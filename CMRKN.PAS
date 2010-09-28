Uses Glob,ServStr,Serv,Objects,TpDAte;


Type BakInputMarketType=Record
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
     End;



Type BakProdagaElement = Record
     BazKod : String[CArtikul];
     Input  : BakInputMarketType;
     End;


Type BakSuperMarketType=Record
     OperatorSelector:Word; {клиент склад}
     DocSelector : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     ShkalaNumer : Word;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
     Realiz  : Boolean;     {признак что товар был выдан на реадизацию}
     Region  : Word;{офис город область резерв}
     Bn : BezNal;
     SkidkaSelector : Word; {вид скидки}
     ClientKod : String[CMakeKod]; {код клиента}
     AgentKod  : String[CMakeKod]; {код клиента}
     MarketElement : Array[1..CMax] Of BakProdagaElement; {информация о проданном товаре}
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
    PBakSuperMarketType = ^BakSuperMarketPtr;
    BakSuperMarketPtr=Object(TObject)
    Dat  :  BakSuperMarketType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Constructor BAkSuperMarketPtr.Init ;
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
     ShkalaNumer :=0;
     DocReal[0]:=#0;
     DocDate[0]:=#0;
    End;
End;

Destructor BakSuperMarketPtr.Done;
Begin
TObject.Done;
End;



Var BakFile : File Of BakSuperMarketType;
    F :File Of SuperMarketType;
    BakPtr :PBakSuperMarketType;
    Ptr :PSuperMarketType;
    s1,s2:String;
    i : Word;

Begin
s1:=ParamStr(1);
Assign(BakFile,s1+'.mrk');
i:=IOResult;
Reset(BakFile);
i:=IOResult;
If I<>0 Then
 Begin
  Writeln('Не могу открыть '+s1+'.mrk');
  Halt;
 End;

Assign(F,s1+'.new');
i:=IOResult;
Rewrite(F);
i:=IOResult;
If I<>0 Then
 Begin
  Close(BakFile);
  Writeln('Не могу создать '+s1+'.new');
  Halt;
 End;

New(BakPtr,Init);
New(Ptr,Init);

While Not(Eof(BakFile)) Do
 Begin
i:=IOResult;
  Read(BakFile,BakPtr^.Dat);
i:=IOResult;
If I<>0 Then
 Begin
  Writeln('Ошибка чтения'+s1+'.mrk');
 End;
  With Ptr^.Dat Do
   Begin
     OperatorSelector:=BakPtr^.Dat.OperatorSelector;
     DocSelector :=BakPtr^.Dat.DocSelector ;
     ShkalaNumer :=BakPtr^.Dat.ShkalaNumer ;
     Realiz  :=BakPtr^.Dat.Realiz  ;
     Bn :=BakPtr^.Dat.Bn ;
     SkidkaSelector :=BakPtr^.Dat.SkidkaSelector ;
     ClientKod :=BakPtr^.Dat.ClientKod ;
     AgentKod :=BakPtr^.Dat.AgentKod ;
     Region :=BakPtr^.Dat.Region ;

     PrhNumer[0]:=#0;
     SfNumer[0]:=#0;
     NaklNumer[0]:=#0;

     For i:=1 To CMax Do
      Begin
       With Ptr^.Dat.MarketElement[i] Do
        Begin
         BazKod:=BakPtr^.Dat.MarketElement[i].BazKod;
          With Ptr^.Dat.MarketElement[i].Input Do
           Begin
             Kol     :=BakPtr^.Dat.MarketElement[i].InPut.Kol;
             Zena    :=BakPtr^.Dat.MarketElement[i].InPut.Zena    ;
             R_Zena  :=BakPtr^.Dat.MarketElement[i].InPut.R_Zena  ;
             O_Zena  :=BakPtr^.Dat.MarketElement[i].InPut.O_Zena  ;
             Skidka  :=BakPtr^.Dat.MarketElement[i].InPut.Skidka  ;
             Itogo   :=BakPtr^.Dat.MarketElement[i].InPut.Itogo ;
             Zakupka :=BakPtr^.Dat.MarketElement[i].InPut.Zakupka;
             Proz    :=BakPtr^.Dat.MarketElement[i].InPut.Proz;
             NDS     :=BakPtr^.Dat.MarketElement[i].InPut.NDS;
             VidNds  :=BakPtr^.Dat.MarketElement[i].InPut.VidNDS;
             VidNalog:=BakPtr^.Dat.MarketElement[i].InPut.VidNalog;
             SpecNalog :=BakPtr^.Dat.MarketElement[i].InPut.SpecNAlog;
       DivisionSNumber:=BakPtr^.Dat.MarketElement[i].InPut.DivisionSNumber;
             Last     :=BakPtr^.Dat.MarketElement[i].InPut.Last;
             Osn.NaklNumer[0]:=#0;
             Osn.DateNakl[0]:=#0;
           End;
        End;
      End;

    Document :=BakPtr^.Dat.Document ;
 DocumentPrz :=BakPtr^.Dat.DocumentPrz ;
     DateC   :=BakPtr^.Dat.DateC   ;
     TimeC   :=BakPtr^.Dat.TimeC   ;
     DateM   :=BakPtr^.Dat.DateM   ;
     TimeM   :=BakPtr^.Dat.TimeM   ;
     ENalog  :=BakPtr^.Dat.ENAlog;
     Nalog5  :=BakPtr^.Dat.NAlog5;
     Nalog3  :=BakPtr^.Dat.NAlog3;
     Nalog_  :=BakPtr^.Dat.NAlog_;
     SummaZ  :=BakPtr^.Dat.SummaZ  ;
     Skidka  :=BakPtr^.Dat.Skidka  ;
SummaZakupka :=BakPtr^.Dat.SummaZakupka;
  SkladKod   :=BakPtr^.Dat.SkladKod;
     Caption :=BakPtr^.Dat.Caption ;
     Active  :=BakPtr^.Dat.Active  ;
     Amount  :=BakPtr^.Dat.Amount  ;
     Locked  :=BakPtr^.Dat.Locked  ;
     Srok    :=BakPtr^.Dat.Srok    ;
     DocReal :=BakPtr^.Dat.DocReal ;
     DocDate :=BakPtr^.Dat.DocDate ;
   End;
   seek(f,filesize(f));
   Write(f,ptr^.dat);
 End;
Dispose(BakPtr,Done);
Dispose(Ptr,Done);
Close(BakFile);
Close(f);
Rename(BakFile,s1+'.bak');
Rename(F,s1+'.mrk');
End.


