{*
*
*   Copyright (c) 1992,93 by Richard W. Hansen
*
*
*}
UNIT TvType;
{$B+}
{$X+}
{$V-}

{$I TVDEFS.INC}

INTERFACE

USES
  Dos,
  Objects;


CONST
  DateSlash : Char = '-';


CONST
  BaseYear  : Word = 1900;


TYPE
  TbxFrameArray = Array[1..8] of Char;


  PbxCharArray  = ^TbxCharArray;
  TbxCharArray  = Array[0..$FFE0] of Char;


  PbxByteArray  = ^TbxByteArray;
  TbxByteArray  = Array[0..$FFE0] of Byte;


  TbxCharSet    = Set of Char;
  TbxByteSet    = Set of Byte;


  TbxLong    = record
    Low, High : Word;
  end;


  { Record passed between two TbxPairedListBox objects }
  PbxItemRec = ^TbxItemRec;
  TbxItemRec = record
    Owner,Item : Pointer;
  end;


  { DATE TYPES }

  TbxDateSt   = String[12]; {"mm/dd/yyyy", etc.}


  { Record for TbxDate GetData and SetData }
  TbxDateRec  = record
    Day   : Byte;
    Month : Byte;
    Year  : Word;
  end;


  PbxDate = ^TbxDate;
  TbxDate = Object(TObject)
    Day   : Byte;
    Month : Byte;
    Year  : Word;

    Constructor Init(D : Byte; M : Byte; Y : Word);
    Constructor Load(var S : TStream);
    Function    Compare(var ADate : PbxDate): Integer;
    Function    DateString(Picture : TbxDateSt): TbxDateSt;
    Function    DaysInMonth: Word;
    Procedure   ExtractDate(Picture : TbxDateSt;
                            ADateSt : TbxDateSt);
    Procedure   GetData(var Rec);
    Function    GetDay: Byte;
    Function    GetMonth: Byte;
    Function    GetYear: Word;
    Function    LeapYear: Boolean;
    Procedure   SetData(var Rec);
    Procedure   SetDay(D : Byte);
    Procedure   SetMonth(M : Byte);
    Constructor SetToday;
    Procedure   SetYear(Y : Word);
    Procedure   Store(var S : TStream);
    Function    Valid: Boolean; Virtual;
    private
    Function    FourDigitYear(Y : Word): Word;
  end;


CONST
  MonthString : Array[1..12] of string[9] =
    (
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь'
    );

CONST
  DayString : Array[1..7] of string[11] =
    (
    'Воскресенье',
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота'
    );


Function IsLeapYear(Year : Word): Boolean;

Function DaysInMonth(Date : TbxDateRec): Word;

Function CompareDate(Date1 : TbxDateRec;
                     Date2 : TbxDateRec): Integer;

Function DateToDateStr(Date    : TbxDateRec;
                          Picture : TbxDateSt): TbxDateSt;

Procedure ExtractDateFromString(var Date    : TbxDateRec;
                                    Picture : TbxDateSt;
                                    ADateSt : TbxDateSt);


{ TvType registration procedure }

Procedure RegisterTVType;


{ Stream Registration Records }

CONST
  RbxDate: TStreamRec = (
    ObjType : 5050;
    VmtLink : Ofs(TypeOf(TbxDate)^);
    Load    : @TbxDate.Load;
    Store   : @TbxDate.Store
  );

implementation

function IsLeapYear(Year: Word): Boolean;
begin
  IsLeapYear := (Year mod 4 = 0) and (Year mod 4000 <> 0)
    and ((Year mod 100 <> 0) or (Year mod 400 = 0))
end;

function DaysInMonth(Date: TbxDateRec): Word;
begin
  case Date.Month of
    1, 3, 5, 7, 8, 10, 12:
      DaysInMonth := 31;
    2:
      if IsLeapYear(Date.Year) then DaysInMonth := 29 else DaysInMonth := 28;
    4, 6, 9, 11:
      DaysInMonth := 30;
  else DaysInMonth := 0
  end
end;

function CompareDate(Date1: TbxDateRec; Date2: TbxDateRec): Integer;
begin
  if (Date1.Year < Date2.Year) then CompareDate := -1
  else if (Date1.Year > Date2.Year) then CompareDate := 1
  else if (Date1.Month < Date2.Month) then CompareDate := -1
  else if (Date1.Month > Date2.Month) then CompareDate := 1
  else if (Date1.Day < Date2.Day) then CompareDate := -1
  else if (Date1.Day > Date2.Day) then CompareDate := 1
  else CompareDate := 0
end;

function DateToDateStr(Date: TbxDateRec; Picture: TbxDateSt): TbxDateSt;

procedure DateToString(C: Char; K: Word; var Picture: string);
var
  I, J: Byte;
  S: string[4];
begin
  I := Pos(C, Picture);
  C := UpCase(C);
  if (I = 0) then
  begin
    I := Pos(C, Picture);
    if (I = 0) then Exit
  end;
  while (I < Length(Picture)) and (UpCase(Picture[I+1]) = C) do Inc(I);
  Str(K: 4, S);
  J := 4;
  while (I > 0) and (UpCase(Picture[I]) = C) do
  begin
    if (J > 0) and (S[J] <> ' ') then
    begin
      Picture[I] := S[J];
      Dec(J)
    end else if (Picture[I] < 'a') then
    begin
      Picture[I] := ' '
    end else
    begin
      Picture[I] := '0'
    end;
    Dec(I)
  end
end;

var
  I: Byte;
begin
  DateToString('d', Date.Day, Picture);
  DateToString('m', Date.Month, Picture);
  DateToString('y', Date.Year, Picture);
  for I := 1 to Length(Picture) do
    if Picture[I] = '-' then Picture[I] := DateSlash;
  DateToDateStr := Picture
end;

procedure ExtractDateFromString(var Date: TbxDateRec; Picture: TbxDateSt;
  ADateSt: TbxDateSt);

procedure DateFromString(C: Char; var Picture: string; var ADateSt: string;
  var K: Word);
var
  I, J: Integer;
  S1: TbxDateSt;
  Code: Word;
begin
  K := 0;
  I := Pos(C, Picture);
  C := UpCase(C);
  J := Pos(C, Picture);
  if (I = 0) or ((J <> 0) and (J < I)) then I := J;
  if (I = 0) then Exit;
  J := 0;
  while (UpCase(Picture[I]) = C) and (I <= Length(ADateSt)) do
  begin
    if ADateSt[I] <> ' ' then
    begin
      Inc(J);
      S1[J] := ADateSt[I];
    end;
    Inc(I);
  end;
  Byte(S1[0]) := J;
  Val(S1, K, Code);
  if (Code <> 0) then K := 0
end;

var
  D, M, Y: Word;
begin
  DateFromString('m', Picture, ADateSt, M);
  DateFromString('d', Picture, ADateSt, D);
  DateFromString('y', Picture, ADateSt, Y);
  Date.Day := D;
  Date.Month := M;
  Date.Year := Y
end;

constructor TbxDate.Init(D: Byte; M: Byte; Y: Word);
begin
  inherited Init;
  Day := D;
  Month := M;
  Year := Y
end;

constructor TbxDate.Load(var S: TStream);
begin
  S.Write(Day, SizeOf(Byte)); { BUG!!! }
  S.Write(Month, SizeOf(Byte));
  S.Write(Year, SizeOf(Word))
end;

function TbxDate.Compare(var ADate: PbxDate): Integer;
var
  D1: TbxDateRec;
  D2: TbxDateRec;
begin
  D1.Day := Day;
  D1.Month := Month;
  D1.Year := Year;
  D2.Day := ADate^.Day;
  D2.Month := ADate^.Month;
  D2.Year := ADate^.Year;
  Compare := CompareDate(D1, D2)
end;

function TbxDate.DateString(Picture: TbxDateSt): TbxDateSt;
var
  D: TbxDateRec;
begin
  D.Day := Day;
  D.Month := Month;
  D.Year := Year;
  DateString := DateToDateStr(D, Picture)
end;

function TbxDate.DaysInMonth: Word;
var
  D: TbxDateRec;
begin
  D.Day := Day;
  D.Month := Month;
  D.Year := FourDigitYear(Year);
  DaysInMonth := TvType.DaysInMonth(D)
end;

procedure TbxDate.ExtractDate(Picture: TbxDateSt; ADateSt: TbxDateSt);
var
  D: TbxDateRec;
begin
  ExtractDateFromString(D, Picture, ADateSt);
  Day := D.Day;
  Month := D.Month;
  Year := D.Year
end;

function TbxDate.FourDigitYear(Y: Word): Word;
begin
  if (Y < 100) then FourDigitYear := Y + BaseYear else FourDigitYear := Y
end;

PROCEDURE TBXDate.GetData(VAR Rec);
BEGIN
  TbxDateRec(Rec).Year := Year;
  TbxDateRec(Rec).Month := Month;
  TbxDateRec(Rec).Day := Day
END;

function TbxDate.GetDay: Byte;
begin
  GetDay := Day
end;

function TbxDate.GetMonth: Byte;
begin
  GetMonth := Month
end;

function TbxDate.GetYear: Word;
begin
  GetYear := Year
end;

function TbxDate.LeapYear: Boolean;
begin
  LeapYear := IsLeapYear(Year)
end;

procedure TbxDate.SetData(var Rec);
begin
  Year := TbxDateRec(Rec).Year;
  Month := TbxDateRec(Rec).Month;
  Day := TbxDateRec(Rec).Day
end;

procedure TbxDate.SetDay(D: Byte);
begin
  Day := D
end;

procedure TbxDate.SetMonth(M: Byte);
begin
  Month := M
end;

constructor TbxDate.SetToday;
var
  D, M, Y, DayOfWeek: Word;
begin
  inherited Init;
  Dos.GetDate(Y, M, D, DayOfWeek);
  Day := D;
  Month := M;
  Year := Y
end;

procedure TbxDate.SetYear(Y: Word);
begin
  Year := Y
end;

procedure TbxDate.Store(var S: TStream);
begin
  S.Read(Day, SizeOf(Byte)); { BUG!!! }
  S.Read(Month, SizeOf(Byte));
  S.Read(Year, SizeOf(Word))
end;

function TbxDate.Valid: Boolean;
begin
  Valid := (Day <> 0) and (Day <= DaysInMonth)
end;

procedure RegisterTvType;
begin
  RegisterType(RbxDate)
end;

end.
