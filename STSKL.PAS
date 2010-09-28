{$IFDEF DPMI}

{$DEFINE NewExeFormat}

{$Else}

{$M 61440,0,652800}

{$ENDIF}

{$X+,S-,I-}

{$IfDEF DPMI}

uses

{$DСпециально для Бакши Арвиндера Пал Сингха,Тула,1997-2000}
 Objects,App, Drivers, Memory,Printers,Prihod,CSklad,Vozwrat,OplInfo,Globals,MyCalc,
 Views, Menus, Dialogs, Glob, MsgBox,  {Calc,}Pereozen,Market,MrkTool,Nastr,Protect,Return,ReestrR,
 Gadgets,Validate,Calendar,{CalUnit,}Serv,Vision1,Vision2,Vision3,Vision5,Vision7,
 Prise,ColorTxt,ServStr,CSkid,Barter,Vision4,Vision8,Vision10,
 Reestr,ReestrZ,ReestrVe,Utils,Rewisia,Stat,StatB,StatP,PStat,dStat,TStat,UsrExit,LockInfo,Net{,tvInput},TvMenus,TpDate,
 DbEngine,MAil,Net1,Utils5,Access1,
 Slava,Slava2,
 ReestrP,ReestrV,ReestrPz,BuxOtch,
 MakeHist,UKassa,UKassaT,EndRep,Vision6,ExpImp,Utils1,Utils2,Utils3,Utils4,Trans,TrNakl;

{$Else}
uses
{$F+}
 Objects,App, Drivers, Memory,Printers,Prihod,CSklad,Vozwrat,OplInfo,Globals,MyCalc,
 Views, Menus, Dialogs, Glob, MsgBox,  Pereozen,Market,MrkTool,Nastr,Protect,Return,ReestrR,
 Gadgets,Validate,Calendar,Serv,Vision1,Vision2,Vision3,Vision5,
 Vision7,Prise,ColorTxt,ServStr,CSkid,Barter,Vision4,Vision8,Vision10,
 MAil,Net1,Utils5,Access1,
 Reestr,ReestrZ,ReestrPz,BuxOtch,
 Utils,Rewisia,Stat,StatB,StatP,PStat,DStat,TStat,UsrExit,LockInfo,Net{,TvInput},TvMenus,TpDate,DbEngine,
 Slava,Slava2,ReestrV,ReestrP,ReestrVe,MakeHist,UKassa,UKassaT,EndRep,Vision6,ExpImp,Utils1,
 Utils2,Utils3,Utils4,Trans,TrNakl;

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
{$O TrNakl}
{$O OplInfo}
{$O MAil}
{$O BuxOtch}


{$EndIF}

{$I Compile.INC}


const
  HeapSize = 630 * (1024 div 16);

type

  PEditorApp = ^TEditorApp;
  TEditorApp = object(TApplication)
     Clock: PClockView;
         Heap: PHeapView;

     InfoDebitWindow : PInfoDynamicDebit;
     ItogoWindow : PItogWindow;
     GlReturnWindow: PReturnWindow;
     MyCalculator : PMyCalculator;
     DynamicReturn :PInfoDynamicReturn;
     StatWindow : PStatWindow;
     SelectClientStat :PSelectClientWindow;
     SelectClientStat1 :PSelectClientWindow1;
     SelectMakeStat :PSelectMAkeWindow;
     PrihodStat     :PPrihodStatWindow;
     TovarStatWindow:PTovarStatWindow;
     SkladKAssa : PKAssawindow;
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
  New(Path,Init);
  New(Rek,Init);
  New(RekSF,Init);
  New(RekComissioner,Init);
  New(NPrint,Init);

  ReadNewIni(h);
  If H <> 0 Then Errors('Ошибка чтения файла конфигурации !');
  ReadRek(h);
  If H <> 0 Then Errors('Ошибка чтения файла реквизитов !');
  ReadRekSF(h);
  If H <> 0 Then Errors('Ошибка чтения файла дубликата реквизитов !');
  ReadRekComissioner(h);
  If H <> 0 Then Errors('Ошибка чтения файла реквизитов комиссионера!');

  Registr;



  DeskTop^.Redraw;

{$IfDEF Debug }

{$Else}

If Not FindParam('/'+IntToStr(NoControl,CZena)) Then
   Begin
    If Not(Wzlom) Then  Res:=TestPC;
   End;

{$ENDIF}


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
  If L<>0 Then MemC(IntToStr(L,CKol));
  inherited Idle;
  L := IOResult;
  If L<>0 Then MemC(IntToStr(L,CKol));
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

   GlobalSkladsName:=' Склад:'+st+'  Дата:'+FDAte+'  Торговый день:';
   If Sopen Then GlobalSkladsName:=GlobalSkladsName+'открыт'
   Else GlobalSkladsName:=GlobalSkladsName+'закрыт';

   If SKassa Then GlobalSkladsName:=GlobalSkladsName+'  Касса:заполнена'
   Else GlobalSkladsName:=GlobalSkladsName+'  Касса:не заполнена';
   DeskTop^.Redraw;
  End;}

end;



Procedure TEditorApp.FreshApp;
VAr
    Oper,skod,st :String;
    sopen,skassa,SKurs : boolean;
    L : Word;
Begin
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
End;


procedure TEditorApp.GetEvent(var Event: TEvent);
Var j: Boolean;
    l : Word;
    OperatorElement : PSystemReestr;
Begin


{
       if (ShiftState and kbRightShift<>0)  then
                                              Begin
                                               Clock^.Update(2);
                                               GlobalTime:=TimeStringToTime('hh:mm:ss',Times);
                                              End;
}
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
cmaliaBakPrihod,cmExportLink,cmImportLink,cmExportToDiger,cmImportToDiger,
{новые}cmCalcRozniza,cmTch,cmSetupSpravka,cmSetupPrilog,
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
cmaliaBakPrihod,cmExportLink,cmImportLink,cmExportToDiger,cmImportToDiger,
{новые}cmCalcRozniza,cmTch,cmSetupSpravka,cmSetupPrilog,
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

if StrToInt(CurrentPassword)<>0 Then
    DisableCommands([cmGlobalAdminLock,cmGlobalAdminUnLock])
Else
    EnableCommands([cmGlobalAdminLock,cmGlobalAdminUnLock]);

{выключено за ненадобностью
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




 if (Message(Desktop, evBroadcast, cmTovarStat, nil) = nil) And
    (Message(Desktop, evBroadcast, cmReestrDoc, nil) = nil) And
    (Message(Desktop, evBroadcast, cmReestrZakaz, nil) = nil) And
    (Message(Desktop, evBroadcast, cmCorrectSklad, nil) = nil) And
    (Message(Desktop, evBroadcast, cmPrihod, nil) = nil) And
    (Message(Desktop, evBroadcast, cmDolg, nil) = nil)  Then Heap^.Show
    Else
    Heap^.Hide;

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
                 If MessageBox(^M+#3+'Желаете закончить работу?',Nil,mfOkCancel)<>cmOk Then
                  Begin
                   ClearEvent(Event);
                   Exit;
                  End;
                   RunFromExitProgram;
			   {                If Not(FindParam('/NOCLOSE')) And Not(FindParam('/READONLY')) Then
                 If TestOpenDate1(FDate) And Not(Wzlom) Then
                  Begin
                   If MessageBox(#3^M+#3'Закрыть текущий программный день ('+FDate+')?',Nil,
                   mfConfirmation+mfYesButton+mfCancelButton)=cmYes Then
                   Begin
                    If (TestOplataClientFile(FDate))And(TestPrihod(FDate)) And (TestNewVozwrat(FDate)) Then
                    Begin
                     If BlockDate1(FDate) Then
                     Begin
                      MessageBox(#3^M+#3'День успешно закрыт - доступ к данным за '+
                      FDate+' заблокирован!',Nil,mfInformation+mfCancelButton);
                                                        End;
                    End
                       Else ClearEvent(Event);
                   End;
                  End;
}
                   AddProtocol('Выход оператора из ситемы!','','');
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


       cmBalance: Begin
                   Selection(6);
                  End;

       cmBalance1:
                     Begin
                   If Password(3) Then Selection(11);
                  End;




       cmCalcMenedger :If Password(7) Then CalcMenedger1;


       cmMArketStat: Begin
                      ClearEvent(Event);
                      Selection(5);
                     End;





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
  cmALIABAkPrihod:Begin
                    If Password(2) Then
                    Begin
                     ClearDesktop(Event);
                     PrihodStat^.OpenPrihodStatWindow;
                     ClearEvent(Event);
                    End;
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

  MenuBar := New(PMenuBar, Init(R, NewMenu(
      NewSubMenu('~?~', $A070, NewMenu(
      NewSubMenu('~Т~овар...', $A070, NewMenu(
         NewItem('Движение ~т~овара', '',KbNoKey, cmTovarStat, hcDosShell,
         NewItem('Анализ ~п~родаж', '',KbNoKey, cmMarketStat, hcDosShell,
         NewItem('~А~нализ приходов', '',KbNoKey, cmAliaBakPrihod, hcDosShell,
      NewSubMenu('~Б~алансировка...', $A070, NewMenu(
         NewItem('Количество', '',KbNoKey, cmBalance, hcDosShell,
         NewItem('Сумма', '',KbNoKey, cmBalance1, hcDosShell,Nil))),Nil))))),
      NewSubMenu('Поста~в~щик...', $A070,
         NewMenu(
         NewItem('~В~ыборка', '^F8',KbCtrlF8, cmMakeStat, hcDosShell,nil)),
      NewSubMenu('~К~лиент...', $A070, NewMenu(
         NewItem('~В~ыборка    ', 'Alt-F7',KbAltF7, cmClientStat, hcDosShell,
         NewItem('Выборка по взаимозачетам', '',KbNoKey, cmStat1, hcDosShell,
         NewItem('~П~ерсонально', 'Alt-F8',KbAltF8, cmStat, hcDosShell,
         NewItem('Оплаченные отгрузки по ~а~гентам', '^A',KbCtrlRusA, cmCalcMenedger, hcDosShell,
      NewSubMenu('~Х~ронология...',hcDosShell,NewMenu(
         NewItem('~О~платы консигнации', 'Alt-F2',KbAltF2, cmInfoDebit, hcDosShell,
         NewItem('~В~озвратов', 'Alt-F3',KbAltF3, cmInfoReturn, hcDosShell,
      nil))),
      Nil)))))),
         NewItem('Ка~с~совые листы', '',KbNoKey, cmKassaStat, hcDosShell,
      Nil))))),
      NewItem('Выход','Alt-Ч',KbAltRusCh , cmQuit, $A030,
      Nil)))));

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
{OrigMode := LastMode;}
{TextMode(CO80);}

Res:=0;
LoadResursMessage;

EditorApp.Init(Res);
Case Res of
1:Begin
  SpecialBeep;
  SpecialBeep;
   MessageBox(#3+'Незаконная копия!'+' При дальнейших попытках запуска'+
              '-данные могут быть уничтожены!'+^M+
              #3+' Лучше легально приобрести программное обеспечение,'+
                    +'которому вы доверяете свои деньги.',Nil,mfWarning+mfCancelButton);
   EditorApp.Done;
   {TextMode(OrigMode);}
   FileMode:=Mode;
   DisposeResursMessage;
   Halt;
  End;
2:Begin
  SpecialBeep;
  SpecialBeep;
   MessageBox(#3+'ИСТЕК срок лицензионного соглашения!'^M+
              #3+'Для продления лицензионного соглашения обратитесь к разработчику!',
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
   MessageBox(#3'ИСТЕКАЕТ срок лицензионного соглашения!'^M+
              #3'Для продления лицензионного соглашения обратитесь к разработчику!',
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

If (Not(l) Or (StrToInt(CurrentPassword)=0))    Then
  Begin
  If (l) And (StrToInt(CurrentPassword)=0) Then
    MessageBox(^M+#3'Будьте внимательны! Программа уже запущена в одном из окон Windows!',
    Nil,mfWarning+mfCancelButton);
  OldExit:=ExitProc;
  ExitProc:=@UserExit;
  EditorApp.Run;
  DelFlag;
  End
  Else
   Begin
    SpecialBeep;
    MessageBox(#3'Программа уже запущена в одном из окон Windows!'+
    ' Воспользуйтесь сочетанием клавиш Alt-Tab или Ctrl-Esc для переключения в уже запущенную копию!',
    Nil,mfError+mfCancelButton);
   End;
End;

{   End;}

Dispose(PathExpImp,Done);
Dispose(Path,Done);
Dispose(Rek,Done);
Dispose(RekSF,Done);
Dispose(RekComissioner,Done);
Dispose(NPrint,Done);

EditorApp.Done;
{TextMode(OrigMode);}
DisposeResursMessage;
FileMode:=Mode;
ExitProc:=OldExit;
end.