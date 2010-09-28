{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit Vision7;

Interface

Uses Glob,ServStr,Dialogs,Utils,Vision1;

Procedure CalcDolgDebitRazdel;
Function  CalcDolgBarter(Regim:Boolean):TMyString;
Procedure FormNaklTTN(Space :TDateString; Video : Boolean;As :DocumentEditZ;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Float;
                            ShowAnswer:Boolean;Zakaz:Boolean;NewSkidka:Boolean;NewSum:Float);
Procedure CalcDolgDebitDate;

Procedure TestDocumentsList(Video:Boolean;Kod : ArtikulStr;Var M:Maska55;E:SuperMarketType;OperatorSelector:Word);


Implementation


Uses DBEngine,MsgBox,Views,Propiss,TpDate,Access3,Tools,Serv,
     NetDBEng,Printers,Objects,Prise,Vision5,UKAssa;




VAr LocalTempBox,TempBox : PBox;




Procedure FormNaklTTN(Space :TDateString; Video : Boolean;As :DocumentEditZ;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Float;
                            ShowAnswer:Boolean;Zakaz:Boolean;NewSkidka:Boolean;NewSum:Float);
Var l : Word;
    Ver,s,sc,ws,ws1,ws2,ws3 : String;
    Ss,ss1 : String;
    st : String[CMantissa];
    pp : String[CPack];
    TTT,ItogoS,NdsPos :Real;
    Local,R : Boolean;
    M : Maska8;
    c : Word;
    Dop : TDateString;
    Nalog,Massa:TDateString;
    tempSkidka,tt1,tt2,WspomSkidka,
    OutputSklad,InputSklad,koefficient:ALLStr;
    DrawSkidka:Boolean;
    Barter : String[CMantissa];
    TempZakupka : AllStr;
    AllMassa,Separator : TMyString;
    EdIzm: STring[CMera];
    Z,Zen,Sum:String[CIZena];
    Postawshik,GruzoOtpravitel,
    Gruzopolushatel,Platelshik : String;
    Rek1 : PRekwiziti;
    Symbol :ArtikulStr;
    cl : PClientType;
    Skl : PExtSkladType;
    SklB : PSkladType;
    BBB,BBBS : PBazType;
    zakaznumer,ZakazDate,ZakazTime : AllStr;
    WithOutZena,SumOut : AllStr;
    SummaOutNDS:AllStr;
    Otsroshka : Word;

Begin
New(Rek1,Init);

{$IfDEF DPMI}
   If E^.Dat.DocSelector in [2,3,4,5,7,6,8] Then Rek1^.Dat:=RekSF^.Dat
   Else Rek1^.Dat:=Rek^.Dat;

   ItogoS:=0; ItogoSkidka:=0; Itogo:=0; NdsPos:=0;

   Dop[0]:=#0;
   R:=False;

   If E^.Dat.OperatorSelector in [0,2] Then Local:=False
   Else Local:=True;


   For l:=1 To E^.Dat.Amount Do
   Begin
   MyStr(StrToReal(E^.Dat.MarketElement[l].Input.Zena)*StrToInt(E^.Dat.MarketElement[l].Input.Kol)
   ,CIZena,CMantissa,ws);
   Itogo:=Itogo+StrToReal(Ws);
   End;


   DrawSkidka:=True;

   If ShowAnswer Then
   Begin

   If Not(LoCal) Then
   Begin
    If (StrToInt(E^.DAt.AgentKod)<>0) Then
       Begin
        If MessageBox(^M+#3'Включать ставки скидок в накладную?',Nil,mfWarning+mfOkCancel)=cmcancel Then
        DrawSkidka:=False;
       End;{служба доставки}
   End;
   End;

DInfoMsg('Формирую товарно-транспортную накладную. Ждите...',True);

Writeln(Txt,Space+Dop+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt,Space+Dop+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');

WriteLn(Txt,Space+Dop+'Экспедитор: '+Bold[NPrint.Printer]+Italic[NPrint.Printer]+GetEkspedField(FAgent,E^.Dat.EkspeditorKod)+
                           NoItalic[NPrint.Printer]+NoBold[NPrint.Printer]);



Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'                                                                            '+
'                                   Форма по ОКУД  0345009');
If E^.Dat.OperatorSelector<>2 Then Barter[0]:=#0
Else Barter:='-Б';

DelSpace(E^.DAt.Document);
DelSpace(E^.DAt.DateC);
DelZerro(E^.DAt.Document);
Z:=Rek^.Dat.Kod;
DelZerro(z);

{формируем строку поставщика}
Postawshik:=Rek1^.Dat.NAme;
DelSpaceRight(Postawshik);
ws:=Rek1^.Dat.Adress;
DelSpaceRight(ws);
Postawshik:=Postawshik+','+ws;
ws:=Rek1^.Dat.INN;
DelSpaceRight(ws);
Postawshik:=Postawshik+',ИНН '+ws;
Format(Postawshik,98);
Postawshik:=Postawshik+' '+'по ОКПО ';
ws:=Rek1^.Dat.Okpo;
DelSpaceRight(ws);
Postawshik:=Postawshik+' '+ws;
{сформировали строку поставщика}
Writeln(txt,Space+Dop+'       Поставщик: '+Postawshik);

{формируем строку Грузоотправителя}
GruzoOtpravitel:=Rek1^.Dat.NAme;
DelSpaceRight(GruzoOtpravitel);
ws:=GetMAkeField(FClient,Rek1^.Dat.Kod,1);
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+',Склад '+ws+',';
ws:=Rek1^.Dat.AdressGruza;
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+ws+',';
ws:=Rek1^.Dat.LizensiaOPTL_V;
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+' Лицензия '+ws;
Format(GruzoOtpravitel,98);
GruzoOtpravitel:=GruzoOtpravitel+' '+'по ОКПО ';
ws:=Rek1^.Dat.Okpo;
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+' '+ws;
{сформировали строку Грузоотправителя}
Writeln(txt,Condensed[NPrint.Printer]+
Space+Dop+'Грузоотправитель: '+GruzoOtpravitel);

{формируем строку Грузополучателя}
New(Cl,Init);
Cl^.Dat.Kod:=E^.Dat.ClientKod;
GetClient(CL,E^.Dat.OperatorSelector);
GruzoPolushatel:=Cl^.Dat.Name{Enviropment{GetClientField(FClient,E^.DAt.ClientKod,E^.DAt.OperatorSelector)};
DelSpaceRight(GruzoPolushatel);
ws:=Cl^.Dat.Adress;{GetClientField(FAdress,E^.DAt.ClientKod,E^.DAt.OperatorSelector)}
DelSpaceRight(ws);
GruzoPolushatel:=GruzoPolushatel+'('+E^.DAt.ClientKod+')'+','+ws+',';
ws:=Cl^.Dat.Enviropment{GetClientField(FEnvir,E^.DAt.ClientKod,E^.DAt.OperatorSelector)};
DelSpaceRight(ws);
GruzoPolushatel:=GruzoPolushatel+'Лицензия '+ws;
Format(GruzoPolushatel,98);
GruzoPolushatel:=GruzoPolushatel+' '+'по ОКПО ';
ws:=Cl^.Dat.OKPO{GetClientField(FOKPO,E^.DAt.ClientKod,E^.DAt.OperatorSelector)};
DelSpaceRight(ws);
GruzoPolushatel:=GruzoPolushatel+' '+ws;
{сформировали строку Грузоотправителя}
Writeln(txt,Space+Dop+' Грузополучатель: '+GruzoPolushatel);

{формируем строку Плательщика}
Platelshik:=Cl^.Dat.FullName{GetClientField(FClient,E^.DAt.ClientKod,E^.DAt.OperatorSelector)};
DelSpaceRight(Platelshik);
ws:=Cl^.Dat.Adress{GetClientField(FAdress,E^.DAt.ClientKod,E^.DAt.OperatorSelector)};
DelSpaceRight(ws);
Platelshik:=Platelshik+'('+E^.DAt.ClientKod+')'+','+ws+',ИНН ';
ws:=Cl^.Dat.INN{GetClientField(FINN,E^.DAt.ClientKod,E^.DAt.OperatorSelector)};
DelSpaceRight(ws);
Platelshik:=Platelshik+ws;
Format(Platelshik,98);
Platelshik:=Platelshik+' '+'по ОКПО ';
ws:=Cl^.Dat.OKPO{GetClientField(FOKPO,E^.DAt.ClientKod,E^.DAt.OperatorSelector)};
DelSpaceRight(ws);
Platelshik:=Platelshik+' '+ws;
{сформировали строку Плательщика}
Writeln(txt,Space+Dop+'      Плательщик: '+Platelshik);

{вид скидки и версия}
   If E^.Dat.SkidkaSelector=0 Then Ver:=Space+'Скидка: Авто '
   Else Ver:=Space+'Скидка: Ручная';

   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   zakazTime[0]:=#0;
(* отключено 26/03/01 из-за проблем в бухгалтерии*)



{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
     ZakazTime:=GetZakazDate(E^.DAt.FromZakaz,FieldTime);
    End
    Else
     Begin
      ZakazDate:=E^.Dat.DateC;
      ZakazTime:=E^.Dat.TimeC;
     End;
End
 Else
  Begin
      ZakazDate:=E^.Dat.DateC;
      ZakazTime:=E^.Dat.TimeC;
  End;



   If (E^.Dat.Versia>1) And ((Not(E^.Dat.Realiz)) Or ((E^.Dat.Realiz)And Not(E^.Dat.DocSelector in [0,1,2,3,4])))
     Then
    Begin
     Ver:=Ver+'                                                     Версия: '+IntToStr(E^.Dat.Versia,CLitrMantissa);
    End;

   Writeln(txt,Space+Dop+NoCondensed[NPrint.Printer]+ver);
{конец вид скидки и версия}


If E^.Dat.DocSelector in [5,6,7,8] Then
Begin
 Writeln(Txt,Space+Dop+Bold[NPrint.Printer]+Double[NPrint.Printer]+'Протокол приема-передачи к договору N: ',
 Cl^.Dat.Dogovor,NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);

 Writeln(Txt,Space+Dop+Bold[NPrint.Printer]+'Срок консигнации до: '+DateToDateString(DateMask,E^.Dat.Srok)+
 NoBold[NPrint.Printer]);
End;


DelSpace(E^.Dat.Document);
Space:='';

{
   If Not Zakaz Then
   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer[0]:=#0;
     If Video Then
     Writeln(txt,Space+Dop+'По заказу N '+E^.DAt.FromZakaz)
     Else
     Writeln(txt,Space+Dop+Italic[NPrint.Printer]+'По заказу N '+E^.DAt.FromZakaz+
        +NoItalic[NPrint.Printer]);
    End;
}


Writeln(txt,NoCondensed[NPrint.Printer]);

If E^.DAt.OperatorSelector in [0,2] Then
Writeln(txt,Header+Space+Dop+'   ТОВАРНО-ТРАНСПОРТНАЯ   Н А К Л А Д Н А Я   N     '+
zakaznumer+E^.DAt.Document+barter+'/'+Z+'  от '+ZakazDate+' ('+ZakazTime+')'++HeaderStop)
Else
Writeln(txt,Header+Space+'ТОВАРНО-ТРАНСПОРТНАЯ  Н А К Л А Д Н А Я (межскладская перевозка) N '+
zakaznumer+E^.DAt.Document+barter+'/'+Z+'  от '+ZakazDate+' ('+ZakazTime+')'+HeaderStop);

Writeln(txt,Space+Dop+'     1. ТОВАРНЫЙ РАЗДЕЛ (заполняется грузоотправителем)'+Condensed[NPrint.Printer]);

(* отключено 26/03/01 из-за проблем в бухгалтерии*)

Writeln(txt,Header+Condensed[NPrint.Printer]+HeaderStop);

If E^.Dat.Oformlenie=1 Then
Writeln(txt,Space+Italic[NPrint.Printer]+Double[NPrint.Printer]+
E^.Dat.Document+barter+'/'+Z+' '+E^.Dat.DateC+' ('+E^.Dat.TimeC+')'+
NoItalic[NPrint.Printer]+NoDouble[NPrint.Printer]);


 If E^.Dat.Oformlenie=1 Then
 Writeln(txt,Header+Space+Dop+Italic[NPrint.Printer]+'По заказу N '+E^.DAt.FromZakaz+NoItalic[NPrint.Printer]++HeaderStop);



Space:=' ';

 If (E^.Dat.OperatorSelector in [0,2]) Then
 Begin
Writeln(txt,Header+Space+MinInterval2[NPrint.Printer]+Dop+
                      '┌─┬─────┬──────────────────────────┬───────────────┬───┬─────┬──────────┬─────────┬────────┬─────────────┬──────────────┬─────────────┬───┬───────┐');
Writeln(txt,Space+Dop+'│N│ Код │ Наименование товара,     │Единица        │   │Колич│Количество│  Масса  │        │  Сумма без  │    Н Д С     │ Итого сумма,│   │       │');
Writeln(txt,Space+Dop+'│ │     │ характеристики, производ.│измерения      │Фас│един.│ упаковок │брутто,кг│Цена,руб│  учета НДС  │Ставка   Сумма│     руб     │Отд│Примеч.│');
Writeln(txt,Space+Dop+'└─┴─────┴──────────────────────────┴───────────────┴───┴─────┴──────────┴─────────┴────────┴─────────────┴──────────────┴─────────────┴───┴───────┘'
+Normal[NPrint.Printer]+HeaderStop);
 End
  Else
  Begin
{$IFNDEF TABAK}
Writeln(txt,Header+Space+Dop+MinInterval2[NPrint.Printer]+
'┌─┬─────┬──────────────────────────┬───────────────┬───┬─────┬──────────┬─────────┬────────┬─────────'+
'────┬──────────────┬─────────────┬───┬──────┬──────┐');
Writeln(txt,Space+Dop+'│N│ Код │  Наименование товара,    │ Единица       │   │Колич│Количество│  Масса  │        │  Сумма б'+
'ез  │    Н Д С     │ Итого сумма,│   │Ставка│      │');
Writeln(txt,Space+Dop+'│ │     │ характеристики, производ.│ измерения     │Фас│един.│ упаковок │брутто,кг│Цена,руб│  учета Н'+
'ДС  │Ставка   Сумма│     руб     │Отд│  НП  │Примеч│');
Writeln(txt,Space+Dop+'└─┴─────┴──────────────────────────┴───────────────┴───┴─────┴──────────┴─────────┴────────┴─────────'+
'────┴──────────────┴─────────────┴───┴──────┴──────┘'+Normal[NPrint.Printer]+HeaderStop);

{$ELSE}

Writeln(txt,Header+Space+Dop+MinInterval2[NPrint.Printer]+
'┌─┬─────┬──────────────────────────┬───────────────┬───┬─────┬──────────┬─────────┬────────┬─────────'+
'────┬──────────────┬─────────────┬───┬──────┬──────┐');
Writeln(txt,Space+Dop+'│N│ Код │ Наименование товара,     │Единица        │   │Колич│Количество│  Масса  │        │  Сумма б'+
'ез  │     Н Д С    │             │   │Ставка│      │');
Writeln(txt,Space+Dop+'│ │     │ характеристики, производ.│измерения      │Фас│един.│ упаковок │брутто,кг│Цена,руб│  учета Н'+
'ДС  │Ставка   Сумма│ З/Цена,руб  │Отд│  НП  │Примеч│');
Writeln(txt,Space+Dop+'└─┴─────┴──────────────────────────┴───────────────┴───┴─────┴──────────┴─────────┴────────┴─────────'+
'────┴──────────────┴─────────────┴───┴──────┴──────┘'+Normal[NPrint.Printer]+HeaderStop);


{$ENDIF}
  End;
              { 1 12345│12345678901234567890123456│12345│12345678│12345│1234567890123│123456789│123│1234567│}


   c:=0;
   AllMAssa[0]:=#0;
   SummaOutNDS[0]:=#0;
   WordToBit8(c,M);
   For l:=1 To E^.Dat.Amount Do
    Begin
     Str(l:CMantissa,St);
     s:=E^.Dat.MarketElement[l].BazKod;

     New(Skl,Init);
     New(SklB,Init);
     New(BBB,Init);
     Skl^.Dat.BazKod:=E^.Dat.MarketElement[l].BazKod;
     SklB^.Dat.BazKod:=E^.Dat.MarketElement[l].BazKod;
     GetExtSkladRecord(Skl);
     GetSkladRecord(SklB);
     GetBazElement(E^.Dat.MarketElement[l].BazKod,BBB^.Dat);


     If Not(E^.DAt.MarketElement[l].Input.Last) Then
     Separator:=' '   Else Separator:=#249;

     If NPrint.FullName=0 Then
     Begin
      ws:=BBB^.Dat.Name{GetIdField(FName,E^.Dat.MarketElement[l].BazKod)};
      ws1:=BBB^.Dat.Name2{GetIdField(FName2,E^.Dat.MarketElement[l].BazKod)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
           Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+st+Separator+s+' '+ws);
        Separator:=' ';
        st:='  ';
        ws:=ws1;
        s:='     ';
       End;
     End
     Else
         Begin
          ws:=BBB^.Dat.Name;
       ws1:=BBB^.Dat.Name2;
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
          Begin
           Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+st+Separator+S+' '+ws);
        Separator:=' ';
        st:='  ';
        ws:=ws1;
        s:='     ';
       End;
      End;

     Format(ws,CName);
     s:=s+' '+ws;

     EdIzm[0]:=#0;
     EdIzm:=BBB^.Dat.Mera{GetIdField(FMera,E^.Dat.MarketElement[l].BazKod)};
     Format(EdIzm,CMera);
     s:=s+' '+EdIzm;

     EdIzm[0]:=#0;
     EdIzm:=BBB^.Dat.InPack{GetIdField(FInPack,E^.Dat.MarketElement[l].BazKod)};
     Format(EdIzm,CInPack);
     s:=s+' '+EdIzm;


     DelSpace(E^.Dat.MarketElement[l].Input.Kol);
     ws:=E^.Dat.MarketElement[l].Input.Kol;
     ws:='{'+ws+'}';
     RFormat(ws,CKol+2);
     s:=s+{' '}+ws;

     pp:=CalcPackNoFile({E^.Dat.MarketElement[l].BazKod}BBB^.Dat.InPack,E^.Dat.MarketElement[l].Input.Kol);
     DelSpace(pp);
     RFormat(pp,CPack);
     s:=s+' '+pp;

     Massa[0]:=#0;
     Massa:=BBB^.Dat.Massa{GetIdField(FMassa,E^.Dat.MarketElement[l].BazKod)};
     Format(Massa,CMassa);
     MyStr(StrToInt(E^.Dat.MarketElement[l].Input.Kol)*
              StrToReal(Massa),CMassa+2,CLitrMantissa,Massa);
     Str(StrToReal(AllMAssa)+StrToReal(Massa):CIZena:CLitrMAntissa,AllMAssa);
     s:=s+' '+MAssa+' ';

     {прибавили массу брутто товара}

     Str(StrToReal(E^.Dat.MarketElement[l].Input.Zakupka):CInputIZena:CMantissaZ,TempZakupka);

     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(E^.Dat.MarketElement[l].Input.Proz);
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[l].Input.Proz)/100)),CZena,CMantissa,ws);
      End
     Else
      Begin
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Skidka))
       ,CZena,CMantissa,ws);
      End;

       {отключен расчет налога с продажи}
       {по всем видам документов}
       If E^.DAt.DocSelector in [{1,2,3,5,6}100] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);
       {новая цена}

{$IFDEF NSP}
       MyStr(StrToReal(ws)/StrToReal(Koefficient),CZena,CMantissa,WithOutZena);
{$ELSE}
       MyStr(StrToReal(ws),CZena,CMantissa,WithOutZena);
{$ENDIF}
       End
       Else WithOutZena:=ws;
       Zen:=ws;

       s:=s+Zen;{прибавили цену за единицу товара с учетом скидки}

       MyStr((StrToReal(Zen)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
       ,CInputIZena,CMantissa,sum);

       ItogoS:=ItogoS+StrToReal(Sum);

       MyStr((StrToReal(WithOutZena)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
       ,CInputIZena,CMantissa,sumOut);

       NdsPos:=StrToReal(SumOut)*StrToReal(E^.Dat.MarketElement[l].Input.NDS)/
       (100+StrToReal(E^.Dat.MarketElement[l].Input.NDS));

       MyStr(NdsPos,CZena,CMantissa,ws);{сумма ндс в позиции}
       NdsPos:=StrToReal(Ws);
       MyStr(StrToReal(Sumout)-StrToReal(ws),CInputIZena,CMAntissa,ws1);{сумма без учета ндс в позиции}

       MyStr(StrToREal(SummaOutNDS)+StrToReal(ws1),CInputIZena,CMAntissa,SummaOutNDS);

       s:=s+' '+ws1;

       ws2:=E^.Dat.MarketElement[l].Input.NDS;
       MyStr(StrToReal(ws2),CLitr,CMantissa,ws2);
       s:=s+' '+ws2;{ставка ндс}
       s:=s+' '+ws;{сумма ндс в позиции}
       ws[0]:=#0;

{$IFNDEF TAbak}
       If E^.Dat.OperatorSelector=0 Then
       s:=s+' '+Sum
       Else
       s:=s+' '+Sum;
{$ELSE}
       If E^.Dat.OperatorSelector in [0,2] Then
       s:=s+' '+Sum
       Else
       s:=s+' '+TempZakupka;
{$ENDIF}

      M[E^.Dat.MarketElement[l].Input.DivisionNumber]:=1;

     {добавили отделение}
     Str(E^.Dat.MarketElement[l].Input.DivisionNumber:2,ws);

  If E^.Dat.OperatorSelector=1 Then
    Begin
     Nalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
     MyStr(StrToReal(Nalog),CLitr,CMantissa,Nalog);
     ws:=ws+' '+Nalog;
    End;

      {Если скидка автоматическая и не нулевая}
      Case E^.Dat.SkidkaSelector Of
      0:Begin{скидка автоматическая}

       Case NPrint.FullSkidka Of
       0:Begin{скидка в процентах}
         If DrawSkidka Then
         Begin
          If (StrToReal(E^.Dat.MarketElement[l].Input.Proz)<>0) Then
           Begin
            TempSkidka:=E^.Dat.MarketElement[l].Input.Proz;

            Format(TempSkidka,CKol+1);
            {если на экран}
            If Video Then ws:=ws+' ('+TempSkidka+')'
            {если на печать}
            Else ws:=ws+' ('+TempSkidka+')';
           End
            Else ws:=ws+'  '+'_______';
          End{DrawSkidka}
         Else
          Begin
           ws:=ws+'  '+'_______';
          End;
         End;{Case FullSkidka 0}

       1:Begin {абсолютная велечина скидки}
         If DrawSkidka Then
         Begin
          If (StrToReal(E^.Dat.MarketElement[l].Input.Proz)<>0) Then
           Begin
            MyStr(StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Zena)/
            (1+StrToReal(E^.Dat.MarketElement[l].Input.Proz)/100),CKol+1,CMantissa,WspomSkidka);
            DelSpace(WspomSkidka);
            Format(WspomSkidka,CKol+1);
            If Video Then ws:=ws+' ('+WspomSkidka+')'
            {если на печать}
            Else ws:=ws+' ('+WspomSkidka+')';
           End
            Else ws:=ws+'  '+'_______';
         End{DrawSkidka}
         Else
          Begin
           ws:=ws+'  '+'_______';
          End;
         End;{Case FullSkidka 1}
       2: Begin
           ws:=ws+'  '+'_______';
          End;
         Else;
         End;{Case FullSkidka}
        End;{0 Case}
      1:Begin{скидка ручная}

        Case NPrint.FullSkidka Of
        0:Begin{скидка в процентах}
         If DrawSkidka Then
         Begin
         If (Abs(StrToReal(E^.Dat.MarketElement[l].Input.Skidka))>=0.01) Then
          Begin
           If StrToReal(E^.Dat.MarketElement[l].Input.Skidka)>0 Then
            Begin
             If (StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Skidka))>0.009 Then
             MyStr(((StrToReal(E^.Dat.MarketElement[l].Input.Zena))/((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-
             StrToReal(E^.Dat.MarketElement[l].Input.Skidka)))-1)*100
             ,CKol+1,CLitrMantissa,WspomSkidka)
             Else
             WspomSkidka:='100.00';

             MyStr(StrToReal(WspomSkidka){*100},CKol+1,CMantissa,WspomSkidka);
            End
            Else
             Begin
              MyStr((-(Abs(StrToReal(E^.Dat.MarketElement[l].Input.Skidka)))/
              ((StrToReal(E^.Dat.MarketElement[l].Input.Zena)))*100),CKol+1,CMantissa,WspomSkidka);
             End;
            DelSpace(WspomSkidka);
            Format(WspomSkidka,CKol+1);
            {если на экран}
            If Video Then ws:=ws+' ('+WspomSkidka+')'
            {если на печать}
            Else ws:=ws+' ('+WspomSkidka+')';
          End
          Else ws:=ws+'  '+'_______';
         End {DrawSkidka}
         Else
          Begin
           ws:=ws+'  '+'_______';
          End;
          End;{Case FillSkidka 0}
        1:Begin{абсолютная велечина скидки}
        If DrawSkidka Then
        Begin
         If (Abs(StrToReal(E^.Dat.MarketElement[l].Input.Skidka))>0.01) Then
          Begin
           MyStr(StrToReal(E^.Dat.MarketElement[l].Input.Skidka),CKol+1,CMantissa,
           E^.Dat.MarketElement[l].Input.Skidka);
           DelSpace(E^.Dat.MarketElement[l].Input.Skidka);
           Format(E^.Dat.MarketElement[l].Input.Skidka,CKol+1);
           WspomSkidka:=E^.Dat.MarketElement[l].Input.Skidka;

           If Video Then ws:=ws+' ('+WspomSkidka+')'
           {если на печать}
           Else ws:=ws+' ('+WspomSkidka+')';
          End
          Else ws:=ws+'  '+'_______';
        End
         Else
          Begin
             ws:=ws+'  '+'_______';
          End;
          End;{Case FullSkidka 1}
       2: Begin
           ws:=ws+'  '+'_______';
          End;
          Else;
          End;{Case FullSkidka}

        End;{1 Case}

      Else;{Case}
      End;{Case}

     s:=Pitch[NPrint.Printer]+Condensed[NPrint.Printer]++s+' '+ws+NoPitch[NPrint.Printer]+
     Condensed[NPrint.Printer];


 If DefaultSetMArker=1 Then
 Begin
 If E^.DAt.MarketElement[l].Input.RegionMArka=0 Then s:=s+' '+NoMArker
 Else s:=s+' '+YesMArker;
 End;


{    If Not(E^.DAt.MarketElement[l].Input.Last) Then
     Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+St+Separator+s)
     Else}

     If l=E^.Dat.Amount Then s:=ONLYLINK+s;

     Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+St+Separator+s);




     If E^.Dat.OperatorSelector in [0,2] Then
     Begin
     If PrintSertifDoc[2]=1 Then
      Begin
       If (E^.Dat.MarketElement[l].Input.NSertif[0]<>#0) And
             (E^.Dat.MarketElement[l].Input.NSertif<>NoSertifStr) Then
       Begin
If (E^.Dat.DocSelector<>1) Then
Begin
New(BBBS,Init);
GetBazElement(E^.Dat.MarketElement[l].Input.NSertif,BBBS^.Dat);

           ws1:=BBBS^.Dat.Name{GetIdField(FName,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws1);
        ws2:=BBBS^.Dat.Name2{GetIdField(FName2,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws2);
           ws2:=ws1+' '+ws2;
           DelSpaceRight(ws2);
        If Not Video Then
           Write(txt,Condensed[NPrint.Printer]+Space+' Сертификат: ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
           Condensed[NPrint.Printer]+ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')'+NoDouble[NPrint.Printer]+
           NoItalic[NPrint.Printer])
        Else
           Write(txt,Condensed[NPrint.Printer]+Space+' Сертификат: ',ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')');

      ws1:=BBBS^.Dat.DSertif{GetIDField(FDateSertif,E^.Dat.MarketElement[l].Input.NSertif)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
        If Not(Video) Then
        Begin
         If ws2[0]<>#0 Then
            WriteLn(txt,Condensed[NPrint.Printer]+Space+' Срок дейст: ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
            Condensed[NPrint.Printer]+ws1+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer]+' ')
         Else
            WriteLn(txt,Condensed[NPrint.Printer]+Space+'   Срок дейст: ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
            Condensed[NPrint.Printer]+ws1+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer]+' ')
        End
        Else
        BEgin
         If ws2[0]<>#0 Then
             WriteLn(txt,Space+' Срок дейст: ',+ws1+' ')
         Else
             WriteLn(txt,Space+'    Срок дейст: ',+ws1+' ');
        End
          End
      Else
      If ws2[0]<>#0 Then Writeln(txt);
Dispose(BBBS,Done);
End;{если не товарный чек}
       End;{сертификаты}
      End;

{
     If PrintAkzisDoc[2]=1 Then
     Begin
       ss:=Skl^.Dat.Input.Akzis1;
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CSertif);
         If Not(Video) Then ss:=Italic[NPrint.Printer]+Double[NPrint.Printer]+
            Condensed[NPrint.Printer]+ss+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer];
         If Video Then
         ss:=Space+'    Примечание: '+ss
         Else ss:=Condensed[NPrint.Printer]+Space+'    Примечание: '+ss;
         Writeln(txt,ss);
        End;
     End;
}
     If PrintAkzisDate[2]=1 Then
      Begin
       ws1:=Skl^.Dat.Input.Marka{BakGetField(FMarka,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
         Begin
          If Not Video Then
          Write(txt,Condensed[NPrint.Printer]+Space+Seria_Akzis^+': ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
          Condensed[NPrint.Printer]+ws1+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer]+' ')
          Else
          Write(txt,Space+Seria_Akzis^+': ',ws1+' ')
         End;

       ws2:=SklB^.Dat.Input.Virabotano{BakGetField(FVirabotano,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);

       If ws2[0]<>#0 Then
        Begin
         If ws1[0]<>#0 Then
          Begin
           If Not Video Then
              WriteLn(txt,Condensed[NPrint.Printer]+'Дата выработки: ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
         Condensed[NPrint.Printer]+ws2+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer])
           Else
              WriteLn(txt,'Дата выработки: ',ws2);
          End
         Else
          Begin
           If Not Video Then
               WriteLn(txt,Condensed[NPrint.Printer]+Space+'Дата выработки: ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
               Condensed[NPrint.Printer]+ws2+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer])
           Else
               WriteLn(txt,Space+'Дата выработки: ',ws2);
          End;
        End
       Else
         if ws1[0]<>#0 Then WriteLn(txt,Condensed[NPrint.Printer]);

       ws2:=Skl^.Dat.Input.Godnost{BakGetField(FGodnost,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);

       DelSpaceRight(ws2);
       If ws2[0]<>#0 Then
         Begin
          If Not Video Then
           WriteLn(txt,Condensed[NPrint.Printer]+Space+'Реализовать до: ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
           Condensed[NPrint.Printer]+ws2+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer])
          Else
           WriteLn(txt,Space+'Реализовать до: ',ws2);
         End;
      End;{печать акцизных марок и дат розлива}
     End{OperatorSelector}
     Else
      Begin

     If PrintSertifDoc[1]=1 Then
      Begin
       If (E^.Dat.MarketElement[l].Input.NSertif[0]<>#0) And
             (E^.Dat.MarketElement[l].Input.NSertif<>NoSertifStr) Then
       Begin

New(BBBS,Init);
GetBazElement(E^.Dat.MarketElement[l].Input.NSertif,BBBS^.Dat);

           ws1:=BBBS^.Dat.Name{GetIdField(FName,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws1);
        ws2:=BBBS^.Dat.Name2{GetIdField(FName2,E^.Dat.MarketElement[l].Input.NSertif)};
           DelSpaceRight(ws2);
           ws2:=ws1+' '+ws2;
           DelSpaceRight(ws2);
        If Not Video Then
           Write(txt,Condensed[NPrint.Printer]+Space+'    Сертификат: ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
           Condensed[NPrint.Printer]+ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')'+NoDouble[NPrint.Printer]+
           NoItalic[NPrint.Printer])
        Else
           Write(txt,Space+'    Сертификат: ',ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')');

      ws1:=BBBS^.Dat.DSertif{GetIDField(FDateSertif,E^.Dat.MarketElement[l].Input.NSertif)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
        If Not(Video) Then
        Begin
        If ws2[0]<>#0 Then
           WriteLn(txt,Condensed[NPrint.Printer]+Space+'    Срок дейст: ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
            Condensed[NPrint.Printer]+ws1+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer]+' ')
        Else
           WriteLn(txt,Condensed[NPrint.Printer]+Space+'    Срок дейст: ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
            Condensed[NPrint.Printer]+ws1+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer]+' ')
        End
        Else
           WriteLn(txt,Space+'    Срок дейст: ',+ws1+' ')
          End
        Else If ws2[0]<>#0 Then Writeln(txt);

      ws2:=BBBS^.Dat.KSertif{GetIDField(FKtoSertif,E^.Dat.MarketElement[l].Input.NSertif)};
      DelSpaceRight(ws2);
      If ws2[0]<>#0 Then
       Begin
           If ws1[0]<>#0 Then
         Begin
          If Not Video Then
        Writeln(txt,Condensed[NPrint.Printer]+' Выдан: ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
                Condensed[NPrint.Printer]+ws2+
             NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer])
          Else
        Writeln(txt,' Выдан: ',+ws2);
         End
           Else
         Begin
          If Not Video Then
                Writeln(txt,Condensed[NPrint.Printer]+Space+'         Выдан: ',Italic[NPrint.Printer]+Double[NPrint.Printer]++
                Condensed[NPrint.Printer]+ws2+
                       NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer])
          Else
                Writeln(txt,Space+'         Выдан: ',+ws2);
         End;
       End
      Else  If ws1[0]<>#0 Then Writeln(txt);
Dispose(BBBS,Done);
      End;{сертификаты}
      End;


     If PrintAkzisDate[1]=1 Then
      Begin
       ws1:=Skl^.Dat.Input.Marka{BakGetField(FMarka,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
         Begin
          If Not Video Then
          Write(txt,Condensed[NPrint.Printer]+Space+Seria_Akzis^+': ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
          Condensed[NPrint.Printer]+ws1+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer]+' ')
          Else
          Write(txt,Space+Seria_Akzis^+': ',ws1+' ')
         End;

       ws2:=SklB^.Dat.Input.Virabotano{BakGetField(FVirabotano,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);

       If ws2[0]<>#0 Then
        Begin
         If ws1[0]<>#0 Then
          Begin
           If Not Video Then
              WriteLn(txt,Condensed[NPrint.Printer]+'Дата выработки: ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
         Condensed[NPrint.Printer]+ws2+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer])
           Else
              WriteLn(txt,'Дата выработки: ',ws2);
          End
         Else
          Begin
           If Not Video Then
               WriteLn(txt,Condensed[NPrint.Printer]+Space+'Дата выработки: ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
               Condensed[NPrint.Printer]+ws2+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer])
           Else
               WriteLn(txt,Space+'Дата выработки: ',ws2);
          End;
        End
       Else
         if ws1[0]<>#0 Then WriteLn(txt);

       ws2:=Skl^.Dat.Input.Godnost{BakGetField(FGodnost,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);

       DelSpaceRight(ws2);
       If ws2[0]<>#0 Then
         Begin
          If Not Video Then
           WriteLn(txt,Condensed[NPrint.Printer]+Space+'Реализовать до: ',Italic[NPrint.Printer]+Double[NPrint.Printer]+
           Condensed[NPrint.Printer]+ws2+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer])
          Else
           WriteLn(txt,Space+'Реализовать до: ',Condensed[NPrint.Printer]+ws2);
         End;

      End;{печать акцизных марок и дат розлива}

     If PrintGTD[1]=1 Then
     Begin
       ss:=Skl^.Dat.Input.NGTD{BakGetField(FNGTD,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ss);
       ss1:=Skl^.Dat.Input.Post{BakGetField(FPost,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ss1);
       If (ss[0]<>#0)Or (ss1[0]<>#0) Then
        Begin
         Format(ss,CNSertif);
         If ss[0]<>#0 Then
         Begin
         If Not(Video) Then ss:=Italic[NPrint.Printer]+Double[NPrint.Printer]+
            Condensed[NPrint.Printer]+ss+NoDouble[NPrint.Printer]+
            NoItalic[NPrint.Printer];
         ss:=Space+'   '+'      N ГТД: '+ss;
         End
         else ss:=Space+'   ';
         If ss1[0]<>#0 Then
         Begin
         If Not(Video) Then ss1:=Italic[NPrint.Printer]+Double[NPrint.Printer]+
            Condensed[NPrint.Printer]+ss1+NoDouble[NPrint.Printer]+
            NoItalic[NPrint.Printer];
         If Video Then
            ss:=ss+' Производство: '+ss1
         Else ss:=ss+Condensed[NPrint.Printer]+' Производство: '+ss1;
         End;
         Writeln(txt,Condensed[NPrint.Printer]+ss);
        End;
     End;
       End;

Dispose(Skl,Done);
Dispose(SklB,Done);
Dispose(BBB,Done);

    End;


    ItogoSkidka:=Itogo{+StrToReal(E^.Dat.ENalog)};
    MySTr(ItogoSkidka,CIZena,CMantissa,tt1);
    MySTr(ItogoS,CIZena,CMantissa,tt2);

    ItogoSkidka:=StrToReal(tt1)-StrToReal(tt2){ItogoS};

    DelSpace(E^.Dat.SummaZ);
    RFormat(E^.Dat.SummaZ,CIZena);
    RFormat(E^.Dat.SummaZakupka,CIZena);
{    If Video Then Writeln(txt,Space+'______________________________________________________________________________');}
MyStr(StrToReal(E^.Dat.SummaZ),CIZena,CMantissa,E^.Dat.SummaZ);
MyStr(StrToReal(E^.Dat.SummaZakupka),CIZena,CMantissaZ,E^.Dat.SummaZakupka);
{DelSpace(E^.Dat.SummaZ);}

    MyStr(StrToReal(E^.Dat.SummaZ)-NDS,CIZena-2,CMAntissa,ws);
    MyStr(StrToReal(E^.Dat.SummaZ),CIZena-2,CMAntissa,E^.Dat.SummaZ);
    MyStr(NDS,CZena,CMAntissa,ws2);

    MyStr(StrToReal(SummaOutNDS),CIZena-2,CMAntissa,SummaOutNDS);

Writeln(txt,Condensed[NPrint.Printer]+
Space+Dop+'──────────────────────────────────────────────────────────────────────────────────────────────────────'+
'─────────────────────────────────────────────');

  If E^.DAt.OperatorSelector in [0,2] Then
Begin

    Writeln(Txt,Condensed[NPrint.Printer]+Space+Dop+'Позиций:',E^.Dat.Amount:2,
    '                                                                                  ',Recogniz({ws}SummaOutNDS),'        ',
    Recogniz(ws2),Double[NPrint.Printer]+Condensed[NPrint.Printer]+Recogniz(E^.Dat.SummaZ)+NoDouble[NPrint.Printer]+
    '   Мест:'+CalcMesto(E));
    If (StrToInt(Rek^.Dat.Kod) in [5]) Then
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'    В т.ч.акциз:',RecognizReal(StrToReal(E^.Dat.SummaAkzis),CIZena,
    CMantissa));

If (Video) And (StrToInt(CurrentPassword)=0) Then
   Begin
    Writeln(Txt,Condensed[NPrint.Printer]+Space+Dop+'                                   Всего закупка:',
    Recogniz(E^.Dat.SummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka),
    CIZena,CMantissaZ)));
   End;
End
  Else
 Begin
    Writeln(Txt,Condensed[NPrint.Printer]+Space+Dop+'Позиций:',E^.Dat.Amount:2,
    '                                                                                  ',Recogniz({ws}SummaOutNDS),'        ',
    Recogniz(ws2),Double[NPrint.Printer]+Condensed[NPrint.Printer]+Recogniz(E^.Dat.SummaZ)+NoDouble[NPrint.Printer]+
    '   Мест:'+CalcMesto(E));
    If (StrToInt(Rek^.Dat.Kod) in [5]) Then
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'    В т.ч.акциз:',RecognizReal(StrToReal(E^.Dat.SummaAkzis),CIZena,
    CMantissa));

If (Video) And (StrToInt(CurrentPassword)=0) And Not(E^.DAt.OperatorSelector=1) Then
   Begin
    Writeln(Txt,Condensed[NPrint.Printer]+Space+Dop+'                                         Всего закупка:',
    Recogniz(E^.Dat.SummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka),
    CIZena,CMantissaZ)));
   End;
 End;


    If Not Video Then
    If E^.Dat.DocSelector<>0 Then
      Begin
       Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'     В т.ч. НДС:',RecognizReal(Nds,CIZena,CMantissa));
       If NDS20>0.009 Then
       Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+Italic[NPrint.Printer]+
          Condensed[NPrint.Printer]+'         20%   :'+
          RecognizReal(NDS20,CIZena,CMantissa)+
          NoItalic[NPrint.Printer]);

       If NDS10>0.009 Then
       Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+Italic[NPrint.Printer]+
          Condensed[NPrint.Printer]+'         10%   :'+
          RecognizReal(NDS10,CIZena,CMantissa)+
          NoItalic[NPrint.Printer]);

       If NDS_>0.009 Then
       Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+Italic[NPrint.Printer]+
          Condensed[NPrint.Printer]+'         прочие:'+
          RecognizReal(NDS_,CIZena,CMantissa)+
          Noitalic[NPrint.Printer])
      End;

{$IFDEF Pharm}
{
if ((Pharm=1)) Then
Begin
    If Not Video Then
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+Italic[NPrint.Printer]+
    'НДС не облагается'+NoItalic[NPrint.Printer]);
End;
}
{$ENDIF}
    {количество позиций}
    MyStr(StrToReal(IntToStr(E^.DAt.Amount,CMAntissa)),CMantissa+1+CMAntissa,CMantissa,s);
    If E^.DAt.Amount>0 Then
    Begin
    DelSpace(s);
    Propis(s,ws);
    l:=Pos('руб',ws);
    ws[0]:=Chr(l-2);
    ws[1]:=UpperCase(ws[1]);
    End
    Else ws:='Ноль';

    {количество мест}
    MyStr(StrToReal(CalcMesto(E)),CZena,CMantissa,ws1);
    If ws1<>'    0.00' Then
    Begin
    DelSpace(ws1);
    Propis(ws1,ws2);
    l:=Pos('руб',ws2);
    ws2[0]:=Chr(l-2);
    ws2[1]:=UpperCase(ws2[1]);
    End
    Else ws2:='Ноль';

    {масса груза}
    s:=AllMAssa;
    If Int(StrToReal(AllMassa))>0 Then
    Begin
    DelSpace(AllMassa);
    Propis(AllMassa,ws1);
    l:=Pos('руб',ws1);
    If l>0 Then
      Begin
       ws1[0]:=Chr(l-2);
       ws1[1]:=UpperCase(ws1[1]);
       ws1:=ws1+' килограмм';
      End;
    End
     Else ws1:='Ноль килограмм';


    l:=Pos('.',s);
    If l>0 Then
      Begin
       ws1:=ws1+' '+Copy(s,l+1,CLitrMantissa);
       ws1[1]:=UpperCase(ws1[1]);
       ws1:=ws1+' г.';
      End;

    Writeln(txt,Condensed[NPrint.Printer]+Space+'         Товарная накладная содержит '+Pitch[NPrint.Printer]+
    Condensed[NPrint.Printer]+ws+NoPitch[NPrint.Printer]+Condensed[NPrint.Printer]+
    ' порядковых номеров записей');
    Writeln(txt,Condensed[NPrint.Printer]+Space+'         Итого наименований: '+Pitch[NPrint.Printer]+
    Condensed[NPrint.Printer]+ws+NoPitch[NPrint.Printer]+Condensed[NPrint.Printer]+
    '   Итого мест: '+Pitch[NPrint.Printer]+
    Condensed[NPrint.Printer]+ws2+NoPitch[NPrint.Printer]+Condensed[NPrint.Printer]+'   Итого масса(брутто): '+
    Pitch[NPrint.Printer]+Condensed[NPrint.Printer]+
    ws1+NoPitch[NPrint.Printer]+Condensed[NPrint.Printer]);



    If E^.Dat.DocSelector in [2,3,4,5,6,7,8] Then
    Begin
    s:=E^.Dat.SummaZ;
    {s:='88888.88';}
    DelSpace(s);
    Propis(s,ws);
    ws[1]:=UpperCase(ws[1]);
    ws:=ws+' '+s;
    Format(ws,80);
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'Отпущено на сумму ');
    Writeln(txt,Space+Dop+Italic[NPrint.Printer]+Double[NPrint.Printer]+Double[NPrint.Printer]+
    +Condensed[NPrint.Printer]+ws+NoItalic[NPrint.Printer]+NoDouble[NPrint.Printer]+NoDouble[NPrint.Printer]+
    Condensed[NPrint.Printer]+
    TTNStr1^{'  По доверенности N _____ от ___________, выданной ______________'});
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+
    TTNStr2^
{'Отпуск разрешил                                                                   Груз к перевозке принял
экспедитор (водитель) _________________'});
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+
    TTNStr3^
{'Оператор                                                                          (При личном приеме товар
по количеству и ассортименту проверил'});
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+
    TTNStr4^{'торгового зала ____________  Бухгалтер кассир _____________
    (груз получил грузополучатель (претензий не имею) _____________'});
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'Отпуск произвел кладовщик ___________________                М.П.'+
    +'                ');

    End;

writeln(txt,NoCondenSed[NPrint.Printer]);

Writeln(txt,Space+Dop+'     2. ТРАНСПОРТНЫЙ РАЗДЕЛ '+CondenSed[NPrint.Printer]);

Writeln(txt,Space+Dop+'Срок доставки груза: '+E^.DAt.DAteC+'                                    '+
'                                                      ТТН N: '+ZakazNumer+E^.Dat.Document+'/'+Z+' от '+ZakazDate);

Writeln(txt,Space+Dop+'Организация: ________________________  Водитель: ____________ Автомобиль: _______'+
'______ Гос.номер: ________________      К путевому листу N ____');

Writeln(txt,Space+Dop+'Лицензионная карточка: Регистрационный N ____________ Серия _________ N ________ '+
'Вид перевозки: ______________________________          Код ____');
Writeln(txt,Space+Dop+'Пункт погрузки: '+Rek1^.Dat.AdressGruza+' Пункт разгрузки: '+
Cl^.Dat.FullNAme{GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)}+' '+
Cl^.Dat.Adress{GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector)});

Dispose(Cl,Done);

Writeln(Txt,NoCondensed[NPrint.Printer]);
(*
    If E^.Dat.DocSelector in [1,2,3,5,6] Then
    Begin                 /
      Writeln(txt,Space+'{'+RecognizReal(STrToReal(E^.Dat.ENalog),CIZena,CMantissa),'}');
      If StrToReal(E^.Dat.ENalog)>0.009 Then
      Begin
       If StrToReal(E^.Dat.Nalog5)>0.009 Then
       Writeln(txt,Space+' '+RecognizReal(StrToReal(E^.Dat.Nalog5),CIZena,CMantissa)+'-A');
       If StrToReal(E^.Dat.Nalog3)>0.009 Then
       Writeln(txt,Space+' '+RecognizReal(StrToReal(E^.Dat.Nalog3),CIZena,CMantissa)+'-B');
       If StrToReal(E^.Dat.Nalog_)>0.009 Then
       Writeln(txt,Space+' '+RecognizReal(StrToReal(E^.Dat.Nalog_),CIZena,CMantissa)+'-C');
      End;
    End;
*)


   If Not(Video) And (FiktivSkidka=1) And (NewSkidka) Then
    Begin
     ItogoSkidka:=NewSum;
    End;


   Write(txt,NoCondensed[NPrint.Printer]);

{$IFNDEF Pharm}
   Writeln(Txt,Space,'{'+RecognizReal(ItogoSkidka,CIZena,CMantissa)+'}');
{$ENDIF}


    If (StrToInt(E^.DAt.AgentKod)<>0)And(E^.Dat.OperatorSelector in[0,2]) Then
     Begin
      s:=GetClientField(FAdressF,E^.DAt.ClientKod,E^.Dat.OperatorSelector);
      DelSpaceRight(s);
      If s[0]<>#0 Then
       Begin
        Writeln(txt,Space+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+s
        +NoItalic[NPrint.Printer]+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
       End;
     End;


   Write(txt,Space{+' Всего: '},' '+'               '{+RecognizReal(Itogo,CIZena,CMantissa)},
    '                         '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

   If E^.Dat.Rashet=2 Then Symbol:='-В'
   Else Symbol:='';

   Writeln(txt,Space+Dop+NoCondensed[NPrint.Printer]+''+Italic[NPrint.Printer]+Double[NPrint.Printer]+
   Double[NPrint.Printer]+' Тип документа: (',
   LeadingZero(E^.Dat.DocSelector),Symbol+')'+NoItalic[NPrint.Printer]+
   NODouble[NPrint.Printer]);

   {отчеркивание заключительное}

Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'============================================================================'+
'=========================='+
'============================================'+NoCondensed[NPrint.Printer]);
If Not(Video) Then NoInfoMsg;
{$ENDIF}
Dispose(Rek1,Done);
End;



Function CalcDolgBarter(Regim:Boolean):TMyString;
Var R : TRect;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    RealFile : BarterClientFileType;
    ClientList :PBox;
    E  : PBArterClientType;
    st : AllStr;
    ws,ws1,ws2 : TMyString;
    ii,c : LongInt;
    LSaldo,LSaldo2,Saldo,Saldo2,LOborot:Real;
    f : Text;
    {DateMask : TDateString;}
    Space : AllStr;
    Space1 : AllStr;
    Tip,Vid,Realno : Word;
    VidProsmotra : Word;
    SDate : TDAteString;
begin
 CalcDolgBarter:='         0.0000';
                 {123456789012345 123456789012345 123456789012345 123456789012345}

VidProsmotra:=0;
SDAte:=FDAte;
If Regim Then
 Begin
  VidProsmotra :=SelectImport(18);
  If VidProsmotra=2 Then
   Begin
    Exit;
   End;

  If Not DateDialog(SDAte) Then
   Begin
    Exit;
   End;


 End;


Assign(f,Path^.Dat.ToTemp+'dolgb.txt');
c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0) And (Regim) Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'dolgb.txt!!'+
  +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
  Exit;
 End;
R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path^.Dat.ToClient+'Barter.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;

If c=0 Then
Begin
If Regim Then AInfo('Рассчитываю сальдо по клиентам...');
While Not(Eof(ClientFile)) Do
 Begin
     ReadClient(ClientFile,ClientElement);
  If ClientElement.Employ Then
   Begin
    Format (ClientElement.Name,CClient);
    ClientList^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
    ClientList^.SetRange(ClientList^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  Close(f);
  Dispose(ClientList,Done);
  MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов',Nil,mfError+mfCancelButton);
  Exit;
 End;
Space:='         ';
Space1:='       ';

Writeln(f,Space+Header+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword);
Writeln(f,Space+'СПРАВКА ПО САЛЬДО ВЗАИМОРАСЧЕТОВ С КЛИЕНТАМИ'+' на '+SDate+'   ('+FDAte+'  '+Times+')');
Writeln(f,Space+'┌────────────────────────────────────────────────────────┐');
Writeln(f,Space+'│      Клиент         Код          Оборот          Сальдо│');
Writeln(f,Space+'└────────────────────────────────────────────────────────┘'+HeaderStop);
                         {12345678901234567890 1234 123456789012345 123456789012345}
Saldo:=0;
Saldo2:=0;
If (ClientList^.List^.Count-1)>=0 Then
 Begin
 If VidProsmotra=1 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
    ws:=GetClientField(FClient,St,2);
    Format(ws,CClient);
    ws:=ws+' '+st;
    Assign(RealFile,Path^.Dat.ToBarter+st+'.brt');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    If ii=0 Then
     Begin
      New(E,Init);
      LSaldo:=0;
      LOborot:=0;
      While Not(Eof(RealFile)) Do
       Begin
        Read(RealFile,E^.Dat);
        With E^.Dat Do
        Begin
        If (E^.Dat.Active) And (DateStringToDate(DateMAsk,E^.Dat.DAteC)<=DAteStringToDate(DateMAsk,SDAte)) Then
          Begin
           Case E^.Dat.OperatorSelector Of
           0:Begin LSaldo:=LSaldo-StrToReal(PSummaZakupka);LOborot:=LOborot+StrToReal(PSummaZakupka);End;
           1:Begin LSaldo:=LSaldo+StrToReal(SummaZ)+StrToReal(SertifSummaZ);LOborot:=LOborot+StrToReal(SummaZ)+
                      StrToReal(SertifSummaZ);
                   End;
           2:Begin LSaldo:=LSaldo+StrToReal(Vidano);LOborot:=LOborot+StrToReal(Vidano); End;
           3:Begin LSaldo:=LSaldo-StrToReal(Priniato);LOborot:=LOborot+StrToReal(Priniato); End;
           Else;
           End;{Case}
          End;{active}
        End;{With}
       End;{While}
      Dispose(E,Done);
      Close(RealFile);
      If LSaldo>=0.009 Then
      Begin
      Saldo:=Saldo+LSaldo;
      MyStr(LSaldo,CIZena,CMantissaZ,ws1);
      MyStr(LOborot,CIZena,CMantissaZ,ws2);
      Writeln(f,Space+ws+' '+ws2+' '+ws1);
      End;
     End;{ii=0}
   End;{For}

Writeln(f,Space+'───────────────────────────────────────────────────────── ');
Writeln(f,Space+'                     Всего нам должны:'+RecognizReal(Saldo,CIZena,CMantissaZ));
Writeln(f,Space+'───────────────────────────────────────────────────────── ');

  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
    ws:=GetClientField(FClient,St,2);
    Format(ws,CClient);
    ws:=ws+' '+st;
    Assign(RealFile,Path^.Dat.ToBarter+st+'.brt');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    If ii=0 Then
     Begin
      New(E,Init);
      LSaldo2:=0;
      LOborot:=0;
      While Not(Eof(RealFile)) Do
       Begin
        Read(RealFile,E^.Dat);
        With E^.Dat Do
        Begin
        If (E^.Dat.Active) And (DateStringToDate(DateMAsk,E^.Dat.DAteC)<=DAteStringToDate(DateMAsk,SDAte)) Then
          Begin
           Case E^.Dat.OperatorSelector Of
           0:Begin LSaldo2:=LSaldo2-StrToReal(PSummaZakupka);LOborot:=LOborot+StrToReal(PSummaZakupka);End;
           1:Begin LSaldo2:=LSaldo2+StrToReal(SummaZ)+StrToReal(SertifSummaZ);LOborot:=LOborot+StrToReal(SummaZ)+
                      StrToReal(SertifSummaZ);
                   End;
           2:Begin LSaldo2:=LSaldo2+StrToReal(Vidano);LOborot:=LOborot+StrToReal(Vidano); End;
           3:Begin LSaldo2:=LSaldo2-StrToReal(Priniato);LOborot:=LOborot+StrToReal(Priniato); End;
           Else;
           End;{Case}
          End;{active}
        End;{With}
       End;{While}
      Dispose(E,Done);
      Close(RealFile);
      If LSaldo2<0.009 Then
      Begin
      Saldo2:=Saldo2+LSaldo2;
      MyStr(LSaldo2,CIZena,CMantissaZ,ws1);
      MyStr(LOborot,CIZena,CMantissaZ,ws2);
      Writeln(f,Space+ws+' '+ws2+' '+ws1);
      End;
     End;{ii=0}
   End;{For}
   Writeln(f,Space+'───────────────────────────────────────────────────────── ');
   Writeln(f,Space+'                      Всего мы должны:'+RecognizReal(Saldo2,CIZena,CMantissaZ));
  End
Else
 Begin
   For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
    ws:=GetClientField(FClient,St,2);
    Format(ws,CClient);
    ws:=ws+' '+st;
    Assign(RealFile,Path^.Dat.ToBarter+st+'.brt');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    If ii=0 Then
     Begin
      New(E,Init);
      LSaldo2:=0;
      LOborot:=0;
      While Not(Eof(RealFile)) Do
       Begin
        Read(RealFile,E^.Dat);
        With E^.Dat Do
        Begin
        If (E^.Dat.Active) And (DateStringToDate(DateMAsk,E^.Dat.DAteC)<=DAteStringToDate(DateMAsk,SDAte)) Then
          Begin
           Case E^.Dat.OperatorSelector Of
           0:Begin LSaldo2:=LSaldo2-StrToReal(PSummaZakupka);LOborot:=LOborot+StrToReal(PSummaZakupka);End;
           1:Begin LSaldo2:=LSaldo2+StrToReal(SummaZ)+StrToReal(SertifSummaZ);
                         LOborot:=LOborot+StrToReal(SummaZ)+StrToReal(SertifSummaZ);
                   End;
           2:Begin LSaldo2:=LSaldo2+StrToReal(Vidano);LOborot:=LOborot+StrToReal(Vidano); End;
           3:Begin LSaldo2:=LSaldo2-StrToReal(Priniato);LOborot:=LOborot+StrToReal(Priniato); End;
           Else;
           End;{Case}
          End;{active}
        End;{With}
       End;{While}
      Dispose(E,Done);
      Close(RealFile);
      Saldo2:=Saldo2+LSaldo2;
      MyStr(LSaldo2,CIZena,CMantissaZ,ws1);
      MyStr(LOborot,CIZena,CMantissaZ,ws2);
      Writeln(f,Space+ws+' '+ws2+' '+ws1);
     End;{ii=0}
   End;{For}

 End;
End;

Dispose(ClientList,Done);



Saldo:=Saldo+Saldo2;



Writeln(f,Space+'───────────────────────────────────────────────────────── ');
Writeln(f,Space+'                         Всего сальдо:'+RecognizReal(Saldo,CIZena,CMantissaZ));
Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'=========================================================');
Close(f);
MyStr(Saldo,CIZena,CMantissaZ,st);
CalcDolgBarter:=st;

If Regim Then
Begin
NoInfo;
ViewAsText(Path^.Dat.ToTemp+'dolgb.txt',True);
{ReportNew(Path^.Dat.ToTemp+'dolgb.txt','',1,False,False);}
End
end;

(*
Function CalcDolgBarter(Regim:Boolean):TMyString;
Var R : TRect;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    RealFile : BarterClientFileType;
    ClientList :PBox;
    E  : PBArterClientType;
    st : AllStr;
    ws,ws1,ws2 : TMyString;
    ii,c : LongInt;
    LSaldo,LSaldo2,Saldo,Saldo2,LOborot:Real;
    f : Text;
    {DateMask : TDateString;}
    Space : AllStr;
    Space1 : AllStr;
    Tip,Vid,Realno : Word;
    VidProsmotra : Word;
begin
 CalcDolgBarter:='         0.0000';
                 {123456789012345 123456789012345 123456789012345 123456789012345}

VidProsmotra:=0;
If Regim Then
 Begin
  VidProsmotra :=SelectImport(18);
  If VidProsmotra=2 Then
   Begin
    Exit;
   End;
 End;


Assign(f,Path^.Dat.ToTemp+'dolgb.txt');
c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0) And (Regim) Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'dolgb.txt!!'+
  +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
  Exit;
 End;
R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path^.Dat.ToClient+'Barter.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;

If c=0 Then
Begin
If Regim Then AInfo('Рассчитываю сальдо по клиентам...');
While Not(Eof(ClientFile)) Do
 Begin
     ReadClient(ClientFile,ClientElement);
  If ClientElement.Employ Then
   Begin
    Format (ClientElement.Name,CClient);
    ClientList^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
    ClientList^.SetRange(ClientList^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  Close(f);
  Dispose(ClientList,Done);
  MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов',Nil,mfError+mfCancelButton);
  Exit;
 End;
Space:='         ';
Space1:='       ';

Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword);
Writeln(f,Space+'СПРАВКА ПО САЛЬДО ВЗАИМОРАСЧЕТОВ С КЛИЕНТАМИ'+'  '+FDate+' ('+Times+')');
Writeln(f,Space+'┌────────────────────────────────────────────────────────┐');
Writeln(f,Space+'│      Клиент         Код          Оборот          Сальдо│');
Writeln(f,Space+'└────────────────────────────────────────────────────────┘');
                         {12345678901234567890 1234 123456789012345 123456789012345}
Saldo:=0;
Saldo2:=0;
If (ClientList^.List^.Count-1)>=0 Then
 Begin
 If VidProsmotra=1 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
    ws:=GetClientField(FClient,St,2);
    Format(ws,CClient);
    ws:=ws+' '+st;
    Assign(RealFile,Path^.Dat.ToBarter+st+'.brt');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    If ii=0 Then
     Begin
      New(E,Init);
      LSaldo:=0;
      LOborot:=0;
      While Not(Eof(RealFile)) Do
       Begin
        Read(RealFile,E^.Dat);
        With E^.Dat Do
        Begin
        If (E^.Dat.Active) Then
          Begin
           Case E^.Dat.OperatorSelector Of
           0:Begin LSaldo:=LSaldo-StrToReal(PSummaZakupka);LOborot:=LOborot+StrToReal(PSummaZakupka);End;
           1:Begin LSaldo:=LSaldo+StrToReal(SummaZ)+StrToReal(SertifSummaZ);LOborot:=LOborot+StrToReal(SummaZ)+
                      StrToReal(SertifSummaZ);
                   End;
           2:Begin LSaldo:=LSaldo+StrToReal(Vidano);LOborot:=LOborot+StrToReal(Vidano); End;
           3:Begin LSaldo:=LSaldo-StrToReal(Priniato);LOborot:=LOborot+StrToReal(Priniato); End;
           Else;
           End;{Case}
          End;{active}
        End;{With}
       End;{While}
      Dispose(E,Done);
      Close(RealFile);
      If LSaldo>=0.009 Then
      Begin
      Saldo:=Saldo+LSaldo;
      MyStr(LSaldo,CIZena,CMantissaZ,ws1);
      MyStr(LOborot,CIZena,CMantissaZ,ws2);
      Writeln(f,Space+ws+' '+ws2+' '+ws1);
      End;
     End;{ii=0}
   End;{For}

Writeln(f,Space+'───────────────────────────────────────────────────────── ');
Writeln(f,Space+'                     Всего нам должны:'+RecognizReal(Saldo,CIZena,CMantissaZ));
Writeln(f,Space+'───────────────────────────────────────────────────────── ');

  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
    ws:=GetClientField(FClient,St,2);
    Format(ws,CClient);
    ws:=ws+' '+st;
    Assign(RealFile,Path^.Dat.ToBarter+st+'.brt');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    If ii=0 Then
     Begin
      New(E,Init);
      LSaldo2:=0;
      LOborot:=0;
      While Not(Eof(RealFile)) Do
       Begin
        Read(RealFile,E^.Dat);
        With E^.Dat Do
        Begin
        If (E^.Dat.Active) Then
          Begin
           Case E^.Dat.OperatorSelector Of
           0:Begin LSaldo2:=LSaldo2-StrToReal(PSummaZakupka);LOborot:=LOborot+StrToReal(PSummaZakupka);End;
           1:Begin LSaldo2:=LSaldo2+StrToReal(SummaZ)+StrToReal(SertifSummaZ);LOborot:=LOborot+StrToReal(SummaZ)+
                      StrToReal(SertifSummaZ);
                   End;
           2:Begin LSaldo2:=LSaldo2+StrToReal(Vidano);LOborot:=LOborot+StrToReal(Vidano); End;
           3:Begin LSaldo2:=LSaldo2-StrToReal(Priniato);LOborot:=LOborot+StrToReal(Priniato); End;
           Else;
           End;{Case}
          End;{active}
        End;{With}
       End;{While}
      Dispose(E,Done);
      Close(RealFile);
      If LSaldo2<0.009 Then
      Begin
      Saldo2:=Saldo2+LSaldo2;
      MyStr(LSaldo2,CIZena,CMantissaZ,ws1);
      MyStr(LOborot,CIZena,CMantissaZ,ws2);
      Writeln(f,Space+ws+' '+ws2+' '+ws1);
      End;
     End;{ii=0}
   End;{For}
  End;
Writeln(f,Space+'───────────────────────────────────────────────────────── ');
Writeln(f,Space+'                      Всего мы должны:'+RecognizReal(Saldo2,CIZena,CMantissaZ));
End
 Else
  Begin
   MemCC;
   For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
    ws:=GetClientField(FClient,St,2);
    Format(ws,CClient);
    ws:=ws+' '+st;
    Assign(RealFile,Path^.Dat.ToBarter+st+'.brt');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    If ii=0 Then
     Begin
      New(E,Init);
      LSaldo2:=0;
      LOborot:=0;
      While Not(Eof(RealFile)) Do
       Begin
        Read(RealFile,E^.Dat);
        With E^.Dat Do
        Begin
        If (E^.Dat.Active) Then
          Begin
           Case E^.Dat.OperatorSelector Of
           0:Begin LSaldo2:=LSaldo2-StrToReal(PSummaZakupka);LOborot:=LOborot+StrToReal(PSummaZakupka);End;
           1:Begin LSaldo2:=LSaldo2+StrToReal(SummaZ)+StrToReal(SertifSummaZ);
                         LOborot:=LOborot+StrToReal(SummaZ)+StrToReal(SertifSummaZ);
                   End;
           2:Begin LSaldo2:=LSaldo2+StrToReal(Vidano);LOborot:=LOborot+StrToReal(Vidano); End;
           3:Begin LSaldo2:=LSaldo2-StrToReal(Priniato);LOborot:=LOborot+StrToReal(Priniato); End;
           Else;
           End;{Case}
          End;{active}
        End;{With}
       End;{While}
      Dispose(E,Done);
      Close(RealFile);
      Saldo2:=Saldo2+LSaldo2;
      MyStr(LSaldo2,CIZena,CMantissaZ,ws1);
      MyStr(LOborot,CIZena,CMantissaZ,ws2);
      Writeln(f,Space+ws+' '+ws2+' '+ws1);
     End;{ii=0}
   End;{For}
End;{ClientList^.Count}

Dispose(ClientList,Done);



Saldo:=Saldo+Saldo2;



Writeln(f,Space+'───────────────────────────────────────────────────────── ');
Writeln(f,Space+'                         Всего сальдо:'+RecognizReal(Saldo,CIZena,CMantissaZ));
Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'=========================================================');
Close(f);
MyStr(Saldo,CIZena,CMantissaZ,st);
CalcDolgBarter:=st;

If Regim Then
Begin
NoInfo;
ViewAsText(Path^.Dat.ToTemp+'dolgb.txt',True);
{Report(Path^.Dat.ToTemp+'dolgb.txt','',1,False,False);}
End
end;


*)


(*
*)

Procedure CalcDolgDebitRazdel;
Const Arhipov=0;
      Ilishev=1;
      Vse    =3;

Var R : TRect;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    RealFile : File Of RealizasiaType;
    Mrk : PSuperMarketType;
    ClientList :PBox;
    E  : PRealizasiaType;
    SArt,TempS,w,w1,st : TMyString;
    ws1,ws : TMyString;
    SDolg : Array [1..4]Of String[CIZena];
    ii,c,t1,t2 : LongInt;
    r1,r2 , Rsf,RsfSkid :Real;
    Razdel1 : PBox;
    Pos1 : Word;
    f : Text;
    {DateMask : TDateString;}
    Space : AllStr;
    v : TDateString;
    Tip,Vid,Realno,Otbor,Detal : Word;

begin
                {123456789012345 123456789012345 123456789012345 123456789012345}
 Vid:=SelectSpecify(False,1);
 If Vid=3 Then Exit;


 Otbor:=SelectSpecify(False,7);
 If Otbor=2 Then Exit;

 If otbor=0 Then
  Begin
   Detal:=SelectSpecify(False,8);
   If Detal=3 Then Exit;
  End
  Else Detal:=2;

Assign(f,Path^.Dat.ToTemp+'dolgr.txt');

c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0) Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'dolgr.txt!!',Nil,mfError+mfCancelButton);
  Exit;
 End;
R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path^.Dat.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c=0 Then
Begin
AInfo('Рассчитываю долги клиентов...');
While Not(Eof(ClientFile)) Do
 Begin
   {
     Repeat
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));
}
     ReadClient(ClientFile,ClientElement);
{
     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);}
    {
     If Otbor=0 Then если доставка
     Begin
      If Not(TestClientName(ClientElement.Name)=Detal) And Not(Detal=2) Then
       ClientElement.Employ:=False;
     End;
    }

  If ClientElement.Employ Then
   Begin
    Begin
     Format(ClientElement.Name,CClient);
     ClientList^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
     ClientList^.SetRange(ClientList^.List^.Count);
    End;
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  Close(f);
  Dispose(ClientList,Done);
  MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов',Nil,mfError+mfCancelButton);
  Exit;
 End;

 Assign(RazdelFile,Path^.Dat.ToRAzdel+'Razdel.db');
 Reset(RazdelFile);
 i:=IOResult;
 If i<>0 Then
  Begin
   Close(f);
   Dispose(ClientList,Done);
   MessageBox(^M+#3+'Ошибка открытия файла разделов!',Nil,mfError+mfCancelButton);
   Exit;
  End;

R.Assign(0, 0, 0, 0);
Razdel1 := New(PBox, Init(R, 1, Nil));
Razdel1^.NewList(New(PTextCollection, Init(0,1)));
 While Not(Eof(RazdelFile)) Do
  Begin
   Read(RazdelFile,RazdelElement);
   If RazdelElement.Employ Then
    Begin                                                      {долг т}        {скидка}
     Format(RazdelElement.Name,CRazdel);
     Razdel1^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod+'│           0.00│           0.00│'+
                                                               {долг Т СФ}     {скидка СФ}
                                                                        '           0.00│           0.00│'));
     Razdel1^.SetRange(Razdel1^.List^.Count);
    End;
  End;
Close(RazdelFile);


Space:='';
r1:=0;r2:=0;
rsf:=0;
rsfSkid:=0;
Writeln(f,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword);
Case Vid Of
2:
Writeln(f,Space+'        СПРАВКА ПО ДОЛГАМ КОНСИГНАТОРОВ по разделам'+'  '+FDate+' ('+Times+')');
1:
Writeln(f,Space+'    СПРАВКА ПО ПРОСРОЧЕННЫМ ДОЛГАМ КОНСИГНАТОРОВ по раздела'+'  '+FDate+' ('+Times+')');
0:
Writeln(f,Space+' СПРАВКА ПО НЕ ПРОСРОЧЕННЫМ ДОЛГАМ КОНСИГНАТОРОВ по разделам'+'  '+FDate+' ('+Times+')');
Else;
End;


Write(f,Space+'Вид доставки: ');
Case Otbor Of
0:Writeln(f,'"Служба доставки"');
1:Writeln(f,'"Все"');
Else Writeln(f);
End;

If Otbor=0 Then
Begin
Write(f,Space+'Служба доставки: ');
Case Detal Of
0:Writeln(f,'"Отдел доставки"');
1:Writeln(f,'"Табак"');
2:Writeln(f,'"Все"');
Else Writeln(f);
End;
End;

Writeln(f,Space+'┌────────────────────────────────────────────────────────────────────────────────────────┐');
Writeln(f,Space+'│N Раздел               Код Сумма долга Т    Сумма скидки  Сумма долга ТСФ Сумма скидк.СФ│');
{                12 12345678901234567890|12|123456789012345 123456789012345 123456789012345 123456789012345}
Writeln(f,Space+'└────────────────────────────────────────────────────────────────────────────────────────┘'+HeaderStop);

    R1:=0;
    R2:=0;
    RSf:=0;
    RSfSkid:=0;
New(mrk,Init);

If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);

(*{блокировка клиента}
 Repeat
 Until SetClientLock(st,0{клиент а не склал},0{клиент а не склал});*)

    Assign(RealFile,Path^.Dat.ToDolg+st+'.dlg');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    If ii=0 Then
     Begin
      New(E,Init);
      While Not(Eof(RealFile)) Do
       Begin
        Read(RealFile,E^.Dat);
        If (Otbor=1) Or ((Otbor=0) And (StrToInt(E^.Dat.Market.AgentKod)<>0)) Then
         Begin
If (Otbor=1) Or (detal=2) Or (Detal=StrToInt(GetAgentField(FLizo,E^.Dat.Market.AgentKod))) Then
        If (E^.Dat.Market.Active) Then
Begin
        t2:=DateStringToDate(DAteMask,FDate);
        t1:=E^.Dat.MArket.Srok;
        If ((((E^.Dat.Dolg<>0)And((t2-t1)>=0))And(Vid=1))Or
           (Vid=2)Or
           ((((E^.Dat.Dolg<>0)And((t2-t1)<0))And(Vid=0)))) And Not(E^.Dat.Full) Then
         Begin
          If GetMarket(E,Mrk) Then
         Begin
          For i:=1 To Mrk^.Dat.Amount Do
           Begin
            SArt:=Copy(Mrk^.Dat.MarketElement[i].BazKod,1,CRazdelKod);
            Pos1:=LocationR(Razdel1,SArt,False);
            {расчитываем лобовые долги}

            v:=GetReturnKol(Mrk^.Dat.Document,Mrk^.Dat.DAteC,Mrk^.Dat.ClientKod,SArt,
                  IntToStr(Mrk^.Dat.MarketElement[i].Input.DiviSionNumber,COne),Mrk^.Dat.OperatorSelector);


            {учитываем возвраты}
            Str(StrToInt(Mrk^.Dat.MarketElement[i].Input.Kol)-
                      StrToInt(v):CKol,Mrk^.Dat.MarketElement[i].Input.Kol);

            MyStr(StrToInt(Mrk^.Dat.MarketElement[i].Input.Kol)*
               StrToReal(Mrk^.Dat.MarketElement[i].Input.Zena),CIZena,CMantissa,SDolg[1]);
            If (Mrk^.Dat.DocSelector in [3,4,6,8]){E^.Dat.Sf} Then
            {расчитываем лобовые долги по сф}
            MyStr(StrToInt(Mrk^.Dat.MarketElement[i].Input.Kol)*
               StrToReal(Mrk^.Dat.MarketElement[i].Input.Zena),CIZena,CMantissa,SDolg[3])
            Else SDolg[3]:='           0.00';

            If Mrk^.Dat.SkidkaSelector=1 Then
            Begin
             MyStr((StrToReal(Mrk^.Dat.MarketElement[i].Input.Skidka)),CZena,CMantissa,SDolg[2]);
             MyStr(StrToInt(Mrk^.Dat.MarketElement[i].Input.Kol)*
                StrToReal(SDolg[2]),CIZena,CMantissa,SDolg[2]);
            If {E^.Dat.Sf}(Mrk^.Dat.DocSelector in [3,4,6,8]) Then
             Begin
              MyStr(StrToReal(Mrk^.Dat.MarketElement[i].Input.Skidka),CZena,CMantissa,SDolg[4]);
              MyStr(StrToInt(Mrk^.Dat.MarketElement[i].Input.Kol)*
                       StrToReal(SDolg[4]),CIZena,CMantissa,SDolg[4])
             End{скидки по с/ф}
             Else SDolg[4]:='           0.00';
            End{SkidkaSelector}
             Else {автоматическая скидка}
              Begin
               MyStr((StrToReal(Mrk^.Dat.MarketElement[i].Input.Zena)/
               (1+StrToReal(Mrk^.Dat.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,ws);
               MyStr((StrToReal(Mrk^.Dat.MarketElement[i].Input.Zena)-
                   StrToReal(ws)),CZena,CMantissa,SDolg[2]);
               MyStr(StrToInt(Mrk^.Dat.MarketElement[i].Input.Kol)*
                         StrToReal(SDolg[2]),CIZena,CMantissa,SDolg[2]);
               If (Mrk^.Dat.DocSelector in [3,4,6,8]){E^.Dat.Sf} Then
                Begin
                 MyStr((StrToReal(Mrk^.Dat.MarketElement[i].Input.Zena)/
                 (1+StrToReal(Mrk^.Dat.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,ws);
                 MyStr((StrToReal(Mrk^.Dat.MarketElement[i].Input.Zena)-
                     StrToReal(ws)),CZena,CMantissa,SDolg[4]);
                 MyStr(StrToInt(Mrk^.Dat.MarketElement[i].Input.Kol)*
                           StrToReal(SDolg[4]),CIZena,CMantissa,SDolg[4])
                End
                Else SDolg[4]:='           0.00';
              End;
            ws:=Razdel1^.GetText(Pos1,Razdel1^.List^.Count);
            ws1:=Copy(ws,1+CRazdel+1+CRazdelKod+1,CIZena);
            R1:=R1+StrToReal(SDolg[1]);
            Rsf:=RSf+StrToReal(SDolg[3]);
            R2:=R2+StrToReal(SDolg[2]);
            Rsfskid:=RSfskid+StrToReal(SDolg[4]);

            MyStr(StrToReal(ws1)+StrToReal(SDolg[1]),CIZena,CMantissa,SDolg[1]);
            ws1:=Copy(ws,1+CRazdel+1+CRazdelKod+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws1)+StrToReal(SDolg[2]),CIZena,CMantissa,SDolg[2]);
            ws1:=Copy(ws,1+CRazdel+1+CRazdelKod+1+CIZena+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws1)+StrToReal(SDolg[3]),CIZena,CMantissa,SDolg[3]);
            ws1:=Copy(ws,1+CRazdel+1+CRazdelKod+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws1)+StrToReal(SDolg[4]),CIZena,CMantissa,SDolg[4]);
            ws[0]:=Chr(1+CRazdel+1+CRazdelKod);
            ws:=ws+SDolg[1]+'│'+SDolg[2]+'│'+SDolg[3]+'│'+SDolg[4]+'│';
            Razdel1^.List^.Atfree(Pos1);
            Razdel1^.SetRange(Razdel1^.List^.Count);
            Razdel1^.List^.Insert(NewStr(ws));
            Razdel1^.SetRange(Razdel1^.List^.Count);
           End;

         End;
         End;
End;{active}
End;{Otbor}
       End;
      Dispose(E,Done);
      Close(RealFile);
     End;
(*
 {деблокировка клиента}
 Repeat
 Until (SetClientUnLock(St,0,0));
*)
   End;
 End;
Dispose(Mrk,Done);
Dispose(ClientList,Done);

If (Razdel1^.List^.Count-1)>=0 Then
Begin
For pos1:=0 To Razdel1^.List^.Count-1 Do
 Begin
  ws:=Razdel1^.GetText(pos1,Razdel1^.List^.Count);
  While Pos('│',ws)>0 Do ws[Pos('│',ws)]:=' ';
  Str(Pos1:CMantissa,ws1);
  Writeln(f,Space+ws1+' '+ws);
 End;{for}
End;{If}


Dispose(Razdel1,Done);

Writeln(f,Space+'──────────────────────────────────────────────────────────────────────────────────────────');
Writeln(f,Space+'                           Всего долг:'+RecognizReal(R1,CIZena,CMantissa));
Writeln(f,Space+'                         Всего скидка:'+RecognizReal(R2,CIZena,CMantissa));
Writeln(f,Space+'              Реальный долг по оплате:'+RecognizReal(R1-R2,CIZena,CMantissa));
Writeln(f,Space+'                       Всего долг С/Ф:'+RecognizReal(RSf,CIZena,CMantissa));
Writeln(f,Space+'                     Всего скидка С/Ф:'+RecognizReal(RsfSkid,CIZena,CMantissa));
Writeln(f,Space+'          Реальный долг по оплате С/Ф:'+RecognizReal(Rsf-RsfSkid,CIZena,CMantissa));

Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'==========================================================================================');

Close(f);
MyStr(R1,CIZena,CMantissa,st);
MyStr(R2,CIZena,CMantissa,ws);
MyStr(Rsf,CIZena,CMantissa,w);
MyStr(RsfSkid,CIZena,CMantissa,w1);

NoInfo;
ViewAsText(Path^.Dat.ToTemp+'dolgr.txt',True);
{ReportNew(Path^.Dat.ToTemp+'dolgr.txt','',1,False,False);}
end;






Procedure CalcDolgDebitDate;
Var R : TRect;
     ClientList : PBox;
      st,s : String;
ClientFile : File;
ClientElement : PBufClientType;
c,cc,Count : Word;
         f : Text;
     Space : AllStr;
     SDAte : TDateString;
     FDolg : File Of ClientDolgType;
     FD    : ClientDolgType;
   AllDolg : Float;

begin
SDAte:=FDAte;

If Not(DateDialog(SDAte)) Then Exit;

If Not FExists(Path^.DAt.ToArchiv+SDAte+'.dlg') Then
 Begin
  MessageBox(#3'Не найден файл '+Path^.DAt.ToArchiv+SDAte+'.dlg!',Nil,mfError+mfCAncelButton);
  Exit;
 End;

Assign(f,Path^.Dat.ToTemp+'dolgd.txt');
c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0) Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'dolgd.txt!!'+
  +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));


Assign (ClientFile,Path^.Dat.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile,SizeOf(ClientType));
c:=IOResult;
If c=0 Then
Begin

While Not(Eof(ClientFile)) Do
{For ccc:=1 To 500 Do}
 Begin
     DInfoMsgShkala('Читаю списки консигнаторов. Ждите... ',0,FileSize(CLientFile),FilePos(CLientFile));
     New(ClientElement,Init);
     Count:=0;
     ReadBufClient(ClientFile,ClientElement,Count);
For c:=1 To Count Do
Begin
  If ClientElement^.Point.Dat[c].Employ Then
   Begin
    Begin
     Format(ClientElement^.Point.Dat[c].FullName,CAll);
     ClientList^.List^.Insert(NewStr(ClientElement^.Point.Dat[c].FullName+'│'+ClientElement^.Point.Dat[c].Kod+'│'+
        +'           0.00'));
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
  Close(f);
  Dispose(ClientList,Done);
  MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов',Nil,mfError+mfCancelButton);
  Exit;
 End;

NoInfoMsg;



Space:='   ';
Writeln(f,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword);
Writeln(f,Space+' СПРАВКА ПО ДОЛГАМ КОНСИГНАТОРОВ по состоянию на '+' '+SDate);
Writeln(f,Space+'┌────┬─────────────────────────────────────────────┬────┬───────────────┐');
Writeln(f,Space+'│ п/п│ Клиент                                      │Код │ Долг по оплате│');
Writeln(f,Space+'├────┼─────────────────────────────────────────────┼────┼───────────────┤'+HeaderStop);
                 {1234│123456789012345678901234567890123456789012345│1234│123456789012345│}


{расставляем долги в списке}
Assign(fdolg,Path^.DAt.ToArchiv+SDAte+'.dlg');
c:=IOResult;
Reset(fDolg);
c:=IOResult;
AllDolg:=0;
While Not(Eof(fdolg)) Do
 Begin
  DInfoMsgShkala('Рассчитываю долги клиентов. Ждите... ',0,FileSize(FDolg),FilePos(FDolg));
  Read(FDolg,FD);
  RFormatZerro(FD.Kod,CClientKod);
  MyStr(FD.Dolg,CIZena,CMantissa,St);
  If FD.Dolg>0.009 Then
  Begin
  AllDolg:=AllDolg+FD.Dolg;
  c:=Location(ClientList,FD.Kod+'│',False);

  s:=ClientList^.GetText(c,ClientList^.List^.Count);

  s1:=Copy(s,1+CAll+1+CClientKod+1,CIZena);
  System.Delete(s,1+CAll+1+CClientKod+1,CIZena);
  MyStr(StrToReal(s1)+FD.Dolg,CIZena,CMantissa,s1);

  s:=s+s1;

  ClientList^.List^.Atfree(c);
  ClientList^.SetRange(ClientList^.List^.Count);

  ClientList^.List^.Insert(NewStr(s));
  ClientList^.SetRange(ClientList^.List^.Count);
  End;
 End;
c:=IOResult;
Close(fDolg);
c:=IOResult;
NoInfoMsg;


Count:=1;
If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    DInfoMsgShkala('Формирую отчет. Ждите... ',0,ClientList^.List^.Count-1,c);
    s := ClientList^.GetText(c,ClientList^.List^.Count);
    If (StrToReal(Copy(s,1+CAll+1+CClientKod+1,CIZena))>0.009) Then
    Begin
     St:= IntToStr(Count,4);
     Inc(Count);
     RFormat(st,4);
     Writeln(f,Space+'│'+st+'│'+s+'│');
    End;
   End;
 End;
Writeln(f,Space+'└────┴─────────────────────────────────────────────┴────┴───────────────┘');
Dispose(ClientList,Done);
Writeln(f,Space+'                           Всего долг по оплате:'+RecognizReal(AllDolg,CIZena,CMantissa));
Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'========================================================================');
c:=IOResult;
Close(f);
c:=IOResult;

NoInfoMsg;
ViewAsText(Path^.Dat.ToTemp+'dolgd.txt',True);
{ReportNew(Path^.Dat.ToTemp+'dolgd.txt','',1,False,False);}
end;


Procedure TestDocumentsList(Video:Boolean;Kod : ArtikulStr;Var M:Maska55;E:SuperMarketType;OperatorSelector:Word);

Var Es : PBufClientToVarType;
    Esf: File{ Of ClientTovarType};
    R  : TRect;
    Count,posit,c,c1 : Word;
    s : String;
    SDate : TDateString;
    Regim : Boolean;
    DocumentsList:PBox;
Begin
For c:=1 To CMAx Do M[c]:=0;

If EnableAntiLock=1 Then
 Begin

If Not Video Then DInfoMsg('Просматриваю документооборот...',False);

R.Assign(0,0,0,0);
DocumentSList := New(PBox, Init(R, 1, Nil));
DocumentSList^.NewList(New(PTextCollection, Init(0,1)));

If E.Amount>0 Then
If OperatorSelector=0 Then
Begin
 Assign(Esf,Path^.Dat.ToClientIndex+Kod+'.tdx');
 c:=IoResult;
 Reset(Esf,SizeOf(ClientTovarType));
 c:=IoResult;
 If c<>0 Then Exit;
 While Not(Eof(Esf)) Do
  Begin
   New(Es,Init);
   Count:=0;
   BlockRead(Esf,Es^.Point,BufferTST,Count);
   Regim:=True;


 For c1:=1 To Count Do
 Begin
   If (Es^.Point.Dat[c1].Active) And (Es^.Point.Dat[c1].Amount>0) And (Regim) Then
    Begin
    If Not(
    (StrToInt(Es^.Point.Dat[c1].Document)=StrToInt(E.Document))
    And
    (Es^.Point.Dat[c1].DateC=E.DateC)) Then
Begin

     For c:=1 To Es^.Point.Dat[c1].Amount Do
      BEgin
      If Es^.Point.Dat[c1].Element[c].BazKod<>NoSertifStr Then
      Begin

       If TestElement(Es^.Point.Dat[c1].Element[c].BazKod,DocumentSList) Then
        {если сертификата нет в списке}
        Begin
         RFormat(Es^.Point.Dat[c1].Element[c].Kol,CKol);
         RFormat(Es^.Point.Dat[c1].Document,CDocNumer);
         RFormat(Es^.Point.Dat[c1].DateC,CDate);
         s:='│'+Es^.Point.Dat[c1].Element[c].BazKod+'│'+Es^.Point.Dat[c1].Element[c].Kol+'│'+
         Es^.Point.Dat[c1].Document+'│'+Es^.Point.Dat[c1].DateC+'│'+Es^.Point.Dat[c1].AgentKod;
         DocumentSList^.List^.Insert(NewStr(s));
         DocumentSList^.SetRange(DocumentSList^.List^.Count);
        End
       Else
        Begin{если элемент уже есть в списке}
         Posit:=Location(DocumentSList,Es^.Point.Dat[c1].Element[c].BazKod,False);
         s:=DocumentSList^.GetText(Posit,DocumentSList^.List^.Count);
         SDate:=Copy(s,1+CArtikul+1+CKol+1+CDocNumer+1,CDAte);

         If DateStringToDAte(DateMask,SDAte)<DateStringToDAte(DateMask,Es^.Point.Dat[c1].DateC) Then
          {если нужно вставлять}
          Begin
           DocumentSList^.List^.AtFree(Posit);
           DocumentSList^.SetRange(DocumentSList^.List^.Count);

           RFormat(Es^.Point.Dat[c1].Element[c].Kol,CKol);
           RFormat(Es^.Point.Dat[c1].Document,CDocNumer);
           RFormat(Es^.Point.Dat[c1].DateC,CDate);
           s:='│'+Es^.Point.Dat[c1].Element[c].BazKod+'│'+Es^.Point.Dat[c1].Element[c].Kol+'│'+
           Es^.Point.Dat[c1].Document+'│'+Es^.Point.Dat[c1].DateC+'│'+Es^.Point.Dat[c1].AgentKod;
           DocumentSList^.List^.Insert(NewStr(s));
           DocumentSList^.SetRange(DocumentSList^.List^.Count);
          End;
        End;
       End;
      End;{For по накладной}
End;
    End;{Active}
  End;
   Dispose(Es,Done);
  End;{While}
 c:=IoResult;
 Close(Esf);
 c:=IoResult;
End;{OperatorSelector=0}


If E.Amount>0 Then
 Begin
  If DocumentSList^.List^.Count-1>=0 Then
   Begin
  For c:=1 To E.Amount Do
   Begin
    If Not TestElement(E.MarketElement[c].Input.NSertif,DocumentSList) Then
     Begin
	 M[c]:=1;
     End;
   End;
   End;{List^.Count-1>1}
 End;

Dispose(DocumentSList,Done);

If Not(Video) Then NoInfoMsg;
End;

End;





End.