{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit DStat;


Interface

Uses Drivers,Dialogs,Glob,ServStr,Protect;

Var StopDateA ,StartDateA : TDateString;

Type PAnalysPeriod =^TAnalysPeriod;
     TAnalysPeriod = object(TDialog)
     procedure PrintReport;
     Procedure Start(Clientkod:ArtikulStr);
     procedure HandleEvent(var Event: TEvent); virtual;
     Destructor Done;virtual;
     end;


Function PeriodFromLock(Regim:Boolean):Boolean;

Implementation

uses Objects, TPDate,Printers,Views,MsgBox,DbEngine,
     App, ColorTxt,Validate,Serv,Vision4;


VAr AnalysPeriod :PAnalysPeriod;
    ControlClient:PView;
    OborotList : PBox;

Function PeriodFromLock(Regim:Boolean):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control,ControlStart,ControlStop : PView;
  C : Word;
  Start,Stop,l : LongInt;
  s1,s2,StartLockDAte,StopLockDate : TDateString;

begin
PeriodFromLock:=False;
s1:='01-01-98';
s2:=FDate;

1:
R.Assign(23, 9, 57, 14);
If Regim Then
New(Dlg, Init(R, 'Укажите период блокировки'))
Else
New(Dlg, Init(R, 'Укажите период деблокировки'));

Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E011;
Dlg^.Palette := dpCyanDialog;

R.Assign(6, 2, 16, 3);
ControlStart := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStart);
  PInputLine(ControlStart)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

ControlStart^.SetData(s1);

  R.Assign(3, 2, 6, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~с~:', ControlStart)));

R.Assign(20, 2, 30, 3);
ControlStop := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStop);
  PInputLine(ControlStop)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

ControlStop^.SetData(s2);

  R.Assign(16, 2, 20, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~п~о:', ControlStop)));

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
   ControlStart^.GetData(s1);
   ControlStop^.GetData(s2);
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);

   If Not(TestDate(s1,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Not(TestDate(s2,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   StartLockDate:=s1;
   StopLockDate:=s2;
   PeriodFromLock:=True;

   {если даты перепутаны переставляем их}
   If DateStringToDate(DateMask,StopLockDate)<DateStringToDate(DateMask,StartLockDate) Then
    Begin
        s1:=StopLockDate;
        StopLockDate:=StartLockDate;
        StartLockDate:=s1;
    End;
   If DateStringToDate(DAteMask,'01-01-98')>DateStringToDate(DAteMask,StartLockDate) Then
   StartLockDate :='01-01-98';
   If DateStringToDate(DAteMask,FDAte)<DateStringToDate(DAteMask,StopLockDate) Then
   StopLockDate :=FDate;

   Start:=DateStringToDate(DAteMask,StartLockDate);
   Stop:=DateStringToDate(DAteMask,StopLockDate);

If Regim Then
   DInfo('Блокирую период с '+StartLockDate+' по '+StopLockDAte+'...')
   Else
   DInfo('Деблокирую период с '+StartLockDate+' по '+StopLockDAte+'...');

   For l:=Start To Stop Do
    Begin
    {If (DayOfWeek(L)<>Sunday) Then}
     Begin
      s1:=DateToDAteString(DateMask,l);
      If Regim Then  BlockDate1(S1)
      Else DeBlockDate1(S1);
     End;
      c:=IOResult;
    End;
   NoInfo;

 End
 Else
  Begin
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);
  End;
end;



Function PeriodFromAnalys:Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control,ControlStart,ControlStop : PView;
  C : Word;
  l : LongInt;
  s1,s2 : TDateString;
  Event : TEvent;

begin
PeriodFromAnalys :=False;
s1:=StartDateA;
s2:=StopDateA;

1:
R.Assign(23, 9, 57, 14);
New(Dlg, Init(R, 'Укажите период расчета'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E011;
Dlg^.Palette := dpCyanDialog;


R.Assign(6, 2, 16, 3);
ControlStart := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStart);
  PInputLine(ControlStart)^.Validator := New(PPXPictureValidator, Init('01-[##-##]', True));

ControlStart^.SetData(s1);

{
R.Assign(7, 1, 29, 2);
Control := New(PColoredText, Init(R, '01-##-9#      01-##-9#', $31));
Dlg^.Insert(Control);
}

  R.Assign(3, 2, 6, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~с~:', ControlStart)));

R.Assign(20, 2, 30, 3);
ControlStop := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStop);
  PInputLine(ControlStop)^.Validator := New(PPXPictureValidator, Init('01-[##-##]', True));

ControlStop^.SetData(s2);

  R.Assign(16, 2, 20, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~п~о:', ControlStop)));

Dlg^.SelectNext(False);
Dlg^.SelectNext(False);

Event.KeyCode:=kbEnd;
Event.What:=evKeyDown;
Application^.PutEvent(Event);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
   ControlStart^.GetData(s1);
   ControlStop^.GetData(s2);
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);

   If Not(TestDate(s1,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Not(TestDate(s2,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Copy(S1,4,5)=Copy(S2,4,5) Then
    Begin
     MessageBox(^M+#3'В указанном диапазоне нет ни одного периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   StartDateA:=s1;
   StopDateA:=s2;
   PeriodFromAnalys:=True;

   {если даты перепутаны переставляем их}
   If DateStringToDate(DateMask,StopDateA)<DateStringToDate(DateMask,StartDateA) Then
    Begin
        s1:=StopDateA;
        StopDateA:=StartDateA;
        StartDateA:=s1;
    End;




 End
 Else
  Begin
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);
  End;
end;


Procedure Calcoborot(Const ClientKod:ArtikulStr;Start,Stop:TDateString);
Var
    Es : PStatClientType;
    Esf : File Of StatClientType;
    j : LongInt;
    Itogo : Real;
    ItogoSkidka : Real;
    ItogoDoc : LongInt;
    s : string[150];
    ws : String[CIZena+1];

begin
 Assign(Esf,Path.ToClient+ClientKod+'.his');
 j:=IOResult;
 Reset(Esf);
 j:=IOResult;
 If j<>0 Then Exit;

 Itogo :=0;
 ItogoSkidka:=0;
 ItogoDoc:=0;

 New(Es,Init);
 While Not(Eof(Esf)) Do
  Begin
   Read(Esf,Es^.Dat);
   If Es^.DAt.Active Then
Begin

   If (DAteStringToDate(DAteMask,Es^.Dat.DateC)>=DAteStringToDate(DAteMask,Start))
   And(DAteStringToDate(DAteMask,Es^.Dat.DateC)<=DAteStringToDate(DAteMask,Stop)) Then
    Begin
     Inc(ItogoDoc);
     Itogo:=Itogo+StrToReal(Es^.Dat.SummaZ)+StrToReal(Es^.Dat.Skidka);
     ItogoSkidka:=ItogoSkidka+StrToReal(Es^.Dat.Skidka);
    End;
End;
  End;
 Close(Esf);

 j:=STrToInt(Copy(Start,4,2));

 Case j of
 1:s:='ЯНВАРЬ  │';
 2:s:='ФЕВРАЛЬ │';
 3:s:='МАРТ    │';
 4:s:='АПРЕЛЬ  │';
 5:s:='МАЙ     │';
 6:s:='ИЮНЬ    │';
 7:s:='ИЮЛЬ    │';
 8:s:='АВГУСТ  │';
 9:s:='СЕНТЯБРЬ│';
10:s:='ОКТЯБРЬ │';
11:s:='НОЯБРЬ  │';
12:s:='ДЕКАБРЬ │';
  Else s:='        │';
  End;

 j:=STrToInt(Copy(Start,7,2));
 j:=1900+j;

 STr(j:CLitrMantissa+1,ws);
 s:=s+ws+'│';

 Str(Itogo:CIZena+1:CMantissa,ws);
 s:=s+ws+'│';

 Str(ItogoSkidka:CIZena+1:CMantissa,ws);
 s:=s+ws+'│';


 Str(ItogoDoc:CLitrMantissa+1,ws);
 s:=s+ws;

 Oborotlist^.List^.Insert(NewStr(s));
 Oborotlist^.SetRange(Oborotlist^.List^.Count);

 Dispose(Es,Done);
end;


Procedure TAnalysPeriod.Start(ClientKod:ArtikulStr);
Var PrevMonat : String[CArtikul];
    MonatCount:Word;
    Cur,l1,l2 : LongInt;
    ws : AllStr;
    R : TRect;
    Control : PView;
    c : Word;
    s : string[150];
    s1,s2 : String[CIZena+1];

Begin
If Not(PeriodFromAnalys) Then Exit;
l1:=DateStrIngToDate(DateMask,StartDAteA);
l2:=DateStrIngToDate(DateMask,StopDAteA);
AInfo ('Расчитываю обороты клиента...');

{
Dec(l2);
StopDAteA:=DateToDateString(DAteMask,l2);

MonatCount:=1;
PrevMonat:=Copy(StartDateA,4,5);
For Cur:=l1 To l2 Do
 Begin
  ws:=DAteToDAteString(DateMask,Cur);
  ws:=Copy(ws,4,5);
  If ws<>PrevMonat Then
   Begin
    PrevMonat:=ws;
    Inc(MonatCount)
   End;
 End;

If MonatCount=0 Then
 Begin
  MessageBox(^M+#3'Не указано ни одного периода!',Nil,mfError+mfCancelButton);
  Exit;
 End;
}
l1:=DateStrIngToDate(DateMask,StartDAteA);
l2:=DateStrIngToDate(DateMask,StopDAteA);
Dec(l2);
StopDAteA:=DateToDateString(DAteMask,l2);
PrevMonat:=Copy(StartDateA,4,5);

R.Assign(12, 2, 68, 20);
New(AnalysPeriod, Init(R,'Обороты клиента с '+StartDateA+' по '+StopDateA));
StopDAteA:=DateToDateString(DAteMask,l2+1);

AnalysPeriod^.Options := AnalysPeriod^.Options or ofCenterX or ofCenterY;
AnalysPeriod^.HelpCtx :=$E100;

R.Assign(20, 1, 28, 2);
Control := New(PColoredText, Init(R, ' Клиент:', $74));
AnalysPeriod^.Insert(Control);

R.Assign(28, 1, 55, 2);
ws:=GetClientField(FClient,ClientKod,0);
Format(ws,CClient);
ControlClient := New(PColoredText, Init(R, #3+ws+'│'+ClientKod, $1F));
AnalysPeriod^.Insert(ControlClient);

R.Assign(55, 3, 56, 17);
Control := New(PScrollBar, Init(R));
AnalysPeriod^.Insert(Control);

R.Assign(1, 3, 55, 17);
OborotList := New(PBox, Init(R, 1, PScrollbar(Control)));
OborotList^.NewList(New(PMyCollection, Init(0,1)));

s1:=StartDateA;
For Cur:=l1 To l2+1 Do
 Begin
  ws:=DAteToDAteString(DateMask,Cur);
  ws:=Copy(ws,4,5);
  If ws<>PrevMonat Then
   Begin
    s2:=DateToDateString(DateMask,Cur-1);
    {Обработка списка}
    Calcoborot(ClientKod,S1,S2);
    s1:=DateToDateString(DateMask,Cur);
    PrevMonat:=ws;
   End;
 End;


OborotList^.FocusItem(0);
AnalysPeriod^.Insert(OborotList);


s1:='0.00';
s2:='0.00';
If OborotList^.List^.Count>0 Then
 Begin
  For c:=0 To OborotList^.List^.Count-1 Do
   Begin
    s:=Copy(OborotList^.GetText(c,OborotList^.List^.Count),1+9+4+1,CIZena+1);
    Str(StrToReal(s1)+StrToReal(s):CIZena+1:CMantissa,s1);
    s:=Copy(OborotList^.GetText(c,OborotList^.List^.Count),1+9+4+1+CIZena+1+1,CIZena+1);
    Str(StrToReal(s2)+StrToReal(s):CIZena+1:CMantissa,s2);
   End;
 End;
DelSpace(s1);
DelSpace(s2);



  R.Assign(1, 2, 55, 3);
  AnalysPeriod^.Insert(New(PLabel, Init(R, 'Месяц     Год      Отгружено        Скидка       Док.', OborotList)));

R.Assign(1, 17, 11, 18);
Control := New(PColoredText, Init(R, ' E Скидка:', $74));
AnalysPeriod^.Insert(Control);

R.Assign(11, 17, 27, 18);
Control := New(PColoredText, Init(R, #3+s2, $4E));
AnalysPeriod^.Insert(Control);

R.Assign(27, 17, 39, 18);
Control := New(PColoredText, Init(R, ' E Отгрузка:', $74));
AnalysPeriod^.Insert(Control);

R.Assign(39, 17, 55, 18);
Control := New(PColoredText, Init(R, #3+s1, $4E));
AnalysPeriod^.Insert(Control);
NoInfo;
c:=Desktop^.ExecView(AnalysPeriod);

Dispose(Control,Done);
Dispose(AnalysPeriod,Done);
End;{Procedure}

Destructor TAnalysPeriod.Done;
Begin
Dispose(ControlClient,Done);
Dispose(OborotList,Done);
TDialog.Done;
End;

Procedure TAnalysPeriod.PrintReport;
Const Space='                     ';
Var txt : Text;
    p1,p2 : Real;
    s,wp : TMyString;
    SClientKod : ArtikulStr;
    w : LongInt;
    k : Word;
Begin
If (OborotList^.List<>Nil)And(OborotList^.List^.Count>=1) Then
 Begin
  Assign(txt,Path.ToTemp+'monat.txt');
  w:=IOResult;
  Rewrite(Txt);
  w:=IOResult;
  If w <>0 Then
   Begin
    MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'monat.txt',Nil,mfError+mfCancelButton);
    Exit;
   End;
  PStaticText(ControlClient)^.GetText(s);
  System.Delete(s,1,1);
  SClientKod:=Copy(s,1+CClient+1,CClientKod);

  wp:=GetClientField(FClient,SClientKod,0);
  Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1999');
  Writeln(txt,Space+'Без учета агента!!!!');
  Writeln(txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'Обороты клиента '+wp+' ('++SClientKod+')'+^M+
  Space+'               с '+StartDateA+' по '+StopDateA+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);

  p1:=0;
  p2:=0;



  Writeln(txt,Space+'----------------------------------------------------');
  Writeln(txt,Space+'Месяц     Год   Сумма отгрузки     Сумма скидки Док.');
                    {12345678 1234 1234567890123456 1234567890123456 1234}
  Writeln(txt,Space+'----------------------------------------------------');

  For w:=0 To OborotList^.List^.Count-1 Do
  Begin
    s:=Copy(OborotList^.GetText(w,OborotList^.List^.Count),1+9+4+1,CIZena+1);
    p1:=p1+StrToReal(s);
    s:=Copy(OborotList^.GetText(w,OborotList^.List^.Count),1+9+4+1+CIZena+1+1,CIZena+1);
    p2:=p2+StrToReal(s);
    s:=OborotList^.GetText(w,OborotList^.List^.Count);

    While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert(' ',s,k);
    End;
    Writeln (txt,Space+s);
  End;


  Writeln(txt,Space+'----------------------------------------------------');
  Writeln(Txt,Space+'                    Всего отгружено:',
  RecognizReal(p1,CIZena+1,CMantissa));
  Writeln(Txt,Space+'                       Всего скидка:',
  RecognizReal(p2,CIZena+1,CMantissa));

  Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  Writeln(txt,Space+'====================================================');
  System.Close(txt);
  Report(Path.ToTemp+'monat.txt','',1,False,False,false);
 End;
End;{Procedure}


Procedure TAnalysPeriod.HandleEvent(Var Event : TEvent);
Begin
  Case Event.What Of
   EvCommand:
    Case Event.Command Of
    cmReestrReport :Begin
                     PrintReport;
                    End;

    Else;
    End;
  Else;
  End;

  inherited HandleEvent(Event);
  ClearEvent(Event);
End;





Var cur: LongInt;
    Stop : Boolean;
    ws : TDateSTring;

Begin
StartDateA:='01-04-98';
Cur:=DateStringToDate(DateMask,FDate);

Stop:=False;

While Not(Stop) Do
 Begin
  Inc(Cur);
  ws:=DAteToDAteString(DateMask,Cur);
  ws:=Copy(ws,1,2);
  If StrToInt(ws)=1 Then
   Begin
    Stop:=True;
   End;
 End;

StopDAteA:=DateToDateString(DateMask,Cur);

End.