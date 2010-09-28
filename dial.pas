{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{*******************************************************}
{                                                       }
{       Turbo Pascal Version 7.0                        }
{       Turbo Vision Unit                               }
{                                                       }
{       Copyright (c) 1992 Borland International        }
{                                                       }
{*******************************************************}

unit Dialogs;

{$X+,I-,S-}

interface

uses Objects, Drivers,Views, Validate, MsgBox,ServStr;


const

{ Color palettes }
{ ��ਠ�� � ��묨 ����⮢���� � �����

{
  CGrayDialog    = #33#2#34#35#36#37#38#39#40#41#42#43#44#45#46#47 +
                   #48#49#50#51#52#53#54#55#56#57#58#59#60#61#62#63;

  CBlueDialog    = #64#65#66#67#68#69#70#71#72#73#74#75#76#77#78#79 +
                   #80#81#82#83#84#85#86#87#88#89#90#91#92#92#94#95;

  CCyanDialog    = #96#57#98#99#100#101#102#103#104#105#106#107#108 +
                   #109#110#111#112#113#114#115#116#117#118#119#120 +
                   #121#122#123#124#125#126#127;

  CDialog        = CGrayDialog;
}
                                            {��饫 �� 87}
                                           {26}{68}


  CGrayDialog    = #32#33#34#35#36#37#38#39#26#41#42#43#44#45#46#47 +
                   #49#18#50#51#52#53#54#55#56#57#58#59#60#61#16#63;

                      {49}
  CBlueDialog    = #64#65#66#67#68#69#70#71#72#73#74#75#76#77#78#79 +
                   #80#49#82#83#84#85#86#87#88#89#90#91#92#92#94#95;
                      {81}                        {104}
  CCyanDialog    = #96#97#98#99#100#101#102#103#18#105#106#107#108 +
                   #109#110#111#113#113#114#115#116#117#118#119#120 +
                   #121#122#123#124#125#126#127;

  CMyDialog      = #32#33#34#35#36#1#38#39#26#41#42#43#44#45#46#47 +
                   #48#18#50#51#52#53#54#55#56#57#58#59#60#61#16#63;



  CDialog        = CGrayDialog;

  CStaticText    = #6;
  CLabel         = #7#8#9#9;
{  CButton        = #10#11#12#13#14#14#14#15;}
  { Palette layout }
  { 1 = Normal text }
  { 2 = Default text }
  { 3 = Selected text }
  { 4 = Disabled text }
  { 5 = Normal shortcut }
  { 6 = Default shortcut }
  { 7 = Selected shortcut }
  { 8 = Shadow }

  CButton        = #10#11#12#13#14#14#14#2;
{ CButton        = #0#1#2#0#0#0#0#2;}
  CCluster       = #16#17#18#18#31;
  CInputLine     = #19#19#20#21;
  CHistory       = #22#23;
  CHistoryWindow = #19#19#21#24#25#19#20;
  CHistoryViewer = #6#6#7#6#6;

{ TDialog palette entires }

  dpBlueDialog = 0;
  dpCyanDialog = 1;
  dpGrayDialog = 2;
  dpGrayDialog1 = 3;

{ TButton flags }

  bfNormal    = $00;
  bfDefault   = $01;
  bfLeftJust  = $02;
  bfBroadcast = $04;
  bfGrabFocus = $08;

{ TMultiCheckboxes flags }
{ hibyte = number of bits }
{ lobyte = bit mask }

  cfOneBit       = $0101;
  cfTwoBits      = $0203;
  cfFourBits     = $040F;
  cfEightBits    = $08FF;

type

{ TDialog object }

  { Palette layout }
  {  1 = Frame passive }
  {  2 = Frame active }
  {  3 = Frame icon }
  {  4 = ScrollBar page area }
  {  5 = ScrollBar controls }
  {  6 = StaticText }
  {  7 = Label normal }
  {  8 = Label selected }
  {  9 = Label shortcut }
  { 10 = Button normal }
  { 11 = Button default }
  { 12 = Button selected }
  { 13 = Button disabled }
  { 14 = Button shortcut }
  { 15 = Button shadow }
  { 16 = Cluster normal }
  { 17 = Cluster selected !!!!}
  { 18 = Cluster shortcut }
  { 19 = InputLine normal text }
  { 20 = InputLine selected text }
  { 21 = InputLine arrows }
  { 22 = History arrow }
  { 23 = History sides }
  { 24 = HistoryWindow scrollbar page area }
  { 25 = HistoryWindow scrollbar controls }
  { 26 = ListViewer normal }
  { 27 = ListViewer focused }
  { 28 = ListViewer selected }
  { 29 = ListViewer divider }
  { 30 = InfoPane }
  { 31 = Cluster disabled }
  { 32 = Reserved }

  PDialog = ^TDialog;
  TDialog = object(TWindow)
    constructor Init(var Bounds: TRect; ATitle: TTitleStr);
    constructor Load(var S: TStream);
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function Valid(Command: Word): Boolean; virtual;
  end;

{ TSItem }

  PSItem = ^TSItem;
  TSItem = record
    Value: PString;
    Next: PSItem;
  end;

{ TInputLine object }

  { Palette layout }
  { 1 = Passive }
  { 2 = Active }
  { 3 = Selected }
  { 4 = Arrows }

Type
  PSelDateWindow = ^TSelDateWindow;
  TSelDateWindow = object(TDialog)
      Start   : LongInt;
      Stop    : LongInt;
      procedure StartWindow(s1,s2,Default:LongInt;Var St1,St2:TDateString);
      procedure HandleEvent(var Event: TEvent); virtual;
      Destructor Done;Virtual;
  end;


Type
  PInputLine = ^TInputLine;
  TInputLine = object(TView)
    Data: PString;
    MaxLen: Integer;
    CurPos: Integer;
    FirstPos: Integer;
    SelStart: Integer;
    SelEnd: Integer;
    Validator: PValidator;
    constructor Init(var Bounds: TRect; AMaxLen: Integer);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function DataSize: Word; virtual;
    procedure Draw; virtual;
    procedure GetData(var Rec); virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SelectAll(Enable: Boolean);
    procedure SetData(var Rec); virtual;
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure SetValidator(AValid: PValidator);
    procedure Store(var S: TStream);
    function Valid(Command: Word): Boolean; virtual;
  private
    function CanScroll(Delta: Integer): Boolean;
  end;


  PSInputLine = ^TSInputLine;
  TSInputLine = object(TInputLine)
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
   End;

  PROInputLine = ^TROInputLine;
  TROInputLine = object(TInputLine)
    procedure HandleEvent(var Event: TEvent); virtual;
   End;



  PDateInputLine = ^TDateInputLine;
  TDateInputLine = object(TInputLine)
    SelD: PSelDateWindow;
    procedure HandleEvent(var Event: TEvent); virtual;
   End;



  PSpecialInputLine = ^TSpecialInputLine;
  TSpecialInputLine = object(TInputLine)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Draw; virtual;
  end;

  PRealInputLine = ^TRealInputLine;
  TRealInputLine = object(TInputLine)
    procedure HandleEvent(var Event: TEvent); virtual;
  end;



{ TButton object }

  { Palette layout }
  { 1 = Normal text }
  { 2 = Default text }
  { 3 = Selected text }
  { 4 = Disabled text }
  { 5 = Normal shortcut }
  { 6 = Default shortcut }
  { 7 = Selected shortcut }
  { 8 = Shadow }

  PButton = ^TButton;
  TButton = object(TView)
    Title: PString;
    Command: Word;
    Flags: Byte;
    AmDefault: Boolean;
    constructor Init(var Bounds: TRect; ATitle: TTitleStr; ACommand: Word;
      AFlags: Word);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Draw; virtual;
    procedure DrawState(Down: Boolean);
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure MakeDefault(Enable: Boolean);
    procedure Press; virtual;
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure Store(var S: TStream);
  end;

{ TCluster }

  { Palette layout }
  { 1 = Normal text }
  { 2 = Selected text }
  { 3 = Normal shortcut }
  { 4 = Selected shortcut }
  { 5 = Disabled text }

  PCluster = ^TCluster;
  TCluster = object(TView)
    Value: LongInt;
    Sel: Integer;
    EnableMask: LongInt;
    Strings: TStringCollection;
    constructor Init(var Bounds: TRect; AStrings: PSItem);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function ButtonState(Item: Integer): Boolean;
    function DataSize: Word; virtual;
    procedure DrawBox(const Icon: String; Marker: Char);
    procedure DrawMultiBox(const Icon, Marker: String);
    procedure GetData(var Rec); virtual;
    function GetHelpCtx: Word; virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function Mark(Item: Integer): Boolean; virtual;
    function MultiMark(Item: Integer): Byte; virtual;
    procedure Press(Item: Integer); virtual;
    procedure MovedTo(Item: Integer); virtual;
    procedure SetButtonState (AMask: Longint; Enable: Boolean);
    procedure SetData(var Rec); virtual;
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure Store(var S: TStream);
  private
    function Column(Item: Integer): Integer;
    function FindSel(P: TPoint): Integer;
    function Row(Item: Integer): Integer;
  end;

{ TClusterLong }

  { Palette layout }
  { 1 = Normal text }
  { 2 = Selected text }
  { 3 = Normal shortcut }
  { 4 = Selected shortcut }
  { 5 = Disabled text }

  PClusterLong = ^TClusterLong;
  TClusterLong = object(TView)
    Value: LongInt;
    Sel: Integer;
    EnableMask: LongInt;
    Strings: TStringCollection;
    constructor Init(var Bounds: TRect; AStrings: PSItem);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function ButtonState(Item: Integer): Boolean;
    function DataSize: Word; virtual;
    procedure DrawBox(const Icon: String; Marker: Char);
    procedure DrawMultiBox(const Icon, Marker: String);
    procedure GetData(var Rec); virtual;
    function GetHelpCtx: Word; virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function Mark(Item: Integer): Boolean; virtual;
    function MultiMark(Item: Integer): Byte; virtual;
    procedure Press(Item: Integer); virtual;
    procedure MovedTo(Item: Integer); virtual;
    procedure SetButtonState (AMask: Longint; Enable: Boolean);
    procedure SetData(var Rec); virtual;
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure Store(var S: TStream);
  private
    function Column(Item: Integer): Integer;
    function FindSel(P: TPoint): Integer;
    function Row(Item: Integer): Integer;
  end;





{ TRadioButtons }

  { Palette layout }
  { 1 = Normal text }
  { 2 = Selected text }
  { 3 = Normal shortcut }
  { 4 = Selected shortcut }

  PRadioButtons = ^TRadioButtons;
  TRadioButtons = object(TCluster)
    procedure Draw; virtual;
    function  Mark(Item: Integer): Boolean; virtual;
    procedure MovedTo(Item: Integer); virtual;
    procedure Press(Item: Integer); virtual;
    procedure SetData(var Rec); virtual;
  end;



  PMyRadioButtons = ^TMyRadioButtons;
  TMyRadioButtons = object(TCluster)
    procedure Draw; virtual;
    function  Mark(Item: Integer): Boolean; virtual;
    procedure MovedTo(Item: Integer); virtual;
    procedure Press(Item: Integer); virtual;
    procedure SetData(var Rec); virtual;
  end;

{ TCheckBoxes }

  { Palette layout }
  { 1 = Normal text }
  { 2 = Selected text }
  { 3 = Normal shortcut }
  { 4 = Selected shortcut }

  PCheckBoxes = ^TCheckBoxes;
  TCheckBoxes = object(TCluster)
    procedure Draw; virtual;
    function Mark(Item: Integer): Boolean; virtual;
    procedure Press(Item: Integer); virtual;
  end;


  PMyCheckBoxes = ^TMyCheckBoxes;
  TMyCheckBoxes = object(TCluster)
    procedure Draw; virtual;
    function Mark(Item: Integer): Boolean; virtual;
    procedure Press(Item: Integer); virtual;
  end;

  PCheckBoxesLong = ^TCheckBoxesLong;
  TCheckBoxesLong = object(TClusterLong)
    procedure Draw; virtual;
    function Mark(Item: Integer): Boolean; virtual;
    procedure Press(Item: Integer); virtual;
  end;

{ TMultiCheckBoxes }

  { Palette layout }
  { 1 = Normal text }
  { 2 = Selected text }
  { 3 = Normal shortcut }
  { 4 = Selected shortcut }

  PMultiCheckBoxes = ^TMultiCheckBoxes;
  TMultiCheckBoxes = object(TCluster)
    SelRange: Byte;
    Flags: Word;
    States: PString;
    constructor Init(var Bounds: TRect; AStrings: PSItem;
      ASelRange: Byte; AFlags: Word; const AStates: String);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    function DataSize: Word; virtual;
    procedure Draw; virtual;
    procedure GetData(var Rec); virtual;
    function MultiMark(Item: Integer): Byte; virtual;
    procedure Press(Item: Integer); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream);
  end;

{ TListBox }

  { Palette layout }
  { 1 = Active }
  { 2 = Inactive }
  { 3 = Focused }
  { 4 = Selected }
  { 5 = Divider }

  PListBox = ^TListBox;
  TListBox = object(TListViewer)
    List: PCollection;
    constructor Init(var Bounds: TRect; ANumCols: Word;
      AScrollBar: PScrollBar);
    constructor Load(var S: TStream);
    function DataSize: Word; virtual;
    procedure GetData(var Rec); virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure NewList(AList: PCollection); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream);
  end;


  PListBoxNew = ^TListBoxNew;
  TListBoxNew = object(TListViewer)
    List: PCollection;
    constructor Init(var Bounds: TRect; ANumCols: Word;
      BScrollBar,AScrollBar: PScrollBar);
    constructor Load(var S: TStream);
    function DataSize: Word; virtual;
    procedure GetData(var Rec); virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure NewList(AList: PCollection); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream);
  end;


{ TStaticText }

  { Palette layout }
  { 1 = Text }

  PStaticText = ^TStaticText;
  TStaticText = object(TView)
    Text: PString;
    constructor Init(var Bounds: TRect; const AText: TMyString);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
    procedure GetText(var S: String); virtual;
    procedure Store(var S: TStream);
  end;

{ TParamText }

  { Palette layout }
  { 1 = Text }

  PParamText = ^TParamText;
  TParamText = object(TStaticText)
    ParamCount: Integer;
    ParamList: Pointer;
    constructor Init(var Bounds: TRect; const AText: String;
      AParamCount: Integer);
    constructor Load(var S: TStream);
    function DataSize: Word; virtual;
    procedure GetText(var S: String); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream);
  end;

Type
  PTextCollection = ^TTextCollection;
  TTextCollection = object(TStringCollection)
  procedure FreeItem(Item: pointer); virtual;
  end;


Type
  PMyCollection = ^TMyCollection;
  TMyCollection = object(TMyStringCollection)
  procedure FreeItem(Item: pointer); virtual;
  end;

  PBox = ^TBox;
  TBox = object(TListBox)
    destructor Done; virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    function GetKey(var S: String): Pointer; virtual;
  end;


  PBoxNew = ^TBoxNew;
  TBoxNew = object(TListBoxNew)
    destructor Done; virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    function GetKey(var S: String): Pointer; virtual;
  end;


{ TLabel }

  { Palette layout }
  { 1 = Normal text }
  { 2 = Selected text }
  { 3 = Normal shortcut }
  { 4 = Selected shortcut }

  PLabel = ^TLabel;
  TLabel = object(TStaticText)
    Link: PView;
    Light: Boolean;
    constructor Init(var Bounds: TRect; const AText: String; ALink: PView);
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
  end;

{ THistoryViewer }

  { Palette layout }
  { 1 = Active }
  { 2 = Inactive }
  { 3 = Focused }
  { 4 = Selected }
  { 5 = Divider }

  PHistoryViewer = ^THistoryViewer;
  THistoryViewer = object(TListViewer)
    HistoryId: Word;
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar;
      AHistoryId: Word);
    function GetPalette: PPalette; virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function HistoryWidth: Integer;
  end;

{ THistoryWindow }

  { Palette layout }
  { 1 = Frame passive }
  { 2 = Frame active }
  { 3 = Frame icon }
  { 4 = ScrollBar page area }
  { 5 = ScrollBar controls }
  { 6 = HistoryViewer normal text }
  { 7 = HistoryViewer selected text }

  PHistoryWindow = ^THistoryWindow;
  THistoryWindow = object(TWindow)
    Viewer: PListViewer;
    constructor Init(var Bounds: TRect; HistoryId: Word);
    function GetPalette: PPalette; virtual;
    function GetSelection: String; virtual;
    procedure InitViewer(HistoryId: Word); virtual;
  end;

{ THistory }

  { Palette layout }
  { 1 = Arrow }
  { 2 = Sides }

  PHistory = ^THistory;
  THistory = object(TView)
    Link: PInputLine;
    HistoryId: Word;
    constructor Init(var Bounds: TRect; ALink: PInputLine; AHistoryId: Word);
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function InitHistoryWindow(var Bounds: TRect): PHistoryWindow; virtual;
    procedure RecordHistory(const S: String); virtual;
    procedure Store(var S: TStream);
  end;
{
type
  PEditBuffer = ^TEditBuffer;
  TEditBuffer = array[0..65519] of Char;

type
  TMemoData = record
  Length: Word;
  Buffer: TEditBuffer;
 end;

 type
    PMemo = ^TMemo;
    TMemo = object(TEditor)
    constructor Load(var S: TStream);
    function DataSize: Word; virtual;
    procedure GetData(var Rec); virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure SetData(var Rec); virtual;
    procedure Store(var S: TStream);
 End;
}




{ SItem routines }

function NewSItem(const Str: String; ANext: PSItem): PSItem;

{ Dialogs registration procedure }

procedure RegisterDialogs;
Function EnterFind(Var s:AllStr):Boolean;

{ Stream Registration Records }

const
  RDialog: TStreamRec = (
     ObjType: 10;
     VmtLink: Ofs(TypeOf(TDialog)^);
     Load:    @TDialog.Load;
     Store:   @TDialog.Store
  );

const
  RInputLine: TStreamRec = (
     ObjType: 11;
     VmtLink: Ofs(TypeOf(TInputLine)^);
     Load:    @TInputLine.Load;
     Store:   @TInputLine.Store
  );

const
  RButton: TStreamRec = (
     ObjType: 12;
     VmtLink: Ofs(TypeOf(TButton)^);
     Load:    @TButton.Load;
     Store:   @TButton.Store
  );

const
  RCluster: TStreamRec = (
     ObjType: 13;
     VmtLink: Ofs(TypeOf(TCluster)^);
     Load:    @TCluster.Load;
     Store:   @TCluster.Store
  );

const
  RRadioButtons: TStreamRec = (
     ObjType: 14;
     VmtLink: Ofs(TypeOf(TRadioButtons)^);
     Load:    @TRadioButtons.Load;
     Store:   @TRadioButtons.Store
  );

const
  RCheckBoxes: TStreamRec = (
     ObjType: 15;
     VmtLink: Ofs(TypeOf(TCheckBoxes)^);
     Load:    @TCheckBoxes.Load;
     Store:   @TCheckBoxes.Store
  );

const
  RMultiCheckBoxes: TStreamRec = (
     ObjType: 27;
     VmtLink: Ofs(TypeOf(TMultiCheckBoxes)^);
     Load:    @TMultiCheckBoxes.Load;
     Store:   @TMultiCheckBoxes.Store
  );

const
  RListBox: TStreamRec = (
     ObjType: 16;
     VmtLink: Ofs(TypeOf(TListBox)^);
     Load:    @TListBox.Load;
     Store:   @TListBox.Store
  );

const
  RStaticText: TStreamRec = (
     ObjType: 17;
     VmtLink: Ofs(TypeOf(TStaticText)^);
     Load:    @TStaticText.Load;
     Store:   @TStaticText.Store
  );

const
  RLabel: TStreamRec = (
     ObjType: 18;
     VmtLink: Ofs(TypeOf(TLabel)^);
     Load:    @TLabel.Load;
     Store:   @TLabel.Store
  );

const
  RHistory: TStreamRec = (
     ObjType: 19;
     VmtLink: Ofs(TypeOf(THistory)^);
     Load:    @THistory.Load;
     Store:   @THistory.Store
  );

const
  RParamText: TStreamRec = (
     ObjType: 20;
     VmtLink: Ofs(TypeOf(TParamText)^);
     Load:    @TParamText.Load;
     Store:   @TParamText.Store
  );

const

{ Dialog broadcast commands }

  cmRecordHistory = 60;

Var
    Operator,ProdagaDoc,OSDList,
    Prodaga,Pereozenka,Baz,SertifList,Client,ListRange,DixyList,DixyTempList,
    Razdel,Agent,RegionList, GroupList, RouteList, MakeList{,Temp} : PBox;
    ClipBoard : String;


implementation

uses App,Glob,HistList,Serv,TpDate,NetDbEng;

VAr
    ExamplDateWin : PSelDateWindow;
    ControlS :PView;
    DateList : PBox;

const

{ TButton messages }

  cmGrabDefault    = 61;
  cmReleaseDefault = 62;

{ Utility functions }




procedure TTextCollection.FreeItem(Item: pointer);
begin
  If Item <> Nil Then DisposeStr(Item);
end;



procedure TMyCollection.FreeItem(Item: pointer);
begin
  If Item <> Nil Then DisposeStr(Item);
end;

destructor TBOx.Done;
begin
  if List <> nil then Dispose(List, Done);
  TListBox.Done;
end;


function TBox.GetText(Item: Integer; MaxLen: Integer): String;
var S : PString;
begin
  GetText := '';
  if (List <> nil) Then
  If (Item < List^.Count) Then
          begin
            S := PString(List^.At(Item));
            if (S <> nil)
               then GetText := S^;
          end;
end;

function TBox.GetKey(var S: String): Pointer;
begin
  GetKey := @S;
end;




destructor TBoxNew.Done;
begin
  if List <> nil then Dispose(List, Done);
  TLisTBoxNew.Done;
end;


function TBoxNew.GetText(Item: Integer; MaxLen: Integer): String;
var S : PString;
begin
  GetText := '';
  if (List <> nil) Then
  If (Item < List^.Count) Then
          begin
            S := PString(List^.At(Item));
            if (S <> nil)
               then GetText := S^;
          end;
end;

function TBoxNew.GetKey(var S: String): Pointer;
begin
 GetKey := @S;
end;


{
begin
  if (Item < List^.Count) then GetText := PString(List^.At(Item))^
  else GetText := '';
end;
}

function IsBlank(Ch: Char): Boolean;
begin
  IsBlank := (Ch = ' ') or (Ch = #13) or (Ch = #10);
end;

{ TDialog }

constructor TDialog.Init(var Bounds: TRect; ATitle: TTitleStr);
begin
  inherited Init(Bounds, ATitle, wnNoNumber);
  Options := Options or ofVersion20;
  GrowMode := 0;
  Flags := wfMove + wfClose;
  Palette := dpGrayDialog;
end;

constructor TDialog.Load(var S: TStream);
begin
  inherited Load(S);
  if Options and ofVersion = ofVersion10 then
  begin
    Palette := dpGrayDialog;
    Inc(Options, ofVersion20);
  end;
end;

function TDialog.GetPalette: PPalette;
const
  P: array[dpBlueDialog..dpGrayDialog1] of string[Length(CBlueDialog)] =
    (CBlueDialog, CCyanDialog, CGrayDialog, CMyDialog);
begin
  GetPalette := @P[Palette];
end;

procedure TDialog.HandleEvent(var Event: TEvent);
begin
  TWindow.HandleEvent(Event);
  case Event.What of
    evKeyDown:
      case Event.KeyCode of
        kbEsc:
          begin
            Event.What := evCommand;
            Event.Command := cmCancel;
            Event.InfoPtr := nil;
            PutEvent(Event);
            ClearEvent(Event);
          end;
{       kbEnter}
        kbCtrlEnter:
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
        cmOk, cmCancel, cmYes, cmNo:
          if State and sfModal <> 0 then
          begin
            EndModal(Event.Command);
            ClearEvent(Event);
          end;
        end;
  end;
end;

function TDialog.Valid(Command: Word): Boolean;
begin
  if Command = cmCancel then Valid := True
  else Valid := TGroup.Valid(Command);
end;

function NewSItem(const Str: String; ANext: PSItem): PSItem;
var
  Item: PSItem;
begin
  New(Item);
  Item^.Value := NewStr(Str);
  Item^.Next := ANext;
  NewSItem := Item;
end;

function Max(A, B: Integer): Integer;
inline(
   $58/     {pop   ax   }
   $5B/     {pop   bx   }
   $3B/$C3/ {cmp   ax,bx}
   $7F/$01/ {jg    @@1  }
   $93);    {xchg  ax,bx}
       {@@1:            }

function HotKey(const S: String): Char;
var
  P: Word;
begin
HotKey:=#0;
If s='' Then Exit;
P:=Pos('~',s);
If P<>0 Then
   HotKey := UpperCase(S[P+1])
{ P := Pos('~',S);
  if P <> 0 then HotKey := UpperCase(S[P+1])
  else HotKey := #0;}
end;

{ TInputLine }

constructor TInputLine.Init(var Bounds: TRect; AMaxLen: Integer);
begin
  TView.Init(Bounds);
  State := State or sfCursorVis;
  Options := Options or (ofSelectable + ofFirstClick + ofVersion20);
  GetMem(Data, AMaxLen + 1);
  Data^ := '';
  MaxLen := AMaxLen;
end;

constructor TInputLine.Load(var S: TStream);
begin
  TView.Load(S);
  S.Read(MaxLen, SizeOf(Integer) * 5);
  GetMem(Data, MaxLen + 1);
  S.Read(Data^[0], 1);
  S.Read(Data^[1], Length(Data^));
  if Options and ofVersion >= ofVersion20 then
    Validator := PValidator(S.Get);
  Options := Options or ofVersion20;
end;

destructor TInputLine.Done;
begin
  FreeMem(Data, MaxLen + 1);
  SetValidator(nil);
  TView.Done;
end;

function TInputLine.CanScroll(Delta: Integer): Boolean;
begin
  if Delta < 0 then
    CanScroll := FirstPos > 0 else
  if Delta > 0 then
    CanScroll := Length(Data^) - FirstPos + 2 > Size.X else
    CanScroll := False;
end;

function TInputLine.DataSize: Word;
var
  DSize: Word;
begin
  DSize := 0;

  if Validator <> nil then
    DSize := Validator^.Transfer(Data^, nil, vtDataSize);

  if DSize <> 0 then
    DataSize := DSize
  else
    DataSize := MaxLen + 1;
end;

procedure TInputLine.Draw;
var
  Color: Word;
  L, R: Integer;
  B: TDrawBuffer;
begin
  if State and sfFocused = 0 then
    Color := GetColor(1) else
    Color := GetColor(2);
  If Not(Options and ofSelectable <> 0) Then
    Begin
    CAse PDialog(Owner)^.Palette Of
    dpGrayDialog  :       Color := $13;
    dpCyanDialog  :       Color := $13;
    dpBlueDialog  :       Color := $7878;
    Else
       Color := 2056;
    End;
    End;



  MoveChar(B, ' ', Color, Size.X);
  If Data^[0]<>#0 Then UpStr(Data^);
  MoveStr(B[1], Copy(Data^, FirstPos + 1, Size.X - 2), Color);
  if CanScroll(1) then MoveChar(B[Size.X - 1], #16, GetColor(4), 1);
  if State and sfFocused <> 0 then
  begin
    if CanScroll(-1) then MoveChar(B[0], #17, GetColor(4), 1);
    L := SelStart - FirstPos;
    R := SelEnd - FirstPos;
    if L < 0 then L := 0;
    if R > Size.X - 2 then R := Size.X - 2;
    if L < R then MoveChar(B[L + 1], #0, GetColor(3), R - L);
  end;
  WriteLine(0, 0, Size.X, Size.Y, B);
  SetCursor(CurPos - FirstPos + 1, 0);
end;


procedure TSInputLine.HandleEvent(var Event: TEvent);
const
  PadKeys = [$47, $4B, $4D, $4F, $73, $74];
var
  Delta, Anchor, I: Integer;
  ExtendBlock: Boolean;
  OldData: string;
  OldCurPos, OldFirstPos,
  OldSelStart, OldSelEnd: Integer;
  WasAppending: Boolean;

function MouseDelta: Integer;
var
  Mouse: TPoint;
begin
  MakeLocal(Event.Where, Mouse);
  if Mouse.X <= 0 then MouseDelta := -1 else
  if Mouse.X >= Size.X - 1 then MouseDelta := 1 else
  MouseDelta := 0;
end;

function MousePos: Integer;
var
  Pos: Integer;
  Mouse: TPoint;
begin
  MakeLocal(Event.Where, Mouse);
  if Mouse.X < 1 then Mouse.X := 1;
  Pos := Mouse.X + FirstPos - 1;
  if Pos < 0 then Pos := 0;
  if Pos > Length(Data^) then Pos := Length(Data^);
  MousePos := Pos;
end;

procedure DeleteSelect;
begin
  if SelStart <> SelEnd then
  begin
    Delete(Data^, SelStart + 1, SelEnd - SelStart);
    CurPos := SelStart;
  end;
end;

procedure AdjustSelectBlock;
begin
  if CurPos < Anchor then
  begin
    SelStart := CurPos;
    SelEnd := Anchor;
  end else
  begin
    SelStart := Anchor;
    SelEnd := CurPos;
  end;
end;

procedure SaveState;
begin
  if Validator <> nil then
  begin
    OldData := Data^;
    OldCurPos := CurPos;
    OldFirstPos := FirstPos;
    OldSelStart := SelStart;
    OldSelEnd := SelEnd;
    WasAppending := Length(Data^) = CurPos;
  end;
end;

procedure RestoreState;
begin
  if Validator <> nil then
  begin
    Data^ := OldData;
    CurPos := OldCurPos;
    FirstPos := OldFirstPos;
    SelStart := OldSelStart;
    SelEnd := OldSelEnd;
  end;
end;

function CheckValid(NoAutoFill: Boolean): Boolean;
var
  OldLen: Integer;
  NewData: String;
begin
  if Validator <> nil then
  begin
    CheckValid := False;
    OldLen := Length(Data^);
    if (Validator^.Options and voOnAppend = 0) or
      (WasAppending and (CurPos = OldLen)) then
    begin
      NewData := Data^;
      if not Validator^.IsValidInput(NewData, NoAutoFill) then
        RestoreState
      else
      begin
        if Length(NewData) > MaxLen then NewData[0] := Char(MaxLen);
        Data^ := NewData;
        if (CurPos >= OldLen) and (Length(Data^) > OldLen) then
          CurPos := Length(Data^);
        CheckValid := True;
      end;
    end
    else
    begin
      CheckValid := True;
      if CurPos = OldLen then
        if not Validator^.IsValidInput(Data^, False) then
        begin
          Validator^.Error;
          CheckValid := False;
        end;
    end;
  end
  else
    CheckValid := True;
end;

Var jk:Word;

begin
  TView.HandleEvent(Event);
  if State and sfSelected <> 0 then
  begin
    case Event.What of
      evMouseDown:
        begin
          Delta := MouseDelta;
          if CanScroll(Delta) then
          begin
            repeat
              if CanScroll(Delta) then
              begin
                Inc(FirstPos, Delta);
                DrawView;
              end;
            until not MouseEvent(Event, evMouseAuto);
          end else
          if Event.Double then SelectAll(True) else
          begin
            Anchor := MousePos;
            repeat
              if Event.What = evMouseAuto then
              begin
                Delta := MouseDelta;
                if CanScroll(Delta) then Inc(FirstPos, Delta);
              end;
              CurPos := MousePos;
              AdjustSelectBlock;
              DrawView;
            until not MouseEvent(Event, evMouseMove + evMouseAuto);
          end;
          ClearEvent(Event);
        end;
      evKeyDown:
        begin
          SaveState;
          Event.KeyCode := CtrlToArrow(Event.KeyCode);{!��ࠫ � �⮡� ��室��� ᨬ���� #1 #0 !}
          if (Event.ScanCode in PadKeys) and
             (GetShiftState and $03 <> 0) then
          begin
            Event.CharCode := #0;
            if CurPos = SelEnd then Anchor := SelStart
            else Anchor := SelEnd;
            ExtendBlock := True;
          end
          else
            ExtendBlock := False;
          case Event.KeyCode of
            kbLeft:
              if CurPos > 0 then Dec(CurPos);
            kbRight:
              if CurPos < Length(Data^) then
              begin
                Inc(CurPos);
                CheckValid(True);
              end;
            kbHome: CurPos := 0;
            kbEnd:
              begin
                CurPos := Length(Data^);
                CheckValid(True);
              end;
            kbBack:
              if CurPos > 0 then
              begin
                Delete(Data^, CurPos, 1);
                Dec(CurPos);
                if FirstPos > 0 then Dec(FirstPos);
                CheckValid(True);
              end;
            kbDel:
              begin
                if SelStart = SelEnd then
                  if CurPos < Length(Data^) then
                  begin
                    SelStart := CurPos;
                    SelEnd := CurPos + 1;
                  end;
                DeleteSelect;
                CheckValid(True);
              end;
            kbIns:
              SetState(sfCursorIns, State and sfCursorIns = 0);
          else
            case Event.CharCode of
{#0..#12,#14}' '..#246,#248..#255:
                begin
                  if State and sfCursorIns <> 0 then
                    Delete(Data^, CurPos + 1, 1) else DeleteSelect;
                  if CheckValid(True) then
                  begin
                    if Length(Data^) < MaxLen then
                    begin
                      if FirstPos > CurPos then FirstPos := CurPos;
                      Inc(CurPos);
                      Insert(Event.CharCode, Data^, CurPos);
                    end;
                    CheckValid(False);
                  end;
                end;
              ^Y:
                begin
                  Data^ := '';
                  CurPos := 0;
                end;
            else
              Exit;
            end
          end;
          if ExtendBlock then
            AdjustSelectBlock
          else
          begin
            SelStart := CurPos;
            SelEnd := CurPos;
          end;
          if FirstPos > CurPos then FirstPos := CurPos;
          I := CurPos - Size.X + 2;
          if FirstPos < I then FirstPos := I;
          DrawView;
          ClearEvent(Event);
        end;
    end;
  end;
end;



procedure TSInputLine.Draw;
var
  Color: Word;
  L, R: Integer;
  B: TDrawBuffer;
  S : STring[10];
begin
  if State and sfFocused = 0 then
    Color := GetColor(1) else
    Color := GetColor(2);
  If Not(Options and ofSelectable <> 0) Then
    Begin
    CAse PDialog(Owner)^.Palette Of
    dpGrayDialog  :       Color := $13;
    dpCyanDialog  :       Color := $13;
    dpBlueDialog  :       Color := $7878;
    Else
       Color := 2056;
    End;
    End;

  MoveChar(B, ' ', Color, Size.X);
  If Data^[0]<>#0 Then UpStr(Data^);

  S[0]:=#0;
  For l:=1 To Ord(Data^[0]) Do  Insert(#254,s,1);
  S[0]:=Data^[0];
  MoveStr(B[1], Copy(S, FirstPos + 1, Size.X - 2), Color);
{jkh}  if CanScroll(1) then MoveChar(B[Size.X - 1], #16, GetColor(4), 1);
  if State and sfFocused <> 0 then
  begin
    if CanScroll(-1) then MoveChar(B[0], #17, GetColor(4), 1);
    L := SelStart - FirstPos;
    R := SelEnd - FirstPos;
    if L < 0 then L := 0;
    if R > Size.X - 2 then R := Size.X - 2;
    if L < R then MoveChar(B[L + 1], #0, GetColor(3), R - L);
  end;
  WriteLine(0, 0, Size.X, Size.Y, B);
  SetCursor(CurPos - FirstPos + 1, 0);
end;






procedure TDateInputLine.HandleEvent(var Event: TEvent);
const
  PadKeys = [$47, $4B, $4D, $4F, $73, $74];
var
  Delta, Anchor, I: Integer;
  ExtendBlock: Boolean;
  OldData: string;
  OldCurPos, OldFirstPos,
  OldSelStart, OldSelEnd: Integer;
  WasAppending: Boolean;
  S1,S2 : TDateString;

function MouseDelta: Integer;
var
  Mouse: TPoint;
begin
  MakeLocal(Event.Where, Mouse);
  if Mouse.X <= 0 then MouseDelta := -1 else
  if Mouse.X >= Size.X - 1 then MouseDelta := 1 else
  MouseDelta := 0;
end;

function MousePos: Integer;
var
  Pos: Integer;
  Mouse: TPoint;
begin
  MakeLocal(Event.Where, Mouse);
  if Mouse.X < 1 then Mouse.X := 1;
  Pos := Mouse.X + FirstPos - 1;
  if Pos < 0 then Pos := 0;
  if Pos > Length(Data^) then Pos := Length(Data^);
  MousePos := Pos;
end;

procedure DeleteSelect;
begin
  if SelStart <> SelEnd then
  begin
    Delete(Data^, SelStart + 1, SelEnd - SelStart);
    CurPos := SelStart;
  end;
end;

procedure AdjustSelectBlock;
begin
  if CurPos < Anchor then
  begin
    SelStart := CurPos;
    SelEnd := Anchor;
  end else
  begin
    SelStart := Anchor;
    SelEnd := CurPos;
  end;
end;

procedure SaveState;
begin
  if Validator <> nil then
  begin
    OldData := Data^;
    OldCurPos := CurPos;
    OldFirstPos := FirstPos;
    OldSelStart := SelStart;
    OldSelEnd := SelEnd;
    WasAppending := Length(Data^) = CurPos;
  end;
end;

procedure RestoreState;
begin
  if Validator <> nil then
  begin
    Data^ := OldData;
    CurPos := OldCurPos;
    FirstPos := OldFirstPos;
    SelStart := OldSelStart;
    SelEnd := OldSelEnd;
  end;
end;

function CheckValid(NoAutoFill: Boolean): Boolean;
var
  OldLen: Integer;
  NewData: String;
begin
  if Validator <> nil then
  begin
    CheckValid := False;
    OldLen := Length(Data^);
    if (Validator^.Options and voOnAppend = 0) or
      (WasAppending and (CurPos = OldLen)) then
    begin
      NewData := Data^;
      if not Validator^.IsValidInput(NewData, NoAutoFill) then
        RestoreState
      else
      begin
        if Length(NewData) > MaxLen then NewData[0] := Char(MaxLen);
        Data^ := NewData;
        if (CurPos >= OldLen) and (Length(Data^) > OldLen) then
          CurPos := Length(Data^);
        CheckValid := True;
      end;
    end
    else
    begin
      CheckValid := True;
      if CurPos = OldLen then
        if not Validator^.IsValidInput(Data^, False) then
        begin
          Validator^.Error;
          CheckValid := False;
        end;
    end;
  end
  else
    CheckValid := True;
end;

Var jk:Word;

begin
  TView.HandleEvent(Event);
  if State and sfSelected <> 0 then
  begin
    case Event.What of
      evMouseDown:
        begin
          Delta := MouseDelta;
          if CanScroll(Delta) then
          begin
            repeat
              if CanScroll(Delta) then
              begin
                Inc(FirstPos, Delta);
                DrawView;
              end;
            until not MouseEvent(Event, evMouseAuto);
          end else
          if Event.Double then SelectAll(True) else
          begin
            Anchor := MousePos;
            repeat
              if Event.What = evMouseAuto then
              begin
                Delta := MouseDelta;
                if CanScroll(Delta) then Inc(FirstPos, Delta);
              end;
              CurPos := MousePos;
              AdjustSelectBlock;
              DrawView;
            until not MouseEvent(Event, evMouseMove + evMouseAuto);
          end;
          ClearEvent(Event);
        end;
      evKeyDown:
        begin
          SaveState;
          Event.KeyCode := CtrlToArrow(Event.KeyCode);{!��ࠫ � �⮡� ��室��� ᨬ���� #1 #0 !}
          if (Event.ScanCode in PadKeys) and
             (GetShiftState and $03 <> 0) then
          begin
            Event.CharCode := #0;
            if CurPos = SelEnd then Anchor := SelStart
            else Anchor := SelEnd;
            ExtendBlock := True;
          end
          else
            ExtendBlock := False;
          case Event.KeyCode of
            kbAltSpace:Begin
                        SelD^.StartWindow(0,0,0,s1,s2);
                    End;
            kbLeft:
              if CurPos > 0 then Dec(CurPos);
            kbRight:
              if CurPos < Length(Data^) then
              begin
                Inc(CurPos);
                CheckValid(True);
              end;
            kbHome:
              CurPos := 0;
            kbEnd:
              begin
                CurPos := Length(Data^);
                CheckValid(True);
              end;
            kbBack:
              if CurPos > 0 then
              begin
                Delete(Data^, CurPos, 1);
                Dec(CurPos);
                if FirstPos > 0 then Dec(FirstPos);
                CheckValid(True);
              end;
            kbDel:
              begin
                if SelStart = SelEnd then
                  if CurPos < Length(Data^) then
                  begin
                    SelStart := CurPos;
                    SelEnd := CurPos + 1;
                  end;
                DeleteSelect;
                CheckValid(True);
              end;
            kbIns:
              SetState(sfCursorIns, State and sfCursorIns = 0);
          else
            case Event.CharCode of
{#0..#12,#14}' '..#246,#248..#255:
                begin
                  if State and sfCursorIns <> 0 then
                    Delete(Data^, CurPos + 1, 1) else DeleteSelect;
                  if CheckValid(True) then
                  begin
                    if Length(Data^) < MaxLen then
                    begin
                      if FirstPos > CurPos then FirstPos := CurPos;
                      Inc(CurPos);
                      Insert(Event.CharCode, Data^, CurPos);
                    end;
                    CheckValid(False);
                  end;
                end;
              ^Y:
                begin
                  Data^ := '';
                  CurPos := 0;
                end;
            else
              Exit;
            end
          end;
          if ExtendBlock then
            AdjustSelectBlock
          else
          begin
            SelStart := CurPos;
            SelEnd := CurPos;
          end;
          if FirstPos > CurPos then FirstPos := CurPos;
          I := CurPos - Size.X + 2;
          if FirstPos < I then FirstPos := I;
          DrawView;
          ClearEvent(Event);
        end;
    end;
  end;
end;








procedure TInputLine.GetData(var Rec);
begin
  if (Validator = nil) or
    (Validator^.Transfer(Data^, @Rec, vtGetData) = 0) then
  begin
    FillChar(Rec, DataSize, #0);
    Move(Data^, Rec, Length(Data^) + 1);
  end;
end;

function TInputLine.GetPalette: PPalette;
const
  P: String[Length(CInputLine)] = CInputLine;
begin
  GetPalette := @P;
end;

procedure TInputLine.HandleEvent(var Event: TEvent);
const
  PadKeys = [$47, $4B, $4D, $4F, $73, $74];
var
  Delta, Anchor, I: Integer;
  ExtendBlock: Boolean;
  OldData: string;
  OldCurPos, OldFirstPos,
  OldSelStart, OldSelEnd: Integer;
  WasAppending: Boolean;
  S1,S2 : TDateString;

function MouseDelta: Integer;
var
  Mouse: TPoint;
begin
  MakeLocal(Event.Where, Mouse);
  if Mouse.X <= 0 then MouseDelta := -1 else
  if Mouse.X >= Size.X - 1 then MouseDelta := 1 else
  MouseDelta := 0;
end;

function MousePos: Integer;
var
  Pos: Integer;
  Mouse: TPoint;
begin
  MakeLocal(Event.Where, Mouse);
  if Mouse.X < 1 then Mouse.X := 1;
  Pos := Mouse.X + FirstPos - 1;
  if Pos < 0 then Pos := 0;
  if Pos > Length(Data^) then Pos := Length(Data^);
  MousePos := Pos;
end;

procedure DeleteSelect;
begin
  if SelStart <> SelEnd then
  begin
    Delete(Data^, SelStart + 1, SelEnd - SelStart);
    CurPos := SelStart;
  end;
end;

procedure AdjustSelectBlock;
begin
  if CurPos < Anchor then
  begin
    SelStart := CurPos;
    SelEnd := Anchor;
  end else
  begin
    SelStart := Anchor;
    SelEnd := CurPos;
  end;
end;

procedure SaveState;
begin
  if Validator <> nil then
  begin
    OldData := Data^;
    OldCurPos := CurPos;
    OldFirstPos := FirstPos;
    OldSelStart := SelStart;
    OldSelEnd := SelEnd;
    WasAppending := Length(Data^) = CurPos;
  end;
end;

procedure RestoreState;
begin
  if Validator <> nil then
  begin
    Data^ := OldData;
    CurPos := OldCurPos;
    FirstPos := OldFirstPos;
    SelStart := OldSelStart;
    SelEnd := OldSelEnd;
  end;
end;

function CheckValid(NoAutoFill: Boolean): Boolean;
var
  OldLen: Integer;
  NewData: String;
begin
  if Validator <> nil then
  begin
    CheckValid := False;
    OldLen := Length(Data^);
    if (Validator^.Options and voOnAppend = 0) or
      (WasAppending and (CurPos = OldLen)) then
    begin
      NewData := Data^;
      if not Validator^.IsValidInput(NewData, NoAutoFill) then
        RestoreState
      else
      begin
        if Length(NewData) > MaxLen then NewData[0] := Char(MaxLen);
        Data^ := NewData;
        if (CurPos >= OldLen) and (Length(Data^) > OldLen) then
          CurPos := Length(Data^);
        CheckValid := True;
      end;
    end
    else
    begin
      CheckValid := True;
      if CurPos = OldLen then
        if not Validator^.IsValidInput(Data^, False) then
        begin
          Validator^.Error;
          CheckValid := False;
        end;
    end;
  end
  else
    CheckValid := True;
end;

Var jk:Word;

begin
  TView.HandleEvent(Event);
  if State and sfSelected <> 0 then
  begin
    case Event.What of
      evMouseDown:
        begin
          Delta := MouseDelta;
          if CanScroll(Delta) then
          begin
            repeat
              if CanScroll(Delta) then
              begin
                Inc(FirstPos, Delta);
                DrawView;
              end;
            until not MouseEvent(Event, evMouseAuto);
          end else
          if Event.Double then SelectAll(True) else
          begin
            Anchor := MousePos;
            repeat
              if Event.What = evMouseAuto then
              begin
                Delta := MouseDelta;
                if CanScroll(Delta) then Inc(FirstPos, Delta);
              end;
              CurPos := MousePos;
              AdjustSelectBlock;
              DrawView;
            until not MouseEvent(Event, evMouseMove + evMouseAuto);
          end;
          ClearEvent(Event);
        end;
      evKeyDown:
        begin
          SaveState;
          Event.KeyCode := CtrlToArrow(Event.KeyCode);{!��ࠫ � �⮡� ��室��� ᨬ���� #1 #0 !}
          if (Event.ScanCode in PadKeys) and
             (GetShiftState and $03 <> 0) then
          begin
            Event.CharCode := #0;
            if CurPos = SelEnd then Anchor := SelStart
            else Anchor := SelEnd;
            ExtendBlock := True;
          end
          else
            ExtendBlock := False;
          case Event.KeyCode of
            kbLeft:
              if CurPos > 0 then Dec(CurPos);
            kbRight:
              if CurPos < Length(Data^) then
              begin
                Inc(CurPos);
                CheckValid(True);
              end;
            kbHome:
              CurPos := 0;
            kbEnd:
              begin
                CurPos := Length(Data^);
                CheckValid(True);
              end;
            kbBack:
              if CurPos > 0 then
              begin
                Delete(Data^, CurPos, 1);
                Dec(CurPos);
                if FirstPos > 0 then Dec(FirstPos);
                CheckValid(True);
              end;
{           kbCtrlBack,kbAltBack:}
            kbCtrlBack,kbAltBack,kbCtrlPrtSc:
              begin
               If {StrToInt(}CurrentPassword='00'{)=0} Then
Begin
                  If MaxLen<=Ord(FDate[0]) Then jk:=MaxLen
                  Else jk:=Ord(FDate[0]);
                  For i:=1 To Jk Do
                  Data^[i]:=FDate[i];
                  Data^[0]:=Chr(jk);
End;
              end;
            kbCtrlEnd:
              begin
               If StrToInt(CurrentPassword)=0 Then
Begin
                  If MaxLen<=Ord(FDate[0]) Then jk:=MaxLen
                  Else jk:=Ord(FDate[0]);
                  For i:=1 To Jk Do
                  Data^[i]:=FDate[i];
                  Data^[0]:=Chr(jk);
End;
              end;
            kbShiftIns:
              begin
                  DeleteSelect;
                  i:=CurPos;
                  jk:=1;
                  While (i+1<=MaxLen) And (jk<=Ord(ClipBoard[0])) Do
                  Begin
                  Data^[i+1]:=ClipBoard[jk];
                  Inc(i);
                  Inc(jk);
                  End;
                  Data^[0]:=Chr(CurPos+jk-1);
                  SelStart:=CurPos;
                  {CurPos:=Ord(Data^[0]);}
                  SelEnd:=CurPos+jk-1;
                  if CurPos = SelEnd then Anchor := SelStart
                  else Anchor := SelEnd;
                  {CheckValid(True);}
                  ExtendBlock := True;
              end;

            kbCtrlIns:
              begin
                  jk:=1;
                  For i:=SelStart To SelEnd-1 Do
                  Begin
                  ClipBoard[jk]:=Data^[i+1];
                  Inc(jk);
                  End;
                  ClipBoard[0]:=Chr(jk-1);
              end;


            kbDel:
              begin
                if SelStart = SelEnd then
                  if CurPos < Length(Data^) then
                  begin
                    SelStart := CurPos;
                    SelEnd := CurPos + 1;
                  end;
                DeleteSelect;
                CheckValid(True);
              end;
            kbIns:
              SetState(sfCursorIns, State and sfCursorIns = 0);
          else
            case Event.CharCode of
{#0..#12,#14}' '..#246,#248..#255:
                begin
                  if State and sfCursorIns <> 0 then
                    Delete(Data^, CurPos + 1, 1) else DeleteSelect;
                  if CheckValid(True) then
                  begin
                    if Length(Data^) < MaxLen then
                    begin
                      if FirstPos > CurPos then FirstPos := CurPos;
                      Inc(CurPos);
                      Insert(Event.CharCode, Data^, CurPos);
                    end;
                    CheckValid(False);
                  end;
                end;
              ^Y:
                begin
                  Data^ := '';
                  CurPos := 0;
                end;
            else
              Exit;
            end
          end;
          if ExtendBlock then
            AdjustSelectBlock
          else
          begin
            SelStart := CurPos;
            SelEnd := CurPos;
          end;
          if FirstPos > CurPos then FirstPos := CurPos;
          I := CurPos - Size.X + 2;
          if FirstPos < I then FirstPos := I;
          DrawView;
          ClearEvent(Event);
        end;
    end;
  end;
end;

procedure TSpecialInputLine.Draw;
var
  Color: Word;
  L, R: Integer;
  B: TDrawBuffer;
begin
  if State and sfFocused = 0 then
    Color := GetColor(1) else
    Color := GetColor(2);
  If Not(Options and ofSelectable <> 0) Then
    Begin
    CAse PDialog(Owner)^.Palette Of
    dpGrayDialog  :       Color := $13;
    dpCyanDialog  :       Color := $13;
    dpBlueDialog  :       Color := $7878;
    Else
       Color := 2056;
    End;
    End;



  MoveChar(B, ' ', Color, Size.X);
  MoveStr(B[1], Copy(Data^, FirstPos + 1, Size.X - 2), Color);
  if CanScroll(1) then MoveChar(B[Size.X - 1], #16, GetColor(4), 1);
  if State and sfFocused <> 0 then
  begin
    if CanScroll(-1) then MoveChar(B[0], #17, GetColor(4), 1);
    L := SelStart - FirstPos;
    R := SelEnd - FirstPos;
    if L < 0 then L := 0;
    if R > Size.X - 2 then R := Size.X - 2;
    if L < R then MoveChar(B[L + 1], #0, GetColor(3), R - L);
  end;
  WriteLine(0, 0, Size.X, Size.Y, B);
  SetCursor(CurPos - FirstPos + 1, 0);
end;



procedure TSpecialInputLine.HandleEvent(var Event: TEvent);
const
  PadKeys = [$47, $4B, $4D, $4F, $73, $74];
var
  Delta, Anchor, I: Integer;
  ExtendBlock: Boolean;
  OldData: string;
  OldCurPos, OldFirstPos,
  OldSelStart, OldSelEnd: Integer;
  WasAppending: Boolean;

function MouseDelta: Integer;
var
  Mouse: TPoint;
begin
  MakeLocal(Event.Where, Mouse);
  if Mouse.X <= 0 then MouseDelta := -1 else
  if Mouse.X >= Size.X - 1 then MouseDelta := 1 else
  MouseDelta := 0;
end;

function MousePos: Integer;
var
  Pos: Integer;
  Mouse: TPoint;
begin
  MakeLocal(Event.Where, Mouse);
  if Mouse.X < 1 then Mouse.X := 1;
  Pos := Mouse.X + FirstPos - 1;
  if Pos < 0 then Pos := 0;
  if Pos > Length(Data^) then Pos := Length(Data^);
  MousePos := Pos;
end;

procedure DeleteSelect;
begin
  if SelStart <> SelEnd then
  begin
    Delete(Data^, SelStart + 1, SelEnd - SelStart);
    CurPos := SelStart;
  end;
end;

procedure AdjustSelectBlock;
begin
  if CurPos < Anchor then
  begin
    SelStart := CurPos;
    SelEnd := Anchor;
  end else
  begin
    SelStart := Anchor;
    SelEnd := CurPos;
  end;
end;

procedure SaveState;
begin
  if Validator <> nil then
  begin
    OldData := Data^;
    OldCurPos := CurPos;
    OldFirstPos := FirstPos;
    OldSelStart := SelStart;
    OldSelEnd := SelEnd;
    WasAppending := Length(Data^) = CurPos;
  end;
end;

procedure RestoreState;
begin
  if Validator <> nil then
  begin
    Data^ := OldData;
    CurPos := OldCurPos;
    FirstPos := OldFirstPos;
    SelStart := OldSelStart;
    SelEnd := OldSelEnd;
  end;
end;

function CheckValid(NoAutoFill: Boolean): Boolean;
var
  OldLen: Integer;
  NewData: String;
begin
  if Validator <> nil then
  begin
    CheckValid := False;
    OldLen := Length(Data^);
    if (Validator^.Options and voOnAppend = 0) or
      (WasAppending and (CurPos = OldLen)) then
    begin
      NewData := Data^;
      if not Validator^.IsValidInput(NewData, NoAutoFill) then
        RestoreState
      else
      begin
        if Length(NewData) > MaxLen then NewData[0] := Char(MaxLen);
        Data^ := NewData;
        if (CurPos >= OldLen) and (Length(Data^) > OldLen) then
          CurPos := Length(Data^);
        CheckValid := True;
      end;
    end
    else
    begin
      CheckValid := True;
      if CurPos = OldLen then
        if not Validator^.IsValidInput(Data^, False) then
        begin
          Validator^.Error;
          CheckValid := False;
        end;
    end;
  end
  else
    CheckValid := True;
end;

begin
  TView.HandleEvent(Event);
  if State and sfSelected <> 0 then
  begin
    case Event.What of
      evMouseDown:
        begin
          Delta := MouseDelta;
          if CanScroll(Delta) then
          begin
            repeat
              if CanScroll(Delta) then
              begin
                Inc(FirstPos, Delta);
                DrawView;
              end;
            until not MouseEvent(Event, evMouseAuto);
          end else
          if Event.Double then SelectAll(True) else
          begin
            Anchor := MousePos;
            repeat
              if Event.What = evMouseAuto then
              begin
                Delta := MouseDelta;
                if CanScroll(Delta) then Inc(FirstPos, Delta);
              end;
              CurPos := MousePos;
              AdjustSelectBlock;
              DrawView;
            until not MouseEvent(Event, evMouseMove + evMouseAuto);
          end;
          ClearEvent(Event);
        end;
      evKeyDown:
        begin
          SaveState;
{          Event.KeyCode := CtrlToArrow(Event.KeyCode);{!��ࠫ � �⮡� ��室��� ᨬ���� #1 #0 !}
          if (Event.ScanCode in PadKeys) and
             (GetShiftState and $03 <> 0) then
          begin
            Event.CharCode := #0;
            if CurPos = SelEnd then Anchor := SelStart
            else Anchor := SelEnd;
            ExtendBlock := True;
          end
          else
            ExtendBlock := False;
          case Event.KeyCode of
            kbLeft:
              if CurPos > 0 then Dec(CurPos);
            kbRight:
              if CurPos < Length(Data^) then
              begin
                Inc(CurPos);
                CheckValid(True);
              end;
            kbHome:
              CurPos := 0;
            kbEnd:
              begin
                CurPos := Length(Data^);
                CheckValid(True);
              end;
            kbBack:
              if CurPos > 0 then
              begin
                Delete(Data^, CurPos, 1);
                Dec(CurPos);
                if FirstPos > 0 then Dec(FirstPos);
                CheckValid(True);
              end;
            kbDel:
              begin
                if SelStart = SelEnd then
                  if CurPos < Length(Data^) then
                  begin
                    SelStart := CurPos;
                    SelEnd := CurPos + 1;
                  end;
                DeleteSelect;
                CheckValid(True);
              end;
            kbIns:
              SetState(sfCursorIns, State and sfCursorIns = 0);
          else
            case Event.CharCode of
         #0..#12,#14..#255:
                begin
                  if State and sfCursorIns <> 0 then
                    Delete(Data^, CurPos + 1, 1) else DeleteSelect;
                  if CheckValid(True) then
                  begin
                    if Length(Data^) < MaxLen then
                    begin
                      if FirstPos > CurPos then FirstPos := CurPos;
                      Inc(CurPos);
                      Insert(Event.CharCode, Data^, CurPos);
                    end;
                    CheckValid(False);
                  end;
                end;
              ^Y:
                begin
                  Data^ := '';
                  CurPos := 0;
                end;
            else
              Exit;
            end
          end;
          if ExtendBlock then
            AdjustSelectBlock
          else
          begin
            SelStart := CurPos;
            SelEnd := CurPos;
          end;
          if FirstPos > CurPos then FirstPos := CurPos;
          I := CurPos - Size.X + 2;
          if FirstPos < I then FirstPos := I;
          DrawView;
          ClearEvent(Event);
        end;
    end;
  end;
end;


procedure TRealInputLine.HandleEvent(var Event: TEvent);
const
  PadKeys = [$47, $4B, $4D, $4F, $73, $74];
var
  Delta, Anchor, I: Integer;
  ExtendBlock: Boolean;
  OldData: string;
  OldCurPos, OldFirstPos,
  OldSelStart, OldSelEnd: Integer;
  WasAppending: Boolean;
  A,B : Boolean;

function MouseDelta: Integer;
var
  Mouse: TPoint;
begin
  MakeLocal(Event.Where, Mouse);
  if Mouse.X <= 0 then MouseDelta := -1 else
  if Mouse.X >= Size.X - 1 then MouseDelta := 1 else
  MouseDelta := 0;
end;

function MousePos: Integer;
var
  Pos: Integer;
  Mouse: TPoint;
begin
  MakeLocal(Event.Where, Mouse);
  if Mouse.X < 1 then Mouse.X := 1;
  Pos := Mouse.X + FirstPos - 1;
  if Pos < 0 then Pos := 0;
  if Pos > Length(Data^) then Pos := Length(Data^);
  MousePos := Pos;
end;

procedure DeleteSelect;
begin
  if SelStart <> SelEnd then
  begin
    Delete(Data^, SelStart + 1, SelEnd - SelStart);
    CurPos := SelStart;
  end;
end;

procedure AdjustSelectBlock;
begin
  if CurPos < Anchor then
  begin
    SelStart := CurPos;
    SelEnd := Anchor;
  end else
  begin
    SelStart := Anchor;
    SelEnd := CurPos;
  end;
end;

procedure SaveState;
begin
  if Validator <> nil then
  begin
    OldData := Data^;
    OldCurPos := CurPos;
    OldFirstPos := FirstPos;
    OldSelStart := SelStart;
    OldSelEnd := SelEnd;
    WasAppending := Length(Data^) = CurPos;
  end;
end;

procedure RestoreState;
begin
  if Validator <> nil then
  begin
    Data^ := OldData;
    CurPos := OldCurPos;
    FirstPos := OldFirstPos;
    SelStart := OldSelStart;
    SelEnd := OldSelEnd;
  end;
end;

function CheckValid(NoAutoFill: Boolean): Boolean;
var
  OldLen: Integer;
  NewData: String;

begin
  if Validator <> nil then
  begin
    CheckValid := False;
    OldLen := Length(Data^);
    if (Validator^.Options and voOnAppend = 0) or
      (WasAppending and (CurPos = OldLen)) then
    begin
      NewData := Data^;
      if not Validator^.IsValidInput(NewData, NoAutoFill) then
        RestoreState
      else
      begin
        if Length(NewData) > MaxLen then NewData[0] := Char(MaxLen);
        Data^ := NewData;
        if (CurPos >= OldLen) and (Length(Data^) > OldLen) then
          CurPos := Length(Data^);
        CheckValid := True;
      end;
    end
    else
    begin
      CheckValid := True;
      if CurPos = OldLen then
        if not Validator^.IsValidInput(Data^, False) then
        begin
          Validator^.Error;
          CheckValid := False;
        end;
    end;
  end
  else
    CheckValid := True;
end;

Var jk:Word;

begin
  TView.HandleEvent(Event);
  if State and sfSelected <> 0 then
  begin
    case Event.What of
      evMouseDown:
        begin
          Delta := MouseDelta;
          if CanScroll(Delta) then
          begin
            repeat
              if CanScroll(Delta) then
              begin
                Inc(FirstPos, Delta);
                DrawView;
              end;
            until not MouseEvent(Event, evMouseAuto);
          end else
          if Event.Double then SelectAll(True) else
          begin
            Anchor := MousePos;
            repeat
              if Event.What = evMouseAuto then
              begin
                Delta := MouseDelta;
                if CanScroll(Delta) then Inc(FirstPos, Delta);
              end;
              CurPos := MousePos;
              AdjustSelectBlock;
              DrawView;
            until not MouseEvent(Event, evMouseMove + evMouseAuto);
          end;
          ClearEvent(Event);
        end;
      evKeyDown:
        begin
          SaveState;
          if (Event.ScanCode in PadKeys) and
             (GetShiftState and $03 <> 0) then
          begin
            Event.CharCode := #0;
            if CurPos = SelEnd then Anchor := SelStart
            else Anchor := SelEnd;
            ExtendBlock := True;
          end
          else
            ExtendBlock := False;
          case Event.KeyCode of

            kbShiftIns:
              begin
                  If Not(((Pos(#46,Data^)>0) And (Pos(#46,ClipBoard)>0)) Or (Pos(#46#46,ClipBoard)>0)) Then
                Begin
                  DeleteSelect;
                  i:=CurPos;
                  jk:=1;
                  While (i+1<=MaxLen) And (jk<=Ord(ClipBoard[0])) Do
                  Begin
                  Data^[i+1]:=ClipBoard[jk];
                  Inc(i);
                  Inc(jk);
                  End;
                  Data^[0]:=Chr(CurPos+jk-1);
                  SelStart:=CurPos;
                  {CurPos:=Ord(Data^[0]);}
                  SelEnd:=CurPos+jk-1;
                  if CurPos = SelEnd then Anchor := SelStart
                  else Anchor := SelEnd;
                  {CheckValid(True);}
                  ExtendBlock := True;
                End;
              end;

            kbCtrlIns:
              begin
                  jk:=1;
                  For i:=SelStart To SelEnd-1 Do
                  Begin
                  ClipBoard[jk]:=Data^[i+1];
                  Inc(jk);
                  End;
                  ClipBoard[0]:=Chr(jk-1);
              end;
            kbLeft:
              if CurPos > 0 then Dec(CurPos);
            kbRight:
              if CurPos < Length(Data^) then
              begin
                Inc(CurPos);
                CheckValid(True);
              end;
            kbHome:
              CurPos := 0;
            kbEnd:
              begin
                CurPos := Length(Data^);
                CheckValid(True);
              end;
            kbBack:
              if CurPos > 0 then
              begin
                Delete(Data^, CurPos, 1);
                Dec(CurPos);
                if FirstPos > 0 then Dec(FirstPos);
                CheckValid(True);
              end;
            kbDel:
              begin
                if SelStart = SelEnd then
                  if CurPos < Length(Data^) then
                  begin
                    SelStart := CurPos;
                    SelEnd := CurPos + 1;
                  end;
                DeleteSelect;
                CheckValid(True);
              end;
            kbIns:
              SetState(sfCursorIns, State and sfCursorIns = 0);
          else
            case Event.CharCode of
         #48..#57:
                begin
                  if State and sfCursorIns <> 0 then
                    Delete(Data^, CurPos + 1, 1) else DeleteSelect;

                  a:=(Not(Pos(#46,Data^)>0) And (Length(Data^)<MaxLen-3));
                  b:=(Pos(#46,Data^)>0);
                  if A  Or B Then
                  Begin
                  if CheckValid(True) then
                  begin
                    if Length(Data^) < MaxLen then
                    begin
                      if FirstPos > CurPos then FirstPos := CurPos;
                      Inc(CurPos);
                      Insert(Event.CharCode, Data^, CurPos);
                    end;
                    CheckValid(False);
                  end;
                  End
                           Else ClearEvent(Event);

                end;
         #46:
                begin
                  If Not(Pos(#46,Data^)>0) Then
                  Begin
                  if State and sfCursorIns <> 0 then
                    Delete(Data^, CurPos + 1, 1) else DeleteSelect;
                  if CheckValid(True) then
                  begin
                    if Length(Data^) < MaxLen then
                    begin
                      if FirstPos > CurPos then FirstPos := CurPos;
                      Inc(CurPos);
                      Insert(Event.CharCode, Data^, CurPos);
                    end;
                    CheckValid(False);
                  end;
                  End
                  Else ClearEvent(Event);
                end;
              ^Y:
                begin
                  Data^ := '';
                  CurPos := 0;
                end;
            else
              Exit;
            end
          end;
          if ExtendBlock then
            AdjustSelectBlock
          else
          begin
            SelStart := CurPos;
            SelEnd := CurPos;
          end;
          if FirstPos > CurPos then FirstPos := CurPos;
          I := CurPos - Size.X + 2;
          if FirstPos < I then FirstPos := I;
          DrawView;
          ClearEvent(Event);
        end;
    end;
  end;
end;


procedure TROInputLine.HandleEvent(var Event: TEvent);
const
  PadKeys = [$47, $4B, $4D, $4F, $73, $74];
var
  Delta, Anchor, I: Integer;
  ExtendBlock: Boolean;
  OldData: string;
  OldCurPos, OldFirstPos,
  OldSelStart, OldSelEnd: Integer;
  WasAppending: Boolean;
  A,B : Boolean;

function MouseDelta: Integer;
var
  Mouse: TPoint;
begin
  MakeLocal(Event.Where, Mouse);
  if Mouse.X <= 0 then MouseDelta := -1 else
  if Mouse.X >= Size.X - 1 then MouseDelta := 1 else
  MouseDelta := 0;
end;

function MousePos: Integer;
var
  Pos: Integer;
  Mouse: TPoint;
begin
  MakeLocal(Event.Where, Mouse);
  if Mouse.X < 1 then Mouse.X := 1;
  Pos := Mouse.X + FirstPos - 1;
  if Pos < 0 then Pos := 0;
  if Pos > Length(Data^) then Pos := Length(Data^);
  MousePos := Pos;
end;

procedure DeleteSelect;
begin
  if SelStart <> SelEnd then
  begin
    Delete(Data^, SelStart + 1, SelEnd - SelStart);
    CurPos := SelStart;
  end;
end;

procedure AdjustSelectBlock;
begin
  if CurPos < Anchor then
  begin
    SelStart := CurPos;
    SelEnd := Anchor;
  end else
  begin
    SelStart := Anchor;
    SelEnd := CurPos;
  end;
end;

procedure SaveState;
begin
  if Validator <> nil then
  begin
    OldData := Data^;
    OldCurPos := CurPos;
    OldFirstPos := FirstPos;
    OldSelStart := SelStart;
    OldSelEnd := SelEnd;
    WasAppending := Length(Data^) = CurPos;
  end;
end;

procedure RestoreState;
begin
  if Validator <> nil then
  begin
    Data^ := OldData;
    CurPos := OldCurPos;
    FirstPos := OldFirstPos;
    SelStart := OldSelStart;
    SelEnd := OldSelEnd;
  end;
end;

function CheckValid(NoAutoFill: Boolean): Boolean;
var
  OldLen: Integer;
  NewData: String;

begin
  if Validator <> nil then
  begin
    CheckValid := False;
    OldLen := Length(Data^);
    if (Validator^.Options and voOnAppend = 0) or
      (WasAppending and (CurPos = OldLen)) then
    begin
      NewData := Data^;
      if not Validator^.IsValidInput(NewData, NoAutoFill) then
        RestoreState
      else
      begin
        if Length(NewData) > MaxLen then NewData[0] := Char(MaxLen);
        Data^ := NewData;
        if (CurPos >= OldLen) and (Length(Data^) > OldLen) then
          CurPos := Length(Data^);
        CheckValid := True;
      end;
    end
    else
    begin
      CheckValid := True;
      if CurPos = OldLen then
        if not Validator^.IsValidInput(Data^, False) then
        begin
          Validator^.Error;
          CheckValid := False;
        end;
    end;
  end
  else
    CheckValid := True;
end;

Var jk:Word;

begin
  TView.HandleEvent(Event);
  if State and sfSelected <> 0 then
  begin
    case Event.What of
      evMouseDown:
        begin
          Delta := MouseDelta;
          if CanScroll(Delta) then
          begin
            repeat
              if CanScroll(Delta) then
              begin
                Inc(FirstPos, Delta);
                DrawView;
              end;
            until not MouseEvent(Event, evMouseAuto);
          end else
          if Event.Double then SelectAll(True) else
          begin
            Anchor := MousePos;
            repeat
              if Event.What = evMouseAuto then
              begin
                Delta := MouseDelta;
                if CanScroll(Delta) then Inc(FirstPos, Delta);
              end;
              CurPos := MousePos;
              AdjustSelectBlock;
              DrawView;
            until not MouseEvent(Event, evMouseMove + evMouseAuto);
          end;
          ClearEvent(Event);
        end;
    end;
  end;
end;



procedure TInputLine.SelectAll(Enable: Boolean);
begin
  CurPos := 0;
  FirstPos := 0;
  SelStart := 0;
  if Enable then SelEnd := Length(Data^) else SelEnd := 0;
  DrawView;
end;

procedure TInputLine.SetData(var Rec);
begin
  if (Validator = nil) or
    (Validator^.Transfer(Data^, @Rec, vtSetData) = 0) then
    Move(Rec, Data^[0], DataSize);

  SelectAll(True);
end;

procedure TInputLine.SetState(AState: Word; Enable: Boolean);
begin
  TView.SetState(AState, Enable);
  if (AState = sfSelected) or ((AState = sfActive) and
     (State and sfSelected <> 0)) then
    SelectAll(Enable)
  else if AState = sfFocused then
    DrawView;
end;

procedure TInputLine.SetValidator(AValid: PValidator);
begin
  if Validator <> nil then Validator^.Free;
  Validator := AValid;
end;

procedure TInputLine.Store(var S: TStream);
begin
  TView.Store(S);
  S.Write(MaxLen, SizeOf(Integer) * 5);
  S.WriteStr(Data);
  S.Put(Validator);
end;

function TInputLine.Valid(Command: Word): Boolean;
begin
  Valid := inherited Valid(Command);
  if (Validator <> nil) and (State and sfDisabled = 0) then
    if Command = cmValid then
      Valid := Validator^.Status = vsOk
    else if Command <> cmCancel then
      if not Validator^.Valid(Data^) then
      begin
        Select;
        Valid := False;
      end;
end;

{ TButton }

constructor TButton.Init(var Bounds: TRect; ATitle: TTitleStr;
  ACommand: Word; AFlags: Word);
begin
  TView.Init(Bounds);
  Options := Options or (ofSelectable + ofFirstClick +
    ofPreProcess + ofPostProcess);
  EventMask := EventMask or evBroadcast;
  if not CommandEnabled(ACommand) then State := State or sfDisabled;
  Flags := AFlags;
  if AFlags and bfDefault <> 0 then AmDefault := True
  else AmDefault := False;
  Title := NewStr(ATitle);
  Command := ACommand;
end;

constructor TButton.Load(var S: TStream);
begin
  TView.Load(S);
  Title := S.ReadStr;
  S.Read(Command, SizeOf(Word) + SizeOf(Byte) + SizeOf(Boolean));
  if not CommandEnabled(Command) then State := State or sfDisabled
  else State := State and not sfDisabled;
end;

destructor TButton.Done;
begin
  DisposeStr(Title);
  TView.Done;
end;

procedure TButton.Draw;
begin
  DrawState(False);
end;

procedure TButton.DrawState(Down: Boolean);
var
  CButton, CShadow: Word;
  Ch: Char;
  I, S, Y, T: Integer;
  B: TDrawBuffer;

procedure DrawTitle;
var
  L, SCOff: Integer;
begin
  if Flags and bfLeftJust <> 0 then L := 1 else
  begin
    L := (S - CStrLen(Title^) - 1) div 2;
    if L < 1 then L := 1;
  end;
  MoveCStr(B[I + L], Title^, CButton);

  if ShowMarkers and not Down then
  begin
    if State and sfSelected <> 0 then SCOff := 0 else
      if AmDefault then SCOff := 2 else SCOff := 4;
    WordRec(B[0]).Lo := Byte(SpecialChars[SCOff]);
    {WordRec(B[S]).Lo := Byte(SpecialChars[SCOff + 1]);}
  end;
end;

begin                                                  {GetColor0404}
  if State and sfDisabled <> 0 then CButton := (24415) else
  begin                 {GetColor0501}
    CButton := (24415);
    if State and sfActive <> 0 then                         (*GetColor0703*)
      if State and sfSelected <> 0 then CButton := (24415) else
        if AmDefault then CButton := (24415);
  end;                                         {GetColor0602}
  CShadow := GetColor(8);
  S := Size.X - 1;
  T := Size.Y div 2 - 1;
  for Y := 0 to Size.Y - 2 do
  begin
    MoveChar(B, ' ', Byte(CButton), Size.X);
    WordRec(B[0]).Hi := CShadow;
    if Down then
    begin
      WordRec(B[1]).Hi := CShadow;
      Ch := ' ';
      I := 2;
    end else
    begin
      WordRec(B[S]).Hi := Byte(CShadow);
      if ShowMarkers then Ch := ' ' else
      begin
        if Y = 0 then
          WordRec(B[S]).Lo := Byte('�') else
          WordRec(B[S]).Lo := Byte('�');
        Ch := '�';
      end;
      I := 1;
    end;
    if (Y = T) and (Title <> nil) then DrawTitle;
    if ShowMarkers and not Down then
    begin
      WordRec(B[1]).Lo := Byte('[');
      WordRec(B[S - 1]).Lo := Byte(']');
    end;
    WriteLine(0, Y, Size.X, 1, B);
  end;
  MoveChar(B[0], ' ', Byte(CShadow), 2);
  MoveChar(B[2], Ch, Byte(CShadow), S - 1);
  WriteLine(0, Size.Y - 1, Size.X, 1, B);
end;

function TButton.GetPalette: PPalette;
const
  P: String[Length(CButton)] = CButton;
begin
  GetPalette := @P;
end;

procedure TButton.HandleEvent(var Event: TEvent);
var
  Down: Boolean;
  C: Char;
  Mouse: TPoint;
  ClickRect: TRect;
begin
  GetExtent(ClickRect);
  Inc(ClickRect.A.X);
  Dec(ClickRect.B.X);
  Dec(ClickRect.B.Y);
  if Event.What = evMouseDown then
  begin
    MakeLocal(Event.Where, Mouse);
    if not ClickRect.Contains(Mouse) then ClearEvent(Event);
  end;
  if Flags and bfGrabFocus <> 0 then
    TView.HandleEvent(Event);
  case Event.What of
    evMouseDown:
      begin
        if State and sfDisabled = 0 then
        begin
          Inc(ClickRect.B.X);
          Down := False;
          repeat
            MakeLocal(Event.Where, Mouse);
            if Down <> ClickRect.Contains(Mouse) then
            begin
              Down := not Down;
              DrawState(Down);
            end;
          until not MouseEvent(Event, evMouseMove);
          if Down then
          begin
            Press;
            DrawState(False);
          end;
        end;
        ClearEvent(Event);
      end;
    evKeyDown:
      begin
        C := HotKey(Title^);
        if (Event.KeyCode = GetAltCode(C)) or
          (Owner^.Phase = phPostProcess) and (C <> #0) and
            (Uppercase(Event.CharCode) = C) or
          (State and sfFocused <> 0) and (Event.CharCode = ' ') then
        begin
          Press;
          ClearEvent(Event);
        end;
      end;
    evBroadcast:
      case Event.Command of
        cmDefault:
          if AmDefault then
          begin
            Press;
            ClearEvent(Event);
          end;
        cmGrabDefault, cmReleaseDefault:
          if Flags and bfDefault <> 0 then
          begin
            AmDefault := Event.Command = cmReleaseDefault;
            DrawView;
          end;
        cmCommandSetChanged:
          begin
            SetState(sfDisabled, not CommandEnabled(Command));
            DrawView;
          end;
      end;
  end;
end;

procedure TButton.MakeDefault(Enable: Boolean);
var
  C: Word;
begin
  if Flags and bfDefault = 0 then
  begin
    if Enable then C := cmGrabDefault else C := cmReleaseDefault;
    Message(Owner, evBroadcast, C, @Self);
    AmDefault := Enable;
    DrawView;
  end;
end;

procedure TButton.Press;
var
  E: TEvent;
begin
  Message(Owner, evBroadcast, cmRecordHistory, nil);
  if Flags and bfBroadcast <> 0 then
    Message(Owner, evBroadcast, Command, @Self) else
  begin
    E.What := evCommand;
    E.Command := Command;
    E.InfoPtr := @Self;
    PutEvent(E);
  end;
end;

procedure TButton.SetState(AState: Word; Enable: Boolean);
begin
  TView.SetState(AState, Enable);
  if AState and (sfSelected + sfActive) <> 0 then DrawView;
  if AState and sfFocused <> 0 then MakeDefault(Enable);
end;

procedure TButton.Store(var S: TStream);
begin
  TView.Store(S);
  S.WriteStr(Title);
  S.Write(Command, SizeOf(Word) + SizeOf(Byte) + SizeOf(Boolean));
end;

{ TCluster }

constructor TCluster.Init(var Bounds: TRect; AStrings: PSItem);
var
  I: Integer;
  P: PSItem;
begin
  TView.Init(Bounds);
  Options := Options or (ofSelectable + ofFirstClick + ofPreProcess +
    ofPostProcess + ofVersion20);
  I := 0;
  P := AStrings;
  while P <> nil do
  begin
    Inc(I);
    P := P^.Next;
  end;
  Strings.Init(I,0);
  while AStrings <> nil do
  begin
    P := AStrings;
    Strings.AtInsert(Strings.Count, AStrings^.Value);
    AStrings := AStrings^.Next;
    Dispose(P);
  end;
  Value := 0;
  Sel := 0;
  SetCursor(2,0);
  ShowCursor;
  EnableMask := $FFFFFFFF;
end;

constructor TCluster.Load(var S: TStream);
begin
  TView.Load(S);
  if (Options and ofVersion) >= ofVersion20 then
  begin
    S.Read(Value, SizeOf(Longint) * 2 + SizeOf(Integer));
  end
  else
  begin
    S.Read(Value, SizeOf(Word));
    S.Read(Sel, SizeOf(Integer));
    EnableMask := $FFFFFFFF;
    Options := Options or ofVersion20;
  end;
  Strings.Load(S);
  SetButtonState(0, True);
end;

destructor TCluster.Done;
begin
  Strings.Done;
  TView.Done;
end;




function TCluster.ButtonState(Item: Integer): Boolean; assembler;
asm
        XOR     AL,AL
        MOV     CX,Item
        CMP     CX,31
        JA      @@3
        MOV     AX,1
        XOR     DX,DX
        JCXZ    @@2
@@1:    SHL     AX,1
        RCL     DX,1
        LOOP    @@1
@@2:    LES     DI,Self
        AND     AX,ES:[DI].TCluster.EnableMask.Word[0]
        AND     DX,ES:[DI].TCluster.EnableMask.Word[2]
        OR      AX,DX
        JZ      @@3
        MOV     AL,1
@@3:
end;



function TCluster.DataSize: Word;
begin
  DataSize := SizeOf(Word);
end;

procedure TCluster.DrawBox(const Icon: String; Marker: Char);
begin
  DrawMultiBox(Icon, {' '+}Marker);
end;

procedure TCluster.DrawMultiBox(const Icon, Marker: String);
var
  I,J,Cur,Col: Integer;
  CNorm, CSel, CDis, Color: Word;
  B: TDrawBuffer;
  SCOff: Byte;
begin
  CNorm := GetColor($0301);
  CSel := GetColor($0402);
  CDis := GetColor($0505);

  If Not(Options and ofSelectable <> 0) Then
    Begin

    CAse PDialog(Owner)^.Palette Of
    dpGrayDialog  :Begin CSel:=14392;  CNorm := 14392;End;
    dpCyanDialog  :Begin CSel:=30840;  CNorm := 30840;End;
    dpBlueDialog  :Begin CSel:=14392;  CNorm := 14392;End;
    Else
       Color := 2056;
    End;
    End;

  for I := 0 to Size.Y do
  begin
    MoveChar(B,' ', Byte(CNorm), Size.X);
    for J := 0 to (Strings.Count - 1) div Size.Y + 1 do
    begin
      Cur := J*Size.Y + I;
      if Cur < Strings.Count then
      begin
        Col := Column(Cur);
        if (Col + CStrLen(PString(Strings.At(Cur))^) + 5 <
          Sizeof(TDrawBuffer) div SizeOf(Word)) and (Col < Size.X) then
        begin
          if not ButtonState(Cur) then
            Color := CDis
          else if (Cur = Sel) and (State and sfFocused <> 0) then
            Color := CSel
          else
            Color := CNorm;
          MoveChar(B[Col], ' ', Byte(Color), Size.X - Col);
          MoveStr(B[Col], Icon, Byte(Color));
          WordRec(B[Col+2]).Lo := Byte(Marker[MultiMark(Cur) + 1]);
          MoveCStr(B[Col+5], PString(Strings.At(Cur))^, Color);

          if ShowMarkers and (State and sfFocused <> 0) and (Cur = Sel) then
          begin
            WordRec(B[Col]).Lo := Byte(SpecialChars[0]);
            WordRec(B[Column(Cur+Size.Y)-1]).Lo := Byte(SpecialChars[1]);
          end;

        end;
      end;
    end;
    WriteBuf(0, I, Size.X, 1, B);
  end;
  SetCursor(Column(Sel)+2,Row(Sel));
end;

procedure TCluster.GetData(var Rec);
begin
  Word(Rec) := Value;
end;

function TCluster.GetHelpCtx: Word;
begin
  if HelpCtx = hcNoContext then GetHelpCtx := hcNoContext
  else GetHelpCtx := HelpCtx + Sel;
end;

function TCluster.GetPalette: PPalette;
const
  P: String[Length(CCluster)] = CCluster;
begin
  GetPalette := @P;
end;

procedure TCluster.HandleEvent(var Event: TEvent);
var
  Mouse: TPoint;
  I, S: Integer;
  C: Char;

procedure MoveSel;
begin
  if I <= Strings.Count then
  begin
    Sel := S;
    MovedTo(Sel);
    DrawView;
  end;
end;

begin
  TView.HandleEvent(Event);
  if (Options and ofSelectable) = 0 then Exit;
  if Event.What = evMouseDown then
  begin
    MakeLocal(Event.Where, Mouse);
    I := FindSel(Mouse);
    if I <> -1 then if ButtonState(I) then Sel := I;
    DrawView;
    repeat
      MakeLocal(Event.Where, Mouse);
      if FindSel(Mouse) = Sel then
        ShowCursor else
        HideCursor;
    until not MouseEvent(Event,evMouseMove); {Wait for mouse up}
    ShowCursor;
    MakeLocal(Event.Where, Mouse);
    if (FindSel(Mouse) = Sel) and ButtonState(Sel) then
    begin
      Press(Sel);
      DrawView;
    end;
    ClearEvent(Event);
  end else if Event.What = evKeyDown then
  begin
    S := Sel;
    case CtrlToArrow(Event.KeyCode) of
      kbUp:
        if State and sfFocused <> 0 then
        begin
          I := 0;
          repeat
            Inc(I);
            Dec(S);
            if S < 0 then S := Strings.Count - 1;
          until ButtonState(S) or (I > Strings.Count);
          MoveSel;
          ClearEvent(Event);
        end;
      kbDown:
        if State and sfFocused <> 0 then
        begin
          I := 0;
          repeat
            Inc(I);
            Inc(S);
            if S >= Strings.Count then S := 0;
          until ButtonState(S) or (I > Strings.Count);
          MoveSel;
          ClearEvent(Event);
        end;
      kbRight:
        if State and sfFocused <> 0 then
        begin
          I := 0;
          repeat
            Inc(I);
            Inc(S,Size.Y);
            if S >= Strings.Count then
            begin
              S := (S+1) mod Size.Y;
              if S >= Strings.Count then S := 0;
            end;
          until ButtonState(S) or (I > Strings.Count);
          MoveSel;
          ClearEvent(Event);
        end;
      kbLeft:
        if State and sfFocused <> 0 then
        begin
          I := 0;
          repeat
            Inc(I);
            if S > 0 then
            begin
              Dec(S, Size.Y);
              if S < 0 then
              begin
                S := ((Strings.Count + Size.Y - 1) div Size.Y)*Size.Y + S - 1;
                if S >= Strings.Count then S := Strings.Count-1;
              end;
            end else S := Strings.Count-1;
          until ButtonState(S) or (I > Strings.Count);
          MoveSel;
          ClearEvent(Event);
        end;
    else
      begin
        for I := 0 to Strings.Count-1 do
        begin
          C := HotKey(PString(Strings.At(I))^);
          if (GetAltCode(C) = Event.KeyCode) or
             (((Owner^.Phase = phPostProcess) or (State and sfFocused <> 0))
               and (C <> #0) and (UpperCase(Event.CharCode) = UpperCase(C))) then
          begin
            if ButtonState(I) then
            begin
              if Focus then
              begin
                Sel := I;
                MovedTo(Sel);
                Press(Sel);
                DrawView;
              end;
              ClearEvent(Event);
            end;
            Exit;
          end;
        end;
        if (Event.CharCode = ' ') and (State and sfFocused <> 0)
          and ButtonState(Sel)then
        begin
          Press(Sel);
          DrawView;
          ClearEvent(Event);
        end;
      end
    end
  end;
end;

procedure TCluster.SetButtonState(AMask: Longint; Enable: Boolean); assembler;
asm
        LES     DI,Self
        MOV     AX,AMask.Word[0]
        MOV     DX,AMask.Word[2]
        TEST    Enable,0FFH
        JNZ     @@1
        NOT     AX
        NOT     DX
        AND     ES:[DI].TCluster.EnableMask.Word[0],AX
        AND     ES:[DI].TCluster.EnableMask.Word[2],DX
        JMP     @@2
@@1:    OR      ES:[DI].TCluster.EnableMask.Word[0],AX
        OR      ES:[DI].TCluster.EnableMask.Word[2],DX
@@2:    MOV     CX,ES:[DI].Strings.TCollection.Count
        CMP     CX,32
        JA      @@6
        MOV     BX,ES:[DI].TCluster.Options
        AND     BX,not ofSelectable
        MOV     AX,ES:[DI].TCluster.EnableMask.Word[0]
        MOV     DX,ES:[DI].TCluster.EnableMask.Word[2]
@@3:    SHR     DX,1
        RCR     AX,1
        JC      @@4
        LOOP    @@3
        JMP     @@5
@@4:    OR      BX,ofSelectable
@@5:    MOV     ES:[DI].TCluster.Options,BX
@@6:
end;

(*
{����� �㭪�� � ��⮬ ��ࠢ������ �����}
procedure TCluster.SetButtonState(AMask: Longint; Enable: Boolean); assembler;
asm
        LES     DI,Self
        MOV     AX,AMask.Word[0]
        MOV     DX,AMask.Word[2]
        TEST    Enable,0FFH
        JNZ     @@1
        NOT     AX
        NOT     DX
        AND     ES:[DI].TCluster.EnableMask.Word[0],AX
        AND     ES:[DI].TCluster.EnableMask.Word[2],DX
        JMP     @@2
@@1:    OR      ES:[DI].TCluster.EnableMask.Word[0],AX
        OR      ES:[DI].TCluster.EnableMask.Word[2],DX
@@2:    MOV     CX,ES:[DI].Strings.TCollection.Count
        CMP     CX,32
        JA      @@5              { change @@6 -> @@5 }
        MOV     BX,ES:[DI].TCluster.Options
        AND     BX,not ofSelectable
        MOV     AX,ES:[DI].TCluster.EnableMask.Word[0]
        MOV     DX,ES:[DI].TCluster.EnableMask.Word[2]
@@3:    SHR     DX,1
        RCR     AX,1
        JC      @@4
        LOOP    @@3
      { JMP @@5 delete this and
        change @@5-> @@4, @@6 -> @@5 }
@@4:    MOV     ES:[DI].TCluster.Options,BX
@@5:
end;
*)


procedure TCluster.SetData(var Rec);
begin
  Value := Word(Rec);
  DrawView;
end;

procedure TCluster.SetState(AState: Word; Enable: Boolean);
begin
  TView.SetState(AState, Enable);
  if AState = sfFocused then DrawView;
end;

function TCluster.Mark(Item: Integer): Boolean;
begin
  Mark := False;
end;

function TCluster.MultiMark(Item: Integer): Byte;
begin
  MultiMark := Byte(Mark(Item) = True);
end;

procedure TCluster.MovedTo(Item: Integer);
begin
end;

procedure TCluster.Press(Item: Integer);
begin
end;

procedure TCluster.Store(var S: TStream);
begin
  TView.Store(S);
  S.Write(Value, SizeOf(Longint) * 2 + SizeOf(Integer));
  Strings.Store(S);
end;

function TCluster.Column(Item: Integer): Integer;
var
  I, Col, Width, L: Integer;
begin
  if Item < Size.Y then Column := 0
  else
  begin
    Width := 0;
    Col := -6;
    for I := 0 to Item do
    begin
      if I mod Size.Y = 0 then
      begin
        Inc(Col, Width + 6);
        Width := 0;
      end;
      if I < Strings.Count then
        L := CStrLen(PString(Strings.At(I))^);
      if L > Width then Width := L;
    end;
    Column := Col;
  end;
end;


function TCluster.FindSel(P: TPoint): Integer;
var
  I, S: Integer;
  R: TRect;
begin
  GetExtent(R);
  if not R.Contains(P) then FindSel := -1
  else
  begin
    I := 0;
    while P.X >= Column(I+Size.Y) do
      Inc(I, Size.Y);
    S := I + P.Y;
    if S >= Strings.Count then
      FindSel := -1 else
      FindSel := S;
  end;
end;


function TCluster.Row(Item: Integer): Integer;
begin
  Row := Item mod Size.Y;
end;


{ TClusterLong }

constructor TClusterLong.Init(var Bounds: TRect; AStrings: PSItem);
var
  I: Integer;
  P: PSItem;
begin
  TView.Init(Bounds);
  Options := Options or (ofSelectable + ofFirstClick + ofPreProcess +
    ofPostProcess + ofVersion20);
  I := 0;
  P := AStrings;
  while P <> nil do
  begin
    Inc(I);
    P := P^.Next;
  end;
  Strings.Init(I,0);
  while AStrings <> nil do
  begin
    P := AStrings;
    Strings.AtInsert(Strings.Count, AStrings^.Value);
    AStrings := AStrings^.Next;
    Dispose(P);
  end;
  Value := 0;
  Sel := 0;
  SetCursor(2,0);
  ShowCursor;
  EnableMask := $FFFFFFFF;
end;

constructor TClusterLong.Load(var S: TStream);
begin
  TView.Load(S);
  if (Options and ofVersion) >= ofVersion20 then
  begin
    S.Read(Value, SizeOf(Longint) * 2 + SizeOf(Integer));
  end
  else
  begin
    S.Read(Value, SizeOf(Word));
    S.Read(Sel, SizeOf(Integer));
    EnableMask := $FFFFFFFF;
    Options := Options or ofVersion20;
  end;
  Strings.Load(S);
  SetButtonState(0, True);
end;

destructor TClusterLong.Done;
begin
  Strings.Done;
  TView.Done;
end;




function TClusterLong.ButtonState(Item: Integer): Boolean; assembler;
asm
        XOR     AL,AL
        MOV     CX,Item
        CMP     CX,31
        JA      @@3
        MOV     AX,1
        XOR     DX,DX
        JCXZ    @@2
@@1:    SHL     AX,1
        RCL     DX,1
        LOOP    @@1
@@2:    LES     DI,Self
        AND     AX,ES:[DI].TClusterLong.EnableMask.Word[0]
        AND     DX,ES:[DI].TClusterLong.EnableMask.Word[2]
        OR      AX,DX
        JZ      @@3
        MOV     AL,1
@@3:
end;



function TClusterLong.DataSize: Word;
begin
  DataSize := SizeOf(LongInt);
end;


procedure TClusterLong.DrawBox(const Icon: String; Marker: Char);
begin
  DrawMultiBox(Icon, {' '+}Marker);
end;

procedure TClusterLong.DrawMultiBox(const Icon, Marker: String);
var
  I,J,Cur,Col: Integer;
  CNorm, CSel, CDis, Color: Word;
  B: TDrawBuffer;
  SCOff: Byte;
begin
  CNorm := GetColor($0301);
  CSel := GetColor($0402);
  CDis := GetColor($0505);

  If Not(Options and ofSelectable <> 0) Then
    Begin

    CAse PDialog(Owner)^.Palette Of
    dpGrayDialog  :Begin CSel:=14392;  CNorm := 14392;End;
    dpCyanDialog  :Begin CSel:=30840;  CNorm := 30840;End;
    dpBlueDialog  :Begin CSel:=14392;  CNorm := 14392;End;
    Else
       Color := 2056;
    End;
    End;

  for I := 0 to Size.Y do
  begin
    MoveChar(B,' ', Byte(CNorm), Size.X);
    for J := 0 to (Strings.Count - 1) div Size.Y + 1 do
    begin
      Cur := J*Size.Y + I;
      if Cur < Strings.Count then
      begin
        Col := Column(Cur);
        if (Col + CStrLen(PString(Strings.At(Cur))^) + 5 <
          Sizeof(TDrawBuffer) div SizeOf(Word)) and (Col < Size.X) then
        begin
          if not ButtonState(Cur) then
            Color := CDis
          else if (Cur = Sel) and (State and sfFocused <> 0) then
            Color := CSel
          else
            Color := CNorm;
          MoveChar(B[Col], ' ', Byte(Color), Size.X - Col);
          MoveStr(B[Col], Icon, Byte(Color));
          WordRec(B[Col+2]).Lo := Byte(Marker[MultiMark(Cur) + 1]);
          MoveCStr(B[Col+5], PString(Strings.At(Cur))^, Color);

          if ShowMarkers and (State and sfFocused <> 0) and (Cur = Sel) then
          begin
            WordRec(B[Col]).Lo := Byte(SpecialChars[0]);
            WordRec(B[Column(Cur+Size.Y)-1]).Lo := Byte(SpecialChars[1]);
          end;

        end;
      end;
    end;
    WriteBuf(0, I, Size.X, 1, B);
  end;
  SetCursor(Column(Sel)+2,Row(Sel));
end;



procedure TClusterLong.GetData(var Rec);
begin
  LongInt(Rec) := Value;
end;


function TClusterLong.GetHelpCtx: Word;
begin
  if HelpCtx = hcNoContext then GetHelpCtx := hcNoContext
  else GetHelpCtx := HelpCtx + Sel;
end;

function TClusterLong.GetPalette: PPalette;
const
  P: String[Length(CCluster)] = CCluster;
begin
  GetPalette := @P;
end;

procedure TClusterLong.HandleEvent(var Event: TEvent);
var
  Mouse: TPoint;
  I, S: Integer;
  C: Char;

procedure MoveSel;
begin
  if I <= Strings.Count then
  begin
    Sel := S;
    MovedTo(Sel);
    DrawView;
  end;
end;

begin
  TView.HandleEvent(Event);
  if (Options and ofSelectable) = 0 then Exit;
  if Event.What = evMouseDown then
  begin
    MakeLocal(Event.Where, Mouse);
    I := FindSel(Mouse);
    if I <> -1 then if ButtonState(I) then Sel := I;
    DrawView;
    repeat
      MakeLocal(Event.Where, Mouse);
      if FindSel(Mouse) = Sel then
        ShowCursor else
        HideCursor;
    until not MouseEvent(Event,evMouseMove); {Wait for mouse up}
    ShowCursor;
    MakeLocal(Event.Where, Mouse);
    if (FindSel(Mouse) = Sel) and ButtonState(Sel) then
    begin
      Press(Sel);
      DrawView;
    end;
    ClearEvent(Event);
  end else if Event.What = evKeyDown then
  begin
    S := Sel;
    case CtrlToArrow(Event.KeyCode) of
      kbUp:
        if State and sfFocused <> 0 then
        begin
          I := 0;
          repeat
            Inc(I);
            Dec(S);
            if S < 0 then S := Strings.Count - 1;
          until ButtonState(S) or (I > Strings.Count);
          MoveSel;
          ClearEvent(Event);
        end;
      kbDown:
        if State and sfFocused <> 0 then
        begin
          I := 0;
          repeat
            Inc(I);
            Inc(S);
            if S >= Strings.Count then S := 0;
          until ButtonState(S) or (I > Strings.Count);
          MoveSel;
          ClearEvent(Event);
        end;
      kbRight:
        if State and sfFocused <> 0 then
        begin
          I := 0;
          repeat
            Inc(I);
            Inc(S,Size.Y);
            if S >= Strings.Count then
            begin
              S := (S+1) mod Size.Y;
              if S >= Strings.Count then S := 0;
            end;
          until ButtonState(S) or (I > Strings.Count);
          MoveSel;
          ClearEvent(Event);
        end;
      kbLeft:
        if State and sfFocused <> 0 then
        begin
          I := 0;
          repeat
            Inc(I);
            if S > 0 then
            begin
              Dec(S, Size.Y);
              if S < 0 then
              begin
                S := ((Strings.Count + Size.Y - 1) div Size.Y)*Size.Y + S - 1;
                if S >= Strings.Count then S := Strings.Count-1;
              end;
            end else S := Strings.Count-1;
          until ButtonState(S) or (I > Strings.Count);
          MoveSel;
          ClearEvent(Event);
        end;
    else
      begin
        for I := 0 to Strings.Count-1 do
        begin
          C := HotKey(PString(Strings.At(I))^);
          if (GetAltCode(C) = Event.KeyCode) or
             (((Owner^.Phase = phPostProcess) or (State and sfFocused <> 0))
               and (C <> #0) and (UpperCase(Event.CharCode) = UpperCase(C))) then
          begin
            if ButtonState(I) then
            begin
              if Focus then
              begin
                Sel := I;
                MovedTo(Sel);
                Press(Sel);
                DrawView;
              end;
              ClearEvent(Event);
            end;
            Exit;
          end;
        end;
        if (Event.CharCode = ' ') and (State and sfFocused <> 0)
          and ButtonState(Sel)then
        begin
          Press(Sel);
          DrawView;
          ClearEvent(Event);
        end;
      end
    end
  end;
end;

procedure TClusterLong.SetButtonState(AMask: Longint; Enable: Boolean); assembler;
asm
        LES     DI,Self
        MOV     AX,AMask.Word[0]
        MOV     DX,AMask.Word[2]
        TEST    Enable,0FFH
        JNZ     @@1
        NOT     AX
        NOT     DX
        AND     ES:[DI].TClusterLong.EnableMask.Word[0],AX
        AND     ES:[DI].TClusterLong.EnableMask.Word[2],DX
        JMP     @@2
@@1:    OR      ES:[DI].TClusterLong.EnableMask.Word[0],AX
        OR      ES:[DI].TClusterLong.EnableMask.Word[2],DX
@@2:    MOV     CX,ES:[DI].Strings.TCollection.Count
        CMP     CX,32
        JA      @@6
        MOV     BX,ES:[DI].TClusterLong.Options
        AND     BX,not ofSelectable
        MOV     AX,ES:[DI].TClusterLong.EnableMask.Word[0]
        MOV     DX,ES:[DI].TClusterLong.EnableMask.Word[2]
@@3:    SHR     DX,1
        RCR     AX,1
        JC      @@4
        LOOP    @@3
        JMP     @@5
@@4:    OR      BX,ofSelectable
@@5:    MOV     ES:[DI].TClusterLong.Options,BX
@@6:
end;

(*
{����� �㭪�� � ��⮬ ��ࠢ������ �����}
procedure TClusterLong.SetButtonState(AMask: Longint; Enable: Boolean); assembler;
asm
        LES     DI,Self
        MOV     AX,AMask.Word[0]
        MOV     DX,AMask.Word[2]
        TEST    Enable,0FFH
        JNZ     @@1
        NOT     AX
        NOT     DX
        AND     ES:[DI].TClusterLong.EnableMask.Word[0],AX
        AND     ES:[DI].TClusterLong.EnableMask.Word[2],DX
        JMP     @@2
@@1:    OR      ES:[DI].TClusterLong.EnableMask.Word[0],AX
        OR      ES:[DI].TClusterLong.EnableMask.Word[2],DX
@@2:    MOV     CX,ES:[DI].Strings.TCollection.Count
        CMP     CX,32
        JA      @@5              { change @@6 -> @@5 }
        MOV     BX,ES:[DI].TClusterLong.Options
        AND     BX,not ofSelectable
        MOV     AX,ES:[DI].TClusterLong.EnableMask.Word[0]
        MOV     DX,ES:[DI].TClusterLong.EnableMask.Word[2]
@@3:    SHR     DX,1
        RCR     AX,1
        JC      @@4
        LOOP    @@3
      { JMP @@5 delete this and
        change @@5-> @@4, @@6 -> @@5 }
@@4:    MOV     ES:[DI].TClusterLong.Options,BX
@@5:
end;
*)


procedure TClusterLong.SetData(var Rec);
begin
  Value := LongInt(Rec);
  DrawView;
end;

procedure TClusterLong.SetState(AState: Word; Enable: Boolean);
begin
  TView.SetState(AState, Enable);
  if AState = sfFocused then DrawView;
end;

function TClusterLong.Mark(Item: Integer): Boolean;
begin
  Mark := False;
end;

function TClusterLong.MultiMark(Item: Integer): Byte;
begin
  MultiMark := Byte(Mark(Item) = True);
end;

procedure TClusterLong.MovedTo(Item: Integer);
begin
end;

procedure TClusterLong.Press(Item: Integer);
begin
end;

procedure TClusterLong.Store(var S: TStream);
begin
  TView.Store(S);
  S.Write(Value, SizeOf(Longint) * 2 + SizeOf(Integer));
  Strings.Store(S);
end;

function TClusterLong.Column(Item: Integer): Integer;
var
  I, Col, Width, L: Integer;
begin
  if Item < Size.Y then Column := 0
  else
  begin
    Width := 0;
    Col := -6;
    for I := 0 to Item do
    begin
      if I mod Size.Y = 0 then
      begin
        Inc(Col, Width + 6);
        Width := 0;
      end;
      if I < Strings.Count then
        L := CStrLen(PString(Strings.At(I))^);
      if L > Width then Width := L;
    end;
    Column := Col;
  end;
end;


function TClusterLong.FindSel(P: TPoint): Integer;
var
  I, S: Integer;
  R: TRect;
begin
  GetExtent(R);
  if not R.Contains(P) then FindSel := -1
  else
  begin
    I := 0;
    while P.X >= Column(I+Size.Y) do
      Inc(I, Size.Y);
    S := I + P.Y;
    if S >= Strings.Count then
      FindSel := -1 else
      FindSel := S;
  end;
end;


function TClusterLong.Row(Item: Integer): Integer;
begin
  Row := Item mod Size.Y;
end;




{ TRadioButtons }

procedure TRadioButtons.Draw;
const
  Button = ' ( )';
begin
  DrawMultiBox(Button, #32#7);
end;

function TRadioButtons.Mark(Item: Integer): Boolean;
begin
  Mark := Item = Value;
end;

procedure TRadioButtons.Press(Item: Integer);
begin
  Value := Item;
end;

procedure TRadioButtons.MovedTo(Item: Integer);
begin
  Value := Item;
end;

procedure TRadioButtons.SetData(var Rec);
begin
  TCluster.SetData(Rec);
  Sel := Integer(Value);
end;


procedure TMyRadioButtons.Draw;
const
  Button = ' ( )';
begin
  DrawMultiBox(Button, #32#7);
end;

function TMyRadioButtons.Mark(Item: Integer): Boolean;
begin
  Mark := Item = Value;
end;

procedure TMYRadioButtons.Press(Item: Integer);
begin
  Value := Item;
end;

procedure TMyRadioButtons.MovedTo(Item: Integer);
begin
  Value := Item;
end;

procedure TMyRadioButtons.SetData(var Rec);
begin
  TCluster.SetData(Rec);
  Sel := Integer(Value);
end;


{ TCheckBoxes }

procedure TCheckBoxes.Draw;
const
  Button = ' [ ] ';
begin
  DrawMultiBox(Button, ' X'{' '+#251});
end;

function TCheckBoxes.Mark(Item: Integer): Boolean;
begin
  Mark := Value and (1 shl Item) <> 0;
end;

procedure TCheckBoxes.Press(Item: Integer);
begin
  Value := Value xor (1 shl Item);
end;


{ TMyCheckBoxes }

procedure TMyCheckBoxes.Draw;
const
  Button = ' [ ] ';
begin
  DrawMultiBox(Button, ' X'{' '+#251});
end;

function TMyCheckBoxes.Mark(Item: Integer): Boolean;
begin
  Mark := Value and (1 shl Item) <> 0;
end;

procedure TMyCheckBoxes.Press(Item: Integer);
begin
  Value := Value xor (1 shl Item);
end;


{ TCheckBoxes }

procedure TCheckBoxesLong.Draw;
const
  Button = ' [ ] ';
begin
  DrawMultiBox(Button, ' X'{' '+#251});
end;

function TCheckBoxesLong.Mark(Item: Integer): Boolean;
begin
  Mark := Value and (1 shl Item) <> 0;
end;

procedure TCheckBoxesLong.Press(Item: Integer);
begin
  Value := Value xor (1 shl Item);
end;

{ TMultiCheckBoxes }

constructor TMultiCheckBoxes.Init(var Bounds: TRect; AStrings: PSItem;
  ASelRange: Byte; AFlags: Word; const AStates: String);
begin
  Inherited Init(Bounds, AStrings);
  SelRange := ASelRange;
  Flags := AFlags;
  States := NewStr(AStates);
end;

constructor TMultiCheckBoxes.Load(var S: TStream);
begin
  TCluster.Load(S);
  S.Read(SelRange, SizeOf(Byte));
  S.Read(Flags, SizeOf(Word));
  States := S.ReadStr;
end;

destructor TMultiCheckBoxes.Done;
begin
  DisposeStr(States);
  TCluster.Done;
end;

procedure TMultiCheckBoxes.Draw;
const
  Button = ' [ ] ';
begin
  DrawMultiBox(Button, States^);
end;

function TMultiCheckBoxes.DataSize: Word;
begin
  DataSize := SizeOf(Longint);
end;

function TMultiCheckBoxes.MultiMark(Item: Integer): Byte;
begin
  MultiMark := (Value shr (Word(Item) * WordRec(Flags).Hi))
    and WordRec(Flags).Lo;
end;

procedure TMultiCheckBoxes.GetData(var Rec);
begin
  Longint(Rec) := Value;
end;

procedure TMultiCheckBoxes.Press(Item: Integer);
var
  CurState: ShortInt;
begin
  CurState := (Value shr (Word(Item) * WordRec(Flags).Hi))
    and WordRec(Flags).Lo;

  Dec(CurState);
  if (CurState >= SelRange) or (CurState < 0) then
    CurState := SelRange - 1;
  Value := (Value and not (LongInt(WordRec(Flags).Lo)
    shl (Word(Item) * WordRec(Flags).Hi))) or
    (LongInt(CurState) shl (Word(Item) * WordRec(Flags).Hi));
end;

procedure TMultiCheckBoxes.SetData(var Rec);
begin
  Value := Longint(Rec);
  DrawView;
end;

procedure TMultiCheckBoxes.Store(var S: TStream);
begin
  TCluster.Store(S);
  S.Write(SelRange, SizeOf(Byte));
  S.Write(Flags, SizeOf(Word));
  S.WriteStr(States);
end;

{ TListBox }

type
  TListBoxRec = record
    List: PCollection;
    Selection: Word;
  end;

constructor TListBox.Init(var Bounds: TRect; ANumCols: Word;
  AScrollBar: PScrollBar);
begin
  TListViewer.Init(Bounds, ANumCols, nil, AScrollBar);
  List := nil;
  SetRange(0);
end;

constructor TListBox.Load(var S: TStream);
begin
  TListViewer.Load(S);
  List := PCollection(S.Get);
end;

function TListBox.DataSize: Word;
begin
  DataSize := SizeOf(TListBoxRec);
end;

procedure TListBox.GetData(var Rec);
begin
  TListBoxRec(Rec).List := List;
  TListBoxRec(Rec).Selection := Focused;
end;

{����� �㭪�� � ��⮬ �����}
function TListBox.GetText(Item: Integer; MaxLen: Integer): String;
var S : PString;
begin
{  GetText := '';
  if (List <> nil)
     then begin
            S := PString(List^.At(Item));
            if (S <> nil)
               then GetText := S^;
          end;}
  GetText := '';
  if (List <> nil) Then
  If (Item < List^.Count) Then
          begin
            S := PString(List^.At(Item));
            if (S <> nil)
               then GetText := S^;
          end;

end;


{
function TListBox.GetText(Item: Integer; MaxLen: Integer): String;
begin
  if (List <> nil) then GetText := PString(List^.At(Item))^
  else GetText := '';
end;
}

procedure TListBox.NewList(AList: PCollection);
begin
  if List <> nil then Dispose(List, Done);
  List := AList;

  if AList <> nil then
      SetRange(AList^.Count)
  else
      SetRange(0);
  if Range > 0 then FocusItem(0);
  DrawView;
end;

procedure TListBox.SetData(var Rec);
begin
  NewList(TListBoxRec(Rec).List);
  FocusItem(TListBoxRec(Rec).Selection);
  DrawView;
end;

procedure TListBox.Store(var S: TStream);
begin
  TListViewer.Store(S);
  S.Put(List);
end;


constructor TListBoxNew.Init(var Bounds: TRect; ANumCols: Word;
  BScrollBar,AScrollBar: PScrollBar);
begin
  TListViewer.Init(Bounds, ANumCols, BScrollBar, AScrollBar);
  List := nil;
  SetRange(0);
end;

constructor TListBoxNew.Load(var S: TStream);
begin
  TListViewer.Load(S);
  List := PCollection(S.Get);
end;

function TListBoxNew.DataSize: Word;
begin
  DataSize := SizeOf(TListBoxRec);
end;

procedure TListBoxNew.GetData(var Rec);
begin
  TListBoxRec(Rec).List := List;
  TListBoxRec(Rec).Selection := Focused;
end;

{����� �㭪�� � ��⮬ �����}
function TListBoxNew.GetText(Item: Integer; MaxLen: Integer): String;
var S : PString;
begin
{  GetText := '';
  if (List <> nil)
     then begin
            S := PString(List^.At(Item));
            if (S <> nil)
               then GetText := S^;
          end;}
  GetText := '';
  if (List <> nil) Then
  If (Item < List^.Count) Then
          begin
            S := PString(List^.At(Item));
            if (S <> nil)
               then GetText := S^;
          end;

end;


{
function TListBoxNew.GetText(Item: Integer; MaxLen: Integer): String;
begin
  if (List <> nil) then GetText := PString(List^.At(Item))^
  else GetText := '';
end;
}




procedure TListBoxNew.NewList(AList: PCollection);
begin
  if List <> nil then Dispose(List, Done);
  List := AList;

  if AList <> nil then
      SetRange(AList^.Count)
  else
      SetRange(0);
  if Range > 0 then FocusItem(0);

  if Range > 1 then FocusItem(0);
  HScrollBar^.SetRange(1, 255 + 3);


  DrawView;
end;

procedure TListBoxNew.SetData(var Rec);
begin
  NewList(TListBoxRec(Rec).List);
  FocusItem(TListBoxRec(Rec).Selection);
  DrawView;
end;

procedure TListBoxNew.Store(var S: TStream);
begin
  TListViewer.Store(S);
  S.Put(List);
end;











{ TStaticText }
constructor TStaticText.Init(var Bounds: TRect; const AText: TMyString);
begin
  TView.Init(Bounds);
  Text := NewStr(AText);
end;

constructor TStaticText.Load(var S: TStream);
begin
  TView.Load(S);
  Text := S.ReadStr;
end;

destructor TStaticText.Done;
begin
  DisposeStr(Text);
  TView.Done;
end;

procedure TStaticText.Draw;
var
  Color: Byte;
  Center: Boolean;
  I, J, L, P, Y: Integer;
  B: TDrawBuffer;
  S: String;
begin
  Color := GetColor(1);
  GetText(S);
  L := Length(S);
  P := 1;
  Y := 0;
  Center := False;
  while Y < Size.Y do
  begin
    MoveChar(B, ' ', Color, Size.X);
    if P <= L then
    begin
      if S[P] = #3 then
      begin
        Center := True;
        Inc(P);
      end;
      I := P;
      repeat
        J := P;
        while (P <= L) and (S[P] = ' ') do Inc(P);
        while (P <= L) and (S[P] <> ' ') and (S[P] <> #13) do Inc(P);
      until (P > L) or (P >= I + Size.X) or (S[P] = #13);
      if P > I + Size.X then
        if J > I then P := J else P := I + Size.X;
      if Center then J := (Size.X - P + I) div 2 else J := 0;
      MoveBuf(B[J], S[I], Color, P - I);
      while (P <= L) and (S[P] = ' ') do Inc(P);
      if (P <= L) and (S[P] = #13) then
      begin
        Center := False;
        Inc(P);
        if (P <= L) and (S[P] = #10) then Inc(P);
      end;
    end;
    WriteLine(0, Y, Size.X, 1, B);
    Inc(Y);
  end;
end;



function TStaticText.GetPalette: PPalette;
const
  P: String[Length(CStaticText)] = CStaticText;
begin
  GetPalette := @P;
end;

procedure TStaticText.GetText(var S: String);
begin
  if Text <> nil then S := Text^
  else S := '';
end;

procedure TStaticText.Store(var S: TStream);
begin
  TView.Store(S);
  S.WriteStr(Text);
end;



{ TParamText }

constructor TParamText.Init(var Bounds: TRect; const AText: String;
  AParamCount: Integer);
begin
  TStaticText.Init(Bounds, AText);
  ParamCount := AParamCount;
end;

constructor TParamText.Load(var S: TStream);
begin
  TStaticText.Load(S);
  S.Read(ParamCount, SizeOf(Integer));
end;

function TParamText.DataSize: Word;
begin
  DataSize := ParamCount * SizeOf(Longint);
end;

procedure TParamText.GetText(var S: String);
begin
  if Text <> nil then FormatStr(S, Text^, ParamList^)
  else S := '';
end;

procedure TParamText.SetData(var Rec);
begin
  ParamList := @Rec;
  DrawView;
end;

procedure TParamText.Store(var S: TStream);
begin
  TStaticText.Store(S);
  S.Write(ParamCount, SizeOf(Integer));
end;

{ TLabel }

constructor TLabel.Init(var Bounds: TRect; const AText: String; ALink: PView);
begin
  TStaticText.Init(Bounds, AText);
  Link := ALink;
  Options := Options or (ofPreProcess + ofPostProcess);
  EventMask := EventMask or evBroadcast;
end;

constructor TLabel.Load(var S: TStream);
begin
  TStaticText.Load(S);
  GetPeerViewPtr(S, Link);
end;

procedure TLabel.Draw;
var
  Color: Word;
  B: TDrawBuffer;
  SCOff: Byte;
begin
  If (Link <> nil) and (Link^.Options and ofSelectable <> 0) Then
  Begin
  if Light then
  begin
    Color := GetColor($0402);
    SCOff := 0;
  end
  else
  begin
    Color := GetColor($0301);
    SCOff := 4;
  end;
  End
  Else
   Begin              {772}
    CAse PDialog(Owner)^.Palette Of
    dpGrayDialog  :       Color := 30840;
    dpCyanDialog  :       Color := 14392;
    dpBlueDialog  :       Color := 6425;
    Else
       Color := 2056;
    End;
    SCOff := 6;
    {While Pos('~',Text^)>0 Do Delete(Text^,Pos('~',Text^),1);}
   End;
  MoveChar(B[0], ' ', Byte(Color), Size.X);
  if Text <> nil then MoveCStr(B[1], Text^, Color);
  if ShowMarkers then WordRec(B[0]).Lo := Byte(SpecialChars[SCOff]);
  WriteLine(0, 0, Size.X, 1, B);
end;

function TLabel.GetPalette: PPalette;
const
  P: String[Length(CLabel)] = CLabel;
begin
  GetPalette := @P;
end;

procedure TLabel.HandleEvent(var Event: TEvent);
var
  C: Char;

  procedure FocusLink;
  begin
    if (Link <> nil) and (Link^.Options and ofSelectable <> 0) then
      Link^.Focus;
    ClearEvent(Event);
  end;

begin
  TStaticText.HandleEvent(Event);
  if Event.What = evMouseDown then FocusLink
  else if Event.What = evKeyDown then
  begin
    C := HotKey(Text^);
    if (GetAltCode(C) = Event.KeyCode) or
       ((C <> #0) and (Owner^.Phase = phPostProcess)and
        (UpperCase(Event.CharCode) = C)) then
                                           FocusLink
  end
  else if Event.What = evBroadcast then
    if ((Event.Command = cmReceivedFocus) or
       (Event.Command = cmReleasedFocus)) and
       (Link <> nil) then
    begin
      Light := Link^.State and sfFocused <> 0;
      DrawView;
    end;
end;

procedure TLabel.Store(var S: TStream);
begin
  TStaticText.Store(S);
  PutPeerViewPtr(S, Link);
end;

{ THistoryViewer }

constructor THistoryViewer.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PScrollBar; AHistoryId: Word);
begin
  If AHistoryId in [99,105] Then
  TListViewer.Init(Bounds, 4 {1} ,AHScrollBar, AVScrollBar)
  Else
  Begin
   If AHistoryId In [103] Then
   TListViewer.Init(Bounds, 3 {1} ,AHScrollBar, AVScrollBar)
  Else
   Begin
    If AHistoryId In [10,11,12,101,102] Then
    TListViewer.Init(Bounds, 2 {1} ,AHScrollBar, AVScrollBar)
    Else
    TListViewer.Init(Bounds, 1 {1} ,AHScrollBar, AVScrollBar);
   End;
  End;
  HistoryId := AHistoryId;
  SetRange(HistoryCount(AHistoryId));
  if Range > 1 then FocusItem(0);
  HScrollBar^.SetRange(1, HistoryWidth-Size.X + 3);
end;

function THistoryViewer.GetPalette: PPalette;
const
  P: String[Length(CHistoryViewer)] = CHistoryViewer;
begin
  GetPalette := @P;
end;

function THistoryViewer.GetText(Item: Integer; MaxLen: Integer): String;
begin
  GetText := HistoryStr(HistoryId, Item);
end;

procedure THistoryViewer.HandleEvent(var Event: TEvent);
begin
  if ((Event.What = evMouseDown) and (Event.Double)) or
     ((Event.What = evKeyDown) and (Event.KeyCode = kbEnter)) then
  begin
    EndModal(cmOk);
    ClearEvent(Event);
  end
   else if ((Event.What = evKeyDown) and (Event.KeyCode = kbEsc)) or
    ((Event.What = evCommand) and (Event.Command = cmCancel)) then
  begin
    EndModal(cmCancel);
    ClearEvent(Event);
  end else
  TListViewer.HandleEvent(Event);
end;

function THistoryViewer.HistoryWidth: Integer;
var
  Width, T, Count, I: Integer;
begin
  Width := 0;
  Count := HistoryCount(HistoryId);
  for I := 0 to Count-1 do
  begin
    T := Length(HistoryStr(HistoryId, I));
    if T > Width then Width := T;
  end;
  HistoryWidth := Width;
end;

{ THistoryWindow }

constructor THistoryWindow.Init(var Bounds: TRect; HistoryId: Word);
Var S : String;
begin
  s:='������ ��ਠ��';
  TWindow.Init(Bounds,S, wnNoNumber);
  Flags := wfClose;
  InitViewer(HistoryId);
end;

function THistoryWindow.GetPalette: PPalette;
const
  P: String[Length(CHistoryWindow)] = CHistoryWindow;
begin
  GetPalette := @P;
end;

function THistoryWindow.GetSelection: String;
begin
  GetSelection := Viewer^.GetText(Viewer^.Focused,255); {!!!]}
end;

procedure THistoryWindow.InitViewer(HistoryId: Word);
var
  R: TRect;
begin

  GetExtent(R);
  R.Grow(-1,-1);

  Viewer := New(PHistoryViewer, Init(R,{Nil,}
    StandardScrollBar(sbHorizontal + sbHandleKeyboard),
    StandardScrollBar(sbVertical + sbHandleKeyboard),
    HistoryId));
  Insert(Viewer);
end;

{ THistory }

constructor THistory.Init(var Bounds: TRect; ALink: PInputLine;
  AHistoryId: Word);
begin
  TView.Init(Bounds);
  Options := Options or ofPostProcess;
  EventMask := EventMask or evBroadcast;
  Link := ALink;
  HistoryId := AHistoryId;
end;

constructor THistory.Load(var S: TStream);
begin
  TView.Load(S);
  GetPeerViewPtr(S, Link);
  S.Read(HistoryId, SizeOf(Word));
end;

procedure THistory.Draw;
var
  B: TDrawBuffer;
begin
  MoveCStr(B, #222'~'#25'~'#221, GetColor($0102));
  WriteLine(0,0, Size.X, Size.Y, B);{!!!}
end;

function THistory.GetPalette: PPalette;
const
  P: String[Length(CHistory)] = CHistory;
begin
  GetPalette := @P;
end;

procedure THistory.HandleEvent(var Event: TEvent);
Label ttt;
var
  HistoryWindow: PHistoryWindow;
  R,P: TRect;
  C: Word;
  Rslt: String;
  ls,Code : Integer;
  lc : Char;
begin
TView.HandleEvent(Event);
if (Event.What = evMouseDown) or
   ((Event.What = evKeyDown) and (CtrlToArrow(Event.KeyCode) = kbPgDn{kbDown}) and
   (Link^.State and sfFocused <> 0)) then
begin
FindSymbol := 0;
FindStrok[0] :=#0;
if not Link^.Focus then
  begin
   ClearEvent(Event);
   Exit;
  end;                 {���� � �ਭ� ���� ���ਨ}
 FindStrok[0] :=#0;
 FindSymbol := 0;
 Link^.GetBounds(R);
 Link^.GetData(RSLT);
 UpStr(Rslt);
 FindStrok:=Rslt;
 FindSymbol:=Ord(Rslt[0]);
 Event.CharCode:=#255;
 Event.What:=evKeyDown;
 PutEvent(Event);

 {����� ��࠭���� ⮫쪮 ��� ��������,��� ��⠫��� ���⪠}
 If Not(HistoryId=55) Then ClearHistory;

 RecordHistory(Link^.Data^);
 Link^.GetBounds(R);
 Dec(R.A.X,70);
 Inc(R.B.X,70); Inc(R.B.Y,70);Dec(R.A.Y,70);
 Owner^.GetExtent(P);
 R.Intersect(P);
     HistoryWindow := InitHistoryWindow(R);
     if HistoryWindow <> nil then
     begin
      C := Owner^.ExecView(HistoryWindow);
      if C = cmOk then
      begin
{}      Rslt := HistoryWindow^.GetSelection;
        c:=Pos('�',RSLT);
        If c>0 Then Rslt[0]:=Chr(C-1);
{        Else RSLT[0]:=Chr(CKTO);}
        DelspaceRight(Rslt);
        if Length(Rslt) > Link^.MaxLen then Rslt[0] := Char(Link^.MaxLen);
        Link^.Data^ := Rslt;
        Link^.SelectAll(True);{True}
        Link^.DrawView;
      end;
      FindSymbol := 0;
      FindStrok[0] :=#0;
      Dispose(HistoryWindow, Done);
     End;{<> nil}
     ClearEvent(Event);
   End
  else;

  if (Event.What = evBroadcast) then
    if ((Event.Command = cmReleasedFocus) and (Event.InfoPtr = Link))
      or (Event.Command = cmRecordHistory)  then
      If (HistoryID=55) Then
         RecordHistory(Link^.Data^);

End;

function THistory.InitHistoryWindow(var Bounds: TRect): PHistoryWindow;
var
  P: PHistoryWindow;
begin
  P := New(PHistoryWindow, Init(Bounds, HistoryId));
  P^.HelpCtx := $E006;{Link^.HelpCtx;}
  InitHistoryWindow := P;
end;



procedure THistory.RecordHistory(const S: String);
Var i : LongInt;
    st : String;
    f : Text;
    c,c1 : Word;
    fl : File;
    Count : Word;
    P : PBox;
    PostElement : PBufPostType;
    KSertifElement : PBufKSertifType;
    MarkaElement : PBufMarkaType;
    BankElement  : PBufBankType;
    SpecMarkaElement : PBufSpecMarkaType;
    FirmaElement : PBufFirmaPostType;
    ClassElement : PBufClassificatorBuchType;
    NGTDElement  : PBufNGTDType;
    MeraElement  : PBufMeraType;
    R : TRect;

begin
Case HistoryID Of
10:{Razdel}
   Begin
    For i := Razdel^.List^.Count-1 DownTo 0 Do
     Begin
      st:=Razdel^.GetText(i,Razdel^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;
   End;

11:{MAkeList}
   Begin
    For i := MakeList^.List^.Count-1 DownTo 0 Do
     Begin
      st:=MakeList^.GetText(i,MakeList^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;
   End;

12:{Client}
   Begin
    For i := Client^.List^.Count-1 DownTo 0 Do
     Begin
      st:=Client^.GetText(i,Client^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;
   End;

13:{Baz}
   Begin
    For i := Baz^.List^.Count-1 DownTo 0 Do
     Begin
      st:=Copy(Baz^.GetText(i,Baz^.List^.Count-1),1,1+CName+1+CArtikul);
      HistoryAdd(HistoryId, st);
     End;
   End;

14:{SertifList}
   Begin
    For i := SertifList^.List^.Count-1 DownTo 0 Do
     Begin
      st:=Copy(SertifList^.GetText(i,SertifList^.List^.Count-1),1,1+CName+1+CName+1+CArtikul);
      System.Delete(st,1+CNAme,1+CName);
      HistoryAdd(HistoryId, st);
     End;
   End;

15:{Baz}
   Begin
      st:='\\Second\hp  ��⤥� ��室�';
      HistoryAdd(HistoryId, st);
      st:='\\Shef1\Hp   ��ணࠬ�����';
      HistoryAdd(HistoryId, st);
      st:='\\Operator\Hp��࣮�� ���';
      HistoryAdd(HistoryId, st);
   End;

16:{Baz}
   Begin
      st:='@!RCI3!������� �ਭ��';
      HistoryAdd(HistoryId, st);
      {st:=#27+#69+#27+#38+#108+#54+#68+#27+#38+#107+#52+#83;}
       st:=#27+#69+#27+#38+#108+#55+#67+#27+#38+#107+#52+#83+'  ������� �ਭ��';{E&l7C&k4S1}
	  {E&l7C&k4S1}
      HistoryAdd(HistoryId, st);
   End;

17:{Region}
   Begin
    For i := RegionList^.List^.Count-1 DownTo 0 Do
     Begin
      st:=RegionList^.GetText(i,RegionList^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;
   End;

18:{Group}
   Begin
    For i := GroupList^.List^.Count-1 DownTo 0 Do
     Begin
      st:=GroupList^.GetText(i,GroupList^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;
   End;

19:{Route}
   Begin
    For i := RouteList^.List^.Count-1 DownTo 0 Do
     Begin
      st:=RouteList^.GetText(i,RouteList^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;
   End;


 {��������}
55: HistoryAdd(HistoryId, s);


99 :{��࠭�-�ந�����⥫�}
    Begin
    Assign(fl,Path^.Dat.ToSPR+'lands.db');
    c:=IOResult;
    Reset(fl,SizeOf(PostType));
    c:=IOResult;
    If c<>0 Then Exit;

R.Assign(0, 0, 0, 0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));

While Not(Eof(fl)) Do
 Begin
    New(PostElement,Init);
    ReadBufPost(fl,PostElement,Count);

For c1:=1 To Count Do
Begin
  If PostElement^.Point.Dat[c1].Employ Then
   Begin
    {Format (PostElement^.Point.Dat[c1].Post,CPost);}
    P^.List^.Insert(NewStr(PostElement^.Point.Dat[c1].Post{+'�'+PostElement^.Point.Dat[c1].Kod}));
    P^.SetRange(P^.List^.Count);
   End;
End;{For}
  Dispose(PostElement,Done);
 End;{While}
System.Close(fl);

    For i := P^.List^.Count-1 DownTo 0 Do
     Begin
      st:=P^.GetText(i,P^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;

Dispose(P,Done);

    End;
100 :{��� �뤠� ���䨪��}
         Begin
    Assign(fl,Path^.Dat.ToSPR+'ksertif.db');
    c:=IOResult;
    Reset(fl,SizeOf(KSertifType));
    c:=IOResult;
    If c<>0 Then Exit;

R.Assign(0, 0, 0, 0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));

While Not(Eof(fl)) Do
 Begin
    New(KSertifElement,Init);
    ReadBufKSertif(fl,KSertifElement,Count);

For c1:=1 To Count Do
Begin
  If KSertifElement^.Point.Dat[c1].Employ Then
   Begin
    {Format (KSertifElement^.Point.Dat[c1].KSertif,CKSertif);}
    P^.List^.Insert(NewStr(KSertifElement^.Point.Dat[c1].KSertif{+'�'+KSertifElement^.Point.Dat[c1].Kod}));
    P^.SetRange(P^.List^.Count);
   End;
End;{For}
  Dispose(KSertifElement,Done);
 End;{While}
System.Close(fl);

    For i := P^.List^.Count-1 DownTo 0 Do
     Begin
      st:=P^.GetText(i,P^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;

Dispose(P,Done);

    End;
101 :{��樧��� ��ઠ}
         Begin
    Assign(fl,Path^.Dat.ToSPR+'marka.db');
    c:=IOResult;
    Reset(fl,SizeOf(MarkaType));
    c:=IOResult;
    If c<>0 Then Exit;

R.Assign(0, 0, 0, 0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));

While Not(Eof(fl)) Do
 Begin
    New(MarkaElement,Init);
    ReadBufMarka(fl,MarkaElement,Count);

For c1:=1 To Count Do
Begin
  If MarkaElement^.Point.Dat[c1].Employ Then
   Begin
    {Format (MarkaElement^.Point.Dat[c1].Marka,CMarka);}
    P^.List^.Insert(NewStr(MarkaElement^.Point.Dat[c1].Marka{+'�'+MarkaElement^.Point.Dat[c1].Kod}));
    P^.SetRange(P^.List^.Count);
   End;
End;{For}
  Dispose(MarkaElement,Done);
 End;{While}
System.Close(fl);

    For i := P^.List^.Count-1 DownTo 0 Do
     Begin
      st:=P^.GetText(i,P^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;

Dispose(P,Done);

         End;
102 :{��}
         Begin
    Assign(fl,Path^.Dat.ToSPR+'ngtd.db');
    c:=IOResult;
    Reset(fl,SizeOf(NGTDType));
    c:=IOResult;
    If c<>0 Then Exit;

R.Assign(0, 0, 0, 0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));

While Not(Eof(fl)) Do
 Begin
    New(NGTDElement,Init);
    ReadBufNGTD(fl,NGTDElement,Count);

For c1:=1 To Count Do
Begin
  If NGTDElement^.Point.Dat[c1].Employ Then
   Begin
{    Format (NGTDElement^.Point.Dat[c1].NGTD,CNGTD);}
    P^.List^.Insert(NewStr(NGTDElement^.Point.Dat[c1].NGTD{+'�'+NGTDElement^.Point.Dat[c1].Kod}));
    P^.SetRange(P^.List^.Count);
   End;
End;{For}
  Dispose(NGTDElement,Done);
 End;{While}
System.Close(fl);

    For i := P^.List^.Count-1 DownTo 0 Do
     Begin
      st:=P^.GetText(i,P^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;
Dispose(P,Done);
         End;
103 :{������ ����७��}
         Begin
    Assign(fl,Path^.Dat.ToSPR+'mera.db');
    c:=IOResult;
    Reset(fl,SizeOf(MeraType));
    c:=IOResult;
    If c<>0 Then Exit;

R.Assign(0, 0, 0, 0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));

While Not(Eof(fl)) Do
 Begin
    New(MeraElement,Init);
    ReadBufMera(fl,MeraElement,Count);

For c1:=1 To Count Do
Begin
  If MeraElement^.Point.Dat[c1].Employ Then
   Begin
    {Format (MeraElement^.Point.Dat[c1].Mera,CMera);}
    P^.List^.Insert(NewStr(MeraElement^.Point.Dat[c1].Mera{+'�'+MeraElement^.Point.Dat[c1].Kod}));
    P^.SetRange(P^.List^.Count);
   End;
End;{For}
  Dispose(MeraElement,Done);
 End;{While}
System.Close(fl);

    For i := P^.List^.Count-1 DownTo 0 Do
     Begin
      st:=P^.GetText(i,P^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;
Dispose(P,Done);
         End;
104 :{ᯥ� ��ઠ}
         Begin
    Assign(fl,Path^.Dat.ToSPR+'SMarka.db');
    c:=IOResult;
    Reset(fl,SizeOf(SpecMarkaType));
    c:=IOResult;
    If c<>0 Then Exit;

R.Assign(0, 0, 0, 0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));

While Not(Eof(fl)) Do
 Begin
    New(SpecMarkaElement,Init);
    ReadBufSpecMarka(fl,SpecMarkaElement,Count);

For c1:=1 To Count Do
Begin
  If SpecMarkaElement^.Point.Dat[c1].Employ Then
   Begin
    {Format (SpecMarkaElement^.Point.Dat[c1].SpecMarka,CSpecMarka);}
    P^.List^.Insert(NewStr(SpecMarkaElement^.Point.Dat[c1].SpecMarka{+'�'+SpecMarkaElement^.Point.Dat[c1].Kod}));
    P^.SetRange(P^.List^.Count);
   End;
End;{For}
  Dispose(SpecMarkaElement,Done);
 End;{While}
System.Close(fl);

    For i := P^.List^.Count-1 DownTo 0 Do
     Begin
      st:=P^.GetText(i,P^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;
Dispose(P,Done);
         End;

105 :{�ଠ �ந�����⥫�}
         Begin
    Assign(fl,Path^.Dat.ToSPR+'firma.db');
    c:=IOResult;
    Reset(fl,SizeOf(FirmaPostType));
    c:=IOResult;
    If c<>0 Then Exit;

R.Assign(0, 0, 0, 0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));

While Not(Eof(fl)) Do
 Begin
    New(FirmaElement,Init);
    ReadBufFirmaPost(fl,FirmaElement,Count);

For c1:=1 To Count Do
Begin
  If FirmaElement^.Point.Dat[c1].Employ Then
   Begin
    {Format (FirmaElement^.Point.Dat[c1].FirmaPost,CFirmaPost);}
    P^.List^.Insert(NewStr(FirmaElement^.Point.Dat[c1].FirmaPost{+'�'+FirmaElement^.Point.Dat[c1].Kod}));
    P^.SetRange(P^.List^.Count);
   End;
End;{For}
  Dispose(FirmaElement,Done);
 End;{While}
System.Close(fl);

    For i := P^.List^.Count-1 DownTo 0 Do
     Begin
      st:=P^.GetText(i,P^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;
Dispose(P,Done);
         End;


165 :{��壠���᪨� ������}
         Begin
    Assign(fl,Path^.Dat.ToSPR+'class.db');
    c:=IOResult;
    Reset(fl,SizeOf(ClassificatorBuchType));
    c:=IOResult;
    If c<>0 Then Exit;

R.Assign(0, 0, 0, 0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));

While Not(Eof(fl)) Do
 Begin
    New(ClassElement,Init);
    ReadBufClass(fl,ClassElement,Count);

For c1:=1 To Count Do
Begin
  If ClassElement^.Point.Dat[c1].Employ Then
   Begin
    {Format (FirmaElement^.Point.Dat[c1].FirmaPost,CFirmaPost);}
    P^.List^.Insert(NewStr(ClassElement^.Point.Dat[c1].Name{+'�'+FirmaElement^.Point.Dat[c1].Kod}));
    P^.SetRange(P^.List^.Count);
   End;
End;{For}
  Dispose(ClassElement,Done);
 End;{While}
System.Close(fl);

    For i := P^.List^.Count-1 DownTo 0 Do
     Begin
      st:=P^.GetText(i,P^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;
Dispose(P,Done);
         End;

250 :{��࠭�-�ந�����⥫�}
    Begin
    Assign(fl,Path^.Dat.ToSPR+'banks.db');
    c:=IOResult;
    Reset(fl,SizeOf(BankType));
    c:=IOResult;
    If c<>0 Then Exit;

R.Assign(0, 0, 0, 0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));

While Not(Eof(fl)) Do
 Begin
    New(BankElement,Init);
    ReadBufBank(fl,BankElement,Count);

For c1:=1 To Count Do
Begin
  If BankElement^.Point.Dat[c1].Employ Then
   Begin
    P^.List^.Insert(NewStr(BankElement^.Point.Dat[c1].FullName{+'�'+FirmaElement^.Point.Dat[c1].Kod}));
    P^.SetRange(P^.List^.Count);
   End;
End;{For}
  Dispose(BankElement,Done);
 End;{While}
System.Close(fl);

    For i := P^.List^.Count-1 DownTo 0 Do
     Begin
      st:=P^.GetText(i,P^.List^.Count-1);
      HistoryAdd(HistoryId, st);
     End;
Dispose(P,Done);

(*
    Assign(f,Path^.Dat.ToSPR+'bank.db');
    c:=IOResult;
    Reset(f);
    c:=IOResult;
    If c<>0 Then Exit;
    While Not(Eof(f)) Do
    Begin
    Readln(f,st);
    HistoryAdd(HistoryId, st);
    End;
    Close(f);
*)

    End;

Else;
End;

end;

procedure THistory.Store(var S: TStream);
begin
  TView.Store(S);
  PutPeerViewPtr(S, Link);
  S.Write(HistoryId, SizeOf(Word));
end;

{ Dialogs registration procedure }




Function EnterFind(Var s:AllStr):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
ShowFind:=True;
EnterFind:=False;;
Application^.GetExtent(R);
R.Assign(1, R.B.Y-6{19}, 51, R.B.Y-3{22});
New(Dlg, Init(R, '���� �� �宦�����'));
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E002;

R.Assign(2, 1, 49, 2);
Control := New(PInputLine, Init(R, CAll));
Dlg^.Insert(Control);

Dlg^.SetDAta(s);

Dlg^.SelectNext(False);
c := Desktop^.ExecView(dlg);
If c<> cmCancel Then
 Begin
  Dlg^.GetData(s);
  EnterFind:=True;
 End;
Dispose(Control,DOne);
Dispose(Dlg,Done);
ShowFind:=False;
end;



procedure RegisterDialogs;
begin
  RegisterType(RDialog);
  RegisterType(RInputLine);
  RegisterType(RButton);
  RegisterType(RCluster);
  RegisterType(RRadioButtons);
  RegisterType(RCheckBoxes);
  RegisterType(RMultiCheckBoxes);
  RegisterType(RListBox);
  RegisterType(RStaticText);
  RegisterType(RLabel);
  RegisterType(RHistory);
  RegisterType(RParamText);
end;



procedure TSelDateWindow.StartWindow(s1,s2,Default:LongInt;Var St1,St2:TDateString);
Var c : Word;
    R : TRect;
    StS,stS1 : AllStr;
    j : LongInt;
Begin
If s1<DateStringToDAte(DateMask,'01-04-98') Then
 Begin
  s1:=DateStringToDAte(DateMask,'01-04-98');
 End;

If s2<DateStringToDAte(DateMask,'31-12-04') Then
 Begin
  s2:=DateStringToDAte(DateMask,'31-12-04');
 End;



R.Assign(53, 3, 80, 20);
New(ExamplDateWin, Init(R, '������ ����'));
ExamplDateWin^.Options := ExamplDateWin^.Options or ofCenterY;
ExamplDateWin^.HelpCtx := $E002;

R.Assign(26, 1, 27, 16);
ControlS := New(PScrollBar, Init(R));
ExamplDateWin^.Insert(ControlS);

R.Assign(1, 1, 26, 16);
DateList := New(PBox, Init(R, 2, PScrollbar(ControlS)));
DateList^.NewList(New(PMyCollection, Init(0,1)));

For j:=S1 To S2 Do
 Begin
  StS:=DateToDateString(DateMask,j);
  StS1:=DayString[DayOfWeek(j)];
  StS:=StS1+'�'+StS;
  DateList^.List^.Insert(NewStr(sts));
  DateList^.SetRange(DateList^.List^.Count);
 End;


ExamplDateWin^.Insert(DateList);

ExamplDateWin^.SelectNext(False);
c:=Desktop^.ExecView(ExamplDateWin);

Dispose(ControlS,Done);
Dispose(DateList,Done);
Dispose(ExamplDateWin,Done);
End;



procedure TSelDateWindow.HandleEvent(var Event: TEvent);
Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
   kbEnter  :Begin
                ClearFind;
                inherited HandleEvent(Event);
                Event.What:=evCommand;
                Event.Command:=CmOk;
             End;
   Else;
   End;
  Else;
  End;


inherited HandleEvent(Event);
End;

Destructor TSelDateWindow.Done;
Begin
TDialog.Done;
End;




Begin
 ClipBoard[0]:=#0;
end.


