(*
переоценка экранная форма для 26 цен
внесение изменений в форматы продаж и приходов (CLitr+1)
подправить продажи а также просмотр продаж по F5
переделать настройку скидок 26 цен
*)


Unit Glob;

Interface

Uses Objects,ServStr,TpDate{,OWindows};
(*
{$IfDEF DPMI}
Uses Objects,ServStr;
{$Else}
Uses Overlay,Objects,ServStr;
{$EndIF}*)
Const

{Варианты статус}
{ DocPrint      =1;}

    BufferGroup = 100;
    BufferDB = 210;
    BufferCOpl = 320;
    BufferDLG = 350;
    BufItg=101;
    CGram = 3;
    CZenaZ = 10;

  DocEdit       =2;
  DocNormal     =0;

  EndFile       = True;
  NoEndFile     = Not(EndFile);

{Конец Вариантов статус}

  DateFiltr='[##-##-##]';
  Buffer = 88;

  CNDS20='18%';


{Варианты вида документа}

  DocPrihod     =0;
  DocPereozen   =1;
  DocReturn     =2;
  DocRewisia    =3;
  DocMarket     =4;
  DocOplata     =5;
  DocProtocol   =6;
DocProtocolReturn=7;
DocBarterOplata =8;
  DocKassa      =9;
  DocTransport  =10;


   MaxStatRazdel=99;

{Конец вариантов вида документа}

  cmViewCorrectSklad = 270;


  cmNone       = 100;
  cmCalculator = 101;
  cmCalendar   = 102;
  cmBlack      = 103;
  cmPrint      = 104;
  cmColor      = 105;
  cmConfig     = 106;
  cmPrihod     = 107;
  cmPrihodDisk = 108;
  cmEditDoc    = 109;
  cmPrintDoc   = 110;
  cmViewPrihod = 111;
  cmViewPereozenka= 112;
  cmViewProd    = 113;
  cmViewRealizas= 114;
  cmViewVoswrat = 115;
  cmViewDoc     = 116;
  cmCopyToArc   = 117;
  cmPrintPreisList = 118;
  cmPrintSklad = 119;
  cmAbout      = 120;
  cmPereozen   = 121;
  cmRekwiziti  = 122;
  cmSuperMarket= 123;
  cmConfigMarket= 124;
  cmSkidki     = 125;
  cmCorrectSklad = 126;
  cmCalcMenedger = 127;
  cmOperator = 128;
  cmLockDay = 129;
  cmUnLockDay = 130;
  cmLocalCalc = 131;
  cmVozwrat   = 132;
  cmSelectClient = 133;
  cmSelectRazdel = 134;
  cmItogoProdaga = 135;
  cmItogoRealizas = 136;
  cmViewCorrectVozwrat= 270;
  cmInputToSklad = 138;
  cmPrintRewizia=139;
  cmDolg = 140;
  cmPrintDebitDolg=141;
  cmViewOplataRealiz = 142;
  cmAllTCh = 143;
  cmAllSf = 144;
  cmAllSpis = 145;
  cmAllSfb = 146;
  cmEditPosition = 147;
  cmOplata = 148;
  cmDeblock = 149;
  cmItogi = 150;
  cmTest = 151;
  cmViewRp = 152;
  cmReestrDoc=153;
  cmEdit = 154;
  cmPrintReestr = 155;
  cmFullView = 156;
  cmRunModem = 157;
  cmCreatReport = 158;
  cmReestrReport = 159;
  cmInfoDebit = 160;
  cmSetupMarketDoc = 161;
  cmSetupDebitDoc = 162;
  cmIndex = 163;
  cmLocalSkidka = 164;
  cmLocalNazenka= 165;
  cmChangeDoc=166;
  cmInfoReturn=167;
  cmLocalInfo = 168;
  cmCalcRozniza=169;
  cmConfigPrint=170;
  cmRewisia = 171;
  cmViewRewisia = 172;
  cmOstatki_Market=173;
  cmStat          =174;
  cmChangeDiapason=175;
  cmPrintScreen   = 176;
  cmTestSklad     = 177;
  cmClientStat    = 177;
  CmCalcStat      = 178;
  cmView          = 179;
  cmUserScreen    = 180;
  cmLastPrise     = 181;
  cmFind          = 182;
  cmNextFind      = 183;
  cmFormKassa     = 184;
  cmPrintKassa    = 185;
  cmCorrectKassa  = 186;
  cmLockPeriod    = 187;
  cmUnLockPeriod  = 188;
  cmAnalysFromPeriod = 189;
  cmReanim = 190;
  cmReanimClient = 191;
  cmRefresh = 192;
  cmUnLockDoc=193;
  cmCreatSpecialFile =194;
  cmMaxMin=195;
  cmTovarStat=196;
  cmPrihC=197;
  cmPrihS=198;
  cmMrkC=199;
  cmMrkS=200;
  cmReturnC=201;
  cmReturnS=202;
  cmPrz=203;
  cmRwz=204;
  cmRp=205;
  cmDetal=206;
  cmRewisiaEdit = 207;
  cmFindDSertif = 208;
  cmSetupPassword = 209;
  cmMarketStat =210;
  CmChangeShkala =211;
  cmUnLockMarket = 212;
  cmBalance = 213;
  cmSpecialMarketStat = 214;
  cmReestrPrh=215;
  cmViewSkidki= 216;
  cmIndexSkidki= 217;
  cmSelectAgent = 218;
  cmMakeHistory = 219;
  cmMakeStat = 220;
  cmGroupPereoz = 221;
  cmPolitikaSkidok = 222;
  cmBuch = 223;

  cmInputKreditClient = 224;

  cmViewSpecialKassa = 226;
  cmMakeHistoryOpl= 227;
  cmMakeHistoryReturn= 228;
  cmViewLockBaza = 229;
  cmReestrRwz=230;
  cmEndRep=231;
  cmKassaStat=232;


  cmBarter = 233;
  cmViewOplataBarter = 234;
  cmItogBarter = 235;
  cmCalcSaldoBarter = 236;
  cmAddKassa = 237;
  cmOutKassa = 238;
  cmPrihB= 239;
  cmMrkB = 240;
  cmStat1 = 241;
  cmProperties =242;
  cmCreatPlan = 243;
  cmReestrKAssa = 244;
  cmSelectKAssa = 245;
  cmParametr = 246;
  cmReestrVzw = 247;
  cmDocFiltr = 248;
  cmOperatorReport =249;
  cmExportImport=250;
  cmCAlcDebitAgent = 251;
  cmViewSkidki1 = 252;
  cmViewSkidki2 = 253;
  cmRekwiziti2 = 254;
  cmLockFromPeriod=255;
  cmChangeNumber = 256;
  cmSelectGroup = 257;
  cmSelectRewGroup =258;
  cmViewSkidkiPeronal = 259;
  cmCalcMenedger2 =260;
  cmSetupStart = 261;
  cmFindSrok = 262;
  cmError = 263;
  cmError2 = 264;
  cmBuchProd = 265;
  cmBuchPrihod = 266;
  cmArcOst=267;
  cmTransport = 137;

  cmSelectOtdelenie=281;
  cmViewTransport = 282;
  cmBuch2 = 283;
  cmDopOper = 284;
  cmPostZak = 285;
  cmVvodSkidki = 286;
  cmArcDlg = 287;
  cmGrAgent = 288;
  cmLoadMainSklad = 289;
  cmSaveRemote = 290;
  cmBuchNovarReport = 291;
  cmImpClient = 292;
  cmEmlDolg =  293;
  cmCalcDebitEmpl = 294;
  cmCalcPost = 295;
  cmCalcMarket = 296;
  cmTo1c = 297;
  cmReestrDost = 298;
  cmProzNdsDay =299;
  cmNabor=300;
  cmLeftConcurs=301;

Type TKolString = Array [1..CDivision] Of String[CKol];
Type TAutoString = Array [1..CShkala] Of String[CLitr+1];
Type TAutoString1 = Array [1..6] Of String[CLitr+1];
Type TRewString = Array [1..CDivision] Of String[CKol+1];

Type Shkala = Record
     Up : String[CIZena];
     Proz : String[CLitr+1];
     MinNaz : String[CLitr+1];
     End;

Type PShkala = ^ShkalaPtr;
     ShkalaPtr = Object(TObject)
     Dat : Shkala;
     Next : PShkala;
     Constructor Init(s:Shkala);
     Destructor Done; Virtual;
     End;

Type LineKredit = Record
      Proz : Array[1..12] Of String[Clitr+1];
     End;


Type KreditType = Record
      Kredit : Array[1..7] Of LineKredit;
     End;

Type PKreditType = ^KreditTypePtr;
     KreditTypePtr = Object(TObject)
     Dat : KreditType;
     Constructor Init;
     Destructor Done; Virtual;
     End;




Type SkidkaType = Record
     BazKod : String[CArtikul];
     Date   : TDateString;
     Time   : TDateString;
     Caption: String [CRazdelKod];
     Skidka : Array [1..CShkala] of Shkala;
     End;



Type SkidkaType1 = Record
     BazKod : String[CArtikul];
     Date   : TDateString;
     Time   : TDateString;
     Caption: String [CRazdelKod];
     MinHand: String[CLitr+1];
     Skidka : Array [1..6] of Shkala;
     End;


Type PSkidkaType = ^SkidkaPtr;
     SkidkaPtr = Object(TObject)
     Dat : SkidkaType;
        Constructor Init;
     Destructor Done; Virtual;
     End;

Type PSkidkaType1 = ^SkidkaPtr1;
     SkidkaPtr1 = Object(TObject)
     Dat : SkidkaType1;
        Constructor Init;
     Destructor Done; Virtual;
     End;



Type GroupType = Record
GroupName: String[CNAme];
Kod      : String[CClientKod];
Employ   : Boolean;
Locked   : Boolean;
LockCaption: String[CRAzdelKod];
ComputerNameLocked : String[10];
End;




Type PGroupType = ^GroupPtr;
     GroupPtr =Object(TObject)
     Dat : GroupType;
     Constructor Init;
     Destructor Done; Virtual;
     End;



Type BufGroupType = Record
   Dat : Array[1..BufferGroup] Of GroupType;
End;



Type PBufGroupType = ^BufGroupPtr;
     BufGroupPtr =Object(TObject)
     Point :BufGroupType;
     Constructor Init;
     Destructor Done; Virtual;
End;



Type Osnovanie = Record
     NaklNumer : String[20];
     DateNakl  : TDateString;
     End;


{Информация по наименованию}
Type InputType = Record
     DivisionS: TKolString;
     {Group   : }
     NGroupKod: String[CClientKod];{Это поле указывает на код группы которой прин.товар}
     Osn     : Osnovanie;
     Zakupka : String[CZena];
     R_Zena  : String[CZena];
     O_Zena  : String[CZena];
     NSertif : String[CNSertif];
     DSertif : String[CDSertif];
     KSertif : String[CKSertif];
RealizovatDo : String[CDAte];
     Akzis1  : String[CAkzis1];
       Post  : String[CPost];
     Kol     : String[CKol];
     Caption : String[CRazdelKod];
        Auto : Boolean;
     End;

Type InputPrihodType = Record
     DivisionS: TKolString;
     Zakupka : String[CZena];
     R_Zena  : String[CZena];
     O_Zena  : String[CZena];
     AutoSkidka: TAutoString;
     NSertif : String[CNSertif];
     DSertif : String[CDSertif];
     KSertif : String[CKSertif];
{  Sertifikat : String[CSertif];}
RealizovatDo : String[CDAte];
     Akzis1  : String[CAkzis1];
       Post  : String[CPost];
     Kol     : String[CKol];
     Caption : String [CRazdelKod];
        Auto : Boolean;
     End;

Type InputRewisiaType = Record
     DivisionS: TRewString{Array[1..CDivision] Of String[CKol+1]};
     Zakupka : String[CZena];
     R_Zena  : String[CZena];
     O_Zena  : String[CZena];
{
     NSertif : String[CNSertif];
     DSert
	if : String[CDSertif];
     KSertif : String[CKSertif];
     Akzis1  : String[CAkzis1];
       Post  : String[CPost];
}
     Kol     : String[CKol+1];
     Caption : String [CRazdelKod];
           Auto : Boolean;
     Osn     : Osnovanie;
        End;

{Информация по наименованию}
Type InputReturnType = Record
     Zena     : String[CZena];
     R_Zena   : String[CZena];
     O_Zena   : String[CZena];
  LocalSkidka : String[CZena];
    LocalProz : String[CLitr+1];
     Kol      : String[CKol];
{    VidNDS   : word;}
     NDS      : String[CLitr];
    VidNalog  : Word;{ вид налога 0=5% 1=3% 2=прочее}
    SpecNalog : String[CLitr];
     DivisionS: String[COne];
     Zakupka  : String[CZena];
     End;


{Информация для склада}
Type BazType = Record
     Name  : String[CName];
     Name2 : String[CName];
     FullName : String[CName];
     FullName2 : String[CName];
    Minimum: String[CArtikul];
 MinNazenka: String[CLitr+1];
     Litr  : String[CLitr];
     InPack: String[CInPack];
     Marker: String[CInPack];
     Market: Word;
     VidNalog : Word; { вид налога 0=5% 1=3% 2=прочее}
     Nalog    : String[CLitr];
     VidNDS      : Word; { вид НДС 0=20% 1=10% 2=прочее}
     NDS         : String[CLitr];
     EnableOtdel : Word;
     Mera   : Word; {0 - шт 1- кг 2-л}
     BazKod: String[CArtikul];
     DostProc: String[CKOl];
     Vol: String[CVol];

     Employ: Boolean;
    Caption: String[CRazdelKod];
LockCaption: String[CRazdelKod];
     Stat  : Boolean;
     Locked: Boolean;
     ZapretOpt: Boolean;
     Realiz: boolean;
     End;


Type PBazType = ^BazTypePtr;
     BazTypePtr = Object(TObject)
     Dat : BazType;
     Constructor Init;
     Destructor Done; Virtual;
     End;


Type InputImportType = Record
 DivisionSNumber: 1..CDivision;
      NGroupKod: String[CClientKod];{Это поле указывает на код группы которой прин.товар}
 	  Zakupka : String[CZena];
	  R_Zena  : String[CZena];
	  O_Zena  : String[CZena];
	    Post  : String[CPost];
	     Kol  : String[CKol];
       NSertif : String[CNSertif];
       DSertif : String[CDSertif];
       KSertif : String[CKSertif];
          Sk   : SkidkaType;
	  End;



Type InputMarketType=Record
        Kol     : String[CKol];
        Skidka  : String[CZena];
        Zena    : String[CZena];
        R_Zena  : String[CZena];
        O_Zena  : String[CZena];
        Zakupka : String[CZena];
        Itogo   : String[CInputIZena];
        Proz    : String[CLitr+1];
       VidNDS   : Word;{ вид налога 0=20% 1=10% 2=прочее}
        NDS     : String[CLitr];
     VidNalog   : Word;{ вид налога 0=5% 1=3% 2=прочее}
      SpecNalog : String[CLitr];
  DiviSionSNumber: 1..CDivision;
       Last     : Boolean;
       Osn      : Osnovanie;
     End;

{информация по приходу наименования}
Type Element = Record
     BazKod : String[CArtikul];
     Input  : InputPrihodType;
     End;

Type RewisiaElement = Record
     BazKod : String[CArtikul];
     Input  : InputRewisiaType;
     End;

Type ReturnElement = Record
     BazKod : String[CArtikul];
     Input  : InputReturnType;
     End;


Type ProdagaElement = Record
     BazKod : String[CArtikul];
     Input  : InputMarketType;
     End;

Type ImportElement = Record
     BazKod : String[CArtikul];
     Baz    : BazType;
     Input  : InputImportType;
     End;




Type DocumentLink = Record
      DocReal : String[CDocNumer];
      DocDate : String[CDate];
      Employ   : Boolean;
     End;


Type RashetType = Record
     Rashet : Word;{0 наличный 1 комлексный}
     NalSumma : String[CiZena];
     BNSumma  : String[CiZena];
     BNDATe   : TDateString;
     BNNPlat  : String[10];
     BNBank   : AllStr;
     Comment  : String[CSertif];
     End;


Type BezNal = Record
      Date  : String[CDate];
      NPlat : String[10];
      Summa : String[CIZena];
      Bank  : AllStr;
      End;

(*
{информация о продаже}
Type SuperMarketType=Record
     OperatorSelector:Word; {клиент склад}
     DocSelector : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Realiz  : Boolean;     {признак что товар был выдан на реадизацию}
     Bn : BezNal;
     SkidkaSelector : Word; {вид скидки}
     ClientKod : String[CMakeKod]; {код клиента}
     MarketElement : Array[1..CMax] Of ProdagaElement; {информация о проданном товаре}
     Document : String[CDocNumer]; {номер документа}
     DocumentPrz : String[CDocNumer];{номер последнего акта переоценки}
     DateC   : TDateString; {дата создания}
     TimeC   : TDateString; {время создания}
     DateM   : TDateString; {дата модификации}
     TimeM   : TDateString; {время модификации}
     SummaZ  : String[CIZena];  {сумма по документу к оплате}
        SkladKod   : String[CClientKod];{признак склада}
     Caption : String [CRazdelKod];{признак оператора}
     Active  : Boolean;{признак активности накладной}
     Amount  : Word;   {число товаров в документе}
        Locked  : Boolean;{сетевая блокировка}
     Srok    : LongInt;{срок возврата долга}
     Payment : Boolean;{признак оплаты, если началась оплата то корректировать нельзя}
                       {по умолчанию False ,обращается в True, если при расплате долга SummaZ=Dolg см док-т реализации}
     DocReal : String[CDocNumer];{номер документа по которым идет проплата,используется только для}
     DocDate : TDateString;      {документов выводимых после оплаты}
     Doc     : Array [1..4] Of DocumentLink;     {используется только в первичных документах реализации
                                  для обозначения выведенных документов }
     Sf     : Boolean;
     End;
*)

Type InputTransportType=Record
        Kol     : String[CKol];
        Grammi  : String[CGram];
        Zena    : String[CZena];
        Zakupka : String[CZenaZ];
    RegionMarka : Word
      End;


Type TElement = Record
     BazKod : String[CArtikul];
     Input  : InputTransportType;
     End;


Type TransportType=Record
     MakeOtdelenie: Word; {код отделения-поставщика}
     ClientOtdelenie: Word; {код отделения-получателя}
     TransportElement   : Array[1..CMax] Of TElement; {информация о проданном товаре}
     Document : String[CDocNumer]; {номер документа}
     DateC   : TDateString; {дата создания}
     TimeC   : TDateString; {время создания}
     SummaZ  : String[CIZena];  {сумма по документу к оплате}
SummaZakupka : String[CIZena];  {сумма документа по закупочным ценнам}
  SkladKod   : String[CClientKod];{признак склада}
     Caption : String [CRazdelKod];{признак оператора}
     Active  : Boolean;{признак активности накладной}
     Amount  : Word;   {число товаров в документе}
     Comment : AllStr;{комментарий к накладной}
     End;

Type
    PTransportType = ^TransportPtr;
    TransportPtr=Object(TObject)
    Dat  :  TransportType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Type SuperMarketType=Record
     OperatorSelector:Word; {клиент склад}
     DocSelector : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     ShkalaNumer : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Realiz  : Boolean;     {признак что товар был выдан на реадизацию}

     Region  : Word;{офис город область резерв}

     Bn : BezNal;
     SkidkaSelector : Word; {вид скидки}


     ClientKod : String[CMakeKod]; {код клиента}
     AgentKod  : String[CMakeKod]; {код клиента}
     MarketElement : Array[1..CMax] Of ProdagaElement; {информация о проданном товаре}
     Document : String[CDocNumer]; {номер документа}
     DocumentPrz : String[CDocNumer];{номер последнего акта переоценки}

     PrhNumer: String[CDocNumer];{номер приходника}
     SfNumer: String[CDocNumer];{номер С/Ф}
     NaklNumer: String[CDocNumer];{номер накладной}


     DateC   : TDateString; {дата создания}
     TimeC   : TDateString; {время создания}
     DateM   : TDateString; {дата модификации}
     TimeM   : TDateString; {время модификации}
     ENalog  : String[CIZena];
     Nalog5  : String[CIZena];
     Nalog3  : String[CIZena];
     Nalog_  : String[CIZena];
     SummaZ  : String[CIZena];  {сумма по документу к оплате}
     Skidka  : String[CIZena];  {скидка по документу}
SummaZakupka : String[CIZena];  {сумма документа по закупочным ценнам}
  SkladKod   : String[CClientKod];{признак склада}
     Caption : String [CRazdelKod];{признак оператора}
     Active  : Boolean;{признак активности накладной}
     Amount  : Word;   {число товаров в документе}
     Locked  : Boolean;{сетевая блокировка}
     Srok    : LongInt;{срок возврата долга}
     DocReal : String[CDocNumer];{номер документа по которым идет проплата,используется только для}
     DocDate : TDateString;      {документов выводимых после оплаты}
     End;

Type
    PSuperMarketType = ^SuperMarketPtr;
    SuperMarketPtr=Object(TObject)
    Dat  :  SuperMarketType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Type ImportSuperMarketType=Record
     OperatorSelector : Word; {вид поставщика}
     Status    : Word;           {статус: импортирован 1 или нет 0}
     MakeKod : String[CMakeKod]; {код поставщика}

     Element   : Array[1..CMax] Of ImportElement; {информация о проданном товаре}
     Document  : String[CDocNumer]; {номер документа}
     DateC     : TDateString; {дата импорта}
     TimeC     : TDateString; {время импорта}
     SummaZ  : String[CIZena];  {сумма по документу к оплате}
SummaZakupka : String[CIZena];  {сумма документа по закупочным ценнам}

  SkladKod   : String[CClientKod];{признак склада}
     Caption : String [CRazdelKod];{признак оператора}
     Amount  : Word;   {число товаров в документе}
     End;


Type
    PImportSuperMarketType = ^ImportSuperMarketPtr;
    ImportSuperMarketPtr=Object(TObject)
    Dat  :  ImportSuperMarketType;
     Constructor Init;
     Destructor Done; Virtual;
 end;




Type StatClientType = Record
        Rashet    : Word;
        DocSelector : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
        Realiz  : Boolean;     {признак что товар был выдан на консигнацию}
        ShkalaNumer : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
        Region : Word;
        Bn : BezNal;
        SkidkaSelector : Word; {вид скидки}
        ClientKod : String[CMakeKod]; {код клиента}
        AgentKod : String[CMakeKod]; {код клиента}
        Document : String[CDocNumer]; {номер документа}
        DateC   : TDateString; {дата создания}
        TimeC   : TDateString; {время создания}
        DateM   : TDateString; {дата модификации}
        TimeM   : TDateString; {время модификации}
        ENalog  : String[CIZena];
        Nalog5  : String[CIZena];
        Nalog3  : String[CIZena];
        Nalog_  : String[CIZena];
        SummaZ  : String[CIZena];  {сумма по документу к оплате}
        Skidka  : String[CIZena];  {сумма по документу к оплате}
   SummaZakupka : String[CIZena];  {сумма документа по закупочным ценнам}
        SkladKod: String[CClientKod];{признак склада}
        Caption : String[CRazdelKod];{признак оператора}
        Active  : Boolean;
        Sf     : Boolean;
        TrueRealiz  : Boolean;  {признак что товар был выдан на реализацию}
        RazdelSum  : Array[0..MaxStatRazdel] Of Real;
        RazdelZak  : Array[0..MaxStatRazdel] Of Real;
        RazdelSkid : Array[0..MaxStatRazdel] Of Real;
     End;

Type StatTovarMarketType = Record
      {Продажа}
        BazKod  : ArtikulStr;
      Rashet    : Word;
OperatorSelector: Word;
    DocSelector : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
        Realiz  : Boolean;     {признак что товар был выдан на реадизацию}
 SkidkaSelector : Word; {вид скидки}
        Oplata  : Boolean;
      ClientKod : String[CMakeKod]; {код клиента}
      AgentKod : String[CMakeKod]; {код клиента}
        Document: String[CDocNumer]; {номер документа}
        DateC   : TDateString; {дата создания}
        TimeC   : TDateString; {время создания}
        DateM   : TDateString; {дата создания}
        TimeM   : TDateString; {дата создания}
        Kol     : String[CKol+2];
        SummaZ  : String[CIZena];  {сумма по позиции к оплате}
        ENalog  : String[CIZena];  {сумма по позиции налог с продажи}
        SNalog  : String[CLitr];
        Skidka  : String[CIZena];  {сумма по документу к оплате}
        Proz    : String[CIZena];
   SummaZakupka : String[CIZena];  {сумма документа по закупочным ценнам}
           BN   : BezNal;
        SkladKod: String[CClientKod];{признак склада}
        Caption : String[CRazdelKod];{признак оператора}
     End;

Type StatTovarPrihodType = Record
      {Приход}
        BazKod  : ArtikulStr;
OperatorSelector: Word;
        MakeKod : String[CMakeKod]; {код клиента}
        Document: String[CDocNumer]; {номер документа}
        DateC   : TDateString; {дата создания}
        TimeC   : TDateString; {время создания}
        Kol     : String[CKol];
       StatusDoc: Word;
   SummaPrihod  : String[CIZena];  {сумма прихода по позиции по Р/Ц}
   SummaZakupka : String[CIZena];  {сумма прихода по позиции по закупочным ценам}
        SkladKod: String[CClientKod];{признак склада}
        Caption : String[CRazdelKod];{признак оператора}
     End;

Type StatTovarPrzType = Record
      {Приход}
        BazKod  : ArtikulStr;
        Document: String[CDocNumer]; {номер документа}
        DateC   : TDateString; {дата создания}
        TimeC   : TDateString; {время создания}
        Kol     : String[CKol];
        Summa   : String[CIZena];
        SkladKod: String[CClientKod];{признак склада}
        Caption : String[CRazdelKod];{признак оператора}
     End;

Type StatTovarRwzType = Record
      {Приход}
        BazKod  : ArtikulStr;
        Document: String[CDocNumer]; {номер документа}
        DateC   : TDateString; {дата создания}
        TimeC   : TDateString; {время создания}
        Kol     : String[CKol+1];
        Zena    : String[CZena];
        Summa   : String[CIZena];
        SkladKod: String[CClientKod];{признак склада}
        Caption : String[CRazdelKod];{признак оператора}
     End;



{Раздел}
Type IndexType = Record
      Present    : Array [0..999] Of Boolean;
     End;


Type
    PIndexType = ^IndexTypePtr;
    IndexTypePtr=Object(TObject)
    Dat  :  IndexType;
     Constructor Init;
     Destructor Done; Virtual;
 end;




Type StatTovarReturnType = Record
     OperatorSelector: Word;
     VidDocument    : Word;
{
0 - наличная продажа скидка автоматическая
1 - наличная продажа скидка ручная
2 - закрытая консигнация авоматическая
3 - закрытая консигнация ручная
4 - открытая консигнация автоматическая
5 - открытая консигнация ручная}
 DocSelector    : Word;
     {тип документа по новой классфикации продажи}
        MakeKod : String[CMakeKod];
        BazKod  : ArtikulStr;
        Document: String[CDocNumer]; {номер документа}
        DateC   : TDateString; {дата создания}
        TimeC   : TDateString; {время создания}
        Kol     : String[CKol+2];
        Summa   : String[CIZena];
       StatusDoc: Word;

        BasisDoc: String[CDocNumer]; {номер документа-основания}
      BasisDate : TDateString; {дата создания документа - основания}

      Opt    : Boolean;
    Rashod   : Boolean;{признак печати расходника}
  RashodSumma: String[CIZena];{велечина суммы расходника}
        SkladKod: String[CClientKod];{признак склада}
        Caption : String[CRazdelKod];{признак оператора}
     End;



Type BarterClientType = Record
        OperatorSelector : Word;{0-приход 1-расход 2-расход из касса в счет погашения
	                          3-приход денег в кассу в счет погашения долга
						 5 - ПЕРЕПЛАТА}
        DocSelector : Word;   {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть
	                          деньги еще не проплачены только для расхода}
        SkidkaSelector : Word; {вид скидки только для расхода}
        ClientKod : String[CMakeKod]; {код клиента}
        Document : String[CDocNumer]; {номер документа только для прихода и расхода}
        DateC   : TDateString; {дата создания}
        TimeC   : TDateString; {время создания}
{сальдо считается по приходу:  закупка *(-1)+
                  по расходу:  к оплате +
			                выдача из кассы
						 поступления в кассу *(-1)}
        ENalog  : String[CIZena];
        Nalog5  : String[CIZena];
        Nalog3  : String[CIZena];
        Nalog_  : String[CIZena];
        {расход}
        SummaZ  : String[CIZena];  {сумма по документу к оплате}
        Skidka  : String[CIZena];  {сумма скидки по документу}
    SummaZakupka: String[CIZena];  {сумма документа по закупочным ценнам}

        {приход}
    VidPrihoda  : Word;  {0-оплаченный сразу или 1-консигнационный}
     SrokPlatega: TDAteString;{заполняется только для консигнационных документов}
        PSumma  : String[CIZena];  {сумма по продажным ценам}
   PSummaZakupka: String[CIZena];  {сумма документа прихода по закупочным ценнам}
    OstatokDolga: String[CIZena];  {остаток долга- для оплаченных 0.00, а для консигнационных приходов}
        {выдача из кассы}
        Vidano  : String[CIZena];
        Link    : Word;{0-не связанный платеж;1-связанный платеж}
        Doc     : String[CDocNumer];{номер оплачиваемого документа}
        Date    : TDateString;{дата оплачиваемого прихода}
        {поступления в кассу}
        Priniato : String[CIZena];
        Comment  : AllStr;
        Rashet  : Word;{вид расчета только для поступлений в кассу}
        Bn      : BezNal; {б/н расчет только для поступлений в кассу}
        SkladKod: String[CClientKod];{признак склада}
        Caption : String[CRazdelKod];{признак оператора}
        Active  : Boolean;
     End;

Type PBarterClientType = ^BArterClientPtr;
     BArterClientPtr =Object(TObject)
     Dat : BarterClientType;
				     Constructor Init;
     Destructor Done; Virtual;
     End;



Type OplataBarter = Record
        OperatorSelector:Word;{0-расход из касса в счет погашения долга
	                          1-приход денег в кассу в счет погашения долга}
       ClientKod: String[CMakeKod]; {код клиента}
        DateC   : TDateString; {дата создания}
        TimeC   : TDateString; {время создания}
        Order   : String[CDocNumer];
        Vid     : Word;

        {только для расхода из кассы}
        Link    : Word;{0-связанный платеж;1-не связанный платеж}
        Doc     : String[CDocNumer];{номер оплачиваемого документа}
        Date    : TDateString;{дата оплачиваемого прихода}

        SkladKod: String[CClientKod];{признак склада}
        Caption : String[CRazdelKod];{признак оператора}
        SummaZ  : String[CIZena];  {сумма по документу к оплате}
        Rashet  : Word;{вид расчета только для поступления в кассу}
        Comment : AllStr;
        Bn      : BezNal; {}
        Active  : Boolean;
     End;

Type POplataBarter = ^OplataBarterPtr;
     OplataBarterPtr=Object(TObject)
     Dat  :  OplataBarter;
     Constructor Init;
     Destructor Done; Virtual;
 end;





Type PStatTovarMarketType = ^StatTovarMArketPtr;
     StatTovarMarketPtr =Object(TObject)
     Dat : StatTovarMarketType;
     Constructor Init;
     Destructor Done; Virtual;
     End;

Type PStatTovarPrihodType = ^StatTovarPrihodPtr;
     StatTovarPrihodPtr =Object(TObject)
     Dat : StatTovarPrihodType;
     Constructor Init;
     Destructor Done; Virtual;
     End;

Type PStatTovarPrzType = ^StatTovarPrzPtr;
     StatTovarPrzPtr =Object(TObject)
     Dat : StatTovarPrzType;
     Constructor Init;
     Destructor Done; Virtual;
     End;

Type PStatTovarRwzType = ^StatTovarRwzPtr;
     StatTovarRwzPtr =Object(TObject)
     Dat : StatTovarRwzType;
     Constructor Init;
     Destructor Done; Virtual;
     End;

Type PStatTovarReturnType = ^StatTovarReturnPtr;
     StatTovarReturnPtr =Object(TObject)
     Dat : StatTovarReturnType;
     Constructor Init;
     Destructor Done; Virtual;
     End;


Type PStatClientType = ^StatClientTypePtr;
     StatClientTypePtr=Object(TObject)
     Dat : StatClientType;
     Constructor Init;
     Destructor Done; Virtual;
     End;

(* Type RealizasiaType = Record
     Market : SuperMarketType;
     Dolg   : Real;
     Full   : Boolean;
     End;*)

Type PsevdoSuperMarketType=Record
     OperatorSelector:Word; {клиент склад обмен заказ}
     DocSelector : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Rashet : Word;{добавлено для отслеживания векселей}
     Region : Word;{добавлено для отслеживания векселей}
     SkidkaSelector : Word; {вид скидки}
     ClientKod : String[CMakeKod]; {код клиента}
     AgentKod  : String[CMakeKod]; {код агента}
     Document : String[CDocNumer]; {номер документа}
     DateC   : TDateString; {дата создания}

     PrhNumer: String[CDocNumer];{номер приходника}
     SfNumer: String[CDocNumer];{номер С/Ф}
     NaklNumer: String[CDocNumer];{номер накладной}


     {TimeC  : TDateString; {время создания}

     SummaZ  : String[CIZena]{String[CIZena]};  {сумма по документу к оплате}
     Skidka  : String[CIZena]{String[CIZena]};  {скидка по документу}

{SummaZakupka : Double{String[CIZena];  {сумма документа по закупочным ценнам}
{SummaZakupka2: Double{String[CIZena];  {сумма документа по закупочным ценнам}

     SkladKod : String[CClientKod];{признак склада}
     Caption : String [CRazdelKod];{признак оператора}
     Active  : Boolean;{признак активности накладной}
     Srok    : LongInt;{срок возврата долга}
     End;



Type RealizasiaType = Record
     Market : PsevdoSuperMarketType;
     Dolg   : Real;
     Full   : Boolean;
     Payment: Boolean;{признак оплаты, если началась оплата то корректировать нельзя}
                      {по умолчанию False ,обращается в True, если при расплате долга}
                      {SummaZ=Dolg см док-т реализации}
     Doc    : Array [1..4] Of DocumentLink;     {используется только в первичных документах реализации
                                                 для обозначения выведенных документов }
     Sf     : Boolean;
     Realiz : boolean;  {признак накладной на реализацию - срок опоздания не катит}
     End;

Type BufRealizasiaType = Record
     Dat : Array [1..BufferDLG] Of RealizasiaType;
End;


Type PBufRealizasiaType = ^BufRealizasiaTypePtr;
     BufRealizasiaTypePtr =Object(TObject)
     Point :BufRealizasiaType;
     Constructor Init;
     Destructor Done; Virtual;
End;





Type BakOplataRealizasiaType = Record
     SkladKod  : String[CClientKod];
     ClientKod :String[CClientKod];
     Document  : String[CDocNumer]; {номер документа}
     DateDoc   : TDateString; {дата документа}
     DateC     : TDateString; {дата ОПЛАТЫ}
     TimeC     : TDateString; {время ОПЛАТЫ}
     SummaZ    : String[CIZena];  {сумма оплаты}
     Vozwrat   : Boolean;      {если был возврат}
     DocNumer  : String[CDocNumer];{документ возврата}
     DocDate   : STring[CDate];    {документ возврата}
     Caption   : String [CRazdelKod];{признак оператора}
     End;


Type OplataRealizasiaType = Record
        SkladKod : String[CClientKod];
        ClientKod :String[CClientKod];
     PrhNumer : String[CDocNumer]; {номер выданного приходника}
     Document : String[CDocNumer]; {номер документа}
     DateDoc : TDateString; {дата документа}
     DateC   : TDateString; {дата ОПЛАТЫ}
     TimeC   : TDateString; {время ОПЛАТЫ}
     SummaZ  : String[CIZena];  {сумма оплаты}
     Skidka  : String[CIZena];  {велечина списания скидки}
     Vozwrat : Boolean;      {если был возврат}
     DocNumerReturn: String[CDocNumer];{документ возврата}
     DocDateReturn : STring[CDate];    {документ возврата}
     Caption : String [CRazdelKod];{признак оператора}
     Rashet  : Boolean;
     Bn      : BezNal;
     Realiz: boolean;
     End;

(*
Type BakClientOplataRealizasiaType = Record
        SkladKod : String[CClientKod];
     ClientKod :String[CClientKod];
     Document : String[CDocNumer]; {номер документа}
     Srok : TDateString; {дата документа}
     DateDoc : TDateString; {дата документа}
     DateC   : TDateString; {дата ОПЛАТЫ}
     TimeC   : TDateString; {время ОПЛАТЫ}
     SummaZ  : String[CIZena];  {сумма оплаты}
     Skidka  : String[CIZena];  {велечина списания скидки}
     Caption : String[CRazdelKod];{признак оператора}
     Delta   : String[CLitrMantissa];{дней задержки}
     End;
*)

Type AkziaZena = Record
     Enable: boolean;
     OKol: String[CKol];
     OZena:String[CZena];
     RKol:String[CKol];
     RZena:String[CZena];
End;

Type PAkziaZena = ^AkziaZenaPtr;
     AkziaZenaPtr =Object(TObject)
      Dat:AkziaZena;
     Constructor Init;
     Destructor Done; Virtual;
End;


Type BakClientOplataRealizasiaType = Record
    SkladKod : String[CClientKod];
   ClientKod :String[CClientKod];
    Document : String[CDocNumer]; {номер документа}
        Srok : TDateString; {дата документа}
     DateDoc : TDateString; {дата документа}
     DateC   : TDateString; {дата ОПЛАТЫ}
     TimeC   : TDateString; {время ОПЛАТЫ}
     SummaZ  : String[CIZena];  {сумма оплаты}
     Caption : String[CRazdelKod];{признак оператора}
     Delta   : String[CLitrMantissa];{дней задержки}
     End;


Type ClientOplataRealizasiaType = Record
     SkladKod : String[CClientKod];
     ClientKod: String[CClientKod];
     Document : String[CDocNumer]; {номер документа}
     PrhNumer : String[CDocNumer]; {номер выданного приходника}
     DateDoc  : TDateString; {дата документа}
     DateC    : TDateString; {дата ОПЛАТЫ}
     TimeC    : TDateString; {время ОПЛАТЫ}
     SummaZ   : String[CIZena];  {сумма оплаты}
      Skidka  : String[CIZena];  {велечина списания скидки}
      {Добавил для документов возврата}
      Vozwrat : Boolean;      {если был возврат}
DocNumerReturn: String[CDocNumer];{документ возврата}
DocDateReturn : STring[CDate];    {документ возврата}
     Srok     : TDateString; {дата документа}
     Caption  : String[CRazdelKod];{признак оператора}
     Delta    : String[CLitrMantissa];{дней задержки}
     Rashet   : Boolean;
     Realiz   : Boolean;
     Bn       : BezNal;
     End;



Type BufClientOplataRealizasiaType = Record
     Dat : Array [1..BufferCOpl] Of ClientOplataRealizasiaType;
End;



Type PBufClientOplataRealizasiaType = ^BufClientOplataRealizasiaTypePtr;
     BufClientOplataRealizasiaTypePtr =Object(TObject)
     Point :BufClientOplataRealizasiaType;
     Constructor Init;
     Destructor Done; Virtual;
End;



Type PRealizasiaType = ^RealizasiaPtr;
     RealizasiaPtr=Object(TObject)
     Dat : RealizasiaType;
     Constructor Init;
     Destructor Done; Virtual;
     End;

Type DostavkaType = record
     DocSelector : Word;
     DocOsn: string[CDocNumer]; {N документа основания}
     DateDoc: string[CDate];  {Дата документа основания}
     DateDost: string[CDate]; {Дата доставки}
     ClientKod: String[CClientKod];
     SumOplata: String[CIZena];
     Vol: String[CKol];
     Massa: String[CKOl];
     EkspedKod: String[CClientKod];
     Maska: string[CRazdelKOd];
     Marsh: string[CRazdelKOd];
     Oformlen: boolean;
End;

Type PDostavkaType = ^DostavkaTypePtr;
     DostavkaTypePtr = Object(TObject)
     Dat:DostavkaType;
     Constructor Init;
     Destructor Done; Virtual;
     End;
{Склад}
Type SkladType = Record
     BazKod  : String[CArtikul];
     MakeKod : String[CMakeKod];
     MakeVid : Word;
     Input   : InputType;
     Employ  : Boolean;
     Date    : TDateString;
     Time    : TDateString;
     Tip     : Word;
     Analys  : Boolean;
     Locked  : Boolean;
   End;


Type
    PSkladType = ^SkladPtr;
    SkladPtr=Object(TObject)
    Dat  :  SkladType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Type BufSkladType = Record
     Dat : Array [1..BufferDB] Of SkladType;
End;


Type PBufSkladType = ^BufSkladTypePtr;
     BufSkladTypePtr =Object(TObject)
     Point :BufSkladType;
     Constructor Init;
     Destructor Done; Virtual;
End;



{Приход}
Type PrihodType = Record
     OperatorSelector:Word;
     MakeKod : String[CMakeKod];
     PrihodElement : Array[1..CMax] Of Element;
     Document : String[CDocNumer];
     DocumentPrz : String[CDocNumer]; {позиция в файле переоценки, а не номер акта переоценки
	                                  это две большие разницы}
     SummaL,SummaR,SummaO,SummaZakupka : String[CIZena];
    SkladKod : String[CClientKod];
     Caption : String[CRazdelKod];
     DateC   : TDateString;
     TimeC   : TDateString;
     DateM   : TDateString;
     TimeM   : TDateString;
     Amount  : Word;
     Osn     : Osnovanie;
   StatusDoc : Word; {1 : Буфер; 0 :Документ попал на склад}
     Locked  : Boolean;
 end;


Type
    PPrihodType = ^PrihodPtr;
    PrihodPtr=Object(TObject)
    Dat  :  PrihodType;
     Constructor Init;
     Destructor Done; Virtual;
 end;



Type BakRewisiaType = Record
        Element : Array[1..CMax] Of RewisiaElement;
        Document: String[CDocNumer];
        Itogo,ItogoPlus,ItogoMinus : String[CIZena];
        ItogoZ,ItogoPlusZ,ItogoMinusZ : String[CIZena];
        SkladKod   : String[CClientKod];
        Caption : String [CRazdelKod];
        DateC   : TDateString;
        TimeC   : TDateString;
        DateM   : TDateString;
        TimeM   : TDateString;
        Comment : SertifStr;
        Amount  : Word;
        Locked  : Boolean;
 end;


Type RewisiaType = Record
        Element : Array[1..CMax] Of RewisiaElement;
        Document: String[CDocNumer];
        Itogo,ItogoPlus,ItogoMinus : String[CIZena];
        ItogoZ,ItogoPlusZ,ItogoMinusZ : String[CIZena];
        SkladKod: String[CClientKod];
        Caption : String [CRazdelKod];
        DateC   : TDateString;
        TimeC   : TDateString;
        DateM   : TDateString;
        TimeM   : TDateString;
        Comment : SertifStr;
        Class   : Word;
        Amount  : Word;
        Locked  : Boolean;
 end;




Type
    PRewisiaType = ^RewisiaPtr;
    RewisiaPtr=Object(TObject)
    Dat  :  RewisiaType;
     Constructor Init;
     Destructor Done; Virtual;
 end;



{Возврат}
Type
     VozwratType = Record
     DocumentWith :String[CDocNumer];
     DateWith :TDateString;
     Opt    : Boolean;
     Prihod : PrihodType;
 end;


{Возврат новый}
Type
     NewVozwratType = Record
     OperatorSelector: Word;
     VidDocument    : Word;
{
0 - наличная продажа скидка автоматическая
1 - наличная продажа скидка ручная
2 - закрытая консигнация авоматическая
3 - закрытая консигнация ручная
4 - открытая консигнация автоматическая
5 - открытая консигнация ручная
}
     DocSelector    : Word;
     {тип документа по новой классфикации продажи}
     MakeKod : String[CMakeKod];
     VozwratElement : Array[1..CMax] Of ReturnElement;
     Document : String[CDocNumer];
     DocumentPrz : String[CDocNumer];
     SummaO,SummaR,SummaZakupka,Skidka : String[CIZena];
     PrevSummaZ,PrevSkidka,Delta:String[CIZena];

     ENalog  : String[CIZena];
     Nalog5  : String[CIZena];
     Nalog3  : String[CIZena];
     Nalog_  : String[CIZena];

     SkladKod: String[CClientKod];
     Caption : String[CRazdelKod];
     DateC   : TDateString;
     TimeC   : TDateString;
     DateM   : TDateString;
     TimeM   : TDateString;
     Amount  : Word;
   StatusDoc : Word; {1 : Буфер; 0 :Документ попал на склад}
     Locked  : Boolean;
    BasisDoc : String[CDocNumer];
    BasisDate: TDateString;
      Opt    : Boolean;
    Rashod   : Boolean;{признак печати расходника}
  RashodSumma: String[CIZena];{велечина суммы расходника}
{Примечание
4 вида возврата (по расходникам)
1.возврат по продаже - расходник выдается на сумму возврата-сумма скидки возврата
2.возврат по закрытой консигнаци - расходник выдается на сумму возврата-сумма скидки возврата
3.возврат по открытой консигнации, причем долг по оплате документа
  превышает сумму возврата - расходник не выдается (он получается на нулевую сумму)
  в файл оплаты консигнации и персональный файл оплаты клиента пишется
  фиктивная оплата консигнации    на сумму возврата

4.возврат по открытой консигнации, причем долг по оплате документа
  меньше суммы возврата - расходник выдается на сумму равную:

      Расходник = сумма возврата-Сумма Долга по документу в настощее время }
 end;

{Возврат новый в файле возврата клиента}

Type ClientNewVozwratType = Record
     Return : NewVozwratType;
 end;


Type
    PVozwratType = ^VozwratPtr;
    VozwratPtr=Object(TObject)
    Dat  :  VozwratType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Type
    PNewVozwratType = ^NewVozwratPtr;
    NewVozwratPtr=Object(TObject)
    Dat  :  NewVozwratType;
     Constructor Init;
     Destructor Done; Virtual;
 end;

Type
    PClientNewVozwratType = ^ClientNewVozwratPtr;
    ClientNewVozwratPtr=Object(TObject)
    Dat  :  ClientNewVozwratType;
     Constructor Init;
        Destructor Done; Virtual;
 end;


{Информация по переоценке наименования}
Type CorrectType = Record
     BazKod:String[CArtikul];
     Kol   : String[CKol];
     Bak_R_Zena,Bak_O_Zena,
     New_R_Zena,New_O_Zena:String[CZena];
     AutoSkid : TAutoString;
     End;

{Переоценка}
Type PereozenkaType = Record
     Element  : Array[1..CMax] Of CorrectType;
     Document : String[CDocNumer];
     Itogo_Bak_R_Zena,
     Itogo_Bak_O_Zena,
     Itogo_New_R_Zena,
     Itogo_New_O_Zena,
     Delta_RZ,Delta_OZ:String[CIZena];
     DateC    : TDateString;
     TimeC    : TDateString;
     DateM    : TDateString;
     TimeM    : TDateString;
     SkladKod : String[CClientKod];
     Caption  : String [CRazdelKod];
     Vid      : Word;{0-нормальная 1-возврат 2-ревизия}
     DocumentWith :String[CDocNumer];
     DateWith :TDateString;
     Amount   : Word;
 end;


Type
    PPereozenkaType = ^PereozenkaPtr;
    PereozenkaPtr=Object(TObject)
    Dat  :  PereozenkaType;
     Constructor Init;
     Destructor Done; Virtual;
 end;



{Конфигурация системы}
Type PrintINI = record
     Printer  : Word;
     Orient   : Word;
     Port     : Word;
     SwapDisk : Word;
     Computer : String[30];
     Ini      : String[30];
    CopyPrihod: LongInt;
    CopyPrz   : LongInt;
    CopyNkl   : LongInt;
    CopyOrder : LongInt;
    CopySF    : LongInt;
    CopyReturn: LongInt;
  PathToModem : String[CSertif];
  PathToPrihod : String[CSertif];
{ Корневая база таблиц }
  PathToMain   : String[CSertif];
  PathToMarket : String[CSertif];
{ Хранится архив (резервная копия всех данных) }
  PathToArc    : String[CSertif];
{ Хранятся текущие продажи и релизация }
  PathToReturn  : String[CSertif];
  PathToProgram: String[CSertif];
  PathToCorrect: String[CSertif];
  ArcCode      : String[CSertif];
  ReportCode   : String[CSertif];
  FullName     : Word;
  FullSertif   : Word;
  FullSkidka   : Word;
     end;


Type Distantion = Record
     ToProgram: String[CSertif];
     ToPrihod : String[CSertif];
     ToMarket : String[CSertif];
     ToReturn : String[CSertif];
     ToCorrect: String[CSertif];
     ToClient : String[CSertif];
     ToDolg   : String[CSertif];
ToClientReturn: String[CSertif];
ToClientOplata: String[CSertif];
      ToOplata: String[CSertif];
    ToOperator: String[CSertif];
        ToName: String[CSertif];
      ToRazdel: String[CSertif];
       ToSklad: String[CSertif];
      ToSkidki: String[CSertif];
       ToModem: String[CSertif];
    ArchivCode: String[CSertif];
      ToArchiv: String[CSertif];
      ToReport: String[CSertif];
    ToProtocol: String[CSertif];
     ToRewisia: String[CSertif];
      FileFlag: String[CSertif];
        ToTemp: String[CSertif];
      ToAnalys: String[CSertif];
      ToBarter: String[CSertif];
      ToExport: String[CSertif];
      ToImport: String[CSertif];
 ToRemoteSklad: String[CSertif];
        End;

Type NewPrintIni = Record
     Printer  : Word;
     Orient   : Word;
     Port     : Word;
     SwapDisk : Word;
     Computer : AllStr;
     Ini      : AllStr;
    CopyPrihod: LongInt;
    CopyOrder : LongInt;
    CopyPrz   : LongInt;
    CopySF    : LongInt;
    CopyNkl   : LongInt;
    CopyReturn: LongInt;
  FullSkidka   : Word;
  FullSertif   : Word;
  FullAkzis    : Word;
  FullName     : Word;
  Messag       : Word;
  TimeStart    : TDateString;
  TimeStop     : TDateString;
  TextMessag   : String[63];
        End;

{Поставщик}
Type MakeType   = Record
Name     : String[CMAke];
Dogovor  : String[CAll];
Punkt    : Array [1..4] Of String[CRazdelKod];
{1 Павильоны} {2 Палатки} {3 Магазин} {4 Кафе}
Limit    : String[CIZena];
Adress   : String[CAll];
Telefon   : String[CAll];
R_Sh    : String[CAll];
Gde      : String[CAll];
Gorod    : String[CAll];
INN      : String[CAll];
OKONH    : String[CAll];
OKPO     : String[CAll];
Enviropment: String[CAll];
Messages  : String[CSertif];
Debit    : Word;
ClientShkala : Word;
SrokLizensia : TDateString;
Test_Srok   : String[CArtikul];
Kod      : String[CClientKod];
Employ   : Boolean;
LockTime : Boolean;
Stat     : Boolean;
Locked   : Boolean;
End;


{Клиент}
Type ClientType = Record
Name     : String[CClient];
FullName : String[100];
Dogovor  : String[CAll];
Punkt    : Array [1..4] Of String[CRazdelKod];
{1 Срок оплаты} {2 Дост/Самовывоз} {3 Магазин} {4 Маршруты}
Limit    : String[CIZena];
Adress   : String[CAll];
Telefon   : String[CAll];
R_Sh    : String[CAll];
Gde      : String[CAll];
Gorod    : String[CAll];
INN      : String[CAll];
OKONH    : String[CAll];
OKPO     : String[CAll];
Enviropment : String[CAll];
Messages : String[CSertif];
Debit    : Word;
NoLimit  : Word;
ClientShkala : Word;
SrokLizensia : TDateString;
Test_Srok: String[CArtikul];
Region   : Word;  {признак нулевой СФ поставщика}
Prozent  : String[Clitr];
AgentKod : array [1..2] of ArtikulStr;
Kod      : String[CClientKod];
Employ   : Boolean;
LockTime : Boolean;
LOCKDATE : TDAteString;
LockTimeCaption : String[CRazdelKod];
Stat     : Boolean;
Locked   : Boolean;
Opt: Boolean;
End;


{Клиент}
Type LockClientType = Record
STatus   : Word;{1-блокирован/0-деблокирован}
LockTime : TDAteString;
LOCKDATE : TDAteString;
Caption : ArtikulStr;
End;




{Клиент}
Type TovarClientType = Record
BazKod   : ArtikulStr;
Nazenka  : String[CLitr+1];
SpecZena : String[CZena];
Comment1 : String[CSertif];
Comment2 : String[CSertif];
Active   : Boolean;
DateC    : TDateString;
TimeC    : TDateString;
Caption  : String[CRAzdelKod];
End;

{Клиент}
Type RazdelClientType = Record
BazKod   : String[CRAzdelKod];
Vid      : Word;{0-использовать расчет через наценку 1-использовать шкалу}
Nazenka  : String[CLitr+1];
Shkala   : String[CMantissa];
Comment1 : String[CSertif];
Comment2 : String[CSertif];
Active   : Boolean;
DateC    : TDateString;
TimeC    : TDateString;
Caption  : String[CRAzdelKod];
End;


Type BufClientType = Record
   Dat : Array[1..Buffer] Of ClientType;
End;


Type PBufClientType = ^BufClientPtr;
     BufClientPtr =Object(TObject)
     Point :BufClientType;
     Constructor Init;
     Destructor Done; Virtual;
End;

Type PClientType = ^ClientPtr;
     ClientPtr =Object(TObject)
     Dat : ClientType;
     Constructor Init;
     Destructor Done; Virtual;
     End;

Type AutoSkidkaElement = record
    dost1:  string[CKOl];
    dost7:  string[CKOl];
    dost14: string[CKOl];
    dost21: string[CKOl];
    dost28: string[CKOl];
    sam1: string[CKOl];
    sam7:    string[CKOl];
    sam14:    string[CKOl];
End;

Type AutoSkidkaType = record
     Rozn: AutoSkidkaElement;
     Opt: AutoSkidkaElement;
End;

Type  PAutoSkidkaType = ^AutoSkidkaPtr;
      AutoSkidkaPtr = Object(TObject)
      Dat: AutoSkidkaType;
      Constructor Init;
      Destructor Done; Virtual;
      end;

{kassa.db}
Type KassaOperation = Record
      NAme     : String[CClient];{название операции}
      Status   : Word;{0-расход из кассы 1-поступления в кассу}
      Employ   : Boolean;
      Kod      : String[CClientKod];{код операции}
      Locked   : Boolean;
     End;

Type InputItogKassa = record
     Summa: double;
     Comment  : String[CAll];
   End;

{за каждый день свой файл прихода расхода}
Type ItogKassa = Record
      Kod      : String[CClientKod];{код операции}
      Lizo     : String[CClientKod]; {КОД СОТРУДНИКА}
      Main     : word; {1-главная 0-подчиненая}
      Input: array[1..CMax] of InputItogKassa;
      Amount:word;
      Doc      : string[CClientKod];
      DateC    : LongInt;
      TimeC    : LongInt;
      Summa    : Double;
      Caption  : String[CRAzdelKod];
      SkladKod : String[CClientKod];
      Comment  : String[CSertif];
      {Active   : Boolean;}
     End;


Type
    PItogKAssa = ^ItogKAssaPtr;
    ItogKassaPtr=Object(TObject)
    Dat  :  ItogKassa;
     Constructor Init;
     Destructor Done; Virtual;
 end;

Type DolgKassa = Record
     Doc      : string[CClientKod];  {N док-та расхода из кассы}
     DocTek   : string[CClientKod];
     DateC    : LongInt; {дата док-та расхода из кассы}
     DateTek  : LongInt;
     Full     : boolean;  {расход погашен}
     SummaDoc : Double;   {сумма выданная по док-ту}
     Summa    : Double;   {текущий долг по документу расхода
	                       если оплата - долг = 0}
     kod      : String[CClientKod];{код операции}
     Caption  : String[CrazdelKOd];
End;

Type
    PDolgKAssa = ^DolgKAssaPtr;
    DolgKassaPtr=Object(TObject)
    Dat  :  DolgKassa;
     Constructor Init;
     Destructor Done; Virtual;
 end;



(*    Name     : String[CClient];
      Dogovor  : String[CAll];
      Punkt    : Array [1..4] Of String[CRazdelKod];
      {1 Павильоны} {2 Палатки} {3 Магазин} {4 Кафе}
      Limit    : String[CIZena];
      Dolg     : String[CIZena];
      Adress   : String[CAll];
     Telefon   : String[CAll];
       R_Sh    : String[CAll];
      Gde      : String[CAll];
         Gorod    : String[CAll];
      INN      : String[CAll];
      OKONH    : String[CAll];
         OKPO     : String[CAll];
   Enviropment : String[CAll];
      Kod      : String[CClientKod];
      Employ   : Boolean;
      Stat     : Boolean;
         Locked   : Boolean;*)

Type ClientDolgType = Record
Kod:String[cClientKod];
DolgSF:Real;
DolgSFT:Real;{}
Dolg  :Real;
DolgT :Real;{}
End;


{Раздел}
Type RazdelType = Record
      Name       : String[CRazdel];
      Designation: String[CDate];
      EnableLitr : Word;
      MinNAzenka : String[CLitr+1];
      BeginStartSeason: String[CDate];
      BeginStopSeason: String[CDate];
      EndStartSeason: String[CDate];
      EndStopSeason: String[CDate];
      Skidka     : Array [1..CShkala] of Shkala;
      Kod        : String[CRazdelKod];
      DostProz   : String[CZena]; {процент за доставку - бум использовать для вычисления РЦ}
      Employ     : Boolean;
      Locked     : Boolean;
      Group      : String[CRazdelKod];
     End;



Type DocumentEdit = Record
      Vid : Word;
      EditPosition : String[CDocNumer];
      D   : String[CDate];
      End;

Type DocumentView = Record
      Vid : Word;
      D   : String[CDate];
      End;

Type Rekwiziti = Record
      Kod      : String[CClientKod];
      Name     : String[100];
      Adress   : String[CAll];
     Telefon   : String[CAll];
       R_Sh    : String[CAll];
      Gde      : String[CAll];
      Gorod    : String[CAll];
      INN      : String[CAll];
      OKONH    : String[CAll];
      OKPO     : String[CAll];
   AdressGruza : String[CAll];
 LizensiaOPTL_V: String[CAll];
 LizensiaOPTSig: String[CAll];
 LizensiaOPTPiv: Array [1..5] Of String[10];
   Svidetelstvo: String[CAll];
         Header: String[CAll];
        Shapka1: String[16]{TMyString};
        Shapka2: String[16]{TMyString};
        Shapka3: String[16]{TMyString};
    Otdel      : Array[1..CDivision] Of String[CIZena];
   SkladsName  : String[CKto];
            ven: String[CClientKod];
     End;

Type TSystemReestr=Record
      Name : String [CKto];
  Password : String[CInputILitr];
    Employ : Boolean;
      Kod  : String [CRazdelKod];
      User: array [0..255] of boolean;
      End;



Type KassaType = Record
{1}                              Prihod : String[CIZena];
{2}                             Ostatok : String[CIZena];
{3}                                  RP : String[CIZena];
{4}                       SummaOutSklad : String[CIZena];
{43}                            Prodagi : String[CIZena];
{43}                          SkProdagi : String[CIZena];
{5}                        VidanoConsig : String[CIZena];
{6}                      SkVidanoConsig : String[CIZENA];
{7}                       OplataINKassa : String[CIZENA];
{8}                      SkOformConsign : String[CIZENA];
{9}                 ReturnOutOpenConsig : String[CIZENA];
{10}              SkReturnOutOpenConsig : String[CIZENA];
{11}   ReturnOutMArketDocAndCloseConsig : String[CIZENA];
{12} SkReturnOutMArketDocAndCloseConsig : String[CIZENA];
{13}                      OstatokConsig : String[CIZENA];
{14}                    SkOstatokConsig : String[CIZENA];
{15}                         Pereozenka : String[CIZENA];
{16}               PereozenkaFromReturn : String[CIZENA];
{17}                       SummaInKassa : String[CIZENA];
{18}                     OstatokInKassa : String[CIZENA];
{19}                      ExtendedDohod : String[CIZENA];
{20}                   RashodFromReturn : String[CIZENA];
{21}         RashodFromReturnOpenConsig : String[CIZENA];
{21}                             Rashod : String[CIZENA];
{23}                         Sertifikat : String[CIZENA];
{24}                              Sdano : String[CIZENA];
{25}                           VidanoSF : String[CIZENA];
{26}                            Rewisia : String[CIZENA];
{27}                            SNalogP : String[CIZENA];
{28}                            SNalogC : String[CIZENA];
{29}             SNalogReturnOpenConsig : String[CIZENA];
{30,31,32,33,34,35,36}

                      OstatokBarter : String[CIZENA];{34}
                       BarterPrihod : String[CIZENA];{35}
                     BarterPrihodRZ : String[CIZENA];{36}
                            BarterT : String[CIZENA];{37}
                       BarterSkidki : String[CIZENA];{38}
                      BarterInKassa : String[CIZENA];{39}
                     BarterOutKassa : String[CIZENA];{40}


   PerewoskiOut : Array[0..4] Of String[CIZena];{входящие перевозки}
{37,38,39,40,41,42}
   PerewoskiInp : Array[0..4] Of String[CIZena];{исходящие перевозки}
{Эти поля не фигурируют на экране}

   EPerewoskiOut : String[CIZENA];
   EPerewoskiInp : String[CIZENA];


   CAption       : String[CRazdelKod];
   DAteC,TimeC,DateM,TimeM:TDateString;
   End;

(*
Type KassaType = Record
{1}                              Prihod : String[CIZena];
{2}                             Ostatok : String[CIZena];
{3}                                  RP : String[CIZena];
{4}                       SummaOutSklad : String[CIZena];
{43}                            Prodagi : String[CIZena];
{43}                          SkProdagi : String[CIZena];
{5}                        VidanoConsig : String[CIZena];
{6}                      SkVidanoConsig : String[CIZENA];
{7}                       OplataINKassa : String[CIZENA];
{8}                      SkOformConsign : String[CIZENA];
{9}                 ReturnOutOpenConsig : String[CIZENA];
{10}              SkReturnOutOpenConsig : String[CIZENA];
{11}   ReturnOutMArketDocAndCloseConsig : String[CIZENA];
{12} SkReturnOutMArketDocAndCloseConsig : String[CIZENA];
{13}                      OstatokConsig : String[CIZENA];
{14}                    SkOstatokConsig : String[CIZENA];
{15}                         Pereozenka : String[CIZENA];
{16}               PereozenkaFromReturn : String[CIZENA];
{17}                       SummaInKassa : String[CIZENA];
{18}                     OstatokInKassa : String[CIZENA];
{19}                      ExtendedDohod : String[CIZENA];
{20}                   RashodFromReturn : String[CIZENA];
{21}         RashodFromReturnOpenConsig : String[CIZENA];
{21}                             Rashod : String[CIZENA];
{23}                         Sertifikat : String[CIZENA];
{24}                              Sdano : String[CIZENA];
{25}                           VidanoSF : String[CIZENA];
{26}                            Rewisia : String[CIZENA];
{27}                            SNalogP : String[CIZENA];
{28}                            SNalogC : String[CIZENA];
{29}             SNalogReturnOpenConsig : String[CIZENA];
{30,31,32,33,34,35,36}

   PerewoskiOut : Array[0..6] Of String[CIZena];{входящие перевозки}
{37,38,39,40,41,42}
   PerewoskiInp : Array[0..6] Of String[CIZena];{исходящие перевозки}
{Эти поля не фигурируют на экране}

   EPerewoskiOut : String[CIZENA];
   EPerewoskiInp : String[CIZENA];


   CAption       : String[CRazdelKod];
   DAteC,TimeC,DateM,TimeM:TDateString;
   End;
*)

Type HiddenKassaType = Record
{1}                              PrihodZ : String[CIZena];
{2}                             OstatokZ : String[CIZena];
{26}                            RewisiaZ : String[CIZENA];
                                 ReturnZ : String[CIZENA];
                               MinusDohod: String[CIZENA];
                                 AllDohod: String[CIZENA];
                                AllDohodA: String[CIZENA];
                                  AllDolg: String[CIZENA];
                                 AllDolgA: String[CIZENA];
                          DolgiIstekshie : String[CIZENA];
                                DolgiVse : String[CIZENA];
                        PlategiIstekshie : String[CIZENA];
                              PlategiVse : String[CIZENA];

   End;


Type
    PHiddenKassaType = ^HiddenKassaPtr;
    HiddenKassaPtr=Object(TObject)
    Dat  :  HiddenKassaType;
     Constructor Init;
     Procedure FormatReal;
     Destructor Done; Virtual;
 end;



Type
    PKassaType = ^KassaPtr;
    KassaPtr=Object(TObject)
    Dat  :  KassaType;
     Constructor Init;
     Procedure FormatReal;
     Destructor Done; Virtual;
 end;


(*
Type ItogType = Record
     BazKod : String[CArtikul];
     Ost    : String[CKol];
     MrkC   : String[CKol];
     MrkS   : String[CKol];
     OstE   : String[CIZena];
     MrkEC  : String[CIZena];
     MrkES  : String[CIZena];
     End;

Type PItogType = ^ItogTypePtr;
     ItogTypePtr = Object(TObject)
     Dat : ItogType;
     Constructor Init;
     Procedure Refresh;
     Destructor Done; Virtual;
     End;
*)

Type NewItogType = Record
     BazKod : String[CArtikul];(**)
     Osn    : Osnovanie;
     Ost    : String[CKol];    (**)
     OstE   : String[CIZena];  (**)
     PrhC   : String[CKol];
     PrhS   : String[CKol];
     PrhB   : String[CKol];
     PrhEC   : String[CIZena];
     PrhES   : String[CIZena];
     PrhEB   : String[CIZena];
     MrkC   : String[CKol];
     MrkS   : String[CKol];
     MrkB   : String[CKol];
     MrkEC  : String[CIZena];
     MrkES  : String[CIZena];
     MrkEB  : String[CIZena];
     End;


Type PNewItogType = ^NewItogTypePtr;
     NewItogTypePtr = Object(TObject)
     Dat : NewItogType;
     Constructor Init;
     Procedure Refresh;
     Destructor Done; Virtual;
     End;

Type BufNewItogType = Record
     Dat : Array [1..BufItg] Of NewItogType;
End;


Type PBufNewItogType = ^BufNewItogTypePtr;
     BufNewItogTypePtr =Object(TObject)
     Point :BufNewItogType;
     Constructor Init;
     Destructor Done; Virtual;
End;




{1} Type ItogKAssaFileType        = File Of ItogKassa;

{1} Type OperationFileType        = File Of KassaOperation;

{1} Type ClientFileType           = File Of ClientType;
{2} Type MakeFileType             = File Of MakeType;
{3} Type SkladFileType            = File Of SkladType;
{4} Type BazFileType              = File Of BazType;
{5} Type PrihodFileType           = File Of PrihodType;
{6} Type MarketFileType           = File Of SuperMarketType;
{7} Type NewVozwratFileType       = File Of NewVozwratType;
{8} Type PereozenkaFileType       = File Of PereozenkaType;
{9} Type RewisiaFileType          = File Of RewisiaType;
{10}Type SkidkaFileType           = File Of SkidkaType;
{12}Type IndexFileType=File Of IndexType;
{11}Type OplataRealizasiaFileType = File Of OplataRealizasiaType;
{12}Type NewItogFileType=File Of NewItogType;
    Type BarterClientFileType     = File Of BarterClientType;
{13}Type OplataBarterFileType     = File Of OplataBarter;
    Type GroupFileType            = File Of GroupType;

{6} Type TransportFileType        = File Of TransportType;



Var
     FileName: string[150];
     FDate,TekDate :  TDateString;
     {Print : PrintIni;}
     Path  : Distantion;
     ClassNAme : Array[1..15] Of String[20];
     NPrint :NewPrintIni;
     Rek,RekSF : Rekwiziti;
     PrihodMax,Lizensia : Real;
     ShowSertif,ShowNumer,ShowClients,DefaultLizensia,DefaultDoc, DefaultReal : Word;
     CurrentPassword : String[CKto];
     ClientRP:String[CCLientKod];
     Status,EditMode : Word;
     {PathToTemp : String[CSertif];}
     EditPosition : LongInt;
     Assistent : DocumentEdit;
     AssistentView : DocumentView;
     Wzlom : Boolean;
     DateMask : TDateString;
     TimeMask : TDateString;
     ProdagaWindow,Show,ShowMsg,ShowNetMsg: Boolean;
     GlobalSkladsName: string[150];
     MYS : TAutoString1;


Implementation

{$IfNDEF DPMI}
Uses Overlay;
{$EndIF}

Constructor DostavkaTypePtr.Init;
Begin
inherited Init;
with Dat do
 begin
   DocOsn:='';
   DateDoc:='';
   DateDost:='';
   ClientKod:='';
   SumOplata:='';
   Vol:='';
   Massa:='';
   EkspedKod:='';
   Maska:='';
   Oformlen:=false;
 end;
End;

Destructor DostavkaTypePtr.Done;
Begin
  TObject.Done;
End;

Constructor AkziaZenaPtr.Init;
Begin
  inherited Init;
 with Dat do
 begin
  Enable:= false;
  OKol:='';
  OZena:='';
  RKol:='';
  RZena:='';
 end;
End;

Destructor AkziaZenaPtr.Done;
Begin
 TObject.Done;
End;

Constructor AutoSkidkaPtr.Init;
Begin
TObject.Init;
With Dat Do
 Begin
  Opt.dost1[0]:=#0;
  Opt.dost7[0]:=#0;
  Opt.dost14[0]:=#0;
  Opt.dost21[0]:=#0;
  Opt.dost28[0]:=#0;
  Opt.sam1[0]:=#0;
  Opt.sam7[0]:=#0;
  Rozn.dost1[0]:=#0;
  Rozn.dost7[0]:=#0;
  Rozn.dost14[0]:=#0;
  Rozn.dost21[0]:=#0;
  Rozn.dost28[0]:=#0;
  Rozn.sam1[0]:=#0;
  Rozn.sam7[0]:=#0;
  Rozn.sam14[0]:=#0;
 end;
End;

Destructor AutoSkidkaPtr.Done;
Begin
 TObject.Done;
End;

Constructor NewItogTypePtr.Init ;
Begin
TObject.Init;
With Dat Do
 Begin
     BazKod[0]:=#0;
     Osn.NaklNumer[0]:=#0;
     Osn.DateNakl[0]:=#0;
     Ost[0]:=#0;
     PrhC[0]:=#0;
     PrhS[0]:=#0;
     PrhB[0]:=#0;
     PrhEC[0]:=#0;
     PrhES[0]:=#0;
     PrhEB[0]:=#0;
     MrkC[0]:=#0;
     MrkS[0]:=#0;
     MrkB[0]:=#0;
     OstE[0]:=#0;
     MrkEC[0]:=#0;
     MrkEB[0]:=#0;
 End;
End;

Procedure NewItogTypePtr.Refresh ;
Begin
With Dat Do
 Begin
     BazKod[0]:=#0;
     Ost[0]:=#0;
     PrhC[0]:=#0;
     PrhS[0]:=#0;
     PrhB[0]:=#0;
     PrhEC[0]:=#0;
     PrhES[0]:=#0;
     PrhEB[0]:=#0;
     MrkC[0]:=#0;
     MrkS[0]:=#0;
     MrkB[0]:=#0;
     OstE[0]:=#0;
     MrkEC[0]:=#0;
     MrkEB[0]:=#0;
 End;
End;

Destructor NewItogTypePtr.Done;
Begin
TObject.Done;
End;







Constructor KassaPtr.Init ;
Var i : Byte;
Begin
TObject.Init;
With DAt Do
Begin
{1}                              Prihod[0] :=#0;
{2}                             Ostatok[0] :=#0;
{3}                                  RP[0] :=#0;
{4}                       SummaOutSklad[0] :=#0;
{43}                            Prodagi[0] :=#0;
{44}                          SkProdagi[0] :=#0;
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
{23}                         Sertifikat[0] :=#0;
{24}                              Sdano[0] :=#0;
{25}                           VidanoSF[0] :=#0;
{26}                            Rewisia[0] :=#0;
{27}                            SNalogP[0] :=#0;
{28}                            SNalogC[0] :=#0;
{29}             SNalogReturnOpenConsig[0] :=#0;



                      OstatokBarter[0] :=#0;{34}
                       BarterPrihod[0] :=#0;{34}
                     BarterPrihodRZ[0] :=#0;{34}
                            BarterT[0] :=#0;{34}
                       BarterSkidki[0] :=#0;{34}
                      BarterInKassa[0] :=#0;{34}
                     BarterOutKassa[0] :=#0;{34}

{44}   EPerewoskiOut[0] :=#0;
{45}   EPerewoskiInp[0] :=#0;

For i:=0 To 4 Do
Begin
{29,30,31,32,33,34,35}
 PerewoskiInp[i,0]:=#0;
{36,37,38,39,40,41,42}
 PerewoskiOut[i,0]:=#0;
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
{1}Str(StrToReal(Prihod):CIZena:CMantissa,Prihod);
{2}Str(StrToReal(Ostatok):CIZena:CMantissa,Ostatok);
{3}Str(StrToReal(RP):CIZena:CMantissa,RP);
{4}Str(StrToReal(SummaOutSklad):CIZena:CMantissa,SummaOutSklad);
{43}Str(StrToReal(Prodagi):CIZena:CMantissa,Prodagi);
{44}Str(StrToReal(SkProdagi):CIZena:CMantissa,SkProdagi);
{5}Str(StrToReal(VidanoConsig):CIZena:CMantissa,VidanoConsig);
{6}Str(StrToReal(SkVidanoConsig):CIZena:CMantissa,SkVidanoConsig);
{7}Str(StrToReal(OplataInKAssa):CIZena:CMantissa,OplataInKAssa);
{8}Str(StrToReal(SkOformConsign):CIZena:CMantissa,SkOformConsign);

{9}Str(StrToReal(ReturnOutOpenConsig):CIZena:CMantissa,ReturnOutOpenConsig);
{10}Str(StrToReal(SkReturnOutOpenConsig):CIZena:CMantissa,SkReturnOutOpenConsig);


{11}Str(StrToReal(ReturnOutMArketDocAndCloseConsig):CIZena:CMantissa,ReturnOutMArketDocAndCloseConsig);
{12}Str(StrToReal(SkReturnOutMArketDocAndCloseConsig):CIZena:CMantissa,SkReturnOutMArketDocAndCloseConsig);
{13}Str(StrToReal(OstatokConsig):CIZena:CMantissa,OstatokConsig);
{14}Str(StrToReal(SkOstatokConsig):CIZena:CMantissa,SkOstatokConsig);
{15}Str(StrToReal(Pereozenka):CIZena:CMAntissa,Pereozenka);
{16}Str(StrToReal(PereozenkaFromReturn):CIZena:CMAntissa,PereozenkaFromReturn);
{17}Str(StrToReal(SummaInKassa):CIZena:CMantissa,SummaInKassa);
{18}Str(StrToReal(OstatokInKAssa):CIZena:CMantissa,OstatokInKassa);
{19}Str(StrToReal(ExtendedDohod):CIZena:CMAntissa,ExtendedDohod);
{20}Str(StrToReal(RashodFromReturn):CIZena:CMAntissa,RashodFromReturn);
{20}Str(StrToReal(RashodFromReturnOpenConsig):CIZena:CMAntissa,RashodFromReturnOpenConsig);
{21}Str(StrToReal(Rashod):CIZena:CMAntissa,Rashod);
{23}Str(StrToReal(Sertifikat):CIZena:CMAntissa,Sertifikat);
{24}Str(StrToReal(Sdano):CIZena:CMAntissa,Sdano);
{25}Str(StrToReal(VidanoSF):CIZena:CMAntissa,VidanoSF);
{26}Str(StrToReal(Rewisia):CIZena:CMantissa,Rewisia);
{27}Str(StrToReal(SNAlogP):CIZena:CMantissa,SNalogP);
{28}Str(StrToReal(SNAlogC):CIZena:CMantissa,SNalogC);
{29}Str(StrToReal(SNAlogReturnOpenConsig):CIZena:CMantissa,SNalogReturnOpenConsig);

   Str(StrToReal(OstatokBarter):CIZena:CMantissa,OstatokBarter);
   Str(StrToReal(BarterPrihod):CIZena:CMantissa,BarterPrihod);
   Str(StrToReal(BarterPrihodRZ):CIZena:CMantissa,BarterPrihodRZ);
   Str(StrToReal(BarterT):CIZena:CMantissa,BarterT);
   Str(StrToReal(BarterSkidki):CIZena:CMantissa,BarterSkidki);
   Str(StrToReal(BarterInKassa):CIZena:CMantissa,BarterInKassa);
   Str(StrToReal(BarterOutKassa):CIZena:CMantissa,BarterOutKassa);


For i:=0 To 4 Do
Begin
{29,30,31,32,33,34,35}
 Str(StrToReal(PerewoskiInp[i]):CIZena:CMAntissa,PerewoskiInp[i]);
{36,37,38,39,40,41,42}
 Str(StrToReal(PerewoskiOut[i]):CIZena:CMAntissa,PerewoskiOut[i]);
End;{For}

{43}Str(StrToReal(EPerewoskiOut):CIZena:CMAntissa,EPerewoskiOut);
{44}Str(StrToReal(EPerewoskiInp):CIZena:CMAntissa,EPerewoskiInp);

End;{With}
End;

Destructor KassaPtr.Done;
Begin
TObject.Done;
End;



Constructor HiddenKassaPtr.Init ;
Var i : Byte;
Begin
TObject.Init;
With DAt Do
Begin
{1}                              PrihodZ[0] :=#0;
{2}                             OstatokZ[0] :=#0;
{26}                            RewisiaZ[0] :=#0;
                                 ReturnZ[0] :=#0;
                               MinusDohod[0] :=#0;
                                 AllDohod[0] :=#0;
                                AllDohodA[0] :=#0;
                                  AllDolg[0] :=#0;
                                 AllDolgA[0] :=#0;

End;{With}
End;

Procedure HiddenKassaPtr.FormatReal;
Var i : Byte;
Begin
With DAt Do
Begin
{1}Str(StrToReal(PrihodZ):CIZena:CMantissa,PrihodZ);
{2}Str(StrToReal(OstatokZ):CIZena:CMantissa,OstatokZ);
   Str(StrToReal(RewisiaZ):CIZena:CMantissa,RewisiaZ);
   Str(StrToReal(ReturnZ) :CIZena:CMantissa,ReturnZ);
   Str(StrToReal(MinusDohod):CIZena:CMantissa,MinusDohod);
   Str(StrToReal(AllDohod) :CIZena:CMantissa,AllDohod);
   Str(StrToReal(AllDohodA):CIZena:CMantissa,AllDohodA);
   Str(StrToReal(AllDolg)  :CIZena:CMantissa,AllDolg);
   Str(StrToReal(AllDolgA) :CIZena:CMantissa,AllDolgA);
   Str(StrToReal(DolgiIstekshie) :CIZena:CMantissa,DolgiIstekshie);
   Str(StrToReal(DolgiVse) :CIZena:CMantissa,DolgiVse);
   Str(StrToReal(PlategiIstekshie) :CIZena:CMantissa,PlategiIstekshie);
   Str(StrToReal(PlategiVse) :CIZena:CMantissa,PlategiVse);

End;{With}
End;

Destructor HiddenKassaPtr.Done;
Begin
TObject.Done;
End;




Constructor PrihodPtr.Init ;
Var i,j : Byte;
Begin
TObject.Init;
 Dat.Locked:=False;
 For i:=1 To CMax Do
  Begin
   {обнуляется приход}
  With Dat.PrihodElement[i].Input Do
   Begin
   Zakupka[0]:=#0;
       Kol[0]:=#0;
    R_Zena[0]:=#0;
    O_Zena[0]:=#0;
 NSertif[0]:=#0;
DSertif[0]:=#0;
 KSertif[0]:=#0;
{Sertifikat[0]:=#0;}
     Akzis1[0]:=#0;
     RealizovatDo[0]:=#0;
     Post [0]:=#0;
   For j:=1 To CDivision Do DivisionS[j,0]:=#0;
   For j:=1 To CShkala Do AutoSkidka[j,0]:=#0;
   Auto:=False;
   End;
   With Dat.PrihodElement[i] Do
   Begin
    BazKod[0]:=#0;
     Dat.OperatorSelector:=0;
     Dat.MakeKod[0]:=#0;
     Dat.Document[0]:=#0;
     Dat.Osn.NaklNumer[0]:=#0;
     Dat.Osn.DateNakl[0]:=#0;
     Dat.DocumentPrz[0]:=#0;
     Dat.SummaL[0]:=#0;
     Dat.DateC[0]:=#0;
     Dat.TimeC[0]:=#0;
     Dat.DateM:=FDate;
     Dat.TimeM:=CurrentTimeString('hh:mm:ss');
     Dat.SummaR[0]:=#0;
     Dat.SummaO[0]:=#0;
     Dat.SummaZakupka[0]:=#0;
     DAt.Caption:=CurrentPassword;
        DAt.SkladKod:=FormKod(Rek.Kod);
        Dat.Amount:=0;
   End;
  End;
End;

Destructor PrihodPtr.Done;
Begin
TObject.Done;
End;

Constructor RewisiaPtr.Init ;
Var i,j : Byte;
Begin
TObject.Init;
 Dat.Locked:=False;
 For i:=1 To CMax Do
  Begin
   {обнуляется приход}
  With Dat.Element[i].Input Do
   Begin
       Kol[0]:=#0;
    Zakupka[0]:=#0;
    R_Zena[0]:=#0;
    O_Zena[0]:=#0;
    Osn.NaklNumer[0]:=#0;
    Osn.DateNakl[0]:=#0;
     {
     NSertif[0] :=#0;
     DSertif[0] :=#0;
     KSertif[0] :=#0;
     Akzis1 [0] :=#0;
       Post [0] :=#0;
     }
   For j:=1 To CDivision Do DivisionS[j,0]:=#0;
   Auto:=False;
   End;
   With Dat.Element[i] Do
   Begin
        BazKod[0]:=#0;
        Dat.Document[0]:=#0;
        Dat.Itogo[0]:=#0;
        Dat.ItogoPlus[0]:=#0;
        Dat.ItogoMinus[0]:=#0;
        Dat.ItogoZ[0]:=#0;
        Dat.ItogoPlusZ[0]:=#0;
        Dat.ItogoMinusZ[0]:=#0;


        Dat.DateC[0]:=#0;
        Dat.TimeC[0]:=#0;
        Dat.DateM:=FDate;
        Dat.TimeM:=CurrentTimeString('hh:mm:ss');
        DAt.Caption:=CurrentPassword;
        DAt.SkladKod:=FormKod(Rek.Kod);
        DAt.Comment[0]:=#0;
        Dat.Amount:=0;
        Dat.Class:=0;
        Dat.Locked:=False;
   End;
  End;
End;

Destructor RewisiaPtr.Done;
Begin
TObject.Done;
End;

Constructor VozwratPtr.Init ;
Var i,j : Byte;
Begin
TObject.Init;
 Dat.DocumentWith[0]:=#0;
 Dat.DateWith[0]:=#0;
 Dat.Opt:=False;
 Dat.Prihod.Locked:=False;
 For i:=1 To CMax Do
  Begin
   {обнуляется приход}
  With Dat.Prihod.PrihodElement[i].Input Do
   Begin
   Zakupka[0]:=#0;
       Kol[0]:=#0;
    R_Zena[0]:=#0;
    O_Zena[0]:=#0;
 NSertif[0]:=#0;
DSertif[0]:=#0;
 KSertif[0]:=#0;

{Sertifikat[0]:=#0;}
     Akzis1[0]:=#0;
   For j:=1 To CDivision Do DivisionS[j,0]:=#0;
   Auto:=False;
   End;
   With Dat.Prihod.PrihodElement[i] Do
   Begin
     BazKod[0]:=#0;
     Dat.Prihod.OperatorSelector:=0;
     Dat.Prihod.MakeKod[0]:=#0;
     Dat.Prihod.Document[0]:=#0;
     Dat.Prihod.DocumentPrz[0]:=#0;
     Dat.Prihod.SummaL[0]:=#0;
     Dat.Prihod.DateC[0]:=#0;
     Dat.Prihod.TimeC[0]:=#0;
     Dat.Prihod.DateM:=FDate;
     Dat.Prihod.TimeM:=CurrentTimeString('hh:mm:ss');
     Dat.Prihod.SummaR[0]:=#0;
     Dat.Prihod.SummaO[0]:=#0;
     DAt.Prihod.Caption:=CurrentPassword;
        DAt.Prihod.SkladKod:=FormKod(Rek.Kod);
     Dat.Prihod.Amount:=0;
   End;
  End;
End;

Destructor VozwratPtr.Done;
Begin
TObject.Done;
End;

Constructor NewVozwratPtr.Init ;
Var i,j : Byte;
Begin
TObject.Init;
With Dat Do
Begin
 BasisDoc[0]:=#0;
 BasisDate[0]:=#0;
 Opt:=False;
 Locked:=False;
 OperatorSelector:=0;
 DocSelector:=9;
 VidDocument    :=0;
 MakeKod[0]:=#0;
 Document[0]:=#0;
 DocumentPrz[0]:=#0;
 Skidka[0]:=#0;
 SummaR[0]:=#0;
 SummaO[0]:=#0;
 SummaZakupka[0]:=#0;


 ENalog[0]:=#0;
 Nalog5[0]:=#0;
 Nalog3[0]:=#0;
 Nalog_[0]:=#0;

 PrevSummaZ[0]:=#0;
 PrevSkidka[0]:=#0;
 Delta[0]:=#0;
 DateC[0]:=#0;
 TimeC[0]:=#0;
 DateM:=FDate;
 TimeM:=CurrentTimeString('hh:mm:ss');
 Caption:=CurrentPassword;
 SkladKod:=FormKod(Rek.Kod);
 Amount:=0;
 StatusDoc :=0;

 Rashod:=False;
 RashodSumma[0]:=#0;

End;
 For i:=1 To CMax Do
  Begin
  With Dat.VozwratElement[i] Do
   Begin
       Bazkod[0]:=#0;
       Input.Kol[0]:=#0;
       input.R_Zena[0]:=#0;
       input.Zena[0]:=#0;
       input.Zakupka[0]:=#0;
       input.O_Zena[0]:=#0;
       Input.LocalSkidka[0]:=#0;

       input.NDS[0]:=#0;

       input.VidNalog:=2;

       input.SpecNAlog[0]:=#0;

       Input.DivisionS[0]:=#0;
   End;
  End;
End;

Destructor NewVozwratPtr.Done;
Begin
TObject.Done;
End;

Constructor ClientNewVozwratPtr.Init ;
Var i,j : Byte;
Begin
TObject.Init;
With Dat.Return Do
Begin
 BasisDoc[0]:=#0;
 BasisDate[0]:=#0;
 Opt:=False;
 Locked:=False;
 OperatorSelector:=0;
 DocSelector:=9;
 VidDocument    :=0;
 MakeKod[0]:=#0;
 Document[0]:=#0;
 DocumentPrz[0]:=#0;
 Skidka[0]:=#0;
 SummaR[0]:=#0;
 SummaO[0]:=#0;

 ENalog[0]:=#0;
 Nalog5[0]:=#0;
 Nalog3[0]:=#0;
 Nalog_[0]:=#0;

 PrevSummaZ[0]:=#0;
 PrevSkidka[0]:=#0;
 DateC[0]:=#0;
 TimeC[0]:=#0;
 DateM:=FDate;
 TimeM:=CurrentTimeString('hh:mm:ss');
 Caption:=CurrentPassword;
 SkladKod:=FormKod(Rek.Kod);
 Amount:=0;
 StatusDoc :=0;

 Rashod:=False;
 RashodSumma[0]:=#0;

End;
 For i:=1 To CMax Do
  Begin
  With Dat.Return.VozwratElement[i] Do
   Begin
       Bazkod[0]:=#0;
       Input.Kol[0]:=#0;
       input.R_Zena[0]:=#0;
       input.Zena[0]:=#0;
       input.O_Zena[0]:=#0;
       Input.LocalSkidka[0]:=#0;

       input.NDS[0]:=#0;

       input.VidNalog:=2;
       input.SpecNAlog[0]:=#0;

       Input.DivisionS[0]:=#0;
   End;
  End;
End;

Destructor ClientNewVozwratPtr.Done;
Begin
TObject.Done;
End;

Constructor PereozenkaPtr.Init ;
Var i,j : Byte;
Begin
TObject.Init;
 For i:=1 To CMax Do
  Begin
    With Dat.Element[i] Do
   Begin
   BazKod[0]:=#0;
   Kol[0]:=#0;
   Bak_R_Zena[0]:=#0;
   Bak_O_Zena[0]:=#0;
   New_R_Zena[0]:=#0;
   New_O_Zena[0]:=#0;
   For j:=1 To CShkala Do AutoSkid[j,0]:=#0;
   End;
  End;
   With Dat Do
    Begin
     Document[0]:=#0;
     Itogo_Bak_R_Zena[0]:=#0;
     Itogo_Bak_O_Zena[0]:=#0;
     Itogo_New_R_Zena[0]:=#0;
     Itogo_New_O_Zena[0]:=#0;
     Delta_OZ[0]:=#0;
     Delta_RZ[0]:=#0;
     Caption:=CurrentPassword;
     Dat.DateC[0]:=#0;
     Dat.TimeC[0]:=#0;
     Dat.DateM:=FDate;
     Dat.TimeM:=CurrentTimeString('hh:mm:ss');
     Vid :=0;
     DocumentWith[0]:=#0;
     DateWith[0]:=#0;
     Amount:=0;
     SkladKod:=FormKod(Rek.Kod);
    End;
End;

Destructor PereozenkaPtr.Done;
Begin
TObject.Done;
End;

Constructor SuperMarketPtr.Init ;
Var i : Byte;
Begin
TObject.Init;
 For i:=1 To CMax Do
  Begin
    Dat.MarketElement[i].BazKod[0]:=#0;
    With Dat.MarketElement[i].Input Do
   Begin
     Kol    [0] :=#0;
     Zena   [0] :=#0;
     R_Zena [0] :=#0;
     O_Zena [0] :=#0;
     Skidka [0] :=#0;
     Zakupka[0] :=#0;
     Itogo[0] :=#0;
     Proz[0] :=#0;
     VidNDS:=2;
     NDS[0] :=#0;
     SpecNalog[0] :=#0;
     VidNalog:=2;
     DivisionSNumber:=1;
     Last :=False;
     Osn.NaklNumer[0]:=#0;
     Osn.DateNakl[0]:=#0;
   End;
  End;
   With Dat Do
    Begin
     Realiz:=False;
     DocumentPRZ[0]:=#0;
     Document[0]:=#0;

     PrhNumer[0]:=#0;
     SfNumer[0]:=#0;
     NaklNumer[0]:=#0;

     ENalog  [0]:=#0;
     Nalog5  [0]:=#0;
     Nalog3  [0]:=#0;
     Nalog_  [0]:=#0;

     SummaZ[0]:=#0;
     SummaZakupka[0]:=#0;

     Skidka[0]:=#0;
     Bn.DAte[0]:=#0;
     Bn.NPlat[0]:=#0;
     Bn.Bank[0]:=#0;
     Bn.Summa[0]:=#0;
     Caption:=CurrentPassword;
     Active:=True;
     Realiz := False;
      Locked:=False;
     Srok:=0;
     Amount:=0;
     DateC[0]:=#0;
     TimeC[0]:=#0;
     DateM:=FDate;
     TimeM:=CurrentTimeString('hh:mm:ss');
     SkladKod:=FormKod(Rek.Kod);
     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
     ShkalaNumer :=0;
     DocReal[0]:=#0;
     DocDate[0]:=#0;
    End;
End;

Destructor SuperMarketPtr.Done;
Begin
TObject.Done;
End;

Constructor StatTovarMarketPtr.Init ;
Begin
TObject.Init;
With DAt Do
 Begin
        BazKod [0]:=#0;
        Rashet    :=0;
        OperatorSelector:=0;
        DocSelector :=0;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
        Realiz  :=False;     {признак что товар был выдан на реадизацию}
        SkidkaSelector :=0; {вид скидки}
        Oplata  :=False;
        ClientKod[0] :=#0; {код клиента}
        Document [0]:=#0;
        DateC    [0]:=#0;
        TimeC    [0]:=#0;

        Kol     [0]:=#0;
        SummaZ  [0]:=#0;
        ENAlog  [0]:=#0;
        Skidka  [0]:=#0;
   SummaZakupka [0]:=#0;
        SkladKod[0]:=#0;
        Caption [0]:=#0;
 End;
End;

Destructor StatTovarMArketPtr.Done;
Begin
TObject.Done;
End;

Constructor StatTovarrwzPtr.Init ;
Begin
TObject.Init;
With DAt Do
 Begin
        BazKod [0]:=#0;
        Document [0]:=#0;
        DateC    [0]:=#0;
        TimeC    [0]:=#0;
        Kol     [0]:=#0;
        SkladKod[0]:=#0;
        Caption [0]:=#0;
 End;
End;

Destructor StatTovarrwzPtr.Done;
Begin
TObject.Done;
End;


Constructor StatTovarPrzPtr.Init ;
Begin
TObject.Init;
With DAt Do
 Begin
        BazKod [0]:=#0;
        Document [0]:=#0;
        DateC    [0]:=#0;
        TimeC    [0]:=#0;
        Kol     [0]:=#0;
        SkladKod[0]:=#0;
        Caption [0]:=#0;
 End;
End;

Destructor StatTovarPrzPtr.Done;
Begin
TObject.Done;
End;

Constructor StatTovarReturnPtr.Init ;
Begin
TObject.Init;
With DAt Do
 Begin
     OperatorSelector:=0;
     VidDocument    :=0;
        DocSelector    :=0;
     {тип документа по новой классфикации продажи}
        MakeKod [0]:=#0;
        Summa   [0]:=#0;
       StatusDoc:=0;
        BasisDoc[0]:=#0;
     BasisDate [0]:=#0;

        BazKod [0]:=#0;
        Document [0]:=#0;
        DateC    [0]:=#0;
        TimeC    [0]:=#0;
        Kol     [0]:=#0;
        Summa   [0]:=#0;
        SkladKod[0]:=#0;
        Caption [0]:=#0;
 End;
End;

Destructor StatTovarReturnPtr.Done;
Begin
TObject.Done;
End;


Constructor StatTovarPrihodPtr.Init ;
Begin
TObject.Init;
With DAt Do
 Begin
        BazKod [0]:=#0;
OperatorSelector:=0;
        MakeKod [0]:=#0;
   SummaPrihod  [0]:=#0;  {сумма прихода по позиции по Р/Ц}
   SummaZakupka [0]:=#0;  {сумма прихода по позиции по закупочным ценам}
        Document [0]:=#0;
        DateC    [0]:=#0;
        TimeC    [0]:=#0;
        Kol     [0]:=#0;
        SkladKod[0]:=#0;
        Caption [0]:=#0;
        StatusDoc:=0;
 End;
End;

Destructor StatTovarPrihodPtr.Done;
Begin
TObject.Done;
End;



Constructor StatClientTypePtr.Init ;
Var i: Word;
Begin
TObject.Init;
   With Dat Do
    Begin
        Rashet:=1;
        Realiz:=False;

        Document[0]:=#0;

        ENalog[0]  :=#0;
        Nalog5[0]  :=#0;
        Nalog3[0]  :=#0;
        Nalog_[0]  :=#0;

        SummaZ[0]:=#0;
        SummaZakupka[0]:=#0;

        Skidka[0]:=#0;
        Bn.DAte[0]:=#0;
        Bn.NPlat[0]:=#0;
        Bn.Bank[0]:=#0;
        Bn.Summa[0]:=#0;
        Caption:=CurrentPassword;
        DateC[0]:=#0;
        TimeC[0]:=#0;
        DateM:=FDate;
        TimeM:=CurrentTimeString('hh:mm:ss');
        SkladKod:=FormKod(Rek.Kod);
        DocSelector :=0;
        SkidkaSelector :=0;
        ShkalaNumer :=0;
        Region :=0;
        ClientKod[0]:=#0;
        AgentKod[0]:=#0;
        Active:=True;
        Sf :=False;
        For i:=0 To MaxStatRazdel Do
         Begin
          RazdelSum[i]:=0.00;
          RazdelZak[i]:=0.00;
          RazdelSkid[i]:=0.00;
         End;
    End;
End;

Destructor StatClientTypePtr.Done;
Begin
TObject.Done;
End;

Constructor RealizasiaPtr.Init ;
Var i : Byte;
Begin
TObject.Init;

   With Dat.Market Do
    Begin
     Document[0]:=#0;
     SummaZ[0]:=#0;
     Skidka[0]:=#0;

     Caption:=CurrentPassword;
     Active:=True;
     Srok:=0;
     DateC:=FDAte;
     SkladKod:=FormKod(Rek.Kod);


     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     Rashet:=0;
     Region:=0;
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
    End;

  With Dat Do
  Begin
   Realiz:= false;
   Dolg:=0;
   Full:=False;
     Payment:=False;
     {sf := False;}
     For i :=1 To 4 Do
      Begin
      Doc[i].DocReal[0]:=#0;
      Doc[i].DocDate[0]:=#0;
      Doc[i].Employ:=False;
      End;
  End;
End;


Destructor RealizasiaPtr.Done;
Begin
TObject.Done;
End;


Constructor SkladPtr.Init ;
Var j : Byte;
Begin
TObject.Init;
{With Dat.Baz Do
 Begin
     Name[0]:=#0;
     FullName[0]:=#0;
     Litr[0]:=#0;
     InPack[0]:=#0;
     BazKod[0]:=#0;
     Employ:=False;
     Stat:=False;
     MakeKod[0] :=#0;
 End;}
     Dat.MakeKod[0] :=#0;
     Dat.MakeVid:=0;
     Dat.Date:=FDate;
     Dat.Time:=CurrentTimeString('hh:mm:ss');
     Dat.Tip    :=0;
     Dat.Analys :=False;
     Dat.Locked :=False;
     Dat.Employ :=False;
 With Dat.Input Do
  Begin
        Post[0] :=#0;
 NSertif[0]:=#0;
DSertif[0]:=#0;
 KSertif[0]:=#0;

{  Sertifikat[0] :=#0;}
       Akzis1[0] :=#0;
     Kol     :='0';
     For j:=1 To CDivision Do DivisionS[j,0]:=#0;
     nGroupKod:='0000';
     Osn.NaklNumer[0]:=#0;
     Osn.DateNakl[0]:=#0;
     Zakupka :='0.00';
     R_Zena  :='0.00';
     O_Zena  :='0.00';
     RealizovatDo[0]:=#0;
     Caption :=CurrentPassword;
     Auto:=False;
  End;

End;

Destructor SkladPtr.Done;
Begin
TObject.Done;
End;

Constructor KreditTypePtr.Init;
Var i,j : Byte;
Begin
 With DAt Do
 Begin
  For i:=1 To 7 Do{розница и шкалы}
   Begin
    For j:=1 To 12 Do{дни}
     Begin
      Kredit[i].Proz[j]:='1.0000';
     End;{For j:=1}
   End;{For i:=1}
 End;{With}
End;

Destructor  KreditTypePtr.Done;
Begin
TObject.Done;
End;




Constructor BazTypePtr.Init ;
Begin
TObject.Init;
With Dat Do
 Begin
     Name[0]:=#0;
     FullName[0]:=#0;
     Name2[0]:=#0;
     FullName2[0]:=#0;
     Litr:='0.000';
     InPack[0]:=#0;
     BazKod[0]:=#0;
     Employ:=False;
     Market:=0;
     MinNazenka:='1.000';

     VidNalog:=0;
     Nalog:='5.00';

     VidNDS:=0;
     NDS:='20.00';
     EnableOtdel:=31;

     Mera:=0 {шт};
     DostProc:='0.00';
     Vol[0]:=#0;
     Stat:=False;
     Locked:=False;
     CAption:=CurrentPassword;
     LockCaption[0]:=#0;
     ZapretOpt:=false;
     Realiz:=false;
 End;
End;

Destructor BazTypePtr.Done;
Begin
TObject.Done;
End;


Constructor SkidkaPtr.Init ;
Var i : Byte;
Begin
TObject.Init;
 With Dat Do
  Begin
  BazKod[0]:=#0;
  Date:=FDate;
  Time:=CurrentTimeString('hh:mm:ss');
  Caption:=CurrentPassword;
  For i :=1 To CShkala Do
  Begin
   Skidka[i].Up[0]:=#0;
   Skidka[i].Proz:='1.0000';
   Skidka[i].MinNaz:='1.0000';
  End;
  End;
End;

Destructor SkidkaPtr.Done;
Begin
TObject.Done;
End;


Constructor SkidkaPtr1.Init ;
Var i : Byte;
Begin
TObject.Init;
 With Dat Do
  Begin
  BazKod[0]:=#0;
  Date:=FDate;
  Time:=CurrentTimeString('hh:mm:ss');
  Caption:=CurrentPassword;
  For i :=1 To 6 Do
  Begin
   Skidka[i].Up[0]:=#0;
   Skidka[i].Proz:='1.0000';
   Skidka[i].MinNaz:='1.0000';
  End;
  End;
End;

Destructor SkidkaPtr1.Done;
Begin
TObject.Done;
End;

Constructor ShkalaPtr.Init(s:Shkala);
Var i : Byte;
Begin
TObject.Init;
Dat:=S;
Next := Nil;
End;

Destructor ShkalaPtr.Done;
Begin
If Next <> Nil Then Dispose(Next,Done);
TObject.Done;
End;

Constructor BArterClientPtr.Init ;
Var i,j : Byte;
Begin
TObject.Init;
With Dat Do
Begin
        OperatorSelector:=0;
        DocSelector :=0;
        SkidkaSelector :=0;
        ClientKod[0]:=#0;
        Document[0]:=#0;
        DateC:=FDate;
        TimeC:=CurrentTimeString('hh:mm:ss');
        ENalog[0]:=#0;
        Nalog5[0]:=#0;
        Nalog3[0]:=#0;
        Nalog_[0]:=#0;
{сальдо считается по приходу:  закупка *(-1)+
                  по расходу:  к оплате +
			                выдача из кассы
						 поступления в кассу *(-1)}
        {расход}
        SummaZ[0]:=#0;
        Skidka[0]:=#0;
    SummaZakupka[0]:=#0;



        {приход}
    VidPrihoda:=0;
     SrokPlatega[0]:=#0;
        PSumma[0]:=#0;
   PSummaZakupka[0]:=#0;
    OstatokDolga[0]:=#0;
        {выдача из кассы}
        Vidano[0]:=#0;
        Link    :=0;
        Doc     [0]:=#0;
        Date    [0]:=#0;

        {поступления в кассу}
        Priniato[0]:=#0;

        Comment[0]:=#0;

        Rashet:=0;{вид расчета только для поступлений в кассу}
        Bn.DAte[0]:=#0;
        Bn.NPlat[0]:=#0;
        Bn.Bank[0]:=#0;
        Bn.Summa[0]:=#0;

        SkladKod:=FormKod(Rek.Kod);
        Caption :=CurrentPAssword;
        Active  :=True;
End;
End;



Destructor BarterClientPtr.Done;
Begin
TObject.Done;
End;




Destructor  OplataBarterPtr.Done;
Begin
TObject.Done;
End;

Constructor OplataBarterPtr.Init ;
Begin
TObject.Init;
With Dat Do
 Begin
   OperatorSelector:=0;{0-расход из касса в счет погашения долга
                         1-приход денег в кассу в счет погашения долга}
        ClientKod[0]:=#0; {код клиента}
        DateC   :=FDate; {дата создания}
        TimeC   :=CurrentTimeString('hh:mm:ss'); {время создания}
        Order   [0]:=#0;
        SkladKod:=FormKod(Rek.Kod);{признак склада}
        Vid:=0;
        Caption :=CurrentPassword;{признак оператора}
        SummaZ  [0]:=#0;  {сумма по документу к оплате}
        Rashet  :=0;{вид расчета только для поступления в кассу 0-нал}
        Comment [0]:=#0;

        Link    :=0;
        Doc     [0]:=#0;
        Date    [0]:=#0;


        Bn.DAte[0]:=#0;
        Bn.NPlat[0]:=#0;
        Bn.Bank[0]:=#0;
        Bn.Summa[0]:=#0;
        Active  :=True;
 End;
End;



Constructor BufClientPtr.Init ;
var j,k : byte;

Begin
TObject.Init;
For k:=1 To Buffer Do
Begin
 With Point.Dat[k] Do
  Begin
Name     [0]:=#0;
Dogovor  [0]:=#0;
For j:=1 To 4 Do Punkt[j,0]:=#0;
{1 Павильоны} {2 Палатки} {3 Магазин} {4 Кафе}
Limit    [0]:=#0;
Adress   [0]:=#0;
Telefon  [0]:=#0;
R_Sh     [0]:=#0;
Gde      [0]:=#0;
Gorod    [0]:=#0;
INN      [0]:=#0;
OKONH    [0]:=#0;
OKPO     [0]:=#0;
Enviropment[0]:=#0;
Messages[0]:=#0;
Debit   :=0;
SrokLizensia[0]:=#0;
Kod      [0]:=#0;
Employ   :=False;
Stat     :=False;
Locked   :=False;
AgentKod[1]:='0000';
AgentKod[2]:='0000';
NoLimit:=0;
ClientShkala :=0;
Test_Srok   [0]:=#0;
LockTime :=False;
  End;
End;{For Buffer}
End;

Destructor BufClientPtr.Done;
Begin
TObject.Done;
End;


Constructor DolgKassaPtr.Init;
var i: word;
Begin
With Dat Do
 Begin
  Doc      :='';  {N док-та расхода из кассы}
  DateC    :=DateStringToDAte(DateMAsk,FDAte);
  Full     :=false;  {расход погашен}
  Summa    :=0.00;   {текущий долг по документу}
  kod:='';
 End;
End;

Destructor DolgKassaPtr.Done;
Begin
 Inherited done;
End;

Constructor ItogKassaPtr.Init;
var i: word;
Begin
TObject.Init;
With Dat Do
 Begin
   Kod     [0]:=#0;
   Comment [0]:=#0;
   DateC   :=DateStringToDAte(DateMAsk,FDAte);
   TimeC   :=TimeStringToTime('hh:mm:ss',CurrentTimeString('hh:mm:ss'));
   Summa   :=0;
   for i:=1 to CMax do
   begin
    Input[i].Summa:=0;
    Input[i].Comment [0]:=#0;
   end;
   Amount:=0;
   Caption :=CurrentPassword;
   SkladKod:=FormKod(Rek.Kod);
   Lizo     [0]:=#0;
   Main     :=0;
   Doc      [0]:=#0;
   {Active  :=True;}
 End;
End;

Destructor ItogKassaPtr.Done;
Begin
TObject.Done;
End;


Constructor ClientPtr.Init ;
var j : byte;
Begin
TObject.Init;
 With Dat Do
  Begin
Name     [0]:=#0;
Dogovor  [0]:=#0;
For j:=1 To 4 Do Punkt[j,0]:=#0;
{1 Павильоны} {2 Палатки} {3 Магазин} {4 Кафе}
Limit    [0]:=#0;
Adress   [0]:=#0;
Telefon  [0]:=#0;
R_Sh     [0]:=#0;
Gde      [0]:=#0;
AgentKod[1] :='0000';
AgentKod[2] :='0000';
NoLimit  := 0;
Gorod    [0]:=#0;
INN      [0]:=#0;
OKONH    [0]:=#0;
OKPO     [0]:=#0;
Enviropment[0]:=#0;
Messages[0]:=#0;
Debit   :=0;
SrokLizensia[0]:=#0;
Kod      [0]:=#0;
Employ   :=False;
Stat     :=False;
Locked   :=False;
ClientShkala :=0;
Test_Srok   [0]:=#0;
LockTime :=False;
  End;

End;

Destructor ClientPtr.Done;
Begin
TObject.Done;
End;


Constructor IndexTypePtr.Init ;
Var i : Word;
Begin
TObject.Init;
    With Dat Do
   Begin
      For i:=0 To 999 Do Present[i]:=False;
   End;{With}
End;


Destructor IndexTypePtr.Done;
Begin
TObject.Done;
End;



Constructor BufGroupPtr.Init ;
var j,k : Word;

Begin
TObject.Init;
For k:=1 To BufferGroup Do
Begin
 With Point.Dat[k] Do
  Begin
GroupName     [0]:=#0;
Kod      [0]:=#0;
Employ   :=False;
Locked   :=False;
LockCaption:='00';
ComputerNameLocked[0] :=#0;
  End;
End;{For Buffer}
End;

Destructor BufGroupPtr.Done;
Begin
TObject.Done;
End;



Constructor GroupPtr.Init ;
var j : byte;
Begin
TObject.Init;
 With Dat Do
  Begin
GroupName [0]:=#0;
Kod      [0]:=#0;
Employ   :=False;
Locked   :=False;
LockCaption:='00';
ComputerNameLocked[0] :=#0;
  End;

End;

Destructor GroupPtr.Done;
Begin
TObject.Done;
End;


Constructor BufSkladTypePtr.Init ;
var j,k : byte;
Begin
TObject.Init;
For k:=1 To BufferDB Do
Begin
 With Point Do
 Begin
     Dat[k].MakeKod[0] :=#0;
     Dat[k].MakeVid:=0;
     Dat[k].Date:=FDate;
     Dat[k].Time:=CurrentTimeString('hh:mm:ss');
     Dat[k].Tip    :=0;
     Dat[k].Analys :=False;
     Dat[k].Locked :=False;
     Dat[k].Employ :=False;
 With Dat[k].Input Do
  Begin
     Akzis1 [0] :=#0;
       Post [0] :=#0;
        Kol     :='0';
     NSertif[0] :=#0;
     DSertif[0] :=#0;
     RealizovatDo[0]:=#0;
     Osn.NaklNumer[0]:=#0;
     Osn.DateNakl[0]:=#0;

     KSertif[0] :=#0;
     For j:=1 To CDivision Do DivisionS[j,0]:=#0;
     Zakupka :='0.0000';
     R_Zena  :='0.00';
     O_Zena  :='0.00';
     NGroupKod:='0000';
     Caption :=CurrentPassword;
     Auto:=False;
  End;
 End;{With}
End;{For}
End;



Destructor BufSkladTypePtr.Done;
Begin
TObject.Done;
End;




Constructor ImportSuperMarketPtr.Init ;
Var c,i : Byte;
Begin
TObject.Init;
 For i:=1 To CMax Do
  Begin
    Dat.Element[i].BazKod[0]:=#0;
With Dat.Element[i].Baz Do
 Begin
     Name[0]:=#0;
     FullName[0]:=#0;
     Litr:='0.000';
     InPack[0]:=#0;
     BazKod[0]:=#0;
     Employ:=False;
     Market:=0;

     VidNalog:=0;
     Nalog:='5.00';

     VidNDS:=0;
     NDS:='20.00';

     Mera:=0 {шт};

     Stat:=False;
     Locked:=False;
     CAption:=CurrentPassword;
     LockCaption[0]:=#0;
 End;

    With Dat.Element[i].Input Do
   Begin
     Kol    [0] :=#0;
     R_Zena [0] :=#0;
     O_Zena [0] :=#0;
     Zakupka[0] :=#0;
      DivisionSNumber:=1;
	   Post[0] :=#0;
   End;
 End;
   With Dat Do
    Begin
     Document[0]:=#0;

     SummaZ[0]:=#0;
     SummaZakupka[0]:=#0;

     Caption:=CurrentPassword;
     Status:=0;
     Amount:=0;
     DateC[0]:=#0;
     TimeC[0]:=#0;
     SkladKod:=FormKod(Rek.Kod);
     OperatorSelector:=1;
     MakeKod[0]:=#0;
    End;{With}
End;

Destructor ImportSuperMarketPtr.Done;
Begin
TObject.Done;
End;


Constructor BufNewItogTypePtr.Init ;
VAr c,j : Byte;
Begin
TObject.Init;
For j:=1 To BufItg Do
Begin
With Point.Dat[j] Do
 Begin

     BazKod[0]:=#0;
     Ost[0]:=#0;
     PrhC[0]:=#0;
     PrhS[0]:=#0;
     PrhB[0]:=#0;
     PrhEC[0]:=#0;
     PrhES[0]:=#0;
     PrhEB[0]:=#0;
     MrkC[0]:=#0;
     MrkS[0]:=#0;
     MrkB[0]:=#0;
     OstE[0]:=#0;
     MrkEC[0]:=#0;
     MrkEs[0]:=#0;
     MrkEB[0]:=#0;



     MrkEC[0]:=#0;;




 End;
End;{For}
End;

Destructor BufNewItogTypePtr.Done;
Begin
TObject.Done;
End;




Constructor BufRealizasiaTypePtr.Init ;
Var i : Byte;
    c : Word;
Begin
TObject.Init;
For c:=1 To BufferDLG Do
Begin
   With Point.Dat[c].Market Do
    Begin
     Document[0]:=#0;
     {
     SummaZ[0]:=#0;
     Skidka[0]:=#0;
     }
     SummaZ[0]:=#0;
     Skidka[0]:=#0;

     PrhNumer[0]:=#0;
     SfNumer[0]:=#0;
     NaklNumer[0]:=#0;

     Caption:=CurrentPassword;
     Active:=True;
     Srok:=0;
     DateC:=FDAte;
     {TimeC[0]:=#0;}

{$IFNDEF Converter}
     SkladKod:=FormKod(Rek.Kod);
{$ENDIF}
     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     Rashet:=0;
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
    End;
  With Point.Dat[c] Do
  Begin
   Dolg:=0;
   Full:=False;
     Payment:=False;
     {sf := False;}
     For i :=1 To 4 Do
      Begin
      Doc[i].DocReal[0]:=#0;
      Doc[i].DocDate:=FDAte;
      Doc[i].Employ:=False;
      End;
  End;
End;
End;



Destructor BufRealizasiaTypePtr.Done;
Begin
TObject.Done;
End;



Constructor TransportPtr.Init ;
Var i : Byte;
Begin
TObject.Init;
 For i:=1 To CMax Do
  Begin
    Dat.TransportElement[i].BazKod[0]:=#0;
    With Dat.TransportElement[i].Input Do
   Begin
     Kol    [0] :=#0;
     Grammi [0] :=#0;
     Zena   [0] :=#0;
     Zakupka[0] :=#0;
     RegionMArka:=0;
   End;
  End;
   With Dat Do
    Begin
     Document[0]:=#0;
     SummaZ[0]:=#0;
     SummaZakupka[0]:=#0;
     Caption:=CurrentPassword;
     Active:=True;
     Amount:=0;
     DateC:=FDate;
     TimeC:=CurrentTimeString('hh:mm:ss');
{$IFNDEF Converter}
     SkladKod:=FormKod(Rek.Kod);
{$ENDIF}
     ClientOtdelenie:=0;
     MakeOtdelenie:=0;
     Comment [0]:=#0;
    End;
End;



Destructor TransportPtr.Done;
Begin
TObject.Done;
End;




Constructor BufClientOplataRealizasiaTypePtr.Init ;
Var c : Word;
Begin
TObject.Init;
For c:=1 To BufferCOpl Do
Begin
   With Point.Dat[c] Do
Begin
     SkladKod[0] :=#0;
     ClientKod[0] :=#0;
     Document [0] :=#0;
     DateDoc  [0] :=#0;
     PrhNumer [0] :=#0;

     DateC    [0]:=#0;
     TimeC    [0]:=#0;

     SummaZ   [0]:=#0;

     Skidka   [0]:=#0;
      {Добавил для документов возврата}
      Vozwrat :=False;
DocNumerReturn[0] :=#0;
DocDateReturn [0]:=#0;
     Srok     [0]:=#0;
     Caption  [0] :=#0;
     Delta    [0] :=#0;
     Rashet   :=True;
End;{With}
End;{For}
End;


Destructor BufClientOplataRealizasiaTypePtr.Done;
Begin
TObject.Done;
End;






{Var f:File;}
Begin
{
Assign(f,'c:\signal');
DefaultDoc:=IOResult;
Reset(f);
DefaultDoc:=IOResult;
If DefaultDoc=0 Then
 Begin
  Writeln('Программа уже запущена в одном из окон Windows !!!');
  Halt;
  Close(f);
 End
Else
 Begin
  Rewrite(f);
  Close(f);
 End;
}

ProdagaWindow:=False;
Show:=False;
Wzlom:=False;
Status:=DocNormal;
GlobalSkladsName[0]:=#0;

{$IfDef DPMI}
{$Else}
  OvrInit('Sklad.ovr');
  OvrSetBuf(OvrGetBuf{+10648});
  Case OvrResult Of
  OvrError:Begin
           WriteLn('Ошибка управления Overlay !');
           Halt;
           End;
  OvrNotFound:Begin
           WriteLn('Оверлейный модуль не найден !');
           Halt;
           End;
  OvrNoMemory:Begin
           WriteLn('Не хватает памяти для оверлейного буфера !');
           Halt;
           End;
  OvrIOError:Begin
           WriteLn('Сбой при чтении оверлейного файла !');
           Halt;
           End;
  Else;
  End;
  OvrInitEms;
  Case OvrResult Of
  OvrIOError:Begin
           Write('Сбой при чтении оверлейного файла !');
           Halt;
           End;
{
  OvrNoEmsDriver:Begin
                  Writeln('Драйвер EMS не установлен !');
                 End;

  OvrNoEMSMemory:Writeln('Мало EMS памяти !');
}

  Else OvrSetBuf(OvrGetBuf{+45864});
  End;
{$EndIf}

End.



