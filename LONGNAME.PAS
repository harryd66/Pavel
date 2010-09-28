(***********************************************************************)
(*   DOS session Windows95/NT LONG-FILENAME functions unit for BP 7    *)
(*                                                                     *)
(*                             (c) Denis Kaganovich, Minsk, 06.09.1996 *)
(*                             E-mail: mahatma@ped.belpak.minsk.by     *)
(*                                     mahatma@aete.belpak.minsk.by    *)
(*                                     2:450/39.242@fidonet            *)
(*                                                                     *)
(* Based on information from Ralf Braun's INTERLIST v4.6               *)
(*                                                                     *)
(* Minimal needed realisation:                                         *)
(*  - SHORT<->LONG names transformation                                *)
(*  - long-filename Move/Rename                                        *)
(*  - volume info (maximum size of name/path, type of file system)     *)
(* Additional:                                                         *)
(*  - Win95 FindFirst/FindNext/FindClose (may be faster)               *)
(* Win95/DOS session supports more long-filename functions, but that   *)
(* not needed.                                                         *)
(* Tested - working in real & protected modes                          *)
(***********************************************************************)

{$O-,R-,S-,V-}
unit LongName;
interface
const LFNError:integer = 0;

{ LFNError=7100 if function not supported }

type
  TLongName = array [0..260] of char;
  TShortName = array [0..66] of char;

const
  { constants for LFNGetName SubFn }
  fnTrueName   = 0; {Dst - LongName}
  fnLong2Short = 1; {Dst - ShortName}
  fnShort2Long = 2; {Dst - LongName}

  { Flags for LFNGetVolInfo }
  fCaseSensitive = 1; {searches are case sensitive}
  fPreservesCase = 2; {preserves case in directory entries}
  fUnicode       = 4; {uses Unicode characters in file and directory names}
  fLongNamesDOS  = $4000; {supports DOS long filename functions}
  fCompressed    = $8000; {volume is compressed}

procedure LFNGetName(SubFn:word; Src,Dst:PChar);
procedure LFNRename(NameFrom,NameTo:PChar);

procedure LFNGetVolInfo(RootName,Buf:PChar; BufSize:word;
          var Flags,NameSize,PathSize);

{================ Standard pascal STRING versions: ===================}
{!!!WARNING! MAY BE BUGS - "STRING" SIZE=255 BUT LONG NAME UP TO 261! }

function sLFNGetName(SubFn:word; Src:string):string;
procedure sLFNRename(NameFrom,NameTo:string);

function sLFNGetVolInfo(RootName:string; var Flags,NameSize,PathSize):string;

{====================== Additional functions ==========================}
{ All downlisted actions may be maked with "old" + uplisted functions  }

type
  TLFNSearchRec = record
    Attr          :longint;
    CreationTime,
    AccessTime,
    ModifyTime    :comp; {DWord}
    HSize,
    LSize         :longint;
    Reserved      :array [0..7] of byte;
    LongName      :array [0..259] of char;
    ShortName     :array [0..13] of char;
  end;

function LFNFindFirst(Path:PChar; Attr:word; var S:TLFNSearchRec):word;
procedure LFNFindNext(Handle:word; var S:TLFNSearchRec);
procedure LFNFindClose(Handle:word);

{========================================================================}
IMPLEMENTATION

procedure CallDOS; near; assembler; { int 21h & error->DosError}
asm
   int 21h
   push ax
   push ds
   jc @ERR
   xor ax,ax
@ERR:
   push ax
   mov ax,seg @Data
   mov ds,ax
   pop ax
   mov LFNError,ax
   pop ds
   pop ax
end;

function LFNFindFirst; assembler;
asm
   push ds
   xor si,si
   mov cx,Attr
   lds dx,Path
   les di,S
   mov ax,714Eh
   call CallDOS
   pop ds
end;

procedure LFNFindNext; assembler;
asm
   xor si,si
   mov bx,Handle
   les di,S
   mov ax,714Fh
   call CallDOS
end;

procedure LFNGetName; assembler;
asm
   push ds
   mov cx,SubFN
   lds si,Src
   les di,Dst
   mov ax,7160h
   call CallDOS
   pop ds
end;

procedure LFNGetVolInfo; assembler;
asm
   push ds
   lds si,RootName
   les di,Buf
   mov cx,BufSize
   mov ax,71A0h
   call CallDOS
   lds si,Flags
   mov [si],bx
   lds si,NameSize
   mov [si],cx
   lds si,PathSize
   mov [si],dx
   pop ds
end;

procedure LFNFindClose; assembler;
asm
   mov bx,Handle
   mov ax,71A1h
   call CallDOS
end;

procedure LFNRename; assembler;
asm
   push ds
   lds dx,NameFrom
   les di,NameTo
   mov ax,7156h
   int 21h
   pop ds
end;

procedure _Str2Pas; near; assembler;
asm { ES:DI }
   cld
   push di
   xor cl,cl
@L:xchg al,es:[di]
   test al,al
   jz @0
   inc di
   inc cl
   jnc @L
   dec cl
@0:pop di
   mov es:[di],cl
end;

procedure _Pas2Str; near; assembler;
asm { DS:SI }
   cld
   push es
   push di
   push si

   push ds
   pop es
   mov di,si
   xor cx,cx
   lodsb
   mov cl,al
   rep movsb
   xor al,al
   stosb

   pop si
   pop di
   pop es
end;

function sLFNGetName(SubFn:word; Src:string):string; assembler;
asm
   cld
   push ds
   mov cx,SubFN
   lds si,Src
   call _Pas2Str
   les di,@Result
   mov ax,7160h
   call CallDOS
   pop ds
   les di,@Result
   call _Str2Pas
   les di,Src
   call _Str2Pas
end;

procedure sLFNRename(NameFrom,NameTo:string); assembler;
asm
   push ds
   lds si,NameTo
   call _Pas2Str
   push ds
   pop es
   mov di,si
   lds si,NameFrom
   call _Pas2Str
   mov dx,si
   mov ax,7156h
   int 21h
   pop ds
   les di,NameFrom
   call _Str2Pas
   les di,NameTo
   call _Str2Pas
end;

function sLFNGetVolInfo(RootName:string; var Flags,NameSize,PathSize):string;
assembler;
asm
   push ds
   lds si,RootName
   call _Pas2Str
   les di,@Result
   inc di
   mov cx,255
   mov ax,71A0h
   call CallDOS
   lds si,Flags
   mov [si],bx
   lds si,NameSize
   mov [si],cx
   lds si,PathSize
   mov [si],dx
   pop ds
   les di,@Result
   call _Str2Pas
   les di,RootName
   call _Str2Pas
end;


END.
