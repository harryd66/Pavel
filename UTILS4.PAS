{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit utils4;


Interface

Uses Glob,ServStr,Dialogs,MyCalc,Drivers,ViewMrk;

Type
  PFindRezervWindow = ^TFindRezervWindow;
  TFindRezervWindow = object(TDialog)
      FFF     : ArtikulStr;
         Calc : PMyCalculator;
      ViewMrk : PFullScreenMrk;
   EnableEdit : Boolean;
      MakeEdit: Boolean;
      Function Start(LinkArt:ArtikulStr;Enable : Boolean{;SDoc:ArtikulStr}):Boolean;
      procedure Prn;
      procedure FormReport(P:PBox);
      Procedure CorrectZakaz;
      procedure FullPreview;
      procedure Refresh;
      procedure DrawCurrent;
      procedure HandleEvent(var Event: TEvent); virtual;
      Destructor Done;Virtual;
  end;



Type
  PLastZenaWindow = ^TLastZenaWindow;
  TLastZenaWindow = object(TDialog)
         FFF     : ArtikulStr;
         ClKod   : String[CClientKod];
         Calc    : PMyCalculator;
      ViewMrk : PFullScreenMrk;
      Function Start(LinkArt:ArtikulStr;Ck:ArtikulStr;VAr ReturnZena:AllStr):AllStr;
      procedure FullPreview;
      procedure DrawCurrent;
      procedure HandleEvent(var Event: TEvent); virtual;
      Destructor Done;Virtual;
  end;


Type
  PInputOtkatWindow = ^TInputOtkatWindow;
  TInputOtkatWindow = object(TDialog)
         Calc : PMyCalculator;
         SoSklada : AllStr;
       Function InputOtkat(Var L:PSuperMarketType):Boolean;
       procedure HandleEvent(var Event: TEvent); virtual;
       Destructor Done;Virtual;
  end;



Type
  PFindDolgWindow = ^TFindDolgWindow;
  TFindDolgWindow = object(TDialog)
      FFF     : ArtikulStr;
      Calc    : PMyCalculator;
      ViewMrk : PFullScreenMrk;
      Doc     : Word;
      Kol     : String[CKol+1];
      Summa   : AllStr;
      procedure Prn;
      procedure FormReport(P:PBox);
      procedure Start(LinkArt:ArtikulStr);
      procedure FullPreview;
      procedure HandleEvent(var Event: TEvent); virtual;
      Destructor Done;Virtual;
  end;




Procedure ImportClientInfo(Reg,Sel:Word);
Function FindZena:AllStr;
Procedure AddProtocolSpecMarket(PrevMArket,L:PSuperMarketType);
Procedure SelectAlgoritmZenInZakaz;
procedure RunDialUp;
Function SelectVidOplata(Var M3 : Maska4):Boolean;
function SelectVidProsmotra(VAr Res : Word) : Boolean;
Var Finding: String[CZena];
Function GetSrok(Start:TDAteString;Var DateEnd:LongInt):Boolean;
{Function InputBezNal(Var Bn:BezNal):Boolean;}
Procedure GlobalUnLockBaza;
Procedure GlobalLockBaza;
Function SelectKuda(VAr Res : Word):Boolean;
Function SpisDolgFromZerroDocRealiz(L:PSuperMarketType):Boolean;
Function EnterPrim:AllStr;
Procedure NewSkidkiIDX;
Procedure NewIDX;
Function SelectVidNalich:Byte;
Function SelectIDTip:Byte;
Function SelectPrz:Byte;
Function SelectSort:Byte;
Function SelectVidFullInfo(A:Word;M:Maska6):Word;
{Procedure ChekPost(st:AllStr);}
{Procedure ChekBank(st:AllStr);}
Function SelectImport(k:Word):Byte;
Function SelectOtdel(Var Otd:Word):Byte;
Function SelectForma3:Byte;
Function SelectForma4:Byte;
Procedure InputBuhKoeffizient;

implementation

Uses Serv,Objects,DbEngine,DbEngin2,MsgBox,NetDbEng,Protect,TpDate,Utils1,
     NetCall,Net,Net2,WinDos,MrkTool,MyView,Utils,Utils6,DbEngin3,
     ServStr2,Utils11,
     Views,ColorTxt,Validate,App,Printers,Vision8,Vision4,Tools,Prise,
	Memory,Dos,Utils5;


Var
    RezervWindow : PFindRezervWindow;
    LastWindow : PLastZenaWindow;
    OtkatWin : PInputOtkatWindow;
    FindDolgWindow : PFindDolgWindow;
    LinkList,NoScreenList : PBox;
    CurrentLine : TMyString;
    ControlAg,ControlDoc,ControlAllR,ControlAllPAckR : PView;
    AgentList : PBox;
    FindDolgList : PBox;
    TimeRashet : TDAteString;
    ControlR : Array[1..CDivision] Of PView;

    ControlOtkat : PView;
    OtkStr: String[CZenaZ];




Function TFindRezervWindow.Start(LinkArt:ArtikulStr;Enable : Boolean{;SDoc:ArtikulStr}):Boolean;
var
  R : TRect;
  R1 : LongInt;
  Control : PView;
  ZF : File;
  Z  : PBufZakazType;
  cc,Count,C,i : Word;
  ss,s,St : String;
  SrokIsp,OperatorNAme,ClientName,AgentName:AllStr;
  StopFind,Find : Boolean;
  Start1 : ArtikulStr;
  txt : Text;
  Skl : PSkladType;
  BBB : PBAzType;
  FindSertif : Boolean;
  VAluta : AllStr;
  Color : Word;
begin
{$IFNDEF RemoteClient}
Start:=False;

FindSertif:=False;
If GetRazdelStatus(Copy(LinkArt,1,CMantissa)) Then FindSertif:=True;

Assign(ZF,Path^.Dat.ToMarket+'Zakaz.db');
i:=IOResult;
Reset(ZF,SizeOf(ZakazType));
i:=IOResult;
If i<>0 Then
 BEgin
  MessageBox(^M+#3+'Ошибка открытия файла '+Path^.Dat.ToMarket+'Zakaz.db',Nil,mfError+
  mfCancelButton);
  Exit;
 End;

Start1[0]:=#0;
Assign(Txt,Path^.Dat.ToMarket+'Zakaz.gid');
i:=IOResult;
Reset(Txt);
i:=IOResult;
If i<>0 Then
 BEgin
  MessageBox(^M+#3+'Ошибка открытия файла-маршрутизатора '+Path^.Dat.ToMarket+'Zakaz.gid',Nil,mfError+
  mfCancelButton);
 End
 Else
  Begin
   Readln(txt,Start1);
   i:=IOResult;
   System.Close(Txt);
   i:=IOResult;
  End;

Seek(ZF,StrToInt(Start1));

R.Assign(0, 0, 0, 0);
NoScreenList := New(PBox, Init(R, 1, Nil));
NoScreenList^.NewList(New(PTextCollection, Init(0,1)));


While Not(Eof(ZF)) Do
 Begin
  DInfoMsgShkala('Просматриваю заказы по позиции '+LinkArt+'...',StrToInt(Start1),FileSize(ZF),
  FilePos(ZF));
  New(Z,Init);
  Count:=0;
  ReadBufZakaz(ZF,Z,Count);

For cc:=1 To Count Do
Begin
 If Z^.Point.Dat[cc].Oformlenie=0 Then
 Begin
With Z^.Point.Dat[cc] Do
Begin
   Find:=False;
   StopFind:=False;
If Not(FindSertif) Then
Begin
 For c:=1 To Amount Do
 Begin
    Find:=False;
   If MarketElement[c].BazKod=LinkArt Then
   Begin
    Find:=True;
    StopFind:=True;
   End;

  If Find Then
  Begin
   RFormatZerro(Document,CArtikul);

   AgentName:=GetAgentField(FClient,AgentKod);
   Format(AgentName,CClient);

   ClientName:=GetClientField(FClient,ClientKod,OperatorSelector);
   Format(ClientName,CClient);

   Format(DateC,CDate);

   OperatorName:=GetOperatorField(FNAme,Caption);
   Format(OperatorName,CKto);


   R1:=EndDate;
   SrokIsp:=DAteToDateString(DAteMask,DateStringToDate(DateMAsk,DateC)+EndDate);

   Format(SrokIsp,CDate);

   RFormat(MarketElement[c].Input.Kol,CKol);

   s[0]:=#0;

   s:=CalcPack(LinkArt,MarketElement[c].Input.Kol);
   RFormat(s,CPack);
   s:=ClientName+'│'+Document+'│'+DateC+'│'+SrokIsp+'│'+IntToStr(MarketElement[c].Input.InputDiviSion,COne)+'│'+
   MarketElement[c].Input.Kol+'│'+s+'│'+OperatorNAme+'│'+
   IntToStr(DocSelector,COne)+'│'+AgentName+' ('+AgentKod+')';

   NoScreenList^.List^.Insert(NewStr(s));
   NoScreenList^.SetRange(NoScreenList^.List^.Count);
  End;{find}
 End;{For по товару}
End;


If (FindSertif) Then
begin
 If not StopFind Then
 Begin
 For c:=1 To AmountS Do
 Begin
    Find:=False;
    If DocumentElement[c].BazKod=LinkArt Then
    Begin
     Find:=True;
     StopFind:=True;
    End;

    If Find Then
     Begin
      RFormatZerro(Document,CArtikul);

      AgentName:=GetAgentField(FClient,AgentKod);
      Format(AgentName,CClient);

      ClientName:=GetClientField(FClient,ClientKod,OperatorSelector);
      Format(ClientName,CClient);

      Format(DateC,CDate);

      OperatorName:=GetOperatorField(FNAme,Caption);
      Format(OperatorName,CKto);


      R1:=EndDate;
      SrokIsp:=DAteToDateString(DAteMask,DateStringToDate(DateMAsk,DateC)+EndDate);

      Format(SrokIsp,CDate);

      RFormat(DocumentElement[c].Input.Kol,CKol);

      s[0]:=#0;

      s:=CalcPack(LinkArt,DocumentElement[c].Input.Kol);
      RFormat(s,CPack);
      s:=ClientName+'│'+Document+'│'+DateC+'│'+SrokIsp+'│'+IntToStr(DocumentElement[c].Input.InputDiviSion,COne)+'│'+
      DocumentElement[c].Input.Kol+'│'+s+'│'+OperatorNAme+'│'+
      IntToStr(DocSelector,COne)+'│'+AgentName+' ('+AgentKod+')';

      NoScreenList^.List^.Insert(NewStr(s));
      NoScreenList^.SetRange(NoScreenList^.List^.Count);
     End;{find}
 End;{For по товару}
 End;{If Not StopFind}
End;

 End;{With}

End;{If Oformlenie=0}
End;{For}
  Dispose(Z,Done);
End;{While}
NoInfoMsg;

CurrentLine[0]:=#0;

i:=IOResult;
System.Close(ZF);
i:=IOResult;
NoScreenList^.FocusItem(0);
{закончили чтение заказов}


R.Assign(0, 1, 80, 22);
New(RezervWindow, Init(R, 'Искомое наименование забронировано в следующих заказах'));
RezervWindow^.Options := RezervWindow^.Options or ofCenterX or ofCenterY;
RezervWindow^.HelpCtx:=$F322;
RezervWindow^.FFF:=LinkArt;
RezervWindow^.EnableEdit:=Enable;
RezervWindow^.MakeEdit:=False;

If Enable Then
  EnableCommands([cmEdit])
Else
  DisableCommands([cmEdit]);

R.Assign(1, 13, 79, 14);
Control := New(PColoredText, Init(R, '─────────────────────────────────────'+
     '─────────────────────────────────────────', $7F));
RezervWindow^.Insert(Control);



R.Assign(61, 3, 78, 5);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
RezervWindow^.Insert(Control);



R.Assign(78, 7, 79, 12);
Control := New(PScrollBar, Init(R));
RezervWindow^.Insert(Control);

R.Assign(2, 7, 78, 12);
LinkList := New(PBox, Init(R, 1, PScrollbar(Control)));
LinkList^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList^.List^.Count-1>=0 Then
 For c:=0 To NoScreenList^.List^.Count-1 Do
  Begin
   s:=NoScreenList^.GetText(c,NoScreenList^.List^.Count);
   LinkList^.List^.Insert(NewStr(s));
   LinkList^.SetRange(LinkList^.List^.Count);
  End;
LinkList^.FocusItem(0);
RezervWindow^.Insert(LinkList);

Dispose(NoScreenList,Done);

  R.Assign(2, 6, 76, 7);
  RezervWindow^.Insert(New(PLabel, Init(R, 'Клиент               Заказ   Дата   Срок До  О Колич  Упаковок   Оператор',
  LinkList)));


R.Assign(1, 1, 54, 2);
st:=GetIdField(FNAme,LinkArt);
s:=GetIdField(FNAme2,LinkArt);
DelSpaceRight(st);
DelSpaceRight(s);
st:=St+' '+s;
Control := New(PColoredText, Init(R, st, $7E));
RezervWindow^.Insert(Control);

R.Assign(59, 1, 63, 2);
Control := New(PColoredText, Init(R, 'Код:', $74));
RezervWindow^.Insert(Control);

R.Assign(63, 1, 68, 2);
Control := New(PColoredText, Init(R, #3+LinkArt, $7E));
RezervWindow^.Insert(Control);

R.Assign(1, 3, 11, 4);
Control := New(PColoredText, Init(R, 'На складе:', $74));
RezervWindow^.Insert(Control);

R.Assign(11, 3, 60, 4);
Control := New(PColoredText, Init(R, '│     │     │     │     │     │     │'+
     '     │     │', $7F));
RezervWindow^.Insert(Control);

R.Assign(4, 4, 11, 5);
Control := New(PColoredText, Init(R, 'Резерв:', $74));
RezervWindow^.Insert(Control);



New(Skl,Init);
Skl^.Dat.BazKod:=LinkArt;
GetSkladRecord(Skl);

New(BBB,Init);
GetBazElement(LinkArt,BBB^.DAt);

For c:=1 To CDivision Do
Begin
 Str(StrToInt(Skl^.Dat.Input.Division[c]):CKOl,Skl^.Dat.Input.Division[c]);
 DelSpace(Skl^.Dat.Input.Division[c]);
 RFormat(Skl^.Dat.Input.Division[c],CKol);
 DelSpace(Skl^.Dat.Input.Division[c]);
 Str(StrToInt(Skl^.Dat.Input.DivisionR[c]):CKOl,Skl^.Dat.Input.DivisionR[c]);
 DelSpace(Skl^.Dat.Input.DivisionR[c]);
 RFormat(Skl^.Dat.Input.DivisionR[c],CKol);
 DelSpace(Skl^.Dat.Input.DivisionR[c]);
End;

 Str(StrToInt(Skl^.Dat.Input.Kol):CKOl,Skl^.Dat.Input.Kol);
 Str(StrToInt(Skl^.Dat.Input.KolR):CKOl,Skl^.Dat.Input.KolR);

 DelSpace(Skl^.Dat.Input.Kol);
 DelSpace(Skl^.Dat.Input.KolR);


R.Assign(12, 3, 17, 4);
Control := New(PColoredText, Init(R, #3+Skl^.Dat.Input.Division[1], $1F));
RezervWindow^.Insert(Control);

R.Assign(18, 3, 23, 4);
Control := New(PColoredText, Init(R, #3+Skl^.Dat.Input.Division[2], $1F));
RezervWindow^.Insert(Control);

R.Assign(24, 3, 29, 4);
Control := New(PColoredText, Init(R, #3+Skl^.Dat.Input.Division[3], $1F));
RezervWindow^.Insert(Control);

R.Assign(30, 3, 35, 4);
Control := New(PColoredText, Init(R, #3+Skl^.Dat.Input.Division[4], $1F));
RezervWindow^.Insert(Control);

R.Assign(36, 3, 41, 4);
Control := New(PColoredText, Init(R, #3+Skl^.Dat.Input.Division[5], $1F));
RezervWindow^.Insert(Control);

R.Assign(42, 3, 47, 4);
Control := New(PColoredText, Init(R, #3+Skl^.Dat.Input.Division[6], $1F));
RezervWindow^.Insert(Control);

R.Assign(48, 3, 53, 4);
Control := New(PColoredText, Init(R, #3+Skl^.Dat.Input.Division[7], $1F));
RezervWindow^.Insert(Control);

R.Assign(54, 3, 59, 4);
Control := New(PColoredText, Init(R, #3+Skl^.Dat.Input.Division[8], $1F));
RezervWindow^.Insert(Control);

R.Assign(11, 4, 60, 5);
Control := New(PColoredText, Init(R, '│     │     │     │     │     │     │'+
     '     │     │', $7F));
RezervWindow^.Insert(Control);

R.Assign(12, 4, 17, 5);
ControlR[1] := New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[1], $13));
RezervWindow^.Insert(ControlR[1]);

R.Assign(18, 4, 23, 5);
ControlR[2] := New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[2], $13));
RezervWindow^.Insert(ControlR[2]);

R.Assign(24, 4, 29, 5);
ControlR[3] := New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[3], $13));
RezervWindow^.Insert(ControlR[3]);

R.Assign(30, 4, 35, 5);
ControlR[4] := New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[4], $13));
RezervWindow^.Insert(ControlR[4]);

R.Assign(36, 4, 41, 5);
ControlR[5] := New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[5], $13));
RezervWindow^.Insert(ControlR[5]);

R.Assign(42, 4, 47, 5);
ControlR[6] := New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[6], $13));
RezervWindow^.Insert(ControlR[6]);

R.Assign(48, 4, 53, 5);
ControlR[7]:= New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[7], $13));
RezervWindow^.Insert(ControlR[7]);

R.Assign(54, 4, 59, 5);
ControlR[8] := New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[8], $13));
RezervWindow^.Insert(ControlR[8]);


R.Assign(11, 5, 60, 6);
Control := New(PColoredText, Init(R, '└─────┴─────┴─────┴─────┴─────┴─────┴'+
     '─────┴─────┘', $7F));
RezervWindow^.Insert(Control);


R.Assign(11, 2, 60, 3);
Control := New(PColoredText, Init(R, '┌──1──┬──2──┬──3──┬──4──┬──5──┬──6──┬'+
     '──7──┬──8──┐', $7F));
RezervWindow^.Insert(Control);

R.Assign(1, 2, 11, 3);
Control := New(PColoredText, Init(R, 'Отделение:', $74));
RezervWindow^.Insert(Control);

R.Assign(62, 2, 67, 3);
Control := New(PColoredText, Init(R, 'Штуки', $7F));
RezervWindow^.Insert(Control);

R.Assign(69, 2, 77, 3);
Control := New(PColoredText, Init(R, 'Упаковки', $7F));
RezervWindow^.Insert(Control);

R.Assign(61, 3, 68, 4);
Control := New(PColoredText, Init(R, #3+Skl^.Dat.Input.Kol, $1F));
RezervWindow^.Insert(Control);

R.Assign(61, 4, 68, 5);
ControlAllR := New(PColoredText, Init(R, #3+Skl^.Dat.Input.KolR, $13));
RezervWindow^.Insert(ControlAllR);


s:=CalcPack(LinkArt,Skl^.Dat.Input.KolR);
DelSpace(S);

R.Assign(69, 4, 78, 5);
ControlAllPackR := New(PColoredText, Init(R, #3+s, $13));
RezervWindow^.Insert(ControlAllPackR);

s:=CalcPack(LinkArt,Skl^.Dat.Input.Kol);
DelSpace(S);

R.Assign(69, 3, 78, 4);
Control:= New(PColoredText, Init(R, #3+s, $1F));
RezervWindow^.Insert(Control);

MyStr(StrToREal(Skl^.Dat.Input.R_Zena),CZena,CMAntissa,Skl^.Dat.Input.R_Zena);
MyStr(StrToREal(Skl^.Dat.Input.Spec_Zena),CZena,CMAntissa,Skl^.Dat.Input.Spec_Zena);
MyStr(StrToREal(Skl^.Dat.Input.Zakupka),CZenaZ,CMAntissaZ,Skl^.Dat.Input.Zakupka);
MyStr(StrToREal(Skl^.Dat.Input.Zakupka2),CZenaZ,CMAntissaZ,Skl^.Dat.Input.Zakupka2);

If Not (EnableZakupka=1) Then
 Begin
  Skl^.Dat.Input.Zakupka:=CodeZakupka;
  Skl^.Dat.Input.Zakupka2:=CodeZakupka;
 End;

DelSpace(Skl^.Dat.Input.R_Zena);
DelSpace(Skl^.Dat.Input.Spec_Zena);
DelSpace(Skl^.Dat.Input.Zakupka);
DelSpace(Skl^.Dat.Input.Zakupka2);

R.Assign(27, 14, 30, 15);
Control := New(PColoredText, Init(R, 'ЗЦ:', $74));
RezervWindow^.Insert(Control);

R.Assign(30, 14, 40, 15);
Control := New(PColoredText, Init(R, Skl^.Dat.Input.Zakupka, $7E));
RezervWindow^.Insert(Control);

R.Assign(41, 14, 45, 15);
Control := New(PColoredText, Init(R, 'ЗЦ2:', $74));
RezervWindow^.Insert(Control);

R.Assign(45, 14, 55, 15);
Control := New(PColoredText, Init(R, Skl^.Dat.Input.Zakupka2, $7E));
RezervWindow^.Insert(Control);

R.Assign(56, 14, 59, 15);
Control := New(PColoredText, Init(R, 'РЦ:', $74));
RezervWindow^.Insert(Control);

R.Assign(59, 14, 67, 15);
Control := New(PColoredText, Init(R, Skl^.Dat.Input.R_Zena, $7E));
RezervWindow^.Insert(Control);

R.Assign(68, 14, 71, 15);
Control := New(PColoredText, Init(R, 'СЦ:', $74));
RezervWindow^.Insert(Control);

R.Assign(71, 14, 79, 15);
Control := New(PColoredText, Init(R, Skl^.Dat.Input.Spec_Zena, $7E));
RezervWindow^.Insert(Control);

Case Skl^.Dat.Input.USD Of
0:VAluta:='Руб.';
1:VAluta:='USD';
Else VAluta:='???';
End;
MyStr(StrToREal(Skl^.Dat.Input.GRZena),CZenaZ,CMAntissaZ,Skl^.Dat.Input.GRZena);
DelSpace(Skl^.Dat.Input.GRZena);
R.Assign(1, 14, 8, 15);
Control := New(PColoredText, Init(R, 'Валюта:', $74));
RezervWindow^.Insert(Control);

R.Assign(8, 14, 12, 15);
Control := New(PColoredText, Init(R, #3+VAluta, $7E));
RezervWindow^.Insert(Control);

R.Assign(13, 14, 16, 15);
Control := New(PColoredText, Init(R, 'ГР:', $74));
RezervWindow^.Insert(Control);

R.Assign(16, 14, 26, 15);
Control := New(PColoredText, Init(R, Skl^.Dat.Input.GRZena, $7E));
RezervWindow^.Insert(Control);




R.Assign(1, 19, 12, 20);
Control := New(PColoredText, Init(R, 'Сертификат:', $74));
RezervWindow^.Insert(Control);

R.Assign(12, 19, 73, 20);
Control := New(PColoredText, Init(R, GetIdField(FFFNAme,Skl^.Dat.Input.NSertif)+' ('+
     +Skl^.Dat.Input.NSertif+')', $7E));
RezervWindow^.Insert(Control);

R.Assign(13, 20, 20, 21);
Control := New(PColoredText, Init(R, ' Марка:', $74));
RezervWindow^.Insert(Control);

Case Skl^.Dat.Input.RegionMarka Of
0:VAluta:='Нет';
1:VAluta:='Есть';
Else VAluta:='???';
End;


R.Assign(20, 20, 24, 21);
Control := New(PColoredText, Init(R, #3+VAluta, $5F));
RezervWindow^.Insert(Control);

R.Assign(24, 20, 34, 21);
Control := New(PColoredText, Init(R, ' Акциз.сб:', $74));
RezervWindow^.Insert(Control);

MyStr(StrToREal(Skl^.Dat.Input.AkzisSbor),CZenaZ,CMAntissaZ,Skl^.Dat.Input.AkzisSbor);
DelSpace(Skl^.Dat.Input.AkzisSbor);

MyStr(StrToREal(Skl^.Dat.Input.ZenaMarki),CZenaZ,CMAntissaZ,Skl^.Dat.Input.ZenaMarki);
DelSpace(Skl^.Dat.Input.ZenaMarki);

R.Assign(34, 20, 44, 21);
Control := New(PColoredText, Init(R, Skl^.Dat.Input.AkzisSbor, $7E));
RezervWindow^.Insert(Control);

R.Assign(44, 20, 56, 21);
Control := New(PColoredText, Init(R, ' Цена марки:', $74));
RezervWindow^.Insert(Control);

R.Assign(56, 20, 66, 21);
Control := New(PColoredText, Init(R, Skl^.Dat.Input.ZenaMarki, $7E));
RezervWindow^.Insert(Control);

DelSpace(Skl^.Dat.Input.StrihKod);
R.Assign(46, 15, 49, 16);
Control := New(PColoredText, Init(R, 'ШК:', $74));
RezervWindow^.Insert(Control);

R.Assign(49, 15, 67, 16);
Control := New(PColoredText, Init(R, Skl^.Dat.Input.StrihKod, $7E));
RezervWindow^.Insert(Control);

R.Assign(1, 15, 5, 16);
Control := New(PColoredText, Init(R, 'ГТД:', $74));
RezervWindow^.Insert(Control);

R.Assign(5, 15, 45, 16);
Control := New(PColoredText, Init(R, GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD), $7E));
RezervWindow^.Insert(Control);

R.Assign(1, 16, 7, 17);
Control := New(PColoredText, Init(R, Seria_Akzis^+':', $74));
RezervWindow^.Insert(Control);

ss:=GetMarkaField(FMarka,Skl^.Dat.Input.Marka);
DelSpaceRight(ss);
Format(ss,33);
R.Assign(7, 16, 40, 17);
Control := New(PColoredText, Init(R, ss, $7E));
RezervWindow^.Insert(Control);

R.Assign(41, 16, 52, 17);
Control := New(PColoredText, Init(R, 'Выработано:', $74));
RezervWindow^.Insert(Control);

DelSpaceRight(Skl^.Dat.Input.Virabotano);
R.Assign(52, 16, 60, 17);
Control := New(PColoredText, Init(R, Skl^.Dat.Input.Virabotano, $7E));
RezervWindow^.Insert(Control);

R.Assign(61, 16, 71, 17);
Control := New(PColoredText, Init(R, 'Реализ.до:', $74));
RezervWindow^.Insert(Control);

DelSpaceRight(Skl^.Dat.Input.Godnost);
R.Assign(71, 16, 79, 17);
Control := New(PColoredText, Init(R, Skl^.Dat.Input.Godnost, $7E));
RezervWindow^.Insert(Control);

R.Assign(1, 17, 11, 18);
Control := New(PColoredText, Init(R, 'Производ.:', $74));
RezervWindow^.Insert(Control);

{DelSpaceRight(Skl1^.Dat.Input.Post);}
ss:=GetPostField(FPost,BBB^.Dat.PostKod);
Format(ss,13);
R.Assign(11, 17, 24, 18);
Control := New(PColoredText, Init(R, ss{Skl1^.Dat.Input.Post}, $7E));
RezervWindow^.Insert(Control);

R.Assign(25, 17, 45, 18);
Control := New(PColoredText, Init(R, 'Фирма-производитель:', $74));
RezervWindow^.Insert(Control);

ss:=GetFirmaPostField(FFirmaPost,BBB^.Dat.FirmaPostKod);
R.Assign(45, 17, 79, 18);
Control := New(PColoredText, Init(R, ss, $7E));
RezervWindow^.Insert(Control);

R.Assign(1, 18, 12, 19);
Control := New(PColoredText, Init(R, 'Спец.марка:', $74));
RezervWindow^.Insert(Control);

{DelSpaceRight(Skl^.Dat.Input.SpecMarka);}
ss:=GetSpecMarkaField(FSpecMarka,Skl^.Dat.Input.SpecMarka);
Format(ss,67);
R.Assign(12, 18, 79, 19);
Control := New(PColoredText, Init(R,ss, $7E));
RezervWindow^.Insert(Control);


Skl^.Dat.BazKod:=LinkArt;

R.Assign(3, 13, 15, 14);
Control := New(PColoredText, Init(R, 'Консигнация:', $7F));
RezervWindow^.Insert(Control);

CAse BBB^.Dat.EnableDebit Of
0:Begin VAluta:='Запрещена'; Color:=$5F; End;
1:Begin VAluta:='Разрешена'; Color:=$7F; End;
Else Begin VAluta:='???'; Color:=$5F; End;;
End;

R.Assign(15, 13, 24, 14);
Control := New(PColoredText, Init(R, #3+VAluta, Color));
RezervWindow^.Insert(Control);

R.Assign(26, 13, 53, 14);
Control := New(PColoredText, Init(R, 'Карточка товара (текущая)', $4F));
Control^.Options := Control^.Options or ofCenterX;
RezervWindow^.Insert(Control);

R.Assign(55, 13, 63, 14);
Control := New(PColoredText, Init(R, 'Продажа:', $7F));
RezervWindow^.Insert(Control);

CAse BBB^.Dat.MArket Of
0:Begin VAluta:='Запрещена'; Color:=$5F; End;
1:Begin VAluta:='Разрешена'; Color:=$7F; End;
Else Begin VAluta:='???'; Color:=$5F; End;;
End;


R.Assign(63, 13, 72, 14);
Control := New(PColoredText, Init(R, #3+Valuta, Color));
RezervWindow^.Insert(Control);





Dispose(BBB,Done);
Dispose(Skl,Done);



R.Assign(60, 12, 69, 13);
ControlDoc := New(PColoredText, Init(R, #3+'', $7E));
RezervWindow^.Insert(ControlDoc);

R.Assign(45, 12, 60, 13);
Control := New(PColoredText, Init(R, ' Вид документа:', $74));
RezervWindow^.Insert(Control);

R.Assign(9, 12, 16, 13);
Control := New(PColoredText, Init(R, ' Агент:', $74));
RezervWindow^.Insert(Control);

R.Assign(16, 12, 43, 13);
ControlAg := New(PColoredText, Init(R, #3+'', $7E));
RezervWindow^.Insert(ControlAg);

RezervWindow^.SelectNext(False);

CurrentLine[0]:=#0;

c:=Desktop^.ExecView(RezervWindow);

  EnableCommands([cmEdit]);

Start:=RezervWindow^.MakeEdit;

Dispose(Control,Done);
Dispose(RezervWindow,Done);
{$ELSE}

Start:=False;
{$ENDIF}
End;





procedure TFindRezervWindow.FormReport(P:PBox);
Const Space='      ';
Var f : text;
         SVersia,Skidka,Summa,ws,s : String;
         c,k : Word;
         Open : String;
Begin
If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path^.Dat.ToTemp+'posbron.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
        MessageBox(#3^m+#3+'Не могу создать файл '+Path^.Dat.ToTemp+'posbron.txt'+
        ' Код: '+IntToStr(c,3),Nil,mfError+mfCancelButton);
   Exit;
  End;
 Writeln(f,Header+Space+ 'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-01');
 Writeln(f);
{     s:=ClientName+'│'+Document+'│'+DateC+'│'+SrokIsp+'│'+IntToStr(DocumentElement[c].Input.InputDiviSion,COne)+'│'+
      DocumentElement[c].Input.Kol+'│'+s+'│'+OperatorNAme+'│'+
      IntToStr(DocSelector,COne)+'│'+AgentName+' ('+AgentKod+')';}
 Writeln(f,Space+'СПИСОК ЗАКАЗОВ, в КОТОРЫХ ЗАБРОНИРОВАНО ИСКОМОЕ НАИМЕНОВАНИЕ ТОВАРА');
 Writeln(f,Space+'Искомое наименование:'+GetIdField(FFFName,RezervWindow^.FFF));
 Writeln(f);
 Writeln(f,Space+'┌────────────────────┬─────┬────────┬────────┬─┬─────┬─────────┬────────────┐');
 Writeln(f,Space+'│Клиент              │Номер│  Дата  │ Срок До│О│Колич│ Упаковок│    Оператор│');
 Writeln(f,Space+'└────────────────────┴─────┴────────┴────────┴─┴─────┴─────────┴────────────┘'+HeaderStop);
 For c:=0 To P^.List^.Count-1 Do
  Begin
        s := P^.GetText(c,P^.List^.Count);
        While Pos('│',s)>0 Do
         Begin
          k:=Pos('│',s);
          System.Delete(s,k,1);
          System.Insert(SeparatorChar,s,k);
         End;
   s[0]:=Chr(CCLient+1+CArtikul+1+CDate+1+CDate+1+COne+1+CKol+1+CPack+1+CKto);
   Writeln(f,Space+' '+s);
  End;
 Writeln(f,Space+'─────────────────────────────────────────────────────────────────────────────');
 Writeln(f);
 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'==============================================================================');
 System.Close(f);
 ReportNew(Path^.Dat.ToTemp+'posbron.txt','',1,False,False);
 End;
End;


procedure TFindRezervWindow.Refresh;
Var SKol : ArtikulStr;
    c : Word;
    R : TRect;
    s : String;
    Skl : PSkladType;
begin
New(Skl,Init);
Skl^.Dat.BazKod:=RezervWindow^.FFF;
GetSkladRecord(Skl);

For c:=1 To CDivision Do
Begin
 Str(StrToInt(Skl^.Dat.Input.DivisionR[c]):CKOl,Skl^.Dat.Input.DivisionR[c]);
 DelSpace(Skl^.Dat.Input.DivisionR[c]);
 RFormat(Skl^.Dat.Input.DivisionR[c],CKol);
 DelSpace(Skl^.Dat.Input.DivisionR[c]);
End;

 Str(StrToInt(Skl^.Dat.Input.KolR):CKOl,Skl^.Dat.Input.KolR);

 DelSpace(Skl^.Dat.Input.KolR);


Dispose(ControlR[1],Done);
R.Assign(12, 4, 17, 5);
ControlR[1] := New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[1], $13));
RezervWindow^.Insert(ControlR[1]);

Dispose(ControlR[2],Done);
R.Assign(18, 4, 23, 5);
ControlR[2] := New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[2], $13));
RezervWindow^.Insert(ControlR[2]);


Dispose(ControlR[3],Done);
R.Assign(24, 4, 29, 5);
ControlR[3] := New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[3], $13));
RezervWindow^.Insert(ControlR[3]);

Dispose(ControlR[4],Done);
R.Assign(30, 4, 35, 5);
ControlR[4] := New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[4], $13));
RezervWindow^.Insert(ControlR[4]);

Dispose(ControlR[5],Done);
R.Assign(36, 4, 41, 5);
ControlR[5] := New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[5], $13));
RezervWindow^.Insert(ControlR[5]);

Dispose(ControlR[6],Done);
R.Assign(42, 4, 47, 5);
ControlR[6] := New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[6], $13));
RezervWindow^.Insert(ControlR[6]);

Dispose(ControlR[7],Done);
R.Assign(48, 4, 53, 5);
ControlR[7]:= New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[7], $13));
RezervWindow^.Insert(ControlR[7]);

Dispose(ControlR[8],Done);
R.Assign(54, 4, 59, 5);
ControlR[8] := New(PColoredText, Init(R, #3+Skl^.Dat.Input.DivisionR[8], $13));
RezervWindow^.Insert(ControlR[8]);


Dispose(ControlAllR,Done);
R.Assign(61, 4, 68, 5);
ControlAllR := New(PColoredText, Init(R, #3+Skl^.Dat.Input.KolR, $13));
RezervWindow^.Insert(ControlAllR);


s:=CalcPack(Skl^.DAt.BAzKod,Skl^.Dat.Input.KolR);
DelSpace(S);

Dispose(ControlAllPAckR,Done);
R.Assign(69, 4, 78, 5);
ControlAllPAckR := New(PColoredText, Init(R, #3+s, $13));
RezervWindow^.Insert(ControlAllPAckR);


Dispose(Skl,Done);
Redraw;

End;


procedure TFindRezervWindow.FullPreview;
Var Ass : DocumentEditZ;
    E : PSuperMarketType;
    R : TRect;
         c : Word;
    P : PBox;
    ws : TMyString;
    Find : Boolean;
    SKolish,SDoc,SClientKod,SAgentKod : ArtikulStr;
    s,SCommentr : String;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];
    v : Byte;


Begin
If (LinkList^.List<>Nil)And(LinkList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count),1+CClient+1,CDocNumer+1);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  s:=LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count);
  Ass.D:=Copy(s,1+CClient+1+(CDocNumer+1)+1,CDate);;
  DelSpace(Ass.D);
  ViewMrk^.FullScreenMrk(Ass,True);
End;
End;


procedure RecalcZakaz(VAr Pz:PZakazType);
Var c : Word;
    SZenaBak : TDateString;
begin
 With Pz^.Dat Do
begin
   SertifSummaZ[0]:=#0;
   SertifSkidka[0]:=#0;
   SummaZ  [0]:=#0;
   Skidka  [0]:=#0;

 For c:=1 To Amount Do
  Begin
   SZenaBak:=Pz^.DAt.MArketElement[c].Input.Zena;
   Case SkidkaSelector Of
   0,2
    :Begin
      MyStr((StrToReal(Pz^.DAt.MArketElement[c].Input.Zena)/
       (1+StrToReal(Pz^.DAt.MArketElement[c].Input.Proz)/100)),CZena,CMantissa,SZenaBak);
     End;
   1:Begin
      MyStr(StrToReal(Pz^.DAt.MArketElement[c].Input.Zena)-
        StrToReal(Pz^.DAt.MArketElement[c].Input.Skidka),CZena,CMantissa,SZenaBak);
     End;
   Else;
   End;
   MyStr(StrToInt(Pz^.DAt.MArketElement[c].Input.Kol)*
        StrToReal(SZenaBak),CIZena,CMantissa,SummaZ);

   MyStr(StrToInt(Pz^.DAt.MArketElement[c].Input.Kol)*
        (StrToReal(Pz^.DAt.MArketElement[c].Input.Zena)-
	   StrToReal(SZenaBak)),CIZena,CMantissa,Skidka);
  End;{For}

 For c:=1 To AmountS Do
  Begin
   SZenaBak:=Pz^.DAt.DocumentElement[c].Input.Zena;
   Case SkidkaSelector Of
   0,2
    :Begin
      MyStr((StrToReal(Pz^.DAt.DocumentElement[c].Input.Zena)/
       (1+StrToReal(Pz^.DAt.DocumentElement[c].Input.Proz)/100)),CZena,CMantissa,SZenaBak);
     End;
   1:Begin
      MyStr(StrToReal(Pz^.DAt.DocumentElement[c].Input.Zena)-
        StrToReal(Pz^.DAt.DocumentElement[c].Input.Skidka),CZena,CMantissa,SZenaBak);
     End;
   Else;
   End;
   MyStr(StrToInt(Pz^.DAt.DocumentElement[c].Input.Kol)*
        StrToReal(SZenaBak),CIZena,CMantissa,SertifSummaZ);

   MyStr(StrToInt(Pz^.DAt.DocumentElement[c].Input.Kol)*
        (StrToReal(Pz^.DAt.DocumentElement[c].Input.Zena)-
	   StrToReal(SZenaBak)),CIZena,CMantissa,SertifSkidka);
  End;{For}

   DelSpace(SertifSummaZ);
   DelSpace(SertifSkidka);
   DelSpace(SummaZ);
   DelSpace(Skidka);


End;{With}


End;



procedure TFindRezervWindow.CorrectZakaz;
Label 1,2;
Var Ass : DocumentEditZ;
    Position,c : Word;
    Find : Boolean;

    DivisionNum: Word;
    DeltaKol,SKladKol,SkladKolR,SKolishBAk,SKolishNew : ArtikulStr;
    SZenaBak : TDateString;
    s : String;
    i,j : Byte;
    PZ : PZakazType;
    Event : TEvent;
    Msg : AllStr;
    Skl : PSkladType;
    Kdx : PSkladTypeNew;
    fSkl : SkladFileType;
    fKdx : File Of SkladTypeNew;
      R : TRect;
    Dlg : PDialog;
Control : PView;
AddSertif: Boolean;
   PrevStatus : Word;

Begin
If (LinkList^.List<>Nil)And(LinkList^.List^.Count>=1) Then
Begin
  s:=LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count);
  Ass.EditPosition:=Copy(LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count),1+CClient+1,CDocNumer+1);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  s:=LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count);
  Ass.D:=Copy(s,1+CClient+1+(CDocNumer+1)+1,CDate);
  DelSpace(Ass.D);

  DivisionNum:=StrToInt(Copy(s,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDAte+1,COne));

  If Not(TestOtdel(DivisionNum)) Then
   Begin
          Sound(100);
          DinfoMsg('Опреации с отделения '+IntToStr(DivisionNum,COne)+' запрещены!',False);
          Delay(300);
          NoSound;
          ClearEvent(Event);
          repeat
           Application^.GetEvent(Event);
          until (Event.What <> evNothing) And (Event.Command<>cmMenu);
          NoInfoMsg;
          ClearEvent(Event);
          Exit;
   End;


  AddSertif:=GetRazdelStatus(RezervWindow^.FFF);


  If Not SetNameLock(RezervWindow^.FFF,Msg) Then
   Begin
    Beep;
    DInfoMsg('Позиция ['+RezervWindow^.FFF+'] используется'+Msg+'. Не могу заблокировать!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
   End;


    New(PZ,Init);
    i:=LockZakaz(Ass.EditPosition,PZ);
    If I=2 Then
     Begin

      Repeat
      Until SetNameUnLock(RezervWindow^.FFF);

      Beep;
      DInfoMsg('Не могу заблокировать заказ N '+PZ^.Dat.Document+' от '+PZ^.Dat.DateC+
         '. Попробуйте повторить!',False);
      Dispose(PZ,Done);
      ClearEvent(Event);
      Application^.GetEvent(Event);
      ClearEvent(Event);
      repeat
        Application^.GetEvent(Event);
      until (Event.What <> evNothing) And (Event.Command<>cmMenu);
      NoInfoMsg;
      ClearEvent(Event);
      Exit;
     End;



{определяем что это товар иди документ AddSertif}

Position := 0;{искомая позиция в заказе}
Find := False;
{ищем позицию в заказе}
If Not AddSertif Then
 Begin
  For c:=1 To Pz^.DAt.Amount Do
   Begin
    If (Pz^.DAt.MarketElement[c].BazKod=RezervWindow^.FFF) And
       (Pz^.DAt.MarketElement[c].Input.InputDiviSion=DivisionNum) Then
       Begin
        Position:=c;
        Find:=True;
CAse Pz^.Dat.SkidkaSelector Of
0,2: Begin
      MyStr((StrToReal(Pz^.DAt.MArketElement[c].Input.Zena)/
       (1+StrToReal(Pz^.DAt.MArketElement[c].Input.Proz)/100)),CZena,CMantissa,SZenaBak);
     End;
1:MyStr(StrToReal(Pz^.DAt.MArketElement[c].Input.Zena)-
        StrToReal(Pz^.DAt.MArketElement[c].Input.Skidka),CZena,CMantissa,SZenaBak);
Else;
End;
SKolishBAk:=Pz^.DAt.MArketElement[c].Input.Kol;
        Break;
       End;
   End;
 End
 Else
   Begin
    For c:=1 To Pz^.DAt.AmountS Do
     Begin
    If (Pz^.DAt.DocumentElement[c].BazKod=RezervWindow^.FFF) And
       (Pz^.DAt.DocumentElement[c].Input.InputDiviSion=DivisionNum) Then
       Begin
        Position:=c;
        Find:=True;

CAse Pz^.Dat.SkidkaSelector Of
0,2: Begin
      MyStr((StrToReal(Pz^.DAt.DocumentElement[c].Input.Zena)/
       (1+StrToReal(Pz^.DAt.DocumentElement[c].Input.Proz)/100)),CZena,CMantissa,SZenaBak);
     End;
1:MyStr(StrToReal(Pz^.DAt.DocumentElement[c].Input.Zena)-
        StrToReal(Pz^.DAt.DocumentElement[c].Input.Skidka),CZena,CMantissa,SZenaBak);
Else;
End;
SKolishBAk:=Pz^.DAt.DocumentElement[c].Input.Kol;
        Break;
       End;

     End;
   End;

If Not(Find) Then
 Begin
  MessageBox(#3+'С момента поиска забронированного товара, произошли изменения!'+
  ' Искомая позиция удалена из заказа!',Nil,mfError+mfCancelButton);
  Goto 1;
 ENd;



New(Skl,Init);
New(Kdx,Init);
Skl^.Dat.BazKod:=RezervWindow^.FFF;
Kdx^.Dat.BazKod:=StrToInt(RezervWindow^.FFF);
GetSkladRecord(Skl);
GetSkladNewRecord(Kdx);

SkladKol:=Skl^.DAt.Input.Division[DivisionNum];
SkladKolR:=Skl^.DAt.Input.DivisionR[DivisionNum];

DelSpace(SKolishBAk);
SKOlishNew:=SKolishBAk;
DelSpace(SkladKol);
DelSpace(SkladKolR);


{определяем количество в заказе и на складе}

{открываем окно корректировки}

PrevStatus :=Glob.Status;
Glob.Status:=DocEdit;

2:
R.Assign(14, 13, 65, 17);
New(Dlg, Init(R, 'Коррекция забронированного товара'));
Dlg^.Options := Dlg^.Options or ofCenterX;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E002;

R.Assign(19, 1, 26, 2);
Control := New(PInputLine, Init(R, CKOl));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(1, 1, 19, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Новое количество:', Control)));

R.Assign(27, 1, 49, 2);
Control := New(PColoredText, Init(R, 'Цена к оплате:'+SZenaBak, $31));
Dlg^.Insert(Control);

R.Assign(7, 2, 19, 3);
Control := New(PStaticText, Init(R, 'В отделении:'));
Dlg^.Insert(Control);


Str(StrToInt(SkladKol)-StrToInt(SkladKolR):CKOl,DeltaKol);

R.Assign(20, 2, 35, 3);
Control := New(PColoredText, Init(R, IntToStr(StrToInt(SkladKol)-StrToInt(SkladKolR),CKol)+' ('+SkladKolR+')', $31));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);

Dlg^.SetDAta(SKolishNew);

c:=Desktop^.ExecView(Dlg);
If c<>cmCAncel Then
Begin
 Dlg^.GetDAta(SKolishNew);
 DelSpace(SKolishNew);
 SKolishNew:=IntToStr(StrToInt(SKolishNew),CKol);


 If StrToInt(SKolishNew)>StrToInt(SKolishBAk) Then
 If (StrToInt(SKolishNew)-StrToInt(SKolishBAk))>StrToInt(DeltaKol) Then
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  MessageBox(^M+#3+'На складе в отделении ['+IntToStr(DivisionNum,COne)+'] отсутсвует такое количество товара!',
  Nil,mfError+mfCancelButton);
  Goto 2;
 End;

 DInfoMsg('Сохраняю изменения...',True);

 Assign(fskl,Path^.Dat.TOSklad+Copy(Skl^.DAt.BazKod,1,2)+'.db');
 c:=IoResult;
 Reset(fskl);
 c:=IoResult;
 If c<>0 Then
  Begin
   NoInfoMsg;
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   MessageBox(^M+#3+'Ошибка открытия '+Path^.Dat.TOSklad+Copy(Skl^.DAt.BazKod,1,2)+'.db'+
   ' Код:'+IntToStr(c,CKol),Nil,mfError+mfCancelButton);
   Goto 2;
  End;


 Assign(fKdx,Path^.Dat.TOIndex+Copy(Skl^.DAt.BazKod,1,2)+'.kdx');
 c:=IoResult;
 Reset(fkdx);
 c:=IoResult;
 If c<>0 Then
  Begin
   NoInfoMsg;
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   MessageBox(^M+#3+'Ошибка открытия '+Path^.Dat.TOIndex+Copy(Skl^.DAt.BazKod,1,2)+'.kdx'+
   ' Код:'+IntToStr(c,CKol),Nil,mfError+mfCancelButton);
   Goto 2;
  End;

 Seek(fskl,StrToInt(Copy(Skl^.DAt.BazKod,3,3)));
 Seek(fkdx,StrToInt(Copy(Skl^.DAt.BazKod,3,3)));

   Repeat
   Pause(1);
   Until NetCall.Lock(fskl,FilePos(fskl)*SizeOf(SkladType),SizeOf(SkladType));

   Str(StrToInt(Skl^.Dat.Input.DivisionR[DivisionNum])-
       StrToInt(SKolishBAk)+StrToInt(SKolishNew):CKOl,Skl^.Dat.Input.DivisionR[DivisionNum]);
       DelSpace(Skl^.Dat.Input.DivisionR[DivisionNum]);

   Skl^.Dat.Input.KolR[0]:=#0;
   For c:=1 To CDiviSion Do
   Str((StrToInt(Skl^.Dat.Input.KolR)+StrToInt(Skl^.Dat.Input.DivisionR[c])):CKol,
   Skl^.Dat.Input.KolR);

        With Kdx^.DAt Do
        Begin
         For j:=1 To CDivision Do Division[j]:=StrToInt(Skl^.Dat.Input.Division[j]);
         For j:=1 To CDivision Do DivisionR[j]:=StrToInt(Skl^.Dat.Input.DivisionR[j]);
        End;


   Write(fskl,Skl^.Dat);
   Write(fKdx,Kdx^.Dat);

   Repeat
    netcall.UnLock(fskl,(FilePos(fskl)-1)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

 c:=IoResult;
   System.Close(Fskl);
 c:=IoResult;
 c:=IoResult;
   System.Close(FKdx);
 c:=IoResult;


  If Not(WriteZakazCor(PZ)) Then
   Begin
    MessageBox(^M+#3+'Ошибка записи в файл копии заказов!'^M+ClicProgrammer^,Nil,mfError+mfCancelButton);
   End;

   Inc(Pz^.Dat.Versia);
{вносим изменения в новую версию заказа}
If Not AddSertif Then
  Pz^.DAt.MarketElement[Position].Input.Kol:=SKolishNew
Else
  Pz^.DAt.DocumentElement[Position].Input.Kol:=SKolishNew;

  {вставить пересчет суммы заказа}
  {конец пересчета суммы заказа}

  PZ^.DAt.DateM:=Fdate;
  PZ^.DAt.TimeM:=Times;
  Pz^.Dat.Caption:=CurrentPassword;

  If Not(LockAndWriteZakaz(PZ)) Then
   Begin
    MessageBox(^M+#3+'Ошибка записи в файл заказов!'^M+ClicProgrammer^,Nil,mfError+mfCancelButton);
   End;

   NoInfoMsg;

 {изменяем строчку в листе}
   RFormat(SKolishNew,CKol);
   System.Delete(s,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDAte+1+COne+1,CKol);
   System.Insert(SKolishNew,s,1+CClient+1+(CDocNumer+1)+1+CDate+1+CDAte+1+COne+1);

 LinkList^.List^.AtFree(LinkList^.Focused);
 LinkList^.SetRange(LinkList^.List^.Count);
 LinkList^.List^.Insert(NewStr(S));
 LinkList^.SetRange(LinkList^.List^.Count);


 AddProtocol('Корректировка заказа N '+Ass.EditPosition+' {позиционная}',
 'Для кода '+RezervWindow^.FFF,
 'Было: '+SKolishBak+'  Стало: '+SKolishNew);

 RecalcZakaz(Pz);

 RezervWindow^.MakeEdit:=True;


 {персчитываем сумму заказа
  и сохраняем новую версия заказа}



End;
Dispose(Control,Done);
Dispose(Dlg,Done);
Dispose(Skl,Done);
Dispose(Kdx,Done);
Glob.Status:=PrevStatus;


1:
{снятие блокировок и уничтожение динамических объектов}


  Repeat
  Until (UnLockZakaz(PZ^.Dat.Document) in [0,2]);


  Repeat
  Until SetNameUnLock(RezervWindow^.FFF);

  Dispose(PZ,done);

End;

End;


procedure TFindRezervWindow.Prn;
Var Ass : DocumentEditZ;
    E : PSuperMarketType;
    R : TRect;
    f : MarketFileType;
         c : Word;
    P : PBox;
    ws : TMyString;
    Find : Boolean;
    SKolish,SDoc,SClientKod,SAgentKod : ArtikulStr;
    s,SCommentr : String;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];
    v : Byte;


Begin
If (LinkList^.List<>Nil)And(LinkList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count),1+CClient+1,CDocNumer+1);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  s:=LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count);
  Ass.D:=Copy(s,1+CClient+1+(CDocNumer+1)+1,CDate);;
  DelSpace(Ass.D);
  PrintZakaz(Ass,NprintC^.DAt.CopyZakaz);
End;
End;



procedure TFindRezervWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var s : String;
    Prom : Word;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
  cmEdit : Begin
            CorrectZakaz;
            Refresh;
           End;
  cmPrintReestr :Begin
     If (LinkList^.State and sfFocused <> 0) And (LinkList^.List<>Nil)And(LinkList^.List^.Count>=1) Then
            Begin
              Prn;
            End;
                 End;
  cmReestrReport:Begin

     If  (LinkList^.List<>Nil)And(LinkList^.List^.Count>=1) Then
            Begin
              FormReport(LinkList);
            End
                 End;

  cmFullView:    Begin
                 ClearFind;
     If (LinkList^.State and sfFocused <> 0) And (LinkList^.List<>Nil)And(LinkList^.List^.Count>=1) Then
            Begin
              FullPreview;
            End
            End;
        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);

 If (Desktop^.Current=PView(RezervWindow)) And (Event.What <> EvKeyDown) Then
     Begin
      DrawCurrent;
     End;
End;

Procedure TFindRezervWindow.DrawCurrent;
Var st : String;
    R : TRect;
Begin
if (LinkList^.List<>Nil)And(LinkList^.List^.Count>=1) Then
 Begin
  st:=LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count);
  If st <> CurrentLine Then
   Begin
    CurrentLine:=St;
    st:=Copy(CurrentLine,1+CClient+1+CArtikul+1+CDate+1+CDAte+1+COne+1+CKol+1+CPAck+1+CKto+1,COne);
    DelSpaceRight(st);
    Case StrToInt(St) Of
    0:st:='Список';
    1:st:='Тов.Чек';
    2:st:='Физ.лицо';
    3:st:='СФ';
    4:st:='СФБ';
    5:st:='Дебит*';
    6:st:='Дебит СФ';
    7:st:='Дебит';
    8:st:='Дебит СФБ';
    Else;
    End;
    Dispose(ControlDoc,Done);
    R.Assign(60, 12, 69, 13);
    ControlDoc := New(PColoredText, Init(R, #3+st, $7E));
    RezervWindow^.Insert(ControlDoc);


    st:=Copy(CurrentLine,1+CClient+1+CArtikul+1+CDate+1+CDAte+1+COne+1+CKol+1+CPAck+1+CKto+1+COne+1,CClient+7);
    DelSpaceRight(st);

    Dispose(ControlAg,Done);
    R.Assign(16, 12, 43, 13);
    ControlAg := New(PColoredText, Init(R, #3+st, $7E));
    RezervWindow^.Insert(ControlAg);

   End;
 End
 Else
  Begin
   PStaticText(ControlDoc)^.GetText(st);
   If St<>#3+'???' Then
   Begin
    Dispose(ControlDoc,Done);
    R.Assign(60, 12, 69, 13);
    ControlDoc := New(PColoredText, Init(R, #3+'???', $7E));
    RezervWindow^.Insert(ControlDoc);

    Dispose(ControlAg,Done);
    R.Assign(16, 12, 43, 13);
    ControlAg := New(PColoredText, Init(R, #3+'???', $7E));
    RezervWindow^.Insert(ControlAg);
   End;
  End;
End;


Destructor TFindRezervWindow.Done;
Begin
TDialog.Done;
End;




procedure TFindDolgWindow.Start(LinkArt:ArtikulStr);
var
  R : TRect;
  R1 : LongInt;
  Control : PView;
  ClientElement:PBufClientType;
  ClientFile : File;
  jjj,cc,Count,C,i : Word;
  s,St : String;
  SrokIsp,OperatorNAme,ClientName,AgentName:AllStr;
  Find : Boolean;
  Start1 : ArtikulStr;
  txt : Text;
  Skl : PSkladType;
  FindSertif : Boolean;
  ClientList : PBox;

  E : PBufRealizasiaType;
  RealFile : File;
  TKol,AllDoc,ii : Word;
  AllSumma,AllSaldo, MKol,VKol,MSum, MSaldo, MDelta : AllStr;


Function TestAgent(Cod:ArtikulStr):Boolean;
Var L : Boolean;
    i : word;
    st : String;
Begin
TestAgent:=False;
If (AgentList^.List^.Count-1)>=0 Then
Begin
For i:=0 To AgentList^.List^.Count-1 Do
 Begin
  st:=AgentList^.GetText(i,AgentList^.List^.Count);
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    TestAgent:=True;
    Break;
   End;{St=Cod}
 End;
End;
End;


Function CalcKol(Er:RealizasiaType;Var s:AllStr):Word;
Var i,j : Word;
    E : PSuperMarketType;
    As : DocumentEditZ;

Begin
CalcKol:=0;
i:=0;
s[0]:=#0;

As.EditPosition:=Er.Market.Document;
As.D:=DateToDateString(DateMAsk,Er.Market.DateC);
New(E,Init);
If GetMArket1(As,E) Then
Begin
 For j:=1 To E^.DAt.Amount Do
  Begin
   If E^.Dat.MarketElement[j].BazKod=LinkArt Then
    Begin
     i:=i+StrToInt(E^.Dat.MarketElement[j].Input.Kol);

     {вычисляем цену}
     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
       MyStr((StrToReal(E^.Dat.MarketElement[j].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[j].Input.Proz)/100)),CZena,CMantissa,E^.Dat.MarketElement[j].Input.Zena)
     Else
       MyStr((StrToReal(E^.Dat.MarketElement[j].Input.Zena)-
       StrToReal(E^.Dat.MarketElement[j].Input.Skidka)),CZena,CMantissa,E^.Dat.MarketElement[j].Input.Zena);

     {подсчитываем сумму}
     MyStr(StrToReal(s)+StrToInt(E^.Dat.MarketElement[j].Input.Kol)*
     StrToReal(E^.Dat.MarketElement[j].Input.Zena),CIZena,CMantissa,s);

    End;
  End;{For}
End;{GetMArket1}

Dispose(E,Done);
CalcKol:=i;
End;{Function}


VAr     CLF : File;
    ClE : PBufKurzClientType;
    SArtik : ArtikulStr;
     BakFileMode : Word;

begin

If GetRazdelStatus(Copy(LinkArt,1,CMantissa)) Then
 Begin
  MessageBox(^M+#3'Сопроводительная документация не отпускается с отсрочкой платежа!',Nil,mfError+
  mfCancelButton);
  Exit;
 End;


R.Assign(0, 0, 0, 0);
AgentList := New(PBox, Init(R, 1, Nil));
AgentList^.NewList(New(PTextCollection, Init(0,1)));

If Not(SelectionAgent(AgentList)) Then
 Begin
  Dispose(AgentList,Done);
  Exit;
 End;

{Алгоритм
1.Просматриваем долги всех клиентов как в расчете сводных долгов по агентам
2.Поднимаем каждую накладную и просматриваем ее на предмет поиска
  искомой позиции товара
3.Если нашли тогда поднимаем просмотр возвратов по этой накладной,
  и считаем количество возвращенного товара
4.Формируем строчку если сальдо не равно "0" и вставляем ее в список}

{читаем базу клиентов}
R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClF,Path^.Dat.ToClientBaseIndex+'Client.idx');
c:=IOResult;
Reset (ClF,SizeOf(KurzClientType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(ClF)) Do
 Begin
     DInfoMsgShkala('Читаю списки консигнаторов. Ждите... ',0,FileSize(CLF),FilePos(ClF));
     New(ClE,Init);
     Count:=0;
     ReadBufKurzClient(ClF,ClE,Count);
For jjj:=1 To Count Do
Begin
  If ClE^.Point.Dat[jjj].Employ Then
   Begin
     Format(ClE^.Point.Dat[jjj].Name,CClient);
     SArtik:=IntToStr(ClE^.Point.Dat[jjj].Kod,CClientKod);
     RFormatZerro(SArtik,CClientKod);
     ClientList^.List^.Insert(NewStr(ClE^.Point.Dat[jjj].Name+'│'+SArtik));
     ClientList^.SetRange(ClientList^.List^.Count);
   End;
End;{For}
  Dispose(ClE,Done);
 End;{While}
System.Close(ClF);
End
Else
 Begin
  NoInfoMsg;
  Dispose(AgentList,Done);
  Dispose(ClientList,Done);
  MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов '+Path^.Dat.ToClient+'Client.db',Nil,mfError+mfCancelButton);
  Exit;
 End;

NoInfoMsg;

{список куда будем добавлять найденный товар}
R.Assign(0, 0, 0, 0);
NoScreenList := New(PBox, Init(R, 1, Nil));
NoScreenList^.NewList(New(PTextCollection, Init(0,1)));

AllSaldo[0]:=#0;
AllSumma[0]:=#0;
AllDoc:=0;

If ((ClientList^.List^.Count-1)>=0) Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    DInfoMsgShkala('Рассчитываю долги клиентов. Ждите... ',0,ClientList^.List^.Count-1,c);
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);

 BakFileMode:=FileMode;
 FileMode:=$42;
    Assign(RealFile,Path^.Dat.ToDolg+st+'.dlg');
    ii:=IOResult;
    Reset(RealFile,SizeOf(RealizasiaType));
    ii:=IOResult;
FileMode:=BakFileMode;
    If ii=0 Then
     Begin
      While Not(Eof(RealFile)) Do
       Begin
        New(E,Init);
        Count:=0;
        BlockRead(RealFile,E^.Point,BufferDLG,Count);
        For jjj:=1 To Count Do
        Begin
         If (E^.Point.Dat[jjj].Market.Active) And Not(E^.Point.Dat[jjj].Full) Then
         Begin

          If (TestAgent(E^.Point.Dat[jjj].Market.AgentKod)) Then
           Begin
            {подсчитываем продажи}
            TKol:=CalcKol(E^.Point.Dat[jjj],MSum);
            MKol:=IntToStr(TKol,CKol);

            {если были продажи подсчитываем возвраты}
            If TKol>0 Then
             Begin
              VKol[0]:=#0;
              CalcReturnPositionAll
              (E^.Point.Dat[jjj].Market.Document,
               DateToDateString(DateMAsk,E^.Point.Dat[jjj].Market.DateC),
                     {E^.Point.Dat[jjj].Market.DateC,}
               E^.Point.Dat[jjj].Market.ClientKod,
                  LinkArt,
                     E^.Point.Dat[jjj].Market.OperatorSelector,
                        VKol);

               Str(StrToInt(VKol):CKOl,VKol);
               Str(StrToInt(MKol):CKOl,MKol);
               Inc(AllDoc);

               {сумма долга в денежном эквиваленте по сумме к оплате}
               MyStr(StrToReal(MSum)/StrToInt(MKol)*(StrToint(MKol)-StrToInt(VKol)),
                        CIZena-5,CMantissa,MSum);
               MyStr(StrToReal(AllSumma)+StrToReal(MSum),CIZena-2,CMantissa,AllSumma);

               {сальдо в количественном выражении}
               Str(StrToint(MKol)-StrToInt(VKol):CKol,MSaldo);

               Str(StrToInt(AllSaldo)+StrToInt(MSaldo):Ckol+1,AllSaldo);

               Str(DateStringToDate(DAteMask,FDAte)-
                   E^.Point.Dat[jjj].MArket.Srok:CLitrMantissa+1,MDelta);
               s:=GetClientField(FClient,E^.Point.Dat[jjj].Market.ClientKod,E^.Point.Dat[jjj].Market.OperatorSelector);
               Format(s,CClient);

               RFormatZerro(E^.Point.Dat[jjj].Market.Document,CDocNumer);
               {Format(E^.Point.Dat[jjj].Market.DateC,CDAte);}
               Format(E^.Point.Dat[jjj].Market.ClientKod,CClientKod);
               s:=s+'│'+E^.Point.Dat[jjj].Market.ClientKod+'│'+
                                 E^.Point.Dat[jjj].Market.Document+'│'+
                        DateToDateString(DateMask,E^.Point.Dat[jjj].Market.DateC)
				    +'│'+
                        MKol+'│'+
                        VKol+'│'+
                                    MSaldo+'│'+
                        MSum+'│'+
                        MDelta+'│'+
                                    RealToStr(E^.Point.Dat[jjj].Dolg,
                                    CIZena-6,CMantissa);
               NoScreenList^.List^.Insert(NewStr(s));
               NoScreenList^.SetRange(NoScreenList^.List^.Count);
             End;{TKol>0}

           End;{TestElement проверка агента}
         End;{Active and Full}
        End;{For}
        Dispose(E,Done);
       End;{While}
      System.Close(RealFile);
     End;{ii=0}
   End;{For po ClientList}
 End;{ClientList^.List^.Count>0}
 NoInfoMsg;

TimeRashet:=Times;

Dispose(ClientList,Done);


R.Assign(2, 1, 78, 21);
New(FindDolgWindow, Init(R, 'Долги клиентов по позиции товара'));
FindDolgWindow^.Options := FindDolgWindow^.Options or ofCenterX or ofCenterY;

FindDolgWindow^.HelpCtx := $F271;
FindDolgWindow^.FFF := LinkArt;
FindDolgWindow^.Doc := AllDoc;
FindDolgWindow^.Kol := AllSaldo;
FindDolgWindow^.Summa := AllSumma;


R.Assign(75, 3, 76, 19);
Control := New(PScrollBar, Init(R));
FindDolgWindow^.Insert(Control);

R.Assign(1, 3, 75, 19);
FindDolgList := New(PBox, Init(R, 1, PScrollbar(Control)));
FindDolgList^.NewList(New(PTextCollection, Init(0,1)));


If (NoScreenList^.List^.Count-1)>=0 Then
For i:=0 To NoScreenList^.List^.Count-1 Do
 Begin
  s:=NoScreenList^.GetText(i,NoScreenList^.List^.Count);
  FindDolgList^.List^.Insert(NewStr(S));
  FindDolgList^.SetRange(FindDolgList^.List^.Count);
 End;

FindDolgWindow^.Insert(FindDolgList);
FindDolgList^.FocusItem(0);

Dispose(NoScreenList,Done);




  R.Assign(1, 2, 75, 3);
  FindDolgWindow^.Insert(New(PLabel, Init(R,'Клиент               Код   N     Дата   Отгр. Возвр. Долг Сумма долг. Del',
  FindDolgList)));

R.Assign(2, 1, 55, 2);
Control := New(PColoredText, Init(R, GetIdField(FFFName,LinkArt), $7E));
FindDolgWindow^.Insert(Control);

R.Assign(65, 1, 69, 2);
Control := New(PColoredText, Init(R, 'Код:', $74));
FindDolgWindow^.Insert(Control);

R.Assign(69, 1, 74, 2);
Control := New(PColoredText, Init(R, LinkArt, $7E));
FindDolgWindow^.Insert(Control);

R.Assign(45, 19, 75, 20);
Control := New(PColoredText, Init(R, ' Всего долг:              руб ', $74));
FindDolgWindow^.Insert(Control);

MyStr(StrToReal(AllSumma),CIZena-2,CMantissa,AllSumma);
DelSpace(AllSumma);
R.Assign(57, 19, 70, 20);
Control := New(PColoredText, Init(R, #3+AllSumma, $4E));
FindDolgWindow^.Insert(Control);


R.Assign(24, 19, 45, 20);
Control := New(PColoredText, Init(R, ' Всего долг:       шт', $74));
FindDolgWindow^.Insert(Control);

DelSpace(AllSaldo);
Str(StrToInt(AllSaldo):CKol,AllSaldo);
R.Assign(36, 19, 42, 20);
Control := New(PColoredText, Init(R, #3+AllSaldo , $4E));
FindDolgWindow^.Insert(Control);

R.Assign(1, 19, 19, 20);
Control := New(PColoredText, Init(R, ' Всего документов:', $74));
FindDolgWindow^.Insert(Control);

R.Assign(19, 19, 24, 20);
Control := New(PColoredText, Init(R, #3+IntToStr(AllDoc,CKol), $4E));
FindDolgWindow^.Insert(Control);

FindDolgWindow^.SelectNext(False);


c:=Desktop^.ExecView(FindDolgWindow);
Dispose(Control,Done);
Dispose(FindDolgList,Done);
Dispose(FindDolgWindow,Done);
Dispose(AgentList,Done);

End;{Procedure Start}


procedure TFindDolgWindow.FormReport(P:PBox);
Const Space='   ';
Var      f : text;
         s : String;
         agKod : AllStr;
         c,k : Word;
Begin
If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path^.Dat.ToTemp+'dolgtov.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
        MessageBox(#3^m+#3+'Не могу создать файл '+Path^.Dat.ToTemp+'dolgtov.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


 Writeln(f,Header+Space+ 'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-01');

 Writeln(f);

 Writeln(f,Space+'       СПРАВКА ПО НЕОПЛАЧЕННОМУ ТОВАРУ '+' на '+FDAte);

 Writeln(f,Space+'Время расчета:'+TimeRashet);
 Writeln(f);
 Writeln(f,Space+'Наименование товара:'+GetIdField(FFFNAme,FindDolgWindow^.FFF));
 Writeln(f,Space+'                Код:'+FindDolgWindow^.FFF+HeaderStop);
 Writeln(f);
 Writeln(f,Space+'Выбраны следующие агенты:');

 For c:=0 To AgentList^.List^.Count-1 Do
  Begin
   s:=AgentList^.GetText(c,AgentList^.List^.Count);
   AgKod:=Copy(s,1+1,CClientKod);
   S:=GetAgentField(FClient,AgKod);
   Format(s,CClient);
   s:=s+' ('+AgKod+')';
   Writeln(f,Space+s);
  End;

 Writeln(f,Header+
           Space+'┌────────────────────┬────┬────┬────────┬─────┬─────┬─────┬─────────┬────┬─────────┐');
 Writeln(f,Space+'│Клиент              │Код │Док.│  Дата  │Отгр.│Возвр│ Долг│ Долг,руб│Del │Ост.долга│');
 Writeln(f,Space+'└────────────────────┴────┴────┴────────┴─────┴─────┴─────┴─────────┴────┴─────────┘'+HeaderStop);


 For c:=0 To P^.List^.Count-1 Do
  Begin
     DInfoMsgShkala('Формирую отчет ...',0,P^.List^.Count-1,c);
     s := P^.GetText(c,P^.List^.Count);
     Writeln(f,Space+s);
  End;
 Writeln(f,Space+'────────────────────────────────────────────────────────────────────────────────────');


 Writeln(f,Space+'  Всего на сумму: ',RecognizReal(StrToReal(FindDolgWindow^.Summa),CIZena-2,CMantissa)+' руб ');
 Writeln(f,Space+'Всего количество: ',IntToStr(StrToInt(FindDolgWindow^.Kol),CKol+1)+' шт');
 Writeln(f,Space+'Всего документов: ',FindDolgWindow^.Doc:CKol+1);
 Writeln(f,Space);
 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'====================================================================================');

 System.Close(f);

 NoInfoMsg;
 ReportNew(Path^.Dat.ToTemp+'dolgtov.txt','',1,False,False);
 End;

End;






procedure TFindDolgWindow.FullPreview;
Var Ass : DocumentEditZ;
    E : PSuperMarketType;
    R : TRect;
    f : MarketFileType;
         c : Word;
    P : PBox;
    ws : TMyString;
    Find : Boolean;
    SKolish,SDoc,SClientKod,SAgentKod : ArtikulStr;
    s,SCommentr : String;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];
    v : Byte;


Begin
If (FindDolgList^.List<>Nil)And(FindDolgList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(FindDolgList^.GetText(FindDolgList^.Focused,FindDolgList^.List^.Count),1+CClient+1+CClientKod+1,
  CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  s:=FindDolgList^.GetText(FindDolgList^.Focused,FindDolgList^.List^.Count);
  Ass.D:=Copy(s,1+CClient+1+CClientKod+1+CDocNumer+1,CDate);;
  DelSpace(Ass.D);
  ViewMrk^.FullScreenMrk(Ass,False);
End;
End;


procedure TFindDolgWindow.Prn;
Var Ass : DocumentEditZ;
    s : String;


Begin
If (FindDolgList^.List<>Nil)And(FindDolgList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(FindDolgList^.GetText(FindDolgList^.Focused,FindDolgList^.List^.Count),1+CClient+1+CClientKod+1,
  CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  s:=FindDolgList^.GetText(FindDolgList^.Focused,FindDolgList^.List^.Count);
  Ass.D:=Copy(s,1+CClient+1+CClientKod+1+CDocNumer+1,CDate);;
  DelSpace(Ass.D);
  PrintNAkl(Ass,NprintC^.DAt.CopyNaklC);
End;
End;




procedure TFindDolgWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var s : String;
    Prom : Word;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
  cmLocalCalc:Calculator;

  cmPrintReestr :Begin
     If (FindDolgList^.State and sfFocused <> 0) And (FindDolgList^.List<>Nil)And(FindDolgList^.List^.Count>=1) Then
            Begin
              Prn;
            End;
                 End;
  cmReestrReport:Begin

     If  (FindDolgList^.List<>Nil)And(FindDolgList^.List^.Count>=1) Then
            Begin
              FormReport(FindDolgList);
            End
                 End;

  cmFullView:    Begin
                 ClearFind;
     If (FindDolgList^.State and sfFocused <> 0) And (FindDolgList^.List<>Nil)And(FindDolgList^.List^.Count>=1) Then
            Begin
              FullPreview;
            End
            End;
        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);

End;



Destructor TFindDolgWindow.Done;
Begin
TDialog.Done;
End;



Procedure ImportClientInfo(Reg,Sel:Word);
Const SeparatorChar=';';
Var f : ClientFileType;
    Rd : ClientType;
    s : String;
    txt : Text;
    i : LongInt;
Begin
Case Reg Of
0:begin
     Case Sel Of
     0:s:=Path^.Dat.ToClient+'Client.db';
     1:s:=Path^.Dat.ToClient+'Sklad.db';
     2:s:=Path^.Dat.ToClient+'Barter.db';
     Else;
     End;{CAse}

  end;
1:begin
       Case Sel Of
     0:s:=Path^.Dat.ToClient+'Make.db';
     1:s:=Path^.Dat.ToClient+'Sklad.db';
     2:s:=Path^.Dat.ToClient+'Barter.db';
     Else;
     End;{CAse}
  End;
Else;
End;{Case}
DInfoMsg('Импортирую данные. Ждите...',False);
Assign (F,s);
i:=IOResult;
Reset(f);
i:=IOResult;

If i<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка открытия '+s+'! (Код:'+IntToStr(i,CLitrMantissa)+')'+
  ClicProgrammer^,Nil,
  mfError+mfCancelButton);
  Exit;
 End;

Assign(txt,Path^.Dat.ToTemp+'impbaza.csv');
i:=IOResult;
Rewrite(txt);
i:=IOResult;
If i<>0 Then
 Begin
  Close(f);
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка создания '+Path^.Dat.ToTemp+'impbaza.csv'+'! (Код:'+IntToStr(i,CLitrMantissa)+')'+
  ClicProgrammer^,Nil,
  mfError+mfCancelButton);
  Exit;
 End;

Case Reg Of
0:begin
     Case Sel Of
     0:s:=SeparatorChar+'БАЗА КЛИЕНТОВ';
     1:s:=SeparatorChar+'БАЗА СКЛАДОВ';
     2:s:=SeparatorChar+'БАЗА КЛИЕНТОВ (БАРТЕР)';
     Else;
     End;{CAse}

  end;
1:begin
       Case Sel Of
     0:s:=SeparatorChar+'БАЗА ПОСТАВЩИКОВ';
     1:s:=SeparatorChar+'БАЗА СКЛАДОВ';
     2:s:=SeparatorChar+'БАЗА ПОСТАВЩИКА (БАРТЕР)';
     Else;
     End;{CAse}
  End;
Else;
End;{Case}
Writeln(txt,DosToWin(s));
Writeln(txt,DosToWin(s));

Write(txt,DosToWin('код склада'+SeparatorChar+
'код контрагента'+SeparatorChar+
'наименование контрагента'+SeparatorChar+
'полное наименование'+SeparatorChar+
'Vip'+SeparatorChar+
'последняя сверка'+SeparatorChar+
'статус'+SeparatorChar+
'период'+SeparatorChar+
'код 1с'+SeparatorChar+
'Дочерний'+SeparatorChar+
'От'+SeparatorChar+
'N договора'+SeparatorChar+
'Адрес фактический'+SeparatorChar+
'Лимит'+SeparatorChar+
'Консигнация'+SeparatorChar+
'Отгрузка'+SeparatorChar+
'Юр.лицо/ФизЛицо'+SeparatorChar+
'Адрес юридический'+SeparatorChar+
'Телефон'+SeparatorChar+
'расчетный счет'+SeparatorChar+
'банк'+SeparatorChar+
'_ИНН'+SeparatorChar+
'_КПП'+SeparatorChar+
'ОКОНХ'+SeparatorChar));

WriteLN(txt,DosToWin(
'ОКПО'+SeparatorChar+
'Лицензия'+SeparatorChar+
'Срок до'+SeparatorChar+
'Свидетельство'+SeparatorChar+
'Имен.падеж'+SeparatorChar+
'Дат.падеж'+SeparatorChar+
'Серия паспорта'+SeparatorChar+
'Номер паспорта'+SeparatorChar+
'Выдан'+SeparatorChar+
'Сообщение'+SeparatorChar+
'Автосообщение'+SeparatorChar+
'Почтовый каталог'+SeparatorChar+
'Авто генерация прайса'+SeparatorChar+
'Контроль ценовых ограничений'+SeparatorChar+
'Контроль минимальных наценок'+SeparatorChar+
'Min%'+SeparatorChar+
'Коэффициент'+SeparatorChar+
'Дата именений'+SeparatorChar+
'Время именений'+SeparatorChar+
'Оператор'+SeparatorChar+
'Регион'+SeparatorChar+
'Код региона'+SeparatorChar+
'Маршрут'+SeparatorChar+
'Код маршрута'+SeparatorChar)
);

While not(eof(f)) do
 begin
  readclient(f,Rd);
  If rd.Employ Then
   Begin
    With Rd Do
     Begin
Write(txt,DosToWin(Rek^.Dat.Kod)+SeparatorChar);

Format(Kod,CCLientKod);
Write(txt,DosToWin(Kod)+SeparatorChar);

Format(Name,CClient);
ChangeSeparator(NAme);
Write(txt,DosToWin(Name)+SeparatorChar);

ChangeSeparator(FullNAme);
Write(txt,DosToWin(FullName)+SeparatorChar);

Format(VIP,CIZena);
Write(txt,DosToWin(VIP)+SeparatorChar);

Format(LastSverka,CDate);
Write(txt,DosToWin(LastSverka)+SeparatorChar);

Case Status of
0:Write(Txt,DosToWin('Активный ')+SeparatorChar);
1:Write(Txt,DosToWin('Пассивный ')+SeparatorChar);
2:Write(Txt,DosToWin('СБ ')+SeparatorChar);
3:Write(Txt,DosToWin('Закрыт ')+SeparatorChar);
4:Write(Txt,DosToWin('? ')+SeparatorChar);
Else;
End;

Format(Period,CLitrMantissa);
Write(txt,DosToWin(Period)+SeparatorChar);


ChangeSeparator(BuchKod);
Write(txt,DosToWin(BUCHKOd)+SeparatorChar);

Write(txt,DosToWin(IntToStr(Main,COne))+SeparatorChar);


ChangeSeparator(FantomKod);
Write(txt,DosToWin(FantomKod)+SeparatorChar);


ChangeSeparator(Dogovor);
Format(Dogovor,CAll);
Write(txt,DosToWin(Dogovor)+SeparatorChar);


ChangeSeparator(AdressF);
Format(AdressF,CAll);
Write(txt,DosToWin(AdressF)+SeparatorChar);


Format(Limit,CIZena);
Write(txt,DosToWin(Limit)+SeparatorChar);

If Debit=0 Then Write(Txt,DosToWin('Консигнация запрещена')+SeparatorChar)
Else Write(Txt,DosToWin('Консигнация разрешена')+SeparatorChar);

If Otgruska=0 Then Write(Txt,DosToWin('Отгрузка запрещена')+SeparatorChar)
Else Write(Txt,DosToWin('Отгрузка разрешена')+SeparatorChar);

If Lizo=0 Then Write(Txt,DosToWin('Юр.лицо ')+SeparatorChar)
else Write(Txt,DosToWin('Физ.лицо')+SeparatorChar);


ChangeSeparator(Adress);
Write(txt,DosToWin(Adress)+SeparatorChar);

ChangeSeparator(Telefon);
Write(txt,DosToWin(Telefon)+SeparatorChar);

ChangeSeparator(R_Sh);
Write(txt,'_'+DosToWin(R_Sh)+SeparatorChar);

ChangeSeparator(BankKod);
Write(txt,DosToWin(GetBankField(FBank,BankKod))+SeparatorChar);

ChangeSeparator(INN);
Write(txt,'_'+DosToWin(INN)+SeparatorChar);

ChangeSeparator(KPP);
Write(txt,'_'+DosToWin(INN)+SeparatorChar);

ChangeSeparator(OKONH);
Write(txt,DosToWin(OKONH)+SeparatorChar);

ChangeSeparator(OKPO);
Write(txt,DosToWin(OKPO)+SeparatorChar);

ChangeSeparator(Enviropment);
Write(txt,DosToWin(Enviropment)+SeparatorChar);

ChangeSeparator(SrokLizensia);
Write(txt,DosToWin(SrokLizensia)+SeparatorChar);

ChangeSeparator(Svidetelstvo);
Write(txt,DosToWin(Svidetelstvo)+SeparatorChar);

ChangeSeparator(VekselIP);
Write(txt,DosToWin(VekselIP)+SeparatorChar);

ChangeSeparator(VekselDP);
Write(txt,DosToWin(VekselDP)+SeparatorChar);

ChangeSeparator(Seria);
Write(txt,DosToWin(Seria)+SeparatorChar);

ChangeSeparator(Passport);
Write(txt,DosToWin(Passport)+SeparatorChar);

ChangeSeparator(Vidan);
Write(txt,DosToWin(Vidan)+SeparatorChar);


ChangeSeparator(Messages);
Write(txt,DosToWin(Messages)+SeparatorChar);

ChangeSeparator(Auto);
Write(txt,DosToWin(Auto)+SeparatorChar);

ChangeSeparator(Dopolnenie.MailPath);
Write(txt,DosToWin(Dopolnenie.MailPath)+SeparatorChar);


Write(txt,IntToStr(Dopolnenie.Price,COne)+SeparatorChar);

If Dopolnenie.DisableControlZeni=0 Then
Write(txt,DosToWin('-')+SeparatorChar)
Else
Write(txt,DosToWin('+')+SeparatorChar);

If DisableControlMinNazenka=0 Then
Write(txt,DosToWin('-')+SeparatorChar)
Else
Write(txt,DosToWin('+')+SeparatorChar);


Write(txt,MinimalProz+SeparatorChar);


Write(txt,Dopolnenie.Proz+SeparatorChar);


Write(txt,DosToWin(DateToDateString(DateMask,DateM))+SeparatorChar);
Write(txt,DosToWin(TimeToTimeString('hh:mm:ss',TimeM))+SeparatorChar);
Write(txt,DosToWin(GetOperatorField(FName,LastCaption))+SeparatorChar);


s:=GetRegionField(fRegion,RegionKod);
Write(txt,DosToWin(S)+SeparatorChar);

s:=RegionKod;
Format(S,CClientKod);
Write(txt,DosToWin(S)+SeparatorChar);

s:=GetRouteField(fRoute,RouteKod);
Write(txt,DosToWin(S)+SeparatorChar);

s:=RouteKod;
Format(S,CClientKod);
Write(txt,DosToWin(S)+SeparatorChar);

Writeln(txt);
i:=IOResult;

     End;
   End;
 end;

Close(f);
i:=IOResult;
Writeln(txt,DosToWin('"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')'));
Close(txt);
i:=IOResult;

NoInfoMsg;
MessageBox(^M+#3'Данные успешно импортированы в '+Path^.Dat.ToTemp+'impbaza.csv!',Nil,
  mfInformation+mfCancelButton);
End;


Function FindZena:AllStr;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c: Word;
  St : String[CZena];
begin
FindZena[0]:=#0;
Application^.GetExtent(R);
If Not(ProdagaWindow) Then
R.Assign(3, {19}R.B.Y-6, 13, R.B.Y-5{20})
Else
R.Assign(40, {19}R.B.Y-6, 50, {20}R.B.Y-5);
New(Dlg, Init(R, ''));
Dlg^.HelpCtx:=$E002;

R.Assign(0, 0, 10, 1);
Control := New(PRealInputLine, Init(R, CZena));
PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));
Control^.SetDAta(Finding);

Dlg^.Insert(Control);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(St);
  DelSpaceRight(St);
  If ST[0]<>#0 Then
        Begin
         MyStr(StrToReal(St),CZena,CMantissa,st);
         DelSpace(St);
         FindZena:=St;
         Finding:=St;
        End;
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;


Procedure AddProtocolSpecMarket(PrevMArket,L:PSuperMarketType);
Var BakSkid,NewSkid : AllStr;
Begin
                 Case PrevMarket^.Dat.SkidkaSelector Of
                 0:BakSkid:='Авто';
                 1:BakSkid:='Ручн.';
                 Else BakSkid:='???';
                 End;

                 Case L^.Dat.SkidkaSelector Of
                 0:NewSkid:='Авто';
                 1:NewSkid:='Ручн.';
                 Else NewSkid:='???';
                 End;
                 AddProtocol('Корректировка документа продажи N '+L^.Dat.Document+' от '+L^.Dat.DateC+'  {возможна кража}',
                          ' Было Со скл.:'+RealToStr(StrToReal(PrevMarket^.Dat.SummaZ)+
                          StrToReal(PrevMarket^.Dat.Skidka),9{CIZena},CMantissa)+
                          ' Скидка:'+RealToStr(StrToReal(PrevMarket^.Dat.Skidka),9{CIZena},CMAntissa)+
                          ' Тип:'+BakSkid+' Вид:'+IntToStr(PrevMarket^.Dat.DocSelector,COne)+
                          ' Опл.:'+RealToStr(StrToReal(PrevMarket^.Dat.SummaZ),9,CMantissa),
                          'Стало Со скл.:'+RealToStr(StrToReal(L^.Dat.SummaZ)+
                          StrToReal(L^.Dat.Skidka),9{CIZena},CMantissa)+
                          ' Скидка:'+RealToStr(StrToReal(L^.Dat.Skidka),{CIZena}9,CMAntissa)+
                          ' Тип:'+NewSkid+' Вид:'+IntToStr(L^.Dat.DocSelector,COne)+
                          ' Опл.:'+RealToStr(StrToReal(L^.Dat.SummaZ),9,CMantissa));

                 AddProtocol('Корректировка документа продажи N '+L^.Dat.Document+'-с'+' от '+L^.Dat.DateC+
                          '  {возможна кража}',
                          ' Было Со скл.:'+RealToStr(
                          StrToReal(PrevMarket^.Dat.SertifSummaZ)+
                          StrToReal(PrevMarket^.Dat.SertifSkidka),9{CIZena},CMantissa)+
                          ' Скидка:'+RealToStr(StrToReal(PrevMarket^.Dat.SertifSkidka),9{CIZena},CMAntissa)+
                          ' Тип:'+BakSkid+' Вид:'+IntToStr(PrevMarket^.Dat.DocSelector,COne)+
                          ' Опл.:'+RealToStr(StrToReal(PrevMarket^.Dat.SertifSummaZ),9,CMantissa),
                          'Стало Со скл.:'+RealToStr(StrToReal(L^.Dat.SertifSummaZ)+
                          StrToReal(L^.Dat.SertifSkidka),9{CIZena},CMantissa)+
                          ' Скидка:'+RealToStr(StrToReal(L^.Dat.SertifSkidka),{CIZena}9,CMAntissa)+
                          ' Тип:'+NewSkid+' Вид:'+IntToStr(L^.Dat.DocSelector,COne)+
                          ' Опл.:'+RealToStr(StrToReal(L^.Dat.SertifSummaZ),9,CMantissa));


                 AddProtocolVozwrat('Корректировка документа продажи N '+L^.Dat.Document+' от '+L^.Dat.DateC+
                          '  {возможна кража}'^M+
                          ' Было Со скл.:'+RealToStr(StrToReal(PrevMarket^.Dat.SummaZ)+
                          StrToReal(PrevMarket^.Dat.Skidka),9{CIZena},CMantissa)+
                          ' Скидка:'+RealToStr(StrToReal(PrevMarket^.Dat.Skidka),9{CIZena},CMAntissa)+
                          ' Тип:'+BakSkid+' Вид:'+IntToStr(PrevMarket^.Dat.DocSelector,COne)+
                          ' Опл.:'+RealToStr(StrToReal(PrevMarket^.Dat.SummaZ),9,CMantissa)+^M+
                          'Стало Со скл.:'+RealToStr(StrToReal(L^.Dat.SummaZ)-StrToReal(L^.Dat.ENalog)+
                          StrToReal(L^.Dat.Skidka),9{CIZena},CMantissa)+
                          ' Скидка:'+RealToStr(StrToReal(L^.Dat.Skidka),{CIZena}9,CMAntissa)+
                          ' Тип:'+NewSkid+' Вид:'+IntToStr(L^.Dat.DocSelector,COne)+
                          ' Опл.:'+RealToStr(StrToReal(L^.Dat.SummaZ),9,CMantissa));

                 AddProtocolVozwrat('Корректировка документа продажи N '+L^.Dat.Document+'-с'+' от '+L^.Dat.DateC+
                          '  {возможна кража}'^M+
                          ' Было Со скл.:'+RealToStr(StrToReal(PrevMarket^.Dat.SertifSummaZ)+
                          StrToReal(PrevMarket^.Dat.SertifSkidka),9{CIZena},CMantissa)+
                          ' Скидка:'+RealToStr(StrToReal(PrevMarket^.Dat.SertifSkidka),9{CIZena},CMAntissa)+
                          ' Тип:'+BakSkid+' Вид:'+IntToStr(PrevMarket^.Dat.DocSelector,COne)+
                          ' Опл.:'+RealToStr(StrToReal(PrevMarket^.Dat.SertifSummaZ),9,CMantissa)+^M+
                          'Стало Со скл.:'+RealToStr(StrToReal(L^.Dat.SertifSummaZ)+
                          StrToReal(L^.Dat.SertifSkidka),9{CIZena},CMantissa)+
                          ' Скидка:'+RealToStr(StrToReal(L^.Dat.SertifSkidka),{CIZena}9,CMAntissa)+
                          ' Тип:'+NewSkid+' Вид:'+IntToStr(L^.Dat.DocSelector,COne)+
                          ' Опл.:'+RealToStr(StrToReal(L^.Dat.SertifSummaZ),9,CMantissa));

End;




Procedure SelectAlgoritmZenInZakaz;

var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  L : LongInt;

Begin
R.Assign(24, 8, 64, 13);
New(Dlg, Init(R, 'Заказы и цены'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(1, 2, 39, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('~О~ставлять цены заказа (не авто)',
  NewSItem('~М~енять цены на текущие складские ',
  {NewSItem('~С~прашивать подтверждения',} Nil{)}))));
Dlg^.Insert(Control);

  R.Assign(1, 1, 25, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'При оформлении заказов:', Control)));

Dlg^.SelectNext(False);
Dlg^.SetData(ZeniInZakaz);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(ZeniInZakaz);
  L:=0;
  WriteNewCfg(L);
         If l<> 0 Then Errors('Ошибка записи файла конфигурации !')
         Else
             Begin
           If ZeniInZakaz=0 Then
                 AddProtocol('Корректировка политики цен в заказах!!!',
                 '"Оставлять цены заказа (не авто)"','')
           Else
                 AddProtocol('Корректировка политики цен в заказах!!!',
                 '"Менять цены на текущие складские"','');
          End;
 End;
 Dispose(Control,Done);
 Dispose(Dlg,Done);
End;



Var ControlOperator,
    ControlSkidka,
    ControlAgent : PView;







Function TLastZenaWindow.Start(LinkArt:ArtikulStr;Ck:ArtikulStr;VAr ReturnZena:AllStr):AllStr;

var
  R : TRect;
  R1 : LongInt;
  Control : PView;
  ZF : File;
  Z  : PBufLAstClientToVArType;
  cc,Count,C,i : Word;
  s : String;
  SrokIsp,OperatorNAme,ClientName,AgentName:AllStr;
  Find : Boolean;
  SDateC,SDAte : TDateString;
  SProz,SZena,SZakupka : String[CZenaZ];
  CurrFull, Full : TMyString;
  SKol,Start1 : ArtikulStr;
  txt : Text;
  Skl : PSkladType;
  FindSertif : Boolean;
  SNAme : TMyString;
  Sh : LongInt;
  PrevD : Word;
  BakFileMode:Word;
begin

Start[0]:=#0;
ReturnZena[0]:=#0;

R.Assign(0, 0, 0, 0);
NoScreenList := New(PBox, Init(R, 1, Nil));
NoScreenList^.NewList(New(PTextCollection, Init(0,1)));

BakFileMode:=FileMode;
FileMode:=$42;
Assign(ZF,Path^.Dat.ToClientIndex+ck+'.tlx');
i:=IOResult;
Reset(ZF,SizeOf(LastClientToVarType));
i:=IOResult;
FileMode:=BakFileMode;
If i=0 Then
Begin
Full:=GetIdField(FFFName,LinkArt);
DelSpaceRight(Full);

sh:=1;


PrevD:=DistanationSorting;

DistanationSorting:=1;

While Not(Eof(ZF)) Do
 Begin
  DInfoMsgShkala('Просматриваю последние цены по позиции '+LinkArt+'...',0,FileSize(ZF),
  FilePos(ZF));
  New(Z,Init);
  Count:=0;
  BlockRead(ZF,Z^.Point,BufferLAstTovar,Count);


For cc:=1 To Count Do
Begin
 If Z^.Point.Dat[cc].Active Then
 Begin
With Z^.Point.Dat[cc] Do
Begin
   Find:=False;
Begin
 For c:=1 To Amount Do
 Begin
   Find:=False;

   If StrToInt(Copy(Element[c].BazKod,1,2))=StrToInt(Copy(LinkArt,1,2)) Then
   Begin
    CurrFull:=GetIdField(FFFNAme,Element[c].BazKod);
    DelSpaceRight(CurrFull);
    If Full=CurrFull Then Find:=True;
   End;

  If Find Then
  Begin
   RFormatZerro(Document,CDocNumer);

   AgentName:=GetAgentField(FClient,AgentKod);
   Format(AgentName,CClient);

   SDate:=IntToStr(Datec,CDAte);
   SDateC:=DateToDateString(DateMask,Datec);
   RFormat(SDate,CDate);

   MyStr(Element[c].Zena,CZena,CMantissa,SZena);
   MyStr(Element[c].Zakupka,CZenaZ,CMantissaZ,SZakupka);


   If Element[c].Zakupka>0.00009 Then
   Begin
     If {FindPAram('/EZ')}(EnableZakupka=1) Or (StrToInt(CurrentPassword)=0) Then
     MyStr((Element[c].Zena-Element[c].Zakupka)/Element[c].Zakupka*100,CKol,CMantissa,SProz)
     Else
      Begin
       SZakupka:=CodeZakupka;
       SProz:='??.??';
      End;
   End
    Else SProz:='??.??';


   OperatorName:=GetOperatorField(FNAme,Caption);
   Format(OperatorName,CKto);

   SKol:=IntToStr(Element[c].Kol,CKOl);
   RFormat(SKOl,CKol);


   s:=SDate+'│'+Document+'│'+SDateC+'│'+SKol+'│'+SZena+'│'+SZakupka+'│'+SProz+'│'+
   AgentNAme+'('+AgentKod+')'+'│'+IntToStr(DocSelector,COne)+'│'+IntToStr(SkidkaSelector,COne)+'│'+
   OperatorNAme+'│'+IntToStr(sh,CKOl);

   Inc(Sh,1);

   NoScreenList^.List^.Insert(NewStr(s));
   NoScreenList^.SetRange(NoScreenList^.List^.Count);
  End;{find}
 End;{For по товару}
End;

 End;{With}

End;{If Active=0}
End;{For}
  Dispose(Z,Done);
End;{While}
System.Close(ZF);
i:=IOResult;

End;

NoInfoMsg;

DistanationSorting:=0;

CurrentLine[0]:=#0;

i:=IOResult;
System.Close(ZF);
i:=IOResult;
NoScreenList^.FocusItem(0);
{закончили чтение заказов}

(*
If Fast{если сокращенный вариант} Then
 Begin

 If NoScreenList^.List^.Count-1>=0 Then
  Begin
   s:=NoScreenList^.GetText(0,NoScreenList^.List^.Count);
   System.Delete(s,1,CDate);
   ReturnZena:=Copy(LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count),1+1+CDocNumer+1+CDate+1+CKol+1,CZena);
   DelSpace(ReturnZena);
   Start:=ReturnZena;
   Dispose(NoScreenList,Done);

   Exit;
  End;

 End;
*)


R.Assign(0, 9, 49, 20);
New(LastWindow, Init(R, 'Хронология цен для '+
GetClientField(FClient,Ck,0)+'('+Ck+')'));
{LastWindow^.Options := LastWindow^.Options or ofCenterX or ofCenterY;}
LastWindow^.HelpCtx:=$F306;
LastWindow^.FFF:=LinkArt;
LastWindow^.ClKod:=Ck;

SNAme:=GetIdField(FFFNAme,LastWindow^.FFF);
Format(SNAme,CName+1+CName);
SNAme[0]:=#39;

R.Assign(1, 1, 48, 2);
Control := New(PStaticText, Init(R, SNAme+'('+LastWindow^.FFF+')'));
LastWindow^.Insert(Control);

R.Assign(48, 3, 49, 9);
Control := New(PScrollBar, Init(R));
LastWindow^.Insert(Control);

R.Assign(1, 3, 48, 9);
LinkList := New(PBox, Init(R, 1, PScrollbar(Control)));
LinkList^.NewList(New(PMyCollection, Init(0,1)));

If NoScreenList^.List^.Count-1>=0 Then
 For c:=0 To NoScreenList^.List^.Count-1 Do
  Begin
   s:=NoScreenList^.GetText(c,NoScreenList^.List^.Count);
   System.Delete(s,1,CDate);
   LinkList^.List^.Insert(NewStr(s));
   LinkList^.SetRange(LinkList^.List^.Count);
  End;
LinkList^.FocusItem(0);
LastWindow^.Insert(LinkList);

Dispose(NoScreenList,Done);

  R.Assign(2, 2, 45, 3);
  LastWindow^.Insert(New(PLabel, Init(R, 'Док.   Дата   Колич.Цена опл.    З/Цена  %',
  LinkList)));


R.Assign(35, 9, 47, 10);
ControlOperator := New(PColoredText, Init(R, #3+'', $7E));
LastWindow^.Insert(ControlOperator);


R.Assign(26, 9, 35, 10);
Control := New(PColoredText, Init(R, 'Оператор:', $74));
LastWindow^.Insert(Control);


R.Assign(14, 10, 20, 11);
Control := New(PColoredText, Init(R, 'Агент:', $74));
LastWindow^.Insert(Control);

R.Assign(20, 10, 47, 11);
ControlAgent := New(PColoredText, Init(R, #3+'', $7E));
LastWindow^.Insert(ControlAgent);


R.Assign(1, 9, 12, 10);
Control := New(PColoredText, Init(R, 'Вид док-та:', $74));
LastWindow^.Insert(Control);

R.Assign(12, 9, 21, 10);
ControlDoc := New(PColoredText, Init(R, #3+'???', $7E));
LastWindow^.Insert(ControlDoc);


R.Assign(1, 10, 8, 11);
Control := New(PColoredText, Init(R, 'Скидка:', $74));
LastWindow^.Insert(Control);

R.Assign(8, 10, 13, 11);
ControlSkidka := New(PColoredText, Init(R, #3+'', $7E));
LastWindow^.Insert(ControlSkidka);

LastWindow^.SelectNext(False);

CurrentLine[0]:=#0;

c:=Desktop^.ExecView(LastWindow);
If c<>cmCancel Then
 Begin
  ReturnZena:=Copy(LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count),1+1+CDocNumer+1+CDate+1+CKol+1,CZena);
  DelSpace(ReturnZena);
 End
 Else
  ReturnZena[0]:=#0;

Start:=ReturnZena;
Dispose(Control,Done);
Dispose(LastWindow,Done);
End;{Procedure}




Procedure TLastZenaWindow.FullPreview;
VAr Ass : DocumentEditZ;
    s : TMyString;
Begin
If (LinkList^.List<>Nil)And(LinkList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count),1+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  s:=LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count);
  Ass.D:=Copy(s,1+1+CDocNumer+1,CDate);;
  DelSpace(Ass.D);
  ViewMrk^.FullScreenMrk(Ass,False);
End;
End;


Procedure TLastZenaWindow.DrawCurrent;
Var st : String;
    R : TRect;
Begin
if (LinkList^.List<>Nil)And(LinkList^.List^.Count>=1) Then
 Begin
  st:=LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count);
  If st <> CurrentLine Then
   Begin
    CurrentLine:=St;
  {
   s:=SDate+'│'+Document+'│'+SDateC+'│'+SKol+'│'+SZena+'│'+SZakupka+'│'+SProz+'│'+
   AgentNAme+'('+AgentKod+')'+'│'+IntToStr(DocSelector,COne)+'│'+IntToStr(Skidka,COne)+'│'+
   OperatorNAme+'│';
                     }
   st:=Copy(CurrentLine,1+1+CDocNumer+1+CDAte+1+CKol+1+CZena+1+CZenaZ+1+CLitr+1+CClient+6+1+COne+1+COne+1,CKto);
   DelSpaceRight(St);

Dispose(ControlOperator,Done);
R.Assign(35, 9, 47, 10);
ControlOperator := New(PColoredText, Init(R, #3+st, $7E));
LastWindow^.Insert(ControlOperator);


   st:=Copy(CurrentLine,1+1+CDocNumer+1+CDAte+1+CKol+1+CZena+1+CZenaZ+1+CLitr+1,CClient+6);
   DelSpaceRight(St);

Dispose(ControlAgent,Done);
R.Assign(20, 10, 47, 11);
ControlAgent := New(PColoredText, Init(R, #3+st, $7E));
LastWindow^.Insert(ControlAgent);

st:=Copy(CurrentLine,1+1+CDocNumer+1+CDAte+1+CKol+1+CZena+1+CZenaZ+1+CLitr+1+CClient+6+1,COne);
Case StrToInt(st) Of
0:st:='Список';
1:st:='Тов.чек';
2:st:='Физ.лицо';
3:st:='СФ*';
4:st:='СФ Б';
5:st:='Дебит*';
6:st:='Дебит СФ';
7:st:='Дебит';
8:st:='Дебит СФБ';
Else St:='?';
End;{CAse}

Dispose(ControlDoc,Done);
R.Assign(12, 9, 21, 10);
ControlDoc := New(PColoredText, Init(R, #3+st, $7E));
LastWindow^.Insert(ControlDoc);


st:=Copy(CurrentLine,1+1+CDocNumer+1+CDAte+1+CKol+1+CZena+1+CZenaZ+1+CLitr+1+CClient+6+1+COne+1,COne);
Case StrToInt(st) Of
0:st:='Авто';
1:st:='Ручн.';
Else St:='?';
End;{CAse}

Dispose(ControlSkidka,Done);
R.Assign(8, 10, 13, 11);
ControlSkidka := New(PColoredText, Init(R, #3+St, $7E));
LastWindow^.Insert(ControlSkidka);
   End;
 End
 Else
  Begin
   PStaticText(ControlDoc)^.GetText(st);
   If St<>#3+'???' Then
   Begin
Dispose(ControlOperator,Done);
R.Assign(35, 9, 47, 10);
ControlOperator := New(PColoredText, Init(R, #3+'', $7E));
LastWindow^.Insert(ControlOperator);

Dispose(ControlAgent,Done);
R.Assign(20, 10, 47, 11);
ControlAgent := New(PColoredText, Init(R, #3+'', $7E));
LastWindow^.Insert(ControlAgent);

Dispose(ControlDoc,Done);
R.Assign(12, 9, 21, 10);
ControlDoc := New(PColoredText, Init(R, #3+'???', $7E));
LastWindow^.Insert(ControlDoc);

Dispose(ControlSkidka,Done);
R.Assign(8, 10, 13, 11);
ControlSkidka := New(PColoredText, Init(R, #3+'', $7E));
LastWindow^.Insert(ControlSkidka);
   End;
  End;

End;


Procedure TLastZenaWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var s : String;
    Prom : Word;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
        cmOk : Begin
               If Not((LinkList^.List<>Nil)And(LinkList^.List^.Count>=1)) Then
                Begin
                 ClearEvent(Event);
                End;
               End;

  cmFullView:    Begin
                 ClearFind;
     If (LinkList^.State and sfFocused <> 0) And (LinkList^.List<>Nil)And(LinkList^.List^.Count>=1) Then
            Begin
              FullPreview;
            End
            End;
        Else;
        End;
 Else;
 End;

  if ((Event.What = evMouseDown) and (Event.Double))   Then
  begin
              Event.What:=evCommand;
              Event.Command:=cmOk;
  end;


inherited HandleEvent(Event);

 If (Desktop^.Current=PView(LastWindow)) And (Event.What <> EvKeyDown) Then
     Begin
      DrawCurrent;
     End;




End;{HandleEvent}

Destructor TLastZenaWindow.Done;
Begin
Dispose(ControlOperator,Done);
Dispose(ControlAgent,Done);
Dispose(ControlDoc,Done);
Dispose(ControlSkidka,Done);
Dispose(LinkList,Done);
TDialog.Done;
End;



Function InputProz(Var Summa:AllStr{сумма накладной со склада}):Boolean;
LAbel 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  S : String[CKOl];
  c : Word;
begin
InputProz:=False;
1:
R.Assign(60, 9, 71, 12);
New(Dlg, Init(R, '%'));
Dlg^.HelpCtx:=$E002;

R.Assign(2, 1, 9, 2);
Control := New(PInputLine, Init(R, CKOl));
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

Dlg^.Insert(Control);

Dlg^.SelectNext(False);
c:=DeskTop^.ExecView(Dlg);
If c<>cmCAncel Then
 Begin
  Dlg^.GetDAta(S);
  If StrToReal(s)>10 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3+'Слишком большой процент > 10%',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  MyStr(StrToReal(Summa)*StrToReal(s)/100,CIZena,CMAntissa,Summa);
  InputProz:=True;
  DelSpace(Summa);

 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;



Function TInputOtkatWindow.InputOtkat(Var L:PSuperMarketType):Boolean;
label 1;
VAr
  R : TRect;
  c : Word;
  Control : PView;
  SumStr : String[CIZena];
Begin
InputOtkat:=False;
1:
R.Assign(19, 9, 60, 13);
New(OtkatWin, Init(R, 'Сумма "БОНУСА"'));
OtkatWin^.Options := OtkatWin^.Options or ofCenterX or ofCenterY;
OtkatWin^.HelpCtx := $F332;

MyStr(StrToReal(L^.DAt.SummaZ){+StrToReal(L^.DAt.Skidka)},CIZena,CMAntissa,OtkatWin^.SoSklada);
{уже не со склада а к оплате по просьбе Бакши от06/08/2002}

R.Assign(27, 2, 39, 3);
ControlOtkat := New(PInputLine, Init(R, CZenaZ));
OtkatWin^.Insert(ControlOtkat);
  PInputLine(ControlOtkat)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

OtkStr:=RealToStr(L^.Dat.Otkat,CZenaZ,CMantissa);
MyStr(StrToReal(L^.Dat.SummaZ){-StrToreal(L^.Dat.Skidka)},CIZena,CMantissa,SumStr);

DelSpace(OtkStr);

R.Assign(1, 1, 26, 3);
Control := New(PColoredText, Init(R, 'Сумма к оплате по накладной:'+SumStr, $7E));
OtkatWin^.Insert(Control);

OtkatWin^.SelectNext(False);

OtkatWin^.SetData(OtkStr);;

c:=Desktop^.ExecView(OtkatWin);

If c<>cmCancel Then
 Begin
  OtkatWin^.GetData(OtkStr);
  DelSpace(OtkStr);
  If StrToReal(OtkStr)>=StrToReal(SumStr) Then
   Begin
    Dispose(Control,Done);
    Dispose(OtkatWin,Done);
    MessageBox(^M+#3'БОНУС превышает сумму к оплате!',Nil,mfError+mfCAncelButton);
    Goto 1;
   End;
  L^.Dat.Otkat:=StrToReal(OtkStr);
  InputOtkat:=True;
 End;
 Dispose(Control,Done);
 Dispose(OtkatWin,Done);

End;


procedure TInputOtkatWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var s : String;
    ss : String[CIZena];
    Prom : Word;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
        cmInputProz:Begin
                     ss:=OtkatWin^.Sosklada;
                     If InputProz(ss) Then
				  Begin
                       DelSpace(ss);
                       OtkatWin^.SetData(ss);
				  End;
                    End;
        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);

End;




Destructor TInputOtkatWindow.Done;
Begin
TDialog.Done;
End;





procedure RunDialUp;
begin
  DInfoMsg('Минуточку...',False);
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  {DoneVideo;}
  DoneDosMem;
  SwapVectors;
  Exec(GetEnv('Comspec'),' /c Start.exe /Max '+Path^.Dat.ToWinLnk+' '+NullStr^);
  SwapVectors;
  InitDosMem;
  {InitVideo;}
  InitEvents;
  InitSysError;
  CursorLines:=1543;
  Application^.Redraw;
                      Case DosError Of
                      2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
                      3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
                      5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
                      6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
                      8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
                     10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
                     11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
                     18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
                        Else;
                       End;
  NoInfoMsg;
end;




{$IFDEF DPMI}
Function SelectVidOplata(Var M3 : Maska4):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  V : Word;{переменная}
  c : Word;

begin
SelectVidOplata:=False;
R.Assign(28, 8, 46, 14);
New(Dlg, Init(R, 'Уточните'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

M3[1]:=1;
M3[2]:=1;
M3[3]:=1;
M3[4]:=1;

BitToWord4(M3,C);


R.Assign(1, 1, 17, 5);
Control := New(PCheckboxes, Init(R,
  NewSItem('На~л~ичный',
  NewSItem('Б/~Н~',
  NewSItem('~В~ексель',
  NewSItem('~В~озвратом',
  Nil))))));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);

Dlg^.SetData(c);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(c);
  WordToBit4(C,M3);
  Convert4(M3);

  SelectVidOplata:=True;
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;


function SelectVidProsmotra(VAr Res : Word) : Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;

begin
SelectVidProsmotra:=False;
R.Assign(27, 9, 52, 14);
New(Dlg, Init(R, 'Режим просмотра'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:= $E002;

R.Assign(1, 1, 24, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('Без ~у~чета брони',
  NewSItem('~З~абронированный',
  NewSItem('~Н~езабронированный', Nil)))));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetDAta(Res);

c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
Begin
 Dlg^.GetData(c);
 SelectVidProsmotra:=True;
 Res:=c;
End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;



Function GetSrok(Start:TDAteString;Var DateEnd:LongInt):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  St : String[CMantissa];
  L : LongInt;
Begin
GetSrok:=False;
1:
R.Assign(21, 9, 58, 14);
New(Dlg, Init(R, 'Длительность брони'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(23, 2, 27, 3);
Control := New(PInputLine, Init(R, CMantissa));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(1, 2, 23, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Срок доставки заказа:', Control)));

R.Assign(28, 2, 35, 3);
Control := New(PColoredText, Init(R, 'дня(ей)', $7F));
Dlg^.Insert(Control);

st[0]:=#0;
If Glob.Status=DocEdit Then
Begin
St:=IntToStr(DateEnd,CMantissa);
If st='0' Then St[0]:=#0;
End;
Dlg^.SetData(st);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
Begin
 Dlg^.GetData(St);
 If StrToInt(St)=0 Then
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   Goto 1;
  End;

 If DayOfWeek(DateStringToDate(DateMask,Start)+StrToInt(St))=Sunday Then
  Begin
   SpecialBeep;
   If MessageBox(#3'Дата доставки заказа - воскресенье!'^M+
   #3'Хотите исправить?',Nil,mfWarning+mfOkCancel)=cmOk Then
    Begin
     Dispose(Control,Done);
     Dispose(Dlg,Done);
     Goto 1;
    End;
  End;
 DateEnd:=StrToInt(st);
 GetSrok:=True;
End;
Dispose(Control,Done);
Dispose(Dlg,Done);
End;


{$ELSE}

Function SelectVidOplata(Var M3 : Maska4):Boolean;
Begin
End;

function SelectVidProsmotra(VAr Res : Word) : Boolean;
Begin
End;


Function GetSrok(Start:TDAteString;Var DateEnd:LongInt):Boolean;
Begin
End;

{$ENDIF}



(*
Function InputBezNal(Var Bn:BezNal):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : WOrd;
  k : LongInt;

begin
1:
InputBezNAl:=False;
R.Assign(12, 8, 67, 15);
New(Dlg, Init(R, 'Безналичный расчет'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E002;

R.Assign(3, 2, 13, 3);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DAteFiltr, True));

  R.Assign(2, 1, 8, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~Д~ата:', Control)));

R.Assign(19, 2, 31, 3);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(18, 1, 25, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'N ~п~/п:', Control)));

R.Assign(35, 2, 52, 3);
Control := New(PRealInputLine, Init(R, 15));
Dlg^.Insert(Control);
{  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));}

  R.Assign(34, 1, 50, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~С~умма платежа:', Control)));

R.Assign(7, 4, 54, 5);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(1, 4, 7, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Б~а~нк:', Control)));

Dlg^.SelectNext(False);


Dlg^.SetData(Bn);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(Bn);
  DelSpace(Bn.Date);
  DelSpace(Bn.NPlat);
  MyStr(StrToReal(Bn.Summa),CIZena,CMAntissa,Bn.Summa);
  DelSpace(Bn.Summa);
  DelSpaceRight(Bn.Bank);
  If bn.Bank[0]=#0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не указан банк !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  If Not(TestDate(Bn.Date,k)) Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не существующая дата !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  If bn.Date[0]=#0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не указана дата п/п !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  If bn.NPlat[0]=#0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не указан номер п/п !',Nil,mfError+mfCancelButton);
         Goto 1;
   End;
  If StrToReal(bn.Summa)=0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Нулевая сумма б/н платежа !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  InputBezNal:=True;
End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;
*)

Function EnterPrim:AllStr;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  s : AllStr;
begin
EnterPrim[0]:=#0;
S[0]:=#0;
R.Assign(14, 10, 65, 13);
New(Dlg, Init(R, 'Примечание'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;

R.Assign(2, 1, 49, 2);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
{MakeDialog := Dlg;}
end;


Function SpisDolgFromZerroDocRealiz(L:PSuperMarketType):Boolean;
Var OplataFile :File Of OplataRealizasiaType;
    Oplata : OplataRealizasiaType;
    c : Word;
    Pos1 : LongInt;
Begin
   If InputZakaz=1 Then
   Begin
    SpisDolgFromZerroDocRealiz:=True;
    Exit;
   End;
   SpisDolgFromZerroDocRealiz:=False;
   Assign(OplataFile,Path^.Dat.ToOplata+FDate+'.opl');
   c:=IOResult;
   Reset(OplataFile);
   c:=IOResult;
   If c<>0 Then
    Begin
     If MessageBox(#3'Файл оплаты консигнации за '+FDate+' не найден!'^M+
     #3'Создавать файл оплаты консигнации?'+
        +' Код:'+IntToStr(c,3),Nil,mfError+mfOkCancel)=cmOk Then
      Begin
{      c:=IOResult;
       Reset(OplataFile);
       c:=Ioresult;
                 If c<>0 Then Rewrite(OplataFile);
       c:=IOResult;}
       If Not(CreatToDayF(DocOplata,FDate)) Then Exit;
       Reset(OplataFile);
       c:=IOResult;
       End
      Else
           Begin
            SpisDolgFromZerroDocRealiz:=False;
            Exit;
           End;
    End;

    Oplata.Rashet:=0;
    Oplata.Bn.DAte[0]:=#0;
    Oplata.Bn.NPlat[0]:=#0;
    Oplata.Bn.BankKod:=NoBankStr;
    Oplata.Bn.Summa[0]:=#0;

    Oplata.Vozwrat:=False;(**)
    Oplata.DocNumerReturn[0]:=#0;{для документов возврата}
    Oplata.DocDAteReturn[0]:=#0;{для документов возврата}

    Oplata.SkladKod:=Rek^.Dat.Kod;(**)
    Oplata.ClientKod:=L^.Dat.ClientKod;(**)
    Oplata.DateC:=FDate;(**)
    Oplata.TimeC:=Times;(**)

    Oplata.Document:=L^.Dat.Document;(**)
         Oplata.DateDoc:=L^.Dat.DateC;(**)


    Oplata.TimeC:=Times; {время создания}
    MyStr(0.00,CIZena,CMantissa,Oplata.SummaZ);  {сумма оплаты}
    Oplata.Caption :=CurrentPassword;{признак оператора}

     DInfoNetMsg('Сохраняю оплату консигнации по докумену N '+Oplata.Document+' от '+Oplata.DateDoc+'...');

    Repeat
     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(OplataFile);
      Seek(OplataFile,Pos1);
     Until (Lock(OplataFile,FilePos(OplataFile)*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)*ComputersKol));

     Pos1:=FileSize(OplataFile);

     If FilePos(OplataFile)<>{FileSize(OplataFile)}Pos1 Then
      Begin
       Repeat {деблокируем участок записи}
        Pause(1);
        UnLock(OplataFile,(FilePos(OplataFile))*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)*ComputersKol);
       Until (DosError=0);
      End;
    Until (FilePos(OplataFile)={FileSize(OplataFile)}Pos1);

          Write(OplataFile,Oplata);
     Seek(OplataFile,FilePos(OplataFile)-1);

     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле оплаты консигнации...',False);
     Repeat {деблокируем участок записи}
     Pause(1);
     UnLock(OplataFile,(FilePos(OplataFile))*SizeOf(OplataRealizasiaType),
         SizeOf(OplataRealizasiaType)*ComputersKol);
     Until (DosError=0);
    Close(OplataFile);
    NoInfoMsg;
    SpisDolgFromZerroDocRealiz:=True;
End;




Function SelectKuda(VAr Res : Word):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  St : AllStr;

begin
SelectKuda:=False;
1:
R.Assign(27, 6, 52, 16);
New(Dlg, Init(R, 'Куда переместить'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 24, 9);
Control := New(PRadioButtons, Init(R,
  NewSItem('~1~ '+Rek^.Dat.Otdel[1],
  NewSItem('~2~ '+Rek^.Dat.Otdel[2],
  NewSItem('~3~ '+Rek^.Dat.Otdel[3],
  NewSItem('~4~ '+Rek^.Dat.Otdel[4],
  NewSItem('~5~ '+Rek^.Dat.Otdel[5],
  NewSItem('~6~ '+Rek^.Dat.Otdel[6],
  NewSItem('~7~ '+Rek^.Dat.Otdel[7],
  NewSItem('~8~ '+Rek^.Dat.Otdel[8],
  Nil))))))))));
Dlg^.Insert(Control);

c:=0;
Dlg^.SelectNext(False);

Dlg^.SetData(c);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(c);
  St:=IntToStr(c+1,COne);
  If Not TestOtdel(c+1) Then
   Begin
    MessageBox(^M+#3'Отделение N '+St+' запрещено!',nil,mfError+mfCancelButton);
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    Goto 1;
   End;

If EnableAverageOtdel<>0 Then
If Not(StrToInt(st) in SetEnableOtdel) Then
  Begin
   MessageBox(^M+#3'Операции с этим отделением запрещены для этой рабочей станции!',
   Nil,mfError+mfCancelButton);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   Goto 1;
  End;

  Res:=C;
  SelectKuda:=True;
 End;

Dispose(Control,Done);
Dispose(Dlg,Done);
end;






Procedure GlobalLockBaza;
Var f : File;
         c : Word;
Begin
 Assign(f,Path^.Dat.ToFlagDir+'lockadm');
 c:=IoResult;
 Rewrite(f);
 c:=IoResult;
 if c=0 Then
  Begin
        Close(f);
        c:=IoResult;

 If Not(Glob.AnsverGlobal) Then
 Begin
  Glob.AnsverGlobal:=True;
  MessageBox(#3'База заблокирована!'^M+
                                 #3'Работа всех компьютеров будет остановлена в течении ближайших 7 секунд!',
                   Nil,mfInsertInApp+mfWarning+mfCancelButton);
  Exit;
 End
  Else Exit;

  End;
End;

Procedure GlobalUnLockBaza;
Var f : File;
    c : Word;
Begin
 Assign(f,Path^.Dat.ToFlagDir+'lockadm');
 c:=IoResult;
 Erase(f);
 c:=IoResult;
 if c=0 Then
  Begin
  MessageBox(#3'База деблокирована!'^M+
             #3'Работа всех компьютеров будет возобновлена в течении ближайших 7 секунд!',Nil,
                   mfInsertInApp+mfWarning+mfCancelButton);

  End
End;




Procedure NewSkidkiIDX;
VAr sklFile : SkidkaFileType;
    skl : pSkidkaType;
    s : ArtikulStr;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    F : Boolean;
    Count,c : Word;
    l : Word;
Begin
If MessageBox(^M+Monopolia^,Nil,mfWarning+mfOkCancel)<>cmOk Then
Exit;
c:=IOResult;
Assign(RazdelFile,Path^.Dat.ToRazdel+'Razdel.db');
Reset(RazdelFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу разделов!',Nil,mfError+mfCancelButton);
  Exit;
 End;
{ Seek(RazdelFile,26);}
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
   DInfo('Идет переиндексация базы скидок - раздел '+RazdelElement.Kod+'...');

   Assign(SklFile,Path^.Dat.ToSkidki+RazdelElement.Kod+'.skl');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToSkidki+RazdelElement.Kod+'.skl',Nil,mfError+mfCancelButton);
  Exit;
 End;

 {
   Seek(SklFile,700);
   Truncate(SklFile);
   Exit;
 }
   New(Skl,Init);
   Count:=0;
   While Not(Eof(sklFile)) Do
    Begin
     Repeat
      Pause(1);
     Until NetCAll.Lock(SklFile,FilePos(SklFile)*SizeOf(SkidkaType),SizeOf(SkidkaType));

     Read(SklFile,Skl^.Dat);

     Str(Count:3,S);
     RFormatZerro(s,3);
     Skl^.Dat.BAZKod:=RazdelElement.Kod+s;
     Skl^.Dat.Caption:=CurrentPassword;
     Skl^.Dat.Date:=FDate;
     Skl^.Dat.Time:=Times;

     For l:=1 To 6 Do
      Begin
       MyStr(StrToReal(Skl^.DAt.Skidka[l].Proz),CLitr,CMantissa,Skl^.DAt.Skidka[l].Proz);
       DelSpace(Skl^.DAt.Skidka[l].Proz);
       MyStr(StrToReal(Skl^.DAt.Skidka[l].Up),CIZena,CMantissa,Skl^.DAt.Skidka[l].Up);
       DelSpace(Skl^.DAt.Skidka[l].Up);
      End;

     Seek(SklFile,Filepos(SklFile)-1);
     Write(SklFile,Skl^.Dat);

   Repeat
    NetCall.UnLock(SklFile,(FilePos(SklFile)-1)*SizeOf(SkidkaType),SizeOf(SkidkaType));
   Until (DosError=0);

     Inc(Count);
     End;

   Dispose(Skl,Done);
   Close(SklFile);
   NoInfo;
   End;
 End;
Close(RazdelFile);
MessageBox(^M+#3'Переиндексация скидок завершена!',Nil,mfInformation+mfCancelButton);
End;


Procedure NewIDX;
VAr sklFile : File Of SkladType;
    skl : pSkladType;
    s : ArtikulStr;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    F : Boolean;
    Count,c : Word;
Begin
If MessageBox(^M+Monopolia^,Nil,mfWarning+mfOkCancel)<>cmOk Then
Exit;
c:=IOResult;
Assign(RazdelFile,Path^.Dat.ToRazdel+'Razdel.db');
Reset(RazdelFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу разделов!',Nil,mfError+mfCancelButton);
  Exit;
 End;
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
   DInfo('Идет переиндексация базы данных - раздел '+RazdelElement.Kod+'...');
   Assign(SklFile,Path^.Dat.ToSklad+RazdelElement.Kod+'.db');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToSklad+RazdelElement.Kod+'.db',Nil,mfError+mfCancelButton);
  Exit;
 End;

   New(Skl,Init);
   Count:=0;
   While Not(Eof(sklFile)) Do
    Begin

     Repeat
      Pause(1);
     Until NetCAll.Lock(SklFile,FilePos(SklFile)*SizeOf(SkladType),SizeOf(SkladType));

     Read(SklFile,Skl^.Dat);

     Str(Count:3,S);
     RFormatZerro(s,3);
     Skl^.Dat.BAZKod:=RazdelElement.Kod+s;
     Seek(SklFile,Filepos(SklFile)-1);
     Write(SklFile,Skl^.Dat);

   Repeat
    NetCall.UnLock(SklFile,(FilePos(SklFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

     Inc(Count);
    End;

   Seek(SklFile,0);

   While Not(Eof(sklFile)) Do
    Begin

     Repeat
      Pause(1);
     Until NetCAll.Lock(SklFile,FilePos(SklFile)*SizeOf(SkladType),SizeOf(SkladType));

     Read(SklFile,Skl^.Dat);
     c:=IOResult;
     F:=GetIDEmploy(Skl^.DAt.BazKod);

     If (F<>Skl^.DAt.Employ) Then
      Begin
       Seek(SklFile,Filepos(SklFile)-1);
       Skl^.DAt.Employ:=F;
       Write(SklFile,Skl^.Dat);
      End;

     c:=GetIDDebit(Skl^.DAt.BazKod);
     If (c<>Skl^.DAt.EnableDebit) Then
      Begin
       Seek(SklFile,Filepos(SklFile)-1);
       Skl^.DAt.EnableDebit:=c;
       Write(SklFile,Skl^.Dat);
      End;


     Repeat
      NetCall.UnLock(SklFile,(FilePos(SklFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
     Until (DosError=0);

    End;

   Dispose(Skl,Done);
   Close(SklFile);
   NoInfo;
   End;
 End;
Close(RazdelFile);
c:=IoResult;
MessageBox(^M+#3'Переиндексация завершена!',Nil,mfInformation+mfCancelButton);
End;



Function SelectVidNalich:Byte;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;

begin
R.Assign(21, 9, 58, 14);
New(Dlg, Init(R, 'Дополнительно'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
{Dlg^.Palette := dpCyanDialog;}
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 36, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('Включать ~с~уммы и цены',
  NewSItem('Включать фасовку и ~к~оличество',
  NewSItem('Включать ~з~акупочные цены', Nil)))));

If Not({FindParam('/EZ')}(EnableZakupka=1)) And Not(StrToInt(CurrentPassword)=0) Then
  PCluster(Control)^.SetButtonState($00000004, False);

(*
{$IFNDEF Tabak}
If StrToInt(CurrentPassword)<>0 Then
 Begin
  PCluster(Control)^.SetButtonState($00000004, False);
 End;
{$ENDIF}
*)

Dlg^.Insert(Control);



c:=0;

Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
  Begin
   Dlg^.GetData(c);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectVidNalich:=c;
  End
  Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectVidNalich:=3;
  End;
end;




Function SelectPrz:Byte;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelectPrz:=0;

R.Assign(31, 9, 61, 14);

New(Dlg, Init(R, 'Точнее'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 29, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('~П~ереоценки',
  NewSItem('Перео~ц~енки по возврату',
{  NewSItem('Переоценки по ~р~евизии',}
  NewSItem('~В~се переоценки', Nil)))));

Dlg^.Insert(Control);

c:=2;

Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
  Begin
   Dlg^.GetData(c);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectPrz:=c;
  End
  Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectPrz:=3;
  End;
end;



Function SelectIDTip:Byte;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelectIdTip:=0;

R.Assign(31, 9, 61, 14);

R.Assign(25, 9, 54, 14);
New(Dlg, Init(R, 'Отбор'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 28, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('~З~апрещенные к продаже',
  NewSItem('~Р~азрешенные к продаже',
  NewSItem('~В~се', Nil)))));
Dlg^.Insert(Control);

c:=2;

Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
  Begin
   Dlg^.GetData(c);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectIDTip:=c;
  End
  Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectIDTip:=3;
  End;
end;



Function SelectForma4:Byte;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelectForma4:=0;


R.Assign(25, 9, 54, 15);
New(Dlg, Init(R, 'Уточните'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 28, 5);
Control := New(PRadioButtons, Init(R,
  NewSItem('Форма ~1~',
  NewSItem('Форма ~2~',
  NewSItem('Форма ~3~',
  NewSItem('Форма ~4~',
  Nil))))));
Dlg^.Insert(Control);

c:=0;

Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
  Begin
   Dlg^.GetData(c);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectForma4:=c;
  End
  Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectForma4:=4;
  End;
end;

Function SelectForma3:Byte;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelectForma3:=0;


R.Assign(25, 9, 54, 14);
New(Dlg, Init(R, 'Уточните'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 28, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('Форма ~1~',
  NewSItem('Форма ~2~',
  NewSItem('Форма ~3~',
  Nil)))));
Dlg^.Insert(Control);

c:=0;

Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
  Begin
   Dlg^.GetData(c);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectForma3:=c;
  End
  Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectForma3:=3;
  End;
end;



Function SelectSort:Byte;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelectSort:=0;

R.Assign(26, 9, 53, 13);
New(Dlg, Init(R, 'Вид сортировки'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 26, 3);
Control := New(PRadioButtons, Init(R,
  NewSItem('Ра~з~делы по коду',
  NewSItem('Разделы по ~а~лфавиту', Nil))));

Dlg^.Insert(Control);

c:=0;

Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
  Begin
   Dlg^.GetData(c);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectSort:=c;
  End
  Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectSort:=2;
  End;
end;


Function SelectVidFullInfo(A:Word;M:Maska6):Word;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;

Begin
SelectVidFullInfo:=0;
R.Assign(24, 9, 56, 14);
New(Dlg, Init(R, 'Укажите вид операций'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;

R.Assign(1, 1, 31, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('~П~риход',
  NewSItem('~О~тгрузка',
  NewSItem('~В~озврат',
  NewSItem('П~е~реоценка',
  NewSItem('Ревизи~я~',
  NewSItem('~Р~/П', Nil))))))));
Dlg^.Insert(Control);

Dlg^.SetData(A);

BitToWord6(M,a);

PCluster(Control)^.SetButtonState(a, False);

Dlg^.SelectNext(False);


c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(c);
  Dispose(Control,Done);
  Inc(c);
  SelectVidFullInfo:=C;
 End
 Else SelectVidFullInfo:=0;
 Dispose(Control,Done);
 Dispose(Dlg,Done);
End;



(*
Procedure ChekBank(st:AllStr);
VAr f : Text;
    s : String[CAll];
    Test : Boolean;
    Wspom : PBox;
    R:TRect;
    i : Word;
    Temp:PBox;
Begin
DelSpaceRight(St);
If st[0]<>#0 Then
Begin
i:=IOResult;
Assign(f,Path^.Dat.ToSPR+'bank.db');
If LockPostWriteRead(FDate) Then
Begin
Reset(f);
i:=IOResult;
If i<>0 Then
 Begin
  Repeat
  Until UnLockPostWriteRead(FDate);
  Exit;
 End;
Test:=False;
While Not(Eof(f)) Do
 Begin
  Readln(f,s);
  If Pos(st,s)=1 Then
        Begin
         Test:=True;
         Break;
        End;
 End;
Close(f);
If Not(Test) Then
 Begin
 Reset(f);
 R.Assign(0, 0, 0, 0);
 Temp := New(PBox, Init(R, 1, Nil));
 Temp^.NewList(New(PTextCollection, Init(1,1)));
 While Not(Eof(F)) Do
  Begin
        Readln(f,s);
        Temp^.List^.Insert(NewStr(s));
        Temp^.SetRange(Temp^.List^.Count);
  End;
        Temp^.List^.Insert(NewStr(st));
        Temp^.SetRange(Temp^.List^.Count);
 Close(f);
 Rewrite(f);
 i:=IOResult;
 If i=0 Then
 Begin
 For i:=Temp^.List^.Count-1 DownTo 0 Do
  Begin
        s:=Temp^.GetText(i,Temp^.List^.Count);
        Writeln(f,s);
  End;
 Close(f);
 End;
 i:=IOResult;
 Dispose(Temp,Done);
 End;
        Repeat
        Until UnLockPostWriteRead(FDate);
End;{Lock}
End;
End;
*)



Function SelectImport(k:Word):Byte;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin

SelectImport:=1;

R.Assign(26, 9, 56, 13);
If k in [20,30] Then
R.Assign(26, 9, 56, 14);
If k in [29,35] Then
R.Assign(26, 9, 56, 15);
If k in [31,34,37] Then
R.Assign(26, 9, 58, 13);
R.Assign(26, 9, 58, 13);


If k in [32,33] Then
R.Assign(26, 9, 60, 13);

If k = 35 Then
R.Assign(26, 9, 61, 14);

New(Dlg, Init(R, 'Назначение'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 29, 3);
If k in [20,30] Then
R.Assign(1, 1, 29, 4);
If k in [29] Then
R.Assign(1, 1, 29, 5);
If k in [31,34] Then
R.Assign(1, 1, 31, 3);


Case k Of
0:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('~К~онвертировать в Excel',
  NewSItem('~П~ечать из DOS', Nil))))
  eND;
1:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('~С~водные продажи',
  NewSItem('~М~аксимальные розничные', Nil))));
  End;
2:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Количество в ~ш~туках',
  NewSItem('Количество в ~у~паковках', Nil))));
  End;
3:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('~П~ромежуточный отчет',
  NewSItem('П~о~лный отчет за день', Nil))));
  End;
4:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('П~о~лная ведомость',
  NewSItem('~Т~олько отгруженные',Nil))));
  End;
5:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Долги реальные по опл.',
  NewSItem('Долги теоретические',Nil))));
  End;
6:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Служба доставки',
  NewSItem('Сигаретники',Nil))));
  End;
7:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Скидка процентом',
  NewSItem('Скидка суммой',Nil))));
  End;
8:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Указать доставку',
  NewSItem('Не указывать доставку',  Nil))));
  End;
9:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Не включая бронь',
  NewSItem('Включая бронь',  Nil))));
  End;
10:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Развернутые оплаты',
  NewSItem('Сокращенные оплаты',  Nil))));
  End;

11:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Сумма скидки',
  NewSItem('Доходность',  Nil))));
  End;

12:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('~С~тандартный вариант',
  NewSItem('С ~з~акупочными ценами',  Nil))));
  End;

13:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Наименование+Поставщик',
  NewSItem('Наименование+Цены...',
  Nil))));
  End;

14:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Для Бухгалтерии',
  NewSItem('Стандартный отчет',  Nil))));
  End;

15:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Просмотреть ~о~тгрузку',
  NewSItem('Просмотреть ~в~озврат',  Nil))));
  End;

16:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Сгрупировать по датам',
  NewSItem('Сгруппировать по накл.',  Nil))));
  End;

17:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Закупка для бухгалтерии',
  NewSItem('Закупка 2',  Nil))));
  End;

18:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Сводный отчет',
  NewSItem('Задолженность/Предоплата',  Nil))));
  End;

19:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Полный отчет',
  NewSItem('Краткий отчет',  Nil))));
  End;

20:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Большие ценники',
  NewSItem('Малые ценники',
  NewSItem('Большие ценники(2 цены)',
  Nil)))));
  End;

21:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Отгрузки и возвраты',
  NewSItem('Расчет доходности',
  Nil))));
  End;

22:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('По розничным ценам',
  NewSItem('По закупочным ценам',  Nil))));
  End;

23:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Форма N ~1~',
  NewSItem('Форма N ~2~',  Nil))));
  End;

24:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Искать по кодам',
  NewSItem('Искать по наименованиям',  Nil))));
  End;

25:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Полный отчет',
  NewSItem('Только дефицит товара',  Nil))));
  End;

26:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Полный отчет',
  NewSItem('Только разногласия',  Nil))));
  End;

27:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Указывать количество',
  NewSItem('Не указывать количество',  Nil))));
  End;

28:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('С НДС',
  NewSItem('Без НДС',  Nil))));
  End;

29:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Большие ценники',
  NewSItem('Малые ценники',
  NewSItem('Большие ценники(2 цены)',
  NewSItem('Бланк без цен',
  Nil))))));
  End;
30:
  Begin
   Control := New(PRadioButtons, Init(R,
   NewSItem('Мягкие ограничения',
   NewSItem('Средние ограничения',
   NewSItem('Жесткие ограничения',
   Nil)))));
  End;

31:
  Begin
   R.Assign(1, 1, 31, 3);
   Control := New(PRadioButtons, Init(R,
   NewSItem('Сводный отчет',
   NewSItem('Персональный по агентам',
   Nil))));
  End;

32:
  Begin
   R.Assign(1, 1, 33, 3);
   Control := New(PRadioButtons, Init(R,
   NewSItem('Сводный отчет',
   NewSItem('Персональный по маршрутам',
   Nil))));
  End;
33:
  Begin
   R.Assign(1, 1, 33, 3);
   Control := New(PRadioButtons, Init(R,
   NewSItem('Выбрать по разделам',
   NewSItem('Выбрать по классам',
   Nil))));
  End;

34:
  Begin

   R.Assign(1, 1, 31, 3);
   Control := New(PRadioButtons, Init(R,
   NewSItem('Сводный по отделениям',
   NewSItem('Разбить по отделениям',
   Nil))));
  End;

35:Begin
  R.Assign(1, 1, 33, 4);
  Control := New(PRadioButtons, Init(R,
  NewSItem('Старый',
  NewSItem('Новый',
  NewSItem('Для Крафт',
  NewSItem('Для возвратов',
  NewSItem('Для ОК',
  Nil)))))));
  End;

36:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Старый',
  NewSItem('Новый',
  NewSItem('Для Крафт',
  Nil)))));
  End;

37:Begin
   R.Assign(1, 1, 31, 3);
  Control := New(PRadioButtons, Init(R,
  NewSItem('Объединить по коду 1С',
  NewSItem('Стандартный',  Nil))));
  End;

38:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Цены ~Д~икси',
  NewSItem('Цены ~С~ПАР',  Nil))));
  End;

39:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Редактирование',
  NewSItem('Контроль',  Nil))));
  End;

40:Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('Дикси',
  NewSItem('Спар',  Nil))));
  End;

Else;
End;

Dlg^.Insert(Control);

c:=1;

If k=3 Then
 Begin
  If (TestOpenDate1(FDate)) Then c:=0;
 End;

If k in [12..13] Then
 Begin
{$IFNDEF Tabak}
  c:=0;
{$ELSE}
  c:=1;
{$ENDIF}
 End;


Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
  Begin
   Dlg^.GetData(c);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectImport:=c;
  End
  Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   If k in [20,29,30,35,36] Then SelectImport:=4
   Else SelectImport:=2;
  End;
end;


Function SelectOtdel(Var Otd:Word):Byte;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  MM8:MAska8;
  MM : Maska9;
  MMMS : Word;
begin
SelectOtdel:=2;
Otd:=0;
R.Assign(26, 6, 53, 17);
New(Dlg, Init(R, 'Отделения-приемник'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;


WordToBit8(EnableOtdel,MM8);
 Convert8(mm8);
 Invert8(mm8);

  mm[2]:=mm8[1];
  mm[3]:=mm8[2];
  mm[4]:=mm8[3];
  mm[5]:=mm8[4];
  mm[6]:=mm8[5];
  mm[7]:=mm8[6];
  mm[8]:=mm8[7];
  mm[9]:=mm8[8];;
  {
  Writeln(mm8[1]);
  Writeln(mm8[2]);
  Writeln(mm8[3]);
  Writeln(mm8[4]);
  Writeln(mm8[5]);
  Writeln(mm8[6]);
  Writeln(mm8[7]);
  Writeln(mm8[8]);
  }
  {Invert9(mm);}
  mm[1]:=0;
  Convert9(mm);
  BitToWord9(MM,MMMS);



R.Assign(1, 1, 26, 10);
Control := New(PRadioButtons, Init(R,
  NewSItem('Отделение-поставщик',
  NewSItem('~1~ '+Rek^.Dat.Otdel[1],
  NewSItem('~2~ '+Rek^.Dat.Otdel[2],
  NewSItem('~3~ '+Rek^.Dat.Otdel[3],
  NewSItem('~4~ '+Rek^.Dat.Otdel[4],
  NewSItem('~5~ '+Rek^.Dat.Otdel[5],
  NewSItem('~6~ '+Rek^.Dat.Otdel[6],
  NewSItem('~7~ '+Rek^.Dat.Otdel[7],
  NewSItem('~8~ '+Rek^.Dat.Otdel[8],
  Nil)))))))))));
PCluster(Control)^.SetButtonState(MMMS, False);
Dlg^.Insert(Control);

Dlg^.SelectNext(False);


c:=0;
Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
  Begin
   Dlg^.GetData(c);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   If c=0 Then SelectOtdel:=0
   Else SelectOtdel:=1;
   Otd:=c;
  End
  Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
  End;
end;


Procedure InputBuhKoeffizient;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : LongInt;

begin
R.Assign(31, 7, 48, 18);
New(Dlg, Init(R, ''));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(3, 0, 15, 1);
Control := New(PColoredText, Init(R, ' Для акциза ', $4F));
Dlg^.Insert(Control);

For c:=0 To 8 Do
Begin
R.Assign(4, c+1, 16, c+2);
Control := New(PInputLine, Init(R, CZenaZ));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, c+1, 4,c+2);
  Dlg^.Insert(New(PLabel, Init(R, '~'+IntToStr(C,COne)+'~:', Control)));
End;


For c:=0 To 8 Do
 Begin
  MyStr(StrToReal(AkzisKoeff[c]),CZenaZ,CMAntissa,AkzisKoeff[c]);
  DelSpace(AkzisKoeff[c]);
 End;

Dlg^.SelectNext(False);
Dlg^.SetDAta(AkzisKoeff);

c:=Desktop^.ExecView(Dlg);
If c<>cmCAncel Then
 Begin
  Dlg^.GetDAta(AkzisKoeff);
   For c:=0 To 8 Do
    Begin
     MyStr(StrToReal(AkzisKoeff[c]),CZenaZ,CMAntissa,AkzisKoeff[c]);
     DelSpace(AkzisKoeff[c]);
    End;

 { AddProtocol('Корректировка акцизных констант !!! Очень важно','','');}
  c:=0;
  WriteNewCfg(c);
  If c<> 0 Then Errors('Ошибка записи файла конфигурации !');

 End;

Dispose(Control,Done);
Dispose(Dlg,Done);
end;






Begin
 Finding[0]:=#0;

End.