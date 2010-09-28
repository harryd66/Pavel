{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit MakeHist;


Interface

Uses Glob,ServStr;

Procedure MakeClientIndex;
Procedure MAkeClientOplataIndex;
Procedure MAkeClientReturnIndex;
Procedure CalcDolgDebitAgent;

Implementation

Uses Access1,Access,NetDbEng,Net,Serv,MsgBox,Views,TpDate,Utils,
     Objects,Dialogs,App,Prise,DbEngine,Tools,MyView,Printers;

Var StartDate,StopDAte:TDateString;
    Start,Stop,Cur:LongInt;
    Curs:TDAteString;
    f : MarketFileType;
    f1 : OplataRealizasiaFileType;
    f2 : File Of ClientOplataRealizasiaType;
    i : LongInt;
    E : PSuperMarketType;
    Oplata : OplataRealizasiaType;
    COplata : ClientOplataRealizasiaType;
    FF : Boolean;

{индекс по продажам клиенту}

Procedure MAkeClientIndex;
Var tt : File;
Begin
 If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
 Exit;
 If Not DatePeriodDialog(StartDate,StopDate,False) Then Exit;

DinfoMsg('Уничтожаю старые индексы по оборотам клиентов...');
Assign(ClientFile,Path.ToClient+'client.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла клиентов!'+
  ClicProgrammer+' Код:'+IntToStr(i,3),Nil,mfError+mfCancelButton);
  Exit;
 End;
{цикл уничтожения ранее существовавших индексов}
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement^.Dat);
 Assign(tt,Path.ToClient+ClientElement^.Dat.Kod+'.his');
 i:=IOResult;
 Rewrite(tt);
 i:=IOResult;
 If i<>0 Then
  MessageBox(^M+#3'Ошибка создания файла хронологии '+Path.ToClient+ClientElement^.Dat.Kod+'.his!'+
  ClicProgrammer+' Код:'+IntToStr(i,3),Nil,mfError+mfCancelButton)
 Else
 Close(tt);
 i:=IOResult;
End;
Close(ClientFile);
NoInfoMsg;
Start:=DateStringToDAte(DAteMask,StartDate);
Stop:=DateStringToDAte(DAteMask,StopDate);

New(E,Init);

For Cur := Start To Stop Do
Begin
Curs:=DateToDateString(DateMask,Cur);
Assign (f,Path.ToMarket+Curs+'.mrk');
i:=IOResult;
Reset(f);
i:=IOResult;
If I =0 Then
Begin
DInfoMsg('Переиндексирую продажи за '+Curs+'...');
 While Not(Eof(f)) Do
  Begin
   ReadMarket(f,E);
   If (E^.Dat.OperatorSelector=0) And (E^.Dat.Active) Then
   Begin
    If ((E^.Dat.DocSelector in [0,1,2,3,4]) And Not(E^.Dat.Realiz))
    Or ((E^.Dat.DocSelector in [5,6,7,8]) And (E^.Dat.Realiz)) Then
    Begin
     If E^.Dat.DocSelector In [3,4,6,8] Then ff:=True
     Else FF:=False;
     if E^.Dat.Amount>0 then
     SaveToStatFile(E,FF,GetIdRealiz(E^.Dat.MarketElement[1].BazKod))
	else SaveToStatFile(E,FF,false);
    End;
   End;
  End;
 i:=IOResult;
 Close(f);
 i:=IOResult;
NoInfoMsg;
End
End;{For}
Dispose(E,Done);

DInfoMsg('Оптимизирую индексы по продажам...');
Reset(ClientFile);
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement^.Dat );
 Assign(tt,Path.ToClient+ClientElement^.Dat.Kod+'.his');
 i:=IOResult;
 Reset(tt);
 i:=IOResult;
 If i=0 Then
     Begin
      If FileSize(tt)=0 Then
          Begin
           i:=IOResult;
           Close(tt);
           i:=IOResult;
           Erase(tt);
           i:=IOResult;
          End
      Else
          Begin
           i:=IOResult;
           Close(tt);
           i:=IOResult;
          End;
     End;
End;
i:=IOResult;
Close(ClientFile);
NoInfoMsg;


MessageBox(^M+#3'Создание индекса по оборотам клиентов завершено!',Nil,mfInformation+mfCancelButton);

End;{Procedure}



{индекс по оплатам консигнации}

Procedure SaveToClientOplataFile(Cl:ClientOplataRealizasiaType);
Var f : File Of ClientOplataRealizasiaType;
    i : Word;
Begin
 Assign(f,Path.ToClientOplata+Cl.ClientKod+'.cpl');
 i:=IOResult;
 Reset(f);
 i:=IOResult;
 If I<>0 Then
  Begin
   If MessageBox(#3'Файл оплат клиента '^M+#3+Path.ToClientOplata+Cl.CLientKod+'.cpl не найден!'^M+
   #3'Создать файл заново ?',Nil,mfWarning+mfOkCancel)=cmOk Then
   Begin
    Rewrite(f);
    i:=IOResult;
    If I<>0 Then
      Begin
       MessageBox(^M+#3'Ошибка создания файла '+Path.ToClientOplata+Cl.ClientKod+'.cpl'+
                   ClicProgrammer,Nil,mfError+mfCancelButton);
       Exit;
      End;
   End
    Else Exit;
  End;
 i:=IOResult;
 Seek(f,FileSize(f));
 i:=IOResult;
 Write(f,Cl);
 i:=IOResult;
 System.Close(f);
 i:=IOResult;
End;



Procedure CalcSrokAndDelta(Var CC:ClientOplataRealizasiaType);
Var GlobalEr:PrealizasiaType;
    SClientKOd : ArtikulStr;
    RealFile : File Of RealizasiaType;
    s1,s : AllStr;
    L : Boolean;
Begin
SClientKod:=Cc.ClientKod;
Assign(RealFile,Path.ToDolg+Cc.ClientKod+'.dlg');
i:=IOResult;
Reset(RealFile);
i:=IOResult;
If i<>0 Then
 Begin
  MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path.ToDolg+Cc.ClientKod+'.dlg!'^M+
  #3'Не могу рассчитать срок и опоздание оплат! ',Nil,mfError+mfCancelButton);
  Exit;
 End;

New(GlobalEr,Init);
l:=False;
s1:=CC.Document;
DelSpace(s1);
s:=CC.DateDoc;
DelSpace(s);
DelZerro(s1);

While Not(Eof(RealFile)) And(Not(l))Do
 Begin
  Read(RealFile,GlobalEr^.Dat);
  Delspace(GlobalEr^.DAt.MArket.Document);
  DelZerro(GlobalEr^.Dat.Market.Document);
  If (GlobalEr^.DAt.MArket.Document=s1) And
     (GlobalEr^.DAt.MArket.DateC=s){And
	(GlobalEr^.DAt.MArket.Active)} Then l:=True;
 End;
i:=IOResult;
Close(RealFile);
i:=IOResult;

{убрал сам так как не нужно!
If Not(l) Then
 Begin
  Dispose(GlobalEr,Done);
  MessageBox(#3'Документ N '+s1+' в базе не найден.'^m+#3+ClicProgrammer,Nil,mfError+mfCancelButton);
  Exit;
 End;}

If GlobalEr^.DAt.Market.Srok<DateStringToDate(DateMask,CC.DateC) Then
    Begin
     s1[0]:=#0;
     i:= DateStringToDate(DateMask,CC.DateC)-GlobalEr^.DAt.Market.Srok;
     Str(i:3,s1);
     DelSpace(s1);
    End
    Else s1[0]:=#0;

    CC.Delta :=S1;{срок опоздания}
    If GlobalEr^.DAt.Market.Srok<DateStringToDate(DateMask,cc.datec) Then
    CC.Srok :=DateToDAteString(DAteMask,DateStringToDate(DateMask,cc.datec)-StrToInt(s1)){срок оплаты}
    Else
    CC.Srok :=DateToDAteString(DAteMask,GlobalEr^.DAt.Market.Srok){срок оплаты};
Dispose(GlobalEr,Done);
End;



Procedure MAkeClientOplataIndex;
Var tt : File;
    f1 : OplataRealizasiaFileType;
Begin
 If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
 Exit;
 If Not DatePeriodDialog(StartDate,StopDate,False) Then Exit;

DinfoMsg('Уничтожаю старые индексы по оплатам клиентов...');
Assign(ClientFile,Path.ToClient+'client.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла клиентов!'+
  ClicProgrammer+' Код:'+IntToStr(i,3),Nil,mfError+mfCancelButton);
  Exit;
 End;
{цикл уничтожения ранее существовавших индексов}
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement^.Dat);
 Assign(tt,Path.ToClientOplata+ClientElement^.Dat.Kod+'.cpl');
 i:=IOResult;
 Rewrite(tt);
 i:=IOResult;
 If i<>0 Then
  MessageBox(^M+#3'Ошибка создания файла хронологии оплаты '+Path.ToClientOplata+ClientElement^.Dat.Kod+'.cpl!'+
  ClicProgrammer+' Код:'+IntToStr(i,3),Nil,mfError+mfCancelButton)
 Else
 Close(tt);
 i:=IOResult;
End;
Close(ClientFile);
NoInfoMsg;
Start:=DateStringToDAte(DAteMask,StartDate);
Stop:=DateStringToDAte(DAteMask,StopDate);


For Cur := Start To Stop Do
Begin
Curs:=DateToDateString(DateMask,Cur);
Assign (f1,Path.ToOplata+Curs+'.opl');
i:=IOResult;
Reset(f1);
i:=IOResult;
If I =0 Then
Begin
DInfoMsg('Переиндексирую оплаты консигнации за '+Curs+'...');
 While Not(Eof(f1)) Do
  Begin
   ReadOplata(f1,Oplata);
   i:=IOResult;
   If Ioresult<>0 Then
    MessageBox(#3'Ошибка чтения '+Path.ToOplata+Curs+'.opl'+ClicProgrammer,Nil,mfError+mfCancelButton);
   With COplata Do
    Begin
     COplata.SkladKod :=Oplata.SkladKod;

     ClientKod:=Oplata.ClientKod;
     Document :=Oplata.Document;
     DateDoc  :=Oplata.DateDoc;
     DateC    :=Oplata.DateC;
     TimeC    :=Oplata.TimeC;
     SummaZ   :=Oplata.SummaZ;
     Skidka   :=Oplata.Skidka;
     PrhNumer :=Oplata.PrhNumer;

      Vozwrat :=Oplata.Vozwrat;
DocNumerReturn:=Oplata.DocNumerReturn;
DocDateReturn :=Oplata.DocDateReturn;
     Caption  :=Oplata.Caption;
     Rashet   :=Oplata.Rashet;
     Bn       :=Oplata.Bn;
     Realiz:=Oplata.Realiz;
    End;{With}
     CalcSrokAndDelta (COplata);
     SaveToClientOplataFile(COplata);
  End;
 i:=IOResult;
 Close(f1);
 i:=IOResult;
NoInfoMsg;
End
End;{For}


DInfoMsg('Оптимизирую индексы по оплатам...');
Reset(ClientFile);
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement^.Dat);
 Assign(tt,Path.ToClientOplata+ClientElement^.Dat.Kod+'.cpl');
 i:=IOResult;
 Reset(tt);
 i:=IOResult;
 If i=0 Then
     Begin
      If FileSize(tt)=0 Then
          Begin
           i:=IOResult;
           Close(tt);
           i:=IOResult;
           Erase(tt);
           i:=IOResult;
          End
      Else
          Begin
           i:=IOResult;
           Close(tt);
           i:=IOResult;
          End;
     End;
End;
i:=IOResult;
Close(ClientFile);
NoInfoMsg;


MessageBox(^M+#3'Создание индекса по оплатам клиентов завершено!',Nil,mfInformation+mfCancelButton);

End;{Procedure}


Procedure SaveToClientReturnFile(Cl:PClientNewVozwratType);
Var f : File Of ClientNewVozwratType;
    i : Word;
Begin
 Assign(f,Path.ToClientReturn+Cl^.Dat.Return.MakeKod+'.cvz');
 i:=IOResult;
 Reset(f);
 i:=IOResult;
 If I<>0 Then
  Begin
   If MessageBox(#3'Файл возвратов клиента '^M+#3+Path.ToClientReturn+Cl^.Dat.Return.MakeKod+'.cvz не найден!'^M+
   #3'Создать файл заново ?',Nil,mfWarning+mfOkCancel)=cmOk Then
   Begin
    Rewrite(f);
    i:=IOResult;
    If I<>0 Then
      Begin
       MessageBox(^M+#3'Ошибка создания файла '+Path.ToClientReturn+Cl^.Dat.Return.MakeKod+'.cvz'+
                   ClicProgrammer,Nil,mfError+mfCancelButton);
       Exit;
      End;
   End
    Else Exit;
  End;
 i:=IOResult;
 Seek(f,FileSize(f));
 i:=IOResult;
 Write(f,Cl^.Dat);
 i:=IOResult;
 System.Close(f);
 i:=IOResult;
End;


Procedure MAkeClientReturnIndex;
Var tt : File;
    f1 : NewVozwratFileType;
    Ret: PNewVozwratType;
  cret : PClientNewVozwratType;
Begin
 If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
 Exit;
 If Not DatePeriodDialog(StartDate,StopDate,False) Then Exit;

DinfoMsg('Уничтожаю старые индексы по возвратам клиентов...');
Assign(ClientFile,Path.ToClient+'client.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла клиентов!'+
  ClicProgrammer+' Код:'+IntToStr(i,3),Nil,mfError+mfCancelButton);
  Exit;
 End;
{цикл уничтожения ранее существовавших индексов}
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement^.Dat);
 Assign(tt,Path.ToClientReturn+ClientElement^.Dat.Kod+'.cvz');
 i:=IOResult;
 Rewrite(tt);
 i:=IOResult;
 If i<>0 Then
  MessageBox(^M+#3'Ошибка создания файла хронологии возвратов '+Path.ToClientReturn++ClientElement^.Dat.Kod+'.cvz!'+
  ClicProgrammer+' Код:'+IntToStr(i,3),Nil,mfError+mfCancelButton)
 Else
 Close(tt);
 i:=IOResult;
End;
Close(ClientFile);
NoInfoMsg;
Start:=DateStringToDAte(DAteMask,StartDate);
Stop:=DateStringToDAte(DAteMask,StopDate);

New(Ret,Init);
For Cur := Start To Stop Do
Begin
Curs:=DateToDateString(DateMask,Cur);
Assign (f1,Path.ToReturn++Curs+'.vzw');
i:=IOResult;
Reset(f1);
i:=IOResult;
If I =0 Then
Begin
DInfoMsg('Переиндексирую возвраты клиентов за '+Curs+'...');

 While Not(Eof(f1)) Do
  Begin
   ReadNewVozwrat(f1,Ret);
   If Ret^.Dat.OperatorSelector=0 Then{если клиентский возврат}
 Begin
   New(CRet,Init);
   With CRet^.Dat.Return Do
    Begin
     OperatorSelector:=Ret^.Dat.OperatorSelector;
     VidDocument     :=Ret^.Dat.VidDocument     ;
     DocSelector     :=Ret^.Dat.DocSelector     ;
     MakeKod         :=Ret^.Dat.MakeKod         ;
     VozwratElement  :=Ret^.Dat.VozwratElement  ;
     Document        :=Ret^.Dat.Document        ;
     DocumentPrz     :=Ret^.Dat.DocumentPrz     ;
     SummaO          :=Ret^.Dat.SummaO          ;
     SummaR          :=Ret^.Dat.SummaR          ;
     Skidka          :=Ret^.Dat.Skidka          ;
     PrevSummaZ      :=Ret^.Dat.PrevSummaZ      ;
     PrevSkidka      :=Ret^.Dat.PrevSkidka      ;
     Delta           :=Ret^.Dat.Delta ;
     SummaZakupka    :=Ret^.Dat.SummaZakupka;
     ENalog          :=Ret^.Dat.ENalog          ;
     Nalog5          :=Ret^.Dat.Nalog5          ;
     Nalog3          :=Ret^.Dat.Nalog3          ;
     Nalog_          :=Ret^.Dat.Nalog_          ;
     SkladKod        :=Ret^.Dat.SkladKod        ;
     Caption         :=Ret^.Dat.Caption         ;
     DateC           :=Ret^.Dat.DateC           ;
     TimeC           :=Ret^.Dat.TimeC           ;
     DateM           :=Ret^.Dat.DateM           ;
     TimeM           :=Ret^.Dat.TimeM           ;
     Amount          :=Ret^.Dat.Amount          ;
     StatusDoc       :=Ret^.Dat.StatusDoc       ;
     Locked          :=Ret^.Dat.Locked          ;
     BasisDoc        :=Ret^.Dat.BasisDoc        ;
     BasisDate       :=Ret^.Dat.BasisDate       ;
     Opt             :=Ret^.Dat.Opt             ;
     Rashod          :=Ret^.Dat.Rashod          ;
     RashodSumma     :=Ret^.Dat.RashodSumma     ;
    End;{With}
     SaveToClientReturnFile(CRet);
     Dispose(CRet,Done);
 End;{id}
  End;
 i:=IOResult;
 Close(f1);
 i:=IOResult;
NoInfoMsg;
End
End;{For}
Dispose(Ret,Done);

DInfoMsg('Оптимизирую индексы по возвратам клиентов...');
Reset(ClientFile);
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement^.Dat);
 Assign(tt,Path.ToClientReturn++ClientElement^.Dat.Kod+'.cvz');
 i:=IOResult;
 Reset(tt);
 i:=IOResult;
 If i=0 Then
     Begin
      If FileSize(tt)=0 Then
          Begin
           i:=IOResult;
           Close(tt);
           i:=IOResult;
           Erase(tt);
           i:=IOResult;
          End
      Else
          Begin
           i:=IOResult;
           Close(tt);
           i:=IOResult;
          End;
     End;
End;
i:=IOResult;
Close(ClientFile);
NoInfoMsg;

MessageBox(^M+#3'Создание индекса по возвратам клиентов завершено!',Nil,mfInformation+mfCancelButton);

End;{Procedure}


Function SetupDialog(VAr Vid,Tip,Teor,Kto,Sort,Dis:Word):Boolean;
Var c: Word;
  Dlg : PDialog;
  R : TRect;
  ControlSort,ControlVid,
  ControlDistant,ControlTip,ControlKto, ControlTeor: PView;

Begin
SetupDialog:=False;
R.Assign(14, 5, 65, 18);
New(Dlg, Init(R, 'Формирование запроса по долгам клиента'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(1, 2, 22, 5);
ControlVid := New(PRadioButtons, Init(R,
  NewSItem('~Н~е просроченные',
  NewSItem('~П~росроченные',
  NewSItem('~В~се', Nil)))));
Dlg^.Insert(ControlVid);
ControlVid^.SetDAta(Vid);

  R.Assign(1, 1, 14, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Срок оплаты:', ControlVid)));

R.Assign(1, 6, 22, 9);
ControlTip := New(PRadioButtons, Init(R,
  NewSItem('Со С/~Ф~',
  NewSItem('Бе~з~ С/Ф',
  NewSItem('Все', Nil)))));
Dlg^.Insert(ControlTip);
ControlTip^.SetData(Tip);

  R.Assign(1, 5, 17, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид документов:', ControlTip)));

R.Assign(1, 10, 21, 12);
ControlTeor := New(PRadioButtons, Init(R,
  NewSItem('~Р~еальные',
  NewSItem('~Т~еоретические', Nil))));
Dlg^.Insert(ControlTeor);
ControlTeor^.SetDAta(Teor);

  R.Assign(1, 9, 8, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Долги:', ControlTeor)));

R.Assign(23, 2, 50, 4);
ControlKto := New(PRadioButtons, Init(R,
  NewSItem('~У~казать доставку',
  NewSItem('Не указ~ы~вать доставку', Nil))));
Dlg^.Insert(ControlKto);
ControlKto^.SetDAta(Kto);

  R.Assign(23, 1, 33, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Доставка:', ControlKto)));

R.Assign(23, 5, 50, 9);
ControlSort := New(PRadioButtons, Init(R,
  NewSItem('~К~лиент',
  NewSItem('Су~м~ма оплаты',
  NewSItem('Сумма ск~и~дки',
  NewSItem('Срок опоз~д~ания', Nil))))));
Dlg^.Insert(ControlSort);
ControlSort^.SetData(Sort);

  R.Assign(23, 4, 35, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Сортировка:', ControlSort)));

R.Assign(23, 10, 50, 12);
ControlDistant := New(PRadioButtons, Init(R,
  NewSItem('По возр~а~станию',
  NewSItem('По убыванию', Nil))));
Dlg^.Insert(ControlDistant);
ControlDistant^.SetData(Dis);

  R.Assign(23, 9, 36, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Направление:', ControlDistant)));

Dlg^.SelectNext(False);

c:=DeskTop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  ControlVid^.GetDAta(Vid);
  ControlTip^.GetData(Tip);
  ControlTeor^.GetDAta(Teor);
  ControlKto^.GetDAta(Kto);
  ControlSort^.GetData(Sort);
  ControlDistant^.GetData(Dis);

  SetupDialog:=True;

 End;
 {
 Dispose(ControlTip,Done);
 Dispose(ControlVid,Done);
 Dispose(ControlTeor,Done);
 Dispose(ControlSort,Done);
 Dispose(ControlDistant,Done);
 Dispose(ControlKto,Done);}
 Dispose(Dlg,Done);

End;





Procedure CalcDolgDebitAgent;

Var R : TRect;
    ClientFile : File;
    ClientElement : PBufClientType;
    RealFile : File Of RealizasiaType;
    Result,AgentList,ClientList :PBox;
    E  : PRealizasiaType;
    st,s,s1 : String;
    TempS,w,w1 : AllStr;
    ws : TMyString;
    ii,c,t1,t2 : LongInt;
    r1,r2 , Rsf,RsfSkid :Real;
    f : Text;
    {DateMask : TDateString;}
    Delta,Space : AllStr;
    PrevDistant:Boolean;
    Tip,Vid,Realno,Sort,Dis,IncludeDostavka: Word;
    jjj , Count : Word;
    As: DocumentEdit;
    M: PSupermarketType;
    bSpec: boolean;
    nr: string[CrazdelKod];
begin
Vid:=2;
Tip:=2;
Realno:=0;
IncludeDostavka:=1;
Sort:=0;
Dis:=0;

If (SetupDialog(Vid,Tip,Realno,IncludeDostavka,Sort,Dis)) Then
 Begin
 {
 Vid:=SelectSpecify(False,1);
 If Vid=3 Then Exit;


 Tip:=SelectSpecify(False,4);
 If Tip=3 Then Exit;


 Realno:=SelectImport(5);
 If Realno=2 Then Exit;

 IncludeDostavka:=SelectImport(8);
 If IncludeDostavka=2 Then Exit;
 }

Assign(f,Path.ToTemp+'dolga.txt');

c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0) Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path.ToTemp+'dolga.txt!!',Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(0, 0, 0, 0);
AgentList := New(PBox, Init(R, 1, Nil));
AgentList^.NewList(New(PTextCollection, Init(0,1)));
If Not(SelectionAgent(AgentList)) Then
 Begin
  Close(f);
  Dispose(AgentList,Done);
  Exit;
 End;


R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile,SizeOf(ClientType));
c:=IOResult;
If c=0 Then
Begin
DInfoMsg('Читаю списки консигнаторов. Ждите... ');

While Not(Eof(ClientFile)) Do
 Begin

     {ReadClient(ClientFile,ClientElement);}
     New(ClientElement,Init);
     Count:=0;
     ReadBufClient(ClientFile,ClientElement,Count);
For jjj:=1 To Count Do
Begin
  If ClientElement^.Point.Dat[jjj].Employ Then
   Begin

     Format(ClientElement^.Point.Dat[jjj].Name,CClient);
     ClientList^.List^.Insert(NewStr(ClientElement^.Point.Dat[jjj].Name+'│'+ClientElement^.Point.Dat[jjj].Kod));
     ClientList^.SetRange(ClientList^.List^.Count);
   End;
End;{For}
  Dispose(ClientElement,Done);
 End;{While}
System.Close(ClientFile);
End
Else
 Begin
  Close(f);
  NoInfoMsg;
  Dispose(AgentList,Done);
  Dispose(ClientList,Done);
  MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов',Nil,mfError+mfCancelButton);
  Exit;
 End;
NoInfoMsg;

Space:='';
r1:=0;r2:=0;
rsf:=0;
rsfSkid:=0;
Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword);
Case Vid Of
2:
Writeln(f,Space+'                 СПРАВКА ПО ДОЛГАМ КОНСИГНАТОРОВ'+'  '+FDate+' ('+Times+')');
1:
Writeln(f,Space+'             СПРАВКА ПО ПРОСРОЧЕННЫМ ДОЛГАМ КОНСИГНАТОРОВ'+'  '+FDate+' ('+Times+')');
0:
Writeln(f,Space+'            СПРАВКА ПО НЕ ПРОСРОЧЕННЫМ ДОЛГАМ КОНСИГНАТОРОВ'+'  '+FDate+' ('+Times+')');
Else;
End;
Write(f,Space+'Вид отбора: ');
Case Tip Of
0:Writeln(f,'"Только со С/Ф"');
1:Writeln(f,'"Только без С/Ф"');
2:Writeln(f,'"Все"');
Else Writeln(f);
End;

Write(f,Space+'Вид долгов: ');
Case Realno Of
1:Writeln(f,'"Теоретичекие"');
0:Writeln(f,'"Реальные по оплате"');
Else Writeln(f);
End;

Case IncludeDostavka Of
0:Writeln(f,'"Указывать доствку"');
1:Writeln(f,'"Не указывать доствку"');
Else;
End;

{Клиент
 оплата
 скидка
 опоздание}

Write(f,Space+'Вид сортировки: ');
Case Sort Of
0:Writeln(f,'"Клиент"');
1:Writeln(f,'"Долг по оплате"');
2:Writeln(f,'"Скида"');
3:Writeln(f,'"Опоздание"');
Else Writeln(f);
End;

Write(f,Space+'Направление сортировки: ');
Case Dis Of
0:Writeln(f,'"По возрастанию"');
1:Writeln(f,'"По убыванию"');
Else Writeln(f);
End;


WriteLN(f,Space+'Выбранные агенты: ');
For c:=0 To AgentList^.List^.Count-1 Do
 Begin
  s:=AgentList^.GetText(c,AgentList^.List^.Count);
  s1:=Copy(s,1+1,CClientKod);
  s1:=GetAgentField(FAgent,s1);
  Format(s1,CClient);
  s:=s1+s;
  While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';
  s[0]:=Chr(1+CClient+1+CClientKod);
  Writeln(f,Space+s);
 End;
WriteLN(f);


R.Assign(0, 0, 0, 0);
Result := New(PBox, Init(R, 1, Nil));
Result^.NewList(New(PTextCollection, Init(0,1)));


PrevDistant:=DistanationSorting;
If Dis=0 Then
DistanationSorting:=True Else DistanationSorting:=False;


Writeln(f,Space+'--------------------------------------------------------------------------------------------');
If Realno=1 Then
Writeln(f,Space+' пп         Клиент        Код  Дата Пок Дата Взв Delta Nдок Сумма скидки   Сумма долга Т Вид')
Else
Writeln(f,Space+' пп         Клиент        Код  Дата Пок Дата Взв Delta Nдок Сумма скидки  Р долг по опл. Вид');
{                1234│12345678901234567890|1234|12345678|12345678|     |1234|123456789012│123456789012345│}
Writeln(f,Space+'--------------------------------------------------------------------------------------------');

DInfoMsg('Рассчитываю долги клиентов. Ждите... ');
If ((ClientList^.List^.Count-1)>=0) Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);

    Assign(RealFile,Path.ToDolg+st+'.dlg');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    If ii=0 Then
     Begin
      While Not(Eof(RealFile)) Do
       Begin
        New(E,Init);
        Count:=0;
        Read(RealFile,E^.DAt);

Begin
        If (E^.Dat.Market.Active) Then
Begin
        If Not(TestElement(E^.Dat.Market.AgentKod+'│',AgentList)) Then
         Begin
        bSpec:=false;
        As.D:=E^.Dat.MArket.DateC;
        As.EditPosition:=E^.Dat.MArket.Document;
        New(M,Init);
        GetMarket1(As,M);
        if M^.Dat.Amount>0 then
         if StrToReal(GetRazdelSFProc(copy(M^.Dat.MarketElement[1].BazKod,1,2)))>0.01 then
         bSpec:=true;
        nr:=copy(M^.Dat.MarketElement[1].BazKod,1,2);
        Dispose(M,Done);
        t2:=DateStringToDate(DAteMask,FDate);
        t1:=E^.Dat.MArket.Srok;
        If ((((E^.Dat.Dolg<>0)And((t2-t1)>=0))And(Vid=1))Or
           (Vid=2)Or
           ((((E^.Dat.Dolg<>0)And((t2-t1)<0))And(Vid=0)))) And Not(E^.Dat.Full) Then
         Begin
         If ((E^.Dat.Sf) And (Tip=0)) Or (Tip=2) Or (Not(E^.Dat.Sf) And (Tip=1)) Then
         Begin
          Str((t2-t1):5,w);
          Delta:=w;
          ws:=GetClientField(FClient,St,0);
          Format(ws,CClient);
          DelSpace(E^.Dat.MArket.Document);
          RFormat(E^.Dat.MArket.Document,CDocnumer);
          if E^.Dat.Realiz then
          ws:=ws+' '+St+' '+E^.Dat.Market.DateC+' '+'Реал.('+nr+')'+w+
          ' '+E^.Dat.Market.Document+' '
          else
          ws:=ws+' '+St+' '+E^.Dat.Market.DateC+' '+DateToDateString(DAteMask,E^.Dat.Market.Srok)+' '+w+
          ' '+E^.Dat.Market.Document+' ';



          If Realno=1 Then
          Str((E^.Dat.Dolg+StrToReal(E^.Dat.Market.Skidka)):CIZena:CMantissa,w)
          Else
          Str((E^.Dat.Dolg):CIZena:CMantissa,w);

          Str(StrToReal(E^.Dat.Market.Skidka):CIZena-3:CMantissa,E^.Dat.Market.Skidka);
          r1:=r1+E^.Dat.Dolg+StrToReal(E^.Dat.Market.Skidka);
          r2:=r2+StrToReal(E^.Dat.Market.Skidka);
          ws:=ws+E^.Dat.Market.Skidka+' '+w;

			 If E^.Dat.Sf Then
			  Begin
				rsf:=rsf+E^.Dat.Dolg+StrToReal(E^.Dat.Market.Skidka);
		  rsfSkid:=rsfSkid+StrToReal(E^.Dat.Market.Skidka);

                  ws:=ws+' '+'   '+' '+E^.Dat.Market.AgentKod;
			  End
           Else
           ws:=ws+'     '+E^.Dat.Market.AgentKod;

{
          If E^.Point.Dat[jjj].Sf Then
           Begin
            rsf:=rsf+E^.Point.Dat[jjj].Dolg+StrToReal(E^.Point.Dat[jjj].Market.Skidka);
        rsfSkid:=rsfSkid+StrToReal(E^.Point.Dat[jjj].Market.Skidka);
           ws:=ws+'│'+'СФ '+'│'+E^.Point.Dat[jjj].Market.AgentKod;
           End
           Else
           ws:=ws+'│'+E^.Point.Dat[jjj].Market.AgentKod;
}




{Клиент
 оплата
 скидка
 опоздание}
           Case Sort Of
           0:{Клиент}
             Begin
              ws:=ws;
             End;
           1:{Оплата}
             Begin
              ws:=w+' '+ws
             End;
           2:{Скидка}
             Begin
              ws:=E^.Dat.Market.Skidka+' '+ws;
             End;
           3:{Опоздание}
             Begin
              ws:=Delta+' '+ws;
             End;
           Else ws:=ws;
           End;

           If E^.Dat.Sf Then ws:=ws+' СФ'
           else ws:=ws+'   ';

           if bSpec then
           Result^.List^.Insert(NewStr(ws+' !'))
           else
           Result^.List^.Insert(NewStr(ws));
           Result^.SetRange(Result^.List^.Count);

         End;
         End;
End;{active}
End;{Otbor}

End;{For}
      Dispose(E,Done);

       End;{While}

      Close(RealFile);
     End;

(*{деблокировка клиента}
 Repeat
 Until (SetClientUnLock(St,0,0));*)

   End;
 End;
NoInfoMsg;


DInfoMsg('Сортирую долги клиентов');
If ((Result^.List^.Count-1)>=0) Then
BEgin
  For c:=0 To Result^.List^.Count-1 Do
   Begin
    st := Result^.GetText(c,Result^.List^.Count);
    Case Sort of
    0:st:=st;
  {Оплата}
    1:Delete(St,1,CIZena+1);
  {Скидка}
    2:Delete(St,1,CIZena-3+1);
  {Опоздание}
    3:Delete(St,1,5+1);
    Else st:=st;
    End;

    TempS:=Copy(st,Ord(st[0])-CClientKod-2,CClientKod);
    Delete(St,Ord(st[0])-CClientKod-2-4,CClientKod+4);

    If IncludeDostavka=0 Then
     Begin
      TempS:=GetAgentField(FAgent,TempS);
      Writeln(f,Space+'     Доставка: '+TempS);
     End;

     ws:=IntToStr(c+1,4);
     RFormat(ws,4);

     Writeln(f,Space+ws+' '+st);
   End;
End;



Dispose(Result,Done);
Dispose(ClientList,Done);
Dispose(AgentList,Done);
Writeln(f,Space+'--------------------------------------------------------------------------------------------');

If Tip In [1,2] Then
Begin
Writeln(f,Space+'                                                   Всего долг:'+RecognizReal(R1,CIZena,CMantissa));
Writeln(f,Space+'                                                 Всего скидка:'+RecognizReal(R2,CIZena,CMantissa));
Writeln(f,Space+'                                      Реальный долг по оплате:'+RecognizReal(R1-R2,CIZena,CMantissa));
End;

{
If Tip In [0,2] Then
Begin
Writeln(f,Space+'                                               Всего долг С/Ф:'+RecognizReal(RSf,CIZena,CMantissa));
Writeln(f,Space+'                                             Всего скидка С/Ф:'+RecognizReal(RsfSkid,CIZena,CMantissa));
Writeln(f,Space+'                                  Реальный долг по оплате С/Ф:'+RecognizReal(Rsf-RsfSkid,CIZena,CMantissa));
End;
}
Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'============================================================================================');

c:=IOresult;
Close(f);

NoInfoMsg;
ViewAsText(Path.ToTemp+'dolga.txt',True);
Report(Path.ToTemp+'dolga.txt','',1,False,False,false);
DistanationSorting:=PrevDistant;

 End;

end;




End.
