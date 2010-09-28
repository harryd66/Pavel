procedure GetDate(var Year, Month, Day, DayOfWeek: Word);
var
  Regs: TRegisters;
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
(*
procedure GetDate(var Year, Month, Day, DayOfWeek: Word); assembler;
asm
	MOV	AH,2AH
	INT	21H
	XOR	AH,AH
	LES	DI,DayOfWeek
	STOSW
	MOV	AL,DL
	LES	DI,Day
	STOSW
	MOV	AL,DH
	LES	DI,Month
	STOSW
	XCHG	AX,CX
	LES	DI,Year
	STOSW
end;
*)

procedure GetTime(var Hour, Minute, Second, Sec100: Word);
var
  Regs: TRegisters;
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
(*
procedure GetTime(var Hour, Minute, Second, Sec100: Word); assembler;
asm
	MOV	AH,2CH
	INT	21H
	XOR	AH,AH
	MOV	AL,DL
	LES	DI,Sec100
	STOSW
	MOV	AL,DH
	LES	DI,Second
	STOSW
	MOV	AL,CL
	LES	DI,Minute
	STOSW
	MOV	AL,CH
	LES	DI,Hour
	STOSW
end;
*)
