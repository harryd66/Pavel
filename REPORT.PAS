{$IFDEF DPMI}

{$DEFINE NewExeFormat}

{$Else}

{655360 65520}

{$M 32000,0,655360}

{$ENDIF}

{$X+,S-,I-}

{$IfDEF DPMI}

uses

{$D���樠�쭮 ��� ���� �ࢨ���� ��� �����,�㫠,1997-2000}
 Objects,App, Drivers, Memory,Printers,Prihod,CSklad,Vozwrat,OplInfo,Globals,MyCalc,
 Views, Menus, Dialogs, Glob, MsgBox,  {Calc,}Pereozen,Market,MrkTool,Nastr,Protect,Return,ReestrR,
 Gadgets,Validate,Calendar,{CalUnit,}Serv,Vision1,Vision11,Vision2,Vision3,Vision5,Vision7,
 Prise,ColorTxt,ServStr,CSkid,Barter,Vision4,Vision8,Vision10,Utils6,Net3,
 Reestr,ReestrZ,ReestrVe,Utils,Rewisia,{Stat,StatB,StatP,PStat,dStat,TStat,}UsrExit,LockInfo,Net{,tvInput},Net2,
 TvMenus,TpDate,DbEngine,MAil,Net1,Utils5,Access1,Slava,Slava2,ReestrP,ReestrV,ReestrPz,BuxOtch,
 MakeHist,UKassa,UKassaT,EndRep,Vision6,ExpImp,Utils1,Utils2,Utils3,Utils4,Trans,TrNakl,Oborot;

{$Else}
uses
{$F+}
 Objects,App, Drivers, Memory,Printers,Prihod,CSklad,Vozwrat,OplInfo,Globals,
 MyCalc,Views, Menus, Dialogs, Glob, MsgBox,  Pereozen,Market,MrkTool,Nastr,
 Protect,Return,ReestrR,Gadgets,Validate,Calendar,Serv,Vision1,Vision11,Vision2,
 Vision3,Vision5,Vision7,Prise,ColorTxt,ServStr,CSkid,Barter,Vision4,Vision8,
 Vision10,Utils6,MAil,Net1,Utils5,Access1,Reestr,ReestrZ,ReestrPz,BuxOtch,Utils,
 Rewisia,{Stat,StatB,StatP,PStat,DStat,TStat,}UsrExit,LockInfo,Net{,TvInput},Net2,Net3,
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
    DisposeStr(PathToConfig);
    Dispose(ListRange,Done);
    EditorApp.Done;
    DisposeResursMessage;
    ExitProc:=OldExit;
    Halt;
   End;

  If FindParam('/READONLY') {Or (ReadOnlyConst=1)} Then GlobalReadOnly:=1;

  If FindParam('/ONLYONECOPY') Then ONLYONECOPY:=1;


  If H <> 0 Then Errors('�訡�� ������ 䠩�� ࠧ��饭�� ���䨣��樨!');

  ReadNewIni(h);

  If H <> 0 Then Errors('�訡�� �⥭�� 䠩�� ���䨣��樨 !'+' ���:'+IntToStr(h,CKol));
  ReadRek(Rek,0,h);

  Path^.Dat.FileFlag:=NetComputerName+'.'+IntToStr(StrToInt(Rek^.Dat.Kod),CMantissa);

  If H <> 0 Then Errors('�訡�� �⥭�� 䠩�� ४����⮢ !'+' ���:'+IntToStr(h,CKol));
  ReadRek(RekSF,1,h);
  If H <> 0 Then Errors('�訡�� �⥭�� 䠩�� �㡫���� ४����⮢ !'+' ���:'+IntToStr(h,CKol));
  ReadRek(RekComissioner,2,h);
  If H <> 0 Then Errors('�訡�� �⥭�� 䠩�� ४����⮢ �����ᨮ���!'+' ���:'+IntToStr(h,CKol));

  Registr;

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
cmClientStat,cmMakeStat,cmFormZajavka,cmFormZajavkaMail,cmLoadRemote,cmStoreRemote,cmTestComplectZakaz,
cmTovarStat,cmCorrectKassa,cmCalcMenedger,cmSetupZeniInZakaz,
cmaliaBakPrihod,cmExportLink,cmImportLink,cmExportToDiger,cmImportToDiger,
{����}cmCalcRozniza,cmCalcRoznizaR,cmTch,cmSetupSpravka,cmSetupPrilog,
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
cmClientStat,cmMakeStat,cmFormZajavka,cmFormZajavkaMail,cmLoadRemote,cmStoreRemote,cmTestComplectZakaz,
cmTovarStat,cmCorrectKassa,cmCalcMenedger,cmSetupZeniInZakaz,
cmaliaBakPrihod,cmExportLink,cmImportLink,cmExportToDiger,cmImportToDiger,
{����}cmCalcRozniza,cmCalcRoznizaR,cmTch,cmSetupSpravka,cmSetupPrilog,
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
cmUnLockDoc,cmReanimClient,cmReanim,cmExportLink,cmImportLink,
cmExportToDiger,cmImportToDiger])
Else
DisableCommands([cmLockDay,cmUnLockDay,cmSetupKurs,
cmUnLockDoc,cmReanimClient,cmReanim,cmExportLink,cmImportLink,
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
 DisableCommands([cmLoadRemote,cmStoreRemote,cmTestComplectZakaz,cmFormZajavka,cmFormZajavkaMail]);

  If RemoteAccess=0 Then
  DisableCommands([cmFormZajavkaMail])
  Else EnableCommands([cmFormZajavkaMail]);



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
    s : String;
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
                 If MessageBox(^M+#3+'������ �������� ࠡ���?',Nil,mfOkCancel)<>cmOk Then
                  Begin
                   ClearEvent(Event);
                   Exit;
                  End;
}
                   AddProtocol('��室 ������ �� ����� "������ ������"!','','');
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
               cmCalendar: Calendar;

        cmMaxMin : Begin
                    Video;
                    Dispose(Heap,Done);
                    GetExtent(R);
                    R.A.X := R.B.X -9; R.A.Y := R.B.Y - 1;
                    Heap := New(PHeapView, Init(R));
                    Insert(Heap);
                   End;
       cmBlack:
        begin
          SetScreenMode(ScreenMode and smBW80);
          Application^.Redraw;
          ClearEvent(Event);
          PbxMenuBar(MenuBar)^.SetMarker(cmBlack);
          PbxMenuBar(MenuBar)^.ResetMarkers(cmColor,cmColor,Event.Command);
        end;

                  cmColor:
                  begin
                         SetScreenMode(ScreenMode xor smCO80);
                         Redraw;
                         ClearEvent(Event);
                         PbxMenuBar(MenuBar)^.SetMarker(cmColor);
                         PbxMenuBar(MenuBar)^.ResetMarkers(cmBlack,cmBlack, Event.Command);
                  end;


               cmCalculator: MyCalculator^.Start;

               cmConfigPrint : If Password(2) Then PrintConfig;

      cmTestSrokComment :Begin
                           ClearDesktop(Event);
                           CalcOutComment;
                           ClearEvent(Event);
                         End;

                  cmSetupKurs :Begin
                                ClearEvent(Event);
                                If Password(2) Then SetupKurs(FDAte,False);
                               End;
      cmTestSrokLiz :Begin
                           ClearDesktop(Event);
                           CalcOutLizensia;
                           ClearEvent(Event);
                         End;

                  cmTestSertif: Begin
                                 Selection(4);
                                End;
                  cmTestSrok: Begin
                               Selection(9);
                              End;

{$IFDEF DPMI}

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
                                                        CalcBux;
{$Else}
											 CalcOborot;
{$ENDIf}
                                                        ClearEvent(Event);
                                                  End;
                             End;
{$ENDif}


         cmCalcBuch :Begin
                      CalcBuch;
                     End;

       cmPrintBakshi: Selection(12);

                 cmOstatki_Market: Begin
                                    Selection(3);
                                   End;
               cmTempLock:
                 Begin
                  TempLockKeyBoard;
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
      NewSubMenu('�� ᪫��', $A001, NewMenu(
      NewItem('��ନ஢��� ~�~�室', 'Ctrl+�',KbCtrlRusP , cmPrihod, hcDosShell,
      NewItem('��ନ஢��� ~�~�����', 'Ctrl+�',KbCtrlRusW , cmVozwrat, hcDosShell,
      NewItem('����㯫���� ⮢�� �� ~�~����','',KbNoKey{CtrlRusC}, cmInputToSklad, hcDosShell,
      nil)))),
             NewItem('�� ᪫��~�~','',kbNokey,cmSupermarket,$A015,
             NewItem('�����','',kbNokey,cmSuperZakaz,$A015,
                NewItem('�����','',kbNokey,cmDolg,$A015,

                NewSubMenu('���㬥��', $A005, NewMenu(
                NewSubMenu('�~�~���� ���㬥�⮢...',hcDosShell,NewMenu(
                NewItem('~�~��㧪�', 'F2'     ,KbF2    , cmReestrDoc, hcDosShell,
                NewItem('~�~�室�' , 'Ctrl-F2',KbCtrlF2, cmReestrPrh, hcDosShell,
                NewItem('~�~������' , 'Ctrl-F3',KbCtrlF3, cmReestrRWz, hcDosShell,
          NewItem('~�~��ᥫ��', 'Ctrl-F4',KbCtrlF4, cmReestrVe , hcDosShell,
                NewItem('��~�~���', 'Ctrl-F5',KbCtrlF5, cmReestrVzw, hcDosShell,
                NewItem('�������', 'Ctrl-F6',KbCtrlF6, cmReestrZakaz, hcDosShell,
             Nil))))))),
                NewItem('�~�~�ᬮ����', 'F3',KbF3, cmViewDoc, hcDosShell,
                NewItem('~�~��४�஢���', 'F6',KbF6, cmEditDoc, hcDosShell,
                NewItem('~�~�����', 'F9',KbF9, cmPrintDoc, hcDosShell,
                NewLine(
          NewItem('������ ���� ᪫���', '',kbNoKey , cmGlobalReport, hcDosShell,
                NewItem('����稥 �� ~�~�����', 'Shift-F1',KbShiftF1 , cmPrintSklad, hcDosShell,
                NewItem('�ࠩ�-~�~���', 'Shift-F2',KbShiftF2 , cmPrintPreisList, hcDosShell,
                NewItem('����� ॢ�~�~�� �� ᪫���', 'Shift-F3',KbShiftF3 , cmPrintRewizia, hcDosShell,
                NewItem('����஫�� ���ᮢ~�~� ����', 'Shift-F4',KbShiftF4 , cmPrintKassa, hcDosShell,
                NewItem('������ �த���', '',KbNoKey , cmCalcRozniza, hcDosShell,
                NewItem('~�~�������� "�������-��������"', 'Shift-F5',KbShiftF5 , cmOstatki_Market, hcDosShell,
      NewSubMenu('���ᮢ� �ନ���', $A005,
         NewMenu(
      NewItem('��ᯮ��஢��� ���� � �ନ���', '',KbNoKey , cmExportToDiger, hcDosShell,
      NewItem('��⠭����� ���ᮢ� �ࢥ�', '',KbNoKey , cmStopServer, hcDosShell,
      NewItem('������஢��� ���⪨ � �த��� �� �ନ����', '',KbNoKey , cmImportToDiger, hcDosShell,
         Nil)))),

                NewSubMenu('����஢���...', $A005,
             NewMenu(
                NewItem('����䨪���', '',KbNoKey , cmTestSertif, hcDosShell,
                NewItem('�ப� ॠ����樨', '',KbNoKey , cmTestSrok, hcDosShell,
                NewItem('�᫮��� ���⠢��', '',KbNoKey , cmTestSrokComment, hcDosShell,Nil)))),

                NewItem('����� ����~�~��樨', 'Shift-F6',KbShiftF6 , cmViewOplataRealiz, hcDosShell,
                NewItem('���ᨣ����~�~', 'Shift-F8',KbShiftF8 , cmPrintDebitDolg, hcDosShell,Nil))))))))))))))))),

                NewSubMenu('�����', $A020, NewMenu(
                NewItem('~�~�८業�� ⮢��', 'F8',KbF8 , cmPereozen, hcDosShell,
                NewItem('���४�஢�~�~� ᪫��', 'F7',KbF7 , cmCorrectSklad, hcDosShell,
                NewItem('������~�~ �� ᪫���', 'Ctrl-�',KbCtrlRusR , cmRewisia, hcDosShell,
                NewItem('��~�~�७��� ��६�饭��', 'Ctrl-�',KbCtrlRusU , cmTransport, hcDosShell,
                NewLine(
                NewItem('��~�~� ���', 'Alt-�',KbAltRusG , cmItogi, hcDosShell,
                NewItem('�����஢~�~�� ����', 'Ctrl-�', KbCtrlRusZ , cmLockDay, hcDosShell,
                NewItem('~�~������஢��� ����', 'Ctrl-�', KbCtrlRusD , cmUnLockDay, hcDosShell,
                NewLine(
                NewItem('���� USD', 'Ctrl-�', KbCtrlRusK , cmSetupKurs, hcDosShell,
                nil))))))))))),
         NewSubMenu('��ࢨ�', $A025, NewMenu(
                NewItem('~�~�������', 'Alt-�',KbAltRusK , cmCalculator, hcDosShell,
                NewItem('��������~�~', '',KbNoKey , cmCalendar, hcDosShell,
                NewLine(
                NewItem('~�~��������', 'Alt-�',KbAltRusR ,   cmRekwiziti , hcDosShell,
                NewItem('~�~�������� (�㡫����)', '',KbNoKey ,   cmRekwizitiSF , hcDosShell,
                NewItem('~�~�������� (�����ᮨ���)', '',KbNoKey , cmRekwizitiCom   , hcDosShell,
                NewItem('���� ��� ������', 'Alt-F10', kbAltF10, cmCreatReport, hcDosShell,
                NewItem('~�~������� �����', 'Ctrl-F10', kbCtrlF10, cmRunModem, hcDosShell,
                NewItem('� ���~�~�', 'Shift-F10', kbShiftF10, cmCopyToArc, hcDosShell,
                NewItem('~�~ �ணࠬ��', 'F1', kbF1, cmAbout, hcDosShell,
          NewItem('��室','Alt-�',KbAltRusCh , cmQuit, $A030,
          Nil)))))))))))),Nil))))))))))          {
                Nil)))))))))),
                NewItem('��室','',KbAltRusCh , cmQuit, $A030,nil)))))))))))}
  Else
*)



  MenuBar := New(PMenuBar, Init(R, NewMenu(
      NewSubMenu('~E~',hcNoContext,
      NewMenu(
      NewItem('~�~����','Alt-9',KbAlt9 , cmConfigPrint, hcNoContext,
      NewItem('~�~�������', 'Alt-�',KbAltRusK , cmCalculator, hcDosShell,
      NewItem('~�~ �ணࠬ��', 'F1', kbF1, cmAbout, hcDosShell,
      NewLine(
      NewItem('���� USD', '^�', KbCtrlRusK , cmSetupKurs, hcDosShell,
      NewLine(
      NewItem('~�~�室 � OS', '', kbNoKey, cmDosShell, hcDosShell,
      Nil)))))))),

      NewSubMenu('����', $A005,
      NewMenu(
      NewItem('~�~���䨪���', '',KbNoKey , cmTestSertif, hcDosShell,
      NewItem('�~�~��� ॠ����樨', '',KbNoKey , cmTestSrok, hcDosShell,
      NewItem('~�~᫮��� ���⠢��', '',KbNoKey , cmTestSrokComment, hcDosShell,
      NewItem('~�~�業��� �����⮢', '',KbNoKey , cmTestSrokLiz, hcDosShell,
	 Nil))))),

      NewSubMenu('~�~����', $A005,
      NewMenu(
      NewItem('�~�~���� ஧���� �த���', '',KbNoKey , cmCalcRozniza, hcDosShell,
      NewItem('������ ஧���� ��~�~����', '',KbNoKey , cmCalcRoznizaR, hcDosShell,
      NewItem('���~�~�饭�� �த���', '',KbNoKey , cmCalcBuch, hcDosShell,
      NewItem('~�~�᫥���� ��室�', '',KbNoKey , cmPrintBakshi, hcDosShell,
      NewItem('���~�~��� �த���', '',KbNoKey , cmTCH, hcDosShell,
      NewItem('�����~�~� ���������', '',KbNoKey , cmBuchOtch, hcDosShell,
      NewItem('~�~�������� "�������-��������"', 'Shift-F5',KbShiftF5 , cmOstatki_Market, hcDosShell,Nil)))))))),

      NewItem('��~�~��','',KbAltRusCh , cmQuit, $A030,
	    Nil)))))));

      PbxMenuBar(MenuBar)^.SetMarker(cmColor);


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


Dispose(PathExpImp,Done);
Dispose(Path,Done);
Dispose(Rek,Done);
Dispose(RekSF,Done);
Dispose(RekComissioner,Done);
Dispose(NPrint,Done);
DisposeStr(PathToConfig);
Dispose(ListRange,Done);
EditorApp.Done;
{TextMode(OrigMode);}
DisposeResursMessage;
FileMode:=Mode;
ExitProc:=OldExit;
end.