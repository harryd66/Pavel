Procedure FormSF{без налога с продажи}( Video : Boolean;Var E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_,NDS18:Float;Comissioner:Boolean);
Var l : Word;
    k,j : Byte;
    s,ws,ws1 : String;
    {ГТД и производитель}
    s1,s2,s3,s4 : String;
    kkk:Text;
    st : String[CMantissa];
    ItogoLitr,PromItogoPos,ItogoPos,NDSPos : Real;
    Test : LongInt;
    SDoc,SDate,SummaNDS : String[CInputIZena];
    SDocs,SDates,SKods : String[CInputIZena];
    RealZena,ITOGONDS_NP,SSummaZ,SummaZena: String[CInputIZena];
    Space : AllStr;
    ItogNalog,Koefficient,pp : AllStr;
    Rek1 :Rekwiziti;
    NPNalog,NormalZena,Koeffizient : String[CZena];
    Lg : PSuperMarketType;
    Barter : String[CMantissa];
    Art,Symbol : ArtikulStr;
    Cl : PClientType;
    BBB : PBazType;
    SKL : PSkladType;
    SAkzis,ZakazNumer,ZakazDate:AllStr;
    Etil : TDateString;
Begin

If Not(Video) Then
Begin
DInfoMsg('Формирую счет-фактуру. Ждите...',True);
End;

   New(Cl,Init);
   Cl^.DAt.Kod:=E^.Dat.ClientKod;

   GetClient(Cl,E^.Dat.OperatorSelector);


   DelSpace(E^.Dat.Document);
   DelSpace(E^.Dat.DocReal);
   s:=E^.Dat.Document;
   s:=Bold[Nprint^.DAt.Printer]+S+NoBold[Nprint^.DAt.Printer];
   Space:='   ';
   {
   Writeln(RekSF^.Dat.INN);
   Readln;
   Writeln(RekComissioner^.Dat.INN);
   Readln;
   }
   If Not(Comissioner) Then Rek1:=RekSF^.Dat
   Else Rek1:=RekComissioner^.Dat;



   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
    End
    Else
     Begin
If ((E^.Dat.Realiz) And (E^.Dat.DocSelector in [5,6,7,8])) Or
   (Not (E^.Dat.Realiz) And (E^.Dat.DocSelector in [0,1,2,3,4]))
 Then
      ZakazDate:=E^.Dat.DateC
Else
      ZakazDate:=DateToDateString(DateMask,E^.Dat.DocDate);
     End;
End
 Else
  Begin
If ((E^.Dat.Realiz) And (E^.Dat.DocSelector in [5,6,7,8])) Or
   (Not (E^.Dat.Realiz) And (E^.Dat.DocSelector in [0,1,2,3,4]))
 Then
      ZakazDate:=E^.Dat.DateC
Else
      ZakazDate:=DateToDateString(DateMask,E^.Dat.DocDate);
  End;


if ((Pharm=1)) Then
Begin
   Writeln(Txt,Condensed[Nprint^.DAt.Printer]+Space+'Оптовая лицензия:'+
   Format(Rek1.LizensiaOPTL_V,CAll)+'          '+
   Nocondensed[Nprint^.DAt.Printer]+
   '                 Приложение N 1');
   Writeln(Txt,Condensed[Nprint^.DAt.Printer]+Space+'                             '+      Format(Rek1.LizensiaOPTSig,CAll)+
   Nocondensed[Nprint^.DAt.Printer]+
   'к правилам ведения журналов учета счетов-фактур');
   Writeln(Txt,Condensed[Nprint^.DAt.Printer]+Space+'                         '+      Format(Rek1.LizensiaOPTPiv,CAll)+
   Nocondensed[Nprint^.DAt.Printer]+
   ' при расчетах по налогу на добавленную стоимость');
End
Else
 Begin
   Writeln(Txt,Condensed[Nprint^.DAt.Printer]+Space+'Оптовая лицензия на лик-вд.:'+
   Format(Rek1.LizensiaOPTL_V,CAll)+
   Nocondensed[Nprint^.DAt.Printer]+
   '                 Приложение N 1');
   Writeln(Txt,Condensed[Nprint^.DAt.Printer]+Space+'Оптовая лицензия на сигареты:'+      Format(Rek1.LizensiaOPTSig,CAll)+
   Nocondensed[Nprint^.DAt.Printer]+
   'к правилам ведения журналов учета счетов-фактур');
   Writeln(Txt,Condensed[Nprint^.DAt.Printer]+Space+'Оптовая лицензия на пиво:'+      Format(Rek1.LizensiaOPTPiv,CAll)+
   Nocondensed[Nprint^.DAt.Printer]+
   ' при расчетах по налогу на добавленную стоимость');
 End;

   {Writeln(Txt,MinInterval2[Nprint^.DAt.Printer]);}
{  Writeln(Txt,Space+'                                               Приложение N 1');
   Writeln(Txt,Space+'                                   к порядку ведения журналов счетов-фактур');
   Writeln(Txt,Space+'                                при расчетах по налогу на добавленную стоимость');
   Writeln(txt,Space+'-----------------------------------------------------------------------------------------------');}




{
   Writeln(Txt,Space+'   '+
   Bold[Nprint^.DAt.Printer]+Italic[Nprint^.DAt.Printer]+High[Nprint^.DAt.Printer]+Rek1.Name+'!'+NoHigh[Nprint^.DAt.Printer]+
   +NoBold[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer]);

   Writeln(Txt,Space+Bold[Nprint^.DAt.Printer]+Italic[Nprint^.DAt.Printer]+
   '  Все безналичные перечисления по документам, выписанным начиная с 13/06/2000,'+
   NoBold[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer]);

   Writeln(Txt,Space+Bold[Nprint^.DAt.Printer]+Italic[Nprint^.DAt.Printer]+
   '              проводите по ниже указанным банковским реквизитам!'+
   NoBold[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer]);

   Writeln(Txt);
}
   s:=Cl^.Dat.FullNAme{GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   Writeln(Txt,Condensed[Nprint^.DAt.Printer]+Space+
   'Продавец:'+Format(Rek1.Name,CAll)+'                     Покупатель:'+Format(s,CAll));

   s:=Cl^.Dat.Adress{GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   Writeln(Txt,Space+
   'Адрес:'+Format(Rek1.Adress,CAll)+'                        Адрес:'+Format(s,CAll));

   s:=Cl^.Dat.Telefon{GetClientField(FTelefon,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   Writeln(Txt,Space+
   'Телефон:'+Format(Rek1.Telefon,CAll)+'                      Телефон:'+Format(s,CAll));

{  убрал за ненадобностью для увеличения места на листе 20.09.2002 - финик сказал}
(*
   s:=Cl^.Dat.Gorod{GetClientField(FGorod,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   Writeln(Txt,Space+
   'Город:'+Format(Rek1.Gorod,CAll)+'                        Город:'+Format(s,CAll));
*)


   s:=Cl^.Dat.INN{GetClientField(FInn,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   Writeln(Txt,Space+
   'ИНН продавца:'+Format(Rek1.INN,CAll)+'                 ИНН покупателя:'+Format(s,CAll));


   {
   Writeln('ИНН:'+Format(Rek1.INN,CAll)+'                          ИНН:'+Format(s,CAll));
   Readln;
   }



   s:=Cl^.Dat.R_Sh{GetClientField(FRSh,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   Writeln(Txt,Space+
   'Расчетный счет:'+Format(Rek1.R_Sh,CAll){+'               Расчетный счет:'+Format(s,CAll)});

   Writeln(Txt,Space+
   'Корр.счет:'+Format(Rek1.K_Sh,CAll));

   s:=Cl^.Dat.Gde{GetClientField(FGde,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};

   Writeln(Txt,Space+
   'в:'+Format(Rek1.Gde,CAll+20){+'        в:'+Format(s,CAll)});
   Writeln(Txt,Space+
   'БИК:'+Format(Rek1.BIK,CAll));

{  убрал за ненадобностью для увеличения места на листе 23.10.98
   s:=GetClientField(FOkonh,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'ОКОНХ:'+Format(Rek1.Okonh,CAll)+'                        ОКОНХ:'+Format(s,CAll));

   s:=GetClientField(FOkpo,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'ОКПО:'+Format(Rek1.Okpo,CAll)+'                         ОКПО:'+Format(s,CAll));
}


   s:=Cl^.Dat.Enviropment{GetClientField(FEnvir,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   Writeln(Txt,Header+Space+Condensed[Nprint^.DAt.Printer]+
   'Грузоотправитель и его адрес:'+Format({Rek1.Name}
   Rek1.AdressGruza,CAll)+
   ' Дополнительно (N лиценз.):'+Format(s,CAll));
   s:=Cl^.Dat.Adress{GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};
   ws:=Cl^.Dat.Name{GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)};

   Writeln(Txt,Space+
   'Грузополучатель и его адрес:'+ws+' '+s);
   Writeln(Txt,Space+'К платежно-расчетному документу N '+E^.Dat.Document+' от '+E^.Dat.DAteC);
   Writeln(Txt,NoCondensed[Nprint^.DAt.Printer]);

DelZerro(E^.Dat.Document);
Barter[0]:=#0;

s1[0]:=#0;
   If (E^.Dat.Versia>1) And ((Not(E^.Dat.Realiz)) Or ((E^.Dat.Realiz)And Not(E^.Dat.DocSelector in [0,1,2,3,4])))
     Then
    Begin
     s1:=s1+
	'                                                                     Версия: '+IntToStr(E^.Dat.Versia,CLitrMantissa);
    End;

   If S1[0]<>#0 Then
   Writeln(txt,Space+s1);

s1:=Rek1.TextMSG_Sf;
DelSpaceRight(s1);
If s1[0]<>#0 Then
Begin
Writeln(Txt,Space+Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+s1+
Nobold[Nprint^.DAt.Printer]+Nodouble[Nprint^.DAt.Printer]);
Writeln(Txt);
End;


DelSpace(E^.DAt.Document);
SDocs:=E^.DAt.Document;
RFormatZerro(SDocs,CDocNumer);
SDates:=ZakazDate;
Razvorot(SDates);
SDates:=ClearChar(SDates);
SKods:=IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa);
RFormatZerro(SKods,CMantissa);
SDocs:=SDATEs+SKODs+SDocs;


If E^.Dat.Realiz Then
Begin
ws:=E^.Dat.DAteC;
If E^.Dat.DocSelector in [5,6,7,8] Then
Writeln(Txt,Space+Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+'СТАТУС: Документ подлежит оплате'+
Nobold[Nprint^.DAt.Printer]+Nodouble[Nprint^.DAt.Printer])
Else
Writeln(Txt,Space+Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+'СТАТУС: Документ оплачен'+
Nobold[Nprint^.DAt.Printer]+Nodouble[Nprint^.DAt.Printer]);


ws:=ClearChar(ws);
Writeln(Txt,Space+'                                                                          '+
Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+'НК'+ws+E^.Dat.Document{E^.Dat.DocReal}+NOBold[Nprint^.DAt.Printer]+
NoDouble[Nprint^.DAt.Printer]{NoItalic});
{Writeln(txt,Space+Bold+Double+'Тип документа: (',LeadingZero(E^.Dat.DocSelector),')'+NOBold+NoDouble);}

If E^.Dat.OperatorSelector<2 Then Barter[0]:=#0
Else Barter:='-Б';

DelSpace(E^.DAt.Document);
SDocs:=E^.DAt.Document;
RFormatZerro(SDocs,CDocNumer);
SDates:=E^.Dat.DateC;
Razvorot(SDates);
SDates:=ClearChar(SDates);
SKods:=IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa);
RFormatZerro(SKods,CMantissa);
SDocs:=SDATEs+SKODs+SDocs;


If Not Comissioner Then
Begin
If E^.Dat.DocSelector in [5,6,7,8] Then
   Writeln(Txt,Space+High[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+'        СЧЕТ-ФАКТУРА N '+
   {ZakazNumer+E^.Dat.Document+}SDocs+
   Barter+
   {'/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)}+
   ' от '+ZakazDate+
   NoHigh[Nprint^.DAt.Printer]+
   NoDouble[Nprint^.DAt.Printer])
Else
   Writeln(Txt,Space+High[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+'        СЧЕТ-ФАКТУРА N '+
   {ZakazNumer+E^.Dat.DocReal+Barter}+SDocs+
   {'/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)+}
   ' от '+ZakazDate{E^.Dat.DocDAte}+
   NoHigh[Nprint^.DAt.Printer]+
   NoDouble[Nprint^.DAt.Printer]);
End
Else
 Begin
   If E^.Dat.OperatorSelector<2 Then Barter[0]:=#0
   Else Barter:='-Б';
   Writeln(Txt,Space+High[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+'        СЧЕТ-ФАКТУРА N '+'_________'+
   ' от '+'__________'+NoHigh[Nprint^.DAt.Printer]+NoDouble[Nprint^.DAt.Printer]);
 End;


If E^.Dat.Oformlenie=1 Then
Begin
If ((E^.Dat.Realiz) And (E^.Dat.DocSelector in [5,6,7,8])) Or
   (Not (E^.Dat.Realiz) And (E^.Dat.DocSelector in [0,1,2,3,4]))
 Then
Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+
E^.Dat.Document+barter+'/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)++' '+E^.Dat.DateC+' ('+E^.Dat.TimeC+')'+
NoItalic[Nprint^.DAt.Printer]+NoDouble[Nprint^.DAt.Printer])
Else
Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+
E^.Dat.DocReal+barter+'/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)+' '+
DateToDateString(DateMask,E^.Dat.DocDate)+' ('+E^.Dat.TimeC+')'+
NoItalic[Nprint^.DAt.Printer]+NoDouble[Nprint^.DAt.Printer])
End;

End
Else
 Begin
   If E^.Dat.OperatorSelector<2 Then Barter[0]:=#0
   Else Barter:='-Б';


If Not Comissioner Then
Begin
   Writeln(Txt,Space+High[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+'        СЧЕТ-ФАКТУРА N '+
   (*{ZakazNumer+}E^.Dat.Document+*)+SDocs+
   Barter+
   {'/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)+}
   ' от '+ZakazDate+
   NoHigh[Nprint^.DAt.Printer]+
   NoDouble[Nprint^.DAt.Printer])
End
Else
 Begin
   Writeln(Txt,Space+High[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+'        СЧЕТ-ФАКТУРА N '+'_________'+
   ' от '+'__________'+NoHigh[Nprint^.DAt.Printer]+NoDouble[Nprint^.DAt.Printer]);
 End;



If E^.Dat.Oformlenie=1 Then
Begin
Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+
E^.Dat.Document+barter+'/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)+' '+E^.Dat.DateC+' ('+E^.Dat.TimeC+')'+
NoItalic[Nprint^.DAt.Printer]+NoDouble[Nprint^.DAt.Printer])
End;


 End;

   Space:=' ';
   ItogoSkidka:=0;  Itogo:=0; NDS:=0; NDSPos:=0; ItogoPos:=0;PromitogoPos:=0;
   ItogoLitr:=0; NDS20:=0; NDS10:=0;NDS18:=0; NDS_:=0;
   Koefficient[0]:=#0;
   If ShemaAkzis=1 Then E^.DAt.SummaAkzis:='0.00';

 If E^.Dat.Oformlenie=1 Then
 Writeln(txt,Space+Condensed[Nprint^.DAt.Printer]+
 Italic[Nprint^.DAt.Printer]+'По заказу N '+E^.DAt.FromZakaz+NoItalic[Nprint^.DAt.Printer]+
 NoCondensed[Nprint^.DAt.Printer]);


   For l:=1 To E^.Dat.Amount Do
   Itogo:=Itogo+StrToReal(E^.Dat.MarketElement[l].Input.Zena)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);
{
   Writeln(txt,Space+'---------------------------------------------------------------------------------------------');
   Writeln(txt,Space+'Наименование товара        Ед Колич     Цена         Сумма  НДС     Сумма НДС     Итого сумма');
   Writeln(txt,Space+'                                                             %                     с НДС и НП');
   Writeln(txt,Space+'---------------------------------------------------------------------------------------------');
}



{финик сказал 20.09.2002}
Writeln(txt,Space+Condensed[Nprint^.DAt.Printer]+
Italic[Nprint^.DAt.Printer]+'Валюта: руб.'+NoItalic[Nprint^.DAt.Printer]+NoCondensed[Nprint^.DAt.Printer]);

Writeln(txt,Condensed[Nprint^.DAt.Printer]+MinInterval2[Nprint^.DAt.Printer]+
            Space+
'┌─────────────────────────────┬────────┬───────┬───────┬────────────┬────────┬───┬────────────┬─────────────'+
'┬──────────────┬──────────────────────┐');
Writeln(txt,
Space+'│N Наименование товара        │Единица │ Колич.│ Цена  │Стоимость то│ В т.ч  │НДС│ Сумма НДС  │ Итого сумма '+
'│    Страна    │N Грузовой таможенной │');
Writeln(txt,
Space+'│                             │измерен.│       │за един│вара без НДС│ акциз  │ % │            │   с НДС     '+
'│происхождения │     декларации       │');
Writeln(txt,
Space+'└─────────────────────────────┴────────┴───────┴───────┴────────────┴────────┴───┴────────────┴─────────────'+
'┴──────────────┴──────────────────────┘'+
Normal[Nprint^.DAt.Printer]+Condensed[Nprint^.DAt.Printer]+HeaderStop);

   New(Lg,Init);
   k:=1;j:=1;
*)
   For l:=1 To E^.Dat.Amount Do
    Begin

     If testMarketSF(E^.Dat.MarketElement[l].BazKod,Lg,j) Then
      Begin
       Str((StrToInt(Lg^.Dat.MarketElement[j].Input.Kol)+
            StrToInt( E^.Dat.MarketElement[l].Input.Kol)):CKol,Lg^.Dat.MarketElement[j].Input.Kol);
      End
      Else
      Begin
       Lg^.Dat.MarketElement[k]:=E^.Dat.MarketElement[l];
       Inc(k);
       Lg^.DAt.Amount:=k-1;
      End;
    End;
    Lg^.DAt.Amount:=k-1;


   New(BBB,Init);
   New(Skl,Init);

   For l:=1 To Lg^.Dat.Amount Do
    Begin

   s2[0]:=#0;
   s3[0]:=#0;
   s4[0]:=#0;

   Skl^.Dat.BAzKod:=Lg^.Dat.MarketElement[l].BazKod;
   GetSkladRecord(Skl);
   GetBazElement(Lg^.Dat.MarketElement[l].BazKod,BBB^.Dat);

     ItogoLitr:=ItogoLitr+StrToReal(BBB^.Dat.Litr{GetIdField(FLitr,Lg^.Dat.MarketElement[l].BazKod)})*
     StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=Lg^.Dat.MarketElement[l].BazKod;
     s4:=IntToStr(l,CMantissa);
     RFormat(s4,CMantissa);

     Etil[0]:=#0;

{$IFNDEF Pharm}
{$IFNDEF Tabak}
     Etil:=RealToStr(StrToReal(BBB^.Dat.Etil),CLitr,CMantissa);
     DelSpace(Etil);
     Etil:=' '+Etil+'%';
{$ENDIF}
{$ENDIF}
     If Nprint^.DAt.FullName=0 Then
     Begin
      ws:=BBB^.Dat.NAme{GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod)};
      ws1:=BBB^.Dat.NAme2{GetIdField(FName2,Lg^.Dat.MarketElement[l].BazKod)};
      DelSpaceRight(ws1);
      ws1:=ws1+''+Etil;
      If ws1[0]<>#0 Then
           Begin
            Writeln(txt,Space+Condensed[Nprint^.DAt.Printer]+s4+' '+ws);
            ws:=ws1;
            s4:='  '
           End
     End
     Else
         Begin
          ws:=BBB^.Dat.NAme{GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod)};
          ws1:=BBB^.Dat.NAme2{GetIdField(FName2,Lg^.Dat.MarketElement[l].BazKod)};
          DelSpaceRight(ws1);
          ws1:=ws1+''+Etil;

       If ws1[0]<>#0 Then
           Begin
            Writeln(txt,Space+Condensed[Nprint^.DAt.Printer]+s4+' '+ws);
            ws:=ws1;
            s4:='  '
           End

      End;

     Format(ws,CName);
     s:=ws;
     s:=s4+'  '+s{+' '+s3+' '+s2};
     ws:=Lg^.Dat.MarketElement[l].Input.Kol;
     DelSpace(Ws);
     RFormat(ws,CKol);

     s2:=BBB^.Dat.Mera{GetIdField(FMera,Lg^.Dat.MarketElement[l].BazKod)};
     s2:=GetMeraField(FMera,s2);
     Format(s2,CMera-6);

     s:=s+' '+{GetIdField(FMera,Lg^.Dat.MarketElement[l].BazKod)}s2+' '+ws;
              {ед}

     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
       MyStr((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(Lg^.Dat.MarketElement[l].Input.Proz)/100))
       ,CZena,CMantissa,ws){новая цена}
     Else
       MyStr((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)-
                 StrToReal(Lg^.Dat.MarketElement[l].Input.Skidka)),
                    CZena,CMantissa,ws);{новая цена}

     NormalZena:=ws;

       NPNalog[0]:=#0;
       {отключен расчет налога с продажи в товарном чеке}
       {06-02-02  и в остальных документах}
       If E^.DAt.DocSelector in [{1,2,3,5,6}100] Then
       Begin
       Mystr(((1+strtoreal(Lg^.dat.marketelement[l].Input.SpecNalog)
        /100)),CZenaZ,CMantissaZ,koefficient);
       {новая цена}
{$IFDEF NSP}
       MyStr((StrToReal(NormalZena)-StrToReal(NormalZena)/StrToReal(Koefficient)),CZena,CMantissa,NPNalog);
{$ELSE}
       MyStr((StrToReal(NormalZena)*StrToReal(Koefficient)-StrToReal(NormalZena)),CZena,CMantissa,NPNalog);
{$ENDIF}
       MyStr(StrToReal(NPNalog)*StrToInt(Lg^.dat.marketelement[l].Input.Kol),CZena,CMantissa,NPNAlog);
{$IFDEF NSP}
       MyStr(StrToReal(NormalZena)/StrToReal(Koefficient),CZena,CMantissa,RealZena);
{$ELSE}
       MyStr(StrToReal(NormalZena){*StrToReal(Koefficient)},CZena,CMantissa,RealZena);
{$ENDIF}
       End
       Else
           Begin
            RealZena:=ws;
            MyStr(StrToReal(NPNalog),CZena,CMantissa,NPNalog);
           End;

       If (Abs(StrToReal(NPNalog))<0.009) Or (E^.Dat.Rashet in [1,2]) Then NpNalog:='    --  ';

{Вычли скидку из цены}
{!!!!} ItogoPos:=StrToReal(RealZena{ws})*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
{Было  ItogoPos:=StrToReal(ws)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);}

{расчитали сумму Итого в позиции со скидкой}
       NdsPos:=ItogoPos*
       StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)/(100+StrToReal(Lg^.Dat.MarketElement[l].Input.NDS));

       Test:=StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
       If Test <> 0 Then
       Begin
       MyStr(((ItogoPos-NDSPos)/StrToInt(Lg^.Dat.MarketElement[l].Input.Kol)),CZena,CMantissa,ws);
       MyStr(StrToReal(ws),CZena,CMantissa,ws);
       End
       Else Ws:='        ';

       s:=s+' '+ws;

       MyStr(NDSPos,CIZena,CMantissa,Ws);

       NdsPos:=StrToReal(Ws);

       MyStr((ItogoPos-NDSPos),CInputIZena-2,CMantissa,ws);
{получили Сумму цены со скидкой и без НДС в позиции}

       SAkzis:='    0.00';
       MyStr(StrToReal(Lg^.Dat.MarketElement[l].Input.AkzisSbor)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol),
       CZena,CMantissa,SAkzis);

       If ShemaAkzis=1 Then
        Begin
        SAkzis:='    0.00';
        if StrToInt(GetIdField(FBuchGroup,Lg^.Dat.MarketElement[l].BazKod)) in [1,2,3,4,7] then
        begin

         if StrToInt(GetIdField(FBuchGroup,Lg^.Dat.MarketElement[l].BazKod)) in [1,2,3] then
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(FBuchGroup,Lg^.Dat.MarketElement[l].BazKod))])
	   *0.8
	   *StrToInt(Lg^.Dat.MarketElement[l].Input.Kol)
	   *StrToReal(GetIdField(FLitr,Lg^.Dat.MarketElement[l].BazKod))
	   *StrToReal(GetIdField(FEtil,Lg^.Dat.MarketElement[l].BazKod))
        /100,
         CZena,CMantissa,SAkzis)
         Else
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(FBuchGroup,Lg^.Dat.MarketElement[l].BazKod))])
	   *0.65
	   *StrToInt(Lg^.Dat.MarketElement[l].Input.Kol)
	   *StrToReal(GetIdField(FLitr,Lg^.Dat.MarketElement[l].BazKod))
	   *StrToReal(GetIdField(FEtil,Lg^.Dat.MarketElement[l].BazKod))
        /100,
         CZena,CMantissa,SAkzis);

         MyStr(StrToReal(SAkzis)+StrToReal(E^.Dat.SummaAkzis),CIZena,CMantissa,E^.Dat.SummaAkzis);
        end
        else
        begin

         if StrToInt(GetIdField(FBuchGroup,Lg^.Dat.MarketElement[l].BazKod)) in [1,2,3] then
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(FBuchGroup,Lg^.Dat.MarketElement[l].BazKod))])
	   *0.8
	   *StrToInt(Lg^.Dat.MarketElement[l].Input.Kol)
	   *StrToReal(GetIdField(FLitr,Lg^.Dat.MarketElement[l].BazKod))
        ,CZena,CMantissa,SAkzis)
        Else
         MyStr(
	    StrToReal(AkzisKoeff[StrToInt(GetIdField(FBuchGroup,Lg^.Dat.MarketElement[l].BazKod))])
	   *0.65
	   *StrToInt(Lg^.Dat.MarketElement[l].Input.Kol)
	   *StrToReal(GetIdField(FLitr,Lg^.Dat.MarketElement[l].BazKod))
        ,CZena,CMantissa,SAkzis);

         MyStr(StrToReal(SAkzis)+StrToReal(E^.Dat.SummaAkzis),CIZena,CMantissa,E^.Dat.SummaAkzis);
        end;
        End;


       If Not(StrToInt(Rek^.Dat.Kod) in [5]) Then
       SAkzis:='    --  ';

       If (Abs(StrToReal(SAkzis))<0.009) Then SAkzis:='    --  ';
       s:=s+'  '+ws+' '+SAkzis{'   --   '};

       PromitogoPos:=PromitogoPos+StrToReal(ws);

       ws:=Lg^.Dat.MarketElement[l].Input.NDS;

       MyStr(StrToReal(ws),CLitr-1,0{CMantissa-1},ws);

       s:=s+' '+Format(Ws,CLitr-1);

       MyStr(NDsPos,CInputIZena-1,CMantissa,ws);

{расчитали размер НДС в позиции}
       s:=s+''+ws;

{расчитали ставку НП в позиции}
       If Not (E^.DAt.DocSelector in [1,2,3,5,6]) Then ws:='0.00'
       Else  ws:=Lg^.Dat.MarketElement[l].Input.SpecNalog;

       ItogoPos:=StrToReal(NormalZena)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);

       MyStr(ItogoPos,CInputIZena-2,CMantissa,ws);
       s:=s+'  '+ws;
       Nds:=Nds+NDSPos;

{разборка  НДС по классификации}
       Case Lg^.Dat.MarketElement[l].Input.VidNDs Of
       0:Nds20:=Nds20+NdsPos;
       1:Nds10:=Nds10+NdsPos;
       2:Nds_:=Nds_+NdsPos;
       3:Nds18:=Nds18+NdsPos;
       Else;
       End;




{сумма НДС по с/ф}

   s2[0]:=#0;
   s3[0]:=#0;
 If PrintGTD[2]=1 Then
  Begin
   s2:=GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD){BakGetField(FNGTD,Lg^.Dat.MarketElement[l].BazKod,0)};
   s3:=GetPostField(FPost,BBB^.Dat.PostKod){BakGetField(FPost,Lg^.Dat.MarketElement[l].BazKod,0)};
  End;
   DelSpaceRight(s2);
   DelSpaceRight(s3);
   Format(s2,CNGTD-16{13 для того что бы влез акциз});
   Format(s3,CPost);



   If L=Lg^.DAt.Amount Then s:=OnlyLink+s;

     Writeln(txt,Space+Pitch[Nprint^.DAt.Printer]+Condensed[Nprint^.DAt.Printer]+
        s+{' '+NPNalog+}'  '+s3+' '+s2+NoPitch[Nprint^.DAt.Printer]);

    End;
    DelSpace(E^.Dat.SummaZ);
    SSummaZ:=E^.Dat.SummaZ;
    RFormat(SSummaZ,CIZena-4);
    DelSpace(E^.Dat.ENalog);
    MyStr(StrToReal(E^.Dat.ENalog),CZena-1,CMantissa,ItogNalog);
    Writeln(txt,Space+'__________________________________________________________________________________________'+
    '________________________________________________________'+NoCondensed[Nprint^.DAt.Printer]);
    MyStr(StrToReal(SSummaZ),CIZena-4,CMantissa,SSummaZ);
    Writeln(Txt,Space+'Всего позиций:',Lg^.Dat.Amount:2);
    Writeln(Txt,Space+'Всего к оплате:           ',PromItogoPos:CIZena:CMantissa,'     ',NDs:CinputIZena-3:CMantissa,
    ' ',SSummaZ);
    If (StrToInt(Rek^.Dat.Kod) in [5]) Then
    Writeln(Txt,Space+Bold[Nprint^.DAt.Printer]+'в т.ч. акциз: ',StrToReal(E^.DAt.SummaAkzis):CIZena:CMantissa,
    NoBold[Nprint^.DAt.Printer]);

    if not((Pharm=1)) Or (Pharm=1) Then
    Writeln(Txt,Space+'Всего ',ItogoLitr:CILitr:CLitrMantissa,' литров алкогольной продукции');
    Writeln(txt,Space+Condensed[Nprint^.DAt.Printer]+

    '_____________________________________________________________________________________________'+
    '_____________________________________________________'+NoCondensed[Nprint^.DAt.Printer]);
    If E^.Dat.DocSelector in [3,4,6,8] Then
    Begin
    s:=E^.Dat.SummaZ;
    DelSpace(s);
    Propis(s,ws);
    ws[1]:=UpperCase(ws[1]);
    Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+ws+
    NoItalic[Nprint^.DAt.Printer]+
    NoBold[Nprint^.DAt.Printer]+NoDouble[Nprint^.DAt.Printer]);
    If s[0]<>#0 Then
    Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+s+
    NoItalic[Nprint^.DAt.Printer]+
    NoBold[Nprint^.DAt.Printer]+NoDouble[Nprint^.DAt.Printer])
    End;
{
if ((Pharm=1)) Then
Begin
    Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+
    'НДС не облагается'+NoItalic[Nprint^.DAt.Printer]+
    NoBold[Nprint^.DAt.Printer]+NoDouble[Nprint^.DAt.Printer]);
End;
}

    Writeln(txt,Space+Condensed[Nprint^.DAt.Printer]+
    '_____________________________________________________________________________________________'+
    '_____________________________________________________'+NoCondensed[Nprint^.DAt.Printer]);



{$IFNDEF Pharm}
  If E^.Dat.Rashet in [1,2] Then
  Begin
   Writeln(Txt,Space+Bold[Nprint^.DAt.Printer]+Italic[Nprint^.DAt.Printer]+
   '     ┌───────────────────────────────────────────────────────────────────────────┐');
   Writeln(Txt,Space+
   '     │Уважаемые клиенты! Обязательно указывайте свой индивидуальный код ('+
   Copy(Rek^.Dat.Kod,3,CMantissa)+E^.Dat.ClientKod+') │');
   Writeln(Txt,Space+
   '     │в графе "назначение платежа" платежного поручения                          │'+
    +
   NoBold[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer]);
   Writeln(Txt,Space+
   '     └───────────────────────────────────────────────────────────────────────────┘');
  End;

  If TestOpenDate1(E^.Dat.DateC) Then
  Begin
   s:=CalcDolgSF(E^.DAt.ClientKod);
   If StrToReal(s) >0 Then
   Begin
   RFormat(S,CIzena);
   {
   Writeln(Txt,Space+Bold[Nprint^.DAt.Printer]+Italic[Nprint^.DAt.Printer]+
   '  ┌──────────────────────────────────────────────────────────────────────────────────┐');}
   Writeln(Txt,Space+Bold[Nprint^.DAt.Printer]+Italic[Nprint^.DAt.Printer]+
   '   Внимание! Ваша задолженность на '+E^.Dat.DateC+'('+Times+') составляет  '+s+' руб '+
   NoBold[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer]);
   {
   Writeln(Txt,Space+
   '  └──────────────────────────────────────────────────────────────────────────────────┘'+
   NoBold[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer]);
   }
   End;
  End;

{$ENDIF}


   Writeln(Txt);
   Writeln(Txt,Space+'   Руководитель предприятия '+Rek1.Director+'               Главный бухгалтер '+Rek1.Buchgalter);
   Writeln(Txt);
   Writeln(Txt,Space+'   Сдал _______          М.П.');
   Writeln(txt,Space);
   Writeln(Txt,Space+'   Примечание: 1.Без печати недействителен');
   Writeln(Txt,Space+'               2.Первый экземпляр-покупателю, второй-продавцу');

   If E^.Dat.Rashet=2 Then Symbol:='-В'
   Else Symbol:='';

   Writeln(txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+
   ')'+Italic[Nprint^.DAt.Printer]+Bold[Nprint^.DAt.Printer]+
   Double[Nprint^.DAt.Printer]+'                                                Тип документа: (',
                     LeadingZero(E^.Dat.DocSelector),+Symbol+')'+NoItalic[Nprint^.DAt.Printer]+NOBold[Nprint^.DAt.Printer]+
                                 NoDouble[Nprint^.DAt.Printer]);

    Writeln(txt,Space+Condensed[Nprint^.DAt.Printer]+
    '=========================================================================================='+
    '====================================================='+NoCondensed[Nprint^.DAt.Printer]+Normal[Nprint^.DAt.Printer]
    );
   Dispose(Lg,Done);

   Dispose(Cl,Done);
   Dispose(BBB,Done);
   Dispose(Skl,Done);

If Not(Video) Then NoInfoMsg;

End;


