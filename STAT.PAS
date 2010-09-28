{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit Stat;


Interface


Uses Dialogs,Drivers,Glob,Access,LockInfo,ServStr,MyCalc,DStat;

Type
  PLocLastWindow = ^TLocLastWindow;
  TLocLastWindow = object(TDialog)
    Procedure Start(Const P:PBox);
    Procedure FormReport;
    procedure DrawCurrent;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;virtual;
  end;


Type
  PStatWindow = ^TStatWindow;
  TStatWindow = object(TDialog)
    Cl  : PClientWindow;
    LockInfo : PLocalInfoDynamicDebit;
    LastInfoZena : PLocLastWindow;
    Analys      : PAnalysPeriod;
    procedure OpenStatWindow;
    procedure CalcItogo;
    procedure Refresh(Auto:Boolean);
    procedure DrawCurrent;
    Procedure FormReport(Spis:PBox);
    Procedure FullPreview;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;


Type{окно подробная раскладка по документам,просмотр документов,
     просмотр оплаты}
  PLocCalcWindow = ^TLocCalcWindow;
  TLocCalcWindow = object(TDialog)
    LockInfo : PLocalInfoDynamicDebit;
    LastInfoZena : PLocLastWindow;
    Calc        : PMyCalculator;
    Analys      : PAnalysPeriod;
    Procedure Start;
    Procedure FormReport(Spis:PBox);
    Procedure FullPreview;
    Procedure DrawCurrent;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;virtual;
  end;


Type {окно результат запроса к БД клиент-сумма}
  PCalcWindow = ^TCalcWindow;
  TCalcWindow = object(TDialog)
    LocCalc : PLocCalcWindow;
    Calc        : PMyCalculator;
    Procedure Start(Var l: Boolean);
    Procedure Refresh;
    Procedure FreshReiting;
    Procedure FormReport(S:PBox);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;virtual;
  end;

Type {главное окно статистики,фильтры документов,оплаты,выбор клиентов}
  PSelectClientWindow = ^TSelectClientWindow;
  TSelectClientWindow = object(TDialog)
    GroupCalcWindow : PCalcWindow;
    procedure OpenSelectClientWindow;
    procedure DrawCurrent;
    procedure AddName;
    Procedure FullPreview;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;



Implementation

uses DBEngine,Objects, Views, MsgBox,Protect,{Calc,}TPDate,Market,Tools,Printers,
     Vision5,Serv,UtilsP,
     App, ColorTxt,Validate,Nastr,Vision1,Vision3,Vision4,NetDbEng,Utils;

var
 StatWindow : PStatWindow;
 ClientStatWindow : PSelectClientWindow;
 CalcWindow :PCalcWindow;
 LocCalcWindow : PLocCalcWindow;
 LocLastWindow :PLocLastWindow;

 SelectClient,SelectAgent,Agent,LocCalcList,LocLastList,CalcList,TempCalcList : PBox;
 StatList: PBox;
 SelectorReport : Byte;



 Reiting,PrevCurrent,PrevCur : string[200];
 LastClientKod : ArtikulStr;
 Prevs: TEnjoyStr;
 {Метки в окне последних цен}
 SControlAgent,
 SControlDocNumer,
 SControlDocDate,
 SControlDocTime,
 SControlDocOperator,

 sControlRashet,
 sControlSkidka,
 sControlVidDoc,
 sControl,
 sControlClient,
 sControlDocFiltr,
 sControlOplataFiltr,
 sControlDatePP,
 sControlSummaPP,
 sControlNPP,
 sControlBank,
 sControlStartDate,
 sControlStopDate,
 sControlStatus,
 sControlItogo,
 sControlItogoSkidka,
 sControlDoc,
 sControlTimeM,
 SControlDop,
 SControlPos,
 SControlSort,
 SControlVidSort,
 SControlReiting: PView;

 Ws : String[CIZena];
 PrevPosition : TMyString;
 mm : Maska9;
 ss : Maska2;
 StopDate ,StartDate ,StopDateA ,StartDateA : TDateString;
 VidSorting,Sorting,Filtr,Oplata : Word;
 AllSumma,AllSummaOtgr,AllSkidka : String[CIZena+5];






Function Period:Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control,ControlStart,ControlStop : PView;
  C : Word;
  l : LongInt;
  s1,s2 : TDateString;

begin
Period :=False;
s1:=StartDate;
s2:=StopDate;

1:
R.Assign(23, 9, 57, 14);
New(Dlg, Init(R, 'Укажите период поиска'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E011;
Dlg^.Palette := dpCyanDialog;

R.Assign(6, 2, 16, 3);
ControlStart := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStart);
  PInputLine(ControlStart)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DAteFiltr, True));

ControlStart^.SetData(s1);

  R.Assign(3, 2, 6, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~с~:', ControlStart)));

R.Assign(20, 2, 30, 3);
ControlStop := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStop);
  PInputLine(ControlStop)^.Validator := New(PPXPictureValidator, Init(DAteFiltr{'[##-##-9#]'}, True));

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

   StartDate:=s1;
   StopDate:=s2;
   Period:=True;

   {если даты перепутаны переставляем их}
   If DateStringToDate(DateMask,StopDate)<DateStringToDate(DateMask,StartDate) Then
    Begin
        s1:=StopDate;
        StopDate:=StartDate;
        StartDate:=s1;
    End;
 End
 Else
  Begin
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);
  End;
end;




procedure TStatWindow.OpenStatWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmStat, nil) = nil then
  begin

    DInfo('Инициализация анализа...');
    L:=True;
    StatWindow := New(PStatWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(StatWindow);
    NoInfo;
    End
    Else
        Begin
         Status:=DocNormal;
      Dispose(StatWindow,Done);
         NoInfo;
        End;
  end
  else
    if PView(StatWindow) <> Desktop^.TopView then StatWindow^.Select;
end;

constructor TStatWindow.Init(Var l : Boolean);
Var R : TRect;
    i : Word;
Begin
L:=False;
R.Assign(0, 0, 80, 23);
inherited Init(R, '');
TekDate:=FDate;
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E581;

R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'Client.db');
i:=IOResult;
Reset (ClientFile);
I:=IOResult;
If i=0 Then
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
End;
Client^.FocusItem(1);
Client^.HelpCtx:=$E001;
PrevPosition:=Client^.GEtText(Client^.Focused,Client^.List^.COunt);
Dispose(Client,Done);

R.Assign(52, 0, 79, 1);
sControlClient := New(PColoredText, Init(R, #3+PrevPosition, $1F));
sControlClient^.Options := sControlClient^.Options or ofSelectable;
Insert(sControlClient);

  R.Assign(44, 0, 52, 1);
  Insert(New(PLabel, Init(R, 'Кл~и~ент:', sControlClient)));



R.Assign(1, 1, 50, 3);
sControlDocFiltr := New(PCheckboxes, Init(R,
  NewSItem('С~п~',
  NewSItem('~Т~Ч*',
  NewSItem('ФЛ*',
  NewSItem('~С~Ф*',
  NewSItem('СФ',
  NewSItem('Д~*~',
  NewSItem('Д С~Ф~*',
  NewSItem('~Д~',
  NewSItem('Д СФ', Nil)))))))))));
Insert(sControlDocFiltr);

{Insert(sControlDocFiltr);}


i:=511;
sControlDocFiltr^.SetData(i);

  R.Assign(1, 0, 15, 1);
  Insert(New(PLabel, Init(R, 'Виды док-тов:', sControlDocFiltr)));

R.Assign(51, 2, 79, 3);
sControlOplataFiltr := New(PCheckboxes, Init(R,
  NewSItem('~О~плачен',
  NewSItem('~Н~е оплачен', Nil))));
Insert(sControlOplataFiltr);

i:=3;
sControlOplataFiltr^.SetData(i);


R.Assign(79, 4, 80, 18);
sControl := New(PScrollBar, Init(R));
Insert(sControl);

R.Assign(1, 4, 79, 18);
StatList := New(PBox, Init(R, 1, PScrollbar(sControl)));
StatList^.NewList(New(PMyCollection, Init(0,1)));
StatList^.HelpCtx:=$E570;
Insert(StatList);
StatList^.FocusItem(0);

  R.Assign(2, 3, 79, 4);
  Insert(New(PLabel, Init(R, ' N    Дата    Время    Сумма к оплате      Скидка       Оператор    Дата изм', StatList)));

R.Assign(33, 18, 60, 19);
SControlAgent := New(PColoredText, Init(R, #3+'???', $7E));
Insert(SControlAgent);

R.Assign(24, 18, 33, 19);
sControl := New(PColoredText, Init(R, 'Доставка:', $71));
Insert(sControl);

R.Assign(2, 19, 9, 20);
SControl := New(PColoredText, Init(R, 'Расчет:', $71));
Insert(sControl);

R.Assign(9, 19, 12, 20);
SControlRashet := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlRashet);

R.Assign(14, 19, 25, 20);
sControl := New(PColoredText, Init(R, 'Вид док-та:', $71));
Insert(sControl);

R.Assign(25, 19, 34, 20);
sControlVidDoc := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlVidDoc);

R.Assign(36, 19, 43, 20);
sControl := New(PColoredText, Init(R, 'Скидка:', $71));
Insert(sControl);

R.Assign(43, 19, 49, 20);
sControlSkidka := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlSkidka);

R.Assign(2, 20, 29, 21);
sControl := New(PColoredText, Init(R, 'Время последнего изменения:', $71));
Insert(sControl);

R.Assign(29, 20, 37, 21);
sControlTimeM := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlTimeM);

R.Assign(9, 21, 18, 22);
sControl := New(PColoredText, Init(R, 'Дата п/п:', $74));
Insert(sControl);

R.Assign(18, 21, 26, 22);
sControlDatePP := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlDatePP);

R.Assign(39, 20, 44, 21);
sControl := New(PColoredText, Init(R, 'Банк:', $74));
Insert(sControl);

R.Assign(44, 20, 79, 21);
sControlBank := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlBank);

R.Assign(29, 21, 35, 22);
sControl := New(PColoredText, Init(R, 'N п/п:', $74));
Insert(sControl);

R.Assign(35, 21, 45, 22);
sControlNPP := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlNPP);

R.Assign(48, 21, 58, 22);
sControl := New(PColoredText, Init(R, 'Сумма п/п:', $74));
Insert(sControl);

R.Assign(58, 21, 73, 22);
sControlSummaPP := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlSummaPP);

R.Assign(51, 1, 59, 2);
sControl := New(PColoredText, Init(R, 'Период:', $74));
Insert(sControl);

R.Assign(59, 1, 67, 2);
sControlStartDAte := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlStartDAte);

R.Assign(68, 1, 70, 2);
sControl := New(PColoredText, Init(R, 'по', $74));
Insert(sControl);

R.Assign(71, 1, 79, 2);
sControlStopDate := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlStopDate);

R.Assign(51, 19, 68, 20);
sControl := New(PColoredText, Init(R, 'Статус документа:', $71));
Insert(sControl);

R.Assign(68, 19, 79, 20);
sControlStatus := New(PColoredText, Init(R, #3+'???', $FE));
Insert(sControlStatus);


R.Assign(16, 0, 42, 1);
sControl:= New(PColoredText, Init(R, 'Анализ работы с клиентом', $4F));
Insert(sControl);



R.Assign(47, 22, 63, 23);
sControl := New(PColoredText, Init(R, ' Итого к оплате:', $74));
Insert(sControl);

R.Assign(63, 22, 79, 23);
sControlItogo := New(PColoredText, Init(R, #3+'???', $4E));
Insert(sControlItogo);

R.Assign(17, 22, 31, 23);
sControl := New(PColoredText, Init(R, ' Итого скидка:', $74));
Insert(sControl);

R.Assign(31, 22, 47, 23);
sControlItogoSkidka := New(PColoredText, Init(R, #3+'???', $4E));
Insert(sControlItogoSkidka);

R.Assign(1, 22, 12, 23);
sControl := New(PColoredText, Init(R, 'Документов:', $74));
Insert(sControl);

R.Assign(12, 22, 17, 23);
sControlDoc := New(PColoredText, Init(R, #3+'???', $4E));
Insert(sControlDoc);


SelectNext(False);
Filtr:=511;
Oplata:=3;
Refresh(True);
CalcItogo;
PrevCurrent[0]:=#0;
L:=True;
End;



procedure TStatWindow.CalcItogo;

Var R : TRect;
    R1,R2 : Real;
    s1,s2 :String[CIZena+1];
    i : Word;
    r3: Word;
Begin
r1:=0;
r2:=0;
If StatList^.List^.Count-1>=0 Then
 For i:=0 To StatList^.List^.Count-1 Do
 Begin
  PrevS:=StatList^.GetText(i,StatList^.List^.Count);
  s1:=Copy(PrevS,1+1+CDocNumer+1+CDate+1+CDate+1,CIZena);
  s2:=Copy(PrevS,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1,CIZena);
  r1:=r1+StrToReal(s1);
  r2:=r2+StrToReal(s2);
 End;

Dispose(sControlItogo,Done);
R.Assign(63, 22, 79, 23);
Str(r1:CIZena+1:CMantissa,s1);
DelSpace(S1);
sControlItogo := New(PColoredText, Init(R, #3+s1, $4E));
Insert(sControlItogo);

Dispose(sControlItogoSkidka,Done);
Str(r2:CIZena+1:CMantissa,s2);
DelSpace(S2);
R.Assign(31, 22, 47, 23);
sControlItogoSkidka := New(PColoredText, Init(R, #3+s2, $4E));
Insert(sControlItogoSkidka);

Dispose(sControlDoc,Done);
R.Assign(12, 22, 17, 23);
Str(StatList^.List^.Count:4,s2);
DelSpace(s2);
sControlDoc := New(PColoredText, Init(R, #3+s2, $4E));
Insert(sControlDoc);
Redraw;
End;


procedure TStatWindow.Refresh(Auto:Boolean);
Var R : TRect;
    Es : PStatClientType;
    Esf : File Of StatClientType;
         s : string;
         ws : ALLStr;
ClientKod: ArtikulStr;
         j,Res : Word;
         Cur,Min,Max : LongInt;
          Er : PRealizasiaType;
          Ef : File Of RealizasiaType;
          Find : Boolean;

Begin
  ClearFind;
 StatList^.NewList(nil);
 StatList^.NewList(New(PMyCollection, Init(0,1)));

 WordTobit9(Filtr,mm);
 Convert9(mm);

 WordToBit2(Oplata,ss);
 Convert2(ss);



 PStaticText(sControlClient)^.GetText(S);
 System.Delete(S,1,1);
 ClientKod:=Copy(s,1+CClient+1,CClientKod);


If Auto Then
Begin
Min:=DateStringToDate(DateMask,FDate);
Max:=Min;
End
Else
 Begin
  Min:=DateStringToDate(DateMask,StartDate);
  Max:=DateStringToDate(DateMask,StopDate);
 End;

 Assign(Esf,Path.ToClient+ClientKod+'.his');
 j:=IOResult;
 Reset(Esf);
 j:=IOResult;

 If j=0 Then
Begin
AInfo('Минуточку...');
Cur:=0;
 New(Es,Init);
 If Not (Eof(Esf)) Then
 Begin
 While Not(Eof(Esf)) Do
  Begin
   Read(Esf,Es^.Dat);
   If Es^.Dat.Active Then
Begin
   Cur := DateStringToDate(DateMask,Es^.Dat.DateC);
   If Auto Then
    Begin
        If Cur < Min Then Min:=Cur;

        If Cur > Max Then Max:=Cur;
    End;

   If (Auto) Or (Not(Auto)And(Cur>=Min)And(Cur<=MAx)) Then
   Begin

 (*!!!  If (Es^.Dat.DocSelector in 5) And (Es^.Dat.Sf) Then Inc(Es^.Dat.DocSelector);{Дебит С/Ф}*)

   If mm[Es^.Dat.DocSelector+1]=1 Then{фильтр документов}
    Begin
        RFormatZerro(Es^.Dat.Document,CDocNumer);
        Str(StrToReal(Es^.Dat.SummaZ):CIZena:CMantissa,Es^.Dat.SummaZ);
        Str(StrToReal(Es^.Dat.Skidka):CIZena:CMantissa,Es^.Dat.Skidka);
        s:=GetOperatorName(Es^.Dat.Caption);
        Format(s,CKto);
        s:='│'+Es^.Dat.Document+'│'+Es^.Dat.DateC+'│'+Es^.Dat.TimeC+'│'+Es^.Dat.SummaZ+'│'+
        Es^.Dat.Skidka+'│'+s+'│'+Es^.Dat.DateM+'│'+Es^.Dat.TimeM+'│';

        Str(Es^.Dat.DocSelector:1,ws);{вид документа}
        s:=s+ws+'│';

        Str(Es^.Dat.sKIDKASelector:1,ws);{скидка }
        s:=s+ws+'│';


        If Es^.Dat.DocSelector in [4,8] Then ws:='0'{Б/Н}
                                                                Else ws:='1';{нал}
        s:=s+ws+'│';

        DelSpace(Es^.Dat.Bn.Date);
        Format(Es^.Dat.bn.Date,CDate);

        s:=s+Es^.Dat.bn.Date+'│';

        DelSpace(Es^.Dat.Bn.NPlat);
        Format(Es^.Dat.bn.NPlat,10);

        s:=s+Es^.Dat.bn.NPlat+'│';

        DelSpace(Es^.Dat.Bn.Summa);
        Format(Es^.Dat.bn.Summa,CIZena);

        s:=s+Es^.Dat.bn.Summa+'│';

        DelSpaceRight(Es^.Dat.Bn.Bank);
        Format(Es^.Dat.bn.Bank,CAll);

        s:=s+Es^.Dat.bn.Bank+'│';

        If Es^.Dat.DocSelector in [0,1,2,3,4] Then
        Begin
          ws:='1';
        End
        Else
         Begin
          DelZerro(Es^.Dat.Document);
          DelSpace(Es^.Dat.Document);

          Assign(ef,Path.ToDolg+ClientKod+'.dlg');
          Res:=IOResult;
          Reset(Ef);
          Res:=IOResult;
          If Res<>0 Then
           Begin
            MessageBox(^M+#3'Ошибка доступа к файлу долгов клиента ('+CLientKod+')!',Nil,mfError+mfCancelButton);
            ws:='0';
           End
          Else
          Begin
          New(er,Init);
          Find:=False;
          While Not(Eof(ef)) And Not(Find) Do
           Begin
            Read(Ef,er^.Dat);
            If (ClearChar(Er^.Dat.Market.Document)=Es^.Dat.Document)
		 And (Er^.Dat.Market.DateC=Es^.Dat.DateC)
           And (Er^.Dat.Market.Active) Then
                Begin
                 Find:=True;
                 If Er^.Dat.Full Then ws:='1'
                 Else ws:='2';
                End;
           End;
          Dispose(Er,Done);
          System.Close(Ef);
          If Not(Find) Then
           Begin
            MessageBox(^M+#3'Документ не найден в долгах клиента!',Nil,mfError+mfCancelButton);
            ws:='0';
           End
          End;{Res=0 файл успешно открыт}
         End;{Res если реализация}


        s:=s+ws+'│'+Es^.Dat.AgentKod+'│';

        ws:=Copy(s,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+COne+1+COne+1+CDate+1+
        10+1+CIZena+1+CAll+1,COne);

     If StrToInt(ws)>0 Then
     If ss[StrToInt(ws)]=1 Then
     Begin
        StatList^.List^.Insert(NewStr(s));
        StatList^.SetRange(StatList^.List^.Count);
     End;
    End;{Auto or Not(Auto)}
   End;{конец фильтра документов}
End;{Active}
  End;{While}
 End{If}
 Else
  Begin
   If Auto Then
   Begin
   Min:=DateStringToDate(DateMask,FDate);
   Max:=DateStringToDate(DateMask,FDate);
   End;
  End;

 Dispose(Es,Done);

 System.Close(Esf);
 NoInfo;
End;

 StatList^.FocusItem(0);


 StartDate := DateToDateString(DateMask,Min);
 StopDate  := DateToDateString(DateMask,Max);

Dispose(sControlStartDAte,Done);
R.Assign(59, 1, 67, 2);
sControlStartDAte := New(PColoredText, Init(R, #3+StartDAte, $7E));
Insert(sControlStartDAte);

Dispose(sControlStopDate,Done);
R.Assign(71, 1, 79, 2);
sControlStopDate := New(PColoredText, Init(R, #3+StopDate, $7E));
Insert(sControlStopDate);

PrevCurrent[0]:=#0;
Redraw;
End;


procedure TStatWindow.DrawCurrent;
Var R : TRect;
    st : string;
    TempS: AllStr;
    ClientKod : ArtikulStr;
    SDoc,SDate : TDateString;
    er : PRealizasiaType;
    ef : File Of RealizasiaType;
    j : Word;
    Find : Boolean;

Begin

If (StatList^.List<>Nil)And(StatList^.List^.Count>0)  Then
 Begin
  st:=StatList^.GetText(StatList^.Focused,StatList^.List^.Count);
  If St <> PrevCurrent Then
   Begin
    PrevCurrent:=St;

    st:=Copy(PrevCurrent,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1,COne);
    {Вид документа}
{
    If StrToInt(st) in [5,6] Then EnableCommands([cmLocalInfo])
    Else DisableCommands([cmLocalInfo]);
}
    Case StrToInt(st) Of
    0:st:='Список';
    1:st:='Тов.Чек*';
    2:st:='Физ.Л*';
    3:st:='СФ*';
    4:st:='СФ ';
    5:st:='Дебит*';
    6:st:='Дебит СФ*';
    7:st:='Дебит';
    8:st:='Дебит СФ';
    Else St:='???';
    End;
        Dispose(sControlVidDoc,Done);
        R.Assign(25, 19, 34, 20);
        sControlVidDoc := New(PColoredText, Init(R, #3+st, $7E));
        Insert(sControlVidDoc);


    st:=Copy(PrevCurrent,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1,COne);
    {Вид скидки}
    Case StrToInt(st) Of
    0:st:='Авто';
    1:st:='Ручная';
    2:st:='Шкала';
    Else st:='???';
    End;
        Dispose(sControlSkidka,Done);
        R.Assign(43, 19, 49, 20);
        sControlSkidka := New(PColoredText, Init(R, #3+St, $7E));
        Insert(sControlSkidka);

    st:=Copy(PrevCurrent,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+COne+1,COne);
    {Вид расчета}
    Case StrToInt(st) Of
    1:st:='Нал';
    0:st:='Б/Н';
    Else st:='???';
    End;

        Dispose(sControlRashet,Done);
        R.Assign(9, 19, 12, 20);
        sControlRashet := New(PColoredText, Init(R, #3+st, $7E));
        Insert(sControlRashet);


    st:=Copy(PrevCurrent,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+COne+1+COne+1,CDate);
    {Дата п/п}
        Dispose(sControlDatePP,Done);
        R.Assign(18, 21, 26, 22);
        sControlDatePP := New(PColoredText, Init(R, #3+st, $7E));
        Insert(sControlDatePP);

    st:=Copy(PrevCurrent,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+COne+1+COne+1+CDate+1,
    10);
    DelSpace(st);
    {номер п/п}
        Dispose(sControlNPP,Done);
        R.Assign(35, 21, 45, 22);
        sControlNPP := New(PColoredText, Init(R, #3+st, $7E));
        Insert(sControlNPP);

    st:=Copy(PrevCurrent,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+COne+1+COne+1+CDate+1+
    10+1,CIZena);
    DelSpace(st);
    {сумма п/п}
        Dispose(sControlSummaPP,Done);
        R.Assign(58, 21, 73, 22);
        sControlSummaPP := New(PColoredText, Init(R, #3+st, $7E));
        Insert(sControlSummaPP);

    st:=Copy(PrevCurrent,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+COne+1+COne+1+CDate+1+
    10+1+CIZena+1,CAll);
    DelSpaceRight(st);
    {сумма п/п}
        Dispose(sControlBank,Done);
        R.Assign(44, 20, 79, 21);
        sControlBank := New(PColoredText, Init(R, #3+st, $7E));
        Insert(sControlBank);


        Dispose(sControlStatus,Done);
        R.Assign(68, 19, 79, 20);
        st:=Copy(PrevCurrent,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+
           COne+1+COne+1+CDate+1+
        10+1+CIZena+1+CAll+1,COne);

        Case StrToInt(st) Of
        2:st:='не оплачен!';
        1:st:='оплачен';
        0:st:='????';
        Else st:='????';
        End;
        sControlStatus := New(PColoredText, Init(R, #3+st, $7E));
        Insert(sControlStatus);

     Dispose(sControlTimeM,Done);
     st:=Copy(PrevCurrent,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1,CDate);
     R.Assign(29, 20, 37, 21);
     sControlTimeM := New(PColoredText, Init(R, #3+st, $7E));
     Insert(sControlTimeM);

     Dispose(sControlAgent,Done);
     st:=Copy(PrevCurrent,Ord(PrevCurrent[0])-CClientKod,CClientKod);
     TempS:=GetAgentField(FClient,st);
     Format(TempS,CClient);
     R.Assign(33, 18, 65, 19);
     SControlAgent := New(PColoredText, Init(R, TempS+'('+st+')', $7E));
     Insert(SControlAgent);



(*
        st:=Copy(PrevCurrent,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1,COne);
        If StrToInt(st) in [0,1,2,3,4] Then
        Begin
          st:='оплачен';
          sControlStatus := New(PColoredText, Init(R, #3+st, $7E));
        End
        Else
         Begin
          SDoc:=Copy(PRevCurrent,1+1,CDocNumer);
          DelZerro(Sdoc);
          DelSpace(Sdoc);
          SDate:=Copy(PRevCurrent,1+1+CDocNumer+1,CDAte);

          PStaticText(sControlClient)^.GetText(st);
          System.Delete(St,1,1);
          ClientKod:=Copy(st,1+CClient+1,CClientKod);

          Assign(ef,Path.ToDolg+ClientKod+'.dlg');
          j:=IOResult;
          Reset(Ef);
          j:=IOResult;
          If j<>0 Then
           Begin
            MessageBox(^M+#3'Ошибка доступа к файлу долгов клиента!',Nil,mfError+mfCancelButton);
            st:='??????';
            sControlStatus := New(PColoredText, Init(R, #3+st, $FE));
           End
          Else
          Begin
          New(er,Init);
          Find:=False;
          While Not(Eof(ef)) And Not(Find) Do
           Begin
            Read(Ef,er^.Dat);
            If (ClearChar(Er^.Dat.Market.Document)=SDoc) And (Er^.Dat.Market.DateC=SDate) Then
                Begin
                 Find:=True;
                 If Er^.Dat.Full Then st:='оплачен'
                 Else st:='не оплачен!';
                End;
           End;
          Dispose(Er,Done);
          System.Close(Ef);
          If Not(Find) Then
           Begin
            MessageBox(^M+#3'Документ не найден в долгах клиента!',Nil,mfError+mfCancelButton);
            st:='??????';
            sControlStatus := New(PColoredText, Init(R, #3+st, $FE));
           End
           Else
           Begin
            sControlStatus := New(PColoredText, Init(R, #3+st, $7E));
           End

          End;{j=0 файл успешно открыт}



         End;{Else если реализация}

        Insert(sControlStatus);
        *)

   Redraw;
   End;

 End

 Else
  Begin

PrevCurrent[0]:=#0;

Dispose(sControlRashet,Done);
R.Assign(9, 19, 12, 20);
sControlRashet := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlRashet);

Dispose(sControlVidDoc,Done);
R.Assign(25, 19, 34, 20);
sControlVidDoc := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlVidDoc);

Dispose(sControlSkidka,Done);
R.Assign(43, 19, 49, 20);
sControlSkidka := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlSkidka);

Dispose(sControlDatePP,Done);
R.Assign(18, 21, 26, 22);
sControlDatePP := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlDatePP);

Dispose(sControlBank,Done);
R.Assign(44, 20, 79, 21);
sControlBank := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlBank);

Dispose(sControlNPP,Done);
R.Assign(35, 21, 45, 22);
sControlNPP := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlNPP);

Dispose(sControlSummaPP,Done);
R.Assign(58, 21, 73, 22);
sControlSummaPP := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlSummaPP);

Dispose(sControlStatus,Done);
R.Assign(68, 19, 79, 20);
sControlStatus := New(PColoredText, Init(R, #3+'???', $FE));
Insert(sControlStatus);

Dispose(sControlTimeM,Done);
R.Assign(29, 20, 37, 21);
sControlTimeM := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlTimeM);

Redraw;
  End;
End;

procedure TStatWindow.FullPreview;
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
If (StatList^.List<>Nil)And(StatList^.List^.Count>0) Then
Begin
  Ass.EditPosition:=Copy(StatList^.GetText(StatList^.Focused,StatList^.List^.Count),1+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(StatList^.GetText(StatList^.Focused,StatList^.List^.Count),1+1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  Assign(f,Path.ToMarket+Ass.d+'.mrk');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
  Begin
   MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path.ToMarket+Ass.d+'.mrk',Nil,mfError+mfCancelButton);
   Exit;
  End;
  AInfo('Ищу документ...');
  New(E,Init);
  Find := False;
  ClearChar(Ass.EditPosition);
  While Not(Eof(f)) And Not(Find) Do
   Begin
     {
     Repeat
     Until NetCAll.Lock(f,FilePos(f)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMArket(f,E);
     {
     Repeat
      NetCall.UnLock(f,(FilePos(f)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
    ClearChar(E^.Dat.Document);
    If (E^.Dat.Active) And (E^.Dat.DateC=Ass.D) and
    (E^.Dat.Document=Ass.EditPosition) Then
                Begin
                 Find:=True;
                 Break;
                End;
   End;
   System.Close(f);
   If Find Then
    Begin
        R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));
For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.MarketElement[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,CName);
  s:=s+'│'+ws+'│';
  Str(E^.Dat.MarketElement[c].Input.DivisionSNumber:1,ws);
  s:=s+ws;
  DelSpace(E^.Dat.MarketElement[c].Input.Kol);
  Format(E^.Dat.MarketElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Kol;
  {
  ws:=GetIdField(FLitr,E^.Dat.MarketElement[c].BazKod);
  Format(Ws,CLitr);
  s:=s+'│'+ws;
  }
  DelSpace(E^.Dat.MarketElement[c].Input.Zena);
  Format(E^.Dat.MarketElement[c].Input.Zena,CZena);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Zena;


      Case E^.Dat.SkidkaSelector Of
      0:Begin{скидка автоматическая}
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
         (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         {форматируем прценты}
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Proz):CZena:CMantissa,ws1);
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Skidka):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
        (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100)):CZena:CMantissa,wspomSkidka);

         S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      2:Begin{скидка ручная по шкалам}
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
         (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         {форматируем проценты}
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Proz):CZena:CMantissa,ws1);
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Skidka):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
        (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100)):CZena:CMantissa,wspomSkidka);

         S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      1:Begin{скидка ручная}

           If StrToReal(E^.Dat.MarketElement[c].Input.Skidka)>=0 Then
           Begin
          {
          Str(((StrToReal(E^.Dat.MarketElement[c].Input.Zena))/((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
          StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))-1)*100
          :CZena:CLitrMantissa,ws1);}

          If (StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka))>0.009 Then
          Str(((StrToReal(E^.Dat.MarketElement[c].Input.Zena))/((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
          StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))-1)*100
          :CZena:CLitrMantissa,ws1)
          Else ws1:='100.00';

          Str(StrToReal(Ws1){*100}:CZena:CMantissa,ws1);
           End
           Else
             Begin
              Str((-(Abs(StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))/
              ((StrToReal(E^.Dat.MarketElement[c].Input.Zena)))*100):CZena:CMantissa,Ws1);
             End;

          Str(StrToReal(E^.Dat.MarketElement[c].Input.Skidka):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

          Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka))
         :CZena:CMantissa,wspomskidka);

          S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      Else;
      End;{E^.Dat.SkidkaSelector}




{
  DelSpace(E^.Dat.MarketElement[c].Input.Skidka);
  Format(E^.Dat.MarketElement[c].Input.Skidka,CZena);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Skidka;
}

  {
  DelSpace(E^.Dat.MarketElement[c].Input.Itogo);
  Format(E^.Dat.MarketElement[c].Input.Itogo,CInputIZena);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Itogo;
  }
  P^.List^.Insert(NewStr(s));
  P^.SetRange(P^.List^.Count);
 End;
 Case E^.Dat.SkidkaSelector Of
 0: ws:=' (Авто)';
 1: ws:=' (Ручная)';
 2: ws:=' (Шкала '+IntToStr(E^.Dat.ShkalaNumer,COne)+')';
 Else;
 End;
P^.FocusItem(0);
{
s:=E^.Dat.SummaZ;
DelSpace(s);
s:=' Всего сумма: '+s;
DelSpace(E^.Dat.Skidka);
s:=s+'  Всего скидка'+ws+': '+E^.Dat.Skidka;
}
s:=E^.Dat.SummaZ;
DelSpace(s);
s:=' К оплате: '+s;
DelSpace(E^.Dat.Skidka);
s:=s+' Всего скидка'+ws+': '+E^.Dat.Skidka;
E^.Dat.ENalog:=RealToStr(StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka){-StrToReal(E^.Dat.ENalog)},CIZena,CMantissa);
DelSpace(E^.Dat.ENalog);
s:=s+' Со склада:'+E^.Dat.ENalog;

SDoc:=E^.Dat.Document;
SDate:=E^.Dat.DateC;

Dispose(E,Done);

ProdagaWindow:=True;
NoInfo;
                   {Вставить номер и дату документа в просмотре}

FullScreen(P,' Код  Выбранн~ы~е товары           N Колич Цена лоб Цена опл  Скидка   Процент',s,
             { 12345│12345678901234567890123456│1│12345│12345678│12345│12345678│12345678}
SDoc,SDAte,0);
ProdagaWindow:=False;

Dispose(P,Done);
    End
Else
  Begin
  NoInfo;
  MessageBox(#3^M+#3'Документ не найден!',Nil,mfError+mfCancelButton);
  Dispose(E,Done);
  End;
End;
End;

Procedure TStatWindow.FormReport(Spis:PBox);
Const Space=' ';
Var Txt : Text;
    k,c : Word;
    TempS: AllStr;
    st,s,ws : string;
    Numer : ArtikulStr;
    R : TRect;
    Clientkod : String[cclientkod];

Begin
{$IFDEF DPMI}
 Assign(txt,Path.ToTemp+'person.txt');
 c := IOResult;
 Rewrite(txt);
 c:=IoResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3+'Не могу создать файл '+Path.ToTemp+'person.txt!',Nil,mfError+mfCancelButton);
   Exit;
  End;
 DInfoMsg('Формирую отчет. Ждите...');
 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');
 Writeln(txt,Space+'Включены в рассмотрение следующие виды документов:');
 Write(txt,Space);

 WordTobit9(Filtr,mm);
 Convert9(mm);

 WordToBit2(Oplata,ss);
 Convert2(ss);

 For c:=1 To Max9 Do
  Begin
   If mm[c]=1 Then
    Case c Of
    1:Write(txt,' "Список" ');
    2:Write(txt,' "Тов.Чек*" ');
    3:Write(txt,' "Физ.Л*" ');
    4:Write(txt,' "СФ*" ');
    5:Write(txt,' "СФ " ');
    6:Write(txt,' "Дебит*" ');
    7:Write(txt,' "Дебит СФ*" ');
    8:Write(txt,' "Дебит" ');
    9:Write(txt,' "Дебит СФ" ');
    Else;
    End;
  End;
 Writeln(txt);
 Writeln(txt);

 Writeln(txt,Space+'Включены в рассмотрение документы со статусом:');
 Write(txt,Space);
 For c:=1 To 2 Do
  Begin
   If ss[c]=1 Then
    Case c Of
    1:Write(txt,' "Оплаченные" ');
    2:Write(txt,' "Не оплаченные" ');
    Else;
    End;
  End;
 Writeln(txt);
 Writeln(txt);


 PStaticText(sControlClient)^.GetText(wS);
 System.Delete(wS,1,1);
 ClientKod:=Copy(ws,1+CClient+1,CClientKod);

 ws:=GetClientField(FClient,ClientKod,0);
 DelSpaceRight(ws);

 Writeln(txt,Space+' СПРАВКА ПО ОБОРОТАМ КЛИЕНТА: '+ws+' ('+ClientKod+') ЗА ПЕРИОД с '+StartDate+' по '+
 StopDate);
 Writeln(txt,Space+'---------------------------------------------------------------------------------------------');
 Writeln(txt,Space+'  N     Дата     Время   Сумма к оплате          Скидка Оператор     Рас.Вид док.  Статус');
                    {1234 12345678 12345678 123456789012345 123456789012345 123456789012 нал дебит с/ф не оплачен}
 Writeln(txt,Space+'---------------------------------------------------------------------------------------------');

If Spis^.List^.Count>0 Then
Begin
 For c:=0 To Spis^.List^.Count-1 Do
 Begin
    ws := Spis^.GetText(c,Spis^.List^.Count);
    s:= ws;
    TempS:=Copy(ws,Ord(ws[0])-CClientKod,CClientKod);
    While Pos('│',ws)>0 Do
    Begin
     k:=Pos('│',ws);
     System.Delete(ws,k,1);
     System.Insert(' ',ws,k);
    End;
    ws[0]:=Chr(1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto);


    st:=Copy(s,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+COne+1,COne);
    {Вид расчета}
    Case StrToInt(st) Of
    1:st:='Нал';
    0:st:='Б/Н';
    Else st:='???';
    End;
    Format (St,3);
    ws:=ws+' '+st;

    st:=Copy(s,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1,COne);
    {Вид документа}
    Case StrToInt(st) Of
    0:st:='Список';
    1:st:='Тов.Чек*';
    2:st:='Физ.Л*';
    3:st:='СФ*';
    4:st:='СФ ';
    5:st:='Дебит*';
    6:st:='Дебит СФ*';
    7:st:='Дебит';
    8:st:='Дебит СФ';
    Else St:='???';;
    End;
    Format (St,9);
    ws:=ws+' '+st;

    st:=Copy(s,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+
    COne+1+COne+1+CDate+1+10+1+CIZena+1+CAll+1,COne);
    Case StrToInt(st) Of
     2:st:='не оплачен';
     1:st:='оплачен';
     0:st:='????';
     Else st:='????';
     End;
    Format (St,10);
    ws:=ws+' '+st;

     TempS:=GetAgentField(FClient,TempS);
     DelSpaceRight(TempS);
     Format(TempS,CClient);
     Writeln(txt,Space+'Доставка: '+TempS);

    Writeln(txt,Space+Ws);
 End;
End;


 Writeln(txt,Space+'---------------------------------------------------------------------------------------------');

 PStaticText(sControlItogo)^.GetText(wS);
 System.Delete(wS,1,1);
 delspace(ws);
 Str(StrToReal(ws):CIZena:CMantissa,ws);

 PStaticText(sControlItogoskidka)^.GetText(S);
 System.Delete(S,1,1);
 delspace(s);
 Str(StrToReal(s):CIZena:CMantissa,s);

 Writeln(txt,Space,' Всего документов: ',Spis^.List^.Count:5,'   Всего к оплате: ',ws,+'   Всего скидка: ',s);

 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'=============================================================================================');


 System.Close(txt);
 NoInfoMsg;
 ViewAsText(Path.ToTemp+'person.txt',True);
 Report(Path.ToTemp+'person.txt','',1,False,False,false);

{$EndIf}
End;


procedure TStatWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1 : string;
    SDoc : ArtikulStr;
    SDate: TDateString;
    ClientKod : ArtikulStr;

    l : Boolean;
begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
        kbEsc: Begin
                    Event.What:=evCommand;
                    Event.Command:=cmCancel;
                    PutEvent(Event);
                    ClearEvent(Event);
                  End;
        {
        Ord('?'): Begin
                    Event.What:=evCommand;
                    Event.Command:=cmLastPrise;
                    PutEvent(Event);
                    ClearEvent(Event);
                  End;
        }
        Ord('!'): if (User[75] or (CurrentPassword='00')) then
	   Begin
                    Event.What:=evCommand;
                    Event.Command:=cmAnalysFromPeriod;
                    PutEvent(Event);
                    ClearEvent(Event);
                  End;
        kbAltF9:  if (User[74] or (CurrentPassword='00')) then
	   Begin
                    Event.What:=evCommand;
                    Event.Command:=cmReestrReport;
                    PutEvent(Event);
                    ClearEvent(Event);
                  End;
         Else;
         End;{KeyDown}
  evCommand :
        Case Event.Command Of

  cmAbout: Begin
    AboutCHM('36');
    ClearEvent(Event);

  End;

  cmAnalysFromPeriod :Begin
        If (StatList^.State and sfFocused <> 0) And (StatList^.List<>Nil)And(StatList^.List^.Count>=1) Then
                   Begin
                    ClearFind;
                    PStaticText(sControlClient)^.GetText(S);
                    System.Delete(S,1,1);
                    ClientKod:=Copy(s,1+CClient+1,CClientKod);
                    Analys^.Start(ClientKod);
                   End;
                  End;
  cmPrintReestr:    Begin
        If (StatList^.State and sfFocused <> 0) And (StatList^.List<>Nil)And(StatList^.List^.Count>=1) Then
                  Begin
                         ClearFind;
                         Assistent.EditPosition:=Copy(StatList^.GetText(StatList^.Focused,StatList^.List^.Count),
                                        1+1,CDocNumer);
                         DelSpace(Assistent.EditPosition);
                         DelZerro(Assistent.EditPosition);
                         Assistent.D:=Copy(StatList^.GetText(StatList^.Focused,StatList^.List^.Count),1+1+CDocNumer+1,CDate);
                         DelSpace(Assistent.D);
                         {PrintNaklSklad(Assistent,NPrint.CopyNkl);}
                         PrintNakl(Assistent,NPrint.CopyNkl);
                         ClearEvent(Event);
                  End
                  End;
 cmReestrReport:    Begin
        If (StatList^.State and sfFocused <> 0) And (StatList^.List<>Nil)And(StatList^.List^.Count>=1) Then
                  Begin
                   ClearFind;
                   FormReport(StatList);
                  End;
                  ClearEvent(Event);
                  End;
{
        cmLastPrise : Begin
        If (StatList^.State and sfFocused <> 0) And (StatList^.List<>Nil)And(StatList^.List^.Count>=1) Then
                      Begin
                       ClearFind;
                       PStaticText(sControlClient)^.GetText(S);
                       System.Delete(S,1,1);
                       ClientKod:=Copy(s,1+CClient+1,CClientKod);
                       LastClientKod:=ClientKod;
                       LastInfoZena^.Start(StatList);
                      End;
                      End;
}
        cmLocalInfo: Begin
        If (StatList^.State and sfFocused <> 0) And (StatList^.List<>Nil)And(StatList^.List^.Count>=1) Then
            Begin
                 ClearFind;
                 s1:=Copy(PrevCurrent,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1,COne);
                 {Вид документа}
                 If StrToInt(s1) in [5,6,7,8] Then
                 Begin
                 PStaticText(sControlClient)^.GetText(S);
                 System.Delete(S,1,1);
                 ClientKod:=Copy(s,1+CClient+1,CClientKod);
                 s:=StatList^.GetText(StatList^.Focused,StatList^.List^.COunt);
                 PrevCurrent[0]:=#0;
                 LockInfo^.LockStart(s,ClientKod);
                 End
                 Else
                  MessageBox(^M+#3+'Вы пытаетесь просмотреть историю оплаты по документу НЕ КОНСИГНАЦИИ!!!',Nil,
                  mfError+mfCancelButton);

            End;
                  ClearEvent(Event);
                          End;




  cmFullView:    Begin
        If (StatList^.State and sfFocused <> 0) And (StatList^.List<>Nil)And(StatList^.List^.Count>=1) Then
                  Begin
                    ClearFind;
                    FullPreview;
                  End;
                  ClearEvent(Event);
                 End;
        cmStat:Begin
                   ClearEvent(Event);
                  End;
        cmChangeDiapason: Begin
                                           ClearFind;
                                    If Period Then
                                         Begin
                                         Refresh(False);
                                         CalcItogo;
                                         End;
                                          ClearEvent(Event);
                                   End;
        cmRefresh: Begin
                                           ClearFind;
                                         Begin
                                         Refresh(False);
                                         CalcItogo;
                                         End;
                                          ClearEvent(Event);
                   End;
        cmOk       :Begin
                     ClearFind;
                     ClearEvent(Event);
                    End;

        cmCancel    : Begin
                     ClearFind;
{
 Dispose(sControlRashet,Done);
 Dispose(sControlSkidka,Done);
 Dispose(sControlVidDoc,Done);
 Dispose(sControlDatePP,Done);
 Dispose(sControlSummaPP,Done);
 Dispose(sControlNPP,Done);
 Dispose(sControlBank,Done);
 Dispose(sControlStatus,Done);
 Dispose(sControlItogo,Done);
 Dispose(sControlItogoSkidka,Done);
 Dispose(sControlDoc,Done);
 Dispose(sControlTimeM,Done);
 Dispose(sControlClient,Done);
 Dispose(SControlStartDate,Done);
 Dispose(SControlStopDate,Done);
 Dispose(SControlDocFiltr,Done);
 Dispose(SControlOplataFiltr,Done);
}

                          Event.What:=evCommand;
                          Event.Command:=cmClose;
                          PutEvent(Event);
                          ClearEvent(Event);
                         End;
  cmSelectClient:
 Begin
  If (PView(Cl)<>Desktop^.TopView)And(sControlClient^.State and sfFocused <> 0) Then
  Begin
{
        StatList^.NewList(nil);
        StatList^.NewList(New(PMyCollection, Init(0,1)));
}
        ClearFind;
        sControlClient^.Focus;
        PStaticText(sControlClient)^.GetText(S);
        System.Delete(S,1,1);

        Cl^.ShowClientList(s,0,0,True,False,False,-1,-1,-1,-1,Test);



        PStaticText(sControlClient)^.Text^:=#3+S;
        PrevS:=S;
        Case Test Of
         0,3 :FocusNext(True);
         1,2 :FocusNext(False);
        Else;
        End;
        Refresh(True);
        cALCiTOGO;
        PrevCurrent[0]:=#0;
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
    (Event.Command = cmStat) then ClearEvent(Event);

 If (PView(Cl)<>Desktop^.TopView)And(sControlClient^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectClient) And (Event.What <> EvKeyDown)Then
                  Begin
                   Event.What:=EvCommand;
                   Event.Command:=cmSelectClient;
                   PutEvent(Event);
                   ClearEvent(Event);
                  End;



  inherited HandleEvent(Event);

  If (Desktop^.Current=PView(StatWindow)) And (Event.What <> EvKeyDown) Then
                   Begin

                if (sControlDocFiltr^.State and sfFocused <> 0)Then
                    Begin
                        sControlDocFiltr^.GetData(Test);
                        If Test <> Filtr Then
                        Begin
                           ClearFind;
                           Filtr:=Test;
                           Refresh(False);
                           CalcItogo;
                           PrevCurrent[0]:=#0;
                        End;
                    End;

                if (sControlOplataFiltr^.State and sfFocused <> 0)Then
                    Begin
                        sControlOplataFiltr^.GetData(Test);
                        If Test <> Oplata Then
                        Begin
                           ClearFind;
                           Oplata:=Test;
                           Refresh(False);
                           CalcItogo;
                           PrevCurrent[0]:=#0;
                        End;
                    End;

                    DrawCurrent;
                   End;

end;

Function GetSetupBestClient:Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  C : Word;
  L : LongInt;

  Data : record
    Doc : Word;
    Opl : Word;
    Start: TDateString;
    Stop : TDateString;
   End;


begin
With Data Do
 Begin
  Doc:=511;
  Opl:=3;
  Start:=FDate;
  Stop:=FDate;
 End;



1:

GetSetupBestClient:=False;
R.Assign(20, 6, 60, 17);
New(Dlg, Init(R, 'Расчет рейтинга клиентов'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E011;


R.Assign(2, 2, 17, 9);
Control := New(PCheckboxes, Init(R,
  NewSItem('~С~писок*',
  NewSItem('~Т~.Ч*',
  NewSItem('Ф.Л*',
  NewSItem('С~Ф~*',
  NewSItem('СФ ',
  NewSItem('~Д~ебит*',
  NewSItem('Д~е~бит СФ*', Nil)))))))));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

  R.Assign(2, 1, 16, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Виды док-тов:', Control)));

R.Assign(19, 2, 38, 4);
Control := New(PCheckboxes, Init(R,
  NewSItem('~О~плаченные',
  NewSItem('~Н~е оплаченные', Nil))));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

  R.Assign(19, 1, 35, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Статус док-тов:', Control)));

R.Assign(20, 6, 35, 9);
Control := New(PColoredText, Init(R, '', $3E));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);



R.Assign(24, 6, 34, 7);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DAteFiltr{'##-##-9#'}, True));

  R.Assign(21, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'с:', Control)));

R.Assign(24, 8, 34, 9);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init({'##-##-9#'}DAteFiltr, True));

  R.Assign(20, 8, 24, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'по:', Control)));

R.Assign(20, 5, 31, 6);
Control := New(PColoredText, Init(R, ' За период: ', $3F));
Dlg^.Insert(Control);

Dlg^.SetData(Data);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(dlg);
If c<>cmCancel Then
 Begin
   Dlg^.GetData(Data);
   Dispose(Control,Done);
   Dispose(Dlg,Done);

   If Not(TestDate(Data.start,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Not(TestDate(Data.Stop,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;


   StartDate:=Data.Start;
   StopDate:=Data.Stop;

   {если даты перепутаны переставляем их}
   If DateStringToDate(DateMask,StopDate)<DateStringToDate(DateMask,StartDate) Then
    Begin
        Data.Stop:=StopDate;
        StopDate:=StartDate;
        StartDate:=Data.Stop;
    End;



 End
 Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
  End;
end;








procedure TSelectClientWindow.OpenSelectClientWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmClientStat, nil) = nil then
  begin
    DInfo('Инициализация анализа...');
    L:=True;
    ClientStatWindow := New(PSelectClientWindow, Init(L));
    If L Then
    Begin
    NoInfo;
    Application^.InsertWindow(ClientStatWindow);
    End
    Else
        Begin
         Status:=DocNormal;
         NoInfo;
         Dispose(ClientStatWindow,Done);
        End;
  end
  else
    if PView(ClientStatWindow) <> Desktop^.TopView then ClientStatWindow^.Select;
end;



constructor TSelectClientWindow.Init(Var l : Boolean);
Var R : TRect;
    i : Word;
    s : String[CIZena];
Begin

L:=False;
R.Assign(0, 0, 80, 23);
inherited Init(R, '');
TekDate:=FDate;
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E602;

R.Assign(47, 0, 57, 1);
SControlStartDate := New(PInputLine, Init(R, CDate));
Insert(sControlStartDate);
  PInputLine(SControlstartDate)^.Validator := New(PPXPictureValidator, Init(DAteFiltr{'##-##-9#'}, True));

  R.Assign(34, 0, 47, 1);
  Insert(New(PLabel, Init(R, 'З~а~ период с:', SControlStartDAte)));
s:='01-01-09';{специально для бакши}

SControlStartDate^.SetData(s);


R.Assign(61, 0, 71, 1);
sControlStopDate := New(PInputLine, Init(R, CDate));
Insert(sControlStopDate);
  PInputLine(sControlStopDate)^.Validator := New(PPXPictureValidator, Init(DAteFiltr{'##-##-9#'}, True));

  R.Assign(57, 0, 61, 1);
  Insert(New(PLabel, Init(R, '~п~о:', SControlStopDate)));

SControlStopDate^.SetData(FDate);

R.Assign(1, 1, 50, 3);
SControlDocFiltr := New(PCheckboxes, Init(R,
  NewSItem('С~п~',
  NewSItem('~Т~Ч*',
  NewSItem('ФЛ*',
  NewSItem('~С~Ф*',
  NewSItem('СФ',
  NewSItem('Д~*~',
  NewSItem('Д С~Ф~*',
  NewSItem('~Д~',
  NewSItem('Д СФ', Nil)))))))))));

Insert(SControlDocFiltr);
i:=511;
SControlDocFiltr^.SetData(i);


R.Assign(52, 1, 71, 3);
SControlOplataFiltr := New(PCheckboxes, Init(R,
  NewSItem('~О~плаченные',
  NewSItem('~Н~е оплаченные', Nil))));
Insert(SControlOplataFiltr);
i:=3;
SControlOplataFiltr^.SetDAta(i);

R.Assign(52, 4, 53, 15);
SControl := New(PScrollBar, Init(R));
Insert(SControl);

R.Assign(0, 4, 52, 15);
Client := New(PBox, Init(R, 2, PScrollbar(SControl)));
Client^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'Client.db');

i:=IOResult;
Reset (ClientFile);
i:=IOResult;
If i=0 Then
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
    S:='0.00';{CalcDolg(ClientElement.Kod);}
    Str(StrToReal(s):CIZena:CMAntissa,s);
    Client^.List^.Insert(NewStr(ClientElement^.Dat.Name+'│'+ClientElement^.Dat.Kod{+'│'+s}));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  MessageBox(^M+#3'Ошибка доступа к базе клиентов!',nil,mfError+mfCanCelButton);
  L:=False;
  Exit;
 End;
Client^.FocusItem(0);
Client^.HelpCtx:=$E586;
Insert(Client);


  R.Assign(1, 3, 42, 4);
  Insert(New(PLabel, Init(R, 'Ба~з~а клиентов        Код', Client)));


R.Assign(79, 4, 80, 15);
SControl := New(PScrollBar, Init(R));
Insert(SControl);

R.Assign(53, 4, 79, 15);
SelectClient := New(PBox, Init(R, 1, PScrollbar(SControl)));
SelectClient^.NewList(New(PTextCollection, Init(0,1)));
SelectClient^.FocusItem(0);
SelectClient^.HelpCtx:=$E596;
Insert(SelectClient);

  R.Assign(53, 3, 79, 4);
  Insert(New(PLabel, Init(R, '~В~ыбранные клиенты     Код', SelectClient)));

R.Assign(52, 16, 53, 21);
SControl := New(PScrollBar, Init(R));
Insert(SControl);

R.Assign(0, 16, 52, 21);
Agent := New(PBox, Init(R, 2, PScrollbar(SControl)));
Agent^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'Agent.db');

i:=IOResult;
Reset (ClientFile);
i:=IOResult;
If i=0 Then
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
    S:='0.00';{CalcDolg(ClientElement.Kod);}
    Str(StrToReal(s):CIZena:CMAntissa,s);
    Agent^.List^.Insert(NewStr(ClientElement^.Dat.Name+'│'+ClientElement^.Dat.Kod{+'│'+s}));
    Agent^.SetRange(Agent^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  MessageBox(^M+#3'Ошибка доступа к базе агентов!',nil,mfError+mfCanCelButton);
  L:=False;
  Exit;
 End;
Agent^.FocusItem(0);
Agent^.HelpCtx:=$E586;
Insert(Agent);


  R.Assign(1, 15, 42, 16);
  Insert(New(PLabel, Init(R, 'Ба~з~а агентов         Код', Agent)));


R.Assign(79, 16, 80, 21);
SControl := New(PScrollBar, Init(R));
Insert(SControl);

R.Assign(53, 16, 79, 21);
SelectAgent := New(PBox, Init(R, 1, PScrollbar(SControl)));
SelectAgent^.NewList(New(PTextCollection, Init(0,1)));
SelectClient^.FocusItem(0);
SelectAgent^.HelpCtx:=$E596;
Insert(SelectAgent);

  R.Assign(53, 15, 79, 16);
  Insert(New(PLabel, Init(R, '~В~ыбранные клиенты     Код', SelectAgent)));


R.Assign(2, 21, 16, 22);
SControl := New(PColoredText, Init(R, '     Лицензия:', $74));
Insert(SControl);

R.Assign(16, 21, 61, 22);
SControlDop := New(PColoredText, Init(R, #3+'???', $7E));
Insert(SControlDop);

R.Assign(25, 22, 43, 23);
SControl := New(PColoredText, Init(R, ' Выбрано клиентов:', $74));
Insert(SControl);

R.Assign(43, 22, 48, 23);
SControlPos := New(PColoredText, Init(R, #3+'???', $4E));
Insert(SControlPos);

R.Assign(2, 0, 24, 1);
SControl := New(PColoredText, Init(R, ' Формирование выборки ', $4F));
Insert(SControl);

SelectNext(False);
AddNAme;
Filtr:=511;
Oplata:=3;
PrevCurrent[0]:=#0;
L:=True;
End;



procedure TSelectClientWindow.AddName;

Var R : TRect;
    R1,R2 : Real;
    KolStr : String[CKol];
Begin
  Str(SelectClient^.List^.Count:CKol,Kolstr);
  DelSpace(KolStr);
  Dispose(SControlPos,Done);
  R.Assign(43, 22, 48, 23);
  SControlPos := New(PColoredText, Init(R, #3+KolStr, $4E));
  Insert(SControlPos);
End;


procedure TSelectClientWindow.DrawCurrent;
Var St : TEnjoyStr;
     R : TRect;
Begin
If (Client^.List<>Nil)And(Client^.List^.Count>0)  Then
 Begin
  st:=Client^.GetText(Client^.Focused,Client^.List^.Count);
  If St <> PrevCurrent Then
   Begin
    PrevCurrent:=St;
    st:=Copy(PrevCurrent,1+CClient+1,CClientKod);
    st:=GetClientField(fEnvir,St,0);
    DelSpaceRight(st);
    Dispose(sControlDop,Done);
    R.Assign(16, 21, 61, 22);
    sControlDop := New(PColoredText, Init(R, #3+st, $7E));
    Insert(sControlDop);
   Redraw;
   End;

 End

 Else
  Begin
If PrevCurrent[0]<>#0 Then
Begin
PrevCurrent[0]:=#0;
Dispose(sControlDop,Done);
R.Assign(16, 21, 61, 22);
sControlDop := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlDop);
Redraw;
End;
  End;

End;

procedure TSelectClientWindow.FullPreview;
Begin
End;



procedure TSelectClientWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1 : string[150];
    SDoc : ArtikulStr;
    SDate: TDateString;
    ClientKod : ArtikulStr;
    Ls : LongInt;
    l : Boolean;
    sstart,sstop : TDateString;
begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
      kbIns: Begin
               ProdagaWindow:=False;
                ClearFind;
            If(Client^.State and sfFocused <> 0) And (Client^.List^.Count>=1) Then
            Begin
               s:=Client^.GetText(Client^.Focused,Client^.List^.COunt);
               If TestElement(Copy(s,1+CClient+1,CClientKod),SelectClient) Then
               Begin
                s:=Copy(s,1,CCLient+1+CClientKod);
                SelectClient^.List^.Insert(NewStr(s));
                SelectClient^.SetRange(SelectClient^.List^.Count);
                ProdagaWindow:=False;
                s:=Client^.GetText(Client^.Focused,Client^.List^.COunt);
                s:=Copy(s,1+CClient+1,CClientKod);
                SelectClient^.FocusItem(LoCation(SelectClient,S,ProdagaWindow));
                If SelectClient^.Focused+1<SelectClient^.List^.Count Then
                SelectClient^.FocusItem(SelectClient^.List^.Count-1);
               End;
               If (Client^.Focused+1)<Client^.List^.Count Then
               Client^.FocusItem(Client^.Focused+1);
            End;
            If(Agent^.State and sfFocused <> 0) And (Agent^.List^.Count>=1) Then
            Begin
               s:=Agent^.GetText(Agent^.Focused,Agent^.List^.COunt);
               If TestElement(Copy(s,1+CClient+1,CClientKod),SelectAgent) Then
               Begin
                s:=Copy(s,1,CCLient+1+CClientKod);
                SelectAgent^.List^.Insert(NewStr(s));
                SelectAgent^.SetRange(SelectAgent^.List^.Count);
                ProdagaWindow:=False;
                s:=Agent^.GetText(Agent^.Focused,Agent^.List^.COunt);
                s:=Copy(s,1+CClient+1,CClientKod);
                SelectAgent^.FocusItem(LoCation(SelectAgent,S,ProdagaWindow));
                If SelectAgent^.Focused+1<SelectAgent^.List^.Count Then
                SelectAgent^.FocusItem(SelectAgent^.List^.Count-1);
               End;
               If (Agent^.Focused+1)<Agent^.List^.Count Then
               Agent^.FocusItem(Agent^.Focused+1);
            End;
              ClearEvent(Event);
              Redraw;
              AddName;
              PrevCurrent[0]:=#0;
            End;


  kbCtrLDel: Begin
               ClearFind;
               ProdagaWindow:=False;
     If (SelectClient^.State and sfFocused <> 0) And (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>=1) Then
            Begin
             SelectClient^.NewList(nil);
             SelectClient^.NewList(New(PTextCollection, Init(0,1)));
            End;
     If (SelectAgent^.State and sfFocused <> 0) And (SelectAgent^.List<>Nil)And(SelectAgent^.List^.Count>=1) Then
            Begin
             SelectAgent^.NewList(nil);
             SelectAgent^.NewList(New(PTextCollection, Init(0,1)));
            End;
            ClearEvent(Event);
             Redraw;
             PrevCurrent[0]:=#0;
             AddName;
            End;

     kbDel: Begin
                ClearFind;
               ProdagaWindow:=False;
     If (SelectClient^.State and sfFocused <> 0) And (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>=1) Then
            Begin
             SelectClient^.List^.AtFree(SelectClient^.Focused);
             SelectClient^.SetRange(SelectClient^.List^.Count);
             If SelectClient^.Focused>0 Then
             SelectClient^.FocusItem(SelectClient^.Focused);

             If (SelectClient^.Focused>=SelectClient^.List^.Count) and(SelectClient^.Focused>0) Then
             SelectClient^.FocusItem(SelectClient^.Focused-1);

              ClearEvent(Event);
              Redraw;
              AddName;
            End;
     If (SelectAgent^.State and sfFocused <> 0) And (SelectAgent^.List<>Nil)And(SelectAgent^.List^.Count>=1) Then
            Begin
             SelectAgent^.List^.AtFree(SelectAgent^.Focused);
             SelectAgent^.SetRange(SelectAgent^.List^.Count);
             If SelectAgent^.Focused>0 Then
             SelectAgent^.FocusItem(SelectAgent^.Focused);

             If (SelectAgent^.Focused>=SelectAgent^.List^.Count) and(SelectAgent^.Focused>0) Then
             SelectAgent^.FocusItem(SelectAgent^.Focused-1);

              ClearEvent(Event);
              Redraw;
              AddName;
            End;
              PrevCurrent[0]:=#0;
            End;

   kbGrayPlus,
   kbCtrlIns: Begin
                ClearFind;
                 ProdagaWindow:=False;
          If ((Client^.State and sfFocused <> 0)And(Client^.List^.Count>= 1)) Then
            Begin
             DInfo('Минуточку...');
             If Client^.List^.Count>0 Then
             Begin
             SelectClient^.NewList(nil);
             SelectClient^.NewList(New(PTextCollection, Init(0,1)));

             For ls :=0 To Client^.List^.Count-1 Do
              Begin
               s:=Client^.GetText(ls,Client^.List^.Count);
               {if Testelement(Copy(s,1+CClient+1,CClientKod),SelectClient) then}
                Begin
                 s:=Copy(s,1,CCLient+1+CClientKod);
                 SelectClient^.List^.Insert(NewStr(s));
                 SelectClient^.SetRange(SelectClient^.List^.Count);
                End;
              End;
             End;
              NoInfo;
                 ProdagaWindow:=False;
                 {SelectClient^.SetRange(SelectClient^.List^.Count);}
                 If Client^.Focused+1<Client^.List^.Count Then Client^.FocusItem(Client^.Focused+1);
                 If SelectClient^.Focused+1<SelectClient^.List^.Count Then
                 SelectClient^.FocusItem(SelectClient^.List^.Count-1);
             End
            Else ClearEvent(Event);
          If ((Agent^.State and sfFocused <> 0)And(Agent^.List^.Count>= 1)) Then
            Begin
             DInfo('Минуточку...');
             If Agent^.List^.Count>0 Then
             Begin
             SelectAgent^.NewList(nil);
             SelectAgent^.NewList(New(PTextCollection, Init(0,1)));

             For ls :=0 To Agent^.List^.Count-1 Do
              Begin
               s:=Agent^.GetText(ls,Client^.List^.Count);
               {if Testelement(Copy(s,1+CClient+1,CClientKod),SelectClient) then}
                Begin
                 s:=Copy(s,1,CCLient+1+CClientKod);
                 SelectAgent^.List^.Insert(NewStr(s));
                 SelectAgent^.SetRange(SelectAgent^.List^.Count);
                End;
              End;
             End;
              NoInfo;
                 ProdagaWindow:=False;
                 {SelectAgent^.SetRange(SelectAgent^.List^.Count);}
                 If Agent^.Focused+1<Agent^.List^.Count Then Agent^.FocusItem(Agent^.Focused+1);
                 If SelectAgent^.Focused+1<SelectAgent^.List^.Count Then
                 SelectAgent^.FocusItem(SelectAgent^.List^.Count-1);
             End
            Else ClearEvent(Event);
            Redraw;
              AddName;
              PrevCurrent[0]:=#0;
            End;

   kbCtrlRusA: Begin
                ClearFind;
                 ProdagaWindow:=False;
          If ((Client^.State and sfFocused <> 0)And(Client^.List^.Count>= 1)) Then
            Begin
             DInfo('Минуточку...');
             If Client^.List^.Count>0 Then
             Begin

             For ls :=0 To Client^.List^.Count-1 Do
              Begin
               s:=Client^.GetText(ls,Client^.List^.Count);
               if Testelement(Copy(s,1+CClient+1,CClientKod),SelectClient) then
                Begin
                 s:=Copy(s,1,CCLient+1+CClientKod);
                 If Pos('А-',s) =1 Then
                 Begin
                 SelectClient^.List^.Insert(NewStr(s));
                 SelectClient^.SetRange(SelectClient^.List^.Count);
                 End;
                End;
              End;
             End;
              NoInfo;
                 ProdagaWindow:=False;
                 {SelectClient^.SetRange(SelectClient^.List^.Count);}
                 If Client^.Focused+1<Client^.List^.Count Then Client^.FocusItem(Client^.Focused+1);
                 If SelectClient^.Focused+1<SelectClient^.List^.Count Then
                 SelectClient^.FocusItem(SelectClient^.List^.Count-1);
             End
            Else ClearEvent(Event);
            Redraw;
              AddName;
              PrevCurrent[0]:=#0;
            End;
   kbCtrlRusC: Begin
                ClearFind;
                 ProdagaWindow:=False;
          If ((Client^.State and sfFocused <> 0)And(Client^.List^.Count>= 1)) Then
            Begin
             DInfo('Минуточку...');
             If Client^.List^.Count>0 Then
             Begin

             For ls :=0 To Client^.List^.Count-1 Do
              Begin
               s:=Client^.GetText(ls,Client^.List^.Count);
               if Testelement(Copy(s,1+CClient+1,CClientKod),SelectClient) then
                Begin
                 s:=Copy(s,1,CCLient+1+CClientKod);
                 If Pos('С-',s) =1 Then
                 Begin
                 SelectClient^.List^.Insert(NewStr(s));
                 SelectClient^.SetRange(SelectClient^.List^.Count);
                 End;
                End;
              End;
             End;
              NoInfo;
                 ProdagaWindow:=False;
                 {SelectClient^.SetRange(SelectClient^.List^.Count);}
                 If Client^.Focused+1<Client^.List^.Count Then Client^.FocusItem(Client^.Focused+1);
                 If SelectClient^.Focused+1<SelectClient^.List^.Count Then
                 SelectClient^.FocusItem(SelectClient^.List^.Count-1);
             End
            Else ClearEvent(Event);
            Redraw;
              AddName;
              PrevCurrent[0]:=#0;
            End;

   kbF8   : Begin
                ClearFind;
                ProdagaWindow:=False;
              If (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>0) Then
               Begin
                If PAssword(3) Then CreatPrimReport(SelectClient,0);
               End;

                PrevCurrent[0]:=#0;
            End;

   kbCtrlF8   : Begin
                ClearFind;
                ProdagaWindow:=False;
              If (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>0) Then
               Begin
                If PAssword(3) Then CreatPersonalCartReport(SelectClient,0);
               End;

                PrevCurrent[0]:=#0;
            End;


        kbEsc: Begin
{                   Dispose(SControlPos,Done);
                    Dispose(SControlDop,Done);}
                    Event.What:=evCommand;
                    Event.Command:=cmCancel;
                    PutEvent(Event);
                    ClearEvent(Event);
                  End;
         Else;
         End;{KeyDown}
  evCommand :
        Case Event.Command Of

  cmAbout: Begin
     AboutCHM('34');
     ClearEvent(Event);
     End;

  cmFullView:Begin

             End;


  cmCalcStat :Begin
              ClearFind;
              If (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>0)And
		       (SelectAgent^.List<>Nil)And(SelectAgent^.List^.Count>0)  Then
               Begin
               {проверяем стартовую дату}
               SControlStartDate^.GetData(sstart);
               If Not(TestDate(sstart,Ls)) Then
                Begin
                 MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;
               {проверям конечную дату}
               SControlStopDate^.GetData(sstop);
               If Not(TestDate(sstop,Ls)) Then
                Begin
                 MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;


               {назначаем диапазон дат}
               StopDate :=SStop;
                        StartDate:=SStart;
               {назначаем фильтр видов документов}
               SControlDocFiltr^.GetData(Filtr);

               {назначаем фильтр оплаты}
               sControlOplataFiltr^.GetData(Oplata);

               {спрашиваем требуемый вид отчета}
               if (User[77]) or
               ((StrToInt(CurrentPassword)=0)){ Or (Password(9)))}
			 Then
               SelectorReport:=SelectImport(11)
               Else SelectorReport:=0;

               If SelectorReport=2 Then
                Begin
                 ClearEvent(Event);
                 Exit;
                End;


               {старт загрузки ответа на сформированный запрос}
               GroupCalcWindow^.Start(l);

               End
               Else
                Begin
              If (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>0) Then
                 MessageBox(^M+#3'Список выбранных агентов - пустой!',Nil,mfError+mfCancelButton)
              Else
                 MessageBox(^M+#3'Список выбранных клиентов - пустой!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;






               PrevCurrent[0]:=#0;
              End;

        cmAllSfB    : if (User[7] or (CurrentPassword='00')) then
	     Begin
              ClearFind;
              If (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>0)And
		       (SelectAgent^.List<>Nil)And(SelectAgent^.List^.Count>0)  Then
               Begin
               {проверяем стартовую дату}
               SControlStartDate^.GetData(sstart);
               If Not(TestDate(sstart,Ls)) Then
                Begin
                 MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;
               {проверям конечную дату}
               SControlStopDate^.GetData(sstop);
               If Not(TestDate(sstop,Ls)) Then
                Begin
                 MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;


               {назначаем диапазон дат}
               StopDate :=SStop;
                        StartDate:=SStart;
               {назначаем фильтр видов документов}
               SControlDocFiltr^.GetData(Filtr);

               {назначаем фильтр оплаты}
               sControlOplataFiltr^.GetData(Oplata);

               {старт загрузки ответа на сформированный запрос}
                CalcMenedger2(SelectClient,SelectAgent,Filtr,Oplata,StartDate,StopDate);
               End
               Else
                Begin
              If (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>0) Then
                 MessageBox(^M+#3'Список выбранных агентов - пустой!',Nil,mfError+mfCancelButton)
              Else
                 MessageBox(^M+#3'Список выбранных клиентов - пустой!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;






               PrevCurrent[0]:=#0;
                     End;



cmClientStat:Begin
                   ClearEvent(Event);
                  End;
        cmCancel    : Begin
                          Event.What:=evCommand;
                          Event.Command:=cmClose;
                          PutEvent(Event);
                          ClearEvent(Event);
                          PrevCurrent[0]:=#0;
                         End;
         Else;
         End;{evCommand}
         Else;
         End;{*Case*}

  if (Event.What = evBroadcast) and
    (Event.Command = cmClientStat) then ClearEvent(Event);



  inherited HandleEvent(Event);

  If (Desktop^.Current=PView(ClientStatWindow)) And (Event.What <> EvKeyDown) Then
   Begin
      DrawCurrent;
   End;


end;

Procedure TCalcWindow.Start(Var l : Boolean);
Var R : TRect;
    Res,C : Word;
    Control : PView;
    Cur,Min,Max,k,j : LongInt;
    ws : string[150];
    Es : PStatClientType;
    Esf : File Of StatClientType;
    SummaOtgr,Summa,Skidka:String[CIZena];
    SClientKod,SDoc : String[CClientKod];
    Add , Find : Boolean;
    Er : PRealizasiaType;
    Ef : File Of RealizasiaType;
Begin
AInfo('Формирую выборку...');
R.Assign(0, 0, 80, 23);
New(CalcWindow, Init(R, 'Обороты выбранных клиентов с '+StartDate+' по '+StopDate));
CalcWindow^.Options := CalcWindow^.Options or ofCenterX;
CalcWindow^.HelpCtx := $E191;


R.Assign(0,0,0,0);
TempCalcList := New(PBox, Init(R, 1, Nil));
TempCalcList^.NewList(New(PTextCollection, Init(0,1)));

 WordTobit9(Filtr,mm);
 Convert9(mm);

 WordToBit2(Oplata,ss);
 Convert2(ss);

  Min:=DateStringToDate(DateMask,StartDate);
  Max:=DateStringToDate(DateMask,StopDate);

  AllSumma[0]:=#0;
  AllSummaOtgr[0]:=#0;
  AllSkidka[0]:=#0;

If (SelectCLient^.List^.Count>0) Then
For j:=0 To SelectClient^.List^.Count-1 Do
 Begin
  ws:=SelectClient^.GetText(j,SelectClient^.List^.Count);
  SClientKod:=Copy(ws,1+CCLient+1,CClientKod);
  Summa[0]:=#0;
  SummaOtgr[0]:=#0;
  Skidka[0]:=#0;
  SDoc[0]:=#0;
  Assign(Esf,Path.ToClient+SClientKod+'.his');
  k:=IOResult;
  Reset(Esf);
  k:=IOResult;


 If k=0 Then
 Begin
  New(Es,Init);
  While Not(Eof(Esf)) Do
  Begin
   Read(Esf,Es^.Dat);
   If (Es^.Dat.Active)And Not(TestElement(Es^.Dat.AgentKod,SelectAgent)) Then
Begin
   Cur := DateStringToDate(DateMask,Es^.Dat.DateC);
   If (Cur>=Min)And(Cur<=MAx) Then
   Begin
(*  If (Es^.Dat.DocSelector=5) And (Es^.Dat.Sf) Then Inc(Es^.Dat.DocSelector);{Дебит С/Ф}*)



    If mm[Es^.Dat.DocSelector+1]=1 Then{фильтр документов}
    Begin

     Add:=False;

    If (Es^.Dat.DocSelector in [0,1,2,3,4]) Then
     Begin
      If ss[1]=1 Then Add:=True;
     End
     Else{для случая консигнации}
     Begin
          DelZerro(Es^.Dat.Document);
          DelSpace(Es^.Dat.Document);

          Assign(ef,Path.ToDolg+SClientKod+'.dlg');
          Res:=IOResult;
          Reset(Ef);
          Res:=IOResult;

          If Res<>0 Then
            MessageBox(^M+#3'Ошибка доступа к файлу долгов клиента '+SClientKod+'!',Nil,mfError+mfCancelButton)
          Else
          Begin
          New(er,Init);
          Find:=False;
          While Not(Eof(ef)) And Not(Find) Do
           Begin
            Read(Ef,er^.Dat);
            If (ClearChar(Er^.Dat.Market.Document)=Es^.Dat.Document)
		  And(Er^.Dat.Market.DateC=Es^.Dat.DateC)
            And(Er^.Dat.Market.Active) Then
                Begin
                 Find:=True;
                 If ((Er^.Dat.Full) and (ss[1]=1)) Or
                             (Not(Er^.Dat.Full) and (ss[2]=1)) Then Add:=True;
                End;
           End;
          Dispose(Er,Done);
          System.Close(Ef);

          If Not(Find) Then  MessageBox(^M+#3'Документ не найден в долгах клиента '+SClientKod+'!',Nil,mfError+mfCancelButton);
          End;{Res=0 файл успешно открыт}

     End;

    If Add Then
    Begin
     Str(StrToReal(Summa)+StrToReal(Es^.Dat.SummaZ):CIZena:CMantissa,SUmma);
     Str(StrToReal(SummaOtgr)+StrToReal(Es^.Dat.SummaZ)+StrToReal(Es^.Dat.Skidka):CIZena:CMantissa,SUmmaOtgr);

     If SelectorReport=0 Then
     MyStr(StrToReal(Skidka)+StrToReal(Es^.Dat.Skidka),CIZena,CMantissa,Skidka)
     Else

     MyStr(StrToReal(Skidka)+
	      StrToReal(Es^.Dat.SummaZ)-
		 StrToReal(Es^.Dat.SummaZakupka),
		 CIZena,CMantissa,Skidka);


     {Str(StrToReal(Skidka)+StrToReal(Es^.Dat.Skidka):CIZena:CMantissa,Skidka);}
     Str(StrToInt(SDoc)+1:CClientKod,SDoc);
    End;{конец фильтра оплаты}
    End;{конец фильтра документов}
   End;{Конец фильтра дат}
End;{Active}
  End;{While}
  Dispose(Es,Done);
  System.Close(Esf);
 End;{If открытие файла успешное}
   Str(StrToReal(Summa):CIZena:CMantissa,SUmma);
   Str(StrToReal(SummaOtgr):CIZena:CMantissa,SUmmaOtgr);
   Str(StrToReal(Skidka):CIZena:CMantissa,Skidka);
   Str(StrToInt(SDoc):CClientKod,SDoc);

  Ws:=Copy(ws,1,1+CCLient+1+CClientKod+1+1);
  ws:=ws+'│'+SummaOtgr+'│'+Skidka+'│'+Summa+'│'+SDoc;
  TempCalcList^.List^.Insert(NewStr(ws));
  TempCalcList^.SetRange(TempCalcList^.List^.Count);

  Str(StrToReal(AllSummaOtgr)+StrToReal(SummaOtgr):CIZena:CMantissa,AllSummaOtgr);
  Str(StrToReal(AllSumma)+StrToReal(Summa):CIZena:CMantissa,AllSumma);
  Str(StrToReal(AllSkidka)+StrToReal(Skidka):CIZena:CMantissa,AllSkidka);

 End;{For}

{TempCalcList^.FocusItem(0);}{убрал исходя из опыта ошибки в ReestrWindow}

{TempCalcList^.Options:=TempCalcList^.Options and not ofSelectable;
CalcWindow^.Insert(TempCalcList);}

  Str(StrToReal(AllSummaOtgr):CIZena:CMantissa,AllSummaOtgr);
  Str(StrToReal(AllSumma):CIZena:CMantissa,AllSumma);
  Str(StrToReal(AllSkidka):CIZena:CMantissa,AllSkidka);

R.Assign(1, 1, 53, 2);
If SelectorReport=0 Then
SControlSort := New(PRadioButtons, Init(R,
  NewSItem('Кл~и~ент',
  NewSItem('От~г~рузка',
  NewSItem('Ски~д~ка',
  NewSItem('К ~о~плате', Nil))))))
Else
SControlSort := New(PRadioButtons, Init(R,
  NewSItem('Кл~и~ент',
  NewSItem('От~г~рузка',
  NewSItem('До~х~од',
  NewSItem('К ~о~плате', Nil))))));

Sorting:=0;
SControlSort^.SetData(Sorting);

CalcWindow^.Insert(SControlSort);


  R.Assign(1, 0, 13, 1);
  CalcWindow^.Insert(New(PLabel, Init(R, '~С~ортировка:', SControlSort)));


R.Assign(65, 1, 79, 2);
SControlVidSort := New(PRadioButtons, Init(R,
  NewSItem(#30,
  NewSItem(#31, Nil))));

VidSorting:=0;

SControlVidSort^.SetDAta(VidSorting);

CalcWindow^.Insert(SControlVidSort);

R.Assign(57, 1, 62, 2);
SControlReiting := New(PColoredText, Init(R, #3+'1', $4E));
CalcWindow^.Insert(SControlReiting);
Reiting[0]:=#0;

R.Assign(55, 1, 57, 2);
Control := New(PColoredText, Init(R, 'N:', $74));
CalcWindow^.Insert(Control);



  R.Assign(65, 0, 70, 1);
  CalcWindow^.Insert(New(PLabel, Init(R, '~Т~ип:', SControlVidSort)));

R.Assign(79, 3, 80, 22);
Control := New(PScrollBar, Init(R));
CalcWindow^.Insert(Control);

R.Assign(0, 3, 79, 22);
CalcList := New(PBox, Init(R, 1, PScrollbar(Control)));
CalcList^.NewList(New(PMyCollection, Init(0,1)));
CalcList^.HelpCtx:=$E612;
CAlcList^.FocusItem(0);
CalcWindow^.Insert(CalcList);

  R.Assign(1, 2, 79, 3);
If SelectorReport=0 Then
  CalcWindow^.Insert(New(PLabel, Init(R, 'Кли~е~нт              Код  Сумма отгрузки     Скидка       Сумма к оплате  Док.',
  CalcList)))
Else
  CalcWindow^.Insert(New(PLabel, Init(R, 'Кли~е~нт              Код  Сумма отгрузки     Доходность   Сумма к оплате  Док.',
  CalcList)));

R.Assign(1, 22, 12, 23);
Control := New(PColoredText, Init(R, 'E Отгрузка:', $74));
CalcWindow^.Insert(Control);

R.Assign(12, 22, 27, 23);
DelSpace(AllSummaOtgr);
Control := New(PColoredText, Init(R, #3+AllSummaOtgr, $4E));
CalcWindow^.Insert(Control);

R.Assign(27, 22, 37, 23);
If SelectorReport=0 Then
Control := New(PColoredText, Init(R, ' E Скидка:', $74))
Else
Control := New(PColoredText, Init(R, ' E  Доход:', $74));
CalcWindow^.Insert(Control);

R.Assign(37, 22, 52, 23);
DelSpace(AllSkidka);
Control := New(PColoredText, Init(R, #3+AllSkidka, $4E));
CalcWindow^.Insert(Control);


R.Assign(52, 22, 64, 23);
Control := New(PColoredText, Init(R, ' E К оплате:', $74));
CalcWindow^.Insert(Control);

R.Assign(64, 22, 79, 23);
DelSpace(AllSumma);
Control := New(PColoredText, Init(R, #3+AllSumma, $4E));
CalcWindow^.Insert(Control);

CalcWindow^.SelectNext(False);

NoInfo;

Refresh;

c:=Desktop^.ExecView(CalcWindow);

l:=True;

Dispose(Control,Done);
Dispose(TempCalcList,Done);
Dispose(CalcWindow,Done);



End;




Procedure TCalcWindow.Refresh;
Var i,j : Word;
    ws,ws1 : string[150];
    TempBox : PBox;
    R : TRect;
Begin

R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

CalcList^.NewList(Nil);
CalcList^.NewList(New(PMyCollection, Init(0,1)));


DInfoMsg('Сортирую выборку...');



If VidSorting=1 Then
DistanationSorting:=False
Else
DistanationSorting:=True;


If TempCalcList^.List^.Count>0 Then
Begin
{формируем отсортированый список}
For j:=0 to TempCalcList^.List^.Count-1 Do
Begin
 ws:=TempCalcList^.GEtText(j,TempCalcList^.List^.Count);
Case Sorting Of
{клиент}
0:ws:=ws;
{сумма отгрузки}
1:Begin
   ws1:=Copy(ws,1+CClient+1+CClientKod+1,CIZena);
   System.Delete(ws,1+CClient+1+CClientKod+1,CIZena+1);
   ws:=ws1+' '+ws;
  End;
{сумма скидки}
2:Begin
   ws1:=Copy(ws,1+CClient+1+CClientKod+1+CIZena+1,CIZena);
   RFormatZerro(ws1,CIZena);
   {System.Delete(ws,1+CClient+1+CClientKod+1+CIZena+1,CIZena+1);}
   ws:=ws1+' '+ws;
  End;
{сумма к оплате}
3:Begin
   ws1:=Copy(ws,1+CClient+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);
   System.Delete(ws,1+CClient+1+CClientKod+1+CIZena+1+CIZena+1,CIZena+1);
   ws:=ws1+' '+ws;
  End;
Else;
End;{CAse}
  TempBox^.List^.Insert(NewStr(ws));
  TempBox^.SetRange(TempBox^.List^.Count);
End;



{форматируем сформированый список под экранную форму}
If TempBox^.List^.Count>0 Then
Begin
For j:=0 to TempBox^.List^.Count-1 Do
Begin
  ws:=TempBox^.GEtText(j,TempBox^.List^.Count);

Case Sorting Of
{клиент}
0:ws:=ws;
{сумма отгрузки}
1:Begin
   ws1:=Copy(ws,1,CIZena);
   System.Delete(ws,1,CIZena+1);
   System.Insert(ws1+'│',ws,1+CClient+1+CClientKod+1);
  End;
{сумма скидки}
2:Begin
   ws1:=Copy(ws,1,CIZena);
   System.Delete(ws,1,CIZena+1);
   {System.Insert(ws1+'│',ws,1+CClient+1+CClientKod+1+CIZena+1);}
  End;
{сумма к оплате}
3:Begin
   ws1:=Copy(ws,1,CIZena);
   System.Delete(ws,1,CIZena+1);
   System.Insert(ws1+'│',ws,1+CClient+1+CClientKod+1+CIZena+1+CIZena+1);
  End;
Else;
End;{CAse}

  CalcList^.List^.Insert(NewStr(ws));
  CalcList^.SetRange(CalcList^.List^.Count);
End;
End;
End;{If TempCalcList^.List^.Count>0 Then}


NoInfoMsg;


Dispose(TempBox,Done);

CalcList^.FocusItem(0);

DistanationSorting:=True;


End;


Procedure TCalcWindow.FormReport(S:PBox);
Const Space='      ';
Var Txt : Text;
    k,c : Word;
    ws : string[150];
    Numer : ArtikulStr;
Begin
{$IFDEF DPMI}
 Assign(txt,Path.ToTemp+'coborot.txt');
 c := IOResult;
 Rewrite(txt);
 c:=IoResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3+'Не могу создать файл '+Path.ToTemp+'coborot.txt!',Nil,mfError+mfCancelButton);
   Exit;
  End;
 DInfoMsg('Формирую отчет. Ждите...');
 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');
 Writeln(txt,Space+'Включены в рассмотрение следующие виды документов:');
 Write(txt,Space);
 For c:=1 To Max9 Do
  Begin
   If mm[c]=1 Then
    Case c Of
    1:Write(txt,' "Список" ');
    2:Write(txt,' "Тов.Чек*" ');
    3:Write(txt,' "Физ.Л*" ');
    4:Write(txt,' "СФ*" ');
    5:Write(txt,' "СФ " ');
    6:Write(txt,' "Дебит*" ');
    7:Write(txt,' "Дебит СФ*" ');
    8:Write(txt,' "Дебит" ');
    9:Write(txt,' "Дебит СФ" ');
    Else;
    End;
  End;
 Writeln(txt);
 Writeln(txt);

 Writeln(txt,Space+'Включены в рассмотрение документы со статусом:');
 Write(txt,Space);
 For c:=1 To 2 Do
  Begin
   If ss[c]=1 Then
    Case c Of
    1:Write(txt,' "Оплаченные" ');
    2:Write(txt,' "Не оплаченные" ');
    Else;
    End;
  End;
 Writeln(txt);
 Writeln(txt);



 Writeln(txt,Space+'Вид сортировки:');
 Write(txt,Space);
    Case Sorting Of
    0:Writeln(txt,' "Клиент" ');
    1:Writeln(txt,' "Сумма отгрузки" ');
    2:If SelectorReport=0 Then Writeln(txt,' "Скидка" ')
      Else Writeln(txt,' "Доходность" ');
    3:Writeln(txt,' "Сумма к оплате" ');
    Else;
    End;
 Writeln(txt);

  AllSumma[0]:=#0;
  AllSummaOtgr[0]:=#0;
  AllSkidka[0]:=#0;


 Writeln(txt,Space+'        СПРАВКА ПО ОБОРОТАМ КЛИЕНТОВ ЗА ПЕРИОД с '+StartDate+' по '+StopDate);
 Writeln(txt,Space+'------------------------------------------------------------------------------------');
 If SelectorReport=0 Then
 Writeln(txt,Space+' N    Клиент                Код  Сумма отгрузки    Сумма скидки  Сумма к оплате Док.')
 Else
 Writeln(txt,Space+' N    Клиент                Код  Сумма отгрузки    Доходность    Сумма к оплате Док.');
 Writeln(txt,Space+'------------------------------------------------------------------------------------');
 For c:=0 To S^.List^.Count-1 Do
 Begin
    ws := S^.GetText(c,S^.List^.Count);
   If StrToInt(Copy(ws,1+CCLient+1+CClientKod+1+CIZena+1+CIZena+1+CIZena+1,CClientKod))>0 Then
   Begin
    Str(StrToReal(AllSummaOtgr)+StrToReal(Copy(ws,1+CCLient+1+CClientKod+1,CIZena)):CIZena:CMantissa,AllSummaOtgr);
    Str(StrToReal(AllSkidka)+StrToReal(Copy(ws,1+CCLient+1+CClientKod+1+CIZena+1,CIZena)):CIZena:CMantissa,AllSkidka);
    Str(StrToReal(AllSumma)+StrToReal(Copy(ws,1+CCLient+1+CClientKod+1+CIZena+1+CIZena+1,CIZena)):CIZena:CMantissa,AllSumma);

    While Pos('│',ws)>0 Do
    Begin
     k:=Pos('│',ws);
     System.Delete(ws,k,1);
     System.Insert(' ',ws,k);
    End;
    Str(c+1:CArtikul,Numer);
    ws:=Numer+' '+ws;
    Writeln(txt,Space+Ws);
   End;
 End;
 Writeln(txt,Space+'------------------------------------------------------------------------------------');
 Writeln(txt,Space+'                                                    Всего отгружено: '+Recogniz(AllSummaOtgr ));
 If SelectorReport=0 Then
 Writeln(txt,Space+'                                                       Всего скидка: '+Recogniz(AllSkidka))
 Else
 Writeln(txt,Space+'                                                        Всего доход: '+Recogniz(AllSkidka));
 Writeln(txt,Space+'                                                     Всего к оплате: '+Recogniz(AllSumma));
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'====================================================================================');


 System.Close(txt);
 NoInfoMsg;
 Report(Path.ToTemp+'coborot.txt','',1,False,False,false);
{$EndIF}


End;

procedure TCalcWindow.HandleEvent(var Event: TEvent);
{
procedure Calculator;
Var Control : PDialog;
begin
  control:=New(PCalculator, Init);
  Desktop^.Execview(Control);
  Dispose(Control,Done);
end;
}
Var t : MAska9;

procedure Calculator;
begin
  Calc^.Start;
end;


Var Test : Word;
    s : string[150];

Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Begin
                     ClearFind;
                        Calculator;
                    End;
        cmView     : if (User[76] or (CurrentPassword='00')) then
	       Begin
                     ClearFind;
                     LocCalc^.Start;
                     PrevCur[0]:=#0;
                    {раскрывающееся подокно}

                    End;
        cmOk       :Begin
                     ClearFind;
                     ClearEvent(Event);
                    End;
     cmReestrReport:if (User[76] or (CurrentPassword='00')) then
	      Begin
                     If (CalcList^.State and sfFocused <> 0) And (CalcList^.List<>Nil)And(CalcList^.List^.Count>=1) Then
                       Begin
                        ClearFind;
                        FormReport(CalcList);
                        PrevCur[0]:=#0;
                       End;
                     ClearEvent(Event);

                    End;
   Else;
   End;
   EvKeyDown       :
       Case Event.KeyCode Of
        {
        Ord('?'): Begin
                    Event.What:=evCommand;
                    Event.Command:=cmLastPrise;
                    PutEvent(Event);
                    ClearEvent(Event);
                  End;
       }
       kbF5 :Begin
              ClearFind;
              Event.What:=EvCommand;
              Event.Command:=cmView;
              PutEvent(Event);
              ClearEvent(Event);
              PrevCur[0]:=#0;
             End;
      Else;
      End;
   Else;
   End;

  if ((Event.What = evMouseDown) and (Event.Double)) And
  ((CalcList^.State and sfFocused <> 0) And (CalcList^.List<>Nil)And(CalcList^.List^.Count>=1))Then
  begin
    Event.What:=evCommand;
    Event.Command:=cmView;
    PutEvent(Event);
    ClearEvent(Event);
    PrevCur[0]:=#0;
  end;




inherited HandleEvent(Event);


  If (Desktop^.Current=PView(CalcWindow)) And (Event.What <> EvKeyDown) Then
  Begin

              if {(CalcList^.State and sfFocused <> 0)  And}(CalcList^.List<>Nil) And (CalcList^.List^.Count>=1)Then
              Begin
               s:=CalcList^.GetText(CalcList^.Focused,CalcList^.List^.Count);
               If s <> Reiting Then
                 Begin
                  FreshReiting;
                 End
              End;


                if (sControlSort^.State and sfFocused <> 0)Then
                    Begin
                        sControlSort^.GetData(Test);
                        If Test <> Sorting Then
                        Begin
                           ClearFind;
                           Sorting:=Test;
                           Refresh;
                           Redraw;
                           Reiting[0]:=#0;
                        End;
                    End;

                if (sControlVidSort^.State and sfFocused <> 0)Then
                    Begin
                        sControlVidSort^.GetData(Test);
                        If Test <> VidSorting Then
                        Begin
                           ClearFind;
                           VidSorting:=Test;
                           Refresh;
                           Redraw;
                           Reiting[0]:=#0;
                        End;
                    End;
  End;


ClearEvent(Event);
End;


Procedure TCalcWindow.FreshReiting;
VAr R :TRect;
    s : ArtikulStr;
    ws : ArtikulStr;
Begin
If (CalcList^.List^.Count>=1) Then
Begin
Dispose(SControlReiting,Done);
R.Assign(57, 1, 62, 2);
Reiting:=CalcList^.GetText(CalcList^.Focused,CalcList^.List^.Count);
Str((CalcList^.Focused+1):Ckol,s);
DelSpace(s);
SControlReiting := New(PColoredText, Init(R, #3+s, $4E));
CalcWindow^.Insert(SControlReiting);
Redraw;
End;
End;



Destructor TCalcWindow.Done;
Begin
Dispose(SControlSort,Done);
Dispose(SControlVidSort,Done);
Dispose(SControlReiting,Done);
TDialog.Done;
End;


Procedure TLocCalcWindow.Start;
Var R : TRect;
    Res,C : Word;
    Control : PView;
    Cur,Min,Max,k,j : LongInt;
    ws,s : string[150];
    Es : PStatClientType;
    Esf : File Of StatClientType;
    SummaOtgr,Summa,Skidka:String[CIZena];
    ClientKod,SDoc : String[CClientKod];
    Add , Find : Boolean;
    Er : PRealizasiaType;
    Ef : File Of RealizasiaType;
Begin

ClientKod:=Copy(CalcList^.GetText(CalcList^.Focused,CalcList^.List^.Count),1+CClient+1,CClientKod);
s:=GetClientField(FClient,ClientKod,0);
DelSpaceRight(ws);

R.Assign(0, 0, 80, 23);
New(LocCalcWindow, Init(R, 'Обороты клиента '+s+' ('+ClientKod+') с '+StartDAte+' по '+StopDate));
LocCalcWindow^.Options := LocCalcWindow^.Options or ofCenterX or ofCenterY;
LocCalcWindow^.HelpCtx:=$E618;

TekDate:=FDate;

R.Assign(79, 2, 80, 18);
Control := New(PScrollBar, Init(R));
LocCalcWindow^.Insert(Control);

R.Assign(1, 2, 79, 18);
LocCalcList := New(PBox, Init(R, 1, PScrollbar(Control)));
LocCalcList^.NewList(New(PMyCollection, Init(0,1)));
  Min:=DateStringToDate(DateMask,StartDate);
  Max:=DateStringToDate(DateMask,StopDate);


 Assign(Esf,Path.ToClient+ClientKod+'.his');
 j:=IOResult;
 Reset(Esf);
 j:=IOResult;

  AllSumma[0]:=#0;
  AllSummaOtgr[0]:=#0;
  AllSkidka[0]:=#0;

 If j=0 Then
Begin
AInfo('Минуточку...');
Cur:=0;
 New(Es,Init);
 While Not(Eof(Esf)) Do
  Begin
   Read(Esf,Es^.Dat);
   If (Es^.DAt.Active) And Not(TestElement(Es^.Dat.AgentKod,SelectAgent)) Then
Begin
   Cur := DateStringToDate(DateMask,Es^.Dat.DateC);

   If (Cur>=Min)And(Cur<=MAx) Then
   Begin

(*   If (Es^.Dat.DocSelector=5) And (Es^.Dat.Sf) Then Inc(Es^.Dat.DocSelector);{Дебит С/Ф}*)

   If mm[Es^.Dat.DocSelector+1]=1 Then{фильтр документов}
    Begin
        RFormatZerro(Es^.Dat.Document,CDocNumer);
        Str(StrToReal(Es^.Dat.SummaZ):CIZena:CMantissa,Es^.Dat.SummaZ);
        Str(StrToReal(Es^.Dat.Skidka):CIZena:CMantissa,Es^.Dat.Skidka);
        s:=GetOperatorName(Es^.Dat.Caption);
        Format(s,CKto);
        s:='│'+Es^.Dat.Document+'│'+Es^.Dat.DateC+'│'+Es^.Dat.TimeC+'│'+Es^.Dat.SummaZ+'│'+
        Es^.Dat.Skidka+'│'+s+'│'+Es^.Dat.DateM+'│'+Es^.Dat.TimeM+'│';

        Str(Es^.Dat.DocSelector:1,ws);{вид документа}
        s:=s+ws+'│';

        Str(Es^.Dat.sKIDKASelector:1,ws);{скидка }
        s:=s+ws+'│';


        If Es^.Dat.DocSelector in [4,8] Then ws:='0'{Б/Н}
           Else ws:='1';{нал}

        s:=s+ws+'│';

        DelSpace(Es^.Dat.Bn.Date);
        Format(Es^.Dat.bn.Date,CDate);

        s:=s+Es^.Dat.bn.Date+'│';

        DelSpace(Es^.Dat.Bn.NPlat);
        Format(Es^.Dat.bn.NPlat,10);

        s:=s+Es^.Dat.bn.NPlat+'│';

        DelSpace(Es^.Dat.Bn.Summa);
        Format(Es^.Dat.bn.Summa,CIZena);

        s:=s+Es^.Dat.bn.Summa+'│';

        DelSpaceRight(Es^.Dat.Bn.Bank);
        Format(Es^.Dat.bn.Bank,CAll);

        s:=s+Es^.Dat.bn.Bank+'│';

        If Es^.Dat.DocSelector in [0,1,2,3,4] Then
        Begin
          ws:='1';
        End
        Else
         Begin
          DelZerro(Es^.Dat.Document);
          DelSpace(Es^.Dat.Document);

          Assign(ef,Path.ToDolg+ClientKod+'.dlg');
          Res:=IOResult;
          Reset(Ef);
          Res:=IOResult;
          If Res<>0 Then
           Begin
            MessageBox(^M+#3'Ошибка доступа к файлу долгов клиента!',Nil,mfError+mfCancelButton);
            ws:='0';
           End
          Else
          Begin
          New(er,Init);
          Find:=False;
          While Not(Eof(ef)) And Not(Find) Do
           Begin
            Read(Ef,er^.Dat);
            If (ClearChar(Er^.Dat.Market.Document)=Es^.Dat.Document)
		  And (Er^.Dat.Market.DateC=Es^.Dat.DateC)
		  And (Er^.Dat.Market.Active) Then
                Begin
                 Find:=True;

                 If Er^.Dat.Full Then ws:='1'
                 Else ws:='2';
                End;
           End;
          Dispose(Er,Done);
          System.Close(Ef);
          If Not(Find) Then
           Begin
            MessageBox(^M+#3'Документ не найден в долгах клиента!',Nil,mfError+mfCancelButton);
            ws:='0';
           End
          End;{Res=0 файл успешно открыт}
         End;{Res если реализация}


        s:=s+ws+'│'+Es^.Dat.AgentKod+'│';



        ws:=Copy(s,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+COne+1+COne+1+CDate+1+
        10+1+CIZena+1+CAll+1,COne);


     If StrToInt(ws)>0 Then
     If ss[StrToInt(ws)]=1 Then
     Begin
        Str(StrToReal(AllSumma)+StrToReal(Es^.Dat.SummaZ):CIZena:CMantissa,AllSUmma);
        Str(StrToReal(AllSkidka)+StrToReal(Es^.Dat.Skidka):CIZena:CMantissa,AllSkidka);
{       If LocCalcList^.List^.Count>0 Then
        For j:=0 To LocCalcList^.List^.Count-1 Do
         Begin
          ws:=LocCalcList^.GetText(j,LocCalcList^.List^.Count);
          If ws=s Then
           Begin
            MessageBox(#3+'Дубликат!',Nil,Mferror+mfCancelButton);
           End;
         End;
}
        LocCalcList^.List^.Insert(NewStr(s));
        LocCalcList^.SetRange(LocCalcList^.List^.Count);
     End;
    End;{Auto or Not(Auto)}
   End;{конец фильтра документов}
End;{Active}
  End;{While}

 Dispose(Es,Done);

 System.Close(Esf);

 End{If}
 Else
  Begin
   MessageBox(^M+#3+'Не могу открыть файл '+Path.ToClient+ClientKod+'.his'+'!',Nil,mfError+mfCancelButton);
  End;


  Str(StrToReal(AllSumma):CIZena:CMantissa,AllSumma);
  Str(StrToReal(AllSkidka):CIZena:CMantissa,AllSkidka);



LocCalcList^.HelpCtx:=$E618;
LocCalcList^.FocusItem(0);
LocCalcWindow^.Insert(LocCalcList);

  R.Assign(2, 1, 78, 2);
  LocCalcWindow^.Insert(New(PLabel, Init(R, ' N    Дата    Время    Сумма к оплате      Скидка       Оператор    Дата изм',
  LocCalcList)));


R.Assign(33, 18, 60, 19);
sControlAgent := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlAgent);

R.Assign(24, 18, 33, 19);
Control := New(PColoredText, Init(R, 'Доставка:', $71));
LocCalcWindow^.Insert(Control);



R.Assign(2, 19, 9, 20);
Control := New(PColoredText, Init(R, 'Расчет:', $71));
LocCalcWindow^.Insert(Control);

R.Assign(9, 19, 12, 20);
SControlRashet := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlRashet);

R.Assign(14, 19, 25, 20);
Control := New(PColoredText, Init(R, 'Вид док-та:', $71));
LocCalcWindow^.Insert(Control);

R.Assign(25, 19, 34, 20);
sControlVidDoc := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlVidDoc);

R.Assign(36, 19, 43, 20);
Control := New(PColoredText, Init(R, 'Скидка:', $71));
LocCalcWindow^.Insert(Control);

R.Assign(43, 19, 49, 20);
sControlSkidka := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlSkidka);

R.Assign(2, 20, 29, 21);
Control := New(PColoredText, Init(R, 'Время последнего изменения:', $71));
LocCalcWindow^.Insert(Control);

R.Assign(29, 20, 37, 21);
sControlTimeM := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlTimeM);

R.Assign(9, 21, 18, 22);
Control := New(PColoredText, Init(R, 'Дата п/п:', $74));
LocCalcWindow^.Insert(Control);

R.Assign(18, 21, 26, 22);
sControlDatePP := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlDatePP);

R.Assign(39, 20, 44, 21);
Control := New(PColoredText, Init(R, 'Банк:', $74));
LocCalcWindow^.Insert(Control);

R.Assign(44, 20, 79, 21);
sControlBank := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlBank);

R.Assign(29, 21, 35, 22);
Control := New(PColoredText, Init(R, 'N п/п:', $74));
LocCalcWindow^.Insert(Control);

R.Assign(35, 21, 45, 22);
sControlNPP := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlNPP);

R.Assign(48, 21, 58, 22);
Control := New(PColoredText, Init(R, 'Сумма п/п:', $74));
LocCalcWindow^.Insert(Control);

R.Assign(58, 21, 73, 22);
sControlSummaPP := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlSummaPP);

R.Assign(51, 19, 68, 20);
Control := New(PColoredText, Init(R, 'Статус документа:', $71));
LocCalcWindow^.Insert(Control);

R.Assign(68, 19, 79, 20);
sControlStatus := New(PColoredText, Init(R, #3+'???', $FE));
LocCalcWindow^.Insert(sControlStatus);

R.Assign(47, 22, 63, 23);
Control := New(PColoredText, Init(R, ' Итого к оплате:', $74));
LocCalcWindow^.Insert(Control);

R.Assign(63, 22, 79, 23);
DelSpace(AllSumma);
sControlItogo := New(PColoredText, Init(R, #3+AllSumma, $4E));
LocCalcWindow^.Insert(sControlItogo);

R.Assign(17, 22, 31, 23);
Control := New(PColoredText, Init(R, ' Итого скидка:', $74));
LocCalcWindow^.Insert(Control);

R.Assign(31, 22, 47, 23);
DelSpace(AllSkidka);
sControlItogoSkidka := New(PColoredText, Init(R, #3+AllSkidka, $4E));
LocCalcWindow^.Insert(sControlItogoSkidka);

R.Assign(1, 22, 12, 23);
Control := New(PColoredText, Init(R, 'Документов:', $74));
LocCalcWindow^.Insert(Control);

R.Assign(12, 22, 17, 23);
Str(LocCalcList^.List^.Count:CClientKod,ws);
DelSpace(ws);
sControlDoc := New(PColoredText, Init(R, #3+ws, $4E));
LocCalcWindow^.Insert(sControlDoc);

LocCalcWindow^.SelectNext(False);
PrevCur[0]:=#0;

NoInfo;

c:=Desktop^.ExecView(LocCalcWindow);

Dispose(Control,Done);
LocCalcList^.NewList(Nil);
Dispose(LoccalcList,Done);
Dispose(LocCalcWindow,Done);
PrevCur[0]:=#0;

End;


Procedure TLocCalcWindow.FormReport(Spis:PBox);
Const Space=' ';
Var Txt : Text;
    k,c : Word;
    st,s,ws : string[150];
    TempS : AllStr;
    Numer : ArtikulStr;
    R : TRect;
    Clientkod : String[cclientkod];

Begin
{$IFDEF DPMI}
 Assign(txt,Path.ToTemp+'lperson.txt');
 c := IOResult;
 Rewrite(txt);
 c:=IoResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3+'Не могу создать файл '+Path.ToTemp+'lperson.txt!',Nil,mfError+mfCancelButton);
   Exit;
  End;
 DInfoMsg('Формирую отчет. Ждите...');
 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');
 Writeln(txt,Space+'Включены в рассмотрение следующие виды документов:');
 Write(txt,Space);

 WordTobit9(Filtr,mm);
 Convert9(mm);

 WordToBit2(Oplata,ss);
 Convert2(ss);

 For c:=1 To Max9{CDivision+1} Do
  Begin
   If mm[c]=1 Then
    Case c Of
    1:Write(txt,' "Список" ');
    2:Write(txt,' "Тов.Чек*" ');
    3:Write(txt,' "Физ.Л*" ');
    4:Write(txt,' "СФ*" ');
    5:Write(txt,' "СФ " ');
    6:Write(txt,' "Дебит*" ');
    7:Write(txt,' "Дебит СФ*" ');
    8:Write(txt,' "Дебит" ');
    9:Write(txt,' "Дебит СФ" ');
    Else;
    End;
  End;
 Writeln(txt);
 Writeln(txt);

 Writeln(txt,Space+'Включены в рассмотрение документы со статусом:');
 Write(txt,Space);
 For c:=1 To 2 Do
  Begin
   If ss[c]=1 Then
    Case c Of
    1:Write(txt,' "Оплаченные" ');
    2:Write(txt,' "Не оплаченные" ');
    Else;
    End;
  End;
 Writeln(txt);
 Writeln(txt);


 ws:=GetClientField(FClient,LastClientKod,0);
 DelSpaceRight(ws);

 Writeln(txt,Space+' СПРАВКА ПО ОБОРОТАМ КЛИЕНТА: '+ws+' ('+lastClientKod+') ЗА ПЕРИОД с '+StartDate+' по '+
 StopDate);
 Writeln(txt,Space+'---------------------------------------------------------------------------------------------');
 Writeln(txt,Space+'  N     Дата     Время   Сумма к оплате          Скидка Оператор     Рас.Вид док.  Статус');
                    {1234 12345678 12345678 123456789012345 123456789012345 123456789012 нал дебит с/ф не оплачен}
 Writeln(txt,Space+'---------------------------------------------------------------------------------------------');

If Spis^.List^.Count>0 Then
Begin
 For c:=0 To Spis^.List^.Count-1 Do
 Begin
    ws := Spis^.GetText(c,Spis^.List^.Count);
    s:= ws;
    TempS:=Copy(ws,Ord(ws[0])-CClientKod,CClientKod);
    While Pos('│',ws)>0 Do
    Begin
     k:=Pos('│',ws);
     System.Delete(ws,k,1);
     System.Insert(' ',ws,k);
    End;
    ws[0]:=Chr(1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto);


    st:=Copy(s,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+COne+1,COne);
    {Вид расчета}
    Case StrToInt(st) Of
    1:st:='Нал';
    0:st:='Б/Н';
    Else st:='???';
    End;
    Format (St,3);
    ws:=ws+' '+st;

    st:=Copy(s,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1,COne);
    {Вид документа}
    Case StrToInt(st) Of
    0:st:='Список';
    1:st:='Тов.Чек*';
    2:st:='Физ.Л*';
    3:st:='СФ*';
    4:st:='СФ ';
    5:st:='Дебит*';
    6:st:='Дебит СФ*';
    7:st:='Дебит';
    8:st:='Дебит СФ';
    Else St:='???';
    End;
    Format (St,9);
    ws:=ws+' '+st;

    st:=Copy(s,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+
    COne+1+COne+1+CDate+1+10+1+CIZena+1+CAll+1,COne);
    Case StrToInt(st) Of
     2:st:='не оплачен';
     1:st:='оплачен';
     0:st:='????';
     Else st:='????';
     End;
    Format (St,10);
    ws:=ws+' '+st;
    TempS:=GetAgentField(FClient,TempS);
    DelSpaceRight(TempS);
    Format(TempS,CClient);
    Writeln(txt,Space+'Доставка: '+TempS);
    Writeln(txt,Space+Ws);
 End;
End;


 Writeln(txt,Space+'---------------------------------------------------------------------------------------------');

 PStaticText(sControlItogo)^.GetText(wS);
 System.Delete(wS,1,1);
 delspace(ws);
 Str(StrToReal(ws):CIZena:CMantissa,ws);

 PStaticText(sControlItogoskidka)^.GetText(S);
 System.Delete(S,1,1);
 delspace(s);
 Str(StrToReal(s):CIZena:CMantissa,s);

 Writeln(txt,Space,' Всего документов: ',Spis^.List^.Count:5,'   Всего к оплате: ',ws,+'   Всего скидка: ',s);

 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'=============================================================================================');
 System.Close(txt);
 NoInfoMsg;
 Report(Path.ToTemp+'lperson.txt','',1,False,False,false);
{$EndIF}

End;




Procedure TLocCalcWindow.FullPreview;
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
If (LocCalcList^.List<>Nil)And(LocCalcList^.List^.Count>0) Then
Begin
  Ass.EditPosition:=Copy(LocCalcList^.GetText(LocCalcList^.Focused,LocCalcList^.List^.Count),1+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(LocCalcList^.GetText(LocCalcList^.Focused,LocCalcList^.List^.Count),1+1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  Assign(f,Path.ToMarket+Ass.d+'.mrk');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
  Begin
   MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path.ToMarket+Ass.d+'.mrk',Nil,mfError+mfCancelButton);
   Exit;
  End;
  AInfo('Ищу документ...');
  New(E,Init);
  Find := False;
  ClearChar(Ass.EditPosition);
  While Not(Eof(f)) And Not(Find) Do
   Begin
     {
     Repeat
     Until NetCall.Lock(f,FilePos(f)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMarket(f,E);
     {
     Repeat
      NetCall.UnLock(f,(FilePos(f)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
    ClearChar(E^.Dat.Document);
    If (E^.Dat.Active) And (E^.Dat.DateC=Ass.D) and
    (E^.Dat.Document=Ass.EditPosition) Then
                Begin
                 Find:=True;
                 Break;
                End;
   End;
   System.Close(f);
   If Find Then
    Begin
R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));
For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.MarketElement[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,CName);
  s:=s+'│'+ws+'│';
  Str(E^.Dat.MarketElement[c].Input.DivisionSNumber:1,ws);
  s:=s+ws;
  DelSpace(E^.Dat.MarketElement[c].Input.Kol);
  Format(E^.Dat.MarketElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Kol;
  {
  ws:=GetIdField(FLitr,E^.Dat.MarketElement[c].BazKod);
  Format(Ws,CLitr);
  s:=s+'│'+ws;
  }
  DelSpace(E^.Dat.MarketElement[c].Input.Zena);
  Format(E^.Dat.MarketElement[c].Input.Zena,CZena);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Zena;


      Case E^.Dat.SkidkaSelector Of
      0:Begin{скидка автоматическая}
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
         (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         {форматируем проценты}
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Proz):CZena:CMantissa,ws1);
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Skidka):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
        (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100)):CZena:CMantissa,wspomSkidka);


{        S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';}
        S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║'+E^.Dat.MarketElement[c].Input.Zena+'│';


        End;
      2:Begin{скидка ручная по шкалам}
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
         (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         {форматируем проценты}
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Proz):CZena:CMantissa,ws1);
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Skidka):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
        (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100)):CZena:CMantissa,wspomSkidka);

         S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      1:Begin{скидка ручная}

           If StrToReal(E^.Dat.MarketElement[c].Input.Skidka)>=0 Then
           Begin
          {
          Str(((StrToReal(E^.Dat.MarketElement[c].Input.Zena))/((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
          StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))-1)*100
          :CZena:CLitrMantissa,ws1);}
          If (StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka))>0.009 Then
          Str(((StrToReal(E^.Dat.MarketElement[c].Input.Zena))/((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
          StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))-1)*100
          :CZena:CLitrMantissa,ws1)
          Else ws1:='100.00';


          Str(StrToReal(Ws1){*100}:CZena:CMantissa,ws1);
           End
           Else
             Begin
              Str((-(Abs(StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))/
              ((StrToReal(E^.Dat.MarketElement[c].Input.Zena)))*100):CZena:CMantissa,Ws1);
             End;

          Str(StrToReal(E^.Dat.MarketElement[c].Input.Skidka):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

          Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka))
         :CZena:CMantissa,wspomskidka);

          S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║'+E^.Dat.MarketElement[c].Input.Zena+'│';
        End;
      Else;
      End;{E^.Dat.SkidkaSelector}

(*
      0:Begin{скидка автоматическая}
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
         (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         {форматируем прценты}
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Proz):CZena:CMantissa,ws1);
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Skidka):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
        (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100)):CZena:CMantissa,wspomSkidka);

         S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      1:Begin{скидка ручная}

           If StrToReal(E^.Dat.MarketElement[c].Input.Skidka)>0 Then
           Begin
          Str(((StrToReal(E^.Dat.MarketElement[c].Input.Zena))/((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
          StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))-1)
          :CZena:CLitrMantissa,ws1);

          Str(StrToReal(Ws1)*100:CZena:CMantissa,ws1);
           End
           Else
             Begin
              Str((-(Abs(StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))/
              ((StrToReal(E^.Dat.MarketElement[c].Input.Zena)))*100):CZena:CMantissa,Ws1);
             End;

          Str(StrToReal(E^.Dat.MarketElement[c].Input.Skidka):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

          Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka))
         :CZena:CMantissa,wspomskidka);

          S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      Else;
      End;{E^.Dat.SkidkaSelector}

*)


{ DelSpace(E^.Dat.MarketElement[c].Input.Skidka);
  Format(E^.Dat.MarketElement[c].Input.Skidka,CZena);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Skidka;}

 {DelSpace(E^.Dat.MarketElement[c].Input.Itogo);
  Format(E^.Dat.MarketElement[c].Input.Itogo,CInputIZena);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Itogo;}



  P^.List^.Insert(NewStr(s));
  P^.SetRange(P^.List^.Count);
 End;
 Case E^.Dat.SkidkaSelector Of
 0: ws:=' (Авто)';
 1: ws:=' (Ручная)';
 2: ws:=' (Шкала '+IntToStr(E^.Dat.ShkalaNumer,COne)+')';
 Else;
 End;
P^.FocusItem(0);

s:=E^.Dat.SummaZ;
DelSpace(s);
s:=' К оплате: '+s;
DelSpace(E^.Dat.Skidka);
s:=s+' Всего скидка'+ws+': '+E^.Dat.Skidka;
E^.Dat.ENalog:=RealToStr(StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka){-StrToReal(E^.Dat.ENalog)},CIZena,CMantissa);
DelSpace(E^.Dat.ENalog);
s:=s+' Со склада:'+E^.Dat.ENalog;

SDoc:=E^.Dat.Document;
SDate:=E^.Dat.DateC;

Dispose(E,Done);

ProdagaWindow:=True;
NoInfo;
                   {Вставить номер и дату документа в просмотре}

FullScreen(P,' Код  Выбранн~ы~е товары           N Колич Цена лоб Цена опл  Скидка   Процент',s,
             { 12345│12345678901234567890123456│1│12345│12345678│12345│12345678│12345678}
SDoc,SDAte,0);
ProdagaWindow:=False;

Dispose(P,Done);
    End
Else
  Begin
  NoInfo;
  MessageBox(#3^M+#3'Документ не найден!',Nil,mfError+mfCancelButton);
  Dispose(E,Done);
  End;
End;
End;


procedure TLocCalcWindow.DrawCurrent;
Var R : TRect;
    st : string[150];
    TempS: AllStr;
    ClientKod : ArtikulStr;
    SDoc,SDate : TDateString;
    er : PRealizasiaType;
    ef : File Of RealizasiaType;
    j : Word;
    Find : Boolean;

Begin
If (LocCalcList^.List<>Nil)And(LocCalcList^.List^.Count>0)  Then
 Begin
  st:=LocCalcList^.GetText(LocCalcList^.Focused,LocCalcList^.List^.Count);
  If St <> PrevCur Then
   Begin
    PrevCur:=St;

    st:=Copy(PrevCur,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1,COne);
    {Вид документа}
{
    If StrToInt(st) in [5,6] Then EnableCommands([cmLocalInfo])
    Else DisableCommands([cmLocalInfo]);
}
    Case StrToInt(st) Of
    0:st:='Список';
    1:st:='Тов.Чек*';
    2:st:='Физ.Л*';
    3:st:='СФ*';
    4:st:='СФ ';
    5:st:='Дебит*';
    6:st:='Дебит СФ*';
    7:st:='Дебит';
    8:st:='Дебит СФ';
    Else St:='???';;
    End;
        Dispose(sControlVidDoc,Done);
        R.Assign(25, 19, 34, 20);
        sControlVidDoc := New(PColoredText, Init(R, #3+st, $7E));
        LocCalcWindow^.Insert(sControlVidDoc);


    st:=Copy(PrevCur,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1,COne);
    {Вид скидки}
    Case StrToInt(st) Of
    0:st:='Авто';
    1:st:='Ручная';
    2:st:='Шкала';
    Else st:='???';
    End;
        Dispose(sControlSkidka,Done);
        R.Assign(43, 19, 49, 20);
        sControlSkidka := New(PColoredText, Init(R, #3+St, $7E));
        LocCalcWindow^.Insert(sControlSkidka);

    st:=Copy(PrevCur,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+COne+1,COne);
    {Вид расчета}
    Case StrToInt(st) Of
    1:st:='Нал';
    0:st:='Б/Н';
    Else st:='???';
    End;
        Dispose(sControlRashet,Done);
        R.Assign(9, 19, 12, 20);
        sControlRashet := New(PColoredText, Init(R, #3+st, $7E));
        LocCalcWindow^.Insert(sControlRashet);


    st:=Copy(PrevCur,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+COne+1+COne+1,CDate);
    {Дата п/п}
        Dispose(sControlDatePP,Done);
        R.Assign(18, 21, 26, 22);
        sControlDatePP := New(PColoredText, Init(R, #3+st, $7E));
        LocCalcWindow^.Insert(sControlDatePP);

    st:=Copy(PrevCur,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+COne+1+COne+1+CDate+1,
    10);
    DelSpace(st);
    {номер п/п}
        Dispose(sControlNPP,Done);
        R.Assign(35, 21, 45, 22);
        sControlNPP := New(PColoredText, Init(R, #3+st, $7E));
        LocCalcWindow^.Insert(sControlNPP);

    st:=Copy(PrevCur,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+COne+1+COne+1+CDate+1+
    10+1,CIZena);
    DelSpace(st);
    {сумма п/п}
        Dispose(sControlSummaPP,Done);
        R.Assign(58, 21, 73, 22);
        sControlSummaPP := New(PColoredText, Init(R, #3+st, $7E));
        LocCalcWindow^.Insert(sControlSummaPP);

    st:=Copy(PrevCur,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+COne+1+COne+1+CDate+1+
    10+1+CIZena+1,CAll);
    DelSpaceRight(st);
    {сумма п/п}
        Dispose(sControlBank,Done);
        R.Assign(44, 20, 79, 21);
        sControlBank := New(PColoredText, Init(R, #3+st, $7E));
        LocCalcWindow^.Insert(sControlBank);


        Dispose(sControlStatus,Done);
        R.Assign(68, 19, 79, 20);
        st:=Copy(PrevCur,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1+COne+1+
           COne+1+COne+1+CDate+1+
        10+1+CIZena+1+CAll+1,COne);

        Case StrToInt(st) Of
        2:st:='не оплачен!';
        1:st:='оплачен';
        0:st:='???';
        Else st:='???';
        End;
        sControlStatus := New(PColoredText, Init(R, #3+st, $7E));
        LocCalcWindow^.Insert(sControlStatus);

     Dispose(sControlTimeM,Done);
     st:=Copy(PrevCur,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1,CDate);
     R.Assign(29, 20, 37, 21);
     sControlTimeM := New(PColoredText, Init(R, #3+st, $7E));
     LocCalcWindow^.Insert(sControlTimeM);

     Dispose(sControlAgent,Done);
     st:=Copy(PrevCur,Ord(PrevCur[0])-CClientKod,CClientKod);
     TempS:=GetAgentField(FClient,st);
     Format(TempS,CClient);
     R.Assign(33, 18, 65, 19);
     SControlAgent := New(PColoredText, Init(R, TempS+'('+st+')', $7E));
     LocCalcWindow^.Insert(SControlAgent);



(*
        st:=Copy(PrevCurrent,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1,COne);
        If StrToInt(st) in [0,1,2,3,4] Then
        Begin
          st:='оплачен';
          sControlStatus := New(PColoredText, Init(R, #3+st, $7E));
        End
        Else
         Begin
          SDoc:=Copy(PRevCurrent,1+1,CDocNumer);
          DelZerro(Sdoc);
          DelSpace(Sdoc);
          SDate:=Copy(PRevCurrent,1+1+CDocNumer+1,CDAte);

          PStaticText(sControlClient)^.GetText(st);
          System.Delete(St,1,1);
          ClientKod:=Copy(st,1+CClient+1,CClientKod);

          Assign(ef,Path.ToDolg+ClientKod+'.dlg');
          j:=IOResult;
          Reset(Ef);
          j:=IOResult;
          If j<>0 Then
           Begin
            MessageBox(^M+#3'Ошибка доступа к файлу долгов клиента!',Nil,mfError+mfCancelButton);
            st:='??????';
            sControlStatus := New(PColoredText, Init(R, #3+st, $FE));
           End
          Else
          Begin
          New(er,Init);
          Find:=False;
          While Not(Eof(ef)) And Not(Find) Do
           Begin
            Read(Ef,er^.Dat);
            If (ClearChar(Er^.Dat.Market.Document)=SDoc)
		  And(Er^.Dat.Market.DateC=SDate)
		  And (Er^.Dat.Market.Active) Then
                Begin
                 Find:=True;
                 If Er^.Dat.Full Then st:='оплачен'
                 Else st:='не оплачен!';
                End;
           End;
          Dispose(Er,Done);
          System.Close(Ef);
          If Not(Find) Then
           Begin
            MessageBox(^M+#3'Документ не найден в долгах клиента!',Nil,mfError+mfCancelButton);
            st:='??????';
            sControlStatus := New(PColoredText, Init(R, #3+st, $FE));
           End
           Else
           Begin
            sControlStatus := New(PColoredText, Init(R, #3+st, $7E));
           End

          End;{j=0 файл успешно открыт}



         End;{Else если реализация}

        Insert(sControlStatus);
        *)

   Redraw;
   End;

 End

 Else
  Begin

PrevCur[0]:=#0;

Dispose(sControlRashet,Done);
R.Assign(9, 19, 12, 20);
sControlRashet := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlRashet);

Dispose(sControlVidDoc,Done);
R.Assign(25, 19, 34, 20);
sControlVidDoc := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlVidDoc);

Dispose(sControlSkidka,Done);
R.Assign(43, 19, 49, 20);
sControlSkidka := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlSkidka);

Dispose(sControlDatePP,Done);
R.Assign(18, 21, 26, 22);
sControlDatePP := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlDatePP);

Dispose(sControlBank,Done);
R.Assign(44, 20, 79, 21);
sControlBank := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlBank);

Dispose(sControlNPP,Done);
R.Assign(35, 21, 45, 22);
sControlNPP := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlNPP);

Dispose(sControlSummaPP,Done);
R.Assign(58, 21, 73, 22);
sControlSummaPP := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlSummaPP);

Dispose(sControlStatus,Done);
R.Assign(68, 19, 79, 20);
sControlStatus := New(PColoredText, Init(R, #3+'???', $FE));
LocCalcWindow^.Insert(sControlStatus);

Dispose(sControlTimeM,Done);
R.Assign(29, 20, 37, 21);
sControlTimeM := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcWindow^.Insert(sControlTimeM);

Redraw;
  End;
End;




procedure TLocCalcWindow.HandleEvent(var Event: TEvent);
{
procedure Calculator;
Var Control : PDialog;
begin
  control:=New(PCalculator, Init);
  Desktop^.Execview(Control);
  Dispose(Control,Done);
end;
}

procedure Calculator;
begin
  Calc^.Start;
end;

Var Test : Word;
    s,s1 : string[150];
    ClientKod : ArtikulStr;
    R : TRect;


Begin
Case Event.What Of
 evKeyDown :
  Case Event.KeyCode Of
          {
          Ord('?'): Begin
                    Event.What:=evCommand;
                    Event.Command:=cmLastPrise;
                    PutEvent(Event);
                    ClearEvent(Event);
                    End;
          }
          Ord('!'): Begin
                    Event.What:=evCommand;
                    Event.Command:=cmAnalysFromPeriod;
                    PutEvent(Event);
                    ClearEvent(Event);
                    End;
          kbAltRusK: Begin
                    Event.What:=evCommand;
                    Event.Command:=cmLocalCalc;
                    PutEvent(Event);
                    ClearEvent(Event);
                    End;
  Else;
  End;

 evCommand :
   Case Event.Command Of
        cmLocalCalc:Begin
                     ClearFind;
                        Calculator;
                    End;
  cmPrintReestr:    Begin
        If (LocCalcList^.State and sfFocused <> 0) And (LocCalcList^.List<>Nil)And(LocCalcList^.List^.Count>=1) Then
                  Begin
                         ClearFind;
                         Assistent.EditPosition:=Copy(LocCalcList^.GetText(LocCalcList^.Focused,LocCalcList^.List^.Count),
                                        1+1,CDocNumer);
                         DelSpace(Assistent.EditPosition);
                         DelZerro(Assistent.EditPosition);
                         Assistent.D:=Copy(LocCalcList^.GetText(LocCalcList^.Focused,LocCalcList^.List^.Count),
                                        1+1+CDocNumer+1,CDate);
                         DelSpace(Assistent.D);
                         PrintNakl(Assistent,NPrint.CopyNkl);
                         ClearEvent(Event);
                  End
                  End;
  cmAnalysFromPeriod :Begin
        If (LocCalcList^.State and sfFocused <> 0) And (LocCalcList^.List<>Nil)And(LocCalcList^.List^.Count>=1) Then
                   Begin
                    ClearFind;
                    s:=CalcList^.GetText(CalcList^.Focused,CalcList^.List^.Count);
                    ClientKod:=Copy(s,1+CClient+1,CClientKod);
                    LastClientKod:=ClientKod;
                    Analys^.Start(ClientKod);
                   End;
                  End;


  cmFullView:    Begin
        If (LocCalcList^.State and sfFocused <> 0) And (LocCalcList^.List<>Nil)And(LocCalcList^.List^.Count>=1) Then
                  Begin
                    ClearFind;
                    FullPreview;
                  End;
                  ClearEvent(Event);
                 End;
{
        cmLastPrise : Begin
        If (LocCalcList^.State and sfFocused <> 0) And (LocCalcList^.List<>Nil)And(LocCalcList^.List^.Count>=1) Then
                      Begin
                       ClearFind;
                       s:=CalcList^.GetText(CalcList^.Focused,CalcList^.List^.Count);
                       ClientKod:=Copy(s,1+CClient+1,CClientKod);
                       LastClientKod:=ClientKod;
                       LastInfoZena^.Start(LocCalcList);
                      End;
                      End;
}
        cmOk       :Begin
                     ClearFind;
                     ClearEvent(Event);
                    End;
        cmLocalInfo: Begin
        If (LocCalcList^.State and sfFocused <> 0) And (LocCalcList^.List<>Nil)And(LocCalcList^.List^.Count>=1) Then
            Begin
                 ClearFind;
                 s1:=Copy(PrevCur,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+CDate+1,COne);
                 {Вид документа}
                 If StrToInt(s1) in [5,6,7,8] Then
                 Begin
                 ClientKod:=Copy(CalcList^.GetText(CalcList^.Focused,CalcList^.List^.Count),1+CClient+1,CClientKod);
                 s:=LocCalcList^.GetText(LocCalcList^.Focused,LocCalcList^.List^.COunt);
                 PrevCur[0]:=#0;
                 LockInfo^.LockStart(s,ClientKod);
                 End
                 Else
                  MessageBox(^M+#3+'Вы пытаетесь просмотреть историю оплаты по документу НЕ КОНСИГНАЦИИ!!!',Nil,
                  mfError+mfCancelButton);

            End;
                  ClearEvent(Event);
                          End;

     cmReestrReport:Begin
                     If (LocCalcList^.State and sfFocused <> 0) And (LocCalcList^.List<>Nil)And(LocCalcList^.List^.Count>=1)
                                 Then
                       Begin
                        ClearFind;
                        s:=CalcList^.GetText(CalcList^.Focused,CalcList^.List^.Count);
                        ClientKod:=Copy(s,1+CClient+1,CClientKod);
                        LastClientKod:=ClientKod;
                        FormReport(LocCalcList);
                       End;
                     ClearEvent(Event);

                    End;
   Else;
   End;
   Else;
   End;

inherited HandleEvent(Event);

  If (Desktop^.Current=PView(LocCAlcWindow)) And (Event.What <> EvKeyDown) Then
   Begin
      DrawCurrent;
   End;

ClearEvent(Event);
End;



Destructor TLocCalcWindow.Done;
Begin
 Dispose(sControlRashet,Done);
 Dispose(sControlSkidka,Done);
 Dispose(sControlVidDoc,Done);
 Dispose(sControlDatePP,Done);
 Dispose(sControlSummaPP,Done);
 Dispose(sControlNPP,Done);
 Dispose(sControlBank,Done);
 Dispose(sControlStatus,Done);
 Dispose(sControlItogo,Done);
 Dispose(sControlItogoSkidka,Done);
 Dispose(sControlDoc,Done);
 Dispose(sControlTimeM,Done);
 TDialog.Done;
 PrevCur[0]:=#0;
End;


Var PrevZena : string[150];


Procedure TLocLastWindow.Start(Const P:PBox);
var
  R : TRect;
  Control : PView;
  c : Word;
  s,ws : string[150];
  SDoc : ArtikulStr;
  SDAte : TDateString;
begin
end;

procedure TLocLastWindow.HandleEvent(var Event: TEvent);
Begin
inherited HandleEvent(Event);
ClearEvent(Event);
End;

Procedure TLocLastWindow.FormReport;
Const Space='';
Var Txt : Text;
    k,c : Word;
    s,ws : string[150];
    Numer : ArtikulStr;
    SortBox : PBox;
    R : TRect;
Begin
{$IFDEF DPMI}
{$EndIF}
End;

procedure TLocLastWindow.DrawCurrent;
Var R : TRect;
    ws,s : TMyString;
Begin
 If LocLastList^.List^.Count>0 Then
  Begin
   s:=LocLastList^.GetText(LocLastList^.Focused,LocLastList^.List^.Count);
   If S<> PrevZena Then
   Begin

   PrevZena:=S;
   {Дата}
   ws:= Copy(s,1+CArtikul+1+CNAme+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1,CDate);
   Dispose(SControlDocDate,Done);
   R.Assign(22, 21, 30, 22);
   SControlDocDate := New(PColoredText, Init(R, #3+ws, $7E));
   LocLastWindow^.Insert(SControlDocDate);

   {Время}
   ws:= Copy(s,1+CArtikul+1+CNAme+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CDate+1,CDate);
   Dispose(SControlDocTime,Done);
   R.Assign(38, 21, 46, 22);
   SControlDocTime := New(PColoredText, Init(R, #3+ws, $7E));
   LocLastWindow^.Insert(SControlDocTime);

   {Документ}
   ws:= Copy(s,1+CArtikul+1+CNAme+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CDate+1+CDate+1,CDocNumer);
   DelSpace(Ws);
   Dispose(SControlDocNumer,Done);
   R.Assign(13, 21, 17, 22);
   SControlDocNumer := New(PColoredText, Init(R, #3+ws, $7E));
   LocLastWindow^.Insert(SControlDocNumer);

   {Оператор}
   ws:= Copy(s,1+CArtikul+1+CNAme+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CDate+1+CDate+1+CDocNumer+1,COne+1);
   DelSpace(Ws);
   ws:=GetOperatorName(ws);
   DelSpaceRight(ws);
   Dispose(SControlDocOperator,Done);
   R.Assign(64, 21, 76, 22);
   SControlDocOperator := New(PColoredText, Init(R, #3+ws, $7E));
   LocLastWindow^.Insert(SControlDocOperator);

   Redraw;
   End;
  End
  Else
   Begin
    If PrevZena[0]<>#0 Then
     Begin
{$IfDEF DPMI}
      Dispose(SControlDocNumer,Done);
      R.Assign(13, 21, 17, 22);
      SControlDocNumer := New(PColoredText, Init(R, #3+'???', $7E));
      LocLastWindow^.Insert(SControlDocNumer);

      Dispose(SControlDocOperator,Done);
      R.Assign(64, 21, 76, 22);
      SControlDocOperator := New(PColoredText, Init(R, #3+'???', $7E));
      LocLastWindow^.Insert(SControlDocOperator);

      Dispose(SControlDocTime,Done);
      R.Assign(38, 21, 46, 22);
      SControlDocTime := New(PColoredText, Init(R, #3+'???', $7E));
      LocLastWindow^.Insert(SControlDocTime);

      Dispose(SControlDocDate,Done);
      R.Assign(22, 21, 30, 22);
      SControlDocDate := New(PColoredText, Init(R, #3+'???', $7E));
      LocLastWindow^.Insert(SControlDocDate);

      PrevZena[0]:=#0;
      Redraw;
{$ENDIF}
     End;
   End;
End;



Destructor TLocLastWindow.Done;
Begin

Dispose(SControlDocNumer,Done);
Dispose(SControlDocDAte,Done);
Dispose(SControlDocTime,Done);
Dispose(SControlDocOperator,Done);
TDialog.Done;
End;








End.