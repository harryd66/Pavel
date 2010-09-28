{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit Vision12;

Interface

Uses Glob,ServStr,Dialogs,Utils,Vision1;

Procedure FormNaklTTN(Space :TDateString; Video : Boolean;As :DocumentEditZ;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16:Float;
                   ShowAnswer:Boolean;Zakaz:Boolean;NewSkidka:Boolean;NewSum:Float);


Implementation


Uses DBEngine,DBEngin2,MsgBox,Views,Propiss,TpDate,Access3,
     Tools,Serv,ServStr2,Utils5,Net,
     NetDBEng,Printers,Objects,Prise,Vision5,UKAssa;





Procedure FormNaklTTN(Space :TDateString; Video : Boolean;As :DocumentEditZ;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16:Float;
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
    AllKol: TMyString;
    EdIzm: STring[CMera];
    Z,Zen,Sum:String[CIZena];
    Postawshik,GruzoOtpravitel,
    Gruzopolushatel,Platelshik,Podrazdel : String;
    RR: TRect;
    OSD :PBox;
    Rek1 : PRekwiziti;
    Symbol :ArtikulStr;
    cl : PClientType;
    {Skl : PExtSkladType;}
    SklB : PSkladType;
    BBB,BBBS : PBazType;
    zakaznumer,ZakazDate,ZakazTime : AllStr;
    WithOutZena,SumOut : AllStr;
    SummaOutNDS:AllStr;
    Otsroshka : Word;

Procedure WriteNiz;
Begin
Writeln(txt,Condensed2[Nprint^.DAt.Printer]+
Space+Dop+'──────────────────────────────────────────────────────────────────────────────────────────────────────'+
'─────────────────────────────────────────────');

  If E^.DAt.OperatorSelector in [0,2] Then
Begin
    format(AllKol,Ckol+1);
    Writeln(Txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+'Позиций:',E^.Dat.Amount:2,
    '                                                 ',AllMassa,'  ',AllKol,'         ',
    Recogniz({ws}SummaOutNDS),'           ',
    Recogniz(ws2),Double[Nprint^.DAt.Printer]+Condensed2[Nprint^.DAt.Printer]+Recogniz(E^.Dat.SummaZ)+
    NoDouble[Nprint^.DAt.Printer]{+
    '   Мест:'+CalcMesto(E)});
    If (StrToInt(Rek^.Dat.Kod) in [5]) Then
    Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+'    В т.ч.акциз:',RecognizReal(StrToReal(E^.Dat.SummaAkzis),CIZena,
    CMantissa));

If (Video) And (StrToInt(CurrentPassword)=0) Then
   Begin
    Writeln(Txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+'                                   Всего закупка:',
    Recogniz(E^.Dat.SummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka),
    CIZena,CMantissaZ)));
   End;
End
  Else
 Begin
    Writeln(Txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+'Позиций:',E^.Dat.Amount:2,
    '                                                                                  ',Recogniz({ws}SummaOutNDS),'        ',
    Recogniz(ws2),Double[Nprint^.DAt.Printer]+Condensed2[Nprint^.DAt.Printer]+Recogniz(E^.Dat.SummaZ)+
    NoDouble[Nprint^.DAt.Printer]+
    '   Мест:'+CalcMesto(E));
    If (StrToInt(Rek^.Dat.Kod) in [5]) Then
    Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+'    В т.ч.акциз:',RecognizReal(StrToReal(E^.Dat.SummaAkzis),CIZena,
    CMantissa));

If (Video) And (StrToInt(CurrentPassword)=0) And Not(E^.DAt.OperatorSelector=1) Then
   Begin
    Writeln(Txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+'                                         Всего закупка:',
    Recogniz(E^.Dat.SummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SummaZakupka),
    CIZena,CMantissaZ)));
   End;
 End;


    If Not Video Then
    If E^.Dat.DocSelector<>0 Then
      Begin
       Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+'     В т.ч. НДС:',RecognizReal(Nds,CIZena,CMantissa));
       If NDS20>0.009 Then
       Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+Italic[Nprint^.DAt.Printer]+
          Condensed2[Nprint^.DAt.Printer]+'         20%   :'+
          RecognizReal(NDS20,CIZena,CMantissa)+
          NoItalic[Nprint^.DAt.Printer]);

       If NDS18>0.009 Then
       Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+Italic[Nprint^.DAt.Printer]+
          Condensed2[Nprint^.DAt.Printer]+'         18%   :'+
          RecognizReal(NDS18,CIZena,CMantissa)+
          NoItalic[Nprint^.DAt.Printer]);

       If NDS16>0.009 Then
       Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+Italic[Nprint^.DAt.Printer]+
          Condensed2[Nprint^.DAt.Printer]+'         16%   :'+
          RecognizReal(NDS16,CIZena,CMantissa)+
          NoItalic[Nprint^.DAt.Printer]);


       If NDS10>0.009 Then
       Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+Italic[Nprint^.DAt.Printer]+
          Condensed2[Nprint^.DAt.Printer]+'         10%   :'+
          RecognizReal(NDS10,CIZena,CMantissa)+
          NoItalic[Nprint^.DAt.Printer]);

       If NDS_>0.009 Then
       Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+Italic[Nprint^.DAt.Printer]+
          Condensed2[Nprint^.DAt.Printer]+'         прочие:'+
          RecognizReal(NDS_,CIZena,CMantissa)+
          Noitalic[Nprint^.DAt.Printer])
      End;

{$IFDEF Pharm}
{
if ((Pharm=1)) Then
Begin
    If Not Video Then
    Writeln(txt,Condensed[Nprint^.DAt.Printer]+Space+Dop+Italic[Nprint^.DAt.Printer]+
    'НДС не облагается'+NoItalic[Nprint^.DAt.Printer]);
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

    Writeln(txt,Normal[Nprint^.DAt.Printer]);
    Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+'         Товарная накладная имеет приложение '
    +'на ________ листах и содержит '+Pitch[Nprint^.DAt.Printer]+
    Condensed2[Nprint^.DAt.Printer]+ws+NoPitch[Nprint^.DAt.Printer]+Condensed2[Nprint^.DAt.Printer]+
    ' порядковых номеров записей');

    Writeln(txt,NoPitch[Nprint^.DAt.Printer]+
    Condensed2[Nprint^.DAt.Printer]+'                       Масса груза (нетто): '+
    {Pitch[Nprint^.DAt.Printer]+Condensed2[Nprint^.DAt.Printer]+
    ws1+NoPitch[Nprint^.DAt.Printer]+Condensed2[Nprint^.DAt.Printer]}
    '____________________________________________');



    Writeln(txt,{Condensed2[Nprint^.DAt.Printer]+Space+'         Итого наименований: '+Pitch[Nprint^.DAt.Printer]+
    Condensed2[Nprint^.DAt.Printer]+ws+NoPitch[Nprint^.DAt.Printer]+Condensed2[Nprint^.DAt.Printer]+}
    ' Всего мест: '+Pitch[Nprint^.DAt.Printer]+
    Condensed2[Nprint^.DAt.Printer]+ws2+
    NoPitch[Nprint^.DAt.Printer]+
    Condensed2[Nprint^.DAt.Printer]+'       Масса груза (брутто): '+
    Pitch[Nprint^.DAt.Printer]+Condensed2[Nprint^.DAt.Printer]+
    ws1+NoPitch[Nprint^.DAt.Printer]+Condensed2[Nprint^.DAt.Printer]);;

    Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+
    ' Приложение (паспорта, сертификаты) на ____________ листах             '+
    '║  По  доверенности № _________ от  "_____" __________________ г.');



    If E^.Dat.DocSelector in [2,3,4,5,6,7,8] Then
    Begin
    s:=E^.Dat.SummaZ;
    {s:='88888.88';}
    DelSpace(s);
    Propis(s,ws);
    ws[1]:=UpperCase(ws[1]);
    ws:=ws+' '+s;
    Format(ws,71);
    Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+
    'Отпущено на сумму                                                      '+
    '║   выданной _________________________________________________');

    Writeln(txt,Space+Dop+Italic[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+
    +Condensed2[Nprint^.DAt.Printer] +ws+
    '║');

    Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+
    '   Отпуск разрешил ___________________________________________________ '+
    '║');

    Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+
    'Главный (старший) бухгалтер __________________________________________ '+
    '║ Груз принял ________________________________________________');

    Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+
    'Отпуск груза произвел ________________________________________________ '+
    '║ Груз получил грузополучатель _______________________________');

    Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+
    '       М.П.                                                            '+
    '║      М.П. ');

    End;

Dispose(Cl,Done);

   If Not(Video) And (FiktivSkidka=1) And (NewSkidka) Then
    Begin
     ItogoSkidka:=NewSum;
    End;


   Write(txt,NoCondensed[Nprint^.DAt.Printer]);

{$IFNDEF Pharm}
   Writeln(Txt,Space,'{'+RecognizReal(ItogoSkidka,CIZena,CMantissa)+'}');
{$ENDIF}


    If (StrToInt(E^.DAt.AgentKod)<>0)And(E^.Dat.OperatorSelector in[0,2]) Then
     Begin
      s:=GetClientField(FAdressF,E^.DAt.ClientKod,E^.Dat.OperatorSelector);
      DelSpaceRight(s);
      If s[0]<>#0 Then
       Begin
        Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+s
        +NoItalic[Nprint^.DAt.Printer]+NoBold[Nprint^.DAt.Printer]+NoDouble[Nprint^.DAt.Printer]);
       End;
     End;

   Write(txt,Space{+' Всего: '},' '+'               '{+RecognizReal(Itogo,CIZena,CMantissa)},
    '                         '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

   If E^.Dat.Rashet=2 Then Symbol:='-В'
   Else Symbol:='';

   Writeln(txt,Space+Dop+NoCondensed[Nprint^.DAt.Printer]+''+Italic[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+
   Double[Nprint^.DAt.Printer]+' Тип документа: (',
   LeadingZero(E^.Dat.DocSelector),Symbol+')'+NoItalic[Nprint^.DAt.Printer]+
   NODouble[Nprint^.DAt.Printer]);

   {отчеркивание заключительное}

End;


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

   End;

DInfoMsg('Формирую товарно-транспортную накладную. Ждите...',True);

Writeln(txt,Condensed[Nprint^.DAt.Printer]+MinInterval2[Nprint^.DAt.Printer]);
Writeln(txt,Space+Dop+' '+
'Унифицированная форма N ТОРГ - 12');
Writeln(txt,Space+Dop+' '+
'Утверждена постановлением Госкомстата');
Writeln(txt,Space+Dop+' '+
'России от 25.12.98г. N 132');

{Writeln(Txt,OrientAlbom[Nprint^.DAt.Printer]);}
Writeln(txt,Condensed2[Nprint^.DAt.Printer]);;
Writeln(Txt,Space+Dop+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt,Space+Dop+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');

WriteLn(Txt,Space+Dop+'Экспедитор: '+Bold[Nprint^.DAt.Printer]+Italic[Nprint^.DAt.Printer]+
GetEkspedField(FAgent,E^.Dat.EkspeditorKod)+
                           NoItalic[Nprint^.DAt.Printer]+NoBold[Nprint^.DAt.Printer]);


Writeln(txt,Condensed[Nprint^.DAt.Printer]+MinInterval2[Nprint^.DAt.Printer]);

Writeln(txt,Space+Dop+'                                                                                                      '+
'                         ┌──────────┐');
Writeln(txt,Space+Dop+'                                                                                                      '+
'                         │   Код    │');
Writeln(txt,Space+Dop+'                                                                                                      '+
'                         ├──────────┤');
Writeln(txt,Space+Dop+'                                                                                                      '+
'           Форма по ОКУД │ 0345009  │');
Writeln(txt,Space+Dop+'                                                                                                      '+
'                         ├──────────┤');


{вид скидки и версия}
   If E^.Dat.SkidkaSelector=0 Then Ver:=Space+'Скидка: Авто '
   Else Ver:=Space+'Скидка: Ручная';

   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   zakazTime[0]:=#0;


If E^.Dat.OperatorSelector<>2 Then Barter[0]:=#0
Else Barter:='-Б';


{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+{'/'}+'        ';{по просьбе дорофеева и гончарова от 18/11/2003}
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

 (*  Writeln(txt,Space+Dop+NoCondensed[Nprint^.DAt.Printer]+ver);*)
{конец вид скидки и версия}



{в связи с необходимостью печатать СФ для продмаркета}
If (strtoint(Rek^.DAt.Kod) in [4,11]) Then
If E^.Dat.OperatorSelector=1 Then E^.Dat.OperatorSelector:=0;



DelSpace(E^.DAt.Document);
DelSpace(E^.DAt.DateC);
DelZerro(E^.DAt.Document);
Z:=Rek^.Dat.Kod;
DelZerro(z);

{Грузоотправитель}
GruzoOtpravitel:=Rek1^.Dat.NAme+',';
DelSpaceRight(GruzoOtpravitel);
{ws:=GetMAkeField(FClient,Rek1^.Dat.Kod,1);
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+',Склад '+ws+',';}
ws:=Rek1^.Dat.Adress;
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+ws+',';
ws:=Rek1^.Dat.LizensiaOPTL_V;
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+' Лицензия '+ws;
Format(GruzoOtpravitel,116);
GruzoOtpravitel:=GruzoOtpravitel+'   по ОКПО │';
ws:=Rek1^.Dat.Okpo;
DelSpaceRight(ws);
format(ws,10);
GruzoOtpravitel:=GruzoOtpravitel+ws+'│';
{сформировали строку Грузоотправителя}





Writeln(txt,Condensed[Nprint^.DAt.Printer]+
Space+Dop+GruzoOtpravitel);

Writeln(txt,Space+Dop+'                                                                                                      '+
'                         ├──────────┤');

Writeln(txt,Space+Dop+'                                                                                                      '+
'                         │          │');

Writeln(txt,Space+Dop+'                                                                                                      '+
'                         ├──────────┤');

{Структурное подразделение}
Podrazdel:='';
ws:=GetMAkeField(FClient,Rek1^.Dat.Kod,1);
DelSpaceRight(ws);
Podrazdel:=Podrazdel+'Склад '+ws+',';
ws:=Rek1^.Dat.AdressGruza;
DelSpaceRight(ws);
Podrazdel:=Podrazdel+ws{+','};
Format(Podrazdel,75);
Podrazdel:=Podrazdel+'Вид деятельности по ОКДП │          │';
Writeln(txt,Space+Dop+'Структурное подразделение: '+Podrazdel);



{Writeln(txt,Space+Dop+'                                                                                                   '+
'ид деятельности по ОКДП │          │');}

Writeln(txt,Space+Dop+'                                                                                                      '+
'                         ├──────────┤');
{формируем строку Грузополучателя}
New(Cl,Init);
Cl^.Dat.Kod:=E^.Dat.ClientKod;
GetClient(CL,E^.Dat.OperatorSelector);
GruzoPolushatel:=Cl^.Dat.Name{Enviropment{GetClientField(FClient,E^.DAt.ClientKod,E^.DAt.OperatorSelector)};
DelSpaceRight(GruzoPolushatel);
ws:=Cl^.Dat.AdressF;{GetClientField(FAdress,E^.DAt.ClientKod,E^.DAt.OperatorSelector)}
DelSpaceRight(ws);
GruzoPolushatel:=GruzoPolushatel+'('+E^.DAt.ClientKod+')'+','+ws+',';
ws:=Cl^.Dat.Enviropment{GetClientField(FEnvir,E^.DAt.ClientKod,E^.DAt.OperatorSelector)};
DelSpaceRight(ws);
GruzoPolushatel:=GruzoPolushatel+'Лицензия '+ws;
Format(GruzoPolushatel,100);
GruzoPolushatel:=GruzoPolushatel+'  '+'по ОКПО ';
ws:=Cl^.Dat.OKPO{GetClientField(FOKPO,E^.DAt.ClientKod,E^.DAt.OperatorSelector)};
DelSpaceRight(ws);
format(ws,10);
GruzoPolushatel:=GruzoPolushatel+'│'+ws+'│';
{сформировали строку Грузоотправителя}
Writeln(txt,Space+Dop+' Грузополучатель: '+GruzoPolushatel);

Writeln(txt,Space+Dop+'                                                                                                      '+
'                         ├──────────┤');



{формируем строку поставщика}
Postawshik:=Rek1^.Dat.NAme;
DelSpaceRight(Postawshik);
 ws:=Rek1^.Dat.Adress;
DelSpaceRight(ws);
Postawshik:=Postawshik+','+ws;
ws:=Rek1^.Dat.INN;
DelSpaceRight(ws);
Postawshik:=Postawshik+',ИНН '+ws;
Format(Postawshik,100);
Postawshik:=Postawshik+' '+'по ОКПО ';
ws:=Rek1^.Dat.Okpo;
DelSpaceRight(ws);
FORMAT(WS,10);
Postawshik:=Postawshik+'│'+ws+'│';
{сформировали строку поставщика}
Writeln(txt,Space+Dop+'       Поставщик: '+Postawshik);

Writeln(txt,Space+Dop+'                                                                                                      '+
'                         ├──────────┤');

{формируем строку Плательщика}
Platelshik:=Cl^.Dat.FullName{GetClientField(FClient,E^.DAt.ClientKod,E^.DAt.OperatorSelector)};
DelSpaceRight(Platelshik);
ws:=Cl^.Dat.Adress{GetClientField(FAdress,E^.DAt.ClientKod,E^.DAt.OperatorSelector)};
DelSpaceRight(ws);
Platelshik:=Platelshik+'('+E^.DAt.ClientKod+')'+','+ws+',ИНН ';
ws:=Cl^.Dat.INN{GetClientField(FINN,E^.DAt.ClientKod,E^.DAt.OperatorSelector)};
DelSpaceRight(ws);
Platelshik:=Platelshik+ws;
Format(Platelshik,100);
Platelshik:=Platelshik+' '+'по ОКПО ';
ws:=Cl^.Dat.OKPO{GetClientField(FOKPO,E^.DAt.ClientKod,E^.DAt.OperatorSelector)};
DelSpaceRight(ws);
format(ws,10);
Platelshik:=Platelshik+'│'+ws+'│';
{сформировали строку Плательщика}
Writeln(txt,Space+Dop+'      Плательщик: '+Platelshik);

Writeln(txt,Space+Dop+'                                                                                                      '+
'                 ┌───────┼──────────┤');
Writeln(txt,Space+Dop+'       Основание:                                                                                     '+
'                 │ номер │          │');
Writeln(txt,Space+Dop+'                                                                                                      '+
'                 ├───────┼──────────┤');
Writeln(txt,Space+Dop+'                                                                                                      '+
'                 │  дата │          │');
Writeln(txt,Space+Dop+'                                                                                                      '+
'                 ├───────┼──────────┤');
Writeln(txt,Space+Dop+'                                                                                                '+
'Транспортная накладная │ номер │          │');
{┌─────┬────────┐}
Writeln(txt,Space+Dop+'                                               ┌────────────────────┬─────────────────────┐           '+
'                 ├───────┼──────────┤');
{│Номер│  Дата  │}
Writeln(txt,Space+Dop+'                                               │   Номер документа  │ Дата составления    │           '+
'                 │  дата │          │');
{ │докум│составл.│}
Writeln(txt,Space+Dop+'                                               └────────────────────┴─────────────────────┘           '+
'                 └───────┼──────────┤');
{}
zakaznumer:=zakaznumer+E^.DAt.Document+barter+'/'+Z;
format(zakaznumer,20);
format(ZakazDate,CDate);
format(ZakazTime,CDate);
If E^.DAt.OperatorSelector in [0,2] Then
Begin
Write(txt,Header+Space+Dop+'         Т О В А Р Н А Я   Н А К Л А Д Н А Я    '+
zakaznumer+' '+ZakazDate+' ('+ZakazTime+')'+HeaderStop);
End
Else
Begin
Write(txt,Header+Space+Dop+'  ТОВАРНАЯ НАКЛАДНАЯ (межскладская перевозка)   '+
zakaznumer+' '+ZakazDate+' ('+ZakazTime+')'+HeaderStop);
End;

Writeln(txt,'                          Вид операции │          │');
Writeln(txt,Space+Dop+'                                                                                                      '+
'                         └──────────┘');


(* отключено 26/03/01 из-за проблем в бухгалтерии*)

Space:=' ';

Writeln(txt,Header+Condensed2[Nprint^.DAt.Printer]+MinInterval2[Nprint^.DAt.Printer]);
Writeln(txt,Space+Dop+'┌─┬────────────────────────────────┬────────────┬─────┬───────────┬───────┬──────┬────────┬'
+'─────────────┬──────────────────┬────────────┐');
Writeln(txt,Space+Dop+'│ │          Товар                 │Единица изм.│ Вид │Количество │ Масса │Коли- │ Цена,  │'
+'  Сумма      │      НДС         │   Сумма с  │');
Writeln(txt,Space+Dop+'│ ├──────────────────────────┬─────┼───────┬────┤     ├─────┬─────┤       │чество│        │'
+' без учета   ├──────┬───────────┤   учетом   │');
Writeln(txt,Space+Dop+'│N│  Наименование, характе-  │ код │наиме- │код │упак.│одном│мест,│ брутто│(масса│руб.коп.│'
+'   НДС,      │ставка│  сумма,   │    НДС,    │');
Writeln(txt,Space+Dop+'│ │  ристики, сорт, артикул  │     │нование│ по │     │месте│штук │       │нетто)│        │'
+' руб. коп.   │  %   │  руб.коп. │  руб. коп. │');
Writeln(txt,Space+Dop+'│ │                          │     │       │ОКЕЙ│     │     │     │       │      │        │'
+'             │      │           │            │');
Writeln(txt,Space+Dop+'├─┼──────────────────────────┼─────┼───────┼────┼─────┼─────┼─────┼───────┼──────┼────────┼'
+'─────────────┼──────┼───────────┼────────────┤');
Writeln(txt,Space+Dop+'│1│              2           │ 3   │    4  │  5 │  6  │  7  │  8  │   9   │  10  │   11   │'
+'     12      │  13  │    14     │     15     │');
Writeln(txt,Space+Dop+'└─┴──────────────────────────┴─────┴───────┴────┴─────┴─────┴─────┴───────┴──────┴────────┴'
+'─────────────┴──────┴───────────┴────────────┘'+MinInterval[Nprint^.DAt.Printer]+HeaderStop);


   c:=0;
   AllMAssa[0]:=#0;
   AllKol[0]:=#0;
   SummaOutNDS[0]:=#0;
   WordToBit8(c,M);


RR.Assign(0, 0, 0, 0);
OSD := New(PBox, Init(RR, 1, Nil));
OSD^.NewList(New(PTextCollection, Init(0,1)));
{создаем список сопроводительных документов в накладной}
Creat_OSD(E,OSD);


   For l:=1 To E^.Dat.Amount Do
    Begin
     Str(l:CMantissa,St);
     s:='';


     New(SklB,Init);
     New(BBB,Init);
     SklB^.Dat.BazKod:=E^.Dat.MarketElement[l].BazKod;
     GetSkladRecord(SklB);

     {подставляем СД из накладной расхода}
     If MarketSD=0 Then GetOLD_OSD(OSD,SklB);

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
           Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+st+Separator+s+ws);
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
           Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+st+Separator+S+ws);
        Separator:=' ';
        st:='  ';
        ws:=ws1;
        s:='';
       End;
      End;

     {Код товара}
     Format(ws,CName);
     s:=s+ws+' '+E^.Dat.MarketElement[l].BazKod;

     {Ед. изм - наименование}
     EdIzm[0]:=#0;
     EdIzm:=GetMeraField(FName,BBB^.Dat.Mera){GetIdField(FMera,E^.Dat.MarketElement[l].BazKod)};
     rFormat(EdIzm,CMera-8);
     s:=s+' '+EdIzm;

     {Код по ОКЕЙ}
     s:=s+'  -  ';

     {Вид Упак}
     s:=s+'   -  ';



     {Фасовка}
     EdIzm[0]:=#0;
     EdIzm:=BBB^.Dat.InPack{GetIdField(FInPack,E^.Dat.MarketElement[l].BazKod)};
     rFormat(EdIzm,CInPack+2);
     s:=s+' '+EdIzm;

          {Кол-во упак}
     pp:=CalcPackNoFile({E^.Dat.MarketElement[l].BazKod}BBB^.Dat.InPack,E^.Dat.MarketElement[l].Input.Kol);
     DelSpace(pp);
     RFormat(pp,CPack-4);
     s:=s+' '+pp;


     {Маса брутто}
     Massa[0]:=#0;
     Massa:=BBB^.Dat.Massa{GetIdField(FMassa,E^.Dat.MarketElement[l].BazKod)};

     MyStr(StrToInt(E^.Dat.MarketElement[l].Input.Kol)*
              StrToReal(Massa),CMassa+2,CLitrMantissa,Massa);
     rFormat(Massa,CMassa);
     Str(StrToReal(AllMAssa)+StrToReal(Massa):CIZena:CLitrMAntissa,AllMAssa);
     s:=s+' '+MAssa+' ';


     {Кол-во шт}
     DelSpace(E^.Dat.MarketElement[l].Input.Kol);
     ws:=E^.Dat.MarketElement[l].Input.Kol;
     Str(StrToInt(AllKol)+StrToInt(ws):Ckol,AllKol);
     (*ws:='{'+ws+'}';*)
     RFormat(ws,CKol+1);
     s:=s+{' '}+ws;





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

       rformat(Zen,CZena);
       s:=s+' '+Zen;{прибавили цену за единицу товара с учетом скидки}

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

       rformat(ws1,CIZena-2);
       s:=s+' '+ws1;

       ws2:=E^.Dat.MarketElement[l].Input.NDS;
       MyStr(StrToReal(ws2),CLitr+1,CMantissa,ws2);
       rformat(ws2,CLitr+1);
       s:=s+' '+ws2;{ставка ндс}
       rformat(ws,CIZena-4);
       s:=s+' '+ws;{сумма ндс в позиции}
       ws[0]:=#0;


       rformat(Sum,CIZena-3);
       rformat(TempZakupka,CIZena-3);
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


     s:=Pitch[Nprint^.DAt.Printer]+Condensed2[Nprint^.DAt.Printer]++s+' '+ws+NoPitch[Nprint^.DAt.Printer]+
     Condensed2[Nprint^.DAt.Printer];


 If DefaultSetMArker=1 Then
 Begin
 If E^.DAt.MarketElement[l].Input.RegionMArka=0 Then s:=s+' '+NoMArker
 Else s:=s+' '+YesMArker;
 End;


     If l=E^.Dat.Amount Then s:=ONLYLINK+s;

     Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+Dop+St+Separator+s);




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
           Write(txt,Condensed2[Nprint^.DAt.Printer]+Space+' Сертификат: ',Italic[Nprint^.DAt.Printer]+
                 Double[Nprint^.DAt.Printer]+
           Condensed2[Nprint^.DAt.Printer]+ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')'+NoDouble[Nprint^.DAt.Printer]+
           NoItalic[Nprint^.DAt.Printer])
        Else
           Write(txt,Condensed2[Nprint^.DAt.Printer]+Space+' Сертификат: ',ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')');

      ws1:=BBBS^.Dat.DSertif{GetIDField(FDateSertif,E^.Dat.MarketElement[l].Input.NSertif)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
        If Not(Video) Then
        Begin
         If ws2[0]<>#0 Then
            WriteLn(txt,Condensed2[Nprint^.DAt.Printer]+Space+' Срок дейст: ',Italic[Nprint^.DAt.Printer]+
                  Double[Nprint^.DAt.Printer]+
            Condensed2[Nprint^.DAt.Printer]+ws1+NoDouble[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer]+' ')
         Else
            WriteLn(txt,Condensed2[Nprint^.DAt.Printer]+Space+'   Срок дейст: ',Italic[Nprint^.DAt.Printer]+
                  Double[Nprint^.DAt.Printer]+
            Condensed2[Nprint^.DAt.Printer]+ws1+NoDouble[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer]+' ')
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



     If PrintExpert[2]=1 Then
     If
     {$IFNDEF Pharm}
	(E^.Dat.MarketElement[l].Input.RegionMarka=1) and
     {$ENDIF}
	(SklB^.Dat.Input.Expert<>NoExpertStr) Then
     Begin
       ss:=GetExpertField(FExpert,SklB^.Dat.Input.Expert);
       DelSpaceRight(ss);
       ss:=ss+' ('+SklB^.Dat.Input.Expert+')';
       If Not(Video) Then ss:=Italic[Nprint^.DAt.Printer]+Bold[Nprint^.DAt.Printer]+ss+
            NoBold[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'   '+Expert_RegNom^+': '+ss;
         Writeln(txt,Condensed2[Nprint^.DAt.Printer]+ss);
     End;



     If PrintAkzisDate[2]=1 Then
      Begin
       ws1[0]:=#0;
       If (SklB^.Dat.Input.Marka<>NoMarkaStr) Then
       Begin
       ws1:=GetMarkaField(FMarka,SklB^.Dat.Input.Marka);
       DelSpaceRight(ws1);
       If (ws1[0]<>#0) Then
         Begin
          ws1:=ws1+' ('+SklB^.Dat.Input.Marka+')';
          If Not Video Then
          Write(txt,Condensed2[Nprint^.DAt.Printer]+Space+Seria_Akzis^+': ',Italic[Nprint^.DAt.Printer]+
          Double[Nprint^.DAt.Printer]+
          Condensed2[Nprint^.DAt.Printer]+ws1+NoDouble[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer]+' ')
          Else
          Write(txt,Space+Seria_Akzis^+': ',ws1+' ')
         End;
       End;
       ws2:=SklB^.Dat.Input.Virabotano{BakGetField(FVirabotano,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);

       If ws2[0]<>#0 Then
        Begin
         If ws1[0]<>#0 Then
          Begin
           If Not Video Then
             WriteLn(txt,Condensed2[Nprint^.DAt.Printer]+'Дата выработки: ',Italic[Nprint^.DAt.Printer]+
                   Double[Nprint^.DAt.Printer]+
             Condensed2[Nprint^.DAt.Printer]+ws2+NoDouble[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer])
           Else
              WriteLn(txt,'Дата выработки: ',ws2);
          End
         Else
          Begin
           If Not Video Then
               WriteLn(txt,Condensed2[Nprint^.DAt.Printer]+Space+'Дата выработки: ',Italic[Nprint^.DAt.Printer]+
                        Double[Nprint^.DAt.Printer]+
               Condensed2[Nprint^.DAt.Printer]+ws2+NoDouble[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer])
           Else
               WriteLn(txt,Space+'Дата выработки: ',ws2);
          End;
        End
       Else
         if ws1[0]<>#0 Then WriteLn(txt,Condensed2[Nprint^.DAt.Printer]);

       ws2:=SklB^.Dat.Input.Godnost{BakGetField(FGodnost,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);
       If ws2[0]<>#0 Then
         Begin
          If Not Video Then
           WriteLn(txt,Condensed2[Nprint^.DAt.Printer]+Space+'Реализовать до: ',Italic[Nprint^.DAt.Printer]+
                 Double[Nprint^.DAt.Printer]+
           Condensed2[Nprint^.DAt.Printer]+ws2+NoDouble[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer])
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
           Write(txt,Condensed2[Nprint^.DAt.Printer]+Space+'    Сертификат: ',Italic[Nprint^.DAt.Printer]+
                 Double[Nprint^.DAt.Printer]+
           Condensed2[Nprint^.DAt.Printer]+ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')'+NoDouble[Nprint^.DAt.Printer]+
           NoItalic[Nprint^.DAt.Printer])
        Else
           Write(txt,Space+'    Сертификат: ',ws2+' ('+E^.Dat.MarketElement[l].Input.NSertif+')');

      ws1:=BBBS^.Dat.DSertif{GetIDField(FDateSertif,E^.Dat.MarketElement[l].Input.NSertif)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
        If Not(Video) Then
        Begin
        If ws2[0]<>#0 Then
           WriteLn(txt,Condensed2[Nprint^.DAt.Printer]+Space+'    Срок дейст: ',Italic[Nprint^.DAt.Printer]+
                 Double[Nprint^.DAt.Printer]+
            Condensed2[Nprint^.DAt.Printer]+ws1+NoDouble[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer]+' ')
        Else
           WriteLn(txt,Condensed2[Nprint^.DAt.Printer]+Space+'    Срок дейст: ',Italic[Nprint^.DAt.Printer]+
                 Double[Nprint^.DAt.Printer]+
            Condensed2[Nprint^.DAt.Printer]+ws1+NoDouble[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer]+' ')
        End
        Else
           WriteLn(txt,Space+'    Срок дейст: ',+ws1+' ')
          End
        Else If ws2[0]<>#0 Then Writeln(txt);

     If BBBS^.Dat.KSertif<>NoOrganStr Then
     Begin
      ws2:=GetKSertifField(FKSertif,BBBS^.Dat.KSertif){GetIDField(FKtoSertif,E^.Dat.MarketElement[l].Input.NSertif)};
      DelSpaceRight(ws2);
      If ws2[0]<>#0 Then
       Begin
           If ws1[0]<>#0 Then
         Begin
          ws2:=ws2+' ('+BBBS^.Dat.KSertif+')';
          If Not Video Then
        Writeln(txt,Condensed2[Nprint^.DAt.Printer]+' Выдан: ',Italic[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+
                Condensed2[Nprint^.DAt.Printer]+ws2+
             NoDouble[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer])
          Else
        Writeln(txt,' Выдан: ',+ws2);
         End
           Else
         Begin
          ws2:=ws2+' ('+BBBS^.Dat.KSertif+')';
          If Not Video Then
                Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+'         Выдан: ',Italic[Nprint^.DAt.Printer]+
                         Double[Nprint^.DAt.Printer]++
                Condensed2[Nprint^.DAt.Printer]+ws2+
                       NoDouble[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer])
          Else
                Writeln(txt,Space+'         Выдан: ',+ws2);
         End;
       End
      Else  If ws1[0]<>#0 Then Writeln(txt);
     End;
Dispose(BBBS,Done);
      End;{сертификаты}
      End;


     If PrintAkzisDate[1]=1 Then
      Begin
       ws1[0]:=#0;
       If SklB^.Dat.Input.Marka<>NoMarkaStr Then
       Begin
       ws1:=GetMarkaField(FMarka,SklB^.Dat.Input.Marka);
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
         Begin
          ws1:=ws1+' ('+SklB^.Dat.Input.Marka+')';
          If Not Video Then
          Write(txt,Condensed2[Nprint^.DAt.Printer]+Space+Seria_Akzis^+': ',Italic[Nprint^.DAt.Printer]+
                Double[Nprint^.DAt.Printer]+
          Condensed2[Nprint^.DAt.Printer]+ws1+NoDouble[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer]+' ')
          Else
          Write(txt,Space+Seria_Akzis^+': ',ws1+' ')
         End;
       End;
       ws2:=SklB^.Dat.Input.Virabotano{BakGetField(FVirabotano,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);

       If ws2[0]<>#0 Then
        Begin
         If ws1[0]<>#0 Then
          Begin
           If Not Video Then
              WriteLn(txt,Condensed2[Nprint^.DAt.Printer]+'Дата выработки: ',Italic[Nprint^.DAt.Printer]+
                    Double[Nprint^.DAt.Printer]+
         Condensed2[Nprint^.DAt.Printer]+ws2+NoDouble[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer])
           Else
              WriteLn(txt,'Дата выработки: ',ws2);
          End
         Else
          Begin
           If Not Video Then
               WriteLn(txt,Condensed2[Nprint^.DAt.Printer]+Space+'Дата выработки: ',Italic[Nprint^.DAt.Printer]+
                        Double[Nprint^.DAt.Printer]+
               Condensed2[Nprint^.DAt.Printer]+ws2+NoDouble[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer])
           Else
               WriteLn(txt,Space+'Дата выработки: ',ws2);
          End;
        End
       Else
         if ws1[0]<>#0 Then WriteLn(txt);

       ws2:=SklB^.Dat.Input.Godnost{BakGetField(FGodnost,E^.Dat.MarketElement[l].BazKod,0)};
       DelSpaceRight(ws2);

       If ws2[0]<>#0 Then
         Begin
          If Not Video Then
           WriteLn(txt,Condensed2[Nprint^.DAt.Printer]+Space+'Реализовать до: ',Italic[Nprint^.DAt.Printer]+
                 Double[Nprint^.DAt.Printer]+
           Condensed2[Nprint^.DAt.Printer]+ws2+NoDouble[Nprint^.DAt.Printer]+NoItalic[Nprint^.DAt.Printer])
          Else
           WriteLn(txt,Space+'Реализовать до: ',Condensed2[Nprint^.DAt.Printer]+ws2);
         End;

      End;{печать акцизных марок и дат розлива}

     If PrintGTD[1]=1 Then
     Begin
       ss[0]:=#0;
       ss1[0]:=#0;
       If SklB^.Dat.Input.NGTD<>NoNGTDStr Then
       Begin
       ss:=GetNGTDField(FNGTD,SklB^.Dat.Input.NGTD);
       DelSpaceRight(ss);
       End;
       If BBB^.Dat.PostKod<>NoPostStr Then
       Begin
       ss1:=GetPostField(FPost,BBB^.Dat.PostKod);
       DelSpaceRight(ss1);
       End;

       If (ss[0]<>#0)Or (ss1[0]<>#0) Then
        Begin
         {Format(ss,CNSertif);}
         If ss[0]<>#0 Then
         Begin
         ss:=ss+' ('+SklB^.Dat.Input.NGTD+')';
         If Not(Video) Then ss:=Italic[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+
            Condensed2[Nprint^.DAt.Printer]+ss+NoDouble[Nprint^.DAt.Printer]+
            NoItalic[Nprint^.DAt.Printer];
         ss:=Space+'   '+'      N ГТД: '+ss;
         End
         else ss:=Space+'   ';
         If ss1[0]<>#0 Then
         Begin
         ss1:=ss1+' ('+BBB^.Dat.PostKod+')';
         If Not(Video) Then ss1:=Italic[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+
            Condensed2[Nprint^.DAt.Printer]+ss1+NoDouble[Nprint^.DAt.Printer]+
            NoItalic[Nprint^.DAt.Printer];
         If Video Then
            ss:=ss+' Производство: '+ss1
         Else ss:=ss+Condensed2[Nprint^.DAt.Printer]+' Производство: '+ss1;
         End;
         Writeln(txt,Condensed2[Nprint^.DAt.Printer]+ss);
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
{    If Video Then Writeln(txt,Space+'______________________________________________________________________________');}
MyStr(StrToReal(E^.Dat.SummaZ),CIZena,CMantissa,E^.Dat.SummaZ);
MyStr(StrToReal(E^.Dat.SummaZakupka),CIZena,CMantissaZ,E^.Dat.SummaZakupka);
{DelSpace(E^.Dat.SummaZ);}

    MyStr(StrToReal(E^.Dat.SummaZ)-NDS,CIZena-2,CMAntissa,ws);
    MyStr(StrToReal(E^.Dat.SummaZ),CIZena-2,CMAntissa,E^.Dat.SummaZ);
    MyStr(NDS,CZena,CMAntissa,ws2);

    MyStr(StrToReal(SummaOutNDS),CIZena-2,CMAntissa,SummaOutNDS);

    WriteNiz;

Writeln(txt,Condensed2[Nprint^.DAt.Printer]+Space+
Dop+'============================================================================'+
'=========================='+
'============================================'+NoCondensed[Nprint^.DAt.Printer]);

Dispose(OSD,Done);

If Not(Video) Then NoInfoMsg;

{$ENDIF}
Dispose(Rek1,Done);
End;

