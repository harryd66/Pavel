{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit Vision7;

Interface

Uses Glob,ServStr,Dialogs,Utils,Vision1;

Procedure FormNaklTTN(Space :TDateString; Video : Boolean;As :DocumentEdit;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Real;
                   ShowAnswer,Commisia:Boolean);

Procedure PrintPersonal;
Procedure CalcBuchPrihod;
Procedure CalcBuchMarket;
Procedure CalcBuchMarket1;

Procedure CalcDolgDebitDate;

Implementation


Uses DBEngine,MsgBox,Views,Propiss,TpDate,Tools,Serv,Printers,UtilsP,
     NetDBEng,Objects,Prise,Vision5,Net,Access;




VAr LocalTempBox,TempBox : PBox;

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
   Tip : Word;
   Ext : TDateString;
   Regim,OldFileMode : Word;

begin
SDAte:=FDAte;

If Not(DateDialog(SDAte)) Then Exit;

Regim:=1;
{Regim:=SelectImport(37);}

If Regim=2 Then Exit;


Ext:=IntToStr(STrToInt(Rek.Kod),CMantissa);
RFormatZerro(Ext,CMantissa);


If Not FExists(Path.ToArchiv+SDAte+'.d'+Ext) Then
 Begin
  MessageBox(#3'Не найден файл '+Path.ToArchiv+SDAte+'.d'+Ext,Nil,mfError+mfCAncelButton);
  Exit;
 End;


Tip:=SelectSpecify(False,16);
If Tip=3 Then Exit;

Assign(f,Path.ToTemp+'dolgd.txt');
c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0) Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path.ToTemp+'dolgd.txt!'+
  +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));


Assign (ClientFile,Path.ToClient+'Client.db');
c:=IOResult;
OldFileMode:=FileMode;
{FileMode:=ReadOnlyN;}
Reset (ClientFile,SizeOf(ClientType));
c:=IOResult;
FileMode:=OldFileMode;
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
     {RFormatZerro(ClientElement^.Point.Dat[c].BuchKod,CClientKod);}
     RFormatZerro(ClientElement^.Point.Dat[c].Kod,CClientKod);

     ClientList^.List^.Insert(NewStr(ClientElement^.Point.Dat[c].FullName+'│'+
     ClientElement^.Point.Dat[c].Kod+'│'+
     ClientElement^.Point.Dat[c].Kod+'│'+
     IntToStr({ClientElement^.Point.Dat[c].Main}1,COne)+'│'+
  '           0.00'));
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
Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword);
Writeln(f,Space+' СПРАВКА ПО ДОЛГАМ КОНСИГНАТОРОВ по состоянию на '+' '+SDate);
Write(f,Space+' Вид отбора: ');
Case Tip Of
0:Write(f,'Со С/Ф');
1:Write(f,'Без С/Ф');
2:Write(f,'Все');
Else;
End;
Writeln(f);
Write(f,Space+' Группировка: ');
Case Regim Of
0:   Write(f,'Код 1С');
Else Write(f,'Стандартная');
End;
Writeln(f);
Writeln(f,Space+'┌────┬─────────────────────────────────────────────┬────┬───────────────┐');
Writeln(f,Space+'│ п/п│ Клиент                                      │Код │ Долг по оплате│');
Writeln(f,Space+'└────┴─────────────────────────────────────────────┴────┴───────────────┘');

                 {1234│123456789012345678901234567890123456789012345│1234│1234│123456789012345│}


{расставляем долги в списке}
Assign(fdolg,Path.ToArchiv+SDAte+'.d'+Ext);
c:=IOResult;
OldFileMode:=FileMode;
{FileMode:=ReadOnlyN;}
Reset(fDolg);
c:=IOResult;
FileMode:=OldFileMode;
AllDolg:=0;
While Not(Eof(fdolg)) Do
 Begin
  DInfoMsgShkala('Рассчитываю долги клиентов. Ждите... ',0,FileSize(FDolg),FilePos(FDolg));
  Read(FDolg,FD);
  RFormatZerro(FD.Kod,CClientKod);
  MyStr(FD.Dolg,CIZena,CMantissa,St);
  If FD.Dolg>0.009 Then
  Begin
  Case Tip Of
  0:Begin
     AllDolg:=AllDolg+FD.DolgSF;{СФ}
     FD.Dolg:=FD.DolgSF;
    End;
  1:Begin
     AllDolg:=AllDolg+(FD.Dolg-FD.DolgSF);{без СФ}
     FD.Dolg:=FD.Dolg-FD.DolgSF;
    End;
  2:Begin
     AllDolg:=AllDolg+FD.Dolg;{ВСЕ}
     FD.Dolg:=FD.Dolg;
    End;
  Else;
  End;

  {AllDolg:=AllDolg+FD.Dolg;}

  {If Regim=0 Then
  c:=SpecialLocation(ClientList,GetFantomKod(ClientList,FD.Kod))
  Else }
  c:=Location(ClientList,FD.Kod+'│',False);

  s:=ClientList^.GetText(c,ClientList^.List^.Count);

  s1:=Copy(s,1+CAll+1+CClientKod+1+CClientKod+1+COne+1,CIZena);
  System.Delete(s,1+CAll+1+CClientKod+1+CClientKod+1+COne+1,CIZena);
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
    If (StrToReal(Copy(s,1+CAll+1+CClientKod+1+CClientKod+1+COne+1,CIZena))>0.009) Then
    Begin
     St:= IntToStr(Count,4);
     Inc(Count);
     RFormat(st,4);
     System.Delete(s,1+CAll+1+CClientKod+1+CClientKod,1+COne);
     System.Delete(s,1+CAll+1+CClientKod,1+CClientKod);

        While Pos('│',s)>0 Do
         Begin
          k:=Pos('│',s);
          System.Delete(s,k,1);
          System.Insert(' ' ,s,k);
         End;

     Writeln(f,Space+' '+st+{SeparatorChar}' '+s+' ');
    End;
   End;
 End;
Writeln(f,Space+'─────────────────────────────────────────────────────────────────────────');
Dispose(ClientList,Done);
Writeln(f,Space+' '+'                           Всего долг по оплате:'+
RecognizReal(AllDolg,CIZena,CMantissa));
Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'===========================================');
c:=IOResult;
Close(f);
c:=IOResult;

NoInfoMsg;
ViewAsText(Path.ToTemp+'dolgd.txt',True);
{ReportNew(Path^.Dat.ToTemp+'dolgd.txt','',NPrintC^.Dat.CopyAll,False,False);}
end;


(*
Procedure FormNaklTTN(Space :TDateString; Video : Boolean;As :DocumentEdit;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Real;
                   ShowAnswer,Commisia:Boolean);
Var l : Word;
    Ver,s,sc,ws,ws1,ws2,ws3 : string[150];
    Ss,ss1 : string[150];
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
    EdIzm: STring[5];
    Z,Zen,Sum:String[CIZena];
    Postawshik,GruzoOtpravitel,
    Gruzopolushatel,Platelshik : string[150];
    Rek1 : Rekwiziti;
    Symbol :ArtikulStr;
    cl : ClientType;
    Skl : SkladType;
    WspomItog : Real;
    Delta,zakaznumer,ZakazDate,ZakazTime : AllStr;
    WithOutZena,SumOut : AllStr;
    SummaOutNDS:AllStr;
    Otsroshka : Word;

Begin

{$IfDEF DPMI}


   {
   If Commisia Then Rek1:=Rek
   Else Rek1:=Rek;
   }

   If E^.dat.DocSelector in [3,4,6,8] Then
   Rek1:=RekSF
   Else
   Rek1:=Rek;



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

DInfoMsg('Формирую товарно-транспортную накладную. Ждите...');

Writeln(Txt,Space+Dop+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt,Space+Dop+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');

    If E^.Dat.DocSelector=4 Then
    Begin
        If E^.Dat.Bn.BAnk[0]<>#0 Then
        Begin
         Writeln(txt,Space+'Платежное поручение N: '+E^.Dat.Bn.NPlat+' от '+E^.Dat.Bn.Date);
         Writeln(txt,Space+'Банк: '+E^.Dat.Bn.BAnk);
        End;
    End;



Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'                                                                            '+
'                                   Форма по ОКУД  0345009');

If E^.Dat.OperatorSelector<>2 Then Barter[0]:=#0
Else Barter:='-Б';

DelSpace(E^.DAt.Document);
DelSpace(E^.DAt.DateC);
DelZerro(E^.DAt.Document);
Z:=Rek1.Kod;
DelZerro(z);

{формируем строку поставщика}
Postawshik:=Rek1.NAme;
DelSpaceRight(Postawshik);
ws:=Rek1.Adress;
DelSpaceRight(ws);
Postawshik:=Postawshik+','+ws;
ws:=Rek1.INN;
DelSpaceRight(ws);
Postawshik:=Postawshik+',ИНН '+ws;
Format(Postawshik,98);
Postawshik:=Postawshik+' '+'по ОКПО ';
ws:=Rek1.Okpo;
DelSpaceRight(ws);
Postawshik:=Postawshik+' '+ws;
{сформировали строку поставщика}
Writeln(txt,Space+Dop+'       Поставщик: '+Postawshik);

{формируем строку Грузоотправителя}
GruzoOtpravitel:=Rek1.NAme;
DelSpaceRight(GruzoOtpravitel);
ws:=GetMAkeField(FClient,Rek1.Kod,1);
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+',Склад '+ws+',';
ws:=Rek1.AdressGruza;
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+ws+',';
ws:=Rek1.LizensiaOPTL_V;
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+' Лицензия '+ws;
Format(GruzoOtpravitel,98);
GruzoOtpravitel:=GruzoOtpravitel+' '+'по ОКПО ';
ws:=Rek1.Okpo;
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+' '+ws;
{сформировали строку Грузоотправителя}
Writeln(txt,Condensed[NPrint.Printer]+
Space+Dop+'Грузоотправитель: '+GruzoOtpravitel);

{формируем строку Грузополучателя}
Cl.Kod:=E^.Dat.ClientKod;
GruzoPolushatel:=GetClientField(FClient,E^.DAt.ClientKod,E^.DAt.OperatorSelector);
DelSpaceRight(GruzoPolushatel);
ws:=GetClientField(FAdress,E^.DAt.ClientKod,E^.DAt.OperatorSelector);
DelSpaceRight(ws);
GruzoPolushatel:=GruzoPolushatel+'('+E^.DAt.ClientKod+')'+','+ws+',';
Format(GruzoPolushatel,98);
GruzoPolushatel:=GruzoPolushatel+' '+'по ОКПО ';
ws:=GetClientField(FOKPO,E^.DAt.ClientKod,E^.DAt.OperatorSelector);
DelSpaceRight(ws);
GruzoPolushatel:=GruzoPolushatel+' '+ws;
{сформировали строку Грузоотправителя}
Writeln(txt,Space+Dop+' Грузополучатель: '+GruzoPolushatel);

{формируем строку Плательщика}
Platelshik:=GetClientField(FClient,E^.DAt.ClientKod,E^.DAt.OperatorSelector);
DelSpaceRight(Platelshik);
ws:=GetClientField(FAdress,E^.DAt.ClientKod,E^.DAt.OperatorSelector);
DelSpaceRight(ws);
Platelshik:=Platelshik+'('+E^.DAt.ClientKod+')'+','+ws+',ИНН ';
ws:=GetClientField(FINN,E^.DAt.ClientKod,E^.DAt.OperatorSelector);
DelSpaceRight(ws);
Platelshik:=Platelshik+ws;
Format(Platelshik,98);
Platelshik:=Platelshik+' '+'по ОКПО ';
ws:=GetClientField(FOKPO,E^.DAt.ClientKod,E^.DAt.OperatorSelector);
DelSpaceRight(ws);
Platelshik:=Platelshik+' '+ws;
{сформировали строку Плательщика}
Writeln(txt,Space+Dop+'      Плательщик: '+Platelshik);

{вид скидки и версия}
   If E^.Dat.SkidkaSelector=0 Then Ver:=Space+'Скидка: Авто '
   Else Ver:=Space+'Скидка: Ручная';

   If E^.Dat.SkidkaSelector=2 Then Ver:=Space+'Скидка: Шкала ';

   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   zakazTime[0]:=#0;
   ZakazNumer:=E^.Dat.Document+'/';
   ZakazDate:=E^.Dat.DateC;
   ZakazTime:=E^.Dat.TimeC;




   Writeln(txt,Space+Dop+NoCondensed[NPrint.Printer]+ver);
{конец вид скидки и версия}


If E^.Dat.DocSelector in [5,6,7,8] Then
Begin

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


If Not Commisia Then
Begin
If E^.DAt.OperatorSelector in [0,2] Then
Writeln(txt,Space+Dop+'   ТОВАРНО-ТРАНСПОРТНАЯ   Н А К Л А Д Н А Я   N     '+
E^.DAt.Document+barter+'/'+E^.DAt.Document+'  от '+ZakazDate+' ('+ZakazTime+')')
Else
Writeln(txt,Space+'ТОВАРНО-ТРАНСПОРТНАЯ  Н А К Л А Д Н А Я (межскладская перевозка) N '+
E^.DAt.Document+barter+'/'+E^.DAt.Document+'  от '+ZakazDate+' ('+ZakazTime+')');
End
Else
 Begin
If E^.DAt.OperatorSelector in [0,2] Then
Writeln(txt,Space+Dop+'   ТОВАРНО-ТРАНСПОРТНАЯ   Н А К Л А Д Н А Я   N     '+
E^.DAt.DocDate+'  от '+E^.DAt.DAteC)
Else
Writeln(txt,Space+'ТОВАРНО-ТРАНСПОРТНАЯ  Н А К Л А Д Н А Я (межскладская перевозка) N '+
E^.DAt.DocDate+'  от '+E^.DAt.DAteC);
 End;

Writeln(txt,Space+Dop+'     1. ТОВАРНЫЙ РАЗДЕЛ (заполняется грузоотправителем)'+Condensed[NPrint.Printer]);

Writeln(txt,Condensed[NPrint.Printer]);



Space:=' ';

 If (E^.Dat.OperatorSelector in [0,2]) Then
 Begin
Writeln(txt,Space+Dop+
'┌─┬─────┬──────────────────────────┬─────┬───┬─────┬──────────┬─────────┬────────┬─────────────┬──────────────┬───────'+
'──────┬───┬───────┐');
Writeln(txt,Space+Dop+'│N│ Код │ Наименование товара,     │Ед.  │   │Колич│Количество│  Масса  │        │  Сумма без  │'+
'    Н Д С     │ Итого сумма,│   │       │');
Writeln(txt,Space+Dop+'│ │     │ характеристики, производ.│изм. │Фас│един.│ упаковок │брутто,кг│Цена,руб│  учета НДС  │'+
'Ставка   Сумма│     руб     │Отд│Примеч.│');
Writeln(txt,Space+Dop+'└─┴─────┴──────────────────────────┴─────┴───┴─────┴──────────┴─────────┴────────┴─────────────┴'+
'──────────────┴─────────────┴───┴───────┘');
 End
  Else
  Begin
Writeln(txt,Space+Dop+
'┌─┬─────┬──────────────────────────┬─────┬───┬─────┬──────────┬─────────┬────────┬─────────────┬──────────────┬───────'+
'──────┬───┬──────┬──────┐');
Writeln(txt,Space+Dop+
'│N│ Код │  Наименование товара,    │Ед.  │   │Колич│Количество│  Масса  │        │  Сумма без  │    Н Д С     │ Итого '+
'сумма,│   │Ставка│      │');
Writeln(txt,Space+Dop+
'│ │     │ характеристики, производ.│изм. │Фас│един.│ упаковок │брутто,кг│Цена,руб│  учета НДС  │Ставка   Сумма│     ру'+
'б     │Отд│  НП  │Примеч│');
Writeln(txt,Space+Dop+
'└─┴─────┴──────────────────────────┴─────┴───┴─────┴──────────┴─────────┴────────┴─────────────┴──────────────┴───────'+
'──────┴───┴──────┴──────┘');
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

     Skl.BazKod:=E^.Dat.MarketElement[l].BazKod;


     If Not(E^.DAt.MarketElement[l].Input.Last) Then
     Separator:=' '   Else Separator:=#249;
      ws:=GetIdField(FName,E^.Dat.MarketElement[l].BazKod);

     Format(ws,CName);
     s:=s+' '+ws;

     EdIzm[0]:=#0;
     EdIzm:=GetIdField(FMera,E^.Dat.MarketElement[l].BazKod);
     Format(EdIzm,5);
     s:=s+' '+EdIzm;

     EdIzm[0]:=#0;
     EdIzm:=GetIdField(FInPack,E^.Dat.MarketElement[l].BazKod);
     Format(EdIzm,CInPack);
     s:=s+' '+EdIzm;


     DelSpace(E^.Dat.MarketElement[l].Input.Kol);
     ws:=E^.Dat.MarketElement[l].Input.Kol;
     ws:='{'+ws+'}';
     RFormat(ws,CKol+2);
     s:=s+{' '}+ws;

     pp:=CalcPack(E^.Dat.MarketElement[l].BazKod,E^.Dat.MarketElement[l].Input.Kol);
     DelSpace(pp);
     RFormat(pp,CPack);
     s:=s+' '+pp;

     Massa[0]:=#0;
     Massa:='';
     Format(Massa,7);
     MyStr(StrToInt(E^.Dat.MarketElement[l].Input.Kol)*
              StrToReal(Massa),7+2,CLitrMantissa,Massa);
     Str(StrToReal(AllMAssa)+StrToReal(Massa):CIZena:CLitrMAntissa,AllMAssa);
     s:=s+' '+MAssa+' ';

     {прибавили массу брутто товара}

     If E^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
      begin
       DelSpace(E^.Dat.MarketElement[l].Input.Proz);
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)*
       (StrToReal(E^.Dat.MarketElement[l].Input.Proz))),CZena,CMantissa,ws);
      End
     Else
      Begin
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Skidka))
       ,CZena,CMantissa,ws);
      End;

       {отключен расчет налога с продажи}
       {по всем видам документов}
       If E^.DAt.DocSelector in [{1}2,3,5,6] Then
       Begin
        Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
               /100)),CLitr,CMantissa,koefficient);
        {новая цена}
        MyStr(StrToReal(ws)*StrToReal(Koefficient),CZena,CMantissa,WithOutZena);
       End
       Else
	   WithOutZena:=ws;


       {ws:=WithOutZena;}

       MyStr(StrToReal(WithOutZena)-StrToReal(ws),CZena,CMAntissa,Delta);
       DelSpace(Delta);

       Zen:=ws;

       s:=s+Zen;{прибавили цену за единицу товара с учетом скидки}

       WspomItog:=StrToReal(Zen)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);

       ItogoS:=ItogoS+{StrToReal(Sum)}WspomItog;

       MyStr((StrToReal(WithOutZena)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
       ,CInputIZena,CMantissa,sumOut);


       NdsPos:=WspomItog*StrToReal(E^.Dat.MarketElement[l].Input.NDS)/
       (100+StrToReal(E^.Dat.MarketElement[l].Input.NDS));
       If E^.Dat.DocSelector in [0,1,2,5,7] Then NDSPos:=0;

       MyStr(NdsPos,CZena,CMantissa,ws);{сумма ндс в позиции}
       NdsPos:=StrToReal(Ws);



       MyStr(StrToReal(Sumout)-StrToReal(ws),CInputIZena,CMAntissa,ws1);{сумма без учета ндс в позиции}
       MyStr(StrToREal(SummaOutNDS)+StrToReal(ws1),CInputIZena,CMAntissa,SummaOutNDS);

       s:=s+' '+ws1;

       ws2:=E^.Dat.MarketElement[l].Input.NDS;
       MyStr(StrToReal(ws2),CLitr,CMantissa,ws2);
       If E^.Dat.DocSelector in [0,1,2,5,7] Then
       begin
        ws2:=' --  ';
        ws:='   --   ';
       End;
       s:=s+' '+ws2;{ставка ндс}
       s:=s+' '+ws;{сумма ндс в позиции}
       ws[0]:=#0;


       MyStr((StrToReal(WithOutZena)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
       ,CInputIZena,CMantissa,sum);


       If E^.Dat.OperatorSelector in [0,2] Then
       s:=s+' '+Sum
       Else
       s:=s+' '+TempZakupka;

      M[E^.Dat.MarketElement[l].Input.DivisionSNumber]:=1;

     {добавили отделение}
     Str(E^.Dat.MarketElement[l].Input.DivisionSNumber:2,ws);

  If E^.Dat.OperatorSelector=1 Then
    Begin
     Nalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
     MyStr(StrToReal(Nalog)*StrToInt(E^.Dat.MarketElement[l].Input.Kol),CZena,CMantissa,Nalog);
     ws:=ws+' '+Nalog;
    End;
     ws:=ws+' '+Delta;


     s:=Pitch[NPrint.Printer]+Condensed[NPrint.Printer]++s+' '+ws+NoPitch[NPrint.Printer]+
     Condensed[NPrint.Printer];

     Str(l:CMantissa,St);
     Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+ST+' '+s);
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
{DelSpace(E^.Dat.SummaZ);}

    MyStr(StrToReal(E^.Dat.SummaZ)-NDS,CIZena-2,CMAntissa,ws);
    MyStr(StrToReal(E^.Dat.SummaZ),CIZena-2,CMAntissa,E^.Dat.SummaZ);
    MyStr(NDS,CZena,CMAntissa,ws2);

    MyStr(StrToReal(SummaOutNDS),CIZena-2,CMAntissa,SummaOutNDS);

Writeln(txt,Condensed[NPrint.Printer]+
Space+Dop+'──────────────────────────────────────────────────────────────────────────────────────────────────────'+
'───────────────────────────────────');

  If E^.DAt.OperatorSelector in [0,2] Then
Begin

   If E^.Dat.DocSelector in [3,4,6,8] Then
    Writeln(Txt,Condensed[NPrint.Printer]+Space+Dop+'Позиций:',E^.Dat.Amount:2,
    '                                                                                                  ',
    Recogniz({ws}SummaOutNDS),+
    '        ',Recogniz(ws2),Double[NPrint.Printer]+Condensed[NPrint.Printer]+Recogniz(E^.Dat.SummaZ)+NoDouble[NPrint.Printer]+
    '   Мест:'+CalcMesto(E))
    Else
    Writeln(Txt,Condensed[NPrint.Printer]+Space+Dop+'Позиций:',E^.Dat.Amount:2,
    '                                                                                     '+
    '        ',Recogniz(ws2),Double[NPrint.Printer]+Condensed[NPrint.Printer]+Recogniz(E^.Dat.SummaZ)+NoDouble[NPrint.Printer]+
    '   Мест:'+CalcMesto(E))

End
  Else
 Begin
    Writeln(Txt,Condensed[NPrint.Printer]+Space+Dop+'Позиций:',E^.Dat.Amount:2,
    '                                                                                  ',Recogniz({ws}SummaOutNDS),'        ',
    Recogniz(ws2),Double[NPrint.Printer]+Condensed[NPrint.Printer]+Recogniz(E^.Dat.SummaZ)+NoDouble[NPrint.Printer]+
    '   Мест:'+CalcMesto(E));

 End;


   If E^.Dat.DocSelector in [3,4,6,8] Then
   Begin
    If Not Video Then
    If E^.Dat.DocSelector<>0 Then
      Begin
       Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'     В т.ч. НДС:',RecognizReal(Nds,CIZena,CMantissa));
       If NDS20>0.009 Then
       Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+Italic[NPrint.Printer]+
          Condensed[NPrint.Printer]+'         '+CNDS20+'   :'+
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
   End
   Else
       Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'Без НДС'+NoItalic[NPrint.Printer]);


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
    DelSpace(s);
    Propis(s,ws);
    ws[1]:=UpperCase(ws[1]);
    ws:=ws+' '+s;
    Format(ws,80);
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'Отпущено на сумму ');
    Writeln(txt,Space+Dop+Italic[NPrint.Printer]+Double[NPrint.Printer]+Double[NPrint.Printer]+
    +Condensed[NPrint.Printer]+ws+NoItalic[NPrint.Printer]+NoDouble[NPrint.Printer]+NoDouble[NPrint.Printer]+
    Condensed[NPrint.Printer]+
    '  По доверенности N _____ от ___________, выданной ______________');
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+
    'Отпуск разрешил                                                                   Груз к перевозке принял '+
    'экспедитор (водитель) _________________');
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'Оператор                                             '+
    '                  (При личном приеме товар по количеству и ассортименту проверил');
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'торгового зала ____________  Бухгалтер кассир _____________  '+
    '  (груз получил грузополучатель (претензий не имею) _____________');
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'Отпуск произвел кладовщик ___________________                '+
    'М.П.                ');

    End;

writeln(txt,NoCondenSed[NPrint.Printer]);

Writeln(txt,Space+Dop+'     2. ТРАНСПОРТНЫЙ РАЗДЕЛ '+CondenSed[NPrint.Printer]);

Writeln(txt,Space+Dop+'Срок доставки груза: '+E^.DAt.DAteC+'                                    '+
'                                                      ТТН N: '+ZakazNumer+E^.Dat.Document+'/'+Z+' от '+ZakazDate);

Writeln(txt,Space+Dop+'Организация: ________________________  Водитель: ____________ Автомобиль: _______'+
'______ Гос.номер: ________________      К путевому листу N ____');

Writeln(txt,Space+Dop+'Лицензионная карточка: Регистрационный N ____________ Серия _________ N ________ '+
'Вид перевозки: ______________________________          Код ____');
Writeln(txt,Space+Dop+'Пункт погрузки: '+Rek1.AdressGruza+' Пункт разгрузки: ');


Writeln(Txt,NoCondensed[NPrint.Printer]);


  If E^.Dat.DocSelector in [{1,}2,3,5,6] Then
    Begin
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




   Write(txt,NoCondensed[NPrint.Printer]);





   Write(txt,Space{+' Всего: '},' '+'               '{+RecognizReal(Itogo,CIZena,CMantissa)},
    '                         '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

   Symbol:='';

   Writeln(txt,Space+Dop+NoCondensed[NPrint.Printer]+''+Italic[NPrint.Printer]+Double[NPrint.Printer]+
   Double[NPrint.Printer]+' Тип документа: (',
   LeadingZero(E^.Dat.DocSelector),Symbol+')'+NoItalic[NPrint.Printer]+
   NODouble[NPrint.Printer]);

   {отчеркивание заключительное}

Writeln(txt,Condensed[NPrint.Printer]+Space+
Dop+'============================================================================'+
'=========================='+
'============================================'+NoCondensed[NPrint.Printer]);
If Not(Video) Then NoInfoMsg;
{$ENDIF}
End;

*)

Procedure FormNaklTTN(Space :TDateString; Video : Boolean;As :DocumentEdit;Const E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Real;
                   ShowAnswer,Commisia:Boolean);
Var l : Word;
    Ver,s,sc,ws,ws1,ws2,ws3 : string[150];
    Ss,ss1 : string[150];
    st : String[CMantissa];
    pp : String[CPack];
    TTT,ItogoS,NdsPos :Real;
    Local,R : Boolean;
    {M : Maska8;}
    c : Word;
    Dop : TDateString;
    Nalog,Massa:TDateString;
    tempSkidka,tt1,tt2,WspomSkidka,
    OutputSklad,InputSklad,koefficient:ALLStr;
    DrawSkidka:Boolean;
    Barter : String[CMantissa];
    TempZakupka : AllStr;
    AllMassa,Separator : TMyString;
    EdIzm: STring[5];
    Z,Zen,Sum:String[CIZena];
    Postawshik,GruzoOtpravitel,
    Gruzopolushatel,Platelshik : string[150];
    Symbol :ArtikulStr;
    cl : ClientType;
    Skl : SkladType;
    WspomItog : Real;
    Delta,zakaznumer,ZakazDate,ZakazTime : AllStr;
    WithOutZena,SumOut : AllStr;
    SummaOutNDS:AllStr;
    Otsroshka : Word;
    Rek1 : Rekwiziti;
    Res : Word;

Begin

{$IfDEF DPMI}

{
   If Commisia Then Rek1:=RekComissioner
   Else Rek1:=Rek;
}
   Commisia:=False;

   If E^.dat.DocSelector in [3,4,6,8] Then
   Rek1:=RekSF
   Else
   Rek1:=Rek;


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
   DrawSkidka:=False;
   (*
   If Not(LoCal) Then
   Begin
    If (StrToInt(E^.DAt.AgentKod)<>0) Then
       Begin
        If MessageBox(^M+#3'Включать ставки скидок в накладную?',Nil,mfWarning+mfOkCancel)=cmcancel Then
        DrawSkidka:=False;
       End;{служба доставки}
   End;
   *)
   End;

DInfoMsg('Формирую товарно-транспортную накладную. Ждите...');

Space:='     ';
Writeln(Txt,Space+Dop+'Оператор: '+E^.Dat.Caption+' Агент: '+E^.Dat.AgentKod+' EYE & 1997-00');
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt,Space+Dop+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');

    If E^.Dat.DocSelector=4 Then
    Begin
        If E^.Dat.Bn.BAnk[0]<>#0 Then
        Begin
         Writeln(txt,Space+'Платежное поручение N: '+E^.Dat.Bn.NPlat+' от '+E^.Dat.Bn.Date);
         Writeln(txt,Space+'Банк: '+E^.Dat.Bn.BAnk);
        End;
    End;

Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'                                                                            '+
'                        Унифицированная форма N ТОРГ 12');
Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'                                                                            '+
'                                   Форма по ОКУД  0330212');

If E^.Dat.OperatorSelector<>2 Then Barter[0]:=#0
Else Barter:='-Б';

DelSpace(E^.DAt.Document);
DelSpace(E^.DAt.DateC);
DelZerro(E^.DAt.Document);
Z:=Rek1.Kod;
DelZerro(z);

{формируем строку поставщика}
Postawshik:=Rek1.NAme;
DelSpaceRight(Postawshik);
ws:=Rek1.Adress;
DelSpaceRight(ws);
Postawshik:=Postawshik+','+ws;
ws:=Rek1.INN;
DelSpaceRight(ws);
Postawshik:=Postawshik+',ИНН '+ws;
Format(Postawshik,98);
Postawshik:=Postawshik+' '+'по ОКПО ';
ws:=Rek1.Okpo;
DelSpaceRight(ws);
Postawshik:=Postawshik+' '+ws;
{сформировали строку поставщика}
Writeln(txt,Space+Dop+'       Поставщик: '+Postawshik);

{формируем строку Грузоотправителя}
GruzoOtpravitel:=Rek1.NAme;
DelSpaceRight(GruzoOtpravitel);
ws:=GetMAkeField(FClient,Rek1.Kod,1);
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+',Склад '+ws+',';
ws:=Rek1.AdressGruza;
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+ws+',';
ws:=Rek1.LizensiaOPTL_V;
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+' Лицензия '+ws;
Format(GruzoOtpravitel,98);
GruzoOtpravitel:=GruzoOtpravitel+' '+'по ОКПО ';
ws:=Rek1.Okpo;
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+' '+ws;
{сформировали строку Грузоотправителя}
Writeln(txt,Condensed[NPrint.Printer]+
Space+Dop+'Грузоотправитель: '+GruzoOtpravitel);

{формируем строку Грузополучателя}
Cl.Kod:=E^.Dat.ClientKod;
GruzoPolushatel:=GetClientField(FFFName,E^.DAt.ClientKod,E^.DAt.OperatorSelector);
DelSpaceRight(GruzoPolushatel);
ws:=GetClientField(FEnvir,E^.DAt.ClientKod,E^.DAt.OperatorSelector);
DelSpaceRight(ws);
GruzoPolushatel:=GruzoPolushatel+'('+E^.DAt.ClientKod+')'+','+ws+',';
Format(GruzoPolushatel,98);
GruzoPolushatel:=GruzoPolushatel+' '+'по ОКПО ';
ws:=GetClientField(FOKPO,E^.DAt.ClientKod,E^.DAt.OperatorSelector);
DelSpaceRight(ws);
GruzoPolushatel:=GruzoPolushatel+' '+ws;
{сформировали строку Грузоотправителя}
Writeln(txt,Space+Dop+' Грузополучатель: '+GruzoPolushatel);

{формируем строку Плательщика}
Platelshik:=GetClientField(FFFName,E^.DAt.ClientKod,E^.DAt.OperatorSelector);
DelSpaceRight(Platelshik);
ws:=GetClientField(FAdress,E^.DAt.ClientKod,E^.DAt.OperatorSelector);
DelSpaceRight(ws);
Platelshik:=Platelshik+'('+E^.DAt.ClientKod+')'+','+ws+',ИНН ';
ws:=GetClientField(FINN,E^.DAt.ClientKod,E^.DAt.OperatorSelector);
DelSpaceRight(ws);
Platelshik:=Platelshik+ws;
Format(Platelshik,98);
Platelshik:=Platelshik+' '+'по ОКПО ';
ws:=GetClientField(FOKPO,E^.DAt.ClientKod,E^.DAt.OperatorSelector);
DelSpaceRight(ws);
Platelshik:=Platelshik+' '+ws;
{сформировали строку Плательщика}
Writeln(txt,Space+Dop+'      Плательщик: '+Platelshik);

{вид скидки и версия}
   If E^.Dat.SkidkaSelector=0 Then Ver:=Space+'Скидка: Авто '
   Else Ver:=Space+'Скидка: Ручная';

   If E^.Dat.SkidkaSelector=2 Then Ver:=Space+'Скидка: Шкала ';

   zakaznumer[0]:=#0;
   zakazDate[0]:=#0;
   zakazTime[0]:=#0;
   ZakazNumer:=E^.Dat.Document+'/';
(* отключено 26/03/01 из-за проблем в бухгалтерии*)
   ZakazDate:=E^.Dat.DateC;
   ZakazTime:=E^.Dat.TimeC;




   Writeln(txt,Space+Dop+NoCondensed[NPrint.Printer]+ver);
{конец вид скидки и версия}


If E^.Dat.DocSelector in [5,6,7,8] Then
Begin

 Writeln(Txt,Space+Dop+Bold[NPrint.Printer]+'Срок консигнации до: '+DateToDateString(DateMask,E^.Dat.Srok)+
 NoBold[NPrint.Printer]);
End;


DelSpace(E^.Dat.Document);
Space:='';
Space:='           ';
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
DelSpace(E^.Dat.NaklNumer);

If Not Commisia Then
Begin
If E^.DAt.OperatorSelector in [0,2] Then
Writeln(txt,Space+Dop+'   Т О В А Р Н А Я    Н А К Л А Д Н А Я   N     '+
E^.DAt.NaklNumer+barter+'/'+E^.DAt.Document+'  от '+ZakazDate)
Else
Writeln(txt,Space+'Т О В А Р Н А Я   Н А К Л А Д Н А Я (межскладская перевозка) N '+
E^.DAt.NaklNumer+barter+'/'+E^.DAt.Document+'  от '+ZakazDate);
End
Else
 Begin
If E^.DAt.OperatorSelector in [0,2] Then
Writeln(txt,Space+Dop+'   Т О В А Р Н А Я    Н А К Л А Д Н А Я   N     '+
E^.DAt.DocDate+'  от '+E^.DAt.DAteC)
Else
Writeln(txt,Space+' Т О В А Р Н А Я    Н А К Л А Д Н А Я (межскладская перевозка) N '+
E^.DAt.DocDate+'  от '+E^.DAt.DAteC);
 End;

(* отключено 26/03/01 из-за проблем в бухгалтерии*)
Writeln(txt,Condensed[NPrint.Printer]);




 If (E^.Dat.OperatorSelector in [0,2]) Then
 Begin
Writeln(txt,Space+Dop+MinInterval2[NPrint.Printer]+
                       '┌──────────────────────────────────┬──────────┬───┬─────────────┬──────┬──────┬────────'+
				   '┬──────────┬───────────────┬──────────┐');
 Writeln(txt,Space+Dop+'│           Т О В А Р              │Един.измер│Вид│ Количество  │      │Колич.│        '+
 '│          │     Н Д С     │  Сумма с │');
 Writeln(txt,Space+Dop+'├─┬─────┬──────────────────────────┼─────┬────┤упа├───────┬─────┤Масса │(масса│  Цена  '+
 '│Сумма без ├──────┬────────┤  учетом  │');
 Writeln(txt,Space+Dop+'│N│ Код │ Наименование товара,     │Наиме│код │ков│в одном│мест,│брутто│нетто)│руб,коп '+
 '│учета НДС,│Ставка│  Сумма │   НДС    │');
 Writeln(txt,Space+Dop+'│ │     │ характеристики, производ.│енов.│ОКЕИ│ки │месте  │штук │      │      │        '+
 '│  руб.коп │      │ руб,коп│  руб,коп │');
 Writeln(txt,Space+Dop+'├─┼─────┼──────────────────────────┼─────┼────┼───┼───────┼─────┼──────┼──────┼────────'+
 '┼──────────┼──────┼────────┼──────────┤');
 Writeln(txt,Space+Dop+'│1│  3  │           2              │  4  │ 5  │ 6 │   7   │  8  │  9   │  10  │   11   '+
 '│    12    │  13  │   14   │    15    │');
 Writeln(txt,Space+Dop+'└─┴─────┴──────────────────────────┴─────┴────┴───┴───────┴─────┴──────┴──────┴────────'+
 '┴──────────┴──────┴────────┴──────────┘'+
 Normal[NPrint.Printer]+
   Condensed[NPrint.Printer]);
{
                      '┌─┬─────┬──────────────────────────┬─────┬───┬─────┬──────────┬─────────┬──'+
				  '──────┬─────────────┬──────────────┬───────'+'──────┬───┬───────┐');
Writeln(txt,Space+Dop+'│N│ Код │ Наименование товара,     │Ед.  │   │Колич│Количество│  Масса  │        │  Сумма без  │'+
'    Н Д С     │ Итого сумма,│   │       │');
Writeln(txt,Space+Dop+'│ │     │ характеристики, производ.│изм. │Фас│един.│ упаковок │брутто,кг│Цена,руб│  учета НДС  │'+
'Ставка   Сумма│     руб     │Отд│Примеч.│');
Writeln(txt,Space+Dop+'└─┴─────┴──────────────────────────┴─────┴───┴─────┴──────────┴─────────┴────────┴─────────────┴'+
'──────────────┴─────────────┴───┴───────┘'+
Normal[NPrint.Printer]+
   Condensed[NPrint.Printer]);
   }
 End
  Else
  Begin

Writeln(txt,Space+Dop+MinInterval2[NPrint.Printer]+
                       '┌──────────────────────────────────┬──────────┬───┬─────────────┬──────┬──────┬────────'+
				   '┬──────────┬───────────────┬──────────┐');
 Writeln(txt,Space+Dop+'│           Т О В А Р              │Един.измер│Вид│ Количество  │      │Колич.│        '+
 '│          │     Н Д С     │  Сумма с │');
 Writeln(txt,Space+Dop+'├─┬─────┬──────────────────────────┼─────┬────┤упа├───────┬─────┤Масса │(масса│  Цена  '+
 '│Сумма без ├──────┬────────┤  учетом  │');
 Writeln(txt,Space+Dop+'│N│ Код │ Наименование товара,     │Наиме│код │ков│в одном│мест,│брутто│нетто)│руб,коп '+
 '│учета НДС,│Ставка│  Сумма │   НДС    │');
 Writeln(txt,Space+Dop+'│ │     │ характеристики, производ.│енов.│ОКЕИ│ки │месте  │штук │      │      │        '+
 '│  руб.коп │      │ руб,коп│  руб,коп │');
 Writeln(txt,Space+Dop+'├─┼─────┼──────────────────────────┼─────┼────┼───┼───────┼─────┼──────┼──────┼────────'+
 '┼──────────┼──────┼────────┼──────────┤');
 Writeln(txt,Space+Dop+'│1│  3  │           2              │  4  │ 5  │ 6 │   7   │  8  │  9   │  10  │   11   '+
 '│    12    │  13  │   14   │    15    │');
 Writeln(txt,Space+Dop+'└─┴─────┴──────────────────────────┴─────┴────┴───┴───────┴─────┴──────┴──────┴────────'+
 '┴──────────┴──────┴────────┴──────────┘'+
 Normal[NPrint.Printer]+
   Condensed[NPrint.Printer]);
  End;
              { 1 12345│12345678901234567890123456│12345│12345678│12345│1234567890123│123456789│123│1234567│}


   c:=0;
   AllMAssa[0]:=#0;
   SummaOutNDS[0]:=#0;
   {WordToBit8(c,M);}
   For l:=1 To E^.Dat.Amount Do
    Begin
     Str(l:CMantissa,St);
     s:=E^.Dat.MarketElement[l].BazKod;

     Skl.BazKod:=E^.Dat.MarketElement[l].BazKod;


     If Not(E^.DAt.MarketElement[l].Input.Last) Then
     Separator:=' '   Else Separator:=#249;
      ws:=GetIdField(FName,E^.Dat.MarketElement[l].BazKod);

     Format(ws,CName);
     s:=s+' '+ws;

     EdIzm[0]:=#0;
     EdIzm:=GetIdField(FMera,E^.Dat.MarketElement[l].BazKod);
     Format(EdIzm,5);
     s:=s+' '+EdIzm+'     '{код ОКЕИ}+'    '{вид упаковки};


     EdIzm[0]:=#0;
     EdIzm:=GetIdField(FInPack,E^.Dat.MarketElement[l].BazKod);
     RFormat(EdIzm,7{водном месте});
     s:=s+' '+EdIzm+'      '{мест(штук)}+'       '{масса брутто};


     DelSpace(E^.Dat.MarketElement[l].Input.Kol);
     ws:=E^.Dat.MarketElement[l].Input.Kol;
     ws:='{'+ws+'}';
     RFormat(ws,CKol+1+2);
     s:=s+{' '}+ws;

     pp:=CalcPack(E^.Dat.MarketElement[l].BazKod,E^.Dat.MarketElement[l].Input.Kol);
     DelSpace(pp);
     RFormat(pp,CPack);
     {s:=s+' '+pp;}

     Massa[0]:=#0;
     Massa:='';
     Format(Massa,7);
     MyStr(StrToInt(E^.Dat.MarketElement[l].Input.Kol)*
              StrToReal(Massa),7+2,CLitrMantissa,Massa);
     Str(StrToReal(AllMAssa)+StrToReal(Massa):CIZena:CLitrMAntissa,AllMAssa);
     {s:=s+' '+MAssa+' ';}

     {прибавили массу брутто товара}
     If E^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
      begin
       DelSpace(E^.Dat.MarketElement[l].Input.Proz);
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)*
       StrToReal(E^.Dat.MarketElement[l].Input.Proz)),CZena,CMantissa,ws);
      End
     Else
      Begin
       MyStr((StrToReal(E^.Dat.MarketElement[l].Input.Zena)-StrToReal(E^.Dat.MarketElement[l].Input.Skidka))
       ,CZena,CMantissa,ws);
      End;

       {отключен расчет налога с продажи}
       {по всем видам документов}
       If E^.DAt.DocSelector in [{1}2,3,5,6] Then
       Begin
        Mystr(((1+strtoreal(e^.dat.marketelement[l].Input.SpecNalog)
               /100)),CLitr,CMantissa,koefficient);
        {новая цена}
        MyStr(StrToReal(ws)*StrToReal(Koefficient),CZena,CMantissa,WithOutZena);
       End
       Else
	   WithOutZena:=ws;


       {ws:=WithOutZena;}

       MyStr(StrToReal(WithOutZena)-StrToReal(ws),CZena,CMAntissa,Delta);
       DelSpace(Delta);

       Zen:=ws;

       s:=s+Zen;{прибавили цену за единицу товара с учетом скидки}

       WspomItog:=StrToReal(Zen)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);

       ItogoS:=ItogoS+{StrToReal(Sum)}WspomItog;

       MyStr((StrToReal(WithOutZena)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
       ,CInputIZena,CMantissa,sumOut);


       NdsPos:=WspomItog*StrToReal(E^.Dat.MarketElement[l].Input.NDS)/
       (100+StrToReal(E^.Dat.MarketElement[l].Input.NDS));
       If E^.Dat.DocSelector in [0,1,2,5,7] Then NDSPos:=0;
       MyStr(NdsPos,CZena,CMantissa,ws);{сумма ндс в позиции}
       NdsPos:=StrToReal(Ws);

{
       NdsPos:=WspomItog*StrToReal(E^.Dat.MarketElement[l].Input.NDS)/
       (100+StrToReal(E^.Dat.MarketElement[l].Input.NDS));
       If E^.Dat.DocSelector in [0,1,2,5,7] Then NDSPos:=0;

       MyStr(NdsPos,CZena,CMantissa,ws);
       NdsPos:=StrToReal(Ws);



       MyStr(StrToReal(Sumout)-StrToReal(ws),CInputIZena,CMAntissa,ws1);
       MyStr(StrToREal(SummaOutNDS)+StrToReal(ws1),CInputIZena,CMAntissa,SummaOutNDS);

       s:=s+' '+ws1;

       ws2:=E^.Dat.MarketElement[l].Input.NDS;
       MyStr(StrToReal(ws2),CLitr,CMantissa,ws2);
       If E^.Dat.DocSelector in [0,1,2,5,7] Then
       begin
        ws2:=' --  ';
        ws:='   --   ';
       End;
       s:=s+' '+ws2;
       s:=s+' '+ws;
       ws[0]:=#0;
}

       MyStr(StrToReal(Sumout)-StrToReal(ws),CInputIZena-3,CMAntissa,ws1);{сумма без учета ндс в позиции}

       MyStr(StrToREal(SummaOutNDS)+StrToReal(ws1),CInputIZena-3,CMAntissa,SummaOutNDS);

       s:=s+' '+ws1;

       ws2:=E^.Dat.MarketElement[l].Input.NDS;
       MyStr(StrToReal(ws2),CLitr,CMantissa,ws2);

       If E^.Dat.DocSelector in [0,1,2,5,7] Then
       begin
        ws2:=' --  ';
        ws:='   --   ';
       End;
       s:=s+' '+ws2+'%';{ставка ндс}
       s:=s+' '+ws;{сумма ндс в позиции}
       ws[0]:=#0;


       MyStr((StrToReal(WithOutZena)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
       ,CInputIZena-3,CMantissa,sum);


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

      {M[E^.Dat.MarketElement[l].Input.DivisionNumbers]:=1;}


     s:=Pitch[NPrint.Printer]+Condensed[NPrint.Printer]++s+' '+ws+NoPitch[NPrint.Printer]+
     Condensed[NPrint.Printer];

     Str(l:CMantissa,St);
     Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+ST+' '+s);

    End;


    ItogoSkidka:=Itogo{+StrToReal(E^.Dat.ENalog)};
    MySTr(ItogoSkidka,CIZena,CMantissa,tt1);
    MySTr(ItogoS,CIZena,CMantissa,tt2);

    ItogoSkidka:=StrToReal(tt1)-StrToReal(tt2){ItogoS};

    DelSpace(E^.Dat.SummaZ);
    RFormat(E^.Dat.SummaZ,CIZena);
    RFormat(E^.Dat.SummaZakupka,CIZena);
MyStr(StrToReal(E^.Dat.SummaZ),CIZena,CMantissa,E^.Dat.SummaZ);

    MyStr(StrToReal(E^.Dat.SummaZ)-NDS,CIZena-2,CMAntissa,ws);
    MyStr(StrToReal(E^.Dat.SummaZ),CIZena-2,CMAntissa,E^.Dat.SummaZ);
    MyStr(NDS,CZena,CMAntissa,ws2);

    MyStr(StrToReal(SummaOutNDS),CIZena-2,CMAntissa,SummaOutNDS);

Writeln(txt,Condensed[NPrint.Printer]+
Space+Dop+'──────────────────────────────────────────────────────────────────────────────────────────────────────'+
'─────────────────────────');

   If Not (E^.Dat.DocSelector in [3,4,6,8]) Then
    ws2:='       ';

    Writeln(Txt,Condensed[NPrint.Printer]+Space+Dop+'Позиций:',E^.Dat.Amount:2,
    '                                         Всего по накладной:              ',Recogniz({ws}SummaOutNDS),'        ',
    Recogniz(ws2),Double[NPrint.Printer]+Condensed[NPrint.Printer]+Recogniz(E^.Dat.SummaZ)+NoDouble[NPrint.Printer]);



   If E^.Dat.DocSelector in [3,4,6,8] Then
   Begin
    If Not Video Then
    If E^.Dat.DocSelector<>0 Then
      Begin
       Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'     В т.ч. НДС:',RecognizReal(Nds,CIZena,CMantissa));
       If NDS20>0.009 Then
       Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+Italic[NPrint.Printer]+
          Condensed[NPrint.Printer]+'         '+CNDS20+'   :'+
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
   End
   Else
       Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'Без НДС'+NoItalic[NPrint.Printer]);

    {
    If Not Video Then
    If E^.Dat.DocSelector<>0 Then
      Begin
       Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'     В т.ч. НДС:',RecognizReal(Nds,CIZena,CMantissa));
       If NDS20>0.009 Then
       Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+Italic[NPrint.Printer]+
          Condensed[NPrint.Printer]+'         '+CNDS20+'   :'+
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
    }
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

Space:='  ';

    Writeln(txt,Condensed[NPrint.Printer]+Space+'         Товарная накладная содержит '+Pitch[NPrint.Printer]+
    Condensed[NPrint.Printer]+ws+NoPitch[NPrint.Printer]+Condensed[NPrint.Printer]+
    ' порядковых номеров записей');
    Writeln(txt,Condensed[NPrint.Printer]+Space+'         всего наименований: '+Pitch[NPrint.Printer]+
    Condensed[NPrint.Printer]+ws+NoPitch[NPrint.Printer]+Condensed[NPrint.Printer]);

    Writeln(txt,Condensed[NPrint.Printer]+Space+
    'Всего мест: '+Pitch[NPrint.Printer]+Condensed[NPrint.Printer]+ws2+NoPitch[NPrint.Printer]+Condensed[NPrint.Printer]);
    Writeln(txt,Condensed[NPrint.Printer]+Space+

    'Всего масса(брутто): '+
    Pitch[NPrint.Printer]+Condensed[NPrint.Printer]+
    ws1+NoPitch[NPrint.Printer]+Condensed[NPrint.Printer]);

    Writeln(txt,Condensed[NPrint.Printer]+Space+
    'Всего масса(нетто): '+
    Pitch[NPrint.Printer]+Condensed[NPrint.Printer]+NoPitch[NPrint.Printer]+Condensed[NPrint.Printer]);

    Writeln(txt,Condensed[NPrint.Printer]+Space+
    'Приложение (паспорта,сертификаты и т.п.): '+
    Pitch[NPrint.Printer]+Condensed[NPrint.Printer]+'         '+NoPitch[NPrint.Printer]+Condensed[NPrint.Printer]+' листах');



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
    '  По доверенности N _____ от ___________, выданной ______________');
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+
    'Отпуск разрешил                                                                   Груз к перевозке принял '+
    'экспедитор (водитель) _________________');
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+
    'Оператор                                             '+
    '                             При личном приеме товар по количеству и ассортименту проверил');
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+
    'торгового зала ____________  Бухгалтер кассир _____________  '+
    '                     груз получил грузополучатель (претензий не имею) _____________');
    Writeln(txt,Condensed[NPrint.Printer]+Space+Dop+'Отпуск произвел кладовщик ___________________                '+
    'М.П.                        М.П.');

    End;

writeln(txt,NoCondenSed[NPrint.Printer]);


   Write(txt,Space{+' Всего: '},' '+'               '{+RecognizReal(Itogo,CIZena,CMantissa)},
    '                         '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

   Symbol:='';

   Writeln(txt,Space+Dop+NoCondensed[NPrint.Printer]+''+Italic[NPrint.Printer]+Double[NPrint.Printer]+
   Double[NPrint.Printer]+' Тип документа: (',
   LeadingZero(E^.Dat.DocSelector),Symbol+')'+NoItalic[NPrint.Printer]+
   NODouble[NPrint.Printer]);

   {отчеркивание заключительное}

Writeln(txt,Condensed[NPrint.Printer]+Space+
Dop+'============================================================================'+
'=========================='+NoCondensed[NPrint.Printer]);
If Not(Video) Then NoInfoMsg;
{$ENDIF}
End;

Procedure PrintPersonal;
Var R : TRect;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    ClientList :PBox;
    RealFile : File Of TovarClientType;
    E  : TovarClientType;

    RealFileR : File Of RazdelClientType;
    ER  : RazdelClientType;
    s,w,w1,st : AllStr;
    ws : TMyString;
    ii,c,t1,t2 : LongInt;
    r1,r2 , Rsf,RsfSkid :Real;
    f : Text;
    {DateMask : TDateString;}
    Space2,Space : AllStr;
    SDelta,SZakupka,SNAme,SDate,SProz,SpezZena,SOp : AllStr;

    Tip,Vid,Realno : Word;
    Print,Criminal : Boolean;
    CriminalSumma : Real;
begin
Assign(f,Path.ToTemp+'pers.txt');
c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0) Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path.ToTemp+'pers.txt!!',Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c=0 Then
Begin
AInfo('Читаю список клиентов...');
While Not(Eof(ClientFile)) Do
 Begin
   ReadClient(ClientFile,ClientElement);

  If (ClientElement.Employ) And ((FExists(Path.ToClient+ClientElement.Kod+'.skl') Or
  (FExists(Path.ToClient+ClientElement.Kod+'.rsk')))) Then
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
Space:='';
r1:=0;r2:=0;
rsf:=0;
rsfSkid:=0;
Writeln(f,Space+Condensed[NPrint.Printer]);
Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword);
Writeln(f,Space+'            СПРАВКА ПО ПЕРСОНАЛЬНЫМ СКИДКАМ КЛИЕНТОВ'+'  '+FDate+' ('+Times+')');
Writeln(f,Space+'------------------------------------------------------------------------------------------------------');
Writeln(f,Space+'       Клиент        Код  Наименование товара         Код  Цена     Дата     Оператор     Дельта    %');
{                12345678901234567890|1234|12345678901234567890123456|12345│12345678|12345678│123456789012│123456|12345}
Writeln(f,Space+'------------------------------------------------------------------------------------------------------');

If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
    Print:=False;

    {печать персональных скидок по позиции}
    Assign(RealFile,Path.ToClient+st+'.skl');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    Space2:='                          ';
    If ii=0 Then
     Begin

      While Not(Eof(RealFile)) Do
       Begin
        Read(RealFile,E);
        If (E.Active) Then
Begin
 If Not Print Then
  Begin
   WriteLn(f,Space+GetClientField(FClient,st,0)+' ');
   Print:=True;
  End;

 SName:=GetIdField(FName,E.BazKod);
 Format(SName,CNAme);
 SZakupka:=BakGetField(FZakupka,E.BazKod,0);

     MyStr(StrToReal(SZakupka)*(1+StrToReal(E.Nazenka)/100),CZena,CMantissa,SpezZena);
     If StrToReal(SpezZena)<StrToReal(E.SpecZena) Then SpezZena:=E.SpecZena;
     MyStr(StrToReal(SpezZena),CZena,CMantissa,SpezZena);

 SDate:=E.DateC;
 SOp:=GetOperatorName(E.Caption);
 Format(SOp,CKto);
 Str(DateStringToDate(DateMask,FDate)-DateStringToDate(DateMask,SDate):CDate,SDelta);

 If StrToReal(SZakupka)>0.001 Then
 MyStr(100*(StrToReal(SpezZena)-StrToReal(SZakupka))/StrToReal(SZakupka),CLitr,CMantissa,SProz)
 Else
 SProz:='???';

 Writeln(f,Space2+SName+' '+E.BazKod+' '+SpeZZena+' '+SDAte+' '+SOp+' '+SDelta+' '+SProz);
End;{active}
       End;
      Close(RealFile);
     End;
    {конец печати персональных скидок по позиции}

    {печать персональных скидок по разделам}
    Assign(RealFileR,Path.ToClient+st+'.rsk');
    ii:=IOResult;
    Reset(RealFileR);
    ii:=IOResult;
    If ii=0 Then
     Begin
      While Not(Eof(RealFileR)) Do
       Begin
        Read(RealFileR,ER);
        If (Er.Active) Then
Begin
 If Not Print Then
  Begin
   WriteLn(f,Space+GetClientField(FClient,st,0)+' ');
   Print:=True;
  End;
 SProz[0]:=#0;

 If ER.Vid=0 Then
 Begin
  SpeZZena:='Наценка ';
  SProz:=Er.Nazenka
 End
 Else
  Begin
  SpeZZena:='Шкала '+Er.Shkala;
  Format(SpeZZena,CZena);
  End;

 SName:=GetRazdel(Er.BazKod);
 Format(SName,CNAme);

 SDate:=Er.DateC;
 SOp:=GetOperatorName(Er.Caption);
 Format(SOp,CKto);
 Str(DateStringToDate(DateMask,FDate)-DateStringToDate(DateMask,SDate):CDate,SDelta);


 Writeln(f,Space2+SName+' '+Er.BazKod+'    '+SpeZZena+' '+SDAte+' '+SOp+' '+SDelta+' '+SProz);
End;{active}
       End;
      Close(RealFiler);
     End;
    {конец печати персональных скидок по разделам}
If Print Then Writeln(f,Space+'---------------------------------------------------------------------------------------------');
 End;

Dispose(ClientList,Done);
Writeln(f,Space+NoCondensed[NPrint.Printer]);

Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'==============================================================================================');
Close(f);
NoInfo;

ViewAsText(Path.ToTemp+'pers.txt',True);
Report(Path.ToTemp+'pers.txt','',1,False,False,false);
End
end;



Function TestPrihod(l:Word;E:PPrihodType;Var SMake,SINN,OutNDS18,SNDS18,OUTNDS10,SNDS10,OUTNDS_:AllStr):Boolean;
Var c : Word;
    LocOutNDS18,LocSNDS18,LocOUTNDS10,LocSNDS10,LocOUTNDS_ : AllStr;
Begin
TestPrihod:=False;
SMake:=GetMakeField(FMAke,E^.Dat.MakeKod,E^.Dat.OperatorSelector);
SINN:=GetMakeField(FINN,E^.Dat.MakeKod,E^.Dat.OperatorSelector);;

OutNDS18[0]:=#0;
SNDS18[0]:=#0;
OUTNDS10[0]:=#0;
SNDS10[0]:=#0;
OUTNDS_[0]:=#0;

LocOutNDS18[0]:=#0;
LocSNDS18[0]:=#0;
LocOUTNDS10[0]:=#0;
LocSNDS10[0]:=#0;
LocOUTNDS_[0]:=#0;


If E^.DAt.Amount<1 Then Exit; {хз какой приход опт или розница}


If ((StrToInt(E^.Dat.PrihodElement[1].Input.DivisionS[1])=0) And (l=0)) Or
   ((StrToInt(E^.Dat.PrihodElement[1].Input.DivisionS[2])=0) And (l=1)) Then Exit;


If ((StrToInt(E^.Dat.PrihodElement[1].Input.DivisionS[1])>0) And (l=0)) Or
   ((StrToInt(E^.Dat.PrihodElement[1].Input.DivisionS[2])>0) And (l=1)) Or
   (l=2) Then
   Begin

     For c:=1 To E^.Dat.Amount Do
      Begin
LocOutNDS18[0]:=#0;
LocSNDS18[0]:=#0;
LocOUTNDS10[0]:=#0;
LocSNDS10[0]:=#0;
LocOUTNDS_[0]:=#0;

       if StrToInt(GetIDField(FINPack,E^.Dat.PrihodElement[c].BazKod))>0 then
       MyStr(StrToReal(E^.Dat.PrihodElement[c].Input.Zakupka)/StrToReal(GetIDField(FINPack,E^.Dat.PrihodElement[c].BazKod)),
	   CIZena,4,E^.Dat.PrihodElement[c].Input.Zakupka);


       Case StrToInt(GetIDField(FVidNDS,E^.Dat.PrihodElement[c].BazKod)) Of
       0{18}:Begin

              MyStr(StrToReal(E^.Dat.PrihodElement[c].Input.Zakupka)*
                        StrToInt(E^.Dat.PrihodElement[c].Input.Kol)*
              18/(100+18),CIZena,4,LocSNds18);



              MyStr(StrToReal(E^.Dat.PrihodElement[c].Input.Zakupka)*
                        StrToInt(E^.Dat.PrihodElement[c].Input.Kol)-
                    StrToReal(LocSNds18),CIZena,4,LocOutNDS18);

             End;

       1{10}:Begin
              MyStr(StrToReal(E^.Dat.PrihodElement[c].Input.Zakupka)*
                        StrToInt(E^.Dat.PrihodElement[c].Input.Kol)*
              10/(100+10),CIZena,4,LocSNds10);

              MyStr(StrToReal(E^.Dat.PrihodElement[c].Input.Zakupka)*
                        StrToInt(E^.Dat.PrihodElement[c].Input.Kol)-
                    StrToReal(LocSNds10),CIZena,4,LocOutNDS10);
             End;

       2{0} :Begin

              MyStr(StrToReal(E^.Dat.PrihodElement[c].Input.Zakupka)*
                        StrToInt(E^.Dat.PrihodElement[c].Input.Kol)
				    ,CIZena,4,LocOutNDS_);
             End;
       Else;
       End;

       MyStr(StrToReal(OutNDS18)+StrToReal(LocOutNDS18),CIZena,4,OutNDS18);
       MyStr(StrToReal(OutNDS10)+StrToReal(LocOutNDS10),CIZena,4,OutNDS10);
       MyStr(StrToReal(OutNDS_)+StrToReal(LocOutNDS_),CIZena,4,OutNDS_);
       MyStr(StrToReal(SNDS18)+StrToReal(LocSNDS18),CIZena,4,SNDS18);
       MyStr(StrToReal(SNDS10)+StrToReal(LocSNDS10),CIZena,4,SNDS10);


      End;{For}

   End;

testPrihod:=True;

End;



Procedure RecalcMrk(E:PSuperMarketType;Var OutNDS18,SNDS18,OUTNDS10,SNDS10,OUTNDS_:AllStr);
Var c : Word;
    LocOutNDS18,LocSNDS18,LocOUTNDS10,LocSNDS10,LocOUTNDS_ : AllStr;
Begin
OutNDS18[0]:=#0;
SNDS18[0]:=#0;
OUTNDS10[0]:=#0;
SNDS10[0]:=#0;
OUTNDS_[0]:=#0;

LocOutNDS18[0]:=#0;
LocSNDS18[0]:=#0;
LocOUTNDS10[0]:=#0;
LocSNDS10[0]:=#0;
LocOUTNDS_[0]:=#0;


If E^.DAt.Amount<1 Then Exit; {хз какой приход опт или розница}

   Begin

     For c:=1 To E^.Dat.Amount Do
      Begin
LocOutNDS18[0]:=#0;
LocSNDS18[0]:=#0;
LocOUTNDS10[0]:=#0;
LocSNDS10[0]:=#0;
LocOUTNDS_[0]:=#0;

     If E^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
       MyStr((StrToReal(E^.Dat.MarketElement[c].Input.Zena)*
       (StrToReal(E^.Dat.MarketElement[c].Input.Proz)))
       ,CZena,CMantissa,E^.Dat.MarketElement[c].Input.Zena){новая цена}
     Else
       MyStr((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
	  StrToReal(E^.Dat.MarketElement[c].Input.Skidka))
            ,CZena,CMantissa,E^.Dat.MarketElement[c].Input.Zena);{новая цена}



       Case StrToInt(GetIDField(FVidNDS,E^.Dat.MarketElement[c].BazKod)) Of
       0{18}:Begin
              MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena)*
                        StrToInt(E^.Dat.MarketElement[c].Input.Kol)*
              18/(100+18),CIZena,4,LocSNds18);


              MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena)*
                        StrToInt(E^.Dat.MarketElement[c].Input.Kol)-
                    StrToReal(LocSNds18),CIZena,4,LocOutNDS18);

             End;

       1{10}:Begin
              MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena)*
                        StrToInt(E^.Dat.MarketElement[c].Input.Kol)*
              10/(100+10),CIZena,4,LocSNds10);

              MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena)*
                        StrToInt(E^.Dat.MarketElement[c].Input.Kol)-
                    StrToReal(LocSNds10),CIZena,4,LocOutNDS10);
             End;

       2{0} :Begin

              MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena)*
                        StrToInt(E^.Dat.MarketElement[c].Input.Kol)
				    ,CIZena,4,LocOutNDS_);
             End;
       Else;
       End;

       MyStr(StrToReal(OutNDS18)+StrToReal(LocOutNDS18),CIZena,4,OutNDS18);
       MyStr(StrToReal(OutNDS10)+StrToReal(LocOutNDS10),CIZena,4,OutNDS10);
       MyStr(StrToReal(OutNDS_)+StrToReal(LocOutNDS_),CIZena,4,OutNDS_);
       MyStr(StrToReal(SNDS18)+StrToReal(LocSNDS18),CIZena,4,SNDS18);
       MyStr(StrToReal(SNDS10)+StrToReal(LocSNDS10),CIZena,4,SNDS10);


      End;{For}

   End;

End;





Procedure CalcBuchPrihod;
Var Mas : Maska5;
    txt : Text;
    NDS20,NDS10,NDS_ : Real;
    OutNDS18,OutNDS10,OutNDS_,SNDS18,SNDS10,SNDS_:AllStr;
    j,c : LongInt;
    l : Word;
    StartDate,StopDAte : Longint;
    CurDate,Start,Stop : TDAteString;
    List : PBox;
    R : TRect;
    prihodFile : PrihodFileType;
    E : PPrihodType;
    SINN,SMAke : AllStr;

Begin

If Not DatePeriodDialog(Start,Stop,False) Then
 Begin
  Exit;
 End;


 StartDate:=DateStringToDate(Datemask,Start);
 StopDate:=DateStringToDate(Datemask,Stop);


 Assign(txt,Path.ToTemp+'buchp.csv');
 i:=IoResult;
 Rewrite(txt);
 i:=IoResult;
    If i<>0 Then
     Begin
      MessageBox(^M+#3+'Ошибка создания '+Path.ToTemp+'buchp.csv Код:'+IntToStr(i,CKol),Nil,mfError+mfCAncelButton);
      Exit;
	End;


If FindParam('/BAKREGIM') Then
Begin
 l:=SelectSpecify(True,15);
 If l=3 Then Exit;
End
Else l:=2;



R.Assign(0, 0, 0, 0);
List := New(PBox, Init(R, 1, Nil));
List^.NewList(New(PMyCollection, Init(0,1)));

New(E,Init);

 For c:=startDAte To StopDate Do
  Begin

   CurDate:=DateToDAteString(DateMask,c);

   DInfoMsg('Обрабатываю приходы за '+CurDate+'...');

   Assign(prihodFile,PAth.ToPrihod+CurDate+'.prh');
   i:=IoResult;
   Reset(prihodFile);
   i:=IoResult;

   {MemCC(PAth.ToPrihod+CurDate+'.prh');}
   If i=0 Then
   Begin
    While Not(Eof(PrihodFile)) Do
     Begin
      ReadPrihod(PrihodFile,E);
      If TestPrihod(l,E,SMake,SINN,OutNDS18,SNDS18,OUTNDS10,SNDS10,OUTNDS_) Then
       Begin

        Writeln(txt,E^.DAt.Document+';'+
	                              +';'+
	               DosToWin(E^.Dat.Osn.NaklNumer)+';'+
	               E^.Dat.Osn.DateNakl+';'+
	               {дата оплаты счета фактуры}+';'+
	               E^.Dat.DateC+';'+
				DosToWin(SMAke)+';'+
				'_'+DosToWin(SINN)+';'+
				{страна происхождения и ГТД}';'+
				DosToWin(E^.DAt.SummaZakupka)+';'+
                    DosToWin(OutNds18)+';'+
				DosToWin(SNDS18)+';'+
                    DosToWin(OutNds10)+';'+
				DosToWin(SNDS10)+';'+
				DosToWin(OutNds_)+';');

       End;

     End;{While}

   i:=IoResult;
   Close(PrihodFile);
   i:=IoResult;
  End;
   NoInfoMsg;
  End;{For}



 Dispose(E,Done);
 Dispose(List,Done);

 i:=IoResult;
  Close(Txt);
 i:=IoResult;
 NoInfoMsg;


 MessageBox(^M+#3+'Формирование книги покупок завершено! Данные выведены в '+
 Path.ToTemp+'buchp.csv!',Nil,mfInformation+mfCancelButton);



End;


Procedure CalcBuchMarket;
Var Mas : Maska5;
    sf,txt : Text;
    NDS20,NDS10,NDS_ : Real;
    OutNDS18,OutNDS10,OutNDS_,SNDS18,SNDS10,SNDS_:AllStr;
    j,c : LongInt;
    l : Word;
    StartDate,StopDAte : Longint;
    CurDate,Start,Stop : TDAteString;
    List : PBox;
    R : TRect;
    prihodFile : MarketFileType;
    NDS,ItogoSkidka,Itogo : Real;
    E : PSuperMArketType;

Begin

If Not DatePeriodDialog(Start,Stop,False) Then
 Begin
  Exit;
 End;

 StartDate:=DateStringToDate(Datemask,Start);
 StopDate:=DateStringToDate(Datemask,Stop);


 Assign(txt,Path.ToTemp+'buchmrk.csv');
 i:=IoResult;
 Rewrite(txt);
 i:=IoResult;
    If i<>0 Then
     Begin
      MessageBox(^M+#3+'Ошибка создания '+Path.ToTemp+'buchmrk.csv Код:'+IntToStr(i,CKol),Nil,mfError+mfCAncelButton);
      Exit;
	End;



R.Assign(0, 0, 0, 0);
List := New(PBox, Init(R, 1, Nil));
List^.NewList(New(PMyCollection, Init(0,1)));


 New(E,Init);

 For c:=startDAte To StopDate Do
  Begin
   CurDate:=DateToDAteString(DateMask,c);

   DInfoMsg('Обрабатываю реализацию за '+CurDate+'...');

   Assign(prihodFile,PAth.ToMarket+CurDate+'.mrk');
   i:=IoResult;
   Reset(prihodFile);
   i:=IoResult;
    If i<>0 Then Continue;

    While Not(Eof(PrihodFile)) Do
     Begin
      ReadMarket(PrihodFile,E);
      If (Not(E^.DAt.Realiz) And (E^.Dat.DocSelector in [3,4])) Or
         ((E^.DAt.Realiz) And (E^.Dat.DocSelector in [6,7,8])) Then
        Begin

         RecalcMrk(E,OutNDS18,SNDS18,OUTNDS10,SNDS10,OUTNDS_);

         DelSpace(E^.Dat.SFNumer);
         If E^.Dat.SFNumer[0]=#0 Then E^.Dat.SFNumer:='???';


        Writeln(txt,E^.DAt.Document+';'+
	               E^.Dat.DateC+';'+
	                              +';'+
	               E^.Dat.SFNumer+';'+
	               E^.Dat.DateC+';'+
				DosToWin(GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector))+';'+
				'_'+DosToWin(GetClientField(FINN,E^.Dat.ClientKod,E^.Dat.OperatorSelector))+';'+
				{страна происхождения и ГТД}';'+
				DosToWin(E^.DAt.SummaZ)+';'+
                    DosToWin(OutNds18)+';'+
				DosToWin(SNDS18)+';'+
                    DosToWin(OutNds10)+';'+
				DosToWin(SNDS10)+';'+
				DosToWin(OutNds_)+';');



        End;

     End;{While}

   i:=IoResult;
   Close(PrihodFile);
   i:=IoResult;
   NoInfoMsg;
  End;{For}



 Dispose(E,Done);
 Dispose(List,Done);

 i:=IoResult;
  Close(Txt);
 i:=IoResult;
 NoInfoMsg;


 MessageBox(^M+#3+'Формирование книги продаж завершено! Данные выведены в '+
 Path.ToTemp+'buchmrk.csv!',Nil,mfInformation+mfCancelButton);





End;




Procedure CalcBuchMarket1;
Var Mas : Maska5;
    sf,txt : Text;
    NDS20,NDS10,NDS_ : Real;
    OutNDS18,OutNDS10,OutNDS_,SNDS18,SNDS10,SNDS_:AllStr;
    j,c : LongInt;
    l : Word;
    StartDate,StopDAte : Longint;
    CurDate,Start,Stop : TDAteString;
    List : PBox;
    R : TRect;
    prihodFile : MarketFileType;
    NDS,ItogoSkidka,Itogo : Real;
    E : PSuperMArketType;
    mm3 : Maska3;
    mm9 : Maska9;

Begin

If Not DatePeriodDialog(Start,Stop,False) Then
 Begin
  Exit;
 End;

 StartDate:=DateStringToDate(Datemask,Start);
 StopDate:=DateStringToDate(Datemask,Stop);


 If Not(SelectOperationAndDocument(mm3,mm9)) Then Exit;



 Assign(txt,Path.ToTemp+'buchmr.csv');
 i:=IoResult;
 Rewrite(txt);
 i:=IoResult;
    If i<>0 Then
     Begin
      MessageBox(^M+#3+'Ошибка создания '+Path.ToTemp+'buchmr.csv Код:'+IntToStr(i,CKol),Nil,mfError+mfCAncelButton);
      Exit;
	End;

R.Assign(0, 0, 0, 0);
List := New(PBox, Init(R, 1, Nil));
List^.NewList(New(PMyCollection, Init(0,1)));

 New(E,Init);

 For c:=startDAte To StopDate Do
  Begin
   CurDate:=DateToDAteString(DateMask,c);

   DInfoMsg('Обрабатываю реализацию за '+CurDate+'...');

   Assign(prihodFile,PAth.ToMarket+CurDate+'.mrk');
   i:=IoResult;
   Reset(prihodFile);
   i:=IoResult;
    If i<>0 Then Continue;

    While Not(Eof(PrihodFile)) Do
     Begin
      ReadMarket(PrihodFile,E);

  If (E^.Dat.Active) Then
   If mm3[E^.Dat.OperatorSelector+1]=1 Then
   If mm9[E^.Dat.DocSelector+1]=1 Then

  If ((Not(E^.Dat.Realiz)) Or ((E^.Dat.Realiz)And
  (E^.Dat.DocSelector in [5,6,7,8])))Then

{
      If (Not(E^.DAt.Realiz) And (E^.Dat.DocSelector in [3,4])) Or
         ((E^.DAt.Realiz) And (E^.Dat.DocSelector in [6,7,8])) Then
}
        Begin

         RecalcMrk(E,OutNDS18,SNDS18,OUTNDS10,SNDS10,OUTNDS_);

         DelSpace(E^.Dat.SFNumer);
         If E^.Dat.SFNumer[0]=#0 Then E^.Dat.SFNumer:='???';


        Writeln(txt,E^.DAt.Document+';'+
	               E^.Dat.DateC+';'+
	                              +';'+
	               E^.Dat.SFNumer+';'+
	               E^.Dat.DateC+';'+
				DosToWin(GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector))+';'+
				'_'+DosToWin(GetClientField(FINN,E^.Dat.ClientKod,E^.Dat.OperatorSelector))+';'+
				{страна происхождения и ГТД}';'+
				DosToWin(E^.DAt.SummaZ)+';'+
                    DosToWin(OutNds18)+';'+
				DosToWin(SNDS18)+';'+
                    DosToWin(OutNds10)+';'+
				DosToWin(SNDS10)+';'+
				DosToWin(OutNds_)+';');

        End;

     End;{While}

   i:=IoResult;
   Close(PrihodFile);
   i:=IoResult;
   NoInfoMsg;
  End;{For}



 Dispose(E,Done);
 Dispose(List,Done);

 i:=IoResult;
  Close(Txt);
 i:=IoResult;
 NoInfoMsg;


 MessageBox(^M+#3+'Формирование отчета завершено! Данные выведены в '+
 Path.ToTemp+'buchmr.csv!',Nil,mfInformation+mfCancelButton);





End;






End.