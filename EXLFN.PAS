
program Test;
  {-test suite for LFN unit}

uses
  dos, lfn;

const
  Digits : array[0..$F] of Char = '0123456789ABCDEF';

  function HexB(B : Byte) : string;
  begin
    HexB[0] := #2;
    HexB[1] := Digits[B shr 4];
    HexB[2] := Digits[B and $F];
  end;

  function HexW(W : Word) : string;
  begin
    HexW[0] := #4;
    HexW[1] := Digits[hi(W) shr 4];
    HexW[2] := Digits[hi(W) and $F];
    HexW[3] := Digits[lo(W) shr 4];
    HexW[4] := Digits[lo(W) and $F];
  end;

  function HexL(L : LongInt) : string;
  type
    Long =
    record
      LowWord, HighWord : Word;
    end;
  begin
    with Long(L) do
      HexL := HexW(HighWord)+HexW(LowWord);
  end;

  procedure DisplayTime(const Msg : string; Time : LongInt; Ms10 : Word);
  var
    DT : DateTime;
    Secs : Real;
  begin
    if Time = 0 then
      exit;
    UnpackTime(Time, DT);
    Secs := DT.Sec+Ms10/200;
    WriteLn(Msg, ' ',
          DT.Year, '/', DT.Month, '/', DT.Day, ' ',
          DT.Hour, ':', DT.Min, ':', Secs:0:2);
  end;

var
  Ver : Word;
  InitName : string;
  Name : string;
  Name2 : string;
  Flags : Word;
  MaxNameLen : Word;
  MaxPathLen : Word;
  FHandle : Word;
  Time : LongInt;
  DT : DateTime;
  Ms10 : Word;
  SR : TLFNSearchRec;

begin
  Ver := dosversion;
  writeln('DOS version: ', lo(Ver), '.', hi(Ver));

  DosError := LFNGetVolumeInfo('c:\', Name,  Flags, MaxNameLen, MaxPathLen);
  if DosError <> 0 then
    WriteLn('LFNGetVolumeInfo error: ', DosError)
  else begin
    WriteLn('FileSysName: ', Name);
    WriteLn('FileSysFlags: ', HexW(Flags), 'H');
    WriteLn('MaxNameLen: ', MaxNameLen);
    WriteLn('MaxPathLen: ', MaxPathLen);
  end;

  DosError := LFNGetDir(0, InitName);
  if DosError <> 0 then
    WriteLn('LFNGetDir error: ', DosError)
  else
    WriteLn('Current dir: ', InitName);

  DosError := LFNChDir('c:\progra~1');
  if DosError <> 0 then
    WriteLn('LFNChDir error: ', DosError);
  DosError := LFNGetDir(0, Name);
  if DosError <> 0 then
    WriteLn('LFNGetDir error: ', DosError)
  else
    WriteLn('Current dir: ', Name);

  DosError := LFNGetShortPath(False, Name, Name2);
  if DosError <> 0 then
    WriteLn('LFNGetShortPath error: ', DosError)
  else
    WriteLn('Current short dir: ', Name2);

  DosError := LFNGetFullPath(False, Name, Name2);
  if DosError <> 0 then
    WriteLn('LFNGetFullPath error: ', DosError)
  else
    WriteLn('Current full dir: ', Name2);

  DosError := LFNGetLongPath(False, Name, Name2);
  if DosError <> 0 then
    WriteLn('LFNGetLongPath error: ', DosError)
  else
    WriteLn('Current long dir: ', Name2);

  DosError := LFNChDir(InitName);
  if DosError <> 0 then
    WriteLn('LFNChDir error: ', DosError);

  DosError := LFNOpenFile('c:\autoexec.bat',OpenAccessReadOnly, 0,
                          FileOpen, Flags, FHandle);
  if DosError <> 0 then
    WriteLn('LFNOpenFile error: ', DosError)
  else begin
    WriteLn('LFNOpenFile ActionTaken: ', Flags);
    DosError := LFNGetAccessFTime(FHandle, Time);
    if DosError <> 0 then
      WriteLn('LFNGetAccessFTime error: ', DosError)
    else
      DisplayTime('Access time: ', Time, 0);
    DosError := LFNGetCreationFTime(FHandle, Time, Ms10);
    if DosError <> 0 then
      WriteLn('LFNGetCreationFTime error: ', DosError)
    else
      DisplayTime('Creation time: ', Time, Ms10);


    DT.Year := 1985;
    DT.Month := 12;
    DT.Day := 26;
    DT.Hour := 20;
    DT.Min := 0;
    DT.Sec := 0;
    PackTime(DT, Time);
    DosError := LFNSetAccessFTime(FHandle, Time);
    if DosError <> 0 then
      WriteLn('LFNSetAccessFTime error: ', DosError);
    DosError := LFNSetCreationFTime(FHandle, Time, 0);
    if DosError <> 0 then
      WriteLn('LFNSetCreationFTime error: ', DosError);
    SetFTime(FHandle, Time);

    DosError := LFNGetAccessFTime(FHandle, Time);
    if DosError <> 0 then
      WriteLn('LFNGetAccessFTime error: ', DosError)
    else
      DisplayTime('Access time: ', Time, 0);
    DosError := LFNGetCreationFTime(FHandle, Time, Ms10);
    if DosError <> 0 then
      WriteLn('LFNGetCreationFTime error: ', DosError)
    else
      DisplayTime('Creation time: ', Time, Ms10);

    DosError := LFNSetFAttr('c:\autoexec.bat', 0);
    if DosError <> 0 then
      WriteLn('LFNSetFAttr error: ', DosError);

    DosError := LFNGetFAttr('c:\autoexec.bat', Flags);
    if DosError <> 0 then
      WriteLn('LFNGetFAttr error: ', DosError)
    else
      WriteLn('File attribute: ', HexW(Flags));
  end;

  DosError := LFNRename('c:\bootlog.prv', 'c:\t.t');
  if DosError <> 0 then
    WriteLn('LFNRename error: ', DosError);

  DosError := LFNRmDir('c:\a long test name');
  if DosError <> 0 then
    WriteLn('LFNRmDir error: ', DosError);

  DosError := LFNMkDir('c:\a long test name');
  if DosError <> 0 then
    WriteLn('LFNMkDir error: ', DosError);

  DosError := LFNGenerateShortName('Program Files', Name,
                                   BcsWansi, BcsWansi, False);
  if DosError <> 0 then
    WriteLn('LFNGenerateShortName error: ', DosError)
  else
    WriteLn('ShortName: ', Name);

  DosError := LFNDeleteFile('c:\t.t', False, 0, 0);
  if DosError <> 0 then
    WriteLn('LFNDeleteFile error: ', DosError);

  DosError := LFNFindFirst('*.*', $00, $16, SR);
  while DosError = 0 do begin
    if SR.AltName = '' then
      SR.AltName := SR.Name;
    WriteLn(SR.AltName:13, ' ',
            HexW(SR.Attr), ' ',
            SR.Size:8, ' ',
            SR.Name);
    DisplayTime('  Access   ', SR.AccessTime, 0);
    DisplayTime('  Write    ', SR.WriteTime, 0);

    DosError := LFNFindNext(SR);
  end;
  LFNFindClose(SR);

end.
