{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit Vision11;

Interface

Uses Glob,ServStr,Dialogs,Utils,Vision1;

Procedure FormNaklTTNAkzis(Space :TDateString; Video : Boolean;As :DocumentEditZ;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Float;
                            ShowAnswer:Boolean;Zakaz:Boolean;NewSkidka:Boolean;NewSum:Float;VzwTxt:AllStr);

Procedure PrintOrder(E:PSuperMarketType; NDS,NDS20,NDS10,NDS_,NDS18,NDS16,Itogo:Real;Var Txt:Text);
Procedure PrintOrderPlategC(SDoc,SDAte,SClient,Summa:AllStr;All:Boolean;l:Word;Var Txt:Text;NDS,NDS20,NDS10,NDS_,NDS18,
NDS16:Real);
Procedure PrintRashodOrder(As : DocumentEditZ);

Procedure CalcNDSP(E:PPrihodType;VidZakupka:Word;Var Zakup,NDS,NDS20,NDS10,NDS_,NDS18,NDS16,Litr,ZakupkaOutNDS,NDSZ,
ZakupkaOutNDS20,ZakupkaOutNDS10,ZakupkaOutNDS_,ZakupkaOutNDS18,ZakupkaOutNDS16,Litr20,Litr10,Litr_,Litr18,Litr16:Real;
Var MMM:Maska5);
Procedure CalcNDS2(FiltrOtdel:Maska8;Sertif:Maska2;E:PSuperMArketType;VidZakupka:Word;Var NDS,NDS20,NDS10,NDS_,NDS18,NDS16,
Litr,ZakupkaOutNDS,NDSZ:Real);
Procedure CalcNDSR2(E:PNewVozwratType;VidZakupka:Word;Var NDS,NDS20,NDS10,NDS_,NDS18,NDS16,Litr,ZakupkaOutNDS,NDSZ:Real);


Implementation


Uses DBEngine,DBEngin2,MsgBox,Views,Propiss,TpDate,Access3,
     Tools,Serv,ServStr2,Utils5,Net,
     NetDBEng,Printers,Objects,Prise,Vision5,UKAssa;


Procedure FormNaklTTNAkzis(Space :TDateString; Video : Boolean;As :DocumentEditZ;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Float;
                            ShowAnswer:Boolean;Zakaz:Boolean;NewSkidka:Boolean;NewSum:Float;VzwTxt:AllStr);
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
    Symbol :ArtikulStr;
    cl : PClientType;
    {Skl : PExtSkladType;}
    SklB : PSkladType;
    BBB,BBBS : PBazType;
    zakaznumer,ZakazDate,ZakazTime : AllStr;
    WithOutZena,SumOut : AllStr;
    SummaOutNDS:AllStr;
    Otsroshka : Word;
    SkKod:ArtikulStr;
    SumAkzis : AllStr;
    Lizens : String[80];
    ItogoAkzis : Float;

Begin

{$IfDEF DPMI}

   ItogoS:=0; ItogoSkidka:=0; Itogo:=0; NdsPos:=0;
   ItogoAkzis:=0;

   SumAkzis[0]:=#0;

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


DInfoMsg('Формирую внутреннюю товарно-транспортную накладную. Ждите...',True);

Writeln(Txt,Header+Space+Dop+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00'+HeaderStop);
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt,Space+Dop+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');

If E^.Dat.OperatorSelector<>2 Then Barter[0]:=#0
Else Barter:='-Б';

DelSpace(E^.DAt.Document);
DelSpace(E^.DAt.DateC);
DelZerro(E^.DAt.Document);
Z:=Rek^.Dat.Kod;
DelZerro(z);

SkKod:=Rek^.DAt.Kod;
Lizens:=GetClientField(FEnvir,SkKod,1);
Writeln(txt,Header+GlobalPrn^.Dat.Condensed[NPrint^.DAt.Printer]+
Space+Dop+'Оптовая лицензия: '+Lizens);
Writeln(txt,Space+Dop+'Грузоотправитель:  Акцизный склад, '+GetClientField(FAdress,SkKod,E^.DAt.OperatorSelector));
SkKod:=E^.DAt.ClientKod;
Writeln(txt,Space+Dop+'Оптовая лицензия: '+GetClientField(FEnvir,SkKod,1));
Lizens:=GetClientField(FEnvir,SkKod,1);
Writeln(txt,Space+Dop+' Грузополучатель:  Оптовый склад N '+IntToStr(StrToInt(SkKod),CMantissa)+', '+
+GEtClientField(FAdress,E^.DAt.ClientKod,E^.DAt.OperatorSelector)+GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);

{вид скидки и версия}
   If E^.Dat.SkidkaSelector=0 Then Ver:=Space+'             '
   Else Ver:=Space+'              ';

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
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
     ZakazTime:=GetZakazDate(E^.DAt.FromZakaz,FieldTime);
     If ZakazTime='' Then ZakazTime:=E^.Dat.TimeC;
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

   Writeln(txt,Space+Dop+GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]+ver);
{конец вид скидки и версия}

If E^.Dat.Oformlenie=1 Then
Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
E^.Dat.Document+barter+'/'+Z+' '+E^.Dat.DateC+' ('+E^.Dat.TimeC+')'+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);


DelSpace(E^.Dat.Document);
Space:='';

If E^.DAt.OperatorSelector in [0,2] Then
Writeln(txt,Space+Dop+'   Н А К Л А Д Н А Я   N     '+
zakaznumer+E^.DAt.Document+barter+VzwTxt+'/'+Z+'  от '+ZakazDate+' ('+ZakazTime+')')
Else
Writeln(txt,Space+'  Н А К Л А Д Н А Я (межскладская перевозка) N '+
zakaznumer+E^.DAt.Document+barter+VzwTxt+'/'+Z+'  от '+ZakazDate+' ('+ZakazTime+')');

Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
'НА ПЕРЕМЕЩЕНИЕ, ПЕРЕДАЧУ ТОВАРОВ С АКЦИЗНОГО СКЛАДА ПРЕДПРИЯТИЯ НА ОПТОВЫЙ СКЛАД ПРЕДПРИЯТИЯ'+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]);
Writeln(txt,GlobalPrn^.Dat.MinInterval2[Nprint^.DAt.Printer]+
             '┌───────────────────────────────┬───────────────────────────────┬───────────────────────┬────────────┐ '+
'                        ┌───────┐');
Writeln(txt,'│      Отправитель              │         Получатель            │Корреспондирующий счет │            │ '+
'                        │ Код   │');
Writeln(txt,'├──────────────┬────────────────┼──────────────┬────────────────┼────────────┬──────────┼────────────┤ '+
'                        ├───────┤');
Writeln(txt,'│ Структурное  │       Вид      │ Структурное  │       Вид      │    Счет,   │Код анали-│            │ '+
'          Форма по ОКУД │0330213│');
Writeln(txt,'│подразделение │  деятельности  │подразделение │  деятельности  │    Субсчет │тич.учета │            │ '+
'                        ├───────┤');
Writeln(txt,'├──────────────┼────────────────┼──────────────┼────────────────┼────────────┼──────────┼────────────┤ '+
'                по ОКПО │       │');

Writeln(txt,'│Акцизный склад│Оптовая торговля│Склад N '+IntToStr(StrToInt(E^.Dat.ClientKod),CMantissa)+
'     │Оптовая торговля│   41:1     │          │            │                         ├───────┤');
{
SkKod:=Rek^.DAt.Kod;
Writeln(txt,'│Склад N '+IntToStr(StrToInt(SKKod),CMantissa)+'     │Оптовая торговля│Склад N '+
IntToStr(StrToInt(E^.Dat.ClientKod),CMantissa)+'     │Оптовая торговля│');
}
Writeln(txt,'└──────────────┴────────────────┴──────────────┴────────────────┴────────────┴──────────┴────────────┘'+
'Вид деятельности по ОКДП │       │');
Writeln(txt,'                                                                                                      '+
'                         ├───────┤');
Writeln(txt,'                                                                                                      '+
'            Вид операции │       │');
Writeln(txt,'                                                                                                      '+
'                         └───────┘');

Writeln(txt,'┌──┬────────────────────────────────┬──────────┬───┬────────┬────────┬─────────┬────────┬──────────┬────────────'+
'┬───┬───────────────────────────────────┐');
Writeln(txt,'│  │Наименование,характеристика     │Единица   │   │        │        │ Масса   │        │  В т.ч.  │            '+
'│   │      Номера                       │');
Writeln(txt,'│N │сорт, артикул товара            │измерения │Фас│Колич,шт│Упаковок│ нетто,кг│Цена,руб│ акциз,руб│ Сумма, руб '+
'│Отд│  акцизных марок                   │');
Writeln(txt,'└──┴────────────────────────────────┴──────────┴───┴────────┴────────┴─────────┴────────┴──────────┴────────────'+
'┴───┴───────────────────────────────────┘'+GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]+HeaderStop);
             {12│12345678901234567890123456│1234567890│123│1234567│123456789│123456789│12345678│1234567890│123456789012}





Space:=' ';

              { 1 12345│12345678901234567890123456│12345│12345678│12345│1234567890123│123456789│123│1234567│}

   c:=0;
   AllMAssa[0]:=#0;
   SummaOutNDS[0]:=#0;
   WordToBit8(c,M);
   For l:=1 To E^.Dat.Amount Do
    Begin
     Str(l:CMantissa,St);
     s:=E^.Dat.MarketElement[l].BazKod;

     {New(Skl,Init);}
     New(SklB,Init);
     New(BBB,Init);
     {Skl^.Dat.BazKod:=E^.Dat.MarketElement[l].BazKod;}
     SklB^.Dat.BazKod:=E^.Dat.MarketElement[l].BazKod;
     {GetExtSkladRecord(Skl);}
     GetSkladRecord(SklB);
     GetBazElement(E^.Dat.MarketElement[l].BazKod,BBB^.Dat);


     If Not(E^.DAt.MarketElement[l].Input.Last) Then
     Separator:=' '   Else Separator:=#249;

     If Nprint^.DAt.FullName=0 Then
     Begin
      ws:=BBB^.Dat.Name{GetIdField(FName,E^.Dat.MarketElement[l].BazKod)};
      ws1:=BBB^.Dat.Name2{GetIdField(FName2,E^.Dat.MarketElement[l].BazKod)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
           Writeln(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+Space+Dop+st+Separator+s+' '+ws);
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
           Writeln(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+Space+Dop+st+Separator+S+' '+ws);
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
     Format(EdIzm,CMera-5);
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

     MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)),CZena,CMantissa,ws);

     Zen:=ws;

     s:=s+Zen;{прибавили цену за единицу товара с учетом скидки}

     MyStr((StrToReal(Zen)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
     ,CInputIZena-1,CMantissa,sum);

     ItogoS:=ItogoS+StrToReal(Sum);

     MyStr((StrToReal(E^.Dat.MarketElement[l].Input.AkzisSbor)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
     ,CZenaZ,CMantissaZ,SumAkzis);

     ItogoAkzis:=ItogoAkzis+StrToReal(SumAkzis);

     s:=s+' '+SumAkzis+' '+Sum;

     {добавили отделение}
     Str(E^.Dat.MarketElement[l].Input.DivisionNumber:2,ws);

     s:=GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+s+' '+ws+
        '                                      '+GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]+
     GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer];


 If DefaultSetMArker=1 Then
 Begin
 If E^.DAt.MarketElement[l].Input.RegionMArka=0 Then s:=s+' '+NoMArker
 Else s:=s+' '+YesMArker;
 End;

      If l=E^.Dat.Amount Then
	  Begin
	   s:=ONLYLINK+s;
       End;



{    If Not(E^.DAt.MarketElement[l].Input.Last) Then
     Writeln(txt,Condensed[Nprint^.DAt.Printer]+Space+Dop+St+Separator+s)
     Else}

     Writeln(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+Space+Dop+St+Separator+s);

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
           Write(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+Space+'    Сертификат: ',
		 GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
           GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')'+
		 GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
           GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
        Else
           Write(txt,Space+'    Сертификат: ',ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')');

      ws1:=BBBS^.Dat.DSertif{GetIDField(FDateSertif,E^.Dat.MarketElement[l].Input.NSertif)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
        If Not(Video) Then
        Begin
        If ws2[0]<>#0 Then
           WriteLn(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+Space+'    Срок дейст: ',
		 GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+ws1+GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
		  GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
        Else
           WriteLn(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+Space+'    Срок дейст: ',
		 GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+ws1+
		  GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
		  GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
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
        Writeln(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+' Выдан: ',
	   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
	   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
                GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+ws2+
             GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
		   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
        Writeln(txt,' Выдан: ',+ws2);
         End
           Else
         Begin
          If Not Video Then
                Writeln(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+Space+'         Выдан: ',
			 GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
			 GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]++
                GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+ws2+
                GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
			 GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
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
       ws1:=GetMarkaField(FMarka,SklB^.Dat.Input.Marka);
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
         Begin
          If Not Video Then
          Write(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+Space+Seria_Akzis^+': ',
		GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
          GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+ws1+
		GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
		GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
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
              WriteLn(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+'Дата выработки: ',
		    GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
         GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+ws2+
	    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
	    GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
           Else
              WriteLn(txt,'Дата выработки: ',ws2);
          End
         Else
          Begin
           If Not Video Then
               WriteLn(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
			Space+'Дата выработки: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
			GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
               GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+ws2+
			GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
			GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
           Else
               WriteLn(txt,Space+'Дата выработки: ',ws2);
          End;
        End
       Else
         if ws1[0]<>#0 Then WriteLn(txt);

       ws2:=SklB^.Dat.Input.Godnost{BakGetField(FGodnost,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);

       DelSpaceRight(ws2);
       If ws2[0]<>#0 Then
         Begin
          If Not Video Then
           WriteLn(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+Space+'Реализовать до: ',
		 GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
           GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+ws2+
		 GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
		 GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
           WriteLn(txt,Space+'Реализовать до: ',
		 GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+ws2);
         End;

      End;{печать акцизных марок и дат розлива}

     If PrintGTD[1]=1 Then
     Begin
       ss:=GetNGTDField(FNGTD,SklB^.Dat.Input.NGTD);
       DelSpaceRight(ss);
       ss1:=GetPostField(FPost,BBB^.Dat.PostKod);
       DelSpaceRight(ss1);
       If (ss[0]<>#0)Or (ss1[0]<>#0) Then
        Begin
         Format(ss,CNSertif);
         If ss[0]<>#0 Then
         Begin
         If Not(Video) Then ss:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
	    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+ss+
		  GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'   '+'      N ГТД: '+ss;
         End
         else ss:=Space+'   ';
         If ss1[0]<>#0 Then
         Begin
         If Not(Video) Then ss1:=GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
	    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+ss1+
		  GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
            GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer];
         If Video Then
            ss:=ss+' Производство: '+ss1
         Else ss:=ss+GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+' Производство: '+ss1;
         End;
         Writeln(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+ss);
        End;
     End;
       End;

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

MyStr(StrToReal(E^.Dat.SummaZ),CIZena,CMantissa,E^.Dat.SummaZ);


Writeln(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
+'───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────'+
'──────────────────────────');

    Writeln(Txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+Space+Dop+'Всего позиций:',E^.Dat.Amount:2,
    '                                    '+'    Мест:'+CalcMesto(E)+'     Всего акциз:',
    RecognizReal(ItogoAkzis,CIZena,CMantissaZ));
    Writeln(Txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+Space+Dop+'Всего по накладной:'+Recogniz(E^.Dat.SummaZ));

    Writeln(txt);

    Writeln(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
    ' Отпустил _____________________________________________________________ товар и тару по количеству и'+
    ' надлежащему качеству на сумму:');

    s:=E^.Dat.SummaZ;
    DelSpace(s);
    Propis(s,ws);
    ws[1]:=UpperCase(ws[1]);
    Writeln(txt);
    ws:=ws+' '+s;
    Format(ws,80);
    Writeln(txt,'   '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+ws+
    GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]);

    Writeln(txt);

    Writeln(txt,GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+'Получил _______________    __________   ___________________'+
    GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]);
    Writeln(txt,
    GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+'           должность         подпись    расшифровка подписи'+
    GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]);


writeln(txt,GlobalPrn^.Dat.NoCondenSed[Nprint^.DAt.Printer]);



   Write(txt,GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);
   Writeln(Txt,Space,'{'+RecognizReal(ItogoSkidka,CIZena,CMantissa)+'}');

   Write(txt,Space{+' Всего: '},' '+RecognizReal(Itogo,CIZena,CMantissa),
    '                         '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

   If E^.Dat.Rashet=2 Then Symbol:='-В'
   Else Symbol:='';

   Writeln(txt,Space+Dop+GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]+''+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+' Тип документа: (',
   LeadingZero(E^.Dat.DocSelector),Symbol+')'+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NODouble[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);

   {отчеркивание заключительное}

Writeln(txt,
GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+Space+
Dop+'============================================================================'+
'=========================='+
'============================================'+
GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]);
If Not(Video) Then NoInfoMsg;
{$ENDIF}
End;





Procedure PrintOrder(E:PSuperMarketType; NDS,NDS20,NDS10,NDS_,NDS18,NDS16,Itogo:Real;Var Txt:Text);
Const Space='      ';
Var s,ws1,ws2 : TMyString;
    Summa : String[CIZena];
    SNDS : String;
    SNDS20,SNDS18,SNDS16,SNDS10,SNDS_,SItog,NP,SClient,SDoc,SDate,SCod : AllStr;
    ZakazNumer,ZakazDate: AllStr;
    ClKods : TDAteString;
Begin
{$IfDEF DPMI}
   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   (* выключенно по причине бухгалтерии 26/03/01*)

{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E^.DAt.FromZakaz;
     DelZerro(ZakazNumer);
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
    End
    Else
     Begin
      ZakazDate:=E^.Dat.DateC;
     End;
End
 Else
  Begin
      ZakazDate:=E^.Dat.DateC;
  End;

DelSpaceRight(RekSF^.Dat.Name);
Format(RekSF^.Dat.Name,CAll);
Format(RekSF^.Dat.SkladsName,CKto);
Format(RekSF^.Dat.Buchgalter,20);
Format(RekSF^.Dat.Kassir,20);

SDate:=E^.Dat.DateC;
SDoc:=E^.Dat.Document+'/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa);
SCod:=IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa);
SClient:=GetClientField(FFullClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(SClient,CAll);
RFormat(SCod,CMantissa);
RFormat(SDoc,CDocNumer+3);
RFormat(SDate,CDate);

MyStr(StrToReal(E^.Dat.SummaZ){Itogo},CInputIZena,CMantissa,S);
MyStr(StrToReal(E^.Dat.SummaZ){Itogo},CInputIZena,CMantissa,SItog);
MyStr(NDS,CInputIZena,CMantissa,SNDS);
MyStr(NDS20,CZena,CMantissa,SNDS20);
MyStr(NDS10,CZena,CMantissa,SNDS10);
MyStr(NDS18,CZena,CMantissa,SNDS18);
MyStr(NDS16,CZena,CMantissa,SNDS16);
MyStr(NDS_,CZena,CMantissa,SNDS_);
DelSpace(s);
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);
ws1[1]:=UpperCase(ws1[1]);
ws2[1]:=UpperCase(ws2[1]);
Format(ws1,41);
Format(ws2,41);

While Pos('.',SItog)>0 Do sitog[Pos('.',SItog)]:='-';
While Pos('.',SNDS)>0 Do snds[Pos('.',Snds)]:='-';
While Pos('.',SNDS20)>0 Do snds20[Pos('.',Snds20)]:='-';
While Pos('.',SNDS10)>0 Do snds10[Pos('.',Snds10)]:='-';
While Pos('.',SNDS18)>0 Do snds18[Pos('.',Snds18)]:='-';
While Pos('.',SNDS16)>0 Do snds16[Pos('.',Snds16)]:='-';
While Pos('.',SNDS_)>0 Do snds_[Pos('.',Snds_)]:='-';


SNDS:='В том числе НДС:';
If Abs(NDS20)>0.009 Then SNDS:=SNDS+'(20%-'+SNDS20+') ';
If Abs(NDS18)>0.009 Then SNDS:=SNDS+'(18%-'+SNDS18+') ';
If Abs(NDS16)>0.009 Then SNDS:=SNDS+'(16%-'+SNDS16+') ';
If Abs(NDS10)>0.009 Then SNDS:=SNDS+'(10%-'+SNDS10+') ';
If Abs(NDS_)>0.009 Then SNDS:=SNDS+'(прочее-'+SNDS_+')';
Del2Space(SNDS);

Format(SNDS,57);

Writeln(txt,NPrint^.Dat.Ini+
GlobalPrn^.Dat.Condensed3[NPrint^.Dat.Printer]+
                  GlobalPrn^.Dat.MinInterval2[NPrint^.Dat.Printer]+Space+
                  '                            Унифицированная форма N КО-1 ││');
Writeln(txt,Space+'                   Утверждена постановлением Госкомстата ││');
Writeln(txt,Space+'                               России от 18.08.98г. N 88 ││');
Writeln(txt,Space+'                                               ┌────────┐││'+RekSF^.Dat.Name);
Writeln(txt,Space+'                                               │ Коды   │││'+RekSF^.Dat.Kod);
Writeln(txt,Space+'                                               ├────────┤││');
Writeln(txt,Space+'                                 Форма по ОКУД │0310001 │││');
Writeln(txt,Space+'                                               ├────────┤││              К В И Т А Н Ц И Я');
Writeln(txt,Space+'                                       по ОКПО │54535565│││        к приходному кассовому ордеру');
Writeln(txt,Space+'                                               └────────┘││            N _____/'+SCod+' от '+SDate);
Writeln(txt,Space+RekSF^.Dat.Name+                             '            ││');
RFormatZerro(E^.DAt.ClientKod,CClientKod);
ClKods:=IntToStr(E^.DAt.OperatorSelector,COne)+E^.DAt.ClientKod;
Writeln(txt,Space+RekSF^.Dat.Kod+'-'+ClKods+'                            ┌────────┬────────┐││');
Writeln(txt,Space+'                                      │ Номер  │Дата    │││');
Writeln(txt,Space+'                                      │докумен.│составл.│││');
Writeln(txt,Space+'                                      ├────────┼────────┤││');
Writeln(txt,Space+'             ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР │_____/'+
                                                              Scod+'│'+SDate+
												              '│││');
Writeln(txt,Space+'                                      └────────┴────────┘││Принято от: '+SClient);
Writeln(txt,Space+'┌────┬───────────────────────────┬─────────────┬────────┐││');
Writeln(txt,Space+'│    │          Кредит           │             │  Код   │││Через: ____________________');
Writeln(txt,Space+'│Деб ├────────┬────────┬─────────┤   Сумма,    │целевого│││');
Writeln(txt,Space+'│ ет │код стр.│кор.счет│код анал.│   руб.коп   │ назнач.│││Основание: за товар');
Writeln(txt,Space+'│    │подразд.│ субсчет│  учета  │             │        │││Сумма:'+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+ws1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
Writeln(txt,Space+'├────┼────────┼────────┼─────────┼─────────────┼────────┤││      '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+ws2+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
Writeln(txt,Space+'│50  │        │  62    │         │'+SItog+    '│        │││'+SNDS{В том числе НДС: '+SNDS});
Writeln(txt,Space+'└────┴────────┴────────┴─────────┴─────────────┴────────┘││');
Writeln(txt,Space+'Принято от:'+SClient                                  +' ││Приложение: накладная N '+SDoc+' от '+SDate);
Writeln(txt,Space+'     Через: ____________________                         ││');
Writeln(txt,Space+'Основание: за товар                                      ││                            '+SDate);
Writeln(txt,Space+'Сумма: '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+ws1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
                                                                  '         ││');
Writeln(txt,Space+'       '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+ws2+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
                                                                 +'         ││ М.П.');
{Writeln(txt,Space+'В том числе НДС: '+SNds+     '                           ││');}
Writeln(txt,Space+SNDS+'││');
Writeln(txt,Space+'                                                         ││');
Writeln(txt,Space+'Приложение: накладная N '+SDoc+' от '+SDate
                                                            +'              ││');
Writeln(txt,Space+'                                                         ││');
Writeln(txt,Space+'Главный бухгалтер: ______________ '+RekSF^.Dat.Buchgalter+
                                                                        '   ││Главный бухгалтер: ______________ '+
														  RekSF^.Dat.Buchgalter);
Writeln(txt,Space+'                                                         ││');
Writeln(txt,Space+'Получил кассир   : ______________ '+RekSF^.Dat.Kassir+
                                                                        '   ││Кассир: ______________ '+RekSF^.Dat.Kassir);
Writeln(txt);
Writeln(txt,Space+'==================================================================================================');

{
└────┴────────┴────────┴─────────┴─────────────┴────────┘
                   В том числе НДС:20%-12345.78 10:-12345.78 прочее-12345.78
В том числе НДС:20%-12345.78 10:-12345.78 прочее-12345.78

                   В т.ч. НДС(20%)12345.78 (10-)-12345.78 (проч.)-12345.78
}
(*
Writeln(txt,Space+'Предприятие:                                       ||');
s:=RekSf^.Dat.Name;
Format(s,CAll-5);
Writeln(txt,Space+s+'  '+E^.Dat.SkladKod+'     || '+S);
Writeln(txt,Space+'                                                   ||');
DelZerro(E^.Dat.Document);
Format(E^.Dat.Document,CDocNumer);
Format(ZakazNumer,CDocNumer+1+1+2);
Format(E^.Dat.DocReal,CDocNumer);

Writeln(txt,Space+Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+'       ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР N '
+E^.Dat.Document+NoDouble[Nprint^.DAt.Printer]+
NoBold[Nprint^.DAt.Printer]+'             ||        '
+Bold[Nprint^.DAt.Printer]+
+Double[Nprint^.DAt.Printer]+' К В И Т А Н Ц И Я'+NoDouble[Nprint^.DAt.Printer]+NoBold[Nprint^.DAt.Printer]);

Writeln(txt,Space+'              от '+E^.Dat.DateC+'                          || к приходному кассовому ордеру N '+
E^.Dat.Document);
Writeln(txt,Space+'                         '     +'                          ||        от '+E^.Dat.DateC);

s:=GetClientField(FFullClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);

DelSpaceRight(s);
Format (s,CClient+15);
Writeln(Txt,Space+'                                                   ||');
Writeln(txt,Space+'    Принято от '+s+' ||  Принято от '+s);

If (E^.Dat.Realiz) Then
Begin
SDoc:=E^.Dat.DocReal;
SDate:=DateToDateString(DateMask,E^.Dat.DocDate);
DelZerro(SDoc);
End
Else
 Begin
  SDoc:=E^.Dat.Document;
  SDate:=E^.Dat.DateC;
  DelZerro(SDoc);
 End;

Writeln(txt,Space+'    Основание: по накладной N '+ZakazNumer+SDoc{E^.Dat.Document}+'         ||  Основание: по накладной N '+
ZakazNumer+SDoc{E^.Dat.Document});
Writeln(txt,Space+'                                                   ||');

s:=E^.Dat.SummaZ;
DelSpace(s);
RFormat(E^.Dat.Summaz,CIZena);
ws1[0]:=#0;
ws2[0]:=#0;
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);
Format(ws1,41);
Ws1[1]:=UpperCase(ws1[1]);
Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+ws1+NoItalic[Nprint^.DAt.Printer]+'          || '+
Italic[Nprint^.DAt.Printer]+ws1+
NoItalic[Nprint^.DAt.Printer]);
If ws2[0]<>#0 Then
Begin
Format(ws2,41);
Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+ws2+NoItalic[Nprint^.DAt.Printer]+'          || '+
Italic[Nprint^.DAt.Printer]+ws2+
NoItalic[Nprint^.DAt.Printer]);
End;
If s[0]<>#0 Then
Begin
Format(s,41);
Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+s+NoItalic[Nprint^.DAt.Printer]+'          || '+Italic[Nprint^.DAt.Printer]+s+
NoItalic[Nprint^.DAt.Printer]);
End;

Writeln(txt,Space+'  '+E^.Dat.SummaZ+' руб.                             ||      '+E^.Dat.SummaZ+' руб.');

MyStr(NDS,CIZena,CMantissa,s);

Writeln(txt,Space+'                                                   ||');
Writeln(txt,Space+'в том числе НДС:'+s+' руб.               || в том числе НДС:'+S+' руб.');
Writeln(Txt,Space+'                                                   ||');
Writeln(txt,Space+'Приложение: накладная N '+ZakazNumer+SDoc+'               ||              '+ZakazNumer+SDoc);
Writeln(txt,Space+'                                                   ||');
Format(RekSF^.DAt.Buchgalter,CKto);
Format(RekSF^.DAt.Kassir,CKto);
Writeln(Txt,Space+' Главный бухгалтер: _________  '+RekSF^.Dat.Buchgalter+'        ||Главный бухгалтер:________'+
RekSF^.Dat.Buchgalter);
Writeln(Txt,Space+'                     Подпись      Расшифр.         ||                   Подпись  Расшифр.');
Writeln(Txt,Space+' Получил кассир:    _________  '+RekSF^.Dat.Kassir+'        ||Кассир:           ________'+
RekSF^.Dat.Kassir);
Writeln(txt,Space+'                     Подпись      Расшифр.         ||                   Подпись  Расшифр.');
Writeln(txt,Space+'============================================================================================');
*)

{$EndIf}
End;



Procedure PrintOrderPlategBak(SDoc,SDAte,SClient,Summa:AllStr;All:Boolean;l:Word;Var Txt:Text;NDS:Real);
Const Space=' ';
Var s,ws1,ws2 : TMyString;
    Symbol:ArtikulStr;
    A : DocumentEditZ;
    E1 : PSuperMArketType;
    ZakazNumer,
    ZakazDAte : TDAteString;

Begin
{$IfDEF DPMI}

A.EditPosition:=SDoc;
A.D:=SDAte;

   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;

New(E1,Init);
If GetMArket1(A,E1) Then
Begin
{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
   If E1^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E1^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';
     ZakazDate:=GetZakazDate(E1^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E1^.Dat.DateC;
    End
    Else
     Begin
      ZakazDate:=E1^.Dat.DateC;
     End;
End
 Else
  Begin
      ZakazDate:=E1^.Dat.DateC;
  End;
End;
Dispose(E1,Done);


Format(ZakazNumer,CDocNumer+1+1+2);

If L in [3,6] Then Symbol:='||'
Else Symbol:='**';

DelZerro(SDoc);

Format(SDoc,CDocNumer);
MyStr(StrToReal(Summa),CIZena,CMantissa,Summa);

Writeln(txt,Space+'Предприятие:                                       '+Symbol);
s:=RekSF^.Dat.Name;
Format(s,CAll-5);
{Writeln(txt,Space+s+' Склад:'+Rek.Kod+'          '+Symbol+' '+S);}

Writeln(txt,Space+s+'  '+RekSF^.Dat.Kod+'     '+Symbol+' '+S);
Writeln(txt,Space+'                                                   '+Symbol);
If L in [6,3] Then
Begin
Writeln(txt,Space+
GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+'НК     ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР N Б/Н '+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+'             '+Symbol+'        '
+
GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+' К В И Т А Н Ц И Я'+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
Writeln(txt,Space+'              от '+FDate+'                          '+Symbol+' к приходному кассовому ордеру N '+
'Б/Н');
Writeln(txt,Space+'                         '     +'                          '+Symbol+'        от '+FDAte);

End
Else
Begin
Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+'НК         КАССОВЫЙ ОРДЕР N Б/Н       '+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+'             '+Symbol+'        '
+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+' К В И Т А Н Ц И Я'+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
Writeln(txt,Space+'              от '+FDate+'                          '+Symbol+' к кассовому ордеру N '+
'Б/Н');
Writeln(txt,Space+'                                                   '+Symbol+'        от '+FDAte);
End;
s:=GetClientField(FFullClient,SClient,0);
DelSpaceRight(s);
Format (s,CClient+15);
Writeln(Txt,Space+'                                                   '+Symbol);
Writeln(txt,Space+'    Принято от '+s+' '+Symbol+'  Принято от '+s);

Writeln(txt,Space+'    Основание: по накладной N '+ZakazNumer+SDoc{E^.Dat.Document}+'         '+
Symbol+'  Основание: по накладной N '+ZakazNumer+SDoc);

Writeln(txt,Space+'                                                   '+Symbol);

s:=Summa;
DelSpace(s);
ws1[0]:=#0;
ws2[0]:=#0;
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);
{Ws1:='1111111111111111111111111111111111111111';}
Format(ws1,41);
Ws1[1]:=UpperCase(ws1[1]);
Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
ws1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+'          '+Symbol+' '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+ws1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
If ws2[0]<>#0 Then
Begin
Format(ws2,41);
Writeln(txt,Space+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+ws2+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+'          '+Symbol+' '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+ws2+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
End;
If s[0]<>#0 Then
Begin
Format(s,41);
Writeln(txt,Space+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+'          '+Symbol+' '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
End;

(*if ((Pharm=1)) Then
s:=' не облагается '
Else  *)
MyStr(NDS,CIZena,CMantissa,s);

Writeln(txt,Space+'         '+Summa+' руб.                      '+Symbol+'      '+Summa+' руб.');
Writeln(txt,Space+'                                                   '+Symbol);
If All And (L in [6,3]) Then
Writeln(txt,Space+'в том числе НДС:'+s+' руб.               '+Symbol+' в том числе НДС:'+S+' руб.');
Writeln(Txt,Space+'                                                   '+Symbol);
Writeln(txt,Space+'Приложение: накладная N '+ZakazNumer+SDoc+'               '+Symbol+'              '+FDate);
Writeln(txt,Space+'                                                   '+Symbol);
Writeln(Txt,Space+' Главный бухгалтер: _________    _________         '+Symbol+' Главный бухгалтер: ________ _________');
Writeln(Txt,Space+'                     Подпись      Расшифр.         '+Symbol+'                     Подпись  Расшифр.');
Writeln(Txt,Space+' Получил кассир:    _________    _________         '+Symbol+' Кассир:            ________ _________');
Writeln(txt,Space+'                     Подпись      Расшифр.         '+Symbol+'                     Подпись  Расшифр. ');
Writeln(txt,Space+'============================================================================================');
{$EndIf}
End;


Procedure PrintOrderPlategC(SDoc,SDAte,SClient,Summa:AllStr;All:Boolean;l:Word;Var Txt:Text;NDS,NDS20,NDS10,NDS_,NDS18,
NDS16:Real);
Const Space=' ';
Var s,ws1,ws2 : TMyString;
    Sym:ArtikulStr;
    A : DocumentEditZ;
    E1 : PSuperMArketType;
    Itogo : Real;
    ZakazNumer,ZakazDAte : TDAteString;
    SItog,NP,SCod : AllStr;
    SNDS : String;
    SNDS20,SNDS10,SNDS18,SNDS16,SNDS_: AllStr;
    ClKods : TDAteString;

Begin


If not(L in [3,4,6,8{это стало после того как отменили векселя}]) Then
 Begin
  PrintOrderPlategBak(SDoc,SDAte,SClient,Summa,All,l,Txt,NDS);
  Exit;
 End;

{это стало после того как отменили векселя т.к. остатки закрываются налом
и нужны приходники}
{if l in [8] then Exit;}


{$IfDEF DPMI}
A.EditPosition:=SDoc;
A.D:=SDAte;

   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;

New(E1,Init);
If GetMArket1(A,E1) Then
Begin
{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
   If E1^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E1^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';
     ZakazDate:=GetZakazDate(E1^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E1^.Dat.DateC;
    End
    Else
     Begin
      ZakazDate:=E1^.Dat.DateC;
     End;
End
 Else
  Begin
      ZakazDate:=E1^.Dat.DateC;
  End;
End;
Dispose(E1,Done);

Format(ZakazNumer,CDocNumer+1+1+2);
Sym:='││';

DelZerro(SDoc);
Format(SDoc,CDocNumer);

DelSpaceRight(RekSF^.Dat.Name);
Format(RekSF^.Dat.Name,CAll);
Format(RekSF^.Dat.SkladsName,CKto);
Format(RekSF^.Dat.Buchgalter,20);
Format(RekSF^.Dat.Kassir,20);

SDate:=SDAte;
SDoc:=SDoc+'/'+IntToStr(StrToInt(RekSf^.Dat.Kod),CMantissa);
SCod:=IntToStr(StrToInt(RekSf^.Dat.Kod),CMantissa);

RFormatZerro(SClient,CClientKod);
ClKods:='0'+SClient;



SClient:=GetClientField(FFullClient,SClient,0);
Format(SClient,CAll);
RFormat(SCod,CMantissa);
RFormat(SDoc,CDocNumer+3);
RFormat(SDate,CDate);

Itogo:=StrToReal(Summa);

MyStr(Itogo,CInputIZena,CMantissa,S);
MyStr(Itogo,CInputIZena,CMantissa,SItog);
MyStr(NDS,CInputIZena,CMantissa,SNDS);
MyStr(NDS20,CZena,CMantissa,SNDS20);
MyStr(NDS18,CZena,CMantissa,SNDS18);
MyStr(NDS16,CZena,CMantissa,SNDS16);
MyStr(NDS10,CZena,CMantissa,SNDS10);
MyStr(NDS_,CZena,CMantissa,SNDS_);


DelSpace(s);
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);
ws1[1]:=UpperCase(ws1[1]);
ws2[1]:=UpperCase(ws2[1]);
Format(ws1,41);
Format(ws2,41);




While Pos('.',SItog)>0 Do sitog[Pos('.',SItog)]:='-';
While Pos('.',SNDS)>0 Do snds[Pos('.',Snds)]:='-';

While Pos('.',SNDS20)>0 Do snds20[Pos('.',Snds20)]:='-';
While Pos('.',SNDS18)>0 Do snds18[Pos('.',Snds18)]:='-';
While Pos('.',SNDS16)>0 Do snds16[Pos('.',Snds16)]:='-';
While Pos('.',SNDS10)>0 Do snds10[Pos('.',Snds10)]:='-';
While Pos('.',SNDS_)>0 Do snds_[Pos('.',Snds_)]:='-';


SNDS:='В том числе НДС:';
If Abs(NDS20)>0.009 Then SNDS:=SNDS+'(20%-'+SNDS20+') ';
If Abs(NDS18)>0.009 Then SNDS:=SNDS+'(18%-'+SNDS18+') ';
If Abs(NDS16)>0.009 Then SNDS:=SNDS+'(16%-'+SNDS16+') ';
If Abs(NDS10)>0.009 Then SNDS:=SNDS+'(10%-'+SNDS10+') ';
If Abs(NDS_)>0.009 Then SNDS:=SNDS+'(прочее-'+SNDS_+')';
Del2Space(SNDS);
Format(SNDS,57);



Writeln(txt,NPrint^.Dat.Ini+GlobalPrn^.Dat.Condensed3[NPrint^.Dat.Printer]+
                  GlobalPrn^.Dat.MinInterval2[NPrint^.Dat.Printer]+Space+
                  '                            Унифицированная форма N КО-1 '+Sym);
Writeln(txt,Space+'                   Утверждена постановлением Госкомстата '+Sym);
Writeln(txt,Space+'                               России от 18.08.98г. N 88 '+Sym);
Writeln(txt,Space+'                                               ┌────────┐'+Sym+RekSF^.Dat.Name);
Writeln(txt,Space+'                                               │ Коды   │'+Sym+RekSF^.Dat.Kod);
Writeln(txt,Space+'                                               ├────────┤'+Sym);
Writeln(txt,Space+'                                 Форма по ОКУД │0310001 │'+Sym);
Writeln(txt,Space+'                                               ├────────┤'+Sym+'              К В И Т А Н Ц И Я');
Writeln(txt,Space+'                                       по ОКПО │54535565│'+Sym+'        к приходному кассовому ордеру');
Writeln(txt,Space+'                                               └────────┘'+Sym+'            N _____/'+SCod+' от '+FDate);
Writeln(txt,Space+RekSF^.Dat.Name+                             '            '+Sym);


Writeln(txt,Space+RekSF^.Dat.Kod+'-'+ClKods+
'                            ┌────────┬────────┐'+Sym);
Writeln(txt,Space+'                                      │ Номер  │Дата    │'+Sym);
Writeln(txt,Space+'                                      │докумен.│составл.│'+Sym);
Writeln(txt,Space+'                                      ├────────┼────────┤'+Sym);
Writeln(txt,Space+'             ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР │_____/'+
                                                              Scod+'│'+FDate+
												              '│'+Sym);

Writeln(txt,Space+'                                      └────────┴────────┘'+Sym+'Принято от: '+SClient);
Writeln(txt,Space+'┌────┬───────────────────────────┬─────────────┬────────┐'+Sym);
Writeln(txt,Space+'│    │          Кредит           │             │  Код   │'+Sym+'Через: ____________________');
Writeln(txt,Space+'│Деб ├────────┬────────┬─────────┤   Сумма,    │целевого│'+Sym);
Writeln(txt,Space+'│ ет │код стр.│кор.счет│код анал.│   руб.коп   │ назнач.│'+Sym+'Основание: за товар');
Writeln(txt,Space+'│    │подразд.│ субсчет│  учета  │             │        │'+Sym+'Сумма:'+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+ws1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
Writeln(txt,Space+'├────┼────────┼────────┼─────────┼─────────────┼────────┤'+Sym+'      '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+ws2+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
Writeln(txt,Space+'│50  │        │  62    │         │'+SItog+    '│        │'+Sym+SNDS{'В том числе НДС: '+SNDS});
Writeln(txt,Space+'└────┴────────┴────────┴─────────┴─────────────┴────────┘'+Sym);
Writeln(txt,Space+'Принято от:'+SClient                                  +' '+Sym+'Приложение: накладная N '+
                                                                                                     SDoc+' от '+SDAte);
Writeln(txt,Space+'     Через: ____________________                         '+Sym);
Writeln(txt,Space+'Основание: за товар                                      '+Sym+'                            '+FDate);
Writeln(txt,Space+'Сумма: '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+ws1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
                                                                  '         '+Sym);
Writeln(txt,Space+'       '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+ws2+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
                                                                 +'         '+Sym+' М.П.');
Writeln(txt,Space+SNDS{'В том числе НДС: '+SNds+     '                           '}+Sym);
Writeln(txt,Space+'                                                         '+Sym);
Writeln(txt,Space+'Приложение: накладная N '+SDoc+' от '+SDate+
                                                             '              '+Sym);
Writeln(txt,Space+'                                                         '+Sym);
Writeln(txt,Space+'Главный бухгалтер: ______________ '+
                                          RekSF^.Dat.Buchgalter+
								                                '   '+Sym+'Главный бухгалтер: ______________ '+
								  RekSF^.Dat.Buchgalter);
Writeln(txt,Space+'                                                         '+Sym);
Writeln(txt,Space+'Получил кассир   : ______________ '+RekSF^.Dat.Kassir+
                                                                        '   '+Sym+'Кассир: ______________ '+
												                                 RekSF^.Dat.Kassir);
Writeln(txt);
Writeln(txt,Space+'==================================================================================================');


(*
Writeln(txt,Space+'Предприятие:                                       '+Symbol);
s:=RekSF^.Dat.Name;
Format(s,CAll-5);
Writeln(txt,Space+s+'  '+RekSF^.Dat.Kod+'     '+Symbol+' '+S);
Writeln(txt,Space+'                                                   '+Symbol);
If L in [6,3] Then
Begin
Writeln(txt,Space+Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+'НК     ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР N Б/Н '+
NoDouble[Nprint^.DAt.Printer]+NoBold[Nprint^.DAt.Printer]+'             '+Symbol+'        '
+Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+' К В И Т А Н Ц И Я'+NoDouble[Nprint^.DAt.Printer]+
NoBold[Nprint^.DAt.Printer]);
Writeln(txt,Space+'              от '+FDate+'                          '+Symbol+' к приходному кассовому ордеру N '+
'Б/Н');
Writeln(txt,Space+'                         '     +'                          '+Symbol+'        от '+FDAte);

End
Else
Begin
Writeln(txt,Space+Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+'НК         КАССОВЫЙ ОРДЕР N Б/Н       '+
NoDouble[Nprint^.DAt.Printer]+NoBold[Nprint^.DAt.Printer]+'             '+Symbol+'        '
+Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+' К В И Т А Н Ц И Я'+NoDouble[Nprint^.DAt.Printer]+
NoBold[Nprint^.DAt.Printer]);
Writeln(txt,Space+'              от '+FDate+'                          '+Symbol+' к кассовому ордеру N '+
'Б/Н');
Writeln(txt,Space+'                                                   '+Symbol+'        от '+FDAte);
End;
s:=GetClientField(FFullClient,SClient,0);
DelSpaceRight(s);
Format (s,CClient+15);
Writeln(Txt,Space+'                                                   '+Symbol);
Writeln(txt,Space+'    Принято от '+s+' '+Symbol+'  Принято от '+s);

Writeln(txt,Space+'    Основание: по накладной N '+ZakazNumer+SDoc{E^.Dat.Document}+'         '+
Symbol+'  Основание: по накладной N '+ZakazNumer+SDoc);

Writeln(txt,Space+'                                                   '+Symbol);

s:=Summa;
DelSpace(s);
ws1[0]:=#0;
ws2[0]:=#0;
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);
Format(ws1,41);
Ws1[1]:=UpperCase(ws1[1]);
Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+ws1+NoItalic[Nprint^.DAt.Printer]+'          '+Symbol+' '+
Italic[Nprint^.DAt.Printer]+ws1+
NoItalic[Nprint^.DAt.Printer]);
If ws2[0]<>#0 Then
Begin
Format(ws2,41);
Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+ws2+NoItalic[Nprint^.DAt.Printer]+'          '+Symbol+' '+
Italic[Nprint^.DAt.Printer]+ws2+NoItalic[Nprint^.DAt.Printer]);
End;
If s[0]<>#0 Then
Begin
Format(s,41);
Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+s+NoItalic[Nprint^.DAt.Printer]+'          '+Symbol+' '+
Italic[Nprint^.DAt.Printer]+s+NoItalic[Nprint^.DAt.Printer]);
End;

MyStr(NDS,CIZena,CMantissa,s);

Writeln(txt,Space+'         '+Summa+' руб.                      '+Symbol+'      '+Summa+' руб.');
Writeln(txt,Space+'                                                   '+Symbol);
If (L in [6,3]) Then
Writeln(txt,Space+'в том числе НДС:'+s+' руб.               '+Symbol+' в том числе НДС:'+S+' руб.');
Writeln(Txt,Space+'                                                   '+Symbol);
Writeln(txt,Space+'Приложение: накладная N '+ZakazNumer+SDoc+'               '+Symbol+'              '+FDate);
Writeln(txt,Space+'                                                   '+Symbol);
Writeln(Txt,Space+' Главный бухгалтер: _________    _________         '+Symbol+' Главный бухгалтер: ________ _________');
Writeln(Txt,Space+'                     Подпись      Расшифр.         '+Symbol+'                     Подпись  Расшифр.');
Writeln(Txt,Space+' Получил кассир:    _________    _________         '+Symbol+' Кассир:            ________ _________');
Writeln(txt,Space+'                     Подпись      Расшифр.         '+Symbol+'                     Подпись  Расшифр. ');
Writeln(txt,Space+'============================================================================================');
*)
{$EndIf}
End;













Procedure PrintRashodOrder(As : DocumentEditZ);
Const Space='        ';
Var s,ws1,ws2 : TMyString;
    Summa : String[CIZena];
    Txt : Text;
    c : Word;
    E : PNewVozwratType;
    f : NewVozwratFileType;
    Find : Boolean;
    A : DocumentEditZ;
    SKod,SDoc,SDAte : AllStr;
    ZakazNumer,ZakazDate : AlLStr;
    E1 : PSuperMArketType;
    ClKods : TDAteString;
Begin
{$IfDEF DPMI}
A:=As;
If MessageBox(^m+#3'Печатать расходный кассовый ордер?',Nil,mfConfirmation+mfOkCancel)=cmCancel Then Exit;
 Assign(F,Path^.Dat.ToReturn+As.D+'.vzw');
 c:=IOResult;
 Reset(f);
 c:=Ioresult;
 If c <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToReturn+As.D+'.vzw',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
  End;

 Assign(Txt,Path^.Dat.ToTemp+'order.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;

 If c <> 0 Then
  Begin
   Close(f);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'order.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


 Find :=False;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
     ReadNewVozwrat(f,E);
  DelSpace(E^.Dat.Document);
  If  StrToInt(E^.Dat.Document)=StrToInt(As.EditPosition) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Dispose(E,Done);
   Close(f);
   c:=IOResult;
   Close(txt);
   c:=IOResult;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
 End;
 Close(f);
 c:=IOResult;

If Not(E^.Dat.Rashod) Then
Begin
 Close(txt);
 c:=IOResult;
 Dispose(E,Done);
 MessageBox(#3^M+#3'По документу возврата не производится выплата клиенту!',Nil,mfError+mfCancelButton);
 Exit;
End;

DelSpaceRight(RekSF^.Dat.Name);
Format(RekSF^.Dat.Name,CAll);
Format(RekSF^.Dat.SkladsName,CKto);
SDate:=E^.Dat.BAsisDate;
SDoc:=E^.Dat.BAsisDoc+'/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa);
SKod:=IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa);
RFormat(SKod,CMantissa);
RFormat(SDoc,CDocNumer+3);
RFormat(SDate,CDate);
MyStr(StrToReal(E^.Dat.RashodSumma),CInputIZena,CMantissa,S);

While Pos('.',s)>0 Do s[Pos('.',s)]:='-';


zakaznumer[0]:=#0;
zakazDate:=E^.Dat.BasisDate;

New(E1,Init);
If GetMArket1(A,E1) Then
Begin
{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
   If E1^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E1^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';
     ZakazDate:=GetZakazDate(E1^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E1^.Dat.DateC;
    End
    Else
     Begin
      ZakazDate:=E1^.Dat.DateC;
     End;
End
 Else
  Begin
      ZakazDate:=E1^.Dat.DateC;
  End;
End;
Dispose(E1,Done);

ClKods:=E^.DAt.MakeKod;
RFormatZerro(ClKods,CClientKod);
ClKods:=IntToStr(E^.DAt.OperatorSelector,COne)+ClKods;

Writeln(txt,Space+NPrint^.Dat.Ini+
GlobalPrn^.Dat.Condensed3[NPrint^.Dat.Printer]+
GlobalPrn^.Dat.MinInterval2[NPrint^.Dat.Printer]+
                  '                             Унифицированная форма № КО-2');
Writeln(txt,Space+'                    Утверждена постановлением Госкомстата');
Writeln(txt,Space+'                                России от 18.08.98 г.№ 88');
Writeln(txt,Space+'                                               ┌────────┐');
Writeln(txt,Space+'                                               │ Коды   │');
Writeln(txt,Space+'                                               ├────────┤');
Writeln(txt,Space+'                                  Форма по ОКУД│0310002 │');
Writeln(txt,Space+'                                               ├────────┤');
Writeln(txt,Space+'                                        по ОКПО│54535565│');
Writeln(txt,Space+RekSf^.Dat.Name+                             '  └────────┘');
Writeln(txt,Space+RekSF^.Dat.Kod+'-'+ClKods+'                             ┌────────┬────────┐');
Writeln(txt,Space+'                                       │Номер   │ Дата   │');
Writeln(txt,Space+'                                       │докум.  │составл.│');
Writeln(txt,Space+'                                       ├────────┼────────┤');
Writeln(txt,Space+'              РАСХОДНЫЙ КАССОВЫЙ ОРДЕР │_____/'+SKod+'│'+E^.Dat.DateC++'│');
Writeln(txt,Space+'                                       └────────┴────────┘'+
GlobalPrn^.Dat.NoCondensed[NPrint^.Dat.Printer]+
                  GlobalPrn^.Dat.Normal[NPrint^.Dat.Printer]);
Writeln(txt,Space+'┌─────────────────────────────┬──────┬─────────────┬────────┐');
Writeln(txt,Space+'│             Дебет           │Кредит│             │  Код   │');
Writeln(txt,Space+'├─┬────────┬────────┬─────────┼──────┤   Сумма,    │целевого│');
Writeln(txt,Space+'│ │код стр │кор.счет│код анал.│      │  руб.коп.   │ назначе│');
Writeln(txt,Space+'│ │подразд.│субсчет │  учета  │      │             │   ния  │');
Writeln(txt,Space+'├─┼────────┼────────┼─────────┼──────┼─────────────┼────────┤');
Writeln(txt,Space+'│ │        │ 62     │         │50    │'+s+        '│        │');
Writeln(txt,Space+'└─┴────────┴────────┴─────────┴──────┴─────────────┴────────┘');
Writeln(txt,Space+'Выдать: '+GetClientField(FFullClient,E^.Dat.MakeKod,E^.Dat.OperatorSelector));
Writeln(txt,Space+' Через: ________________________________');
Writeln(txt,Space+'Основание: Возврат товара по накладной N '+ZakazNumer+E^.Dat.BasisDoc+' от '+E^.Dat.BasisDate);

MyStr(StrToReal(E^.Dat.RashodSumma),CInputIZena,CMantissa,S);
DelSpace(s);
summa:=s;
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);
ws1[1]:=UpperCase(ws1[1]);
ws2[1]:=UpperCase(ws2[1]);

Writeln(txt,Space+'Сумма: '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+ws1+
                           +
					  GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
					  GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
Writeln(txt,Space+'       '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+ws2+
                           +
					  GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
					  GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
Writeln(txt,Space+'Приложение: __________________________________________________');
Writeln(txt,Space+'Руководитель организации:  _______________ '+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+RekSf^.Dat.Director+
                   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
Writeln(txt,Space+'Главный бухгалтер : _______________ '+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+RekSf^.Dat.Buchgalter+
                   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
Writeln(txt,Space+'Получил: '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+ws1+
                              GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
						GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
Writeln(txt,Space+'         '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+ws2+
                              GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
						GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
Writeln(txt,Space+' Дата: ________     Подпись:  ______________');
Writeln(txt);
Writeln(txt,Space+'По документу : _______________________________________________');
Writeln(txt,Space+'              (наименование,номер,дата и место выдачи документа)');

Writeln(txt,Space+'Выдал кассир : ______________ '+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+RekSF^.Dat.Kassir+
                   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+'     "'+
			    DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask));
WriteLN(txt,Space+'==============================================================');
(*
DelZerro(E^.Dat.SkladKod);
Writeln(txt,Space+'Предприятие:'+RekSf^.Dat.Name);
Writeln(txt,Space+Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+
'                   РАСХОДНЫЙ КАССОВЫЙ ОРДЕР N '+'_____ / '+E^.Dat.SkladKod{E^.Dat.Document}+' от '+
E^.Dat.DateC+NoDouble[Nprint^.DAt.Printer]+NoBold[Nprint^.DAt.Printer]);
Writeln(txt);
s:=GetClientField(FFullClient,E^.Dat.MakeKod,E^.Dat.OperatorSelector);
DelSpaceRight(s);

Format(s,CAll);
WriteLN(txt,Space+' Выдать: '+s+'  через: ________________________');


   zakaznumer[0]:=#0;
   zakazDate:=E^.Dat.BasisDate;

New(E1,Init);
If GetMArket1(A,E1) Then
Begin

{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
   If E1^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E1^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';
     ZakazDate:=GetZakazDate(E1^.DAt.FromZakaz,FieldEndDate);
    End
    Else
     Begin
      ZakazDate:=E1^.Dat.DateC;
     End;
End
 Else
  Begin
      ZakazDate:=E1^.Dat.DateC;
  End;
End;
Dispose(E1,Done);


WriteLN(txt,Space+' Основание: возврат товара по документу N '+ZakazNumer+E^.Dat.BasisDoc+' от '+E^.Dat.BasisDate);


If E^.Dat.Opt Then s:=E^.Dat.SummaO
Else s:=E^.Dat.SummaR;

MyStr(StrToReal(E^.Dat.RashodSumma){StrToReal(s)-StrToReal(E^.Dat.Skidka)},CIZena,CMantissa,S);

DelSpace(s);
summa:=s;
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);

ws1:=ws1+ws2;
Ws1[1]:=UpperCase(ws1[1]);
Writeln(txt,Space+' Сумма:   '+Italic[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+ws1+NoDouble[Nprint^.DAt.Printer]
+NoItalic[Nprint^.DAt.Printer]);
If s[0]<>#0 Then
Begin
Format(s,41);
Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+s+NoDouble[Nprint^.DAt.Printer]+
NoItalic[Nprint^.DAt.Printer]);
End;
Writeln(txt,Space+'                    '+Double[Nprint^.DAt.Printer]+Summa+' руб.'+NoDouble[Nprint^.DAt.Printer]);
WriteLN(txt,Space+' Приложение: _____________________________________________________________________________');
WriteLN(txt);
WriteLN(txt,Space+'        Руководитель: ________ ___________   Главный бухгалтер: ________ ___________');
WriteLN(txt,Space+'                       Подпись   Расшифр.                        Подпись   Расшифр.');
WriteLN(txt);
WriteLN(txt,Space+'             "'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+
'  Подпись получателя: ___________________');
WriteLN(txt);

Writeln(txt,Space+' Получил: ________________________________________________________________________________');

WriteLN(txt,Space+' по документу: ___________________________________________________________________________');
WriteLN(txt);
WriteLN(txt,Space+'                            Выдал кассир: _________  '+RekSF^.Dat.Kassir);
WriteLN(txt,Space+'                                           Подпись     Расшифр.');
WriteLN(txt,Space+'==========================================================================================');
*)
c:=IOResult;
Close(txt);
c:=IOResult;
Dispose(E,Done);
Report(Path^.Dat.ToTemp+'order.txt','',NprintC^.DAt.CopyRKO,False,False);
{$EndIf}
End;


Procedure CalcNDS2(FiltrOtdel:Maska8;Sertif:Maska2;E:PSuperMArketType;VidZakupka:Word;Var NDS,NDS20,NDS10,NDS_,NDS18,NDS16,
Litr,ZakupkaOutNDS,NDSZ:Real);
Var l : Word;
    k,j : Byte;
    s,ws,ws1 : String;
    st : String[CMantissa];
    ItogoLitr,PromItogoPos,ItogoPos,ItogoPosZ,NDSPos,NDSPosZ : Real;
    Test : LongInt;
    Wspom,SZakupka,RealZena,ITOGONDS_NP,SummaZena: AllStr;
    ItogNalog,Koefficient,pp : String[CPack];
    BBB : PBazType;

Begin
   NDS:=0;NDSZ:=0; NDSPos:=0; ItogoPos:=0;PromitogoPos:=0;
   NDS20:=0;NDS18:=0;NDS16:=0; NDS10:=0; NDS_:=0;Litr:=0;
   ZakupkaOutNDS:=0;
   Koefficient[0]:=#0;


   New(BBB,Init);

  If Sertif[1]=1 Then
  Begin
   For l:=1 To E^.Dat.Amount Do
    Begin
     If FiltrOtdel[E^.Dat.MarketElement[l].Input.DivisionNumber]=1 Then
    Begin
     GetBazElement(E^.Dat.MarketElement[l].BazKod,BBB^.Dat);
     ItogoLitr:=0;

     StrToInt(E^.Dat.MarketElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=E^.Dat.MarketElement[l].BazKod;

     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(E^.Dat.MarketElement[l].Input.Proz)/100))
       ,CZena,CMantissa,ws){новая цена}
     Else
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-
	  StrToReal(E^.Dat.MarketElement[l].Input.Skidka))
            ,CZena,CMantissa,ws);{новая цена}

       If E^.DAt.DocSelector in [{1,2,3,5,6}100] Then
       Begin
       Mystr(((1+strtoreal(E^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);
       {новая цена}
       MyStr(StrToReal(ws)/StrToReal(Koefficient),CZena,CMantissa,Ws);
       End;

       If VidZakupka=0 Then
       SZakupka:=E^.dat.marketelement[l].Input.Zakupka
       Else
       SZakupka:=E^.dat.marketelement[l].Input.Zakupka2;

{Вычли скидку из цены}
       ItogoPos:=StrToReal(ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);
       ItogoPosZ:=StrToReal(SZakupka)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);
       ItogoLitr:=StrToReal(BBB^.Dat.Litr)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);

       MyStr(ItogoPosZ,CIZena,CMantissaZ,Wspom);

{расчитали сумму Итого в позиции со скидкой}
       NdsPos:={ItogoPos}StrToReal(ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol)*
       StrToReal(E^.Dat.MarketElement[l].Input.NDs)/(100+StrToReal(E^.Dat.MarketElement[l].Input.NDS));

       NdsPosZ:={StrToReal(Wspom){ItogoPosZ}StrToReal(SZakupka)*StrToInt(E^.Dat.MarketElement[l].Input.Kol)*
       StrToReal(E^.Dat.MarketElement[l].Input.NDs)/(100+StrToReal(E^.Dat.MarketElement[l].Input.NDS));

       MyStr(NDSPosZ,CIZena,CMantissaZ,Ws);
       NdsPosZ:=StrToReal(Ws);

       MyStr(NDSPos,CIZena,CMantissa,Ws);
       NdsPos:=StrToReal(Ws);

       Nds:=Nds+NDSPos;
       NdsZ:=NdsZ+NDSPosZ;

       Litr:=Litr+ItogoLitr;


       ZakupkaOutNDS:=ZakupkaOutNDS+ItogoPosZ-NDSPosZ;

       MyStr(ZakupkaOutNDS,CIZena,CMantissaZ,Ws);
       ZakupkaOutNDS:=StrToReal(Ws);


{разборка  НДС по классификации}
       Case E^.Dat.MarketElement[l].Input.VidNDs Of
       0:Nds20:=Nds20+NdsPos;
       1:Nds10:=Nds10+NdsPos;
       2:Nds_:=Nds_+NdsPos;
       3:Nds18:=Nds18+NdsPos;
       4:Nds16:=Nds16+NdsPos;
       Else;
       End;
    End;{FiltrOtdel}
    End;
  End;

  {сертификаты}
  If Sertif[2]=1 Then
  Begin
   For l:=1 To E^.Dat.AmountS Do
    Begin
    If FiltrOtdel[E^.Dat.DocumentElement[l].Input.DivisionNumber]=1 Then
    Begin
     GetBazElement(E^.Dat.DocumentElement[l].BazKod,BBB^.Dat);

     ItogoLitr:=0;

     StrToInt(E^.Dat.DocumentElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=E^.Dat.DocumentElement[l].BazKod;


     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
       MyStr((StrToReal(E^.Dat.DocumentElement[l].Input.Zena)/
       (1+StrToReal(E^.Dat.DocumentElement[l].Input.Proz)/100))
       ,CZena,CMantissa,ws){новая цена}
     Else
       MyStr((StrToReal(E^.Dat.DocumentElement[l].Input.Zena)-
	  StrToReal(E^.Dat.DocumentElement[l].Input.Skidka))
            ,CZena,CMantissa,ws);{новая цена}

       If E^.DAt.DocSelector in [1,2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(E^.dat.DocumentElement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);
       {новая цена}
       MyStr(StrToReal(ws)/StrToReal(Koefficient),CZena,CMantissa,Ws);
       End;

       If VidZakupka=0 Then
       SZakupka:=E^.dat.DocumentElement[l].Input.Zakupka
       Else
       SZakupka:=E^.dat.DocumentElement[l].Input.Zakupka2;

{Вычли скидку из цены}
       ItogoPos:=StrToReal(ws)*StrToInt(E^.Dat.DocumentElement[l].Input.Kol);
       ItogoPosZ:=StrToReal(SZakupka)*StrToInt(E^.Dat.DocumentElement[l].Input.Kol);
       ItogoLitr:=StrToReal(BBB^.Dat.Litr)*StrToInt(E^.Dat.DocumentElement[l].Input.Kol);

{расчитали сумму Итого в позиции со скидкой}
       NdsPos:={ItogoPos}StrToReal(ws)*StrToInt(E^.Dat.DocumentElement[l].Input.Kol)*
       StrToReal(E^.Dat.DocumentElement[l].Input.NDs)/(100+StrToReal(E^.Dat.DocumentElement[l].Input.NDS));

       NdsPosZ:={ItogoPosZ}StrToReal(SZakupka)*StrToInt(E^.Dat.DocumentElement[l].Input.Kol)*
       StrToReal(E^.Dat.DocumentElement[l].Input.NDs)/(100+StrToReal(E^.Dat.DocumentElement[l].Input.NDS));

       MyStr(NDSPos,CIZena,CMantissa,Ws);
       NdsPos:=StrToReal(Ws);

       Nds:=Nds+NDSPos;
       NdsZ:=NdsZ+NDSPosZ;

       Litr:=Litr+ItogoLitr;

       ZakupkaOutNDS:=ZakupkaOutNDS+ItogoPosZ-NDSPosZ;

{разборка  НДС по классификации}
       Case E^.Dat.DocumentElement[l].Input.VidNDs Of
       0:Nds20:=Nds20+NdsPos;
       1:Nds10:=Nds10+NdsPos;
       2:Nds_:=Nds_+NdsPos;
       3:Nds18:=Nds18+NdsPos;
       4:Nds16:=Nds16+NdsPos;
       Else;
       End;
    End;{FiltrOtdel}
    End;
  End;
   Dispose(BBB,Done);
End;




Procedure CalcNDSR2(E:PNewVozwratType;VidZakupka:Word;Var NDS,NDS20,NDS10,NDS_,NDS18,NDS16,
Litr,ZakupkaOutNDS,NDSZ:Real);
Var l : Word;
    k,j : Byte;
    s,ws,ws1 : String;
    st : String[CMantissa];
    ItogoLitr,PromItogoPos,ItogoPos,ItogoPosZ,NDSPos,NDSPosZ : Real;
    Test : LongInt;
    SZakupka,RealZena,ITOGONDS_NP,SummaZena: String[CInputIZena];
    ItogNalog,Koefficient,pp : String[CPack];
    BBB : PBazType;

Begin
   NDS:=0;NDSZ:=0; NDSPos:=0; ItogoPos:=0;PromitogoPos:=0;
   NDS20:=0;NDS18:=0;NDS16:=0; NDS10:=0; NDS_:=0;Litr:=0;
   ZakupkaOutNDS:=0;
   Koefficient[0]:=#0;

   New(BBB,Init);

   For l:=1 To E^.Dat.Amount Do
    Begin
     GetBazElement(E^.Dat.VozwratElement[l].BazKod,BBB^.Dat);

     ItogoLitr:=0;

     StrToInt(E^.Dat.VozwratElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=E^.Dat.VozwratElement[l].BazKod;


     If E^.Dat.VidDocument in [0,2,4] Then{Если автомат}
       MyStr((StrToReal(E^.Dat.VozwratElement[l].Input.Zena)/
       (1+StrToReal(E^.Dat.VozwratElement[l].Input.LocalProz)/100))
       ,CZena,CMantissa,ws){новая цена}
     Else
       MyStr((StrToReal(E^.Dat.VozwratElement[l].Input.Zena)-
	  StrToReal(E^.Dat.VozwratElement[l].Input.LocalSkidka))
            ,CZena,CMantissa,ws);{новая цена}


       If E^.DAt.DocSelector in [{1,2,3,5,6}100] Then
       Begin
       Mystr(((1+strtoreal(E^.dat.Vozwratelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);
       {новая цена}
       MyStr(StrToReal(ws)/StrToReal(Koefficient),CZena,CMantissa,Ws);
       End;

       If VidZakupka=0 Then
       SZakupka:=E^.dat.Vozwratelement[l].Input.Zakupka
       Else
       SZakupka:=E^.dat.Vozwratelement[l].Input.Zakupka2;

{Вычли скидку из цены}
       ItogoPos:=StrToReal(ws)*StrToInt(E^.Dat.VozwratElement[l].Input.Kol);
       ItogoPosZ:=StrToReal(SZakupka)*StrToInt(E^.Dat.VozwratElement[l].Input.Kol);
       ItogoLitr:=StrToReal(BBB^.Dat.Litr)*StrToInt(E^.Dat.VozwratElement[l].Input.Kol);

{расчитали сумму Итого в позиции со скидкой}
       NdsPos:=ItogoPos*
       StrToReal(E^.Dat.VozwratElement[l].Input.NDs)/(100+StrToReal(E^.Dat.VozwratElement[l].Input.NDS));

       NdsPosZ:=ItogoPosZ*
       StrToReal(E^.Dat.VozwratElement[l].Input.NDs)/(100+StrToReal(E^.Dat.VozwratElement[l].Input.NDS));

       MyStr(NDSPos,CIZena,CMantissa,Ws);
       NdsPos:=StrToReal(Ws);

       Nds:=Nds+NDSPos;
       NdsZ:=NdsZ+NDSPosZ;

       Litr:=Litr+ItogoLitr;

       ZakupkaOutNDS:=ZakupkaOutNDS+ItogoPosZ-NDSPosZ;

{разборка  НДС по классификации}
       Case Round(StrToReal(E^.Dat.VozwratElement[l].Input.NDs)) Of
       20:Nds20:=Nds20+NdsPos;
       18:Nds18:=Nds18+NdsPos;
       16:Nds16:=Nds16+NdsPos;
       10:Nds10:=Nds10+NdsPos;
        Else Nds_:=Nds_+NdsPos;;
       End;
    End;

   Dispose(BBB,Done);
End;



Procedure CalcNDSP(E:PPrihodType;VidZakupka:Word;Var Zakup,NDS,NDS20,NDS10,NDS_,NDS18,NDS16,
Litr,ZakupkaOutNDS,NDSZ,ZakupkaOutNDS20,ZakupkaOutNDS10,ZakupkaOutNDS_,
ZakupkaOutNDS18,ZakupkaOutNDS16,Litr20,Litr10,Litr_,Litr18,Litr16:Real;Var MMM:Maska5);

Var l : Word;
    k,j : Byte;
    s,ws,ws1 : String;
    st : String[CMantissa];
    ItogoLitr,PromItogoPos,ItogoPos,ItogoPosZ,NDSPos,NDSPosZ : Real;
    Test : LongInt;
    SZakupka,RealZena,ITOGONDS_NP,SummaZena: String[CInputIZena];
    ItogNalog,Koefficient,pp : String[CPack];
    BBB : PBazType;

Begin
   NDS:=0;NDSZ:=0; NDSPos:=0; ItogoPos:=0;PromitogoPos:=0;
   NDS20:=0;
   NDS18:=0;
   NDS16:=0;
   NDS10:=0; 
   NDS_:=0;
   Litr:=0;
   ZakupkaOutNDS:=0;
   Koefficient[0]:=#0;

   ZakupkaOutNDS20:=0;
   ZakupkaOutNDS10:=0;
   ZakupkaOutNDS_:=0;
   ZakupkaOutNDS18:=0;
   ZakupkaOutNDS16:=0;
   Litr20:=0;
   Litr10:=0;
   Litr_:=0;
   Litr18:=0;
   Litr16:=0;
   MMM[1]:=0;
   MMM[2]:=0;
   MMM[3]:=0;
   MMM[4]:=0;
   MMM[5]:=0;

    If (VidZakupka=0) Then
     Zakup:=StrToReal(E^.dat.SummaZakupka)
    Else
     Zakup:=StrToReal(E^.dat.SummaZakupka2);


   New(BBB,Init);

   For l:=1 To E^.Dat.Amount Do
    Begin
     GetBazElement(E^.Dat.PrihodElement[l].BazKod,BBB^.Dat);

     ItogoLitr:=0;

     StrToInt(E^.Dat.PrihodElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=E^.Dat.PrihodElement[l].BazKod;

       If VidZakupka=0 Then
       SZakupka:=E^.dat.Prihodelement[l].Input.Zakupka
       Else
       SZakupka:=E^.dat.Prihodelement[l].Input.Zakupka2;

       ws:=SZakupka;

{Вычли скидку из цены}
       ItogoPos:=StrToReal(ws)*StrToInt(E^.Dat.PrihodElement[l].Input.Kol);
       ItogoPosZ:=StrToReal(SZakupka)*StrToInt(E^.Dat.PrihodElement[l].Input.Kol);
       ItogoLitr:=StrToReal(BBB^.Dat.Litr)*StrToInt(E^.Dat.PrihodElement[l].Input.Kol);

{расчитали сумму Итого в позиции со скидкой}
       NdsPos:=ItogoPos*
       StrToReal(E^.dat.Prihodelement[l].NDs)/(100+StrToReal(E^.dat.Prihodelement[l].NDs));

       NdsPosZ:=ItogoPosZ*
       StrToReal(E^.dat.Prihodelement[l].NDs)/(100+StrToReal(E^.dat.Prihodelement[l].NDs));

       MyStr(NDSPos,CIZena,CMantissa,Ws);
       NdsPos:=StrToReal(Ws);

       Nds:=Nds+NDSPos;
       NdsZ:=NdsZ+NDSPosZ;

       Litr:=Litr+ItogoLitr;

       ZakupkaOutNDS:=ZakupkaOutNDS+ItogoPosZ-NDSPosZ;

{разборка  НДС по классификации}
       Case E^.dat.Prihodelement[l].VidNDs Of
       0:Begin
           MMM[1]:=1;
	      Nds20:=Nds20+NdsPos;
           Litr20:=Litr20+ItogoLitr;
           ZakupkaOutNDS20:=ZakupkaOutNDS20+ItogoPosZ-NDSPosZ;
         End;
       3:Begin
           MMM[4]:=1;
           Nds18:=Nds18+NdsPos;
           Litr18:=Litr18+ItogoLitr;
           ZakupkaOutNDS18:=ZakupkaOutNDS18+ItogoPosZ-NDSPosZ;
         End;
       4:Begin
           MMM[5]:=1;
           Nds16:=Nds16+NdsPos;
           Litr16:=Litr16+ItogoLitr;
           ZakupkaOutNDS16:=ZakupkaOutNDS16+ItogoPosZ-NDSPosZ;
         End;
       1:Begin
          MMM[2]:=1;
	     Nds10:=Nds10+NdsPos;
          Litr10:=Litr10+ItogoLitr;
          ZakupkaOutNDS10:=ZakupkaOutNDS10+ItogoPosZ-NDSPosZ;
         End;
        Else
	     Begin
           MMM[3]:=1;
		 Nds_:=Nds_+NdsPos;
           Litr_:=Litr_+ItogoLitr;
           ZakupkaOutNDS_:=ZakupkaOutNDS_+ItogoPosZ-NDSPosZ;
          End;
       End;

    End;

   Dispose(BBB,Done);
End;








End.