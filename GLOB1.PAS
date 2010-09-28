{  некоторые соображения
   перевод штрихкода в db-файл, т.е. в InputType
1. возврат по бартеру перевод бартера на вторую закупочную цену
2. переход на 4-ех значную фасовку
3. переход на дробное количество товара (9 символов)
5. просмотр версий заказов
}

Unit Glob;

Interface



{$I Compile.INC}


Uses Objects,ServStr,TpDate{,OWindows};

Const


{Варианты статус}
{ DocPrint      =1;}
  DocEdit       =2;
  DocNormal     =0;
{Конец Вариантов статус}

{список разделов, которые надо включить в }
  NoSertif=85000;
  NoRegion=0;
  NoRoute=0;
  NoSertifStr='85000';
  NoRegionStr='0000';
  NoGroupStr='0000';
  NoRouteStr='0000';
  NoControl =19610405;

{константы буферизации}


{Варианты вида документа}
  DocPrihod      =0;
  DocPereozen    =1;
  DocReturn      =2;
  DocRewisia     =3;
  DocMarket      =4;
  DocOplata      =5;
  DocProtocol    =6;
DocProtocolReturn=7;
DocBarterOplata  =8;
   DocTransport  =9;
  DocOplataOtkat =10;
  DocZakaz       =11;
 {Конец вариантов вида документа}


 ReadOnlyN = $42{40};

 {если возле кода в фигурных скобках стоит * то код уже используется}

 SpisanieProzent:Array [1..4] Of Real =(10.00,5.00,3.00,0.00);

Type Shkala = Record
     Up : String[CIZena];
     Proz : String[CLitr];
     End;


Type PShkala = ^ShkalaPtr;
     ShkalaPtr = Object(TObject)
     Dat : Shkala;
     Next : PShkala;
     Constructor Init(s:Shkala);
     Destructor Done; Virtual;
     End;


Type SkidkaType = Record
     BazKod : String[CArtikul];
     Date   : TDateString;
     Time   : TDateString;
     Caption: String [CRazdelKod];
     Skidka : Array [1..CShkala] of Shkala;
     End;


Type PSkidkaType = ^SkidkaPtr;
     SkidkaPtr = Object(TObject)
     Dat : SkidkaType;
     Constructor Init;
     Destructor Done; Virtual;
     End;


{Информация для склада *.id}
Type BazType = Record
     Main  : Word;{признак головная позиция или нет}
     Name  : String[CName];
     Name2 : String[CName];
     Litr  : String[CLitr];
     InPack: String[CInPack];
    InPack2: String[CInPack];
     OKP   : LongInt{String[COKP]};
     Massa : String[CMassa];
 BuchGroup : LongInt;
     Etil  : String[CLitr];
     Market: Word;
   EnableDebit: Word;  {разрешение консигнации}
     VidNalog : Word; { вид налога 0=5% 1=3% 2=прочее}
     Nalog    : String[CLitr];
     VidNDS   : Word; { вид НДС 0=20% 1=10% 2=прочее}
     NDS      : String[CLitr];
     Mera     : String[CMera];
     EnableContract : Word;
     Contract : String[CContract];
 ContractDate : String[CDate];
     EnableSklads : Word;
     {Slave : Word; {поле от 16-05-02 0-главная или 1-подчиненная позиция}
     {SlaveKod : Longint;}
     {KSertif : String[CKSertif];}
     DSertif : String[CDSertif];
     BazKod  : String[CArtikul];
     FantomKod: String[CArtikul];{код головной позиции в случае если текущая подчиненная}
     PostKod  : String[CClientKod];
     FirmaPostKod  : String[CClientKod];
     KSertif : String[CClientKod];
     Employ: Boolean;
    Caption: String[CRazdelKod];
LockCaption: String[CRazdelKod];
ComputerNameLocked : String[CCNAme];
     Locked: Boolean;
     End;


Type PBazType = ^BazTypePtr;
     BazTypePtr = Object(TObject)
     Dat : BazType;
     Constructor Init;
     Destructor Done; Virtual;
     End;


Type BufBazType = Record
     Dat : Array [1..BufferID] Of BazType;
End;


Type PBufBazType = ^BufBazTypePtr;
     BufBazTypePtr =Object(TObject)
     Point :BufBazType;
     Constructor Init;
     Destructor Done; Virtual;
End;


Type InputImportType = Record
	  Kol     : String[CKol];
       Grammi  : String[CGram];
	  Zakupka : String[CZenaZ];
	  Zakupka2: String[CZenaZ];
	  R_Zena  : String[CZena];
	  O_Zena  : String[CZena];
    Spec_Zena  : String[CZena];
	  NGTD    : String[CNSertif];
      StrihKod : String[CStrihKod];
	    Post  : String[CPost];
    FirmaPost  : String[CFirmaPost];
	  Marka   : String[CNSertif];
     SpecMarka : String[CSpecMarka{CNSertif}];
    Virabotano : String[CDSertif];
	  Godnost : String[CDSertif];
	  Akzis1  : String[CAkzis1];
	  NSertif : ArtikulStr;{Это поле указывает на код сертификата}
	  NMakeKod: ArtikulStr;{Это поле указывает на код поставщика}
      NGroupKod: Word;{Это поле указывает на код группы}
   RegionMarka : Word;{0 - нет; 1- да}
      AkzisSbor: String[CZenaZ];
      ZenaMarki: String[CZenaZ];
{             EZ: String[CName];}
	  End;


Type InputImportTypeS = Record
	  Kol     : String[CKol];
	  Zakupka : String[CZenaZ];
	  Zakupka2: String[CZenaZ];
	  R_Zena  : String[CZena];
	  O_Zena  : String[CZena];
    Spec_Zena  : String[CZena];
	  NSertif : ArtikulStr;{Это поле указывает на код сертификата}
       NMakeKod: ArtikulStr;
      NGroupKod: Word;
	  End;



Type InputMarketType=Record
        Kol     : String[CKol];
        Grammi  : String[CGram];
        Skidka  : String[CZena];
        Zena    : String[CZena];
        R_Zena  : String[CZena];
        O_Zena  : String[CZena];
        Zakupka : String[CZenaZ];
        Zakupka2: String[CZenaZ];
        Proz    : String[CLitr];
       VidNDS   : Word;{ вид налога 0=20% 1=10% 2=прочее}
        NDS     : String[CLitr];
     VidNalog   : Word;{ вид налога 0=5% 1=3% 2=прочее}
      SpecNalog : String[CLitr];
  DiviSionNumber: 1..CDivision;
       Last     : Boolean;
       NSertif  : ArtikulStr;
       SertifKol: String[CKol];{используется только для товара}
       NMAkeKod : ArtikulStr;{код поставщика продукции}
     RegionMarka: Word;{0 - нет; 1- да}
       AkzisSbor: String[CZenaZ];
       ZenaMarki: String[CZenaZ];
       Version  : Word;
      End;

(*
Type InputMarketTypeDisk=Record
        Kol     : Float;
        Skidka  : String[CZena];
        Zena    : String[CZena];
        R_Zena  : String[CZena];
        O_Zena  : String[CZena];
        Zakupka : String[CZenaZ];
        Zakupka2: String[CZenaZ];
        Proz    : String[CLitr];
       VidNDS   : Word;{ вид налога 0=20% 1=10% 2=прочее}
        NDS     : String[CLitr];
     VidNalog   : Word;{ вид налога 0=5% 1=3% 2=прочее}
      SpecNalog : String[CLitr];
  DiviSionNumber: 1..CDivision;
       Last     : Boolean;
       NSertif  : LongInt;
       SertifKol: LongInt;{используется только для товара}
       NMAkeKod : LongInt;{код поставщика продукции}
     RegionMarka: Word;{0 - нет; 1- да}
       AkzisSbor: Float;
       ZenaMarki: Float;
       Version  : Word;
      End;

*)


Type InputTransportType=Record
        Kol     : String[CKol];
        Grammi  : String[CGram];
        Zena    : String[CZena];
        Zakupka : String[CZenaZ];
    RegionMarka : Word
      End;


Type InputZakazType=Record
        Kol     : String[CKol];
        Zena    : String[CZena];
        Skidka  : String[CZena];
        Proz    : String[CZena];
   InputDiviSion: 1..CDivision;
       NSertif  : ArtikulStr;
       SertifKol: String[CKol];{используется только для товара}
        Version : Word;
      End;

{информация по приходу наименования}
Type ElementP = Record
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

Type TElement = Record
     BazKod : String[CArtikul];
     Input  : InputTransportType;
     End;

Type ImportElement = Record
     BazKod : String[CArtikul];
     Baz    : BazType;{наименование товара}
     Employ : Boolean;
     Input  : InputImportType;
     End;

Type ImportElementS = Record
     BazKod : String[CArtikul];
     Baz    : BazType;{наименование товара}
     Employ : Boolean;
     Input  : InputImportTypeS;
     End;

Type ImportBazElement = Record
     BazKod : String[CArtikul];
     Baz    : BazType;{наименование товара}
     NMakeKod: ArtikulStr;
     NGroupKod: Word;
     Employ  : Boolean;
     End;

Type ZakazElementType = Record
     BazKod : String[CArtikul];
     Input  : InputZakazType;
     End;

Type DocumentLink = Record
      DocReal : String[CDocNumer];
      DocDate : LongInt{String[CDate]};
      Employ   : Boolean;
     End;

(*
Type RashetType = Record
     Rashet : Word;{0 наличный 1 комлексный}
     NalSumma : String[CiZena];
     BNSumma  : String[CiZena];
     BNDATe   : TDateString;
     BNNPlat  : String[10];
     BNBank   : AllStr;
     Comment  : String[CSertif];
     End;
*)

(*{информация о продаже}
Type SuperMarkethType=Record
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
     End;*)
(*
Type ExamplVeksel = Record
     Seria : String[CLitr];
     Numer : String[CPack];
     Data  : TDAteString;
     Summa : String[CIZena];
     Proz  : String[CMantissa];
     DogovorNumer : String[CZena];
     End;

Type ExamplPKO = Record
     Numer : String[CArtikul];
     Data  : TDAteString;
     Summa : String[CIZena];
     End;

Type VekselType = Record
      Exampl   : Array[1..MaxVeksel] Of ExamplVeksel;
     End;

Type PKOType = Record
      Exampl   : Array[1..MaxVeksel] Of ExamplPKO;
     End;


Type VekselDopolnenie = Record
      Podlegit : String[CName];
      Mesto1   : String[CAll];
      Mesto2   : String[CAll];
     End;


Type Monstr = Record
      Exampl   : Array[1..MaxVeksel] Of ExamplVeksel;
      Podlegit : String[CName];
      Mesto1   : String[CAll];
      Mesto2   : String[CAll];
     End;*)

(*
Type ExtMarket = Record
	  NGTD    : String[CNSertif];
      StrihKod : String[CStrihKod];
	    Post  : String[CPost];
    FirmaPost  : String[CFirmaPost];
	  Marka   : String[CNSertif];
	  Godnost : String[CDSertif];
     SpecMarka : String[CSpecMArka];
     End;
*)

Type SuperMarketType=Record
     OperatorSelector : Word;{клиент склад обмен заказ}
     DocSelector      : Word;{список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Versia{ShkalaNumer}:Word;{временно не используется для совместимости с универсальным форматом всех файлов}
     Realiz  : Boolean;     {признак что товар был выдан на реализацию}
     Bn : BezNal;
     SkidkaSelector : Word; {вид скидки}
     {новая}
     ShkalaNumer: Word; {временно не используется для совместимости с универсальным форматом всех файлов
	                    номер скидочной шкалы}
     ClientKod : String[CMakeKod]; {код клиента}
     AgentKod  : String[CMakeKod]; {код агента}
     EkspeditorKod : String[CMakeKod]; {код агента}
     {ExtElement   : Array[1..CMax] Of ExtMarket;}
     MarketElement   : Array[1..CMax] Of ProdagaElement; {информация о проданном товаре}
     DocumentElement : Array[1..CMAx] Of ProdagaElement; {информация о проданном товаре}
     Document        : String[CDocNumer]; {номер документа}
     DocumentPrz     : String[CDocNumer];{номер последнего акта переоценки}
     DocumentComment : Integer;
     DateC   : TDateString; {дата создания}
     TimeC   : TDateString; {время создания}
     DateM   : TDateString; {дата модификации}
     TimeM   : TDateString; {время модификации}
  {только для сертификатов}
(* *)SertifSummaZ: String[CIZena];
(* *)SertifSkidka: String[CIZena];
(* *)SertifSummaZakupka: String[CIZena];
(* *)SertifSummaZakupka2: String[CIZena];
     ENalog  : String[CIZena];
     Nalog5  : String[CIZena];
     Nalog3  : String[CIZena];
     Nalog_  : String[CIZena];
     SummaZ  : String[CIZena];  {сумма по документу к оплате}
 SummaAkzis  : String[CIZena];  {сумма акзица по документу}
     Skidka  : String[CIZena];  {скидка по документу}
SummaZakupka : String[CIZena];  {сумма документа по закупочным ценнам}
SummaZakupka2: String[CIZena];  {сумма документа по закупочным ценнам}
     Otkat   : Double;{откат только у Бакши и только для консигнационных документов}
   SkladKod  : String[CClientKod];{признак склада}
     Caption : String [CRazdelKod];{признак оператора}
     Active  : Boolean;{признак активности накладной}
     Amount  : Word;   {число товаров в документе}
(**) AmountS : Word;  {число сертиикатов в документе}
     Locked  : Boolean;{сетевая блокировка}
     Srok    : LongInt;{срок возврата долга}
     DocReal : String[CDocNumer];{номер документа по которым идет проплата,используется только для}
     DocDate : LongInt{TDateString};{документов выводимых после оплаты}
     Rashet  : Word;{0-нал/1-бн/2-вексель}
   Oformlenie: Word;{0 без исползования брони; с использованием брони
                     по заказу номер смотри поле FromZakaz}
    FromZakaz: ArtikulStr;{Номер оформляемого заказа}
     Veksel  : VekselType;
     {PKO     : PKOType;}
     {Comment : AllStr;{комментарий к накладной}
     End;



Type SuperMarketTypeDisk=Record
     OperatorSelector : Word;{клиент склад обмен заказ}
     DocSelector      : Word;{список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Versia           : Word;{временно не используется для совместимости с универсальным форматом всех файлов}
     Realiz           : Boolean;{признак что товар был выдан на реализацию}
     Bn               : BezNal;
     SkidkaSelector   : Word; {вид скидки}
     {новая}
     ShkalaNumer: Word; {временно не используется для совместимости с универсальным форматом всех файлов
	                    номер скидочной шкалы}
     ClientKod : LongInt; {код клиента}
     AgentKod  : LongInt; {код агента}
     EkspeditorKod  : LongInt; {код агента}
     Document : LongInt; {номер документа}
     DocumentPrz : LongInt;{номер последнего акта переоценки}
     DocumentComment : Integer;
     DateC   : LongInt; {дата создания}
     TimeC   : LongInt; {время создания}
     DateM   : LongInt; {дата модификации}
     TimeM   : LongInt; {время модификации}
  {только для сертификатов}
(* *)  SertifSummaZ: String[CIZena];
(* *) SertifSkidka: String[CIZena];
(* *)SertifSummaZakupka: String[CIZena];
(* *)SertifSummaZakupka2: String[CIZena];
     ENalog  : String[CIZena];
     Nalog5  : String[CIZena];
     Nalog3  : String[CIZena];
     Nalog_  : String[CIZena];
     SummaZ  : String[CIZena];  {сумма по документу к оплате}
 SummaAkzis  : String[CIZena];  {сумма акзица по документу}
     Skidka  : String[CIZena];  {скидка по документу}
SummaZakupka : String[CIZena];  {сумма документа по закупочным ценнам}
SummaZakupka2: String[CIZena];  {сумма документа по закупочным ценнам}
     Otkat   : Double;{откат только у Бакши и только для консигнационных документов}
   SkladKod  : LongInt;{признак склада}
     Caption : String [CRazdelKod];{признак оператора}
     Active  : Boolean;{признак активности накладной}
     Amount  : Word;   {число товаров в документе}
(**) AmountS : Word;  {число сертиикатов в документе}
     Locked  : Boolean;{сетевая блокировка}
     Srok    : LongInt;{срок возврата долга}
     DocReal : LongInt;{номер документа по которым идет проплата,используется только для}
     DocDate : LongInt{TDateString};{документов выводимых после оплаты}
     Rashet  : Word;{0-нал/1-бн/2-вексель}
   Oformlenie: Word;{0 без исползования брони; с использованием брони
                     по заказу номер смотри поле FromZakaz}
    FromZakaz: LongInt;{Номер оформляемого заказа}
      Start  : LongInt;{номер стартовй позиции в файле}
      Stop   : LongInt;{номер стоповой позиции в файле}
      StartS : LongInt;{номер стартовй позиции в файле для сертификатов}
      StopS  : LongInt;{номер стоповой позиции в файле для сертификатов}
     Veksel  : VekselType;
     End;


Type SuperMarketTypeIDX=Record
     OperatorSelector : Word; {клиент склад обмен заказ}
     DocSelector      : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Versia           : Word; {временно не используется для совместимости с универсальным форматом всех файлов}
     Realiz           : Boolean;     {признак что товар был выдан на реализацию}
     SkidkaSelector   : Word; {вид скидки}
     ShkalaNumer: Word; {временно не используется для совместимости с универсальным форматом всех файлов
	                    номер скидочной шкалы}
     ClientKod : String[CMakeKod]; {код клиента}
     AgentKod  : String[CMakeKod]; {код агента}
     EkspeditorKod  : String[CMakeKod]; {код агента}
     Document : String[CDocNumer]; {номер документа}
     DateC   : LongInt; {дата создания}
     TimeC   : LongInt; {время создания}
     DateM   : LongInt; {дата модификации}
     TimeM   : LongInt; {время модификации}
  {только для сертификатов}
(* *)SertifSummaZ: Double;
(* *)SertifSkidka:  Double;
(* *)SertifSummaZakupka: Double;
(* *)SertifSummaZakupka2: Double;
     ENalog  : Double;
     SummaZ  : Double;  {сумма по документу к оплате}
 SummaAkzis  : Double;  {сумма по документу акзицного сбора}
     Skidka  : Double;  {скидка по документу}
SummaZakupka : Double;  {сумма документа по закупочным ценнам}
SummaZakupka2: Double;  {сумма документа по закупочным ценнам}
     Otkat   : Double;{откат только у Бакши и только для консигнационных документов}

     MSummaZ  : Array[1..CDivision] Of Real;  {сумма по документу к оплате}
     MSkidka  : Array[1..CDivision] Of Real;  {скидка по документу}
MSummaZakupka : Array[1..CDivision] Of Real;  {сумма документа по закупочным ценнам}
MSummaZakupka2: Array[1..CDivision] Of Real;  {сумма документа по закупочным ценнам2}

     MSSummaZ  : Array[1..CDivision] Of Real;  {сумма по документу к оплате}
     MSSkidka  : Array[1..CDivision] Of Real;  {скидка по документу}
MSSummaZakupka : Array[1..CDivision] Of Real;  {сумма документа по закупочным ценнам}
MSSummaZakupka2: Array[1..CDivision] Of Real;  {сумма документа по закупочным ценнам2}



   SkladKod  : String[CClientKod];{признак склада}
     Caption : String [CRazdelKod];{признак оператора}
     Active  : Boolean;{признак активности накладной}
     Rashet  : Word;{0-нал/1-бн/2-вексель}
   Oformlenie: Word;{0 без исползования брони; с использованием брони
                     по заказу номер смотри поле FromZakaz}
    FromZakaz: ArtikulStr;{Номер оформляемого заказа}
     End;



Type ClientMarketType=Record
    DocSelector: Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
SkidkaSelector : Word; {вид скидки}
     AgentKod  : String[CMakeKod]; {код агента}
     BazKod    : ArtikulStr;
     Document  : String[CDocNumer]; {номер документа}
     DateC     : LongInt; {дата создания}
     Kol       : ArtikulStr;
     Zena      : Real;
     Lobovaja  : Real;
     Zakupka   : Real;
     End;

{буферизированный тип для продаж}
Type BufSuperMarketType = Record
     Dat : Array [1..BufferMRK] Of SuperMarketType;
     End;


{буферизированный тип для продаж}
Type BufSuperMarketTypeIDX = Record
     Dat : Array [1..BufferMRKIDX] Of SuperMarketTypeIDX;
     End;


Type PBufSuperMarketType = ^BufSuperMarketTypePtr;
     BufSuperMarketTypePtr =Object(TObject)
     Point :BufSuperMarketType;
     Constructor Init;
     Destructor Done; Virtual;
End;


Type PBufSuperMarketTypeIDX = ^BufSuperMarketTypeIDXPtr;
     BufSuperMarketTypeIDXPtr =Object(TObject)
     Point :BufSuperMarketTypeIDX;
     Constructor Init;
     Destructor Done; Virtual;
End;




Type NewInputMarketType=Record
        Kol     : LongInt;
        Skidka  : Double;
        Zena    : Double;
        R_Zena  : Double;
        O_Zena  : Double;
        Zakupka : Double;
        Zakupka2: Double;
        Proz    : Double;
       VidNDS   : Word;{ вид налога 0=20% 1=10% 2=прочее}
        NDS     : StrIng[CLitr];
     VidNalog   : Word;{ вид налога 0=5% 1=3% 2=прочее}
      SpecNalog : StrIng[CLitr];
  DiviSionNumber: 1..CDivision;
       Last     : Boolean;
       NSertif  : LongInt;
       SertifKol: LongInt;{используется только для товара}
       NGTD     : LongInt;{код ГТД}
       Akzis    : LongInt;{код акцизной марки}
       SpecMarka: LongInt;{код спецмарки}
      End;


Type NewProdagaElement = Record
     BazKod : LongInt;
     Document : LongInt;
     DateC    : LongInt;
     SkladKod : Word;
     Input  : NewInputMarketType;
     End;

Type BufNewProdagaElement = Record
     Point : Array [1..BufferNewPE] Of NewProdagaElement;
     End;


{
Type
    PBufNewProdagaElement = ^BufNewProdagaElementPtr;
    BufNewProdagaElementPtr=Object(TObject)
    Dat  :  BufNewProdagaElement;
     Constructor Init;
     Destructor Done; Virtual;
 end;
}


(*
     {483}
Type SuperMarketTypeDisk=Record
     OperatorSelector : Word; {клиент склад обмен заказ}
     DocSelector      : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Versia           : Word; {временно не используется для совместимости с универсальным форматом всех файлов}
     Realiz           : Boolean;     {признак что товар был выдан на реализацию}
     SkidkaSelector   : Word; {вид скидки}
     {новая}
     ShkalaNumer: Word; {временно не используется для совместимости с универсальным форматом всех файлов
	                    номер скидочной шкалы}
     ClientKod : Word; {код клиента}
     AgentKod  : Word; {код агента}
     Document : LongInt; {номер документа}
     DocumentPrz : LongInt;{номер последнего акта переоценки}
     DocumentComment : Integer;
     DateC   : LongInt; {дата создания}
     TimeC   : LongInt; {время создания}
     DateM   : LongInt; {дата модификации}
     TimeM   : LongInt; {время модификации}

  {только для сертификатов}
  SertifSummaZ: Real;
 SertifSkidka: Real;
SertifSummaZakupka: Real;
SertifSummaZakupka2: Real;


     SummaZ  : Real;  {сумма по документу к оплате}
     Skidka  : Real;  {скидка по документу}
SummaZakupka : Real;  {сумма документа по закупочным ценнам}
SummaZakupka2: Real;  {сумма документа по закупочным ценнам}

      Start  : LongInt;{номер стартовй позиции в файле}
      Stop   : LongInt;{номер стоповой позиции в файле}

      StartS : LongInt;{номер стартовй позиции в файле для сертификатов}
      StopS  : LongInt;{номер стоповой позиции в файле для сертификатов}

   SkladKod  : Word;{признак склада}
     Caption : Word;{признак оператора}
     Active  : Boolean;{признак активности накладной}
     Amount  : Word;   {число товаров в документе}
    AmountS  : Word;  {число сертиикатов в документе}
     Locked  : Boolean;{сетевая блокировка}
     Srok    : LongInt;{срок возврата долга}
     DocReal : LongInt;{номер документа по которым идет проплата,используется только для}
     DocDate : LongInt;{документов выводимых после оплаты}
     Rashet  : Word;{0-нал/1-бн/2-вексель}
   Oformlenie: Word;{0 без исползования брони; с использованием брони
                     по заказу номер смотри поле FromZakaz}
    FromZakaz: LongInt;{Номер оформляемого заказа}
     End;
*)





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


Type ImportSuperMarketType=Record
     Element   : Array[1..CMax] Of ImportElement; {информация о проданном товаре}
     ElementS  : Array[1..CMax] Of ImportElementS; {информация о проданном сертификате}
     NSertif   : Array[1..CMax] Of ImportBazElement;
     Document  : String[CDocNumer]; {номер документа}
     DateC     : LongInt; {дата импорта}
     TimeC     : LongInt; {время импорта}
     SummaZ    : Real{String[CIZena]};  {сумма по документу к оплате}
SummaZakupka   : Real{String[CIZena]};  {сумма документа по закупочным ценнам}
    SkladKod   : String[CClientKod];{признак склада}
     Caption   : String [CRazdelKod];{признак оператора}
     Amount    : Word;   {число товаров в документе}
     AmountS   : Word;   {число сертификатов в документе}
     AmountNS  : Word;   {число ссылок на сертификаты в документе}
     End;




Type PsevdoSuperMarketType=Record
     OperatorSelector:Word; {клиент склад обмен заказ}
     DocSelector : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Versia : Byte{Word};
     Rashet : Word;{добавлено для отслеживания векселей}
     SkidkaSelector : Word; {вид скидки}
     ClientKod : String[CMakeKod]; {код клиента}
     AgentKod  : String[CMakeKod]; {код агента}
     EkspeditorKod  : String[CMakeKod]; {код агента}
     Document : String[CDocNumer]; {номер документа}
     DateC   : LongInt; {дата создания}

     SummaZ  : Double{String[CIZena]};  {сумма по документу к оплате}
     Skidka  : Double{String[CIZena]};  {скидка по документу}

 SummaZakupka : Double{String[CIZena]};  {сумма документа по закупочным ценам}
 SummaZakupka2: Double{String[CIZena]};  {сумма документа по закупочным ценам}

     SkladKod : String[CClientKod];{признак склада}
     Caption : String [CRazdelKod];{признак оператора}
     Active  : Boolean;{признак активности накладной}
     Srok    : LongInt;{срок возврата долга}
     End;


(*
Type PsevdoSuperMarketType1=Record
     OperatorSelector:Word; {клиент склад обмен заказ}
     DocSelector : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Versia : Word;
     Rashet : Word;{добавлено для отслеживания векселей}
     SkidkaSelector : Word; {вид скидки}
     ClientKod : Word; {код клиента}
     AgentKod  : Word; {код агента}
     Document : String[CDocNumer]; {номер документа}
     DateC   : TDateString; {дата создания}
     TimeC   : TDateString; {время создания}

     SummaZ  : String[CIZena];  {сумма по документу к оплате}
     Skidka  : String[CIZena];  {скидка по документу}

SummaZakupka : String[CIZena];  {сумма документа по закупочным ценнам}
SummaZakupka2: String[CIZena];  {сумма документа по закупочным ценнам}

  SkladKod   : Word;{признак склада}
     Caption : String [CRazdelKod];{признак оператора}
     Active  : Boolean;{признак активности накладной}
     Srok    : LongInt;{срок возврата долга}
     End;
*)



Type ZakazType=Record
     OperatorSelector : Word; {клиент склад обмен заказ}
     DocSelector      : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Versia : Word;
	ShkalaNumer: Word; {временно не используется для совместимости с универсальным форматом всех файлов}
     SkidkaSelector : Word; {вид скидки}
     ClientKod : String[CMakeKod]; {код клиента}
     AgentKod        : String[CMakeKod]; {код агента}
     EkspeditorKod  : String[CMakeKod]; {код агента}
     MarketElement   : Array[1..CMax] Of ZakazElementType; {информация о проданном товаре}
     DocumentElement : Array[1..CMAx] Of ZakazElementType; {информация о проданном товаре}
     Document : ArtikulStr; {номер документа}
     DocumentComment : Integer;
     DateC   : TDateString; {дата создания}
     TimeC   : TDateString; {время создания}
     DateM   : TDateString; {дата модификации}
     TimeM   : TDateString; {время модификации}

  {только для сертификатов}
(* *)  SertifSummaZ: String[CIZena];
(* *) SertifSkidka: String[CIZena];
     SummaZ  : String[CIZena];  {сумма по документу к оплате}
     Skidka  : String[CIZena];  {скидка по документу}

   SkladKod  : String[CClientKod];{признак склада}
     Caption : String [CRazdelKod];{признак оператора}
     Amount  : Word;   {число товаров в документе}
(**) AmountS  : Word;  {число сертиикатов в документе}
     Locked  : Boolean;{сетевая блокировка}
     Srok    : LongInt;{срок возврата долга}
     EndDate : LongInt;{Срок брони - количество дней отводимых на доставку}
     DocReal : String[CDocNumer];{номер документа по которым идет проплата,используется только для}
     DocDate : TDateString;{документов выводимых после оплаты}
     Rashet  : Word;{0-нал/1-бн/2-вексель}
     Oformlenie : Word;{признак оформления заказа или снятия с брони по времени}
     End;





Type HeaderZakazType=Record
     OperatorSelector : Byte; {клиент склад обмен заказ}
     DocSelector      : Byte;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Versia : Byte;
     SkidkaSelector : Byte; {вид скидки}
     ClientKod : Word; {код клиента}
     AgentKod  : Word; {код агента}
     EkspeditorKod  : Word; {код агента}
     Rashet:Byte;
     SkladKod : Word;

     Document: LongInt; {номер документа}

     DateC   : LongInt; {дата создания}
     TimeC   : LongInt; {время создания}
     DateM   : LongInt; {дата модификации}
     TimeM   : LongInt; {время модификации}

(* *)SertifSummaZ: Real;
(* *)SertifSkidka: Real;

     SummaZ  : Real;  {сумма по документу к оплате}
     Skidka  : Real;  {скидка по документу}
     Caption : Byte;{признак оператора}
     EndDate : LongInt;{Срок брони - количество дней отводимых на доставку}
     DocReal : LongInt;{номер документа по которым идет проплата,используется только для}
     DocDate : LongInt;{документов выводимых после оплаты}
     Oformlenie : Byte;{признак оформления заказа иди снятия с брони по времени}
     End;



Type BufZakazType = Record
     Dat : Array [1..BufferZakaz] Of ZakazType;
     End;


Type BufHeaderZakazType = Record
     Dat : Array [1..BufferHeaderZakaz] Of HeaderZakazType;
     End;


Type PBufZakazType = ^BufZakazTypePtr;
     BufZakazTypePtr =Object(TObject)
     Point :BufZakazType;
     Constructor Init;
     Destructor Done; Virtual;
End;

Type PBufHeaderZakazType = ^BufHeaderZakazTypePtr;
     BufHeaderZakazTypePtr =Object(TObject)
     Point :BufHeaderZakazType;
     Constructor Init;
     Destructor Done; Virtual;
End;




Type
    PSuperMarketType = ^SuperMarketPtr;
    SuperMarketPtr=Object(TObject)
    Dat  :  SuperMarketType;
     Constructor Init;
     Destructor Done; Virtual;
 end;

Type
    PSuperMarketTypeIDX = ^SuperMarketIDXPtr;
    SuperMarketIDXPtr=Object(TObject)
    Dat  :  SuperMarketTypeIDX;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Type
    PTransportType = ^TransportPtr;
    TransportPtr=Object(TObject)
    Dat  :  TransportType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Type
    PImportSuperMarketType = ^ImportSuperMarketPtr;
    ImportSuperMarketPtr=Object(TObject)
    Dat  :  ImportSuperMarketType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Type
    PZakazType = ^ZakazTypePtr;
    ZakazTypePtr=Object(TObject)
    Dat  :  ZakazType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Type
    PHeaderZakazType = ^HeaderZakazTypePtr;
    HeaderZakazTypePtr=Object(TObject)
    Dat  :  HeaderZakazType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Type BarterClientType = Record
        OperatorSelector:Word;{0-приход 1-расход 2-расход из касса в счет погашения
	                          3-приход денег в кассу в счет погашения долга}
        DocSelector : Word;   {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть
	                          деньги еще не проплачены только для расхода}
        SkidkaSelector : Word; {вид скидки только для расхода}
        ClientKod : String[CMakeKod]; {код клиента}
        Document : String[CDocNumer]; {номер документа только для прихода и расхода}
        DateC   : TDateString; {дата создания}
        TimeC   : TDateString; {время создания}
        SENalog  : String[CIZena];
        SNalog5  : String[CIZena];
        SNalog3  : String[CIZena];
        SNalog_  : String[CIZena];
{сальдо считается по приходу:  закупка *(-1)+
                  по расходу:  к оплате +
			                выдача из кассы
						 поступления в кассу *(-1)}
        {расход сертификатов}
(**)  SertifSummaZ: String[CIZena];
(**) SertifSkidka: String[CIZena];
(**)SertifSummaZakupka: String[CIZena];
(**)SertifSummaZakupka2: String[CIZena];
        ENalog  : String[CIZena];
        Nalog5  : String[CIZena];
        Nalog3  : String[CIZena];
        Nalog_  : String[CIZena];
        {расход}
        SummaZ  : String[CIZena];  {сумма по документу к оплате}
        Skidka  : String[CIZena];  {сумма скидки по документу}
    SummaZakupka: String[CIZena];  {сумма документа по закупочным ценнам}
   SummaZakupka2: String[CIZena];  {сумма документа по закупочным ценнам}
        {приход}
        PSumma  : String[CIZena];  {сумма по продажным ценам}
   PSummaZakupka: String[CIZena];  {сумма документа прихода по закупочным ценнам}
   PSummaZakupka2: String[CIZena];  {сумма документа прихода по закупочным ценнам}
        {выдача из кассы}
        Vidano  : String[CIZena];
        {поступления в кассу}
        Priniato : String[CIZena];
        Comment  : AllStr;
        Rashet  : Word;{вид расчета только для поступлений в кассу}
        Bn      : BezNal; {б/н расчет только для поступлений в кассу}
        SkladKod: String[CClientKod];{признак склада}
        Caption : String[CRazdelKod];{признак оператора}
        Active  : Boolean;
     End;



Type OplataBarter = Record
        OperatorSelector:Word;{0-расход из касса в счет погашения долга
	                          1-приход денег в кассу в счет погашения долга}
        ClientKod : String[CMakeKod]; {код клиента}
        DateC   : TDateString; {дата создания}
        TimeC   : TDateString; {время создания}
        Order   : String[CDocNumer];
        Vid     : Word;
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


Type StatClientType = Record
        Rashet    : Word;
        DocSelector : Word;{список, тов чек, физ.лиц, с/ф,с/ф б,дебит то есть деньги еще не проплачены}
        Realiz  : Boolean; {признак что товар был выдан на реадизацию}
        Bn : BezNal;
        SkidkaSelector : Word; {вид скидки}
        AgentKod : String[CMakeKod]; {код клиента}
        EkspeditorKod : String[CMakeKod];
        Document: String[CDocNumer]; {номер документа}
        DateC   : LongInt{TDateString}; {дата создания}
        TimeC   : LongInt{TDateString}; {время создания}
        DateM   : LongInt{TDateString}; {дата модификации}
        TimeM   : LongInt{TDateString}; {время модификации}
(**)  SertifSummZ: Float{String[CIZena]};
(**) SertifSkidka: Float{String[CIZena]};
(**)SertifSummaZakupka: Float{String[CIZena]};
        SummaZ  : Float{String[CIZena]};  {сумма по документу к оплате}
        Skidka  : Float{String[CIZena]};  {сумма по документу к оплате}
   SummaZakupka : Float{String[CIZena]};  {сумма документа по закупочным ценнам}
   SummaAkzis   : Float{String[CIZena]};  {сумма документа по закупочным ценнам}
        SkladKod: Word{String[CClientKod]};{признак склада}
        Caption : String[CRazdelKod];{признак оператора}
        Active  : Boolean;
     End;

(*
Type StatClientType1 = Record
        Rashet    : Word;
        DocSelector : Word;{список, тов чек, физ.лиц, с/ф,с/ф б,дебит то есть деньги еще не проплачены}
        Realiz  : Boolean; {признак что товар был выдан на реадизацию}
        SkidkaSelector : Word; {вид скидки}
        AgentKod : String[CMakeKod]; {код клиента}
        EkspeditorKod : String[CMakeKod];
        Document: String[CDocNumer]; {номер документа}
        DateC   : LongInt{TDateString}; {дата создания}
        TimeC   : LongInt{TDateString}; {время создания}
        DateM   : LongInt{TDateString}; {дата модификации}
        TimeM   : LongInt{TDateString}; {время модификации}
      SertifSummZ: Real{String[CIZena]};
     SertifSkidka: Real{String[CIZena]};
    SertifSummaZakupka: Real{String[CIZena]};
        SummaZ  : Real{String[CIZena]};  {сумма по документу к оплате}
        Skidka  : Real{String[CIZena]};  {сумма по документу к оплате}
   SummaZakupka : Real{String[CIZena]};  {сумма документа по закупочным ценнам}
   SummaAkzis   : Real{String[CIZena]};  {сумма документа по закупочным ценнам}
        SkladKod: Word{String[CClientKod]};{признак склада}
        Caption : String[CRazdelKod];{признак оператора}
        Active  : Boolean;
     End;
*)

(*
Type StatClientType1 = Record
        Rashet    : Word;
        DocSelector : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
        Realiz  : Boolean;     {признак что товар был выдан на реадизацию}
        Bn : BezNal;
        SkidkaSelector : Word; {вид скидки}
        AgentKod : String[CMakeKod]; {код клиента}
        Document : String[CDocNumer]; {номер документа}
        DateC   : LongInt{TDateString}; {дата создания}
        TimeC   : LongInt{TDateString}; {время создания}
        DateM   : LongInt{TDateString}; {дата модификации}
        TimeM   : LongInt{TDateString}; {время модификации}


  SertifSummZ: String[CIZena];
 SertifSkidka: String[CIZena];
SertifSummaZakupka: String[CIZena];
SertifSummaZakupka2: String[CIZena];


        SummaZ  : String[CIZena];  {сумма по документу к оплате}
        Skidka  : String[CIZena];  {сумма по документу к оплате}
   SummaZakupka : String[CIZena];  {сумма документа по закупочным ценнам}
   SummaZakupka2: String[CIZena];  {сумма документа по закупочным ценнам}
        SkladKod: Word{String[CClientKod]};{признак склада}
        Caption : String[CRazdelKod];{признак оператора}
        Active  : Boolean;
        RazdelSum  : Array[0..MaxStatRazdel] Of Single{Real};
        RazdelZak  : Array[0..MaxStatRazdel] Of Single{Real};
        RazdelZak2 : Array[0..MaxStatRazdel] Of Single{Real};
        RazdelSkid : Array[0..MaxStatRazdel] Of Single{Real};
     End;
*)




{буферизированный тип для хронологии}
Type BufStatClientType = Record
     Dat : Array [1..BufferHis] Of StatClientType;
     End;


Type PBufStatClientType = ^BufStatClientTypePtr;
     BufStatClientTypePtr =Object(TObject)
     Point :BufStatClientType;
     Constructor Init;
     Destructor Done; Virtual;
End;


Type Shetshik = Record
       BazKod  : ArtikulStr;
       Kol     : String[CKol];
     End;


Type ClientTovarType = Record
        ClientKod: String[CClientKod];
        AgentKod : String[CClientKod];
     DocSelector : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
        Document : String[CDocNumer]; {номер документа}
         DateC   : TDateString; {дата создания}
         TimeC   : TDateString; {время создания}
         Active  : Boolean;
         Amount  : Word;
         SkladKod: String[CClientKod];
         Element : Array [1..CMax] of Shetshik;
     End;


Type LastShetshik = Record
       BazKod  : ArtikulStr;
       Kol     : Word;
       Zena    : Real;
       Zakupka : Real;
     End;


Type LastClientTovarType = Record
        ClientKod: String[CClientKod];
        AgentKod : String[CClientKod];
     SkidkaSelector : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     DocSelector : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
        Document : String[CDocNumer]; {номер документа}
         Caption : String[CRazdelKod];
         DateC   : LongInt; {дата создания}
         Active  : Boolean;
         Amount  : Word;
         SkladKod: String[CClientKod];
         Element : Array [1..CMax] of LastShetshik;
     End;


Type BufClientTovarType = Record
     Dat : Array [1..BufferTST] Of ClientTovarType;
     End;

Type BufLastClientTovarType = Record
     Dat : Array [1..BufferLastTovar] Of LastClientTovarType;
     End;


Type PClientTovarType = ^ClientTovarTypePtr;
     ClientTovarTypePtr =Object(TObject)
     Dat : ClientTovarType;
     Constructor Init;
     Destructor Done; Virtual;
     End;

Type PLastClientTovarType = ^LastClientTovarTypePtr;
     LastClientTovarTypePtr =Object(TObject)
     Dat : LastClientTovarType;
     Constructor Init;
     Destructor Done; Virtual;
     End;


Type PBufClientTovarType = ^BufClientTovarTypePtr;
     BufClientTovarTypePtr =Object(TObject)
     Point :BufClientTovarType;
     Constructor Init;
     Destructor Done; Virtual;
End;



Type PBufLAstClientTovarType = ^BufLastClientTovarTypePtr;
     BufLastClientTovarTypePtr =Object(TObject)
     Point :BufLastClientTovarType;
     Constructor Init;
     Destructor Done; Virtual;
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
        BN      : BezNal;
        Document: String[CDocNumer]; {номер документа}
        DateC   : TDateString; {дата создания}
        TimeC   : TDateString; {время создания}
        DateM   : TDateString; {дата создания}
        TimeM   : TDateString; {время создания}
        Kol     : String[CKol+2];
        SummaZ  : String[CIZena];  {сумма по позиции к оплате}
        ENalog  : String[CIZena];  {сумма по позиции налог с продажи}
        SNalog  : String[CLitr];
        Skidka  : String[CIZena];  {сумма по документу к оплате}
        Proz    : String[CIZena];
      AkzisSbor : String[CIZena];  {Акцизный сбор}
   SummaZakupka : String[CIZena];  {сумма документа по закупочным ценнам}
   SummaZakupka2: String[CIZena];  {сумма документа по закупочным ценнам}
        SkladKod: String[CClientKod];{признак склада}
        Caption : String[CRazdelKod];{признак оператора}
        {Comment : AllStr;}
     End;



Type StatTovarPrihodType = Record
      {Приход}
        BazKod  : ArtikulStr;
        NMakeKod: ArtikulStr;
OperatorSelector: Word;
        MakeKod : String[CMakeKod]; {код клиента}
        Document: String[CDocNumer]; {номер документа}
        DateC   : TDateString; {дата создания}
        TimeC   : TDateString; {время создания}
        Kol     : String[CKol];
       StatusDoc: Word;
   SummaAkzis   : String[CIZena];
   SummaPrihod  : String[CIZena];  {сумма прихода по позиции по Р/Ц}
   SummaZakupka : String[CIZena];  {сумма прихода по позиции по закупочным ценам}
   SummaZakupka2: String[CIZena];  {сумма прихода по позиции по закупочным ценам}
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
        Comment : SertifStr;
        Tested  : Word;
        CaptionTested : String[CRazdelKod];
        DateT   : TDateString;
        TimeT   : TDateString;
     End;


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
   SummaAkzis   : String[CIZena];
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


Type PBarterClientType = ^BArterClientPtr;
     BArterClientPtr =Object(TObject)
     Dat : BarterClientType;
     Constructor Init;
     Destructor Done; Virtual;
     End;

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


Type RealizasiaType = Record
     Market : PsevdoSuperMarketType;
     {для Бакши для учета отката-взяток}
     Otkat  : Double;
   FullOtkat: Boolean;
     Dolg   : Double;
     Full   : Boolean;
     Payment: Boolean;{признак оплаты, если началась оплата то корректировать нельзя}
                      {по умолчанию False ,обращается в True, если при расплате долга}
                      {SummaZ=Dolg см док-т реализации}
     Doc    : Array [1..4] Of DocumentLink;{используется только в первичных документах реализации
                                            для обозначения выведенных документов}
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


(*
Type BakRealizasiaType = Record
     Market : SuperMarketType;
     Dolg   : Real;
     Full   : Boolean;
     Payment: Boolean;{признак оплаты, если началась оплата то корректировать нельзя}
                      {по умолчанию False ,обращается в True, если при расплате долга}
                      {SummaZ=Dolg см док-т реализации}
     Doc    : Array [1..4] Of DocumentLink;     {используется только в первичных документах реализации
                                                  для обозначения выведенных документов }
     Sf     : Boolean;
     End;
(*
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
*)


Type OplataRealizasiaType = Record
    SkladKod : String[CClientKod];
   ClientKod : String[CClientKod];
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
     Rashet  : Word;
     Bn      : BezNal;
     Veksel  : VekselType;
     End;


Type BufOplataRealizasiaType = Record
     Dat : Array [1..BufferOpl] Of OplataRealizasiaType;
End;


Type PBufOplataRealizasiaType = ^BufOplataRealizasiaTypePtr;
     BufOplataRealizasiaTypePtr =Object(TObject)
     Point :BufOplataRealizasiaType;
     Constructor Init;
     Destructor Done; Virtual;
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
     Caption : String[CRazdelKod];{признак оператора}
     Delta   : String[CLitrMantissa];{дней задержки}
     End;
*)

(*
Type ClientOplataRealizasiaType = Record
     SkladKod : String[CClientKod];
     ClientKod: String[CClientKod];
     Document : String[CDocNumer]; {номер документа}
     DateDoc  : TDateString; {дата документа}
     DateC    : TDateString; {дата ОПЛАТЫ}
     TimeC    : TDateString; {время ОПЛАТЫ}
     SummaZ   : String[CIZena];  {сумма оплаты}
     Skidka   : String[CIZena];  {велечина списания скидки}
                                 {Добавил для документов возврата}
      Vozwrat : Boolean;      {если был возврат}
DocNumerReturn: String[CDocNumer];{документ возврата}
DocDateReturn : STring[CDate];    {документ возврата}
     Srok     : TDateString; {дата документа}
     Caption  : String[CRazdelKod];{признак оператора}
     Delta    : String[CLitrMantissa+1];{дней задержки}
     Rashet   : Word;{0-нал 1-бн 2-вексель}
     Veksel   : VekselType;
     Bn       : BezNal;
     End;
*)

Type ClientOplataRealizasiaType = Record
     SkladKod : String[CClientKod];
     ClientKod: String[CClientKod];
     Document : String[CDocNumer]; {номер документа}
     DateDoc  : LongInt; {дата документа}
     DateC    : LongInt; {дата ОПЛАТЫ}
     TimeC    : LongInt; {время ОПЛАТЫ}
     SummaZ   : Real;  {сумма оплаты}
     Skidka   : Real;  {велечина списания скидки}
                       {Добавил для документов возврата}
      Vozwrat : Boolean;      {если был возврат}
DocNumerReturn: String[CDocNumer];{документ возврата}
DocDateReturn : {String[CDate]}LongInt;    {документ возврата}
     Srok     : LongInt; {дата документа}
     Caption  : String[CRazdelKod];{признак оператора}
     Delta    : String[CLitrMantissa+1];{дней задержки}
     Rashet   : Word;{0-нал 1-бн 2-вексель}
    {Veksel   : VekselType1;}
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



{Склад}
Type SkladType = Record
     BazKod      : String[CArtikul];
     MakeKod     : String[CMakeKod];
     MakeVid     : Word;
     Input       : InputType;
     EnableDebit : Word;
     Employ      : Boolean;
     Date        : LongInt{TDateString};
     Time        : LongInt{TDateString};
     Locked      : Boolean;
   End;


{Склад}
Type SkladTypeMore = Record
     BazKod      : String[CArtikul];
     MakeKod     : String[CMakeKod];
     MakeVid     : Word;
     Input       : InputTypeMore;
     EnableDebit : Word;
     Employ      : Boolean;
     Date        : LongInt{TDateString};
     Time        : LongInt{TDateString};
     Locked      : Boolean;
   End;


Type SkladTypeNew = Record
       Name : String[CNAme];
       Name2: String[CNAme];
       Virabotano : LongInt{TDateString};
	  Division: TKolWord;
      DivisionR: TKolWord;
       Kol     : LongInt;
	  R_Zena  : Real;
  EnableSklads : Word;
      StrihKod : String[CStrihKod];
	  NSertif : LongInt;{Это поле указывает на код сертификата}
       NMakekod: LongInt;
      NGroupKod: LongInt;
    RegionMarka: Word;
     AkzisSbor : Real;
       Zakupka : Real;
       Zakupka2: Real;
       BazKod  : LongInt;
       Employ  : Boolean;
	  End;


Type SkladTypeNewMore = Record
       Name : String[CNAme];
       Name2: String[CNAme];
       Virabotano : LongInt{TDateString};
	  Division: Array[1..9]Of TKolWord;
      DivisionR: Array[1..9]Of TKolWord;
       Kol     : Array[1..9]Of LongInt;
	  R_Zena  : Real;
      StrihKod : String[CStrihKod];
	  NSertif : LongInt;{Это поле указывает на код сертификата}
    RegionMarka: Word;
       BazKod  : LongInt;
       Employ  : Boolean;
	  End;



{Type SkladType1 = Record
     Kol         : Array[1..8] Of Word;
     Locked      : Boolean;
   End;}





{Type RemoteSkladType = Record
     BazKod      : Word;
     ArrayKol    : Array[1..MaxSkladKol] Of String[CKol];
     Employ      : Boolean;
   End;}


Type ExtSkladType = Record
     BazKod  : String[CArtikul];
     Input       : InputExtend;
   End;


Type BufSkladType = Record
     Dat : Array [1..BufferDB] Of SkladType;
End;


Type BufSkladTypeNew = Record
     Dat : Array [1..BufferDBNew] Of SkladTypeNew;
End;


Type BufExtSkladType = Record
     Dat : Array [1..BufferDBExt] Of ExtSkladType;
End;


Type PBufSkladType = ^BufSkladTypePtr;
     BufSkladTypePtr =Object(TObject)
     Point :BufSkladType;
     Constructor Init;
     Destructor Done; Virtual;
End;


Type PBufSkladTypeNew = ^BufSkladTypeNewPtr;
     BufSkladTypeNewPtr =Object(TObject)
     Point :BufSkladTypeNew;
     Constructor Init;
     Destructor Done; Virtual;
End;


Type PBufExtSkladType = ^BufExtSkladTypePtr;
     BufExtSkladTypePtr =Object(TObject)
     Point :BufExtSkladType;
     Constructor Init;
     Destructor Done; Virtual;
End;


Type
    PSkladType = ^SkladPtr;
    SkladPtr=Object(TObject)
    Dat  :  SkladType;
     Constructor Init;
     Destructor Done; Virtual;
 end;

Type
    PSkladTypeNew = ^SkladNewPtr;
    SkladNewPtr=Object(TObject)
    Dat  :  SkladTypeNew;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Type
    PExtSkladType = ^ExtSkladPtr;
    ExtSkladPtr=Object(TObject)
    Dat  :  ExtSkladType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


{Приход}
Type Postawshik=Record
     Numer : String[CName];     {номер накладной поставщика}
     Date  : TDateString;{дата накладной поставщика}
     End;


{Приход}
Type PrihodType = Record
     OperatorSelector:Word;
     MakeKod : String[CMakeKod];
     PrihodElement : Array[1..CMax] Of ElementP;
     Document : String[CDocNumer];
     DocumentPrz : String[CDocNumer]; {позиция в файле переоценки, а не номер акта переоценки
	                                  это две большие разницы}
     SummaL,SummaR,SummaO,
	SummaZakupka,SummaZakupka2,SummaAkzis,
	SummaZakupkaAverage : String[CIZena];
     SkladKod : String[CClientKod];
     Caption : String[CRazdelKod];
     DateC   : TDateString;
     TimeC   : TDateString;
     DateM   : TDateString;
     TimeM   : TDateString;
     Amount  : Word;
   StatusDoc : Word; {1 : Буфер; 0 :Документ попал на склад}
     Locked  : Boolean;
    Rekwizit : Postawshik;
 end;




Type
    PPrihodType = ^PrihodPtr;
    PrihodPtr=Object(TObject)
    Dat  :  PrihodType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Type RewisiaType = Record
        Element : Array[1..CMax] Of RewisiaElement;
        Document: String[CDocNumer];
        Itogo,ItogoPlus,ItogoMinus : String[CIZena];
        ItogoZ,ItogoPlusZ,ItogoMinusZ : String[CIZena];
        ItogoZ2,ItogoPlusZ2,ItogoMinusZ2 : String[CIZena];
        ItogoAkzis,ItogoAkzisPlus,ItogoAkzisMinus : String[CIZena];
        SkladKod: String[CClientKod];
        Caption : String [CRazdelKod];
        DateC   : TDateString;
        TimeC   : TDateString;
        DateM   : TDateString;
        TimeM   : TDateString;
        Comment : SertifStr;
        Amount  : Word;
        Locked  : Boolean;
        Tested  : Word;
   CaptionTested: String[CRazdelKod];
        DateT   : TDateString;
        TimeT   : TDateString;
 end;



Type
    PRewisiaType = ^RewisiaPtr;
    RewisiaPtr=Object(TObject)
    Dat  :  RewisiaType;
     Constructor Init;
     Destructor Done; Virtual;
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
     DocSelector    : Word;{0,1,2,5,7}
     {тип документа по новой классфикации продажи}
     MakeKod : String[CMakeKod];
     VozwratElement : Array[1..CMax] Of ReturnElement;
     Document : String[CDocNumer];
     DocumentPrz : String[CDocNumer];
     SummaAkzis,SummaO,SummaR,SummaZakupka,
	SummaZakupka2,
	SummaZakupkaAverage,Skidka : String[CIZena];
     PrevSummaZ,PrevSkidka,
	Delta,
	Delta2:String[CIZena];

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
{
Примечание
4 вида возврата (по расходникам)
1.возврат по продаже - расходник выдается на сумму возврата-сумма скидки возврата
2.возврат по закрытой консигнаци - расходник выдается на сумму возврата-сумма скидки возврата
3.возврат по открытой консигнации, причем долг по оплате документа
  превышает сумму возврата - расходник не выдается (он получается на нулевую сумму)
  в файл оплаты консигнации и персональный файл оплаты клиента пишется
  фиктивная оплата консигнации    на сумму возврата
4.возврат по открытой консигнации, причем долг по оплате документа
  меньше суммы возврата - расходник выдается на сумму равную:
      Расходник = сумма возврата-Сумма Долга по документу в настощее время
}
 end;



Type
     NewVozwratType1 = Record
     OperatorSelector: Word;
     VidDocument    : Word;
     DocSelector    : Word;{0,1,2,5,7}
     MakeKod : String[CMakeKod];
     Document : String[CDocNumer];
     DocumentPrz : String[CDocNumer];
     SummaAkzis,SummaO,SummaR,SummaZakupka,
	SummaZakupka2,
	Skidka : Real;
     SkladKod: String[CClientKod];
     Caption : String[CRazdelKod];
     DateC   : LongInt;
     TimeC   : LongInt;
     DateM   : LongInt;
     TimeM   : LongInt;
    BasisDoc : String[CDocNumer];
    BasisDate: LongInt;
      Opt    : Boolean;
    Rashod   : Boolean;{признак печати расходника}
  RashodSumma: Real;{велечина суммы расходника}
 end;


{Возврат новый в файле возврата клиента}
Type ClientNewVozwratType = Record
     Return : NewVozwratType1;
 end;


Type BufClientNewVozwratType = Record
     Dat : Array [1..BufferCVzw] Of ClientNewVozwratType;
End;



Type PBufClientNewVozwratType = ^BufClientNewVozwratTypePtr;
     BufClientNewVozwratTypePtr =Object(TObject)
     Point :BufClientNewVozwratType;
     Constructor Init;
     Destructor Done; Virtual;
End;




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






Type NewPrintIni = Record
     Printer  : Word;
     Orient   : Word;
     Port     : Word;
     SwapDisk : Word;
     Computer : AllStr;
     Ini      : AllStr;
    CopyPrihod: LongInt;
    CopyTTN   : LongInt;
    CopyPrz   : LongInt;
    CopySF    : LongInt;
    CopyNkl   : LongInt;
    CopyReturn: LongInt;
  FullSkidka   : Word;

  FullSertif   : Word;
  FullAkzis    : Word;
  FullExpert   : Word;
  FullGTD      : Word;
  FullAkzizDate: Word;

  FullName     : Word;
 PrintPhoto    : Word;
 PrilogenieNakl: Word;
 PrintTTN      : Word;
 PrintPrilogGTDTTN: Word;

  Messag       : Word;
  TimeStart    : TDateString;
  TimeStop     : TDateString;
  TextMessag   : String[35];
  ProtectScreen: Word;
  TimeProtectScreen: String[2];
  ScreenSaverName: String[CSertif];
        End;

Type
    PNewPrintIni = ^NewPrintIniPtr;
    NewPrintIniPtr=Object(TObject)
    Dat  :  NewPrintIni;
     Constructor Init;
     Destructor Done; Virtual;
 end;



{Поставщик}
(*
Type MakeType   = Record
Name     : String[CMAke];
FullName : String[CAll];
Dogovor  : String[CAll];
AdressF  : String[CAll];
{Punkt    : Array [1..4] Of String[CRazdelKod];}
{1 Павильоны} {2 Палатки} {3 Магазин} {4 Кафе}
Limit    : String[CIZena];
Lizo     : Word;
Adress   : String[CAll];
Telefon   : String[CAll];
R_Sh    : String[CAll];
Gde      : String[CAll];
Gorod    : String[CAll];
INN      : String[CAll];
OKONH    : String[CAll];
OKPO     : String[CAll];
Enviropment: String[CAll];
Svidetelstvo: String[CAll];{номер лицензии}
VekselIP: String[CAll];{в вексель именительный падеж}
VekselDP: String[CAll];{в вексель дательный падеж}
Seria   : String[CSeriaPassport];{серия паспорта}
Passport : String[CNumerPassport];{номер паспорта}
Vidan     :String[CAll];{кем выдан паспорт}
Messages  : String[CSertif];
Debit    : Word;
SrokLizensia : TDateString;
Kod      : String[CClientKod];
Employ   : Boolean;
Stat     : Boolean;
Locked   : Boolean;
LockCaption: String[CRAzdelKod];
ComputerNameLocked : String[CCNAme];
End;
*)

{Клиент}
Type ClientType = Record
Name     : String[CClient];
FullName : String[CAll];
Dogovor  : String[CAll];
AdressF  : String[CAll];
Limit    : String[CIZena];
Lizo     : Word;
Adress   : String[CAll];
Telefon  : String[CAll];
R_Sh       : String[CAll];
Gde        : String[CAll];
Gorod      : String[CAll];
INN        : String[CAll];
OKONH      : String[CAll];
OKPO       : String[CAll];
Enviropment: String[CAll];{номер лицензии}
Kto      : String[CAll];{кто выдал}
Svidetelstvo: String[CAll];{номер лицензии}
VekselIP : String[CAll];{в вексель именительный падеж}
VekselDP : String[CAll];{в вексель дательный падеж}
Seria    : String[CSeriaPassport];{серия паспорта}
Passport : String[CNumerPassport];{номер паспорта}
Vidan    : String[CAll];{кем выдан паспорт}
Messages : String[CSertif];
Otgruska : Word;
Debit    : Word;
SrokLizensia : TDateString;
RegionKod: String[CClientKod];
Kod      : String[CClientKod];
DateM    : longint;
Employ   : Boolean;
RCD      : Boolean;{признак репликации на другие объекты}
Locked   : Boolean;
LockCaption: String[CRAzdelKod];
ComputerNameLocked : String[CCNAme];
End;

{Клиент}
Type NewClientType = Record
Name     : String[CClient];{название клиента}
Main     : Word;          {признак подчиненности клиента 0-главный;1-дочерний}

FullName : String[CAll];  {Полное Юридическое название клиента}
Adress   : String[CAll];  {Юридический адрес}
Dogovor  : String[CAll];{номер договора}
Lizo     : Word;        {0-юр.лицо;1-физ.лицо}
INN        : String[CAll];{ИНН клиента}
Gorod      : String[CAll];{город}
Gde        : String[CAll];{банк клиента}
R_Sh       : String[CAll];{расчетный счет}
OKONH      : String[CAll];{ОКОНХ}
OKPO       : String[CAll];{ОКПО}
Svidetelstvo: String[CAll];{номер лицензии}
Enviropment: String[CAll];{номер лицензии}
Kto      : String[CAll];{кто выдал}
SrokLizensia : TDateString;{срок действия лицензии}
DocFiltr : Word; {фильтр документов отгразки (511)}

{}
Otgruska : Word; {разрешить отгрузки}
Debit    : Word; {разрешить консигнацию}
Status   : Word; {статус клиента по процессингу активен поссивен сб закр ?}

Limit    : String[CIZena];{потенциал - устанавливают коммерсанты}
VIP      : String[CIZena];{признак особой важности клиента
                           в нем(поле) устанавливается дополнительная отсрочка}
Telefon  : String[CAll];{телефон и контактные лица}
(* персональные данные для всех клиентов (даже если сетевик)*)
Period   : ArtikulStr;    {периодичность появления}
LastSverka : DAteString;

Seria    : String[CSeriaPassport];{серия паспорта}
Passport : String[CNumerPassport];{номер паспорта}
Vidan    : String[CAll];{кем выдан паспорт}
VekselIP : String[CAll];{в вексель именительный падеж}
VekselDP : String[CAll];{в вексель дательный падеж}
Messages : String[CSertif];{сообщение в карточке клиента}
AdressF  : String[CAll];{фактический адрес}
RegionKod: String[CClientKod];{код региона фактического адреса доставки}
RouteKod : String[CClientKod];{код маршрута}
ZenaKod  : String[CClientKod];{код шкалы цен пока не используется}
Kod      : String[CClientKod];{код клиента}
MainKod  : String[CClientKod];{Default│0000}
DateM    : longint;{дата модификации}
TimeM    : longint;{время модификации}
LastCaption: String[CRAzdelKod];{пользователь проводивший модификацию}
Employ   : Boolean;{признак использования кода}
RCD      : Boolean;{признак репликации на другие объекты}
Locked   : Boolean;{признак сетевой блокировки}
LockCaption: String[CRAzdelKod];{пользователь проводивший блокировку}
ComputerNameLocked : String[CCNAme];{компьютер проводивший последнюю блокировку}
End;


{│12│123456789012345678901234567890123456789012345│1234│123456789012345│}
Type BufClientType = Record
   Dat : Array[1..Buffer] Of ClientType;
End;


Type PClientType = ^ClientPtr;
     ClientPtr =Object(TObject)
     Dat : ClientType;
     Constructor Init;
     Destructor Done; Virtual;
     End;

Type PBufClientType = ^BufClientPtr;
     BufClientPtr =Object(TObject)
     Point :BufClientType;
     Constructor Init;
     Destructor Done; Virtual;
End;

Type CommentClientType = Record
 Memo  :TMemoData;
 Memo1 :TMemoData;
  Srok  : TDateString;
Caption : String[CRAzdelKod];
  Date  : TDateString;
  Time  : TDateString;
 Active : Boolean;
End;


Type
    PCommentClientType = ^CommentClientTypePtr;
    CommentClientTypePtr=Object(TObject)
    Dat  :  CommentClientType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


{Раздел}
Type RazdelType = Record
      Name       : String[CRazdelName];
     {Designation: String[CDate];}
      EnableDoc  : Word;{флаг предназначен для того чтобы
                         распознать для чего используется
     			     раздел}
      EnableLitr : Word;
      Skidka     : Array [1..CShkala] of Shkala;
      Kod        : String[CRazdelKod];
      Employ     : Boolean;
      Locked     : Boolean;
     End;

Type
    PRazdelType = ^RazdelTypePtr;
    RazdelTypePtr=Object(TObject)
    Dat  :  RazdelType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Type BufRazdelType = Record
   Dat : Array[1..BufferRazdel] Of RazdelType;
End;


Type PBufRazdelType = ^BufRazdelPtr;
     BufRazdelPtr =Object(TObject)
     Point :BufRazdelType;
     Constructor Init;
     Destructor Done; Virtual;
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


Type DocumentEdit = Record
      Vid : Word;
      EditPosition : String[CDocNumer];
      D   : String[CDate];
      End;

Type DocumentEditZ = Record
      Vid : Word;
      EditPosition : ArtikulStr;
      D   : String[CDate];
      End;


Type DocumentView = Record
      Vid : Word;
      D   : String[CDate];
      End;

{за каждый день свой файл прихода расхода}
Type KassaOperation = Record
      NAme     : String[CClient];{название операции}
      Status   : Word;{0-расход из кассы 1-поступления в кассу}
      Employ   : Boolean;
      Kod      : String[CClientKod];{код операции}
     End;

(*
{за каждый день свой файл прихода расхода}
Type ItogKassa = Record
      Kod      : String[CClientKod];{код операции}
      DateC    : LongInt;
      TimeC    : LongInt;
      Summa    : Double;
      Caption  : String[CRAzdelKod];
      SkladKod : String[CClientKod];
     End;

Type
    PItogKAssa = ^ItogKAssaPtr;
    ItogKassaPtr=Object(TObject)
    Dat  :  ItogKasa;
     Constructor Init;
     Destructor Done; Virtual;
 end;
*)



Type TSystemReestr=Record
      Name : String [CKto];
    LoginNT: String [CKto];
  Password : String[CInputILitr];
  Password2 : String[CInputILitr];
  kbPrefix : Word;
      Lock : Word;
      Srok : Word;
   EndSrok : Word;
 Changepwd : Word;
 UserRights: TUserRight;
    Employ : Boolean;
      Date : LongInt;{дата регистрации пароля}
      Kod  : String [CRazdelKod];
      End;


Type
    PSystemReestr = ^SystemReestrPtr;
    SystemReestrPtr=Object(TObject)
    Dat  :  TSystemReestr;
     Constructor Init;
     Destructor Done; Virtual;
 end;




Type TSystemReestrDisk=Record
      Name  : TNAme;
    LoginNT : TNAme;
  Password  : TPassword;
  Password2 : TPassword;
  kbPrefix  : Word;
      Lock  : Word;
   EndSrok  : Word;
      Srok  : Word;
 Changepwd  : Word;
 UserRights : TUSerRight;
      Date  : LongInt;{дата регистрации пароля}
    Employ  : Boolean;
      Kod   : Word;
      End;



Type
    PSystemReestrDisk = ^SystemReestrDiskPtr;
    SystemReestrDiskPtr=Object(TObject)
    Dat  :  TSystemReestrDisk;
     Constructor Init;
     Destructor Done; Virtual;
 end;





(*
Type BAkKassaType = Record
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
{30}                      OstatokBarter : String[CIZENA];
{30}                       BarterPrihod : String[CIZENA];
{30}                     BarterPrihodRZ : String[CIZENA];
{30}                            BarterT : String[CIZENA];
{31}                       BarterSkidki : String[CIZENA];
{33}                      BarterInKassa : String[CIZENA];
{33}                     BarterOutKassa : String[CIZENA];
{30,31,32,33,34,35,36}
   PerewoskiOut : Array[0..4] Of String[CIZena];{входящие перевозки}
{37,38,39,40,41,42}
   PerewoskiInp : Array[0..4] Of String[CIZena];{исходящие перевозки}
{Эти поля не фигурируют на экране}

   EPerewoskiOut : String[CIZENA];
   EPerewoskiInp : String[CIZENA];
   CAption       : String[CRazdelKod];
   DAteC,TimeC,DateM,TimeM:TDateString;
   End;
*)



{

Type ItogType = Record
     BazKod : String[CArtikul];(**)
     Ost    : String[CKol];    (**)
     MrkC   : String[CKol];
     MrkS   : String[CKol];
     MrkB   : String[CKol];
     OstE   : String[CIZena];  (**)
     MrkEC  : String[CIZena];
     MrkES  : String[CIZena];
     MrkEB  : String[CIZena];
     End;


Type PItogType = ^ItogTypePtr;
   ItogTypePtr = Object(TObject)
     Dat : ItogType;
     Constructor Init;
     Procedure Refresh;
     Destructor Done; Virtual;
     End;
}


(*
Type NewItogType = Record
     BazKod : String[CArtikul];
     Ost    : String[CKol];
     OstE   : String[CIZena];
     OstEZ  : String[CIZena];
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
*)

Type NewItogType = Record
     BazKod : String[CArtikul];(**)
     Ost    : String[CKol];    (**)
     OstDiv : Array [1..CDivision] Of LongInt;

     OstE   : Double;  (**)
     OstEZ  : Double;  (**){ZakupkaList}
     OstEZ2 : Double;  {закупка 2}{ZakupkaList}

     NMakeKod: ArtikulStr;

     PrhC   : String[CKol];
     PrhS   : String[CKol];
     PrhB   : String[CKol];

     PrhEC   : Double;{розниц а}{RashetList}
     PrhECZ  : Double;{закупка}{1}{RAshetList2}
     PrhECZ2 : Double;{закупка2}{2}{RAshetList2}

     PrhES   : Double;            {RAshetList}
     PrhESZ  : Double;{закупка}{3}{RAshetList2}
     PrhESZ2 : Double;{закупка2}{4}{RAshetList2}

     PrhEB   : Double;            {RAshetList}
     PrhEBZ  : Double;{закупка}{5}{RAshetList2}
     PrhEBZ2 : Double;{закупка2}{6}{RAshetList2}

     MrkC   : String[CKol];
     MrkCDiv: Array [1..CDivision] Of LongInt;

     MrkS   : String[CKol];
     MrkSDiv: Array [1..CDivision] Of LongInt;

     MrkB   : String[CKol];
     MrkBDiv: Array [1..CDivision] Of LongInt;

     MrkEC   : Double;{к оплате}{14}{RAshetList}
     MrkECOpl: Double;{к оплате}{7}{RAshetList2}
     MrkECZ  : Double;{закупка}{8}{RAshetList2}
     MrkECZ2 : Double;{закупка2}{9}{RAshetList2}

     MrkES   : Double;             {RAshetList}
     MrkESZ  : Double;{закупка}{10}{RAshetList2}
     MrkESZ2 : Double;{закупка 2}{11}{RAshetList2}

     MrkEB   : Double;               {RAshetList}
     MrkEBZ  : Double;{закупка}{12}  {RAshetList2}
     MrkEBZ2 : Double;{закупка 2}{13}{RAshetList2}

     MrkOptC    : String[CKol];
     MrkOptRZC  : Double;{продажа в оптом по лобовым ценам}
    MrkOptCOpl  : Double;{продажа в оптом по ценам к оплате}
    MrkOptCZZ   : Double;{продажа в оптом по ценам закупка для бухгалтерии}
    MrkOptCZZ2  : Double;{продажа в оптом по ценам закупка 2}

     MrkRoznC   : String[CKol];
     MrkRoznRZC : Double;{продажа в розницу по лобовым ценам}
    MrkRoznCOpl : Double;{продажа в розницу по ценам к оплате}
    MrkRoznCZZ  : Double;{продажа в розницу по ценам закупка для бухгалтерии}
    MrkRoznCZZ2 : Double;{продажа в розницу по ценам закупка 2}

     MrkOptB    : String[CKol];
     MrkOptRZB  : Double;{продажа в оптом по лобовым ценам}
    MrkOptBOpl  : Double;{продажа в оптом по ценам к оплате}
    MrkOptBZZ   : Double;{продажа в оптом по ценам закупка для бухгалтерии}
    MrkOptBZZ2  : Double;{продажа в оптом по ценам закупка 2}

     MrkRoznB   : String[CKol];
     MrkRoznRZB : Double;{продажа в розницу по лобовым ценам}
    MrkRoznBOpl : Double;{продажа в розницу по ценам к оплате}
    MrkRoznBZZ  : Double;{продажа в розницу по ценам закупка для бухгалтерии}
    MrkRoznBZZ2 : Double;{продажа в розницу по ценам закупка 2}

     RewKol  : String[CKol+1];
     RewRZ   : Double;
     RewZZ   : Double;
     RewZZ2  : Double;

     ReturnOptKol  : String[CKol];
     ReturnOptOpl  : Double;
     ReturnOptRZ   : Double;
     ReturnOptZZ   : Double;
     ReturnOptZZ2  : Double;

     ReturnRoznKol : String[CKol];
     ReturnRoznOpl : Double;
     ReturnRoznRZ  : Double;
     ReturnRoznZZ  : Double;
     ReturnRoznZZ2 : Double;
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









{1} Type ClientFileType           = File Of ClientType;
{1} Type KurzClientFileType       = File Of KurzClientType;
{2}{Type MakeFileType             = File Of MakeType;}
{3} Type SkladFileType            = File Of SkladType;
{3} Type ExtSkladFileType         = File Of ExtSkladType;
{4} Type BazFileType              = File Of BazType;
{5} Type PrihodFileType           = File Of PrihodType;
{6} Type MarketFileType           = File Of SuperMarketType;
{6} Type MarketFileTypeIDX        = File Of SuperMarketTypeIDX;
{6} Type TransportFileType        = File Of TransportType;
{6} Type RazdelFileType           = File Of RazdelType;
{6} Type IndexFileType            = File Of IndexType;
{6} Type ZakazFileType            = File Of ZakazType;
{6} Type HeaderZakazFileType      = File Of HeaderZakazType;
{7} Type NewVozwratFileType       = File Of NewVozwratType;
{7} Type NewVozwratFileType1      = File Of NewVozwratType1;
{8} Type PereozenkaFileType       = File Of PereozenkaType;
{9} Type RewisiaFileType          = File Of RewisiaType;
{10}Type SkidkaFileType           = File Of SkidkaType;
{11}Type OplataRealizasiaFileType = File Of OplataRealizasiaType;
{13}Type OplataBarterFileType     = File Of OplataBarter;
    Type BarterClientFileType     = File Of BarterClientType;
    Type RegionFileType           = File Of RegionType;
    Type GroupFileType            = File Of GroupType;
    Type RouteFileType            = File Of RouteType;
    Type PostFileType             = File Of PostType;
    Type FirmaPostFileType        = File Of FirmaPostType;
    Type KSertifFileType          = File Of KSertifType;



    Type AkzisKoeffizient = Array [0..8] Of String[CZenaZ];

{!!!!!!  Var !!!!!!!!!!}
Var
     {FileName: String;}
     FDate,TekDate :  TDateString;
    NewItogFile  : File Of NewItogType;
    NItg : PNewItogType;


     {Print : PrintIni;}
     Path  : PDistantion;
     PathExpImp:PDistantionExpImp;
     NPrint :PNewPrintIni;
     Rek,RekSF,RekComissioner : PRekwiziti;
     EditPosition : LongInt;
     Assistent : {DocumentEdit}DocumentEditZ;
     AssistentZ : DocumentEditZ;
     AssistentView : DocumentView;
     DateMask : TDateString;
     TimeMask : TDateString;
     PrihodMax,Lizensia : Real;
     Wzlom : Boolean;
     SkayScreen: Word;
     GlobalReadOnly:Word;
     EnableBron,Compress,Status,EditMode,
	ZakazShema : Word;
     CurrentPassword : String[CKto];
     LastSkladKod : ArtikulStr;
     ClientRP:String[CCLientKod];
     ZeniInZakaz : Word;
     InputZakaz : Word;{указывает на режим работы окна продажи (продажа или заказ)}
     AnsverGlobal,GlobalShow,ProdagaWindow,Show,ShowMsg,ShowMsgCopy,ShowNetMsg: Boolean;
     GlobalSkladsName: TMyString;
     GlobalOperatorNAme: AllStr;
     Interval,GlobalTime,GlobalTimeMsg,GlobalTimeMsg1 : LongInt;
     NetComputerNAme: AllStr;
     EnablePril,EnableSpravka: Set of Byte;
     SignalFile : File;
     EnableSpisanie,DisableOtgruzkaSertif,ControlPricePosition,EnableSound,
	AutoMarket : Word;
     DefaultSetMArker,EnableAutoSHK,EnableSHK,RemoteProtocol,
	EnableOtkat,RemoteAccess,PrihodFromClient,EnablePeremeshenie,FiktivSkidka,
     DisableCLose,DisableProtocol,EnableNewTovar,EnableHandZeni,EnableAntiLock,
     RegimOtsheta,AllSklads,AverageOtdel,EnableAverageOtdel,EnableImport,
	EnableZakupka,EnablePosVersion,EnableOtdel,ShemaAkzis,OnlyOneCopy: Word;
     SetEnableOtdel : Set of Byte;
     YesMarker,NoMarker : String[CONe];
     AkzisKoeff : AkzisKoeffizient;




Implementation

{$IfNDEF DPMI}
Uses Overlay;
{$EndIF}

{
Constructor ItogTypePtr.Init ;
Begin
TObject.Init;
With Dat Do
 Begin
     BazKod[0]:=#0;
     Ost[0]:=#0;
     MrkC[0]:=#0;
     MrkS[0]:=#0;
     MrkB[0]:=#0;
     OstE[0]:=#0;
     MrkEC[0]:=#0;
     MrkES[0]:=#0;
     MrkEB[0]:=#0;
 End;
End;


Procedure ItogTypePtr.Refresh ;
Begin
With Dat Do
 Begin
     BazKod[0]:=#0;
     Ost[0]:=#0;
     MrkC[0]:=#0;
     MrkS[0]:=#0;
     OstE[0]:=#0;
     MrkEC[0]:=#0;
     MrkES[0]:=#0;
 End;
End;
}

Constructor NewItogTypePtr.Init ;
VAr c : Byte;
Begin
TObject.Init;
With Dat Do
 Begin
     BazKod[0]:=#0;
     Ost[0]:=#0;
     PrhC[0]:=#0;
     PrhS[0]:=#0;
     PrhB[0]:=#0;
     PrhEC:=0;
     PrhES:=0;
     PrhEB:=0;
     MrkC[0]:=#0;
     MrkS[0]:=#0;
     MrkB[0]:=#0;
     OstE:=0;
     MrkEC:=0;
     MrkEs:=0;
     MrkEB:=0;
     OstEZ  :=0;  (**){ZakupkaList}
     OstEZ2 :=0;
     PrhECZ :=0;
     PrhECZ2 :=0;
     PrhESZ  :=0;
     PrhESZ2 :=0;
     PrhEBZ  :=0;
     PrhEBZ2 :=0;
     MrkECOpl :=0;
     MrkECZ   :=0;
     MrkECZ2  :=0;
     MrkESZ   :=0;
     MrkESZ2  :=0;
     MrkEBZ   :=0;
     MrkEBZ2  :=0;

     MrkRoznC[0]:=#0;
     MrkRoznRZC:=0;
    MrkRoznCOpl:=0;
    MrkRoznCZZ :=0;
    MrkRoznCZZ2:=0;
     MrkOptC   [0]:=#0;
     MrkOptRZC :=0;
    MrkOptCOpl :=0;
    MrkOptCZZ  :=0;
    MrkOptCZZ2 :=0;

     MrkRoznB  [0]:=#0;
     MrkRoznRZB:=0;
    MrkRoznBOpl:=0;
    MrkRoznBZZ :=0;
    MrkRoznBZZ2:=0;
     MrkOptB   [0]:=#0;
     MrkOptRZB :=0;
    MrkOptBOpl :=0;
    MrkOptBZZ  :=0;
    MrkOptBZZ2 :=0;

     MrkEC   :=0;

     RewKol  [0]:=#0;
     RewRZ   :=0;
     RewZZ   :=0;
     RewZZ2  :=0;

     ReturnOptKol[0]:=#0;
     ReturnOptOpl:=0;
     ReturnOptRZ :=0;
     ReturnOptZZ :=0;
     ReturnOptZZ2:=0;

     ReturnRoznKol[0]:=#0;
     ReturnRoznOpl:=0;
     ReturnRoznRZ :=0;
     ReturnRoznZZ :=0;
     ReturnRoznZZ2:=0;

     For c:=1 To CDivision Do
	 Begin
       OstDiv[c]:=0;
       MrkCDiv[c]:=0;
       MrkSDiv[c]:=0;
       MrkBDiv[c]:=0;
	 End;
     NMakeKod[0]:=#0;
 End;
End;

Procedure NewItogTypePtr.Refresh ;
Var c : Word;
Begin
With Dat Do
 Begin
     BazKod[0]:=#0;
     Ost[0]:=#0;
     PrhC[0]:=#0;
     PrhS[0]:=#0;
     PrhB[0]:=#0;
     PrhEC:=0;
     PrhES:=0;
     PrhEB:=0;
     MrkC[0]:=#0;
     MrkS[0]:=#0;
     MrkB[0]:=#0;
     OstE:=0;
     MrkEC:=0;
     MrkEB:=0;
     OstEZ  :=0;  (**){ZakupkaList}
     OstEZ2 :=0;
     PrhECZ :=0;
     PrhECZ2 :=0;
     PrhESZ  :=0;
     PrhESZ2 :=0;
     PrhEBZ  :=0;
     PrhEBZ2 :=0;
     MrkECOpl :=0;
     MrkECZ   :=0;
     MrkECZ2  :=0;
     MrkESZ   :=0;
     MrkESZ2  :=0;
     MrkEBZ   :=0;
     MrkEBZ2  :=0;
     MrkRoznC[0]:=#0;
     MrkRoznRZC:=0;
    MrkRoznCOpl:=0;
    MrkRoznCZZ :=0;
    MrkRoznCZZ2:=0;
     MrkOptC   [0]:=#0;
     MrkOptRZC :=0;
    MrkOptCOpl :=0;
    MrkOptCZZ  :=0;
    MrkOptCZZ2 :=0;

     MrkRoznB  [0]:=#0;
     MrkRoznRZB:=0;
    MrkRoznBOpl:=0;
    MrkRoznBZZ :=0;
    MrkRoznBZZ2:=0;
     MrkOptB   [0]:=#0;
     MrkOptRZB :=0;
    MrkOptBOpl :=0;
    MrkOptBZZ  :=0;
    MrkOptBZZ2 :=0;

     RewKol  [0]:=#0;
     RewRZ   :=0;
     RewZZ   :=0;
     RewZZ2  :=0;

     ReturnOptKol[0]:=#0;
     ReturnOptOpl:=0;
     ReturnOptRZ :=0;
     ReturnOptZZ :=0;
     ReturnOptZZ2:=0;

     ReturnRoznKol[0]:=#0;
     ReturnRoznOpl:=0;
     ReturnRoznRZ :=0;
     ReturnRoznZZ :=0;
     ReturnRoznZZ2:=0;

     For c:=1 To CDivision Do
	 Begin
       OstDiv[c]:=0;
       MrkCDiv[c]:=0;
       MrkSDiv[c]:=0;
       MrkBDiv[c]:=0;
	 End;
     NMakeKod[0]:=#0;
 End;
End;

Destructor NewItogTypePtr.Done;
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
     PrhEC:=0;
     PrhES:=0;
     PrhEB:=0;
     MrkC[0]:=#0;
     MrkS[0]:=#0;
     MrkB[0]:=#0;
     OstE:=0;
     MrkEC:=0;
     MrkEs:=0;
     MrkEB:=0;
     OstEZ  :=0;  (**){ZakupkaList}
     OstEZ2 :=0;
     PrhECZ :=0;
     PrhECZ2 :=0;
     PrhESZ  :=0;
     PrhESZ2 :=0;
     PrhEBZ  :=0;
     PrhEBZ2 :=0;
     MrkECOpl :=0;
     MrkECZ   :=0;
     MrkECZ2  :=0;
     MrkESZ   :=0;
     MrkESZ2  :=0;
     MrkEBZ   :=0;
     MrkEBZ2  :=0;

     MrkRoznC[0]:=#0;
     MrkRoznRZC:=0;
    MrkRoznCOpl:=0;
    MrkRoznCZZ :=0;
    MrkRoznCZZ2:=0;
     MrkOptC   [0]:=#0;
     MrkOptRZC :=0;
    MrkOptCOpl :=0;
    MrkOptCZZ  :=0;
    MrkOptCZZ2 :=0;

     MrkRoznB  [0]:=#0;
     MrkRoznRZB:=0;
    MrkRoznBOpl:=0;
    MrkRoznBZZ :=0;
    MrkRoznBZZ2:=0;
     MrkOptB   [0]:=#0;
     MrkOptRZB :=0;
    MrkOptBOpl :=0;
    MrkOptBZZ  :=0;
    MrkOptBZZ2 :=0;

     MrkEC   :=0;

     RewKol  [0]:=#0;
     RewRZ   :=0;
     RewZZ   :=0;
     RewZZ2  :=0;

     ReturnOptKol[0]:=#0;
     ReturnOptOpl:=0;
     ReturnOptRZ :=0;
     ReturnOptZZ :=0;
     ReturnOptZZ2:=0;

     ReturnRoznKol[0]:=#0;
     ReturnRoznOpl:=0;
     ReturnRoznRZ :=0;
     ReturnRoznZZ :=0;
     ReturnRoznZZ2:=0;

     For c:=1 To CDivision Do
	 Begin
       OstDiv[c]:=0;
       MrkCDiv[c]:=0;
       MrkSDiv[c]:=0;
       MrkBDiv[c]:=0;
	 End;
     NMakeKod[0]:=#0;
 End;
End;{For}
End;

Destructor BufNewItogTypePtr.Done;
Begin
TObject.Done;
End;


Constructor SystemReestrPtr.Init;
Var c:Word;
Begin
TObject.Init;
With Dat Do
 Begin
      Name[0] :=#0;
      LoginNT[0]:=#0;
  Password[0] :=#0;
  Password2[0] :=#0;
      kbPrefix :=0;
      Lock :=0;
      EndSrok:=0;
      Srok :=0;
 Changepwd :=0;
    Employ :=False;
      Kod [0] :=#0;
      For c:=1 To MaxUserRight Do UserRights[c]:=0;
      Date:=DateStringToDAte(DAteMask,FDAte);
 End;
End;

Destructor SystemReestrPtr.Done;
Begin
TObject.Done;
End;

Constructor SystemReestrDiskPtr.Init;
Var c:Word;
Begin
TObject.Init;
With Dat Do
 Begin
      For c:=1 To CKto Do Name[c]:=0;
      For c:=1 To CKto Do LoginNT[c]:=0;
      For c:=1 To CPAssword Do Password[c] :=0;
      For c:=1 To CPAssword Do Password2[c] :=0;
      Lock :=0;
      kbPrefix :=0;
      Srok :=0;
      EndSrok:=0;
 Changepwd :=0;
      For c:=1 To MaxUserRight Do UserRights[c]:=0;
      Date:=DateStringToDAte(DAteMask,FDAte);
    Employ :=False;
      Kod  :=0;
 End;
End;

Destructor SystemReestrDiskPtr.Done;
Begin
TObject.Done;
End;




{
Destructor ItogTypePtr.Done;
Begin
TObject.Done;
End;
}

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
{$IFNDEF Converter}
        SkladKod:=FormKod(Rek^.Dat.Kod);{признак склада}
{$ENDIF}
        Vid:=0;
        Caption :=CurrentPassword;{признак оператора}
        SummaZ  [0]:=#0;  {сумма по документу к оплате}
        Rashet  :=0;{вид расчета только для поступления в кассу 0-нал}
        Comment [0]:=#0;
        Bn.DAte[0]:=#0;
        Bn.NPlat[0]:=#0;
        Bn.Bank[0]:=#0;
        Bn.Summa[0]:=#0;
        Active  :=True;
 End;
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
        SENalog[0]:=#0;
        SNalog5[0]:=#0;
        SNalog3[0]:=#0;
        SNalog_[0]:=#0;
{сальдо считается по приходу:  закупка *(-1)+
                  по расходу:  к оплате +
			                выдача из кассы
						 поступления в кассу *(-1)}
        {расход}
        SummaZ[0]:=#0;
        Skidka[0]:=#0;
    SummaZakupka[0]:=#0;
    SummaZakupka2[0]:=#0;

      SertifSummaZ[0]:=#0;
      SertifSkidka[0]:=#0;
SertifSummaZakupka[0]:=#0;
SertifSummaZakupka2[0]:=#0;
        {приход}
        PSumma[0]:=#0;
   PSummaZakupka[0]:=#0;
   PSummaZakupka2[0]:=#0;
        {выдача из кассы}
        Vidano[0]:=#0;
        {поступления в кассу}
        Priniato[0]:=#0;

        Comment[0]:=#0;

        Rashet:=0;{вид расчета только для поступлений в кассу}
        Bn.DAte[0]:=#0;
        Bn.NPlat[0]:=#0;
        Bn.Bank[0]:=#0;
        Bn.Summa[0]:=#0;

{$IFNDEF Converter}
        SkladKod:=FormKod(Rek^.Dat.Kod);
{$ENDIF}
        Caption :=CurrentPAssword;
        Active  :=True;
End;
End;

Destructor BarterClientPtr.Done;
Begin
TObject.Done;
End;






Constructor NewPrintIniPtr.Init;
Begin
TObject.Init;
With Dat Do
 Begin
     Printer  :=0;
     Orient   :=0;
     Port     :=0;
     SwapDisk :=0;
     Computer [0]:=#0;
     Ini      [0]:=#0;
    CopyPrihod:=0;
    CopyTTN :=0;
    CopyPrz   :=0;
    CopySF    :=0;
    CopyNkl   :=0;
    CopyReturn:=0;
  FullSkidka  :=0;
  FullSertif  :=0;
  FullAkzis   :=0;
  FullName    :=0;
  FullGTD     :=0;
  FullExpert  :=0;
  FullAkzizDate:=0;
  Messag       :=0;
  TimeStart    :='';
  TimeStop     :='';
  TextMessag   :='';
  ProtectScreen:=0;
  TimeProtectScreen:='';
  ScreenSaverName[0]:=#0;
  FullName     :=0;
 PrilogenieNakl:=0;
 PrintTTN      :=0;
 PrintPhoto    :=0;
 PrintPrilogGTDTTN:=0;

 End;
End;

Destructor NewPrintIniPtr.Done;
Begin
TObject.Done;
End;






Constructor ClientTovarTypePtr.Init;
Var j : Byte;
Begin
TObject.Init;
With Dat Do
 Begin
        ClientKod[0] :=#0;
        AgentKod [0] :=#0;
        DocSelector :=0;
        Document[0] :=#0;
        DateC[0] :=#0;
        TimeC[0] :=#0;
        Amount:=0;
        Active :=False;
{$IFNDEF Converter}
        SkladKod:=FormKod(Rek^.Dat.Kod);;
{$ENDIF}
        For j:=1 To CMax Do
        Begin
         Element[j].BazKod[0] :=#0;
         Element[j].Kol[0] :=#0;
        End;
 End;
End;


Destructor ClientTovarTypePtr.Done;
Begin
TObject.Done;
End;


Constructor LAstClientTovarTypePtr.Init;
Var j : Byte;
Begin
TObject.Init;
With Dat Do
 Begin
        ClientKod[0] :=#0;
        AgentKod [0] :=#0;
        DocSelector :=0;
        SkidkaSelector :=0;
        Document[0] :=#0;
        DateC :=DateStringToDAte(DateMAsk,FDAte);
        Amount:=0;
        Active :=False;
{$IFNDEF Converter}
        SkladKod:=FormKod(Rek^.Dat.Kod);;
{$ENDIF}
        For j:=1 To CMax Do
        Begin
         Element[j].BazKod[0] :=#0;
         Element[j].Kol :=0;
         Element[j].Zena :=0;
         Element[j].Zakupka :=0;
        End;
 End;
End;


Destructor LastClientTovarTypePtr.Done;
Begin
TObject.Done;
End;


Constructor BufClientTovarTypePtr.Init;
Var j,i : Byte;
Begin
TObject.Init;
For i:=1 To BufferTST Do
Begin
With Point.Dat[i] Do
 Begin
        ClientKod[0] :=#0;
        AgentKod [0] :=#0;
        DocSelector :=0;
        Document[0] :=#0;
        DateC[0] :=#0;
        TimeC[0] :=#0;
        Amount:=0;
        Active :=False;
{$IFNDEF Converter}
        SkladKod:=FormKod(Rek^.Dat.Kod);;
{$ENDIF}
        For j:=1 To CMax Do
        Begin
         Element[j].BazKod[0] :=#0;
         Element[j].Kol[0] :=#0;
        End;
 End;
End;{For}
End;


Destructor BufClientTovarTypePtr.Done;
Begin
TObject.Done;
End;

Constructor BufLastClientTovarTypePtr.Init;
Var j,i : Byte;
Begin
TObject.Init;
For i:=1 To BufferLastToVar Do
Begin
With Point.Dat[i] Do
 Begin
        ClientKod[0] :=#0;
        AgentKod [0] :=#0;
        Skidkaselector:=0;
        DocSelector :=0;
        Document[0] :=#0;
        DateC :=DateStringToDAte(DateMAsk,FDAte);
        Amount:=0;
        Active :=False;
{$IFNDEF Converter}
        SkladKod:=FormKod(Rek^.Dat.Kod);;
{$ENDIF}
        For j:=1 To CMax Do
        Begin
         Element[j].BazKod[0] :=#0;
         Element[j].Kol :=0;
         Element[j].Zena :=0;
         Element[j].Zakupka :=0;
        End;
 End;
End;{For}
End;


Destructor BufLastClientTovarTypePtr.Done;
Begin
TObject.Done;
End;


Constructor PrihodPtr.Init ;
Var i,j : Byte;
Begin
TObject.Init;
{Writeln('есть память');}
 Dat.Locked:=False;
 For i:=1 To CMax Do
  Begin
   {обнуляется приход}
  With Dat.PrihodElement[i].Input Do
   Begin
   USD    :=0;
   GRZena [0]:=#0;
   Proz[0]:=#0;
   Zakupka[0]:=#0;
   Zakupka2[0]:=#0;
  ZakupkaS[0]:=#0;
  NMakeKod:='00000';
  NGroupKod:='0000';
       Kol[0]:=#0;
    R_Zena[0]:=#0;
    O_Zena[0]:=#0;
     NSertif[0] :=#0;
     Akzis1 [0] :=#0;
       NGTD [0] :=#0;
    StrihKod[0] :=#0;
       Post [0] :=#0;
  FirmaPost [0] :=#0;
	  Marka[0] :=#0;
   SpecMarka[0] :=#0;
  Virabotano[0] :=#0;
     Godnost[0] :=#0;
     RegionMArka:=0;
     AkzisSbor[0]:=#0;
     ZenaMarki[0]:=#0;
     Ex[0]:=#0;


   For j:=1 To CDivision Do Division[j,0]:=#0;
   Auto:=False;
   End;
   With Dat.PrihodElement[i] Do
   Begin
     BazKod[0]:=#0;
   End;
  End;
  {Writeln('массив заполнен');}
  With Dat Do
  Begin
     OperatorSelector:=0;
     MakeKod[0]:=#0;
     Document[0]:=#0;
     DocumentPrz[0]:=#0;
     SummaL[0]:=#0;
     DateC[0]:=#0;
     TimeC[0]:=#0;
     DateM:=FDate;
     TimeM:=CurrentTimeString('hh:mm:ss');
     SummaAkzis[0]:=#0;
     SummaR[0]:=#0;
     SummaO[0]:=#0;
     SummaZakupka[0]:=#0;
     SummaZakupka2[0]:=#0;
     SummaZakupkaAverage[0]:=#0;
     Caption:=CurrentPassword;
{$IFNDEF Converter}
     SkladKod:=FormKod(Rek^.Dat.Kod);
{$ENDIF}
     Amount:=0;
     Rekwizit.Numer[0]:=#0;
     Rekwizit.Date[0]:=#0;
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
    R_Zena[0]:=#0;
    O_Zena[0]:=#0;
   Zakupka[0]:=#0;
  Zakupka2[0]:=#0;
 AkzisSbor[0]:=#0;
     {
     NSertif[0] :=#0;
     DSertif[0] :=#0;
     KSertif[0] :=#0;
     Akzis1 [0] :=#0;}
{
Sertifikat[0]:=#0;
     Akzis[0]:=#0;
}
   For j:=1 To CDivision Do Division[j,0]:=#0;
   Auto:=False;
   End;
   With Dat.Element[i] Do
   Begin
        BazKod[0]:=#0;
        Dat.Document[0]:=#0;
        Dat.Itogo[0]:=#0;
        Dat.ItogoZ[0]:=#0;
        Dat.DateC[0]:=#0;
        Dat.TimeC[0]:=#0;
        Dat.DateM:=FDate;
        Dat.TimeM:=CurrentTimeString('hh:mm:ss');
        Dat.Comment[0] :=#0;
        Dat.ItogoPlus[0]:=#0;
        Dat.ItogoMinus[0]:=#0;
        Dat.ItogoAkzisPlus[0]:=#0;
        Dat.ItogoAkzisMinus[0]:=#0;
        Dat.ItogoAkzis[0]:=#0;
        Dat.ItogoPlusZ[0]:=#0;
        Dat.ItogoMinusZ[0]:=#0;
        DAt.Caption:=CurrentPassword;
{$IFNDEF Converter}
        DAt.SkladKod:=FormKod(Rek^.Dat.Kod);
{$ENDIF}
        Dat.Amount:=0;
        Dat.Tested:=1;
        Dat.CaptionTested[0]:=#0;
        Dat.DateT[0]:=#0;
        Dat.TimeT[0]:=#0;

   End;
  End;
End;

Destructor RewisiaPtr.Done;
Begin
TObject.Done;
End;


Constructor NewVozwratPtr.Init ;
Var i,j : Word;
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
 SummaZakupka2[0]:=#0;
 SummaAkZis[0]:=#0;
 ENalog[0]:=#0;
 Nalog5[0]:=#0;
 Nalog3[0]:=#0;
 Nalog_[0]:=#0;
 SummaZakupkaAverage[0]:=#0;


 PrevSummaZ[0]:=#0;
 PrevSkidka[0]:=#0;
 Delta[0]:=#0;
 Delta2[0]:=#0;
 DateC[0]:=#0;
 TimeC[0]:=#0;
 DateM:=FDate;
 TimeM:=CurrentTimeString('hh:mm:ss');
 Caption:=CurrentPassword;
{$IFNDEF Converter}
 SkladKod:=FormKod(Rek^.Dat.Kod);
{$ENDIF}
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
       Input.Grammi [0] :=#0;
       input.R_Zena[0]:=#0;
       input.Zena[0]:=#0;
       input.O_Zena[0]:=#0;
       Input.LocalSkidka[0]:=#0;
       input.Zakupka[0]:=#0;
       input.Zakupka2[0]:=#0;
       input.ZakupkaS[0]:=#0;

       input.NDS[0]:=#0;

       input.VidNalog:=2;
       input.RegionMarka:=0;

       Input.SpecNAlog[0]:=#0;
       Input.AkzisSbor[0]:=#0;
       Input.Division[0]:=#0;
       Input.NMAkeKod[0]:=#0;
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
 BasisDate:=0;
 Opt:=False;
 OperatorSelector:=0;
 DocSelector:=9;
 VidDocument    :=0;
 MakeKod[0]:=#0;
 Document[0]:=#0;
 DocumentPrz[0]:=#0;
 Skidka:=0;
 SummaR:=0;
 SummaO:=0;
 SummaZakupka:=0;
 SummaZakupka2:=0;

 TimeC:=0;
 DateM:=0;
 TimeM:=CurrentTime;
 Caption:=CurrentPassword;
{$IFNDEF Converter}
 SkladKod:=FormKod(Rek^.Dat.Kod);
{$ENDIF}

 Rashod:=False;
 RashodSumma:=0;

End;
End;

Destructor ClientNewVozwratPtr.Done;
Begin
TObject.Done;
End;


Constructor BufClientNewVozwratTypePtr.Init ;
Var i,j,k : Word;
Begin
TObject.Init;
For k:=1 To BufferCvzw Do
Begin
With Point.Dat[k].Return Do
Begin
 BasisDoc[0]:=#0;
 BasisDate:=0;
 Opt:=False;
 OperatorSelector:=0;
 DocSelector:=9;
 VidDocument    :=0;
 MakeKod[0]:=#0;
 Document[0]:=#0;
 DocumentPrz[0]:=#0;
 Skidka:=0;
 SummaR:=0;
 SummaO:=0;
 SummaZakupka:=0;
 SummaZakupka2:=0;

 TimeC:=0;
 DateM:=0;
 TimeM:=CurrentTime;
 Caption:=CurrentPassword;
{$IFNDEF Converter}
 SkladKod:=FormKod(Rek^.Dat.Kod);
{$ENDIF}

 Rashod:=False;
 RashodSumma:=0;

End;
End;{For}
End;

Destructor BufClientNewVozwratTypePtr.Done;
Begin
TObject.Done;
End;



Constructor PereozenkaPtr.Init ;
Var i : Byte;
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
{$IFNDEF Converter}
        SkladKod:=FormKod(Rek^.Dat.Kod);
{$ENDIF}
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
     NSertif[0] :=#0;
     NMakeKod:='00000';
   SertifKol[0] :=#0;
     Kol    [0] :=#0;
    Grammi  [0] :=#0;

     Zena   [0] :=#0;
     R_Zena [0] :=#0;
     O_Zena [0] :=#0;
     Skidka [0] :=#0;
     Zakupka[0] :=#0;
     {Itogo  [0] :=#0;}
     Proz   [0] :=#0;
     VidNDS :=2;
     NDS    [0] :=#0;
     SpecNalog[0] :=#0;
     VidNalog:=2;
     DivisionNumber:=1;
     LAst :=FAlse;
     NSertif[0] :=#0;
   SertifKol[0] :=#0;
   RegionMarka:=0;
     AkzisSbor[0]:=#0;
     ZenaMarki[0]:=#0;
     Version:=1;
   End;

    Dat.DocumentElement[i].BazKod[0]:=#0;
    With Dat.DocumentElement[i].Input Do
   Begin
     NSertif[0] :=#0;
   SertifKol[0] :=#0;
     Kol    [0] :=#0;
     Zena   [0] :=#0;
     R_Zena [0] :=#0;
     O_Zena [0] :=#0;
     Skidka [0] :=#0;
     Zakupka[0] :=#0;
     {Itogo[0] :=#0;}
     Proz[0] :=#0;
     VidNDS:=2;
     NDS[0] :=#0;
     SpecNalog[0] :=#0;
     VidNalog:=2;
     DivisionNumber:=1;
     LAst :=FAlse;
   End;
  End;
   With Dat Do
    Begin
     Realiz:=False;
     DocumentPRZ[0]:=#0;
     Document[0]:=#0;
     DocumentComment:=0;
     ENalog  [0]:=#0;
     Nalog5  [0]:=#0;
     Nalog3  [0]:=#0;
     Nalog_  [0]:=#0;

     SummaAkzis[0]:=#0;
     SummaZ[0]:=#0;
     SummaZakupka[0]:=#0;
     SummaZakupka2[0]:=#0;
     Skidka[0]:=#0;

     SertifSummaZ[0]:=#0;
     SertifSummaZakupka[0]:=#0;
     SertifSummaZakupka2[0]:=#0;
     SertifSkidka[0]:=#0;
     Bn.DAte[0]:=#0;
     Bn.NPlat[0]:=#0;
     Bn.Bank[0]:=#0;
     Bn.Summa[0]:=#0;
     Caption:=CurrentPassword;
     Active:=True;
     Realiz := False;
      Locked:=False;
     Srok:=0;
     Otkat:=0.0000;
     Amount:=0;
     ShkalaNumer:=0;
     AmountS:=0;
     DateC[0]:=#0;
     TimeC[0]:=#0;
     DateM:=FDate;
     TimeM:=CurrentTimeString('hh:mm:ss');

{$IFNDEF Converter}
     SkladKod:=FormKod(Rek^.Dat.Kod);
{$ENDIF}

     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     Versia :=1;
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
     EkspeditorKod:='0000';
     DocReal[0]:=#0;
     DocDate:=DateStringToDate(DateMask,FDate);
     Rashet:=0;
     Oformlenie :=0;
     FromZakaz[0]:=#0;

     With Veksel Do
     Begin
      For i:=1 To MaxVeksel Do
       Begin
        Exampl[i].Seria:=SeriaConst;
        Exampl[i].Numer[0]:=#0;
        Exampl[i].Data [0]:=#0;
        Exampl[i].Summa[0]:=#0;
        Exampl[i].Proz :='0';
        Exampl[i].DogovorNumer[0]:=#0;
       End;{For}
     End;{With}
     {comment[0]:=#0;}
    End;{With}
End;




Destructor SuperMarketPtr.Done;
Begin
TObject.Done;
End;

(*
Constructor BufNewProdagaElementPtr.Init ;
Var i : Byte;
    j : Word;
Begin
TObject.Init;
For j:=1 To BufferNewPE Do
Begin
    Dat.Point[j].BazKod:=0;
    With Dat.Point[j].Input Do
   Begin
        Kol     [0]:=#0;
        Skidka  :=0.00;
        Zena    :=0.00;
        R_Zena  :=0.00;
        O_Zena  :=0.00;
        Zakupka :=0.00;
        Zakupka2:=0.00;
        Proz    :=0.00;
       VidNDS   :=0;{ вид налога 0=20% 1=10% 2=прочее}
        NDS     :='20.00';
     VidNalog   :=0;{ вид налога 0=5% 1=3% 2=прочее}
      SpecNalog :='5.00';
  DiviSionNumber:=1;
       Last     :=False;
       NSertif  [0]:=#0;
       SertifKol[0]:=#0;{используется только для товара}
   End;{With}

End;{For}
End;


Destructor BufNewProdagaElementPtr.Done;
Begin
TObject.Done;
End;
*)


Constructor BufSuperMarketTypePtr.Init ;
Var i : Word;
    j : Word;
Begin
TObject.Init;
For j:=1 To BufferMRK Do
Begin
 For i:=1 To CMax Do
  Begin
    Point.Dat[j].MarketElement[i].BazKod[0]:=#0;
    With Point.Dat[j].MarketElement[i].Input Do
   Begin
     NSertif[0] :=#0;
     NMAkeKod:='00000';
   SertifKol[0] :=#0;
     Kol    [0] :=#0;
    Grammi  [0] :=#0;
     Zena   [0] :=#0;
     R_Zena [0] :=#0;
     O_Zena [0] :=#0;
     Skidka [0] :=#0;
     Zakupka[0] :=#0;
     {Itogo  [0] :=#0;}
     Proz   [0] :=#0;
     VidNDS :=2;
     NDS    [0] :=#0;
     SpecNalog[0] :=#0;
     VidNalog:=2;
     RegionMarka:=0;
     DivisionNumber:=1;
     LAst :=FAlse;
     NSertif[0] :=#0;
   SertifKol[0] :=#0;
     AkzisSbor[0]:=#0;
     ZenaMarki[0]:=#0;
   End;

    Point.Dat[j].DocumentElement[i].BazKod[0]:=#0;
    With Point.Dat[j].DocumentElement[i].Input Do
   Begin
     NMAkeKod:='00000';
     NSertif[0] :=#0;
   SertifKol[0] :=#0;
     Kol    [0] :=#0;
     Zena   [0] :=#0;
     R_Zena [0] :=#0;
     O_Zena [0] :=#0;
     Skidka [0] :=#0;
     Zakupka[0] :=#0;
     {Itogo[0] :=#0;}
     Proz[0] :=#0;
     VidNDS:=2;
     NDS[0] :=#0;
     SpecNalog[0] :=#0;
     VidNalog:=2;
     DivisionNumber:=1;
     LAst :=FAlse;
     Version := 1;
   End;
  End;
   With Point.Dat[j] Do
    Begin
     Realiz:=False;
     DocumentPRZ[0]:=#0;
     Document[0]:=#0;
     DocumentComment:=0;
     ENalog  [0]:=#0;
     Nalog5  [0]:=#0;
     Nalog3  [0]:=#0;
     Nalog_  [0]:=#0;

     SummaZ[0]:=#0;
     SummaAkzis[0]:=#0;
     SummaZakupka[0]:=#0;
     SummaZakupka2[0]:=#0;
     Skidka[0]:=#0;

     Otkat:=0;

     SertifSummaZ[0]:=#0;
     SertifSummaZakupka[0]:=#0;
     SertifSkidka[0]:=#0;
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
     ShkalaNumer:=0;
     AmountS:=0;
     DateC[0]:=#0;
     TimeC[0]:=#0;
     DateM:=FDate;
     TimeM:=CurrentTimeString('hh:mm:ss');
{$IFNDEF Converter}
     SkladKod:=FormKod(Rek^.Dat.Kod);
{$ENDIF}
     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     Versia :=1;
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
     EkspeditorKod:='0000';
     DocReal[0]:=#0;
     DocDate:=DateStringToDate(DateMask,FDAte);
     Rashet:=0;
     Oformlenie :=0;
     FromZakaz[0]:=#0;

     With Veksel Do
     Begin
      For i:=1 To MaxVeksel Do
       Begin
        Exampl[i].Seria:=SeriaConst;
        Exampl[i].Numer[0]:=#0;
        Exampl[i].Data [0]:=#0;
        Exampl[i].Summa[0]:=#0;
        Exampl[i].Proz :='0';
        Exampl[i].DogovorNumer[0]:=#0;
       End;{For}
     End;{With}
     {comment[0]:=#0;}
    End;{With}
End;{For}
End;




Destructor BufSuperMarketTypePtr.Done;
Begin
TObject.Done;
End;


Constructor BufSuperMarketTypeIDXPtr.Init ;
Var i : Word;
    j,k : Word;
Begin
TObject.Init;
For j:=1 To BufferMRKIDX Do
Begin
   With Point.Dat[j] Do
    Begin
     Realiz:=False;
     Document[0]:=#0;

     SummaZ:=0;
     SummaZakupka:=0;
     SummaZakupka2:=0;
     Skidka:=0;

     ENalog:=0;
     SummaAkzis:=0;
     SertifSummaZ:=0;
     SertifSummaZakupka:=0;
     SertifSkidka:=0;
     Otkat:=0;
     Caption:=CurrentPassword;
     Active:=True;
     Realiz := False;
     ShkalaNumer:=0;
     DateC:=DateStringToDAte(DateMask,FDAte);
     TimeC:=TiMeStringToTime('hh:mm:ss',CurrentTimeString('hh:mm:ss'));
     DateM:=DateStringToDAte(DateMask,FDAte);
     TimeM:=TiMeStringToTime('hh:mm:ss',CurrentTimeString('hh:mm:ss'));
{$IFNDEF Converter}
     SkladKod:=FormKod(Rek^.Dat.Kod);
{$Endif}
     OperatorSelector:=0;

     For k:=1 To CDivision Do
     Begin
     MSummaZ  [k]:=0;
     MSkidka  [k]:=0;
MSummaZakupka [k]:=0;
MSummaZakupka2[k]:=0;
     MSSummaZ  [k]:=0;
     MSSkidka  [k]:=0;
MSSummaZakupka [k]:=0;
MSSummaZakupka2[k]:=0;
     End;


     DocSelector :=0;
     SkidkaSelector :=0;
     Versia :=1;
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
     EkspeditorKod:='0000';
     Rashet:=0;
     Oformlenie :=0;
     FromZakaz[0]:=#0;
    End;{With}
End;{For}
End;




Destructor BufSuperMarketTypeIDXPtr.Done;
Begin
TObject.Done;
End;


Constructor SuperMarketIDXPtr.Init ;
Var i : Word;
    j,k : Word;
Begin
TObject.Init;
   With Dat Do
    Begin
     Realiz:=False;
     Document[0]:=#0;

     SummaZ:=0;
     SummaZakupka:=0;
     SummaZakupka2:=0;
     Skidka:=0;
     ENalog:=0;

     SummaAkzis:=0;
     SertifSummaZ:=0;
     SertifSummaZakupka:=0;
     SertifSkidka:=0;
     Caption:=CurrentPassword;
     Active:=True;
     Realiz := False;
     ShkalaNumer:=0;
     DateC:=DateStringToDAte(DateMask,FDAte);
     TimeC:=TiMeStringToTime('hh:mm:ss',CurrentTimeString('hh:mm:ss'));
     DateM:=DateStringToDAte(DateMask,FDAte);
     TimeM:=TiMeStringToTime('hh:mm:ss',CurrentTimeString('hh:mm:ss'));
{$IFNDEF Converter}
     SkladKod:=FormKod(Rek^.Dat.Kod);
{$ENDIF}

     For k:=1 To CDivision Do
     Begin
     MSummaZ  [k]:=0;
     MSkidka  [k]:=0;
MSummaZakupka [k]:=0;
MSummaZakupka2[k]:=0;

     MSSummaZ  [k]:=0;
     MSSkidka  [k]:=0;
MSSummaZakupka [k]:=0;
MSSummaZakupka2[k]:=0;
     End;

     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     Versia :=1;
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
     EkspeditorKod:='0000';
     Rashet:=0;
     Oformlenie :=0;
     Otkat :=0;
     FromZakaz[0]:=#0;
    End;{With}
End;




Destructor SuperMarketIDXPtr.Done;
Begin
TObject.Done;
End;


Constructor BufZakazTypePtr.Init ;
Var i : Word;
    j : Word;
Begin
TObject.Init;
For j:=1 To BufferZakaz Do
Begin
 For i:=1 To CMax Do
  Begin
    Point.Dat[j].MarketElement[i].BazKod[0]:=#0;
    With Point.Dat[j].MarketElement[i].Input Do
   Begin
     NSertif[0] :=#0;
   SertifKol[0] :=#0;
     Kol    [0] :=#0;
     Zena   [0] :=#0;
     Skidka [0] :=#0;
     Proz   [0] :=#0;
     InputDivision:=1;
     NSertif[0] :=#0;
   SertifKol[0] :=#0;
     Version:=1;
   End;

    Point.Dat[j].DocumentElement[i].BazKod[0]:=#0;
    With Point.Dat[j].DocumentElement[i].Input Do
   Begin
     NSertif[0] :=#0;
   SertifKol[0] :=#0;
     Kol    [0] :=#0;
     Zena   [0] :=#0;
     Skidka [0] :=#0;
     Proz[0] :=#0;
     InputDivision:=1;
   End;
  End;
   With Point.Dat[j] Do
    Begin
     Document[0]:=#0;
     DocumentComment:=0;

     SummaZ[0]:=#0;
     Skidka[0]:=#0;

     SertifSummaZ[0]:=#0;
     SertifSkidka[0]:=#0;
     Caption:=CurrentPassword;
      Locked:=False;
     Amount:=0;
     ShkalaNumer:=0;
     AmountS:=0;
     DateC[0]:=#0;
     TimeC[0]:=#0;
     DateM:=FDate;
     TimeM:=CurrentTimeString('hh:mm:ss');
{$IFNDEF Converter}
     SkladKod:=FormKod(Rek^.Dat.Kod);
{$ENDIF}
     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     Versia :=1;
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
     EkspeditorKod:='0000';
     DocReal[0]:=#0;
     DocDate[0]:=#0;
     EndDate:=0;
     Oformlenie :=0;
     {comment[0]:=#0;}
    End;{With}
End;{For}
End;




Destructor BufZakazTypePtr.Done;
Begin
TObject.Done;
End;


Constructor BufHeaderZakazTypePtr.Init ;
Var i : Word;
    j : Word;
Begin
TObject.Init;
For j:=1 To BufferHeaderZakaz Do
Begin
   With Point.Dat[j] Do
    Begin
     Document:=0;

     SummaZ:=0.00;
     Skidka:=0.00;

     SertifSummaZ:=0.00;
     SertifSkidka:=0.00;
     Caption:=0;
     DateC:=0;
     TimeC:=0;
     DateM:=0;
     TimeM:=0;
     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     Versia :=1;
     ClientKod:=0;
     AgentKod:=0;
     EkspeditorKod:=0;
     Rashet:=0;
     DocReal:=0;
     DocDate:=0;
     EndDate:=0;
     Oformlenie :=0;
    End;{With}
End;{For}
End;




Destructor BufHeaderZakazTypePtr.Done;
Begin
TObject.Done;
End;



Constructor HeaderZakazTypePtr.Init ;
Var i : Byte;
    j : Word;
Begin
TObject.Init;
   With Dat Do
    Begin
     Document:=0;

     SummaZ:=0.00;
     Skidka:=0.00;

     SertifSummaZ:=0.00;
     SertifSkidka:=0.00;
     Caption:=0;
     DateC:=0;
     TimeC:=0;
     DateM:=0;
     TimeM:=0;
     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     Versia :=1;
     ClientKod:=0;
     AgentKod:=0;
     EkspeditorKod:=0;
     DocReal:=0;
     DocDate:=0;
     EndDate:=0;
     Oformlenie :=0;
    End;{With}
End;




Destructor HeaderZakazTypePtr.Done;
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
     SkladKod:=FormKod(Rek^.Dat.Kod);
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


Constructor ImportSuperMarketPtr.Init ;
Var c,i : Byte;

Begin
TObject.Init;
 For i:=1 To CMax Do
  Begin
    Dat.Element[i].BazKod[0]:=#0;
    Dat.Element[i].Employ:=False;
    Dat.Elements[i].Employ:=False;
    Dat.NSertif[i].Employ:=False;

With Dat.Element[i].Baz Do
 Begin
     Name[0]:=#0;
     Name2[0]:=#0;
     {FullName[0]:=#0;}
     Litr:='0.000';
     InPack[0]:=#0;
     BazKod[0]:=#0;
     {OKP[0]:=#0;}
     OKP:=0;
     Massa[0]:=#0;
     Employ:=False;
     Market:=0;

     VidNalog:=0;
     Nalog:='5.00';

     VidNDS:=0;
     NDS:='20.00';

     Mera[0]:=#0 {шт};
     {Organization:=0; {организация}
     EnableDebit:=1; {организация}
     KSertif[0]:=#0;
     DSertif[0]:=#0;

     {Stat:=False;}
     Locked:=False;
     CAption:=CurrentPassword;
     LockCaption[0]:=#0;
 End;
With Dat.Elements[i].Baz Do
 Begin
     Name[0]:=#0;
     Name2[0]:=#0;
     {FullName[0]:=#0;}
     Litr:='0.000';
     InPack[0]:=#0;
     BazKod[0]:=#0;
     {OKP[0]:=#0;}
     OKP:=0;
     Massa[0]:=#0;
     Employ:=False;
     Market:=0;

     VidNalog:=0;
     Nalog:='5.00';

     VidNDS:=0;
     NDS:='20.00';

     Mera[0]:=#0 {шт};
     {Organization:=0; {организация}
     EnableDebit:=1; {организация}
     KSertif[0]:=#0;
     DSertif[0]:=#0;

     {Stat:=False;}
     Locked:=False;
     CAption:=CurrentPassword;
     LockCaption[0]:=#0;
 End;

With Dat.NSertif[i].Baz Do
 Begin
     Name[0]:=#0;
     Name2[0]:=#0;
     {FullName[0]:=#0;}
     Litr:='0.000';
     InPack[0]:=#0;
     BazKod[0]:=#0;
     {OKP[0]:=#0;}
     OKP:=0;
     Massa[0]:=#0;
     Employ:=False;
     Market:=0;

     VidNalog:=0;
     Nalog:='5.00';

     VidNDS:=0;
     NDS:='20.00';

     Mera:=#0 {шт};
     {Organization:=0; {организация}
     EnableDebit:=1; {организация}
     KSertif[0]:=#0;
     DSertif[0]:=#0;

     {Stat:=False;}
     Locked:=False;
     CAption:=CurrentPassword;
     LockCaption[0]:=#0;
 End;
  Dat.NSertif[i].NMakeKod:='00000';

    With Dat.Element[i].Input Do
   Begin
     NSertif[0] :=#0;
     NMakeKod:='00000';
     R_Zena [0] :=#0;
     Spec_Zena [0] :=#0;
     O_Zena [0] :=#0;
     Zakupka[0] :=#0;
{
     USD:=0;
     GRZena[0]:=#0;
}
     Zakupka2[0] :=#0;
         Kol[0] :=#0;
      Grammi[0]:=#0;
     {For c:=1 To CDivision DO Division[c,0]:=#0;}
      NGTD  [0] :=#0;
	   Post[0] :=#0;
	  Marka[0] :=#0;
   SpecMarka[0] :=#0;
  Virabotano[0] :=#0;
     {DivisionNumber:=1;}
     Godnost[0] :=#0;
	 Akzis1[0] :=#0;
     RegionMarka:=0;
     AkzisSbor[0]:=#0;
     ZenaMarki[0]:=#0;
   End;
    With Dat.Elements[i].Input Do
   Begin
{     NSertif[0] :=#0;}
     R_Zena [0] :=#0;
     O_Zena [0] :=#0;
  Spec_Zena [0] :=#0;
     Zakupka[0] :=#0;
    Zakupka2[0] :=#0;
         Kol[0] :=#0;
{      NGTD  [0] :=#0;}
      NSertif:=NoSertifStr;
      NMakeKod:='00000';
{       Post[0] :=#0;
	  Marka[0] :=#0;
   SpecMarka[0] :=#0;
  Virabotano[0] :=#0;
     Godnost[0] :=#0;}
{	 Akzis1[0] :=#0;}
   End;
 End;


   With Dat Do
    Begin

     Document[0]:=#0;
     DAteC:=DateStringToDAte(DateMask,FDAte);
     SummaZ:=0.00;
     SummaZakupka:=0.00;

     Caption:=CurrentPassword;



     AmountNS:=0;
     AmountS:=0;
     Amount:=0;
{$IFNDEF Converter}
     SkladKod:=FormKod(Rek^.Dat.Kod);
{$ENDIF}
     {OperatorSelector:=1;}
     {ClientKod[0]:=#0;}
     {AgentKod[0]:=#0;}
    End;{With}


End;




Destructor ImportSuperMarketPtr.Done;
Begin
TObject.Done;
End;


Constructor RazdelTypePtr.Init ;
Var i : Word;
Begin
TObject.Init;
    With Dat Do
   Begin
      Name[0]:=#0;
      {Designation[0]:=#0;}
      EnableDoc  :=0;
      EnableLitr :=0;
      For i:=1 To CShkala Do
	  Begin
        Skidka[i].Up  [0]:=#0;
        Skidka[i].Proz[0]:=#0;
       End;
      Kod     [0]:=#0;
      Employ     :=False;
      Locked     :=False;
      {For i:=0 To 999 Do Present[i]:=False;}
   End;{With}
End;

Destructor RazdelTypePtr.Done;
Begin
TObject.Done;
End;



Constructor BufRazdelPtr.Init ;
Var i : Word;
    j : Word;
Begin
TObject.Init;
For j:= 1 To BufferRazdel Do
Begin
    With Point.Dat[j] Do
   Begin
      Name[0]:=#0;
      {Designation[0]:=#0;}
      EnableDoc  :=0;
      EnableLitr :=0;
      For i:=1 To CShkala Do
	  Begin
        Skidka[i].Up  [0]:=#0;
        Skidka[i].Proz[0]:=#0;
       End;
      Kod     [0]:=#0;
      Employ     :=False;
      Locked     :=False;
      {For i:=0 To 999 Do Present[i]:=False;}
   End;{With}
End;
End;

Destructor BufRazdelPtr.Done;
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



Constructor ZakazTypePtr.Init ;
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
     Proz   [0] :=#0;
     Skidka [0] :=#0;
     InputDivision:=1;
   End;
  End;
   With Dat Do
    Begin
     DocumentComment:=0;
     Document[0]:=#0;
     SummaZ[0]:=#0;
     Caption:=CurrentPassword;
     Locked:=False;
     Amount:=0;
     AmountS:=0;
     DateC:=FDate;
     TimeC:=CurrentTimeString('hh:mm:ss');
{$IFNDEF Converter}
     SkladKod:=FormKod(Rek^.Dat.Kod); (*******)
{$ENDIF}
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
     EndDAte:=0;
     DocReal[0]:=#0;
     DocDate[0]:=#0;
  Oformlenie:=0;
     Versia:=1;
    End;{With}
End;


Destructor ZakazTypePtr.Done;
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
        DateM    [0]:=#0;
        TimeM    [0]:=#0;

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
        Zena    [0]:=#0;
        SkladKod[0]:=#0;
        Caption [0]:=#0;
        Comment [0]:=#0;
        Tested  :=0;
        CaptionTested[0]:=#0;
        DateT   [0]:=#0;
        TimeT   [0]:=#0;
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
        NMakeKod:='00000';
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
        {
        ENalog[0]  :=#0;
        Nalog5[0]  :=#0;
        Nalog3[0]  :=#0;
        Nalog_[0]  :=#0;
        }
        SummaZ:=0;
        SummaZakupka:=0;
        SummaAkzis:=0;
        Skidka:=0;

(**)  SertifSummZ:=0;
(**) SertifSkidka:=0;
(**)SertifSummaZakupka:=0;

        Bn.DAte[0]:=#0;
        Bn.NPlat[0]:=#0;
        Bn.Bank[0]:=#0;
        Bn.Summa[0]:=#0;

        Caption:=CurrentPassword;
        DateC{[0]}:=0;
        TimeC{[0]}:=0;
        DateM:=DateStringToDate(DateMask,FDate);
        TimeM:=TimeStringToTime('hh:mm:ss',CurrentTimeString('hh:mm:ss'));
{$IFNDEF Converter}
        SkladKod:=StrToInt(FormKod(Rek^.Dat.Kod));
{$Endif}
        DocSelector :=0;
        SkidkaSelector :=0;
        {ClientKod[0]:=#0};
        Active:=True;
        {Sf :=False;}
        (*
        For i:=0 To MaxStatRazdel Do
         Begin
          RazdelSum[i]:=0.00;
          {RazdelZak[i]:=0.00;}
          RazdelSkid[i]:=0.00;
         End;
        *)
    End;
End;

Destructor StatClientTypePtr.Done;
Begin
TObject.Done;
End;







Constructor BufStatClientTypePtr.Init ;
Var i,j: Word;
Begin
TObject.Init;
For j:=1 To BufferHis Do
Begin
   With Point.Dat[j] Do
    Begin
        Rashet:=1;
        Realiz:=False;
        Document[0]:=#0;
        {
        ENalog[0]  :=#0;
        Nalog5[0]  :=#0;
        Nalog3[0]  :=#0;
        Nalog_[0]  :=#0;
        }
        {SummaZ[0]:=#0;}
        SummaZ:=0;
        SummaZakupka:=0;
        Skidka:=0;
        SummaAkzis:=0;

(**)  SertifSummZ:=0;
(**) SertifSkidka:=0;
(**)SertifSummaZakupka:=0;


        Bn.DAte[0]:=#0;
        Bn.NPlat[0]:=#0;
        Bn.Bank[0]:=#0;
        Bn.Summa[0]:=#0;
        Caption:=CurrentPassword;
        DateC:=0;
        TimeC:=0;
        DateM:=DateStringToDate(DateMask,FDate);
        TimeM:=TimeStringToTime('hh:mm:ss',CurrentTimeString('hh:mm:ss'));
{$IFNDEF Converter}
        SkladKod:=StrToInt(FormKod(Rek^.Dat.Kod));
{$Endif}
        DocSelector :=0;
        SkidkaSelector :=0;
        {ClientKod[0]:=#0};
        Active:=True;
        {Sf :=False;}
        (*
        For i:=0 To MaxStatRazdel Do
         Begin
          RazdelSum[i]:=0.00;
          {RazdelZak[i]:=0.00;}
          RazdelSkid[i]:=0.00;
         End;
        *)
    End;
End;
End;

Destructor BufStatClientTypePtr.Done;
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
     {
     SummaZ[0]:=#0;
     Skidka[0]:=#0;
     }

     SummaZ:=0;

     SummaZakupka:=0;
     SummaZakupka2:=0;

     Skidka:=0;

     Caption:=CurrentPassword;
     Active:=True;
     Srok:=0;
     DateC:=DateStringToDAte(DateMAsk,FDAte);
{$IFNDEF Converter}
     SkladKod:=FormKod(Rek^.Dat.Kod);
{$ENDIF}


     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     Versia :=1;
     Rashet:=0;
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
     EkspeditorKod:='0000';
    End;
  With Dat Do
  Begin
   Dolg:=0;
   Full:=False;
     Otkat  :=0;
   FullOtkat:=True;
     Payment:=False;
     {sf := False;}
     For i :=1 To 4 Do
      Begin
      Doc[i].DocReal[0]:=#0;
      Doc[i].DocDate{[z0]}:={#0}DateStringToDate(DateMask,FDAte);
      Doc[i].Employ:=False;
      End;
  End;
End;


Destructor RealizasiaPtr.Done;
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
     SummaZ:=0;
     Skidka:=0;

     SummaZakupka:=0;
     SummaZakupka2:=0;

     Caption:=CurrentPassword;
     Active:=True;
     Srok:=0;
     DateC:=DateStringToDAte(DateMAsk,FDAte);
     {TimeC[0]:=#0;}

{$IFNDEF Converter}
     SkladKod:=FormKod(Rek^.Dat.Kod);
{$ENDIF}
     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     Versia :=1;
     Rashet:=0;
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
     EkspeditorKod:='0000';
    End;
  With Point.Dat[c] Do
  Begin
   Dolg:=0;
   Otkat:=0;
   FullOtkat:=True;
   Full:=False;
     Payment:=False;
     {sf := False;}
     For i :=1 To 4 Do
      Begin
      Doc[i].DocReal[0]:=#0;
      Doc[i].DocDate:=DateStringToDate(DateMask,FDAte);
      Doc[i].Employ:=False;
      End;
  End;
End;
End;



Destructor BufRealizasiaTypePtr.Done;
Begin
TObject.Done;
End;


Constructor BufOplataRealizasiaTypePtr.Init ;
Var i : Byte;
    c : Word;
Begin
TObject.Init;
For c:=1 To BufferOpl Do
Begin
   With Point.Dat[c] Do
Begin
    SkladKod [0]:=#0;
   ClientKod [0]:=#0;
    Document [0]:=#0;
     DateDoc [0]:=#0;
     DateC   [0]:=#0;
     TimeC   [0]:=#0;
     SummaZ  [0]:=#0;
     Skidka  [0]:=#0;
     Vozwrat :=False;      {если был возврат}
     DocNumerReturn[0]:=#0;
     DocDateReturn[0]:=#0;
     Caption[0]:=#0;
     Rashet  :=0;
End;{With}
End;{For}
End;


Destructor BufOplataRealizasiaTypePtr.Done;
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
     DateDoc   :=0;

     DateC     :=0;
     TimeC     :=0;

     SummaZ   :=0;

     Skidka   :=0;
      {Добавил для документов возврата}
      Vozwrat :=False;
DocNumerReturn[0] :=#0;
DocDateReturn :=0;
     Srok     :=0;
     Caption  [0] :=#0;
     Delta    [0] :=#0;
     Rashet   :=0;
End;{With}
End;{For}
End;


Destructor BufClientOplataRealizasiaTypePtr.Done;
Begin
TObject.Done;
End;




Constructor SkladPtr.Init ;
var j : Word;
Begin
TObject.Init;
     Dat.MakeKod[0] :=#0;
     Dat.MakeVid:=0;
     Dat.Date:=Today;
     Dat.Time:=CurrentTime;
     {Dat.Tip    :=0;}
     {Dat.Analys :=False;}
     Dat.Locked :=False;
     Dat.Employ :=False;
     Dat.EnableDebit :=1;
 With Dat.Input Do
  Begin
     NSertif :=NoSertifStr;
     NMakeKod:='00000';
    NGroupKod:='0000';
        Kol     :='0';
        StrihKod[0] :=#0;
        KolR    :='0';
        USD     :=0;
        Proz[0]:=#0;
        GRZEna [0]:=#0;
  Virabotano[0]:=#0;
     RegionMarka:=0;
     For j:=1 To CDivision Do Division[j,0]:=#0;
     For j:=1 To CDivision Do DivisionR[j,0]:=#0;
     Zakupka :='0.0000';
     Zakupka2:='0.0000';
     R_Zena  :='0.00';
    Spec_Zena:='0.00';
     O_Zena  :='0.00';
     Caption :=CurrentPassword;
     Auto:=False;
     AkzisSbor:='0.0000';
     ZenaMArki:='0.0000';
  End;

End;

Destructor SkladPtr.Done;
Begin
TObject.Done;
End;


Constructor SkladNewPtr.Init ;
var j : byte;
Begin
TObject.Init;
With Dat Do
  begin
     BazKod  :=0;
     NSertif :=NoSertif;
     Employ:=False;
     StrihKod[0] :=#0;
     Kol:=0;
     RegionMarka:=0;
     NMakeKod:=0;
     NGroupKod:=0;
     EnableSklads:=32767;
     Zakupka:=0;
     Zakupka2:=0;
     AkzisSbor:=0;
     For j:=1 To CDivision Do
	Begin
	Division[j]:=0;
     DivisionR[j]:=0;
     End;
     R_Zena  :=0.00;
  End;

End;

Destructor SkladNewPtr.Done;
Begin
TObject.Done;
End;

Constructor ExtSkladPtr.Init ;
var j : byte;
Begin
TObject.Init;
       Dat.BazKod[0]:=#0;
 With Dat.Input Do
  Begin
     Ex [0] :=#0;
     Akzis1 [0] :=#0;
        NGTD[0] :=#0;
     {StrihKod[0] :=#0;}
       Post [0] :=#0;
  FirmaPost [0] :=#0;
   SpecMarka[0]:=#0;
	  Marka[0]:=#0;
	  Godnost[0]:=#0;
  End;

End;

Destructor ExtSkladPtr.Done;
Begin
TObject.Done;
End;

Constructor BufSkladTypePtr.Init ;
var j,k : Word;
Begin
TObject.Init;
For k:=1 To BufferDB Do
Begin
 With Point Do
 Begin
     Dat[k].MakeKod[0] :=#0;
     Dat[k].MakeVid:=0;
     Dat[k].Date:=ToDay;
     Dat[k].Time:=CurrentTime;
     {Dat[k].Tip    :=0;}
     {Dat[k].Analys :=False;}
     Dat[k].Locked :=False;
     Dat[k].Employ :=False;
     Dat[k].EnableDebit :=1;
 With Dat[k].Input Do
  Begin
     NSertif :=NoSertifStr;
    NGroupKod:='0000';
     NMakeKod:='00000';
        Kol     :='0';
        KolR    :='0';
        Proz[0]:=#0;
        GRZena[0]:=#0;
        USD:=0;
        StrihKod[0] :=#0;
  Virabotano[0]:=#0;
     For j:=1 To CDivision Do Division[j,0]:=#0;
     For j:=1 To CDivision Do DivisionR[j,0]:=#0;
     Zakupka :='0.0000';
     Zakupka2:='0.0000';
     R_Zena  :='0.00';
     O_Zena  :='0.00';
    Spec_Zena:='0.00';
     Caption :=CurrentPassword;
     Auto:=False;
     AkzisSbor:='0.0000';
     ZenaMArki:='0.0000';
  End;
 End;{With}
End;{For}
End;



Destructor BufSkladTypePtr.Done;
Begin
TObject.Done;
End;


Constructor BufSkladTypeNewPtr.Init ;
var j,k : Word;
Begin
TObject.Init;
For k:=1 To BufferDBnew Do
Begin
 With Point.Dat[k] Do
 Begin
     Name [0]:=#0;
     Name2[0]:=#0;
     Virabotano :=0;
     Employ :=False;
     NSertif :=NoSertif;
     NMakeKod:=0;
     NGroupKod:=0;
     EnableSklads:=32767;
     Zakupka:=0;
     Zakupka2:=0;
     AkzisSbor:=0;
     For j:=1 To CDivision Do Division[j]:=0;
     For j:=1 To CDivision Do DivisionR[j]:=0;
     R_Zena  :=0.00;
     RegionMarka:=0;
     BazKod:=0;
 End;{With}
End;{For}
End;



Destructor BufSkladTypeNewPtr.Done;
Begin
TObject.Done;
End;

Constructor BufExtSkladTypePtr.Init ;
var j,k : byte;
Begin
TObject.Init;
For k:=1 To BufferDBExt Do
Begin
 With Point Do
 Begin
  Dat[k].BazKod[0]:=#0;
 With Dat[k].Input Do
  Begin
          Ex[0] :=#0;
     Akzis1 [0] :=#0;
        NGTD[0] :=#0;
   {StrihKod[0] :=#0;}
       Post [0] :=#0;
       FirmaPost[0]:=#0;
   SpecMarka[0]:=#0;
	  Marka[0]:=#0;
	  Godnost[0]:=#0;
  End;
 End;{With}
End;{For}
End;



Destructor BufExtSkladTypePtr.Done;
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
FullName [0]:=#0;
Dogovor  [0]:=#0;
AdressF  [0]:=#0;
{For j:=1 To 4 Do Punkt[j,0]:=#0;}
{1 Павильоны} {2 Палатки} {3 Магазин} {4 Кафе}
Limit    [0]:=#0;
Lizo     :=0;
Adress   [0]:=#0;
Telefon  [0]:=#0;
R_Sh     [0]:=#0;
Gde      [0]:=#0;
Gorod    [0]:=#0;
INN      [0]:=#0;
OKONH    [0]:=#0;
OKPO     [0]:=#0;
Enviropment[0]:=#0;
KTO      [0]:=#0;
Svidetelstvo[0]:=#0;
VekselIP[0]:=#0;
VekselDP[0]:=#0;
Seria   [0]:=#0;
Passport[0]:=#0;
Vidan   [0]:=#0;
Messages[0]:=#0;
Debit   :=0;
SrokLizensia[0]:=#0;
Kod      [0]:=#0;
Employ   :=False;
RCD     :=FAlse;
Locked   :=False;
LockCaption:='00';
RegionKod:=NoRegionStr;
ComputerNameLocked[0] :=#0;

(*
Main     :=0;        {признак подчиненности клиента 0-главный;1-дочерний}
Period   [0]:=#0;    {периодичность появления}
VIP      [0]:=#0;    {признак особой важности клиента
                           в нем(поле) устанавливается дополнительная отсрочка}
DocFiltr :=0; {фильтр документов отгразки}
ZenaKod  [0]:=#0;{код шкалы цен пока не используется}
MainKod  [0]:=#0;{Default│0000}
DateM    := DateStringToDAte(DateMask,FDate);
TimeM    := TimeStringToDAte('hh:mm:ss',Times);
LastCaption:=CurrentPassword;{пользователь проводивший модификацию}
*)


  End;

End;

Destructor ClientPtr.Done;
Begin
TObject.Done;
End;



Constructor BufClientPtr.Init ;
var j,k : Word;

Begin
TObject.Init;
For k:=1 To Buffer Do
Begin
 With Point.Dat[k] Do
  Begin
Name     [0]:=#0;
FullName [0]:=#0;
Dogovor  [0]:=#0;
AdressF  [0]:=#0;
{For j:=1 To 4 Do Punkt[j,0]:=#0;}
{1 Павильоны} {2 Палатки} {3 Магазин} {4 Кафе}
Limit    [0]:=#0;
Lizo     :=0;
Adress   [0]:=#0;
Telefon  [0]:=#0;
R_Sh     [0]:=#0;
Gde      [0]:=#0;
Gorod    [0]:=#0;
INN      [0]:=#0;
OKONH    [0]:=#0;
OKPO     [0]:=#0;
Enviropment[0]:=#0;
KTO[0]:=#0;
Svidetelstvo[0]:=#0;
VekselIP[0]:=#0;
VekselDP[0]:=#0;
Seria   [0]:=#0;
Passport[0]:=#0;
Vidan   [0]:=#0;
Messages[0]:=#0;
Debit   :=0;
SrokLizensia[0]:=#0;
Kod      [0]:=#0;
Employ   :=False;
RCD      :=False;
Locked   :=False;
RegionKod:=NoRegionStr;
DAteM :=DateStringToDate(DateMask,FDAte);
LockCaption:='00';
ComputerNameLocked[0] :=#0;

(*
Main     :=0;        {признак подчиненности клиента 0-главный;1-дочерний}
Period   [0]:=#0;    {периодичность появления}
VIP      [0]:=#0;    {признак особой важности клиента
                           в нем(поле) устанавливается дополнительная отсрочка}
DocFiltr :=0; {фильтр документов отгразки}
ZenaKod  [0]:=#0;{код шкалы цен пока не используется}
MainKod  [0]:=#0;{Default│0000}
DateM    := DateStringToDAte(DateMask,FDate);
TimeM    := TimeStringToDAte('hh:mm:ss',Times);
LastCaption:=CurrentPassword;{пользователь проводивший модификацию}
*)

  End;
End;{For Buffer}
End;

Destructor BufClientPtr.Done;
Begin
TObject.Done;
End;











Constructor BazTypePtr.Init ;
Begin
TObject.Init;
With Dat Do
 Begin
     Main:=0;
     Name[0]:=#0;
     Name2[0]:=#0;
     {FullName[0]:=#0;}
     Litr:='0.000';
     InPack[0]:=#0;
     InPack2[0]:=#0;
     BazKod[0]:=#0;
     FantomKod:=NoSertifStr;
     {OKP[0]:=#0;}
     OKP:=0;
     Massa[0]:=#0;
     Employ:=False;
     Market:=0;
     BuchGroup:=0;
     Etil:='0.00';

     VidNalog:=0;
     Nalog:='5.00';

     VidNDS:=0;
     NDS:='20.00';

     Mera[0]:=#0 {шт};

     EnableContract:=0;
     ContractDate[0]:=#0;
     Contract[0]:=#0;
     ContractDate[0]:=#0;

     EnableDebit:=1; {организация}

     KSertif := NoRouteStr;
     PostKod := NoRouteStr;
     FirmaPostKod := NoRouteStr;

     DSertif[0]:=#0;
     EnableSklads:=32767;

     {Stat:=False;}
     Locked:=False;
     CAption:=CurrentPassword;
     LockCaption[0]:=#0;
 End;
End;

Destructor BazTypePtr.Done;
Begin
TObject.Done;
End;


Constructor BufBazTypePtr.Init ;
Var c,count : Word;
Begin
TObject.Init;
For c:=1 To BufferID Do
Begin
With Point.Dat[c] Do
 Begin
     Main :=0;
     Name[0]:=#0;
     Name2[0]:=#0;
     {FullName[0]:=#0;}
     Litr:='0.000';
     InPack[0]:=#0;
     InPack2[0]:=#0;
     BazKod[0]:=#0;
     FantomKod[0]:=#0;
     {OKP[0]:=#0;}
     OKP:=0;
     Massa[0]:=#0;
     BuchGroup:=0;
     Etil:='0.00';

     Employ:=False;
     Market:=0;
     {Gruppa:=0;}

     VidNalog:=0;
     Nalog:='5.00';

     VidNDS:=0;
     NDS:='20.00';

     Mera[0]:=#0 {шт};

     EnableContract:=0;
     ContractDate[0]:=#0;
     Contract[0]:=#0;
     ContractDate[0]:=#0;

     {Organization:=0; {организация}
     EnableDebit:=1; {организация}
     KSertif[0]:=#0;
     DSertif[0]:=#0;
     EnableSklads:=32767;

{$IfDEF Tara}
     FantomEnable :=0;
	FantomKod[0] :=#0;
     FantomInPack[0]:=#0;
{$EndIF}

     {Stat:=False;}
     Locked:=False;
     CAption:=CurrentPassword;
     LockCaption[0]:=#0;
 End;{With}
End{For}
End;



Destructor BufBazTypePtr.Done;
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
  For i :=1 To 6 Do
  Begin
   Skidka[i].Up[0]:=#0;
   Skidka[i].Proz[0]:=#0;
  End;
  End;
End;


Destructor SkidkaPtr.Done;
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




Constructor CommentClientTypePtr.Init;
Var c: Word;
Begin
TObject.Done;
 With Dat Do
  Begin
Srok  [0]:=#0;
Memo.Length:=0;
{Long    :=0;}
For c:=0 To CMaxMemo Do
 Begin
  Memo.buffer[c]:=#0;
 End;

Memo1.Length:=0;
For c:=0 To CMaxMemo1 Do
 Begin
  Memo1.buffer[c]:=#0;
 End;

Caption := CurrentPassword;
  Date  :=FDate;
  Time  :=CurrentTimeString('hh:mm:ss');
 Active :=True;
  End;
End;

Destructor CommentClientTypePtr.Done;
Begin
TObject.Done;
End;


(*
Constructor ItogKassaPtr.Init;
Begin
With Dat Do
 Begin
   Kod     [0]:=#0;
   DateC   :=DateStringToDAte(DateMAsk,FDAte);
   TimeC   :=TimeStringToTime('hh:mm:ss',CurrentTimeString('hh:mm:ss'));
   Summa   :=0;
   Caption :=CurrentPassword;
   SkladKod:=FormKod(Rek^.Dat.Kod);;
 End;
End;

Destructor ItogKassaPtr.Done;
Begin
TObject.Done;
End;
*)


{Var f:File;}
Begin
ProdagaWindow:=False;
Show:=False;
ShowMsg:=False;
ShowMsgCopy:=False;
Wzlom:=False;
Status:=DocNormal;
GlobalSkladsName[0]:=#0;
GlobalOperatorNAme:='???';
(*
{$IfDef DPMI}

{$Else}
  OvrInit('sklad.ovr');
  OvrSetBuf(OvrGetBuf);
  Case OvrResult Of
  OvrError:Begin
           WriteLn('Ошибка управления Overlay !');
           Halt;
           End;
  OvrNotFound:Begin
           {WriteLn('Оверлейный модуль не найден !');}
           Halt;
           End;
  OvrNoMemory:Begin
           {WriteLn('Не хватает памяти для оверлейного буфера !');}
           Halt;
           End;
  OvrIOError:Begin
           {WriteLn('Сбой при чтении оверлейного файла !');}
           Halt;
           End;
  Else;
  End;
  OvrInitEms;
  Case OvrResult Of
  OvrIOError:Begin
           {Write('Сбой при чтении оверлейного файла !');}
           Halt;
           End;

  OvrNoEmsDriver:Begin
                  {Writeln('Драйвер EMS не установлен !');}
                 End;

  OvrNoEMSMemory:;{Writeln('Мало EMS памяти !');}


  Else  OvrSetBuf(OvrGetBuf+2000);
  End;
{$EndIf}
*)
 SkayScreen:=0;
 InputZakaz:=0;{по умолчанию продажи}
 SetEnableOtdel:=[];
End.



