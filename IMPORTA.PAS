{$A+,B-,D-,E-,F-,G+,I-,L-,N+,P-,Q-,R-,S-,T-,V-,X+,Y-}
{$M 65520,0,655360 }
{$I Compile.INC}

{$DEFINE Converter}

Uses Glob,Serv,Servstr,Servstr2,Utils,Utils5,Objects,StHolder,
     Dialogs,Utils1,Utils3,Mail,Protect,Access4,
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


Type TMyString = String[150];

Type PathTaskElement = Record
ObjectKod    : String[CClientKod];
PathToRazdel : TMyString;
PathToSklad  : TMyString;
PathToSkidki : TMyString;
PathToId     : TMyString;
PathToIndex  : TMyString;
PathToZakaz   :TMyString;
PathToZakazIDX:TMyString;
PathToPredZakaz   :TMyString;
PathToPredZakazIDX:TMyString;
PathToTemp : TMyString;
DefaultDivision:Word;
AutoZakaz:Word;
AutoAnswer:Word;
AutoOstatki:Word;
ShemaZakaz:Word;
End;



Type SkladTask =Record
     Task : Array [1..CMaxSklads] Of PathTaskElement;
     PathToClient : TMyString;
     PathToClientIDX:TMyString;
     PathToSystem : TMyString;
     PathToTemp   : TMyString;
     PathToSPR    : TMyString;
     PathToUtils  : TMyString;
     ListFile  : TMyString;
     FirstLockKod : Array [1..4] Of ArtikulStr;
     End;



Var CalcOst : Array[1..CMaxSklads] Of Boolean;



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
    i,j : Word;
    Res : LongInt;
    Ini : Text;
    Log : Text;
    III : SkladTask;


Procedure ClearIni;
VAr c : Word;
Begin
III.PathToClient[0]:=#0;
III.PathToClientIDX[0]:=#0;
III.PathToTemp[0]:=#0;
III.PathToUtils[0]:=#0;
III.ListFile[0]:=#0;
III.PathToSPR[0]:=#0;
III.PathToSystem[0]:=#0;
III.FirstLockKod[1,0]:=#0;
III.FirstLockKod[2,0]:=#0;
III.FirstLockKod[3,0]:=#0;
III.FirstLockKod[4,0]:=#0;

For c:=1 To CMaxSklads Do
Begin
CalcOst[c]:=False;
III.Task[c].ObjectKod[0]:=#0;
III.Task[c].PathToRazdel[0]:=#0;
III.Task[c].PathToSklad[0]:=#0;
III.Task[c].PathToSkidki[0]:=#0;
III.Task[c].PathToId[0]:=#0;
III.Task[c].PathToIndex[0]:=#0;
III.Task[c].PathToZakaz[0]:=#0;
III.Task[c].PathToZakazIDX[0]:=#0;
III.Task[c].PathToPredZakaz[0]:=#0;
III.Task[c].PathToPredZakazIDX[0]:=#0;
III.Task[c].PathToTemp[0]:=#0;
III.Task[c].AutoZakaz:=0;
III.Task[c].AutoOstatki:=0;
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
Assign (f,'importa.ini');
Res := IOResult;
Reset(f);
Res := IOResult;
If Res <> 0 Then Exit;
Close(f);
Res := IOResult;
SH.Init;
SH.LoadFromFile ('importa.ini');

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

III.PathToSPR[0]:=#0;
III.PathToSPR:=GetAsString('ToSPR');
DelSpaceRight(III.PathToSPR);


III.PathToSystem[0]:=#0;
III.PathToSystem:=GetAsString('ToSystem');
DelSpaceRight(III.PathToSystem);

III.FirstLockKod[1,0]:=#0;
III.FirstLockKod[1]:=GetAsString('FirstLockKod[1]');
DelSpaceRight(III.FirstLockKod[1]);

III.FirstLockKod[2,0]:=#0;
III.FirstLockKod[2]:=GetAsString('FirstLockKod[2]');
DelSpaceRight(III.FirstLockKod[2]);

III.FirstLockKod[3,0]:=#0;
III.FirstLockKod[3]:=GetAsString('FirstLockKod[3]');
DelSpaceRight(III.FirstLockKod[3]);

III.FirstLockKod[4,0]:=#0;
III.FirstLockKod[4]:=GetAsString('FirstLockKod[4]');
DelSpaceRight(III.FirstLockKod[4]);


III.ListFile[0]:=#0;
III.ListFile:=GetAsString('ListFile');
DelSpaceRight(III.ListFile);


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
III.Task[c].AutoOstatki:=0;

III.Task[c].ObjectKod:=GetAsString('ObjectKod['+IntToStr(c,CMantissa)+']');
RFormatZerro(III.Task[c].ObjectKod,CClientKod);


III.Task[c].PathToRazdel:=GetAsString('ToRazdel['+IntToStr(c,CMantissa)+']');

DelSpaceRight(III.Task[c].PathToRazdel);

III.Task[c].PathToSklad:=GetAsString('ToSklad['+IntToStr(c,CMantissa)+']');
DelSpaceRight(III.Task[c].PathToSklad);


III.Task[c].PathToSkidki:=GetAsString('ToSkidki['+IntToStr(c,CMantissa)+']');
DelSpaceRight(III.Task[c].PathToSkidki);


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

III.Task[c].PathToTemp:=GetAsString('ToSkladTemp['+IntToStr(c,CMantissa)+']');
DelSpaceRight(III.Task[c].PathToTemp);


III.Task[c].AutoZakaz:=GetAsInteger('AutoZakaz['+IntToStr(c,CMantissa)+']');

III.Task[c].AutoOstatki:=GetAsInteger('AutoOstatki['+IntToStr(c,CMantissa)+']');

III.Task[c].AutoAnswer:=GetAsInteger('AutoAnswer['+IntToStr(c,CMantissa)+']');

III.Task[c].ShemaZakaz:=GetAsInteger('ShemaZakaz['+IntToStr(c,CMantissa)+']');

III.Task[c].DefaultDivision:=GetAsInteger('DefaultDivision['+IntToStr(c,CMantissa)+']');

If Not III.Task[c].DefaultDivision in [1..8] Then III.Task[c].DefaultDivision:=1;


End;

SH.Done;
End;



Procedure ShowHelp;
Begin
Writeln('Утилита импорта заказов клиентов в базу предзаказов по схеме мобильно торговли '+CompileDate);
Writeln('Протокол операций '+ClearChar(FDAte)+'.log');
Writeln('Файл конфигурации importa.ini');
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


Function TestElementFull (Const S : String;Const P : PBox) : Boolean;
Var ls : Word;
    k  : Byte;
    st : String;
Begin
TestElementFull:=True;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
If St=S Then
   Begin
    TestElementFull:=False;
    Break;
   End;
End;
End;




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
  AddLog(Log,ss+'-ошибка открытия '+III.Task[ok].PathToSklad+c+'.db код:['+IntToStr(l,CKol)+']');
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
  AddLog(Log,ss+'-ошибка открытия '+III.Task[ok].PathToID+c+'.id код:['+IntToStr(l,CKol)+']');
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
 Assign(fskl,III.PathToSPR+'lands.db');
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Beep;
  AddLog(Log,ss+'-ошибка открытия '+III.PathToSPR+'lands.db код:['+IntToStr(l,CKol)+']');
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
 Assign(fskl,III.PathToSPR+'firma.db');
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Beep;
  AddLog(Log,ss+'-ошибка открытия '+III.PathToSPR+'firma.db код:['+IntToStr(l,CKol)+']');
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
 Assign(fskl,III.PathToSPR+'Marka.db');
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Beep;
  AddLog(Log,ss+'-ошибка открытия '+III.PathToSPR+'Marka.db код:['+IntToStr(l,CKol)+']');
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




Function GetAgent(sf: AllStr;Var Cl : PClientType):Boolean;
Var f : ClientFileType;
    l : LongInt;
    s : ClientType;
    st : ArtikulStr;
    c,Code : Integer;
    ss : AllStr;
Begin

 GetAgent:=False;
 Assign (f,III.PathToClient+'Agent.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Beep;
  AddLog(Log,ss+'-ошибка открытия файла агентов код:'+IntToStr(l,3));
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
     AddLog(Log,ss+'попытка чтения агента '+Cl^.DAt.Kod+' - позиция вне файла! Позиция:'+
	IntToStr(l,CKol)+'('+IntToStr(FileSize(f),CKol)+')');
     Exit;
    End;

   Seek(f,l);
   l:=IOResult;
   ReadClient(f,Cl^.DAt);
   l:=IOResult;
   Close(f);
   l:=IOResult;
   GetAgent:=True;
  End;

  If Not(Cl^.Dat.Employ) Then
     Begin
      Beep;
      AddLog(Log,ss+'-агент '+Cl^.Dat.Kod+' помечен удаленным');
      GetAgent:=False;
      Exit;
     End;

End;


Function GetOperatorName(CC:Word):AllStr;
Var f : File of TSystemReestrDisk;
    l : LongInt;
    ss: PSystemReestr;
    s : PSystemReestrDisk;
    st : ArtikulStr;
    c,Code : Integer;
Begin
 GetOperatorName:='';
 Assign (f,III.PathToSystem+'system.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Beep;
  AddLog(Log,'-ошибка открытия файла операторов:'+IntToStr(l,3));
  Exit;
 End
 Else
  Begin
   l:=cc;

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     c:=IOResult;
     Beep;
     AddLog(Log,'попытка чтения оператора '+IntToStr(c,CKol)+' - позиция вне файла! Позиция:'+
	IntToStr(l,CKol)+'('+IntToStr(FileSize(f),CKol)+')');
     Exit;
    End;

   New(s,Init);
   Seek(f,l);
   l:=IOResult;
   Read(f,s^.DAt);
   l:=IOResult;
   Close(f);
   l:=IOResult;

   new(ss,Init);
   DiskSystemToProgramSystem(s,ss);



  If Not(ss^.Dat.Employ) Then
     Begin
      Beep;
      AddLog(Log,'оператор '+ss^.Dat.Kod+' помечен удаленным');
      Dispose(ss,Done);
      Dispose(s,Done);
      GetOperatorName:='?????';
      Exit;
     End;


   GetOperatorName:=ss^.Dat.Name;
   Dispose(ss,Done);
   Dispose(s,Done);
  End;


End;



Function GetAgentField(ss:AllStr;Field:Byte;C:ArtikulStr):TEnjoyStr;
Var f : ClientFileType;
    l : LongInt;
    s : PClientType;
    st : ArtikulStr;
    Code : Integer;
Begin
 Assign (f,III.PathToClient+'Agent.db');
 GetAgentField:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Beep;
  AddLog(Log,ss+'-ошибка открытия файла агентов код:'+IntToStr(l,3));
  Exit;
 End

 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     Code:=IOResult;
     Beep;
     AddLog(Log,ss+'попытка чтения агента '+C+' - позиция вне файла! Позиция:'+
	IntToStr(l,CKol)+'('+IntToStr(FileSize(f),CKol)+')');
     Exit;
    End;

   Seek(f,l);
   New(S,Init);
   ReadClient(f,s^.Dat);
   Code:=IOResult;
   Close(f);
   Code:=IOResult;


   Case Field Of
    FClient,
    FAgent,
    FEksped,
    FMake  : GetAgentField:=S^.Dat.Name;
    FStatus,
    FClientStatus: GetAgentField:=IntToStr(S^.Dat.Status,CMantissa);
    FPeriod: GetAgentField:=S^.Dat.Period;
    FLastSverka: GetAgentField:=S^.Dat.LastSverka;
    FVip: GetAgentField:=S^.Dat.Vip;
    FClientDocMaska: GetAgentField:=IntToStr(S^.Dat.DocFiltr,CKOl);
    FRoute,
    FClientRoute:GetAgentField:=S^.Dat.RouteKod;
    FClientMain :GetAgentField:=IntToStr(S^.Dat.Main,CKOl);
 FClientMainKod :GetAgentField:=S^.Dat.FantomKod;
    fSrok  : GetAgentField:=S^.Dat.SrokLizensia;
    FDAteM : GetAgentField:=DAteToDAteString(DateMask,S^.Dat.DateM);
    FTimeM : GetAgentField:=TimeToTimeString('hh:mm:ss',S^.Dat.TimeM);
FLastCaption: GetAgentField:=S^.Dat.LastCaption;
    fSrok  : GetAgentField:=S^.Dat.SrokLizensia;
    FLizo : Begin
              Str(S^.Dat.Lizo:1,St);
              GetAgentField:=St;
            End;

    FDebit : Begin
              {Str(S^.Dat.Debit:5,St);}
              GetAgentField:=IntToStr(S^.Dat.Debit,CAll);
             End;

    FEnableMarket:Begin
                   {Str(S^.Dat.Otgruska:5,St);}
                   GetAgentField:=IntToStr(S^.Dat.Otgruska,CAll);
                  End;

    FMessages:GetAgentField:=S^.Dat.Messages;
    FSvid:GetAgentField:=S^.Dat.Svidetelstvo;
    FVekselIP:GetAgentField:=S^.Dat.VekselIP;
    FVekselDP:GetAgentField:=S^.Dat.VekselDP;
    FPassport:GetAgentField:=S^.Dat.Passport;
       FSeria:GetAgentField:=S^.Dat.Seria;
       FVidan:GetAgentField:=S^.Dat.Vidan;
    fEnvir : GetAgentField:=S^.Dat.EnviropMent;
    fINN   : GetAgentField:=S^.Dat.Inn;
    fOkonh : GetAgentField:=S^.Dat.Okonh;
    fOkpo  : GetAgentField:=S^.Dat.Okpo;
    fRSh   : GetAgentField:=S^.Dat.R_Sh;
    fGde,FBank   : GetAgentField:=S^.Dat.BankKod;
    fAdress: GetAgentField:=S^.Dat.Adress;
    fLimit : GetAgentField:=S^.Dat.Limit;
  fTelefon : GetAgentField:=S^.Dat.Telefon;
    fKod   : GetAgentField:=S^.Dat.Kod;
  fNDogovor: GetAgentField:=S^.Dat.Dogovor;
   fAdressF: GetAgentField:=S^.Dat.AdressF;
    fPunkt :Begin
            GetAgentField:=S^.Dat.AdressF;
           End;
    Else;
   End;{Case}

  If Not(S^.Dat.Employ) Then
     Begin
      Beep;
      AddLog(Log,ss+'-клиент '+S^.Dat.Kod+' помечен удаленным');
     End;

  Dispose(S,Done);


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

Procedure EraseFiles(ss:String);
Var c : Word;
    f : File;
Begin
Assign(f,ss);
c:=IoResult;
Erase(f);
c:=IoResult;
End;



Procedure LoadMessages(S:String);
LAbel 43,44,45;
Var ss : TMyString;
    txt : Text;
    i : Byte;
    c : Byte;
    SH: TStringHolder;
    SHeader,SClientKod,SAgentKod,
    SStatus,SObjectKod,LocSkidka : AllStr;
    Cl : PClientType;
    DeltaAmount : Word;
    LastAmount : Word;
    PZ : PPredZakazType;
    Skl : PSkladType;
    f : File;


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

SAgentKod:=GetAsString('AgentKod');{клиент}
If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден AgentKod. Сообщение отложено');
                     Goto 44;
                    End;

RFormatZerro(SAgentKod,CClientKod);

New(Cl,Init);
Cl^.Dat.Kod:=SAgentKod;
If Not(GetAgent(ss,Cl)) Then Goto 44;

If Cl^.Dat.Dopolnenie.Price=0 Then
                    Begin
                     Beep;
                     AddLog(Log,ss+'- автозаказы для агента '+Cl^.Dat.Name+' ('+SAgentKod+') запрещены. Сообщение отложено');
                     Goto 44;
                    End;



DeltaAmount:=0;
LastAmount:=1;
New(PZ,Init);
Pz^.Dat.ClientKod:=SClientKod;
Pz^.Dat.AgentKod:=SAgentKod;

Pz^.Dat.SkladKod:=IntToStr(StrToInt(SObjectKod),CClientKod);
RFormatZerro(Pz^.Dat.SkladKod,CClientKod);
Pz^.Dat.Status:=4;{получен T-Mail}



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
      AddLog(Log,ss+'- дата отправки '+Pz^.Dat.DataOtpr+' меньше текущей. Сообщение отложено');
      If NOT FindParam('/HARD') Then
      Pz^.Dat.DataOtpr:=FDate
      Else
      Goto 43;
 {
  Убрано из-за лоховства торговых
  которые подписывают заказ 27/04 а
  отправляют 28/04 и обработчик
  откладывает эти заказы на хуй
 }
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
Pz^.Dat.Rezerv:=GetAsInteger('Srok');
Pz^.Dat.DateConv:=0;
Pz^.Dat.TimeConv:=0;
Pz^.Dat.SendConfirmation:=0;





Pz^.Dat.Defizit:=GetAsInteger('Defizit');{недостача}
Pz^.Dat.Summa:=GetAsString('Summa');{сумма у клиента}
Pz^.Dat.SertifSumma:=GetAsString('SertifSumma');{сумма у клиента}
Pz^.Dat.Sf:=GetAsInteger('SF');{недостача}
Pz^.Dat.Bn:=GetAsInteger('Bn');{недостача}
Pz^.Dat.Caption:=GetAsString('Caption');{системная учетная запись}

Pz^.Dat.Comment1:=GetAsString('Comment1');
Pz^.Dat.Comment2:=GetAsString('Comment2');
DelSpaceRight(Pz^.Dat.Comment1);
DelSpaceRight(Pz^.Dat.Comment2);

Pz^.Dat.Comment2:=Pz^.Dat.Comment2;
DelSpaceRight(Pz^.Dat.Comment2);



Pz^.Dat.Summa[0]:=#0;{будет уточнять исходя из текущего прайса}
Pz^.Dat.Skidka[0]:=#0;{будет уточнять исходя из текущего прайса}
Pz^.Dat.SertifSkidka[0]:=#0;{будет уточнять исходя из текущего прайса}
Pz^.Dat.SertifSumma[0]:=#0;{будет уточнять исходя из текущего прайса}
Pz^.Dat.Defizit:=0;
LocSkidka[0]:=#0;


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

  Pz^.Dat.Element[c].DivisionNumber:=III.Task[StrToInt(SObjectKod)].DefaultDivision;{}

  If Not (Pz^.Dat.Element[c].DivisionNumber in [1..8]) Then
       Begin
        Pz^.Dat.Element[c].DivisionNumber:=1;
        Beep1;
        AddLog(Log,ss+'- Element['+IntToStr(c,CKol)+'].Zena. Не настроен номер отделения-приемника. Изменено на 1');
       End;


  Pz^.Dat.Element[c].Zena:=GetAsString('Element['+IntToStr(c,CKol)+'].Zena');{}
  DelSpace(Pz^.Dat.Element[c].Zena);

If Not Sh.OkOp Then Begin
                     Beep;
                     AddLog(Log,ss+'- не найден Element['+IntToStr(c,CKol)+'].Zena. Сообщение отложено');
                     Goto 43;
                    End;

  New(Skl,Init);
  Skl^.Dat.BazKod:=Pz^.Dat.Element[c].BazKod;
  If GetSkladRecord(ss,StrToInt(SObjectKod),Skl) Then
    Begin
     {
     If (StrToReal(Skl^.Dat.Input.R_Zena)*StrToReal(Cl^.Dat.Dopolnenie.Proz)-
	    StrToReal(Pz^.Dat.Element[c].Zena)) > 0.009 Then
        Begin
         Beep1;
         AddLog(log,ss+'-недостоверная цена для '+Pz^.Dat.Element[c].BazKod+'-'+
         Pz^.Dat.Element[c].Zena+' заменена на '+ RealToStr(
	    StrToReal(Skl^.Dat.Input.R_Zena)*StrToReal(Cl^.Dat.Dopolnenie.Proz),CZena,CMantissa));
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)*StrToReal(Cl^.Dat.Dopolnenie.Proz),
	    CZena,CMantissa,Pz^.Dat.Element[c].Zena);
        End;
     }
       {предварительная цена}
       Pz^.Dat.Element[c].Zakupka:=StrToReal(Skl^.Dat.Input.Zakupka);
       {предварительная скидка}
       Pz^.Dat.Element[c].Skidka:=StrToReal(Skl^.Dat.Input.R_Zena)-StrToreal(Pz^.Dat.Element[c].Zena);

    End
    Else
       Begin
         Beep;
         AddLog(log,ss+'-не могу проверить цену и подсчитать закупку для '+Pz^.Dat.Element[c].BazKod+'. Сообщение отложено');
         Goto 43;
       End;

  MyStr(StrToReal(Pz^.Dat.Summa)+
        StrToReal(Pz^.Dat.Element[c].Zena)*StrToInt(Pz^.Dat.Element[c].Kol),CIZena,CMantissa,
	   Pz^.Dat.Summa);

  MyStr(StrToReal(Pz^.Dat.Skidka)+
       ((StrToReal(Skl^.Dat.Input.R_Zena))
	  -StrToReal(Pz^.Dat.Element[c].Zena))*StrToInt(Pz^.Dat.Element[c].Kol),CIZena,CMantissa,
       Pz^.Dat.Skidka);


  Dispose(Skl,Done);

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




Procedure ScanCatalog(Var ReplClient,ReplSPR,OST:PBox; Const V:PBox);
Var P : PBox;
    R : TRect;
    AgKod,Ext : AllStr;
    s,s1,FindPath : String;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
    Zapros,ZaprosC,ZaprosS,c : Word;
Begin
R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));

DosError:=0;
Zapros:=0;
ZaprosC:=0;
ZaprosS:=0;
{сканируем каталоги пользователей}
AddLog(Log,'Сканирую входящую почту');

For c:=0 To V^.List^.Count-1 Do
Begin
 s1:=Copy(V^.GetText(c,V^.List^.Count),1+1+CClientKod+1,250);
 DelSpace(s1);
 FindFirst(s1+'IN\'+PredZakazPrefix+'*.*', AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=s1+'IN\'+DirInfo.Name;
{   If Not HiddenAttribute(s) Then}
    Begin
     P^.List^.Insert(NewStr(s));
     P^.SetRange(P^.List^.Count);
    End;
   FindNext(DirInfo);
 end;{While}


 DosError:=0;
 s1:=Copy(V^.GetText(c,V^.List^.Count),1+1+CClientKod+1,250);
 DelSpace(s1);
 FindPath:=s1+'OUT\';
 FindFirst(s1+'IN\'+'refresh.*', AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=s1+'IN\'+DirInfo.Name;
   If Pos('.',DirInfo.Name)>0 Then
    Begin
     Ext:=Copy(DirInfo.Name,Pos('.',DirInfo.Name)+1,3);
     DelSpace(Ext);
     If StrToInt(Ext) in [1..CMaxSklads] Then
     If III.Task[StrToInt(Ext)].AutoOstatki=1 Then
     Begin
      CalcOst[StrToInt(Ext)]:=True;
      Inc(Zapros);
      If TestElementFull(FindPath+';'+Ext,OST) Then
      Begin
       OST^.List^.Insert(NewStr(FindPath+';'+Ext));
       OST^.SetRange(OST^.List^.Count);
      End;
     End;
    End
    Else
     Begin
      AddLog(Log,'Обнаружен неизвестный запрос остатков: '+s );
     End;
   EraseFile(s);
   FindNext(DirInfo);
 end;{While}


 DosError:=0;
 AgKod:=Copy(V^.GetText(c,V^.List^.Count),1+1,CClientKod);
 s1:=Copy(V^.GetText(c,V^.List^.Count),1+1+CClientKod+1,250);
 DelSpace(s1);
 FindPath:=s1;
 FindFirst(s1+'IN\'+'client.*', AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=s1+'IN\'+DirInfo.Name;
   Inc(ZaprosC);
   If TestElementFull(FindPath,ReplClient) Then
      Begin
       ReplClient^.List^.Insert(NewStr(FindPath+';'+GetAgentField('',FRoute,AgKod)));
       ReplClient^.SetRange(ReplClient^.List^.Count);
      End;
   EraseFile(s);
   FindNext(DirInfo);
 end;{While}


 DosError:=0;
 s1:=Copy(V^.GetText(c,V^.List^.Count),1+1+CClientKod+1,250);
 DelSpace(s1);
 FindPath:=s1+'OUT\';
 FindFirst(s1+'IN\'+'spr.*', AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=s1+'IN\'+DirInfo.Name;
   Inc(ZaprosS);
   If TestElementFull(FindPath,ReplSPR) Then
      Begin
       ReplSPR^.List^.Insert(NewStr(FindPath));
       ReplSPR^.SetRange(ReplSPR^.List^.Count);
      End;
   EraseFile(s);
   FindNext(DirInfo);
 end;{While}



End;{For}






AddLog(Log,'Сканирование входящей почты завершено');

If P^.List^.Count>0 Then
 Begin
  AddLog(Log,'Обнаружено входящих сообщений:'+IntToStr(P^.List^.Count,CKol));
 End;

If Zapros>0 Then
 Begin
  AddLog(Log,'Обнаружено входящих запросов для остатки:'+IntToStr(Zapros,CKol));
 End;

If ZaprosC>0 Then
 Begin
  AddLog(Log,'Обнаружено входящих запросов для клиентов:'+IntToStr(ZaprosC,CKol));
 End;

If ZaprosS>0 Then
 Begin
  AddLog(Log,'Обнаружено входящих запросов для доп.справочников:'+IntToStr(ZaprosS,CKol));
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
  If (Zapros=0) And (ZaprosC=0) And (ZaprosS=0) Then
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
NameFile:=GetExportFileNameClientConfirmationNew(Ass,SklPost);

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
 {по клиенту}
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
 Writeln(t,'Srok=',Rezerv);
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
  Writeln(t,'EP[',i,'].BazKod=',Element[i].BazKod);
  DelSpace(Element[i].Kol);
  Writeln(t,'EP[',i,'].DivisionNumber=',Element[i].DivisionNumber);
  Writeln(t,'EP[',i,'].Kol=',Element[i].Kol:CKOl);
  DelSpace(Element[i].Zena);
  Writeln(t,'EP[',i,'].Zena=',Element[i].Zena);
  Writeln(t,'EP[',i,'].Fakt=',Element[i].Fakt:CKol);
  Writeln(t,'EP[',i,'].NadoSertif=',Element[i].NadoSertif);


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

  Writeln(t,'EP[',i,'].Name=',BBB^.Dat.Name);
  Writeln(t,'EP[',i,'].Name2=',BBB^.Dat.Name2);
  Writeln(t,'EP[',i,'].InPack=',BBB^.Dat.InPack);
  Writeln(t,'EP[',i,'].InPack2=',BBB^.Dat.InPack2);
  Writeln(t,'EP[',i,'].Litr=',BBB^.Dat.Litr);
  Writeln(t,'EP[',i,'].EnableContract=',BBB^.Dat.EnableContract);
  Writeln(t,'EP[',i,'].NDS=',BBB^.Dat.NDS);
  Writeln(t,'EP[',i,'].VidNDS=',BBB^.Dat.VidNDS);
  Writeln(t,'EP[',i,'].Nalog=',BBB^.Dat.Nalog);
  Writeln(t,'EP[',i,'].VidNalog=',BBB^.Dat.VidNalog);
  Writeln(t,'EP[',i,'].PostKod=',BBB^.Dat.PostKod);
  Writeln(t,'EP[',i,'].FirmaKod=',BBB^.Dat.FirmaPostKod);
  Writeln(t,'EP[',i,'].NGroupKod=',BBB^.Dat.NGroupKod);
  Writeln(t,'EP[',i,'].Otdel=',BBB^.Dat.Otdel);
  Writeln(t,'EP[',i,'].Market=',BBB^.Dat.Market);
  Writeln(t,'EP[',i,'].EnableDebit=',BBB^.Dat.EnableDebit);
  Writeln(t,'EP[',i,'].Prihod=',BBB^.Dat.Prihod);
  Writeln(t,'EP[',i,'].OKP=',BBB^.Dat.OKP);
  Writeln(t,'EP[',i,'].Massa=',BBB^.Dat.Massa);
  Writeln(t,'EP[',i,'].BuchGroup=',BBB^.Dat.BuchGroup);
  Writeln(t,'EP[',i,'].Etil=',BBB^.Dat.Etil);
  Writeln(t,'EP[',i,'].Class=',BBB^.Dat.Class);
  Writeln(t,'EP[',i,'].Mera=',BBB^.Dat.Mera);
  Writeln(t,'EP[',i,'].Class=',BBB^.Dat.Class);
  Writeln(t,'EP[',i,'].EnableSklads=',BBB^.Dat.EnableSklads);
  Writeln(t,'EP[',i,'].Godnost=',Skl^.Dat.Input.Godnost);
  Writeln(t,'EP[',i,'].ZenaGR=',Skl^.Dat.Input.GRZena);
  Writeln(t,'EP[',i,'].Marker=',BBB^.Dat.Marker);
  Writeln(t,'EP[',i,'].FantomKod=',BBB^.Dat.FantomKod);
  Writeln(t,'EP[',i,'].Main=',BBB^.DAt.Main);
  Writeln(t,'EP[',i,'].NSertif=',Skl^.Dat.Input.NSertif);
  Writeln(t,'EP[',i,'].NMakeKod=',Skl^.Dat.Input.NMakeKod);
  Writeln(t,'EP[',i,'].RegionMarka=',Skl^.Dat.Input.RegionMarka);
  Writeln(t,'EP[',i,'].AkzisSbor=',Skl^.Dat.Input.AkzisSbor);
  Writeln(t,'EP[',i,'].ZenaMarki=',Skl^.Dat.Input.ZenaMarki);
  Writeln(t,'EP[',i,'].NGTD=',Skl^.Dat.Input.NGTD);
  Writeln(t,'EP[',i,'].SMarka=',Skl^.Dat.Input.SpecMarka);
  Writeln(t,'EP[',i,'].Marka=',Skl^.Dat.Input.Marka);
  Writeln(t,'EP[',i,'].Expert=',Skl^.Dat.Input.Expert);
  Writeln(t,'EP[',i,'].USD=',Skl^.Dat.Input.USD);

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

  Writeln(t,'EP[',i,'].SertifName=',BBB^.Dat.Name,' ',BBB^.Dat.Name2);


  Dispose(BBB,Done);
  Dispose(Skl,Done);



 end;
End;{With}

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




Procedure ScanConfirmation(Var OST:PBox; Const P:PBox);
Var R : TRect;
    s,s1 : String;
    Res,j,c : Word;
    zz,Pos : LongInt;
    f : PredZakazFileType;
    Kdx : PHeaderPredZakazType;
    fkdx : File Of HeaderPredZakazType;
    Txt : Text;
    FullPath,Start : String;
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
      If Not TestElement(Pz^.Dat.AgentKod+'│',P) Then
      {элемент найден}
       Begin
        zz:=Location(P,Pz^.Dat.AgentKod+'│',False);
        FullPath:=P^.GetText(zz,P^.List^.Count)+'OUT\;'+IntToStr(j,CKol);
        s1:=Copy(P^.GetText(zz,P^.List^.Count),1+1+CClientKod+1,250);
        DelSpace(s1);
        s1:=s1+'OUT\';{сгенерировали путь к каталогу исходящей почты}
        AddLog(Log,'Обнаружен готовый к отправке предзаказ N '+Pz^.Dat.Document+
	   ' (клиент:'+Pz^.Dat.ClientKod+') '+
	   ' (агент:'+Pz^.Dat.AgentKod+') '+
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
          CalcOst[j]:=True;

      If TestElementFull(FullPath,OST) Then
      Begin
          OST^.List^.Insert(NewStr(FullPath));
          OST^.SetRange(OST^.List^.Count);
      End;
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




Procedure CopyOST(Const OST:PBox);
Var R : TRect;
    s,s1 : String;
    Obj : AllStr;
    Res,j,c : Word;
    zz: LongInt;
    FullPath,Start : String;
    FName : String;
Begin
For c:=0 To OST^.List^.Count-1 Do
Begin
 s1:=Copy(OST^.GetText(c,OST^.List^.Count),1,250);

 Obj:=Copy(s1,Pos(';',s1)+1,CKol);
 System.Delete(s1,Pos(';',s1),CAll);

 If Pos('│',s1)>0 Then
 System.Delete(s1,Pos('│',s1),6);

 If StrToInt(Obj) in [1..CMaxSklads] Then
 Begin
 If CalcOst[StrToInt(Obj)] Then
  Begin
  {If TestOST Then}
   Begin
   FName:=III.PathToTemp+OstatkiPrefix+'ost.'+IntToStr(StrToInt(Obj),CMantissa);
   s:='copy'+' '+FName+' '+s1+' >NUL ';



   SWAPVECTORS;
   exec (GetEnvMy,' /C '+s);
   Res:=DosError;
   SWAPVECTORS;


   If FExists(s1+OstatkiPrefix+'ost.'+IntToStr(StrToInt(Obj),CMantissa)) Then
    Begin
     AddLog(Log,'Копирование '+FName+' в '+s1+' Ok');
    End
   Else
    Begin
     Beep;
     AddLog(Log,'Ошибка копирования в '+s1+OstatkiPrefix+'ost.'+IntToStr(StrToInt(Obj),CMantissa));
    End;


   End;
  End;{CalcOST}
 End;

End;{For}


End;{CopyOst}



Function CreatClientBase(s1:String;{кталог к новой базе}Obj{код маршрута}:AllStr):Boolean;
Var f : File;
    E : PBufClientType;
    Cl : PClientType;
    c,Count : Word;
    NewF : ClientFileType;

Begin
CreatClientBase:=False;
Assign(f,III.PathToClient+'Client.db');
i:=IOResult;
Reset(f,SizeOf(ClientType));
i:=IOResult;
If I<>0 Then
 Begin
  Beep;
  AddLog(Log,'Ошибка открытия '+III.PathToClient+'Client.db Код:'+IntToStr(i,CKol));
  Exit;
 End;


Assign(Newf,s1+'Temp\'+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa));
i:=IOResult;
Rewrite(Newf);
i:=IOResult;
If I<>0 Then
 Begin
  Beep;
  i:=IOResult;
  Close(f);
  i:=IOResult;
  AddLog(Log,'Ошибка создания '+s1+'Temp\'+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa));
  Exit;
 End;

While Not(Eof(f)) Do
 Begin
  Count:=0;
  New(E,Init);
  ReadBufClient(F,E,Count);

  For c:=1 To Count Do
   Begin
    If (StrToInt(E^.Point.Dat[c].RouteKod)=StrToInt(Obj)) Or
       (StrToInt(E^.Point.DAt[c].Kod)=StrToInt(III.FirstLockKod[1])) Or
       (StrToInt(E^.Point.DAt[c].Kod)=StrToInt(III.FirstLockKod[2])) Or
       (StrToInt(E^.Point.DAt[c].Kod)=StrToInt(III.FirstLockKod[3])) Or
       (StrToInt(E^.Point.DAt[c].Kod)=StrToInt(III.FirstLockKod[4]))
     Then
     Begin
      {E^.Point.Dat[c].Locked:=False;}
      Write(NewF,E^.Point.Dat[c]);
     End;

   End;

  Dispose(E,Done);

 End;{While}

  i:=IOResult;
System.Close(Newf);
  i:=IOResult;


  i:=IOResult;
System.Close(f);
  i:=IOResult;


CreatClientBase:=True;
End;





Procedure CreatAndCopyClient(Const ReplClient:PBox);
Var R : TRect;
    s,s1 : String;
    Obj : AllStr;
    Res,j,c : Word;
    zz: LongInt;
    FullPath,Start : String;
    FName : String;
Begin
For c:=0 To ReplClient^.List^.Count-1 Do
Begin
 s1:=Copy(ReplClient^.GetText(c,ReplClient^.List^.Count),1,250);

 {получили код маршрута}
 Obj:=Copy(s1,Pos(';',s1)+1,CKol);
 System.Delete(s1,Pos(';',s1),CAll);

 If CreatClientBase(s1{кталог к новой базе},Obj{код маршрута}) Then
  Begin

  {уничтожаем старый архив если есть}
  If FExists(III.PathToTemp+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa)) Then
  EraseFiles(III.PathToTemp+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa));

  s:=III.PathToUtils+'rar.exe a -inul -y -m5 -ep -ep1 -w'+III.PathToTemp+' '+
  III.PathToTemp+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa)+
  ' '+s1+'Temp\'+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa)+' >NUL ';


  SWAPVECTORS;
  exec (GetEnv('Comspec'),' /C '+s);
  Res:=DosError;
  SWAPVECTORS;

  If FExists(III.PathToTemp+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa)) Then
   Begin
    AddLog(Log,'Упаковка '+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa)+' Ok');
   {начинаем копировать в каталог TMail клиента}

   s:='copy'+' '+III.PathToTemp+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa)+
   ' '+s1+'Out\'+' >NUL ';

   SWAPVECTORS;
   exec (GetEnvMy,' /C '+s);
   Res:=DosError;
   SWAPVECTORS;

   If FExists(III.PathToTemp+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa)) Then
    Begin
     AddLog(Log,'Копирование '+III.PathToTemp+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa)+' в '
	+s1+'Out\'+' Ok');
    End
   Else
    Begin
     Beep;
     AddLog(Log,'Ошибка копирования '+III.PathToTemp+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa)+' в '
	+s1+'Out\');
    End;


  {уничтожаем временный архив}
  If FExists(III.PathToTemp+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa)) Then
  EraseFiles(III.PathToTemp+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa));


   End{конец упаковки}
  Else
   Begin
    Beep;
    AddLog(Log,'Ошибка упаковки '+ClientPrefix+'client.'+IntToStr(StrToInt(Obj),CLitrMantissa));
   End;


  End;{CreatClientBase}




End;{For}


End;{CopyOst}



Function GetUnLoadStatus(S: TDAteString;Ind : Word;Var P :PLoadToDayFile):Boolean;
Var f : File Of LoadToDayFile;
 Pos,Date : LongInt;
    c : Byte;
Begin
 GetUnLoadStatus:=False;
 Date:=DateStringToDate(DateMask,s);
 Pos:=Date-DateStringToDAte(DateMask,'01-01-98');
 Assign(f,III.Task[Ind].PathToSklad+'load.db');
 c:=IOResult;
 Reset(f);
 c:=IOResult;

 If c<>0 Then
  Begin
   AddLog(Log,'Ошибка открытия '+III.Task[Ind].PathToSklad+'load.db'+'(Код:'+IntToStr(c,3)+')');
   Exit;
  End;

 If (FileSize(f)<Pos) Or (Pos<0) Then
  Begin
   c:=IOResult;
   Close(f);
   c:=IOResult;
   AddLog(Log,'Дата '+s+' не найдена в '+III.Task[Ind].PathToSklad+'load.db для объекта:'+IntToStr(Ind,CKol));
   Exit;
  End;

 Seek(f,Pos);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(LoadToDayFile),SizeOf(LoadToDayFile)); {предварительная блокировка}
 Read(f,P^.Dat);
 Repeat
  Unlock(f,Pos*SizeOf(LoadToDayFile),SizeOf(LoadToDayFile));
 Until (DosError=0);
 c:=IOResult;
 Close(f);
 c:=IOResult;
 GetUnLoadStatus:=True;
End;





Procedure CreatOstatki{(j:Word)};
Var R : TRect;
    s,s1 : String;
    Count,Res,k,c : Word;
    zz,Pos : LongInt;
    RE : RazdelType;
    f : File Of RazdelType;
    Kdx : PBufSkladTypeNew;
    fkdx : File;
    wr : Boolean;
    Txt : Text;
    KolS,KolsR : LongInt;
    Start : String;
    P : PLoadToDayFile;
Begin
{
1.проверяем вычисляем если хоть у одного агента хоть один объект
  где нужно было бы обновлять количество
}

{бежим по массиву объектов}
For j:=1 To CMaxSklads Do
Begin

 {разрешен ли отклик для объекта}
 If FExists(III.Task[j].PathToTemp+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa)) Then
 EraseFile(III.Task[j].PathToTemp+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa));

 If FExists(III.PathToTemp+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa)) Then
 EraseFile(III.PathToTemp+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa));

 If FExists(III.Task[j].PathToTemp+'message.'+IntToStr(j,CMantissa)) Then
 EraseFile(III.Task[j].PathToTemp+'message.'+IntToStr(j,CMantissa));

 If CalcOst[j] Then
 If III.Task[j].AutoOstatki=1 Then
 Begin
 New(P,Init);
 GetUnLoadStatus(FDate,j,P);
 If (P^.Dat.Load) And Not (P^.Dat.UnLoad) Then
 Begin
  Dispose(P,Done);
  Assign(txt,III.Task[j].PathToTemp+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa));
  Res:=IOResult;
  Rewrite(txt);
  Res:=IOResult;
   If Res<>0 Then
    Begin
     Beep;
     AddLog(Log,'Ошибка создания остатков для объекта '+IntToStr(j,CMantissa)+' Код:'+IntToStr(Res,CKol));
     {Continue;}Exit;
    End;

  Writeln(txt,ToDay);
  Writeln(txt,CurrentTime);

  Assign(f,III.Task[j].PathToRazdel+'razdel.db');
  Res:=IOResult;
  Reset(f);
  Res:=IOResult;
   If Res<>0 Then
    Begin
     Beep;
     AddLog(Log,'Ошибка открытия '+III.Task[j].PathToRazdel+'razdel.db Код:'+IntToStr(Res,CKol));
     Res:=IOResult;
     Close(txt);
     Res:=IOResult;
     Exit;
    End;

  While Not (Eof(f)) Do
   Begin
    Read(f,RE);

    If RE.Employ Then
     If RE.EnableDoc=0 Then
      Begin
        Assign(fkdx,III.Task[j].PathToIndex+RE.Kod+'.kdx');
        Res:=IOResult;
        Reset(fkdx,SizeOf(SkladTypeNew));
        Res:=IOResult;
        If Res<>0 Then
         Begin
           Beep;
           AddLog(Log,'Ошибка открытия '+III.Task[j].PathToIndex+RE.Kod+'.kdx Код:'+IntToStr(Res,CKol));
           Res:=IOResult;
           Continue;
         End;{Res<>0}

        While Not (Eof(Fkdx)) Do
         Begin
          New(kdx,Init);
          Count:=0;
          ReadBufNewSklad(FKdx,Kdx,Count);

          For c:=1 To Count Do
           Begin
            wr:=False;
            If Kdx^.Point.Dat[c].Employ Then
             Begin
              s[0]:=#0;
              s:=IntToStr(Kdx^.Point.Dat[c].BazKod,CArtikul)+';'+
		    RealToStr(Kdx^.Point.Dat[c].R_Zena,CZena,CMAntissa)+';';

              KolS  :=0;
		    KolsR :=0;

              For K:=1 To CDivision Do
               Begin


 If III.Task[j].DefaultDivision=k Then
 Begin
                KolS  :=Kdx^.Point.Dat[c].Division[k];
			 KolsR :=Kdx^.Point.Dat[c].DivisionR[k];
                If (KolS-KolSR) >=0 Then
			  Begin
                  s:=s+IntToStr((KolS-KolSR),CKOl+1)+';';
                  If (KolS-KolSR) >0 Then Wr:=True;
                 End
                 Else
                  s:=s+'0;';
 End
  Else
                  s:=s+'0;';{это остатки других отделений}
               End;{For k}


             DelSpace(s);
             If wr Then Writeln(txt,s);

             End;
           End;{For}


          Dispose(Kdx,Done);
         End;{While}

        Res:=IOResult;
        Close(fkdx);
        Res:=IOResult;

      End;{EnableDoc=0 Employ=True}

 End;{ While}
  Res:=IOResult;
  Close(f);
  Res:=IOResult;

  Res:=IOResult;
  Close(txt);
  Res:=IOResult;



  s:=III.PathToUtils+'rar.exe a -inul -y -m5 -ep -ep1 -w'+III.PathToTemp+' '+
  III.PathToTemp+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa)+
  ' '+III.Task[j].PathToTemp+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa)+' >NUL ';


  SWAPVECTORS;
  exec (GetEnv('Comspec'),' /C '+s);
  Res:=DosError;
  SWAPVECTORS;

  If FExists(III.PathToTemp+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa)) Then
   Begin
    AddLog(Log,'Упаковка '+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa)+' Ok');
   End
  Else
   Begin
    Beep;
    AddLog(Log,'Ошибка упаковки '+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa));
   End;



   If FExists(III.Task[j].PathToTemp+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa)) Then
   EraseFile(III.Task[j].PathToTemp+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa));


 End{GetUnLoadStatus}
 Else
  Begin{собщение о невозможности отправки остатков ввиду не загруженности базы
        удаленных складов}

  Assign(txt,III.Task[j].PathToTemp+'message.'+IntToStr(j,CMantissa));
  Res:=IOResult;
  Rewrite(txt);
  Res:=IOResult;

  Write(txt,'Невозможно обновить информацию об остатках!');
  If P^.Dat.UnLoad Then
   Begin
    WriteLN(txt,' База удаленных складов выгружена '+DateToDateString(DateMask,P^.Dat.UnLoadDAte)+' в '+
    TimeToTimeString('hh:mm:ss',P^.Dat.UnLoadTime)+' оператором '+GetOperatorName(P^.Dat.UnLoadCaption));
   End;

  If Not P^.Dat.Load Then
   Begin
    WriteLN(txt,' База удаленных складов за '+FDate+' не загружена');
   End;

  Dispose(P,Done);

  Res:=IOResult;
  Close(txt);
  Res:=IOResult;

  If FExists(III.Task[j].PathToTemp+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa)) Then
  EraseFile(III.Task[j].PathToTemp+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa));



  s:=III.PathToUtils+'rar.exe a -inul -y -m5 -ep -ep1 -w'+III.PathToTemp+' '+
  III.PathToTemp+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa)+
  ' '+III.Task[j].PathToTemp+'message.'+IntToStr(j,CMantissa)+' >NUL ';


  SWAPVECTORS;
  exec (GetEnv('Comspec'),' /C '+s);
  Res:=DosError;
  SWAPVECTORS;

  If FExists(III.PathToTemp+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa)) Then
   Begin
    AddLog(Log,'Упаковка '+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa)+' Ok');
   End
  Else
   Begin
    Beep;
    AddLog(Log,'Ошибка упаковки '+OstatkiPrefix+'ost.'+IntToStr(j,CMantissa));
   End;



   If FExists(III.Task[j].PathToTemp+'message.'+IntToStr(j,CMantissa)) Then
   EraseFile(III.Task[j].PathToTemp+'message.'+IntToStr(j,CMantissa));


  End;


 End;


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




Procedure CreatAndCopySPR(ReplSPR:PBox);
Var FName,s,s1 : String;
    Count,Res,k,c : Word;
    zz,Pos : LongInt;
    RE : RazdelType;
    f : File Of RazdelType;
    Kdx : PBufSkladTypeNew;
    fkdx : File;
    wr : Boolean;
    Txt : Text;
    KolS,KolsR : LongInt;
    Start : String;
Begin
{
1.проверяем вычисляем если хоть у одного агента хоть один объект
  где нужно было бы обновлять количество
}

{бежим по массиву объектов}
 If Not(ReplSPR^.List^.Count>0) Then
  Begin
   Exit;
  End
 Else
  Begin
   {Архивируем каталог spr используя list.txt}
   DelSpace(III.listfile);
   If III.listfile[0]=#0 Then
    Begin
     Beep1;
     AddLog(Log,'Внимание! Отстутствует список архивации SPR');
     Exit;
    End;

   EraseFiles(III.PathToTemp+SprPrefix+'spr.rar');
   s:=III.PathToUtils+'rar.exe a -inul -y -m5 -ep -ep1 -dh -w'+III.PathToTemp+' '+
   III.PathToTemp+SprPrefix++'spr.rar'+' @'+III.listfile+' >NUL ';

   SWAPVECTORS;
   exec (GetEnv('Comspec'),' /C '+s);
   Res:=DosError;
   SWAPVECTORS;

   If FExists(III.PathToTemp+SprPrefix++'spr.rar') Then
    Begin
     AddLog(Log,'Упаковка '+III.PathToTemp+SprPrefix++'spr.rar'+' Ok');
    End
   Else
    Begin
     Beep;
     AddLog(Log,'Ошибка упаковки '+III.PathToTemp+SprPrefix++'spr.rar');
    End;


  End;


For c:=0 To ReplSpr^.List^.Count-1 Do
Begin

   s1:=Copy(ReplSpr^.GetText(c,ReplSpr^.List^.Count),1,250);

   FName:=III.PathToTemp+SprPrefix++'spr.rar';
   s:='copy'+' '+FName+' '+s1+' >NUL ';
   SWAPVECTORS;
   exec (GetEnvMy,' /C '+s);
   Res:=DosError;
   SWAPVECTORS;

   If FExists(s1+SprPrefix++'spr.rar') Then
    Begin
     AddLog(Log,'Копирование '+FName+' в '+s1+' Ok');
    End
   Else
    Begin
     Beep;
     AddLog(Log,'Ошибка копирования '+FName+' в '+s1);
    End;

End;{For}

   EraseFiles(III.PathToTemp+SprPrefix++'spr.rar');


End;









Procedure ScanBase;
Var c,i,Count : Word;
    Cl : PBufClientType;
    ReplClient,ReplSPR,OST,V:PBox;
    R : TRect;
    s : String;
    FClient : File;
Begin

Assign(FClient,III.PathToClient+'agent.db');
count:=IOResult;
Reset(FClient,SizeOf(ClientType));
count:=IOResult;
If Count<>0 Then
 Begin
  Beep;
  AddLog(Log,'Ошибка открытия '+III.PathToClient+'agent.db');
  AddLog(Log,'Аварийное завершение');
  Exit;
 End;

R.Assign(0,0,0,0);
V := New(PBox, Init(R, 1, Nil));
V^.NewList(New(PTextCollection, Init(0,1)));

OST := New(PBox, Init(R, 1, Nil));
OST^.NewList(New(PTextCollection, Init(0,1)));

ReplClient := New(PBox, Init(R, 1, Nil));
ReplClient^.NewList(New(PTextCollection, Init(0,1)));

ReplSPR := New(PBox, Init(R, 1, Nil));
ReplSPR^.NewList(New(PTextCollection, Init(0,1)));


AddLog(Log,'Сканирую базу агентов');
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
        i:=IoResult;
        MkDir(Cl^.Point.Dat[c].Dopolnenie.MailPath);
        i:=IoResult;
        MkDir(Cl^.Point.Dat[c].Dopolnenie.MailPath+Cl^.Point.Dat[c].Kod);
        i:=IoResult;
        MkDir(Cl^.Point.Dat[c].Dopolnenie.MailPath+Cl^.Point.Dat[c].Kod+'\Arc');
        i:=IoResult;
        MkDir(Cl^.Point.Dat[c].Dopolnenie.MailPath+Cl^.Point.Dat[c].Kod+'\Arc\In');
        i:=IoResult;
        MkDir(Cl^.Point.Dat[c].Dopolnenie.MailPath+Cl^.Point.Dat[c].Kod+'\Arc\Out');
        i:=IoResult;
        MkDir(Cl^.Point.Dat[c].Dopolnenie.MailPath+Cl^.Point.Dat[c].Kod+'\Arc\Temp');
        i:=IoResult;
        MkDir(Cl^.Point.Dat[c].Dopolnenie.MailPath+Cl^.Point.Dat[c].Kod+'\In');
        i:=IoResult;
        MkDir(Cl^.Point.Dat[c].Dopolnenie.MailPath+Cl^.Point.Dat[c].Kod+'\Out');
        i:=IoResult;
        MkDir(Cl^.Point.Dat[c].Dopolnenie.MailPath+Cl^.Point.Dat[c].Kod+'\Temp');
        i:=IoResult;
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

AddLog(Log,'Сканирование базы агентов завершено ('+IntToStr(V^.List^.Count,CKol)+' агентов)');

If V^.List^.Count>0 Then
 Begin
  ScanCatalog(ReplClient,ReplSPR,OST,V);
 End;
{
  Writeln(Times);
  CreatOstatki(2);
  Writeln(Times);
}

{Writeln(V^.List^.Count);}
If V^.List^.Count>0 Then
 Begin
  AddLog(Log,'Сканирую исходящую почту');
  ScanConfirmation(OST,V);
  CreatOstatki;

  {CreatClientBase;}


 If OST^.List^.Count>0 Then
  Begin
   CopyOST(OST);
  END;

 If ReplClient^.List^.Count>0 Then
  Begin
   CreatAndCopyClient(ReplClient);
  END;

 If ReplSPR^.List^.Count>0 Then
  Begin
   CreatAndCopySPR(ReplSPR);
  END;

  AddLog(Log,'Сканирование исходящей почты завершено');
 End;

Dispose(V,Done);
Dispose(OST,Done);
Dispose(ReplClient,Done);
Dispose(ReplSPR,Done);



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

 Assign(Ini,'importa.ini');
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



