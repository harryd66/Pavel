{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Vision4;

Interface

Uses Glob,Dialogs,ServStr,Serv,Vision1,Drivers,Utils;


Type
  PSelZenWindow = ^TSelZenWindow;
  TSelZenWindow = object(TDialog)
   procedure HandleEvent(var Event: TEvent); virtual;
   Destructor Done; virtual;
  end;






Procedure FormNakl(Space :TDateString; Video : Boolean;As :DocumentEdit;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Real;
                            ShowAnswer:Boolean);

Procedure FormPril(E:PSuperMarketType;Var Txt:Text);


{Function SelectPrize(Var M:Maska24;Reg:Word;VAr Region : Word):Word;}
Function SelectPrize(Var M:Maska24;Reg:Word;VAr Region:Word;Ext:Boolean;VAr Mas:Maska6):Word;

Procedure SpecialRashetProdag(const Spis:PBox;Assort,Sort:Word);

Procedure RashetProdag(const Spis:PBox;Assort,Sort:Word);
Function TestElementSpis_New (Const S : ArtikulStr;Const P : PBox;Const Sort:Word) : Boolean;
Procedure CalcMenedger2(Const Client,Agent:PBox; Filtr,Oplata:Word;StartD,StopD:TDateString);

Function CalcMassaOtdel(E:PSuperMArketType;Otdel:MaskaNew):AllStr;


Implementation

Uses DBEngine,MsgBox,Views,Propiss,TpDate,Access,Objects,Tools,
      NetDBEng,Printers,App;


Var zenaWin :PSelZenWindow;
    StandartList,SelectList:PBox;
    GlobalControl:Word;
    Control1 : PView;

Function CalcMassa(E:PSuperMArketType):AllStr;
VAr c : Word;
    AllMassa:AllStr;
    Bk : ArtikulStr;
Begin
CalcMassa[0]:=#0;
AllMassa[0]:=#0;

 With E^.Dat Do
  Begin
     {перенос наименований}
   For c:=1 To E^.Dat.Amount Do
   Begin
     BK:=E^.Dat.MarketElement[c].BAzKod;
     With MarketElement[c].Input Do
      Begin
        Bk:=GetIdField(FLitr,BK);
        MyStr(StrToReal(AllMassa)+StrToInt(E^.Dat.MarketElement[c].Input.Kol)*
	   StrToReal(Bk),CPack,CLitrMantissa,AllMAssa);
      End;{With}
   End;{For}
  End;{With}

CAlcMassa:=AllMassa;
End;{Procedure}


Function CalcMassaOtdel(E:PSuperMArketType;Otdel:MaskaNew):AllStr;
VAr c : Word;
    AllMassa:AllStr;
    Bk : ArtikulStr;
Begin
CalcMassaOtdel[0]:=#0;
AllMassa[0]:=#0;

 With E^.Dat Do
  Begin
     {перенос наименований}
   For c:=1 To E^.Dat.Amount Do
   Begin
  If Otdel[E^.Dat.MarketElement[c].Input.DivisionSNumber]=1 Then
Begin
     BK:=E^.Dat.MarketElement[c].BAzKod;
     With MarketElement[c].Input Do
      Begin
        Bk:=GetIdField(FLitr,BK);
        MyStr(StrToReal(AllMassa)+StrToInt(E^.Dat.MarketElement[c].Input.Kol)*
	   StrToReal(Bk),CPack,CLitrMantissa,AllMAssa);
      End;{With}
End;
   End;{For}
  End;{With}

CAlcMassaOtdel:=AllMassa;
End;{Procedure}




Procedure FormNakl(Space :TDateString; Video : Boolean;As :DocumentEdit;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Real;
                   ShowAnswer:Boolean);


Var l : Word;
    sc,s,ws,ws1 : String;
    Ss : TEnjoyStr;
    st : String[CMantissa];
    pp : String[CPack];
    TTT,ItogoS,NdsPos :Real;
    Local,R : Boolean;
    M : MaskaNew;
    c : Word;
    SDate,Dop : TDateString;
    Nalog:TDateString;
    tempSkidka,tt1,tt2,WspomSkidka,OutputSklad,InputSklad,koefficient:ALLStr;
    DrawSkidka:Boolean;
    Separator : AllStr;
    Symbol : ArtikulStr;
    SRegion : AllStr;
    _NDS20,_NDS10,_NDS_ : Real;


Begin
   c:=IoResult;

   ItogoS:=0;ItogoSkidka:=0;Itogo:=0;{ NDS:=0;} NdsPos:=0;

   {R=True - первичный документ консигнации
   R=False - вторичный документ консигнации}
   If (E^.Dat.Realiz) And Not(E^.Dat.DocSelector in [5,6,7,8]) Then
   Begin
   R:=False;
   Dop:='          ';
   End
   Else
   Begin
   R:=True;
   Dop[0]:=#0;
   End;


   If E^.Dat.OperatorSelector in [0,2] Then Local:=False
   Else Local:=True;


   For l:=1 To E^.Dat.Amount Do
   Begin
   MyStr(StrToReal(E^.Dat.MarketElement[l].Input.Zena)*StrToInt(E^.Dat.MarketElement[l].Input.Kol)
   ,CIZena,CMantissa,ws);
   Itogo:=Itogo+StrToReal(Ws);
   End;


   CAse E^.Dat.Region Of
   0: SRegion:='Офис ';
   1: SRegion:='Город ';
   2: SRegion:='Область ';
   3: SRegion:='Резерв ';
   Else;
   End;




   If Video Then
   Begin
   CAse E^.Dat.SkidkaSelector Of
   0: Writeln(txt,Space+'Скидка: Авто ');
   1: Writeln(txt,Space+'Скидка: Ручная');
   2: If E^.Dat.ShkalaNumer>0 Then
      Writeln(txt,Space+'Скидка: Шкала '+SRegion+
	 IntToStr(E^.Dat.Shkalanumer-(6*E^.Dat.Region),CMantissa)+
	 ' ('+IntToStr(E^.Dat.Shkalanumer,CMantissa)+')')
      Else
      Writeln(txt,Space+'Скидка: Шкала '+SRegion+'0 (0)');
   Else;
   End;
   End;

   DrawSkidka:=True;

   If ShowAnswer Then
   Begin

   If Not(LoCal) Then
   Begin
    sc:=GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
    If (Pos('А-',sc)>0) Then
       Begin
        If MessageBox(^M+#3'Включать ставки скидок в накладную?',Nil,mfWarning+mfOkCancel)=cmcancel Then
        DrawSkidka:=False;
       End;{служба доставки}
   End;
   End;


If R Then
Begin
 If (E^.Dat.OperatorSelector in [0,2]) And (E^.Dat.DocSelector in [0,1,2,3,4,5,6,7,8]) Then
 Begin
   Writeln(txt,Space+Dop+'--------------------------------------------------------------------------------------');
   Writeln(txt,Space+Dop+' N  Код  Наименование товара        Колич     Цена   Итого сумма  Упаковок Отд Примеч.');
   Writeln(txt,Space+Dop+'--------------------------------------------------------------------------------------');
 End
  Else
  Begin
   Space:=' ';
   Writeln(txt,Space+Dop+'---------------------------------------------------------------------------------------');
   Writeln(txt,Space+Dop+' N  Код  Наименование товара        Колич   Р/Цена   НП    З/Цена  Упаковок Отд Примеч.');
   Writeln(txt,Space+Dop+'---------------------------------------------------------------------------------------');
  End;
                         { 1 12345│12345678901234567890123456│12345│12345678│12345│12345678│123456789│123│1234567│}
End
Else
Begin
   Writeln(txt,Space+Dop+'-----------------------------------------------------------------');
   Writeln(txt,Space+Dop+' N  Код  Наименование товара        Колич     Цена   Итого сумма');
   Writeln(txt,Space+Dop+'-----------------------------------------------------------------');
End;
   c:=0;
   WordToBitNew(c,M);

   _Nds20:=0;
   _Nds10:=0;
   _Nds_:=0;

   For l:=1 To E^.Dat.Amount Do
    Begin
     Str(l:CMantissa,St);
     s:=E^.Dat.MarketElement[l].BazKod;

     If Not(E^.DAt.MarketElement[l].Input.Last) Then
     Separator:=' '   Else Separator:=#249;

     If NPrint.FullName=0 Then
     Begin
      ws:=GetIdField(FName,E^.Dat.MarketElement[l].BazKod);
      ws1:=GetIdField(FName2,E^.Dat.MarketElement[l].BazKod);
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
	  Begin

        If Not(E^.DAt.MarketElement[l].Input.Last) Then
	   Writeln(txt,Space+Dop+st+Separator+s+' '+ws)
        Else
         Begin
          If Not Video Then
          Writeln(txt,Space+Dop+st+
		            Bold[NPrint.Printer]+Double[NPrint.Printer]+
				  Separator+s+
				  NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]+
                      ' '+ws)
          Else
    	     Writeln(txt,Space+Dop+st+Separator+s+' '+ws)
         End;


        Separator:=' ';
        st:='  ';
        ws:=ws1;
        s:='     ';
       End;
     End
     Else
	 Begin
	  ws:=GetIdField(FFName,E^.Dat.MarketElement[l].BazKod);
       ws1:=GetIdField(FFName2,E^.Dat.MarketElement[l].BazKod);
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
	  Begin

        If Not(E^.DAt.MarketElement[l].Input.Last) Then
	   Writeln(txt,Space+Dop+st+Separator+s+' '+ws)
        Else
         Begin
          If Not Video Then
          Writeln(txt,Space+Dop+st+
		            Bold[NPrint.Printer]+Double[NPrint.Printer]+
				  Separator+s+
				  NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]+
                      ' '+ws)
          Else
    	     Writeln(txt,Space+Dop+st+Separator+s+' '+ws)
         End;


        Separator:=' ';
        st:='  ';
        ws:=ws1;
        s:='     ';

       End;
      End;


     Format(ws,CName);
     s:=s+' '+ws;
     DelSpace(E^.Dat.MarketElement[l].Input.Kol);
     ws:=E^.Dat.MarketElement[l].Input.Kol;
     RFormat(ws,CKol);
     s:=s+' '+ws;


     If E^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
      begin
       DelSpace(E^.Dat.MarketElement[l].Input.Proz);

       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)*
       (StrToReal(E^.Dat.MarketElement[l].Input.Proz))),CZena,CMantissa,ws);

       If E^.DAt.DocSelector in [{1,}2,3,5,6] Then {отключен расчет НП в тч}
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);
       {новая цена}
       MyStr(StrToReal(ws)*StrToReal(Koefficient),CZena,CMantissa,ws);
      End;

     s:=s+' '+ws;

   If (E^.Dat.OperatorSelector=1) Or
   (R And(E^.Dat.OperatorSelector in [0,2]) And Not(E^.Dat.DocSelector in [0,1,2,4,5,6,7,8])) Then
    Begin
     Nalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
     MyStr(StrToReal(Nalog),CLitr,CMantissa,Nalog);
     s:=s+' '+Nalog;
    End;

       MyStr((StrToReal(Ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
       ,CInputIZena,CMantissa,ws);

       ItogoS:=ItogoS+StrToReal(wS);
       s:=s+' '+ws;
      end
     Else
      Begin
{       ItogoSkidka:=ItogoSkidka+StrToReal(E^.Dat.MarketElement[l].Input.Skidka)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);
       {сумма скидки}
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Skidka))
       ,CZena,CMantissa,ws);


       If E^.DAt.DocSelector in [{1,}2,3,5,6] Then {отключен  НП в ТЧ}
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);

       {новая цена}
       MyStr(StrToReal(ws)*StrToReal(Koefficient),CZena,CMantissa,ws);
       End;

       s:=s+' '+ws;


  If (E^.Dat.OperatorSelector=1)  Then
    Begin
     Nalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
     MyStr(StrToReal(Nalog),CLitr,CMantissa,Nalog);
     {пока включен налог спродажи нужен в документах клиента}
     s:=s+' '+Nalog{+'     '};
    End;



       MyStr((StrToReal(Ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
       ,CInPutIZena,CMantissa,ws);

       ItogoS:=ItogoS+StrToReal(wS);

  If (E^.Dat.OperatorSelector<>1)  Then
    Begin
      s:=s+' '+ws;
    End
    Else
     Begin
      MyStr(StrToReal(E^.Dat.MarketElement[l].Input.Zakupka),CZena,CMantissa,E^.Dat.MarketElement[l].Input.Zakupka);
      s:=s+' '+E^.Dat.MarketElement[l].Input.Zakupka;
     End;

      End;

      M[E^.Dat.MarketElement[l].Input.DivisionSNumber]:=1;

     NdsPos:=StrToReal(Ws)*StrToReal(E^.Dat.MarketElement[l].Input.NDS)/
     (100+StrToReal(E^.Dat.MarketElement[l].Input.NDS));


     NdsPos:=StrToReal(Ws)-NDSPos;

     {
     StrToReal(BakGetField(FNDS,E^.Dat.MarketElement[l].BazKod,0))/
     (100+StrToReal(BakGetField(FNDS,E^.Dat.MarketElement[l].BazKod,0)));
     }
     MyStr(NdsPos,CIZena,CMantissa,ws);
     NdsPos:=StrToReal(Ws);

     {Nds:=Nds+NdsPos;}

     If R Then {Если не вторичный документ консигнации}
      Begin
      {посчитали упаковки}
      pp:=CalcPack(E^.Dat.MarketElement[l].BazKod,E^.Dat.MarketElement[l].Input.Kol);
      DelSpace(Pp);
      RFormat(Pp,CPack);
      s:=s+' '+pp;
      {добавили отделение}
      Str(E^.Dat.MarketElement[l].Input.DivisionSNumber:2,ws);



       Case E^.Dat.MarketElement[l].Input.VidNDs Of
       0:_Nds20:=_Nds20+NdsPos;
       1:_Nds10:=_Nds10+NdsPos;
       2:_Nds_:=_Nds_+NdsPos;
       Else;
       End;

      {Если скидка автоматическая и не нулевая}
      Case E^.Dat.SkidkaSelector Of
      0:Begin{скидка автоматическая}

       Case NPrint.FullSkidka Of
       0:Begin{скидка в процентах}
         If DrawSkidka Then
         Begin
          If (StrToReal(E^.Dat.MarketElement[l].Input.Proz)<>1.0000) Then
           Begin

            TempSkidka:=E^.Dat.MarketElement[l].Input.Proz;

            MyStr((1-StrToReal(TempSkidka))*100,CKol+1,CLitrMAntissa+1,TempSkidka);
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
          If (StrToReal(E^.Dat.MarketElement[l].Input.Proz)<>1.0000) Then
           Begin
            MyStr(StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Zena)*
            (StrToReal(E^.Dat.MarketElement[l].Input.Proz)),CKol+1,CMantissa,WspomSkidka);
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
       2:Begin
           SDate:=BakGetField(FRealiz,E^.Dat.MarketElement[l].BazKod,0);
           DelSpace(SDate);
           If SDAte[0]<>#0 Then
           ws:=ws+'  '+SDate
           Else
           ws:=ws+'  '+'_______';
          End;

       3:Begin
           ws:=ws+'  '+'_______';
          End;
         Else;
         End;{Case FullSkidka}

        End;{0 Case}
      2:Begin{скидка ручная по шкалам}

       Case NPrint.FullSkidka Of
       0:Begin{скидка в процентах}
         If DrawSkidka Then
         Begin
          If (StrToReal(E^.Dat.MarketElement[l].Input.Proz)<>1.0000) Then
           Begin
            TempSkidka:=E^.Dat.MarketElement[l].Input.Proz;
            MyStr((StrToReal(Tempskidka)),CLitr+1,CLitrMantissa+1,TempSkidka);

            MyStr((1-StrToReal(TempSkidka))*100,CKol+1,CLitrMAntissa+1,TempSkidka);

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
           ws:=ws+'  '+'________';
          End;
         End;{Case FullSkidka 0}

       1:Begin {абсолютная велечина скидки}
         If DrawSkidka Then
         Begin
          If (StrToReal(E^.Dat.MarketElement[l].Input.Proz)<>1.0000) Then
           Begin
            (*
            Str(StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Zena)/
            (1+StrToReal(E^.Dat.MarketElement[l].Input.Proz)/100):CKol+1:CMantissa,WspomSkidka);
            *)
            MyStr(StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Zena)*
            (StrToReal(E^.Dat.MarketElement[l].Input.Proz)),CKol+1,CMantissa,WspomSkidka);
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
         End;{Case FullSkidka}

       2:Begin
           SDate:=BakGetField(FRealiz,E^.Dat.MarketElement[l].BazKod,0);
           DelSpace(SDate);
           If SDAte[0]<>#0 Then
           ws:=ws+'  '+SDate
           Else
           ws:=ws+'  '+'_______';
          End;

        3:Begin
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
           {If StrToReal(E^.Dat.MarketElement[l].Input.Skidka)>0 Then}
            Begin
             MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-
             StrToReal(E^.Dat.MarketElement[l].Input.Skidka))/(StrToReal(E^.Dat.MarketElement[l].Input.Zena))
             ,CKol+1,CLitrMantissa+1,WspomSkidka);
             MyStr(StrToReal(WspomSkidka){*100},CKol+1,CLitrMantissa+1,WspomSkidka);
            End;

            MyStr((1-StrToReal(WspomSkidka))*100,CKol+1,CLitrMAntissa+1,WspomSkidka);
            {

            Else
             Begin
              Str((-(Abs(StrToReal(E^.Dat.MarketElement[l].Input.Skidka)))/
              ((StrToReal(E^.Dat.MarketElement[l].Input.Zena)))):CKol+1:CLitrMantissa+1,WspomSkidka);
             End;
            }
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
        2:Begin
           SDate:=BakGetField(FRealiz,E^.Dat.MarketElement[l].BazKod,0);
           DelSpace(SDate);
           If SDAte[0]<>#0 Then
           ws:=ws+'  '+SDate
           Else
           ws:=ws+'  '+'_______';
          End;

        1:Begin{абсолютная велечина скидки}
        If DrawSkidka Then
        Begin
         If (Abs(StrToReal(E^.Dat.MarketElement[l].Input.Skidka))>=0.01) Then
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
          Else;
          End;{Case FullSkidka}

        End;{1 Case}

      Else;{Case}
      End;{Case}
      End{If r}
      Else
           Begin
            pp[0]:=#0;
            ws[0]:=#0;
           End;


     If Not Video Then s:=Pitch[NPrint.Printer]+s+' '+ws+NoPitch[NPrint.Printer]
     Else s:=s+' '+ws;

     If Video Then
     If FindPAram('/EZ') Then
	s:=s+' '+E^.Dat.MarketElement[l].Input.Zakupka;

     If FindPAram('/SHOWNAKL') Then
	s:=s+' '+E^.Dat.MarketElement[l].Input.Osn.NaklNumer+' '+E^.Dat.MarketElement[l].Input.Osn.DateNakl;


     If Not(E^.DAt.MarketElement[l].Input.Last) Then
     Writeln(txt,Space+Dop+St+' '+s)
     Else
     Begin
     If Not Video Then
     Writeln(txt,Space+Dop+Bold[NPrint.Printer]+Double[NPrint.Printer]+
	St+#249+NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]+s)
     Else
     Writeln(txt,Space+Dop+St+#249+s);
     End;

     {
     If Not(E^.DAt.MarketElement[l].Input.Last) Then
     Writeln(txt,Space+Dop+St+' '+s)
     Else
     Writeln(txt,Space+Dop+St+#249+s);
     }
     {Writeln(txt,Space+Dop+St+Separator+s);}
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
     If E^.Dat.OperatorSelector in [0,2] Then
     Begin
{    If PrintSertifDoc[2]=1 Then
      Begin
       ss:=BakGetField(FSertif,E^.Dat.MarketElement[l].BazKod,0);
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CSertif);
         ss:=Space+'   '+'Сертификат: '+ss;
         Writeln(txt,ss);
        End;
      End;}

     If PrintAkzisDoc[2]=1 Then
     Begin
       ss:=BakGetField(FAkzis,E^.Dat.MarketElement[l].BazKod,0);
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CSertif);
         ss:=Space+'   '+'Примечание: '+ss;
         Writeln(txt,ss);
        End;
     End;

     End{OperatorSelector}
     Else
      Begin
{
     If PrintSertifDoc[1]=1 Then
      Begin
       ss:=BakGetField(FSertif,E^.Dat.MarketElement[l].BazKod,0);
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CSertif);
         ss:=Space+'   '+'Сертификат: '+ss;
         Writeln(txt,ss);
        End;
      End;
}
     If PrintAkzisDoc[1]=1 Then
     Begin
       ss:=BakGetField(FAkzis,E^.Dat.MarketElement[l].BazKod,0);
       DelSpaceRight(ss);
       If not(ss[0]=#0) Then
        Begin
         Format(ss,CSertif);
         ss:=Space+'   '+'Примечание: '+ss;
         Writeln(txt,ss);
        End;
      End;
       End;
{    s:=BakGetField(FSertif,E^.Dat.MarketElement[l].BazKod,0);
     DelSpaceRight(s);
     If s[0]<>#0 Then
     Begin
     Format(s,CSertif);
     Writeln(Txt,Space+'        Сертификат: '+s);
     End;     }
{     StrToInt(E^.Dat.MArketElement[l].Input.Kol)*Wspom*
     StrToReal(GetNds(E^.Dat.MarketElement[l].BazKod))/(100+StrToReal(GetNds(E^.Dat.MarketElement[l].BazKod)));
{    Nds:=StrToReal(Ws);}
    End;


    ItogoSkidka:=Itogo+StrToReal(E^.Dat.ENalog);
    MySTr(ItogoSkidka,CIZena,CMantissa,tt1);
    MySTr(ItogoS,CIZena,CMantissa,tt2);

    {MemClC(RealToStr(ItogoSkidka,CIZena,CMantissa)+' '+RealToStr(ItogoS,CIZena,CMantissa));}

    ItogoSkidka:=StrToReal(tt1)-StrToReal(tt2){ItogoS};

    DelSpace(E^.Dat.SummaZ);
    RFormat(E^.Dat.SummaZ,CIZena);
    RFormat(E^.Dat.SummaZakupka,CIZena);
{    If Video Then Writeln(txt,Space+'______________________________________________________________________________');}
MyStr(StrToReal(E^.Dat.SummaZ),CIZena,CMantissa,E^.Dat.SummaZ);
MyStr(StrToReal(E^.Dat.SummaZakupka),CIZena,CMantissa,E^.Dat.SummaZakupka);
{DelSpace(E^.Dat.SummaZ);}
If R Then
Begin
 If (E^.Dat.OperatorSelector in [0,2]) And (E^.Dat.DocSelector in [0,1,4,7,8]) Then
   Begin
    Writeln(txt,Space+Dop+'--------------------------------------------------------------------------------------');
    Writeln(Txt,Space+Dop+'Всего позиций:',E^.Dat.Amount:2,'                  Всего к оплате:',Recogniz(E^.Dat.SummaZ)+
    ' Мест:'+CalcMesto(E));
    Writeln(Txt,Space+Dop+'  Всего масса:',Recogniz(CalcMassa(E)));

If (Video) And (StrToInt(CurrentPassword)=0) Then
   Begin
    Writeln(Txt,Space+Dop+'                                   Всего закупка:',Recogniz(E^.Dat.SummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ)-StrToReal(E^.Dat.ENalog)-StrToReal(E^.Dat.SummaZakupka),
    CIZena,CMantissa)));
   End;

   End
   Else
    Begin
    Writeln(txt,Space+Dop+
    '---------------------------------------------------------------------------------------'
    {'--------------------------------------------------------------------------------------------'});
    Writeln(Txt,Space+Dop+'Всего позиций:',E^.Dat.Amount:2,'                 Всего к оплате:',Recogniz(E^.Dat.SummaZ)+
    ' Мест:'+CalcMesto(E));
    Writeln(Txt,Space+Dop+'  Всего масса:',Recogniz(CalcMassa(E)));
If (Video) Or (E^.Dat.OperatorSelector=1) Then
   Begin
    Write(Txt,Space+Dop+'                                  Всего закупка:',Recogniz(E^.Dat.SummaZakupka));
    If Video And (StrToInt(CurrentPassword)=0) Then Writeln(txt,
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ)-StrToReal(E^.Dat.ENalog)-StrToReal(E^.Dat.SummaZakupka),
    CIZena,CMantissa)))
    Else
    Writeln(txt);
   End;
    End;
End
Else
Begin
    Writeln(txt,Space+Dop+'-----------------------------------------------------------------');
    Writeln(Txt,Space+Dop+'Всего позиций:',E^.Dat.Amount:2,'                  Всего к оплате:',Recogniz(E^.Dat.SummaZ)+
    ' Мест:'+CalcMesto(E));
    Writeln(Txt,Space+Dop+'  Всего масса:',Recogniz(CalcMassa(E)));
If (Video) And (StrToInt(CurrentPassword)=0) Then
   Begin
    Writeln(Txt,Space+Dop+'                                   Всего закупка:',Recogniz(E^.Dat.SummaZakupka)+
    '    D:'+Recogniz(RealToStr(StrToReal(E^.Dat.SummaZ)-StrToReal(E^.Dat.ENalog)-StrToReal(E^.Dat.SummaZakupka),
    CIZena,CMantissa)));
   End;

End;


If Not(Video) Then
Begin
    If E^.Dat.DocSelector in [2,3,4,5,6,8] Then
    Begin
    s:=E^.Dat.SummaZ;
    DelSpace(s);
    Propis(s,ws);
    If r Then
    Writeln(txt,Space+Dop+'--------------------------------------------------------------------------------------')
    Else
    Writeln(txt,Space+Dop+'-----------------------------------------------------------------');

    ws[1]:=UpperCase(ws[1]);
    If Not Video Then Writeln(txt,Space+Dop+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+ws+
    NoItalic[NPrint.Printer]+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer])
    Else Writeln(txt,Space+ws);
    If s[0]<>#0 Then
    If Not Video Then Writeln(txt,Space+Dop+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+s+
    NoItalic[NPrint.Printer]++NoBold[NPrint.Printer]+NoDouble[NPrint.Printer])
    Else Writeln(txt,Space+s);

    If r Then
    Writeln(txt,Space+Dop+'--------------------------------------------------------------------------------------')
    Else
    Writeln(txt,Space+Dop+'-----------------------------------------------------------------');
    End;
End;

  If Not FindParam('/SHOWOUTNDS') Then
 Begin
    If E^.Dat.DocSelector in [3,4,6,8] Then
     Begin
       Writeln(txt,Space+Dop+'     В т.ч. НДС:',RecognizReal(Nds,CIZena,CMantissa));
       If NDS20>0.009 Then
       If Not Video Then
       Writeln(txt,Space+Dop+Italic[NPrint.Printer]+'         '+CNDS20+'   :'+RecognizReal(NDS20,CIZena,CMantissa)+
          NoItalic[NPrint.Printer])
       Else
       Writeln(txt,Space+Dop+'         '+CNDS20+'   :'+RecognizReal(NDS20,CIZena,CMantissa));
       If NDS10>0.009 Then
       If Not Video Then
       Writeln(txt,Space+Dop+Italic[NPrint.Printer]+'         10%   :'+RecognizReal(NDS10,CIZena,CMantissa)+
          NoItalic[NPrint.Printer])
       Else
       Writeln(txt,Space+Dop+'         10%   :'+RecognizReal(NDS10,CIZena,CMantissa));
       If NDS_>0.009 Then
       If Not Video Then
       Writeln(txt,Space+Dop+Italic[NPrint.Printer]+'         прочие:'+RecognizReal(NDS_,CIZena,CMantissa)+
          Noitalic[NPrint.Printer])
       Else
       Writeln(txt,Space+Dop+'         прочие:'+RecognizReal(NDS_,CIZena,CMantissa));
     End
     Else
       Writeln(txt,Space+Dop+'Без НДС');
 End
 Else
 Begin
    If E^.Dat.DocSelector in [3,4,6,8] Then
     Begin
       Writeln(txt,Space+Dop+'     В т.ч. НДС:',RecognizReal(Nds,CIZena,CMantissa));
       If (NDS20>0.009) Or (_NDS20>0.009) Then
       If Not Video Then
       Writeln(txt,Space+Dop+Italic[NPrint.Printer]+'         '+CNDS20+'   :'+RecognizReal(NDS20,CIZena,CMantissa)+
          NoItalic[NPrint.Printer]+
		'   (сумма без НДС '+CNDS20+RecognizReal(_NDS20,CIZena,CMantissa)+')')
       Else
       Writeln(txt,Space+Dop+'         '+CNDS20+'   :'+RecognizReal(NDS20,CIZena,CMantissa)+
	  +'   (сумма без НДС '+CNDS20+RecognizReal(_NDS20,CIZena,CMantissa)+')');
       If (NDS10>0.009) Or (_NDS10>0.009) Then
       If Not Video Then
       Writeln(txt,Space+Dop+Italic[NPrint.Printer]+'         10%   :'+RecognizReal(NDS10,CIZena,CMantissa)+
          NoItalic[NPrint.Printer]+
		'   (сумма без НДС 10%'+RecognizReal(_NDS10,CIZena,CMantissa)+')')
       Else
       Writeln(txt,Space+Dop+'         10%   :'+RecognizReal(NDS10,CIZena,CMantissa)+
	  +'   (сумма без НДС 10%'+RecognizReal(_NDS10,CIZena,CMantissa)+')');
       If (NDS_>0.009) Or (_NDS_>0.009) Then
       If Not Video Then
       Writeln(txt,Space+Dop+Italic[NPrint.Printer]+'         прочие:'+RecognizReal(NDS_,CIZena,CMantissa)+
          Noitalic[NPrint.Printer]++'   (сумма прочее НДС '+RecognizReal(_NDS_,CIZena,CMantissa)+')')
       Else
       Writeln(txt,Space+Dop+'         прочие:'+RecognizReal(NDS_,CIZena,CMantissa)+
	  +'   (сумма прочее НДС '+RecognizReal(_NDS_,CIZena,CMantissa)+')');
     End
     Else
       Writeln(txt,Space+Dop+'Без НДС');
 End;



    If E^.Dat.DocSelector in [{1,}2,3,5,6] Then {отключен НП в тч}
    Begin
      Writeln(txt,Space+Dop+'Налог с продажи:',RecognizReal(STrToReal(E^.Dat.ENalog),CIZena,CMantissa));
      If StrToReal(E^.Dat.ENalog)>0.009 Then
      Begin
       If StrToReal(E^.Dat.Nalog5)>0.009 Then
       Writeln(txt,Space+Dop+'         5%    :'+RecognizReal(StrToReal(E^.Dat.Nalog5),CIZena,CMantissa)+'');
       If StrToReal(E^.Dat.Nalog3)>0.009 Then
       Writeln(txt,Space+Dop+'         3%    :'+RecognizReal(StrToReal(E^.Dat.Nalog3),CIZena,CMantissa)+'');
       If StrToReal(E^.Dat.Nalog_)>0.009 Then
       Writeln(txt,Space+Dop+'         прочие:'+RecognizReal(StrToReal(E^.Dat.Nalog_),CIZena,CMantissa)+'');
      End;
    End;


    Writeln(Txt);
   If Not(Local) Then
   Begin
   If Not(Video) Then
   Begin
 {
 Writeln(txt,Space+'                         '+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+
 'Уважаемый клиент! Если по отношению к Вам проявили'+NoItalic[NPrint.Printer]+NOBold[NPrint.Printer]+NoDouble[NPrint.Printer]+
 ^M+
 Space+'                         '+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+
 'грубость - обратитесь пожалуйста к руководителю.'+NoItalic[NPrint.Printer]+NOBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
 }
    If R Then
    Begin
     For c:=1 To CDivision Do
      Begin
       If M[c]=1 Then
        Begin
         s:=Rek.Otdel[c];
         Format(s,CIZena);
         Writeln(Txt,Space+Dop+'Сдал (отделение ',c:1,') '{+Bold+s+NoBold}+
            ' ________     Товар принял, претензий не имею _______')
        End;
      End;{For}
    End
    Else
    Writeln(Txt,Space+'     Сдал ________       Товар принял, претензий не имею _______')

   End;
   End
   Else
    Begin
    OutPutSklad:=GetClientField(FClient,Rek.Kod,1);
    Format(OutPutSklad,CClient);
    InPutSklad:=GetClientField(FClient,E^.Dat.ClientKod,1);
    Format(InPutSklad,CClient);
   If Not(Video) Then
   Begin
 Writeln(Txt,Space+' '+'  Сдал кладовщик '+OutPutSklad+': __________  Товар принял экспедитор: __________');
 Writeln(txt,Space+' '+'                                           ФИО                                ФИО');
 Writeln(Txt,Space+' '+'Принял кладовщик '+InputSklad +': __________  Товар сдал экспедитор  : __________');
 Writeln(txt,Space+' '+'                                           ФИО                                ФИО');

   End;
   End;

(*   Writeln(Txt,Space{+'Скидка: '},'{'+RecognizReal(ItogoSkidka,CIZena,CMantissa)+'}');*)


{   If E^.Dat.DocSelector in [1,5,7] Then}
    Writeln(txt,Space+GetClientField({FClient}FFFName,E^.DAt.ClientKod,E^.Dat.OperatorSelector)+' ('+E^.DAt.ClientKod+')');
    Writeln(txt,Space+GetClientField({FAdressClient}FEnvir,E^.DAt.ClientKod,E^.Dat.OperatorSelector));

if StrToInt(Rek.kod)<>1 then
begin
Writeln(txt);
Writeln(txt);
Writeln(txt);
Writeln(txt);
Writeln(txt);
Writeln(txt);
Writeln(txt);
Writeln(txt);
end;
   If Not(Video)Then Write(txt,Space{+' Всего: '},' '+RecognizReal(Itogo,CIZena,CMantissa),
    ' Печатал:'+GetOperatorName(CurrentPassword)+' '+'"'+DayString[DayOfWeek(ToDay)]+'" '+
    TodayString(DateMask)+'('+Times+')')
   Else
   Writeln(Txt,Space{+' Всего: '},' '+RecognizReal(Itogo,CIZena,CMantissa));
   If Not(Video) Then
   Writeln(txt,'  '+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+' Тип документа: (',
   LeadingZero(E^.Dat.DocSelector),')'+NoItalic[NPrint.Printer]+NOBold[NPrint.Printer]+NoDouble[NPrint.Printer]);



 If ((E^.Dat.OperatorSelector in [0,2]) And (E^.Dat.DocSelector in [0,1,4,7,8])) Or Not(r)
 Then
   Writeln(txt,Space+'===============================================')
   Else
   If (E^.Dat.OperatorSelector=1) Then
   Writeln(txt,Space+'===============================================')
   Else
   Writeln(txt,Space+'===============================================');
End;


Procedure FormPril( E:PSuperMarketType;Var Txt:Text);
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
    Lg : PSuperMarketType;
Begin
   Space:='    ';
   Writeln(Txt,Space+' Склад: ',{E^.Dat.Sklad+}E^.Dat.SkladKod+
                  '  Оператор: '+E^.Dat.Caption+' EYE & 1999');
   Writeln (Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'                      Приложение к накладной N '+
   E^.DAt.Document+' от '+E^.Dat.DAteC+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
   If E^.DAt.DocSelector in [3,4,6,8] Then
   Rek1:=RekSF
   Else
   Rek1:=Rek;
   Format(Rek.NAme,CAll);
   Format(Rek.Adress,CAll);
   Format(Rek.Telefon,CAll);
   Writeln(Txt,Space+' Предриятие:'+Bold[NPrint.Printer]+Rek1.Name+NoBold[NPrint.Printer]   +' В соответствии  с  поста- ');
   Writeln(Txt,Space+' Адрес     :'+Bold[NPrint.Printer]+Rek1.Adress+NoBold[NPrint.Printer] +' новлением правительства РФ');
   Writeln(Txt,Space+' Телефон   :'+Bold[NPrint.Printer]+Rek1.Telefon+NoBold[NPrint.Printer]+' N 55 от 19.01.98');
   Writeln(Txt,Space+' Первые копии сертификатов находятся по адресу:'+Rek1.Adress);

{
   Writeln(Txt,Space+'                                                          тификации  N 210 7/268  от ');
   Writeln(Txt,Space+'                                                          06.04.96г. и Постановлением');
   Writeln(Txt,Space+'                                                          Правительства РФ N 595     ');
   Writeln(Txt,Space+'                                                          от 17.05.96 г.');
}
   Writeln(Txt);

   Space[0]:=#0;
   Space:='          ';
   Writeln(txt,Space+Condensed[NPrint.Printer]+'______________________________________________________________________'+
   '_____________________________________________________'++NoCondensed[NPrint.Printer]);
  Writeln(txt,Space+Condensed[NPrint.Printer]+' Код  Наименование товара        Регистрационный и учетный                Ср'+
   'ок       Наименование органа,'++NoCondensed[NPrint.Printer]);
  Writeln(txt,Space+Condensed[NPrint.Printer]+'                                 N сертификата                            дей'+
   'ствия   выдающего сертификат'++NoCondensed[NPrint.Printer]);
   Writeln(txt,Space+Condensed[NPrint.Printer]+'_____________________________________________________________________________'+
   '______________________________________________'+NoCondensed[NPrint.Printer]);
{12345 12345678901234567890123456│1234567890123456789012345678901234567890│1234567890│1234567890123456789012345678901234567890}

                                                                     {1234567890123 1234 1234567890123 1234567890123}
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

     Full[0]:=#0;
     If NPrint.FullName=0 Then
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


     {
     If NPrint.FullName=0 Then
     ws:=GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod)
     Else ws:=GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod);
     }



     Format(ws,CName);
     s:=Lg^.DAt.MarketElement[l].BazKod+' '+ws;
     ws:=BakGetField(FSertif,Lg^.DAt.MarketElement[l].BazKod,0);
     Format(ws,CNSertif);
     s:=s+' '+ws;
     ws:=BakGetField(FDateSertif,Lg^.DAt.MarketElement[l].BazKod,0);
     DelSpace(ws);

    If (ShowSertif=1) Then
    Begin
     If ws[0]<>#0 Then
     Begin
     If DateStringToDAte(DateMask,ws)<ToDay Then
      Begin
       MessageBox(^M+#3'В приложение включен просроченный сертификат!'^M+
          #3+'Товар с кодом: '+Lg^.DAt.MarketElement[l].BazKod,Nil,mfWarning+mfCancelButton);
      End;
     End
     Else
       MessageBox(^M+#3'В приложение у товара с кодом: '+Lg^.DAt.MarketElement[l].BazKod+^M+
          #3+'не указан срок действия сертификата!',Nil,mfWarning+mfCancelButton);
    End;

     Format(ws,CDSertif);
     s:=s+' '+ws;
     ws:=BakGetField(FKtoSertif,Lg^.DAt.MarketElement[l].BazKod,0);
     Format(ws,CKSertif);
     s:=s+' '+ws;
     If Full[0]<>#0 Then
     Writeln(txt,Space+Condensed[NPrint.Printer]+'      '+Full+NoCondensed[NPrint.Printer]);

     Writeln(txt,Space+Pitch[NPrint.Printer]+Condensed[NPrint.Printer]+s+NoCondensed[NPrint.Printer]+
        +NoPitch[NPrint.Printer]);
    End;
   WriteLn(txt,Space+'                                                   '+'"'+DayString[DayOfWeek(ToDay)]+
   '" '+TodayString(DateMask)+'('+Times+')');
   Writeln(txt,Space+Condensed[NPrint.Printer]+'============================================================================'+
   '================='+NoCondensed[NPrint.Printer]);
   Dispose(Lg,Done);
End;




(*
Function SelectPrize(Var M:Maska24;Reg:Word;VAr Region:Word;Ext:Boolean;VAr Mas:Maska6):Word;
Var R : TRect;
    ws1,ws,s : AllStr;
    c : Word;
    c1: Word;
    Find : Boolean;
    A : Array [1..6] Of Word;
    sRegion : TDAteString;
    max1 : Word;
Begin

c1:=SelectRegion(Ext);
If c1=6 Then Exit;

Region:=c1;

Case Region Of
0:sRegion:='Офис';
1:sRegion:='Город';
2:sRegion:='Область';
3:sRegion:='Резерв';
4:sRegion:='Спец.';
5:sRegion:='Персон.'
Else;
End;

A[1]:=1;
A[2]:=1;
A[3]:=1;
A[4]:=1;
A[5]:=1;
A[6]:=1;

SelectPrize:=6;
GlobalControl:=Reg;
R.Assign(25, 6, 54, 17);
New(zenaWin, Init(R, 'Выбор цен-"'+Sregion+'"'));
ZenaWin^.Options := ZenaWin^.Options or ofCenterX or ofCenterY;

R.Assign(10, 2, 11, 9);
Control1 := New(PScrollBar, Init(R));
ZenaWin^.Insert(Control1);

R.Assign(1, 2, 9, 9);
StandartList := New(PBox, Init(R, 1, PScrollbar(Control1)));
StandartList^.NewList(New(PTextCollection, Init(1,1)));
StandartList^.Options := StandartList^.Options or ofFramed;


Max1:=CShkala;

If Ext Then Max1:=CShkala+6;


 For c:=1 To Max1 Do
  Begin
    ws:=IntToStr(c,CMAntissa);
    RFormatZerro(ws,CMantissa);
    Find:=False;

   Case c1 Of
   0:Begin
      If c in [1..6] Then
      Begin
      Find:=True;
      ws1:=IntToStr(A[1],CMantissa);
      RFormat(ws1,CMantissa);
      s:='ЦЕНА '+ws1+'│'+ws;
      Inc(A[1]);
      End;
     End;
   1:Begin
      If c in [7..12] Then
      Begin
      Find:=True;
      ws1:=IntToStr(A[2],CMantissa);
      RFormat(ws1,CMantissa);
      s:='ЦЕНА '+ws1+'│'+ws;
      Inc(A[2]);
      End;
     End;
   2:Begin
      If c in [13..18] Then
      Begin
      Find:=True;
      ws1:=IntToStr(A[3],CMantissa);
      RFormat(ws1,CMantissa);
      s:='ЦЕНА '+ws1+'│'+ws;
      Inc(A[3]);
      End;
     End;
   3:Begin
      If c in [19..CShkala] Then
      Begin
      Find:=True;
      ws1:=IntToStr(A[4],CMantissa);
      RFormat(ws1,CMantissa);
      s:='ЦЕНА '+ws1+'│'+ws;
      Inc(A[4]);
      End;
     End;
   4:Begin
      If c in [CShkala+1..Max1] Then
      Begin
      Find:=True;
      ws1:=IntToStr(A[5],CMantissa);
      RFormat(ws1,CMantissa);
      s:='ЦЕНА '+ws1+'│'+ws;
      Inc(A[5]);
      End;
     End;
   Else;
   End;{Case}

    If Find Then
    Begin
    StandartList^.List^.Insert(NewStr(S));
    StandartList^.SetRange(StandartList^.List^.Count);
    End;
  End;


StandartList^.FocusItem(0);
StandartList^.HelpCtx:=$E044;
ZenaWin^.Insert(StandartList);


  R.Assign(2, 1, 7, 2);
  ZenaWin^.Insert(New(PLabel, Init(R, 'Цены', StandartList)));

R.Assign(26, 2, 27, 9);
Control1 := New(PScrollBar, Init(R));
ZenaWin^.Insert(Control1);

R.Assign(18, 2, 26, 9);
SelectList := New(PBox, Init(R, 1, PScrollbar(Control1)));
SelectList^.NewList(New(PTextCollection, Init(1,1)));
SelectList^.Options := SelectList^.Options or ofFramed;
SelectList^.FocusItem(0);
SelectList^.HelpCtx:=$E041;
ZenaWin^.Insert(SelectList);

  R.Assign(15, 1, 24, 2);
  ZenaWin^.Insert(New(PLabel, Init(R, 'Выбраны:', SelectList)));

ZenaWin^.SelectNext(False);
c:=Desktop^.ExecView(ZenaWin);
If c<>cmCancel Then
 Begin
  SelectPrize:=0;
  For c:=1 To CShkala Do m[c]:=0;

  if ext Then
  For c:=1 To 6 Do mas[c]:=0;



  For c:=0 To SelectList^.List^.Count-1 Do
   Begin
    s:=SelectList^.GetText(c,SelectList^.List^.COunt);
    s:=Copy(s,9,CMantissa);
    m[StrToInt(s)]:=1;
   End;

  if Ext Then
  For c:=0 To SelectList^.List^.Count-1 Do
   Begin
    s:=SelectList^.GetText(c,SelectList^.List^.COunt);
    s:=Copy(s,9,CMantissa);
    mas[StrToInt(s)-CShkala]:=1;
   End;

 End;
 Dispose(Control1,Done);
 Dispose(StandartList,Done);
 Dispose(SelectList,Done);
 Dispose(ZenaWin,Done);
End;
*)


Function SelectPrize(Var M:Maska24;Reg:Word;VAr Region:Word;Ext:Boolean;VAr Mas:Maska6):Word;
Var R : TRect;
    ws1,ws,s : AllStr;
    c : Word;
    c1: Word;
    Find : Boolean;
    A : Array [1..6] Of Word;
    sRegion : TDAteString;
    max1 : Word;
Begin
SelectPrize:=6;

c1:=SelectRegion(Ext);

If c1=6 Then Exit;

Region:=c1;

If Region=5 Then
 Begin
 SelectPrize:=0;
 Exit;
 End;


Case Region Of
0:sRegion:='Офис';
1:sRegion:='Город';
2:sRegion:='Область';
3:sRegion:='Резерв';
4:sRegion:='Спец.';
5:sRegion:='Персон.'
Else;
End;

A[1]:=1;
A[2]:=1;
A[3]:=1;
A[4]:=1;
A[5]:=1;
A[6]:=1;

SelectPrize:=6;
GlobalControl:=Reg;
R.Assign(25, 6, 54, 17);
New(zenaWin, Init(R, 'Выбор цен-"'+Sregion+'"'));
ZenaWin^.Options := ZenaWin^.Options or ofCenterX or ofCenterY;

R.Assign(10, 2, 11, 9);
Control1 := New(PScrollBar, Init(R));
ZenaWin^.Insert(Control1);

R.Assign(1, 2, 9, 9);
StandartList := New(PBox, Init(R, 1, PScrollbar(Control1)));
StandartList^.NewList(New(PTextCollection, Init(1,1)));
StandartList^.Options := StandartList^.Options or ofFramed;


Max1:=CShkala;

If Ext Then Max1:=CShkala+6;


 For c:=1 To Max1 Do
  Begin
    ws:=IntToStr(c,CMAntissa);
    RFormatZerro(ws,CMantissa);
    Find:=False;

   Case c1 Of
   0:Begin
      If c in [1..6] Then
      Begin
      Find:=True;
      ws1:=IntToStr(A[1],CMantissa);
      RFormat(ws1,CMantissa);
      s:='ЦЕНА '+ws1+'│'+ws;
      Inc(A[1]);
      End;
     End;
   1:Begin
      If c in [7..12] Then
      Begin
      Find:=True;
      ws1:=IntToStr(A[2],CMantissa);
      RFormat(ws1,CMantissa);
      s:='ЦЕНА '+ws1+'│'+ws;
      Inc(A[2]);
      End;
     End;
   2:Begin
      If c in [13..18] Then
      Begin
      Find:=True;
      ws1:=IntToStr(A[3],CMantissa);
      RFormat(ws1,CMantissa);
      s:='ЦЕНА '+ws1+'│'+ws;
      Inc(A[3]);
      End;
     End;
   3:Begin
      If c in [19..CShkala] Then
      Begin
      Find:=True;
      ws1:=IntToStr(A[4],CMantissa);
      RFormat(ws1,CMantissa);
      s:='ЦЕНА '+ws1+'│'+ws;
      Inc(A[4]);
      End;
     End;
   4:Begin
      If c in [CShkala+1..Max1] Then
      Begin
      Find:=True;
      ws1:=IntToStr(A[5],CMantissa);
      RFormat(ws1,CMantissa);
      s:='ЦЕНА '+ws1+'│'+ws;
      Inc(A[5]);
      End;
     End;
   Else;
   End;{Case}

    If Find Then
    Begin
    StandartList^.List^.Insert(NewStr(S));
    StandartList^.SetRange(StandartList^.List^.Count);
    End;
  End;


StandartList^.FocusItem(0);
StandartList^.HelpCtx:=$E044;
ZenaWin^.Insert(StandartList);


  R.Assign(2, 1, 7, 2);
  ZenaWin^.Insert(New(PLabel, Init(R, 'Цены', StandartList)));

R.Assign(26, 2, 27, 9);
Control1 := New(PScrollBar, Init(R));
ZenaWin^.Insert(Control1);

R.Assign(18, 2, 26, 9);
SelectList := New(PBox, Init(R, 1, PScrollbar(Control1)));
SelectList^.NewList(New(PTextCollection, Init(1,1)));
SelectList^.Options := SelectList^.Options or ofFramed;
SelectList^.FocusItem(0);
SelectList^.HelpCtx:=$E041;
ZenaWin^.Insert(SelectList);

  R.Assign(15, 1, 24, 2);
  ZenaWin^.Insert(New(PLabel, Init(R, 'Выбраны:', SelectList)));

ZenaWin^.SelectNext(False);
c:=Desktop^.ExecView(ZenaWin);
If c<>cmCancel Then
 Begin
  SelectPrize:=0;
  For c:=1 To CShkala Do m[c]:=0;

  if ext Then
  For c:=1 To 6 Do mas[c]:=0;



  For c:=0 To SelectList^.List^.Count-1 Do
   Begin
    s:=SelectList^.GetText(c,SelectList^.List^.COunt);
    s:=Copy(s,9,CMantissa);
    m[StrToInt(s)]:=1;
   End;

  if Ext Then
  For c:=0 To SelectList^.List^.Count-1 Do
   Begin
    s:=SelectList^.GetText(c,SelectList^.List^.COunt);
    s:=Copy(s,9,CMantissa);
    mas[StrToInt(s)-CShkala]:=1;
   End;

 End;
 Dispose(Control1,Done);
 Dispose(StandartList,Done);
 Dispose(SelectList,Done);
 Dispose(ZenaWin,Done);
End;




Destructor TSelZenWindow.Done;
Begin
TDialog.Done;
End;



procedure TSelZenWindow.HandleEvent(var Event: TEvent);
Var s : String[CRazdel+1+CRazdelKod];
    ls : Word;
Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
  kbCtrLDel:Begin
            ClearFind;
     If (SelectList^.State and sfFocused <> 0) And (SelectList^.List<>Nil)And(SelectList^.List^.Count>=1) Then
            Begin
             SelectList^.NewList(nil);
             SelectList^.NewList(New(PTextCollection, Init(1,1)));
            End;
            ClearEvent(Event);
             Redraw;
            End;
     kbDel: Begin
             ClearFind;
     If (SelectList^.State and sfFocused <> 0) And (SelectList^.List<>Nil)And(SelectList^.List^.Count>=1) Then
            Begin
             SelectList^.List^.AtFree(SelectList^.Focused);
             SelectList^.SetRange(SelectList^.List^.Count);
             If SelectList^.Focused>0 Then
             SelectList^.FocusItem(SelectList^.Focused);

             If (SelectList^.Focused>=SelectList^.List^.Count) and(SelectList^.Focused>0) Then
             SelectList^.FocusItem(SelectList^.Focused-1);

            End;
              ClearEvent(Event);
              Redraw;
            End;
    kbIns : Begin
            ClearFind;
            If(StandartList^.State and sfFocused <> 0) And (StandartList^.List^.Count>=1) Then
            Begin

            If (SelectList^.List^.Count<GlobalControl)  Then
            Begin
               s:=StandartList^.GetText(StandartList^.Focused,StandartList^.List^.COunt);
               If TestElement(Copy(s,9,CMAntissa),SelectList) Then
                Begin
               SelectList^.List^.Insert(NewStr(s));
               SelectList^.SetRange(SelectList^.List^.Count);
               s:=Copy(s,9,CMAntissa);
               SelectList^.FocusItem(LoCation(SelectList,S,ProdagaWindow));
             If SelectList^.Focused+1<SelectList^.List^.Count Then
             SelectList^.FocusItem(SelectList^.List^.Count-1);
                End;
               If (StandartList^.Focused+1) <  StandartList^.List^.Count Then
               StandartList^.FocusItem(StandartList^.Focused+1);
            End
             Else MessageBox(^M+#3'Вы хотите выбрать слишком много цен'^M+
                                      #3'Нельзя выбрать больше '+IntToStr(GlobalControl,CMantissa)+' цен!',
							   Nil,mfError+mfCancelButton);
            End;
              ClearEvent(Event);
              Redraw;
            End;
    Else;
    End;
   evCommand :
    Case Event.Command Of
      cmOk :Begin
            If Not((SelectList^.List<>Nil)And(SelectList^.List^.Count>=1)) Then
              Begin
               ClearEvent(Event);
               MessageBox(^M+#3'Не выбрано ни одной цены!',Nil,mfError+mfCancelButton);
              End;
            End;
      Else;
      End;
    Else;
    End;
  inherited HandleEvent(Event);
End;


Function TestElementSpis_New(Const S : ArtikulStr;Const P : PBox;Const Sort:Word) : Boolean;
Var ls : Word;
    k  : Byte;
    st : String[CALL];
Begin
TestElementSpis_New:=False;
For ls:=0 To P^.List^.Count-1 Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
k:=Pos('│',St);
If Sort in [1,2] Then
ST:=Copy(St,K+1,CRazdelKod) Else ST:=Copy(St,1,CRazdelKod);
If St=S Then
   Begin
    TestElementSpis_New:=True;
    Break;
   End;
End;
End;



(*

Procedure CompressReport(Start,Stop:LongInt;Cl:Word;Const TL:PBox;Regim:Word);
Var i,j,l,currentday,max,CurrentWeek,Current,Pos : LongInt;
    WL : PBox;
    ws,temps,s : TMyString;
    Itg : PNewItogType;
    WeekFile,ItogFile : File Of NewItogType;
    r1 : trect;
    Reiting,SumKol,Ext,Space : TEnJoyStr;

Begin

 For currentWeek:=1 To 8 Do
 Begin
  Str(CurrentWeek:1,TempS);
  Assign(WeekFile,Path.ToTemp+TEmps+'.w'+TempS);
  i:=IOResult;
  Rewrite(WeekFile);
  i:=IOResult;
  Close(WeekFile);
  i:=IOResult;
 End;

  currentDay:=start;
  currentWeek:=1;
  current:=start;
  New(Itg,Init);

  while current<stop do
begin
 Str(CurrentWeek:1,TempS);
 Assign(WeekFile,Path.ToTemp+TEmps+'.w'+TempS);
 i:=IOResult;
 Rewrite(WeekFile);
 i:=IOResult;
  If i=0 Then
    Begin
     {цикл расчета итогов за неделю}
      R1.Assign(0,0,0,0);
      Wl := New(PBox, Init(R1, 1, Nil));
      WL^.NewList(New(PTextCollection, Init(0,1)));
      max:=Current+6;
       For Current:=Current To Max Do
        Begin
         Str(StrToInt(Rek.Kod):2,Ext);
         RFormatZerro(Ext,2);
         s:=DAteToDAteString(DateMask,Current);
         Assign(ItogFile,Path.ToArchiv+s+'.i'+Ext);
         i:=IOResult;
         Reset(ItogFile);
         i:=IOResult;
         If i=0 Then
          Begin
           While Not(Eof(ItogFile)) Do
            Begin
             Read(ItogFile,Itg^.Dat);
If TestElementSpis_New (Copy(Itg^.Dat.BAzKod,1,CRAzdelKod),TL,regim) Then
Begin
             If Not(TestElement(Itg^.Dat.BAzKod,WL)) Then
              Begin

               Pos:= Location(WL,Itg^.Dat.BAzKod,False);
               ws := WL^.GetText(pos,WL^.List^.Count);
               s:=Copy(ws,1+CName+1+CArtikul+1,Ckol);
           temps:=Copy(ws,1+CName+1+CArtikul+1+CKol+1,Ckol);
               {обрезаем строку}
               ws[0]:=chr(1+CName+1+CArtikul);
               {складываем продажи}

               {Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC):Ckol,s);}

          Case Cl Of
          0:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC):CKol,s);{клиент}
          1:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkS):CKol,s);{склад}
          2:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC)+StrToInt(Itg^.Dat.MrkS):CKol,s);
          Else;
          End;


               {запоминаем последние остатки}
           If (Current=Stop) Then
            Begin
            Str(StrToInt(Itg^.Dat.Ost):Ckol,temps);
            End
            Else
			TempS[0]:=#0;

               ws:=ws+s+'│'+Temps;

               WL^.List^.AtFree(Pos);
               WL^.SetRange(WL^.List^.Count);

               WL^.List^.Insert(NewStr(ws));
               WL^.SetRange(WL^.List^.Count);
              End
             Else
              Begin
               ws:=GetIdField(FNAme,Itg^.Dat.BAzKod);
               Format(ws,CNAme);


               ws:=ws+'│'+Itg^.Dat.BAzKod+'│';
               Str(StrToInt(Itg^.Dat.MrkC):CKol,Itg^.Dat.MrkC);

          Case Cl Of
          0:Str(StrToInt(Itg^.Dat.MrkC):CKol,Itg^.Dat.MrkC);{клиент}
          1:Str(StrToInt(Itg^.Dat.MrkS):CKol,Itg^.Dat.MrkC);{склад}
          2:Str(StrToInt(Itg^.Dat.MrkC)+StrToInt(Itg^.Dat.MrkS):CKol,Itg^.Dat.MrkC);
          Else;
          End;



               Str(StrToInt(Itg^.Dat.Ost):CKol,Itg^.Dat.Ost);

               If (Current=Stop) Then
               Str(StrToInt(Itg^.Dat.Ost):Ckol,temps)
               Else
			TempS[0]:=#0;

               ws:=ws+Itg^.Dat.MrkC+'│'+TempS;
               WL^.List^.Insert(NewStr(ws));
               WL^.SetRange(WL^.List^.Count);
              End;
End;{If TestElementSpis}
            End;{While Not Eof(ItogFile)}
           Close(ItogFile);
          End;{ioresult=0}
        End;{for current}


       If WL^.List^.Count>=1 Then
        Begin
         For l:=0 To WL^.List^.Count-1 Do
          Begin
           Itg^.Dat.MrkC[0]:=#0;
           Itg^.Dat.MrkS[0]:=#0;
           Itg^.Dat.Ost[0]:=#0;
           ws:=WL^.GetText(l,WL^.List^.Count);
           Itg^.Dat.BazKod:=Copy(ws,1+CName+1,CArtikul);
           Itg^.Dat.MrkC:=Copy(ws,1+CName+1+CArtikul+1,CKol);
           Itg^.Dat.Ost:=Copy(ws,1+CName+1+CArtikul+1+CKol+1,CKol);
           Str(StrToInt(Itg^.Dat.Ost):CKol,Itg^.Dat.Ost);
           Str(StrToInt(Itg^.Dat.MrkC):CKol,Itg^.Dat.MrkC);

           Seek(WeekFile,FileSize(WeekFile));
           Write(WeekFile,Itg^.Dat);
          End;{For по списку}
        End;{WspomList}

      Dispose(WL,Done);
      Close(WeekFile);
    End;{IOResult=0}
 inc(current);
 inc(CurrentWeek);
end;{While}
Dispose(Itg,Done);

End;
*)


Procedure SpecialCompressReport(Start,Stop:LongInt;Cl,ClP:Word;Const TL:PBox;Regim:Word);
label m1;
Var i,j,l,currentday,max,CurrentWeek,Current,Current1,Pos : LongInt;
    WL : PBox;
    ws,temps,s : TMyString;
    Itg : PNewItogType;
    WeekFile,ItogFile : File Of NewItogType;
    r1 : trect;
    Reiting,SumKol,Ext,Space : TEnJoyStr;

Begin

 For currentWeek:=1 To 8 Do
 Begin
  Str(CurrentWeek:1,TempS);
  Assign(WeekFile,Path.ToTemp+TEmps+'.w'+TempS);
  i:=IOResult;
  Rewrite(WeekFile);
  i:=IOResult;
  Close(WeekFile);
  i:=IOResult;
 End;



  currentDay:=start;
  currentWeek:=1;
  current:=start;
  New(Itg,Init);

        Current1:=Stop;

m1:     s:=DAteToDAteString(DateMask,Stop);

        Str(StrToInt(Rek.Kod):2,Ext);
        RFormatZerro(Ext,2);

      Assign(ItogFile,Path.ToArchiv+s+'.p'+Ext);

         i:=IOResult;
         Reset(ItogFile);
         i:=IOResult;

         if i<>0 then
         if Current1-Stop<5 then
         begin
          dec(Stop);
          goto m1;
         end
         else close(ItogFile);



while current<stop do
begin
 Str(CurrentWeek:1,TempS);
 Assign(WeekFile,Path.ToTemp+TEmps+'.w'+TempS);
 i:=IOResult;
 Rewrite(WeekFile);
 i:=IOResult;
  If i=0 Then
    Begin
     {цикл расчета итогов за неделю}
      R1.Assign(0,0,0,0);
      Wl := New(PBox, Init(R1, 1, Nil));
      WL^.NewList(New(PTextCollection, Init(0,1)));
      max:=Current+6;
       For Current:=Current To Max Do
        Begin
         Str(StrToInt(Rek.Kod):2,Ext);
         RFormatZerro(Ext,2);

      s:=DAteToDAteString(DateMask,Current);

      Assign(ItogFile,Path.ToArchiv+s+'.p'+Ext);
         i:=IOResult;
         Reset(ItogFile);
         i:=IOResult;

         If i=0 Then
          Begin
           While Not(Eof(ItogFile)) Do
            Begin
             Read(ItogFile,Itg^.Dat);
If TestElementSpis_New (Copy(Itg^.Dat.BAzKod,1,CRAzdelKod),TL,regim) Then
Begin
             If Not(TestElement(Itg^.Dat.BAzKod,WL)) Then
              Begin

               Pos:= Location(WL,Itg^.Dat.BAzKod,False);
               ws := WL^.GetText(pos,WL^.List^.Count);
               s:=Copy(ws,1+CName+1+CArtikul+1,Ckol);
               s1:=Copy(ws,1+CName+1+CArtikul+1+CKol+1,Ckol);
           temps:=Copy(ws,1+CName+1+CArtikul+1+CKol+1+CKol+1,Ckol);
               {обрезаем строку}
               ws[0]:=chr(1+CName+1+CArtikul);
               {складываем продажи}

               {Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC):Ckol,s);}

          Case Cl Of
          0:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC):CKol,s);{клиент}
          1:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkS):CKol,s);{склад}
          2:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkB):CKol,s);
          3:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC)+StrToInt(Itg^.Dat.MrkB)+
		                  StrToInt(Itg^.Dat.MrkS):CKol,s);
          Else;
          End;

          Case Clp Of
          0:Str(StrToInt(s1)+StrToInt(Itg^.Dat.PrhC):CKol,s1);{клиент}
          1:Str(StrToInt(s1)+StrToInt(Itg^.Dat.PrhS):CKol,s1);{склад}
          2:Str(StrToInt(s1)+StrToInt(Itg^.Dat.PrhB):CKol,s1);
          3:Str(StrToInt(s1)+StrToInt(Itg^.Dat.PrhC)+StrToInt(Itg^.Dat.PrhB)+
		                   StrToInt(Itg^.Dat.PrhS):CKol,s1);
          Else;
          End;


               {запоминаем последние остатки}
           If (Current=Stop) Then
            Begin
            Str(StrToInt(Itg^.Dat.Ost):Ckol,temps);
            End
            Else
			TempS[0]:=#0;

               ws:=ws+s+'│'+s1+'│'+Temps;

               WL^.List^.AtFree(Pos);
               WL^.SetRange(WL^.List^.Count);

               WL^.List^.Insert(NewStr(ws));
               WL^.SetRange(WL^.List^.Count);
              End
             Else
              Begin
               ws:=GetIdField(FNAme,Itg^.Dat.BAzKod);
               Format(ws,CNAme);


               ws:=ws+'│'+Itg^.Dat.BAzKod+'│';
               Str(StrToInt(Itg^.Dat.MrkC):CKol,Itg^.Dat.MrkC);
               Str(StrToInt(Itg^.Dat.PrhC):CKol,Itg^.Dat.PrhC);

          Case Cl Of
          0:Str(StrToInt(Itg^.Dat.MrkC):CKol,Itg^.Dat.MrkC);{клиент}
          1:Str(StrToInt(Itg^.Dat.MrkS):CKol,Itg^.Dat.MrkC);{склад}
          2:Str(StrToInt(Itg^.Dat.MrkB):CKol,Itg^.Dat.MrkC);
          3:Str(StrToInt(Itg^.Dat.MrkC)+StrToInt(Itg^.Dat.MrkB)+
		      StrToInt(Itg^.Dat.MrkS):CKol,Itg^.Dat.MrkC);
          Else;
          End;

          Case ClP Of
          0:Str(StrToInt(Itg^.Dat.PrhC):CKol,Itg^.Dat.PrhC);{клиент}
          1:Str(StrToInt(Itg^.Dat.PrhS):CKol,Itg^.Dat.PrhC);{склад}
          2:Str(StrToInt(Itg^.Dat.PrhB):CKol,Itg^.Dat.PrhC);
          3:Str(StrToInt(Itg^.Dat.PrhC)+StrToInt(Itg^.Dat.PrhS)
		     +StrToInt(Itg^.Dat.PrhB):CKol,Itg^.Dat.PrhC);
          Else;
          End;



               Str(StrToInt(Itg^.Dat.Ost):CKol,Itg^.Dat.Ost);

               If (Current=Stop) Then
               Str(StrToInt(Itg^.Dat.Ost):Ckol,temps)
               Else
			TempS[0]:=#0;

               ws:=ws+Itg^.Dat.MrkC+'│'+Itg^.Dat.PrhC+'│'+TempS;
               WL^.List^.Insert(NewStr(ws));
               WL^.SetRange(WL^.List^.Count);
              End;
End;{If TestElementSpis}
            End;{While Not Eof(ItogFile)}
           Close(ItogFile);
          End;{ioresult=0}
        End;{for current}


       If WL^.List^.Count>=1 Then
        Begin
         For l:=0 To WL^.List^.Count-1 Do
          Begin
           Itg^.Dat.MrkC[0]:=#0;
           Itg^.Dat.PrhC[0]:=#0;
           Itg^.Dat.PrhB[0]:=#0;
           Itg^.Dat.MrkS[0]:=#0;
           Itg^.Dat.MrkB[0]:=#0;
           Itg^.Dat.PrhS[0]:=#0;
           Itg^.Dat.Ost[0]:=#0;
           ws:=WL^.GetText(l,WL^.List^.Count);
           Itg^.Dat.BazKod:=Copy(ws,1+CName+1,CArtikul);
           Itg^.Dat.MrkC:=Copy(ws,1+CName+1+CArtikul+1,CKol);
           Itg^.Dat.PrhC:=Copy(ws,1+CName+1+CArtikul+1+CKol+1,CKol);
           Itg^.Dat.Ost :=Copy(ws,1+CName+1+CArtikul+1+CKol+1+CKol+1,CKol);
           Str(StrToInt(Itg^.Dat.Ost):CKol,Itg^.Dat.Ost);
           Str(StrToInt(Itg^.Dat.MrkC):CKol,Itg^.Dat.MrkC);
           Str(StrToInt(Itg^.Dat.PrhC):CKol,Itg^.Dat.PrhC);

           Seek(WeekFile,FileSize(WeekFile));
           Write(WeekFile,Itg^.Dat);
          End;{For по списку}
        End;{WspomList}

      Dispose(WL,Done);
      Close(WeekFile);
    End;{IOResult=0}
 inc(current);
 inc(CurrentWeek);
end;{While}
Dispose(Itg,Done);

End;


Procedure RashetProdag(Const Spis:PBox;Assort,Sort:Word);
label m1;

              {123456123456123456123456123456123456123456123456123456}
Var R,R1 : TRect;
    Txt : Text;
    rs,Shablon,s1,RazdelName,Fas,TempArtikul,s,ss : TMyString;
    ws : String;
    Reiting,SumKol,Ext,Space : TEnJoyStr;
    TempList : PBox;
    WspomList1,WspomList2,WspomList: PBox;
    EdIzm,Regim : Word;
    Separator : ArtikulStr;
    SInPack,MarketKol,MarketPack:string[CPack];
    Art,PositionZena,Date : TDateString;
    l,l1,EE,EE1,l2 : LongInt;
    Pos,j,i,Srok,Day: Word;
    Start : TDAteString;
    Itg : PNewItogType;
    ItogFile  : File Of NewItogType;
    Position,Cl,Dopoln : Word;
    ssort:Byte;
    Shapka : Array[1..4] Of TMyString;
    LastZakupka,LastDate : TDAteString;

Begin
 Separator:=' ';
 Assign(Txt,Path.ToTemp+'mrk_ost.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'mrk_ost.txt',Nil,mfError+mfCancelButton);
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

Day:=0;
Srok:=8;
If Not SelectVidOstatkiMarket(Day,Srok,Start) Then
 Begin
      Dispose(TempList,Done);
      Exit;
 End;

 EdIzm:=SelectImport(2);
      If EdIzm=2 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;

 Dopoln:=0;
 Dopoln:=SelectImport(6);
      If Dopoln=2 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;


 SSort:=SelectSpecify(False,5);
      If SSort=3 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;
 Sort:=SSort;

 Cl:=SelectSpecify(FAlse,8);
      If Cl=4 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;


  DInfo('Анализирую остатки и продажи...');
  Append(txt);
  Space:='';
  Writeln(Txt,Space+'Склад:'+FormKod(Rek.Kod)+' Оператор: '+CurrentPassword);
  Writeln(Txt,Space+'Дата и время расчета: '+FDate+'  ('+Times+')');
  Write(Txt,Space+'Вид отбора отгрузки: ');
  Case Cl Of
  3:Writeln(txt,'{Все}');
  2:Writeln(txt,'{Взаимозачет}');
  0:Writeln(txt,'{Клиент}');
  1:Writeln(txt,'{Склад}');
  Else Writeln(txt);
  End;
  Write(Txt,Space+'Вид сортировки товара: ');
  Case Sort Of
  2:Writeln(txt,'{По штучным продажам (по убыванию)}');
  1:Writeln(txt,'{По наименованию}');
  0:Writeln(txt,'{По кодам}');
  Else Writeln(txt);
  End;

  Write(Txt,Space+'Вид сортировки разделов: ');
  Case Regim Of
  1:Writeln(txt,'{По наименованиям разделов}');
  0:Writeln(txt,'{По кодам разделов}');
  Else Writeln(txt);
  End;
  Write(Txt,Space+'Единицы измерения: ');
  Case EdIzm Of
  0:Writeln(txt,'{Штуки}');
  1:Writeln(txt,'{Упаковки}');
  Else Writeln(txt);
  End;
  Writeln(txt);

  Write(Txt,Space+'Дополнительно: ');
  Case Dopoln Of
  0:Writeln(txt,'{Включить рейтинг}');
  1:Writeln(txt,'{Включить З/Цены}');
  Else Writeln(txt);
  End;
  Writeln(txt);



 s:=' Код |Наименование товара       |Фас';
    {12345 12345678901234567890123456 123}
s1:='     |                          |   ';
EE:=DateStringToDate(DateMask,Start);
if day=0 then
EE1:=EE-Srok+1{чтобы учесть текущий день}
else
EE1:=EE-Srok*7+1;

Space:='';
Shablon[0]:=#0;
Writeln(Txt,Space+' ВЕДОМОСТЬ ОСТАТКОВ и ОТГРУЗКИ ТОВАРА за период с '+DAteToDateString(DAteMask,EE1)+' по '+Start);
If Day=0 Then
Writeln(Txt,Space+' Количество дней в расчете: ',Srok:1)
Else
Writeln(Txt,Space+' Количество недель в расчете: ',Srok:1);

Writeln(Txt,Space+'{Обозначения: "-" нет остатков  "?" нет данных}');

Writeln(Txt,Space+Condensed[NPrint.Printer]);


    Str(StrToInt(Rek.Kod):2,Ext);
    RFormatZerro(Ext,2);

if day=1 then SpecialCompressReport(EE1,EE,Cl,Cl,TempList,Regim);

Space:='';
j:=1;
For l:=EE1 To EE Do
Begin
ws:=DAteToDAteString('  dd.mm  ',l);
If Day=1 Then ws[1]:='с';
s:=s+'|'+ws;
if day=1 then
  Begin
   ss:=inttostr(j,COne);
   Format(ss,CMantissa);
  End
else
  ss:=DayString[DayOfWeek(l)];
ss:='    '+ss+'   ';
s1:=s1+'|'+ss;
If Day=0 Then
Begin
If Not(FExists(Path.ToArchiv+DAteToDAteString(DateMask,l)+'.p'+Ext)) Then
Shablon:=Shablon+'    ?    '+'|'
Else
Shablon:=Shablon+'    -    '+'|';
End
 Else
  Begin
If Not(FExists(Path.ToTemp+IntToStr(j,COne)+'.w'+IntToStr(j,COne))) Then
Shablon:=Shablon+'    ?    '+'|'
Else
Shablon:=Shablon+'    -    '+'|';
inc(l,6);
if l>ee then break;
  End;
inc(j);
End;

if day=0 then
begin
If Not(FExists(Path.ToArchiv+DAteToDAteString(DateMask,EE)+'.p'+Ext)) Then
Shablon:=Shablon+'    ?    ' Else Shablon:=Shablon+'    -    ';
end
else
 begin
If Not(FExists(Path.ToTemp+IntToStr(Srok,COne)+'.w'+IntToStr(Srok,COne))) Then
Shablon:=Shablon+'    ?    ' Else Shablon:=Shablon+'    -    ';
 end;

If Day=1 Then
Begin
ws:=DAteToDAteString('   dd.mm ',EE);
ws[1]:='Н';ws[2]:='а';
End;

If Dopoln=0 Then
s:=s+'   остат     прод.    рейтинг '
Else
s:=s+'   остат     прод.    З/Цена  ';

s1:=s1+'|'+ws+'|'+'    E    |        |';

ws[0]:=#0;
For l:=1 To Ord(s[0]) Do
Begin
ws[l]:='_';
ws[0]:=Chr(l);
End;

rs:=ws;

{
Writeln(Txt,Space+ws);
Writeln(Txt,Space+s1);
Writeln(Txt,Space+s);
Writeln(Txt,Space+ws);
}
Shapka[1]:=ws;
Shapka[2]:=s1;
Shapka[3]:=s;
Shapka[4]:=ws;



  R1.Assign(0,0,0,0);
  WspomlIST := New(PBox, Init(R1, 1, Nil));
  WspomList^.NewList(New(PTextCollection, Init(0,1)));
  j:=0;
  New(Itg,Init);
  For L:=EE1 To EE Do
   Begin
    Str(StrToInt(Rek.Kod):2,Ext);
    RFormatZerro(Ext,2);

    l2:=l;

m1:    s:=DAteToDAteString(DateMask,l2);

    If Day=0 Then
    Assign(ItogFile,Path.ToArchiv+s+'.p'+Ext)
    Else
    Assign(ItogFile,Path.ToTemp+IntToStr(j+1,COne)+'.w'+IntToStr(j+1,COne));

    i:=IOResult;
    Reset(ItogFile);
    i:=IOResult;

    if i<>0 then
    if l-l2<5 then
    begin
     dec(l2);
     goto m1;
    end;

    If i=0 Then
     Begin
      While Not(Eof(ItogFile)) Do
       Begin
        Read(ItogFile,Itg^.Dat);
{       If Not TestElement(Copy(Itg^.Dat.BAzKod,1,CRAzdelKod),TempList) Then}
If TestElementSpis_New (Copy(Itg^.Dat.BAzKod,1,CRAzdelKod),TempList,regim) Then
   Begin
        If Not(TestElement(Itg^.Dat.BAzKod,WspomList)) Then
         Begin
          Pos:= Location(WspomList,Itg^.Dat.BAzKod,False);
          ws := WspomList^.GetText(pos,WspomList^.List^.Count);
          s:=Copy(ws,1+CName+1+CArtikul+1+(CPack+1)*j,CPack);
          Delete(ws,1+CName+1+CArtikul+1+(CPAck+1)*j,CPAck);

          if day=0 then{для случая расчета по дням}
          begin
          Case Cl Of
          0:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC):CPAck,s);{клиент}
          1:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkS):CPAck,s);{склад}
          2:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkB):CPAck,s);
          3:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC)+StrToInt(Itg^.Dat.MrkS)+
		      StrToInt(Itg^.Dat.MrkB):CPAck,s);
          Else;
          End;
          end
           else Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC):CPAck,s);{для случая недель}


          Insert(s,ws,1+CName+1+CArtikul+1+(CPAck+1)*j);

          If Day=0 Then
          Begin
          If l=EE Then
           Begin
            Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
            Str(StrToInt(Itg^.Dat.Ost):CPAck,s);
            ws:=ws+s;
           End;
          End
          Else
           Begin
          If (j+1)=Srok Then
           Begin
            Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
            Str(StrToInt(Itg^.Dat.Ost):CPAck,s);
            ws:=ws+s;
           End;

           End;

          WspomList^.List^.AtFree(Pos);
          WspomList^.SetRange(WspomList^.List^.Count);

          WspomList^.List^.Insert(NewStr(ws));
          WspomList^.SetRange(WspomList^.List^.Count);
         End
         Else
          Begin
            ws:=GetIdField(FNAme,Itg^.Dat.BAzKod);
            Format(ws,CNAme);

            ws:=ws+'│'+Itg^.Dat.BAzKod+'│'+Shablon;


            Delete(ws,1+CName+1+CArtikul+1+(CPAck+1)*j,CPAck);

          if day=0 Then{для случая расчета по дням}
          Begin
          Case Cl Of
          0:Str(StrToInt(Itg^.Dat.MrkC):CPAck,s);{клиент}
          1:Str(StrToInt(Itg^.Dat.MrkS):CPAck,s);{склад}
          2:Str(StrToInt(Itg^.Dat.MrkB):CPAck,s);
          3:Str(StrToInt(Itg^.Dat.MrkC)+StrToInt(Itg^.Dat.MrkS)+StrToInt(Itg^.Dat.MrkB):CPAck,s);
          Else;
          End;
          End
          Else Str(StrToInt(Itg^.Dat.MrkC):CPAck,s);{для случая недель}

            {Str(StrToInt(Itg^.Dat.MrkC):CPAck,s);}

            Insert(s,ws,1+CName+1+CArtikul+1+(CPAck+1)*j);
          If Day=0 Then
          Begin
          If l=EE Then
           Begin
            Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
            Str(StrToInt(Itg^.Dat.Ost):CPAck,s);
            ws:=ws+s;
           End;
          End
           Else
            Begin
          If (j+1)=Srok Then
           Begin
            Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
            Str(StrToInt(Itg^.Dat.Ost):CPAck,s);
            ws:=ws+s;
           End;

            End;

            WspomList^.List^.Insert(NewStr(ws));
            WspomList^.SetRange(WspomList^.List^.Count);
          End;
  End;

       End;{While Not(Eof)}
      Close(ItogFile);{IOResult=0}
     End
      Else
       Begin
       End;
     Inc(j);{счетчик дней}
   End;{for по датам}
   Dispose(Itg,Done);

{вставить код расчета сводных продаж}
  R.Assign(0,0,0,0);
  WspomlIST2 := New(PBox, Init(R1, 1, Nil));
  WspomList2^.NewList(New(PTextCollection, Init(0,1)));
DistanationSorting:=False;
If WspomList^.List^.Count>=1 Then
Begin
  For j:=0 To WspomList^.List^.Count-1 Do
   Begin
    ws:=WspomList^.GetText(j,WspomList^.List^.Count);
    Art:=Copy(ws,1+CName+1,CArtikul);
    SumKol[0]:=#0;
    For i:=0 To Srok-1 Do
     Begin
      ss:=Copy(ws,1+CName+1+CArtikul+1+(CPAck+1)*i,CPAck);
      Str(StrToInt(SumKol)+StrToInt(ss):CPAck+1,SumKol);
     End;
     ws:=SumKol+'│'+Art;
     WspomList2^.List^.Insert(NewStr(ws));
     WspomList2^.SetRange(WspomList2^.List^.Count);
   End;{For}
End;{If WspomList^.List^.Count>=1 Then}
{конец расчета сводных продаж}
DistanationSorting:=True;


{вставить сортировку наименований внутри раздела}
  R.Assign(0,0,0,0);
  WspomlIST1 := New(PBox, Init(R1, 1, Nil));
  WspomList1^.NewList(New(PTextCollection, Init(0,1)));

If WspomList^.List^.Count>=1 Then
Begin
  For j:=0 To WspomList^.List^.Count-1 Do
   Begin
    ws:=WspomList^.GetText(j,WspomList^.List^.Count);
(*  Case Sort Of
    0:Begin
       ss:=Copy(ws,1+CName+1,CArtikul);
       ws:=ss+'│'+ws;
       Art:=ss;
      End;
    1: Art:=Copy(ws,1+CName+1,CArtikul);
    2:Begin
       ss:=Copy(ws,Ord(ws[0])-CPack+1,CPack);
       ws:=ss+'│'+ws;
       Art:=ss;
      End;
    Else;
    End;
*)
   If Sort=0 Then{по коду}
    Begin
     ss:=Copy(ws,1+CName+1,CArtikul);
     ws:=ss+'│'+ws;
     Art:=ss;
    End
    Else Art:=Copy(ws,1+CName+1,CArtikul);

    s:=Copy(ws,Ord(ws[0])-CPAck+1,CPAck);
     Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
    If Not(System.Pos('?',s)>0) Then
     Begin
	 Str(StrToInt(s):CPAck,s);
      If EdIzm=1 Then
        Begin
         DelSpace(s);
         MarketPack:=CalcPack(Art,s);
         s:=MarketPack;
        End;
     End;
     ws:=ws+s;


    WspomList1^.List^.Insert(NewStr(ws));
    WspomList1^.SetRange(WspomList1^.List^.Count);
   End;{For}
  WspomList^.NewList(Nil);
  WspomList^.NewList(New(PTextCollection, Init(0,1)));
  For j:=0 To WspomList1^.List^.Count-1 Do
   Begin
    ws:=WspomList1^.GetText(j,WspomList1^.List^.Count);
    WspomList^.List^.Insert(NewStr(ws));
    WspomList^.SetRange(WspomList^.List^.Count);
   End;{For}
End;
Dispose(WspomList1,Done);


If WspomList^.List^.Count>=1 Then
 Begin
 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else
  s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);

If TestElementSpis_New (S,WspomList,Sort) Then
Begin

  Writeln(Txt);
  Writeln(Txt,Space+'                    Раздел: '+GetRazdel(s));

Writeln(Txt,Space+Shapka[1]);
Writeln(Txt,Space+Shapka[2]);
Writeln(Txt,Space+Shapka[3]);
Writeln(Txt,Space+Shapka[4]);

If Sort<>2 Then
Begin
  For j:=0 To WspomList^.List^.Count-1 Do
   Begin
    ws:=WspomList^.GetText(j,WspomList^.List^.Count);
    If Sort=0 Then Delete(ws,1,CArtikul+1);
    ss:=Copy(ws,1+CName+1,CArtikul);
    Art:=ss;
  If StrToInt(Copy(ss,1,CRAzdelKod))=StrToInt(s) Then
  Begin
    Delete(ws,1+CNAme+1,CArtikul+1);
    ws:=ss+'|'+ws;

  SumKol[0]:=#0;
  Reiting[0]:=#0;
  l1:=0;
  For i:=0 To Srok-1 Do
   Begin
    ss:=Copy(ws,1+CName+1+CArtikul+1+(CPAck+1)*i,CPAck);
    If Not(System.Pos('?',ss)>0) And Not(System.Pos('-',ss)>0) Then inc(l1);
    If EdIzm=1 Then
     Begin
      If Not(System.Pos('?',ss)>0) And Not(System.Pos('-',ss)>0) Then
       Begin
        DelSpace(ss);
        MarketPack:=CalcPack(Art,ss);
        Delete(ws,1+CName+1+CArtikul+1+(CPAck+1)*i,CPAck);
        Insert(MarketPack,ws,1+CName+1+CArtikul+1+(CPAck+1)*i);
       End;
     End;
    ws[1+CName+1+CArtikul+1+(CPAck+1)*i-1]:='|';
    Str(StrToInt(SumKol)+StrToInt(ss):CPAck,SumKol);
   End;
  ws[1+CName+1+CArtikul+1+(CPAck+1)*Srok-1]:='|';

  If l1>0 Then Str(StrToInt(SumKol) div l1:CPAck,Reiting)
  Else Reiting:='    ?    ';

  If EdIzm=1 Then
   Begin
    DelSpace(SumKol);
    SumKol:=CalcPack(Art,SumKol);
   End;

  If EdIzm=1 Then
   Begin
    DelSpace(Reiting);
    Reiting:=CalcPack(Art,Reiting);
   End;

  If Dopoln=1 Then
   Begin
    Reiting:=BakGetField(FZakupka,Art,0);
    Str(StrToReal(Reiting):CZena:CMantissa,Reiting);
   End;

{
  LastZakupka:=BakGEtField(FZakupka,Art,0);
  Str(StrToREal(LastZakupka):CZena-2:CMantissa,LastZakupka);
}
  {LastDate:=BakGEtField(FDAtePrihod,Art,0);}
  DelSpace(LastDate);
  If LastDate[0]=#0 Then Format(LastDate,5);
  {LastDate[0]:=#5;}

  ws:=ws+'|'+SumKol+'|'+{LastDate+'|'+LastZakupka}+Reiting;

  {ws:=ws+'|'+SumKol{+'|'+Reiting};

  SumKol:=GetIdField(FInPack,Art);
  DelSpace(SumKol);
  RFormat(SumKol,CInPAck);

  Insert(SumKol+'|',ws,1+CArtikul+1+CName+1);

   While System.Pos('│',ws)>0 Do
    Begin
     i:=System.Pos('│',ws);
     ws[i]:='|';
    End;

  Writeln(txt,Space+ws);
End;
  End;
   End{Sort<>2}
Else
 Begin {Sort=2}
  For j:=0 To WspomList2^.List^.Count-1 Do
   Begin
    ws:=WspomList2^.GetText(j,WspomList2^.List^.Count);
    ss:=Copy(ws,1+CPack+1+1,CArtikul);
    Art:=ss;
  If StrToInt(Copy(ss,1,CRAzdelKod))=StrToInt(s) Then
  Begin
    Position:=Location(WspomList,ss,(Sort=0));
    ws:=WspomList^.GetText(Position,WspomList^.List^.Count);

    If Sort=0 Then Delete(ws,1,CArtikul+1);

    Delete(ws,1+CNAme+1,CArtikul+1);
    ws:=ss+'|'+ws;

  SumKol[0]:=#0;
  Reiting[0]:=#0;
  l1:=0;
  For i:=0 To Srok-1 Do
   Begin
    ss:=Copy(ws,1+CName+1+CArtikul+1+(CPAck+1)*i,CPAck);
    If Not(System.Pos('?',ss)>0) And Not(System.Pos('-',ss)>0) Then inc(l1);
    If EdIzm=1 Then
     Begin
      If Not(System.Pos('?',ss)>0) And Not(System.Pos('-',ss)>0) Then
       Begin
        DelSpace(ss);
        MarketPack:=CalcPack(Art,ss);
        Delete(ws,1+CName+1+CArtikul+1+(CPAck+1)*i,CPAck);
        Insert(MarketPack,ws,1+CName+1+CArtikul+1+(CPAck+1)*i);
       End;
     End;
    ws[1+CName+1+CArtikul+1+(CPAck+1)*i-1]:='|';
    Str(StrToInt(SumKol)+StrToInt(ss):CPAck,SumKol);
   End;
  ws[1+CName+1+CArtikul+1+(CPAck+1)*Srok-1]:='|';

  If l1>0 Then Str(StrToInt(SumKol) div l1:CPAck,Reiting)
  Else Reiting:='    ?    ';

  If EdIzm=1 Then
   Begin
    DelSpace(SumKol);
    SumKol:=CalcPack(Art,SumKol);
   End;

  If EdIzm=1 Then
   Begin
    DelSpace(Reiting);
    Reiting:=CalcPack(Art,Reiting);
   End;

  If Dopoln=1 Then
   Begin
    Reiting:=BakGetField(FZakupka,Art,0);
    Str(StrToReal(Reiting):CZena:CMantissa,Reiting);
   End;

{
  LastZakupka:=BakGEtField(FZakupka,Art,0);
  Str(StrToREal(LastZakupka):CZena-2:CMantissa,LastZakupka);
}
  {LastDate:=BakGEtField(FDAtePrihod,Art,0);}
  DelSpace(LastDate);
  If LastDate[0]=#0 Then Format(LastDate,5);

  {LastDate[0]:=#5;}

  ws:=ws+'|'+SumKol+'|'+{LastDate+'|'}+Reiting;

  SumKol:=GetIdField(FInPack,Art);
  DelSpace(SumKol);
  RFormat(SumKol,CInPAck);

  Insert(SumKol+'|',ws,1+CArtikul+1+CName+1);

   While System.Pos('│',ws)>0 Do
    Begin
     i:=System.Pos('│',ws);
     ws[i]:='|';
    End;

  Writeln(txt,Space+ws);
End;
  End;

 End;{Else т.е. режим сортировки по продажам}
   End;

 End;{for по разделам}
 End;

ws[0]:=#0;
For l:=1 To Ord(rs[0]) Do
Begin
ws[l]:='=';
ws[0]:=Chr(l);
End;

Writeln(Txt);
Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(Txt,Space+ws+NoCondensed[NPrint.Printer]);
Close(txt);


 Dispose(WspomList,Done);
 Dispose(WspomList2,Done);

 Dispose(TempList,Done);
 NoInfo;
 ViewAsText(Path.ToTemp+'mrk_ost.txt',True);
 Report(Path.ToTemp+'mrk_ost.txt','',1,False,False,false);
End;


(*
Procedure RashetProdag(Const Spis:PBox;Const M:Maska; Assort,Sort:Word);


              {123456123456123456123456123456123456123456123456123456}
Var R,R1 : TRect;
    Txt : Text;
    rs,Shablon,s1,RazdelName,Fas,TempArtikul,s,ss : TMyString;
    ws,ws1,ws2 : String;
    Reiting,SumKol,Ext,Space : TEnJoyStr;
    TempList : PBox;
    WspomList1,WspomList2,WspomList: PBox;
    EdIzm,Regim : Word;
    Separator : ArtikulStr;
    SInPack,MarketKol,MarketPack:string[CPack];
    Art,PositionZena,Date : TDateString;
    l,l1,EE,EE1 : LongInt;
    Pos,j,i,Srok,Day: Word;
    Start : TDAteString;
    Itg : PNewItogType;
    ItogFile  : File Of NewItogType;
    Position,Cl,Dopoln : Word;
    ssort:Byte;
    Shapka : Array[1..4] Of TMyString;

Begin
 Separator:=' ';
 Assign(Txt,Path.ToTemp+'mrk_ost.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'mrk_ost.txt',Nil,mfError+mfCancelButton);
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


If Not SelectVidOstatkiMarket(Day,Srok,Start) Then
 Begin
      Dispose(TempList,Done);
      Exit;
 End;

 EdIzm:=SelectImport(2);
      If EdIzm=2 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;

 Dopoln:=0;
 Dopoln:=SelectImport(6);
      If Dopoln=2 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;

 SSort:=SelectSpecify(False,5);
      If SSort=3 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;
 Sort:=SSort;

 Cl:=SelectSpecify(FAlse,6);
      If Cl=3 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;


  DInfo('Анализирую остатки и продажи...');
  Append(txt);
  Space:='   ';
  Writeln(Txt,Space+'Склад:'+FormKod(Rek.Kod)+' Оператор: '+CurrentPassword);
  Writeln(Txt,Space+'Дата и время расчета: '+FDate+'  ('+Times+')');
  Write(Txt,Space+'Вид отбора отгрузки: ');
  Case Cl Of
  2:Writeln(txt,'{Все}');
  0:Writeln(txt,'{Клиент}');
  1:Writeln(txt,'{Склад}');
  Else Writeln(txt);
  End;
  Write(Txt,Space+'Вид сортировки товара: ');
  Case Sort Of
  2:Writeln(txt,'{По штучным продажам (по убыванию)}');
  1:Writeln(txt,'{По наименованию}');
  0:Writeln(txt,'{По кодам}');
  Else Writeln(txt);
  End;

  Write(Txt,Space+'Вид сортировки разделов: ');
  Case Regim Of
  1:Writeln(txt,'{По наименованиям разделов}');
  0:Writeln(txt,'{По кодам разделов}');
  Else Writeln(txt);
  End;

  Write(Txt,Space+'Единицы измерения: ');
  Case EdIzm Of
  0:Writeln(txt,'{Штуки}');
  1:Writeln(txt,'{Упаковки}');
  Else Writeln(txt);
  End;

  Write(Txt,Space+'Дополнительно: ');
  Case Dopoln Of
  0:Writeln(txt,'{Включить рейтинг}');
  1:Writeln(txt,'{Включить З/Цены}');
  Else Writeln(txt);
  End;
  Writeln(txt);


 s:=' Код  Наименование товара        Фас';
    {12345 12345678901234567890123456 123}
s1:='                                    ';
EE:=DateStringToDate(DateMask,Start);
if day=0 then
EE1:=EE-Srok+1{чтобы учесть текущий день}
else
EE1:=EE-Srok*7+1;

Space:='    ';
Shablon[0]:=#0;
Writeln(Txt,Space+' ВЕДОМОСТЬ ОСТАТКОВ и ОТГРУЗКИ ТОВАРА за период с '+DAteToDateString(DAteMask,EE1)+' по '+Start);
If Day=0 Then
Writeln(Txt,Space+' Количество дней в расчете: ',Srok:1)
Else
Writeln(Txt,Space+' Количество недель в расчете: ',Srok:1);

Writeln(Txt,Space+'{Обозначения: "-" нет остатков  "?" нет данных}');

Writeln(Txt,Space+Condensed[NPrint.Printer]);


    Str(StrToInt(Rek.Kod):2,Ext);
    RFormatZerro(Ext,2);

if day=1 then CompressReport(EE1,EE,Cl,TempList,Regim);



Space:='    ';
j:=1;
For l:=EE1 To EE Do
Begin
ws:=DAteToDAteString('  dd.mm  ',l);
If Day=1 Then ws[1]:='с';
s:=s+' '+ws;
if day=1 then
  Begin
   ss:=inttostr(j,COne);
   Format(ss,CMantissa);
  End
else
  ss:=DayString[DayOfWeek(l)];
ss:='    '+ss+'   ';
s1:=s1+' '+ss;
If Day=0 Then
Begin
If Not(FExists(Path.ToArchiv+DAteToDAteString(DateMask,l)+'.i'+Ext)) Then
Shablon:=Shablon+'    ?    '+' '
Else
Shablon:=Shablon+'    -    '+' ';
End
 Else
  Begin
If Not(FExists(Path.ToTemp+IntToStr(j,COne)+'.w'+IntToStr(j,COne))) Then
Shablon:=Shablon+'    ?    '+' '
Else
Shablon:=Shablon+'    -    '+' ';
inc(l,6);
if l>ee then break;
  End;
inc(j);
End;

if day=0 then
begin
If Not(FExists(Path.ToArchiv+DAteToDAteString(DateMask,EE)+'.i'+Ext)) Then
Shablon:=Shablon+'    ?    ' Else Shablon:=Shablon+'    -    ';
end
else
 begin
If Not(FExists(Path.ToTemp+IntToStr(Srok,COne)+'.w'+IntToStr(Srok,COne))) Then
Shablon:=Shablon+'    ?    ' Else Shablon:=Shablon+'    -    ';
 end;

If Day=1 Then
Begin
ws:=DAteToDAteString('   dd.mm ',EE);
ws[1]:='Н';ws[2]:='а';
End;

If Dopoln=0 Then
s:=s+'   остат     прод.    рейтинг '
Else
s:=s+'   остат     прод.    З/Цена  ';

s1:=s1+' '+ws+'    E         E';

ws[0]:=#0;
For l:=1 To Ord(s[0]) Do
Begin
ws[l]:='_';
ws[0]:=Chr(l);
End;

rs:=ws;

{
Writeln(Txt,Space+ws);
Writeln(Txt,Space+s1);
Writeln(Txt,Space+s);
Writeln(Txt,Space+ws);
}
Shapka[1]:=ws;
Shapka[2]:=s1;
Shapka[3]:=s;
Shapka[4]:=ws;



  R1.Assign(0,0,0,0);
  WspomlIST := New(PBox, Init(R1, 1, Nil));
  WspomList^.NewList(New(PTextCollection, Init(0,1)));
  j:=0;
  New(Itg,Init);
  For L:=EE1 To EE Do
   Begin
    Str(StrToInt(Rek.Kod):2,Ext);
    RFormatZerro(Ext,2);
    s:=DAteToDAteString(DateMask,l);
    If Day=0 Then
    Assign(ItogFile,Path.ToArchiv+s+'.i'+Ext)
    Else
    Assign(ItogFile,Path.ToTemp+IntToStr(j+1,COne)+'.w'+IntToStr(j+1,COne));

    i:=IOResult;
    Reset(ItogFile);
    i:=IOResult;
    If i=0 Then
     Begin
      While Not(Eof(ItogFile)) Do
       Begin
        Read(ItogFile,Itg^.Dat);
{       If Not TestElement(Copy(Itg^.Dat.BAzKod,1,CRAzdelKod),TempList) Then}
If TestElementSpis_New (Copy(Itg^.Dat.BAzKod,1,CRAzdelKod),TempList,regim) Then
   Begin
        If Not(TestElement(Itg^.Dat.BAzKod,WspomList)) Then
         Begin
          Pos:= Location(WspomList,Itg^.Dat.BAzKod,False);
          ws := WspomList^.GetText(pos,WspomList^.List^.Count);
          s:=Copy(ws,1+CName+1+CArtikul+1+(CPack+1)*j,CPack);
          Delete(ws,1+CName+1+CArtikul+1+(CPAck+1)*j,CPAck);

          if day=0 then{для случая расчета по дням}
          begin
          Case Cl Of
          0:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC):CPAck,s);{клиент}
          1:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkS):CPAck,s);{склад}
          2:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC)+StrToInt(Itg^.Dat.MrkS):CPAck,s);
          Else;
          End;
          end
           else Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC):CPAck,s);{для случая недель}


          Insert(s,ws,1+CName+1+CArtikul+1+(CPAck+1)*j);

          If Day=0 Then
          Begin
          If l=EE Then
           Begin
            Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
            Str(StrToInt(Itg^.Dat.Ost):CPAck,s);
            ws:=ws+s;
           End;
          End
          Else
           Begin
          If (j+1)=Srok Then
           Begin
            Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
            Str(StrToInt(Itg^.Dat.Ost):CPAck,s);
            ws:=ws+s;
           End;

           End;

          WspomList^.List^.AtFree(Pos);
          WspomList^.SetRange(WspomList^.List^.Count);

          WspomList^.List^.Insert(NewStr(ws));
          WspomList^.SetRange(WspomList^.List^.Count);
         End
         Else
          Begin
            ws:=GetIdField(FNAme,Itg^.Dat.BAzKod);
            Format(ws,CNAme);

            ws:=ws+'│'+Itg^.Dat.BAzKod+'│'+Shablon;


            Delete(ws,1+CName+1+CArtikul+1+(CPAck+1)*j,CPAck);

          if day=0 Then{для случая расчета по дням}
          Begin
          Case Cl Of
          0:Str(StrToInt(Itg^.Dat.MrkC):CPAck,s);{клиент}
          1:Str(StrToInt(Itg^.Dat.MrkS):CPAck,s);{склад}
          2:Str(StrToInt(Itg^.Dat.MrkC)+StrToInt(Itg^.Dat.MrkS):CPAck,s);
          Else;
          End;
          End
          Else Str(StrToInt(Itg^.Dat.MrkC):CPAck,s);{для случая недель}

            {Str(StrToInt(Itg^.Dat.MrkC):CPAck,s);}

            Insert(s,ws,1+CName+1+CArtikul+1+(CPAck+1)*j);
          If Day=0 Then
          Begin
          If l=EE Then
           Begin
            Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
            Str(StrToInt(Itg^.Dat.Ost):CPAck,s);
            ws:=ws+s;
           End;
          End
           Else
            Begin
          If (j+1)=Srok Then
           Begin
            Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
            Str(StrToInt(Itg^.Dat.Ost):CPAck,s);
            ws:=ws+s;
           End;

            End;


            WspomList^.List^.Insert(NewStr(ws));
            WspomList^.SetRange(WspomList^.List^.Count);
          End;
  End;

       End;{While Not(Eof)}
      Close(ItogFile);{IOResult=0}
     End
      Else
       Begin
       End;
     Inc(j);{счетчик дней}
   End;{for по датам}
   Dispose(Itg,Done);

{вставить код расчета сводных продаж}
  R.Assign(0,0,0,0);
  WspomlIST2 := New(PBox, Init(R1, 1, Nil));
  WspomList2^.NewList(New(PTextCollection, Init(0,1)));
DistanationSorting:=False;
If WspomList^.List^.Count>=1 Then
Begin
  For j:=0 To WspomList^.List^.Count-1 Do
   Begin
    ws:=WspomList^.GetText(j,WspomList^.List^.Count);
    Art:=Copy(ws,1+CName+1,CArtikul);
    SumKol[0]:=#0;
    For i:=0 To Srok-1 Do
     Begin
      ss:=Copy(ws,1+CName+1+CArtikul+1+(CPAck+1)*i,CPAck);
      Str(StrToInt(SumKol)+StrToInt(ss):CPAck+1,SumKol);
     End;
     ws:=SumKol+'│'+Art;
     WspomList2^.List^.Insert(NewStr(ws));
     WspomList2^.SetRange(WspomList2^.List^.Count);
   End;{For}
End;{If WspomList^.List^.Count>=1 Then}
{конец расчета сводных продаж}
DistanationSorting:=True;


{вставить сортировку наименований внутри раздела}
  R.Assign(0,0,0,0);
  WspomlIST1 := New(PBox, Init(R1, 1, Nil));
  WspomList1^.NewList(New(PTextCollection, Init(0,1)));

If WspomList^.List^.Count>=1 Then
Begin
  For j:=0 To WspomList^.List^.Count-1 Do
   Begin
    ws:=WspomList^.GetText(j,WspomList^.List^.Count);
{
  Case Sort Of
    0:Begin
       ss:=Copy(ws,1+CName+1,CArtikul);
       ws:=ss+'│'+ws;
       Art:=ss;
      End;
    1: Art:=Copy(ws,1+CName+1,CArtikul);
    2:Begin
       ss:=Copy(ws,Ord(ws[0])-CPack+1,CPack);
       ws:=ss+'│'+ws;
       Art:=ss;
      End;
    Else;
    End;
}
   If Sort=0 Then{по коду}
    Begin
     ss:=Copy(ws,1+CName+1,CArtikul);
     ws:=ss+'│'+ws;
     Art:=ss;
    End
    Else Art:=Copy(ws,1+CName+1,CArtikul);

    s:=Copy(ws,Ord(ws[0])-CPAck+1,CPAck);
     Delete(ws,Ord(ws[0])-CPAck+1,CPAck);
    If Not(System.Pos('?',s)>0) Then
     Begin
	 Str(StrToInt(s):CPAck,s);
      If EdIzm=1 Then
        Begin
         DelSpace(s);
         MarketPack:=CalcPack(Art,s);
         s:=MarketPack;
        End;
     End;
     ws:=ws+s;


    WspomList1^.List^.Insert(NewStr(ws));
    WspomList1^.SetRange(WspomList1^.List^.Count);
   End;{For}
  WspomList^.NewList(Nil);
  WspomList^.NewList(New(PTextCollection, Init(0,1)));
  For j:=0 To WspomList1^.List^.Count-1 Do
   Begin
    ws:=WspomList1^.GetText(j,WspomList1^.List^.Count);
    WspomList^.List^.Insert(NewStr(ws));
    WspomList^.SetRange(WspomList^.List^.Count);
   End;{For}
End;
Dispose(WspomList1,Done);


If WspomList^.List^.Count>=1 Then
 Begin
 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else
  s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);

If TestElementSpis_New (S,WspomList,Sort) Then
Begin

  Writeln(Txt);
  Writeln(Txt,Space+'                    Раздел: '+GetRazdel(s));

Writeln(Txt,Space+Shapka[1]);
Writeln(Txt,Space+Shapka[2]);
Writeln(Txt,Space+Shapka[3]);
Writeln(Txt,Space+Shapka[4]);

If Sort<>2 Then
Begin
  For j:=0 To WspomList^.List^.Count-1 Do
   Begin
    ws:=WspomList^.GetText(j,WspomList^.List^.Count);
    If Sort=0 Then Delete(ws,1,CArtikul+1);
    ss:=Copy(ws,1+CName+1,CArtikul);
    Art:=ss;
  If StrToInt(Copy(ss,1,CRAzdelKod))=StrToInt(s) Then
  Begin
    Delete(ws,1+CNAme+1,CArtikul+1);
    ws:=ss+' '+ws;

  SumKol[0]:=#0;
  Reiting[0]:=#0;
  l1:=0;
  For i:=0 To Srok-1 Do
   Begin
    ss:=Copy(ws,1+CName+1+CArtikul+1+(CPAck+1)*i,CPAck);
    If Not(System.Pos('?',ss)>0) And Not(System.Pos('-',ss)>0) Then inc(l1);
    If EdIzm=1 Then
     Begin
      If Not(System.Pos('?',ss)>0) And Not(System.Pos('-',ss)>0) Then
       Begin
        DelSpace(ss);
        MarketPack:=CalcPack(Art,ss);
        Delete(ws,1+CName+1+CArtikul+1+(CPAck+1)*i,CPAck);
        Insert(MarketPack,ws,1+CName+1+CArtikul+1+(CPAck+1)*i);
       End;
     End;
    ws[1+CName+1+CArtikul+1+(CPAck+1)*i-1]:='|';
    Str(StrToInt(SumKol)+StrToInt(ss):CPAck,SumKol);
   End;
  ws[1+CName+1+CArtikul+1+(CPAck+1)*Srok-1]:='|';

  If l1>0 Then Str(StrToInt(SumKol) div l1:CPAck,Reiting)
  Else Reiting:='    ?    ';

  If EdIzm=1 Then
   Begin
    DelSpace(SumKol);
    SumKol:=CalcPack(Art,SumKol);
   End;

  If EdIzm=1 Then
   Begin
    DelSpace(Reiting);
    Reiting:=CalcPack(Art,Reiting);
   End;

  If Dopoln=1 Then
   Begin
    Reiting:=BakGetField(FZakupka,Art,0);
    Str(StrToReal(Reiting):CZena:CMantissa,Reiting);
   End;



  ws:=ws+'|'+SumKol+'|'+Reiting;

  SumKol:=GetIdField(FInPack,Art);
  DelSpace(SumKol);
  RFormat(SumKol,CInPAck);

  Insert(SumKol+'|',ws,1+CArtikul+1+CName+1);

   While System.Pos('│',ws)>0 Do
    Begin
     i:=System.Pos('│',ws);
     ws[i]:='|';
    End;

  Writeln(txt,Space+ws);
End;
  End;
   End{Sort<>2}
Else
 Begin {Sort=2}
  For j:=0 To WspomList2^.List^.Count-1 Do
   Begin
    ws:=WspomList2^.GetText(j,WspomList2^.List^.Count);
    ss:=Copy(ws,1+CPack+1+1,CArtikul);
    Art:=ss;
  If StrToInt(Copy(ss,1,CRAzdelKod))=StrToInt(s) Then
  Begin
    Position:=Location(WspomList,ss,(Sort=0));
    ws:=WspomList^.GetText(Position,WspomList^.List^.Count);

    If Sort=0 Then Delete(ws,1,CArtikul+1);

    Delete(ws,1+CNAme+1,CArtikul+1);
    ws:=ss+' '+ws;

  SumKol[0]:=#0;
  Reiting[0]:=#0;
  l1:=0;
  For i:=0 To Srok-1 Do
   Begin
    ss:=Copy(ws,1+CName+1+CArtikul+1+(CPAck+1)*i,CPAck);
    If Not(System.Pos('?',ss)>0) And Not(System.Pos('-',ss)>0) Then inc(l1);
    If EdIzm=1 Then
     Begin
      If Not(System.Pos('?',ss)>0) And Not(System.Pos('-',ss)>0) Then
       Begin
        DelSpace(ss);
        MarketPack:=CalcPack(Art,ss);
        Delete(ws,1+CName+1+CArtikul+1+(CPAck+1)*i,CPAck);
        Insert(MarketPack,ws,1+CName+1+CArtikul+1+(CPAck+1)*i);
       End;
     End;
    ws[1+CName+1+CArtikul+1+(CPAck+1)*i-1]:='|';
    Str(StrToInt(SumKol)+StrToInt(ss):CPAck,SumKol);
   End;
  ws[1+CName+1+CArtikul+1+(CPAck+1)*Srok-1]:='|';

  If l1>0 Then Str(StrToInt(SumKol) div l1:CPAck,Reiting)
  Else Reiting:='    ?    ';

  If EdIzm=1 Then
   Begin
    DelSpace(SumKol);
    SumKol:=CalcPack(Art,SumKol);
   End;

  If EdIzm=1 Then
   Begin
    DelSpace(Reiting);
    Reiting:=CalcPack(Art,Reiting);
   End;


  If Dopoln=1 Then
   Begin
    Reiting:=BakGetField(FZakupka,Art,0);
    Str(StrToReal(Reiting):CZena:CMantissa,Reiting);
   End;


  ws:=ws+'|'+SumKol+'|'+Reiting;

  SumKol:=GetIdField(FInPack,Art);
  DelSpace(SumKol);
  RFormat(SumKol,CInPAck);

  Insert(SumKol+'|',ws,1+CArtikul+1+CName+1);

   While System.Pos('│',ws)>0 Do
    Begin
     i:=System.Pos('│',ws);
     ws[i]:='|';
    End;
  Writeln(txt,Space+ws);

          ws1:=Copy(ws,1,CArtikul);
          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
          Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt,Space+'      '+ws2+'|');
           {Format(ws2,CName);}
          End;


End;
  End;

 End;{Else т.е. режим сортировки по продажам}
   End;

 End;{for по разделам}
 End;

ws[0]:=#0;
For l:=1 To Ord(rs[0]) Do
Begin
ws[l]:='=';
ws[0]:=Chr(l);
End;

Writeln(Txt);
Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(Txt,Space+ws+NoCondensed[NPrint.Printer]);
Close(txt);


 Dispose(WspomList,Done);
 Dispose(WspomList2,Done);

 Dispose(TempList,Done);
 NoInfo;
 ViewAsText(Path.ToTemp+'mrk_ost.txt',True);
 Report(Path.ToTemp+'mrk_ost.txt','',1,False,False);
End;
*)

Procedure SpecialRashetProdag(Const Spis:PBox;Assort,Sort:Word);
              {123456123456123456123456123456123456123456123456123456}
label m1;
Var R,R1 : TRect;
    Txt : Text;
    rs,Shablon,s1,RazdelName,Fas,TempArtikul,s,sss,ss : TMyString;
    ws1,ws : String;
    SumPrh,SumKol,Ext,Space : TEnJoyStr;
    TempList : PBox;
    WspomList1,WspomList2,WspomList: PBox;
    Regim : Word;
    Separator : ArtikulStr;
    SInPack,MarketKol,MarketPack:string[CPack];
    Art,PositionZena,Date : TDateString;
    l,EE,EE1,l2 : LongInt;
    Pos,j,i,Srok,Day: Word;
    Start : TDAteString;
    Itg : PNewItogType;
    ItogFile  : File Of NewItogType;
    Position,Cl,ClP : Word;
    ssort:Byte;
    Shapka : Array[1..5] Of TMyString;

Begin
 Separator:=' ';
 Assign(Txt,Path.ToTemp+'mrk_ost1.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'mrk_ost1.txt',Nil,mfError+mfCancelButton);
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

Day:=0;
Srok:=8;
If Not SelectVidOstatkiMarket(Day,Srok,Start) Then
 Begin
      Dispose(TempList,Done);
      Exit;
 End;


 SSort:=SelectSpecify(False,5);
      If SSort=3 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;
 Sort:=SSort;

 Cl:=SelectSpecify(FAlse,8);
      If Cl=4 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;

ClP:=SelectSpecify(FAlse,10);
      If Clp=4 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;


  DInfo('Анализирую остатки, продажи и приходы...');
  Append(txt);
  Space:='   ';
  Writeln(Txt,Space+'Склад:'+FormKod(Rek.Kod)+' Оператор: '+CurrentPassword);
  Writeln(Txt,Space+'Дата и время расчета: '+FDate+'  ('+Times+')');
  Write(Txt,Space+'Вид отбора отгрузки: ');
  Case Cl Of
  3:Writeln(txt,'{Все}');
  0:Writeln(txt,'{Клиент}');
  1:Writeln(txt,'{Склад}');
  2:Writeln(txt,'{Взаимозачет}');
  Else Writeln(txt);
  End;
  Write(Txt,Space+'Вид отбора прихода: ');
  Case Clp Of
  3:Writeln(txt,'{Все}');
  0:Writeln(txt,'{Клиент}');
  1:Writeln(txt,'{Склад}');
  2:Writeln(txt,'{Взаимозачет}');
  Else Writeln(txt);
  End;
  Write(Txt,Space+'Вид сортировки товара: ');
  Case Sort Of
  2:Writeln(txt,'{По штучным продажам (по убыванию)}');
  1:Writeln(txt,'{По наименованию}');
  0:Writeln(txt,'{По кодам}');
  Else Writeln(txt);
  End;

  Write(Txt,Space+'Вид сортировки разделов: ');
  Case Regim Of
  1:Writeln(txt,'{По наименованиям разделов}');
  0:Writeln(txt,'{По кодам разделов}');
  Else Writeln(txt);
  End;
  Writeln(txt);

 s:=' Код |Наименование товара       |Фас';
    {12345 12345678901234567890123456 123}
s1:='     |                          |   ';
ws1:=s1;
EE:=DateStringToDate(DateMask,Start);
if day=0 then
EE1:=EE-Srok+1{чтобы учесть текущий день}
else
EE1:=EE-Srok*7+1;

Space:='    ';
Shablon[0]:=#0;
Writeln(Txt,Space+' ВЕДОМОСТЬ ОСТАТКОВ,ОТГРУЗКИ И ПРИХОДА ТОВАРА за период с '+DAteToDateString(DAteMask,EE1)+' по '+Start);
If Day=0 Then
Writeln(Txt,Space+' Количество дней в расчете: ',Srok:1)
Else
Writeln(Txt,Space+' Количество недель в расчете: ',Srok:1);

Writeln(Txt,Space+'{Обозначения: "-" нет остатков  "?" нет данных}');

Writeln(Txt,Space+Condensed[NPrint.Printer]);


    Str(StrToInt(Rek.Kod):2,Ext);
    RFormatZerro(Ext,2);

if day=1 then SpecialCompressReport(EE1,EE,Cl,Clp,TempList,Regim);

Space:='';
j:=1;
For l:=EE1 To EE Do
Begin
ws:=DAteToDAteString('   dd.mm   ',l);
                     {12345678901}
If Day=1 Then ws[1]:='с';
s:=s+'|'+ws;
if day=1 then
  Begin
   ss:=inttostr(j,COne);
   Format(ss,CMantissa);
  End
else
  ss:=DayString[DayOfWeek(l)];
ss:='     '+ss+'    ';
s1:=s1+'|'+ss;
ws1:=ws1+'|'+' Прод  Прих';
If Day=0 Then
Begin
If Not(FExists(Path.ToArchiv+DAteToDAteString(DateMask,l)+'.p'+Ext)) Then
Shablon:=Shablon+'   ?     ? '+'|'
Else             {12345678901}
Shablon:=Shablon+'   -     - '+'|';
End              {12345 12345}
 Else
  Begin
If Not(FExists(Path.ToTemp+IntToStr(j,COne)+'.w'+IntToStr(j,COne))) Then
Shablon:=Shablon+'   ?     ? '+'|'
Else
Shablon:=Shablon+'   -     - '+'|';
inc(l,6);        {12345 12345}
if l>ee then break;
  End;
inc(j);
End;
ws1:=ws1+'|     |      |';

if day=0 then
begin
If Not(FExists(Path.ToArchiv+DAteToDAteString(DateMask,EE)+'.p'+Ext)) Then
Shablon:=Shablon+'   ? ' Else Shablon:=Shablon+'   - ';
end              {12345}                       {12345}
else
 begin
If Not(FExists(Path.ToTemp+IntToStr(Srok,COne)+'.w'+IntToStr(Srok,COne))) Then
Shablon:=Shablon+'   ? ' Else Shablon:=Shablon+'   - ';
 end;            {12345}                       {12345}

If Day=1 Then
Begin
ws:=DAteToDAteString('dd.mm',EE);
{ws[1]:='Н';ws[2]:='а';}
End
Else DelSpace(ws);

s:=s+'|остат| прод.| прих.';
     {12345 123456 123456}
s1:=s1+'|'+ws+'|'+'   E  |  E';

ws[0]:=#0;
For l:=1 To Ord(s[0]) Do
Begin
ws[l]:='_';
ws[0]:=Chr(l);
End;

rs:=ws;

{
Writeln(Txt,Space+ws);
Writeln(Txt,Space+s1);
Writeln(Txt,Space+s);
Writeln(Txt,Space+ws);
}
Shapka[1]:=ws;
Shapka[2]:=s1;
Shapka[3]:=s;
Shapka[4]:=ws1;
Shapka[5]:=ws;



  R1.Assign(0,0,0,0);
  WspomlIST := New(PBox, Init(R1, 1, Nil));
  WspomList^.NewList(New(PTextCollection, Init(0,1)));
  j:=0;
  New(Itg,Init);
  For L:=EE1 To EE Do
   Begin
    Str(StrToInt(Rek.Kod):2,Ext);
    RFormatZerro(Ext,2);

    l2:=l;

m1:    s:=DAteToDAteString(DateMask,l2);
    If Day=0 Then
    Assign(ItogFile,Path.ToArchiv+s+'.p'+Ext)
    Else
    Assign(ItogFile,Path.ToTemp+IntToStr(j+1,COne)+'.w'+IntToStr(j+1,COne));

    i:=IOResult;
    Reset(ItogFile);
    i:=IOResult;

    if i<>0 then
    begin
     dec(l2);
     if l-l2<6 then goto m1;
    end;

    If i=0 Then
     Begin
      While Not(Eof(ItogFile)) Do
       Begin
        Read(ItogFile,Itg^.Dat);
{       If Not TestElement(Copy(Itg^.Dat.BAzKod,1,CRAzdelKod),TempList) Then}
If TestElementSpis_New (Copy(Itg^.Dat.BAzKod,1,CRAzdelKod),TempList,regim) Then
   Begin
        If Not(TestElement(Itg^.Dat.BAzKod,WspomList)) Then
         Begin
          Pos:= Location(WspomList,Itg^.Dat.BAzKod,False);
          ws := WspomList^.GetText(pos,WspomList^.List^.Count);
          s:=Copy(ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*j,CKol);
          sss:=Copy(ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*j+CKol+1,CKol);
          Delete(ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*j,CKol);
          Delete(ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*j,CKol+1);

          if day=0 then{для случая расчета по дням}
          begin
          Case Cl Of
          0:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC):CKol,s);{клиент}
          1:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkS):CKol,s);{склад}
          2:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkB):CKol,s);
          3:Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC)+StrToInt(Itg^.Dat.MrkS)
		     +StrToInt(Itg^.Dat.MrkB):CKol,s);
          Else;
          End;
          Case Clp Of
          0:Str(StrToInt(sss)+StrToInt(Itg^.Dat.PrhC):CKol,sss);{клиент}
          1:Str(StrToInt(sss)+StrToInt(Itg^.Dat.PrhS):CKol,sss);{склад}
          2:Str(StrToInt(sss)+StrToInt(Itg^.Dat.PrhB):CKol,sss);
          3:Str(StrToInt(sss)+StrToInt(Itg^.Dat.PrhC)+StrToInt(Itg^.Dat.PrhS)
		     +StrToInt(Itg^.Dat.PrhB):CKol,sss);
          Else;
          End;
          end
           else
		  Begin
		   Str(StrToInt(s)+StrToInt(Itg^.Dat.MrkC):CKol,s);{для случая недель}
		   Str(StrToInt(sss)+StrToInt(Itg^.Dat.PrhC):CKol,sss);{для случая недель}
            End;


          Insert(' '+sss,ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*j);
          Insert(s,ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*j);

          If Day=0 Then
          Begin
          If l=EE Then
           Begin
            Delete(ws,Ord(ws[0])-CKol+1,CKol);
            Str(StrToInt(Itg^.Dat.Ost):CKol,s);
            ws:=ws+s;
           End;
          End
          Else
           Begin
          If (j+1)=Srok Then
           Begin
            Delete(ws,Ord(ws[0])-CKol+1,CKol);
            Str(StrToInt(Itg^.Dat.Ost):CKol,s);
            ws:=ws+s;
           End;

           End;

          WspomList^.List^.AtFree(Pos);
          WspomList^.SetRange(WspomList^.List^.Count);

          WspomList^.List^.Insert(NewStr(ws));
          WspomList^.SetRange(WspomList^.List^.Count);
         End
         Else
          Begin
            ws:=GetIdField(FNAme,Itg^.Dat.BAzKod);
            Format(ws,CNAme);

            ws:=ws+'│'+Itg^.Dat.BAzKod+'│'+Shablon;


            Delete(ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*j,CKol);{удаляем проданное колич}
            Delete(ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*j,CKol+1);{удаляем оприходов колич}

          if day=0 Then{для случая расчета по дням}
          Begin
          Case Cl Of
          0:Str(StrToInt(Itg^.Dat.MrkC):CKol,s);{клиент}
          1:Str(StrToInt(Itg^.Dat.MrkS):CKol,s);{склад}
          2:Str(StrToInt(Itg^.Dat.MrkB):CKol,s);
          3:Str(StrToInt(Itg^.Dat.MrkC)+StrToInt(Itg^.Dat.MrkS)+StrToInt(Itg^.Dat.MrkB):CKol,s);
          Else;
          End;
          Case Clp Of
          0:Str(StrToInt(Itg^.Dat.PrhC):CKol,sss);{клиент}
          1:Str(StrToInt(Itg^.Dat.PrhS):CKol,sss);{склад}
          2:Str(StrToInt(Itg^.Dat.PrhB):CKol,sss);{склад}
          3:Str(StrToInt(Itg^.Dat.PrhC)+StrToInt(Itg^.Dat.PrhS)+StrToInt(Itg^.Dat.PrhB):CKol,sss);
          Else;
          End;
          End
          Else
		 Begin
		  Str(StrToInt(Itg^.Dat.MrkC):CKol,s);{для случая недель}
		  Str(StrToInt(Itg^.Dat.PrhC):CKol,sss);{для случая недель}
           End;

            {Str(StrToInt(Itg^.Dat.MrkC):CKol,s);}

            Insert(' '+sss,ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*j);{вставляем приходы}
            Insert(s,ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*j);{вставляем продажи}
          If Day=0 Then
          Begin
          If l=EE Then
           Begin
            Delete(ws,Ord(ws[0])-CKol+1,CKol);
            Str(StrToInt(Itg^.Dat.Ost):CKol,s);
            ws:=ws+s;
           End;
          End
           Else
            Begin
          If (j+1)=Srok Then
           Begin
            Delete(ws,Ord(ws[0])-CKol+1,CKol);
            Str(StrToInt(Itg^.Dat.Ost):CKol,s);
            ws:=ws+s;
           End;

            End;


            WspomList^.List^.Insert(NewStr(ws));
            WspomList^.SetRange(WspomList^.List^.Count);
          End;
  End;

       End;{While Not(Eof)}
      Close(ItogFile);{IOResult=0}
     End
      Else
       Begin
       End;
     Inc(j);{счетчик дней}
   End;{for по датам}
   Dispose(Itg,Done);

{вставить код расчета сводных продаж}
  R.Assign(0,0,0,0);
  WspomlIST2 := New(PBox, Init(R1, 1, Nil));
  WspomList2^.NewList(New(PTextCollection, Init(0,1)));
DistanationSorting:=False;
If WspomList^.List^.Count>=1 Then
Begin
  For j:=0 To WspomList^.List^.Count-1 Do
   Begin
    ws:=WspomList^.GetText(j,WspomList^.List^.Count);
    Art:=Copy(ws,1+CName+1,CArtikul);

    SumKol[0]:=#0;
    For i:=0 To Srok-1 Do
     Begin
      ss:=Copy(ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*i,CKol);
      Str(StrToInt(SumKol)+StrToInt(ss):CKol+1,SumKol);
     End;
     ws:=SumKol+'│'+Art;
     WspomList2^.List^.Insert(NewStr(ws));
     WspomList2^.SetRange(WspomList2^.List^.Count);
   End;{For}
End;{If WspomList^.List^.Count>=1 Then}
{конец расчета сводных продаж}
DistanationSorting:=True;


{вставить сортировку наименований внутри раздела}
  R.Assign(0,0,0,0);
  WspomlIST1 := New(PBox, Init(R1, 1, Nil));
  WspomList1^.NewList(New(PTextCollection, Init(0,1)));

If WspomList^.List^.Count>=1 Then
Begin
  For j:=0 To WspomList^.List^.Count-1 Do
   Begin
    ws:=WspomList^.GetText(j,WspomList^.List^.Count);
   If Sort=0 Then{по коду}
    Begin
     ss:=Copy(ws,1+CName+1,CArtikul);
     ws:=ss+'│'+ws;
     Art:=ss;
    End
    Else Art:=Copy(ws,1+CName+1,CArtikul);



    s:=Copy(ws,Ord(ws[0])-CKol+1,CKol);
     Delete(ws,Ord(ws[0])-CKol+1,CKol);
    If Not(System.Pos('?',s)>0) Then
     Begin
	 Str(StrToInt(s):CKol,s);
     End;
     ws:=ws+s;


    WspomList1^.List^.Insert(NewStr(ws));
    WspomList1^.SetRange(WspomList1^.List^.Count);
   End;{For}
  WspomList^.NewList(Nil);
  WspomList^.NewList(New(PTextCollection, Init(0,1)));
  For j:=0 To WspomList1^.List^.Count-1 Do
   Begin
    ws:=WspomList1^.GetText(j,WspomList1^.List^.Count);
    WspomList^.List^.Insert(NewStr(ws));
    WspomList^.SetRange(WspomList^.List^.Count);
   End;{For}
End;
Dispose(WspomList1,Done);


If WspomList^.List^.Count>=1 Then
 Begin
 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else
  s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);

If TestElementSpis_New (S,WspomList,Sort) Then
Begin

  Writeln(Txt);
  Writeln(Txt,Space+'                    Раздел: '+GetRazdel(s));

Writeln(Txt,Space+Shapka[1]);
Writeln(Txt,Space+Shapka[2]);
Writeln(Txt,Space+Shapka[3]);
Writeln(Txt,Space+Shapka[4]);
Writeln(Txt,Space+Shapka[5]);

If Sort<>2 Then
Begin
  For j:=0 To WspomList^.List^.Count-1 Do
   Begin
    ws:=WspomList^.GetText(j,WspomList^.List^.Count);
    If Sort=0 Then Delete(ws,1,CArtikul+1);
    ss:=Copy(ws,1+CName+1,CArtikul);
    Art:=ss;
  If StrToInt(Copy(ss,1,CRAzdelKod))=StrToInt(s) Then
  Begin
    Delete(ws,1+CNAme+1,CArtikul+1);
    ws:=ss+'|'+ws;

  SumKol[0]:=#0;
  SumPrh[0]:=#0;
  For i:=0 To Srok-1 Do
   Begin
    ss:=Copy(ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*i,CKol);
    sss:=Copy(ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*i+CKol+1,CKol);
    ws[1+CName+1+CArtikul+1+(CKol+1+CKol+1)*i-1]:='|';
    Str(StrToInt(SumKol)+StrToInt(ss):CKol+1,SumKol);
    Str(StrToInt(SumPrh)+StrToInt(sss):CKol+1,SumPrh);
   End;

  For i:=1 To Srok Do
   Begin
    ws[1+CName+1+CArtikul+1+(CKol+1)*i]:='/';
   End;

  ws[1+CName+1+CArtikul+1+(CKol+1+CKol+1)*Srok-1]:='|';




  ws:=ws+'|'+SumKol+'|'+SumPrh;

  SumKol:=GetIdField(FInPack,Art);
  DelSpace(SumKol);
  RFormat(SumKol,CInPAck);

  Insert(SumKol+'|',ws,1+CArtikul+1+CName+1);

   While System.Pos('│',ws)>0 Do
    Begin
     i:=System.Pos('│',ws);
     ws[i]:='|';
    End;

  Writeln(txt,Space+ws);
End;
  End;
   End{Sort<>2}
Else
 Begin {Sort=2}
  For j:=0 To WspomList2^.List^.Count-1 Do
   Begin
    ws:=WspomList2^.GetText(j,WspomList2^.List^.Count);
    ss:=Copy(ws,1+CKol+1+1,CArtikul);
    Art:=ss;
  If StrToInt(Copy(ss,1,CRAzdelKod))=StrToInt(s) Then
  Begin
    Position:=Location(WspomList,ss,(Sort=0));
    ws:=WspomList^.GetText(Position,WspomList^.List^.Count);

    If Sort=0 Then Delete(ws,1,CArtikul+1);

    Delete(ws,1+CNAme+1,CArtikul+1);
    ws:=ss+'|'+ws;

  SumKol[0]:=#0;
  SumPrh[0]:=#0;
  For i:=0 To Srok-1 Do
   Begin
    ss:=Copy(ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*i,CKol);
    sss:=Copy(ws,1+CName+1+CArtikul+1+(CKol+1+CKol+1)*i+CKol+1,CKol);

    ws[1+CName+1+CArtikul+1+(CKol+1+CKol+1)*i-1]:='|';
    Str(StrToInt(SumKol)+StrToInt(ss):CKol+1,SumKol);
    Str(StrToInt(SumPrh)+StrToInt(sss):CKol+1,SumPrh);
   End;
  ws[1+CName+1+CArtikul+1+(CKol+1+CKol+1)*Srok-1]:='|';




  ws:=ws+'|'+SumKol+'|'+SumPrh;

  SumKol:=GetIdField(FInPack,Art);
  DelSpace(SumKol);
  RFormat(SumKol,CInPAck);

  Insert(SumKol+'|',ws,1+CArtikul+1+CName+1);

   While System.Pos('│',ws)>0 Do
    Begin
     i:=System.Pos('│',ws);
     ws[i]:='|';
    End;

  Writeln(txt,Space+ws);
End;
  End;

 End;{Else т.е. режим сортировки по продажам}
   End;

 End;{for по разделам}
 End;

ws[0]:=#0;
For l:=1 To Ord(rs[0]) Do
Begin
ws[l]:='=';
ws[0]:=Chr(l);
End;
{
Writeln(Txt,Space+Shapka[1]);
Writeln(Txt,Space+Shapka[2]);
Writeln(Txt,Space+Shapka[3]);
Writeln(Txt,Space+Shapka[4]);
}
Writeln(Txt);
Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(Txt,Space+ws+NoCondensed[NPrint.Printer]);
Close(txt);


 Dispose(WspomList,Done);
 Dispose(WspomList2,Done);

 Dispose(TempList,Done);
 NoInfo;
 ViewAsText(Path.ToTemp+'mrk_ost1.txt',True);
 Report(Path.ToTemp+'mrk_ost1.txt','',1,False,False,false);
End;





Procedure CalcMenedger2(Const Client,Agent:PBox; Filtr,Oplata:Word;StartD,StopD:TDateString);
Const
      Arhipov=0; Ilishev=1;

Var f : File Of StatClientType;
    R : TRect;
    E : PStatClientType;
    s : String;
    l : Word;
    Razdel1 :PBox;

    Delta,DateOpl,Date : TDAteString;
    NDS,z,AllSkidka,AllItogo,ItogoSkidka,Itogo : Real;
    AllZakupka,AllReturn,AllSkidkaReturn:Real;
    ws,ws2 : TMyString;
    txt1 : Text;
    Res,AllDoc : LongInt;
    DocS : Word;
    Slujba,Current,Cur,sh,VidSkidka,Vid : Word;

    ws1,Space : TMyString;
    AllReturnDoc,RAbday,Den,Start,Stop : LongInt;
    NoScreen : PBox;
    Key,Distant : Word;
    NameDoc,Names,Otgruz : AllStr;
    DateOtgr,DateOplata: TDateString;
    StartDate,StopDate : TDateString;
    Index :Word;
    FFF : Boolean;
    AgName,ClShk,Dohod,CurClientKod,tr,Doc,Cod,Ag:AllStr;
    Dolg : Real;
    EStraf,Straf: Real;
    mm : Maska9;
    ss : Maska2;
    Find,Add : Boolean;
    Er : PRealizasiaType;
    fr: File of RealizasiaType;


Function TestAgent(Cod:ArtikulStr):Boolean;
Var L : Boolean;
    i : word;
    st : String;
Begin
TestAgent:=False;
If (Agent^.List^.Count-1)>=0 Then
Begin
For i:=0 To Agent^.List^.Count-1 Do
 Begin
  st:=Agent^.GetText(i,Agent^.List^.Count);
  st:=Copy(st,1+CClient+1,CClientKod);
  If (St=Cod) Then
   Begin
    TestAgent:=True;
    Break;
   End;{St=Cod}
 End;
End;
End;



Begin
  if not (User[78] or
               (StrToInt(CurrentPassword)=0)) then exit;


 WordTobit9(Filtr,mm);
 Convert9(mm);

 WordToBit2(Oplata,ss);
 Convert2(ss);


 Start:=DateStringToDate(DateMask,StartD);
 Stop:=DateStringToDate(DateMask,StopD);


 Key:=0;
 Distant:=0;
 If Not(KeySorting(Key,Distant)) Then
   Begin
    Exit;
   End;


If Distant=0 Then DistanationSorting:=True
Else DistanationSorting:=False;


 Space[0]:=#0;
 Assign(Txt1,Path.ToTemp+'cmengob.txt');
 l:=IOResult;
 Rewrite(Txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path.ToTemp+'cmengob.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

If Distant=0 Then DistanationSorting:=True
Else DistanationSorting:=False;


 Assign(RazdelFile,Path.ToRAzdel+'Razdel.db');
 Reset(RazdelFile);
 i:=IOResult;
 If i<>0 Then
  Begin
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
    Begin
     Razdel1^.List^.Insert(NewStr('│'+RazdelElement.Kod+'000'+'│           0.00│           0.00'));
     Razdel1^.SetRange(Razdel1^.List^.Count);
    End;
  End;
Close(RazdelFile);

R.Assign(0,0,0,0);
NoScreen:= New(PBox, Init(R, 1, Nil));
NoScreen^.NewList(New(PTextCollection, Init(0,1)));


Writeln(txt1,Space+'Склад: '+FormKod(Rek.Kod)++'  Оператор: '+CurrentPassword);

Write(txt1,Space+'Включены документы отгрузки:');
For sh:=1 To Max9 Do
Case (Sh-1) Of
0:If mm[sh]=1 Then Write(txt1,' Список');
1:If mm[sh]=1 Then Write(txt1,' Тов.Ч*');
2:If mm[sh]=1 Then Write(txt1,' Физ.Л*');
3:If mm[sh]=1 Then Write(txt1,' СФ*');
4:If mm[sh]=1 Then Write(txt1,' СФБ');
5:If mm[sh]=1 Then Write(txt1,' Д*');
6:If mm[sh]=1 Then Write(txt1,' ДСФ*');
7:If mm[sh]=1 Then Write(txt1,' Д');
8:If mm[sh]=1 Then Write(txt1,' ДСФБ');
Else;
End;
Writeln(txt1);

Write(txt1,Space+'Включены документы со статусом:');
For sh:=1 To CMantissa Do
Case (Sh-1) Of
0:If ss[sh]=1 Then Write(txt1,' Оплаченные');
1:If ss[sh]=1 Then Write(txt1,' Не оплаченные');
Else;
End;
Writeln(txt1);

Write(txt1,Space+'Сортировка по:');
 Case Key Of
0{клиент}   :Write(txt1,'Клиенту');
1{дата отгр}:Write(txt1,'Дата отгрузки');
2{дата опл} :Write(txt1,'Сумма оплаты');
3{скидка}   :Write(txt1,'Сумма закупки');
4{оплата}   :Write(txt1,'Доход');
5{вид док}  :Write(txt1,'Шкала клиента');
6{Delta}    :Write(txt1,'Агент');
Else;
End;

Case Distant Of
0{клиент}   :WriteLn(txt1,' По возрастанию');
1{дата отгр}:WriteLn(txt1,' По убыванию');
Else WriteLn(txt1);
End;

{
If (Client^.List^.Count)>=1 Then
Begin
 Writeln(txt1,'Выбранные клиенты:');
For Index:=0 To Client^.List^.Count-1 Do
Begin
s:=Client^.GetText(Index,Client^.List^.Count);
While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';
Writeln(txt1,s);
End;
End;
}
If (Agent^.List^.Count)>=1 Then
Begin
 Writeln(txt1);
 Writeln(txt1,'Выбранные агенты:');
For Index:=0 To Agent^.List^.Count-1 Do
Begin
s:=Agent^.GetText(Index,Agent^.List^.Count);
While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';
Writeln(txt1,s);
End;
End;


Writeln(txt1);
Writeln(txt1,Space,' СПРАВКА ПО ОТГРУЗКАМ ЗА ПЕРИОД с '+Startd+' по '+Stopd+' (по выбранным клиентам)');
Writeln(txt1,Space+'-------------------------------------------------------------------------------------------');
Writeln(txt1,Space+' N  Клиент               Код  Агент          Док. Дата док Сумма к опл Сумма по ЗЦ   %   Шк');
Writeln(txt1,Space+'-------------------------------------------------------------------------------------------');
                   {123 12345678901234567890 1234 12345678901234 1234 12345678 12345678901 12345678901 12345 12}
AllItogo:=0;
AllZakupka:=0;
AllSkidka:=0;
AllDoc:=0;
DInfoMsg('Обрабатываю запрос...');



New(E,Init);

If Client^.List^.Count>=1 Then
Begin
For Index:=0 To Client^.List^.Count-1 Do
Begin
CurClientKod:=Copy(Client^.GetText(Index,Client^.List^.Count),1+CCLient+1,CClientKod);

 Assign(F,Path.ToClient+CurClientKod+'.his');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
If l=0 Then
 Begin
  While Not (Eof(f)) Do
   Begin
      Read(f,E^.Dat);

If E^.Dat.Active Then

    If TestAgent(E^.Dat.AgentKod)
       And (mm[E^.Dat.DocSelector+1]=1) Then


   If (DateStringToDate(DateMask,E^.Dat.DateC)<=Stop) And
      (DateStringToDate(DateMask,E^.Dat.DateC)>=Start) Then

       Begin

     Add:=False;

    If (E^.Dat.DocSelector in [0,1,2,3,4]) Then
     Begin
      If ss[1]=1 Then Add:=True;
     End
     Else{для случая консигнации}
     Begin
          DelZerro(E^.Dat.Document);
          DelSpace(E^.Dat.Document);

          Assign(fr,Path.ToDolg+E^.Dat.ClientKod+'.dlg');
          Res:=IOResult;
          Reset(fr);
          Res:=IOResult;

          If Res<>0 Then
            MessageBox(^M+#3'Ошибка доступа к файлу долгов клиента '+E^.Dat.ClientKod+'!',Nil,mfError+mfCancelButton)
          Else
          Begin
          New(er,Init);
          Find:=False;
          While Not(Eof(fr)) And Not(Find) Do
           Begin
            Read(fr,er^.Dat);
            If (ClearChar(Er^.Dat.Market.Document)=E^.Dat.Document)
		  And(Er^.Dat.Market.DateC=E^.Dat.DateC)
            And(Er^.Dat.Market.Active) Then
                Begin
                 Find:=True;
                 If ((Er^.Dat.Full) and (ss[1]=1)) Or
                             (Not(Er^.Dat.Full) and (ss[2]=1)) Then Add:=True;
                End;
           End;
          Dispose(Er,Done);
          System.Close(fr);

          If Not(Find) Then  MessageBox(^M+#3'Документ не найден в долгах клиента '+E^.Dat.ClientKod+'!',
		Nil,mfError+mfCancelButton);
          End;{Res=0 файл успешно открыт}
     End;

    If Add Then
    Begin

        FFF:=ProdagaWindow;
        ProdagaWindow:=False;
        For Cur:=0 To MaxStatRazdel Do
         Begin
          tr:=IntToStr(Cur,CMantissa);
          RFormatZerro(tr,CMantissa);
          If Not(TestRazdelMemory(tr,Razdel1)) Then
           Begin
            s:=Razdel1^.GetText(
            LocationR(Razdel1,tr,ProdagaWindow),Razdel1^.List^.Count);
            ws1:=Copy(s,1+1+CArtikul+1,CIZena);

            Str(StrToReal(ws1)+
            E^.DAt.RazdelSum[Cur]:CIZena:CMantissa,ws1);
            Delete(s,1+1+CArtikul+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1);


            ws1:=Copy(s,1+1+CArtikul+1+CIZena+1,CIZena);
            Str(StrToReal(ws1)+
            E^.DAt.RazdelZak[Cur]:CIZena:CMantissa,ws1);
            Delete(s,1+1+CArtikul+1+CIZena+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1+CiZena+1);


            Razdel1^.List^.Atfree(LocationR(Razdel1,tr,ProdagaWindow));
            Razdel1^.SetRange(Razdel1^.List^.Count);
            Razdel1^.List^.Insert(NewStr(s));
            Razdel1^.SetRange(Razdel1^.List^.Count);
           End;
         End;



        ws:=GetClientField(FClient,E^.Dat.ClientKod,0);
        {Clshk:=GetClientField(FShkala,E^.Dat.ClientKod,0);}
        If E^.DAt.SkidkaSelector =2 Then
        Begin
        Clshk:=IntToStr(E^.DAt.ShkalaNumer,CMAntissa);
        RFormat(CLShk,CMAntissa);
        End
         Else
          Begin
           If E^.DAt.SkidkaSelector=0 Then Clshk:='Ав'
           Else Clshk:='Рч'
          End;
        Format(ws,CClient);

        DelSpace(E^.Dat.Document);
        RFormat(E^.Dat.Document,CDocNumer);
        DelSpace(E^.Dat.DateC);
        RFormat(E^.Dat.DateC,CDate);

        AgName:=GetAgentField(FAgent,E^.Dat.AgentKod);
        Format(AgName,CClient-6);

(************    ***************)
(*
          If StrToInt(E^.DAt.AgentKod)=17 Then
           Begin
     {13}   Str(StrToReal(E^.Dat.SummaZ)*0.98:CIZena:CMantissa,E^.Dat.SummaZ);
           End;
*)


        If (StrToReal(E^.Dat.SummaZakupka)>0.009) Then
         Begin
           Str(
          (StrToReal(E^.Dat.SummaZ)-StrToReal(E^.Dat.SummaZakupka))/
           StrToReal(E^.Dat.SummaZakupka)*100:CLitr+1:CMAntissa,Dohod);
         End
        Else
          Dohod:='  0.00';


        AllItogo:=AllItogo+StrToreal(E^.Dat.SummaZ);
        Allzakupka:=AllZakupka+StrToreal(E^.Dat.SummaZakupka);
        AllSkidka:=AllSkidka+StrToreal(E^.Dat.Skidka);
        AllDoc:=AllDoc+1;

        DelSpace(E^.Dat.SummaZ);


        RFormat(E^.Dat.SummaZ,CIZena-4);
        DelSpace(E^.Dat.SummaZakupka);
        RFormat(E^.Dat.SummaZakupka,CIZena-4);

        s[0]:=#0;
        s:=s+ws+' '+E^.Dat.ClientKod+' '+AgName+' '+
	   +E^.Dat.Document+' '+E^.Dat.DAteC+' '+E^.DAt.SummaZ+' '+E^.Dat.SummaZakupka+' '+
	   Dohod+' '+ClShk;


        Case Key Of
        1{дата отгр}:Begin
                       tr:=IntToStr(
                       DateStringToDate(DateMask,E^.Dat.DateC),CKol+1);
	                  s:=tr+' '+s;
                     End;
        2{Сумма опл}:s:=E^.Dat.SummaZ+' '+s;
        3{Сумма зак}:Begin
	                 s:=E^.Dat.SummaZakupka+' '+s;
                     End;
        4{доход}  :s:=Dohod+' '+s;
        5{шкала клиентов}:s:=ClShk+' '+s;
        6{агент}  : s:=AgName+' '+s;
        Else;
        End;


        NoScreen^.List^.Insert(NewStr(s));
        NoScreen^.SetRange(NoScreen^.List^.Count);
   End;{Add}
       End;{If}
   End;{While}
   Close(f);
 End;{If l=0}

 End;{For по клиентам}
End;{If SelectClient>0}


If NoScreen^.List^.Count>=1 Then
 Begin
  For Den:=0 To NoScreen^.List^.Count-1 Do
   Begin
     s:=NoScreen^.GetText(Den,NoScreen^.List^.Count);
        Case Key Of
        1{дата отгр}:Delete(s,1,CKol+1+1);
        2{сумма опл}:Delete(s,1,(CIZena-4)+1);
        3{сумма зак}:Delete(s,1,(CIZena-4)+1);
        4{доход}    :Delete(s,1,CLitr+1+1);
        5{шкала кли}:Delete(s,1,2+1);
        6{агент}    :Delete(s,1,(CClient-6)+1);
        Else;
        End;

        ws:=IntToStr(dEN+1,3);
        RFormat(ws,CLitrMantissa);


     Writeln(txt1,Space+WS+' '+s);
   End;
 End;


Writeln(txt1,Space+'-------------------------------------------------------------------------------------------');


Writeln(Txt1,Space+'                                                    Всего документов: ',
AllDoc:CIZena);
Writeln(Txt1,Space+
'                                                      Всего оплачено: ',RecognizReal(AllItogo,CIZena,CMantissa));
Writeln(Txt1,Space+
'                                                        Всего по З/Ц: ',RecognizReal(AllZakupka,CIZena,CMantissa));
If AllZakupka>0.009 Then
Begin
Writeln(Txt1,Space+
'                                                       Всего доход %: ',
RecognizReal((AllItogo-AllZakupka)/AllZakupka*100,CIZena,CMantissa));
End;

Writeln(Txt1,Space+
'                                                         Всего доход: ',RecognizReal(AllItogo-AllZakupka,CIZena,CMantissa));
Dispose(E,Done);
Dispose(NoScreen,Done);
DistanationSorting:=True;
Writeln(txt1);

If (Razdel1^.List^.Count-1)>=0 Then
Begin
Space:='        ';
Writeln(txt1);
Writeln(txt1,Space+'ИТОГОВАЯ СПРАВКА ПО ОТГРУЗКАМ ПО РАЗДЕЛАМ (для выбранных клиентов)');
Writeln(txt1,Space+'--------------------------------------------------------------');
Writeln(txt1,Space+'NN Раздел                  Сумма оплаты    Сумма по З/Ц    %');
Writeln(txt1,Space+'--------------------------------------------------------------');
                   {12 12345678901234567890 123456789012345 123456789012345 123456}

For Cur:=0 To Razdel1^.List^.Count-1 Do
 Begin
  s:=Razdel1^.GetText(Cur,Razdel1^.List^.Count);
  While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';
  Delete(s,1,1);
  ws1:=Copy(s,1,CRazdelKod);
  Delete(s,1+CRazdelKod,3);
  ws1:=GetRazdel(ws1);
  Format(ws1,CRazdel+1);
  Insert(ws1,s,1+CRazdelKod+1);

  ws1:=Copy(s,1+CRazdelKod+1+CRazdel+1,CIZena);
  ws:=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1,CIZena);

If (StrToReal(ws)>0.009) Then
Str((StrToReal(ws1)-StrToReal(ws))/StrToReal(ws)*100:CLitr+1:CMantissa,ws1)
Else
 If StrToReal(ws1)>0.009 Then
  ws1:='100.00'
 Else
  ws1:='  0.00';

  s:=s+' '+ws1;
  Writeln(txt1,Space+s);
 End;{}
End;


Space[0]:=#0;
Writeln(Txt1);
Writeln(Txt1,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt1,Space+'===========================================================');

Close(txt1);
Dispose(Razdel1,Done);
NoInfoMsg;
ViewAsText(Path.ToTemp+'cmengob.txt',True);
End;{CalcTch}







End.
