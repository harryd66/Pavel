{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit utils1;


Interface

Uses Glob,ServStr,Dialogs,MyCalc,Drivers,FindPrh;

Type
  PLinkWindow = ^TLinkWindow;
  TLinkWindow = object(TDialog)
         Calc: PMyCalculator;
         FP  : PFindPrh;
         procedure Start(LinkArt:ArtikulStr);
         procedure FormReport;
         procedure Refresh;
         procedure DrawCurrent;
         procedure HandleEvent(var Event: TEvent); virtual;
         Destructor Done;Virtual;
  end;


Type
  PLinkMarkaWindow = ^TLinkMarkaWindow;
  TLinkMarkaWindow = object(TDialog)
         Calc    : PMyCalculator;
         Lnk : PLinkWindow;
         FP  : PFindPrh;
         procedure Start(LinkArt:ArtikulStr);
         procedure FormReport;
         procedure Refresh;
         procedure DrawCurrent;
         procedure HandleEvent(var Event: TEvent); virtual;
         Destructor Done;Virtual;
  end;


Type
  PLinkExpertWindow = ^TLinkExpertWindow;
  TLinkExpertWindow = object(TDialog)
         Calc    : PMyCalculator;
         Lnk : PLinkWindow;
         FP  : PFindPrh;
         procedure Start(LinkArt:ArtikulStr);
         procedure FormReport;
         procedure Refresh;
         procedure DrawCurrent;
         procedure HandleEvent(var Event: TEvent); virtual;
         Destructor Done;Virtual;
  end;



Type
  PLinkGroupWindow = ^TLinkGroupWindow;
  TLinkGroupWindow = object(TDialog)
         Calc    : PMyCalculator;
         FP  : PFindPrh;
         procedure Start(LinkArt:ArtikulStr);
         procedure FormReport;
         procedure Refresh;
         procedure DrawCurrent;
         procedure HandleEvent(var Event: TEvent); virtual;
         Destructor Done;Virtual;
  end;


Type
  PLinkKSertifWindow = ^TLinkKSertifWindow;
  TLinkKSertifWindow = object(TDialog)
         Calc    : PMyCalculator;
         Lnk : PLinkWindow;
         FP  : PFindPrh;
         procedure Start(LinkArt:ArtikulStr);
         procedure FormReport;
         procedure Refresh;
         procedure DrawCurrent;
         procedure HandleEvent(var Event: TEvent); virtual;
         Destructor Done;Virtual;
  end;






{Procedure ReadNewINI (Var Res : LongInt);}
{Procedure WriteNewINI(Var Res : LongInt);}
{Function SelectImportDocument(Var P:PImportSuperMarketType):Boolean;}
{Function GetImportFileName(As:DocumentEdit;SkladKod:ArtikulStr):AllStr;}

{Procedure FindLink(Art:ArtikulStr;Space:String; Var Txt:Text); не нужна
убрал 11/12/2003}

Function SelSkidka:Word;
Function SelZeni:Word;
Function SelContrAgent:Word;
{Procedure ChekAddStr(st:String; Res:Word);}
Function FiltrDocument1(VAr V:Word):Boolean;
Function FiltrRashet(VAr V:Word):Boolean;
Procedure TestMemo;


Function SelectVidRasheta(DocSelector,EditDocSelector:Word;
Var Rashet,EditRashet:Word):Boolean;

Function HiddenAttribute(s:String):Boolean;
Function SystemAttribute(s:String):Boolean;


Function GetShkalaSkidka(Art:ArtikulStr;Var Skidka:TDAteString):Boolean;
Procedure AverageMarket(DDD: TKolString; BakKol,BAkZena,NewKol,NewZena:AllStr; Var AverageZena:AllStr);


Function TestAgent(Cod:ArtikulStr):Boolean;
Procedure FindLink1(Art:ArtikulStr; LinkList:PBox; Space:String; Var Txt:Text);

Procedure CalcSpecialKassa( Var
    OtkatS,
    AllSumma,
    OstatokConsigT,
    SkidkiOstatokConsig,
    OstatokConsigTSF,
    SkidkiOstatokConsigSF,
    AllZakupka,
    AllAkzis,
    ProdagiCAkzis,
    ProdagiSAkzis,
    ProdagiBAkzis,
    VidanoConsigAkzis,
    OformlenoConsigAkzis,
    PrihodCAkzis,
    PrihodSAkzis,
    PrihodBAkzis,
    ReturnCAkzis,
    ReturnSAkzis,
    RevisiaAkZis,
    ReportKassa,
    AllDolgZ,
    AllPrihodC,
    AllPrihodS,
    AllPrihodB,
    AllRewisia,
    AllReturn,
    MinusDohod,
    AllDohod,
    AllDohodA,
    AllDohodB,
    AllDohodS,
    OtgruzkaZC,
    OtgruzkaZS,
    OtgruzkaZB,
    OtgruzkaZRP
    (*,
    OstatokCZ*): AllStr;
    Var InpZ,OutZ:TItogString;
    Var
       AllZakupka2, {PrihodZC2}
       AllPrihodC2, {PrihodZS2}
       AllPrihodS2, {PrihodZB2}
       AllPrihodB2, {OstatokZ2}
       AllRewisia2, {RewisiaZ2}
       AllReturn2,  {ReturnZ2}
       MinusDohod2, {MinusDohod2}
       AllDohod2,   {AllDohod2}
       AllDohodA2,  {AllDohodA2}
       AllDohodB2,  {AllDohodB2}
       AllDohodS2,  {AllDohodS2}
       OtgruzkaZC2, {OtgruzkaZC2}
       OtgruzkaZS2, {OtgruzkaZS2}
       OtgruzkaZB2, {OtgruzkaZB2}
       OtgruzkaZRP2,{OtgruzkaZRP2}
       OstatokAZ,   {OstatokAZ}
       OstatokAZ2,  {OstatokAZ2}
       OstatokNZ,   {OstatokNZ}
       OstatokNZ2:AllStr;{OstatokNZ2}
	  VAr
	  InpZ2,       {PerewoskiInpZ2}
	  Outz2:TItogString);{PerewoskiOutz2}


Procedure SetupVidZakupka;
Function SelOtkuda:Word;
Function SelectEditRegim:Word;


implementation

Uses Serv,Objects,DbEngine,MsgBox,NetDbEng,Protect,Editors,TpDate,NetCall,
     CPrihod,Mail,Printers,Utils5,Utils4,Utils6,Access1,DbEngin2,ServStr2,
     Utils11,
     Views,ColorTxt,Validate,App,Utils,DOS,Vision1,MrkTools;

{Const amReadOnly=0;}

Var LArt : ArtikulStr;
    LinkWindow : PLinkWindow;
    LinkMarkaWindow : PLinkMarkaWindow;
    LinkExpertWindow : PLinkExpertWindow;
    LinkKSertifWindow : PLinkKSertifWindow;
    LinkWindowG : PLinkGroupWindow;
    LinkList,NoScreenList1: PBox;
    LinkList1,NoScreenList2: PBox;
    ControlCount,ControlCount1,
    ControlCount3,ControlSelector,
    ControlVidOtboraG,ControlVidOtboraG3,
    ControlVidOtboraG1,ControlGroup,
    ControlGroup1,
    ControlKSertif,ControlKSertif1,
    ControlVidOtbora1,ControlVidOtbora3,ControlVidOtbora : PView;
    VidOtbora,VidOtbora1,VidProsmotra,Otobragenie : Word;
    ControlHeader,ControlOtobragenie : PView;
    ControlNGTD,ControlNGTD3,ControlNGTD1,ControlMarka1,ControlMarka3,ControlMarka,
    ControlVirabotano,ControlVirabotano3,ControlVirabotano1,ControlDo,ControlDo1,
    ControlDo3   : PView;
    CurrentLine : String;
    VidSkidki : AllStr;
    ReturnCount : Word;



Procedure FindLink1(Art:ArtikulStr; LinkList:PBox; Space:String; Var Txt:Text);
Label 1;
var
  Skl  : PSkladType;
  C,i,k : Word;
  ss,s,St : String;
  Find : Boolean;
  SMarka,SNGTD : AllStr;
Begin
Find := False;

1:

If Not TestElement(Art,LinkList) Then
For c :=0 To LinkList^.List^.Count Do
Begin
st:=LinkList^.GetText(c,LinkList^.List^.Count);
k:=Pos('│',St);

S:=Copy(St,K+1,CArtikul);
{
If (StrToInt(s)=85348)  Then
 Begin
  MemC('1');
 End;}
{MemC(s+' '+Art);}
If S=Art Then
    Begin
            ST:=Copy(St,K+1+CArtikul+1,CArtikul);
            LinkList^.List^.AtFree(C);
            LinkList^.SetRange(LinkList^.List^.Count);

            {MemC(St);}
            Find:=True;
            new(Skl,Init);
            Skl^.Dat.BazKod:=st;
            GetSkladRecord(Skl);
            s[0]:=#0;
            st:=GetIdField(FFFName,Skl^.Dat.BazKod);
            DelSpaceRight(st);
            s:=st;
            Format(s,CName+1+CNAme);
            DelSpace(Skl^.Dat.Input.Kol);
            RFormat(Skl^.Dat.Input.Kol,CKol);
            s:=Skl^.Dat.BazKod+' '+s+' '+Skl^.Dat.Input.Kol;
            Writeln(txt,Space+s);

            SNGTD:=Skl^.Dat.Input.NGTD;

            If (StrToInt(sNGTD)<>StrToInt(NoNGTDStr))  Then
            Begin
             s:=GetNGTDField(FNGTD,SNGTD);
             DelSpaceRight(s);
            End;

            SMarka:=Skl^.Dat.Input.Marka;

            If (StrToInt(sMarka)<>StrToInt(NoMarkaStr))  Then
            Begin
            ss:=GetMarkaField(FMarka,SMarka);
            DelSpaceRight(ss);
            End;
            {Format(s,CNSertif-5);}

            If (StrToInt(sMarka)<>StrToInt(NoMarkaStr)) Or
		  (StrToInt(sNGTD)<>StrToInt(NoNGTDStr)) Then
           Begin
            If (StrToInt(sNGTD)<>StrToInt(NoNGTDStr))  Then
             Write(txt,Space+'ГТД: '+s+' ('+SNGTD+')');


            If (StrToInt(sMarka)<>StrToInt(NoMarkaStr)) Then
             Begin
              If (StrToInt(sMarka)<>StrToInt(NoMarkaStr)) Then
		    Writeln(txt,' Акциз: '+ss+' ('+SMarka+')')
              Else
		    Writeln(txt,Space+' Акциз: '+ss+' ('+SMarka+')')
             End
               Else
                 Writeln(txt);
           End;

            {
            s:='ГТД: '+Skl^.Dat.Input.NGTD+' Акциз: '+Skl^.Dat.Input.Marka;
            Writeln(txt,Space+s);
            }

            DelSpaceRight(Skl^.Dat.Input.Virabotano);
            DelSpaceRight(Skl^.Dat.Input.Godnost);

            If (Skl^.Dat.Input.Godnost[0]<>#0) Or (Skl^.Dat.Input.Virabotano[0]<>#0) Then
           Begin
            If Skl^.DAt.Input.Virabotano[0]<>#0 Then
             Write(txt,Space+'Выработано: '+Skl^.Dat.Input.Virabotano);

               If Skl^.Dat.Input.Godnost[0]<>#0 Then
                Begin
                 If s[0]<>#0 Then Writeln(txt,' Реализовать до: '+Skl^.Dat.Input.Godnost)
                 Else Writeln(txt,Space+' Реализовать до: '+Skl^.Dat.Input.Godnost)
                End
               Else
                 Writeln(txt);
           End;
{           DelSpaceRight(Skl^.Dat.Input.Virabotano);
            DelSpaceRight(Skl^.Dat.Input.Godnost);

            If (Skl^.Dat.Input.Virabotano[0]<>#0) Or (Skl^.Dat.Input.Godnost[0]<>#0) Then
            Writeln(txt,Space+'Выработано: '+Skl^.Dat.Input.Virabotano+
                  '   Реализовать до: '+Skl^.Dat.Input.Godnost);}
            Dispose(Skl,Done);
            Goto 1;
   End{If St=s}
End;{For}
  If Find Then
  Writeln(txt,Space+'     -------------------------------------------------------------------');
End;




Function SelSkidka:Word;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelSkidka:=2;
R.Assign(30, 9, 49, 13);
New(Dlg, Init(R, ''));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 18, 3);
Control := New(PRadioButtons, Init(R,
  NewSItem('~Т~овар',
  NewSItem('~С~ертификаты', Nil))));
Dlg^.Insert(Control);

C:=0;

Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=DeskTop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(c);
  SelSkidka:=c;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End
Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
end;


Function SelZeni:Word;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelZeni:=3;
R.Assign(30, 9, 49, 14);
New(Dlg, Init(R, ''));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 18, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('~Р~озничная',
  NewSItem('Закупка ~1~',
  NewSItem('Закупка ~2~',
  Nil)))));
Dlg^.Insert(Control);

C:=0;

Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=DeskTop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(c);
  SelZeni:=c;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End
Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  SelZeni:=3;
 End;

end;


Function SelContrAgent:Word;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelContrAgent:=4;
R.Assign(22, 8, 57, 14);
New(Dlg, Init(R, ''));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;

R.Assign(1, 1, 34, 5);
Control := New(PRadioButtons, Init(R, 
  NewSItem('~К~лиенты',
  NewSItem('~В~нутренние подразделения',
  NewSItem('~П~оставщики',
  NewSItem('П~о~ставщики по взаимозачетам', Nil))))));
Dlg^.Insert(Control);

C:=0;

Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=DeskTop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(c);
  SelContrAgent:=c;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End
Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  SelContrAgent:=4;
 End;

end;




Function FiltrDocument1(VAr V:Word) :Boolean ;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c: Word;
begin
FiltrDocument1:=False;
R.Assign(25, 9, 55, 14);
New(Dlg, Init(R, 'Фильтр документов'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

R.Assign(1, 1, 29, 4);
Control := New(PCheckboxes, Init(R,
  NewSItem('С~п~',
  NewSItem('~Т~Ч*',
  NewSItem('Ф~Л~*',
  NewSItem('~С~Ф*',
  NewSItem('СФБ',
  NewSItem('~Д~*',
  NewSItem('ДС~Ф~',
  NewSItem('Д',
  NewSItem('ДСФБ', Nil)))))))))));

Dlg^.Insert(Control);
Dlg^.SelectNext(False);
Dlg^.SetData(V);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(V);
  FiltrDocument1:=True;
 End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
end;


Function FiltrRashet(VAr V:Word) :Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c: Word;
begin
FiltrRashet:=False;
R.Assign(30, 9, 49, 14);
New(Dlg, Init(R, 'Расчет'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

R.Assign(1, 1, 18, 4);
Control := New(PCheckboxes, Init(R,
  NewSItem('~Н~аличный',
  NewSItem('~Б~езналичный',
  NewSItem('~В~ексель', Nil)))));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetData(V);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(V);
  FiltrRashet:=True;
 End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
end;

Procedure TestMemo;
var
  DataRec : record
    Field1 : Word;
    Field2 : Array[1..500] of Char;
  end;
  Dlg : PDialog;
  R : TRect;
  Control, Control1 : PView;
  ControlM : PMemo;
  c : Word;
Begin
For c:=1 To 15 Do
DataRec.Field2[c]:=Chr(c+49);
DataRec.Field1:=15;

R.Assign(13, 6, 67, 17);
New(Dlg, Init(R, 'Тест'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(52, 2, 53, 9);
Control := New(PScrollBar, Init(R));
Dlg^.Insert(Control);

R.Assign(2, 9, 52, 10);
Control1 := New(PScrollBar, Init(R));
Dlg^.Insert(Control1);

R.Assign(2, 2, 52, 9);
ControlM := New(PMemo, Init(R, PScrollbar(Control1), PScrollbar(Control), Nil, 500,False));
ControlM^.Options := ControlM^.Options or ofFramed;
Dlg^.Insert(ControlM);

  R.Assign(2, 1, 15, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Комментарий:', ControlM)));

Dlg^.SetData(DataRec);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(DataRec);
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
End;





Procedure CalcSpecialKassa( Var
    OtkatS,
    AllSumma,
    OstatokConsigT,
    SkidkiOstatokConsig,
    OstatokConsigTSF,
    SkidkiOstatokConsigSF,
    AllZakupka,
    AllAkzis,
    ProdagiCAkzis,
    ProdagiSAkzis,
    ProdagiBAkzis,
    VidanoConsigAkzis,
    OformlenoConsigAkzis,
    PrihodCAkzis,
    PrihodSAkzis,
    PrihodBAkzis,
    ReturnCAkzis,
    ReturnSAkzis,
    RevisiaAkZis,
    ReportKassa,
    AllDolgZ,
    AllPrihodC,
    AllPrihodS,
    AllPrihodB,
    AllRewisia,
    AllReturn,
    MinusDohod,
    AllDohod,
    AllDohodA,
    AllDohodB,
    AllDohodS,
    OtgruzkaZC,
    OtgruzkaZS,
    OtgruzkaZB,
    OtgruzkaZRP
    (*,
    OstatokCZ*): AllStr;
    Var InpZ,OutZ:TItogString;
    Var
       AllZakupka2, {PrihodZC2}
       AllPrihodC2, {PrihodZS2}
       AllPrihodS2, {PrihodZB2}
       AllPrihodB2, {OstatokZ2}
       AllRewisia2, {RewisiaZ2}
       AllReturn2,  {ReturnZ2}
       MinusDohod2, {MinusDohod2}
       AllDohod2,   {AllDohod2}
       AllDohodA2,  {AllDohodA2}
       AllDohodB2,  {AllDohodB2}
       AllDohodS2,  {AllDohodS2}
       OtgruzkaZC2, {OtgruzkaZC2}
       OtgruzkaZS2, {OtgruzkaZS2}
       OtgruzkaZB2, {OtgruzkaZB2}
       OtgruzkaZRP2,{OtgruzkaZRP2}
       OstatokAZ,   {OstatokAZ}
       OstatokAZ2,  {OstatokAZ2}
       OstatokNZ,   {OstatokNZ}
       OstatokNZ2:AllStr;{OstatokNZ2}
	  VAr
	  InpZ2,       {PerewoskiInpZ2}
	  Outz2:TItogString);{PerewoskiOutz2}


VAr sklFile : File;
    PF : PrihodFileType;
    E : PPrihodType;
    RF : RewisiaFileType;
    RE : PRewisiaType;
    vF : NewVozwratFileType;
    vE : PNewVozwratType;
    vO : File;
    mF : File;
    me : PBufSuperMarketTypeIDX;
    vEO: PBufOplataRealizasiaType;
    skl : PBufSkladTypeNew;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    F : Boolean;
    c,c1 : Word;
    ch : LongInt;
    ws : String;
    k,All : LongInt;
    St,w: AllStr;
    R : TRect;
    ClientList : PBox;
    ClientFile : File;
    ClientElement : PBufKurzClientType;
    RealFile : File;
    DE : PBufRealizasiaType;
    ii : LongInt;
    Cur,cc,Count,
    BakFileMode : Word;
    SArtik : ArtikulStr;
Begin
OtKatS[0]:=#0;
AllDolgZ[0]:=#0;
AllZakupka[0]:=#0;
AllSumma[0]:=#0;
AllAkzis[0]:=#0;
OstatokConsigT[0]:=#0;
SkidkiOstatokConsig[0]:=#0;
OstatokConsigTSF[0]:=#0;
SkidkiOstatokConsigSF[0]:=#0;

PrihodCAkzis[0]:=#0;
PrihodSAkzis[0]:=#0;
PrihodBAkzis[0]:=#0;
RevisiaAkZis[0]:=#0;
ReturnCAkzis[0]:=#0;
ReturnSAkzis[0]:=#0;
ProdagiSAkzis[0]:=#0;
ProdagiBAkzis[0]:=#0;

ReportKassa[0]:=#0;

ProdagiCAkzis[0]:=#0;
VidanoConsigAkzis[0]:=#0;
OformlenoConsigAkzis[0]:=#0;



AllPrihodC[0]:=#0;
AllPrihodS[0]:=#0;
AllPrihodB[0]:=#0;
AllRewisia[0]:=#0;
AllReturn[0]:=#0;
MinusDohod[0]:=#0;
AllDohod[0]:=#0;
AllDohodA[0]:=#0;
AllDohodB[0]:=#0;
AllDohodS[0]:=#0;


OtgruzkaZC [0]:=#0;
OtgruzkaZS [0]:=#0;
OtgruzkaZB [0]:=#0;
OtgruzkaZRP[0]:=#0;

AllZakupka2[0]:=#0;
AllPrihodC2[0]:=#0;
AllPrihodS2[0]:=#0;
AllPrihodB2[0]:=#0;
AllRewisia2[0]:=#0;
AllReturn2[0]:=#0;
MinusDohod2[0]:=#0;
AllDohod2[0]:=#0;
AllDohodA2[0]:=#0;
AllDohodB2[0]:=#0;
AllDohodS2[0]:=#0;
OtgruzkaZC2[0]:=#0;
OtgruzkaZS2[0]:=#0;
OtgruzkaZB2[0]:=#0;
OtgruzkaZRP2[0]:=#0;

OstatokAZ[0]:=#0;
OstatokAZ2[0]:=#0;
OstatokNZ[0]:=#0;
OstatokNZ2[0]:=#0;



(*OstatokCZ[0]:=#0;*)

For c:=1 To 15 Do
Begin
 InpZ[c,0]:=#0;
 InpZ2[c,0]:=#0;
 OutZ[c,0]:=#0;
 OutZ2[c,0]:=#0;
End;{For}

 BakFileMode:=FileMode;
 FileMode:=ReadOnlyN;
{расчитываем остаток по закупочным ценам}
c:=IOResult;
Assign(RazdelFile,Path^.Dat.ToRazdel+'Razdel.db');
Reset(RazdelFile);
c:=IOResult;
FileMode:=BakFileMode;
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

   Assign(SklFile,Path^.Dat.ToIndex+RazdelElement.Kod+'.kdx');
   c:=IOResult;
   BakFileMode:=FileMode;
   FileMode:=$42;
   Reset(SklFile,SizeOf(SkladTypeNew));
   c:=IOResult;
   FileMode:=BakFileMode;
If c<>0 Then
 Begin
  Close(RazdelFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToSklad+RazdelElement.Kod+'.db',Nil,mfError+mfCancelButton);
  Exit;
 End;
   ch:=0;
   While Not(Eof(sklFile)) Do
    Begin
     New(Skl,Init);
     Count:=0;
     ReadBufNewSklad(SklFile,Skl,Count);
For cc:=1 To Count Do
Begin
     With Skl^.Point.Dat[cc] Do
     Begin
      All:=0;

      For k:=1 To CDivision Do
        Begin
           All:=All+Division[k];
        End;

     Skl^.Point.Dat[cc].Kol:=All;

     Str(Skl^.Point.Dat[cc].Zakupka*
             Skl^.Point.Dat[cc].Kol+StrToReal(AllZakupka):CIZena:CMantissaZ,AllZakupka);

     Str(Skl^.Point.Dat[cc].Zakupka2*
             Skl^.Point.Dat[cc].Kol+StrToReal(AllZakupka2):CIZena:CMantissaZ,AllZakupka2);

     Str(Skl^.Point.Dat[cc].R_Zena*
             Skl^.Point.Dat[cc].Kol+StrToReal(AllSumma):CIZena:CMantissaZ,AllSumma);

     If Skl^.Point.Dat[cc].RegionMarka=1 Then
      Begin
       Str(Skl^.Point.Dat[cc].Zakupka*
            Skl^.Point.Dat[cc].Kol+StrToReal(OstatokAZ):CIZena:CMantissaZ,OstatokAZ);
       Str(Skl^.Point.Dat[cc].Zakupka2*
            Skl^.Point.Dat[cc].Kol+StrToReal(OstatokAZ2):CIZena:CMantissaZ,OstatokAZ2);
      End
      Else
      Begin
       Str(Skl^.Point.Dat[cc].Zakupka*
            Skl^.Point.Dat[cc].Kol+StrToReal(OstatokNZ):CIZena:CMantissaZ,OstatokNZ);
       Str(Skl^.Point.Dat[cc].Zakupka2*
            Skl^.Point.Dat[cc].Kol+StrToReal(OstatokNZ2):CIZena:CMantissaZ,OstatokNZ2);
      End;


     If Skl^.Point.Dat[cc].RegionMarka=1 Then
     Str(Skl^.Point.Dat[cc].AkzisSbor*
             Skl^.Point.Dat[cc].Kol+StrToReal(AllAkzis):CIZena:CMantissaZ,AllAkzis);
     End;{With}
End;
    Dispose(Skl,Done);
   End;{While}

   c:=IOResult;
   Close(SklFile);
   c:=IOResult;
   End;
 End;


   c:=IOResult;
Close(RazdelFile);
   c:=IOResult;

{приход на склад по закупке от всех поставщиков}
Assign(Pf,Path^.Dat.ToPrihod+FDate+'.prh');
   c:=IOResult;
   BakFileMode:=FileMode;
   FileMode:=ReadOnlyN;
Reset(Pf);
   c:=IOResult;
   FileMode:=BakFileMode;
If c=0 Then
 Begin
  New(E,Init);
  While Not(Eof(PF)) Do
   Begin
    ReadPrihod(Pf,E);

    If E^.Dat.OperatorSelector = 0 Then
    Begin
    Str(StrToReal(E^.Dat.SummaZakupka)+
           StrToREal(AllPrihodC):CIZena:CMantissaZ,AllPrihodC);

    Str(StrToReal(E^.Dat.SummaZakupka2)+
           StrToREal(AllPrihodC2):CIZena:CMantissaZ,AllPrihodC2);

    Str(StrToReal(E^.Dat.SummaAkzis)+
           StrToREal(PrihodCAkzis):CIZena:CMantissaZ,PrihodCAkzis);
    End;

    If E^.Dat.OperatorSelector = 1 Then
    begin
    Str(StrToReal(E^.Dat.SummaZakupka)+
           StrToREal(AllPrihodS):CIZena:CMantissaZ,AllPrihodS);

    Str(StrToReal(E^.Dat.SummaZakupka2)+
           StrToREal(AllPrihodS2):CIZena:CMantissaZ,AllPrihodS2);

    If StrToInt(E^.Dat.MakeKod)<>StrToInt(ClientRP) Then
    Str(StrToReal(E^.Dat.SummaZakupka)+
           StrToREal(InpZ[Strtoint(E^.Dat.MakeKod)]):CIZena:CMantissaZ,InpZ[Strtoint(E^.Dat.MakeKod)]);


    If StrToInt(E^.Dat.MakeKod)<>StrToInt(ClientRP) Then
    Str(StrToReal(E^.Dat.SummaZakupka2)+
           StrToREal(InpZ2[Strtoint(E^.Dat.MakeKod)]):CIZena:CMantissaZ,InpZ2[Strtoint(E^.Dat.MakeKod)]);


    Str(StrToReal(E^.Dat.SummaAkzis)+
           StrToREal(PrihodSAkzis):CIZena:CMantissaZ,PrihodSAkzis);

    end;

    If E^.Dat.OperatorSelector = 2 Then
    Begin
    Str(StrToReal(E^.Dat.SummaZakupka)+
           StrToREal(AllPrihodB):CIZena:CMantissaZ,AllPrihodB);


    Str(StrToReal(E^.Dat.SummaZakupka2)+
           StrToREal(AllPrihodB2):CIZena:CMantissaZ,AllPrihodB2);

    Str(StrToReal(E^.Dat.SummaAkzis)+
           StrToREal(PrihodBAkzis):CIZena:CMantissaZ,PrihodBAkzis);
    End;

   End;
  Dispose(E,Done);
   c:=IOResult;
   Close(PF);
   c:=IOResult;
 End;


{ревизия на складе по закупке}
Assign(Rf,Path^.Dat.ToRewisia+FDate+'.rwz');
c:=IOResult;
BakFileMode:=FileMode;
FileMode:=ReadOnlyN;
Reset(Rf);
c:=IOResult;
FileMode:=BAkFileMode;
If c=0 Then
 Begin
  New(RE,Init);
  While Not(Eof(RF)) Do
   Begin
    ReadRewisia(Rf,RE);
    Str(StrToReal(RE^.Dat.ItogoZ)+
           StrToREal(AllRewisia):CIZena:CMantissaZ,AllRewisia);

    Str(StrToReal(RE^.Dat.ItogoZ2)+
           StrToREal(AllRewisia2):CIZena:CMantissaZ,AllRewisia2);

    Str(StrToReal(RE^.Dat.ItogoAkzis)+
           StrToREal(RevisiaAkZis):CIZena:CMantissaZ,RevisiaAkZis);
   End;
  Dispose(RE,Done);
   c:=IOResult;
   Close(RF);
   c:=IOResult;
 End;


{возврат на складе по закупке}
{упущенный доход}
Assign(vf,Path^.Dat.ToReturn+FDate+'.vzw');
   c:=IOResult;
   BakFileMode:=FileMode;
   FileMode:=ReadOnlyN;
Reset(vf);
   c:=IOResult;
   FileMode:=BakFileMode;

If c=0 Then
 Begin
  New(vE,Init);
  While Not(Eof(vF)) Do
   Begin
    ReadNewVozwrat(vf,vE);
    Str(StrToReal(vE^.Dat.SummaZakupka)+
           StrToREal(AllReturn):CIZena:CMantissaZ,AllReturn);

    Str(StrToReal(vE^.Dat.SummaZakupka2)+
           StrToREal(AllReturn2):CIZena:CMantissaZ,AllReturn2);

    Str(StrToReal(vE^.Dat.Delta)+
           StrToREal(MinusDohod)-StrToReal(vE^.Dat.SummaAkzis):CIZena:CMantissaZ,MinusDohod);


    Str(StrToReal(vE^.Dat.Delta2)+
           StrToREal(MinusDohod2)-StrToReal(vE^.Dat.SummaAkzis):CIZena:CMantissaZ,MinusDohod2);

    If Ve^.Dat.OperatorSelector=0 Then
    Str(StrToReal(vE^.Dat.SummaAkzis)+
           StrToREal(ReturnCAkzis):CIZena:CMantissaZ,ReturnCAkzis);

    If Ve^.Dat.OperatorSelector=1 Then
    Str(StrToReal(vE^.Dat.SummaAkzis)+
           StrToREal(ReturnSAkzis):CIZena:CMantissaZ,ReturnSAkzis);


   End;
  Dispose(vE,Done);
   c:=IOResult;
   Close(vF);
   c:=IOResult;
 End;



{оплаты консигнации по товарным чекам для сверки с отчетом по ккм}
{упущенный доход}
Assign(vo,Path^.Dat.ToOplata+FDate+'.opl');
   c:=IOResult;
   BakFileMode:=FileMode;
   FileMode:=ReadOnlyN;
 Reset(vo,SizeOf(OplataRealizasiaType));
   c:=IOResult;
   FileMode:=BakFileMode;

If c=0 Then
 Begin
  While Not(Eof(vO)) Do
   Begin
   New(vEO,Init);
   ReadBufOplata(vO,VeO,Count);
   For c1:=1 To Count Do
   Begin
   If (Veo^.Point.Dat[c1].SkladKod=Rek^.Dat.Kod) Then
   If Not(VeO^.Point.Dat[c1].Vozwrat) Then
    If Not TestSf(VeO^.Point.Dat[c1].ClientKod,VeO^.Point.Dat[c1].Document,VeO^.Point.Dat[c1].DateDoc) Then
    If (VeO^.Point.Dat[c1].Rashet=0) Then
     Begin
      Str(StrToReal(ReportKassa)+StrToReal(VeO^.Point.Dat[c1].SummaZ)
	 :CIZena:CMAntissa,
         ReportKassa);
     End;
   End;{For}
  Dispose(vEO,Done);
   End;{While}
   c:=IOResult;
   Close(vO);
   c:=IOResult;
 End;


{доходность по отгрузке}
Assign(mf,Path^.Dat.ToMarketIndex+FDate+'.mrx');
c:=IOResult;
   BakFileMode:=FileMode;
   FileMode:=$42;
Reset(mf,{SizeOf(SuperMarketType)}SizeOf(SuperMarketTypeIDX));
c:=IOResult;
   FileMode:=BakFileMode;

If c=0 Then
 Begin
  While Not(Eof(mF)) Do
   Begin
    New(mE,Init);
    {ReadBufMarket}ReadBufHeaderMarket(mf,me,Count);
For cc:=1 To Count Do
Begin
   {ReadMarket(mf,mE);}

   If (me^.Point.Dat[cc].Active) Then
   Begin
     If (ME^.Point.Dat[cc].OperatorSelector in [0,2]) Then
    Begin
     {подсчитываем сумму по суточному кассовому отчету за товар}

     If ((ME^.Point.Dat[cc].DocSelector in [0,1]) And Not(ME^.Point.Dat[cc].Realiz) And (ME^.Point.Dat[cc].Rashet=0)) Then
     Begin
      Str(StrToReal(ReportKassa)+ME^.Point.Dat[cc].SummaZ:CIZena:CMAntissa,
         ReportKassa);
     End;


     {подсчитываем сумму по суточному кассовому отчету за сертификаты}

     If (Not(ME^.Point.Dat[cc].Realiz) And (ME^.Point.Dat[cc].DocSelector in [0,1,2,3,4]) )
	   Or (ME^.Point.Dat[cc].DocSelector in [5,6,7,8]) Then
     Begin
      Str(StrToReal(ReportKassa)+ME^.Point.Dat[cc].SertifSummaZ
	 :CIZena:CMAntissa,
         ReportKassa);
     End;
   End;{Active}
  End;{OperatorSelector}


   If (ME^.Point.Dat[cc].OperatorSelector=0) Then
   Begin
    If (me^.Point.Dat[cc].Active) Then
    Begin

     If ((ME^.Point.Dat[cc].DocSelector in [0,1,2,3,4]) And Not(ME^.Point.Dat[cc].Realiz)) Or
        (ME^.Point.Dat[cc].DocSelector in [5,6,7,8]) Then
     Begin

      If StrToInt(me^.Point.Dat[cc].AgentKod)=0 Then
      Begin
        Str(mE^.Point.Dat[cc].SummaZ-
           mE^.Point.Dat[cc].SummaZakupka-
           mE^.Point.Dat[cc].SummaAkzis+
           StrToREal(AllDohod):CIZena:CMantissaZ,AllDohod);

           Str(mE^.Point.Dat[cc].SummaZ-
           mE^.Point.Dat[cc].SummaZakupka2-
           mE^.Point.Dat[cc].SummaAkzis+
             StrToREal(AllDohod2):CIZena:CMantissaZ,AllDohod2);
      End
      Else
      Begin
         Str(mE^.Point.Dat[cc].SummaZ-
            mE^.Point.Dat[cc].SummaZakupka-
            mE^.Point.Dat[cc].SummaAkzis+
           StrToREal(AllDohodA):CIZena:CMantissaZ,AllDohodA);

         Str(mE^.Point.Dat[cc].SummaZ-
            mE^.Point.Dat[cc].SummaZakupka2-
            mE^.Point.Dat[cc].SummaAkzis+
           StrToREal(AllDohodA2):CIZena:CMantissaZ,AllDohodA2);
      End;

        Str(mE^.Point.Dat[cc].SummaZakupka+
           StrToREal(OtgruzkaZC):CIZena:CMantissaZ,OtgruzkaZC);


        Str(mE^.Point.Dat[cc].SummaZakupka2+
           StrToREal(OtgruzkaZC2):CIZena:CMantissaZ,OtgruzkaZC2);

     End;{DocSelector}

     {подсчитываем акцизный сбор без отсрочки}
     If ((ME^.Point.Dat[cc].DocSelector in [0,1,2,3,4]) And Not(ME^.Point.Dat[cc].Realiz))Then
     Begin
      Str(ME^.Point.Dat[cc].SummaAkzis+StrToReal(ProdagiCAkzis):
         CIZena:CMAntissaZ,ProdagiCAkzis);
     End;
     {подсчитываем акцизный сбор по выданной консигнации}
     If (ME^.Point.Dat[cc].DocSelector in [5,6,7,8]) Then
     Begin
      Str(ME^.Point.Dat[cc].SummaAkzis+StrToReal(VidanoConsigAkzis):CIZena:CMAntissaZ,
         VidanoConsigAkzis);
     End;
     {подсчитываем акцизный сбор по оформленной консигнации}
     If ((ME^.Point.Dat[cc].DocSelector in [0,1,2,3,4]) And (ME^.Point.Dat[cc].Realiz))Then
     Begin
      Str(ME^.Point.Dat[cc].SummaAkzis+StrToReal(OformlenoConsigAkzis):CIZena:CMAntissaZ,
         OformlenoConsigAkzis);
     End;



    End;{Active}
   End;{OperatorSelector=0}

   If (me^.Point.Dat[cc].Active) Then
   If (ME^.Point.Dat[cc].OperatorSelector in [2]) Then
   Begin
     {ацизный сбор бартер}
     Str(mE^.Point.Dat[cc].SummaAkzis+
       StrToREal(ProdagiBAkzis):CIZena:CMantissaZ,ProdagiBAkzis);

    If (me^.Point.Dat[cc].Active) Then
    Begin
     If ((ME^.Point.Dat[cc].DocSelector in [0,1,2,3,4]) And Not(ME^.Point.Dat[cc].Realiz)) Or
        (ME^.Point.Dat[cc].DocSelector in [5,6,7,8]) Then
     Begin
        Str(mE^.Point.Dat[cc].SummaZakupka+
           StrToREal(OtgruzkaZB):CIZena:CMantissaZ,OtgruzkaZB);

        Str(mE^.Point.Dat[cc].SummaZakupka2+
           StrToREal(OtgruzkaZB2):CIZena:CMantissaZ,OtgruzkaZB2);

        Str(mE^.Point.Dat[cc].SummaZ-
           mE^.Point.Dat[cc].SummaZakupka-
           mE^.Point.Dat[cc].SummaAkzis+
        StrToREal(AllDohodB):CIZena:CMantissaZ,AllDohodB);

        Str(mE^.Point.Dat[cc].SummaZ-
           mE^.Point.Dat[cc].SummaZakupka2-
           mE^.Point.Dat[cc].SummaAkzis+
        StrToREal(AllDohodB2):CIZena:CMantissaZ,AllDohodB2)

     End;{DocSelector}
    End;{Active}
   End;{OperatorSelector}

   If (ME^.Point.Dat[cc].OperatorSelector in [1]) Then
   Begin
    If (me^.Point.Dat[cc].Active) Then
    Begin
     {ацизный сбор межсклад и РП}
     Str(mE^.Point.Dat[cc].SummaAkzis+
       StrToREal(ProdagiSAkzis):CIZena:CMantissaZ,ProdagiSAkzis);
     If (ME^.Point.Dat[cc].DocSelector=0) Then
     Begin

       If StrToInt(Me^.Point.Dat[cc].ClientKod)<>StrToInt(ClientRP) Then
        Begin
         Str(mE^.Point.Dat[cc].SummaZakupka+
         StrToREal(OtgruzkaZS):CIZena:CMantissaZ,OtgruzkaZS);

         Str(mE^.Point.Dat[cc].SummaZakupka2+
         StrToREal(OtgruzkaZS2):CIZena:CMantissaZ,OtgruzkaZS2);

         Str(mE^.Point.Dat[cc].SummaZakupka+
         StrToREal(OutZ[Strtoint(mE^.Point.Dat[cc].ClientKod)]):CIZena:CMantissaZ,
            OutZ[StrToInt(mE^.Point.Dat[cc].ClientKod)]);

         Str(mE^.Point.Dat[cc].SummaZakupka2+
         StrToREal(OutZ2[Strtoint(mE^.Point.Dat[cc].ClientKod)]):CIZena:CMantissaZ,
            OutZ2[StrToInt(mE^.Point.Dat[cc].ClientKod)]);

        End
       Else
        Begin
         Str(mE^.Point.Dat[cc].SummaZakupka+
            StrToREal(OtgruzkaZRP):CIZena:CMantissaZ,OtgruzkaZRP);

         Str(mE^.Point.Dat[cc].SummaZakupka2+
            StrToREal(OtgruzkaZRP2):CIZena:CMantissaZ,OtgruzkaZRP2);
        End

     End;{DocSelector}
    End;{Active}
   End;{OperatorSelector}
End;{For}
   Dispose(mE,Done);
   End;{While}
   c:=IOResult;
   Close(mF);
   c:=IOResult;
 End;{c=0}




R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path^.Dat.ToClientBaseIndex+'Client.idx');
   BakFileMode:=FileMode;
   FileMode:={ReadOnlyN}$42;
c:=IOResult;
Reset (ClientFile,SizeOf(KurzClientType));
c:=IOResult;
FileMode:=BakFileMode;
If c=0 Then
Begin
While Not(Eof(ClientFile)) Do
 Begin

     New(ClientElement,Init);
     Count:=0;
     ReadBufKurzClient(ClientFile,ClientElement,Count);
For c:=1 To Count Do
Begin
  If ClientElement^.Point.Dat[c].Employ Then
 Begin
    SArtik:=IntToStr(ClientElement^.Point.Dat[c].Kod,CClientKod);
    RFormatZerro(SArtik,CClientKod);

    If Not(FExists(Path^.Dat.ToDolg+SArtik+'.dlg')) Then
    ClientElement^.Point.Dat[c].Employ:=False;

  If ClientElement^.Point.Dat[c].Employ Then
   Begin
    Format (ClientElement^.Point.Dat[c].Name,CClient);
    ClientList^.List^.Insert(NewStr(ClientElement^.Point.Dat[c].Name+'│'+
    SArtik));
    ClientList^.SetRange(ClientList^.List^.Count);
   End;
 End;
End;{For}
     Dispose(ClientElement,Done);


 End;{While}
System.Close(ClientFile);
End

Else
 Begin
  Dispose(ClientList,Done);
  Exit;
 End;




If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
    Assign(RealFile,Path^.Dat.ToDolg+st+'.dlg');
    ii:=IOResult;
    BakFileMode:=FileMode;
    FileMode:={ReadOnlyN}$42;
    Reset(RealFile,SizeOf(RealizasiaType));
    ii:=IOResult;
    FileMode:=BakFileMode;
    If ii=0 Then
     Begin
      While Not(Eof(RealFile)) Do
       Begin
        Count:=0;
        New(De,Init);
        BlockRead(RealFile,DE^.Point,BufferDLG,Count);

For cur:=1 To Count Do
Begin
        If (DE^.Point.Dat[Cur].Market.Active) Then
Begin
        If Not(DE^.Point.Dat[Cur].Full) Then
         Begin
          MyStr(DE^.Point.Dat[Cur].Market.SummaZakupka+StrToREal(AllDolgZ),CIZena,CMantissaZ,AllDolgZ);
          MyStr(DE^.Point.Dat[Cur].Dolg+
          DE^.Point.Dat[Cur].Market.Skidka+
		StrToREal(OstatokConsigT),CIZena,CMantissa,OstatokConsigT);
          MyStr(DE^.Point.Dat[Cur].Market.Skidka+StrToREal(SkidkiOstatokConsig),CIZena,CMantissa,
		SkidkiOstatokConsig);
          If (DE^.Point.Dat[Cur].Market.DocSelector in [6,8]) Then
           Begin
          MyStr(DE^.Point.Dat[Cur].Dolg+
          DE^.Point.Dat[Cur].Market.Skidka+
		StrToREal(OstatokConsigTSF),CIZena,CMantissa,OstatokConsigTSF);
          MyStr(DE^.Point.Dat[Cur].Market.Skidka+StrToREal(SkidkiOstatokConsigSF),CIZena,CMantissa,
		SkidkiOstatokConsigSF);
           End;
         End;

If Not(DE^.Point.Dat[Cur].FullOtkat) Then
If Abs(DE^.Point.Dat[Cur].Otkat)>=0.009 Then
 Begin
   MyStr(StrToReal(OtkatS)+DE^.Point.Dat[cur].Otkat,CIZena,CMantissa,OtkatS);
 End;

End;{active}


End;{For}
        Dispose(DE,Done);
       End;{While}
   ii:=IOResult;
      Close(RealFile);
   ii:=IOResult;
     End;{II=0}

   End;
 End;


Dispose(ClientList,Done);


End;





Procedure SetupVidZakupka;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  c1 : LongInt;
  VZ : Word;

begin
R.Assign(13, 9, 66, 14);
New(Dlg, Init(R, 'Обработка закупочных цен'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(1, 1, 52, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('~П~оследняя закупка',
  NewSItem('~С~редневзвешенная закупка ((a*b)+(c*d))/(a+c)',
  NewSItem('~Н~е изменять закупку (для возвратов по бартеру)', Nil)))));
Dlg^.Insert(Control);

Vz:=VidZakupka;
Dlg^.SelectNext(False);
Dlg^.SetData(VidZakupka);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
Begin
 Dlg^.GEtData(VidZakupka);
 WriteNewCfg(c1);
 If VZ<>VidZakupka Then
 AddProtocol('Изменение политики закупочных цен! {Очень важно!!! Закупочные цены}',
 'Было: '+IntToStr(VZ     ,COne),'Стало: '+IntToStr(VidZakupka,COne));
End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;




Function SelectVidRasheta(DocSelector,EditDocSelector:Word;
Var Rashet,EditRashet:Word):Boolean;
Label 1;

var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;

begin
1:
SelectVidRasheta:=False;
R.Assign(30, 9, 49, 14);
New(Dlg, Init(R, 'Расчет'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(1, 1, 18, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('~Н~аличный',
  NewSItem('~Б~езналичный',
  NewSItem('~В~ексель',
  Nil)))));


{запрет безнала}
If DocSelector in [0,1,2,3,5,7] Then
PCluster(Control)^.SetButtonState($00000002, False);

{запрет векселя}
If DocSelector in [0,1,2,3,5,7] Then
PCluster(Control)^.SetButtonState($00000002, False);

{запрет наличной оплаты}
If DocSelector in [4,8] Then
PCluster(Control)^.SetButtonState($00000001, False);

If Status=DocNormal Then
Begin
If InputZakaz<>2 Then
Begin
Case DocSelector Of
0:c:=0; {список}
1:c:=0; {товарный чек}
2:c:=0; {физ лицо}
3:c:=0; {с/ф}
4:c:=1; {б/н с/ф}
5:c:=0; {Дебит*}
6:c:=0; {Дебит СФ}
7:c:=0; {Дебит}
8:c:=1; {Дебит СФБ}
Else;
End;
End{InputZakaz<>2}
 Else
  Begin
Case DocSelector Of
0:c:=0; {список}
1:c:=0; {товарный чек}
2:c:=0; {физ лицо}
3:c:=0; {с/ф}
4:If (DocSelector in [4,8]) And (EditDocSelector in [4,8]) Then c:=EditRashet {б/н с/ф}
  Else c:=1;
5:c:=0; {Дебит*}
6:c:=0; {Дебит СФ}
7:c:=0; {Дебит}
8:If (DocSelector in [4,8]) And (EditDocSelector in [4,8]) Then c:=EditRashet {б/н с/ф}
  Else c:=1;
Else;
End;
  End;
End
 Else
 Begin
{ Writeln(DocSelector,' ',EditDocSelector,' ',EditRashet);
  Readln;}
Case DocSelector Of
0:c:=0; {список}
1:c:=0; {товарный чек}
2:c:=0; {физ лицо}
3:c:=0; {с/ф}
4:If (DocSelector in [4,8]) And (EditDocSelector in [4,8]) Then c:=EditRashet {б/н с/ф}
  Else c:=1;
5:c:=0; {Дебит*}
6:c:=0; {Дебит СФ}
7:c:=0; {Дебит}
8:If (DocSelector in [4,8]) And (EditDocSelector in [4,8]) Then c:=EditRashet {б/н с/ф}
  Else c:=1;
Else;
End;

 End;


Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetData(c);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(c);
  If EnableVeksel=0 Then
  If c=2 Then
 Begin
               MessageBox(^M+#3+'Вексельные операции запрещены!',Nil,mfWarning+mfCancelButton);
               Dispose(Control,Done);
               Dispose(Dlg,Done);
               Goto 1;
 End;
  Rashet:=c;
  SelectVidRasheta:=True;
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;


Function HiddenAttribute(s:String):Boolean;
var
 F: file;
 Attr: Word;
begin
 HiddenAttribute:=False;
 Assign(F, S);
 GetFAttr(F, Attr);
 if (Attr and Dos.Hidden <> 0) then HiddenAttribute:=True;
 Attr:=IOResult;
end;


Function SystemAttribute(s:String):Boolean;
var
 F: file;
 Attr: Word;
begin
 SystemAttribute:=False;
 Assign(F, S);
 GetFAttr(F, Attr);
 if (Attr and Dos.SysFile <> 0) then SystemAttribute:=True;
 Attr:=IOResult;
end;


Function GetShkalaSkidka(Art:ArtikulStr;Var Skidka:TDAteString):Boolean;
VAr Zena : TDateString;
      P  : PSkidkaType;
 MasZena : Array[1..CShkala] Of TDAteString;
     Dlg : PDialog;
       R : TRect;
 Control : PView;
       c : word;
Begin
GetShkalaSkidka:=False;
Skidka[0]:=#0;
Zena := BakGetField(FRZena,Art,0);
MyStr(StrToReal(Zena),CZena,CMantissa,Zena);
New(p,Init);
GetSkidka(Art,P^.Dat);

For c:=1 To CShkala Do
 Begin
  MyStr(StrToREal(Zena)/(1+StrToREal(P^.Dat.Skidka[c].Proz)/100),CZena,CMantissa,MasZena[c]);
 End;

R.Assign(27, 7, 53, 16);
New(Dlg, Init(R, 'Укажите шкалу'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(1, 1, 25, 8);
Control := New(PRadioButtons, Init(R,
  NewSItem('Шкала ~0~ ('+Zena+')',
  NewSItem('Шкала ~1~ ('+MasZena[1]+')',
  NewSItem('Шкала ~2~ ('+MasZena[2]+')',
  NewSItem('Шкала ~3~ ('+MasZena[3]+')',
  NewSItem('Шкала ~4~ ('+MasZena[4]+')',
  NewSItem('Шкала ~5~ ('+MasZena[5]+')',
  NewSItem('Шкала ~6~ ('+MasZena[6]+')',
  Nil)))))))));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
c:=0;
Dlg^.SetDAta(c);
c:=Desktop^.ExecView(Dlg);
If c<>CmCancel Then
 Begin
  Dlg^.GetData(c);
  If c<>0 Then
   Begin
    MyStr(StrToReal(Zena)-StrToReal(MasZena[c]),CZena,CMantissa,Skidka);
    DelSpace(Skidka);
   End
   Else
    Begin
     Skidka[0]:=#0;
    End;
  GetShkalaSkidka:=True;
 End;

Dispose(Control,Done);
Dispose(Dlg,Done);
End;




Procedure AverageMarket(DDD: TKolString; BakKol,BAkZena,NewKol,NewZena:AllStr; Var AverageZena:AllStr);
VAr c : Word;
Begin
CAse VidZakupka Of
{последняя закупка}
0:Begin
   MyStr(StrToReal(BakZena),CZenaZ,CMantissaZ,AverageZena);
   DelSpace(AverageZena);
  End;
{средневзвешенная закупка}
1:Begin

    If EnableAverageOtdel<>0 Then
    Begin
     BakKol[0]:=#0;
     For c:=1 To CDivision Do
      Begin
       If c in SetEnableOtdel Then
        Begin
         Str(StrToInt(BAkKol)+StrToInt(DDD[c]):CKol,BAkKol);
        End;
      End;
     DelSpace(BakKol);
    End;



    If (StrToInt(NewKol)+StrToInt(BakKol))>0 Then
    Begin
     MyStr(((StrToInt(NewKol)*StrToReal(NewZena)+
         StrToInt(BakKol)*StrToReal(BakZena))/(StrToInt(NewKol)+StrToInt(BakKol))),
            CZenaZ,CMantissaZ,AverageZena)
    End
    Else
    MyStr(StrToReal(BakZena),CZenaZ,CMantissaZ,AverageZena);
    DelSpace(AverageZena);
  End;
{оставить последнюю закупку}
2:Begin
   MyStr(StrToReal(BakZena),CZenaZ,CMantissaZ,AverageZena);
   DelSpace(AverageZena);
  End;
Else;
End;
End;





Function TestAgent(Cod:ArtikulStr):Boolean;
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





procedure TLinkWindow.Start(LinkArt:ArtikulStr);
var
  R : TRect;
  Control : PView;
  RazdelFile : RazdelFileType;
  RazdelElement : PRazdelType;
  FSkl : File;
  Skl  : PBufSkladTypeNew;
  Skl2 : PSkladType;
  Count,C,i : Word;
  SArtik : ArtikulStr;
  SKol : TDAteString;
  s,St : String;
  Find : Boolean;
begin
LArt:=LinkArt;

If Not(GetRazdelStatus(LinkArt)) Then
 Begin
  LArt:=BakGetField(FNSertif,LinkArt,0);
  LinkArt:=LArt;
 {MessageBox(^M+#3'Необходим сертификат, а не товар!',Nil,mfError+mfCancelButton);
  Exit;}
 End;


R.Assign(0,0,0,0);
NoScreenList1 := New(PBox, Init(R, 1, Nil));
NoScreenList1^.NewList(New(PTextCollection, Init(0,1)));


Assign(RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
i:=IOResult;
Reset(RazdelFile);
i:=IOResult;
Find:=False;
If i=0 Then
 Begin
  {DInfoMsg('Идет поиск связанных наименований...',True);}
  New(RazdelElement,Init);
  While Not(Eof(Razdelfile)) Do
   Begin
    Read(RazdelFile,RazdelElement^.Dat);

    DInfoMsgShkala('Идет поиск связанных наименований в разделе '+RazdelElement^.Dat.Kod+'. Ждите...',
    1,EmployRazdel,StrToInt(RazdelElement^.Dat.Kod)+1);
    If (RazdelElement^.Dat.Employ) And (Razdelelement^.Dat.EnableDoc=0) Then
     Begin
      Assign(FSkl,Path^.Dat.ToIndex+RazdelElement^.Dat.Kod+'.kdx');
      i:=ioresult;
      reset(fskl,SizeOf(SkladTypeNew));
      i:=ioresult;
      If i=0 Then
       Begin
        While Not(Eof(FSkl)) Do
         Begin
          New(Skl,Init);
          ReadBufNewSklad(FSkl,Skl,Count);
          For c:=1 To Count Do
Begin
          If Skl^.Point.Dat[c].Employ Then
          If Skl^.Point.Dat[c].NSertif=StrToInt(LinkArt) Then
           Begin
            Find:=True;
            s[0]:=#0;
            SArtik:=IntToStr(Skl^.Point.Dat[c].BazKod,CArtikul);
            RFormatZerro(SArtik,CArtikul);

            st:=GetIdField(FName,{Skl^.Point.Dat[c].BazKod}SArtik);
            DelSpaceRight(st);
            s:=st;
            st:=GetIdField(FName2,SArtik{Skl^.Point.Dat[c].BazKod});
            DelSpaceRight(st);
            s:=s+' '+st;
            Format(s,CName+1+CNAme);
            {DelSpace(Skl^.Point.Dat[c].Input.Kol);}

            SKol:=IntToStr(Skl^.Point.Dat[c].Kol,CKol);
            RFormat(SKol{Skl^.Point.Dat[c].Input.Kol},CKol);
            st:=CalcPack(SArtik{Skl^.Point.Dat[c].BazKod},SKol{Skl^.Point.Dat[c].Input.Kol});
            DelSpace(st);
            RFormat(st,CPAck);
            s:=s+'│'+SArtik{Skl^.Point.Dat[c].BazKod}+'│'+SKol{Skl^.Point.Dat[c].Input.Kol}+'│'+st;

            New(Skl2,Init);
            Skl2^.Dat.BazKod:=LinkArt;
            GetSkladRecord(Skl2);

            St:=GetMarkaField(FMarka,Skl2^.Dat.Input.Marka);
            Format(st,CMarka);
            s:=s+'│'+st;

            St:=GetNGTDField(FNGTD,Skl2^.Dat.Input.NGTD);
            Format(st,CNGTD);
            s:=s+'│'+st;

            If Skl^.Point.Dat[c].Virabotano=-1 Then
            St:='        '
            Else
            St:=DateToDateString(DateMask,Skl^.Point.Dat[c].Virabotano);

            {St:=Skl^.Point.Dat[c].Input.Virabotano;}
            Format(st,CDate);
            s:=s+'│'+st;

            St:=Skl2^.Dat.Input.Godnost;
            Format(st,CDate);
            s:=s+'│'+st;
            Dispose(Skl2,Done);

      If NoScreenList1^.List^.Count>=MaxCollectionSize-10 Then
      Begin
       MessageBox(^M+#3+'Переполнение коллекции!',Nil,mfError+mfCancelButton);
       Break;
      End;

            NoScreenList1^.List^.Insert(NewStr(s));
            NoScreenList1^.SetRange(NoScreenList1^.List^.Count);
           End;
End;{For}
         Dispose(Skl,Done);
         End;{While}
         System.Close(FSkl);
         {Dispose(Skl,Done);}
       End
       Else
        Begin
            NoInfoMsg;
            MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToSklad+RazdelElement^.Dat.Kod+'.db!'+
            ClicProgrammer^,Nil,mfError+mfCancelButton);
        End;
     End;
   End;
  NoInfoMsg;
  System.Close(RazdelFile);
  Dispose(RazdelElement,Done);
 End
Else
Begin
 MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToRazdel+'razdel.db! '+
            ClicProgrammer^,Nil,
            mfError+mfCancelButton);
 Exit;
End;


If Not(Find) Then
 Begin
  Dispose(NoScreenList1,Done);
  MessageBox(^M+#3'С данным сертификатом не связано ни одно наименование товара!',
             Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(1, 2, 79, 21);
New(LinkWindow, Init(R, ''));
LinkWindow^.Options := LinkWindow^.Options or ofCenterX or ofCenterY;
LinkWindow^.HelpCtx:=$F947{E607};

R.Assign(77, 4, 78, 16);
Control := New(PScrollBar, Init(R));
LinkWindow^.Insert(Control);

R.Assign(1, 4, 77, 16);
LinkList := New(PBox, Init(R, 1, PScrollbar(Control)));
LinkList^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList1^.List^.Count-1>=0 Then
 For c:=0 To NoScreenList1^.List^.Count-1 Do
  Begin
   s:=NoScreenList1^.GetText(c,NoScreenList1^.List^.Count);
   LinkList^.List^.Insert(NewStr(s));
   LinkList^.SetRange(LinkList^.List^.Count);
  End;
LinkList^.FocusItem(0);
LinkWindow^.Insert(LinkList);


  R.Assign(1, 3, 77, 4);
  LinkWindow^.Insert(New(PLabel, Init(R, 'Наименования товара, связанные с сертификатом          Код  Колич  Упаковок',
  LinkList)));

R.Assign(14, 1, 75, 2);
st:=GetIdField(FNAme,LinkArt);
s:=GetIdField(FNAme2,LinkArt);
DelSpaceRight(st);
DelSpaceRight(s);
st:=St+' '+s;
Control := New(PColoredText, Init(R, st+'('+LinkArt+')', $7E));
LinkWindow^.Insert(Control);

R.Assign(3, 1, 14, 2);
Control := New(PColoredText, Init(R, 'Сертификат:', $74));
LinkWindow^.Insert(Control);

R.Assign(8, 2, 14, 3);
Control := New(PColoredText, Init(R, 'Выдан:', $74));
LinkWindow^.Insert(Control);

st:=GetKSertifField(FKSertif,(GetIdField(FKtoSertif,LinkArt)));
DelSpaceRight(st);
R.Assign(14, 2, 54, 3);
Control := New(PColoredText, Init(R, st, $7E));
LinkWindow^.Insert(Control);

R.Assign(55, 2, 69, 3);
Control := New(PColoredText, Init(R, 'Срок действия:', $74));
LinkWindow^.Insert(Control);

st:=GetIdField(FDateSertif,LinkArt);
DelSpaceRight(st);
R.Assign(69, 2, 77, 3);
Control := New(PColoredText, Init(R, st, $7E));
LinkWindow^.Insert(Control);

R.Assign(2, 18, 25, 19);
ControlCount3 := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList^.List^.Count,CLitr+1), $4E));
LinkWindow^.Insert(ControlCount3);

R.Assign(1, 16, 16, 17);
Control := New(PColoredText, Init(R, 'Акцизная марка:', $74));
LinkWindow^.Insert(Control);

R.Assign(16, 16, 56, 17);
ControlMarka3 := New(PColoredText, Init(R, '???', $7E));
LinkWindow^.Insert(ControlMarka3);

R.Assign(7, 17, 47, 18);
ControlNGTD3 := New(PColoredText, Init(R, '???', $7E));
LinkWindow^.Insert(ControlNGTD3);

R.Assign(1, 17, 7, 18);
Control := New(PColoredText, Init(R, 'N ГТД:', $74));
LinkWindow^.Insert(Control);

R.Assign(58, 16, 69, 17);
Control := New(PColoredText, Init(R, 'Выработано:', $74));
LinkWindow^.Insert(Control);

R.Assign(69, 16, 77, 17);
ControlVirabotano3 := New(PColoredText, Init(R, '???', $7E));
LinkWindow^.Insert(ControlVirabotano3);

R.Assign(69, 17, 77, 18);
ControlDo3 := New(PColoredText, Init(R, '???', $7E));
LinkWindow^.Insert(ControlDo3);

R.Assign(54, 17, 69, 18);
Control := New(PColoredText, Init(R, 'Реализовать до:', $74));
LinkWindow^.Insert(Control);

VidOtbora:=0;

R.Assign(40, 18, 76, 19);
ControlVidOtbora := New(PRadioButtons, Init(R,
  NewSItem('~В~се',
  NewSItem('Не ну~л~евое количество', Nil))));
LinkWindow^.Insert(ControlVidOtbora);

ControlVidOtbora^.SetData(VidOtbora);

  R.Assign(28, 18, 40, 19);
  LinkWindow^.Insert(New(PLabel, Init(R, 'Вид отбора:', ControlVidOtbora)));

LinkWindow^.SelectNext(False);

CurrentLine[0]:=#0;
Refresh;
CurrentLine[0]:=#0;

c:=Desktop^.ExecView(LinkWindow);

Dispose(NoScreenList1,Done);
Dispose(Control,Done);
Dispose(LinkWindow,Done);
End;

(*

procedure TLinkWindow.Start(LinkArt:ArtikulStr);
var
  R : TRect;
  Control : PView;
  RazdelFile : RazdelFileType;
  RazdelElement : PRazdelType;
  FSkl : File;
  Skl  : PBufSkladType;
  Skl1 : PExtSkladType;
  Count,C,i : Word;

  s,St : String;
  Find : Boolean;
begin
LArt:=LinkArt;

If Not(GetRazdelStatus(LinkArt)) Then
 Begin
  LArt:=BakGetField(FNSertif,LinkArt,0);
  LinkArt:=LArt;
  {MessageBox(^M+#3'Необходим сертификат, а не товар!',Nil,mfError+mfCancelButton);
  Exit;}
 End;


R.Assign(0,0,0,0);
NoScreenList1 := New(PBox, Init(R, 1, Nil));
NoScreenList1^.NewList(New(PTextCollection, Init(0,1)));


Assign(RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
i:=IOResult;
Reset(RazdelFile);
i:=IOResult;
Find:=False;
If i=0 Then
 Begin
  {DInfoMsg('Идет поиск связанных наименований...',True);}
  New(RazdelElement,Init);
  While Not(Eof(Razdelfile)) Do
   Begin
    Read(RazdelFile,RazdelElement^.Dat);

    DInfoMsgShkala('Идет поиск связанных наименований в разделе '+RazdelElement^.Dat.Kod+'. Ждите...',
    1,EmployRazdel,StrToInt(RazdelElement^.Dat.Kod)+1);
    If (RazdelElement^.Dat.Employ) And (Razdelelement^.Dat.EnableDoc=0) Then
     Begin
      Assign(FSkl,Path^.Dat.ToSklad+RazdelElement^.Dat.Kod+'.db');
      i:=ioresult;
      reset(fskl,SizeOf(SkladType));
      i:=ioresult;
      If i=0 Then
       Begin
        While Not(Eof(FSkl)) Do
         Begin
          New(Skl,Init);
          ReadBufSklad(FSkl,Skl,Count);
          For c:=1 To Count Do
Begin
          If Skl^.Point.Dat[c].Employ Then
          If StrToInt(Skl^.Point.Dat[c].Input.NSertif)=StrToInt(LinkArt) Then
           Begin
            Find:=True;
            s[0]:=#0;
            st:=GetIdField(FName,Skl^.Point.Dat[c].BazKod);
            DelSpaceRight(st);
            s:=st;
            st:=GetIdField(FName2,Skl^.Point.Dat[c].BazKod);
            DelSpaceRight(st);
            s:=s+' '+st;
            Format(s,CName+1+CNAme);
            DelSpace(Skl^.Point.Dat[c].Input.Kol);
            RFormat(Skl^.Point.Dat[c].Input.Kol,CKol);
            st:=CalcPack(Skl^.Point.Dat[c].BazKod,Skl^.Point.Dat[c].Input.Kol);
            DelSpace(st);
            RFormat(st,CPAck);
            s:=s+'│'+Skl^.Point.Dat[c].BazKod+'│'+Skl^.Point.Dat[c].Input.Kol+'│'+st;

            New(Skl1,Init);
            Skl1^.Dat.BazKod:=Skl^.Point.Dat[c].BazKod;
            GetExtSkladRecord(Skl1);

            St:=Skl1^.Dat.Input.Marka;
            Format(st,CNSertif);
            s:=s+'│'+st;

            St:=Skl1^.Dat.Input.NGTD;
            Format(st,CNSertif);
            s:=s+'│'+st;

            St:=Skl^.Point.Dat[c].Input.Virabotano;
            Format(st,CDate);
            s:=s+'│'+st;

            St:=Skl1^.Dat.Input.Godnost;
            Format(st,CDate);
            s:=s+'│'+st;
            Dispose(Skl1,Done);

            NoScreenList1^.List^.Insert(NewStr(s));
            NoScreenList1^.SetRange(NoScreenList1^.List^.Count);
           End;
End;{For}
         Dispose(Skl,Done);
         End;{While}
         System.Close(FSkl);
         {Dispose(Skl,Done);}
       End
       Else
        Begin
            NoInfoMsg;
            MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToSklad+RazdelElement^.Dat.Kod+'.db!'+
            ClicProgrammer,Nil,mfError+mfCancelButton);
        End;
     End;
   End;
  NoInfoMsg;
  System.Close(RazdelFile);
  Dispose(RazdelElement,Done);
 End
Else
Begin
 MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToRazdel+'razdel.db! '+
            ClicProgrammer,Nil,
            mfError+mfCancelButton);
 Exit;
End;


If Not(Find) Then
 Begin
  Dispose(NoScreenList1,Done);
  MessageBox(^M+#3'С данным сертификатом не связано ни одно наименование товара!',
             Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(1, 2, 79, 21);
New(LinkWindow, Init(R, ''));
LinkWindow^.Options := LinkWindow^.Options or ofCenterX or ofCenterY;
LinkWindow^.HelpCtx:=$E607;

R.Assign(77, 4, 78, 16);
Control := New(PScrollBar, Init(R));
LinkWindow^.Insert(Control);

R.Assign(1, 4, 77, 16);
LinkList := New(PBox, Init(R, 1, PScrollbar(Control)));
LinkList^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList1^.List^.Count-1>=0 Then
 For c:=0 To NoScreenList1^.List^.Count-1 Do
  Begin
   s:=NoScreenList1^.GetText(c,NoScreenList1^.List^.Count);
   LinkList^.List^.Insert(NewStr(s));
   LinkList^.SetRange(LinkList^.List^.Count);
  End;
LinkList^.FocusItem(0);
LinkWindow^.Insert(LinkList);


  R.Assign(1, 3, 77, 4);
  LinkWindow^.Insert(New(PLabel, Init(R, 'Наименования товара, связанные с сертификатом          Код  Колич  Упаковок',
  LinkList)));

R.Assign(14, 1, 75, 2);
st:=GetIdField(FNAme,LinkArt);
s:=GetIdField(FNAme2,LinkArt);
DelSpaceRight(st);
DelSpaceRight(s);
st:=St+' '+s;
Control := New(PColoredText, Init(R, st+'('+LinkArt+')', $7E));
LinkWindow^.Insert(Control);

R.Assign(3, 1, 14, 2);
Control := New(PColoredText, Init(R, 'Сертификат:', $74));
LinkWindow^.Insert(Control);

R.Assign(8, 2, 14, 3);
Control := New(PColoredText, Init(R, 'Выдан:', $74));
LinkWindow^.Insert(Control);

st:=GetIdField(FKtoSertif,LinkArt);
DelSpaceRight(st);
R.Assign(14, 2, 54, 3);
Control := New(PColoredText, Init(R, st, $7E));
LinkWindow^.Insert(Control);

R.Assign(55, 2, 69, 3);
Control := New(PColoredText, Init(R, 'Срок действия:', $74));
LinkWindow^.Insert(Control);

st:=GetIdField(FDateSertif,LinkArt);
DelSpaceRight(st);
R.Assign(69, 2, 77, 3);
Control := New(PColoredText, Init(R, st, $7E));
LinkWindow^.Insert(Control);

R.Assign(2, 18, 25, 19);
ControlCount3 := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList^.List^.Count,CLitr+1), $4E));
LinkWindow^.Insert(ControlCount3);

R.Assign(1, 16, 16, 17);
Control := New(PColoredText, Init(R, 'Акцизная марка:', $74));
LinkWindow^.Insert(Control);

R.Assign(16, 16, 56, 17);
ControlMarka3 := New(PColoredText, Init(R, '???', $7E));
LinkWindow^.Insert(ControlMarka3);

R.Assign(7, 17, 47, 18);
ControlNGTD3 := New(PColoredText, Init(R, '???', $7E));
LinkWindow^.Insert(ControlNGTD3);

R.Assign(1, 17, 7, 18);
Control := New(PColoredText, Init(R, 'N ГТД:', $74));
LinkWindow^.Insert(Control);

R.Assign(58, 16, 69, 17);
Control := New(PColoredText, Init(R, 'Выработано:', $74));
LinkWindow^.Insert(Control);

R.Assign(69, 16, 77, 17);
ControlVirabotano3 := New(PColoredText, Init(R, '???', $7E));
LinkWindow^.Insert(ControlVirabotano3);

R.Assign(69, 17, 77, 18);
ControlDo3 := New(PColoredText, Init(R, '???', $7E));
LinkWindow^.Insert(ControlDo3);

R.Assign(54, 17, 69, 18);
Control := New(PColoredText, Init(R, 'Реализовать до:', $74));
LinkWindow^.Insert(Control);

VidOtbora:=0;

R.Assign(40, 18, 76, 19);
ControlVidOtbora := New(PRadioButtons, Init(R,
  NewSItem('~В~се',
  NewSItem('Не ну~л~евое количество', Nil))));
LinkWindow^.Insert(ControlVidOtbora);

ControlVidOtbora^.SetData(VidOtbora);

  R.Assign(28, 18, 40, 19);
  LinkWindow^.Insert(New(PLabel, Init(R, 'Вид отбора:', ControlVidOtbora)));

LinkWindow^.SelectNext(False);

CurrentLine[0]:=#0;
Refresh;
CurrentLine[0]:=#0;

c:=Desktop^.ExecView(LinkWindow);

Dispose(NoScreenList1,Done);
Dispose(Control,Done);
Dispose(LinkWindow,Done);
End;



*)



procedure TLinkWindow.FormReport;
Var txt : Text;
    Reg,c,w : Word;
   Space: AllStr;
      s : String;
   SMArka,SGTD,SSrok,SVirabotano : AllStr;
begin
Space:='       ';
Reg:=SelectImport(19);
If not (Reg in [0,1]) Then Exit;


DInfoMsg('Формирую отчет.Ждите...',True);
 Assign(txt,Path^.Dat.ToTemp+'linksert.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'linksert.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(txt,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+
 ' EYE & 1997-01');
 Writeln(txt);
 Writeln(txt,Space+
 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'         ОТЧЕТ ПО НАИМЕНОВАНИЯМ ТОВАРА, СВЯЗАННЫМ С СЕРТИФИКАТОМ'+
 GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
 Writeln(txt,Space+GetIdField(FFFName,LArt)+' ('+LArt+')');
 Writeln(txt,Space+'Выдан:'+GetIdField(FKtoSertif,LArt)+' Срок действия: '+GetIdField(FDateSertif,LArt));
 Write(txt,Space+'Вид отбора:');

 Case VidOtbora Of
 0:Writeln(txt,'Все');
 1:Writeln(txt,'Не нулевое количество');
 Else Writeln(txt);
 End;
 Writeln(txt,Space+'┌────────────────────────────────────────────────────┬─────┬─────┬─────────┐');
 Writeln(txt,Space+'│Наименования товара, связанные с сертификатом       │ Код │Колич│ Упаковок│');
 Writeln(txt,Space+'└────────────────────────────────────────────────────┴─────┴─────┴─────────┘'+HeaderStop);

 For c:=0 To LinkList^.List^.Count-1 Do
  Begin
   s:=LinkList^.GetText(c,LinkList^.List^.Count);

    sMarka:=Copy(s,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1,CMarka);
    DelSpaceRight(sMarka);
    sGTD:=Copy(s,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CMarka+1,CNGTD);
    DelSpaceRight(sGTD);
    sVirabotano:=Copy(s,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CMarka+1+CNGTD+1,CDate);
    DelSpaceRight(sVirabotano);
    sSrok:=Copy(s,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CMarka+1+CNGTD+1+CDAte+1,CDate);
    DelSpaceRight(SSrok);

   s[0]:=Chr(1+CNAme+1+CNAme+1+CArtikul+1+CKol+1+CPAck);

   While Pos('│',s)>0 Do
    Begin
     w:=Pos('│',s);
     System.Delete(s,w,1);
     System.Insert(' ',s,w);
    End;

   Writeln(txt,Space+s);
   If Reg=0 Then
   Begin
   Writeln(txt,Space+Seria_Akzis^+':'+SMarka+'    '+'Выработано:'+SVirabotano);
   Writeln(txt,Space+'ГТД:'+SGTD+'    '+'Реализовать до:'+SSrok);
   Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────');
   End;
  End;
 Writeln(txt,Space+'────────────────────────────────────────────────────────────────────────────');
 Writeln(txt,Space+' Всего позиций: ',LinkList^.List^.Count:6);
 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'============================================================================');
 System.Close(txt);
NoInfoMsg;
ReportNew(Path^.Dat.ToTemp+'linksert.txt','',1,False,False);
End;

procedure TLinkWindow.Refresh;
Var SKol : ArtikulStr;
    c : Word;
    R : TRect;
    s : String;
begin
DInfoMsg('Минуточку...',True);
LinkList^.NewList(Nil);
LinkList^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList1^.List^.Count>0 Then
 For c:=0 To NoScreenList1^.List^.Count-1 Do
  Begin
   s:=NoScreenList1^.GetText(c,NoScreenList1^.List^.Count);
   SKol:=Copy(s,1+CNAme+1+CName+1+CArtikul+1,CKol);
   If ((StrToInt(Skol)>0)And (VidOtbora=1)) Or (VidOtbora=0) Then
   Begin
    LinkList^.List^.Insert(NewStr(s));
    LinkList^.SetRange(LinkList^.List^.Count);
   End;
  End;
LinkList^.FocusItem(0);

Dispose(ControlCount3,Done);
R.Assign(2, 18, 25, 19);
ControlCount3 := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList^.List^.Count,CLitr+1), $4E));
LinkWindow^.Insert(ControlCount3);
NoInfoMsg;

CurrentLine[0]:=#0;

End;

procedure TLinkWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var art : ArtikulStr;
    Prom : Word;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
        cmReestrReport:Begin
                        If LinkList^.List^.Count>0 Then FormReport;
                        ClearEvent(Event);
                       End;

 cmViewPrihodTovar:
            Begin
             Art:=Copy(LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count),1+CName+1+CName+1,Cartikul);
             FP^.FindScreenPrh(Art);
             ClearEvent(Event);
            End;

        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);

 If (Desktop^.Current=PView(LinkWindow)) And (Event.What <> EvKeyDown) Then
     Begin
          if (ControlVidOtbora^.State and sfFocused <> 0)Then
              Begin
               ControlVidOtbora^.GetData(Prom);
               If Prom <> VidOtbora Then
               Begin
                  VidOtbora:=Prom;
                           Refresh;
                  Redraw;
               End;
              End;
      DrawCurrent;
     End;
End;

Procedure TLinkWindow.DrawCurrent;
Var st : String;
    R : TRect;
Begin
if (LinkList^.List<>Nil)And(LinkList^.List^.Count>=1) Then
 Begin
  st:=LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count);
  If st <> CurrentLine Then
   Begin
    CurrentLine:=St;
    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1,CMarka);
    DelSpaceRight(st);
    Dispose(ControlMarka3,Done);
    R.Assign(16, 16, 56, 17);
    ControlMarka3 := New(PColoredText, Init(R, st, $7E));
    LinkWindow^.Insert(ControlMarka3);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CMarka+1,
    CNGTD);
    DelSpaceRight(st);
    Dispose(ControlNGTD3,Done);
    R.Assign(7, 17, 47, 18);
    ControlNGTD3 := New(PColoredText, Init(R, st, $7E));
    LinkWindow^.Insert(ControlNGTD3);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CMarka+1+
    CNGTD+1,CDate);
    DelSpaceRight(st);
    Dispose(ControlVirabotano3,Done);
    R.Assign(69, 16, 77, 17);
    ControlVirabotano3 := New(PColoredText, Init(R, St, $7E));
    LinkWindow^.Insert(ControlVirabotano3);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CMarka+1+
    CNGTD+1+CDAte+1,CDate);
    DelSpaceRight(st);
    Dispose(ControlDo3,Done);
    R.Assign(69, 17, 77, 18);
    ControlDo3 := New(PColoredText, Init(R, St, $7E));
    LinkWindow^.Insert(ControlDo3);
   End;
 End
 Else
  Begin
   PStaticText(ControlMarka3)^.GetText(st);
   If St<>'???' Then
   Begin
   Dispose(ControlMarka3,Done);
   R.Assign(16, 16, 56, 17);
   ControlMarka3 := New(PColoredText, Init(R, '???', $7E));
   LinkWindow^.Insert(ControlMarka3);

   Dispose(ControlNGTD3,Done);
   R.Assign(7, 17, 47, 18);
   ControlNGTD3 := New(PColoredText, Init(R, '???', $7E));
   LinkWindow^.Insert(ControlNGTD3);

   Dispose(ControlVirabotano3,Done);
   R.Assign(69, 16, 77, 17);
   ControlVirabotano3 := New(PColoredText, Init(R, '???', $7E));
   LinkWindow^.Insert(ControlVirabotano3);

   Dispose(ControlDo3,Done);
   R.Assign(69, 17, 77, 18);
   ControlDo3 := New(PColoredText, Init(R, '???', $7E));
   LinkWindow^.Insert(ControlDo3);
   End;
  End;
End;


Destructor TLinkWindow.Done;
Begin
TDialog.Done;
End;




procedure TLinkGroupWindow.Start(LinkArt:ArtikulStr);
var
  R : TRect;
  Control : PView;
  RazdelFile : RazdelFileType;
  RazdelElement : PRazdelType;
  FSkl : File;
  Skl  : PSkladType;
  Skl1 : PSkladType;
  Count,C,i : Word;
  BF : File;
  BE : PBufBazType;

  s,St : String;
  Find : Boolean;
begin
LArt:=LinkArt;

{
If Not(GetRazdelStatus(LinkArt)) Then
 Begin
  LArt:=BakGetField(FNSertif,LinkArt,0);
  LinkArt:=LArt;
 End;
}

R.Assign(0,0,0,0);
NoScreenList1 := New(PBox, Init(R, 1, Nil));
NoScreenList1^.NewList(New(PTextCollection, Init(0,1)));


Assign(RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
i:=IOResult;
Reset(RazdelFile);
i:=IOResult;
Find:=False;
If i=0 Then
 Begin
  {DInfoMsg('Идет поиск связанных наименований...',True);}
  New(RazdelElement,Init);
  While Not(Eof(Razdelfile)) Do
   Begin
    Read(RazdelFile,RazdelElement^.Dat);

    DInfoMsgShkala('Идет поиск связанных группой наименований в разделе '+RazdelElement^.Dat.Kod+'. Ждите...',
    1,EmployRazdel,StrToInt(RazdelElement^.Dat.Kod)+1);
    If (RazdelElement^.Dat.Employ) And (Razdelelement^.Dat.EnableDoc=0) Then
     Begin
      Assign(BF,Path^.Dat.ToName+RazdelElement^.Dat.Kod+'.id');
      i:=ioresult;
      reset(bf,SizeOf(BazType));
      i:=ioresult;
      If i=0 Then
       Begin
        While Not(Eof(bf)) Do
         Begin
          New(be,Init);
          ReadBufBaz(Bf,be,Count);

          {ReadSklad(FSkl,Skl^.Dat);}
          For c:=1 To Count Do
Begin
          If Be^.Point.Dat[c].Employ Then
          If StrToInt(Be^.Point.Dat[c].NGroupKod)=StrToInt(LinkArt) Then
           Begin
            Find:=True;
            s[0]:=#0;
            st:=Be^.Point.Dat[c].Name;
            DelSpaceRight(st);
            s:=st;
            st:=Be^.Point.Dat[c].Name2;
            DelSpaceRight(st);
            s:=s+' '+st;
            Format(s,CName+1+CNAme);
            New(Skl,Init);
            Skl^.Dat.BazKod:=Be^.Point.Dat[c].BazKod;
            GetSkladRecord(Skl);
            DelSpace(Skl^.Dat.Input.Kol);
            RFormat(Skl^.Dat.Input.Kol,CKol);
            st:=CalcPack(Skl^.Dat.BazKod,Skl^.Dat.Input.Kol);
            DelSpace(st);
            RFormat(st,CPAck);
            s:=s+'│'+Skl^.Dat.BazKod+'│'+Skl^.Dat.Input.Kol+'│'+st;

            St:=GetMarkaField(FMarka,Skl^.Dat.Input.Marka);
            Format(st,CMarka);
            s:=s+'│'+st;

            St:=GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD);
            Format(st,CNGTD);
            s:=s+'│'+st;

            St:=Skl^.Dat.Input.Virabotano;
            Format(st,CDate);
            s:=s+'│'+st;

            St:=Skl^.Dat.Input.Godnost;
            Format(st,CDate);
            s:=s+'│'+st;

            Dispose(Skl,Done);

      If NoScreenList1^.List^.Count>=MaxCollectionSize-10 Then
      Begin
       MessageBox(^M+#3+'Переполнение коллекции!',Nil,mfError+mfCancelButton);
       Break;
      End;


            NoScreenList1^.List^.Insert(NewStr(s));
            NoScreenList1^.SetRange(NoScreenList1^.List^.Count);
           End;
End;{For}
         Dispose(BE,Done);
         End;{While}
         System.Close(BF);
       End
       Else
        Begin
            NoInfoMsg;
            MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToSklad+RazdelElement^.Dat.Kod+'.db!'+
            ClicProgrammer^,Nil,mfError+mfCancelButton);
        End;
     End;
   End;
  NoInfoMsg;
  System.Close(RazdelFile);
  Dispose(RazdelElement,Done);
 End
Else
Begin
 MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToRazdel+'razdel.db! '+
            ClicProgrammer^,Nil,
            mfError+mfCancelButton);
 Exit;
End;


If Not(Find) Then
 Begin
  Dispose(NoScreenList1,Done);
  MessageBox(^M+#3'С данной группой не связано ни одно наименование товара!',
             Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(1, 2, 79, 21);
New(LinkWindowG, Init(R, ''));
LinkWindowG^.Options := LinkWindowG^.Options or ofCenterX or ofCenterY;
LinkWindowG^.HelpCtx:=$F941;

R.Assign(77, 4, 78, 16);
Control := New(PScrollBar, Init(R));
LinkWindowG^.Insert(Control);

R.Assign(1, 4, 77, 16);
LinkList := New(PBox, Init(R, 1, PScrollbar(Control)));
LinkList^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList1^.List^.Count-1>=0 Then
 For c:=0 To NoScreenList1^.List^.Count-1 Do
  Begin
   s:=NoScreenList1^.GetText(c,NoScreenList1^.List^.Count);
   LinkList^.List^.Insert(NewStr(s));
   LinkList^.SetRange(LinkList^.List^.Count);
  End;
LinkList^.FocusItem(0);
LinkWindowG^.Insert(LinkList);


  R.Assign(1, 3, 77, 4);
  LinkWindowG^.Insert(New(PLabel, Init(R, 'Наименования товара, связанные с группой               Код  Колич  Упаковок',
  LinkList)));

R.Assign(14, 1, 75, 2);
st:=GetGroupField(FNAme,LinkArt);
DelSpaceRight(st);
Control := New(PColoredText, Init(R, st+'('+LinkArt+')', $7E));
LinkWindowG^.Insert(Control);

R.Assign(3, 1, 14, 2);
Control := New(PColoredText, Init(R, '    Группа:', $74));
LinkWindowG^.Insert(Control);
{
R.Assign(8, 2, 14, 3);
Control := New(PColoredText, Init(R, 'Выдан:', $74));
LinkWindowG^.Insert(Control);

st:=GetIdField(FKtoSertif,LinkArt);
DelSpaceRight(st);
R.Assign(14, 2, 54, 3);
Control := New(PColoredText, Init(R, st, $7E));
LinkWindowG^.Insert(Control);

R.Assign(55, 2, 69, 3);
Control := New(PColoredText, Init(R, 'Срок действия:', $74));
LinkWindowG^.Insert(Control);

st:=GetIdField(FDateSertif,LinkArt);
DelSpaceRight(st);
R.Assign(69, 2, 77, 3);
Control := New(PColoredText, Init(R, st, $7E));
LinkWindowG^.Insert(Control);
}
R.Assign(2, 18, 25, 19);
ControlCount := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList^.List^.Count,CLitr+1), $4E));
LinkWindowG^.Insert(ControlCount);

R.Assign(1, 16, 16, 17);
Control := New(PColoredText, Init(R, 'Акцизная марка:', $74));
LinkWindowG^.Insert(Control);

R.Assign(16, 16, 56, 17);
ControlMarka := New(PColoredText, Init(R, '???', $7E));
LinkWindowG^.Insert(ControlMarka);

R.Assign(7, 17, 47, 18);
ControlNGTD := New(PColoredText, Init(R, '???', $7E));
LinkWindowG^.Insert(ControlNGTD);

R.Assign(1, 17, 7, 18);
Control := New(PColoredText, Init(R, 'N ГТД:', $74));
LinkWindowG^.Insert(Control);

R.Assign(58, 16, 69, 17);
Control := New(PColoredText, Init(R, 'Выработано:', $74));
LinkWindowG^.Insert(Control);

R.Assign(69, 16, 77, 17);
ControlVirabotano := New(PColoredText, Init(R, '???', $7E));
LinkWindowG^.Insert(ControlVirabotano);

R.Assign(69, 17, 77, 18);
ControlDo := New(PColoredText, Init(R, '???', $7E));
LinkWindowG^.Insert(ControlDo);

R.Assign(54, 17, 69, 18);
Control := New(PColoredText, Init(R, 'Реализовать до:', $74));
LinkWindowG^.Insert(Control);

VidOtbora:=0;

R.Assign(40, 18, 76, 19);
ControlVidOtboraG := New(PRadioButtons, Init(R,
  NewSItem('~В~се',
  NewSItem('Не ну~л~евое количество', Nil))));
LinkWindowG^.Insert(ControlVidOtboraG);

ControlVidOtboraG^.SetData(VidOtbora);

  R.Assign(28, 18, 40, 19);
  LinkWindowG^.Insert(New(PLabel, Init(R, 'Вид отбора:', ControlVidOtboraG)));

LinkWindowG^.SelectNext(False);

CurrentLine[0]:=#0;
Refresh;
CurrentLine[0]:=#0;

c:=Desktop^.ExecView(LinkWindowG);

Dispose(NoScreenList1,Done);
Dispose(Control,Done);
Dispose(LinkWindowG,Done);
End;





procedure TLinkGroupWindow.FormReport;
Var txt : Text;
    c,w : Word;
   Space: AllStr;
      s : String;

begin
Space:='       ';
DInfoMsg('Формирую отчет.Ждите...',True);
 Assign(txt,Path^.Dat.ToTemp+'linkserg.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'linkserg.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(txt,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-00');
 Writeln(txt);
 Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'         ОТЧЕТ ПО НАИМЕНОВАНИЯМ ТОВАРА, СВЯЗАННЫМ С ГРУППОЙ'+
 GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
 Writeln(txt,Space+GetGroupField(FName,LArt)+' ('+LArt+')');
 Write(txt,Space+'Вид отбора:');

 Case VidOtbora Of
 0:Writeln(txt,'Все');
 1:Writeln(txt,'Не нулевое количество');
 Else Writeln(txt);
 End;
 Writeln(txt,Space+'┌────────────────────────────────────────────────────┬─────┬─────┬─────────┐');
 Writeln(txt,Space+'│Наименования товара, связанные с группой            │ Код │Колич│ Упаковок│');
 Writeln(txt,Space+'└────────────────────────────────────────────────────┴─────┴─────┴─────────┘'+HeaderStop);

 For c:=0 To LinkList^.List^.Count-1 Do
  Begin
   s:=LinkList^.GetText(c,LinkList^.List^.Count);
   s[0]:=Chr(1+CNAme+1+CNAme+1+CArtikul+1+CKol+1+CPAck);

   While Pos('│',s)>0 Do
    Begin
     w:=Pos('│',s);
     System.Delete(s,w,1);
     System.Insert(' ',s,w);
    End;

   Writeln(txt,Space+s)
  End;
 Writeln(txt,Space+'────────────────────────────────────────────────────────────────────────────');
 Writeln(txt,Space+' Всего позиций: ',LinkList^.List^.Count:6);
 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'============================================================================');
 System.Close(txt);
NoInfoMsg;
ReportNew(Path^.Dat.ToTemp+'linkserg.txt','',1,False,False);
End;

procedure TLinkGroupWindow.Refresh;
Var SKol : ArtikulStr;
    c : Word;
    R : TRect;
    s : String;
begin
DInfoMsg('Минуточку...',True);
LinkList^.NewList(Nil);
LinkList^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList1^.List^.Count>0 Then
 For c:=0 To NoScreenList1^.List^.Count-1 Do
  Begin
   s:=NoScreenList1^.GetText(c,NoScreenList1^.List^.Count);
   SKol:=Copy(s,1+CNAme+1+CName+1+CArtikul+1,CKol);
   If ((StrToInt(Skol)>0)And (VidOtbora=1)) Or (VidOtbora=0) Then
   Begin
    LinkList^.List^.Insert(NewStr(s));
    LinkList^.SetRange(LinkList^.List^.Count);
   End;
  End;
LinkList^.FocusItem(0);

Dispose(ControlCount,Done);
R.Assign(2, 18, 25, 19);
ControlCount := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList^.List^.Count,CLitr+1), $4E));
LinkWindowG^.Insert(ControlCount);
NoInfoMsg;

CurrentLine[0]:=#0;

End;

procedure TLinkGroupWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var Art : ArtikulStr;
    Prom : Word;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
        cmReestrReport:Begin
                        If LinkList^.List^.Count>0 Then FormReport;
                        ClearEvent(Event);
                       End;
 cmViewPrihodTovar:
            Begin
             Art:=Copy(LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count),1+CName+1+CName+1,Cartikul);
             FP^.FindScreenPrh(Art);
             ClearEvent(Event);
            End;
        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);

 If (Desktop^.Current=PView(LinkWindowG)) And (Event.What <> EvKeyDown) Then
     Begin
          if (ControlVidOtboraG^.State and sfFocused <> 0)Then
              Begin
               ControlVidOtboraG^.GetData(Prom);
               If Prom <> VidOtbora Then
               Begin
                  VidOtbora:=Prom;
                  Refresh;
                  Redraw;
               End;
              End;
      DrawCurrent;
     End;
End;



Procedure TLinkGroupWindow.DrawCurrent;
Var st : String;
    R : TRect;
Begin
if (LinkList^.List<>Nil)And(LinkList^.List^.Count>=1) Then
 Begin
  st:=LinkList^.GetText(LinkList^.Focused,LinkList^.List^.Count);
  If st <> CurrentLine Then
   Begin
    CurrentLine:=St;
    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlMarka,Done);
    R.Assign(16, 16, 56, 17);
    ControlMarka := New(PColoredText, Init(R, st, $7E));
    LinkWindowG^.Insert(ControlMarka);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1,
    CNSertif);
    DelSpaceRight(st);
    Dispose(ControlNGTD,Done);
    R.Assign(7, 17, 47, 18);
    ControlNGTD := New(PColoredText, Init(R, st, $7E));
    LinkWindowG^.Insert(ControlNGTD);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1,CDate);
    DelSpaceRight(st);
    Dispose(ControlVirabotano,Done);
    R.Assign(69, 16, 77, 17);
    ControlVirabotano := New(PColoredText, Init(R, St, $7E));
    LinkWindowG^.Insert(ControlVirabotano);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1+CDAte+1,CDate);
    DelSpaceRight(st);
    Dispose(ControlDo,Done);
    R.Assign(69, 17, 77, 18);
    ControlDo := New(PColoredText, Init(R, St, $7E));
    LinkWindowG^.Insert(ControlDo);
   End;
 End
 Else
  Begin
   PStaticText(ControlMarka)^.GetText(st);
   If St<>'???' Then
   Begin
   Dispose(ControlMarka,Done);
   R.Assign(16, 16, 56, 17);
   ControlMarka := New(PColoredText, Init(R, '???', $7E));
   LinkWindowG^.Insert(ControlMarka);

   Dispose(ControlNGTD,Done);
   R.Assign(7, 17, 47, 18);
   ControlNGTD := New(PColoredText, Init(R, '???', $7E));
   LinkWindowG^.Insert(ControlNGTD);

   Dispose(ControlVirabotano,Done);
   R.Assign(69, 16, 77, 17);
   ControlVirabotano := New(PColoredText, Init(R, '???', $7E));
   LinkWindowG^.Insert(ControlVirabotano);

   Dispose(ControlDo,Done);
   R.Assign(69, 17, 77, 18);
   ControlDo := New(PColoredText, Init(R, '???', $7E));
   LinkWindowG^.Insert(ControlDo);
   End;
  End;
End;


Destructor TLinkGroupWindow.Done;
Begin
TDialog.Done;
End;



procedure TLinkMarkaWindow.Start(LinkArt:ArtikulStr);
var
  R : TRect;
  Control : PView;
  RazdelFile : RazdelFileType;
  RazdelElement : PRazdelType;
  FSkl : File;
  Count,C,i : Word;
  BF : File;
  BE : PBufSkladTypeNew;
  SArt,SKol : AllStr;
  s : String;
  st : TMyString;
  Find : Boolean;
begin

LArt:=LinkArt;


R.Assign(0,0,0,0);
NoScreenList2 := New(PBox, Init(R, 1, Nil));
NoScreenList2^.NewList(New(PTextCollection, Init(0,1)));


Assign(RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
i:=IOResult;
Reset(RazdelFile);
i:=IOResult;
Find:=False;
If i=0 Then
 Begin
  {DInfoMsg('Идет поиск связанных наименований...',True);}
  New(RazdelElement,Init);
  While Not(Eof(Razdelfile)) Do
   Begin
    Read(RazdelFile,RazdelElement^.Dat);

    DInfoMsgShkala('Идет поиск связанных с объектом наименований в разделе '+RazdelElement^.Dat.Kod+'. Ждите...',
    1,EmployRazdel,StrToInt(RazdelElement^.Dat.Kod)+1);
    If (RazdelElement^.Dat.Employ) And (Razdelelement^.Dat.EnableDoc=0) Then
     Begin
      Assign(bf,Path^.Dat.ToIndex+RazdelElement^.Dat.Kod+'.kdx');
      i:=ioresult;
      reset(bf,SizeOf(SkladTypeNew));
      i:=ioresult;
      If i=0 Then
       Begin
        While Not(Eof(bf)) Do
         Begin
          New(be,Init);
          ReadBufNewSklad(Bf,be,Count);
          For c:=1 To Count Do
Begin
          If Be^.Point.Dat[c].Employ Then
          If Be^.Point.Dat[c].NMarkaKod=StrToInt(LinkArt) Then
           Begin
            Find:=True;
            s[0]:=#0;
            st:=Be^.Point.Dat[c].Name;
            DelSpaceRight(st);
            s:=st;
            st:=Be^.Point.Dat[c].Name2;
            DelSpaceRight(st);
            s:=s+' '+st;
            Format(s,CName+1+CNAme);

            SKol:=IntToStr(Be^.Point.Dat[c].Kol,CKOl);
            RFormat(SKol,CKol);
            SArt:=IntToStr(Be^.Point.Dat[c].BazKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            st:=CalcPack(SArt,SKol);
            DelSpace(st);
            RFormat(st,CPAck);
            s:=s+'│'+SArt+'│'+SKol+'│'+st;

            SArt:=IntToStr(Be^.Point.Dat[c].NExpertKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetExpertField(FExpert,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CMarka);
            s:=s+'│'+st;

            SArt:=IntToStr(Be^.Point.Dat[c].NGTDKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetNGTDField(FNGTD,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNGTD);
            s:=s+'│'+st;


            SArt:=IntToStr(Be^.Point.Dat[c].NSertif,CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetIdField(FFFName,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNSertif);
            s:=s+'│'+st;

            SArt:=IntToStr(Be^.Point.Dat[c].FirmaPostKod,CClientKod);
            RFormatZerro(SArt,CClientKod);
            St:=GetFirmaPostField(FFirmaPost,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNSertif);
            s:=s+'│'+st;


            SArt:=IntToStr(Be^.Point.Dat[c].BazKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            SArt:=GetIDField(FGroup,SArt);
            RFormatZerro(SArt,CClientKod);
            St:=GetGroupField(FName,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNSertif);
            s:=s+'│'+st;

            {
            St:=Be^.Point.Dat[c].Godnost;
            Format(st,CDate);
            s:=s+'│'+st;
            }
      If NoScreenList2^.List^.Count>=MaxCollectionSize-10 Then
      Begin
       MessageBox(^M+#3+'Переполнение коллекции!',Nil,mfError+mfCancelButton);
       Break;
      End;

            NoScreenList2^.List^.Insert(NewStr(s));
            NoScreenList2^.SetRange(NoScreenList2^.List^.Count);
           End;
End;{For}
         Dispose(BE,Done);
         End;{While}
         System.Close(BF);
       End
       Else
        Begin
            NoInfoMsg;
            MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToSklad+RazdelElement^.Dat.Kod+'.db!'+
            ClicProgrammer^,Nil,mfError+mfCancelButton);
        End;
     End;
   End;
  NoInfoMsg;
  System.Close(RazdelFile);
  Dispose(RazdelElement,Done);
 End
Else
Begin
 MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToRazdel+'razdel.db! '+
            ClicProgrammer^,Nil,
            mfError+mfCancelButton);
 Exit;
End;


If Not(Find) Then
 Begin
  Dispose(NoScreenList2,Done);
  MessageBox(^M+#3'С данной маркой не связано ни одно наименование товара!',
             Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(1, 2, 79, 24);
New(LinkMarkaWindow, Init(R, ''));
LinkMarkaWindow^.Options := LinkMarkaWindow^.Options or ofCenterX or ofCenterY;
LinkMarkaWindow^.HelpCtx:=$F940;

R.Assign(77, 4, 78, 16);
Control := New(PScrollBar, Init(R));
LinkMarkaWindow^.Insert(Control);

R.Assign(1, 4, 77, 16);
LinkList1 := New(PBox, Init(R, 1, PScrollbar(Control)));
LinkList1^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList2^.List^.Count-1>=0 Then
 For c:=0 To NoScreenList2^.List^.Count-1 Do
  Begin
   s:=NoScreenList2^.GetText(c,NoScreenList2^.List^.Count);
   LinkList1^.List^.Insert(NewStr(s));
   LinkList1^.SetRange(LinkList1^.List^.Count);
  End;
LinkList1^.FocusItem(0);
LinkMarkaWindow^.Insert(LinkList1);


  R.Assign(1, 3, 77, 4);
  LinkMarkaWindow^.Insert(New(PLabel, Init(R, 'Наименования товара, связанные с маркой                Код  Колич  Упаковок',
  LinkList1)));

R.Assign(14, 1, 75, 2);
st:=GetMarkaField(FNAme,LinkArt);
DelSpaceRight(st);
Control := New(PColoredText, Init(R, st+'('+LinkArt+')', $7E));
LinkMarkaWindow^.Insert(Control);

R.Assign(3, 1, 14, 2);
Control := New(PColoredText, Init(R, '     Марка:', $74));
LinkMarkaWindow^.Insert(Control);

R.Assign(2, 21, 25, 22);
ControlCount := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList1^.List^.Count,CLitr+1), $4E));
LinkMarkaWindow^.Insert(ControlCount);

R.Assign(1, 16, 16, 17);
Control := New(PColoredText, Init(R, Expert_RegNom^+':', $74));
LinkMarkaWindow^.Insert(Control);

R.Assign(16, 16, 56, 17);
ControlMarka := New(PColoredText, Init(R, '???', $7E));
LinkMarkaWindow^.Insert(ControlMarka);

R.Assign(16, 17, 77, 18);
ControlNGTD := New(PColoredText, Init(R, '???', $7E));
LinkMarkaWindow^.Insert(ControlNGTD);

R.Assign(1, 17, 16, 18);
Control := New(PColoredText, Init(R, '         N ГТД:', $74));
LinkMarkaWindow^.Insert(Control);

R.Assign(1, 18, 16, 19);
Control := New(PColoredText, Init(R, '    Сертификат:', $74));
LinkMarkaWindow^.Insert(Control);

R.Assign(16, 18, 77, 19);
ControlVirabotano := New(PColoredText, Init(R, '???', $7E));
LinkMarkaWindow^.Insert(ControlVirabotano);

R.Assign(16, 19, 77, 20);
ControlDo := New(PColoredText, Init(R, '???', $7E));
LinkMarkaWindow^.Insert(ControlDo);

R.Assign(1, 19, 16, 20);
Control := New(PColoredText, Init(R, 'Фирма-производ:', $74));
LinkMarkaWindow^.Insert(Control);


R.Assign(1, 20, 16, 21);
Control := New(PColoredText, Init(R, '        Группа:', $74));
LinkMarkaWindow^.Insert(Control);

R.Assign(16, 20, 77, 21);
ControlGroup := New(PColoredText, Init(R, '???', $7E));
LinkMarkaWindow^.Insert(ControlGroup);



VidOtbora:=0;

R.Assign(40, 21, 76, 22);
ControlVidOtboraG := New(PRadioButtons, Init(R,
  NewSItem('~В~се',
  NewSItem('Не ну~л~евое количество', Nil))));
LinkMarkaWindow^.Insert(ControlVidOtboraG);

ControlVidOtboraG^.SetData(VidOtbora);
{
  R.Assign(28, 19, 40, 20);
  LinkMarkaWindow^.Insert(New(PLabel, Init(R, 'Вид отбора:', ControlVidOtboraG)));
}
LinkMarkaWindow^.SelectNext(False);

CurrentLine[0]:=#0;
Refresh;
CurrentLine[0]:=#0;

c:=Desktop^.ExecView(LinkMarkaWindow);

Dispose(NoScreenList2,Done);
Dispose(Control,Done);
Dispose(LinkMarkaWindow,Done);

End;





procedure TLinkMarkaWindow.FormReport;
Var txt : Text;
    c,w : Word;
   Space: AllStr;
      s : String;

begin
Space:='       ';
DInfoMsg('Формирую отчет.Ждите...',True);
 Assign(txt,Path^.Dat.ToTemp+'linkakz.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'linkakz.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(txt,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-00');
 Writeln(txt);
 Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'         ОТЧЕТ ПО НАИМЕНОВАНИЯМ ТОВАРА, СВЯЗАННЫМ С МАРКОЙ'+
 GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
 Writeln(txt,Space+GetMarkaField(FName,LArt)+' ('+LArt+')');
 Write(txt,Space+'Вид отбора:');

 Case VidOtbora Of
 0:Writeln(txt,'Все');
 1:Writeln(txt,'Не нулевое количество');
 Else Writeln(txt);
 End;
 Writeln(txt,Space+'┌────────────────────────────────────────────────────┬─────┬─────┬─────────┐');
 Writeln(txt,Space+'│Наименования товара, связанные с маркой             │ Код │Колич│ Упаковок│');
 Writeln(txt,Space+'└────────────────────────────────────────────────────┴─────┴─────┴─────────┘'+HeaderStop);

 For c:=0 To LinkList1^.List^.Count-1 Do
  Begin
   s:=LinkList1^.GetText(c,LinkList1^.List^.Count);
   s[0]:=Chr(1+CNAme+1+CNAme+1+CArtikul+1+CKol+1+CPAck);

   While Pos('│',s)>0 Do
    Begin
     w:=Pos('│',s);
     System.Delete(s,w,1);
     System.Insert(' ',s,w);
    End;

   Writeln(txt,Space+s)
  End;
 Writeln(txt,Space+'────────────────────────────────────────────────────────────────────────────');
 Writeln(txt,Space+' Всего позиций: ',LinkList1^.List^.Count:6);
 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'============================================================================');
 System.Close(txt);
NoInfoMsg;
ReportNew(Path^.Dat.ToTemp+'linkakz.txt','',1,False,False);
End;


procedure TLinkMarkaWindow.Refresh;
Var SKol : ArtikulStr;
    c : Word;
    R : TRect;
    s : String;
begin
DInfoMsg('Минуточку...',True);
LinkList1^.NewList(Nil);
LinkList1^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList2^.List^.Count>0 Then
 For c:=0 To NoScreenList2^.List^.Count-1 Do
  Begin
   s:=NoScreenList2^.GetText(c,NoScreenList2^.List^.Count);
   SKol:=Copy(s,1+CNAme+1+CName+1+CArtikul+1,CKol);
   If ((StrToInt(Skol)>0)And (VidOtbora=1)) Or (VidOtbora=0) Then
   Begin
    LinkList1^.List^.Insert(NewStr(s));
    LinkList1^.SetRange(LinkList1^.List^.Count);
   End;
  End;
LinkList1^.FocusItem(0);

Dispose(ControlCount,Done);
R.Assign(2, 21, 25, 22);
ControlCount := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList1^.List^.Count,CLitr+1), $4E));
LinkMarkaWindow^.Insert(ControlCount);
NoInfoMsg;

CurrentLine[0]:=#0;

End;

procedure TLinkMarkaWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var s : String;
    Prom : Word;
    Art : ArtikulStr;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
        cmReestrReport:Begin
                        If LinkList1^.List^.Count>0 Then FormReport;
                        ClearEvent(Event);
                       End;
 cmFindLink:Begin
             Art:=Copy(LinkList1^.GetText(LinkList1^.Focused,LinkList1^.List^.Count),1+CName+1+CName+1,Cartikul);
             Lnk^.Start(Art);
             ClearEvent(Event);
            End;

 cmViewPrihodTovar:
            Begin
             Art:=Copy(LinkList1^.GetText(LinkList1^.Focused,LinkList1^.List^.Count),1+CName+1+CName+1,Cartikul);
             FP^.FindScreenPrh(Art);
             ClearEvent(Event);
            End;
        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);

 If (Desktop^.Current=PView(LinkMarkaWindow)) And (Event.What <> EvKeyDown) Then
     Begin
          if (ControlVidOtboraG^.State and sfFocused <> 0)Then
              Begin
               ControlVidOtboraG^.GetData(Prom);
               If Prom <> VidOtbora Then
               Begin
                  VidOtbora:=Prom;
                  Refresh;
                  Redraw;
               End;
              End;
      DrawCurrent;
     End;
End;



Procedure TLinkMarkaWindow.DrawCurrent;
Var st : String;
    R : TRect;
Begin
if (LinkList1^.List<>Nil)And(LinkList1^.List^.Count>=1) Then
 Begin
  st:=LinkList1^.GetText(LinkList1^.Focused,LinkList1^.List^.Count);
  If st <> CurrentLine Then
   Begin
    CurrentLine:=St;
    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlMarka,Done);
    R.Assign(16, 16, 56, 17);
    ControlMarka := New(PColoredText, Init(R, st, $7E));
    LinkMarkaWindow^.Insert(ControlMarka);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1,
    CNSertif);
    DelSpaceRight(st);
    Dispose(ControlNGTD,Done);
    R.Assign(16, 17, 77, 18);
    ControlNGTD := New(PColoredText, Init(R, st, $7E));
    LinkMarkaWindow^.Insert(ControlNGTD);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlVirabotano,Done);
    R.Assign(16, 18, 77, 19);
    ControlVirabotano := New(PColoredText, Init(R, St, $7E));
    LinkMarkaWindow^.Insert(ControlVirabotano);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1+CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlDo,Done);
    R.Assign(16, 19, 77, 20);
    ControlDo := New(PColoredText, Init(R, St, $7E));
    LinkMarkaWindow^.Insert(ControlDo);


    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1+CNSertif+1+CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlGroup,Done);
    R.Assign(16, 20, 77, 21);
    ControlGroup := New(PColoredText, Init(R, St, $7E));
    LinkMarkaWindow^.Insert(ControlGroup);
   End;
 End
 Else
  Begin
   PStaticText(ControlMarka)^.GetText(st);
   If St<>'???' Then
   Begin
   Dispose(ControlMarka,Done);
   R.Assign(16, 16, 56, 17);
   ControlMarka := New(PColoredText, Init(R, '???', $7E));
   LinkMarkaWindow^.Insert(ControlMarka);

   Dispose(ControlNGTD,Done);
   R.Assign(7, 17, 47, 18);
   ControlNGTD := New(PColoredText, Init(R, '???', $7E));
   LinkMarkaWindow^.Insert(ControlNGTD);

   Dispose(ControlVirabotano,Done);
   R.Assign(16, 18, 77, 19);
   ControlVirabotano := New(PColoredText, Init(R, '???', $7E));
   LinkMarkaWindow^.Insert(ControlVirabotano);

   Dispose(ControlDo,Done);
   R.Assign(16, 19, 77, 20);
   ControlDo := New(PColoredText, Init(R, '???', $7E));
   LinkMarkaWindow^.Insert(ControlDo);

   Dispose(ControlGroup,Done);
   R.Assign(16, 20, 77, 21);
   ControlGroup := New(PColoredText, Init(R, '???', $7E));
   LinkMarkaWindow^.Insert(ControlGroup);
   End;
  End;
End;


Destructor TLinkMarkaWindow.Done;
Begin
TDialog.Done;
End;


procedure TLinkExpertWindow.Start(LinkArt:ArtikulStr);
var
  R : TRect;
  Control : PView;
  RazdelFile : RazdelFileType;
  RazdelElement : PRazdelType;
  FSkl : File;
  Count,C,i : Word;
  BF : File;
  BE : PBufSkladTypeNew;
  SArt,SKol : AllStr;
  s : String;
  st : TMyString;
  Find : Boolean;
begin

LArt:=LinkArt;


R.Assign(0,0,0,0);
NoScreenList2 := New(PBox, Init(R, 1, Nil));
NoScreenList2^.NewList(New(PTextCollection, Init(0,1)));


Assign(RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
i:=IOResult;
Reset(RazdelFile);
i:=IOResult;
Find:=False;
If i=0 Then
 Begin
  {DInfoMsg('Идет поиск связанных наименований...',True);}
  New(RazdelElement,Init);
  While Not(Eof(Razdelfile)) Do
   Begin
    Read(RazdelFile,RazdelElement^.Dat);

    DInfoMsgShkala('Идет поиск связанных с объектом наименований в разделе '+RazdelElement^.Dat.Kod+'. Ждите...',
    1,EmployRazdel,StrToInt(RazdelElement^.Dat.Kod)+1);
    If (RazdelElement^.Dat.Employ) And (Razdelelement^.Dat.EnableDoc=0) Then
     Begin
      Assign(bf,Path^.Dat.ToIndex+RazdelElement^.Dat.Kod+'.kdx');
      i:=ioresult;
      reset(bf,SizeOf(SkladTypeNew));
      i:=ioresult;
      If i=0 Then
       Begin
        While Not(Eof(bf)) Do
         Begin
          New(be,Init);
          ReadBufNewSklad(Bf,be,Count);
          For c:=1 To Count Do
Begin
          If Be^.Point.Dat[c].Employ Then
          If Be^.Point.Dat[c].NExpertKod=StrToInt(LinkArt) Then
           Begin
            Find:=True;
            s[0]:=#0;
            st:=Be^.Point.Dat[c].Name;
            DelSpaceRight(st);
            s:=st;
            st:=Be^.Point.Dat[c].Name2;
            DelSpaceRight(st);
            s:=s+' '+st;
            Format(s,CName+1+CNAme);

            SKol:=IntToStr(Be^.Point.Dat[c].Kol,CKOl);
            RFormat(SKol,CKol);
            SArt:=IntToStr(Be^.Point.Dat[c].BazKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            st:=CalcPack(SArt,SKol);
            DelSpace(st);
            RFormat(st,CPAck);
            s:=s+'│'+SArt+'│'+SKol+'│'+st;

            SArt:=IntToStr(Be^.Point.Dat[c].NMarkaKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetMarkaField(FMarka,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CExpert);
            s:=s+'│'+st;

            SArt:=IntToStr(Be^.Point.Dat[c].NGTDKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetNGTDField(FNGTD,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNGTD);
            s:=s+'│'+st;


            SArt:=IntToStr(Be^.Point.Dat[c].NSertif,CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetIdField(FFFName,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNSertif);
            s:=s+'│'+st;

            SArt:=IntToStr(Be^.Point.Dat[c].FirmaPostKod,CClientKod);
            RFormatZerro(SArt,CClientKod);
            St:=GetFirmaPostField(FFirmaPost,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNSertif);
            s:=s+'│'+st;


            SArt:=IntToStr(Be^.Point.Dat[c].BazKod,CArtikul);
            RFormatZerro(SArt,CArtikul);
            SArt:=GetIDField(FGroup,SArt);
            RFormatZerro(SArt,CClientKod);
            St:=GetGroupField(FName,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNSertif);
            s:=s+'│'+st;

            {
            St:=Be^.Point.Dat[c].Godnost;
            Format(st,CDate);
            s:=s+'│'+st;
            }

      If NoScreenList2^.List^.Count>=MaxCollectionSize-10 Then
      Begin
       MessageBox(^M+#3+'Переполнение коллекции!',Nil,mfError+mfCancelButton);
       Break;
      End;

            NoScreenList2^.List^.Insert(NewStr(s));
            NoScreenList2^.SetRange(NoScreenList2^.List^.Count);
           End;
End;{For}
         Dispose(BE,Done);
         End;{While}
         System.Close(BF);
       End
       Else
        Begin
            NoInfoMsg;
            MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToSklad+RazdelElement^.Dat.Kod+'.db!'+
            ClicProgrammer^,Nil,mfError+mfCancelButton);
        End;
     End;
   End;
  NoInfoMsg;
  System.Close(RazdelFile);
  Dispose(RazdelElement,Done);
 End
Else
Begin
 MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToRazdel+'razdel.db! '+
            ClicProgrammer^,Nil,
            mfError+mfCancelButton);
 Exit;
End;


If Not(Find) Then
 Begin
  Dispose(NoScreenList2,Done);
  MessageBox(^M+#3'С данным объектом не связано ни одно наименование товара!',
             Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(1, 2, 79, 24);
New(LinkExpertWindow, Init(R, ''));
LinkExpertWindow^.Options := LinkExpertWindow^.Options or ofCenterX or ofCenterY;
LinkExpertWindow^.HelpCtx:=$F941;

R.Assign(77, 4, 78, 16);
Control := New(PScrollBar, Init(R));
LinkExpertWindow^.Insert(Control);

R.Assign(1, 4, 77, 16);
LinkList1 := New(PBox, Init(R, 1, PScrollbar(Control)));
LinkList1^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList2^.List^.Count-1>=0 Then
 For c:=0 To NoScreenList2^.List^.Count-1 Do
  Begin
   s:=NoScreenList2^.GetText(c,NoScreenList2^.List^.Count);
   LinkList1^.List^.Insert(NewStr(s));
   LinkList1^.SetRange(LinkList1^.List^.Count);
  End;
LinkList1^.FocusItem(0);
LinkExpertWindow^.Insert(LinkList1);


  R.Assign(1, 3, 77, 4);
  LinkExpertWindow^.Insert(New(PLabel, Init(R, 'Наименования товара, связанные с экспертным заключ.    Код  Колич  Упаковок',
  LinkList1)));

R.Assign(14, 1, 75, 2);
st:=GetExpertField(FNAme,LinkArt);
DelSpaceRight(st);
Control := New(PColoredText, Init(R, st+'('+LinkArt+')', $7E));
LinkExpertWindow^.Insert(Control);

R.Assign(3, 1, 14, 2);
Control := New(PColoredText, Init(R, Expert_RegNom^+':', $74));
LinkExpertWindow^.Insert(Control);

R.Assign(2, 21, 25, 22);
ControlCount := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList1^.List^.Count,CLitr+1), $4E));
LinkExpertWindow^.Insert(ControlCount);

R.Assign(1, 16, 16, 17);
Control := New(PColoredText, Init(R, '  Акцизн.марка:', $74));
LinkExpertWindow^.Insert(Control);

R.Assign(16, 16, 56, 17);
ControlMarka := New(PColoredText, Init(R, '???', $7E));
LinkExpertWindow^.Insert(ControlMarka);

R.Assign(16, 17, 77, 18);
ControlNGTD := New(PColoredText, Init(R, '???', $7E));
LinkExpertWindow^.Insert(ControlNGTD);

R.Assign(1, 17, 16, 18);
Control := New(PColoredText, Init(R, '         N ГТД:', $74));
LinkExpertWindow^.Insert(Control);

R.Assign(1, 18, 16, 19);
Control := New(PColoredText, Init(R, '    Сертификат:', $74));
LinkExpertWindow^.Insert(Control);

R.Assign(16, 18, 77, 19);
ControlVirabotano := New(PColoredText, Init(R, '???', $7E));
LinkExpertWindow^.Insert(ControlVirabotano);

R.Assign(16, 19, 77, 20);
ControlDo := New(PColoredText, Init(R, '???', $7E));
LinkExpertWindow^.Insert(ControlDo);

R.Assign(1, 19, 16, 20);
Control := New(PColoredText, Init(R, 'Фирма-производ:', $74));
LinkExpertWindow^.Insert(Control);


R.Assign(1, 20, 16, 21);
Control := New(PColoredText, Init(R, '        Группа:', $74));
LinkExpertWindow^.Insert(Control);

R.Assign(16, 20, 77, 21);
ControlGroup := New(PColoredText, Init(R, '???', $7E));
LinkExpertWindow^.Insert(ControlGroup);



VidOtbora:=0;

R.Assign(40, 21, 76, 22);
ControlVidOtboraG := New(PRadioButtons, Init(R,
  NewSItem('~В~се',
  NewSItem('Не ну~л~евое количество', Nil))));
LinkExpertWindow^.Insert(ControlVidOtboraG);

ControlVidOtboraG^.SetData(VidOtbora);
{
  R.Assign(28, 19, 40, 20);
  LinkExpertWindow^.Insert(New(PLabel, Init(R, 'Вид отбора:', ControlVidOtboraG)));
}
LinkExpertWindow^.SelectNext(False);

CurrentLine[0]:=#0;
Refresh;
CurrentLine[0]:=#0;

c:=Desktop^.ExecView(LinkExpertWindow);

Dispose(NoScreenList2,Done);
Dispose(Control,Done);
Dispose(LinkExpertWindow,Done);

End;





procedure TLinkExpertWindow.FormReport;
Var txt : Text;
    c,w : Word;
   Space: AllStr;
      s : String;

begin
Space:='       ';
DInfoMsg('Формирую отчет.Ждите...',True);
 Assign(txt,Path^.Dat.ToTemp+'linkexp.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'linkexp.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(txt,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-00');
 Writeln(txt);
 Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'         ОТЧЕТ ПО НАИМЕНОВАНИЯМ ТОВАРА, СВЯЗАННЫМ С ЭКСП.ЗАКЛЮЧ.'+
 GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
 Writeln(txt,Space+GetExpertField(FName,LArt)+' ('+LArt+')');
 Write(txt,Space+'Вид отбора:');

 Case VidOtbora Of
 0:Writeln(txt,'Все');
 1:Writeln(txt,'Не нулевое количество');
 Else Writeln(txt);
 End;
 Writeln(txt,Space+'┌────────────────────────────────────────────────────┬─────┬─────┬─────────┐');
 Writeln(txt,Space+'│Наименования товара, связанные с маркой             │ Код │Колич│ Упаковок│');
 Writeln(txt,Space+'└────────────────────────────────────────────────────┴─────┴─────┴─────────┘'+HeaderStop);

 For c:=0 To LinkList1^.List^.Count-1 Do
  Begin
   s:=LinkList1^.GetText(c,LinkList1^.List^.Count);
   s[0]:=Chr(1+CNAme+1+CNAme+1+CArtikul+1+CKol+1+CPAck);

   While Pos('│',s)>0 Do
    Begin
     w:=Pos('│',s);
     System.Delete(s,w,1);
     System.Insert(' ',s,w);
    End;

   Writeln(txt,Space+s)
  End;
 Writeln(txt,Space+'────────────────────────────────────────────────────────────────────────────');
 Writeln(txt,Space+' Всего позиций: ',LinkList1^.List^.Count:6);
 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'============================================================================');
 System.Close(txt);
NoInfoMsg;
ReportNew(Path^.Dat.ToTemp+'linkexp.txt','',1,False,False);
End;


procedure TLinkExpertWindow.Refresh;
Var SKol : ArtikulStr;
    c : Word;
    R : TRect;
    s : String;
begin
DInfoMsg('Минуточку...',True);
LinkList1^.NewList(Nil);
LinkList1^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList2^.List^.Count>0 Then
 For c:=0 To NoScreenList2^.List^.Count-1 Do
  Begin
   s:=NoScreenList2^.GetText(c,NoScreenList2^.List^.Count);
   SKol:=Copy(s,1+CNAme+1+CName+1+CArtikul+1,CKol);
   If ((StrToInt(Skol)>0)And (VidOtbora=1)) Or (VidOtbora=0) Then
   Begin
    LinkList1^.List^.Insert(NewStr(s));
    LinkList1^.SetRange(LinkList1^.List^.Count);
   End;
  End;
LinkList1^.FocusItem(0);

Dispose(ControlCount,Done);
R.Assign(2, 21, 25, 22);
ControlCount := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList1^.List^.Count,CLitr+1), $4E));
LinkExpertWindow^.Insert(ControlCount);
NoInfoMsg;

CurrentLine[0]:=#0;

End;

procedure TLinkExpertWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var Prom : Word;
    Art : ArtikulStr;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
        cmReestrReport:Begin
                        If LinkList1^.List^.Count>0 Then FormReport;
                        ClearEvent(Event);
                       End;
 cmFindLink:Begin
             Art:=Copy(LinkList1^.GetText(LinkList1^.Focused,LinkList1^.List^.Count),1+CName+1+CName+1,Cartikul);
             Lnk^.Start(Art);
             ClearEvent(Event);
            End;
 cmViewPrihodTovar:
            Begin
             Art:=Copy(LinkList1^.GetText(LinkList1^.Focused,LinkList1^.List^.Count),1+CName+1+CName+1,Cartikul);
             FP^.FindScreenPrh(Art);
             ClearEvent(Event);
            End;

        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);

 If (Desktop^.Current=PView(LinkExpertWindow)) And (Event.What <> EvKeyDown) Then
     Begin
          if (ControlVidOtboraG^.State and sfFocused <> 0)Then
              Begin
               ControlVidOtboraG^.GetData(Prom);
               If Prom <> VidOtbora Then
               Begin
                  VidOtbora:=Prom;
                  Refresh;
                  Redraw;
               End;
              End;
      DrawCurrent;
     End;
End;



Procedure TLinkExpertWindow.DrawCurrent;
Var st : String;
    R : TRect;
Begin
if (LinkList1^.List<>Nil)And(LinkList1^.List^.Count>=1) Then
 Begin
  st:=LinkList1^.GetText(LinkList1^.Focused,LinkList1^.List^.Count);
  If st <> CurrentLine Then
   Begin
    CurrentLine:=St;
    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlMarka,Done);
    R.Assign(16, 16, 56, 17);
    ControlMarka := New(PColoredText, Init(R, st, $7E));
    LinkExpertWindow^.Insert(ControlMarka);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1,
    CNSertif);
    DelSpaceRight(st);
    Dispose(ControlNGTD,Done);
    R.Assign(16, 17, 77, 18);
    ControlNGTD := New(PColoredText, Init(R, st, $7E));
    LinkExpertWindow^.Insert(ControlNGTD);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlVirabotano,Done);
    R.Assign(16, 18, 77, 19);
    ControlVirabotano := New(PColoredText, Init(R, St, $7E));
    LinkExpertWindow^.Insert(ControlVirabotano);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1+CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlDo,Done);
    R.Assign(16, 19, 77, 20);
    ControlDo := New(PColoredText, Init(R, St, $7E));
    LinkExpertWindow^.Insert(ControlDo);


    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1+CNSertif+1+CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlGroup,Done);
    R.Assign(16, 20, 77, 21);
    ControlGroup := New(PColoredText, Init(R, St, $7E));
    LinkExpertWindow^.Insert(ControlGroup);
   End;
 End
 Else
  Begin
   PStaticText(ControlMarka)^.GetText(st);
   If St<>'???' Then
   Begin
   Dispose(ControlMarka,Done);
   R.Assign(16, 16, 56, 17);
   ControlMarka := New(PColoredText, Init(R, '???', $7E));
   LinkExpertWindow^.Insert(ControlMarka);

   Dispose(ControlNGTD,Done);
   R.Assign(7, 17, 47, 18);
   ControlNGTD := New(PColoredText, Init(R, '???', $7E));
   LinkExpertWindow^.Insert(ControlNGTD);

   Dispose(ControlVirabotano,Done);
   R.Assign(16, 18, 77, 19);
   ControlVirabotano := New(PColoredText, Init(R, '???', $7E));
   LinkExpertWindow^.Insert(ControlVirabotano);

   Dispose(ControlDo,Done);
   R.Assign(16, 19, 77, 20);
   ControlDo := New(PColoredText, Init(R, '???', $7E));
   LinkExpertWindow^.Insert(ControlDo);

   Dispose(ControlGroup,Done);
   R.Assign(16, 20, 77, 21);
   ControlGroup := New(PColoredText, Init(R, '???', $7E));
   LinkExpertWindow^.Insert(ControlGroup);
   End;
  End;
End;


Destructor TLinkExpertWindow.Done;
Begin
TDialog.Done;
End;







Function SelOtkuda:Word;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  s1,s2,s3,s4 : AllStr;
begin
R.Assign(23, 9, 57, 15);
New(Dlg, Init(R, 'Укажите склад для заявки'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


{
s1:=GetMAkeField(FMake,'0004',1);
Format(s1,CClient);
}

If StrToInt(Rek^.Dat.Kod)=10 Then
s1:=GetMAkeField(FMake,'0011',1){резервный продмаркета}
Else
s1:=GetMAkeField(FMake,'0004',1){резервный};
Format(s1,CClient);

s2:=GetMAkeField(FMake,'0009',1);
Format(s2,CClient);
s3:=GetMAkeField(FMake,'0001',1);
Format(s3,CClient);
s4:='ЗАРЕЗЕРВИРОВАНО '{GetMAkeField(FMake,'????',1)};
Format(s3,CClient);

R.Assign(1, 1, 33, 5);
If StrToInt(Rek^.Dat.Kod)=10 Then
Control := New(PRadioButtons, Init(R,
  NewSItem(s1+' (0011)',
  NewSItem(s3+' (0001)',
  NewSItem(s2+' (0009)',
  NewSItem(s4+' (????)',
  Nil))))))
  Else
Control := New(PRadioButtons, Init(R,
  NewSItem(s1+' (0004)',
  NewSItem(s3+' (0001)',
  NewSItem(s2+' (0009)',
  NewSItem(s4+' (????)',
  Nil))))));

Dlg^.Insert(Control);

c:=0;
Dlg^.SetDAta(c);
Dlg^.SelectNext(False);
c:=Desktop^.execView(Dlg);
If c<>cmCAncel Then
 Begin
   Dlg^.GetDAta(c);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelOtkuda:=c;
 End
 Else
  Begin
   SelOtkuda:=4;
   Dispose(Control,Done);
   Dispose(Dlg,Done);
  End;
end;


Function SelectEditRegim:Word;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  s1,s2,s3,s4 : AllStr;
begin
c:=0;
SelectEditRegim:=0;
R.Assign(28, 9, 51, 13);
New(Dlg, Init(R, 'Редактировать'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

R.Assign(1, 1, 22, 3);
Control := New(PRadioButtons, Init(R,
  NewSItem('Текущую позицию',
  NewSItem('Главную позицию', Nil))));
Dlg^.Insert(Control);
Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCAncel Then
 Begin
   Dlg^.GetDAta(c);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectEditRegim:=c;
 End
 Else
  Begin
   SelectEditRegim:=2;
   Dispose(Control,Done);
   Dispose(Dlg,Done);
  End;
end;



procedure TLinkKSertifWindow.Start(LinkArt:ArtikulStr);
var
  R : TRect;
  Control : PView;
  RazdelFile : RazdelFileType;
  RazdelElement : PRazdelType;
  FSkl : File;
  Count,C,i : Word;
  BF : File;
  BE : PBufBazType;
  SArt,SKol : AllStr;
  s : String;
  st : TMyString;
  Find : Boolean;
  Skl : PSkladType;
begin

LArt:=LinkArt;


R.Assign(0,0,0,0);
NoScreenList2 := New(PBox, Init(R, 1, Nil));
NoScreenList2^.NewList(New(PTextCollection, Init(0,1)));


Assign(RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
i:=IOResult;
Reset(RazdelFile);
i:=IOResult;
Find:=False;
If i=0 Then
 Begin
  New(RazdelElement,Init);
  While Not(Eof(Razdelfile)) Do
   Begin
    Read(RazdelFile,RazdelElement^.Dat);

    DInfoMsgShkala('Идет поиск связанных с объектом наименований в разделе '+RazdelElement^.Dat.Kod+'. Ждите...',
    1,EmployRazdel,StrToInt(RazdelElement^.Dat.Kod)+1);
    If (RazdelElement^.Dat.Employ) And (Razdelelement^.Dat.EnableDoc=1) Then
     Begin
      Assign(bf,Path^.Dat.ToName+RazdelElement^.Dat.Kod+'.id');
      i:=ioresult;
      reset(bf,SizeOf(BazType));
      i:=ioresult;
      If i=0 Then
       Begin
        While Not(Eof(bf)) Do
         Begin
          New(be,Init);
          ReadBufBaz(Bf,be,Count);
          For c:=1 To Count Do
Begin
          If Be^.Point.Dat[c].Employ Then
          If StrToInt(Be^.Point.Dat[c].KSertif)=StrToInt(LinkArt) Then
           Begin
            Find:=True;
            s[0]:=#0;
            st:=Be^.Point.Dat[c].Name;
            DelSpaceRight(st);
            s:=st;
            st:=Be^.Point.Dat[c].Name2;
            DelSpaceRight(st);
            s:=s+' '+st;
            Format(s,CName+1+CNAme);

            New(Skl,Init);
            Skl^.Dat.BazKod:=Be^.Point.Dat[c].BazKod;
            GetSkladRecord(Skl);

            SKol:=IntToStr(StrToInt(Skl^.Dat.Input.Kol),CKOl);
            RFormat(SKol,CKol);
            SArt:=IntToStr(StrToInt(Be^.Point.Dat[c].BazKod),CArtikul);
            RFormatZerro(SArt,CArtikul);
            st:=CalcPack(SArt,SKol);
            DelSpace(st);
            RFormat(st,CPAck);
            s:=s+'│'+SArt+'│'+SKol+'│'+st;


            SArt:=IntToStr(StrToInt(Skl^.Dat.Input.Marka),CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetMarkaField(FMarka,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CKSertif);
            s:=s+'│'+st;


            SArt:=IntToStr(StrToInt(Skl^.Dat.Input.Expert),CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetExpertField(FExpert,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CKSertif);
            s:=s+'│'+st;



            SArt:=IntToStr(StrToInt(Skl^.Dat.Input.NSertif),CArtikul);
            RFormatZerro(SArt,CArtikul);
            St:=GetIdField(FFFName,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNSertif);
            s:=s+'│'+st;

            Dispose(Skl,Done);


            SArt:=IntToStr(StrToInt(Be^.Point.Dat[c].FirmaPostKod),CClientKod);
            RFormatZerro(SArt,CClientKod);
            St:=GetFirmaPostField(FFirmaPost,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNSertif);
            s:=s+'│'+st;


            SArt:=IntToStr(StrToInt(Be^.Point.Dat[c].BazKod),CArtikul);
            RFormatZerro(SArt,CArtikul);
            SArt:=GetIDField(FGroup,SArt);
            RFormatZerro(SArt,CClientKod);
            St:=GetGroupField(FName,SArt);
            st:=St+' ['+SArt+']';
            Format(st,CNSertif);
            s:=s+'│'+st;

            {
            St:=Be^.Point.Dat[c].Godnost;
            Format(st,CDate);
            s:=s+'│'+st;
            }

      If NoScreenList2^.List^.Count>=MaxCollectionSize-10 Then
      Begin
       MessageBox(^M+#3+'Переполнение коллекции!',Nil,mfError+mfCancelButton);
       Break;
      End;


            NoScreenList2^.List^.Insert(NewStr(s));
            NoScreenList2^.SetRange(NoScreenList2^.List^.Count);
           End;
End;{For}
         Dispose(BE,Done);
         End;{While}
         System.Close(BF);
       End
       Else
        Begin
            NoInfoMsg;
            MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToSklad+RazdelElement^.Dat.Kod+'.db!'+
            ClicProgrammer^,Nil,mfError+mfCancelButton);
        End;
     End;
   End;
  NoInfoMsg;
  System.Close(RazdelFile);
  Dispose(RazdelElement,Done);
 End
Else
Begin
 MessageBox(^M+#3+'Ошибка открытия файла разделов '+Path^.Dat.ToRazdel+'razdel.db! '+
            ClicProgrammer^,Nil,
            mfError+mfCancelButton);
 Exit;
End;


If Not(Find) Then
 Begin
  Dispose(NoScreenList2,Done);
  MessageBox(^M+#3'С данным объектом не связано ни один элемент!',
             Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(1, 2, 79, 24);
New(LinkKSertifWindow, Init(R, ''));
LinkKSertifWindow^.Options := LinkKSertifWindow^.Options or ofCenterX or ofCenterY;
LinkKSertifWindow^.HelpCtx:=$F941;

R.Assign(77, 4, 78, 16);
Control := New(PScrollBar, Init(R));
LinkKSertifWindow^.Insert(Control);

R.Assign(1, 4, 77, 16);
LinkList1 := New(PBox, Init(R, 1, PScrollbar(Control)));
LinkList1^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList2^.List^.Count-1>=0 Then
 For c:=0 To NoScreenList2^.List^.Count-1 Do
  Begin
   s:=NoScreenList2^.GetText(c,NoScreenList2^.List^.Count);
   LinkList1^.List^.Insert(NewStr(s));
   LinkList1^.SetRange(LinkList1^.List^.Count);
  End;
LinkList1^.FocusItem(0);
LinkKSertifWindow^.Insert(LinkList1);


  R.Assign(1, 3, 77, 4);
  LinkKSertifWindow^.Insert(New(PLabel, Init(R, 'Наименования, связанные с органом сертификации         Код  Колич  Упаковок',
  LinkList1)));

R.Assign(14, 1, 75, 2);
st:=GetKSertifField(FKSertif,LinkArt);
DelSpaceRight(st);
Control := New(PColoredText, Init(R, st+'('+LinkArt+')', $7E));
LinkKSertifWindow^.Insert(Control);

R.Assign(3, 1, 14, 2);
Control := New(PColoredText, Init(R, 'Орган серт:', $74));
LinkKSertifWindow^.Insert(Control);

R.Assign(2, 21, 25, 22);
ControlCount1 := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList1^.List^.Count,CLitr+1), $4E));
LinkKSertifWindow^.Insert(ControlCount1);

R.Assign(1, 16, 16, 17);
Control := New(PColoredText, Init(R, '         Марка:', $74));
LinkKSertifWindow^.Insert(Control);

R.Assign(16, 16, 56, 17);
ControlMarka1 := New(PColoredText, Init(R, '???', $7E));
LinkKSertifWindow^.Insert(ControlMarka1);

R.Assign(16, 17, 77, 18);
ControlKSertif1 := New(PColoredText, Init(R, '???', $7E));
LinkKSertifWindow^.Insert(ControlKSertif1);

R.Assign(1, 17, 16, 18);
Control := New(PColoredText, Init(R, Expert_RegNom^+':', $74));
LinkKSertifWindow^.Insert(Control);

R.Assign(1, 18, 16, 19);
Control := New(PColoredText, Init(R, '    Сертификат:', $74));
LinkKSertifWindow^.Insert(Control);

R.Assign(16, 18, 77, 19);
ControlVirabotano1 := New(PColoredText, Init(R, '???', $7E));
LinkKSertifWindow^.Insert(ControlVirabotano1);

R.Assign(16, 19, 77, 20);
ControlDo1 := New(PColoredText, Init(R, '???', $7E));
LinkKSertifWindow^.Insert(ControlDo1);

R.Assign(1, 19, 16, 20);
Control := New(PColoredText, Init(R, 'Фирма-производ:', $74));
LinkKSertifWindow^.Insert(Control);


R.Assign(1, 20, 16, 21);
Control := New(PColoredText, Init(R, '        Группа:', $74));
LinkKSertifWindow^.Insert(Control);

R.Assign(16, 20, 77, 21);
ControlGroup1 := New(PColoredText, Init(R, '???', $7E));
LinkKSertifWindow^.Insert(ControlGroup1);



VidOtbora1:=0;

R.Assign(40, 21, 76, 22);
ControlVidOtboraG1 := New(PRadioButtons, Init(R,
  NewSItem('~В~се',
  NewSItem('Не ну~л~евое количество', Nil))));
LinkKSertifWindow^.Insert(ControlVidOtboraG1);

ControlVidOtboraG1^.SetData(VidOtbora1);
{
  R.Assign(28, 19, 40, 20);
  LinkKSertifWindow^.Insert(New(PLabel, Init(R, 'Вид отбора:', ControlVidOtboraG)));
}
LinkKSertifWindow^.SelectNext(False);

CurrentLine[0]:=#0;
Refresh;
CurrentLine[0]:=#0;

c:=Desktop^.ExecView(LinkKSertifWindow);

Dispose(NoScreenList2,Done);
Dispose(Control,Done);
Dispose(LinkKSertifWindow,Done);

End;





procedure TLinkKSertifWindow.FormReport;
Var txt : Text;
    c,w : Word;
   Space: AllStr;
      s : String;

begin
Space:='       ';
DInfoMsg('Формирую отчет.Ждите...',True);
 Assign(txt,Path^.Dat.ToTemp+'linkkse.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'linkkse.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(txt,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-00');
 Writeln(txt);
 Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'         ОТЧЕТ ПО НАИМЕНОВАНИЯМ ТОВАРА, СВЯЗАННЫМ С ГТД'+
 GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
 Writeln(txt,Space+GetKSertifField(FName,LArt)+' ('+LArt+')');
 Write(txt,Space+'Вид отбора:');

 Case VidOtbora Of
 0:Writeln(txt,'Все');
 1:Writeln(txt,'Не нулевое количество');
 Else Writeln(txt);
 End;
 Writeln(txt,Space+'┌────────────────────────────────────────────────────┬─────┬─────┬─────────┐');
 Writeln(txt,Space+'│Наименования, связанные с объектом                  │ Код │Колич│ Упаковок│');
 Writeln(txt,Space+'└────────────────────────────────────────────────────┴─────┴─────┴─────────┘'+HeaderStop);

 For c:=0 To LinkList1^.List^.Count-1 Do
  Begin
   s:=LinkList1^.GetText(c,LinkList1^.List^.Count);
   s[0]:=Chr(1+CNAme+1+CNAme+1+CArtikul+1+CKol+1+CPAck);

   While Pos('│',s)>0 Do
    Begin
     w:=Pos('│',s);
     System.Delete(s,w,1);
     System.Insert(' ',s,w);
    End;

   Writeln(txt,Space+s)
  End;
 Writeln(txt,Space+'────────────────────────────────────────────────────────────────────────────');
 Writeln(txt,Space+' Всего позиций: ',LinkList1^.List^.Count:6);
 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'============================================================================');
 System.Close(txt);
NoInfoMsg;
ReportNew(Path^.Dat.ToTemp+'linkkse.txt','',1,False,False);
End;


procedure TLinkKSertifWindow.Refresh;
Var SKol : ArtikulStr;
    c : Word;
    R : TRect;
    s : String;
begin
DInfoMsg('Минуточку...',True);
LinkList1^.NewList(Nil);
LinkList1^.NewList(New(PTextCollection, Init(0,1)));

If NoScreenList2^.List^.Count>0 Then
 For c:=0 To NoScreenList2^.List^.Count-1 Do
  Begin
   s:=NoScreenList2^.GetText(c,NoScreenList2^.List^.Count);
   SKol:=Copy(s,1+CNAme+1+CName+1+CArtikul+1,CKol);
   If ((StrToInt(Skol)>0)And (VidOtbora=1)) Or (VidOtbora=0) Then
   Begin
    LinkList1^.List^.Insert(NewStr(s));
    LinkList1^.SetRange(LinkList1^.List^.Count);
   End;
  End;
LinkList1^.FocusItem(0);

Dispose(ControlCount1,Done);
R.Assign(2, 21, 25, 22);
ControlCount1 := New(PColoredText, Init(R, 'Всего позиций: '+IntToStr(LinkList1^.List^.Count,CLitr+1), $4E));
LinkKSertifWindow^.Insert(ControlCount1);
NoInfoMsg;

CurrentLine[0]:=#0;

End;

procedure TLinkKSertifWindow.HandleEvent(var Event: TEvent);


procedure Calculator;
begin
  Calc^.Start;
end;

Var Art : AllStr;
    Prom : Word;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;

 cmFindLink:Begin
             Art:=Copy(LinkList1^.GetText(LinkList1^.Focused,LinkList1^.List^.Count),1+CName+1+CName+1,Cartikul);
             Lnk^.Start(Art);
             ClearEvent(Event);
            End;

 cmViewPrihodTovar:
            Begin
             Art:=Copy(LinkList1^.GetText(LinkList1^.Focused,LinkList1^.List^.Count),1+CName+1+CName+1,Cartikul);
             FP^.FindScreenPrh(Art);
             ClearEvent(Event);
            End;

        cmReestrReport:Begin
                        If LinkList1^.List^.Count>0 Then FormReport;
                        ClearEvent(Event);
                       End;
        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);

 If (Desktop^.Current=PView(LinkKSertifWindow)) And (Event.What <> EvKeyDown) Then
     Begin
          if (ControlVidOtboraG1^.State and sfFocused <> 0)Then
              Begin
               ControlVidOtboraG1^.GetData(Prom);
               If Prom <> VidOtbora1 Then
               Begin
                  VidOtbora1:=Prom;
                  Refresh;
                  Redraw;
               End;
              End;
      DrawCurrent;
     End;
End;



Procedure TLinkKSertifWindow.DrawCurrent;
Var st : String;
    R : TRect;
Begin
if (LinkList1^.List<>Nil)And(LinkList1^.List^.Count>=1) Then
 Begin
  st:=LinkList1^.GetText(LinkList1^.Focused,LinkList1^.List^.Count);
  If st <> CurrentLine Then
   Begin
    CurrentLine:=St;
    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlMarka1,Done);
    R.Assign(16, 16, 56, 17);
    ControlMarka1 := New(PColoredText, Init(R, st, $7E));
    LinkKSertifWindow^.Insert(ControlMarka1);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1,
    CNSertif);
    DelSpaceRight(st);
    Dispose(ControlKSertif1,Done);
    R.Assign(16, 17, 77, 18);
    ControlKSertif1 := New(PColoredText, Init(R, st, $7E));
    LinkKSertifWindow^.Insert(ControlKSertif1);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlVirabotano1,Done);
    R.Assign(16, 18, 77, 19);
    ControlVirabotano1 := New(PColoredText, Init(R, St, $7E));
    LinkKSertifWindow^.Insert(ControlVirabotano1);

    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1+CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlDo1,Done);
    R.Assign(16, 19, 77, 20);
    ControlDo1 := New(PColoredText, Init(R, St, $7E));
    LinkKSertifWindow^.Insert(ControlDo1);


    st:=Copy(CurrentLine,1+CName+1+CName+1+CArtikul+1+CKol+1+CPack+1+CNSertif+1+
    CNSertif+1+CNSertif+1+CNSertif+1,CNSertif);
    DelSpaceRight(st);
    Dispose(ControlGroup1,Done);
    R.Assign(16, 20, 77, 21);
    ControlGroup1 := New(PColoredText, Init(R, St, $7E));
    LinkKSertifWindow^.Insert(ControlGroup1);
   End;
 End
 Else
  Begin
   PStaticText(ControlMarka1)^.GetText(st);
   If St<>'???' Then
   Begin
   Dispose(ControlMarka1,Done);
   R.Assign(16, 16, 56, 17);
   ControlMarka1 := New(PColoredText, Init(R, '???', $7E));
   LinkKSertifWindow^.Insert(ControlMarka1);

   Dispose(ControlKSertif1,Done);
   R.Assign(7, 17, 47, 18);
   ControlKSertif1 := New(PColoredText, Init(R, '???', $7E));
   LinkKSertifWindow^.Insert(ControlKSertif1);

   Dispose(ControlVirabotano1,Done);
   R.Assign(16, 18, 77, 19);
   ControlVirabotano1 := New(PColoredText, Init(R, '???', $7E));
   LinkKSertifWindow^.Insert(ControlVirabotano1);

   Dispose(ControlDo1,Done);
   R.Assign(16, 19, 77, 20);
   ControlDo1 := New(PColoredText, Init(R, '???', $7E));
   LinkKSertifWindow^.Insert(ControlDo1);

   Dispose(ControlGroup1,Done);
   R.Assign(16, 20, 77, 21);
   ControlGroup1 := New(PColoredText, Init(R, '???', $7E));
   LinkKSertifWindow^.Insert(ControlGroup1);
   End;
  End;
End;


Destructor TLinkKSertifWindow.Done;
Begin
TDialog.Done;
End;





End.