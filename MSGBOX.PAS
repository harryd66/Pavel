
{*******************************************************}
{                                                       }
{       Turbo Pascal Version 7.0                        }
{       Turbo Vision Unit                               }
{                                                       }
{       Copyright (c) 1992 Borland International        }
{                                                       }
{*******************************************************}



unit MsgBox;

{$X+,I-,S-}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

interface

uses Objects;

const

{ Message box classes }

  mfWarning      = $0000;       { Display a Warning box }
  mfError        = $0001;       { Dispaly a Error box }
  mfInformation  = $0002;       { Display an Information Box }
  mfConfirmation = $0003;       { Display a Confirmation Box }
  mfFatalError   = $0004;       { Display a FatalError Box }

  mfInsertInApp  = $0080;       { Insert message box into application }
                                { instead of the Desktop }

{ Message box button flags }

  mfYesButton    = $0100;       { Put a Yes button into the dialog }
  mfNoButton     = $0200;       { Put a No button into the dialog }
  mfOKButton     = $0400;       { Put an OK button into the dialog }
  mfCancelButton = $0800;       { Put a Cancel button into the dialog }

  mfYesNoCancel  = mfYesButton + mfNoButton + mfCancelButton;
                                { Standard Yes, No, Cancel dialog }
  mfOKCancel     = mfOKButton + mfCancelButton;
                                { Standard OK, Cancel dialog }

{ MessageBox displays the given string in a standard sized      }
{ dialog box. Before the dialog is displayed the Msg and Params }
{ are passed to FormatStr.  The resulting string is displayed   }
{ as a TStaticText view in the dialog.                          }

function MessageBox(const Msg: String; Params: Pointer;
  AOptions: Word): Word;

{ MessageBoxRec allows the specification of a TRect for the     }
{ message box to occupy.                                        }

function MessageBoxRect(var R: TRect; const Msg: String; Params: Pointer;
  AOptions: Word): Word;

{ InputBox displays a simple dialog that allows the user to     }
{ type in a string.                                             }

function InputBox(const Title, ALabel: String; var S: String;
  Limit: Byte): Word;

{ InputBoxRect is like InputBox but allows the specification of }
{ a rectangle.                                                  }

function InputBoxRect(var Bounds: TRect; const Title, ALabel: String;
  var S: String;  Limit: Byte): Word;

Procedure Beep;
Procedure SpecialBeep;
Procedure NetBeep;

implementation

uses Glob,Drivers, Views, Dialogs, App, ServStr,ColorTxt;


Procedure Beep;
Begin
{$IfDEF Sound}
Sound(300);
Delay(50);
NoSound;
{$EndIf}
End;

Procedure SpecialBeep;
Var i : Integer;
    j : Integer;
Begin
{$IfDEF Sound}
{
For i:=1 To 3 Do
Begin
Sound(2050);
Delay(100);
NoSound;
Delay(200);
End;}
Sound(250);
Delay(150);
Sound(450);
Delay(200);
Sound(250);
Delay(200);
NoSound;

{$EndIf}
End;

Procedure NetBeep;
Var i : Integer;
    j : Integer;
Begin
{$IfDEF Sound}

For i:=1 To 3 Do
Begin
Sound(2050);
Delay(100);
NoSound;
Delay(200);
End;
{$EndIf}
End;


function MessageBox(const Msg: String; Params: Pointer;
  AOptions: Word): Word;
var
  R: TRect;
begin
  R.Assign(0, 0, 45, 8);
  if AOptions and mfInsertInApp = 0 then
    R.Move((Desktop^.Size.X - R.B.X) div 2, (Desktop^.Size.Y - R.B.Y) div 2)
  else R.Move((Application^.Size.X - R.B.X) div 2, (Application^.Size.Y - R.B.Y) div 2);
  MessageBox := MessageBoxRect(R, Msg, Params, AOptions);
end;

function MessageBoxRect(var R: TRect; const Msg: String; Params: Pointer;
  AOptions: Word): Word;
const
  ButtonName: array[0..3] of string[6] =
    ('Да', 'Нет', 'Ввод', 'Отмена');
  Commands: array[0..3] of word =
    (cmYes, cmNo, cmOK, cmCancel);
  Titles: array[0..4] of string[14] =
    ('Внимание','Ошибка','Информация','Подтверждение','Аварийное завершение');
  Hint: array[0..3] of string[16] =
    ('','Esc Нет','Ctrl+'+#17+#217+' Ok`key','Esc Отмена');
var
  I, X, ButtonCount: Integer;
  Dialog: PDialog;
  Control: PView;
  ButtonList: array[0..4] of PView;
  S: String;
  Event : TEvent;
begin
  Dialog := New(PDialog,
  Init(R, Titles[AOptions and $3]));
{  If (AOptions and $3)=1 Then Dialog^.Palette:=dpGrayDialog1; изменение цвета окна при ошибке}
  If (AOptions and $0400) <> 0 Then   Dialog^.HelpCtx:=$E083
  Else
  If (AOptions and $0100) <> 0 Then Dialog^.HelpCtx:=$E562
  Else
  Dialog^.HelpCtx:=$E090;
  If (AOptions and $0004) <> 0 Then
    Dialog^.Palette:=wpCyanWindow;

  with Dialog^ do
  begin
    R.Assign(2, 2, Size.X - 2, Size.Y - 1);
    FormatStr(S, Msg, Params^);
    Control := New(PStaticText, Init(R, S));
    Insert(Control);
    X := -2;
    ButtonCount := 0;
    s[0]:=#0;
    for I := 0 to 3 do
      if AOptions and ($0100 shl I) <> 0 then
      begin
        R.Assign(0, 0, 10, 2);
 {      Control := New(PButton, Init(R, ButtonName[I], Commands[i],
        bfNormal));}
        s:=s+'  '+Hint[i];
{       Inc(X, Control^.Size.X + 2);
        ButtonList[ButtonCount] := Control;}
        Inc(ButtonCount);
      end;
    X := (Size.X - X) shr 1;
    for I := 0 to ButtonCount - 1 do
    begin
{     Control := ButtonList[I];
      Insert(Control);
      Control^.MoveTo(X, Size.Y - 3);
      Inc(X, Control^.Size.X + 2);}
    end;
{   R.Assign((Size.X-Ord(s[0]))Div 2, Size.Y-1, ((Size.X-Ord(s[0]))Div 2)+Ord(s[0])+1, Size.Y);
    Control^.Options := Control^.Options or ofCenterX;
    Control := New(PColoredText, Init(R, #3+s,$74));  {7e yeloww}
{   Control := New(PColoredText, Init(R, #3'Esc Отмена Ctrl '+#17+#217+' Ввод',$4F));}
{    Insert(Control);}
    If (AOptions and mfError)<>0 Then    Beep;
    If (AOptions and mfFatalError)<>0 Then    SpecialBeep;
    SelectNext(False);
  end;


  if AOptions and mfInsertInApp = 0 then
    MessageBoxRect := DeskTop^.ExecView(Dialog)
  else MessageBoxRect := Application^.ExecView(Dialog);
  Dispose(Dialog, Done);
end;

function InputBox(const Title, ALabel: String; var S: String;
  Limit: Byte): Word;
var
  R: TRect;
begin
  R.Assign(0, 0, 60, 8);
  R.Move((Desktop^.Size.X - R.B.X) div 2, (Desktop^.Size.Y - R.B.Y) div 2);
  InputBox := InputBoxRect(R, Title, ALabel, S, Limit);
end;

function InputBoxRect(var Bounds: TRect; const Title, ALabel: String;
  var S: String;  Limit: Byte): Word;
var
  Dialog: PDialog;
  Control: PView;
  R: TRect;
  C: Word;
begin
  Dialog := New(PDialog, Init(Bounds, Title));
  with Dialog^ do
  begin
    R.Assign(4 + CStrLen(ALabel), 2, Size.X - 3, 3);
    Control := New(PInputLine, Init(R, Limit));
    Insert(Control);
    R.Assign(2, 2, 3 + CStrLen(ALabel), 3);
    Insert(New(PLabel, Init(R, ALabel, Control)));
    R.Assign(Size.X - 24, Size.Y - 4, Size.X - 14, Size.Y - 2);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    Inc(R.A.X, 12); Inc(R.B.X, 12);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
    Inc(R.A.X, 12); Inc(R.B.X, 12);
    SelectNext(False);
  end;
  Dialog^.SetData(S);
  C := DeskTop^.ExecView(Dialog);
  if C <> cmCancel then Dialog^.GetData(S);
  Dispose(Dialog, Done);
  InputBoxRect := C;
end;

end.