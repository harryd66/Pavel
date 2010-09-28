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

Uses Glob,Serv,Servstr,{Mail,Utils,Utils4,Utils5,}Utils1,StHolder,Utils,
     {MsgBox,}TpDate,NetCall,Dos,NetDbEng;

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

{$I Compile.INC}

{$DEFINE Converter}


Const

 CMaxTasks = 23;


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
 R04960.103   маршруты
 }


 StartClient='CLIENT';{1}
 StartMAke='MAKE';{2}
 StartBarter='BARTER';{3}
 StartAgent='AGENT';{4}
 StartSklad='SKLAD';{5}
 StartEksped='EKSPED';{6}
 StartGroup='GROUP';{7}
 StartRoute='ROUTE';{7}
 StartRegion='REGION';{8}
 StartBank='BANKS';{9}
 StartNGTD='NGTD';{9}
 StartMERA='MERA';{9}
 StartExpert='EXPERT';{9}
 StartMarka='MARKA';{9}
 StartSMarka='SMARKA';{9}
 StartLANDS='LANDS';{9}
 StartFIRMA='FIRMA';{9}
 StartKSERTIF='KSERTIF';{9}
 StartClass='CLASS';{9}
 StartKassa='KASSA';{9}
 StartPERSONAL='PERSONAL';{9}
 StartMOVING='MOVING';{9}
 StartPassword='PASSWORD';{9}

Const
 KurzSklad : array[1..30] of Char=('1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K',
 {21 22  23   24  25  26  27  28  29  30}
 'L','M','N','O','P','Q','R','S','T','U');

Var  Log,Lst : Text;




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


function FExists(FileName: TMyString): Boolean;
var
  F: file;
  Attr: Word;
begin
  Attr:=IOResult;
  Assign(F, FileName);
  GetFAttr(F, Attr);
  Attr:=IOResult;
  FExists := DosError = 0;
  Attr:=IOResult;
  DosError:=0;
end;



Procedure AddLst(s:String);
Var j : Word;
Begin
 If Not FExists('Client.lst') Then
  Begin
   j:=IoResult;
   Writeln('Ошибка открытия файла-списка');
   AddLog(Log,'Ошибка открытия файла-списка');
   Assign(Lst,'Client.lst');
   j:=IoResult;
   Rewrite(Lst);
   j:=IoResult;
   If j<>0 Then
    Begin
     {SpecialBeep;}
     AddLog(Log,'Ошибка создания файла-списка');
     Writeln('Ошибка создания файла-списка');
    End
    Else
     Begin
      j:=IoResult;
      Close(Lst);
      j:=IoResult;
     End;
  End;


 Assign(Lst,'Client.lst');
 j:=IoResult;
 Append(Lst);
 j:=IoResult;
 If j<>0 Then
  Begin
   AddLog(Log,'Ошибка записи в файл-список');
   Writeln('Ошибка записи в файл-список');
   Exit;
  End;
 WriteLn(Lst,s);
 j:=IoResult;
 Close(lst);
 j:=IoResult;
End;



Procedure AddLstB(s:String);
Var j : Word;
Begin
 If Not FExists('Barter.lst') Then
  Begin
   j:=IoResult;
   Writeln('Ошибка открытия файла-списка');
   AddLog(Log,'Ошибка открытия файла-списка');
   Assign(Lst,'Barter.lst');
   j:=IoResult;
   Rewrite(Lst);
   j:=IoResult;
   If j<>0 Then
    Begin
     {SpecialBeep;}
     AddLog(Log,'Ошибка создания файла-списка');
     Writeln('Ошибка создания файла-списка');
    End
    Else
     Begin
      j:=IoResult;
      Close(Lst);
      j:=IoResult;
     End;
  End;


 Assign(Lst,'Barter.lst');
 j:=IoResult;
 Append(Lst);
 j:=IoResult;
 If j<>0 Then
  Begin
   AddLog(Log,'Ошибка записи в файл-список');
   Writeln('Ошибка записи в файл-список');
   Exit;
  End;
 WriteLn(Lst,s);
 j:=IoResult;
 Close(lst);
 j:=IoResult;
End;


Procedure AddLstM(s:String);
Var j : Word;
Begin

 If Not FExists('Make.lst') Then
  Begin
   j:=IoResult;
   Writeln('Ошибка открытия файла-списка');
   AddLog(Log,'Ошибка открытия файла-списка');
   Assign(Lst,'Make.lst');
   j:=IoResult;
   Rewrite(Lst);
   j:=IoResult;
   If j<>0 Then
    Begin
     {SpecialBeep;}
     AddLog(Log,'Ошибка создания файла-списка');
     Writeln('Ошибка создания файла-списка');
    End
    Else
     Begin
      j:=IoResult;
      Close(Lst);
      j:=IoResult;
     End;
  End;
 Assign(Lst,'Make.lst');
 j:=IoResult;
 Append(Lst);
 j:=IoResult;
 If j<>0 Then
  Begin
   AddLog(Log,'Ошибка записи в файл-список');
   Writeln('Ошибка записи в файл-список');
   Exit;
  End;
 WriteLn(Lst,s);
 j:=IoResult;
 Close(lst);
 j:=IoResult;
End;






Var
    ReplicationObject: Array [1..CMaxSklads] Of Byte;{управляется параметрами коммандной строки}
    ScanPAth : String;{сканируемый каталог}
    ScanPAthSPR : String;{сканируемый каталог}
    TempPAth : String;{временный каталог перед упаковкой}
    ReplicationPath : Array [1..CMaxSklads] Of String;

    MailPathIn      : Array [1..CMaxSklads] Of String;
    MailPathOut     : Array [1..CMaxSklads] Of String;
    MailRootPath     : String;

    ReplicationTasks: Array [1..CMaxTasks] Of Byte;{список задач подлежащих обработке}
    i,j : Word;
    Cl  : PClientType;
    Gr  : PGroupType;
    Rr  : PRegionType;
    Ini : Text;
    FileName : String;
    OutSklad,Pref  : ArtikulStr;






Function ClearAttribute(FN:String):boolean;
Var F: File;
    Attr: word;
Begin
  ClearAttribute:=False;
  Assign(f,FN);
  GetFAttr(f,Attr);
   if doserror=0 then
     begin
      Attr:=IOResult;
      SetFAttr(f,(Not Dos.Hidden)+(Not Dos.SYSFile)+(Not Dos.ReadOnly)+Dos.Archive);
      Attr:=IOResult;

      If Attr<>0 Then
       Begin
        AddLog(Log,'Ошибка установки новых аттрибутов '+FN);
       End
      Else
      Begin
      ClearAttribute:=True;
      Erase(f);
      Attr:=IOResult;
      End;
     end
   else
     begin
      AddLog(Log,'Ошибка снятия аттрибутов '+FN);
     end;
End;



Procedure PackMessages(BakPath,NewPath:String);
Var s1 : String;
    Result : Word;
    f : File;
Begin
  If FExists(NewPath) Then
   Begin
    If Not ClearAttribute(NewPath) Then
       Begin
        AddLog(Log,'Ошибка упаковки '+NewPath);
	   Exit;
       End;
   End;

  s1:='rar a -m5 -ep -ep1 -inul -y -w'+TempPath+' '+
  NewPath+' '+BakPath+' '+'>NUL';
  DelSpaceRight(s1);

  SWAPVECTORS;
  exec (GetEnv('Comspec'),' /C '+S1);
  Result:=DosError;
  SWAPVECTORS;

  If FExists(NewPath) Then
    AddLog(Log,'Упаковка '+NewPath+' Ok')
  Else
    AddLog(Log,'Ошибка упаковки '+NewPath);
End;

Function GetImportFileNameWithPrefix(Pr,Kod:ArtikulStr):AllStr;
Begin
 RFormatZerro(Kod,CClientKod);
 GetImportFileNameWithPrefix:=Pr+Kod+OutSklad[1]+'.'+OutSklad[2];
End;


Function GetImportFileNameWithPrefixArtikul(Pr,Kod:ArtikulStr):AllStr;
Begin
 RFormatZerro(Kod,CArtikul);
 GetImportFileNameWithPrefixArtikul:=Pr+Kod+OutSklad[1]+'.'+OutSklad[2];
End;



Procedure ReplicationClient(FN:String;Pr:ArtikulStr);
Var f : ClientFileType;
    c : Word;
    Cl : PClientType;
    PoS : LongInt;


Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 c:=IoResult;
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(ClientType),SizeOf(ClientType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 c:=IoResult;
 Repeat
  Unlock(f,Pos*SizeOf(ClientType),SizeOf(ClientType));
 Until DosError=0;
 c:=IoResult;
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
     Cl.RCD:=False;
     Write(ExpF,Cl);
     c:=IOResult;
     Close(ExpF);
     c:=IOResult;
     If Pr<>ClientPrefix Then
     PackMessages(TempPath+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush)
     Else
     PackMessages(TempPath+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush)
    End;{проверка нужно ли обрабатывать для данного объекта}
  End;{For}
End;{Procedure}

Var Position : LongInt;


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
  {If Not(Cl^.DAt.Locked) Then}
   {If Cl^.Dat.Employ Then}
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.Dat.Name);
       If (System.Pos('CLIENT',FN)>0) Then AddLst(Cl^.Dat.Kod);
       If (System.Pos('BARTER',FN)>0) Then AddLstB(Cl^.Dat.Kod);
       If (System.Pos('MAKE',FN)>0) Then AddLstM(Cl^.Dat.Kod);
       If (System.Pos('BARTER',FN)>0) Or (System.Pos('MAKE',FN)>0) Then
        Begin
         Cl^.Dat.Name:='СМ.РЕЗЕРВНЫЙ СКЛАД';
         Cl^.Dat.FullName:='СМ.РЕЗЕРВНЫЙ СКЛАД';
         Cl^.Dat.Adress:='СМ.РЕЗЕРВНЫЙ СКЛАД';
         Cl^.Dat.AdressF:='СМ.РЕЗЕРВНЫЙ СКЛАД';
         Cl^.Dat.Telefon:='';
         Cl^.Dat.INN:='';
         Cl^.Dat.Enviropment:='';
         Cl^.Dat.Dogovor:='';
        End;
       ImportClient(Pr,Cl^.DAt);


       {вставка для обязательной отправки главного клиента}
       If (System.Pos('CLIENT',FN)>0) Then
       If Cl^.Dat.Main=1 Then
       If StrToInt(Cl^.Dat.FantomKod)<FileSize(f) Then
        Begin
         Position:=FilePos(f);
         c:=IoResult;
         {прыгуем курсором в новую позицию}
         Seek(f,StrToInt(Cl^.Dat.FantomKod));
         c:=IoResult;
         ReadClient(f,Cl^.Dat);
         ClearAttribRCD;
         AddLog(Log,'Обнаружен смежный объект '+Cl^.Dat.Kod+' '+Cl^.Dat.Name);
         ImportClient(Pr,Cl^.DAt);
         {возращаем курсор в прежнее положение}
         c:=IoResult;
         Seek(f,Position);
         c:=IoResult;
        End;


      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
Dispose(Cl,Done);
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
   {If Cl^.Dat.Employ Then}
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.DAt.RegionNAme);
       ImportRegion(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
Dispose(Cl,Done);
End;




Procedure ReplicationFirma(FN:String;Pr:ArtikulStr);
Var f : FirmaPostFileType;
    c : Word;
    Cl : PFirmaPostType;
    PoS : LongInt;

Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(FirmaPostType),SizeOf(FirmaPostType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(FirmaPostType),SizeOf(FirmaPostType));
 Until DosError=0;
End;

Procedure ImportFirmaPost(Pr:ArtikulStr;Cl:FirmaPostType);
Var ExpF : File Of FirmaPostType;
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
  ReadFirmaPost(f,Cl^.Dat);
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.DAt.FirmaPost);
       ImportFirmaPost(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
Dispose(Cl,Done);
End;


Procedure ReplicationPost(FN:String;Pr:ArtikulStr);
Var f : PostFileType;
    c : Word;
    Cl : PPostType;
    PoS : LongInt;
Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(PostType),SizeOf(PostType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(PostType),SizeOf(PostType));
 Until DosError=0;
End;

Procedure ImportPost(Pr:ArtikulStr;Cl:PostType);
Var ExpF : File Of PostType;
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
  ReadPost(f,Cl^.Dat);
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.DAt.Post);
       ImportPost(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
Dispose(Cl,Done);
End;



Procedure ReplicationMera(FN:String;Pr:ArtikulStr);
Var f : MeraFileType;
    c : Word;
    Cl : PMeraType;
    PoS : LongInt;
Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(MeraType),SizeOf(MeraType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(MeraType),SizeOf(MeraType));
 Until DosError=0;
End;

Procedure ImportMera(Pr:ArtikulStr;Cl:MeraType);
Var ExpF : File Of MeraType;
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
  ReadMera(f,Cl^.Dat);
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.DAt.Mera);
       ImportMera(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
Dispose(Cl,Done);
End;



Procedure ReplicationKSertif(FN:String;Pr:ArtikulStr);
Var f : KSertifFileType;
    c : Word;
    Cl : PKSertifType;
    PoS : LongInt;
Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(KSertifType),SizeOf(KSertifType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(KSertifType),SizeOf(KSertifType));
 Until DosError=0;
End;

Procedure ImportKSertif(Pr:ArtikulStr;Cl:KSertifType);
Var ExpF : File Of KSertifType;
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
     Assign(ExpF,TempPath{ReplicationPath[j]}+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+
     Polush);
     c:=IOResult;
     Rewrite(ExpF);
     c:=IOResult;
     If c<>0 Then
      Begin
       AddLog(Log,'Ошибка создания '+{ReplicationPath[j]}TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush+
	  ' Код:'+IntToSTr(c,CKol));
       Continue;{возвращаемся к For}
      End;
     Cl.RCD:=False;
     Write(ExpF,Cl);
     c:=IOResult;
     Close(ExpF);
     c:=IOResult;
     PackMessages(TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush)
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
  ReadKSertif(f,Cl^.Dat);
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.DAt.KSertif);
       ImportKSertif(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
Dispose(Cl,Done);
End;



Procedure ReplicationMarka(FN:String;Pr:ArtikulStr);
Var f : MarkaFileType;
    c : Word;
    Cl : PMarkaType;
    PoS : LongInt;
Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(MarkaType),SizeOf(MarkaType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(MarkaType),SizeOf(MarkaType));
 Until DosError=0;
End;

Procedure ImportMarka(Pr:ArtikulStr;Cl:MarkaType);
Var ExpF : File Of MarkaType;
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
     Assign(ExpF,TempPath{ReplicationPath[j]}+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+
     Polush);
     c:=IOResult;
     Rewrite(ExpF);
     c:=IOResult;
     If c<>0 Then
      Begin
       AddLog(Log,'Ошибка создания '+{ReplicationPath[j]}TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush+
	  ' Код:'+IntToSTr(c,CKol));
       Continue;{возвращаемся к For}
      End;
     Cl.RCD:=False;
     Write(ExpF,Cl);
     c:=IOResult;
     Close(ExpF);
     c:=IOResult;
     PackMessages(TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush)
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
  ReadMarka(f,Cl^.Dat);
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.DAt.Marka);
       ImportMarka(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
Dispose(Cl,Done);
End;


Procedure ReplicationNGTD(FN:String;Pr:ArtikulStr);
Var f : NGTDFileType;
    c : Word;
    Cl : PNGTDType;
    PoS : LongInt;

Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(NGTDType),SizeOf(NGTDType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(NGTDType),SizeOf(NGTDType));
 Until DosError=0;
End;

Procedure ImportNGTD(Pr:ArtikulStr;Cl:NGTDType);
Var ExpF : File Of NGTDType;
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
     Assign(ExpF,TempPath{ReplicationPath[j]}+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+
     Polush);
     c:=IOResult;
     Rewrite(ExpF);
     c:=IOResult;
     If c<>0 Then
      Begin
       AddLog(Log,'Ошибка создания '+{ReplicationPath[j]}TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush+
	  ' Код:'+IntToSTr(c,CKol));
       Continue;{возвращаемся к For}
      End;
     Cl.RCD:=False;
     Write(ExpF,Cl);
     c:=IOResult;
     Close(ExpF);
     c:=IOResult;
     PackMessages(TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush)
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
  ReadNGTD(f,Cl^.Dat);
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.DAt.NGTD);
       ImportNGTD(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
Dispose(Cl,Done);
End;


Procedure ReplicationExpert(FN:String;Pr:ArtikulStr);
Var f : ExpertFileType;
    c : Word;
    Cl : PExpertType;
    PoS : LongInt;

Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(ExpertType),SizeOf(ExpertType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(ExpertType),SizeOf(ExpertType));
 Until DosError=0;
End;

Procedure ImportExpert(Pr:ArtikulStr;Cl:ExpertType);
Var ExpF : File Of ExpertType;
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
     Assign(ExpF,TempPath{ReplicationPath[j]}+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+
     Polush);
     c:=IOResult;
     Rewrite(ExpF);
     c:=IOResult;
     If c<>0 Then
      Begin
       AddLog(Log,'Ошибка создания '+{ReplicationPath[j]}TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush+
	  ' Код:'+IntToSTr(c,CKol));
       Continue;{возвращаемся к For}
      End;
     Cl.RCD:=False;
     Write(ExpF,Cl);
     c:=IOResult;
     Close(ExpF);
     c:=IOResult;
     PackMessages(TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush)
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
  ReadExpert(f,Cl^.Dat);
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.DAt.Expert);
       ImportExpert(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
Dispose(Cl,Done);
End;




Procedure ReplicationClass(FN:String;Pr:ArtikulStr);
Var f : ClassFileType;
    c : Word;
    Cl : PClassificatorBuchType;
    PoS : LongInt;

Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(ClassificatorBuchType),SizeOf(ClassificatorBuchType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(ClassificatorBuchType),SizeOf(ClassificatorBuchType));
 Until DosError=0;
End;

Procedure ImportClass(Pr:ArtikulStr;Cl:ClassificatorBuchType);
Var ExpF : File Of ClassificatorBuchType;
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
     Assign(ExpF,TempPath{ReplicationPath[j]}+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+
     Polush);
     c:=IOResult;
     Rewrite(ExpF);
     c:=IOResult;
     If c<>0 Then
      Begin
       AddLog(Log,'Ошибка создания '+{ReplicationPath[j]}TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush+
	  ' Код:'+IntToSTr(c,CKol));
       Continue;{возвращаемся к For}
      End;
     Cl.RCD:=False;
     Write(ExpF,Cl);
     c:=IOResult;
     Close(ExpF);
     c:=IOResult;
     PackMessages(TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush)
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
  ReadClass(f,Cl^.Dat);
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.DAt.Name);
       ImportClass(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
Dispose(Cl,Done);
End;


Procedure ReplicationPersonal(FN:String;Pr:ArtikulStr);
Var f : PersonalFileType;
    c : Word;
    Cl : PPersonalType;
    PoS : LongInt;

Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(PersonalType),SizeOf(PersonalType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(PersonalType),SizeOf(PersonalType));
 Until DosError=0;
End;

Procedure ImportPersonal(Pr:ArtikulStr;Cl:PersonalType);
Var ExpF : File Of PersonalType;
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
     Assign(ExpF,TempPath{ReplicationPath[j]}+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+
     Polush);
     c:=IOResult;
     Rewrite(ExpF);
     c:=IOResult;
     If c<>0 Then
      Begin
       AddLog(Log,'Ошибка создания '+{ReplicationPath[j]}TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush+
	  ' Код:'+IntToSTr(c,CKol));
       Continue;{возвращаемся к For}
      End;
     Cl.RCD:=False;
     Write(ExpF,Cl);
     c:=IOResult;
     Close(ExpF);
     c:=IOResult;
     PackMessages(TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush)
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
  ReadPersonal(f,Cl^.Dat);
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.DAt.Name);
       ImportPersonal(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
Dispose(Cl,Done);
End;



Procedure ReplicationBank(FN:String;Pr:ArtikulStr);
Var f : BankFileType;
    c : Word;
    Cl : PBankType;
    PoS : LongInt;

Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(BankType),SizeOf(BankType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(BankType),SizeOf(BankType));
 Until DosError=0;
End;

Procedure ImportBank(Pr:ArtikulStr;Cl:BankType);
Var ExpF : File Of BankType;
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
     Assign(ExpF,TempPath{ReplicationPath[j]}+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+
     Polush);
     c:=IOResult;
     Rewrite(ExpF);
     c:=IOResult;
     If c<>0 Then
      Begin
       AddLog(Log,'Ошибка создания '+{ReplicationPath[j]}TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush+
	  ' Код:'+IntToSTr(c,CKol));
       Continue;{возвращаемся к For}
      End;
     Cl.RCD:=False;
     Write(ExpF,Cl);
     c:=IOResult;
     Close(ExpF);
     c:=IOResult;
     PackMessages(TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush)
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
  ReadBank(f,Cl^.Dat);
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.DAt.FullName);
       ImportBank(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
Dispose(Cl,Done);
End;






Procedure ReplicationKassa(FN:String;Pr:ArtikulStr);
Var f : KassaOperationFileType;
    c : Word;
    Cl : PKassaOperationType;
    PoS : LongInt;

Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(KassaOperationType),SizeOf(KassaOperationType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(KassaOperationType),SizeOf(KassaOperationType));
 Until DosError=0;
End;

Procedure ImportKassaOperation(Pr:ArtikulStr;Cl:KassaOperationType);
Var ExpF : File Of KassaOperationType;
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
     Assign(ExpF,TempPath{ReplicationPath[j]}+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+
     Polush);
     c:=IOResult;
     Rewrite(ExpF);
     c:=IOResult;
     If c<>0 Then
      Begin
       AddLog(Log,'Ошибка создания '+{ReplicationPath[j]}TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush+
	  ' Код:'+IntToSTr(c,CKol));
       Continue;{возвращаемся к For}
      End;
     Cl.RCD:=False;
     Write(ExpF,Cl);
     c:=IOResult;
     Close(ExpF);
     c:=IOResult;
     PackMessages(TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush)
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
  ReadKassa(f,Cl^.Dat);
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.DAt.Name1);
       ImportKassaOperation(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
Dispose(Cl,Done);
End;





Procedure ReplicationSMarka(FN:String;Pr:ArtikulStr);
Var f : SpecMarkaFileType;
    c : Word;
    Cl : PSpecMarkaType;
    PoS : LongInt;
Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType));{предварительная блокировка}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType));
 Until DosError=0;
End;

Procedure ImportSMarka(Pr:ArtikulStr;Cl:SpecMarkaType);
Var ExpF : File Of SpecMarkaType;
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
     Assign(ExpF,TempPath{ReplicationPath[j]}+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+
     Polush);
     c:=IOResult;
     Rewrite(ExpF);
     c:=IOResult;
     If c<>0 Then
      Begin
       AddLog(Log,'Ошибка создания '+{ReplicationPath[j]}TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush+
	  ' Код:'+IntToSTr(c,CKol));
       Continue;{возвращаемся к For}
      End;
     Cl.RCD:=False;
     Write(ExpF,Cl);
     c:=IOResult;
     Close(ExpF);
     c:=IOResult;
     PackMessages(TempPath+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefixArtikul(Pr,Cl.Kod)+Polush)
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
  ReadSpecMarka(f,Cl^.Dat);
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'Обнаружен объект '+Cl^.Dat.Kod+' '+Cl^.DAt.SpecMarka);
       ImportSMarka(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
Dispose(Cl,Done);
End;







Procedure ShowHelp;
Begin
Writeln('Монитор изменения баз данных '+CompileDate);
Writeln('Протокол операций monitor.log');
Writeln('Файл конфигурации monitor.ini');
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
Writeln('CLIENT - обрабатывать репликации по базе клиентов (client.db)');
Writeln('MAKE   - обрабатывать репликации по базе поставщиков (make.db)');
Writeln('BARTER - обрабатывать репликации по базе взаимозачетов (barter.db)');
Writeln('AGENT  - обрабатывать репликации по базе торговых представителей (agent.db)');
Writeln('SKLAD  - обрабатывать репликации по базе внутренних подразделений (sklad.db)');
Writeln('EKSPED - обрабатывать репликации по базе экспедиторов (eksped.db)');
Writeln('GROUP  - обрабатывать репликации по базе групп (group.db)');
Writeln('REGION - обрабатывать репликации по базе регионов (region.db)');
Writeln('ROUTE  - обрабатывать репликации по базе маршрутов (route.db)');
Writeln('MERA   - обрабатывать репликации по базе единиц измерения (mera.db)');
Writeln('LANDS  - обрабатывать репликации по базе стран-происхождения (lands.db)');
Writeln('FIRMA  - обрабатывать репликации по базе фирм-производителей (firma.db)');
Writeln('KSERTIF- обрабатывать репликации по базе органов сертификации (ksertif.db)');
Writeln('MARKA  - обрабатывать репликации по базе акцизных марок (marka.db)');
Writeln('SMARKA - обрабатывать репликации по базе спецмарок (smarka.db)');
Writeln('NGTD   - обрабатывать репликации по базе ГТД (ngtd.db)');
Writeln('EXPERT - обрабатывать репликации по базе экспертных заключений (expert.db)');
Writeln('BANKS  - обрабатывать репликации по базе банков (banks.db)');
Writeln('CLASS  - обрабатывать репликации по базе бухгалтерских классов (class.db)');
Writeln('KASSA  - обрабатывать репликации по базе кассовых операций (kassa.db)');
Writeln('PERSON - обрабатывать репликации по базе песонала (personal.db)');
Halt;
End;


Function FindParam(s:String):Boolean;
Var i : Word;
Begin
 FindParam:=False;
 For i:=1 To ParamCount+1 Do
  Begin
   If (Pos(s,UpCAses(ParamStr(i)))>0) Then
         Begin
          FindParam:=True;
          Break;
         End;
  End;

 If Pos(UpCases(s),UpCases(ConfigCmdParameters))>0 Then  FindParam:=True;

End;


Function SetReadMailAttribute(FN:String):boolean;
Var F: File;
    Attr: word;
Begin
  SetReadMailAttribute:=False;
  Assign(f,FN);
  GetFAttr(f,Attr);
   if doserror=0 then
     begin
      SetFAttr(f,Dos.Hidden+Dos.Archive);
      SetReadMailAttribute:=True;
     end
End;



Procedure MoveFiles(Var j,k:Word;SKto,SKomu:String);
Var s,SDistanation : String;
    DirInfo: SearchRec;         { For Windows, use TSearchRec }
    TestStr : AllStr;
Begin
 DosError:=0;
 FindFirst(MailRootPath+'*'+SKto[1]+'.'+SKto[2]+SKomu, AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   {
   TestStr:=Copy(s,Pos(s,'.')-1,3);
   If Pos(TestStr,'.')>0 Then System.Delete(TestStr,Pos(TestStr,'.'),1);
   DelSpace(TestStr);
   DelSpace(SKto);

   }

   {If Skto=TestStr Then}
   If Not (Pos('-',s)>0) Then
   If Not HiddenAttribute(MailRootPath+DirInfo.Name) Then
   If Not SystemAttribute(MailRootPath+DirInfo.Name) Then
   If DirInfo.Size>0 Then
   Begin
    AddLog(Log,'Обнаружен файл '+MailRootPath+DirInfo.Name);
    SDistanation:=MailPathOut[k];

    {If SDistanation[Length(SDistanation)]='\' Then SDistanation[0]:=Chr(Length(SDistanation)-1);}

  SWAPVECTORS;
    exec (GetEnvMy,'/c copy /Y '+MailRootPath+s+' '+SDistanation+' >NUL');
  SWAPVECTORS;




    If FExists(MailPathOut[k]+DirInfo.Name) Then
     Begin
      AddLog(Log,'Файл '+MailRootPath+DirInfo.Name+' --> '+MailPathOut[k]+DirInfo.Name+'  - Ок');
      If Not SetReadMailAttribute(MailRootPath+DirInfo.Name) Then
      AddLog(Log,'Ошибка установки аттрибута о передаче '+MailRootPath+DirInfo.Name);
     End{If FExists(ReplicationPath[k]+DirInfo.Name) Then}
     Else
      AddLog(Log,'Ошибка при копировании '+MailRootPath+DirInfo.Name+' --> '+MailPathOut[k]+DirInfo.Name);
{
     Writeln(SKto+' '+TestStr);
     Readln;
}
   End;
   FindNext(DirInfo);
 end;{While}

End;


Procedure FastMoveFiles(SKto,SKuda:String);
Var s,SDistanation : String;
    DirInfo: SearchRec;         { For Windows, use TSearchRec }
Begin
 DosError:=0;
 FindFirst(SKto+'*.*', AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not HiddenAttribute(SKto+DirInfo.Name) Then
   If Not SystemAttribute(SKto+DirInfo.Name) Then
   If DirInfo.Size>0 Then
   Begin
     AddLog(Log,'Обнаружен файл '+SKto+DirInfo.Name);
     SDistanation:=SKuda;
     If SDistanation[Length(SDistanation)]='\' Then SDistanation[0]:=Chr(Length(SDistanation)-1);

  SWAPVECTORS;
     exec (GetEnvMy,' /C move /Y '+SKto+s+' '+SDistanation+' >NUL');
  SWAPVECTORS;

    If FExists(SKuda+DirInfo.Name) Then
     Begin
      AddLog(Log,'Файл '+SKto+DirInfo.Name+' --> '+SKuda+DirInfo.Name+'  - Ок');

     End{If FExists(ReplicationPath[k]+DirInfo.Name) Then}
     Else
      AddLog(Log,'Ошибка '+SKto+DirInfo.Name+' --> '+SKuda+DirInfo.Name+'');
   End;
   FindNext(DirInfo);
 end;{While}

End;


Procedure CopyPasswordBase(j:Word);
Var s : String;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
 DirInfoB: SearchRec;         { For Windows, use TSearchRec }
    c : Word;
    size : String[CIZena];
    SDistanation : String;
Begin
 If FExists(MailPathOut[j]+'system.pwl') Then
Begin
 FindFirst(MailPathOut[j]+'system.pwl', AnyFile, DirInfoB);
 while DosError = 0 do
 begin
    FindNext(DirInfoB);
 end;{While}
 DosError := 0;

 FindFirst(MailRootPath+'system.pwl', AnyFile, DirInfo);
 while DosError=0 do
 begin
    s:=DirInfo.Name;
   If (DirInfoB.Time<>DirInfo.Time) Or (DirInfoB.Size<>DirInfo.Size) Then
   Begin
    SDistanation:=MailPathOut[j];
    If SDistanation[Length(SDistanation)]='\' Then SDistanation[0]:=Chr(Length(SDistanation)-1);

  SWAPVECTORS;
    exec (GetEnvMy,'/C copy /Y /b '+MailRootPath+'system.pwl'+' '+SDistanation+' >NUL');
  SWAPVECTORS;
    AddLog(Log,'Копирование '+MailRootPath+'system.pwl'+' '+SDistanation);
   End;
    FindNext(DirInfo);
 end;{While}
End
 Else
  Begin
    SDistanation:=MailPathOut[j];
    If SDistanation[Length(SDistanation)]='\' Then SDistanation[0]:=Chr(Length(SDistanation)-1);

  SWAPVECTORS;
    exec (GetEnvMy,'/C copy /Y /b '+MailRootPath+'system.pwl'+' '+SDistanation+' >NUL');
  SWAPVECTORS;
    AddLog(Log,'Копирование '+MailRootPath+'system.pwl'+' '+SDistanation);
  End;



End;





Procedure ReadNewIni;
Var j,i : Byte;
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
 Assign(Ini,'monitor.ini');
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
   j:=IoResult;
   Close(Lst);
   j:=IoResult;
   Exit;
  End;

 I:=IoResult;
 Close(Ini);
 I:=IoResult;{закрытие ini файла}

SH.Init;
SH.LoadFromFile ('monitor.ini');

 ScanPAth:=GetAsString('ScanPath');
 ScanPAthSPR:=GetAsString('ScanSPR');
 TempPAth:=GetAsString('TempPath');
 OutSklad:=GetAsString('OutSklad');
 OutSklad:=IntToStr(StrToInt(OutSklad),CMantissa);
 RFormatZerro(OutSklad,CMantissa);

 MailRootPath:=GetAsString('MailRootPath');

 For j:=1 To CMaxSklads Do
  Begin
   ReplicationPath[j,0]:=#0;
   {то что приходит со склада}
   MailPathIn[j,0]:=#0;
   {то что уходит на склада}
   MailPathOut[j,0]:=#0;
   ReplicationPath[j]:=GetAsString('ReplicationPath['+IntToStr(j,CMantissa)+']');
   {Writeln('ReplicationPath[j]'+ReplicationPath[j]);}
   MailPathIn[j]:=GetAsString('MailPathIn['+IntToStr(j,CMantissa)+']');
   {Writeln('MailPathIn[j]'+MailPathIn[j]);}
   MailPathOut[j]:=GetAsString('MailPathOut['+IntToStr(j,CMantissa)+']');
   {Writeln('MailPathOut[j]'+MailPathOut[j]);}
  End;

SH.Done;

End;





Var SKto,SKomu : AllStr;
    k : Word;


(*************    О С Н О В Н А Я    П Р О Г Р А М М А        ***********)
Begin
 FileMode:=66;

 If FindParam('/?') Then
  Begin
   ShowHelp;
  End;

 j:=1;
 For j:=1 To CMaxSklads Do
  Begin
   If FindParam('/'+{WordToMyHex(j)}KurzSklad[j]) Then ReplicationObject[j]:=1
   Else
   ReplicationObject[j]:=0;
  End;


 {цикл настройки на обрабатываемые задачи}
 For j:=1 To CMaxTasks Do
  Begin
   ReplicationTasks[j]:=0;
  End;

 If FindParam(StartClient) Then ReplicationTasks[1]:=1;{client.db}
 If FindParam(StartMake)   Then ReplicationTasks[2]:=1;{make.db}
 If FindParam(StartBarter) Then ReplicationTasks[3]:=1;{barter.db}
 If FindParam(StartAgent)  Then ReplicationTasks[4]:=1;{agent.db}
 If FindParam(StartSklad)  Then ReplicationTasks[5]:=1;{Sklad.db}
 If FindParam(StartEksped) Then ReplicationTasks[6]:=1;{eksped.db}
 If FindParam(StartGroup)  Then ReplicationTasks[7]:=1;{group.db}
 If FindParam(StartRegion) Then ReplicationTasks[8]:=1;{region.db}
 If FindParam(StartRoute)  Then ReplicationTasks[9]:=1;{route.db}

 If FindParam(StartFIRMA)  Then ReplicationTasks[10]:=1;{firma.db}
 If FindParam(StartLands) Then ReplicationTasks[11]:=1;{lands.db}
 If FindParam(StartKSertif)  Then ReplicationTasks[12]:=1;{ksertif.db}
 If FindParam(StartMera)   Then ReplicationTasks[13]:=1;{mera.db}
 If FindParam(StartMarka)  Then ReplicationTasks[14]:=1;{marka.db}
 If FindParam(StartSMarka) Then ReplicationTasks[15]:=1;{smarka.db}
 If FindParam(StartNGTD)    Then ReplicationTasks[16]:=1;{ngtd.db}
 If FindParam(StartExpert) Then ReplicationTasks[17]:=1;{expert.db}
 If FindParam(StartBank)  Then ReplicationTasks[18]:=1;{banks.db}
 If FindParam(StartClass) Then ReplicationTasks[19]:=1;{class.db}
 If FindParam(StartKassa) Then ReplicationTasks[20]:=1;{kassa.db}
 If FindParam(StartPersonal) Then ReplicationTasks[21]:=1;{personal.db}
 If FindParam(StartMoving) Then ReplicationTasks[22]:=1;{перемещения}
 If FindParam(StartPassword) Then ReplicationTasks[23]:=1;{пароли}



 Assign(Log,'monitor.log');
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

(*
 Assign(Lst,'Client.lst');
 j:=IoResult;
 Append(Lst);
 j:=IoResult;
 If j<>0 Then
*)


 ReadNewIni;


 {цикл основной работы}
 AddLog(Log,'Старт сеанса обработки репликации справочников');

 {цикл по задачам}
 For j:=1 To CMaxTasks Do
  BEgin
   If j<22{StartMoving} Then
   If ReplicationTasks[j]=1 Then{проверяем необходимость обработки}
    Begin
     Case j Of
     1:Begin
	   fileName:=ScanPath+StartClient+'.db';
        Pref:=ClientPrefix;
        If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartClient+' ('+FileName+')');
        ReplicationClient(FileName,Pref);
       End;

     2:Begin
       Pref:=MakePrefix;
	  fileName:=ScanPath+StartMAke+'.db';
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartMake+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;

     3:Begin
	  fileName:=ScanPath+StartBarter+'.db';
       Pref:=BarterPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartBarter+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;

     4:Begin
	  fileName:=ScanPath+StartAgent+'.db';
       Pref:=AgentPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartAgent+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;
     5:Begin
	  fileName:=ScanPath+StartSklad+'.db';
       Pref:=SkladPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartSklad+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;
     6:Begin
	  fileName:=ScanPath+StartEksped+'.db';
       Pref:=EkspeditorPrefix;
       {Writeln(ScanPath+StartEksped+'.db');}
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartEksped+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;
     7:Begin
	  fileName:=ScanPathSPR+StartGroup+'.db';
       Pref:=GroupPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartGroup+' ('+FileName+')');
       ReplicationExtended(FileName,Pref);
       End;

     8:Begin
	  fileName:=ScanPathSPR+StartRegion+'.db';
       Pref:=RegionPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartRegion+' ('+FileName+')');
       ReplicationExtended(FileName,Pref);
       End;

     9:Begin
	  fileName:=ScanPathSPR+StartRoute+'.db';
       Pref:=RoutePrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartRoute+' ('+FileName+')');
       ReplicationExtended(FileName,Pref);
       End;

    10:Begin
	  fileName:=ScanPathSpr+StartFirma+'.db';
       Pref:=FirmaPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartFirma+' ('+FileName+')');
       ReplicationFirma(FileName,Pref);
       End;

    11:Begin
	  fileName:=ScanPathSpr+StartLands+'.db';
       Pref:=LandsPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartLands+' ('+FileName+')');
       ReplicationPost(FileName,Pref);
       End;

    12:Begin
	  fileName:=ScanPathSpr+StartKSertif+'.db';
       Pref:=KSertifPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartKSertif+' ('+FileName+')');
       ReplicationKSertif(FileName,Pref);
       End;

    13:Begin
	  fileName:=ScanPathSpr+StartMera+'.db';
       Pref:=MeraPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartMera+' ('+FileName+')');
       ReplicationMera(FileName,Pref);
       End;

    14:Begin
	  fileName:=ScanPathSpr+StartMarka+'.db';
       Pref:=MarkaPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartMarka+' ('+FileName+')');
       ReplicationMarka(FileName,Pref);
       End;

    15:Begin
	  fileName:=ScanPathSpr+StartSMarka+'.db';
       Pref:=SMarkaPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartSMarka+' ('+FileName+')');
       ReplicationSMarka(FileName,Pref);
       End;

    16:Begin
	  fileName:=ScanPathSpr+StartNGTD+'.db';
       Pref:=NGTDPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartNGTD+' ('+FileName+')');
       ReplicationNGTD(FileName,Pref);
       End;

    17:Begin
	  fileName:=ScanPathSpr+StartExpert+'.db';
       Pref:=ExpertPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartExpert+' ('+FileName+')');
       ReplicationExpert(FileName,Pref);
       End;

{18 банки}

    18:Begin
	  fileName:=ScanPathSpr+StartBank+'.db';
       Pref:=BankPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartBank+' ('+FileName+')');
       ReplicationBank(FileName,Pref);
       End;

    19:Begin
	  fileName:=ScanPathSpr+StartClass+'.db';
       Pref:=ClassPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartClass+' ('+FileName+')');
       ReplicationClass(FileName,Pref);
       End;

    20:Begin
	  fileName:=ScanPathSpr+StartKassa+'.db';
       Pref:=KassaPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartKassa+' ('+FileName+')');
       ReplicationKassa(FileName,Pref);
       End;

    21:Begin
	  fileName:=ScanPathSpr+StartPersonal+'.db';
       Pref:=PersonalPrefix;
       If FindParam('/FULLINFO') Then AddLog(Log,'Обработка задачи '+StartPersonal+' ('+FileName+')');
       ReplicationPersonal(FileName,Pref);
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



 AddLog(Log,'Завершение сеанса обработки репликации справочников');
 {конец цикла основной работы}

 If ReplicationTasks[22]=1 Then{проверяем необходимость обработки}
 Begin
  AddLog(Log,'Старт сеанса обработки почтовых ящиков');


 {вытаскиваем все файлы из каталогов MailPathIn и ReplcationPath в MailRoot}

{
      For k:=1 To CMaxSklads Do
       Begin
        If (j<>k{сам себе) And (ReplicationPath[j]<>ReplicationPath[k]) Then
         Begin
          SKomu:=IntToStr(k,CMantissa);
          RFormatZerro(sKomu,CMantissa);
          MoveFiles(j,k,SKto,SKomu);
         End;
       End;
}

  AddLog(Log,'Старт фаза 1');

  For j:=1 To CMaxSklads Do
   Begin
    If ReplicationObject[j]=1 Then
     Begin
      If (ReplicationPath[j]<>MailRootPath){т.е. разные каталоги репликации} Then
      FastMoveFiles(ReplicationPath[j],MailRootPath);

      If (MailPathIn[j]<>MailRootPath){т.е. разные каталоги репликации} Then
      FastMoveFiles(MailPathIn[j],MailRootPath);
	End;{ReplicationObject[j]=1}
   End;{For j}

  AddLog(Log,'Завершение фаза 1');



{завершен первый этап}

  AddLog(Log,'Старт фаза 2');
  For j:=1 To CMaxSklads Do
   Begin
    If ReplicationObject[j]=1 Then
     Begin
       SKto:=IntToStr(j,CMantissa);
       RFormatZerro(sKto,CMantissa);
       For k:=1 To CMaxSklads Do
        begin
         If ReplicationObject[k]=1 Then
         If (j<>k) And (MailRootPath<>MailPathOut[k]) Then
         Begin
          SKomu:=IntToStr(k,CMantissa);
          RFormatZerro(sKomu,CMantissa);
          MoveFiles(j,k,SKto,SKomu);
         End;
        End;
	End;{ReplicationObject[j]=1}
   End;{For j}
  AddLog(Log,'Завершение фаза 2');

{завершен второй этап}


{копируем файлы общего назначения}

  AddLog(Log,'Завершение сеанса обработки почтовых ящиков');
 End;


 If ReplicationTasks[23]=1 Then{рассылаем пароли}
 Begin
  AddLog(Log,'Старт сеанса обработки базы паролей');

{копируем файлы общего назначения}

  For j:=1 To CMaxSklads Do
   Begin
    If ReplicationObject[j]=1 Then CopyPasswordBase(j);
   End;{For j}

  AddLog(Log,'Завершение сеанса обработки базы паролей');
 End;

 I:=IoResult;
 Close(Log);
 I:=IoResult;

End.