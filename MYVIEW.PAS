{************************************************}
{                                                }
{   Turbo Vision File Manager Demo               }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

unit MyView;

{$F+,O+,X+,S-}

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
    SwapName: PString;
    IsValid: Boolean;
    Max : LongInt;
    CurX,CurY,FindY,FindX:LongInt;
    Finding : Boolean;
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar;
      const AFileName: PathStr);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Draw;Virtual;
    procedure ReadFile(const FName: PathStr);
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure Store(var S: TStream);
    function Valid(Command: Word): Boolean; virtual;
    Function GetSwapLine(Pos : LongInt):String;
    Procedure HandleEvent(Var Event:TEvent);Virtual;
    Procedure FindText;
    Procedure SetSelect;
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


implementation

uses Memory, MsgBox, Protect, App, Glob, Printers, Dialogs, ServStr, Serv;

Var FindStr : String[CSertif];
    Current : LongInt;

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
{  AHScrollBar^.Show;}
  Finding:=False;
  FindX:=0;
  FindY:=0;
  CurX:=0;
  CurY:=0;
end;

constructor TFileViewer.Load(var S: TStream);
var
  FName: PathStr;
begin
  TScroller.Load(S);
  FileName := S.ReadStr;
  FName := FileName^;
  ReadFile(FName);
  FindX:=0;
  FindY:=0;
  CurX:=0;
  CurY:=0;
end;

destructor TFileViewer.Done;
begin
  DisposeStr(FileName);
  DisposeStr(SwapName);
  TScroller.Done;
end;

Function TFileViewer.GetSwapLine(Pos : LongInt):String;
Var SwapFile: File Of String;
    s : String;
    R : LongInt;
    i : Byte;
    k : Word;
Begin
GetSwapLine[0]:=#0;
Assign(SwapFile,SwapName^);
i:=IOResult;
Reset(SwapFile);
i:=IOResult;
If i<>0 Then
 Begin
  MessageBox(^M+#3+'Ошибка доступа к файлу '+SwapName^+'!',Nil,mfError+mfCancelButton);
  Exit;
 End;
R:=FileSize(SwapFile);

If (Pos>FileSize(SwapFile)-1) Or (Pos<0) Then Seek(SwapFile,FileSize(SwapFile)-1)
Else
    Seek(SwapFile,Pos);
Read(SwapFile,s);
Close(SwapFile);



If SeparatorChar<>' ' Then
 Begin
  k:=System.Pos(SeparatorChar,s);
  While k>0 Do            {├┼┤}
   Begin                  {└┴┘}
    System.Delete(s,k,1);
    System.Insert(' ',s,k);
    k:=System.Pos(SeparatorChar,s);       {уничтожаем заголовок}
   End;
 End;


GetSwapLine:=s;

If R<>Max Then Max:=R;
Limit.Y:=Max;
inherited SetLimit(Limit.X, Limit.Y);

Pos:=IOResult;
End;



procedure TFileViewer.Draw;
var
  B: TDrawBuffer;
  C: Byte;
  I: Integer;
  ws,S: String;

begin
  C := GetColor(1);{!!!}{17,38,3a,31}

  Dec(Size.Y,2);

  for I := 0 to Size.Y-1  do
  begin
    MoveChar(B, ' ', C, Size.X);

    if Delta.Y + I < Max then
    begin
       s:=GetSwapLine(Delta.Y + I);
       S := Copy(s, Delta.X + 1, Size.X);
    end
    Else
     Begin
     s[0]:=#0;
     End;
     MoveStr(B, S, C);

    WriteLine(0, I, Size.X, 1, B);{!!!}

(*   If ((Delta.Y + I-1)=FindNumber) And (Finding) Then
     Begin
     Finding:=False;
     C := GetColor(3);
     MoveChar(B, ' ', C, Ord(FindStr[0]));
     s:=FindStr;
     MoveStr(B, S, C);
     WriteLine(FindSymb-1, FindNumber+1{(VScrollBar^.Value)}, Ord(FindStr[0]), 1, B);
     c:=GetColor(1);
     End;*)

  end;

  Inc(Size.Y,2);
  CurX:=Delta.X;
  CurY:=Delta.Y;

    c:=GetColor(3);

    s[0]:=#0;
    While (Ord(s[0])<Limit.X) Or (Ord(s[0])<(MaxViewWidth-1)) Do
    Insert(#205,s,1);
    S := Copy(s, Delta.X + 1, Size.X);
    MoveStr(B, S, C);
    WriteLine(0, Size.Y-2, Size.X, 1, B);{!!!}

    c:=GetColor(2);

    s[0]:=#0;

 {   If DelTa.Y+I>Max Then Max:=DelTa.Y+I+1;}
{
    S := s+'   Строка: ';
    Str(DelTa.Y+I+1:5,ws);
    s := s+ws;

}

    S := s+' Поиск: ';
    If FindStr[0]<>#0 Then
     Begin ws := s+FindStr;
           Format(ws,43);
           s:=ws;
     End
    Else s:=s+'                                  ';

    If Ord(s[0])>43 Then Begin
                          s[0]:=#40;
                          s:=s+'...';
                         End;



    S := s+'  Всего строк: ';
    Str(Max:5,ws);
    s:=s+ws;

    STr((Max div MaxLine[NPrint.Printer]):2,ws);
    If Abs(Frac(Max/MaxLine[NPrint.Printer]))>0 Then Str(StrToInt(ws)+1:2,ws);
    {If StrToInt(ws)=0 Then ws:=' 1';}
    s:=s+'/'+ws;
{    Str(Size.X+CurX,ws);
    s := s+' ('+ws+':';
    Str(Size.Y-2+CurY,ws);
    s := s+ws+')';}

    If Max<>0 Then
    Begin
    S := s+'  (';
    Str((DelTa.Y+I+1)/(Max)*100:6:2,ws);
    If StrToReal(ws)>100 Then Str(1000/10:6:2,ws);
    End
    Else
    Str(1000/10:6:2,ws);

    s := s+ws+'%)';

    ServStr.Format(s,Size.X);

    MoveStr(B, S, C);
    WriteLine(0, Size.Y-1, Size.X , 1, B);{!!!}

end;



procedure TFileViewer.ReadFile(const FName: PathStr);
var
  FileToView: Text;
  SName : String;
  SwapFile: File Of String;
  Line: String;
  MaxWidth: Integer;
  E: TEvent;
  i : Word;
begin
  IsValid := True;
  if FileName <> nil then DisposeStr(FileName);
  FileName := NewStr(FName);
  If Pos('.',FName)>0 Then  SName:=Copy(FName,1,Pos('.',FName)-1);
  While Pos('\',SNAme)>0 Do System.Delete(SNAme,1,Pos('\',SNAme));
  SNAme:=Path.ToTemp+SName+'.swp';
  if SwapName <> nil then DisposeStr(SwapName);
  SwapName := NewStr(SName);

  AInfo('Читаю отчет...');

  Assign(SwapFile,SNAme);
  Rewrite(SwapFile);

  MaxWidth := 0;

  Assign(FileToView, FName);
  Reset(FileToView);
  Max:=-1;
    while not Eof(FileToView)  And (Max<32700) do
    begin
      Readln(FileToView, Line);
      Inc(Max);
      Write(SwapFile,Line);
     if Length(Line) > MaxWidth then MaxWidth := Length(Line);
    end;

  Close(FileToView);
  Close(SwapFile);

  Limit.X := MaxWidth{MaxViewWidth-1};
  Limit.Y := Max;
  NoInfo;
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


Function FindDialog:Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  C : Word;
  Event : TEvent;
begin
FindDialog:=False;

R.Assign(0, 19, 25, 22);
New(Dlg, Init(R, 'Поиск'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Flags := Dlg^.Flags and not(wfMove or wfClose);
Dlg^.HelpCtx:=$E002;

R.Assign(1, 1, 24, 2);
Control := New(PInputLine, Init(R, CSertif{SizeOf(String)}));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetData(FindStr);


 Event.What:=EvKeyDown;
 Event.KeyCode:=kbEnd;
 Application^.PutEvent(Event);

c:=Desktop^.ExecView(Dlg);

If c<>cmCAncel Then
 Begin
  Dlg^.GetData(FindStr);
  While Pos(#247,FindStr)>0 Do
   System.Delete(FindStr,Pos(#247,FindStr),1);
  DelSpaceRight(FindStr);
  If FindStr[0]<>#0 Then
   Begin
    FindDialog:=True;
   End;

 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;


Procedure TFileViewer.HandleEvent(Var Event:TEvent);
VAr Cange : Boolean;
Begin
Case Event.What Of
 EvKeyDown : Begin
       Case Event.KeyCode Of
       40..175,224..239 : Begin
                           FindStr[0]:=#0;
                           FindStr:=FindStr+Event.CharCode;
                           Event.What:=EvCommand;
                           Event.Command:=cmFind;
                           PutEvent(Event);
                           ClearEvent(Event);
                          End;
      kbAltRusD : Begin
                           Event.What:=EvCommand;
                           Event.Command:=cmNextFind;
                           PutEvent(Event);
                           ClearEvent(Event);

              End;
       Else;
       End;

             End;
 EvCommand:Begin
            Case Event.Command Of
            cmScrollBarChanged :
                  Begin
             FindX:=0;
            End;

            Else;
            End;
           End;

Else;
End;


 Inherited HandleEvent(Event);

Case Event.What Of
 EvCommand:Begin
            Case Event.Command Of
            cmFind :
                  Begin
               If FindDialog Then
                Begin
                 FindX:=0;
                 FindText;
                End
                Else
                Begin
              {DrawFlag:=True;
               Draw;
               DrawFlag:=False;}
                End;
               ClearEvent(Event);
            End;
            cmNextFind :
                  Begin
              FindText;
              ClearEvent(Event);
            End;


            Else;
            End;
           End;

Else;
End;
End;


function Maximum(A, B: Integer): Integer;
inline(
   $58/     {pop   ax   }
   $5B/     {pop   bx   }
   $3B/$C3/ {cmp   ax,bx}
   $7F/$01/ {jg    @@1  }
   $93);    {xchg  ax,bx}



Procedure TFIleViewer.FindText;
Var j,r,i : LongInt;
    s : String;
    LockFind : Boolean;
Begin
{
     DrawFlag:=True;
     Draw;
     DrawFlag:=False;
}
Finding:=False;
LockFind:=False;
DInfoMsg('Идет поиск...');
r:=CurY;
If r<Max Then
For i:=r To Max-1 Do
 Begin
   s:=GetSwapLine(i);
   s:=Upcases(s);
   If i=CurY Then
   j:=Maximum(CurX,FindX)
   Else j:=0;
   s:=Copy(s,j+1,Ord(s[0]));
   If (Pos(FindStr,s)>0) Then
    Begin
     FindX:=Pos(FindStr,s)+j;
     {Inc(i,3);}
     FindY:=i;
     LockFind:=True;
     Finding:=True;
     DrawFlag:=True;
     If Size.X>FindX Then
     TScroller.ScrollTo(0, i)
     Else
     TScroller.ScrollTo(FindX, i);
     Draw;
     DrawFlag:=False;
     SetSelect;
     Break;
    End;
 End;{For}
NoInfoMsg;
If Not(LockFind) Then
Begin
 MessageBox(#3'Искомая строка:'^M+
            #3+'"'+FindStr+'"'^M+
                  #3+'не найдена!',Nil,mfInformation+mfCancelButton);
 {Draw;}
End
End;

(*
Procedure TFIleViewer.FindText;
Label 1;
Var r,i : LongInt;
    s : String;
    LockFind : Boolean;
Begin
Finding:=False;
LockFind:=False;
DInfoMsg('Идет поиск...');
 r:=DelTa.Y;
 If r=0 Then r:=-1;
 If r<Max Then
 For i:=r{+1} To Max Do
  Begin
   If i<>FindNumber Then FindSymb:=0;
   s:=GetSwapLine(i);
   s:=Upcases(s);

   If (Pos(FindStr,s)>0) Then
   Begin
1:
   R:=Maximum(Delta.X + 1,FindSymb);
   If (Pos(FindStr,s)>R) Then
    Begin
     FindSymb:=Pos(FindStr,s);
     LockFind:=True;
     {
     If (i+1)<Max Then
     DelTa.Y:=I;}
{     Else     DelTa.Y:=I;}
     FindNumber:=i;
     Finding:=True;

     {DrawFlag:=True;}

     If Size.X>FindSymb Then
     TScroller.ScrollTo(0, i)
     Else
     TScroller.ScrollTo(FindSymb, i);
     {Draw;}
     Break;
    End
    Else
    Begin
     Delete(S,1,Pos(FindStr,s));
     Goto 1;
    End;
    End;
  End;
NoInfoMsg;
If Not(LockFind) Then
Begin
 MessageBox(#3'Искомая строка:'^M+
            #3+'"'+FindStr+'"'^M+
                  #3+'не найдена!',Nil,mfError+mfCancelButton);
 Draw;
End
Else Begin
      SetSelect;
{         Str(i:3,s);
         MessageBox(#3'Искомая строка:'^M+
            #3+'"'+s+'"'^M+
                  #3+' найдена!',Nil,mfError+mfCancelButton);}
     End;

End;




*)


Procedure TFIleViewer.SetSelect;
var
  B: TDrawBuffer;
  C: Byte;
  I: Integer;
  ws,S: String;

begin
  C:=GetColor(1);
  Dec(Size.Y,2);
  for I := 0 to Size.Y-1  do
  begin
    If ((Delta.Y + I)=FindY) And (Finding) Then
     Begin
     Finding:=False;
     C := GetColor(4);
     MoveChar(B, ' ', C, Ord(FindStr[0]));
     s:=FindStr;
     MoveStr(B, S, C);
     WriteLine(FindX-1-Delta.X, FindY-Delta.Y{(VScrollBar^.Value)}, Ord(FindStr[0]), 1, B);
     c:=GetColor(1);
     End;
  end;
  Inc(Size.Y,2);
  CurX:=Delta.X;
  CurY:=Delta.Y;

end;




{ TTextWindow }

function TTextWindow.GetTitle(I:Integer):TTitleStr;
Begin
{ GetTitle:='Пpосмотp отчета';}
 GetTitle:='Отчет';
End;


constructor TTextWindow.Init(R: TRect; const FileName: PathStr;Reg:Boolean);
begin
  inherited Init(R, Filename, wnNoNumber);
  Palette := wpCyanWindow;
  If Reg Then  HelpCtx := $F001
  Else HelpCtx := $F004;
  {wpBlueWindow │ 0     │ Window text is yellow on blue
wpCyanWindow │ 1     │ Window text is blue on cyan
wpGrayWindow │ 2     │ Window text is black on gray

  }
  Options := Options or ofTileable;
  GetExtent(R);
  R.Grow(-1, -1);
  Insert(New(PFileViewer, Init(R,
    StandardScrollBar(sbIndiCator+sbHorizontal + sbHandleKeyboard),
    StandardScrollBar(sbIndiCator+sbVertical + sbHandleKeyboard), Filename)));
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
                   Report(F,'',1,False,False,false);
                   ClearEvent(Event);
                  End;
            Else;
            End;


           End;
Else;
End;
inherited HandleEvent(Event);
End;

BeGin
FindStr[0]:=#0;
end.
