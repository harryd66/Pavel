{$DEFINE Converter}

uses Glob,Servstr,Objects;

const CPartyIDKod = 5;
      NoPartyIDStr='00000';

Type NewInputZakazType=Record
        Kol     : String[CKol];
        Zena    : String[CZena];
        Skidka  : String[CZena];
        Proz    : String[CZena];
   InputDiviSion: 1..CDivision;
       NSertif  : ArtikulStr;
       SertifKol: String[CKol];{используется только для товара}
        Version : Word;
       {новые поля}
       MarkaKod : ArtikulStr;
       SMarkaKod: ArtikulStr;
       NGTDKod  : ArtikulStr;
       ExpertKod: ArtikulStr;
      PartyIDKod: String[CPartyIDKod];
       Srok     : LongInt;
     Virabotano : LongInt;
End;

Type NewZakazElementType=Record
      BazKod : String[CArtikul];
      Input  : NewInputZakazType;
End;


Type NewZakazType=Record
            OperatorSelector : Word; {клиент склад обмен заказ}
     DocSelector      : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Versia : Word;
	ShkalaNumer: Word; {временно не используется для совместимости с универсальным форматом всех файлов}
     Processing : Word;
     SkidkaSelector : Word; {вид скидки}
     ClientKod : String[CMakeKod]; {код клиента}
     AgentKod        : String[CMakeKod]; {код агента}
     EkspeditorKod  : String[CMakeKod]; {код агента}
     MarketElement  : Array[1..CMax] Of NewZakazElementType; {информация о проданном товаре}
     DocumentElement: Array[1..CMAx] Of NewZakazElementType; {информация о проданном товаре}
     ElementP       : array[1..CMax] of PredZakazElement;  {у клиента фактически подтвержденные ассортимент и количество}

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
(**) AmountS : Word;  {число сертиикатов в документе}
     AmountP : Word;  {}
     Locked  : Boolean;{сетевая блокировка}
LockCaption  : String[CRazdelKod];
LockTime     : LongInt;
ComputerNameLocked : String[CCNAme];
     Srok    : LongInt;{срок возврата долга}
     EndDate : LongInt;{Срок брони - количество дней отводимых на доставку}
     DocReal : String[CDocNumer];{номер документа по которым идет проплата,используется только для}
     DocDate : TDateString;{документов выводимых после оплаты}
     Rashet  : Word;{0-нал/1-бн/2-вексель}
     Oformlenie : Word;{признак оформления заказа или снятия с брони по времени}

     Status  : Word;{0-стандартная схема резервирования;
                     1-схема резервирования через удаленный доступ}

     PredZakazNumer : LongInt;{по базе предзаказов}
     PredZakazDate  : LongInt;
     PredZakazClient: String[CCLientKod];
     Comment1 : AllStr;
     Comment2 : AllStr;
     Reserv : Word;
     End;

Type
    PNewZakazType = ^NewZakazTypePtr;
    NewZakazTypePtr=Object(TObject)
    Dat  :  NewZakazType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Constructor NewZakazTypePtr.Init ;
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
     MarkaKod [0] :=#0;
     SMarkaKod[0] :=#0;
     NGTDKod  [0] :=#0;
     ExpertKod[0] :=#0;
     Srok     :=0;
     Virabotano :=0;
   End;

    With Dat.ElementP[i] Do
   Begin
       BazKod[0]:=#0;
       Kol   [0]:=#0;
       Zena  [0]:=#0;
       NadoSertif :=0;
       Fakt :=0;
       DivisionNumber :=1;
{!}    Zakupka :=0.00;
       Skidka  :=0.00;
   End;


    With Dat.DocumentElement[i].Input Do
   Begin
     Kol    [0] :=#0;
     Zena   [0] :=#0;
     Proz   [0] :=#0;
     Skidka [0] :=#0;
     InputDivision:=1;
     MarkaKod [0] :=#0;
     SMarkaKod[0] :=#0;
     NGTDKod  [0] :=#0;
     ExpertKod[0] :=#0;
     Srok     :=0;
     Virabotano :=0;
   End;
  End;



   With Dat Do
    Begin
     DocumentComment:=0;
     Document[0]:=#0;
     SummaZ[0]:=#0;
     Caption:=CurrentPassword;
     Locked:=False;
     LockCaption:=CurrentPassword;
     LockTime:=0;
     ComputerNameLocked:=NetComputerName;
     Amount:=0;
     Srok:=0;
     AmountP:=0;
     AmountS:=0;
     DateC:=FDate;
     TimeC:='';
{$IFNDEF Converter}
     SkladKod:=FormKod(Rek^.Dat.Kod); (*******)
{$ENDIF}
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
     EndDAte:=0;
     DocReal[0]:=#0;
     DocDate[0]:=#0;
  Oformlenie:=0;
     Status  :=0;{0-стандартная схема резервирования;
	             1-схема резервирования через удаленный доступ}
     PredZakazNumer :=0;
     PredZakazDate  :=0;
     PredZakazClient[0]:=#0;
     Comment1[0]:=#0;
     Comment2[0]:=#0;
     Versia:=1;
     Reserv :=0;
    End;{With}

End;


Destructor NewZakazTypePtr.Done;
Begin
TObject.Done;
End;



var
    OldType: PZakazType;
    NewType: PNewZakazType;
    OldF: file of ZakazType;
    NewF: file of NewZakazType;
    IORez,i: word;


BEGIN
  Assign(OldF,'zakaz.cor');
  Reset(OldF);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      writeln('Не могу открыть файл zakaz.cor');
      exit;
    end;

  Assign(NewF,'zakaz.ncr');
  Rewrite(NewF);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      writeln('Не могу создать файл zakaz.ncr');
      exit;
    end;

     New(OldType,Init);
     New(NewType,Init);


  while not eof(OldF)do
   begin
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
      OperatorSelector :=OldType^.Dat.OperatorSelector;
      DocSelector      :=OldType^.Dat.DocSelector;
      Versia :=OldType^.Dat.Versia;
	ShkalaNumer:=OldType^.Dat.ShkalaNumer;
      Processing :=OldType^.Dat.Processing;
      SkidkaSelector :=OldType^.Dat.SkidkaSelector;
      ClientKod :=OldType^.Dat.ClientKod;
      AgentKod        :=OldType^.Dat.AgentKod;
      EkspeditorKod  :=OldType^.Dat.EkspeditorKod;

      for i:=1 to OldType^.Dat.Amount do
        begin
          MarketElement[i].BazKod := OldType^.Dat.MarketElement[i].BazKod;
          MarketElement[i].Input.Kol     := OldType^.Dat.MarketElement[i].Input.Kol;
          MarketElement[i].Input.Zena    :=OldType^.Dat.MarketElement[i].Input.Zena;
        MarketElement[i].Input.Skidka  :=OldType^.Dat.MarketElement[i].Input.Skidka;
        MarketElement[i].Input.Proz    :=OldType^.Dat.MarketElement[i].Input.Proz;
   MarketElement[i].Input.InputDiviSion:=OldType^.Dat.MarketElement[i].Input.InputDiviSion;
       MarketElement[i].Input.NSertif  :=OldType^.Dat.MarketElement[i].Input.NSertif;
       MarketElement[i].Input.SertifKol:=OldType^.Dat.MarketElement[i].Input.SertifKol;
        MarketElement[i].Input.Version :=OldType^.Dat.MarketElement[i].Input.Version;
       MarketElement[i].Input.MarkaKod :=OldType^.Dat.MarketElement[i].Input.MarkaKod;
       MarketElement[i].Input.SMarkaKod:=OldType^.Dat.MarketElement[i].Input.SMarkaKod;
       MarketElement[i].Input.NGTDKod  :=OldType^.Dat.MarketElement[i].Input.NGTDKod;
       MarketElement[i].Input.ExpertKod:=OldType^.Dat.MarketElement[i].Input.ExpertKod;
      MarketElement[i].Input.PartyIDKod:=NoPartyIDStr;
       MarketElement[i].Input.Srok     :=OldType^.Dat.MarketElement[i].Input.Srok;
     MarketElement[i].Input.Virabotano :=OldType^.Dat.MarketElement[i].Input.Virabotano;
        end;

        for i:=1 to OldType^.Dat.AmountS do
        begin
          DocumentElement[i].BazKod := OldType^.Dat.DocumentElement[i].BazKod;
          DocumentElement[i].Input.Kol     := OldType^.Dat.DocumentElement[i].Input.Kol;
          DocumentElement[i].Input.Zena    :=OldType^.Dat.DocumentElement[i].Input.Zena;
        DocumentElement[i].Input.Skidka  :=OldType^.Dat.DocumentElement[i].Input.Skidka;
        DocumentElement[i].Input.Proz    :=OldType^.Dat.DocumentElement[i].Input.Proz;
   DocumentElement[i].Input.InputDiviSion:=OldType^.Dat.DocumentElement[i].Input.InputDiviSion;
       DocumentElement[i].Input.NSertif  :=OldType^.Dat.DocumentElement[i].Input.NSertif;
       DocumentElement[i].Input.SertifKol:=OldType^.Dat.DocumentElement[i].Input.SertifKol;
        DocumentElement[i].Input.Version :=OldType^.Dat.DocumentElement[i].Input.Version;
       DocumentElement[i].Input.MarkaKod :=OldType^.Dat.DocumentElement[i].Input.MarkaKod;
       DocumentElement[i].Input.SMarkaKod:=OldType^.Dat.DocumentElement[i].Input.SMarkaKod;
       DocumentElement[i].Input.NGTDKod  :=OldType^.Dat.DocumentElement[i].Input.NGTDKod;
       DocumentElement[i].Input.ExpertKod:=OldType^.Dat.DocumentElement[i].Input.ExpertKod;
      DocumentElement[i].Input.PartyIDKod:=NoPartyIDStr;
       DocumentElement[i].Input.Srok     :=OldType^.Dat.DocumentElement[i].Input.Srok;
     DocumentElement[i].Input.Virabotano :=OldType^.Dat.DocumentElement[i].Input.Virabotano;
        end;

       for i:=1 to OldType^.Dat.AmountP do
        begin
         ElementP[i].BazKod:=OldType^.Dat.ElementP[i].BazKod;
       ElementP[i].Kol   :=OldType^.Dat.ElementP[i].Kol;
       ElementP[i].Zena  :=OldType^.Dat.ElementP[i].Zena;
       ElementP[i].NadoSertif :=OldType^.Dat.ElementP[i].NadoSertif;
       ElementP[i].Fakt :=OldType^.Dat.ElementP[i].Fakt;
       ElementP[i].DivisionNumber :=OldType^.Dat.ElementP[i].DivisionNumber;
       ElementP[i].Zakupka :=OldType^.Dat.ElementP[i].Zakupka;
       ElementP[i].Skidka  :=OldType^.Dat.ElementP[i].Skidka;
      end;


     Document :=OldType^.Dat.Document;
     DocumentComment :=OldType^.Dat.DocumentComment;
     DateC   :=OldType^.Dat.DateC;
     TimeC   :=OldType^.Dat.TimeC;
     DateM   :=OldType^.Dat.DateM;
     TimeM   :=OldType^.Dat.TimeM;

(* *)  SertifSummaZ:=OldType^.Dat.SertifSummaZ;
(* *) SertifSkidka:=OldType^.Dat.SertifSkidka;
     SummaZ  :=OldType^.Dat.SummaZ;
     Skidka  :=OldType^.Dat.Skidka;

   SkladKod  :=OldType^.Dat.SkladKod;
     Caption :=OldType^.Dat.Caption;
     Amount  :=OldType^.Dat.Amount;
(**) AmountS :=OldType^.Dat.AmountS;
     AmountP :=OldType^.Dat.AmountP;
     Locked  :=OldType^.Dat.Locked;
LockCaption  :=OldType^.Dat.LockCaption;
LockTime     :=OldType^.Dat.LockTime;
ComputerNameLocked :=OldType^.Dat.ComputerNameLocked;
     Srok    :=OldType^.Dat.Srok;
     EndDate :=OldType^.Dat.EndDate;
     DocReal :=OldType^.Dat.DocReal;
     DocDate :=OldType^.Dat.DocDate;
     Rashet  :=OldType^.Dat.Rashet;
     Oformlenie :=OldType^.Dat.Oformlenie;

     Status  :=OldType^.Dat.Status;
     PredZakazNumer :=OldType^.Dat.PredZakazNumer;
     PredZakazDate  :=OldType^.Dat.PredZakazDate;
     PredZakazClient:=OldType^.Dat.PredZakazClient;
     Comment1 :=OldType^.Dat.Comment1;
     Comment2 :=OldType^.Dat.Comment2;

      end;
     Write(NewF,NewType^.Dat);
     i:=IOResult;
   end;

  Close(OldF);
  Close(NewF);
  Dispose(OldType,Done);
  Dispose(NewType,Done);

  Rename(OldF,'zakaz.bcz');
  Rename(NewF,'zakaz.cor');
  Writeln('All Ok');
END.