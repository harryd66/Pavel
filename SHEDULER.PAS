{переменные для размещения каталога анализируемых баз}
{client.db}
{make.db}
{barter.db}
{agent.db}
{sklad.db}
{eksped.db - ее нужно конвертнуть для введения поля RCD : Boolean;}
{group.db  - ее нужно конвертнуть для введения поля RCD : Boolean;}
{region.db - ее нужно конвертнуть для введения поля RCD : Boolean;}

{
ввести в основной программе из ини файла
переменные префиксы видов почтовых пакетов
A - приходы
B - переоценки
C - client.db
E - make.db
F - barter.db
G - agent.db
H - sklad.db
I - eksped.db
E - group.db
K - region.db
}
{
переменные для размещения каталога экспорта для каждого объекта}


{
1.конвертация необходимых файлов p??,k??,eksped,group,region
2.написание обработчика sheduler.exe
}

Uses Glob,Serv,Servstr,Mail,Utils,
     MsgBox,TpDate,NetCall,Dos,NetDbEng;

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
2.Читаем каталоги из ini - файла sheduler.ini
  сканируемый рабочий каталог
  массив [1..CMaxSklads] Of String[CSertif] - размещение каталогов экспорта
3.Цикл работы
}

Const

 CMaxSklads = 15;
 CMaxTasks = 8;


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


 StartClient='CLIENT';{1}
 StartMAke='MAKE';{2}
 StartBarter='BARTER';{3}
 StartAgent='AGENT';{4}
 StartSklad='SKLAD';{5}
 StartEksped='EKSPED';{6}
 StartGroup='GROUP';{7}
 StartRegion='REGION';{8}





Procedure AddLog(Var Log:Text;s:String);
Var j : Word;
Begin
 j:=IoResult;
 WriteLn(Log,
 TodayString(DateMask)+'('+Times+')'+'"'+DayString[DayOfWeek(ToDay)]+'"'+'│'+
 s);
 Writeln('('+Times+') '+s);
 j:=IoResult;
End;




Var
    ReplicationObject: Array [1..CMaxSklads] Of Byte;{управляется параметрами коммандной строки}
    ScanPAth : String[CSertif];{сканируемый каталог}
    TempPAth : String[CSertif];{временный каталог перед упаковкой}
    ReplicationPath : Array [1..CMaxSklads] Of String;
    ReplicationTasks: Array [1..CMaxTasks] Of Byte;{список задач подлежащих обработке}
    i,j : Word;
    Cl  : PClientType;
    Gr  : PGroupType;
    Rr  : PRegionType;
    Ini : Text;
    Log : Text;
    FileName : String;
    OutSklad,Pref  : ArtikulStr;



Procedure PackMessages(BakPath,NewPath:String);
Var s1 : String;
    Result : Word;
Begin
  s1:='rar a -m5 -ep -ep1 -av- -inul -ds -y -w'+TempPath+' '+
  NewPath+' '+BakPath+' '+'>NUL';
  DelSpaceRight(s1);
  SWAPVECTORS;
  exec (GetEnv('Comspec'),' /C '+S1);
  Result:=DosError;
  SWAPVECTORS;
  If FExists(NewPath) Then
    AddLog(Log,'Упаковка '+NewPath+' Ok')
  Else
    AddLog(Log,'Ощибка упаковки '+NewPath);
End;

Function GetImportFileNameWithPrefix(Pr,Kod:ArtikulStr):AllStr;
Begin
 GetImportFileNameWithPrefix:=Pr+Kod+OutSklad[1]+'.'+OutSklad[2];
End;

Procedure ReplicationClient(FN:String;Pr:ArtikulStr);
Var f : ClientFileType;
    c : Word;
    Cl : PClientType;
    PoS : LongInt;

Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(ClientType),SizeOf(ClientType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(ClientType),SizeOf(ClientType));
 Until DosError=0;
End;





Procedure ImportClient(Pr:ArtikulStr;Cl:ClientType);
Var ExpF : File Of ClientType;
    c : Word;
    Polush : ArtikulStr;
    j : Word;
Begin
 For j:=1 To CMaxSklads Do
  Begin
   If ReplicationObject[j]=1 Then
    Begin
     Polush:=IntToStr(j,CMantissa);
     RFormatZerro(Polush,CMantissa);
     Assign(ExpF,TempPath{ReplicationPath[j]}+GetImportFileNameWithPrefix(Pr,Cl.Kod)+
     Polush);
     c:=IOResult;
     Rewrite(ExpF);
     c:=IOResult;
     If c<>0 Then
      Begin
       AddLog(Log,'Ошибка создания '+{ReplicationPath[j]}TempPath+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush+
	  ' Код:'+IntToSTr(c,CKol));
       Continue;{возвращаемся к For}
      End;
     Cl.Locked:=False;
     Cl.RCD:=False;
     Write(ExpF,Cl);
     c:=IOResult;
     Close(ExpF);
     c:=IOResult;
     PackMessages(TempPath+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush)
    End;{проверка нужно ли обрабатывать для данного объекта}
  End;{For}
End;{Procedure}


Begin
Assign(f,FN);
c:=IoResult;
Reset(f);
c:=IoResult;
if c<>0 Then
 Begin
  AddLog(Log,'Ошибка открытия '+FN+' Код:'+IntToStr(c,CKol)+' задача отложена!');
  Exit;
 End;
New(Cl,Init);
While Not(Eof(f)) Do
 Begin
  ReadClient(f,Cl^.Dat);
  If Not(Cl^.DAt.Locked) Then
   {If Cl^.Dat.Employ Then}
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.Dat.Name);
       If (System.Pos('BARTER',FN)>0) Or (System.Pos('MAKE',FN)>0) Then
        Begin
         Cl^.Dat.Name:='СМ.РЕЗЕРВНЫЙ СКЛАД';
         Cl^.Dat.FullName:='СМ.РЕЗЕРВНЫЙ СКЛАД';
         Cl^.Dat.Adress:='СМ.РЕЗЕРВНЫЙ СКЛАД';
         Cl^.Dat.AdressF:='СМ.РЕЗЕРВНЫЙ СКЛАД';
         Cl^.Dat.Telefon:='';
         Cl^.Dat.Gorod:='';
         Cl^.Dat.INN:='';
         Cl^.Dat.Enviropment:='';
         Cl^.Dat.Dogovor:='';
        End;
       ImportClient(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
End;


Procedure ReplicationExtended(FN:String;Pr:ArtikulStr);
Var f : RegionFileType;
    c : Word;
    Cl : PRegionType;
    PoS : LongInt;

Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(RegionType),SizeOf(RegionType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(RegionType),SizeOf(RegionType));
 Until DosError=0;
End;





Procedure ImportRegion(Pr:ArtikulStr;Cl:RegionType);
Var ExpF : File Of RegionType;
    c : Word;
    Polush : ArtikulStr;
    j : Word;
Begin
 For j:=1 To CMaxSklads Do
  Begin
   If ReplicationObject[j]=1 Then
    Begin
     Polush:=IntToStr(j,CMantissa);
     RFormatZerro(Polush,CMantissa);
     Assign(ExpF,TempPath{ReplicationPath[j]}+GetImportFileNameWithPrefix(Pr,Cl.Kod)+
     Polush);
     c:=IOResult;
     Rewrite(ExpF);
     c:=IOResult;
     If c<>0 Then
      Begin
       AddLog(Log,'Ошибка создания '+{ReplicationPath[j]}TempPath+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush+
	  ' Код:'+IntToSTr(c,CKol));
       Continue;{возвращаемся к For}
      End;
     Cl.Locked:=False;
     Cl.RCD:=False;
     Write(ExpF,Cl);
     c:=IOResult;
     Close(ExpF);
     c:=IOResult;
     PackMessages(TempPath+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush)
    End;{проверка нужно ли обрабатывать для данного объекта}
  End;{For}
End;{Procedure}


Begin
Assign(f,FN);
c:=IoResult;
Reset(f);
c:=IoResult;
if c<>0 Then
 Begin
  AddLog(Log,'Ошибка открытия '+FN+' Код:'+IntToStr(c,CKol)+' задача отложена!');
  Exit;
 End;
New(Cl,Init);
While Not(Eof(f)) Do
 Begin
  ReadRegion(f,Cl^.Dat);
  If Not(Cl^.DAt.Locked) Then
   {If Cl^.Dat.Employ Then}
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod);
       ImportRegion(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
End;





(*************    О С Н О В Н А Я    П Р О Г Р А М М А        ***********)
Begin
 j:=1;
 For j:=1 To CMaxSklads Do
  Begin
   If FindParam('/'+WordToMyHex(j)) Then ReplicationObject[j]:=1
   Else
   ReplicationObject[j]:=0;
  End;



 {цикл настройки на обрабатываемые задачи}
 For j:=1 To CMaxTasks Do
  Begin
   ReplicationTasks[j]:=0;
  End;

 If FindParam(StartClient) Then ReplicationTasks[1]:=1;{client}
 If FindParam(StartMake)   Then ReplicationTasks[2]:=1;{make}
 If FindParam(StartBarter) Then ReplicationTasks[3]:=1;{barter}
 If FindParam(StartAgent)  Then ReplicationTasks[4]:=1;{agent}
 If FindParam(StartSklad)  Then ReplicationTasks[5]:=1;{Sklad}
 If FindParam(StartEksped) Then ReplicationTasks[6]:=1;{eksped}
 If FindParam(StartGroup)  Then ReplicationTasks[7]:=1;{group}
 If FindParam(StartRegion) Then ReplicationTasks[8]:=1;{region}

 Assign(Log,'sheduler.log');
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


 Assign(Ini,'sheduler.ini');
 j:=IoResult;
 Reset(Ini);
 j:=IoResult;
 If j<>0 Then
  Begin
   {SpecialBeep;}
   Writeln('Ошибка открытия ini-файла');
   AddLog(Log,'Ошибка открытия ini-файла');
   AddLog(Log,'Аварийное завершение');
   j:=IoResult;
   Close(Log);
   j:=IoResult;
   Exit;
  End;

 Readln(Ini,ScanPAth);{читаем каталог сканирования}
 Readln(Ini,TempPAth);{читаем каталог сканирования}
 Readln(Ini,OutSklad);{читаем код склада - отправителя}
 OutSklad:=IntToStr(StrToInt(OutSklad),CMantissa);
 RFormatZerro(OutSklad,CMantissa);

 For j:=1 To CMaxSklads Do
  Begin
   Readln(Ini,ReplicationPath[j]);
   I:=IoResult;
  End;
 I:=IoResult;
 Close(Ini);
 I:=IoResult;{закрытие ini файла}



 {цикл основной работы}
 AddLog(Log,'Старт сеанса обработки');

 {цикл по задачам}
 For j:=1 To CMaxTasks Do
  BEgin
   If ReplicationTasks[j]=1 Then{проверяем необходимость обработки}
    Begin
     Case j Of
     1:Begin
	   fileName:=ScanPath+StartClient+'.db';
        Pref:=ClientPrefix;
        AddLog(Log,'Обработка задачи '+StartClient+' ('+FileName+')');
        ReplicationClient(FileName,Pref);
       End;
     2:Begin
       Pref:=MakePrefix;
	  fileName:=ScanPath+StartMAke+'.db';
       AddLog(Log,'Обработка задачи '+StartMake+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;
     3:Begin
	  fileName:=ScanPath+StartBarter+'.db';
       Pref:=BarterPrefix;
       AddLog(Log,'Обработка задачи '+StartBarter+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;
     4:Begin
	  fileName:=ScanPath+StartAgent+'.db';
       Pref:=AgentPrefix;
       AddLog(Log,'Обработка задачи '+StartAgent+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;
     5:Begin
	  fileName:=ScanPath+StartSklad+'.db';
       Pref:=SkladPrefix;
       AddLog(Log,'Обработка задачи '+StartSklad+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;
     6:Begin
	  fileName:=ScanPath+StartEksped+'.db';
       Pref:=EkspeditorPrefix;
       AddLog(Log,'Обработка задачи '+StartEksped+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;
     7:Begin
	  fileName:=ScanPath+StartGroup+'.db';
       Pref:=GroupPrefix;
       AddLog(Log,'Обработка задачи '+StartGroup+' ('+FileName+')');
       ReplicationExtended(FileName,Pref);
       End;
     8:Begin
	  fileName:=ScanPath+StartRegion+'.db';
       Pref:=RegionPrefix;
       AddLog(Log,'Обработка задачи '+StartRegion+' ('+FileName+')');
       ReplicationExtended(FileName,Pref);
       End;
     Else
	  Begin
        AddLog(Log,'Обрабатывемая задача не определена');
        I:=IoResult;
        Close(Log);
        I:=IoResult;
	   Exit;
       End;{ветка Else у Case}
    End;{Case}
   End;{проверяем необходимость выполнения задачи}
  End;{цикл по задачам}




 AddLog(Log,'Завершение сеанса обработки');
 {конец цикла основной работы}

 I:=IoResult;
 Close(Log);
 I:=IoResult;


End.