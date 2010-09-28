{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit ReestrV;

Interface


Uses Dialogs,Drivers,{Glob,}Access,ServStr,Utils;

Type
  PReestrVWindow = ^TReestrVWindow;
  TReestrVWindow = object(TDialog)
    ViewMrk: PFullScreenMrk;
    constructor Init(Var l: Boolean);
    procedure OpenReestrVWindow;
    procedure FullPreview;
    procedure HandleEvent(var Event: TEvent); virtual;
    Procedure FormPReport(Const p:PBox);
    Procedure FormPReport3(Const P:PBox);
    procedure Refresh;
    procedure DrawCurrent;
    procedure SortScreenList;
    Function Setup : Boolean;
  end;


Implementation

uses Glob,DBEngine,Objects, Views, MsgBox,{Vision,Calc,}Dos,Vision1,TpDate,Vision2,UtilsP,
     Prise,App, ColorTxt,Serv,{InpLong,{Validate,}
	Tools,Printers,ComboBox,NetDbEng,Net;

Const CIZenaK=10;

var
 DocList : PBox;
 ControlStatus,Control,ControlSort,ControlAllDoc,ControlAllSumma,
 ControlDocName,ControlVid,ControlDocSelector,ControlSkidka,ControlAgent,
 ControlDirection,ControlVidano,
 ControlPeriod,ControlAllSkidka: PView;
 DocReestrPWindow:PReestrVWindow;
 StartDate,StopDAte,DocDate : TDateString;

 VidVozwrata,FiltrDoc,Direction,Status ,Sorting,Operations : Word;

 StartTime:LongInt;


 MOperation : Maska3;
 M6 : Maska6;
 M9 : Maska9;

 Start,Stop,RefreshTime:LongInt;
 AllVidano,AllSkidka,AllDoc,AllZakupka,AllSumma : String[CIZena];
 PrevCur : String;
 NoScreenList : PBox;


Function TReestrVWindow.Setup : Boolean;
var
  DataRec : record
    Vid : Word;
    Doc : Word;
    Oper : Word;
    Stat: Word;
  end;

  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
Begin
Setup:=FAlse;

    DataRec.Vid :=VidVozwrata;
    DataRec.Doc :=FiltrDoc;
    DataRec.Oper:=Operations;
    DataRec.Stat:=Status;


R.Assign(0, 6, 80, 16);
New(Dlg, Init(R, 'Параметры'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(1, 2, 45, 8);
Control := New(PCheckboxes, Init(R,
  NewSItem('Нали~ч~ная продажа скидка автоматическая',
  NewSItem('Налична~я~ продажа скидка ручная',
  NewSItem('Закрытая конси~г~нация автоматическая',
  NewSItem('Закрытая консигна~ц~ия ручная',
  NewSItem('Открытая консигнация автомати~ч~еская',
  NewSItem('Отк~р~ытая консигнация ручная', Nil))))))));
Dlg^.Insert(Control);

  R.Assign(1, 1, 15, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~В~ид возврата:', Control)));

R.Assign(46, 2, 79, 5);
Control := New(PCheckboxes, Init(R,
  NewSItem('С~п~исок',
  NewSItem('~Т~ов.чек',
  NewSItem('Фи~з~.лицо',
  NewSItem('~С~Ф',
  NewSItem('С~Ф~Б',
  NewSItem('Д~*~',
  NewSItem('ДСФ',
  NewSItem('~Д~',
  NewSItem('ДСФ~Б~', Nil)))))))))));
Dlg^.Insert(Control);

  R.Assign(46, 1, 66, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Документы отгрузки:', Control)));

R.Assign(46, 6, 79, 7);
Control := New(PCheckboxes, Init(R,
  NewSItem('Кл~и~ент',
  NewSItem('Ск~л~ад',
  NewSItem('Обме~н~', Nil)))));
Dlg^.Insert(Control);

  R.Assign(46, 5, 60, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид операций:', Control)));

R.Assign(46, 8, 79, 9);
Control := New(PCheckboxes, Init(R,
  NewSItem('Введен',
  NewSItem('Б~у~фер', Nil))));
Dlg^.Insert(Control);

  R.Assign(46, 7, 54, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'Статус:', Control)));

Dlg^.SelectNext(False);
Dlg^.SetDAta(DAtaRec);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
Begin
 Setup:=True;
 Dlg^.GetDAta(DAtaRec);

    VidVozwrata:=DataRec.Vid;
    FiltrDoc:=DataRec.Doc;
    Operations:=DataRec.Oper;
    Status:=DataRec.Stat;

End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;


procedure TReestrvWindow.OpenReestrVWindow;
Var l : Boolean;
begin
StartDate:=FDate;
StopDate:=FDate;
  if Message(Desktop, evBroadcast, cmReestrVzw, nil) = nil then
  begin
    L:=True;
    {If Not(DatePeriodDialog(StartDAte,StopDate,False)) Then Exit;}
    StartDate:=FDate;
    StopDate:=FDate;

   start:=DateStringToDate(DAtemask,StartDate);
   stop:=DateStringToDate(DAtemask,StopDate);

    DInfo('Инициализация реестра документов возврата...');
    DocReestrPWindow := New(PReestrVWindow, Init(L));
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


Procedure TReestrvWindow.Refresh;
Var Fp : NewVozwratFileType;
    s: TMyString;
    ws : AllStr;
    E : PNewVozwratType;
    FPos:Byte;
    FS : AllStr;
    c : Word;
    R : TRect;
    Cur : LongInt;
    TempS : TDateString;
    mSorting: Maska3;
    mStatus : Maska2;
    mOperation : Maska3;
    Summa : String[CIZena];
    BB : PSuperMarketType;
    As : DocumentEdit;
    AgentKod : ArtikulStr;
Begin
DInfo('Минуточку...');
New(E,Init);
AllDoc[0]:=#0;
AllSumma[0]:=#0;
AllSkidka[0]:=#0;
AllVidano[0]:=#0;
AllZakupka[0]:=#0;

NoScreenList^.NewList(Nil);
NoScreenList^.NewList(New(PTextCollection, Init(1,1)));


{ControlOperation^.GetData(Operations);}


For Cur:=Start To Stop Do
Begin
c:=IOResult;
TempS:=DAteToDateString(DAteMask,Cur);

DInfoMsg('Просматриваю возвраты за '+TempS+' ...');

Assign(fp,Path.ToReturn+TempS+'.vzw');
Reset(fp);
c:=IOResult;
If c=0 Then
 Begin
While Not(Eof(Fp)) Do
 Begin
  ReadNewVozwrat(Fp,E);
{Клиент              │Номе│  Дата  │Сумма Возв│  Скидка  │Расход    │Оператор    │С│Nдок│Дата Doc Agen S│В O}
{12345678901234567890│1234│12345678│1234567890│1234567890│1234567890│123456789012│1│1234│12345678│1234│1│1│1}
{  If (mstatus[E^.Dat.StatusDoc+1]=1) And (msorting[E^.Dat.OperatorSelector+1]=1) Then}
   Begin
    Str(StrToInt(AllDoc)+1:CArtikul,AllDoc);
    DelSpace(AllDoc);
    s:=GetClientField(FClient,E^.Dat.MakeKod,E^.Dat.OperatorSelector);
    Format(S,CClient);
    s:=s+'│';
    RFormatZerro(E^.Dat.Document,CDocNumer);
    Format(E^.Dat.Document,CDocNumer);
    s:=s+E^.Dat.Document+{'│'+E^.Dat.DateC}+'│'+E^.Dat.DateC+'│';
    DelSpace(E^.Dat.SummaR);

    If Not(E^.Dat.Opt) Then Summa:=E^.Dat.SummaR

    Else Summa:=E^.Dat.SummaO;

    New(BB,Init);

    As.EditPosition:=E^.DAt.BasisDoc;

    As.D:=E^.DAt.BasisDAte;

    If GetMarket1(As,BB) Then
    Begin
     AgentKod:=BB^.Dat.AgentKod;
    End
    Else
     AgentKod:='0000';

    Dispose(BB,Done);

    RFormat(E^.DAt.BasisDOc,CDocNumer);
    Str(StrToReal(Summa):CIzena-5:CMantissa,Summa);
    Str(StrToReal(E^.Dat.Skidka):CIzena-5:CMantissa,E^.Dat.Skidka);
    Str(StrToReal(E^.Dat.RashodSumma):CIzena-5:CMantissa,E^.Dat.RashodSumma);

    Str(StrToReal(AllSumma)+StrToReal(Summa):CIZena:CMantissa,AllSumma);
    DelSpace(AllSumma);

    Str(StrToReal(AllSkidka)+StrToReal(E^.Dat.Skidka):CIZena:CMantissa,AllSkidka);
    DelSpace(AllSkidka);

    s:=s+Summa+'│'+E^.Dat.Skidka+'│'+E^.Dat.RashodSumma+'│';

    ws:=GetOperatorName(E^.Dat.Caption);
    Format(Ws,CKto);
    s:=s+ws;

    Str(E^.Dat.StatusDoc:1,ws);
    s:=s+'│'+ws;

    s:=s+'│'+E^.Dat.BasisDoc+'│'+E^.Dat.BAsisDate+'│'+AgentKod+'│'+IntToStr(E^.Dat.DocSelector,COne)+'│'+
    IntToStr(E^.Dat.VidDocument,COne)+'│'+IntToStr(E^.Dat.OperatorSelector,COne);

    NoScreenList^.List^.Insert(NewStr(s));
    NoScreenList^.SetRange(NoScreenList^.List^.Count);
   End;{If StatusDoc=0}
 End;{While}
System.Close(Fp);
End;{If IOResult}
End;{For}

Dispose(E,Done);
NoInfoMsg;
NoScreenList^.FocusItem(0);


NoInfoMsg;

NoInfo;
End;


constructor TReestrVWindow.Init(Var l : Boolean);
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

AllDoc[0]:=#0;
AllVidano[0]:=#0;
AllSumma[0]:=#0;
AllSkidka[0]:=#0;
AllZakupka[0]:=#0;

Status:=3;{введен буфер}

Sorting:=0;{ключ сортировки}

Operations:=7;{клиент склад обмен}

RefreshTime:=20;

VidVozwrata:=63;{виды возвратов}

FiltrDoc:=511;{виды документов}

Direction:=0;




L:=False;
R.Assign(0, 0, 80, 23);
inherited Init(R, ''{Реестр документов возврата товара на склад с '+StartDate+' по '+StopDate});
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E002;


R.Assign(0, 0, 0, 0);
NoScreenList := New(PBox, Init(R, 1, Nil));
NoScreenList^.NewList(New(PTextCollection, Init(1,1)));
NoScreenList^.FocusItem(0);

R.Assign(14, 0, 65, 1);
ControlPeriod := New(PColoredText, Init(R, 'Реестр документов возврата'+
' с '+StartDAte+' по '+StopDAte, $4F));
ControlPeriod^.Options := ControlPeriod^.Options or ofCenterX;
Insert(ControlPeriod);


R.Assign(1, 1, 64, 2);
ControlSort := New(PRadioButtons, Init(R,
  NewSItem('К~л~иент',
  NewSItem('Да~т~а и номер',
  NewSItem('Су~м~ма возврата',
  NewSItem('К вы~д~аче', Nil))))));
ControlSort^.SetData(Sorting);
Insert(ControlSort);

  R.Assign(1, 0, 13, 1);
  Insert(New(PLabel, Init(R, 'Со~р~тировка:', ControlSort)));

{R.Assign(11, 1, 45, 2);
ControlSort := New(PCheckBoxes, Init(R,
  NewSItem('Кл~и~ент',
  NewSItem('Ск~л~ад',
  NewSItem('Обмен',
   Nil)))));
Sorting:=7;
ControlSort^.SetData(Sorting);
Insert(ControlSort);

  R.Assign(1, 1, 11, 2);
  Insert(New(PLabel, Init(R, 'Вид взв.:', ControlSort)));

R.Assign(54, 1, 79, 2);
ControlStatus := New(PCheckBoxes, Init(R,
  NewSItem('~В~веденные',
  NewSItem('Бу~ф~ер',
  Nil))));
Status:=3;
ControlStatus^.SetData(Status);
Insert(ControlStatus);

  R.Assign(46, 1, 54, 2);
  Insert(New(PLabel, Init(R, 'Статус:', ControlStatus)));}

R.Assign(65, 1, 79, 2);
ControlDirection := New(PRadioButtons, Init(R,
  NewSItem(#30,
  NewSItem(#31, Nil))));
ControlDirection^.SetData(Direction);
Insert(ControlDirection);

R.Assign(80, 3, 81, 20);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(0, 3, 80, 20);
DoCList := New(PBox, Init(R, 1, Nil));
DoCList^.NewList(New(PMyCollection, Init(0,1)));
DocList^.HelpCtx:=$F182;
Insert(DocList);

Str(StrToReal(AllSumma):10:CMantissa,AllSumma);
DelSpace(AllSumma);
Str(StrToReal(AllZakupka):10:CMantissa,AllZakupka);
DelSpace(AllZakupka);

Str(StrToReal(AllVidano):10:CMantissa,AllVidano);
DelSpace(AllZakupka);

Str(StrToInt(AllDoc):CArtikul,AllDoc);
DelSpace(AllDoc);

  R.Assign(1, 2, 78, 3);
  Insert(New(PLabel, Init(R, 'Клиент                N   Дата    Возврат РЦ Скидка взв. К выдаче  Оператор  ', DocList)));
                             {12345678901234567890│1234│12345678│1234567890│1234567890│1234567890│123456789012}

R.Assign(58, 22, 69, 23);
Control := New(PColoredText, Init(R, ' E Возврат:', $74));
Insert(Control);

R.Assign(69, 22, 79, 23);
ControlAllSumma := New(PColoredText, Init(R, #3+AllSumma, $4E));
Insert(ControlAllSumma);

R.Assign(1, 22, 16, 23);
Control := New(PColoredText, Init(R, ' E Скид.возвр.:', $74));
Insert(Control);

R.Assign(16, 22, 26, 23);
ControlAllSkidka := New(PColoredText, Init(R, #3+AllSkidka, $4E));
Insert(ControlAllSkidka);

R.Assign(26, 22, 32, 23);
Control := New(PColoredText, Init(R, ' Док.:', $74));
Insert(Control);

R.Assign(32, 22, 38, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);

R.Assign(38, 22, 48, 23);
Control := New(PColoredText, Init(R, ' К выдаче:', $74));
Insert(Control);

R.Assign(48, 22, 58, 23);
ControlVidano := New(PColoredText, Init(R, #3+AllVidano, $4E));
Insert(ControlVidano);

R.Assign(1, 20, 20, 21);
Control := New(PColoredText, Init(R, 'Документ-основание:', $74));
Insert(Control);

R.Assign(20, 20, 36, 21);
ControlDocName := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlDocName);

R.Assign(37, 20, 57, 21);
Control := New(PColoredText, Init(R, 'Тип док-та отгрузки:', $74));
Insert(Control);

R.Assign(57, 20, 66, 21);
ControlDocSelector := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlDocSelector);

R.Assign(1, 21, 7, 22);
Control := New(PColoredText, Init(R, 'Агент:', $74));
Insert(Control);

R.Assign(7, 21, 27, 22);
ControlAgent := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlAgent);

R.Assign(28, 21, 39, 22);
Control := New(PColoredText, Init(R, 'Вид возвр.:', $74));
Insert(Control);

R.Assign(70, 20, 75, 21);
ControlSkidka := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlSkidka);

R.Assign(39, 21, 79, 22);
ControlVid := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlVid);

SelectNext(False);
SelectNext(False);
SelectNext(False);
L:=True;
Refresh;
SortScreenList;
PrevCur[0]:=#0;
end;




procedure TReestrVWindow.FullPreview;
Var Ass : DocumentEdit;
    E : PNewVozwratType;
    R : TRect;
    f : NewVozwratFileType;
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
  Ass.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,
  CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CDocNumer+1,
  CDate);
  DelSpace(Ass.D);

  Assign(f,Path.ToReturn+Ass.d+'.vzw');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
  Begin
   MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path.ToReturn+Ass.d+'.vzw',Nil,mfError+mfCancelButton);
   Exit;
  End;
  DInfoMsg('Ищу документ...');
  New(E,Init);
  Find := False;
  ClearChar(Ass.EditPosition);
  While Not(Eof(f)) And Not(Find) Do
   Begin
   ReadNewVozwrat(F,E);
   ClearChar(E^.Dat.Document);
    If (E^.Dat.DateC=Ass.D) and (E^.Dat.Document=Ass.EditPosition) Then
          Begin
           Find:=True;
           Break;
          End;
   End;
   System.Close(f);
  NoInfoMsg;

   If Find Then
    Begin
     R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(1,1)));
For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.VozwratElement[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,CName);
  s:=ws+'│'+s;
  ws:=GetIdField(FInPack,E^.Dat.VozwratElement[c].BazKod);
  RFormat(ws,CInPack);
  s:=s+'│'+ws;

  ws:=GetIdField(FLitr,E^.Dat.VozwratElement[c].BazKod);
  RFormat(ws,CInPack);
  s:=s+'│'+ws;

  DelSpace(E^.Dat.VozwratElement[c].Input.Kol);
  RFormat(E^.Dat.VozwratElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.VozwratElement[c].Input.Kol;

  DelSpace(E^.Dat.VozwratElement[c].Input.R_Zena);
  RFormat(E^.Dat.VozwratElement[c].Input.R_Zena,CZena);
  s:=s+'│'+E^.Dat.VozwratElement[c].Input.R_Zena;

  ws:=CalcPack(E^.Dat.VozwratElement[c].BazKod,E^.Dat.VozwratElement[c].Input.Kol);
  DelSpace(ws);
  Format(ws,CPAck);
  s:=s+'│'+ws+'│';


  P^.List^.Insert(NewStr(s));
  P^.SetRange(P^.List^.Count);
 End;


P^.FocusItem(0);
s[0]:=#0;
ws:=E^.Dat.SummaR;
DelSpace(ws);
s:=s+' Всего возврат по Р/Ценам: '+ws;

 Begin
  Str(StrToReal(E^.Dat.RashodSumma):CIZena:CMAntissa,ws);
  DelSpace(ws);
  s:=s+' К выдаче клиенту: '+ws;
 End;

SDoc:=E^.Dat.Document;
SDate:=E^.Dat.DateC;

Dispose(E,Done);

NoInfomsg;
                   {Вставить номер и дату документа в просмотре}
FullScreen(P,'Наименование товара         Код  Фас Литр  Колич  Р/Цена  Упаковок',s,
             {12345678901234567890123456│12345│123│12345│12345│12345678│123456789}
SDoc,SDAte,0);
Dispose(P,Done);
    End
Else
  Begin
  NoInfomsg;
  MessageBox(#3^M+#3'Документ не найден!',Nil,mfError+mfCancelButton);
  Dispose(E,Done);
  End;
End;
End;



Function TestAgent(Agent:PBox;Cod:ArtikulStr):Boolean;
Var L : Boolean;
    i : word;
    st : String;
Begin
TestAgent:=False;
If (Agent^.List^.Count-1)>=0 Then
Begin
For i:=0 To Agent^.List^.Count-1 Do
 Begin
  st:=Agent^.GetText(i,Agent^.List^.Count);
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    TestAgent:=True;
    Break;
   End;{St=Cod}
 End;
End;
End;



Procedure TReestrVWindow.FormPReport(Const P:PBox);
Const Space='   ';
Var f : text;
    Skidka,Summa,ws,s : String;
    i,c,k : Word;
    mSorting: Maska3;
    mStatus : Maska2;
    mVidVozwrata : Maska6;
    MFiltrDoc : MAska9;
    tt : Real;
    TempStr,Datestr:DateString;
    LocZ,LocP:Real;
    LocDoc:LongInt;
    PrintItog,PrintDate : Boolean;
    As : DocumentEdit;
    NDS20,NDS10,NDS_ : Real;
    NDS,LocNDS,LocNDS20,LocNDS10,LocNDS_:Real;
    Agent : PBox;
    AgKod : AllStr;
    R : TRect;
    DocCount:Word;
    AllSummaA,AllSkidkaA,AllRashodA:AllStr;

Begin
If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path.ToTemp+'listvz.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'Не могу создать файл '+Path.ToTemp+'listvz.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));

If Not(SelectionAgent(Agent)) Then
 Begin
  System.Close(f);
  Dispose(Agent,Done);
  Exit;
 End;


WordToBit3(Operations,mOperation);
Convert3(mOperation);

WordToBit2(STatus,mStatus);
Convert2(mStatus);

WordToBit6(VidVozwrata,mVidVozwrata);
Convert6(mVidVozwrata);

WordToBit9(FiltrDoc,MFiltrDoc);
Convert9(MFiltrDoc);

 Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1999');


 WriteLn(f,Space+'Виды возврата:');
 For c:=1 To Max6 Do
  Begin
   If mVidVozwrata[c]=1 Then
    Case c Of
    1:WriteLn(f,'Наличная продажа скидка автоматическая');
    2:WriteLn(f,'Наличная продажа скидка ручная');
    3:WriteLn(f,'Закрытая консигнация автоматическая');
    4:WriteLn(f,'Закрытая консигнация ручная');
    5:WriteLn(f,'Открытая консигнация автоматическая');
    6:WriteLn(f,'Открытая консигнация ручная');
    Else;
    End;
  End;
 Writeln(f);

 WriteLn(f,Space+'Виды документов:');
 For c:=1 To Max9 Do
  Begin
   If MFiltrDoc[c]=1 Then
    Case c Of
    1:Write(f,' "Сп" ');
    2:Write(f,' "ТЧ*" ');
    3:Write(f,' "ФЛ*" ');
    4:Write(f,' "СФ*" ');
    5:Write(f,' "СФБ" ');
    6:Write(f,' "Д*" ');
    7:Write(f,' "ДСФ*" ');
    8:Write(f,' "Д" ');
    9:Write(f,' "ДСФБ" ');
    Else;
    End;
  End;
 Writeln(f);

 WriteLn(f,Space+'Сортировка:');
    Case Sorting Of
    0:WriteLn(f,' "Клиент" ');
    1:WriteLn(f,' "Номер и дата" ');
    2:WriteLn(f,' "Сумма возврата" ');
    3:WriteLn(f,' "К выдаче" ');
    Else Writeln(f);
    End;

 Write(f,Space+'Вид операций:');
 For i:=1 To 3 Do
 Case i Of
 1: If mOperation[i]=1 Then Write(f,'{Клиент ') Else Write(f,'{');
 2: If mOperation[i]=1 Then Write(f,'Склад ') ;
 3: If mOperation[i]=1 Then Write(f,' Обмен}') Else Write(f,'}');
 Else;
 End;
 Writeln(f);


 Write(f,Space+'Статус документов:');
 For i:=1 To 2 Do
 Case i Of
 1: If mStatus[i]=1 Then Write(f,'{Введен на склад ') Else Write(f,'{');
 2: If mStatus[i]=1 Then Write(f,'Буфер}') Else Write(f,'}');
 Else;
 End;
 Writeln(f);

 DocCount:=0;
 AllSummaA[0]:=#0;
 AllSkidkaA[0]:=#0;
 AllRashodA[0]:=#0;
 WriteLn(f,Space+'Форма N 1');


 Writeln(f,Space+' РЕЕСТР ДОКУМЕНТОВ ВОЗВРАТА ТОВАРА НА СКЛАД  с '+StartDate+
 ' по '+StopDate);

 Writeln(f,Space+'Выбраны следующие агенты:');
 For c:=0 To Agent^.List^.Count-1 Do
  Begin
   s:=Agent^.GetText(c,Agent^.List^.Count);

   AgKod:=Copy(s,1+1,CClientKod);

   S:=GetAgentField(FClient,AgKod);
   Format(s,CClient);
   s:=s+' ('+AgKod+')';
   Writeln(f,Space+s);
  End;

 Writeln(f,Space+'┌──────────────────────────────────────────────────────────────────────────────┐');
 Writeln(f,Space+'│Клиент              Док    Дата  Сумма по РЦ Скидка взв.  Из кассы    Оператор│');
 Writeln(f,Space+'└──────────────────────────────────────────────────────────────────────────────┘');
 s := P^.GetText(0,P^.List^.Count);

 LocZ:=0;
 LocP:=0;
 LocDoc:=0;

   NDS:=0;
   NDS10:=0;
   NDS20:=0;
   NDS_:=0;



 For c:=0 To P^.List^.Count-1 Do
  Begin
   DInfoMsg('Формирую отчет за период с '+StartDate+' по '+StopDate+' ...');
   PrintItog:=False;
   PrintDate:=False;

   s := P^.GetText(c,P^.List^.Count);

AgKod:=Copy(s,1+CClient+1+CDocNumer+1+CDAte+1+(CIZena-5)+1+(CIZena-5)+1+(CIZena-5)+1+CKto+1+
COne+1+CDocNumer+1+CDate+1,CClientKod);

If TestAgent(Agent,AgKod) Then
Begin
   Inc(DocCount);


{Клиент              │Номе│  Дата  │Сумма Возв│  Скидка  │Расход    │Оператор    │С│Nдок│Дата Doc Agen S│В}
{12345678901234567890│1234│12345678│1234567890│1234567890│1234567890│123456789012│1│1234│12345678│1234│1│1│}
   Str(StrToReal(Copy(s,1+CClient+1+CDocNumer+1+CDAte+1,CIZenaK))+
         StrToReal(AllSummaA):CIZenaK:CMantissa,AllSummaA);

   Str(StrToReal(Copy(s,1+CClient+1+CDocNumer+1+CDAte+1+CIZenaK+1+CIZenaK+1,CIZenaK))+
         StrToReal(AllRashodA):CIZenaK:CMantissa,AllRashodA);

   Str(StrToReal(Copy(s,1+CClient+1+CDocNumer+1+CDAte+1+CIZenaK+1,CIZenaK))+
         StrToReal(AllSkidkaA):CIZenaK:CMantissa,AllSkidkaA);




   As.EditPosition:=Copy(s,1+CClient+1,CDocNumer);
   As.D:=Copy(s,1+CClient+1+CDocNumer+1,CDate);
   LocNDS:=0;
   LocNDS10:=0;
   LocNDS20:=0;
   LocNDS_:=0;
   {
   CalcNDSFromVozwrat(As,LocNDS,LocNDS20,LocNDS10,LocNDS_);


  NDS:=NDS+LocNDS;
  NDS10:=NDS10+LocNDS10;
  NDS20:=NDS20+LocNDS20;
  NDS_:=NDS_+LocNDS_;
   }



   While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert(' ',s,k);
    End;

    s[0]:=Chr(1+CClient+1+CDocNumer+1+CDate+1+10+1+10+1+10+1+CKto);

   Writeln(f,Space+s);
End;{TestAgent}
  End;
 Writeln(f,Space+'───────────────────────────────────────────────────────────────────────────────-');
 Writeln(f,Space,'                                        Всего документов за период: ',DocCount:5);
 Writeln(f,Space,'                                      Всего возвр. по Р/Ц составил: '+Recogniz(AllSummaA));
 Writeln(f,Space,'                                             Всего скидка возврата: '+Recogniz(AllSkidkaA));
 Writeln(f,Space,'                                            Всего к выдаче клиенту: '+Recogniz(AllRashodA));

(*
 s:='Всего НДС: '+RecognizReal(NDS,CIZena,CMAntissa)+' руб ';
 Writeln(f,Space+s);


 If Abs(NDS20)>0.009 Then
 Writeln(f,Space+'НДС 20%:'+RecognizReal(NDS20,CIZena,CMAntissa));


 If Abs(NDS10)>0.009 Then
 Writeln(f,Space+'НДС 10%:'+RecognizReal(NDS10,CIZena,CMAntissa));


 If Abs(NDS_)>0.009 Then
 Writeln(f,Space+'НДС прочее:'+RecognizReal(NDS_,CIZena,CMAntissa));
*)
 Writeln(f);

 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'================================================================================');


 System.Close(f);
 Dispose(Agent,Done);

 NoInfoMSg;
 ViewAsText(Path.ToTemp+'listvz.txt',True);
 Report(Path.ToTemp+'listvz.txt','',1,False,False,false);
 End;
End;



Procedure TReestrVWindow.FormPReport3(Const P:PBox);
Const Space='  ';
      SeparatorChar=' ';
Var f : text;
    Skidka,Summa,ws,s : String;
    i,c,k : Word;
    mSorting: Maska3;
    mStatus : Maska2;
    mVidVozwrata : Maska6;
    MFiltrDoc : MAska9;
    tt : Real;
    TempStr,Datestr:DateString;
    LocZ,LocP:Real;
    LocDoc:LongInt;
    Ass : DocumentEdit;
    PrintItog,PrintDate : Boolean;
    As : DocumentEdit;
    NDS20,NDS10,NDS18,NDS_ : Real;
    NDS,LocNDS,LocNDS20,LocNDS10,LocNDS18,LocNDS_:Real;
    Agent : PBox;
    AgKod : AllStr;
    R : TRect;
    VidReport,DocCount:Word;
    DocName:TDateString;
    BasDoc,BasDAte,Podskazka : AllStr;
    AllSummaA,AllSkidkaA,AllRashodA:AllStr;
    TempList : PBox;
    V : PNewVozwratType;
    j : Word;
    SDiv,SKod,SDoc,SDate,SKto,SKol,SZena: AllStr;
    OtdelMas : MaskaNew;
    Otdel : Word;

Begin
If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin

 If Not(SelectOtdel(Otdel)) Then Exit;

 WordToBitNew(Otdel,OtdelMas);
 ConvertNew(OtdelMas);



 Assign (f,Path.ToTemp+'listvz3.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'Не могу создать файл '+Path.ToTemp+'listvz3.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));

If Not(SelectionAgent(Agent)) Then
 Begin
  System.Close(f);
  Dispose(Agent,Done);
  Exit;
 End;



R.Assign(0, 0, 0, 0);
TempList := New(PBox, Init(R, 1, Nil));
TempList^.NewList(New(PTextCollection, Init(1,1)));
TempList^.FocusItem(0);
DInfoMsg('Анализирую возвраты за период с '+StartDate+' по '+StopDate+' ...');

 For c:=0 To P^.List^.Count-1 Do
  Begin
   s := P^.GetText(c,P^.List^.Count);

AgKod:=Copy(s,1+CClient+1+CDocNumer+1+CDAte+1+(CIZena-5)+1+(CIZena-5)+1+(CIZena-5)+1+CKto+1+
COne+1+CDocNumer+1+CDate+1,CClientKod);

If TestAgent(Agent,AgKod) Then
Begin
   Ass.EditPosition:=copy(s,1+CClient+1,CDocNumer);
   Ass.D:=Copy(s,1+CClient+1+CDocNumer+1,CDate);
   New(V,Init);
   If GetReturnDoc(Ass,V) Then
     Begin
      For j:=1 To V^.Dat.Amount Do
       Begin
        s:=GetIdField(FName,V^.Dat.VozwratElement[j].BazKod);
        Format(s,CNAme);
        Sdiv:=V^.Dat.VozwratElement[j].Input.DivisionS;
        sDoc:=IntToStr(StrToInt(V^.Dat.Document),CDocNumer);
        RFormat(SDoc,CDocNumer);
        sDate:=V^.Dat.DateC;
        sKol:=IntToStr(StrToInt(V^.Dat.VozwratElement[j].Input.Kol),CKOl);
        RFormat(SKol,CKOl);
        MyStr(StrToReal(V^.Dat.VozwratElement[j].Input.Zena)*StrToInt(SKol),10,CMantissa,SZena);
        SKto:=GetOperatorname(V^.Dat.Caption);
        Format(SKto,CKto);
{
 Writeln(f,Space+'│       Наименование      │ Код │ │  Возврат    │     │   Сумма  │            │');
 Writeln(f,Space+'│         товара          │товар│О│Док.   Дата  │Колич│ возврата │ Оператор   │');
}
        s:=s+SeparatorChar+V^.Dat.VozwratElement[j].BazKod+SeparatorChar+SDiv+SeparatorChar+SDoc+SeparatorChar+
	   SDate+SeparatorChar+SKol+SeparatorChar+SZena+SeparatorChar+SKto;

       TempList^.List^.Insert(NewStr(s));
       TempList^.SetRange(TempList^.List^.Count);
       End;{For j}
     End;{GetReturnDoc}
   Dispose(V,Done);
End;{TestAgent}
  End;{For}

   NoInfoMsg;


WordToBit3(Operations,mOperation);
Convert3(mOperation);

WordToBit2(STatus,mStatus);
Convert2(mStatus);

WordToBit6(VidVozwrata,mVidVozwrata);
Convert6(mVidVozwrata);

WordToBit9(FiltrDoc,MFiltrDoc);
Convert9(MFiltrDoc);

 Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 2002');

 WriteLn(f,Space+'Виды возврата:');
 For c:=1 To Max6 Do
  Begin
   If mVidVozwrata[c]=1 Then
    Case c Of
    1:WriteLn(f,'Наличная продажа скидка автоматическая');
    2:WriteLn(f,'Наличная продажа скидка ручная');
    3:WriteLn(f,'Закрытая консигнация автоматическая');
    4:WriteLn(f,'Закрытая консигнация ручная');
    5:WriteLn(f,'Открытая консигнация автоматическая');
    6:WriteLn(f,'Открытая консигнация ручная');
    Else;
    End;
  End;
 Writeln(f);

 WriteLn(f,Space+'Виды документов:');
 For c:=1 To Max9 Do
  Begin
   If MFiltrDoc[c]=1 Then
    Case c Of
    1:Write(f,' "Сп" ');
    2:Write(f,' "ТЧ*" ');
    3:Write(f,' "ФЛ*" ');
    4:Write(f,' "СФ*" ');
    5:Write(f,' "СФБ" ');
    6:Write(f,' "Д*" ');
    7:Write(f,' "ДСФ*" ');
    8:Write(f,' "Д" ');
    9:Write(f,' "ДСФБ" ');
    Else;
    End;
  End;
 Writeln(f);

 Write(f,Space+'Вид операций:');
 For i:=1 To 3 Do
 Case i Of
 1: If mOperation[i]=1 Then Write(f,'{Клиент ') Else Write(f,'{');
 2: If mOperation[i]=1 Then Write(f,'Склад ') ;
 3: If mOperation[i]=1 Then Write(f,' Обмен}') Else Write(f,'}');
 Else;
 End;
 Writeln(f);


 Write(f,Space+'Статус документов:');
 For i:=1 To 2 Do
 Case i Of
 1: If mStatus[i]=1 Then Write(f,'{Введен на склад ') Else Write(f,'{');
 2: If mStatus[i]=1 Then Write(f,'Буфер}') Else Write(f,'}');
 Else;
 End;
 Writeln(f);

 DocCount:=0;
 AllSummaA[0]:=#0;
 AllSkidkaA[0]:=#0;
 AllRashodA[0]:=#0;

 Write(f,Space+'Внимание! в отчет включены следующие отделения:');
 For c:=1 To CDivision Do
 Begin
  If OtdelMas[c]=1 Then Write(f,c:2,'  ');
 End;
 Writeln(f);


 Writeln(f,Space+' РЕЕСТР ВОЗРАЩЕННОГО ТОВАРА НА СКЛАД  с '+StartDate+' по '+StopDate);
(*
 Writeln(f,Space+'Выбраны следующие агенты:');
 For c:=0 To Agent^.List^.Count-1 Do
  Begin
   s:=Agent^.GetText(c,Agent^.List^.Count);

   AgKod:=Copy(s,1+1,CClientKod);

   S:=GetAgentField(FClient,AgKod);
   Format(s,CClient);
   s:=s+' ('+AgKod+')';
   Writeln(f,Space+s);
  End;
*)
 WriteLn(f,Space+'Форма N 2');

 {наименование              │код  │о│док │  дата  │колич│     сумма│оператор}
 {12345678901234567890123456│12345│1│1234│12345678│12345│1234567890│123456789012}


 Writeln(f,Space+'┌─────────────────────────┬─────┬─┬─────────────┬─────┬──────────┬────────────┐');
 Writeln(f,Space+'│       Наименование      │ Код │ │  Возврат    │     │   Сумма  │            │');
 Writeln(f,Space+'│         товара          │товар│О│Док.'+SeparatorChar+'  Дата  │Колич│ возврата │ Оператор   │');
 Writeln(f,Space+'└─────────────────────────┴─────┴─┴─────────────┴─────┴──────────┴────────────┘');

 AllSummaA[0]:=#0;
 MyStr(StrToReal(AllSummaA),CIZena,CMantissa,AllSummaA);
 DInfoMsg('Формирую отчет...');
 For c:=0 To TempList^.List^.Count-1 Do
  Begin
   PrintItog:=False;
   PrintDate:=False;

   s := TempList^.GetText(c,TempList^.List^.Count);
   sDiv:=Copy(S,1+CName+1+CArtikul+1,COne);
   sZena:=Copy(S,1+CName+1+CArtikul+1+COne+1+CDocNumer+1+CDate+1+CKOl+1,10);

   If OtdelMas[StrToInt(SDiv)]=1 Then {фильтр отделений}
   Begin
    Writeln(f,Space+s);
    MyStr(StrToReal(AllSummaA)+StrToReal(SZena),CIZena,CMantissa,AllSummaA);
   End;{MMM}
  End;
 Writeln(f,Space+'────────────────────────────────────────────────────────────────────');
 Writeln(f,Space,'                                      Всего возвр. по Р/Ц составил:'+SeparatorChar+Recogniz(AllSummaA));
 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'========================================================');



 System.Close(f);
 Dispose(Agent,Done);
 Dispose(TempList,Done);

 NoInfoMSg;
 ViewAsText(Path.ToTemp+'listvz3.txt',True);
 Report(Path.ToTemp+'listvz3.txt','',1,False,False,false);
 End;
End;




(*
Procedure TReestrVWindow.FormPReport(Const P:PBox);
Const Space='   ';
Var f : text;
    Skidka,Summa,ws,s : String;
    i,c,k : Word;
    mSorting: Maska3;
    mStatus : Maska2;
    mVidVozwrata : Maska6;

    MFiltrDoc : MAska9;
    tt : Real;
    TempStr,Datestr:DateString;
    LocZ,LocP:Real;
    LocDoc:LongInt;
    PrintItog,PrintDate : Boolean;
    As : DocumentEdit;
    NDS20,NDS10,NDS_ : Real;
    NDS,LocNDS,LocNDS20,LocNDS10,LocNDS_:Real;
Begin
If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path^.Dat.ToTemp+'listvz.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'Не могу создать файл '+Path^.Dat.ToTemp+'listvz.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


WordToBit3(Operations,mOperation);
Convert3(mOperation);

WordToBit2(STatus,mStatus);
Convert2(mStatus);

WordToBit6(VidVozwrata,mVidVozwrata);
Convert6(mVidVozwrata);

WordToBit9(FiltrDoc,MFiltrDoc);
Convert9(MFiltrDoc);

 Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1999');


 WriteLn(f,Space+'Виды возврата:');
 For c:=1 To Max6 Do
  Begin
   If mVidVozwrata[c]=1 Then
    Case c Of
    1:WriteLn(f,'Наличная продажа скидка автоматическая');
    2:WriteLn(f,'Наличная продажа скидка ручная');
    3:WriteLn(f,'Закрытая консигнация автоматическая');
    4:WriteLn(f,'Закрытая консигнация ручная');
    5:WriteLn(f,'Открытая консигнация автоматическая');
    6:WriteLn(f,'Открытая консигнация ручная');
    Else;
    End;
  End;
 Writeln(f);

 WriteLn(f,Space+'Виды документов:');
 For c:=1 To Max9 Do
  Begin
   If MFiltrDoc[c]=1 Then
    Case c Of
    1:Write(f,' "Сп" ');
    2:Write(f,' "ТЧ*" ');
    3:Write(f,' "ФЛ*" ');
    4:Write(f,' "СФ*" ');
    5:Write(f,' "СФБ" ');
    6:Write(f,' "Д*" ');
    7:Write(f,' "ДСФ*" ');
    8:Write(f,' "Д" ');
    9:Write(f,' "ДСФБ" ');
    Else;
    End;
  End;
 Writeln(f);

 Write(f,Space+'Вид операций:');
 For i:=1 To 3 Do
 Case i Of
 1: If mOperation[i]=1 Then Write(f,'{Клиент ') Else Write(f,'{');
 2: If mOperation[i]=1 Then Write(f,'Склад ') ;
 3: If mOperation[i]=1 Then Write(f,' Обмен}') Else Write(f,'}');
 Else;
 End;
 Writeln(f);


 Write(f,Space+'Статус документов:');
 For i:=1 To 2 Do
 Case i Of
 1: If mStatus[i]=1 Then Write(f,'{Введен на склад ') Else Write(f,'{');
 2: If mStatus[i]=1 Then Write(f,'Буфер}') Else Write(f,'}');
 Else;
 End;
 Writeln(f);


 Writeln(f,Space+' РЕЕСТР ДОКУМЕНТОВ ВОЗВРАТА ТОВАРА НА СКЛАД  с '+StartDate+
 ' по '+StopDate);
 Writeln(f,Space+'--------------------------------------------------------------------------------');
 Writeln(f,Space+'Клиент               Док    Дата  Сумма по РЦ Скидка взв.  Из кассы    Оператор ');
                 {12345678901234567890│1234│12-45-78│1234567890│1234567890│1234567890│123456789012│}
 Writeln(f,Space+'--------------------------------------------------------------------------------');
 s := P^.GetText(0,P^.List^.Count);

 DateStr:=Copy(s,1+CClient+1+CDocNumer+1,CDate);
 LocZ:=0;
 LocP:=0;
 LocDoc:=0;
 Writeln(f,Space+'Дата: '+DateStr);

   NDS:=0;
   NDS10:=0;
   NDS20:=0;
   NDS_:=0;



 For c:=0 To P^.List^.Count-1 Do
  Begin
   DInfoMsgShkala('Формирую отчет за период с '+StartDate+' по '+StopDate+' ...',0,P^.List^.Count-1,c);
   PrintItog:=False;
   PrintDate:=False;

   s := P^.GetText(c,P^.List^.Count);

   As.EditPosition:=Copy(s,1+CClient+1,CDocNumer);
   As.D:=Copy(s,1+CClient+1+CDocNumer+1,CDate);
   LocNDS:=0;
   LocNDS10:=0;
   LocNDS20:=0;
   LocNDS_:=0;

   CalcNDSFromVozwrat(As,LocNDS,LocNDS20,LocNDS10,LocNDS_);


  NDS:=NDS+LocNDS;
  NDS10:=NDS10+LocNDS10;
  NDS20:=NDS20+LocNDS20;
  NDS_:=NDS_+LocNDS_;




   While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert(' ',s,k);
    End;
    LocZ:=LocZ+StrToReal(Copy(s,1+CClient+1+CDocNumer+1+CDate+1,10));
    LocP:=LocP+StrToReal(Copy(s,1+CClient+1+CDocNumer+1+CDate+1+10+1+10+1,10));

    Inc(LocDoc);

   If c<P^.List^.Count-1 Then
    Begin
     ws := P^.GetText(c+1,P^.List^.Count);
     TempStr:=Copy(ws,1+CClient+1+CDocNumer+1,CDate);
     If TempStr<>DateStr Then
      Begin
       DateStr:=TempStr;
       PrintDate:=True;
       PrintItog:=True;
      End;
    End
    Else PrintItog:=True;

    s[0]:=Chr(1+CClient+1+CDocNumer+1+CDate+1+10+1+10+1+10+1+CKto);

   Writeln(f,Space+s);

 If PrintItog Then
 Begin
 Writeln(f,Space,'Всего за: '+DateStr+' по РЦ: ',RecognizReal(LocZ,10,CMantissa), ' к выдаче: ',
 RecognizReal(LocP,10,CMantissa), ' док-тов: ',LocDoc:5,' -------');
 DateStr:=TempStr;
 LocZ:=0;
 LocP:=0;
 LocDoc:=0;
 End;
 If PrintDate Then
 Writeln(f,Space+'Дата: '+DateStr);

  End;
 Writeln(f,Space+'--------------------------------------------------------------------------------');
 Writeln(f,Space,'                                        Всего документов за период: ',AllDoc);
 Writeln(f,Space,'                                      Всего возвр. по Р/Ц составил: '+Recogniz(AllSumma));
 Writeln(f,Space,'                                            Всего к выдаче клиенту: '+Recogniz(AllVidano));


 s:='Всего НДС: '+RecognizReal(NDS,CIZena,CMAntissa)+' руб ';
 Writeln(f,Space+s);


 If Abs(NDS20)>0.009 Then
 Writeln(f,Space+'НДС 20%:'+RecognizReal(NDS20,CIZena,CMAntissa));


 If Abs(NDS10)>0.009 Then
 Writeln(f,Space+'НДС 10%:'+RecognizReal(NDS10,CIZena,CMAntissa));


 If Abs(NDS_)>0.009 Then
 Writeln(f,Space+'НДС прочее:'+RecognizReal(NDS_,CIZena,CMAntissa));

 Writeln(f);

 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'================================================================================');


 System.Close(f);
 NoInfoMSg;
 ViewAsText(Path^.Dat.ToTemp+'listvz.txt',True);
 Report(Path^.Dat.ToTemp+'listvz.txt','',1,False,False);
 End;
End;
*)


procedure TReestrVWindow.DrawCurrent;
{0 - наличная продажа скидка автоматическая
1 - наличная продажа скидка ручная
2 - закрытая консигнация авоматическая
3 - закрытая консигнация ручная
4 - открытая консигнация автоматическая
5 - открытая консигнация ручная}
VAr S : String;
    R : TRect;
    TTT,TempS : String;
    A:ArtikulStr;

Begin
If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
  Begin
  s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
  PrevCur:=S;

{Клиент              │Номе│  Дата  │Сумма Возв│  Скидка  │Расход    │Оператор    │С│Nдок│Дата Doc Agen S│В}
{12345678901234567890│1234│12345678│1234567890│1234567890│1234567890│123456789012│1│1234│12345678│1234│1│1│}


A:=Copy(s,1+CClient+1+CDocNumer+1+CDAte+1+(CIZena-5)+1+(CIZena-5)+1+(CIZena-5)+1+CKto+1+
COne+1,CDocNumer);

TempS:=Copy(s,1+CClient+1+CDocNumer+1+CDAte+1+(CIZena-5)+1+(CIZena-5)+1+(CIZena-5)+1+CKto+1+
COne+1+CDocNumer+1,CDate);

DelSpace(A);
DelZerro(A);

Dispose(ControlDocName,Done);
R.Assign(20, 20, 36, 21);
ControlDocName := New(PColoredText, Init(R, #3+A+' от '+TempS, $7E));
Insert(ControlDocName);



A:=Copy(s,1+CClient+1+CDocNumer+1+CDAte+1+(CIZena-5)+1+(CIZena-5)+1+(CIZena-5)+1+CKto+1+
COne+1+CDocNumer+1+CDate+1+CClientKod+1,COne);
Case StrToInt(a) Of
0:TempS:='Список';
1:TempS:='Тов.Чек*';
2:TempS:='Физ.Л*';
3:TempS:='СФ*';
4:TempS:='СФ Б';
5:TempS:='Дебит*';
6:TempS:='Дебит СФ*';
7:TempS:='Дебит';
8:TempS:='Дебит СФБ';
Else TempS:='???';
End;

Dispose(ControlDocSelector,Done);
R.Assign(57, 20, 66, 21);
ControlDocSelector := New(PColoredText, Init(R, #3+TempS, $7E));
Insert(ControlDocSelector);


A:=Copy(s,1+CClient+1+CDocNumer+1+CDAte+1+(CIZena-5)+1+(CIZena-5)+1+(CIZena-5)+1+CKto+1+
COne+1+CDocNumer+1+CDate+1,CClientKod);
TempS:=GetAgentField(FClient,A);
Dispose(ControlAgent,Done);
R.Assign(7, 21, 27, 22);
ControlAgent := New(PColoredText, Init(R, TempS, $7E));
Insert(ControlAgent);



A:=Copy(s,1+CClient+1+CDocNumer+1+CDAte+1+(CIZena-5)+1+(CIZena-5)+1+(CIZena-5)+1+CKto+1+
COne+1+CDocNumer+1+CDate+1+CClientKod+1+COne+1,COne);

Dispose(ControlSkidka,Done);
Case StrToInt(a) Of
0,2,4 : TempS:='Авто';
1,3,5 : TempS:='Ручн';
Else TempS:='???';
End;
R.Assign(70, 20, 75, 21);
ControlSkidka := New(PColoredText, Init(R, #3+TempS, $7E));
Insert(ControlSkidka);

Dispose(ControlVid,Done);
R.Assign(39, 21, 79, 22);
Case StrToInt(a) Of
0 : TempS:='наличная продажа скидка автоматическая';
1 : TempS:='наличная продажа скидка ручная';
2 : TempS:='закрытая консигнация авоматическая';
3 : TempS:='закрытая консигнация ручная';
4 : TempS:='открытая консигнация автоматическая';
5 : TempS:='открытая консигнация ручная';
Else TempS:='???';
End;
ControlVid := New(PColoredText, Init(R, #3+TempS, $7E));
Insert(ControlVid);

  End
  Else
   Begin
    If PStaticText(ControlDocName)^.Text^<>#3'???' Then
begin
Dispose(ControlDocName,Done);
R.Assign(20, 20, 36, 21);
ControlDocName := New(PColoredText, Init(R, #3+'???', $7E));
Insert(ControlDocName);

Dispose(ControlDocSelector,Done);
R.Assign(57, 20, 66, 21);
ControlDocSelector := New(PColoredText, Init(R, #3+'???', $7E));
Insert(ControlDocSelector);

Dispose(ControlAgent,Done);
R.Assign(7, 21, 27, 22);
ControlAgent := New(PColoredText, Init(R, #3+'???', $7E));
Insert(ControlAgent);


Dispose(ControlSkidka,Done);
R.Assign(70, 20, 75, 21);
ControlSkidka := New(PColoredText, Init(R, #3+'???', $7E));
Insert(ControlSkidka);

Dispose(ControlVid,Done);
R.Assign(39, 21, 79, 22);
ControlVid := New(PColoredText, Init(R, #3+'???', $7E));
Insert(ControlVid);
End;
   End;
End;




procedure TReestrVWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1,s2 : String;
    SDoc : ArtikulStr;
    SDate: TDateString;
    l : Boolean;
    FC:Byte;
    FS : AllStr;
    KK : Word;
    As : DocumentEdit;

begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbF7 : Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmDocFiltr;
              PutEvent(Event);
              ClearEvent(Event);
            End;
     kbF2 : Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmChangeDiapason;
              PutEvent(Event);
              ClearEvent(Event);
            End;
     kbEsc: Begin
              ClearFind;
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
    AboutCHM('54');
    ClearEvent(Event);
    End;


  cmPrintReestr:    Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CDocNumer+1,CDate);
                DelSpace(Assistent.D);
                If MessageBox(^M+#3'Печатать накладную возврата N '+Assistent.EditPosition+' от '+Assistent.D+'?',Nil,
                         mfConfirmation+mfOKCancel)=cmOk Then
                If NewPrintVozwrat(Assistent) Then PrintRashodOrder(Assistent);
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
              SortScreenList;
              ClearEvent(Event);
              PrevCur[0]:=#0;
              Redraw;
              End;
                            End;

  cmDocFiltr: if (User[92] or (CurrentPassword='00')) then
  Begin
              If Setup Then
              Begin
              ClearEvent(Event);
              SortScreenList;
              PrevCur[0]:=#0;
              Redraw;
              End;
                ClearEvent(Event);
             End;
 cmReestrReport:
     Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
             Case SelectImport(28) Of
             0: FormPReport(DocList);
             1: FormPReport3(DocList);
             Else;
             End;
            End
            End;
  cmFullView:    Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
              KK:=SelectImport(15);
              If kk>=2 Then
               Begin
                  ClearFind;
                  ClearEvent(Event);
                  Exit;
               End;
              If kk=1 Then  FullPreview
              Else
               Begin
                s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
                As.EditPosition:=Copy(s,1+CClient+1+CDocNumer+1+CDAte+1+(CIZena-5)+1+(CIZena-5)+1+(CIZena-5)+1+CKto+1+
                COne+1,CDocNumer);

                As.D:=Copy(s,1+CClient+1+CDocNumer+1+CDAte+1+(CIZena-5)+1+(CIZena-5)+1+(CIZena-5)+1+CKto+1+
                COne+1+CDocNumer+1,CDate);

                DelSpace(As.EditPosition);
                DelZerro(As.EditPosition);
                ViewMrk^.FullScreenMrk(As);
               End;
               ClearEvent(Event);
            End
            End;
     cmReestrVzw:Begin
                  ClearFind;
                  ClearEvent(Event);
                 End;
     cmRefresh  :Begin
                  ClearFind;
                  ClearEvent(Event);
                  Refresh;
                  SortScreenList;
                 End;
     cmCancel    : Begin
                 Dispose(NoScreenList,Done);
                 ClearFind;
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 ClearEvent(Event);
                End;
      Else;
      End;{evCommand}
      Else;
      End;{*Case*}

  if (Event.What = evBroadcast) and
    (Event.Command = cmReestrVzw) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);


  inherited HandleEvent(Event);


  If (Desktop^.Current=PView(DocReestrPWindow)) And (Event.What <> EvKeyDown) Then
             Begin


  if (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
       Begin
               s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
               If s <> PrevCur Then
                 Begin
                  PrevCur:=S;
                  DrawCurrent;
                 End;
       End
              Else
                  DrawCurrent;




                if (ControlSort^.State and sfFocused <> 0)Then
                    Begin
                        ControlSort^.GetData(Test);
                        If Test <> Sorting Then
                        Begin
                           ClearFind;
                           Sorting:=Test;
                           SortScreenList;
                           Redraw;
                        End;
                    End;

                if (ControlDirection^.State and sfFocused <> 0)Then
                    Begin
                        ControlDirection^.GetData(Test);
                        If Test <> Direction Then
                        Begin
                           ClearFind;
                           Direction:=Test;
                           SortScreenList;
                           Redraw;
                        End;
                    End;



             End;

end;



procedure TReestrVWindow.SortScreenList;
Var R : TRect;
    Doc : String;
    TempBox : PBox;
    CurStatus,CurDoc,CurVidVozw,CurOperation:Word;
    MStatus : MAska2;
    MOperation : MAska3;
    MVidVozwrata : Maska6;
    MFiltrDoc : Maska9;
    J : Word;
    ws,ws1 : String;
    LongDate : String[CIZena];

Begin
Dispose(ControlPeriod,Done);
R.Assign(14, 0, 65, 1);
ControlPeriod := New(PColoredText, Init(R, 'Реестр документов возврата'+
' с '+StartDAte+' по '+StopDAte, $4F));

ControlPeriod^.Options := ControlPeriod^.Options or ofCenterX;
Insert(ControlPeriod);

DInfoMsg('Сортирую документы...');


AllDoc[0]:=#0;
AllVidano[0]:=#0;
AllSumma[0]:=#0;
AllSkidka[0]:=#0;
AllZakupka[0]:=#0;


R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));


DocList^.NewList(Nil);
DocList^.NewList(New(PMyCollection, Init(0,1)));




If Direction=1 Then
DistanationSorting:=False
Else
DistanationSorting:=True;


WordToBit3(Operations,mOperation);
Convert3(mOperation);

WordToBit2(STatus,mStatus);
Convert2(mStatus);

WordToBit6(VidVozwrata,mVidVozwrata);
Convert6(mVidVozwrata);

WordToBit9(FiltrDoc,MFiltrDoc);
Convert9(MFiltrDoc);


If NoScreenList^.List^.Count>0 Then
Begin
{формируем отсортированный список}
For j:=0 to NoScreenList^.List^.Count-1 Do
Begin
 ws:=NoScreenList^.GEtText(j,NoScreenList^.List^.Count);


{Клиент              │Номе│  Дата  │Сумма Возв│  Скидка  │Расход    │Оператор   │С│Nдок│Дата Doc Agen S│В  OperattorSelector}
{12345678901234567890│1234│12345678│1234567890│1234567890│1234567890│123456789012│1│1234│12345678│1234│1│1│1}



CurVidVozw:=StrToInt(Copy(ws,1+CClient+1+CDocNumer+1+CDAte+1+(CIZena-5)+1+(CIZena-5)+1+(CIZena-5)+1+CKto+1+
COne+1+CDocNumer+1+CDate+1+CClientKod+1+COne+1,COne));

CurStatus:=StrToInt(Copy(ws,1+CClient+1+CDocNumer+1+CDAte+1+(CIZena-5)+1+(CIZena-5)+1+(CIZena-5)+1+CKto+1,
COne));

CurDoc:=StrToInt(Copy(ws,1+CClient+1+CDocNumer+1+CDAte+1+(CIZena-5)+1+(CIZena-5)+1+(CIZena-5)+1+CKto+1+
COne+1+CDocNumer+1+CDate+1+CClientKod+1,COne));
{
s:=s+'│'+E^.Dat.BasisDoc+'│'+E^.Dat.BAsisDate+'│'+AgentKod+'│'+IntToStr(E^.Dat.DocSelector,COne)+'│'+
IntToStr(E^.Dat.VidDocument,COne)+'│'+IntToStr(E^.Dat.OperatorSelector,COne);
}


CurOperation:=StrToInt(Copy(ws,1+CClient+1+CDocNumer+1+CDAte+1+(CIZena-5)+1+(CIZena-5)+1+(CIZena-5)+1+CKto+1+
COne+1+CDocNumer+1+CDate+1+CClientKod+1+COne+1+COne+1,COne));




LongDate:=Copy(ws,1+CClient+1+CDocNumer+1,CDate);

LongDate:=IntToStr(DateStringToDate(DateMask,LongDate),CDAte);

RFormat(LongDate,CDAte);

if (MOperation[CurOperation+1]=1) And (mVidVozwrata[CurVidVozw+1]=1) And
   (MFiltrDoc[CurDoc+1]=1) and (MStatus[CurStatus+1]=1) then
begin

Str(STrToInt(AllDoc)+1:CArtikul,AllDoc);

Str(StrToREal(AllSumma)+StrToReal(Copy(ws,1+CClient+1+CDocNumer+1+CDAte+1,10)):10:CMantissa,AllSumma);
Str(StrToREal(AllVidano)+StrToReal(Copy(ws,1+CClient+1+CDocNumer+1+CDAte+1+10+1+10+1,10)):10:CMantissa,AllVidano);
Str(StrToREal(AllSkidka)+StrToReal(Copy(ws,1+CClient+1+CDocNumer+1+CDAte+1+10+1,10)):10:CMantissa,AllSkidka);


Case Sorting Of
{клиент}
0:Begin
   System.Insert(LongDate,ws,1+CClient+1);
  End;
{номер документа}
1:Begin
   ws1:=Copy(ws,1+CClient+1,CDocNumer);
   System.Delete(ws,1+CClient+1,CDocNumer+1);
   ws:=LongDate+ws1+' '+ws;
  End;
{сумма отгрузки}
2:Begin
   ws1:=Copy(ws,1+CClient+1+CDocNumer+1+CDate+1,10);
   RFormatZerro(ws1,10);
   {System.Delete(ws,1+CClient+1+CDocNumer+1+CDate+1,CIZena+1);}
   ws:=ws1+' '+ws;
  End;
{сумма из кассы}
3:Begin
   ws1:=Copy(ws,1+CClient+1+CDocNumer+1+CDAte+1+10+1+10+1,10);
   RFormatZerro(ws1,10);
   {System.Delete(ws,1+CClient+1+CDocNumer+1+CDAte+1+CIZena+1,CIZena+1);}
   ws:=ws1+' '+ws;
  End;
Else;
End;{CAse}
  TempBox^.List^.Insert(NewStr(ws));
  TempBox^.SetRange(TempBox^.List^.Count);
end;{фильтр}
End;


{форматируем сформированый список под экранную форму}
If TempBox^.List^.Count>0 Then
Begin
For j:=0 to TempBox^.List^.Count-1 Do
Begin
  ws:=TempBox^.GEtText(j,TempBox^.List^.Count);

Case Sorting Of
{клиент}
0:Begin
   System.Delete(ws,1+CClient+1,CDate);
   ws:=ws;
  End;
{N документа}
1:Begin
   System.Delete(ws,1,CDate);
   ws1:=Copy(ws,1,CDocNumer);
   System.Delete(ws,1,CDocNumer+1);
   System.Insert(ws1+'│',ws,1+CClient+1);
  End;
{сумма отгрузки}
2:Begin
   ws1:=Copy(ws,1,10);
   System.Delete(ws,1,10+1);
   {System.Insert(ws1+'│',ws,1+CClient+1+CDocNumer+1+CDate+1);}
  End;
{сумма из кассы}
3:Begin
   ws1:=Copy(ws,1,10);
   System.Delete(ws,1,10+1);
   {System.Insert(ws1+'│',ws,1+CClient+1+CDocNumer+1+CDAte+1+CIZena+1);}
  End;
Else;
End;{CAse}

  DocList^.List^.Insert(NewStr(ws));
  DocList^.SetRange(DocList^.List^.Count);
End;
End;
End;{If TempCalcList^.List^.Count>0 Then}


Dispose(TempBox,Done);

NoInfoMsg;

DocList^.FocusItem(0);
DocList^.HelpCtx:=$F182;

Str(StrToReal(AllSumma):10:CMantissa,AllSumma);
DelSpace(AllSumma);
Str(StrToReal(AllZakupka):10:CMantissa,AllZakupka);
DelSpace(AllZakupka);

Str(StrToReal(AllSkidka):10:CMantissa,AllSkidka);
DelSpace(AllSkidka);

Str(StrToReal(AllVidano):10:CMantissa,AllVidano);
DelSpace(AllVidano);

Str(StrToInt(AllDoc):CArtikul,AllDoc);
DelSpace(AllDoc);

Dispose(ControlAllSumma,Done);
R.Assign(69, 22, 79, 23);
ControlAllSumma := New(PColoredText, Init(R, #3+AllSumma, $4E));
Insert(ControlAllSumma);

Dispose(ControlAllSkidka,Done);
R.Assign(16, 22, 26, 23);
ControlAllSkidka := New(PColoredText, Init(R, #3+AllSkidka, $4E));
Insert(ControlAllSkidka);

Dispose(ControlAllDoc,Done);
R.Assign(32, 22, 38, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);

Dispose(ControlVidano,Done);
R.Assign(48, 22, 58, 23);
ControlVidano := New(PColoredText, Init(R, #3+AllVidano, $4E));
Insert(ControlVidano);


Redraw;

DistanationSorting:=True;
PrevCur[0]:=#0;
End;






BEgin
Status:=3;{введен буфер}

Sorting:=0;{ключ сортировки}

Operations:=7;{клиент склад обмен}

RefreshTime:=20;

VidVozwrata:=63;{виды возвратов}

FiltrDoc:=511;{виды документов}

Direction:=0;

End.