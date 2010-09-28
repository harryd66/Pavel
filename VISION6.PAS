{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit Vision6;

Interface

Uses Glob,Dialogs,ServStr,Serv,Vision1,Utils;

Procedure FormNaklSertif(Space :TDateString; Video : Boolean;As :DocumentEditZ;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Float;
                                 ShowAnswer:Boolean;Zakaz:Boolean);

Procedure FormPamatka(Space :TDateString;
                         Video :Boolean;
                                   Const E :PSuperMarketType;
                       Var Txt :Text;Zakaz:Boolean);


Procedure PrintNaklSertif (Space :TDateString; Video : Boolean;As :DocumentEditZ;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Float;
                                 ShowAnswer:Boolean;CopyNkl:Byte;Zakaz:Boolean;MMM:Maska55;NPrintCC:PNewPrintCopy);

Function  TestFormPril(E:PSuperMarketType):Boolean;
Function  TestRazdelA (E:PSuperMarketType):Boolean;

Procedure FormPril( E:PSuperMarketType;Var Txt:Text;Zakaz:Boolean);
Procedure FormRazdelA(E:PSuperMarketType;Var Txt:Text;Zakaz:Boolean);

Function  TestElementSpis(Const S : ArtikulStr;Const P : PBox;Const Sort:Word) : Boolean;
Procedure Test_Srok(Const Spis:PBox;Const M:Maska8;Const Assort,Sort:Word);
Function AutoAnswer(s:String):Boolean;

Procedure ShowPhoto(Art:ArtikulStr);
Procedure PrintNewGTD;


Implementation


Uses DBEngine,MsgBox,Views,Propiss,TpDate,Access,Tools,Utils5,
     Memory,Dos,DbEngin2,ServStr2,DBIII,
     Drivers,NetDBEng,Printers,Objects,Prise,Vision5,App,Utils4;
{Const ReadOnly=0;}

VAr LocalTempBox,TempBox : PBox;
    OldFileMode : Word;


Function AutoAnswer(s:String):Boolean;
Begin
AutoAnswer:=False;
If (NPrintC^.Dat.AutoPrintRashod=1) Or FindParam('/AUTOPRINTRASHOD') Then
 Begin
  AutoAnswer:=True;
  Exit;
 End;
If MessageBox(s,Nil,mfConfirmation+mfOkCancel)=CmOk Then AutoAnswer:=True;
End;




Procedure FormNaklSertif(Space : TDateString;
                         Video : Boolean;
                                           As : DocumentEditZ;
                                   Const E : PSuperMarketType;
                       Var Txt : Text;
                       Var NDS,
                                   Itogo,
                                   ItogoSkidka,
                                   NDS20,
                                   NDS10,
                                   NDS_    : Float;
                                 ShowAnswer: Boolean;
                                      Zakaz: Boolean);
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
    Nalog:TDateString;
    tempSkidka,tt1,tt2,WspomSkidka,OutputSklad,InputSklad,koefficient:ALLStr;
    DrawSkidka:Boolean;
    BarterS : String[CMantissa];
    TempZakupka : AllStr;
    Separator : AllStr;
    Printing: Boolean;
    BBBS : PBazType;
    Skl  : PSkladType;
    ZakazNumer,
    ZakazDate,
    ZakazTime : AllStr;

Begin
Dop[0]:=#0;

If Not(Video) Then DInfoMsg('Формирую документ на отпуск сертификатов. Ждите...',True);



   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   zakazTime[0]:=#0;

If Not Zakaz Then
Begin
   (* отключено из-за проблем с бухгалтерией 26/03/01*)
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
End
Else
    Begin

     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer;
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldDate);
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
     ZakazTime:=GetZakazDate(E^.DAt.FromZakaz,FieldTime);
     If ZakazTime='' Then ZakazTime:=E^.Dat.TimeC;

    End;




If E^.Dat.DocSelector<>0 Then{если не список}
Begin
Writeln(Txt,Space+(*'Склад: ',{E^.Dat.Sklad+}E^.Dat.SkladKod+*)
                  'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
End
Else
Begin
If E^.Dat.OperatorSelector<>0 Then
Begin
Writeln(Txt,Space+(*'Склад: ',{E^.Dat.Sklad}E^.Dat.SkladKod+*)
                  'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
End
 Else Begin
        Writeln(txt);
      End;
End;


If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt,Space{+'Последние изменения:'}+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');

If E^.Dat.OperatorSelector<>2 Then BarterS[0]:=#0
Else BarterS:='-Б';

DelSpace(E^.DAt.Document);
DelSpace(As.EditPosition);
DelSpace(E^.DAt.DateC);
DelSpace(E^.DAt.TimeC);

If Video Then
Writeln(txt,Space+Dop+'Тип документа:(',LeadingZero(E^.Dat.DocSelector){,'-С)'});

If Not(Zakaz) Then
Begin
If E^.DAt.OperatorSelector in [0,2] Then
 Begin
        Writeln(Txt,Space+'        Д О К У М Е Н Т  расхода сертификатов  N '+ZakazNumer+E^.Dat.Document+'-С'+BArterS+
        '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+' от ',ZakazDAte{E^.Dat.DAteC}+' ('+ZakazTime{E^.Dat.TimeC}+')');
 End
Else
 Begin
        Writeln(Txt,Space+'   Н А К Л А Д Н А Я (межскладская перевозка сертификатов)  N '+ZakazNumer+
           E^.Dat.Document+'-С'+BArterS+
        '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+' от ',ZakazDate{E^.Dat.DAteC}+' ('+ZakazTime{E^.Dat.TimeC}+')');
 End;
End
Else
  Begin
        Writeln(Txt,Space+'   З А Г Р У З О Ч Н Ы Й   л и с т (сертификаты)  N '+ZakazNumer+'-С'+BArterS+
        '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+' от '+ZakazDate{E^.Dat.DAteC}+' ('+ZakazTime{E^.Dat.TimeC}+')');
  End;



        ItogoS:=0;ItogoSkidka:=0;Itogo:=0;{ NDS:=0;} NdsPos:=0;

        If E^.Dat.OperatorSelector in [0,2] Then Local:=False
        Else Local:=True;

 DelSpace(E^.Dat.Document);
 If (E^.Dat.DocSelector=1) Then
 Writeln(Txt,Space+Dop+'Поставщик: '+Rek^.Dat.Name)
 Else
 If E^.Dat.OperatorSelector in [0,2] Then
 Writeln(Txt,Space+Dop+'Поставщик: '+RekSF^.Dat.Name)
 Else
 Writeln(Txt,Space+Dop+'Поставщик: '+GetMakeField(FFullClient,Rek^.Dat.Kod,1));

 Writeln(Txt,Space+Dop+'Получатель: ',GetClientField(FFullClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
 E^.Dat.ClientKod+')');


        For l:=1 To E^.Dat.AmountS Do
        Begin
        MyStr(StrToReal(E^.Dat.DocumentElement[l].Input.Zena)*StrToInt(E^.Dat.DocumentElement[l].Input.Kol)
        ,CIZena,CMantissa,ws);
        Itogo:=Itogo+StrToReal(Ws);
        End;

        If E^.Dat.SkidkaSelector=0 Then Ver:=Space+'Скидка: Авто '
        Else Ver:=Space+'Скидка: Ручная';

        If (E^.Dat.Versia>1) Then
         Begin
          Ver:=Ver+'                                                             Версия: '+
                IntToStr(E^.Dat.Versia,CLitrMantissa);
         End;

        Writeln(txt,ver);


   If Not Zakaz Then
   If E^.Dat.Oformlenie=1 Then
    Begin
     (* Отключено из-за проблем с бухгалтерией 26/03/01*)
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer+'/';

     If Video Then
     Writeln(txt,Space+Dop+'По заказу N '+E^.DAt.FromZakaz)
     Else
     Writeln(txt,Space+Dop+
       GlobalPrn^.Dat.Italic[NPrint^.Dat.Printer]+'По заказу N '+E^.DAt.FromZakaz+
        +GlobalPrn^.Dat.NoItalic[NPrint^.Dat.Printer]);
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


If Not(Zakaz) Then
Begin
 If (E^.Dat.OperatorSelector in [0,2]) Then
 Begin
        Writeln(txt,Space+Dop+'┌──────────────────────────────────────────────────────────────────────────────────┐');
        Writeln(txt,Space+Dop+'│N  Код  Сертификат                 Колич     Цена Итого сумма  Упаковок Отд Примеч│');
        Writeln(txt,Space+Dop+'└──────────────────────────────────────────────────────────────────────────────────┘');
                              {12│12345│12345678901234567890123456│12345│12345678│12345678901│123456789│123│1234567}
 End
  Else
  Begin
        Writeln(txt,Space+Dop+'┌────────────────────────────────────────────────────────────────────────────────────────┐');
{$IFNDEF TABAK}
        Writeln(txt,Space+Dop+'│N  Код  Сертификат                 Колич     Цена   НП  Итого сумма  Упаковок Отд Примеч│');
{$ELSE}
        Writeln(txt,Space+Dop+'│N  Код  Сертификат                 Колич     Цена   НП       З/Цена  Упаковок Отд Примеч│');
{12│12345│12345678901234567890123456│12345│12345678901234567890123456│12345│12345678│12345678}
{$ENDIF}
        Writeln(txt,Space+Dop+'└────────────────────────────────────────────────────────────────────────────────────────┘');
  End;
End
Else
 Begin
        Writeln(txt,Space+Dop+'┌─────────────────────────────────────────────────────────┐');
        Writeln(txt,Space+Dop+'│                                   Заказ Дефиц.          │');
        Writeln(txt,Space+Dop+'│N  Код  Сертификат                 Колич Колич Отд Примеч│');
        Writeln(txt,Space+Dop+'└─────────────────────────────────────────────────────────┘');
 End;



        c:=0;
        WordToBit8(c,M);

{New(Skl,Init);}
New(BBBS,Init);

        For l:=1 To E^.Dat.AmountS Do
         Begin
          Str(l:CMantissa,St);
          s:=E^.Dat.DocumentElement[l].BazKod;

       BBBS^.Dat.BazKod:=E^.Dat.DocumentElement[l].BazKod;
       GetBazElement(E^.Dat.DocumentElement[l].BazKod,BBBS^.Dat);

          If Not(E^.DAt.DocumentElement[l].Input.Last) Then
          Separator:=' '   Else Separator:=#249;

          If NPrint^.DAt.FullName=0 Then
          Begin
                ws:=BBBS^.Dat.Name{GetIdField(FName,E^.Dat.DocumentElement[l].BazKod)};
                ws1:=BBBS^.Dat.Name2{GetIdField(FName2,E^.Dat.DocumentElement[l].BazKod)};
                DelSpaceRight(ws1);
                If ws1[0]<>#0 Then
          Begin
                  Writeln(txt,Space+Dop+st+Separator+s+' '+ws);
                  Separator:=' ';
                  st:='  ';
                  ws:=ws1;
                  s:='     ';
                 End;
          End
          Else
         Begin
          ws:=BBBS^.Dat.Name{GetIdField(FFName,E^.Dat.DocumentElement[l].BazKod)};
          ws1:=BBBS^.Dat.Name2{GetIdField(FFName2,E^.Dat.DocumentElement[l].BazKod)};
          DelSpaceRight(ws1);
                 If ws1[0]<>#0 Then
          Begin
                Writeln(txt,Space+Dop+st+Separator+S+' '+ws);
                  Separator:=' ';
                  st:='  ';
                  ws:=ws1;
                  s:='     ';
          End;
         End;


          Format(ws,CName);
          s:=s+' '+ws;
          DelSpace(E^.Dat.DocumentElement[l].Input.Kol);
          ws:=E^.Dat.DocumentElement[l].Input.Kol;
          ws:='{'+ws+'}';
          RFormat(ws,CKol+2);
          s:=s+{' '}+ws;


If Not(Zakaz) Then
Begin
          Str(StrToReal(E^.Dat.DocumentElement[l].Input.Zakupka):CInputIZena-2:CMantissa,TempZakupka);
          If E^.Dat.SkidkaSelector=0 Then{Если автомат}
                begin
                 DelSpace(E^.Dat.DocumentElement[l].Input.Proz);

                 MyStr((StrToReal(E^.Dat.DocumentElement[l].Input.Zena)/
                 (1+StrToReal(E^.Dat.DocumentElement[l].Input.Proz)/100)),CZena,CMantissa,ws);

                 {отключен расчет налога с продажи в товарном чеке}
                 {в этой процедуре ничего менять не надо т.к. налог с продажи
                          при отуске сертификатов не играет никакой роли
                          потому что это товарный чек, а следовательно вмененный налог}
                 If E^.DAt.DocSelector in [1,2,3,5,6] Then
                 Begin
                 Mystr(((1+strtoreal(e^.dat.Documentelement[l].Input.SpecNalog)
                                  /100)),CLitr,CMantissa,koefficient);

                 {новая цена}
                 MyStr(StrToReal(ws){*StrToReal(Koefficient)},CZena,CMantissa,ws);
                 End;

                 s:=s+{' '}+ws;


  If E^.Dat.OperatorSelector=1 Then
    Begin
          Nalog:=E^.Dat.DocumentElement[l].Input.SpecNalog;
          MyStr(StrToReal(Nalog),CLitr,CMantissa,Nalog);
     s:=s+' '+Nalog;
    End;

          MyStr((StrToReal(Ws)*StrToInt(E^.Dat.DocumentElement[l].Input.Kol))
       ,CInputIZena-2,CMantissa,ws);

                 ItogoS:=ItogoS+StrToReal(wS);
{$IFNDEF TAbak}
       If E^.Dat.OperatorSelector=0 Then
                 s:=s+' '+ws
                 Else
       s:=s+' '+ws;
{$ELSE}
       If E^.Dat.OperatorSelector in [0,2] Then
       s:=s+' '+ws
       Else
       s:=s+' '+TempZakupka;
{$ENDIF}
      end
     Else
      Begin
       {сумма скидки}
          MyStr((StrToReal(E^.Dat.DocumentElement[l].Input.Zena)-StrToReal(E^.Dat.DocumentElement[l].Input.Skidka))
       ,CZena,CMantissa,ws);


       If E^.DAt.DocSelector in [1,2,3,5,6] Then
       Begin
                 Mystr(((1+strtoreal(e^.dat.Documentelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);

       {новая цена}
       MyStr(StrToReal(ws){*/StrToReal(Koefficient)},CZena,CMantissa,ws);
       End;

       s:=s+{' '}+ws;



  If E^.Dat.OperatorSelector=1 Then
    Begin
          Nalog:=E^.Dat.DocumentElement[l].Input.SpecNalog;
     MyStr(StrToReal(Nalog),CLitr,CMantissa,Nalog);
          s:=s+' '+Nalog;
    End;
                 MyStr((StrToReal(Ws)*StrToInt(E^.Dat.DocumentElement[l].Input.Kol))
                 ,CInPutIZena-2,CMantissa,ws);

       ItogoS:=ItogoS+StrToReal(wS);

{$IFNDEF TAbak}
       If E^.Dat.OperatorSelector=0 Then
                 s:=s+' '+ws
       Else
                 s:=s+' '+ws;
{$ELSE}
       If E^.Dat.OperatorSelector in [0,2] Then
       s:=s+' '+ws
       Else
       s:=s+' '+TempZakupka;
{$ENDIF}

                { s:=s+' '+ws;}
                End;


     NdsPos:=StrToReal(Ws)*

          StrToReal(E^.Dat.DocumentElement[l].Input.NDS)/
          (100+StrToReal(E^.Dat.DocumentElement[l].Input.NDS));

         {StrToReal(BakGetField(FNDS,E^.Dat.DocumentElement[l].BazKod,0))/
          (100+StrToReal(BakGetField(FNDS,E^.Dat.DocumentElement[l].BazKod,0)));}

     MyStr(NdsPos,CIZena,CMantissa,ws);
     NdsPos:=StrToReal(Ws);

     {Nds:=Nds+NdsPos;}

                {посчитали упаковки}
                pp:=CalcPack(E^.Dat.DocumentElement[l].BazKod,E^.Dat.DocumentElement[l].Input.Kol);
      DelSpace(Pp);
      RFormat(Pp,CPack);
      s:=s+' '+pp;
      {добавили отделение}
End{If Not Zakaz}
Else {если это заказ всетаки}
 Begin
  s:=s+' '+'     ';
 End;

          M[E^.Dat.DocumentElement[l].Input.DivisionNumber]:=1;

                Str(E^.Dat.DocumentElement[l].Input.DivisionNumber:2,ws);


      {Если скидка автоматическая и не нулевая}
                Case E^.Dat.SkidkaSelector Of
                0:Begin{скидка автоматическая}

                 Case NPrint^.DAt.FullSkidka Of
                 0:Begin{скидка в процентах}
                        If DrawSkidka Then
                        Begin
                         If (StrToReal(E^.Dat.DocumentElement[l].Input.Proz)<>0) Then
                          Begin
                                TempSkidka:=E^.Dat.DocumentElement[l].Input.Proz;

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
                         If (StrToReal(E^.Dat.DocumentElement[l].Input.Proz)<>0) Then
                          Begin
                                MyStr(StrToReal(E^.Dat.DocumentElement[l].Input.Zena)-
                                                  StrToReal(E^.Dat.DocumentElement[l].Input.Zena)/
                                (1+StrToReal(E^.Dat.DocumentElement[l].Input.Proz)/100),CKol+1,CMantissa,WspomSkidka);
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

                  Case NPrint^.DAt.FullSkidka Of
                  0:Begin{скидка в процентах}
                        If DrawSkidka Then
                        Begin
                        If (Abs(StrToReal(E^.Dat.DocumentElement[l].Input.Skidka))>=0.01) Then
                         Begin
                          If StrToReal(E^.Dat.DocumentElement[l].Input.Skidka)>0 Then
                                Begin
                                 If (StrToReal(E^.Dat.DocumentElement[l].Input.Zena)-
                                                   StrToReal(E^.Dat.DocumentElement[l].Input.Skidka))>0.009 Then
                                 MyStr(((StrToReal(E^.Dat.DocumentElement[l].Input.Zena))/
                                                   ((StrToReal(E^.Dat.DocumentElement[l].Input.Zena)-
                                 StrToReal(E^.Dat.DocumentElement[l].Input.Skidka)))-1)*100
                                 ,CKol+1,CLitrMantissa,WspomSkidka)
                                 Else
                                 WspomSkidka:='100.00';

                                 MyStr(StrToReal(WspomSkidka){*100},CKol+1,CMantissa,WspomSkidka);
                                End
                                Else
                                 Begin
                                  MyStr((-(Abs(StrToReal(E^.Dat.DocumentElement[l].Input.Skidka)))/
                                  ((StrToReal(E^.Dat.DocumentElement[l].Input.Zena)))*100),CKol+1,CMantissa,WspomSkidka);
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
                        If (Abs(StrToReal(E^.Dat.DocumentElement[l].Input.Skidka))>0.01) Then
                         Begin
                          MyStr(StrToReal(E^.Dat.DocumentElement[l].Input.Skidka),CKol+1,CMantissa,
                          E^.Dat.DocumentElement[l].Input.Skidka);
                          DelSpace(E^.Dat.DocumentElement[l].Input.Skidka);
                          Format(E^.Dat.DocumentElement[l].Input.Skidka,CKol+1);
                          WspomSkidka:=E^.Dat.DocumentElement[l].Input.Skidka;

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

          If Not Video Then s:=
               GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+s+' '+ws+
               GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]
          Else s:=s+' '+ws;


     {вставляем номер версии}
     If EnablePosVersion=1 Then
     If E^.Dat.DocumentElement[l].Input.Version<>1 Then
     {MemC(IntToStr(E^.Dat.DocumentElement[l].Input.Version,CMantissa));}
     If Not Video Then
     s:=s+' '+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
       IntToStr(E^.Dat.DocumentElement[l].Input.Version,
       CMantissa)+
              GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]
     Else
     s:=s+' '+IntToStr(E^.Dat.DocumentElement[l].Input.Version,CMantissa);




          If Not(E^.DAt.DocumentElement[l].Input.Last) Then
          Writeln(txt,Space+Dop+St+Separator+s)
          Else
          Writeln(txt,Space+Dop+St+Separator+s);


      ws1:=BBBS^.Dat.DSertif{GetIDField(FDateSertif,E^.Dat.DocumentElement[l].BazKod)};
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
        If Not(Video) Then
        Begin
         If ws2[0]<>#0 Then
            Write(txt,Space+'   Срок дейст: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
                 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
            ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
         Else
            Write(txt,Space+'   Срок дейст: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
                 GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
            ws1+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' ')
        End
        Else
        BEgin
         If ws2[0]<>#0 Then
             Write(txt,Space+'  Срок дейст: ',+ws1+' ')
         Else
             Write(txt,Space+'  Срок дейст: ',+ws1+' ');
        End
          End;

      {отключена печать графы кем выдан сертификат}
      ws2:=BBBS^.Dat.KSertif{GetIDField(FKtoSertif,E^.Dat.DocumentElement[l].BazKod)};
      DelSpaceRight(ws2);
      If ws2[0]<>#0 Then
       Begin
           If ws1[0]<>#0 Then
         Begin
          If Not Video Then
        Writeln(txt,' Выдан: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ws2+
             GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
        Writeln(txt,' Выдан: ',+ws2);
         End
           Else
         Begin
          If Not Video Then
                Writeln(txt,Space+'       Выдан: ',GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
                        GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ws2+
                       GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
          Else
                Writeln(txt,Space+'       Выдан: ',+ws2);
         End;
       End
      Else  If ws1[0]<>#0 Then Writeln(txt);



       Printing:=False;
       For k:=1 To E^.Dat.Amount Do
        Begin
         If E^.Dat.MarketElement[k].input.NSertif=E^.Dat.DocumentElement[l].BazKod Then
          Begin
           If Not Printing Then
            Writeln(txt,Space+Dop+'         Для следующих позиций:');
           Printing:=True;
           ws1:=GetIdField(FFFName,E^.Dat.MarketElement[k].BazKod);
           {ws2:=GetIdField(FName2,E^.Dat.MarketElement[k].BazKod);}
           DelSpaceRight(ws1);
           {DelSpaceRight(ws2);
           ws1:=ws1+' '+ws2;}
           Format(ws1,CName+1+CNAme);
           Writeln(txt,Space+Dop+'           '+E^.Dat.MarketElement[k].BazKod+' '+ws1);
          End;
        End;

         End;

Dispose(BBBS,Done);

         ItogoSkidka:=Itogo{+StrToReal(E^.Dat.ENalog)};
         MySTr(ItogoSkidka,CIZena,CMantissa,tt1);
         MySTr(ItogoS,CIZena,CMantissa,tt2);

         ItogoSkidka:=StrToReal(tt1)-StrToReal(tt2){ItogoS};

         DelSpace(E^.Dat.SertifSummaZ);
         RFormat(E^.Dat.SertifSummaZ,CIZena);
         RFormat(E^.Dat.SertifSummaZakupka,CIZena);
         RFormat(E^.Dat.SertifSummaZakupka2,CIZena);
{    If Video Then Writeln(txt,Space+'______________________________________________________________________________');}
MyStr(StrToReal(E^.Dat.SertifSummaZ),CIZena,CMantissa,E^.Dat.SertifSummaZ);
MyStr(StrToReal(E^.Dat.SertifSummaZakupka),CIZena,CMantissa,E^.Dat.SertifSummaZakupka);
MyStr(StrToReal(E^.Dat.SertifSummaZakupka2),CIZena,CMantissa,E^.Dat.SertifSummaZakupka2);
{DelSpace(E^.Dat.SummaZ);}

If Not(Zakaz) Then
Begin
  If E^.DAt.OperatorSelector in [0,2] Then
   Begin
    Writeln(txt,Space+Dop+'────────────────────────────────────────────────────────────────────────────────────');
    Writeln(Txt,Space+Dop+'Всего сертификатов:',E^.Dat.AmountS:2,'           Всего к оплате:',Recogniz(E^.Dat.SertifSummaZ)
    );

If (Video) And (StrToInt(CurrentPassword)=0) Then
   Begin
    Writeln(Txt,Space+Dop+'                                   Всего закупка:',Recogniz(E^.Dat.SertifSummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SertifSummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SertifSummaZakupka),
    CIZena,CMantissa)));
    Writeln(Txt,Space+Dop+'                                  Всего закупка2:',Recogniz(E^.Dat.SertifSummaZakupka2)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SertifSummaZ){-StrToReal(E^.Dat.ENalog)}-
    StrToReal(E^.Dat.SertifSummaZakupka2),
    CIZena,CMantissa)));
   End;

   End
   Else
    Begin
    Writeln(txt,Space+Dop+'──────────────────────────────────────────────────────────────────────────────────────────');
    Writeln(Txt,Space+Dop+'Всего сертификатов:',E^.Dat.AmountS:2,'           Всего к оплате:',
    Recogniz(E^.Dat.SertifSummaZ));
{$IFNDEF Tabak}

{$ELSE}
    If E^.Dat.OperatorSelector=1 Then
    Begin
    Writeln(Txt,Space+Dop+'                                         Всего закупка:',Recogniz(E^.Dat.SertifSummaZakupka));
    Writeln(Txt,Space+Dop+'                                        Всего закупка2:',Recogniz(E^.Dat.SertifSummaZakupka2));
    End;
{$ENDIF}

If (Video) And (StrToInt(CurrentPassword)=0) And Not(E^.DAt.OperatorSelector=1) Then
   Begin
    Writeln(Txt,Space+Dop+'                                         Всего закупка:',Recogniz(E^.Dat.SertifSummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SertifSummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SertifSummaZakupka),
    CIZena,CMantissa)));
    Writeln(Txt,Space+Dop+'                                        Всего закупка2:',Recogniz(E^.Dat.SertifSummaZakupka2)+
    '   D2:'+Recogniz(RealToStr(StrToReal(E^.Dat.SertifSummaZ){-StrToReal(E^.Dat.ENalog)}-
    StrToReal(E^.Dat.SertifSummaZakupka2),
    CIZena,CMantissa)));
   End;
    End;
End
Else
 Begin
   Writeln(txt,Space+Dop+'─────────────────────────────────────────────────────────');
   Writeln(Txt,Space+Dop+'Всего позиций:',E^.Dat.AmountS:2,'Всего к оплате(ориентир):',Recogniz(E^.Dat.SertifSummaZ));

If (Video) And (StrToInt(CurrentPassword)=0) And Not(E^.DAt.OperatorSelector=1) Then
   Begin
    Writeln(Txt,Space+Dop+'                                Всего закупка(ориентир):',Recogniz(E^.Dat.SertifSummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SertifSummaZ){-StrToReal(E^.Dat.ENalog)}-StrToReal(E^.Dat.SertifSummaZakupka),
    CIZena,CMantissaZ)));
    Writeln(Txt,Space+Dop+'                               Всего закупка2(ориентир):',Recogniz(E^.Dat.SertifSummaZakupka2)+
    '   D2:'+Recogniz(RealToStr(StrToReal(E^.Dat.SertifSummaZ)-StrToReal(E^.Dat.SertifSummaZakupka2),
    CIZena,CMantissaZ)));
   End;
 End;{Zakaz}


Writeln(Txt);

   If Not(Local) Then
   Begin
   If Not(Video) Then
   Begin
    If R Then
    Begin
     For c:=1 To CDivision Do
      Begin
       If M[c]=1 Then
        Begin
         s:=Rek^.Dat.Otdel[c];
         Format(s,CIZena);
         Writeln(Txt,Space+Dop+'        Сдал (отделение ',c:1,'): '{+GlobalPrn^.Dat.Bold+s+GlobalPrn^.Dat.NoBold}+
            '______          Документы принял экспедитор: ______')
        End;
      End;{For}
      Writeln(Txt);
      Writeln(Txt,Space+Dop+' Документы сдал экспедитор: ',''{+GlobalPrn^.Dat.Bold+s+GlobalPrn^.Dat.NoBold}+
            '______  Документы принял, претензий не имею: ______')

    End
    Else
    Writeln(Txt,Space+'            Сдал ________   Документы принял, претензий не имею _______')

   End;
   End
   Else
    Begin
    OutPutSklad:=GetClientField(FClient,Rek^.Dat.Kod,1);
    Format(OutPutSklad,CClient);
    InPutSklad:=GetClientField(FClient,E^.Dat.ClientKod,1);
    Format(InPutSklad,CClient);
   If Not(Video) Then
   Begin
 Writeln(Txt,Space+'    '+'  Сдал '+OutPutSklad+': __________  Документы принял экспедитор: __________');
 Writeln(Txt);
 Writeln(Txt,Space++'    '+'Принял '+InputSklad +': __________  Документы сдал экспедитор  : __________');

   End;
   End;

If Not(Zakaz) Then
Begin
   Writeln(Txt,Space{+'Скидка: '},'{'+RecognizReal(ItogoSkidka,CIZena,CMantissa)+'}');

   If Not(Video) Then Write(txt,Space{+' Всего: '},' '+RecognizReal(Itogo,CIZena,CMantissa),
    '              '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')')
   Else
   Writeln(Txt,Space{+' Всего: '},' '+RecognizReal(Itogo,CIZena,CMantissa));
   If Not(Video) Then
   Writeln(txt,' '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+'Тип документа: (',
   LeadingZero(E^.Dat.DocSelector),')'+ZakazNumer+E^.DAt.Document+'-С'+'/'+IntToStr(StrToInt(E^.Dat.SkladKod),COne)+
   +GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
End
Else
 Begin
   Writeln(Txt,Space{+'Скидка: '},'{'+RecognizReal(ItogoSkidka,CIZena,CMantissa)+'}');

   If Not(Video) Then Write(txt,Space{+' Всего: '},' '+RecognizReal(Itogo,CIZena,CMantissa),
    '              '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')')
   Else
   Writeln(Txt,Space{+' Всего: '},' '+RecognizReal(Itogo,CIZena,CMantissa));
   If Not(Video) Then
   Writeln(txt,' '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+'Тип документа: (',
   LeadingZero(E^.Dat.DocSelector),')'+ZakazNumer+'-С'+'/'+IntToStr(StrToInt(E^.Dat.SkladKod),COne)+
   +GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
 End;

   If (E^.Dat.OperatorSelector in[0,2]) Then
   WriteLn(txt,Space+'==============================================')
   Else
   WriteLn(txt,Space+'==============================================');

If Not(Video) Then NoInfoMsg;
End;




Procedure RefreshDocumentsList1(Kod : ArtikulStr;OperatorSelector:Word;SDocS,SDAteS:TDAteString; Var DocumentsList:PBox);
Var Es : PBufClientToVarType;
    Esf : File{ Of ClientTovarType};
    BakFileMode,Count,posit,c,c1 : Word;
    s : String;
    SDate : TDateString;
    Regim : Boolean;
Begin
DocumentSList^.NewList(Nil);
DocumentSList^.NewList(New(PTextCollection, Init(0,1)));
{вставить процедуру}

If OperatorSelector=0 Then
Begin
 Assign(Esf,Path^.Dat.ToClientIndex+IntToStr(OperatorSelector,COne)+Kod+'.tdx');
 c:=IoResult;
 BakFileMode:=FileMode;
 FileMode:=$42;
 Reset(Esf,SizeOf(ClientTovarType));
 c:=IoResult;
 FileMode:=BakFileMode;

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
   If Not((StrToInt(SDocS)=StrToInt(Es^.Point.Dat[c1].Document)) And
           (SDateS=Es^.Point.Dat[c1].DAteC)) Then
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
    End;{Active}
  End;
   Dispose(Es,Done);
  End;{While}
 c:=IoResult;
 Close(Esf);
 c:=IoResult;
End;
End;



Function GetArchiv(SFantomArtikul:ArtikulStr;
         Const DocumentSL:PBox;Var SKol,SDoc,SDate,SAgent:TDateString):Boolean;
Var Posit:Word;
    s : String;
Begin
 GetArchiv:=False;
 If Not TestElement(SFantomArtikul,DocumentSL) Then
 Begin
  GetArchiv:=True;
  Posit:=Location(DocumentSL,SFantomArtikul,False);
  s:=DocumentSL^.GetText(Posit,DocumentSL^.List^.Count);
  SDoc:=Copy(s,1+1+CArtikul+1+CKol+1,CDocNumer);
  SDate:=Copy(s,1+1+CArtikul+1+CKol+1+CDocNumer+1,CDate);
  SKol:=Copy(s,1+1+CArtikul+1,CKol);
  SAgent:=Copy(s,1+1+CArtikul+1+CKol+1+CDocNumer+1+CDate+1,CClientKod);
 End;
End;



Function TestFormPAmatka(E:PSuperMarketType):Boolean;
Var l,c,j : Word;
    R1 : TRect;
    DocumentSL : PBox;
    Find : Boolean;
    SKol,SDoc,SDAte,SAgent : TDateString;
Begin
TestFormPamatka:=False;

If (E^.DAt.Amount=0) Or (E^.DAt.OperatorSelector in [1,2]) Then Exit;

DelSpace(E^.DAt.Document);
DelSpace(E^.DAt.DateC);
DelSpace(E^.DAt.TimeC);


R1.Assign(0, 0, 0, 0);
DocumentSL := New(PBox, Init(R1, 1, Nil));
DocumentSL^.NewList(New(PTextCollection, Init(0,1)));


RefreshDocumentsList1(E^.Dat.ClientKod,E^.Dat.OperatorSelector,E^.Dat.Document,
E^.Dat.DateC,DocumentSL);

        For l:=1 To E^.Dat.Amount Do
         Begin
       Find:=False;
        If E^.Dat.MArketElement[l].Input.NSertif<>NoSertifStr Then
        For j:=1 To E^.Dat.AmountS Do
         Begin
          If E^.Dat.DocumentElement[j].BazKod=E^.Dat.MArketElement[l].Input.NSertif Then
           Begin
            Find:=True;
            Break;
           End;
         End;{цикл For поиска внутри документа}

        If Not(Find) Then
        {если сертификата нет в накладной
            тогда начинаем его поиск в архиве
            и если он есть, то добавляем его в памятку}
         Begin
          Find:=GetArchiv(E^.Dat.MarketElement[l].Input.NSertif,
                                 DocumentSL,SKol,SDoc,SDate,SAgent);
          If Find Then{если нашли в архиве}
           Begin
            TestFormPAmatka:=True;
            Dispose(DocumentSL,Done);
            Exit;
           End;{Если 2-ой find=true}
         End;{Если 1- find=false}
      End;{For}

Dispose(DocumentSL,Done);


End;{Function}



{$IFNDEF Pharm}
Procedure FormPamatka(Space :TDateString;Video :Boolean;
                                   Const E :PSuperMarketType;Var Txt :Text;Zakaz:Boolean);
Var   l,j : Word;
         Ver,s,sc,ws,ws1,ws2,ws3 : String;
         st,Ss,ss1 : String;
         Local,R : Boolean;
         Dop : TDateString;
      R1 : TRect;
      Separator : ArtikulStr;
      DocumentSL : PBox;
      Find,FindList : Boolean;
      c,k : Word;
      BBBS : PBAzType;
      SKol,SDoc,SDate,SAgent : TDAteString;
      ZakazNumer,ZakazDate : AllStr;
      Printing : Boolean;

Begin
Dop[0]:=#0;

If Not(Video) Then DInfoMsg('Формирую памятку на отпуск сертификатов. Ждите...',True);


   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;

If Not Zakaz Then
Begin

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
End
Else
    Begin
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer;
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
    End;




If E^.Dat.DocSelector<>0 Then{если не список}
Begin
Writeln(Txt,Header+Space+(*'Склад: ',{E^.Dat.Sklad+}E^.Dat.SkladKod+*)
                  'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
End
Else
Begin
If E^.Dat.OperatorSelector<>0 Then
Begin
Writeln(Txt,Header+Space+(*'Склад: ',{E^.Dat.Sklad}E^.Dat.SkladKod+*)
                  'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
End
 Else Begin
        Writeln(txt,Header);
      End;
End;




DelSpace(E^.DAt.Document);
DelSpace(E^.DAt.DateC);
DelSpace(E^.DAt.TimeC);


R1.Assign(0, 0, 0, 0);
DocumentSL := New(PBox, Init(R1, 1, Nil));
DocumentSL^.NewList(New(PTextCollection, Init(0,1)));


{RefreshDocumentsList1(E^.Dat.ClientKod,E^.Dat.OperatorSelector,DocumentSL);}

RefreshDocumentsList1(E^.Dat.ClientKod,E^.Dat.OperatorSelector,E^.Dat.Document,
E^.Dat.DateC,DocumentSL);





If Not(Zakaz) Then
        Writeln(Txt,Space+'  П Р И Л О Ж Е Н И Е - памятка к накладной  N '+ZakazNumer+E^.Dat.Document+
        '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+' от '+ZakazDate{E^.Dat.DAteC}{+' ('+ZakazTime+')'})
Else
        Writeln(Txt,Space+'  П Р И Л О Ж Е Н И Е - памятка к заказу  N '+ZakazNumer+'/'+
        IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+' от '+ZakazDate{E^.Dat.DAteC}{+' ('+ZakazTime+')'});

     Ver[0]:=#0;
        If (E^.Dat.Versia>1) Then
         Begin
          Ver:=Ver+'              Версия: '+IntToStr(E^.Dat.Versia,CLitrMantissa);
         End;

      s:=GetClientField(FFullClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
      Format(s,CAll);
 Writeln(Txt,Space+'Получатель: ',s+' ('+E^.Dat.ClientKod+')'+Ver);


        Writeln(txt,Space+Dop+'┌───────────────────────────────────────────────────────────────────────────┐');
        Writeln(txt,Space+Dop+'│N  Код  Сертификат                 Колич Nдок Дата отг.       Агент        │');
        Writeln(txt,Space+Dop+'└───────────────────────────────────────────────────────────────────────────┘'+HeaderStop);

                                          {12│12345│12345678901234567890123456│12345│1234│12345678│12345678901234567890}

     c:=0;
        For l:=1 To E^.Dat.Amount Do
         Begin
       Find:=False;
        If E^.Dat.MArketElement[l].Input.NSertif<>NoSertifStr Then
        For j:=1 To E^.Dat.AmountS Do
         Begin
          If E^.Dat.DocumentElement[j].BazKod=E^.Dat.MArketElement[l].Input.NSertif Then
           Begin
            Find:=True;
            Break;
           End;
         End;{цикл For поиска внутри документа}

        If Not(Find) Then
        {если сертификата нет в накладной
            тогда начинаем его поиск в архиве
            и если он есть, то добавляем его в памятку}
         Begin
          Find:=GetArchiv(E^.Dat.MarketElement[l].Input.NSertif,
                                DocumentSL,SKol,SDoc,SDate,SAgent);

          If Find Then{если нашли в архиве}
           Begin
            Inc(c);
            Str(c:CMantissa,St);
            s:=E^.Dat.MarketElement[l].Input.NSertif;




            New(BBBS,Init);

            BBBS^.Dat.BazKod:=E^.Dat.MarketElement[l].Input.NSertif;
            GetBazElement(E^.Dat.MarketElement[l].Input.NSertif,BBBS^.Dat);

            Separator:=' ';

          If Nprint^.DAt.FullName=0 Then
                 Begin
                     ws:=BBBS^.Dat.Name;
                     ws1:=BBBS^.Dat.Name2;
                     DelSpaceRight(ws1);
                     If ws1[0]<>#0 Then
                   Begin
                          Writeln(txt,Space+Dop+st+Separator+s+' '+ws);
                       Separator:=' ';
                       st:='  ';
                       ws:=ws1;
                       s:='     ';
                      End;
                 End
               Else
                Begin
                 ws:=BBBS^.Dat.Name;
                 ws1:=BBBS^.Dat.Name2;
                 DelSpaceRight(ws1);
                    If ws1[0]<>#0 Then
                   Begin
                       Writeln(txt,Space+Dop+st+Separator+S+' '+ws);
                       Separator:=' ';
                       st:='  ';
                       ws:=ws1;
                       s:='     ';
                   End;
                End;


                   Format(ws,CName);
                s:=s+' '+ws;
                DelSpace(SKol);
                ws:=SKol;
                ws:='{'+ws+'}';
                RFormat(ws,CKol+2);
                s:=s+{' '}+ws;
             RFormat(SDoc,CDocNumer);
             RFormat(SDate,CDate);
             s:=s+SDoc+' '+SDate;
             ws:=GetAgentField(FClient,SAgent);
             Format(ws,CClient);

                If Not Video Then s:=
                        GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+s+' '+ws+
                        GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]
                Else s:=s+' '+ws;

             If l=E^.Dat.Amount Then s:=ONLYLINK+s;


             Writeln(txt,Space+Dop+st+Separator+s);


       Printing:=False;
       For k:=1 To E^.Dat.Amount Do
        Begin
         If E^.Dat.MarketElement[k].input.NSertif=E^.Dat.MarketElement[l].Input.NSertif Then
          Begin
           If Not Printing Then
            Writeln(txt,Space+Dop+'  Для следующих позиций:');
           Printing:=True;
           ws1:=GetIdField(FFFName,E^.Dat.MarketElement[k].BazKod);
           DelSpaceRight(ws1);
           Format(ws1,CName+1+CNAme);
           Writeln(txt,Space+Dop+'       '+E^.Dat.MarketElement[k].BazKod+' '+ws1);
          End;
        End;






             Dispose(BBBS,Done);
          End;{Если 2-ой find=true}
         End;{Если 1- find=false}
      End;{For}


    Writeln(txt,Space+Dop+'─────────────────────────────────────────────────────────────────────────────');
    Writeln(Txt,Space+Dop+'Всего сертификатов:',c:2);

    Writeln(Txt);

    If Not(Video) Then Write(txt,Space{+' Всего: '},'                '+
     '           '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

   If Not(Video) Then
   Begin
   If Not(Zakaz) Then
    Writeln(txt,' '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+'Тип документа: (',
    LeadingZero(E^.Dat.DocSelector),')'+ZakazNumer+E^.DAt.Document+'-С'+'/'+IntToStr(StrToInt(E^.Dat.SkladKod),COne)+
    +GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer])
   Else
    Writeln(txt,' '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+'Тип документа: (',
    LeadingZero(E^.Dat.DocSelector),')'+ZakazNumer+'-С'+'/'+IntToStr(StrToInt(E^.Dat.SkladKod),COne)+
    +GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer])
   End;

   Write(txt,Space+'=============================================================================');

Dispose(DocumentSl,Done);
If Not(Video) Then NoInfoMsg;
End;

{$ELSE}

Procedure FormPamatka(Space :TDateString;Video :Boolean;Const E :PSuperMarketType;Var Txt :Text;Zakaz:Boolean);
Var   l,j : Word;
         Ver,s,sc,ws,ws1,ws2,ws3 : String;
         st,Ss,ss1 : String;
         Local,R : Boolean;
         Dop : TDateString;
      R1 : TRect;
      Separator : ArtikulStr;
      DocumentSL : PBox;
      Find,FindList : Boolean;
      c,k : Word;
      BBBS : PBAzType;
      SKol,SDoc,SDate,SAgent : TDAteString;
      ZakazNumer,ZakazDate : AllStr;
      Printing : Boolean;
      PrintList : PBox;
      R2 : TRect;

Begin
Dop[0]:=#0;

If Not(Video) Then DInfoMsg('Формирую памятку на отпуск сертификатов. Ждите...',True);


   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   Space:='     ';

If Not Zakaz Then
Begin

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
End
Else
    Begin
     ZakazNumer:=E^.DAt.Document{FromZakaz};
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer;
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
    End;




If E^.Dat.DocSelector<>0 Then{если не список}
Begin
Writeln(Txt,Header+Space+(*'Склад: ',{E^.Dat.Sklad+}E^.Dat.SkladKod+*)
                  'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
End
Else
Begin
If E^.Dat.OperatorSelector<>0 Then
Begin
Writeln(Txt,Header+Space+(*'Склад: ',{E^.Dat.Sklad}E^.Dat.SkladKod+*)
                  'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
End
 Else Begin
        Writeln(txt,Header);
      End;
End;




DelSpace(E^.DAt.Document);
DelSpace(E^.DAt.DateC);
DelSpace(E^.DAt.TimeC);


R1.Assign(0, 0, 0, 0);
DocumentSL := New(PBox, Init(R1, 1, Nil));
DocumentSL^.NewList(New(PTextCollection, Init(0,1)));


RefreshDocumentsList1(E^.Dat.ClientKod,E^.Dat.OperatorSelector,E^.DAt.Document,E^.DAt.DateC,DocumentSL);


R2.Assign(0, 0, 0, 0);
PrintList := New(PBox, Init(R2, 1, Nil));
PrintList^.NewList(New(PTextCollection, Init(0,1)));



If Not(Zakaz) Then
        Writeln(Txt,Space+'  П Р И Л О Ж Е Н И Е - памятка к накладной  N '+ZakazNumer+E^.Dat.Document+
        '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+' от '+ZakazDate{E^.Dat.DAteC}{+' ('+ZakazTime+')'})
Else
        Writeln(Txt,Space+'  П Р И Л О Ж Е Н И Е - памятка к заказу  N '+ZakazNumer+'/'+
        IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+' от '+ZakazDate{E^.Dat.DAteC}{+' ('+ZakazTime+')'});

     Ver[0]:=#0;
        If (E^.Dat.Versia>1) Then
         Begin
          Ver:=Ver+'              Версия: '+IntToStr(E^.Dat.Versia,CLitrMantissa);
         End;

      s:=GetClientField(FFullClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
      Format(s,CAll);
 Writeln(Txt,Space+'Получатель: ',s+' ('+E^.Dat.ClientKod+')'+Ver);


        Writeln(txt,Space+Dop+'┌───────────────────────────────────────────────┐');
        Writeln(txt,Space+Dop+'│N  Код  Сертификат                Nдок Дата отг│');
        Writeln(txt,Space+Dop+'└───────────────────────────────────────────────┘'+HeaderStop);
                              {12│12345│12345678901234567890123456│1234│12345678│12345678901234567890}

     c:=0;
        For l:=1 To E^.Dat.Amount Do
         Begin
       Find:=False;
        If E^.Dat.MArketElement[l].Input.NSertif<>NoSertifStr Then
        {это условие вставлено 23/08/2003 для оптимизации}
        {If (TestElement(E^.Dat.MarketElement[l].Input.NSertif,PrintList) Then}
        For j:=1 To E^.Dat.AmountS Do
         Begin
          If E^.Dat.DocumentElement[j].BazKod=E^.Dat.MArketElement[l].Input.NSertif Then
           Begin
            Find:=True;
            Break;
           End;
         End;{цикл For поиска внутри документа}

        If Not(Find) Then
        {если сертификата нет в накладной
            тогда начинаем его поиск в архиве
            и если он есть, то добавляем его в памятку}
         Begin
          Find:=GetArchiv(E^.Dat.MarketElement[l].Input.NSertif,
                                DocumentSL,SKol,SDoc,SDate,SAgent);

          If Find and (TestElement(E^.Dat.MarketElement[l].Input.NSertif,PrintList))  Then{если нашли в архиве}
           Begin
            Inc(c);
          Str(c:CMantissa,St);
               s:=E^.Dat.MarketElement[l].Input.NSertif;

            PrintList^.List^.Insert(NewStr('│'+s));
            PrintList^.SetRange(PrintList^.List^.Count);

            New(BBBS,Init);

            BBBS^.Dat.BazKod:=E^.Dat.MarketElement[l].Input.NSertif;
            GetBazElement(E^.Dat.MarketElement[l].Input.NSertif,BBBS^.Dat);

            Separator:=' ';

          If Nprint^.DAt.FullName=0 Then
                 Begin
                     ws:=BBBS^.Dat.Name;
                     ws1:=BBBS^.Dat.Name2;
                     DelSpaceRight(ws1);
                     If ws1[0]<>#0 Then
                   Begin
                          Writeln(txt,Space+Dop+st+Separator+s+' '+ws);
                       Separator:=' ';
                       st:='  ';
                       ws:=ws1;
                       s:='     ';
                      End;
                 End
               Else
                Begin
                 ws:=BBBS^.Dat.Name;
                 ws1:=BBBS^.Dat.Name2;
                 DelSpaceRight(ws1);
                    If ws1[0]<>#0 Then
                   Begin
                       Writeln(txt,Space+Dop+st+Separator+S+' '+ws);
                       Separator:=' ';
                       st:='  ';
                       ws:=ws1;
                       s:='     ';
                   End;
                End;


                   Format(ws,CName);
                s:=s+' '+ws;
                (*
                DelSpace(SKol);
                ws:=SKol;
                ws:='{'+ws+'}';
                RFormat(ws,CKol+2);
                s:=s+ws;*)
             RFormat(SDoc,CDocNumer);
             RFormat(SDate,CDate);
             s:=s+SDoc+' '+SDate;

             ws[0]:=#0;
             (*
             ws:=GetAgentField(FClient,SAgent);
             Format(ws,CClient);*)

                If Not Video Then s:=GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+s+' '+
                        ws+GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]
                Else s:=s+' '+ws;

             If l=E^.Dat.Amount Then s:=ONLYLINK+s;


             Writeln(txt,Space+Dop+st+Separator+s);

       Printing:=False;
       For k:=1 To E^.Dat.Amount Do
        Begin
         If E^.Dat.MarketElement[k].input.NSertif=E^.Dat.MarketElement[l].Input.NSertif Then
          Begin
           If Not Printing Then
            Writeln(txt,Space+Dop+'  Для следующих позиций:');
           Printing:=True;
           ws1:=GetIdField(FFFName,E^.Dat.MarketElement[k].BazKod);
           DelSpaceRight(ws1);
           Format(ws1,CName+1+CNAme);
           Writeln(txt,Space+Dop+'       '+E^.Dat.MarketElement[k].BazKod+' '+ws1);
          End;
        End;



             Dispose(BBBS,Done);
          End;{Если 2-ой find=true}
         End;{Если 1- find=false}
      End;{For}


    Writeln(txt,Space+Dop+'─────────────────────────────────────────────────────────────────────────────');
    Writeln(Txt,Space+Dop+'Всего сертификатов:',c:2);

    Writeln(Txt);

    If Not(Video) Then Write(txt,Space{+' Всего: '},'                '+
     '           '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

   If Not(Video) Then
   Begin
   If Not(Zakaz) Then
    Writeln(txt,' '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+'Тип документа: (',
    LeadingZero(E^.Dat.DocSelector),')'+ZakazNumer+E^.DAt.Document+'-С'+'/'+IntToStr(StrToInt(E^.Dat.SkladKod),COne)+
    +GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer])
   Else
    Writeln(txt,' '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+'Тип документа: (',
    LeadingZero(E^.Dat.DocSelector),')'+ZakazNumer+'-С'+'/'+IntToStr(StrToInt(E^.Dat.SkladKod),COne)+
    +GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer])
   End;

   Write(txt,Space+'=============================================================================');

Dispose(DocumentSl,Done);
Dispose(PrintList,Done);
If Not(Video) Then NoInfoMsg;
End;
{$ENDIF}








Procedure FormPril( E:PSuperMarketType;Var Txt:Text;Zakaz:Boolean);
Var l : Word;
         k,j : Byte;
         Full,s,ws,ws1 : String;
         kkk:Text;
         st : String[CMantissa];
         ItogoLitr,PromItogoPos,ItogoPos,NDSPos : Real;
         Test : LongInt;
         SDoc,SDate,SummaNDS : String[CInputIZena];
         RealZena,ITOGONDS_NP,SummaZena: String[CInputIZena];
         Space : AllStr;
         ItogNalog,Koefficient,pp : String[CPack];
         Rek1 :Rekwiziti;
      NArt : ArtikulStr;
         Lg : PSuperMarketType;
      ZakazNumer,ZakazDate : TDAteString;
Begin

DInfoMsg('Формирую приложения. Ждите...',True);

DelSpace(E^.Dat.FromZakaz);
DelSpace(E^.Dat.Document);


   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   SDoc[0]:=#0;

If Not Zakaz Then
Begin
   (*отключено из-за проблем с бухгалтерией 26/03/01*)
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

End
Else
    Begin
     ZakazNumer:=E^.DAt.Document{FromZakaz};
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer;
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
    End;


        Space:='    ';
        Writeln(Txt,Header+Space+' Склад: ',{E^.Dat.Sklad+}E^.Dat.SkladKod+
                  '  Оператор: '+E^.Dat.Caption+' EYE & 1999-2001');

If Zakaz Then
   Writeln (Txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
   '                  Приложение к накладной N '+
   ZakazNumer+{'/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)+{E^.DAt.Document}+'      от '+
   ZakazDate{E^.Dat.DAteC}+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer])
Else
   Writeln (Txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
   '                  Приложение к накладной N '+
   ZakazNumer+'/'+E^.DAt.Document{+'/'+IntToStr(StrToInt(E^.DAt.SkladKod),COne)}+
   {E^.DAt.Document}+'      от '+
   ZakazDate{E^.Dat.DAteC}+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);



{$IFNDEF Tabak}
   If E^.Dat.DocSelector in [2,3,4,5,6,7,8] Then Rek1:=RekSF^.Dat
   Else Rek1:=Rek^.Dat;
{$ELSE}
   If E^.Dat.DocSelector in [3,4,6,8] Then Rek1:=RekSF^.DAt
   Else Rek1:=Rek^.DAt;
{$ENDIF}

   Format(Rek1.NAme,CAll);
   Format(Rek1.Adress,CAll);
   Format(Rek1.Telefon,CAll);
   Writeln(Txt,Space+' Предриятие:'+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+Rek1.Name+
   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]   +
   ' В соответствии  с  поста- ');
   Writeln(Txt,Space+' Адрес     :'+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+Rek1.Adress+
   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer] +
   ' новлением правительства РФ');
   Writeln(Txt,Space+' Телефон   :'+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+Rek1.Telefon+
   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+' N 55 от 19.01.98');
   DelSpaceRight(Rek1.AdressCopySertif);
   DelSpaceRight(Rek1.Telefon);

   Writeln(Txt,Space+' Первые копии сертификатов находятся по адресу:'+Rek1.AdressCopySertif);

{  Writeln(Txt,Space+'                                                          тификации  N 210 7/268  от ');
   Writeln(Txt,Space+'                                                          06.04.96г. и Постановлением');
   Writeln(Txt,Space+'                                                          Правительства РФ N 595     ');
   Writeln(Txt,Space+'                                                          от 17.05.96 г.');}

   Writeln(Txt);

   Space[0]:=#0;
   Space:='          ';
   Writeln(txt,Space+GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
   '┌─────┬──────────────────────────┬─────────────────────────────────────'+
   '┌───────────┬─────────┬─────────────────────────────┐'+GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);
   Writeln(txt,Space+GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
   '│ Код │Наименование товара       │Регистрационный и учетный               │Ср'+
   'ок    │  Дата   │Наименование органа,         │'+
   GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);
   Writeln(txt,Space+GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
   '│     │                          │N сертификата                           │дей'+
   'ствия│  выдачи │выдающего сертификат         │'+
   GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);
   Writeln(txt,Space+GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
   '└─────┴──────────────────────────┴────────────────────────────────────────┴───'+
   '─────┴─────────┴─────────────────────────────┘'+
   GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]+HeaderStop);

   {12345 12345678901234567890123456│1234567890123456789012345678901234567890│1234567890│
   1234567890│1234567890123456789012345678901234567890}

                                                                     {1234567890123 1234 1234567890123 1234567890123}
   New(Lg,Init);
   k:=1;j:=1;

   For l:=1 To E^.Dat.Amount Do
    Begin

     If testMarketSF(E^.Dat.MarketElement[l].BazKod,Lg,j) Then
      Begin
       Str((StrToInt(Lg^.Dat.MarketElement[j].Input.Kol)+
            StrToInt( E^.Dat.MarketElement[l].Input.Kol)):CKol,Lg^.Dat.MarketElement[j].Input.Kol);
       Lg^.Dat.MarketElement[j].Input.NSertif:=E^.Dat.MarketElement[l].Input.NSertif;
      End
      Else
      Begin
       Lg^.Dat.MarketElement[k]:=E^.Dat.MarketElement[l];
       Inc(k);
       Lg^.DAt.Amount:=k-1;
      End;
    End;
    Lg^.DAt.Amount:=k-1;


   For l:=1 To Lg^.Dat.Amount Do
    Begin
     {
     If Nprint^.DAt.FullName=0 Then
     ws:=GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod)
     Else ws:=GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod);
     }
     {
     If StrToInt(Copy(Lg^.DAt.MarketElement[l].BazKod,1,CRazdelKod)) in
      [29..54,56] Then
     }
    If TestPrilogenieAndGTD(0{True},Lg^.DAt.MarketElement[l].BazKod) Then
Begin

     Full[0]:=#0;
     If Nprint^.DAt.FullName=0 Then
     Begin
      ws:=GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod);
      ws1:=GetIdField(FName2,Lg^.Dat.MarketElement[l].BazKod);
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
        Full:=ws;
        ws:=ws1;
       End;
     End
     Else
         Begin
          ws:=GetIdField(FFName,Lg^.Dat.MarketElement[l].BazKod);
       ws1:=GetIdField(FFName2,Lg^.Dat.MarketElement[l].BazKod);
       DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
        Full:=ws;
        ws:=ws1;
       End;
      End;



     Format(ws,CName);
     s:=Lg^.DAt.MarketElement[l].BazKod+' '+ws;
     ws:=GetIdField(FName,Lg^.DAt.MarketElement[l].Input.NSertif);
     DelSpaceRight(ws);
     If (WS[0]<>#0) Then
Begin
     Format(ws,CNSertif);
     s:=s+' '+ws;
     ws:=GetIdField(FDateSertif,Lg^.DAt.MarketElement[l].Input.NSertif);
     DelSpace(ws);
     Format(ws,CDSertif);
     s:=s+' '+ws;

     ws:=GetIdField(FDVidan,Lg^.DAt.MarketElement[l].Input.NSertif);
     DelSpace(ws);
     Format(ws,CDSertif);
     s:=s+' '+ws;

     ws:=GetKSertifField(FKtoSertif,GetIDField(FKtoSertif,Lg^.DAt.MarketElement[l].Input.NSertif));
     Format(ws,CKSertif);
     s:=s+' '+ws;
     If Full[0]<>#0 Then
     Writeln(txt,Space+GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+'      '+Full+
       GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);

     Writeln(txt,Space+GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+s+
       GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]+
        +GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]);
End;
End;
    End;


   WriteLn(txt,Space+'                                                   '+'"'+DayString[DayOfWeek(ToDay)]+
   '" '+TodayString(DateMask)+'('+Times+')');
   Writeln(txt,Space+
   GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
   '============================================================================'+
   '==============================================='+
   GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);
   Dispose(Lg,Done);
NoInfoMsg;

End;



Function TestRazdelA( E:PSuperMarketType):Boolean;
Var j:Byte;
    s : TMyString;
Begin
TestRazdelA:=False;
For j:=1 To E^.Dat.Amount Do
 Begin
   If TestPrilogenieAndGTD(1{False},E^.DAt.MarketElement[j].BazKod) Then
   Begin
    TestRazdelA:=True;
    Break;
   End;
 End;
End;



Function TestRazdelAPr( E:PPrihodType):Boolean;
Var j:Byte;
    s : TMyString;
Begin
TestRazdelAPr:=False;
For j:=1 To E^.Dat.Amount Do
 Begin
(*
   If StrToInt(Copy(E^.DAt.PrihodElement[j].BazKod,1,CRazdelKod)) in
      [0..29,55] Then{30-отечеств пиво}
{ If StrToReal(GetIdField(FLitr,E^.Dat.PrihodElement[j].BazKod))>0.0009 Then}
*)
    If TestPrilogenieAndGTD(1{False},E^.DAt.PrihodElement[j].BazKod) Then
   Begin
    TestRazdelAPr:=True;
    Break;
   End;
 End;
End;





{$IFDEF Pharm}
Procedure FormRazdelA(E:PSuperMarketType;Var Txt:Text;Zakaz:Boolean);
Const Space=' ';
Var sh,l : Word;
    sm,s1,s2,s3,s4,s,ws : String;
    st : String[CMantissa];
    SDoc,SDate: String[CInputIZena];
    Rek1 :Rekwiziti;
    Lg : PSuperMarketType;
    k,j:Byte;
    OKPO : AllStr;
    Kto : String[CIZena];
    ZakazNumer,ZakazDate : AllStr;
    Count : Word;
    SAdr : AllStr;

Procedure SelAdress(Var SAdress:AllStr);
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
Begin
R.Assign(13, 9, 62, 12);
New(Dlg, Init(R, 'Адрес доставки груза'));
Dlg^.HelpCtx:=$E002;

R.Assign(1, 1, 48, 2);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetDAta(SAdress);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetDAta(SAdress);
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
End;


Begin
DInfoMsg('Формирую приложения к ГТД/ТТН. Ждите...',True);

{$IFNDEF Tabak}
   If E^.Dat.DocSelector in [2,3,4,5,6,7,8] Then Rek1:=RekSF^.Dat
   Else Rek1:=Rek^.Dat;
{$ELSE}
   If E^.Dat.DocSelector in [3,4,6,8] Then Rek1:=RekSF^.Dat
   Else Rek1:=Rek^.Dat;
{$ENDIF}

   Count:=0;
   Format(Rek1.NAme,CAll);
   Format(Rek1.Adress,CAll);
   Format(Rek1.AdressGruza,CAll);
   Format(Rek1.INN,CIZena);

   OKPO:=Rek1.OKPO;

   Format(OKPO,20);
   Format(Rek1.OKPO,{CAll}20);
   Format(Rek1.LizensiaOPTL_V,CAll);
   Format(Rek1.LizensiaRoznL_V,CAll);
   Format(Rek1.Organ,CAll);
   Format(Rek1.Director,CKto);
   Format(Rek1.Telefon,CAll);
   New(Lg,Init);
   k:=1;j:=1;

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

    DelSpace(E^.DAt.FromZakaz);
    DelSpace(E^.DAt.Document);

(*
if Zakaz then
Begin
    If E^.DAt.Oformlenie=1 Then
    Begin
      SDoc[0]:=#0;
      E^.DAt.DateC:=DateToDAteString(DateMask,
         DateStringToDate(DateMask,
         GetZakazDate(E^.DAt.FromZakaz,FieldDate))+
         StrToInt(GetZakazDate(E^.DAt.FromZakaz,FieldSrok)));
    End
    Else SDoc:=E^.DAt.Document;
End
 Else
  Begin
   SDoc:=E^.DAt.Document;
  End;
    Format(SDoc,8);
*)
   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   SDoc[0]:=#0;

If Not Zakaz Then
Begin
   (*отключено из-за проблем с бухгалтерией 26/03/01*)
{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer;
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
    End
    Else
     Begin
      ZakazDate:=E^.Dat.DateC;
      ZakazNumer:=E^.Dat.Document;
      DelSpace(ZakazNumer);
     End;
End
   Else
    Begin
      ZakazDate:=E^.Dat.DateC;
      ZakazNumer:=E^.Dat.Document;
    End;
End
Else
    Begin
     {ZakazNumer:=E^.DAt.FromZakaz;}
     ZakazNumer:=E^.DAt.Document{FromZakaz};
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer;
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
    End;


    SDoc:=ZakazNumer;
    Format(SDoc,8);


sAdr:=GetClientField(FAdressF,E^.Dat.ClientKod,E^.Dat.OperatorSelector);

If FindParam('/CHANGEADRESS') Or (ChangeAdress=1) Then
 Begin
  SelAdress(SAdr);
 End;

Format(sAdr,CAll);

    Str(StrToInt(E^.Dat.SkladKod):COne,E^.Dat.SkladKod);

Write(txt,GlobalPrn^.Dat.DopIni[Nprint^.DAt.Printer]);
sh:=0;
For l:=1 To Lg^.Dat.Amount Do
Begin
Str(StrToInt(Lg^.Dat.MarketElement[l].Input.Kol):CKol,Lg^.Dat.MarketElement[l].Input.Kol);
(*
If StrToInt(Copy(Lg^.DAt.MarketElement[l].BazKod,1,CRazdelKod)) in
      [0..29,55] Then{30-отечеств пиво}*)
If TestPrilogenieAndGTD(1{False},Lg^.DAt.MarketElement[l].BazKod) Then
{If StrToReal(GetIdField(FLitr,Lg^.Dat.MarketElement[l].BazKod))>0.0009 Then}
Begin
s1:=GetPostField(FPost,GetIDField(FPost,Lg^.DAt.MarketElement[l].BazKod));
DelSpace(s1);
If UpCAses(S1)='РОССИЯ' Then
Begin

s:=GetIdField(FFFName,Lg^.Dat.MarketElement[l].BazKod);
s:=s+'  ('+Lg^.Dat.MarketElement[l].BazKod+')';
Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);

{2}Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────────────────');

{3}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
'Справка к товарно транспортной накладной'+'      Раздел "Б"'+{Mih Nik}
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
{4}Writeln(txt,Space+'Наименование организации-продавца             Наименование организации-покупателя');
{5}Writeln(txt,Space+'Юридический адрес, адрес поставки             Юридический адрес, адрес поставки');
s:=GetClientField(FFullClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CAll);
{6}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Name+' '+S+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]);
s:=GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CAll);
{7}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Adress+' '+S+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

{7}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.AdressGruza+' '+Sadr+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
{8}Writeln(txt,Space+'Номер лицензии, орган ее выдавший             Номер лицензии, орган ее выдавший');
s:=GetClientField(FEnvir,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CAll);
{
If E^.Dat.OperatorSelector in [0,1,5,7] Then
Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.LizensiaRoznL_V+' '+S+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
Else
}
{9}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.LizensiaOPTL_V+' '+S+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
s:=GetClientField(FKto,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CAll);
{10}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Organ+' '+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

s:=GetClientField(FINN,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CIZena);
{11}Writeln(txt,Space+'ИНН налогоплательщика '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.INN+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
        +'         ИНН налогоплательщика '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

s:=GetClientField(FOKPO,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,{CAll}20);

{12}Writeln(txt,Space+'Код ОКПО '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.OKPO+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
+'                 Код ОКПО '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

{Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.OKPO+' '+S+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);}

{13}Writeln(txt,Space+'Количество продукции в (бут) '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
Lg^.Dat.MarketElement[l].Input.Kol+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
      '            Количество продукции в (бут) '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
        Lg^.Dat.MarketElement[l].Input.Kol+
         GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
{
s:=GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod);
Format(s,CName);
s:=s+'       ('+Lg^.Dat.MarketElement[l].BazKod+')     ';
Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+' '+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);

s:=GetIdField(FName2,Lg^.Dat.MarketElement[l].BazKod);
DelSpaceRight(s);
If s[0]<>#0 Then
Begin
Format(s,CName);
s:=s+'                   ';
Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+' '+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
End;
}
{1234567890123456789012345 (12345)             1234567890123456789012345 (12345)}
{14}
Writeln(txt,Space+'Маркировка продукции спец.марками (коды)      Маркировка продукции спец.марками (коды)');

If MarketSD=1 Then
GetBazSpecMarka4(Lg^.Dat.MarketElement[l].BazKod,s1,s2,s3,s4)
Else
 Begin
  sm:=GetSpecMarkaField(FSpecMarka,Lg^.Dat.MarketElement[l].Input.SMarkaKod);
  FormSpecMarka4(Sm,S1,S2,S3,S4);
 End;

Inc(Count,14);

DelSpaceRight(s1);
If s1[0]<>#0  Then
Begin
Format(s1,CNSertif);
Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s1+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+'      '+
                  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s1+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
Inc(Count,1);
End;

DelSpaceRight(s2);
If s2[0]<>#0  Then
Begin
Format(s2,CNSertif);
Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s2+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]++'      '+
                  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s2+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
Inc(Count,1);
End;

DelSpaceRight(s3);
If s3[0]<>#0  Then
Begin
Format(s3,CNSertif);
Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s3+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]++'      '+
                  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s3+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
Inc(Count,1);
End;

DelSpaceRight(s4);
If s4[0]<>#0  Then
Begin
Format(s4,CNSertif);
Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s4+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]++'      '+
                  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s4+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
Inc(Count,1);
End;



Format(ZakazDate,CDAte);
{19}Writeln(txt,Space+'Дата отгрузки: '+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ZakazDate{E^.Dat.DateC}+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
'  N ТТН:'+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
SDoc+'/'+E^.Dat.SkladKod+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
'     Дата отгрузки: '+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
ZakazDate{E^.Dat.DateC}+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
'  N ТТН:'+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+SDoc+'/'+E^.Dat.SkladKod+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);

Inc(Count,1);

If StrToInt(GetIDField(FEnableContract,Lg^.Dat.MarketElement[l].BazKod))=1 Then
Begin
Inc(Count,1);
{20}Writeln(txt,Space+'Договор с поставщиком (серийное производство) Договор с поставщиком (серийное производство)');
s:=GetIDField(FContractNumer,Lg^.Dat.MarketElement[l].BazKod);
DelSpace(s);
RFormat(s,CContract);
s1:=GetIDField(FContractDate,Lg^.Dat.MarketElement[l].BazKod);
RFormat(s1,CDate);
Inc(Count,1);
{21}Writeln(txt,Space+'N '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' от '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
'                    '+'N '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' от '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
End;               {N 123456 от 12-12-12                  N}

Kto:=Rek1.Cladovshik;
Format(Kto,20{CIZena});
{22}Writeln(txt,Space+'Должность ФИО Зав.складом '+Kto+'Должность ФИО                М.П.');
{23}Writeln(txt,Space+'отправителя                  М.П.             покупателя                   Подпись');
{24}Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────────────────');
Inc(Count,3);

End
 Else
  Begin {Вариант ГТД}

s:=GetIdField(FFFName,Lg^.Dat.MarketElement[l].BazKod);
s:=s+'  ('+Lg^.Dat.MarketElement[l].BazKod+')';
{1}Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);

{2}Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────────────────');

If MarketSD=1 Then
s1:=BakGetField(FNGTD,Lg^.DAt.MarketElement[l].BazKod,0)
Else
s1:=GetNGTDField(FNGTD,Lg^.DAt.MarketElement[l].Input.NGTDKod);

DelSpaceRight(s1);
Format(s1,CName);
{3}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
'Приложение к справке ГТД N'+s1+' Раздел "Б"'+{Mih Nik}
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
{4}Writeln(txt,Space+'Наименование организации-продавца             Наименование организации-покупателя');
s:=GetClientField(FFullClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CAll);
{5}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Name+' '+S+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

s:=GetClientField(FINN,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
{
Format(s,CIZena);
Writeln(txt,Space+'ИНН налогоплательщика '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.INN+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
        +'         ИНН налогоплательщика '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+GlobalPrn^.Dat.NoItalic
          [Nprint^.DAt.Printer]);
}

{6}Writeln(txt,Space+'Идентификационный номер '+{GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.INN+GlobalPrn^.Dat.
NoItalic[Nprint^.DAt.Printer]+}
      +'                      Идентификационный номер ' {GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+GlobalPrn^.Dat.
        NoItalic[Nprint^.DAt.Printer]});

{7}Writeln(txt,Space+'налогоплательщика-продавца '+
      +'                   налогоплательщика-покупателя ');

{8}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.INN+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
      +'                                                  '+
           GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
{9}Writeln(txt,Space);
{10}Writeln(txt,Space+'М.П                                           '+
                 +'М.П');
{11}Writeln(txt,Space);
{$IfNDEF Pharm}
{12}Writeln(txt,Space+'Руководитель организации '+Rek1.Director+' Подпись '+
                 +'Руководитель организации        Подпись');
{$ELSE}
{12}Writeln(txt,Space+'Руководитель организации        Подпись       '+
                 +'Руководитель организации        Подпись');
{$ENDIF}
{13}Writeln(txt,Space);
{14}Writeln(txt,Space);

{15}Writeln(txt,Space+'Дата : '+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ZakazDate{E^.Dat.DateC}+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
+'                               Дата : '+
GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ZakazDate+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
{16}Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────────────────');
Inc(Count,16);

  End;
Inc(sh);

If sh=4 Then
 Begin
  If L<Lg^.DAt.Amount Then
  Writeln(txt,GlobalPrn^.Dat.EndPage[Nprint^.DAt.Printer]);
  Sh:=0;
 End;

End;{}
End;
Writeln(txt,Space+'===============================================');
Dispose(Lg,Done);
NoInfoMsg;
End;

{$ELSE}

{вариант ТС}

Procedure FormRazdelA(E:PSuperMarketType;Var Txt:Text;Zakaz:Boolean);
Const Space=' ';
Var c,sh,l : Word;
    sm,s1,s2,s22,s3,s4,s,ws : String;
    st : String[CMantissa];
    SDoc,SDate: String[CInputIZena];
    txt2 : Text;
    Rek1 :Rekwiziti;
    Lg : PSuperMarketType;
    k,j:Byte;
    OKPO : AllStr;
    Kto : String[CIZena];
    ZakazNumer,ZakazDate : AllStr;
    Count : Word;
    SAdr,sKOlLitr : AllStr;
    Base : DBase3;
    First : Boolean;

Procedure SelAdress(Var SAdress:AllStr);
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
Begin
R.Assign(13, 9, 62, 12);
New(Dlg, Init(R, 'Адрес доставки груза'));
Dlg^.HelpCtx:=$E002;

R.Assign(1, 1, 48, 2);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetDAta(SAdress);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetDAta(SAdress);
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
End;


Begin
DInfoMsg('Формирую приложения к ГТД/ТТН. Ждите...',True);

{$IFNDEF Tabak}
   If E^.Dat.DocSelector in [2,3,4,5,6,7,8] Then Rek1:=RekSF^.Dat
   Else Rek1:=Rek^.Dat;
{$ELSE}
   If E^.Dat.DocSelector in [3,4,6,8] Then Rek1:=RekSF^.Dat
   Else Rek1:=Rek^.Dat;
{$ENDIF}

   Count:=0;
   Format(Rek1.NAme,CAll);
   Format(Rek1.Adress,CAll);
   Format(Rek1.AdressGruza,CAll);
   Format(Rek1.INN,CAll);

   OKPO:=Rek1.OKPO;

   Format(OKPO,20);
   Format(Rek1.OKPO,{CAll}20);
   Format(Rek1.LizensiaOPTL_V,CAll);
   Format(Rek1.LizensiaRoznL_V,CAll);
   Format(Rek1.Organ,CAll);
   Format(Rek1.Director,CKto);
   Format(Rek1.Telefon,CAll);
   New(Lg,Init);
   k:=1;j:=1;

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

    DelSpace(E^.DAt.FromZakaz);
    DelSpace(E^.DAt.Document);

   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   SDoc[0]:=#0;


 Assign(txt2,Path^.Dat.ToTemp+'Zennik.ini');
 l:=Ioresult;
 Rewrite(txt2);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfoMsg;
   DIspose(Lg,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'zennik.ini'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(txt2,'[COMMON]');
 Writeln(txt2,'PathToReport='+Path^.Dat.ToUtils);
 Writeln(txt2,'PathToTable='+Path^.Dat.ToTemp);
 Writeln(txt2,'PathToPhoto='+Path^.Dat.ToPhoto);
 Writeln(txt2,'PathToPrinter='+NetworkPrinters);
 Writeln(txt2,'ShowDialog=',ShowDialogPrint);
 Writeln(txt2,'PrintOGTD=',PrintOGTD);
 Writeln(txt2,'PrintOPhoto=',PrintOPhoto);
 Writeln(txt2,'TableName=Spravka');
 Writeln(txt2,'PathToTMPDir='+Path^.Dat.ToTemp+'sleep.txt');

 Writeln(txt2,'Vid=',5:2);{0-большой 1-маленький 2-с двумя ценами 3-пустой бланк
 5- Гтд и (или) сертификат}

 l:=Ioresult;
 Close(txt2);
 l:=Ioresult;



with Base do
begin
 Assign(Path^.Dat.ToTemp+'Spravka.dbf'); {пpисвоить БД имя}
 Init; {подготовиться к созданию БД}
       ADDField('ORG','C',100,0);
       ADDField('ADRESS','C',100,0);
       ADDField('ADR_GRO','C',100,0);
       ADDField('CLIENT','C',100,0);
       ADDField('CLIENT_A','C',100,0);
       ADDField('CLIENT_F','C',100,0);
       ADDField('CLIENT_E','C',100,0);
       ADDField('CLIENT_O','C',100,0);
       ADDField('CLIENT_S','C',15,0);
       ADDField('LIZENC','C',100,0);
       ADDField('ORGAN','C',100,0);
       ADDField('REK_INN','C',25,0);
       ADDField('CL_INN','C',25,0);
       ADDField('CL_KPP','C',25,0);
       ADDField('TOV_NAME','C',55,0);
       ADDField('KOD_TOV','C',5,0);
       ADDField('KOD_S','C',5,0);
       ADDField('KOL','C',15,0);
       ADDField('MARKA1','C',100,0);
       ADDField('MARKA2','C',100,0);
       ADDField('MARKA3','C',100,0);
       ADDField('MARKA4','C',100,0);
       ADDField('TTN','C',15,0);
       ADDField('DATE','C',15,0);
       ADDField('KTO','C',15,0);

   if Create then Open(ReadWrite)
   else
     begin
      NoInfoMsg;
      Dispose(Lg,Done);
      MessageBox(^M+#3+'Ошибка создания '+Path^.Dat.ToTemp+'Spravka.dbf!',Nil,mfError+mfCancelButton);
      exit;
     end;

c:=IOResult;
     Close;
c:=IOResult;
End;{With Base}



 Base.Assign(Path^.Dat.ToTemp+'Spravka.dbf');
 c:=IOResult;
 Base.Open(ReadWrite);
 c:=IOResult;
 If c<>0 Then
  Begin
   NoInfoMsg;
   Dispose(Lg,Done);
   MessageBox(^M+#3+'Ошибка открытия '+Path^.Dat.ToTemp+'Spravka.dbf!',Nil,mfError+mfCancelButton);
   Exit;
  End;




If Not Zakaz Then
Begin
(*отключено из-за проблем с бухгалтерией 26/03/01*)
{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer;
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
    End
    Else
     Begin
      ZakazDate:=E^.Dat.DateC;
      ZakazNumer:=E^.Dat.Document;
      DelSpace(ZakazNumer);
     End;
End
   Else
    Begin
      ZakazDate:=E^.Dat.DateC;
      ZakazNumer:=E^.Dat.Document;
    End;
End
Else
    Begin
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer;
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
    End;


    SDoc:=ZakazNumer;
    Format(SDoc,8);


sAdr:=GetClientField(FAdressF,E^.Dat.ClientKod,E^.Dat.OperatorSelector);

If FindParam('/CHANGEADRESS') Or (ChangeAdress=1) Then
 Begin
  SelAdress(SAdr);
 End;

Format(sAdr,CAll);




    Str(StrToInt(E^.Dat.SkladKod):COne,E^.Dat.SkladKod);

Write(txt,GlobalPrn^.Dat.DopIni[Nprint^.DAt.Printer]);


{настраиваем разреженный интервал новой схемы печати ГТД}
If NPrint^.Dat.ShemaPrilB=1 Then
Write(txt,GlobalPrn^.Dat.MinInterval4[Nprint^.DAt.Printer]);


sh:=0;
First:=False;
For l:=1 To Lg^.Dat.Amount Do
Begin
Str(StrToInt(Lg^.Dat.MarketElement[l].Input.Kol):CKol,Lg^.Dat.MarketElement[l].Input.Kol);
(*
If StrToInt(Copy(Lg^.DAt.MarketElement[l].BazKod,1,CRazdelKod)) in
      [0..29,55] Then{30-отечеств пиво}*)
If TestPrilogenieAndGTD(1{False},Lg^.DAt.MarketElement[l].BazKod) Then
{If StrToReal(GetIdField(FLitr,Lg^.Dat.MarketElement[l].BazKod))>0.0009 Then}
Begin
  s1:=GetPostField(FPost,GetIDField(FPost,Lg^.DAt.MarketElement[l].BazKod));
  DelSpace(s1);
 If UpCAses(S1)='РОССИЯ' Then
 Begin


   If NPrint^.Dat.ShemaPrilB=1 Then
    Begin
     If First Then
     Writeln(txt,GlobalPrn^.Dat.EndPage[Nprint^.DAt.Printer]);
    End;

First:=True;


s:=GetIdField(FFFName,Lg^.Dat.MarketElement[l].BazKod);
s:=s+'  ('+Lg^.Dat.MarketElement[l].BazKod+')';
Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);

{2}Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────────────────');

{3}Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
'Справка к товарно-транспортной накладной'+'                             Раздел "Б"'+{Mih Nik}
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
{Все перекурочено - Пост Прав РФ от 31 дек 2005 г 864 Михник }
Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
'на этиловый спирт, алкогольную и спиртосодержащую продукцию'+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]
+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);

{4}Writeln(txt,Space+'Наименование организации-продавца             Наименование организации-покупателя');

{5}Writeln(txt,Space+'Адрес места нахождения,адрес поставки         Адрес места нахождения,адрес поставки');
s:=GetClientField(FFullClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CAll);
{6}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Name+' '+S+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]);
s:=GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CAll);
{7}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Adress+' '+S+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

{7}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.AdressGruza+' '+Sadr+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

{8}Writeln(txt,Space+'Номер лицензии,орган ее выдавший,дата выдачи  Номер лицензии,орган ее выдавший,дата выдачи');
s:=GetClientField(FEnvir,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CAll);
{
If E^.Dat.OperatorSelector in [0,1,5,7] Then
Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.LizensiaRoznL_V+' '+S+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.
Printer])
Else
}
{9}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.LizensiaOPTL_V+' '+S+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
s:=GetClientField(FKto,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CAll);
{10}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Organ+' '+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

s:=GetClientField(FINN,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CIZena);
s22:=GetClientField(FKPP,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s22,CIZena);
{11}Writeln(txt,Space+'ИНН '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.INN+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
        +' ИНН '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' КПП '+
		GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s22+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

(*s:=GetClientField(FOKPO,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,{CAll}20);

{12}Writeln(txt,Space+'Код ОКПО '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.OKPO+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
+'                 Код ОКПО '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);*)

{Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.OKPO+' '+S+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);}

sKOlLitr:=GetIdField(FLitr,Lg^.Dat.MarketElement[l].BazKod);
MyStr(StrToReal(sKOlLitr)*StrToReal(Lg^.Dat.MarketElement[l].Input.Kol)/10,CZena,CLitrMantissa,
sKOlLitr);
{13}Writeln(txt,Space+'Количество продукции(дал/бут)'+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+

sKOlLitr+'/'+Lg^.Dat.MarketElement[l].Input.Kol+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
      '   Количество продукции(дал/бут)'+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
        sKOlLitr+'/'+Lg^.Dat.MarketElement[l].Input.Kol+
         GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
{
s:=GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod);
Format(s,CName);
s:=s+'       ('+Lg^.Dat.MarketElement[l].BazKod+')     ';
Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+' '+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);

s:=GetIdField(FName2,Lg^.Dat.MarketElement[l].BazKod);
DelSpaceRight(s);
If s[0]<>#0 Then
Begin
Format(s,CName);
s:=s+'                   ';
Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+' '+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
End;
}
{1234567890123456789012345 (12345)             1234567890123456789012345 (12345)}
{14}
Writeln(txt,Space+
'Маркировка продукции федеральными специаль-   Маркировка продукции федеральными специаль-');
Writeln(txt,Space+'ными марками (разряд и номер федеральных      ными марками (разряд и номер федеральных');
Writeln(txt,Space+'специальных марок)                            специальных марок)');
   If MarketSD=1 Then
    GetBazSpecMarka4(Lg^.Dat.MarketElement[l].BazKod,s1,s2,s3,s4)
    Else
     Begin
      sm:=GetSpecMarkaField(FSpecMarka,Lg^.Dat.MarketElement[l].Input.SMarkaKod);
      FormSpecMarka4(Sm,S1,S2,S3,S4);
     End;

Inc(Count,14);

DelSpaceRight(s1);
   If s1[0]<>#0  Then
    Begin
     Format(s1,CNSertif);
     Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s1+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+'      '+
                  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s1+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
     Inc(Count,1);
    End;

    DelSpaceRight(s2);
    If s2[0]<>#0  Then
    Begin
     Format(s2,CNSertif);
     Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s2+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]++'      '+
                  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s2+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
     Inc(Count,1);
    End;

DelSpaceRight(s3);
    If s3[0]<>#0  Then
     Begin
      Format(s3,CNSertif);
      Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s3+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]++'      '+
                  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s3+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
      Inc(Count,1);
     End;

DelSpaceRight(s4);
    If s4[0]<>#0  Then
     Begin
      Format(s4,CNSertif);
      Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s4+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]++'      '+
                   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s4+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
      Inc(Count,1);
     End;



Format(ZakazDate,CDAte);
{19}Writeln(txt,Space+'Дата отгрузки: '+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ZakazDate{E^.Dat.DateC}+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
'  N ТТН:'+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
SDoc+'/'+E^.Dat.SkladKod+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
'     Дата отгрузки: '+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
ZakazDate{E^.Dat.DateC}+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
'  N ТТН:'+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+SDoc+'/'+E^.Dat.SkladKod+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);

Inc(Count,1);

(*If StrToInt(GetIDField(FEnableContract,Lg^.Dat.MarketElement[l].BazKod))=1 Then
Begin
Inc(Count,1);
{20}Writeln(txt,Space+'Договор с поставщиком (серийное производство) Договор с поставщиком (серийное производство)');
s:=GetIDField(FContractNumer,Lg^.Dat.MarketElement[l].BazKod);
DelSpace(s);
RFormat(s,CContract);
s1:=GetIDField(FContractDate,Lg^.Dat.MarketElement[l].BazKod);
RFormat(s1,CDate);
Inc(Count,1);
{21}Writeln(txt,Space+'N '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' от '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
'                    '+'N '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' от '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
End;               {N 123456 от 12-12-12                  N}
*)
Kto:=Rek1.Cladovshik;
Format(Kto,20{CIZena});
{22}Writeln(txt,Space+'ФИО Должность '+Kto+'Ст.специал. ФИО Должность                 М.П.');
{23}Writeln(txt,Space+'уполн.лица организации-продавца         М.П.  уполн.лица организации-покупателя подпись');
{24}Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────────────────');
Inc(Count,3);
Inc(sh);

     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteSTR('ORG',Rek1.Name);{Код объекта откуда происходит реализация}
       WriteSTR('ADRESS',Rek1.Adress);
       WriteSTR('ADR_GRO',Rek1.AdressGruza);
       WriteSTR('CLIENT',GetClientField(FFullClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector));
       WriteSTR('CLIENT_A',GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector));
       WriteSTR('CLIENT_F',GetClientField(FAdressF,E^.Dat.ClientKod,E^.Dat.OperatorSelector));
       WriteSTR('CLIENT_E',GetClientField(FENVIR,E^.Dat.ClientKod,E^.Dat.OperatorSelector));
       WriteSTR('CLIENT_O',GetClientField(FKto,E^.Dat.ClientKod,E^.Dat.OperatorSelector));
       WriteSTR('CLIENT_S',GetClientField(FSrok,E^.Dat.ClientKod,E^.Dat.OperatorSelector));
       WriteSTR('LIZENC',Rek1.LizensiaOPTL_V);
       WriteSTR('ORGAN',Rek1.Organ);
       WriteSTR('REK_INN',Rek1.INN);
{       WriteSTR('REK_KPP',Rek1.KPP);}
       WriteSTR('CL_INN',GetClientField(FINN,E^.Dat.ClientKod,E^.Dat.OperatorSelector));
       WriteSTR('CL_KPP',GetClientField(FKPP,E^.Dat.ClientKod,E^.Dat.OperatorSelector));
       WriteStr('TOV_NAME',GetIdField(FFFName,Lg^.Dat.MarketElement[l].BazKod));
       WriteStr('KOD_TOV',Lg^.Dat.MarketElement[l].BazKod);
       WriteStr('KOD_S',Lg^.Dat.MarketElement[l].Input.NSertif);
       WriteStr('KOL',sKOlLitr+'/'+Lg^.Dat.MarketElement[l].Input.Kol);
       WriteStr('MARKA1',s1);
       WriteStr('MARKA2',s2);
       WriteStr('MARKA3',s3);
       WriteStr('MARKA4',s4);
       WriteStr('TTN',SDoc+'/'+E^.Dat.SkladKod);
       WriteStr('DATE',ZakazDate);
       WriteStr('KTO',Rek1.Cladovshik);

      End;{With}



End{РОССИЯ}
   Else
   Begin
     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteSTR('ORG','');{Код объекта откуда происходит реализация}
       WriteSTR('ADRESS','');
       WriteSTR('ADR_GRO','');
       WriteSTR('CLIENT','');
       WriteSTR('CLIENT_A','');
       WriteSTR('CLIENT_F','');
       WriteSTR('CLIENT_E','');
       WriteSTR('CLIENT_O','');
       WriteSTR('CLIENT_S','');
       WriteSTR('LIZENC','');
       WriteSTR('ORGAN','');
       WriteSTR('REK_INN','');
{       WriteSTR('REK_KPP',Rek1.KPP);}
       WriteSTR('CL_INN','');
       WriteSTR('CL_KPP','');
       WriteStr('TOV_NAME','');
       WriteStr('KOD_TOV',Lg^.Dat.MarketElement[l].BazKod);
       WriteStr('KOD_S',Lg^.Dat.MarketElement[l].Input.NSertif);
       WriteStr('KOL','');
       WriteStr('MARKA1','');
       WriteStr('MARKA2','');
       WriteStr('MARKA3','');
       WriteStr('MARKA4','');
       WriteStr('TTN','');
       WriteStr('DATE','');
       WriteStr('KTO','');
      End;{With}
   End;




(*  участок печати ГТДвыключен 04/09/2003 по просьбе Гончарова Олейника и Тесова
 Else
  Begin {Вариант ГТД}

s:=GetIdField(FFFName,Lg^.Dat.MarketElement[l].BazKod);
s:=s+'  ('+Lg^.Dat.MarketElement[l].BazKod+')';
{1}Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);

{2}Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────────────────');

If MarketSD=1 Then
s1:=BakGetField(FNGTD,Lg^.DAt.MarketElement[l].BazKod,0)
Else
s1:=GetNGTDField(FNGTD,Lg^.DAt.MarketElement[l].Input.NGTDKod);


DelSpaceRight(s1);
Format(s1,CName);
{3}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
'Приложение к справке ГТД N'+s1+' Раздел "Б"'+{Mih Nik}
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
{4}Writeln(txt,Space+'Наименование организации-продавца             Наименование организации-покупателя');
s:=GetClientField(FFullClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CAll);
{5}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Name+' '+S+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

s:=GetClientField(FINN,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
{
Format(s,CIZena);
Writeln(txt,Space+'ИНН налогоплательщика '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.INN+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
        +'         ИНН налогоплательщика '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
}

{6}Writeln(txt,Space+'Идентификационный номер '+{GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.INN+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+}
      +'                      Идентификационный номер ' {GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
        GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]});

{7}Writeln(txt,Space+'налогоплательщика-продавца '+
      +'                   налогоплательщика-покупателя ');

{8}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.INN+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
      +'                                                  '+
           GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
{9}Writeln(txt,Space);
{10}Writeln(txt,Space+'М.П                                           '+
                 +'М.П');
{11}Writeln(txt,Space);
{$IfNDEF Pharm}
{12}Writeln(txt,Space+'Руководитель организации '+Rek1.Director+' Подпись '+
                 +'Руководитель организации        Подпись');
{$ELSE}
{12}Writeln(txt,Space+'Руководитель организации        Подпись       '+
                 +'Руководитель организации        Подпись');
{$ENDIF}
{13}Writeln(txt,Space);
{14}Writeln(txt,Space);

{15}Writeln(txt,Space+'Дата : '+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ZakazDate{E^.Dat.DateC}+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
+'                               Дата : '+
GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ZakazDate+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
{16}Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────────────────');
Inc(Count,16);

  End;
*)




If NPrint^.Dat.ShemaPrilB=0 Then
Begin
If sh=4 Then
 Begin
  If L<Lg^.DAt.Amount Then
  Writeln(txt,GlobalPrn^.Dat.EndPage[Nprint^.DAt.Printer]);
  Sh:=0;
 End;
End






End{ TestPrilogenieGTD}
  Else
   Begin
     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteSTR('ORG','');{Код объекта откуда происходит реализация}
       WriteSTR('ADRESS','');
       WriteSTR('ADR_GRO','');
       WriteSTR('CLIENT','');
       WriteSTR('CLIENT_A','');
       WriteSTR('CLIENT_F','');
       WriteSTR('CLIENT_E','');
       WriteSTR('CLIENT_O','');
       WriteSTR('CLIENT_S','');
       WriteSTR('LIZENC','');
       WriteSTR('ORGAN','');
       WriteSTR('REK_INN','');
{       WriteSTR('REK_KPP',Rek1.KPP);}
       WriteSTR('CL_INN','');
       WriteSTR('CL_KPP','');
       WriteStr('TOV_NAME','');
       WriteStr('KOD_TOV',Lg^.Dat.MarketElement[l].BazKod);
       WriteStr('KOD_S',Lg^.Dat.MarketElement[l].Input.NSertif);
       WriteStr('KOL','');
       WriteStr('MARKA1','');
       WriteStr('MARKA2','');
       WriteStr('MARKA3','');
       WriteStr('MARKA4','');
       WriteStr('TTN','');
       WriteStr('DATE','');
       WriteStr('KTO','');
      End;{With}
   End;

End;{For}
If First Then Writeln(txt,Space+'===============================================');
Dispose(Lg,Done);

c:=IOResult;
 Base.Close;{закрытие DBF}
c:=IOResult;

NoInfoMsg;
End;

(*
Procedure FormRazdelA(E:PSuperMarketType;Var Txt:Text;Zakaz:Boolean);
Const Space=' ';
Var sh,l : Word;
    sm,s1,s2,s3,s4,s,ws : String;
    st : String[CMantissa];
    SDoc,SDate: String[CInputIZena];
    Rek1 :Rekwiziti;
    Lg : PSuperMarketType;
    k,j:Byte;
    OKPO : AllStr;
    Kto : String[CIZena];
    ZakazNumer,ZakazDate : AllStr;
    Count : Word;
    SAdr : AllStr;

Procedure SelAdress(Var SAdress:AllStr);
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
Begin
R.Assign(13, 9, 62, 12);
New(Dlg, Init(R, 'Адрес доставки груза'));
Dlg^.HelpCtx:=$E002;

R.Assign(1, 1, 48, 2);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetDAta(SAdress);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetDAta(SAdress);
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
End;


Begin
DInfoMsg('Формирую приложения к ГТД/ТТН. Ждите...',True);

{$IFNDEF Tabak}
   If E^.Dat.DocSelector in [2,3,4,5,6,7,8] Then Rek1:=RekSF^.Dat
   Else Rek1:=Rek^.Dat;
{$ELSE}
   If E^.Dat.DocSelector in [3,4,6,8] Then Rek1:=RekSF^.Dat
   Else Rek1:=Rek^.Dat;
{$ENDIF}

   Count:=0;
   Format(Rek1.NAme,CAll);
   Format(Rek1.Adress,CAll);
   Format(Rek1.AdressGruza,CAll);
   Format(Rek1.INN,CIZena);

   OKPO:=Rek1.OKPO;

   Format(OKPO,20);
   Format(Rek1.OKPO,{CAll}28);
   Format(Rek1.LizensiaOPTL_V,CAll);
   Format(Rek1.LizensiaRoznL_V,CAll);
   Format(Rek1.Organ,CAll);
   Format(Rek1.Director,CKto);
   Format(Rek1.Telefon,CAll);
   New(Lg,Init);
   k:=1;j:=1;

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

    DelSpace(E^.DAt.FromZakaz);
    DelSpace(E^.DAt.Document);

   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   SDoc[0]:=#0;

If Not Zakaz Then
Begin
{вариант для доставки-вино}
If ZakazShema=0 Then
Begin
   If E^.Dat.Oformlenie=1 Then
    Begin
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer;
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
    End
    Else
     Begin
      ZakazDate:=E^.Dat.DateC;
      ZakazNumer:=E^.Dat.Document;
      DelSpace(ZakazNumer);
     End;
End
   Else
    Begin
      ZakazDate:=E^.Dat.DateC;
      ZakazNumer:=E^.Dat.Document;
    End;
End
Else
    Begin
     ZakazNumer:=E^.DAt.FromZakaz;
     DelSpace(ZakazNumer);
     ZakazNumer:='ЗЛ '+ZakazNumer;
     ZakazDate:=GetZakazDate(E^.DAt.FromZakaz,FieldEndDate);
     If ZakazDate='' Then ZakazDate:=E^.Dat.DateC;
    End;


    SDoc:=ZakazNumer;
    Format(SDoc,8);


sAdr:=GetClientField(FAdressF,E^.Dat.ClientKod,E^.Dat.OperatorSelector);

If FindParam('/CHANGEADRESS') Or (ChangeAdress=1) Then
 Begin
  SelAdress(SAdr);
 End;

Format(sAdr,CAll);




    Str(StrToInt(E^.Dat.SkladKod):COne,E^.Dat.SkladKod);

Write(txt,GlobalPrn^.Dat.DopIni[Nprint^.DAt.Printer]);
sh:=0;
For l:=1 To Lg^.Dat.Amount Do
Begin
Str(StrToInt(Lg^.Dat.MarketElement[l].Input.Kol):CKol,Lg^.Dat.MarketElement[l].Input.Kol);
If TestPrilogenieAndGTD(1{False},Lg^.DAt.MarketElement[l].BazKod) Then

Begin
s1:=GetPostField(FPost,GetIDField(FPost,Lg^.DAt.MarketElement[l].BazKod));
DelSpace(s1);
If UpCAses(S1)='РОССИЯ' Then
Begin

s:=GetIdField(FFFName,Lg^.Dat.MarketElement[l].BazKod);
s:=s+'  ('+Lg^.Dat.MarketElement[l].BazKod+')';
Writeln(txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);

{2}Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────────────────');
{3}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
'Справка к товарно транспортной накладной'+'      Раздел "Б"'+{Mih Nik}
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
{4}Writeln(txt,Space+'Наименование организации-продавца             Наименование организации-покупателя');
{5}Writeln(txt,Space+'Юридический адрес, адрес поставки             Юридический адрес, адрес поставки');
s:=GetClientField(FFullClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CAll);
{6}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Name+' '+S+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]);
s:=GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CAll);
{7}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Adress+' '+S+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

{7}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.AdressGruza+' '+Sadr+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
{8}Writeln(txt,Space+'Номер лицензии, орган ее выдавший             Номер лицензии, орган ее выдавший');
s:=GetClientField(FEnvir,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CAll);
{
If E^.Dat.OperatorSelector in [0,1,5,7] Then
Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.LizensiaRoznL_V+' '+S+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.
Printer])
Else
}
{9}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.LizensiaOPTL_V+' '+S+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
s:=GetClientField(FKto,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CAll);
{10}Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Organ+' '+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

s:=GetClientField(FINN,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,CIZena);
{11}Writeln(txt,Space+'ИНН налогоплательщика '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.INN+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
        +'         ИНН налогоплательщика '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

s:=GetClientField(FOKPO,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(s,{CAll}28);

{12}Writeln(txt,Space+'Код ОКПО '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.OKPO+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
+'         Код ОКПО '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

{Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.OKPO+' '+S+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);}

{13}Writeln(txt,Space+'Количество продукции в (бут) '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
Lg^.Dat.MarketElement[l].Input.Kol+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
      '            Количество продукции в (бут) '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
        Lg^.Dat.MarketElement[l].Input.Kol+
         GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
Writeln(txt,Space+'Маркировка продукции спец.марками (коды)      Маркировка продукции спец.марками (коды)');

If MarketSD=1 Then
GetBazSpecMarka4(Lg^.Dat.MarketElement[l].BazKod,s1,s2,s3,s4)
Else
 Begin
  sm:=GetSpecMarkaField(FSpecMarka,Lg^.Dat.MarketElement[l].Input.SMarkaKod);
  FormSpecMarka4(Sm,S1,S2,S3,S4);
 End;




Inc(Count,14);

DelSpaceRight(s1);
If s1[0]<>#0  Then
Begin
Format(s1,CNSertif);
Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s1+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+'      '+
                  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s1+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
Inc(Count,1);
End;

DelSpaceRight(s2);
If s2[0]<>#0  Then
Begin
Format(s2,CNSertif);
Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s2+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]++'      '+
                  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s2+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
Inc(Count,1);
End;

DelSpaceRight(s3);
If s3[0]<>#0  Then
Begin
Format(s3,CNSertif);
Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s3+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]++'      '+
                  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s3+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
Inc(Count,1);
End;

DelSpaceRight(s4);
If s4[0]<>#0  Then
Begin
Format(s4,CNSertif);
Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s4+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]++'      '+
                  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s4+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
Inc(Count,1);
End;



Format(ZakazDate,CDAte);
{19}Writeln(txt,Space+'Дата отгрузки: '+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+ZakazDate{E^.Dat.DateC}+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
'  N ТТН:'+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
SDoc+'/'+E^.Dat.SkladKod+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
'     Дата отгрузки: '+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
ZakazDate{E^.Dat.DateC}+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
'  N ТТН:'+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+SDoc+'/'+E^.Dat.SkladKod+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);

Inc(Count,1);

If StrToInt(GetIDField(FEnableContract,Lg^.Dat.MarketElement[l].BazKod))=1 Then
Begin
Inc(Count,1);
{20}Writeln(txt,Space+'Договор с поставщиком (серийное производство) Договор с поставщиком (серийное производство)');
s:=GetIDField(FContractNumer,Lg^.Dat.MarketElement[l].BazKod);
DelSpace(s);
RFormat(s,CContract);
s1:=GetIDField(FContractDate,Lg^.Dat.MarketElement[l].BazKod);
RFormat(s1,CDate);
Inc(Count,1);
{21}Writeln(txt,Space+'N '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' от '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
'                    '+'N '+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+' от '+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s1+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
End;               {N 123456 от 12-12-12                  N}

Kto:=Rek1.Cladovshik;
Format(Kto,20{CIZena});
{22}Writeln(txt,Space+'Должность ФИО Зав.складом '+Kto+'Должность ФИО                М.П.');
{23}Writeln(txt,Space+'отправителя                  М.П.             покупателя                   Подпись');
{24}Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────────────────');
Inc(Count,3);
Inc(sh);

End;

If sh=4 Then
 Begin
  If L<Lg^.DAt.Amount Then
  Writeln(txt,GlobalPrn^.Dat.EndPage[Nprint^.DAt.Printer]);
  Sh:=0;
 End;

End;{}
End;
Writeln(txt,Space+'===============================================');
Dispose(Lg,Done);
NoInfoMsg;
End;
*)

{$ENDIF}








Function TestFormPril( E:PSuperMarketType):Boolean;
Var l : Word;
    k,j : Byte;
    s,ws : String;
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
Begin
   TestFormPril:=False;
   New(Lg,Init);
   k:=1;j:=1;

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


   For l:=1 To Lg^.Dat.Amount Do
    Begin
         If TestPrilogenieAndGTD(0{True},Lg^.DAt.MarketElement[l].BazKod) Then
         Begin
          ws:={BakGetField(FSertif,}Lg^.DAt.MarketElement[l].Input.NSertif{BazKod{,0);};
          DelSpaceRight(ws);
          If (WS<>NoSertifStr) Then
                Begin
                 TestFormPril:=True;
                 Break;
                End;
         End;
         End;
 Dispose(Lg,Done);
End;


Function TestElementSpis (Const S : ArtikulStr;Const P : PBox;Const Sort:Word) : Boolean;
Var ls : Word;
    k  : Byte;
    st : String[CALL];
Begin
TestElementSpis:=False;
For ls :=0 To P^.List^.Count-1 Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
k:=Pos('│',St);
If Sort=1 Then
ST:=Copy(St,K+1,CRazdelKod) Else ST:=Copy(St,1,CRazdelKod);
If St=S Then
   Begin
    TestElementSpis:=True;
    Break;
   End;
End;
End;


Function TestSertif(E:PSuperMarketType;c:Word;NNN:ArtikulStr):Boolean;
Var j : Word;
Begin
TestSertif:=True;
If c<=1 Then Exit;

For j:=1 to (c-1) Do
 Begin
  if E^.Dat.MarketElement[j].Input.NSertif=NNN Then
   Begin
    TestSertif:=False;
    Break;
   End;
 End;

End;



(*
Procedure RunPrintPhoto(E:PSuperMarketType);
Var Event : TEvent;
    s1,s2,s3,s4 : String;
    c : Word;
    Cmd : Text;
Begin

If Not FExists(Path^.Dat.ToPhoto+'photo.exe') Then
 Begin
  MessageBox(NoExistsModul^+ClicProgrammer^,Nil,mfError+mfCancelButton);
  Exit;
 End;

 s1[0]:=#0;
 s2[0]:=#0;
 s3[0]:=#0;
 s4[0]:=#0;

{$IFDEF Pharm}
DInfoMsg('Формирую список фотографий...',False);
 For c:=1 To E^.Dat.Amount Do
  Begin
   If (E^.Dat.MarketElement[c].Input.NSertif<>NoSertifStr) And
      TestSertif(E,c,E^.Dat.MarketElement[c].Input.NSertif) Then
   Begin
     If ord(s1[0])<150 Then s1:=s1+E^.Dat.MarketElement[c].Input.NSertif+'.* '
     Else
     If ord(s2[0])<150 Then s2:=s2+E^.Dat.MarketElement[c].Input.NSertif+'.* '
     Else
     If ord(s3[0])<150 Then s3:=s3+E^.Dat.MarketElement[c].Input.NSertif+'.* '
     Else
     If ord(s4[0])<150 Then s4:=s4+E^.Dat.MarketElement[c].Input.NSertif+'.* ';
   End;
  End;
NoInfoMsg;

{$ELSE}

DInfoMsg('Формирую список фотографий...',False);
 For c:=1 To E^.Dat.AmountS Do
  Begin
   If ord(s1[0])<150 Then s1:=s1+E^.Dat.DocumentElement[c].BazKod+'.* '
   Else
   If ord(s2[0])<150 Then s2:=s2+E^.Dat.DocumentElement[c].BazKod+'.* '
   Else
   If ord(s3[0])<150 Then s3:=s3+E^.Dat.DocumentElement[c].BazKod+'.* '
   Else
   If ord(s4[0])<150 Then s4:=s4+E^.Dat.DocumentElement[c].BazKod+'.* ';
  End;
NoInfoMsg;

{$ENDIF}
{
  Memc(s1);
  Memc(s2);
  Memc(s3);
  Memc(s4);
}

  Assign(Cmd,Path^.Dat.ToTemp+'photo.bat');
  c:=IoResult;
  Rewrite(Cmd);
  c:=IoResult;
  If c<>0 Then
     Begin
      MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'photo.bat!',Nil,mfError+mfCancelButton);
      Exit;
     End;

  If s1[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s1);
  If s2[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s2);
  If s3[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s3);
  If s4[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s4);
  Writeln(Cmd,'Exit');
  c:=IoResult;
  Close(Cmd);
  c:=IoResult;

  CursorLines:=1543;
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SwapVectors;

  Exec(GetEnvMy,' /C '+Path^.Dat.ToTemp+'photo.bat '+NullStr^);

  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;

  Event.What:=evCommand;
  Event.Command:=cmNone;
  Application^.PutEvent(Event);

  Application^.Redraw;
End;
*)

Procedure CreatAndPrintSeparatorPage(E:PSuperMArketType);
Var txt : Text;
    sss : Boolean;
      c : Word;
Begin
 Assign(txt,Path^.DAt.ToTemp+'sosat.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;
 Writeln(txt);
 Writeln(txt);
 Writeln(txt);
 Writeln(txt);
 Writeln(txt,GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
 '  Клиент:'+GetClientField(FClient,E^.DAt.ClientKod,0)+
 GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
 Writeln(txt,GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
 '   Агент:'+GetAgentField(FAgent,E^.DAt.AgentKod)+
 GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

 Writeln(txt,GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
 'Оператор:'+GetOperatorField(FNAme,E^.DAt.Caption)+
 GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

 Writeln(txt,GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
 'Документ:'+E^.DAt.Document+' от '+E^.DAt.DateC+''+
 GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

 Writeln(txt,GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
 '  Версия:'+IntToStr(E^.DAt.Versia,CKol)+
 GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
 Writeln(txt,'==============================================');

 c:=IOResult;
 Close(txt);
 c:=IOResult;
 If MessageBox(^M+#3'Печатать страницу-разделитель?',Nil,mfInformation+mfOkCancel)=cmOk Then
    Report(Path^.DAt.ToTemp+'sosat.txt','',1,False,False);



End;




Procedure RunPrintPhoto(E:PSuperMarketType;
{эта переменная была нужна только для Бакши а теперь и в Триаде-сервис}MMM:Maska55);
Var Event : TEvent;
    s1,s2,s3,s4,s11,s22,s33,s44,s111,s222,s333,s444 : String;
    c : Word;
    Cmd : Text;
    Regim : Word;
Begin

If Not FExists(Path^.Dat.ToPhoto+'photo.exe') Then
 Begin
  MessageBox(NoExistsModul^+ClicProgrammer^,Nil,mfError+mfCancelButton);
  Exit;
 End;


 s1[0]:=#0;
 s2[0]:=#0;
 s3[0]:=#0;
 s4[0]:=#0;

 s11[0]:=#0;
 s22[0]:=#0;
 s33[0]:=#0;
 s44[0]:=#0;

 s111[0]:=#0;
 s222[0]:=#0;
 s333[0]:=#0;
 s444[0]:=#0;

{$IFDEF Pharm}

Regim:=0;

If Not(Pos('*',GetClientField(FMessages,E^.Dat.ClientKod,E^.Dat.OperatorSelector))>0) Then
Begin

{ищем есть в накладной повторные сертификаты}
For c:=1 To E^.DAt.Amount Do
 Begin
  Regim:=Regim+MMM[c];
 End;

If Regim<>0 Then
  Begin
   If MessageBox(#3+'Провести повторную печать фотографий сертификатов?',Nil,mfOkCancel)=cmCancel Then Regim:=0
   Else Regim:=1;
  End;

End;


DInfoMsg('Формирую список фотографий...',False);

 For c:=1 To E^.Dat.Amount Do
  Begin
   If (Regim=0) Or ((Regim=1) And (MMM[c]=0)) Then{фильтр повторной печати фотографий}
   If (E^.Dat.MarketElement[c].Input.NSertif<>NoSertifStr) And
      TestSertif(E,c,E^.Dat.MarketElement[c].Input.NSertif) Then
   Begin
     If ord(s1[0])<150 Then s1:=s1+E^.Dat.MarketElement[c].Input.NSertif+'*.* '
     Else
     If ord(s2[0])<150 Then s2:=s2+E^.Dat.MarketElement[c].Input.NSertif+'*.* '
     Else
     If ord(s3[0])<150 Then s3:=s3+E^.Dat.MarketElement[c].Input.NSertif+'*.* '
     Else
     If ord(s4[0])<150 Then s4:=s4+E^.Dat.MarketElement[c].Input.NSertif+'*.* ';
   End;
  End;
NoInfoMsg;

{$ELSE}

DInfoMsg('Формирую список фотографий...',False);

 For c:=1 To E^.Dat.AmountS Do
  Begin
   If ord(s1[0])<150 Then s1:=s1+E^.Dat.DocumentElement[c].BazKod+'*.* '
   Else
   If ord(s2[0])<150 Then s2:=s2+E^.Dat.DocumentElement[c].BazKod+'*.* '
   Else
   If ord(s3[0])<150 Then s3:=s3+E^.Dat.DocumentElement[c].BazKod+'*.* '
   Else
   If ord(s4[0])<150 Then s4:=s4+E^.Dat.DocumentElement[c].BazKod+'*.* ';
  End;


 For c:=1 To E^.Dat.Amount Do
  Begin
   If ord(s11[0])<150 Then s11:=s11+E^.Dat.MarketElement[c].BazKod+'*.* '
   Else
   If ord(s22[0])<150 Then s22:=s22+E^.Dat.MarketElement[c].BazKod+'*.* '
   Else
   If ord(s33[0])<150 Then s33:=s33+E^.Dat.MarketElement[c].BazKod+'*.* '
   Else
   If ord(s44[0])<150 Then s44:=s44+E^.Dat.MarketElement[c].BazKod+'*.* ';
  End;

{* - добавлена 01/06/2005 для того чтобы печатать помимо фотографий еще какую-нить байду
типа справки гигиенические удостоверения и прочее}

{добавлена 26/09/2005 по просьбе МихНика для возможности печатать
фотографии даже при нулевом расходе сертификатов}


If NPrint^.Dat.ShemaPhoto=1 Then
Begin
 For c:=1 To E^.Dat.Amount Do
  Begin
   If (E^.Dat.MarketElement[c].Input.NSertif<>NoSertifStr) And
      TestSertif(E,c,E^.Dat.MarketElement[c].Input.NSertif) Then

   If (Not (Pos(E^.Dat.MarketElement[c].Input.NSertif,s111)>0)) Then
   If (Not (Pos(E^.Dat.MarketElement[c].Input.NSertif,s1)>0)) Then
   If (Not (Pos(E^.Dat.MarketElement[c].Input.NSertif,s222)>0)) Then
   If (Not (Pos(E^.Dat.MarketElement[c].Input.NSertif,s2)>0)) Then
   If (Not (Pos(E^.Dat.MarketElement[c].Input.NSertif,s333)>0)) Then
   If (Not (Pos(E^.Dat.MarketElement[c].Input.NSertif,s3)>0)) Then
   If (Not (Pos(E^.Dat.MarketElement[c].Input.NSertif,s444)>0)) Then
   If (Not (Pos(E^.Dat.MarketElement[c].Input.NSertif,s4)>0)) Then

   Begin
     If (ord(s111[0])<150) Then s111:=s111+E^.Dat.MarketElement[c].Input.NSertif+'*.* '
     Else
     If (ord(s222[0])<150) Then s222:=s222+E^.Dat.MarketElement[c].Input.NSertif+'*.* '
     Else
     If (ord(s333[0])<150) Then s333:=s333+E^.Dat.MarketElement[c].Input.NSertif+'*.* '
     Else
     If (ord(s444[0])<150) Then s444:=s444+E^.Dat.MarketElement[c].Input.NSertif+'*.* ';
   End;
  End;
End;



NoInfoMsg;

{$ENDIF}
{
  Memc(s1);
  Memc(s2);
  Memc(s3);
  Memc(s4);
}

  Assign(Cmd,Path^.Dat.ToTemp+'photo.bat');
  c:=IoResult;
  Rewrite(Cmd);
  c:=IoResult;
  If c<>0 Then
     Begin
      MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'photo.bat!',Nil,mfError+mfCancelButton);
      Exit;
     End;

  If s1[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s1);
  If s2[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s2);
  If s3[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s3);
  If s4[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s4);
  If s11[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s11);
  If s22[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s22);
  If s33[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s33);
  If s44[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s44);
  If s111[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s111);
  If s222[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s222);
  If s333[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s333);
  If s444[0]<>#0 Then
  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s444);

  Writeln(Cmd,'Exit');
  c:=IoResult;
  Close(Cmd);
  c:=IoResult;

  CursorLines:=1543;
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SwapVectors;
(*
  If s1[0]<>#0 Then
  Begin
  Exec(GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p! '+s1);
  AddProtocol('Печать фотографий',GetEnvMy+' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s1,'');
  End;


  If s2[0]<>#0 Then
  Begin
  Exec(GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p! '+s2);
  AddProtocol('Печать фотографий',GetEnvMy+' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s2,'');
  End;


  If s3[0]<>#0 Then
  Begin
  Exec(GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p! '+s3);
  AddProtocol('Печать фотографий',GetEnvMy+' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s3,'');
  End;


  If s4[0]<>#0 Then
  Begin
  Exec(GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p! '+s4);
  AddProtocol('Печать фотографий',GetEnvMy+' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe /p '+s4,'');
  End;
*)

  Exec(GetEnvMy,' /C '+Path^.Dat.ToTemp+'photo.bat '+NullStr^);



  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;

  Event.What:=evCommand;
  Event.Command:=cmNone;
  Application^.PutEvent(Event);
  Application^.Redraw;

  If NPrint^.Dat.PrintSeparatorPage=1 Then CreatAndPrintSeparatorPage(E);

End;


Procedure ShowPhoto(Art:ArtikulStr);
Var Event : TEvent;
    s1,s2,s3,s4 : String;
    c : Word;
    Cmd : Text;
    Regim : Word;
Begin

{сертификатный раздел}
If GetRazdelStatus(art) Then Exit;

If Not FExists(Path^.Dat.ToPhoto+art) Then
 Begin
     Sound(100);
     DInfoMsg('Фотография объекта отсутствует!',False);
     NoSound;
     Application^.ClearEvent(Event);
     Application^.GetEvent(Event);
     Application^.ClearEvent(Event);
     repeat
       Application^.GetEvent(Event);
     until (Event.What <> evNothing) And (Event.Command<>cmMenu);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Exit;
 End;


If Not FExists(Path^.Dat.ToPhoto+'photo.exe') Then
 Begin
  MessageBox(NoExistsModul^+ClicProgrammer^,Nil,mfError+mfCancelButton);
  Exit;
 End;


Regim:=0;

  Assign(Cmd,Path^.Dat.ToTemp+'sphoto.bat');
  c:=IoResult;
  Rewrite(Cmd);
  c:=IoResult;
  If c<>0 Then
     Begin
      MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'sphoto.bat!',Nil,mfError+mfCancelButton);
      Exit;
     End;

  Writeln(Cmd,GetEnvMy,' /C Start /D'+Path^.Dat.ToPhoto+' photo.exe '+Art);
  Writeln(Cmd,'Exit');
  c:=IoResult;
  Close(Cmd);
  c:=IoResult;

  CursorLines:=1543;
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SwapVectors;

  Exec(GetEnvMy,' /C '+Path^.Dat.ToTemp+'sphoto.bat '+NullStr^);

  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;

  Event.What:=evCommand;
  Event.Command:=cmNone;
  Application^.PutEvent(Event);

  Application^.Redraw;
End;





Procedure PrintNaklSertif (Space :TDateString; Video : Boolean;As :DocumentEditZ;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Float;
                                 ShowAnswer:Boolean;CopyNkl:Byte;Zakaz:Boolean;MMM:Maska55;NPrintCC:PNewPrintCopy);

Const StavkaNDS:Real =20;
      StavkaNDS2:Real =18;

Var f : MarketFileType;
    Copy,l : Word;
    s,ver : TMyString;
    ws : String[CName];
    pp : String[CPack];
    ws1 : TDateString;
    Find : Boolean;
    {DateMask : TDateString;}
    Proz : String[CLitr];
    Logik : Boolean;
    SDoc,SDate : AllStr;
    Barter : String[CMantissa];
    ZakazNumer,ZakazDate,ZakazTime : AllStr;
Begin

If (E^.Dat.Versia>1) Or ((E^.Dat.Versia=1)And (E^.Dat.AmountS>0)) Or TestFormPamatka(E) Then
Begin
{If MessageBox(^M+#3+'Печатать документы на отпуск сертификатов?',Nil,mfConfirmation+mfOKCancel)=cmOk Then}
If AutoAnswer(^M+#3+'Печатать документы на отпуск сертификатов?') Then
Begin

ItogoSkidka:=0;   Itogo:=0; {NDS:=0;}

If E^.Dat.OperatorSelector<>2 Then Barter[0]:=#0
Else Barter:='-Б';

If (E^.Dat.Realiz) And Not(E^.DAt.DocSelector in [5,6,7,8]) Then
Begin
SDoc:=E^.Dat.DocReal;
SDate:=DateToDateString(DateMask,E^.Dat.DocDate);
Logik:=True;
End
Else
 Begin
  SDoc:=E^.Dat.Document;
  SDate:=E^.Dat.DateC;
  Logik:=False;
 End;

DelSpace(SDoc);
DelSpace(SDate);

Case E^.Dat.DocSelector Of
0:begin
  If (E^.Dat.Versia>1) Or ((E^.Dat.Versia=1)And (E^.Dat.AmountS>0)) Then
  Begin
   FormNaklSertif(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,False,Zakaz);
   Close(txt);
   Report(Path^.Dat.ToTemp+'Nakladnp.txt',Path^.Dat.ToTemp+'temp.tmp',CopyNkl,False,Logik);
   Rewrite(txt);
  End;

   If ((NPrintCC^.Dat.CopyPamatka>0) And (E^.Dat.OperatorSelector in [0,2]))
   Or (E^.Dat.OperatorSelector=1) Then
   If TestFormPamatka(E) Then
   {If MessageBox(^M+#3'Печатать памятку на не отпущенные сертификаты?',Nil,mfConfirmation+mfOkCancel)=cmOk Then}
   If AutoAnswer(^M+#3'Печатать памятку на не отпущенные сертификаты?') Then
   Begin
    FormPamatka(Space+'    ',False, E, Txt,Zakaz);
    Close(txt);
    ReportNew(Path^.Dat.ToTemp+'Nakladnp.txt',Path^.Dat.ToTemp+'temp.tmp',NPrintCC^.Dat.CopyPamatka,False,Logik);
    Rewrite(txt);
   End;

{новая вставка}
  end;{список}

1,2,3,4,5,6,7,8:
  begin
  If (E^.Dat.Versia>1) Or ((E^.Dat.Versia=1)And (E^.Dat.AmountS>0)) Then
  Begin
   FormNaklSertif(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,False,Zakaz);

If Not(FindParam('/NOCLIENTSERTIF')) And Not(DisablePrintXerox=1) Then
Begin
If Not(Zakaz) Then
begin
   Writeln(Txt,GlobalPrn^.Dat.EndPage[Nprint^.DAt.Printer]);
   s:=E^.Dat.Document;

 If E^.Dat.DocSelector<>0 Then{если не список}
 Begin
  Writeln(Txt,Space+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
 End
 Else
 Begin
  If E^.Dat.OperatorSelector<>0 Then
   Begin
    Writeln(Txt,Space+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
   End
   Else Begin Writeln(txt); End;
 End;

 WriteLn(Txt,Space+'Экспедитор: '+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
 GetEkspedField(FAgent,E^.Dat.EkspeditorKod)+
                           GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);



   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   zakazTime[0]:=#0;

If Not Zakaz Then
Begin
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
End;




 If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
 Writeln(txt,Space{+'Последние изменения:'}+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');

   Writeln(Txt ,Space+ZakazNumer+SDoc+'-С'+BArter+
   '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)
    +'                        Т О В А Р Н Ы Й  Ч Е К  от '+ZakazDate{SDAte}+
    ' ('+ZakazTime{E^.Dat.TimeC}+')');
    Writeln(Txt,Space+'                                                                  <<КАССА>>');

    If E^.DAt.Oformlenie=1 Then
    Writeln(Txt ,Space+SDoc+'-С'+BArter+' от '+SDAte+' ('+E^.DAt.TimeC+')');

    Writeln(Txt,Space+'Получатель: ',{GetClient(E^.Dat.ClientKod)+}' ('+E^.Dat.ClientKod+')');

    If E^.Dat.SkidkaSelector=0 Then Ver:='Скидка: Авто '
        Else Ver:='Скидка: Ручная';

        If (E^.Dat.Versia>1) Then
         Begin
          Ver:=Ver+'                                                   Версия: '+IntToStr(E^.Dat.Versia,CLitrMantissa);
         End;

    Writeln(txt,Space+ver);

    DelSpace(E^.Dat.SertifSummaZ);
    RFormat(E^.Dat.SertifSummaZ,CIZena);
    Writeln(Txt,Space+'              ┌─────────────────────────────────────────────────────┐');
    Writeln(Txt,Space+'              │N  Наименование услуги     Количество            Цена│');
    Writeln(Txt,Space+'              └─────────────────────────────────────────────────────┘');
    Writeln(Txt,Space+'               1  Услуги ксерокопирования          1 '+E^.Dat.SertifSummaZ);
    Writeln(Txt,Space+'               ─────────────────────────────────────────────────────');
    Writeln(Txt,Space+'               Всего позиций: 1       Всего к оплате:'+E^.Dat.SertifSummaZ);
    Writeln(Txt,Space+'               ─────────────────────────────────────────────────────');
    {
    Writeln(txt,Space+'               В т.ч. НДС: ',RecognizReal(StrToReal(E^.Dat.SertifSummaZ)*StavkaNDS/(100+StavkaNDS),
    CIZena,CMantissa));
    Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt^.DAt.Printer]+'                  20% :'+
    RecognizReal(StrToReal(E^.Dat.SertifSummaZ)*
    StavkaNDS/
    (100+StavkaNDS),
    CIZena,CMantissa)+
                            GlobalPrn^.Dat.NoItalic[Nprint^.DAt^.DAt.Printer]);}
    Writeln(txt);
    Writeln(txt,Space+'             Сдал _________             Принял _________');
    Writeln(Txt,Space,'{'+RecognizReal(StrToReal(E^.Dat.SertifSkidka),CIZena,CMantissa)+'}');
    Writeln(Txt,Space,' '+RecognizReal(StrToReal(E^.Dat.SertifSkidka)+StrToREal(E^.Dat.SertifSummaZ),
    CIZena,CMantissa)+'                    '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')  '+
    GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+'  Тип документа: (',
         LeadingZero(E^.Dat.DocSelector)+{'-С',}')'+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
           GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
           GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
   Writeln(Txt,Space+'──────────────────────────────── Линия отрыва ──────────────────────────────────────');
   Writeln(Txt);

 If E^.Dat.DocSelector<>0 Then{если не список}
 Begin
  Writeln(Txt,Space+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
 End
 Else
  Begin
   If E^.Dat.OperatorSelector<>0 Then
    Begin
     Writeln(Txt,Space+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
    End
    Else Begin
          Writeln(txt);
         End;
  End;


If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt,Space{+'Последние изменения:'}+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');


   Writeln(Txt ,Space+ZakazNumer+SDoc+'-С'+BArter+
   '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)
    +'                        Т О В А Р Н Ы Й  Ч Е К  от '+ZakazDate{SDAte}+
    ' ('+ZakazTime{E^.Dat.TimeC}+')');

    If E^.DAt.Oformlenie=1 Then
    Writeln(Txt ,Space+SDoc+'-С'+BArter+' от '+SDAte+' ('+E^.DAt.TimeC+')');

   (*
   Writeln(Txt ,Space+SDoc+'-С'+BArter+
   '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)
    +'                        Т О В А Р Н Ы Й  Ч Е К  от '+SDAte{E^.Dat.DateC}+
    ' ('+E^.Dat.TimeC+')');
   *)

    Writeln(Txt);
    Writeln(Txt,Space+'Получатель: ',{GetClient(E^.Dat.ClientKod)+}' ('+E^.Dat.ClientKod+')');

    If E^.Dat.SkidkaSelector=0 Then Ver:='Скидка: Авто '
        Else Ver:='Скидка: Ручная';

        If (E^.Dat.Versia>1) Then
         Begin
          Ver:=Ver+'                                                   Версия: '+IntToStr(E^.Dat.Versia,CLitrMantissa);
         End;

    Writeln(txt,Space+ver);

    DelSpace(E^.Dat.SertifSummaZ);
    RFormat(E^.Dat.SertifSummaZ,CIZena);
    Writeln(Txt,Space+'              ┌─────────────────────────────────────────────────────┐');
    Writeln(Txt,Space+'              │N  Наименование услуги     Количество            Цена│');
    Writeln(Txt,Space+'              └─────────────────────────────────────────────────────┘');
    Writeln(Txt,Space+'               1  Услуги ксерокопирования          1 '+E^.Dat.SertifSummaZ);
    Writeln(Txt,Space+'               ─────────────────────────────────────────────────────');
    Writeln(Txt,Space+'               Всего позиций: 1       Всего к оплате:'+E^.Dat.SertifSummaZ);
    Writeln(Txt,Space+'               ─────────────────────────────────────────────────────');

    If DateStringToDate(DateMask,E^.Dat.DAteC)<DAteStringToDAte(DateMask,'01-01-04') Then
    Begin
    Writeln(txt,Space+'               В т.ч. НДС: ',RecognizReal(StrToReal(E^.Dat.SertifSummaZ)*StavkaNDS/(100+StavkaNDS),
    CIZena,CMantissa));
    Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+'                  20% :'+
    RecognizReal(StrToReal(E^.Dat.SertifSummaZ)*
    StavkaNDS
    /(100+StavkaNDS),CIZena,CMantissa)+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
    End
     Else
      Begin
    Writeln(txt,Space+'               В т.ч. НДС: ',RecognizReal(StrToReal(E^.Dat.SertifSummaZ)*StavkaNDS2/(100+StavkaNDS2),
    CIZena,CMantissa));
    Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+'                  18% :'+
    RecognizReal(StrToReal(E^.Dat.SertifSummaZ)*
    StavkaNDS2
    /(100+StavkaNDS2),CIZena,CMantissa)+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
      End;

    Writeln(txt);
    Writeln(txt,Space+'             Сдал _________             Принял _________');
    Writeln(Txt,Space,'{'+RecognizReal(StrToReal(E^.Dat.SertifSkidka),CIZena,CMantissa)+'}');
    Writeln(Txt,Space,' '+RecognizReal(StrToReal(E^.Dat.SertifSkidka)+StrToREal(E^.Dat.SertifSummaZ),
    CIZena,CMantissa)+'                    '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')  '+
    GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    '  Тип документа: (',
         LeadingZero(E^.Dat.DocSelector)+')'+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
           GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
           GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
   Writeln(Txt,Space+'====================================================================================');
   Close(txt);
   Report(Path^.Dat.ToTemp+'Nakladnp.txt',Path^.Dat.ToTemp+'temp.tmp',CopyNkl,False,Logik);
End{FindParam}
   Else
   Close(txt);

   Rewrite(txt);
 End
Else
 Begin
   Close(txt);
   Report(Path^.Dat.ToTemp+'Nakladnp.txt',Path^.Dat.ToTemp+'temp.tmp',1,False,Logik);
   Rewrite(txt);
 End;
End;

   If ((NPrintCC^.Dat.CopyPamatka>0) And (E^.Dat.OperatorSelector in [0,2]))
   Or (E^.Dat.OperatorSelector=1) Then
   If TestFormPamatka(E) Then
   {If MessageBox(^M+#3'Печатать памятку на не отпущенные сертификаты?',Nil,mfConfirmation+mfOkCancel)=cmOk Then}
   If AutoAnswer(^M+#3'Печатать памятку на не отпущенные сертификаты?') Then
   Begin
    FormPamatka(Space+'    ',False, E, Txt,Zakaz);
    Close(txt);
    ReportNew(Path^.Dat.ToTemp+'Nakladnp.txt',Path^.Dat.ToTemp+'temp.tmp',NPrintCC^.Dat.CopyPamatka,False,Logik);
    Rewrite(txt);
   End;
    End;{1}
Else;
End;{Case}
End;{MassageBox}
End;{Versia}

If NewGtd=0 Then
Begin
If NPrint^.Dat.PrintPhoto=1 Then
{$IFDEF Pharm}
If E^.Dat.Amount>0 Then
{$ELSE}
If (E^.Dat.AmountS>0) Or (NPrint^.Dat.ShemaPhoto=1) Then
{$EndIf}
{If MessageBox(^M+#3+'Печатать фотографии сертификатов?',Nil,mfConfirmation+mfOKCancel)=cmOk Then}
If AutoAnswer(^M+#3+'Печатать фотографии сертификатов?') Then
Begin
 If E^.Dat.OperatorSelector in [0,2] Then
 RunPrintPhoto(E,MMM);
End;
End;

End;{Procedure}





Procedure Test_Srok(Const Spis:PBox;Const M:Maska8;Const Assort,Sort:Word);
Var R,R1 : TRect;
    i,l,lk : Word;
    Txt : Text;
    RazdelName,Fas,TempArtikul,s,ss : AllStr;
    ws,ws1,ws2 : String;
    Pack,P : String[CPack];
    Space : TEnJoyStr;
    VidProsmotra : Word; {1 - все остатки продажи,
                          0 - остатки только по продающимся позициям}
    RazdelO,RazdelR,ItogoR,ItogoO : Real;
    E : PSkladType;
    Wk : String[CKol];
    Ef : SkladFileType;
    Skidka : Boolean;
    TempList : PBox;
    WspomList: PBox;
    Regim : Word;
    Separator : ArtikulStr;
    {esbox : PBox;}
         MyWsopList : PBox;
    SInPack,MarketKol,MarketPack:string[CPack];
    PositionZena,Date : TDateString;
    VidZaprosa,VidPoiska,Diapason,EdIzm : Word;
    Protocol : Text;


Begin
 Separator:=SeparatorChar;
 Assign(Txt,Path^.Dat.ToTemp+'dsrok.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'dsrok.txt'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   {Dispose(Spis,Done);}
   Exit;
  End;
 Close(txt);


  R.Assign(0,0,0,0);
  TemplIST := New(PBox, Init(R, 1, Nil));
  TempList^.NewList(New(PTextCollection, Init(0,1)));
  For L:=0 To Spis^.List^.Count-1 Do
 Begin
  s:=Spis^.GetText(l,Spis^.List^.Count);
  TempList^.List^.Insert(NewStr(s));
  TempList^.SetRange(TempList^.List^.Count);
 End;
 {Dispose(Spis,Done);}

 Regim:=SelectSort;

   CAse Regim Of
   0:Begin
  R1.Assign(0,0,0,0);
  WspomlIST := New(PBox, Init(R1, 1, Nil));
  WspomList^.NewList(New(PTextCollection, Init(0,1)));
  For L:=0 To TempList^.List^.Count-1 Do
   Begin
    s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod)+'│'+
       Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdel);
    WspomList^.List^.Insert(NewStr(s));
    WspomList^.SetRange(WspomList^.List^.Count);
   End;

  TEmpList^.NewList(Nil);
  TEmpList^.NewList(New(PTextCollection, Init(0,1)));
  For L:=0 To WspomList^.List^.Count-1 Do
   Begin
    s:=WspomList^.GetText(l,WspomList^.List^.Count);
    TempList^.List^.Insert(NewStr(s));
    TempList^.SetRange(TempList^.List^.Count);
   End;
   Dispose(WspomList,Done);

     End;
   2:Begin
         Dispose(TempList,Done);
      Exit;
     End;

   Else;
   End;




    VidZaprosa:=1;
 If Not(SelectDSertif(VidZaprosa,VidPoiska,Diapason)) Then
    Begin
     Dispose(TempList,Done);
     Exit;
    End;

R.Assign(0, 0, 0, 0);
LocalTempBox := New(PBox, Init(R, 1, Nil));
LocalTempBox^.NewList(New(PTextCollection, Init(0,1)));

  DInfo('Анализирую остатки...');
  Append(txt);
  Space:='       ';
  Writeln(Txt,Header+Space+'Склад:'+FormKod(Rek^.Dat.Kod)+' Оператор:'+CurrentPassword+' EYE & 1999');

  Writeln(Txt,Space+'Выбранные отделения:');
  Write(Txt,Space);
  For l:=1 To CDivision Do
  If M[l]=1 Then Write(txt,l:2,':',Rek^.Dat.Otdel[l],' ');
  Writeln(Txt);
Space:='    ';
If VidPoiska=1 Then
Writeln(Txt,Space+'     ТОВАРЫ, СРОК РЕАЛИЗАЦИИ КОТОРЫХ ИСТЕКАЕТ В БЛИЖАЙШИЕ '+IntToStr(Diapason,3)+' дней ')
Else
Writeln(Txt,Space+'                      БАЗА СРОКОВ РЕАЛИЗАЦИИ ТОВАРА');

Writeln(txt,Space+'┌────┬────┬──────────────────────────┬─────┬───────────────┬────────┬────────┬────────┐');
Writeln(txt,Space+'│Код │  N │Наименование товара       │Колич│    Фирма-     │Дата    │Срок    │Осталось│');
Writeln(txt,Space+'│    │    │                          │  шт │ прозводитель  │выработ.│реализац│до срока│');
Writeln(txt,Space+'└────┴────┴──────────────────────────┴─────┴───────────────┴────────┴────────┴────────┘'+HeaderStop);
Writeln(Txt);

 New(E,Init);

 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);



If TestRazdel(s,M{отделения},Assort{0 ассортимент},2{0 разреш к продаже},2{маркиров и немарк},0{без учета брони},False) Then
  Begin

      RazdelName:=GetRazdel(s);

      Assign(Ef,Path^.Dat.ToSklad+s+'.db');
      OldFileMode:=FileMode;
      FileMode:=ReadOnlyN;
      Reset(Ef);
      FileMode:=OldFileMode;

      R1.Assign(0, 0, 0, 0);
      MyWsopList := New(PBox, Init(R, 1, Nil));
      MyWsopList^.NewList(New(PTextCollection, Init(0,1)));
      While Not(Eof(ef)) Do
      Begin
       ReadSkladPointer(ef,E);

       For i:=1 To CDivision Do
        If M[i]=1 Then
       Begin
        DelSpace(E^.Dat.Input.Kol);

      If ((E^.Dat.Employ) And (StrToInt(E^.Dat.Input.Division[i])>0)And(Assort=0))Or
       ((E^.Dat.Employ)And(Assort>0)And(((StrToInt(E^.Dat.Input.Division[i])>0))Or(i<=1)))Then
         Begin

          If Nprint^.DAt.FullName=0 Then Ws:=GetIdField(FName,E^.Dat.Bazkod)
          Else Ws:=GetIdField(FFName,E^.Dat.Bazkod);
          Format(ws,CName);

          RFormat(E^.Dat.Input.DiviSion[i],CKol);

          Str(i:2,S);

          Str(StrToInt(E^.Dat.Input.Division[i]):CKol,E^.Dat.Input.Division[i]);

          Ws:=Space+E^.Dat.BazKod+Separator+' '+s+' '+Separator+ws+Separator+
                E^.Dat.Input.Division[i]+Separator;

          ws1:=GetFirmaPostField(FFirmaPost,GetIdField(FFirmaPost,E^.DAt.BAzKod));
          DelSpaceRight(ws1);
          Format(ws1,CPost);
          ws:=ws+ws1+Separator;

          ws1:=E^.DAt.Input.Virabotano;
          DelSpaceRight(ws1);
          Format(ws1,CDate);
          ws:=ws+ws1+Separator;

          ws1:=BakGetField1(FGodnost,E^.DAt.BAzKod,0);
          DelSpaceRight(ws1);
          Format(ws1,CDate);
          ws:=ws+ws1+Separator;

          ws1:=IntToStr(DateStringToDate(DateMask,BakGetField1(FGodnost,E^.DAt.BAzKod,0))-
                        DateStringToDate(DateMask,FDate),CDAte);


          RFormat(ws1,CDate);
          DelSpaceRight(ws1);
          ws:=ws+ws1;

          If (VidPoiska=0) Or
                   (VidPoiska=1) And (DateStringToDate(DateMask,BakGetField1(FGodnost,E^.DAt.BAzKod,0))<=
                                     (DateStringToDate(DateMask,FDate)+Diapason)) Then
         Begin
          If Sort>0 Then
           Begin
            P:=Copy(ws,Ord(Space[0])+1,CArtikul+2+2);
            Delete(ws,Ord(Space[0])+1,CArtikul+2+2);
            ws:=ws+Separator+P;
           End;
          {Writeln(txt,ws);}
          MyWsopList^.List^.Insert(NewStr(ws));
          MyWsopList^.SetRange(MyWsopList^.List^.Count);
         End;
         End;
       End;{ if m[i]=1}
      End;{While}

      Close(Ef);

       If ((MyWsopList^.List^.Count-1)>=0) {And (MyWsopList^.List<>Nil)} Then
       Begin
       {печать заголовка раздела}

       Writeln(Txt,'                       Раздел: '+RazdelName);
       Writeln(Txt);

       For lk:=0 To MyWsopList^.List^.Count-1 Do
        Begin
        ws:=MyWsopList^.GetText(lk,MyWsopList^.List^.Count);
        If Sort>0 Then
         Begin
          P:=Copy(ws,Ord(ws[0])-CArtikul-2-1,CArtikul+2+2);
          Delete(ws,Ord(ws[0])-CArtikul-2-2,CArtikul+2+2+1);
          Insert(P,ws,Ord(Space[0])+1);
         End;

                         ws1:=Copy(ws,Ord(Space[0])+1,CArtikul);
          If Nprint^.DAt.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
                         Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           ws1:=Copy(ws,1+Ord(Space[0])+1+CArtikul+2+2+1,CName);
           System.Delete(ws,1+Ord(Space[0])+1+CArtikul+2+2+1,CName);
           System.Insert(ws2,ws,1+Ord(Space[0])+1+CArtikul+2+2+1);
           Writeln(txt,Space+'     '+Separator+' '+'   '+SeparatorChar+ws1);
           {Format(ws2,CName);}
          End;

          Writeln(txt,ws);
        End;
        Writeln(txt);
       End;
        {MyWsopList^.NewList(Nil);}
        Dispose(MyWsopList,Done);
                  {MemC;}
   End;{TestRazdel}
 End;{for по разделам}

    Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

Writeln(txt,Space+'==============================================');

 Close(txt);
 Dispose(E,Done);

 Dispose(TempList,Done);
 Dispose(LocalTempBox,Done);
 MyStr(ItogoR,CIZena,CMantissa,ws);
 NoInfo;
 ViewAsText(Path^.Dat.ToTemp+'dsrok.txt','Справка по срокам реализации продукции',True);
{ If Not(TestOpenDate(FDate)) Then}
 {ReportNew(Path^.Dat.ToTemp+'dsrok.txt','',NPrintC^.Dat.CopyAll,False,False);}
End;




Procedure PrintNewGTD;
Var Ver : Word;
    Event : TEvent;
Begin
 NoInfoMsg;
  CursorLines:=1543;
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SwapVectors;
  Ver := DosVersion;
  If Ver<>5{ у XP и 2000 версия 5} Then
  Exec(GetEnvMy,' /c Start.exe '+Path^.Dat.ToUtils+'zen.exe '+Path^.Dat.ToTemp+'zennik.ini')
  Else
  Exec(GetEnvMy,' /C Start /D'+Path^.Dat.ToUtils+' zen.exe '+Path^.Dat.ToTemp+'zennik.ini');
  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;

  Event.What:=evCommand;
  Event.Command:=cmNone;
  Application^.PutEvent(Event);

  Application^.Redraw;
End;






End.














