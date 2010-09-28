{$X+}
unit dbase;
{**********************************************************}
{*                        dBase.PAS                       *}
{*    Объектно-ориентированный интерфейс к DBF-файлам     *}
{*                     Version 0.90 beta                  *}
{*             Головной модуль - доступ к собственно DBF  *}
{*     Спецификация интерфейсов к индексным и MEMO-файлам *}
{*                 Copyright (c) by SoftWeyr,1994         *}
{**********************************************************}
interface
uses objects,dos;
const TOP = 0;    {for Go Method}
      BOTTOM = -1;
      {Field types}
      fldChar='C';
      fldNumeric='N';
      fldLogical='L';
      fldMemo='M';
      {DataBase modes}
      dbOpen = 0;
      dbCreate =1;
      dbReadOnly=2;
      {Values returned in DBError variable}
      {database warnings}
      dbFieldEmpty=-1;
      dbDataTooLong=-2;
      dbRecordNotDeleted=-3;
      dbAlreadyDeleted=-4;
      {dataBase errors}
      dbInvalidMode=1;
      dbInvalidField=2;
      dbInvalidRecNo=3;
      dbInvalidFieldName=4;
      dbInvalidType=5;
      dbInvalidData=6;
      dbLimitExeeded=7;
      dbBaseEmpty=8;
      dbRecordTooLarge=9;
      dbFieldAlreadyExist=10;
      dbInvalidIndexNum=11;
      dbInvalidIndex=12;
      dbUndefinedIndex=13;
      dbMemoNotOpen=14;
      dbInitError=15;
      {Максимально допустимая длина поля Memo}
      MaxMemoLen=4096;

Type  FieldNameString=string[11];
   {$IFOPT N+}
    FLoat=Extended;
   {$ELSE}
    Float=Real;
   {$ENDIF}
   FieldDesc = record
     Name : array [1..11] of char; { Имя поля }
     Typ  : char;                  { Тип }
     Res,Res2  : integer;               { Резерв }
     Len  : byte;                  { общая длина поля }
     Dec  : byte;                  { число цифр после дес.точки }
     Res3 : array[1..13] of byte;  { Резерв }
     Tag  : byte;                  { Признак тага MDX }
   end;

    TStru=array[1..128] of FieldDesc;
    PStru=^TStru;

    TRecord=Array[0..4095] of char;
    PRecord=^TRecord;

    TWArray=array[1..128] of word;
    PWArray=^TWArray;
{
    PMemoRec=^TMemoRec;
    TMemoRec=record
              TextLen:Word;
              TextData:Array[1..MaxMemoLen] of char;
             end;
}
type
  PProtectedStream = ^TProtectedStream;
  TProtectedStream = object(TBufStream)
    procedure Error(Code, Info: Integer); virtual;
  end;

(*
PMemoFile = ^TMemoFile;
TMemoFile = object(TObject)
             Function GetSize(Offset:LongInt):Word;virtual;
             Procedure Get(Offset:LongInt;var D:TMemoRec);virtual;
             Procedure Free(Offset:LongInt);virtual;
             Function Put(var D:TMemoRec):LongInt;virtual;
             Function GetDBFID:Byte;virtual;
            end;
*)

PDBF = ^TDBF;
TDBF=Object(TObject)
          S:PStream;
          HeaderSize:Word;
          RecSiZE:Word;
          RecCount:Longint;
          FieldCount:byte;
          SkipDeleted:Boolean;
          Mode:Byte;
          RecNo:LongInt;
          VersionID:Byte;
          {Memo:PMemoFile;}
          Constructor Init(St:PStream);
          {----- Открывает DBF файл из заданного потока. Если поток пустой,
                 то входит в режим создания файла}
          Procedure Go(ARecNo:LongInt);virtual;
          {------ Переход к записи по номеру.
                  вместо номера можно использовать константы Top и Bottom.}

          function Field(n:integer):String;
          {------ Возвращает имя поля по номеру}
          function FieldNo(FName:String):Byte;
          {------ Находит номер поля по имени. Если не нашел, возвращает 0}
          Function FieldType(n:integer):Char;
          {------ Возвращает тип поля}
          Function FieldLen(n:integer):byte;
          {------ Возвращает длину поля}
          Function FieldDec(n:integer):byte;
          {------ Возвращает число знаков после запятой}
          Function GetField(n:Integer):string;
          {------ Возвращает строковое представление любого поля кроме Memo}
          Function GetIntField(n:integer):LongInt;
          {------ Возвращает целое представление числового поля с Dec=0}
          Function GetRealField(n:integer):Float;
          {------ Возвращает вещественное представление числового поля}
          Function GetBooleanField(n:integer):Boolean;
          {------- Возвращает значение логического поля}
          {Function GetMemoField(n:Integer):PMemoRec;}
          {------ Читает поле Memo и размещает его в динамической памяти.
                  Возвращает указатель на него}
          {Procedure GetMemoStatic(n:Integer;var Value);}
          {------ Читает поле Memo. Value должно быть записью типа
                  TMemoRec и содержать достаточно места}
          Procedure PutField(n:Integer;Value:String);
          {------- Изменяет строковое поле}
          Procedure PutIntField(n:Integer;Value:LongInt);
          {------- Изменяет целое поле}
          Procedure PutRealField(n:Integer;Value:Float);
          {------- изменяет любое числовое поле}
          Procedure PutBooleanField(n:Integer;Value:Boolean);
          {------- Изменяет логическое поле}
          {Procedure PutMemoField(n:Integer;var Value);}
          {------ Записывает поле Memo Value должно быть записью типа
                  TMemoRec}
          Procedure InsertBlank(Before:boolean);virtual;
          {------- Вставляет пустую запись после/перед текущей}
          Procedure AppendBlank;
          {------- Вставляет пустую запись в конец файла}
          Procedure AddField(Name:String;Typ:char;LEn,dec:byte);
          {------- добавляет поле (только в режиме создания)}
          Procedure CopyStru(P:PDBF);
          {------ Копирует структуру из другого файла и создает файл
                   методом Create}
          Procedure Create;
          {------- Создает файл. Переходит из режима создания в режим dbOpen}
          Procedure Skip(Count:longint);virtual;
          {--------- Перемещает указатель на Count записей}
          Procedure Next;virtual;
          {-------- переходит к следующей записи}

          Destructor Done;virtual;
          {------- сохраняет изменения,закрывает файл, уничтожает поток,}
          Procedure Delete;
          {------ Помечает текущую запись для удаления}
          Procedure Recall;
          {------- Снимает отметку для удаления с текущей записи}
          Procedure SetDeleted(On:Boolean);
          {------- Устанавливает режим пропуска удаленных записей
                    On=True - использовать False - пропускать}
          function isDeleted:Boolean;
          {------- Проверяет, помечена ли текущая запись для удаления}
          function Eof:Boolean;virtual;
          {------  Проверяет, является ли текущая запись концом файла}
          function Bof:Boolean;virtual;
          {------  Проверяет, является ли текущая запись началом файла}
          procedure AppendFrom(P:PDBF);
          {------ Копирует в данный файл записи из другого}
          procedure Zap;

          Procedure BlankRecord;

          Private

           Buffer:PRecord;
           Stru:PSTru;
           Offset:PWArray;
           RecordModified:boolean;
           GlobalChanged:Boolean;
           Procedure GetRecord;
           Procedure PutRecord;virtual;
           Procedure WriteHeader;
          end;




var DBError:integer;


implementation

Uses MsgBox,SysTime,ServStr;


Type
 DBFHeader = record
     Version   : byte;     { Заголовочный байт }
     yy,mm,dd  : byte;     { Дата последнего обновления файла }
     MaxRecs   : longint;  { Число записей в файле, вместе с уд-ми }
     HplusD    : word;     { Общая дина заголовка и списка д-ров полей }
     RecLen    : word;     { Длина одной записи }
     Reserv1   : integer;  { Зарезервировано }
     HoldTrans : byte;     { Флаг задержки по транзакции }
     Res2 : array[15..27] of byte; { Зарезервировано }
     IsMDX     : byte;     { Признак подключения MDX-файла}
     Res3 : array[29..31] of byte; { Зарезервировано }
   end;


const D:Char=#13;


Var Test : PDBF;


Constructor TDBF.Init(St:PStream);
var H:DBFHeader;
    i,j:Integer;
begin
 dbError:=dbInitError;
 if St^.Status<>0 then fail;
 TObject.Init;
 if St^.GetSize=0 then
  begin
   Mode:=dbCreate;
   St^.Write(H,1);
   RecSize:=1;
   if St^.Status<>stOk then  fail;
   S:=St;
   HeaderSize:=33;
   VersionID:=3;
   exit;
  end;

 St^.Seek(0);
 St^.Read(H,SizeOf(H));

 if St^.Status<>stOk then fail;
 St^.Seek(0);
 St^.Write(H,SizeOf(H));
 if ST^.Status<>0 then begin st^.Reset;Mode:=dbReadOnly end;
 HeaderSize:=H.HPlusD;
 RecSize:=H.RecLen;
 RecCount:=H.MaxRecs;
 VersionID:=H.Version;
 FieldCount:=(HeaderSize-1)div 32 - 1;
 GetMem(Stru,HeaderSize-33);
 St^.Seek(32);
 St^.Read(Stru^,32*FieldCount);
 if St^.Status<>stOk then
  begin
   FreeMem(Stru,HeaderSize-33);
   Fail;
  end;
  S:=St;
  GetMem(Offset,FieldCount*SizeOf(Word));
  J:=1;
  For i:=1 to FieldCount do
   begin
    Offset^[i]:=j;
    J:=J+Stru^[i].Len;
   end;
  GetMem(Buffer,RecSize);
  RecNo:=1;
  S^.Seek(HeaderSize);
  GetRecord;
end;



Procedure TDBF.CopyStru(P:PDbf);
var H:DBfHeader;
begin
 if Mode<>dbCreate then
 begin
  DBError:=dbInvalidMode;
  exit;
 end;
 dbError:=0;
 FieldCount:=P^.FieldCount;
 HeaderSize:=P^.HeaderSize;
 RecSize:=P^.RecSize;
 GetMem(Offset,FieldCount*2);
 Move(P^.Offset^,Offset^,FieldCount*2);
 GetMem(Stru,FieldCount*32);
 Move(P^.Stru^,Stru^,FieldCount*32);
 VersionID:=P^.VersionID;
 Create;
end;


Procedure TDBF.Go(ARecNo:LongInt);
begin
   dbError:=0;
  if Mode=dbCreate then
   begin
    dbError:=dbInvalidMode;
    exit;
   end;
 if ARecNo=Bottom then ARecNo:=RecCount;
 if ARecNo=Top then ArecNo:=1;
 dec(ARecNo);
 if (ARecNo<0)or(ARecNo>RecCount) then
  begin
   DBError:=dbInvalidRecNo;
   exit;
  end;
 if RecordModified then
  PutRecord;
 S^.Seek(HeaderSize+ARecNo*RecSize);
 RecNo:=ARecNo+1;

 if RecNo<=RecCount then GetRecord else
  Begin
    BlankRecord;
    RecordModified:=False;
  end;
 if SkipDeleted then
  while isDeleted and not eof do next;
end;


function TDBF.Field(n:integer):String;
var str:FieldNameString;
begin
 DbError:=0;
 if n>FieldCount then Field:='' else
 begin
  Str:=Stru^[N].Name;
  While (Str[Length(Str)]<=' ') do dec(Str[0]);
  Field:=Str;
 end;
end;

function TDBF.FieldNo(FName:String):Byte;
 var i:byte;
     f:Array[1..11] of char;
 begin
   FillChaR(F,SizeOf(F),#0);
   if Length(FName)>11 then
    begin
     DBError:=dbInvalidFieldName;exit;
     FieldNo:=0;
    end;
   For i:=1 to Length(Fname) do F[i]:=Upcase(FName[i]);
   i:=FieldCount;
   while (i>0) and (Stru^[i].name<>f)  do dec(i);
   FieldNo:=i
  end;

Function TDBF.FieldType(n:integer):Char;
begin
 dbError:=0;
 if n>FieldCount then
  begin
 FieldType:=' ';DBError:=dbInvalidField end else FieldType:=Stru^[N].Typ;
end;

Function TDBF.FieldLen(n:integer):byte;
begin
 dbError:=0;
 if n>FieldCount then
  begin
 FieldLen:=0;DBError:=dbInvalidField end else FieldLen:=Stru^[N].Len;
end;

Function TDBF.FieldDec(n:integer):byte;
begin
 dbError:=0;
 if n>FieldCount then
  begin
   FieldDec:=0;DBError:=dbInvalidField end else FieldDec:=Stru^[N].Dec;
end;

Function TDBF.GetField(n:Integer):string;
var D:String;
begin
   GetField:='';
 if Mode=dbCreate then begin dbError:=dbInvalidMode;exit;end;
 if (N>FieldCount)or(N<=0) then
  begin
   DBError:=dbInvalidField;
   exit;
  end;
 if Stru^[n].typ=fldMemo then
  begin
   DBError:=dbInvalidType;
   exit;
  end;
  D[0]:=chr(Stru^[n].len);
  Move(Buffer^[Offset^[n]],D[1],ord(D[0]));
  While D[ord(D[0])]=' ' do dec(D[0]);
  GetField:=D;
  DBError:=0;
end;

Function TDBF.GetIntField(n:integer):LongInt;
var D:String;L:LongInt;i:integer;
begin
 GetIntField:=0;
 if Mode=dbCreate then begin dbError:=dbInvalidMode;exit;end;
 if (N>FieldCount)or(N<=0) then
  begin
   DBError:=dbInvalidField;
   exit;
  end;
 if ((Stru^[n].typ<>fldNumeric)or(Stru^[n].Dec<>0))and(Stru^[n].typ<>fldMemo) then
  begin
   DBError:=dbInvalidType;
   exit;
  end;
  D[0]:=chr(Stru^[n].len);
  Move(Buffer^[Offset^[n]],D[1],ord(D[0]));
  i:=1;While (i<=Length(D)) and (D[i]=' ') do inc(i);
        While D[length(D)]=' ' do dec(D[0]);
  if i>Length(D) then
   dbError:=dbFieldEmpty
  else
   begin
    val(Copy(D,i,255),l,i);
    if i<>0 then DBError:=dbInvalidData else
     begin
      DbError:=0;
      GetIntField:=L;
     end;
   end;
end;

Function TDBF.GetRealField(n:integer):Float;
var D:String;R:Float;i:integer;
begin
 GetRealField:=0;
 if Mode=dbCreate then begin dbError:=dbInvalidMode;exit;end;
 if (N>FieldCount)or(N<=0) then
  begin
   DBError:=dbInvalidField;
   exit;
  end;
 if (Stru^[n].typ<>fldNumeric) then
  begin
   DBError:=dbInvalidType;
   exit;
  end;
  D[0]:=chr(Stru^[n].len);
  Move(Buffer^[Offset^[n]],D[1],ord(D[0]));
        While (D<>'')and(D[length(D)]=' ' )do dec(D[0]);
  if D='' then
   dbError:=dbFieldEmpty  else
   begin
    val(D,R,i);
    if i<>0 then DBError:=dbInvalidData else
     begin
      DbError:=0;
      GetRealField:=R;
     end;
   end;
end;

Function TDBF.GetBooleanField(n:integer):Boolean;
var C:Char;
begin
 GetBooleanField:=false;
 if Mode=dbCreate then begin dbError:=dbInvalidMode;exit;end;
 if (N>FieldCount)or(N<=0) then
  begin
   DBError:=dbInvalidField;
   exit;
  end;
 if (Stru^[n].typ<>fldLogical) then
  begin
   DBError:=dbInvalidType;
   exit;
  end;
 C:= Buffer^[offset^[n]];
 DBerror:=0;
  case C of
  'Y','T':GetBooleanField:=True;
  'N','F':;
  ' ':DbError:=dbFieldEmpty;
  else
   dbError:=dbInvalidData;
  end;
end;

(*
Function TDBF.GetMemoField(n:Integer):PMemoRec;
var Offs:LongInt;Size:Word;P:PMemoRec;
begin
 GetMemoField:=Nil;
 if Mode=dbCreate then begin dbError:=dbInvalidMode;exit;end;
 if (N>FieldCount)or(N<=0) then
  begin
   DBError:=dbInvalidField;
   exit;
  end;
 if (Stru^[n].typ<>fldMemo) then
  begin
   DBError:=dbInvalidType;
   exit;
  end;
 if Memo=nil then begin
  DBError:=dbMemoNotOpen;
  exit;
 end;
 Offs:=GetIntField(n);
 if dbError=dbFieldEmpty then exit;
 Size:=Memo^.GetSize(Offs);
 if Size=0 then begin dbError:=dbFieldEmpty;exit end;
 GetMem(P,Size+2);
 Memo^.Get(Offs,P^);
 GetMemoField:=P;
end;

Procedure TDBF.GetMemoStatic(n:Integer;var Value);
var Offs:LongInt;
begin
 if Mode=dbCreate then begin dbError:=dbInvalidMode;exit;end;
 if (N>FieldCount)or(N<=0) then
  begin
   DBError:=dbInvalidField;
   exit;
  end;
 if (Stru^[n].typ<>fldMemo) then
  begin
   DBError:=dbInvalidType;
   exit;
  end;
 if Memo=nil then begin
  DBError:=dbMemoNotOpen;
  exit;
 end;
 Offs:=GetIntField(n);
 if dbError=dbFieldEmpty then exit;
 Memo^.Get(Offs,TMemoRec(Value));
end;
*)

Procedure TDBF.PutField(n:Integer;Value:String);
var L:Byte;
begin
 if Mode<>dbOpen then begin dbError:=dbInvalidMode;exit;end;
 if (N>FieldCount)or(N<=0) then
  begin
   DBError:=dbInvalidField;
   exit;
  end;
 if (Stru^[n].typ<>fldChar) then
  begin
   DBError:=dbInvalidType;
   exit;
  end;
 L:=Stru^[n].Len;
 if Length(Value)>L then DBError:=dbDataTooLong
  else
   while Length(Value)<L do Value:=Value+' ';
 Move(Value[1],Buffer^[Offset^[n]],L);
 RecordModified:=True;
end;

Procedure TDBF.PutIntField(n:Integer;Value:LongInt);
var D:String;L:Byte;
begin
 if Mode<>dbOpen then begin dbError:=dbInvalidMode;exit;end;
 if (N>FieldCount)or(N<=0) then
  begin
   DBError:=dbInvalidField;
   exit;
  end;
 if ((Stru^[n].typ<>fldNumeric)or(Stru^[n].Dec<>0))and(Stru^[n].Typ<>fldMemo) then
  begin
   DBError:=dbInvalidType;
   exit;
  end;
 L:=Stru^[n].Len;
 Str(Value:L,D);
 if Length(D)>L then DBError:=dbLimitExeeded else
  begin
   Move(D[1],Buffer^[Offset^[N]],L);
   RecordModified:=true;
  end;
end;

Procedure TDBF.PutRealField(n:Integer;Value:Float);
var D:String;L:Byte;
begin
 if Mode<>dbOpen then begin dbError:=dbInvalidMode;exit;end;
 if (N>FieldCount)or(N<=0) then
  begin
   DBError:=dbInvalidField;
   exit;
  end;
 if (Stru^[n].typ<>fldNumeric)and(Stru^[n].Dec<>0) then
  begin
   DBError:=dbInvalidType;
   exit;
  end;
 L:=Stru^[n].Len;
 Str(Value:L:Stru^[n].Dec,D);
 if Length(D)>L then DBError:=dbLimitExeeded else
  begin
   Move(D[1],Buffer^[Offset^[N]],L);
   RecordModified:=true;
  end;
end;

Procedure TDBF.PutBooleanField(n:Integer;Value:Boolean);
const Ch: Array[Boolean] of char= ('F','T');
begin
 if Mode<>dbOpen then begin dbError:=dbInvalidMode;exit;end;
 if (N>FieldCount)or(N<=0) then
  begin
   DBError:=dbInvalidField;
   exit;
  end;
 if (Stru^[n].typ<>fldLogical) then
  begin
   DBError:=dbInvalidType;
   exit;
  end;
 Buffer^[Offset^[N]]:=Ch[Value];
 RecordModified:=True;
end;

(*
Procedure TDBF.PutMemoField(n:Integer;var Value);
var Offs:LongInt;
begin
 if Mode=dbCreate then begin dbError:=dbInvalidMode;exit;end;
 if (N>FieldCount)or(N<=0) then
  begin
   DBError:=dbInvalidField;
   exit;
  end;
 if (Stru^[n].typ<>fldMemo) then
  begin
   DBError:=dbInvalidType;
   exit;
  end;
 if Memo=nil then begin
  DBError:=dbMemoNotOpen;
  exit;
 end;
 Offs:=GetIntField(n);
 Memo^.Free(Offs);
 Offs:=Memo^.Put(TMemoRec(Value));
 PutIntField(n,Offs);
end;
*)


Procedure TDBF.InsertBlank(Before:boolean);
var N:LongInt;I:LongInt;
begin
 if Mode<>dbOpen then begin dbError:=dbInvalidMode;exit;end;
 n:=RecNo; if not Before then inc(N);
 appendBlank;
 For i:=Pred(RecCount) downto n do
  begin
   Go(i);
   GetRecord;
   S^.Write(Buffer^,RecSize);
  end;
 BlankRecord;
 RecordModified:=True;
end;

Procedure TDBF.AppendBlank;
begin
 if Mode<>dbOpen then begin dbError:=dbInvalidMode;exit;end;
 Go(Bottom);
 Next;
 BlankRecord;
 S^.Write(Buffer^,RecSize);
 inc(RecCount);
end;

Procedure TDBF.AddField(Name:String;Typ:char;LEn,dec:byte);
var St:PStru;O:PWArray;L:Word;I:Byte;
begin
 if Mode<>dbCreate then
  begin
   dbError:=dbInvalidMode;
   exit;
  end;
 if Pos(Typ,'CNLM')=0 then
  begin
   dbError:=dbInvalidType;
   exit;
  end;
  if Typ='N' then
   begin
   if Dec>Len then begin dbError:=dbLimitExeeded; exit end;
   end else Dec:=0;
 if Length(Name)>11 then begin dbError:=dbDataTooLong;Name[0]:=#11 end;
 if Typ='L' then Len:=1 else if Typ='M' then Len:=10;
 L:=RecSize+Len;if L>4096 then begin dbError:=dbRecordTooLarge;exit end;
 if FieldNo(Name)<>0 then begin dbError:=dbFieldAlreadyExist;exit end;
 For i:=1 to length(Name) do
 begin
  Name[i]:=Upcase(Name[i]);
   if Not (Name[i] in ['0'..'9','A'..'Z','_'])then
   begin
    dbError:=dbInvalidFieldName;exit
   end;
 end;
  if (Name[1]>'Z')or(Name[1]<'A') then
   begin
    dbError:=dbInvalidFieldName;exit
   end;
 St:=Stru;
 O:=Offset;
 GetMem(Stru,Succ(FieldCount)*32);
 GetMem(OffSet,Succ(FieldCount)*2);
 Move(O^,Offset^,FieldCount*2);
 Move(St^,Stru^,FieldCount*32);
 FreeMem(St,FieldCount*32);
 FreeMem(O,FieldCount*2);
 inc(FieldCount);
 Offset^[FieldCount]:=RecSize;
 FillChar(Stru^[FieldCount],32,#0);
 Move(Name[1],Stru^[FieldCount].Name,LengtH(Name));
 Stru^[FieldCount].Len:=Len;
 Stru^[FieldCount].Dec:=Dec;
 Stru^[FieldCount].Typ:=Typ;
 Stru^[FieldCount].Res:=RecSize;
 Inc(HeaderSize,32);
 RecSize:=L;
end;


Procedure TDBF.Create;
var I:Integer;
begin
 dbError:=0;
 if Mode<>dbCreate then begin DBError:=dbInvalidMode;exit end;
 if FieldCount=0 then begin DBError:=dbBaseEmpty;exit end;
 S^.Seek(0);
 S^.Truncate;
 {if (VersionID=3) and (Memo<>nil) then VersionID:=Memo^.GetDBFID;}
 if VersionID=3 then
  for i:=1 to FieldCount do
   if FieldType(I)=fldMemo then
    begin
     dbError := dbMemoNotOpen;
    end;
 WriteHeader;
 S^.Write(Stru^,FieldCount*32);
 S^.Write(D,1);
 Mode:=dbOpen;
 GetMem(Buffer,RecSize);
 BlankRecord;
 RecNo:=1;
end;

Procedure TDBF.Skip(Count:longint);
var N:LongInt;Step:Integer;
begin
 if Mode=dbCreate then begin dbError:=dbInvalidMode;exit;end;
 if not SkipDeleted then
  begin
    N:=RecNo+Count;
    if N<=0 then N:=1;
    if N>RecCount then N:=Bottom;
    Go(N);
  end
  else
  begin
   if Count<0 then
    begin
     Step:=-1;Count:=-Count
    end
     else
      step:=1;
      N:=RecNo+Step;

    While (Count>0)and(RecNo>0)and(RecNo<=RecCount+1) do
     begin
      Go(N);if not IsDeleted then dec(Count);
      inc(N,Step);
     end;
   end;
end;

Procedure TDBF.Next;
begin
 if Mode=dbCreate then begin dbError:=dbInvalidMode;exit;end;
 if RecordModified then PutRecord;
 Repeat
  inc(Recno);
  GetRecord;
 Until not SkipDeleted or not isDeleted;
end;

Destructor TDBF.Done;
Const ControlZ:Char=^Z;
begin
 if RecordModified then PutRecord;
 if (Mode=dbOpen)and(GlobalChanged) then
 WriteHeader;
 if FieldCount<>0 then
 begin
  FreeMem(Stru,FieldCount*32);
  FreeMem(offset,FieldCount*2);
 end;
 if Buffer<>nil then FreeMem(Buffer,RecSize);
 if Mode=dbOpen then
  begin
   S^.Seek(HeaderSize+RecCount*RecSize);
   S^.Write(ControlZ,1);
  end;
 Dispose(S,Done);
end;

Procedure TDBF.Delete;
begin
 if Mode<>dbOpen then begin dbError:=dbInvalidMode;exit;end;
 if Buffer^[0]=' ' then
  begin
   Buffer^[0]:='*';
   RecordModified:=True;
   dbError:=0
  end
  else if Buffer^[0]='*' then dbError:=dbAlreadyDeleted else dbError:=dbInvalidData
end;

function TDBF.isDeleted:Boolean;
begin
 if Mode=dbCreate then begin dbError:=dbInvalidMode;exit;end;
 if Buffer^[0]='*' then isDeleted:=True
  else
   begin
    isDeleted:=False;
    if Buffer^[0]<>' ' then dbError:=dbInvalidData;
   end;
end;

Procedure TDBF.GetRecord;
begin
 if RecNo<=RecCount then
 S^.Read(Buffer^,RecSize) else BlankRecord;
 RecordModified:=False;
end;

Procedure TDBF.PutRecord;
begin
 S^.Seek(HeaderSize+RecSize*Pred(RecNo));
 S^.Write(Buffer^,RecSize);
 RecordModified:=False;
 if RecNo>RecCount then RecCount:=RecNo;
 GlobalChanged:=True;
end;

Procedure TDBF.BlankRecord;
begin
 RecordModified:=True;
 FillChar(Buffer^,RecSize,' ');
end;

Procedure TDBF.WriteHeader;
var H:DBFHeader;
    Y,M,D,DW:Word;
begin
 if S^.GetSize>0 then
  begin
   S^.Seek(0);
   S^.Read(H,32);
  end
 else
  begin
   FillChar(H,32,0);
   H.Version:=VersionID;
   H.HPlusD:=HeaderSize;
   H.RecLen:=RecSize;
  end;
 SysTime.GetDate(Y,M,D,DW);
 H.YY:=Y mod 100;
 H.MM:=m;
 H.dD:=D;
 H.MaxRecs:=RecCount;
 S^.Seek(0);
 S^.Write(H,32);
end;

Function TDBF.Eof:Boolean;
begin
 Eof:=RecNo>RecCount;
end;

Function TDBF.Bof:boolean;
begin
 Bof:=RecNo=1;
end;

Procedure TDBF.Recall;
begin
 if Mode<>dbOpen then dbError:=dbInvalidMode else
  begin
   if Buffer^[0]='*' then
   begin
    Buffer^[0]:=' ';
    dbError:=0;
    RecordModified:=True;
   end
     else
     if Buffer^[0]<>' ' then dbError:=dbInvalidData else
      dbError:=dbRecordNotDeleted;

  end;
end;

Procedure TDBF.SetDeleted(On:Boolean);
begin
  SkipDeleted:=not On;
end;

Procedure TDBF.Zap;
begin
 if Mode<>dbOpen then begin DBError:=dbInvalidMode; exit end;
 S^.Seek(HeaderSize);
 S^.Truncate;
 RecCount:=0;
 Go(1);
end;

Procedure TDBF.AppendFrom(P:PDBF);
var Link:TWArray;i,j:Integer;
begin
 For i:=1 to FieldCount do
  begin
   j:=P^.FieldCount;
   While (J>0) and ((Field(i)<>P^.Field(J))or(FieldType(i)<>P^.FieldType(J)))
    do dec(j);
   link[i]:=j;
  end;
 P^.Go(Top);
 While not P^.Eof do
  begin
   AppendBlank;
   For i:=1 to FieldCount do
     if Link[i]<>0 then
      case Stru^[i].Typ of
      'C':PutField(I,p^.GetField(Link[i]));
      'N':PutRealField(I,p^.GetRealField(Link[i]));
      'L':PutBooleanField(I,P^.GetBooleanField(Link[i]));
      end;
    P^.Next;
  end;
end;


(*
{TMemoFile}
Function TMemoFile.GetSize(Offset:LongInt):Word;
begin
abstract;
end;
Procedure TMemoFile.Get(Offset:Longint;var D:TMemoRec);
begin
abstract;
end;
Function TMemoFile.Put(var D:TMemoRec):LongInt;
begin
abstract;
end;
Function TMemoFile.GetDBFID:Byte;
begin
 GetDBFID:=3;
end;
Procedure TMemoFile.Free(Offset:LongInt);
begin
 abstract;
end;
*)

procedure TProtectedStream.Error(Code, Info: Integer);
begin
  MessageBox(^M+#3'Error in stream: Code = '+IntToStr(Code,CKol)+' Info = '+IntToStr(Info,CKol),nil,mfError+
  mfCancelButton);
  Halt(1);
end;



Begin




end.