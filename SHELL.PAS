{$IFDEF DPMI}

{$DEFINE NewExeFormat}

{$Else}

{$M 32000,0,100000}

{$ENDIF}

{$X+,S-,I-}

{$IfDEF DPMI}

uses
{$DСпециально для Бакши Арвиндера Пал Сингха,Тула,1997-2000}
 Objects,App, Drivers, Memory,Views,Gadgets,Dialogs, Globals, Menus,
 ColorTxt,{Main,} UsrExit, DbEngine, Protect,Utils, Dos, TPDate,
 ServStr, Glob, Utils5, Utils1, Utils6, Serv, Nastr, MsgBox;

{$Else}
uses
{$F+}
 Objects,App, Drivers, Memory,Views,Gadgets,Dialogs, Globals, Menus,
 ColorTxt, {Main,} UsrExit, DbEngine,Protect, Utils, Dos, TPDate,
 ServStr, Glob, Utils5, Utils1, Utils6, Serv, Nastr, MsgBox;

{$EndIF}

{$I Compile.INC}


const
  HeapSize = 630 * (1024 div 16);

Const MaxMenu=15;
      RefreshTime=20;

Const MenuLine : Array [1..MaxMenu] Of String =
     ('Оперативное управление',
	 'Анализ',
      'Прочие отчеты',
	 'Инвентаризация',
	 'Доставка',
	 '',
	 '',
	 '',
	 '',
	 '',
	 '',
	 'Конфигурация и инструменты',
	 'Управление правами доступа',
	 'Сменить объект',
	 'Завершение работы');


Const BinLine : Array [1..MaxMenu] Of String =
     ('store.bin',
	 'analys.bin',
	 'report.bin',
	 'inventry.bin',
	 'delive.bin',
      '',
      '',
      '',
      '',
      '',
      '',
	 'config.bin',
	 'rights.bin',
	 '',
	 '');




Type
  PManagerWindow = ^TManagerWindow;
  TManagerWindow = object(TDialog)
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    Function  OpenManadgerWindow : Boolean;
    procedure DrawCurrent;
    procedure Refresh;
  end;

Type
  PEditorApp = ^TEditorApp;
  TEditorApp = object(TApplication)
    Clock: PClockView;
    Heap: PHeapView;
    ManagerWindow : PManagerWindow;
     GlobalAdm : PGlobalLock;
{     AddOp1    : PAddOperatorWin;}
    Constructor Init(VAr Res : Byte);
    Procedure FreshApp;
    Procedure HandleEvent(var Event: TEvent); virtual;
    Procedure GetEvent(var Event: TEvent); virtual;
    Procedure InitMenuBar; virtual;
    Procedure InitStatusLine; virtual;
    Procedure Idle;virtual;
End;





var
 ManagerWindow : PManagerWindow;
 ControlComment: PView;
 PrevCur,PrevS : String;
 SArtikul : artikulstr;
 MenuList : PBox;
 ControlObject, ControlOperator,ControlUserNT,ControlComputer,
 ControlFDate, ControlKurs,ControlKKL : PView;
  EditorApp : TEditorApp;
  ShowInfo : Boolean;
  MenuBox : PBox;
  StartTime : LongInt;



Procedure TEditorApp.FreshApp;
VAr
    Oper,skod,st :String;
    sopen,skassa,SKurs : boolean;
    L : Word;
Begin
   If ShowInfo Then Exit;
   If LastSkladKod[0]=#0 Then Exit;

   ShowInfo:=True;
   st:=GetMAkeField(FClient,Rek^.Dat.Kod,1);
   GlobalOperatorName:=GetOperatorField(FNAme,CurrentPassword);
   DelSpaceRight(St);
   DelSpaceRight(GlobalOperatorName);
   sopen:=TestOpenDate1(FDate);
   skurs:=TestSetupKurs2(FDate);

   Str(StrToInt(Rek^.Dat.Kod):2,skod);
   RFormatZerro(skod,2);

   If FExists(Path^.Dat.ToArchiv+FDate+'.k'+skod) Then Skassa:=True
   Else SKassa:=False;

   GlobalSkladsName:='Склад:'+st+{' Дата:'+FDAte+}' День:';
   If Sopen Then GlobalSkladsName:=GlobalSkladsName+'ОТКРЫТ'+'('+FDAte+')'
   Else GlobalSkladsName:=GlobalSkladsName+'ЗАКРЫТ'+'('+FDAte+')';

   If SKassa Then GlobalSkladsName:=GlobalSkladsName+' Касса:ЕСТЬ '
   Else GlobalSkladsName:=GlobalSkladsName+' Касса:НЕТ ';

   If SKurs Then
    Begin
     Oper:=FDate;
     If GetKurs(Oper) Then
      Begin
       DelSpace(Oper);
       GlobalSkladsName:=GlobalSkladsName+' Курс USD: '+Oper;
      End
     Else GlobalSkladsName:=GlobalSkladsName+' Курс USD: ??? '
    End
   Else GlobalSkladsName:=GlobalSkladsName+' Курс USD: НЕ УСТАНОВЕН ';

 (*If CurrentPassword[0]<>#0 Then
    Begin
     Oper:=GetOperatorName(CurrentPassword){+'('+CurrentPassword+')'};
     GlobalSkladsName:=GlobalSkladsName+'Оператор:'+Oper;
    End;*)

   {DeskTop^.Redraw;}
   st:=GlobalSkladsName;
   DelSpaceRight(St);
   DInfoMsg(st,False);
   st:=GetMAkeField(FClient,Rek^.Dat.Kod,1);
   DelSpaceRight(St);
   GlobalSkladsName:=' Склад:'+ST+'  Дата:'+FDAte+' ';
   DeskTop^.Redraw;
   Delay(800);
   {DeskTop^.Redraw;}
   L := IOResult;
   NoInfoMsg;
   ShowInfo:=False;
End;



constructor TEditorApp.Init(Var Res:Byte);
var
  h: LongInt;
  R: TRect;
  f: Text;
  Start1,Start2,Start3,Start4,Start0 : Boolean;
  TTT : PView;
  Dlg : PDialog;

begin
  StartTime:=TimeStringToTime('hh:mm:ss',Times);

  Res:=0;
  MaxHeapSize := HeapSize;

  RezStream := New(PProtectedStream, Init('sklad.rez', stOpenRead, 4096));
  RezFile.Init(RezStream);

  RegisterObjects;
  RegisterViews;
  RegisterMenus;
  RegisterDialogs;
  RegisterApp;

  inherited Init;

  GetExtent(R);
  R.A.X := R.B.X - 14; R.B.Y := R.A.Y + 1;
  Clock := New(PClockView, Init(R));
  Insert(Clock);

  GetExtent(R);
  R.A.X := R.B.X -9; R.A.Y := R.B.Y - 1;

  Heap := New(PHeapView, Init(R));
  Insert(Heap);

(*
R.Assign(10,10,10,10);
Dlg := New(PDialog, Init(R, 'Дата'));
Dlg^.Palette := dpBlueDialog;
Desktop^.Insert(Dlg);
Dispose(Dlg,Done);
*)


GetExtent(R);
R.Assign(1, 0, 65,1);
TTT := New(PColoredText, Init(R,'Ситема управления Склад 2000 Версия 3 '+'('+CompileDate+')',$70));
Insert(TTT);


If Not ManagerWindow^.OpenManadgerWindow Then
 Begin
  ExitProc:=OldExit;
  Halt;
 End;



(*
Desktop^.GetExtent(R);
R.Assign(37, 8, 38, R.B.Y-2{19});
TTT := New(PScrollBar, Init(R));
Desktop^.Insert(TTT);

R.Assign(1, 8, 36, R.B.Y-2{19});
MenuBox := New(PBox, Init(R, 1, PScrollbar(TTT)));
MenuBox^.NewList(New(PMyCollection, Init(0,1)));
MenuBox^.List^.Insert(NewStr('Раз'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.List^.Insert(NewStr('Два'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.List^.Insert(NewStr('Три'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.List^.Insert(NewStr('Три1'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.List^.Insert(NewStr('Три2'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.List^.Insert(NewStr('Три3'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.List^.Insert(NewStr('Три4'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.List^.Insert(NewStr('Три5'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.List^.Insert(NewStr('Три6'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.List^.Insert(NewStr('Три7'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.List^.Insert(NewStr('Три8'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.List^.Insert(NewStr('Три9'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.List^.Insert(NewStr('Три10'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.List^.Insert(NewStr('Три10'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.List^.Insert(NewStr('Три12'));
MenuBox^.SetRange(MenuBox^.List^.Count);
MenuBox^.Options := MenuBox^.Options or ofFramed;

Desktop^.Insert(MenuBox);
*)




end;




Procedure TEditorApp.Idle;
Var l : ShortInt;
    k : LongInt;
    skod,st :String[CAll];
    sopen,skassa : boolean;
    Event : TEvent;
    j : Boolean;
begin
  L := IOResult;
  inherited Idle;
  L := IOResult;
  Clock^.Update(0);
  Heap^.Update;
end;



procedure TEditorApp.GetEvent(var Event: TEvent);
Var j: Boolean;
    l : Word;
    OperatorElement : PSystemReestr;
Begin

  TApplication.GetEvent(Event);

  If((Event.What=EvCommand)Or(Event.What=EvKeyDown)
  Or(Event.What=EvMouseMove)Or(Event.What=EvMouseDown))
  Then
   Begin
    GlobalTime:=TimeStringToTime('hh:mm:ss',Times);
    If (Event.What=EvKeyDown) And (Event.KeyCode=kbCtrlRusM) Then
    RunScreenSaver;
   End
  Else
   Begin
   If Nprint^.DAt.ProtectScreen=1 Then
   Begin
If ((Abs(-GlobalTime+TimeStringToTime('hh:mm:ss',Times))>=StrToInt(Nprint^.DAt.TimeProtectScreen)*60))
 Then
 Begin
  RunScreenSaver;
 End;
   End;
   End;


  If Not(Glob.GlobalShow) And (CurrentPassword[0]<>#0) Then
If ((Abs(-GlobalTimeMsg+TimeStringToTime('hh:mm:ss',Times))>=7)) Then
 Begin
  If FExists(Path^.Dat.ToFlagDir+'lockadm') Then
   Begin
    GlobalTimeMsg:=TimeStringToTime('hh:mm:ss',Times);
    j:=FAlse;
    GlobalAdm^.Start(j);
   End
   Else
     Begin
      Glob.AnsverGlobal:=FAlse;
      GlobalTimeMsg:=TimeStringToTime('hh:mm:ss',Times);
     End;
 End;

If ((Abs(-GlobalTimeMsg1+TimeStringToTime('hh:mm:ss',Times))>=7)) Then
 Begin
  If FExists(Path^.Dat.ToTerminal+'runserv.flg') Then
   Begin
    GlobalTimeMsg1:=TimeStringToTime('hh:mm:ss',Times);
    GlobalReadOnly:=1;
   End
   Else
     Begin
      GlobalTimeMsg1:=TimeStringToTime('hh:mm:ss',Times);
      GlobalReadOnly:=0;

  If FExists(Path^.Dat.ToTerminal+'wait_imp.flg') Then
   Begin
    GlobalTimeMsg1:=TimeStringToTime('hh:mm:ss',Times);
    GlobalReadOnly:=1;
   End;

      If FindParam('/READONLY') Then
       Begin
        GlobalReadOnly:=1;
       End;

     End;
 End;

l:=IOResult;

{
If (Desktop^.Current=Nil) And (Desktop^.TopView=Nil)  Then
   Begin
    EnableCommands([cmExit]);
   End
   Else DisableCommands([cmExit]);
}


  l:=IOResult;
end;



procedure TEditorApp.HandleEvent(var Event: TEvent);


VAr R : TRect;
    s : String;
    Time : LongInt;
    st1,st2 :TDAteString;
    R1 : TREct;
    c : Word;
begin


  inherited HandleEvent(Event);

  ClearEvent(Event);

  if (Abs(TimeStringToTime('hh:mm:ss',Times)-StartTime)>RefreshTime) then
   Begin
     Event.What:=evCommand;
     Event.Command:=cmRefresh;
     PutEvent(Event);
   End;

end;



procedure TEditorApp.InitMenuBar;
var
  R : TRect;
  s : ArtikulStr;
begin
  GetExtent(R);
  s:=' ';
  R.B.Y := R.A.Y + 1;

  MenuBar := New(PMenuBar, Init(R, NewMenu(
      NewItem(' ','Sys',KbAltRusCh , cmQuit, $A030,
      Nil))));
end;




Function TManagerWindow.OpenManadgerWindow:Boolean;
Var l : Boolean;
begin
  ClearFind;
  OpenManadgerWindow:=False;
  if Message(Desktop, evBroadcast, cmSkidki, nil) = nil then
  begin
    L:=True;
    ManagerWindow := New(PManagerWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(ManagerWindow);
    OpenManadgerWindow:=True;
    End
    Else
     Begin
      Dispose(ManagerWindow,Done);
     End;
  end
  else
    if PView(ManagerWindow) <> Desktop^.TopView then ManagerWindow^.Select;
end;


Procedure RunBin(Event:TEvent; Index:Word);
Var f : File;
    c : Word;
    Dopolnenie : TMyString;
    s : String;
Begin
If Not FExists(Path^.Dat.ToProgram+BinLine[Index]) Then
 Begin
  MessageBox(NoExistsModul^,Nil,mfError+mfCancelButton);
  Exit;
 End;

 If (Index=2) And Not(Password(7)) Then Exit;

  Dopolnenie[0]:=#0;
  If FindParam('/WIN2K') Then Dopolnenie:='/WIN2K'
  Else Dopolnenie[0]:=#0;

  If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then Dopolnenie:=Dopolnenie+' '+'/READONLY';

  CursorLines:=1543;
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SwapVectors;

  Exec(Path^.Dat.ToProgram+BinLine[Index],' '+Dopolnenie+' '+'/CONFIGDATE='+FDate+' '+
  '/CONFIGPATH='+PathToConfig^+' '+KeyStr+CurrentPassword+' '+NullStr^);

  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;

  Event.What:=evCommand;
  Event.Command:=cmNone;
  Application^.PutEvent(Event);

  Application^.Redraw;
End;



constructor TManagerWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  DocumentNumer : TDateString;
  SkladFile : File Of SkladType;
  s: TEnjoyStr;
  ws : TDateString;
  j,i : Byte;
  SNAme : AllStr;
  st : String;
  h : LongInt;
  Res : Word;
begin
l:=False;
R.Assign(1, 1, 81, 24);
inherited Init(R, '');
Options := Options or ofCenterX or ofCenterY;
Flags := Flags and not wfMove;

{Palette := dpCyanDialog;}
HelpCtx:=$F901;

{
For c:=0 To 25 Do
Begin
 R.Assign(0, c, 80, c+1);
 s[0]:=#0;
 For j:=1 To 80 Do s:=s+#219;
Control := New(PColoredText, Init(R, s, $78));
Insert(Control);
End;
}
  New(PathExpImp,Init);
  New(Path,Init);
  New(Rek,Init);
  New(RekSF,Init);
  New(RekComissioner,Init);
  New(NPrint,Init);
  New(NPrintC,Init);

  R.Assign(0,0,0,0);
  ListRange := New(PBox, Init(R, 1, Nil));
  ListRange^.NewList(New(PTextCollection, Init(1,1)));
  ListRange^.FocusItem(0);


  If Not ReadNewSystemIni(h) Then
   Begin
    Dispose(PathExpImp,Done);
    Dispose(Path,Done);
    Dispose(Rek,Done);
    Dispose(RekSF,Done);
    Dispose(RekComissioner,Done);
    Dispose(NPrint,Done);
    Dispose(NPrintC,Done);
    DisposeStr(PathToConfig);
    DisposeResursMessage;
    Exit;
   End;

  If FindParam('/READONLY') {Or (ReadOnlyConst=1)} Then GlobalReadOnly:=1;

  If FindParam('/ONLYONECOPY') Then ONLYONECOPY:=1;


DInfoMsg('Инициализация системы...',False);


  If H <> 0 Then Errors('Ошибка открытия файла размещения конфигурации!');


  ReadNewCfg(h);

  If H <> 0 Then Errors('Ошибка чтения файла конфигурации !');

  ReadRek(Rek,0,h);

  If H <> 0 Then Errors('Ошибка чтения файла реквизитов !');

  Path^.Dat.FileFlag:=NetComputerName+'.'+IntToStr(StrToInt(Rek^.Dat.Kod),CMantissa);

  ReadRek(RekSF,1,h);

  If H <> 0 Then Errors('Ошибка чтения файла дубликата реквизитов !');

  ReadRek(RekComissioner,2,h);

  If H <> 0 Then Errors('Ошибка чтения файла реквизитов комиссионера!');

  NoInfoMsg;

  LastSkladKod:=Rek^.dat.Kod;

  If FExists(Path^.Dat.ToTerminal+'runserv.flg') Then
   Begin
    MessageBox(WarningFoundEKRSERV1^,Nil,
                        mfWarning+mfCancelButton);
    GlobalReadOnly:=1;
    GlobalTimeMsg1:=TimeStringToTime('hh:mm:ss',Times);
   End;

  If FExists(Path^.Dat.ToTerminal+'wait_imp.flg') Then
   Begin
    GlobalTimeMsg1:=TimeStringToTime('hh:mm:ss',Times);
    GlobalReadOnly:=1;
   End;


  DeskTop^.Redraw;

Registr;


{$IfDEF Debug }

{$Else}

If Not FindParam('/'+IntToStr(NoControl,CZena)) Then
   Begin
    If Not(Wzlom) Then  Res:=TestPC;
   End;

{$ENDIF}


NewTmpAndAnalys;
NewTmpAndAnalysLocal;
CursorLines:=1543;

R.Assign(44, 18, 77, 21);
Control := New(PColoredText, Init(R, '', $70));
Control^.Options := Control^.Options or ofFramed;
Insert(Control);

R.Assign(43, 12, 78, 16);
Control := New(PColoredText, Init(R, '', $70));
Control^.Options := Control^.Options or ofFramed;
Insert(Control);


R.Assign(41, 10, 42, 21);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(2, 10, 41, 21);
MenuList := New(PBox, Init(R, 1, PScrollbar(Control)));
MenuList^.NewList(New(PMyCollection, Init(0,1)));
MenuList^.Options := MenuList^.Options or ofFramed;
For h:=1 To MaxMenu Do
Begin
 st:=MenuLine[h];
 If st<>'' Then
  Begin
   Format(st,Call);
   SNAme:=IntToStr(h,CMAntissa);
   RFormatZerro(SNAme,CMantissa);
   st:=St+'│'+SNAme;
   MenuList^.List^.Insert(NewStr(st));
   MenuList^.SetRange(MenuList^.List^.Count);
  End;
End;
Insert(MenuList);

R.Assign(49, 12, 56, 13);
Control := New(PStaticText, Init(R, 'Объект:'));
Insert(Control);

R.Assign(44, 18, 57, 19);
Control := New(PStaticText, Init(R, 'Пользователь:'));
Insert(Control);

R.Assign(51, 19, 57, 20);
Control := New(PStaticText, Init(R, 'Login:'));
Insert(Control);

R.Assign(48, 20, 57, 21);
Control := New(PStaticText, Init(R, 'Computer:'));
Insert(Control);

R.Assign(43, 13, 56, 14);
Control := New(PStaticText, Init(R, 'Рабочая дата:'));
Insert(Control);

R.Assign(47, 14, 56, 15);
Control := New(PStaticText, Init(R, 'Курс USD:'));
Insert(Control);

R.Assign(52, 15, 56, 16);
Control := New(PStaticText, Init(R, 'ККЛ:'));
Insert(Control);

R.Assign(56, 12, 76, 13);
ControlObject := New(PStaticText, Init(R, '???'));
Insert(ControlObject);

R.Assign(57, 18, 77, 19);
ControlOperator := New(PStaticText, Init(R, GetOperatorField(FName,CurrentPassword)));
Insert(ControlOperator);

R.Assign(57, 19, 77, 20);
ControlUserNT := New(PStaticText, Init(R, GetEnv('UserName')));
Insert(ControlUserNT);

R.Assign(57, 20, 77, 21);
ControlComputer := New(PStaticText, Init(R, NetComputerName));
Insert(ControlComputer);

R.Assign(56, 13, 73, 14);
ControlFDate := New(PStaticText, Init(R, FDate));
Insert(ControlFDate);

R.Assign(56, 14, 64, 15);
ControlKurs := New(PStaticText, Init(R, '???'));
Insert(ControlKurs);

R.Assign(56, 15, 64, 16);
ControlKKL := New(PStaticText, Init(R, '???'));
Insert(ControlKKL);

SelectNext(False);

Refresh;

l:=True;
end;



Procedure ReloadConfig;
var
  c,h: LongInt;
  l : Boolean;
  Start1,Start2,Start3,Start4,Start0 : Boolean;
  s : String;
begin

  AddProtocol('Выход оператора из ситемы через смену конфигурации!','','');
  DelFlag;
  RunFromExitProgram;

  GlobalReadOnly:=0;
  GlobalSkladsName[0]:=#0;
  GlobalOperatorNAme:='???';

  ConfigCmdParameters[0]:=#0;

  DisposeStr(PathToConfig);

  DeskTop^.Redraw;

  ListRange^.NewList(Nil);
  ListRange^.NewList(New(PTextCollection, Init(0,1)));

  If Not ReadNewSystemIni(h) Then
   Begin
    Dispose(PathExpImp,Done);
    Dispose(Path,Done);
    Dispose(Rek,Done);
    Dispose(RekSF,Done);
    Dispose(RekComissioner,Done);
    Dispose(NPrint,Done);
    Dispose(NPrintC,Done);
    DisposeStr(PathToConfig);
    Dispose(ListRange,Done);
    DisposeResursMessage;
    Dispose(ListRange,Done);
    EditorApp.Done;
    ExitProc:=OldExit;
    Halt;
   End;

    Dispose(PathExpImp,Done);
    Dispose(Path,Done);
    Dispose(Rek,Done);
    Dispose(RekSF,Done);
    Dispose(RekComissioner,Done);
    Dispose(NPrint,Done);
    Dispose(NPrintC,Done);

  New(PathExpImp,Init);
  New(Path,Init);
  New(Rek,Init);
  New(RekSF,Init);
  New(RekComissioner,Init);
  New(NPrint,Init);
  New(NPrintC,Init);

  If H <> 0 Then Errors('Ошибка открытия файла размещения конфигурации!'+' Код:'+IntToStr(h,CKol));
  ReadNewCfg(h);

  If H <> 0 Then Errors('Ошибка чтения файла конфигурации !'+' Код:'+IntToStr(h,CKol));
  ReadRek(Rek,0,h);

  Path^.Dat.FileFlag:=NetComputerName+'.'+IntToStr(StrToInt(Rek^.Dat.Kod),CMantissa);
  If H <> 0 Then Errors('Ошибка чтения файла реквизитов !'+' Код:'+IntToStr(h,CKol));

  ReadRek(RekSF,1,h);
  If H <> 0 Then Errors('Ошибка чтения файла дубликата реквизитов !'+' Код:'+IntToStr(h,CKol));

  ReadRek(RekComissioner,2,h);
  If H <> 0 Then Errors('Ошибка чтения файла реквизитов комиссионера!'+' Код:'+IntToStr(h,CKol));

  EditorApp.FreshApp;

  LastSkladKod:=Rek^.DAt.Kod;

  If FExists(Path^.Dat.ToTerminal+'runserv.flg') Then
   Begin
    MessageBox(WarningFoundEKRSERV1^,Nil,mfWarning+mfCancelButton);
    GlobalReadOnly:=1;
    GlobalTimeMsg1:=TimeStringToTime('hh:mm:ss',Times);
   End;

  If FExists(Path^.Dat.ToTerminal+'wait_imp.flg') Then
   Begin
    GlobalTimeMsg1:=TimeStringToTime('hh:mm:ss',Times);
    GlobalReadOnly:=1;
   End;

s[0]:=#0;

For c:=1 To ParamCount Do
 Begin
  s:=s+' '+ParamStr(c)+';';
 End;

 If FindParam('/READONLY') {Or (ReadOnlyConst=1)} Then GlobalReadOnly:=1;

 If FindParam('/ONLYONECOPY') Then ONLYONECOPY:=1;

  AddProtocol('Вход в систему нового оператора через смену конфигурации!',
   'Со следующими параметрами :'+s,ConfigCmdParameters);

  GlobalOperatorName:=GetOperatorField(FNAme,CurrentPassword);

  DelSpaceRight(GlobalOperatorName);

  DeskTop^.Redraw;
{
If (FindParam('/AUTODETECT')) Or (AutoDetect=1) Then
Begin
 Start0:=False;
 Start1:=False;
 Start2:=False;
 Start3:=False;
 Start4:=False;
 DInfoMsg('Ищу обновленные базы...',True);
 Start0:=TestFoundAddClient(0,Path^.DAt.ToClientIndex);
 Start1:=TestFoundAddClient(1,Path^.DAt.ToClientIndex);
 Start2:=TestFoundAddClient(2,Path^.DAt.ToClientIndex);
 Start3:=TestFoundAddClient(3,Path^.DAt.ToClientIndex);
 Start4:=TestFoundAddClient(4,Path^.DAt.ToClientIndex);
 NoInfoMsg;
 If Start0 Or Start1 Or Start2 Or Start3 Or Start4 Then  ClientIDXAuto;
End;
}
NewTmpAndAnalys;

NewTmpAndAnalysLocal;

l:=(TestFlag);

If Not(l) Or (StrToInt(CurrentPassword)=0) Then
Begin
  If (l) And (StrToInt(CurrentPassword)=0)  Then
    MessageBox(WarningNoOneCopy^,Nil,mfWarning+mfCancelButton);
End
   Else
    Begin
     SpecialBeep;
     MessageBox(FoundRunCopyProgram^,Nil,mfError+mfCancelButton);
     Dispose(PathExpImp,Done);
     Dispose(Path,Done);
     Dispose(Rek,Done);
     Dispose(RekSF,Done);
     Dispose(RekComissioner,Done);
     Dispose(NPrint,Done);
     Dispose(NPrintC,Done);
     DisposeStr(PathToConfig);
     EditorApp.Done;
     DisposeResursMessage;
     ExitProc:=OldExit;
     Halt;
   End;
End;


procedure TManagerWindow.HandleEvent(var Event: TEvent);
Var test,IO : Word;
    s,s1 : String;
    l : Boolean;
    SName : String[CName];
    Art   : ArtikulStr;
    Enable : Boolean;
    FS : AllStr;
    FC : Word;
    Kod : LongInt;
begin
 {
  if (Abs(TimeStringToTime('hh:mm:ss',Times)-StartTime)>RefreshTime) then
   Begin
     Event.What:=evCommand;
     Event.Command:=cmRefresh;
   End;
 }
  case Event.What of
    evCommand:
Begin
      case Event.Command of

        cmQuit : Begin
                 If MessageBox(^M+#3+'Желаете закончить работу?',Nil,mfOkCancel)<>cmOk Then
                  Begin
                   ClearEvent(Event);
                   Exit;
                  End;
                   RunFromExitProgram;
                   AddProtocol('Выход оператора из ситемы!','','');
                 End;

   cmReloadConfig : Begin
                     RunFromExitProgram;
                     ReloadConfig;
                     Refresh;
                    End;

        cmRefresh:Begin
  If (DeskTop^.Current=PView(ManagerWindow)) And (Event.What <> EvKeyDown)
      And Not(Glob.Show) And Not(Glob.ShowMsg) And Not(Glob.GlobalShow) Then
           Begin
              FS:=FindStrok;
              FC:=Ord(FindStrok[0]);
              Refresh;
              ClearEvent(Event);
              StartTime:=TimeStringToTime('hh:mm:ss',Times);
              FindStrok:=FS;
              FindSymbol:=FC;
              Redraw;
           End
           Else ClearEvent(Event);
                  End;

        cmView :Begin
                 s:=MenuList^.GetText(MenuList^.Focused,MenuList^.List^.Count);
                 Kod:=StrToInt(Copy(s,1+CAll+1,CMAntissa));

                 {Команда на выход}
                 If Kod=MAxMenu Then
                  Begin
                   Event.What:=evCommand;
                   Event.Command:=cmQuit;
                   Event.InfoPtr:=Nil;
                   PutEvent(Event);
                  End;

                 If Kod=(MAxMenu-1) Then
                  Begin
                   Event.What:=evCommand;
                   Event.Command:=cmReloadConfig;
                   Event.InfoPtr:=Nil;
                   PutEvent(Event);
                  End;

                 If BinLine[kod]<>'' Then
                  Begin
                   RunBin(Event,Kod);
                  End;

                  ClearEvent(Event);
                End;

        Else;
        End;
End;

    evKeyDown:Begin
               {
               Case Event.KeyCode Of

               kbEnter:Begin
                        s:=
                       End;


               Else;
               End;{CAse}
              End;{evKeyDown}

Else;
End;

  inherited HandleEvent(Event);

  If (Desktop^.Current=PView(ManagerWindow)) And (Event.What <> EvKeyDown) Then
             Begin

             End;
end;


procedure TManagerWindow.DrawCurrent;
VAr S : String;
    R : TRect;
    SKol : TDateString;
Begin
End;


procedure TManagerWindow.Refresh;
VAr
    R : TRect;
    StatusSS,Oper,SKod,SKol : AllStr;
    SKassa,SKurs,SOpen : Boolean;
Begin

DInfoMsg('Минутку...',False);

Str(StrToInt(Rek^.Dat.Kod):2,skod);
RFormatZerro(skod,2);

Dispose(ControlObject,Done);
R.Assign(56, 12, 76, 13);
StatussS:=GetClientField(FClient,Rek^.DAt.Kod,1);
DelSpaceRight(StatussS);
ControlObject := New(PStaticText, Init(R, StatussS+' ['+SKod+']'));
Insert(ControlObject);
{
Dispose(ControlOperator,Done);
R.Assign(57, 18, 77, 19);
ControlOperator := New(PStaticText, Init(R, GetOperatorField(FName,CurrentPassword)));
Insert(ControlOperator);

Dispose(ControlUserNT,Done);
R.Assign(57, 19, 77, 20);
ControlUserNT := New(PStaticText, Init(R, GetEnv('UserName')));
Insert(ControlUserNT);

Dispose(ControlComputer,Done);
R.Assign(57, 20, 77, 21);
ControlComputer := New(PStaticText, Init(R, NetComputerName));
Insert(ControlComputer);
}

skurs:=TestSetupKurs2(FDate);
sopen:=TestOpenDate1(FDate);

If FExists(Path^.Dat.ToArchiv+FDate+'.k'+skod) Then Skassa:=True
Else SKassa:=False;

Dispose(ControlKurs,Done);
R.Assign(56, 14, 64, 15);
If Not SKurs Then
ControlKurs := New(PStaticText, Init(R, 'Нет'))
Else
 Begin
  Oper:=FDate;
  If GetKurs(Oper) Then
  ControlKurs := New(PStaticText, Init(R, DelSpace(Oper)))
  Else
  ControlKurs := New(PStaticText, Init(R, '???'))
 End;
Insert(ControlKurs);


If SOpen Then StatusSS:='открыт'
Else StatusSS:='закрыт';

Dispose(ControlFDate,Done);
R.Assign(56, 13, 73, 14);
ControlFDate := New(PStaticText, Init(R, FDate+' '+StatusSS));
Insert(ControlFDate);


Dispose(ControlKKL,Done);
R.Assign(56, 15, 64, 16);
If SKassa Then
ControlKKL := New(PStaticText, Init(R, 'Есть'))
Else
ControlKKL := New(PStaticText, Init(R, 'Нет'));
Insert(ControlKKL);
NoInfoMsg;
End;



procedure TEditorApp.InitStatusLine;
var
  R: TRect;
begin
  Application^.GetExtent(R);
  R.Assign(0, 0, 80, R.B.Y-2{23});
  StatusLine := PStatusLine(RezFile.Get('StatusLine'));
  StatusLine^.Show;
end;

(*
Label Stop;
Var Mode,OrigMode : Integer;
    f : File;
    l : Boolean;
    Res : Byte;
    s : String;

Begin
interval:=60;
Mode:=FileMode;
FileMode:=66;
ProdagaWindow:=False;
ShowInfo:=False;

{OrigMode := LastMode;}
{TextMode(CO80);}

Res:=0;
LoadResursMessage;

EditorApp.Init(Res);
CursorLines:=1543;
Case Res of
1:Begin
  SpecialBeep;
  SpecialBeep;
   MessageBox(NoLizensiaFromProgram^,Nil,mfWarning+mfCancelButton);
   EditorApp.Done;
  {TextMode(OrigMode);}
   FileMode:=Mode;
   DisposeResursMessage;
   Halt;
  End;
2:Begin
  SpecialBeep;
  SpecialBeep;
   MessageBox(IstekSrokLizensii^,
                    Nil,mfWarning+mfCancelButton);
   EditorApp.Done;
   {TextMode(OrigMode);}
   FileMode:=Mode;
   DisposeResursMessage;
   HAlt;
  End;
3:Begin
  SpecialBeep;
  SpecialBeep;
   MessageBox(IstekaetSrokLizensii^,
                    Nil,mfWarning+mfCancelButton);
   DisposeResursMessage;
  End;
Else;
End;

EditorApp.Run;

Dispose(PathExpImp,Done);
Dispose(Path,Done);
Dispose(Rek,Done);
Dispose(RekSF,Done);
Dispose(RekComissioner,Done);

Dispose(NPrint,Done);
DisposeStr(PathToConfig);

EditorApp.Done;
{TextMode(OrigMode);}
DisposeResursMessage;
FileMode:=Mode;
ExitProc:=OldExit;
end.
*)
Label Stop;
Var Mode,OrigMode : Integer;
    f : File;
    l : Boolean;
    Res : Byte;
    s : String;

Begin
interval:=60;
Mode:=FileMode;
FileMode:=66;
ProdagaWindow:=False;
ShowInfo:=False;

{OrigMode := LastMode;}
{TextMode(CO80);}

Res:=0;
LoadResursMessage;

EditorApp.Init(Res);

Case Res of
1:Begin
  SpecialBeep;
  SpecialBeep;
   MessageBox(NoLizensiaFromProgram^,Nil,mfWarning+mfCancelButton);
   EditorApp.Done;
   {TextMode(OrigMode);}
   FileMode:=Mode;
   DisposeResursMessage;
   Halt;
  End;
2:Begin
  SpecialBeep;
  SpecialBeep;
   MessageBox(IstekSrokLizensii^,
                    Nil,mfWarning+mfCancelButton);
   EditorApp.Done;
   {TextMode(OrigMode);}
   FileMode:=Mode;
   DisposeResursMessage;
   HAlt;
  End;
3:Begin
  SpecialBeep;
  SpecialBeep;
   MessageBox(IstekaetSrokLizensii^,
                    Nil,mfWarning+mfCancelButton);
   DisposeResursMessage;
  End;
Else;
End;

{  If TDate Then
  Begin}

If Not(Wzlom) Then
Begin
l:=(TestFlag);

If Not(l) Or (StrToInt(CurrentPassword)=0) Then
Begin
  If (l) And (StrToInt(CurrentPassword)=0)  Then
    MessageBox(WarningNoOneCopy^,Nil,mfWarning+mfCancelButton);
    OldExit:=ExitProc;
    ExitProc:=@UserExit;
    EditorApp.Run;
    DelFlag;
End
Else
   Begin
    SpecialBeep;
    MessageBox(FoundRunCopyProgram^,
    Nil,mfError+mfCancelButton);
   End;

End;

{EditorApp.Run;}


Dispose(PathExpImp,Done);
Dispose(Path,Done);
Dispose(Rek,Done);
Dispose(RekSF,Done);
Dispose(RekComissioner,Done);
Dispose(NPrint,Done);
Dispose(NPrintC,Done);
DisposeStr(PathToConfig);
EditorApp.Done;
{TextMode(OrigMode);}
DisposeResursMessage;
FileMode:=Mode;
ExitProc:=OldExit;

end.