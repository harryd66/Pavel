{$IFDEF DPMI}

{$DEFINE NewExeFormat}

{$Else}

{655360 65520}

{$M 32000,0,655360}

{$ENDIF}

{$X+,S-,I-}

{$IfDEF DPMI}

uses

{$DСпециально для Бакши Арвиндера Пал Сингха,Тула,1997-2000}
 Objects,App, Drivers, Memory,Printers,Prihod,CSklad,Vozwrat,OplInfo,Globals,MyCalc,
 Views, Menus, Dialogs, Glob, MsgBox,  {Calc,}Pereozen,Market,MrkTool,Nastr,Protect,Return,ReestrR,
 Gadgets,Validate,Calendar,{CalUnit,}Serv,Vision1,Vision11,Vision2,Vision3,Vision5,Vision7,
 Prise,ColorTxt,ServStr,CSkid,Barter,Vision4,Vision8,Vision10,Utils6,Utils7,
 Access7,
 Reestr,ReestrZ,ReestrVe,Utils,Rewisia,{Stat,StatB,StatP,PStat,dStat,TStat,}UsrExit,LockInfo,Net{,tvInput},Net2,
 TvMenus,TpDate,DbEngine,MAil,Net1,Utils5,Access1,Slava,Slava2,ReestrP,ReestrV,ReestrPz,BuxOtch,
 MakeHist,UKassa,UKassaT,EndRep,Vision6,ExpImp,Utils1,Utils2,Utils3,Utils4,Trans,TrNakl,Oborot;

{$Else}
uses
{$F+}
 Objects,App, Drivers, Memory,Printers,Prihod,CSklad,Vozwrat,OplInfo,Globals,
 MyCalc,Views, Menus, Dialogs, Glob, MsgBox,  Pereozen,Market,MrkTool,Nastr,Utils7,
 Protect,Return,ReestrR,Gadgets,Validate,Calendar,Serv,Vision1,Vision11,Vision2,
 Access7,
 Vision3,Vision5,Vision7,Prise,ColorTxt,ServStr,CSkid,Barter,Vision4,Vision8,
 Vision10,Utils6,MAil,Net1,Utils5,Access1,Reestr,ReestrZ,ReestrPz,BuxOtch,Utils,
 Rewisia,{Stat,StatB,StatP,PStat,DStat,TStat,}UsrExit,LockInfo,Net{,TvInput},Net2,
 TvMenus,TpDate,DbEngine,Slava,Slava2,ReestrV,ReestrP,ReestrVe,MakeHist,UKassa,
 UKassaT,EndRep,Vision6,ExpImp,Utils1,Utils2,Utils3,Utils4,Trans,TrNakl,Oborot;





{$O Reestr}
{$O ReestrZ}
{$O ReestrP}
{$O ReestrPz}
{$O ReestrR}
{$O ReestrV}
{$O ReestrVe}
{$O Printers}
{$O Prihod}
{$O CSklad}
{$O Pereozen}
{$O MArket}
{$O Mrktool}
{$O Trans}
{$O Nastr}
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
{$O Vision11}
{$O Prise}
{$O CSkid}
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
{$O Vozwrat}
{$O Barter}
{$O Return}
{$O Rewisia}
{$O UsrExit}
{$O LockInfo}
{$O DbEngine}
{$O Net}
{$O Net1}
{$O Slava}
{$O Slava2}
{$O MakeHist}
{$O Utils}
{$O Ukassa}
{$O UkassaT}
{$O EndRep}
{$O ExpImp}
{$O Utils1}
{$O Utils2}
{$O Utils3}
{$O Utils4}
{$O Utils6}
{$O Utils7}
{$O TrNakl}
{$O OplInfo}
{$O MAil}


{$EndIF}






{$I Compile.INC}


const
  HeapSize = 630 * (1024 div 16);

type

  PEditorApp = ^TEditorApp;
  TEditorApp = object(TApplication)
     Clock: PClockView;
     Heap: PHeapView;
     MyCalculator : PMyCalculator;
     RewisiaWindow : PRewisiaWindow;
     ReestrRewWindow : PReestrRewWindow;
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
    Dispose(ListRange,Done);
    EditorApp.Done;
    DisposeResursMessage;
    ExitProc:=OldExit;
    Halt;
   End;

  If FindParam('/READONLY') {Or (ReadOnlyConst=1)} Then GlobalReadOnly:=1;

  If FindParam('/ONLYONECOPY') Then ONLYONECOPY:=1;


  If H <> 0 Then Errors('Ошибка открытия файла размещения конфигурации!');

  ReadNewCfg(h);

  If H <> 0 Then Errors('Ошибка чтения файла конфигурации !'+' Код:'+IntToStr(h,CKol));
  ReadRek(Rek,0,h);

  Path^.Dat.FileFlag:=NetComputerName+'.'+IntToStr(StrToInt(Rek^.Dat.Kod),CMantissa);

  If H <> 0 Then Errors('Ошибка чтения файла реквизитов !'+' Код:'+IntToStr(h,CKol));
  ReadRek(RekSF,1,h);
  If H <> 0 Then Errors('Ошибка чтения файла дубликата реквизитов !'+' Код:'+IntToStr(h,CKol));
  ReadRek(RekComissioner,2,h);
  If H <> 0 Then Errors('Ошибка чтения файла реквизитов комиссионера!'+' Код:'+IntToStr(h,CKol));

  Registr;

  LastSkladKod:=Rek^.dat.Kod;

  InitCash;
  If Not Wzlom Then LoadCash;

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

AddProtocol('Запуск модуля "ИНВЕНТАРИЗАЦИЯ"!','','');


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
  {If L<>0 Then MemC(IntToStr(L,CKol));}
  inherited Idle;
  L := IOResult;
  {If L<>0 Then MemC(IntToStr(L,CKol));}
  Clock^.Update(0);

  Heap^.Update;

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

 If RemoteAccess=0 Then
 Begin
  If Path^.Dat.ToModem[0]=#0 Then
  DisableCommands([cmRunModem])
  Else EnableCommands([cmRunModem]);
 End
 Else
  Begin
   If Path^.Dat.ToWinLnk[0]=#0 Then
   DisableCommands([cmRunModem])
   Else EnableCommands([cmRunModem]);
  End;

  If RemoteAccess=0 Then
  DisableCommands([cmDialUp])
  Else EnableCommands([cmDialUp]);

  If StrToInt(CurrentPassword)<>0 Then
  DisableCommands([cmCorrectKassa])
  Else EnableCommands([cmCorrectKassa]);

  If StrToInt(CurrentPassword)<>0 Then
  DisableCommands([cmDeactivateMrk])
  Else EnableCommands([cmDeactivateMrk]);

If (Desktop^.Current=Nil) And (MenuBar^.Current=Nil) And (Event.What=evNothing) Then
   Begin
    Event.What:=EvCommand;
    Event.InfoPtr := Nil;
    Event.Command:=cmMenu;
    PutEvent(Event);
    EnableCommands([cmFullview]);
    ClearFind;
   End;

If EnableBron=1 Then
    Begin
     EnableCommands([cmSuperZakaz,cmReestrZakaz]);
    End;

if (Message(Desktop, evBroadcast, cmReestrDoc, nil) <> nil) Or
   (Message(Desktop, evBroadcast, cmReestrZakaz, nil) <> nil) Then
    DisableCommands([cmCreatReport])
Else
    EnableCommands([cmCreatReport]);

DisableCommands([cmTransport]);
DisableCommands([cmBarter]);

 if (Message(Desktop, evBroadcast, cmPrihod, nil) = nil)
And (Message(Desktop, evBroadcast, cmRewisia, nil) = nil)
And (Message(Desktop, evBroadcast, cmDolg, nil) = nil)
And (Message(Desktop, evBroadcast, cmInfoDebit, nil) = nil)
And (Message(Desktop, evBroadcast, cmInfoReturn, nil) = nil)
And (Message(Desktop, evBroadcast, cmVozwrat, nil) = nil)
And (Message(Desktop, evBroadcast, cmBArter, nil) = nil)
And (Message(Desktop, evBroadcast, cmPereozen, nil) = nil)
And (Message(Desktop, evBroadcast, cmCorrectSklad, nil) = nil)
And (Message(Desktop, evBroadcast, cmSuperMarket, nil) = nil)
And (Message(Desktop, evBroadcast, cmSuperZakaz, nil) = nil)
And (Message(Desktop, evBroadcast, cmTransPort, nil) = nil)
And (Message(Desktop, evBroadcast, cmOperator, nil) = nil)
And (Message(Desktop, evBroadcast, cmReestrDoc, nil) = nil)
And (Message(Desktop, evBroadcast, cmReestrZakaz, nil) = nil)
And (Message(Desktop, evBroadcast, cmReestrVe, nil) = nil)
And (Message(Desktop, evBroadcast, cmReestrPrh, nil) = nil)
And (Message(Desktop, evBroadcast, cmReestrPrz, nil) = nil)
And (Message(Desktop, evBroadcast, cmReestrVzw, nil) = nil)
And (Message(Desktop, evBroadcast, cmReestrRwz, nil) = nil)
And (Message(Desktop, evBroadcast, cmSkidki, nil) = nil)
And (Message(Desktop, evBroadcast, cmClientStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmMakeStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmTovarStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmStat1, nil) = nil)
And (Message(Desktop, evBroadcast, cmaliaBakPrihod, nil) = nil) then
Begin
EnableCommands([cmReloadConfig,
cmEditDoc,cmPereozen,cmPrihod,cmCorrectSklad,
cmSuperMarket,cmSuperZakaz,cmOperator,cmSkidki,
cmConfigMarket1,cmConfigMarket,cmStat,cmStat1,
cmRewisia,cmRewisiaEdit,cmVozwrat,cmDolg,cmReestrVe,cmReestrDoc,
cmReestrZakaz,cmReestrPrz,cmReestrPrh,cmReestrVzw,
cmReestrRwz,cmInfoDebit,cmInfoReturn,
cmSetupDebitDoc,cmSetupMarketDoc,cmSetEnableSklad,
cmClientStat,cmMakeStat,cmFormZajavka,cmLoadRemote,cmStoreRemote,cmTestComplectZakaz,
cmTovarStat,cmCorrectKassa,cmCalcMenedger,cmSetupZeniInZakaz,
cmaliaBakPrihod,cmImportLink,cmImportLinkG,cmExportToDiger,cmImportToDiger,
{новые}cmCalcRozniza,cmCalcRoznizaR,cmTch,cmSetupSpravka,cmSetupPrilog,
cmCorrectKAssa,cmTestSrokComment,cmTestSrokLiz]);

If (EnableBarter=1) Then EnableCommands([cmBArter]);
If (EnablePeremeshenie=1) Then  EnableCommands([cmTransport])

End
Else
  DisableCommands([cmReloadConfig,
cmEditDoc,cmPereozen,cmPrihod,cmCorrectSklad,
cmSuperMarket,cmSuperZakaz,cmOperator,cmSkidki,
cmConfigMarket1,cmConfigMarket,cmBarter,cmStat,cmStat1,
cmRewisia,cmRewisiaEdit,cmVozwrat,cmDolg,cmReestrVe,cmReestrDoc,
cmReestrZakaz,cmReestrPrz,cmReestrPrh,cmReestrVzw,
cmReestrRwz,cmTransPort,cmInfoDebit,cmInfoReturn,
cmSetupDebitDoc,cmSetupMarketDoc,cmSetEnableSklad,
cmClientStat,cmMakeStat,cmFormZajavka,cmLoadRemote,cmStoreRemote,cmTestComplectZakaz,
cmTovarStat,cmCorrectKassa,cmCalcMenedger,cmSetupZeniInZakaz,
cmaliaBakPrihod,cmImportLinkG,cmImportLink,cmExportToDiger,cmImportToDiger,
{новые}cmCalcRozniza,cmCalcRoznizaR,cmTch,cmSetupSpravka,cmSetupPrilog,
cmCorrectKAssa,cmTestSrokComment,cmTestSrokLiz]);





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
cmExportToDiger,cmImportToDiger])
Else
DisableCommands([cmLockDay,cmUnLockDay,cmSetupKurs,
cmUnLockDoc,cmReanimClient,cmReanim,cmImportLink,cmImportLinkG,
cmExportToDiger,cmImportToDiger]);

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

If (Desktop^.Current=Nil) Then Heap^.Show
    Else
    Heap^.Hide;


l:=IOResult;


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
    ss : String;
    Time : LongInt;
    st1,st2 :TDAteString;
    R1 : TREct;
    c : Word;
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

  case Event.What of
    evCommand:
Begin
      case Event.Command of
        cmQuit : Begin
{
                 If MessageBox(^M+#3+'Желаете закончить работу?',Nil,mfOkCancel)<>cmOk Then
                  Begin
                   ClearEvent(Event);
                   Exit;
                  End;
}
                   AddProtocol('Выход оператора из модуля "ИНВЕНТАРИЗАЦИЯ"!','','');
                 End;


        Else;
        End;
End;

{
     evKeyDown : Begin
                  Case Event.KeyCode Of
                    kbF1:  Begin
                            Video;
                           End;
                  Else;
                  End;
                 End;
}
        Else;
        End;

  inherited HandleEvent(Event);

  case Event.What of
    evCommand:
      case Event.Command of
                  cmAbout:
                  Begin
                  About;
                  {TestNetworks;}
                  End;

               cmCalculator: MyCalculator^.Start;

               cmConfigPrint : If Password(2) Then PrintConfig;

               cmTempLock:
                 Begin
                  TempLockKeyBoard;
                 End;

           cmRewisia:Begin
                            If Password(2) Then
                            Begin
                             ClearDesktop(Event);
                             RewisiaWindow^.OpenRewisiaWindow;
                             ClearEvent(Event);
                            End;
                  End;

       cmPrintRewizia: Selection(2);

   cmReestrRwz    :Begin
                    ClearDesktop(Event);
                    ReestrRewWindow^.OpenReestrRewWindow;
                    ClearEvent(Event);
                   End;

                  cmSetupKurs :Begin
                                ClearEvent(Event);
                                If Password(2) Then SetupKurs(FDAte,False);
                               End;

            cmConfigPrint2: If Password(2) Then PrintConfig2;
            cmWindowsManager: WindowManager;

    cmRewisiaEdit :Begin
                     If Password(2) Then
                       Begin
                        ClearDesktop(Event);
                        If SelDoc(Assistent) Then EditRewisiaComment(Assistent);
                        ClearEvent(Event);
                       End;
                   End;

    cmTCH :Begin
                     If Password(2) Then
                       Begin
                        ClearDesktop(Event);
                        If SelDoc(Assistent) Then PrintRewisia(Assistent);
                        ClearEvent(Event);
                       End;
                   End;


               cmViewRewisia:
			 Begin
                 {надо дописать диалог выбора даты}
                 ss:=FDAte;
                 If Not DAteDialog(ss) Then Exit;
			  ViewAllRewisia(ss,False,2);
                End;

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
(*
  If Not(FindParam('/FULL')) Then
  MenuBar := New(PMenuBar, Init(R, NewMenu(
      NewSubMenu('На склад', $A001, NewMenu(
      NewItem('Сформировать ~п~риход', 'Ctrl+П',KbCtrlRusP , cmPrihod, hcDosShell,
      NewItem('Сформировать ~в~озврат', 'Ctrl+В',KbCtrlRusW , cmVozwrat, hcDosShell,
      NewItem('Поступление товара на ~с~клад','',KbNoKey{CtrlRusC}, cmInputToSklad, hcDosShell,
      nil)))),
             NewItem('Со склад~а~','',kbNokey,cmSupermarket,$A015,
             NewItem('Заказ','',kbNokey,cmSuperZakaz,$A015,
                NewItem('Долги','',kbNokey,cmDolg,$A015,

                NewSubMenu('Документ', $A005, NewMenu(
                NewSubMenu('Р~е~естр документов...',hcDosShell,NewMenu(
                NewItem('~О~тгрузки', 'F2'     ,KbF2    , cmReestrDoc, hcDosShell,
                NewItem('~П~рихода' , 'Ctrl-F2',KbCtrlF2, cmReestrPrh, hcDosShell,
                NewItem('~Р~евизий' , 'Ctrl-F3',KbCtrlF3, cmReestrRWz, hcDosShell,
          NewItem('~В~екселей', 'Ctrl-F4',KbCtrlF4, cmReestrVe , hcDosShell,
                NewItem('Во~з~врата', 'Ctrl-F5',KbCtrlF5, cmReestrVzw, hcDosShell,
                NewItem('Заказов', 'Ctrl-F6',KbCtrlF6, cmReestrZakaz, hcDosShell,
             Nil))))))),
                NewItem('П~р~осмотреть', 'F3',KbF3, cmViewDoc, hcDosShell,
                NewItem('~К~орректировать', 'F6',KbF6, cmEditDoc, hcDosShell,
                NewItem('~П~ечатать', 'F9',KbF9, cmPrintDoc, hcDosShell,
                NewLine(
          NewItem('Сводный отчет склада', '',kbNoKey , cmGlobalReport, hcDosShell,
                NewItem('Наличие на ~с~кладе', 'Shift-F1',KbShiftF1 , cmPrintSklad, hcDosShell,
                NewItem('Прайс-~л~ист', 'Shift-F2',KbShiftF2 , cmPrintPreisList, hcDosShell,
                NewItem('Бланк реви~з~ии на складе', 'Shift-F3',KbShiftF3 , cmPrintRewizia, hcDosShell,
                NewItem('Контрольный кассов~ы~й лист', 'Shift-F4',KbShiftF4 , cmPrintKassa, hcDosShell,
                NewItem('Сводные продажи', '',KbNoKey , cmCalcRozniza, hcDosShell,
                NewItem('~В~едомость "ОСТАТКИ-ОТГРУЗКА"', 'Shift-F5',KbShiftF5 , cmOstatki_Market, hcDosShell,
      NewSubMenu('Кассовый терминал', $A005,
         NewMenu(
      NewItem('Экспортировать базу в терминал', '',KbNoKey , cmExportToDiger, hcDosShell,
      NewItem('Остановить кассовый сервер', '',KbNoKey , cmStopServer, hcDosShell,
      NewItem('Импортировать остатки и продажи из терминала', '',KbNoKey , cmImportToDiger, hcDosShell,
         Nil)))),

                NewSubMenu('Тестировать...', $A005,
             NewMenu(
                NewItem('Сертификаты', '',KbNoKey , cmTestSertif, hcDosShell,
                NewItem('Сроки реализации', '',KbNoKey , cmTestSrok, hcDosShell,
                NewItem('Условия поставки', '',KbNoKey , cmTestSrokComment, hcDosShell,Nil)))),

                NewItem('Оплата конси~г~нации', 'Shift-F6',KbShiftF6 , cmViewOplataRealiz, hcDosShell,
                NewItem('Консигнатор~ы~', 'Shift-F8',KbShiftF8 , cmPrintDebitDolg, hcDosShell,Nil))))))))))))))))),

                NewSubMenu('Склад', $A020, NewMenu(
                NewItem('~П~ереоценка товара', 'F8',KbF8 , cmPereozen, hcDosShell,
                NewItem('Корректирова~т~ь склад', 'F7',KbF7 , cmCorrectSklad, hcDosShell,
                NewItem('Ревизи~я~ на складе', 'Ctrl-Р',KbCtrlRusR , cmRewisia, hcDosShell,
                NewItem('Вн~у~треннее перемещение', 'Ctrl-У',KbCtrlRusU , cmTransport, hcDosShell,
                NewLine(
                NewItem('Ито~г~и дня', 'Alt-Г',KbAltRusG , cmItogi, hcDosShell,
                NewItem('Блокиров~а~ть день', 'Ctrl-З', KbCtrlRusZ , cmLockDay, hcDosShell,
                NewItem('~Д~еблокировать день', 'Ctrl-Д', KbCtrlRusD , cmUnLockDay, hcDosShell,
                NewLine(
                NewItem('Курс USD', 'Ctrl-К', KbCtrlRusK , cmSetupKurs, hcDosShell,
                nil))))))))))),
         NewSubMenu('Сервис', $A025, NewMenu(
                NewItem('~К~алькулятор', 'Alt-К',KbAltRusK , cmCalculator, hcDosShell,
                NewItem('Календар~ь~', '',KbNoKey , cmCalendar, hcDosShell,
                NewLine(
                NewItem('~Р~еквизиты', 'Alt-Р',KbAltRusR ,   cmRekwiziti , hcDosShell,
                NewItem('~Р~еквизиты (дубликат)', '',KbNoKey ,   cmRekwizitiSF , hcDosShell,
                NewItem('~Р~еквизиты (комиссоинер)', '',KbNoKey , cmRekwizitiCom   , hcDosShell,
                NewItem('Отчет для модема', 'Alt-F10', kbAltF10, cmCreatReport, hcDosShell,
                NewItem('~З~апустить модем', 'Ctrl-F10', kbCtrlF10, cmRunModem, hcDosShell,
                NewItem('В арх~и~в', 'Shift-F10', kbShiftF10, cmCopyToArc, hcDosShell,
                NewItem('~О~ программе', 'F1', kbF1, cmAbout, hcDosShell,
          NewItem('Выход','Alt-Ч',KbAltRusCh , cmQuit, $A030,
          Nil)))))))))))),Nil))))))))))          {
                Nil)))))))))),
                NewItem('Выход','',KbAltRusCh , cmQuit, $A030,nil)))))))))))}
  Else
*)



  MenuBar := New(PMenuBar, Init(R, NewMenu(
      NewSubMenu('~E~',hcNoContext,
      NewMenu(
      NewItem('~П~ечать','Alt-9',KbAlt9 , cmConfigPrint, hcNoContext,
      NewItem('Пе~ч~ать дополнительно', '',KbAlt2 ,cmConfigPrint2,hcDosShell,
      NewItem('~Д~испетчер окон', 'Alt-0',KbAlt0,cmWindowsManager,hcDosShell,
      NewItem('~К~алькулятор', 'Alt-К',KbAltRusK , cmCalculator, hcDosShell,
      NewItem('~О~ программе', 'F1', kbF1, cmAbout, hcDosShell,
      NewLine(
      NewItem('Курс USD', '^К', KbCtrlRusK , cmSetupKurs, hcDosShell,
      NewLine(
      NewItem('~В~ыход в OS', '', kbNoKey, cmDosShell, hcDosShell,
      Nil)))))))))),

      NewSubMenu('~Р~евизия', hcNoContext,
      NewMenu(
      NewItem('~Б~ланк ревизии на складе', 'Shift-F3',KbShiftF3 , cmPrintRewizia, hcNoContext,
      NewItem('~Н~овый документ ревизии', '',KbNoKey , cmRewisia, hcNoContext,
      NewItem('Р~е~естр документов ревизий', '^F3',KbCtrlF3 , cmReestrRwz, hcNoContext,
      NewItem('Пр~о~смотр ревизий', 'F3',KbF3 , cmViewRewisia, hcDosShell,
      NewItem('Печ~а~ть документа ревизии', 'F9',KbF9 , cmTCH, hcNoContext,
      NewItem('Корректировать комментарий ~д~окумента ревизии', 'F6',KbF6, cmRewisiaEdit, hcNoContext,
         Nil))))))),
      NewItem('Вы~х~од','',KbAltRusCh , cmQuit, $A030,
	    Nil))))));

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

DestroyCash;
Dispose(PathExpImp,Done);
Dispose(ListRange,Done);
Dispose(Path,Done);
Dispose(Rek,Done);
Dispose(RekSF,Done);
Dispose(RekComissioner,Done);
Dispose(NPrint,Done);
Dispose(NPrintC,Done);
DisposeStr(PathToConfig);
EditorApp.Done;
DisposeResursMessage;
FileMode:=Mode;
ExitProc:=OldExit;
end.
