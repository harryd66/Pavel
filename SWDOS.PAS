{******************************************************************}
{*                         SWDOS.PAS                              *}
{*                  SoftWeyr enhanced DOS toolbox                 *}
{*                        version 1.2                             *}
{*                 Copyright (c) by SoftWeyr,1994-95              *}
{******************************************************************}
{$F-}
{$IFDEF Ver70}
{$T-}
{$ENDIF}
{$G-}
unit SWDOS;
Interface
uses DOS;
Const
  {Memory allocation strategies}
  msFirstFitLow=0;{In conventional memory from lowest address}
  msBestFitLow=1;{In best block of conventional  memory}
  msLastFitLow=2;{In conventional memory from highest address}
  msFirstFitHighOnly=$40;{Only in UMB from lower end}
  msBestFitHighOnly=$41;
  msLastFitHighOnly=$42;
  msFirstFitHigh=$80;{Try in UMB, if failed, try in conventional}
  msBestFitHigh=$81;
  msLastFitHigh=$82;
  {Standard DOS devices}
  STDIN=0;
  STDOUT=1;
  STDERR=2;
  STDPRN=3;
  STDAUX=4;
  STDAUXin=5;
var
     ZeroWord:Word;{Don't change this and folllowing definition and value
                       of this constant!}
     Environment:Word;{Contain Segment address of currently availiable env}
{-------------  operations with file via its name -------------------------}
{1}Procedure RenameFile(OldName,NewName:String);
{2}Procedure EraseFile(FileName:String);
{3}Procedure SetFileAttr(FileName:String;Attr:Word);
{4}Function GetFileAttr(FileName:String):Word;
{5}Procedure SetFileTime(FileName:String;DateTime:LongInt);
{6}Procedure GetFileTime(FileName:String;var DateTime:Longint);
{-------------  operations with file via its handle -----------------------}
{Useful, for example for operate with TDOSStream}
{7}Procedure SetHandleTime(Handle:Word;DateTime:LongInt);
{8}Procedure GetHandleTime(Handle:Word;var DateTime:Longint);
{-------------------- other file operations ------------------------------}
{9}Procedure MaxFiles(Count:Integer);
{Set maximal count of availiable file handlers}
{10}Procedure AssignTemp(var F;TempDir:String);
{Creats a temporary  file with unique name in specified directory and
 assignes it to file variable F}
{11}Procedure CloseTemp(var F);
{Closes and erases file}
{12}Function GetFileName(var F):String;
{Returns name of assigned file, either text or binary}
{------ STD Dos Devices & TEXT file management ---------------------}
{13}Procedure OpenSTD(var F:Text;Device:Word);
{Opens text file as standard dos device}
{14}Procedure StdWrite(Device:Word;S:String);
{Writes string to standard dos device}
{15}Function Redirected(var F:TExt):Boolean;
{Checks for redirection of STDIN or STDOUT}
{16}Procedure Redirect(var F:Text;Where:String);
{Redirects standard input or output (INPUT or OUTPUT file variables)
 to specified file or device}
{17}Procedure CancelRedirection(var F:Text);
{Cancels redirection, prevouisly created by Redirect}
{18}Procedure CloseHandle(Handle:Word);
{Closes the given handle}
{19}Procedure SetPagingMode(var F :Text; H :Integer; Message
                                                      :String);
{20}Procedure EndPagingMode(var F:Text);
{Set/Reset autostop after each H strings}
{21}Function GetStr(var F:Text):String;
{Readln(F,S) as function. Sometimes useful}
{22}Procedure Tee(var F:Text);
{Duplicates output to specified file to STDOUT. Useful if file is
 assigned trough AssignCRT or AssignDevice and StDOut is redirected.
 Tee and setPaging mode cannot be used at same time, even with different
 files}
var DuplicateOutput:Boolean;
{Set it to false if you want temporary stop Tee file}
{-------------- KeyBoard Read though DOS ---------------------------------}
{23} Function DOSReadKey:char;inline
 {Four bytes only shorter than far CALL}
($B4/$08    {MOV AH,8}
/$CD/$21);  {INT 21H}
{24}Function DOSKeyPressed:Boolean;inline
($B4/$0B    {MOV AH,0BH}
/$CD/$21    {INT 21H}
/$24/$01);  {AND AL,1;True = 1, but not $FF, as  DOS think,
                               but  False - really  0}
{25}Function ReadKeyWithEcho:char;inline($B4/$01/$CD/$21);

{-------------- operations with enviroment -------------------------------}
{Make Environment of parent process availiable for reading and modification}
{26}Procedure AccessParentEnv;
{Make current Environment availiiable again after call of prevois routine}
{27}Procedure AccessCurrentEnv;
{Make Root Environment availiable for reading and modification}
{28}Procedure AccessRootEnv;
{Deallocates environment block and lets DOS use its space for other purposes}
{very useful for TSR's}
{29}Procedure FreeEnv;
{Returns size of currently availiavle environment block}
{30}Function GetEnvSize:word;
{Returns number of Environment strings}
{31}Function GetEnvCount:Integer;
{Returns number of free bytes in environment block}
{32}Function GetEnvSpace:word;
{Return N-th String from environment}
{33}Function GetEnvStrN(N:Integer):String;
{Return Value of specified environment variable}
{34}Function GetEnvStr(VarName:String):String;
{Sets new value of specified environment variable}
{Returns 20 in DosError if out of environment space}
{35}Procedure SetEnvStr(VarName,Value:String);
{Return Path name of owner of currently availiable environment}
{36}Function GetProgName:String;
{Return command line of owner of currently availiable environment}
{37}Function GetCommandLine:String;
{Return command line addres of owner of currently availiable environment}
{38}Function CommandLineAddress:Pointer;

{Returns addres of prevois int 22-24h handler}
{39}Function OldInt22H:Pointer;
{40}Function OldInt23H:Pointer;
{41}Function OldInt24H:Pointer;
{-------------operation with DOS memory meneger-----------------}
{$IFDEF MSDOS}
{42}Procedure SetMemTop(MemTop:Pointer);
{Analog of procedure from Turbo Vision unit Memory. Be very careful with
 TP versions prior 6.0. freelist may be destroyed by this call }
{$ENDIF}
{43}Function DosAlloc(Size:Word):Pointer;
{Allocates Size paragraphs of DOS memory. Returns nil in case of error}
{44}Procedure DosFree(P:Pointer);
{Allocates /deallocates memory block on DOS level}
{45}Function DosBlockSize(P:Pointer):Word;
{Returns size of Dos memory block in paragraphs. Sets DosError to 204 if
 pointer is not valid}
{46}Procedure SetAllocationStrategy(Strategy:Word);
{Changes DOS allocation strategy see msXXX constants in this unit}
{Please restore original allocation strategy before exiting from program}
{47}Function GetAllocationStrategy:Word;
{Returns current DOS Allocation Strategy}
{48}Function GetUMBLink:Boolean;
{Returns True if UMB usage allowed}
{49}Procedure SetUMBLink(Allow:Boolean);
{Sets UMB usage state}
{50}Function Upcase(ch:Char):Char;
{UpperCases character in differece from System.Upcase correctly works with
 national characters if COUNTRY was defined in  CONFIG.SYS}
{51}Function StUpcase(S:STring):String;
{UpperCases a string}
{$IFDEF Ver70}
{52} Function StrUpper(Str:PChar):PChar;
{$ENDIF}
{-------------------------- File name management ---------------------------}
{53}Function JustFileName(FileName:String):String;
{Extracts name with extension from given filename (Removes any pathname)}
{54}Function JustName(FileName:String):String;
{Extract name without extension from given filename}
{55}Function JustExtension(FileName:String):String;
{Extract extension from given file name}
{56}Function JustPathName(FileName:String):String;
{Extract pathname from given fileName}
{57}Function DefaultExtension(FileName,Extension:String):String;
{if given filename has no extension, appends given extension}
{58}Function ForceExtension(FileName,Extension:String):String;
{Sets extension to given}
{59}Function ExpandFileName(FileName,DefaultExt,DefaultDir:String):String;
{ Appends extension if no one specified and search file in list of
  default directories. Returns '' if not found or full name}
{-------------- Text file management ---------------------}
{60}Procedure TextSeek(var F : Text; Target : LongInt);
    {-Do a Seek for a text file opened for input. Returns False in case of I/O
      error.}
{61}Function TextPos(var F:Text):Longint;
 {Returns current positon of text file, opened both for input ir output.
  Returns -1 in case of error}
{62}Procedure AssignMemory(var F:Text;var Buffer;BufSize:Word);
{Assigns memory buffer to file.  Futher you can do Reset or Rewrite etc.
 Do not forget remove buffer after closing if it is dynamically allocated.
 if you want read from this file, fill buffer by anything appropriate before}

{63}Procedure LoadTextFile(var F:Text);
{Loads a text file. Make usial Assign before and usial Reset after
 (You may Reset it as many time as you need without any disk access
 Close by CloseLoaded
  or do With TextRec(F) do
          FreeMem(BufPtr,BufSize);
  after close
  if file larger then 64 K or not enough memory,IOResult would return
   8 (Not Enough Memory) and file would be open as usial}

{64}Procedure CloseLoaded(var F:Text);
{Closes file and deallocates it's buffer}
{-----------------Single drive processing----------------------------}
{65}Function GetDriveLetter(Device:Byte):Char;
{Return drive letter, currently associated with specified device}
{Device - 0 :Default, 1-A 2-B etc. Returns '@' in cad=se of error
 associated with device}
{66}Function IsDriveMappable(Device:Byte):Boolean;
{Returns True if more than one letter associated with given device}
{67}Procedure SetDriveLetter(DriveLet:Char);
{if device can be associated with more than one letter i.e A: B:,
 tells dos, which letter must be used}
Implementation
{==========================================================================}
{$F+}
{$L Rename}
Procedure RenameFile(OldName,NewName:String);external;
{$L Erase}
Procedure EraseFile(FileName:String);external;
{$L Attr}
Procedure SetFileAttr(FileName:String;Attr:Word);external;
Function GetFileAttr(FileName:String):Word;external;
{$L FTime}
Procedure SetFileTime(FileName:String;DateTime:LongInt);External;
Procedure GetFileTime(FileName:String;var DateTime:Longint);external;
{$L HTime}
Procedure SetHandleTime(Handle:Word;DateTime:LongInt);External;
Procedure GetHandleTime(Handle:Word;var DateTime:Longint);External;
{$L Environ.obj}
Procedure AccessParentEnv;External;
{$L MaxFiles}
Procedure MaxFiles(Count:Integer);external;
{$IFDEF MSDOS}
Procedure SetMemTop(MemTop:Pointer);External;
{$L MemTop}
{$L DosAlloc}
{$L DosFree}
{$L BLOKSIZE}
{$ELSE}
{$L DosAlloc.OBP}
{$L DosFree.OBP}
{$L BlokSize.OBP}
{$ENDIF}
Function DosAlloc(Size:Word):Pointer;External;
Procedure DosFree(P:Pointer);external;
Function DosBlockSize(P:Pointer):Word;external;
{$L STRATEGY}
Procedure SetAllocationStrategy(Strategy:Word);External;
Function GetAllocationStrategy:Word;External;
{$L UMBLink}
Function GetUMBLink:Boolean;External;
Procedure SetUMBLink(Allow:Boolean);External;
{$IFDEF MSDOS}
{$L Upcase}
{$ELSE}
{$L UPCASE.OBP}
{$ENDIF}
Function Upcase(ch:Char):Char;external;
{UpperCases character in differece from System.Upcase correctly works with
 national characters if COUNTRY was defined in  CONFIG.SYS}
Function StUpcase(S:STring):String;External;
{UpperCases a string}
{$IFDEF Ver70}
  {$L Upcase7}
  Function StrUpper(Str:PChar):PChar;external;
{$ENDIF}
{$L Asciiz}
Procedure Asciiz;external;
{$L DevWrite}
Procedure StdWrite(Device:Word;S:STring);External;
{$L CLose}
Procedure CloseHandle(Handle:Word);External;
{$L REDIR}
Function Redirected(var F:TExt):Boolean;External;
{$L DOREDIR}
Procedure Redirect(var F:Text;Where:String);external;
Procedure CancelRedirection(var F:Text);external;
{-------------- Text file position management ---------------------}
Procedure TextSeek(var F : Text; Target : LongInt);external;
{$L TEXTSEEK.OBJ}
Function TextPos(var F : Text): LongInt;external;
{$L TEXTPOS.OBJ}
{------------ Single drive systems ------------------}
Function GetDriveLetter(Device:Byte):Char;External;
Function IsDriveMappable(Device:Byte):Boolean;External;
Procedure SetDriveLetter(DriveLet:Char);External;
{$L ONEDRIVE.OBJ}
{$F-}
type EnvBlock=array[0..32767]of char;
     EnvPtr=^EnvBlock;
var Env:EnvPtr absolute ZeroWord;
    EnvPos:Word;
{Local environment operation procedures}
Function GetEnvSize:Word;
begin
 GetEnvSize:=DosBlockSize(Env)*16;
end;
Procedure FreeEnv;
begin
 DosFree(Env);
end;
Procedure SkipLine;
begin
 While Env^[EnvPos]<>#0 do inc(EnvPos);
 Inc(EnvPos);
end;
Function CopyStr:String;
var I:Integer;
begin
 i:=0;
 While (I<255)and(Env^[EnvPos]<>#0) do
  begin
   inc(i);
   CopyStr[i]:=Env^[EnvPos];
   Inc(EnvPos);
  end;
 CopyStr[0]:=chr(i);
end;
Procedure FindEnvStr(var VarName:string);
var i:Integer;
begin
 EnvPos:=0;
 VarName:=StUpCase(VarName);
 While Env^[EnvPos]<>#0 do
  begin
   i:=1;
   While (Env^[EnvPos]=VarName[i])and(i<=Length(VarName)) do
    begin
     inc(i);
     Inc(EnvPos);
    end;
   if (i=Succ(Length(VarName)))and(Env^[EnvPos]='=')then exit
    else SkipLine;
  end;
end;

Procedure StoreStr(S:String);
var i:Integer;
begin
 For i:=1 to Length(S) do
  begin
   Env^[EnvPos]:=S[i];
   Inc(EnvPos);
  end;
end;
{Interface environment operation procedures}
Function GetEnvCount:Integer;
var I:Integer;
begin
 EnvPos:=0;
 I:=0;
 While Env^[EnvPos]<>#0 do
  begin
   SkipLine;
   Inc(i);
  end;
 GetEnvCount:=i;
end;
Function GetEnvSpace:Word;
begin
 EnvPos:=0;
 While Env^[EnvPos]<>#0 do
  SkipLine;
 inc(envpos);
 if Env^[EnvPos]=#1 then
  begin
   inc(EnvPos,2);
   SkipLine;
  end;
 GetEnvSpace:=GetEnvSize-EnvPos;
end;
Function GetEnvStrN(N:Integer):String;
Label 1;
var I:Integer;
begin
 EnvPos:=0;
 For I:=2 to n do
 begin
  SkipLine;
  if Env^[EnvPos]=#0 then goto 1;
 end;
 1:GetEnvStrN:=CopyStr;
end;
Function GetEnvStr(VarName:String):String;
begin
 FindEnvStr(VarName);
 if Env^[EnvPos]=#0 then GetEnvStr:='' else
  begin
 Inc(EnvPos);
 GetEnvStr:=CopyStr;
 end;
end;
Procedure SetEnvStr(VarName,Value:String);
var Lastpos,Space,k,i,n:word;
Procedure MoveEnv(Src,Dst:word);
var i:integer;
begin
 if Src>Dst then
   For i:=Src to LastPos do
    begin
     Env^[Dst]:=Env^[i];
     Inc(Dst);
    end
  else
 if Src<Dst then
  begin
   Dst:=LastPos-Src+Dst;
   For i:=LastPos downto Src do
    begin
     Env^[Dst]:=Env^[i];
     Dec(Dst);
    end;
  end;
end;
begin
 Space:=GetEnvSpace;
 LastPos:=EnvPos;
 FindEnvStr(VarName);
 if Value='' then
  begin
   {Clearing environment variable}
   if Env^[EnvPos]=#0 then exit;{Variable is not defined}
   k:=EnvPos;
   {Find begin of line}
   While (k>0) and (Env^[k]<>#0)do dec(k);
   if Env^[k]=#0 then inc(K);
   {Find end of Line}
   SkipLine;
   {Move rest of Environment}
   MoveEnv(EnvPos,k);
  end
  else
 begin
  {Set new Value}
  if Env^[EnvPos]=#0 then
   begin
    {Variable is not already defined}
    k:=Length(VarName)+Length(Value)+2;
    if Space<K then begin DosError:=8;exit end;
    MoveEnv(EnvPos,EnvPos+k);
    StoreStr(VarName);StoreStr('=');StoreStr(Value);StoreStr(#0);
   end
  else
   begin
    k:=Succ(EnvPos);
    SkipLine;
    Dec(EnvPos);
    if Space+EnvPos-k<Length(Value) then begin
     DosError:=8;
     exit;
    end;
   MoveEnv(EnvPos,K+Length(Value));
   EnvPos:=K;
   StoreStr(Value);
  end;
 end;
end;
Function GetProgName:String;
begin
 EnvPos:=0;
 While Env^[EnvPos]<>#0 do SkipLine;
 inc(envpos);
 if Env^[EnvPos]=#1 then
  begin
   inc(EnvPos,2);
   GetProgName:=CopyStr;
  end
  else
   GetProgName:='';
end;
Type PtrPtr=^Pointer;
     StrPtr=^String;
     WordPtr=^Word;
Function GetCommandLine:String;
var P:Pointer;
Begin

 GetCommandLine:=StrPtr(CommandLineAddress)^;
end;
Function CommandLineAddress:Pointer;
begin
 CommandLineAddress:=Ptr(WordPtr(Ptr(Pred(Environment),1))^,$80)
end;
Function OldInt22H:Pointer;
begin
 OldInt22H:=PtrPtr(Ptr(PrefixSeg,$A))^;
end;

Function OldInt23H:Pointer;
begin
 OldInt23H:=PtrPtr(Ptr(PrefixSeg,$E))^;
end;
Function OldInt24H:Pointer;
begin
 OldInt24H:=PtrPtr(Ptr(PrefixSeg,$12))^;
end;
Procedure AccessCurrentEnv;
Type PWord=^Word;
begin
 Environment:=PWord(Ptr(PrefixSeg,$2C))^;
end;
Procedure AccessRootEnv;
    {-Return master environment record}
  var
    Owner : Word;
    Mcb : Word;
    Eseg : Word;
    Done : Boolean;
  begin

      {Interrupt $2E points into COMMAND.COM}
      Owner := MemW[0:(2+4*$2E)];

      {Mcb points to memory control block for COMMAND}
      Mcb := Owner-1;
      if (Mem[Mcb:0] <> Byte('M')) or (MemW[Mcb:1] <> Owner) then
        Exit;

      {Read segment of environment from PSP of COMMAND}
      Eseg := MemW[Owner:$2C];

      {Earlier versions of DOS don't store environment segment there}
      if Eseg = 0 then begin
        {Master environment is next block past COMMAND}
        Mcb := Owner+MemW[Mcb:3];
        if (Mem[Mcb:0] <> Byte('M')) or (MemW[Mcb:1] <> Owner) then
          {Not the right memory control block}
          Exit;
        Eseg := Mcb+1;
      end else
        Mcb := Eseg-1;

      {Return segment and length of environment}
      Environment := Eseg;
    end;

   {$F+}
   Procedure MakeTempFile(var F:File);External;
   {$F-}
   {$L TEMPFILE.OBJ}

   Procedure AssignTemp(var F;TempDir:String);
   begin
       if (Length(TempDir)=0) then GetDir(0,TempDir);
    if (TempDir[Length(TempDir)]<>'\') then
     begin
      Inc(TempDir[0]);
      TempDir[Length(TempDir)]:='\';
     end;
    Assign(Text(F),TempDir);
    MakeTempFile(File(F));
  end;
  Procedure CloseTemp(var F);
  begin
   if TextRec(F).Mode<>fmClosed then
     if TextRec(F).CloseFunc<>nil then Close(Text(F)) else Close(File(F));
   Erase(File(F));
  end;
  Function GetFileName(var f):String;
  var S:String;
      i:Integer;
  begin
   S:='';
   i:=0;
   With FileRec(F) do
    while Name[i]<>#0 do begin S:=S+Name[i];inc(i) end;
   GetFileName:=S;
 end;
Procedure OpenStd(var F:Text;Device:Word);
begin
  Assign(F,'');
  Case Device of
  STDIN,STDAUXin:Reset(F);
  STDOUT,STDERR,STDPRN,STDAUX:Rewrite(F);
  else exit;
 end;
 if Device = STDErr then TextRec(F).BufSize:=1 else
 if Device=STDAUXin then Device:=stdAUX;
 TextRec(F).Handle:=Device;
end;
{Set PagingMode variables and functions}
Var OldInOut:Pointer;
    MoreMessage:String[75];
    LineCount:Integer;
    LineLimit:Integer;
Function CallOldInOut(var F:TextRec):Integer;
inline($FF/$1E/OldInOut);
{$F+}
Function PageOut(var F:TextRec):Integer;
{$F-}
var i:Word;BP,BE:Word;R:Integer;S:String;Ch:Char;
begin
 {Scanning buffer, counting LF until BufPos Reached or LineLimit lines found}
 i:=0;
 While (i<F.BufPos) and (LineCount<LineLimit)do
  begin
  {$R-}
   if F.BufPtr^[i]=#10 then inc(LineCount);
   inc(i);
  end;
   BP:=F.BufPos;
   F.BufPos:=i;
   R:=CallOldInOut(F);
   if LineCount=LineLimit then begin
     StdWrite(STDErr,MoreMessage);
     Repeat
      Ch:=Upcase(DOSReadKey);
     Until (Ch='N') or (Ch='Y');
     StdWrite(2,ch);
     LineCount:=0;
     if Ch='Y' then
      begin
       S[0]:=Chr(Length(MoreMessage)+1);
       FillChar(S[1],ord(S[0]),' ');
       StdWrite(StdErr,#13+S+#13);
       PageOut:=R;
       Move(F.BufPtr^[i],F.BufPtr^[0],BP-i);
       F.BufPos:=BP-i;
      end else PageOut:=101;
    end
  else PageOut:=R;
end;
Procedure SetPagingMode(var F :Text; H :Integer; Message:String);
begin
 With TextRec(F) do
  begin
   if OldInOut<>nil then
    begin
     DosError:=4;
     exit;
    end;
   OldInOut:=InOutFunc;
   InOutFunc:=@PageOut;
   FlushFunc:=@PageOut;
   LineLimit:=H;
   LineCount:=0;
   MoreMessage:=Copy(Message,1,75);
  end;
end;
Procedure EndPagingMode(var F:Text);
begin
 With TextRec(F) do
  begin
   if InOutFunc<>@PageOut then
    begin
     DosError:=6;
     Exit;
    end;
   InOutFunc:=OldInOut;
   FlushFunc:=OldInOut;
   OldInOut:=nil;
  end;
end;
Function GetStr(var F:Text):String;
var S:String;
begin
 Readln(F,S);
 GetStr:=S;
end;
Function ExtPos(FileName:String):Integer;
var I:Integer;
begin
 i:=Length(FileName)-3;
 While (I<=Length(FileName))and(FileName[i]<>'.') do inc(i);
 ExtPos:=i;
end;
Function JustFileName(FileName:String):String;
var i:Integer;
begin
 i:=Length(FileName);
 While (i>0)and(FileName[i]<>'\') do Dec(i);
 if FileName[i]='\' then inc(i);
 JustFileName:=Copy(FileName,i,255);
end;
Function JustName(FileName:String):String;
var i:Integer;
begin
  FileName:=JustFileName(FileName);
  Delete(FileName,ExtPos(FileNAme),4);
  JustName:=FileName;
end;
Function JustExtension(FileName:String):String;
var I:Integer;
begin
 JustExtension:=Copy(FileName,ExtPos(FileName)+1,3);
end;
Function JustPathName(FileName:String):String;
var i:Integer;
begin
 i:=Length(FileName);
 While (i>0)and(FileName[i]<>'\') do Dec(i);
 if (i=3) and(FileName[2]=':') then inc(i);
 JustPathName:=Copy(FileName,1,I-1);
end;
Function DefaultExtension(FileName,Extension:String):String;
var i:Integer;
begin
 if ExtPos(FileName)>Length(FileName) then
  DefaultExtension:=FileName+'.'+Extension
 else
  DefaultExtension:=FileName;
end;
Function ForceExtension(FileName,Extension:String):String;
begin
 ForceExtension:=Copy(FileName,1,ExtPos(FileName)-1)+'.'+Extension;
end;
Function ExpandFileName(FileName,DefaultExt,DefaultDir:String):String;
begin
 ExpandFileName:=FSearch(DefaultExtension(FileName,DefaultExt),DefaultDir);
end;
Procedure StdOutWrite(Buf:Pointer;Count:Word);far;external;
{$L DUPOUT}

Function NewInOut(var F:TextRec):Integer;far;
begin
 if DuplicateOutput then StdOutWrite(F.BufPtr,F.BufPos);
 NewInOut:=CallOldInOut(F);
end;
Procedure Tee(var F:Text);
begin
 With TextRec(F) do
  begin
   OldInOut:=InOutFunc;
   InOutFunc:=@NewInOut;
   FlushFunc:=@NewInOut;
  end;
 DuplicateOutput:=True;
end;
{$F+}
Function MemInOut(var F:TextRec):Integer;
begin
 F.BufPos:=0;
 F.BufEnd:=0;
 MemInOut:=0;
end;
Function DoNothing(var F:TextRec):integer;
begin
 DoNothing:=0;
end;
Function MemOpen(var F:TextRec):Integer;
begin
 F.CloseFunc:=@DoNothing;
 F.FlushFunc:=@DoNothing;
 F.InOutFunc:=@MemInOut;
 F.BufPos:=0;
 F.BufEnd:=F.BufSize;
 MemOpen:=0;
end;
Procedure AssignMemory(var F:Text;var Buffer;BufSize:Word);
var T:TextRec absolute F;
begin
 T.Mode:=fmClosed;
 T.BufPtr:=@Buffer;
 T.BufSize:=BufSize;
 T.OpenFunc:=@MemOpen;
end;
Procedure LoadTextFile(var F:Text);
var B:File absolute F;
    Size:LongInt;
    SaveHeapError:Pointer;
    P:Pointer;

begin
 Reset(B,1);
 Size:=FileSize(B);
 if Size>65521 then
  begin
   Close(B);
   InOutRes:=8;
   exit;
  end;
 if MaxAvail<Size then
  begin
   Close(B);
   InOutRes:=8;
   exit;
  end;
 GetMem(P,Size);
 BlockRead(B,P^,Size);
 Close(B);
 AssignMemory(F,P^,Size);
end;
Procedure CloseLoaded(var F:Text);
begin
 Close(F);
 With TextRec(F) do
   FreeMem(BufPtr,BufSize);
end;


begin
 AccessCurrentEnv;
 ZeroWord:=0;
 OldInOut:=nil;
end.
