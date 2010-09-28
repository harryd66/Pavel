{Notes:
  This DOS-based program is a demonstration of the LFN long filename
  unit. It is a "super directory" program that supports long
  filenames. It runs in a Windows 95 DOS box. It also runs on older
  DOS systems by falling back to non-Win32 DOS calls when needed.

  Usage: SDIR [options] [mask1 mask2 ...]

  Options:
    /AN /DN  sort by name ascending or descending
    /AE /DE  sort by extension "
    /AS /DS  sort by size      "
    /AT /DT  sort by time      "
    /AD /DD  sort by DOS order " [default]

    /S       show subdirectories
    /SO      show subdirectories only
    /H       show hidden files
    /HO      show hidden files only

    /Mn      show only files modified in last n days
    /M       show only files modified today (equiv to /M0)
    /Bn      show only files not modified in last n days
    /Ln      show only files < n bytes
    /Gn      show only files > n bytes

    /T       display totals (file count and byte count)
    /TO      display totals only

    /W       display whole pathname only (no totals available)
    /N       display filename only       (no totals available)
    /C       display in compressed (5 column) format
    /F       display full information [default]

    /R       recurse through all subdirectories of starting mask
    /Vmask   don't display any files matching mask

  If more than one mask is specified, files matching any of the masks
  are displayed. If one or more /V options is specified, files matching
  any of these masks are *not* displayed. If no masks are specified,
  a default mask of *.* is supplied.

  The wildcard matcher handles masks such as '*dir*.*'.

  Quotes (") can be used to delimit command line parameters that contain
  embedded spaces.

  Kim Kokkonen, TurboPower Software Co.
  CompuServe 76004,2611

  May be distributed freely, but not sold.

  Version 1.0, 10/24/95
}

{$S-,R-,V-,I-}
{$M 32768,0,655360}

program SDir;
  {-Super directory that supports Win95 long filenames}

uses
  Dos, LFN;

const
  AnyChar = '*';         {Match zero or more characters}
  OneChar = '?';         {Match exactly one character}
  EndChar = #255;        {Terminator to match strings}

type
  TShortName = string[13];
  TLongName = string;
  PLongName = ^TLongName;

  PFileNode = ^TFileNode;
  TFileNode =
  object
    Next : PFileNode;
    Attr : LongInt;
    Time : LongInt;
    Size : LongInt;
    Dir  : PLongName;
    AltName : TShortName;
    Name : TLongName;

    procedure Init(AAttr, ATime, ASize : LongInt; ADir : PLongName;
                   const AName : TLongName; const AAltName : TShortName);
  end;

  PDosWildMatcher = ^TDosWildMatcher;
  TDosWildMatcher =
  object
    Mask : string;
    procedure Init(const AMask : string);
    function Matches(Name : string) : Boolean;
  end;

  PMatchNode = ^TMatchNode;
  TMatchNode =
  object
    Next : PMatchNode;
    Matcher : PDosWildMatcher;
    Avoid : Boolean;
  end;

  TSortMode = (smName, smExt, smSize, smTime, smDos);
  TDispMode = (dmFull, dmNameOnly, dmPathOnly, dmCompressed, dmTotalsOnly);

  TSortedFileList =
  object
    Head : PFileNode;
    Tail : PFileNode;

    DCount : LongInt;
    DSize : LongInt;

    SortMode : TSortMode;
    SortDown : Boolean;
    DispMode : TDispMode;
    Recursive : Boolean;
    Totals : Boolean;
    Dummy : Boolean; {word align}

    ReqdAttr : Word;
    AcptAttr : Word;
    MinSize : LongInt;
    MaxSize : LongInt;
    MinAge : LongInt;
    MaxAge : LongInt;
    MaskList : PMatchNode;
    StartDir : string;

    procedure InitFromCommandLine;
    procedure Clear;

    procedure UpdateStartDir(const AMask : string);
    function MatchSpecified : Boolean;
    procedure InsertMatchNode(AMask : string; AAvoid : Boolean);

    function Less(N1, N2 : PFileNode) : Boolean;
    procedure Insert(N : PFileNode);
    function Nth(N : LongInt) : PFileNode;

    function AcceptableName(const Name : string) : Boolean;
    function AcceptableAge(Time : LongInt) : Boolean;
    procedure BuildOne(const CurDir : string);
    procedure Build;

    procedure WriteLnPause;
    procedure ShowDirTotals;
    procedure DisplayFull;
    procedure DisplayNameOnly;
    procedure DisplayPathOnly;
    procedure DisplayCompressed;
    procedure DisplayTotalsOnly;
    procedure Display;
  end;

var
  SFL : TSortedFileList;


  {---------------------------------------------------}

  function Locase(Ch : Char) : Char;
  begin
    case Ch of
      'A'..'Z' : Locase := Char(Byte(Ch)+32);
    else
      Locase := Ch;
    end;
  end;

  function StLocase(const S : string) : string;
  var
    I : Word;
  begin
    for I := 1 to Length(S) do
      StLocase[I] := Locase(S[I]);
    StLocase[0] := S[0];
  end;

  function CommaIze(L : LongInt; Width : Byte) : String;
    {-Convert L to a string and add commas for thousands}
  var
    I : Word;
    Len : Word;
    S : String[19];
  begin
    Str(L, S);
    Len := Length(S);
    I := Len;
    while I > 1 do begin
      if (Len+1-I) mod 3 = 0 then
        Insert(',', S, I);
      dec(I);
    end;
    while Length(S) < Width do
      Insert(' ', S, 1);
    CommaIze := S;
  end;

  function ZeroIze(L : LongInt; Width : Byte) : string;
    {-Convert L to a string and change spaces to zeros}
  var
    I : Word;
    Tmp : string;
  begin
    Str(L:Width, Tmp);
    for I := 1 to Width do
      if Tmp[I] = ' ' then
        Tmp[I] := '0';
    ZeroIze := Tmp;
  end;

  procedure ParsePathname(const Name : string;
                          var FirstColonPos, LastSlashPos, LastDotPos : Word);
  var
    I : Word;
  begin
    FirstColonPos := Pos(':', Name);

    LastSlashPos := 0;
    LastDotPos := 0;

    I := Length(Name);
    while I > 0 do begin
      case Name[I] of
        ':', '\' :
          begin
            LastSlashPos := I;
            Exit;
          end;
        '.' :
          LastDotPos := I;
      end;
      Dec(I);
    end;
  end;

  {---------------------------------------------------}

  procedure TFileNode.Init(AAttr, ATime, ASize : LongInt;
                           ADir : PLongName;
                           const AName : TLongName;
                           const AAltName : TShortName);
  begin
    Attr := AAttr;
    Time := ATime;
    Size := ASize;
    Dir := ADir;
    Name := AName;
    AltName := AAltName;
    Next := nil;
  end;

  {---------------------------------------------------}

  procedure TSortedFileList.Clear;
  var
    P, N : PFileNode;
  begin
    P := Head;
    while P <> nil do begin
      N := P^.Next;
      FreeMem(P, SizeOf(TFileNode)-SizeOf(TLongName)+Length(P^.Name)+1);
      P := N;
    end;
    Head := nil;
    Tail := nil;
  end;

  function TSortedFileList.Less(N1, N2 : PFileNode) : Boolean;
  var
    IsLess : Boolean;

    function ExtLess(N1, N2 : PFileNode) : Boolean;
    var
      Ext1 : string;
      Name1 : string;
      Ext2 : string;
      Name2 : string;

      procedure GetNameExt(const FullName : string;
                           var Name, Ext : string);
      var
        FCP : Word;
        LSP : Word;
        LDP : Word;
      begin
        ParsePathname(FullName, FCP, LSP, LDP);
        if LDP = 0 then begin
          Name := FullName;
          Ext := '';
        end else begin
          Name := Copy(FullName, 1, LDP-1);
          Ext := Copy(FullName, LDP+1, 255);
        end;
      end;

    begin
      GetNameExt(N1^.AltName, Name1, Ext1);
      GetNameExt(N2^.AltName, Name2, Ext2);

      if Ext1 < Ext2 then
        ExtLess := True
      else if Ext1 > Ext2 then
        ExtLess := False
      else
        ExtLess := (Name1 < Name2);
    end;

  begin
    if N1^.Dir = N2^.Dir then
      {keep directories together regardless of mode}
      case SortMode of
        smName :
          IsLess := (N1^.AltName < N2^.AltName);

        smExt :
          IsLess := ExtLess(N1, N2);

        smSize :
          if N1^.Size < N2^.Size then
            IsLess := True
          else if N1^.Size > N2^.Size then
            IsLess := False
          else
            IsLess := (N1^.AltName < N2^.AltName);

        smTime :
          if N1^.Time < N2^.Time then
            IsLess := True
          else if N1^.Time > N2^.Time then
            IsLess := False
          else
            IsLess := (N1^.AltName < N2^.AltName);
      end

    else
      IsLess := (N1^.Dir^ < N2^.Dir^);

    Less := IsLess xor SortDown;
  end;

  procedure TSortedFileList.Insert(N : PFileNode);
  var
    O, P : PFileNode;
  begin
    if Head = nil then begin
      {first element added to list}
      Head := N;
      Tail := N;
    end else if SortMode = smDos then begin
      {always insert at head or tail}
      if SortDown then begin
        N^.Next := Head;
        Head := N;
      end else begin
        Tail^.Next := N;
        Tail := N;
      end;
    end else begin
      O := nil;
      P := Head;
      while P <> nil do begin
        if Less(N, P) then begin
          if O = nil then
            {new head}
            Head := N
          else
            O^.Next := N;
          N^.Next := P;
          Exit;
        end;
        O := P;
        P := P^.Next;
      end;
      {new tail}
      O^.Next := N;
      Tail := N;
    end;
  end;

  function TSortedFileList.MatchSpecified : Boolean;
  var
    MN : PMatchNode;
  begin
    MN := MaskList;
    while MN <> nil do begin
      if not MN^.Avoid then begin
        MatchSpecified := True;
        Exit;
      end;
      MN := MN^.Next;
    end;
    MatchSpecified := False;
  end;

  function TSortedFileList.AcceptableName(const Name : string) : Boolean;
  var
    MN : PMatchNode;
    Matches : Boolean;
  begin
    if (Name <> '.') and (Name <> '..') then begin
      Matches := False;
      MN := MaskList;
      while MN <> nil do begin
        if MN^.Matcher^.Matches(Name) then
          if MN^.Avoid then begin
            AcceptableName := False;
            Exit;
          end else
            Matches := True;
        MN := MN^.Next;
      end;
      AcceptableName := Matches;
    end else
      AcceptableName := False;
  end;

  function TSortedFileList.AcceptableAge(Time : LongInt) : Boolean;
  var
    DT : DateTime;
    Year, Month, Day, DayOfWeek: Word;
    JToday : LongInt;
    JSR : LongInt;
    Age : LongInt;

    function DMYtoJulian(Day, Month, Year : Word) : LongInt;
    begin
      if Month > 2 then
        Dec(Month, 3)
      else begin
        Inc(Month, 9);
        Dec(Year);
      end;
      Dec(Year, 1600);
      DMYtoJulian :=
          ((LongInt(Year div 100)*146097) div 4)+
          ((LongInt(Year mod 100)*1461) div 4)+
          (((153*Month)+2) div 5)+Day;
    end;

  begin
    if (MinAge = 0) and (MaxAge = MaxLongInt) then
      AcceptableAge := True
    else begin
      UnpackTime(Time, DT);
      JSR := DMYToJulian(DT.Day, DT.Month, DT.Year);
      GetDate(Year, Month, Day, DayOfWeek);
      JToday := DMYToJulian(Day, Month, Year);
      Age :=  JToday-JSR;
      AcceptableAge := (Age >= MinAge) and (Age <= MaxAge);
    end;
  end;

  procedure TransferSR(const DosSR : SearchRec; var SR : TLFNSearchRec);
  begin
    FillChar(SR, SizeOf(TLFNSearchRec), 0);
    SR.Attr := DosSR.Attr;
    SR.WriteTime:= DosSR.Time;
    SR.Size := DosSR.Size;
    SR.Name := DosSR.Name;
  end;

  procedure DualFindFirst(const Path : string; Attr : Byte;
                          var SR : TLFNSearchRec; var DosSR : SearchRec);
  begin
    DosError := LFNFindFirst(Path, 0, Attr, SR);
    if DosError > 255 then begin
      SR.Handle := 0;
      FindFirst(Path, Attr, DosSR);
      if DosError = 0 then
        TransferSR(DosSR, SR);
    end;
  end;

  procedure DualFindNext(var SR : TLFNSearchRec; var DosSR : SearchRec);
  begin
    if SR.Handle <> 0 then
      DosError := LFNFindNext(SR)
    else begin
      FindNext(DosSR);
      if DosError = 0 then
        TransferSR(DosSR, SR);
    end;
  end;

  procedure DualFindClose(var SR : TLFNSearchRec);
  begin
    if SR.Handle <> 0 then
      LFNFindClose(SR);
  end;

  procedure TSortedFileList.BuildOne(const CurDir : string);
  var
    N : PFileNode;
    DirP : PLongName;
    SHandle : Word;
    TmpAttr : Byte;
    GotDir : Boolean;
    SR : TLFNSearchRec;
    DosSR : SearchRec;
    TmpDir : string;

    procedure BuildMask(const CurDir, Mask : string; var FullMask : string);
    begin
      FullMask := CurDir+StLocase(Mask);
    end;

    procedure BuildSubDir(const CurDir, SubName : string; var NewDir : string);
    begin
      NewDir := CurDir+StLocase(SubName)+'\';
    end;

    procedure UpdateNames(var AltName, Name : string);
    begin
      if AltName = '' then begin
        {there is no long name}
        AltName := StLocase(Name);
        Name := '';
      end else begin
        AltName := StLocase(AltName);
        if AltName = StLocase(Name) then
          {long name is not substantially different}
          Name := '';
      end;
    end;

  begin
    DirP := nil;

    BuildMask(CurDir, '*.*', TmpDir);

    {add entries to linked list first}
    GotDir := False;
    DualFindFirst(TmpDir, AnyFile, SR, DosSR);
    while DosError = 0 do begin
      {treat hidden and system files the same}
      TmpAttr := SR.Attr;
      if TmpAttr and SysFile <> 0 then
        TmpAttr := TmpAttr or Hidden;
      if TmpAttr and Directory <> 0 then
        GotDir := True;
      if (((ReqdAttr and (not TmpAttr)) and $3F = 0) and
          (((not AcptAttr) and TmpAttr) and $1E = 0)) then
        {attribute ok}
        if (TmpAttr and Directory <> 0) or
           ((SR.Size >= MinSize) and (SR.Size <= MaxSize)) then
          {size ok}
          if AcceptableName(SR.Name) then
            {name ok}
            if AcceptableAge(SR.WriteTime) then begin
              {age ok}
              if DirP = nil then begin
                {store the directory name for use by reports}
                GetMem(DirP, Length(CurDir)+1);
                DirP^ := CurDir;
              end;

              {update the short and long names}
              UpdateNames(SR.AltName, SR.Name);

              {create the new file node and insert it in proper order}
              GetMem(N, SizeOf(TFileNode)-SizeOf(TLongName)+Length(SR.Name)+1);
              N^.Init(SR.Attr, SR.WriteTime, SR.Size, DirP, SR.Name, SR.AltName);
              Insert(N);
            end;
      DualFindNext(SR, DosSR);
    end;
    DualFindClose(SR);

    {trace directories}
    if Recursive and GotDir then begin
      DualFindFirst(TmpDir, AnyFile, SR, DosSR);
      while DosError = 0 do begin
        if SR.Attr and Directory <> 0 then
          if (SR.Name <> '.') and (SR.Name <> '..') then begin
            BuildSubDir(CurDir, SR.Name, TmpDir);
            BuildOne(TmpDir);
          end;
        DualFindNext(SR, DosSR);
      end;
      DualFindClose(SR);
    end;
  end;

  procedure TSortedFileList.Build;
  begin
    {call a recursive routine for the starting directory}
    BuildOne(StartDir);
  end;

  procedure TSortedFileList.WriteLnPause;
  begin
    {pause at full screen could occur here}
    {would need detection of screen height plus a readkey function}
    WriteLn;
  end;

  procedure TSortedFileList.ShowDirTotals;
  begin
    if Totals then begin
      WriteLnPause;
      Write(DCount, ' file');
      if DCount <> 1 then
        Write('s');
      Write(', ', CommaIze(DSize, 0), ' bytes');
      WriteLnPause;
    end;
    DSize := 0;
    DCount := 0;
  end;

  procedure TSortedFileList.DisplayFull;
  var
    I : Word;
    Len : Word;
    FCP : Word;
    LSP : Word;
    LDP : Word;
    DT : DateTime;
    N : PFileNode;
    LastDir : PLongName;

    function AttrChar(Attr, Mask : Word; Ch : Char) : Char;
    begin
      if Attr and Mask <> 0 then
        AttrChar := Ch
      else
        AttrChar := '.';
    end;

  begin
    LastDir := nil;
    DSize := 0;
    DCount := 0;
    N := Head;

    while N <> nil do begin
      with N^ do begin
        {show directory name for recursive option}
        if Recursive then
          if LastDir <> Dir then begin
            if LastDir <> nil then begin
              ShowDirTotals;
              WriteLnPause;
            end;
            Write(Dir^);
            WriteLnPause;
            LastDir := Dir;
          end;

        {short name}
        Len := Length(AltName);
        if Attr and Directory <> 0 then
          Write(AltName)
        else begin
          ParsePathname(AltName, FCP, LSP, LDP);
          if LDP = 0 then
            Write(AltName)
          else begin
            Write(Copy(AltName, 1, LDP-1));
            for I := LDP to 9 do
              Write(' ');
            Write(Copy(AltName, LDP+1, 255));
            Len := 9+Length(AltName)-LDP;
          end;
        end;
        for I := Len to 12 do
          Write(' ');

        {size}
        if Attr and Directory <> 0 then
          Write('<dir>':11)
        else
          Write(CommaIze(Size, 11));

        Inc(DCount);
        Inc(DSize, Size);

        {date and time}
        UnpackTime(Time, DT);
        Write('  ',
              ZeroIze(DT.Month, 2),      '/',
              ZeroIze(DT.Day, 2),        '/',
              ZeroIze(DT.Year-1900, 2),  ' ',
              ZeroIze(DT.Hour, 2),       ':',
              ZeroIze(DT.Min, 2),        ':',
              ZeroIze(DT.Sec, 2),        ' ');

        {attributes}
        Write(AttrChar(Attr, ReadOnly, 'r'),
              AttrChar(Attr, Hidden,   'h'),
              AttrChar(Attr, SysFile,  's'),
              AttrChar(Attr, Archive,  'a'), '  ');

        {long name}
        Write(Name);
        WriteLnPause;
      end;
      N := N^.Next;
    end;
    ShowDirTotals;
  end;

  procedure TSortedFileList.DisplayNameOnly;
  var
    N : PFileNode;
    LastDir : PLongName;
  begin
    LastDir := nil;
    N := Head;

    while N <> nil do begin
      with N^ do begin
        {show directory name for recursive option}
        if Recursive then
          if LastDir <> Dir then begin
            if LastDir <> nil then
              WriteLnPause;
            Write(Dir^);
            WriteLnPause;
            LastDir := Dir;
          end;
        Write(AltName);
        WriteLnPause;
      end;
      N := N^.Next;
    end;
  end;

  procedure TSortedFileList.DisplayPathOnly;
  var
    N : PFileNode;
  begin
    N := Head;

    while N <> nil do begin
      with N^ do
        Write(Dir^, AltName);
      WriteLnPause;
      N := N^.Next;
    end;
  end;

  function TSortedFileList.Nth(N : LongInt) : PFileNode;
  var
    Tmp : PFileNode;
  begin
    Tmp := Head;
    while (Tmp <> nil) and (N > 1) do begin
      Tmp := Tmp^.Next;
      dec(N);
    end;
    if N <> 1 then
      Nth := nil
    else
      Nth := Tmp;
  end;

  procedure TSortedFileList.DisplayCompressed;
  const
    NumCols = 5;
  var
    NumPerCol : LongInt;
    SNum : LongInt;
    ENum : LongInt;
    I : Word;
    Len : Word;
    N : PFileNode;
    P : PFileNode;
    LastDir : PLongName;
    Tmp : array[1..NumCols+1] of PFileNode;

    procedure DisplayItem(var N, NextColN : PFileNode);
    var
      I : Word;
    begin
      if N <> nil then begin
        Write(N^.AltName);
        Len := Length(N^.AltName);
        if N^.Attr and Directory <> 0 then begin
          Write('\');
          inc(Len);
        end;
        for I := Len to 12 do
          Write(' ');
        if NextColN <> nil then
          Write('   ')
        else
          WriteLnPause;
        Inc(DCount);
        Inc(DSize, N^.Size);
        N := N^.Next;
      end;
    end;

  begin
    SNum := 1;
    P := nil;
    N := Head;
    DCount := 0;
    DSize := 0;

    while N <> nil do begin
      ENum := SNum;
      LastDir := N^.Dir;
      while (N <> nil) and (N^.Dir = LastDir) do begin
        inc(ENum);
        P := N;
        N := N^.Next;
      end;

      {temporarily break list}
      P^.Next := nil;

      NumPerCol := (ENum-SNum+NumCols-1) div NumCols;
      for I := 1 to NumCols do
        Tmp[I] := Nth(SNum+(I-1)*NumPerCol);
      Tmp[NumCols+1] := nil;

      if Recursive then begin
        if SNum <> 1 then begin
          ShowDirTotals;
          WriteLnPause;
        end;
        Write(LastDir^);
        WriteLnPause;
      end;
      while NumPerCol > 0 do begin
        for I := 1 to NumCols do
          DisplayItem(Tmp[I], Tmp[I+1]);
        dec(NumPerCol);
      end;

      {prepare for next directory, if any}
      SNum := ENum;
      P^.Next := N;
    end;

    ShowDirTotals;
  end;

  procedure TSortedFileList.DisplayTotalsOnly;
  var
    TSize : LongInt;
    TCount : LongInt;
    N : PFileNode;
    LastDir : PLongName;
  begin
    LastDir := nil;
    DSize := 0;
    TSize := 0;
    DCount := 0;
    TCount := 0;
    N := Head;

          {nnnnn n,nnn,nnn,nnn dddddddddddd}
    Write('files   size(bytes) directory');
    WriteLnPause;

    while N <> nil do begin
      with N^ do begin
        if Recursive then
          if LastDir <> Dir then begin
            if LastDir <> nil then begin
              Write(DCount:5, ' ', CommaIze(DSize, 13), ' ', LastDir^);
              WriteLnPause;
            end;
            DCount := 0;
            DSize := 0;
            LastDir := Dir;
          end;
        Inc(DCount);
        Inc(DSize, Size);
        Inc(TCount);
        Inc(TSize, Size);
      end;
      N := N^.Next;
    end;
    if Recursive and (LastDir <> nil) then begin
      Write(DCount:5, ' ', CommaIze(DSize, 13), ' ', LastDir^);
      WriteLnPause;
    end;
    Write(TCount:5, ' ', CommaIze(TSize, 13), ' overall');
    WriteLnPause;
  end;

  procedure TSortedFileList.Display;
  begin
    case DispMode of
      dmFull :
        DisplayFull;
      dmNameOnly :
        DisplayNameOnly;
      dmPathOnly :
        DisplayPathOnly;
      dmCompressed :
        DisplayCompressed;
      dmTotalsOnly :
        DisplayTotalsOnly;
    end;
  end;

  procedure TSortedFileList.UpdateStartDir(const AMask : string);
  var
    FCP : Word;
    LSP : Word;
    LDP : Word;
    FullDir : string;
  begin
    DosError := LFNGetFullPath(False, AMask, FullDir);
    if DosError <> 0 then
      {drive doesn't support Win32 services}
      FullDir := FExpand(AMask);
    ParsePathname(FullDir, FCP, LSP, LDP);
    StartDir := StLocase(Copy(FullDir, 1, LSP));
  end;

  procedure DualGetDir(Drive : Byte; var DirName : string);
  begin
    DosError := LFNGetDir(Drive, DirName);
    if DosError > 255 then begin
      GetDir(Drive, DirName);
      DosError := 0;
    end;
  end;

  procedure DualChDir(const DirName : string);
  begin
    DosError := LFNChDir(DirName);
    if DosError > 255 then begin
      ChDir(DirName);
      DosError := IoResult;
    end;
  end;

  function IsDirectory(const AMask : string) : Boolean;
  var
    CurDir : string;
    CurDestDir : string;
    DiffDrive : Boolean;
  begin
    DualGetDir(0, CurDir);

    if (Length(AMask) >= 2) and (AMask[2] = ':') and
       (Locase(AMask[1]) <> Locase(CurDir[1])) then begin
      {Checking on a different drive}
      DiffDrive := True;
      DualGetDir(Byte(Locase(AMask[1]))-Byte('a')+1, CurDestDir);
      if DosError <> 0 then begin
        IsDirectory := False;
        Exit;
      end;
    end else
      DiffDrive := False;

    DualChDir(AMask);
    IsDirectory := (DosError = 0);

    if DiffDrive then
      DualChDir(CurDestDir);

    DualChDir(CurDir);
  end;

  procedure TSortedFileList.InsertMatchNode(AMask : string; AAvoid : Boolean);
  var
    FCP : Word;
    LSP : Word;
    LDP : Word;
    MaskNode : PMatchNode;
    JustMask : string;
  begin
    {determine whether AMask is a directory name}
    if IsDirectory(AMask) then begin
      case AMask[Length(AMask)] of
        '\', ':' : ;
      else
        AMask := AMask+'\';
      end;
      AMask := AMask+'*.*';
    end;

    ParsePathname(AMask, FCP, LSP, LDP);
    if (LSP <> 0) and (StartDir = '') then
      {a directory is specified, use it as start directory}
      UpdateStartDir(AMask);
    if LDP = 0 then
      {no extension is specified, assume a wildcard}
      AMask := AMask+'.*';

    {get just the wildcard part of the mask}
    JustMask := Copy(AMask, LSP+1, 255);

    {add the node}
    New(MaskNode);
    MaskNode^.Avoid := AAvoid;
    MaskNode^.Next := MaskList;
    MaskList := MaskNode;
    New(MaskNode^.Matcher);
    MaskNode^.Matcher^.Init(JustMask);
  end;

  procedure TSortedFileList.InitFromCommandLine;
  var
    Index : Word;
    MaxIndex : Word;
    Arg : string;

    procedure UnknownArg;
    begin
      WriteLn('Unknown option "', Arg, '"');
    end;

    procedure SetAttrFlag(Flag : Word);
    begin
      case Length(Arg) of
        2 :
          AcptAttr := AcptAttr or Flag;
        3 :
          if Upcase(Arg[3]) = 'O' then begin
            AcptAttr := AcptAttr or Flag;
            ReqdAttr := ReqdAttr or Flag;
          end else
            UnknownArg;
      else
        UnknownArg;
      end;
    end;

    procedure GetLongInt(var Number : LongInt);
    var
      Code : Word;
      NumTmp : LongInt;
      NumStr : string;
    begin
      if Length(Arg) = 2 then begin
        if Index = MaxIndex then begin
          UnknownArg;
          Exit;
        end;
        inc(Index);
        Arg := LFNParamStr(Index);
        NumStr := Arg;
      end else
        NumStr := Copy(Arg, 3, 255);
      Val(NumStr, NumTmp, Code);
      if Code <> 0 then
        UnknownArg
      else
        Number := NumTmp;
    end;

    procedure WriteHelp;
    begin
      WriteLn('Usage: SDIR [options] [mask1 mask2 ...]');
      WriteLn;
      WriteLn('Options:');
      WriteLn('  /AN /DN  sort by name, ascending or descending');
      WriteLn('  /AE /DE  sort by extension, "');
      WriteLn('  /AS /DS  sort by size,      "');
      WriteLn('  /AT /DT  sort by time,      "');
      WriteLn('  /AD /DD  sort by DOS order, " [default]');
      WriteLn;
      WriteLn('  /S       show subdirectories');
      WriteLn('  /SO      show subdirectories only');
      WriteLn('  /H       show hidden/system files');
      WriteLn('  /HO      show hidden/system files only');
      WriteLn;
      WriteLn('  /Mn      show only files modified in last n days');
      WriteLn('  /M       show only files modified today (equiv to /M0)');
      WriteLn('  /Bn      show only files not modified in last n days');
      WriteLn('  /Ln      show only files < n bytes');
      WriteLn('  /Gn      show only files > n bytes');
      WriteLn;
      WriteLn('  /W       display whole pathname only (no totals available)');
      WriteLn('  /N       display filename only       (no totals available)');
      WriteLn('  /C       display in compressed (5 column) format');
      WriteLn('  /F       display full information [default]');
      WriteLn;
      WriteLn('  /T       display totals (file count and byte count)');
      WriteLn('  /TO      display totals only');
      WriteLn;
      WriteLn('  /R       recurse through all subdirectories of starting directory');
      WriteLn('  /Vmask   don''t display any files matching mask');
      Halt;
    end;

  begin
    {default settings}
    SortMode := smDos;
    SortDown := False;
    DispMode := dmFull;
    Recursive := False;
    Totals := False;
    ReqdAttr := 0;
    AcptAttr := 0;
    MinSize := 0;
    MaxSize := MaxLongInt;
    MinAge := 0;
    MaxAge := MaxLongInt;
    MaskList := nil;
    StartDir := '';

    {initially empty}
    Head := nil;
    Tail := nil;

    Index := 1;
    MaxIndex := LFNParamCount;
    while Index <= MaxIndex do begin
      Arg := LFNParamStr(Index);
      if (Length(Arg) > 0) then
        case Arg[1] of
          '/', '-' :
            if Length(Arg) = 1 then
              UnknownArg
            else
              case Upcase(Arg[2]) of
                'A', 'D' : {ascending or descending sort}
                  if Length(Arg) = 3 then begin
                    SortDown := (Upcase(Arg[2]) = 'D');
                    case Upcase(Arg[3]) of
                      'D' : SortMode := smDos;
                      'E' : SortMode := smExt;
                      'N' : SortMode := smName;
                      'S' : SortMode := smSize;
                      'T' : SortMode := smTime;
                    else
                      UnknownArg;
                    end;
                  end else
                    UnknownArg;

                'B' : {files older than n days}
                  GetLongInt(MinAge);

                'C' : {compressed format}
                  if Length(Arg) = 2 then
                    DispMode := dmCompressed
                  else
                    UnknownArg;

                'F' : {full display format}
                  if Length(Arg) = 2 then
                    DispMode := dmFull
                  else
                    UnknownArg;

                'G' : {files greater than n bytes}
                  GetLongInt(MinSize);

                'H' : {show hidden files}
                  begin
                    SetAttrFlag(Hidden);
                    AcptAttr := AcptAttr or SysFile;
                  end;

                'L' : {files less than n bytes}
                  GetLongInt(MaxSize);

                'M' : {files newer than n days}
                  if Length(Arg) = 2 then
                    MaxAge := 0
                  else
                    GetLongInt(MaxAge);

                'N' : {name only format}
                  if Length(Arg) = 2 then
                    DispMode := dmNameOnly
                  else
                    UnknownArg;

                'R' : {recursive search}
                  if Length(Arg) = 2 then
                    Recursive := True
                  else
                    UnknownArg;

                'S' : {show subdirectories}
                  SetAttrFlag(Directory);

                'T' : {show totals}
                  if Length(Arg) = 2 then
                    Totals := True
                  else if (Length(Arg) = 3) and (Upcase(Arg[3]) = 'O') then
                    DispMode := dmTotalsOnly
                  else
                    UnknownArg;

                'V' : {avoid mask}
                  begin
                    if Length(Arg) = 2 then begin
                      Inc(Index);
                      Arg := LFNParamStr(Index);
                    end else
                      Arg := Copy(Arg, 3, 255);
                    InsertMatchNode(Arg, True);
                  end;

                'W' : {whole path format}
                  if Length(Arg) = 2 then
                    DispMode := dmPathOnly
                  else
                    UnknownArg;

                '?' : {help screen}
                  WriteHelp;
              else
                UnknownArg;
              end;
        else
          InsertMatchNode(Arg, False);
        end;

      Inc(Index);
    end;

    if not MatchSpecified then
      InsertMatchNode('*.*', False);

    if StartDir = '' then
      UpdateStartDir('*.*');

    if DispMode = dmTotalsOnly then begin
      {no point in sorting in this case; use the fastest mode}
      SortMode := smDos;
      SortDown := False;
    end;
  end;

  {---------------------------------------------------}

  procedure TDosWildMatcher.Init(const AMask : string);
  var
    MPos : Word;
    OLen : Word;
  begin
    Mask := AMask;
    MPos := 1;
    OLen := 0;
    for MPos := 1 to Length(Mask) do
      if (MPos = 1) or (Mask[MPos] <> '*') or (Mask[MPos-1] <> '*') then begin
        inc(OLen);
        Mask[OLen] := LoCase(Mask[MPos]);
      end;
    Mask[0] := Char(OLen);
    Mask[OLen+1] := EndChar;
  end;

  function TDosWildMatcher.Matches(Name : string) : Boolean;
  var
    MPos : Word;
    NPos : Word;
    MPSave : Word;
    NPSave : Word;
    AnyOn : Boolean;
    Ch : Char;
  begin
    Matches := False;

    {add implied extension}
    if Pos('.', Name) = 0 then begin
      inc(Name[0]);
      Name[Length(Name)] := '.';
    end;

    {add terminator to input string}
    Name[Length(Name)+1] := EndChar;

    AnyOn := False;
    MPos := 1;
    NPos := 1;

    while (Mask[MPos] <> EndChar) or (Name[NPos] <> EndChar) do begin
      {look for '*'}
      if Mask[MPos] = AnyChar then begin
        if MPos >= Length(Mask) then begin
          {last character in Mask is '*', rest must match}
          Matches := True;
          Exit;
        end;
        AnyOn := True;
        NPSave := NPos;
        inc(MPos);
        MPSave := MPos;
      end;

      {Get next character from Name string}
      Ch := LoCase(Name[NPos]);

      {Look for literal match}
      if (Ch <> EndChar) and ((Mask[MPos] = OneChar) or (Mask[MPos] = Ch))
      then begin
        {Matching character}
        inc(MPos);
        inc(NPos);
      end else begin
        {Mismatched character}
        if not AnyOn or (NPSave >= Length(Name)) then
          {Fatal mismatch, no '*' in effect or no way to advance past mismatch}
          Exit;
        {Increment restart point}
        inc(NPSave);
        {Try again at next Name position}
        NPos := NPSave;
        {Restart Mask just after the '*'}
        MPos := MPSave;
      end;
    end;

    Matches := True;
  end;

begin
  SFL.InitFromCommandLine;
  SFL.Build;
  SFL.Display;
end.
