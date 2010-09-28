{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit ReestrPz;

Interface


Uses Dialogs,Drivers,Glob,Access,ServStr,Utils8;

Type
  PReestrPrzWindow = ^TReestrPrzWindow;
  TReestrPrzWindow = object(TDialog)
    ViewPrz  : PFullScreenPrz;
    constructor Init(Var l: Boolean);
    procedure OpenReestrPzWindow;
    procedure HandleEvent(var Event: TEvent); virtual;
    Procedure FormPReport(Const p:PBox);
    procedure Correct;
    procedure Refresh;
    procedure DrawCurrent;
  end;


Implementation

uses DBEngine,Objects, Views, MsgBox,{Vision,Calc,}Dos,Vision1,TpDate,Vision2,
     Vision5,Protect,NET,Prihod,Access2,Utils3,
     App, ColorTxt,Serv,{InpLong,{Validate,}Tools,Printers,ComboBox,NetDbEng,UTils;

Const CIZenaK=12;

var
 DocList : PBox;
 ControlStatus,Control,ControlSort,ControlAllDoc,ControlPeriod,
 ControlPrim,
 ControlAllSumma,ControlAllZakupka: PView;
 PrevCur : TMyString;
 DocReestrPWindow:PReestrPrzWindow;
 StartDate,StopDAte,DocDate : TDateString;
 StartTime:LongInt;
 Start,Stop,RefreshTime:LongInt;
 AllDoc,AllZakupka,AllSumma : String[CIZena];
 PrevS : String;


procedure TReestrPrzWindow.OpenReestrPzWindow;
Var l : Boolean;
begin

  if Message(Desktop, evBroadcast, cmReestrPrz, nil) = nil then
  begin
    L:=True;

    StartDate:=FDate;
    StopDate:=FDate;

    start:=DateStringToDate(DAtemask,StartDate);
    stop:=DateStringToDate(DAtemask,StopDate);

    DInfo('Инициализация реестра документов переоценки...');
    DocReestrPWindow := New(PReestrPrzWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(DocReestrPWindow);
    NoInfo;
    End
    Else
     Begin
      TekDate:=FDate;
      Dispose(DocReestrPWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(DocReestrPWindow) <> Desktop^.TopView then DocReestrPWindow^.Select;

end;


Procedure TReestrPrzWindow.Refresh;
Var Fp : PereozenkaFileType;
    s: TMyString;
    ws : AllStr;
    E : PPereozenkaType;
    FPos:Byte;
    FS : AllStr;
    c : Word;
    R : TRect;
    Cur : LongInt;
    TempS : TDateString;
    mSorting:Maska3;
    mStatus : Maska2;
Begin
New(E,Init);
AllDoc[0]:=#0;
AllSumma[0]:=#0;

DocList^.NewList(Nil);
DocList^.NewList(New(PMyCollection, Init(0,1)));


For Cur:=Start To Stop Do
Begin
c:=IOResult;
TempS:=DAteToDateString(DAteMask,Cur);
DInfoMsgShkala('Просматриваю переоценки за '+TempS+' ...',Start,Stop,Cur);
Assign(fp,Path^.Dat.ToCorrect+TempS+'.prz');
Reset(fp);
c:=IOResult;
If c=0 Then
 Begin
While Not(Eof(Fp)) Do
 Begin
  ReadPereozenka(Fp,E);

    Str(StrToInt(AllDoc)+1:CArtikul-1,AllDoc);
    DelSpace(AllDoc);
    RFormatZerro(E^.Dat.Document,CDocNumer);
    Format(E^.Dat.Document,CDocNumer);
    s:='│';
    s:=s+E^.Dat.Document+'│'+E^.Dat.DateC+'│'+E^.Dat.TimeC+'│';

    DelSpace(E^.Dat.Itogo_Bak_R_Zena);
    RFormat(E^.Dat.Itogo_Bak_R_Zena,CIZenaK);
    s:=s+E^.Dat.Itogo_Bak_R_Zena+'│';


    DelSpace(E^.Dat.Itogo_New_R_Zena);
    RFormat(E^.Dat.Itogo_New_R_Zena,CIZenaK);
    s:=s+E^.Dat.Itogo_New_R_Zena+'│';


    DelSpace(E^.Dat.Delta_RZ);
    RFormat(E^.Dat.Delta_RZ,CIZenaK);
    s:=s+E^.Dat.Delta_RZ+'│';

    MyStr(StrToReal(AllSumma)+StrToReal(E^.Dat.Delta_RZ),CIZena,CMantissa,AllSumma);
    DelSpace(AllSumma);

    ws:=GetOperatorField(FNAme,E^.Dat.Caption);
    Format(Ws,CKto);
    s:=s+ws+'│';

    Str(E^.Dat.Vid:1,ws);
    s:=s+ws;
    DocList^.List^.Insert(NewStr(s));
    DocList^.SetRange(DocList^.List^.Count);
 End;{While}
System.Close(Fp);
End;{If IOResult}
End;{For}
NoInfoMsg;
Dispose(E,Done);
DocList^.FocusItem(0);




Str(StrToInt(AllDoc):CArtikul-1,AllDoc);
DelSpace(AllDoc);


MyStr(StrToReal(AllSumma),CIZena,CMantissa,AllSumma);
DelSpace(AllSumma);


Dispose(ControlAllSumma,Done);
R.Assign(60, 22, 75, 23);
ControlAllSumma := New(PColoredText, Init(R, #3+AllSumma, $4E));
Insert(ControlAllSumma);

Dispose(ControlAllDoc,Done);
R.Assign(37, 22, 42, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);

Dispose(ControlPeriod,Done);
R.Assign(2, 0, 76, 1);
ControlPeriod := New(PColoredText, Init(R, #3+'Реестр документов переоценки на складе за период с '+StartDate+' по '+StopDate,
$4F));
ControlPeriod^.Options := ControlPeriod^.Options or ofCenterX;
Insert(ControlPeriod);
Prevs[0]:=#0;
End;


constructor TReestrPrzWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  s: TMyString;
  ws : AllStr;
  E : PPrihodType;
  fp : PrihodFileType;
  Cur,start,Stop:LongInt;
begin

L:=False;
R.Assign(1, 0, 79, 23);
inherited Init(R, '');
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$F061;

R.Assign(77, 2, 78, 22);
Control := New(PScrollBar, Init(R));
Insert(Control);



R.Assign(1, 2, 77, 22);
DoCList := New(PBox, Init(R, 1, PScrollBar(Control)));
DoCList^.NewList(New(PMyCollection, Init(1,1)));
DocList^.HelpCtx:=$F291;
DocList^.FocusItem(0);
Insert(DocList);


MyStr(StrToReal(AllSumma),CIZena,CMantissa,AllSumma);
DelSpace(AllSumma);

Str(StrToInt(AllDoc):CArtikul-1,AllDoc);
DelSpace(AllDoc);

  R.Assign(1, 1, 74, 2);
  Insert(New(PLabel, Init(R,' Док    Дата     Время   Было по Р/Ц Стало по Р/Ц  Переоценка   Оператор', DocList)));



R.Assign(1, 22, 13, 23);
Control := New(PColoredText, Init(R, ' Примечание:', $74));
Insert(Control);

R.Assign(13, 22, 26, 23);
ControlPrim := New(PColoredText, Init(R, #3+'???', $7E));
Insert(ControlPrim);


R.Assign(42, 22, 60, 23);
Control := New(PColoredText, Init(R, ' Всего переоценка:', $74));
Insert(Control);


R.Assign(60, 22, 75, 23);
ControlAllSumma := New(PColoredText, Init(R, #3+AllSumma, $4E));
Insert(ControlAllSumma);


R.Assign(25, 22, 37, 23);
Control := New(PColoredText, Init(R, ' Документов:', $74));
Insert(Control);


R.Assign(37, 22, 42, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);

R.Assign(2, 0, 76, 1);
ControlPeriod := New(PColoredText, Init(R, #3+'Реестр документов переоценки на складе за период с '+StartDate+' по '+StopDate,
$4F));
ControlPeriod^.Options := ControlPeriod^.Options or ofCenterX;
Insert(ControlPeriod);


SelectNext(False);
L:=True;
Refresh;
PrevCur[0]:=#0;
end;









Procedure TReestrPrzWindow.FormPReport(Const P:PBox);
Const Space='  ';
Var f : text;
    mys,Skidka,Summa,ws,s,s1 : String;
    i,c,k : Word;
    mSorting: Maska5;
    mStatus : Maska2;
    tt : Real;
    TempStr,Datestr:DateString;
    LocR,LocP,LocI:Real;
    LocDoc:LongInt;
    PrintItog,PrintDate : Boolean;
    Vid : Word;
    A : DocumentEdit;

Begin
DInfoMsg('Формирую отчет...',False);

If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path^.Dat.ToTemp+'listrpz.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(#3^m+#3+'Не могу создать файл '+Path^.Dat.ToTemp+'listrpz.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(f,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1999');
 Writeln(f,Space+'  РЕЕСТР ДОКУМЕНТОВ ПЕРЕОЦЕНКИ ТОВАРА НА СКЛАДЕ  с '+StartDate+' по '+StopDate);
 Writeln(f,Space+'┌────┬────────┬────────┬────────────┬────────────┬────────────┬────────────┬──────────┐');
 Writeln(f,Space+'│Док │ Дата   │  Время │ Было по РЦ │Стало по РЦ │    Delta   │  Оператор  │  Статус  │');
 Writeln(f,Space+'└────┴────────┴────────┴────────────┴────────────┴────────────┴────────────┴──────────┘'+HeaderStop);
                  {1234 12345678 12345678 123456789012 123456789012 123456789012 123456789012 возвр.}

If (P^.List^.Count-1)>=0 Then
 Begin

 s := P^.GetText(0,P^.List^.Count);

 DateStr:=Copy(s,1+1+CDocNumer+1,CDate);
 LocI:=0;
 LocDoc:=0;
 Writeln(f,Space+'Дата: '+DateStr);



 For c:=0 To P^.List^.Count-1 Do
  Begin
   PrintItog:=False;
   PrintDate:=False;
   s := P^.GetText(c,P^.List^.Count);

 A.EditPosition:=Copy(s,1+1,CDocNumer);
 DelSpace(A.EditPosition);
 DelZerro(A.EditPosition);
 A.D:=Copy(s,1+1+CDocNumer+1,CDate);
 DelSpace(A.D);


   While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert(SeparatorChar,s,k);
    End;

   System.Delete(s,1,1);
   s1:=Copy(s,1+CDocnumer+1+CDAte+1+CDAte+1+CIZenaK+1+CIZenaK+1+CIZenaK+1+CKto+1,COne);
   s[0]:=Chr(CDocNumer+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CIZenaK+1+CKto+1);
    CAse StrToInt(s1) Of
    0:s1:='';
    1:s1:='по возврату';
    Else s1:='???';
    End;
    s:=s+' '+s1;

   Writeln(f,Space+' '+s);
   DelSpaceRight(s1);

   s:=Copy(s,1+CDocNumer+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1,CIZenaK);
   LocI:=LocI+StrToReal(s);
   Inc(LocDoc);

   If c<P^.List^.Count-1 Then
    Begin
     ws := P^.GetText(c+1,P^.List^.Count);
     TempStr:=Copy(ws,1+1+CDocNumer+1,CDate);
     If TempStr<>DateStr Then
      Begin
       {DateStr:=TempStr;}
       PrintDate:=True;
       PrintItog:=True;
      End;
    End
    Else PrintItog:=True;

 If PrintItog Then
 Begin
 Writeln(f,Space,'───────────── Всего за:'+DateStr+' ',RecognizReal(LocI,CIZena,CMantissa),
 '   документов: ',LocDoc:3,' ───────────');
 DateStr:=TempStr;
 LocI:=0;
 LocDoc:=0;
 End;
 If PrintDate Then
 Writeln(f,Space+'Дата: '+DateStr);



  End;

 End;
 Writeln(f,Space+'─────────────────────────────────────────────────────────────────────────────');

 Writeln(f,Space+'                                       Всего документов: ',StrToInt(AllDoc):CIZena);
 Writeln(f,Space+'                                       Всего переоценка: '+RecognizReal(StrToReal(AllSumma),
 CIZena,CMantissa),' руб');
 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'=============================================================================');


 System.Close(f);
 NoInfoMsg;

 ViewAsText(Path^.Dat.ToTemp+'listrpz.txt','Отчет реестр переоценок с '+StartDate+' по '+StopDate,True);

 End;

End;





procedure TReestrPrzWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1 : String;
    SDoc : ArtikulStr;
    SDate: TDateString;
    l : Boolean;
    FC:Byte;
    FS : AllStr;
    s2 : TDateString;

begin

  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbEsc: Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
            End;

     kbF4 : Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
             If Password(4) Then Correct;
             ClearEvent(Event);
            End
            End;

      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of

  cmGetName: Begin
              PString(Event.InfoPtr)^ := 'Реестр переоценок за период с '+StartDate+' по '+StopDate;
              ClearEvent(Event);
              Exit;
             End;

  cmPrintReestr:    Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+1+CDocNumer+1,CDate);
                DelSpace(Assistent.D);
                If MessageBox(^M+#3'Печатать акт переоценки N '+Assistent.EditPosition+' от '+Assistent.D+'?',Nil,
                         mfConfirmation+mfOKCancel)=cmOk Then
                PrintAktPrz(Assistent);

              Redraw;

            End
            End;


cmFullView: Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+1+CDocNumer+1,CDate);
                DelSpace(Assistent.D);
                ViewPrz^.FullScreenPrz(Assistent);
            End
            End;



  cmChangeDiapason:Begin
              s1:=StartDate;
              s2:=StopDate;
              If DatePeriodDialog(s1,s2,False) Then
              Begin
              StartDate:=s1;
              StopDate:=s2;
              start:=DateStringToDate(DAtemask,StartDate);
              stop:=DateStringToDate(DAtemask,StopDate);
              Refresh;
              ClearEvent(Event);
              Redraw;
              End;
                            End;


 cmReestrReport:    Begin
                 ClearFind;
     If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
            FormPReport(DocList);
            Redraw;
            End
            End;
     cmReestrPrz:Begin
                  ClearFind;
                  ClearEvent(Event);
                  Redraw;
                 End;
     cmRefresh  :Begin
                  ClearFind;
                  ClearEvent(Event);
                  Refresh;
                  Redraw;
                 End;
     cmCancel    : Begin
                 {Dispose(DocList,Done);}
                 ClearFind;
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 ClearEvent(Event);
                End;
(*     cmClose  : Begin
                 {Dispose(ControlModifyDate,Done);}
                 {Dispose(ControlAllSkidka,Done);}
                 inherited HandleEvent(Event);
                 Exit;
                End;*)

      Else;
      End;{evCommand}
      Else;
      End;{*Case*}

  if (Event.What = evBroadcast) and
    (Event.Command = cmReestrPrz) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);


  inherited HandleEvent(Event);


  If (Desktop^.Current=PView(DocReestrPWindow)) And (Event.What <> EvKeyDown) Then
             Begin
            if (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
              Begin
               DrawCurrent;
              End;
             End;

end;


procedure TReestrPrZWindow.Correct;
Var Ass : DocumentEdit;
    E : PPereozenkaType;
    R : TRect;
    f : PereozenkaFileType;
    c : Word;
    P : PBox;
    s,ws : TMyString;
    Find : Boolean;
    SDoc : ArtikulStr;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];
Begin
If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+1,
  CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+1+CDocNumer+1,
  CDate);
  DelSpace(Ass.D);

  Assign(f,Path^.Dat.ToCorrect+Ass.d+'.prz');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
  Begin
   MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToCorrect+Ass.d+'.prz',Nil,mfError+mfCancelButton);
   Exit;
  End;
  DInfoMsg('Ищу документ...',False);
  New(E,Init);
  Find := False;
  ClearChar(Ass.EditPosition);
  While Not(Eof(f)) And Not(Find) Do
   Begin
   ReadPereozenka(F,E);
   ClearChar(E^.Dat.Document);
    If (E^.Dat.DateC=Ass.D) and (E^.Dat.Document=Ass.EditPosition) Then
          Begin
           Find:=True;
           Break;
          End;
   End;


   If Find Then
    Begin
     System.Seek(f,FilePos(f)-1);
     E^.DAt.SkladKod:=Rek^.Dat.Kod;
    {E^.DAt.Vid:=0;}
     Write(f,E^.DAt);
    End;

   c:=IOResult;
   System.Close(f);
   c:=IOResult;

  Dispose(E,Done);
  NoInfomsg;
  If Find Then
  MessageBox(#3^M+#3'Операция успешно завершена!',Nil,mfError+mfCancelButton)
  Else
  MessageBox(#3^M+#3'Документ не найден!',Nil,mfError+mfCancelButton);
                   {Вставить номер и дату документа в просмотре}
    End
Else
  Begin
   NoInfomsg;
   MessageBox(#3^M+#3'Документ не найден!',Nil,mfError+mfCancelButton);
   Dispose(E,Done);
  End;
End;







procedure TReestrPrZWindow.DrawCurrent;
VAr S : String;
    R : TRect;
    TempS : AllStr;
Begin

If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
  Begin

   s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
   If s<>PrevS Then
   Begin
    Prevs:=s;
    s:=Copy(s,1+1+CDocNumer+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+CIZenaK+1+CKto+1,COne);

    CAse StrToInt(s) Of
    0:s:='';
    1:s:='по возврату';
    Else s:='???';
    End;

    Dispose(ControlPrim,Done);
    R.Assign(13, 22, 26, 23);
    ControlPrim := New(PColoredText, Init(R, #3+s, $7E));
    Insert(ControlPrim);
   End;

  End
  Else
   Begin
    If PStaticText(ControlPrim)^.Text^<>#3'???' Then
    Begin
     Dispose(ControlPrim,Done);
     R.Assign(13, 22, 26, 23);
     ControlPrim := New(PColoredText, Init(R, #3+'???', $7E));
     Insert(ControlPrim);
    End;
   End;

End;








BEgin
End.