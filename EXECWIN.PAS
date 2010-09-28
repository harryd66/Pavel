{$O+,F+,S-}
unit ExecWin;
interface
uses Objects, Drivers, Views;

type
  PExecTerminal = ^TExecTerminal;
  TExecTerminal = object(TView)
    Bufer: PByteArray;
    BufSize: Word;
    Cur: TPoint;
    constructor Init(var Bounds: TRect);
    destructor Done; virtual;
    function GetPalette: PPalette; virtual;
    procedure Draw; virtual;
    procedure PutChar(C: Char);
    procedure ExecPrg(Path, CmdLine: string);
  end;

procedure RegisterExecWin;

const
  RTerminal: TStreamRec = (
     ObjType: 1016;
     VmtLink: Ofs(TypeOf(TExecTerminal)^);
     Load:    @TExecTerminal.Load;
     Store:   @TExecTerminal.Store
  );

implementation
uses Dos, Memory,Serv;

{TExecTerminal ============================================================}
constructor TExecTerminal.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  Options := ofSelectable;
  GrowMode := gfGrowHiX + gfGrowHiY;
  BufSize:=ScreenWidth*ScreenHeight;
  Bufer := MemAlloc(BufSize);
  FillChar(Bufer^, BufSize, ' ');
  ShowCursor;
end;

destructor TExecTerminal.Done;
begin
  if Bufer <> nil then FreeMem(Bufer, BufSize);
  inherited Done;
end;

function TExecTerminal.GetPalette: PPalette;
const
  P: String[1] = #2;
begin
  GetPalette := @P
end;

procedure TExecTerminal.Draw;
var
  X,Y: Integer;
begin
 for Y := 0 to Size.Y-1 do
  for X := 0 to Size.X-1 do
    WriteChar(X, Y, Char(Bufer^[Y*ScreenWidth+X]), 1, 1);
end;

procedure TExecTerminal.PutChar(C: Char);
  procedure NewLine;
  begin
    Inc(Cur.Y);
    if Cur.Y >= Size.Y then
    begin
      Move(Bufer^[ScreenWidth], Bufer^[0], ScreenWidth*(ScreenHeight-1));
      FillChar(Bufer^[ScreenWidth*(ScreenHeight-2)], ScreenWidth, ' ');
      Cur.Y := Size.Y-1;
      DrawView;
    end;
  end;
begin
 case C of
  #$07: ;
  #$08: Dec(Cur.X);
  #$09: Inc(Cur.X, 8);
  #$0A: NewLine;
  #$0D: Cur.X:=0;
   else
    begin
     WriteChar(Cur.X, Cur.Y, C, 1, 1);
     Bufer^[Cur.Y*ScreenWidth+Cur.X] := Byte(C);
     Inc(Cur.X);
    end;
 end;
 SetCursor(Cur.X,Cur.Y);
end;

procedure Save10h; assembler;
asm
        NOP;    NOP;    NOP
end;

const
 ET: PExecTerminal = nil;

procedure Int10h; assembler;
asm
        CMP     AH,0Eh
        JE      @@TryOut
        JMP     @@Poll
@@TryOut:
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI
        PUSH    DS
        PUSH    ES
        PUSH    BP        {Save All Registers}

        MOV     SI,Seg @DATA
        MOV     DS,SI

        LES     DI,ET
        PUSH    AX
        PUSH    ES
        PUSH    DI
        CALL    TExecTerminal.PutChar

        POP     BP         {Restore All Registers}
        POP     ES
        POP     DS
        POP     DI
        POP     SI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        IRET
@@Poll:
        JMP     DWORD PTR CS:Save10h
end;

procedure TExecTerminal.ExecPrg(Path, CmdLine: string);
var
 OldInt10h: Pointer;
begin
  ET:=@Self;
  DoneDosMem;
  GetIntVec($10, OldInt10h);
  asm
        LES     AX, OldInt10h
        MOV     CS:Save10h.Word[0],AX
        MOV     CS:Save10h.Word[2],ES
  end;
  SetIntVec($10, @Int10h);
  MemCC;
  Exec(GetEnv('COMSPEC'),'/C '+Path+' '+CmdLine);
  SetIntVec($10, OldInt10h);
  InitDosMem;
end;

procedure RegisterExecWin;
begin
 RegisterType(RTerminal);
end;

end.


