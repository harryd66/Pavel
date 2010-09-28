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
 Prise,ColorTxt,ServStr,CSkid,Barter,Vision4,Vision8,Vision10,Utils6,Utils7,Access7,
 TvInput,TvType,Net3,ServStr2,Replagnt,Utils11,Utils8,
 Reestr,ReestrZ,ReestrVe,Utils,Rewisia,{Stat,StatB,StatP,PStat,dStat,TStat,}UsrExit,LockInfo,Net{,tvInput},Net2,
 TvMenus,TpDate,DbEngine,MAil,Net1,Utils5,Access1,Slava,Slava2,ReestrP,ReestrV,ReestrPz,BuxOtch,
 MakeHist,UKassa,UKassaT,EndRep,Vision6,ExpImp,Utils1,Utils2,Utils3,Utils10,
 Utils4,Trans,TrNakl,Oborot;

{$Else}
uses
{$F+}
 Objects,App, Drivers, Memory,Printers,Prihod,CSklad,Vozwrat,OplInfo,Globals,
 MyCalc,Views, Menus, Dialogs, Glob, MsgBox,  Pereozen,Market,MrkTool,Nastr,
 Access7,TvInput,TvType,Net3,ServStr2,Replagnt,Utils11,Utils8,
 Protect,Return,ReestrR,Gadgets,Validate,Calendar,Serv,Vision1,Vision11,Vision2,
 Vision3,Vision5,Vision7,Prise,ColorTxt,ServStr,CSkid,Barter,Vision4,Vision8,
 Vision10,Utils6,Utils7,MAil,Net1,Utils5,Access1,Reestr,ReestrZ,ReestrPz,BuxOtch,Utils,
 Rewisia,{Stat,StatB,StatP,PStat,DStat,TStat,}UsrExit,LockInfo,Net{,TvInput},Net2,
 TvMenus,TpDate,DbEngine,Slava,Slava2,ReestrV,ReestrP,ReestrVe,MakeHist,UKassa,
 UKassaT,EndRep,Vision6,ExpImp,Utils1,Utils2,Utils3,Utils4,Utils10,
 Trans,TrNakl,Oborot;





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
     SkladWindow : PSkladWindow;
     MyCalculator : PMyCalculator;
     SkladKAssa : PKAssawindow;
     ZakazTest : PDeltaTestWindow;
     OperatorWindow : POperatorWindow;
     GlobalAdm : PGlobalLock;
     AddOp1    : PAddOperatorWin;
    Constructor Init(VAr Res : Byte);
    Procedure Determinatecreatfile;
    Procedure DeterminateDocument(k:Byte);
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



Procedure TEditorApp.DeterminateDocument(k:Byte);
Label 1;
var
  {Dlg : PDialog;}
  R : TRect;
  Control : PView;
  C : Word;
  Event : TEvent;
  L : LongInt;

  Control1 : PbxEditLine;{PView}
  Dlg  : PbxEntryDialog;
  AA : Record
  Vid : Word;
  EditPosition : String[CArtikul];
  Dt1: TbxDateRec;
  End;

Begin
ClearFind;
AA.Vid:=Assistent.Vid;
AA.EditPosition:=Assistent.EditPosition;
1:
 R.Assign(20, 7, 61, 20);
Case K Of
0: New(Dlg, Init(R, 'Печать документа'));
1: New(Dlg, Init(R, 'Коррекция документа'));
2: New(Dlg, Init(R, 'Деблокировка документа'));
Else;
End;

Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

R.Assign(1, 2, 19, 12);
Control := New(PRadioButtons, Init(R,
  NewSItem('П~р~иход',
  NewSItem('П~е~реоценка',
  NewSItem('Пр~о~дажа',
  NewSItem('~В~озврат',
  NewSItem('~К~онсигнация',
  NewSItem('Реви~з~ия',
  NewSItem('В~н~.перемещ.',
  NewSItem('З~а~каз',
  NewSItem('ПредЗаказ',
  NewSItem('Касс.операц.',
  Nil))))))))))));

If K in [1..2] Then PCluster(Control)^.SetButtonState($42, False);
Dlg^.Insert(Control);

  R.Assign(1, 1, 16, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид документа:', Control)));

R.Assign(33, 3, 39, 4);
Control := New(PInputLine, Init(R, CArtikul));
Dlg^.Insert(Control);
{  PInputLine(Control)^.Validator := New(PRangeValidator, Init(1, 999));}
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(20, 3, 33, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'N ~д~окумента:', Control)));


R.Assign(26, 5, 36, 6);
{
Control := New(PInputLine, Init(R, CDate));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DAteFiltr, True));
}
      Control1:= New(PbxDateEdit, Init(R, DateMask));
      Control1^.SetEditFlag(dfRequired, True);
      Dlg^.Insert(Control1);
      ExtractDateFromString(AA.Dt1,DateMask,Assistent.D);

  R.Assign(20, 5, 26, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Д~а~та:', Control1)));

Dlg^.SelectNext(False);

If ((k =1) And (Assistent.Vid=1)) Then
Inc(Assistent.Vid);
{
If ((k =1) And (Assistent.Vid=5)) Then
Dec(Assistent.Vid);
}
AA.Vid:=Assistent.Vid;


Dlg^.SetData(AA{Assistent});

c:=Desktop^.ExecView(Dlg);
If c <> CmCancel Then
           Begin
            Dlg^.GetData(AA);

            Assistent.Vid:=AA.Vid;
            Assistent.EditPosition:=AA.EditPosition;
            Assistent.D:=DateToDateStr(AA.Dt1,DateMask);

            DelSpace(Assistent.D);

           If Assistent.EditPosition[0]=#0 Then
            Begin
             Dispose(Control,Done);
             Dispose(Control1,Done);
             Dispose(Dlg,Done);
             MessageBox(#3^M+#3'Не введен номер документа!',Nil,mfError+mfCancelButton);
             Goto 1;
            End;
           DelZerro(Assistent.EditPosition);
           DelSpace(Assistent.EditPosition);

           If TestDate(Assistent.d,L) Then
           Begin
           Case K Of
           1:Begin {Корректировка документа}
                Case Assistent.Vid Of
                 0:Begin
                    TekDate:=Assistent.D;
                    Status:=DocEdit;
                    Event.What:=EvCommand;
                    Event.Command:=cmPrihod;
                    PutEvent(Event);
                    ClearEvent(Event);
                   End;
                 2,4:Begin

            If Assistent.D<>FDate Then
            Begin
               If Password(2) Then
            Begin
                    TekDate:=Assistent.D;
                    Status:=DocEdit;
                    InputZakaz:=0;
                    Event.What:=EvCommand;
                    Event.Command:=cmSuperMarket;
                    PutEvent(Event);
                    ClearEvent(Event);
            End;
            End
            Else
            Begin
                    TekDate:=Assistent.D;
                    Status:=DocEdit;
                    InputZakaz:=0;
                    Event.What:=EvCommand;
                    Event.Command:=cmSuperMarket;
                    PutEvent(Event);
                    ClearEvent(Event);
            End;
                   End;
                 5:Begin
                    TekDate:=Assistent.D;
                    Event.What:=EvCommand;
                    Event.Command:=cmRewisiaEdit;
                    PutEvent(Event);
                    ClearEvent(Event);
                   End;
                 7:Begin
                    AssistentZ.D:=Assistent.D;
                    AssistentZ.EditPosition:=Assistent.EditPosition;
                    TekDate:=Assistent.D;
                    Status:=DocEdit;
                    InputZakaz:=1;
                    Event.What:=EvCommand;
                    Event.Command:=cmSuperZakaz;
                    PutEvent(Event);
                    ClearEvent(Event);
                   End;
                 {предзаказ}
                 8:Begin
                    MessageBox(^M+#3'Воспользуйтесь реестром предзаказов для выполнения этой операции!',Nil,
				mfWarning+mfCancelButton);
                    ClearEvent(Event);
                   End;
                 {кассовая операция}
                 9:Begin
                    MessageBox(^M+#3'Воспользуйтесь реестром кассовых операций для выполнения этой операции!',Nil,
				mfWarning+mfCancelButton);
                    ClearEvent(Event);
                   End;
                 3:Begin
                    TekDate:=Assistent.D;
                    Status:=DocEdit;
                    Event.What:=EvCommand;
                    Event.Command:=cmVozwrat;
                    PutEvent(Event);
                    ClearEvent(Event);
                   End;
                 Else;
                 End;
             End;{1}
           2:Begin
                Case Assistent.Vid Of
                 0:Begin{приход}
                    If Not(FExists(Path^.Dat.ToPrihod+Assistent.D+'.prh')) Then
                     Begin
                      MessageBox(^M+#3'Файл прихода за '+Assistent.D+' не найден!',Nil,
                                  mfInformation+mfCancelButton);
                     End
                     Else
                                 Repeat
                     Until (UnLockPrihod(Assistent.EditPosition,Assistent.D) in [0,2]);
                         End;
                 2,4:Begin{продажа,консигнация}
                    If Not(FExists(Path^.Dat.ToMarket+Assistent.D+'.mrk')) Then
                     Begin
                      MessageBox(^M+#3'Файл продаж за '+Assistent.D+' не найден!',Nil,
                                  mfInformation+mfCancelButton);
                     End
                     Else

                                 Repeat
                     Until (UnLockMarket(Assistent.EditPosition,Assistent.D) in [0,2]);

                     End;
                 7:Begin{заказ}
                    If Not(FExists(Path^.Dat.ToMarket+'zakaz.db')) Then
                     Begin
                      MessageBox(^M+#3'Файл заказов не найден!',Nil,
                                  mfInformation+mfCancelButton);
                     End
                     Else

                                 Repeat
                     Until (UnLockZakaz(Assistent.EditPosition) in [0,2]);

                     End;

                 8:Begin{заказ}
                    If Not(FExists(Path^.Dat.ToMarket+'pzakaz.db')) Then
                     Begin
                      MessageBox(^M+#3'Файл заказов не найден!',Nil,
                                  mfInformation+mfCancelButton);
                     End
                     Else

                                 Repeat
                     Until (UnLockPredZakaz(Assistent.EditPosition) in [0,2]);

                     End;
                 9:Begin{кассовая операция}
                    If Not(FExists(Path^.Dat.ToClient+Assistent.D+'.kas')) Then
                     Begin
                      MessageBox(^M+#3'Файл кассовых операций за '+Assistent.D+' не найден!',Nil,
                                  mfInformation+mfCancelButton);
                     End
                     Else
                      Repeat
                      Until (UnLockKassa(Assistent.EditPosition,Assistent.D) in [0,2]);
                   End;

                 3:Begin{возврат}
                    If Not(FExists(Path^.Dat.ToReturn+Assistent.D+'.vzw')) Then
                     Begin
                      MessageBox(^M+#3'Файл возврата за '+Assistent.D+' не найден!',Nil,
                                  mfInformation+mfCancelButton);
                     End
                     Else
                      Repeat
                      Until (UnLockReturn(Assistent.EditPosition,Assistent.D) in [0,2]);
                   End;
                 5:Begin{ревизия}
                    If Not(FExists(Path^.Dat.ToRewisia+Assistent.D+'.rwz')) Then
                     Begin
                      MessageBox(^M+#3'Файл ревизии за '+Assistent.D+' не найден!',Nil,
                                  mfInformation+mfCancelButton);
                     End
                     Else
                      Repeat
                      Until (UnLockRewisia(Assistent.EditPosition,Assistent.D) in [0,2]);
                   End;
                 Else;
                 End;

             End;{2}
           0:Begin
                {Status:=DocPrint;}
                Case Assistent.Vid Of
                 0:Begin
                   If MessageBox(^M+#3'Печатать накладную прихода N '+Assistent.EditPosition+' от '+Assistent.D+'?',Nil,
                     mfConfirmation+mfOKCancel)=cmOk Then
                             PrintPrihod(Assistent);

                   If (Pharm=1) Then
                   If MessageBox(^M+#3'Печатать накладную комиссии по документу '+Assistent.EditPosition+' от '+
                            Assistent.D+'?',Nil,
                     mfConfirmation+mfOKCancel)=cmOk Then
                    PrintPrihodAsMarket(Assistent);


                   End;

                 3:Begin
                    If NewPrintVozwrat(Assistent) Then PrintRashodOrder(Assistent);
                   End;
                 1:PrintAktPrz(Assistent);
                 6:PrintTransport(Assistent);
                 7:PrintZakaz(Assistent,NprintC^.DAt.CopyZakaz);
                 8:PrintZakaz(Assistent,NprintC^.DAt.CopyZakaz);
                 2,4:PrintNakl(Assistent,NprintC^.DAt.CopyNaklC);
                 5 :Begin
                     PrintRewisia(Assistent);
                     {код печати ревизии}
                    End;
                 Else;
                 End;
             End;
           Else;
           End;{Case K Of}
           End
           Else
            Begin
             Dispose(Control,Done);
             Dispose(Control1,Done);
             Dispose(Dlg,Done);
             MessageBox(#3^M+#3'Недопустимое значение даты!',Nil,mfError+mfCancelButton);
             Goto 1;
            End;
           End;
Dispose(Control,Done);
Dispose(Control1,Done);
Dispose(Dlg,Done);
End;



Procedure TEditorApp.Determinatecreatfile;
Label 1;
var
  {Dlg : PDialog;}
  R : TRect;
  Control : PView;
  C : Word;
  L : LongInt;
  SDAte : TDAteSTring;
  Control1 : PbxEditLine;{PView}
  Dlg  : PbxEntryDialog;
  A : Record
  Vid : Word;
  Dt1: TbxDateRec;
  End;


Begin
ClearFind;
1:
 A.Vid:=3;

R.Assign(20, 7, 60, 22);
New(Dlg, Init(R, 'Аварийное создание файлов'));

Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

R.Assign(2, 2, 23, 14);
Control := New(PRadioButtons, Init(R,

  NewSItem('П~р~иход',
  NewSItem('П~е~реоценка',
  NewSItem('~В~озврат',
  NewSItem('Реви~з~ия',
  NewSItem('~П~родажа',
  NewSItem('~О~плата консиг.',
  NewSItem('Про~т~окол опер.',
  NewSItem('Протоко~л~ возв.',
  NewSItem('Касса ВЗ',
  NewSItem('Вн~у~тр.перемещен.',
  NewSItem('Оплата бонусов',
  NewSItem('Кассовых операций',
  Nil))))))))))))));
Dlg^.Insert(Control);

  R.Assign(1, 1, 16, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид документа:', Control)));

R.Assign(26, 5, 36, 6);
{
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DAteFiltr, True));
}
      Control1:= New(PbxDateEdit, Init(R, DateMask));
      Control1^.SetEditFlag(dfRequired, True);
      Dlg^.Insert(Control1);
      ExtractDateFromString(A.Dt1,DateMask,FDate);


  R.Assign(25, 4, 31, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Д~а~та:', Control1)));

Dlg^.SelectNext(False);

a.Vid:=3;
Dlg^.SetData(A);

c:=Desktop^.ExecView(Dlg);
If c <> CmCancel Then
           Begin
            Dlg^.GetData(A);
            SDate:=DateToDateStr(A.Dt1,DateMask);

            DelSpace(SDAte);
           If TestDate(SDAte,L) Then
            Begin
             {вставка для кассовых операций}
             If A.Vid=11 Then A.Vid:=13;
             CreatSpecialFile(A.Vid,SDAte);
            End;
           End;
Dispose(Control,Done);
Dispose(Control1,Done);
Dispose(Dlg,Done);
End;


{
Procedure MyTest;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  SpinBar : PbxSpinBar;

begin
R.Assign(18, 6, 64, 15);
New(Dlg, Init(R, 'Dialog Design'));
Dlg^.HelpCtx:=$E002;

R.Assign(31, 4, 33, 5);
SpinBar := New(PbxSpinBar, Init(R));
SpinBar^.SetParams(0, -50,50, 1,1);
SpinBar^.Options:= SpinBar^.Options and not ofSelectable;

 R.Assign(24, 4, 30, 5);
Dlg^.Insert(New(PbxSpinEdit, Init(R, '###', SpinBar)));
Dlg^.Insert(SpinBar);

Dlg^.SelectNext(False);
c:=DeskTop^.ExecView(Dlg);
Dispose(Dlg,Done);
end;
}

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
    Dispose(ListRange,Done);
    EditorApp.Done;
    DisposeResursMessage;
    ExitProc:=OldExit;
    Halt;
   End;

  If FindParam('/READONLY') {Or (ReadOnlyConst=1)} Then GlobalReadOnly:=1;

  If FindParam('/ONLYONECOPY') Then ONLYONECOPY:=1;


  If H <> 0 Then Errors('Ошибка открытия файла размещения конфигурации!');

  ReadNewCFG(h);

  If H <> 0 Then Errors('Ошибка чтения файла конфигурации !'+' Код:'+IntToStr(h,CKol));
  ReadRek(Rek,0,h);

  Path^.Dat.FileFlag:=NetComputerName+'.'+IntToStr(StrToInt(Rek^.Dat.Kod),CMantissa);

  If H <> 0 Then Errors('Ошибка чтения файла реквизитов !'+' Код:'+IntToStr(h,CKol));
  ReadRek(RekSF,1,h);
  If H <> 0 Then Errors('Ошибка чтения файла дубликата реквизитов !'+' Код:'+IntToStr(h,CKol));
  ReadRek(RekComissioner,2,h);
  If H <> 0 Then Errors('Ошибка чтения файла реквизитов комиссионера!'+' Код:'+IntToStr(h,CKol));


{$IFDef RemoteClient}
  InitCash;
{$EndIf}

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

{
R.Assign(1, 12, 27, 22);
ControlSklad := New(PRadioButtons, Init(R,
  NewSItem('12345678901234567890',
  NewSItem('12345678901234567890',
  NewSItem('12345678901234567890',
  NewSItem('12345678901234567890',
  NewSItem('12345678901234567890',
  NewSItem('12345678901234567890',
  NewSItem('12345678901234567890',
  NewSItem('12345678901234567890',
  NewSItem('12345678901234567890',
  NewSItem('12345678901234567890', Nil))))))))))));
Desktop^.Insert(ControlSklad);
}

(*
If FindParam('/AUTODETECT') Or (AutoDetect=1) Then
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
*)

NewTmpAndAnalys;

NewTmpAndAnalysLocal;
If FExists(Path^.Dat.ToTemp+'sleep.txt') Then
 Begin
  Assign(f,Path^.Dat.ToTemp+'sleep.txt');
  h:=IOResult;
  Erase(f);
  h:=IOResult;
 End;

end;





Procedure TEditorApp.Idle;
{
function IsTileable(P: PView): Boolean; far;
begin
  IsTileable := (P^.Options and ofTileable <> 0) and
    (P^.State and sfVisible <> 0);
end;
}
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
   If ShowInfo Then Exit;
   If LastSkladKod[0]=#0 Then Exit;

   ShowInfo:=True;
   st:=GetMAkeField(FClient,Rek^.Dat.Kod,1);
   GlobalOperatorName:=GetOperatorField(FNAme,CurrentPassword);
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
                                               Begin
                                               AddOp1^.AddOperator(kbF4,OperatorElement,CurrentPassword,False);
                                               End;
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
    {CreatMonopolia(CurrentPAssword)}
   End;
   {
   Else
    DeleteMonopolia(CurrentPAssword)}

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
cmaliaBakPrihod,cmImportLink,cmImportLinkG,cmExportToDiger,{cmImportToDiger,}
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
cmaliaBakPrihod,cmImportLink,cmImportLinkG,cmExportToDiger,{cmImportToDiger,}
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

{
if StrToInt(CurrentPassword)<>0 Then
    DisableCommands([cmGlobalAdminLock,cmGlobalAdminUnLock])
Else
    EnableCommands([cmGlobalAdminLock,cmGlobalAdminUnLock]);
}
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

{if (Message(Desktop, evBroadcast, cmTovarStat, nil) = nil) And
    (Message(Desktop, evBroadcast, cmReestrDoc, nil) = nil) And
    (Message(Desktop, evBroadcast, cmReestrZakaz, nil) = nil) And
    (Message(Desktop, evBroadcast, cmCorrectSklad, nil) = nil) And
    (Message(Desktop, evBroadcast, cmPrihod, nil) = nil) And
    (Message(Desktop, evBroadcast, cmDolg, nil) = nil)  Then Heap^.Show
    Else
    Heap^.Hide;}


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
    c : Word;
    f : File;
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
                   AddProtocol('Выход оператора из модуля "Конфигурация и инструменты"!','','');
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

      cmAbout: About;
               cmCalculator: MyCalculator^.Start;
               cmUnLockDoc:If Password(5) Then DeterminateDocument(2);
               cmUnLockPrh:Begin
                            Assign(f,Path^.Dat.ToFlagDir+'lockadmp');
	                       If Password(7) Then UnlockImportPrihod(f);
                           End;

   cmViewCorrectSklad:
                   Begin
                    If Password(5) Then
                    Begin
                    ViewCorrect;
                    End;
                   End;

   cmViewCorrectVozwrat:
                   Begin
                    If Password(5) Then
                    Begin
                    ViewVozwrat;
                    End;
                   End;

                 cmClearBase: if StrToInt(CurrentPassword)=0 Then NullIDX;


                 cmMakeHisIndex: if Password(5) Then MAkeClientIndex;

                 cmMakeDocIndex: if Password(5) Then MAkeClientDocumentIndex;

                 cmMakeTovarIndex: if Password(5) Then MAkeClientTovarIndex;

          cmMakeZakazIndex: if Password(5) Then MAkeZakazIndex{ExtendZakaz};

      cmMakePredZakazIndex: if Password(5) Then MAkePredZakazIndex{ExtendZakaz};

         cmMakeHisIndexMrk: if Password(5) Then MAkeIndexMrk;

                 cmMakeCOplIndex: if Password(5) Then MAkeClientOplataIndex;

                 cmMakeCReturnIndex: if Password(5) Then MAkeClientReturnIndex;

       cmCreatSpecialFile :If Password(5) Then DeterminateCreatFile;



      cmSetupSpravka:Begin
                                                  If Password(3) Then
                                                  Begin
                                                  ClearDesktop(Event);
                                                  NastrRazdel(False);
                                                  End;
                                                  ClearEvent(Event);
                     End;

      cmSetupZakupka : Begin
                                                  If Password(7) Then  SetupVidZakupka;
                                                  ClearEvent(Event);
                       End;

      cmSetupPrilog:Begin
                                                  If Password(3) Then
                                                  Begin
                                                  ClearDesktop(Event);
                                                  NastrRazdel(True);
                                                  End;
                                                  ClearEvent(Event);
                    End;


         cmConfigMarket:Begin
                                                  If Password(3) Then
                                                  Begin
                                                  ClearDesktop(Event);
                                                  NastrMarket;
                                                  End;
                                                  ClearEvent(Event);
                        End;

         cmSetupAkzis:Begin
                                                  If Password(5) Then
                                                  Begin
                                                  InputBuhKoeffizient;
                                                  End;
                                                  ClearEvent(Event);
                      End;

         cmConfigMarket1:Begin
                                                  If Password(5) Then
                                                  Begin
                                                  ClearDesktop(Event);
                                                  NewNastrMarket;
                                                  End;
                                                  ClearEvent(Event);
                         End;

         cmConfigMarket2:Begin
                                                  If Password(3) Then
                                                  Begin
                                                  ClearDesktop(Event);
                                                  NewNastrMarket2;
                                                  End;
                                                  ClearEvent(Event);
                         End;

         cmSetupMArketDoc:
                                                 Begin
                                                  If Password(5) Then
                                                  Begin
                                                  ClearDesktop(Event);
                                                  SetupMarketDoc(0);
                                                  End;
                                                  ClearEvent(Event);
                                                 End;


        cmRekwiziti:  ChangeRekwiziti(0,Rek);

        cmRekwizitiSf:  ChangeRekwiziti(1,RekSF);

        cmRekwizitiCom:  ChangeRekwiziti(2,RekComissioner);

         cmSetEnableSklad:
                                                 Begin
                                                  If Password(5) Then
                                                  Begin
                                                  ClearDesktop(Event);
                                                  SetupSklads;
                                                  End;
                                                  ClearEvent(Event);
                                                 End;
         cmSetupDebitDoc:
                                                 Begin
                                                  If Password(5) Then
                                                  Begin
                                                  ClearDesktop(Event);
                                                  SetupMarketDoc(1);
                                                  End;
                                                  ClearEvent(Event);
                                                 End;

   cmRunScreenSaver:Begin
                     RunScreenSaver;
                     GlobalTime:=TimeStringToTime('hh:mm:ss',Times);
                     ClearEvent(Event);
                    End;

  cmLockPeriod   : If StrToInt(CurrentPassword)=0 Then PeriodFromLock(True);
  cmUnLockPeriod : If StrToInt(CurrentPassword)=0 Then PeriodFromLock(False);

         cmIndex     :Begin
                                                 If Password(7) Then
                                                 Begin
                                                  NewIDx;
                                                 End;
                                                 End;


         cmReanim     :Begin
                                                 If Password(7) Then
                                                 Begin
                                                  CreatIDx;
                                                 End;
                                                 End;

         cmReanimSPR  :Begin
                                                 If Password(5) Then
                                                 Begin
                                                  SPRIdx(False);
                                                 End;
                       End;

         cmReanimClient:Begin
                                                 If Password(5) Then
                                                 Begin
                                                  ClientIDX(False);
                                                 End;
                                                 End;


                  cmCalculator: MyCalculator^.Start;


            cmConfig : If Password(5) Then ConfigDistantion(0);
            cmConfigMainBase : If Password(5) Then ConfigDistantion(1);

            cmDistanationSklads : If Password(5) Then ConfigDistantionSklads;


            cmConfigExpImp: If Password(5) Then ConfigExportImport;

            cmConfigEnableOperation : If Password(5) Then NewNastrMarket3;


            cmConfigPrint : If Password(2) Then PrintConfig;

            cmSetupZeniInZakaz : If Password(3) Then SelectAlgoritmZenInZakaz;

            cmImportLink  : If Password(5) Then ImportLinkID;
            cmExportLink  : If Password(5) Then ExportLinkID;

            cmImportLinkG : If Password(5) Then ImportLinkDB;
            cmExportLinkG : If Password(5) Then ExportLinkDB;


            cmCompressMarket: Begin
                                                 If Password(5) Then
                                                 Begin
                                                  CompressMarket(FAlse,St1,St2);
                                                 End;
                                                 ClearEvent(Event);
                                                End;
                  cmCompressDolg  : Begin
                                                 If Password(5) Then
                                                  Begin
                                                   CompressDolg(False);
                                                   ClearEvent(Event);
                                                  End;
                                                End;

    cmDeactivateMrk:Begin
                     SelectDeActivDocument;
                     ClearEvent(Event);
                    End;

  cmUnLockDay        :CloseDate(0);

  cmSetupKurs :Begin
                                ClearEvent(Event);
                                If Password(2) Then SetupKurs(FDAte,False);
                               End;

{$ifdef dpmi}
              cmGlobalAdminLock:Begin
if StrToInt(CurrentPassword)=0 Then
GlobalLockBaza;
                                    End;
                cmGlobalAdminUnLock:Begin
if StrToInt(CurrentPassword)=0 Then
                                      GlobalUnLockBaza;
                                    End;
{$endif}

                  cmTestZakaz :Begin
                                If Password(5) Then
                                 Begin
                                  ZakazTest^.Start;
                                 End;
                                      End;

         cmCorrectKassa: Begin
{$IFDEF NetVersion}
If (StrToInt(CurrentPassword)<>0) And (DisableClose=1) Then
Begin
 MessageBox(^M+#3+NoCorrectKassa^,Nil,mfError+mfCancelButton);
 Exit;
End;
{$EndIf}
                                                        If Password(20) Then
                                                        Begin
                                                         ClearDesktop(Event);
                                                         SkladKassa^.start(True);
                                                        End;
                                                        ClearEvent(Event);
                                                  End;

            cmConfigPrint2: If Password(2) Then PrintConfig2;
            cmWindowsManager: WindowManager;
            cmSortNakl: SelectSortOtgruzka;
            cmSortPrh: SelectSortPrihod;

         cmNameIndex     :If Password(5) Then CreatIDIndex;

  cmSetupPassword :Begin
                    If StrToInt(CurrentPassword)=0 Then
                    SetupPassword;
                   End;

   cmCorrectSklad:Begin
                   ClearDesktop(Event);
                   SkladWindow^.OpenSkladWindow;
                   ClearEvent(Event);
                  End;

                  cmIndexSkidki:Begin
                                 If Password(5) Then NewSkidkiIDX;
                                End;
(*
        cmRekwiziti:  ChangeRekwiziti(0,Rek);

        cmRekwizitiSf:  ChangeRekwiziti(1,RekSF);

        cmRekwizitiCom:  ChangeRekwiziti(2,RekComissioner);
*)
        cmCopyToArc: Begin
                      ArcBaza;
                      Redraw;
                     End;

               cmTempLock:
                 Begin
                  TempLockKeyBoard;
                 End;

         cmOperator    :Begin
                                                  If StrToInt(CurrentPassword)=0 Then
                                                        Begin
                                                         ClearDesktop(Event);
                                                         OperatorWindow^.OpenOperatorWindow;
                                                         ClearEvent(Event);
                                                        End;
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
      NewItem('Пе~ч~ать дополнительно', '',KbNoKey ,cmConfigPrint2,hcDosShell,
      NewItem('~Д~испетчер окон', 'Alt-0',KbAlt0,cmWindowsManager,hcDosShell,
      NewItem('~К~алькулятор', 'Alt-К',KbAltRusK , cmCalculator, hcDosShell,
      NewItem('~О~ программе', 'F1', kbF1, cmAbout, hcDosShell,
      NewLine(
      NewItem('Курс USD', '^К', KbCtrlRusK , cmSetupKurs, hcDosShell,
      NewLine(
      NewItem('~В~ыход в OS', '', kbNoKey, cmDosShell, hcDosShell,
      Nil)))))))))),
      NewSubMenu('Размещение',hcDosShell,
	 NewMenu(
      NewItem('~Р~азмещение баз данных', '',kbCtrlRusJa,cmConfig,hcDosShell,
      NewItem('~Р~азмещение реплицируемых баз данных', '',kbNoKey,cmConfigMainBase,hcDosShell,
      NewItem('Размещение экспорта/~и~мпорта', '',KbAlt3,cmConfigExpImp,hcDosShell,
      NewItem('Размещение складов', '',KbNoKey,cmDistanationSklads,hcDosShell,Nil))))),

      NewSubMenu('На~с~тройка',hcDosShell,
	 NewMenu(
      NewItem('~Д~окументы продажи', '',KbNoKey ,cmSetupMarketDoc , hcDosShell,
      NewItem('Документы конси~г~нации', '',KbNoKey ,cmSetupDebitDoc , hcDosShell,
      NewItem('~З~акупочные цены', '',KbNoKey ,cmSetupZakupka , hcDosShell,
      NewItem('~Ц~ены в заказах', '',KbNoKey,cmSetupZeniInZakaz,hcDosShell,
      NewSubMenu('Сортировка',hcNoContext,
      NewMenu(
      NewItem('Отгрузки', '',KbNoKey,cmSortNakl,hcDosShell,
      NewItem('Прихода', '',KbNoKey,cmSortPrh,hcDosShell,Nil))),
      NewItem('Разделы и доку~м~енты', '',KbAlt8,cmConfigMarket,hcDosShell,
      NewItem('Для акциза', '',KbAlt4 , cmSetupAkzis , hcDosShell,
      NewItem('Общие', '',kbAlt6 , cmConfigMarket1 , hcDosShell,
      NewItem('Общие 2', '',kbAlt7 , cmConfigMarket2 , hcDosShell,
      NewItem('Разрешенные операции', '',kbNoKey , cmConfigEnableOperation  , hcDosShell,
      NewItem('Разрешенные объекты', '',kbAlt5 , cmSetEnableSklad , hcDosShell,
      NewItem('~Р~азделы и ГТД', '',KbNoKey , cmSetupSpravka , hcDosShell,
      NewItem('Разде~л~ы и приложения', '',KbNoKey , cmSetupPrilog , hcDosShell,
	 Nil)))))))))))))),


      NewSubMenu('Инструменты',hcNoContext,
	 NewMenu(
      NewSubMenu('~П~ереиндексация',hcNoContext,
      NewMenu(
      NewItem('~Т~оваров', '',kbNoKey , cmReanim , hcNoContext,
      NewItem('~С~кидок', '',KbNoKey , cmIndexSkidki , hcNoContext,
      NewItem('~К~лиентов', '',KbNoKey , cmReanimClient , hcNoContext,
      NewItem('~З~аказов', '',KbNoKey , cmMakeZakazIndex , hcNoContext,
      NewItem('Предварительных заказов', '',KbNoKey , cmMakePredZakazIndex , hcNoContext,
      NewItem('Отгрузок','',KbNoKey , cmMakeHisIndexMrk, hcNoContext,
      NewItem('~Д~ополнительных справочников', '',kbNoKey , cmReanimSpr , hcDosShell,
      NewItem('~О~боротов клиентов','',KbNoKey , cmMakeHisIndex, hcNoContext,
      NewItem('Документооборота клиентов','',KbNoKey , cmMakeDocIndex, hcNoContext,
      NewItem('Товарооборота клиентов','',KbNoKey , cmMakeTovarIndex, hcNoContext,
      NewItem('О~п~лат клиентов','',KbNoKey , cmMakeCOplIndex, hcNoContext,
      NewItem('~В~озвратов клиентов','',KbNoKey , cmMakeCReturnIndex, hcNoContext,
      Nil))))))))))))),
      NewItem('~К~онсолидация', '',KbNoKey , cmIndex , hcNoContext,
      NewItem('Восстановление товарного справочника', '',kbNoKey , cmNameIndex , hcDosShell,
      NewSubMenu('Компрессия',hcNoContext,
      NewMenu(
      NewItem('Отгрузки', '',kbNoKey , cmCompressMarket , hcNoContext,
      NewItem('Долги', '',KbNoKey , cmCompressDolg , hcNoContext,
         Nil))),

      NewItem('Б~л~окировать период', '',KbNoKey , cmLockPeriod, hcNoContext,
      NewItem('Д~е~блокировать день', '^Д', KbCtrlRusD , cmUnLockDay, hcDosShell,
      NewItem('~Д~еблокировать период','',KbNoKey , cmUnLockPeriod, hcNoContext,
	 Nil)))))))),
      NewSubMenu('Св~я~зи',hcDosShell,NewMenu(
      NewItem('~И~мпорт связей товарного справочника', '',KbNoKey , cmImportLink , hcDosShell,
      NewItem('~Э~кспорт связей товарного справочника', '',KbNoKey , cmExportLink , hcDosShell,
      NewItem('Импорт связей базы остатков', '',KbNoKey , cmImportLinkG , hcDosShell,
      NewItem('Экспорт связей базы остатков', '',KbNoKey , cmExportLinkG , hcDosShell,
         Nil))))),
      NewSubMenu('Прочее',hcNoContext,
      NewMenu(
      NewSubMenu('Реквизиты...',hcDosShell,
	 NewMenu(
      NewItem('~Р~еквизиты', 'Alt-Р',KbAltRusR ,   cmRekwiziti , hcDosShell,
      NewItem('~Р~еквизиты (дубликат)', '',KbNoKey ,   cmRekwizitiSF , hcDosShell,
      NewItem('~Р~еквизиты (комиссоинер)', '',KbNoKey , cmRekwizitiCom   , hcDosShell,
      Nil)))),
      NewItem('Корректирова~т~ь склад', 'F7',KbF7 , cmCorrectSklad, hcDosShell,
      NewItem('~О~ператоры', '',KbNoKey , cmOperator , hcDosShell,
      NewItem('Очистит~ь~ базу остатков','',KbNoKey , cmClearBase, hcDosShell,
      NewItem('Проверка забронированного товара', '',KbNoKey , cmTestZakaz , hcDosShell,
      NewItem('~Н~астройка паролей','',KbNoKey , cmSetupPassword, hcDosShell,
      NewItem('Изменить статус документа','',KbNoKey , cmDeactivateMrk, hcNoContext,
      NewItem('~К~орректировать ККЛ', '',KbAltSpace ,   cmCorrectKassa , hcDosShell,
      NewItem('В арх~и~в', '', kbNokey, cmCopyToArc, hcDosShell,

      NewSubMenu('Сет~ь~',hcNoContext,
      NewMenu(
      NewItem('Б~л~окировать базу ', '^PtrScr',kbCtrlPrtSc , cmGlobalAdminLock, hcNoContext,
      NewItem('Д~е~блокировать базу', '',KbNoKey , cmGlobalAdminUnLock, hcNoContext,
      NewItem('Де~б~локировать документ','',KbNoKey , cmUnLockDoc, hcNoContext,
      NewItem('Деблокировать буфер прихода','',KbNoKey , cmUnLockPrh, hcNoContext,
      NewItem('~А~варийное создание файлов','',KbNoKey , cmCreatSpecialFile, hcNoContext,
      Nil)))))),

      NewSubMenu('П~р~отокол',hcDosShell,NewMenu(
      NewItem('П~р~отокол операций', '',KbNoKey , cmViewCorrectSklad, hcDosShell,
      NewItem('Протокол во~з~врата', '',KbNoKey , cmViewCorrectVozwrat, hcDosShell,
      Nil))),Nil)))))))))))),

      NewItem('Выход','Alt-Ч',KbAltRusCh , cmQuit, $A030,
         Nil))))))))));
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

EditorApp.Run;

{$IFDEF RemoteClient}
DestroyCash;
{$EndIF}

Dispose(PathExpImp,Done);
Dispose(PathSklads,Done);
Dispose(ListRange,Done);
Dispose(DixyList,Done);
Dispose(Path,Done);
Dispose(NetPath,Done);
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