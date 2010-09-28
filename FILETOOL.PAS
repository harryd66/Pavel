{$D-}
{$F+,O+}

unit FileTool;

interface

uses Dos;

type
  FileNameStr = String[12];

type
  DiskClass = (
    Floppy360, Floppy720, Floppy12, Floppy144, OtherFloppy, Bernoulli,
    HardDisk, RamDisk, SubstDrive, UnknownDisk, InvalidDrive);

const
  ExtLen = 3;

const DosDelimSet:  Set of Char = ['\', ':', #0];
const IllegalChars: Set of Char = [';',',','=','+','<','>','|','"','[',']',' '];

const
  fomCreate     = $3C00;           { Create new file }
  fomOpenRead   = $3D00;           { Read access only }
  fomOpenWrite  = $3D01;           { Write access only }
  fomOpen       = $3D02;           { Read and write access }

  fsmStart      = $0000;           { Seek at start of file }
  fsmCurrent    = $0001;           { Seek at current pos of file }
  fsmEnd        = $0002;           { Seek at end of file }

  fcmCopy       = $0000;           { Copy files }
  fcmRenMove    = $0001;           { Rename or move files }
  fcmSplice     = $0002;           { Splice files }

function HasExtension(const Name: PathStr; var DotPos: Word): Boolean;
function DefaultExtension(const Name: PathStr; Ext: ExtStr): PathStr;
function ForceExtension(const Name: PathStr; Ext: ExtStr): PathStr;
function JustFilename(const PathName: PathStr): FileNameStr;
function JustName(const PathName: PathStr): NameStr;
function JustExtension(const Name: PathStr): ExtStr;
function JustPathname(const PathName: PathStr): DirStr;
function AddBackSlash(const DirName: DirStr): DirStr;
function RemoveBackSlash(const DirName: DirStr): DirStr;
function ConvertPath(const Path: PathStr; MaxLen: Integer): String;

function TextSeek(var F: Text; Target: LongInt): Boolean;
function TextFileSize(var F: Text): LongInt;
function TextPos(var F: Text): LongInt;

function FileName(var F): PathStr;

function fOpen(const Path: PathStr; Mode: Word): Integer;
procedure fClose(Handle: Integer);
function fRead(Handle: Integer; var Buf; Count: Integer): Integer;
function fReadLn(Handle: Integer; var aStr: string): boolean;
function fWrite(Handle: Integer; var Buf; Count: Integer): Integer;
function fSeek(Handle: Integer; Pos: Longint; Mode: Word): Longint;
function fSize(Handle: Integer): Longint;
function fPosition(Handle: Integer): Longint;
function fTruncate(Handle: Integer): Integer;
function GetFTime(Handle: Integer): Longint;
procedure SetFTime(Handle: Integer; Time: Longint);
function fErase(const Path: PathStr): Integer;
function GetFileTime(const Path: PathStr): Longint;
function GetDateTime: Longint;
function GetFileSize(const Path: PathStr): Longint;
function FileExists(const Path: PathStr): Boolean;
function GetFAttr(const Path: PathStr): Integer;
function SetFAttr(const Path: PathStr; Attr: Integer): Integer;
function fRename(const F1, F2: PathStr): Integer;

function GetCurDrive: Char;
procedure SetCurDrive(Drive: Char);

function DriveValid(Drive: Char): Boolean;
function PathValid(const Path: DirStr): Boolean;
function GetCurDir(Drive: Byte): DirStr;
function IsDir(const S: PathStr): Boolean;

function GetDosError: Integer;
  inline(
    $33/$C0/                 {xor  ax,ax}
    $87/$06/DosError);       {xchg ax,DosError}

function DosVersion : Word;
  inline(
    $B4/$30/                 {mov ah,$30}
    $CD/$21/                 {int $21}
    $86/$C4);                {xchg ah,al}

function GetDiskClass(Drive: Char; var SubstDriveChar: Char): DiskClass;

{ Проверка и создание каталога }
function CheckCreateDir(aPath : DirStr) : boolean;

implementation

uses Strings;

const
  DSReadDrive  : Byte = $FF;
  DSWriteDrive : Byte = $FF;
  DSReadBig    : Byte = $00;
  DSWriteBig   : Byte = $00;


function HasExtension(const Name: PathStr; var DotPos: Word): Boolean;
var
  I : Word;
begin
  DotPos := 0;
  for I := Length(Name) downto 1 do
    if (Name[I] = '.') and (DotPos = 0) then
      DotPos := I;
  HasExtension := (DotPos > 0) and (Pos('\', Copy(Name, Succ(DotPos), 64)) = 0);
end;

function DefaultExtension(const Name: PathStr; Ext: ExtStr): PathStr;
var
  DotPos : Word;
begin
  if HasExtension(Name, DotPos) then
    DefaultExtension := Name
  else if Name = '' then
    DefaultExtension := ''
  else
    DefaultExtension := Name+'.'+Ext;
end;

function ForceExtension(const Name: PathStr; Ext: ExtStr): PathStr;
var
  DotPos : Word;
begin
  if HasExtension(Name, DotPos) then
    ForceExtension := Copy(Name, 1, DotPos)+Ext
  else if Name = '' then
    ForceExtension := ''
  else
    ForceExtension := Name+'.'+Ext;
end;

function JustExtension(const Name: PathStr): ExtStr;
var
  DotPos : Word;
begin
  if HasExtension(Name, DotPos) then
    JustExtension := Copy(Name, Succ(DotPos), ExtLen)
  else
    JustExtension := '';
end;

function JustFilename(const PathName: PathStr): FileNameStr;
var
  I : Word;
begin
  I := Succ(Word(Length(PathName)));
  repeat
    Dec(I);
  until (PathName[I] in DosDelimSet) or (I = 0);
  JustFilename := Copy(PathName, Succ(I), 64);
end;

function JustName(const PathName: PathStr): NameStr;
var
  DotPos : Byte;
  S : FileNameStr;
begin
  S := JustFileName(PathName);
  DotPos := Pos('.', S);
  if DotPos > 0 then S := Copy(S,1,DotPos-1);
  JustName := S;
end;

function JustPathname(const PathName: PathStr): DirStr;
var
  I : Word;
begin
  I := Succ(Word(Length(PathName)));
  repeat
    Dec(I);
  until (PathName[I] in DosDelimSet) or (I = 0);

  if I = 0 then
    JustPathname[0] := #0
  else if I = 1 then
    JustPathname := PathName[1]
  else if (PathName[I] = '\') then begin
    if PathName[Pred(I)] = ':' then
      JustPathname := Copy(PathName, 1, I)
    else
      JustPathname := Copy(PathName, 1, Pred(I));
  end else
    JustPathname := Copy(PathName, 1, I);
end;

function AddBackSlash(const DirName: DirStr): DirStr;
begin
  if DirName[Length(DirName)] in DosDelimSet then
    AddBackSlash := DirName
  else
    AddBackSlash := DirName+'\';
end;

function RemoveBackSlash(const DirName: DirStr): DirStr;
begin
  if DirName[Length(DirName)] = '\' then
    RemoveBackSlash := Copy(DirName,1,Length(DirName)-1);
end;

function Begins(const A, B: String): Boolean; near; assembler;
asm
     PUSH  DS
     XOR   AX,AX
     LES   DI, B
     LDS   SI, A
     LODSB
     XCHG  AX,CX
     INC   DI
     cld
     REPE  CMPSB
     MOV   AX,0
     JNE   @@1
     INC   AX
@@1: POP   DS
end;

procedure ShortenDir(var Dir: DirStr); near;
var
  B: Boolean;
  I: Integer;
begin
  if Dir = '\' then Dir := '' else
  begin
    if DIR[1] = '\' then
    begin
      B := True;
      Dir := Copy(Dir, 2, 255);
    end
    else B := False;
    if Dir[1] = '.' then Dir := Copy(Dir, 5, 255);
    I := Pos('\', Dir);
    if I <> 0 then Dir := '...\' + Copy(Dir, I + 1, 255) else Dir := '';
    if B then Dir := '\' + Dir;
  end;
end;

procedure ShortenPath(var Path: PathStr; MaxLen: Integer); near;
var
  Drive: String[3];
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  FSplit(Path, Dir, Name, Ext);
  if Dir[2] = ':' then
  begin
    Drive := Copy(Dir, 1, 2);
    Dir := Copy(Dir, 3, 255);
  end
  else Drive := '';
  while (Length(Path) > MaxLen) and ((Length(Dir) <> 0) or (Length(Drive) <>0 )) do
  begin
    if Dir = '\...\' then
    begin
      Drive := '';
      Dir := '...\';
    end
    else if Dir = '' then Drive := ''
    else ShortenDir(Dir);
    Path := Drive + Dir + Name + Ext;
  end;
end;

function ConvertPath(const Path: PathStr; MaxLen: Integer): String;
var
  Drive: String[3];
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
  CurDir: DirStr;
  Result: PathStr;
begin
  ConvertPath := '';
  if Path = '' then Exit;
  FSplit(Path, Dir, Name, Ext);
  Dir := FExpand(Dir);
  CurDir := FExpand(GetCurDir(0));
  if (CurDir = Dir) and FileExists(Name + Ext) then
  begin
    ConvertPath := Name + Ext;
    Exit;
  end;
  Drive := '';
  if (Length(Dir) > 2) and (Dir[2] = ':') then
  begin
    if (Dir[1] = 'A') or (Dir[1] = 'B') then Dir := '' else
    begin
      CurDir := GetCurDir(Ord(Upcase(Path[1]))-Ord('A')+1);
      if Length(CurDir) > 3 then CurDir := CurDir+'\';
      Dir := Copy(Dir, 3, 255);
      CurDir := Copy(CurDir, 3, 255);
      if Begins(CurDir, Dir) then Dir := Copy(Dir, Length(CurDir) + 1, 255);
    end;
    if GetCurDrive <> Path[1] then Drive := Path[1] + ':';
  end;
  Result := Drive + Dir + Name + Ext;
  ShortenPath(Result, MaxLen);
  ConvertPath := Result;
end;

function TextSeek(var F: Text; Target: LongInt): Boolean; assembler;
asm
     PUSH  DS
     LDS   SI, DWORD PTR F
     CMP   TextRec([SI]).Mode, fmInput
     JNE   @@5
     MOV   AX, 4201H
     MOV   BX, TextRec([SI]).Handle
     XOR   CX, CX
     XOR   DX, DX
     INT   21H
     JC    @@5
     SUB   AX, TextRec([SI]).BufEnd
     SBB   DX, 0
     MOV   CX, WORD PTR Target
     MOV   BX, WORD PTR Target + 2
     SUB   CX, AX
     SBB   BX, DX
     MOV   AX, CX
     MOV   DX, BX
     CMP   AX, 0
     JAE   @@1
     CMP   DX, 0
     JAE   @@1
     JMP   @@4
@@1: CMP   DX, 0
     JA    @@4
@@2: CMP   AX, TextRec([SI]).BufEnd
     JB    @@3
     JMP   @@4
@@3: MOV   TextRec([SI]).BufPos, AX
@@4: MOV   AX, 4200H
     MOV   BX, TextRec([SI]).Handle
     MOV   DX, WORD PTR Target
     MOV   CX, WORD PTR Target + 2
     INT   21H
     JC    @@5
     MOV   TextRec([SI]).BufPos, 0
     MOV   TextRec([SI]).BufEnd, 0
     MOV   AX, 1
     JMP   @@6
@@5: CLC
     XOR   AX, AX
@@6: POP   DS
end;

function TextFileSize(var F: Text): LongInt; assembler;
asm
     PUSH  DS
     LDS   SI, DWORD PTR F
     CMP   TextRec([SI]).Mode, fmClosed
     JE    @@1
     MOV   AX, 4201H
     MOV   BX, TextRec([SI]).Handle
     XOR   CX, CX
     XOR   DX, DX
     INT   21H
     JC    @@1
     PUSH  DX
     PUSH  AX
     MOV   AX, 4202H
     MOV   BX, TextRec([SI]).Handle
     XOR   CX, CX
     XOR   DX, DX
     INT   21H
     JC    @@1
     MOV   BX, DX
     POP   DX
     POP   CX
     PUSH  BX
     PUSH  AX
     MOV   AX, 4200H
     MOV   BX, TextRec([SI]).Handle
     INT   21H
     JC    @@1
     POP   AX
     POP   DX
     JMP   @@2
@@1: CLC
     MOV   DX, 0FFFFH
     MOV   AX, 0FFFFH
@@2: POP   DS
end;

function TextPos(var F: Text): LongInt; assembler;
asm
     PUSH  DS
     LDS   SI, DWORD PTR F
     CMP   TextRec([SI]).Mode, fmClosed
     JE    @@4
     MOV   AX, 4201H
     MOV   BX, TextRec([SI]).Handle
     XOR   CX, CX
     XOR   DX, DX
     INT   21H
     JC    @@4
     CMP   TextRec([SI]).Mode, fmOutput
     JNE   @@2
     ADD   AX, TextRec([SI]).BufPos
     ADC   DX, 0
@@2: CMP   TextRec([SI]).BufEnd, 0
     JE    @@3
     MOV   CX, TextRec([SI]).BufEnd
     SUB   CX, TextRec([SI]).BufPos
     SUB   AX, CX
     SBB   DX, 0
     JMP   @@3
@@4: CLC
     MOV   DX, 0FFFFH
     MOV   AX, 0FFFFH
@@3: POP   DS
end;

function FileName(var F): PathStr;
begin
  FileName := StrPas(FileRec(F).Name);
end;

procedure Pas2C; near; assembler;
asm
     MOV    DX,DI
     PUSH   SS
     POP    ES
     CLD
     LODSB
     XOR    AH,AH
     XCHG   AX,CX
     REP    MOVSB
     XCHG   AX,CX
     STOSB
     PUSH   ES
     POP    DS
end;

function fOpen(const Path: PathStr; Mode: Word): Integer; assembler;
var S: Array[0..79] of Char;
asm
     PUSH   DS
     LDS    SI,Path
     LEA    DI,S
     CALL   Pas2C
     MOV    AX,Mode
     XOR    CX,CX
     INT    21H
     JNC    @@1
     NEG    AX
@@1: POP    DS
end;

procedure fClose(Handle: Integer); assembler;
asm
     MOV    AH,3EH
     MOV    BX,Handle
     INT    21H
end;

function fRead(Handle: Integer; var Buf; Count: Integer): Integer; assembler;
asm
     PUSH   DS
     MOV    AH,3FH
     MOV    BX,Handle
     MOV    CX,Count
     LDS    DX,Buf
     INT    21H
     JNC    @@1
     NEG    AX
@@1: POP    DS
end;

function fReadLn(Handle: Integer; var aStr: string): boolean;
var
  bChar : char;
  blnOk : boolean;

begin
  blnOk := true;
  bChar := #0;
  aStr  := '';

  while blnOk and (bChar <> #13) do
    begin
      blnOk := fRead(Handle, bChar, 1) = 1;
      if blnOk and (bChar <> #13) then
        begin
          aStr := aStr + bChar;
        end;
    end;

  fReadLn := blnOk;
end;

function fWrite(Handle: Integer; var Buf; Count: Integer): Integer; assembler;
asm
     PUSH   DS
     MOV    AH,40H
     MOV    BX,Handle
     MOV    CX,Count
     LDS    DX,Buf
     INT    21H
     JNC    @@1
     NEG    AX
@@1: POP    DS
end;


function fSeek(Handle: Integer; Pos: Longint; Mode: Word): Longint; assembler;
asm
     MOV    AH,42H
     MOV    AL,BYTE PTR Mode
     MOV    BX,Handle
     MOV    DX,Pos.Word[0]
     MOV    CX,Pos.Word[2]
     INT    21H
     JNC    @@1
     NEG    AX
     CWD
@@1:
end;



function fSize(Handle: Integer): Longint;
begin
  fSize := fSeek(Handle, 0, fsmEnd);
end;

function fPosition(Handle: Integer): Longint;
begin
  fPosition := fSeek(Handle, 0, fsmCurrent);
end;

function fTruncate(Handle: Integer): Integer; assembler;
asm
     PUSH   DS
     MOV    AH,40H
     MOV    BX,Handle
     XOR    CX,CX
     INT    21H
     JNC    @@1
     NEG    AX
@@1: POP    DS
end;

function GetFTime(Handle: Integer): Longint; assembler;
asm
     MOV    AX,5700H
     MOV    BX,Handle
     INT    21H
     JNC    @@1
     MOV    AX,-1
@@1: MOV    AX,CX
end;

procedure SetFTime(Handle: Integer; Time: Longint); assembler;
asm
     MOV    AX,5701H
     MOV    BX,Handle
     MOV    CX,Time.Word[0]
     MOV    DX,Time.Word[2]
     INT    21H
     JNC    @@1
@@1:
end;

function fErase(const Path: PathStr): Integer; assembler;
var S: Array[0..79] of Char;
asm
     PUSH   DS
     LDS    SI,Path
     LEA    DI,S
     CALL   Pas2C
     MOV    AH,41H
     INT    21H
     JC     @@1
     XOR    AX,AX
@@1: NEG    AX
     POP    DS
end;

function GetFileTime(const Path: PathStr): Longint; assembler;
var
  S: Array[0..79] of Char;
  DTA: Array[0..47] of Byte;
asm
     PUSH   DS
     MOV    AH,1AH
     LEA    DX,DTA
     PUSH   SS
     POP    DS
     INT    21H
     LDS    SI,Path
     LEA    DI,S
     CALL   Pas2C
     MOV    AH,4EH
     XOR    CX,CX
     INT    21H
     MOV    AX,DTA.SearchRec.Time.Word[0]
     MOV    DX,DTA.SearchRec.Time.Word[2]
     JNC    @@1
     MOV    AX,-1
     CWD
@@1: POP    DS
end;

function FileExists(const Path: PathStr): Boolean; assembler;
asm
     LES    DI,Path
     PUSH   ES
     PUSH   DI
     CALL   GetFileTime
     AND    AX,DX
     INC    AX
     JZ     @@1
     MOV    AL,1
@@1:
end;

function GetDateTime: Longint; assembler;
asm
     MOV    AH,2AH
     INT    21H
     XCHG   AX,CX
     SUB    AX,1980
     MOV    CL,9
     SHL    AX,CL
     XOR    BX,BX
     MOV    BL,DH
     MOV    CL,5
     SHL    BX,CL
     OR     AX,BX
     OR     AL,DL
     PUSH   AX
     MOV    AH,2CH
     INT    21H
     XOR    AX,AX
     MOV    BX,CX
     XCHG   AL,BH
     MOV    CL,11
     SHL    AX,CL
     XOR    BH,BH
     MOV    CL,5
     SHL    BX,CL
     OR     AX,BX
     SHR    DH,1
     OR     AL,DH
     POP    DX
end;

function GetFileSize(const Path: PathStr): Longint;
var
  DirInfo: SearchRec;
begin
  FindFirst(Path, AnyFile, DirInfo);
  if GetDosError = 0 then
    GetFileSize := DirInfo.Size
  else GetFileSize := -1;
end;

function GetFAttr(const Path: PathStr): Integer; assembler;
var
  S: Array[0..79] of Char;
  DTA: Array[0..47] of Byte;
asm
     PUSH   DS
     MOV    AH,1AH
     LEA    DX,DTA
     PUSH   SS
     POP    DS
     INT    21H
     LDS    SI,Path
     LEA    DI,S
     CALL   Pas2C
     MOV    AH,4EH
     MOV    CX,AnyFile
     INT    21H
     MOV    AL,DTA.SearchRec.Attr
     MOV    AH,0
     JNC    @@1
     NEG    AX
@@1: POP    DS
end;

function SetFAttr(const Path: PathStr; Attr: Integer): Integer; assembler;
var S: Array[0..79] of Char;
asm
     PUSH   DS
     LDS    SI,Path
     LEA    DI,S
     CALL   Pas2C
     MOV    AH,43H
     MOV    AL,1
     MOV    CX,Attr
     INT    21H
     JC     @@1
     XOR    AX,AX
@@1: NEG    AX
     POP    DS
end;


function fRename(const F1, F2: PathStr): Integer; assembler;
var S1, S2: Array[0..79] of Char;
asm
     PUSH   DS
     LDS    SI,F2
     LEA    DI,S1
     CALL   Pas2C
     PUSH   DS
     PUSH   DX
     LDS    SI,F1
     LEA    DI,S2
     CALL   Pas2C
     POP    DI
     POP    ES
     MOV    AH,56H
     INT    21H
     JNC    @@1
     NEG    AX
     JMP    @@2
@@1: XOR    AX,AX
@@2: POP    DS
end;

function GetCurDrive: Char; assembler;
asm
     MOV    AH,19H
     INT    21H
     ADD    AL,'A'
end;

procedure SetCurDrive(Drive: Char); assembler;
asm
     MOV    AH,0EH
     MOV    DL,Drive
     SUB    DL,'A'
     INT    21H
end;

function DriveValid(Drive: Char): Boolean; assembler;
asm
     MOV    AH,19H
     INT    21H
     MOV    BL,AL
     MOV    DL,Drive
     SUB    DL,'A'
     MOV    AH,0EH
     INT    21H
     MOV    AH,19H
     INT    21H
     MOV    CX,0
     CMP    AL,DL
     JNE    @@1
     MOV    CX,1
     MOV    DL,BL
     MOV    AH,0EH
     INT    21H
@@1: XCHG   AX,CX
end;

function PathValid(const Path: DirStr): Boolean;
var
  ExpPath: PathStr;
  SR: SearchRec;
begin
  ExpPath := FExpand(Path);
  if Length(ExpPath) <= 3 then PathValid := DriveValid(ExpPath[1])
  else
  begin
    if ExpPath[Length(ExpPath)] = '\' then Dec(ExpPath[0]);
    FindFirst(ExpPath, Directory, SR);
    PathValid := (GetDosError = 0) and (SR.Attr and Directory <> 0);
  end;
end;


function GetCurDir(Drive: Byte): DirStr;
var
  CurDir: DirStr;
begin
  GetDir(Drive, CurDir);
  if Length(CurDir) > 3 then
  begin
    Inc(CurDir[0]);
    CurDir[Length(CurDir)] := '\';
  end;
  GetCurDir := CurDir;
end;



function IsDir(const S: PathStr): Boolean;
var
  SR: SearchRec;
begin
  FindFirst(S, Directory, SR);
  if GetDosError = 0 then
    IsDir := (SR.Attr and Directory <> 0)
  else IsDir := False;
end;


function GetDiskClass(Drive: Char; var SubstDriveChar: Char): DiskClass;
  {-This routine uses an undocumented DOS function ($32). Information about
    this function was obtained from Terry Dettmann's DOS Programmer's
    Reference (Que, 1988).}
type
  ParamBlock =
    record
      DriveNumber, DeviceDriverUnit : Byte;
      BytesPerSector : Word;
      SectorsPerCluster, ShiftFactor : Byte;
      ReservedBootSectors : Word;
      FatCopies : Byte;
      RootDirEntries, FirstDataSector, HighestCluster : Word;
      SectorsPerFat : Byte;
      RootDirStartingSector : Word;
      DeviceDriverAddress : Pointer;
      Media2and3 : Byte;        {media descriptor here in DOS 2.x and 3.x}
      Media4 : Byte;            {media descriptor here in DOS 4.x}
      NextDeviceParamBlock : Pointer;
    end;
  ParamBlockPtr = ^ParamBlock;
var
  DriveNum : Byte;
  MediaDescriptor : Byte;
  SvAL : Byte;
  SvDS, SvBX : Word;
begin
  GetDiskClass := InvalidDrive;
  SubstDriveChar := Drive;
  Drive := Upcase(Drive);
  case Drive of
    'A'..'Z' : DriveNum := Ord(Drive)-$40;
    else Exit;
  end;

  asm
      PUSH   DS
      MOV    AH, 1CH
      MOV    DL, DriveNum;
      INT    21H
      MOV    AH, [BX]
      MOV    MediaDescriptor, AH
      MOV    AH, 32H
      MOV    DL, DriveNum
      INT    21H
      MOV    SvAL, AL
      MOV    AX, DS
      MOV    SvDS, AX
      MOV    SvBX, BX
      POP    DS
  end;

  if (SvAL = $FF) then
   Exit;

  with ParamBlockPtr(Ptr(SvDS, SvBX))^ do begin
    {DOS 4.x has bug in $1C function}
    if (Hi(DosVersion) = 4) and (MediaDescriptor = $FF) then
      MediaDescriptor := Media4;

    {check for SUBSTituted drive}
    if (DriveNumber <> Pred(DriveNum)) then begin
      GetDiskClass := SubstDrive;
      SubstDriveChar := Char(Ord('A')+DriveNumber);
    end
    else if (FatCopies = 1) then
      {RAM disks have one copy of File Allocation Table}
      GetDiskClass := RamDisk
    else if (MediaDescriptor = $F8) then
      {MediaDescriptor of $F8 indicates hard disk}
      GetDiskClass := HardDisk
    else if (MediaDescriptor = $FD) and (SectorsPerFat <> 2) then
      {Bernoulli drives have more than 2 sectors per FAT}
      GetDiskClass := Bernoulli
    else if (MediaDescriptor >= $F9) then
      {media descriptors >= $F9 are for floppy disks}
      case HighestCluster of
        355 : GetDiskClass := Floppy360;
        714,
        1423 : GetDiskClass := Floppy720;
        2372 : GetDiskClass := Floppy12;
      else GetDiskClass := OtherFloppy;
      end
    else if (MediaDescriptor = $F0) and (HighestCluster = 2848) then
      {it's a 1.44 meg floppy}
      GetDiskClass := Floppy144
    else
      {unable to classify disk/drive}
      GetDiskClass := UnknownDisk;
  end;
end;

{ Проверка и создание каталога }
function CheckCreateDir(aPath : DirStr) : boolean;
var
  SR : SearchRec;
begin
  CheckCreateDir := false;
  FindFirst(aPath, Directory, SR);
  if DosError <> 0 then
    begin
      MkDir(aPath);
      if IOResult <> 0 then exit;
    end;
  CheckCreateDir := true;
end;

end.

