{  некоторые соображения
   перевод штрихкода в db-файл, т.е. в InputType
1. возврат по бартеру перевод бартера на вторую закупочную цену
2. переход на 4-ех значную фасовку
3. переход на дробное количество товара (9 символов)
4. переход к индексам файлов продаж
5. просмотр версий заказов
}

Unit KGlob;

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
  NoSertifStr='85000';
  NoRegionStr='0000';
  NoGroupStr='0000';
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

 {если возле кода в фигурных скобках стоит * то код уже используется}


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




Type ProdagaElement = Record
     BazKod : String[CArtikul];
     Input  : InputMarketType;
     End;




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
     {ExtElement   : Array[1..CMax] Of ExtMarket;}
     MarketElement   : Array[1..CMax] Of ProdagaElement; {информация о проданном товаре}
     DocumentElement : Array[1..CMAx] Of ProdagaElement; {информация о проданном товаре}
     Document : String[CDocNumer]; {номер документа}
     DocumentPrz : String[CDocNumer];{номер последнего акта переоценки}
     DocumentComment : Integer;
     DateC   : TDateString; {дата создания}
     TimeC   : TDateString; {время создания}
     DateM   : TDateString; {дата модификации}
     TimeM   : TDateString; {время модификации}

{    SENalog  : String[CIZena];
     SNalog5  : String[CIZena];
     SNalog3  : String[CIZena];
     SNalog_  : String[CIZena];}

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
     Document : String[CDocNumer]; {номер документа}
     DateC   : LongInt; {дата создания}
     TimeC   : LongInt; {время создания}
     DateM   : LongInt; {дата модификации}
     TimeM   : LongInt; {время модификации}
  {только для сертификатов}
(* *)  SertifSummaZ: Double;
(* *) SertifSkidka:  Double;
(* *)SertifSummaZakupka: Double;
(* *)SertifSummaZakupka2: Double;
     SummaZ  : Double;  {сумма по документу к оплате}
 SummaAkzis  : Double;  {сумма по документу акзицного сбора}
     Skidka  : Double;  {скидка по документу}
SummaZakupka : Double;  {сумма документа по закупочным ценнам}
SummaZakupka2: Double;  {сумма документа по закупочным ценнам}
   SkladKod  : String[CClientKod];{признак склада}
     Caption : String [CRazdelKod];{признак оператора}
     Active  : Boolean;{признак активности накладной}
     Rashet  : Word;{0-нал/1-бн/2-вексель}
   Oformlenie: Word;{0 без исползования брони; с использованием брони
                     по заказу номер смотри поле FromZakaz}
    FromZakaz: ArtikulStr;{Номер оформляемого заказа}
     End;

Type
    PSuperMarketType = ^SuperMarketPtr;
    SuperMarketPtr=Object(TObject)
    Dat  :  SuperMarketType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Var
     {FileName: String;}
     FDate,TekDate :  TDateString;
     {Print : PrintIni;}
     EditPosition : LongInt;
     DateMask : TDateString;
     TimeMask : TDateString;

     PrihodMax,Lizensia : Real;
     Wzlom : Boolean;
     SkayScreen: Word;
     GlobalReadOnly:Word;
     EnableBron,Compress,Status,EditMode,
	ZakazShema : Word;
     CurrentPassword : String[CKto];
     ClientRP:String[CCLientKod];
     ZeniInZakaz : Word;
     InputZakaz : Word;{указывает на режим работы окна продажи (продажа или заказ)}
     AnsverGlobal,GlobalShow,ProdagaWindow,Show,ShowMsg,ShowMsgCopy,ShowNetMsg: Boolean;
     GlobalSkladsName: TMyString;
     GlobalOperatorNAme: AllStr;
     Interval,GlobalTime,GlobalTimeMsg,GlobalTimeMsg1 : LongInt;
     NetComputerNAme: AllStr;
     EnablePril,EnableSpravka: Set of Byte;
     AutoMarket : Word;
     DefaultSetMArker,EnableAutoSHK,EnableSHK,RemoteProtocol,
	EnableOtkat,RemoteAccess,PrihodFromClient,EnablePeremeshenie,FiktivSkidka,
     DisableCLose,DisableProtocol,EnableNewTovar,EnableHandZeni,EnableComplect,
     RegimOtsheta,
	EnableZakupka,EnablePosVersion,EnableOtdel: Word;
     YesMarker,NoMarker : String[CONe];





Implementation

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
     Caption:='00';
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
     SkladKod:='0001';
{$ENDIF}

     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     Versia :=1;
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
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



End.