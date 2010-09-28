{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
{$I Compile.INC}

Unit Vozwrat;


Interface


Uses Dialogs,Drivers,Glob,Access,ServStr,LockInfo,MyCalc,Market,Utils,Heads;

Type
  PSummaWindow = ^TSummaWindow;
  TSummaWindow = object(TDialog)
    Function Ini(s:TEnjoyStr;VAr L : Byte;Var BnLogik:Boolean;Var Bn : BezNal):Real;
    Destructor Done; virtual;
  end;


Type SetArrayNalog=Array[1..4]Of NalogType;

Type IT = Array [1..4] Of Real;

Type
  POplataWindow = ^TOplataWindow;
  TOplataWindow = object(TDialog)
    Calc        : PMyCalculator;
    procedure OpenPrintDocWindow(S:TMyString);
    Procedure SaveToFile(Save:Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure CalcItogoDoc(VAr Ih,Is : It);
    Procedure All(R:Word);
    Procedure FreshHint(s:TMyString);
    Destructor Done; virtual;
  end;


Type
  PDolgWindow = ^TDolgWindow;
  TDolgWindow = object(TDialog)
    Cl  : PClientWindow;
    Sum : PSummaWindow;
    Opl : POplataWindow;
    LockInfo : PLocalInfoDynamicDebit;
    ViewMrk  : PFullScreenMrk;
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

Type PInfoDynamicDebit =^TInfoDynamicDebit;
     TInfoDynamicDebit = object(TDialog)
    Cl  : PClientWindow;
    ViewMrk  : PFullScreenMrk;
    procedure OpenDebitWindow;
    procedure FullPreview;
    Procedure FormReport(Const P:PBox);
    Procedure FormReport1(Const P:PBox);
    Procedure FormReport2(Const P:PBox);
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Refresh;
    procedure FreshRashetHint;
  end;



Implementation



uses DBEngine,Objects, Views, MsgBox,Protect,{Calc,}TPDate,Tools,Printers,NetCAll,Windos,
     Utilsp,Utils2,MrkTool,
     App, ColorTxt,Validate,Serv,Nastr,Vision1,Vision5,Net,Stat,NetDbEng;


        Const CIZenaK=10;
              CZenaZ=10;

const ___='-------------------------------------------------------------------------------------';

var
 DolgWindow : PDolgWindow;
 InfoDynamicWindow : PInfoDynamicDebit;
 SumWindow : PSummaWindow;
 OplataWindow : POplataWindow;
 ControlAgent,ControlComment,ControlVidDoc,ControlRashetDoc,ControlRealizSkidki,ControlDoc,COntrolOpl,ControlClient,
 ControlKolSpisok,ControlKolTSh,ControlKolSF,ControlKolSFB,ControlSumSpisok,
 ControlSumTSh,ControlSumSF,ControlSumSFB,ControlSelectorDoc,
 ControlSpisokKOL,ControlSFKOL,ControlSFBKOL,ControlTShKol,ControlAllKol,
 ControlBank,ControlPP,ControlRashet,ControlSummaPP,ControlDatePP,
 ControlOpl1,
 ControlPrim,ControlDolgT,ControlStartDAte,ControlStopDAte,ControlN: PView;
 ControlPassword : PView;
 PrevCurrent : TMyString;
 Prevs: TEnjoyStr;

 Ws : String[CIZena];
 RealFile : File Of RealizasiaType;
 GlobalEr : PRealizasiaType;
 PrevPosition : TMyString;
 AllKol : StrIng[CKol];
 Sf,SkidkaAuto : Boolean;
 Doc : WOrd;
 DolgList,DynamicList: PBox;
 mm,mm2 : Maska9;
 CurrentArtikul : ArtikulStr;
 PrevDoc:ArtikulStr;
 StartDate,StopDate,PrevDate :TDateString;
 ItogNalog:SetArrayNalog;
 CloseVidDoc:Word;


{ конец объект и методы окна ввода количества товара}

{Type
  POplataWindow = ^TOplataWindow;
  TOplataWindow = object(TDialog)
    KolW  : PKolWindow;
    procedure OpenPrintDocWindow;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure CalcItogoDoc;
  end;}

Procedure TOplataWindow.OpenPrintDocWindow(S:TMyString);
Label StopAdd,Avaria;
Var R : TRect;
    c : LongInt;

    Control : PView;
    st : string;
    NDS,VidNalog,VidNDS,Nalog,SArtikul,Sdoc,SDate : TDateString;
    Special,L : Boolean;
    NSumma : AllStr;
    GlobalErMrk : PSuperMArketType;
    ih,Is : It;
    k : Byte;
Begin

  WordToBit9(DebitDocNumer,MM);
  k:=1;
  For c:=Max9 Downto 1 Do
   Begin
    mm2[k]:=mm[c];
    inc(k);
   End;

 PStaticText(ControlClient)^.GetText(St);
 System.Delete(St,1,1);

 St:=Copy(St,1+CClient+1,CClientKod);
 SDoc:=Copy(s,1+1,CDocNumer);
{ SDoc:=Copy(s,1+1+CDate+1,CDocNumer);}
 DelSpace(SDoc);
 DelZerro(SDoc);

 SDate:=Copy(s,1+1+CDocNumer+1,CDate);
{ SDate:=Copy(s,1+1,CDate);}
 DelSpace(SDate);

DInfo('Формирую документы...');

 Assign (RealFile,Path.ToDolg+St+'.dlg');
 c:=IOResult;
 Reset(RealFile);
 c:=IOResult;
 If c<>0 Then
  Begin
   NoInfo;
   MessageBox(#3'Ошибка '+Path.ToDolg+St+'.dlg',Nil,mfError+mfCancelButton);
   Exit;
  End;

  L:=False;
  New(GlobalEr,Init);
  While Not(Eof(RealFile)) And Not(l) Do
   Begin
    Read(RealFile,GlobalEr^.Dat);
    DelSpace(GlobalEr^.Dat.Market.Document);
    DelZerro(GlobalEr^.Dat.Market.Document);
    If (GlobalEr^.Dat.Market.Document=SDoc) And
       (GlobalEr^.Dat.Market.DateC=SDate) And
          (GlobalEr^.Dat.Market.Active) Then L:=True;
   End;
 System.Close(RealFile);
 If Not(l) Then
  Begin
   Dispose(GlobalEr,Done);
   NoInfo;
   MessageBox(#3'Документ N '+SDoc+' '+SDate+' не найден!',Nil,mfError+mfCancelButton);
{  System.Close(RealFile);}
   Exit;
  End;


  New(GlobalErMrk,Init);
  If Not (GetMarket(GlobalEr,GlobalErMrk)) Then
   Begin
    Dispose(GlobalEr,Done);
    Dispose(GlobalErMrk,Done);
    NoInfo;
    MessageBox(#3'Документ N '+SDoc+' за '+SDate+' не найден!',Nil,mfError+mfCancelButton);
    Exit;
   End;



R.Assign(6, 1, 73, 23);
New(OplataWindow, Init(R, 'Оформление документов консигнации'));
OplataWindow^.Options := OplataWindow^.Options or ofCenterX;
OplataWindow^.HelpCtx :=$E306;

R.Assign(66, 3, 67, 19);
Control := New(PScrollBar, Init(R));
OplataWindow^.Insert(Control);



CloseVidDoc:=GlobalEr^.Dat.Market.DocSelector;

R.Assign(1, 3, 66, 19);
Prodaga := New(PBox, Init(R, 1, PScrollbar(Control)));
Special:=False;

Avaria:

Prodaga^.NewList(New(PTextCollection, Init(0,1)));

  c:=1;

  For c:=1 To GlobalErMrk^.Dat.Amount Do
   Begin
    S:=GetIdField(FName,GlobalErMrk^.Dat.MarketElement[c].BazKod);
    Format(S,CName);
    s:=s+'│'+GlobalErMrk^.Dat.MarketElement[c].BazKod;
    Str(GlobalErMrk^.Dat.MarketElement[c].Input.DiviSionSNumber:1,SArtikul);
    s:=s+'│'+SArtikul+'│';


{уменшаем количество на велечину возврата}
  Str(STrToInt(GlobalErMrk^.Dat.MarketElement[c].Input.Kol)-
  StrToInt(GetReturnKol(GlobalErMrk^.Dat.Document,GlobalErMrk^.Dat.DateC,GlobalErMrk^.Dat.ClientKod,
  GlobalErMrk^.Dat.MarketElement[c].BazKod,SArtikul,
  GlobalErMrk^.Dat.OperatorSelector)):CKol,GlobalErMrk^.Dat.MarketElement[c].Input.Kol);

{
Str(StrToInt(GlobalEr^.Dat.Market.MarketElement[c].Input.Kol):CKol,GlobalEr^.Dat.Market.MarketElement[c].Input.Kol);
    Format (GlobalEr^.Dat.Market.MarketElement[c].Input.Kol,CKol);
}
    s:=s+GlobalErMrk^.Dat.MarketElement[c].Input.Kol+'│';


If StrToInt(GlobalErMrk^.Dat.MarketElement[c].Input.Kol)>0 Then
   Begin
MyStr(StrToReal(GlobalErMrk^.Dat.MarketElement[c].Input.Zena),CZena,CMantissa,
GlobalErMrk^.Dat.MarketElement[c].Input.Zena);
    Format (GlobalErMrk^.Dat.MarketElement[c].Input.Zena,CZena);
    s:=s+GlobalErMrk^.Dat.MarketElement[c].Input.Zena+'│';
MyStr(StrToReal(GlobalErMrk^.Dat.MarketElement[c].Input.Skidka),CZena,CMantissa,
GlobalErMrk^.Dat.MarketElement[c].Input.Skidka);
    Format(GlobalErMrk^.Dat.MarketElement[c].Input.Skidka,CZena);
    s:=s+GlobalErMrk^.Dat.MarketElement[c].Input.Skidka+'│';
MyStr(StrToReal(GlobalErMrk^.Dat.MarketElement[c].Input.Proz),CLitr+1,CMantissa+2,
GlobalErMrk^.Dat.MarketElement[c].Input.Proz);
    Format(GlobalErMrk^.Dat.MarketElement[c].Input.Proz,CLitr+1);
    s:=s+GlobalErMrk^.Dat.MarketElement[c].Input.Proz+'│';
    Format(GlobalErMrk^.Dat.MarketElement[c].Input.R_Zena,CZena);
    Format(GlobalErMrk^.Dat.MarketElement[c].Input.O_Zena,CZena);
    Format(GlobalErMrk^.Dat.MarketElement[c].Input.Zakupka,CZena);
    Format(GlobalErMrk^.Dat.MarketElement[c].Input.Itogo,CInputIZena);
    ws:=GetIdField(FLitr,GlobalErMrk^.Dat.MarketElement[c].BazKod);
    Format(WS,CLitr);


    For k:=1 To Max9 Do
     mm2[k]:=0;


{$IFNDEF Aisha}
    Case GlobalEr^.Dat.Market.DocSelector Of
    5:mm2[3]:=1;
    6:mm2[3]:=1;
    7:mm2[2]:=1;
    8:mm2[4]:=1;
     Else;
     End;
{$ELSE}

(*    Case GlobalEr^.Dat.Market.DocSelector Of
    {
    5:mm2[3]:=1;
    7:mm2[2]:=1;
    }
    5:mm2[2]:=1;
    6:mm2[4]:=1;
    7:mm2[1]:=1;
    8:mm2[5]:=1;

     Else;
     End;      *)


{$ENDIF}



{
    For k:=1 To Max9 Do
     mm2[k]:=0;

    Case GlobalEr^.Dat.Market.DocSelector Of
    5:mm2[2]:=1;
    6:mm2[4]:=1;
    7:mm2[1]:=1;
    8:mm2[5]:=1;

     Else;
     End;
}

    If Special Then
     Begin
       For k:=1 To Max9 Do mm2[k]:=0;
           mm2[1]:=1;
     End;

{$IFNDEF Aisha}

     If mm2[2]=1 Then{Если ТЧ не запрещен}
      Begin
       If TestRazdelA(GlobalErMrk^.Dat.MarketElement[c].BazKod,TChekRazdel) Then
        Begin
         s:=s+GlobalErMrk^.Dat.MarketElement[c].Input.Itogo+'│'+
         GlobalErMrk^.Dat.MarketElement[c].Input.R_Zena+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.O_Zena+
         '│0    '+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.Kol+'│0    '+'│0    ';
         Goto StopAdd;
        End;
      End;



     If mm2[3]=1 Then{Если ФЛ не запрещена}
     Begin
       If TestRazdelA(GlobalErMrk^.Dat.MarketElement[c].BazKod,FZRazdel) Then
        Begin
         s:=s+GlobalErMrk^.Dat.MarketElement[c].Input.Itogo+'│'+
         GlobalErMrk^.Dat.MarketElement[c].Input.R_Zena+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.O_Zena+'│0    '+
         +'│0    '+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.Kol+'│0    ';
        Goto StopAdd;
        End;
     End;


     If mm2[1]=1 Then{Если список не запрещен}
     Begin
       If TestRazdelA(GlobalErMrk^.Dat.MarketElement[c].BazKod,SpisokRazdel) Then
        Begin
         s:=s+GlobalErMrk^.Dat.MarketElement[c].Input.Itogo+'│'+
         GlobalErMrk^.Dat.MarketElement[c].Input.R_Zena+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.O_Zena+'│'+
        +GlobalErMrk^.Dat.MarketElement[c].Input.Kol+'│0    '+'│0    '+'│0    ';
        Goto StopAdd;
        End;
     End;

     If mm2[4]=1 Then{Если СФ не запрещена}
     Begin
       If TestRazdelA(GlobalErMrk^.Dat.MarketElement[c].BazKod,FZRazdel) Then
        Begin
         s:=s+GlobalErMrk^.Dat.MarketElement[c].Input.Itogo+'│'+
         GlobalErMrk^.Dat.MarketElement[c].Input.R_Zena+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.O_Zena+'│0    '+
         +'│0    '+'│0    '+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.Kol;
        Goto StopAdd;
        End;
     End;

{$ELSE}

(*     If mm2[2]=1 Then{Если ТЧ не запрещен}
      Begin
       If TestRazdel(GlobalErMrk^.Dat.MarketElement[c].BazKod,TChekRazdel) Then
        Begin
         s:=s+GlobalErMrk^.Dat.MarketElement[c].Input.Itogo+'│'+
         GlobalErMrk^.Dat.MarketElement[c].Input.R_Zena+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.O_Zena+
         '│0    '+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.Kol+'│0    '+'│0    ';
         Goto StopAdd;
        End;
      End;

     If mm2[4]=1 Then{Если СФ не запрещена}
     Begin
       If TestRazdel(GlobalErMrk^.Dat.MarketElement[c].BazKod,FZRazdel) Then
        Begin
         s:=s+GlobalErMrk^.Dat.MarketElement[c].Input.Itogo+'│'+
         GlobalErMrk^.Dat.MarketElement[c].Input.R_Zena+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.O_Zena+'│0    '+
         +'│0    '+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.Kol+'│0    ';
        Goto StopAdd;
        End;
     End;

     If mm2[1]=1 Then{Если список не запрещен}
     Begin
       If TestRazdel(GlobalErMrk^.Dat.MarketElement[c].BazKod,SpisokRazdel) Then
        Begin
         s:=s+GlobalErMrk^.Dat.MarketElement[c].Input.Itogo+'│'+
         GlobalErMrk^.Dat.MarketElement[c].Input.R_Zena+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.O_Zena+'│'+
        +GlobalErMrk^.Dat.MarketElement[c].Input.Kol+'│0    '+'│0    '+'│0    ';
        Goto StopAdd;
        End;
     End;


     If mm2[5]=1 Then{Если СФБ не запрещена}
     Begin
       If TestRazdel(GlobalErMrk^.Dat.MarketElement[c].BazKod,SFBRazdel) Then
        Begin
         s:=s+GlobalErMrk^.Dat.MarketElement[c].Input.Itogo+'│'+
         GlobalErMrk^.Dat.MarketElement[c].Input.R_Zena+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.O_Zena+'│0    '+
         +'│0    '+'│0    '+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.Kol;
        Goto StopAdd;
        End;
     End;       *)

{$EndIf}




(*
     If mm2[5]=1 Then{Если СФБ не запрещена}
     Begin
       If TestRazdel(GlobalEr^.Dat.Market.MarketElement[c].BazKod,SFBRazdel) Then
        Begin
         s:=s+GlobalEr^.Dat.Market.MarketElement[c].Input.Itogo+'│'+
         GlobalEr^.Dat.Market.MarketElement[c].Input.R_Zena+'│'+GlobalEr^.Dat.Market.MarketElement[c].Input.O_Zena+'│0    '+
         +'│0    '+'│0    '+'│'+GlobalEr^.Dat.Market.MarketElement[c].Input.Kol;
        Goto StopAdd;
        End;
     End;
*)

StopAdd:
           MyStr(StrToReal(GlobalErMrk^.Dat.MarketElement[c].Input.Zakupka),CZena,CMantissa,
           GlobalErMrk^.Dat.MarketElement[c].Input.Zakupka);
           Format (GlobalErMrk^.Dat.MarketElement[c].Input.Zakupka,CZena);

            Nalog:=GlobalErMrk^.Dat.MarketElement[c].Input.SpecNalog;
            DelSpace(NAlog);
            Format(Nalog,CLitr);
            NDS:=GlobalErMrk^.Dat.MarketElement[c].Input.NDS;
            DelSpace(NDS);
            Format(NDS,CLitr);
            VidNalog:=IntToStr(GlobalErMrk^.Dat.MarketElement[c].Input.VidNalog,1);
            DelSpace(VidNalog);
            VidNDS:=IntToStr(GlobalErMrk^.Dat.MarketElement[c].Input.VidNDS,1);
            DelSpace(VidNDS);
            s:=s+'│'+Nalog+'│'+VidNalog+'│'+NDS+'│'+VidNDS+'│'+GlobalErMrk^.Dat.MarketElement[c].Input.Zakupka;

            Prodaga^.List^.Insert(NewStr(s));
            Prodaga^.SetRange(Prodaga^.List^.Count);
     End;{GlobalEr^.Dat.Market.MarketElement[c].Input.Kol>0}
   End;

Prodaga^.FocusItem(0);
OplataWindow^.Insert(Prodaga);

If GlobalEr^.DAt.MArket.SkidkaSelector in [0,2] Then SkidkaAuto:=True
Else SkidkaAuto:=False;

Sf:=GlobalEr^.DAt.SF;


  R.Assign(1, 2, 66, 3);
  OplataWindow^.Insert(New(PLabel, Init(R, 'Наименование товара         Код  N Колич   Цена    Скидка  Проц.', Prodaga)));

R.Assign(3, 19, 10, 20);
Control := New(PColoredText, Init(R, 'Список:', $71));
OplataWindow^.Insert(Control);

R.Assign(10, 19, 15, 20);
ControlKolSpisok := New(PColoredText, Init(R, #3'0', $7E));
OplataWindow^.Insert(ControlKolSpisok);

R.Assign(19, 19, 27, 20);
Control := New(PColoredText, Init(R, 'Тов.Чек:', $71));
OplataWindow^.Insert(Control);

R.Assign(27, 19, 32, 20);
ControlKolTSh := New(PColoredText, Init(R, #3'0', $7E));
OplataWindow^.Insert(ControlKolTSh);

R.Assign(37, 19, 41, 20);
Control := New(PColoredText, Init(R, 'ФЛ*:', $71));
OplataWindow^.Insert(Control);

R.Assign(41, 19, 46, 20);
ControlKolSF := New(PColoredText, Init(R, #3'0', $7E));
OplataWindow^.Insert(ControlKolSF);

R.Assign(51, 19, 59, 20);
Control := New(PColoredText, Init(R, 'С/Ф Б/Н:', $71));
OplataWindow^.Insert(Control);

R.Assign(59, 19, 64, 20);
ControlKolSFB := New(PColoredText, Init(R, #3'0', $7E));
OplataWindow^.Insert(ControlKolSFB);

R.Assign(2, 20, 17, 21);
ControlSumSpisok := New(PColoredText, Init(R, #3'0.00', $4E));
OplataWindow^.Insert(ControlSumSpisok);

R.Assign(18, 20, 33, 21);
ControlSumTSh := New(PColoredText, Init(R, #3'0.00', $4E));
OplataWindow^.Insert(ControlSumTSh);

R.Assign(34, 20, 49, 21);
ControlSumSF := New(PColoredText, Init(R, #3'0.00', $4E));
OplataWindow^.Insert(ControlSumSF);

R.Assign(50, 20, 65, 21);
ControlSumSFB := New(PColoredText, Init(R, #3'0.00', $4E));
OplataWindow^.Insert(ControlSumSFB);

R.Assign(2, 21, 34, 22);
Control := New(PColoredText, Init(R, ' Сумма по документу консигнации:', $71));
OplataWindow^.Insert(Control);


MyStr(StrToReal(GlobalEr^.Dat.Market.SummaZ),CIZena,CMantissa,NSumma);

DelSpace(NSumma);


R.Assign(34, 21, 49, 22);
Control := New(PColoredText, Init(R, #3+NSumma, $7E));
OplataWindow^.Insert(Control);

R.Assign(50, 21, 58, 22);
Control := New(PColoredText, Init(R, ' Скидка:', $71));
OplataWindow^.Insert(Control);

{
R.Assign(58, 21, 64, 22);
CAse GlobalEr^.Dat.Market.SkidkaSelector Of
0 :Control := New(PColoredText, Init(R, 'AUTO', $7E));
1 :Control := New(PColoredText, Init(R, 'NOAUTO', $7E));
2 :Control := New(PColoredText, Init(R, 'SHKALA', $7E));
Else;
End;
OplataWindow^.Insert(Control);
}

PStaticText(ControlClient)^.GetText(S);
System.Delete(S,1,1);

R.Assign(39, 1, 66, 2);
Control := New(PColoredText, Init(R, #3+S, $1F));
OplataWindow^.Insert(Control);

R.Assign(2, 1, 15, 2);
Control := New(PColoredText, Init(R, 'По документу:', $71));
OplataWindow^.Insert(Control);

DelSpace(GlobalEr^.Dat.Market.Document);
R.Assign(15, 1, 19, 2);
Control := New(PColoredText, Init(R, #3+GlobalEr^.Dat.Market.Document, $7E));
OplataWindow^.Insert(Control);

R.Assign(20, 1, 22, 2);
Control := New(PColoredText, Init(R, 'от', $71));
OplataWindow^.Insert(Control);

R.Assign(23, 1, 31, 2);
Control := New(PColoredText, Init(R, #3+GlobalEr^.Dat.Market.DateC, $7E));
OplataWindow^.Insert(Control);

Dispose(GlobalEr,Done);
Dispose(GlobalErMrk,Done);


OplataWindow^.SelectNext(False);
PrevPosition[0]:=#0;

  WordToBit9(DebitDocNumer,MM);
  k:=1;
  For c:=Max9 Downto 1 Do
   Begin
    mm2[k]:=mm[c];
    inc(k);
   End;

CalcItogoDoc(ih,Is);

NoInfo;

(*
If (StrToInt(CurrentPassword)=0) And Not(Sf) Then
   Begin
    mm2[1]:=1;
    mm2[2]:=1;
    mm2[3]:=1;
    mm2[4]:=1;
    mm2[5]:=1;
    mm2[6]:=1;
    mm2[7]:=1;
    mm2[8]:=1;
    mm2[9]:=1;
   End;
*)

C:=Desktop^.ExecView(OplataWindow);

Dispose(Control,Done);
Dispose(OplataWindow,Done);
End;


Procedure TOplataWindow.FreshHint(s:TMyString);
Var R : TRect;
    St : String[CKol];
    L : Word;
Begin
l:=1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CKol+1+1+CZena+1+CZena+1+CInputIZena+1;
st:=Copy(s,L,CKol);
DelSpace(St);
Dispose(ControlKolSpisok,Done);
R.Assign(10, 19, 15, 20);
ControlKolSpisok := New(PColoredText, Init(R, #3+st, $7E));
OplataWindow^.Insert(ControlKolSpisok);

Dispose(ControlKolTSh,Done);
st:=Copy(s,L+CKol+1,CKol);
DelSpace(St);
R.Assign(27, 19, 32, 20);
ControlKolTSh := New(PColoredText, Init(R, #3+St, $7E));
OplataWindow^.Insert(ControlKolTSh);

Dispose(ControlKolSF,Done);
st:=Copy(s,L+CKol+1+CKol+1,CKol);
DelSpace(St);
R.Assign(41, 19, 46, 20);
ControlKolSF := New(PColoredText, Init(R, #3+St, $7E));
OplataWindow^.Insert(ControlKolSF);

Dispose(ControlKolSFB,Done);
st:=Copy(s,L+CKol+1+CKol+1+CKol+1,CKol);
DelSpace(St);
R.Assign(59, 19, 64, 20);
ControlKolSFB := New(PColoredText, Init(R, #3+St, $7E));
OplataWindow^.Insert(ControlKolSFB);
End;





Procedure TOplataWindow.All(R:Word);
Var ws1,s : TMYString;
    SArtikul : ArtikulStr;
    ih,Is : It;
Begin
(*
if (Prodaga^.State and sfFocused <> 0)  And(Prodaga^.List<>Nil) And (Prodaga^.List^.Count>=1)Then
   Begin
   If Not(Sf) Then
    Begin
    If (Not((r=cmAllSpis)And(mm2[1]<>1)))
    And(Not((r=cmAllTCh)And(mm2[2]<>1)))
    And(Not((r=cmAllSfb)And(mm2[5]<>1)))

     Then
    Begin
    s:=Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count);
    Sartikul:=Copy(s,1+CName+1,CArtikul);
    ws1:=Copy(s,1,1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CKol+1+CZena+1+CZena+1+CInputIZena);
    s:=Copy(s,1+CNAme+1+CArtikul+1+COne+1,CKol);
    CAse R Of
    cmAllSf: s:=ws1+'    0│    0│'+S+'│    0';
    cmAllSpis:s:=ws1+s+'│    0│    0│    0';
    cmAllTCh:Begin
             If TestRazdel(SArtikul) Then
              s:=ws1+'    0│'+s+'│    0│    0'
              Else
              Exit;
             End;
    cmAllSfb:s:=ws1+'    0│    0│    0│'+S;
    Else Exit;
    End;

    Prodaga^.List^.AtFree(Prodaga^.Focused);
    Prodaga^.SetRange(Prodaga^.List^.Count);

    Prodaga^.List^.Insert(NewStr(s));
    Prodaga^.SetRange(Prodaga^.List^.Count);
    PrevPosition[0]:=#0;
    If (Prodaga^.Focused+1)<Prodaga^.List^.Count Then
      Prodaga^.FocusItem(Prodaga^.Focused+1);
    CalcItogoDoc(ih,Is);
    End
     Else
       Begin
        MessageBox(^m+#3'Вам нельзя редактировать этот вид документов!',Nil,mfError+mfCancelButton);
       End;
    End
    Else
     Begin
     SpecialBeep;
     MessageBox(#3^m+#3'Извините но документы можно оформить только на С/Ф!',nil,mfError+mfCancelButton);
     End;
   End;
*)
End;

Function Distanation(K:Byte):Boolean;

Const l=1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CKol+1+1+CZena+1+CZena+1+CInputIZena+1;
VAr i : Word;
    s : string[150];
Begin
Distanation := False;
If (Prodaga^.List^.Count)>0 Then
For i:=0 To Prodaga^.List^.Count-1 Do
 Begin
  s:=Prodaga^.GetText(i,Prodaga^.List^.Count);
  s:=Copy(s,l+K*(CKol+1),CKol);
  If StrToInt(s)<>0 Then
     Begin
      Distanation:=True;
      Break;
     End;
 End;
End;


Procedure TOplataWindow.SaveToFile(Save:Boolean);
Label 1;
Var ih,Is :It;
    TestDoc : Array[1..4]Of Boolean;
    dop,my,i : Byte;
    j,k :Word;
    s :string;
    NewDoc : Array [1..4] Of PSuperMarketType;
    ER : PRealizasiaType;
    SDoc:String[CDocNumer];
    SDAte : TDateString;
    SClient : String[CClientKod];
    fr : File Of RealizasiaType;
    Find : Boolean;
    Pos  : LongInt;
    As : DocumentEdit;
Begin
Save:=False;

CalcItogoDoc(Ih,Is);

{проверяем созданные документы}
For i:=0 To 3 Do
 Begin
  TestDoc[i+1]:=Distanation(i);
 End;

If Not(TestDoc[1]) And Not(TestDoc[2]) And Not(TestDoc[3]) And Not(TestDoc[4])
   Then TestDoc[1]:=True;

{конец проверки}

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
  MessageBox(#3'Не найден файл задолженности клиента '+SClient,Nil,mfError+mfCancelButton);
  Exit;
 End;
Find := False;

{ищем исходный документ реализации в файле задолженности}
DelZerro(SDoc);

New(Er,Init);
While Not(Eof(fr)) And Not(Find) Do
 Begin
  Read(fr,Er^.Dat);
  DelSpace(Er^.Dat.Market.Document);
  DelZerro(Er^.Dat.Market.Document);
  DelSpace(Er^.Dat.MArket.DateC);
  If (Er^.Dat.Market.Document=SDoc) And
     (Er^.DAt.Market.DateC=SDate) And
     (Er^.DAt.Market.Active) Then Find := True;
 End;
If Not(Find) Then
   Begin
    System.Close(fr);
    Dispose(Er,DOne);
    MessageBox(#3+'Документ N '+SDoc+' за '+SDate+''^M
    +#3'в долгах найден!',Nil,mfError+mfCancelButton);
    Exit;
   End;

{формируем необходимые документы}
For i:=0 To 3 Do
 Begin
 If TestDoc[i+1] Then
   Begin
    New(NewDoc[i+1],Init);
    k:=1;
    If Prodaga^.List^.Count>=1 Then
    Begin
    For j:=0 To Prodaga^.List^.Count-1 Do
     Begin
      s:=Prodaga^.GetText(j,Prodaga^.List^.Count);
      NewDoc[i+1]^.Dat.MarketElement[k].BazKod:=Copy(s,1+CName+1,CArtikul);
      NewDoc[i+1]^.Dat.MarketElement[k].Input.Kol:=Copy(s,1+CNAme+1+CArtikul+
      1+COne+1+CKol+1+CZena+1+CZena+1+CKol+1+1+CZena+1+CZena+1+CInputIZena+1+i*(CKol+1),Ckol);
      DelSpace(NewDoc[i+1]^.Dat.MarketElement[k].Input.Kol);

      NewDoc[i+1]^.Dat.MarketElement[k].Input.SpecNalog:=Copy(s,1+CNAme+1+CArtikul+
      1+COne+1+CKol+1+CZena+1+CZena+1+CKol+1+1+CZena+1+CZena+1+CInputIZena+1+4*(CKol+1),CLitr);

      DelSpace(NewDoc[i+1]^.Dat.MarketElement[k].Input.SpecNalog);

      NewDoc[i+1]^.Dat.MarketElement[k].Input.VidNalog:=StrToInt(Copy(s,1+CNAme+1+CArtikul+
      1+COne+1+CKol+1+CZena+1+CZena+1+CKol+1+1+CZena+1+CZena+1+CInputIZena+1+4*(CKol+1)+CLitr+1,COne));

      NewDoc[i+1]^.Dat.MarketElement[k].Input.NDS:=Copy(s,1+CNAme+1+CArtikul+
      1+COne+1+CKol+1+CZena+1+CZena+1+CKol+1+1+CZena+1+CZena+1+CInputIZena+1+4*(CKol+1)+CLitr+1+COne+1,CLitr);
      DelSpace(NewDoc[i+1]^.Dat.MarketElement[k].Input.NDS);

      NewDoc[i+1]^.Dat.MarketElement[k].Input.VidNDS:=StrToInt(Copy(s,1+CNAme+1+CArtikul+
      1+COne+1+CKol+1+CZena+1+CZena+1+CKol+1+1+CZena+1+CZena+1+CInputIZena+1+4*(CKol+1)+CLitr+1+COne+1+CLitr+1,COne));

      NewDoc[i+1]^.Dat.MarketElement[k].Input.Zakupka:=Copy(s,1+CNAme+1+CArtikul+
      1+COne+1+CKol+1+CZena+1+CZena+1+CKol+1+1+CZena+1+CZena+1+CInputIZena+1+4*(CKol+1)+CLitr+1+COne+1+CLitr+1+COne+1,CZena);
      DelSpace(NewDoc[i+1]^.Dat.MarketElement[k].Input.Zakupka);

      If StrToInt(NewDoc[i+1]^.Dat.MarketElement[k].Input.Kol)>0 Then
       Begin
         With NewDoc[i+1]^.Dat.MarketElement[k].Input Do
           Begin
        Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CKol+1,CZena);
        DelSpace(Zena);

        Skidka:=Copy(s,1+COne+1+CName+1+CArtikul+1+CKol+1+CZena+1,CZena);
        DelSpace(Skidka);

        DiviSionSNumber:=StrToInt(Copy(s,1+CName+1+CArtikul+1,COne));

        Proz:=Copy(s,1+COne+1+CName+1+CArtikul+1+CKol+1+CZena+1+CZena+1,CKol+1);
        DelSpace(Proz);

        MyStr((StrToInt(Kol)*StrToReal(Zena)),CInputIZena,CMantissa,Itogo);
        DelSpace(Itogo);

        R_Zena:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CZena+1+CZena+1+CKol+1+1+CInputIZena+1+COne+1,CZena);
        DelSpace(R_Zena);

        O_Zena:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CZena+1+CZena+1+CKol+1+1+CInputIZena+1+COne+1+CZena+1,CZena);
        DelSpace(O_Zena);

        Inc(k);
           End;{With}
       End;{Kol<>0}
     End;{For по списку}
     End ;{If Count>=1}
   NewDoc[i+1]^.Dat.Amount:=k-1;
   NewDoc[i+1]^.Dat.Caption:=CurrentPassword;
   NewDoc[i+1]^.Dat.OperatorSelector:=0;
   NewDoc[i+1]^.Dat.DocumentPrz:='1';
   NewDoc[i+1]^.Dat.Region:=Er^.Dat.Market.Region;
   NewDoc[i+1]^.Dat.SkidkaSelector:=Er^.Dat.Market.SkidkaSelector;
   NewDoc[i+1]^.Dat.Realiz:=True;
   NewDoc[i+1]^.Dat.SummaZakupka:=ItogNalog[i+1].Zakupka;
   NewDoc[i+1]^.Dat.ENalog:=ItogNalog[i+1].ENAlog;
   NewDoc[i+1]^.Dat.Nalog5:=ItogNalog[i+1].NAlog5;
   NewDoc[i+1]^.Dat.Nalog3:=ItogNalog[i+1].NAlog3;
   NewDoc[i+1]^.Dat.Nalog_:=ItogNalog[i+1].NAlog_;

   NewDoc[i+1]^.Dat.NaklNumer:=Er^.Dat.Market.NaklNumer;
   NewDoc[i+1]^.Dat.PrhNumer[0]:=#0;
   NewDoc[i+1]^.Dat.SfNumer:=Er^.Dat.Market.SfNumer;

   Case i Of
    0:NewDoc[i+1]^.Dat.DocSelector:=i;
    1:NewDoc[i+1]^.Dat.DocSelector:=i;
{$IFNDEF Aisha}
    2:NewDoc[i+1]^.Dat.DocSelector:=i;
{$ELSE}
    2:NewDoc[i+1]^.Dat.DocSelector:=i+1;
{$ENDIF}
    3:NewDoc[i+1]^.Dat.DocSelector:=i+1;
    Else;
    End;
   NewDoc[i+1]^.Dat.DateC:=FDate;
   NewDoc[i+1]^.Dat.TimeC:=Times;
   NewDoc[i+1]^.Dat.DateM:=FDate;
   NewDoc[i+1]^.Dat.TimeM:=Times;
   MyStr(Ih[i+1],CIZena,CMantissa,NewDoc[i+1]^.Dat.SummaZ);
   DelSpace(NewDoc[i+1]^.Dat.SummaZ);
   MyStr(Is[i+1],CIZena,CMantissa,NewDoc[i+1]^.Dat.SKidka);
   DelSpace(NewDoc[i+1]^.Dat.Skidka);
   NewDoc[i+1]^.Dat.DocReal:=Er^.Dat.Market.Document;
   NewDoc[i+1]^.Dat.DocDAte:=Er^.Dat.Market.DateC;
   NewDoc[i+1]^.Dat.ClientKod:=Er^.Dat.Market.ClientKod;
   NewDoc[i+1]^.Dat.AgentKod :=Er^.Dat.Market.AgentKod;
   SortNkl(NewDoc[i+1]); {сортируем в необходимом порядке все созданные документы}
   End;
End;{For по документам}


{ищем первый не пустой документ}
For i:=1 To 4 Do
  If TestDoc[i] Then Break;


If Not(UseDocNumer(DocMarket,FDate,NewDoc[i]^.Dat.Document)) Then
   Begin
    System.Close(fr);
    Goto 1;
   End;

j:=StrToInt(NewDoc[i]^.Dat.Document)+1;
For dop:=i+1 To 4 Do
Begin
 If TestDoc[dop] Then
 Begin
      NewDoc[dop]^.Dat.DocReal:=Er^.Dat.Market.Document;
      NewDoc[dop]^.Dat.DocDate:=Er^.Dat.Market.DateC;{на первичный}
      NewDoc[dop]^.Dat.Document:=IntToStr(j,CDocNumer);
      DelSpace(NewDoc[dop]^.Dat.Document);
      Inc(j);
      Er^.Dat.Doc[dop].Employ:=True;                 {на вторичный}
      Er^.Dat.Doc[dop].DocReal:=NewDoc[dop]^.Dat.Document;
      Er^.Dat.Doc[dop].DocDate:=NewDoc[dop]^.Dat.DateC;
      Er^.DAt.PayMent:=True;
      Er^.Dat.Full:=True;
 End;{TestDoc}
End;

{сохраняем вновь созданные документы реализации}
For i:=1 To 4 Do
 Begin
If TestDoc[i] Then
Begin

If LockAndWriteMArket(NewDoc[i]) Then
 Begin
  Repeat
  Until (UnlockMarket(NewDoc[i]^.Dat.Document,FDate) in [0,2]);
  Er^.Dat.Doc[i].Employ:=True;                 {на вторичный}
  Er^.Dat.Doc[i].DocReal:=NewDoc[i]^.Dat.Document;
  Er^.Dat.Doc[i].DocDate:=NewDoc[i]^.Dat.DateC;
  Er^.DAt.PayMent:=True;
  Er^.Dat.Full:=True;
 End
 Else
  Begin
       MessageBox(^M+^M+#3+ClicProgrammer,Nil,mfWarning+mfError+mfCancelButton);
       For my:=i DownTo 1 Do
       begin
       end;{цикл освобождения номеров}
       System.Close(fr);
       Goto 1;
  End;

End;
 End;


Seek(fr,FilePos(fr)-1);
Write(fr,Er^.Dat);

System.Close(Fr);
{закончили сохранять новые документы}

{s:='Вывод документов консигнации:';
For i:=1 To 4 Do
 Begin
  If TestDoc[i] Then s:=s+' '+NewDoc[i]^.DAt.Document;
 End;

s:=s+''^M+'по накладной консигнации '+SDoc+' от '+SDAte+' (Клиент:'+SClient+')';}
{AddProtocol(s,'','');}

if Not (Er^.Dat.Realiz) then
CalcNewSrok(SClient,SDAte);

{Печать указанных документов}
For i:=1 To 4 Do
 Begin
 If TestDoc[i] And Not(i in [4]) Then
  Begin
  As.D:=NewDoc[i]^.Dat.DateC;
  As.EditPosition:=NewDoc[i]^.Dat.Document;
  {PrintNaklSklad(As,NPrint.CopyNkl+1);}
  PrintNakl(As,NPrint.CopyNkl+1);
  End;
 End;
{конец печати}

Save := True;
{уничтожение всех задействованных ресурсов}
1:
For i:=1 To 4 Do
 Begin
  If TestDoc[i] Then Dispose(NewDoc[i],Done);
 End;
{Dispose(E,Done);}
Dispose(Er,Done);
{конец сохранения всех задействованных ресурсов}
End;


Procedure TOplataWindow.HandleEvent(Var Event:TEvent);
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

Var s : string;
    ih,Is : It;
    L : Boolean;
Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
           cmLocalCalc:Calculator;


        cmOk          :Begin
                        If MessageBox(#3^M+#3'Закрываю документ консигнации?',Nil,MfConfirmation+mfOkCancel)=cmOk Then
                         Begin
                         {Вставить здесь код записи в файл}
                          SaveToFile(l);
                         End
                         Else
                          ClearEvent(Event);

                       End;
        cmCancel      :Begin
               If MessageBox(#3^M+#3'Отказаться от оформления документов?',Nil,MfConfirmation+mfOkCancel)=cmCancel Then
                         Begin
                          ClearEvent(Event);
                         End;
                       End;
   Else;
   End;
   Else;
   End;

inherited HandleEvent(Event);
ClearEvent(Event);
if (Prodaga^.State and sfFocused <> 0) And(Prodaga^.List<>Nil) And (Prodaga^.List^.Count>=1)Then
   Begin
    s:=Prodaga^.GetText(Prodaga^.Focused,Prodaga^.List^.Count);
    If s <> PrevPosition Then
     Begin
      FreshHint(s);
      PrevPosition:=s;
{     CalcItogoDoc(ih,Is);}
     End
   End;

End;

Procedure TOplataWindow.CalcItogoDoc(Var ih,Is :It);
Const Position=1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CKol+1+1+CZena+1+CZena+1+CInputIZena+1;
  Var w : Byte;
      R : TRect;
      TEmp1 : Array [1..4] Of PBox;
      Mas : Array [1..4] Of String[CKol];
      Ls : LongInt;
      l : Real;
      Zena : String[CIZena];
      Sa : TDateString;
      Zakupka,koefficient,RealZena,Skid,Sso : String[CZena];
      Kol : Array [1..4] Of LongInt;
      itogozakupka,NalogItogo,Sr,Itogo,Itog,SkidkaItogo : Array [1..4] Of Real;
      ItogoZ,ItogoPos : Array [1..4] Of String[CIZena];
      T : Real;
      Itogo_L,Nalogstr,S : TMyString;
      VidNalog : Word;
Begin
For w:=1 To 4 Do
Begin
NalogItogo[w]:=0;

ItogNalog[w].Zakupka[0]:=#0;
ItogNalog[w].ENalog[0]:=#0;
ItogNalog[w].Nalog5[0]:=#0;
ItogNalog[w].Nalog3[0]:=#0;
ItogNalog[w].Nalog_[0]:=#0;
SkidkaItogo[w]:=0;
Itogo[w]:=0;
Itog[w]:=0;
ih[w]:=0;
is[w]:=0;
RealZena[w]:=#0;
itogozakupka[w]:=0;
End;


For ls:=0 To Prodaga^.List^.Count Do
Begin
For w:=1 To 4 Do

Mas[w]:=Copy(Prodaga^.GetText(Ls,Prodaga^.List^.Count),Position+(w-1)*CKol+(w-1),CKol);

{артикул}
Sa:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+CName+1,CArtikul);

{Любая (оптовая или розничная зависит от вида документа) цена}
SSo:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1+CKol+1,CZena);
DelSpace(sso);

{Скидка}
Skid:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1+CKol+1+CZena+1,CZena);
DelSpace(skid);


Zakupka:=Copy(Prodaga^.GetText(Ls,Prodaga^.List^.Count),Position+4*CKol+4+CLitr+1+Cone+1+CLitr+1+COne+1,CZena);
DelSpace(Zakupka);


For w:=1 To 4 Do kol[w]:=StrToInt(Mas[w]);{количество}

t:=StrToReal(Skid);{размер позиционной скидки}

For w:=1 To 4 Do SkidkaItogo[w]:=SkidkaItogo[w]+t*Kol[w];{велечина общей позиционной скидки}



l:=StrToReal(Zakupka);{Закупка}
For w:=1 To 4 Do
 Begin
  MyStr((l*Kol[w]),CInputIZena,CMantissa,ItogoZ[w]);
 End;

For w:=1 To 4 Do
MyStr((StrToReal(ItogoZ[w])+StrToReal(ItogNalog[w].Zakupka)),CIZena,CMantissa,ItogNalog[w].Zakupka);


t:=StrToReal(SSo);{Цена}

{s:=Prodaga^.GetText(Ls,Prodaga^.List^.Count);}
Nalogstr:=Copy(Prodaga^.GetText(Ls,Prodaga^.List^.Count),Position+4*CKol+4,CLitr);
DelSpace(NalogStr);

VidNalog:=StrToInt(Copy(Prodaga^.GetText(Ls,Prodaga^.List^.Count),Position+4*CKol+4+CLitr+1,Cone));

MyStr((1+StrToReal(NalogStr)/100),CLitr,CMantissa,Koefficient);
DelSpace(Koefficient);


MyStr(StrToReal(SSo)-StrToReal(Skid),CZena,CMAntissa,Zena);

MyStr(StrToREal(Zena)*StrToReal(Koefficient),CZena,CMantissa,RealZena);

MySTr(StrToReal(RealZena)-StrToReal(Zena),CZena,CMantissa,RealZena);

For w:=1 To 4 Do
Begin
If CloseVidDoc in [{1,}2,3,5,6] Then
Begin
{велечина спец налога с единицы товара}

MyStr(StrToReal(RealZena)*Kol[w],CIZena,CMantissa,Zena);
DelSpace(Zena);

{суммарная ставка налога}
MyStr((StrToReal(Zena)+StrToReal(ItogNalog[w].ENalog)),CIZena,CMantissa,ItogNalog[w].ENalog);
CAse VidNalog Of
0:MyStr((StrToReal(Zena)+StrToReal(ItogNalog[w].Nalog5)),CIZena,CMantissa,ItogNalog[w].Nalog5);
1:MyStr((StrToReal(Zena)+StrToReal(ItogNalog[w].Nalog3)),CIZena,CMantissa,ItogNalog[w].Nalog3);
2:MyStr((StrToReal(Zena)+StrToReal(ItogNalog[w].Nalog_)),CIZena,CMantissa,ItogNalog[w].Nalog_);
Else;
End;
End;
End;


For w:=1 To 4 Do MyStr((t*Kol[w]),CInputIZena,CMantissa,ItogoPos[w]);

For w:=1 To 4 Do
Itog[w]:=Itog[w]+StrToReal(ItogoPos[w]);{стоимость всего накладной}
End;{for}

Itogo:=Itog;

{Sr:=Itogo;}

If SkidkaAuto Then
 Begin
For w:=1 To 4 Do
Begin
NalogItogo[w]:=0;
ItogNalog[w].ENalog[0]:=#0;
ItogNalog[w].Nalog5[0]:=#0;
ItogNalog[w].Nalog3[0]:=#0;
ItogNalog[w].Nalog_[0]:=#0;
SkidkaItogo[w]:=0;
{Itogo[w]:=0;}
Itog[w]:=0;
ih[w]:=0;
is[w]:=0;
RealZena[w]:=#0;
End;

If Prodaga^.List^.Count>0 Then
Begin
For w:=1 To 4 Do
Begin
R.Assign(0, 0, 0, 0);
Temp1[w] := New(PBox, Init(R, 1, Nil));
Temp1[w]^.NewList(New(PTextCollection, Init(0,1)));
End;
For ls:=0 To Prodaga^.List^.Count-1 Do
Begin
{артикул}
Sa:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+CName+1,CArtikul);

For w:=1 To 4 Do
Mas[w]:=Copy(Prodaga^.GetText(Ls,Prodaga^.List^.Count),Position+(w-1)*CKol+(w-1),CKol);

{Любая (оптовая или розничная зависит от вида документа) цена}
SSo:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1+CKol+1,CZena);

{Любая (оптовая или розничная зависит от вида документа) цена}
Skid:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1+CKol+1+CZena+1+CZena+1,CKol+1);

Nalogstr:=Copy(Prodaga^.GetText(Ls,Prodaga^.List^.Count),Position+4*CKol+4,CLitr);

VidNalog:=StrToInt(Copy(Prodaga^.GetText(Ls,Prodaga^.List^.Count),Position+4*CKol+4+CLitr+1,Cone));


For w:=1 To 4 Do
Begin
If TestElement(Sa,Temp1[w]) Then
 Begin
   For w:=1 To 4 Do
   Temp1[w]^.List^.Insert(NewStr('│'+Sa+'│'+Mas[w]+'│'+SSo+'│'+Skid+'│'+NalogStr+'│'+IntToStr(VidNalog,COne)));
   Temp1[w]^.SetRange(Temp1[w]^.List^.Count);
 End
  Else
   Begin
    Temp1[w]^.FocusItem(Location(Temp1[w],Sa,False)); {нашли фокус}
    S:=Temp1[w]^.GetText(Temp1[w]^.Focused,Temp1[w]^.List^.Count);
    Skid:=Copy(s,2+Cartikul+1,CKol); {Выяснили количество в фокусе}
    Str(StrToInt(Skid)+StrToInt(Mas[w]):CKol,Skid);{Вычислили новое количество}
    Format(Skid,CKol);
    Temp1[w]^.List^.AtFree(Temp1[w]^.Focused); {Удалили старую строку}
    System.Delete(s,2+Cartikul+1,CKol); {Подставли новое количество}
    System.Insert(skid,s,2+Cartikul+1);
    Temp1[w]^.List^.Insert(NewStr(s));
   End;
End;
End;{for}
{ Sr:=0;}
 For w:=1 To 4 Do
 Begin
  Sr[w]:=0;
  For ls:=0 To Temp1[w]^.List^.Count-1 Do
  Begin
  {артикул}
  Sa:=Copy(Temp1[w]^.GetText(ls,Temp1[w]^.List^.Count),2,CArtikul);

  {колич}
  Mas[w]:=Copy(Temp1[w]^.GetText(ls,Temp1[w]^.List^.Count),2+CArtikul+1,CKol);

  {Любая (оптовая или розничная зависит от вида документа) цена}
  SSo:=Copy(Temp1[w]^.GetText(ls,Temp1[w]^.List^.Count),2+CArtikul+1+CKol+1,CZena);

  kol[w]:=StrToInt(Mas[w]);

  Skid:=Copy(Temp1[w]^.GetText(ls,Temp1[w]^.List^.Count),2+CArtikul+1+CKol+1+CZena+1,CKol+1);
  DelSpace(Skid);

  NalogStr:=Copy(Temp1[w]^.GetText(ls,Temp1[w]^.List^.Count),2+CArtikul+1+CKol+1+CZena+1+CKol+1+1,CLitr);

  DelSpace(NAlogStr);

  VidNalog:=StrToInt(Copy(Temp1[w]^.GetText(ls,Temp1[w]^.List^.Count),2+CArtikul+1+CKol+1+CZena+1+CKol+1+1+CLitr+1,COne));

  {Процент скидки}

{новый вариант расчета скидки}
{  t:=StrToReal(SSo)/(1+StrToReal(Skid)/100);}
  t:=StrToReal(SSo)*StrToReal(Skid);

  MyStr(t,CZena,CMantissa,Itogo_L);

  MyStr((1+StrToReal(NalogStr)/100),CLitr,CMantissa,Koefficient);
  DelSpace(Koefficient);

  MyStr(StrToReal(Itogo_L)*StrToReal(Koefficient),CZena,CMantissa,Zena);

  MyStr((StrToReal(Zena)-StrToReal(Itogo_L)),CZena,CMAntissa,RealZena);

  t:=StrToReal(Itogo_L);

  MyStr((t*Kol[w]),CInputIZena,CMantissa,ItogoPos[w]);
  Sr[w]:=Sr[w]+StrToReal(ItogoPos[w]);

If CloseVidDoc in [{1,}2,3,5,6] Then
Begin
  {расчитываем абсолютное значение сбора по спецналогу с единицы товара}
  MyStr(StrToReal(RealZena)*Kol[w],CIZena,CMantissa,RealZena);
  {суммарная ставка налога}
  MyStr((StrToReal(RealZena)+StrToReal(ItogNalog[w].ENalog)),CIZena,CMantissa,ItogNalog[w].ENalog);
 CAse VidNalog Of
 0:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog[w].Nalog5)),CIZena,CMantissa,ItogNalog[w].Nalog5);
 1:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog[w].Nalog3)),CIZena,CMantissa,ItogNalog[w].Nalog3);
 2:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog[w].Nalog_)),CIZena,CMantissa,ItogNalog[w].Nalog_);
 Else;
 End;
End;
  End;{for}

  SkidkaItogo[w]:=Itogo[w]-Sr[w];
  Dispose(Temp1[w],Done);
 End;

End;
End;

For w:=1 To 4 Do
Begin
Itogo[w]:=Itogo[w]-SkidkaItogo[w]+StrToReal(ItogNalog[w].ENalog);
MyStr(Itogo[w],CIZena,CMantissa,ItogoPos[w]);
DelSpace(ItogoPos[w]);
Ih[w]:=Itogo[w]{+StrToReal(ItogNalog[w].ENalog)};
Is[w]:=SkidkaItogo[w];
End;

Dispose(ControlSumSpisok,Done);
R.Assign(2, 20, 17, 21);
ControlSumSpisok := New(PColoredText, Init(R, #3+ItogoPos[1], $4E));
OplataWindow^.Insert(ControlSumSpisok);

Dispose(ControlSumTSh,Done);
R.Assign(18, 20, 33, 21);
ControlSumTSh := New(PColoredText, Init(R, #3+ItogoPos[2], $4E));
OplataWindow^.Insert(ControlSumTSh);

Dispose(ControlSumSF,Done);
R.Assign(34, 20, 49, 21);
ControlSumSF := New(PColoredText, Init(R, #3+ItogoPos[3], $4E));
OplataWindow^.Insert(ControlSumSF);

Dispose(ControlSumSFB,Done);
R.Assign(50, 20, 65, 21);
ControlSumSFB := New(PColoredText, Init(R, #3+ItogoPos[4], $4E));
OplataWindow^.Insert(ControlSumSFB);
End;


Destructor TOplataWindow.Done;
Begin
Dispose(ControlKolSpisok,Done);
Dispose(ControlKolTSh,Done);
Dispose(ControlKolSF,Done);
Dispose(ControlKolSFB,Done);
Dispose(ControlSumSpisok,Done);
Dispose(ControlSumTSh,Done);
Dispose(ControlSumSF,Done);
Dispose(ControlSumSFB,Done);
Dispose(Prodaga,Done);
TDialog.Done;
End;


Function TSummaWindow.Ini(s:TEnjoyStr;VAr L : Byte;Var BnLogik:Boolean;Var Bn : BezNal):Real;
Label 1;
var
  R : TRect;
  Control : PView;
  c : Word;
  St1 : String[CIZena];
  Ls : PSuperMarketType;
var
  DataRec : record
    St : String[CIZena];
   Res : Word;
  end;

begin

DataRec.st[0]:=#0;
DataRec.Res:=0;
DataRec.Res:=StrToInt(Copy(s,1+CDocNumer+1+CDate+1+CDAte+1+CIZena+1+CIZena+1+CIZena+1+CLitrMantissa+1
         +1,COne));
If DataRec.Res in [4,8] Then DataRec.Res:=1
Else DataRec.Res:=0;

1:
l:=2;{Все плохо}
Ini:=0;
If Not((DolgList^.List^.Count-1)>=0) Then Exit;
R.Assign(17, 9, 65, 16);
New(SumWindow, Init(R, 'Оплата долга по консигнации'));
SumWindow^.Options := SumWindow^.Options or ofCenterX or ofCenterY;
SumWindow^.Palette := dpBlueDialog;
SumWindow^.HelpCtx:=$E002;

R.Assign(19, 2, 34, 3);
Control := New(PInputLine, Init(R, 15));
SumWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));

R.Assign(2, 1, 19, 3);
Control := New(PStaticText, Init(R, 'Какую сумму желаете оплатить:'));
SumWindow^.Insert(Control);


R.Assign(35, 2, 46, 6);
Control := New(PRadioButtons, Init(R,
  NewSItem('~Н~ал',
  NewSItem('~Б~/Н',
  NewSItem('~В~з/Зач',
  NewSItem('по ~Р~КО', Nil))))));

SumWindow^.Insert(Control);


R.Assign(35, 1, 42, 2);
Control := New(PStaticText, Init(R, 'Расчет:'));
SumWindow^.Insert(Control);

R.Assign(11, 4, 18, 5);
Control := New(PStaticText, Init(R, 'Долг:'));
SumWindow^.Insert(Control);


R.Assign(22, 4, 37, 5);
st1:=Copy(s,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1,CIZena);
DelSpace(st1);
Control := New(PColoredText, Init(R, #3+st1, $1A));
Control^.Options := Control^.Options or ofCenterX;
SumWindow^.Insert(Control);

SumWindow^.SelectNext(False);

SumWindow^.SetData(DataRec);

c:=Desktop^.ExecView(SumWindow);

If c<>cmCancel Then
 Begin
  SumWindow^.GetData(Datarec);
  If StrToReal(DataRec.St)>StrToReal(st1) Then
  Begin
  MessageBox(#3^M+#3'Сумма оплаты больше долга!'^M+#3'Повторите ввод!',Nil,mfError+mfCancelButton);
  Dispose(Control,Done);
  Dispose(SumWindow,Done);
  Goto 1;
  End;

  {Очищаем без нальную переменную}
  With Bn Do
  Begin
    Date [0] :=#0;
    NPlat[0] :=#0;
    Summa[0] :=#0;
    Bank [0] :=#0;
  End;

  BnLogik:=False;

  If Datarec.Res=1 Then
  Begin
  New(ls,Init);
  If Not InputBN(ls,ls,false) Then
   Begin
    Dispose(Ls,Done);
    Dispose(Control,Done);
    Dispose(SumWindow,Done);
    Goto 1;
   End
   Else
   Begin
    BnLogik:=True;
    Bn:=Ls^.Dat.Bn;
    Dispose(Ls,Done);
   End;
  End;

  If Datarec.Res=2 then
  BEGIN
    If StrToInt(CurrentPassword)=0 Then
    Bn.Bank:='Взаимозачет'
    else
    begin
      MessageBox(#3^M+#3'Данный тип оплаты запрещен!',Nil,mfConfirmation+mfOkCancel);
      Dispose(Control,Done);
      Dispose(SumWindow,Done);
      Goto 1;
    end;
  END;

  If Datarec.Res=3 Then
  Begin
  New(ls,Init);
  If Not InputBN(ls,ls,true) Then
   Begin
    Dispose(Ls,Done);
    Dispose(Control,Done);
    Dispose(SumWindow,Done);
    Goto 1;
   End
   Else
   Begin
    {BnLogik:=True;}
    Bn:=Ls^.Dat.Bn;
    Dispose(Ls,Done);
   End;
  End;


  Mystr(StrToREal(DataRec.St),CIZena,CMantissa,DataRec.st);
  Delspace(DataRec.st);
  If MessageBox(#3^M+#3'Сумма введена правильно?'^M+#3+DataRec.St,Nil,mfConfirmation+mfOkCancel)<>cmOk Then
  Begin
  Dispose(Control,Done);
  Dispose(SumWindow,Done);
  Goto 1;
  End;
  l := 0; {Все оккей}
 End;
 Dispose(Control,Done);
 Dispose(SumWindow,Done);
 Ini:=StrToReal(DataRec.St);
end;

Destructor TSummaWindow.Done;
Begin
TDialog.Done;
End;

procedure TDolgWindow.OpenDolgWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmDolg, nil) = nil then
  begin
    DInfo('Инициализация возврата долга...');
    L:=True;
    DolgWindow := New(PDolgWindow, Init(L));
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



constructor TDolgWindow.Init(Var l : Boolean);
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
Inherited Init(R, 'Возврат долга после консигнации');
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E002;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    Exit;
   End;


R.Assign(0, 0, 0, 0);
TChekRazdel := New(PBox, Init(R, 1, Nil));
TChekRazdel^.NewList(New(PTextCollection, Init(0,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprth!.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
TChekRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
TChekRazdel^.SetRange(TChekRazdel^.List^.Count);
End;
System.Close(RazdelFile);

R.Assign(0, 0, 0, 0);
FZRazdel := New(PBox, Init(R, 1, Nil));
FZRazdel^.NewList(New(PTextCollection, Init(0,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprfl!.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
FZRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
FZRazdel^.SetRange(FZRazdel^.List^.Count);
End;
System.Close(RazdelFile);



R.Assign(0, 0, 0, 0);
SpisokRazdel := New(PBox, Init(R, 1, Nil));
SpisokRazdel^.NewList(New(PTextCollection, Init(0,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprsp.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
SpisokRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
SpisokRazdel^.SetRange(SpisokRazdel^.List^.Count);
End;
System.Close(RazdelFile);

R.Assign(0, 0, 0, 0);
SFRazdel := New(PBox, Init(R, 1, Nil));
SFRazdel^.NewList(New(PTextCollection, Init(0,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprsf!.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
SFRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
SFRazdel^.SetRange(SFRazdel^.List^.Count);
End;
System.Close(RazdelFile);

R.Assign(0, 0, 0, 0);
SFBRazdel := New(PBox, Init(R, 1, Nil));
SFBRazdel^.NewList(New(PTextCollection, Init(0,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprsb.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
Begin
Read(RazdelFile,RazdelElement);
SFBRazdel^.List^.Insert(NewStr(RazdelElement.Kod));
SFBRazdel^.SetRange(SFBRazdel^.List^.Count);
End;
System.Close(RazdelFile);


R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'Client.db');
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

R.Assign(2, 0, 10, 1);
Insert(New(PLabel, Init(R, 'Кли~е~нт:', ControlClient)));

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
  Insert(New(PLabel, Init(R, '  N     Дата     Срок   Сумма по док. Т  Долг по оплате Скидка по докум Del Т', DolgList)));

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


R.Assign(4, 17, 32, 21);
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
R.Assign(1, 15, 14, 16);
Control := New(PColoredText, Init(R, 'Особ.отметки:', $74));
Insert(Control);

{R.Assign(47, 21, 59, 22);}
R.Assign(14, 15, 17, 16);
ControlComment := New(PColoredText, Init(R, 'Нет', $FE));
Insert(ControlComment);

R.Assign(18, 15, 25, 16);
Control := New(PColoredText, Init(R, #3+'Сквоз.N:', $74));
Insert(Control);

R.Assign(26, 15, 33, 16);
ControlN := New(PColoredText, Init(R, '  -  ', $7E));
Insert(ControlN);


R.Assign(33, 15, 47, 16);
Control := New(PColoredText, Init(R, #3+'Долг по опл.Т:', $74));
Insert(Control);

R.Assign(47, 15, 57, 16);
ControlDolgT := New(PColoredText, Init(R, #3+'0.00', $7E));
Insert(ControlDolgT);

R.Assign(57, 15, 70, 16);
Control := New(PColoredText, Init(R, #3+'Вид док.:', $74));
Insert(Control);

R.Assign(70, 15, 80, 16);
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
Insert(ControlOpl1);

SelectNext(False);
CalcItogo;
L:=True;
end;

procedure TDolgWindow.CalcItogo;
VAr s1,s2,s3 : String[CIZena];
    i : LongInt;
    R1,r2,r3 : Real;
    R : TRect;
Begin
R1:=0;
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
Insert(ControlRealizSkidki);
End;


Procedure TDolgWindow.DrawCurrent;
Var SClientKod,s1,s : AllStr;
    St : TMyString;
    TempS : string;
    R : TRect;
    L : Boolean;
    RealFile: File Of RealizasiaType;
    i : Byte;
    wp,ws : AllStr;
    EEE:PSuperMarketType;
Begin
if (DolgList^.List<>Nil)And(DolgList^.List^.Count>=1) Then
 Begin
  st:=DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count);
  If st <> PrevCurrent Then
    Begin
      PrevCurrent:=St;
      New(GlobalEr,Init);
      {If Doc=1 Then
      Begin}
      PStaticText(ControlClient)^.GetText(PrevS);
      System.Delete(PrevS,1,1);
      s1:=PrevS;
      s1:=Copy(s1,1+CClient+1,CClientKod);
      SClientKod:=s1;
      Assign(RealFile,Path.ToDolg+s1+'.dlg');
      i:=IOResult;
      Reset(RealFile);
      i:=IOResult;
      If i<>0 Then
       Begin
        MessageBox(^M+#3'Ошибка доступа к файлу '+Path.ToDolg+s1+'.dlg!',Nil,mfError+mfCancelButton);
        Exit;
       End;

       s1:=Copy(PrevCurrent,1+1,CDocNumer);  DelSpace(s1);
{      s1:=Copy(PrevCurrent,1+1+CDate+1,CDocNumer);  DelSpace(s1);}
{      s:=Copy(PrevCurrent,1+1+CDocNumer+1,CDate); DelSpace(s);}
       s:=Copy(PrevCurrent,1+1+CDocNumer+1,CDate); DelSpace(s);

      l:=False;
      DelZerro(s1);

      While Not(Eof(RealFile)) And(Not(l))Do
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
      System.Close(RealFile);

      St[0]:=#0;
      For i:=1 To 4 Do
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
      R.Assign(14, 15, 17, 16);
      If GlobalEr^.Dat.Market.DocSelector in [6,8] Then
         ControlComment := New(PColoredText, Init(R, #3+'СФ', $FE))
      Else ControlComment := New(PColoredText, Init(R, #3+'Нет', $FE));
      Insert(ControlComment);

      R.Assign(26, 15, 33, 16);
      If GlobalEr^.Dat.Market.DocSelector in [6,8] Then
      begin
      New(EEE,Init);
      GetMArket(GlobalEr,EEE);
      DelSpace(EEE^.Dat.SfNumer);
      ControlN := New(PColoredText, Init(R, EEE^.Dat.SfNumer, $7E));
      Dispose(EEE,Done);
      end
      else ControlN := New(PColoredText, Init(R, '  -  ', $7E));
      Insert(ControlN);



    MyStr(GlobalEr^.Dat.Dolg,CIZena,CMantissa,ws);
    MyStr(StrToReal(GlobalEr^.Dat.Market.Skidka),CIZena,CMantissa,Wp);

    MyStr(StrToReal(Wp)+GlobalEr^.Dat.Dolg,CIZena,CMantissa,wp);
    DelSpace(wp);

    Dispose(ControlDolgT,Done);
    R.Assign(47, 15, 57, 16);
    ControlDolgT := New(PColoredText, Init(R, #3+wp, $7E));
    Insert(ControlDolgT);

    Dispose(ControlVidDoc,Done);
    R.Assign(70, 15, 80, 16);
    if GlobalEr^.Dat.Realiz then
    Case GlobalEr^.Dat.Market.DocSelector Of
    5:wp:='Реализ.*';
    6:wp:='Реализ.СФ*';
    7:wp:='Реализ.';
    8:wp:='Реализ.СФБ';
    Else;
    End
    else
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
    Redraw;

    End {If St<>PrevCurrent}
 End

Else
 Begin
  Dispose(ControlRashetDoc,Done);
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
    End;



  Redraw;
End;
End;



Procedure TDolgWindow.Refresh(Auto:Boolean);
Var r1 : TRect;
    r,Test : LongInt;
    P : Real;
    ReturnSkidka,Wp : String[CIZena];
    Delta : String[CLitrMantissa];
    vidDoc: String[COne];
    SSum : AllStr;
Begin
ClearFind;
DolgList^.NewList(Nil);
DolgList^.NewList(New({PText}PMyCollection, Init(0,1)));
PStaticText(ControlClient)^.GetText(PrevS);
System.Delete(PrevS,1,1);

If Auto Then
Begin
 StartDate:='01-01-09';
 StopDate:=FDate;
End;

SSum[0]:=#0;


PrevS:=Copy(PrevS,1+CClient+1,CClientKod);

CalcToDayOplata(PrevS,SSum);


Assign (RealFile,Path.ToDolg+PrevS+'.dlg');
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
  If (GlobalEr^.Dat.Market.Active) Then
  Begin
  If (Not(GlobalEr^.DAt.Full)And(Doc=0)) Or
     ((GlobalEr^.DAt.Full)And(Doc=1)) Then
   Begin
If(DateStringToDate(DateMask,GlobalER^.Dat.Market.DateC)<=
   DateStringToDate(DateMask,StopDate)) And
  (DateStringToDate(DateMask,GlobalER^.Dat.Market.DateC)>=
   DateStringToDate(DateMask,StartDate)) Then
Begin

    RFormatZerro(GlobalEr^.Dat.Market.Document,CDocNumer);
    Format (GlobalEr^.Dat.Market.Document,CDocNumer);
    Format (GlobalEr^.Dat.Market.DateC,CZena);
{   Format (E^.Dat.Market.SummaZ,CIZena);}
    p:=StrToReal(GlobalEr^.Dat.Market.SummaZ);
    MyStr(p,CIZena,CMantissa,GlobalEr^.Dat.Market.SummaZ);

If (Not(GlobalEr^.DAt.Full)And(Doc=0)) Then
    Begin
    If GlobalEr^.DAt.Market.Srok<DateStringToDate(DateMask,FDate) Then
    Str(DateStringToDate(DateMask,FDate)-GlobalEr^.DAt.Market.Srok:CLitrMantissa,Delta)
    Else Delta:='   ';
    End
Else
    Begin
     For r:=1 To 4 Do
      If GlobalEr^.DAt.Doc[r].Employ Then Break;{For}
      If DateStringToDAte(DateMask,GlobalEr^.DAt.Doc[r].DocDate)>
            GlobalEr^.DAt.Market.Srok Then
      Str(DateStringToDate(DateMask,GlobalEr^.DAt.Doc[r].DocDate)-GlobalEr^.DAt.Market.Srok:CLitrMantissa,Delta)
      Else Delta:='   ';
    End;

    viddoc:=inttostr(GlobalEr^.DAt.Market.DocSelector,COne);

    PrevS:=DateToDateString(DateMask,GlobalEr^.Dat.MArket.Srok);
    Format (PrevS,CZena);
    MyStr(GlobalEr^.Dat.Dolg,CIZena,CMantissa,ws);
    MyStr(StrToReal(GlobalEr^.Dat.Market.Skidka),CIZena,CMantissa,Wp);


(*  14.09.98
    Убрана для того чтобы имет на глазах реальную сумму по документу*)

    MyStr(StrToReal(Wp)
       +StrToReal(GlobalEr^.Dat.Market.SummaZ)

       +StrToReal(GetReturnSkidka(GlobalEr^.Dat.Market.Document,
                                     GlobalEr^.Dat.MArket.DateC,
                                  GlobalEr^.Dat.Market.ClientKod,0))
                                                    ,CIZena,CMantissa,
    GlobalEr^.Dat.Market.SummaZ);

    if GlobalEr^.Dat.Realiz then
    DolgList^.List^.Insert(NewStr('*'+GlobalEr^.Dat.MArket.Document+'│'+GlobalEr^.Dat.MArket.DateC+'│'+PrevS+'│'+
    GlobalEr^.DAt.Market.SummaZ+'│'+ws+'│'+wp+'│'+Delta+'│'+Viddoc+'│'+GlobalEr^.Dat.Market.AgentKod))
    else
    DolgList^.List^.Insert(NewStr('│'+GlobalEr^.Dat.MArket.Document+'│'+GlobalEr^.Dat.MArket.DateC+'│'+PrevS+'│'+
    GlobalEr^.DAt.Market.SummaZ+'│'+ws+'│'+wp+'│'+Delta+'│'+Viddoc+'│'+GlobalEr^.Dat.Market.AgentKod));

    DolgList^.SetRange(DolgList^.List^.Count);
   End;
End;
  End;{GlobalEr^.Dat.Market.Active}
 End;
Dispose(GlobalEr,Done);
System.Close(RealFile);
NoInfo;
End;
DolgList^.FocusItem(0);
DolgList^.HelpCtx:=$E200;

Dispose(ControlStartDate,Done);
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

CalcItogo;
PrevCurrent[0]:=#0;
End;


Procedure PrintOrderPl(PrhNum,NaklNumer,SDoc,SDAte,SClientKod,Summa:AllStr;All:Boolean;L:Word);
Var Txt :Text;
    As : DocumentEdit;
    Np,Nds : Real;
    Nalog : AllStr;
    E : PSuperMarketType;
Begin
    As.D:=SDate;
    As.EditPosition:=SDoc;
    DelZerro(As.EditPosition);
    Nalog[0]:=#0;
    If All And (L in [5,6,7,8]) Then
     Begin
	 CalcNDS(As,NDS,NP);

      {New(E,Init);
      If GetMarket1(As,E) Then
         Begin}
{
         End;
      Dispose(E,Done);}
     End
    Else
     Begin
      Nds:=0;
      Nalog[0]:=#0;
     End;

    If L in [5,6] Then{Если приходник Дебит с *}
    Begin
     If Test3000(SClientKod,Summa) Then
      Begin
       Assign(Txt,Path.ToTemp+'order.$$$');
       Rewrite(txt);
       PrintOrderPlategC(PrhNum,NaklNumer,SDoc,SClientKod,Summa,All,L,Txt,NDS,NP{StrToreal(NAlog)});
       Close(txt);
       Report(Path.ToTemp+'order.$$$','',NPrint.CopyOrder,False,False,false);
      End
      Else
   MessageBox(#3'Сумма превышает '+RealToStr(PrihodMax,CZena,CMantissa)+' рублей!'^M
   +#3'Разбивайте приходный кассовый ордер вручную !!!',Nil,MfWarning+mfCancelButton);
    End
    Else
     Begin
      Assign(Txt,Path.ToTemp+'order.$$$');
      Rewrite(txt);
      PrintOrderPlategC(PrhNum,NaklNumer,SDoc,SClientKod,Summa,All,L,Txt,NDS,NP{StrToreal(NAlog)});
      Close(txt);
      Report(Path.ToTemp+'order.$$$','',NPrint.CopyOrder,False,False,false);
     End;
End;


Function CalcNewDolg(r: Real;S:TEnjoyStr;BnLogik:Boolean;Bn:BezNal):Boolean;
VAr s1:AllStr;
    Pos1,i : LongInt;
    l:Boolean;
    {Sm : PSuperMarketType;
    Sf : File of SuperMarketType;}
    SClientKod : StrIng[CClientKod];
    OplataFile : File Of OplataRealizasiaType;
    Summa : String[CIZena];
    Oplata : OplataRealizasiaType;
    ClientOplataFile : File Of ClientOplataRealizasiaType;
    ClientOplata : ClientOplataRealizasiaType;
    PrhNum: ArtikulStr;
    E : PSuperMArketType;
    AA : DocumentEdit;

Begin
ClearFind;
CalcNewDolg:=False;
PStaticText(ControlClient)^.GetText(PrevS);
System.Delete(PrevS,1,1);
s1:=PrevS;
s1:=Copy(s1,1+CClient+1,CClientKod);
SClientKod:=s1;
Assign(RealFile,Path.ToDolg+s1+'.dlg');
i:=IOResult;
Reset(RealFile);
i:=IOResult;
If i<>0 Then
 Begin
  MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path.ToDolg+s1+'.dlg!'^M+
  #3'Долг с клиента не списан! ',Nil,mfError+mfCancelButton);
  Exit;
 End;
DInfo('Списываю долг с клиента...');
{s1:=Copy(s,1+1+CDate+1,CDocNumer);}
s1:=Copy(s,1+1,CDocNumer);
DelSpace(s1);
s:=Copy(s,1+1+CDocNumer+1,CDate);
{s:=Copy(s,1+1,CDate);}
DelSpace(s);
DelZerro(s1);
AA.EditPosition:=s1;
AA.D:=s;

New(E,Init);
If Not GetMarket1(AA,E) Then
 Begin
  Dispose(E,Done);
  Close(RealFile);
  NoInfo;
  Exit;
 end;

New(GlobalEr,Init);
l:=False;
While Not(Eof(RealFile)) And(Not(l))Do
 Begin
  Read(RealFile,GlobalEr^.Dat);
  Delspace(GlobalEr^.DAt.MArket.Document);
  DelZerro(GlobalEr^.Dat.Market.Document);
  If (GlobalEr^.DAt.MArket.Document=s1) And
     (GlobalEr^.DAt.MArket.DateC=s) And
        (GlobalEr^.DAt.MArket.Active) Then l:=True;
 End;
If Not(l) Then
 Begin
  Dispose(E,Done);
  Dispose(GlobalEr,Done);
  Close(RealFile);
  NoInfo;
  MessageBox(#3^M+#3'Документ N '+s1+''^M+
  #3'в базе не найден.'^m+#3'Долг с клиента не списан!',Nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  BEgin
   If GlobalEr^.DAt.Market.Srok<DateStringToDate(DateMask,FDate) Then
    Begin
   (*  s1[0]:=#0;
     i:= DateStringToDate(DateMask,FDate)-GlobalEr^.DAt.Market.Srok;
     Str(i:3,s1);
     DelSpace(s1);
     MyStr((I*0.01*GlobalEr^.DAt.Dolg),CIZena,CMantissa,s);
     DelSpace(s);
     MessageBox(#3'Клиент задержал оплату!'^M+
     #3'Необходимо начислить пени за '+s1+' дня(ей) в сумме '+S,nil,mfWarning+mfCancelButton);*)
    End
    Else s1[0]:=#0;

{  Assign(sf,Print.PathToMarket+GlobalEr^.Dat.Market.DateC+'.mrk');
   i:=IOResult;
   Reset(Sf);
   i:=IOResult;
   If i<>0 Then
    Begin
     NoInfo;
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+Print.PathToMArket+GlobalEr^.Dat.Market.DateC+'.mrk!'^M+
     #3'Долг с клиента не списан! ',Nil,mfError+mfCancelButton);
     Dispose(GlobalEr,Done);
     Close(RealFile);
     Exit;
    End;}
{    New(Sm,Init);
l:=False;
DelSpace(GlobalEr^.DAt.Market.Document);
While Not(Eof(Sf)) And(Not(l))Do
 Begin
  Read(sf,Sm^.Dat);
  Delspace(Sm^.DAt.Document);
  If (Sm^.Dat.Document=E^.Dat.Market.Document) And (E^.Dat.Market.DateC=Sm^.DAt.DAteC)And
  (Sm^.Dat.Active)Then l:=True;
 End;

If Not(l) Then
 Begin
  NoInfo;
  MessageBox(#3^M+#3'Документ N '+E^.DAt.Market.Document+''^M+
  #3'в базе продаж не найден.'^m+#3'Долг с клиента не списан!',Nil,mfError+mfCancelButton);
  Dispose(sm,Done);
  Dispose(E,Done);
  Close(RealFile);
  Close(Sf);
  Exit;
 End;}

   Assign(OplataFile,Path.ToOplata+FDate+'.opl');
   i:=IOResult;
   Reset(OplataFile);
   i:=IOResult;
   If i<>0 Then
    Begin
    (* If MessageBox(#3'Файл оплаты консигнации за '+FDate+' не найден!'^M+
     #3'Создавать?'+
        +' Код:'+IntToStr(i,3),Nil,mfError+mfOkCancel)=cmOk Then*)
      Begin
{       i:=IOResult;
       Reset(OplataFile);
       i:=Ioresult;
       If I<>0 Then Rewrite(OplataFile);}
       If Not(CreatToDayF(DocOplata,FDate)) Then
           Begin
         NoInfo;
         Dispose(E,Done);
         Dispose(GlobalEr,Done);
         Close(RealFile);
            Exit;
        End;

       Reset(OplataFile);

       i:=IOResult;
      End;
    (*  Else
        Begin
         NoInfo;
         Dispose(E,Done);
         Dispose(GlobalEr,Done);
{         Dispose(Sm,Done);}
         Close(RealFile);
{         Close(Sf);}
         Exit;
        End;          *)
    End;

   Assign(ClientOplataFile,Path.ToClientOplata+SClientKod+'.cpl');
   i:=IOResult;
   Reset(ClientOplataFile);
   i:=IOResult;
   If i<>0 Then
    Begin
     (*If MessageBox(#3'Файл оплаты консигнации у клиента ('+SClientKod+') не найден!'^M+
     #3'Создавать? '+
        +' Код:'+IntToStr(i,3),Nil,mfError+mfOkCancel)=cmOk Then*)
      Begin
       i:=IOResult;
       Rewrite(ClientOplataFile);
       i:=IOResult;
      End;
      (*Else
        Begin
         NoInfo;
         Dispose(E,Done);
         Dispose(GlobalEr,Done);
{         Dispose(Sm,Done);}
         Close(RealFile);
         Close(OplataFile);
{         Close(Sf);}
         Exit;
        End;*)
    End;

    If ((GlobalEr^.Dat.Dolg-r)-StrToReal(GlobalEr^.Dat.Market.SummaZ))>0.01 Then
     Begin
      NoInfo;
      MessageBox(#3+'Сумма долга клиента превышает сумму долга по накладной консигнации!'^M+
      +#3'Будьте внимательней!',Nil,mfError+mfCancelButton);
      Dispose(E,Done);
      Dispose(GlobalEr,Done);
{     Dispose(Sm,Done);}
{     Close(Sf);}
      Close(RealFile);
      Close(OplataFile);
      Close(ClientOplataFile);
      Exit;
     End;

    If BnLogik Then Oplata.Rashet:=True
    Else Oplata.Rashet:=False;
    Oplata.Bn:=Bn;
    Oplata.PrhNumer:='    ';
    PrhNum:='    ';

    If Not(BnLogik) And (GlobalEr^.Dat.Market.DocSelector in [2,3,6]) Then
    Begin
     GetReestrNumOpl(0,PrhNum,GlobalEr^.Dat.Market);
     Oplata.PrhNumer:=PrhNum;
    End;

    Oplata.Vozwrat:=False;
    Oplata.DocNumerReturn[0]:=#0;
    Oplata.DocDAteReturn[0]:=#0;
    Oplata.SkladKod:=Rek.Kod;
    Oplata.ClientKod:=SClientKod;
    Oplata.DateC:=FDate;
    Oplata.Document:=GlobalEr^.Dat.Market.Document;
    Oplata.DateDoc:=GlobalEr^.Dat.Market.DateC;
    Oplata.TimeC:=Times; {время создания}
    MyStr(R,CIZena,CMantissa,Oplata.SummaZ);  {сумма оплаты}
    MyStr(0.00,CIZena,CMantissa,Oplata.Skidka);

    Oplata.Caption :=CurrentPassword;{признак оператора}
    Oplata.Realiz:=GlobalEr^.Dat.Realiz;

    DInfoNetMsg('Сохраняю оплату по докумену N '+Oplata.Document+' от '+Oplata.DateDoc+'...');

    Repeat
     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(OplataFile);
      Seek(OplataFile,Pos1);
     Until (Lock(OplataFile,FilePos(OplataFile)*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)*5));

     Pos1:=FileSize(OplataFile);

     If FilePos(OplataFile)<>Pos1{FileSize(OplataFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        Pause(1);
        UnLock(OplataFile,(FilePos(OplataFile))*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)*5);
       Until (DosError=0);
      End;

    Until (FilePos(OplataFile)=Pos1{FileSize(OplataFile)});

     Write(OplataFile,Oplata);
     Seek(OplataFile,FilePos(OplataFile)-1);
     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле оплаты');

     Repeat {деблокируем участок записи}
     UnLock(OplataFile,(FilePos(OplataFile))*SizeOf(OplataRealizasiaType),
         SizeOf(OplataRealizasiaType)*5);
     Until (DosError=0);
     Close(OplataFile);
     NoInfoMsg;
{
     Repeat
      Seek(OplataFile,FileSize(OplataFile));
      Pause(1);
     Until (Lock(OplataFile,FilePos(OplataFile)*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)*5));
     Write(OplataFile,Oplata);
     Seek(OplataFile,FilePos(OplataFile)-1);
     Repeat
      UnLock(OplataFile,FilePos(OplataFile)*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)*5);
     Until (DosError=0);
}


    If BnLogik Then ClientOplata.Rashet:=True
    Else ClientOplata.Rashet:=False;

    ClientOplata.PrhNumer:='    ';

    If Not(BnLogik) Then
    Begin
     ClientOplata.PrhNumer:=PrhNum;
    End;

    ClientOplata.Bn:=Bn;
    ClientOplata.DocNumerReturn[0]:=#0;{документ возврата}
    ClientOplata.DocDateReturn [0]:=#0;    {документ возврата}
    ClientOplata.Vozwrat:=False;
    ClientOplata.SkladKod:=Rek.Kod;
    ClientOplata.ClientKod:=SClientKod;
    ClientOplata.PrhNumer:=PrhNum;
    ClientOplata.Realiz:=GlobalEr^.Dat.Realiz;
    ClientOplata.DateC:=FDate;
    ClientOplata.Document:=GlobalEr^.Dat.Market.Document;
    ClientOplata.DateDoc:=GlobalEr^.Dat.Market.DateC;
    ClientOplata.TimeC:=Times; {время создания}
    MyStr(R,CIZena,CMantissa,ClientOplata.SummaZ);  {сумма оплаты}
    MyStr(0.00,CIZena,CMantissa,ClientOplata.Skidka);

    ClientOplata.Caption :=CurrentPassword;{признак оператора}
    ClientOplata.Delta :=S1;{срок опоздания}
    If GlobalEr^.DAt.Market.Srok<DateStringToDate(DateMask,FDate) Then
    ClientOplata.Srok :=DateToDAteString(DAteMask,DateStringToDate(DateMask,FDate)-StrToInt(s1)){срок оплаты}
    Else
    ClientOplata.Srok :=DateToDAteString(DAteMask,GlobalEr^.DAt.Market.Srok){срок оплаты};

    Seek(ClientOplataFile,FileSize(ClientOplataFile));
    Write(ClientOplataFile,ClientOplata);
    Close(ClientOplataFile);



   Seek(RealFile,FilePos(RealFile)-1);
   GlobalEr^.DAt.Dolg:=GlobalEr^.Dat.Dolg-r;
   If GlobalEr^.Dat.Dolg<0.009 Then GlobalEr^.Dat.Dolg:=0;
   If (GlobalEr^.DAt.Dolg=0) Then CalcNewDolg:=True;
   If GlobalEr^.Dat.Dolg=StrToReal(GlobalEr^.Dat.Market.SummaZ) Then
   GlobalEr^.Dat.Payment:=False
   Else GlobalEr^.Dat.Payment:=True;

   If GlobalEr^.Dat.Dolg<0.009 Then L:=True
   Else L:=False;
    {печатать документальное подтверждение оплаты}
    MyStr(R,CIZena,CMantissa,Summa);
    If  Not(BnLogik) Then
    If MessageBox(^M+#3+'Печатать приходный кассовый ордер?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
    PrintOrderPl(PrhNum,E^.Dat.NaklNumer,E^.Dat.Document,
    E^.Dat.DateC,GlobalEr^.Dat.Market.ClientKod,Summa,L,
    GlobalEr^.Dat.Market.DocSelector);


   Write(RealFile,GlobalEr^.Dat);

{   Seek(Sf,FilePos(Sf)-1);
{  If E^.Dat.Dolg=StrToReal(E^.Dat.Market.SummaZ) Then
   Sm^.Dat.Payment:=False
   Else Sm^.Dat.Payment:=True;
   Write(Sf,Sm^.Dat);
   Dispose(Sm,Done);

   Close(Sf);}


MyStr(R,CIZena,CMantissa,S1);
DelSpace(s1);
{AddProtocol('Оплата по документу консигнации N '+GlobalEr^.Dat.Market.Document+' от '+
GlobalEr^.Dat.MArket.DateC+' на сумму '+S1,'','');}

  End;
Dispose(GlobalEr,Done);
Dispose(E,Done);
Close(RealFile);
NoInfo;
End;

Procedure TDolgWindow.Order;
var SDoc:String[CDocNumer];
    SDAte : TDateString;
    SClient : String[CClient+7];
    S : TMyString;
Begin
   PStaticText(ControlClient)^.GetText(S);
   SClient:=Copy(s,2,CClient);
   SClient:=SClient+'('+Copy(s,1+CClient+1+1,CCLientKod)+')';
   s:=DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count-1);
   SDoc:=Copy(s,1+1,CDocNumer);
   SDate:=Copy(s,1+1+CDocNumer+1,CDate);
   DelSpace(SDate);
   PrintOrder3('по документу N ',SClient,SDoc,sDate,'1','0');
End;

{проверена}
Procedure TDolgWindow.OpenDOc;
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
ClearFind;
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

NoInfo;
Refresh(False);
End;


procedure TDolgWindow.FullPreview;
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
If (DolgList^.List<>Nil)And(DolgList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count),1+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  Ass.D:=Copy(DolgList^.GetText(DolgList^.Focused,DolgList^.List^.Count),1+1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  ViewMrk^.FullScreenMrk(Ass);
End;
End;


procedure TDolgWindow.FormReport(Const P : PBox;SCKod:ArtikulStr);
Const Space='  ';
Var f : text;
    ws,s,s1,s2 : string;
    c,w : Word;
    Find : Boolean;
Begin
If (P^.List<>Nil) And (P^.List^.Count>=1) Then
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
 Writeln(f,Space+___);
 Writeln(f,Space+'Док  Дата док Срок опл Долг по докум.Т  Долг по оплате Скидка по докум Del   Вид');

                 {1234│12345678│12345678│123456789012345│123456789012345│123456789012345│123│Дебит СФ Б'}
 Writeln(f,Space+___);


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

   if s[1]='*' then
   Case StrToInt(s1) Of
   5:s1:='Реализ.*';
   6:s1:='Реализ.СФ*';
   7:s1:='Реализ.';
   8:s1:='Реализ.СФБ';
   Else s1:='???';
   End
   else
   Case StrToInt(s1) Of
   5:s1:='Дебит*';
   6:s1:='Дебит СФ*';
   7:s1:='Дебит';
   8:s1:='Дебит СФБ';
   Else s1:='???';
   End;

(*
   Seek(RealFile,0);
   Find:=False;
   While Not(Eof(RealFile)) And(Not(Find))Do
    Begin
     Read(RealFile,GlobalEr^.Dat);
     Delspace(GlobalEr^.DAt.MArket.Document);
     DelZerro(GlobalEr^.Dat.Market.Document);
     If (GlobalEr^.DAt.MArket.Document=s1) And
           (GlobalEr^.DAt.MArket.DateC=s2)And
           (GlobalEr^.DAt.MArket.Active)  Then Find:=True;
    End;
    If Not(Find) Then
     Begin
      s1:='???';
     End
    Else
    Begin
     If GlobalEr^.Dat.Market.DocSelector in [6,8]{GlobalEr^.Dat.Sf} Then
      Begin
       s1:='С/Ф';
      End
      Else
      s1:='';
    End;
*)
   s:=s+' '+s1;

   System.Delete(s,1,1);

   Writeln(f,Space+s);
  End;
(*  System.Close(RealFile);
  Dispose(GlobalEr,Done);*)

 Writeln(f,Space+___);


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
 End;
End;





procedure TDolgWindow.HandleEvent(var Event: TEvent);
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
  evKeyDown:
  Begin
        CAse Event.KeyCode Of
               kbDel      :Begin
ClearFind;
               If (DolgList^.State and sfFocused<>0) Then
               Begin
                            If StrToInt(CurrentPassword)=0 Then
					    Begin
                If MessageBox(^M+#3'Удалить эту запись?',Nil,
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
 End;

  evCommand :

        Case Event.Command Of
                   cmOplata : if (User[67] or (CurrentPassword='00')) then
			    Begin
                   if Password(1) Then
                 Begin
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
                  End;
                                    ClearEvent(Event);
                       End;{kbEnter}

         cmAbout: Begin
               ClearEvent(Event);
               AboutCHM('27');
         End;

         cmCancel : Begin
                 {Dispose(ControlSelectorDoc,Done);
                 Dispose(ControlClient,Done);
                 Dispose(DolgList,Done);   }
                 PStaticText(ControlClient)^.GetText(S);
                 System.Delete(S,1,1);
                 Repeat
                 Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,0));

                 Dispose(TChekRazdel,Done);
                 Dispose(FZRazdel,Done);
                 Dispose(SpisokRazdel,Done);
                 Dispose(SfRazdel,Done);
                 Dispose(SFBRazdel,Done);
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

 cmChangeDiapason :
        Begin
          If (Period(StartDate,StopDate)) Then Refresh(False);
          ClearEvent(Event);
        End;


 cmReestrReport:
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
                End;
              End
            End;


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
     Cl^.ShowClientList(s,0,0,True,True,True,-1,-1,-1,-1,Test);

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
{  Else
         EnableCommands([cmFullview]);}


end;


procedure TInfoDynamicDebit.OpenDebitWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmInfoDebit, nil) = nil then
  begin
    DInfo('Инициализация хронологии оплаты...');
    L:=True;
    InfoDynamicWindow := New(PInfoDynamicDebit, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(InfoDynamicWindow);
    NoInfo;
    End
    Else
     Begin
      Status:=DocNormal;
      Dispose(InfoDynamicWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(InfoDynamicWindow) <> Desktop^.TopView then InfoDynamicWindow^.Select;
end;

procedure TInfoDynamicDebit.FullPreview;
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
If (DynamicList^.List<>Nil)And(DynamicList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(DynamicList^.GetText(DynamicList^.Focused,DynamicList^.List^.Count),1+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(DynamicList^.GetText(DynamicList^.Focused,DynamicList^.List^.Count),1+1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  ViewMrk^.FullScreenMrk(Ass);
End;

End;


constructor TInfoDynamicDebit.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : LongInt;
  p : Real;
  wp : String[cIzena];
begin
ClearFind;
L:=False;
R.Assign(0, 0, 80, 23);
inherited Init(R,'Хронология оплаты клиентом долгов консигнации');
Options := Options or ofCenterX or ofCenterY;

R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'Client.db');
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

End

Else
 Begin
  L:=False;
  Exit;
 End;

PrevS:=Client^.GEtText(0,Client^.List^.COunt);
Dispose(Client,Done);

R.Assign(52, 1, 79, 2);
ControlClient := New(PColoredText, Init(R, #3+PrevS, $1F));
ControlClient^.Options := ControlClient^.Options or ofSelectable;
Insert(ControlClient);

 R.Assign(44, 1, 52, 2);
Insert(New(PLabel, Init(R, 'Кл~и~ент:', ControlClient)));

R.Assign(79, 3, 80, 19);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 3, 79, 19);
DynamicList := New(PBox, Init(R, 1, PScrollbar(Control)));
DynamicList^.NewList(New({PText}PMyCollection, Init(0,1)));
PrevS:=Copy(PrevS,1+CClient+1,CClientKod);

DynamicList^.FocusItem(0);
DynamicList^.HelpCtx:=$E316;

Insert(DynamicList);

  R.Assign(1, 2, 79, 3);
{Insert(New(PLabel, Init(R, ' Дата Док   N   Срок Оп Дата Оп. Время Оп.   Сумма оплаты   Скидка возвр. Del', DynamicList)));}
 Insert(New(PLabel, Init(R, '  N   Дата Док Срок Оп. Дата Оп. Время Оп.   Сумма оплаты   Скидка возвр. Del', DynamicList)));

R.Assign(18, 20, 24, 21);
Control := New(PColoredText, Init(R, 'N п/п:', $74));
Insert(Control);

R.Assign(15, 19, 24, 20);
Control := New(PColoredText, Init(R, 'Дата п/п:', $74));
Insert(Control);

R.Assign(24, 20, 34, 21);
ControlPP := New(PColoredText, Init(R, #3'', $7E));
Insert(ControlPP);

R.Assign(24, 19, 32, 20);
ControlDatePP := New(PColoredText, Init(R, #3'', $7E));
Insert(ControlDatePP);

R.Assign(35, 19, 45, 20);
Control := New(PColoredText, Init(R, 'Сумма п/п:', $74));
Insert(Control);

R.Assign(45, 19, 60, 20);
ControlSummaPP := New(PColoredText, Init(R, #3'', $7E));
Insert(ControlSummaPP);

R.Assign(40, 20, 45, 21);
Control := New(PColoredText, Init(R, 'Банк:', $74));
Insert(Control);

R.Assign(45, 20, 78, 21);
ControlBank := New(PColoredText, Init(R, '', $7E));
Insert(ControlBank);

R.Assign(3, 19, 10, 20);
Control := New(PColoredText, Init(R, 'Расчет:', $71));
Insert(Control);

R.Assign(10, 19, 13, 20);
ControlRashet := New(PColoredText, Init(R, #3'', $7E));
Insert(ControlRashet);

R.Assign(2, 21, 13, 22);
Control := New(PColoredText, Init(R, 'Примечание:', $71));
Insert(Control);

R.Assign(13, 21, 53, 22);
ControlPrim := New(PColoredText, Init(R, #3'', $7E));
Insert(ControlPrim);

R.Assign(55, 21, 64, 22);
Control := New(PColoredText, Init(R, 'Оператор:', $74));
Insert(Control);

R.Assign(64, 21, 76, 22);
ControlPassword := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlPassword);

PrevCurrent[0]:=#0;

SelectNext(False);
L:=True;
end;

(*
Procedure TInfoDynamicDebit.FormReport(Const P:PBox);
Const Space='  ';
Var f : text;
    r1 : Real;
    Summa,s : TMystring;
    c,k : Word;
Begin
PStaticText(ControlClient)^.GetText(S);
System.Delete(S,Pos(#3,S),1);
S:=Copy(s,1+CClient+1,CClientKod);
If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path.ToTemp+'listdd.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'Не могу создать файл '+Path.ToTemp+'listdd.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Writeln(f,Space+' СПРАВКА ПО ОПЛАТЕ ДОКУМЕНТОВ КОНСИГНАЦИИ КЛИЕНТОМ '+GetClientField(FClient,S,0)+' ('+FDate+' '+Times+')');
 Writeln(f,Space+'------------------------------------------------------------------------------------------');
{ Writeln(f,Space+' Дата док  N   Срок Оп  Дата Оп  Время оп    Сумма оплаты   Скидка возвр. Del    Оператор');}
 Writeln(f,Space+' N    Дата док Срок Оп  Дата Оп  Время оп    Сумма оплаты   Скидка возвр. Del    Оператор');
                  {1234567845678│12345678│12345678│12345678│123456789012345│123456789012345│123│123456789012 }
 Writeln(f,Space+'------------------------------------------------------------------------------------------');
 R1:=0;
 For c:=0 To P^.List^.Count-1 Do
  Begin
   s := P^.GetText(c,P^.List^.Count);
   While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert(' ',s,k);
    End;
   Summa:=Copy(s,2+CDocNumer+1+CDate+1+CDate+1+CDate+1+CDate+1,CIZena);

   Writeln(f,Space+s);
   R1:=R1+StrToReal(Summa);
  End;
 Writeln(f,Space+'------------------------------------------------------------------------------------------');
 s:='Всего оплачен товар на сумму:'+RecognizReal(R1,CIZena,CMantissa);
 Writeln(f,Space+s);
 Writeln(f,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'==========================================================================================');
 System.Close(f);
 ViewAsText(Path.ToTemp+'listdd.txt',True);
 Report(Path.ToTemp+'listdd.txt','',1,False,False);
 End;
End;
*)



Procedure TInfoDynamicDebit.FormReport(Const P:PBox);
Const Space=' ';
Var f : text;
    r1 : Real;
    Summa,s : TMystring;
    c,k : Word;
    DlgFile : File Of RealizasiaType;
    DlgVar  : PRealizasiaType;
    CplFile : File Of ClientOplataRealizasiaType;
    CplVAr  : ClientOplataRealizasiaType;
    Start,Stop : LongInt;
    doc,date,timeopl,dateopl,srok : tdatestring;

Begin
PStaticText(ControlClient)^.GetText(S);
System.Delete(S,Pos(#3,S),1);
S:=Copy(s,1+CClient+1,CClientKod);
StartDate:='01-04-98';
StopDate:=FDate;

If Not(Period(StartDate,StopDate)) Then Exit;
Assign(DlgFile,Path.ToDolg+s+'.dlg');
c:=IOResult;;
Reset(dlgFile);
c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'Не могу открыть файл '+Path.ToDolg+s+'.dlg!',Nil,mfError+mfCancelButton);
   Exit;
  End;
Start:=DAteStringToDate(DateMask,StartDAte);
Stop :=DAteStringToDate(DateMask,StopDAte);

 Assign (f,Path.ToTemp+'listdd.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'Не могу создать файл '+Path.ToTemp+'listdd.txt',Nil,mfError+mfCancelButton);
   System.Close(DlgFile);
   Exit;
  End;

 Writeln(f,Space+' СПРАВКА ПО ОПЛАТЕ ДОКУМЕНТОВ КОНСИГНАЦИИ КЛИЕНТОМ '+GetClientField(FClient,S,0)+' ('+FDate+' '+Times+')');
 Writeln(f,Space+' за период с '+startdate+' по '+stopdate);
 Writeln(f,Space+'------------------------------------------------------------------------------------------');
 Writeln(f,Space+' N    Дата док Срок Оп  Дата Оп  Время оп    Сумма оплаты   Скидка возвр. Del    Оператор');
 Writeln(f,Space+'------------------------------------------------------------------------------------------');

New(DlgVar,Init);
While Not(Eof(DlgFile)) Do
 Begin
  Read(DlgFile,DlgVar^.Dat);
  If (DlgVar^.DAt.MArket.Active) Then
  Begin
  {определяем попала ли дата в диапазон}
  If (DAteStringToDate(DateMask,DlgVar^.Dat.Market.DateC)<=Stop) And
     (DAteStringToDate(DateMask,DlgVar^.Dat.Market.DateC)>=Start)
      Then
     Begin
      {вставляем заголовок документа}
      delspace(DlgVar^.Dat.Market.Document);
      RFormatZerro(DlgVar^.Dat.Market.Document,CDocNumer);
      Format(DlgVar^.Dat.Market.Document,CDocNumer);
      MyStr(StrToReal(DlgVar^.Dat.Market.SummaZ),CIZena,CMantissa,DlgVar^.Dat.Market.SummaZ);
      DelSpace(DlgVar^.Dat.Market.SummaZ);
      MyStr(StrToReal(DlgVar^.Dat.Market.Skidka),CIZena,CMantissa,DlgVar^.Dat.Market.Skidka);
      DelSpace(DlgVar^.Dat.Market.Skidka);
      Write(f,Space+'Накладная '+DlgVar^.Dat.Market.Document+' от '+DlgVar^.Dat.Market.Datec+' Срок оплаты:'+
         DateToDateString(DateMask,DlgVar^.Dat.Market.Srok)+
      ' Сумма:'+DlgVar^.Dat.Market.SummaZ+' Скидка:'+DlgVar^.Dat.Market.Skidka);
      If {DlgVar^.Dat.Sf}DlgVar^.Dat.Market.DocSelector in [6,8] Then Write(f,' Выд.С/Ф');
      If (DlgVar^.Dat.Full) then Writeln(f,' Оплачен')
      Else Writeln(f,' Не оплачен');
      {расписываем оплаты по документу}
      R1:=0;
      If (P^.List<>Nil) And (P^.List^.Count>=1) Then
        Begin
         For c:=0 To P^.List^.Count-1 Do
           Begin
            s := P^.GetText(c,P^.List^.Count);
           {если совпадают номер, дата документа, срок оплаты тогда включить в отчет}
            doc:=Copy(s,1+1,CDocNumer);
            Date:=Copy(s,1+1+CDocNumer+1,CDate);
            srok:=Copy(s,1+1+CDocNumer+1+CDate+1,CDate);
            TimeOpl:=Copy(s,1+1+CDocNumer+1+CDate+1+CDate+1+CDate+1,CDate);
            DateOpl:=Copy(s,1+1+CDocNumer+1+CDate+1+CDate+1,CDate);
            If (StrToInt(doc)=StrToInt(DlgVar^.Dat.Market.Document)) And
               (Date=DlgVar^.Dat.Market.Datec) And
               (DateStringToDate(DateMask,Srok)=DlgVar^.Dat.Market.Srok) Then
               Begin

                While Pos('│',s)>0 Do
                  Begin
                    k:=Pos('│',s);
                    System.Delete(s,k,1);
                    System.Insert(' ',s,k);
                  End;
                Summa:=Copy(s,2+CDocNumer+1+CDate+1+CDate+1+CDate+1+CDate+1,CIZena);
                Writeln(f,Space+s);
                If TestReturn(Doc,Date,TimeOpl,DateOpl,s,PrevS) Then
                Writeln(f,Space+' '+s);
                R1:=R1+StrToReal(Summa);
               End;
           End;
        End;
      s:='Всего оплачен товар по накладной на сумму:'+RecognizReal(R1,CIZena,CMantissa);
      Writeln(f,Space+s);
      Writeln(f,Space+'------------------------------------------------------------------------------------------');
      Writeln(f);
     End;
   End;
 End;
Dispose(DlgVar,Done);
System.Close(DlgFIle);

{
Assign(DlgFile,Path.ToClientOplata+s+'.cpl');
c:=IOResult;;
Reset(dlgFile);
c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'Не могу открыть файл '+Path.ToDolg+s+'.clp!',Nil,mfError+mfCancelButton);
   Exit;
  End;
}

 Writeln(f,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'==================================================');
 System.Close(f);
 ViewAsText(Path.ToTemp+'listdd.txt',True);
 Report(Path.ToTemp+'listdd.txt','',1,False,False,false);
End;


Procedure TInfoDynamicDebit.FormReport1;
(*Const Space='';
Var f : text;
    r1 : Real;
    R : TRect;
    NoScreenList : PBox;
    s : TMystring;
    c,k : Word;
    SS : AllStr;
    Es : PStatClientType;
    Esf : File  of StatClientType;
    EsfOpl : File  of ClientOplataRealizasiaType;
    EsOPl :ClientOplataRealizasiaType;
    Esr : File Of ClientNewVozwratType;
    Esv : PClientNewVozwratType;
    Cur,j : LongInt;
    CplFile : File Of ClientOplataRealizasiaType;
    CplVAr  : ClientOplataRealizasiaType;
    Start,Stop : LongInt;
    doc,date,timeopl,dateopl,srok : TDatestring;
    cc,Count : Word;
    SumDolg : AllStr;
    Kod : ArtikulStr;
    ClKod : ArtikulStr;
    STime,SDate : TDateString;
    Wspom: AllStr;
    ItogList : PBox;
    Index : Word;
    AllOutKassa,AllOtgruska,AllOplata,AllReturn:Real;
    SPrim : TMyString;
    Plus,Minus,SComment : AllStr;
    CurrentSaldo:Real;
    SSDate : TDateString;
    SVidano : AllStr;
    StartDate,StopDate : TDateString;
    Vid : Word;
    AllOtgruzkaL,AllReturnL,AllOplataL,AllOplataCL,AllVidanoL : Real;*)


Begin

(*PStaticText(ControlClient)^.GetText(S);
System.Delete(S,Pos(#3,S),1);
S:=Copy(s,1+CClient+1,CClientKod);
Kod:=s;

StartDate:='01-04-98';
StopDate:=FDate;

If Not(DatePeriodDialog(StartDate,StopDate,False)) Then Exit;


  Vid:=0;
  Vid:=SelectSpecify(False,11);
  If Vid=4 Then
   Begin
    Exit;
   End;



Start:=DAteStringToDate(DateMask,StartDAte);
Stop :=DAteStringToDate(DateMask,StopDAte);

 Assign (f,Path.ToTemp+'listdd.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'Не могу создать файл '+Path.ToTemp+'listdd.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

AllOtgruska:=0;
AllOplata:=0;;
AllReturn:=0;
AllOutKassa:=0;

R.Assign(0, 0, 0, 0);
NoScreenList := New(PBox, Init(R, 1, Nil));
NoScreenList^.NewList(New(PTextCollection, Init(0,1)));


 Writeln(f,Space+' СПРАВКА ПО ВЗАИМОРАСЧЕТАМ С КЛИЕНТОМ '+GetClientField(FClient,S,0)+' ('+FDate+' '+Times+')');

 Writeln(f,Space+' за период с '+startdate+' по '+stopdate);
 Writeln(f,Space+' Форма N 2');

 SumDolg:='0.00';

{
читаем *.his начиная с позиции соответсвующей дате начала расчета
читаем *.cpl
читаем *.cvz
Структура строки
Дата│Время│Вид операции│Номер и дата документа│Сумма операции│оператор│
           0 расход
           1 оплата
}



{сканируем продажи}

If Vid in [0,3] Then
Begin
 Assign(Esf,Path.ToClient+Kod+'.his');
 j:=IOResult;
 Reset(Esf);
 j:=IOResult;

 If j=0 Then
Begin
 If Not (Eof(Esf)) Then
 Begin
 While Not(Eof(Esf)) Do
  Begin

   DInfoMsg('Читаю отгрузки клиента '+Kod+'. Ждите ...');

   New(Es,Init);
   Count:=0;
   Read(Esf,Es^.Dat);


   If Es^.Dat.Active Then
Begin

   If (DateStringToDAte(DateMask,Es^.Dat.DateC)>=Start) And
      (DateStringToDAte(DateMask,Es^.Dat.DateC)<=Stop) Then
     Begin
        SDAte:=IntToStr(DateStringToDAte(DateMask,Es^.Dat.DateC),CDate);
        STime:=IntToStr(TimeStringToTime('hh:mm:ss',Es^.Dat.TimeC),CDate);
        RFormat(SDAte,CDate);
        RFormat(STime,CDAte);
        RFormat(Es^.Dat.Document,CDocNumer);
        s:=GetOperatorName(Es^.Dat.Caption);
        Format(s,CKto);

    If Abs(StrToReal(Es^.Dat.SummaZ))>0.009 Then
Begin
        MyStr(StrToReal(Es^.Dat.SummaZ),CIZenaK,CMantissa,SumDolg);
        s:=SDAte+'│'+STime+'│'+Es^.Dat.DateC+'│'+
           'отгрузка N '+Es^.Dat.Document+' от '+
           Es^.Dat.DateC+' │'+SumDolg+'│          │'+s+'│';

        AllOtgruska:=AllOtgruska+StrToreal(SumDolg);



        NoScreenList^.List^.Insert(NewStr(s));
        NoScreenList^.SetRange(NoScreenList^.List^.Count);

        {добавляем фиктивную оплату без отсрочки платежа}
        If Es^.DAt.DocSelector in [0,1,2,3,4] Then
        Begin
         s:=GetOperatorName(Es^.Dat.Caption);
         Format(s,CKto);
         MyStr(StrToReal(Es^.Dat.SummaZ),CIZenaK,CMantissa,SumDolg);
         s:=SDAte+'│'+STime+'│'+Es^.Dat.DateC+'│'+
            'оплата   N '+Es^.Dat.Document+' от '+
            Es^.Dat.DateC+' │'+'          │'+SumDolg+'│'+s+'│';

         AllOplata:=AllOplata+StrToreal(SumDolg);

          If (Es^.DAt.DocSelector=4) And (Es^.DAt.Rashet=1) Then
           Begin
            DelSpace(Es^.Dat.Bn.Date);
            Format(Es^.Dat.bn.Date,CDate);
            DelSpace(Es^.Dat.Bn.NPlat);
            Format(Es^.Dat.bn.NPlat,10);
            DelSpaceRight(Es^.Dat.Bn.Bank);
            Format(Es^.Dat.bn.Bank,CAll);

            s:=s+Es^.Dat.bn.Date+'│';
            s:=s+Es^.Dat.bn.NPlat+'│';
            s:=s+Es^.Dat.bn.Bank+'│';
           End;


         NoScreenList^.List^.Insert(NewStr(s));
         NoScreenList^.SetRange(NoScreenList^.List^.Count);
End;
        End;
     End;{фильтр дат}
 End;{Active}
    Dispose(Es,Done)
  End;{While}
End;
  j:=IOResult;
  System.Close(Esf);
  j:=IOResult;
 End;{If j=0}
{закончили сканировать продажи}

NoInfoMsg;
End;

{сканируем оплаты}

If Vid in[1,3] Then
Begin
 Assign(EsfOpl,Path.ToClientOplata+Kod+'.cpl');
 j:=IOResult;
 Reset(EsfOpl);
 j:=IOResult;

 If j=0 Then
Begin
 If Not (Eof(EsfOpl)) Then
 Begin
 While Not(Eof(EsfOpl)) Do
  Begin

   DInfoMsg('Читаю оплаты клиента '+Kod+'. Ждите ...');

   Count:=0;
   Read(EsfOpl,EsOpl);

   If Not(EsOpl.Vozwrat) Then
   If (DAteStringToDAte(DateMask,EsOpl.DateC)>=Start) And
      (DAteStringToDAte(DateMask,EsOpl.DateC)<=Stop) Then
   Begin
        SDAte:=IntToStr(DAteStringToDAte(DateMask,EsOpl.DateC),CDate);
        STime:=IntToStr(TimeStringToTime('hh:mm:ss',EsOpl.TimeC),CDate);
        RFormat(SDAte,CDate);
        RFormat(STime,CDAte);
        EsOpl.Document:=IntToStr(StrToInt(EsOpl.Document),CDocNumer);
        RFormat(EsOpl.Document,CDocNumer);
        s:=GetOperatorName(EsOpl.Caption);
        Format(s,CKto);

     If Abs(StrToReal(EsOpl.SummaZ)-StrToReal(EsOpl.Skidka))>0.009 Then
Begin
        MyStr(StrToReal(EsOpl.SummaZ)-StrToReal(EsOpl.Skidka),CIZenaK,CMantissa,SumDolg);
        s:=SDAte+'│'+STime+'│'+EsOpl.DateC+'│'+
           'опл.долг N '+EsOpl.Document+' от '+
		 EsOpl.DateDoc+' │'+'          │'+SumDolg+'│'+s+'│';

        AllOplata:=AllOplata+StrToreal(SumDolg);

         If Not(EsOpl.Rashet) Then
         Begin
            DelSpace(EsOpl.Bn.Date);
            Format(EsOpl.bn.Date,CDate);
            DelSpace(EsOpl.Bn.NPlat);
            Format(EsOpl.bn.NPlat,10);
            DelSpaceRight(EsOpl.Bn.Bank);
            Format(EsOpl.bn.Bank,CAll);

            s:=s+EsOpl.bn.Date+'│';
            s:=s+EsOpl.bn.NPlat+'│';
            s:=s+EsOpl.bn.Bank+'│';
         End;{Rashet=1}

         NoScreenList^.List^.Insert(NewStr(s));
         NoScreenList^.SetRange(NoScreenList^.List^.Count);
End;
   End;{период и не возврат}

  End;{While}
End;
  j:=IOResult;
  System.Close(EsfOpl);
  j:=IOResult;

 End;{If j=0}
{закончили сканировать оплаты}
 NoInfoMsg;
End;


If Vid in[2,3] Then
Begin
{сканируем возвраты}
 Assign(Esr,Path.ToClientReturn+Kod+'.cvz');
 j:=IOResult;
 Reset(Esr);
 j:=IOResult;

 If j=0 Then
Begin
 If Not (Eof(Esr)) Then
 Begin
   New(Esv,Init);
 While Not(Eof(Esr)) Do
  Begin

   DInfoMsg('Читаю возвраты клиента '+Kod+'. Ждите ...');

   Read(Esr,Esv^.Dat);

   If (DateStringToDAte(DAteMask,Esv^.Dat.Return.DateC)>=Start) And
      (DateStringToDAte(DAteMask,Esv^.Dat.Return.DateC)<=Stop) Then
   Begin
        SDAte:=IntToStr(DateStringToDAte(DAteMask,EsV^.Dat.Return.DateC),CDate);
        SSDAte:=EsV^.Dat.Return.DateC;
        STime:=IntToStr(TimeStringToTime('hh:mm:ss',EsV^.Dat.Return.TimeC),CDate);
        RFormat(SDAte,CDate);
        RFormat(STime,CDate);
        RFormat(EsV^.Dat.Return.Document,CDocNumer);
        s:=GetOperatorName(EsV^.Dat.Return.Caption);
        Format(s,CKto);

        If Abs(StrToReal(EsV^.Dat.Return.SummaR)-StrToReal(EsV^.Dat.Return.Skidka))>0.009 Then
Begin
        MyStr(StrToReal(EsV^.Dat.Return.SummaR)-StrToReal(EsV^.Dat.Return.Skidka),CIZenaK,CMantissa,SumDolg);
        s:=SDAte+'│'+STime+'│'+SSDate{EsV^.Dat.Return.DateC}+'│'+
           'возврат  N '+EsV^.Dat.Return.Document+' от '+
		 EsV^.Dat.Return.DateC+' │'+'          │'+
		 SumDolg+'│'+s+'│';

        AllReturn:=AllReturn+StrToreal(SumDolg);


            Wspom:=EsV^.Dat.Return.BasisDoc+' от '+EsV^.Dat.Return.BasisDate;
            Format(Wspom,CAll);

            s:=s+'         '+'│';
            s:=s+'          '+'│';
            s:=s+wspom+'│';

        NoScreenList^.List^.Insert(NewStr(s));
        NoScreenList^.SetRange(NoScreenList^.List^.Count);

        If (EsV^.Dat.Return.Rashod) And (Abs(StrToReal(EsV^.Dat.Return.RashodSumma))>0.009) Then
         Begin
        SDAte:=IntToStr(DateStringToDAte(DAteMask,EsV^.Dat.Return.DateC),CDate);
        SSDAte:=EsV^.Dat.Return.DateC;
        STime:=IntToStr(TimeStringToTime('hh:mm:ss',EsV^.Dat.Return.TimeC),CDate);
        RFormat(SDAte,CDate);
        RFormat(STime,CDate);
        RFormat(EsV^.Dat.Return.Document,CDocNumer);
        s:=GetOperatorName(EsV^.Dat.Return.Caption);
        Format(s,CKto);

          MyStr(StrToReal(EsV^.Dat.Return.RashodSumma),CIZenaK,CMantissa,SumDolg);
          s:=SDAte+'│'+STime+'│'+SSDate{EsV^.Dat.Return.DateC}+'│'+
          'выдано по N'+EsV^.Dat.Return.Document+' от '+
		EsV^.Dat.Return.DateC+' │'+SumDolg+'│          │'+
		+s+'│';

        SVidano[0]:=#0;
        If EsV^.Dat.Return.Rashod Then
         Begin
          SVidano:=' Из кассы:'+RealToStr(StrToReal(EsV^.Dat.Return.RashodSumma),CZenaZ,CMAntissa);
          AllOutKassa:=AllOutKAssa+StrToReal(EsV^.Dat.Return.RashodSumma);
         End;

          Wspom:=EsV^.Dat.Return.BasisDoc+' от '+
		EsV^.Dat.Return.BasisDate+SVidano;
          Format(Wspom,CAll);

          s:=s+'         '+'│';
          s:=s+'          '+'│';
          s:=s+wspom+'│';

          NoScreenList^.List^.Insert(NewStr(s));
          NoScreenList^.SetRange(NoScreenList^.List^.Count);
         End;

End;
  End;

  End;{While}
  Dispose(EsV,Done);
End;
  j:=IOResult;
  System.Close(Esr);
  j:=IOResult;
 End;{If j=0}
{закончили сканировать возвраты}


NoInfoMsg;
End;

DInfoMsg('Формирую отчет...');

R.Assign(0,0,0,0);
ItogList := New(PBox, Init(R, 1, Nil));
ItogList^.NewList(New(PMyCollection, Init(0,1)));

If (NoScreenList^.List^.Count)>=1 Then
Begin
 For Index:=0 To NoScreenList^.List^.Count-1 Do
  Begin
   s:=NoScreenList^.GetText(Index,NoScreenList^.List^.Count);
   ItogList^.List^.Insert(NewStr(s));
   ItogList^.SetRange(ItogList^.List^.Count);
  End;
End;

 Writeln(f,Space+'┌───┬────────┬────────────────────────────┬──────────┬──────────┬────────────┐');
 Writeln(f,Space+'│N  │Дата док│Вид операции                │Отгрузка  │Оплата    │Оператор    │');
 Writeln(f,Space+'└───┴────────┴────────────────────────────┴──────────┴──────────┴────────────┘');
                 {1234│12345678│оплата по N 1234 от 12345678│1234567890│1234567890│123456789012│123456789012345}
                               {оплата по N 1234 от 12345678}
                               {1234567890123456789012345678}
If (ItogList^.List^.Count)>=1 Then
Begin
 s:=ItogList^.GetText(0,ItogList^.List^.Count);
 STime:=Copy(s,1+CDate+1+CDAte+1,CDate);

 AllOtgruzkaL:=0;
 AllReturnL:=0;
 AllOplataL:=0;
 AllOplataCL:=0;
 AllVidanoL:=0;

 For Index:=0 To ItogList^.List^.Count-1 Do
  Begin
   s:=ItogList^.GetText(Index,ItogList^.List^.Count);
   System.Delete(s,1,CDAte+1+CDate+1);


   Plus:=Copy(s,1+CDate+1+28+1,CIZenaK);
   Minus:=Copy(s,1+CDate+1+28+1+CIZenaK+1,CIZenaK);

   {MemC('='+Plus+' ='+Minus);}

   CurrentSaldo:=CurrentSaldo+StrToReal(Plus)-StrToReal(Minus);

   s[0]:=Chr(CDate+1+28+1+CIZenaK+1+CIZenaK+1+CKto+1);

   SDAte:=IntToStr(Index+1,4);
   RFormat(SDAte,4);
   Writeln(f,Space+SDAte+'│'+s{+RealToStr(CurrentSaldo,CIZena,CMantissa)});

   s:=ItogList^.GetText(Index,ItogList^.List^.Count);
   System.Delete(s,1,CDAte+1+CDate+1);

     {если БН}
     If Pos('отгрузка',s)>0 Then
      Begin
       ss:=Copy(s,1+CDate+1+28+1,CIZenaK);
       AllOtgruzkaL:=AllOtgruzkaL+StrToReal(ss);
      End;


     {если БН}
     If Pos('оплата',s)>0 Then
      Begin
       ss:=Copy(s,1+CDate+1+28+1+CIZenaK+1,CIZenaK);
       AllOplataL:=AllOplataL+StrToReal(ss);
      End;


     {если БН}
     If Pos('опл.долг',s)>0 Then
      Begin
       ss:=Copy(s,1+CDate+1+28+1+CIZenaK+1,CIZenaK);
       AllOplataCL:=AllOplataCL+StrToReal(ss);
      End;

     {если возврат}
     If Pos('возврат',s)>0 Then
      Begin
       ss:=Copy(s,1+CDate+1+28+1+CIZenaK+1,CIZenaK);
       AllReturnL:=AllReturnL+StrToReal(ss);
      End;

     If Pos('выдано по',s)>0 Then
      Begin
       ss:=Copy(s,1+CDate+1+28+1+CIZenaK+1,CIZenaK);
       AllVidanoL:=AllVidanoL+StrToReal(ss);
      End;


   {тест на наличие расширенной информации}
   If Ord(s[0])>(1+CDate+1+28+1+CIZenaK+1+CIZenaK+1+CKto+1) Then
    Begin

     {если БН}
     If Pos('опл.долг',s)>0 Then
      Begin
       sDate:=Copy(s,1+CDate+1+28+1+CIZenaK+1+CIZenaK+1+CKto+1,CDAte);
       DelSpaceRight(sDate);
       sPrim:=Copy(s,1+CDate+1+28+1+CIZenaK+1+CIZenaK+1+CKto+1+CDate+1+10+1,CAll);
       DelSpaceRight(sPrim);
       sComment:=Copy(s,1+CDate+1+28+1+CIZenaK+1+CIZenaK+1+CKto+1+CDAte+1,10);
       DelSpaceRight(sComment);
       Writeln(f,Space+'              ПП: '+sComment+' от: '+SDate+' Банк: '+SPrim);

      End;

     {если возврат}
     If Pos('возврат',s)>0 Then
      Begin
       sPrim:=Copy(s,1+CDate+1+28+1+CIZenaK+1+CIZenaK+1+CKto+1+CDate+1+10+1+1,CAll);
       DelSpaceRight(sPrim);
       Writeln(f,Space+'              документ основание: '+sPrim);
      End;

     If Pos('выдано по',s)>0 Then
      Begin
       sPrim:=Copy(s,1+CDate+1+28+1+CIZenaK+1+CIZenaK+1+CKto+1+CDate+1+10+1+1,CAll);
       DelSpaceRight(sPrim);
       Writeln(f,Space+'              документ основание: '+sPrim);
      End;

    End;



 If Index<>(ItogList^.List^.Count-1) Then
  Begin
   s:=ItogList^.GetText((Index+1),ItogList^.List^.Count);
   S:=Copy(s,1+CDate+1+CDAte+1,CDate);
   {MemC('s='+s+' '+'STime='+STime);}
   If s<>STime Then
   Begin
    STime:=S;
    Writeln(f,Space+'Всего отгрузка   :'+RealToStr(AllOtgruzkaL,CIZena,CMantissa)+^M+
                    'Всего оплата     :'+RealToStr(AllOplataL,CIZena,CMantissa)+^M+
				'Всего опл консиг.:'+RealToStr(AllOplataCL,CIZena,CMantissa)+^M+
				'Всего возврат.   :'+RealToStr(AllReturnL,CIZena,CMantissa)+^M+
				'Всего выдано по возврату:'+RealToStr(AllVidanoL,CIZena,CMantissa));
    Writeln(f,Space+'──────────────────────────────────────────────────────────────────────────');
    AllOtgruzkaL:=0;
    AllReturnL:=0;
    AllOplataL:=0;
    AllOplataCL:=0;
    AllVidanoL:=0;
   End;

  End;

  End;



End;

Dispose(ItogList,Done);
Dispose(NoScreenList,Done);

    Writeln(f,Space+'Всего отгрузка   :'+RealToStr(AllOtgruzkaL,CIZena,CMantissa)+^M+
                    'Всего оплата     :'+RealToStr(AllOplataL,CIZena,CMantissa)+^M+
				'Всего опл консиг.:'+RealToStr(AllOplataCL,CIZena,CMantissa)+^M+
				'Всего возврат.   :'+RealToStr(AllReturnL,CIZena,CMantissa)+^M+
				'Всего выдано по возврату:'+RealToStr(AllVidanoL,CIZena,CMantissa));

 AllOtgruzkaL:=0;
 AllReturnL:=0;
 AllOplataL:=0;
 AllOplataCL:=0;
 AllVidanoL:=0;

Writeln(f,Space+'──────────────────────────────────────────────────────────────────────────────────────');
Writeln(f);
Writeln(f,Space+'    Всего отгружено продукции на сумму : ',RecognizReal(AllOtgruska,CIZena,CMantissa));
Writeln(f,Space+'     Всего оплачено продукции на сумму : ',RecognizReal(AllOplata,CIZena,CMantissa));
Writeln(f,Space+'   Всего возвращено продукции на сумму : ',RecognizReal(AllReturn,CIZena,CMantissa));
Writeln(f,Space+'     Всего выдано из кассы по возврату : ',RecognizReal(AllOutKassa,CIZena,CMantissa));

{Writeln(f,Space+' текущая задолженность клиента ('+FDate+'): '+RecognizReal(StrToreal(CalcDolg(Kod)),CIZena,CMAntissa));}
Writeln(f);


 Writeln(f,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'=======================================================');
 Index:=IOResult;
 System.Close(f);
 Index:=IOResult;
NoInfoMsg;

 ViewAsText(Path.ToTemp+'listdd.txt',True);
 Report(Path.ToTemp+'listdd.txt','',1,False,False);*)
End;



{$IFDef DPMI}

Procedure TInfoDynamicDebit.Refresh;
Var Test : LongInt;
    P : Real;
    Wp : String[CIZena];
    ClientOplataFile : File Of ClientOplataRealizasiaType;
    ClientOplata : ClientOplataRealizasiaType;
Begin
ClearFind;

DynamicList^.NewList(Nil);
DynamicList^.NewList(New({PText}PMyCollection, Init(0,1)));
PStaticText(ControlClient)^.GetText(PrevS);
System.Delete(PrevS,1,1);

PrevS:=Copy(PrevS,1+CClient+1,CClientKod);
Assign (ClientOplataFile,Path.ToClientOplata+PrevS+'.cpl');
Test:=IOResult;
Reset (ClientOplataFile);
Test:=IOResult;
If Test=0 Then
Begin
DInfo('Читаю хронологию оплаты долгов клиентом...');
While Not(Eof(ClientOplataFile)) Do
 Begin
  Read(ClientOplataFile,ClientOplata);
    With ClientOplata Do
    Begin
    RFormatZerro(ClientOplata.Document,CDocNumer);
    Format (Document,CDocNumer);
    Format (DateDoc,CDate);
    Format (Srok,CDate);
    Format (DAteC,CDate);
    Format (TimeC,CDate);
    Format (SummaZ,CIZena);
    MyStr(StrToReal(Skidka),CIZena,CMantissa,Skidka);
    {Format (Skidka,CIZena);}
    wp:=GetOperatorName(Caption);
    Format(wp,CKto);
    {Str(StrToInt(Delta):CLitrMantissa,Delta);}
    Format(Delta,CLitrMantissa);
    MyStr(StrToReal(SummaZ)-StrToReal(Skidka),CIZena,CMantissa,Summaz);
    DynamicList^.List^.Insert(NewStr('│'+Document+'│'
    +DateDoc+'│'+Srok+'│'+DateC+'│'+TimeC+'│'+SummaZ+'│'+Skidka+'│'+Delta+'│'+wp));
    End;
    DynamicList^.SetRange(DynamicList^.List^.Count);
 End;
System.Close(ClientOplataFile);
NoInfo;
End;
DynamicList^.FocusItem(0);
DynamicList^.HelpCtx:=$E316;
PrevCurrent[0]:=#0;
Redraw;
End;


Procedure TInfoDynamicDebit.FreshRashetHint;
Var Ass : DocumentEdit;
    Test : Word;
    R : TRect;
    s,ws : TMyString;
    SDAte,STime:TDateString;
    SSumma :String[CIZena];
    Find : Boolean;
    Kto : String[CKto];
    ClientOplataFile : File Of ClientOplataRealizasiaType;
    ClientOplata : ClientOplataRealizasiaType;
Begin
If (DynamicList^.State and sfFocused <> 0) And (DynamicList^.List<>Nil)And(DynamicList^.List^.Count>=1) Then
 Begin
  s:=DynamicList^.GetText(DynamicList^.Focused,DynamicList^.List^.Count);
  If s <> PrevCurrent Then
  Begin
  PrevCurrent:=S;
{  Ass.EditPosition:=Copy(DynamicList^.GetText(DynamicList^.Focused,DynamicList^.List^.Count),1+1+CDate+1,CDocNumer);}
  Ass.EditPosition:=Copy(DynamicList^.GetText(DynamicList^.Focused,DynamicList^.List^.Count),1+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  ClearChar(Ass.EditPosition);
{  Ass.D:=Copy(DynamicList^.GetText(DynamicList^.Focused,DynamicList^.List^.Count),1+1,CDate);}
  Ass.D:=Copy(DynamicList^.GetText(DynamicList^.Focused,DynamicList^.List^.Count),1+1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  SDate:=Copy(DynamicList^.GetText(DynamicList^.Focused,DynamicList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1,CDate);
  STime:=Copy(DynamicList^.GetText(DynamicList^.Focused,DynamicList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1+CDate+1,
  CDate);
  SSumma:=Copy(DynamicList^.GetText(DynamicList^.Focused,DynamicList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1+CDate+1+
  CDate+1,CIZena);
  Kto:=Copy(DynamicList^.GetText(DynamicList^.Focused,DynamicList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1+CDate+1+
  CDate+1+CIZena+1+CIZena+1+CLitrMantissa+1,
  CKto);
  DelSpace(sdate);
  DelSpace(stime);
  DelSpace(ssumma);

  PStaticText(ControlClient)^.GetText(PrevS);
  System.Delete(PrevS,1,1);

  PrevS:=Copy(PrevS,1+CClient+1,CClientKod);
  Assign (ClientOplataFile,Path.ToClientOplata+PrevS+'.cpl');
  Test:=IOResult;
  Reset (ClientOplataFile);
  Test:=IOResult;
  If Test=0 Then
  Begin
   Find:=False;
   DelZerro(Ass.EditPosition);
   While Not(Eof(ClientOplataFile))And Not(find) Do
    Begin
     Read(ClientOplataFile,ClientOplata);
     ClearChar(ClientOplata.Document);
     DelZerro(ClientOplata.Document);

     DelSpace(ClientOplata.DateDoc);
     DelSpace(ClientOplata.SummaZ);

     If (ClientOplata.Document=Ass.EditPosition) And (Ass.D=ClientOplata.DateDoc)
    And (ClientOplata.DateC=SDate) And (ClientOplata.TimeC=STime) {And (ClientOplata.SummaZ=SSumma)}Then
      Begin
       Find:=True;
      End;
    End;
    System.Close(ClientOplataFile);
    If Not(Find) Then
     Begin
      MessageBox(^M+#3'Документ '+Ass.EditPosition+' не найден!',Nil,mfError+mfCancelButton);
      Exit;
     End;

Dispose(ControlPP,Done);
R.Assign(24, 20, 34, 21);
ControlPP := New(PColoredText, Init(R, #3+ClientOplata.Bn.NPLat, $7E));
Insert(ControlPP);

Dispose(ControlDatePP,Done);
R.Assign(24, 19, 32, 20);
ControlDatePP := New(PColoredText, Init(R, #3+ClientOplata.Bn.Date, $7E));
Insert(ControlDatePP);

Dispose(ControlSummaPP,Done);
R.Assign(45, 19, 60, 20);
ControlSummaPP := New(PColoredText, Init(R, #3+ClientOplata.Bn.Summa, $7E));
Insert(ControlSummaPP);

Dispose(ControlBank,Done);
R.Assign(45, 20, 78, 21);
ControlBank := New(PColoredText, Init(R, ClientOplata.Bn.Bank, $7E));
Insert(ControlBank);

Dispose(ControlRashet,Done);
R.Assign(10, 19, 13, 20);
If ClientOplata.Rashet Then
ControlRashet := New(PColoredText, Init(R, #3'Б/Н', $7E))
Else
Begin
ControlRashet := New(PColoredText, Init(R, #3'Нал', $7E));
if ClientOplata.Bn.Bank<>'' then ControlRashet := New(PColoredText, Init(R, #3'Вз.зач', $7E));
End;
Insert(ControlRashet);

Dispose(ControlPrim,Done);
R.Assign(13, 21, 53, 22);
If ClientOplata.Vozwrat Then
ControlPrim := New(PColoredText, Init(R, #3'Возврат по документу N'+ClientOplata.DocNumerReturn+
 ' от '+ClientOplata.DocDateReturn, $7E))
 Else
ControlPrim := New(PColoredText, Init(R, #3'', $7E));
Insert(ControlPrim);

Dispose(ControlPassword,Done);
R.Assign(64, 21, 76, 22);
ControlPassword := New(PColoredText, Init(R, #3+Kto, $7E));
Insert(ControlPassword);
  End
  Else
   MessageBox(^M+#3'Ошибка доступа к файлу '+Path.ToClientOplata+PrevS+'.cpl!',Nil,mfError+mfCancelButton);
   Redraw;
 End;
 End;
End;

Procedure TInfoDynamicDebit.FormReport2;
Const Space='';
Var f : text;
    r1 : Real;
    R : TRect;
    NoScreenList : PBox;
    s : TMystring;
    c,k : Word;
    SS : AllStr;
    Es : PStatClientType;
    Esf : File  of StatClientType;
    EsfOpl : File  of ClientOplataRealizasiaType;
    EsOPl :ClientOplataRealizasiaType;
    Esr : File Of ClientNewVozwratType;
    Esv : PClientNewVozwratType;
    Cur,j : LongInt;
    CplFile : File Of ClientOplataRealizasiaType;
    CplVAr  : ClientOplataRealizasiaType;
    Start,Stop : LongInt;
    doc,date,timeopl,dateopl,srok : TDatestring;
    cc,Count : Word;
    StartSaldo,SumDolg : AllStr;
    Kod : ArtikulStr;
    ClKod : ArtikulStr;
    STime,SDate : TDateString;
    Wspom: AllStr;
    ItogList : PBox;
    Index : Word;
    AllOutKassa,AllOtgruska,AllOplata,AllReturn:Real;
    SPrim : TMyString;
    Plus,Minus,SComment : AllStr;
    CurrentSaldo:Real;
    SSDate : TDateString;
    SVidano : AllStr;
    StartDate,StopDate : TDateString;
    Vid : Word;
    AllOtgruzkaL,AllReturnL,AllOplataL,AllOplataCL,AllVidanoL : Real;

Begin

PStaticText(ControlClient)^.GetText(S);
System.Delete(S,Pos(#3,S),1);
S:=Copy(s,1+CClient+1,CClientKod);
Kod:=s;

StartDate:='01-04-98';
StopDate:=FDate;

If Not(DatePeriodDialog(StartDate,StopDate,False)) Then Exit;


  Vid:=3;

Start:=DAteStringToDate(DateMask,StartDAte);
Stop :=DAteStringToDate(DateMask,StopDAte);

If Not GetDolgClient(
 DateToDateString(DateMask,DateStringToDate(DateMask,StartDate)-1),s,2,StartSaldo,StartDate) Then StartSaldo:='??.??';

 Assign (f,Path.ToTemp+'listdd.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'Не могу создать файл '+Path.ToTemp+'listdd.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

AllOtgruska:=0;
AllOplata:=0;;
AllReturn:=0;
AllOutKassa:=0;

R.Assign(0, 0, 0, 0);
NoScreenList := New(PBox, Init(R, 1, Nil));
NoScreenList^.NewList(New(PTextCollection, Init(0,1)));

 Writeln(f,Space+' АКТ СВЕРКИ ');
 Writeln(f,Space+' ВЗАИМОРАСЧЕТОВ С КЛИЕНТОМ '+GetClientField(FFFName,S,0){+' по состоянию на '+FDate});

 Writeln(f,Space+' за период с '+startdate+' по '+stopdate);
{ Writeln(f,Space+' Форма N 2');}
Writeln(f,Space);
Writeln(f,Space+'Мы, нижеподписавшиеся,'+Rek.Name
+' в лице Генерального директора  Еродского П.Е.,с одной стороны');
Writeln(f,Space+'и '+GetClientField(FFFName,S,0)+' в лице _________________________________ с другой стороны,');
Writeln(f,Space+'составили настоящий акт сверки в том, что состояние взаимных расчетов по данным учета следующие:');

 SumDolg:='0.00';

{
читаем *.his начиная с позиции соответсвующей дате начала расчета
читаем *.cpl
читаем *.cvz
Структура строки
Дата│Время│Вид операции│Номер и дата документа│Сумма операции│оператор│
           0 расход
           1 оплата
}



{сканируем продажи}

If Vid in [0,3] Then
Begin
 Assign(Esf,Path.ToClient+Kod+'.his');
 j:=IOResult;
 Reset(Esf);
 j:=IOResult;

 If j=0 Then
Begin
 If Not (Eof(Esf)) Then
 Begin
 While Not(Eof(Esf)) Do
  Begin

   DInfoMsg('Читаю отгрузки клиента '+Kod+'. Ждите ...');

   New(Es,Init);
   Count:=0;
   Read(Esf,Es^.Dat);


   If Es^.Dat.Active Then
Begin

   If (DateStringToDAte(DateMask,Es^.Dat.DateC)>=Start) And
      (DateStringToDAte(DateMask,Es^.Dat.DateC)<=Stop) Then
     Begin
        SDAte:=IntToStr(DateStringToDAte(DateMask,Es^.Dat.DateC),CDate);
        STime:=IntToStr(TimeStringToTime('hh:mm:ss',Es^.Dat.TimeC),CDate);
        RFormat(SDAte,CDate);
        RFormat(STime,CDAte);
        RFormat(Es^.Dat.Document,CDocNumer);
        s:=GetOperatorName(Es^.Dat.Caption);
        Format(s,CKto);

    If Abs(StrToReal(Es^.Dat.SummaZ))>0.009 Then
Begin
        MyStr(StrToReal(Es^.Dat.SummaZ),CIZenaK,CMantissa,SumDolg);
        s:=SDAte+'│'+STime+'│'+Es^.Dat.DateC+'│'+
           'отгрузка N '+Es^.Dat.Document+' от '+
           Es^.Dat.DateC+' │'+SumDolg+'│          │'+s+'│';

        AllOtgruska:=AllOtgruska+StrToreal(SumDolg);



        NoScreenList^.List^.Insert(NewStr(s));
        NoScreenList^.SetRange(NoScreenList^.List^.Count);

        {добавляем фиктивную оплату без отсрочки платежа}
        If Es^.DAt.DocSelector in [0,1,2,3,4] Then
        Begin
         s:=GetOperatorName(Es^.Dat.Caption);
         Format(s,CKto);
         MyStr(StrToReal(Es^.Dat.SummaZ),CIZenaK,CMantissa,SumDolg);
         s:=SDAte+'│'+STime+'│'+Es^.Dat.DateC+'│'+
            'оплата   N '+Es^.Dat.Document+' от '+
            Es^.Dat.DateC+' │'+'          │'+SumDolg+'│'+s+'│';

         AllOplata:=AllOplata+StrToreal(SumDolg);

          If (Es^.DAt.DocSelector=4) And (Es^.DAt.Rashet=1) Then
           Begin
            DelSpace(Es^.Dat.Bn.Date);
            Format(Es^.Dat.bn.Date,CDate);
            DelSpace(Es^.Dat.Bn.NPlat);
            Format(Es^.Dat.bn.NPlat,10);
            DelSpaceRight(Es^.Dat.Bn.Bank);
            Format(Es^.Dat.bn.Bank,CAll);

            s:=s+Es^.Dat.bn.Date+'│';
            s:=s+Es^.Dat.bn.NPlat+'│';
            s:=s+Es^.Dat.bn.Bank+'│';
           End;


         NoScreenList^.List^.Insert(NewStr(s));
         NoScreenList^.SetRange(NoScreenList^.List^.Count);
End;
        End;
     End;{фильтр дат}
 End;{Active}
    Dispose(Es,Done)
  End;{While}
End;
  j:=IOResult;
  System.Close(Esf);
  j:=IOResult;
 End;{If j=0}
{закончили сканировать продажи}

NoInfoMsg;
End;

{сканируем оплаты}

If Vid in[1,3] Then
Begin
 Assign(EsfOpl,Path.ToClientOplata+Kod+'.cpl');
 j:=IOResult;
 Reset(EsfOpl);
 j:=IOResult;

 If j=0 Then
Begin
 If Not (Eof(EsfOpl)) Then
 Begin
 While Not(Eof(EsfOpl)) Do
  Begin

   DInfoMsg('Читаю оплаты клиента '+Kod+'. Ждите ...');

   Count:=0;
   Read(EsfOpl,EsOpl);

   If Not(EsOpl.Vozwrat) Then
   If (DAteStringToDAte(DateMask,EsOpl.DateC)>=Start) And
      (DAteStringToDAte(DateMask,EsOpl.DateC)<=Stop) Then
   Begin
        SDAte:=IntToStr(DAteStringToDAte(DateMask,EsOpl.DateC),CDate);
        STime:=IntToStr(TimeStringToTime('hh:mm:ss',EsOpl.TimeC),CDate);
        RFormat(SDAte,CDate);
        RFormat(STime,CDAte);
        EsOpl.Document:=IntToStr(StrToInt(EsOpl.Document),CDocNumer);
        RFormat(EsOpl.Document,CDocNumer);
        s:=GetOperatorName(EsOpl.Caption);
        Format(s,CKto);

     If Abs(StrToReal(EsOpl.SummaZ)-StrToReal(EsOpl.Skidka))>0.009 Then
Begin
        MyStr(StrToReal(EsOpl.SummaZ)-StrToReal(EsOpl.Skidka),CIZenaK,CMantissa,SumDolg);
        s:=SDAte+'│'+STime+'│'+EsOpl.DateC+'│'+
           'опл.долг N '+EsOpl.Document+' от '+
		 EsOpl.DateDoc+' │'+'          │'+SumDolg+'│'+s+'│';

        AllOplata:=AllOplata+StrToreal(SumDolg);

         If Not(EsOpl.Rashet) Then
         Begin
            DelSpace(EsOpl.Bn.Date);
            Format(EsOpl.bn.Date,CDate);
            DelSpace(EsOpl.Bn.NPlat);
            Format(EsOpl.bn.NPlat,10);
            DelSpaceRight(EsOpl.Bn.Bank);
            Format(EsOpl.bn.Bank,CAll);

            s:=s+EsOpl.bn.Date+'│';
            s:=s+EsOpl.bn.NPlat+'│';
            s:=s+EsOpl.bn.Bank+'│';
         End;{Rashet=1}

         NoScreenList^.List^.Insert(NewStr(s));
         NoScreenList^.SetRange(NoScreenList^.List^.Count);
End;
   End;{период и не возврат}

  End;{While}
End;
  j:=IOResult;
  System.Close(EsfOpl);
  j:=IOResult;

 End;{If j=0}
{закончили сканировать оплаты}
 NoInfoMsg;
End;


If Vid in[2,3] Then
Begin
{сканируем возвраты}
 Assign(Esr,Path.ToClientReturn+Kod+'.cvz');
 j:=IOResult;
 Reset(Esr);
 j:=IOResult;

 If j=0 Then
Begin
 If Not (Eof(Esr)) Then
 Begin
   New(Esv,Init);
 While Not(Eof(Esr)) Do
  Begin

   DInfoMsg('Читаю возвраты клиента '+Kod+'. Ждите ...');

   Read(Esr,Esv^.Dat);

   If (DateStringToDAte(DAteMask,Esv^.Dat.Return.DateC)>=Start) And
      (DateStringToDAte(DAteMask,Esv^.Dat.Return.DateC)<=Stop) Then
   Begin
        SDAte:=IntToStr(DateStringToDAte(DAteMask,EsV^.Dat.Return.DateC),CDate);
        SSDAte:=EsV^.Dat.Return.DateC;
        STime:=IntToStr(TimeStringToTime('hh:mm:ss',EsV^.Dat.Return.TimeC),CDate);
        RFormat(SDAte,CDate);
        RFormat(STime,CDate);
        RFormat(EsV^.Dat.Return.Document,CDocNumer);
        s:=GetOperatorName(EsV^.Dat.Return.Caption);
        Format(s,CKto);

        If Abs(StrToReal(EsV^.Dat.Return.SummaR)-StrToReal(EsV^.Dat.Return.Skidka))>0.009 Then
Begin
        MyStr(StrToReal(EsV^.Dat.Return.SummaR)-StrToReal(EsV^.Dat.Return.Skidka),CIZenaK,CMantissa,SumDolg);
        s:=SDAte+'│'+STime+'│'+SSDate{EsV^.Dat.Return.DateC}+'│'+
           'возврат  N '+EsV^.Dat.Return.Document+' от '+
		 EsV^.Dat.Return.DateC+' │'+'          │'+
		 SumDolg+'│'+s+'│';

        AllReturn:=AllReturn+StrToreal(SumDolg);


            Wspom:=EsV^.Dat.Return.BasisDoc+' от '+EsV^.Dat.Return.BasisDate;
            Format(Wspom,CAll);

            s:=s+'         '+'│';
            s:=s+'          '+'│';
            s:=s+wspom+'│';

        NoScreenList^.List^.Insert(NewStr(s));
        NoScreenList^.SetRange(NoScreenList^.List^.Count);

        If (EsV^.Dat.Return.Rashod) And (Abs(StrToReal(EsV^.Dat.Return.RashodSumma))>0.009) Then
         Begin
        SDAte:=IntToStr(DateStringToDAte(DAteMask,EsV^.Dat.Return.DateC),CDate);
        SSDAte:=EsV^.Dat.Return.DateC;
        STime:=IntToStr(TimeStringToTime('hh:mm:ss',EsV^.Dat.Return.TimeC),CDate);
        RFormat(SDAte,CDate);
        RFormat(STime,CDate);
        RFormat(EsV^.Dat.Return.Document,CDocNumer);
        s:=GetOperatorName(EsV^.Dat.Return.Caption);
        Format(s,CKto);

          MyStr(StrToReal(EsV^.Dat.Return.RashodSumma),CIZenaK,CMantissa,SumDolg);
          s:=SDAte+'│'+STime+'│'+SSDate{EsV^.Dat.Return.DateC}+'│'+
          'выдано по N'+EsV^.Dat.Return.Document+' от '+
		EsV^.Dat.Return.DateC+' │'+SumDolg+'│          │'+
		+s+'│';

          AllOtgruska:=AllOtgruska+StrToreal(SumDolg);

        SVidano[0]:=#0;
        If EsV^.Dat.Return.Rashod Then
         Begin
          SVidano:=' Из кассы:'+RealToStr(StrToReal(EsV^.Dat.Return.RashodSumma),CZenaZ,CMAntissa);
          AllOutKassa:=AllOutKAssa+StrToReal(EsV^.Dat.Return.RashodSumma);
         End;

          Wspom:=EsV^.Dat.Return.BasisDoc+' от '+
		EsV^.Dat.Return.BasisDate+SVidano;
          Format(Wspom,CAll);

          s:=s+'         '+'│';
          s:=s+'          '+'│';
          s:=s+wspom+'│';

          NoScreenList^.List^.Insert(NewStr(s));
          NoScreenList^.SetRange(NoScreenList^.List^.Count);
         End;

End;
  End;

  End;{While}
  Dispose(EsV,Done);
End;
  j:=IOResult;
  System.Close(Esr);
  j:=IOResult;
 End;{If j=0}
{закончили сканировать возвраты}


NoInfoMsg;
End;

DInfoMsg('Формирую отчет...');

R.Assign(0,0,0,0);
ItogList := New(PBox, Init(R, 1, Nil));
ItogList^.NewList(New(PMyCollection, Init(0,1)));

If (NoScreenList^.List^.Count)>=1 Then
Begin
 For Index:=0 To NoScreenList^.List^.Count-1 Do
  Begin
   s:=NoScreenList^.GetText(Index,NoScreenList^.List^.Count);
   ItogList^.List^.Insert(NewStr(s));
   ItogList^.SetRange(ItogList^.List^.Count);
  End;
End;

  Writeln(f,Space+' задолженность клиента на начало периода ('+
  DateToDateString(DateMask,DateStringToDate(DateMask,StartDate)-1)+'): '+StartSaldo);

Heads.InfoDynamicDebitFormReport2(f,space);

If (ItogList^.List^.Count)>=1 Then
Begin
 s:=ItogList^.GetText(0,ItogList^.List^.Count);
 STime:=Copy(s,1+CDate+1+CDAte+1,CDate);

 AllOtgruzkaL:=0;
 AllReturnL:=0;
 AllOplataL:=0;
 AllOplataCL:=0;
 AllVidanoL:=0;

 For Index:=0 To ItogList^.List^.Count-1 Do
  Begin
   s:=ItogList^.GetText(Index,ItogList^.List^.Count);

   System.Delete(s,1,CDAte+1+CDate+1);


   Plus:=Copy(s,1+CDate+1+28+1,CIZenaK);
   Minus:=Copy(s,1+CDate+1+28+1+CIZenaK+1,CIZenaK);

   {MemCl('='+Plus+' ='+Minus);}

   CurrentSaldo:=CurrentSaldo+StrToReal(Plus)-StrToReal(Minus);

   {s[0]:=Chr(CDate+1+28+1+CIZenaK+1+CIZenaK+1+CKto+1);}
   s[0]:=Chr(CDate+1+28+1+CIZenaK+1+CIZenaK+1);

   SDAte:=IntToStr(Index+1,4);
   RFormat(SDAte,4);
   Writeln(f,Space+SDAte+'│'+s{+RealToStr(CurrentSaldo,CIZena,CMantissa)});

   s:=ItogList^.GetText(Index,ItogList^.List^.Count);
   System.Delete(s,1,CDAte+1+CDate+1);

     {если БН}
     If Pos('отгрузка',s)>0 Then
      Begin
       ss:=Copy(s,1+CDate+1+28+1,CIZenaK);
       AllOtgruzkaL:=AllOtgruzkaL+StrToReal(ss);
      End;


     {если БН}
     If Pos('оплата',s)>0 Then
      Begin
       ss:=Copy(s,1+CDate+1+28+1+CIZenaK+1,CIZenaK);
       AllOplataL:=AllOplataL+StrToReal(ss);
      End;


     {если БН}
     If Pos('опл.долг',s)>0 Then
      Begin
       ss:=Copy(s,1+CDate+1+28+1+CIZenaK+1,CIZenaK);
       AllOplataCL:=AllOplataCL+StrToReal(ss);
      End;

     {если возврат}
     If Pos('возврат',s)>0 Then
      Begin
       ss:=Copy(s,1+CDate+1+28+1+CIZenaK+1,CIZenaK);
       AllReturnL:=AllReturnL+StrToReal(ss);
      End;

     If Pos('выдано по',s)>0 Then
      Begin
       ss:=Copy(s,1+CDate+1+28+1,CIZenaK);
       AllVidanoL:=AllVidanoL+StrToReal(ss);
       AllOtgruzkaL:=AllOtgruzkaL+StrToReal(ss);
      End;


   {тест на наличие расширенной информации}
   If Ord(s[0])>(1+CDate+1+28+1+CIZenaK+1+CIZenaK+1+CKto+1) Then
    Begin

     {если БН}
     If Pos('опл.долг',s)>0 Then
      Begin
       sDate:=Copy(s,1+CDate+1+28+1+CIZenaK+1+CIZenaK+1+CKto+1,CDAte);
       DelSpaceRight(sDate);
       sPrim:=Copy(s,1+CDate+1+28+1+CIZenaK+1+CIZenaK+1+CKto+1+CDate+1+10+1,CAll);
       DelSpaceRight(sPrim);
       sComment:=Copy(s,1+CDate+1+28+1+CIZenaK+1+CIZenaK+1+CKto+1+CDAte+1,10);
       DelSpaceRight(sComment);
       Writeln(f,Space+'              ПП: '+sComment+' от: '+SDate+' Банк: '+SPrim);

      End;

     {если возврат}
     If Pos('возврат',s)>0 Then
      Begin
       sPrim:=Copy(s,1+CDate+1+28+1+CIZenaK+1+CIZenaK+1+CKto+1+CDate+1+10+1+1,CAll);
       DelSpaceRight(sPrim);
       Writeln(f,Space+'              документ основание: '+sPrim);
      End;

     If Pos('выдано по',s)>0 Then
      Begin
       sPrim:=Copy(s,1+CDate+1+28+1+CIZenaK+1+CIZenaK+1+CKto+1+CDate+1+10+1+1,CAll);
       DelSpaceRight(sPrim);
       Writeln(f,Space+'             документ основание: '+sPrim);
      End;

    End;

 Writeln(f,Space+' ────────────────────────────────────────────────────────────────────────────────────────────────────────'+
 +'──────────');

 If Index<>(ItogList^.List^.Count-1) Then
  Begin
   s:=ItogList^.GetText((Index+1),ItogList^.List^.Count);
   S:=Copy(s,1+CDate+1+CDAte+1,CDate);
   {MemC('s='+s+' '+'STime='+STime);}
   If s<>STime Then
   Begin
  (*  STime:=S;
    Writeln(f,Space+'Всего отгрузка   :'+RealToStr(AllOtgruzkaL,CIZena,CMantissa)+^M+
                    'Всего оплата     :'+RealToStr(AllOplataL,CIZena,CMantissa)+^M+
				'Всего опл консиг.:'+RealToStr(AllOplataCL,CIZena,CMantissa)+^M+
				'Всего возврат.   :'+RealToStr(AllReturnL,CIZena,CMantissa)+^M+
				'Всего выдано по возврату:'+RealToStr(AllVidanoL,CIZena,CMantissa));
    Writeln(f,Space+'──────────────────────────────────────────────────────────────────────────');*)
    AllOtgruzkaL:=0;
    AllReturnL:=0;
    AllOplataL:=0;
    AllOplataCL:=0;
    AllVidanoL:=0;
   End;

  End;

  End;



End;

Dispose(ItogList,Done);
Dispose(NoScreenList,Done);

(*    Writeln(f,Space+'Всего отгрузка   :'+RealToStr(AllOtgruzkaL,CIZena,CMantissa)+^M+
                    'Всего оплата     :'+RealToStr(AllOplataL,CIZena,CMantissa)+^M+
				'Всего опл консиг.:'+RealToStr(AllOplataCL,CIZena,CMantissa)+^M+
				'Всего возврат.   :'+RealToStr(AllReturnL,CIZena,CMantissa)+^M+
				'Всего выдано по возврату:'+RealToStr(AllVidanoL,CIZena,CMantissa));*)

 AllOtgruzkaL:=0;
 AllReturnL:=0;
 AllOplataL:=0;
 AllOplataCL:=0;
                { │N  │Дата док│Вид операции                │ Дебет    │ Кредит   │N  │Дата док,Вид операции    │ Дебет '}
Writeln(f,Space+ '     Обороты за период                    │'+RecognizReal(AllOtgruska,CIZena-5,CMantissa)+'│'
+RecognizReal(AllOplata+AllReturn+AllVidanoL,CIZena-5,CMantissa)+'│');

Writeln(f,Space+ ' ────────────────────────────────────────────────────────────────────────────────────────────────────────'+
 +'──────────');
Write(f,Space+ '     Сальдо на '+stopdate+' г.                │');
if pos('??',StartSaldo)>0 then StartSaldo:='0.00';
AllOplata:=AllOtgruska-AllOplata-AllReturn+StrToReal(StartSaldo){-AllOutKassa};
AllVidanoL:=AllOplata;
AllOplata:=-AllOplata;

if AllOplata>=0 then
  begin
    {AllOplata:=-AllOplata;}
    Writeln(f,'          │'+RecognizReal(AllOplata,CIZena-5,CMantissa)+'│');
  end
else
  begin
    AllOplata:=-AllOplata;
    Writeln(f,RecognizReal(AllOplata,CIZena-5,CMantissa)+'│          │');
  end;

Writeln(f,Space+ ' ────────────────────────────────────────────────────────────────────────────────────────────────────────'+
 +'──────────');
Writeln(f);
{riteln(f,Space+'    Всего отгружено продукции на сумму : ',RecognizReal(AllOtgruskaAllOtgruska,CIZena,CMantissa));
Writeln(f,Space+'     Всего оплачено продукции на сумму : ',RecognizReal(AllOplata,CIZena,CMantissa));
Writeln(f,Space+'   Всего возвращено продукции на сумму : ',RecognizReal(AllReturn,CIZena,CMantissa));}
{Writeln(f,Space+'     Всего выдано из кассы по возврату : ',RecognizReal(AllOutKassa,CIZena,CMantissa));}

{Writeln(f,Space+' текущая задолженность клиента ('+FDate+'): '+RecognizReal(StrToreal(CalcDolg(Kod)),CIZena,CMAntissa));}
Writeln(f);

    Writeln(f,Space+'По данным '+copy(Rek.Name,pos(',',Rek.Name)+1,length(Rek.Name)-pos(',',Rek.Name)));
    Writeln(f,Space+'по состоянию на '+stopdate+' задолженность  за период с '+startdate+' по '+stopdate);
    Writeln(f,Space+'составляет '+RecognizReal(AllVidanoL,CIZena-5,CMantissa)+' рублей.');

Writeln(f);
Writeln(f);
Writeln(f,Space+'    От '+Rek.Name+'                                   От '+GetClientField(FFFName,Kod,0));
Writeln(f,Space+'    Генеральный директор            Еродский П.Е.                        _______________________  ');
Writeln(f);
Writeln(f);
 Writeln(f,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+ ' ========================================================================================================'+
 +'==========');
 Index:=IOResult;
 System.Close(f);
 Index:=IOResult;
NoInfoMsg;

 ViewAsText(Path.ToTemp+'listdd.txt',True);
 Report(Path.ToTemp+'listdd.txt','',1,False,False,false);
End;


procedure TInfoDynamicDebit.HandleEvent(var Event: TEvent);
Var test : Word;
    s : TMyString;
    l : Boolean;
    R : Real;
    b : Byte;
    Vid : Word;
begin
  Case Event.What Of
  evCommand :
     Case Event.Command Of

      cmAbout: Begin
      AboutCHM('41');
       ClearEvent(Event);
      End;

      cmCancel : Begin
                 Dispose(ControlClient,Done);
                 Dispose(DynamicList,Done);
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
{                PutEvent(Event);
                 Status:=DocNormal;
                 ClearEvent(Event);}
                End;

     cmFullview : Begin
     If (DynamicList^.State and sfFocused <> 0) And (DynamicList^.List<>Nil)And(DynamicList^.List^.Count>=1) Then
              FullPreview;
            End;

 cmReestrReport: if (User[80] or (CurrentPassword='00')) then
 Begin
     If (DynamicList^.State and sfFocused <> 0) And (DynamicList^.List<>Nil)And(DynamicList^.List^.Count>=1) Then
            Begin
              PStaticText(ControlClient)^.GetText(S);
              System.Delete(S,1,1);
		    If Password(3) then
		     begin

              Vid:=SelectImport(23);
              Case Vid Of
              0:FormReport(DynamicList);
              1:FormReport2(DynamicList);
              Else Exit;
              End;{Case}


               end;
            End
            End;
  cmSelectClient:
 Begin
  If (PView(Cl)<>Desktop^.TopView)And(ControlClient^.State and sfFocused <> 0) Then
  Begin
     PStaticText(ControlClient)^.GetText(S);
     System.Delete(S,1,1);
     Cl^.ShowClientList(s,0,0,True,False,False,-1,-1,-1,-1,Test);
     PStaticText(ControlClient)^.Text^:=#3+S;
     PrevS:=S;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
  End;
  Refresh;
     End;
     Redraw;
     ClearEvent(Event);
 End;
      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmInfoDebit) then ClearEvent(Event);
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


  If (Desktop^.Current=PView(InfoDynamicWindow)) And (Event.What <> EvKeyDown) Then
   Begin
      FreshRashetHint;
   End;


end;

{$Else}

procedure TInfoDynamicDebit.HandleEvent(var Event: TEvent);
Begin
End;
Procedure TInfoDynamicDebit.Refresh;
Begin
End;
Procedure TInfoDynamicDebit.FreshRashetHint;
Begin
End;
{$EndIf}




End.
