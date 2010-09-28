{$A+,B-,D-,E-,F-,G+,I-,L-,N+,P-,Q-,R-,S-,T-,V-,X+,Y-}
{$M 65520,0,655360 }
{$I Compile.INC}

{$DEFINE Converter}
{$DEFINE Pharm}

Uses Glob,Serv,Servstr,Servstr2,Utils,Utils5,Objects,StHolder,
     Dialogs,Utils1,Utils3,Mail,
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
ObjectKod    : String[CClientKod];
PathToRazdel : TMyString;
PathToSklad  : TMyString;
PathToSPR    : TMyString;
PathToSkidki : TMyString;
PathToId     : TMyString;
PathToIndex  : TMyString;
PathToZakaz   :TMyString;
PathToZakazIDX:TMyString;
PathToPredZakaz   :TMyString;
PathToPredZakazIDX:TMyString;
DefaultDivision:Word;
AutoZakaz:Word;
AutoAnswer:Word;
ShemaZakaz:Word;
End;








Type SkladTask =Record
     Task : Array [1..CMaxSklads] Of PathTaskElement;
     PathToClient : TMyString;
     PathToClientIDX:TMyString;
     PathToTemp   : TMyString;
     PathToUtils  : TMyString;
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



Procedure Beep;
Begin
Sound(300);
Delay(100);
NoSound;
End;


Procedure Beep1;
Begin
Sound(800);
Delay(200);
NoSound;
End;

Procedure Beep2;
Begin
Sound(1200);
Delay(300);
NoSound;
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
    IndexTasks: Array [1..CMaxTasks] Of Byte;{список задач подлежащих обработке}
    i,j : Word;
    Res : LongInt;
    Ini : Text;
    Log : Text;
    FileName : String;
    III : SkladTask;
    FClient : File;
    ClientPriceList,PriceList,ClientDolgList,AgentDolgList : PBox;
    R:TRect;


Procedure ClearIni;
VAr c : Word;
Begin
III.PathToClient[0]:=#0;
III.PathToClientIDX[0]:=#0;
III.PathToTemp[0]:=#0;
III.PathToUtils[0]:=#0;
For c:=1 To CMaxSklads Do
Begin
III.Task[c].ObjectKod[0]:=#0;
III.Task[c].PathToRazdel[0]:=#0;
III.Task[c].PathToSklad[0]:=#0;
III.Task[c].PathToSkidki[0]:=#0;
III.Task[c].PathToId[0]:=#0;
III.Task[c].PathToSPR[0]:=#0;
III.Task[c].PathToIndex[0]:=#0;
III.Task[c].PathToZakaz[0]:=#0;
III.Task[c].PathToZakazIDX[0]:=#0;
III.Task[c].PathToPredZakaz[0]:=#0;
III.Task[c].PathToPredZakazIDX[0]:=#0;
III.Task[c].AutoZakaz:=0;
III.Task[c].AutoAnswer:=0;
III.Task[c].ShemaZakaz:=0;
III.Task[c].DefaultDivision:=1;
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
Assign (f,'import.ini');
Res := IOResult;
Reset(f);
Res := IOResult;
If Res <> 0 Then Exit;
Close(f);
Res := IOResult;
SH.Init;
SH.LoadFromFile ('import.ini');

III.PathToClient[0]:=#0;
III.PathToClient:=GetAsString('ToClient');
DelSpaceRight(III.PathToClient);

III.PathToClientIDX[0]:=#0;
III.PathToClientIDX:=GetAsString('ToClientIDX');
DelSpaceRight(III.PathToClientIDX);

III.PathToTemp[0]:=#0;
III.PathToTemp:=GetAsString('ToTemp');
DelSpaceRight(III.PathToTemp);

III.PathToUtils[0]:=#0;
III.PathToUtils:=GetAsString('ToUtils');
DelSpaceRight(III.PathToUtils);



For c:=1 To CMaxSklads Do
Begin

III.Task[c].ObjectKod[0]:=#0;
III.Task[c].PathToRazdel[0]:=#0;
III.Task[c].PathToSklad[0]:=#0;
III.Task[c].PathToId[0]:=#0;
III.Task[c].PathToIndex[0]:=#0;
III.Task[c].PathToSkidki[0]:=#0;
III.Task[c].PathToZakaz[0]:=#0;
III.Task[c].PathToZakazIDX[0]:=#0;
III.Task[c].PathToPredZakaz[0]:=#0;
III.Task[c].PathToPredZakazIDX[0]:=#0;
III.Task[c].AutoZakaz:=0;
III.Task[c].AutoAnswer:=0;
III.Task[c].ShemaZakaz:=0;


III.Task[c].ObjectKod:=GetAsString('ObjectKod['+IntToStr(c,CMantissa)+']');

RFormatZerro(III.Task[c].ObjectKod,CClientKod);


III.Task[c].PathToRazdel:=GetAsString('ToRazdel['+IntToStr(c,CMantissa)+']');

DelSpaceRight(III.Task[c].PathToRazdel);

III.Task[c].PathToSklad:=GetAsString('ToSklad['+IntToStr(c,CMantissa)+']');
DelSpaceRight(III.Task[c].PathToSklad);


III.Task[c].PathToSkidki:=GetAsString('ToSkidki['+IntToStr(c,CMantissa)+']');
DelSpaceRight(III.Task[c].PathToSkidki);

III.Task[c].PathToSPR:=GetAsString('ToSPR['+IntToStr(c,CMantissa)+']');
DelSpaceRight(III.Task[c].PathToSPR);

III.Task[c].PathToID:=GetAsString('ToID['+IntToStr(c,CMantissa)+']');
DelSpaceRight(III.Task[c].PathToID);

III.Task[c].PathToIndex:=GetAsString('ToIndex['+IntToStr(c,CMantissa)+']');
DelSpaceRight(III.Task[c].PathToIndex);




III.Task[c].PathToZakaz:=GetAsString('ToZakaz['+IntToStr(c,CMantissa)+']');
DelSpaceRight(III.Task[c].PathToZakaz);


III.Task[c].PathToZakazIDX:=GetAsString('ToZakazIDX['+IntToStr(c,CMantissa)+']');
DelSpaceRight(III.Task[c].PathToZakazIDX);

III.Task[c].PathToPredZakaz:=GetAsString('ToPredZakaz['+IntToStr(c,CMantissa)+']');
DelSpaceRight(III.Task[c].PathToPredZakaz);


III.Task[c].PathToPredZakazIDX:=GetAsString('ToPredZakazIDX['+IntToStr(c,CMantissa)+']');
DelSpaceRight(III.Task[c].PathToPredZakazIDX);


III.Task[c].AutoZakaz:=GetAsInteger('AutoZakaz['+IntToStr(c,CMantissa)+']');

III.Task[c].AutoAnswer:=GetAsInteger('AutoAnswer['+IntToStr(c,CMantissa)+']');

III.Task[c].ShemaZakaz:=GetAsInteger('ShemaZakaz['+IntToStr(c,CMantissa)+']');

III.Task[c].DefaultDivision:=GetAsInteger('DefaultDivision['+IntToStr(c,CMantissa)+']');

If Not III.Task[c].DefaultDivision in [1..8] Then III.Task[c].DefaultDivision:=1;


End;

SH.Done;
End;



Procedure ShowHelp;
Begin
Writeln('Утилита импорта заказов клиентов в базу предзаказов '+CompileDate);
Writeln('Протокол операций '+ClearChar(FDAte)+'.log');
Writeln('Файл конфигурации import.ini');
Halt;
End;


function JustFilename(PathName : string) : string;
var
  I : Word;
begin
  JustFilename[0]:=#0;
  I := Succ(Word(Length(PathName)));
  repeat
    Dec(I);
  until (PathName[I] in ['\','/',':']) or (I = 0);
  JustFilename := Copy(PathName, Succ(I), 25);
end;






Function UnpackMailFileClient(FName:String;Var NewFName:String):boolean;
var ss,s:string;
    Result : LongInt;
    FName1 : String;
Begin
  UnpackMailFileClient:=False;
  NewFName:=JustFilename(FName);

  FName1:=FNAme;
  {каталог для хранения архива принятых сообщений}
  If Pos('\IN\',FName1)>0 Then System.Insert('\Arc',FName1,Pos('\IN\',FName1));

  s:=III.PathToUtils+'rar.exe e -inul -y -w'+III.PathToTemp+' '+
  FName+' '+
  III.PathToTemp+' >NUL';

  SWAPVECTORS;
  exec (GetEnv('Comspec'),' /C '+s);
  Result:=DosError;
  SWAPVECTORS;


  If FExists(III.PathToTemp+''+NewFName) Then
   Begin
    AddLog(Log,'Распаковка '+NewFName+' Ok');
    UnpackMailFileClient:=True;
   End
  Else
    Begin
    Beep;
    AddLog(Log,'Ошибка распаковки '+NewFName);
    End;

  s:='copy'+' '+FName+' '+FName1+' >NUL';

  SWAPVECTORS;
  exec (GetEnv('Comspec'),' /C '+s);
  Result:=DosError;
  SWAPVECTORS;


  If FExists(FName1) Then
   Begin
    AddLog(Log,'Копирование '+FName1+' Ok');
   End
  Else
   Begin
    Beep;
    AddLog(Log,'Ошибка копирования '+FName1);
   End;



End;


Function GetSkladRecord(ss:AllStr;Ok:Word;Var SklDan:PSkladType):Boolean;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
       c : ArtikulStr;
     fskl: SkladFileType;
Begin
 GetSkladRecord:=False;
 st:=SklDan^.Dat.BazKod;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fskl,III.Task[ok].PathToSklad+c+'.db');
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Beep;
  AddLog(Log,ss+'-ошибка открытия '+III.Task[ok].PathToSklad+c+'.db код:['+st+']');
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   If l>FileSize(fskl) Then
    Begin
     l:=IOResult;
     System.Close(fskl);
     l:=IOResult;
     Beep;
     AddLog(Log,ss+'- попытка чтения товара ('+st+') '+c+' для объекта '+IntToStr(Ok,CKol)+
	' - позиция вне файла!');
     Exit;
    End;

   Seek(fskl,L);
   ReadSkladPointer(FSkl,SklDan);
   Close(fskl);
   l:=IOResult;
   GetSkladRecord:=True;
  End;
End;



Function GetBazRecord(ss:AllStr;Ok:Word;Var SklDan:PBazType):Boolean;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
       c : ArtikulStr;
     fskl: BazFileType;
Begin
 GetBazRecord:=False;
 st:=SklDan^.Dat.BazKod;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fskl,III.Task[ok].PathToID+c+'.id');
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Beep;
  AddLog(Log,ss+'-ошибка открытия '+III.Task[ok].PathToID+c+'.id код:['+st+']');
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   If l>FileSize(fskl) Then
    Begin
     l:=IOResult;
     System.Close(fskl);
     l:=IOResult;
     Beep;
     AddLog(Log,ss+'- попытка чтения товара ('+st+') - id'+c+' для объекта '+IntToStr(Ok,CKol)+
	' - позиция вне файла!');
     Exit;
    End;

   Seek(fskl,L);
   ReadBazPointer(FSkl,SklDan);
   Close(fskl);
   l:=IOResult;
   GetBazRecord:=True;
  End;
End;



Function GetPostField(ss:AllStr;Ok:Word;Art:ArtikulStr):AllStr;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
       c : ArtikulStr;
     fskl: PostFileType;
     SklDan : PostType;
Begin
 GetPostField[0]:=#0;
 Assign(fskl,III.Task[ok].PathToSPR+'lands.db');
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Beep;
  AddLog(Log,ss+'-ошибка открытия '+III.Task[ok].PathToSPR+'lands.db код:['+st+']');
  Exit;
 End
 Else
  Begin
   L:=StrToInt(Art);
   If l>FileSize(fskl) Then
    Begin
     l:=IOResult;
     System.Close(fskl);
     l:=IOResult;
     Beep;
     AddLog(Log,ss+'- попытка чтения ('+st+') - lands.db  для объекта '+IntToStr(Ok,CKol)+
	' - позиция вне файла!');
     Exit;
    End;

   Seek(fskl,L);
   ReadPost(FSkl,SklDan);
   Close(fskl);
   l:=IOResult;
   GetPostField:=SklDan.Post;
  End;
End;


Function GetFirmaPostField(ss:AllStr;Ok:Word;Art:ArtikulStr):AllStr;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
       c : ArtikulStr;
     fskl: FirmaPostFileType;
     SklDan : FirmaPostType;
Begin
 GetFirmaPostField[0]:=#0;
 Assign(fskl,III.Task[ok].PathToSPR+'firma.db');
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Beep;
  AddLog(Log,ss+'-ошибка открытия '+III.Task[ok].PathToSPR+'firma.db код:['+st+']');
  Exit;
 End
 Else
  Begin
   L:=StrToInt(Art);
   If l>FileSize(fskl) Then
    Begin
     l:=IOResult;
     System.Close(fskl);
     l:=IOResult;
     Beep;
     AddLog(Log,ss+'- попытка чтения ('+st+') - firma.db  для объекта '+IntToStr(Ok,CKol)+
	' - позиция вне файла!');
     Exit;
    End;

   Seek(fskl,L);
   ReadFirmaPost(FSkl,SklDan);
   Close(fskl);
   l:=IOResult;
   GetFirmaPostField:=SklDan.FirmaPost;
  End;
End;


Function GetMarkaField(ss:AllStr;Ok:Word;Art:ArtikulStr):AllStr;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
       c : ArtikulStr;
     fskl: MarkaFileType;
     SklDan : MarkaType;
Begin
 GetMarkaField[0]:=#0;
 Assign(fskl,III.Task[ok].PathToSPR+'Marka.db');
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Beep;
  AddLog(Log,ss+'-ошибка открытия '+III.Task[ok].PathToSPR+'Marka.db код:['+st+']');
  Exit;
 End
 Else
  Begin
   L:=StrToInt(Art);
   If l>FileSize(fskl) Then
    Begin
     l:=IOResult;
     System.Close(fskl);
     l:=IOResult;
     Beep;
     AddLog(Log,ss+'- попытка чтения ('+st+') - Marka.db  для объекта '+IntToStr(Ok,CKol)+
	' - позиция вне файла!');
     Exit;
    End;

   Seek(fskl,L);
   ReadMarka(FSkl,SklDan);
   Close(fskl);
   l:=IOResult;
   GetMarkaField:=SklDan.Marka;
  End;
End;




Function GetClient(sf: AllStr;Var Cl : PClientType):Boolean;
Var f : ClientFileType;
    l : LongInt;
    s : ClientType;
    st : ArtikulStr;
    c,Code : Integer;
    ss : AllStr;
Begin

 GetClient:=False;
 Assign (f,III.PathToClient+'Client.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Beep;
  AddLog(Log,ss+'-ошибка открытия файла клиентов код:'+IntToStr(l,3));
  Exit;
 End
 Else
  Begin
   DelSpace(Cl^.DAt.Kod);
   l:=StrToInt(Cl^.DAt.Kod);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     c:=IOResult;
     Beep;
     AddLog(Log,ss+'попытка чтения клиента '+Cl^.DAt.Kod+' - позиция вне файла! Позиция:'+
	IntToStr(l,CKol)+'('+IntToStr(FileSize(f),CKol)+')');
     Exit;
    End;

   Seek(f,l);
   l:=IOResult;
   ReadClient(f,Cl^.DAt);
   l:=IOResult;
   Close(f);
   l:=IOResult;
   GetClient:=True;
  End;

  If Not(Cl^.Dat.Employ) Then
     Begin
      Beep;
      AddLog(Log,ss+'-клиент '+Cl^.Dat.Kod+' помечен удаленным');
      GetClient:=False;
      Exit;
     End;
End;




Function LockAndWritePredZakazI(ss:AllStr;Ok:Word;Var L:PPredZakazType):Boolean;
Var MarketFile : PredZakazFileType;
    HeaderFile : HeaderPredZakazFileType;
    c : Byte;
    Find : Boolean;
    Test : PPredZakazType;
    Er,Position,Code,Pos1,Pos2:LongInt;
    ChangeNumer : Boolean;
    Lh : PHeaderPredZakazType;
Begin
 LockAndWritePredZakazI:=False;
 Assign(MarketFile,III.Task[ok].PathToPredZakaz+'PZakaz.db');
 c:=IOResult;
{$I-}
 Reset(MarketFile);
 c:=IOResult;
 If c <> 0 Then Begin
                 Beep;
                 AddLog(Log,ss+'-нет доступа к файлу PZakaz.db код:'+IntToStr(c,CKol)+
			  '. Сообщение отложено');
                 Exit;
                End;


 Assign(HeaderFile,III.Task[ok].PathToPredZakazIDX+'PZakaz.idx');
 c:=IOResult;
{$I-}
 Reset(HeaderFile);
 c:=IOResult;

 If c <> 0 Then Begin
                 Beep;
                 AddLog(Log,ss+'-нет доступа к файлу PZakaz.idx код:'+IntToStr(c,CKol)+'. Сообщение отложено');
                 Close(MarketFile);
                 c:=IOResult;
                 Exit;
                End;

L^.Dat.Document:=IntToStr(FileSize(MarketFile)+1,CKOl);

   New(Lh,Init);
    PredZakazToIndex(L,Lh);
{если открытие прошло нормально}
    Begin
     {запись прихода для случая формирования накладной}
    Repeat

     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(MarketFile);
      Seek(MarketFile,Pos1);
     Until (Lock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType)));

     Pos1:=FileSize(MarketFile);

     If FilePos(MarketFile)<>Pos1{FileSize(MarketFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        UnLock(MarketFile,(FilePos(MarketFile))*SizeOf(PredZakazType),SizeOf(PredZakazType));
       Until (DosError=0);
      End;
    Until (FilePos(MarketFile)=Pos1);

{$IFDEF NetVersion}
     {что бы не блокировать логически новую запись}
     L^.Dat.Locked:=False;
{$ENDIF}

     If ((Pos1+1)<>(StrToInt(L^.Dat.Document))) Then
     Begin
      ChangeNumer:=True;
      L^.Dat.Document:=IntToStr(Pos1+1,CDocNumer);
      DelSpace(L^.Dat.Document);

      Dispose(Lh,Done);
      New(Lh,Init);
      PredZakazToIndex(L,Lh);
     End;

     Position:=FilePos(MarketFile);

     Er:=IOResult;
     Write(MarketFile,L^.DAt);
     Er:=IOResult;
     Seek(MarketFile,FilePos(MarketFile)-1);
     Er:=IOResult;

     {запись в idx file}
     Seek(HeaderFile,{FilePos(MarketFile)}Position);
     Er:=IOResult;
     Write(HeaderFile,Lh^.DAt);
     Er:=IOResult;
     {снятие блокировки}


     Repeat {деблокируем участок записи}
      UnLock(MarketFile,(FilePos(MarketFile))*SizeOf(PredZakazType),
      SizeOf(PredZakazType));
     {If DosError<>0 Then
       MessageBox(#3+'DosError='+IntToStr(DosError,3),Nil,
          mfError+mfCancelButton);}
     Until (DosError=0);

     c:=IOResult;
     Close(MarketFile);
     c:=IOResult;
     Close(HeaderFile);
     c:=IOResult;
     LockAndWritePredZakazI:=True;

    End;

c:=IOResult;
Dispose(Lh,Done);
c:=IOResult;

End;


Procedure EraseFile(ss:String);
Var c : Word;
    f : File;
Begin
Assign(f,ss);
c:=IoResult;
Erase(f);
c:=IoResult;
If c<>0 Then
Begin
 Beep1;
 AddLog(Log,ss+'-ошибка удаления код: '+IntToStr(c,CKol));
End;
End;



Procedure LoadMessages(S:String);
LAbel 43,44,45;
Var ss : TMyString;
    txt : Text;
    i : Byte;
    c : Byte;
    SH: TStringHolder;
    SHeader,SClientKod,
    SStatus,SObjectKod,LocSkidka : AllStr;
    Cl : PClientType;
    DeltaAmount : Word;
    LastAmount : Word;
    PZ : PPredZakazType;
    Skl    : PSkladType;
    SklDan : PBazType;
    f : File;
    LandStr : AllStr;
    Russia : Boolean;


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

Function GetAsReal(Name:AllStr):Real;
Begin
GetAsReal:=0;
GetAsReal:=StrToReal(SH.GetString (Name));
End;

Begin
 ss[0]:=#0;
 If Not UnpackMailFileClient(s{старое имя},ss{новое имя}) Then Exit;

Assign (txt,III.PathToTemp+ss);
Res := IOResult;
Reset(txt);
Res := IOResult;
If Res <> 0 Then
 Begin
  Beep;
  AddLog(Log,'ошибка открытия '+III.PathToTemp+ss+' код:'+IntToStr(Res,CKOl));
  Exit;
 End;
Close(txt);
Res := IOResult;
SH.Init;
SH.LoadFromFile (III.PathToTemp+ss);
{
(1.проверяем поле Header - что за сообщение (0-предзаказ))
(2.проверяем поле From - разрешена ли вообще загрузка для объекта)
(3.проверяем поле ClientKod - разрешена ли загрузка для выбранного клиента)
(4.проверяем поле Status - стоит ли статус отправки для )
}


SHeader:=GetAsString('Header');{предзаказ}
If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден заголовок. Сообщение отложено');
                     Goto 45;
                    End;

{это другая тематика а не предзаказ}
If StrToInt(SHeader)<>0 Then Goto 45;

SObjectKod:=GetAsString('SkladKod');{организация}
If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден SkladKod. Сообщение отложено');
                     Goto 45;
                    End;

If Not(StrToInt(SObjectKod) in [1..30]) Then
                    Begin
                     Beep;
                     AddLog(Log,ss+'- недопустимый код объекта '+SObjectKod+'. Сообщение отложено');
                     Goto 45;
                    End;

If III.Task[StrToInt(SObjectKod)].AutoZakaz=0 Then
                    Begin
                     Beep;
                     AddLog(Log,ss+'- автозаказы для объекта '+SObjectKod+' запрещены. Сообщение отложено');
                     Goto 45;
                    End;


SClientKod:=GetAsString('ClientKod');{клиент}
If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден ClientKod. Сообщение отложено');
                     Goto 45;
                    End;
RFormatZerro(SClientKod,CClientKod);

New(Cl,Init);
Cl^.Dat.Kod:=SClientKod;
If Not(GetClient(ss,Cl)) Then Goto 44;

If Cl^.Dat.Dopolnenie.Price=0 Then
                    Begin
                     Beep;
                     AddLog(Log,ss+'- автозаказы для клиента '+Cl^.Dat.Name+' ('+SClientKod+') запрещены. Сообщение отложено');
                     Goto 44;
                    End;

SStatus:=GetAsString('Status');{клиент}
If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден Status. Сообщение отложено');
                     Goto 44;
                    End;

If StrToInt(SStatus)<>2 Then
                    Begin
                     Beep;
                     AddLog(Log,ss+'- недопустимое значение Status='+IntToStr(StrToInt(SStatus),CKol)+'. Сообщение отложено');
                     Goto 44;
                    End;
DeltaAmount:=0;
LastAmount:=1;
New(PZ,Init);
Pz^.Dat.ClientKod:=SClientKod;
Pz^.Dat.SkladKod:=IntToStr(StrToInt(SObjectKod),CClientKod);
RFormatZerro(Pz^.Dat.SkladKod,CClientKod);
Pz^.Dat.Status:=4;{получен T-Mail}

Pz^.Dat.AgentKod:=GetAsString('AgentKod');{клиент}
If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден AgentKod. Сообщение отложено');
                     Goto 43;
                    End;

Pz^.Dat.ClientNumer:=GetAsInteger('ClientNumer');{номер у клиент}
If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден ClientNumer. Сообщение отложено');
                     Goto 43;
                    End;

Pz^.Dat.Date:=GetAsString('Date');{дата у клиента}
If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден Date. Сообщение отложено');
                     Goto 43;
                    End;

Pz^.Dat.DataOtpr:=GetAsString('DataOtpr');{дата у клиента}
If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден DataOtpr. Сообщение отложено');
                     Goto 43;
                    End;

DelSpace(Pz^.Dat.DataOtpr);


If (Pz^.Dat.DataOtpr[0]=#0) Or
   (DateStringToDate(DateMask,Pz^.Dat.DataOtpr)<DateStringToDate(DateMask,FDate)) Then
     Begin
      Beep;
      If Not FindParam('/PHARM') Then
	  Begin
        AddLog(Log,ss+'- дата отправки '+Pz^.Dat.DataOtpr+' меньше текущей. Сообщение отложено');
	   Goto 43;
       End
      Else
        Begin
         AddLog(Log,ss+'- дата отправки '+Pz^.Dat.DataOtpr+' меньше текущей заменяю на текущую');
         Pz^.Dat.DataOtpr:=FDate;

        End;
     End;

Pz^.Dat.DateEnd:=GetAsString('DateEnd');{дата у клиента}
If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден DateEnd. Сообщение отложено');
                     Goto 43;
                    End;

DelSpace(Pz^.Dat.DateEnd);
If Pz^.Dat.DateEnd[0]=#0 Then
                    Begin
                     Beep;
                     AddLog(Log,ss+'- параметр DateEnd не указан-устанавливаем срок доставки '+FDate);
                     Pz^.Dat.DateEnd:=FDate;
                    End;

If DateStringToDate(DateMask,Pz^.Dat.DateEnd)<DateStringToDAte(DateMask,FDate) Then
                    Begin
                     Beep;
                     AddLog(Log,ss+'- срок доставки заказа меньше текущей даты');
                    End;


Pz^.Dat.Amount:=GetAsInteger('Amount');{количество позиций}
If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден Amount. Сообщение отложено');
                     Goto 43;
                    End;

Pz^.Dat.DocSelector :=GetAsInteger('DocSelector');
Pz^.Dat.OperatorSelector :=GetAsInteger('OperatorSelector');
Pz^.Dat.OperatorSelector :=0;
Pz^.Dat.Versia :=1;
Pz^.Dat.ShkalaNumer:=GetAsInteger('ShkalaNumer');
Pz^.Dat.SkidkaSelector:=GetAsInteger('SkidkaSelector');
Pz^.Dat.DateConv:=0;
Pz^.Dat.TimeConv:=0;
Pz^.Dat.SendConfirmation:=0;


Pz^.Dat.Defizit:=GetAsInteger('Defizit');{недостача}
Pz^.Dat.Summa:=GetAsString('Summa');{сумма у клиента}
Pz^.Dat.SertifSumma:=GetAsString('SertifSumma');{сумма у клиента}
Pz^.Dat.Sf:=GetAsInteger('SF');{недостача}

If Pz^.Dat.Sf=1 Then Pz^.Dat.DocSelector:=6;

Pz^.Dat.Bn:=GetAsInteger('Bn');{недостача}
Pz^.Dat.Caption:='99';{системная учетная запись}

Pz^.Dat.Comment1:=GetAsString('Comment1');{сумма у клиента}
Pz^.Dat.Comment2:=GetAsString('Comment2');{сумма у клиента}
DelSpaceRight(Pz^.Dat.Comment2);

Pz^.Dat.Comment2:=Pz^.Dat.Comment2+' '+DAteToDateString(DateMask,GetAsInteger('PriceDate'));{сумма у клиента}
DelSpaceRight(Pz^.Dat.Comment2);



Pz^.Dat.Summa[0]:=#0;{будет уточнять исходя из текущего прайса}
Pz^.Dat.Skidka[0]:=#0;{будет уточнять исходя из текущего прайса}
Pz^.Dat.SertifSkidka[0]:=#0;{будет уточнять исходя из текущего прайса}
Pz^.Dat.SertifSumma[0]:=#0;{будет уточнять исходя из текущего прайса}
Pz^.Dat.Defizit:=0;
LocSkidka[0]:=#0;

AddLog(log,ss+'- старт обработки предзаказа');

If FindParam('/PHARM') Then
 Begin
  Pz^.Dat.DocSelector:=6;
  If Pz^.Dat.Bn=1 Then Pz^.Dat.DocSelector:=8;
 End;


For c:=1 To Pz^.Dat.Amount Do
 Begin
  Pz^.Dat.Element[c].BazKod:=GetAsString('Element['+IntToStr(c,CKol)+'].BazKod');{}
  RFormatZerro(Pz^.Dat.Element[c].BazKod,CArtikul);

If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден Element['+IntToStr(c,CKol)+'].BazKod. Сообщение отложено');
                     Goto 43;
                    End;

  Pz^.Dat.Element[c].Kol:=GetAsString('Element['+IntToStr(c,CKol)+'].Kol');{}
  DelSpace(Pz^.Dat.Element[c].Kol);

If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден Element['+IntToStr(c,CKol)+'].Kol. Сообщение отложено');
                     Goto 43;
                    End;

  Pz^.Dat.Element[c].NadoSertif:=GetAsInteger('Element['+IntToStr(c,CKol)+'].NadoSertif');{}

  Pz^.Dat.Element[c].DivisionNumber:=GetAsInteger('Element['+IntToStr(c,CKol)+'].Division');{}
  {III.Task[StrToInt(SObjectKod)].DefaultDivision;}

  If Not (Pz^.Dat.Element[c].DivisionNumber in [1..8]) Then
       Begin
        Writeln(Pz^.Dat.Element[c].DivisionNumber);
        Readln;
        Pz^.Dat.Element[c].DivisionNumber:=1;
        Beep1;
        AddLog(Log,ss+'- Element['+IntToStr(c,CKol)+'].Division. Не настроен номер отделения-приемника. Изменено на 1');
       End;


  Pz^.Dat.Element[c].Zena:=GetAsString('Element['+IntToStr(c,CKol)+'].Zena');
  DelSpace(Pz^.Dat.Element[c].Zena);

If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден Element['+IntToStr(c,CKol)+'].Zena. Сообщение отложено');
                     Goto 43;
                    End;

  New(Skl,Init);
  New(SklDan,Init);
  Skl^.Dat.BazKod:=Pz^.Dat.Element[c].BazKod;
  SklDan^.Dat.BazKod:=Pz^.Dat.Element[c].BazKod;

  AddLog(log,ss+'- определяем режим формирования цены');
  If Cl^.Dat.DisableControlMinNazenka=1 Then
  {разрешено формирование прайса от РЦ}
  Begin

  AddLog(log,ss+'- цены от РЦ');

  If GetSkladRecord(ss,StrToInt(SObjectKod),Skl) Then
    Begin
     If (StrToReal(Skl^.Dat.Input.R_Zena)*(1+StrToReal(Cl^.Dat.MinimalProz)/100)-
	    StrToReal(Pz^.Dat.Element[c].Zena)) > 0.009 Then
        Begin
         If Not FindParam('/NOEDIT') Then
         Begin
         Beep1;
         AddLog(log,ss+'-недостоверная цена для '+Pz^.Dat.Element[c].BazKod+'-'+
         Pz^.Dat.Element[c].Zena+' заменена на '+ RealToStr(
	    StrToReal(Skl^.Dat.Input.R_Zena)*(1+StrToReal(Cl^.Dat.MinimalProz)/100),CZena,CMantissa));
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)*(1+StrToReal(Cl^.Dat.Dopolnenie.Proz)/100),
	    CZena,CMantissa,Pz^.Dat.Element[c].Zena);
         End
          Else
		 Begin
            AddLog(log,ss+'-недостоверная цена для '+Pz^.Dat.Element[c].BazKod+'-'+
            Pz^.Dat.Element[c].Zena);
           End;
        End;
       {предварительная цена}
       Pz^.Dat.Element[c].Zakupka:=StrToReal(Skl^.Dat.Input.Zakupka);
       {предварительная скидка}
       Pz^.Dat.Element[c].Skidka:=StrToReal(Skl^.Dat.Input.R_Zena)-StrToreal(Pz^.Dat.Element[c].Zena);
    End
    Else
       Begin
         Dispose(Skl,Done);
         Dispose(SklDan,Done);
         Beep;
         AddLog(log,ss+'-не могу проверить цену и подсчитать закупку для '+Pz^.Dat.Element[c].BazKod+'. Сообщение отложено');
         Goto 43;
       End;
  End
  Else
 Begin
   AddLog(log,ss+'- цены от ЗЦ');

  If GetBazRecord(ss,StrToInt(SObjectKod),SklDan) Then
    Begin
     LandStr:=GetPostField(ss,StrToInt(SObjectKod),SklDan^.Dat.PostKod);
    End
    Else
     Begin
      Beep;
      AddLog(log,ss+'-не могу проверить страну происхождения '+
	 SklDan^.Dat.PostKod+' для '+Pz^.Dat.Element[c].BazKod+'. Ипользую страна "Россия"');
      LandStr:='РОССИЯ';
     End;

  If (Pos('РОССИЯ',LandStr)>0) Or
     (Pos('БЕЛАРУСЬ',LandStr)>0) Or
     (Pos('УКРАИНА',LandStr)>0) Or
     (Pos('ЭСТОНИЯ',LandStr)>0) Or
     (Pos('АРМЕНИЯ',LandStr)>0) Or
     (Pos('ЛАТВИЯ',LandStr)>0) Or
     (Pos('ЛИТВА',LandStr)>0)  Then Russia:=True
  Else Russia:=False;

  If GetSkladRecord(ss,StrToInt(SObjectKod),Skl) Then
    Begin

     If (Russia And((StrToReal(Skl^.Dat.Input.R_Zena)*StrToReal(Cl^.Dat.Dopolnenie.Proz)-
	    StrToReal(Pz^.Dat.Element[c].Zena)) > 0.009))
	   Or

        (Not Russia And((StrToReal(Skl^.Dat.Input.R_Zena)*StrToReal(Cl^.Dat.Dopolnenie.ProzImport)-
	    StrToReal(Pz^.Dat.Element[c].Zena)) > 0.009))


	     Then
        Begin
         Beep1;
         If Not FindParam('/NOEDIT') Then
         Begin
         If Russia Then
          Begin
           AddLog(log,ss+'-недостоверная цена для '+Pz^.Dat.Element[c].BazKod+'-'+
           Pz^.Dat.Element[c].Zena+' заменена на '+ RealToStr(
   	      StrToReal(Skl^.Dat.Input.Zakupka)*StrToReal(Cl^.Dat.Dopolnenie.Proz),CZena,CMantissa));
           MyStr(StrToReal(Skl^.Dat.Input.Zakupka)*StrToReal(Cl^.Dat.Dopolnenie.Proz),
   	      CZena,CMantissa,Pz^.Dat.Element[c].Zena);
          End
           Else
            Begin
           AddLog(log,ss+'-недостоверная цена для '+Pz^.Dat.Element[c].BazKod+'-'+
           Pz^.Dat.Element[c].Zena+' заменена на '+ RealToStr(
   	      StrToReal(Skl^.Dat.Input.Zakupka)*StrToReal(Cl^.Dat.Dopolnenie.ProzImport),CZena,CMantissa));
           MyStr(StrToReal(Skl^.Dat.Input.Zakupka)*StrToReal(Cl^.Dat.Dopolnenie.ProzImport),
   	      CZena,CMantissa,Pz^.Dat.Element[c].Zena);
            End;
         End
          Else
           Begin{режим информирования о расхождении}
            If Russia Then
             AddLog(log,ss+'-недостоверная цена для '+Pz^.Dat.Element[c].BazKod+'-'+
             Pz^.Dat.Element[c].Zena+' должна быть '+ RealToStr(
   	        StrToReal(Skl^.Dat.Input.Zakupka)*StrToReal(Cl^.Dat.Dopolnenie.Proz),CZena,CMantissa))
            Else
             AddLog(log,ss+'-недостоверная цена для '+Pz^.Dat.Element[c].BazKod+'-'+
             Pz^.Dat.Element[c].Zena+' должна быть '+ RealToStr(
             StrToReal(Skl^.Dat.Input.Zakupka)*StrToReal(Cl^.Dat.Dopolnenie.ProzImport),CZena,CMantissa));
           End;
        End;
       {предварительная цена}
       Pz^.Dat.Element[c].Zakupka:=StrToReal(Skl^.Dat.Input.Zakupka);
       {предварительная скидка}
       Pz^.Dat.Element[c].Skidka:=StrToReal(Skl^.Dat.Input.R_Zena)-StrToreal(Pz^.Dat.Element[c].Zena);
    End
    Else
       Begin
         Dispose(Skl,Done);
         Dispose(SklDan,Done);
         Beep;
         AddLog(log,ss+'-не могу проверить цену и подсчитать закупку для '+Pz^.Dat.Element[c].BazKod+'. Сообщение отложено');
         Goto 43;
       End;

  End;

  MyStr(StrToReal(Pz^.Dat.Summa)+
        StrToReal(Pz^.Dat.Element[c].Zena)*StrToInt(Pz^.Dat.Element[c].Kol),CIZena,CMantissa,
	   Pz^.Dat.Summa);

  MyStr(StrToReal(Pz^.Dat.Skidka)+
       ((StrToReal(Skl^.Dat.Input.R_Zena))
	  -StrToReal(Pz^.Dat.Element[c].Zena))*StrToInt(Pz^.Dat.Element[c].Kol),CIZena,CMantissa,
       Pz^.Dat.Skidka);


  Dispose(Skl,Done);
  Dispose(SklDan,Done);

 End;{For}


{заказ сформирован его необходимо сохранить}
If LockAndWritePredZakazI(ss,StrToInt(SObjectKod),Pz) Then
 Begin
   Beep2;
   AddLog(Log,ss+'-успешно преобразован в предзаказ '+Pz^.Dat.Document+' от '+
   DateToDateString(DateMask,Pz^.Dat.DateC));
   EraseFile(s);{уничтожаем архив в TMail}
 End;



43:
Dispose(PZ,Done);

44:
Dispose(Cl,Done);

45:

EraseFile(III.PathToTemp+ss);{уничтожаем распакованный текстовый файл PathToTemp}

SH.Done;



End;




Procedure ScanCatalog(Const V:PBox);
Var P : PBox;
    R : TRect;
    s,s1 : String;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
    c : Word;
Begin
R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));
DosError:=0;

{сканируем каталоги пользователей}
AddLog(Log,'Сканирую почтовые каталоги пользователей');

For c:=0 To V^.List^.Count-1 Do
Begin
 s1:=Copy(V^.GetText(c,V^.List^.Count),1+1+CClientKod+1,250);
 DelSpace(s1);
 FindFirst(s1+'IN\'+PredZakazPrefix+'*.*', AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=s1+'IN\'+DirInfo.Name;
   If Not HiddenAttribute(s) Then
    Begin
     P^.List^.Insert(NewStr(s));
     P^.SetRange(P^.List^.Count);
    End;
   FindNext(DirInfo);
 end;{While}
End;{For}

AddLog(Log,'Сканирование каталогов входящей почты завершено');

If P^.List^.Count>0 Then
 Begin
  AddLog(Log,'Обнаружено входящих сообщений:'+IntToStr(P^.List^.Count,CKol));
 End;

If P^.List^.Count>0 Then
 Begin
  For c:=0 To P^.List^.Count-1 Do
   Begin
    s:=P^.GetText(c,P^.List^.Count);
    LoadMessages(S);
   End;
 End
 Else
  AddLog(Log,'Не обнаружено входящих сообщений');

Dispose(P,Done);
End;


Procedure ReadPredZakaz(Var F : PredZakazFileType;Var Element:PPredZakazType);
Var IO : Byte;
    Pos:LongInt;
Begin
Pos:=FilePos(f);
 IO:=IOResult;
 Read(f,Element^.Dat);
 IO:=IOResult;
If IO<>0 Then
Begin
{$IFDEF NetVersion}
 Pos:=FilePos(f);
 IO:=IOResult;

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*PredZakazSize,PredZakazSize);
{$ENDIF}

 IO:=IOResult;
  Read(f,Element^.DAt);
 IO:=IOResult;
{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*PredZakazSize,PredZakazSize);
 Until DosError=0;
{$ENDIF}
End;

End;


Function TestElement (Const S : String;Const P : PBox) : Boolean;
Var ls : Word;
    k  : Byte;
    st : String;
Begin
TestElement:=True;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
k:=Pos('│',St);
ST:=Copy(St,K+1,CArtikul);
If St=S Then
   Begin
    TestElement:=False;
    Break;
   End;
End;
End;


Function Location(Const P:PBox;Const s:ArtikulStr;b:Boolean):Word;
Var w,i: Word;
    st : String;
Begin
location:=0;
For i:=0 To P^.List^.Count Do
  Begin
  Location:=i;
  st:=P^.GetText(i,P^.List^.Count);
  If Not(b) Then w:=Pos('│',st)
  Else w:=0;
  st:=Copy(st,w+1,CArtikul);
  If St=s Then Break;
  End;
  If not(st=s) Then
  Begin
   Location:=0;
   Beep;
   AddLog(Log,'Внимание! Элемент ('+s+') в списке не найден!');
  End;
End;






Function StoreMessages(Pz:PPredZakazType;Ok:Word;S1:TMyString):Boolean;
Var t : Text;
    NameFile:String;
    NameFile1:String;
    Ass : DocumentEditZ;
    s : String;
    Res : LongInt;
    SklPost : ArtikulStr;
    BBB : PBazType;
    Skl : PSkladType;
Begin
StoreMessages:=False;
SklPost:=IntToStr(StrToInt(Pz^.Dat.SkladKod),CClientKod);
Ass.EditPosition:=Pz^.Dat.Document;
Ass.D:=DAteToDateString(DAteMask,Pz^.Dat.DateC);
NameFile:=GetExportFileNameClientConfirmation(Ass,SklPost);

Assign(t,III.PathToTemp+NameFile);
Res:=IOResult;
Rewrite(t);
Res:=IOResult;
If Res<>0 Then
  Begin
   Beep;
   AddLog(Log,' ошибка создания '+III.PathToTemp+NameFile+' для объекта '+IntToStr(ok,CKOl)
   +' код:'+IntToStr(Res,CKol));
   Exit;
  End;

{записываем теги предзаказа}
Writeln(t,'Header=0');
with Pz^.DAt do
begin
 Writeln(t,'ClientKod=',ClientKod);
 Writeln(t,'SkladKod=',SkladKod);
 Writeln(t,'AgentKod=',AgentKod);
 Writeln(t,'DocSelector=',DocSelector);
 Writeln(t,'OperatorSelector=',OperatorSelector);
 Writeln(t,'Versia=',Versia);
 Writeln(t,'ShkalaNumer=',ShkalaNumer);
 Writeln(t,'SkidkaSelector=',SkidkaSelector);
 Writeln(t,'ClientNumer=',ClientNumer);
 Writeln(t,'Document=',Document);
 Writeln(t,'Date=',Date);
 DelSpace(Summa);
 Writeln(t,'Summa=',Summa);
 DelSpace(SertifSumma);
 Writeln(t,'SertifSumma=',SertifSumma);
 DelSpace(Skidka);
 Writeln(t,'Skidka=',Skidka);
 DelSpace(SertifSkidka);
 Writeln(t,'SertifSkidka=',SertifSkidka);
 DelSpace(DataOtpr);
 Writeln(t,'DataOtpr=',DataOtpr);
 Writeln(t,'AmountP=',Amount);
 Writeln(t,'Amount=',Amount);
 Writeln(t,'DateC=',DateC);
 Writeln(t,'TimeC=',TimeC);
 Writeln(t,'DateM=',DateM);
 Writeln(t,'TimeM=',TimeM);
 Writeln(t,'DateConv=',DateConv);
 Writeln(t,'TimeConv=',TimeConv);
 Writeln(t,'Defizit=',Defizit:CKol);
 Writeln(t,'Status=',Status:CKol);
 Writeln(t,'ZakazNumer=',ZakazNumer:CKol);
 Writeln(t,'Rezerv=',Rezerv);
 Writeln(t,'SendConfirmation=',SendConfirmation:CKOl);
 Writeln(t,'DateConfirmation=',DateConfirmation);
 Writeln(t,'TimeConfirmation=',TimeConfirmation);
 Writeln(t,'DateEnd=',DateEnd);
 Writeln(t,'Comment1=',Comment1);
 Writeln(t,'Comment2=',Comment2);
 if DocSelector in [6,8] then
   Writeln(t,'sf=1')
 else  Writeln(t,'sf=0') ;
 if (DocSelector in [4,8]) then
   Writeln(t,'BN=1')
  else  Writeln(t,'BN=0');

 for i:=1 to Amount do
 begin
  Writeln(t,'ElementP[',i,'].BazKod=',Element[i].BazKod);
  DelSpace(Element[i].Kol);
  Writeln(t,'ElementP[',i,'].DivisionNumber=',Element[i].DivisionNumber);
  Writeln(t,'ElementP[',i,'].Kol=',Element[i].Kol:CKOl);
  DelSpace(Element[i].Zena);
  Writeln(t,'ElementP[',i,'].Zena=',Element[i].Zena);
  Writeln(t,'ElementP[',i,'].Fakt=',Element[i].Fakt:CKol);
  Writeln(t,'ElementP[',i,'].NadoSertif=',Element[i].NadoSertif);


  New(BBB,Init);
  BBB^.Dat.BazKod:=Element[i].BazKod;
  If Not GetBazRecord('',Ok,BBB) Then
   Begin
    Dispose(BBB,Done);
    Res:=IOResult;
    Close(t);
    Res:=IOResult;
    Exit;
   End;


  New(Skl,Init);
  Skl^.Dat.BazKod:=Element[i].BazKod;
  If Not GetSkladRecord('',Ok,Skl) Then
   Begin
    Dispose(BBB,Done);
    Dispose(Skl,Done);
    Res:=IOResult;
    Close(t);
    Res:=IOResult;
    Exit;
   End;

{
  Writeln(bbb^.Dat.PostKod);
  Writeln(bbb^.Dat.FirmaPostKod);
  Writeln(Skl^.Dat.Input.Marka);
}

  Writeln(t,'ElementP[',i,'].Name=',BBB^.Dat.Name,' ',BBB^.Dat.Name2);
  Writeln(t,'ElementP[',i,'].Godnost=',Skl^.Dat.Input.Godnost);
  Writeln(t,'ElementP[',i,'].ZenaGR=',Skl^.Dat.Input.GRZena);
  Writeln(t,'ElementP[',i,'].Post=',GetPostField('',Ok,BBB^.Dat.PostKod));
  Writeln(t,'ElementP[',i,'].Firma=',GetFirmaPostField('',Ok,BBB^.Dat.FirmaPostKod));
  Writeln(t,'ElementP[',i,'].Marka=',GetMarkaField('',Ok,Skl^.Dat.Input.Marka));

  Dispose(BBB,Done);

  New(BBB,Init);
  BBB^.Dat.BazKod:=Skl^.Dat.Input.NSertif;
  If Not GetBazRecord('',Ok,BBB) Then
   Begin
    Dispose(BBB,Done);
    Res:=IOResult;
    Close(t);
    Res:=IOResult;
    Exit;
   End;

  Writeln(t,'ElementP[',i,'].Sertif=',BBB^.Dat.Name,' ',BBB^.Dat.Name2);

  Dispose(BBB,Done);
  Dispose(Skl,Done);



 end;
End;{With}

{закрываем файл}
Res:=IOResult;
Close(t);
Res:=IOResult;


  s:=III.PathToUtils+'rar.exe a -inul -y -m5 -ep -ep1 -w'+III.PathToTemp+' '+
  s1+NameFile+' '+III.PathToTemp+NameFile+' >NUL ';


  NameFile1:=s1+NameFile;
  If Pos('\OUT\',NameFile1)>0 Then System.Insert('\Arc',NameFile1,Pos('\OUT\',NameFile1));

  SWAPVECTORS;
  exec (GetEnv('Comspec'),' /C '+s);
  Res:=DosError;
  SWAPVECTORS;

  If FExists(s1+NameFile) Then
   Begin
    AddLog(Log,'Упаковка '+NameFile+' Ok');
    StoreMessages:=True;
   End
  Else
   Begin
    Beep;
    AddLog(Log,'Ошибка упаковки '+NameFile);
   End;


  s:='copy'+' '+s1+NameFile+' '+NameFile1+' >NUL';

  SWAPVECTORS;
  exec (GetEnv('Comspec'),' /C '+s);
  Res:=DosError;
  SWAPVECTORS;

  If FExists(NameFile1) Then
   Begin
    AddLog(Log,'Копирование '+NameFile1+' Ok');
   End
  Else
   Begin
    Beep;
    AddLog(Log,'Ошибка копирования '+NameFile1);
   End;


{EraseFile(III.PathToTemp+NameFile);}

End;




Procedure ScanConfirmation(Const P:PBox);
Var R : TRect;
    s,s1 : String;
    Res,j,c : Word;
    zz,Pos : LongInt;
    f : PredZakazFileType;
    Kdx : PHeaderPredZakazType;
    fkdx : File Of HeaderPredZakazType;
    Txt : Text;
    Start : String;
    PZ : PPredZakazType;
Begin

{бежим по массиву объектов}
For j:=1 To CMaxSklads Do
Begin
 {разрешен ли отклик для объекта}
 If III.Task[j].AutoAnswer=1 Then
 Begin
  Assign(txt,III.Task[j].PathToZakaz+'pzakaz.gid');
  Res:=IOResult;
  Reset(txt);
  Res:=IOResult;
  If Res<>0 Then
    Begin
     Beep;
     AddLog(Log,' ошибка открытия '+III.Task[j].PathToZakaz+'pzakaz.gid для объекта:'+IntToStr(j,CKOl)+
	' Код:'+IntToStr(Res,CKol)+'');
     Continue;
    End;

  Readln(txt,Start);
  i:=IOResult;
  System.Close(Txt);
  i:=IOResult;

  Assign(f,III.Task[j].PathToZakaz+'pzakaz.db');
  Res:=IOResult;
  Reset(f);
  Res:=IOResult;
  If Res<>0 Then
    Begin
     Beep;
     AddLog(Log,' ошибка открытия '+III.Task[j].PathToZakaz+'pzakaz.db для объекта:'+IntToStr(j,CKOl)+
	' Код:'+IntToStr(Res,CKol)+'');
     Continue;
    End;


  Assign(fkdx,III.Task[j].PathToZakazIDX+'pzakaz.idx');
  Res:=IOResult;
  Reset(fkdx);
  Res:=IOResult;
  If Res<>0 Then
    Begin
     i:=IOResult;
     Close(fkdx);
     i:=IOResult;
     Beep;
     AddLog(Log,' ошибка открытия '+III.Task[j].PathToZakazIDX+'pzakaz.idx для объекта:'+IntToStr(j,CKOl)+
	' Код:'+IntToStr(Res,CKol)+'');
     Continue;
    End;

If (FileSize(F)<StrToInt(Start)) Or (FileSize(FKDx)<StrToInt(Start)) Then Start:='0';

If (StrToInt(Start)-250)>=0 Then
Begin
Seek(F,StrToInt(Start)-250);
Seek(FKdx,StrToInt(Start)-250);
Start:=IntToStr(StrToInt(Start)-250,CKOl);
End
Else
 Begin
  Seek(F,StrToInt(Start));
  Seek(FKdx,StrToInt(Start));
 End;



 While Not(Eof(f)) Do
  Begin
   {бежим по списку}
   New(PZ,Init);
   New(Kdx,Init);
   i:=IOResult;
   ReadPredZakaz(f,Pz);
   i:=IOResult;
   Read(fKdx,Kdx^.Dat);
   i:=IOResult;

{   WriteLn(Pz^.Dat.Locked,' ',Pz^.Dat.Status,' ',Pz^.Dat.SendConfirmation);}


   If Not Pz^.Dat.Locked Then{не заблокирован заказ}
   If Pz^.Dat.Status in [5,6] Then{оформлен заказ}
    If Pz^.Dat.SendConfirmation=1 Then {если подтверждение не отправлено}
    Begin

      {поиск по списку клиентов}
      If Not TestElement(Pz^.Dat.ClientKod+'│',P) Then
      {элемент найден}
       Begin
        zz:=Location(P,Pz^.Dat.ClientKod+'│',False);
        s1:=Copy(P^.GetText(zz,P^.List^.Count),1+1+CClientKod+1,250);
        DelSpace(s1);
        s1:=s1+'OUT\';{сгенерировали путь к каталогу исходящей почты}
        AddLog(Log,'Обнаружен готовый к отправке предзаказ N '+Pz^.Dat.Document+' (клиент:'+Pz^.Dat.ClientKod+') '+
	   ' объект '+IntToStr(j,CKOl));

        Pz^.Dat.SendConfirmation:=2;
        Pz^.Dat.DateConfirmation:=DateStringToDate(DateMask,FDate);
        Pz^.Dat.TimeConfirmation:=TimeStringToTime(TimeMask,Times);
        Kdx^.Dat.SendConfirmation:=2;
        Kdx^.Dat.DateConfirmation:=DateStringToDate(DateMask,FDate);
        Kdx^.Dat.TimeConfirmation:=TimeStringToTime(TimeMask,Times);

        If StoreMessages(Pz,j,s1) Then{если выгрузка прошла успешно тогда взводим флаги}
         Begin
          Seek(f,FilePos(f)-1);
          Seek(fkdx,FilePos(fkdx)-1);
          i:=IOResult;
          Write(F,Pz^.Dat);
          i:=IOResult;
          Write(FKdx,Kdx^.Dat);
          i:=IOResult;
          Beep2;
          AddLog(Log,' экспорт подтверждения для предзаказа '+Pz^.Dat.Document+' для объекта '+
          IntToStr(j,CKol)+' успешно завершен');
         End;
       End;
      {если клиент есть тогда экспортруем упаковываем и меням статус}
    End;

   Dispose(PZ,Done);
   Dispose(Kdx,Done);
  End;{Eof(f)}

  i:=IOResult;
  Close(F);
  i:=IOResult;
  Close(FKdx);
  i:=IOResult;
 End;{AutoAnswer[j]=1}

End;{цикл по объектам}

{если отклик(пожтверждение) разрешен }
{открываем Pzakaz.gid и Seek уемся по нему}
{открываем Pzakaz.db и Pzakaz.Idx}
{бежим по базе заказов смотрим поле SendConfirmation=1}
{экспортируем из него в текстовый файл}
{упаковываем его и лишь только подтвердив упаковку вносим изменения в
 pzakaz.db и pzakaz.idx SendConfirmation:=2 DateConfirmation,TimeConfirmation}
{сигнализируем об успешном экспорте в лог и на экран}
{все здипец}


End;





Procedure ScanBase;
Var c,Count : Word;
    Cl : PBufClientType;
    V:PBox;
    R : TRect;
    s : String;
Begin

Assign(FClient,III.PathToClient+'client.db');
count:=IOResult;
Reset(FClient,SizeOf(ClientType));
count:=IOResult;
If Count<>0 Then
 Begin
  Beep;
  AddLog(Log,'Ошибка открытия '+III.PathToClient+'client.db');
  AddLog(Log,'Аварийное завершение');
  Exit;
 End;

R.Assign(0,0,0,0);
V := New(PBox, Init(R, 1, Nil));
V^.NewList(New(PTextCollection, Init(0,1)));


AddLog(Log,'Сканирую базу клиентов');
While Not(Eof(FClient)) Do
 Begin
  New(Cl,Init);
  ReadBufClient(FClient,Cl,Count);
  For c:=1 To Count Do
   Begin
    If Cl^.Point.Dat[c].Employ Then
     Begin
      DelSpace(Cl^.Point.Dat[c].Kod);
      RFormatZerro(Cl^.Point.Dat[c].Kod,CClientKod);
      If (Cl^.Point.Dat[c].Dopolnenie.Price=1) Then {разрешить генерацию прайса}
	  Begin
        s:='│'+Cl^.Point.Dat[c].Kod+'│'+Cl^.Point.Dat[c].Dopolnenie.MailPath+Cl^.Point.Dat[c].Kod+'\';
        V^.List^.Insert(NewStr(s));
        V^.SetRange(V^.List^.Count);
	  End;
     End;
   End;
  Dispose(Cl,Done);
  count:=IOResult;
 End;

count:=IOResult;
System.Close(FClient);
count:=IOResult;

AddLog(Log,'Сканирование базы клиентов завершено ('+IntToStr(V^.List^.Count,CKol)+' клиентов)');

If V^.List^.Count>0 Then
 Begin
  ScanCatalog(V);
 End;


{Writeln(V^.List^.Count);}
If V^.List^.Count>0 Then
 Begin
  AddLog(Log,'Сканирую исходящую почту');
  ScanConfirmation(V);
  AddLog(Log,'Сканирование исходящей почты завершено');
 End;

Dispose(V,Done);



End;










(*************    О С Н О В Н А Я    П Р О Г Р А М М А        ***********)

Begin
 FileMode:=66;
 If FindParam('/?') Then
  Begin
   ShowHelp;
   Exit;
  End;

 ClearIni;

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

 Assign(Ini,'import.ini');
 j:=IoResult;
 Reset(Ini);
 j:=IoResult;
 If j<>0 Then
  Begin
   Writeln('Ошибка открытия ini-файла');
   Beep;
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
   Beep;
   AddLog(Log,'Ошибка чтения ini-файла');
   AddLog(Log,'Аварийное завершение');
   j:=IoResult;
   Close(Log);
   j:=IoResult;
   Exit;
  End;


 ScanBase;


 AddLog(Log,'Завершение автоматического обработчика');
 {конец цикла основной работы}

 I:=IoResult;
 Close(Log);
 I:=IoResult;



End.

(*
 {FExpand.PAS}

{ Example for FExpand and FSearch }
Var s : String;

begin
  S := FSearch('TURBO.EXE',GetEnv('PATH'));
  if S = '' then
    WriteLn('TURBO.EXE not found')
  else
    { Show full path }
    WriteLn('Found as ',FExpand(S));
end.
*)



