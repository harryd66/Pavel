{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit ViewText;

{$F+,O+,X+,S-,D-}

interface

uses Objects, Views, Dos,Drivers{,Glob};

type

  { TLineCollection }

  PLineCollection = ^TLineCollection;
  TLineCollection = object(TCollection)
    procedure FreeItem(P: Pointer); virtual;
  end;

  { TFileViewer }

  PFileViewer = ^TFileViewer;
  TFileViewer = object(TScroller)
    FileName: PString;
    FileLines: PCollection;
    IsValid: Boolean;
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar;
      const AFileName: PathStr);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Draw;Virtual;
    procedure ReadFile(const FName: PathStr);
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure Store(var S: TStream);
    function Valid(Command: Word): Boolean; virtual;
  end;

(*
  MyFileViewer = ^TMyFileViewer;
  TMyFileViewer = object(TFileViewer)
    MyFileName: PString;
    ShapkaFileLines: PCollection;
    constructor Init(var Bounds,MyBounds: TRect; AHScrollBar, AVScrollBar: PScrollBar;
      const AFileName: PathStr);
    procedure Draw;Virtual;
    procedure ReadFile(const FName: PathStr);
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure Store(var S: TStream);
    function Valid(Command: Word): Boolean; virtual;
  end;
*)
  { TTextWindow }

  PTextWindow = ^TTextWindow;
  TTextWindow = object(TWindow)
    constructor Init(R: TRect; const FileName: PathStr;Reg:Boolean);
    function GetTitle(I:Integer):TTitleStr;virtual;
    procedure HandleEvent(Var Event : TEvent);virtual;
  end;

{Var Test : Byte;}

implementation

uses Memory, MsgBox, App, Glob, Printers;

{ TLineCollection }
procedure TLineCollection.FreeItem(P: Pointer);
begin
  DisposeStr(P);
end;

{ TFileViewer }
constructor TFileViewer.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PScrollBar; const AFileName: PathStr);
begin
  TScroller.Init(Bounds, AHScrollbar, AVScrollBar);{!!!}
  GrowMode := gfGrowHiX + gfGrowHiY;
  FileName := nil;

  ReadFile(AFileName);
end;

constructor TFileViewer.Load(var S: TStream);
var
  FName: PathStr;
begin
  TScroller.Load(S);
  FileName := S.ReadStr;
  FName := FileName^;
  ReadFile(FName);
end;

destructor TFileViewer.Done;
begin
  Dispose(FileLines, Done);
  DisposeStr(FileName);
  TScroller.Done;
end;

procedure TFileViewer.Draw;
var
  B: TDrawBuffer;
  C: Byte;
  I: Integer;
  S: String;
  P: PString;
begin
  C := GetColor(1);{!!!}{17,38,3a,31}
  for I := 0 to Size.Y - 1 do
  begin
    MoveChar(B, ' ', C, Size.X);
    if Delta.Y + I < FileLines^.Count then{!!!}
    begin
      P := FileLines^.At(Delta.Y + I);
      if P <> nil then S := Copy(P^, Delta.X + 1, Size.X)
      else S := '';
      MoveStr(B, S, C);
    end;
    WriteLine(0, I, Size.X, 1, B);{!!!}
  end;
end;

procedure TFileViewer.ReadFile(const FName: PathStr);
var
  FileToView: Text;
  Line: String;
  MaxWidth: Integer;
  E: TEvent;
begin
  IsValid := True;
  if FileName <> nil then DisposeStr(FileName);
  FileName := NewStr(FName);
  FileLines := New(PLineCollection, Init(5,5));
    MaxWidth := 0;
  Assign(FileToView, FName);
  Reset(FileToView);
    while not Eof(FileToView) and not LowMemory do
    begin
      Readln(FileToView, Line);
      if Length(Line) > MaxWidth then MaxWidth := Length(Line);
      FileLines^.Insert(NewStr(Line));
    end;
    Close(FileToView);
  Limit.X := MaxWidth;
  Limit.Y := FileLines^.Count;
end;

procedure TFileViewer.SetState(AState: Word; Enable: Boolean);
begin
  TScroller.SetState(AState, Enable);
  if Enable and (AState and sfExposed <> 0) then
     SetLimit(Limit.X, Limit.Y);
end;

procedure TFileViewer.Store(var S: TStream);
begin
  TScroller.Store(S);
  S.WriteStr(FileName);
end;

function TFileViewer.Valid(Command: Word): Boolean;
begin
  Valid := IsValid;
end;

{ TTextWindow }

function TTextWindow.GetTitle(I:Integer):TTitleStr;
Begin
{ GetTitle:='èpÆ·¨Æ‚p Æ‚Á•‚†';}
 GetTitle:='é‚Á•‚';
End;


constructor TTextWindow.Init(R: TRect; const FileName: PathStr;Reg:Boolean);
begin
  inherited Init(R, Filename, wnNoNumber);
  Palette := wpCyanWindow;
  If Reg Then  HelpCtx := $F001
  Else HelpCtx := $F004;
  {wpBlueWindow ≥ 0     ≥ Window text is yellow on blue
wpCyanWindow ≥ 1     ≥ Window text is blue on cyan
wpGrayWindow ≥ 2     ≥ Window text is black on gray

  }
  Options := Options or ofTileable;
  GetExtent(R);
  R.Grow(-1, -1);
  Insert(New(PFileViewer, Init(R,
    StandardScrollBar(sbHorizontal + sbHandleKeyboard),
    StandardScrollBar(sbVertical + sbHandleKeyboard), Filename)));
end;

Procedure TTextWindow.HandleEvent(Var Event:TEvent);
VAr f : TTitleStr;
Begin

Case Event.What Of
 EvCommand:Begin
            Case Event.Command Of
            cmPrintScreen :
		  Begin
               f:=inherited GetTitle(SizeOf(TTitleStr));
      	     Report(F,'',1,False,False);
               ClearEvent(Event);
            End;
            Else;
            End;



           End;
Else;
End;
inherited HandleEvent(Event);
End;

end.
