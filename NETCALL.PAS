{**************************************************************************}
{*                    SoftWeyr LAN library. Version 1.3                   *}
{*                               NetCall.PAS                              *}
{*                    The LANtastic (tm) interface unit                   *}
{*                   for Turbo Pascal (tm) 6.0 or higher                  *}
{*                     Copyright (c) by SoftWeyr,1994                     *}
{**************************************************************************}
{$A+,B-,E-,F-,G-,I-,N-,O+,R-,S-,V-,X-}

{$I Compile.INC}

Unit NetCall;
interface
uses Dos;
  Const
{Here GetServer stores adapter No }
  AdaptNo:Byte=0;
{Device type code for GetDevice and NetUse}
        dtPrinter = 3;
        dtDisk  =4;
  {File open mode}
   amReadOnly = 0;
   amWriteOnly = 1;
   amReadWrite = 2;
 {Other user restrictions}
 amCompatibility = 0;{for non-network enviroment }
 amExclusive = $10;
 amDenyAll = amExclusive;
 amDenyWrite = $20;
 amDenyRead = $30;
 amDenyNone = $40;
 {Inheritance}
 amPrivate = $80;
{Device access rights  ------------------------------------------}
ACL_read          = $8000;{ (R) Allow open for read and reading}
ACL_write         = $4000;{ (W) Allow open for write and writing}
ACL_create_file   = $2000;{ (C) Allow file creation}
ACL_create_dir    = $1000;{ (M) Allow directory creation}
ACL_lookup        = $0800;{ (L) Allow file/directory lookups}
ACL_delete_file   = $0400;{ (D) Allow file deletion}
ACL_delete_dir    = $0200;{ (K) Allow directory deletion}
ACL_rename        = $0100;{ (N) Allow file renaming}
ACL_execute       = $0080;{ (E) Allow program execution}
ACL_physical      = $0040;{ (P) Allow physical access to device}
ACL_attribute     = $0020;{ (A) Allow attribute changing}
{User status }
AUE_state_starting       = 0000  ;{ We are in the middle of a login}
AUE_state_in             = 0001  ;{ We are fully logged in}
AUE_state_RPL            = 0002  ;{ Remote program load login}
{User privelegies}
priv_superACL   = $80;{ Bypass ACLs}
priv_superqueue = $40;{ Bypass queue protection}
priv_peer       = $20;{ Treat as local process}
priv_supermail  = $10;{ Bypass mail protection}
priv_audit      = $08;{ The user can create audit entries}

{User status info }
Type TUserEntry=record
            VCID:Word;                { Virtual circuit number}
            state:Byte;               { Login state see above }
            command:Byte;             { Last command issued}
            IO:array[0..4]of byte ;   { Number of I/O bytes
                                       (40 bit unsigned binary number)}
            requests:Array[0..2]of byte;{ Number of server requests 24 bit
                                        u/bin. num}
            name:String[15];           { Name of user who is logged in}
            machine:String[15];        { Name of remote logged in machine}
      end;


{--------------- Informational functions ------------------------------}
  Function IsRedir:Boolean;
  Function IsServer:Boolean;
  Function Version:String;
  Function GetMachineName:String;
  Function GetError(ErrorNum:Integer):String;
  Function GetPrivilege(Server:String):Byte;
{----------- List browsing -------------------------}
  Procedure GetDevice( Index  : Integer;
                   Var Name   : String;
                   Var Path   : String;
                   Var Typ   : Integer;
                   Var Valid: Boolean);
Function GetDeviceDescr(Path:String):String;
var DeviceAccessRights:Word;
{Here access rights are placed by  GetDeviceDescr }

  Procedure GetUser(  Index   : Integer;
                  Var Name    : String);


  Procedure GetLogins( Index  : Integer;
                   Var Name   : String);

  Procedure GetServer(Index   : Integer;
                  Var Name    : String);

Procedure GetUserInfo(Index:Integer;Server:String;var Buffer:TUserEntry);

{------------------------ LogIn & LogOut ------------------------------}
  Procedure NetLogin( Server  : String;
                      Name    : String;
                      Passwrd  : String);

  Procedure AdaptLogin( Adapter:Byte;
                       Server  : String;
                      Name    : String;
                      Passwrd  : String);


  Procedure NetLogout(Server  : String);


{------------------- Device redirection --------------------------}
Procedure NetUse(    Name   : String;
                       Path   : String;
                       Typ   : Integer);



  Procedure NetUnuse(  Name   : String);


{------------------ Spooler control ---------------------}
{Spooler commands. * requeres Q privilege}
Type CQ_Command=
(CQ_start,      {* Start despooling}
CQ_halt,        {* Halt despooling}
CQ_halt_EOJ,    {* Halt despooling at end of job}
CQ_pause,       {* Pause the despooler at end of job}
CQ_single,      {* Print Real job}
CQ_restart,     {* Restart the current print job}
CQ_cancel,      { Cancel the currently printing job}
CQ_hold,        { Hold the queue entry}
CQ_release,     { Release a held queue entry}
CQ_rush         {* Make the queue entry a rushed job}
);
{ Different queue entry statuses}
TQueueStatus=(
QESfree,        {The queue entry is empty}
QESupdate,      {The queue entry is being updated}
QEShold,        {The queue entry is held}
QESwait,        {The queue entry is waiting for despool}
QESactive,      {The queue entry is being despooled}
QEScancel,      {The queue has been canceled}
QESfile_error,  {The spooled file could not be accessed}
QESspool_error, {The destination could not be accessed}
QESrush         {Rush this job}
);
{ Different types of queue entries}
TQueueType=(
QETprint,          { Spooled printer queue file }
QETmessage,        { Spooled message }
QETlocal_file,     { Spooled local file }
QETremote_file,    { Spooled remote file }
QETmodem,          { Spooled to remote modem }
QETbatch           { Spooled batch processor file }
);
{ Bit definitions for output control}
const
QEOC_keep        =   $40;  { Keep after despooling (don't delete)
                            For mail - allow delete only by owner}

Type
TQueueEntry = Record
               Status:TQueueStatus; {Status of queue entry}
               Size:LongInt;{ Size of spooled file}
               QEType:TQueueType;{ Type of queue entry}
               output_control:Byte;{ Control of despooled file}
               copies:Word; { Copies}
               sequence:LongInt;{ Sequence number of queue entry}
               Spooled_file:String[47];{ Pathname of spooled file}
               user:String[15]; {Username who spooled file}
               machine:String[15]; {Machine name user was on}
               DateTime:Longint;{ Date file spooled (MS-DOS format)}
               destination:String[16]; { Device name or username destined for}
               comment:String[47] ;{ Comment field}
              end;
Procedure GetQueueEntry(var Index:Integer;Server:String; Var Entry:TQueueEntry);

Procedure SetJobParams(var F;Copies:Word;Comment:String;DeleteAfterDespooling:Boolean);

Procedure ControlQueue(Server:String;Sequence:LongInt;Command:CQ_Command);
Type TQueueMode=(qmCombined,qmSeparated);
Function GetQueueMode:TQueueMode;
Procedure SetQueueMode(Mode:TQueueMode);
Procedure FlushCurrentJob;
Procedure SetLPTTimeOut(Ticks:Word);
Function GetLPTTimeOut:Word;
{--------------- get current time from server -----------------------------}
Procedure GetServerDateTime(Int:Word;Server:String;
 Var DT:DateTime);
{type DateTime is declared in DOS unit}
{--------------- file locking --------------------------}
Function Lock (var F;Offset,Length:LongInt):Boolean;
Procedure UnLock(var F;Offset,Length:LongInt);
Function LockRec(var F;StartRec,EndRec:LongInt):Boolean;
Procedure UnLockRec(var F;StartRec,EndRec:LongInt);
{------------------- LANtastic mail ----------------------------------}
Procedure OpenLetter(Var F:Text;Server,User,Subject:String;Keep:Boolean);
{------------------- Messages ------------------------------}
const
 {Message types}
  msgGeneral=0;
  msgWarning=1;
 {Message control flags }
 msgfBeep=1;
 msgfDeliverEqu=2;
 msgfPopUp=4;
Procedure SendMessage(Typ :Byte; Machine, Server, User, Text
                                    :String);
Procedure GetLastMessage(var Typ:Byte;var Text:String;var Sender:String);

Function GetMessageFlag:Byte;

Procedure SetMessageFlag(Flag:Byte);

Procedure SetMessageVector(P:Pointer);
Procedure GetMessageVector(var P:Pointer);

implementation

  Procedure GetLogins( Index  : Integer;
                   Var Name   : String);assembler;
  asm
   MOV AX,5F80H
   MOV BX,Index
   LES DI,Name
   inc DI
   int 21H
   jc @@Error
   mov al,' '
   mov cx,16
   cld
   Repnz Scasb
   mov AL,15
   sub al,cl
   mov Cl,al
   les di,Name
   Mov Es:[DI],AL;
   Mov DosError,0
   jmp @@X
@@Error:Mov DosError,AX
@@X:
   end;
Procedure GetServer( Index  : Integer;
                   Var Name   : String);assembler;
  asm
   MOV AX,5F84H
   MOV BX,Index
   LES DI,Name
   inc DI
   int 21H
   jc @@Error
   Mov AdaptNo,Dl
   mov al,' '
   mov cx,16
   cld
   Repnz Scasb
   mov AL,15
   sub al,cl
   mov Cl,al
   les di,Name
   Mov Es:[DI],AL;
   Mov DosError,0
   jmp @@X
@@Error:Mov DosError,AX
@@X:
   end;
Function Version:String;
var major,minor:Byte;
    S1,s2:String[3];
begin
 asm
  Mov AX,0B800H
  INT 2FH
  MOV MAjor,Al
 end;
 if Major=0 then
  begin
   Version:='Not installed';
   exit
  end;
 asm
  Mov AX,0B809H
  Int 2Fh
  Mov Major,AH
  Mov Minor,Al
 end;
 Str(Major,s1);
 Str(Minor,s2);
 While length(s2)<2 do s2:='0'+s2;
 Version:=S1+'.'+S2;
end;
Function IsRedir:Boolean;assembler;
asm
  Mov AX,0B800H
  Int 2FH
  cmp al,0
  jz @@No
  test BL,00001000B
  jz @@No
  Mov Al,True;
  jmp @@X
@@No: Mov Al,False
@@X:
end;
Function IsServer:Boolean;assembler;
asm
  Mov AX,0B800H
  Int 2FH
  cmp al,0
  jz @@No
  test BL,010000000B
  jz @@No
  Mov Al,True;
  jmp @@X
@@No: Mov Al,False
@@X:
end;

{$IFDEF NetVersion}
Function GetMachineName:String;External;
{$L GetName.obj}
{$Else}
Function GetMachineName:String;
Begin
GetMachineName[0]:=#0;
End;
{$ENDIF}



Procedure NetLogin(Server :String;
                   Name:String;
                   PassWrd:String);
begin
 AdaptLogIn($FF,Server,Name,PassWrd);
end;

Procedure AdaptLogin( Adapter:Byte;
                      Server  : String;
                      Name    : String;
                      Passwrd  : String);
var Str:String;
begin
 Str:=Server+'\'+Name+#0+PassWrd+#0;
 asm
  Push SS
  Pop ES
  Mov DI,Offset Str
  Add DI,BP
  inc DI
  Mov AX,5F81H
  Mov Bl,Adapter
  Int 21H
  jc @@Error
  Mov DosError,0
  jmp @@X
@@Error:
  Mov DosError,AX
@@X:
  end;
end;
Procedure StrLocal;assembler;
{DS:SI - pointer to string }
{ES:DI - pointer to local array of char }
{moves string into buffer, converting from LString to ASCIIZ}
{on exit  ES:DI - pointer to array  }
asm
 CLD
 PUSH CX
 PUSH AX
 PUSH DI
 SUB AX,AX
 LODSB
 MOV CX,AX
 REP MOVSB
 SUB AX,AX
 STOSB
 POP DI
 POP AX
 POP CX
end;
Procedure NetLogout(Server  : String);assembler;
Var ServAsciiz:Array[0..20] of char;
asm
 PUSH DS
 LDS SI,Server
 PUSH SS
 POP ES
 LEA DI,ServASciiZ
 Call StrLocal
 POP DS
 Mov AX,5F82H
 Int 21H
 jc @@Error
 Mov DosError,0
 Jmp @@X
@@Error:
  Mov DosError,AX
@@X:
end;
Procedure CalcAsciiZLen;near;assembler;
{ES:DI - Pointer to string with uninitiliazed length and #0 after end of line
 fills lenfth byte }
asm
 Push DI
 Push CX
 inc di
 mov al,0
 cld
 RepNz Scasb
 pop ax
 dec al
 sub al,cl
 pop di
 mov ES:[DI],Al
end;
 Procedure GetUser(  Index   : Integer;
                  Var Name    : String);assembler;
asm
 Mov AX,5F83H
 Mov BX,Index
 LES DI,Name
 inc DI
 Int 21H
 jc @@Error
 Mov DosError,0
 dec di
 Mov Cx,16
 call CalcAsciizLen
 jmp @@X
@@Error:
  Mov DosError,AX
@@X:
end;
  Procedure GetDevice( Index  : Integer;
                   Var Name   : String;
                   Var Path   : String;
                   Var Typ   : Integer;
                   Var Valid:Boolean);assembler;
asm
 Mov AX,5F02H
 Mov BX,Index
 Push DS
 LEs DI,Path
 Inc DI
 LDS SI,Name
 inc Si
 Int 21H
 jc @@Error
 Lds si,typ
 Mov Al,bl
 sub ah,ah
 Mov [si],AX
 lds si,Valid
 not bh
 and bh,1
 mov [si],bh
 Pop Ds
 Mov CX,128
 dec di
 Call CalcAsciizLen
 mov cx,16
 les di,Name
 call CalcAsciizLen
 Mov DosError,0
 jmp @@X
@@Error:
  Pop DS
  Mov DosError,AX
@@X:
end;
Procedure NetUse(    Name   : String;
                     Path   : String;
                     Typ   : Integer);assembler;
var NameASC:Array[0..8] of char;
    PathASC:Array[0..79] of char;
asm
 Push DS
 LDS Si,Name
 Push SS
 POP ES
 LEA DI,NameAsc
 Call StrLocal
 PUSH ES
 PUSH DI
 LDS SI,Path
 LEA DI,PATHASC
 CALL StrLocal
 POP SI
 POP DS
 Mov Bl,Typ.Byte[0]
 Mov Ax,5F03H
 Int 21H
 Pop DS
 jc @@Error
 Sub AX,AX
@@Error:
 Mov DosError,AX
@@X:
end;
Procedure NetUnuse(Name:String);assembler;
var NameAsc:Array[0..8] of char;
asm
 Push DS
 LDS SI,Name
 PUSH SS
 POP ES
 LEA DI,NameAsc
 Call StrLocal
 PUSH ES
 POP DS
 MOV SI,DI
 mov AX,5F04H
 Int 21H
 Pop DS
 jc @@Error
 Sub Ax,Ax
@@Error:
 Mov DosError,AX
end;
Procedure CallExpand(ErrCode:Integer;var S:String);Assembler;
asm
 Mov Ax,ErrCode;
 Mov Bx,AX
 Mov AH,5
 Int 2FH
 mov cx,80
 Push DS
 Push ES
 Push DI
 Pop Si
 Pop ds
 cld
 Les di,S
 inc DI
 Mov CX,0
@@1:Lodsb
    cmp al,0
    jz @@2
    Stosb
    inc cx
    jmp @@1
@@2:lds si,S
    mov [si],cl
   Pop ds
end;
var S:String;
Function GetError(ErrorNum:Integer):String;
begin
 CallExpand(ErrorNum,S);
 GetError:=S;
end;

Procedure NetClock(Int:Word;Var Server:String;Var Time_Block);assembler;
var ServerAsc:Array[0..20] of char;
asm
 Push DS
 LDS SI, Server
 PUSH SS
 POP ES
 LEA DI,ServerAsc
 Call StrLocal
 LDS SI,Time_block
 inc di
 Mov AX,5FC0H
 Int 21H
 Pop ds
 jc @@Error
 sub AX,AX
@@Error:
 Mov DosError,Ax
end;

Procedure GetServerDateTime(Int:Word;Server:String;
 Var DT:DateTime);
Type time_block =Record
  TYear:Word;
  TDay,TMonth,TMinutes,THour,THundreds,TSeconds:byte
end;
var D:Time_Block;
begin
  Server[Length(Server)+1]:=#0;
  NetClock(Int,Server,D);
  With D,Dt do
   begin
    Year:=TYear;
    Day:=TDay;
    Month:=TMonth;
    Hour:=THour;
    Min:=TMinutes;
    Sec:=TSeconds;
   end;
end;

Procedure Asciiz2Str;near;assembler;
{Recieve Pointer to ASCIIZ in  ES:DI and its maximal length in CX
 Converts it to LString at same place and sets ES:DI to end of string,
 i.e initial ES:DI+Cx
 It allows to convert
 record like
 R:REcord
  A:String[25]
  B:String[16]
  end;
 by commands
  LES DI,R
  MOV CX,25
  Call Asciiz2Str
  MOV CX,16
  Call Ascii2Str }
asm
 Push DI
 Push cx
 Mov al,0
 cld
 repnz scasb
 std
 pop ax
 push ax
 push ds
 push es
 pop ds
 dec di
 mov Si,di
 dec si
 sub ax,cx
 dec ax
 mov cx,ax
 mov dx,ax
 std
 rep movsb
 stosb
 pop ds
 pop ax
 pop di
 add di,ax
end;

Procedure Str2Asciiz;near;assembler;
{On entry - DS:SI - Pointer to LString
 BX , DX - unchanged ,ES,DI,CX,AX,SI destroyed}
asm
 PUSH DS
 POP ES
 MOV DI,SI
 XOR AX,AX
 CLD
 LODSB
 MOV CX,AX
 REP MOVSB
 SUB AL,AL
 STOSB
end;
Procedure GetQueueEntry(var Index:Integer;Server:String; Var Entry:TQueueEntry);
assembler;
var ServAsc:array[0..20] of char;
asm
 Push ds
 LDS SI,Index
 Mov DX,[si]
 lds si,Server
 PUSH SS
 POP ES
 LEA DI,ServAsc
 Call StrLocal
 mov bx,Dx
 lds Si,Entry
 mov AX,5FA0H
 int 21H
 LDS SI,Index
 MOV DS:[SI],BX
 Pop ds
 jc @@Error
 ;{if Success, convert all ASCIIZ into lstrings}
 les di,Entry
 add di,13
 mov cx,48
 call Asciiz2Str;{TQueueEntry.Spooled_file}
 mov cl,16
 call Asciiz2Str;{TQueueEntry.User}
 mov cl,16
 Push DI
 call Asciiz2Str;{TQueueEntry.Machine}
 Pop DX
 Push DI
 std
 mov cx,16
 mov di,dx
 sub ax,ax
 mov al,ES:[DI]
 add di,ax
 mov al,' '
 repz scasb
 mov di,dx
 mov ES:[DI],cl
 pop di
 add di,4;{Skip TQueueEntry.DateTime}
 mov cl,17
 call Asciiz2str;{TQueueEntry.destination}
 mov cl,48
 call asciiz2Str;{TQueueEntry.Comment}
 xor ax,ax
@@Error:
  Mov DosError,Ax
end;
Procedure SetQEParams(var F;Copies:Word;Comment:String;DeleteAfterDespooling:Boolean;Dest:String);
assembler;
var Q:TQueueEntry;
const QSize=Sizeof(TQueueEntry);
asm
 Push DS
 LDS SI,Comment
 LEA DI,Q
 PUSH SS
 POP ES
 CLD
 XOR AL,AL
 MOV CX,QSize
 REP Stosb
 LEA DI,Q
 Add DI, offset TQueueEntry.Comment
 sub ax,ax
 LODSB
 CMP AL,47
 JBE @@Comment
 MOV AL,47
@@Comment :
 mov cx,ax
 rep movsb
 LDS SI,Dest
 LEA DI,Q
 Add DI, offset TQueueEntry.destination
 sub ax,ax
 LODSB
 CMP AL,16
 JBE @@Dest
 MOV AL,16
@@Dest:
 mov cx,ax
 rep movsb
 MOV AX,Copies
 MOV Q.Copies,AX
 SUB AL,AL
 CMP DeleteAfterDespooling,True
 JZ @@1
 MOV AL,QEOC_keep;
@@1:
 MOV Q.output_control,AL
 LDS SI,F
 MOV BX,[SI]
 LEA SI,Q
 PUSH SS
 POP DS
 MOV AX,5FA1H
 INT 21H
 POP DS
 JC @@Error
 XOR AX,AX
@@Error:
 MOV DosError,AX
end;
Procedure SetJobParams(var F;Copies:Word;Comment:String;DeleteAfterDespooling:Boolean);
begin
 SetQEParams(F,Copies,Comment,DeleteAfterDespooling,'');
end;
Procedure ControlQueue(Server:String;Sequence:LongInt;Command:CQ_Command);
assembler;
var Servasc:array[0..20] of char;
asm
 sub ax,ax
 PUSH DS
 lds si,Server
 Push SS
 POP Es
 LEA DI,ServASc
 CALL StrLocal
 POP DS
 mov cx,Sequence.Word[2]
 mov dx,Sequence.Word[0]
 mov bl,command
 mov ax,5FA2H
 int 21H
 jc @@Error
 sub ax,ax
@@Error:
 Mov DosError,AX
end;
Function LockRec(var F;StartRec,EndRec:LongInt):Boolean;
{Locking records of typed/untyped file from
 StartRec to EndRec (both included)   }
begin
 LockRec:=Lock(F,FileRec(F).RecSize*StartRec,FileRec(F).RecSize*Succ(EndRec-StartRec));
end;

Procedure UnLockRec(var F;StartRec,EndRec:LongInt);
begin
 UnLock(F,FileRec(F).RecSize*StartRec,FileRec(F).RecSize*Succ(EndRec-StartRec));
end;


{$IFDEF NetVersion}
Function Lock (var F;Offset,Length:LongInt):Boolean;external;
Procedure UnLock(var F;Offset,Length:LongInt);external;
{$L LOCK.OBJ}
{$Else}
Function Lock (var F;Offset,Length:LongInt):Boolean;
Begin
Lock:=True;
End;

Procedure UnLock(var F;Offset,Length:LongInt);
Begin
DosError:=0
End;
{$ENDIF}

Function GetQueueMode:TQueueMode;assembler;
asm
 Mov AX,5D07H
 int 21H
 jc @@Error
 sub ax,ax
 Mov DosError,AX
 mov al,dl
 jmp @@X
@@Error:
 Mov DosError,AX
 sub al,al
@@X:
end;
Procedure SetQueueMode(Mode:TQueueMode);assembler;
asm
 Mov AX,5D08H
 Mov DL,mode
 Int 21H
 jc @@Error
 Sub AX,AX
@@Error:
  Mov DosError,AX
end;
Procedure FlushCurrentJob;assembler;
asm
 Mov AX,5D09H
 Int 21H
 jc @@Error
 Xor Ax,Ax
@@Error:
 Mov DosError,AX
end;
Function GetDeviceDescr(Path:String):String;assembler;
var PathAsc:Array[0..80] of char;
asm
  PUSH DS
  LDS SI,Path
  PUSH SS
  POP ES
  LEA DI,PathAsc
  Call StrLocal
  LDS SI,@Result
  MOV AX,5FB1H
  INT 21H
  PUSH DS
  PUSH SI
  POP DI
  POP ES
  POP DS
  jc @Error
  MOV DeviceAccessRights,CX
  MOV CX,63
  CALL ASCIIz2Str
  SUB AX,AX
  Jmp @Success
@Error:
  MOV Byte Ptr ES:[DI],0
@Success:
  MOV DOSError,AX
end;
Procedure GetUserInfo(Index:Integer;Server:String;var Buffer:TUserEntry);assembler;
var ServAsc:array[0..20] of char;
asm
 Push DS
 LDS SI,Server;
 PUSH SS
 POP ES
 LEA DI,ServAsc
 Call StrLocal
 Mov AX,$5FB0;
 Mov BX,index;
 LDS SI,Buffer;
 int 21H
 push ds
 pop es
 pop ds
 push si
 pop di
 jc @Error
 add di,12
 mov cx,16
 call Asciiz2Str;{Name}
 mov cx,16
 Push DI
 call Asciiz2Str;{Machine}
 Pop DX
 std
 mov cx,16
 mov di,dx
 sub ax,ax
 mov al,ES:[DI]
 add di,ax
 mov al,' '
 repz scasb
 mov di,dx
 mov ES:[DI],cl
 Xor Ax,ax
@Error:
 Mov DosError,AX
end;
Function GetPrivilege(Server:String):Byte;
var MName:String;
    B:TUserEntry;
    i,j:Integer;
begin
   MName:=GetMachineName;
   i:=0;
   Repeat
    GetUserInfo(I,Server,B);
    inc(i);
   Until (DosError<>0)or(B.Machine=MName);
   if DosError=0 then GetPrivilege:=B.State
   else GetPrivilege:=0;
end;
Procedure SetLPTTimeOut(Ticks:Word);assembler;
asm
 MOV AX,5FD1H
 MOV CX,TICKS
 INT 21H
 JC @Error
 XOR AX,AX
@Error:
 MOV DosError,AX
end;
Function GetLPTTimeOut:Word;assembler;
asm
 MOV AX,5FD0H
 INT 21H
 JC @Error
 XOR AX,AX
 MOV DosError,AX
 MOV AX,CX
 jmp @Exit
@Error:
 MOV DosError,AX
 XOR AX,AX
@Exit:
end;
Procedure OpenLetter(Var F:Text;Server,User,Subject:String;Keep:Boolean);
var SR:SearchRec;
begin
 FindFirst(Server+'\@MAIL',Directory,SR);
 if DosError<>0 then Exit;
 Assign(F,Server+'\@MAIL');
 Rewrite(F);
 SetQEParams(F,1,Subject,not Keep,User);
end;
Type TMessageBuffer=record
                     Reserved:Byte;
                     Typ:Byte;
                     Machine,Server,User,Origin:Array[0..15] of char;
                     Text:Array[0..79]of char;
                    end;
Procedure SendMessage(Typ :Byte; Machine, Server, User, Text
                                    :String);assembler;
var MsgBuf:TMessageBuffer;
    Const BufSize=SizeOf(TMessageBuffer) div 2 -1;
asm
 Mov AL,Typ;
 Mov MsgBuf.Typ,Al
 LEA DI,MsgBuf.Machine
 Push SS
 Pop ES
 Mov CX,BufSize;
 CLD
 SUB AX,AX
 REP STOSW
 Push DS
 LDS SI,Machine
 LEA DI,MsgBuf.Machine
 LodSb
 cmp AX,15
 jbe @@01
 Mov AX,15
@@01:
 Mov CX,Ax
 jcxz @@1
 Rep MovSb
@@1:Lea DI,MsgBuf.Server
 LDS SI,Server
 LodSb
 cmp AX,15
 jbe @@02
 Mov AX,15
@@02:
 Mov CX,Ax
 jcxz @@2
 Rep MovSb
@@2:Lea DI,MsgBuf.User
 LDS SI, User
 LodSb
 cmp AX,15
 jbe @@03
 Mov AX,15
@@03:
 Mov CX,Ax
 jcxz @@3
 Rep MovSb
@@3:Lea DI,MsgBuf.Text
 LDS SI ,Text
 LodSb
 cmp AX,79
 jbe @@04
 Mov AX,15
@@04:
 Mov CX,Ax
 jcxz @@4
 Rep MovSb
@@4:LEA SI,MsgBuf
  Push SS
  Pop DS
  Mov AX,$5F98
  Int 21H
  Pop DS
  jc @@Error
  XOR AX,AX
@@Error:
  Mov DosError,AX
end;
Procedure GetLastMessage(var Typ:Byte;var Text:String;var Sender:String);assembler;
var MsgBuf:TMessageBuffer;
asm
 Push SS
 Pop ES
 LEA DI,MsgBuf
 Mov AX,$5F99
 Int 21H
 JC @@Error
 MOV AL,MSGbuf.Typ
 LES DI,TYP
 Mov ES:[DI],Al
 Push DS
 XOR CX,CX
 Lea SI,MsgBuf.Origin
 Push SS
 Pop DS
 LES DI,Sender
 Push DI
 Inc DI
 XOR CX,CX
@@1:Lodsb
    cmp AL,0
    JZ @@11
    StoSb
    inc cl
    jmp @@1
@@11:Pop DI
     Mov ES:[DI],cl
  LEA SI,MsgBuf.Text
  LES DI,Text
 Push DI
 Inc DI
 XOR CX,CX
@@2:Lodsb
    cmp AL,0
    JZ @@21
    StoSb
    inc cl
    jmp @@2
@@21:Pop DI
     Mov ES:[DI],cl
   Pop DS
   XOR AX,AX
@@Error:Mov DosError,AX
end;
Function GetMessageFlag:Byte;assembler;
asm
 Mov AX,$5F9A
 Int 21H
 jc @@Error
 Xor Ax,ax
@@Error:
 Mov DosError,AX
 Mov Al,Dl
end;
Procedure SetMessageFlag(Flag:Byte);assembler;
asm
 Mov AX,$5F9B
 Mov DL,Flag
 Int 21H
 jc @@Error
 Xor Ax,ax
@@Error:
 Mov DosError,AX
end;
Procedure GetMessageVector(var P:Pointer);assembler;
asm
 Mov AX,$5FE2
 Int 21H
 jc @@Error
 Mov DX,ES
 Les DI,P
 Mov ES:[Di],BX
 Mov Es:[DI].Word[2],DX
 XOR AX,AX
@@Error:
 Mov DosError,AX
end;
Procedure SetMessageVector(P:Pointer);Assembler;
asm
 LES BX,P
 Mov AX,$5FE3
 Int 21H
 jc @@Error
 XOR AX,AX
@@Error:
  MOV DosError,AX
end;
end.

