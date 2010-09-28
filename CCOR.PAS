{$DEFINE Converter}

uses Glob,Servstr,Objects,TpDate;
{20.07.07}
const CPartyIDKod= 5;
NoPartyIDStr='00000';

Type NewInputMarketType=Record
       Kol     : String[CKol];
        Grammi  : String[CGram];
        Skidka  : String[CZena];
        Zena    : String[CZena];
        R_Zena  : String[CZena];
        O_Zena  : String[CZena];
        Zakupka : String[CZenaZ];
        Zakupka2: String[CZenaZ];
        Proz    : String[CLitr];
       VidNDS   : Word;{ вид налога 0=20% 1=10% 2=прочее 3=18%}
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

       MarkaKod : ArtikulStr;
       SMarkaKod: ArtikulStr;
       NGTDKod  : ArtikulStr;
       ExpertKod: ArtikulStr;
      PartyIDKod: String[CPartyIDKod];
       Srok     : LongInt;
     Virabotano : LongInt;
      End;


Type NewProdagaElement = Record
     BazKod : String[CArtikul];
     Input  : NewInputMarketType;
     End;


Type NewSuperMarketType=Record
     OperatorSelector : Word;{клиент склад обмен заказ}
     DocSelector      : Word;{список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Versia           : Word;{временно не используется для совместимости с универсальным форматом всех файлов}
     Realiz  : Boolean;     {признак что товар был выдан на реализацию}
     Bn : BNType;
     SkidkaSelector : Word; {вид скидки}

     {новая}
     ShkalaNumer: Word; {временно не используется для совместимости с универсальным форматом всех файлов
	                    номер скидочной шкалы}
     Processing : Word;
     ClientKod : String[CClientKod]; {код клиента}
     AgentKod  : String[CClientKod]; {код агента}
     EkspeditorKod : String[CClientKod]; {код агента}
     {ExtElement   : Array[1..CMax] Of ExtMarket;}
     MarketElement   : Array[1..CMax] Of NewProdagaElement; {информация о проданном товаре}
     DocumentElement : Array[1..CMAx] Of NewProdagaElement; {информация о проданном товаре}
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

LockCaption  : String[CRazdelKod];
LockTime     : LongInt;
ComputerNameLocked : String[CCNAme];

     Srok    : LongInt;{срок возврата долга}
     DocReal : String[CDocNumer];{номер документа по которым идет проплата,используется только для}
     DocDate : LongInt{TDateString};{документов выводимых после оплаты}
     Rashet  : Word;{0-нал/1-бн/2-вексель}
   Oformlenie: Word;{0 без исползования брони; с использованием брони
                     по заказу номер смотри поле FromZakaz}
    FromZakaz: ArtikulStr;{Номер оформляемого заказа}
     Veksel  : VekselType;
   Exporting : Word;{0-Экспорт не производился}
                    {1-Экспорт производился}
  Reserv     : Word;
     {PKO     : PKOType;}
     {Comment : AllStr;{комментарий к накладной}
     Comment1 : AllStr;
     Comment2 : AllStr;
     End;


Type
    PNewSuperMarketType = ^NewSuperMarketPtr;
    NewSuperMarketPtr=Object(TObject)
    Dat  :  NewSuperMarketType;
     Constructor Init;
     Destructor Done; Virtual;
 end;

Constructor NewSuperMarketPtr.Init ;
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
     MarkaKod [0]:=#0;
     SMarkaKod[0]:=#0;
     NGTDKod  [0]:=#0;
     ExpertKod[0]:=#0;
     PartyIDKod[0]:=#0;
     Srok     :=0;
     Virabotano:=0;
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
     MarkaKod [0]:=#0;
     SMarkaKod[0]:=#0;
     NGTDKod  [0]:=#0;
     ExpertKod[0]:=#0;
     PartyIDKod[0]:=#0;
     Srok     :=0;
     Virabotano:=0;
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
     Bn.BankKod:=NoBankStr;
     Bn.Summa[0]:=#0;
     Caption:=CurrentPassword;
     Active:=True;
     Realiz := False;
     Locked:=False;
     LockCaption:=CurrentPassword;
     LockTime:=CurrentTime;
     ComputerNameLocked:=NetComputerName;
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
     Processing :=0;
     Reserv:=0;
     Exporting:=0;
     Comment1[0]:=#0;
     Comment2[0]:=#0;

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
end;


Destructor NewSuperMarketPtr.Done;
Begin
TObject.Done;
End;





var
    OldType: PSuperMarketType;
    NewType: PNewSuperMarketType;
    OldF: file of SuperMarketType;
    NewF: file of NewSuperMarketType;
    IORez,i: word;

BEGIN
  Assign(OldF,ParamStr(1)+'.cor');
  IORez:=IOResult;
  Reset(OldF);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      writeln('Не могу открыть файл ',ParamStr(1)+'cor');
      Readln;
      exit;
    end;

  Assign(NewF,ParamStr(1)+'.ncr');
  IORez:=IOResult;
  Rewrite(NewF);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      writeln('Не могу создать файл ',ParamStr(1)+'.ncr'+' Код:'+IntToStr(IoRez,3));
      Readln;
      exit;
    end;

  while not eof(OldF)do
   begin
     New(OldType,Init);
     New(NewType,Init);
     Writeln(FilePos(OldF):4);
     Read(OldF,OldType^.Dat);
     i:=IOResult;
     If i<>0 Then
      Begin
       Writeln('Ошибка ',i:3);
       Readln;
       Halt;
      End;

     With NewType^.Dat do
      begin
     OperatorSelector := OldType^.Dat.OperatorSelector;
     DocSelector      := OldType^.Dat.DocSelector;
     Versia           := OldType^.Dat.Versia;
     Realiz           := OldType^.Dat.Realiz;
     Bn := OldType^.Dat.Bn;
     SkidkaSelector := OldType^.Dat.SkidkaSelector;
     ShkalaNumer:= OldType^.Dat.ShkalaNumer;
     Processing := OldType^.Dat.Processing;
     ClientKod := OldType^.Dat.ClientKod;
     AgentKod  := OldType^.Dat.AgentKod;
     EkspeditorKod := OldType^.Dat.EkspeditorKod;

     If OldType^.Dat.Amount>55 Then OldType^.Dat.Amount:=55;
     Amount:=OldType^.Dat.Amount;
     If OldType^.Dat.AmountS>55 Then OldType^.Dat.AmountS:=55;
     AmountS:=OldType^.Dat.AmountS;

     for i:=1 to OldType^.Dat.Amount do
        begin
          MarketElement[i].BazKod :=OldType^.Dat.MarketElement[i].BazKod;
          MarketElement[i].Input.Kol:=OldType^.Dat.MarketElement[i].Input.Kol;
        MarketElement[i].Input.Grammi  :=OldType^.Dat.MarketElement[i].Input.Grammi;
        MarketElement[i].Input.Skidka  :=OldType^.Dat.MarketElement[i].Input.Skidka;
        MarketElement[i].Input.Zena    :=OldType^.Dat.MarketElement[i].Input.Zena;
        MarketElement[i].Input.R_Zena  :=OldType^.Dat.MarketElement[i].Input.R_Zena;
        MarketElement[i].Input.O_Zena  :=OldType^.Dat.MarketElement[i].Input.O_Zena;
        MarketElement[i].Input.Zakupka :=OldType^.Dat.MarketElement[i].Input.Zakupka;
        MarketElement[i].Input.Zakupka2:=OldType^.Dat.MarketElement[i].Input.Zakupka2;
        MarketElement[i].Input.Proz    :=OldType^.Dat.MarketElement[i].Input.Proz;
       MarketElement[i].Input.VidNDS   :=OldType^.Dat.MarketElement[i].Input.VidNDS;
        MarketElement[i].Input.NDS     :=OldType^.Dat.MarketElement[i].Input.NDS;
     MarketElement[i].Input.VidNalog   :=OldType^.Dat.MarketElement[i].Input.VidNalog;
      MarketElement[i].Input.SpecNalog :=OldType^.Dat.MarketElement[i].Input.SpecNalog;
  MarketElement[i].Input.DiviSionNumber:=OldType^.Dat.MarketElement[i].Input.DiviSionNumber;
       MarketElement[i].Input.Last     :=OldType^.Dat.MarketElement[i].Input.Last;
       MarketElement[i].Input.NSertif  :=OldType^.Dat.MarketElement[i].Input.NSertif;
       MarketElement[i].Input.SertifKol:=OldType^.Dat.MarketElement[i].Input.SertifKol;
       MarketElement[i].Input.NMAkeKod :=OldType^.Dat.MarketElement[i].Input.NMAkeKod;
     MarketElement[i].Input.RegionMarka:=OldType^.Dat.MarketElement[i].Input.RegionMarka;
       MarketElement[i].Input.AkzisSbor:=OldType^.Dat.MarketElement[i].Input.AkzisSbor;
       MarketElement[i].Input.ZenaMarki:=OldType^.Dat.MarketElement[i].Input.ZenaMarki;
       MarketElement[i].Input.Version  :=OldType^.Dat.MarketElement[i].Input.Version;
       MarketElement[i].Input.MarkaKod :=OldType^.Dat.MarketElement[i].Input.MarkaKod;
       MarketElement[i].Input.SMarkaKod:=OldType^.Dat.MarketElement[i].Input.SMarkaKod;
       MarketElement[i].Input.NGTDKod  :=OldType^.Dat.MarketElement[i].Input.NGTDKod;
       MarketElement[i].Input.ExpertKod:=OldType^.Dat.MarketElement[i].Input.ExpertKod;
      MarketElement[i].Input.PartyIDKod:=NoPartyIDStr;;
       MarketElement[i].Input.Srok     :=OldType^.Dat.MarketElement[i].Input.Srok;
     MarketElement[i].Input.Virabotano :=OldType^.Dat.MarketElement[i].Input.Virabotano;
       end;

     for i:=1 to OldType^.Dat.AmountS do
        begin
          DocumentElement[i].BazKod :=OldType^.Dat.DocumentElement[i].BazKod;
          DocumentElement[i].Input.Kol:=OldType^.Dat.DocumentElement[i].Input.Kol;
        DocumentElement[i].Input.Grammi  :=OldType^.Dat.DocumentElement[i].Input.Grammi;
        DocumentElement[i].Input.Skidka  :=OldType^.Dat.DocumentElement[i].Input.Skidka;
        DocumentElement[i].Input.Zena    :=OldType^.Dat.DocumentElement[i].Input.Zena;
        DocumentElement[i].Input.R_Zena  :=OldType^.Dat.DocumentElement[i].Input.R_Zena;
        DocumentElement[i].Input.O_Zena  :=OldType^.Dat.DocumentElement[i].Input.O_Zena;
        DocumentElement[i].Input.Zakupka :=OldType^.Dat.DocumentElement[i].Input.Zakupka;
        DocumentElement[i].Input.Zakupka2:=OldType^.Dat.DocumentElement[i].Input.Zakupka2;
        DocumentElement[i].Input.Proz    :=OldType^.Dat.DocumentElement[i].Input.Proz;
       DocumentElement[i].Input.VidNDS   :=OldType^.Dat.DocumentElement[i].Input.VidNDS;
        DocumentElement[i].Input.NDS     :=OldType^.Dat.DocumentElement[i].Input.NDS;
     DocumentElement[i].Input.VidNalog   :=OldType^.Dat.DocumentElement[i].Input.VidNalog;
      DocumentElement[i].Input.SpecNalog :=OldType^.Dat.DocumentElement[i].Input.SpecNalog;
  DocumentElement[i].Input.DiviSionNumber:=OldType^.Dat.DocumentElement[i].Input.DiviSionNumber;
       DocumentElement[i].Input.Last     :=OldType^.Dat.DocumentElement[i].Input.Last;
       DocumentElement[i].Input.NSertif  :=OldType^.Dat.DocumentElement[i].Input.NSertif;
       DocumentElement[i].Input.SertifKol:=OldType^.Dat.DocumentElement[i].Input.SertifKol;
       DocumentElement[i].Input.NMAkeKod :=OldType^.Dat.DocumentElement[i].Input.NMAkeKod;
     DocumentElement[i].Input.RegionMarka:=OldType^.Dat.DocumentElement[i].Input.RegionMarka;
       DocumentElement[i].Input.AkzisSbor:=OldType^.Dat.DocumentElement[i].Input.AkzisSbor;
       DocumentElement[i].Input.ZenaMarki:=OldType^.Dat.DocumentElement[i].Input.ZenaMarki;
       DocumentElement[i].Input.Version  :=OldType^.Dat.DocumentElement[i].Input.Version;
       DocumentElement[i].Input.MarkaKod :=OldType^.Dat.DocumentElement[i].Input.MarkaKod;
       DocumentElement[i].Input.SMarkaKod:=OldType^.Dat.DocumentElement[i].Input.SMarkaKod;
       DocumentElement[i].Input.NGTDKod  :=OldType^.Dat.DocumentElement[i].Input.NGTDKod;
       DocumentElement[i].Input.ExpertKod:=OldType^.Dat.DocumentElement[i].Input.ExpertKod;
      DocumentElement[i].Input.PartyIDKod:=NoPartyIDStr;
       DocumentElement[i].Input.Srok     :=OldType^.Dat.DocumentElement[i].Input.Srok;
     DocumentElement[i].Input.Virabotano :=OldType^.Dat.DocumentElement[i].Input.Virabotano;
       end;

     Document        := OldType^.Dat.Document;
     DocumentPrz     := OldType^.Dat.DocumentPrz;
     DocumentComment := OldType^.Dat.DocumentComment;
     DateC   := OldType^.Dat.DateC;
     TimeC   := OldType^.Dat.TimeC;
     DateM   := OldType^.Dat.DateM;
     TimeM   := OldType^.Dat.TimeM;
(* *)SertifSummaZ:= OldType^.Dat.SertifSummaZ;
(* *)SertifSkidka:= OldType^.Dat.SertifSkidka;
(* *)SertifSummaZakupka:= OldType^.Dat.SertifSummaZakupka;
(* *)SertifSummaZakupka2:= OldType^.Dat.SertifSummaZakupka2;
     ENalog  := OldType^.Dat.ENalog;
     Nalog5  := OldType^.Dat.Nalog5;
     Nalog3  := OldType^.Dat.Nalog3;
     Nalog_  := OldType^.Dat.Nalog_;
     SummaZ  := OldType^.Dat.SummaZ;
 SummaAkzis  := OldType^.Dat.SummaAkzis;
     Skidka  := OldType^.Dat.Skidka;
SummaZakupka := OldType^.Dat.SummaZakupka;
SummaZakupka2:= OldType^.Dat.SummaZakupka2;
     Otkat   := OldType^.Dat.Otkat;
   SkladKod  := OldType^.Dat.SkladKod;
     Caption := OldType^.Dat.Caption;
     Active  := OldType^.Dat.Active;
     Amount  := OldType^.Dat.Amount;
(**) AmountS := OldType^.Dat.AmountS;
     Locked  := OldType^.Dat.Locked;

LockCaption  := OldType^.Dat.LockCaption;
LockTime     := OldType^.Dat.LockTime;
ComputerNameLocked := OldType^.Dat.ComputerNameLocked;

     Srok    := OldType^.Dat.Srok;
     DocReal := OldType^.Dat.DocReal;
     DocDate := OldType^.Dat.DocDate;
     Rashet  := OldType^.Dat.Rashet;
   Oformlenie:= OldType^.Dat.Oformlenie;
    FromZakaz:= OldType^.Dat.FromZakaz;
     Veksel  := OldType^.Dat.Veksel;
   Exporting := OldType^.Dat.Exporting;
     Comment1 := OldType^.Dat.Comment1;
     Comment2 := OldType^.Dat.Comment2;

      end;


     Write(NewF,NewType^.Dat);
     Writeln('Ok Write');
     IORez:=IOResult;

     Dispose(OldType,Done);
     Dispose(NewType,Done);
   end;

  IORez:=IOResult;
  Close(OldF);
  IORez:=IOResult;
  Close(NewF);
  IORez:=IOResult;

  Rename(OldF,ParamStr(1)+'.bcr');
  IORez:=IOResult;
  Rename(NewF,ParamStr(1)+'.cor');
  IORez:=IOResult;
  Writeln('All Ok');
END.
