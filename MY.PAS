Procedure CalcMenedger1;
Const
      Arhipov=0; Ilishev=1;
Var f : File;
    R : TRect;
    E : PBufSuperMarketType;
    s : String;
    l : Word;
    RetF : NewVozwratFileType;
    Ret  : PNewVozwratType;
    Razdel1 :PBox;

    Delta,DateOpl,Date : TDAteString;
    NDS,z,AllSkidka,AllItogo,ItogoSkidka,Itogo : Float;
    AllReturn,AllSkidkaReturn,AllZakupka,AllReturnZakupka:Float;
    ww1,ww2,ws,ws2 : TMyString;
    Txt2,txt1 : Text;
    AllDoc : Word;
    DocS : Word;
    Slujba,Current,Cur,sh,VidSkidka,Vid : Word;

    ws1,Space : TMyString;
    AllReturnDoc,RAbday,Start,Stop,Den : LongInt;
    NoScreen : PBox;
    mm : Maska9;
    Key,Distant : Word;
    NameDoc,Names,Otgruz : AllStr;
    DateOtgr,DateOplata: TDateString;
    StartDate,StopDate : TDateString;
    VidReport,c,Count,SelectorOplata : Word;

    FFF : Boolean;
    Doc,Cod,Ag:AllStr;
    Dohod,Dolg : Float;
    ws11,ws22:String;
    SumO,SumZ:AllStr;

    EStrafN,EStrafBN,EStrafV : String[CIZena];
    StrafN: Float;
    StrafBn: Float;
    StrafV: Float;


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
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    TestAgent:=True;
    Break;
   End;{St=Cod}
 End;
End;
End;



Procedure AddAgentSumma(Cod:ArtikulStr;s1,s2,s3{сумма по закупке}:AllStr);
Var L : Boolean;
    st,s : String;
    i : word;
Begin
l:=False;
If (Agent^.List^.Count-1)>=0 Then
Begin
For i:=0 To Agent^.List^.Count-1 Do
 Begin
  st:=Agent^.GetText(i,Agent^.List^.Count);
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    st:=Agent^.GetText(i,Agent^.List^.Count);
    {добавляем отгрузку}

    s:=Copy(st,1+1+CClientKod+1,CIZena);
    System.Delete(st,1+1+CClientKod+1,CIZena);
    MyStr(StrToReal(s)+StrToReal(s1),CIZena,CMantissa,s);
    System.Insert(s,st,1+1+CClientKod+1);


    {добавляем отгрузку по закупочным ценам}
    s:=Copy(st,1+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);
    MyStr(StrToReal(s)+StrToReal(s3),CIZena,CMantissaZ,s);
    System.Insert(s,st,1+1+CClientKod+1+CIZena+1+CIZena+1);


    Agent^.List^.AtFree(i);
    Agent^.SetRange(Agent^.List^.Count);
    Agent^.List^.Insert(NewStr(st));
    Agent^.SetRange(Agent^.List^.Count);
    l:=True;
    Break;
   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;





Procedure AddAgentStraf(Cod:ArtikulStr;straf:Float);
Var L : Boolean;
    st,s : String;
    i : word;
Begin
l:=False;
If (Agent^.List^.Count-1)>=0 Then
Begin
For i:=0 To Agent^.List^.Count-1 Do
 Begin
  st:=Agent^.GetText(i,Agent^.List^.Count);
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    st:=Agent^.GetText(i,Agent^.List^.Count);
    {добавляем отгрузку}
    s:=Copy(st,1+1+CClientKod+1+CIZena+1,CIZena);
    System.Delete(st,1+1+CClientKod+1+CIZena+1,CIZena);
    MyStr(StrToReal(s)+Straf,CIZena,CMantissa,s);
    System.Insert(s,st,1+1+CClientKod+1+CIZena+1);

    Agent^.List^.AtFree(i);
    Agent^.SetRange(Agent^.List^.Count);
    Agent^.List^.Insert(NewStr(st));
    Agent^.SetRange(Agent^.List^.Count);
    l:=True;
    Break;
   End;{St=Cod}
 End;
if Not(l) Then
 MessageBox(^M+#3'Элемент ('+Cod+') в списке не найден!',Nil,mfError+mfCancelButton);
End;
End;


Procedure AddClientOplata(SelectorOplata,VidReport:Word; Cod:ArtikulStr;
                          Doc,Date:TDateString;Dolg:Float;
                          Var f : Text;Var EStrafN,EStrafBN,EStrafV:Float);
Const Space='     ';
Var L : Boolean;
    st,s : String;
    i : word;
    Cl : PBufClientOplataRealizasiaType;
    clf : File{ Of ClientOplataRealizasiaType};
    Find,Shapka : Boolean;
    Straf,StrafN,StrafBN,StrafV : Float;
    c1,Count : Word;
Begin
EStrafN:=0.0000;
EStrafBN:=0.0000;
EStrafV:=0.0000;
StrafN:=0.0000;
StrafBN:=0.0000;
StrafV:=0.0000;
Straf:=0.0000;

Find:=False;
Assign(clf,Path^.Dat.ToClientOplata+Cod+'.cpl');
i:=IOresult;
Reset(clf,SizeOf(ClientOplataRealizasiaType));
i:=IOresult;
If (i<>0) Then
 Begin
  if (VidReport=0) then Writeln(f,Space+'Нет файла оплаты!      Штраф:',EStrafN+EStrafBN+EStrafV:CIZena:CMantissa);
  Exit;
 End;

DelSpace(Doc);
DelSpace(Date);
Shapka:=False;
While Not(Eof(clf)) Do
 Begin
  New(Cl,Init);
  BlockRead(Clf,Cl^.Point,BufferOpl,Count);
For c1:=1 To Count Do
Begin
  Str(StrToInt(Cl^.Point.Dat[c1].Document):CDocNumer,Cl^.Point.Dat[c1].Document);
  DelSpace(Cl^.Point.Dat[c1].Document);
  DelSpace(Cl^.Point.Dat[c1].DateDoc);
  If (Cl^.Point.Dat[c1].Document=Doc) And (Cl^.Point.Dat[c1].DateDoc=Date) And
  (StrToInt(Cl^.Point.Dat[c1].SkladKod)=StrToInt(Rek^.Dat.Kod)) And Not(Cl^.Point.Dat[c1].Vozwrat) Then
   Begin
    Find:=True;

StrafN:=0.0000;
StrafBN:=0.0000;
StrafV:=0.0000;
Straf:=0.0000;

    If (SelectorOplata=0) And (VidReport=0) Then
     Begin
      If Not(Shapka) Then
       Begin
        Writeln(f,Space+'--------------------------------------------------------------------------');
        Writeln(f,Space+'Дата опл    Сумма оплаты   Остаток долга   Текущий штраф Del  Оператор  ');
                        {12345678 123456789012345 123456789012345 123456789012345 1234 123456789012}
        Writeln(f,Space+'--------------------------------------------------------------------------');
       End;{печать шапки}

      If StrToInt(Cl^.Point.Dat[c1].Delta)>0 Then
      Begin
      If StrToInt(Cl^.Point.Dat[c1].Delta)-1>0 Then{в этом месте исключается первый день опоздания}
       Begin
        Straf:=StrToReal(Cl^.Point.Dat[c1].SummaZ)*0.001*(StrToInt(Cl^.Point.Dat[c1].Delta)-1);
        CAse Cl^.Point.Dat[c1].Rashet Of
        0: StrafN:={StrafN+}Straf;
        1: StrafBN:={StrafBN+}Straf;
        2: StrafV:={StrafV+}Straf;
        Else;
        End;{CAse}
       End;

      End
      Else
       Begin
        If (StrToInt(Cl^.Point.Dat[c1].Delta))<0 Then
        Begin
         Straf:=StrToReal(Cl^.Point.Dat[c1].SummaZ)*0.001*(StrToInt(Cl^.Point.Dat[c1].Delta));
         CAse Cl^.Point.Dat[c1].Rashet Of
         0: StrafN:={StrafN+}Straf;
         1: StrafBN:={StrafBN+}Straf;
         2: StrafV:={StrafV+}Straf;
         Else;
         End;{CAse}
        End;
       End;

      Shapka:=True;
      MyStr(Dolg,CIZena,CMantissa,st);
      s:=GetOperatorName(Cl^.Point.Dat[c1].Caption);
      Format(s,CKto);
      MyStr(StrToReal(Cl^.Point.Dat[c1].SummaZ),CIZena,CMantissa,Cl^.Point.Dat[c1].SummaZ);
      Str(StrToInt(Cl^.Point.Dat[c1].Delta):CLitrMantissa+1,Cl^.Point.Dat[c1].Delta);

      Writeln(f,Space+Cl^.Point.Dat[c1].DateC+' '+Cl^.Point.Dat[c1].SummaZ+' '+St+' ',Straf:CIzena:cmantissa,' '+
         Cl^.Point.Dat[c1].Delta+' '+s);
     End{если развернутый вариант оплаты}
     Else
     begin
      If StrToInt(Cl^.Point.Dat[c1].Delta)>0 Then
      Begin
       If StrToInt(Cl^.Point.Dat[c1].Delta)-1>0 Then
       Begin
        Straf:=StrToReal(Cl^.Point.Dat[c1].SummaZ)*0.001*(StrToInt(Cl^.Point.Dat[c1].Delta)-1);
         CAse Cl^.Point.Dat[c1].Rashet Of
         0: StrafN:={StrafN+}Straf;
         1: StrafBN:=Straf;
         2: StrafV:=Straf;
         Else;
         End;{CAse}
       End;
      end
      Else
       Begin
        If (StrToInt(Cl^.Point.Dat[c1].Delta))<0 Then
        Begin
        Straf:=StrToReal(Cl^.Point.Dat[c1].SummaZ)*0.001*(StrToInt(Cl^.Point.Dat[c1].Delta));
         CAse Cl^.Point.Dat[c1].Rashet Of
         0: StrafN:={StrafN+}Straf;
         1: StrafBN:=Straf;
         2: StrafV:=Straf;
         Else;
         End;{CAse}

        End;
       End;

     End;



     (*
     if strtoint(cod) in [16,21,39,19] Then
	 Begin
       If StrafN>0 Then
       StrafN:=StrafN*12.5;
       If StrafBN>0 Then
       StrafBN:=StrafBN*12.5;
       If StrafV>0 Then
       StrafV:=StrafV*12.5;
      End;
     *)


     EStrafN:=EStrafN+StrafN;
     EStrafBN:=EStrafBN+StrafBN;
     EStrafV:=EStrafV+StrafV;

     Dolg :=Dolg-StrToReal(Cl^.Point.Dat[c1].SummaZ);
   End;{Если нужный документ}
End;{For}
 Dispose(Cl,Done);
 End;{While}

If (VidReport=0) Then
Begin
If Find Then
Writeln(f,Space+'                         Штраф:',EStrafN+EStrafBN+EStrafV:CIZena:CMantissa)
Else
Writeln(f,Space+'Оплаты не найдены!       Штраф:',EStrafN+EStrafBN+EStrafV:CIZena:CMantissa);
End;
Close(clf);
i:=IOresult;
End;


Type ArrayRazdelMemory = Record
     RList  : PBox;   {список разделов}
     Employ : Boolean;{признак инициализации списка}
     DocKol : Word;
    End;

 Var i : LongInt;
     SertifKol : LongInt;
     TestE:PSuperMarketType;
     StartLogik:Boolean;
     A : DocumentEditZ;
     Idx : Word;

     Stat : Array [0..MaxStatClient] Of ArrayRazdelMemory;
     Client : PBox;
     Clf : File;
     CLE : PBufClientType;
     ZakupkaOpora:Word;


Procedure NewElement(Kod : Word);
Var R : TRect;
    s : String;
    c : Word;
Begin
R.Assign(0, 0, 0, 0);
Stat[Kod].Employ:=True;
Stat[Kod].DocKol:=0;
Stat[Kod].RList := New(PBox, Init(R, 1, Nil));
Stat[Kod].RList^.NewList(New(PTextCollection, Init(0,1)));
For c:=0 To Razdel1^.List^.Count-1 Do
Begin
 s:=Razdel1^.GetText(c,Razdel1^.List^.Count);
 s:=Copy(s,1+1,CRAzdelKod);
 s:=s+'000'+'│               │               │               │               │';

Stat[Kod].RList^.List^.Insert(
NewStr('│'+s));
     Stat[Kod].RList^.SetRange(Stat[Kod].RList^.List^.Count);
End;{For}
End;




Procedure DoneArrayList;
Var  c : Word;
Begin
For c:=0 To MaxStatClient Do
Begin
 If Stat[c].Employ Then
  Begin
   Dispose(Stat[c].RList,Done);
  End;
End;{For}
End;



Begin
 If Not(DatePeriodDialog(StartDate,StopDate,False)) Then Exit;

{Assign(ClientFile,Path^.Dat.ToClient+'agent.db');
 Reset(ClientFile);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3+'Ошибка открытия файла агентов!',Nil,mfError+mfCancelButton);
   Exit;
  End;}

For c:=0 To MaxStatClient Do
 Begin
  Stat[c].Employ:=False;
  Stat[c].DocKol:=0;
 End;



R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));

If Not(SelectionAgent(Agent)) Then
 Begin
  Dispose(Agent,Done);
  Exit;
 End;

{If Not(eof(ClientFile)) Then Read(ClientFile,ClientElement);
 While Not(Eof(ClientFile)) Do
  Begin
   Read(ClientFile,ClientElement);
   If ClientElement.Employ Then
    Begin
     Agent^.List^.Insert(NewStr('│'+ClientElement.Kod+'│           0.00│           0.00'));
     Agent^.SetRange(Agent^.List^.Count);
    End;
  End;
Close(ClientFile);}

 Start:=DateStringToDate(DateMask,StartDate);
 Stop:=DateStringToDate(DateMask,StopDate);

 Vid:=0;

 Slujba:=0;
 Slujba:=SelectImport(8);
 If Slujba=2 Then
  Begin
   Dispose(Agent,Done);
   Exit;
  End;

{Vid:=SelectImport(6);
 If Vid=2 Then Exit;}

  VidReport:=1;
  VidReport:=SelectImport(19);
 If VidReport=2 Then
  Begin
   Dispose(Agent,Done);
   Exit;
  End;


  If Not(Filtration(mm)) Then
  Begin
   Dispose(Agent,Done);
   Exit;
  End;



 VidSkidka:=1;
If VidReport=0 Then
Begin
 VidSkidka:=SelectImport(7);
 If VidSkidka=2 Then
  Begin
   Dispose(Agent,Done);
   Exit;
  End;
End;


 SelectorOplata:=1;
If VidReport=0 Then
Begin
 SelectorOplata:=SelectImport(10);
 If SelectorOplata=2 Then
  Begin
   Dispose(Agent,Done);
   Exit;
  End;
End;



 Key:=0;
 Distant:=0;
If VidReport=0 Then
Begin
 If Not(KeySorting(Key,Distant,True)) Then
   Begin
   Dispose(Agent,Done);
   Exit;
  End;
End;


 ZakupkaOpora:=0;
 ZakupkaOpora:=SelectImport(17);
 If ZakupkaOpora=2 Then
  Begin
   Dispose(Agent,Done);
   Exit;
  End;




 Space[0]:=#0;
 Assign(Txt1,Path^.Dat.ToTemp+'cmeng.txt');
 l:=IOResult;
 Rewrite(Txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Dispose(Agent,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path^.Dat.ToTemp+'cmeng.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


 Assign(Txt2,Path^.Dat.ToTemp+'cmengerr.txt');
 l:=IOResult;
 Rewrite(Txt2);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(txt1);
   Dispose(Agent,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path^.Dat.ToTemp+'cmengerr.txt'+' Код:'+IntToStr(L,3) ,Nil,
   mfError+mfCancelButton);
   Exit;
  End;



If Distant=0 Then DistanationSorting:=True
Else DistanationSorting:=False;


 Assign(RazdelFile,Path^.Dat.ToRAzdel+'Razdel.db');
 Reset(RazdelFile);
 i:=IOResult;
 If i<>0 Then
  Begin
   DistanationSorting:=True;
   Dispose(Agent,Done);
   MessageBox(^M+#3+'Ошибка открытия файла разделов!',Nil,mfError+mfCancelButton);
   Exit;
  End;

R.Assign(0, 0, 0, 0);
Razdel1 := New(PBox, Init(R, 1, Nil));
Razdel1^.NewList(New(PTextCollection, Init(0,1)));
 While Not(Eof(RazdelFile)) Do
  Begin
   Read(RazdelFile,RazdelElement);
   If (RazdelElement.Employ){ And (RazdelElement.EnableDoc=0)} Then
    Begin                                       {базовая} {возвратыпоБазе}        {оплата}        {закупка}
     Razdel1^.List^.Insert(
     NewStr('│'+RazdelElement.Kod+'000'+'│           0.00│           0.00│           0.00│           0.00│'));
     Razdel1^.SetRange(Razdel1^.List^.Count);
    End;
  End;
Close(RazdelFile);





R.Assign(0,0,0,0);
NoScreen:= New(PBox, Init(R, 1, Nil));
NoScreen^.NewList(New(PTextCollection, Init(0,1)));


Writeln(txt1,Space+'Склад: '+FormKod(Rek^.Dat.Kod)++'  Оператор: '+CurrentPassword);
{
Write(txt1,Space+'Вид отбора:');
Case Vid Of
                     0:Writeln(txt1,'Служба доставки');
1:Writeln(txt1,'Сигаретники');
Else;
End;
}
Write(txt1,Space+'Отображать скидку:');
Case VidSkidka Of
0:Writeln(txt1,'Процентом');
1:Writeln(txt1,'Суммой');
Else;
End;




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
Write(txt1,Space+'Сортировка по:');
 Case Key Of
0{клиент}   :Write(txt1,'Клиенту');
1{дата отгр}:Write(txt1,'Дата отгрузки');
2{дата опл} :Write(txt1,'Дата оплаты');
3{скидка}   :Write(txt1,'Сумма скидки');
4{оплата}   :Write(txt1,'Сумма к оплате');
5{вид док}  :Write(txt1,'Вид документа');
6{Delta}    :Write(txt1,'Срок опоздания');
Else;
End;





Case Distant Of
0{клиент}   :WriteLn(txt1,Space+' По возрастанию');
1{дата отгр}:WriteLn(txt1,Space+' По убыванию');
Else WriteLn(txt1);
End;


Write(txt1,Space+'Вид отчета:');
Case VidReport Of
0:WriteLn(txt1,' Полный ');
1:WriteLn(txt1,' Краткий ');
Else;
End;


Write(txt1,Space+'Опорная закупка:');
Case ZakupkaOpora Of
0{клиент}   :WriteLn(txt1,Space+' Закупка для бухгалтерии');
1{дата отгр}:WriteLn(txt1,Space+' Закупка 2');
Else WriteLn(txt1);
End;

Writeln(txt1);
Writeln(txt1,Space,'     СПРАВКА ПО ОПЛАЧЕННЫМ ОТГРУЗКАМ ЗА ПЕРИОД с '+StartDate+' по '+StopDate);
Writeln(txt1,Space+'┌─────────────────────────────────────────────────────────────────────────────────────┐');
Writeln(txt1,Space+'│N  Клиент               Док. Д отгруз Док. Д оплат.    Скидка  Сумма к опл. Вид. Del │');
Writeln(txt1,Space+'└─────────────────────────────────────────────────────────────────────────────────────┘');
                   {123 12345678901234567890 1234 12345678 1234 12345678 123456789 1234567890123 1234 1234}


AllItogo:=0;
AllSkidka:=0;
AllZakupka:=0;
AllDoc:=0;
SertifKol:=0;


EStrafN[0]:=#0;
EStrafBN[0]:=#0;
EStrafV[0]:=#0;
StrafV:=0;
StrafN:=0;
StrafBn:=0;


DInfo('Минуточку...');

FFF:=ProdagaWindow;

For Den:=Start To Stop Do
Begin
 Date:=DateToDateString(DateMask,DEn);
 Assign(F,Path^.Dat.ToMarket+Date+'.mrk');
 DInfoMsgShkala('Просматриваю продажи за '+Date+' ...',Start,Stop,Den);

 l:=IOResult;
 Reset(f,SizeOf(SuperMArketType));
 l:=Ioresult;
 If L <> 0 Then
  Begin
   {MessageBox(^M+#3'Не найден файл '+Path^.Dat.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);}
   Writeln(txt2,'Не найден файл продаж за '+Date+'  "'+DayString[DayOfWeek(DAteStringToDate(DAteMask,Date))]+'"'+
   +' Код:'+IntToStr(L,3));

  End;
If l=0 Then
 Begin
  While Not (Eof(f)) Do
   Begin
      New(E,Init);
      Count:=0;
      ReadBufMArket(f,E,Count);
For c:=1 To Count Do
Begin
If E^.Point.Dat[c].Active Then
    If (E^.Point.Dat[c].OperatorSelector=0) And TestAgent(E^.Point.Dat[c].AgentKod)
       And (E^.Point.Dat[c].DocSelector in [0,1,2,3,4])
       Then
Begin
        Docs:=0;
        If (E^.Point.Dat[c].Realiz)  Then
       Begin
         Case E^.Point.Dat[c].DocSelector Of
         0:Docs:=7;
         1:Docs:=5;
         3:Docs:=6;
         4:Docs:=8;
         Else ;
         End;
       End
        Else
              Begin
            Docs:=E^.Point.Dat[c].DocSelector;
           End;
{фильтр документов подлежащих обработке}

        If mm[Docs+1]=1 Then
       Begin
        ProdagaWindow:=False;


        {настройка на вторую закупку}
        If ZakupkaOpora=1 Then ConvertMarket(E,c);

        For Cur:=1 To E^.Point.Dat[c].Amount Do
         Begin
          If Not(TestRazdelMemory(Copy(E^.Point.Dat[c].MarketElement[cur].BazKod,1,CRazdelKod),Razdel1)) Then
           Begin
            s:=Razdel1^.GetText(
            LocationR(Razdel1,E^.Point.Dat[c].MarketElement[Cur].BazKod,ProdagaWindow),Razdel1^.List^.Count);
            ws1:=Copy(s,1+1+CArtikul+1,CIZena);{отгрузка по базовым ценам}
            ww1:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);{отгрузка по ценам к оплате}
            ww2:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{отгрузка по з/ценам}


            {считаем отгрузку по базовым ценам}
            MyStr(StrToReal(ws1)+
            StrToInt(E^.Point.Dat[c].MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Point.Dat[c].MArketElement[Cur].Input.Zena),CIZena,CMantissa,ws1);
            Delete(s,1+1+CArtikul+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1);

            {считаем отгрузку по ценам к оплате}
            Case E^.Point.Dat[c].SkidkaSelector Of
            0:Begin{скидка автоматическая}
               MyStr(StrToReal(E^.Point.Dat[c].MarketElement[cur].Input.Zena)/
               (1+StrToReal(E^.Point.Dat[c].MarketElement[cur].Input.Proz)/100),CZena,CMantissa,
                        E^.Point.Dat[c].MarketElement[cur].Input.Zena);
              End;
            1:Begin{скидка ручная}
                MyStr(StrToReal(E^.Point.Dat[c].MarketElement[Cur].Input.Zena)-
                StrToReal(E^.Point.Dat[c].MarketElement[Cur].Input.Skidka),CZena,CMantissa,
                         E^.Point.Dat[c].MarketElement[Cur].Input.Zena);
               End;
            Else;
            End;

            MyStr(StrToReal(ww1)+
            StrToInt(E^.Point.Dat[c].MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Point.Dat[c].MArketElement[Cur].Input.Zena),CIZena,CMantissa,ww1);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
            Insert(ww1,s,1+1+CArtikul+1+CIZena+1+CIZena+1);

            {считаем отгрузку по закупочным ценам}
            MyStr(StrToReal(ww2)+
            StrToInt(E^.Point.Dat[c].MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Point.Dat[c].MArketElement[Cur].Input.Zakupka),CIZena,CMantissaZ,ww2);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            Insert(ww2,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1);

            Razdel1^.List^.Atfree(LocationR(Razdel1,E^.Point.Dat[c].MarketElement[Cur].BazKod,ProdagaWindow));
            Razdel1^.SetRange(Razdel1^.List^.Count);
            Razdel1^.List^.Insert(NewStr(s));
            Razdel1^.SetRange(Razdel1^.List^.Count);


            {заполняем персональную статистику}
            Idx:=StrToInt(E^.Point.Dat[c].ClientKod);

           If Not Stat[Idx].Employ Then
           Begin
            NewElement(Idx);
           End;
            {дальше идет код отвечающий за расчет по деталям для каждого клиента}

            s:=Stat[Idx].RList^.GetText(
            LocationR(Stat[Idx].RList,E^.Point.Dat[c].MarketElement[Cur].BazKod,ProdagaWindow),Stat[Idx].RList^.List^.Count);
            ws1:=Copy(s,1+1+CArtikul+1,CIZena);{отгрузка по базовым ценам}
            ww1:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);{отгрузка по ценам к оплате}
            ww2:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{отгрузка по з/ценам}

            {восстанавливаем старую цену}
            E^.Point.Dat[c].MArketElement[Cur].Input.Zena:=
            E^.Point.Dat[c].MArketElement[Cur].Input.R_Zena;

            {считаем отгрузку по базовым ценам}
            MyStr(StrToReal(ws1)+
            StrToInt(E^.Point.Dat[c].MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Point.Dat[c].MArketElement[Cur].Input.Zena),CIZena,CMantissa,ws1);
            Delete(s,1+1+CArtikul+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1);

            {считаем отгрузку по ценам к оплате}
            Case E^.Point.Dat[c].SkidkaSelector Of
            0:Begin{скидка автоматическая}
               MyStr(StrToReal(E^.Point.Dat[c].MarketElement[cur].Input.Zena)/
               (1+StrToReal(E^.Point.Dat[c].MarketElement[cur].Input.Proz)/100),CZena,CMantissa,
                        E^.Point.Dat[c].MarketElement[cur].Input.Zena);
              End;
            1:Begin{скидка ручная}
                MyStr(StrToReal(E^.Point.Dat[c].MarketElement[Cur].Input.Zena)-
                StrToReal(E^.Point.Dat[c].MarketElement[Cur].Input.Skidka),CZena,CMantissa,
                         E^.Point.Dat[c].MarketElement[Cur].Input.Zena);
               End;
            Else;
            End;

            MyStr(StrToReal(ww1)+
            StrToInt(E^.Point.Dat[c].MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Point.Dat[c].MArketElement[Cur].Input.Zena),CIZena,CMantissa,ww1);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
            Insert(ww1,s,1+1+CArtikul+1+CIZena+1+CIZena+1);

            {считаем отгрузку по закупочным ценам}
            MyStr(StrToReal(ww2)+
            StrToInt(E^.Point.Dat[c].MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Point.Dat[c].MArketElement[Cur].Input.Zakupka),CIZena,CMantissaZ,ww2);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            Insert(ww2,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1);

            Stat[Idx].RList^.List^.Atfree(LocationR(Stat[Idx].RList,E^.Point.Dat[c].MarketElement[Cur].BazKod,ProdagaWindow));
            Stat[Idx].RList^.SetRange(Stat[Idx].RList^.List^.Count);
            Stat[Idx].RList^.List^.Insert(NewStr(s));
            Stat[Idx].RList^.SetRange(Stat[Idx].RList^.List^.Count);


           End;
         End;


         New(TestE,Init);
         StartLogik:=False;

         If E^.Point.Dat[c].Realiz Then
         Begin
          A.EditPosition:=E^.Point.Dat[c].DocReal;
          A.D:=DateToDateString(DateMask,E^.Point.Dat[c].DocDate);
          If GetMarket1(A,TestE) Then StartLogik:=True;
         End
         Else
          Begin
           TestE^.Dat:=E^.Point.Dat[c];
           StartLogik:=True;
          End;

          If StartLogik Then
Begin
        For Cur:=1 To TestE^.Dat.AmountS Do
         Begin
          If Not(TestRazdelMemory(Copy(TestE^.Dat.DocumentElement[cur].BazKod,1,CRazdelKod),Razdel1)) Then
           Begin
            s:=Razdel1^.GetText(
            LocationR(Razdel1,TestE^.DAt.DocumentElement[Cur].BazKod,ProdagaWindow),Razdel1^.List^.Count);
            ws1:=Copy(s,1+1+CArtikul+1,CIZena);{отгрузка по базовым ценам}
            ww1:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);{отгрузка по ценам к оплате}
            ww2:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{отгрузка по з/ценам}
            {считаем отгрузку по базовым ценам}
            MyStr(StrToReal(ws1)+
            StrToInt(TestE^.DAt.DocumentElement[Cur].Input.Kol)*
            StrToReal(TestE^.DAt.DocumentElement[Cur].Input.Zena),CIZena,CMantissa,ws1);
            Delete(s,1+1+CArtikul+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1);

            {считаем отгрузку по ценам к оплате}
            Case TestE^.DAt.SkidkaSelector Of
            {
            0:Begin
               MyStr(StrToReal(TestE^.DAt.DocumentElement[cur].Input.Zena)/
               (1+StrToReal(TestE^.DAt.DocumentElement[cur].Input.Proz)/100),CZena,CMantissa,
                        TestE^.DAt.DocumentElement[cur].Input.Zena);
              End;
            }
            1:Begin{скидка ручная}
                MyStr(StrToReal(TestE^.DAt.DocumentElement[Cur].Input.Zena)-
                StrToReal(TestE^.DAt.DocumentElement[Cur].Input.Skidka),CZena,CMantissa,
                         TestE^.DAt.DocumentElement[Cur].Input.Zena);
               End;
            Else;
            End;

            MyStr(StrToReal(ww1)+
            StrToInt(TestE^.DAt.DocumentElement[Cur].Input.Kol)*
            StrToReal(TestE^.DAt.DocumentElement[Cur].Input.Zena),CIZena,CMantissa,ww1);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
            Insert(ww1,s,1+1+CArtikul+1+CIZena+1+CIZena+1);

            {считаем отгрузку по закупочным ценам}
            MyStr(StrToReal(ww2)+
            StrToInt(TestE^.DAt.DocumentElement[Cur].Input.Kol)*
            StrToReal(TestE^.DAt.DocumentElement[Cur].Input.Zakupka),CIZena,CMantissaZ,ww2);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            Insert(ww2,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1);

            Razdel1^.List^.Atfree(LocationR(Razdel1,TestE^.DAt.DocumentElement[Cur].BazKod,ProdagaWindow));
            Razdel1^.SetRange(Razdel1^.List^.Count);
            Razdel1^.List^.Insert(NewStr(s));
            Razdel1^.SetRange(Razdel1^.List^.Count);


            {расчитываем по сертификатам}
            Idx:=StrToInt(TestE^.Dat.ClientKod);

           If Not Stat[Idx].Employ Then
           Begin
            NewElement(Idx);
           End;

            s:=Stat[Idx].RList^.GetText(
            LocationR(Stat[Idx].RList,TestE^.DAt.DocumentElement[Cur].BazKod,ProdagaWindow),Stat[Idx].RList^.List^.Count);
            ws1:=Copy(s,1+1+CArtikul+1,CIZena);{отгрузка по базовым ценам}
            ww1:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);{отгрузка по ценам к оплате}
            ww2:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);{отгрузка по з/ценам}

            {восстанавливаем старую цену}
            TestE^.DAt.DocumentElement[Cur].Input.Zena:=
            TestE^.DAt.DocumentElement[Cur].Input.R_Zena;

            {считаем отгрузку по базовым ценам}
            MyStr(StrToReal(ws1)+
            StrToInt(TestE^.DAt.DocumentElement[Cur].Input.Kol)*
            StrToReal(TestE^.DAt.DocumentElement[Cur].Input.Zena),CIZena,CMantissa,ws1);
            Delete(s,1+1+CArtikul+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1);

            {считаем отгрузку по ценам к оплате}
            Case TestE^.DAt.SkidkaSelector Of
            1:Begin{скидка ручная}
                MyStr(StrToReal(TestE^.DAt.DocumentElement[Cur].Input.Zena)-
                StrToReal(TestE^.DAt.DocumentElement[Cur].Input.Skidka),CZena,CMantissa,
                TestE^.DAt.DocumentElement[Cur].Input.Zena);
               End;
            Else;
            End;

            MyStr(StrToReal(ww1)+
            StrToInt(TestE^.DAt.DocumentElement[Cur].Input.Kol)*
            StrToReal(TestE^.DAt.DocumentElement[Cur].Input.Zena),CIZena,CMantissa,ww1);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
            Insert(ww1,s,1+1+CArtikul+1+CIZena+1+CIZena+1);

            {считаем отгрузку по закупочным ценам}
            MyStr(StrToReal(ww2)+
            StrToInt(TestE^.DAt.DocumentElement[Cur].Input.Kol)*
            StrToReal(TestE^.DAt.DocumentElement[Cur].Input.Zakupka),CIZena,CMantissaZ,ww2);
            Delete(s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
            Insert(ww2,s,1+1+CArtikul+1+CIZena+1+CIZena+1+CIZena+1);

            Stat[Idx].RList^.List^.Atfree(LocationR(Stat[Idx].RList,TestE^.DAt.DocumentElement[Cur].BazKod,ProdagaWindow));
            Stat[Idx].RList^.SetRange(Stat[Idx].RList^.List^.Count);
            Stat[Idx].RList^.List^.Insert(NewStr(s));
            Stat[Idx].RList^.SetRange(Stat[Idx].RList^.List^.Count);



           End;
         End;
         SertifKol:=SertifKol+TestE^.Dat.AmountS;
End;{getMarket1}

        Dispose(TestE,Done);

        Inc(AllDoc);
        s:=IntToStr(AllDoc,3);
        RFormat(s,CLitrMantissa);
        ws:=GetClientField(FClient,E^.Point.Dat[c].ClientKod,E^.Point.Dat[c].OperatorSelector);


        If Not Stat[StrToInt(E^.Point.Dat[c].ClientKod)].Employ Then
         Begin
          NewElement(StrToInt(E^.Point.Dat[c].ClientKod));
         End;
         Inc(Stat[StrToInt(E^.Point.Dat[c].ClientKod)].DocKol);

        Format(ws,CClient);
        Names:=ws;
        s:={s+' '}ws;
        Docs:=0;
        If (E^.Point.Dat[c].Realiz)  Then
          Begin
           Delta:=CalcSrokOpozdania(E^.Point.Dat[c].ClientKod,E^.Point.Dat[c].DocReal,
		 DateToDateString(DateMask,E^.Point.Dat[c].DocDate),
                 E^.Point.Dat[c].DateC);
           DelSpace(Delta);
           RFormat(Delta,CLitrMantissa+1);
         Case E^.Point.Dat[c].DocSelector Of
         0:Docs:=7;
         1:Docs:=5;
         3:Docs:=6;
         4:Docs:=8;
         Else ;
         End;
          {E^.Dat.DateC:=E^.Dat.DocDate;
           E^.Dat.Document:=E^.Dat.DocReal;}
          End
        Else
              Begin
            Docs:=E^.Point.Dat[c].DocSelector;
                  Delta:='   0';
                  E^.Point.Dat[c].DocDate:=DateStringToDate(DateMask,E^.Point.Dat[c].DateC);
            E^.Point.Dat[c].DocReal:=E^.Point.Dat[c].Document;
           End;

        If mm[Docs+1]=1 Then
       Begin

        DelSpace(E^.Point.Dat[c].Document);
        RFormat(E^.Point.Dat[c].Document,CDocNumer{-1});
        DelSpace(E^.Point.Dat[c].DocReal);
        RFormat(E^.Point.Dat[c].DocReal,CDocNumer{-1});

        Format(E^.Point.Dat[c].DateC,CDate);
        DateOtgr:=DateToDateString(DateMask,E^.Point.Dat[c].DocDate);
        DateOplata:=E^.Point.Dat[c].DateC;
        E^.Point.Dat[c].DateC:=Copy(E^.Point.Dat[c].DateC,1,CDate{-3});{сокращаем дату}
        (*
        E^.Point.Dat[c].DocDate:=Copy(
	   DateToDateString(DateMask,E^.Point.Dat[c].DocDate),1,CDate{-3});{сокращаем дату}
        *)
        DateOpl:=Date;

        Format(DateOpl,CDate);
        DateOpl:=Copy(DateOpl,1,CDate{-3});{сокращаем дату}

        ws[0]:=#0;
        MyStr(StrToReal(E^.Point.Dat[c].SummaZ)+StrToReal(E^.Point.Dat[c].Skidka),CIZena-2,CMantissa,ws);
        Otgruz:=ws;
        MyStr(StrToReal(E^.Point.Dat[c].Skidka),CIZena-6,CMantissa,E^.Point.Dat[c].Skidka);
        MyStr(StrToReal(E^.Point.Dat[c].SummaZ),CIZena-2,CMantissa,E^.Point.Dat[c].SummaZ);

        AllItogo:=AllItogo+StrToreal(E^.Point.Dat[c].SummaZ);
        AllZakupka:=AllZakupka+StrToReal(E^.Point.Dat[c].SummaZakupka);
        AllSkidka:=AllSkidka+StrToreal(E^.Point.Dat[c].Skidka);
        {
        If E^.Dat.Document='122' Then
         Begin
          Readln;
         End;
        }
        If VidSkidka=0 Then
        Begin
        If (StrToReal(E^.Point.Dat[c].Skidka)<=0) Then
         Begin
          If Abs(StrToReal(ws))>0.009 Then
          MyStr(StrToReal(E^.Point.Dat[c].Skidka)/StrToReal(ws)*100,CIZena-6,CMantissa,E^.Point.Dat[c].Skidka)
          Else MyStr(0.00,CIZena-6,CMantissa,E^.Point.Dat[c].Skidka);
         End
         Else
          Begin
           If Abs(StrToReal(ws)-StrToReal(E^.Point.Dat[c].Skidka))>0.009 Then
           MyStr(
                   (StrToReal(ws)/
                    (StrToReal(ws)-StrToReal(E^.Point.Dat[c].Skidka))-1)*100,CIZena-6,CMantissa,E^.Point.Dat[c].Skidka)
           Else
             MyStr(99.99,CIZena-6,CMantissa,E^.Point.Dat[c].Skidka);
          End;
        End;

        s:=s+' '+E^.Point.Dat[c].DocReal+' '+
	   DateToDateString(DateMask,E^.Point.Dat[c].DocDate)+' '+E^.Point.Dat[c].Document+' '+
           E^.Point.Dat[c].DateC+' '+{ws+' '+}
        +E^.Point.Dat[c].Skidka+' '+E^.Point.Dat[c].SummaZ;
        If (E^.Point.Dat[c].DocSelector in [0,1,2,3,4]) And Not(E^.Point.Dat[c].Realiz) Then
        Begin
         Case E^.Point.Dat[c].DocSelector Of
         0:NameDoc:=' нСП ';
         1:NameDoc:=' нТЧ*';
         2:NameDoc:=' нФЛ*';
         3:NameDoc:=' нСФ*';
         4:NameDoc:=' нСФБ';
         Else NameDoc:='     ';
         End;
         s:=s+NameDoc;
        End
           Else
        Begin
         Case E^.Point.Dat[c].DocSelector Of
         0:NameDoc:=' ДЕБ ';
         1:NameDoc:=' ДЕБ*';
         3:NameDoc:=' ДСФ*';
         4:NameDoc:=' ДСФБ';
         Else NameDoc:='     ';
         End;
         s:=s+NameDoc;
        End;
        s:=s+' '+Delta+' '+E^.Point.Dat[c].ClientKod;
        RFormatZerro(Delta,CLitrMantissa+1);
        {Writeln(txt1,Space+s);}

        Str(DateStringToDate(DateMask,DateOtgr):6,DateOtgr);
        Str(DateStringToDate(DateMask,DateOplata):6,DateOplata);

        Case Key Of
        0{клиент}   :s:=Names+' '+s;
        1{дата отгр}:s:=DateOtgr+' '+s;
        2{дата опл} :s:=DateOplata+' '+s;
        3{скидка}   :Begin
                      RFormatZerro(E^.Point.Dat[c].Skidka,(CIZena-6));
                      If Pos('-',E^.Point.Dat[c].Skidka)>0 Then
                      Begin
                       E^.Point.Dat[c].Skidka[Pos('-',E^.Point.Dat[c].Skidka)]:='0';
                       E^.Point.Dat[c].Skidka[1]:='-';
                      End;
                         s:=E^.Point.Dat[c].Skidka+' '+s;
                     End;
        4{оплата}   :s:=E^.Point.Dat[c].SummaZ+' '+s;
        5{вид док}  :s:=NameDoc+' '+s;
        6{Delta}    :s:=Delta+' '+s;
        Else;
        End;

        s:=s+' '+E^.Point.Dat[c].AgentKod;
        AddAgentSumma(E^.Point.Dat[c].AgentKod,E^.Point.Dat[c].SummaZ,'0.00',E^.Point.Dat[c].SummaZakupka);

      If NoScreen^.List^.Count<=MaxCollectionSize-1 Then
      Begin{отключает вставку объектов в память если больше 16000}
        NoScreen^.List^.Insert(NewStr(s));
        NoScreen^.SetRange(NoScreen^.List^.Count);
      End;
       End;{If mm[Docs]}
 End;{If mm[Docs]}
End;{If}
End;{For по буферу}
Dispose(E,Done);
   End;{While}
   Close(f);
 End;{If l=0}
End;{For}
{Writeln(Txt1);}

NoInfoMsg;

DInfoMsg('Сохраняю промежуточные результаты расчета ...',True);

If NoScreen^.List^.Count>=1 Then
 Begin
  For Den:=0 To NoScreen^.List^.Count-1 Do
   Begin
     s:=NoScreen^.GetText(Den,NoScreen^.List^.Count);
        Case Key Of
        0{клиент}   :Delete(s,1,CClient+1);
        1{дата отгр}:Delete(s,1,CKol+1+1);
        2{дата опл} :Delete(s,1,CKol+1+1);
        3{скидка}   :Delete(s,1,(CIZena-6)+1);
        4{оплата}   :Delete(s,1,(CIZena-2)+1);
        5{вид док}  :Delete(s,1,(CKol)+1);
        6{Delta}    :Delete(s,1,(CLitrMantissa+1)+1);
        Else;
        End;

     Otgruz:=IntToStr(Den+1,CLitrMantissa);
     RFormat(Otgruz,CLitrMantissa);

     Cod:=Copy(s,Ord(s[0])-CClientKod*2,CClientKod);
     Ag:=Copy(s,Ord(s[0])-CClientKod+1,CClientKod);
     Doc:=Copy(s,1+CClient+1,CDocnumer);
     DelSpace(doc);
     date:=Copy(s,1+CClient+1+CDocnumer+1,CDate);
     DelSpace(Date);
     ws2:=Copy(s,1+CClient+1+(CDocnumer+1+CDate+1)*2+CIZena-6+1,CIZena-2);
     Dolg:=StrToReal(Copy(s,1+CClient+1+(CDocnumer+1+CDate+1)*2+CIZena-6+1,CIZena-2));
     s:=Otgruz+' '+s;
     Delete(s,Ord(s[0])-CClientKod*2-1,1+CClientKod*2+1);

     If VidReport=0 Then
     Begin
     If Slujba=0 Then
     Writeln(txt1,Space+'    Доставка: '+GetAgentField(FClient,Ag)+' ('+Ag+')'^M+Space+s)
     Else
     Writeln(txt1,Space+s);
     End;

     StrafV:=0.0000;
     StrafN:=0.0000;
     StrafBn:=0.0000;


     If (Pos(' ДЕБ ',s)>0)  Or (Pos(' ДЕБ*',s)>0)
        Or (Pos(' ДСФ*',s)>0)  Or (Pos(' ДСФБ',s)>0) Then
        Begin
     AddClientOplata(SelectorOplata,VidReport,Cod,Doc,Date,Dolg,txt1,StrafN,StrafBN,StrafV);
     AddAgentStraf(Ag,StrafN+StrafV+StrafBN);
     MyStr(StrToReal(EStrafN)+StrafN,CIZena,CMAntissa,EStrafN);
     MyStr(StrToReal(EStrafBN)+StrafBN,CIZena,CMAntissa,EStrafBN);
     MyStr(StrToReal(EStrafV)+StrafV,CIZena,CMAntissa,EStrafV);
        End;

   End;
 End;
Writeln(Txt1);

Writeln(txt1,Space+'────────────────────────────────────────────────────────────────────────────────────-');

Writeln(Txt1,Space+'                                                    Всего документов: ',
AllDoc:CIZena);
Writeln(Txt1,Space+
'                                                      Всего к оплате: ',RecognizReal(AllItogo,CIZena,CMantissa));
Writeln(Txt1,Space+
'                                                    Всего по З/Ценам: ',RecognizReal(AllZakupka,CIZena,CMantissaZ));
Writeln(Txt1,Space+
'                                                         Всего доход: ',RecognizReal(AllItogo-AllZakupka,CIZena,CMantissaZ));

If AllZakupka>0.009 Then
Writeln(Txt1,Space+
'                                                      Рентабельность: ',RecognizReal((AllItogo-
AllZakupka)/AllZakupka*100,CIZena,CMantissa)+' %');



Writeln(Txt1,Space+
'                                                     Начислено штраф: ',RecognizReal(StrToReal(EStrafN)+
StrToReal(EStrafBN)+StrToReal(EStrafV),CIZena,CMantissa));
Writeln(Txt1,Space+
'                                                         в том числе  ');

Writeln(Txt1,Space+
'                                                            наличные: '+RecognizReal(StrToreal(EStrafN),CIZena,CMantissaZ));
Writeln(Txt1,Space+
'                                                         безналичные: '+RecognizReal(StrToreal(EStrafBN),CIZena,CMantissaZ));
Writeln(Txt1,Space+
'                                                             вексель: '+RecognizReal(StrToreal(EStrafV),CIZena,CMantissaZ));

Writeln(Txt1,Space+
'                                                        Всего скидка: ',RecognizReal(AllSkidka,CIZena,CMantissa));
Writeln(Txt1,Space+
'                                                     Всего со склада: ',RecognizReal(AllItogo+AllSkidka,CIZena,CMantissa));
Writeln(Txt1,Space+
'                                    Всего израсходовано сертификатов: ',SertifKol:CIZena);

NoInfoMsg;

Dispose(NoScreen,Done);
DistanationSorting:=True;

AllReturn:=0;
AllReturnZakupka:=0;
AllSkidkaReturn:=0;
AllReturnDoc:=0;

Space:='   ';
Writeln(txt1);
Writeln(txt1,Space+'СПРАВКА О ВОЗВРАТАХ ПО ОПЛАЧЕННЫМ документам за ПЕРИОД с '+StartDate+' по '+StopDate);
Writeln(txt1,Space+'┌───────────────────────────────────────────────────────────────────────────────┐');
Writeln(txt1,Space+'│N  Клиент               Док.Дата отг.Взв.Дата взв. Сумма возвр.  Сумма скидки п│');
Writeln(txt1,Space+'└───────────────────────────────────────────────────────────────────────────────┘');
                   {123 12345678901234567890 123 12345789 123 12345678 1234567890123 1234567890123 1 123}


New(Ret,Init);

For Den:=Start To Stop Do
Begin
 Date:=DateToDateString(DateMask,DEn);
 DInfoMsgShkala('Просматриваю возвраты за '+Date+' ...',Start,Stop,Den);
 Assign(RetF,Path^.Dat.ToReturn+Date+'.vzw');
 l:=IOResult;
 Reset(Retf);
 l:=Ioresult;
If l=0 Then
 Begin
  While Not (Eof(Retf)) Do
   Begin
      ReadNewVozwrat(Retf,Ret);

If (Ret^.Dat.OperatorSelector=0) Then
    If (Ret^.Dat.StatusDoc=0) And
    {(TestClientName(GetClientField(FClient,Ret^.Dat.MakeKod,Ret^.Dat.OperatorSelector))=Vid)}
       (Ret^.Dat.VidDocument in [0,1,2,3])
       Then
       Begin
       If CalcAgentfromMrk(Ret^.Dat.BasisDoc,Ret^.Dat.BasisDate,Ag) Then
Begin
    If TestAgent(Ag) Then
Begin
        {настройка на вторую закупку}
        If ZakupkaOpora=1 Then ConvertReturn(Ret);

        For Cur:=1 To Ret^.Dat.Amount Do
         Begin
          If Not(TestRazdelMemory(Ret^.Dat.VozwratElement[cur].BazKod,Razdel1)) Then
           Begin
            s:=Razdel1^.GetText(
            LocationR(Razdel1,Ret^.Dat.VozwratElement[Cur].BazKod,ProdagaWindow),Razdel1^.List^.Count);
            ws1:=Copy(s,1+1+CArtikul+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws1)+
                      StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
                StrToReal(Ret^.DAt.VozwratElement[Cur].Input.Zena),CIZena,CMantissa,ws1);
            Delete(s,1+1+CArtikul+1+CIZena+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1+CIZena+1);
            Razdel1^.List^.Atfree(LocationR(Razdel1,Ret^.Dat.VozwratElement[Cur].BazKod,ProdagaWindow));
            Razdel1^.SetRange(Razdel1^.List^.Count);
            Razdel1^.List^.Insert(NewStr(s));
            Razdel1^.SetRange(Razdel1^.List^.Count);


            {детализация по возвратам клиентов}
            Idx:=StrToInt(Ret^.Dat.MakeKod);

           If Not Stat[Idx].Employ Then
           Begin
            NewElement(Idx);
           End;
            s:=Stat[Idx].RList^.GetText(
            LocationR(Stat[Idx].RList,Ret^.Dat.VozwratElement[Cur].BazKod,ProdagaWindow),Stat[Idx].RList^.List^.Count);
            ws1:=Copy(s,1+1+CArtikul+1+CIZena+1,CIZena);
            MyStr(StrToReal(ws1)+
                      StrToInt(Ret^.DAt.VozwratElement[Cur].Input.Kol)*
                StrToReal(Ret^.DAt.VozwratElement[Cur].Input.Zena),CIZena,CMantissa,ws1);
            Delete(s,1+1+CArtikul+1+CIZena+1,CIZena);
            Insert(ws1,s,1+1+CArtikul+1+CIZena+1);
            Stat[Idx].RList^.List^.Atfree(LocationR(Stat[Idx].RList,Ret^.Dat.VozwratElement[Cur].BazKod,ProdagaWindow));
            Stat[Idx].RList^.SetRange(Stat[Idx].RList^.List^.Count);
            Stat[Idx].RList^.List^.Insert(NewStr(s));
            Stat[Idx].RList^.SetRange(Stat[Idx].RList^.List^.Count);
           End;
         End;

        Docs:=0;

        If (Ret^.Dat.VidDocument in [0,1]) Then{наличная продажа}
         Begin
         Case Ret^.Dat.DocSelector Of
         0:Docs:=7;
         1:Docs:=5;
         3:Docs:=6;
         4:Docs:=8;
         Else ;
         End;
         End
        Else
         Begin {закрытая консигнация}
          Docs:=Ret^.Dat.DocSelector;
         End;

        If mm[Docs+1]=1 Then
       Begin
        DelSpace(Ret^.Dat.BasisDate);
{       If (DateStringToDate(DateMask,Ret^.Dat.BasisDate)<Start) Then}
        Begin
        Inc(AllReturnDoc);
        s:=IntToStr(AllReturnDoc,3);
        RFormat(s,CLitrMantissa);
        ws:=GetClientField(FClient,Ret^.Dat.MakeKod,Ret^.Dat.OperatorSelector);
        Format(ws,CClient);
        s:=s+' '+ws;

        DelSpace(Ret^.Dat.Document);
        RFormat(Ret^.Dat.Document,CDocNumer-1);
        Format(REt^.Dat.DateC,CDate);

        DelSpace(Ret^.Dat.BasisDoc);
        RFormat(Ret^.Dat.BasisDoc,CDocNumer-1);
        Format(REt^.Dat.BasisDate,CDate);

        MyStr(StrToReal(RET^.Dat.SummaR)-StrToReal(RET^.Dat.Skidka),CIZena-2,CMantissa,ws);
        MyStr(StrToReal(RET^.Dat.Skidka),CIZena-2,CMantissa,RET^.Dat.Skidka);
        MyStr(StrToReal(RET^.Dat.SummaR),CIZena-2,CMantissa,RET^.Dat.SummaR);

        AllReturn:=AllReturn+StrToreal(RET^.Dat.SummaR);
        AllReturnZakupka:=AllReturnZakupka+StrToreal(RET^.Dat.SummaZakupka);
        AllSkidkaReturn:=AllSkidkaReturn+StrToreal(Ret^.Dat.Skidka);
        s:=s+' '+Ret^.Dat.BasisDoc+' '+Ret^.Dat.BasisDate+' '+Ret^.Dat.Document+' '+REt^.Dat.DateC+' '+
        +Ret^.Dat.SummaR+' '+Ret^.Dat.Skidka;
        If (Ret^.Dat.VidDocument in [0,1]) Then s:=s+' '+'н' Else s:=s+'  ';
     If Slujba=0 Then
     Writeln(txt1,Space+'    Доставка: '+GetAgentField(FClient,Ag)+' ('+Ag+')'^M+Space+s)
     Else
     Writeln(txt1,Space+s)
        End;
       End;{mm[docs+1]=1}
End;{TestAgent(Ag)}
End;{CalcAgentfromMrk}
       End;{If}
   End;{While}
   Close(Retf);
 End;{If l=0}
End;{For}

NoInfoMsg;

Dispose(Ret,Done);

ProdagaWindow:=FFF;


DInfoMsg('Сохраняю промежуточные результаты расчета ...',True);


Writeln(Txt1);
Writeln(txt1,Space+'───────────────────────────────────────────────────────────────────────────────-');

Writeln(Txt1,Space+'                                        Всего документов: ',AllReturnDoc:CIZena);
Writeln(Txt1,Space+
                   '                         Всего возврат по ценам отгрузки: ',RecognizReal(AllReturn-AllSkidkaReturn,
                            CIZena,CMantissa));

Writeln(Txt1,Space+
                   '                                Всего возврат по З/Ценам: ',RecognizReal(AllReturnZakupka,
                            CIZena,CMantissaZ));

Writeln(Txt1,Space+
                   '                                   Всего упущенный доход: ',RecognizReal(AllReturn-AllSkidkaReturn-
                            AllReturnZakupka,
                            CIZena,CMantissa));

Writeln(Txt1,Space+
                   '                                   Всего скидка возврата: ',RecognizReal(AllSkidkaReturn,
                            CIZena,CMantissa));
Writeln(Txt1,Space+
                   '                          Всего возврат по базовым ценам: ',RecognizReal(AllReturn,CIZena,CMantissa));

If (Razdel1^.List^.Count-1)>=0 Then
Begin
{Space:='        ';}
Space:='';
Writeln(txt1);
Writeln(txt1,Space+'ИТОГОВАЯ СПРАВКА ПО ОПЛАЧЕННЫМ ОТГРУЗКАМ И ВОЗВРАТАМ ПО РАЗДЕЛАМ');
Writeln(txt1,Space+'┌─────────────────────────────────────────────────────────────────────────────────────────────┐');
Writeln(txt1,Space+'│N Раздел                Сумма отгр   %   Сумма возвр.Сумма к опл.Сумма по ЗЦ   Доход,     %  │');
Writeln(txt1,Space+'│                        теор, руб  от E  теор, руб      руб          руб        руб     доход│');
Writeln(txt1,Space+'└─────────────────────────────────────────────────────────────────────────────────────────────┘');




                   {12 12345678901234567890 12345678901│12345│12345678901│12345678901│12345678901│1234567890│12345}
{12 12345678901234567890 123456789012345 12345│123456789012345│12345│1234567890123│1234567890123}

{расчет дохода}
Dohod:=0.00;
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

  ws1:=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1+CIZena+1,CIZena);
  ws :=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
  Dohod:=Dohod+StrToReal(ws1)-StrToReal(ws);
End;


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

  {отгрузка}
  ws1:=Copy(s,1+CRazdelKod+1+CRazdel+1,CIZena);
  Str(StrToReal(ws1):CIZena-4:CMAntissa,ws1);
  {возврат}
  ws:=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1,CIZena);
  Str(StrToReal(ws):CIZena-4:CMAntissa,ws);
  {оплата}
  ww1:=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1+CIZena+1,CIZena);
  Str(StrToReal(ww1):CIZena-4:CMAntissa,ww1);
  {закупка}
  ww2:=Copy(s,1+CRazdelKod+1+CRazdel+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
  Str(StrToReal(ww2):CIZena-4:CMAntissaZ,ww2);


If (StrToReal(ws1)>0.009) Or (StrToReal(ws)>0.009) Or (StrToReal(ww1)>0.009)
Or (StrToReal(ww2)>0.009) Then
Begin

 If StrToReal(ww2)>0.009 Then
 Begin
  If (AllItogo+AllSkidka)>0.009 Then
  MyStr(StrToReal(ws1)/(AllItogo+AllSkidka)*100,CLitr,CMantissa,ws11)
  Else ws11:='??.??';
 End
 Else
   ws11:=' 0.00';

 If StrToReal(ww2)>0.009 Then
 Begin
  If ((StrToReal(ww1)-StrToReal(ww2))>0.009) Then
  MyStr((StrToReal(ww1)-StrToReal(ww2))/(StrToReal(ww2))*100,CLitr,CMantissa,ws22)
  Else ws22:='??.??';
 End
 Else
  ws22:=' 0.00';

  s[0]:=Chr(CRazdelKod+1+CRazdel+1);
  s:=s+ws1+' '+ws11+' '+ws+' '+ww1+' '+ww2+' '+RealToStr(StrToReal(ww1)-StrToReal(ww2),CIZena-5,CMAntissaZ)+' '+ws22;
{
  Insert(ws1+' ',s,1+CRazdelKod+1+CRazdel+1+CIZena+1);
  s:=s+' '+ws;
}
  Writeln(txt1,Space+s);
End;
 End;
End;
Writeln(txt1,Space+'───────────────────────────────────────────────────────────────────────────────────────────────');
Writeln(txt1,Space+'Всего доход:',Dohod:CIZena:CMantissaZ);



If (Agent^.List^.Count-1)>=0 Then
Begin
Space:='  ';
Writeln(txt1);
Writeln(txt1,Space+'   СПРАВКА ПО ОПЛАЧЕННЫМ ОТГРУЗКАМ ПО АГЕНТАМ');
Writeln(txt1,Space+'┌───────────────────────────────────────────────────────────────────────────────────────┐');
Writeln(txt1,Space+'│N        Агент         Код   Оплачена сумма   %      Всего штраф        Доход,руб   %  │');
Writeln(txt1,Space+'│                                            от E                                  доход│');
Writeln(txt1,Space+'└───────────────────────────────────────────────────────────────────────────────────────┘');
                   {12 12345678901234567890 1234 123456789012345 12345 123456789012345│123456789012345│12345}

For Cur:=0 To Agent^.List^.Count-1 Do
 Begin
  s:=Agent^.GetText(Cur,Agent^.List^.Count);
  {объем клиента по З/Цене }
  SumZ:=Copy(s,1+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);
  System.Delete(s,1+1+CClientKod+1+CIZena+1+CIZena+1,CIZena);

  While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';
  Delete(s,1,1);
  ws1:=Copy(s,1+1,CClientKod);
  ws1:=GetAgentField(FClient,ws1);
  Format(ws1,CClient+1);
  System.Insert(ws1,s,1);
  ws1:=Copy(s,1+CClient+1+CClientKod+1,CIZena);{объемы агента}
  SumO:=ws1;


If (StrToReal(ws1)>0.009) Then
Begin
  If (AllItogo{+AllSkidka})>0.009 Then
  MyStr(StrToReal(ws1)/(AllItogo{+AllSkidka})*100,CLitr,CMantissa,ws1)
  Else ws1:='??.??';
End
  Else ws1:=' 0.00';



  ws2:=IntToStr(Cur+1,CMantissa);
  RFormat(ws2,CMantissa);
  System.Insert(ws1,s,1+CClient+1+CClientKod+1+CIZena+1);
  s:=ws2+' '+s+' ';

If (StrToReal(SumO)>0.009) Then
Begin
  If StRToReal(SumZ)>0.009 Then
  MyStr((StrToReal(SumO)-StrToReal(SumZ))/StrToReal(SumZ)*100,CLitr,CMantissa,ws1)
  Else ws1:='??.??';
End
  Else ws1:=' 0.00';

  MyStr((StrToReal(SumO)-StrToReal(SumZ)),CIZena,CMantissaZ,ws2);

  s:=s+ws2+' '+ws1;

  Writeln(txt1,Space+s);
 End;
End;{If Agent}


Space:='   ';

Close(txt2);
i:=IoResult;
Reset(txt2);
i:=IoResult;
If IOResult=0 Then
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

Close(txt2);
End;



Writeln(Txt1);
Writeln(Txt1,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt1,Space+'================================================================================');

NoInfoMsg;

Close(txt1);
Cur:=IOResult;
Dispose(Agent,Done);

NoInfo;

If MessageBox(^M+#3'Основной расчет успешно завершен!'^M+
#3'Подготовить детальный отчет по клиентам?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
Begin
 Assign(txt1,Path^.Dat.ToTemp+'full.txt');
 Rewrite(txt1);
 Cur:=IOResult;
 If Cur=0 Then
  Begin

DInfoMsg('Провожу детализацию ...',True);

R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClF,Path^.Dat.ToClient+'Client.db');

cur:=IOResult;
Reset (ClF,SizeOf(ClientType));
cur:=IOResult;
 If cur=0 Then
 Begin
  While Not(Eof(ClF)) Do
   Begin
    New(CLE,Init);
    Count:=0;
    ReadBufClient(Clf,CLE,Count);
    For c:=1 To Count Do
     Begin
      If ClE^.Point.Dat[c].Employ Then
       Begin
        Format (ClE^.Point.Dat[c].Name,CClient);
        Client^.List^.Insert(NewStr(ClE^.Point.Dat[c].Name+'│'+ClE^.Point.Dat[c].Kod{+'│'+s}));
        Client^.SetRange(Client^.List^.Count);
       End;
     End;{For}
    Dispose(CLE,Done);
   End;{While}
   System.Close(ClF);
   cur:=IOResult;
 End
 Else
  Begin
   MessageBox(^M+#3'Ошибка доступа к базе клиентов!',nil,mfError+mfCanCelButton);
  End;
  Client^.FocusItem(0);

  Writeln(Txt1,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+') Отчет сформирован по оплате');
  Write(Txt1,'                   '+'$'+'    '+'$'+'     '+'$');

For Cur:=0 To Razdel1^.List^.Count-1 Do
 Begin
  s:=Razdel1^.GetText(Cur,Razdel1^.List^.Count);
  Delete(s,1,1);
  ws1:=Copy(s,1,CRazdelKod);
  Delete(s,1+CRazdelKod,3);
  ww1:=GetRazdel(ws1);
  Format(ww1,CRazdel-(CRazdelKod+1));
  Write(txt1,ww1+' '+ws1+'$');
 End;
  WriteLn(txt1);


  For c:=0 To Client^.List^.Count-1 Do
   Begin
    s:=Client^.GetText(c,Client^.List^.Count);
    Cur:=StrToInt(Copy(Client^.GetText(c,Client^.List^.Count),1+CClient+1,CClientKod));

    If (Stat[Cur].Employ) And (Stat[Cur].DocKol>0) Then
     Begin
      Write(txt1,Copy(s,1,CClient)+'$',Cur:4,'$',Stat[Cur].DocKol:5,'$');
      For l:=0 To Stat[Cur].RList^.List^.Count-1 Do
        Begin
         s:=Stat[Cur].RList^.GetText(l,Stat[Cur].RList^.List^.Count);
         s:=Copy(s,1+1+CArtikul+1+CIZena+1+CIZena+1,CIZena);
         Write(txt1,s+'     $');
        End;{For}
      Writeln(txt1);
     End;{Employ and DocKol>0}
   End;{For по клиентам}

 Dispose(Client,Done);

  Close(txt1);
  Cur:=IOResult;
NoInfoMsg;

  MessageBox(^M+#3'Детальный отчет успешно сформирован!',Nil,mfInformation+mfCancelButton);
  End
Else
Begin
 MessageBox(^M+#3'Ошибка создания '+Path^.Dat.ToTemp+'full.txt'^M+
 #3' Код: ',nil,mfError+mfCanCelButton);
 Assign(txt1,Path^.Dat.ToTemp+'full.txt');
 Erase(txt1);
 Cur:=IOResult;
End;

End;
{вопрос о детальном расчете}



DInfoMsg('Уничтожаю промежуточные результаты расчета...',True);
Dispose(Razdel1,Done);
DoneArrayList;
NoInfoMsg;

ViewAsText(Path^.Dat.ToTemp+'cmeng.txt',True);
{Report(Path^.Dat.ToTemp+'cmeng.txt','',1,False,False);}
End;{CalcTch}


