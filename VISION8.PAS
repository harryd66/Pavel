{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}


Unit Vision8;

Interface

Uses Glob,Dialogs,ServStr,Serv,Vision1,Utils;


Procedure PrintNaklRet (As: DocumentEditZ;CopyNkl : Byte);
Procedure PrintZakaz (As: DocumentEditZ;CopyNkl : Byte);
Procedure PrintPredZakaz (As: DocumentEditZ;CopyNkl : Byte);
Procedure CalcBuch;
Procedure CalcSpecialOthset(Const Spis:PBox;Const M:Maska8;Const Assort,Sort:Word);
Procedure Test_Sertif(Const Spis: PBox;Const M: Maska8;Const Assort,Sort:Word);
Function ViewAllNakl (Date: TDateString; Regim:Boolean;Debit:Boolean;Default:Byte):TMyString;
Function CalcDolgOtkat(Regim:Boolean):TMyString;
Function ViewOplOtkat(Dates:TDateString;Regim : Boolean;Var VidanoOtkatToDAy:AllStr):AllStr;
Function  ViewAllNAklSertif (Date: TDateString):TMyString;


Implementation


Uses DBEngine,MsgBox,Views,Propiss,TpDate,Access,Tools,Vision6,PrnVeks,Utils3,
     NetDBEng,Printers,Objects,Utils1,Prise,Utils5,Utils4,DbEngin2,
	DbEngin3,ServStr2,Form,
     Vision5,Vision7,Vision9,Vision4,Validate,App;


Var TempBox:PBox;
    StartDate,StopDate : TDAteString;
    LocalTempBox : PBox;
    OldFileMode : Word;

Procedure PrintShet (E:PZakazType;NPrintCC:PNewPrintCopy);
Var
    Copy,l : Word;
    NDS,z,ItogoSkidka,Itogo,
    NDS20,NDS18,NDS16,NDS10,NDS_ : Real;
    s,ws,ws1 : TMyString;
    Find : Boolean;
    Proz : String[CLitr];

    txt: Text;
    Logik : Boolean;
    RealZena,NPNalog,NormalZena,s3,s4,s2,s1,st,ItogNalog,Koefficient : AllStr;
    SDoc,SDate,Space : AllStr;
    Barter : String[CMantissa];
    Rek1 :Rekwiziti;
    Cl : PClientType;
    LG : PSuperMArketType;
    k,i,j : Byte;
NDSPos,ItogoPos,PromitogoPos:Real;
    BBB : PBazType;
    Test : LongInt;
    Art,Symbol : ArtikulStr;
    s5 : AllStr;

Begin
 Logik :=False;
 Assign(Txt,Path^.Dat.ToTemp+'zakaz.tmp');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'zakaz.tmp'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;


Space:='      ';

DINFOMsg('Формирую счет N '+E^.Dat.Document+'...',True);

Writeln(Txt,Space+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
Writeln(Txt);

If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt,Space{+'Последние изменения:'}+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');

ItogoSkidka:=0;   Itogo:=0; {NDS:=0;}

If E^.Dat.OperatorSelector<>2 Then Barter[0]:=#0
Else Barter:='-Б';


   If (E^.Dat.DocSelector in [3,4,6,8])  Then
   Rek1:=RekSF^.Dat
   Else
   Rek1:=Rek^.Dat;


   New(Cl,Init);
   Cl^.DAt.Kod:=E^.Dat.ClientKod;
   GetClient(Cl,E^.Dat.OperatorSelector);

   s:=Cl^.Dat.FullNAme;

   Writeln(Txt,Space+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Name+
   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
   Writeln(Txt,Space+'───────────────────────────────────────────────────────────────────────');

   Writeln(Txt,Space+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'Адрес:'+
   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Adress+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

   Writeln(Txt,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'Телефон:'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Telefon+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

   Writeln(Txt,Space+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'Город:'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Gde+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

   Writeln(Txt,Space+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'ИНН:'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.INN+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

   Writeln(Txt,Space+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'Расчетный счет:'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   Rek1.R_Sh+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

   Writeln(Txt,Space+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'Корр.счет:'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.K_Sh+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

   Writeln(Txt,Space+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'в:'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.Gde+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

   Writeln(Txt,Space+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'БИК:'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Rek1.BIK+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

   Writeln(Txt,Space+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'Грузоотправитель и его адрес:'+
   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   Rek1.AdressGruza+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
   Writeln(Txt,Space+'───────────────────────────────────────────────────────────────────────');


s:=DateToDateString(DateMask,
DateStringToDate(DateMAsk,E^.Dat.DateC)+E^.Dat.EndDate);
Writeln(Txt,Space+
GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'Срок доставки заказа до: '+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+s+
GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
{
Write(Txt,Space+  Bold[Nprint^.DAt.Printer]+'Вид расчета: '+NoBold[Nprint^.DAt.Printer]);

Case E^.DAt.Rashet Of
0:Writeln(txt,Italic[Nprint^.DAt.Printer]+'Наличный'+NoItalic[Nprint^.DAt.Printer]);
1:Writeln(txt,Italic[Nprint^.DAt.Printer]+'Безналичный'+NoItalic[Nprint^.DAt.Printer]);
2:Writeln(txt,Italic[Nprint^.DAt.Printer]+'Вексель'+NoItalic[Nprint^.DAt.Printer]);
Else Writeln(txt);
End;
}

s5:=E^.Dat.DAteC;
Insert('20',s5,7);

Writeln(Txt,Header+Space+
GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+'          С Ч Е Т  N '+'ЗЛ '+
E^.Dat.Document+BArter+
'/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+ ' от ',s5+' ('+ E^.Dat.TimeC+')'+
+
GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+HeaderStop);

Writeln(Txt);

   Writeln(Txt,Space+'───────────────────────────────────────────────────────────────────────');
   Writeln(Txt,Space+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'       Плательщик:'+
   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+Cl^.Dat.FullNAme+
   ' ('+Cl^.Dat.Kod+')'+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
   Writeln(Txt,Space+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'  ИНН плательщика:'+
   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   Cl^.Dat.INN+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
   Writeln(Txt,Space+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'Адрес плательщика:'+
   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   Cl^.Dat.Adress+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
   Writeln(Txt,Space+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'             Банк:'+
   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GetBankField(FBank,Cl^.Dat.BankKod)+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
   Writeln(Txt,Space+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'   Расчетный счет:'+
   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   Cl^.Dat.R_Sh+
   GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

   Writeln(Txt,Space+'───────────────────────────────────────────────────────────────────────');



Writeln(Txt,Header+
            Space+'┌─────────────────────────────────────────────────────────────────────┐');
Writeln(Txt,Space+'│N Наименование товара        Единица   Колич.    Цена Сумма к оплате │');
Writeln(Txt,Space+'│                             измерен.                                │');
Writeln(Txt,Space+'└─────────────────────────────────────────────────────────────────────┘'+HeaderStop);
                  {12 12345678901234567890123456 1234567890 12345 12345678 123456789012345}


   ItogoSkidka:=0;  Itogo:=0; NDS:=0; NDSPos:=0; ItogoPos:=0;PromitogoPos:=0;
   NDS20:=0; NDS10:=0; NDS_:=0;
   Koefficient[0]:=#0;

   For l:=1 To E^.Dat.Amount Do
   Itogo:=Itogo+StrToReal(E^.Dat.MarketElement[l].Input.Zena)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);

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
       Lg^.Dat.MarketElement[k].BazKod:=E^.Dat.MarketElement[l].BazKod;
       Lg^.Dat.MarketElement[k].Input.Kol:=E^.Dat.MarketElement[l].Input.Kol;

       Lg^.Dat.MarketElement[k].Input.Skidka  := E^.Dat.MarketElement[l].Input.Skidka;
       Lg^.Dat.MarketElement[k].Input.Zena    := E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[k].Input.R_Zena  := E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[k].Input.O_Zena  := E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[k].Input.Proz    := E^.Dat.MarketElement[l].Input.Proz;
       Lg^.Dat.MarketElement[k].Input.VidNDS  := StrToInt(GetIDField(FVidNDS,E^.Dat.MarketElement[l].BazKod));
       Lg^.Dat.MarketElement[k].Input.NDS     := BakGetField(FNDS,E^.Dat.MarketElement[l].BazKod,0);
       Lg^.Dat.MarketElement[k].Input.VidNalog   :=StrToInt(BakGetField(FVidNalog,E^.Dat.MarketElement[l].BazKod,0));
       Lg^.Dat.MarketElement[k].Input.SpecNalog  :=BakGetField(FNalog,E^.Dat.MarketElement[l].BazKod,0);
       Lg^.Dat.MarketElement[k].Input.DiviSionNumber:= E^.Dat.MarketElement[l].Input.InputDiviSion;
       Lg^.Dat.MarketElement[k].Input.Last     :=False;
       Lg^.Dat.MarketElement[k].Input.NSertif  :=E^.Dat.MarketElement[l].Input.NSertif;
       Lg^.Dat.MarketElement[k].Input.SertifKol:=E^.Dat.MarketElement[l].Input.SertifKol;

       Inc(k);
       Lg^.DAt.Amount:=k-1;
      End;
    End;
    Lg^.DAt.Amount:=k-1;

   New(BBB,Init);


   For l:=1 To Lg^.Dat.Amount Do
    Begin

   GetBazElement(Lg^.Dat.MarketElement[l].BazKod,BBB^.Dat);

     StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=Lg^.Dat.MarketElement[l].BazKod;

     If Nprint^.DAt.FullName=0 Then
     Begin
      ws:=BBB^.Dat.NAme;
      ws1:=BBB^.Dat.NAme2;
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
           Begin
            Writeln(txt,Space+'   '+ws);
            ws:=ws1;
           End;
     End
     Else
         Begin
          ws:=BBB^.Dat.NAme{GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod)};
          ws1:=BBB^.Dat.NAme2{GetIdField(FName2,Lg^.Dat.MarketElement[l].BazKod)};
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
     s:=s4+' '+s{+' '+s3+' '+s2};
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

     MySTr(StrToReal(ws)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol),
        CIZena,CMantissa,s3);
     {дописали цену и сумму}
     s:=s+' '+ws+' '+s3;

     If l=Lg^.Dat.Amount Then s:=OnlyLink+s;

     {записали сформированную строку в файл}
     Writeln(txt,Space+s);

     NormalZena:=ws;
     NPNalog[0]:=#0;

     {отключен расчет налога с продажи в товарном чеке}
       If E^.DAt.DocSelector in [{1,}2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(Lg^.dat.marketelement[l].Input.SpecNalog)
              /100)),CZenaZ,CMantissaZ,koefficient);
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

{Вычли скидку из цены}
{!!!!}
       ItogoPos:=StrToReal(RealZena{ws})*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
{Было        ItogoPos:=StrToReal(ws)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);}

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

       s:=s+' '+ws;

       PromitogoPos:=PromitogoPos+StrToReal(ws);

       ws:=Lg^.Dat.MarketElement[l].Input.NDS;

       MyStr(StrToReal(ws),CLitr-1,0{CMantissa-1},ws);

       s:=s+' '+Format(Ws,CLitr-1);

       MyStr(NDsPos,CInputIZena-1,CMantissa,ws);
{расчитали размер НДС в позиции}
       s:=s+' '+ws;

{расчитали ставку НП в позиции}
       If Not (E^.DAt.DocSelector in [1,2,3,5,6]) Then ws:='0.00'
       Else
       ws:=Lg^.Dat.MarketElement[l].Input.SpecNalog;
{!!!!}
       ItogoPos:=StrToReal(NormalZena)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
{Было  ItogoPos:=StrToReal(RealZena)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);}

       MyStr(ItogoPos,CInputIZena-2,CMantissa,ws);
       s:=s+'   '+ws;

       Nds:=Nds+NDSPos;

{разборка  НДС по классификации}
       Case Lg^.Dat.MarketElement[l].Input.VidNDs Of
       0:Nds20:=Nds20+NdsPos;
       1:Nds10:=Nds10+NdsPos;
       2:Nds_:=Nds_+NdsPos;
       3:Nds18:=Nds18+NdsPos;
       4:Nds16:=Nds16+NdsPos;
       Else;
       End;
    End;{конец печати самого счета}

Writeln(Txt,Space+'───────────────────────────────────────────────────────────────────────');
Writeln(Txt,Space+'                                       Всего к оплате: ',RecognizReal(StrToReal(E^.Dat.SummaZ),
CIZena,CMAntissa));

    If E^.Dat.DocSelector in [3,4,6,8] Then
    Begin
Writeln(Txt,Space+'───────────────────────────────────────────────────────────────────────');
    s:=E^.Dat.SummaZ;
    DelSpace(s);
    Propis(s,ws);
    ws[1]:=UpperCase(ws[1]);
    Writeln(txt,Space+
    GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+ws+
    GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
    If s[0]<>#0 Then
    Writeln(txt,Space+
    GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+s+
    GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
Writeln(Txt,Space+'───────────────────────────────────────────────────────────────────────');
    End;


    If E^.Dat.DocSelector<>0 Then
     Begin
       Writeln(txt,Space+'     В т.ч. НДС:',RecognizReal(Nds,CIZena,CMantissa));

       If NDS20>0.009 Then
       Writeln(txt,Space+
	  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+'         20%   :'+RecognizReal(NDS20,CIZena,CMantissa)+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

       If NDS18>0.009 Then
       Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+'         18%   :'+RecognizReal(NDS18,CIZena,CMantissa)+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

       If NDS16>0.009 Then
       Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+'         16%   :'+RecognizReal(NDS16,CIZena,CMantissa)+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

       If NDS10>0.009 Then
       Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+'         10%   :'+RecognizReal(NDS10,CIZena,CMantissa)+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

       If NDS_>0.009 Then
       Writeln(txt,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+'         прочие:'+RecognizReal(NDS_,CIZena,CMantissa)+
          GlobalPrn^.Dat.Noitalic[Nprint^.DAt.Printer]);

{
if ((Pharm=1)) Then
Begin
    Writeln(txt,Space+Italic[Nprint^.DAt.Printer]+Bold[Nprint^.DAt.Printer]+Double[Nprint^.DAt.Printer]+
    'НДС не облагается'+NoItalic[Nprint^.DAt.Printer]+
    NoBold[Nprint^.DAt.Printer]+NoDouble[Nprint^.DAt.Printer]);
End;
}
     End;


   Writeln(Txt);
   Writeln(Txt,Space+' Руководитель предприятия ________     Бухгалтер _______');
   Writeln(Txt);
   Writeln(Txt,Space+'         М.П.');


   If E^.Dat.Rashet=2 Then Symbol:='-В'
   Else Symbol:='';

   Writeln(txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+
   ')'+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+'                            Тип документа: (',
                     LeadingZero(E^.Dat.DocSelector),+Symbol+')'+
				 GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
				 GlobalPrn^.Dat.NOBold[Nprint^.DAt.Printer]+
                                 GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
Writeln(txt,Space+'=======================================================================');



   Dispose(Lg,Done);
   Dispose(Cl,Done);
   Dispose(BBB,Done);
   Close(txt);
 l:=IOResult;
NoInfoMsg;

  If AutoAnswer(#3^M+#3'Печатать счет N '+E^.Dat.Document+'?') Then
   ReportNew(Path^.Dat.ToTemp+'zakaz.tmp','',NprintCC^.DAt.CopyShet,False,Logik);
End;{Procedure}




Procedure PrintZakaz (As: DocumentEditZ;CopyNkl : Byte);
Var Ez : PZakazType;
    E : PSuperMarketType;
    Copy,l : Word;
    NDS,z,ItogoSkidka,Itogo,
    NDS20,NDS10,NDS18,NDS16,NDS_ : Float;
    s : TMyString;
    ws : String[CName];
    pp : String[CPack];
    ws1 : TDateString;
    Find : Boolean;
    {DateMask : TDateString;}
    Proz : String[CLitr];
    txt,txt1 : Text;
    Logik : Boolean;
    SDoc,SDate,Space : AllStr;
    Barter : String[CMantissa];
    MMM : Maska55;
    NPrintCC :PNewPrintCopy;
    Cl : PClientType;
    MMMM : Maska8;
    CopyOtborka,Res,c : Word;


Begin

 New(Ez,Init);
 If Not GetZakaz(As.EditPosition,EZ) Then
  Begin
   Dispose(Ez,Done);
   MessageBox(#3'Заказ N '+As.EditPosition+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
  End;

 AInfo('Ищу заказ...');

 New(E,Init);

 ZakazToMarket(E,Ez);

 Assign(Txt1,Path^.Dat.ToTemp+'temp.tmp');
 l:=IOResult;
 Rewrite(Txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   NoInfo;
   Dispose(E,Done);
   Dispose(Ez,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'temp.tmp'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;

 Assign(Txt,Path^.Dat.ToTemp+'Nakladnp.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   NoInfo;
   Close(txt1);
   Dispose(E,Done);
   Dispose(Ez,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'Nakladnp.txt'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;


E^.Dat.Oformlenie:=1;
E^.Dat.FromZakaz:=As.EditPosition;
DelSpace(E^.Dat.FromZakaz);



Space:='      ';


If E^.Dat.DocSelector<>0 Then{если не список}
Begin
Writeln(Txt,Space+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
Writeln(Txt1,Space+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00')
End
Else
Begin
If E^.Dat.OperatorSelector<>0 Then
Begin
Writeln(Txt,Space+(*'Склад: ',{E^.Dat.Sklad}E^.Dat.SkladKod+*)
                  'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
Writeln(Txt1,Space+(*'Склад: ',{E^.Dat.Sklad}E^.Dat.SkladKod+*)
                  'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
End
 Else Begin
        Writeln(txt);
        Writeln(txt1);
      End;
End;

If Not(Ez^.Dat.DAteM=Ez^.Dat.DAteC) Or Not(Ez^.Dat.TimeM=Ez^.Dat.TimeC) Then
Writeln(txt,Space{+'Последние изменения:'}+' '+Ez^.Dat.DAteM+'('+Ez^.Dat.TimeM+')');
If Not(Ez^.Dat.DAteM=Ez^.Dat.DAteC) Or Not(Ez^.Dat.TimeM=Ez^.Dat.TimeC) Then
Writeln(txt1,Space{+'Последние изменения:'}+' '+Ez^.Dat.DAteM+'('+Ez^.Dat.TimeM+')');
ItogoSkidka:=0;   Itogo:=0; {NDS:=0;}

If E^.Dat.OperatorSelector<>2 Then Barter[0]:=#0
Else Barter:='-Б';

SDoc:=As.EditPosition;
DelSpace(SDoc);
SDate:=As.D;
Logik:=False;

Noinfo;


Writeln(Txt ,Space+' Внимание! Документ предназначен только для внутреннего использования!');
Writeln(Txt1,Space+' Внимание! Документ предназначен только для внутреннего использования!');

Writeln(Txt);
Writeln(Txt1);

s:=DateToDateString(DateMask,
DateStringToDate(DateMAsk,E^.Dat.DateC)+Ez^.Dat.EndDate);
Writeln(Txt,Space+'Срок доставки заказа до: '+s);
Writeln(Txt1,Space+'Срок доставки заказа до: '+s);

Case Ez^.Dat.Oformlenie Of
0:Begin
   Writeln(Txt,Space+'Статус: Подлежит оформлению');
   Writeln(Txt1,Space+'Статус: Подлежит оформлению');
  End;
1:Begin
   Writeln(Txt,Space+'Статус: По заказу оформлен - документ N '+Ez^.Dat.DocReal+' от '+Ez^.Dat.DocDate);
   Writeln(Txt1,Space+'Статус: По заказу оформлен - документ N '+Ez^.Dat.DocReal+' от '+Ez^.Dat.DocDate);
  End;
2:Begin
   Writeln(Txt,Space+'Статус: Заказ анулирован по истечении срока резервирования!');
   Writeln(Txt1,Space+'Статус: Заказ анулирован по истечении срока резервирования!');
  End;
Else;
End;


New(NPrintCC,Init);
NPrintCC^.Dat:=NPrintC^.Dat;

SortNkl(E);

CopyOtborka:=NPrintC^.Dat.CopyOtborka;


If E^.Dat.OperatorSelector in [0,2] Then
 Begin
New(Cl,Init);
Cl^.Dat.Kod:=E^.Dat.ClientKod;
GetClient(Cl,E^.Dat.OperatorSelector);

If Cl^.Dat.Dopolnenie.EnableAuto=1 Then{разрешено использовать персональные настройки}
 Begin
   With NPrintCC^.Dat Do
    Begin
     CopyNaklC   :=Cl^.Dat.Dopolnenie.CopyNaklC;
     CopyTTNC    :=Cl^.Dat.Dopolnenie.CopyTTNC;
     CopySF      :=Cl^.Dat.Dopolnenie.CopySF;
     CopyProtocol:=Cl^.Dat.Dopolnenie.CopyProtocol;
     CopyPrilog  :=Cl^.Dat.Dopolnenie.CopyPrilog;
     CopyPrilog2 :=Cl^.Dat.Dopolnenie.CopyPrilog2;
     CopyShet    :=Cl^.Dat.Dopolnenie.CopyShet;
     CopyPamatka :=Cl^.Dat.Dopolnenie.CopyPamatka;
     CopyGTDTTN  :=Cl^.Dat.Dopolnenie.CopyGTDTTN;
     CopyPKO     :=Cl^.Dat.Dopolnenie.CopyPKO;
     CopyRKO     :=Cl^.Dat.Dopolnenie.CopyRKO;
     CopyZakaz   :=Cl^.Dat.Dopolnenie.CopyZakaz;
    End;
 End;

Dispose(Cl,Done);
 End;{E^.Dat.OperatorSelector}



 {вычисляем отделения для печати отборочных листов}
 If NPrint^.Dat.PrintOtborka=1 Then
 Begin
  For c:=1 To CDivision Do MMMM[c]:=0;
  Res:=0;
  CalcDivision(E,MMMM,Res);
 End;
 {закончили вычислять отделения}


Writeln(Txt,Header+Space+'          З А Г Р У З О Ч Н Ы Й   л и с т  N '+'ЗЛ '+Ez^.Dat.Document+BArter+
'/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+ ' от ',Ez^.Dat.DAteC+' ('+ Ez^.Dat.TimeC+')');

Writeln(Txt1,Header+Space+'          З А Г Р У З О Ч Н Ы Й   л и с т  N '+'ЗЛ '+Ez^.Dat.Document+BArter+
'/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+ ' от ',Ez^.Dat.DAteC+' ('+ Ez^.Dat.TimeC+')');

Writeln(Txt, Space+'Поставщик: '+GetMakeField(FClient,Rek^.Dat.Kod,1));
Writeln(Txt1,Space+'Поставщик: '+GetMakeField(FClient,Rek^.Dat.Kod,1));

Writeln(Txt, Space+'Получатель: ',GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
E^.Dat.ClientKod+')'+HeaderStop);
Writeln(Txt1,Space+'Получатель: ',GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
E^.Dat.ClientKod+')'+HeaderStop);




TestDocumentsList(False,E^.Dat.ClientKod,MMM,E^.Dat,E^.Dat.OperatorSelector);

{печать собственно ЗЛ}
   FormNakl(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16,True,True,False,0,MMM);
   Copy:=Nprint^.DAt.FullName;
   Nprint^.DAt.FullName:=1;
   FormNakl(Space,False,As, E, Txt1, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16,False,True,False,0,MMM);
   Nprint^.DAt.FullName:=Copy;
   Close(txt);
   Close(txt1);

  If ((NPrintCC^.Dat.CopyZakaz>0) And (E^.Dat.OperatorSelector in [0,2])) Or
  (E^.Dat.OperatorSelector=1)Then
  If AutoAnswer(#3^M+#3'Печатать загрузочный лист N '+As.EditPosition+'?') Then
  {If MessageBox(#3^M+#3'Печатать загрузочный лист N '+As.EditPosition+'?',Nil,mfConfirmation+mfOkCancel)=CmOk Then}
  Begin
   ReportNew(Path^.Dat.ToTemp+'Nakladnp.txt',Path^.Dat.ToTemp+'temp.tmp',NPrintCC^.Dat.CopyZakaz,True,Logik);
  End;


   If NPrint^.Dat.PrintOtborka=1 Then
   If Res>0 Then
    Begin
     If CopyOtborka>0 Then
     If AutoAnswer(#3^M+#3'Печатать отборочный лист по заказу N '+As.EditPosition+'?') Then
      Begin
       PrintOtborka(As,MMMM,CopyOtborka,True{заказ/отгрузка},'');
      End;
    End;



  {If (Pharm=1) Then }
  If ((NPrintCC^.Dat.CopyShet>0) And (E^.Dat.OperatorSelector in [0,2])) Or
  (E^.DAt.OperatorSelector=1)Then
  If AutoAnswer(#3^M+#3'Печатать счет для клиента?') Then
  {If MessageBox(#3^M+#3'Печатать счет для клиента?',Nil,mfConfirmation+mfOkCancel)=CmOk Then}
  PrintShet(Ez,NPrintCC);





{печать приложение к документу}
   If ((PrintSertifDoc[2]=1)And(E^.DAt.OperatorSelector in [0,2])) Then

   If ((NPrintC^.Dat.CopyPrilog>0) And (E^.Dat.OperatorSelector in [0,2])) Or
  (E^.DAt.OperatorSelector=1)Then
   If TestFormPril(E) Then
   {If MessageBox(#3^M+#3'Печатать приложение к документу?',Nil,mfConfirmation+mfOkCancel)=CmOk Then}
  If AutoAnswer(#3^M+#3'Печатать приложение к документу?') Then
   Begin
    Rewrite(txt);
    FormPril( E, Txt,True);
    Close(txt);
    ReportNew(Path^.Dat.ToTemp+'Nakladnp.txt','',NPrintCC^.Dat.CopyPrilog,False,Logik);
   End;

{печать приложений к ГТД}
If NewGTD=0 Then
Begin
   If ((NPrintCC^.Dat.CopyGTDTTN>0) And (E^.Dat.OperatorSelector in [0,2])) Or
  (E^.DAt.OperatorSelector=1)Then
   If E^.Dat.DocSelector<>0 Then
   If TestRazdelA(E) Then
   {If MessageBox(#3^M+#3'Печатать приложение к ГТД?',Nil,mfConfirmation+mfOkCancel)=CmOk Then}
   If AutoAnswer(#3^M+#3'Печатать приложение к ГТД/ТТН?') Then
   Begin
    Rewrite(txt);
    FormRazdelA( E, Txt,True);
    Close(txt);
    If NewGtd=0 Then
    Report(Path^.Dat.ToTemp+'Nakladnp.txt','',NPrintCC^.Dat.CopyGTDTTN,False,Logik)
    Else
    PrintNewGTD;
   End;
End
 Else
  Begin

   If ((NPrintCC^.Dat.CopyGTDTTN>0) And (E^.Dat.OperatorSelector in [0,2])) Or
  (E^.DAt.OperatorSelector=1)Then
   If E^.Dat.DocSelector<>0 Then
   If TestRazdelA(E) Then
   {If MessageBox(#3^M+#3'Печатать приложение к ГТД?',Nil,mfConfirmation+mfOkCancel)=CmOk Then}
   If AutoAnswer(#3^M+#3'Печатать фотографии ?') Then
   Begin
    Rewrite(txt);
    FormRazdelA( E, Txt,True);
    Close(txt);
    If NewGtd=0 Then
    Report(Path^.Dat.ToTemp+'Nakladnp.txt','',NPrintCC^.Dat.CopyGTDTTN,False,Logik)
    Else
    PrintNewGTD;
   End;

  End;


    Space:='   ';
    Rewrite(txt);
    PrintNaklSertif(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,True,CopyNkl,True,MMM,NPrintCC);
    Close(txt);

   Dispose(Ez,Done);
   Dispose(E,Done);
   Dispose(NPrintCC,Done);
End;{Procedure}



Procedure PredZakazToMarket(Ez:PPredZakazType;Var E:PSuperMarketType);
Begin
(*
  With E^.Dat Do
  Begin

     Caption :=Ez^.DAt.Caption;
     OperatorSelector :=Ez^.DAt.OperatorSelector;
     DocSelector      :=Ez^.DAt.DocSelector;

     Versia:=Ez^.DAt.Versia;
     SkidkaSelector :=Ez^.DAt.SkidkaSelector;
     ShkalaNumer:=Ez^.DAt.ShkalaNumer;

     Summaz:=Ez^.DAt.SummaZ;
     Skidka:=Ez^.DAt.Skidka;
     SertifSummaz:=Ez^.DAt.SertifSummaZ;
     SertifSkidka:=Ez^.DAt.SertifSkidka;

     ClientKod :=Ez^.DAt.ClientKod;

     AgentKod :=Ez^.DAt.AgentKod;
     EkspeditorKod :=Ez^.DAt.EkspeditorKod;

     New(Skl,Init);
     New(BBB,Init);

     {перенос наименований}
     For c:=1 To Ez^.Dat.Amount Do
     Begin
     MarketElement[c].Bazkod:=Ez^.Dat.MarketElement[c].BAzKod;

     With MarketElement[c].Input Do
      Begin
        Skl^.Dat.BazKod:=Ez^.Dat.MarketElement[c].BAzKod;
        Version:=Ez^.Dat.MarketElement[c].Input.Version;
        GetSkladRecord(Skl);
        GetBazElement(Skl^.Dat.BazKod,BBB^.Dat);
        Kol := Ez^.Dat.MarketElement[c].Input.Kol;

        {пересчет ручной скидки}
        DelSpace(Skl^.Dat.Input.R_Zena);
        DelSpace(Ez^.Dat.MarketElement[c].Input.Zena);

If ZeniInZakaz=1 Then{если менять цени на складские}
Begin
        NewProz[0]:=#0;
       If (Skl^.Dat.Input.R_Zena)<>(Ez^.Dat.MarketElement[c].Input.Zena) Then
    Begin
       If StrToReal(Ez^.Dat.MarketElement[c].Input.Skidka)>=0 Then
        Begin
         If (StrToReal(Ez^.Dat.MarketElement[c].Input.Zena)-
            StrToReal(Ez^.Dat.MarketElement[c].Input.Skidka)) >0.009 Then
         Begin
         MySTr(StrToreal(Ez^.Dat.MarketElement[c].Input.Zena)/
            (StrToReal(Ez^.Dat.MarketElement[c].Input.Zena)-
            StrToReal(Ez^.Dat.MarketElement[c].Input.Skidka)),CKol,CMAntissa,NewProz);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)/StrToReal(NewProz),CZena,CMantissa,Skidka);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)-StrToReal(Skidka),CZena,CMantissa,Skidka);
         End
         Else Skidka:=Skl^.Dat.Input.R_Zena;
        End
         Else
        Begin
         {вариант наценки}
         MyStr(Abs(StrToReal(Ez^.Dat.MarketElement[c].Input.Skidka)/
                  StrToReal(Ez^.Dat.MarketElement[c].Input.Zena)),CKol,CMantissaZ,NewProz);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)*
                  StrToReal(NewProz),CKol,CMantissaZ,Skidka);
               DelSpace(Skidka);
               Skidka:='-'+Skidka;
        End;
    End
     Else
        {цена не изменилась}
        Begin
          Skidka:=Ez^.Dat.MarketElement[c].Input.Skidka;
        End;
End
    Else{если оставлять в накладной цени заказа}
    Begin
     NewProz[0]:=#0;
       If (Skl^.Dat.Input.R_Zena)<>(Ez^.Dat.MarketElement[c].Input.Zena) Then
    Begin
       {получили реальную цену к оплате в заказе}
       MyStr(StrToReal(Ez^.Dat.MarketElement[c].Input.Zena)
               -StrToReal(Ez^.Dat.MarketElement[c].Input.Skidka),
                  CZena,CMantissa,NewProz);

       {расчитываем отклонение нужной цены от текущей складской}
       MyStr(StrToReal(Skl^.Dat.Input.R_Zena)-
                StrToReal(NewProz),CZena,CMantissa,NewProz);
       DelSpace(NewProz);
       Skidka:=NewProz;
    End
     Else
        {цена не изменилась}
        Begin
          Skidka:=Ez^.Dat.MarketElement[c].Input.Skidka;
        End;

    End;{Else ZeniInZakaz}

        DelSpace(Skidka);

        Zena    :=Skl^.Dat.Input.R_Zena;
        R_Zena  :=Skl^.Dat.Input.R_Zena;
        O_Zena  :=Skl^.Dat.Input.O_Zena;
        Zakupka :=Skl^.Dat.Input.Zakupka;
        Zakupka2 :=Skl^.Dat.Input.Zakupka2;
        AkzisSbor:=Skl^.Dat.Input.AkzisSbor;
        ZenaMarki:=Skl^.Dat.Input.ZenaMarki;
        RegionMarka :=Skl^.Dat.Input.RegionMarka;

        {MyStr(StrToReal(Zena)*StrToInt(Kol),CInputIZena,CMantissa,Itogo);}

        Proz    :=Ez^.Dat.MarketElement[c].Input.Proz;

        VidNDS  :=BBB^.Dat.VidNDS;
        NDS     :=BBB^.Dat.NDS;
        VidNalog   :=BBB^.Dat.VidNalog;
        SpecNalog  :=BBB^.Dat.Nalog;
        DiviSionNumber:=Ez^.Dat.MarketElement[c].Input.InputDivision;
        Last     :=False;

        NSertif  :=Ez^.Dat.MarketElement[c].Input.NSertif;
        SertifKol:=Ez^.Dat.MarketElement[c].Input.SertifKol;

       MarkaKod :=Ez^.Dat.MarketElement[c].Input.MarkaKod;
       SMarkaKod:=Ez^.Dat.MarketElement[c].Input.SMarkaKod;
       NGTDKod  :=Ez^.Dat.MarketElement[c].Input.NGTDKod;
       ExpertKod:=Ez^.Dat.MarketElement[c].Input.ExpertKod;
       Srok     :=Ez^.Dat.MarketElement[c].Input.Srok;
     Virabotano :=Ez^.Dat.MarketElement[c].Input.Virabotano;

      End;{With}
     End;

     {перенос сертификатов}
     For c:=1 To Ez^.Dat.AmountS Do
     Begin
     DocumentElement[c].Bazkod:=Ez^.Dat.DocumentElement[c].BAzKod;
     With DocumentElement[c].Input Do
      Begin
        Version:=Ez^.Dat.DocumentElement[c].Input.Version;

        Skl^.Dat.BazKod:=Ez^.Dat.DocumentElement[c].BAzKod;

        GetSkladRecord(Skl);
        GetBazElement(Skl^.Dat.BazKod,BBB^.Dat);

        Kol:=Ez^.Dat.DocumentElement[c].Input.Kol;

        {пересчет ручной скидки}
        {пересчет ручной скидки}
       DelSpace(Skl^.Dat.Input.R_Zena);
       DelSpace(Ez^.Dat.DocumentElement[c].Input.Zena);

If ZeniInZakaz=1 Then{если менять цени на складские}
Begin
        NewProz[0]:=#0;
       If (Skl^.Dat.Input.R_Zena)<>(Ez^.Dat.DocumentElement[c].Input.Zena) Then
    Begin
       If StrToReal(Ez^.Dat.DocumentElement[c].Input.Skidka)>=0 Then
        Begin
         If (StrToReal(Ez^.Dat.DocumentElement[c].Input.Zena)-
            StrToReal(Ez^.Dat.DocumentElement[c].Input.Skidka)) >0.009 Then
         Begin
         MySTr(StrToreal(Ez^.Dat.DocumentElement[c].Input.Zena)/
            (StrToReal(Ez^.Dat.DocumentElement[c].Input.Zena)-
            StrToReal(Ez^.Dat.DocumentElement[c].Input.Skidka)),CKol,CMAntissa,NewProz);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)/StrToReal(NewProz),CZena,CMantissa,Skidka);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)-StrToReal(Skidka),CZena,CMantissa,Skidka);
         End
         Else Skidka:=Skl^.Dat.Input.R_Zena;
        End
         Else
        Begin
         {вариант наценки}
         MyStr(Abs(StrToReal(Ez^.Dat.DocumentElement[c].Input.Skidka)/
                  StrToReal(Ez^.Dat.DocumentElement[c].Input.Zena)),CKol,CMantissaZ,NewProz);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)*
                  StrToReal(NewProz),CKol,CMantissaZ,Skidka);
               DelSpace(Skidka);
               Skidka:='-'+Skidka;
        End;
    End
     Else
        {цена не изменилась}
        Begin
          Skidka:=Ez^.Dat.DocumentElement[c].Input.Skidka;
        End;
End
    Else{если оставлять в накладной цени заказа}
    Begin
     NewProz[0]:=#0;
       If (Skl^.Dat.Input.R_Zena)<>(Ez^.Dat.DocumentElement[c].Input.Zena) Then
    Begin
       {получили реальную цену к оплате в заказе}
       MyStr(StrToReal(Ez^.Dat.DocumentElement[c].Input.Zena)
               -StrToReal(Ez^.Dat.DocumentElement[c].Input.Skidka),
                  CZena,CMantissa,NewProz);

       {расчитываем отклонение нужной цены от текущей складской}
       MyStr(StrToReal(Skl^.Dat.Input.R_Zena)-
                StrToReal(NewProz),CZena,CMantissa,NewProz);
       DelSpace(NewProz);
       Skidka:=NewProz;
    End
     Else
        {цена не изменилась}
        Begin
          Skidka:=Ez^.Dat.DocumentElement[c].Input.Skidka;
        End;

    End;{Else ZeniInZakaz}


        DelSpace(Skidka);

        Zena    :=Skl^.Dat.Input.R_Zena;
        R_Zena  :=Skl^.Dat.Input.R_Zena;
        O_Zena  :=Skl^.Dat.Input.O_Zena;
        Zakupka :=Skl^.Dat.Input.Zakupka;
        Zakupka2:=Skl^.Dat.Input.Zakupka2;
        AkzisSbor:=Skl^.Dat.Input.AkzisSbor;
        ZenaMarki:=Skl^.Dat.Input.ZenaMarki;
        RegionMarka :=Skl^.Dat.Input.RegionMarka;

        {MyStr(StrToReal(Zena)*StrToInt(Kol),CInputIZena,CMantissa,Itogo);}

        Proz    :='0.00';
        VidNDS  :=BBB^.Dat.VidNDS;
        NDS     :=BBB^.Dat.NDS;
        VidNalog   :=BBB^.Dat.VidNalog;
        SpecNalog  :=BBB^.Dat.Nalog;
        DiviSionNumber:=Ez^.Dat.DocumentElement[c].Input.InputDivision;
        Last     :=False;
        NSertif  :=Ez^.Dat.DocumentElement[c].Input.NSertif;
        SertifKol:=Ez^.Dat.DocumentElement[c].Input.SertifKol;
      End;
     End;

     Dispose(Skl,Done);
     Dispose(BBB,Done);

     DateC   :=Ez^.DAt.DateC;
     TimeC   :=Ez^.DAt.TimeC;
     DateM   :=Ez^.DAt.DateM;
     TimeM   :=Ez^.DAt.TimeM;

   SkladKod  :=Ez^.DAt.SkladKod;
     Active  :=True;
     Srok    :=Ez^.DAt.Srok;
     Amount  :=Ez^.DAt.Amount;
     AmountS :=Ez^.DAt.AmountS;
     Locked  :=Ez^.DAt.Locked;
     Rashet  :=Ez^.DAt.Rashet;
     {Comment :=Ez^.DAt.Comment;}

  End;{With}
*)
End;




Procedure PrintPredZakaz (As: DocumentEditZ;CopyNkl : Byte);
Var Ez : PPredZakazType;
    E : PSuperMarketType;
    Copy,l : Word;
    NDS,z,ItogoSkidka,Itogo,
    NDS20,NDS10,NDS18,NDS16,NDS_ : Float;
    s : TMyString;
    ws : String[CName];
    pp : String[CPack];
    ws1 : TDateString;
    Find : Boolean;
    {DateMask : TDateString;}
    Proz : String[CLitr];
    txt,txt1 : Text;
    Logik : Boolean;
    SDoc,SDate,Space : AllStr;
    Barter : String[CMantissa];
    MMM : Maska55;
    NPrintCC :PNewPrintCopy;
    Cl : PClientType;

Begin

 New(Ez,Init);
 If Not GetPredZakaz(As.EditPosition,EZ) Then
  Begin
   Dispose(Ez,Done);
   MessageBox(#3'ПредЗаказ N '+As.EditPosition+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
  End;

 AInfo('Ищу предзаказ...');

 New(E,Init);

 PredZakazToMarket(Ez,E);

 Assign(Txt1,Path^.Dat.ToTemp+'temp.tmp');
 l:=IOResult;
 Rewrite(Txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   NoInfo;
   Dispose(E,Done);
   Dispose(Ez,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'temp.tmp'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;

 Assign(Txt,Path^.Dat.ToTemp+'Nakladnp.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   NoInfo;
   Close(txt1);
   Dispose(E,Done);
   Dispose(Ez,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'Nakladnp.txt'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;


Space:='      ';


If E^.Dat.DocSelector<>0 Then{если не список}
Begin
Writeln(Txt,Space+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-04');
Writeln(Txt1,Space+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-04')
End
Else
Begin
If E^.Dat.OperatorSelector<>0 Then
Begin
Writeln(Txt,Space+
                  'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-04');
Writeln(Txt1,Space+
                  'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-04');
End
 Else Begin
        Writeln(txt);
        Writeln(txt1);
      End;
End;

If Not(Ez^.Dat.DAteM=Ez^.Dat.DAteC) Or Not(Ez^.Dat.TimeM=Ez^.Dat.TimeC) Then
Writeln(txt,Space{+'Последние изменения:'}+' '+DateToDateString(Datemask,Ez^.Dat.DAteM)+'('+
TimeToTimeString('hh:mm:ss',Ez^.Dat.TimeM)+')');
If Not(Ez^.Dat.DAteM=Ez^.Dat.DAteC) Or Not(Ez^.Dat.TimeM=Ez^.Dat.TimeC) Then
Writeln(txt1,Space{+'Последние изменения:'}+' '+DateToDateString(Datemask,Ez^.Dat.DAteM)+'('+
TimeToTimeString('hh:mm:ss',Ez^.Dat.TimeM)+')');
ItogoSkidka:=0;   Itogo:=0; {NDS:=0;}

If E^.Dat.OperatorSelector<>2 Then Barter[0]:=#0
Else Barter:='-Б';

SDoc:=As.EditPosition;
DelSpace(SDoc);
SDate:=As.D;
Logik:=False;

Noinfo;


Writeln(Txt ,Space+' Внимание! Документ предназначен только для внутреннего использования!');
Writeln(Txt1,Space+' Внимание! Документ предназначен только для внутреннего использования!');

Writeln(Txt);
Writeln(Txt1);

s:=ez^.Dat.DateEnd;
Writeln(Txt,Space+'Срок доставки предзаказа до: '+s);
Writeln(Txt1,Space+'Срок доставки предзаказа до: '+s);

Case Ez^.Dat.Status Of
4:Begin
   Writeln(Txt,Space+'Статус: Подлежит оформлению');
   Writeln(Txt1,Space+'Статус: Подлежит оформлению');
  End;
5:Begin
   Writeln(Txt,Space+'Статус: По предзаказу оформлен - документ N '+Ez^.Dat.ZakazNumer);
   Writeln(Txt1,Space+'Статус: По предзаказу оформлен - документ N '+Ez^.Dat.ZakazNumer);
  End;
6:Begin
   Writeln(Txt,Space+'Статус: ПредЗаказ анулирован по истечении срока резервирования!');
   Writeln(Txt1,Space+'Статус: ПредЗаказ анулирован по истечении срока резервирования!');
  End;
Else;
End;


New(NPrintCC,Init);
NPrintCC^.Dat:=NPrintC^.Dat;

SortNkl(E);

If E^.Dat.OperatorSelector in [0,2] Then
 Begin
New(Cl,Init);
Cl^.Dat.Kod:=E^.Dat.ClientKod;
GetClient(Cl,E^.Dat.OperatorSelector);

If Cl^.Dat.Dopolnenie.EnableAuto=1 Then{разрешено использовать персональные настройки}
 Begin
   With NPrintCC^.Dat Do
    Begin
     CopyNaklC   :=Cl^.Dat.Dopolnenie.CopyNaklC;
     CopyTTNC    :=Cl^.Dat.Dopolnenie.CopyTTNC;
     CopySF      :=Cl^.Dat.Dopolnenie.CopySF;
     CopyProtocol:=Cl^.Dat.Dopolnenie.CopyProtocol;
     CopyPrilog  :=Cl^.Dat.Dopolnenie.CopyPrilog;
     CopyPrilog2 :=Cl^.Dat.Dopolnenie.CopyPrilog2;
     CopyShet    :=Cl^.Dat.Dopolnenie.CopyShet;
     CopyPamatka :=Cl^.Dat.Dopolnenie.CopyPamatka;
     CopyGTDTTN  :=Cl^.Dat.Dopolnenie.CopyGTDTTN;
     CopyPKO     :=Cl^.Dat.Dopolnenie.CopyPKO;
     CopyRKO     :=Cl^.Dat.Dopolnenie.CopyRKO;
     CopyZakaz   :=Cl^.Dat.Dopolnenie.CopyZakaz;
    End;
 End;

Dispose(Cl,Done);
 End;{E^.Dat.OperatorSelector}



Writeln(Txt,Header+Space+'          П Р Е Д З А К А З   N '+Ez^.Dat.Document+BArter+
'/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+ ' от ',
DateToDateString(DateMask,Ez^.Dat.DAteC)+' ('+ TimeToTimeString('hh:mm:ss',Ez^.Dat.TimeC)+')');

Writeln(Txt1,Header+Space+'          П Р Е Д З А К А З   N '+Ez^.Dat.Document+BArter+
'/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)+ ' от ',
DateToDateString(DateMask,Ez^.Dat.DAteC)+' ('+ TimeToTimeString('hh:mm:ss',Ez^.Dat.TimeC)+')');

Writeln(Txt, Space+'Поставщик: '+GetMakeField(FClient,Rek^.Dat.Kod,1));
Writeln(Txt1,Space+'Поставщик: '+GetMakeField(FClient,Rek^.Dat.Kod,1));

Writeln(Txt, Space+'Получатель: ',GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
E^.Dat.ClientKod+')'+HeaderStop);
Writeln(Txt1,Space+'Получатель: ',GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
E^.Dat.ClientKod+')'+HeaderStop);

TestDocumentsList(False,E^.Dat.ClientKod,MMM,E^.Dat,E^.Dat.OperatorSelector);

{печать собственно ЗЛ}
   FormNakl(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16,True,True,False,0,MMM);
   Copy:=Nprint^.DAt.FullName;
   Nprint^.DAt.FullName:=1;
   FormNakl(Space,False,As, E, Txt1, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16,False,True,False,0,MMM);
   Nprint^.DAt.FullName:=Copy;
   Close(txt);
   Close(txt1);

  If ((NPrintCC^.Dat.CopyZakaz>0) And (E^.Dat.OperatorSelector in [0,2])) Or
  (E^.Dat.OperatorSelector=1)Then
  If AutoAnswer(#3^M+#3'Печатать предЗаказ N '+As.EditPosition+'?') Then
  Begin
   ReportNew(Path^.Dat.ToTemp+'Nakladnp.txt',Path^.Dat.ToTemp+'temp.tmp',NPrintCC^.Dat.CopyZakaz,True,Logik);
  End;



   Dispose(Ez,Done);
   Dispose(E,Done);
   Dispose(NPrintCC,Done);

End;{Procedure}




Procedure PrintNaklRet (As: DocumentEditZ;CopyNkl : Byte);
Var f : MarketFileType;
    E : PSuperMarketType;
    Copy,l : Word;
    NDS,z,ItogoSkidka,Itogo,
    NDS20,NDS10,NDS18,NDS16,NDS_ : Float;
    s : TMyString;
    ws : String[CName];
    pp : String[CPack];
    ws1 : TDateString;
    Find : Boolean;
    {DateMask : TDateString;}
    Proz : String[CLitr];
    txt : Text;
    Logik : Boolean;
    SDoc,SDate,Space : AllStr;
    Barter : String[CMantissa];
Begin
 DInfoMsg('Ищу документ...',True);
 Space:='      ';
 Assign(F,Path^.Dat.ToMarket+As.D+'.mrk');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfoMsg;
   MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToMarket+As.D+'.mrk'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt,Path^.Dat.ToTemp+'Nakladnp.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   l:=IOResult;
   NoInfoMsg;
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'Nakladnp.txt'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;
 Close(Txt);
 l:=IOResult;

{ CloSe(Txt1); убрал иначе возникает ошибка}


 Find :=False;
 New(E,Init);


 {оптимизация поиска при печати}
   If FileSize(F)>(StrToInt(As.EditPosition)-1) Then
    Begin
     Seek(F,StrToInt(As.EditPosition)-1);
     ReadMarket(F,E);
     DelSpace(E^.Dat.Document);
  If  (StrToInt(E^.Dat.Document)=StrToInt(As.EditPosition)) And(E^.Dat.Active)
  And(E^.Dat.DateC=As.D) Then
         Begin
             Find:=True;
         End
         Else Seek(F,0);
    End;

 While Not(Eof(f))And Not(Find) Do
 Begin
     ReadMarket(f,E);
  DelSpace(E^.Dat.Document);
  If  (StrToInt(E^.Dat.Document)=StrToInt(As.EditPosition)) And(E^.Dat.Active)
  And(E^.Dat.DateC=As.D) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Dispose(E,Done);
   Close(f);
   l:=IOResult;
   NoInfoMsg;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
 End;
 Close(f);
 l:=IOResult;

 Append(txt);
 FormSf(True, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16,False,'');
{Erase(Txt1);}
 Close(Txt);
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;

If E^.Dat.DocSelector<>0 Then{если не список}
Begin
Writeln(Txt,Space+(*'Склад: ',{E^.Dat.Sklad+}E^.Dat.SkladKod+*)
                  'Оператор: '+E^.Dat.Caption+' EYE & 1997-00');
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
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
ItogoSkidka:=0;   Itogo:=0; {NDS:=0;}

If E^.Dat.OperatorSelector<>2 Then Barter[0]:=#0
Else Barter:='-Б';

{If E^.Dat.DocSelector=5 Then
   If TestSf(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC) Then Inc(E^.Dat.DocSelector);}

Noinfomsg;



Case E^.Dat.DocSelector Of
5,7
  :begin
   {накладная возврата для непроводной консигнации}
   If E^.Dat.DocSelector in [5,7] Then
   Begin
    Writeln(Txt,Header+Space+'         Н А К Л А Д Н А Я  возврата на склад N _____'+
   ' / '+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)
    +' от '+'___________');

    WriteLn(Txt,Space+'Поставщик: ', GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
    E^.Dat.ClientKod+')');


    Writeln(Txt,Space+'Получатель: '+RekSF^.Dat.Name+HeaderStop);
    FormNaklRet(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,True);
    Copy:=Nprint^.DAt.FullName;
    Close(txt);
    If MessageBox(#3^M+#3'Печатать накладную возврата по документу консигнации N '+As.EditPosition+'?',Nil,
    mfConfirmation+mfOkCancel)=CmOk Then
    Begin
     ReportNew(Path^.Dat.ToTemp+'Nakladnp.txt',Path^.Dat.ToTemp+'temp.tmp',NprintC^.DAt.CopyReturn,True,False);
    End;
   End;
   Dispose(E,Done);
  end;{реализация}
Else Close(txt);
l:=IOResult;
End;

End;


(*
Procedure FindLastPrihod(Date:TDAteString;Art:ArtikulStr;
Var NewPostName,NewFirmName,NewSeria,NewNGTD:AllStr);
var
    l,Start,Stop,Cur,Cur1 : LongInt;
    c : Word;
    E : PPrihodType;
    Ef : PrihodFileType;
    s : String;
    Find : Boolean;

Begin
Start:=DateStringToDate(DateMask,'01-02-01');
Stop:=DateStringToDate(DateMask,Date);

New(E,Init);


Find:=False;

For Cur:=Stop DownTo Start Do
Begin

Assign(ef,Path^.Dat.ToPrihod+DAteToDateString(DateMAsk,Cur)+'.prh');
l:=IoResult;
Reset(ef);
l:=IoResult;
If l<>0 Then
 Begin
  Continue;
 End;

While Not(Eof(Ef)) And Not(Find) Do
 Begin
  ReadPrihod(Ef,E);
   If E^.Dat.OperatorSelector in [0,2] Then
    Begin
     For c:=1 To E^.DAt.Amount Do
      Begin
       If E^.DAt.PrihodElement[c].BazKod=Art Then
        Begin
         Format(E^.DAt.PrihodElement[c].Input.Marka,CNSertif);
         Format(E^.DAt.PrihodElement[c].Input.NGTD,CNSertif);
         NewPostName:=GetPostField(FPost,GetIDField(FPost,E^.DAt.PrihodElement[c].BazKod));
         Format(NewPostName,CPost);
         NewFirmName:=GetFirmaPostField(FFirmaPost,GetIDField(FFirmaPost,E^.DAt.PrihodElement[c].BazKod));
         Format(NewFirmName,CFirmaPost);
         NewSeria:=E^.DAt.PrihodElement[c].Input.Marka;
         NewNGTD:=E^.DAt.PrihodElement[c].Input.NGTD;
         Find:=True;
         Break;
        End;
      End;{For}
    End;{OperatorSelector}
 End;{While}

l:=IoResult;
Close(Ef);
l:=IoResult;

If Find Then Break;

End;{For}
Dispose(E,Done);
End;{Procedure}

*)



Procedure AddMarketToMarketListWithZena(Const E:SuperMarketType);
Var j,i : Word;
    l,k,pp:Byte;
    Artikul : ArtikulStr;
    Find : Boolean;
    ws1,ws ,s: String;
    Start,Stop : TDateString;
    Lg : PSuperMarketType;
    Logik : Boolean;
    Zen : TDateString;
    NewSeria,BAkSeria : AllStr;
    NewName,BakName,NewPostName,NewFirmNAme,BakPostNAme,BakFirmName : AllStr;
    BakNGTD,NewNGTD : AllStr;

Begin
   New(Lg,Init);

   k:=1;pp:=1;
   For l:=1 To E.Amount Do
    Begin
      Lg^.Dat.MarketElement[l]:=E.MarketElement[l];

       Case E.SkidkaSelector Of
            0,2:Begin{скидка автоматическая}
               Str(StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)/
               (1+StrToReal(Lg^.Dat.MarketElement[l].Input.Proz)/100):CZena:CMantissa,Lg^.Dat.MarketElement[l].Input.Zena);
              End;
            1:Begin{скидка ручная}
                Str(StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)-
                StrToReal(Lg^.Dat.MarketElement[l].Input.Skidka):CZena:CMantissa,Lg^.Dat.MarketElement[l].Input.Zena);
               End;
       Else
       End;
    End;

    Lg^.DAt.Amount:=E.Amount;
    Lg^.Dat.Document:=E.Document;
    Lg^.Dat.DateC:=E.DateC;
    Lg^.Dat.ClientKod:=E.ClientKod;
    Lg^.Dat.SkidkaSelector:=E.SkidkaSelector;


For i:=1 To Lg^.Dat.Amount Do
 Begin
  Artikul:=Lg^.Dat.MarketElement[i].BazKod;
  NewName:=GetIdField(FFFName,Lg^.Dat.MarketElement[i].BazKod);
{
  NewPostNAme:=BakGetField1(FPost,Lg^.Dat.MarketElement[i].BazKod,0);
  NewFirmNAme:=BakGetField1(FFirmaPost,Lg^.Dat.MarketElement[i].BazKod,0);
  NewSeria:=BakGetField1(FMArka,Lg^.Dat.MarketElement[i].BazKod,0);
  NewNGTD:=BakGetField1(FMArka,Lg^.Dat.MarketElement[i].BazKod,0);
}

  NewPostNAme[0]:=#0;
  NewFirmNAme[0]:=#0;
  NewSeria[0]:=#0;
  NewNGTD[0]:=#0;

  {FindLastPrihod(Lg^.Dat.DateC,Lg^.Dat.MarketElement[i].BazKod,NewPostName,NewFirmName,NewSeria,NewNGTD);}

  NewPostName:=GetPostField(FPost,GetIDField(FPost,Lg^.Dat.MarketElement[i].BazKod));
  NewFirmName:=GetFirmaPostField(FFirmaPost,GetIDField(FFirmaPost,Lg^.Dat.MarketElement[i].BazKod));

If MarketSD=0 Then
Begin
  NewSeria:=GetMarkaField(FMarka,{BakGetField(FMarka,}Lg^.Dat.MarketElement[i].Input.MarkaKod{,0)});
  NewNGTD:=GetNGTDField(FNGTD,{BakGetField(FNGTD,}Lg^.Dat.MarketElement[i].Input.NGTDKod{,0)});
End
 Else
  Begin
  NewSeria:=GetMarkaField(FMarka,BakGetField(FMarka,Lg^.Dat.MarketElement[i].BazKod,0));
  NewNGTD:=GetNGTDField(FNGTD,BakGetField(FNGTD,Lg^.Dat.MarketElement[i].BazKod,0));
  End;

  Format(NewFirmNAme,CFirmaPost);
  Format(NewSeria,CName);
  Format(NewPostNAme,CPost);
  Format(NewNGTD,CName);
  {DelSpaceRight(NewName);}

  If TempBox^.List^.Count-1>=0 Then
  Begin
   Logik:=True;
   For j:=0 To TempBox^.List^.Count-1 Do
    Begin
     Find:=False;
     ws:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CFullName,CArtikul);


     BakName:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1,CFullName);
     DelSpaceRight(BakName);


     Zen:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CFullName+1+CArtikul+1+CKol+1,CZena);

     BakPostName:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CFullName+1+CArtikul+1+CKol+1+CZena+1+CDAte+1+CDAte+1,CPost);
     BakFirmName:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CFullName+1+CArtikul+1+CKol+1+CZena+1+CDAte+1+CDAte+1+
        CPost+1,CFirmaPost);

     BakSeria:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CFullName+1+CArtikul+1+CKol+1+CZena+1+CDAte+1+CDAte+1+
        CPost+1+CFirmaPost+1,CName);

     BakNGTD:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CFullName+1+CArtikul+1+CKol+1+CZena+1+CDAte+1+CDAte+1+
        CPost+1+CFirmaPost+1+CName+1,CName);


     Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
     Str(StrToReal(Zen):CZena:CMantissa,Zen);

     If (ws=Lg^.Dat.MarketElement[i].BazKod){(NewName=BakName)} And (Zen=Lg^.Dat.MarketElement[i].Input.Zena)
        And (NewPostNAme=BakPostNAme) And (NewFirmNAme=BAkFirmNAme) And (NewSeria=BAkSeria)
        And (NewNGTD=BAkNGTD) Then
      Begin

       Logik:=False;
       ws:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CFullName,CKol);
           Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);

       Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
       s:=NewName{GetIdField(FFFName,Artikul)};
       Format(s,CFullName);

       ws1:=copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CFullName,CKol);
       Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)+StrToInt(ws1):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
       ws1:=copy(TempBox^.GetText(j,TempBox^.List^.Count),1+CArtikul+1+CFullName+1+CKol+1,CZena);
       Str(StrToReal(ws1):CZena:CMantissa,ws);

       {стартовая дата}
       Start:=copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CFullName+CKol+1+CZena+1,CDAte);
       Stop:=copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CFullName+CKol+1+CZena+1+CDAte+1,CDate);

       If DateStringToDate(DateMask,Start)>DateStringToDate(DateMask,Lg^.Dat.DateC) Then Start:=Lg^.Dat.DateC;

       If DateStringToDate(DateMask,Stop)>DateStringToDate(DateMask,Lg^.Dat.DateC) Then Stop:=Lg^.Dat.DateC;

       s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+ws+'│'+Start+'│'+Stop+
          '│'+BAkPostNAme+'│'+BAkFirmNAme+'│'+BAkSeria+'│'+BakNGTD;
       TempBox^.List^.AtFree(j);
       TempBox^.SetRange(TempBox^.List^.Count);
       TempBox^.List^.Insert(NewStr(s));
       TempBox^.SetRange(TempBox^.List^.Count);
       Find:=True;
       Break;
      End;
    End;{For по списку продаж}

    If Logik Then{Если не найдено ни одного вхождения}
     Begin
        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,ws);
        s:=NewNAme{GetIdField(FFFName,Artikul)};
        Format(s,CFullName);

        s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+ws+'│'+
           Lg^.Dat.DateC+'│'+Lg^.Dat.DateC+
           '│'+NewPostNAme+'│'+NewFirmNAme+'│'+NewSeria+'│'+NewNGTD;

        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
        {Break;}
     End;
  End{если список не пустой}
    Else
      Begin
        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,ws);
        s:=NewName{GetIdField(FFFName,Artikul)};
        Format(s,CFullName);

        s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+ws+'│'+
           Lg^.Dat.DateC+'│'+Lg^.Dat.DateC+
           '│'+NewPostNAme+'│'+NewFirmNAme+'│'+NewSeria+'│'+NewNGTD;

        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
      End;
 End;{For i:=1 To E^.Dat.Amount Do}

 Dispose(lg,Done);
End;


Function PeriodProd:Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control,ControlStart,ControlStop : PView;
  C : Word;
  l : LongInt;
  s1,s2 : TDateString;

begin
PeriodProd :=False;
s1:=FDate;
s2:=FDate;

1:
R.Assign(23, 9, 57, 14);
New(Dlg, Init(R, 'Период расчета продаж'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E011;
Dlg^.Palette := dpCyanDialog;

R.Assign(6, 2, 16, 3);
ControlStart := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStart);
  PInputLine(ControlStart)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));

ControlStart^.SetData(s1);

  R.Assign(3, 2, 6, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~с~:', ControlStart)));

R.Assign(20, 2, 30, 3);
ControlStop := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStop);
  PInputLine(ControlStop)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));

ControlStop^.SetData(s2);

  R.Assign(16, 2, 20, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~п~о:', ControlStop)));

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
   ControlStart^.GetData(s1);
   ControlStop^.GetData(s2);
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);

   If Not(TestDate(s1,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Not(TestDate(s2,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   StartDate:=s1;
   StopDate:=s2;
   PeriodProd:=True;

   {если даты перепутаны переставляем их}
   If DateStringToDate(DateMask,StopDate)<DateStringToDate(DateMask,StartDate) Then
    Begin
        s1:=StopDate;
        StopDate:=StartDate;
        StartDate:=s1;
    End;
 End
 Else
  Begin
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);
  End;
end;


Procedure CalcPrihod(Const StartStr,StopStr:TDateString;Var wspomList1:PBox;Var txt2:Text);
var
    l,Start,Stop,Cur,Cur1 : LongInt;
    c : Word;
    E : PPrihodType;
    Ef : PrihodFileType;
    s : String;
    SPost,SFirma,SMarka,SNGTD:AllStr;

Begin
Start:=DateStringToDate(DateMask,StartStr);
Stop:=DateStringToDate(DateMask,StopStr);

New(E,Init);

Cur1:=Start;
For Cur:=Stop DownTo Start Do
Begin

DInfoMsgShkala('Просматриваю приходы за '+DAteToDateString(DateMAsk,Cur)+' ...',Start,Stop,Cur1);

Inc(Cur1);

Assign(ef,Path^.Dat.ToPrihod+DAteToDateString(DateMAsk,Cur)+'.prh');
l:=IoResult;
Reset(ef);
l:=IoResult;
If l<>0 Then
 Begin
   Writeln(txt2,'Не найден файл прихода за '+DAteToDateString(DateMAsk,Cur)+'  "'+DayString[DayOfWeek(Cur)]+'"'+
   +' Код:'+IntToStr(L,3));
  Continue;
 End;

While Not(Eof(Ef)) Do
 Begin
  ReadPrihod(Ef,E);
   If E^.Dat.OperatorSelector in [0,2] Then
    Begin
     DelSpace(E^.DAt.Rekwizit.Numer);
     DelSpace(E^.DAt.Rekwizit.Date);
     Format(E^.DAt.Rekwizit.Numer,CDate);
     Format(E^.DAt.Document,CDocNumer);
     Format(E^.DAt.DateC,CDate);
     Format(E^.DAt.Rekwizit.Date,CDate);
     For c:=1 To E^.DAt.Amount Do
      Begin
       If StrToInt(E^.DAt.PrihodElement[c].Input.Kol)>0 Then
       If TestElement(E^.DAt.PrihodElement[c].BazKod,WspomList1) Then
        Begin
         {
         Format(E^.DAt.PrihodElement[c].Input.Post,CPost);
         Format(E^.DAt.PrihodElement[c].Input.FirmaPost,CFirmaPost);
         }
         SPost:=GetPostField(FPost,GetIdField(FPost,E^.DAt.PrihodElement[c].BazKod));
         SFirma:=GetFirmaPostField(FFirmaPost,GetIdField(FFirmaPost,E^.DAt.PrihodElement[c].BazKod));
         SMarka:=GetMarkaField(FMarka,E^.DAt.PrihodElement[c].Input.Marka);
         SNGTD:=GetNGTDField(FNGTD,E^.DAt.PrihodElement[c].Input.NGTD);


         Format(SPost,CPost);
         Format(SFirma,CFirmaPost);
         Format(SMArka,CNSertif);
         Format(SNGTD,CNSertif);

         s:='│'+E^.DAt.PrihodElement[c].BazKod+'│'+E^.DAt.Rekwizit.Numer+'│'+
            E^.DAt.Rekwizit.DAte+'│'+E^.DAt.Document+'│'+E^.DAt.DateC+'│'+E^.Dat.MAkeKod+
            '│'+SPost+
		  '│'+SFirma+
            '│'+SMarka+
		  '│'+SNGTD;
         WspomList1^.List^.Insert(NewStr(s));
         WspomList1^.SetRange(WspomList1^.List^.Count);
        End;
      End;{For}
    End;{OperatorSelector}
 End;{While}

l:=IoResult;
Close(Ef);
l:=IoResult;

End;{For}
NoInfoMsg;
Dispose(E,Done);
End;{Procedure}




Procedure CalcBuch;
Var f : File;
    R : TRect;
    E : PBufSuperMarketType;
    l : Word;
    Date : TDAteString;
    NDS,z,AllSkidka,AllItogo,ItogoSkidka,Itogo : Real;
    s,Seria : String;
    SArt,ws,ws1,ws2 : AllStr;
    txt1,txt2 : Text;
    k,i,j  : Word;
    Vid : Word;
    RAbday,Start,Stop,Den : LongInt;
    Space : AllStr;
    mm3 : Maska3;
    mm9 : Maska9;
    c,Count : Word;
    SLastCod,SNDS,SLastPost : AllStr;
Begin

 Space:='';

 If Not(PeriodProd) Then Exit;

 Start:=DateStringToDate(DateMask,StartDate);
 Stop:=DateStringToDate(DateMask,StopDate);



 If Not(SelectOperationAndDocument(mm3,mm9)) Then Exit;


 {
 Vid:=0;

 Vid:=SelectImport(1);
 If Vid=2 Then Exit;
 }

 Assign(Txt1,Path^.DAt.ToTemp+'calcbuch.txt');
 l:=IOResult;
 Rewrite(Txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path^.DAt.ToTemp+'calcbuch.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Close(Txt1);


 Assign(Txt2,Path^.DAt.ToTemp+'calcbuce.txt');
 l:=IOResult;
 Rewrite(Txt2);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path^.DAt.ToTemp+'calcbuce.txt',Nil,mfError+mfCancelButton);
   Close(Txt1);
   Exit;
  End;

R.Assign(0, 0, 0, 0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

AllItogo:=0;
AllSkidka:=0;
RabDAy:=0;




For Den:=Start To Stop Do
Begin
{ If DayOfWeek(Den)<>Sunday Then}
 Begin
 Date:=DateToDateString(DateMask,DEn);

 Assign(F,Path^.DAt.ToMarket+Date+'.mrk');
 l:=IOResult;
 Reset(f,SizeOf(SuperMarketType));
 l:=Ioresult;
 If L <> 0 Then
  Begin
   Writeln(txt2,'Не найден файл продаж за '+Date+'  "'+DayString[DayOfWeek(DAteStringToDate(DAteMask,Date))]+'"'+
   +' Код:'+IntToStr(L,3));
  End;

If l=0 Then
Begin
 Inc(RabDay);

DInfoMsgShkala('Просматриваю отгрузки '+Date+'...',Start,Stop,Den);

While Not (Eof(f)) Do
Begin
     New(E,Init);
     Count:=0;
     ReadBufMarket(F,E,Count);
For c:=1 To Count Do
Begin

  If (E^.Point.Dat[c].Active) Then
   If mm3[E^.Point.Dat[c].OperatorSelector+1]=1 Then
   If mm9[E^.Point.Dat[c].DocSelector+1]=1 Then

  If ((Not(E^.Point.Dat[c].Realiz)) Or ((E^.Point.Dat[c].Realiz)And
  (E^.Point.Dat[c].DocSelector in [5,6,7,8])))Then
   Begin
    AddMarketToMarketListWithZena(E^.Point.Dat[c]);
   End;
End;{for}
    Dispose(E,Done);
End;{While}
 Close(f);

 NoInfoMsg;
 End;{l=0}
 End;{Если не воскресенье}
End;{For Den}

 DInfoMsg('Формирую отчет...',True);
 {записать список в файл и вывести на экран}
 Append(txt1);
Writeln(txt1,Space+'Склад: '+FormKod(Rek^.DAt.Kod)++'  Оператор: '+CurrentPassword);

Writeln(txt1,Space+'   С П Р А В К А   О   СОВМЕЩЕННЫХ ПРОДАЖАХ  ЗА  период с '+StartDAte+' по '+StopDate);

Writeln(txt1,Space,RabDay:3,' рабочих дней');

Writeln(txt1,Space+
'------------------------------------'+
'----------------------------------------------------------------------------------------------------------------');
Writeln(txt1,Space+
' пп Наименование товара                                    Код  Ко-во Цена опл    Старт     Стоп Страна производ'+
'.Фирма-производитель  Серия  Сумма по оплате');
{123 12345678901234567890123456 12345678901234567890123456 12345 12345 12345678 12345678 12345678 123456789012345}
Writeln(txt1,Space+
'----------------------------------------------------------------------------------------------------------------'+
'------------------------------------');
AllItogo:=0;
  If TempBox^.List^.Count-1>=0 Then
  Begin
  For i:=0 To TempBox^.List^.Count-1 Do
   Begin
    s:=TempBox^.GetText(i,TempBox^.List^.Count);
    ws:=Copy(s,1+CFullName+1+CArtikul+1+CKol+1,CZena);
    SArt:=Copy(s,1+CFullName+1,CArtikul);
    SLastCod:=BakGetField(FNMakeKod,SArt,0);
    SLastPost:=GetMakeField(FMake,Copy(SLastCod,2,CClientKod),StrToInt(Copy(SLastCod,1,COne)));

    SNDS:=GetIdField(FNDS,SArt);
    {
    Seria:=BakGetField1(FAkzis,SArt,0);
    Format(Seria,CAll);}
    {memC(SArt+'-'+Seria);}
    ws1:=Copy(s,1+CFullName+1+CArtikul+1,CKol);
    Str(StrToReal(ws)*StrToInt(ws1):CIZena:CMantissa,ws2);
    AllItogo:=AllItogo+StrToReal(ws)*StrToInt(ws1);
    ws1:=Copy(s,1+CFullName+1,CArtikul);
     {
     ws:=Copy(s,1+1,CArtikul);
     ws:=GetIdField(FName,ws);
     Format(ws,CFullName);
     s:=ws+''+s;}
   While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert('$',s,k);
    End;
    Str(i+1:CLitrMantissa,ws);
    s:=ws+'$'+s;
    Write(txt1,Space+s+'$'+' '+ws2);
    WriteLN(txt1,'$'+SNDS+'$'+SLastPost);

(*        If Nprint^.DAt.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
                Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CFullName);
           Writeln(txt1,Space+' '+'  '+' '+ws2);
          End;
*)
   End;
  End;

Writeln(txt1,Space+
'----------------------------------------------------------------------------------------------------------------');
Writeln(txt1,Space,'                                                  Всего: ',RecognizReal(AllItogo,CIZena,CMantissa));

Close(txt2);
i:=IoResult;
Reset(txt2);
i:=IoResult;
If i=0 Then
Begin
If Not(Eof(txt2)) Then
 Begin
  Writeln(txt1);
  Writeln(txt1,'[Примечание]');
 End;
 While Not(Eof(txt2)) Do
 Begin
  Readln(txt2,s);
  Writeln(txt1,Space+s);
 End;
i:=IoResult;
 Close(txt2);
i:=IoResult;
End;



Writeln(txt1,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt1,Space+
'================================================================================================================');
 Close(txt1);

 Dispose(TempBox,Done);
NoInfoMsg;
ViewAsText(Path^.DAt.ToTemp+'calcbuch.txt','Справка о совмещенных продажах с '+StartDate+' по '+StopDate,True);
{Report(Path^.DAt.ToTemp+'calcbuch.txt','',NPrintC^.Dat.CopyAll,False,False);}

End;{CalcTch}






Procedure CalcSpecialOthset(Const Spis:PBox;Const M:Maska8;Const Assort,Sort:Word);
Var Regim,L : Word;
    txt,txt2 : Text;
    Separator : TDateString;
    Temp,wspomList,wspomList1,TempList : PBox;
    R,R1 : TRect;
    s,ws : String;
    StartStr , StopStr : TDateString;
    Start,Stop,Cut : LongInt;
    Space : TDAteString;
    c,Count : Word;
    Ef : File;
    E : PBufSkladType;
    ClNAme : AllStr;
    NumerGTD,Seria,FirmaPostawshik,Postawshik : AllStr;
    NaklNumer,NAklDAte,ClKod : TDAteString;


Procedure GetProperties(Kod:ArtikulStr);
VAr ls : Word;
    st : String;
Begin
For ls :=0 To WspomList1^.List^.Count Do
Begin
St:=WspomList1^.GetText(ls,WspomList1^.List^.Count);
ST:=Copy(St,2,CArtikul);
If St=Kod Then
   Begin
    St:=WspomList1^.GetText(ls,WspomList1^.List^.Count);
    NaklNumer:=Copy(st,2+CArtikul+1,CDAte);
    NAklDate:=Copy(st,2+CArtikul+1+CDAte+1,CDate);
    ClKod:=Copy(st,2+CArtikul+1+CDAte+1+CDate+1+CDocNumer+1+CDate+1,CClientKod);
    Postawshik:=Copy(st,2+CArtikul+1+CDAte+1+CDate+1+CDocNumer+1+CDate+1+CClientKod+1,CPost);
    FirmaPostawshik:=Copy(st,2+CArtikul+1+CDAte+1+CDate+1+CDocNumer+1+CDate+1+CClientKod+1+CPost+1,CFirmaPost);
    Seria:=Copy(st,2+CArtikul+1+CDAte+1+CDate+1+CDocNumer+1+CDate+1+CClientKod+1+CPost+1+CFirmaPost+1,CNSertif);
    NumerGTD :=Copy(st,2+CArtikul+1+CDAte+1+CDate+1+CDocNumer+1+CDate+1+CClientKod+1+CPost+1+CFirmaPost+1+CNSertif+1,CNSertif);
    WspomList1^.List^.AtFree(ls);
    WspomList1^.SetRange(WspomList1^.List^.Count);
    Break;
   End;
End;
End;


Begin
 StartStr:=FDate;
 StopStr:=FDate;
 If Not DatePeriodDialog(StartStr,StopStr,False) Then Exit;

 Separator:='$';
 Assign(Txt,Path^.Dat.ToTemp+'specbak.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'specbak.txt'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;

 Assign(Txt2,Path^.Dat.ToTemp+'specbake.txt');
 l:=IOResult;
 Rewrite(Txt2);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'specbake.txt'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;


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
      Close(Txt);
      Close(Txt2);
      Exit;
     End;

   Else;
   End;

 R.Assign(0,0,0,0);
 WspomList1 := New(PBox, Init(R, 1, Nil));
 WspomList1^.NewList(New(PTextCollection, Init(0,1)));


 CalcPrihod(StartStr,StopStr,wspomList1,txt2);

Space[0]:=#0;

Writeln(Txt,Space+'┌─────┬──────────────────────────┬─────┬───────────┬──────┬──────────┬───────────────┐');
Writeln(Txt,Space+'│Код  │Наименование товара       │Колич│N накл.пост│ Дата │Поставщик │N ГТД          │');
Writeln(Txt,Space+'└─────┴──────────────────────────┴─────┴───────────┴──────┴──────────┴───────────────┘');

                   {12345│12345678901234567890123456│12345│12345678│12345678│1234567890123456789012345678901234567890}



 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else
  s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);

  DInfoMsgShkala('Анализирую остатки товара. Раздел '+s+' ...',0,TempList^.List^.Count-1,L);


  Writeln(Txt,'Раздел: '+GetRazdel(s));


   Assign(Ef,Path^.Dat.ToSklad+s+'.db');
   c:=IOResult;
   Reset(Ef,SizeOf(SkladType));
   c:=IOResult;


      While Not(Eof(ef)) Do
      Begin

      New(E,Init);
      Count:=0;
      ReadBufSklad(ef,E,Count);
For c:=1 To Count Do
Begin

    If (E^.Point.Dat[c].Employ) Then
    Begin

      If ((E^.Point.Dat[c].Employ) And (StrToInt(E^.Point.Dat[c].Input.Kol)>0)And(Assort=0))Or
       ((E^.Point.Dat[c].Employ)And(Assort>0)And(((StrToInt(E^.Point.Dat[c].Input.Kol)>0))))Then
       Begin
        Ws:=GetIdField(FFFName,E^.Point.Dat[c].Bazkod);
        E^.Point.Dat[c].Input.Kol:=IntToStr(StrToInt(E^.Point.Dat[c].Input.Kol),CKol);
        RFormat(E^.Point.Dat[c].Input.Kol,CKol);
        s:=GetNGTDField(FNGTD,BakGetField1(FNGTD,E^.Point.Dat[c].Bazkod,0));
        DelSpaceRight(s);

        NaklNumer[0]:=#0;
        NaklDate[0]:=#0;
        Postawshik[0]:=#0;
        FirmaPostawshik[0]:=#0;
        ClKod[0]:=#0;
        Seria[0]:=#0;
        NumerGTD[0]:=#0;

        GetProperties(E^.Point.Dat[c].Bazkod);

        ClNAme:=GetMAkeField(FMake,ClKod,0);
        DelSpaceRight(ClName);

        Ws:=Space+E^.Point.Dat[c].BazKod+Separator+ws+Separator+E^.Point.Dat[c].Input.Kol+
        Separator+Postawshik{производитель}+Separator+FirmaPostawshik{фирмапроизводитель}+
        Separator+Seria{производитель}+
        Separator+{номер накладной}NaklNumer+Separator+NaklDate+Separator+ClName+Separator+s;

        Writeln(txt,Space+ws);
       End;
    End;
End;{For Count}
      Dispose(E,Done);
      End;{While}
        c:=IOResult;
      Close(Ef);
        c:=IOResult;

  End;{For по списку разделов}

NoInfoMsg;

Writeln(txt);
Close(txt2);
l:=IoResult;
Reset(txt2);
l:=IoResult;
If IOResult=0 Then
Begin
If Not(Eof(txt2)) Then
 Begin
  Writeln(txt);
  Writeln(txt,'[Примечание]');
 End;
 While Not(Eof(txt2)) Do
 Begin
  Readln(txt2,s);
  Writeln(txt,Space+s);
 End;
l:=IoResult;
 Close(txt2);
l:=IoResult;
End;

Space[0]:=#0;
Writeln(Txt);
Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt,Space+'===========================================================================================');

l:=IoResult;
 Close(txt);
l:=IoResult;

 Dispose(TempList,Done);
 Dispose(WspomList1,Done);


ViewAsText(Path^.Dat.ToTemp+'specbak.txt','Спец.отчет по приходам с '+StartStr+' по '+StopStr,True);



End;{Procedure}

Procedure Test_Sertif(Const Spis:PBox;Const M:Maska8;Const Assort,Sort:Word);
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
    E : PBufSkladType;
    Wk : String[CKol];
    Ef : File;
    Skidka : Boolean;
    TempList : PBox;
    WspomList: PBox;
    Regim : Word;
    Separator : ArtikulStr;
    {esbox : PBox;}
         MyWsopList : PBox;
    SInPack,MarketKol,MarketPack:string[CPack];
    PositionZena,Date : TDateString;
    VidPoiska,Diapason,EdIzm : Word;
    Protocol : Text;
    VidZaprosa:Word;
    Count,c : Word;


Begin
{ Assign(Protocol,'c:\temp.txt');
 Rewrite(Protocol);            }
 Separator:=' ';
 Assign(Txt,Path^.Dat.ToTemp+'dsertif.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'dsertif.txt'+
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



    VidZaprosa:=0;
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
  Space:=' ';
  Writeln(Txt,Header+Space+'Склад:'+FormKod(Rek^.Dat.Kod)+' Оператор:'+CurrentPassword+' EYE & 1999'+'('+Times+')');

  Writeln(Txt,Space+'Выбранные отделения:');
  Write(Txt,Space);
  For l:=1 To CDivision Do
  If M[l]=1 Then Write(txt,l:2,':',Rek^.Dat.Otdel[l],' ');
  Writeln(Txt);
Space:='      ';
If VidPoiska=1 Then
Writeln(Txt,Space+'        СЕРТИФИКАТЫ, СРОК ДЕЙСТВИЯ КОТОРЫХ ИСТЕКАЕТ В БЛИЖАЙШИЕ '+IntToStr(Diapason,3)+' дней ')
Else
Writeln(Txt,Space+'                               БАЗА СЕРТИФИКАТОВ');

writeln(txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]);
Writeln(txt,Space+'┌────┬────┬──────────────────────────┬─────┬────────────────────────────────────────┬─────────┬──────────'+
'────────────────────────────┐');
Writeln(txt,Space+'│Код │  N │Наименование товара       │Колич│Регистрационный и учетный               │Срок     │ Наименова'+
'ние органа,                 │');
Writeln(txt,Space+'│    │    │                          │  шт │N сертификата                           │действия │ выдающего'+
' сертификат                 │');
Writeln(txt,Space+'└────┴────┴──────────────────────────┴─────┴────────────────────────────────────────┴─────────┴──────────'+
'────────────────────────────┘'+HeaderStop);
Writeln(Txt);


 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);


  DInfoMsgShkala('Проверяю сроки действия сертификатов. Раздел '+s+' ...',0,TempList^.List^.Count-1,L);

{  If TestRazdel(s,M,0,0,2,0) Then}
If TestRazdel(s,M{отделения},Assort{0 ассортимент},2{0 разреш к продаже},2{маркиров и немарк},0{без учета брони},
False) Then

  Begin
      RazdelName:=GetRazdel(s);

      Assign(Ef,Path^.Dat.ToSklad+s+'.db');
      Reset(Ef,SizeOf(SkladType));

      R1.Assign(0, 0, 0, 0);
      MyWsopList := New(PBox, Init(R, 1, Nil));
      MyWsopList^.NewList(New(PTextCollection, Init(0,1)));
      While Not(Eof(ef)) Do
      Begin
       New(e,Init);
       cOunt:=0;
       ReadBufSklad(ef,E,Count);
For c:=1 To Count Do
Begin
       For i:=1 To CDivision Do
        If M[i]=1 Then
       Begin
        DelSpace(E^.Point.Dat[c].Input.Kol);

      If ((E^.Point.Dat[c].Employ) And (StrToInt(E^.Point.Dat[c].Input.Division[i])>0)And(Assort=0))Or
       ((E^.Point.Dat[c].Employ)And(Assort>0)And(((StrToInt(E^.Point.Dat[c].Input.Division[i])>0))Or(i<=1)))Then
         Begin

          If Nprint^.DAt.FullName=0 Then Ws:=GetIdField(FName,E^.Point.Dat[c].Bazkod)
          Else Ws:=GetIdField(FFName,E^.Point.Dat[c].Bazkod);
          Format(ws,CName);

          RFormat(E^.Point.Dat[c].Input.DiviSion[i],CKol);
          Str(i:2,S);

          Str(StrToInt(E^.Point.Dat[c].Input.Division[i]):CKol,E^.Point.Dat[c].Input.Division[i]);

          Ws:=Space+E^.Point.Dat[c].BazKod+SeparatorChar+Separator+s+SeparatorChar+Separator+ws+SeparatorChar+
                E^.Point.Dat[c].Input.Division[i]+SeparatorChar;
          ws1:=E^.Point.Dat[c].Input.NSertif;{@@@@@@@@}
          DelSpaceRight(ws1);
          ws1:=ws1+SeparatorChar+GetIdField(FName,E^.Point.Dat[c].Input.NSertif);
          Format(ws1,CNSertif);
          ws:=ws+ws1+SeparatorChar;


          ws1:=GetIdField(FDateSertif,E^.Point.Dat[c].Input.NSertif);
          DelSpaceRight(ws1);
          Format(ws1,CDSertif);
          ws:=ws+ws1+SeparatorChar;

          ws1:=GetKSertifField(FKSertif,GetIdField(FKtoSertif,E^.Point.Dat[c].Input.NSertif{E^.DAt.BazKod}));
          DelSpaceRight(ws1);
          Format(ws1,CKSertif);
          ws:=ws+ws1;


          If (VidPoiska=0) Or
                   (VidPoiska=1) And (DateStringToDate(DateMask,GetIdField(FDateSertif,E^.Point.Dat[c].Input.NSertif))<=
                                     (DateStringToDate(DateMask,FDate)+Diapason)) Then
         Begin
          If Sort>0 Then
           Begin
            P:=Copy(ws,Ord(Space[0])+1,CArtikul+2+2);
            Delete(ws,Ord(Space[0])+1,CArtikul+2+2);
            ws:=ws+SeparatorChar+P;
           End;
          {Writeln(txt,ws);}
          MyWsopList^.List^.Insert(NewStr(ws));
          MyWsopList^.SetRange(MyWsopList^.List^.Count);
         End;
         End;
       End;{ if m[i]=1}
End;
      Dispose(E,Done);
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
           Writeln(txt,Space+'      '+SeparatorChar+Separator+'  '+SeparatorChar+ws1);
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

Writeln(txt,Space+'======================================================================='+
'===============================================================');

 Close(txt);

 Dispose(TempList,Done);
 Dispose(LocalTempBox,Done);
 MyStr(ItogoR,CIZena,CMantissa,ws);
 NoInfoMsg;
 NoInfo;
 ViewAsText(Path^.Dat.ToTemp+'dsertif.txt','Отчет по срокам действия сертификатов',True);
{ If Not(TestOpenDate(FDate)) Then}
 {ReportNew(Path^.Dat.ToTemp+'dsertif.txt','',NPrintC^.Dat.CopyAll,False,False);}
End;

Function Test(E:SuperMarketType;Var txt:Text):Boolean;
 Var
 RealFile : File Of RealizasiaType;
 c : Word;
 GlobalEr : PRealizasiaType;
 L : Boolean;
 j : LongInt;
 BakFileMode : Word;
Begin
 Test:=False;
 BakFileMode:=FileMode;
 FileMode:=$42;
 Assign (RealFile,Path^.Dat.ToDolg+E.ClientKod+'.dlg');
 c:=IOResult;
 Reset(RealFile);
 c:=IOResult;
 FileMode:=BakFileMode;
 If c<>0 Then
  Begin
   MessageBox(#3'Ошибка доступа к файлу '+Path^.Dat.ToDolg+E.ClientKod+'.dlg',Nil,mfError+mfCancelButton);
   Exit;
  End;

  L:=False;
  New(GlobalEr,Init);

  j:=FileSize(RealFile)-1;
  While (j>=0) And Not(L) Do
   Begin
    Seek(RealFile,j);
    Read(RealFile,GloBalEr^.Dat);
    DelSpace(GlobalEr^.Dat.Market.Document);
    DelZerro(GlobalEr^.Dat.Market.Document);
    If (StrToInt(GlobalEr^.Dat.Market.Document)=StrToInt(E.DocReal)) And
       (GlobalEr^.Dat.Market.DateC=E.DocDate) And
       (GlobalEr^.Dat.Market.Active) Then L:=True;
    Dec(j);
   End;


  {
  While Not(Eof(RealFile)) And Not(l) Do
   Begin
    Read(RealFile,GlobalEr^.Dat);
    DelSpace(GlobalEr^.Dat.Market.Document);
    DelZerro(GlobalEr^.Dat.Market.Document);
    If (GlobalEr^.Dat.Market.Document=SDoc) And
       (GlobalEr^.Dat.Market.DateC=SDate) And
          (GlobalEr^.Dat.Market.Active) Then L:=True;
   End;
  }

  System.Close(RealFile);


 If Not(l) Then
  Begin
   Dispose(GlobalEr,Done);
   MessageBox(#3'Документ N '+E.DocReal+' за '+DateToDateString(DateMask,E.DocDate)+' в базе не найден!',Nil,
   mfError+mfCancelButton);
   Exit;
  End;

 If (Abs(StrToReal(E.SummaZ)-GlobalEr^.Dat.Market.SummaZ)>0.009)
  Or(Abs(StrToReal(E.Skidka)-GlobalEr^.Dat.Market.Skidka)>0.009) Then
  Begin
   {MemCC;}
   Test:=True;
   Writeln(txt,'В оформленной накладной к оплате:'+E.SummaZ+'('+RealToStr(GlobalEr^.Dat.Market.SummaZ,CIZena,CMAntissa)+')');
   Writeln(txt,'  В оформленной накладной скидка:'+E.Skidka+'('+RealToStr(GlobalEr^.Dat.Market.Skidka,CIZena,CMAntissa)+')');
  End;


End;



Function ViewAllNakl (Date: TDateString; Regim:Boolean;Debit:Boolean;Default:Byte):TMyString;
Const Sp='                     ';
Var f : File;
    E : PBufSuperMarketType;
    E1 : PSuperMarketType;
    l : Word;
    As : DocumentEditZ;
    NDS,z,AllSkidka,AllItogo,ItogoSkidka,Itogo,AllNalog,
    NDS20,NDS18,NDS16,NDS10,NDS_ : Float;
    s : TMyString;
    ws : String[CName];
    pp : String[CPack];
    Proz : String[CLitr];
    txt : Text;
    txt1 : Text;
    sh,Vid : Byte;
    Space: TDateString;
    Wiwod : Boolean;
    Doc : LongInt;
    fr : File Of RealizasiaType;
    Er : PRealizasiaType;
    Find : Boolean;
    Barter : String[CMantissa];
    c,Count: Word;
    MMM : Maska55;
    BakFileMode : Word;
Begin
 Space[0]:=#0;
 ViewAllNakl:='           0.00            0.00   0';
             { 123456789012345 123456789012345 123}
 Assign(F,Path^.Dat.ToMarket+Date+'.mrk');
 l:=IOResult;
 Reset(f,SizeOf(SuperMarketType));
 l:=Ioresult;
 If L <> 0 Then
  Begin
  If Regim Then
   MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToMarket+Date+'.mrk'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt1,Path^.Dat.ToTemp+'temp.txt');

 Assign(Txt,Path^.Dat.ToTemp+'nakladn.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path^.Dat.ToTemp+'nakladn.txt'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;
  Vid:=Default;
  If Regim Then
  Begin
  Vid:=SelectSpecify(Debit,5);
  If Vid=4 Then
   Begin
    CLose(f);
    Close(txt);
    Exit;
   End;


 AllItogo:=0;
 AllSkidka:=0;
 AllNalog:=0;
 Doc:=0;
If Regim Then  AInfo('Минуточку...');
While Not (Eof(f)) Do
Begin
     New(E,Init);
     Count:=0;
     ReadBufMArket(f,E,Count);
For c:=1 To Count Do
Begin
If   (Vid=3) Or
     (
      (
       (E^.Point.Dat[c].OperatorSelector=Vid) Or (Vid=3)
      )
       And (Not Debit) And (Not E^.Point.Dat[c].Realiz) And Not((E^.Point.Dat[c].ClientKod=ClientRP{'0000'})And
          (E^.Point.Dat[c].OperatorSelector=1))
       )

     Or (
         (Debit)And(E^.Point.Dat[c].Realiz)And Not((E^.Point.Dat[c].ClientKod={'0000'}ClientRP)And
            (E^.Point.Dat[c].OperatorSelector=1)) And
           (
            (Vid=2)or
                    (
                     (Vid=1)And(E^.Point.Dat[c].DocSelector in [5,6,7,8])
                    ) Or
                        (
                         (Vid in [0,2])And not(E^.Point.Dat[c].DocSelector in[5,6,7,8])
                        )
           )
        )
                                                    Then
Begin
Begin
 If (E^.Point.Dat[c].Active) Then
 Begin
{  If Not(Rp) Or (Rp and (E^.Point.Dat[c].OperatorSelector=0) And (E^.Point.Dat[c].ClientKod='0998')) Then}
   Begin

 SortNklStatic(E^.Point.Dat[c]);

 Writeln(Txt,'Склад: ',GetClientField(FClient,E^.Point.Dat[c].SkladKod,1){E^.Point.Dat[c].Sklad}+'  Оператор: '+
 E^.Point.Dat[c].Caption+
 ' Агент: '+E^.Point.Dat[c].AgentKod);
 If Not(E^.Point.Dat[c].DAteM=E^.Point.Dat[c].DAteC) Or Not(E^.Point.Dat[c].TimeM=E^.Point.Dat[c].TimeC) Then
 Writeln(txt,{'Последние изменения:'+}' '+E^.Point.Dat[c].DAteM+'('+E^.Point.Dat[c].TimeM+')');
 ItogoSkidka:=0;   Itogo:=0; NDS:=0;
 Inc(Doc);

 Rewrite(Txt1);
 As.D:=Date;
 As.EditPosition:=E^.Point.Dat[c].Document;

 New(E1,Init);
 E1^.Dat:=E^.Point.Dat[c];

 FormSf(True, E1, Txt1, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16,False,'');
 Close(Txt1);
{If E^.Point.Dat[c].DocSelector=5 Then
   If TestSf(E^.Point.Dat[c].ClientKod,E^.Point.Dat[c].Document,E^.Point.Dat[c].DateC) Then Inc(E^.Point.Dat[c].DocSelector);}
 Writeln(txt,'Тип документа:(',LeadingZero(E^.Point.Dat[c].DocSelector),')');

If (E^.Point.Dat[c].Realiz) And Not(E^.Point.Dat[c].DocSelector in[5,6,7,8]) Then
Begin
{
If Regim Then
If Test (E^.Point.Dat[c],txt) Then Writeln(txt,'Внимание! обнаружена ошибка');
}
Writeln(Txt,'ПО НАКЛАДНОЙ КОНСИГНАЦИИ: '+E^.Point.Dat[c].DocReal+ ' от  '+
DateToDateString(DateMask,E^.Point.Dat[c].DocDate));
End;

If E^.Point.Dat[c].OperatorSelector<2 then barter[0]:=#0
else barter:='-Б';


 WriteLn(Txt,'Экспедитор: '+GetEkspedField(FAgent,E^.Point.Dat[c].EkspeditorKod));


TestDocumentsList(True,E^.Point.Dat[c].ClientKod,MMM,E^.Point.Dat[c],E^.Point.Dat[c].OperatorSelector);


Case E^.Point.Dat[c].DocSelector Of
0:begin
   If E^.Point.Dat[c].OperatorSelector=0 Then
   Writeln(Txt,'                     С П И С О К   N '+E^.Point.Dat[c].Document+Barter+ ' от ',E^.Point.Dat[c].DAteC+' ('+
   E^.Point.Dat[c].TimeC+')')
   Else
   Writeln(Txt,'       Н А К Л А Д Н А Я (межскладская перевозка)  N '+E^.Point.Dat[c].Document+Barter+ ' от ',
   E^.Point.Dat[c].DAteC+' ('+
   E^.Point.Dat[c].TimeC+')');
   If E^.Point.Dat[c].OperatorSelector=1 Then
   Writeln(Txt,Space+'Получатель: ',GetClientField(FClient,E^.Point.Dat[c].ClientKod,E^.Point.Dat[c].OperatorSelector)+
   ' ('+E^.Point.Dat[c].ClientKod+')')
   Else
   Writeln(Txt,Space+'Получатель: ',{GetClient(E^.Point.Dat[c].ClientKod)+}' ('+E^.Point.Dat[c].ClientKod+')');
   As.EditPosition:=E^.Point.Dat[c].Document;
   As.D:=E^.Point.Dat[c].DAteC;
   FormNakl(Space,True,As, E1, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16,false,False,False,0,MMM);
   AllItogo:=AllItogo+Itogo;
   AllSkidka:=AllSkidka+ItogoSkidka;
  end;{список}
1:begin
    Writeln(txt,'                      Т О В А Р Н Ы Й  Ч Е К   N '+E^.Point.Dat[c].Document+BArter+' от ',
    E^.Point.Dat[c].DAteC+
    ' ('+E^.Point.Dat[c].TimeC+')');
    Writeln(Txt,'Получатель: ',GetClientField(FClient,E^.Point.Dat[c].ClientKod,E^.Point.Dat[c].OperatorSelector)+' ('+
    E^.Point.Dat[c].ClientKod+')');
    As.EditPosition:=E^.Point.Dat[c].Document;
    As.D:=E^.Point.Dat[c].DAteC;
    FormNakl(Space,True,As, E1, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16,False,False,False,0,MMM);
    AllItogo:=AllItogo+Itogo;
    AllSkidka:=AllSkidka+ItogoSkidka;
  end;{товарный чек}
2:begin
    Writeln(Txt,'                        Н А К Л А Д Н А Я   N '+E^.Point.Dat[c].Document+Barter+' от ',E^.Point.Dat[c].DAteC+
    ' ('+E^.Point.Dat[c].TimeC+')');
    Writeln(Txt,'Получатель: ',GetClientField(FClient,E^.Point.Dat[c].ClientKod,E^.Point.Dat[c].OperatorSelector)+' ('+
    E^.Point.Dat[c].ClientKod+')');
    As.EditPosition:=E^.Point.Dat[c].Document;
    As.D:=E^.Point.Dat[c].DAteC;
    FormNakl(Space,True,As, E1, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16,False,False,False,0,MMM);
    AllItogo:=AllItogo+Itogo;
    AllSkidka:=AllSkidka+ItogoSkidka;
  end;{накладная с приходником}
3,4:
   begin
    If E^.Point.Dat[c].DocSelector=4 Then
    Begin
     Writeln(txt,'Платежное поручение N: '+E^.Point.Dat[c].Bn.NPlat+' от '+E^.Point.Dat[c].Bn.Date);
     Writeln(txt,'Банк: '+GetBankField(FBank,E^.Point.Dat[c].Bn.BAnkKod)+' ('+E^.Point.Dat[c].Bn.BAnkKod+')');
    End;
    Writeln(Txt,'                        Н А К Л А Д Н А Я   N '+E^.Point.Dat[c].Document+Barter+' от ',E^.Point.Dat[c].DAteC+
    ' ('+E^.Point.Dat[c].TimeC+')');
    Writeln(Txt,'Получатель: ',GetClientField(FClient,E^.Point.Dat[c].ClientKod,E^.Point.Dat[c].OperatorSelector)+' ('+
    E^.Point.Dat[c].ClientKod+')');
    As.EditPosition:=E^.Point.Dat[c].Document;
    As.D:=E^.Point.Dat[c].DAteC;
    FormNakl(Space,True,As, E1, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16,False,False,False,0,MMM);
    AllItogo:=AllItogo+Itogo;
    AllSkidka:=AllSkidka+ItogoSkidka;
   end;{с/ф накладная и приходник}
5,6,7,8:
   begin
Writeln(Txt,'           Н А К Л А Д Н А Я  на  консигнацию  N '+E^.Point.Dat[c].Document+Barter+' от ',E^.Point.Dat[c].DAteC+
' ('+E^.Point.Dat[c].TimeC+')');
Wiwod:=False;
 BakFileMode:=FileMode;
 FileMode:=$42;
Assign(fr,Path^.Dat.ToDolg+E^.Point.Dat[c].ClientKod+'.dlg');
sh:=IOResult;
Reset(fr);
sh:=IOResult;
 FileMode:=BakFileMode;
If Sh=0 Then
Begin
  New(Er,Init);
  Find:=False;
  DelSpace(E^.Point.Dat[c].Document);
   While Not(Eof(fr)) And Not(Find) Do
     Begin
      Read(fr,Er^.Dat);
      DelSpace(Er^.Dat.Market.Document);
      If (Er^.Dat.Market.Document=E^.Point.Dat[c].Document)
         And(DateToDateString(DateMask,Er^.Dat.Market.DAteC)=E^.Point.Dat[c].DateC)
      And(Er^.Dat.Market.Active) Then Find:=True;
     End;
  Close(Fr);
  If Not(Find) Then
   Begin
    MessageBox(^m+#3'Документ не найден в долгах клиента!',Nil,mfError+mfCancelButton)
   End
    Else
   Begin
    For sh:=1 To 4 Do
      Begin
        If Er^.DAt.Doc[sh].Employ Then
          Begin
            Wiwod:=True;
            Break;
          End;
      End;
    If Wiwod Then
      Begin
        Writeln(Txt,Sp+'┌───────────────────────────────┐');
        Writeln(txt,Sp+'│ По данной накладной выведены: │');
        For sh:=1 To 4 Do
          Begin
            If Er^.DAt.Doc[sh].Employ Then
               Begin
                 s:='│      '+Er^.DAt.Doc[sh].DocReal+' от '+DateToDateString(DateMask,Er^.DAt.Doc[sh].DocDAte);
                 Format(s,31);
                 s:=s+' │';
                 Writeln(txt,Sp+s);
               End;
          End;
        Writeln(Txt,Sp+'└───────────────────────────────┘');
      End;
   End;
  Dispose(Er,Done);
End;

    If E^.Point.Dat[c].DocSelector in [6,8] Then
      Begin
        Writeln(txt);
        Writeln(Txt,'            ВНИМАНИЕ! ПО НАКЛАДНОЙ КОНСИГНАЦИИ КЛИЕНТУ ВЫДАН СЧЕТ-ФАКТУРА');
        Writeln(txt);
      End;

Writeln(Txt,'Выдано на консигнацию: ',
GetClientField(FClient,E^.Point.Dat[c].ClientKod,E^.Point.Dat[c].OperatorSelector)+' ('+E^.Point.Dat[c].ClientKod+')');
    Writeln(Txt,'Срок консигнации до: '+DateToDateString(DateMask,E^.Point.Dat[c].Srok));
    As.EditPosition:=E^.Point.Dat[c].Document;
    As.D:=E^.Point.Dat[c].DAteC;
    FormNakl(Space,True,As, E1, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,NDS18,NDS16,False,False,False,0,MMM);
    AllItogo:=AllItogo+Itogo;
    AllSkidka:=AllSkidka+ItogoSkidka;
   end;{с/ф накладная и приходник}
Else;
End;{Case}

 Dispose(E1,Done);
End;

End;
End;
End;

End;
 Dispose(E,Done);

End;{For}
End;{While}
Close(f);
Writeln(txt);
Writeln(Txt,'    Всего за день скидка: ',RecognizReal(AllSkidka,CIZena,CMantissa),' руб.');
Writeln(Txt,'    Всего за день  сумма: ',RecognizReal(AllItogo,CIZena,CMantissa),' руб.');
Writeln(Txt,'        Всего за день НП: ',RecognizReal(AllNAlog,CIZena,CMantissa),' руб.');
Str(Doc:CLitrMAntissa,ws);
Writeln(Txt,'Всего за день документов: ',Ws);

Close(txt);
If Regim Then NoInfo;
ERase(Txt1);
If Regim Then ViewAsText(Path^.Dat.ToTemp+'nakladn.txt','Просмотр документов отгрузки за '+Date,False);

{ViewAsText('c:\newskl\1.txt',True); отладка просмотра фала большого размера}

MyStr(AllItogo,CIZena,CMantissa,ws);
s:=ws;
MyStr(AllSkidka,CIZena,CMantissa,ws);
s:=s+' '+ws;
Str(Doc:CLitrMAntissa,ws);
s:=s+' '+ws;
ViewAllNakl:=s;
{ViewAllNakl:=RecognizReal(AllItogo,CIZena,CMantissa)+';'+RecognizReal(AllSkidka,CIZena,CMantissa)+'│'+s;}
End;




Function CalcDolgOtkat(Regim:Boolean):TMyString;
Var R : TRect;
    r1: Float;
    w,Space : AllStr;
    ClientList :PBox;
    st : String;
    ClientFile : File;
    ClientElement : PBufKurzClientType;
    RealFile : File;
    E  : PBufRealizasiaType;
    c,cc,ii,Count : Word;
    ws : TMyString;
    f : Text;
    t1,t2 : LongInt;
    ss,Separator : AllStr;
    BakFileMode:Word;

begin
CalcDolgOtkat:='           0.00';
{123456789012345 123456789012345 123456789012345 123456789012345}
Space:='';
If Regim Then
Begin
Assign(f,Path^.Dat.ToTemp+'dolgo.txt');
c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0) And (Regim) Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'dolgo.txt!!'+
  +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
  Exit;
 End;
End;

R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));

{If Regim Then AInfo('Рассчитываю долги клиентов...');}

   BakFileMode:=FileMode;
   FileMode:={ReadOnlyN}$42;
Assign (ClientFile,Path^.Dat.ToClientBaseIndex+'Client.idx');
c:=IOResult;
Reset (ClientFile,SizeOf(KurzClientType));
c:=IOResult;
   FileMode:=BakFileMode;
If c=0 Then
Begin

While Not(Eof(ClientFile)) Do
{For ccc:=1 To 500 Do}
 Begin
If Regim Then DInfoMsgShkala('Читаю списки консигнаторов. Ждите... ',0,FileSize(CLientFile),FilePos(CLientFile));
     New(ClientElement,Init);
     Count:=0;
     ReadBufKurzClient(ClientFile,ClientElement,Count);

For c:=1 To Count Do
Begin
  If ClientElement^.Point.Dat[c].Employ Then
   Begin
    Begin
     ss:=IntToStr(ClientElement^.Point.Dat[c].Kod,CClientKod);
     RFormatZerro(SS,CClientKod);
     Format(ClientElement^.Point.Dat[c].Name,CClient);
     ClientList^.List^.Insert(NewStr(ClientElement^.Point.Dat[c].Name+'│'+ss));
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
  Dispose(ClientList,Done);
  MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов',Nil,mfError+mfCancelButton);
  Exit;
 End;

If Regim Then NoInfoMsg;

r1:=0;


If Regim Then
Begin
 Writeln(f,Space+Header+'             СПРАВКА ПО БОНУСАМ КОНСИГНАТОРОВ'+'  '+FDate+' ('+Times+')');
 Writeln(f,Space+'┌───────────────────┬────┬──────────┬────────┬─────┬────┬─────────────────┬──────────────┬───┐');
 Writeln(f,Space+'│      Клиент       │Код │Дата Пок  │Дата Взв│Delta│Nдок│   Остаток бонуса│ Р долг по опл│Вид│');
 Writeln(f,Space+'└───────────────────┴────┴──────────┴────────┴─────┴────┴─────────────────┴──────────────┴───┘'+HeaderStop);

End;

Separator:=SeparatorChar;

If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    if regim then DInfoMsgShkala('Рассчитываю остаток бонусов клиентов. Ждите... ',0,ClientList^.List^.Count-1,c);
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
   BakFileMode:=FileMode;
   FileMode:={ReadOnlyN}$42;
    Assign(RealFile,Path^.Dat.ToDolg+st+'.dlg');
    ii:=IOResult;
    Reset(RealFile,SizeOf(RealizasiaType));
    ii:=IOResult;
   FileMode:=BakFileMode;
    If ii=0 Then
     Begin
      While Not(Eof(RealFile)) Do
       Begin
        New(E,Init);
        Count:=0;
        BlockRead(RealFile,E^.Point,BufferDLG,Count);

For cc:=1 To Count Do
Begin

If (E^.Point.Dat[cc].Market.Active) And Not(E^.Point.Dat[cc].FullOtkat) Then
If Abs(E^.Point.Dat[cc].Otkat)>=0.009 Then
 Begin
   If Regim Then
   begin
          t2:=DateStringToDate(DAteMask,FDate);
          t1:=E^.Point.Dat[cc].MArket.Srok;
          Str((t2-t1):5,w);
          ws:=GetClientField(FClient,St,0);
          Format(ws,CClient);
          DelSpace(E^.Point.Dat[cc].MArket.Document);
          RFormat(E^.Point.Dat[cc].MArket.Document,CDocnumer);
          ws:=ws+Separator+St+Separator+
                DateToDateString(DateMask,E^.Point.Dat[cc].Market.DateC)+' '+Separator+
          DateToDateString(DAteMask,E^.Point.Dat[cc].Market.Srok)+' '+
          +Separator+w+
          +Separator+' '+E^.Point.Dat[cc].Market.Document+Separator+' ';
          MyStr(E^.Point.Dat[cc].Otkat,CIZena,CMantissa,w);
          ws:=ws+w+Separator;
          MyStr(E^.Point.Dat[cc].Dolg,CIZena,CMantissa,w);
          ws:=ws+w+Separator;
                         If E^.Point.Dat[cc].MArket.DocSelector in [6] Then
                          Begin
                 If E^.Point.Dat[cc].Market.Rashet=2 Then ws:=ws+'Вкс'
                 Else    ws:=ws+'СФ';
                          End;

                         If E^.Point.Dat[cc].MArket.DocSelector in [8] Then
                          Begin
                 If E^.Point.Dat[cc].Market.Rashet=2 Then
                                  ws:=ws+'Вкс'
                 Else
                          ws:=ws+'СФБ';
                          End;
         Writeln(f,Space+ws);
         Writeln(f,Space+'──────────────────────────────────────────────────────────────────────────────────────────────');
   End;

        r1:=r1+E^.Point.Dat[cc].Otkat;
 End;
End;{For}
                Dispose(E,Done);
End;{Eof}
      Close(RealFile);
     End;{Ioresult=0}
   End;{For по листу}
 End;{если список не пустой}

If Regim Then
Begin
Writeln(f,Space+'                                      Реальный долг по бонусам:'+RecognizReal(R1,CIZena,CMantissa));
Writeln(f);
Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'==============================================================================================');
c:=IOResult;
Close(f);
c:=IOResult;
End;


Dispose(ClientList,Done);

If Regim Then NoInfoMsg;

MyStr(R1,CIZena,CMantissa,st);
CalcDolgOtkat:=st;

If Regim Then
Begin
NoInfoMsg;
ViewAsText(Path^.Dat.ToTemp+'dolgo.txt','Справка по бонусам консигнаторов',True);
End


end;




Function ViewOplOtkat(Dates:TDateString;Regim : Boolean;Var VidanoOtkatToDAy:AllStr):AllStr;
Const Space =' ';
      Space1='  ';
Var     f : File;
      Opl : PBufOplataRealizasiaType;
      PromItog,ItogoOZ : Real;
      Txt : Text;
      l,i : Byte;
      S   : String;
      st  : AllStr;
      Vid : Word;
      StartDate,StopDAte:TDateString;
      Cur,Start,Stop : LongInt;
      c,Count,c1 : Word;

Begin
 ViewOplOtkat:='           0.00';
 VidanoOtkatToDAy[0]:=#0;
{               123456789012345}
 If Regim Then
 Begin
 StopDate:=FDate;
 StartDate:=FDate;
 if StrToInt(CurrentPassword)=0 Then DateToDateString(DateMask,DAteStringToDate(DateMask,StopDate)-30);
 If Not(DatePeriodDialog(StartDate,StopDate,False)) Then Exit;
 End
 Else
   Begin
    Dates:=FDate;
    StartDAte:=FDAte;
    StopDAte:=FDate;
   End;


 Assign(Txt,Path^.Dat.ToTemp+'otkat.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'otkat.txt'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;


ItogoOZ:=0;

If Regim Then   DInfo('Минуточку...');
  Writeln(Txt,Space+Header+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+' Оператор:'+CurrentPassword);



 Writeln(Txt,Space+'   С П Р А В К А   П О   О П Л А Т Е    Б О Н У С О В   с  '+StartDate+'  по  '+StopDate);
 Writeln(Txt,Space+'┌────────────────────┬────┬────┬────────┬────────────────┬─────────┬────────┬────────────┬──┐');
 Writeln(Txt,Space+'│Клиент              │Код │Док │Дата Док│    Сумма оплаты│ Дата опл│Время оп│    Оператор│Д │');
 Writeln(Txt,Space+'└────────────────────┴────┴────┴────────┴────────────────┴─────────┴────────┴────────────┴──┘'+HeaderStop);

                    {12345678901234567890 1234 1234 12345678  123456789012345  12345678 12345678 123456789012}

Start:=DateStringToDate(DateMask,StartDate);
Stop :=DateStringToDate(DateMask,StopDate);

For Cur:=Start To Stop Do
Begin
 DAtes:=DateToDateString(DateMask,Cur);

 If Regim  Then DInfoMsgShkala('Просматриваю оплаты бонусов за '+Dates+' ...',Start,Stop,Cur);

 Assign(F,Path^.Dat.ToOplata+Dates+'.otp');
 l:=IOResult;
 Reset(f,SizeOf(OplataRealizasiaType));
 l:=Ioresult;
 If L=0 Then
 Begin
  PromItog:=0.0;
  While Not Eof(f) Do
  Begin
   New(Opl,Init);
   ReadBufOplata(F,Opl,Count);
For c1:=1 To Count Do
Begin

   s:=GetClientField(FClient,Opl^.Point.Dat[c1].ClientKod,0);
   Format(s,CClient);
   s:=s+SeparatorChar+Opl^.Point.Dat[c1].CLientKod;
   DelSpace(Opl^.Point.Dat[c1].Document);
   Format(Opl^.Point.Dat[c1].Document,CDocNumer);
   DelSpace(Opl^.Point.Dat[c1].SummaZ);


   ItogoOZ:=ItogoOZ+StrToReal(Opl^.Point.Dat[c1].SummaZ);
   PromItog:=PromItog+StrToReal(Opl^.Point.Dat[c1].SummaZ);

   RFormat(Opl^.Point.Dat[c1].SummaZ,CIZena);
   st:=GetOperatorField(FNAme,Opl^.Point.Dat[c1].Caption);
   Format(St,CKto);
   s:=s+SeparatorChar+Opl^.Point.Dat[c1].Document+SeparatorChar+
   Opl^.Point.Dat[c1].DateDoc+SeparatorChar+' ';

   s:=s+Opl^.Point.Dat[c1].SummaZ+SeparatorChar+' '+Opl^.Point.Dat[c1].DateC+
   SeparatorChar+Opl^.Point.Dat[c1].TimeC+SeparatorChar+St;

   Writeln(txt,Space1+s);

   {вычисляем оплату бонусов по накладным текущего дня}
   If Opl^.Point.Dat[c1].DateC=Opl^.Point.Dat[c1].DateDoc Then
    Begin
     MyStr(StrToReal(VidanoOtkatToDAy)+StrToReal(Opl^.Point.Dat[c1].SummaZ),CIZena,CMAntissa,VidanoOtkatToDAy);
    End;

End;{For}
    Dispose(Opl,Done)
  End;{while}
 l:=Ioresult;
  Close(f);
 l:=Ioresult;
  If Start<>Stop Then
  Begin
   Writeln(Txt,Space+'───────────────────────────────────────────────────────────────────────────────────────────');
   Writeln(txt,Space+' Всего оплата бонусов за '+Dates+' составила: ',RecognizReal(PromItog,CIZena,CMantissa),' руб.');
   Writeln(txt);
  End;
  End{IOResult=0}
  Else
   Begin

   End;
End;{For}
   Writeln(Txt,Space+'───────────────────────────────────────────────────────────────────────────────────────────');
   Writeln(txt,Space+'         Всего оплата бонусов составила: ',RecognizReal(ItogoOZ,CIZena,CMantissa),' руб.');
   Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
   Writeln(Txt,Space+'===========================================================================================');

 l:=Ioresult;
Close(Txt);
 l:=Ioresult;

If Regim Then NoInfoMsg;

If Regim Then NoInfo;

If Regim Then ViewAsText(Path^.Dat.ToTemp+'otkat.txt','Справка по оплате бонусов с '+
StartDate+' по '+StopDate,True);
{If Regim Then Report(Path^.Dat.ToTemp+'otkat.txt','',NPrintC^.Dat.CopyAll,False,False);}

 MyStr(ItogoOZ,CIZena,CMantissa,st);
ViewOplOtkat:=st;
End;



Function ViewAllNAklSertif (Date: TDateString):TMyString;
Var f : File;
    E1 : PSuperMarketType;
    E  : PBufSuperMarketType;
    l : Word;
    As : DocumentEditZ;
    NDS,z,AllSkidka,AllItogo,ItogoSkidka,Itogo,
    NDS20,NDS10,NDS_ : Float;
    s : TMyString;
    ws : String[CName];
    pp : String[CPack];
    Proz : String[CLitr];
    txt : Text;
    sh,Vid : Byte;
    Space: TDateString;
    Wiwod : Boolean;
    Doc : LongInt;
    ShowRegim:Word;
    Count, c : Word;
Begin
{$IFDEF DPMI}
 Space[0]:=#0;
 {123456789012345 123456789012345 123}
 Assign(F,Path^.Dat.ToMarket+Date+'.mrk');
 l:=IOResult;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(f,SizeOf(SuperMarketType));
 FileMode:=OldFileMode;
 l:=Ioresult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Assign(Txt,Path^.Dat.ToTemp+'nakls.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'nakls.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

  Vid:=3;
  Vid:=SelectSpecify(False,5);
  If Vid=4 Then
   Begin
    CLose(f);
    Close(txt);
    Exit;
   End;

 AllItogo:=0;
 AllSkidka:=0;
 Doc:=0;
DInfo('Минуточку...');
While Not (Eof(f)) Do
Begin
  New(E,Init);
  Count:=0;
  ReadBufMArket(f,E,Count);
For c:=1 To Count Do
Begin
If ((E^.Point.Dat[c].OperatorSelector=Vid) Or (Vid=3)) And Not(E^.Point.Dat[c].ClientKod=ClientRP)
   And (E^.Point.Dat[c].AmountS>0) Then
Begin
 If (E^.Point.Dat[c].Active) Then
 Begin
    ItogoSkidka:=0;   Itogo:=0; NDS:=0;
    NDS20:=0;NDS10:=0;NDS_:=0;
    Inc(Doc);
    As.EditPosition:=E^.Point.Dat[c].Document;
    As.D:=E^.Point.Dat[c].DAteC;
    New(E1,Init);
    E1^.Dat:=E^.Point.Dat[c];
    FormNaklSertif(Space,True,As, E1, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,false,FAlse);
    Dispose(E1,Done);
    AllItogo:=AllItogo+Itogo;
    AllSkidka:=AllSkidka+ItogoSkidka;
 End;{Active}
End;{ClientKod}
End;{For}
 Dispose(E,Done);
End;{While}
Close(f);
Writeln(Txt,'Всего за день скидка: ',RecognizReal(AllSkidka,CIZena,CMantissa),' руб.');
Writeln(Txt,'Всего за день  сумма: ',RecognizReal(AllItogo,CIZena,CMantissa),' руб.');
Str(Doc:CLitrMAntissa,ws);
Writeln(Txt,'Всего за день документов: ',Ws);

Close(txt);
NoInfo;
ViewAsText(Path^.Dat.ToTemp+'nakls.txt','Просмотр документов отгрузки сертификатов за '+Date,False);
{$ENDIF}
End;








End.{Unit}