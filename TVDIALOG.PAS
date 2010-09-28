{*
*
*   Copyright (c) 1992,93 by Richard W. Hansen
*
*
*}
{$F+,O+}
UNIT TvDialog;
{$B+}
{$X+}
{$V-}

{$I TVDEFS.INC}

INTERFACE


USES
  Dos,
  TvObject, TvConst, TvString, TvType,
  {$IFDEF USE_NEW_FILE_DIALOG}
  StdDlg,
  {$ENDIF}
  App, Dialogs, Drivers, Memory, MsgBox, Objects, Views;


CONST
  BarChar       : Char = '±';
  BarFillChar   : Char = 'Û';


CONST
  Buttons       : Array[0..3] of String[8] =
                    ('~Y~es', '~N~o', 'O~K~', '~C~ancel');
  Commands      : Array[0..3] of Word =
                    (cmYes, cmNo, cmOK, cmCancel);
  Titles        : Array[0..3] of String[11] =
                    ('Warning', 'Error', 'Information', 'Confirm');


CONST
  mfMessageLine  = $1000;
  mfPauseButton  = $2000;
  mfPauseCancel  = mfPauseButton + mfCancelButton;
  mfOKPauseCancel= mfOKCancel + mfPauseButton;


CONST
  vlCurrent = $0001;
  vlPrev    = $0002;
  vlNext    = $0003;
  vlMin     = $0004;
  vlMax     = $0005;
  vlListMax = $0006;
  vlListMin = $0007;


{$IFDEF USE_NEW_FILE_DIALOG}
TYPE
  PSearchRec = ^TSearchRec;   {why isn't this public in StdDlg?}
  DriveLetters  = 'A'..'Z';
  DriveSet      = Set of DriveLetters;
{$ENDIF}

TYPE
  PbxRunDialog  = ^TbxRunDialog;
  TbxRunDialog  = Object(TDialog)
    Msg     : PStaticText;
    RunState: Word;
    pfFlags : Word;
    BtnRow  : Byte;
    SButton : PButton;
    CButton : PButton;

    Constructor Init(var Bounds   : TRect;
                         ATitle   : TTitleStr;
                         AMessage : String;
                         AOptions : Word;
                         ButtonRow: Byte);
    Constructor Load(var S: TStream);
    Procedure   ChangeMessage(AMessage : String);
    Function    Execute: Word;                            Virtual;
    Procedure   HandleEvent(var Event : TEvent);          Virtual;
    Procedure   Process;                                  Virtual;
    Procedure   Store(var S: TStream);
  end;


  PbxPercentDialog  = ^TbxPercentDialog;
  TbxPercentDialog  = Object(TbxRunDialog)
    Total   : LongInt;
    Count   : LongInt;
    Step    : Word;
    Pct     : PStaticText;
    Bar     : PStaticText;

    Constructor Init(ATitle   : TTitleStr;
		     AMessage : String;
                     ATotal   : LongInt;
                     AOptions : Word
                    );
    Constructor Load(var S: TStream);
    Procedure   Increment;
    Procedure   IncrementBy(AStep : Word);
    Procedure   Store(var S: TStream);
  end;


  PbxPrintDialog  = ^TbxPrintDialog;
  TbxPrintDialog  = Object(TbxRunDialog)
    Constructor Init(ATitle   : TTitleStr;
                     AMessage : String;
                     AOptions : Word
                    );
  end;


  PbxLinkedLine = ^TbxLinkedLine;
  TbxLinkedLine = Object(TInputLine)
    LinkEvent : Word;

    Constructor Init(var Bounds : TRect;
                         AMaxLen: Integer;
			 EventCode : Word);
    Constructor Load(var S: TStream);
    Procedure   HandleEvent(var Event : TEvent);          Virtual;
    Procedure   Store(var S: TStream);
  end;


  PbxLinkedBox  = ^TbxLinkedBox;
  TbxLinkedBox  = Object(TListBox)
    LinkEvent : Word;

    Constructor Init(var Bounds     : TRect;
                         ANumCols   : Word;
			 AScrollBar : PScrollBar;
                         EventCode  : Word);
    Constructor Load(var S: TStream);
    Procedure   FocusItem(Item : Integer);                Virtual;
    Procedure   Store(var S: TStream);
  end;


  PbxMessageDialog  = ^TbxMessageDialog;
  TbxMessageDialog  = Object(TDialog)
    SList   : TbxUnsortedStringCollection;
    DOptions: Word;

    Constructor Init(AOptions : Word);
    Procedure   AddMessage(St : String);
    Function    Execute: Word;                            Virtual;
  end;


  PbxListBox  = ^TbxListBox;
  TbxListBox  = Object(TListbox)
    Function  GetText(Item  : Integer;
                      MaxLen: Integer): String;           Virtual;
  end;


  PbxCheckListBox = ^TbxCheckListBox;
  TbxCheckListBox = Object(TbxListBox)
    Procedure GetSelectSet(var ASet : TbxByteSet);
    Function  GetText(Item  : Integer;
                      MaxLen: Integer): String;           Virtual;
    Procedure HandleEvent(var Event: TEvent);             Virtual;
    Function  IsSelected(Item : Integer): Boolean;        Virtual;
    Procedure SelectItem(Item : Integer);                 Virtual;
    Procedure SetSelectSet(ASet : TbxByteSet);
  end;


  PbxPairedListBox  = ^TbxPairedListBox;
  TbxPairedListBox  = Object(TbxListBox)
    Procedure SelectItem(Item : Integer);                 Virtual;
    Procedure HandleEvent(var Event : TEvent);            Virtual;
  end;


  PbxPairedStrListBox  = ^TbxPairedStrListBox;
  TbxPairedStrListBox  = Object(TbxPairedListBox)
    Function  GetText(Item  : Integer;
                      MaxLen: Integer): String;           Virtual;
  end;


  PbxVListBox  = ^TbxVListBox;
  TbxVListBox  = Object(TListBox)
    AtMin : Boolean;
    AtMax : Boolean;

    Constructor Init(Bounds     : TRect;
                     ANumCols   : Word;
                     AHScrollBar: PScrollBar;
                     AVScrollBar: PScrollBar);
    Constructor Load(var S: TStream);
    Function    FillByPage(GoForward : Boolean): Integer; Virtual;
    Function    FillFrom(FromTop : Boolean): Integer;     Virtual;
    Procedure   FocusItem(Item : Integer);                Virtual;
    Function    GetItem(ACommand : Word): PObject;        Virtual;
    Procedure   HandleEvent(var Event : TEvent);          Virtual;
    Function    Lookup(P : PObject): Boolean;             Virtual;
    Function    MatchItem(P : PObject): Boolean;          Virtual;
    Procedure   NewList(AList: PCollection);              Virtual;
    Function    PageSize : Integer;                       Virtual;
    Procedure   SetCommandState(Enable : Boolean);
  end;


  {$IFDEF USE_NEW_FILE_DIALOG}
  PbxFileCollection = ^TbxFileCollection;
  TbxFileCollection = object(TFileCollection)
    Function Compare(Key1, Key2: Pointer): Integer;       Virtual;
  end;


  PbxFileList = ^TbxFileList;
  TbxFileList = object(TFileList)
    Constructor Init(var Bounds     : TRect;
                         AWildCard  : PathStr;
                         AScrollBar : PScrollBar);

    Procedure   HandleEvent(var Event: TEvent);           Virtual;
    Procedure   FocusItem(Item: Integer);                 Virtual;

    { **************************************************
      NOTE: The following method must be made virtual in
      the TFileList object in the file STDDLG.PAS unit.
      At line # 101 add a "virtual" declaration.
      ************************************************** }
    Procedure   ReadDirectory(AWildCard : PathStr);       Virtual;
  end;


  PbxDriveList = ^TbxDriveList;
  TbxDriveList = object(TbxFileList)
    Constructor Init(var Bounds     : TRect;
                         AScrollBar : PScrollBar);
    Procedure   GetDrives(var Drives : DriveSet);
    Procedure   ReadDirectory(AWildCard : PathStr);       Virtual;
    Function    GetKey(var S : String): Pointer;          Virtual;
  end;


  PbxFileInputLine = ^TbxFileInputLine;
  TbxFileInputLine = object(TFileInputLine)
    Procedure HandleEvent(var Event : TEvent);            Virtual;
  end;


  PbxFileInfoPane = ^TbxFileInfoPane;
  TbxFileInfoPane = object(TFileInfoPane)
    Procedure   Draw;                                     Virtual;
  end;


  PBXDirectoryInfoPane = ^TBXDirectoryInfoPane;
  TbxDirectoryInfoPane = object(TView)
    Constructor Init(var Bounds: TRect);
    Function    GetPalette: PPalette;                     Virtual;
    Procedure   HandleEvent(var Event: TEvent);           Virtual;
    Procedure   Draw;                                     Virtual;
  end;


  PBXFileDialog = ^TBXFileDialog;
  TBXFileDialog = object(TFileDialog)
    DriveList : PbxDriveList;

    Constructor Init(AWildCard  : TWildStr;
                     ATitle     : String;
                     InputName  : String;
                     AOptions   : Word;
                     HistoryId  : Byte);

    { **************************************************
      NOTE: In TFileDialog in the unit STDDLG.PAS the
      method ReadDirectory must be made PUBLIC.
      At line # 152 remove the "private" declaration.
      ************************************************** }
  end;
  {$ENDIF}


{ TvDialog registration procedure }

Procedure RegisterTVDialog;


{ Stream Registration Records }

CONST
  RbxRunDialog: TStreamRec = (
    ObjType : 5050;
    VmtLink : Ofs(TypeOf(TbxRunDialog)^);
    Load    : @TbxRunDialog.Load;
    Store   : @TbxRunDialog.Store
  );


CONST
  RbxPercentDialog: TStreamRec = (
    ObjType : 5051;
    VmtLink : Ofs(TypeOf(TbxPercentDialog)^);
    Load    : @TbxPercentDialog.Load;
    Store   : @TbxPercentDialog.Store
  );


CONST
  RbxPrintDialog: TStreamRec = (
    ObjType : 5052;
    VmtLink : Ofs(TypeOf(TbxPrintDialog)^);
    Load    : @TbxPrintDialog.Load;
    Store   : @TbxPrintDialog.Store
  );


CONST
  RbxLinkedLine: TStreamRec = (
    ObjType : 5053;
    VmtLink : Ofs(TypeOf(TbxLinkedLine)^);
    Load    : @TbxLinkedLine.Load;
    Store   : @TbxLinkedLine.Store
  );


CONST
  RbxLinkedBox: TStreamRec = (
    ObjType : 5054;
    VmtLink : Ofs(TypeOf(TbxLinkedBox)^);
    Load    : @TbxLinkedBox.Load;
    Store   : @TbxLinkedBox.Store
  );


CONST
  RbxListBox: TStreamRec = (
    ObjType : 5055;
    VmtLink : Ofs(TypeOf(TbxListBox)^);
    Load    : @TbxListBox.Load;
    Store   : @TbxListBox.Store
  );


CONST
  RbxCheckListBox: TStreamRec = (
    ObjType : 5056;
    VmtLink : Ofs(TypeOf(TbxCheckListBox)^);
    Load    : @TbxCheckListBox.Load;
    Store   : @TbxCheckListBox.Store
  );


CONST
  RbxPairedListBox: TStreamRec = (
    ObjType : 5057;
    VmtLink : Ofs(TypeOf(TbxPairedListBox)^);
    Load    : @TbxPairedListBox.Load;
    Store   : @TbxPairedListBox.Store
  );

CONST
  RbxPairedStrListBox: TStreamRec = (
    ObjType : 5058;
    VmtLink : Ofs(TypeOf(TbxPairedstrListBox)^);
    Load    : @TbxPairedStrListBox.Load;
    Store   : @TbxPairedStrListBox.Store
  );

CONST
  RbxVListBox: TStreamRec = (
    ObjType : 5059;
    VmtLink : Ofs(TypeOf(TbxVListBox)^);
    Load    : @TbxVListBox.Load;
    Store   : @TbxVListBox.Store
  );

{$IFDEF USE_NEW_FILE_DIALOG}
CONST
  RbxFileCollection: TStreamRec = (
    ObjType : 5060;
    VmtLink : Ofs(TypeOf(TbxFileCollection)^);
    Load    : @TbxFileCollection.Load;
    Store   : @TbxFileCollection.Store
  );

CONST
  RbxFileList: TStreamRec = (
    ObjType : 5061;
    VmtLink : Ofs(TypeOf(TbxFileList)^);
    Load    : @TbxFileList.Load;
    Store   : @TbxFileList.Store
  );

CONST
  RbxDriveList: TStreamRec = (
    ObjType : 5062;
    VmtLink : Ofs(TypeOf(TbxDriveList)^);
    Load    : @TbxDriveList.Load;
    Store   : @TbxDriveList.Store
  );

CONST
  RbxFileInputLine: TStreamRec = (
    ObjType : 5063;
    VmtLink : Ofs(TypeOf(TbxFileInputLine)^);
    Load    : @TbxFileInputLine.Load;
    Store   : @TbxFileInputLine.Store
  );

CONST
  RbxFileInfoPane: TStreamRec = (
    ObjType : 5064;
    VmtLink : Ofs(TypeOf(TbxFileInfoPane)^);
    Load    : @TbxFileInfoPane.Load;
    Store   : @TbxFileInfoPane.Store
  );

CONST
  RbxDirectoryInfoPane: TStreamRec = (
    ObjType : 5065;
    VmtLink : Ofs(TypeOf(TbxDirectoryInfoPane)^);
    Load    : @TbxDirectoryInfoPane.Load;
    Store   : @TbxDirectoryInfoPane.Store
  );

CONST
  RbxFileDialog: TStreamRec = (
    ObjType : 5066;
    VmtLink : Ofs(TypeOf(TbxFileDialog)^);
    Load    : @TbxFileDialog.Load;
    Store   : @TbxFileDialog.Store
  );
{$ENDIF}

implementation

constructor TbxRunDialog.Init(var Bounds: TRect; ATitle: TTitleStr;
  AMessage: string; AOptions: Word; ButtonRow: Byte);
var
  R: TRect;
begin
  inherited Init(Bounds, ATitle);
  pfFlags := AOptions;
  Flags := Flags and not wfClose;
  BtnRow := ButtonRow;
  RunState := 0;
  if ((pfFlags and mfMessageLine) <> 0) then
  begin
    R.Assign(2, 1, 42, 2);
    Msg := New(PStaticText, Init(R, AMessage));
    Insert(Msg);
  end;
  if ((pfFlags and mfOkCancel) = mfOkCancel) then
  begin
    R.Assign(11, BtnRow, 20, BtnRow + 2);
    SButton := New(PButton, Init(R, 'Start', cmStartJob, bfDefault));
    Insert(SButton);
    R.Assign(24, BtnRow, 34, BtnRow + 2);
    CButton := New(PButton, Init(R, 'Cancel', cmCancelJob, bfNormal));
    Insert(CButton);
  end else if ((pfFlags and mfOkButton) <> 0) then
  begin
    R.Assign(17, BtnRow, 26, BtnRow + 2);
    SButton := New(PButton, Init(R, 'Start', cmStartJob, bfDefault));
    Insert(SButton);
    CButton := nil;
  end else if ((pfFlags and mfCancelButton) <> 0) then
  begin
    R.Assign(16, BtnRow, 26, BtnRow + 2);
    CButton := New(PButton, Init(R, 'Cancel', cmCancelJob, bfDefault));
    Insert(CButton);
    SButton := nil;
  end;
  SelectNext(False);
end;

constructor TbxRunDialog.Load(var S: TStream);
begin
  inherited Load(S);
  GetSubViewPtr(S, Msg);
  S.Read(RunState, SizeOf(Word));
  S.Read(pfFlags, SizeOf(Word));
  S.Read(BtnRow, SizeOf(Byte));
  GetSubViewPtr(S, SButton);
  GetSubViewPtr(S, CButton);
end;

procedure TbxRunDialog.ChangeMessage(AMessage: string);
begin
  if (Msg <> nil) then
  begin
    DisposeStr(Msg^.Text);
    Msg^.Text := NewStr(AMessage);
    Msg^.DrawView;
  end;
end;

function TbxRunDialog.Execute: Word;
var
  Event: TEvent;
begin
  if ((pfFlags and mfOkButton) = 0) then RunState := cmStartJob;
  repeat
    GetEvent(Event);
    HandleEvent(Event);
    Process;
  until (RunState > cmContinueJob);
  Execute := RunState;
end;

procedure TbxRunDialog.HandleEvent(var Event: TEvent);
var
  R: TRect;

procedure RemoveButton(Button: PButton);
begin
  if (Button <> nil) then
  begin
    Delete(Button);
    Dispose(Button, Done);
  end;
end;

begin
  TWindow.HandleEvent(Event);
  case Event.What of
    evKeyDown:
      case Event.KeyCode of
        kbEsc:
          begin
            Event.What := evCommand;
            Event.Command := cmCancelJob;
            Event.InfoPtr := nil;
            PutEvent(Event);
            ClearEvent(Event);
          end;
        kbEnter:
          begin
            Event.What := evBroadcast;
            Event.Command := cmDefault;
            Event.InfoPtr := nil;
            PutEvent(Event);
            ClearEvent(Event);
          end;
      end;
    evCommand:
      case Event.Command of
        cmCancelJob, cmJobComplete, cmPauseJob, cmContinueJob, cmStartJob:
          begin
            case Event.Command of
              cmContinueJob, cmStartJob:
                begin
                  Lock;
                  RemoveButton(SButton);
                  RemoveButton(CButton);
                  if ((pfFlags and mfPauseCancel) = mfPauseCancel) then
                  begin
                    R.Assign(11, BtnRow, 20, BtnRow + 2);
                    SButton := New(PButton, Init(
                      R, 'Pause', cmPauseJob, bfDefault));
                    SButton^.State := SButton^.State or sfActive;
                    Insert(SButton);
                    R.Assign(24, BtnRow, 34, BtnRow + 2);
                    CButton := New(PButton, Init(
                      R, 'Cancel',cmCancelJob, bfNormal));
                    Insert(CButton);
                    CButton^.State := CButton^.State or sfActive;
                  end else if ((pfFlags and mfPauseButton) <> 0) then
                  begin
                    R.Assign(17, BtnRow, 26, BtnRow + 2);
                    SButton := New(PButton, Init(
                      R, 'Pause', cmPauseJob, bfDefault));
                    Insert(SButton);
                    CButton := nil;
                    SButton^.State := SButton^.State or sfActive;
                  end else if ((pfFlags and mfCancelButton) <> 0) then
                  begin
                    R.Assign(16, BtnRow, 26, BtnRow + 2);
                    CButton := New(PButton, Init(
                      R, 'Cancel', cmCancelJob, bfDefault));
                    Insert(CButton);
                    SButton := nil;
                    CButton^.State := CButton^.State or sfActive;
                  end;
                  SelectNext(False);
                  DrawView;
                  Unlock;
                end;
              cmPauseJob:
                begin
                  Lock;
                  RemoveButton(SButton);
                  RemoveButton(CButton);
                  if ((pfFlags and mfPauseCancel) = mfPauseCancel) then
                  begin
                    R.Assign(10, BtnRow, 22, BtnRow + 2);
                    SButton := New(PButton, Init(
                      R, 'Continue', cmContinueJob, bfDefault));
                    Insert(SButton);
                    R.Assign(25, BtnRow, 35, BtnRow + 2);
                    CButton := New(PButton, Init(
                      R, 'Cancel', cmCancelJob, bfNormal));
                    Insert(CButton);
                    SButton^.State := SButton^.State or sfActive;
                    CButton^.State := CButton^.State or sfActive;
                  end else
                  begin
                    R.Assign(15, BtnRow, 27, BtnRow + 2);
                    SButton := New(PButton, Init(
                      R, 'Continue', cmContinueJob, bfDefault));
                    Insert(SButton);
                    CButton := nil;
                    SButton^.State := SButton^.State or sfActive;
                  end;
                  SelectNext(False);
                  DrawView;
                  Unlock;
                end;
            end;
            RunState := Event.Command;
            ClearEvent(Event);
          end;
      end;
  end;
end;

procedure TbxRunDialog.Process;
begin
end;

procedure TbxRunDialog.Store(var S: TStream);
begin
  inherited Store(S);
  PutSubViewPtr(S, Msg);
  S.Write(RunState, SizeOf(Word));
  S.Write(pfFlags, SizeOf(Word));
  S.Write(BtnRow, SizeOf(Byte));
  PutSubViewPtr(S, SButton);
  PutSubViewPtr(S, CButton);
end;

constructor TbxPercentDialog.Init(ATitle: TTitleStr; AMessage: string;
  ATotal: Longint; AOptions: Word);
var
  R: TRect;
begin
  R.Assign(0, 0, 44, 10);
  inherited Init(R, ATitle, AMessage, AOptions, 7);
  Options := Options or ofCentered;
  Total := ATotal;
  Step := Total div 25;
  if (Total mod 25 <> 0) then Inc(Step);
  R.Assign(9, 3, 36, 4);
  Insert(New(PStaticText, Init(R, 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿')));
  R.Assign(9, 4, 36, 5);
  Insert(New(PStaticText, Init(R, '³                         ³')));
  R.Assign(9, 5, 36, 6);
  Insert(New(PStaticText, Init(R, 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ')));
  R.Assign(20, 2, 25, 3);
  Pct := New(PStaticText, Init(R, '0%  '));
  Insert(Pct);
  R.Assign(10, 4, 35, 5);
  Bar := New(PStaticText, Init(R, Chars(25, BarChar)));
  Insert(Bar);
end;

constructor TbxPercentDialog.Load(var S: TStream);
var
  R: TRect;
begin
  inherited Load(S);
  S.Read(Total, SizeOf(Longint));
  S.Read(Count, SizeOf(Longint));
  S.Read(Step, SizeOf(Word));
  GetSubViewPtr(S, Pct);
  GetSubViewPtr(S, Bar);
  R.Assign(9, 3, 36, 4);
  Insert(New(PStaticText, Init(R, 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿')));
  R.Assign(9, 4, 36, 5);
  Insert(New(PStaticText, Init(R, '³                         ³')));
  R.Assign(9, 5, 36, 6);
  Insert(New(PStaticText, Init(R, 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ')));
end;

procedure TbxPercentDialog.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(Total, SizeOf(Longint));
  S.Write(Count, SizeOf(Longint));
  S.Write(Step, SizeOf(Word));
  PutSubViewPtr(S, Pct);
  PutSubViewPtr(S, Bar);
end;

procedure TbxPercentDialog.Increment;
begin
  IncrementBy(1);
end;

procedure TbxPercentDialog.IncrementBy(AStep: Word);
var
  Value: Real;
  N: Word;
  K: string[3];
begin
  if (Count < Total) then
  begin
    Count := Count + AStep;
    if (Count >= Total) then
    begin
      FillChar(Bar^.Text^[1], 25, BarFillChar);
      Bar^.DrawView;
      Pct^.Text^ := '100%';
      Pct^.DrawView;
    end else if ((Count mod Step) = 0) then
    begin
      Value := (Count / Total) * 100;
      N := Round(Value / 4);
      FillChar(Bar^.Text^[1], N, BarFillChar);
      Bar^.DrawView;
      Str(Value: 3: 0, K);
      Pct^.Text^ := K + '%';
      Pct^.DrawView;
    end;
  end;
end;

constructor TbxPrintDialog.Init(ATitle: TTitleStr; AMessage: string;
  AOptions: Word);
var
  R: TRect;
begin
  R.Assign(0, 0, 44, 7);
  inherited Init(R, ATitle, AMessage, AOptions, 4);
  Options := Options or ofCentered;
end;

constructor TbxLinkedBox.Init(var Bounds: TRect; ANumCols: Word;
  AScrollBar: PScrollBar; EventCode: Word);
begin
  inherited Init(Bounds, ANumCols, AScrollBar);
  LinkEvent := EventCode;
end;

constructor TbxLinkedBox.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(LinkEvent, SizeOf(Word));
end;

procedure TbxLinkedBox.FocusItem(Item: Integer);
begin
  inherited FocusItem(Item);
  Message(Owner, evBroadcast, LinkEvent, List^.At(Item));
end;

procedure TbxLinkedBox.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(LinkEvent, SizeOf(Word));
end;

constructor TbxLinkedLine.Init(var Bounds: TRect; AMaxLen: Integer;
  EventCode: Word);
begin
  inherited Init(Bounds, AMaxLen);
  LinkEvent := EventCode;
  EventMask := EventMask or evBroadcast;
end;

constructor TbxLinkedLine.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(LinkEvent, SizeOf(Word));
end;

procedure TbxLinkedLine.HandleEvent(var Event: TEvent);
var
  S: string;
begin
  inherited HandleEvent(Event);
  if (Event.What = evBroadcast) then
    if (Event.Command = LinkEvent) then
      if (State and sfSelected = 0) then
      begin
        SetData(PString(Event.InfoPtr)^);
        DrawView;
        ClearEvent(Event);
      end;
end;

procedure TbxLinkedLine.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(LinkEvent, SizeOf(Word));
end;

constructor TbxMessageDialog.Init(AOptions: Word);
var
  R: TRect;
begin
  R.Assign(0, 0, 4, 4);
  inherited Init(R, Titles[AOptions and $3]);
  DOptions := AOptions;
  SList.Init(15, 5);
end;

procedure TbxMessageDialog.AddMessage(St: string);
var
  P: PString;
begin
  GetMem(P, Length(St) + 1);
  if (P <> nil) then
  begin
    P^ := St;
    SList.Insert(P);
  end;
end;

function TbxMessageDialog.Execute: Word;
var
  P: Pointer;
  XX, YY: Byte;
  N, Y: Byte;
  I: Byte;
  BCount: Byte;
  Rest: Integer;
  Width: Integer;
  R: TRect;
begin
  Hide;
  Desktop^.GetExtent(R);
  N := 0;
  for I := 0 to SList.Count - 1 do
  begin
    P := SList.At(I);
    if (Byte(P^) > R.B.X) then Byte(P^) := R.B.X;
    if (Byte(P^) > N) then N := Byte(P^);
  end;
  BCount := 0;
  for I := 0 to 3 do if (DOptions and ($0100 shl I) <> 0) then Inc(BCount);
  if ((BCount * 11 + 1) > N) then N := BCount * 11 + 1;
  N := N + 2;
  Y := SList.Count + 2;
  if (ButtonCount > 0) then Y := Y + 3;
  if (Y > R.B.Y) then Y := R.B.Y;
  XX := (R.B.X - N) div 2;
  YY := (R.B.Y - Y) div 2;
  R.Assign(XX, YY, XX + N, YY + Y);
  ChangeBounds(R);
  if (BCount > 0) then
  begin
    Rest := Size.X - (BCount * 9);
    Width := Rest div (BCount + 1);
    N := Width + (Rest mod BCount) shr 1;
    for I := 0 to 3 do
      if (DOptions and ($0100 shl I) <> 0) then
      begin
        R.Assign(N, Size.Y - 3, N + 10, Size.Y - 1);
        Insert(New(PButton, Init(R, Buttons[I], Commands[I], bfNormal)));
        Inc(N, Width + 8);
      end;
    SelectNext(False);
  end;
  N := SList.Count;
  if (N > Y - 4) then N := Y - 4;
  for I := 0 to N - 1 do
  begin
    R.Assign(1, I + 1, Size.X - 1, I + 2);
    Insert(New(PStaticText, Init(R, PString(SList.At(I))^)));
  end;
  SList.Done;
  Show;
  Execute := inherited Execute;
end;

function TbxListBox.GetText(Item: Integer; MaxLen: Integer): string;
Var s : PString;
begin
  {GetText := PbxObject(List^.At(Item))^.GetText(MaxLen);}
  GetText := '';
  if (List <> nil) Then
  If (Item < List^.Count) Then
          begin
            {S := PString(List^.At(Item));
            if (S <> nil)
               then} GetText := {S^}PbxObject(List^.At(Item))^.GetText(MaxLen);;
          end;

end;

procedure TbxCheckListBox.GetSelectSet(var ASet: TbxByteSet);
var
  I: Byte;
  N: Integer;
begin
  if (List <> nil) Then
  Begin
  N := List^.Count - 1;
  if (N > 255) then N := 255;
  ASet := [];
  for I := 0 to N do
    if PbxSelectObject(List^.At(I))^.GetSelect then ASet := ASet + [I];
  End;
end;

function TbxCheckListBox.GetText(Item: Integer; MaxLen: Integer): string;
begin
  GetText := '';
  if (List <> nil) Then
  Begin
  If (Item < List^.Count) Then
  Begin
  if PbxSelectObject(List^.At(Item))^.GetSelect then
    GetText := '[X] ' + PbxSelectStr(List^.At(Item))^.GetText(MaxLen - 3) else
    GetText := '[ ] ' + PbxSelectStr(List^.At(Item))^.GetText(MaxLen - 3);
  End;
  End;
end;

procedure TbxCheckListBox.HandleEvent(var Event: TEvent);
var
  Mouse: TPoint;
  ColWidth: Word;
  NewItem: Integer;
begin
  if (Event.What = evMouseDown) then
  begin
    MakeLocal(Event.Where, Mouse);
    if MouseInView(Event.Where) then
    begin
      ColWidth := Size.X div NumCols + 1;
      NewItem := Mouse.Y + (Size.Y * (Mouse.X div ColWidth)) + TopItem;
      SelectItem(NewItem);
    end;
  end;
  inherited HandleEvent(Event);
end;

function TbxCheckListBox.IsSelected(Item: Integer): Boolean;
begin
  if (List <> nil) Then
  IsSelected := PbxSelectObject(List^.At(Item))^.GetSelect;
end;

procedure TbxCheckListBox.SelectItem(Item: Integer);
begin
  if (List <> nil) Then
  Begin
  PbxSelectObject(List^.At(Item))^.SetSelect(
    not PbxSelectObject(List^.At(Item))^.GetSelect);
  DrawView;
 End;
end;

procedure TbxCheckListBox.SetSelectSet(ASet: TbxByteSet);
var
  I: Byte;
  N: Integer;
begin
  if (List <> nil) Then
  Begin
  N := List^.Count - 1;
  if (N > 255) then N := 255;
  for I := 0 to N do PbxSelectObject(List^.At(I))^.SetSelect(I in ASet);
  End;
end;

procedure TbxPairedListBox.SelectItem(Item: Integer);
var
  P: PbxItemRec;
begin
  inherited SelectItem(Item);
  New(P);
  P^.Item := List^.At(Item);
  P^.Owner := @Self;
  List^.AtDelete(Item);
  SetRange(List^.Count);
  Message(Owner, evBroadcast, cmTakeItem, P);
  DrawView;
end;

procedure TbxPairedListBox.HandleEvent(var Event: TEvent);
var
  Mouse: TPoint;
  ColWidth: Word;
  Item: Integer;
begin
  case Event.What of
    evBroadcast:
      case Event.Command of
        cmTakeItem:
          if (PbxItemRec(Event.InfoPtr)^.Owner <> @Self) then
          begin
            List^.Insert(PbxItemRec(Event.InfoPtr)^.Item);
            SetRange(List^.Count);
            Dispose(PbxItemRec(Event.InfoPtr));
            ClearEvent(Event);
            DrawView;
          end;
      end;
    evMouseDown:
      begin
        MakeLocal(Event.Where, Mouse);
        if MouseInView(Event.Where) then
        begin
          ColWidth := Size.X div NumCols + 1;
          Item := Mouse.Y + (Size.Y * (Mouse.X div ColWidth)) + TopItem;
          if (Item < List^.Count) then
          begin
            if Event.Double then
            begin
              SelectItem(Item);
              ClearEvent(Event);
            end
          end else
          begin
            ClearEvent(Event);
          end;
        end;
      end;
  end;
  inherited HandleEvent(Event);
end;

function TbxPairedStrListBox.GetText(Item: Integer; MaxLen: Integer): string;
begin
  if (List <> nil) then
    GetText := FTruncateStr(PString(List^.At(Item))^, MaxLen) else
    GetText := '';
end;

constructor TbxVListBox.Init(Bounds: TRect; ANumCols: Word;
  AHScrollBar: PScrollBar; AVScrollBar: PScrollBar);
begin
  TListViewer.Init(Bounds, ANumCols, AHScrollBar, AVScrollBar);
  List := nil;
  SetRange(0);
  AtMin := False;
  AtMax := False;
  SetCommandState(False);
end;

constructor TbxVListBox.Load(var S: TStream);
begin
  inherited Load(S);
  AtMin := False;
  AtMax := False;
end;

function TbxVListBox.FillByPage(GoForward: Boolean): Integer;
var
  MaxItem: Integer;
  N, Discarded: Integer;
  NewItem: PObject;
  Code: Word;
begin
  FillByPage := 0;
  if (List^.Count > 0) then
  begin
    if GoForward then
    begin
      NewItem := GetItem(vlListMax);
      Code := vlNext;
      Discarded := 0;
    end else
    begin
      NewItem := GetItem(vlListMin);
      Code := vlPrev;
      Discarded := List^.Count - 1;
    end;
    Dispose(NewItem, Done);
    NewItem := GetItem(Code);
    MaxItem := PageSize;
    N := 0;
    while (NewItem <> nil) and (N < MaxItem) do
    begin
      if (List^.Count = List^.Limit) then List^.Free(List^.At(Discarded));
      if GoForward then List^.Insert(NewItem) else List^.AtInsert(0, NewItem);
      Inc(N);
      if (N < MaxItem) then NewItem := GetItem(Code);
    end;
    if GoForward then
    begin
      AtMax := (N < MaxItem);
      if AtMin then AtMin := (N = 0);
    end else
    begin
      AtMin := (N < MaxItem);
      if AtMax then AtMax := (N = 0);
    end;
    FillByPage := N;
    SetCommandState(True);
    Draw;
  end;
end;

function TbxVListBox.FillFrom(FromTop: Boolean): Integer;
var
  N: Integer;
  Code: Word;
  NewItem: PObject;
  OldLimit: Integer;
begin
  if FromTop then
  begin
    NewItem := GetItem(vlMin);
    Code := vlNext
  end else
  begin
    NewItem := GetItem(vlMax);
    Code := vlPrev;
  end;
  N := 0;
  OldLimit := List^.Limit;
  List^.FreeAll;
  while (NewItem <> nil) and (N < OldLimit) do
  begin
    if FromTop then List^.Insert(NewItem) else List^.AtInsert(0, NewItem);
    Inc(N);
    if (N < OldLimit) then NewItem := GetItem(Code);
  end;
  if FromTop then
  begin
    AtMin := True;
    AtMax := (N < OldLimit);
  end else
  begin
    AtMax := True;
    AtMin := (N < OldLimit);
  end;
  SetRange(List^.Count);
  SetCommandState(True);
  Draw;
  FillFrom := N;
end;

procedure TbxVListBox.FocusItem(Item: Integer);
begin
  inherited FocusItem(Item);
  Draw;
end;

function TbxVListBox.GetItem(ACommand: Word): PObject;
begin
  RunError(211);
end;

procedure TbxVListBox.HandleEvent(var Event: TEvent);
var
  Dummy: Word;
begin
  case Event.What of
    evBroadcast:
      begin
        case Event.Command of
          cmPrevPage:
            if not AtMin then FillByPage(False);
          cmNextPage:
            if not AtMax then FillByPage(True);
          cmFirstPage:
            if not AtMin then FillFrom(True);
          cmLastPage:
            if not AtMax then FillFrom(False);
        end;
      end;
  end;
  inherited HandleEvent(Event);
end;

function TbxVListBox.Lookup(P: PObject): Boolean;
var
  OldLimit: Integer;
begin
  Lookup := False;
  if (P <> nil) then
    if MatchItem(P) then
    begin
      OldLimit := List^.Limit;
      List^.FreeAll;
      while (P <> nil) and (List^.Count < List^.Limit) do
      begin
        List^.Insert(P);
        if (List^.Count < List^.Limit) then P := GetItem(vlNext);
      end;
      AtMax := (P = nil);
      AtMin := False;
      Lookup := True;
      SetRange(List^.Count);
      SetCommandState(True);
      FocusItem(0);
    end;
end;

function TbxVListBox.MatchItem(P: PObject): Boolean;
begin
  MatchItem := False;
end;

procedure TbxVListBox.NewList(AList: PCollection);
begin
  inherited NewList(AList);
  SetCommandState(True);
end;

function TbxVListBox.PageSize: Integer;
begin
  PageSize := List^.Limit div 3;
end;

procedure TbxVListBox.SetCommandState(Enable: Boolean);
begin
  if AtMax or not Enable then DisableCommands([cmNextPage, cmLastPage])
  else if not AtMax then EnableCommands([cmNextPage, cmLastPage]);
  if AtMin or not Enable then DisableCommands([cmPrevPage, cmFirstPage])
  else if not AtMin then EnableCommands([cmPrevPage, cmFirstPage]);
end;

{$IFDEF USE_NEW_FILE_DIALOG}
function TbxFileCollection.Compare(Key1, Key2: Pointer): Integer;
begin
  if PSearchRec(Key1)^.Name = PSearchRec(Key2)^.Name then Compare := 0
  else if PSearchRec(Key1)^.Name = '..' then Compare := -1
  else if PSearchRec(Key2)^.Name = '..' then Compare := 1
  else if (PSearchRec(Key1)^.Attr and VolumeId <> 0)
      and (PSearchRec(Key2)^.Attr and VolumeId = 0) then Compare := 1
  else if (PSearchRec(Key2)^.Attr and VolumeId <> 0)
      and (PSearchRec(Key1)^.Attr and VolumeId = 0) then Compare := -1
  else if PSearchRec(Key1)^.Name > PSearchRec(Key2)^.Name then Compare := 1
  else Compare := -1;
end;

constructor TbxFileList.Init(var Bounds: TRect; AWildCard: PathStr;
  AScrollBar: PScrollBar);
begin
  TSortedListBox.Init(Bounds, 1, AScrollBar);
end;

procedure TbxFileList.HandleEvent(var Event: TEvent);
var
  E: TEvent;
begin
  if (Event.What = evBroadcast) and (Event.Command = cmReceivedFocus)
    and (Event.InfoPtr = @Self) then
  begin
    FocusItem(Focused)
  end else
  begin
    if (Event.What = evMouseDown) and (Event.Double) then
      Message(Owner, evBroadcast, cmRecordHistory, nil);
    inherited HandleEvent(Event);
  end;
end;

procedure TbxFileList.FocusItem(Item: Integer);
begin
  if (List^.Count > 0) then inherited FocusItem(Item);
end;

procedure TbxFileList.ReadDirectory(AWildCard: PathStr);
var
  S: SearchRec;
  P: PSearchRec;
  Event: TEvent;
  FileList: PbxFileCollection;
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  PbxFileDialog(Owner)^.DriveList^.ReadDirectory(AWildCard);
  AWildCard := FExpand(AWildCard);
  FSplit(AWildCard, Dir, Name, Ext);
  FileList := New(PbxFileCollection, Init(5 ,5));
  FindFirst(AWildCard, ReadOnly + Archive, S);
  P := @P;
  while (P <> nil) and (DosError = 0) do
  begin
    if (S.Attr and Directory = 0) then
    begin
      P := MemAlloc(SizeOf(P^));
      if (P <> nil) then
      begin
        Move(S.Attr, P^, SizeOf(P^));
        FileList^.Insert(P);
      end;
    end;
    FindNext(S);
  end;
  if (P = nil) then
    MessageBox('Too many files.', nil, mfOkButton + mfWarning);
  NewList(FileList);
  if (List^.Count > 0) then
  begin
    Event.What := evBroadcast;
    Event.Command := cmFileFocused;
    Event.InfoPtr := List^.At(0);
    Owner^.HandleEvent(Event);
  end;
end;

constructor TbxDriveList.Init(var Bounds: TRect; AScrollBar: PScrollBar);
begin
  TSortedListBox.Init(Bounds, 1, AScrollBar);
end;

procedure TbxDriveList.GetDrives(var Drives: DriveSet);
var
  ADrives: Longint;
begin
  asm
        MOV     AH, 19h
        INT     21h
        PUSH    AX
        MOV     BX, 1
        XOR     CX, CX
        XOR     DL, DL
        MOV     WORD PTR [ADrives], 0
        MOV     WORD PTR [ADrives+2], 0
@1:     MOV     AH, 0Eh
        INT     21h
        MOV     AH, 19h
        INT     21h
        CMP     AL, DL
        JNE     @2
        OR      WORD PTR [ADrives], BX
        OR      WORD PTR [ADrives+2], CX
@2:     SHL     BX, 1
        RCL     CX, 1
        INC     DL
        CMP     DL, 26
        JB      @1
        MOV     AH, 0Eh
        POP     DX
        INT     21h
        SHL     WORD PTR [ADrives], 1
        RCL     WORD PTR [ADrives+2], 1
  end;
  Drives := DriveSet(ADrives);
end;

function TbxDriveList.GetKey(var S: string): Pointer;
const
  SR: TSearchRec = ();

procedure UpString(var S: string);
var
  I: Byte;
begin
  for I := 1 to Length(S) do S[I] := UpCase(S[I]);
end;

begin
  SR.Attr := Directory;
  SR.Name := S;
  UpString(SR.Name);
  GetKey := @SR;
end;

procedure TbxDriveList.ReadDirectory(AWildCard: PathStr);
var
  C: Char;
  DriveList: DriveSet;
  S: SearchRec;
  P: PSearchRec;
  FileList: PbxFileCollection;
  ADir: DirStr;
  AName: NameStr;
  AExt: ExtStr;
begin
  P := @P;
  FileList := New(PbxFileCollection, Init(5, 5));
  AWildCard := FExpand(AWildCard);
  FSplit(AWildCard, ADir, AName, AExt);
  AWildCard := ADir + '*.*';
  FindFirst(AWildCard, Directory, S);
  while (P <> nil) and (DosError = 0) do
  begin
    if (S.Attr and Directory <> 0) and (S.Name[1] <> '.') then
    begin
      P := MemAlloc(SizeOf(P^));
      if (P <> nil) then
      begin
        Move(S.Attr, P^, SizeOf(P^));
        FileList^.Insert(PObject(P));
      end;
    end;
    FindNext(S);
  end;
  if Length(ADir) > 4 then
  begin
    P := MemAlloc(SizeOf(P^));
    if (P <> nil) then
    begin
      FindFirst(AWildCard, Directory, S);
      FindNext(S);
      if (DosError = 0) and (S.Name = '..') then
      begin
        Move(S.Attr, P^, SizeOf(P^))
      end else
      begin
        P^.Name := '..';
        P^.Size := 0;
        P^.Time := $210000;
        P^.Attr := Directory;
      end;
      FileList^.Insert(PObject(P));
    end;
  end;
  GetDrives(DriveList);
  for C := 'A' to 'Z' do
    if (C in DriveList) then
    begin
      P := MemAlloc(SizeOf(P^));
      if (P <> nil) then
      begin
        P^.Name := C + ':';
        P^.Size := 0;
        P^.Time := $210000;
        P^.Attr := Directory or VolumeId;
        FileList^.AtInsert(FileList^.Count, PObject(P));
      end;
    end;
  if (P = nil) then
    MessageBox('Too many directories.', nil, mfOkButton + mfWarning);
  NewList(FileList);
end;

procedure TbxFileInputLine.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evBroadcast) and (Event.Command =cmFileFocused)
    and (State and sfSelected = 0) then
  begin
    if (PSearchRec(Event.InfoPtr)^.Attr and Directory <> 0) then
      Data^ := PSearchRec(Event.InfoPtr)^.Name + '\' +
        PFileDialog(Owner)^.WildCard else
      Data^ := FExpand(PbxFileDialog(Owner)^.Directory^) +
        PSearchRec(Event.InfoPtr)^.Name;
    DrawView;
  end;
end;

procedure TbxFileInfoPane.Draw;
var
  Color: Word;
  Params: array[0..7] of Longint;
  Time: DateTime;
  D: string[5];
  FmtId: string[60];
  Str: string[60];
  B: TDrawBuffer;
const
  sDirectoryLine = '%-12s  %-9s  %02d/%02d/%4d  %02d:%02d%cm';
  sFileLine      = '%-12s  %-9d  %02d/%02d/%4d  %02d:%02d%cm';
begin
  Color := GetColor($01);
  MoveChar(B, ' ', Color, Size.X);
  Params[0] := Longint(@S.Name);
  if ((S.Attr and Directory) <> 0) then
  begin
    FmtId := sDirectoryLine;
    D := '<Dir>';
    Params[1] := Longint(@D);
  end else
  begin
    FmtId := sFileLine;
    Params[1] := S.Size;
  end;
  UnpackTime(S.Time, Time);
  Params[2] := Time.Month;
  Params[3] := Time.Day;
  Params[4] := Time.Year;
  if (Time.Hour >= 12) then Params[7] := Byte('p') else Params[7] := Byte('a');
  Time.Hour := Time.Hour mod 12;
  if (Time.Hour = 0) then Time.Hour := 12;
  Params[5] := Time.Hour;
  Params[6] := Time.Min;
  FormatStr(Str, FmtId, Params);
  MoveStr(B[1], Str, Color);
  WriteLine(0, 0, Size.X, 1, B);
end;

constructor TbxDirectoryInfoPane.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  EventMask := EventMask or evBroadcast;
end;

function TbxDirectoryInfoPane.GetPalette: PPalette;
const
  P: string[Length(CInfoPane)] = CInfoPane;
begin
  GetPalette := @P;
end;

procedure TbxDirectoryInfoPane.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evBroadcast) and (Event.Command = cmFileFocused) then
    DrawView;
end;

procedure TbxDirectoryInfoPane.Draw;
var
  B: TDrawBuffer;
  Color: Word;
  DirName: PathStr;
begin
  DirName := FExpand(PbxFileDialog(Owner)^.Directory^);
  Color := GetColor($01);
  MoveChar(B, ' ', Color, Size.X);
  MoveStr(B[1], DirName, Color);
  WriteLine(0, 0, Size.X, 1, B);
end;

constructor TbxFileDialog.Init(AWildCard: TWildStr; ATitle: string;
  InputName: string; AOptions: Word; HistoryId: Byte);
var
  Control: PView;
  R: TRect;
  S: string;
  Opt: Word;
  ACurDir: PathStr;
begin
  R.Assign(0, 0, 49, 18);
  TDialog.Init(R, ATitle);
  Options := Options or ofCentered;
  WildCard := AWildCard;
  R.Assign(2, 2, 31, 3);
  FileName := New(PbxFileInputLine, Init(R, 79));
  FileName^.Data^ := WildCard;
  Insert(FileName);
  R.Assign(2, 1, 3 + CStrLen(InputName), 2);
  Control := New(PLabel, Init(R, InputName, FileName));
  Insert(Control);
  R.Assign(31, 2, 34, 3);
  Control := New(PHistory, Init(R, FileName, HistoryId));
  Insert(Control);
  R.Assign(16, 6, 17, 16);
  Control := New(PScrollBar, Init(R));
  Insert(Control);
  R.Assign(2, 6, 16, 16);
  FileList := New(PbxFileList, Init(R, WildCard, PScrollBar(Control)));
  Insert(FileList);
  R.Assign(2, 5, 8, 6);
  Control := New(PLabel, Init(R, '~F~iles', FileList));
  Insert(Control);
  R.Assign(32, 6, 33, 16);
  Control := New(PScrollBar, Init(R));
  Insert(Control);
  R.Assign(18, 6, 32, 16);
  DriveList := New(PbxDriveList, Init(R, PScrollBar(Control)));
  Insert(DriveList);
  R.Assign(18, 5, 30, 6);
  Control := New(PLabel, Init(R, 'Fo~l~ders', DriveList));
  Insert(Control);
  R.Assign(35, 2, 46, 4);
  Opt := bfDefault;
  if AOptions and fdOpenButton <> 0 then
  begin
    Insert(New(PButton, Init(R, '~O~pen', cmFileOpen, Opt)));
    Opt := bfNormal;
    Inc(R.A.Y, 3);
    Inc(R.B.Y, 3);
  end;
  if AOptions and fdOkButton <> 0 then
  begin
    Insert(New(PButton, Init(R, '~O~k', cmFileOpen, Opt)));
    Opt := bfNormal;
    Inc(R.A.Y, 3);
    Inc(R.B.Y, 3);
  end;
  if AOptions and fdReplaceButton <> 0 then
  begin
    Insert(New(PButton, Init(R, '~R~eplace', cmFileReplace, Opt)));
    Opt := bfNormal;
    Inc(R.A.Y, 3);
    Inc(R.B.Y, 3);
  end;
  if AOptions and fdClearButton <> 0 then
  begin
    Insert(New(PButton, Init(R, '~C~lear', cmFileClear, Opt)));
    Opt := bfNormal;
    Inc(R.A.Y, 3);
    Inc(R.B.Y, 3);
  end;
  Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));
  Inc(R.A.Y, 3);
  Inc(R.B.Y, 3);
  if AOptions and fdHelpButton <> 0 then
  begin
    Insert(New(PButton, Init(R, 'Help', cmHelp, bfNormal)));
    Inc(R.A.Y, 3);
    Inc(R.B.Y, 3);
  end;
  R.Assign(2, 4, 31, 5);
  Control := New(PbxDirectoryInfoPane, Init(R));
  Insert(Control);
  R.Assign(3, 3, 12, 4);
  Control := New(PStaticText, Init(R, 'Folder'));
  Insert(Control);
  R.Assign(2, Size.Y - 2, Size.X - 2, Size.Y - 1);
  Control := New(PbxFileInfoPane, Init(R));
  Insert(Control);
  SelectNext(False);
  if ((AOptions and fdNoLoadDir) = 0) then ReadDirectory;
end;
{$ENDIF}

procedure RegisterTvDialog;
begin
  RegisterType(RbxRunDialog);
  RegisterType(RbxPercentDialog);
  RegisterType(RbxPrintDialog);
  RegisterType(RbxLinkedLine);
  RegisterType(RbxLinkedBox);
  RegisterType(RbxListBox);
  RegisterType(RbxVListBox);
  RegisterType(RbxCheckListBox);
  RegisterType(RbxPairedListBox);
  RegisterType(RbxPairedStrListBox);
  {RegisterType(RbxVListBox);}
{$IFDEF USE_NEW_FILE_DIALOG}
  RegisterType(RbxFileCollection);
  RegisterType(RbxFileList);
  RegisterType(RbxDriveList);
  RegisterType(RbxFileInputLine);
  RegisterType(RbxFileInfoPane);
  RegisterType(RbxDirectoryInfoPane);
  RegisterType(RbxFileDialog);
{$ENDIF}
end;

end.
