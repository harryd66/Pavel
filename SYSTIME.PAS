Unit SysTime;


Interface

Const MrkSeek=0;
      PrhSeek=1;
      DocSeek=2;
      VksSeek=3;
      RetSeek=4;
      OplSeek=5;
      PrzSeek=6;
      RwzSeek=7;
      IntSeek=8;
      ZakSeek=9;


procedure GetTime(var Hour, Minute, Second, Sec100: Word);
procedure GetDate(var Year, Month, Day, DayOfWeek: Word);

Implementation

Uses Dos,FileTool;

procedure GetTime(var Hour, Minute, Second, Sec100: Word);
var
  Regs: Registers;
begin
  with Regs do begin
    AH := $2C;
    MsDos(Regs);
    Hour   := CH;
    Minute := CL;
    Second := DH;
    Sec100 := DL;
  end;
end;





procedure GetDate(var Year, Month, Day, DayOfWeek: Word);
var
  Regs: Registers;
begin
  with Regs do begin
    AH := $2A;
    MsDos(Regs);
    Year      := CX;
    Month     := DH;
    Day       := DL;
    DayOfWeek := AL;
  end;
end;


End.