{ Copyright (C) 1998 by Cristi Streng }

{ Please read MANUAL.TXT before you use this unit }
(*
{$B-,Q-,F-,$G+}
{ Complete boolean evaluation off }
{ Overflow checking is disabled because some functions don't work with $Q+
  If you want to use it, enable it above and then put $Q-...$Q+ around line
  1535 and around line 1577 }
{ Far calls will be enabled below, for the text file interface to work }
{ Use 286 instructions - Windows 95 needs a 386 }
*)
unit DOS70;

interface

   const
      { * drive map info flags * }
      DMI_PM_LOGICAL_DRIVE     =$0001;
      DMI_PM_PHYSICAL_DRIVE    =$0002;
      DMI_PM_ONLY_DRIVE        =$0004;
      DMI_PM_EJECT             =$0008;
      DMI_PM_ASYNC_NOTIFY      =$0010;
      DMI_LOGDRIVE             =DMI_PM_LOGICAL_DRIVE;
      DMI_PHDRIVE              =DMI_PM_PHYSICAL_DRIVE;
      DMI_ONEDRIVE             =DMI_PM_ONLY_DRIVE;
      DMI_EJECT                =DMI_PM_EJECT;
      DMI_ASNOTIFY             =DMI_PM_ASYNC_NOTIFY;
      { * query close flags * }
      CL_NOTACK                =$00;
      CL_ACK                   =$01;
      CL_NOT                   =$02;
      { * file attributes * }
      FA_NORMAL                =$0000; { normal }
      FA_RDONLY                =$0001; { read-only }
      FA_HIDDEN                =$0002; { hidden }
      FA_SYSTEM                =$0004; { system }
      FA_VOLUME                =$0008; { volume label }
      FA_DIR                   =$0010; { directory }
      FA_ARC                   =$0020; { archive }
      FA_TEMP                  =$0100; { temporary file }
      FA_ANY                   =$003F; { any file }
      { * open * }
      OPEN_RDONLY              =$0000;
      OPEN_WRONLY              =$0001;
      OPEN_RDWR                =$0002;
      OPEN_RO_NOMOD            =$0004;
      OPEN_AUTOCREATE          =$0800;
      OPEN_SHARE_COMPATIBLE    =$0000;
      OPEN_SHARE_DENYREADWRITE =$0010;
      OPEN_SHARE_DENYWRITE     =$0020;
      OPEN_SHARE_DENYREAD      =$0030;
      OPEN_SHARE_DENYNONE      =$0040;
      OPEN_FLAGS_NOINHERIT     =$0080;
      OPEN_FLAGS_NOBUFFERING   =$0100;
      OPEN_FLAGS_NOCOMPRESS    =$0200;
      OPEN_FLAGS_ALIAS_HINT    =$0400;
      OPEN_FLAGS_NOCRITERR     =$2000;
      OPEN_FLAGS_COMMIT        =$4000;
      O_RDONLY                 =OPEN_RDONLY;
      O_WRONLY                 =OPEN_WRONLY;
      O_RDWR                   =OPEN_RDWR;
      O_NOMOD                  =OPEN_RO_NOMOD;
      O_CREATE                 =OPEN_AUTOCREATE;
      OS_COMP                  =OPEN_SHARE_COMPATIBLE;
      OS_DENYRW                =OPEN_SHARE_DENYREADWRITE;
      OS_DENYW                 =OPEN_SHARE_DENYWRITE;
      OS_DENYR                 =OPEN_SHARE_DENYREAD;
      OS_DENYN                 =OPEN_SHARE_DENYNONE;
      OF_NOINHERIT             =OPEN_FLAGS_NOINHERIT;
      OF_NOBUFF                =OPEN_FLAGS_NOBUFFERING;
      OF_NOCOMP                =OPEN_FLAGS_NOCOMPRESS;
      OF_ALIASHINT             =OPEN_FLAGS_ALIAS_HINT;
      OF_NOCRITERR             =OPEN_FLAGS_NOCRITERR;
      OF_COMMIT                =OPEN_FLAGS_COMMIT;
      { * seek * }
      SEEK_BEG                 =0;
      SEEK_CUR                 =1;
      SEEK_END                 =2;
      { * Volume information * }
      FS_CASE_SENSITIVE        =$0001;
      FS_CASE_PRESERVED        =$0002;
      FS_UNICODE_USED          =$0004;
      FS_LFN_APIS              =$4000;
      FS_COMPRESSED            =$8000;
      { * Char Set * }
      CS_WANSI                 =0;
      CS_OEM                   =1;
      CS_UNICODE               =2;
      { * Subst Expand * }
      NO_SUBST_EXPAND          =False;
      SUBST_EXPAND             =True;
      { * Erase Wildcards * }
      NO_WILDCARDS             =False;
      WILDCARDS                =True;
      { * Swap File Pager Type * }
      SW_NOPAGER               =1;
      SW_DOSPAGER              =2;
      SW_IOSPAGER              =3;

   { ********** Structures ********** }
   type
      LFNFile=word;
      TMapInfo=record              { GetDriveMapInfo }
         Flags:byte;
         Int13Unit:byte;           { Physical Drive Number }
         AssociatedDriveMap:comp;
         PartitionStartRBA:comp
      end;
      TVolInfo=record              { GetVolumeInformatione }
         FSName:string;            { File System Name }
         Flags:word;               { File System Flags }
         MaxFileName:word;         { Maximum File Name Length - 255 for FAT }
         MaxPath:word              { Maximum Path Length - 260 for FAT }
      end;
      TSwapInfo=record             { GetSwapFileInfo }
         FileName:string;          { Swap File Name }
         FileSize:real;            { Swap File Size }
         Pager:byte;               { Swap Pager }
      end;
      TExtFreeSpace=record         { GetExtFreeSpace }
         SectPerCluster:longint;   { Sectors per cluster }
         BytesPerSect:longint;     { Bytes per sector }
         FreeClusters:longint;     { Free clusters }
         TotClusters:longint;      { Total number of clusters }
         FreeSectNoComp:longint;   { Free sectors }
         TotSectNoComp:longint;    { Total number of sectors }
         FreeAllocUnits:longint;   { Free allocation units }
         TotAllocUnits:longint;    { Total number of allocation units }
      end;

      { LFN }
      NewDateTime=record
         Year:word;
         Month:byte;
         Day:byte;
         Hour:byte;
         Minute:byte;
         Second:byte;
         Millisecond:word
      end;
      TFindData=record             { LFNFindFirst/Next }
         Name:string;              { File Name }
         ShortName:string;         { Alternate File Name }
         Size:comp;                { File Size }
         Attrs:longint;            { File Attributes - see PASCAL help }
         TimeModified:NewDateTime;
         TimeAccessed:NewDateTime;
         TimeCreated:NewDateTime
      end;

   var
      DOS7Error:word;

   { ********** Text File Interface ********** }
   procedure AssignLFN (var f: text; const s: string);
             { Assigns the long name of an external file
               to a Pascal file variable }

   { ********** Miscellaneous functions ********** }
   function  IsDOS70:boolean;
             { Check whether you work with DOS 7.0 or newer }
   procedure GetVer (var major:byte; var minor:byte);
             { Retrieve the DOS version }
   procedure GetWinVer (var major:byte; var minor:byte);
             { Retrieve the version of your Windows }
   function  GetShell:string;
             { Retrieves the executable file name of the primary shell }
   function  GetShellComLine:string;
             { Retrieves the CONFIG.SYS SHELL= command line }
   function  GetRegistryPath:string;
             { Returns the full path of the registry file SYSTEM.DAT }
   function  GetWinNesting:byte;
             { Returns the number of instances of WIN.COM in memory }

   { ********** DOS Extensions - except long filenames ********** }
   procedure GetSwapFileInfo (var SwapInfo:TSwapInfo);
             { Retrieve information about the swap file }
   function  LockMedia (Drive:byte):byte;
             { Lock a removable media }
   function  UnlockMedia (Drive:byte):byte;
             { Unlock a removable media }
   function  GetLockCount (Drive:byte):byte;
             { Number of locks pending on the specified drive }
   procedure EjectMedia (Drive:byte);
             { Eject a removable media }
   procedure GetDriveMapInfo (Drive:byte; var MapInfo:TMapInfo);
             { Get information about a drive }
   function  GetFirstCluster (PathName:string; CharSet:byte):longint;
             { Get the first cluster of a file }
   function  ExtOpenFile (FileName:string; Attributes:word; Flags:word):word;
             { Open a file }
   function  ExtCreateFile (FileName:string; Attributes:word; Flags:word):word;
             { Creates a file }
   function  ExtTruncFile (FileName:string; Attributes:word; Flags:word):word;
             { Truncates a file }
   function  DOS7Rewrite (FileName:string):word;
             { Rewrite a file }
   function  DOS7Reset (FileName:string):word;
             { Reset a file }
   function  DOS7Append (FileName:string):word;
             { Append to a file }
   procedure FlushBuffers (Drive:byte);
             { Resets the drive and flushes the file system buffers }
   procedure FlushCache (Drive:byte);
             { Same as FlushBuffers, but also flushes and the cache }
   procedure GetExtFreeSpace (Drive:string; var DF:TExtFreeSpace);
             { Return the number of sectors, clusters, etc. of a partition }
   function  ExtDiskSize (Drive:byte):comp;
             { The size of a FAT/FAT32 partition }
   function  ExtDiskFree (Drive:byte):comp;
             { Free disk space on a FAT/FAT32 partition }
   function  ExtDiskSizeS (Drive:string):comp;
             { The size of a FAT/FAT32 partition }
   function  ExtDiskFreeS (Drive:string):comp;
             { Free disk space on a FAT/FAT32 partition }

   { ********** Virtual Machine Services ********** }
   procedure SetFocus;
             { Make the current Virtual Machine active }
   procedure SetFocusTo (VMID:word);
             { Make the specified Virtual Machine active }
   function  GetVMID:word;
             { Retrieves the ID of the current Virtual Machine }
   function  GetApplicationTitle:string;
             { Get the title of the application }
   function  GetVMTitle:string;
             { Get the title of the Virtual Machine }
   procedure SetApplicationTitle (title:string);
             { Set the title of the application }
   procedure SetVMTitle (title:string);
             { Set the title of the Virtual Machine }
   procedure AcknowledgeClose;
             { Acknowledges the close state of the close flag }
   procedure CancelClose;
             { Cancels the close operation }
   procedure EnableClose;
             { Enables the Close command in the system menu }
   procedure DisableClose;
             { Disables the Close command in the system menu }
   function  QueryClose:byte;
             { Indicates whether the user attempted to close an application
               using the Close command in the system menu }

   { ********** Long File Name functions ********** }
   procedure FileTimeToDOSTime (FileTime:comp; var DT:NewDateTime);
             { Convert the time }
   procedure DOSTimeToFileTime (DT:NewDateTime; var FileTime:comp);
             { Convert the time }
   procedure LFNMkDir (NewDir:string);
             { Create Directory }
   procedure LFNRmDir (OldDir:string);
             { Remove Directory }
   procedure LFNChDir (Dir:string);
             { Change Current Directory }
   procedure LFNErase (FileName:string; MustAttrs:byte; SearchAttrs:byte; Wildcards:boolean);
             { Erase a file; wildcards allowed }
   function  LFNGetAttrib (FileName:string):word;
             { Get the attributes of a file or directory }
   procedure LFNSetAttrib (FileName:string; Attributes:word);
             { Set the attributes of a file or directory }
   function  LFNPhysicalFileSize (FileName:string):longint;
             { Get the number of bytes occupied by the file on disk }
   procedure LFNGetModifTime (FileName:string; var DT:NewDateTime);
             { Get Last Modified Date and Time }
   procedure LFNSetModifTime (FileName:string; DT:NewDateTime);
             { Set Last Modified Date and Time }
   procedure LFNGetAccessTime (FileName:string; var DT:NewDateTime);
             { Get Last Access Date and Time }
   procedure LFNSetAccessTime (FileName:string; DT:NewDateTime);
             { Set Last Access Date and Time }
   procedure LFNGetCreateTime (FileName:string; var DT:NewDateTime);
             { Get Creation Date and Time }
   procedure LFNSetCreateTime (FileName:string; DT:NewDateTime);
             { Set Creation Date and Time }
   procedure LFNHGetModifTime (Handle:word; var DT:NewDateTime);
             { Get Last Access Date and Time }
   procedure LFNHSetModifTime (Handle:word; DT:NewDateTime);
             { Set Last Access Date and Time }
   procedure LFNHGetAccessTime (Handle:word; var DT:NewDateTime);
             { Get Last Access Date and Time }
   procedure LFNHSetAccessTime (Handle:word; DT:NewDateTime);
             { Set Last Access Date and Time }
   procedure LFNHGetCreateTime (Handle:word; var DT:NewDateTime);
             { Get Creation Date and Time }
   procedure LFNHSetCreateTime (Handle:word; DT:NewDateTime);
             { Set Creation Date and Time }
   function  LFNGetDir (Drive:byte):string;
             { Get Current Directory }
   function  LFNFindFirst (FileName:string; MustAttrs:byte; SearchAttrs:byte; var FindData:TFindData):word;
             { Find First File Matching FileName }
   procedure LFNFindNext (Handle:word; var FindData:TFindData);
             { Find Next Matching File }
   procedure LFNFindClose (Handle:word);
             { Close a Handle for Find First/Next }
   procedure LFNRename (OldName:string; NewName:string);
             { Rename a File }
   function  GetFullPathName (SourcePath:string; SubstExpand:boolean):string;
             { Get the full path of a file or directory }
   function  GetShortPathName (SourcePath:string; SubstExpand:boolean):string;
             { Get the short path (8.3) of a file or directory }
   function  GetLongPathName (SourcePath:string; SubstExpand:boolean):string;
             { Get the long path of a file or directory }
   function  LFNOpenFile (FileName:string; Attributes:word; Flags:word; AliasHint:word):word;
             { Open a file with a long name }
   function  LFNCreateFile (FileName:string; Attributes:word; Flags:word; AliasHint:word):word;
             { Create a file with a long name }
   function  LFNTruncateFile (FileName:string; Attributes:word; Flags:word; AliasHint:word):word;
             { Truncate a file with a long name }
   function  LFNRewrite (FileName:string):word;
             { Rewrite a file }
   function  LFNReset (FileName:string):word;
             { Reset a file }
   function  LFNAppend (FileName:string):word;
             { Append to a file }
   function  LFNBlockRead (Handle:word; var Buffer; Size:word):word;
             { Read a file }
   function  LFNBlockWrite (Handle:word; var Buffer; Size:word):word;
             { Write to a file }
   function  LFNSeek (Handle:word; Origin:byte; Offset:longint):longint;
             { Write to a file }
   procedure LFNCloseFile (Handle:word);
             { Close a file }
   procedure GetVolumeInformation (RootName:string; var VolInfo:TVolInfo);
             { Get informations about a specified volume }
   function  LFNGenShortName (LFN:string; CharSet:byte):string;
             { Generate a short filename for a long filename }
   procedure CreateSubst (Drive:byte; Path:string);
             { Associates a path with a drive letter }
   procedure TerminateSubst (Drive:byte);
             { Terminates a subst }
   function  GetSubst (Drive:byte):string;
             { Determine if a drive letter is associated with a path }

implementation

{$IFDEF Windows}
uses windos;
type Registers=TRegisters;
{$ELSE}
uses dos;
{$ENDIF}
var
   R:Registers;
   LFNName: String;
   { This is a kludge, needed because TextRec.Name is too short for a LFN.}
   { Imposes constraint: after AssignLFN, must open file before the }
   { next call to AssignLFN.}


procedure FileTimeToDOSTime;
var
   R:Registers;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$71A7;
  R.BX:=0;
  R.SI:=Ofs(FileTime);
  R.DS:=Seg(FileTime);
  DOS7Error:=0; MsDOS (R);
  DT.Year:=R.DX shr 9+1980;
  DT.Month:=R.DX shr 5 and $0F;
  DT.Day:=R.DX and $1F;
  DT.Hour:=R.CX shr 11;
  DT.Minute:=R.CX shr 5 and $3F;
  DT.Second:=R.CX and $1F*2+R.BH div 100;
  DT.Millisecond:=R.BH mod 100*10;
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure DOSTimeToFileTime;
var
   R:Registers;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$71A7;
  R.BX:=(DT.Second mod 2*100+DT.Millisecond div 10) shl 8+1;
  R.CX:=DT.Hour shl 11+DT.Minute shl 5+DT.Second div 2;
  R.DX:=(DT.Year-1980) shl 9+DT.Month shl 5+DT.Day;
  R.DI:=Ofs(FileTime);
  R.ES:=Seg(FileTime);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

{$IFDEF VER55}
procedure TP55Intr2F; { by Arnoud Lambers <mta-mm@vip.cybercity.dk> }
(* Replacement for Intr($2F,R) call in unit DOS70 (doesn't work in TP 5.5) *)
(* Using this method, EXAMPLE3.PAS works fine                              *)
(* Note: only AX and BX registers are returned!                            *)
type L2W = record case byte of 0: (AX,BX: word); 1: (ABX: longint) end;
var tmp_r: L2W;
  function InlineInt2F(AX,BX,CX,DX,DI,ES: word): longint;
  inline($07/$5F/$5A/$59/$5B/$58/   { POP ES;DI;DX;CX;BX;AX }
         $55/$CD/$2F/$5D/           { PUSH BP; INT 2F; POP BP }
         $89/$DA);                  { MOV DX,BX (returns BX and AX) }
begin
  with R do tmp_r.ABX := InlineInt2F(AX,BX,CX,DX,DI,ES);
  R.AX := tmp_r.AX; R.BX := tmp_r.BX;
end;
{$ENDIF}

{ Text file interface }
{ The following functions provide the services needed by text file devices.}
{ See Chapter 14 of the Borland Pascal Language Guide.}
{$F+}
{$IFDEF Windows}
function LFNFileClose (var F: TTextRec): Integer;
{$ELSE}
function LFNFileClose (var F: TextRec): Integer;
{$ENDIF}
begin
  LFNCloseFile (F.Handle);
  LFNFileClose := Dos7Error;
end;

{$IFDEF Windows}
function LFNFileRead (var F: TTextRec): Integer;
{$ELSE}
function LFNFileRead (var F: TextRec): Integer;
{$ENDIF}
begin
  if (F.BufEnd = 0) or (F.BufPos >= F.BufEnd) then
  begin
    F.BufEnd := LFNBlockRead (F.Handle, F.BufPtr^, F.BufSize);
    F.BufPos := 0;
    LFNFileRead := Dos7Error;
  end
  else
    LFNFileRead := 0;
end;

{$IFDEF Windows}
function LFNFileWrite (var F: TTextRec): Integer;
{$ELSE}
function LFNFileWrite (var F: TextRec): Integer;
{$ENDIF}
begin
  LFNBlockWrite (F.Handle, F.BufPtr^, F.BufPos);
  F.BufPos := 0;
  LFNFileWrite := Dos7Error;
end;

{$IFDEF Windows}
function LFNFileOpen (var F: TTextRec): Integer;
{$ELSE}
function LFNFileOpen (var F: TextRec): Integer;
{$ENDIF}
var
  Status: Integer;
begin
  if (F.Mode = fmInput) then
  begin  { open for read }
    F.Handle := LFNReset (LFNName);
    Status := Dos7Error;
    F.InOutFunc := @LFNFileRead;
    F.FlushFunc := @LFNFileRead;
    F.CloseFunc := @LFNFileClose;
  end
  else if (F.Mode = fmOutput) then
  begin  { open for write }
    F.Handle := LFNRewrite (LFNName);
    Status := Dos7Error;
    F.InOutFunc := @LFNFileWrite;
    F.FlushFunc := @LFNFileWrite;
    F.CloseFunc := @LFNFileClose;
  end
  else if (F.Mode = fmInOut) then
  begin  { open for append }
    F.Handle := LFNAppend (LFNName);
    Status := Dos7Error;
    if (Status = 0) then
      F.Mode := fmOutput;
    F.InOutFunc := @LFNFileWrite;
    F.FlushFunc := @LFNFileWrite;
    F.CloseFunc := @LFNFileClose;
  end
  else
    { Fail }
    Status := 5;
  LFNFileOpen := Status;
end;
{$F-}



{ Set up the TextRec structure for file F. Store name in LFN name until }
{ the file is opened.}
procedure AssignLFN;
begin
{$IFDEF Windows}
  with TTextRec(F) do
{$ELSE}
  with TextRec(F) do
{$ENDIF}
  begin
    Handle := $FFFF;
    Mode := fmClosed;
    BufSize := SizeOf (Buffer);
    BufPtr := @Buffer;
    OpenFunc := @LFNFileOpen;
    Name[0] := #0;
  end;
  LFNName := S;
end;
{ End of text file interface }

function IsDOS70;
var
   major,minor:byte;
begin
  GetVer (major, minor);
  IsDOS70:=(major>=7)
end;

procedure GetVer;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$3001;
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  minor:=R.AH;
  major:=R.AL
end;

procedure GetWinVer;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$160A;
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  if R.AX<>0 then
    DOS7Error:=$FF;
  major:=R.BH;
  minor:=R.BL
end;

function GetShell;
type
   MyPChar=array [0..255] of char;
var
   Shell:string;
   i:byte;
   pc:^MyPChar;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$4A33;
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  if R.AX<>0 then
    DOS7Error:=$FF;
  pc:=Ptr (R.DS, R.DX);
  Move (pc^, Shell[1], 255);
  i:=1;
  while Shell[i]<>#0 do
    inc (i);
  Shell[0]:=Chr(i-1);
  GetShell:=Shell
end;

function GetShellComLine;
type
   MyPChar=array [0..255] of char;
var
   ComLine:string;
   pc:^MyPChar;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$4A33;
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  if R.AX<>0 then
    DOS7Error:=$FF;
  pc:=Ptr (R.DS, R.SI);
  Move (pc^, ComLine, ord (pc^[0])+1);
  GetShellComLine:=ComLine
end;

function GetRegistryPath;
var
   p:string;
   i:byte;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$1613;
  R.CX:=$FF;
  R.ES:=Seg (p[1]);
  R.DI:=Ofs (p[1]);
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  if R.AX<>0 then
    DOS7Error:=$FF;
  i:=1;
  while p[i]<>#0 do
    inc (i);
  p[0]:=Chr(i-1);
  GetRegistryPath:=p
end;

function GetWinNesting;
var
   i:byte;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$4B21;
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  GetWinNesting:=R.AL
end;

procedure GetSwapFileInfo;
var
   i:byte;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$440D;
  R.CX:=$086E;
  R.DX:=Ofs (SwapInfo.FileName [1]);
  R.DS:=Seg (SwapInfo.FileName [1]);
  DOS7Error:=0; MsDOS (R);
  i:=1;
  while SwapInfo.FileName[i]<>#0 do
    inc (i);
  SwapInfo.FileName[0]:=Chr(i-1);
  SwapInfo.FileSize:=(R.CX*65536.+R.BX)*4096.;
  SwapInfo.Pager:=R.AX;
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

function LockMedia;
var
   ParamBlock:record
      Operation:byte;
      NumLocks:byte
   end;
begin
  FillChar (R, SizeOf (R), 0);
  ParamBlock.Operation:=0;
  R.AX:=$440D;
  R.BX:=Drive;
  R.CX:=$0848;
  R.DX:=Ofs(ParamBlock);
  R.DS:=Seg(ParamBlock);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  LockMedia:=ParamBlock.NumLocks
end;

function UnlockMedia;
var
   ParamBlock:record
      Operation:byte;
      NumLocks:byte
   end;
begin
  FillChar (R, SizeOf (R), 0);
  ParamBlock.Operation:=1;
  R.AX:=$440D;
  R.BX:=Drive;
  R.CX:=$0848;
  R.DX:=Ofs(ParamBlock);
  R.DS:=Seg(ParamBlock);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  UnlockMedia:=ParamBlock.NumLocks
end;

function GetLockCount;
var
   ParamBlock:record
      Operation:byte;
      NumLocks:byte
   end;
begin
  FillChar (R, SizeOf (R), 0);
  ParamBlock.Operation:=2;
  R.AX:=$440D;
  R.BX:=Drive;
  R.CX:=$0848;
  R.DX:=Ofs(ParamBlock);
  R.DS:=Seg(ParamBlock);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  GetLockCount:=ParamBlock.NumLocks
end;

procedure EjectMedia;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$440D;
  R.BX:=Drive;
  R.CX:=$0849;
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure GetDriveMapInfo;
var
   OMapInfo:record
      AllocationLength:byte;
      InfoLength:byte;
      Flags:byte;
      Int13Unit:byte;
      DriveMap:longint;
      StartRBA:comp
   end;
begin
  FillChar (R, SizeOf (R), 0);
  OMapInfo.AllocationLength:=SizeOf (OMapInfo);
  R.AX:=$440D;
  R.BX:=Drive;
  R.CX:=$086F;
  R.DX:=Ofs(OMapInfo);
  R.DS:=Seg(OMapInfo);
  DOS7Error:=0; MsDOS (R);
  MapInfo.Flags:=OMapInfo.Flags;
  MapInfo.Int13Unit:=OMapInfo.Int13Unit;
  MapInfo.AssociatedDriveMap:=OMapInfo.DriveMap;
  MapInfo.PartitionStartRBA:=OMapInfo.StartRBA;
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

function GetFirstCluster;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=PathName+#0;
  R.AX:=$440D;
  R.BX:=CharSet;
  R.CX:=$0871;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  GetFirstCluster:=R.DX shl 16+R.AX
end;

function ExtOpenFile;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$6C00;
  R.DX:=$01;
  if (Flags and OPEN_AUTOCREATE)<>0 then
  begin
    Inc (R.DX, $10);
    Dec (Flags, OPEN_AUTOCREATE)
  end;
  R.BX:=Flags;
  R.CX:=$00;
  R.DS:=Seg(p[1]);
  R.SI:=Ofs(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  ExtOpenFile:=R.AX
end;

function ExtCreateFile;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$6C00;
  R.BX:=Flags;
  R.CX:=Attributes;
  R.DX:=$10;
  R.DS:=Seg(p[1]);
  R.SI:=Ofs(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  ExtCreateFile:=R.AX
end;

function ExtTruncFile;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$6C00;
  R.DX:=$02;
  if (Flags and OPEN_AUTOCREATE)<>0 then
  begin
    Inc (R.DX, $10);
    Dec (Flags, OPEN_AUTOCREATE)
  end;
  R.BX:=Flags;
  R.CX:=Attributes;
  R.DS:=Seg(p[1]);
  R.SI:=Ofs(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  ExtTruncFile:=R.AX
end;

function DOS7Rewrite;
begin
  DOS7Rewrite:=ExtTruncFile (FileName, FA_NORMAL, OPEN_WRONLY+OPEN_AUTOCREATE)
end;

function DOS7Reset;
begin
  DOS7Reset:=ExtOpenFile (FileName, FA_NORMAL, OPEN_RDONLY)
end;

function DOS7Append;
var
   f:word;
begin
  f:=ExtOpenFile (FileName, FA_NORMAL, OPEN_WRONLY);
  if DOSError=0 then
    LFNSeek (f, SEEK_END, 0); { go to the end of file }
  DOS7Append:=f
end;

procedure FlushBuffers;
begin
  FillChar (R, sizeof (R), 0);
  R.AX:=$710D;
  R.CX:=$0000;
  R.DX:=Drive;
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
end;

procedure FlushCache;
begin
  FillChar (R, sizeof (R), 0);
  R.AX:=$710D;
  R.CX:=$0001;
  R.DX:=Drive;
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
end;

procedure GetExtFreeSpace;
var
   p:string;
   buf:array [0..43] of byte;
begin
  p:=Drive+#0;
  FillChar (buf, sizeof (buf), 0);
  R.AX:=$7303;
  R.CX:=44; { sizeof (buf) }
  R.DS:=Seg(p[1]);
  R.DX:=Ofs(p[1]);
  R.ES:=Seg(buf);
  R.DI:=Ofs(buf);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  Move (buf[4], DF, 32)
end;

function ExtDiskSize;
var
   df:TExtFreeSpace;
   s:string;
   drv:byte;
begin
  drv:=Drive;
  if (drv=0) then
  begin
    GetDir (0, s);
    drv:=ord (s[1])-64
  end;
  s:=chr (drv+64)+':\';
  GetExtFreeSpace (s, df);
  ExtDiskSize:=df.BytesPerSect*df.SectPerCluster*df.TotClusters
end;

function ExtDiskFree;
var
   df:TExtFreeSpace;
   s:string;
   drv:byte;
begin
  drv:=Drive;
  if (drv=0) then
  begin
    GetDir (0, s);
    drv:=ord (s[1])-64
  end;
  s:=chr (drv+64)+':\';
  GetExtFreeSpace (s, df);
  ExtDiskFree:=df.BytesPerSect*df.SectPerCluster*df.FreeClusters
end;

function ExtDiskSizeS;
var
   df:TExtFreeSpace;
begin
  GetExtFreeSpace (Drive, df);
  ExtDiskSizeS:=df.BytesPerSect*df.SectPerCluster*df.TotClusters
end;

function ExtDiskFreeS;
var
   df:TExtFreeSpace;
begin
  GetExtFreeSpace (Drive, df);
  ExtDiskFreeS:=df.BytesPerSect*df.SectPerCluster*df.FreeClusters
end;


procedure SetFocus;
begin
  SetFocusTo (0);
end;

procedure SetFocusTo;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$168B;
  R.BX:=VMID;
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  if R.AL<>0 then
    DOS7Error:=$FF
end;

function GetVMID;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$1683;
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  GetVMID:=R.BX
end;

function GetApplicationTitle;
var
   p:string;
   i:byte;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$168E;
  R.CX:=80;
  R.DX:=2;
  R.DI:=Ofs (p[1]);
  R.ES:=Seg (p[1]);
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  i:=1;
  while p[i]<>#0 do
    inc (i);
  p[0]:=Chr(i-1);
  if R.AX<>1 then
    DOS7Error:=$FF;
  GetApplicationTitle:=p
end;

function GetVMTitle;
var
   p:string;
   i:byte;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$168E;
  R.CX:=80;
  R.DX:=3;
  R.DI:=Ofs (p[1]);
  R.ES:=Seg (p[1]);
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  i:=1;
  while p[i]<>#0 do
    inc (i);
  p[0]:=Chr(i-1);
  if R.AX<>1 then
    DOS7Error:=$FF;
  GetVMTitle:=p
end;

procedure SetApplicationTitle;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=title+#0;
  R.AX:=$168E;
  R.CX:=80;
  R.DX:=0;
  R.DI:=Ofs (p[1]);
  R.ES:=Seg (p[1]);
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  if R.AX<>1 then
    DOS7Error:=$FF
end;

procedure SetVMTitle;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=title+#0;
  R.AX:=$168E;
  R.CX:=80;
  R.DX:=1;
  R.DI:=Ofs (p[1]);
  R.ES:=Seg (p[1]);
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  if R.AX<>1 then
    DOS7Error:=$FF
end;

procedure AcknowledgeClose;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$168F;
  R.DX:=$200;
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  if R.AX<>0 then
    DOS7Error:=$FF
end;

procedure CancelClose;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$168F;
  R.DX:=$300;
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  if R.AX<>0 then
    DOS7Error:=$FF
end;

procedure EnableClose;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$168F;
  R.DX:=1;
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  if R.AX<>0 then
    DOS7Error:=$FF
end;

procedure DisableClose;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$168F;
  R.DX:=0;
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  if R.AX<>0 then
    DOS7Error:=$FF
end;

function QueryClose;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$168F;
  R.DX:=$100;
  DOS7Error:=0;
  {$IFDEF VER55}
  TP55Intr2F;
  {$ELSE}
  Intr ($2F, R);
  {$ENDIF}
  if (R.AX<>0) and (R.AX<>1) then
    R.AX:=2;
  QueryClose:=R.AX
end;


procedure LFNMkDir;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=NewDir+#0;
  R.AX:=$7139;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNRmDir;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=OldDir+#0;
  R.AX:=$713A;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNChDir;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=Dir+#0;
  R.AX:=$713B;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
  begin
    DOS7Error:=R.AL;
    Exit
  end;
  if Dir [2]=':' then
  begin
    R.AX:=$0E00;
    R.DX:=Ord (UpCase(Dir[1]))-65;
    DOS7Error:=0; MsDOS (R);
    if (R.Flags and fCarry)<>0 then
      DOS7Error:=R.AL
  end
end;

procedure LFNErase;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$7141;
  R.CX:=MustAttrs shl 8+SearchAttrs;
  R.DX:=Ofs(p[1]);
  R.SI:=Ord(Wildcards);
  R.DS:=Seg(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

function LFNGetAttrib;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$7143;
  R.BX:=$00;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  LFNGetAttrib:=R.CX
end;

procedure LFNSetAttrib;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$7143;
  R.BX:=$01;
  R.CX:=Attributes;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

function LFNPhysicalFileSize;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$7143;
  R.BX:=$02;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  LFNPhysicalFileSize:=R.DX shl 16+R.AX
end;

procedure LFNGetModifTime;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$7143;
  R.BX:=$04;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  DOS7Error:=0; MsDOS (R);
  DT.Year:=R.DI shr 9+1980;
  DT.Month:=R.DI shr 5 and $0F;
  DT.Day:=R.DI and $1F;
  DT.Hour:=R.CX shr 11;
  DT.Minute:=R.CX shr 5 and $3F;
  DT.Second:=R.CX and $1F*2;
  DT.Millisecond:=0;
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNSetModifTime;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$7143;
  R.BX:=$03;
  R.CX:=DT.Hour shl 11+DT.Minute shl 5+DT.Second div 2;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  R.DI:=(DT.Year-1980) shl 9+DT.Month shl 5+DT.Day;
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNGetAccessTime;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$7143;
  R.BX:=$06;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  DOS7Error:=0; MsDOS (R);
  DT.Year:=R.DI shr 9+1980;
  DT.Month:=R.DI shr 5 and $0F;
  DT.Day:=R.DI and $1F;
  DT.Hour:=0;
  DT.Minute:=0;
  DT.Second:=0;
  DT.Millisecond:=0;
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNSetAccessTime;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$7143;
  R.BX:=$05;
  R.CX:=0;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  R.DI:=(DT.Year-1980) shl 9+DT.Month shl 5+DT.Day;
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNGetCreateTime;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$7143;
  R.BX:=$08;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  DOS7Error:=0; MsDOS (R);
  DT.Year:=R.DI shr 9+1980;
  DT.Month:=R.DI shr 5 and $0F;
  DT.Day:=R.DI and $1F;
  DT.Hour:=R.CX shr 11;
  DT.Minute:=R.CX shr 5 and $3F;
  DT.Second:=R.CX and $1F*2+R.SI div 100;
  DT.Millisecond:=R.SI mod 100*10;
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNSetCreateTime;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$7143;
  R.BX:=$07;
  R.CX:=DT.Hour shl 11+DT.Minute shl 5+DT.Second div 2;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  R.SI:=DT.Second mod 2*100+DT.Millisecond div 10;
  R.DI:=(DT.Year-1980) shl 9+DT.Month shl 5+DT.Day;
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNHGetModifTime;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$5700;
  R.BX:=Handle;
  DOS7Error:=0; MsDOS (R);
  DT.Year:=R.DI shr 9+1980;
  DT.Month:=R.DI shr 5 and $0F;
  DT.Day:=R.DI and $1F;
  DT.Hour:=R.CX shr 11;
  DT.Minute:=R.CX shr 5 and $3F;
  DT.Second:=R.CX and $1F*2;
  DT.Millisecond:=0;
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNHSetModifTime;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$5701;
  R.BX:=Handle;
  R.CX:=DT.Hour shl 11+DT.Minute shl 5+DT.Second div 2;
  R.DI:=(DT.Year-1980) shl 9+DT.Month shl 5+DT.Day;
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNHGetAccessTime;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$5704;
  R.BX:=Handle;
  DOS7Error:=0; MsDOS (R);
  DT.Year:=R.DI shr 9+1980;
  DT.Month:=R.DI shr 5 and $0F;
  DT.Day:=R.DI and $1F;
  DT.Hour:=0;
  DT.Minute:=0;
  DT.Second:=0;
  DT.Millisecond:=0;
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNHSetAccessTime;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$5705;
  R.BX:=Handle;
  R.CX:=0;
  R.DI:=(DT.Year-1980) shl 9+DT.Month shl 5+DT.Day;
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNHGetCreateTime;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$5706;
  R.BX:=Handle;
  DOS7Error:=0; MsDOS (R);
  DT.Year:=R.DI shr 9+1980;
  DT.Month:=R.DI shr 5 and $0F;
  DT.Day:=R.DI and $1F;
  DT.Hour:=R.CX shr 11;
  DT.Minute:=R.CX shr 5 and $3F;
  DT.Second:=R.CX and $1F*2+R.SI div 100;
  DT.Millisecond:=R.SI mod 100*10;
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNHSetCreateTime;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$5707;
  R.BX:=Handle;
  R.CX:=DT.Hour shl 11+DT.Minute shl 5+DT.Second div 2;
  R.SI:=DT.Second mod 2*100+DT.Millisecond div 10;
  R.DI:=(DT.Year-1980) shl 9+DT.Month shl 5+DT.Day;
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

function LFNGetDir;
var
   Dir:string;
   i:byte;
   s:string;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$7147;
  R.DX:=Drive;
  R.SI:=Ofs(Dir[1]);
  R.DS:=Seg(Dir[1]);
  DOS7Error:=0; MsDOS (R);
  i:=1;
  while Dir[i]<>#0 do
    inc (i);
  Dir[0]:=Chr(i-1);
  if Drive=0 then
  begin
    GetDir (0, s);
    Drive:=Ord (s[1])-64
  end;
  Dir:=Chr(Drive+64)+':\'+Dir;
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  LFNGetDir:=Dir
end;

function LFNFindFirst;
var
   p:string;
   FD:record
      FileAttributes:longint;
      CreationTime:comp;
      AccessTime:comp;
      WriteTime:comp;
      FileSizeHigh:longint;
      FileSizeLow:longint;
      Reserved:comp;
      FullName:array [0..259] of char;
      ShortName:array [0..13] of char
   end;
   i:byte;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$714E;
  R.CX:=MustAttrs shl 8+SearchAttrs;
  R.DX:=Ofs(p[1]);
  R.SI:=0; { DateTimeFormat }
  R.DI:=Ofs(FD);
  R.DS:=Seg(p[1]);
  R.ES:=Seg(FD);
  DOS7Error:=0; MsDOS (R);
  Move (FD.FullName [0], FindData.Name [1], 255);
  i:=1;
  while FindData.Name[i]<>#0 do
    inc (i);
  FindData.Name[0]:=Chr(i-1);
  Move (FD.ShortName[0], FindData.ShortName[1], 14);
  i:=1;
  while FindData.ShortName[i]<>#0 do
    inc (i);
  FindData.ShortName[0]:=Chr(i-1);
  FindData.Size:=FD.FileSizeHigh shl 16+FD.FileSizeLow;
  FindData.Attrs:=FD.FileAttributes;
  FileTimeToDOSTime (FD.CreationTime, FindData.TimeCreated);
  FileTimeToDOSTime (FD.AccessTime, FindData.TimeAccessed);
  FileTimeToDOSTime (FD.WriteTime, FindData.TimeModified);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  LFNFindFirst:=R.AX
end;

procedure LFNFindNext;
var
   FD:record
      FileAttributes:longint;
      CreationTime:comp;
      AccessTime:comp;
      WriteTime:comp;
      FileSizeHigh:longint;
      FileSizeLow:longint;
      Reserved:comp;
      FullName:array [0..259] of char;
      ShortName:array [0..13] of char
   end;
   i:byte;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$714F;
  R.BX:=Handle;
  R.SI:=0;
  R.DI:=Ofs(FD);
  R.ES:=Seg(FD);
  DOS7Error:=0; MsDOS (R);
  Move (FD.FullName[0], FindData.Name[1], 255);
  i:=1;
  while FindData.Name[i]<>#0 do
    inc (i);
  FindData.Name[0]:=Chr(i-1);
  Move (FD.ShortName[0], FindData.ShortName[1], 14);
  i:=1;
  while FindData.ShortName[i]<>#0 do
    inc (i);
  FindData.ShortName[0]:=Chr(i-1);
  FindData.Size:=FD.FileSizeHigh shl 16+FD.FileSizeLow;
  FindData.Attrs:=FD.FileAttributes;
  FileTimeToDOSTime (FD.CreationTime, FindData.TimeCreated);
  FileTimeToDOSTime (FD.AccessTime, FindData.TimeAccessed);
  FileTimeToDOSTime (FD.WriteTime, FindData.TimeModified);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNFindClose;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$71A1;
  R.BX:=Handle;
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure LFNRename;
var
   p,q:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=OldName+#0;
  q:=NewName+#0;
  R.AX:=$7156;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  R.DI:=Ofs(q[1]);
  R.ES:=Seg(q[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

function GetFullPathName;
var
   Dir:string;
   p:string;
   i:byte;
begin
  FillChar (R, SizeOf (R), 0);
  p:=SourcePath+#0;
  R.AX:=$7160;
  R.CX:=Ord(SubstExpand) shl 15;
  R.SI:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  R.DI:=Ofs(Dir[1]);
  R.ES:=Seg(Dir[1]);
  DOS7Error:=0; MsDOS (R);
  i:=1;
  while Dir[i]<>#0 do
    inc (i);
  Dir[0]:=Chr(i-1);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  GetFullPathName:=Dir
end;

function GetShortPathName;
var
   Dir:string;
   p:string;
   i:byte;
begin
  FillChar (R, SizeOf (R), 0);
  p:=SourcePath+#0;
  R.AX:=$7160;
  R.CX:=Ord(SubstExpand) shl 15+1;
  R.SI:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  R.DI:=Ofs(Dir[1]);
  R.ES:=Seg(Dir[1]);
  DOS7Error:=0; MsDOS (R);
  i:=1;
  while Dir[i]<>#0 do
    inc (i);
  Dir[0]:=Chr(i-1);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  GetShortPathName:=Dir
end;

function GetLongPathName;
var
   Dir:string;
   p:string;
   i:byte;
begin
  FillChar (R, SizeOf (R), 0);
  p:=SourcePath+#0;
  R.AX:=$7160;
  R.CX:=Ord(SubstExpand) shl 15+2;
  R.SI:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  R.DI:=Ofs(Dir[1]);
  R.ES:=Seg(Dir[1]);
  DOS7Error:=0; MsDOS (R);
  i:=1;
  while Dir[i]<>#0 do
    inc (i);
  Dir[0]:=Chr(i-1);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  GetLongPathName:=Dir
end;

function LFNOpenFile;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$716C;
  R.DX:=$01;
  if (Flags and OPEN_AUTOCREATE)<>0 then
  begin
    Inc (R.DX, $10);
    Dec (Flags, OPEN_AUTOCREATE)
  end;
  R.BX:=Flags;
  R.CX:=$00;
  R.DI:=AliasHint;
  R.DS:=Seg(p[1]);
  R.SI:=Ofs(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  LFNOpenFile:=R.AX
end;

function LFNCreateFile;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$716C;
  R.BX:=Flags;
  R.CX:=Attributes;
  R.DX:=$10;
  R.DI:=AliasHint;
  R.DS:=Seg(p[1]);
  R.SI:=Ofs(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  LFNCreateFile:=R.AX
end;

function LFNTruncateFile;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=FileName+#0;
  R.AX:=$716C;
  R.DX:=$02;
  if (Flags and OPEN_AUTOCREATE)<>0 then
  begin
    Inc (R.DX, $10);
    Dec (Flags, OPEN_AUTOCREATE)
  end;
  R.BX:=Flags;
  R.CX:=Attributes;
  R.DI:=AliasHint;
  R.DS:=Seg(p[1]);
  R.SI:=Ofs(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  LFNTruncateFile:=R.AX
end;

function LFNBlockRead;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$3F00;
  R.BX:=Handle;
  R.CX:=Size;
  R.DX:=Ofs(Buffer);
  R.DS:=Seg(Buffer);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  LFNBlockRead:=R.AX
end;

function LFNBlockWrite;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$4000;
  R.BX:=Handle;
  R.CX:=Size;
  R.DX:=Ofs(Buffer);
  R.DS:=Seg(Buffer);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  LFNBlockWrite:=R.AX
end;

function LFNSeek;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$4200+Origin;
  R.BX:=Handle;
  R.CX:=Offset shr 16;
  R.DX:=Offset and $FFFF;
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  LFNSeek:=R.DX shl 16+R.AX
end;

procedure LFNCloseFile;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$3E00;
  R.BX:=Handle;
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure GetVolumeInformation;
var
   p:string;
   i:byte;
begin
  FillChar (R, SizeOf (R), 0);
  p:=RootName+#0;
  R.AX:=$71A0;
  R.CX:=$FE;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  R.DI:=Ofs(VolInfo.FSName[1]);
  R.ES:=Seg(VolInfo.FSName[1]);
  DOS7Error:=0; MsDOS (R);
  i:=1;
  while VolInfo.FSName[i]<>#0 do
    inc (i);
  VolInfo.FSName[0]:=Chr(i-1);
  VolInfo.Flags:=R.BX;
  VolInfo.MaxFileName:=R.CX;
  VolInfo.MaxPath:=R.DX;
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

function LFNGenShortName;
var
   p,q:string;
   i:byte;
begin
  FillChar (R, SizeOf (R), 0);
  p:=LFN+#0;
  R.AX:=$71A8;
  R.DX:=$0100+CharSet;
  R.SI:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  R.DI:=Ofs(q[1]);
  R.ES:=Seg(q[1]);
  DOS7Error:=0; MsDOS (R);
  i:=1;
  while q[i]<>#0 do
    inc (i);
  q[0]:=Chr(i-1);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  LFNGenShortName:=q
end;

procedure CreateSubst;
var
   p:string;
begin
  FillChar (R, SizeOf (R), 0);
  p:=Path+#0;
  R.AX:=$71AA;
  R.BX:=Drive;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

procedure TerminateSubst;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$71AA;
  R.BX:=Drive+$0100;
  DOS7Error:=0; MsDOS (R);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL
end;

function GetSubst;
var
   p:string;
   i:byte;
begin
  FillChar (R, SizeOf (R), 0);
  R.AX:=$71AA;
  R.BX:=Drive;
  R.DX:=Ofs(p[1]);
  R.DS:=Seg(p[1]);
  DOS7Error:=0; MsDOS (R);
  i:=1;
  while p[i]<>#0 do
    inc (i);
  p[0]:=Chr(i-1);
  if (R.Flags and fCarry)<>0 then
    DOS7Error:=R.AL;
  GetSubst:=p
end;

function LFNRewrite;
begin
  LFNRewrite:=LFNTruncateFile (FileName, FA_NORMAL, OPEN_WRONLY+OPEN_AUTOCREATE, 0)
end;

function LFNReset;
begin
  LFNReset:=LFNOpenFile (FileName, FA_NORMAL, OPEN_RDONLY, 0)
end;

function LFNAppend;
var
   f:word;
begin
  f:=LFNOpenFile (FileName, FA_NORMAL, OPEN_WRONLY, 0);
  if DOSError=0 then
    LFNSeek (f, SEEK_END, 0); { go to the end of file }
  LFNAppend:=f
end;


begin
  DOS7Error:=0; { no DOS Error }
end.
