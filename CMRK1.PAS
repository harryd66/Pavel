uses Glob,Serv,Servstr,Objects,TpDate;


Type BakInputMarketType=Record
        Kol     : String[CKol];
        Skidka  : String[CZena];
        Zena    : String[CZena];
        R_Zena  : String[CZena];
        O_Zena  : String[CZena];
        Zakupka : String[CZenaZ];
        Itogo   : String[CInputIZena];
        Proz    : String[CLitr];
       VidNDS   : Word;{ вид налога 0=20% 1=10% 2=прочее}
        NDS     : String[CLitr];
     VidNalog   : Word;{ вид налога 0=5% 1=3% 2=прочее}
      SpecNalog : String[CLitr];
  DiviSionNumber: 1..CDivision;
       Last     : Boolean;
       NSertif  : ArtikulStr;
       SertifKol: String[CKol];{используется только для товара}
      End;


Type BakProdagaElement = Record
     BazKod : String[CArtikul];
     Input  : BakInputMarketType;
     End;




Type BakSuperMarketType=Record
     OperatorSelector:Word; {клиент склад обмен заказ}
     DocSelector : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Versia{ShkalaNumer }: Word; {временно не используется для совместимости с универсальным форматом всех файлов}
     Realiz  : Boolean;     {признак что товар был выдан на реадизацию}
     Bn : BezNal;
     SkidkaSelector : Word; {вид скидки}
     {новая}
     ShkalaNumer: Word; {временно не используется для совместимости с универсальным форматом всех файлов}
     ClientKod : String[CMakeKod]; {код клиента}
     AgentKod        : String[CMakeKod]; {код агента}
     MarketElement   : Array[1..CMax] Of BakProdagaElement; {информация о проданном товаре}
     DocumentElement : Array[1..CMAx] Of BakProdagaElement; {информация о проданном товаре}
     Document : String[CDocNumer]; {номер документа}
     DocumentPrz : String[CDocNumer];{номер последнего акта переоценки}
     DocumentComment : Integer;
     DateC   : TDateString; {дата создания}
     TimeC   : TDateString; {время создания}
     DateM   : TDateString; {дата модификации}
     TimeM   : TDateString; {время модификации}

     SENalog  : String[CIZena];
     SNalog5  : String[CIZena];
     SNalog3  : String[CIZena];
     SNalog_  : String[CIZena];
  {только для сертификатов}
(* *)  SertifSummaZ: String[CIZena];
(* *) SertifSkidka: String[CIZena];
(* *)SertifSummaZakupka: String[CIZena];

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
(**) AmountS  : Word;  {число сертиикатов в документе}
     Locked  : Boolean;{сетевая блокировка}
     Srok    : LongInt;{срок возврата долга}
     DocReal : String[CDocNumer];{номер документа по которым идет проплата,используется только для}
     DocDate : TDateString;{документов выводимых после оплаты}
     Rashet  : Word;{0-нал/1-бн/2-вексель}
     Veksel  : VekselType;
     Comment : AllStr;{комментарий к накладной}
     End;


Type
    PBakSuperMarketType = ^BakSuperMarketPtr;
    BakSuperMarketPtr=Object(TObject)
    Dat  :  BakSuperMarketType;
     Constructor Init;
     Destructor Done; Virtual;
 end;



Constructor BakSuperMarketPtr.Init ;
Var i : Byte;
Begin
TObject.Init;
 For i:=1 To CMax Do
  Begin
    Dat.MarketElement[i].BazKod[0]:=#0;
    With Dat.MarketElement[i].Input Do
   Begin

     NSertif[0] :=#0;
   SertifKol[0] :=#0;

     Kol    [0] :=#0;
     Zena   [0] :=#0;
     R_Zena [0] :=#0;
     O_Zena [0] :=#0;
     Skidka [0] :=#0;
     Zakupka[0] :=#0;
     Itogo  [0] :=#0;
     Proz   [0] :=#0;
     VidNDS :=2;
     NDS    [0] :=#0;
     SpecNalog[0] :=#0;
     VidNalog:=2;
     DivisionNumber:=1;
     LAst :=FAlse;

     NSertif[0] :=#0;
   SertifKol[0] :=#0;
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
     Itogo[0] :=#0;
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
     ENalog  [0]:=#0;
     Nalog5  [0]:=#0;
     Nalog3  [0]:=#0;
     Nalog_  [0]:=#0;

     SummaZ[0]:=#0;
     SummaZakupka[0]:=#0;
     Skidka[0]:=#0;

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
     AmountS:=0;
     DateC[0]:=#0;
     TimeC[0]:=#0;
     DateM:=FDate;
     TimeM:=CurrentTimeString('hh:mm:ss');
     SkladKod:=FormKod(Rek.Kod);
     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     Versia :=1;
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
     DocReal[0]:=#0;
     DocDate[0]:=#0;
     Rashet:=0;

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
     comment[0]:=#0;
    End;{With}
End;





Destructor BakSuperMarketPtr.Done;
Begin
TObject.Done;
End;





var
    OldType: PBakSuperMarketType;
    NewType: PSuperMarketType;
    OldF: file of BakSuperMarketType;
    NewF: file of SuperMarketType;
    IORez,i: word;

BEGIN
  Assign(OldF,'c:\14-08-01.mrk');
  Reset(OldF);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      writeln('Не могу открыть файл ',ParamStr(1)+'.mrk');
      exit;
    end;

  Assign(NewF,ParamStr(1)+'.new');
  Rewrite(NewF);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      writeln('Не могу создать файл ',ParamStr(1)+'.new');
      exit;
    end;

  while not eof(OldF)do
   begin
     New(OldType,Init);
     New(NewType,Init);
     i:=IOResult;
     Read(OldF,OldType^.Dat);
     i:=IOResult;
     If i<>0 Then
      Begin
       Writeln('Ошибка ',i:3);
       Halt;
      End;


     With NewType^.Dat do
      begin
       DocumentComment :=OldType^.Dat.DocumentComment;
       OperatorSelector:=OldType^.Dat.OperatorSelector;
       DocSelector:= OldType^.Dat.DocSelector;
       Versia:= OldType^.Dat.Versia;
       Realiz  := OldType^.Dat.Realiz;
       Bn := OldType^.Dat.Bn;
       SkidkaSelector := OldType^.Dat.SkidkaSelector;
       ShkalaNumer:= OldType^.Dat.ShkalaNumer;
       ClientKod := OldType^.Dat.ClientKod;
       AgentKod  := OldType^.Dat.AgentKod ;

       Amount:=OldType^.Dat.Amount;
       AmountS:=OldType^.Dat.AmountS;

       for i:=1 to Amount do
        begin
          MarketElement[i].BazKod := OldType^.Dat.MarketElement[i].BazKod;
          MarketElement[i].Input.Kol     := OldType^.Dat.MarketElement[i].Input.Kol;
          MarketElement[i].Input.Skidka  := OldType^.Dat.MarketElement[i].Input.Skidka;
          MarketElement[i].Input.Zena    := OldType^.Dat.MarketElement[i].Input.Zena ;
          MarketElement[i].Input.R_Zena  := OldType^.Dat.MarketElement[i].Input.R_Zena;
          MarketElement[i].Input.O_Zena  := OldType^.Dat.MarketElement[i].Input.O_Zena;
          MyStr(StrToReal(OldType^.Dat.MarketElement[i].Input.Zakupka),CZenaZ,CMantissaZ,
		MarketElement[i].Input.Zakupka);

          MyStr(StrToReal(OldType^.Dat.MarketElement[i].Input.Zakupka),CZenaZ,CMantissaZ,
		MarketElement[i].Input.Zakupka2);

          MarketElement[i].Input.Itogo   := OldType^.Dat.MarketElement[i].Input.Itogo;
          MarketElement[i].Input.Proz    := OldType^.Dat.MarketElement[i].Input.Proz;
          MarketElement[i].Input.VidNDS  := OldType^.Dat.MarketElement[i].Input.VidNDS;
          MarketElement[i].Input.NDS     := OldType^.Dat.MarketElement[i].Input.NDS;
          MarketElement[i].Input.VidNalog:= OldType^.Dat.MarketElement[i].Input.VidNalog ;
          MarketElement[i].Input.SpecNalog:=OldType^.Dat.MarketElement[i].Input.SpecNalog ;
          MarketElement[i].Input.DiviSionNumber:= OldType^.Dat.MarketElement[i].Input.DiviSionNumber;
          MarketElement[i].Input.Last     := OldType^.Dat.MarketElement[i].Input.Last;
          MarketElement[i].Input.NSertif  := OldType^.Dat.MarketElement[i].Input.NSertif;
          MarketElement[i].Input.SertifKol:=OldType^.Dat.MarketElement[i].Input.SertifKol;
        End;

       for i:=1 to OldType^.Dat.AmountS do
        begin
          DocumentElement[i].BazKod :=OldType^.Dat.DocumentElement[i].BazKod;
          DocumentElement[i].Input.Kol     := OldType^.Dat.DocumentElement[i].Input.Kol;
          DocumentElement[i].Input.Skidka  := OldType^.Dat.DocumentElement[i].Input.Skidka;
          DocumentElement[i].Input.Zena    := OldType^.Dat.DocumentElement[i].Input.Zena;
          DocumentElement[i].Input.R_Zena  := OldType^.Dat.DocumentElement[i].Input.R_Zena;
          DocumentElement[i].Input.O_Zena  := OldType^.Dat.DocumentElement[i].Input.O_Zena;

          MyStr(StrToReal(OldType^.Dat.DocumentElement[i].Input.Zakupka),CZenaZ,CMantissaZ,
		DocumentElement[i].Input.Zakupka);

          MyStr(StrToReal(OldType^.Dat.DocumentElement[i].Input.Zakupka),CZenaZ,CMantissaZ,
		DocumentElement[i].Input.Zakupka2);

          DocumentElement[i].Input.Itogo   := OldType^.Dat.DocumentElement[i].Input.Itogo;
          DocumentElement[i].Input.Proz    := OldType^.Dat.DocumentElement[i].Input.Proz;
          DocumentElement[i].Input.VidNDS  := OldType^.Dat.DocumentElement[i].Input.VidNDS;
          DocumentElement[i].Input.NDS     := OldType^.Dat.DocumentElement[i].Input.NDS;
          DocumentElement[i].Input.VidNalog:= OldType^.Dat.DocumentElement[i].Input.VidNalog;
          DocumentElement[i].Input.SpecNalog:=OldType^.Dat.DocumentElement[i].Input.SpecNalog;
          DocumentElement[i].Input.DiviSionNumber:= OldType^.Dat.DocumentElement[i].Input.DiviSionNumber;
          DocumentElement[i].Input.Last     :=OldType^.Dat.DocumentElement[i].Input.Last;
          DocumentElement[i].Input.NSertif  :=OldType^.Dat.DocumentElement[i].Input.NSertif;
          DocumentElement[i].Input.SertifKol  :=OldType^.Dat.DocumentElement[i].Input.SertifKol;
        end;

       Document := OldType^.Dat.Document;
       DocumentPrz := OldType^.Dat.DocumentPrz;
       DateC   := OldType^.Dat.DateC;
       TimeC   := OldType^.Dat.TimeC;

       DateM   := OldType^.Dat.DateM;
       TimeM   := OldType^.Dat.TimeM;

       SENalog :=OldType^.Dat.SENalog;
       SNalog5 := OldType^.Dat.SNalog5;
       SNalog3 := OldType^.Dat.SNAlog3;
       SNalog_ := OldType^.Dat.SNalog_;

       SertifSummaZ:= OldType^.Dat.SertifSummaZ;

       SertifSkidka:= OldType^.Dat.SertifSkidka;

       MyStr(StrToReal(
       OldType^.Dat.SertifSummaZakupka),CIZena,CMantissaZ,SertifSummaZakupka);

       MyStr(StrToReal(
       OldType^.Dat.SertifSummaZakupka),CIZena,CMantissaZ,SertifSummaZakupka2);

       ENalog  := OldType^.Dat.ENalog;
       Nalog5  := OldType^.Dat.Nalog5;
       Nalog3  := OldType^.Dat.Nalog3;
       Nalog_  := OldType^.Dat.Nalog_;

       SummaZ  := OldType^.Dat.SummaZ;
       Skidka  := OldType^.Dat.Skidka;

       MyStr(StrToReal(
       OldType^.Dat.SummaZakupka),CIZena,CMantissaZ,SummaZakupka);

       MyStr(StrToReal(
       OldType^.Dat.SummaZakupka),CIZena,CMantissaZ,SummaZakupka2);

       SkladKod:= OldType^.Dat.SkladKod;
       Caption := OldType^.Dat.Caption;
       Active  := OldType^.Dat.Active;
       Amount  := OldType^.Dat.Amount;
       AmountS := OldType^.Dat.AmountS;
       Locked  := OldType^.Dat.Locked;
       Srok    := OldType^.Dat.Srok;
       DocReal := OldType^.Dat.DocReal;
       DocDate := OldType^.Dat.DocDate;
       Rashet  := OldType^.Dat.Rashet;
       Veksel  := OldType^.Dat.Veksel;
       Comment := OldType^.Dat.Comment;

       Oformlenie:=0;
       FromZakaz[0]:=#0;
      end;

     Write(NewF,NewType^.Dat);

     Dispose(NewType,Done);
     Dispose(OldType,Done);
   end;

  Close(OldF);
  Close(NewF);

  Rename(OldF,ParamStr(1)+'.bmr');
  Rename(NewF,ParamStr(1)+'.mrk');
  Writeln('All Ok');
END.