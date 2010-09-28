{
┌───────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬─────────┬──────────┬────
──────┬──────────┬──────────┬──────────┐

│ Дата  │Приход    │Сумма     │Доходность│Доходность│ Расходы  │  Р/П     │  Сдано   │ Выдано   │Возврат  │Остаток   │Выдано СФ
 │Упущенный │Скидки    │Ревизии   │
│       │на склад  │со склада │отгрузка  │оплата    │          │          │          │ по ВЗ    │на склад │консигн.  │
 │доход     │отгрузки  │на складе │
└───────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴─────────┴──────────┴─────────
─┴──────────┴──────────┴──────────┘

12345678│1234567890│1234567890│1234567890│1234567890│1234567890│1234567890 1234567890│1234567890 123456780 1234567890 123456789
0 1234567890│1234567890│1234567890
}

{$I Compile.INC}
{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

unit Ukassa;

Interface

Uses Dialogs,Drivers,ServStr,MyCalc,Glob,Objects;

Type KassaType = Record
                       SummaInKassa : String[CIZENA];
                     OstatokInKassa : String[CIZENA];
                              Sdano : String[CIZENA];
                      ExtendedDohod : String[CIZENA];
                             Rashod : String[CIZENA];
                           DohodAll : String[CIZENA];
                         DohodAgent : String[CIZENA];
                        DohodSertif : String[CIZENA];
                             Prihod : String[CIZena];{9}
                            Ostatok : String[CIZena];{10}
                                 RP : String[CIZena];{11}
                           SertifRP : String[CIZena];{11}
                      SummaOutSklad : String[CIZena];{12}
                            Prodagi : String[CIZena];{13}
                          SkProdagi : String[CIZena];{14}
                      SertifProdagi : String[CIZena];{13}
                    SertifSkProdagi : String[CIZena];{14}
                       VidanoConsig : String[CIZena];{15}
                     SkVidanoConsig : String[CIZENA];{16}
                      OplataINKassa : String[CIZENA];{17}
                     SkOformConsign : String[CIZENA];{18}
                ReturnOutOpenConsig : String[CIZENA];{19}
              SkReturnOutOpenConsig : String[CIZENA];{20}
   ReturnOutMArketDocAndCloseConsig : String[CIZENA];{21}
 SkReturnOutMArketDocAndCloseConsig : String[CIZENA];{22}
                      OstatokConsig : String[CIZENA];{23}
                    SkOstatokConsig : String[CIZENA];{24}
                         Pereozenka : String[CIZENA];{25}
               PereozenkaFromReturn : String[CIZENA];{26}
                   RashodFromReturn : String[CIZENA];{27}
         RashodFromReturnOpenConsig : String[CIZENA];{28}
                           VidanoSF : String[CIZENA];{29}
                            Rewisia : String[CIZENA];{30}
                            SNalogP : String[CIZENA];{31}
                            SNalogC : String[CIZENA];{32}
             SNalogReturnOpenConsig : String[CIZENA];{33}
                      OstatokBarter : String[CIZENA];{34}
                       BarterPrihod : String[CIZENA];{35}
                     BarterPrihodRZ : String[CIZENA];{36}
                            BarterT : String[CIZENA];{37}
                       BarterSkidki : String[CIZENA];{38}
                      SertifBarterT : String[CIZENA];{37}
                 SertifBarterSkidki : String[CIZENA];{38}
                      BarterInKassa : String[CIZENA];{39}
                     BarterOutKassa : String[CIZENA];{40}
                     BNOPlataConsig : String[CIZENA];{безналичные оплаты консигнации}
                          BNProdagi : String[CIZENA];{безналичные консигнации в кассу}
                    BNBarterInKassa : String[CIZENA];{безналичные поступления по бартеру
                                                      является составной частью BarterInKassa}
                   BNBarterOutKassa : String[CIZENA];{безналичные расходы по бартеру
                                                                  является составной частью BarterOutKassa}
                {=} OstatokPereplatN: String[CIZENA];{остаток наличных переплат(всегда больше "0")}
                {=} OstatokPereplatB: String[CIZENA];{остаток безналичных переплат(всегда больше "0")}
                {=} OstatokPereplatV: String[CIZENA];{остаток вексельных переплат(всегда больше "0")}
                    {+}NewPereplatN : String[CIZENA];{новые поступления переплат наличные}
                    {+}NewPereplatB : String[CIZENA];{новые поступления переплат безналичные}
                    {+}NewPereplatV : String[CIZENA];{новые поступления переплат по векселю}
                 {-}RashodPereplatN : String[CIZena];{списание переплат наличных}
                 {-}RashodPereplatB : String[CIZena];{списание переплат безналичных}
                 {-}RashodPereplatV : String[CIZena];{списание переплат вексельных}
{+}                   OstatokAkzis  : String[CIZena];{остаток на складе акциза}
                      ProdagiCAkzis : String[CIZena];{акцизный сбор по накладным без отсрочки клиентам}
                      ProdagiSAkzis : String[CIZena];{акцизный сбор по накладным межскладским}
                      ProdagiBAkzis : String[CIZena];{акцизный сбор по накладным обмен}
                  VidanoConsigAkzis : String[CIZena];{акцизный сбор на консигнацию}
               OformlenoConsigAkzis : String[CIZena];{акцизный сбор на консигнацию}
                      PrihodCAkzis  : String[CIZena];{акцизный сбор по приходам от клиента}
                      PrihodSAkzis  : String[CIZena];{акцизный сбор по приходам от склада}
                      PrihodBAkzis  : String[CIZena];{акцизный сбор по приходам в обмен}
                      ReturnCAkzis  : String[CIZena];{акцизный сбор по возврату от клиента}
                      ReturnSAkzis  : String[CIZena];{акцизный сбор по возврату от склада}
                      RevisiaAkZis  : String[CIZena];{акцизный сбор по ревизии от склада}

   PerewoskiOut  : TItogString;
   PerewoskiInp  : TItogString;
   EPerewoskiOut : String[CIZENA];{63}
   EPerewoskiInp : String[CIZENA];{64}

                            ReportKassa: String[CIZena];
                            {закупочные цены}
                            PrihodZC: String[CIZena];
                            PrihodZS: String[CIZena];
                            PrihodZB: String[CIZena];
                           OstatokZ : String[CIZena];
                     OstatokConsigZ : String[CIZena];
                           RewisiaZ : String[CIZENA];
                            ReturnZ : String[CIZENA];
                          MinusDohod: String[CIZENA];
                            AllDohod: String[CIZENA];
                           AllDohodA: String[CIZENA];
                           AllDohodB: String[CIZENA];
                           AllDohodS: String[CIZENA];
                          OtgruzkaZC: String[CIZENA];
                          OtgruzkaZS: String[CIZENA];
                          OtgruzkaZB: String[CIZENA];
                         OtgruzkaZRP: String[CIZENA];

                            {закупочные цены2}
                            PrihodZC2: String[CIZena];
                            PrihodZS2: String[CIZena];
                            PrihodZB2: String[CIZena];
                           OstatokZ2 : String[CIZena];
                           RewisiaZ2 : String[CIZENA];
                            ReturnZ2 : String[CIZENA];
                          MinusDohod2: String[CIZENA];
                            AllDohod2: String[CIZENA];
                           AllDohodA2: String[CIZENA];
                           AllDohodB2: String[CIZENA];
                           AllDohodS2: String[CIZENA];
                          OtgruzkaZC2: String[CIZENA];
                          OtgruzkaZS2: String[CIZENA];
                          OtgruzkaZB2: String[CIZENA];
                         OtgruzkaZRP2: String[CIZENA];
                            OstatokAZ: String[CIZENA];
                           OstatokAZ2: String[CIZENA];
                            OstatokNZ: String[CIZENA];
                           OstatokNZ2: String[CIZENA];

{фармпартнер}
                               Otkat: String[CIZENA];{остаток отката}
                            AddOtkat: String[CIZENA];{добавление новых откатов}
                           KillOtkat: String[CIZENA];{гашение новых откатов}
                      KillOtkatToDay: String[CIZENA];{гашение новых откатов}
                        OtgruzkaWithOplataWithOutAkzis: String[CIZENA];{по базовым ценам}

   PerewoskiOutZ  : TItogString;{входящие перевозки по закупке}{41-47}
   PerewoskiInpZ  : TItogString;{исходящие перевозки по закупке}{48-62}
   PerewoskiOutZ2  : TItogString;{входящие перевозки по закупке}{41-47}
   PerewoskiInpZ2  : TItogString;{исходящие перевозки по закупке}{48-62}

   Caption       : String[CRazdelKod];{65}
   DateC,TimeC,DateM,TimeM:TDateString;{66-69}
   End;


Type
    PKassaType = ^KassaPtr;
    KassaPtr=Object(TObject)
    Dat  :  KassaType;
     Constructor Init;
     Procedure FormatReal;
     Destructor Done; Virtual;
 end;



Type
  PKassaWindow = ^TKassaWindow;
  TKassaWindow = object(TDialog)
    Calc     : PMyCalculator;
    Procedure Start(Mode:Boolean);
    Procedure KassaToList(kk:PKassaType);
    Procedure ListToKassa(Var kk:PKassaType);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done; virtual;
  end;

Type
  PBarterItogWindow = ^TBarterItogWindow;
  TBarterItogWindow = object(TDialog)
   Calc        : PMyCalculator;
    Procedure OpenViewBarterItog;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done; virtual;
  end;

Type
  PSertifItogWindow = ^TSertifItogWindow;
  TSertifItogWindow = object(TDialog)
   Calc        : PMyCalculator;
    Procedure OpenViewSertifItog;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done; virtual;
  end;


Type
  PBNItogWindow = ^TBNItogWindow;
  TBNItogWindow = object(TDialog)
   Calc        : PMyCalculator;
    Procedure OpenViewBNItog;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done; virtual;
  end;


Type
  PItogWindow = ^TItogWindow;
  TItogWindow = object(TDialog)
   Calc        : PMyCalculator;
         Brt: PBarterItogWindow;
         Srt: PSertifItogWindow;
         BN : PBNItogWindow;
            KW : PKassaWindow;
    procedure ShowDohod;
    Procedure OpenViewItog;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done; virtual;
  end;



Type PsevdoKassaType = record
     SummaInKassa : String[CIZENA];
   OstatokInKassa : String[CIZENA];
            Sdano : String[CIZENA];
    ExtendedDohod : String[CIZENA];
           Rashod : String[CIZENA];
       Sertifikat : String[CIZENA];
         DohodAll : String[CIZENA];
       DohodAgent : String[CIZENA];
       DohodSertif: String[CIZENA];
  end;




Implementation


uses Views, MsgBox,Vision10,Validate,Access3,Access1,DBEngine,Utils1,Utils5,
     TPDate,Vision1,Vision4,Vision8,Vision5,Vision7,Vision2,App, Serv,
	ColorTxt,ServStr2,
     Protect,Prihod,Return,NetDbEng,Printers,Net,Utils,Tools,UKassaT;

{Const amReadOnly=0;}

Function CalcOutSkladPerevoski (ClientKod : ArtikulStr):AllStr;
Var
    st : AllStr;
    l : Real;
    MarketFile : File{MArketFileType};
    {E : PSuperMarketType;}
    e : PBufSuperMarketTypeIDX;
    BakFileMode:Word;
    i : Word;
    cc,Count : Word;
begin
 CalcOutSkladPerevoski:='0.00';
 l:=0;
 If GetClientEmploy(ClientKod,1) Then
 Begin
    Assign(MarketFile,Path^.Dat.ToMarketIndex+FDate+'.mrx');
    i:=IOResult;
    BakFileMode:=FileMode;
    FileMode:=$42;
    Reset(MArketFile,SizeOf(SuperMarketTypeIDX));
    i:=IOResult;
    FileMode:=BakFileMode;
    l:=0;

    If i=0 Then
     Begin
      While Not(Eof(MArketFile)) Do
       Begin

    New(E,Init);
    {ReadBufMarket}ReadBufHeaderMarket(MarketFile,e,Count);
For cc:=1 To Count Do
Begin
        If(E^.Point.Dat[cc].OperatorSelector=1)And(StrToInt(E^.Point.Dat[cc].ClientKod)=StrToInt(ClientKod))
          And(E^.Point.Dat[cc].Active) Then
         Begin
          l:=l+E^.Point.Dat[cc].SummaZ+E^.Point.Dat[cc].SertifSummaZ;
         End;
End;{For}
      Dispose(E,Done);
       End;
      Close(MarketFile);
     End

     Else
      Exit;

 End;

MyStr(L,CIZena,CMantissa,st);
DelSpace(St);
CalcOutSkladPerevoski:=st;
end;

Function CalcInpSkladPerevoski (ClientKod : ArtikulStr):AllStr;
Var
    st : AllStr;
    l : Real;
    PrihodFile : PrihodFileType;
    E : PPrihodType;
    i : Word;
begin
 CalcInpSkladPerevoski:='0.00';
 l:=0;
 If GetClientEmploy(ClientKod,1) Then
 Begin
    Assign(PrihodFile,Path^.Dat.ToPrihod+FDate+'.prh');
    i:=IOResult;
    Reset(PrihodFile);
    i:=IOResult;
    l:=0;
    If i=0 Then
     Begin
      New(E,Init);
      While Not(Eof(PrihodFile)) Do
       Begin
     {
     Repeat
     Until Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType));
     }
     ReadPrihod(PrihodFile,E);
     {
     Repeat
      UnLock(PrihodFile,(FilePos(PrihodFile)-1)*SizeOf(PrihodType),SizeOf(PrihodType));
     Until (DosError=0);
     }
        If (E^.Dat.OperatorSelector=1)And(StrToInt(E^.Dat.MakeKod)=StrToInt(ClientKod))
           And(E^.Dat.StatusDoc=0) Then
         Begin
          l:=l+StrToReal(E^.DAt.SummaR);
         End;
       End;
      Dispose(E,Done);
      Close(PrihodFile);
     End
     Else
      Exit;
 End;
MyStr(L,CIZena,CMantissa,st);
DelSpace(St);
CalcInpSkladPerevoski:=st;
end;



Constructor KassaPtr.Init ;
Var i : Byte;
Begin
TObject.Init;
With DAt Do
Begin
{1}                              Prihod[0] :=#0;
{1}                            DohodAll[0] :=#0;
{1}                          DohodAgent[0] :=#0;
{1}                         DohodSertif[0] :=#0;
{2}                             Ostatok[0] :=#0;
{3}                                  RP[0] :=#0;
{3}                            SertifRP[0] :=#0;
{4}                       SummaOutSklad[0] :=#0;
{43}                            Prodagi[0] :=#0;
{44}                          SkProdagi[0] :=#0;
{43}                      SertifProdagi[0] :=#0;
{44}                    SertifSkProdagi[0] :=#0;
{5}                        VidanoConsig[0] :=#0;
{6}                      SkVidanoConsig[0] :=#0;
{7}                       OplataINKassa[0] :=#0;
{8}                      SkOformConsign[0] :=#0;
{9}                 ReturnOutOpenConsig[0] :=#0;
{10}              SkReturnOutOpenConsig[0] :=#0;
{11}   ReturnOutMArketDocAndCloseConsig[0] :=#0;
{12} SkReturnOutMArketDocAndCloseConsig[0] :=#0;
{13}                      OstatokConsig[0] :=#0;
{14}                    SkOstatokConsig[0] :=#0;
{15}                         Pereozenka[0] :=#0;
{16}               PereozenkaFromReturn[0] :=#0;
{17}                       SummaInKassa[0] :=#0;
{18}                     OstatokInKassa[0] :=#0;
{19}                      ExtendedDohod[0] :=#0;
{20}                   RashodFromReturn[0] :=#0;
{21}         RashodFromReturnOpenConsig[0] :=#0;
{21}                             Rashod[0] :=#0;
{24}                              Sdano[0] :=#0;
{25}                           VidanoSF[0] :=#0;
{26}                            Rewisia[0] :=#0;
{27}                            SNalogP[0] :=#0;
{28}                            SNalogC[0] :=#0;
{29}             SNalogReturnOpenConsig[0] :=#0;
{30}                      OstatokBarter[0] :=#0;
{30}                       BarterPrihod[0] :=#0;
{30}                     BarterPrihodRZ[0] :=#0;
{30}                            BarterT[0] :=#0;
{31}                       BarterSkidki[0] :=#0;
{30}                      SertifBarterT[0] :=#0;
{31}                 SertifBarterSkidki[0] :=#0;
{33}                      BarterInKassa[0] :=#0;
{33}                     BarterOutKassa[0] :=#0;

                               Otkat[0]:=#0;{остаток отката}
                            AddOtkat[0]:=#0;{добавление новых откатов}
                           KillOtkat[0]:=#0;
                      KillOtkatToDay[0]:=#0;
                        OtgruzkaWithOplataWithOutAkzis[0]:=#0;

                     BNOPlataConsig[0]:=#0;
                          BNProdagi[0]:=#0;
                    BNBarterInKassa[0]:=#0;
                   BNBarterOutKassa[0]:=#0;

                {=} OstatokPereplatN[0]:=#0;
                {=} OstatokPereplatB[0]:=#0;
                {=} OstatokPereplatV[0]:=#0;
                    {+}NewPereplatN [0]:=#0;
                    {+}NewPereplatB [0]:=#0;
                    {+}NewPereplatV [0]:=#0;

                    {-}RashodPereplatN[0]:=#0;
                    {-}RashodPereplatB[0]:=#0;
                    {-}RashodPereplatV[0]:=#0;

{+}                   OstatokAkzis [0]:=#0;
                      ProdagiCAkzis[0]:=#0;
                      ProdagiSAkzis[0]:=#0;
                      ProdagiBAkzis[0]:=#0;
                  VidanoConsigAkzis[0]:=#0;
                      PrihodCAkzis[0]:=#0;
                      PrihodSAkzis[0]:=#0;
                      PrihodBAkzis[0]:=#0;
                      ReturnCAkzis[0]:=#0;
                      ReturnSAkzis[0]:=#0;
                      RevisiaAkZis[0]:=#0;

                      ReportKassa[0]:=#0;

                            PrihodZC[0] :=#0;
                            PrihodZS[0] :=#0;
                            PrihodZB[0] :=#0;
                           OstatokZ[0] :=#0;
                     OstatokConsigZ[0] :=#0;
                           RewisiaZ[0] :=#0;
                            ReturnZ[0] :=#0;
                          MinusDohod[0] :=#0;
                            AllDohod[0] :=#0;
                           AllDohodA[0] :=#0;
                           AllDohodB[0] :=#0;
                           AllDohodS[0] :=#0;

                          OtgruzkaZC[0]:=#0;
                          OtgruzkaZS[0]:=#0;
                          OtgruzkaZB[0]:=#0;
                         OtgruzkaZRP[0]:=#0;

                            PrihodZC2[0]:=#0;
                            PrihodZS2[0]:=#0;
                            PrihodZB2[0]:=#0;
                           OstatokZ2 [0]:=#0;
                           RewisiaZ2 [0]:=#0;
                            ReturnZ2 [0]:=#0;
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

{44}   EPerewoskiOut[0] :=#0;
{45}   EPerewoskiInp[0] :=#0;
For i:=1 To Max30 Do
Begin
{29,30,31,32,33,34,35}
 PerewoskiInp[i,0]:=#0;
 PerewoskiInpZ[i,0]:=#0;
 PerewoskiInpZ2[i,0]:=#0;
{36,37,38,39,40,41,42}
 PerewoskiOut[i,0]:=#0;
 PerewoskiOutZ[i,0]:=#0;
 PerewoskiOutZ2[i,0]:=#0;
End;{For}
 CAption:=CurrentPassword;
 DAteC:=FDate;
 TimeC:=CurrentTimeString('hh:mm:ss');
 DAteM:=DateC;
 TimeM:=TimeC;
End;{With}
End;

Procedure KassaPtr.FormatReal;
Var i : Byte;
Begin
With DAt Do
Begin
{1}MyStr(StrToReal(DohodAll),CIZena,CMantissaZ,DohodAll);
{1}MyStr(StrToReal(DohodAgent),CIZena,CMantissaZ,DohodAgent);
{1}MyStr(StrToReal(DohodSertif),CIZena,CMantissaz,DohodSertif);
{1}MyStr(StrToReal(Prihod),CIZena,CMantissa,Prihod);
{2}MyStr(StrToReal(Ostatok),CIZena,CMantissa,Ostatok);
{3}MyStr(StrToReal(RP),CIZena,CMantissa,RP);
{3}MyStr(StrToReal(SertifRP),CIZena,CMantissa,SertifRP);
{4}MyStr(StrToReal(SummaOutSklad),CIZena,CMantissa,SummaOutSklad);
{43}MyStr(StrToReal(Prodagi),CIZena,CMantissa,Prodagi);
{44}MyStr(StrToReal(SkProdagi),CIZena,CMantissa,SkProdagi);
{43}MyStr(StrToReal(SertifProdagi),CIZena,CMantissa,SertifProdagi);
{44}MyStr(StrToReal(SertifSkProdagi),CIZena,CMantissa,SertifSkProdagi);
{5}MyStr(StrToReal(VidanoConsig),CIZena,CMantissa,VidanoConsig);
{6}MyStr(StrToReal(SkVidanoConsig),CIZena,CMantissa,SkVidanoConsig);
{7}MyStr(StrToReal(OplataInKAssa),CIZena,CMantissa,OplataInKAssa);
{8}MyStr(StrToReal(SkOformConsign),CIZena,CMantissa,SkOformConsign);

{9}MyStr(StrToReal(ReturnOutOpenConsig),CIZena,CMantissa,ReturnOutOpenConsig);
{10}MyStr(StrToReal(SkReturnOutOpenConsig),CIZena,CMantissa,SkReturnOutOpenConsig);


{11}MyStr(StrToReal(ReturnOutMArketDocAndCloseConsig),CIZena,CMantissa,ReturnOutMArketDocAndCloseConsig);
{12}MyStr(StrToReal(SkReturnOutMArketDocAndCloseConsig),CIZena,CMantissa,SkReturnOutMArketDocAndCloseConsig);
{13}MyStr(StrToReal(OstatokConsig),CIZena,CMantissa,OstatokConsig);
{14}MyStr(StrToReal(SkOstatokConsig),CIZena,CMantissa,SkOstatokConsig);
{15}MyStr(StrToReal(Pereozenka),CIZena,CMAntissa,Pereozenka);
{16}MyStr(StrToReal(PereozenkaFromReturn),CIZena,CMAntissa,PereozenkaFromReturn);
{17}MyStr(StrToReal(SummaInKassa),CIZena,CMantissa,SummaInKassa);
{18}MyStr(StrToReal(OstatokInKAssa),CIZena,CMantissa,OstatokInKassa);
{19}MyStr(StrToReal(ExtendedDohod),CIZena,CMAntissa,ExtendedDohod);
{20}MyStr(StrToReal(RashodFromReturn),CIZena,CMAntissa,RashodFromReturn);
{20}MyStr(StrToReal(RashodFromReturnOpenConsig),CIZena,CMAntissa,RashodFromReturnOpenConsig);
{21}MyStr(StrToReal(Rashod),CIZena,CMAntissa,Rashod);
{24}MyStr(StrToReal(Sdano),CIZena,CMAntissa,Sdano);
{25}MyStr(StrToReal(VidanoSF),CIZena,CMAntissa,VidanoSF);
{26}MyStr(StrToReal(Rewisia),CIZena,CMantissa,Rewisia);
{27}MyStr(StrToReal(SNAlogP),CIZena,CMantissa,SNalogP);
{28}MyStr(StrToReal(SNAlogC),CIZena,CMantissa,SNalogC);
{29}MyStr(StrToReal(SNAlogReturnOpenConsig),CIZena,CMantissa,SNalogReturnOpenConsig);
{30}MyStr(StrToReal(OstatokBarter),CIZena,CMantissaZ,OstatokBarter);
{30}MyStr(StrToReal(BarterPrihod),CIZena,CMantissaZ,BarterPrihod);
{30}MyStr(StrToReal(BarterPrihodRZ),CIZena,CMantissa,BarterPrihodRZ);
{30}MyStr(StrToReal(BarterT),CIZena,CMantissa,BarterT);
{31}MyStr(StrToReal(BarterSkidki),CIZena,CMantissa,BarterSkidki);
{30}MyStr(StrToReal(SertifBarterT),CIZena,CMantissa,SertifBarterT);
{31}MyStr(StrToReal(SertifBarterSkidki),CIZena,CMantissa,SertifBarterSkidki);
{33}MyStr(StrToReal(BarterInKassa),CIZena,CMantissa,BarterInKassa);
{33}MyStr(StrToReal(BarterOutKassa),CIZena,CMantissa,BarterOutKassa);

    {безналичный расчет}
    MyStr(StrToReal(BNOPlataConsig),CIZena,CMantissa,BNOPlataConsig);
    MyStr(StrToReal(BNProdagi),CIZena,CMantissa,BNProdagi);
    MyStr(StrToReal(BNBarterInKassa),CIZena,CMantissa,BNBarterInKassa);
    MyStr(StrToReal(BNBarterOutKassa),CIZena,CMantissa,BNBarterOutKassa);


    {переплаты}
    MyStr(StrToReal(OstatokPereplatN),CIZena,CMantissa,OstatokPereplatN);
    MyStr(StrToReal(OstatokPereplatB),CIZena,CMantissa,OstatokPereplatB);
    MyStr(StrToReal(OstatokPereplatV),CIZena,CMantissa,OstatokPereplatV);
    {поступления переплат}
    MyStr(StrToReal(NewPereplatN),CIZena,CMantissa,NewPereplatN);
    MyStr(StrToReal(NewPereplatB),CIZena,CMantissa,NewPereplatB);
    MyStr(StrToReal(NewPereplatV),CIZena,CMantissa,NewPereplatV);
    {расход переплат}
    MyStr(StrToReal(RashodPereplatN),CIZena,CMantissa,RashodPereplatN);
    MyStr(StrToReal(RashodPereplatB),CIZena,CMantissa,RashodPereplatB);
    MyStr(StrToReal(RashodPereplatV),CIZena,CMantissa,RashodPereplatV);

    MyStr(StrToReal(OstatokAkzis),CIZena,CMantissaZ,OstatokAkzis);
    MyStr(StrToReal(ProdagiCAkzis),CIZena,CMantissaZ,ProdagiCAkzis);
    MyStr(StrToReal(ProdagiSAkzis),CIZena,CMantissaZ,ProdagiSAkzis);
    MyStr(StrToReal(ProdagiBAkzis),CIZena,CMantissaZ,ProdagiBAkzis);
    MyStr(StrToReal(VidanoConsigAkzis),CIZena,CMantissaZ,VidanoConsigAkzis);
    MyStr(StrToReal(OformlenoConsigAkzis),CIZena,CMantissaZ,OformlenoConsigAkzis);
    MyStr(StrToReal(PrihodCAkzis),CIZena,CMantissaZ,PrihodCAkzis);
    MyStr(StrToReal(PrihodSAkzis),CIZena,CMantissaZ,PrihodSAkzis);
    MyStr(StrToReal(PrihodBAkzis),CIZena,CMantissaZ,PrihodBAkzis);
    MyStr(StrToReal(ReturnCAkzis),CIZena,CMantissaZ,ReturnCAkzis);
    MyStr(StrToReal(ReturnSAkzis),CIZena,CMantissaZ,ReturnSAkzis);
    MyStr(StrToReal(RevisiaAkZis),CIZena,CMantissaZ,RevisiaAkZis);

    MyStr(StrToReal(ReportKassa),CIZena,CMantissa,ReportKassa);


    MyStr(StrToReal(Otkat),CIZena,CMantissaZ,Otkat);
    MyStr(StrToReal(AddOtkat),CIZena,CMantissaZ,AddOtkat);
    MyStr(StrToReal(KillOtkat),CIZena,CMantissaZ,KillOtkat);
    MyStr(StrToReal(KillOtkatToDAy),CIZena,CMantissaZ,KillOtkatToDay);
    MyStr(StrToReal(OtgruzkaWithOplataWithOutAkzis),CIZena,CMantissaZ,OtgruzkaWithOplataWithOutAkzis);

    MyStr(StrToReal(PrihodZC),CIZena,CMantissaZ,PrihodZC);
    MyStr(StrToReal(PrihodZS),CIZena,CMantissaZ,PrihodZS);
    MyStr(StrToReal(PrihodZB),CIZena,CMantissaZ,PrihodZB);
    MyStr(StrToReal(OstatokZ),CIZena,CMantissaZ,OstatokZ);
    MyStr(StrToReal(OstatokConsigZ),CIZena,CMantissaZ,OstatokConsigZ);
    MyStr(StrToReal(RewisiaZ),CIZena,CMantissaZ,RewisiaZ);
    MyStr(StrToReal(ReturnZ),CIZena,CMantissaZ,ReturnZ);
    MyStr(StrToReal(MinusDohod),CIZena,CMantissaZ,MinusDohod);
    MyStr(StrToReal(AllDohod),CIZena,CMantissaZ,AllDohod);
    MyStr(StrToReal(AllDohodA),CIZena,CMantissaZ,AllDohodA);
    MyStr(StrToReal(AllDohodB),CIZena,CMantissaZ,AllDohodB);
    MyStr(StrToReal(AllDohodS),CIZena,CMantissaZ,AllDohodS);

MyStr(StrToReal(OtgruzkaZC),CIZena,CMantissaZ,OtgruzkaZC);
MyStr(StrToReal(OtgruzkaZS),CIZena,CMantissaZ,OtgruzkaZS);
MyStr(StrToReal(OtgruzkaZB),CIZena,CMantissaZ,OtgruzkaZB);
MyStr(StrToReal(OtgruzkaZRP),CIZena,CMantissaZ,OtgruzkaZRP);



MyStr(StrToReal(PrihodZC2),CIZena,CMantissaZ,PrihodZC2);
MyStr(StrToReal(PrihodZS2),CIZena,CMantissaZ,PrihodZS2);
MyStr(StrToReal(PrihodZB2),CIZena,CMantissaZ,PrihodZB2);
MyStr(StrToReal(OstatokZ2),CIZena,CMantissaZ,OstatokZ2);
MyStr(StrToReal(RewisiaZ2),CIZena,CMantissaZ,RewisiaZ2);
MyStr(StrToReal(ReturnZ2),CIZena,CMantissaZ,ReturnZ2);
MyStr(StrToReal(MinusDohod2),CIZena,CMantissaZ,MinusDohod2);
MyStr(StrToReal(AllDohod2),CIZena,CMantissaZ,AllDohod2);
MyStr(StrToReal(AllDohodA2),CIZena,CMantissaZ,AllDohodA2);
MyStr(StrToReal(AllDohodB2),CIZena,CMantissaZ,AllDohodB2);
MyStr(StrToReal(AllDohodS2),CIZena,CMantissaZ,AllDohodS2);
MyStr(StrToReal(OtgruzkaZC2),CIZena,CMantissaZ,OtgruzkaZC2);
MyStr(StrToReal(OtgruzkaZS2),CIZena,CMantissaZ,OtgruzkaZS2);
MyStr(StrToReal(OtgruzkaZB2),CIZena,CMantissaZ,OtgruzkaZB2);
MyStr(StrToReal(OtgruzkaZRP2),CIZena,CMantissaZ,OtgruzkaZRP2);
MyStr(StrToReal(OstatokAZ),CIZena,CMantissaZ,OstatokAZ);
MyStr(StrToReal(OstatokAZ2),CIZena,CMantissaZ,OstatokAZ2);
MyStr(StrToReal(OstatokNZ),CIZena,CMantissaZ,OstatokNZ);
MyStr(StrToReal(OstatokNZ2),CIZena,CMantissaZ,OstatokNZ2);













(*MyStr(StrToReal(OstatokCZ),CIZena,CMantissaZ,OstatokCZ);*)


For i:=1 To Max30 Do
Begin
{29,30,31,32,33,34,35}
 MyStr(StrToReal(PerewoskiInp[i]),CIZena,CMAntissa,PerewoskiInp[i]);
 MyStr(StrToReal(PerewoskiInpZ[i]),CIZena,CMAntissaZ,PerewoskiInpZ[i]);
 MyStr(StrToReal(PerewoskiInpZ2[i]),CIZena,CMAntissaZ,PerewoskiInpZ2[i]);
{36,37,38,39,40,41,42}
 MyStr(StrToReal(PerewoskiOut[i]),CIZena,CMAntissa,PerewoskiOut[i]);
 MyStr(StrToReal(PerewoskiOutZ[i]),CIZena,CMAntissaZ,PerewoskiOutZ[i]);
 MyStr(StrToReal(PerewoskiOutZ2[i]),CIZena,CMAntissaZ,PerewoskiOutZ2[i]);
End;{For}

{43}MyStr(StrToReal(EPerewoskiOut),CIZena,CMAntissa,EPerewoskiOut);
{44}MyStr(StrToReal(EPerewoskiInp),CIZena,CMAntissa,EPerewoskiInp);

End;{With}
End;

Destructor KassaPtr.Done;
Begin
TObject.Done;
End;





VAr KassaWindow : PKassaWindow;
    Itog : PItogWindow;
    BarterItog : PBarterItogWindow;
    SertifItog : PSertifItogWindow;
    BNItog : PBNItogWindow;
    NoInputBarterPrhRZ,NoInputBarterPrhKolRZ,BarterPrhKolRZ,BarterKol,BarterPrhKol : AllStr;
    ShowKassa:Boolean;
    KassaList : PBox;
    DohodKol,DohodAgentKol : ArtikulStr;
    KassaDate : TDateString;
    Kassa : PKAssaType;
    ControlOstatok,ControlSummaInKassa,ControlSdano,ControlDoh,ControlDohAg,
    ControlDD,ControlSert,ControlRashod:PView;
    Pk : PsevdoKassaType;
    SertifProdagiC,
 SertifProdagiCKol,
 SertifProdagiCSkidki,
 SertifProdagiS,
 SertifProdagiSKol,
 SertifBarterT,
 SertifBarterKol,
 SertifBarterSkidki,
 SertifRP, SertifRPKol : AllStr;




{Procedure CalcAllNakl;}
Procedure CalcAllNakl (Date: TDateString;
Var Dohod,DohodAgent,DohodSertif : AllStr;Var DohodKol,DohodAgentKol:ArtikulStr;
Var VidaNoC:AllStr;Var VidanoCKol:ArtikulStr;Var VidanoCSkidki:AllStr;
Var SkidkiOfC:AllStr;Var SkidkiOfCKol:ArtikulStr;
Var ProdagiC :AllStr;Var ProdagiCKol :ArtikulStr;Var ProdagiCSkidki :AllStr;
Var ProdagiS :AllStr;Var ProdagiSKol :ArtikulStr;
Var SertifProdagiC :AllStr;Var SertifProdagiCKol :ArtikulStr;Var SertifProdagiCSkidki :AllStr;
Var SertifProdagiS :AllStr;Var SertifProdagiSKol :ArtikulStr;
Var SertifBarterT:AllStr;Var SertifBarterKol:Artikulstr; Var SertifBarterSkidki:AllStr;
Var SertifRP :AllStr;Var SertifRPKol :ArtikulStr;

Var RP :AllStr;Var RPKol :ArtikulStr;
Var Sf :AllStr;Var SfKol :ArtikulStr;

Var VidanoCSf:AllStr;Var VidanoCSfKol:ArtikulStr;
Var VidanoCSfSkid:AllStr;Var VidanoCSfSkidKol:ArtikulStr;
Var SkidkiOfCSf:AllStr;Var SkidkiOfCKolSf:ArtikulStr;
Var SpecNAlogP:AllStr;Var SpecNAlogC:AllStr;
Var BarterT:AllStr;Var BarterKol:Artikulstr; Var BarterSkidki:AllStr;
Var NewOtkat : AllStr;
Var BNProdagi : AllStr;Var OtgruzkaWithOplataWithOutAkzis:AllStr);


Label 1;

Var f : {MarketFileType}File;
    {E : PSuperMarketType;}
    E :  PBufSuperMarketTypeIDX;
    l : Word;
    s : TMyString;
    ws : String[CName];
    pp : String[CPack];
    Proz : String[CLitr];
    sh,Vid : Byte;
    Space: TDateString;
    Wiwod : Boolean;
    Doc : LongInt;
    Find : Boolean;
    Count,cc : Word;
    BakFileMode : Word;

Begin
        Dohod :='           0.00';{1}
   DohodAgent :='         0.0000';{1}
  DohodSertif :='         0.0000';{1}
     DohodKol :='  0';{1}
DohodAgentKol :='  0';{1}
     ProdagiC :='           0.00';{1}
  ProdagiCKol :='  0';            {2}
ProdagiCSkidki:='           0.00';{3}
     ProdagiS :='           0.00';{4}
  ProdagiSKol :='  0';            {5}



 SertifProdagiC:='           0.00';
SertifProdagiCKol:='  0';
SertifProdagiCSkidki:='           0.00';

SertifProdagiS :='           0.00';;
SertifProdagiSKol:='  0';

    SertifBarterT:='           0.00'; {30}
  SertifBarterKol:='  0';            {31}
SertifBarterSkidki:='           0.00'; {32}

        SertifRP :='           0.00';{6}
     SertifRPKol :='  0';            {7}



           RP :='           0.00';{6}
        RPKol :='  0';            {7}
       VidaNoC:='           0.00';{8}
    VidanoCKol:='  0';            {9}
 VidanoCSkidki:='           0.00';{10}
     SkidkiOfC:='           0.00';{11}
  SkidkiOfCKol:='  0';            {12}
           Sf :='           0.00';{13}
        SfKol :='  0';            {14}

  VidanoCSfKol:='  0';            {15}
     VidanoCSF:='           0.00';{16}

VidanoCSfSkidKol:='  0';          {17}
 VidanoCSFSkid:='           0.00';{18}

SkidkiOfCKolSf:='  0';            {19}
   SkidkiOfCSf:='           0.00';{20}
   SpecNalogP:='           0.00';{28}
   SpecNalogC:='           0.00';{29}
      BarterT:='           0.00'; {30}
    BarterKol:='  0';            {31}
 BarterSkidki:='           0.00'; {32}

    NewOtkat :='           0.00'; {32}
    BNProdagi:='           0.00'; {32}
 OtgruzkaWithOplataWithOutAkzis:='           0.00'; {32}

 BakFileMode:=FileMode;
 FileMode:=$42;
 Assign(F,Path^.Dat.ToMarketIndex+Date+'.mrx');
 l:=IOResult;
 Reset(f,SizeOf(SuperMarketTypeIDX));
 l:=Ioresult;
 FileMode:=BakFileMode;
 If L <> 0 Then
  Begin
   Exit;
  End;

While Not (Eof(f)) Do
Begin
    {ReadMarket(f,E);}
    New(E,Init);
    ReadBufHeaderMarket(f,e,Count);
For cc:=1 To Count Do
Begin
 If (E^.Point.Dat[cc].Active) Then
  Begin
   If (E^.Point.DAt[cc].OperatorSelector in [0]) Then
   If (E^.Point.DAt[cc].DocSelector in [5,6,7,8])Then
        Begin
  {13}   MyStr(StrToReal(NewOtkat)+E^.Point.DAt[cc].Otkat,CIZena,CMantissa,NewOtkat);
        End;


   {подсчитываем СФ}
   If (E^.Point.DAt[cc].OperatorSelector in [0,2]) Then
   If (Not(E^.Point.DAt[cc].Realiz)And(E^.Point.DAt[cc].DocSelector in [3,4])) Or
    ((E^.Point.DAt[cc].Realiz)And(E^.Point.DAt[cc].DocSelector in [6,8]){And(TestSf(E^.Point.DAt[cc].ClientKod,
    E^.Point.DAt[cc].Document,E^.Point.DAt[cc].DateC))}) Then
        Begin
  {13}   MyStr(StrToReal(Sf)+E^.Point.DAt[cc].SummaZ,CIZena,CMantissa,Sf);
  {14}   Str(StrToInt(SfKol)+1:CLitrMantissa,SfKol);
        End;


   {подсчитываем БН за товар}
   If (E^.Point.DAt[cc].OperatorSelector in [0]) Then
   If (E^.Point.DAt[cc].DocSelector in [4]) And Not(E^.Point.DAt[cc].Realiz) Then
   If (E^.Point.DAt[cc].Rashet =1)Then
        Begin
  {13}   MyStr(StrToReal(BNProdagi)+E^.Point.DAt[cc].SummaZ
  {-StrToReal(E^.Point.DAt[cc].Skidka)},CIZena,CMantissa,BNProdagi);
        End;




   {подсчитываем доход по итогам дня !!! проверить с сигаретниками}
   If (E^.Point.DAt[cc].OperatorSelector in [0,2]) And (E^.Point.DAt[cc].DocSelector in [0,1,2,3,4])
   {And Not(E^.Point.DAt[cc].Realiz)} Then
     Begin
   {3}   MyStr(StrToReal(Dohod)+E^.Point.DAt[cc].SummaZ-
               E^.Point.DAt[cc].SummaZakupka-E^.Point.DAt[cc].SummaAkzis,
              CIZena,CMantissaZ,Dohod);
  {14}   Str(StrToInt(DohodKol)+1:CLitrMantissa,DohodKol);

   {3}  If (StrToInt(E^.Point.DAt[cc].AgentKod)<>0) Then
        Begin
         MyStr(StrToReal(DohodAgent)+E^.Point.DAt[cc].SummaZ-
	    E^.Point.DAt[cc].SummaZakupka-E^.Point.DAt[cc].SummaAkzis,CIZena,CMantissaZ,DohodAgent);
  {14}   Str(StrToInt(DohodAgentKol)+1:CLitrMantissa,DohodAgentKol);
        End;
     End;


   {подсчитываем оформленную консигнацию за вычетом акцизного сбора}
   {для того чтобы можно было затем вычислять доходность в процентах по оплате}
   {по следующей зависимости}
   {все оплаченны отгрузки со склада за вычетом акцизного сбора-дох.по оплате=мнимая цифра оплаченных отгрузок по закупке}

   If (E^.Point.DAt[cc].OperatorSelector in [0,2]) And (E^.Point.DAt[cc].DocSelector in [0,1,2,3,4])
   And Not(E^.Point.DAt[cc].Realiz) Then
     Begin
   {3}   MyStr(StrToReal(OtgruzkaWithOplataWithOutAkzis)+E^.Point.DAt[cc].SummaZ-
               -E^.Point.DAt[cc].SummaAkzis,
              CIZena,CMantissaZ,OtgruzkaWithOplataWithOutAkzis);
     End;





   {доход по сертификатам,продажи по сертификатам клиенту}
   If (E^.Point.DAt[cc].OperatorSelector in [0,2]) And (((E^.Point.DAt[cc].DocSelector in [0,1,2,3,4])
   And Not(E^.Point.DAt[cc].Realiz))
       Or ((E^.Point.DAt[cc].DocSelector in [5,6,7,8]) And (E^.Point.DAt[cc].Realiz))) Then
     Begin
   {3}   MyStr(StrToReal(DohodSertif)+E^.Point.DAt[cc].SertifSummaZ-
   E^.Point.DAt[cc].SertifSummaZakupka,
              CIZena,CMantissaZ,DohodSertif);

{!!!!}
   If (E^.Point.DAt[cc].OperatorSelector in [0]) Then
   Begin
   {3}   MyStr(StrToReal(SertifProdagiC)+E^.Point.DAt[cc].SertifSummaZ
   {-StrToReal(E^.Point.DAt[cc].ENalog)},CIZena,CMantissa,
          SertifProdagiC);
        If (E^.Point.DAt[cc].OperatorSelector in [0]) Then
   {5}   Str(StrToInt(SertifProdagiCKol)+1:CLitrMantissa,SertifProdagiCKol);
   {4}   MyStr(StrToReal(SertifProdagiCSkidki)+E^.Point.DAt[cc].SertifSkidka,CIZena,CMantissa,SertifProdagiCSkidki);
   End;
     End;

   {продажи по сертификатам складу}
   If ((E^.Point.DAt[cc].OperatorSelector in [1]) And (((E^.Point.DAt[cc].DocSelector in [0,1,2,3,4])
   And Not(E^.Point.DAt[cc].Realiz))))
   And Not(StrToInt(E^.Point.DAt[cc].ClientKod)=StrToInt(ClientRP)) Then
     Begin

       If {E^.Point.DAt[cc].AmountS>0}E^.Point.DAt[cc].SertifSummaZ>0.009 Then
       Begin
   {3}   MyStr(StrToReal(SertifProdagiS)+E^.Point.DAt[cc].SertifSummaZ
   {-StrToReal(E^.Point.DAt[cc].ENalog)},CIZena,CMantissa,
         SertifProdagiS);
   {5}   Str(StrToInt(SertifProdagiSKol)+1:CLitrMantissa,SertifProdagiSKol);
       End;
     End;

   {подсчитываем бартер}
   If (E^.Point.DAt[cc].OperatorSelector=2) Then
        Begin
  {30}   MyStr(StrToReal(BarterT)+E^.Point.DAt[cc].SummaZ+
         E^.Point.DAt[cc].Skidka,CIZena,CMantissa,BarterT);
  {31}   Str(StrToInt(BarterKol)+1:CLitrMantissa,BarterKol);
  {32}   MyStr(StrToReal(BarterSkidki)+E^.Point.DAt[cc].Skidka,CIZena,CMantissa,BarterSkidki);

         If {E^.Point.DAt[cc].AmountS>0}(E^.Point.DAt[cc].SertifSummaZ+E^.Point.DAt[cc].SertifSkidka)>0.009 Then
         Begin
   {30}   MyStr(StrToReal(SertifBarterT)+E^.Point.DAt[cc].SertifSummaZ+
          E^.Point.DAt[cc].SertifSkidka,CIZena,CMantissa,SertifBarterT);
   {31}   Str(StrToInt(SertifBarterKol)+1:CLitrMantissa,SertifBarterKol);
   {32}   MyStr(StrToReal(SertifBarterSkidki)+E^.Point.DAt[cc].SertifSkidka,CIZena,CMantissa,SertifBarterSkidki);
         End;
        End;


   {подсчитываем величину спец налога без отсрочки платежа}
   If (E^.Point.DAt[cc].OperatorSelector=0) Then
   If (Not(E^.Point.DAt[cc].Realiz)And(E^.Point.DAt[cc].DocSelector in [1,2,3])) Then
        Begin
  {28}   MyStr(StrToReal(SpecNalogP)+E^.Point.DAt[cc].ENAlog,CIZena,CMantissa,SpecNalogP);
        End;


   If (E^.Point.DAt[cc].OperatorSelector=0) Then
   If ((E^.Point.DAt[cc].DocSelector in [5,6])) Then
        Begin
  {29}   MyStr(StrToReal(SpecNalogC)+E^.Point.DAt[cc].ENAlog,CIZena,CMantissa,SpecNalogC);
        End;


   If (E^.Point.DAt[cc].OperatorSelector=0) And (E^.Point.DAt[cc].DocSelector in [3,4]) Then
        Begin
            If (E^.Point.DAt[cc].Realiz){ And Not(E^.Point.DAt[cc].DocSelector in[5,6])} Then
                Begin
                 {If TestSf(E^.Point.DAt[cc].ClientKod,E^.Point.DAt[cc].DocReal,E^.Point.DAt[cc].DocDate) Then}
                  Begin
         {19}   MyStr(StrToReal(SkidkiOfCSf)+E^.Point.DAt[cc].Skidka,CIZena,CMantissa,SkidkiOfCSf);
         {20}   Str(StrToInt(SkidkiOfCKolSf)+1:CLitrMantissa,SkidkiOfCKolSf);
                  End;
                End;
        End;




   {подсчитываем РП в том числе и по сертификатам}
   If (StrToInt(E^.Point.DAt[cc].ClientKod)=StrToInt(ClientRP)) And (E^.Point.DAt[cc].OperatorSelector=1)
   And Not(E^.Point.DAt[cc].Realiz) Then
        Begin
   {1}   MyStr(StrToReal(RP)+E^.Point.DAt[cc].SummaZ,CIZena,CMantissa,RP);

   {1}   MyStr(StrToReal(SertifRP)+E^.Point.DAt[cc].SertifSummaZ,CIZena,CMantissa,SertifRP);
   {2}   Str(StrToInt(RPKol)+1:CLitrMantissa,RPKol);

         If {E^.Point.DAt[cc].AmountS>0}E^.Point.DAt[cc].SertifSummaZ>0.009 Then
          Begin
           Str(StrToInt(SertifRPKol)+1:CLitrMantissa,SertifRPKol);
          End;

         Goto 1;
        End;

   {подсчитываем продажи с клиентом}
   If (E^.Point.DAt[cc].OperatorSelector=0) And (E^.Point.DAt[cc].DocSelector in [0,1,2,3,4])
   And Not(E^.Point.DAt[cc].Realiz) Then
     Begin
   {3}   MyStr(StrToReal(ProdagiC)+E^.Point.DAt[cc].SummaZ{-StrToReal(E^.Point.DAt[cc].ENalog)},
   CIZena,CMantissa,ProdagiC);
   {5}   Str(StrToInt(ProdagiCKol)+1:CLitrMantissa,ProdagiCKol);
   {4}   MyStr(StrToReal(ProdagiCSkidki)+E^.Point.DAt[cc].Skidka,CIZena,CMantissa,ProdagiCSkidki);
      Goto 1;
     End;

   {подсчитываем продажи со складом}
   If (E^.Point.DAt[cc].OperatorSelector=1) And (E^.Point.DAt[cc].DocSelector in [0,1,2,3,4]) And
   Not(E^.Point.DAt[cc].Realiz) Then
     Begin
   {6}   MyStr(StrToReal(ProdagiS)+E^.Point.DAt[cc].SummaZ{-StrToReal(E^.Point.DAt[cc].ENalog)},
   CIZena,CMantissa,ProdagiS);

   {7}   Str(StrToInt(ProdagiSKol)+1:CLitrMantissa,ProdagiSKol);
      Goto 1;
     End;

   {подсчитываем выдано на консигнацию}
   If (E^.Point.DAt[cc].OperatorSelector=0) And (E^.Point.DAt[cc].DocSelector in [5,6,7,8]) Then
     Begin
   {8}   MyStr(StrToReal(VidaNoC)+E^.Point.DAt[cc].SummaZ{-StrToReal(E^.Point.DAt[cc].ENalog)},
   CIZena,CMantissa,VidaNoC);
   {9}   MyStr(StrToReal(VidaNoCSkidki)+E^.Point.DAt[cc].Skidka,CIZena,CMantissa,VidaNoCSkidki);
   {10}  Str(StrToInt(VidaNoCKol)+1:CLitrMantissa,VidaNoCKol);

   If (E^.Point.DAt[cc].DocSelector in [6,8]){TestSf(E^.Point.DAt[cc].ClientKod,E^.Point.DAt[cc].Document,
   E^.Point.DAt[cc].DateC)} Then
   Begin
   {15}  Str(StrToInt(VidaNoCSFKol)+1:CLitrMantissa,VidaNoCSFKol);
   {16}  MyStr(StrToReal(VidanoCSF)+E^.Point.DAt[cc].SummaZ{-StrToReal(E^.Point.DAt[cc].ENalog)},
   CIZena,CMantissa,VidanoCSF);

   {17}  Str(StrToInt(VidaNoCSFSkidKol)+1:CLitrMantissa,VidaNoCSFSkidKol);
   {18}  MyStr(StrToReal(VidanoCSFSkid)+E^.Point.DAt[cc].Skidka,CIZena,CMantissa,VidanoCSFSkid);
   End;


      Goto 1;
     End;

   {подсчитываем оформленную консигнацию}
   If (E^.Point.DAt[cc].OperatorSelector=0) And (E^.Point.DAt[cc].DocSelector in [0,1,3,4]) And (E^.Point.DAt[cc].Realiz) Then
     Begin
   {11}  MyStr(StrToReal(SkidkiOfC)+E^.Point.DAt[cc].Skidka,CIZena,CMantissa,SkidkiOfC);
   {12}  Str(StrToInt(SkidkiOfCKol)+1:CLitrMantissa,SkidkiOfCKol);
      Goto 1;
     End;
  End;
1:
End;{For}
Dispose(E,Done);
End;
 l:=Ioresult;
Close(f);
 l:=Ioresult;
End;





Procedure TItogWindow.OpenViewItog;
 var
  R : TRect;
  Control : PView;
  c : Word;
  PromS,PromP,SSklad,ws,s1,s2,SkidkaK,SkidkaP : AllStr;
  s : String;
  RazdelSelect : PBox;
  M : Maska8;
 VidaNoC,Dohod,DohodAgent,DohodS:AllStr;
 VidanoCKol:ArtikulStr;
 VidanoCSkidki:AllStr;
 SkidkiOfC:AllStr;
 SkidkiOfCKol:ArtikulStr;
 ProdagiC :AllStr;
 ProdagiCKol :ArtikulStr;
 ProdagiCSkidki :AllStr;
 ProdagiS :AllStr;
 ProdagiSKol :ArtikulStr;
 ProdagiSC :AllStr;
 ProdagiSCKol :ArtikulStr;
 ProdagiSCSkidki :AllStr;
 ProdagiSS :AllStr;
 ProdagiSSKol :ArtikulStr;
 RP :AllStr;
 RPKol :ArtikulStr;
 Sf :AllStr;
 SfKol :ArtikulStr;

 VidanoRashod:AllStr;
 VidanoRashodKol:AllStr;
 VidanoCRashod:AllStr;
 VidanoCRashodKol:AllStr;

 VidanoCSf:AllStr;
 VidanoCSfKol:ArtikulStr;
 VidanoCSfSkid:AllStr;
 VidanoCSfSkidKol:ArtikulStr;
 SkidkiOfCSf:AllStr;
 SkidkiOfCKolSf:ArtikulStr;

 Return:AllStr;
 ReturnKol : ArtikulStr;
 ReturnSkid:AllStr;
 ReturnSf  :AllStr;
 ReturnSfKol : ArtikulStr;
 ReturnSFSkid:AllStr;

 ReturnSfNAl  :AllStr;
 ReturnSfKolNAl : ArtikulStr;
 Temp,ReturnSFSkidNAl:AllStr;
 SKassa,SpecNalogP,SpecNalogC,SNalogReturnOpenConsig : AllStr;
 BarterT,BarterSkidki,NewOtkat,BNProdagi,VidanoOtkat,VidanoOtkatToDAy,
 OtgruzkaWithOplataWithOutAkzisToDay,
 OstConsigSF,skOstConsigSF,SOstatokOtkat : AllStr;

begin

DInfo('Минуточку...');

New(Kassa,Init);{создается экземпляр объекта кассовый лист}


R.Assign(0, 0, 80, 23);
New(Itog, Init(R, 'Итоги дня'));
Itog^.Options := Itog^.Options or ofTileable or ofCenterX or ofCenterY;
Itog^.Palette := dpBlueDialog;
Itog^.HelpCtx:=$F006{E555};

R.Assign(2, 2, 78, 10);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Itog^.Insert(Control);



R.Assign(2, 1, 21, 2);
Control := New(PColoredText, Init(R, ' Итоги консигнации ', $4F));
Itog^.Insert(Control);

R.Assign(2, 11, 78, 21);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Itog^.Insert(Control);


(*
{$IFNDEF Tabak}
R.Assign(23, 10, 56, 11);
Control := New(PColoredText, Init(R, ' Итоги прихода/расхода на складе ', $4f));
Control^.Options := Control^.Options or ofCenterX;
{$ELSE}
*)
R.Assign(2, 10, 35, 11);
Control := New(PColoredText, Init(R, ' Итоги прихода/расхода на складе ', $4f));
(*{$ENDIF}*)
Itog^.Insert(Control);



R.Assign(2, 0, 7, 1);
Control := New(PColoredText, Init(R, 'Дата:', $1F));
Itog^.Insert(Control);

R.Assign(7, 0, 24, 1);
If TestOpenDate1(FDate) Then
Control := New(PColoredText, Init(R, #3+FDate+' (ОТКРЫТ)', $1A))
Else
Control := New(PColoredText, Init(R, #3+FDate+' (ЗАКРЫТ)', $1A));
Itog^.Insert(Control);

R.Assign(52, 0, 58, 1);
Control := New(PColoredText, Init(R, 'Склад:', $1F));
Itog^.Insert(Control);

R.Assign(58, 0, 70, 1);
Control := New(PColoredText, Init(R, #3+GetClientField(FClient,Rek^.Dat.Kod,1), $1A));
{Control := New(PColoredText, Init(R, #3+Rek.SkladsName, $1A));}
Itog^.Insert(Control);



CalcAllNakl (FDate,Dohod,DohodAgent,DohodS,DohodKol,DohodAgentKol,VidaNoC,
VidanoCKol,VidanoCSkidki,SkidkiOfC,SkidkiOfCKol,ProdagiC, ProdagiCKol,
ProdagiCSkidki, ProdagiS, ProdagiSKol,
SertifProdagiC,SertifProdagiCKol,SertifProdagiCSkidki,SertifProdagiS,
SertifProdagiSKol,SertifBarterT,SertifBarterKol,SertifBarterSkidki,
SertifRP, SertifRPKol,RP, RPKol,Sf,SfKol,VidanoCSf,
VidanoCSfKol,VidanoCSfSkid,VidanoCSfSkidKol,SkidkiOfCSf,SkidkiOfCKolSf,
SpecNalogP,SpecNalogC,BarterT,BarterKol,BarterSkidki,NewOtkat,BNProdagi,OtgruzkaWithOplataWithOutAkzisToDay);


Kassa^.Dat.Dohodall:=Dohod;
DelSpace(Kassa^.Dat.Dohodall);
RFormat(Kassa^.Dat.DohodAll,CIZena);
MyStr(StrToReal(Kassa^.Dat.DohodAll),CIZena,CMAntissaZ,Kassa^.Dat.DohodAll);

Kassa^.Dat.DohodAgent:=DohodAgent;
DelSpace(Kassa^.Dat.DohodAgent);
RFormat(Kassa^.Dat.DohodAgent,CIZena);
MyStr(StrToReal(Kassa^.Dat.DohodAgent),CIZena,CMAntissaZ,Kassa^.Dat.DohodAgent);

Kassa^.Dat.DohodSertif:=DohodS;
DelSpace(Kassa^.Dat.DohodSertif);
RFormat(Kassa^.Dat.DohodSertif,CIZena);
MyStr(StrToReal(Kassa^.Dat.DohodSertif),CIZena,CMAntissaZ,Kassa^.Dat.DohodSertif);

Kassa^.Dat.SertifRP:=SertifRP;
DelSpace(Kassa^.Dat.SertifRP);
RFormat(Kassa^.Dat.SertifRP,CIZena);
MyStr(StrToReal(Kassa^.Dat.SertifRP),CIZena,CMAntissa,Kassa^.Dat.SertifRP);

Kassa^.Dat.BarterT:=BarterT;
DelSpace(Kassa^.Dat.BarterT);
RFormat(Kassa^.Dat.BarterT,CIZena);
MyStr(StrToReal(Kassa^.Dat.BarterT),CIZena,CMAntissa,Kassa^.Dat.BarterT);

Kassa^.Dat.BarterSkidki:=BarterSkidki;
DelSpace(Kassa^.Dat.BarterSkidki);
RFormat(Kassa^.Dat.BarterSkidki,CIZena);
MyStr(StrToReal(Kassa^.Dat.BarterSkidki),CIZena,CMAntissa,Kassa^.Dat.BarterSkidki);

Kassa^.Dat.SertifBarterT:=SertifBarterT;
DelSpace(Kassa^.Dat.SertifBarterT);
RFormat(Kassa^.Dat.SertifBarterT,CIZena);
MyStr(StrToReal(Kassa^.Dat.SertifBarterT),CIZena,CMAntissa,Kassa^.Dat.SertifBarterT);

Kassa^.Dat.SertifBarterSkidki:=SertifBarterSkidki;
DelSpace(Kassa^.Dat.SertifBarterSkidki);
RFormat(Kassa^.Dat.SertifBarterSkidki,CIZena);
MyStr(StrToReal(Kassa^.Dat.SertifBarterSkidki),CIZena,CMAntissa,Kassa^.Dat.SertifBarterSkidki);

MyStr(StrToReal(SertifProdagiC)+StrToReal(SertifProdagiCSkidki),CIZena,CMantissa,Temp);

Kassa^.Dat.SertifProdagi:=Temp;
DelSpace(Kassa^.Dat.SertifProdagi);
RFormat(Kassa^.Dat.SertifProdagi,CIZena);
MyStr(StrToReal(Kassa^.Dat.SertifProdagi),CIZena,CMAntissa,Kassa^.Dat.SertifProdagi);

Kassa^.Dat.SertifSkProdagi:=SertifProdagiCSkidki;
DelSpace(Kassa^.Dat.SertifSkProdagi);
RFormat(Kassa^.Dat.SertifSkProdagi,CIZena);
MyStr(StrToReal(Kassa^.Dat.SertifSkProdagi),CIZena,CMAntissa,Kassa^.Dat.SertifSkProdagi);


R.Assign(2, 2, 21, 3);
Control := New(PColoredText, Init(R, 'Выдано на консиг.Т', $1F));
Itog^.Insert(Control);

MyStr(StrToReal(VidaNoC)+StrToReal(VidanoCSkidki),CIZena,CMantissa,Temp);

{5}Kassa^.Dat.VidanoConsig:=Temp;
   DelSpace(Kassa^.Dat.VidanoConsig);

{6}Kassa^.Dat.SkVidanoConsig:=VidanoCSkidki;
   DelSpace(Kassa^.Dat.SkVidanoConsig);

R.Assign(2, 3, 21, 4);
Control := New(PColoredText, Init(R, Temp+' '+VidanoCKol, $5f));
Itog^.Insert(Control);

R.Assign(2, 4, 21, 5);
Control := New(PColoredText, Init(R, 'Скидки выд. консиг.', $1F));
Itog^.Insert(Control);

{DelSpace(VidanoCSkidki);}

R.Assign(2, 5, 21, 6);
Control := New(PColoredText, Init(R, VidanoCSkidki, $5F{1A}));
Itog^.Insert(Control);

R.Assign(2, 6, 21, 7);
Control := New(PColoredText, Init(R, 'Выдан.кон.со СФ Т', $1F));
Itog^.Insert(Control);

MyStr(StrToReal(VidaNoCSf)+StrToReal(VidanoCSfSkid),CIZena,CMantissa,Temp);

R.Assign(2, 7, 21, 8);
Control := New(PColoredText, Init(R, Temp+' '+VidanoCSfKol, $5F));
Itog^.Insert(Control);

R.Assign(2, 8, 21, 9);
Control := New(PColoredText, Init(R, 'Скид.выд.кон.со СФ', $1F));
Itog^.Insert(Control);

R.Assign(2, 9, 21, 10);
Control := New(PColoredText, Init(R, VidanoCSfSkid+' '+VidanoCSFSkidKol, $5F));
Itog^.Insert(Control);

R.Assign(22, 2, 41, 3);
Control := New(PColoredText, Init(R, 'Опл. конс.в кассу', $1F));
Itog^.Insert(Control);

s:=ViewOplReal(FDate,False);
s1:=Copy(s,1,CIZena);
{DelSpace(s1);
s1:=SClearChar(s1);}

{7}Kassa^.Dat.OplataINKassa :=s1;
   DelSpace(Kassa^.Dat.OplataINKassa);

R.Assign(22, 3, 41, 4);
Control := New(PColoredText, Init(R, s1, $30{1A}));
Itog^.Insert(Control);

R.Assign(22, 4, 41, 5);
Control := New(PColoredText, Init(R, 'Скидки оф. консигн.', $1F));
Itog^.Insert(Control);

{8}Kassa^.Dat.SkOformConsign :=SkidkiOfC;
   DelSpace(Kassa^.Dat.SkOformConsign);

R.Assign(22, 5, 41, 6);
Control := New(PColoredText, Init(R, SkidkiOfC+' '+SkidkiOfCKol, $30{1A}));
Itog^.Insert(Control);

R.Assign(22, 6, 41, 7);
Control := New(PColoredText, Init(R, 'Опл.конс.СФ в кас.', $1F));
Itog^.Insert(Control);

s1:=Copy(s,1+CIZena+1,CIZena);
{DelSpace(s1);
s1:=SClearChar(s1);}

R.Assign(22, 7, 41, 8);
Control := New(PColoredText, Init(R, s1, $30));
Itog^.Insert(Control);

R.Assign(22, 8, 41, 9);
Control := New(PColoredText, Init(R, 'Скид.оф.кон.со СФ', $1F));
Itog^.Insert(Control);

R.Assign(22, 9, 41, 10);
Control := New(PColoredText, Init(R, SkidkiOfCSf+' '+SkidkiOfCKolSf, $30));
Itog^.Insert(Control);


SOstatokOtkat[0]:=#0;;

{расчет отката 29/08/03 перенесен вниз и совмещен с расчетом задолженности
SOstatokOtkat:=CalcDolgOtkat(False);
MyStr(StrToREal(SOstatokOtkat),CIZena,CMantissa,SOstatokOtkat);
}
{расход по возврату}
CalcRashodfromVozwrat(FDate,VidanoRashod,VidanoRashodKol,VidanoCRashod,VidanoCRashodKol);

R.Assign(21, 1, 29, 2);
Control := New(PColoredText, Init(R, 'Рсх.взв:', $1F));
Itog^.Insert(Control);

{19}Kassa^.Dat.RashodFromReturn :=VidanoRashod;
         DelSpace(Kassa^.Dat.RashodFromReturn);


R.Assign(29, 1, 48, 2);
Control := New(PColoredText, Init(R, VidanoRashod+' '+VidanoRashodKol, $70));
Itog^.Insert(Control);

R.Assign(49, 1, 59, 2);
Control := New(PColoredText, Init(R, 'Рсх.от.к.:', $1F));
Itog^.Insert(Control);

{??}Kassa^.Dat.RashodFromReturnOpenConsig :=VidanoCRashod;
         DelSpace(Kassa^.Dat.RashodFromReturnOpenConsig);

R.Assign(59, 1, 78, 2);
Control := New(PColoredText, Init(R, VidanoCRashod+' '+VidanoCRashodKol, $70));
Itog^.Insert(Control);



CalcVozwratfromConsig(FDate,Return, ReturnKol ,ReturnSkid,ReturnSf,
ReturnSfKol, ReturnSFSkid,SNalogReturnOpenConsig);


R.Assign(59, 2, 78, 3);
Control := New(PColoredText, Init(R, 'Возв.по консиг.Т', $1F));
Itog^.Insert(Control);

{9}Kassa^.Dat.ReturnOutOpenConsig:=Return;
        DelSpace(Kassa^.Dat.ReturnOutOpenConsig);

{30}Kassa^.Dat.SNalogReturnOpenConsig:=SNalogReturnOpenConsig;
        DelSpace(Kassa^.Dat.SNalogReturnOpenConsig);

R.Assign(59, 3, 78, 4);
Control := New(PColoredText, Init(R, Return+' '+ReturnKol, $6F));
Itog^.Insert(Control);

R.Assign(59, 4, 78, 6);
Control := New(PColoredText, Init(R, 'Скид.возв.по конс.', $1F));
Itog^.Insert(Control);

{10}Kassa^.Dat.SkReturnOutOpenConsig :=ReturnSkid;
         DelSpace(Kassa^.Dat.SkReturnOutOpenConsig);


R.Assign(59, 5, 78, 6);
Control := New(PColoredText, Init(R, ReturnSkid, $6F));
Itog^.Insert(Control);

R.Assign(59, 6, 78, 7);
Control := New(PColoredText, Init(R, 'Возв.по конс.СФ Т', $1F));
Itog^.Insert(Control);

R.Assign(59, 7, 78, 8);
Control := New(PColoredText, Init(R, ReturnSf+' '+ReturnSfKol, $6F));
Itog^.Insert(Control);

R.Assign(59, 8, 78, 9);
Control := New(PColoredText, Init(R, 'Скид.возв.конс.СФ', $1F));
Itog^.Insert(Control);

R.Assign(59, 9, 78, 10);
Control := New(PColoredText, Init(R, ReturnSfSkid, $6F));
Itog^.Insert(Control);

R.Assign(2, 11, 21, 12);
Control := New(PColoredText, Init(R, 'Продажи (клиент) Т', $1F));
Itog^.Insert(Control);


MyStr(StrToReal(ProdaGiC)+StrToReal(ProdagiCSkidki),CIZena,CMantissa,Temp);


{40}Kassa^.Dat.Prodagi :=Temp;
    DelSpace(Kassa^.Dat.Prodagi);

R.Assign(2, 12, 21, 13);
Control := New(PColoredText, Init(R, Temp+' '+ProdagiCKol, $70{1A}));
Itog^.Insert(Control);

R.Assign(2, 15, 16, 16);
Control := New(PColoredText, Init(R, 'Скидки продажи', $1F));
Itog^.Insert(Control);

{DelSpace(ProdagiCSkidki);}

{41}Kassa^.Dat.SkProdagi :=ProdagiCSkidki;
    DelSpace(Kassa^.Dat.SkProdagi);


R.Assign(2, 16, 21, 17);
Control := New(PColoredText, Init(R, ProdagiCSkidki, $70{1A}));
Itog^.Insert(Control);

R.Assign(2, 13, 21, 14);
Control := New(PColoredText, Init(R, 'Отгрузка (склад)', $1F));
Itog^.Insert(Control);

R.Assign(2, 14, 21, 15);
Control := New(PColoredText, Init(R, ProdagiS+' '+ProdagiSKol, $70{1A}));
Itog^.Insert(Control);


R.Assign(2, 17, 12, 18);
Control := New(PColoredText, Init(R, 'Переоценка', $1F));
Itog^.Insert(Control);

s:=ViewAllAktPrz(FDate,False,0);
ws:=Copy(s,1,CIZena);
s:=Copy(s,1+CIZena+1,CLitrMantissa);

{15}Kassa^.Dat.Pereozenka:=ws;
    DelSpace(Kassa^.Dat.Pereozenka);


R.Assign(2, 18, 21, 19);
Control := New(PColoredText, Init(R, ws+' '+s, $4F));
Itog^.Insert(Control);

R.Assign(2, 19, 21, 20);
Control := New(PColoredText, Init(R, 'Переоценка по возв.', $1F));
Itog^.Insert(Control);


s:=ViewAllAktPrz(FDate,False,1);
ws:=Copy(s,1,CIZena);
s:=Copy(s,1+CIZena+1,CLitrMantissa);

{16}Kassa^.Dat.PereozenkaFromReturn:=ws;
    DelSpace(Kassa^.Dat.PereozenkaFromReturn);


R.Assign(2, 20, 21, 21);
Control := New(PColoredText, Init(R, ws+' '+s, $4F));
Itog^.Insert(Control);


R.Assign(22, 11, 37, 12);
Control := New(PColoredText, Init(R, 'Приход (клиент)', $1F));
Itog^.Insert(Control);

s1:=ViewAllPrihod(FDate,False,0);

ws:=Copy(s1,1,CIZena);
s:=Copy(s1,1+CIZena+1,CIZena);
s2:=Copy(s1,1+CIZena+1+CIZena+1,CLitrMAntissa);
s1:=Copy(s1,1+CIZena+1+CIZena+1+CLitrMantissa+1,CLitrMantissa);

{1}Kassa^.Dat.Prihod :=ws;
   DelSpace(Kassa^.Dat.Prihod);


R.Assign(22, 12, 41, 14);
Control := New(PColoredText, Init(R, ws+' '+s2+^M+
                                                        s+' '+s1, $3F{1A}));
Itog^.Insert(Control);

R.Assign(22, 14, 41, 15);
Control := New(PColoredText, Init(R, 'Приход межскладской', $1F));
Itog^.Insert(Control);

s1:=ViewAllPrihod(FDate,False,1);
ws:=Copy(s1,1,CIZena);
s:=Copy(s1,1+CIZena+1,CIZena);
s2:=Copy(s1,1+CIZena+1+CIZena+1,CLitrMAntissa);
s1:=Copy(s1,1+CIZena+1+CIZena+1+CLitrMantissa+1,CLitrMantissa);

R.Assign(22, 15, 41, 17);
Control := New(PColoredText, Init(R,ws+' '+s2+^M+
                                                         s+' '+s1, $3F{1A}));
Itog^.Insert(Control);

s1:=ViewAllPrihod(FDate,False,2);

ws:=Copy(s1,1,CIZena);
 s:=Copy(s1,1+CIZena+1,CIZena);
s2:=Copy(s1,1+CIZena+1+CIZena+1,CLitrMAntissa);
s1:=Copy(s1,1+CIZena+1+CIZena+1+CLitrMantissa+1,CLitrMantissa);

{1}Kassa^.Dat.BarterPrihodRZ :=ws;
   DelSpace(Kassa^.Dat.BarterPrihodRZ);
   BarterPrhKolRZ:=s2;
   NoInputBarterPrhRZ:=s;
   NoInputBarterPrhKolRZ:=s1;

s1:=CAlcPrihodBarter(FDate);

ws:=Copy(s1,1,CIZena);
s2:=Copy(s1,1+CIZena+1,CLitrMAntissa);
{1}Kassa^.Dat.BarterPrihod :=ws;
   DelSpace(Kassa^.Dat.BarterPrihod);
   BarterPrhKol:=s2;

ws:=CalcDolgBarter(False);
{1}Kassa^.Dat.OstatokBarter:=ws;
   DelSpace(Kassa^.Dat.OstatokBarter);

s1:=ViewOplBarter(FDate,False);
ws:=Copy(s1,1,CIZena);
s1:=copy(s1,1+CIZena+1,CIZena);
{1}Kassa^.Dat.BarterInKassa:=ws;
   DelSpace(Kassa^.Dat.BarterInKassa);
{1}Kassa^.Dat.BarterOutKassa:=s1;
   DelSpace(Kassa^.Dat.BarterOutKassa);




R.Assign(42, 11, 59, 12);
Control := New(PColoredText, Init(R, 'Возврат(клиент)Т', $1F));
Itog^.Insert(Control);

s1:=NewViewAllVozwrat(FDate,False,0);
ws:=Copy(s1,1,CIZena);
s:=Copy(s1,1+CIZena+1,CIZena);
s2:=Copy(s1,1+CIZena+1+CIZena+1,CLitrMAntissa);
s1:=Copy(s1,1+CIZena+1+CIZena+1+CLitrMantissa+1,CLitrMantissa);

R.Assign(42, 12, 61, 14);
Control := New(PColoredText, Init(R,ws+' '+s2+^M+
                                                          s+' '+s1 , $6F{1A}));
Itog^.Insert(Control);


R.Assign(42, 14, 61, 15);
Control := New(PColoredText, Init(R, 'Возврат межскладс.Т', $1F));
Itog^.Insert(Control);

s1:=NewViewAllVozwrat(FDate,False,1);
ws:=Copy(s1,1,CIZena);
s:=Copy(s1,1+CIZena+1,CIZena);
s2:=Copy(s1,1+CIZena+1+CIZena+1,CLitrMAntissa);
s1:=Copy(s1,1+CIZena+1+CIZena+1+CLitrMantissa+1,CLitrMantissa);


R.Assign(42, 15, 61, 17);
Control := New(PColoredText, Init(R, ws+' '+s2+^M+
                                                           s+' '+s1, $6F{1A}));
Itog^.Insert(Control);



{R.Assign(42, 17, 57, 18);}
R.Assign(63, 15, 78, 16);
Control := New(PColoredText, Init(R, 'Сумма со склада', $1F));
Itog^.Insert(Control);

{27.04.02}
MyStr(StrToReal(VidaNoC)+StrToReal(ProdagiC)+StrToReal(ProdagiCSkidki)+StrToReal(VidanoCSkidki)+
StrToREal(BarterT),CIZena,CMantissa,s);

{4} Kassa^.Dat.SummaOutSklad:=s;
DelSpace(Kassa^.Dat.SummaOutSklad);


{R.Assign(42, 18, 61, 19);}
R.Assign(63, 16, 78, 17);
Control := New(PColoredText, Init(R, s, $3E));
Itog^.Insert(Control);

R.Assign(22, 17, 32, 18);
Control := New(PColoredText, Init(R, 'Р/П работы', $1F));
Itog^.Insert(Control);

{3}Kassa^.Dat.RP:=Rp;
   DelSpace(Kassa^.Dat.RP);

R.Assign(22, 18, 41, 19);
Control := New(PColoredText, Init(R, Rp+' '+RpKol, $3E));
Itog^.Insert(Control);


(*
R.Assign(0, 0, 0, 0);
RazdelSelect := New(PBox, Init(R, 1, Nil));
RazdelSelect^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
   Begin
    Format (RazdelElement.Name,CRazdel);
    RazdelSelect^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
   End;
 End;
System.Close(RazdelFile);
RazdelSelect^.FocusItem(0);
{Itog^.Insert(RazdelSelect);}

For c:=1 To Max8 Do m[c]:=1;

Ssklad:=PrintSklad_Or_Prise(False,0,RazdelSelect,M,0,0,0,0);
Dispose(RazdelSelect,Done);
*)

R.Assign(22, 19, 41, 20);
Control := New(PColoredText, Init(R, 'Сумма по выдан. СФ', $1F));
Itog^.Insert(Control);


{24}Kassa^.Dat.VidanoSF:=Sf;
    DelSpace(Kassa^.Dat.VidanoSF);

R.Assign(22, 20, 41, 21);
Control := New(PColoredText, Init(R, Sf+' '+SfKol, $3E));
Itog^.Insert(Control);


CalcVozwratfromSfNal(FDate,ReturnSfNal,ReturnSfKolNal, ReturnSFSkidNal);

R.Assign(42, 18, 61, 19);
Control := New(PColoredText, Init(R,ReturnSfNal+' '+ReturnSfKolNal, $6F));
Itog^.Insert(Control);

R.Assign(42, 17, 61, 18);
Control := New(PColoredText, Init(R, 'Возврат по СФ пр.Т', $1F));
Itog^.Insert(Control);

R.Assign(42, 19, 61, 20);
Control := New(PColoredText, Init(R, 'Всего возврат СФ Т', $1F));
Itog^.Insert(Control);


MyStr(StrToReal(ReturnSfNal)+StrToReal(ReturnSf),CIZena,CMantissa,s1);
Str(StrToInt(ReturnSfKolNal)+StrToInt(ReturnSfKol):CLitrMantissa,s2);

R.Assign(42, 20, 61, 21);
Control := New(PColoredText, Init(R, s1+' '+s2, $6E));
Itog^.Insert(Control);


s1:=ViewAllRewisia(FDate,True,2);
s2:=Copy(s1,1,CIZena);

{25}Kassa^.Dat.Rewisia:=s2;
    DelSpace(Kassa^.Dat.Rewisia);

R.Assign(63, 19, 78, 20);
Control := New(PColoredText, Init(R, 'Всего ревизия', $1F));
Itog^.Insert(Control);

R.Assign(63, 20, 78, 21);
Control := New(PColoredText, Init(R, s2, $70));
Itog^.Insert(Control);

s2:=Copy(s1,1+CIZena+1,CLitr);
DelSpace(s2);

R.Assign(75, 21, 78, 22);
Control := New(PColoredText, Init(R, #3+s2, $70));
Itog^.Insert(Control);


CalcVozwratfromNal(FDate,ReturnSfNal,ReturnSfKolNal, ReturnSFSkidNal);

R.Assign(62, 11, 78, 12);
Control := New(PColoredText, Init(R, 'Возв.пр,оф.кон.Т', $1F));
Itog^.Insert(Control);

{11}Kassa^.Dat.ReturnOutMArketDocAndCloseConsig :=ReturnSFNAl;
    DelSpace(Kassa^.Dat.ReturnOutMArketDocAndCloseConsig);

R.Assign(63, 12, 78, 13);
Control := New(PColoredText, Init(R, ReturnSFNal, $6E));
Itog^.Insert(Control);

R.Assign(62, 13, 78, 14);
Control := New(PColoredText, Init(R, 'Ск.возв.пр,оф.к.', $1F));
Itog^.Insert(Control);

{12}Kassa^.Dat.SkReturnOutMArketDocAndCloseConsig :=ReturnSFSkidNAl;
    DelSpace(Kassa^.Dat.SkReturnOutMArketDocAndCloseConsig);


R.Assign(63, 14, 78, 15);
Control := New(PColoredText, Init(R, ReturnSFSkidNal, $6E));
Itog^.Insert(Control);

R.Assign(1, 22, 10, 23);
Control := New(PStaticText, Init(R, ' НП прод:'));
Itog^.Insert(Control);

DelSpace(SpecNalogP);
R.Assign(10, 22, 25, 23);
Control := New(PColoredText, Init(R, #3+SpecNalogP, $5E));
Itog^.Insert(Control);

{28}Kassa^.Dat.SNalogP :=SpecNalogP;
    DelSpace(Kassa^.Dat.SNalogP);

R.Assign(25, 22, 39, 23);
Control := New(PStaticText, Init(R, ' НП выд.конс.:'));
Itog^.Insert(Control);

DelSpace(SpecNalogC);
R.Assign(39, 22, 54, 23);
Control := New(PColoredText, Init(R, #3+SpecNAlogC, $5E));
Itog^.Insert(Control);

{29}Kassa^.Dat.SNalogC :=SpecNalogC;
    DelSpace(Kassa^.Dat.SNalogC);

R.Assign(54, 22, 67, 23);
Control := New(PStaticText, Init(R, ' НП взв.о.к.:'));
Itog^.Insert(Control);

DelSpace(SNalogReturnOpenConsig);
R.Assign(67, 22, 79, 23);
Control := New(PColoredText, Init(R, #3+SNalogReturnOpenConsig, $5E));
Itog^.Insert(Control);

{30}Kassa^.Dat.SNalogReturnOpenConsig :=SNalogReturnOpenConsig;
    DelSpace(Kassa^.Dat.SNalogReturnOpenConsig);

R.Assign(71, 0, 79, 1);
Control := New(PColoredText, Init(R, #3+'[E.Y.E.]', $1B));
Itog^.Insert(Control);


{здесь вставить код расчета остатка отката, нового отката и гашения отката}
DelSpace(NewOtkat);{посчитан ранее в CalcAllNakl}
DelSpace(BnProdagi);{посчитан ранее в CalcAllNakl}

VidanoOtkat[0]:=#0;
VidanoOtkat:=ViewOplOtkat(FDate,False,VidanoOtkatToDAy);
DelSpace(VidanoOtkat);
MyStr(StrToReal(VidanoOtkatToDay),CIZena,CMantissa,VidanoOtkatToDay);
DelSpace(VidanoOtkatToDay);


DelSpace(VidanoOtkat);
DelSpace(SOstatokOtkat);
Kassa^.Dat.AddOtkat:=NewOtkat;
Kassa^.Dat.Otkat:=SOstatokOtkat;
Kassa^.Dat.KillOtkat:=VidanoOtkat;
Kassa^.Dat.KillOtkatToDay:=VidanoOtkatToDay;
Kassa^.Dat.OtgruzkaWithOplataWithOutAkzis:=OtgruzkaWithOplataWithOutAkzisToDay;

SSklad[0]:=#0;
OstConsigSF[0]:=#0;
skOstConsigSF[0]:=#0;


With Kassa^.Dat Do
Begin
CalcSpecialKassa(     Otkat,
                      SSklad,
                      Kassa^.Dat.OstatokConsig,
                      Kassa^.Dat.SkOstatokConsig,
                      OstConsigSF,
                      skOstConsigSF,
                      OstatokZ ,
                      OstatokAkzis,
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
                      ReportKAssa,
                      OstatokConsigZ ,
                      PrihodZC ,
                      PrihodZS ,
                      PrihodZB ,
                      RewisiaZ ,
                      ReturnZ ,
                      MinusDohod,
                      AllDohod,
                      AllDohodA,
                      AllDohodB,
                      AllDohodS,
                      OtgruzkaZC,
                      OtgruzkaZS,
                      OtgruzkaZB,
                      OtgruzkaZRP,
                      PerewoskiInpZ,
				  PerewoskiOutz,
                      OstatokZ2,
                      PrihodZC2,
                      PrihodZS2,
                      PrihodZB2,
                      RewisiaZ2,
                      ReturnZ2,
                      MinusDohod2,
                      AllDohod2,
                      AllDohodA2,
                      AllDohodB2,
                      AllDohodS2,
                          OtgruzkaZC2,
                          OtgruzkaZS2,
                          OtgruzkaZB2,
                         OtgruzkaZRP2,
                            OstatokAZ,
                           OstatokAZ2,
                            OstatokNZ,
                           OstatokNZ2,
                           PerewoskiInpZ2,PerewoskiOutz2);
End;

{$IFDEF TABAK}
{сумма в кассе}
With kassa^.Dat Do
Begin
Str(StrToReal(Prodagi)
+   StrToReal(SertifProdagi)
-   StrToReal(SertifSkProdagi)

+   StrToReal(BarterINKassa)
-   StrToReal(BarterOutKassa)

-   StrToReal(SkProdagi)
+   StrToReal(OplataINKassa)
-   StrToReal(RAshodFromReturn)
-   StrToReal(KillOtkat){выдача денег из кассы по откату}
-   StrToReal(BNOPlataConsig){безналичные оплаты консигнации}
-   StrToReal(BNProdagi){безналичные оплаты без отсрочки}
-   StrToReal(BNBarterInKassa){безналичные поступления по бартеру}
+   StrToReal(BNBarterOutKassa){безналичные расходы по бартеру}
    :CIZena+1:CMAntissa,SKAssa);
End;

R.Assign(46, 10, 62, 11);
Control := New(PColoredText, Init(R, ' Сумма в кассе: ', $1F));
Itog^.Insert(Control);

R.Assign(62, 10, 78, 11);
Control := New(PColoredText, Init(R, SKassa, $30));
Itog^.Insert(Control);
{$ENDIF}


Kassa^.Dat.BnProdagi:=BNProdagi;
Kassa^.Dat.BNOPlataConsig:=CalcBNOplReal(FDate);

DelSpace(Kassa^.Dat.BNOPlataConsig);

s1:=CalcBNBarter(FDate);
ws:=Copy(s1,1,CIZena);
s1:=copy(s1,1+CIZena+1,CIZena);
{1}Kassa^.Dat.BNBarterInKassa:=ws;

   DelSpace(Kassa^.Dat.BNBarterInKassa);
{2}Kassa^.Dat.BNBarterOutKassa:=s1;
   DelSpace(Kassa^.Dat.BNBarterOutKassa);




{R.Assign(42, 19, 59, 20);}
{
R.Assign(26, 7, 45, 8);
Control := New(PColoredText, Init(R, 'ККМ:123456789012345', $5E));
Dlg^.Insert(Control);
}

{$IFNDEF Tabak}
R.Assign(46, 10, 62, 11);
Control := New(PColoredText, Init(R, ' Сутки по ККМ: ', $1F));
Itog^.Insert(Control);

DelSpace(Kassa^.Dat.ReportKassa);
RFormat(Kassa^.Dat.ReportKassa,CIZena);

R.Assign(62, 10, 78, 11);
Control := New(PColoredText, Init(R, Kassa^.Dat.ReportKassa, $30));
Itog^.Insert(Control);
{$EndIF$}


R.Assign(63, 17, 78, 18);
Control := New(PColoredText, Init(R, 'Остаток на скл.', $1F));
Itog^.Insert(Control);

{2}Kassa^.Dat.Ostatok:=SSklad;
   DelSpace(Kassa^.Dat.Ostatok);

{R.Assign(42, 20, 61, 21);}
R.Assign(63, 18, 78, 19);
Control := New(PColoredText, Init(R, SSklad, $3E));
Itog^.Insert(Control);


{s:=CalcDolgDebit(2,False);}
MyStr(StrToReal(Kassa^.Dat.OstatokConsig),CIZena,CMantissa,Kassa^.Dat.OstatokConsig);
DelSpace(Kassa^.Dat.OstatokConsig);
R.Assign(42, 2, 59, 3);
Control := New(PColoredText, Init(R, 'Остаток консиг.Т', $1F));
Itog^.Insert(Control);

R.Assign(42, 3, 58, 4);
Control := New(PColoredText, Init(R, #3+Kassa^.Dat.OstatokConsig, $71{1A}));
Itog^.Insert(Control);

MyStr(StrToReal(Kassa^.Dat.SkOstatokConsig),CIZena,CMantissa,Kassa^.Dat.SkOstatokConsig);
DelSpace(Kassa^.DAt.skOstatokConsig);

R.Assign(42, 4, 58, 5);
Control := New(PColoredText, Init(R, 'Скид.ост.консиг.', $1F));
Itog^.Insert(Control);

R.Assign(42, 5, 58, 6);
Control := New(PColoredText, Init(R, #3+Kassa^.Dat.SkOstatokConsig, $71));
Itog^.Insert(Control);

R.Assign(42, 6, 59, 7);
Control := New(PColoredText, Init(R, 'Ост.конс. С/Ф Т', $1F));
Itog^.Insert(Control);

MyStr(StrToReal(OstConsigSF),CIZena,CMantissa,OstConsigSF);
DelSpace(OstConsigSF);

R.Assign(42, 7, 58, 8);
Control := New(PColoredText, Init(R, #3+OstConsigSF, $71));
Itog^.Insert(Control);


R.Assign(42, 8, 58, 9);
Control := New(PColoredText, Init(R, 'Скид.ост.кон.СФ', $1F));
Itog^.Insert(Control);

MyStr(StrToReal(SkOstConsigSF),CIZena,CMantissa,SkOstConsigSF);
DelSpace(SkOstConsigSF);

R.Assign(42, 9, 58, 10);
Control := New(PColoredText, Init(R, #3+SKOstConsigSF, $71));
Itog^.Insert(Control);

Itog^.SelectNext(False);
NoInfo;
ShowKassa:=False;
GlobalTime:=TimeStringToTime('hh:mm:ss',Times);

c:=Desktop^.ExecView(Itog);
Dispose(Kassa,Done);{уничтожаем экземпляр объекта кассовый лист}
Dispose(Control,Done);
Dispose(Itog,Done);
If ShowKassa Then ViewKassa(True,KassaDAte);
end;



Destructor TItogWindow.Done;
Begin
TDialog.Done;
End;



Procedure TItogWindow.ShowDohod;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c: Word;
  Temp,Temp1 : String;
begin
R.Assign(27, 8, 53, 14);
New(Dlg, Init(R, 'Доходность'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E091;

MyStr(StrToReal(Kassa^.Dat.DohodAll),CIZena,CMAntissaZ,Temp);
Str(StrToInt(DohodKol):CLitr,Temp1);

R.Assign(3, 2, 24, 3);
Control := New(PColoredText, Init(R, Temp+' '+Temp1, $30));
Dlg^.Insert(Control);

R.Assign(3, 1, 23, 2);
Control := New(PColoredText, Init(R, 'Общий доход за день', $70));
Dlg^.Insert(Control);

MyStr(StrToReal(Kassa^.Dat.DohodAgent),CIZena,CMAntissaZ,Temp);
Str(StrToInt(DohodAgentKol):CLitr,Temp1);

R.Assign(3, 4, 24, 5);
Control := New(PColoredText, Init(R, Temp+' '+Temp1, $30));
Dlg^.Insert(Control);

R.Assign(3, 3, 24, 4);
Control := New(PColoredText, Init(R, 'Доход-служба доставки', $70));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);

Dispose(Control,Done);
Dispose(Dlg,Done);
end;






procedure TItogWindow.HandleEvent(var Event: TEvent);
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


Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
       cmItogBarter:Brt^.OpenViewBarterItog;
       cmItogSertif:Srt^.OpenViewSertifItog;
       cmItogBN:BN^.OpenViewBNItog;
        cmFormKassa:Begin

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

                    If Not(TestOpenDate1(FDate)) Or (StrToInt(CurrentPassword)=0) Then
                     Begin

{$IFDEF NetVersion}
If (StrToInt(CurrentPassword)<>0) And (DisableClose=1) Then
Begin
 MessageBox(^M+#3'С этой рабочей станции нельзя заполнять контрольный кассовый лист!',Nil,mfError+mfCancelButton);
 Exit;
End;
{$EndIF}
                      If (StrToInt(CurrentPassword)<>0) Then
                      MessageBox(#3+'ОБРАЩАЮ Ваше внимание - кассовый лист заполняется ТОЛЬКО ОДИН РАЗ!'^M+
                                  #3+'Будьте внимательней!',Nil,mfInformation+
                                  mfCancelButton);
                      kw^.start(False);
                     End
                    Else
                     Begin
{$IFDEF NetVersion}
If (StrToInt(CurrentPassword)<>0) And (DisableClose=1) Then
Begin
 MessageBox(^M+#3'С этой рабочей станции нельзя заполнять контрольный кассовый лист!',Nil,mfError+mfCancelButton);
 Exit;
End;
{$EndIf}
                      MessageBox(#3'Кассовый лист заполняется только после закрытия дня'^M+
                                  #3+'и ОБРАЩАЮ Ваше внимание - ТОЛЬКО ОДИН РАЗ',Nil,mfError+mfCancelButton);
                                 End;
                     ClearEvent(Event);
                       End;
   Else;
   End;

 evKeyDown :
   Case Event.KeyCode Of
       kbAltRusK : Begin
                    Event.What:=EvCommand;
                    Event.Command:=cmLocalCalc;
                    PutEvent(Event);
                   End;
       kbCtrlRusD,
       kbAltRusD : Begin
                    If Password(5) Then
                     Begin
                      ShowDohod;
                     End;
                   End;
   Else;
   End;
    Else;
    End;

  Inherited HandleEvent(Event);
  {ClearEvent(Event);}
End;


Procedure TBarterItogWindow.OpenViewBarterItog;
 var
  R : TRect;
  Control : PView;
  c : Word;
  TempS : AllStr;
begin
R.Assign(20, 6, 59, 17);
New(BarterItog, Init(R, 'Взаимозачеты'));
BarterItog^.Options := BarterItog^.Options or ofCenterX or ofCenterY;
BarterItog^.HelpCtx := $E556;

R.Assign(6, 1, 19, 2);
Control := New(PStaticText, Init(R, 'Приход Б З/Ц:'));
BarterItog^.Insert(Control);

TempS:=Kassa^.Dat.BarterPrihod;
RFormat(TempS,CIZena);
RFormat(BarterPrhKol,CLitrMantissa);

R.Assign(19, 1, 38, 2);
Control := New(PColoredText, Init(R, TempS+' '+BarterPrhKol, $1F));
BarterItog^.Insert(Control);

TempS:=Kassa^.Dat.BarterT;
RFormat(TempS,CIZena);
RFormat(BarterKol,CLitrMantissa);

R.Assign(8, 2, 19, 3);
Control := New(PStaticText, Init(R, 'Выдано Б Т:'));
BarterItog^.Insert(Control);

R.Assign(19, 2, 38, 3);
Control := New(PColoredText, Init(R, TempS+' '+BarterKol, $1F));
BarterItog^.Insert(Control);

TempS:=Kassa^.Dat.BarterSkidki;
RFormat(TempS,CIZena);

R.Assign(19, 3, 38, 4);
Control := New(PColoredText, Init(R, TempS, $1F));
BarterItog^.Insert(Control);

R.Assign(2, 3, 19, 4);
Control := New(PStaticText, Init(R, '  Скиди выдачи Б:'));
BarterItog^.Insert(Control);


TempS:=Kassa^.Dat.BarterOutKassa;
RFormat(TempS,CIZena);

R.Assign(19, 4, 38, 5);
Control := New(PColoredText, Init(R, TempS, $1F));
BarterItog^.Insert(Control);

R.Assign(1, 4, 19, 5);
Control := New(PStaticText, Init(R, 'Выдано из кассы Б:'));
BarterItog^.Insert(Control);

TempS:=Kassa^.Dat.BarterInKassa;
RFormat(TempS,CIZena);


R.Assign(19, 5, 38, 6);
Control := New(PColoredText, Init(R, TempS, $1F));
BarterItog^.Insert(Control);

R.Assign(2, 5, 19, 6);
Control := New(PStaticText, Init(R, 'Оплата Б в кассу:'));
BarterItog^.Insert(Control);

TempS:=Kassa^.Dat.OstatokBarter;
RFormat(TempS,CIZena);

R.Assign(19, 6, 38, 7);
Control := New(PColoredText, Init(R, TempS, $1F));
BarterItog^.Insert(Control);

R.Assign(4, 6, 19, 7);
Control := New(PStaticText, Init(R, 'Всего сальдо Б:'));
BarterItog^.Insert(Control);




TempS:=Kassa^.Dat.BarterPrihodRZ;
RFormat(TempS,CIZena);
RFormat(BarterPrhKolRZ,CLitrMantissa);
RFormat(NoInputBarterPrhRZ,CIZena);
RFormat(NoInputBarterPrhKolRZ,CLitrMantissa);



R.Assign(19, 8, 38, 10);
Control := New(PColoredText, Init(R, TempS+' '+BarterPrhKolRZ+^M+
                                     NoInputBarterPrhRZ+' '+NoInputBarterPrhKolRZ, $1F));
BarterItog^.Insert(Control);

R.Assign(6, 8, 19, 9);
Control := New(PStaticText, Init(R, 'Приход Б Р/Ц:'));
BarterItog^.Insert(Control);



BarterItog^.SelectNext(False);

c:=Desktop^.ExecView(BarterItog);

Dispose(Control,Done);
Dispose(BarterItog,Done);
end;


Destructor TBarterItogWindow.Done;
Begin
TDialog.Done;
End;

procedure TBarterItogWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;


Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
   Else;
   End;
 Else;
 End;
 Inherited HandleEvent(Event);
End;



Procedure TSertifItogWindow.OpenViewSertifItog;
 var
  R : TRect;
  Control : PView;
  c : Word;
  TempS : AllStr;
begin
R.Assign(17, 7, 62, 15);
New(SertifItog, Init(R, 'Итоги прихода/расхода сертификатов'));
SertifItog^.Options := SertifItog^.Options or ofCenterX or ofCenterY;
{SertifItog^.Palette := dpCyanDialog;}
SertifItog^.HelpCtx := $E556;

R.Assign(6, 1, 25, 2);
Control := New(PStaticText, Init(R, 'Продажи (клиент) Т:'));
SertifItog^.Insert(Control);

MyStr(StrToReal(Kassa^.Dat.SertifProdagi),CIZena,CMantissa,TempS);
DelSpace(TempS);
RFormat(TempS,CIZena);
DelSpace(SertifProdagiCKol);
RFormat(SertifProdagiCKol,CLitrMantissa);

R.Assign(25, 1, 44, 2);
Control := New(PColoredText, Init(R, TempS+' '+SertifProdagiCKol, $1F));
SertifItog^.Insert(Control);

R.Assign(1, 2, 25, 3);
Control := New(PStaticText, Init(R, 'Скидки продажи (клиент):'));
SertifItog^.Insert(Control);

TempS:=SertifProdagiCSkidki;
DelSpace(TempS);
RFormat(TempS,CIZena);

R.Assign(25, 2, 44, 3);
Control := New(PColoredText, Init(R, TempS, $1F));
SertifItog^.Insert(Control);

R.Assign(11, 4, 25, 5);
Control := New(PStaticText, Init(R, 'Выдано по Б Т:'));
SertifItog^.Insert(Control);

MyStr(StrToReal(Kassa^.Dat.SertifBarterT),CIZena,CMantissa,TempS);
DelSpace(TempS);
RFormat(TempS,CIZena);
DelSpace(SertifBarterKol);
RFormat(SertifBarterKol,CLitrMantissa);

R.Assign(25, 4, 44, 5);
Control := New(PColoredText, Init(R, TempS+' '+SertifBarterKol, $1F));
SertifItog^.Insert(Control);

R.Assign(8, 6, 25, 7);
Control := New(PStaticText, Init(R, 'Р/П сертификатов:'));
SertifItog^.Insert(Control);

MyStr(StrToReal(Kassa^.Dat.SertifRP),CIZena,CMantissa,TempS);
DelSpace(TempS);
RFormat(TempS,CIZena);
DelSpace(SertifRPKol);
RFormat(SertifRPKol,CLitrMantissa);

R.Assign(25, 6, 44, 7);
Control := New(PColoredText, Init(R, Temps+' '+SertifRPKol, $1F));
SertifItog^.Insert(Control);



R.Assign(6, 5, 25, 6);
Control := New(PStaticText, Init(R, 'Скидки выдачи по Б:'));
SertifItog^.Insert(Control);

MyStr(StrToReal(Kassa^.Dat.SertifBarterSkidki),CIZena,CMantissa,TempS);
DelSpace(TempS);
RFormat(TempS,CIZena);

R.Assign(25, 5, 44, 6);
Control := New(PColoredText, Init(R, TempS, $1F));
SertifItog^.Insert(Control);


R.Assign(8, 3, 25, 4);
Control := New(PStaticText, Init(R, 'Отгрузка (склад):'));
SertifItog^.Insert(Control);

MyStr(StrToReal(SertifProdagiS),CIZena,CMantissa,TempS);
DelSpace(TempS);
RFormat(TempS,CIZena);
DelSpace(SertifProdagiSKol);
RFormat(SertifProdagiSKol,CLitrMantissa);

R.Assign(25, 3, 44, 4);
Control := New(PColoredText, Init(R, TempS+' '+SertifProdagiSKol, $1F));
SertifItog^.Insert(Control);

SertifItog^.SelectNext(False);

c:=Desktop^.ExecView(SertifItog);

Dispose(Control,Done);
Dispose(SertifItog,Done);
end;


Destructor TSertifItogWindow.Done;
Begin
TDialog.Done;
End;

procedure TSertifItogWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;


Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
   Else;
   End;
 Else;
 End;
 Inherited HandleEvent(Event);
End;



Procedure TBNItogWindow.OpenViewBNItog;
 var
  R : TRect;
  Control : PView;
  c : Word;
  TempS : AllStr;
begin
R.Assign(15, 8, 65, 14);
New(BNItog, Init(R, 'Безналичные операции'));
BNItog^.Options := BNItog^.Options or ofCenterX or ofCenterY;
{BNItog^.Palette := dpCyanDialog;}
BNItog^.HelpCtx := $E556;

R.Assign(2, 1, 34, 2);
Control := New(PStaticText, Init(R, 'Оплата б/н без отсрочки платежа:'));
BNItog^.Insert(Control);

MyStr(StrToReal(Kassa^.Dat.BNProdagi),CIZena,CMantissa,TempS);

R.Assign(34, 1, 49, 2);
Control := New(PColoredText, Init(R, TempS, $1F));
BNItog^.Insert(Control);

R.Assign(11, 2, 34, 3);
Control := New(PStaticText, Init(R, 'Оплата б/н консигнации:'));
BNItog^.Insert(Control);

MyStr(StrToReal(Kassa^.Dat.BNOplataConsig),CIZena,CMantissa,TempS);

R.Assign(34, 2, 49, 3);
Control := New(PColoredText, Init(R, TempS, $1F));
BNItog^.Insert(Control);

R.Assign(2, 3, 34, 4);
Control := New(PStaticText, Init(R, 'Б/н в кассу в счет взаимозачета:'));
BNItog^.Insert(Control);

MyStr(StrToReal(Kassa^.Dat.BNBarterInKassa),CIZena,CMantissa,TempS);

R.Assign(34, 3, 49, 4);
Control := New(PColoredText, Init(R, TempS, $1F));
BNItog^.Insert(Control);



R.Assign(1, 4, 34, 5);
Control := New(PStaticText, Init(R, 'Б/н из кассы в счет взаимозачета:'));
BNItog^.Insert(Control);

MyStr(StrToReal(Kassa^.Dat.BNBarterOutKassa),CIZena,CMantissa,TempS);

R.Assign(34, 4, 49, 5);
Control := New(PColoredText, Init(R, Temps, $1F));
BNItog^.Insert(Control);

BNItog^.SelectNext(False);

c:=Desktop^.ExecView(BNItog);

Dispose(Control,Done);
Dispose(BNItog,Done);
end;


Destructor TBNItogWindow.Done;
Begin
TDialog.Done;
End;

procedure TBNItogWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;


Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
   Else;
   End;
 Else;
 End;
 Inherited HandleEvent(Event);
End;





Function WriteKassaToFile(kk:PKassaType;Mode:Boolean): Boolean;
Var kf : File Of KassaType;
    Ext : ArtikulStr;
    w : Byte;
Begin
AddProtocol('Подготовка к записи контрольного кассового листа склада за '+KassaDate,'','');
WriteKassaToFile:=False;
Kk^.Dat.EPerewoskiInp[0]:=#0;
Kk^.Dat.EPerewoskiOut[0]:=#0;

For w:=1 To Max30 Do
 Begin
  MyStr(StrToReal(Kk^.Dat.PerewoskiInp[w])+StrToReal(Kk^.Dat.EPerewoskiInp),CIZena,CMAntissa,
  Kk^.Dat.EPerewoskiInp);
  MyStr(StrToReal(Kk^.Dat.PerewoskiOut[w])+StrToReal(Kk^.Dat.EPerewoskiOut),CIZena,CMAntissa,
  Kk^.Dat.EPerewoskiOut);
 End;

Str(StrToInt(Rek^.Dat.Kod):2,Ext);
RFormatZerro(Ext,2);
Assign(kf,Path^.Dat.ToArchiv+KassaDate+'.k'+Ext);
w:=IOResult;
Rewrite(kf);
w:=IOResult;
If w<>0 Then
 Begin
  MessageBox(^m+#3'Не могу создать файл '+Path^.Dat.ToArchiv+KassaDate+'.k'+Ext,Nil,mfError+mfCancelButton);
  Exit;
 End;
Seek(kf,0);
Write(kf,kk^.Dat);
Close(kf);
If Not(Mode) Then
AddProtocol('Ввод контрольного кассового листа склада за '+KassaDate,'','')
Else
AddProtocol('Корректировка контрольного кассового листа склада за '+KassaDate,'','');
MessageBox(^M+#3'Контрольный кассовый лист успешно сохранен!',Nil,mfInformation+mfCancelButton);
WriteKassaToFile:=True;
End;


Var PrevKassa : PKassaType;
    RegimKassa : Boolean;


Procedure RunTest(kk:PKassaType);
Var kf : File Of KassaType;
    ktest : PKassaType;
    BarterSaldo,OstatokKassa,OstatokZakupka,
    SummaKassa,OstatokC,OtkatC,OstatokS : String[CIZena+1];
    w,i,j : LongInt;
    c : Word;
    res : Real;
    s : DateSTring;
    Ext : ArtikulStr;
    Find : Boolean;
    R : TRect;
    Control : PView;
    Dlg : PDialog;
    txt : Text;

Begin
Str(StrToInt(Rek^.Dat.Kod):2,Ext);
RFormatZerro(Ext,2);
Find:=FAlse;
i:=DAteStringToDate(DateMask,KassaDate);
j:=i-10;

 While Not(Find) and (i>=j) Do
  Begin
   Dec(i);
   s:=DAteToDateString(DateMask,i);
   s:=s+'.k'+Ext;
   w := IOResult;
   Assign(kf,Path^.Dat.ToArchiv+s);
   Reset(kf);
   w:=IOResult;
   If (w=0) Then Find:=True;
  End;

If Not(Find) Then
Begin
 MessageBox(^M+#3'Не могу провести проверку т.к. не найдено ни одного файла за последние 10 дней!',
 Nil,mfError+mfCancelButton);
 Exit;
End;

New(kTest,Init);
w:=IOResult;
Read(kf,KTest^.Dat);
w:=IOResult;
If W<>0 Then
Begin
 Dispose(kTest,Done);
 MessageBox(^M+#3'Ошибка чтения файла '+Path^.Dat.ToArchiv+s,Nil,mfError+mfCancelButton);
 Close(kf);
 Exit;
End;
Close(kf);


SummaKAssa[0]:=#0;
OstatokKAssa[0]:=#0;
OstatokS[0]:=#0;
BarterSaldo[0]:=#0;
OstatokZakupka[0]:=#0;
OstatokC[0]:=#0;
OtkatC[0]:=#0;

Kk^.Dat.EPerewoskiInp[0]:=#0;
kk^.Dat.EPerewoskiOut[0]:=#0;

For j:=1 To Max30 Do
 Begin
  MyStr(StrToReal(kk^.Dat.PerewoskiInp[j])+StrToReal(kk^.Dat.EPerewoskiInp),CIZena,CMAntissa,
  kk^.Dat.EPerewoskiInp);
  MyStr(StrToReal(kk^.Dat.PerewoskiOut[j])+StrToReal(kk^.Dat.EPerewoskiOut),CIZena,CMAntissa,
  kk^.Dat.EPerewoskiOut);
 End;

{Начинаем тестирование}



{сумма в кассе}
With kk^.Dat Do
Begin
{дополнена}
MyStr(STrToReal(SummaInKassa)
-  (StrToReal(Prodagi)
-   StrToReal(SkProdagi)
+   StrToReal(OplataINKassa)
+   StrToReal(BarterINKassa)
-   StrToReal(BarterOutKassa)
+   StrToReal(SertifProdagi)
-   StrToReal(SertifSkProdagi)
+   StrToReal(ExtendedDohod)
-   StrToReal(RAshod)
-   StrToReal(RAshodFromReturn)
-   StrToReal(KillOtkat){выдача денег из кассы по откату}
-   StrToReal(BNOPlataConsig){безналичные оплаты консигнации}
-   StrToReal(BNProdagi){безналичные оплаты без отсрочки}
-   StrToReal(BNBarterInKassa){безналичные поступления по бартеру}
+   StrToReal(BNBarterOutKassa){безналичные расходы по бартеру}
+   StrToReal(KTest^.DAt.OstatokInKAssa)
),CIZena+1,CMAntissa,SummaKAssa);

If (Abs(StrToReal(SummaKAssa))<0.009) Then SummaKassa:='Ок';
DelSpace(SummaKassa);
End;

{Остаток в кассе}
With kk^.Dat Do
Begin
MyStr(StrToReal(OstatokInKassa)
-  (StrToReal(SummaInKassa)
-   StrToReal(Sdano)
   )
   ,CIZena+1,CMAntissa,OstatokKAssa);

If (Abs(StrToReal(OstatokKAssa))<0.009) Then OstatokKassa:='Ок';
DelSpace(OstatokKassa);
End;


{Остаток на складе}
With kk^.Dat Do
Begin
{дополнена}
MyStr(StrToReal(OStatok)
-  (StrToReal(kTest^.DAt.OStatok)
+   StrToReal(Prihod)
+   StrToReal(BarterPrihodRZ)
+   StrToReal(EPerewoskiInp)
-   StrToReal(EPerewoskiOut)
-   StrToReal(RP)
-   StrToReal(SertifRP)
-   StrToReal(Prodagi)
-   StrToReal(SertifProdagi)
-   StrToReal(BarterT)
-   StrToReal(SertifBarterT)
-   StrToReal(VidanoConsig)
+   StrToReal(Rewisia)
+   StrToReal(Pereozenka)
+   StrToReal(PereozenkaFromReturn)
+   StrToReal(ReturnOutMArketDocAndCloseConsig)
+   StrToReal(ReturnOutOpenConsig))
   ,CIZena+1,CMantissa,OstatokS);
If (Abs(StrToReal(OstatokS))<0.009) Then OstatokS:='Ок';
DelSpace(OstatokS);
End;

(*
Assign(txt,Path^.Dat.ToTemp+'runtest.txt');
Rewrite(txt);
With kk^.Dat Do
Begin
Writeln(txt,OStatok+' ',StrToReal(OStatok):CIZena:Cmantissa);
Writeln(txt,kTest^.DAt.OStatok+'-',StrToReal(kTest^.DAt.OStatok):CIZena:CMantissa);
Writeln(txt,Prihod,'+',StrToReal(Prihod):CIZena:CMantissa);
Writeln(txt,BarterPrihodRZ+'+',StrToReal(BarterPrihodRZ):CIZena:CMantissa);
Writeln(txt,EPerewoskiInp+'+',StrToReal(EPerewoskiInp):CIZena:CMantissa);
Writeln(txt,EPerewoskiOut+'-',StrToReal(EPerewoskiOut):CIZena:CMantissa);
Writeln(txt,RP,'-',StrToReal(RP):CIZena:CMantissa);
Writeln(txt,SertifRP,'-',StrToReal(SertifRP):CIZena:CMantissa);
Writeln(txt,Prodagi,'-',StrToReal(Prodagi):CIZena:CMantissa);
Writeln(txt,SertifProdagi,'-',StrToReal(SertifProdagi):CIZena:CMantissa);
Writeln(txt,BarterT,'-',StrToReal(BarterT):CIZena:CMantissa);
Writeln(txt,SertifBarterT,'-',StrToReal(SertifBarterT):CIZena:CMantissa);
Writeln(txt,VidanoConsig,'-',StrToReal(VidanoConsig):CIZena:CMantissa);
Writeln(txt,Rewisia,'+',StrToReal(Rewisia):CIZena:CMantissa);
Writeln(txt,Pereozenka,'+',StrToReal(Pereozenka):CIZena:CMantissa);
Writeln(txt,PereozenkaFromReturn,'+',StrToReal(PereozenkaFromReturn):CIZena:CMantissa);
Writeln(txt,ReturnOutMArketDocAndCloseConsig,'+',StrToReal(ReturnOutMArketDocAndCloseConsig):CIZena:CMantissa);
Writeln(txt,ReturnOutOpenConsig+'+',StrToReal(ReturnOutOpenConsig):CIZena:CMantissa);
Writeln(txt,OstatokS);
End;
Close(txt);
*)

{Остаток консигнации}
With kk^.Dat Do
Begin
MyStr(StrToReal(OstatokConsig)
-  (StrToReal(kTest^.DAt.OstatokConsig)
+   StrToReal(VidanoConsig)
{+   StrToReal(SNalogC)}
-   StrToReal(OplataINKassa)
-   StrToReal(SkOformConsign)
-   StrToReal(ReturnOutOpenConsig)
{-  StrToReal(SNalogReturnOpenConsig)}
+   StrToReal(RashodFromReturnOpenConsig))
    ,CIZena+1,CMantissa,OstatokC);
If (Abs(StrToReal(OstatokC))<0.009) Then OstatokC:='Ок';
DelSpace(OstatokC);
End;
{конец тестирование}


{Сальдо бартера}
{дополнена}
With kk^.Dat Do
Begin
MyStr(StrToReal(OstatokBarter)
-   StrToReal(kTest^.DAt.OstatokBarter)
+   StrToReal(BarterPrihod)
+   StrToReal(BarterINKassa)
-   StrToReal(BarterOutKassa)
-   StrToReal(BarterT)
+   StrToReal(BarterSkidki)
-   StrToReal(SertifBarterT)
+   StrToReal(SertifBarterSkidki),CIZena+1,CMantissaZ,
    BarterSaldo);
If (Abs(StrToReal(BarterSaldo))<0.00009) Then BarterSaldo:='Ок';
DelSpace(BarterSaldo);
End;

{Остаток на складе по закупке}
With kk^.Dat Do
Begin
{
MemC(OstatokZ);
MemC(kTest^.DAt.OstatokZ);
MemC(PrihodZC);
MemC(EPrihodZS);
MemC(PrihodZB);
MemC(RewisiaZ);
MemC(ReturnZ);
MemC(OtgruzkaZC);
MemC(EOtgruzkaZS);
MemC(OtgruzkaZB);
MemC(OtgruzkaZRP);
}
MyStr(StrToReal(OstatokZ)
-   (StrToReal(kTest^.DAt.OstatokZ)
+   StrToReal(PrihodZC)
+   StrToReal(PrihodZS)
+   StrToReal(PrihodZB)
+   StrToReal(RewisiaZ)
+   StrToReal(ReturnZ)
-   StrToReal(OtgruzkaZC)
-   StrToReal(OtgruzkaZS)
-   StrToReal(OtgruzkaZB)
-   StrToReal(OtgruzkaZRP)),CIZena+1,CMantissaZ,
    OstatokZakupka);
If (Abs(StrToReal(OstatokZakupka))<0.009) Then OstatokZakupka:='Ок';
DelSpace(OstatokZakupka);
End;
{конец тестирование}


{Остаток отката}
With kk^.Dat Do
Begin
MyStr(StrToReal(Otkat)
-  (StrToReal(kTest^.DAt.Otkat)
+   StrToReal(AddOtkat)
-   StrToReal(KillOtkat))
    ,CIZena+1,CMantissa,OtkatC);
If (Abs(StrToReal(OtkatC))<0.009) Then OtkatC:='Ок';
DelSpace(OtkatC);
End;
{конец тестирование}


Dispose(KTest,Done);

{Вывод на экран результатов}
R.Assign(21, 7, 59, 17);
New(Dlg, Init(R, 'Результаты тестирования'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E090;

R.Assign(1, 1, 22, 8);
Control := New(PColoredText, Init(R,
     '   Остаток на складе:'^M+
     ' Остаток консигнации:'^M+
     '   Сальдо по бартеру:'^M+
     '       Сумма в кассе:'^M+
     '     Остаток в кассе:'^M+
     '  Остаток по З/Ценам:'^M+
     '  Остаток по БОНУСАМ:'^M
        , $30));
Dlg^.Insert(Control);

R.Assign(22, 1, 37, 2);
Control := New(PColoredText, Init(R, #3+OstatokS, $3E));
Dlg^.Insert(Control);

R.Assign(22, 2, 37, 3);
Control := New(PColoredText, Init(R, #3+OstatokC, $3E));
Dlg^.Insert(Control);

R.Assign(22, 3, 37, 4);
Control := New(PColoredText, Init(R, #3+BarterSaldo, $3E));
Dlg^.Insert(Control);

R.Assign(22, 4, 37, 5);
Control := New(PColoredText, Init(R, #3+SummaKassa, $3E));
Dlg^.Insert(Control);

R.Assign(22, 5, 37, 6);
Control := New(PColoredText, Init(R, #3+OstatokKAssa, $3E));
Dlg^.Insert(Control);

R.Assign(22, 6, 37, 7);
Control := New(PColoredText, Init(R, #3+OstatokZakupka, $3E));
Dlg^.Insert(Control);

R.Assign(22, 7, 37, 8);
Control := New(PColoredText, Init(R, #3+OtkatC, $3E));
Dlg^.Insert(Control);

R.Assign(2, 8, 36, 9);
s:=DAteToDateString(DateMask,i);
Control := New(PStaticText, Init(R, 'Использовались данные за '+s));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);
Dispose(Control,Done);
Dispose(Dlg,Done);
{закрытие окна результатов теста}
End;


Procedure TKassaWindow.KassaToList(kk:PKassaType);
VAr s : STring;
    c : Word;
    st,s1 : AllStr;
Begin
kk^.Formatreal;

With kk^.Dat Do
Begin
 {1}
 s:='009│Приход на склад от клиента                                │'+Prihod;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {2}
 s:='010│Остаток на складе                                         │'+Ostatok;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {3}
 s:='011│РП работы                                                 │'+RP;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {4}
 s:='012│РП работы (сертификаты)                                   │'+SertifRP;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {5}
 s:='013│Сумма со склада                                           │'+SummaOutSklad;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {6}
 s:='014│Выдано без отсрочки платежа (Т)                           │'+Prodagi;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {7}
 s:='015│Скидки выдачи без отсрочки платежа                        │'+SkProdagi;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {8}
 s:='016│Выдано сертификатов без отсрочки платежа (Т)              │'+SertifProdagi;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {9}
 s:='017│Скидки выдачи сертификатов без отсрочки платежа           │'+SertifSkProdagi;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {10}
 s:='018│Выдано на консигнацию (Т)                                 │'+VidanoConsig;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {11}
 s:='019│Скидки выданной консигнации                               │'+SkVidanoConsig;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {12}
 s:='020│Оплата консигнации в кассу                                │'+OplataInKassa;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {13}
 s:='021│Скидки оформленной консигнации                            │'+SkOformConsign;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {14}
 s:='022│Возврат по открытой консигнации (Т)                       │'+ReturnOutOpenConsig;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {15}
 s:='023│Скидки возврата по открытой консигнации                   │'+SkReturnOutOpenConsig;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {16}
 s:='024│Возврат по документам продажи и закрытой консигнации (Т)  │'+ReturnOutMArketDocAndCloseConsig;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {17}
 s:='025│Скидки возврата по документам продажи и закрыт.консигнации│'+SkReturnOutMArketDocAndCloseConsig;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {18}
 s:='026│Остаток консигнации (Т)                                   │'+OstatokConsig;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {19}
 s:='027│Скидки остатка консигнации                                │'+SkOstatokConsig;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {20}
 s:='028│Переоценка                                                │'+Pereozenka;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {21}
 s:='029│Переоценка по возврату                                    │'+PereozenkaFromReturn;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {22}
 s:='030│Расходы по возврату                                       │'+RashodFromReturn;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {23}
 s:='031│Расходы по возврату открытой консигнации                  │'+RashodFromReturnOpenConsig;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {24}
 s:='032│Сумма по выданным С/Ф                                     │'+VidanoSF;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {25}
 s:='033│Ревизия на складе                                         │'+Rewisia;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {26}
 s:='034│Сбор НП по отгрузке клиенту без отсрочки платежа          │'+SNAlogP;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {27}
 s:='035│Сбор НП по отгрузке клиенты на консигнацию                │'+SNAlogC;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {28}
 s:='036│НП по возврату отрытой консигнации                        │'+SNalogReturnOpenConsig;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {29}
 s:='037│Сальдо по взаимозачетам                                   │'+OstatokBarter;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {30}
 s:='038│Приход в счет взаимозачета по З/Ц                         │'+BarterPrihod;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {31}
 s:='039│Приход на склад в счет взаимозачета по Р/Ц                │'+BarterPrihodRZ;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {32}
 s:='040│Выдано клиентам в счет взаимозачета  (Т)                  │'+BarterT;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {33}
 s:='041│Скидки выдачи клиентам в счет взаимозачета                │'+BarterSkidki;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {34}
 s:='042│Выдано сертификатов клиентам в счет взаимозачета  (Т)     │'+SertifBarterT;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {35}
 s:='043│Скидки выдачи сертификатов клиентам в счет взаимозачета   │'+SertifBarterSkidki;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {36}
 s:='044│Поступления в кассу в счет взаимозачета                   │'+BarterInKassa;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {37}
 s:='045│Расход из кассы в счет взаимозачета                       │'+BarterOutKassa;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {38}
 s:='046│Безналичные оплаты консигнации                            │'+BNOPlataConsig;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {39}
 s:='047│Безналичные оплаты товара без отсрочки платежа            │'+BNProdagi;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {40}
 s:='048│Безналичные поступления в счет взаимозачета               │'+BNBarterInKassa;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {41}
 s:='049│Безналичные расходы в счет взаимозачета                   │'+BNBarterOutKassa;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {42}
 s:='050│Остаток переплат клиентов за наличный расчет              │'+OstatokPereplatN;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {43}
 s:='051│Остаток переплат клиентов за безналичный расчет           │'+OstatokPereplatB;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {44}
 s:='052│Остаток переплат клиентов по векселям                     │'+OstatokPereplatV;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {45}
 s:='053│Поступления в счет переплат клиентов за наличный расчет   │'+NewPereplatN;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {46}
 s:='054│Поступления в счет переплат клиентов за безналичный расчет│'+NewPereplatB;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {47}
 s:='055│Поступления в счет переплат клиентов за вексельный расчет │'+NewPereplatV;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {48}
 s:='056│Расход наличных переплат клиентов                         │'+RashodPereplatN;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {49}
 s:='057│Расход безналичных переплат клиентов                      │'+RashodPereplatB;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {50}
 s:='058│Расход вексельных переплат клиентов                       │'+RashodPereplatV;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {51}
 s:='059│Остаток акциза на складе                                  │'+OstatokAkzis;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {52}
 s:='060│Акцизный сбор по документам без отсрочки платежа          │'+ProdagiCAkzis;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {53}
 s:='061│Акцизный сбор по межскладским перевозкам                  │'+ProdagiSAkzis;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {54}
 s:='062│Акцизный сбор по документам отгрузки в счет взаимозачета  │'+ProdagiBAkzis;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {55}
 s:='063│Акцизный сбор по документам, выданным на консигнацию      │'+VidanoConsigAkzis;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {56}
 s:='064│Акцизный сбор по документам оформленной консигнации       │'+OformlenoConsigAkzis;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {57}
 s:='065│Акцизный сбор по документам прихода от клиента            │'+PrihodCAkzis;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {58}
 s:='066│Акцизный сбор по документам межскладского прихода         │'+PrihodSAkzis;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {59}
 s:='067│Акцизный сбор по документам прихода в счет взаимозачета   │'+PrihodBAkzis;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {60}
 s:='068│Акцизный сбор по документам возврата от клиента           │'+ReturnCAkzis;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {61}
 s:='069│Акцизный сбор по документам межскладского возврата        │'+ReturnSAkzis;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);
 {62}
 s:='070│Акцизный сбор по документам ревизии                       │'+RevisiaAkZis;
 KassaList^.List^.Insert(NewStr(s));
 KassaList^.SetRange(KassaList^.List^.Count);






 For c:=71{59}{46} To 100{73}{60} Do
 Begin
  s:=GetClientField(FCLient,IntToStr(c-70{58{45},2),1);
  Format(s,29);
  st:=IntToStr(c,3);
  RFormatZerro(st,3);
  s:=st+'│'+'Перевозки со склада на склад '+ s+'│'+PerewoskiOut[c-70{58{45}];
  KassaList^.List^.Insert(NewStr(s));
  KassaList^.SetRange(KassaList^.List^.Count);
 End;

 For c:=101{74{61} To 130{75} Do
 Begin
  s:=GetClientFieLd(FCLient,IntToStr(c-100{73{60},2),1);
  Format(s,29);
  {
  If c<100 Then
  s1:=IntToStr(c,2)
  Else
  s1:='9A';
  }
  st:=IntToStr(c,3);
  RFormatZerro(st,3);

  s:=st+'│'+'Перевозки на склад со склада '+ s+'│'+PerewoskiInp[c-100{73{60}];
  KassaList^.List^.Insert(NewStr(s));
  KassaList^.SetRange(KassaList^.List^.Count);
 End;
End{With}
End;



Procedure TKassaWindow.ListToKassa(Var kk:PKassaType);
VAr s : STring;
         c : Word;
Begin
With kk^.Dat Do
Begin
 For c:=0 To KAssaList^.List^.Count-1 Do
 Begin
  s:=KAssaList^.GetText(c,KAssaList^.List^.Count);
  System.Delete(s,1,4);
  Case c Of
  0:Prihod:=Copy(s,Pos('│',s)+1,CIZena);
  1:Ostatok:=Copy(s,Pos('│',s)+1,CIZena);
  2:Rp:=Copy(s,Pos('│',s)+1,CIZena);
  3:SertifRp:=Copy(s,Pos('│',s)+1,CIZena);
  4:SummaOutSklad:=Copy(s,Pos('│',s)+1,CIZena);
  5:Prodagi:=Copy(s,Pos('│',s)+1,CIZena);
  6:SkProdagi:=Copy(s,Pos('│',s)+1,CIZena);
  7:SertifProdagi:=Copy(s,Pos('│',s)+1,CIZena);
  8:SertifSkProdagi:=Copy(s,Pos('│',s)+1,CIZena);
  9:VidanoConsig:=Copy(s,Pos('│',s)+1,CIZena);
 10:SkVidanoConsig:=Copy(s,Pos('│',s)+1,CIZena);
 11:OplataInKassa:=Copy(s,Pos('│',s)+1,CIZena);
 12:SkOformConsign:=Copy(s,Pos('│',s)+1,CIZena);
 13:ReturnOutOpenConsig:=Copy(s,Pos('│',s)+1,CIZena);
 14:SkReturnOutOpenConsig:=Copy(s,Pos('│',s)+1,CIZena);
 15:ReturnOutMArketDocAndCloseConsig:=Copy(s,Pos('│',s)+1,CIZena);
 16:SkReturnOutMArketDocAndCloseConsig:=Copy(s,Pos('│',s)+1,CIZena);
 17:OstatokConsig:=Copy(s,Pos('│',s)+1,CIZena);
 18:SkOstatokConsig:=Copy(s,Pos('│',s)+1,CIZena);
 19:Pereozenka:=Copy(s,Pos('│',s)+1,CIZena);
 20:PereozenkaFromReturn:=Copy(s,Pos('│',s)+1,CIZena);
 21:RashodFromReturn:=Copy(s,Pos('│',s)+1,CIZena);
 22:RashodFromReturnOpenConsig:=Copy(s,Pos('│',s)+1,CIZena);
 23:VidanoSF:=Copy(s,Pos('│',s)+1,CIZena);
 24:Rewisia:=Copy(s,Pos('│',s)+1,CIZena);
 25:SNAlogP:=Copy(s,Pos('│',s)+1,CIZena);
 26:SNAlogC:=Copy(s,Pos('│',s)+1,CIZena);
 27:SNalogReturnOpenConsig:=Copy(s,Pos('│',s)+1,CIZena);
 28:OstatokBarter:=Copy(s,Pos('│',s)+1,CIZena);
 29:BarterPrihod:=Copy(s,Pos('│',s)+1,CIZena);
 30:BarterPrihodRZ:=Copy(s,Pos('│',s)+1,CIZena);
 31:BarterT:=Copy(s,Pos('│',s)+1,CIZena);
 32:BarterSkidki:=Copy(s,Pos('│',s)+1,CIZena);
 33:SertifBarterT:=Copy(s,Pos('│',s)+1,CIZena);
 34:SertifBarterSkidki:=Copy(s,Pos('│',s)+1,CIZena);
 35:BarterInKassa:=Copy(s,Pos('│',s)+1,CIZena);
 36:BarterOutKassa:=Copy(s,Pos('│',s)+1,CIZena);
 {новый кусочек}

 37:BNOPlataConsig:=Copy(s,Pos('│',s)+1,CIZena);
 38:BNProdagi:=Copy(s,Pos('│',s)+1,CIZena);

 39:BNBarterInKassa:=Copy(s,Pos('│',s)+1,CIZena);
 40:BNBarterOutKassa:=Copy(s,Pos('│',s)+1,CIZena);

 41:OstatokPereplatN:=Copy(s,Pos('│',s)+1,CIZena);
 42:OstatokPereplatB:=Copy(s,Pos('│',s)+1,CIZena);
 43:OstatokPereplatV:=Copy(s,Pos('│',s)+1,CIZena);
 44:NewPereplatN:=Copy(s,Pos('│',s)+1,CIZena);
 45:NewPereplatB:=Copy(s,Pos('│',s)+1,CIZena);
 46:NewPereplatV:=Copy(s,Pos('│',s)+1,CIZena);
 47:RashodPereplatN:=Copy(s,Pos('│',s)+1,CIZena);
 48:RashodPereplatB:=Copy(s,Pos('│',s)+1,CIZena);
 49:RashodPereplatV:=Copy(s,Pos('│',s)+1,CIZena);
 50:OstatokAkzis:=Copy(s,Pos('│',s)+1,CIZena);
 51:ProdagiCAkzis:=Copy(s,Pos('│',s)+1,CIZena);
 52:ProdagiSAkzis:=Copy(s,Pos('│',s)+1,CIZena);
 53:ProdagiBAkzis:=Copy(s,Pos('│',s)+1,CIZena);
 54:VidanoConsigAkzis:=Copy(s,Pos('│',s)+1,CIZena);
 55:OformlenoConsigAkzis:=Copy(s,Pos('│',s)+1,CIZena);
 56:PrihodCAkzis:=Copy(s,Pos('│',s)+1,CIZena);
 57:PrihodSAkzis:=Copy(s,Pos('│',s)+1,CIZena);
 58:PrihodBAkzis:=Copy(s,Pos('│',s)+1,CIZena);
 59:ReturnCAkzis:=Copy(s,Pos('│',s)+1,CIZena);
 60:ReturnSAkzis:=Copy(s,Pos('│',s)+1,CIZena);
 61:RevisiaAkZis:=Copy(s,Pos('│',s)+1,CIZena);

 {37..51}
 {50..64}
 62..{76}91
       :Begin
         PerewoskiOut[c-{36}{49}61]:=Copy(s,Pos('│',s)+1,CIZena);
        End;
 {52..66}
 {65..79}
 92..121
       :Begin
         PerewoskiInp[c-{51}{64}91]:=Copy(s,Pos('│',s)+1,CIZena);
        End;
 Else;
 End;{CAse}
End;{For}
End;{With}

kk^.FormatReal;

With kk^.DAt Do {удаление пробелов}
BEgin
DelSpace(SummaInKassa);
DelSpace(OstatokInKassa);
DelSpace(Sdano);
DelSpace(ExtendedDohod);
DelSpace(Rashod);
DelSpace(SertifProdagi);
DelSpace(DohodAll);
DelSpace(DohodAgent);
DelSpace(DohodSertif);
DelSpace(Prihod);
DelSpace(Ostatok);
DelSpace(Rp);
DelSpace(SertifRp);
DelSpace(SummaOutSklad);
DelSpace(Prodagi);
DelSpace(SkProdagi);
DelSpace(SertifProdagi);
DelSpace(SertifSkProdagi);
DelSpace(VidanoConsig);
DelSpace(SkVidanoConsig);
DelSpace(OplataInKassa);
DelSpace(SkOformConsign);
DelSpace(ReturnOutOpenConsig);
DelSpace(SkReturnOutOpenConsig);
DelSpace(ReturnOutMArketDocAndCloseConsig);
DelSpace(SkReturnOutMArketDocAndCloseConsig);
DelSpace(OstatokConsig);
DelSpace(SkOstatokConsig);
DelSpace(Pereozenka);
DelSpace(PereozenkaFromReturn);
DelSpace(RashodFromReturn);
DelSpace(RashodFromReturnOpenConsig);
DelSpace(VidanoSF);
DelSpace(Rewisia);
DelSpace(SNAlogP);
DelSpace(SNAlogC);
DelSpace(SNalogReturnOpenConsig);
DelSpace(OstatokBarter);
DelSpace(BarterPrihod);
DelSpace(BarterPrihodRZ);
DelSpace(BarterT);
DelSpace(BarterSkidki);
DelSpace(SertifBarterT);
DelSpace(SertifBarterSkidki);
DelSpace(BarterInKassa);
DelSpace(BarterOutKassa);

DelSpace(Otkat);
DelSpace(AddOtkat);
DelSpace(KillOtkat);
DelSpace(KillOtkatToDay);
DelSpace(OtgruzkaWithOplataWithOutAkzis);

DelSpace(PrihodZC);
DelSpace(PrihodZS);
DelSpace(PrihodZB);

DelSpace(OstatokZ);
DelSpace(OstatokConsigZ);
DelSpace(RewisiaZ);
DelSpace(ReturnZ);
DelSpace(MinusDohod);
DelSpace(AllDohod);
DelSpace(AllDohodA);

DelSpace(OstatokAkzis);
DelSpace(ProdagiCAkzis);
DelSpace(ProdagiSAkzis);
DelSpace(ProdagiBAkzis);
DelSpace(VidanoConsigAkzis);
DelSpace(OformlenoConsigAkzis);
DelSpace(PrihodCAkzis);
DelSpace(PrihodSAkzis);
DelSpace(PrihodBAkzis);
DelSpace(ReturnCAkzis);
DelSpace(ReturnSAkzis);
DelSpace(RevisiaAkZis);
DelSpace(ReportKAssa);

DelSpace(OtgruzkaZC);
DelSpace(OtgruzkaZS);
DelSpace(OtgruzkaZB);
DelSpace(OtgruzkaZRP);


{безналичный расчет}
DelSpace(BNOPlataConsig);
DelSpace(BNProdagi);

DelSpace(BNBarterInKassa);
DelSpace(BNBarterOutKassa);

{переплаты}
DelSpace(OstatokPereplatN);
DelSpace(OstatokPereplatB);
DelSpace(OstatokPereplatV);
    {поступления переплат}
DelSpace(NewPereplatN);
DelSpace(NewPereplatB);
DelSpace(NewPereplatV);
    {расход переплат}
DelSpace(RashodPereplatN);
DelSpace(RashodPereplatB);
DelSpace(RashodPereplatV);

DelSpace(PrihodZC2);
DelSpace(PrihodZS2);
DelSpace(PrihodZB2);
DelSpace(OstatokZ2);
DelSpace(RewisiaZ2);
DelSpace(ReturnZ2);
DelSpace(MinusDohod2);
DelSpace(AllDohod2);
DelSpace(AllDohodA2);
DelSpace(AllDohodB2);
DelSpace(AllDohodS2);
DelSpace(MinusDohod);
DelSpace(AllDohod);
DelSpace(AllDohodA);
DelSpace(AllDohodB);
DelSpace(AllDohodS);
DelSpace(OtgruzkaZC2);
DelSpace(OtgruzkaZS2);
DelSpace(OtgruzkaZB2);
DelSpace(OtgruzkaZRP2);
DelSpace(OstatokAZ);
DelSpace(OstatokAZ2);
DelSpace(OstatokNZ);
DelSpace(OstatokNZ2);


For c:=1 To Max30 Do
 Begin
  DelSpace(PerewoskiOut[c]);
  DelSpace(PerewoskiOutZ[c]);
  DelSpace(PerewoskiOutZ2[c]);
  DelSpace(PerewoskiInp[c]);
  DelSpace(PerewoskiInpZ[c]);
  DelSpace(PerewoskiInpZ2[c]);
 End;
End;{With}

End;{Procedure}


Procedure TKassaWindow.Start(Mode:Boolean);
var
  R : TRect;
  Control : PView;
  {PrevKassa,}kk : PKAssaType;
  c : Word;
  s : AllStr;
  Regim : Boolean;
  FK : File Of KassaType;

begin
RegimKassa:=Mode;
Str(StrToInt(Rek^.Dat.Kod):2,s);
RFormatZerro(s,2);
KassaDate:=FDate;
If Not(Mode) Then
Begin
Assign(fk,Path^.Dat.ToArchiv+KassaDate+'.k'+s);
c:=IOResult;
Reset(fk);
c:=IOResult;
If c=0 Then
 Begin
  System.Close(fk);
  If StrToInt(CurrentPassword)<>0 Then
  Begin
  MessageBox(#3+'Кассовый лист уже заполнен!'^M+
  #3+'Его повторный ввод или корректировка запрещены!'^M+
  #3+'Звоните в финансовый департамент!',Nil,mfError+mfCancelButton);
  Exit;
  End;
 End;

{AInfo('Подсчитываю межскладские перевозки...');}
DInfoMsg('Подсчитываю межскладские перевозки...',False);
End
Else
 Begin
  If Not(DateDialog(KassaDate)) Then Exit;
  Assign(fk,Path^.Dat.ToArchiv+KassaDate+'.k'+s);
  c:=IOResult;
  Reset(fk);
  c:=IOResult;
  If c<>0 Then
   Begin
    MessageBox(^M+#3+'Ошибка открытия файла кассы за '+KassaDate,Nil,mfError+mfCancelButton);
    Exit;
   End;
  New(PrevKassa,Init);
  c:=IOResult;
  Read(fk,PrevKassa^.Dat);
  c:=IOResult;
  If c<>0 Then
   Begin
    c:=IOResult;
    System.Close(fk);
    Dispose(PrevKassa,Done);
    MessageBox(^M+#3+'Ошибка чтения файла кассы за '+KassaDate,Nil,mfError+mfCancelButton);
    Exit;
   End;
   System.Close(fk);
 End;

New(kk,Init);{создаем редактируемый объект кассового листа}

If Not(Mode) Then
kk^.Dat:=KAssa^.Dat
Else
Begin
kk^.Dat:=PrevKassa^.Dat;
kk^.dat.DateC:=PrevKassa^.DAt.DateC;
kk^.DAt.TimeC:=PrevKassa^.DAt.TimeC;
kk^.Dat.Caption:=CurrentPassword;
End;

{подсчитываем межскладские перевозки}
For c:=1 To Max30 Do
Begin

If Not(Mode) Then
Begin
Str(c:CClientKod,s);
s:=CalcOutSkladPerevoski(s);
kk^.Dat.PerewoskiOut[c]:=s;

Str(c:CClientKod,s);
s:=CalcInpSkladPerevoski(s);
kk^.Dat.PerewoskiInp[c]:=s;
End;

End;



If (StrToInt(CurrentPassword)=0) Then Regim:=True
Else Regim:=False;

If Not(Regim) Then
Begin
RFormatZerro(KK^.Dat.DohodAll,10);
RFormatZerro(KK^.Dat.DohodAgent,10);
RFormatZerro(KK^.Dat.DohodSertif,10);
End;

R.Assign(0, 0, 80, 23);

s:=FormKod(Rek^.Dat.Kod);
s:=GEtClientField(FClient,s,1);
DelSpaceLeftRight(s);

New(KassaWindow, Init(R, 'Контрольный кассовый лист склада '+s+' за '+KassaDate));
kassawindow^.HelpCtx := $E191;

R.Assign(0, 22, 0, 23);
Control := New(PColoredText, Init(R, '', $77));
KassaWindow^.Insert(Control);

R.Assign(19, 1, 31, 2);
ControlSummaInKassa := New(PInputLine, Init(R, CIZena));
KassaWindow^.Insert(ControlSummaInKassa);
  PInputLine(ControlSummaInKassa)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(4, 1, 19, 2);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Сумма в кассе:', ControlSummaInKassa)));

DelSpace(kk^.Dat.SummaInKassa);
ControlSummaInKassa^.SetData(kk^.Dat.SummaInKassa);


R.Assign(19, 2, 31, 3);
ControlOstatok := New(PInputLine, Init(R, CIZena));
KassaWindow^.Insert(ControlOstatok);
  PInputLine(ControlOstatok)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(2, 2, 19, 3);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Остаток в кассе:', ControlOstatok)));

DelSpace(kk^.Dat.OstatokInKassa);
ControlOstatok^.SetData(kk^.Dat.OstatokInKassa);


R.Assign(19, 3, 31, 4);
ControlSdano := New(PInputLine, Init(R, CIZena));
KassaWindow^.Insert(ControlSdano);
  PInputLine(ControlSdano)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(12, 3, 19, 4);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Сдано:', ControlSdano)));

DelSpace(kk^.Dat.Sdano);
ControlSdano^.SetData(kk^.Dat.Sdano);

R.Assign(44, 1, 56, 2);
ControlDD := New(PInputLine, Init(R, CIZena));
KassaWindow^.Insert(ControlDD);
  PInputLine(ControlDD)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(33, 1, 44, 2);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Доп.доход:', ControlDD)));

DelSpace(kk^.Dat.ExtendedDohod);
ControlDD^.SetData(kk^.Dat.ExtendedDohod);


R.Assign(44, 2, 56, 3);
ControlRashod := New(PInputLine, Init(R, CIZena));
KassaWindow^.Insert(ControlRashod);
  PInputLine(ControlRashod)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(35, 2, 44, 3);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Расходы:', ControlRashod)));

DelSpace(kk^.Dat.Rashod);
ControlRashod^.SetData(kk^.Dat.Rashod);


R.Assign(44, 3, 56, 4);
If Regim Then
Begin
ControlDoh := New(PInputLine, Init(R, CIZena));
PInputLine(ControlDoh)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
End
 Else
ControlDoh := New(PSInputLine, Init(R, CIZena));
KassaWindow^.Insert(ControlDoh);
  If Not(Regim) Then ControlDoh^.Options := ControlDoh^.Options and not ofSelectable;

  R.Assign(33, 3, 44, 4);
  If Regim Then
  KassaWindow^.Insert(New(PLabel, Init(R, '    Доход:', ControlDoh)))
  Else
  KassaWindow^.Insert(New(PLabel, Init(R, '     ??? :', ControlDoh)));

DelSpace(kk^.Dat.DohodAll);
ControlDoh^.SetData(kk^.Dat.DohodAll);


R.Assign(67, 1, 79, 2);
If Regim Then
Begin
ControlDohAg := New(PInputLine, Init(R, CIZena));
PInputLine(ControlDohag)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
End
Else
ControlDohag := New(PSInputLine, Init(R, CIZena));
KassaWindow^.Insert(ControlDohag);
  If Not(Regim) Then ControlDohag^.Options := ControlDohag^.Options and not ofSelectable;

  R.Assign(58, 1, 67, 2);
  If Regim Then
  KassaWindow^.Insert(New(PLabel, Init(R, 'Доход А:', ControlDohAg)))
  Else
  KassaWindow^.Insert(New(PLabel, Init(R, ' ???   :', ControlDohAg)));

DelSpace(kk^.Dat.DohodAgent);
ControlDohag^.SetData(kk^.Dat.DohodAgent);



R.Assign(67, 2, 79, 3);
If Regim Then
Begin
ControlSert := New(PInputLine, Init(R, CIZena));
PInputLine(ControlSert)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
End
Else
ControlSert := New(PSInputLine, Init(R, CIZena));
KassaWindow^.Insert(ControlSert);
  If Not(Regim) Then ControlSert^.Options := ControlSert^.Options and not ofSelectable;

  R.Assign(58, 2, 67, 3);
  If Regim Then
  KassaWindow^.Insert(New(PLabel, Init(R, 'Доход С:', ControlSert)))
  Else
  KassaWindow^.Insert(New(PLabel, Init(R, '   ??? :', ControlSert)));

DelSpace(kk^.Dat.DohodSertif);
ControlSert^.SetData(kk^.Dat.DohodSertif);


(*
{заполняем первую часть кассового листа}
With Pk Do
Begin
  SummaInKassa :=Kk^.Dat.SummaInKassa;
OstatokInKassa :=Kk^.Dat.OstatokInKassa;
         Sdano :=Kk^.Dat.Sdano;
 ExtendedDohod :=Kk^.Dat.ExtendedDohod;
        Rashod :=Kk^.Dat.Rashod;
    Sertifikat :=Kk^.Dat.Sertifikat;
      DohodAll :=Kk^.Dat.Dohodall;
    DohodAgent :=Kk^.Dat.DohodAgent;
End;
{закончили заполнять первую часть кассового листа}

KassaWindow^.SetData(Pk);
*)
R.Assign(1, 1, 3, 4);
Control := New(PColoredText, Init(R,
     '1'^M+
     '2'^M+
     '3', $7E));
KassaWindow^.Insert(Control);

R.Assign(32, 1, 33, 4);
Control := New(PColoredText, Init(R,
     '4'^M+
     '5'^M+
     '6', $7E));
KassaWindow^.Insert(Control);

R.Assign(57, 1, 58, 4);
Control := New(PColoredText, Init(R,
     '7'^M+
     '8', $7E));
KassaWindow^.Insert(Control);


{кассовый лист начиная с девятого пункта}
R.Assign(80, 4, 81, 22);
Control := New(PScrollBar, Init(R));
KassaWindow^.Insert(Control);

R.Assign(1, 4, 80, 22);
KassaList := New(PBox, Init(R, 1, PScrollbar(Control)));
KassaList^.NewList(New(PTextCollection, Init(0,1)));

KassaWindow^.KassaToList(KK);

KassaList^.FocusItem(0);
KassaList^.HelpCtx:=$F099;
KassaWindow^.Insert(KassaList);

If Mode Then
Begin
R.Assign(26-25, 22, 53-25, 23);
Control := New(PColoredText, Init(R, 'Идет корректировка данных', $DE));
{Control^.Options := Control^.Options or ofCenterX;}
KassaWindow^.Insert(Control);
End;


{добавлено по просьбе фиников 15/05/2003}
R.Assign(40, 22, 79, 23);
Control := New(PColoredText, Init(R, #3+'Суточный отчет по ККМ:'+Kk^.Dat.ReportKassa, $4E));
KassaWindow^.Insert(Control);

KassaWindow^.SelectNext(False);


ProdagaWindow:=True;
If Not(Mode) Then NoInfoMsg;
c:=Desktop^.ExecView(KassaWindow);

If c<>cmCAncel Then
 Begin
 AddProtocol('Чтение данных кассы '+KassaDate,'','');
 {KassaWindow^.GetData(kk^.Dat);}
 If Mode Then DIspose(PrevKassa,Done);

 ControlSummaInKassa^.GetData(kk^.Dat.SummaInKassa);
 ControlOstatok^.GetData(kk^.Dat.OstatokInKassa);
 ControlSdano^.GetData(kk^.Dat.Sdano);
 ControlDD^.GetData(kk^.Dat.ExtendedDohod);
 ControlRashod^.GetData(kk^.Dat.Rashod);
 ControlDoh^.GetData(kk^.Dat.DohodAll);
 ControlDohAg^.GetData(kk^.Dat.DohodAgent);
 ControlSert^.GetData(kk^.Dat.DohodSertif);
 KK^.Dat.Caption:=CurrentPassword;
 KK^.Dat.TimeM:=Times;
 KK^.Dat.DateM:=FDate;


{
With KK^.Dat Do
Begin
  SummaInKassa :=Pk.SummaInKassa;
OstatokInKassa :=Pk.OstatokInKassa;
            Sdano :=Pk.Sdano;
 ExtendedDohod :=Pk.ExtendedDohod;
           Rashod :=Pk.Rashod;
    Sertifikat :=Pk.Sertifikat;
      DohodAll :=Pk.Dohodall;
    DohodAgent :=Pk.DohodAgent;
End;
}
 KassaWindow^.ListToKassa(KK);

 If Not(Mode) Then kassa^.Dat:=Kk^.Dat;

 If WriteKassaToFile(kk,Mode) And Not(Mode) Then
 {If Not(Mode) Then }ShowKAssa:=True;
 End;
ProdagaWindow:=False;
Dispose(kk,Done);
Dispose(Control,Done);
Dispose(KassaWindow,Done);
end;


Destructor TKassaWindow.Done;
Begin
TDialog.Done;
End;

Procedure EditPunkt(Posit:Word;s:String);
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  Dan : String[CIZena];
  Lab : String;
  Numer : ArtikulStr;
  c : Word;
begin
Numer:=Copy(s,1,3);
System.Delete(s,1,Pos('│',s));
Lab:=Copy(s,1,Pos('│',s)-1);

Dan:=Copy(s,Pos('│',s)+1,CIZena);
DelSpace(Dan);
R.Assign(0, 10, 80, 13);
New(Dlg, Init(R, 'Корректировка параметра кассового листа'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(62, 1, 79, 2);
Control := New(PInputLine, Init(R, CIZena));


If StrToInt(Copy(Numer,1,2)) in [15,17,19,21,23,25,27,28,29,33,37,41,43,70{16,18,20,22,24,25,26,30,34,38}] Then
PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']))
Else
PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

Dlg^.Insert(Control);

R.Assign(1, 1, 62, 2);
Control := New(PColoredText, Init(R, Lab+' : ', $74));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetData(Dan);

c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
 Begin
  Dlg^.GetData(Dan);
  MyStr(StrToReal(Dan),CIZena,CMantissaZ,Dan);
  s:=Numer+'│'+Lab+'│'+Dan;
 {System.Delete(s,Pos('│',s)+4,CIZena);
  s:=s+Dan;}
  KassaList^.List^.Atfree(Posit);
  KassaList^.List^.Insert(NewStr(s));
  KassaList^.SetRange(KassaList^.List^.Count);
 End;

Dispose(Control,Done);
Dispose(Dlg,Done);

end;


Procedure TKassaWindow.HAndleEvent(Var Event:TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var kk1 : PKassaType;
    Pk1 : PSevdoKassaType;
    Position : word;
    s : String;
Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmTestSklad:Begin
                     New(kk1,Init);
                     ControlSummaInKassa^.GetData(kk1^.Dat.SummaInKassa);
                     ControlOstatok^.GetData(kk1^.Dat.OstatokInKassa);
                     ControlSdano^.GetData(kk1^.Dat.Sdano);
                     ControlDD^.GetData(kk1^.Dat.ExtendedDohod);
                     ControlRashod^.GetData(kk1^.Dat.Rashod);
                     ControlDoh^.GetData(kk1^.Dat.DohodAll);
                     ControlDohAg^.GetData(kk1^.Dat.DohodAgent);
                     ControlSert^.GetData(kk1^.Dat.DohodSertif);
{With KK1^.Dat Do
Begin
  SummaInKassa :=Pk1.SummaInKassa;
OstatokInKassa :=Pk1.OstatokInKassa;
            Sdano :=Pk1.Sdano;
 ExtendedDohod :=Pk1.ExtendedDohod;
           Rashod :=Pk1.Rashod;
    Sertifikat :=Pk1.Sertifikat;
      DohodAll :=Pk1.Dohodall;
    DohodAgent :=Pk1.DohodAgent;
End;            }

               If Not RegimKassa Then
               Begin
               With kk1^.Dat Do
               Begin
                           Otkat:=Kassa^.Dat.Otkat;
                           AddOtkat:=Kassa^.Dat.AddOtkat;
                           KillOtkat:=Kassa^.Dat.KillOtkat;
                           KillOtkatToDay:=Kassa^.Dat.KillOtkatToDay;
                           OtgruzkaWithOplataWithOutAkzis:=Kassa^.Dat.OtgruzkaWithOplataWithOutAkzis;
                            PrihodZC:=Kassa^.Dat.PrihodZC;
                            PrihodZS:=Kassa^.Dat.PrihodZS;
                            PrihodZB:=Kassa^.Dat.PrihodZB;
                           OstatokZ :=Kassa^.Dat.OstatokZ;
                     OstatokConsigZ :=Kassa^.Dat.OstatokConsigZ;
                           RewisiaZ :=Kassa^.Dat.RewisiaZ;
                            ReturnZ :=Kassa^.Dat.ReturnZ;
                          OtgruzkaZC:=Kassa^.Dat.OtgruzkaZC;
                          OtgruzkaZS:=Kassa^.Dat.OtgruzkaZS;
                          OtgruzkaZB:=Kassa^.Dat.OtgruzkaZB;
                         OtgruzkaZRP:=Kassa^.Dat.OtgruzkaZRP;

PrihodZC2:=Kassa^.Dat.PrihodZC2;
PrihodZS2:=Kassa^.Dat.PrihodZS2;
PrihodZB2:=Kassa^.Dat.PrihodZB2;
OstatokZ2:=Kassa^.Dat.OstatokZ2;
RewisiaZ2:=Kassa^.Dat.RewisiaZ2;
ReturnZ2:=Kassa^.Dat.ReturnZ2;
OtgruzkaZC2:=Kassa^.Dat.OtgruzkaZC2;
OtgruzkaZS2:=Kassa^.Dat.OtgruzkaZS2;
OtgruzkaZB2:=Kassa^.Dat.OtgruzkaZB2;
OtgruzkaZRP2:=Kassa^.Dat.OtgruzkaZRP2;
OstatokAZ:=Kassa^.Dat.OstatokAZ;
OstatokAZ2:=Kassa^.Dat.OstatokAZ2;
OstatokNZ:=Kassa^.Dat.OstatokNZ;
OstatokNZ2:=Kassa^.Dat.OstatokNZ2;

               End;
               End
                Else
                 Begin
               With kk1^.Dat Do
               Begin
                           Otkat:=PrevKassa^.Dat.Otkat;
                           AddOtkat:=PrevKassa^.Dat.AddOtkat;
                           KillOtkat:=PrevKassa^.Dat.KillOtkat;
                           KillOtkatToDay:=PrevKassa^.Dat.KillOtkatToDay;
                           OtgruzkaWithOplataWithOutAkzis:=PrevKassa^.DAt.OtgruzkaWithOplataWithOutAkzis;
                            PrihodZC:=PrevKassa^.Dat.PrihodZC;
                            PrihodZS:=PrevKassa^.Dat.PrihodZS;
                            PrihodZB:=PrevKassa^.Dat.PrihodZB;
                           OstatokZ :=PrevKassa^.Dat.OstatokZ;
                     OstatokConsigZ :=PrevKassa^.Dat.OstatokConsigZ;
                           RewisiaZ :=PrevKassa^.Dat.RewisiaZ;
                            ReturnZ :=PrevKassa^.Dat.ReturnZ;
                          OtgruzkaZC:=PrevKassa^.Dat.OtgruzkaZC;
                          OtgruzkaZS:=PrevKassa^.Dat.OtgruzkaZS;
                          OtgruzkaZB:=PrevKassa^.Dat.OtgruzkaZB;
                         OtgruzkaZRP:=PrevKassa^.Dat.OtgruzkaZRP;

PrihodZC2:=PrevKassa^.Dat.PrihodZC2;
PrihodZS2:=PrevKassa^.Dat.PrihodZS2;
PrihodZB2:=PrevKassa^.Dat.PrihodZB2;
OstatokZ2:=PrevKassa^.Dat.OstatokZ2;
RewisiaZ2:=PrevKassa^.Dat.RewisiaZ2;
ReturnZ2:=PrevKassa^.Dat.ReturnZ2;
OtgruzkaZC2:=PrevKassa^.Dat.OtgruzkaZC2;
OtgruzkaZS2:=PrevKassa^.Dat.OtgruzkaZS2;
OtgruzkaZB2:=PrevKassa^.Dat.OtgruzkaZB2;
OtgruzkaZRP2:=PrevKassa^.Dat.OtgruzkaZRP2;
OstatokAZ:=PrevKassa^.Dat.OstatokAZ;
OstatokAZ2:=PrevKassa^.Dat.OstatokAZ2;
OstatokNZ:=PrevKassa^.Dat.OstatokNZ;
OstatokNZ2:=PrevKassa^.Dat.OstatokNZ2;


               End;
                 End;
                     ListToKassa(kk1);
                     RunTest(kk1);
                     Dispose(kk1,Done);
                    End;


        cmLocalCalc:Calculator;

     cmEdit     :Begin
       If (KassaList^.State and sfFocused <> 0) And (KassaList^.List<>Nil)And(KassaList^.List^.Count>=1) Then
            Begin
             Position:=KassaList^.Focused;
             S:=KassaList^.GetText(KAssaList^.Focused,KassaList^.List^.Count);
             EditPunkt(Position,s);
             Redraw;
            End;
                 End;

        cmOk       :Begin
                       If MessageBox(#3'Вы убеждены что каждая цифра кассового листа введена правильно?'^M+
                                     #3'После ввода данных корректировка будет невозможна!',nil,mfOkCancel)<>cmOk Then
                     Begin
                      ClearEvent(Event);
                      Exit;
                     End;
                    End;
   Else;
   End;
 evKeyDown :
 CAse Event.KeyCode Of
kbAltRusT,
  kbF9 :Begin
         If Password(3) Then
         Begin
         Event.What:=EvCommand;
         Event.Command:=cmTestSklad;
         PutEvent(Event);
         End;
         ClearEvent(Event);
        End;
 Else;
 End;
   Else;
   End;
inherited HandleEvent(Event);
End;{handleevent}









End.