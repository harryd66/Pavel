{$IFDEF DPMI}

{$DEFINE NewExeFormat}

{$Else}

{$M 61440,0,652800}

{$ENDIF}

{$X+,S-,I-}

{$IfDEF DPMI}

uses
{$D���樠�쭮 ��� ���� �ࢨ���� ��� �����,�㫠,1997-2000}
 Objects,App, Drivers, Memory,Printers,{Prihod,CSklad,Vozwrat,}OplInfo,Globals,MyCalc,
 Views, Menus, Dialogs, Glob, MsgBox,  {Pereozen,Market,MrkTool,}Nastr,Protect,Access7,
 {Return,ReestrR,}ServStr2,Feliks,Replagnt,MrkTool,
 Gadgets,Validate,Calendar,Serv,Vision1,Vision2,Vision3,Vision5,Vision7,ClBalans,
 Prise,ColorTxt,ServStr,{CSkid,Barter,}Vision4,Vision8,Vision10,Utils6,Declare,
 {Reestr,ReestrZ,ReestrVe,}Utils,{Rewisia,}Stat,StatB,StatP,{PStat,}dStat,TStat,
 UsrExit,LockInfo,Net{,tvInput},TvMenus,TpDate,Utils7,AgOpl,
 DbEngine,{MAil,}Net1,Utils5,Access1,RangView,Oborot,TulaDecl,
 Slava,Slava2,Utils10,Utils11,Hz,EtilDecl,
 {ReestrP,ReestrV,ReestrPz,BuxOtch,
 MakeHist,}UKassa,UKassaT,{EndRep,Vision6,ExpImp,}Utils1,Utils2,Utils3,Utils4{,Trans,TrNakl};

{$Else}
uses
{$F+}
 Objects,App, Drivers, Memory,Printers,Prihod,CSklad,Vozwrat,OplInfo,Globals,MyCalc,Access7,
 Views, Menus, Dialogs, Glob, MsgBox,  Pereozen,Market,MrkTool,Nastr,Protect,Return,ReestrR,
 Gadgets,Validate,Calendar,Serv,Vision1,Vision2,Vision3,Vision5,ClBalans,
 Vision7,Prise,ColorTxt,ServStr,CSkid,Barter,Vision4,Vision8,Vision10,Utils6,Declare,
 MAil,Net1,Utils5,Access1,RangView,AgOpl,Oborot,Feliks,Replagnt,
 Reestr,ReestrZ,ReestrPz,BuxOtch,ServStr2,Utils10,Utils11,MrkTool,
 EtilDecl,
 Utils,Rewisia,Stat,StatB,StatP,{PStat,}DStat,TStat,UsrExit,LockInfo,Net{,TvInput},TvMenus,TpDate,DbEngine,
 Slava,Slava2,ReestrV,ReestrP,ReestrVe,MakeHist,UKassa,UKassaT,EndRep,Vision6,ExpImp,Utils1,
 Utils2,Utils3,Utils4,Trans,TrNakl;Hz,

{$O Protect}
{$O Vision1}
{$O Vision2}
{$O Vision3}
{$O Vision4}
{$O Vision5}
{$O Vision6}
{$O Vision7}
{$O Vision8}
{$O Vision10}
{$O Prise}
{$O MyCalc}
{$O Calendar}
{$O Validate}
{$O Menus}
{$O App}
{$O Views}
{$O MSgBox}
{$O Dialogs}
{$O ServStr}
{$O Serv}
{$O ColorTxt}
{$O Gadgets}
{$O Stat}
{$O StatB}
{$O PStat}
{$O StatP}
{$O DStat}
{$O TStat}
{$O UsrExit}
{$O LockInfo}
{$O DbEngine}
{$O Net}
{$O Net1}
{$O Slava}
{$O Slava2}
{$O Utils}
{$O Ukassa}
{$O UkassaT}
{$O Utils1}
{$O Utils2}
{$O Utils3}
{$O Utils4}
{$O Utils6}
{$O OplInfo}
{$O ClBalans}
{$O Feliks}


{$EndIF}

{$I Compile.INC}


const
  HeapSize = 630 * (1024 div 16);

type

  PEditorApp = ^TEditorApp;
  TEditorApp = object(TApplication)
     Clock: PClockView;
         Heap: PHeapView;
     {
     SuperMarketWindow : PSuperMarketWindow;
     SkladWindow : PSkladWindow;
     SkidWindow : PSkidWindow;
     PrihodWindow : PPrihodWindow;
     RewisiaWindow : PRewisiaWindow;
     TransportWindow: PTransportWindow;
     DolgWindow : PDolgWindow;
     BarterWindow : PBarterWindow;}
     OperatorWindow : POperatorWindow;
     PZ        : PZenaWindow;
     {
     PrzWindow : PPrzWindow;
     ReestrWindow : PReestrWindow;
     ReestrZWindow: PReestrZWindow;
     ReestrPZWindow: PReestrPZWindow;
     ReestrVeWindow : PReestrVeWindow;
     ReestrPWindow : PReestrPWindow;
     ReestrVWindow : PReestrVWindow;
     ReestrRewWindow : PReestrRewWindow;
     }
     InfoDebitWindow : PInfoDynamicDebit;
     {
     ItogoWindow : PItogWindow;}
     {GlReturnWindow: PReturnWindow;}
     MyCalculator : PMyCalculator;
     DynamicReturn :PInfoDynamicReturn;
     StatWindow : PStatWindow;
     SelectClientStat :PSelectClientWindow;
     SelectClientStat1 :PSelectClientWindow1;
     SelectMakeStat :PSelectMAkeWindow;
     {PrihodStat     :PPrihodStatWindow;}
     TovarStatWindow:PTovarStatWindow;
     SkladKAssa : PKAssawindow;
     {
     ZakazTest : PDeltaTestWindow;}
     GlobalAdm : PGlobalLock;
     AddOp1    : PAddOperatorWin;
    Constructor Init(VAr Res : Byte);
    Procedure HandleEvent(var Event: TEvent); virtual;
    Procedure GetEvent(var Event: TEvent); virtual;
    Procedure InitMenuBar; virtual;
    Procedure InitStatusLine; virtual;
    Procedure Idle;virtual;
    Procedure FreshApp;
    Procedure ClearDesktop(Var Event : tEvent);
End;

var
  EditorApp : TEditorApp;
  ControlSklad : PView;
  SetupPasswordB : Boolean;
  ShowInfo : Boolean;

  {ShiftState: Byte absolute $40:$17;}


constructor TEditorApp.Init(Var Res:Byte);
var
  h: LongInt;
  R: TRect;
  f: Text;
  Start1,Start2,Start3,Start4,Start0 : Boolean;
begin
  SetupPasswordB:=False;
  Res:=0;
  MaxHeapSize := HeapSize;
  FindStrok[0]:=#0;
  FindSymbol:=0;

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

  New(PathExpImp,Init);
  New(PathSklads,Init);
  New(Path,Init);
  New(NetPath,Init);
  New(Rek,Init);
  New(RekSF,Init);
  New(RekComissioner,Init);
  New(NPrint,Init);
  New(NPrintC,Init);

  R.Assign(0,0,0,0);
  ListRange := New(PBox, Init(R, 1, Nil));
  ListRange^.NewList(New(PTextCollection, Init(1,1)));
  ListRange^.FocusItem(0);
  LastRange:=0;

  DixyList := New(PBox, Init(R, 1, Nil));
  DixyList^.NewList(New(PTextCollection, Init(1,1)));
  DixyList^.FocusItem(0);
  LastDixy:=0;

  If Not ReadNewSystemIni(h) Then
   Begin
    Dispose(PathExpImp,Done);
    Dispose(PathSklads,Done);
    Dispose(Path,Done);
    Dispose(NetPath,Done);
    Dispose(Rek,Done);
    Dispose(RekSF,Done);
    Dispose(RekComissioner,Done);
    Dispose(NPrint,Done);
    Dispose(NPrintC,Done);
    Dispose(ListRange,Done);
    Dispose(DixyList,Done);
    DisposeStr(PathToConfig);
    EditorApp.Done;
    DisposeResursMessage;
    ExitProc:=OldExit;
    Halt;
   End;

  If H <> 0 Then Errors('�訡�� ������ 䠩�� ࠧ��饭�� ���䨣��樨!');

  ReadNewCfg(h);

  If H <> 0 Then Errors('�訡�� �⥭�� 䠩�� ���䨣��樨 !');

  ReadRek(Rek,0,h);

  If H <> 0 Then Errors('�訡�� �⥭�� 䠩�� ४����⮢ !');

  Path^.Dat.FileFlag:=NetComputerName+'.'+IntToStr(StrToInt(Rek^.Dat.Kod),CMantissa);

  ReadRek(RekSF,1,h);

  If H <> 0 Then Errors('�訡�� �⥭�� 䠩�� �㡫���� ४����⮢ !');

  ReadRek(RekComissioner,2,h);

  If H <> 0 Then Errors('�訡�� �⥭�� 䠩�� ४����⮢ �����ᨮ���!');


  InitCash;
  LoadCash;

  Registr;

  LoadMonitorZen;
  LoadSubst;

{$IFNDEF RemoteClient}

{$ELSE}
GetLastOst;
GetLastLocal;
GetLastCl;
GetLastSpr;
{$ENDIF}

  DeskTop^.Redraw;

  FreshApp;

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

If FExists(Path^.Dat.ToTemp+'sleep.txt') Then
 Begin
  Assign(f,Path^.Dat.ToTemp+'sleep.txt');
  h:=IOResult;
  Erase(f);
  h:=IOResult;
 End;



end;



Procedure TEditorApp.ClearDesktop(Var Event : tEvent);
Var Event1 : TEvent;
Begin
   Event1:=Event;
 repeat
   Event.Command:=cmClose;
   Event.What:=EvCommand;
   Event.InfoPtr:=Nil;
   PutEvent(Event);
   inherited HandleEvent(Event);
   ClearEvent(Event);
 until (Desktop^.Current = Nil);
   Event:=Event1;
   PutEvent(Event);
   ClearEvent(Event);
   EnableCommands([cmFullview]);
End;




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
{
  If Abs((TimeStringToTime('hh:mm:ss',Times)-RefreshTime))>4 then
  Begin
   RefreshTime:=TimeStringToTime('hh:mm:ss',Times);
   st:=GetMAkeField(FClient,Rek.Kod,1);
   DelSpaceRight(St);
   sopen:=TestOpenDate1(FDate);

   Str(StrToInt(Rek.Kod):2,skod);
   RFormatZerro(skod,2);

   If FExists(Path^.Dat.ToArchiv+FDate+'.k'+skod) Then Skassa:=True
   Else SKassa:=False;

   GlobalSkladsName:=' �����:'+st+'  ���:'+FDAte+'  ��࣮�� ����:';
   If Sopen Then GlobalSkladsName:=GlobalSkladsName+'�����'
   Else GlobalSkladsName:=GlobalSkladsName+'������';

   If SKassa Then GlobalSkladsName:=GlobalSkladsName+'  ����:���������'
   Else GlobalSkladsName:=GlobalSkladsName+'  ����:�� ���������';
   DeskTop^.Redraw;
  End;}

end;




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
   GlobalAgentName:=GetAgentField(FAgent,Rek^.Dat.AgentKod);
   DelSpaceRight(St);
   DelSpaceRight(GlobalOperatorName);
   DelSpaceRight(GlobalAgentName);

{$IFNDEF RemoteClient}
{$ELSE}
GetLastOst;
GetLastCl;
GetLastSpr;
{$ENDIF}

   sopen:=TestOpenDate1(FDate);
   skurs:=TestSetupKurs2(FDate);

   Str(StrToInt(Rek^.Dat.Kod):2,skod);
   RFormatZerro(skod,2);

   If FExists(Path^.Dat.ToArchiv+FDate+'.k'+skod) Then Skassa:=True
   Else SKassa:=False;

   GlobalSkladsName:='�����:'+st+{' ���:'+FDAte+}' ����:';
   If Sopen Then GlobalSkladsName:=GlobalSkladsName+'������'+'('+FDAte+')'
   Else GlobalSkladsName:=GlobalSkladsName+'������'+'('+FDAte+')';

   If SKassa Then GlobalSkladsName:=GlobalSkladsName+' ����:���� '
   Else GlobalSkladsName:=GlobalSkladsName+' ����:��� ';

   If SKurs Then
    Begin
     Oper:=FDate;
     If GetKurs(Oper) Then
      Begin
       DelSpace(Oper);
       GlobalSkladsName:=GlobalSkladsName+' ���� USD: '+Oper;
      End
     Else GlobalSkladsName:=GlobalSkladsName+' ���� USD: ??? '
    End
   Else GlobalSkladsName:=GlobalSkladsName+' ���� USD: �� ��������� ';
 (*If CurrentPassword[0]<>#0 Then
    Begin
     Oper:=GetOperatorName(CurrentPassword){+'('+CurrentPassword+')'};
     GlobalSkladsName:=GlobalSkladsName+'������:'+Oper;
    End;*)
   {DeskTop^.Redraw;}
   st:=GlobalSkladsName;
   DelSpaceRight(St);
   DInfoMsg(st,False);
   st:=GetMAkeField(FClient,Rek^.Dat.Kod,1);
   DelSpaceRight(St);
   GlobalSkladsName:=' �����:'+ST+'  ���:'+FDAte+' ';
   DeskTop^.Redraw;
   Delay(800);
   {DeskTop^.Redraw;}
   L := IOResult;
   NoInfoMsg;
   ShowInfo:=False;
End;



procedure TEditorApp.GetEvent(var Event: TEvent);
Var j: Boolean;
    l : Word;
    OperatorElement : PSystemReestr;
Begin


       if (ShiftState and kbRightShift<>0) oR
	     (ShiftState and kbLeftShift<>0) then
                                              Begin
                                               Clock^.Update(3);
                                               GlobalTime:=TimeStringToTime('hh:mm:ss',Times);
                                              End;

       if  ShiftState and kbCtrlShift <> 0 then
                                              Begin
                                               Clock^.Update(1);
                                               GlobalTime:=TimeStringToTime('hh:mm:ss',Times);
                                              End;


       if  ShiftState and kbCtrlShift <> 0 then
                                              Begin
                                               Clock^.Update(1);
                                               GlobalTime:=TimeStringToTime('hh:mm:ss',Times);
                                              End;


       if  (ShiftState and kbCtrlShift<>0) And
           (ShiftState and kbAltShift <> 0) And
           (ShiftState and kbLeftShift <> 0) And
           (ShiftState and kbRightShift <> 0)
         Then
                                              Begin
                                               If Not(SetupPasswordB) Then
                                               If CurrentPassword<>'' Then
                                               Begin
                                               SetupPasswordB:=True;
                                               New(OperatorElement,Init);
                                               if IdentifPassword(CurrentPassword) Then
                                               AddOp1^.AddOperator(kbF4,OperatorElement,CurrentPassword,False);
                                               Dispose(OperatorElement,Done);
                                               SetupPasswordB:=False;
                                               End;
                                              End;

       if (ShiftState and kbAltShift <> 0) And
          (ShiftState and kbCtrlShift <> 0)  then
                                              Begin
                                               TApplication.ClearEvent(Event);
                                               FreshApp;
                                               GlobalTime:=TimeStringToTime('hh:mm:ss',Times);
                                              End;

  TApplication.GetEvent(Event);

    If (ShiftState and kbAltShift <> 0) And
           (ShiftState and kbLeftShift <> 0) Then
          Begin
           Event.What:=evCommand;
           Event.InfoPtr := Nil;
           Event.Command:=cmResize;
           PutEvent(Event);
          End;

  If {(Desktop^.Current=Nil) And Not(Glob.GlobalShow) And} Not( ((Event.What=EvCommand)Or(Event.What=EvKeyDown)
  Or(Event.What=EvMouseMove)Or(Event.What=EvMouseDown)))
  Then
   Begin
    If ((Abs(-GlobalTime+TimeStringToTime('hh:mm:ss',Times))>=AutoRefreshCash)) Then
    Begin
    RefreshCash;
    End;
   End;


  If((Event.What=EvCommand)Or(Event.What=EvKeyDown)
  Or(Event.What=EvMouseMove)Or(Event.What=EvMouseDown))
  Then
   Begin
    GlobalTime:=TimeStringToTime('hh:mm:ss',Times);
    If (Event.What=EvKeyDown) And (Event.KeyCode=kbCtrlRusM) Then
    Begin
    RunScreenSaver;
    RefreshCash;
    End;
   End
  Else
   Begin
   If Nprint^.DAt.ProtectScreen=1 Then
   Begin

If ((Abs(-GlobalTime+TimeStringToTime('hh:mm:ss',Times))>=StrToInt(Nprint^.DAt.TimeProtectScreen)*60))
 Then
 Begin
  RunScreenSaver;
  RefreshCash;
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





If (Desktop^.Current=Nil) And (MenuBar^.Current=Nil) And (Event.What=evNothing) Then
   Begin
    Event.What:=EvCommand;
    Event.InfoPtr := Nil;
    Event.Command:=cmMenu;
    PutEvent(Event);
    EnableCommands([cmFullview]);
    ClearFind;
    {CreatMonopolia(CurrentPAssword)}
   End;
   {
   Else
    DeleteMonopolia(CurrentPAssword)}



If EnableBron=1 Then
   Begin
    EnableCommands([cmSuperZakaz,cmReestrZakaz]);
   End;


 if (Message(Desktop, evBroadcast, cmInfoDebit, nil) = nil)
And (Message(Desktop, evBroadcast, cmInfoReturn, nil) = nil)
And (Message(Desktop, evBroadcast, cmClientStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmMakeStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmTovarStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmStat1, nil) = nil)
And (Message(Desktop, evBroadcast, cmaliaBakPrihod, nil) = nil) then
Begin
EnableCommands([
cmEditDoc,cmPereozen,cmPrihod,cmCorrectSklad,
cmSuperMarket,cmSuperZakaz,cmOperator,cmSkidki,
cmConfigMarket1,cmConfigMarket,cmStat,cmStat1,
cmRewisia,cmRewisiaEdit,cmVozwrat,cmDolg,cmReestrVe,cmReestrDoc,
cmReestrZakaz,cmReestrPrz,cmReestrPrh,cmReestrVzw,
cmReestrRwz,cmInfoDebit,cmInfoReturn,
cmSetupDebitDoc,cmSetupMarketDoc,cmSetEnableSklad,
cmClientStat,cmMakeStat,cmFormZajavka,cmLoadRemote,cmStoreRemote,cmTestComplectZakaz,
cmTovarStat,cmCorrectKassa,cmCalcMenedger,cmSetupZeniInZakaz,
cmaliaBakPrihod,cmImportLink,cmImportLinkG,cmExportToDiger,
{����}{cmCalcRozniza,cmTch,}cmSetupSpravka,cmSetupPrilog,
cmCorrectKAssa,cmTestSrokComment]);

If (EnableBarter=1) Then EnableCommands([cmBArter]);
If (EnablePeremeshenie=1) Then  EnableCommands([cmTransport])

End
Else
  DisableCommands([
cmEditDoc,cmPereozen,cmPrihod,cmCorrectSklad,
cmSuperMarket,cmSuperZakaz,cmOperator,cmSkidki,
cmConfigMarket1,cmConfigMarket,cmBarter,cmStat,cmStat1,
cmRewisia,cmRewisiaEdit,cmVozwrat,cmDolg,cmReestrVe,cmReestrDoc,
cmReestrZakaz,cmReestrPrz,cmReestrPrh,cmReestrVzw,
cmReestrRwz,cmTransPort,cmInfoDebit,cmInfoReturn,
cmSetupDebitDoc,cmSetupMarketDoc,cmSetEnableSklad,
cmClientStat,cmMakeStat,cmFormZajavka,cmLoadRemote,cmStoreRemote,cmTestComplectZakaz,
cmTovarStat,cmCorrectKassa,cmCalcMenedger,cmSetupZeniInZakaz,
cmaliaBakPrihod,cmImportLink,cmImportLinkG,cmExportToDiger,
{����}{cmCalcRozniza,cmTch,}cmSetupSpravka,cmSetupPrilog,
cmCorrectKAssa,cmTestSrokComment]);



if  (Message(Desktop, evBroadcast, cmPrihod, nil) = nil)
And (Message(Desktop, evBroadcast, cmDolg, nil) = nil)
And (Message(Desktop, evBroadcast, cmRewisia, nil) = nil)
And (Message(Desktop, evBroadcast, cmVozwrat, nil) = nil)
And (Message(Desktop, evBroadcast, cmBarter, nil) = nil)
And (Message(Desktop, evBroadcast, cmPereozen, nil) = nil)
And (Message(Desktop, evBroadcast, cmCorrectSklad, nil) = nil)
And (Message(Desktop, evBroadcast, cmTransPort, nil) = nil)
And (Message(Desktop, evBroadcast, cmSuperZakaz, nil) = nil)
And (Message(Desktop, evBroadcast, cmSuperMarket, nil) = nil) Then
EnableCommands([cmLockDay,cmUnLockDay,cmSetupKurs,
cmUnLockDoc,cmReanimClient,cmReanim,cmImportLink,cmImportLinkG,
cmExportToDiger{,cmImportToDiger}])
Else
DisableCommands([cmLockDay,cmUnLockDay,cmSetupKurs,
cmUnLockDoc,cmReanimClient,cmReanim,cmImportLink,cmImportLinkG,
cmExportToDiger{,cmImportToDiger}]);

If (Event.What=EvCommand)And((Event.Command=cmQuit)Or(Event.Command=cmTempLock)) Then
if (Message(Desktop, evBroadcast, cmPrihod, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmVozwrat, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmBarter, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmStat, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmStat1, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmClientStat, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmMakeStat, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmTovarStat, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmAliaBakPrihod, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmRewisia, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmReestrDoc, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmReestrZakaz, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmReestrVe, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmReestrRwz, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmReestrPrh, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmReestrPrz, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmReestrVzw, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmInfoDebit, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmInfoReturn, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmDolg, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmPereozen, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmSuperMarket, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmSuperZakaz, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmTransPort, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmCorrectSklad, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmOperator, nil) <> nil) then ClearEvent(Event);

{
If(Message(Desktop, evBroadcast, cmSuperMarket, nil) = nil)
And (Message(Desktop, evBroadcast, cmSuperZakaz, nil) = nil)
And (Message(Desktop, evBroadcast, cmDolg, nil) = nil)
And (Message(Desktop, evBroadcast, cmAliaBakPrihod, nil)= nil)
And (Message(Desktop, evBroadcast, cmClientStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmTovarStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmStat1, nil) = nil)
And (Message(Desktop, evBroadcast, cmMakeStat, nil) = nil)

   Then
        EnableCommands([cmSetupMArketDoc,cmSetupDebitDoc,
        cmSetupZeniInZakaz,
           cmExportLink,cmImportLink,cmExportToDiger,cmImportToDiger])
Else DisableCommands([cmSetupMArketDoc,cmSetupDebitDoc,
     cmSetupZeniInZakaz,cmExportLink,cmImportLink,cmExportToDiger,cmImportToDiger]);
}

(*
if StrToInt(CurrentPassword)<>0 Then
    DisableCommands([cmGlobalAdminLock,cmGlobalAdminUnLock])
Else
    EnableCommands([cmGlobalAdminLock,cmGlobalAdminUnLock]);
*)
{�몫�祭� �� �������������
If FindParam('/DD') Then
 DisableCommands([cmPrintDebitDolg,cmCalcMenedger])
Else
 EnableCommands([cmPrintDebitDolg,cmCalcMenedger]);
}

If EnableBron=0 Then
     DisableCommands([cmSuperZakaz,cmReestrZakaz]);


If (EnableOtkat=1) Then
  EnableCommands([cmViewOplataOtkat,cmInputOplOtkat,cmPrintOtkatDolg])
  Else DisableCommands([cmViewOplataOtkat,cmInputOplOtkat,cmPrintOtkatDolg]);


If (EnableBarter=1) Then
  EnableCommands([cmViewOplataBarter,cmCAlcSaldoBArter,cmItogBarter])
  Else DisableCommands([cmBArter,cmViewOplataBarter,cmCAlcSaldoBArter,cmItogBarter]);


If EnableAverageOtdel=0 Then
 DisableCommands([cmLoadRemote,cmStoreRemote,cmTestComplectZakaz,cmFormZajavka]);



{
 if (Message(Desktop, evBroadcast, cmTovarStat, nil) = nil) And
    (Message(Desktop, evBroadcast, cmReestrDoc, nil) = nil) And
    (Message(Desktop, evBroadcast, cmReestrZakaz, nil) = nil) And
    (Message(Desktop, evBroadcast, cmCorrectSklad, nil) = nil) And
    (Message(Desktop, evBroadcast, cmPrihod, nil) = nil) And
    (Message(Desktop, evBroadcast, cmDolg, nil) = nil)  Then Heap^.Show
    Else
    Heap^.Hide;
}
{
If (Desktop^.Current=Nil) Then Heap^.Show
    Else
    Heap^.Hide;
}

If (Desktop^.Current=Nil) Then Heap^.Show
    Else
     If Not FindParam('/HEAP') Then Heap^.Hide;

  If FindParam('/TERMINAL') Or (Terminal=1) Then
  Begin
   If StrToInt(CurrentPassword)<>0 Then
   DisableCommands([cmDosShell])
   Else
   EnableCommands([cmDosShell]);
  End;


l:=IOResult;

{
If (Desktop^.Current=Nil) And (Desktop^.TopView=Nil)  Then
   Begin
    EnableCommands([cmExit]);
   End
   Else DisableCommands([cmExit]);
}




end;



procedure TEditorApp.HandleEvent(var Event: TEvent);
{
procedure Calculator;
begin
  InsertWindow(New(PCalculator, Init));
end;
}

procedure Calendar;
begin
  InsertWindow(New(PCalendarWindow, Init));
end;

{
Procedure ShowCalendar;
 Var
 CalendarWindow: PCalendarWindow;
Begin
 CalendarWindow := New(PCalendarWindow, Init(New(PDayDialog,Init)));
 DeskTop^.Insert(CalendarWindow);
End;
}


VAr R : TRect;
    s : String;
    Time : LongInt;
    st1,st2 :TDAteString;
    R1 : TREct;
    Res,c : Word;
begin
{
  Time:=TimeStringToTime('hh:mm:ss',Times);
  If (Abs(GlobalTime-Time)>10) And (Event.What <> EvKeyDown) Then
    Begin
     RunScreenSaver;
     GlobalTime:=TimeStringToTime('hh:mm:ss',Times);
     Time:=GlobalTime;
    End;
}

  inherited HandleEvent(Event);

  case Event.What of
    evCommand:
      case Event.Command of

       cmCalculator: MyCalculator^.Start;

        cmBalance:Begin
                   Selection(6);
                  End;
       cmBalance1:
                  Begin
                   If Password(3) Then Selection(11);

                  End;
        cmBalanceDolg:Begin
                   If Password(3) Then TestCalcDolgClient;
                  End;

        cmComment:Begin
                   Res:=0;
                   Res:=SelectImport(39);
                   if Res=2 Then
                    Begin
                     ClearEvent(Event);
                     Exit;
                    End;
                    Case Res Of
                    0:Begin
                       If Password(21) Then
                        Begin
                         ClearDesktop(Event);
                         PZ^.Start;
                       End;
                       ClearEvent(Event);
                      End;
                    1:Begin
                       If Password(3) Then TestRange;
                      End;
                    Else;
                    End;
                    ClearEvent(Event);

                  End;



       cmCalcMenedger :If Password(7) Then CalcMenedger1;

         cmSetupKurs :Begin
                                ClearEvent(Event);
                                If Password(2) Then SetupKurs(FDAte,False);
                               End;

       cmMArketStat: Begin
                      ClearEvent(Event);
                      Selection(5);
                     End;

            cmConfigPrint2: If Password(2) Then PrintConfig2;
            cmConfigPrint : If Password(2) Then PrintConfig;
                  cmAbout:
                  Begin
                  { About;}

                  CalcTulaDeclareOborot;
                  {TestNet;}
                  {TestNetworks;}
                  End;


            cmWindowsManager: WindowManager;


   cmInfoDebit    :Begin
                    ClearDesktop(Event);
                    InfoDebitWindow^.OpenDebitWindow;
                    ClearEvent(Event);
                   End;


   cmInfoReturn   :Begin
                    ClearDesktop(Event);
                    DynamicReturn^.OpenDynamicReturnWindow;
                    ClearEvent(Event);
                   End;


   cmStat         :Begin
                    If Password(2) Then
                    Begin
                                ClearDesktop(Event);
                                StatWindow^.OpenStatWindow;
                                ClearEvent(Event);
                    End;
                   End;

   cmStat1        :Begin
                    If Password(2) Then
                    Begin
                                ClearDesktop(Event);
                                SelectClientStat1^.OpenSelectClientWindow;
                                ClearEvent(Event);
                    End;
                   End;

 { �� ���� �����-�
   cmCalcAgentStat: If Password(2) Then CalcDolgOplataAgent;}


{$IFDEF DPMI}
   cmClientStat   :Begin
                    If Password(2) Then
                    Begin
                                ClearDesktop(Event);
                                SelectClientStat^.OpenSelectClientWindow;
                                ClearEvent(Event);
                    End;
                            End;
   cmMakeStat    :Begin
                    If Password(2) Then
                    Begin
                     ClearDesktop(Event);
                     SelectMakeStat^.OpenSelectMAkeWindow;
                     ClearEvent(Event);
                    End;
                  End;
   cmDeclare : Begin
                If Password(4) Then
                Begin
                 ClearDesktop(Event);
                 SelectClass;
                 ClearEvent(Event);
                End;
               End;

   cmDeclare2006 : Begin
                If Password(4) Then
                Begin
                 ClearDesktop(Event);
                 CalcDeclareOborot;
                 ClearEvent(Event);
                End;
               End;

   cmCalcRozniza  :Begin
                                                  If Password(4) Then
                                                  Begin
                                                        ClearDesktop(Event);
                                                        CalcTCh;
                                                        ClearEvent(Event);
                                                  End;
                   End;

   cmCalcRoznizaR :Begin
                                                  If Password(4) Then
                                                  Begin
                                                        ClearDesktop(Event);
                                                        CalcTChReturn;
                                                        ClearEvent(Event);
                                                  End;
                   End;

        cmTCH     :Begin
                                                  If Password(4) Then
                                                  Begin
                                                        ClearDesktop(Event);
                                                        CalcParusTCh;
                                                        ClearEvent(Event);
                                                  End;
                   End;

        cmBuchOtch          :Begin
                                                  If Password(4) Then
                                                  Begin
                                                        {ClearDesktop(Event);}
{$IFDEF Tabak}
{�� ���졥 ��⠪��� 09/06/2004 � � ���� ����� �� �㦭� �ਠ�� �த��}
											 CalcOborot;
                                                        {CalcBux;}
{$Else}
											 CalcOborot;
{$ENDIf}
                                                        ClearEvent(Event);
                                                  End;
                             End;
{$ENDif}

         cmPrintBakshi: Selection(12);
         cmStopServer : CalcFeliks;
(*
      cmClearBase    :Begin
                                                  If Password(21) Then
                                                  Begin
                                                  ClearDesktop(Event);
                                                  PZ^.Start;
                                                  End;
                                                  ClearEvent(Event);
                    End;
*)

         cmCalcTPReport:Begin
                         SelectionHZRazdel;
                        End;
         cmCalcBuch :Begin
                      CalcBuch;
                     End;

{
  cmALIABAkPrihod:Begin
                    If Password(2) Then
                    Begin
                     ClearDesktop(Event);
                     PrihodStat^.OpenPrihodStatWindow;
                     ClearEvent(Event);
                    End;
                  End;
}
                 cmOstatki_Market: Begin
                                             {If Password(2) Then} Selection(3);
                                            End;

   cmTovArStat   :Begin
                    If Password(2) Then
                                                  Begin
                                                        ClearDesktop(Event);
                                                        TovarStatWindow^.OpenTovarStatWindow;
                                                        ClearEvent(Event);
                                                  End;
                           End;


cmKassaStat   : If Password(7) Then FormReportKAssa;

cmCalcRoute   : If Password(2) Then CreatRouteReport;






      else
        Exit;
      end;
  else
    ClearEvent(Event){Exit};
  end;
  ClearEvent(Event);
end;



procedure TEditorApp.InitMenuBar;
var
  R : TRect;
  s : ArtikulStr;
begin
  GetExtent(R);
  s:=' ';
  R.B.Y := R.A.Y + 1;
{$IFNDEF  RemoteClient}
  MenuBar := New(PMenuBar, Init(R,
  NewMenu(
      NewSubMenu('~E~',hcNoContext,
      NewMenu(
      NewItem('~�~����','Alt-9',KbAlt9 , cmConfigPrint, hcNoContext,
      NewItem('��~�~��� �������⥫쭮', '',KbNoKey{Alt2} ,cmConfigPrint2,hcDosShell,
      NewItem('~�~�ᯥ��� ����', 'Alt-0',KbAlt0,cmWindowsManager,hcDosShell,
      NewItem('~�~�������', 'Alt-�',KbAltRusK , cmCalculator, hcDosShell,
      NewItem('~�~ �ணࠬ��', 'F1', kbF1, cmAbout, hcDosShell,
      NewLine(
      NewItem('���� USD', '^�', KbCtrlRusK , cmSetupKurs, hcDosShell,
      NewLine(
      NewItem('~�~�室 � OS', '', kbNoKey, cmDosShell, hcDosShell,
      Nil)))))))))),
      NewSubMenu('~�~����', $A070, NewMenu(
         NewItem('�� ᪫���', 'F2',KbF2, cmTovarStat, hcDosShell,
         NewItem('������ ~�~த��', 'F3',KbF3, cmMarketStat, hcDosShell,
         {NewItem('������ ��࠭�~�~����', '',KbNoKey , cmClearBase, hcDosShell,}
	    Nil))){)},
         {NewItem('~�~����� ��室��', '',KbNoKey, cmAliaBakPrihod, hcDosShell,Nil)))),}
      NewSubMenu('��~�~�஫�', $A070, NewMenu(
         NewItem('������⢮', 'F4',KbF4, cmBalance, hcDosShell,
         NewItem('�㬬�', 'F5',KbF5, cmBalance1, hcDosShell,
         NewItem('����� ���ᨣ���஢', '',KbNoKey, cmBalanceDolg, hcDosShell,
         NewItem('������ ��࠭�祭��', '',KbNoKey, cmComment, hcDosShell,
	    Nil))))),
      NewSubMenu('�~�~�室�', $A070,
         NewMenu(
         NewItem('�롮ઠ �� �~�~�⠢騪��', 'F6',KbF6, cmMakeStat, hcDosShell,
         NewItem('�롮ઠ �� �~�~�������⠬', 'F7',KbF7, cmStat1, hcDosShell,nil))),
      NewSubMenu('�~�~����', $A070, NewMenu(
         NewItem('~�~롮ઠ    ', 'F8',KbF8, cmClientStat, hcDosShell,
         NewItem('�~�~�ᮭ��쭮', 'F9',KbF9, cmStat, hcDosShell,
         NewItem('�� ������⠬', '^�',KbCtrlRusO, cmCalcRoute, hcDosShell,
         NewItem('�� ����⠬', '',KbNoKey, cmCalcTPReport, hcDosShell,
         {NewItem('�� ����⠬', '',KbNoKey, cmCalcAgentStat, hcDosShell,}
         NewItem('�����~�~�� ���㧪�', '^A',KbCtrlRusA, cmCalcMenedger, hcDosShell,
      NewSubMenu('~�~஭������...',hcDosShell,NewMenu(
         NewItem('������ ����~�~��樨', 'Alt-F2',KbAltF2, cmInfoDebit, hcDosShell,
         NewItem('�����⮢', 'Alt-F3',KbAltF3, cmInfoReturn, hcDosShell,
      nil))),
      Nil))))))),
      NewSubMenu('���~�~�', $A005,
      NewMenu(
      NewItem('������ ஧���� �த���', '',KbNoKey , cmCalcRozniza, hcDosShell,
      NewItem('������ ஧���� �������', '',KbNoKey , cmCalcRoznizaR, hcDosShell,
      NewItem('�����饭�� �த���', '',KbNoKey , cmCalcBuch, hcDosShell,
      NewItem('��᫥���� ��室�', '',KbNoKey , cmPrintBakshi, hcDosShell,
      NewItem('���� �� ��室��', '',KbNoKey , cmStopServer, hcDosShell,
      NewItem('������� �த���', '',KbNoKey , cmTCH, hcDosShell,
      NewItem('����⭠� ���������', '',KbNoKey , cmBuchOtch, hcDosShell,
      NewItem('��� ������樨', '',KbNoKey , cmDeclare, hcDosShell,
      NewItem('��� ������樨 2006', '',KbNoKey , cmDeclare2006, hcDosShell,
      NewItem('~�~�������� "�������-��������"', 'Shift-F5',KbShiftF5 , cmOstatki_Market, hcDosShell,
      NewItem('�� ��~�~ᮢ� ���⠬', '',KbNoKey, cmKassaStat, hcDosShell,
	 Nil)))))))))))),
      NewItem('��室','Alt-�',KbAltRusCh , cmQuit, $A030,
      Nil))))))))));

         PbxMenuBar(MenuBar)^.SetMarker(cmColor);
{$ELSE}


  MenuBar := New(PMenuBar, Init(R,
  NewMenu(
      NewSubMenu('~E~',hcNoContext,
      NewMenu(
      NewItem('~�~����','Alt-9',KbAlt9 , cmConfigPrint, hcNoContext,
      NewItem('��~�~��� �������⥫쭮', '',KbNoKey{Alt2} ,cmConfigPrint2,hcDosShell,
      NewItem('~�~�ᯥ��� ����', 'Alt-0',KbAlt0,cmWindowsManager,hcDosShell,
      NewItem('~�~�������', 'Alt-�',KbAltRusK , cmCalculator, hcDosShell,
      NewItem('~�~ �ணࠬ��', 'F1', kbF1, cmAbout, hcDosShell,
      NewItem('��室','Alt-�',KbAltRusCh , cmQuit, $A030,
      Nil))))))),

      {NewItem('�����', 'F2',KbF2, cmTovarStat, hcDosShell,}
      {NewSubMenu('�~�~����', $A070, NewMenu(}
      NewItem('�����', 'F2',KbF2, cmTovarStat, hcDosShell,
      NewItem('~�~롮ઠ', 'F8',KbF8, cmClientStat, hcDosShell,
      NewItem('�~�~�ᮭ��쭮', 'F9',KbF9, cmStat, hcDosShell,
      NewItem('�����~�~�� ���㧪�', '^A',KbCtrlRusA, cmCalcMenedger, hcDosShell,
      NewSubMenu('~�~஭������',hcDosShell,
	 NewMenu(
      NewItem('������ ����~�~��樨', 'Alt-F2',KbAltF2, cmInfoDebit, hcDosShell,
      NewItem('�����⮢', 'Alt-F3',KbAltF3, cmInfoReturn, hcDosShell,
      Nil))),
	 Nil)))))))));



{$EndIF}


end;




procedure TEditorApp.InitStatusLine;
var
  R: TRect;
begin
  Application^.GetExtent(R);
  R.Assign(0, 0, 80, R.B.Y-2{23});
  StatusLine := PStatusLine(RezFile.Get('StatusLine'));
  StatusLine^.Show;
end;


Label Stop;
Var Mode,OrigMode : Integer;
    f : File;
    l : Boolean;
    Res : Byte;
    s : String;

Begin
DistanationSorting:=0;
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

DestroyCash;
Dispose(PathExpImp,Done);
Dispose(PathSklads,Done);
Dispose(Path,Done);
Dispose(NetPath,Done);
Dispose(Rek,Done);
Dispose(RekSF,Done);
Dispose(RekComissioner,Done);
Dispose(ListRange,Done);
Dispose(DixyList,Done);
Dispose(NPrint,Done);
Dispose(NPrintC,Done);
DisposeStr(PathToConfig);

EditorApp.Done;
{TextMode(OrigMode);}
DisposeResursMessage;
FileMode:=Mode;
ExitProc:=OldExit;
end.