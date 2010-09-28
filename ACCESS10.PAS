{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Access10;

Interface

Uses Dialogs,Glob,Slava3,Drivers,ServStr,Utils1;


Type
    PSelClientWindow= ^TSelClientWindow;
    TSelClientWindow = object(TDialog)
    OperatorSelector : Word;{0-клиенты 1}

    Reg,Sel : Word;
    BKod: ArtikulStr;{код клиента}
    Procedure ShowMainClient(Var st:String;Var Re,se,Res: Word);
    Procedure DrawCurrent;
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;




Implementation

{$I Compile.INC}

Uses Printers,App,Views,Objects,MsgBox,Serv,ColorTxt,Validate,
     DbEngin2,Memory,TpDate,DbEngine,Servstr2,MyView,Utils,Utils5,
     Access,
     Protect,Net,Net1,NetDbEng;

Const LocalReadOnlyN=$42;

Var

   KSertifWindow : PSelClientWindow;
   KSertifList : PBox;
   ControlAdresU,ControlAdresf : PView;
   PrevCurrentLine : PString;




Procedure TSelClientWindow.ShowMainClient(Var st:String;Var Re,se,Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s,st1 : String;
  Bak : String;
  c: Word;
  c1,Count : Word;
  Clf : File;
  CLE : PBufClientType;
begin
Bak :=St;
ClearFind;

Res:=0;
R.Assign(3, 2, 77, 21);
New(KSertifWindow, Init(R, 'Укажите главного контрагента'));

KSertifWindow^.Reg:=Re;
KSertifWindow^.Sel:=Se;

if Bak[0]<>#0 Then
KSertifWindow^.BKod:=Copy(Bak,Pos('│',Bak)+1,CClientKod)
Else
KSertifWindow^.BKod[0]:=#0;


R.Assign(73, 2, 74, 16);
Control := New(PScrollBar, Init(R));
KSertifWindow^.Insert(Control);

R.Assign(1, 2, 73, 16);
KSertifList := New(PBox, Init(R, 1, PScrollbar(Control)));
KSertifList^.NewList(New(PTextCollection, Init(0,1)));



Case KSertifWindow^.Reg Of
bClient:Begin
    Case KSertifWindow^.Sel Of
     0:Assign (ClF,Path^.Dat.ToClient+'Client.db');
     1:Assign (ClF,Path^.Dat.ToClient+'Sklad.db');
     2:Assign (ClF,Path^.Dat.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
bMake:Begin
    Case KSertifWindow^.Sel Of
     0:Assign (ClF,Path^.Dat.ToClient+'Make.db');
     1:Assign (ClF,Path^.Dat.ToClient+'Sklad.db');
     2:Assign (ClF,Path^.Dat.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
Else;
End;


Reset (ClF,SizeOf(ClientType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(ClF)) Do
 Begin
    DInfoMsgShkala('Читаю списки контрагентов. Ждите... ',0,FileSize(CLF),FilePos(CLF));
    Count:=0;
    New(CLE,Init);
    ReadBufClient(Clf,CLE,Count);
  For c:=1 To Count Do
  Begin
  If (ClE^.Point.Dat[c].Employ) And (ClE^.Point.Dat[c].Main=0) Then
   Begin
    Format (ClE^.Point.Dat[c].Name,CClient);
    Format (ClE^.Point.Dat[c].FullName,CAll);
    Format (ClE^.Point.Dat[c].Adress,CAll);
    Format (ClE^.Point.Dat[c].Enviropment,CAll);
    St1:=ClE^.Point.Dat[c].Kod;
    RFormatZerro(St1,CClientKod);
    s:=ClE^.Point.Dat[c].Name+'│'+St1+'│'+ClE^.Point.Dat[c].FullName+'│'+ClE^.Point.Dat[c].Enviropment+'│'+
    ClE^.Point.Dat[c].Adress+'│';
    KSertifList^.List^.Insert(NewStr(s));
    KSertifList^.SetRange(KSertifList^.List^.Count);
   End;{Employ}
  End;{For}
     Dispose(CLE,Done);
 End;{Eof}
System.Close(ClF);
NoInfoMsg;
End
Else
 Begin
  Res:=1;
  MessageBox(^M+#3'Ошибка доступа к файлам базы ! Код:'+IntToStr(c,CKol),nil,mfError+mfCanCelButton);
  Goto 1;
 End;



R.Assign(3, 16, 12, 17);
Control := New(PColoredText, Init(R, 'Юр.адрес:', $74));
KSertifWindow^.Insert(Control);

R.Assign(12, 16, 73, 17);
ControlAdresU := New(PColoredText, Init(R, '', $7E));
KSertifWindow^.Insert(ControlAdresU);

R.Assign(1, 17, 12, 18);
Control := New(PColoredText, Init(R, '  Лицензия:', $74));
KSertifWindow^.Insert(Control);

R.Assign(12, 17, 73, 18);
ControlAdresF := New(PColoredText, Init(R, '', $7E));
KSertifWindow^.Insert(ControlAdresF);





If KSertifWindow^.BKod[0]<>#0 Then
Begin
RFormatZerro(KSertifWindow^.BKod,CClientKod);
KSertifList^.FocusItem(Location(KSertifList,KSertifWindow^.BKod+'│',False));
End
Else
KSertifList^.FocusItem(0);

KSertifList^.HelpCtx:=$F921;;
KSertifWindow^.Insert(KSertifList);

R.Assign(1, 1, 55, 2);
KSertifWindow^.Insert(New(PLabel, Init(R, 'Клиент               Код  Полное наименование клиента', KSertifList)));


PrevCurrentLine:=NewSTR(#3);
KSertifWindow^.SelectNext(False);
NoInfoMsg;

c:=Desktop^.ExecView(KSertifWindow);
If c<>CmCancel Then
  If c=CmOk Then Res:=2;
  If c=CmYes Then Res:=3;
  If c=CmCancel Then Res:=1;
  If Res in [2,3] Then
   St:=KSertifList^.GetText(KSertifList^.Focused,KSertifList^.List^.Count)
   Else St:=Bak;
1:
Dispose(COntrol,Done);
Dispose(COntrolAdresU,Done);
Dispose(COntrolAdresF,Done);
DisposeSTR(PrevCurrentLine);
Dispose(KSertifWindow,Done);
end;




Procedure TSelClientWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s,St1 : String;
  c,Cod: LongInt;
  KSertifFile : File;
  KSertifElement : PBufKSertifType;
  c1,Count : Word;
  Clf : File;
  CLE : PBufClientType;
begin
ClearFind;

Cod:=KSertifList^.Focused;

KSertifList^.NewList(Nil);
KSertifList^.NewList(New(PTextCollection, Init(0,1)));

Case KSertifWindow^.Reg Of
bClient:Begin
    Case KSertifWindow^.Sel Of
     0:Assign (ClF,Path^.Dat.ToClient+'Client.db');
     1:Assign (ClF,Path^.Dat.ToClient+'Sklad.db');
     2:Assign (ClF,Path^.Dat.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
bMake:Begin
    Case KSertifWindow^.Sel Of
     0:Assign (ClF,Path^.Dat.ToClient+'Make.db');
     1:Assign (ClF,Path^.Dat.ToClient+'Sklad.db');
     2:Assign (ClF,Path^.Dat.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
Else;
End;


Reset (ClF,SizeOf(ClientType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(ClF)) Do
 Begin
    DInfoMsgShkala('Читаю списки контрагентов. Ждите... ',0,FileSize(CLF),FilePos(CLF));
    Count:=0;
    New(CLE,Init);
    ReadBufClient(Clf,CLE,Count);
  For c:=1 To Count Do
  Begin
  If (ClE^.Point.Dat[c].Employ) And (ClE^.Point.Dat[c].Main=0) Then
   Begin
    Format (ClE^.Point.Dat[c].Name,CClient);
    Format (ClE^.Point.Dat[c].FullName,CAll);
    Format (ClE^.Point.Dat[c].Adress,CAll);
    Format (ClE^.Point.Dat[c].Enviropment,CAll);
    St1:=ClE^.Point.Dat[c].Kod;
    RFormatZerro(St1,CClientKod);
    s:=ClE^.Point.Dat[c].Name+'│'+St1+'│'+ClE^.Point.Dat[c].FullName+'│'+ClE^.Point.Dat[c].Enviropment+'│'+
    ClE^.Point.Dat[c].Adress+'│';
    KSertifList^.List^.Insert(NewStr(s));
    KSertifList^.SetRange(KSertifList^.List^.Count);
   End;{Employ}
  End;{For}
     Dispose(CLE,Done);
 End;{Eof}
System.Close(ClF);
NoInfoMsg;
End
Else
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлам базы ! Код:'+IntToStr(c,CKol),nil,mfError+mfCanCelButton);
 End;

If Cod<>0 Then Dec(Cod);
KSertifList^.FocusItem(Cod);
Redraw;
DisposeStr(PrevCurrentLine);
PrevCurrentLine:=NewSTR(#3);
end;







Destructor TSelClientWindow.Done;
Begin
ClearFind;
Dispose(KSertifList,Done);
TDialog.Done;
End;


Procedure TSelClientWindow.DrawCurrent;
Var S : String;
    R : TRect;
Begin
if (KSertifList^.State and sfFocused <> 0)  And(KSertifList^.List<>Nil) And (KSertifList^.List^.Count>=1)Then
 Begin
  s:=KSertifList^.GetText(KSertifList^.Focused,KSertifList^.List^.Count);
  If s <> PrevCurrentLine^ Then
   Begin
    DisposeSTR(PrevCurrentLine);
    PrevCurrentLine:=NewSTR(s);
    S:=Copy(s,1+CClient+1+CClientKod+1+CAll+1+CAll+1,CAll);
    DelSpaceRight(S);
    Dispose(ControlAdresU,Done);
    R.Assign(12, 16, 73, 17);
    ControlAdresU := New(PColoredText, Init(R, S, $7E));
    Insert(ControlAdresU);

    s:=PrevCurrentLine^;
    S:=Copy(s,1+CClient+1+CClientKod+1+CAll+1,CAll);
    DelSpaceRight(S);
    Dispose(ControlAdresF,Done);
    R.Assign(12, 17, 73, 18);
    ControlAdresF := New(PColoredText, Init(R, S, $7E));
    Insert(ControlAdresF);
    Redraw;
   End
 End;
End;




procedure TSelClientWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    Cod : ArtikulStr;
begin
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
     kbF3 : Begin
if (KSertifList^.State and sfFocused <> 0)  And(KSertifList^.List<>Nil) And (KSertifList^.List^.Count>=1)Then
 Begin
 Cod:=Copy(PrevCurrentLine^,1+CClient+1,CClientKod);
 ViewElement(Cod,KSertifWindow^.Reg,KSertifWindow^.Sel);
 End;
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


  if( ((Event.What = evMouseDown) and (Event.Double)) or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbEnter)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlEnter)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbTab)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlRight)))
	And
     ((KSertifList^.List<>Nil)And(KSertifList^.List^.Count>=1))
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
     ((KSertifList^.List<>Nil)And(KSertifList^.List^.Count>=1))

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

  If (Desktop^.Current=PView(KSertifWindow)) And (Event.What <> EvKeyDown) Then
          Begin
           DrawCurrent;
         End;

  ClearEvent(Event);
end;





End.