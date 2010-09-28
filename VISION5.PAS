{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Vision5;

Interface

Uses Glob,Dialogs,ServStr,Serv,Vision1,Drivers,Utils;

Procedure PrintNakl (As: DocumentEdit;CopyNkl : Byte);
Procedure PrintNaklSklad (As: DocumentEdit;CopyNkl : Byte);
Procedure PrintSKL2(Const Spis:PBox;Const M:MaskaNew; Const Assort,Sort:Word);
Procedure CreatPrimReport(ClientList:PBox;Op:Word);
Procedure CreatPersonalCartReport(ClientList:PBox;Op:Word);
procedure PrintingZeni(As : DocumentEdit;Vid:Byte);
Procedure PrintSKL1(Const Spis:PBox;Const M:MaskaNew; Const Assort,Sort:Word);
Procedure ChangeSkladKod;

Implementation

Uses Memory,App,DBEngine,MsgBox,Views,Propiss,TpDate,Access,Objects,Tools,Vision4,
     NetDBEng,Printers,Dos,VAlidate,Access3,Utils2, Vision7,DBIII;


Procedure FormNaklStore(Space :TDateString; As :DocumentEdit;Const E:PSuperMarketType;
                   Var Txt:Text);
Var l : Word;
    sc,s,ws,ws1 : string[150];
    Ss : TEnjoyStr;
    st : String[CMantissa];
    pp : String[CPack];
    TTT,ItogoS,NdsPos :Real;
    Local,R : Boolean;
    M : MaskaNew;
    c : Word;
    Dop : TDateString;
    Nalog:TDateString;
    tempSkidka,tt1,tt2,WspomSkidka,OutputSklad,InputSklad,koefficient:ALLStr;
    DrawSkidka: Boolean;
    Separator : AllStr;
    Symbol : ArtikulStr;
    SRegion : AllStr;
    Separator1,Separator2 : TMyString;
    Zag : Array [1..3]Of string[150];

Begin

   {R=True - первичный документ консигнации
   R=False - вторичный документ консигнации}
   If (E^.Dat.Realiz) And Not(E^.Dat.DocSelector in [5,6,7,8]) Then
   Begin
   R:=False;
   Dop:='    ';
   End
   Else
   Begin
   R:=True;
   Dop[0]:=#0;
   End;

   Writeln(Txt,Space+'Склад: ',{E^.Dat.Sklad}E^.Dat.SkladKod+
                  '  Оператор: '+E^.Dat.Caption+'  Агент: '+E^.Dat.AgentKod+' EYE & 1999');
   Writeln(txt);
   Writeln(Txt,Space+Dop+'      ОТБОРОЧНЫЙ ЛИСТ  N '+E^.Dat.Document+' от ',
   E^.Dat.DAteC+' ('+ E^.Dat.TimeC+')');

   Writeln(Txt,Space+Dop+'Получатель: ',GetClientField({FClient}FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
   E^.Dat.ClientKod+')');

   Separator1:='--------------------------------------------------------';;
   Writeln(txt,Space+Dop+Separator1);
   Writeln(txt,Space+Dop+' N  Код  Наименование товара        Колич   Упаковок Отд');
   Writeln(txt,Space+Dop+Separator1);
   Separator2:='  Сдал:________                 Принял:__________';;

   c:=0;
   WordToBitnew(c,M);
   For l:=1 To E^.Dat.Amount Do
    Begin
     If L=1 Then
     Writeln(txt,Space+Dop+'Отделение: ',E^.Dat.MarketElement[l].Input.DiviSionSNumber);

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
	   Writeln(txt,Space+Dop+st+Separator+s+' '+ws);
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
	   Writeln(txt,Space+Dop+st+Separator+S+' '+ws);
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
     s:=s+' '+ws+' ';

     {посчитали упаковки}
     pp:=CalcPack(E^.Dat.MarketElement[l].BazKod,E^.Dat.MarketElement[l].Input.Kol);
     DelSpace(Pp);
     RFormat(Pp,CPack);
     s:=s+''+pp;
     {добавили отделение}
     Str(E^.Dat.MarketElement[l].Input.DiviSionSNumber:3,ws);

     s:=Pitch[NPrint.Printer]+s+' '+ws+NoPitch[NPrint.Printer];

     Writeln(txt,Space+Dop+St+Separator+s);


     If (l+1)<=E^.Dat.Amount Then
      Begin
       If E^.Dat.MarketElement[l].Input.DiviSionSNumber<>
        E^.Dat.MarketElement[l+1].Input.DiviSionSNumber Then
          Begin
          Writeln(txt,Space+Dop+Separator1);
          Writeln(Txt);
          Writeln(txt,Space+Dop+Separator2);
          WriteLN(txt,Space+Dop+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
          Writeln(txt,Space+Dop+Separator1);
          Writeln(Txt,EndPage[NPrint.Printer]);
          Writeln(Txt,Space+Dop+'Склад: ',E^.Dat.SkladKod+
                  '  Оператор: '+E^.Dat.Caption+'  Агент: '+E^.Dat.AgentKod+' EYE & 1999');
   Writeln(txt);
   Writeln(Txt,Space+Dop+'      ОТБОРОЧНЫЙ ЛИСТ  N '+E^.Dat.Document+' от ',
   E^.Dat.DAteC+' ('+ E^.Dat.TimeC+')');
   Writeln(Txt,Space+Dop+'Получатель: ',GetClientField(FFFName{FClient},E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
   E^.Dat.ClientKod+')');
   Writeln(txt,Space+Dop+Separator1);
   Writeln(txt,Space+Dop+' N  Код  Наименование товара        Колич   Упаковок Отд');
   Writeln(txt,Space+Dop+Separator1);
   Writeln(txt,Space+Dop+'Отделение: ',E^.Dat.MarketElement[l+1].Input.DiviSionSNumber);
            End;

      End;



    End;{For}

          Writeln(txt,Space+Dop+Separator1);
          Writeln(Txt);
          Writeln(txt,Space+Dop+Separator2);
          WriteLN(txt,Space+Dop+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
     Writeln(txt,Space+'===========================================');
End;




Procedure PrintNakl (As: DocumentEdit;CopyNkl : Byte);
Var f : MarketFileType;
    E : PSuperMarketType;
    Copy,l : Word;
    NDS,z,ItogoSkidka,Itogo,
    NDS20,NDS10,NDS_ : Real;
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
    BArter : String[CMAntissa];
    Rek1 : Rekwiziti;
    Prom : Word;
    Vzw : Boolean;
Begin
 AInfo('Ищу документ...');
 Space:='      ';
 Assign(F,Path.ToMarket+As.D+'.mrk');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+As.D+'.mrk',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt1,Path.ToTemp+'temp.tmp');
 Assign(Txt,Path.ToTemp+'Nakladnp.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   NoInfo;
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'Nakladnp.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Close(Txt);

{ CloSe(Txt1); убрал иначе возникает ошибка}

 Find :=False;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMarket(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
  DelSpace(E^.Dat.Document);
  If  (ClearChar(E^.Dat.Document)=ClearChar(As.EditPosition)) And(E^.Dat.Active)
  And(E^.Dat.DateC=As.D) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Dispose(E,Done);
   Close(f);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
 End;
 Close(f);

NoInfo;



 VZw:=FAlse;
If FindParam('/DECVOZWRAT') Then
 Begin
 IF MessageBox(^M+#3+'Пересчитать с учетом возвратов?',nil,mfOkCAncel)=cmOk Then
  Begin
  RecalcFromVozwrat(E);
  Vzw:=True;
  End;
 End;



 Rewrite(Txt1);
 FormSf(False, E, Txt1, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_);
 Close(Txt1);
{Erase(Txt1);}
 Rewrite(Txt1);
 Append(txt);

   If E^.DAt.DocSelector in [3,4,6,8] Then
   Rek1:=RekSF
   Else
   Rek1:=Rek;

If E^.Dat.DocSelector<>0 Then{если не список}
Begin
Writeln(Txt,Space+'Маршрут: ',GetClientField(FMarsh,E^.Dat.ClientKod,E^.Dat.OperatorSelector));
Writeln(Txt,Space+'Склад: ',{E^.Dat.Sklad+}E^.Dat.SkladKod+
                  '  Оператор: '+E^.Dat.Caption+'  Агент: '+E^.Dat.AgentKod++' EYE & 1999');
Writeln(Txt1,Space+'Склад: ',{E^.Dat.Sklad}+E^.Dat.SkladKod+
                   '  Оператор: '+E^.Dat.Caption+'  Агент: '+E^.Dat.AgentKod++' EYE & 1999')
End
Else
Begin
If E^.Dat.OperatorSelector<>0 Then
Begin
Writeln(Txt,Space+'Склад: ',{E^.Dat.Sklad}E^.Dat.SkladKod+
                  '  Оператор: '+E^.Dat.Caption+'  Агент: '+E^.Dat.AgentKod+' EYE & 1999');
Writeln(Txt1,Space+'Склад: ',{E^.Dat.Sklad}E^.Dat.SkladKod+
                   '  Оператор: '+E^.Dat.Caption+'  Агент: '+E^.Dat.AgentKod++' EYE & 1999');
End
 Else Begin
        Writeln(txt);
        Writeln(txt1);
      End;
End;
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt,Space{+'Последние изменения:'}+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt1,Space{+'Последние изменения:'}+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
ItogoSkidka:=0;   Itogo:=0; {NDS:=0;}

If (E^.Dat.Realiz) And Not(E^.DAt.DocSelector in [5,6,7,8]) Then
Begin
Writeln(Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'СТАТУС: Документ оплачен'+NOBold[NPrint.Printer]+
NoDouble[NPrint.Printer]);
Writeln(Txt1,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'СТАТУС: Документ оплачен'+NOBold[NPrint.Printer]+
NoDouble[NPrint.Printer]);

SDoc:=E^.Dat.DocReal;
SDate:=E^.Dat.DocDate;
{что писать в шапке документа - для наклдных консигнации-первичный документ}
Logik:=True;
ws:=E^.Dat.DateC;
ws:=ClearChar(ws);
Writeln(Txt,Space+'                                                                      '+{Italic+}Bold[NPrint.Printer]+
Double[NPrint.Printer]+'НК '+ws+
  E^.Dat.Document{Real}+NOBold[NPrint.Printer]{+NoItalic}+NoDouble[NPrint.Printer]);
{Writeln(Txt,Space+Italic+Bold+'НК '+E^.Dat.DocReal+ ' от  '+E^.Dat.DocDate+NOBold+NoItalic);}
Writeln(Txt1,Space+'                                                                      '+{Italic+}Bold[NPrint.Printer]+
Double[NPrint.Printer]+'НК '+ws+
E^.Dat.Document{Real}+NOBold[NPrint.Printer]{+NoItalic}+NoDouble[NPrint.Printer]);

{Writeln(Txt1,Space+Italic+Bold+'ПО НАКЛАДНОЙ КОНСИГНАЦИИ: '+E^.Dat.DocReal+ ' от  '+E^.Dat.DocDate+NOBold+NoItalic);}
End
Else
 Begin
 If (E^.Dat.Realiz) Then
 Begin
  Writeln(Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'СТАТУС: Документ подлежит оплате'+NOBold[NPrint.Printer]+
  NoDouble[NPrint.Printer]);
  Writeln(Txt1,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'СТАТУС: Документ подлежит оплате'+NOBold[NPrint.Printer]+
  NoDouble[NPrint.Printer]);
 End;
  SDoc:=E^.Dat.Document;
  SDate:=E^.Dat.DateC;
  Logik:=False;
 End;

{
 If E^.Dat.DocSelector=5 Then
   If TestSf(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC) Then Inc(E^.Dat.DocSelector);
}

 If E^.Dat.OperatorSelector<2 Then Barter[0]:=#0
 Else Barter:='-Б';


 IF Vzw Then
  Begin
  If FindParam('/FULL') Then
  Begin
  Writeln(Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'ВНИМАНИЕ! ПРОИЗВОДИЛИСЬ ВОЗВРАТЫ'+NOBold[NPrint.Printer]+
  NoDouble[NPrint.Printer]);
  Writeln(Txt1,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'ВНИМАНИЕ! ПРОИЗВОДИЛИСЬ ВОЗВРАТЫ'+NOBold[NPrint.Printer]+
  NoDouble[NPrint.Printer]);
  End
  Else
   Begin
  Writeln(Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'ВЗВ'+NOBold[NPrint.Printer]+
  NoDouble[NPrint.Printer]);
  Writeln(Txt1,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'ВЗВ'+NOBold[NPrint.Printer]+
  NoDouble[NPrint.Printer]);
   End;
  End;


IF MessageBox(^M+#3+'Отсортировать по группам?',nil,mfOkCAncel)=cmOk Then
 Begin
  SortNklIdx(E);
 End;



Case E^.Dat.DocSelector Of
0:begin
   If MessageBox(#3^M+#3'Печатать список по документу N '+As.EditPosition{SDoc}+'?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
    Begin
     If E^.Dat.OperatorSelector=1 Then
     Begin
     Writeln(Txt,Space+'          Н А К Л А Д Н А Я (межскладская перевозка)  N '+E^.Dat.Document+BArter+ ' от ',
	E^.Dat.DAteC+' ('+
     E^.Dat.TimeC+')');
     Writeln(Txt1,Space+'          Н А К Л А Д Н А Я (межскладская перевозка)  N '+E^.Dat.Document+BArter+ ' от ',
     E^.Dat.DAteC+' ('+ E^.Dat.TimeC+')');
     Writeln(Txt,Space+'Поставщик: '+{GetClient(Rek.Kod,E^.Dat.OperatorSelector)++' ('+Rek.Kod+')');}
	Bold[NPrint.Printer]+GetMakeField(FClient,Rek1.Kod,1)+NoBold[NPrint.Printer]);
     Writeln(Txt1,Space+'Поставщик: '+{GetClient(Rek.Kod,E^.Dat.OperatorSelector)++' ('+Rek.Kod+')');}{Rek.Name}
     Bold[NPrint.Printer]+GetMakeField(FClient,Rek1.Kod,1)+NoBold[NPrint.Printer]);
     End
   Else
    Begin
    s:=SDoc{E^.Dat.Document};
    s:=Bold[NPrint.Printer]+S+NoBold[NPrint.Printer];
    Writeln(txt,Space+s+'                                                            '+SDate{E^.Dat.DateC}+
    ' ('+E^.Dat.TimeC+')');
    Writeln(txt1,Space+s+'                                                            '+SDate{E^.Dat.DateC}+
    ' ('+E^.Dat.TimeC+')');
    End;

   If E^.Dat.OperatorSelector=1 Then
   Begin
   Writeln(Txt,Space+'Получатель: ',GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
   E^.Dat.ClientKod+')');
   Writeln(Txt1,Space+'Получатель: ',GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
   E^.Dat.ClientKod+')');
   End
   Else
   Begin
   Writeln(Txt,Space+'Получатель: ',{GetClient(E^.Dat.ClientKod)+}' ('+E^.Dat.ClientKod+')');
   Writeln(Txt1,Space+'Получатель: ',{GetClient(E^.Dat.ClientKod)+}' ('+E^.Dat.ClientKod+')');
   End;
   FormNakl(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,True);
   FormNakl(Space,False,As, E, Txt1, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,False);
   Close(txt);
   Close(txt1);
{  If Status=DocPrint Then Status:=DocNormal;}
   Report(Path.ToTemp+'Nakladnp.txt',Path.ToTemp+'temp.tmp',CopyNkl,True,Logik,false);

   If FindParam('/AUTOOTBORKA') Then
   Begin
   If MessageBox(^M+#3'Печатать отборочный лист по документу?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
    Begin
    Rewrite(txt);
    FormNaklStore(Space,As, E, Txt);
    Copy:=NPrint.FullName;
    NPrint.FullName:=1;
    Close(txt);
    Report(Path.ToTemp+'Nakladnp.txt','',1,False,Logik,false);
    End;
   End
    Else
     Begin
      PrintNaklSklad(As,1);
     End;

   If ((PrintSertifDoc[1]=1)And(E^.DAt.OperatorSelector=1)) Or
      ((PrintSertifDoc[2]=1)And(E^.DAt.OperatorSelector=0)) Then
   If MessageBox(#3^M+#3'Печатать приложение к документу?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
   Begin
    Rewrite(txt);
    FormPril( E, Txt);
    Close(txt);
    Report(Path.ToTemp+'Nakladnp.txt','',1,False,Logik,false);
   End;
   Dispose(E,Done);

   End
   Else
    Begin
     Close(txt);
     Close(txt1);
     Dispose(E,Done);

{     If Status=DocPrint Then Status:=DocNormal;}
     Exit;
    End;
  end;{список}
1:begin
    s:=E^.Dat.Document;
    Writeln(Txt ,Space+SDoc+BArter+'                        Т О В А Р Н Ы Й  Ч Е К  от '+SDAte{E^.Dat.DateC}+' ('+
    E^.Dat.TimeC+')');
    Writeln(Txt1,Space+SDoc+BArter+'                        Т О В А Р Н Ы Й  Ч Е К  от '+SDate{E^.Dat.DateC}+' ('+
    E^.Dat.TimeC+')');
(*    Writeln(Txt,Space+'Получатель: ',{GetClient(E^.Dat.ClientKod)+}' ('+E^.Dat.ClientKod+')');
    Writeln(Txt1,Space+'Получатель: ',{GetClient(E^.Dat.ClientKod)+}' ('+E^.Dat.ClientKod+')');
*)
    Writeln(Txt,Space+'Поставщик: '+Bold[NPrint.Printer]+Rek1.Name+NoBold[NPrint.Printer]);
    Writeln(Txt1,Space+'Поставщик: '+Bold[NPrint.Printer]+Rek1.Name+NoBold[NPrint.Printer]);
    Writeln(txt,Space+'Адрес: '+Rek1.Adress);
    Writeln(txt1,Space+'Адрес: '+Rek1.Adress);
    Writeln(txt,Space+'Тел.офиса: '+Bold[NPrint.Printer]+Rek1.Telefon+NoBold[NPrint.Printer]);
    Writeln(txt1,Space+'Тел.офиса: '+Bold[NPrint.Printer]+Rek1.Telefon+NoBold[NPrint.Printer]);

    If Rek1.Svidetelstvo[0]<>#0 Then
    Begin
    Writeln(txt,Space+'Свидетельство:'+Rek1.Svidetelstvo);
    Writeln(txt1,Space+'Свидетельство:'+Rek1.Svidetelstvo);
    End;
{
    If Rek1.LizensiaRoznSig[0]<>#0 Then
    Begin
    Writeln(txt,Space+' N розн.лицензии на сигареты:'+Rek1.LizensiaRoznSig);
    Writeln(txt1,Space+' N розн.лицензии на сигареты:'+Rek1.LizensiaRoznSig);
    End;
    If Rek1.LizensiaRoznPiv[0]<>#0 Then
    Begin
    Writeln(txt,Space+' N розн.лицензии на пиво:'+Rek1.LizensiaRoznPiv);
    Writeln(txt1,Space+' N розн.лицензии на пиво:'+Rek1.LizensiaRoznPiv);
    End;
}
    FormNakl(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,True);
    FormNakl(Space,False,As, E, Txt1, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,False);
    Close(txt);
    Close(txt1);
   If MessageBox(#3^M+#3'Печатать товарный чек по документу N '+As.EditPosition+'?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
   Begin
{    If Status=DocPrint Then Status:=DocNormal;}
    Report(Path.ToTemp+'Nakladnp.txt',Path.ToTemp+'temp.tmp',CopyNkl,True,Logik,false);
   End;



   If FindParam('/AUTOOTBORKA') Then
   Begin
   If MessageBox(^M+#3'Печатать отборочный лист по документу?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
    Begin
    Rewrite(txt);
    FormNaklStore(Space,As, E, Txt);
    Copy:=NPrint.FullName;
    NPrint.FullName:=1;
    Close(txt);
    Report(Path.ToTemp+'Nakladnp.txt','',1,False,Logik,false);
    End;
   End
    Else
     Begin
      PrintNaklSklad(As,1);
     End;

   If ((PrintSertifDoc[2]=1)And(E^.DAt.OperatorSelector=0)) Then
   If MessageBox(#3^M+#3'Печатать приложение к документу?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
   Begin
    Rewrite(txt);
    FormPril( E, Txt);
    Close(txt);
    Report(Path.ToTemp+'Nakladnp.txt','',1,False,Logik,false);
   End;


   Dispose(E,Done);
{    If Status=DocPrint Then Status:=DocNormal;}
  end;{товарный чек}
2:begin
    s:=E^.Dat.Document;
    Writeln(Txt ,Space+SDoc+BArter+'                        Т О В А Р Н Ы Й  Ч Е К  от '+SDAte{E^.Dat.DateC}+' ('+
    E^.Dat.TimeC+')');
    Writeln(Txt1,Space+SDoc+BArter+'                        Т О В А Р Н Ы Й  Ч Е К  от '+SDate{E^.Dat.DateC}+' ('+
    E^.Dat.TimeC+')');
    (* убрал по просьбе Юрия Григорьевича
    Writeln(Txt,Space+'                   Н А К Л А Д Н А Я  N '+SDoc{As.EditPosition}+' от '+SDate{As.D}+' ('+
    E^.Dat.TimeC+')');
    Writeln(Txt1,Space+'                   Н А К Л А Д Н А Я  N '+SDoc{As.EditPosition}+' от '+SDate{As.D}+' ('+
    E^.Dat.TimeC+')');
    *)
    Writeln(Txt,Space+'Получатель: ', GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
    E^.Dat.ClientKod+')');
    Writeln(Txt1,Space+'Получатель: ',GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
    E^.Dat.ClientKod+')');
    Writeln(Txt,Space+'Поставщик: '+Bold[NPrint.Printer]+Rek1.Name+NoBold[NPrint.Printer]);
    Writeln(Txt1,Space+'Поставщик: '+Bold[NPrint.Printer]+Rek1.Name+NoBold[NPrint.Printer]);
    Writeln(txt,Space+'Адрес: '+Rek1.Adress);
    Writeln(txt1,Space+'Адрес: '+Rek1.Adress);
    Writeln(txt,Space+'Тел.офиса: '+Bold[NPrint.Printer]+Rek1.Telefon+NoBold[NPrint.Printer]);
    Writeln(txt1,Space+'Тел.офиса: '+Bold[NPrint.Printer]+Rek1.Telefon+NoBold[NPrint.Printer]);

    If Rek1.Svidetelstvo[0]<>#0 Then
    Begin
    Writeln(txt,Space+'Свидетельство:'+Rek1.Svidetelstvo);
    Writeln(txt1,Space+'Свидетельство:'+Rek1.Svidetelstvo);
    End;


    FormNakl(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,True);
    FormNakl(Space,False,As, E, Txt1, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,False);
    Close(txt);
    Close(txt1);
   If MessageBox(#3^M+#3'Печатать накладную по документу N '+As.EditPosition+'?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
   Begin
{    If Status=DocPrint Then Status:=DocNormal;}
    Report(Path.ToTemp+'Nakladnp.txt',Path.ToTemp+'temp.tmp',CopyNkl,True,Logik,false);
   End;

   If FindParam('/AUTOOTBORKA') Then
   Begin
   If MessageBox(^M+#3'Печатать отборочный лист по документу?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
    Begin
    Rewrite(txt);
    FormNaklStore(Space,As, E, Txt);
    Copy:=NPrint.FullName;
    NPrint.FullName:=1;
    Close(txt);
    Report(Path.ToTemp+'Nakladnp.txt','',1,False,Logik,false);
    End;
   End
    Else
     Begin
      PrintNaklSklad(As,1);
     End;


   If Not(E^.Dat.Realiz) Then
   Begin
   If (Test3000(e^.Dat.ClientKod,E^.Dat.SummaZ)) Then
   Begin
    If MessageBox(#3^M+#3'Печатать приходный кассовый ордер?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
     Begin
      Rewrite(txt);
      PrintOrder(E,NDS,NDS,Itogo,Txt);
      Close(txt);
      {If Status=DocPrint Then Status:=DocNormal;}
      Report(Path.ToTemp+'Nakladnp.txt','',NPrint.CopyOrder,False,Logik,false);
     End;
   End
   Else MessageBox(^M+#3'Сумма превышает '+RealToStr(PrihodMax,CZena,CMantissa)+' рублей!'^M
   +#3'Разбивайте приходник вручную !!!',Nil,MfWarning+mfCancelButton);
{   If Status=DocPrint Then Status:=DocNormal;}
   End;

   If ((PrintSertifDoc[2]=1)And(E^.DAt.OperatorSelector=0)) Then
   If MessageBox(#3^M+#3'Печатать приложение к документу?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
   Begin
    Rewrite(txt);
    FormPril( E, Txt);
    Close(txt);
    Report(Path.ToTemp+'Nakladnp.txt','',1,False,Logik,false);
   End;


   Dispose(E,Done);
  end;{накладная с приходником}
5,6,7,8
  :begin
    If E^.DAt.DocSelector in [6,8] Then
    Begin
     Writeln(Txt,Space+'            Н А К Л А Д Н А Я   N '+E^.DAt.NaklNumer+BArter+'/'+As.EditPosition+BArter+' от '+As.D+
	' ('+E^.Dat.TimeC+')');
     Writeln(Txt1,Space+'            Н А К Л А Д Н А Я   N '+E^.DAt.NaklNumer+BArter+'/'+As.EditPosition+BArter+' от '+As.D+
	' ('+E^.Dat.TimeC+')');
    End
    Else
    Begin
     Writeln(Txt ,Space+As.EditPosition+BArter+'                        Т О В А Р Н Ы Й  Ч Е К  от '+As.D{E^.Dat.DateC}+' ('+
     E^.Dat.TimeC+')');
     Writeln(Txt1,Space+As.EditPosition+BArter+'                        Т О В А Р Н Ы Й  Ч Е К  от '+As.D{E^.Dat.DateC}+' ('+
     E^.Dat.TimeC+')');
    End;

    If E^.DAt.DocSelector in [6,8] Then
    Begin
    Writeln(Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'Протокол приема-передачи к договору N: ',
    GetClientField(FNDogovor,E^.Dat.ClientKod,
    E^.Dat.OperatorSelector)+ NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
    Writeln(Txt1,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'Протокол приема-передачи к договору N: ',
    GetClientField(FNDogovor,E^.Dat.ClientKod,
    E^.Dat.OperatorSelector)+ NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);

    Write(Txt,Space+'Выдано на консигнацию: ', GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
    E^.Dat.ClientKod+')');

    Write(Txt1,Space+'Выдано на консигнацию: ',GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
    E^.Dat.ClientKod+')');

    Writeln(Txt{,'    '+Bold[NPrint.Printer]+'Срок консигнации до: '+DateToDateString(DateMask,E^.Dat.Srok)+
    NoBold[NPrint.Printer]});
    Writeln(Txt1{,'    '+Bold[NPrint.Printer]+'Срок консигнации до: '+DateToDateString(DateMask,E^.Dat.Srok)+
    NoBold[NPrint.Printer]});
    End;

    Writeln(Txt,Space+'Поставщик: '+Bold[NPrint.Printer]+Rek1.Name+NoBold[NPrint.Printer]);
    Writeln(Txt1,Space+'Поставщик: '+Bold[NPrint.Printer]+Rek1.Name+NoBold[NPrint.Printer]);
    Writeln(txt,Space+'Адрес: '+Rek1.Adress);
    Writeln(txt1,Space+'Адрес: '+Rek1.Adress);

    If Rek1.Svidetelstvo[0]<>#0 Then
    Begin
    Writeln(txt,Space+'Свидетельство:'+Rek1.Svidetelstvo);
    Writeln(txt1,Space+'Свидетельство:'+Rek1.Svidetelstvo);
    End;
    Writeln(txt);
    Writeln(txt1);
    Writeln(txt,Space+Bold[NPrint.Printer]+'Тел.офиса: '+Rek1.Telefon+NoBold[NPrint.Printer]);
    Writeln(txt1,Space+Bold[NPrint.Printer]+'Тел.офиса: '+Rek1.Telefon+NoBold[NPrint.Printer]);
    Writeln(txt);
    Writeln(txt1);

    FormNakl(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,True);
    FormNakl(Space,False,As, E, Txt1, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,False);
    Close(txt);
    Close(txt1);
    If MessageBox(#3^M+#3'Печатать накладную по документу консигнации N '+As.EditPosition+'?',Nil,
    mfConfirmation+mfOkCancel)=CmOk Then
   Begin
{    If Status=DocPrint Then Status:=DocNormal;}
    Report(Path.ToTemp+'Nakladnp.txt',Path.ToTemp+'temp.tmp',CopyNkl,True,False,false);
   End;

   If FindParam('/AUTOOTBORKA') Then
   Begin
   If MessageBox(^M+#3'Печатать отборочный лист по документу?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
    Begin
    Rewrite(txt);
    FormNaklStore(Space,As, E, Txt);
    Copy:=NPrint.FullName;
    NPrint.FullName:=1;
    Close(txt);
    Report(Path.ToTemp+'Nakladnp.txt','',1,False,Logik,false);
    End;
   End
    Else
     Begin
      PrintNaklSklad(As,1);
     End;

   { убрано 15/09/2004 тк надовыдавать СФ на товареый чек}If E^.Dat.DocSelector in [6,7,8]
    Then
   Begin
    If MessageBox(#3^M+#3'Печатать С/Ф?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
        Begin
         Rewrite(txt);
         FormSf(False, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_);
         Close(txt);
{        If Status=DocPrint Then Status:=DocNormal;}
         Report(Path.ToTemp+'Nakladnp.txt','',NPrint.CopySf,False,Logik,false);
        End
   End;

   If ((PrintSertifDoc[2]=1)And(E^.DAt.OperatorSelector=0)) Then
   If MessageBox(#3^M+#3'Печатать приложение к документу?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
   Begin
    Rewrite(txt);
    FormPril( E, Txt);
    Close(txt);
    Report(Path.ToTemp+'Nakladnp.txt','',1,False,Logik,false);
   End;


   If E^.Dat.DocSelector in [6,7,8]{TestSf(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC)} Then
   If MessageBox(#3^M+#3'Печатать ТТН по документу N '+As.EditPosition+'?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
   Begin
    Space:='   ';
    Rewrite(txt);
    Rewrite(txt1);
    FormNaklTTN(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,True,False);
    NPrint.FullName:=1;
    FormNaklTTN(Space,False,As, E, Txt1, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,False,False);
    NPrint.FullName:=Copy;
    Close(txt);
    Close(txt1);
    Report(Path.ToTemp+'Nakladnp.txt',Path.ToTemp+'temp.tmp',CopyNkl,True,Logik
    ,false);
   End;



   Dispose(E,Done);
  end;{реализация}
3,4:begin

    If E^.Dat.Realiz Then
          Begin
           If Not(Password(3)) Then
                Begin
                 Close(txt1);
                 Close(txt);
                 Dispose(E,Done);
                 Exit;
                End;
          End;

    If E^.Dat.DocSelector=4 Then
    Begin
        Writeln(txt,Space+'Платежное поручение N: '+E^.Dat.Bn.NPlat+' от '+E^.Dat.Bn.Date);
        Writeln(txt,Space+'Банк: '+E^.Dat.Bn.BAnk);
        Writeln(txt1,Space+'Платежное поручение N: '+E^.Dat.Bn.NPlat+' от '+E^.Dat.Bn.Date);
        Writeln(txt1,Space+'Банк: '+E^.Dat.Bn.BAnk);
    End;

    s:=E^.Dat.Document;
    (*
    Writeln(Txt ,Space+SDoc+BArter+'                        Т О В А Р Н Ы Й  Ч Е К  от '+SDAte{E^.Dat.DateC}+' ('+
    E^.Dat.TimeC+')');
    Writeln(Txt1,Space+SDoc+BArter+'                        Т О В А Р Н Ы Й  Ч Е К  от '+SDate{E^.Dat.DateC}+' ('+
    E^.Dat.TimeC+')');
    *)
    Writeln(Txt,Space+'                   Н А К Л А Д Н А Я  N '+E^.Dat.NaklNumer+Barter+'/'+SDoc+{As.EditPosition}+' от '+
    SDate{As.D}+' ('+E^.Dat.TimeC+')');
    Writeln(Txt1,Space+'                   Н А К Л А Д Н А Я  N '+E^.Dat.NaklNumer+Barter+'/'+SDoc+{As.EditPosition}+' от '+
    SDate{As.D}+' ('+E^.Dat.TimeC+')');

    Writeln(Txt,Space+'Получатель: ',GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+E^.Dat.ClientKod+
    ')');
    Writeln(Txt1,Space+'Получатель: ',GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+E^.Dat.ClientKod+
    ')');
    Write(Txt,Space+'Поставщик: '+Bold[NPrint.Printer]+Rek1.Name+NoBold[NPrint.Printer]);
    Write(Txt1,Space+'Поставщик: '+Bold[NPrint.Printer]+Rek1.Name+NoBold[NPrint.Printer]);
    Writeln(txt,'   '+'Адрес: '+Rek1.Adress);
    Writeln(txt1,'   '+'Адрес: '+Rek1.Adress);
    If Rek1.Svidetelstvo[0]<>#0 Then
    Begin
    Writeln(txt,Space+'Свидетельство:'+Rek1.Svidetelstvo);
    Writeln(txt1,Space+'Свидетельство:'+Rek1.Svidetelstvo);
    End;
    FormNakl(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,True);
    FormNakl(Space,False,As, E, Txt1, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,False);
    Close(txt);
    Close(txt1);

   If MessageBox(#3^M+#3'Печатать накладную по документу N '+As.EditPosition+'?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
   Begin
{    If Status=DocPrint Then Status:=DocNormal;}
    Report(Path.ToTemp+'Nakladnp.txt',Path.ToTemp+'temp.tmp',CopyNkl,True,Logik,false);
   End;

   If FindParam('/AUTOOTBORKA') Then
   Begin
   If MessageBox(^M+#3'Печатать отборочный лист по документу?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
    Begin
    Rewrite(txt);
    FormNaklStore(Space,As, E, Txt);
    Copy:=NPrint.FullName;
    NPrint.FullName:=1;
    Close(txt);
    Report(Path.ToTemp+'Nakladnp.txt','',1,False,Logik,false);
    End;
   End
    Else
     Begin
      PrintNaklSklad(As,1);
     End;

   If Not(E^.Dat.Realiz) Then
   If E^.Dat.DocSelector<>4 Then
   Begin
   If Test3000(e^.Dat.ClientKod,E^.Dat.SummaZ) Then
   Begin
   If MessageBox(#3^M+#3'Печатать приходный кассовый ордер?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
   Begin
    Rewrite(txt);
    PrintOrder(E,NDS,NDS,Itogo,Txt);
    Close(txt);
{    If Status=DocPrint Then Status:=DocNormal;}
    Report(Path.ToTemp+'Nakladnp.txt','',NPrint.CopyOrder,False,Logik,false);
   End;
   End
   Else
   MessageBox(^M+#3'Сумма превышает '+RealToStr(PrihodMax,CZena,CMantissa)+' рублей!'^M

   +#3'Разбивайте приходник вручную !!!',Nil,MfWarning+mfCancelButton);
   End;

   If MessageBox(#3^M+#3'Печатать С/Ф?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
   Begin
    Rewrite(txt);
    FormSf(False, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_);
    Close(txt);
    Report(Path.ToTemp+'Nakladnp.txt','',NPrint.CopySf,False,Logik,false);
   End;

   If ((PrintSertifDoc[2]=1)And(E^.DAt.OperatorSelector=0)) Then
   If MessageBox(#3^M+#3'Печатать приложение к документу?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
   Begin
    Rewrite(txt);
    FormPril( E, Txt);
    Close(txt);
    Report(Path.ToTemp+'Nakladnp.txt','',1,False,Logik,false);
   End;

   If MessageBox(#3^M+#3'Печатать ТТН по документу N '+As.EditPosition+'?',Nil,mfConfirmation+mfOkCancel)=CmOk Then
   Begin
    Space:='   ';
    Rewrite(txt);
    Rewrite(txt1);
    FormNaklTTN(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,True,False);
    NPrint.FullName:=1;
    FormNaklTTN(Space,False,As, E, Txt1, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,False,False);
    NPrint.FullName:=Copy;
    Close(txt);
    Close(txt1);
    Report(Path.ToTemp+'Nakladnp.txt',Path.ToTemp+'temp.tmp',CopyNkl,True,Logik,false);
   End;


   Dispose(E,Done);
    end;{с/ф накладная и приходник}
Else;
End;
End;


Procedure PrintSKL2(Const Spis:PBox;Const M:MaskaNew; Const Assort,Sort:Word);
Const Space='';
VAr sklFile : BazFileType;
    skl : pBazType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    F : Boolean;
    TArt,Zena,Zakupka,Lob:String[CZena];
    Max,Min : TDAteString;
    jk,l,c : Word;
    txt : Text;
    Kb : TDAteString;
    wws,ws,s : string[150];
    R,R1 : TRect;
    lk : LongInt;
    ttt,TempList, WspomList :PBox;
    Regim : LongInt;
    sh,VidPrize : Word;
    Mas : Maska24;
    Region : Word;
    SSS : Boolean;
Begin
c:=IOResult;
Assign(txt,Path.ToTemp+'skidki2.txt');
Rewrite(txt);
c:=IOResult;

Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+' Оператор:'+CurrentPassword);
Writeln(Txt,Space+'  ТАБЛИЦЫ РАЗНОГЛАСИЙ РУЧНЫХ СКИДОК на '+FDate);

Case Region Of
0:Writeln(Txt,Space+'Регион: Офис');
1:Writeln(Txt,Space+'Регион: Город');
2:Writeln(Txt,Space+'Регион: Область');
3:Writeln(Txt,Space+'Регион: Резерв');
Else;
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
      Close(Txt);
      Dispose(TempList,Done);
      Exit;
     End;

   Else;
   End;



DInfo('Минуточку...');




 For jk:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then wws:=Copy(TempList^.GetText(jk,TempList^.List^.Count),1,CRazdelKod)
  Else
  wws:=Copy(TempList^.GetText(jk,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);

  If TestRazdel(wws,M,Assort,2) Then
Begin

   Writeln(txt);
   Writeln(txt,Space+'   Раздел:'+GetRazdel(wws));

   s:='Код   Наименование             З/Цена   Р/Ц Позиц. Раздел';

  s[0]:=Chr(Ord(s[0]));

 ws[0]:=#0;
 For sh:=1 To Ord(s[0]) Do
  Begin
    ws[sh]:='_';
    ws[0]:=Chr(sh);
  End;



   Writeln(txt,Space+ws);
   Writeln(txt,Space+s);
   Writeln(txt,Space+ws);
                     {12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789}
                     {12345 12345678901234567890123456 12345678 12345 12345 12345 12345 12345 12345 12345 12345}
   Assign(SklFile,Path.ToNAme+wws+'.id');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;
   If c<>0 Then
    Begin
     Close(txt);
     MessageBox(^M+#3'Ошибка доступа к файлу '+Path.ToName+RazdelElement.Kod+'.id',Nil,mfError+mfCancelButton);
     Exit;
    End;

   R1.Assign(0,0,0,0);
   ttt := New(PBox, Init(R1, 1, Nil));
   ttt^.NewList(New(PTextCollection, Init(0,1)));

   New(Skl,Init);

   While Not(Eof(sklFile)) Do
Begin
     ReadBazPointer(SklFile,Skl);
     If ((StrToInt(BakGetField(FKol,Skl^.Dat.BAzKod,0))>0) and (Assort=0)) Or
         (Assort=1) Then
     {фильтр количества}
Begin
     s[0]:=#0;
     ws[0]:=#0;
     ws := Skl^.Dat.Name;
     Format(ws,CNAme-4);
     MyStr(StrtoReal(BakGetField(FZakupka,Skl^.Dat.BAzKod,0)),CZena-1,CMantissa,Zakupka);
     MyStr(StrtoReal(BakGetField(FRZena,Skl^.Dat.BAzKod,0)),CZena-1,CMantissa,Lob);

     s:=Skl^.Dat.BazKod+' '+ws+' '+Zakupka+' '+Lob;

     SSS:=False;


     Kb:=GetRazdelNaz(Skl^.Dat.BazKod);
     MyStr(StrToReal(KB),CLitr+1,CMAntissa,KB);

       If Abs(StrToreal(Skl^.Dat.MinNazenka)-StrToReal(KB))>0.01 Then
       Begin
         SSS:=True;
       End;
        MyStr(StrToReal(Skl^.Dat.MinNazenka),CLitr+1,CMantissa,Skl^.Dat.MinNazenka);
        s:=s+' '+Skl^.Dat.MinNazenka+' '+Kb;

    If Sort > 0 Then
    Begin
     System.Delete(s,1,CArtikul);
     s:=s+Skl^.Dat.BazKod;
    End;

    If SSS Then
    Begin
     ttt^.List^.Insert(NewStr(s));
     ttt^.SetRange(ttt^.List^.Count);
    End;

End;{тест количества}
End;{While}

      Dispose(Skl,Done);

     If ((ttt^.List^.Count-1)>=0) Then
      For lk:=0 To ttt^.List^.Count-1 Do
      Begin
       s:=ttt^.GetText(lk,ttt^.List^.Count);
       If Sort>0 Then
       Begin
        TArt:=Copy(s,Ord(s[0])-CArtikul+1,CArtikul);
        Delete(s,Ord(s[0])-CArtikul+1,CArtikul);
       End;
       Writeln(txt,Space+TArt+s);
      End;{for печати}

    Dispose(ttt,Done);
    c:=IoResult;
    Close(SklFile);

   End;{TestRazdel}
End;{For}

c:=IOResult;
Dispose(TempList,Done);
Writeln(txt);
Writeln(txt);
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
Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt,Space+'===========================================================');
Close(txt);
NoInfo;
ViewAsText(Path.ToTemp+'Skidki2.txt',True);
End;




Procedure CreatPrimReport(ClientList:PBox;Op:Word);
Var R : TRect;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    s,w,w1,st : AllStr;
    ws : TMyString;
    ii,c,t1,t2 : LongInt;
    r1,r2 , Rsf,RsfSkid :Real;
    f : Text;
    {DateMask : TDateString;}
    Space : AllStr;
    Tip,Vid,Realno : Word;
    Criminal : Boolean;
    CriminalSumma : Real;
begin
Assign(f,Path.ToTemp+'clientot.txt');

c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0)Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path.ToTemp+'clientot.txt!!',Nil,mfError+mfCancelButton);
  Exit;
 End;

Space:='     ';

Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword);
Writeln(f,Space+'СПРАВКА ПО ПЕРСОНАЛЬНЫМ СООБЩЕНИЯМ В КАРТОЧКАХ КЛИЕНТОВ'+FDate+' ('+Times+')');
Writeln(f,Space+'------------------------------------------------------------------');
Writeln(f,Space+'       Клиент        Код  Сообщение                              ');
{                12345678901234567890|1234|1234567890123456789012345678901234567890}
Writeln(f,Space+'------------------------------------------------------------------');

AInfo('Минуточку...');

If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    S := Copy(st,1+CClient+1,CClientKod);
    s:=GetClientField(FMessages,s,Op);
    While Pos('│',st)>0 Do St[Pos('│',st)]:=' ';
    Writeln(f,Space+st+' '+s);
   End;
 End;
Writeln(f,Space+'------------------------------------------------------------------');
Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'==================================================================');
Close(f);

NoInfo;
ViewAsText(Path.ToTemp+'clientot.txt',True);
Report(Path.ToTemp+'clientot.txt','',1,False,False,false);
end;



Procedure CreatPersonalCartReport(ClientList:PBox;Op:Word);
Var R : TRect;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    s,w,w1,st : AllStr;
    ws : TMyString;
    ii,c,t1,t2 : LongInt;
    r1,r2 , Rsf,RsfSkid :Real;
    f : Text;
    {DateMask : TDateString;}
    Space : AllStr;
    Tip,Vid,Realno : Word;
    Criminal : Boolean;
    CriminalSumma : Real;
    jk : Word;
    fff : File Of ToVArClientType;
    TovEl : ToVArClientType;
    SArt : ArtikulStr;
    SNAme : AllStr;
    SRZena,SZakupka,SProz,SSpecZena : TDAteString;
    Count : Word;
    Regim : Word;
begin
Regim:=SelectImport(24);
If Regim=2 Then Exit;

Assign(f,Path.ToTemp+'clientpc.txt');
c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0)Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path.ToTemp+'clientpc.txt!!',Nil,mfError+mfCancelButton);
  Exit;
 End;

Space:='     ';

Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword);
Writeln(f,Space+'СПРАВКА ПО ПЕРСОНАЛЬНЫМ ценам КЛИЕНТОВ'+FDate+' ('+Times+')');

AInfo('Минуточку...');

If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    S := Copy(st,1+CClient+1,CClientKod);

    Assign(fff,Path.ToClient+s+'.skl');
    jk:=IOResult;
    Reset(fff);
    jk:=IOResult;
    If jk=0 Then
     Begin
      If FileSize(FFF)>0 Then
      Begin
      Writeln(f,Space+Copy(st,1,CClient)+' '+s);
      Writeln(f,Space+'-------------------------------------------------------------------');
      Writeln(f,Space+' Код  Наименование товара         З/Цена    %   Расч.Цена Спец.Цена');
      Writeln(f,Space+'-------------------------------------------------------------------');
                      {12345│12345678901234567890123456│12345678│123456│12345678│12345678}
      Count:=0;
      While Not(Eof(FFF)) Do
       Begin
        Read(fff,TovEl);
        If TovEl.Active Then
         Begin
         {код наименование закупочная цена наценка % цена от наценки с/цена }
          sArt:=TovEl.BazKod;
          SProz:=TovEl.Nazenka;
          SNAme:=GetIdField(FNAme,SArt);
          Format(Sname,CName);
          Format(SProz,CLitr+1);
          SZakupka:=BakGetField(FZakupka,SArt,0);
          MyStr(StrToReal(SZakupka),CZena,CMantissa,SZakupka);
          Format(SZakupka,CZena);
          SSpecZena:=TovEl.SpecZena;
          MyStr(StrToReal(SSpecZena),CZena,CMantissa,SSpecZena);
          Format(SSpecZena,CZena);
          MyStr(StrToReal(SZakupka)*(1+StrToReal(TovEl.NAzenka)/100),CZena,CMAntissa,SRZena);
          If (Regim=0) Or ((Regim=1)And(StrToReal(SRZena)<>StrToReal(SSpecZena))) Then
           Begin
           Writeln(f,Space+SArt+' '+SNAme+' '+SZakupka+' '+SProz+' '+SRZena+' '+SSpecZena);
           Inc (Count);
           End;
         End;
       End;
       Writeln(f,Space+'-------------------------------------------------------------------');
       Writeln(f,Space+'Всего ',Count:4,' позиций');
      End;
      jk:=IOResult;
      Close(fff);
      jk:=IOResult;
     End;
   End;
 End;
Writeln(f,Space+'------------------------------------------------------------------');
Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'==================================================================');
Close(f);

NoInfo;
ViewAsText(Path.ToTemp+'clientpc.txt',True);
Report(Path.ToTemp+'clientpc.txt','',1,False,False,false);
end;





procedure PrintingZeniDOS(As : DocumentEdit;Vid:Byte);
Const Space='   ';
Var txt : Text;
    k,c,l,t,i,j : LongInt;
    ws,ws1 : string;
    f : PereozenkaFileType;
    fp : PrihodFileType;
    s   : Array [1..19] Of string;
    E : PPereozenkaType;
    SArt : ArtikulStr;
    Ep : PPrihodType;
    Find : Boolean;
    Rek1 : Rekwiziti;
    Sk : PSkidkaType;
    SkZena : Array[1..CShkala] Of STring[CZena];
    R : TRect;
    Temp: PBox;
    Mas : Maska24;
    Region : Word;
    MMM : MAska6;

Begin
 AInfo('Ищу документ...');
 R.Assign(0,0,0,0);
 Temp := New(PBox, Init(R, 1, Nil));
 Temp^.NewList(New(PTextCollection, Init(1,1)));
 Find:=False;
 If Vid=0 Then{если печатать переоценку}
Begin
 Assign(F,Path.ToCorrect+As.D+'.prz');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не найден файл '+Path.ToCorrect+As.D+'.prz',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
   ReadPereozenka(F,E);
  DelSpace(E^.Dat.Document);
  If  ClearChar(E^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Close(f);
   Dispose(Temp,Done);
   Dispose(E,Done);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
 End;
 Close(f);

 For c:=1 To E^.DAt.Amount Do
  Begin
   Temp^.List^.Insert(NewStr('│'+E^.DAt.Element[c].BAzKod));
   Temp^.SetRange(Temp^.List^.Count);
  End;
 Dispose(E,Done);
End{если печатать переоценку}
Else
 Begin
 Assign(Fp,Path.ToPrihod+As.D+'.prh');
 l:=IOResult;
 Reset(fp);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не найден файл '+Path.ToPrihod+As.D+'.prh',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(Ep,Init);
 While Not(Eof(fp))And Not(Find) Do
 Begin
   ReadPrihod(Fp,Ep);
  DelSpace(Ep^.Dat.Document);
  If  ClearChar(Ep^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Close(fp);
   Dispose(Temp,Done);
   Dispose(Ep,Done);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
 End;
 Close(fp);
 For c:=1 To Ep^.DAt.Amount Do
  Begin
   Temp^.List^.Insert(NewStr('│'+Ep^.DAt.PrihodElement[c].BAzKod));
   Temp^.SetRange(Temp^.List^.Count);
  End;
  Dispose(Ep,Done);
 End;
 NoInfo;

If (Temp^.List^.Count-1>=0) Then
Begin

Assign(txt,path.ToTemp+'zennik.txt');
i:=IOResult;
Rewrite(txt);
i:=IOResult;
If i<>0 Then
  Begin
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'zennik.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

SelectPrize(Mas,5,Region,False,MMM);

AInfo('Формирую ценники...');

j:=1;
Rek1:=Rek;
Format(Rek1.Name,20);
s[1] :='------------------------------------------------------------------------------------------';
s[2] :=Italic[Nprint.Printer]+Condensed[Nprint.Printer]+'     '+Rek1.Name+'     '+
                                                        '     '+Rek1.Name+'     '+
											 '     '+Rek1.Name+'     '+
											 '     '+Rek1.Name+'     '+
											 '     '+Rek1.Name+'     '+
NoItalic[Nprint.Printer]+NoCondensed[Nprint.Printer];
s[3,0]:=#0;{Наименование}
s[4,0]:=#0;{Фасовка}
s[5,0]:=#0;{Производство}
s[6,0]:=#0; {Базовая}
s[7,0]:=#0;{169.50}
s[8,0]:=#0;{Цена 1}
s[9,0]:=#0;{Цена 2}
s[10,0]:=#0;{Цена 3}
s[11,0]:=#0;{Цена 4}
s[12,0]:=#0;{Цена 4}
s[13,0]:=#0;{Цена 4}
s[14,0]:=#0;{Цена 4}
s[15,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[16,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[17,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[18,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[19,0]:=#0;{'------------------------------------------------------------------------------------------';}

k:=0;
For i:=0 To Temp^.List^.Count-1 Do
Begin
SArt:=Copy(Temp^.GetText(i,Temp^.List^.Count),1+1,CArtikul);
{пробиваем наименование}
ws:=GetIdField(FName,SArt);
format(ws,CName);
ws:=' '+ws+'   ';
s[3]:=s[3]+ws;
{пробиваем фасовку}
ws:=GetIdField(FLitr,SArt);
Format(ws,CLitr);
ws:=Condensed[Nprint.Printer]+'    Масса:     '+ws+'          '+NoCondensed[Nprint.Printer];
s[4]:=s[4]+ws;

ws:=BakGetField(FPost,SArt,0);
Format(ws,CPost);
ws:=Condensed[Nprint.Printer]+' Производство:'+ws+' '+NoCondensed[Nprint.Printer];
{Производ-во:123456789012345}
s[5]:=s[5]+ws;
{пробиваем цену}
ws:=BakGetField(FRZena,SArt,0);
MyStr(StrToReal(ws),CZena-2,CMantissa,ws);
DelSpace(ws);
ws:=' '+ws;
Format(ws,CZena+1);
s[7]:=s[7]+{Condensed[NPrint.Printer]+' '+Condensed[NPrint.Printer]+}High[NPrint.Printer]+Bold[NPrint.Printer]+
ws+
NoHigh[NPrint.Printer]{NoBold[NPrint.Printer]+NoItalic[NPrint.Printer]+NoDouble[NPrint.Printer]};
New(Sk,Init);
GetSkidka(SArt,Sk^.Dat);

For t:=1 To CShkala Do
 Begin
  MyStr(StrToREal(sk^.Dat.Skidka[t].Up),CZena-3,0,sk^.Dat.Skidka[t].Up);
  MyStr((StrToReal(ws)*StrToReal(sk^.Dat.Skidka[t].Proz)),CZena-2,CMAntissa,SkZena[t]);
 End;
{123456 123456   123456 123456}

If Mas[1]=1 Then
Begin
ws:=' '+SkZena[1];
Format(ws,CZena+1);
s[9]:= s[9]+High[NPrint.Printer]+ws+NoHigh[NPrint.Printer];
End;
If Mas[2]=1 Then
Begin
ws:=' '+SkZena[2];
Format(ws,CZena+1);
s[11]:=s[11]+High[NPrint.Printer]+ws+NoHigh[NPrint.Printer];
End;
If Mas[3]=1 Then
Begin
ws:=' '+SkZena[3];
Format(ws,CZena+1);
s[13]:=s[13]+High[NPrint.Printer]+ws+NoHigh[NPrint.Printer];
End;
If Mas[4]=1 Then
Begin
ws:=' '+SkZena[4];
Format(ws,CZena+1);
s[15]:=s[15]+High[NPrint.Printer]+ws+NoHigh[NPrint.Printer];
End;
If Mas[5]=1 Then
Begin
ws:=' '+SkZena[5];
Format(ws,CZena+1);
s[17]:=s[17]+High[NPrint.Printer]+ws+NoHigh[NPrint.Printer];
End;
If Mas[6]=1 Then
Begin
ws:=' '+SkZena[6];
Format(ws,CZena+1);
s[19]:=s[19]+High[NPrint.Printer]+ws+NoHigh[NPrint.Printer];
End;

Dispose(Sk,Done);

Inc(j);

{запись строки ценников в файл}
If (j=6) Or (i=Temp^.List^.Count-1) Then
 Begin
  Inc(k);
  For j:=1 To 19 Do
   Begin
    If j=3 Then s[3]:=Double[Nprint.Printer]+Condensed[Nprint.Printer]+s[3]+NoDouble[Nprint.Printer]+
    NoCondensed[Nprint.Printer];
    if j<>7 Then
     If Not((j in [8,9])And(Mas[1]=0)) And
        Not((j in [10,11])And(Mas[2]=0)) And
        Not((j in [12,13])And(Mas[3]=0)) And
        Not((j in [14,15])And(Mas[4]=0)) And
        Not((j in [16,17])And(Mas[5]=0)) And
        Not((j in [18,19])And(Mas[6]=0)) Then

    Writeln(txt,Space+s[j]);
   End;
  iF K=3 Then
   Begin
        k:=1;
    Writeln(txt,EndPage[NPrint.Printer]);
   End;

{заполнение чистой формы}
j:=1;
Format(Rek1.Name,20);
s[1] :='------------------------------------------------------------------------------------------';
{       123456789012345678901234567890 123456789012345678901234567890 123456789012345678901234567890}
{
s[2] :=Italic[Nprint.Printer]+Condensed[Nprint.Printer]+Rek1.Name+NoCondensed[Nprint.Printer]+NoItalic[NPrint.Printer]+'│'+
       Italic[Nprint.Printer]+Condensed[Nprint.Printer]+Rek1.Name+NoCondensed[Nprint.Printer]+NoItalic[NPrint.Printer]+'│'+
       Italic[Nprint.Printer]+Condensed[Nprint.Printer]+Rek1.Name+NoCondensed[Nprint.Printer]+NoItalic[NPrint.Printer]+'│'+
	  Italic[Nprint.Printer]+Condensed[Nprint.Printer]+Rek1.Name+NoCondensed[Nprint.Printer]+NoItalic[NPrint.Printer]+'│';
       }
s[2] :=Italic[Nprint.Printer]+Condensed[Nprint.Printer]+'     '+Rek1.Name+'     '+
                                                        '     '+Rek1.Name+'     '+
											 '     '+Rek1.Name+'     '+
											 '     '+Rek1.Name+'     '+
											 '     '+Rek1.Name+'     '+
NoItalic[Nprint.Printer]+NoCondensed[Nprint.Printer];

{5 наименование организации}
{}
s[3,0]:=#0;{Наименование}
s[4,0]:=#0;{Фасовка}
s[5,0]:=#0;{Производство}
s[6,0]:=#0;
s[7,0]:=#0;{Базовая-169.50}
s[8,0]:=#0;{Цена 1}
s[9,0]:=#0;{Цена 2}
s[10,0]:=#0;{Цена 3}
s[11,0]:=#0;{Цена 4}
s[12,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[13,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[14,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[15,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[16,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[17,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[18,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[19,0]:=#0;{'------------------------------------------------------------------------------------------';}
 End;
End;

NoInfo;
Close(txt);
Report(Path.ToTemp+'zennik.txt','',NPrint.CopyPrz,False,False,false);
End;
Dispose(Temp,Done);
End;



(*
procedure PrintingZeniWIN(As : DocumentEdit;Vid:Byte);
Const Space='   ';
Var txt : Text;
    k,c,l,t,i,j : LongInt;
    ws,ws1 : string[150];
    f : PereozenkaFileType;
    fp : PrihodFileType;
    s   : Array [1..19] Of string[150];
    E : PPereozenkaType;
    SArt : ArtikulStr;
    Ep : PPrihodType;
    Find : Boolean;
    Rek1 : Rekwiziti;
    Sk : PSkidkaType;
    SkZena : Array[1..CShkala] Of STring[CZena];
    R : TRect;
    Temp: PBox;
    Mas : Maska24;
    Region : Word;
    MMM : Maska6;

Begin
 AInfo('Ищу документ...');
 R.Assign(0,0,0,0);
 Temp := New(PBox, Init(R, 1, Nil));
 Temp^.NewList(New(PTextCollection, Init(1,1)));
 Find:=False;
 If Vid=0 Then{если печатать переоценку}
Begin
 Assign(F,Path.ToCorrect+As.D+'.prz');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не найден файл '+Path.ToCorrect+As.D+'.prz',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
   ReadPereozenka(F,E);
  DelSpace(E^.Dat.Document);
  If  ClearChar(E^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Close(f);
   Dispose(Temp,Done);
   Dispose(E,Done);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
 End;
 Close(f);

 For c:=1 To E^.DAt.Amount Do
  Begin
   Temp^.List^.Insert(NewStr('│'+E^.DAt.Element[c].BAzKod));
   Temp^.SetRange(Temp^.List^.Count);
  End;
 Dispose(E,Done);
End{если печатать переоценку}
Else
 Begin
 Assign(Fp,Path.ToPrihod+As.D+'.prh');
 l:=IOResult;
 Reset(fp);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не найден файл '+Path.ToPrihod+As.D+'.prh',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(Ep,Init);
 While Not(Eof(fp))And Not(Find) Do
 Begin
   ReadPrihod(Fp,Ep);
  DelSpace(Ep^.Dat.Document);
  If  ClearChar(Ep^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Close(fp);
   Dispose(Temp,Done);
   Dispose(Ep,Done);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
 End;
 Close(fp);
 For c:=1 To Ep^.DAt.Amount Do
  Begin
   Temp^.List^.Insert(NewStr('│'+Ep^.DAt.PrihodElement[c].BAzKod));
   Temp^.SetRange(Temp^.List^.Count);
  End;
  Dispose(Ep,Done);
 End;
 NoInfo;

If (Temp^.List^.Count-1>=0) Then
Begin

Assign(txt,path.ToTemp+'zennik.txt');
i:=IOResult;
Rewrite(txt);
i:=IOResult;
If i<>0 Then
  Begin
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'zennik.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

SelectPrize(Mas,5,Region,False,MMM);

AInfo('Формирую ценники...');

j:=1;
Rek1:=Rek;
s[1] :='------------------------------------------------------------------------------------------';
s[2] :='$'+Rek1.Name+'$'+Rek1.Name+
											 '$'+Rek1.Name+
											 '$'+Rek1.Name+
											 '$'+Rek1.Name;
s[3,0]:=#0;{Наименование}
s[4,0]:=#0;{Фасовка}
s[5,0]:=#0;{Производство}
s[6,0]:=#0; {Базовая}
s[7,0]:=#0;{169.50}
s[8,0]:=#0;{Цена 1}
s[9,0]:=#0;{Цена 2}
s[10,0]:=#0;{Цена 3}
s[11,0]:=#0;{Цена 4}
s[12,0]:=#0;{Цена 4}
s[13,0]:=#0;{Цена 4}
s[14,0]:=#0;{Цена 4}
s[15,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[16,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[17,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[18,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[19,0]:=#0;{'------------------------------------------------------------------------------------------';}

k:=0;
For i:=0 To Temp^.List^.Count-1 Do
Begin
SArt:=Copy(Temp^.GetText(i,Temp^.List^.Count),1+1,CArtikul);
{пробиваем наименование}
ws:=GetIdField(FFFName,SArt);
format(ws,CName);
ws:='$'+ws;
s[3]:=s[3]+ws;
{пробиваем фасовку}
ws:=GetIdField(FLitr,SArt);
Format(ws,CLitr);
ws:='$ Масса:'+ws;
s[4]:=s[4]+ws;

ws:=BakGetField(FPost,SArt,0);
Format(ws,CPost);
ws:='$ Производство:'+ws;
{Производ-во:123456789012345}
s[5]:=s[5]+ws;
{пробиваем цену}
ws:=BakGetField(FRZena,SArt,0);
Str(StrToReal(ws):CZena-2:CMantissa,ws);
DelSpace(ws);
ws:=' '+ws;
Format(ws,CZena+1);
s[7]:=s[7]+'$'+ws;
New(Sk,Init);
GetSkidka(SArt,Sk^.Dat);

For t:=1 To CShkala Do
 Begin
  Str(StrToREal(sk^.Dat.Skidka[t].Up):CZena-3:0,sk^.Dat.Skidka[t].Up);
  Str((StrToReal(ws)*StrToReal(sk^.Dat.Skidka[t].Proz)):CZena-2:CMAntissa,SkZena[t]);
 End;
{123456 123456   123456 123456}

If Mas[1]=1 Then
Begin
ws:=' '+SkZena[1];
Format(ws,CZena+1);
s[9]:= s[9]+'$'+ws;
End;
If Mas[2]=1 Then
Begin
ws:=' '+SkZena[2];
Format(ws,CZena+1);
s[11]:=s[11]+'$'+ws;
End;
If Mas[3]=1 Then
Begin
ws:=' '+SkZena[3];
Format(ws,CZena+1);
s[13]:=s[13]+'$'+ws;
End;
If Mas[4]=1 Then
Begin
ws:=' '+SkZena[4];
Format(ws,CZena+1);
s[15]:=s[15]+'$'+ws;
End;
If Mas[5]=1 Then
Begin
ws:=' '+SkZena[5];
Format(ws,CZena+1);
s[17]:=s[17]+'$'+ws;
End;
If Mas[6]=1 Then
Begin
ws:=' '+SkZena[6];
Format(ws,CZena+1);
s[19]:=s[19]+'$'+ws;
End;

Dispose(Sk,Done);

Inc(j);

{запись строки ценников в файл}
If (j=6) Or (i=Temp^.List^.Count-1) Then
 Begin
  Inc(k);
  For j:=1 To 19 Do
   Begin
    if j<>7 Then
     If Not((j in [8,9])And(Mas[1]=0)) And
        Not((j in [10,11])And(Mas[2]=0)) And
        Not((j in [12,13])And(Mas[3]=0)) And
        Not((j in [14,15])And(Mas[4]=0)) And
        Not((j in [16,17])And(Mas[5]=0)) And
        Not((j in [18,19])And(Mas[6]=0)) Then

    Writeln(txt,Space+s[j]);
   End;
  iF K=3 Then
   Begin
        k:=1;
   End;

{заполнение чистой формы}
j:=1;
Format(Rek1.Name,20);
s[1] :='------------------------------------------------------------------------------------------';
{       123456789012345678901234567890 123456789012345678901234567890 123456789012345678901234567890}
{
s[2] :=Italic[Nprint.Printer]+Condensed[Nprint.Printer]+Rek1.Name+NoCondensed[Nprint.Printer]+NoItalic[NPrint.Printer]+'│'+
       Italic[Nprint.Printer]+Condensed[Nprint.Printer]+Rek1.Name+NoCondensed[Nprint.Printer]+NoItalic[NPrint.Printer]+'│'+
       Italic[Nprint.Printer]+Condensed[Nprint.Printer]+Rek1.Name+NoCondensed[Nprint.Printer]+NoItalic[NPrint.Printer]+'│'+
	  Italic[Nprint.Printer]+Condensed[Nprint.Printer]+Rek1.Name+NoCondensed[Nprint.Printer]+NoItalic[NPrint.Printer]+'│';
       }
s[2] :='$'+Rek1.Name+'$'+Rek1.Name+
											 '$'+Rek1.Name+
											 '$'+Rek1.Name+
											 '$'+Rek1.Name;

{5 наименование организации}
{}
s[3,0]:=#0;{Наименование}
s[4,0]:=#0;{Фасовка}
s[5,0]:=#0;{Производство}
s[6,0]:=#0;
s[7,0]:=#0;{Базовая-169.50}
s[8,0]:=#0;{Цена 1}
s[9,0]:=#0;{Цена 2}
s[10,0]:=#0;{Цена 3}
s[11,0]:=#0;{Цена 4}
s[12,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[13,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[14,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[15,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[16,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[17,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[18,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[19,0]:=#0;{'------------------------------------------------------------------------------------------';}
 End;
End;

NoInfo;
Close(txt);
MessageBox(^M+#3'Данные успешно эскпортированы в '+Path.ToTemp+'zennik.txt!'^M+
#3'Запустите MS Excel и распечатайте ценники',Nil,mfInformation+mfCancelButton);

End;
Dispose(Temp,Done);
End;

*)


Function GetEnvMy:string;
Var Ver : Word;
Begin
Ver := DosVersion;
If Ver<>5{ у XP и 2000 версия 5} {Not(FindParam('/WIN2K'))} Then GetEnvMy:=GetEnv('Comspec')
Else GetEnvMy:=GetEnv('SYSTEMROOT')+'\SYSTEM32\cmd.exe';
End;




{новый вариант ценников через DBF}
procedure PrintingZeniWIN(As : DocumentEdit;Vid:Byte);
Const Space=' ';
Var txt : Text;
    k,c,l,t,i,j : LongInt;
    ws,ws1 : string[150];
    f : PereozenkaFileType;
    fp : PrihodFileType;
    s   : Array [1..15] Of string[150];
    E : PPereozenkaType;
    SArt : ArtikulStr;
    Ep : PPrihodType;
    Find : Boolean;
    Rek1 : Rekwiziti;
    Sk : PSkidkaType;
    SkZena : Array[1..CShkala] Of String[CZena];
    R : TRect;
    Temp: PBox;
    EndP : Boolean;
    VidZennik:Word;
    SSS,Prozent : AllStr;
    Base : DBase3;
    SZena,SZena1,SZena2,SZena3,SName,SLitr,SInPack,SPost:string[150];
    Event : TEvent;
    Ver : Word;
    Skid : PSkidkaType;

Begin
 VidZennik:=0;
 Prozent:='1.00';

 If VidZennik=4 Then Exit;

 AInfo('Ищу документ...');
 R.Assign(0,0,0,0);
 Temp := New(PBox, Init(R, 1, Nil));
 Temp^.NewList(New(PTextCollection, Init(1,1)));
 Find:=False;
 If Vid=0 Then{если печатать переоценку}
Begin
 Assign(F,Path.ToCorrect+As.D+'.prz');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не найден файл '+Path.ToCorrect+As.D+'.prz'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
   {
   Repeat
   Until Lock(f,FilePos(f)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
   }
   ReadPereozenka(F,E);
   {
   Repeat
    UnLock(f,(FilePos(f)-1)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
   Until DosError=0;
   }
  DelSpace(E^.Dat.Document);
  If  StrToInt(E^.Dat.Document)=StrToInt(As.EditPosition) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Close(f);
   Dispose(Temp,Done);
   Dispose(E,Done);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
{  If Status=DocPrint Then Status:=DocNormal;}
   Exit;
 End;
 Close(f);

 For c:=1 To E^.DAt.Amount Do
  Begin
   Temp^.List^.Insert(NewStr('│'+E^.DAt.Element[c].BAzKod));
   Temp^.SetRange(Temp^.List^.Count);
  End;
 Dispose(E,Done);
End{если печатать переоценку}
Else
 Begin
 Assign(Fp,Path.ToPrihod+As.D+'.prh');
 l:=IOResult;
 Reset(fp);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не найден файл '+Path.ToPrihod+As.D+'.prh',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(Ep,Init);
 While Not(Eof(fp))And Not(Find) Do
 Begin
  ReadPrihod(Fp,Ep);
  DelSpace(Ep^.Dat.Document);
  If  StrToInt(Ep^.Dat.Document)=StrToInt(As.EditPosition) Then Find:=True;
 End;

 If Not(Find) Then
 Begin
   Close(fp);
   Dispose(Temp,Done);
   Dispose(Ep,Done);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
 End;
 Close(fp);

 For c:=1 To Ep^.DAt.Amount Do
  Begin
   Temp^.List^.Insert(NewStr('│'+Ep^.DAt.PrihodElement[c].BAzKod));
   Temp^.SetRange(Temp^.List^.Count);
  End;

  Dispose(Ep,Done);
 End;{приход}

 NoInfo;

If (Temp^.List^.Count-1>=0) Then
Begin
DInfoMsg('Формирую ценники...');

 Assign(txt,Path.ToTemp+'Zennik.ini');
 l:=Ioresult;
 Rewrite(txt);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfoMsg;
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'zennik.ini'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(txt,'[COMMON]');
 Writeln(txt,'PathToReport='+Path.ToProgram);
 Writeln(txt,'PathToTable='+Path.ToTemp);
 Writeln(txt,'TableName=Zennik');
 Writeln(txt,'Vid=',VidZennik:2);{0-большой 1-маленький 2-с двумя ценами 3-пустой бланк}

 l:=Ioresult;
 Close(txt);
 l:=Ioresult;


with Base do
begin
 Assign(Path.ToTemp+'Zennik.dbf'); {пpисвоить БД имя}
 Init; {подготовиться к созданию БД}
 AddField('ORG','C',50,0);{Код объекта откуда происходит реализация}
 AddField('TOV_NAME','C',55,0);{код операции 1-розница; 0-опт; 2-вз}
 AddField('INPACK','C',10,0);{код клиента}
 AddField('KOD_TOV','C',5,0);{код клиента}
 AddField('LITR','C',10,0);{ссылка на основной договор}
 AddField('PROIZV','C',10,0);{код признак генерации СФ}
 AddField('ZENA1','C',15,0);{всего литров с НДС20}
 AddField('ZENA2','C',15,0);{всего литров с НДС20}
 AddField('ZENA3','C',15,0);{всего литров с НДС20}
 AddField('ZENA4','C',15,0);{всего литров с НДС20}

   if Create then Open(ReadWrite)
   else
     begin
      NoInfoMsg;
      Dispose(Temp,Done);
      MessageBox(^M+#3+'Ошибка создания '+Path.ToTemp+'Zennik.dbf!',Nil,mfError+mfCancelButton);
      exit;
     end;

c:=IOResult;
     Close;
c:=IOResult;
End;{With Base}
End;{TempList <> Nil}

j:=1;
Rek1:=Rek;

 Base.Assign(Path.ToTemp+'Zennik.dbf');
 j:=IOResult;
 Base.Open(ReadWrite);
 j:=IOResult;
 If j<>0 Then
  Begin
   NoInfoMsg;
   Dispose(Temp,Done);
   MessageBox(^M+#3+'Ошибка открытия '+Path.ToTemp+'Zennik.dbf!',Nil,mfError+mfCancelButton);
   Exit;
  End;


For i:=0 To Temp^.List^.Count-1 Do
Begin
SZena[0]:=#0;
SZena1[0]:=#0;
SZena2[0]:=#0;
SZena3[0]:=#0;
SSS[0]:=#0;
SArt:=Copy(Temp^.GetText(i,Temp^.List^.Count),1+1,CArtikul);
SName:=GetIdField(FFFName,SArt);
SLitr:=GetIdField(FLitr,SArt);
SInPack:=GetIdField(FInPack,SArt);
SPost:=BakGetField(FPost,SArt,0);
SZena:=BakGetField(FRZena,SArt,0);
MyStr(StrToReal(SZena),CZena,CMAntissa,SZena);
DelSpace(SZena);

   New(skid,Init);
   GetSkidka(SArt,Skid^.Dat);
   SSS:=SZena;
   MyStr(StrToReal(SZena)*(StrToReal(Skid^.DAt.Skidka[1].Proz)),CZena,CMAntissa,SZena);
   MyStr(StrToReal(SSS)*(StrToReal(Skid^.DAt.Skidka[2].Proz)),CZena,CMAntissa,SZena1);
   MyStr(StrToReal(SSS)*(StrToReal(Skid^.DAt.Skidka[3].Proz)),CZena,CMAntissa,SZena2);
   MyStr(StrToReal(SSS)*(StrToReal(Skid^.DAt.Skidka[4].Proz)),CZena,CMAntissa,SZena3);
   Dispose(Skid,Done);

   DelSpace(SZena);
   DelSpace(SZena1);
   DelSpace(SZena2);
   DelSpace(SZena3);

     With Base Do
      Begin
       Append; {добавить новую запись}
       WriteSTR('ORG',Rek1.Name);{Код объекта откуда происходит реализация}
       WriteStr('TOV_NAME',SName);
       WriteStr('INPACK',SInPack);
       WriteStr('KOD_TOV',SArt);
       WriteStr('LITR',SLitr);
       WriteStr('PROIZV',SPost);
       WriteStr('ZENA1',SZena);
       WriteStr('ZENA2',SZena1);
       WriteStr('ZENA3',SZena2);
       WriteStr('ZENA4',SZena3);
      End;{With}
End;

c:=IOResult;
 Base.Close;{закрытие DBF}
c:=IOResult;



 NoInfoMsg;

  CursorLines:=1543;
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SwapVectors;
  Ver := DosVersion;
  If Ver<>5{ у XP и 2000 версия 5} Then
  Exec(GetEnvMy,' /c Start.exe '+Path.ToProgram+'zen.exe '+Path.ToTemp+'zennik.ini')
  Else
  Exec(GetEnvMy,' /C Start /D'+Path.ToProgram+' zen.exe '+Path.ToTemp+'zennik.ini');
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


procedure PrintingZeni(As : DocumentEdit;Vid:Byte);
VAr Regim : Word;
Begin
Regim:=SelectImport(0);
Case Regim Of
0:PrintingZeniWin(As,Vid);
1:PrintingZeniDos(As,Vid);
Else Exit;
End;

End;




function GetNewNumber(Var St : ArtikulStr) : Boolean;
LAbel 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  st1 : String[CClientKod];
begin
1:
St[0]:=#0;
St1[0]:=#0;
GetNewNumber:=False;
R.Assign(33, 10, 47, 13);
New(Dlg, Init(R, 'Код'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;
R.Assign(3, 1, 9, 2);
Control := New(PInputLine, Init(R, CClientKod));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  Dlg^.SetDAta(Rek.Kod);

Dlg^.SelectNext(False);
c:=Desktop^.execView(Dlg);
If c<>cmCAncel Then
 Begin
  Dlg^.GetDAta(st1);
  If StrToInt(st1)=0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    Goto 1;
   End;
  DelSpace(st1);
  st:=st1;
  GetNewNumber:=True;
 End;
 Dispose(Control,Done);
 Dispose(Dlg,Done);
end;





Procedure ChangeSkladKod;
{приход   prh
 отгрузка mrk
 возврат  vzw
 переоценки  prz
 ревизии  rwz
 бартер   brt
 оплата бартера bpl
 долги    dlg
 оплата реализации opl}


Var Ph  : PPrihodType;
    Phf : File Of PrihodType;
    Prz  : PPereozenkaType;
    Przf : File Of PereozenkaType;
    Mh  : PSuperMArketType;
    Mhf : File Of SuperMArketType;
    Rh  : PNewVozwratType;
    Rhf : File Of NewVozwratType;
    Rwh  : PRewisiaType;
    Rwhf : File Of RewisiaType;
    Oph  : OplataRealizasiaType;
    Ophf : File Of OplataRealizasiaType;
    Opb  : OplataBarter;
    Opbf : File Of OplataBarter;
    Dlg  : PRealizasiaType;
    Dlgf : File Of RealizasiaType;
    Brt  : PBArterClientType;
    BrtF : File Of BArterClientType;
    DirInfo: SearchRec;
    Cur : LongInt;
    Start,Stop : LongInt;
    StartDAte,StopDAte,CurDAte : TDAteString;
    c:Word;
    Newkod : String[CClientKod];

begin
If Not GetNewNumber(NewKod) Then Exit;

If Not(DAtePeriodDialog(StartDAte,StopDAte,FAlse)) Then Exit;

Start:=DateStringToDAte(DAteMAsk,StartDAte);
Stop:=DateStringToDAte(DAteMAsk,StopDAte);

RFormatZerro(NewKod,CClientKod);

For Cur:=Start To Stop Do
 Begin
  CurDAte:=DAteToDAteString(DateMAsk,Cur);

  AInfo('Перекодирую информацию за '+CurDAte+'...');

  {цикл обработки приходов}
  Assign(Phf,PAth.ToPrihod+CurDAte+'.prh');
  c:=IoResult;
  Reset(Phf);
  c:=IoResult;
  If c=0 Then
   Begin
    New(Ph,Init);
    While Not(Eof(Phf)) Do
     Begin
      Read(Phf,Ph^.DAt);
      Ph^.DAt.SkladKod:=NewKod;
      Seek(Phf,FilePos(Phf)-1);
      Write(Phf,Ph^.DAt);
     End;
    Dispose(Ph,Done);
    c:=IoResult;
    Close(Phf);
    c:=IoResult;
   End;

  {цикл обработки переоценок}
  Assign(Przf,PAth.ToCorrect+CurDAte+'.prz');
  c:=IoResult;
  Reset(Przf);
  c:=IoResult;
  If c=0 Then
   Begin
    New(Prz,Init);
    While Not(Eof(Przf)) Do
     Begin
      Read(Przf,Prz^.DAt);
      Prz^.DAt.SkladKod:=NewKod;
      Seek(Przf,FilePos(Przf)-1);
      Write(Przf,Prz^.DAt);
     End;
    Dispose(Prz,Done);
    c:=IoResult;
    Close(Przf);
    c:=IoResult;
   End;


  {цикл обработки продаж}
  Assign(Mhf,PAth.ToMArket+CurDAte+'.mrk');
  c:=IoResult;
  Reset(Mhf);
  c:=IoResult;
  If c=0 Then
   Begin
    New(Mh,Init);
    While Not(Eof(Mhf)) Do
     Begin
      Read(Mhf,Mh^.DAt);
      Mh^.DAt.SkladKod:=NewKod;
      Seek(Mhf,FilePos(Mhf)-1);
      Write(Mhf,Mh^.DAt);
     End;
    Dispose(Mh,Done);
    c:=IoResult;
    Close(Mhf);
    c:=IoResult;
   End;


  {цикл обработки вовзратов}
  Assign(Rhf,PAth.ToReturn+CurDAte+'.vzw');
  c:=IoResult;
  Reset(Rhf);
  c:=IoResult;
  If c=0 Then
   Begin
    New(Rh,Init);
    While Not(Eof(Rhf)) Do
     Begin
      Read(Rhf,Rh^.DAt);
      Rh^.DAt.SkladKod:=NewKod;
      Seek(Rhf,FilePos(Rhf)-1);
      Write(Rhf,Rh^.DAt);
     End;
    Dispose(Rh,Done);
    c:=IoResult;
    Close(Rhf);
    c:=IoResult;
   End;

  {цикл обработки ревизий}
  Assign(Rwhf,PAth.ToRewisia+CurDAte+'.rwz');
  c:=IoResult;
  Reset(Rwhf);
  c:=IoResult;
  If c=0 Then
   Begin
    New(Rwh,Init);
    While Not(Eof(Rwhf)) Do
     Begin
      Read(Rwhf,Rwh^.DAt);
      Rwh^.DAt.SkladKod:=NewKod;
      Seek(Rwhf,FilePos(Rwhf)-1);
      Write(Rwhf,Rwh^.DAt);
     End;
    Dispose(Rwh,Done);
    c:=IoResult;
    Close(Rwhf);
    c:=IoResult;
   End;

  {цикл обработки оплат консигнации}
  Assign(Ophf,PAth.ToOplata+CurDAte+'.opl');
  c:=IoResult;
  Reset(Ophf);
  c:=IoResult;
  If c=0 Then
   Begin
    While Not(Eof(Ophf)) Do
     Begin
      Read(Ophf,Oph);
      Oph.SkladKod:=NewKod;
      Seek(Ophf,FilePos(Ophf)-1);
      Write(Ophf,Oph);
     End;
    c:=IoResult;
    Close(Ophf);
    c:=IoResult;
   End;

  {цикл обработки оплат по бартеру}
  Assign(Opbf,Path.ToBarter+CurDAte+'.bpl');
  c:=IoResult;
  Reset(Opbf);
  c:=IoResult;
  If c=0 Then
   Begin
    While Not(Eof(Opbf)) Do
     Begin
      Read(Opbf,Opb);
      Opb.SkladKod:=NewKod;
      Seek(Opbf,FilePos(Opbf)-1);
      Write(Opbf,Opb);
     End;
    c:=IoResult;
    Close(Opbf);
    c:=IoResult;
   End;

  NoInfo;
 End;



 {цикл обработки долгов консигнации}
 FindFirst(Path.ToDolg+'*.dlg', AnyFile, DirInfo);
 while DosError = 0 do
 begin
  If (Not(Pos('office.dlg',DirInfo.NAme))>0) And
     (Not(Pos('gorod.dlg',DirInfo.NAme))>0) And
     (Not(Pos('region.dlg',DirInfo.NAme))>0) And
     (Not(Pos('rezerv.dlg',DirInfo.NAme))>0) Then
  Begin

  AInfo('Обрабатываю долги '+DirInfo.Name+'...');
  Assign(Dlgf,Path.ToDolg+DirInfo.Name);
  c:=IoResult;
  Reset(Dlgf);
  c:=IoResult;
  If c=0 Then
   Begin
    New(Dlg,Init);
    While Not(Eof(Dlgf)) Do
     Begin
      Read(Dlgf,Dlg^.DAt);
      Dlg^.DAt.Market.SkladKod:=NewKod;
      Seek(Dlgf,FilePos(Dlgf)-1);
      Write(Dlgf,Dlg^.DAt);
     End;
    Dispose(Dlg,Done);
    c:=IoResult;
    Close(Dlgf);
    c:=IoResult;
   End;
  NoInfo;
  End;
  FindNext(DirInfo);
 end;{While}

 {цикл обработки сальдо взаимозачетов}
 FindFirst(Path.ToBArter+'*.brt', AnyFile, DirInfo);
 while DosError = 0 do
 begin
  AInfo('Обрабатываю взаимозачеты '+DirInfo.Name+'...');
  Assign(Brtf,Path.ToBArter+DirInfo.Name);
  c:=IoResult;
  Reset(Brtf);
  c:=IoResult;
  If c=0 Then
   Begin
    New(Brt,Init);
    While Not(Eof(Brtf)) Do
     Begin
      Read(Brtf,Brt^.DAt);
      Brt^.DAt.SkladKod:=NewKod;
      Seek(Brtf,FilePos(Brtf)-1);
      Write(Brtf,Brt^.DAt);
     End;
    Dispose(Brt,Done);
    c:=IoResult;
    Close(Brtf);
    c:=IoResult;
   End;
  NoInfo;
  FindNext(DirInfo);
 end;{While}



AddProtocol('Смена кода объекта - новый код '+NewKod,'','');

MessageBox(^M+#3'Операция завершена!'^M+
#3'Не забудь провести переиндексацию',Nil,mfWarning+mfCancelButton);
end;



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






Procedure FormNaklSklad(Space :TDateString; Video : Boolean;As :DocumentEdit; E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Real;
                   ShowAnswer:Boolean;OtdelMas:MaskaNew);


Var l : Word;
    sc,s,ws,ws1 : string[150];
    Ss : TEnjoyStr;
    st : String[CMantissa];
    pp : String[CPack];
    TTT,ItogoS,NdsPos :Real;
    Local,R : Boolean;
    M : MaskaNew;
    c : Word;
    Dop : TDateString;
    Nalog:TDateString;
    tempSkidka,tt1,tt2,WspomSkidka,OutputSklad,InputSklad,koefficient:ALLStr;
    DrawSkidka:Boolean;
    Separator : AllStr;
    Symbol : ArtikulStr;
    SRegion : AllStr;
    CC: Word;



Begin
   c:=IoResult;

   ItogoS:=0;ItogoSkidka:=0;Itogo:=0;{ NDS:=0;} NdsPos:=0;
   CC:=0;

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


   Write(txt,Space+'Внимание! в отборку включены следующие отделения:');
   For c:=1 To CDivision Do
   Begin
    If OtdelMas[c]=1 Then Write(txt,c:2,'  ');
   End;
   Writeln(txt);


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

   DrawSkidka:=False;



If R Then
Begin


 If (E^.Dat.OperatorSelector in [0,2]) And (E^.Dat.DocSelector in [0,1,2,3,4,5,6,7,8]) Then
 Begin
   Writeln(txt,Space+Dop+'--------------------------------------------------------------------------------------');
   Writeln(txt,Space+Dop+' N  Код  Наименование товара        Колич                         Упаковок Отд Примеч.');
   Writeln(txt,Space+Dop+'--------------------------------------------------------------------------------------');
 End
  Else
  Begin
   Space:=' ';
   Writeln(txt,Space+Dop+'---------------------------------------------------------------------------------------');
   Writeln(txt,Space+Dop+' N  Код  Наименование товара        Колич                          Упаковок Отд Примеч.');
   Writeln(txt,Space+Dop+'---------------------------------------------------------------------------------------');
  End;
                         { 1 12345│12345678901234567890123456│12345│12345678│12345│12345678│123456789│123│1234567│}
End
Else
Begin
   Writeln(txt,Space+Dop+'-----------------------------------------------------------------');
   Writeln(txt,Space+Dop+' N  Код  Наименование товара        Колич                       ');
   Writeln(txt,Space+Dop+'-----------------------------------------------------------------');
End;
   c:=0;
   WordToBitNew(c,M);
   RecalcFromOtdel(E,OtdelMas);
   For l:=1 To E^.Dat.Amount Do
    Begin
     Str(l:CMantissa,St);
     s:=E^.Dat.MarketElement[l].BazKod;
  If OtdelMas[E^.Dat.MarketElement[l].Input.DivisionSNumber]=1 Then
Begin
     Inc(cc);
{
     if E^.Dat.MarketElement[l].BazKod='26064'
      Then
      Begin
       Readln;
      End;
}

{
     If NPrint.FullName=0 Then
     ws:=GetIdField(FName,E^.Dat.MarketElement[l].BazKod)
     Else ws:=GetIdField(FFname,E^.Dat.MarketElement[l].BazKod);
}

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

       {
	   Writeln(txt,Space+Dop+st+Separator+S+' '+ws);
        Separator:=' ';
        st:='  ';
        ws:=ws1;
        s:='     ';
       }
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

     s:=s+'         ';

   If (E^.Dat.OperatorSelector=1) Or
   (R And(E^.Dat.OperatorSelector in [0,2]) And Not(E^.Dat.DocSelector in [0,1,2,4,5,6,7,8])) Then
    Begin
     Nalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
     MyStr(StrToReal(Nalog),CLitr,CMantissa,Nalog);
     s:=s+'{    }';
    End;

       MyStr((StrToReal(Ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
       ,CInputIZena,CMantissa,ws);

       ItogoS:=ItogoS+StrToReal(wS);
       s:=s+'{            }';
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

       s:=s+' '+'         ';


  If (E^.Dat.OperatorSelector=1)  Then
    Begin
     Nalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
     MyStr(StrToReal(Nalog),CLitr,CMantissa,Nalog);
     {пока включен налог спродажи нужен в документах клиента}
     s:=s+'{'+'    }';
    End;



       MyStr((StrToReal(Ws)*StrToInt(E^.Dat.MarketElement[l].Input.Kol))
       ,CInPutIZena,CMantissa,ws);

       ItogoS:=ItogoS+StrToReal(wS);

  If (E^.Dat.OperatorSelector<>1)  Then
    Begin
      s:=s+'{'+'            }';
    End
    Else
     Begin
      MyStr(StrToReal(E^.Dat.MarketElement[l].Input.Zakupka),CZena,CMantissa,E^.Dat.MarketElement[l].Input.Zakupka);
      s:=s+'{'+'       }';
     End;

      End;

      M[E^.Dat.MarketElement[l].Input.DivisionSNumber]:=1;

     NdsPos:=StrToReal(Ws)*StrToReal(E^.Dat.MarketElement[l].Input.NDS)/
     (100+StrToReal(E^.Dat.MarketElement[l].Input.NDS));

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

      DrawSkidka:=False;

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









     {Writeln(txt,Space+Dop+St+Separator+s);}
{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
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

    End;


    ItogoSkidka:=Itogo+StrToReal(E^.Dat.ENalog);
    MySTr(ItogoSkidka,CIZena,CMantissa,tt1);
    MySTr(ItogoS,CIZena,CMantissa,tt2);

    {MemCC(RealToStr(ItogoSkidka,CIZena,CMantissa)+' '+RealToStr(ItogoS,CIZena,CMantissa));}

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
    Writeln(Txt,Space+Dop+'Всего позиций:',cc:2,' из ',E^.Dat.Amount:2,'            Всего к оплате:',Recogniz(E^.Dat.SummaZ)+
    ' Мест:'+CalcMestoOtdel(E,OtdelMas));
    Writeln(Txt,Space+Dop+'  Всего масса:',Recogniz(CalcMassaOtdel(E,OtdelMas)));

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
    Writeln(Txt,Space+Dop+'Всего позиций:',CC:2,' из ',E^.Dat.Amount:2,'           Всего к оплате:',Recogniz(E^.Dat.SummaZ)+
    ' Мест:'+CalcMestoOtdel(E,OtdelMas));
    Writeln(Txt,Space+Dop+'  Всего масса:',Recogniz(CalcMassaOtdel(E,OtdelMas)));
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
    Writeln(Txt,Space+Dop+'Всего позиций:',cc:2,' из ',E^.Dat.Amount:2,'            Всего к оплате:',Recogniz(E^.Dat.SummaZ)+
    ' Мест:'+CalcMestoOtdel(E,OtdelMas));
    Writeln(Txt,Space+Dop+'  Всего масса:',Recogniz(CalcMassaOtdel(E,OtdelMas)));
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


    Writeln(Txt);
(*  Writeln(Txt,Space{+'Скидка: '},'{'+RecognizReal(ItogoSkidka,CIZena,CMantissa)+'}');*)

   If Not(Video)Then Write(txt,Space{+' Всего: '},' Печатал:'+GetOperatorName(CurrentPassword)+' '+
   '"'+DayString[DayOfWeek(ToDay)]+'" '+
    TodayString(DateMask)+'('+Times+')');

   If Not(Video) Then
   Writeln(txt,'  '+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+' Тип документа: (',
   LeadingZero(E^.Dat.DocSelector),')'+NoItalic[NPrint.Printer]+NOBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
 If ((E^.Dat.OperatorSelector in [0,2]) And (E^.Dat.DocSelector in [0,1,4,7,8])) Or Not(r)
 Then
   Writeln(txt,Space+'======================================================================================')
   Else
   If (E^.Dat.OperatorSelector=1) Then
   Writeln(txt,Space+'=======================================================================================')
   Else
   Writeln(txt,Space+'============================================================================================');
End;



function SelectOtdel(Var Otdel:Word) : Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  w,c : Word;

begin
SelectOtdel:=False;
R.Assign(30, 7, 47, 13);
New(Dlg, Init(R, 'Укажите отделение'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;
Otdel:=255;
R.Assign(1, 1, 16, 5);
Control := New(PCheckboxes, Init(R,
  NewSItem('~1~',
  NewSItem('~2~',
  NewSItem('~3~',
  NewSItem('~4~',
  NewSItem('~5~',
  NewSItem('~6~',
  NewSItem('~7~',
  NewSItem('~8~',
  Nil))))))))));
Dlg^.Insert(Control);
Dlg^.SetData(Otdel);

Dlg^.SelectNext(False);
w:=Desktop^.ExecView(Dlg);
If w<>cmCancel Then
 Begin
  Dlg^.GetDAta(Otdel);
  If Otdel<>0 Then SelectOtdel:=True;
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;













Procedure PrintNaklSklad (As: DocumentEdit;CopyNkl : Byte);
Var f : MarketFileType;
    E : PSuperMarketType;
    Copy,l : Word;
    NDS,z,ItogoSkidka,Itogo,
    NDS20,NDS10,NDS_ : Real;
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
    BArter : String[CMAntissa];
    Rek1 : Rekwiziti;
    Vzw : Boolean;
    OtdelMas : MaskaNew;
    Otdel:Word;
Begin
 Otdel:=SelectImport(27);
 If Otdel=2 Then Exit;

 If Otdel=1 Then Otdel:=255
 Else Begin
       If Not SelectOtdel(Otdel) Then Exit;
      End;

 WordToBitNew(Otdel,OtdelMas);
 ConvertNew(OtdelMas);


 AInfo('Ищу документ...');
 Space:='      ';
 Assign(F,Path.ToMarket+As.D+'.mrk');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+As.D+'.mrk',Nil,mfError+mfCancelButton);
   Exit;
  End;


 Assign(Txt,Path.ToTemp+'Nakla.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   NoInfo;
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'Nakla.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Close(Txt);

{ CloSe(Txt1); убрал иначе возникает ошибка}

 Find :=False;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMarket(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
  DelSpace(E^.Dat.Document);
  If  (ClearChar(E^.Dat.Document)=ClearChar(As.EditPosition)) And(E^.Dat.Active)
  And(E^.Dat.DateC=As.D) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Dispose(E,Done);
   Close(f);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
 End;
 Close(f);

   NoInfo;

{
 VZw:=FAlse;
If FindParam('/DECVOZWRAT') Then
 Begin
 IF MessageBox(^M+#3+'Пересчитать с учетом возвратов?',nil,mfOkCAncel)=cmOk Then
  Begin
  RecalcFromVozwrat(E);
  Vzw:=True;
  End;
 End;
}

 Rewrite(Txt);
 FormSf(False, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_);
 Close(Txt);
{Erase(Txt1);}
 Rewrite(Txt);

   If E^.DAt.DocSelector in [3,4,6,8] Then
   Rek1:=RekSF
   Else
   Rek1:=Rek;

If E^.Dat.DocSelector<>0 Then{если не список}
Begin
Writeln(Txt,Space+'Склад: ',{E^.Dat.Sklad+}E^.Dat.SkladKod+
                  '  Оператор: '+E^.Dat.Caption+'  Агент: '+E^.Dat.AgentKod++' EYE & 1999');
End
Else
Begin
If E^.Dat.OperatorSelector<>0 Then
Begin
Writeln(Txt,Space+'Склад: ',{E^.Dat.Sklad}E^.Dat.SkladKod+
                  '  Оператор: '+E^.Dat.Caption+'  Агент: '+E^.Dat.AgentKod+' EYE & 1999');
End
 Else Begin
        Writeln(txt);
      End;
End;
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt,Space{+'Последние изменения:'}+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');

ItogoSkidka:=0;   Itogo:=0; {NDS:=0;}

If (E^.Dat.Realiz) And Not(E^.DAt.DocSelector in [5,6,7,8]) Then
Begin
Writeln(Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'СТАТУС: Документ оплачен'+NOBold[NPrint.Printer]+
NoDouble[NPrint.Printer]);

SDoc:=E^.Dat.DocReal;
SDate:=E^.Dat.DocDate;
{что писать в шапке документа - для наклдных консигнации-первичный документ}
Logik:=True;
ws:=E^.Dat.DateC;
ws:=ClearChar(ws);
Writeln(Txt,Space+'                                                                      '+{Italic+}Bold[NPrint.Printer]+
Double[NPrint.Printer]+'НК '+ws+
  E^.Dat.Document{Real}+NOBold[NPrint.Printer]{+NoItalic}+NoDouble[NPrint.Printer]);
{Writeln(Txt,Space+Italic+Bold+'НК '+E^.Dat.DocReal+ ' от  '+E^.Dat.DocDate+NOBold+NoItalic);}

{Writeln(Txt1,Space+Italic+Bold+'ПО НАКЛАДНОЙ КОНСИГНАЦИИ: '+E^.Dat.DocReal+ ' от  '+E^.Dat.DocDate+NOBold+NoItalic);}
End
Else
 Begin
 If (E^.Dat.Realiz) Then
 Begin
  Writeln(Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'СТАТУС: Документ подлежит оплате'+NOBold[NPrint.Printer]+
  NoDouble[NPrint.Printer]);
 End;
  SDoc:=E^.Dat.Document;
  SDate:=E^.Dat.DateC;
  Logik:=False;
 End;

{
 If E^.Dat.DocSelector=5 Then
   If TestSf(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC) Then Inc(E^.Dat.DocSelector);
}

 If E^.Dat.OperatorSelector<2 Then Barter[0]:=#0
 Else Barter:='-Б';

 If Vzw Then
  Writeln(Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'ВЗВ'+NOBold[NPrint.Printer]+
  NoDouble[NPrint.Printer]);


IF MessageBox(^M+#3+'ДЛЯ СКЛАДА: Отсортировать по группам?',nil,mfOkCAncel)=cmOk Then
 Begin
  SortNklIdx(E);
 End;



Case E^.Dat.DocSelector Of
0:begin
   If MessageBox(#3^M+#3'ДЛЯ СКЛАДА - Печатать список по документу N '+As.EditPosition{SDoc}+'?',Nil,mfConfirmation+mfOkCancel)
   =CmOk Then
    Begin
     If E^.Dat.OperatorSelector=1 Then
     Begin
     Writeln(Txt,Space+'          Д О К У М Е Н Т   ПРИЕМА-ПЕРЕДАЧИ N '+E^.Dat.Document+BArter+ ' от ',
	E^.Dat.DAteC+' ('+
     E^.Dat.TimeC+')');
     Writeln(Txt,Space+'Поставщик: '+{GetClient(Rek.Kod,E^.Dat.OperatorSelector)++' ('+Rek.Kod+')');}
	Bold[NPrint.Printer]+GetMakeField(FClient,Rek1.Kod,1)+NoBold[NPrint.Printer]);
     End
   Else
    Begin
    s:=SDoc{E^.Dat.Document};
    s:=Bold[NPrint.Printer]+S+NoBold[NPrint.Printer];
    Writeln(txt,Space+s+'                                                            '+SDate{E^.Dat.DateC}+
    ' ('+E^.Dat.TimeC+')');
    End;

   If E^.Dat.OperatorSelector=1 Then
   Begin
   Writeln(Txt,Space+'Получатель: ',GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
   E^.Dat.ClientKod+')');
   End
   Else
   Begin
   Writeln(Txt,Space+'Получатель: ',{GetClient(E^.Dat.ClientKod)+}' ('+E^.Dat.ClientKod+')');
   End;
   FormNaklSklad(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,True,OtdelMas);
   Close(txt);
{  If Status=DocPrint Then Status:=DocNormal;}
   Report(Path.ToTemp+'Nakla.txt','',1,False,False,false);
   Dispose(E,Done);

   End
   Else
    Begin
     Close(txt);
     Dispose(E,Done);
     Exit;
    End;
  end;{список}
1:begin
    s:=E^.Dat.Document;
    Writeln(Txt,Space+'          Д О К У М Е Н Т   ПРИЕМА-ПЕРЕДАЧИ N '+SDoc+BArter+ ' от ',
    SDAte+' ('+E^.Dat.TimeC+')');
    Writeln(Txt,Space+'Получатель: ',{GetClient(E^.Dat.ClientKod)+}' ('+E^.Dat.ClientKod+')');
    Write(Txt,Space+'Поставщик: '+Bold[NPrint.Printer]+Rek1.Name+NoBold[NPrint.Printer]);
    Writeln(txt,'    '+'Адрес: '+Rek1.Adress);

    If Rek1.Svidetelstvo[0]<>#0 Then
    Begin
    Writeln(txt,Space+'Свидетельство:'+Rek1.Svidetelstvo);
    End;
    FormNaklSklad(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,True,OtdelMas);
    Close(txt);
   If MessageBox(#3^M+#3'ДЛЯ СКЛАДА - Печатать товарный чек по документу N '+As.EditPosition+'?',Nil,mfConfirmation+
   mfOkCancel)=CmOk Then
   Begin
{    If Status=DocPrint Then Status:=DocNormal;}
    Report(Path.ToTemp+'Nakla.txt','',1,False,False,false);
   End;

   Dispose(E,Done);
  end;{товарный чек}
2:begin
    s:=E^.Dat.Document;
    Writeln(Txt,Space+'          Д О К У М Е Н Т   ПРИЕМА-ПЕРЕДАЧИ N '+SDoc+BArter+ ' от ',
    SDAte+' ('+E^.Dat.TimeC+')');
    Writeln(Txt,Space+'Получатель: ', GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
    E^.Dat.ClientKod+')');
    Write(Txt,Space+'Поставщик: '+Bold[NPrint.Printer]+Rek1.Name+NoBold[NPrint.Printer]);
    Writeln(txt,'    '+'Адрес: '+Rek1.Adress);
    If Rek1.Svidetelstvo[0]<>#0 Then
    Begin
    Writeln(txt,Space+'Свидетельство:'+Rek1.Svidetelstvo);
    End;

    FormNaklSklad(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,True,OtdelMas);
    Close(txt);

    If MessageBox(#3^M+#3'ДЛЯ СКЛАДА - Печатать накладную по документу N '+As.EditPosition+'?',Nil,mfConfirmation+
    mfOkCancel)=CmOk Then
    Begin
     Report(Path.ToTemp+'Nakla.txt','',1,False,False,false);
    End;

    Dispose(E,Done);
  end;{накладная с приходником}
5,6,7,8
  :begin

 l:=IOResult;
    If E^.DAt.DocSelector in [6,8] Then
    Begin
    Writeln(Txt,Space+'          Д О К У М Е Н Т   ПРИЕМА-ПЕРЕДАЧИ N '+SDoc+BArter+ ' от ',
    SDAte+' ('+E^.Dat.TimeC+')');
    End
    Else
    Begin
    Writeln(Txt,Space+'          Д О К У М Е Н Т   ПРИЕМА-ПЕРЕДАЧИ N '+SDoc+BArter+ ' от ',
    SDAte+' ('+E^.Dat.TimeC+')');
    End;

    l:=IOResult;

    Write(Txt,Space+'Выдано на консигнацию: ', GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+
    E^.Dat.ClientKod+')');
    Writeln(Txt,'    '+Bold[NPrint.Printer]+'Срок консигнации до: '+DateToDateString(DateMask,E^.Dat.Srok)+
    NoBold[NPrint.Printer]);
    l:=IOResult;

    Write(Txt,Space+'Поставщик: '+Bold[NPrint.Printer]+Rek1.Name+NoBold[NPrint.Printer]);
    Writeln(txt,'    '+'Адрес: '+Rek1.Adress);
    If Rek1.Svidetelstvo[0]<>#0 Then
    Begin
    Writeln(txt,Space+'Свидетельство:'+Rek1.Svidetelstvo);
    End;

    FormNaklSklad(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,True,OtdelMas);
    Close(txt);
    If MessageBox(#3^M+#3'ДЛЯ СКЛАДА - Печатать накладную по документу консигнации N '+As.EditPosition+'?',Nil,
    mfConfirmation+mfOkCancel)=CmOk Then
   Begin
    Report(Path.ToTemp+'Nakla.txt','',1,False,False,false);
   End;
   Dispose(E,Done);
  end;{реализация}
3,4:begin

    If E^.Dat.Realiz Then
          Begin
           If Not(Password(3)) Then
                Begin
                 Close(txt);
                 Dispose(E,Done);
                 Exit;
                End;
          End;

    If E^.Dat.DocSelector=4 Then
    Begin
        Writeln(txt,Space+'Платежное поручение N: '+E^.Dat.Bn.NPlat+' от '+E^.Dat.Bn.Date);
        Writeln(txt,Space+'Банк: '+E^.Dat.Bn.BAnk);
    End;

    s:=E^.Dat.Document;
    (*
    Writeln(Txt ,Space+SDoc+BArter+'                        Т О В А Р Н Ы Й  Ч Е К  от '+SDAte{E^.Dat.DateC}+' ('+
    E^.Dat.TimeC+')');
    Writeln(Txt1,Space+SDoc+BArter+'                        Т О В А Р Н Ы Й  Ч Е К  от '+SDate{E^.Dat.DateC}+' ('+
    E^.Dat.TimeC+')');
    *)
    Writeln(Txt,Space+'          Д О К У М Е Н Т   ПРИЕМА-ПЕРЕДАЧИ N '+SDoc+BArter+ ' от ',
    SDAte+' ('+E^.Dat.TimeC+')');

    Writeln(Txt,Space+'Получатель: ',GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+E^.Dat.ClientKod+
    ')');
    Write(Txt,Space+'Поставщик: '+Bold[NPrint.Printer]+Rek1.Name+NoBold[NPrint.Printer]);
    Writeln(txt,'    '+'Адрес: '+Rek1.Adress);
    If Rek1.Svidetelstvo[0]<>#0 Then
    Begin
    Writeln(txt,Space+'Свидетельство:'+Rek1.Svidetelstvo);
    End;
    FormNaklSklad(Space,False,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,True,OtdelMas);
    Close(txt);

   If MessageBox(#3^M+#3'ДЛЯ СКЛАДА - Печатать накладную по документу N '+As.EditPosition+'?',Nil,mfConfirmation+
   mfOkCancel)=CmOk Then
   Begin
{    If Status=DocPrint Then Status:=DocNormal;}
    Report(Path.ToTemp+'Nakla.txt',Path.ToTemp+'tem.tmp',1,True,Logik,false);
   End;

   Dispose(E,Done);
    end;{с/ф накладная и приходник}
Else;
End;
End;



{$IFDEF Not Kurz}
Procedure PrintSKL1(Const Spis:PBox;Const M:MaskaNew; Const Assort,Sort:Word);

Const Space='';
VAr sklFile : BazFileType;
    skl : pBazType;
    Skid : PSkidkaType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    F : Boolean;
    TArt,Zena,Zakupka,Lob:String[CZena];
    Max,Min : TDAteString;
    jk,l,c : Word;
    txt : Text;
    Kb : TDAteString;
    wws,ws,s : string[150];
    R,R1 : TRect;
    lk : LongInt;
    ttt,TempList, WspomList :PBox;
    Regim : LongInt;
    sh,VidPrize : Word;
    Mas : Maska24;
    Region : Word;
    SSS : Boolean;
    MMM : Maska6;
Begin

  VidPrize:=SelectPrize(Mas,6,Region,False,MMM);
  If VidPrize<>0 Then
   Begin
    Exit;
   End;


c:=IOResult;
Assign(txt,Path.ToTemp+'skidki1.txt');
Rewrite(txt);
c:=IOResult;

Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+' Оператор:'+CurrentPassword);
Writeln(Txt,Space+' ТАБЛИЦЫ РАЗНОГЛАСИЙ АВТОМАТИЧЕСКИХ СКИДОК на '+FDate);

Case Region Of
0:Writeln(Txt,Space+'Регион: Офис');
1:Writeln(Txt,Space+'Регион: Город');
2:Writeln(Txt,Space+'Регион: Область');
3:Writeln(Txt,Space+'Регион: Резерв');
Else;
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
      Close(Txt);
      Dispose(TempList,Done);
      Exit;
     End;

   Else;
   End;



DInfo('Минуточку...');




 For jk:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then wws:=Copy(TempList^.GetText(jk,TempList^.List^.Count),1,CRazdelKod)
  Else
  wws:=Copy(TempList^.GetText(jk,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);

  If TestRazdel(wws,M,Assort,2) Then
Begin

   Writeln(txt);
   Writeln(txt,Space+'   Раздел:'+GetRazdel(wws));

   s:='Код   Наименование             З/Цена   Р/Ц ';

 For sh:=1 To CShkala Do
  Begin
   If Mas[sh]=1 Then
    Begin
    ws:=IntToStr(Round(sh-Region*6),CMAntissa);
    RFormat(ws,CLitr+1);
    s:=s+ws+' ';
    s:=s+'  Разд.';
    End;
  End;

  s[0]:=Chr(Ord(s[0])-1);

 ws[0]:=#0;
 For sh:=1 To Ord(s[0]) Do
  Begin
    ws[sh]:='_';
    ws[0]:=Chr(sh);
  End;



   Writeln(txt,Space+ws);
   Writeln(txt,Space+s);
   Writeln(txt,Space+ws);
                     {12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789}
                     {12345 12345678901234567890123456 12345678 12345 12345 12345 12345 12345 12345 12345 12345}
   Assign(SklFile,Path.ToNAme+wws+'.id');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;
   If c<>0 Then
    Begin
     Close(txt);
     MessageBox(^M+#3'Ошибка доступа к файлу '+Path.ToName+RazdelElement.Kod+'.id',Nil,mfError+mfCancelButton);
     Exit;
    End;

   R1.Assign(0,0,0,0);
   ttt := New(PBox, Init(R1, 1, Nil));
   ttt^.NewList(New(PTextCollection, Init(0,1)));

   New(Skl,Init);
   New(Skid,Init);

   While Not(Eof(sklFile)) Do
Begin
     ReadBazPointer(SklFile,Skl);
     If ((StrToInt(BakGetField(FKol,Skl^.Dat.BAzKod,0))>0) and (Assort=0)) Or
         (Assort=1) Then
     {фильтр количества}
Begin
     s[0]:=#0;
     ws[0]:=#0;
     ws := Skl^.Dat.Name;
     Format(ws,CNAme-4);
     Str(StrtoReal(BakGetField(FZakupka,Skl^.Dat.BAzKod,0)):CZena-1:CMantissa,Zakupka);
     Str(StrtoReal(BakGetField(FRZena,Skl^.Dat.BAzKod,0)):CZena-1:CMantissa,Lob);

     s:=Skl^.Dat.BazKod+' '+ws+' '+Zakupka+' '+Lob;

     SSS:=False;

     GetSkidka(Skl^.Dat.BazKod,Skid^.Dat);



     For l:=1 To CShkala Do
      Begin
       If Mas[l]=1 Then
  Begin
     Kb:=GetRazdelShkalaNaz(Skl^.Dat.BazKod,L);
     Str(StrToReal(KB):CLitr+1:CMAntissa,KB);



       If Abs(StrToreal(Skid^.Dat.Skidka[l].MinNaz)-StrToReal(KB))>0.01 Then
       Begin
         SSS:=True;
       End;
        Str(StrToReal(Skid^.Dat.Skidka[l].MinNaz):CLitr+1:CMantissa,Skid^.Dat.Skidka[l].MinNaz);
        s:=s+' '+Skid^.Dat.Skidka[l].MinNaz+' '+Kb;
  End;
      End;{For l:=1 To CShkala}

    If Sort > 0 Then
    Begin
     System.Delete(s,1,CArtikul);
     s:=s+Skl^.Dat.BazKod;
    End;

    If SSS Then
    Begin
     ttt^.List^.Insert(NewStr(s));
     ttt^.SetRange(ttt^.List^.Count);
    End;

End;{тест количества}
End;{While}

      Dispose(Skl,Done);
      Dispose(Skid,Done);

     If ((ttt^.List^.Count-1)>=0) Then
      For lk:=0 To ttt^.List^.Count-1 Do
      Begin
       s:=ttt^.GetText(lk,ttt^.List^.Count);
       If Sort>0 Then
       Begin
        TArt:=Copy(s,Ord(s[0])-CArtikul+1,CArtikul);
        Delete(s,Ord(s[0])-CArtikul+1,CArtikul);
       End;
       Writeln(txt,Space+TArt+s);
      End;{for печати}

    Dispose(ttt,Done);
    c:=IoResult;
    Close(SklFile);

   End;{TestRazdel}
End;{For}

c:=IOResult;
Dispose(TempList,Done);
Writeln(txt);
Writeln(txt);
Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt,Space+'=================================================');
Close(txt);
NoInfo;
ViewAsText(Path.ToTemp+'Skidki1.txt',True);
End;
{$Else}

Procedure PrintSKL1(Const Spis:PBox;Const M:MaskaNew; Const Assort,Sort:Word);
Begin
End;

{$EndIF}





End.
