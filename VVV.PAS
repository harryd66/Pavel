 Procedure FormSF( Video : Boolean; E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Real);
Var l : Word;
    k,j : Byte;
    s,ws,ws1 : String;
    {ГТД и производитель}
    s2,s3,s4 : String;
    kkk:Text;
    st : String[CMantissa];
    ItogoLitr,PromItogoPos,ItogoPos,NDSPos : Real;
    Test : LongInt;
    SDoc,SDate,SummaNDS : String[CInputIZena];
    RealZena,ITOGONDS_NP,SummaZena: String[CInputIZena];
    Space : AllStr;
    ItogNalog,Koefficient,pp : String[CPack];
    Rek1 :Rekwiziti;
    Lg : PSuperMarketType;
    Barter : String[CMantissa];
    Art : ArtikulStr;
    Res : Word;
Begin
   s:=E^.Dat.Document;
   s:=Bold[NPrint.Printer]+S+NoBold[NPrint.Printer];
   Space:='     ';
   Rek1:=Rek;
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                         '+
   Nocondensed[NPrint.Printer]+
   '                 Приложение N 1');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                         '+
   Nocondensed[NPrint.Printer]+
   '   к порядку ведения журналов счетов-фактур');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                         '+
   Nocondensed[NPrint.Printer]+
   ' при расчетах по налогу на добавленную стоимость');
   Writeln(Txt);
{  Writeln(Txt,Space+'                                               Приложение N 1');
   Writeln(Txt,Space+'                                   к порядку ведения журналов счетов-фактур');
   Writeln(Txt,Space+'                                при расчетах по налогу на добавленную стоимость');
   Writeln(txt,Space+'-----------------------------------------------------------------------------------------------');}

   s:=GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Condensed[NPrint.Printer]+Space+
   'Поставщик:'+Format(Rek1.Name,CAll)+'                    Покупатель:'+Format(s,CAll));

   s:=GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'Адрес:'+Format(Rek1.Adress,CAll)+'                        Адрес:'+Format(s,CAll));

   s:=GetClientField(FTelefon,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'Телефон:'+Format(Rek1.Telefon,CAll)+'                      Телефон:'+Format(s,CAll));

{ убрал за ненадобностью для увеличения места на листе 23.10.98
   s:=GetClientField(FRSh,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'Расчетный счет:'+Format(Rek1.R_Sh,CAll)+'               Расчетный счет:'+Format(s,CAll));

   s:=GetClientField(FGde,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'в:'+Format(Rek1.Gde,CAll)+'                            в:'+Format(s,CAll));

   s:=GetClientField(FGorod,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'Город:'+Format(Rek1.Gde,CAll)+'                        Город:'+Format(s,CAll));
}
   s:=GetClientField(FInn,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'ИНН:'+Format(Rek1.INN,CAll)+'                          ИНН:'+Format(s,CAll));

{ убрал за ненадобностью для увеличения места на листе 23.10.98
   s:=GetClientField(FOkonh,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'ОКОНХ:'+Format(Rek1.Okonh,CAll)+'                        ОКОНХ:'+Format(s,CAll));

   s:=GetClientField(FOkpo,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'ОКПО:'+Format(Rek1.Okpo,CAll)+'                         ОКПО:'+Format(s,CAll));
}
   s:=GetClientField(FEnvir,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'Грузоотправитель и его адрес:'+Format({Rek1.Name}
   Rek1.AdressGruza,CClient{All})+
   '                          Дополнительно (N лиценз.):'+Format(s,CAll));
   s:=GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   ws:=GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'Грузополучатель и его адрес:'+ws+' '+s);
DelSpace(E^.DAt.Document);

   Writeln(Txt,Space+'К платежно-расчетному документу N _____________'{+E^.Dat.NaklNumer+' от '+E^.Dat.DAteC});
   Writeln(Txt,NoCondensed[NPrint.Printer]);

DelZerro(E^.Dat.Document);
Barter[0]:=#0;
If E^.Dat.Realiz Then
Begin
{ws:=E^.Dat.DocDate;}
ws:=E^.Dat.DAteC;

If E^.Dat.DocSelector in [5,6,7,8] Then
Writeln(Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'СТАТУС: Документ подлежит оплате'+Nobold[NPrint.Printer]+
Nodouble[NPrint.Printer])
Else
Writeln(Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'СТАТУС: Документ оплачен'+Nobold[NPrint.Printer]+
Nodouble[NPrint.Printer]);

ws:=ClearChar(ws);
Writeln(Txt,Space+'                                                                          '+
Bold[NPrint.Printer]+Double[NPrint.Printer]+'НК'+ws+E^.Dat.Document{E^.Dat.DocReal}+NOBold[NPrint.Printer]+
NoDouble[NPrint.Printer]{NoItalic});
{   Writeln(txt,Space+Bold+Double+'Тип документа: (',LeadingZero(E^.Dat.DocSelector),')'+NOBold+NoDouble);}

If E^.Dat.OperatorSelector<2 Then Barter[0]:=#0
Else Barter:='-Б';

DelSpace(E^.DAt.Document);

If E^.Dat.DocSelector in [6,8] Then
   Writeln(Txt,Space+High[NPrint.Printer]+Double[NPrint.Printer]+'        СЧЕТ-ФАКТУРА N '+E^.Dat.Document+
   ' от '
   +E^.Dat.DAteC+
   NoHigh[NPrint.Printer]+
   NoDouble[NPrint.Printer])
Else
   Writeln(Txt,Space+High[NPrint.Printer]+Double[NPrint.Printer]+'        СЧЕТ-ФАКТУРА N '+E^.Dat.Document+
   ' от '
   +E^.Dat.DocDAte+
   NoHigh[NPrint.Printer]+
   NoDouble[NPrint.Printer]);
End
Else
 Begin
{   Writeln(txt,Space+Bold+Double+'Тип документа: (',LeadingZero(E^.Dat.DocSelector),')'+NOBold+NoDouble);}
   If E^.Dat.OperatorSelector<2 Then Barter[0]:=#0
   Else Barter:='-Б';

   Writeln(Txt,Space+High[NPrint.Printer]+Double[NPrint.Printer]+'        СЧЕТ-ФАКТУРА N '+E^.Dat.Document+
   ' от '
   +E^.Dat.DAteC+
   NoHigh[NPrint.Printer]+
   NoDouble[NPrint.Printer]);
 End;

   Space:=' ';
   ItogoSkidka:=0;  Itogo:=0; NDS:=0; NDSPos:=0; ItogoPos:=0;PromitogoPos:=0;
   ItogoLitr:=0; NDS20:=0; NDS10:=0; NDS_:=0;
   Koefficient[0]:=#0;
   For l:=1 To E^.Dat.Amount Do
   Itogo:=Itogo+StrToReal(E^.Dat.MarketElement[l].Input.Zena)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);
{
   Writeln(txt,Space+'---------------------------------------------------------------------------------------------');
   Writeln(txt,Space+'Наименование товара        Ед Колич     Цена         Сумма  НДС     Сумма НДС     Итого сумма');
   Writeln(txt,Space+'                                                             %                     с НДС и НП');
   Writeln(txt,Space+'---------------------------------------------------------------------------------------------');
}
   Writeln(txt,Condensed[NPrint.Printer]+Space+'___________________________________________________________________________'+
   '_______________________________________________________________________________');
   Writeln(txt,Space+'N Наименование товара        Производство    N Грузовой таможенной декларации         Ед.Колич.   '+
   ' Цена          Сумма  НДС     Сумма НДС     Итого сумма');
   Writeln(txt,Space+'                                                                                                  '+
   '                       %                     с НДС и НП');
   Writeln(txt,Space+'____________________________________________________________________________________________________'+
   '______________________________________________________');
{  12│12345678901234567890123456│123456789012345678│1234567890123456789012345678901234567890│12│12345│12345678│123│
1234567890123│1234567890123}
{ убрана 12.04
   Writeln(txt,Space+'----------------------------------------------------------------------------------------------');
   Writeln(txt,Space+'Наименование товара        Ед Колич     Цена         Сумма  НДС     Сумма НДС  НП Итого сумма');
   Writeln(txt,Space+'                                                             %                  % с НДС и НП');
   Writeln(txt,Space+'----------------------------------------------------------------------------------------------');
}
                     {12345678901234567890123456│12│12345│12345678│1234567890123│1234│1234567890123│1234│123456789012345}
                                                                     {1234567890123 1234 1234567890123 1234567890123}
   New(Lg,Init);
   k:=1;j:=1;

   For l:=1 To E^.Dat.Amount Do
    Begin

     If testMarketSF(E^.Dat.MarketElement[l].BazKod,Lg,j) Then
      Begin
       Str((StrToInt(Lg^.Dat.MarketElement[j].Input.Kol)+
            StrToInt( E^.Dat.MarketElement[l].Input.Kol)):CKol,Lg^.Dat.MarketElement[j].Input.Kol);
{
       Lg^.Dat.MarketElement[j].Input.Zena:=E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[j].Input.SpecNalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
       Lg^.Dat.MarketElement[j].Input.NDS:=E^.Dat.MarketElement[l].Input.NDS;
}
      End
      Else
      Begin
       Lg^.Dat.MarketElement[k]:=E^.Dat.MarketElement[l];
{      Lg^.Dat.MarketElement[k].Input.Zena:=E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[k].Input.SpecNalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
       Lg^.Dat.MarketElement[k].Input.NDS:=E^.Dat.MarketElement[l].Input.NDS;}
       Inc(k);
       Lg^.DAt.Amount:=k-1;
      End;
    End;
    Lg^.DAt.Amount:=k-1;


   For l:=1 To Lg^.Dat.Amount Do
    Begin

   s2:='';
   s3:={BakGetField(FPost,Lg^.Dat.MarketElement[l].BazKod,0)}'РОССИЯ';

   DelSpaceRight(s2);
   DelSpaceRight(s3);
   Format(s2,CNSertif);
   Format(s3,CPost);

     ItogoLitr:=ItogoLitr+StrToReal(GetIdField(FLitr,Lg^.Dat.MarketElement[l].BazKod))*
     StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=Lg^.Dat.MarketElement[l].BazKod;

     If NPrint.FullName=0 Then
     Begin
      ws:=GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod);
      ws1[0]:=#0;
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
	   Begin
	    Writeln(txt,Space+'   '+ws);
         ws:=ws1;
        End;
     End
     Else
	 Begin
	  ws:=GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod);
       ws1[0]:=#0;
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
	   Begin
	    Writeln(txt,Space+'   '+ws);
         ws:=ws1;
        End;
      End;

     Format(ws,CName);
     s:=ws;
     s4:=IntToStr(l,CMantissa);
     RFormat(s4,CMantissa);
     s:=s4+' '+s+' '+s3+' '+s2;
     ws:=Lg^.Dat.MarketElement[l].Input.Kol;
     DelSpace(Ws);
     RFormat(ws,CKol);
     s:=s+' '+GetIdField(FMera,Lg^.Dat.MarketElement[l].BazKod)+' '+ws;
              {ед}

     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
       Str((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(Lg^.Dat.MarketElement[l].Input.Proz)/100))
       :CZena:CMantissa,ws){новая цена}
     Else
       Str((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[l].Input.Skidka))
            :CZena:CMantissa,ws);{новая цена}


       If E^.DAt.DocSelector in [1,2,3,5,6] Then
       Begin
       str(((1+strtoreal(Lg^.dat.marketelement[l].Input.SpecNalog)
              /100)):CLitr:CMantissa,koefficient);
       {новая цена}
       Str(StrToReal(ws){*StrToReal(Koefficient)}:CZena:CMantissa,RealZena);
       End
       Else RealZena:=ws;




{Вычли скидку из цены}
       ItogoPos:=StrToReal({RealZena}ws)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);

{расчитали сумму Итого в позиции со скидкой}
       NdsPos:=ItogoPos*
       StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)/(100+StrToReal(Lg^.Dat.MarketElement[l].Input.NDS));


{NdsPos:=StrToReal(BakGetField
(FNds,Lg^.Dat.MarketElement[l].BazKod,0))/(100+StrToReal(BakGetField(FNDs,Lg^.Dat.MarketElement[l].BazKod,0)));}


       Test:=StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
       If Test <> 0 Then
       Begin
       Str(((ItogoPos-NDSPos)/StrToInt(Lg^.Dat.MarketElement[l].Input.Kol)):CZena:CMantissa,ws);
       Str(StrToReal(ws):CZena:CMantissa,ws);
       End
       Else Ws:='        ';
       s:=s+' '+ws;

       Str(NDSPos:CIZena:CMantissa,Ws);
       NdsPos:=StrToReal(Ws);


       Str((ItogoPos-NDSPos):CInputIZena:CMantissa,ws);
{получили Сумму цены со скидкой и без НДС в позиции}


       s:=s+' '+ws;

       PromitogoPos:=PromitogoPos+StrToReal(ws);
{
       ws:=BakGetField(FNds,Lg^.Dat.MarketElement[l].BazKod,0);
}

       ws:=Lg^.Dat.MarketElement[l].Input.NDS;

       Str(StrToReal(ws):CLitr-1:0{CMantissa-1},ws);
       s:=s+' '+Format(Ws,CLitr-1);

       Str(NDsPos:CInputIZena:CMantissa,ws);
{расчитали размер НДС в позиции}
       s:=s+' '+ws;

{расчитали ставку НП в позиции}
       If Not (E^.DAt.DocSelector in [1,2,3,5,6]) Then ws:='0.00'
       Else
       ws:=Lg^.Dat.MarketElement[l].Input.SpecNalog;

(*
       Str(StrToReal(ws):CLitr-1:0{CMantissa-1},ws);
       s:=s+{' '}+Format(Ws,CLitr-1);
*)
       ItogoPos:=StrToReal(RealZena)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);

       Str(ItogoPos:CInputIZena:CMantissa,ws);
       s:=s+'   '+ws;

       Nds:=Nds+NDSPos;

{разборка  НДС по классификации}
       Case Lg^.Dat.MarketElement[l].Input.VidNDs Of
       0:Nds20:=Nds20+NdsPos;
       1:Nds10:=Nds10+NdsPos;
       2:Nds_:=Nds_+NdsPos;
       Else;
       End;

(*
       If (StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)<20.01) And
          (StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)>19.99) Then
             Begin
              Nds20:=Nds20+NdsPos;
             End
       Else
          Begin
           If (StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)<10.01) And
              (StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)>9.99) Then
              Begin
                Nds10:=Nds10+NdsPos;
              End
           Else
              Begin
                Nds_:=Nds_+NdsPos;
              End
          End;
*)



{сумма НДС по с/ф}


     Writeln(txt,Space+s);
{
 If PrintGTD[2]=1 Then
  Begin
   s2:=BakGetField(FNGTD,Lg^.Dat.MarketElement[l].BazKod,0);
   s3:=BakGetField(FPost,Lg^.Dat.MarketElement[l].BazKod,0);
   DelSpaceRight(s2);
   DelSpaceRight(s3);
   If (s2[0]<>#0)Or(s3[0]<>#0) Then
    Begin
     Format(s2,CNSertif);
     WriteLn(txt,Space+'N ГТД/ТТН: '+s2+
	            ' Производство:'+s3);
    End;
  End;
}
    End;
    DelSpace(E^.Dat.SummaZ);
    RFormat(E^.Dat.SummaZ,CIZena-4);
    DelSpace(E^.Dat.ENalog);
    Str(StrToReal(E^.Dat.ENalog):CZena-1:CMantissa,ItogNalog);
    Writeln(txt,Space+'___________________________________________________________________________________________________'+
    '_______________________________________________________'+NoCondensed[NPrint.Printer]);
    Str(StrToReal(E^.Dat.SummaZ):CIZena-6:CMantissa,E^.Dat.SummaZ);
    Writeln(Txt,Space+'Всего позиций:',Lg^.Dat.Amount:2,'                   Всего к оплате: ',
    PromItogoPos:CIZena+4:CMantissa,'  ',NDs:CinputIZena-3:CMantissa,'  ',E^.Dat.SummaZ);
    {
    Writeln(Txt,Space+'Всего ',ItogoLitr:CILitr:CLitrMantissa,' литров алкогольной продукции');}
    Writeln(txt,Space+Condensed[NPrint.Printer]+'_________________________________________________________________________'+
    '____________________________'+
    '_____________________________________________________'+NoCondensed[NPrint.Printer]);

    If E^.Dat.DocSelector in [3,4,6,8] Then
    Begin
    s:=E^.Dat.SummaZ;
    DelSpace(s);
    Propis(s,ws);
    ws[1]:=UpperCase(ws[1]);
    Writeln(txt,Space+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+ws+NoItalic[NPrint.Printer]+
    NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
    If s[0]<>#0 Then
    Writeln(txt,Space+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+s+NoItalic[NPrint.Printer]+
    NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
    Writeln(txt,Space+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+
    'В том числе НДС: ',NDs:CinputIZena-3:CMantissa,NoItalic[NPrint.Printer]+
    NoBold[NPrint.Printer]+NoDouble[NPrint.Printer])
    End;
    Writeln(txt,Space+Condensed[NPrint.Printer]+'____________________________________________________________________________'+
    '____________________________'+
    '__________________________________________________'+NoCondensed[NPrint.Printer]);
   Writeln(Txt);
   Writeln(Txt,Space+'   Руководитель предприятия ________                Главный бухгалтер _______');
   Writeln(Txt);
   Writeln(Txt);
   Writeln(Txt,Space+'   Сдал _______          М.П.                   М.П.          Получил _______');
   Writeln(txt,Space+'                                                       (подпись ответственного лица)');
   Writeln(txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+
   ')'+Italic[NPrint.Printer]+Bold[NPrint.Printer]+
   Double[NPrint.Printer]+'                                                   Тип документа: (',
                     LeadingZero(E^.Dat.DocSelector),')'+NoItalic[NPrint.Printer]+NOBold[NPrint.Printer]+
				 NoDouble[NPrint.Printer]);

    Writeln(txt,Space+Condensed[NPrint.Printer]+'========================================================================='+
    '============================'+
    '====================================================='+NoCondensed[NPrint.Printer]);
   Dispose(Lg,Done);
End;
