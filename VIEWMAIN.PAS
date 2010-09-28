{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit viewMain;


Interface


Uses Glob,Views,Dialogs,ServSTr,Drivers,
     Utils1,Utils4,Slava3,FindPrh;



Type PMainNameWindow= ^TMainNameWindow;
     TMainNameWindow = object(TDialog)
     lnk : PLinkWindow;
     RKod: String[cRazdelKod];
     FR  : PFindRezervWindow;
     FP  : PFindPrh;
     BKod: ArtikulStr;
     Procedure ShowMainNameList(SKod:ArtikulStr;VAr S:TMyString;Var Res: Word);
     Procedure Refresh;
     procedure HandleEvent(var Event: TEvent); virtual;
     Procedure DrawCurrent;
     Destructor Done;Virtual;
  end;


implementation


Uses App,Serv,Objects,DbEngine,MsgBox,StHolder,Utils5,Net,Mail,Access2,
     TVInput,TvType,TvConst,Validate,Vision1,NetDbEng,Filetool,ColorTxt,
     DbEngin2,Utils,ServStr2,
     Printers,TPDate,Prise,Protect,MyView,Tools,Utils6;


Var MainNameWindow : PMainNameWindow;
    PrevCurrentLine : String;
    MainList : PBox;
    ControlPost,ControlVid,ControlFirmaPost : PView;
    VidView: Word;


Procedure TMainNameWindow.ShowMainNameList(SKod:ArtikulStr;VAr S:TMyString;Var Res: Word);
var
  R : TRect;
  Control : PView;
  st : String;
  c,Count: Word;
  i,j : Word;
  Skl : PBufBazType;
  Sklf :File;
  Cod : ArtikulStr;
  PrevS : TMyString;
  MySet:Set Of Byte;
  Event : TEvent;
Begin
PrevS:=s;
Cod:=Copy(s,Pos('│',s)+1,CArtikul);
ClearFind;
(*

  MySet:=[];

  If StrToInt(Copy(Cod,1,CRazdelKod)) in [0..10] Then
   Begin
    MySet:=[0..10];
    VidView:=0;
   End;

  If StrToInt(Copy(Cod,1,CRazdelKod)) in [11..20] Then
   Begin
    MySet:=[11..20];
    VidView:=1;
   End;

  If StrToInt(Copy(Cod,1,CRazdelKod)) in [21..30] Then
   Begin
    MySet:=[21..30];
    VidView:=2;
   End;

  If StrToInt(Copy(Cod,1,CRazdelKod)) in [31..50] Then
   Begin
    MySet:=[31..50];
    VidView:=3;
   End;

  If StrToInt(Copy(Cod,1,CRazdelKod)) in [51..99] Then
   Begin
    MySet:=[51..99];
    VidView:=4;
   End;

*)

R.Assign(9, 0, 71, 22);
New(MainNameWindow, Init(R, ''));
MainNameWindow^.Options := MainNameWindow^.Options or ofCenterX or ofCenterY;
MainNameWindow^.HelpCtx:=$F921;
MainNameWindow^.BKod:=Cod;
MainNameWindow^.RKod:=SKod;

(*
R.Assign(5, 21, 59, 22);
ControlVid := New(PRadioButtons, Init(R,
  NewSItem('~0~-10',
  NewSItem('~1~1-20',
  NewSItem('~2~1-30',
  NewSItem('~3~1-50',
  NewSItem('~5~1-99',
  Nil)))))));
MainNameWindow^.Insert(ControlVid);

ControlVid^.SetData(VidView);
*)


R.Assign(61, 2, 62, 19);
Control := New(PScrollBar, Init(R));
MainNameWindow^.Insert(Control);

R.Assign(1, 2, 61, 19);
MainList := New(PBox, Init(R, 1, PScrollbar(Control)));
MainList^.NewList(New(PTextCollection, Init(0,1)));

If MainNameWindow^.BKod=NoSertifStr Then MainNameWindow^.BKod[0]:=#0;

DInfoMsg('Читаю списки товаров ...',False);
(*
For i:=0 To 99 Do
Begin
 DInfoMsgShkala('Читаю списки товаров ...',0,99,i);
 If Not(i in MySet) Then Continue;
 St:=IntToStr(i,CMantissa);
 RFormatZerro(St,CMantissa);
 St:=St;
{If EnableCash=0 Then}
Begin
*)
 If Not GetRazdelStatus(MainNameWindow^.RKod) Then
  Begin
   Assign(SklF,Path^.Dat.ToName+MainNameWindow^.RKod+'.id');
   j:=IOResult;
   Reset(Sklf,SizeOf(BazType));
   j:=IOResult;
   If j=0 Then
    Begin
     {MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToName+St+'.id!'+ClicProgrammer^,Nil,mfError+mfCancelButton);}
     {Continue;}
   While Not(Eof(Sklf)) Do
    Begin
     Count:=0;
     New(Skl,Init);
     ReadBufBaz(Sklf,Skl,Count);
     j:=IOResult;
For c:=1 To Count Do
Begin
     If (Skl^.Point.Dat[c].Employ) and (Skl^.Point.Dat[c].Main=0)Then
     {If (Skl^.Point.Dat[c].BazKod<>MainNameWindow^.BKod) Then}
      Begin
       PrevCurrentLine:=Skl^.Point.Dat[c].Name+' '+Skl^.Point.Dat[c].Name2;
       Format(PrevCurrentLine,CNAme+1+CNAme);
       PrevCurrentLine:=PrevCurrentLine+'│'+Skl^.Point.Dat[c].BazKod+'│'+
	  Skl^.Point.Dat[c].PostKod+'│'+Skl^.Point.Dat[c].FirmaPostKod;
       MainList^.List^.Insert(NewStr(PrevCurrentLine));
       MainList^.SetRange(MainList^.List^.Count);
      End;{If Employ}
End;{For}
     Dispose(Skl,Done);
    End;{While}
   System.Close(Sklf);
    End;
   j:=IOResult;
   {MemC(st);}
  End;{GetRazdelStatus}
(*
End{EnableCash=0}
End;{For}
*)
NoInfoMsg;

If MainNameWindow^.BKod[0]<>#0 Then
MainList^.FocusItem(Location(MainList,Cod,False))
Else
MainList^.FocusItem(0);

MainNameWindow^.Insert(MainList);

  R.Assign(1, 1, 60, 2);
  MainNameWindow^.Insert(New(PLabel, Init(R, 'Наименование товара                                    Код', MainList)));

R.Assign(14, 19, 21, 20);
Control := New(PColoredText, Init(R, 'Страна:', $74));
MainNameWindow^.Insert(Control);

R.Assign(21, 19, 61, 20);
ControlPost := New(PColoredText, Init(R, '', $7E));
MainNameWindow^.Insert(ControlPost);

R.Assign(1, 20, 21, 21);
Control := New(PColoredText, Init(R, 'Фирма-производитель:', $74));
MainNameWindow^.Insert(Control);

R.Assign(21, 20, 61, 21);
ControlFirmaPost := New(PColoredText, Init(R, '', $7E));
MainNameWindow^.Insert(ControlFirmaPost);

{MainNameWindow^.SelectNext(False);}

PrevCurrentLine[0]:=#0;
{EnableCommands([cmFindLink]);}
NoInfoMsg;
c:=Desktop^.ExecView(MainNameWindow);
{DisableCommands([cmFindLink]);}
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Res in [2,3] Then
   S:=MainList^.GetText(MainList^.Focused,MainList^.List^.Count);

   If Res=1 Then
    BEgin
     s:=PrevS;
    End;
   s[0]:=Chr(CNAme+1+CNAme+1+CArtikul);

Application^.ClearEvent(Event);

Dispose(COntrol,Done);
Dispose(MainNameWindow,Done);
End;


Procedure TMainNameWindow.Refresh;
Var
  c,Count: Word;
  i,j : Word;
  Skl : PBufBazType;
  Sklf :File;
  St : String;
  Cod : ArtikulStr;
  MySet:Set Of Byte;
Begin
{cod:=Copy(MainList^.GetText(MainList^.Focused,MainList^.List^.Count),1+CNAme+1+CName+1,CArtikul);}
MainList^.NewList(Nil);
MainList^.NewList(New(PTextCollection, Init(0,1)));
(*
  MySet:=[];

  Case VidView Of
  0:MySet:=[0..10];
  1:MySet:=[11..20];
  2:MySet:=[21..30];
  3:MySet:=[31..50];
  4:MySet:=[51..99];
  Else Exit;
  End;
*)
(*
For i:=0 To 99 Do
Begin
 DInfoMsgShkala('Читаю списки товаров ...',0,99,i);
 If Not(i in MySet) Then Continue;
 St:=IntToStr(i,CMantissa);
 RFormatZerro(St,CMantissa);
 St:=St;
*)
 If Not GetRazdelStatus(MainNameWindow^.RKod) Then
  Begin
   Assign(SklF,Path^.Dat.ToName+MainNameWindow^.RKod+'.id');
   j:=IOResult;
   Reset(Sklf,SizeOf(BazType));
   j:=IOResult;
   If j=0 Then
    Begin
     {MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToName+St+'.id!'+ClicProgrammer^,Nil,mfError+mfCancelButton);}
     {Continue;}
   While Not(Eof(Sklf)) Do
    Begin
     Count:=0;
     New(Skl,Init);
     ReadBufBaz(Sklf,Skl,Count);
     j:=IOResult;
For c:=1 To Count Do
Begin
     If (Skl^.Point.Dat[c].Employ) and (Skl^.Point.Dat[c].Main=0) Then
     {If (Skl^.Point.Dat[c].BazKod<>MainNameWindow^.BKod) Then}
      Begin
       PrevCurrentLine:=Skl^.Point.Dat[c].Name+' '+Skl^.Point.Dat[c].Name2;
       Format(PrevCurrentLine,CNAme+1+CNAme);
       PrevCurrentLine:=PrevCurrentLine+'│'+Skl^.Point.Dat[c].BazKod+'│'+
       Skl^.Point.Dat[c].PostKod+'│'+Skl^.Point.Dat[c].FirmaPostKod;
       MainList^.List^.Insert(NewStr(PrevCurrentLine));
       MainList^.SetRange(MainList^.List^.Count);
      End;{If Employ}
End;{For}
   Dispose(Skl,Done);
    End;{While}
   System.Close(Sklf);
   j:=IOResult;
    End;
  End;{GetRazdelStatus}
{End;{For}
NoInfoMsg;
Redraw;
End;



procedure TMainNameWindow.HandleEvent(var Event: TEvent);
Var test   : Word;
    s,s1   : String;
    l      : Boolean;
  SName,SNAme2   : String[CName];
  SKSertif : String[CAll];
  SDSertif : String[CAll];
  Art      : ArtikulStr;
  SLitr    : String[CLitr];
  IO       : Word;

Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
    Msg : StrNAme;
Begin
  LockSelect:=False;
  s:=Copy(MainList^.GetText(MainList^.Focused,MainList^.List^.Count),1+CName+1+CNAme+1,Cartikul);
  R:=GetIdEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Позиция ['+s+'] отмечена как удаленная. Не могу заблокировать!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End;

  If SetNameLock(s,Msg) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg('Позиция ['+s+'] используется'+Msg+'. Не могу заблокировать!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
   End;
End;



Begin
  CAse Event.What Of
  evCommand:
    Begin
    CAse Event.Command Of
    cmRefresh:Begin
               Refresh;
              End;
    Else;
    End;
    End;{EvCommand}
  evKeyDown:
    Begin
      Case Event.KeyCode Of
     kbDel: Begin

If Not(TestOpenDate1(FDAte)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    {MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);}
    ClearEvent(Event);
    Exit;
   End;
ClearFind;

{Удаление товара со склада}
     If Password(18) Then
     If (MainList^.State and sfFocused <> 0) And (MainList^.List<>Nil)And(MainList^.List^.Count>=1) Then
            Begin
             If MessageBox(#3+DelBazName^,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
               test := IOResult;
               s:=MainList^.GetText(MainList^.Focused,MainList^.List^.Count);
               s:=Copy(s,1+CName+1+CName+1,Cartikul);
               Art:=s;

               If Not(LockSelect) Then
                        Begin
                         ClearEvent(Event);
                         exit;
                        End;

                If DelNameFromDB(s) Then
                Begin
                 MainList^.List^.AtFree(MainList^.Focused);
                 MainList^.SetRange(MainList^.List^.Count);
                 If (MainList^.Focused>=MainList^.List^.Count) and(MainList^.Focused>0) Then
                 MainList^.FocusItem(MainList^.Focused-1);
                 AddProtocol('Удаление наименования:'+s+' '+GetIdField(FName,s),'','')
                End
                 Else
                  Begin
                   s1:=Copy(s,1,CRazdelKod);
                   MessageBox(^m+#3'Ошибка доступа к файлу '+s1+'.db!',nil,mfError+mfCanCelButton);
                  End;

                Repeat
                Until (SetNameUnLock(Art));


              End
              Else Begin
                    ClearEvent(Event);
                   End;
            ClearEvent(Event);
            End;
            Redraw;
            End;
     kbEsc: Begin
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
            End;
      Else;
      End;{Event,KeyCode}
    End;{EvKeyDown}
  Else;
  End;

(*
  if( ((Event.What = evMouseDown) and (Event.Double) And (MainList^.State and sfFocused <> 0)) or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbEnter)))

     And
     ((MainList^.List<>Nil)And(MainList^.List^.Count>=1))

	 Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbTab)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlRight)) Then
  begin
              Event.What:=evCommand;
              Event.Command:=cmOk;
              Event.InfoPtr:=Nil;
              {PutEvent(Event);}
  end;

  if ((Event.What = evKeyDown) and (Event.KeyCode = kbEsc))then
  begin
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
  end;
*)

  if( ((Event.What = evMouseDown) and (Event.Double)) or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbEnter)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlEnter)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbTab)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlRight)))
	And
     ((MainList^.List<>Nil)And(MainList^.List^.Count>=1))
	 Then
  begin
              Event.What:=evCommand;
              Event.Command:=cmOk;
              PutEvent(Event);
              ClearEvent(Event);
  end;
  if (
     ((Event.What = evKeyDown) and (Event.KeyCode =kbShiftTab))Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlLeft))
	)	And
     ((MainList^.List<>Nil)And(MainList^.List^.Count>=1))

	Then
  begin

              Event.What:=evCommand;
              Event.Command:=cmYes;
              PutEvent(Event);
              ClearEvent(Event);

  end;

  if ((Event.What = evKeyDown) and (Event.KeyCode = kbEsc))then
  begin
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
  end;



 if (Event.What = evBroadcast) and
     (Event.Command = cmSelectMainName) then ClearEvent(Event);

  inherited HandleEvent(Event);

  If (Desktop^.Current=PView(MainNameWindow)) And (Event.What <> EvKeyDown) Then
          Begin
           DrawCurrent;
{
          if (ControlVid^.State and sfFocused <> 0)Then
              Begin
               ControlVid^.GetData(Test);
               If Test <> VidView Then
               Begin
                  VidView:=Test;
                  Refresh;
                  Redraw;
               End;
              End;
 }
          End;

  ClearEvent(Event);
End;



Procedure TMainNameWindow.DrawCurrent;
Var S : String;
    R : TRect;
Begin
if (MainList^.State and sfFocused <> 0)  And(MainList^.List<>Nil) And (MainList^.List^.Count>=1)Then
 Begin
  s:=MainList^.GetText(MainList^.Focused,MainList^.List^.Count);
  If s <> PrevCurrentLine Then
   Begin
    PrevCurrentLine:=S;
    S:=Copy(s,1+CNAme+1+CNAme+1+CArtikul+1,CClientKod);
    DelSpaceRight(S);
    Dispose(ControlPost,Done);
    R.Assign(21, 19, 61, 20);
    ControlPost := New(PColoredText, Init(R, GetPostField(FPost,S)+' ('+S+')', $7E));
    Insert(ControlPost);

    s:=PrevCurrentLine;
    S:=Copy(s,1+CNAme+1+CNAme+1+CArtikul+1+CClientKod+1,CClientKod);
    DelSpaceRight(S);
    Dispose(ControlFirmaPost,Done);
    R.Assign(21, 20, 61, 21);
    ControlFirmaPost := New(PColoredText, Init(R, GetFirmaPostField(FFirmaPost,S)+' ('+S+')', $7E));
    Insert(ControlFirmaPost);
    Redraw;
   End
 End;
End;


Destructor TMainNameWindow.Done;
Begin
ClearFind;
Dispose(ControlPost,Done);
Dispose(ControlFirmaPost,Done);
Dispose(MainList,Done);
TDialog.Done;
End;



Begin

End.