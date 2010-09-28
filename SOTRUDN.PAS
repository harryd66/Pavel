{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit Sotrudn;

INTERFACE

Uses Dialogs,Drivers,Glob,Access,ServStr,LockInfo,MyCalc,Market,Utils
,kassa;

Type
  POplataWindow = ^TOplataWindow;
  TOplataWindow = object(TDialog)
  {  Calc        : PMyCalculator;
    procedure OpenPrintDocWindow(S:TMyString);
    Procedure SaveToFile(Save:Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure CalcItogoDoc(VAr Ih,Is : It);
    Procedure All(R:Word);
    Procedure FreshHint(s:TMyString);
    Destructor Done; virtual;  }
  end;

Type
  PEmplDolgWindow = ^TEmplDolgWindow;
  TEmplDolgWindow = object(TDialog)
    Cl  : PLizoWindow;
    {Sum : PSummaWindow;}
    Opl : PAddOperation;
    LockInfo : PEmplLocalInfoDynamicDebit;
    As: DocumentEdit;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure OpenDolgWindow;
    Procedure OpenDOc;
    Procedure Order;
    Procedure FormReport(Const P:PBox;SCKod:ArtikulStr);
    procedure CalcItogo;
    procedure Refresh(Auto:Boolean);
    procedure FullPreview;
    procedure DrawCurrent;
  end;

Function CalcDolgDebitEmpl(Default:Byte;Regim:Boolean):TMyString;

{процедуры разделение доступа к сотрудникам}
Function SetLizoLock(c:ArtikulStr):Boolean;
Function SetLizoUnLock(c:ArtikulStr):Boolean;
Function WriteLockLizo(ClientElement:ClientType):Boolean;
Function TestEmployLizoAndLock(TestCod:ArtikulStr):Boolean;


IMPLEMENTATION

uses DBEngine,Objects, Views, MsgBox,Protect,{Calc,}TPDate,Tools,Printers,NetCAll,Windos,
     Utilsp,Utils2,MrkTool,Slava,
     App, ColorTxt,Validate,Serv,Nastr,Vision1,Vision5,Net,Stat,NetDbEng;

var
 DolgWindow : PEmplDolgWindow;
 ControlClient,ControlSelectorDoc: PView;
 Prevs,PrevCurrent: string[150];
 DolgList,DynamicList: PBox;
 Doc : WOrd;
 RealFile : File Of DolgKassa;
 GlobalEr : PDolgKassa;

Function SetLizoUnLock(c:ArtikulStr):Boolean;
Var f : File of ClientType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую сотрудника с кодом '+c);
 SetLizoUnLock:=False;

 Assign (F,Path.ToClient+'lizo.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла сотрудников!',nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetLizoUnLock:=True;
  End;
End;



Function WriteLockLizo(ClientElement:ClientType):Boolean;
Var f : File Of ClientType;
    c : LongInt;
    s : ClientType;
Begin
DInfoNetMsg('Сохраняю информацию сотруднике с кодом '+ClientElement.Kod+'...');
WriteLockLizo:=False;
Assign (F,Path.ToClient+'lizo.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла сотрудников!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType)));

{$IFDEF NetVersion}
   ClientElement.Locked:=True;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   WriteLockLizo:=True;
End;



Function TestEmployLizoAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of ClientType;
    c : LongInt;
    s : ClientType;
Begin
DInfoNetMsg('Блокирую сотрудника с кодом '+TestCod);
TestEmployLizoAndLock:=False;
Assign (F,Path.ToClient+'lizo.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла сотрудников!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType)); {предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployLizoAndLock:=True;
      Exit;
End;



Function SetLizoLock(c:ArtikulStr):Boolean;
Var f : File of ClientType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Блокирую сотрудника с кодом '+c);
 SetLizoLock:=False;
 Assign (F,Path.ToClient+'lizo.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла сотрудников!',nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetLizoLock:=True;
      Exit;
  End;
End;



Function CalcDolgDebitEmpl(Default:Byte;Regim:Boolean):TMyString;
Var R : TRect;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    RealFile : File Of DolgKassa;
    ClientList :PBox;
    SortList: PBox;
    E  : PDolgKassa;
    s,w,w1,st : AllStr;
    ws : TMyString;
    ii,c,t1,t2 : LongInt;
    r1,r2 , Rsf,RsfSkid :Real;
    f : Text;
    {DateMask : TDateString;}
    Space : AllStr;
    Tip,Vid,Realno : Word;
    Criminal : Boolean;
    CriminalSumma : Real;
    sDate: string[CDate];
begin
 CalcDolgDebitEmpl:='           0.00            0.00            0.00            0.00';
                {123456789012345 123456789012345 123456789012345 123456789012345}
(* If Regim=True Then
 Begin
 Vid:=SelectSpecify(True,1);
 If Vid=3 Then Exit;
 Tip:=SelectSpecify(True,4);
 If Tip=3 Then Exit;
 Realno:=SelectImport(5);
 If Realno=2 Then Exit;
 End
 Else Begin
       Vid:=Default;
       Tip:=2;
       Realno:=1;
      End;      *)

If Regim Then
Assign(f,Path.ToTemp+'dolgemp.txt')
Else
Assign(f,Path.ToTemp+'dolgiemp.txt');

c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0) And (Regim) Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path.ToTemp+'dolgemp.txt!!',Nil,mfError+mfCancelButton);
  Exit;
 End;
R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0, 0, 0, 0);
SortList := New(PBox, Init(R, 1, Nil));
SortList^.NewList(New(PTextCollection, Init(0,1)));


Assign (ClientFile,Path.ToClient+'Lizo.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c=0 Then
Begin
{If Regim Then AInfo('Рассчитываю долги сотрудников...');}
While Not(Eof(ClientFile)) Do
 Begin
   {
     Repeat
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));
   }
     ReadClient(ClientFile,ClientElement);
   {
     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
   }

  If ClientElement.Employ Then
   Begin
    Format (ClientElement.Name,CClient);
    ClientList^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
    ClientList^.SetRange(ClientList^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  Close(f);
  Dispose(ClientList,Done);
  MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов',Nil,mfError+mfCancelButton);
  Exit;
 End;
Space:='';
r1:=0;r2:=0;
rsf:=0;
rsfSkid:=0;
Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword);
Case Vid Of
2:
Writeln(f,Space+'                 СПРАВКА ПО ДОЛГАМ СОТРУДНИКОВ'+'  '+FDate+' ('+Times+')');
1:
Writeln(f,Space+'             СПРАВКА ПО ПРОСРОЧЕННЫМ ДОЛГАМ СОТРУДНИКОВ'+'  '+FDate+' ('+Times+')');
0:
Writeln(f,Space+'            СПРАВКА ПО НЕ ПРОСРОЧЕННЫМ ДОЛГАМ СОТРУДНИКОВ'+'  '+FDate+' ('+Times+')');
Else;
End;
Write(f,Space+'Вид отбора: ');
Case Tip Of
0:Writeln(f,'"Только с приходниками"');
1:Writeln(f,'"Только без приходников"');
2:Writeln(f,'"Все"');
Else Writeln(f);
End;

Write(f,Space+'Вид долгов: ');
Case Realno Of
1:Writeln(f,'"Теоретичекие"');
0:Writeln(f,'"Реальные по оплате"');
Else Writeln(f);
End;


Writeln(f,Space+'----------------------------------------------------------------------------------------------');
(*If Realno=1 Then
Writeln(f,Space+'       Клиент        Код  Дата Пок  Дата Взв  Delta  N док    Сумма скидки   Сумма долга Т Вид')
Else
Writeln(f,Space+'       Клиент        Код  Дата Пок  Дата Взв  Delta  N док    Сумма скидки  Р долг по опл. Вид');*)
If Realno=1 Then
Writeln(f,Space+'  Сотрудник          Код  Дата      N док  Сумма     Долг     Оператор  ')
Else
Writeln(f,Space+'  Сотрудник          Код  Дата      N док  Сумма     Долг     Оператор  ');
{Writeln(f,Space+'Дата Пок        Клиент        Код   Дата Взв  Delta  N док    Сумма скидки  Р долг по опл. Вид');}

{                 12345678901234567890|1234|12345678| 12345678|       |12345|123456789012345│123456789012345}
Writeln(f,Space+'----------------------------------------------------------------------------------------------');
CriminalSumma:=0;
If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    Criminal:=False;
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);

    s:=GetClientField(FNDogovor,st,0);
    If s[0]=#0 Then
     Criminal:=True;

    Assign(RealFile,Path.ToClient+st+'.dls');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    If ii=0 Then
     Begin
      New(E,Init);
      While Not(Eof(RealFile)) Do
       Begin
        Read(RealFile,E^.Dat);
        If not (E^.Dat.Full) Then
        If StrToInt(GetOperationField(FStatus,E^.DAt.Kod))=0 then
Begin
          MyStr(E^.Dat.SummaDoc,CZena,CMAntissa,w);
          MyStr(E^.Dat.Summa,CZena,CMAntissa,s);
          rformat(w,CZena);
          ws:=GetLizoField(FClient,St);
          Format(ws,CClient);
          DelSpace(E^.DAt.Doc);
          RFormat(E^.DAt.Doc,CDocnumer);
          ws:=ws+' '+St+' '+DateToDateString(DAteMask,E^.Dat.DateC)+'  '
          +E^.Dat.Doc+'  '+w+'  '+s+' '+GetOperatorName(E^.Dat.Caption);
          SortList^.List^.Insert(NewStr(ws));
          SortList^.SetRange(SortList^.List^.Count);
End;{active}
       End;
      Dispose(E,Done);
      Close(RealFile);
     End;
   End;
 End;


if (SortList<>nil) and (SortList^.List^.Count>0) then
for c:=0 to SortList^.List^.Count-1 do
begin
 ws:=SortList^.GetText(c,SortList^.List^.Count);
 Writeln(f,ws);
end;


Dispose(ClientList,Done);
Dispose(SortList,Done);
Writeln(f,Space+'----------------------------------------------------------------------------------------------');
If Tip In [1,2] Then
Begin
Writeln(f,Space+'                                                   Всего долг:'+RecognizReal(R1,CIZena,CMantissa));
Writeln(f,Space+'                                                 Всего скидка:'+RecognizReal(R2,CIZena,CMantissa));
Writeln(f,Space+'                                      Реальный долг по оплате:'+RecognizReal(R1-R2,CIZena,CMantissa));
If CriminalSumma>0.009 Then
Writeln(f,Space+'ВНИМАНИЕ!Обнаружены накладные консигнации без договора   долг:'+RecognizReal(CriminalSumma,CIZena,CMantissa));
End;

If Tip In [0,2] Then
Begin
Writeln(f,Space+'                                               Всего долг СФ:'+RecognizReal(RSf,CIZena,CMantissa));
Writeln(f,Space+'                                             Всего скидка СФ:'+RecognizReal(RsfSkid,CIZena,CMantissa));
Writeln(f,Space+'                                  Реальный долг по оплате СФ:'+RecognizReal(Rsf-RsfSkid,CIZena,CMantissa));
End;

Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'==============================================================================================');
Close(f);
MyStr(R1,CIZena,CMantissa,st);
MyStr(R2,CIZena,CMantissa,ws);
MyStr(Rsf,CIZena,CMantissa,w);
MyStr(RsfSkid,CIZena,CMantissa,w1);
CalcDolgDebitEmpl:=st+' '+ws+' '+w+' '+w1;

If Regim Then
Begin
NoInfo;
ViewAsText(Path.ToTemp+'dolgemp.txt',True);
Report(Path.ToTemp+'dolg.txtemp','',1,False,False,false);
End
end;

procedure TEmplDolgWindow.OpenDolgWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmDolg, nil) = nil then
  begin
    DInfo('Инициализация возврата долга...');
    L:=True;
    DolgWindow := New(PEmplDolgWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(DolgWindow);
    NoInfo;
    End
    Else
     Begin
      TekDate:=FDAte;
      Status:=DocNormal;
      Dispose(DolgWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(DolgWindow) <> Desktop^.TopView then DolgWindow^.Select;
end;

constructor TEmplDolgWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : LongInt;
  p : Real;
  wp : String[cIzena];
  cod : ArtikulStr;
begin

ClearFind;
L:=False;
R.Assign(0, 0, 80, 23);
Inherited Init(R, 'Возврат долга в кассу');
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E002;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    Exit;
   End;

R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'lizo.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(ClientFile)) Do
 Begin
     {
     Repeat
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));
     }

        ReadClient(ClientFile,ClientElement^.Dat);
     {
     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
     }

  If ClientElement^.Dat.Employ Then
   Begin
    Format (ClientElement^.Dat.Name,CClient);
    Client^.List^.Insert(NewStr(ClientElement^.Dat.Name+'│'+ClientElement^.Dat.Kod));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(ClientFile);
{здесь вставить код осуществляющий блокировку ближайшего доступного клиента}

If Not(SetLockNearClient({Client,}0,0,Cod)) Then
  Begin
   Dispose(Client,Done);
   L:=False;
   MessageBox(^M+#3'Не могу заблокировать ни одного клиента!',Nil,mfError+mfCancelButton);
   Exit;
  End;
End
Else
 Begin
  L:=False;
  Dispose(Client,Done);
  Exit;
 End;

PrevS:=Client^.GEtText(Location(Client,Cod,False),Client^.List^.COunt);{фокус должен попасть на заблокированного клиента}
Dispose(Client,Done);

R.Assign(2, 1, 29, 2);
ControlClient := New(PColoredText, Init(R, #3+PrevS, $1F));
ControlClient^.Options := ControlClient^.Options or ofSelectable;
Insert(ControlClient);

R.Assign(2, 0, 15, 1);
Insert(New(PLabel, Init(R, 'Сотрудник:', ControlClient)));

R.Assign(79, 3,80, 15);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 3, 79, 15);
DolgList := New(PBox, Init(R, 1, PScrollbar(Control)));
DolgList^.NewList(New({PText}PMyCollection, Init(0,1)));
PrevS:=Copy(PrevS,1+CClient+1,CClientKod);
DolgList^.FocusItem(0);
DolgList^.HelpCtx:=$E200;


  R.Assign(1, 2, 79, 3);
  Insert(New(PLabel, Init(R, '  N     Дата    Сумма по док.   Долг по оплате Наименов. операции   Оператор', DolgList)));

R.Assign(49, 1, 77, 2);
ControlSelectorDoc := New(PRadioButtons, Init(R,
  NewSItem('О~т~крытые',
  NewSItem('~З~акрытые', Nil))));
{ControlSelectorDoc^.HelpCtx:=$E002;}
ControlSelectorDoc^.SetData(DefaultReal);
Doc:=DefaultReal;
Insert(ControlSelectorDoc);

  R.Assign(30, 1, 49, 2);
  Insert(New(PLabel, Init(R, 'Статус документов:', ControlSelectorDoc)));

Insert(DolgList);


(*R.Assign(4, 17, 32, 21);
ControlRashetDoc := New(PColoredText, Init(R, '  Список - '^M+
     ' Тов.Чек -'^M+
     '     ФЛ* -'^M+
     ' С/Ф Б/Н -', $1F));
ControlRashetDoc^.Options := ControlRashetDoc^.Options or ofFramed;
Insert(ControlRashetDoc);

R.Assign(5, 16, 28, 17);
Control := New(PColoredText, Init(R, ' По документу выведены:', $74));
Insert(Control);

R.Assign(35, 17, 75, 20);
Control := New(PColoredText, Init(R, '', $7F));
Control^.Options := Control^.Options or ofFramed;
Insert(Control);

R.Assign(35, 17, 60, 18);
Control := New(PColoredText, Init(R, 'Итого долг по документ.Т:', $74));
Insert(Control);

R.Assign(60, 17, 75, 18);
ControlDoc := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(ControlDoc);

R.Assign(39, 18, 60, 19);
Control := New(PColoredText, Init(R, 'Итого долг по оплате:', $74));
Insert(Control);

R.Assign(60, 18, 75, 19);
ControlOpl := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(ControlOpl);

R.Assign(35, 19, 60, 20);
Control := New(PColoredText, Init(R, 'Итого скидка консигнации:', $74));
Insert(Control);

R.Assign(60, 19, 75, 20);
ControlRealizSkidki := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(ControlRealizSkidki);

{R.Assign(32, 21, 47, 22);}
R.Assign(3, 15, 16, 16);
Control := New(PColoredText, Init(R, 'Особ.отметки:', $74));
Insert(Control);

{R.Assign(47, 21, 59, 22);}
R.Assign(16, 15, 19, 16);
ControlComment := New(PColoredText, Init(R, 'Нет', $FE));
Insert(ControlComment);


R.Assign(23, 15, 37, 16);
Control := New(PColoredText, Init(R, #3+'Долг по опл.Т:', $74));
Insert(Control);

R.Assign(37, 15, 52, 16);
ControlDolgT := New(PColoredText, Init(R, #3+'0.00', $7E));
Insert(ControlDolgT);

R.Assign(54, 15, 68, 16);
Control := New(PColoredText, Init(R, #3+'Вид документа:', $74));
Insert(Control);

R.Assign(68, 15, 77, 16);
ControlVidDoc := New(PColoredText, Init(R, #3+'???', $7E));
Insert(ControlVidDoc);

R.Assign(34, 21, 44, 22);
Control := New(PColoredText, Init(R, 'Период с:', $74));
Insert(Control);

StartDAte:='01-04-98';
StopDAte:=FDate;

R.Assign(44, 21, 52, 22);
ControlStartDAte := New(PColoredText, Init(R, #3+StartDate, $7E));
Insert(ControlStartDAte);

R.Assign(53, 21, 56, 22);
Control := New(PColoredText, Init(R, 'по:', $74));
Insert(Control);

R.Assign(57, 21, 65, 22);
ControlStopDate := New(PColoredText, Init(R, #3+StopDate, $7E));
Insert(ControlStopDate);

R.Assign(66, 21, 78, 22);
Control := New(PColoredText, Init(R, 'F4-ордер', $74));
Insert(Control);


R.Assign(1, 22, 8, 23);
Control := New(PColoredText, Init(R, ' Агент:', $74));
Insert(Control);

R.Assign(8, 22, 37, 23);
ControlAgent := New(PColoredText, Init(R, #3+'', $1F));
Insert(ControlAgent);


R.Assign(43, 22, 60, 23);
Control := New(PColoredText, Init(R, 'Сегодня оплачено:', $7E));
Insert(Control);

R.Assign(60, 22, 75, 23);
ControlOpl1 := New(PColoredText, Init(R, #3+'0.00', $7E));
Insert(ControlOpl1);   *)


SelectNext(False);
CalcItogo;
L:=True;
end;



procedure TEmplDolgWindow.CalcItogo;
VAr s1,s2,s3 : String[CIZena];
    i : LongInt;
    R1,r2,r3 : Real;
    R : TRect;
Begin
(*R1:=0;
R2:=0;
R3:=0;
s1[0]:=#0;
s2[0]:=#0;
s3[0]:=#0;
If DolgList^.List^.Count-1>=0 Then
 For i:=0 To DolgList^.List^.Count-1 Do
 Begin
  PrevS:=DolgList^.GetText(i,DolgList^.List^.Count);
  s1:=Copy(Prevs,1+1+CDocNumer+1+CDate+1+CDate+1,CIZena);
  s2:=Copy(Prevs,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1,CIZena);
  s3:=Copy(Prevs,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1,CIZena);
  r1:=r1+StrToReal(s1);
  r2:=r2+StrToReal(s2);
  r3:=r3+StrToReal(s3);
 End;
Dispose(ControlDoc,Done);
R.Assign(60, 17, 75, 18);
MyStr(r1,CIZena,CMantissa,s1);
DelSpace(S1);
ControlDoc := New(PColoredText, Init(R, #3+s1, $4E));
Insert(ControlDoc);

Dispose(ControlOpl,Done);
MyStr(r2,CIZena,CMantissa,s2);
DelSpace(S2);
R.Assign(60, 18, 75, 19);
ControlOpl := New(PColoredText, Init(R, #3+s2, $4E));
Insert(ControlOpl);

Dispose(ControlRealizSkidki,Done);
MyStr(r3,CIZena,CMantissa,s3);
DelSpace(S3);
R.Assign(60, 19, 75, 20);
ControlRealizSkidki := New(PColoredText, Init(R, #3+s3, $4E));
Insert(ControlRealizSkidki);*)
End;


Procedure TEmplDolgWindow.DrawCurrent;
Var SClientKod,s1,s : AllStr;
    St : TMyString;
    TempS : string[150];
    R : TRect;
    L : Boolean;
    RealFile: File Of RealizasiaType;
    i : Byte;
    wp,ws : AllStr;
Begin
if (DolgList^.List<>Nil)And(DolgList^.List^.Count>=1) Then
 Begin
  st:=DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count);
  If st <> PrevCurrent Then
    Begin
      PrevCurrent:=St;
     { New(GlobalEr,Init);}
      {If Doc=1 Then
      Begin}
      PStaticText(ControlClient)^.GetText(PrevS);
      System.Delete(PrevS,1,1);
      s1:=PrevS;
      s1:=Copy(s1,1+CClient+1,CClientKod);
      SClientKod:=s1;
      Assign(RealFile,Path.ToClient+s1+'.dls');
      i:=IOResult;
      Reset(RealFile);
      i:=IOResult;
      If i<>0 Then
       Begin
        MessageBox(^M+#3'Ошибка доступа к файлу '+Path.ToClient+s1+'.dls!',Nil,mfError+mfCancelButton);
        Exit;
       End;

       s1:=Copy(PrevCurrent,1+1,CDocNumer);  DelSpace(s1);
{      s1:=Copy(PrevCurrent,1+1+CDate+1,CDocNumer);  DelSpace(s1);}
{      s:=Copy(PrevCurrent,1+1+CDocNumer+1,CDate); DelSpace(s);}
       s:=Copy(PrevCurrent,1+1+CDocNumer+1,CDate); DelSpace(s);

      l:=False;
      DelZerro(s1);

  (*    While Not(Eof(RealFile)) And(Not(l))Do
       Begin
        Read(RealFile,GlobalEr^.Dat); Delspace(GlobalEr^.DAt.MArket.Document);
         DelZerro(GlobalEr^.Dat.Market.Document);
        If (GlobalEr^.DAt.MArket.Document=s1) And
              (GlobalEr^.DAt.MArket.DateC=s) And
                 (GlobalEr^.DAt.MArket.Active) Then l:=True;
       End;
      If Not(l) Then
       Begin
        Dispose(GlobalEr,Done);
        System.Close(RealFile);
        MessageBox(#3^M+#3'Документ N '+s1+''^M+#3'в базе не найден !',Nil,mfError+mfCancelButton);
        Exit;
       End;
   *)
      System.Close(RealFile);

      St[0]:=#0;
   (*   For i:=1 To 4 Do
       Begin
        If Not(GlobalEr^.Dat.Doc[i].Employ) Then
         Begin
          GlobalEr^.Dat.Doc[i].DocReal[0]:=#0;
          GlobalEr^.Dat.Doc[i].DocDate[0]:=#0;
         End;
       End;
      If Doc=1 Then
       Begin
        Dispose(ControlRashetDoc,Done);
        R.Assign(4, 17, 32, 21);
        ControlRashetDoc := New(PColoredText, Init(R,
        '  Список: '+GlobalEr^.Dat.Doc[1].DocReal+'  '+GlobalEr^.Dat.Doc[1].DocDate+^M+
        'Тов.Чек*: '+GlobalEr^.Dat.Doc[2].DocReal+'  '+GlobalEr^.Dat.Doc[2].DocDate+^M+
        '     ФЛ*: '+GlobalEr^.Dat.Doc[3].DocReal+'  '+GlobalEr^.Dat.Doc[3].DocDate+^M+
        '  СФ Б/Н: '+GlobalEr^.Dat.Doc[4].DocReal+'  '+GlobalEr^.Dat.Doc[4].DocDate, $1F));
        ControlRashetDoc^.Options := ControlRashetDoc^.Options or ofFramed;
        Insert(ControlRashetDoc);
       End;{If Doc=1 Then}
      Dispose(ControlComment,Done);
      {R.Assign(47, 21, 59, 22);}
      R.Assign(16, 15, 19, 16);
      If {GlobalEr^.Dat.Sf}GlobalEr^.Dat.Market.DocSelector in [6,8] Then
         ControlComment := New(PColoredText, Init(R, #3+'СФ', $FE))
      Else ControlComment := New(PColoredText, Init(R, #3+'Нет', $FE));
      Insert(ControlComment);


    MyStr(GlobalEr^.Dat.Dolg,CIZena,CMantissa,ws);
    MyStr(StrToReal(GlobalEr^.Dat.Market.Skidka),CIZena,CMantissa,Wp);

    MyStr(StrToReal(Wp)+GlobalEr^.Dat.Dolg,CIZena,CMantissa,wp);
    DelSpace(wp);

    Dispose(ControlDolgT,Done);
    R.Assign(37, 15, 52, 16);
    ControlDolgT := New(PColoredText, Init(R, #3+wp, $7E));
    Insert(ControlDolgT);

    Dispose(ControlVidDoc,Done);
    R.Assign(68, 15, 77, 16);
    Case GlobalEr^.Dat.Market.DocSelector Of
    5:wp:='Дебит*';
    6:wp:='Дебит СФ*';
    7:wp:='Дебит';
    8:wp:='Дебит СФБ';
    Else;
    End;
    ControlVidDoc := New(PColoredText, Init(R, #3+wp, $7E));
    Insert(ControlVidDoc);

    Dispose(ControlAgent,Done);
    R.Assign(8, 22, 37, 23);
    TempS:=GlobalEr^.Dat.Market.AgentKod;
    TempS:=GetAgentField(FClient,TempS);
    DelSpaceRight(TempS);
    Format(TempS,CClient);
    ControlAgent := New(PColoredText, Init(R, #3+TempS+' ('+
    GlobalEr^.Dat.Market.AgentKod+')', $1F));
    Insert(ControlAgent);


    Dispose(GlobalEr,Done);
    Redraw;  *)

    End {If St<>PrevCurrent}
 End

Else
 Begin
 (* Dispose(ControlRashetDoc,Done);
  R.Assign(4, 17, 32, 21);
  ControlRashetDoc := New(PColoredText, Init(R, '   Список: '^M+
      'Тов.Чек*: '^M+
      '     ФЛ*: '^M+
      '  СФ Б/Н: ', $77));
  ControlRashetDoc^.Options := ControlRashetDoc^.Options or ofFramed;
  Insert(ControlRashetDoc);

  Dispose(ControlComment,Done);
  {R.Assign(47, 21, 59, 22);}
  R.Assign(16, 15, 19, 16);
  ControlComment := New(PColoredText, Init(R, 'Нет', $FE));
  Insert(ControlComment);

  Dispose(ControlDolgT,Done);
  R.Assign(37, 15, 52, 16);
  ControlDolgT := New(PColoredText, Init(R, #3+'0.00', $7E));
  Insert(ControlDolgT);

    Dispose(ControlVidDoc,Done);
    R.Assign(68, 15, 77, 16);
    ControlVidDoc := New(PColoredText, Init(R, #3+'???', $7E));
    Insert(ControlVidDoc);

    PStaticText(ControlAgent)^.GetText(TempS);
    System.Delete(TempS,Pos(#3,TempS),1);
    If TempS<>'???' Then
    Begin
    Dispose(ControlAgent,Done);
    R.Assign(8, 22, 37, 23);
    ControlAgent := New(PColoredText, Init(R, #3+'???', $1F));
    Insert(ControlAgent);
    End; *)



  Redraw;
End;
End;



Procedure TEmplDolgWindow.Refresh(Auto:Boolean);
Var r1 : TRect;
    r,Test : LongInt;
    P : Real;
    ReturnSkidka,Wp : String[CIZena];
    Delta : String[CLitrMantissa];
    vidDoc: String[COne];
    SSum,sSumDoc : AllStr;
    StartDate,StopDate:string[CDate];
Begin
ClearFind;
DolgList^.NewList(Nil);
DolgList^.NewList(New({PText}PMyCollection, Init(0,1)));
PStaticText(ControlClient)^.GetText(PrevS);

System.Delete(PrevS,1,1);
Kassa.PrevS:=PrevS;

If Auto Then
Begin
 StartDate:='01-04-98';
 StopDate:=FDate;
End;

SSum[0]:=#0;


PrevS:=Copy(PrevS,1+CClient+1,CClientKod);
Assign (RealFile,Path.ToClient+PrevS+'.dls');
Test:=IOResult;
Reset (RealFile);
Test:=IOResult;

If Test=0 Then
Begin
DInfo('Читаю долги клиента...');
New(GlobalEr,Init);
While Not(Eof(RealFile)) Do
Begin

  Read(RealFile,GlobalEr^.DAt);

if StrToInt(GetOperationField(FStatus,GlobalEr^.DAt.Kod))=0 then
If ((not GlobalEr^.DAt.Full) and (Doc=0)) or
   (( GlobalEr^.DAt.Full) and (Doc=1))
    Then
Begin

(*If (GlobalER^.Dat.DateC <=
   DateStringToDate(DateMask,StopDate)) And
  (GlobalER^.Dat.DateC >=
   DateStringToDate(DateMask,StartDate)) Then *)
Begin

    RFormatZerro(GlobalEr^.Dat.Doc,CDocNumer);

{   Format (E^.Dat.Market.SummaZ,CIZena);}
    p:=GlobalEr^.Dat.Summa;

    MyStr(GlobalEr^.DAt.Summa,CIZena,CMantissa,SSum);
    MyStr(GlobalEr^.DAt.SummaDoc,CIZena,CMantissa,SSumDoc);
    DolgList^.List^.Insert(NewStr('│'+GlobalEr^.Dat.Doc+'│'+DateToDateString(DateMAsk,GlobalEr^.Dat.DateC)+
    +'│'+ssumDoc+'│'+ssum+'│'+GetOperationField(FNAme,GlobalEr^.Dat.Kod)+'│'+GetOperatorName(GlobalEr^.Dat.Caption)));

    DolgList^.SetRange(DolgList^.List^.Count);
End;
End;
End;
Dispose(GlobalEr,Done);
System.Close(RealFile);
NoInfo;

end;
DolgList^.FocusItem(0);
DolgList^.HelpCtx:=$E200;

(*Dispose(ControlStartDate,Done);
R1.Assign(44, 21, 52, 22);
ControlStartDAte := New(PColoredText, Init(R1, #3+StartDate, $7E));
Insert(ControlStartDAte);

Dispose(ControlStopDate,Done);
R1.Assign(57, 21, 65, 22);
ControlStopDate := New(PColoredText, Init(R1, #3+StopDate, $7E));
Insert(ControlStopDate);


MyStr(StrToReal(SSum),CIZena,CMantissa,SSum);
DelSpace(SSum);

Dispose(ControlOpl1,Done);
R1.Assign(60, 22, 75, 23);
ControlOpl1 := New(PColoredText, Init(R1, #3+SSum, $5E));
Insert(ControlOpl1);

CalcItogo;          *)
PrevCurrent[0]:=#0;
End;

Procedure TEmplDolgWindow.Order;
var SDoc:String[CDocNumer];
    SDAte : TDateString;
    SClient : String[CClient+7];
    S : TMyString;
Begin
(*   PStaticText(ControlClient)^.GetText(S);
   SClient:=Copy(s,2,CClient);
   SClient:=SClient+'('+Copy(s,1+CClient+1+1,CCLientKod)+')';
   s:=DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count-1);
   SDoc:=Copy(s,1+1,CDocNumer);
   SDate:=Copy(s,1+1+CDocNumer+1,CDate);
   DelSpace(SDate);
   PrintOrder3('по документу N ',SClient,SDoc,sDate,'1','0'); *)
End;

{проверена}
Procedure TEmplDolgWindow.OpenDOc;
Var
    S : TMyString;
    {E,}EE : PSuperMarketType;
    ER : PRealizasiaType;
    SDoc:String[CDocNumer];
    SDAte : TDateString;
    SClient : String[CClientKod];
    fr : File Of RealizasiaType;
    Find : Boolean;
    my,k,i : Word;
Begin
(*ClearFind;
DInfo('Открываю документ...');
PStaticText(ControlClient)^.GetText(S);
System.Delete(S,1,1);
SClient:=Copy(s,1+CClient+1,CCLientKod);
DelSpace(SClient);

s:=DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count-1);
SDoc:=Copy(s,1+1,CDocNumer);

DelSpace(SDoc);
SDate:=Copy(s,1+1+CDocNumer+1,CDate);
DelSpace(SDate);

Assign(fr,Path.ToDolg+SClient+'.dlg');
i:=IOResult;
Reset(fr);
i:=IOResult;
If i<>0 Then
 Begin
  NoInfo;
  MessageBox(^M+#3'Не найден файл задолженности клиента '+SClient,Nil,mfError+mfCancelButton);
  Exit;
 End;
Find := False;

{ищем исходный документ реализации в файле задолженности}
New(Er,Init);
DelZerro(SDoc);

While Not(Eof(fr)) And Not(Find) Do
 Begin
  Read(fr,Er^.Dat);
  DelSpace(Er^.Dat.Market.Document);
  DelZerro(Er^.Dat.Market.Document);
  DelSpace(Er^.Dat.MArket.DateC);
  If (Er^.Dat.Market.Document=SDoc) And
     (Er^.DAt.Market.DateC=SDate) And
        (Er^.DAt.MArket.Active) Then Find := True;
 End;
If Not(Find) Then
   Begin
    NoInfo;
    System.Close(fr);
    Dispose(Er,DOne);
    MessageBox(^M+#3+'Документ консигнации N '+SDoc+' за '+SDate+''^M
    +#3'в долгах клиента не найден!',Nil,mfError+mfCancelButton);
    Exit;
   End;

Find := True;
For i:=1 To 4 Do
 Begin
  If Er^.DAt.Doc[i].Employ Then Find:=TestOpenDate1(Er^.DAt.Doc[i].DocDate);
  If Not(Find) Then Break;
 End;

If Not(Find) Then
 Begin
  NoInfo;
  sDate:=Er^.DAt.Doc[i].DocDate;
  Dispose(Er,Done);
  System.Close(Fr);
  MessageBox(#3^M+#3'Нет доступа к данным за '+SDate+''^M+
  #3'Документ не был открыт!',Nil,mfError+mfCancelButton);
  Exit;
 End;

s:='Открытие документа консигнации:'+Er^.Dat.Market.Document+' от '+
Er^.Dat.Market.DateC+^M+'Аннулирование следующих документов: ';

For i:=1 To 4 Do
 Begin
  If Er^.DAt.Doc[i].Employ Then
   Begin

    Sdoc:=Er^.DAt.Doc[i].DocReal;
    DelSpace(SDoc);
    Sdate:=Er^.DAt.Doc[i].DocDate;
    DelSpace(SDate);
    s:=s+' '+SDoc+' от '+SDAte+' ;';
    DelZerro(SDoc);
    If Not(Activ_DeActiv_Market(SDoc,SDate,False)) Then
     Begin
       MessageBox(#3^M+#3'Не могу деактивизировать документ '+SDoc+' от '+SDate+''^M+
       #3'Документ не был открыт!',Nil,mfError+mfCancelButton);
       If i>1 Then
         For my:=i-1 Downto 1 Do
          Begin
           Sdoc:=Er^.DAt.Doc[my].DocReal;
           DelSpace(SDoc);
           Sdate:=Er^.DAt.Doc[my].DocDate;
           DelSpace(SDate);
           s:=s+' '+SDoc+' от '+SDAte+' ;';
           DelZerro(SDoc);
           Repeat
           Until (Activ_DeActiv_Market(SDoc,SDate,True));
          End;
       Dispose(Er,Done);
       System.Close(Fr);
       Exit;
     End;
   End;{If}
 End;{For}

 For i:=1 To 4 Do
  Begin
   Er^.DAt.Doc[i].Employ:=False;
   Er^.DAt.Doc[i].DocReal[0]:=#0;
   Er^.DAt.Doc[i].DocDate[0]:=#0;
  End;

   Er^.DAt.Full:=False;

   Seek(fr,FilePos(fr)-1);
   Write(fr,er^.dat);
   Dispose(Er,Done);
   System.Close(fr);

AddProtocol(s,'','');
NoInfo;
Refresh(False); *)
End;

procedure TEmplDolgWindow.FullPreview;
Var Ass : DocumentEdit;
    E : PSuperMarketType;
    R : TRect;
    f : MarketFileType;
    c : Word;
    P : PBox;
    s,ws : TMyString;
    Find : Boolean;
    SDoc : ArtikulStr;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];

Begin
(*If (DolgList^.List<>Nil)And(DolgList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count),1+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  Ass.D:=Copy(DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count),1+1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  ViewMrk^.FullScreenMrk(Ass);
End; *)
End;


procedure TEmplDolgWindow.FormReport(Const P : PBox;SCKod:ArtikulStr);
Const Space='  ';
Var f : text;
    ws,s,s1,s2 : string[150];
    c,w : Word;
    Find : Boolean;
Begin
(*If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path.ToTemp+'dolgrep.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'Не могу создать файл '+Path.ToTemp+'dolgrep.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(f);

 ControlSelectorDoc^.GetData(W);

 AInfo('Минуточку...');

 Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1999');

 s:=GetClientField(FClient,SCKod,0);
 DelSpaceRight(s);
 If W=0 Then
 Writeln(f,Space+'СПРАВКА ПО НЕ ОПЛАЧЕННЫМ ДОКУМЕНТАМ КОНСИГНАЦИИ КЛИЕНТА '+s+'('+SCKod+')')
 Else
 Writeln(f,Space+'СПРАВКА ПО ОПЛАЧЕННЫМ ДОКУМЕНТАМ КОНСИГНАЦИИ КЛИЕНТА '+s+'('+SCKod+')');
 Writeln(f,Space+'Документы выданы за период с:'+StartDAte+' по '+StopDAte);
 Writeln(f,Space+'-------------------------------------------------------------------------------------');
 Writeln(f,Space+'Док  Дата док Срок опл Долг по докум.Т  Долг по оплате Скидка по докум Del   Вид');

                 {1234│12345678│12345678│123456789012345│123456789012345│123456789012345│123│Дебит СФ Б'}
 Writeln(f,Space+'-------------------------------------------------------------------------------------');


 {
      New(GlobalEr,Init);
      Assign(RealFile,Path.ToDolg+sCKod+'.dlg');
      c:=IOResult;
      Reset(RealFile);
      c:=IOResult;
      If c<>0 Then
       Begin
        Dispose(GlobalEr,Done);
        System.Close(f);
        NoInfo;
        MessageBox(^M+#3'Ошибка доступа к файлу '+Path.ToDolg+sCKod+'.dlg!',Nil,mfError+mfCancelButton);
        Exit;
       End;
}
 For c:=0 To P^.List^.Count-1 Do
  Begin
   s := P^.GetText(c,P^.List^.Count);

   While Pos('│',s)>0 Do
    Begin
     w:=Pos('│',s);
     System.Delete(s,w,1);
     System.Insert(' ',s,w);
    End;

   s1:=Copy(P^.GetText(c,P^.List^.Count),1+1,CDocNumer);
   DelSpace(s1);
   s2:=Copy(P^.GetText(c,P^.List^.Count),1+1+CDocNumer+1,CDate);
   DelSpace(s2);
   DelZerro(s1);
   s1:=Copy(s,1+CDocNumer+1+CDate+1+CDAte+1+CIZena+1+CIZena+1+CIZena+1+CLitrMantissa+1
         +1,COne);
   s[0]:=Chr(1+CDocNumer+1+CDate+1+CDAte+1+CIZena+1+CIZena+1+CIZena+1+CLitrMantissa+1);

   Case StrToInt(s1) Of
   5:s1:='Дебит*';
   6:s1:='Дебит СФ*';
   7:s1:='Дебит';
   8:s1:='Дебит СФБ';
   Else s1:='???';
   End;

(  s:=s+' '+s1;

   System.Delete(s,1,1);

   Writeln(f,Space+s);
  End;

 Writeln(f,Space+'-------------------------------------------------------------------------------------');


PStaticText(ControlDoc)^.GetText(S);
System.Delete(S,1,1);
Writeln(f,Space+'                         Всего долг по документам (Т): '+RecognizReal(StrToReal(s),CIZena,CMantissa));

PStaticText(ControlOpl)^.GetText(S);
System.Delete(S,1,1);
Writeln(f,Space+'                                 Всего долг по оплате: '+RecognizReal(StrToReal(s),CIZena,CMantissa));

PStaticText(ControlRealizSkidki)^.GetText(S);
System.Delete(S,1,1);
Writeln(f,Space+'                             Всего скидка консигнации: '+RecognizReal(StrToReal(s),CIZena,CMantissa));


 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'=========================================================');
 System.Close(f);
 NoInfo;
 ViewAsText(Path.ToTemp+'Dolgrep.txt',True);
 Report(Path.ToTemp+'Dolgrep.txt','',1,False,False,false);
 End; *)
End;





procedure TEmplDolgWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s : TMyString;
    l : Boolean;
    R : Real;
    b : Byte;
    BnLogik : Boolean;
    Bn : BezNal;
    SClientKod,SDoc,ClKod : ArtikulStr;
    Assistent : DocumentEdit;
    SDate : TDateString;
begin
  Case Event.What Of
 (* evKeyDown:
  Begin
        CAse Event.KeyCode Of
               kbDel      :Begin
               ClearFind;
               If (DolgList^.State and sfFocused<>0) Then
               Begin
                            If StrToInt(CurrentPassword)=0 Then
					    Begin
                If MessageBox(^M+#3'Вы уверены, что хотите удалить эту запись?',Nil,
			   mfWarning+mfConfirmation+mfOkCancel)=cmOk Then
                 Begin
                  PStaticText(ControlClient)^.GetText(S);
                  System.Delete(S,1,1);
                  ClKod:=Copy(s,1+CClient+1,CClientKod);
                  Assistent.EditPosition:=Copy(DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count),1+1,CDocNumer);
                  DelSpace(Assistent.EditPosition);
                  DelZerro(Assistent.EditPosition);
                  Assistent.D:=Copy(DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count),1+1+CDocNumer+1,CDAte);
                  DelSpace(Assistent.D);
     	        DelDolgNakl(ClKod,Assistent);
                  Refresh(False);
                 End;
                             End;
               End;
                           End;{kbDel}
               kbF4      :Begin
               If (DolgList^.State and sfFocused <> 0) And (DolgList^.List<>Nil)And(DolgList^.List^.Count>=1) Then
                   Order;
                  End;
       Else;
       End;
 End; *)

  evCommand :

        Case Event.Command Of

                    cmAbout: Begin
                      AboutChm('33');
                      ClearEvent(Event);
                    End;

                   cmOplata :{ if (User[67] or (CurrentPassword='00')) then}
                   If (DolgList^.State and sfFocused<>0) Then
			    Begin
                     As.EditPosition:=Copy(DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count),1+1,CDocNumer);
                     As.D:=Copy(DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count),1+1+CDocNumer+1,CDAte);
                     OpL^.Start(true,AS);
                     Refresh(false);
                     Redraw;
               (*  Begin
                                    ClearFind;
                                    If (DolgList^.State and sfFocused<>0) Then
                                        Begin
                                        ClearEvent(Event);
                                        s:=DolgList^.GetText(DolgList^.Focused,DolgList^.List^.COunt);
                                        R:=Sum^.Ini(s,b,BnLogik,BN);
                         If b in [0,1] Then
                         Begin
                          l:=True;
                          If b=0 Then l:=CalcNewDolg(R,S,BnLogik,Bn);
                          If L Then
                           Begin
                            Opl^.OpenPrintDocWindow(S);
                           End;
                         Refresh(False);
                         {DrawCurrent;}
                         Redraw;
                         End;
                        End;
                  End;         *)
                                    ClearEvent(Event);
                       End;{kbEnter}
         cmCancel : Begin
                 {Dispose(ControlSelectorDoc,Done);
                 Dispose(ControlClient,Done);
                 Dispose(DolgList,Done);   }
                 PStaticText(ControlClient)^.GetText(S);
                 System.Delete(S,1,1);
                 Repeat
                 Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,0));

             (*    Dispose(TChekRazdel,Done);
                 Dispose(FZRazdel,Done);
                 Dispose(SpisokRazdel,Done);
                 Dispose(SfRazdel,Done);
                 Dispose(SFBRazdel,Done);  *)
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 EnableCommands([cmFullview])
{                PutEvent(Event);
                 Status:=DocNormal;
                 ClearEvent(Event);}
                End;
  cmPrintReestr:    Begin
                 ClearFind;
     If (DolgList^.State and sfFocused <> 0) And (DolgList^.List<>Nil)And(DolgList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count),1+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count),1+1+CDocNumer+1,CDAte);
                DelSpace(Assistent.D);
                {PrintNaklSklad(Assistent,NPrint.CopyNkl);}
                PrintNakl(Assistent,NPrint.CopyNkl);
            End
            End;

 (*cmChangeDiapason :
        Begin
          If (Period(StartDate,StopDate)) Then Refresh(False);
          ClearEvent(Event);
        End; *)


(* cmReestrReport:
            Begin
             ClearFind;
     If (DolgList^.State and sfFocused <> 0) And (DolgList^.List<>Nil)And(DolgList^.List^.Count>=1) Then
              Begin
               PStaticText(ControlClient)^.GetText(S);
               System.Delete(S,1,1);
               sClientKod:=Copy(s,1+CClient+1,CClientKod);
               If Password(3) Then
			 Begin
			  FormReport(DolgList,SClientKod);
                 AddProtocol('Печать хронологии долгов клиента ('+SClientKod+') {Возможна утечка информации}','','');
                End;
              End
            End;        *)


     cmLocalInfo: Begin
     If (DolgList^.State and sfFocused <> 0) And (DolgList^.List<>Nil)And(DolgList^.List^.Count>=1) Then
            Begin
                 PStaticText(ControlClient)^.GetText(S);
                 System.Delete(S,1,1);
                 sClientKod:=Copy(s,1+CClient+1,CClientKod);

                 s:=DolgList^.GetText(DolgList^.Focused,DolgList^.List^.COunt);
                 LockInfo^.LockStart(s,SClientKod);
                 PrevCurrent[0]:=#0;
            End;



                 End;

      cmDeblock : if (User[68] or (CurrentPassword='00')) then
	 Begin
     If (DolgList^.State and sfFocused <> 0) And (DolgList^.List<>Nil)And(DolgList^.List^.Count>=1) Then
                   OpenDoc;
                  End;
     cmFullview : Begin
     If (DolgList^.State and sfFocused <> 0) And (DolgList^.List<>Nil)And(DolgList^.List^.Count>=1) Then
              FullPreview;
                  End;

cmSelectClient:
 Begin
  If (PView(Cl)<>Desktop^.TopView)And(ControlClient^.State and sfFocused <> 0) Then
  Begin
     ControlClient^.Focus;
     PStaticText(ControlClient)^.GetText(S);
     System.Delete(S,1,1);
     Repeat
     Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,0));
     Cl^.ShowAgentList(s,Test);

     PStaticText(ControlClient)^.Text^:=#3+S;
     PrevS:=S;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
     End;
     Refresh(True);
     PrevCurrent[0]:=#0;
     {DrawCurrent;}
     {Redraw;}
     ClearEvent(Event);
  End
  Else
     ClearEvent(Event);
 End;
      Else;
      End;{evCommand}
      Else;
      End;{*Case*}

  if (Event.What = evBroadcast) and
    (Event.Command = cmDolg) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);

 If (PView(Cl)<>Desktop^.TopView)And(ControlClient^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectClient) And (Event.What <> EvKeyDown)Then
            Begin
             Event.What:=EvCommand;
                   Event.Command:=cmSelectClient;
                   PutEvent(Event);
                   ClearEvent(Event);
                  End;

  inherited HandleEvent(Event);


  If (Desktop^.Current=PView(DolgWindow)) And (Event.What <> EvKeyDown) Then
   Begin

        if (ControlSelectorDoc^.State and sfFocused <> 0)Then
         Begin
          ControlSelectorDoc^.GetData(Test);
          If Test <> Doc Then
           Begin
            Doc:=Test;
            Refresh(False);
            PrevCurrent[0]:=#0;
           End;
         End;


        If Doc=0 Then
        Begin
         DisableCommands([cmDeblock]);
         EnableCommands([cmOplata])
        End
        Else
        Begin
         EnableCommands([cmDeblock]);
         DisableCommands([cmOplata]);
        End;

        DrawCurrent;

  End

end;

BEGIN
END.