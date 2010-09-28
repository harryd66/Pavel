{$X+}

{ Unit X_Dialog                                                 }
{   Extended Dialog Boxes                                       }
{                                                               }
{ Donn Aiken, 71150,2011                                        }
{ May 17, 1991                                                  }

{ Small example program to show how to create what functions as }
{ a dialog box that scrolls.                                    }
{ Look at TMyListBox object to see how it's done.               }
{                                                               }
{ Based somewhat upon the ListBox example without a scrollbar   }
{ by Mike Savage, 71121,3137.                                   }
{                                                               }


{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}



unit x_dialog;

interface

uses Objects, Views, Dialogs, Drivers;

const
  TBoxMaxSize = 30;

type
  PStringO = ^TStringO;
  TStringO = object (TObject)
    Item : PString;
    constructor Init (s : string);
    destructor  Done; virtual;
  end;


  PBoxData   = ^TBoxData;
  TBoxData   = object (TObject)
    PList : PCollection;
    Sel   : array [0..TBoxMaxSize-1] of boolean;
    constructor init;
    procedure   clear;  virtual;
    function    empty : boolean; virtual;
  end;


  PMyListBox = ^TMyListBox;
  TMyListBox = object(TBox)
    ReadOnly  : Boolean;
    Selected  : array [0..TBoxMaxSize-1] of boolean;
    CheckChar : Char;

    constructor Init     (var Bounds      : TRect;
                              CChar       : Char;
                              Cols        : Byte;
                              AVScrollBar : PScrollBar;RO:Boolean);

    destructor Done; virtual;

    function  DataSize : Word; virtual;
    procedure GetData     (var Rec); virtual;
    procedure HandleEvent (var Event: TEvent); virtual;
    procedure SetData     (var Rec); virtual;
    function  GetText     (Item: Integer; MaxLen: Integer): String; virtual;
    function  GetText1    (Item: Integer; MaxLen: Integer): String;
    procedure SelectItem  (item : integer); virtual;
  end;


implementation

Uses Utils,Servstr, Serv;

constructor TStringO.Init (S : String);
begin
  TObject.Init;
  Item := NewStr(S);
end;

destructor TStringO.Done;
begin
  DisposeStr (Item);
  TObject.Done;
end;


constructor TBoxData.Init;
var
  i : integer;
begin
  TObject.Init;
  PList := Nil;
  TBoxData.Clear;
end;

procedure TBoxData.Clear;

var
  i : integer;

begin
  for i := 0 to TBoxMaxSize-1 do Sel[i] := False;
end;

function TBoxData.Empty : boolean;

var
  i : integer;
  b : boolean;

begin
  b := true;
  for i := 0 to TBoxMaxSize-1 do
  if (sel[i]) then b := false;
  Empty := b;
end;

{ TMyListBox }

constructor TMyListBox.Init (var  Bounds : TRect;
                                   CChar : Char;
                                   Cols  : Byte;
                             AVScrollBar : PScrollBar;RO:Boolean);
var
  i   : Word;
  R   : TRect;
  mw,
  ml  : Word;

begin
  TListBox.Init (Bounds, Cols, AVScrollBar);
  CheckChar := CChar;
  ReadOnly :=RO;
  GrowMode  := gfGrowHiX or gfGrowHiY;
  for i := 0 to TBoxMaxSize-1 do
    Selected[i] := false;
end;

destructor TMyListBox.Done;

begin
  TListBox.Done;
end;

function  TMyListBox.DataSize: Word;

begin
  DataSize := Sizeof({TBoxData}LongInt);
end;

procedure TMyListBox.GetData (var Rec);
Var c,l : LongInt;
    MMM : Maska30;
begin

  {l:=LongInt(Rec);}
  For c:=1 To Max30 Do
  Begin
   MMM[c]:=0;
   If Selected[c-1] Then MMM[c]:=1;{установка значений из списка}
  End;
  BitToWord30(MMM,L);
  Move(L, Rec, sizeof(LongInt));

  {
  PBoxData(Rec)^.PList := List;
  Move(Selected, PBoxData(Rec)^.Sel, sizeof(Selected));
  }
end;

procedure TMyListBox.HandleEvent (var Event: TEvent);

var
  p : TPoint;
  r : TRect;
  current_column : byte;
  i : byte;

begin

  If Not ReadOnly Then
  if (Event.What = evMouseDown)  then
    begin
      GetBounds (R);
      MakeLocal(Event.Where, P);
      current_column := P.X * NumCols div Size.X;
      If Not ReadOnly Then
      if (P.Y + Current_Column * Size.Y = Focused - TopItem) then
        begin
          selected[Focused] := not(Selected[Focused]);
          drawview;
          ClearEvent (Event);
        end
    end;

  If Not ReadOnly Then TListBox.HandleEvent (Event);
  Drawview;
end;


procedure TMyListBox.SetData (var Rec);
Var c,l : LongInt;
    MMM : Maska30;
    VV : Array [0..29] Of Boolean;
begin
  l:=LongInt(Rec);
  WordToBit30(l,MMM);
  For c:=1 To Max30 Do
  Begin
   Selected[c-1]:=False;
   Selected[c-1]:=(MMM[c]=1);{установка значений в список}
  End;

  {
  TListBox.NewList(PBoxData(Rec)^.PList);
  }

end;


function  TMyListBox.GetText (Item: Integer; MaxLen: Integer): String;

var
  s : string;

begin
    GetText := '';
  if (List = Nil) then
    GetText := ''
  else
    begin
      If (Item < List^.Count) Then
     Begin
      s := Copy (PStringO(List^.At(Item))^.Item^, 1, MaxLen-5);
      if (Selected[Item]) then
        GetText := '[' + CheckChar + '] ' + s
      else
        GetText := '[ ] ' + s;
     End;
    end;
end;

function  TMyListBox.GetText1 (Item: Integer; MaxLen: Integer): String;

var
  s : string;

begin
    GetText1 := '';
  if (List = Nil) then
    GetText1 := ''
  else
    begin
      If (Item < List^.Count) Then
      Begin
      s := PStringO(List^.At(Item))^.Item^;
      GetText1 := s;
      End;
    end;
end;


procedure TMyListBox.SelectItem(Item : integer);

begin
  if (List <> nil) Then
  Begin
  TListBox.SelectItem(Item);
  Selected[item] := not(Selected[item]);
  Drawview;
  End;
end;

end.