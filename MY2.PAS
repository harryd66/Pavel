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
{!!!}ElementP: array[1..CMax] of PredZakazElement;  {у клиента фактически подтвержденные ассортимент и количество}
     Document : ArtikulStr; {номер документа}
     DocumentComment{ClientNumer} : Integer;
     DateC   : TDateString; {дата создания}
     TimeC   : TDateString; {время создания}
     DateM   : TDateString; {дата модификации}
     TimeM   : TDateString; {время модификации}

{!!!}     AmountP: word;

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
LockCaption  : String[CRazdelKod];
LockTime     : LongInt;
ComputerNameLocked : String[CCNAme];
     Srok    : LongInt;{срок возврата долга}
     EndDate : LongInt;{Срок брони - количество дней отводимых на доставку}
     DocReal : String[CDocNumer];{номер документа по которым идет проплата,используется только для}
     DocDate{DateOtpr} : TDateString;{документов выводимых после оплаты}
     Rashet  : Word;{0-нал/1-бн/2-вексель}
     Oformlenie : Word;{признак оформления заказа или снятия с брони по времени}

     Status  : Word;{0-стандартная схема резервирования;
                     1-схема резервирования через удаленный доступ}

     PredZakazNumer : LongInt;{по базе предзаказов}
     PredZakazDate  : LongInt;
     PredZakazClient: String[CCLientKod];
     End;
