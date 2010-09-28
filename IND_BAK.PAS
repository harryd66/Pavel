{$A+,B-,D-,E-,F-,G+,I-,L-,N+,P-,Q-,R-,S-,T-,V-,X+,Y-}
{$M 65520,0,655360 }
{
1.конвертация необходимых файлов p??,k??,eksped,group,region
2.написание обработчика sheduler.exe
}
{$I Compile.INC}

{$DEFINE Converter}

Uses Glob,Serv,Servstr,Mail,Utils,Utils4,Utils5,Objects,StHolder,
     Dialogs,
     TpDate,NetCall,Dos,NetDbEng;

{$M 65520,0,655360 }

{последовательность следующая}
{
1.Анализируем ключи командной строки
/1 -включить экспорт для склада N 1
/2 -включить экспорт для склада N 2
/3 -включить экспорт для склада N 3
/4 -включить экспорт для склада N 4
/5 -включить экспорт для склада N 5
/6 -включить экспорт для склада N 6
/7 -включить экспорт для склада N 7
/8 -включить экспорт для склада N 8
/9 -включить экспорт для склада N 9
/10 -включить экспорт для склада N 10
/11 -включить экспорт для склада N 11
/12 -включить экспорт для склада N 12
/13 -включить экспорт для склада N 13
/14 -включить экспорт для склада N 14
/15 -включить экспорт для склада N 15
/CLIENT - репликации по клиентам
/MAKE - репликации по поставщикам
/BARTER - репликации по взаимозачетам
/AGENT - репликации по спискам торговых представителей
/SKLAD - репликации по спискам внутренних подразделений
/EKSPED - репликации по спискам экспедиторов
/GROUP - репликации по спискам групп
/REGION - репликации по спискам регионов
/SKLADKOD=01
2.Читаем каталоги из ini - файла monitor.ini
  сканируемый рабочий каталог
  массив [1..CMaxSklads] Of String[CSertif] - размещение каталогов экспорта
3.Цикл работы
}

Const

 CMaxSklads = 30;
 CMaxTasks = 12;

{структура имени файла экспорта}
{
 P1201060.402 приходы
 Z1201060.402 переоценка
 C04450.402   клиента
 M04960.103   поставщики
 B04960.103   бартер
 T04960.103   агенты
 S04960.103   склад
 E04960.103   экспедитор
 G04960.103   группа
 R04960.103   регион
 }


 StartOborot='OBOROT';{1}
 StartReturn='RETURN';{2}
 StartOplata='OPLATA';{3}
 StartTovar='TOVAR';{4}
 StartDocument='DOCUMENT';{5}
 StartLockLizensia='TESTSROKLIZ';{6}
 StartNetUnLock='UNLOCK';{7}
 StartLockClient='CALCDOLG';{8}
 StartLockAgent='TESTAGENT';{9}
 StartKDX='KDX';{10}
 StartPRICE='PRICE';{11}
 StartClient='CLIENT';{12}
                                                                       {10  11  12  13  14  15  16  17  18  19  20}
Const
 KurzSklad : array[1..30] of Char=('1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K',
 {21 22  23   24  25  26  27  28  29  30}
 'L','M','N','O','P','Q','R','S','T','U');

Const ReadOnlyN=$42{+$42 {на самом деле не ReadOnly a DenyNone
                      открытие на чтение и запись но всем разрешено все};
      ReadOnly=66;

Type Nu =Record
    All:Real;
    Ob:Array[1..30] Of Real;
    End;

Type TMyString = String[110];

Type PathTaskElement = Record
Name         : String[CClient];
PathToRazdel : TMyString;
PathToSklad  : TMyString;
PathToId     : TMyString;
PathToIndex  : TMyString;
StartDateIndexClient:TDateString;
StopDateIndexClient:TDateString;
PathToClient:TMyString;
PathToClientBaseIDX:TMyString;
PathToMarket:TMyString;
PathToDolg:TMyString;
PathToIndexClientOborot:TMyString;
DeltaDateClientTovar:LongInt;
DeltaDateClientDocument:LongInt;
PathToIndexClientTovar:TMyString;
PathToIndexClientDocument:TMyString;
{возвраты клиентов *.cvz}
StartDateIndexClientReturn:TDateString;
StopDateIndexClientReturn:TDateString;
PathToReturn:TMyString;
PathToIndexClientReturn:TMyString;
{оплаты клиентов *.cpl}
StartDateIndexClientOplata:TDateString;
StopDateIndexClientOplata:TDateString;
PathToOplata:TMyString;
PathToIndexClientOplata:TMyString;
IndexClient:Word;
CalcDolg:Word;
End;






Var Starting : Boolean;
    ClientPriceList,PriceList,ClientDolgList,AgentDolgList : PBox;
    R:TRect;
Var OldFileMode : Word;



Type SkladTask =Record
     Task : Array [1..CMaxSklads] Of PathTaskElement;
     PathToClientPrice:String;
     LockStatusWithDelta : Word;
     PathToClientLizAndUnLock : String;
     PriceSklad : Word;{код объекта для расчета прайс-листа клиентов}
     PathToSPR : String;
     End;





Function ClearChar(S : TDateString):TDateString;
Var i,j : Byte;
    ss  : TDateString;
Begin
DelZerro(s);
j:=1;
ss[0]:=#0;
For i := 1 To Ord(S[0]) Do
 If s[i] in ['1','2','3','4','5','6','7','8','9','0'] Then
  Begin
   ss[j]:=s[i];
   ss[0]:=Chr(j);
   Inc(j);
  End;
ClearChar:=ss;
End;



Procedure AddLog(Var Log:Text;s:String);
Var j : Word;
Begin
 j:=IoResult;
 WriteLn(Log,
 TodayString(DateMask)+'('+Times+')'+'"'+DayString[DayOfWeek(ToDay)]+'"'+'│'+
 s);
 j:=IoResult;
 Writeln('('+Times+') '+s);
 j:=IoResult;
End;




Var
    ReplicationObject: Array [1..CMaxSklads] Of Byte;{управляется параметрами коммандной строки}
    IndexTasks: Array [1..CMaxTasks] Of Byte;{список задач подлежащих обработке}
    i,j : Word;
    Res : LongInt;
    Ini : Text;
    Log : Text;
    FileName : String;
    III : SkladTask;


Procedure ClearIni;
VAr c : Word;
Begin
III.PathToClientLizAndUnLock[0]:=#0;
III.PathToSPR:=#0;
III.LockStatusWithDelta:=0;
III.PathToClientPrice[0]:=#0;
III.PriceSklad:=1;
For c:=1 To CMaxSklads Do
Begin
III.Task[c].Name [0]:=#0;
III.Task[c].PathToRazdel [0]:=#0;
III.Task[c].IndexClient:=0;
III.Task[c].CalcDolg:=0;
III.Task[c].PathToSklad  [0]:=#0;
III.Task[c].PathToId     [0]:=#0;
III.Task[c].PathToIndex  [0]:=#0;
III.Task[c].StartDateIndexClient[0]:=#0;
III.Task[c].StopDateIndexClient[0]:=#0;
III.Task[c].PathToClient[0]:=#0;
III.Task[c].PathToClientBaseIDX[0]:=#0;
III.Task[c].PathToMarket[0]:=#0;
III.Task[c].PathToDolg[0]:=#0;
III.Task[c].PathToIndexClientOborot[0]:=#0;
III.Task[c].DeltaDateClientTovar:=0;
III.Task[c].DeltaDateClientDocument:=0;
III.Task[c].PathToIndexClientTovar[0]:=#0;
III.Task[c].PathToIndexClientDocument[0]:=#0;
{возвраты клиентов *.cvz}
III.Task[c].StartDateIndexClientReturn[0]:=#0;
III.Task[c].StopDateIndexClientReturn[0]:=#0;
III.Task[c].PathToReturn[0]:=#0;
III.Task[c].PathToIndexClientReturn[0]:=#0;
III.Task[c].StartDateIndexClientOplata[0]:=#0;
III.Task[c].StopDateIndexClientOplata[0]:=#0;
III.Task[c].StopDateIndexClientOplata[0]:=#0;
III.Task[c].PathToOplata[0]:=#0;
III.Task[c].PathToIndexClientOplata[0]:=#0;
End;
End;


Procedure ReadNewIni(Var f : text;Var Res : LongInt);
Var i : Byte;
    c : Byte;
    SH: TStringHolder;

Function GetAsString(Name:AllStr):String;
Begin
GetAsString[0]:=#0;
GetAsString:=SH.GetString (Name);
End;

Function GetAsInteger(Name:AllStr):LongInt;
Begin
GetAsInteger:=0;
GetAsInteger:=StrToInt(SH.GetString (Name));
End;

Begin
Assign (f,'index.ini');
Res := IOResult;
Reset(f);
Res := IOResult;
If Res <> 0 Then Exit;
Close(f);
Res := IOResult;
SH.Init;
SH.LoadFromFile ('index.ini');


III.PathToClientLizAndUnLock:=GetAsString('PathToClientLizAndUnLock');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.PathToSPR:=GetAsString('PathToSPR');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.PathToClientPrice:=GetAsString('PathToClientPrice');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.PriceSklad:=GetAsInteger('PriceSklad');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

If (III.PriceSklad<1) Or (III.PriceSklad>30) Then III.PriceSklad:=1;

III.LockStatusWithDelta:=GetAsInteger('LockStatusWithDelta');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


For c:=1 To CMaxSklads Do
Begin
III.Task[c].StartDateIndexClient:=GetAsString('StartDateIndexClient['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
III.Task[c].StopDateIndexClient:=GetAsString('StopDateIndexClient['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DelSpaceRight(III.Task[c].StopDateIndexClient);
If III.Task[c].StopDateIndexClient='' Then III.Task[c].StopDateIndexClient:=FDate;

III.Task[c].PathToClient:=GetAsString('PathToClient['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


III.Task[c].Name:=GetAsString('Name['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].IndexClient:=GetAsInteger('IndexClient['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].CalcDolg:=GetAsInteger('CalcDolg['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToClientBaseIDX:=GetAsString('PathToClientBaseIDX['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
III.Task[c].PathToMarket:=GetAsString('PathToMarket['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
III.Task[c].PathToDolg:=GetAsString('PathToDolg['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
III.Task[c].PathToIndexClientOborot:=GetAsString('PathToIndexClientOborot['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
III.Task[c].DeltaDateClientTovar:=GetAsInteger('DeltaDateClientTovar['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
III.Task[c].DeltaDateClientDocument:=GetAsInteger('DeltaDateClientDocument['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
III.Task[c].PathToIndexClientTovar:=GetAsString('PathToIndexClientTovar['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
III.Task[c].PathToIndexClientDocument:=GetAsString('PathToIndexClientDocument['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
{возвраты клиентов *.cvz}
III.Task[c].StartDateIndexClientReturn:=GetAsString('StartDateIndexClientReturn['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].StopDateIndexClientReturn:=GetAsString('StopDateIndexClientReturn['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DelSpaceRight(III.Task[c].StopDateIndexClientReturn);
If III.Task[c].StopDateIndexClientReturn='' Then III.Task[c].StopDateIndexClientReturn:=FDate;


III.Task[c].PathToReturn:=GetAsString('PathToReturn['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToIndexClientReturn:=GetAsString('PathToIndexClientReturn['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

{оплаты клиентов *.cpl}
III.Task[c].StartDateIndexClientOplata:=GetAsString('StartDateIndexClientOplata['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].StopDateIndexClientOplata:=GetAsString('StopDateIndexClientOplata['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

DelSpaceRight(III.Task[c].StopDateIndexClientOplata);
If III.Task[c].StopDateIndexClientOplata='' Then III.Task[c].StopDateIndexClientOplata:=FDate;


III.Task[c].PathToOplata:=GetAsString('PathToOplata['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToIndexClientOplata:=GetAsString('PathToIndexClientOplata['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToIndex:=GetAsString('PathToIndex['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToRAzdel:=GetAsString('PathToRazdel['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToSklad:=GetAsString('PathToSklad['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


III.Task[c].PathToId:=GetAsString('PathToId['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


End;

SH.Done;
End;



Procedure WriteNewIni(c:Word);
Var i : Byte;
Begin

Writeln('StartDateIndexClient['+IntToStr(c,CMantissa)+']='+III.Task[c].StartDateIndexClient);

Writeln('StartDateIndexClient['+IntToStr(c,CMantissa)+']='+III.Task[c].StopDateIndexClient);

Writeln('PathToClient['+IntToStr(c,CMantissa)+']='+III.Task[c].PathToClient);

Writeln('IndexClient['+IntToStr(c,CMantissa)+']=',III.Task[c].IndexClient);

Writeln('PathToClientBaseIDX['+IntToStr(c,CMantissa)+']='+III.Task[c].PathToClientBaseIDX);

Writeln('PathToMarket['+IntToStr(c,CMantissa)+']='+III.Task[c].PathToMarket);

Writeln('PathToIndexClientOborot['+IntToStr(c,CMantissa)+']='+III.Task[c].PathToIndexClientOborot);

Writeln('DeltaDateClientTovar['+IntToStr(c,CMantissa)+']=',III.Task[c].DeltaDateClientTovar:3);

Writeln('DeltaDateClientDocument['+IntToStr(c,CMantissa)+']=',III.Task[c].DeltaDateClientDocument:3);

Writeln('PathToIndexClientTovar['+IntToStr(c,CMantissa)+']='+III.Task[c].PathToIndexClientTovar);

Writeln('PathToIndexClientDocument['+IntToStr(c,CMantissa)+']='+III.Task[c].PathToIndexClientDocument);

Writeln('StartDateIndexClientReturn['+IntToStr(c,CMantissa)+']='+III.Task[c].StartDateIndexClientReturn);

Writeln('StopDateIndexClientReturn['+IntToStr(c,CMantissa)+']='+III.Task[c].StopDateIndexClientReturn);

Writeln('PathToReturn['+IntToStr(c,CMantissa)+']='+III.Task[c].PathToReturn);

Writeln('PathToIndexClientReturn['+IntToStr(c,CMantissa)+']='+III.Task[c].PathToIndexClientReturn);

Writeln('StartDateIndexClientOplata['+IntToStr(c,CMantissa)+']='+III.Task[c].StartDateIndexClientOplata);

Writeln('StopDateIndexClientOplata['+IntToStr(c,CMantissa)+']='+III.Task[c].StopDateIndexClientOplata);

Writeln('PathToOplata['+IntToStr(c,CMantissa)+']='+III.Task[c].PathToOplata);

Writeln('PathToIndexClientOplata['+IntToStr(c,CMantissa)+']='+III.Task[c].PathToIndexClientOplata);


Writeln('PathToIndex['+IntToStr(c,CMantissa)+']='+III.Task[c].PathToIndex);

Writeln('PathToRazdel['+IntToStr(c,CMantissa)+']='+III.Task[c].PathToRazdel);

Writeln('PathToSklad['+IntToStr(c,CMantissa)+']='+III.Task[c].PathToSklad);

Writeln('PathToId['+IntToStr(c,CMantissa)+']='+III.Task[c].PathToId);

End;







Procedure ShowHelp;
Begin
Writeln('Утилита индексации баз данных '+CompileDate);
Writeln('Протокол операций '+ClearChar(FDAte)+'.log');
Writeln('Файл конфигурации index.ini');
Writeln('Управляется следующими параметрами коммандной строки:');
Writeln('/1 - включить мониторинг изменений для склада N 1');
Writeln('/2 - для склада N 2   /3 - для склада N 3');
Writeln('/4 - для склада N 4   /5 - для склада N 5');
Writeln('/6 - для склада N 6   /7 - для склада N 7');
Writeln('/8 - для склада N 8   /9 - для склада N 9');
Writeln('/A - для склада N 10  /B - для склада N 11');
Writeln('/C - для склада N 12  /D - для склада N 13');
Writeln('/E - для склада N 14  /F - для склада N 15');
Writeln('/G - для склада N 16  /H - для склада N 17');
Writeln('/I - для склада N 18  /J - для склада N 19');
Writeln('/K - для склада N 20  /L - для склада N 21');
Writeln('/M - для склада N 22  /N - для склада N 23');
Writeln('/O - для склада N 24  /P - для склада N 25');
Writeln('/Q - для склада N 26  /R - для склада N 27');
Writeln('/S - для склада N 28  /T - для склада N 29');
Writeln('/U - для склада N 30');
Writeln('KDX      - индексация наличия товаров (*.kdx *.idx)');
Writeln('OBOROT   - индексация оборотов клиентов (*.his)');
Writeln('RETURN   - индексация возвратов клиентов (*.cpl)');
Writeln('OPLATA   - индексация оплат клиентов (*.cpl)');
Writeln('TOVAR    - индексация товарооборота клиентов (*.tlx)');
Writeln('DOCUMENT - индескация документооборота клиентов (*.tdx)');
Writeln('TESTSROKLIZ -тестировать сроки действия лицензий и закрывать отгрузки');
Writeln('UNLOCK   - снятие обнаруженных сетевых блокировок');
Writeln('CALCDOLG - генерация сводного отчета по долгам клиентов');
Writeln('PRICE - сформировать прайс-листы для клиентов');
Writeln('CLIENT - индексация базы client.db');
Halt;
End;


{создание индекса по оборотам клиентов *.his}

Function SaveToStatFile(L:PSuperMarketType;S:Boolean;Ind : Word):Boolean;
Var Es : PstatClientType;
    Esf : File Of StatClientType;
    i : Byte;
    SkKod : TDAteSTring;
Begin
 SaveToStatFile:=False;
 Assign(esf,III.Task[Ind].PathToIndexClientOborot+L^.Dat.ClientKod+'.his');
 i:=IOResult;
 Reset(esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
   Exit;
  End;
 New(Es,Init);
 skKod:=IntToStr(Ind,CMantissa);
 RFormatZerro(SkKod,CClientKod);
 Es^.Dat.SkladKod:=Ind;

         With Es^.Dat Do
          Begin
        If L^.Dat.DocSelector in [4,8] Then    Rashet:=0
        Else    Rashet:=1;
        Realiz:=L^.Dat.Realiz;
        Document:=L^.Dat.Document;
      SertifSummZ:=StrToReal(L^.Dat.SertifSummaZ);
     SertifSkidka:=StrToReal(L^.Dat.SertifSkidka);
    SertifSummaZakupka:=StrToReal(L^.Dat.SertifSummaZakupka);

        SummaZ:=StrToReal(L^.Dat.SummaZ);
        Skidka:=StrToReal(L^.Dat.Skidka);
        SummaZakupka:=StrToReal(L^.Dat.SummaZakupka);
        SummaAkzis:=StrToReal(L^.Dat.SummaAkzis);

        Bn.DAte:=L^.Dat.bn.Date;
        Bn.NPlat:=L^.Dat.bn.NPlat;
        Bn.BankKod:=L^.Dat.bn.BankKod;
        Bn.Summa:=L^.Dat.bn.Summa;
        Caption:=L^.Dat.Caption;
        DateC:=DateStringToDate(DateMask,L^.Dat.DateC);
        TimeC:=TimeStringToTime('hh:mm:ss',L^.Dat.TimeC);
        DateM:=DateStringToDate(DateMask,L^.Dat.DateM);
        TimeM:=TimeStringToTime('hh:mm:ss',L^.Dat.TimeM);
        DocSelector :=L^.Dat.DocSelector;
        SkidkaSelector :=L^.Dat.SkidkaSelector;
        AgentKod:=L^.Dat.AgentKod;
        EkspeditorKod:=L^.Dat.EkspeditorKod;
        Active:=True;
        {CalcRaspredelenie(L,Es);}
          End;
          i:=IOResult;
          Seek(Esf,FileSize(Esf));
          i:=IOResult;
          Write(Esf,Es^.Dat);
          i:=IOResult;

        If i<>0 Then
         Begin
          DiSpose(Es,Done);
          Close(Esf);
          i:=IOResult;
          AddLog(Log,'Ошибка записи в файл '+III.Task[Ind].PathToIndexClientOborot+L^.Dat.CLientKod+'.his'+
		' для объекта '+IntToStr(Ind,CMantissa)+' Код:'+
          IntToStr(i,3));
          Exit;
         End;

Dispose(Es,Done);
i:=IOResult;
Close(Esf);
i:=IOResult;
SaveToStatFile:=True;
End;



Procedure MAkeClientIndex(ind:Word);
Var tt : File Of StatClientType;
    f : MarketFileType;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    E : PSuperMArketType;
    Cur,Start,Stop : LongInt;
    Curs : TDateString;
    ff : Boolean;

Begin
AddLog(Log,'Уничтожаю старые индексы по оборотам клиентов для объекта '+IntToStr(Ind,CMantissa)+'...');
Assign(ClientFile,III.Task[Ind].PathToClient+'client.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
  AddLog(Log,'Ошибка открытия базы клиентов '+III.Task[Ind].PathToClient+' для объекта '+IntToStr(Ind,CMantissa)+' Код:'+
  IntToStr(i,3));
  Exit;
 End;
{цикл уничтожения ранее существовавших индексов}

While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);
 Assign(tt,III.Task[Ind].PathToIndexClientOborot+ClientElement.Kod+'.his');
 i:=IOResult;
 Rewrite(tt);
 i:=IOResult;
 If i<>0 Then
  AddLog(Log,'Ошибка создания файла хронологии '+III.Task[Ind].PathToIndexClientOborot+ClientElement.Kod+'.his Код:'+
  IntToStr(i,3))
 Else
 Close(tt);
 i:=IOResult;
End;
Close(ClientFile);

Start:=DateStringToDAte(DAteMask,III.Task[Ind].StartDateIndexClient);
Stop:=DateStringToDAte(DAteMask,III.Task[Ind].StopDateIndexClient);

New(E,Init);

AddLog(Log,'Переиндексирую обороты клиентов c '+III.Task[Ind].StartDateIndexClient+' по '+
III.Task[Ind].StopDateIndexClient+' для объекта '+IntToStr(Ind,CMantissa));

For Cur := Start To Stop Do
Begin
Curs:=DateToDateString(DateMask,Cur);
Assign (f,III.Task[Ind].PathToMarket+Curs+'.mrk');
Write(DayString[DayOfWeek(Cur)]+' '+Curs);
i:=IOResult;
Reset(f);
i:=IOResult;
If I =0 Then
Begin
 While Not(Eof(f)) Do
  Begin
   ReadMarket(f,E);
   If StrToInt(E^.Dat.SkladKod)=Ind Then
   If (E^.Dat.OperatorSelector=0) And (E^.Dat.Active) Then
   Begin
    If ((E^.Dat.DocSelector in [0,1,2,3,4]) And Not(E^.Dat.Realiz))
    Or ((E^.Dat.DocSelector in [5,6,7,8]) And (E^.Dat.Realiz)) Then
    Begin
     If E^.Dat.DocSelector in [3,4,6,8] Then ff:=True
     Else FF:=False;
     SaveToStatFile(E,FF,Ind);
    End;
   End;
  End;
 i:=IOResult;
 Close(f);
 i:=IOResult;
 Write('-Ok');
End{}
Else Write('- нет данных');

Writeln;
End;{For}
Dispose(E,Done);


AddLog(Log,'Оптимизирую обороты клиентов c '+III.Task[Ind].StartDateIndexClient+' по '+
III.Task[Ind].StopDateIndexClient+' для объекта '+IntToStr(Ind,CMantissa));

Reset(ClientFile);
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);
 Assign(tt,III.Task[Ind].PathToIndexClientOborot+ClientElement.Kod+'.his');
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

AddLog(Log,'Индексация оборотов клиентов c '+III.Task[Ind].StartDateIndexClient+' по '+
III.Task[Ind].StopDateIndexClient+' для объекта '+IntToStr(Ind,CMantissa)+' успешно завершена!');
End;{Procedure}





Function GetIDField(Ind:Word;Field:Byte;C:ArtikulStr):TEnjoyStr;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    OldFileMode : Word;
    FId  : BazFileType;
    Id   : PBazType;
Begin
 GetIdField[0]:=#0;
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fId,III.Task[Ind].PathToID+c+'.id');
 GetIdField[0]:=#0;
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);

   If l>FileSize(fid) Then
    Begin
     System.Close(fid);
     l:=IOResult;
     {MessageBox(^M+#3'Попытка чтения базы наименований ('+st+') '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);}
     AddLog(Log,'Попытка чтения базы наименований ('+st+') '+c+' - позиция вне файла!'+
	' для объекта '+IntToSTr(Ind,2));
     Exit;
    End;

   Seek(fid,L);
   New(id,Init);
   Code:=IOResult;
   ReadBazPointer(FId,Id);
   Close(fid);
   Case Field Of
  FEnableMarket :GetIdField:=IntToStr(Id^.Dat.Market,COne);
  FDebit        :GetIdField:=IntToStr(Id^.Dat.EnableDebit,COne);
  FFFName:Begin
           DelSpaceRight(Id^.Dat.Name);
           DelSpaceRight(Id^.Dat.Name2);
           GetIdField:=Id^.Dat.Name+' '+Id^.Dat.Name2;
          End;

  FName:GetIdField:=Id^.Dat.Name;
  FName2:GetIdField:=Id^.Dat.Name2;
  FFName:GetIdField:=Id^.Dat.Name;
  FFName2:GetIdField:=Id^.Dat.Name2;

  FLitr:GetIdField:=Id^.Dat.Litr;
  FMAssa:GetIdField:=Id^.Dat.Massa;
  FFirmaPost : GetIdField:=Id^.Dat.FirmaPostKod;

  FEnableContract : GetIdField:=IntToStr(Id^.Dat.EnableContract,COne);
  FContractNumer : GetIdField:=Id^.Dat.Contract;
  FContractDate  : GetIdField:=Id^.Dat.ContractDate;

  FInPack:GetIdField:=Id^.Dat.InPack;
  FOperator:GetIdField:=Id^.Dat.CAption;
  FKtoSertif:GetIdField:=Id^.Dat.KSertif;
  FDateSertif:GetIdField:=Id^.Dat.DSertif;
  FEnableSklads:GetIdField:=IntToStr(Id^.Dat.EnableSklads,CKol);

  FNalog:GetIdField:=Id^.Dat.Nalog;
  FVidNalog:Begin
             Str(Id^.Dat.VidNalog:COne,St);
             DelSpace(St);
             GetIdField:=St;
            End;
  FNDS     :GetIdField:=Id^.Dat.NDS;
  FVidNDS  :Begin
             Str(Id^.Dat.VidNDS:COne,St);
             DelSpace(St);
             GetIdField:=St;
            End;
  FOrganization :Begin
             {
             Str(Id^.Dat.Organization:COne,St);
             DelSpace(St);
             GetIdField:=St;
             }
            End;
{$IfDEF Tara}
  FFEnable :Begin
             Str(Id^.Dat.FantomEnable:COne,St);
             DelSpace(St);
             GetIdField:=St;
            End;
  FFKod    :GetIdField:=Id^.Dat.FantomKod;
  FFInPack :GetIdField:=Id^.Dat.FantomInPack;
{$EndIF}

  FMain :Begin
          Str(Id^.Dat.Main:COne,St);
          DelSpace(St);
          GetIdField:=St;
         End;
  FFantomKod:
     Begin
      RFormatZerro(Id^.Dat.Mera,CClientKod);
	 GetIdField:=Id^.Dat.FantomKod;
     End;
  FBuchGroup:GetIdField:=IntToStr(Id^.Dat.BuchGroup,COne);
  FGroup,
  FNGroupKod:GetIdField:=Id^.Dat.NGroupKod;
  FEtil     :GetIdField:=Id^.Dat.Etil;
  FMera    : Begin
             st:=Id^.Dat.Mera;
             RFormatZerro(Id^.Dat.Mera,CClientKod);
             DelSpaceRight(St);
             GetIdField:=St;
            {0Case Id^.Dat.Mera Of
              0:st:='шт';
              1:st:='кг';
              2:st:='мш';
              3:st:='л ';
              4:st:='бл';
              5:st:='бр';
              Else St:='??';
              End;{Case}
             { GetIdField:=St;}
             End;

   Else;
   End;{CAse}
  End;

  If Not(Id^.Dat.Employ) And (Field in [FFName,FNAme]) Then
   Begin
    GetIDField:='!!!ТОВАР УДАЛЕН!!!';
    {AddLog(Log,III.Task[Ind].PathToID+Copy(st,1,CRazdelKod)+'.id '+Id^.DAt.BazKod+' '+Id^.Dat.Name);}
   End;

  Dispose(Id,Done);
End;



Function GetPostField(C:ArtikulStr):String;
Var f : PostFileType;
    l : LongInt;
    s : PostType;
Begin
 GetPostField:=#0;

 Assign (f,III.PathToSPR+'lands.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Writeln('Ошибка открытия '+III.PathToSPR+'lands.db Код:'+IntToStr(l,3));
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     Writeln('Попытка чтения страны '+c+' - позиция вне файла!');
     Exit;
    End;

   Seek(f,l);
   ReadPost(f,s);
   Close(f);
   l:=IOResult;
   GetPostField:=S.Post;
  End;
  {If Not(s.Employ) Then GetPostField:='!!!СТРАНА УДАЛЕНА!!';}
End;


Function GetFirmaPostField(C:ArtikulStr):String;
Var f : FirmaPostFileType;
    l : LongInt;
    s : FirmaPostType;
Begin
 GetFirmaPostField:=#0;

 Assign (f,III.PathToSPR+'firma.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Writeln('Ошибка открытия '+III.PathToSPR+'firma.db Код:'+IntToStr(l,3));
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     Writeln('Попытка чтения фирм '+c+' - позиция вне файла!');
     Exit;
    End;

   Seek(f,l);
   ReadFirmaPost(f,s);
   Close(f);
   l:=IOResult;
   GetFirmaPostField:=S.FirmaPost;
  End;
End;




Function GetMarkaField(C:ArtikulStr):String;
Var f : MarkaFileType;
    l : LongInt;
    s : MarkaType;
Begin
 GetMarkaField:=#0;

 Assign (f,III.PathToSPR+'marka.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Writeln('Ошибка открытия '+III.PathToSPR+'marka.db Код:'+IntToStr(l,3));
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     Writeln('Попытка чтения акц.марки (серии) '+c+' - позиция вне файла!');
     Exit;
    End;

   Seek(f,l);
   ReadMarka(f,s);
   Close(f);
   l:=IOResult;
   GetMarkaField:=S.Marka;
  End;
End;







Function GetBazElement(Ind:Word;C:ArtikulStr;Var E:BazType):Boolean;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    fid  : BazFileType;
     id  : PBAzType;
Begin
 GetBAzElement:=False;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fId,III.Task[Ind].PathToID+c+'.id');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Writeln('Ошибка открытия '+III.Task[Ind].PathToID+c+'.id'+' Код:['+IntToStr(l,CKol)+']');
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   If l>FileSize(fid) Then
    Begin
     l:=IOResult;
     Writeln('Попытка чтения товара '+c+IntToStr(FileSize(FId),CKOl)+' - позиция вне файла!');
     System.Close(fid);
     l:=IOResult;
     Exit;
    End;

   Seek(fid,L);
   New(id,Init);
   Code:=IOResult;
   ReadBazPointer(FId,Id);
   Code:=IOResult;
   l:=IOResult;
   Close(fid);
   E:=Id^.Dat;
   GetBAzElement:=True;
   If Not(Id^.Dat.Employ) Then
     Writeln('Позиция ('+Id^.Dat.BazKod+')'+' помечена как удаленная!');
   Dispose(Id,Done);
  End;
End;




Procedure MakeKDX(Ind:Word);
VAr SklFile : File Of SkladType;
    Skl     : PSkladType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    {
    IndexFile : IndexFileType;
    Index : PIndexType;
    }
    IndexFileNew : File Of SkladTypeNew;
    Indexnew : PSkladTypenew;
    F : Boolean;
    c : Word;
    ch : LongInt;
    ws : String;
    k,All : LongInt;
    j : Word;
Begin
c:=IOResult;
Assign(RazdelFile,III.Task[Ind].PathToRazdel+'Razdel.db');
Reset(RazdelFile);
c:=IOResult;

If c<>0 Then
 Begin
  AddLog(Log,'Ошибка доступа к файлу разделов '+III.Task[Ind].PathToRazdel+' для объекта '+IntToStr(Ind,CMantissa)+' Код:'+
  IntToStr(c,3));
  Exit;
 End;

Writeln('Индексация наличия товаров на складе (объект N '+IntToStr(Ind,CMantissa)+')...');

While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
   Assign(SklFile,III.Task[Ind].PathToSklad+RazdelElement.Kod+'.db');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;
   Write('Раздел '+RazdelElement.Kod+'-');

If c<>0 Then
 Begin
  Close(RazdelFile);
  AddLog(Log,'Ошибка доступа к файлу '+III.Task[Ind].PathToSklad+RazdelElement.Kod+'.db'+' для объекта '+
  IntToStr(Ind,CMantissa)+' Код:'+
  IntToStr(c,3));
  Exit;
 End;

{
c:=IOResult;
Assign(IndexFile,III.Task[Ind].PathToIndex+RazdelElement.Kod+'.idx');
Rewrite(IndexFile);
c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  Close(SklFile);
  AddLog(Log,'Ошибка создания файла индексов '+III.Task[Ind].PathToIndex+RazdelElement.Kod+'.idx'+' для объекта '+
  IntToStr(Ind,CMantissa)+' Код:'+
  IntToStr(c,3));
  Exit;
 End;
}
c:=IOResult;
Assign(IndexFileNew,III.Task[Ind].PathToIndex+RazdelElement.Kod+'.kdx');
Rewrite(IndexFileNew);
c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  Close(SklFile);
  {Close(IndexFile);}
  AddLog(Log,'Ошибка создания файла индексов '+III.Task[Ind].PathToIndex+RazdelElement.Kod+'.kdx'+' для объекта '+
  IntToStr(Ind,CMantissa)+' Код:'+
  IntToStr(c,3));
  Exit;
 End;

   New(Skl,Init);
   {New(Index,Init);}
   New(IndexNew,Init);
   ch:=0;
   While Not(Eof(sklFile)) Do
    Begin

     Repeat
      Pause(1);
     Until NetCAll.Lock(SklFile,FilePos(SklFile)*SizeOf(SkladType),SizeOf(SkladType));

     Read(SklFile,Skl^.Dat);
     Str(ch:3,ws);
     While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';

     If Skl^.Dat.Employ Then
     With Skl^.Dat.Input Do
     Begin
      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(Division[k]):CKol,Division[k]);
           DelSpace(Division[k]);
           All:=All+StrToInt(Division[k]);
        End;
     Str(All:CKol,Skl^.Dat.Input.Kol);
     DelSpace(Skl^.Dat.Input.Kol);

     {
     If StrToInt(Skl^.Dat.Input.Kol)>0 Then
     Index^.Dat.Present[StrToInt(ws)]:=True
     Else
     Index^.Dat.Present[StrToInt(ws)]:=False;
     }
     DelSpace(Skl^.Dat.Input.Kol);

      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(DivisionR[k]):CKol,DivisionR[k]);
           DelSpace(DivisionR[k]);
           All:=All+StrToInt(DivisionR[k]);
        End;
     Str(All:CKol,Skl^.Dat.Input.KolR);
     DelSpace(Skl^.Dat.Input.KolR);

     MyStr(StrToReal(Skl^.Dat.Input.R_Zena),CZena,CMantissa,Skl^.Dat.Input.R_Zena);
     DelSpace(Skl^.Dat.Input.R_Zena);

     MyStr(StrToReal(Skl^.Dat.Input.O_Zena),CZena,CMantissa,Skl^.Dat.Input.O_Zena);
     DelSpace(Skl^.Dat.Input.O_Zena);

     Skl^.Dat.Date:=DateStringToDAte(DateMask,FDate);
     Skl^.Dat.Time:=CurrentTime;
     MyStr(StrToReal(Skl^.Dat.Input.Zakupka),CZenaZ,CMantissaZ,Skl^.Dat.Input.Zakupka);
     Skl^.Dat.Input.Caption:='99';

     End;

     IndexNew^.Dat.Name :=GetIdField(Ind,FName,Skl^.Dat.BazKod);
     IndexNew^.Dat.Name2:=GetIdField(Ind,FName2,Skl^.Dat.BazKod);
     IndexNew^.Dat.Virabotano :=DateStringToDate(DateMask,Skl^.Dat.input.Virabotano);
     IndexNew^.Dat.EnableSklads:=StrToInt(GetIdField(Ind,FEnableSklads,Skl^.DAt.BazKod));
     IndexNew^.Dat.FantomKod:=StrToInt(GetIdField(Ind,FFantomKod,Skl^.DAt.BazKod));
     IndexNew^.Dat.Main:=StrToInt(GetIdField(Ind,FMain,Skl^.DAt.BazKod));
     IndexNew^.Dat.NGroupKod:=StrToInt(GetIdField(Ind,FNGroupKod,Skl^.DAt.BazKod));

     IndexNew^.Dat.FirmaPostKod:={StrToInt(Be^.Dat.FirmaPostKod);}
	StrToInt(GetIdField(Ind,FFirmaPost,Skl^.Dat.BazKod));
     IndexNew^.Dat.NMarkaKod:=StrToInt(Skl^.Dat.Input.Marka);
     IndexNew^.Dat.NSpecMarkaKod:=StrToInt(Skl^.Dat.Input.SpecMarka);
     IndexNew^.Dat.NExpertKod:=StrToInt(Skl^.Dat.Input.Expert);
     IndexNew^.Dat.NGTDKod:=StrToInt(Skl^.Dat.Input.NGTD);

     IndexNew^.Dat.Employ :=Skl^.DAt.Employ;
     IndexNew^.Dat.NSertif :=StrToInt(Skl^.DAt.Input.NSertif);
     For j:=1 To CDivision Do IndexNew^.Dat.Division[j]:=StrToInt(Skl^.Dat.Input.Division[j]);
     For j:=1 To CDivision Do IndexNew^.Dat.DivisionR[j]:=StrToInt(Skl^.Dat.Input.DivisionR[j]);
     IndexNew^.Dat.R_Zena  :=StrToreal(Skl^.Dat.Input.R_Zena);

     IndexNew^.Dat.Zakupka :=StrToreal(Skl^.Dat.Input.Zakupka);
     IndexNew^.Dat.Zakupka2:=StrToreal(Skl^.Dat.Input.Zakupka2);
     IndexNew^.Dat.AkzisSbor:=StrToreal(Skl^.Dat.Input.AkzisSbor);

     IndexNew^.Dat.RegionMarka:=Skl^.Dat.Input.RegionMarka;
     IndexNew^.Dat.BazKod:=StrToInt(Skl^.Dat.BazKod);
     IndexNew^.Dat.Kol:=StrToInt(Skl^.Dat.Input.Kol);
     IndexNew^.Dat.StrihKod:=Skl^.Dat.Input.StrihKod;
     IndexNew^.Dat.NMakeKod:=StrToInt(Skl^.Dat.Input.NMakeKod);

     ws:=RazdelElement.Kod+ws;

     Seek(SklFile,FilePos(SklFile)-1);
     Skl^.Dat.BazKod:=ws;
     Write(SklFile,Skl^.Dat);

     Write(IndexFileNew,IndexNew^.Dat);

     Repeat
      NetCall.UnLock(SklFile,(FilePos(SklFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
     Until (DosError=0);

     Inc(ch);
     End;

   Dispose(Skl,Done);
   Close(SklFile);
   {Write(IndexFile,Index^.Dat);}
   {Close(IndexFile);}
   Close(IndexFileNew);
   Dispose(IndexNew,Done);
   {Dispose(Index,Done);}
   WriteLn('Ok');
   End;
 End;
  c:=IOResult;
  Close(RazdelFile);
  c:=IOResult;
  AddLog(Log,'Переиндексация наличия успешно завершена для объекта '+IntToStr(Ind,CMantissa));
End;







Procedure TestLizensiaAndNetLock;
Var ClientFile,FCopy : ClientFileType;
    ClientElement : ClientType;
    BakClient : PClientType;
    c : LongInt;
    ff,OpenCopy : Boolean;

Begin
AddLog(Log,'Тестирую базу клиентов ...');
Assign(ClientFile,III.PathToClientLizAndUnLock+'client.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
  AddLog(Log,'Ошибка открытия базы клиентов '+III.PathToClientLizAndUnLock+' Код:'+
  IntToStr(i,3));
  Exit;
 End;
{цикл уничтожения ранее существовавших индексов}

While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);
 i:=IOResult;
 If (IndexTasks[6]=1) Then
  Begin
    DelSpaceRight(ClientElement.SrokLizensia);




    If (DateStringToDate(DateMAsk,FDate)>=DateStringToDate(DateMask,ClientElement.SrokLizensia))And
    (ClientElement.SrokLizensia[0]<>#0)  Then
  Begin
    If (ClientElement.Status in [0,1]) Then
    Begin
     i:=IOResult;
     Seek(ClientFile,FilePos(ClientFile)-1);
     i:=IOResult;


  Assign (FCopy,III.PathToClientLizAndUnLock+ClientPrefix+ClientElement.Kod+'.cor');
  OpenCopy:=True;
  c:=IOResult;
  Reset(fCopy);
  c:=IOResult;
  If c<>0 Then
   Begin
     c:=IOResult;
     Rewrite(fCopy);
     c:=IOResult;
     If c<>0 Then
     Begin
      OpenCopy:=False;
      AddLog(Log,'Ошибка сетевого открытия файла '+III.PathToClientLizAndUnLock+ClientPrefix+ClientElement.Kod+'.cor Код:'+
	 IntToStr(c,CKOl));
     End;
   End;



   {читаем прежний экземпляр объекта}
   If OpenCopy Then
    Begin
     c:=IOResult;
     Seek(FCopy,FileSize(FCopy));
     c:=IOResult;
     Write(FCopy,ClientElement);
     c:=IOResult;
     System.Close(FCopy);
     c:=IOResult;
    End;



     ClientElement.RCD:=True;
     ClientElement.Status:=4;
     ClientElement.Auto:='АВТОЗАКРЫТИЕ ОТГРУЗКИ '+Times+' '+FDATE;
     ClientElement.LastCaption:='99';{Mailer}
     Write(ClientFile,ClientElement);
     i:=IOResult;
     AddLog(Log,'БЛОКИРОВКА ОТГРУЗКИ ДЛЯ КЛИЕНТА '+ClientElement.Name+' ['+ClientELement.Kod+']');
    End;
  End
   Else
    Begin

    If ((DateStringToDate(DateMAsk,FDate)+30)>=(DateStringToDate(DateMask,ClientElement.SrokLizensia)))And
    (ClientElement.SrokLizensia[0]<>#0)  Then
  Begin

    If (DateStringToDate(DateMask,ClientElement.SrokLizensia)-DateStringToDate(DateMAsk,FDate))>0 Then
    If (ClientElement.Status in [0,1]) Then
    Begin

  Assign (FCopy,III.PathToClientLizAndUnLock+ClientPrefix+ClientElement.Kod+'.cor');
  OpenCopy:=True;
  c:=IOResult;
  Reset(fCopy);
  c:=IOResult;
  If c<>0 Then
   Begin
     c:=IOResult;
     Rewrite(fCopy);
     c:=IOResult;
     If c<>0 Then
     Begin
      OpenCopy:=False;
      AddLog(Log,'Ошибка сетевого открытия файла '+III.PathToClientLizAndUnLock+ClientPrefix+ClientElement.Kod+'.cor Код:'+
	 IntToStr(c,CKOl));
     End;
   End;


   {читаем прежний экземпляр объекта}
   If OpenCopy Then
    Begin
     c:=IOResult;
     Seek(FCopy,FileSize(FCopy));
     c:=IOResult;
     Write(FCopy,ClientElement);
     c:=IOResult;
     System.Close(FCopy);
     c:=IOResult;
    End;


     i:=IOResult;
     Seek(ClientFile,FilePos(ClientFile)-1);
     i:=IOResult;
     ClientElement.RCD:=True;
     ClientElement.LastCaption:='99';{Mailer}
     ClientElement.Auto:='ЛИЦЕНЗИЯ ИСТЕКАЕТ ЧЕРЕЗ '+
	IntToStr(DateStringToDate(DateMask,ClientElement.SrokLizensia)-DateStringToDate(DateMAsk,FDate)
	         ,CKol)+' ДНЕЙ '+Times+' '+FDATE;
     Write(ClientFile,ClientElement);
     i:=IOResult;
     AddLog(Log,'ПРЕДУПРЕЖДЕНИЕ ОБ ИСТЕЧЕНИИ СРОКА ДЕЙСТВИЯ ЛИЦЕНЗИИ ДЛЯ КЛИЕНТА '+
	ClientElement.Name+' ['+ClientELement.Kod+']');
    End;
  End;



    End;






  End;

 { выключена 14/05/2004 т.к. теперь надо смотреть lck-файлы
 If (IndexTasks[7]=1) Then
  Begin
    If (ClientElement.Locked)  Then
    Begin
     i:=IOResult;
     Seek(ClientFile,FilePos(ClientFile)-1);
     i:=IOResult;
     ClientElement.Locked:=False;
     Write(ClientFile,ClientElement);
     i:=IOResult;
     AddLog(Log,'СЕТЕВАЯ ДЕБЛОКИРОВКА КЛИЕНТА '+ClientElement.Name+' ['+ClientELement.Kod+']');
    End;
  End;
 }
End;
i:=IOResult;
Close(ClientFile);
i:=IOResult;

If (IndexTasks[6]=1) Then
AddLog(Log,'Тестирование сроков лицензии успешно завершено!');

If (IndexTasks[7]=1) Then
AddLog(Log,'Снятие сетевых блокировок успешно завершено!');
End;{Procedure}






Procedure LoadClientList(Var P:PBox);
Var ClientFile : File;
    ClientElement : PBufClientType;
    s : String;
    SProz : AllStr;
    c,j,count : Word;
    txt : Text;

Begin
AddLog(Log,'Загружаю базу клиентов ...');
Assign(ClientFile,III.PathToClientLizAndUnLock+'client.db');
i:=IOResult;
Reset(ClientFile,SizeOf(ClientType));
i:=IOResult;
If i<>0 then
 Begin
  AddLog(Log,'Ошибка открытия базы клиентов '+III.PathToClientLizAndUnLock+' Код:'+
  IntToStr(i,3));
  Exit;
 End;
{цикл уничтожения ранее существовавших индексов}

While Not(eof(ClientFile)) Do
Begin
 New(ClientElement,Init);
 Count:=0;
 ReadBufClient(ClientFile,ClientElement,Count);
 For j:=1 To Count Do
 Begin
   If (ClientElement^.Point.Dat[j].Employ) Then
    If (ClientElement^.Point.Dat[j].Otgruska=1) Then
    If (ClientElement^.Point.Dat[j].Dopolnenie.Price=1) Then
    Begin
       SProz:=ClientElement^.Point.Dat[j].Dopolnenie.Proz;
       c:=IOResult;
       MyStr(StrToReal(SProz),CZena,CMantissa,SProz);
       If StrToReal(SProz)<0.85 then
       AddLog(Log,'ВНИМАНИЕ ОБНАРУЖЕНА ОШИБКА В ПРАЙС-ЛИСТЕ ДЛЯ КЛИЕНТА '+ClientElement^.Point.Dat[j].Name+
     ' ['+ClientElement^.Point.Dat[j].Kod+'] %='+SProz);

       AddLog(Log,'ОБНАРУЖЕН ПРАЙС-ЛИСТ ДЛЯ КЛИЕНТА '+ClientElement^.Point.Dat[j].Name+
     ' ['+ClientElement^.Point.Dat[j].Kod+'] %='+SProz);
       s:='│'+ClientElement^.Point.Dat[j].Kod+'│'+SProz+'│'+ClientElement^.Point.Dat[j].Dopolnenie.MailPath;
       P^.List^.Insert(NewStr(s));
       P^.SetRange(P^.List^.Count);

     {список}
    End;
 End;{For}
 Dispose(ClientElement,Done);
End;{While}
i:=IOResult;
Close(ClientFile);
i:=IOResult;

AddLog(Log,'Загрузка базы клиентов для прайсов успешно завершено!');

End;{Procedure}




{создание индекса по возвратам клиентов}
Procedure SaveToClientReturnFile(Cl:PClientNewVozwratType;Ind:Word);
Var f : File Of ClientNewVozwratType;
    i : Word;
Begin
 Assign(f,III.Task[Ind].PathToIndexClientReturn+Cl^.Dat.Return.MakeKod+'.cvz');
 i:=IOResult;
 Reset(f);
 i:=IOResult;
 If I<>0 Then
  Begin
    Exit;
  End;
 i:=IOResult;
 Seek(f,FileSize(f));
 i:=IOResult;
 Write(f,Cl^.Dat);
 i:=IOResult;
 System.Close(f);
 i:=IOResult;
End;






Procedure RetrunToIndex(VAr CRet:PClientNewVozwratType;Ret:PNewVozwratType);
Begin
   With CRet^.Dat.Return Do
    Begin
     OperatorSelector:=Ret^.Dat.OperatorSelector;
     VidDocument     :=Ret^.Dat.VidDocument     ;
     DocSelector     :=Ret^.Dat.DocSelector     ;
     MakeKod         :=Ret^.Dat.MakeKod         ;
     Document        :=Ret^.Dat.Document        ;
     DocumentPrz     :=Ret^.Dat.DocumentPrz     ;
     SummaO          :=StrToReal(Ret^.Dat.SummaO)          ;
     SummaR          :=StrToReal(Ret^.Dat.SummaR)          ;
     SummaZakupka    :=StrToReal(Ret^.Dat.SummaZakupka)    ;
     SummaZakupka2   :=StrToReal(Ret^.Dat.SummaZakupka2)   ;
     SummaAkzis      :=StrToReal(Ret^.Dat.SummaAkzis)      ;
     Skidka          :=StrToReal(Ret^.Dat.Skidka)          ;
     SkladKod        :=Ret^.Dat.SkladKod        ;
     Caption         :=Ret^.Dat.Caption         ;
     DateC           :=DateStringToDAte(DateMask,Ret^.Dat.DateC);
     TimeC           :=TimeStringToTime('hh:mm:ss',Ret^.Dat.TimeC);
     DateM           :=DateStringToDAte(DateMask,Ret^.Dat.DateM);
     TimeM           :=TimeStringToTime('hh:mm:ss',Ret^.Dat.TimeM);
     BasisDoc        :=Ret^.Dat.BasisDoc        ;
     BasisDate       :=DateStringToDAte(DateMask,Ret^.Dat.BasisDate);
     Opt             :=Ret^.Dat.Opt             ;
     Rashod          :=Ret^.Dat.Rashod          ;
     RashodSumma     :=StrToReal(Ret^.Dat.RashodSumma);
    End;{With}
End;






Procedure MAkeClientReturnIndex(Ind:Word);
Var tt : File Of ClientNewVozwratType;
    f1 : NewVozwratFileType;
    Ret: PNewVozwratType;
  cret : PClientNewVozwratType;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    Start,Stop : LongInt;
    Cur : LongInt;
    Curs : TDAteString;
Begin
AddLog(Log,'Уничтожаю старые индексы по возвратам клиентов для объекта '+IntToStr(Ind,CMantissa)+'...');

Assign(ClientFile,III.Task[Ind].PathToClient+'client.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
  AddLog(Log,'Ошибка открытия базы клиентов '+III.Task[Ind].PathToClient+'client.db для объекта '+IntToStr(Ind,CMantissa)+
  ' Код:'+
  IntToStr(i,3));
  Exit;
 End;
{цикл уничтожения ранее существовавших индексов}
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);
 Assign(tt,III.Task[Ind].PathToIndexClientReturn+ClientElement.Kod+'.cvz');
 i:=IOResult;
 Rewrite(tt);
 i:=IOResult;
 If i<>0 Then
  AddLog(Log,'Ошибка создания файла '+III.Task[Ind].PathToIndexClientOborot+ClientElement.Kod+'.cvz Код:'+
  IntToStr(i,3))
 Else
 Close(tt);
 i:=IOResult;
End;
 i:=IOResult;
Close(ClientFile);
 i:=IOResult;

Start:=DateStringToDAte(DAteMask,III.Task[Ind].StartDateIndexClientReturn);
Stop:=DateStringToDAte(DAteMask,III.Task[Ind].StopDateIndexClientReturn);

AddLog(Log,'Переиндексирую возвраты клиентов c '+III.Task[Ind].StartDateIndexClientReturn+' по '+
III.Task[Ind].StopDateIndexClientReturn+' для объекта '+IntToStr(Ind,CMantissa));

New(Ret,Init);
For Cur := Start To Stop Do
Begin
Curs:=DateToDateString(DateMask,Cur);
Write(DayString[DayOfWeek(Cur)]+' '+Curs);
i:=IOResult;
Assign (f1,III.Task[Ind].PathToReturn+Curs+'.vzw');
i:=IOResult;
Reset(f1);
i:=IOResult;
If I =0 Then
Begin
 While Not(Eof(f1)) Do
  Begin
   ReadNewVozwrat(f1,Ret);

   If StrToInt(Ret^.Dat.SkladKod)=Ind Then{если клиентский возврат}
   If Ret^.Dat.OperatorSelector=0 Then{если клиентский возврат}
 Begin
   New(CRet,Init);
   RetrunToIndex(CRet,Ret);
   SaveToClientReturnFile(CRet,Ind);
   Dispose(CRet,Done);
 End;{id}
  End;
 i:=IOResult;
 Close(f1);
 i:=IOResult;
 Write('-Ok');
End{}
Else Write('- нет данных');

Writeln;
End;{For}
Dispose(Ret,Done);


AddLog(Log,'Оптимизирую индексы по возвратам клиентов c '+III.Task[Ind].StartDateIndexClientReturn+' по '+
III.Task[Ind].StopDateIndexClientReturn+' для объекта '+IntToStr(Ind,CMantissa));
 i:=IOResult;
Reset(ClientFile);
 i:=IOResult;
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);
 Assign(tt,III.Task[Ind].PathToIndexClientReturn+ClientElement.Kod+'.cvz');
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

AddLog(Log,'Индексация возвратов клиентов c '+III.Task[Ind].StartDateIndexClientReturn+' по '+
III.Task[Ind].StopDateIndexClientReturn+' для объекта '+IntToStr(Ind,CMantissa)+' успешно завершена!');
End;{Procedure}


Function SaveToTovarStatFile(L:PSuperMarketType;Ind:Word;Var k:Byte):Boolean;
Var Es : PClientTovarType;
    Esf : File Of ClientTovarType;
    j,i,c : Byte;
    SkKod : TDateString;
Begin
k:=0;
If Not((L^.DAt.DocSelector in [0,1,2,3,4]) And (L^.Dat.Realiz)) Then
Begin
If L^.Dat.AmountS>0 Then
Begin
 SaveToTovarStatFile:=False;
 Assign(esf,III.Task[Ind].PathToIndexClientTovar+IntToStr(L^.Dat.OperatorSelector,COne)+
                                    L^.Dat.ClientKod+'.tdx');
 i:=IOResult;
 Reset(esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
    Exit;
  End;
New(Es,Init);

 skKod:=IntToStr(Ind,CMantissa);
 RFormatZerro(SkKod,CClientKod);
 Es^.Dat.SkladKod:=SkKod;

k:=0;
For j:=1 To L^.Dat.AmountS Do
Begin
DelSpace(L^.Dat.DocumentElement[j].BazKod);
If L^.Dat.DocumentElement[j].BazKod<>'' Then
 Begin
      Inc(k);
      With Es^.Dat Do
       Begin
        Element[k].Kol:=L^.Dat.DocumentElement[j].Input.Kol;
        Element[k].BazKod:=L^.Dat.DocumentElement[j].BazKod;
       End;
 End;{если не пустой код}

End;

      With Es^.Dat Do
       Begin
        Document:=L^.Dat.Document;
        DateC:=L^.Dat.DateC;;
        TimeC:=L^.Dat.TimeC;
        {SSS:=IntToStr(Ind,CCLientKod);}
        SkladKod:=L^.DAt.SkladKod(*FormKod({Rek^.Dat.Kod}SSS)*);
        DocSelector :=L^.Dat.DocSelector;
        AgentKod:=L^.Dat.AgentKod;
        Amount:=k;
        ClientKod:=L^.Dat.ClientKod;
        Active:=True;
        i:=IOResult;
        Seek(Esf,FileSize(Esf));
        i:=IOResult;
        Write(Esf,Es^.Dat);
        i:=IOResult;
        If i<>0 Then
         Begin
          DiSpose(Es,Done);
          c:=IOResult;
          Close(Esf);
          c:=IOResult;
          AddLog(Log,'Ошибка записи в файл '+III.Task[Ind].PathToIndexClientTovar+
		IntToStr(L^.Dat.OperatorSelector,COne)+L^.Dat.CLientKod+'.his'+
		' для объекта '+IntToStr(Ind,CMantissa)+' Код:'+
          IntToStr(i,3));
          Exit;
         End;
       End;

Dispose(Es,Done);

i:=IOResult;
Close(Esf);
i:=IOResult;
End;
End;
SaveToTovarStatFile:=True;
End;



Function SaveToLastTovarStatFile(L:PSuperMarketType;Ind:Word;Var k:Byte):Boolean;
Var Es : PLastClientTovarType;
    Esf : File Of LastClientTovarType;
    j,i,c : Byte;
    SRZena : AllStr;
    SkKod : TDateString;
Begin
k:=0;
If (L^.DAt.OperatorSelector=0) And
   Not ((L^.DAt.DocSelector in [0,1,2,3,4]) And (L^.Dat.Realiz)) Then
Begin
If L^.Dat.Amount>0 Then
Begin
 SaveToLastTovarStatFile:=False;
 Assign(esf,III.Task[Ind].PathToIndexClientTovar+L^.Dat.ClientKod+'.tlx');
 i:=IOResult;
 Reset(esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
   Exit;
  End;

New(Es,Init);
k:=0;

 skKod:=IntToStr(Ind,CMantissa);
 RFormatZerro(SkKod,CClientKod);
 Es^.Dat.SkladKod:=SkKod;

For j:=1 To L^.Dat.Amount Do
Begin
DelSpace(L^.Dat.marketElement[j].BazKod);

If L^.Dat.marketElement[j].BazKod<>'' Then
 Begin
      Inc(k);

      With Es^.Dat Do
       Begin
        Element[k].Kol:=StrToInt(L^.Dat.marketElement[j].Input.Kol);
        Element[k].Zakupka:=StrToReal(L^.Dat.marketElement[j].Input.Zakupka);
        Case L^.Dat.SkidkaSelector Of
        0,2:MyStr((StrToReal(l^.Dat.MarketElement[j].Input.Zena)/
              (1+StrToReal(l^.Dat.MarketElement[j].Input.Proz)/100)),CZena,CMantissa,SRZena);

        1:MyStr(StrToReal(L^.Dat.marketElement[j].Input.Zena)-
                   StrToReal(L^.Dat.marketElement[j].Input.Skidka),CZena,CMantissa,SRZena);
        Else SRZena:=L^.Dat.marketElement[j].Input.Zena;{CAse}
        End;
        Element[k].Zena:=StrToReal(SRZena);
        Element[k].RZena:=StrToReal(l^.Dat.MarketElement[j].Input.Zena);
        Element[k].BazKod :=L^.Dat.marketElement[j].BazKod;
       End;
 End;{если не пустой код}
End;

      With Es^.Dat Do
       Begin
        Caption:=L^.Dat.Caption;
        Document:=L^.Dat.Document;
        DateC:=DateStringToDate(DAteMask,L^.Dat.DateC);
        DocSelector :=L^.Dat.DocSelector;
        SkidkaSelector :=L^.Dat.SkidkaSelector;
        AgentKod:=L^.Dat.AgentKod;
        Amount:=k;
        ClientKod:=L^.Dat.ClientKod;
        Active:=True;
        i:=IOResult;
        Seek(Esf,FileSize(Esf));
        i:=IOResult;
        Write(Esf,Es^.Dat);
        i:=IOResult;
        If i<>0 Then
         Begin
          DiSpose(Es,Done);
          c:=IOResult;
          Close(Esf);
          c:=IOResult;
          AddLog(Log,'Ошибка записи в файл '+III.Task[Ind].PathToIndexClientTovar+L^.Dat.ClientKod+'.tlx'+
		' для объекта '+IntToStr(Ind,CMantissa)+' Код:'+
          IntToStr(i,3));
          Exit;
         End;
       End;

Dispose(Es,Done);

i:=IOResult;
Close(Esf);
i:=IOResult;
End;
End;
SaveToLastTovarStatFile:=True;
End;




Procedure MAkeClientDocumentIndex(Ind:Word);
Var tt : File Of ClientTovarType;
    k : Byte;
    f : MarketFileType;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    Start,Stop : LongInt;
    Cur : LongInt;
    Curs : TDAteString;
    E : PSuperMarketType;
Begin
AddLog(Log,'Уничтожаю старые индексы по документообороту клиентов для объекта '+IntToStr(Ind,CMantissa)+'...');

Assign(ClientFile,III.Task[Ind].PathToClient+'client.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
  AddLog(Log,'Ошибка открытия базы клиентов '+III.Task[Ind].PathToClient+'client.db для объекта '+IntToStr(Ind,CMantissa)+
  ' Код:'+
  IntToStr(i,3));
  Exit;
 End;

{цикл уничтожения ранее существовавших индексов}
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);
 If ClientElement.Employ Then
 Begin
 Assign(tt,III.Task[Ind].PathToIndexClientDocument+'0'+ClientElement.Kod+'.tdx');
 i:=IOResult;
 Rewrite(tt);
 i:=IOResult;
 If i<>0 Then
  AddLog(Log,'Ошибка создания файла '+III.Task[Ind].PathToIndexClientDocument+'0'+ClientElement.Kod+'.tdx'+'Код:'+
  IntToStr(i,3))
 Else
 Close(tt);
 i:=IOResult;
 End;
End;
 i:=IOResult;
Close(ClientFile);
 i:=IOResult;

Assign(ClientFile,III.Task[Ind].PathToClient+'sklad.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
  AddLog(Log,'Ошибка открытия базы клиентов '+III.Task[Ind].PathToClient+'sklad.db для объекта '+IntToStr(Ind,CMantissa)+
  ' Код:'+
  IntToStr(i,3));
  Exit;
 End;

{цикл уничтожения ранее существовавших индексов}
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);
 If ClientElement.Employ Then
 Begin
 Assign(tt,III.Task[Ind].PathToIndexClientDocument+'1'+ClientElement.Kod+'.tdx');
 i:=IOResult;
 Rewrite(tt);
 i:=IOResult;
 If i<>0 Then
  AddLog(Log,'Ошибка создания файла '+III.Task[Ind].PathToIndexClientDocument+'1'+ClientElement.Kod+'.tdx'+'Код:'+
  IntToStr(i,3))
 Else
 Close(tt);
 i:=IOResult;
 End;
End;
 i:=IOResult;
Close(ClientFile);
 i:=IOResult;

Assign(ClientFile,III.Task[Ind].PathToClient+'barter.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
  AddLog(Log,'Ошибка открытия базы клиентов '+III.Task[Ind].PathToClient+'barter.db для объекта '+IntToStr(Ind,CMantissa)+
  ' Код:'+
  IntToStr(i,3));
  Exit;
 End;

{цикл уничтожения ранее существовавших индексов}
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);
 If ClientElement.Employ Then
 Begin
 Assign(tt,III.Task[Ind].PathToIndexClientDocument+'2'+ClientElement.Kod+'.tdx');
 i:=IOResult;
 Rewrite(tt);
 i:=IOResult;
 If i<>0 Then
  AddLog(Log,'Ошибка создания файла '+III.Task[Ind].PathToIndexClientDocument+'2'+ClientElement.Kod+'.tdx'+'Код:'+
  IntToStr(i,3))
 Else
 Close(tt);
 i:=IOResult;
 End;
End;
 i:=IOResult;
Close(ClientFile);
 i:=IOResult;



Start:=DateStringToDAte(DAteMask,FDate)-III.Task[Ind].DeltaDateClientDocument;
Stop:=DateStringToDAte(DAteMask,FDate);


AddLog(Log,'Переиндексирую товарооборот клиентов c '+
DateToDateString(DateMask,DateStringToDAte(DAteMask,FDate)-III.Task[Ind].DeltaDateClientDocument)
+' по '+
FDate+' для объекта '+IntToStr(Ind,CMantissa));

New(E,Init);

For Cur := Start To Stop Do
Begin
Curs:=DateToDateString(DateMask,Cur);
Write(DayString[DayOfWeek(Cur)]+' '+Curs);
Assign (f,III.Task[Ind].PathToMarket+Curs+'.mrk');
i:=IOResult;
Reset(f);
i:=IOResult;
If I =0 Then
Begin
 While Not(Eof(f)) Do
  Begin
   ReadMarket(f,E);
   If StrToInt(E^.Dat.SkladKod)=Ind Then
   If (E^.Dat.Active) Then
   Begin
     SaveToTovarStatFile(E,Ind,k);
   End;
  End;
 i:=IOResult;
 Close(f);
 i:=IOResult;
 Write('-Ok');
End{}
Else Write('- нет данных');
Writeln;
End;{For}
Dispose(E,Done);



AddLog(Log,'Оптимизирую индексы по документообороту клиентов c '+
DateToDateString(DateMask,DateStringToDAte(DAteMask,FDate)-III.Task[Ind].DeltaDateClientDocument)
+' по '+
FDate+' для объекта '+IntToStr(Ind,CMantissa));

Assign(ClientFile,III.Task[Ind].PathToClient+'client.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);
 Assign(tt,III.Task[Ind].PathToIndexClientDocument+'0'+ClientElement.Kod+'.tdx');
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

Assign(ClientFile,III.Task[Ind].PathToClient+'sklad.db');
i:=IOResult;
Reset(ClientFile);
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);
 Assign(tt,III.Task[Ind].PathToIndexClientDocument+'1'+ClientElement.Kod+'.tdx');
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
Assign(ClientFile,III.Task[Ind].PathToClient+'barter.db');
i:=IOResult;
Reset(ClientFile);
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);
 Assign(tt,III.Task[Ind].PathToIndexClientDocument+'2'+ClientElement.Kod+'.tdx');
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

AddLog(Log,'Индексация документооборота клиентов c '+
DateToDateString(DateMask,DateStringToDAte(DAteMask,FDate)-III.Task[Ind].DeltaDateClientDocument)
+' по '+
FDate+' для объекта '+IntToStr(Ind,CMantissa)+' успешно завершена!');


End;{Procedure}



Procedure MAkeClientTovarIndex(Ind:Word);
Var tt : File Of LastClientTovarType;
    k : Byte;
    f : MarketFileType;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    Start,Stop : LongInt;
    Cur : LongInt;
    Curs : TDAteString;
    E : PSuperMarketType;


Begin
AddLog(Log,'Уничтожаю старые индексы по товарообороту для объекта '+IntToStr(Ind,CMantissa)+'...');
Assign(ClientFile,III.Task[Ind].PathToClient+'client.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
  AddLog(Log,'Ошибка открытия базы клиентов '+III.Task[Ind].PathToClient+'client.db для объекта '+IntToStr(Ind,CMantissa)+
  ' Код:'+
  IntToStr(i,3));
  Exit;
 End;
{цикл уничтожения ранее существовавших индексов}
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);
 Assign(tt,III.Task[Ind].PathToIndexClientTovar+ClientElement.Kod+'.tlx');
 i:=IOResult;
 Rewrite(tt);
 i:=IOResult;
 If i<>0 Then
  AddLog(Log,'Ошибка создания файла '+III.Task[Ind].PathToIndexClientTovar+ClientElement.Kod+'.tlx Код:'+
  IntToStr(i,3))
 Else
 Close(tt);
 i:=IOResult;
End;
Close(ClientFile);
 i:=IOResult;

Start:=DateStringToDAte(DAteMask,FDate)-III.Task[Ind].DeltaDateClientTovar;
Stop:=DateStringToDAte(DAteMask,FDate);

New(E,Init);

AddLog(Log,'Переиндексирую товарооборот клиентов c '+
DateToDateString(DateMask,DateStringToDAte(DAteMask,FDate)-III.Task[Ind].DeltaDateClientTovar)
+' по '+
FDate+' для объекта '+IntToStr(Ind,CMantissa));

For Cur := Start To Stop Do
Begin
Curs:=DateToDateString(DateMask,Cur);
Write(DayString[DayOfWeek(Cur)]+' '+Curs);
Assign (f,III.Task[Ind].PathToMarket+Curs+'.mrk');
i:=IOResult;
Reset(f);
i:=IOResult;
If I =0 Then
Begin
 While Not(Eof(f)) Do
  Begin
   ReadMarket(f,E);
   If StrToInt(E^.Dat.SkladKod)=Ind Then
   If (E^.Dat.OperatorSelector=0) And (E^.Dat.Active) Then
   Begin
     SaveToLastTovarStatFile(E,Ind,k);
   End;
  End;
 i:=IOResult;
 Close(f);
 i:=IOResult;
 Write('-Ok');
End{}
Else Write('- нет данных');

Writeln;
End;{For}
Dispose(E,Done);

AddLog(Log,'Оптимизирую индексы по товарообороту клиентов c '+
DateToDateString(DateMask,DateStringToDAte(DAteMask,FDate)-III.Task[Ind].DeltaDateClientTovar)
+' по '+
FDate+' для объекта '+IntToStr(Ind,CMantissa));
 i:=IOResult;
Reset(ClientFile);
 i:=IOResult;
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);
 Assign(tt,III.Task[Ind].PathToIndexClientTovar+ClientElement.Kod+'.tlx');
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

AddLog(Log,'Индексация товарооборота клиентов c '+
DateToDateString(DateMask,DateStringToDAte(DAteMask,FDate)-III.Task[Ind].DeltaDateClientTovar)
+' по '+
FDate+' для объекта '+IntToStr(Ind,CMantissa)+' успешно завершена!');
End;{Procedure}





{индекс по оплатам консигнации}
Procedure SaveToClientOplataFile(Cl:ClientOplataRealizasiaType;Ind:Word);
Var f : File Of ClientOplataRealizasiaType;
    i : Word;
Begin
 Assign(f,III.Task[Ind].PathToIndexClientOplata+Cl.ClientKod+'.cpl');
 i:=IOResult;
 Reset(f);
 i:=IOResult;
 If I<>0 Then
  Begin
   Exit;
  End;
 i:=IOResult;
 Seek(f,FileSize(f));
 i:=IOResult;
 Write(f,Cl);
 i:=IOResult;
 System.Close(f);
 i:=IOResult;
End;



Procedure CalcSrokAndDelta(Var CC:ClientOplataRealizasiaType;Ind:Word);
Var GlobalEr:PrealizasiaType;
    SClientKOd : ArtikulStr;
    RealFile : File Of RealizasiaType;
    s1,s : AllStr;
    L : Boolean;
    i : LongInt;
Begin
SClientKod:=Cc.ClientKod;
Assign(RealFile,III.Task[Ind].PathToDolg+Cc.ClientKod+'.dlg');
i:=IOResult;
Reset(RealFile);
i:=IOResult;
If i<>0 Then
 Begin
  AddLog(Log,'Ошибка открытия  '+III.Task[Ind].PathToDolg+Cc.ClientKod+'.dlg'+
  +' для объекта '+IntToStr(Ind,CMantissa)+' Код:'+IntToStr(i,3));
  Exit;
 End;

New(GlobalEr,Init);
l:=False;
s1:=CC.Document;
DelSpace(s1);
s:=DateToDateString(DateMask,CC.DateDoc);
DelSpace(s);
DelZerro(s1);

While Not(Eof(RealFile)) And(Not(l))Do
 Begin
  Read(RealFile,GlobalEr^.Dat);
  Delspace(GlobalEr^.DAt.MArket.Document);
  DelZerro(GlobalEr^.Dat.Market.Document);
  If (GlobalEr^.DAt.MArket.Document=s1) And
     (DateToDateString(DateMask,GlobalEr^.DAt.MArket.DateC)=s) Then l:=True;
 End;
i:=IOResult;
Close(RealFile);
i:=IOResult;
CC.Delta[0] :=#0;{срок опоздания}

If L Then
Begin
If GlobalEr^.DAt.Market.Srok<CC.DateC Then
    Begin
     s1[0]:=#0;
     i:= CC.DateC-GlobalEr^.DAt.Market.Srok;
     Str(i:4,s1);
     DelSpace(s1);
    End
    Else
     Begin
      s1[0]:=#0;
      i:= CC.DateC-GlobalEr^.DAt.Market.Srok;
      Str(i:4,s1);
     End;
    CC.Delta :=S1;{срок опоздания}
    If GlobalEr^.DAt.Market.Srok<cc.datec Then
    CC.Srok :=cc.datec-StrToInt(s1){срок оплаты}
    Else
    CC.Srok :=GlobalEr^.DAt.Market.Srok{срок оплаты};
End;
Dispose(GlobalEr,Done);
End;


Procedure MAkeClientOplataIndex(Ind:Word);
Var tt : File Of ClientOplataRealizasiaType;
    f1 : OplataRealizasiaFileType;
    f2 : File Of ClientOplataRealizasiaType;
    Oplata : OplataRealizasiaType;
    COplata : ClientOplataRealizasiaType;
    Regim : Word;
    R : TRect;
    S : String;
    SSrok,SDate,STime,SDateReturn,SSumma,SSkidka : AllStr;
    SDelta,SReturn : ArtikulStr;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    Start,Stop : LongInt;
    Cur : LongInt;
    Curs : TDAteString;
Begin
Regim:=0;
AddLog(Log,'Уничтожаю старые индексы по по оплатам клиентов для объекта '+IntToStr(Ind,CMantissa)+'...');

Assign(ClientFile,III.Task[Ind].PathToClient+'client.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
  AddLog(Log,'Ошибка открытия базы клиентов '+III.Task[Ind].PathToClient+'client.db для объекта '+IntToStr(Ind,CMantissa)+
  ' Код:'+
  IntToStr(i,3));
  Exit;
 End;

{цикл уничтожения ранее существовавших индексов}
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);

 Assign(tt,III.Task[Ind].PathToIndexClientOplata+ClientElement.Kod+'.cpl');
 i:=IOResult;
 Rewrite(tt);
 i:=IOResult;
 If i<>0 Then
  AddLog(Log,'Ошибка создания файла '+III.Task[Ind].PathToIndexClientOplata+ClientElement.Kod+'.cpl Код:'+
  IntToStr(i,3))
  Else
 Close(tt);
 i:=IOResult;
End;
i:=IOResult;
Close(ClientFile);
i:=IOResult;

Start:=DateStringToDAte(DAteMask,III.Task[Ind].StartDateIndexClientOplata);
Stop:=DateStringToDAte(DAteMask,III.Task[Ind].StopDateIndexClientOplata);

AddLog(Log,'Переиндексирую оплаты клиентов c '+III.Task[Ind].StartDateIndexClientOplata+' по '+
III.Task[Ind].StopDateIndexClientOplata+' для объекта '+IntToStr(Ind,CMantissa));
i:=IOResult;

For Cur := Start To Stop Do
Begin
Curs:=DateToDateString(DateMask,Cur);
Write(DayString[DayOfWeek(Cur)]+' '+Curs);
i:=IOResult;
Assign (f1,III.Task[Ind].PathToOplata+Curs+'.opl');
i:=IOResult;
Reset(f1);
i:=IOResult;
If I =0 Then
Begin
 While Not(Eof(f1)) Do
  Begin
   ReadOplata(f1,Oplata);
   i:=IOResult;
   If StrToInt(Oplata.SkladKod)=Ind Then{если клиентский возврат}
   Begin
   With COplata Do
    Begin
     COplata.SkladKod :=Oplata.SkladKod;
     ClientKod:=Oplata.ClientKod;
     Document :=Oplata.Document;
     Document :=IntToStr(StrToInt(Document),CDocNumer);
     DateDoc  :=DateStringToDate(DateMask,Oplata.DateDoc);
     DateC    :=DateStringToDate(DateMask,Oplata.DateC);
     TimeC    :=TimeStringToTime('hh:mm:ss',Oplata.TimeC);
     SummaZ   :=StrToReal(Oplata.SummaZ);
     Skidka   :=StrToReal(Oplata.Skidka);
      Vozwrat :=Oplata.Vozwrat;
DocNumerReturn:=Oplata.DocNumerReturn;
DocDateReturn :=DateStringToDate(DateMask,Oplata.DocDateReturn);
     Caption  :=Oplata.Caption;
     Rashet   :=Oplata.Rashet;
     Bn       :=Oplata.Bn;
    End;{With}
    End;
     CalcSrokAndDelta (COplata,Ind);
     i:=IOResult;
     SaveToClientOplataFile(COplata,Ind);
     i:=IOResult;
  End;
 i:=IOResult;
 Close(f1);
 i:=IOResult;
 Write('-Ok');
End
Else Write('- нет данных');

Writeln;
End;{For}


AddLog(Log,'Оптимизирую индексы по оплатам клиентов c '+III.Task[Ind].StartDateIndexClientOplata+' по '+
III.Task[Ind].StopDateIndexClientOplata+' для объекта '+IntToStr(Ind,CMantissa));
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
While Not(eof(ClientFile)) Do
Begin
 ReadClient(ClientFile,ClientElement);
 Assign(tt,III.Task[Ind].PathToIndexClientOplata+ClientElement.Kod+'.cpl');
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

AddLog(Log,'Индексация оплат клиентов c '+III.Task[Ind].StartDateIndexClientOplata+' по '+
III.Task[Ind].StopDateIndexClientOplata+' для объекта '+IntToStr(Ind,CMantissa)+' успешно завершена!');


End;{Procedure}


Procedure CalcDolgNewWithOut(ind:Word;SKod:ArtikulStr;Var s{долг},sk{максимальная просрочка}:ALLStr);
Var i : Byte;
    R,Rsk : Real;
    Count : Word;
    BakFileMode,c : Word;
    RealFile : File;
    E : PBufRealizasiaType;
    l : LongInt;
Begin
r:=0;
Rsk:=0;
sk:='0';
s:='0.00';
Assign (RealFile,III.Task[Ind].PathToDolg+sKod+'.dlg');
i:=Ioresult;
Reset(Realfile,SizeOf(RealizasiaType));
i:=IOresult;
If (i<>0) Then Exit;
While Not(Eof(RealFile)) Do
 Begin
  New(E,Init);
  BlockRead(RealFile,E^.Point,BufferDLG,Count);
For c:=1 To Count Do
Begin
  If (E^.Point.Dat[c].Market.Active) Then
  If Not(E^.Point.Dat[c].FULL) Then
   Begin
    r:=r+E^.Point.Dat[c].Dolg;
    l:=E^.Point.Dat[c].Market.Srok;
    If (ToDay-l)>StrToInt(sk) Then
     Begin
       sk:=IntToStr(Today-l,CKol);
     End;
   End;
End;{For}
 Dispose(E,Done);
 End;
i:=Ioresult;
Close(RealFile);
i:=Ioresult;
MyStr(R,CIZena,CMantissa,s);
End;




Procedure LoadClient;
VAr
 ClientFile : ClientFileType;
 ClientElement : ClientType;
 Cur,Start,Stop : LongInt;
 s,ws : String;
 i : Word;
 sKod,SDolg,SDelta : AllStr;
Begin
 R.Assign(0,0,0,0);
 ClientDolgList := New(PBox, Init(R, 1, Nil));
 ClientDolgList^.NewList(New(PTextCollection, Init(0,1)));
Assign(ClientFile,III.PathToClientLizAndUnLock+'client.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
  AddLog(Log,'Ошибка открытия базы клиентов '+III.PathToClientLizAndUnLock+'client.db Код:'+
  IntToStr(i,3));
  Exit;
 End;

AddLog(Log,'Старт загрузки справочника клиентов и расчета долгов');

While Not(Eof(ClientFile)) Do
Begin
 Read(ClientFile,ClientELement);
 If CLientElement.Employ Then
 Begin
 s[0]:=#0;
 Format(ClientElement.Name,CClient);
 s:=ClientElement.Name+'│'+ClientELement.Kod+'│';

  For Cur:=1 To CMaxSklads Do
  Begin
   If III.Task[cur].CalcDolg=1 Then
      Begin
       SKod:=ClientELement.Kod;
       SDolg[0]:=#0;
       SDelta[0]:=#0;
       CalcDolgNewWithOut(Cur,SKod,SDolg,SDelta);
       MyStr(StrToReal(SDolg),12,2,SDolg);
       SDelta:=IntToStr(StrToInt(SDelta),CKol);
       RFormat(SDelta,CKol);
	  s:=s+SDolg+'│'+SDelta+'│';

       If ClientElement.Status in [0,1] Then
       If III.LockStatusWithDelta=1 Then
       If StrToInt(SDelta)>StrToInt(ClientElement.MaxDelta) Then
        BEgin
         I:=IOResult;
         ClientElement.Status:=2;{сб}
         ClientElement.RCD:=True;
         ClientElement.Auto:='АВТОСМЕНА СТАТУСА Склад:'+InTToStr(cur,CKol)+'('+SDelta+'>='+
	    IntToStr(StrToInt(ClientElement.MaxDelta),CKol)+')'+
	    ' '+Times+' '+FDAte;
         Seek(ClientFile,FilePos(ClientFile)-1);
         Write(ClientFile,ClientElement);
         I:=IOResult;
         AddLog(Log,'АВТОСМЕНА СТАТУСА ДЛЯ КЛИЕНТА '+ClientElement.Name+' ['+ClientELement.Kod+']'+
	    ' Склад:'+InTToStr(cur,CKol)+'('+SDelta+'>='+
	    IntToStr(StrToInt(ClientElement.MaxDelta),CKol)+')');
         I:=IOResult;
        End;

      End;
  End;
  ClientDolgList^.List^.Insert(NewStr(s));
  ClientDolgList^.SetRange(ClientDolgList^.List^.Count);
 End;
End;
i:=IOResult;
Close(ClientFile);
i:=IOResult;
AddLog(Log,'Завершение загрузки справочника клиентов и расчета долгов');
End;



Procedure LoadAgent;
VAr
 ClientFile : ClientFileType;
 ClientElement : ClientType;
 Cur,Start,Stop : LongInt;
 s,ws : String;
 i : Word;
Begin
 R.Assign(0,0,0,0);
 AgentDolgList := New(PBox, Init(R, 1, Nil));
 AgentDolgList^.NewList(New(PTextCollection, Init(0,1)));

 Assign(ClientFile,III.PathToClientLizAndUnLock+'agent.db');
i:=IOResult;
Reset(ClientFile);
i:=IOResult;
If i<>0 then
 Begin
  AddLog(Log,'Ошибка открытия базы агентов '+III.PathToClientLizAndUnLock+'agent.db Код:'+
  IntToStr(i,3));
  Exit;
 End;

AddLog(Log,'Старт загрузки справочника агентов');

While Not(Eof(ClientFile)) Do
Begin
 Read(ClientFile,ClientELement);
 If CLientElement.Employ Then
 Begin
 s[0]:=#0;
 MyStr(StrToReal(ClientELement.Limit),CIZena-3,CMAntissa,ws);
 s:=ClientELement.Kod+'│'+ws;
 ws:=ClientElement.NAme;
 Format(ws,CClient);
 s:=ws+'│'+s+'│';
  For Cur:=1 To CMaxSklads Do  s:=s+'        0.00│';
  AgentDolgList^.List^.Insert(NewStr(s));
  AgentDolgList^.SetRange(AgentDolgList^.List^.Count);
 End;
End;
i:=IOResult;
Close(ClientFile);
i:=IOResult;
AddLog(Log,'Завершение загрузки справочника агентов');
End;




Procedure CalcDolgClientAndAgent(Ind:Word);
Begin
End;




Procedure LoadDBfromPrice(Var P:PBox);
Var SklFile : File;
    Skl : PBufSkladType;
    k,j,c,Count : Word;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    All : LongInt;
    SArt: ArtikulStr;
    BBB,BBB2 : PBazType;
    s : String;
    SSertif,SPost,SMarka,SFirma,SDate : AllStr;
    SName : TMyString;

Begin
c:=IOResult;
Assign(RazdelFile,III.Task[III.PriceSklad].PathToRazdel+'Razdel.db');
Reset(RazdelFile);
c:=IOResult;

If c<>0 Then
 Begin
  AddLog(Log,'Ошибка доступа к файлу разделов '+III.Task[III.PriceSklad].PathToRazdel+' для объекта '+IntToStr(III.PriceSklad,
  CMantissa)+' Код:'+
  IntToStr(c,3));
  Exit;
 End;

Writeln('Загрузка товарных остатков...');

While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  If (RazdelElement.EnableDoc=0) Then
  Begin
   Assign(SklFile,III.Task[III.PriceSklad].PathToSklad+RazdelElement.Kod+'.db');
   c:=IOResult;
   Reset(SklFile,SizeOf(SkladType));
   c:=IOResult;
   Write('Раздел '+RazdelElement.Kod+'-');

If c<>0 Then
 Begin
  Close(RazdelFile);
  AddLog(Log,'Ошибка доступа к файлу '+III.Task[III.PriceSklad].PathToSklad+RazdelElement.Kod+'.db'+' для объекта '+
  IntToStr(III.PriceSklad,CMantissa)+' Код:'+
  IntToStr(c,3));
  Exit;
 End;


   While Not(Eof(sklFile)) Do
    Begin
     New(Skl,Init);
     Count:=0;
     ReadBufSklad(SklFile,Skl,Count);

    For j:=1 To Count Do
    Begin
  If Skl^.Point.Dat[j].Employ Then
  Begin
     With Skl^.Point.Dat[j].Input Do
     Begin
      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(Division[k]):CKol,Division[k]);
           DelSpace(Division[k]);
           All:=All+StrToInt(Division[k]);
        End;
     Str(All:CKol,Skl^.Point.Dat[j].Input.Kol);
     DelSpace(Skl^.Point.Dat[j].Input.Kol);

      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(DivisionR[k]):CKol,DivisionR[k]);
           DelSpace(DivisionR[k]);
           All:=All+StrToInt(DivisionR[k]);
        End;
     Str(All:CKol,Skl^.Point.Dat[j].Input.KolR);
     DelSpace(Skl^.Point.Dat[j].Input.KolR);

     Str(StrToInt(Skl^.Point.Dat[j].Input.Kol)-StrToInt(Skl^.Point.Dat[j].Input.KolR):CKOl,
	Skl^.Point.Dat[j].Input.Kol);
     DelSpace(Skl^.Point.Dat[j].Input.Kol);


     MyStr(StrToReal(Skl^.Point.Dat[j].Input.R_Zena),CZena,CMantissa,
	Skl^.Point.Dat[j].Input.R_Zena);

     MyStr(StrToReal(Skl^.Point.Dat[j].Input.GRZena),CZena,CMantissa,
	Skl^.Point.Dat[j].Input.GRZena);

     If StrToInt(Skl^.Point.Dat[j].Input.Kol)>0 Then
     Begin
      sSertif[0]:=#0;
      sPost[0]:=#0;
      sMarka[0]:=#0;
      sDate[0]:=#0;
      sPost[0]:=#0;
      sFirma[0]:=#0;

      New(BBB,Init);
      New(BBB2,Init);

      SArt:=Skl^.Point.Dat[j].BazKod;
      GetBazElement(III.PriceSklad,SArt,BBB^.Dat);
      If (BBB^.Dat.Market=1) Then
      Begin
      RFormat(Skl^.Point.Dat[j].Input.Kol,CKol);
      {sSertif}

      SArt:=Skl^.Point.Dat[j].Input.NSertif;
      GetBazElement(III.PriceSklad,SArt,BBB2^.Dat);
      DelSpaceRight(BBB2^.Dat.Name);
      sSertif:=BBB2^.Dat.Name;
      Format(sSertif,CNAme);
      {sDate}
      sDate:=Skl^.Point.Dat[j].Input.Godnost;
      Format(sDate,CDate);
      {sPost}
      sPost:=GetPostField(BBB^.Dat.PostKod);

      Format(sPost,CPost);
      {sFirma}
      sFirma:=GetFirmaPostField(BBB^.Dat.FirmaPostKod);
      Format(sFirma,CFirmaPost);
      {sMarka}
      sMarka:=GetMarkaField(Skl^.Point.Dat[j].Input.Marka);
      Format(sMarka,CPost);

      DelSpaceRight(BBB^.Dat.Name);
      s:=BBB^.Dat.Name+' '+BBB^.Dat.Name2;
      Format(s,CName+1+CNAme);
      s:=s+'│'+Skl^.Point.Dat[j].BazKod+'│'+Skl^.Point.Dat[j].Input.Kol+'│'+
	 Skl^.Point.Dat[j].Input.R_Zena+'│'+
      Skl^.Point.Dat[j].Input.GRZena+'│'+
	 SPost+'│'+SFirma+'│'+SMarka+'│'+SDate+'│'+SSertif;
      {добавляем элемент в список}
      P^.List^.Insert(NewStr(s));
      P^.SetRange(P^.List^.Count);
      End;

      Dispose(BBB,Done);
      Dispose(BBB2,Done);

     End;
    End;{With}
  End;{If}
     End;{For}
   Dispose(Skl,Done);
     End;{While}

  c:=IOResult;
   Close(SklFile);
  c:=IOResult;
   {Dispose(Index,Done);}
   WriteLn('Ok');
   End;
 End;
  c:=IOResult;
  Close(RazdelFile);
  c:=IOResult;
End;{LoadDBFromPrice}



Procedure GeneratePriceList(Var ClientPriceList,PriceList:PBox);
var j,k,c : word;
    SProz,SClientKod : AllStr;
    f : File Of PriceType;
    Prc : PPriceType;
    s : String;
    SPath,s1 : String;
Begin
{бежим по клиентам}
If (ClientPriceList^.List<>Nil)And(ClientPriceList^.List^.Count>=1) Then
Begin
 For c:=0 To ClientPriceList^.List^.Count-1 Do
  Begin
   SClientKod:=Copy(ClientPriceList^.GetText(c,ClientPriceList^.List^.Count),1+1,CClientKod);
   SProz:=Copy(ClientPriceList^.GetText(c,ClientPriceList^.List^.Count),1+1+CClientKod+1,CZena);
   SPath:=Copy(ClientPriceList^.GetText(c,ClientPriceList^.List^.Count),1+1+CClientKod+1+CZena+1,CSertif);
   DelSpace(SPath);

   If SPath[Length(SPath)]<>'\' Then SPath:=SPath+'\';

   MkDir({III.PathToClientPrice+SClientKod}SPath+SClientKod);
   k:=IOResult;
   MkDir({III.PathToClientPrice+SClientKod}SPath+SClientKod+'\Out');
   k:=IOResult;
   MkDir({III.PathToClientPrice+SClientKod}SPath+SClientKod+'\In');
   k:=IOResult;
   Write('Формирование прайс-листа для клиента '+SClientKod+'-');
   Assign(f,{III.PathToClientPrice}SPath+SClientKod+'\Out\price.db');
   Rewrite(f);
   k:=IOResult;
   If k<>0 Then
    Begin
     Writeln('Ошибка создания файла прайса '+{III.PathToClientPrice}SPath++SClientKod+'\Out\price.db Код:'+
	IntToStr(k,CKol));
     AddLog(Log,'Ошибка создания файла прайса '+{III.PathToClientPrice}SPath++SClientKod+'\Out\price.db Код:'+
	IntToStr(k,CKol));
     Continue;
    End;

   If (PriceList^.List<>Nil)And(PriceList^.List^.Count>=1) Then
    Begin
     For k:=0 To PriceList^.List^.Count-1 Do
      Begin
       s:=PriceList^.GetText(k,ClientPriceList^.List^.Count);

       New(Prc,Init);
       Prc^.Dat.Name:=Copy(s,1,CName+1+CNAme);
       {Writeln(Prc^.Dat.Name);}
       Prc^.Dat.Kod:=Copy(s,1+CName+1+CNAme+1,CArtikul);
       {Writeln(Prc^.Dat.Kod);}
       Prc^.Dat.Kol:=StrToInt(Copy(s,1+CName+1+CNAme+1+CArtikul+1,
	  CKol));
       {Writeln(Prc^.Dat.Kol);}

       Prc^.Dat.Zena:=Copy(s,1+CName+1+CNAme+1+CArtikul+1+
	  CKol+1,CZena);

       MyStr(StrToReal(Prc^.Dat.Zena)*StrToreal(SProz),CZena,CMantissa,Prc^.Dat.Zena);
       {Writeln(Prc^.Dat.Zena);}

       Prc^.Dat.ZenaGR:=Copy(s,1+CName+1+CNAme+1+CArtikul+1+
	  CKol+1+CZena+1,CZena);
       {Writeln(Prc^.Dat.ZenaGR);}
       Prc^.Dat.Post:=Copy(s,1+CName+1+CNAme+1+CArtikul+1+
	  CKol+1+CZena+1+CZena+1,CPost);
       {Writeln(Prc^.Dat.Post);}
       Prc^.Dat.Firma:=Copy(s,1+CName+1+CNAme+1+CArtikul+1+
	  CKol+1+CZena+1+CZena+1+CPost+1,CFirmaPost);
       {Writeln(Prc^.Dat.Marka);}
       Prc^.Dat.Marka:=Copy(s,1+CName+1+CNAme+1+CArtikul+1+
	  CKol+1+CZena+1+CZena+1+CPost+1+CFirmaPost+1,CPost);
       Prc^.Dat.Godnost:=Copy(s,1+CName+1+CNAme+1+CArtikul+1+
	  CKol+1+CZena+1+CZena+1+CPost+1+CFirmaPost+1+CPost+1,CDate);
       {Writeln(Prc^.Dat.Godnost);}

       Prc^.Dat.Sertif:=Copy(s,1+CName+1+CNAme+1+CArtikul+1+
	  CKol+1+CZena+1+CZena+1+CPost+1+CFirmaPost+1+CPost+1+CDate+1,CNAme);

       {Writeln(Prc^.Dat.Sertif);}
       DelSpaceRight(Prc^.Dat.Name);
       DelSpaceRight(Prc^.Dat.Sertif);
       Write(f,Prc^.Dat);
       Dispose(Prc,Done);
      End;
    end;

   k:=IOResult;
   Close(f);
   k:=IOResult;
   Writeln('Ok');

  s1:='rar m -r -m5 -ep -ep1 -ds -inul -y '+
  {III.PathToClientPrice}SPath+SClientKod+'\Out\price.rar'+' '+
  {III.PathToClientPrice}SPath+SClientKod+'\Out\price.db'+' '{'>NUL'};
  DelSpaceRight(s1);
  SWAPVECTORS;

  exec (GetEnv('COMSPEC'),' /c '+S1);
  SWAPVECTORS;
  k:=DosError;

  If FExists({III.PathToClientPrice}SPath+SClientKod+'\Out\price.rar') Then
    AddLog(Log,'Упаковка '+{III.PathToClientPrice}SPath+SClientKod+'\Out\price.db'+' Ok')
  Else
    AddLog(Log,'Ошибка упаковки '+{III.PathToClientPrice}SPath+SClientKod+'\Out\price.db');

   AddLog(Log,'Формирование прайс-листа для клиента '+SClientKod+' завершено');
   {создаем каталог файл прайса}
   {читаем конфигурацию прайса}
  End;{For}
{бежим по товарам и сохраняем соответсвующие прайс листы с пересчетом цен}
End;{If (ClientPriceList^.List<>Nil)And(ClientPriceList^.List^.Count>=1) Then}
End;


Procedure ReIndexClient(Ind:Word);
Var j,c : LongInt;
    ws : String;
    ClientFile : File Of ClientType;
    ClientElement :ClientType;
    ClientIdxFile : File Of KurzClientType;
    ClientKurz :KurzClientType;
Begin
{если не надо индексировать}
If III.Task[Ind].IndexClient<>1 Then Exit;

j:=IoResult;
AddLog(Log,'Индексация базы client.db для объекта '+IntToStr(Ind,CMantissa));

Assign (ClientFile,III.Task[Ind].PathToClient+'client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,III.Task[Ind].PathToClientBaseIDX+'client.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
c:=0;

While Not(Eof(ClientFile)) Do
 Begin
     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  RFormatZerro(ws,CClientKod);
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;

  With ClientElement Do
   Begin
     If Lizo>1 Then Lizo:=0;
   End;


  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.RouteKod:=StrToInt(RouteKod);
  ClientKurz.RegionKod:=StrToInt(RegionKod);
  ClientKurz.Employ:=Employ;
  ClientKurz.Status:=Status;
  ClientKurz.Main:=Main;
  ClientKurz.FantomKod:=StrToInt(FantomKod);
  End;

  Write(ClientIdxFile,ClientKurz);

     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);

  Inc(c);
 End;
j:=IoResult;
System.Close(ClientFile);
j:=IoResult;
System.Close(ClientIdxFile);
j:=IoResult;

j:=IoResult;
AddLog(Log,'Индексация базы client.db для объекта '+IntToStr(Ind,CMantissa)+' завершено');
j:=IoResult;


End;


Procedure CreatPriceFromClient;
Begin
 R.Assign(0,0,0,0);
 ClientPriceList := New(PBox, Init(R, 1, Nil));
 ClientPriceList^.NewList(New(PTextCollection, Init(0,1)));
 PriceList := New(PBox, Init(R, 1, Nil));
 PriceList^.NewList(New(PTextCollection, Init(0,1)));
 LoadClientList(ClientPriceList);
 LoadDBfromPrice(PriceList);

 GeneratePriceList(ClientPriceList,PriceList);


 Dispose(ClientPriceList,Done);
 Dispose(PriceList,Done);
End;



Procedure PrintClient;
VAr j,c : LongInt;
    Txt : Text;
    ws,s : String;

Begin
 Assign(txt,ClearChar(FDate)+'c.csv');
 j:=IoResult;
 Rewrite(txt);
 j:=IoResult;
 If j<>0 Then
  Begin
   AddLog(Log,'Ошибка создания файла отчета по клиентам');
   Exit;
  End;

 WriteLn(txt,DosToWin(DateToDAteString(DateMask,ToDay)+' '+Times));
 Write(txt,DosToWin('Клиент;Код;'));
 s[0]:=#0;
  For c:=1 To CMaxSklads Do
  Begin
   If III.Task[c].CalcDolg=1 Then
      Begin
	  s:=s+'Долг '+III.Task[c].Name+'; Опоздание ;';
      End;
  End;
 WriteLn(txt,DosToWin(s));


 For c:=0 To ClientDolgList^.List^.Count-1 Do
  Begin
   s := ClientDolgList^.GetText(c,ClientDolgList^.List^.Count);
   ws:=Copy(s,1,CCLient);
   s:=Copy(s,CCLient+1,Ord(s[0])-CCLient+1);
   DelSpace(S);
   Del2Space(wS);
   While Pos('│',s)>0 Do s[Pos('│',s)]:=';';
   While Pos('.',s)>0 Do s[Pos('.',s)]:=',';
   Writeln(txt,DosToWin(ws)+s);
  End;
 j:=IoResult;
Close(txt);
 j:=IoResult;
End;

Procedure PrintAgent;
VAr j,c : LongInt;
    Txt : Text;
    ws,s : String;
Begin
 Assign(txt,ClearChar(FDate)+'a.csv');
 j:=IoResult;
 Rewrite(txt);
 j:=IoResult;
 If j<>0 Then
  Begin
   AddLog(Log,'Ошибка создания файла отчета по агентам');
   Exit;
  End;

 For c:=0 To AgentDolgList^.List^.Count-1 Do
  Begin
   s := AgentDolgList^.GetText(c,AgentDolgList^.List^.Count);
   ws:=Copy(s,1,CCLient);
   s:=Copy(s,CCLient+1,Ord(s[0])-CCLient+1);
   DelSpace(S);
   Del2Space(wS);
   While Pos('│',s)>0 Do s[Pos('│',s)]:=';';
   While Pos('.',s)>0 Do s[Pos('.',s)]:=',';
   Writeln(txt,DosToWin(ws)+s);
  End;
 j:=IoResult;
Close(txt);
 j:=IoResult;
End;






(*************    О С Н О В Н А Я    П Р О Г Р А М М А        ***********)
Begin

 If FindParam('/?') Then
  Begin
   ShowHelp;
  End;

 ClearIni;

 j:=1;
 For j:=1 To CMaxSklads Do
  Begin
   If FindParam('/'+KurzSklad[j]{WordToMyHex(j)}) Then ReplicationObject[j]:=1
   Else
   ReplicationObject[j]:=0;
  End;

 {цикл настройки на обрабатываемые задачи}
 For j:=1 To CMaxTasks Do
  Begin
   IndexTasks[j]:=0;
  End;

 If FindParam(StartOborot) Then IndexTasks[1]:=1;{client}
 If FindParam(StartReturn)   Then IndexTasks[2]:=1;{make}
 If FindParam(StartOplata) Then IndexTasks[3]:=1;{barter}
 If FindParam(StartTovar)  Then IndexTasks[4]:=1;{agent}
 If FindParam(StartDocument)  Then IndexTasks[5]:=1;{Sklad}
 If FindParam(StartLockLizensia)  Then IndexTasks[6]:=1;{блокировка по сроку лицензии}
 If FindParam(StartNetUnLock)  Then IndexTasks[7]:=1;{снятие сетевой блокировки}
 If FindParam(StartLockClient)  Then IndexTasks[8]:=1;{блокировка по превышению лимита долга клиентов}
 If FindParam(StartLockAgent)  Then IndexTasks[9]:=1;{блокировка по превышению лимита долга агентов}
 If FindParam(StartKDX)  Then IndexTasks[10]:=1;{блокировка по превышению лимита долга агентов}
 If FindParam(StartPrice)  Then IndexTasks[11]:=1;{формирование прайс-листов для клиентов}
 If FindParam(StartClient)  Then IndexTasks[12]:=1;{индексация базы клиентов}

 {цикл настройки на обрабатываемые задачи}
 Starting := False;
 For j:=1 To CMaxTasks Do
  Begin
   If
   IndexTasks[j]>0 Then Starting:=True;
  End;

 If Not Starting Then
  Begin
   Writeln('Не обнаружено никаких задач!');
   Halt;
  End;


 Assign(Log,ClearChar(FDate)+'.log');
 j:=IoResult;
 Append(Log);
 j:=IoResult;
 If j<>0 Then
  Begin
   {SpecialBeep;}
   Writeln('Ошибка открытия лог-файла');
   Rewrite(Log);
   j:=IoResult;
   If j<>0 Then
    Begin
     {SpecialBeep;}
     Writeln('Ошибка создания лог-файла');
    End;
  End;

 Assign(Ini,'index.ini');
 j:=IoResult;
 Reset(Ini);
 j:=IoResult;
 If j<>0 Then
  Begin
   Writeln('Ошибка открытия ini-файла');
   AddLog(Log,'Ошибка открытия ini-файла');
   AddLog(Log,'Аварийное завершение');
   j:=IoResult;
   Close(Log);
   j:=IoResult;
   Exit;
  End;
 j:=IoResult;
 Close(ini);
 j:=IoResult;
 Res:=0;
 ReadNewIni(INI,Res);
 j:=IoResult;
 Close(ini);
 j:=IoResult;
 If Res=1 Then
  Begin
   Writeln('Ошибка чтения ini-файла');
   j:=IoResult;
   AddLog(Log,'Ошибка чтения ini-файла');
   AddLog(Log,'Аварийное завершение');
   j:=IoResult;
   Close(Log);
   j:=IoResult;
   Exit;
  End;

If (IndexTasks[8]=1) Then LoadClient;
{LoadAgent;}

For j:=1 To CMAxSklads Do
 Begin
  If ReplicationObject[j]=1 Then
  Begin
  If IndexTasks[1]=1 Then MAkeClientIndex(j);
  If IndexTasks[2]=1 Then MAkeClientReturnIndex(j);
  If IndexTasks[3]=1 Then MAkeClientOplataIndex(j);
  If IndexTasks[4]=1 Then MAkeClientTovarIndex(j);
  If IndexTasks[5]=1 Then MAkeClientDocumentIndex(j);
  If IndexTasks[10]=1 Then MakeKDX(j);
  End;
 End;

  If (IndexTasks[6]=1) Or (IndexTasks[7]=1) Then TestLizensiaAndNetLock;


For j:=1 To CMAxSklads Do
 Begin
  If ReplicationObject[j]=1 Then
  Begin
  {If (IndexTasks[8]=1) Then CalcDolgClientAndAgent(j);}

  If (IndexTasks[12]=1) Then ReIndexClient(j);
  End;
 End;


If (IndexTasks[11]=1) Then CreatPriceFromClient;




If (IndexTasks[8]=1) Then
Begin
 AddLog(Log,'Формирование отчета по долгам клиентов');
 PrintClient;
End;

If (IndexTasks[8]=1) Then
Begin
 AddLog(Log,'Уничтожение списка клиентов');
 Dispose(ClientDolgList,Done);
End;
{
 AddLog(Log,'Уничтожение списка агентов');
 Dispose(AgentDolgList,Done);
}

 AddLog(Log,'Завершение автоматического обработчика');
 {конец цикла основной работы}

 I:=IoResult;
 Close(Log);
 I:=IoResult;



End.