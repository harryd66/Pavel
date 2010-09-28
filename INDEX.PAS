Uses Glob,ServStr,Access1,Access,NetDbEng,Net,Serv,MsgBox,TpDate,Utils,
     Objects,Dialogs,App,Prise,DbEngine,Tools,MyView,Printers;

Const ReadOnly=0+$42;

Type PathType = record
   ToClient: string;
   ToMarket: string;
   ToClientOplata: string;
   ToOplata: string;
   ToDolg: string;
   ToClientReturn: string;
   ToReturn: string;
   TOName: string;
  end;

Var StartDate,StopDAte:TDateString;
    Start,Stop,Cur:LongInt;
    Curs:TDAteString;
    f : MarketFileType;
    f1 : OplataRealizasiaFileType;
    f2 : File Of ClientOplataRealizasiaType;
    i : LongInt;
    E : SuperMarketType;
    Oplata : OplataRealizasiaType;
    COplata : ClientOplataRealizasiaType;
    FF : Boolean;
    ClientFile: ClientFileType;
    Path: PathType;
    s: string;
    ini,log: text;
    IORez: word;
    ClientElement: ClientType;

Function GetIdRealiz(C:ArtikulStr):Boolean;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    OldFileMode: word;
    id: BazType;
    fid: file of BazType;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fId,Path.TOName+c+'.id');
 GetIdRealiz:=False;
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 If l <> 0 Then
 Begin
  writeln(log,Path.TOName+c+'.id'+' Код:['+st+'] Код:'+IntToStr(l,CKol));
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Seek(fid,L);
   Read(FID,Id);
   Close(fid);
   GetIdRealiz:=Id.Realiz;
   FileMode:=OldFileMode;
  End;
End;

Function GetBAzElement(C:ArtikulStr;Var E:BazType):Boolean;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    OldFileMode: word;
    ID: bazType;
    fid: file of BazType;
Begin
 GetBAzElement:=False;
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fId,Path.TOName+c+'.id');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 If l <> 0 Then
 Begin
  writeln(Path.TOName++c+'.id'+' Код:['+st+']');
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Seek(fid,L);
   Code:=IOResult;
   Read(FId,Id);
   Close(fid);
   E:=Id;
   FileMode:=OldFileMode;
   If Not(Id.Employ) Then
    writeln('Позиция ('+Id.BazKod+')'+' помечена как удаленная!');
  End;
End;


Procedure CalcRaspredelenie(L:SuperMarketType;Var Es:statClientType);
Var i,j:Word;
    k : Real;
    MasStr1,MasStr2 : Array[0..MaxStatRazdel] of AllStr;
    ws,ws1 : String[CIZena];
Begin
 For j:=0 To MaxStatRazdel Do
 Begin
  For i:=1 To L.Amount Do
   Begin
    {нашли позицию}
    If StrToInt(Copy(L.MarketElement[i].BazKod,1,CRazdelKod))=j Then
     Begin

      Case L.SkidkaSelector Of
      0,2:Begin
        Str(
        (StrToReal(L.MarketElement[i].Input.Zena)-
         StrToReal(L.MarketElement[i].Input.Zena)*(StrToReal(L.MarketElement[i].Input.Proz))):CIZena:CMantissa,ws);
        Str(Es.RazdelSkid[j]+StrToInt (L.MarketElement[i].Input.Kol)*
        StrToReal(ws):CIZena:CMantissa,ws);
        Es.RazdelSkid[j]:=StrToReal(ws);

        Str(
        (StrToReal(L.MarketElement[i].Input.Zena)-
         StrToReal(L.MarketElement[i].Input.Zena)*
        (StrToReal(L.MarketElement[i].Input.Proz))):CIZena:CMantissa,ws1);

        Str(
        StrToReal(L.MarketElement[i].Input.Zena)-
        StrToReal(ws1):CIZena:CMantissa,ws1);
        End;
      1:Begin
        ws:=RealToStr(Es.RazdelSkid[j],CIZena,CMantissa);
        Str(StrToReal(ws)+StrToInt (L.MarketElement[i].Input.Kol)*
        StrToReal(L.MarketElement[i].Input.Skidka):CIZena:CMantissa,ws);
        Es.RazdelSkid[j]:=StrToReal(ws);
        Str(
        StrToReal(L.MarketElement[i].Input.Zena)-
        StrToReal(L.MarketElement[i].Input.Skidka):CIZena:CMantissa,ws1);
        End;
      Else;
      End;

      ws:=RealToStr(Es.RazdelSum[j],CIZena,CMantissa);
      Str(StrToReal(ws){Es^.Dat.RazdelSum[j]}+StrToReal(ws1)*
                                StrToInt (L.MarketElement[i].Input.Kol):CIZena:CMantissa,ws);
      Es.RazdelSum[j]:=StrToReal(ws);


      ws:=RealToStr(Es.RazdelZak[j],CIZena,CMantissa);
      Str(StrToReal(ws)+StrToReal(L.MarketElement[i].Input.Zakupka)*
                                StrToInt (L.MarketElement[i].Input.Kol):CIZena:CMantissa,ws);
      Es.RazdelZak[j]:=StrToReal(ws);
     End;
   End;{по позициям}
 End;{по разделам}
End;


Function SaveToStatFile1(L:SuperMarketType;S:Boolean;R:boolean):Boolean;
Var Es : statClientType;
    Esf : File Of StatClientType;
    i : Byte;
Begin
 SaveToStatFile1:=False;
 Assign(esf,Path.ToClient+L.ClientKod+'.his');
 i:=IOResult;
 Reset(esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
   {If MessageBox(#3'Файл расчетов с клиентом '^M+#3+Path.ToClient+L^.Dat.ClientKod+'.his не найден!'^M+
   #3'Создать файл заново ?',Nil,mfWarning+mfOkCancel)=cmOk Then}
    Begin
        i:=IOResult;
        Rewrite(Esf);
        i:=IOResult;
        If i<>0 Then
         Begin
         { MessageBox(^m+#3'Не могу создать файл '^M+
          #3+Path.ToClient+L^.Dat.ClientKod+'.his',Nil,mfError+mfCancelButton);}
          Exit;
         End;
    End

  End;
         With Es Do
          Begin
        If L.DocSelector in [4,8] Then    Rashet:=0
        Else    Rashet:=1;

        TrueRealiz:=R;

        Realiz:=L.Realiz;
        Document:=L.Document;
        ENalog  :=L.ENalog;
        Nalog5  :=L.Nalog5;
        Nalog3  :=L.Nalog3;
        Nalog_  :=L.Nalog_;
        SummaZ:=L.SummaZ;;
        Skidka:=L.Skidka;
        SummaZakupka:=L.SummaZakupka;
        Bn.DAte:=L.bn.Date;
        Bn.NPlat:=L.bn.NPlat;
        Bn.Bank:=L.bn.Bank;
        Bn.Summa:=L.bn.Summa;
        Caption:=L.Caption;
        DateC:=L.DateC;;
        TimeC:=L.TimeC;
        DateM:=L.DateM;
        TimeM:=L.TimeM;;
        SkladKod:=FormKod(Rek.Kod);
        ShkalaNumer:=L.ShkalaNumer;
        Region:=L.Region;
        DocSelector :=L.DocSelector;
        SkidkaSelector :=L.SkidkaSelector;
        ClientKod:=L.ClientKod;
        AgentKod:=L.AgentKod;
        Active:=True;
        Sf :=S;
        CalcRaspredelenie(L,Es);
          End;
          i:=IOResult;
          Seek(Esf,FileSize(Esf));
          i:=IOResult;
          Write(Esf,Es);
          i:=IOResult;

        If i<>0 Then
         Begin
          Close(Esf);
          Writeln(log,'Ошибка записи в файл '+
          Path.ToClient+L.ClientKod+'.his '+
                IntToStr(i,3));
          Exit;
         End;

i:=IOResult;
Close(Esf);
i:=IOResult;
SaveToStatFile1:=True;
End;


Procedure MAkeClientIndex;
Var tt : File;
Begin
 StartDate:='01-01-09';
 StopDate:=DateToDateString(DateMask,Today);

Assign(ClientFile,Path.ToClient+'client.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
   writeln(log,'Ошибка чтения '+Path.ToClient+'client.db ',i);
   exit;
 End;
{цикл уничтожения ранее существовавших индексов}
While Not(eof(ClientFile)) Do
Begin
 Read(ClientFile,ClientElement);
 Assign(tt,Path.ToClient+ClientElement.Kod+'.his');
 i:=IOResult;
 Rewrite(tt);
 i:=IOResult;
 If i<>0 Then
    writeln(log,'Ошибка создания файла хронологии '+Path.ToClient+ClientElement.Kod+'.his!')
Else Close(tt);
 i:=IOResult;
End;
Close(ClientFile);
{NoInfoMsg;}
Start:=DateStringToDAte(DAteMask,StartDate);
Stop:=DateStringToDAte(DAteMask,StopDate);

For Cur := Start To Stop Do
Begin
Curs:=DateToDateString(DateMask,Cur);
Assign (f,Path.ToMarket+Curs+'.mrk');
i:=IOResult;
Reset(f);
i:=IOResult;
If I =0 Then
Begin
 writeln(log,'Переиндексирую продажи за '+Curs+'...');
 While Not(Eof(f)) Do
  Begin
   Read(f,E);
   If (E.OperatorSelector=0) And (E.Active) Then
   Begin
    If ((E.DocSelector in [0,1,2,3,4]) And Not(E.Realiz))
    Or ((E.DocSelector in [5,6,7,8]) And (E.Realiz)) Then
    Begin
     If E.DocSelector In [3,4,6,8] Then ff:=True
     Else FF:=False;
     if E.Amount>0 then
     SaveToStatFile1(E,FF,GetIdRealiz(E.MarketElement[1].BazKod))
	else SaveToStatFile1(E,FF,false);
    End;
   End;
  End;
 i:=IOResult;
 Close(f);
 i:=IOResult;
{NoInfoMsg;}
End else
begin
writeln(log,'Нет продаж за '+Curs+'...');
continue;
end;
End;{For}

writeln(log,'Оптимизирую индексы по продажам...');
Reset(ClientFile);
While Not(eof(ClientFile)) Do
Begin
 Read(ClientFile,ClientElement);
 Assign(tt,Path.ToClient+ClientElement.Kod+'.his');
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
i:=IOResult;
{NoInfoMsg;}


writeln(log,'Создание индекса по оборотам клиентов завершено!');

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
  { If MessageBox(#3'Файл оплат клиента '^M+#3+Path.ToClientOplata+Cl.CLientKod+'.cpl не найден!'^M+
   #3'Создать файл заново ?',Nil,mfWarning+mfOkCancel)=cmOk Then }
   Begin
    Rewrite(f);
    i:=IOResult;
    If I<>0 Then
      Begin
     {  MessageBox(^M+#3'Ошибка создания файла '+Path.ToClientOplata+Cl.ClientKod+'.cpl'+
                   ClicProgrammer,Nil,mfError+mfCancelButton);}
       Exit;
      End;
   End

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
Var GlobalEr:realizasiaType;
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
{  MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path.ToDolg+Cc.ClientKod+'.dlg!'^M+
  #3'Не могу рассчитать срок и опоздание оплат! ',Nil,mfError+mfCancelButton);}
  Exit;
 End;

l:=False;
s1:=CC.Document;
DelSpace(s1);
s:=CC.DateDoc;
DelSpace(s);
DelZerro(s1);

While Not(Eof(RealFile)) And(Not(l))Do
 Begin
  Read(RealFile,GlobalEr);
  Delspace(GlobalEr.MArket.Document);
  DelZerro(GlobalEr.Market.Document);
  If (GlobalEr.MArket.Document=s1) And
     (GlobalEr.MArket.DateC=s){And
	(GlobalEr^.DAt.MArket.Active)} Then l:=True;
 End;
i:=IOResult;
Close(RealFile);
i:=IOResult;

If GlobalEr.Market.Srok<DateStringToDate(DateMask,CC.DateC) Then
    Begin
     s1[0]:=#0;
     i:= DateStringToDate(DateMask,CC.DateC)-GlobalEr.Market.Srok;
     Str(i:3,s1);
     DelSpace(s1);
    End
    Else s1[0]:=#0;

    CC.Delta :=S1;{срок опоздания}
    If GlobalEr.Market.Srok<DateStringToDate(DateMask,cc.datec) Then
    CC.Srok :=DateToDAteString(DAteMask,DateStringToDate(DateMask,cc.datec)-StrToInt(s1)){срок оплаты}
    Else
    CC.Srok :=DateToDAteString(DAteMask,GlobalEr.Market.Srok){срок оплаты};
End;


Procedure MAkeClientOplataIndex;
Var tt : File;
    f1 : OplataRealizasiaFileType;
Begin

 StartDate:='01-01-09';
 StopDate:=DateToDateString(DateMask,Today);


writeln(log,'Уничтожаю старые индексы по оплатам клиентов...');
Assign(ClientFile,Path.ToClient+'client.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
  writeln(log,('Ошибка открытия файла клиентов!'+' Код:'+IntToStr(i,3)));
  Exit;
 End;
{цикл уничтожения ранее существовавших индексов}
While Not(eof(ClientFile)) Do
Begin
 Read(ClientFile,ClientElement);
 Assign(tt,Path.ToClientOplata+ClientElement.Kod+'.cpl');
 i:=IOResult;
 Rewrite(tt);
 i:=IOResult;
 If i<>0 Then
  writeln(log,'Ошибка создания файла хронологии оплаты '+Path.ToClientOplata+ClientElement.Kod+'.cpl!'+
  +' Код:'+IntToStr(i,3))
 Else
 Close(tt);
 i:=IOResult;
End;
Close(ClientFile);
{NoInfoMsg;}
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
writeln(log,'Переиндексирую оплаты консигнации за '+Curs+'...');
 While Not(Eof(f1)) Do
  Begin
   ReadOplata(f1,Oplata);
   i:=IOResult;
   If Ioresult<>0 Then
   writeln(log,'Ошибка чтения '+Path.ToOplata+Curs+'.opl');
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
{NoInfoMsg;}
End
End;{For}


writeln(log,'Оптимизирую индексы по оплатам...');
Reset(ClientFile);
While Not(eof(ClientFile)) Do
Begin
 Read(ClientFile,ClientElement);
 Assign(tt,Path.ToClientOplata+ClientElement.Kod+'.cpl');
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

writeln(log,'Создание индекса по оплатам клиентов завершено!');

End;{Procedure}


Procedure SaveToClientReturnFile(Cl:ClientNewVozwratType);
Var f : File Of ClientNewVozwratType;
    i : Word;
Begin
 Assign(f,Path.ToClientReturn+Cl.Return.MakeKod+'.cvz');
 i:=IOResult;
 Reset(f);
 i:=IOResult;
 If I<>0 Then
  Begin
  (* If MessageBox(#3'Файл возвратов клиента '^M+#3+Path.ToClientReturn+Cl^.Dat.Return.MakeKod+'.cvz не найден!'^M+
   #3'Создать файл заново ?',Nil,mfWarning+mfOkCancel)=cmOk Then*)
   Begin
    Rewrite(f);
    i:=IOResult;
    If I<>0 Then
      Begin
       (*MessageBox(^M+#3'Ошибка создания файла '+Path.ToClientReturn+Cl^.Dat.Return.MakeKod+'.cvz'+
                   ClicProgrammer,Nil,mfError+mfCancelButton);*)
       Exit;
      End;
   End;
  End;

 i:=IOResult;
 Seek(f,FileSize(f));
 i:=IOResult;
 Write(f,Cl);
 i:=IOResult;
 System.Close(f);
 i:=IOResult;

End;



Procedure MAkeClientReturnIndex;
Var tt : File;
    f1 : NewVozwratFileType;
    Ret: NewVozwratType;
  cret : ClientNewVozwratType;
Begin
 StartDate:='01-01-09';
 StopDate:=DateToDateString(DateMask,Today);


writeln(log,'Уничтожаю старые индексы по возвратам клиентов...');
Assign(ClientFile,Path.ToClient+'client.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
{  MessageBox(^M+#3'Ошибка открытия файла клиентов!'+
  ClicProgrammer+' Код:'+IntToStr(i,3),Nil,mfError+mfCancelButton);}
  Exit;
 End;
{цикл уничтожения ранее существовавших индексов}
While Not(eof(ClientFile)) Do
Begin
 Read(ClientFile,ClientElement);
 Assign(tt,Path.ToClientReturn+ClientElement.Kod+'.cvz');
 i:=IOResult;
 Rewrite(tt);
 i:=IOResult;
 If i<>0 Then
  {MessageBox(^M+#3'Ошибка создания файла хронологии возвратов '+Path.ToClientReturn++ClientElement.Kod+'.cvz!'+
  ClicProgrammer+' Код:'+IntToStr(i,3),Nil,mfError+mfCancelButton)}
 Else
 Close(tt);
 i:=IOResult;
End;
Close(ClientFile);
{NoInfoMsg;}
Start:=DateStringToDAte(DAteMask,StartDate);
Stop:=DateStringToDAte(DAteMask,StopDate);

For Cur := Start To Stop Do
Begin
Curs:=DateToDateString(DateMask,Cur);
Assign (f1,Path.ToReturn+Curs+'.vzw');
i:=IOResult;
Reset(f1);
i:=IOResult;
If I =0 Then
Begin
writeln(log,'Переиндексирую возвраты клиентов за '+Curs+'...');

 While Not(Eof(f1)) Do
  Begin
   Read(f1,Ret);
   If Ret.OperatorSelector=0 Then{если клиентский возврат}
 Begin
   With CRet.Return Do
    Begin
     OperatorSelector:=Ret.OperatorSelector;
     VidDocument     :=Ret.VidDocument     ;
     DocSelector     :=Ret.DocSelector     ;
     MakeKod         :=Ret.MakeKod         ;
     VozwratElement  :=Ret.VozwratElement  ;
     Document        :=Ret.Document        ;
     DocumentPrz     :=Ret.DocumentPrz     ;
     SummaO          :=Ret.SummaO          ;
     SummaR          :=Ret.SummaR          ;
     Skidka          :=Ret.Skidka          ;
     PrevSummaZ      :=Ret.PrevSummaZ      ;
     PrevSkidka      :=Ret.PrevSkidka      ;
     Delta           :=Ret.Delta ;
     SummaZakupka    :=Ret.SummaZakupka;
     ENalog          :=Ret.ENalog          ;
     Nalog5          :=Ret.Nalog5          ;
     Nalog3          :=Ret.Nalog3          ;
     Nalog_          :=Ret.Nalog_          ;
     SkladKod        :=Ret.SkladKod        ;
     Caption         :=Ret.Caption         ;
     DateC           :=Ret.DateC           ;
     TimeC           :=Ret.TimeC           ;
     DateM           :=Ret.DateM           ;
     TimeM           :=Ret.TimeM           ;
     Amount          :=Ret.Amount          ;
     StatusDoc       :=Ret.StatusDoc       ;
     Locked          :=Ret.Locked          ;
     BasisDoc        :=Ret.BasisDoc        ;
     BasisDate       :=Ret.BasisDate       ;
     Opt             :=Ret.Opt             ;
     Rashod          :=Ret.Rashod          ;
     RashodSumma     :=Ret.RashodSumma     ;
    End;{With}
     SaveToClientReturnFile(CRet);
 End;{id}
  End;
 i:=IOResult;
 Close(f1);
 i:=IOResult;
{NoInfoMsg;}
End
End;{For}

writeln(log,'Оптимизирую индексы по возвратам клиентов...');
Reset(ClientFile);
While Not(eof(ClientFile)) Do
Begin
 Read(ClientFile,ClientElement);
 Assign(tt,Path.ToClientReturn+ClientElement.Kod+'.cvz');
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
i:=IOResult;

Writeln(log,'Создание индекса по возвратам клиентов завершено!');

End;{Procedure}




BEGIN
  Assign(log,'index.log');
  IOrez:=ioresult;
  Rewrite(log);
  IOrez:=ioresult;
  if IOrez<>0 then
  begin
   halt;
  end;


  Assign(ini,'index.ini');
  IOrez:=ioresult;
  Reset(ini);
  IOrez:=ioresult;
  if iorez<>0 then
  begin
    writeln('Ошибка index.ini ',IOrez);
    close(log);
    halt;
  end;

while not eof(ini) do
begin
 readln(ini,s);

  if pos('ToClient=',s)>0 then
  begin
    delete(s,1,pos('=',s));
    Path.ToClient:=s;
  end;

  if pos('ToMarket=',s)>0 then
  begin
    delete(s,1,pos('=',s));
    Path.ToMarket:=s;
  end;

  if pos('ToClientOplata=',s)>0 then
  begin
    delete(s,1,pos('=',s));
    Path.ToClientOplata:=s;
  end;

  if pos('ToOplata=',s)>0 then
  begin
    delete(s,1,pos('=',s));
    Path.ToOplata:=s;
  end;

  if pos('ToDolg=',s)>0 then
  begin
    delete(s,1,pos('=',s));
    Path.ToDolg:=s;
  end;

  if pos('ToClientReturn=',s)>0 then
  begin
    delete(s,1,pos('=',s));
    Path.ToClientReturn:=s;
  end;

  if pos('ToReturn=',s)>0 then
  begin
    delete(s,1,pos('=',s));
    Path.ToReturn:=s;
  end;

   if pos('ToName=',s)>0 then
  begin
    delete(s,1,pos('=',s));
    Path.ToName:=s;
  end;
end;

  close(ini);

  MAkeClientIndex;
  writeln(log);
  MAkeClientOplataIndex;
  writeln(log);
  MAkeClientReturnIndex;

  Close(log);

END.