{$IFDEF DPMI}

{$DEFINE NewExeFormat}

{$Else}
{$M 65520,0,655360 }
{$ENDIF}

{$X+,S-,I-}

{$IfDEF DPMI}
uses

{$DСпециально для Союзной,1999}
 Objects,App, Drivers, Memory,Printers,Prihod,CSklad,Vozwrat,Globals,MyCalc,
 Views, Menus, Dialogs, Glob, MsgBox,  {Calc,}Pereozen,Market,Nastr,Protect,Return,
 Barter,Slava,AgOpl,Trans,TrNakl,Oplinfo,PostZak,GrAgent,{Replicat,}UchDoh,
 Gadgets,Validate,Calendar,Serv,Vision1,Vision2,Vision5,Vision3,Prise,ColorTxt,ServStr,CSkid,MakeHist,
 Spec,Utils,Utils2,UtilsP,EndRep,Kassa,Vision7,Access,Access2,Sotrudn,Logist,
 Reestr,ReestrP,ReestrV,ReestrR,Rewisia,Stat,Stat1,StatP,dStat,TStat,UsrExit,LockInfo,Net{,tvInput},TvMenus,TpDate,
 DbEngine,Nabor,Dos;

{$Else}
uses
{$F+}
 Objects,App, Drivers, Memory,Printers,Prihod,CSklad,Vozwrat,Globals,MyCalc,
 Views, Menus, Dialogs, Glob, MsgBox,  {Calc,}Pereozen,Market,Nastr,Protect,Return,MakeHist,
 Barter,Slava,AgOpl,Trans,TrNakl,Oplinfo,PostZak,GrAgent,{Replicat,}UchDoh,
 Gadgets,Validate,Calendar,Serv,Vision1,Vision2,Vision5,Vision3,Prise,ColorTxt,ServStr,CSkid,
 Spec,Utils,Utils2,UtilsP,EndRep,Kassa,Vision7,Access,Access2,Sotrudn,Logist,
 Reestr,ReestrP,ReestrR,ReestrV,Rewisia,Stat,Stat1,StatP,DStat,TStat,UsrExit,LockInfo,Net{,TvInput},TvMenus,TpDate,DbEngine
 ,Nabor,Doc;


{$O Reestr}
{$O Reestrp}
{$O ReestrR}
{$O Printers}
{$O Prihod}
{$O CSklad}
{$O Pereozen}
{$O MArket}
{$O Nastr}
{$O Protect}
{$O Vision1}
{$O Vision2}
{$O Vision3}
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
{$O Return}
{$O Barter}
{$O Rewisia}
{$O Vision5}
{$O Stat}
{$O Stat1}
{$O DStat}
{$O TStat}
{$O UsrExit}
{$O LockInfo}
{$O DbEngine}
{$O MakeHist}
{$O Net}
{$O Spec}
{$O Utils}
{$O Utils2}
{$O UtilsP}
{$O EndRep}
{$O Kassa}
{$O Slava}
{$O Nabor}
{$O Sotrudn}


{$EndIF}

{$I Compile.INC}



type
  PEditorApp = ^TEditorApp;
  TEditorApp = object(TApplication)
        Clock: PClockView;
         Heap: PHeapView;
     SuperMarketWindow : PSuperMarketWindow;
     SkladWindow : PSkladWindow;
     SkidWindow : PSkidWindow;
     PrihodWindow : PPrihodWindow;
     PZPrihodWindow : PPZPrihodWindow;
     RewisiaWindow : PRewisiaWindow;
     {EditRewisia: PEditRewisia;}
     TransportWindow: PTransportWindow;

     DolgWindow : PDolgWindow;
     EmplDolgWindow : PEmplDolgWindow;
     OperatorWindow : POperatorWindow;
     BarterWindow : PBarterWindow;
     PrzWindow : PPrzWindow;
     ReestrWindow : PReestrWindow;
     ReestrKWindow : PReestrKWindow;
     ReestrPWindow : PReestrPWindow;
     ReestrDostWindow : PReestrDostWindow;
     ReestrVWindow : PReestrVWindow;
     ReestrRewWindow : PReestrRewWindow;
     InfoDebitWindow : PInfoDynamicDebit;
     ItogoWindow : PItogWindow;
     GlReturnWindow: PReturnWindow;
     MyCalculator : PMyCalculator;
     DynamicReturn :PInfoDynamicReturn;
     StatWindow : PStatWindow;
     SelectClientStat :PSelectClientWindow;
     SelectClientStat1 :PSelectClientWindow1;
     SelectMakeWindow:PSelectMakeWindow;
     TovarStatWindow:PTovarStatWindow;
     TTNaborWindow:PNaborWindow;
     SkladKAssa : PKAssawindow;
    Constructor Init(VAr Res : Byte);
    Procedure DeterminateDocument(k:Byte);
    Procedure DeterminateViewDocument;
    Procedure Determinatecreatfile;
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
  ShiftState: Byte absolute $40:$17;
  Starting : Boolean;

Procedure TEditorApp.DeterminateViewDocument;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  C : Word;
  Event : TEvent;
  L : LongInt;
Begin
1:
ClearFind;
R.Assign(24, 7, 55, 18);
New(Dlg, Init(R, 'Просмотр документов'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

R.Assign(1, 2, 18, 10);
Control := New(PRadioButtons, Init(R,
  NewSItem('Пр~и~ход',
  NewSItem('П~е~реоценка',
  NewSItem('Пр~о~дажа',
  NewSItem('~В~озврат',
  NewSItem('~К~онсигнация',
  NewSItem('~Р~/П',
  NewSItem('Реви~з~ия',
  NewSItem('В~н~.перемещ.'
  ,Nil))))))))));
Dlg^.Insert(Control);

  R.Assign(1, 1, 16, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид документа:', Control)));

R.Assign(19, 4, 29, 5);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(20, 3,25, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Д~а~та:', Control)));

Dlg^.SelectNext(False);

Dlg^.SetData(AssistentView);


c:=Desktop^.ExecView(Dlg);


If c <> CmCancel Then
           Begin
            Dlg^.GetData(AssistentView);
           If TestDate(AssistentView.d,L) Then
           Begin
            Case AssistentView.Vid Of
            0:Begin
               Event.What:=EvCommand;
               Event.Command:=cmViewPrihod;
               PutEvent(Event);
              End;
            1:Begin
               Event.What:=EvCommand;
               Event.Command:=cmViewPereozenka;
               PutEvent(Event);
              End;
            2:Begin
               Event.What:=EvCommand;
               Event.Command:=cmViewProd;
               PutEvent(Event);
              End;
            4:Begin
               Event.What:=EvCommand;
               Event.Command:=cmViewRealizas;
               PutEvent(Event);
              End;
            5:Begin
               Event.What:=EvCommand;
               Event.Command:=cmViewRP;
               PutEvent(Event);
              End;
            7:Begin
               Event.What:=EvCommand;
               Event.Command:=cmViewTransport;
               PutEvent(Event);
              End;

            6:Begin
               Event.What:=EvCommand;
               Event.Command:=cmViewRewisia;
               PutEvent(Event);
              End;
            3:Begin
               Event.What:=EvCommand;
               Event.Command:=cmViewVoswrat;
               PutEvent(Event);
              End;
            Else;
            End;
           End
           Else
            Begin
             Dispose(Control,Done);
             Dispose(Dlg,Done);
             MessageBox(#3^M+#3+'Недопустимое значение даты!',Nil,mfError+mfCancelButton);
             Goto 1;
            End;
           End;
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

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
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  C : Word;
  Event : TEvent;
  L : LongInt;
Begin
ClearFind;
1:
 R.Assign(20, 7, 60, 17);
Case K Of
0: New(Dlg, Init(R, 'Печать документа'));
1: New(Dlg, Init(R, 'Коррекция документа'));
2: New(Dlg, Init(R, 'Деблокировка документа'));
Else;
End;

Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

R.Assign(2, 2, 19, 9);
Control := New(PRadioButtons, Init(R,
  NewSItem('П~р~иход',
  NewSItem('П~е~реоценка',
  NewSItem('Пр~о~дажа',
  NewSItem('~В~озврат',
  NewSItem('~К~онсигнация',
  NewSItem('Реви~з~ия',
  NewSItem('В~н~.перемещ.',
  Nil)))))))));
If K in [1..2] Then PCluster(Control)^.SetButtonState($2, False);
Dlg^.Insert(Control);

  R.Assign(1, 1, 16, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид документа:', Control)));

R.Assign(32, 3, 38, 4);
Control := New(PInputLine, Init(R, 4));
Dlg^.Insert(Control);
{  PInputLine(Control)^.Validator := New(PRangeValidator, Init(1, 999));}
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(19, 3, 32, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'N ~д~окумента:', Control)));


R.Assign(26, 5, 36, 6);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(20, 5, 26, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Д~а~та:', Control)));


Dlg^.SelectNext(False);

If ((k =1) And (Assistent.Vid=1)) Then
Inc(Assistent.Vid);

{If ((k =1) And (Assistent.Vid=5)) Then
Dec(Assistent.Vid);}
Dlg^.SetData(Assistent);

c:=Desktop^.ExecView(Dlg);
If c <> CmCancel Then
           Begin
            Dlg^.GetData(Assistent);
            DelSpace(Assistent.D);
           If Assistent.EditPosition[0]=#0 Then
            Begin
             Dispose(Control,Done);
             Dispose(Dlg,Done);
             MessageBox(#3^M+#3'Не введен номер накладной!',Nil,mfError+mfCancelButton);
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
               If Password(3) Then
            Begin
                    TekDate:=Assistent.D;
                    Status:=DocEdit;
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
                    Event.What:=EvCommand;
                    Event.Command:=cmSuperMarket;
                    PutEvent(Event);
                    ClearEvent(Event);
            End;
                   End;
                 5:Begin
                    TekDate:=Assistent.D;
                    {Status:=DocEdit;}
                    Event.What:=EvCommand;
                    Event.Command:=cmRewisiaEdit;
                    PutEvent(Event);
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
                 0:
			  Begin{приход}
                    If Not(FExists(Path.ToPrihod+Assistent.D+'.prh')) Then
                     Begin
                      MessageBox(^M+#3'Файл прихода за '+Assistent.D+' не найден!',Nil,
                                  mfInformation+mfCancelButton);
                     End
                     Else
                                 Repeat
                     Until (UnLockPrihod(Assistent.EditPosition,Assistent.D) in [0,2]);
                   End;
                 2,4:Begin{продажа,консигнация}
                    If Not(FExists(Path.ToMarket+Assistent.D+'.mrk')) Then
                     Begin
                      MessageBox(^M+#3'Файл продаж за '+Assistent.D+' не найден!',Nil,
                                  mfInformation+mfCancelButton);
                     End
                     Else
                     Repeat
                     Until (UnLockMarket(Assistent.EditPosition,Assistent.D) in [0,2]);

                     End;
                 3:Begin{возврат}
                    If Not(FExists(Path.ToReturn+Assistent.D+'.vzw')) Then
                     Begin
                      MessageBox(^M+#3'Файл возврата за '+Assistent.D+' не найден!',Nil,
                                  mfInformation+mfCancelButton);
                     End
                     Else
                      Repeat
                      Until (UnLockReturn(Assistent.EditPosition,Assistent.D) in [0,2]);
                   End;
                 5:Begin{ревизия}
                    If Not(FExists(Path.ToRewisia+Assistent.D+'.rwz')) Then
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
                 0:if (User[87] or (CurrentPassword='00')) then PrintPrihod(Assistent);
                 3:Begin
                    If NewPrintVozwrat(Assistent) Then PrintRashodOrder(Assistent);
                   End;
                 1:PrintAktPrz(Assistent);
                 2,4:Begin
                      {PrintNaklSklad(Assistent,NPrint.CopyNkl);}
                      PrintNakl(Assistent,NPrint.CopyNkl);
                     End;
                 6:PrintTransport(Assistent);
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
             Dispose(Dlg,Done);
             MessageBox(#3^M+#3'Недопустимое значение даты!',Nil,mfError+mfCancelButton);
             Goto 1;
            End;
           End;
Dispose(Control,Done);
Dispose(Dlg,Done);
End;


Procedure TEditorApp.Determinatecreatfile;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  C : Word;
  L : LongInt;
  a : Record
   Vid :Word;
   Date:TDateString;
   End;

Begin
ClearFind;
1:
 R.Assign(20, 7, 60, 21);
New(Dlg, Init(R, 'Аварийное создание файлов'));

Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

R.Assign(2, 2, 22, 13);
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
  NewSItem('Кассовые операции',
  NewSItem('Вн.перемещения',

  Nil)))))))))))));
Dlg^.Insert(Control);

  R.Assign(1, 1, 16, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид документа:', Control)));

R.Assign(26, 5, 36, 6);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(25, 4, 31, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Д~а~та:', Control)));

Dlg^.SelectNext(False);

a.Vid:=3;
A.Date:=FDate;
Dlg^.SetData(A);

c:=Desktop^.ExecView(Dlg);
If c <> CmCancel Then
           Begin
            Dlg^.GetData(A);
            DelSpace(A.Date);
           If TestDate(A.date,L) Then
            Begin
             CreatSpecialFile(A.Vid,A.DAte);
            End;
           End;
Dispose(Control,Done);
Dispose(Dlg,Done);
End;


constructor TEditorApp.Init(Var Res:Byte);
const
  HeapSize = 630 * (1024 div 16);

var
  h: LongInt;
  R: TRect;
  f: Text;
begin
  Starting:=False;
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



  ReadRek(h);
  If H <> 0 Then Errors('Ошибка чтения файла реквизитов !');

  ReadRekSF(h);
  If H <> 0 Then Errors('Ошибка чтения файла реквизитов2 !');

  ReadNewIni(h);
  If H <> 0 Then Errors('Ошибка чтения файла конфигурации !');

  Starting:=True;

  Registr;
  FreshApp;

  NewTmpAndAnalys;

  {NewTmpAndAnalysLocal;}




  DeskTop^.Redraw;

{$IfDEF Debug }
{$Else}
If Not FindParam('/NOCONTROL') Then
   Begin
   If Not(Wzlom) Then  Res:=TestPC;
   End;
{$ENDIF}
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
begin
  L := IOResult;
  inherited Idle;
  L := IOResult;
  Clock^.Update(0);
  Heap^.Update;
end;

Procedure TEditorApp.FreshApp;
VAr
    Oper,skod,st :String[CAll];
    sopen,skassa : boolean;

Begin
   If Not Starting Then Exit;
   st:=GetMAkeField(FClient,Rek.Kod,1);
   DelSpaceRight(St);
   sopen:=TestOpenDate1(FDate);

   Str(StrToInt(Rek.Kod):2,skod);
   RFormatZerro(skod,2);

   If FExists(Path.ToArchiv+FDate+'.k'+skod) Then Skassa:=True
   Else SKassa:=False;

   GlobalSkladsName:=' Склад:'+st+{' Дата:'+FDAte+}' День:';
   If Sopen Then GlobalSkladsName:=GlobalSkladsName+'ОТКРЫТ'+'('+FDAte+')'
   Else GlobalSkladsName:=GlobalSkladsName+'ЗАКРЫТ'+'('+FDAte+')';

   If SKassa Then GlobalSkladsName:=GlobalSkladsName+' Касса:ЕСТЬ '
   Else GlobalSkladsName:=GlobalSkladsName+' Касса:НЕТ ';

   If CurrentPassword[0]<>#0 Then
    Begin
     Oper:=GetOperatorName(CurrentPassword){+'('+CurrentPassword+')'};
     GlobalSkladsName:=GlobalSkladsName+'Оператор:'+Oper;
    End;

   DeskTop^.Redraw;
   Delay(800);
   st:=GetMAkeField(FClient,Rek.Kod,1);
   DelSpaceRight(St);
   GlobalSkladsName:=' Склад:'+ST+'  Дата:'+FDAte+' ';
   DeskTop^.Redraw;
End;


procedure TEditorApp.GetEvent(var Event: TEvent);
Begin
       if (ShiftState and kbRightShift<>0)  then
                                              Begin
                                               Clock^.Update(2);
                                              End;

       if  ShiftState and kbCtrlShift <> 0 then
                                              Begin
                                               Clock^.Update(1);
                                              End;

       if (ShiftState and kbAltShift <> 0) And
          (ShiftState and kbCtrlShift <> 0)  then
                                              Begin
                                               FreshApp;
                                              End;
                                               {
       if ShiftState and kbAltShift <> 0 then
                                              Begin
                                               Clock^.Update(2);
                                              End;
                                              }
       if  (ShiftState and kbLeftShift<>0)
         Then
                                              Begin
                                               Clock^.Update(3);
                                              End;

       Case  Event.What  Of
         evKeyDown:Begin
(*      If  (Event.KeyCode = kbEsc)
           Then Begin
                                          Event.What := evCommand;
                                          Event.Command := cmClose;
                                          Event.InfoPtr := Nil{Owner};
                                          PutEvent(Event);
                                          ClearEvent(Event);
                                         End;*)
                    End;
  End;
  TApplication.GetEvent(Event);

  If Path.ToModem[0]=#0 Then
  DisableCommands([cmRunModem])
  Else EnableCommands([cmRunModem]);


  If Not(StrToInt(CurrentPassword) in [0,5]) Then
  DisableCommands([cmSetupPassword])
  Else EnableCommands([cmSetupPassword]);

If (Desktop^.Current=Nil) And (MenuBar^.Current=Nil) And (Event.What=evNothing) Then
   Begin
    Event.What:=EvCommand;
    Event.InfoPtr := Nil;
    Event.Command:=cmMenu;
    PutEvent(Event);
    EnableCommands([cmFullview]);
    ClearFind;
   End;



if (Message(Desktop, evBroadcast, cmReestrDoc, nil) <> nil) Then
    DisableCommands([cmCreatReport])
Else
    EnableCommands([cmCreatReport]);



 if (Message(Desktop, evBroadcast, cmPrihod, nil) = nil)
And (Message(Desktop, evBroadcast, cmPostZak, nil) = nil)
And (Message(Desktop, evBroadcast, cmRewisia, nil) = nil)
And (Message(Desktop, evBroadcast, cmDolg, nil) = nil)
And (Message(Desktop, evBroadcast, cmInfoDebit, nil) = nil)
And (Message(Desktop, evBroadcast, cmInfoReturn, nil) = nil)
And (Message(Desktop, evBroadcast, cmBArter, nil) = nil)
And (Message(Desktop, evBroadcast, cmVozwrat, nil) = nil)
And (Message(Desktop, evBroadcast, cmPereozen, nil) = nil)
And (Message(Desktop, evBroadcast, cmCorrectSklad, nil) = nil)
And (Message(Desktop, evBroadcast, cmSuperMarket, nil) = nil)
And (Message(Desktop, evBroadcast, cmOperator, nil) = nil)
And (Message(Desktop, evBroadcast, cmReestrDoc, nil) = nil)
And (Message(Desktop, evBroadcast, cmReestrVZw, nil) = nil)
And (Message(Desktop, evBroadcast, cmReestrKassa, nil) = nil)
And (Message(Desktop, evBroadcast, cmReestrPrh, nil) = nil)
And (Message(Desktop, evBroadcast, cmReestrRwz, nil) = nil)
And (Message(Desktop, evBroadcast, cmSkidki, nil) = nil)
And (Message(Desktop, evBroadcast, cmClientStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmMakeStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmTovarStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmStat1, nil) = nil)
And (Message(Desktop, evBroadcast, cmStat, nil) = nil) then

EnableCommands([cmEditDoc,{cmPrintSklad,cmPrintPreisList,}cmPereozen,cmPrihod{,cmPostZak},cmBArter,
           cmCorrectSklad,cmSuperMarket,cmOperator, cmSkidki,cmConfigMarket,
           cmStat,cmStat1,cmRewisia,cmVozwrat,cmDolg,cmReestrDoc,cmReestrVZw,cmReestrPrh,cmReestrRwz,cmInfoDebit,cmInfoReturn,
           cmBArter,cmReestrKAssa,
           cmSetupDebitDoc,cmSetupMarketDoc,cmClientStat,cmMakeStat,cmTovarStat,cmCorrectKassa])

Else
  DisableCommands([cmEditDoc,{cmPrintSklad,cmPrintPreisList,}cmPereozen,
      cmPrihod,{cmPostZak,}cmCorrectSklad,cmSuperMarket,cmOperator,cmSkidki,cmConfigMarket,
         cmStat1,cmStat,cmReestrKAssa,
            cmRewisia,cmVozwrat,cmDolg,cmReestrDoc,cmReestrVZw,cmReestrRwz,cmReestrPrh,cmInfoDebit,cmInfoReturn,
         cmSetupDebitDoc,cmSetupMarketDoc,cmClientStat,cmMakeStat,cmTovarStat,cmCorrectKassa]);

if (Message(Desktop, evBroadcast, cmPrihod, nil) = nil)
And (Message(Desktop, evBroadcast, cmPostZak, nil) = nil)
And (Message(Desktop, evBroadcast, cmDolg, nil) = nil)
And (Message(Desktop, evBroadcast, cmRewisia, nil) = nil)
And (Message(Desktop, evBroadcast, cmVozwrat, nil) = nil)
And (Message(Desktop, evBroadcast, cmBarter, nil) = nil)
And (Message(Desktop, evBroadcast, cmPereozen, nil) = nil)
And (Message(Desktop, evBroadcast, cmCorrectSklad, nil) = nil)
And (Message(Desktop, evBroadcast, cmSuperMarket, nil) = nil) Then
        EnableCommands([cmLockDay,cmUnLockDay,cmLockPeriod,cmUnlockPeriod,cmCreatSpecialFile,
           cmUnLockDoc,cmReanimClient,cmReanim])
Else DisableCommands([cmLockDay,cmUnLockDay,cmLockPeriod,cmUnlockPeriod,cmCreatSpecialFile,
        cmUnLockDoc,cmReanimClient,cmReanim]);

If (Event.What=EvCommand)And(Event.Command=cmQuit) Then
if (Message(Desktop, evBroadcast, cmPrihod, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmPostZak, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmVozwrat, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmStat1, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmClientStat, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmBarter, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmMakeStat, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmTovarStat, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmRewisia, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmReestrDoc, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmReestrVzw, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmReestrPrh, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmReestrRwz, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmReestrKassa, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmInfoDebit, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmInfoReturn, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmDolg, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmPereozen, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmSuperMarket, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmCorrectSklad, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmSkidki, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmStat, nil) <> nil)
Or (Message(Desktop, evBroadcast, cmOperator, nil) <> nil) then ClearEvent(Event);

If(Message(Desktop, evBroadcast, cmSuperMarket, nil) = nil)
And (Message(Desktop, evBroadcast, cmDolg, nil) = nil)

And (Message(Desktop, evBroadcast, cmClientStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmMakeStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmTovarStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmStat, nil) = nil)
And (Message(Desktop, evBroadcast, cmStat1, nil) = nil)

   Then
        EnableCommands([cmSetupMArketDoc,cmSetupDebitDoc])
Else DisableCommands([cmSetupMArketDoc,cmSetupDebitDoc]);


If FindParam('/EB') Then
        EnableCommands([cmCalcSaldoBarter,cmViewOplataBarter,cmBarter,cmCreatPlan])
Else
        DisableCommands([cmCalcSaldoBarter,cmViewOplataBarter,cmBarter,cmCreatPlan]);


If FindParam('/EK') Then
        EnableCommands([cmReestrKAssa])
Else
        DisableCommands([cmReestrKAssa]);

if not (User[0] or (CurrentPassword='00')) then DisableCommands([cmPrihod,cmVozwrat,cmInputToSklad]);
if not (User[1] or (CurrentPassword='00')) then DisableCommands([cmSupermarket]);
if not (User[2] or (CurrentPassword='00')) then DisableCommands([cmDolg]);
IF not (User[3] or (CurrentPassword='00')) then DisableCommands([cmBarter]);
if not (User[4] or (CurrentPassword='00')) then DisableCommands([cmTovarStat]);
if not (User[5] or (CurrentPassword='00')) then DisableCommands([cmMArketStat]);
if not (User[6] or (CurrentPassword='00')) then DisableCommands([cmSpecialMArketStat]);
if not (User[7] or (CurrentPassword='00')) then DisableCommands([cmBalance]);
if not (User[8] or (CurrentPassword='00')) then DisableCommands([cmMakeStat]);
if not (User[9] or (CurrentPassword='00')) then DisableCommands([cmStat]);
if not (User[10] or (CurrentPassword='00')) then DisableCommands([cmClientStat]);
if not (User[11] or (CurrentPassword='00')) then DisableCommands([cmStat1]);
if not (User[12] or (CurrentPassword='00')) then DisableCommands([cmInfoDebit]);
{if not (User[13] or (CurrentPassword='00')) then DisableCommands([cmCalcMenedger2]);}
if not (User[14] or (CurrentPassword='00')) then DisableCommands([cmInfoReturn]);
{if not (User[15] or (CurrentPassword='00')) then DisableCommands([cmBuchPrihod,cmBuchpROD]);}
if not (User[16] or (CurrentPassword='00')) then DisableCommands([cmReestrDoc]);
if not (User[17] or (CurrentPassword='00')) then DisableCommands([cmReestrPrh]);
if not (User[18] or (CurrentPassword='00')) then DisableCommands([cmReestrRwz]);
if not (User[19] or (CurrentPassword='00')) then DisableCommands([cmReestrKassa]);
if not (User[20] or (CurrentPassword='00')) then DisableCommands([cmReestrVzw]);
if not (User[21] or (CurrentPassword='00')) then DisableCommands([cmViewDoc]);
if not (User[22] or (CurrentPassword='00')) then DisableCommands([cmEditDoc]);
if not (User[23] or (CurrentPassword='00')) then DisableCommands([cmPrintDoc]);
if not (User[24] or (CurrentPassword='00')) then DisableCommands([cmEndRep]);
if not (User[25] or (CurrentPassword='00')) then DisableCommands([cmPrintSklad]);
{if not (User[26] or (CurrentPassword='00')) then DisableCommands([cmArcOst]);}
if not (User[27] or (CurrentPassword='00')) then DisableCommands([cmPrintPreisList]);
if not (User[28] or (CurrentPassword='00')) then DisableCommands([cmPrintKassa]);
if not (User[29] or (CurrentPassword='00')) then DisableCommands([cmOstatki_Market]);
{if not (User[31] or (CurrentPassword='00')) then DisableCommands([cmPrintPreisList]);}
if not (User[30] or (CurrentPassword='00')) then DisableCommands([cmBuch,cmBuch]);
if not (User[32] or (CurrentPassword='00')) then DisableCommands([cmViewOplataRealiz]);
if not (User[33] or (CurrentPassword='00')) then DisableCommands([cmPrintDebitDolg]);
if not (User[34] or (CurrentPassword='00')) then DisableCommands([cmCalcDebitAgent]);
if not (User[35] or (CurrentPassword='00')) then DisableCommands([cmOperatorReport]);
if not (User[36] or (CurrentPassword='00')) then DisableCommands([cmCalcSaldoBarter]);
if not (User[37] or (CurrentPassword='00')) then DisableCommands([cmViewOplataBarter]);
if not (User[38] or (CurrentPassword='00')) then DisableCommands([cmCreatPlan]);
{if not (User[39] or (CurrentPassword='00')) then DisableCommands([cmViewCorrectSklad,cmViewCorrectVozwrat]);}
if not (User[40] or (CurrentPassword='00')) then DisableCommands([cmPereozen]);
if not (User[41] or (CurrentPassword='00')) then DisableCommands([cmCorrectSklad]);
if not (User[42] or (CurrentPassword='00')) then DisableCommands([cmRewisia]);
if not (User[43] or (CurrentPassword='00')) then DisableCommands([cmItogi]);
if not (User[44] or (CurrentPassword='00')) then DisableCommands([cmConfig,
cmConfigPrint,cmSetupMarketDoc,cmSetupDebitDoc,cmConfigMarket,cmInputKreditClient,
cmIndex,cmReanim,cmReanimClient,cmIndexSkidki,cmLockPeriod,cmUnLockPeriod,
cmUnLockDoc,cmCreatSpecialFile,cmMakeHistory,cmMakeHistoryOpl,cmMakeHistoryReturn,
{cmError2,}
cmSkidki,
cmViewSkidki,
{cmViewSkidkiPeronal,}
cmViewSkidki1,
cmViewSkidki2,
cmPolitikaSkidok,cmKassaStat,
cmLockFromPeriod,
cmViewLockBaza,
cmOperator,
cmRekwiziti,cmRekwiziti2,cmCorrectKassa]);
{if not (User[45] or (CurrentPassword='00')) then DisableCommands([]);}
if not (User[46] or (CurrentPassword='00')) then DisableCommands([cmPrintRewizia]);
if not (User[47] or (CurrentPassword='00')) then DisableCommands([cmViewSpecialKassa]);
if not (User[48] or (CurrentPassword='00')) then DisableCommands([cmTransport]);
if not (User[49] or (CurrentPassword='00')) then DisableCommands([cmLockDay]);
if not (User[50] or (CurrentPassword='00')) then DisableCommands([cmUnLockDay]);

{$IfDEF Debug }
{$Else}
 if (Message(Desktop, evBroadcast, cmTovarStat, nil) = nil) Then
   Heap^.Show
   Else
   Heap^.Hide;
{$ENDIF}


end;



procedure TEditorApp.HandleEvent(var Event: TEvent);              {
procedure Calculator;
begin
  InsertWindow(New(PCalculator, Init));
end;
}
Var s:TMyString;
    Start,Stop : TDAteString;

procedure Calendar;
begin
  InsertWindow(New(PCalendarWindow, Init));
end;
begin
  case Event.What of
    evCommand:
      case Event.Command of
        cmQuit : Begin
                 If MessageBox(^M+#3+'Желаете закончить работу?',Nil,mfOkCancel)<>cmOk Then
                  Begin
                   ClearEvent(Event);
                   Exit;
                  End;
                 If TestOpenDate1(FDate) And Not(Wzlom) Then
                  Begin
                   if (User[49] or
                   (StrToInt(CurrentPassword)=0)) then
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
                   AddProtocol('Выход оператора из ситемы!','','');
                 End;
        Else;
        End;
        Else;
        End;

  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      case Event.Command of

        cmBlack:
        begin
          SetScreenMode(ScreenMode and smBW80);
          Redraw;
          ClearEvent(Event);
          PbxMenuBar(MenuBar)^.SetMarker(cmBlack);
          PbxMenuBar(MenuBar)^.ResetMarkers(cmColor,cmColor,Event.Command);
        end;
        cmCopyToArc: Begin
                      ArcBaza;
                      Redraw;
                     End;

        cmViewTransport: ViewTransport(AssistentView.D);
        cmRekwiziti:  ChangeRekwiziti;
        cmRekwiziti2:  ChangeRekwizitiSF;
        cmViewPrihod: ViewAllPrihod(AssistentView.D,True,2);

        cmViewRewisia: ViewAllRewisia(AssistentView.D,False,2);

        cmViewVoswrat: NewViewAllVozwrat(AssistentView.D,True,2);
        cmViewPereozenka: ViewAllAktPrz(AssistentView.D,True,0);
        cmViewProd: ViewAllNakl(AssistentView.D,True,False,2);
        cmViewRealizas: ViewAllNakl(AssistentView.D,True,True,2);
        cmViewRP: ViewAllRP(AssistentView.D,True);
        cmViewOplataRealiz: ViewOplReal(AssistentView.D,True);
        cmEditDoc:DeterminateDocument(1);
       cmPrintDoc:DeterminateDocument(0);
       cmUnLockDoc:If Password(1) Then DeterminateDocument(2);
       cmPrintSklad: Selection(0);
       cmOstatki_Market: Begin
                             ClearEvent(Event);
                             Selection(3);
                         End;
       cmFindDSertif: Begin
                             ClearEvent(Event);
                             Selection(4);
                      End;

       cmFindSrok: Begin
                             ClearEvent(Event);
                             Selection(11);
                      End;

       cmMArketStat: Begin
                             ClearEvent(Event);
                             Selection(5);
                      End;

 cmSpecialMArketStat: Begin
                             ClearEvent(Event);
                             Selection(7);
                      End;
           cmBalance: Begin
                             ClearEvent(Event);
                             Selection(6);
                      End;

       cmPrintRewizia: Selection(2);
       cmPrintPreisList: Selection(1);
       cmPrintKassa:
                     Begin
                      ClearDesktop(Event);
                      If Password(5) Then
                      ViewKAssa(False,FDate);
                     End;

       cmViewSpecialKassa:
                     Begin
                      ClearDesktop(Event);
                      If Password(10) Then
                      ViewSpecialKAssa(False,FDate);
                     End;

       cmViewDoc:DeterminateViewDocument;

       cmCreatSpecialFile :If Password(1) Then Determinatecreatfile;
       cmitogi:ItogoWindow^.OpenViewItog;

        cmPostZak:Begin
                    ClearDesktop(Event);
                    PZPrihodWindow^.OpenPrihodWindow;
                    ClearEvent(Event);
                  End;

        cmPrihod :Begin
                    ClearDesktop(Event);
                    PrihodWindow^.OpenPrihodWindow;
                    ClearEvent(Event);
                  End;
        cmRewisia :Begin
                            If (Password(11))  Then
                            Begin
                                ClearDesktop(Event);
                                RewisiaWindow^.OpenRewisiaWindow;
                                ClearEvent(Event);
                            End;
                  End;
        cmRewisiaEdit :Begin
                            If Password(1) Then
                            Begin
                                ClearDesktop(Event);
                                {EditRewisia^.}EditRewisiaComment(Assistent);
                                ClearEvent(Event);
                            End;
                  End;


                                         cmCreatPlan:Begin
                                                  If Password(9) Then
                                                  Begin
                                                                                  ClearDesktop(Event);
                                                                                  CreatPlan;
                                                                                  ClearEvent(Event);
                                                  End;
                                                                 End;

                                         cmBarter:Begin
                                                  If Password(9) Then
                                                  Begin
                                                                                  ClearDesktop(Event);
                                                                                  BarterWindow^.OpenBarterWindow;
                                                                                  ClearEvent(Event);
                                                  End;
                                                                 End;

   cmCalcSaldoBarter:Begin
                                                  If Password(9) Then
                                                  Begin
                     CalcDolgBarter(True);
                                End;
                    End;
   cmViewOplataBarter:
    Begin
                                                  If Password(9) Then
                                                  Begin
     ViewOplBarter(AssistentView.D,True);
                                End;
    End;

        cmVozwrat :Begin
                    Begin
                    If Password(1) Then
                    Begin
                    ClearDesktop(Event);
                    ClearEvent(Event);
                    gLReturnWindow^.OpenReturnWindow;
                    End;
                    End;
                   End;
{$IfDEF DPMI }
   cmCorrectSklad:Begin
                    ClearDesktop(Event);
                    SkladWindow^.OpenSkladWindow;
                    ClearEvent(Event);
                   End;
   cmViewCorrectSklad:Begin
                  if (User[39] or (CurrentPassword='00')) then
                    ViewCorrect;
                   End;
   cmViewCorrectVozwrat:Begin
                    if (User[39] or (CurrentPassword='00')) then
                    ViewVozwrat;
                   End;
   cmPrintDebitDolg:Begin
                     If Password(6) Then CalcDolgDebit(2,True);
                    End;
{$EndIf }

   cmReestrKassa  :Begin
                    ClearDesktop(Event);
                    ReestrKWindow^.OpenReestrWindow;
                    ClearEvent(Event);
                   End;

   cmSuperMarket :Begin
                    if Status=DocEdit Then
                     Begin
                      If Not Password(4) Then Exit;
                     End;
                    ClearDesktop(Event);
                    SuperMarketWindow^.OpenSuperMarketWindow;
                    ClearEvent(Event);
                   End;


   cmReestrDoc    :Begin
                    ClearDesktop(Event);
                    ReestrWindow^.OpenReestrWindow;
                    ClearEvent(Event);
                   End;

   cmReestrRwz    :Begin
                    ClearDesktop(Event);
                    ReestrRewWindow^.OpenReestrRewWindow;
                    ClearEvent(Event);
                   End;

   cmReestrPrh    :Begin
                    ClearDesktop(Event);
                    ReestrPWindow^.OpenReestrPWindow;
                    ClearEvent(Event);
                   End;

   cmReestrDost   :Begin
                    ClearDesktop(Event);
                    ReestrDostWindow^.OpenReestrPWindow;
                    ClearEvent(Event);
                   End;


   cmClientStat   :Begin
                                ClearDesktop(Event);
                      If Password(2) Then SelectClientStat^.OpenSelectClientWindow;
                                ClearEvent(Event);
                            End;
   cmDopOper:  Begin
               End;

   cmMakeStat   :Begin
                  ClearDesktop(Event);
                  If Password(9) Then
                  SelectMakeWindow^.OpenSelectMakeWindow;
                  ClearEvent(Event);
                 End;
{$IfDEF DPMI }

   cmInfoDebit    :Begin
                    ClearDesktop(Event);
                    If Password(4) Then InfoDebitWindow^.OpenDebitWindow;
                    ClearEvent(Event);
                   End;

   cmInfoReturn   :Begin
                    ClearDesktop(Event);
                    DynamicReturn^.OpenDynamicReturnWindow;
                    ClearEvent(Event);
                   End;
    cmBuch      :Begin
                  CalcBuch;
                 End;
    cmBuch2     :Begin
      if (User[31] or (CurrentPassword='00')) then
                  CalcBuchMarket1;
                 End;

   cmStat1   :Begin
                ClearDesktop(Event);
                If Password(9) Then SelectClientStat1^.OpenSelectClientWindow;
                ClearEvent(Event);
              End;

   cmStat         :Begin
                    ClearDesktop(Event);
                    StatWindow^.OpenStatWindow;
                    ClearEvent(Event);
                   End;


{$EndIf }
{   cmTovArStat   :Begin
                    If Password(2) Then
                    Begin
                                ClearDesktop(Event);
                                TovarStatWindow^.OpenTovarStatWindow;
                                ClearEvent(Event);
                    End;
                  End;

   cmCalcRozniza  :Begin
                     ClearDesktop(Event);
                     CalcTCh;
                     ClearEvent(Event);
                   End;
}

           cmDolg :Begin
                    ClearDesktop(Event);
                    DolgWindow^.OpenDolgWindow;
                    ClearEvent(Event);
                   End;

           cmPereozen:Begin
                       If Password(11) Then
                       Begin
                       ClearDesktop(Event);
                       PrzWindow^.OpenPrzWindow;
                       End;
                       ClearEvent(Event);
                      End;
   cmInputToSklad:Begin
                    InputToSklad;
                    ClearEvent(Event);
                   End;
    cmOperatorReport:Begin
                     CreatOperatorReport;
                    End;
    cmConfigMarket:Begin
                    If Password(2) Then
                    Begin
                    ClearDesktop(Event);
                    NastrMarket;
                    End;
                    ClearEvent(Event);
                   End;
    cmSetupMArketDoc:Begin
                    If Password(2) Then
                    Begin
                    ClearDesktop(Event);
                    SetupMarketDoc(0);
                    End;
                    ClearEvent(Event);
                   End;
    cmSetupDebitDoc:Begin
                    If Password(2) Then
                    Begin
                    ClearDesktop(Event);
                    SetupMarketDoc(1);
                    End;
                    ClearEvent(Event);
                   End;
    cmCalcMenedger : if (User[45] or (CurrentPassword='00')) then
             If Password(2) Then CalcMenedger1;

    cmCalcMenedger2: if (User[34] or (CurrentPassword='00')) then
           If Password(2) Then CalcDolgOplataAgent;

    cmGrAgent: if (User[93] or (CurrentPassword='00')) then CalcGroupAgent;

    cmSkidki      :Begin
                    ClearDesktop(Event);
                    SkidWindow^.OpenSkidWindow;
                    ClearEvent(Event);
{                   PrintSkl; для печати таблицы скидок}
                   End;


    cmPolitikaSkidok:Begin
                      If Password(2) Then Analys;
                      End;

    cmInputKreditClient:Begin
                         If Password(2) Then InputKredit;
                       End;
    {
    cmRunModem    : Begin
                     RunModem;
                     Redraw;
                     ClearEvent(Event);
                    End;
                    }
    cmCorrectKassa: Begin
{$IFDEF NetVersion}
If (StrToInt(CurrentPassword)<>0) And FindPAram('/NOCLOSE') Then
Begin
 MessageBox(^M+#3'С этой рабочей станции нельзя корректировать контрольный кассовый лист!',Nil,mfError+mfCancelButton);
 Exit;
End;
{$EndIf}
                     If Password(4) Then
                     Begin
                     ClearDesktop(Event);
                     SkladKassa^.start(True);
                     End;
                     ClearEvent(Event);
                    End;

    cmLockDay      :
                     CloseDate(1);

  cmUnLockDay      : CloseDate(0);

    cmLockPeriod   : If Password(2) Then PeriodFromLock(True);
  cmUnLockPeriod   : If Password(5) Then PeriodFromLock(False);


    cmOperator    :Begin
                   If (StrToInt(CurrentPassword)=0) Then
                   Begin
                    ClearDesktop(Event);
                    OperatorWindow^.OpenOperatorWindow;
                    ClearEvent(Event);
                   End;
                   End;
  cmSetupPassword :Begin
                    SetupPassword ;
                   End;

    cmIndex     :Begin
                   If Password(2) Then
                   Begin
                    NewIDx;
                   End;
                   End;
    cmReanim     :Begin
                   If Password(2) Then
                   Begin
                    CreatIDx;
                   End;
                   End;

    cmKassaStat  :Begin
                   If Password(10) Then
                   Begin
                    FormReportKAssa;
                   End;
                   End;

   cmReestrVzw    :Begin
                    ClearDesktop(Event);
                    ReestrVWindow^.OpenReestrVWindow;
                    ClearEvent(Event);
                   End;



        cmViewSkidki:Begin
                      ClearEvent(Event);
                      If Password(3) Then
                      Selection(8);{PrintSkl;}
                     End;

        cmViewSkidkiPeronal:Begin
                      ClearEvent(Event);
                      if (User[44] or (CurrentPassword='00')) then
                      If Password(3) Then PrintPersonal;
                     End;


        cmViewSkidki1:Begin
                      ClearEvent(Event);
                      If Password(3) Then
                      Selection(9);{PrintSkl;}
                     End;
        cmViewSkidki2:Begin
                      ClearEvent(Event);
                      If Password(3) Then
                      Selection(10);{PrintSkl;}
                     End;
    cmReanimClient:Begin
                   If Password(2) Then
                   Begin
                    ClientIDX;
                   End;
                   End;
     (*   cmError:Begin
                 If StrToInt(CurrentPassword)=0 Then  FindError;
                End;
        cmError2:Begin
                 If StrToInt(CurrentPassword)=0 Then  FindError2;
                End; *)
        cmColor:
        begin
           SetScreenMode(ScreenMode xor smCO80);
          Redraw;
          ClearEvent(Event);
          PbxMenuBar(MenuBar)^.SetMarker(cmColor);
          PbxMenuBar(MenuBar)^.ResetMarkers(cmBlack,cmBlack, Event.Command);
        end;
        cmCalculator: MyCalculator^.Start;
           {Calculator;}

        cmCreatReport: Begin
                        s:=FDate;
                        CreatReport(False,s);
                       End;
        cmConfig    : If Password(2) Then ConfigDistantion;

        cmBuchProd : Begin
                      if (User[15] or (CurrentPassword='00')) then
                      If Password(8) Then
				   Begin
                        CalcBuchMarket;
				   End;
                     End;
        cmArcOst:
                 Begin
                  if (User[26] or (CurrentPassword='00')) then
                  Selection(13);
                 End;

        cmArcDlg:Begin
                  if (User[26] or (CurrentPassword='00')) then
                  CalcDolgDebitDate;
                 End;

   cmTransPort   :Begin
                  {  If FindParam('/ETRANS') Then}
                    Begin
                    ClearDesktop(Event);
                    TransportWindow^.OpenTransPortWindow;
                    ClearEvent(Event);
                    End;
                  End;

        cmBuchPrihod : Begin
                      if (User[15] or (CurrentPassword='00')) then
                      If Password(8) Then
				   Begin
                        CalcBuchPrihod;
				   End;
                       End;


        cmConfigPrint : If Password(1) Then PrintConfig;
        cmCalendar: Calendar;

        cmVvodSkidki: EditSkidka;

      (*  cmLoadMainSklad: if StrToInt(Rek.Kod)<>1 then
	         CopyMainFiles;
        cmSaveRemote : if StrToInt(Rek.Kod)<>1 then
	         SaveMarketToMainSklad; *)

        cmBuchNovarReport : if (User[31] or (CurrentPassword='00')) then
	      CalcRashodDohod;


        cmCalcMarket: if (User[31] or (CurrentPassword='00')) then
	      CalcMarket;

        cmTo1c: if (User[31] or (CurrentPassword='00')) then
	      to1s;

        cmProzNdsDay: if (User[31] or (CurrentPassword='00')) then
           ProzNdsDay;

        cmCalcPost: if (User[31] or (CurrentPassword='00')) then
	      CalcPost;

        cmImpClient: if (CurrentPassword='00') then
           ImportClientInfo(0,0);

        cmEmlDolg:Begin
             ClearDesktop(Event);
             EmplDolgWindow^.OpenDolgWindow;
             ClearEvent(Event);
                  end;

        cmLeftConcurs: Begin
             LeftConcurs;
           end;

        cmAbout: Begin

	   AboutCHM('13');
        {CopyMainFiles;}
        {CalcDolgDebitDate;}
        end;

   cmSetupStart:Begin
                 if (User[44] or (CurrentPassword='00')) then
                 If Password(6) Then SetupStart;
                End;


        cmViewLockBaza :
                           If Password(7) Then ViewClientBaza;
        cmLockFromPeriod :
                           If Password(2) Then CretLockReport;

        cmChangeNumber :
                          if (User[44] or (CurrentPassword='00')) then
                           If Password(7) Then ChangeSkladKod;

   cmCalcDebitEmpl:Begin
                     If Password(6) Then
                     CalcDolgDebitEmpl(2,True);
                    End;

   cmCalcDebitAgent     :Begin
                     If Password(6) Then
                     CalcDolgDebitAgent;
                    End;

           cmEndRep : GlobalReport;


        cmMakeHistory :Begin
                        If Password(2) Then MakeClientIndex;
                       End;

        cmMakeHistoryReturn :Begin
                        If Password(2) Then MAkeClientReturnIndex;
                       End;

        cmMakeHistoryOpl :Begin
                        If Password(2) Then MAkeClientOplataIndex;
                       End;

        cmIndexSkidki:Begin
                       If Password(3) Then
                                   NewSkidkiIDX;
                      End;
   cmTovArStat   :Begin
                    If Password(2) Then
                                                  Begin
                                                        ClearDesktop(Event);
                                                        TovarStatWindow^.OpenTovarStatWindow;
                                                        ClearEvent(Event);
                                                  End;
                                                End;

   cmNabor   :Begin
                    If Password(2) Then
                                                  Begin
  exec (GetEnv('Comspec'),' /C hh ms-its:sklad.chm::page_3.html');

                                                      (*  ClearDesktop(Event);
                                                        TTNaborWindow^.OpenNaborWindow;
                                                        ClearEvent(Event); *)
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


(*
procedure TEditorApp.InitMenuBar;
var
  R: TRect;
  s : ArtikulStr;
begin
  GetExtent(R);
  s:=' ';
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
      NewSubMenu('На склад', $A001, NewMenu(
      NewItem('Сформировать ~п~риход', 'Ctrl+П',KbCtrlRusP , cmPrihod, hcDosShell,
      NewItem('Сформировать ~в~озврат', 'Ctrl+В',KbCtrlRusW , cmVozwrat, hcDosShell,
      NewItem('Поступление товара на ~с~клад','',KbCtrlRusC, cmInputToSklad, hcDosShell,
      nil)))),
      NewItem('Со склад~а~','',kbNokey,cmSupermarket,$A015,
         NewItem('Долги','',kbNokey,cmDolg,$A055,

      NewSubMenu('Док~у~мент', $A005, NewMenu(
      NewItem('Р~е~естр документов отгрузки', 'F2',KbF2, cmReestrDoc, hcDosShell,
      NewItem('П~р~осмотреть', 'F3',KbF3, cmViewDoc, hcDosShell,
      NewItem('~К~орректировать', 'F6',KbF6, cmEditDoc, hcDosShell,
      NewItem('~П~ечатать', 'F9',KbF9, cmPrintDoc, hcDosShell,
      NewLine(
      NewItem('Наличие на ~с~кладе', 'Shift-F1',KbShiftF1 , cmPrintSklad, hcDosShell,
      NewItem('Прайс-~л~ист', 'Shift-F2',KbShiftF2 , cmPrintPreisList, hcDosShell,
      NewItem('Долги дебиторо~в~', 'Shift-F7',KbShiftF7 , cmPrintDebitDolg, hcDosShell,
      NewItem('Проверка сертификатов', 'Shift-F8',KbShiftF8 , cmFindDSertif, hcDosShell,
      Nil)))))))))),
      NewSubMenu('Ск~л~ад', $A020, NewMenu(
      NewItem('~П~ереоценка товара', 'F8',KbF8 , cmPereozen, hcDosShell,
      NewItem('Корректирова~т~ь склад', 'F7',KbF7 , cmCorrectSklad, hcDosShell,
      NewItem('Ревизи~я~ на складе', 'Ctrl-Р',KbCtrlRusR , cmRewisia, hcDosShell,
      NewLine(
{      NewItem('Максимум/минимум', 'Ctrl-Т',KbCtrlRusT , cmMaxMin, hcDosShell,}
      NewItem('Блокиров~а~ть день', 'Ctrl-З', KbCtrlRusZ , cmLockDay, hcDosShell,
      NewItem('~Д~еблокировать день', 'Ctrl-Д', KbCtrlRusD , cmUnLockDay, hcDosShell,
      nil))))))){)},
    NewSubMenu('Сервис', $A025, NewMenu(
      NewItem('~К~алькулятор', 'Alt-К',KbAltRusK , cmCalculator, hcDosShell,
      NewItem('Календар~ь~', 'Alt-Ь',KbAltRus , cmCalendar, hcDosShell,
      NewLine(
      NewSubMenu('Конфигураци~я~',hcDosShell,NewMenu(
      NewItem('~Р~азмещение баз данных', '',KbAltRusJa,   cmConfig , hcDosShell,
      NewItem('~П~ечать', '',KbAlt9 ,   cmConfigPrint , hcDosShell,
      NewSubMenu('На~с~тройка продаж',hcDosShell,NewMenu(

      NewItem('~Д~окументы продажи', '',KbNoKey , cmSetupMarketDoc , hcDosShell,
      NewItem('Документы конси~г~нации', '',KbNoKey , cmSetupDebitDoc , hcDosShell,
      NewItem('Разделы и доку~м~енты', '',KbNoKey , cmConfigMarket , hcDosShell, Nil)))),

      NewSubMenu('И~н~струменты',hcDosShell,NewMenu(
      NewItem('~К~онсолидация', '',KbNoKey , cmIndex , hcDosShell,
      NewItem('~В~осстановление индексов товаров', '',KbNoKey , cmReanim , hcDosShell,
      NewItem('В~о~сстановление индексов клиентов', '',KbNoKey , cmReanimClient , hcDosShell,
      NewItem('Б~л~окировать период', '',KbNoKey , cmLockPeriod, hcDosShell,
      NewItem('~Д~еблокировать период','',KbNoKey , cmUnLockPeriod, hcDosShell,
      NewItem('Де~б~локировать документ','',KbNoKey , cmUnLockDoc, hcDosShell,
      NewItem('Настройка паролей','',KbNoKey , cmSetupPassword, hcDosShell,
      Nil)))))))),

      NewItem('Скидк~и~', '',KbNoKey , cmSkidki , hcDosShell,
      NewItem('~О~ператоры', '',KbNoKey , cmOperator , hcDosShell,
      NewItem('~Р~еквизиты', 'Alt-Р',KbAltRusR ,   cmRekwiziti , hcDosShell,
      NewItem('В арх~и~в', 'Shift-F10', kbShiftF10, cmCopyToArc, hcDosShell,
      Nil))))))))),
      NewItem('Выход','',KbAltRusCh , cmQuit, $A030,nil)))))),Nil)))))))));
end;*)

(*
procedure TEditorApp.InitMenuBar;
var
  R: TRect;
  s : ArtikulStr;
begin
  GetExtent(R);
  s:=' ';
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
      NewSubMenu('На склад', $A001, NewMenu(
      NewItem('Сформировать ~п~риход', 'Ctrl+П',KbCtrlRusP , cmPrihod, hcDosShell,
      NewItem('Сформировать ~в~озврат', 'Ctrl+В',KbCtrlRusW , cmVozwrat, hcDosShell,
      NewItem('Поступление товара на ~с~клад','',KbCtrlRusC, cmInputToSklad, hcDosShell,
      nil)))),
      NewItem('Со склад~а~','',kbNokey,cmSupermarket,$A015,
         NewItem('Долги','',kbNokey,cmDolg,$A055,
      NewSubMenu('~?~', $A070, NewMenu(
      NewSubMenu('Движение ~т~овара',hcDosShell,NewMenu(
{        NewItem('~В~ыборка товара', '',KbNoKey, cmTovarStat, hcDosShell,}
         NewItem('~А~нализ продаж', '',KbNoKey, cmMArketStat, hcDosShell,
         NewItem('~Б~алансировка', '',KbNoKey, cmBalance, hcDosShell,
         Nil))),{)),}
      NewSubMenu('Работа с к~л~иентом',hcDosShell,NewMenu(
         NewItem('~П~ерсонально', 'Alt-F7',KbAltF7, cmStat, hcDosShell,
         NewItem('~В~ыборка', 'Alt-F8',KbAltF8, cmClientStat, hcDosShell,
         NewItem('~О~плата консигнации', 'Alt-F2',KbAltF2, cmInfoDebit, hcDosShell,
         NewItem('~В~озвраты', 'Alt-F3',KbAltF3, cmInfoReturn, hcDosShell,
      nil))))),Nil))),


      NewSubMenu('Док~у~мент', $A005, NewMenu(
      NewItem('Р~е~естр документов отгрузки', 'F2',KbF2, cmReestrDoc, hcDosShell,
      NewItem('П~р~осмотреть', 'F3',KbF3, cmViewDoc, hcDosShell,
      NewItem('~К~орректировать', 'F6',KbF6, cmEditDoc, hcDosShell,
      NewItem('~П~ечатать', 'F9',KbF9, cmPrintDoc, hcDosShell,
      NewLine(
      NewItem('Наличие на ~с~кладе', 'Shift-F1',KbShiftF1 , cmPrintSklad, hcDosShell,
      NewItem('Прайс-~л~ист', 'Shift-F2',KbShiftF2 , cmPrintPreisList, hcDosShell,
      NewItem('Бланк реви~з~ии на складе', 'Shift-F3',KbShiftF3 , cmPrintRewizia, hcDosShell,
      NewItem('Контрольный кассов~ы~й лист', 'Shift-F4',KbShiftF4 , cmPrintKassa, hcDosShell,
      NewItem('~В~едомость "ОСТАТКИ-ОТГРУЗКА"', 'Shift-F5',KbShiftF5 , cmOstatki_Market, hcDosShell,
      NewItem('Оплата конси~г~нации', 'Shift-F6',KbShiftF6 , cmViewOplataRealiz, hcDosShell,
      NewItem('Долги дебиторо~в~', 'Shift-F7',KbShiftF7 , cmPrintDebitDolg, hcDosShell,
      NewItem('Проверка сертификатов', 'Shift-F8',KbShiftF8 , cmFindDSertif, hcDosShell,
{      NewItem('Сводные розни~ч~ные продажи', 'Shift-F8',KbShiftF8 , cmCalcRozniza, hcDosShell,}
      Nil)))))))))))))){)},
      NewSubMenu('Ск~л~ад', $A020, NewMenu(
      NewItem('~П~ереоценка товара', 'F8',KbF8 , cmPereozen, hcDosShell,
      NewItem('Корректирова~т~ь склад', 'F7',KbF7 , cmCorrectSklad, hcDosShell,
      NewItem('Ревизи~я~ на складе', 'Ctrl-Р',KbCtrlRusR , cmRewisia, hcDosShell,
      NewLine(
      NewItem('Ито~г~и дня', 'Alt-Г',KbAltRusG , cmItogi, hcDosShell,
{      NewItem('Максимум/минимум', 'Ctrl-Т',KbCtrlRusT , cmMaxMin, hcDosShell,}
      NewItem('Блокиров~а~ть день', 'Ctrl-З', KbCtrlRusZ , cmLockDay, hcDosShell,
      NewItem('~Д~еблокировать день', 'Ctrl-Д', KbCtrlRusD , cmUnLockDay, hcDosShell,
      NewLine(
      NewSubMenu('П~р~отокол',hcDosShell,NewMenu(
      NewItem('П~р~отокол операций', 'Alt-F6',KbAltF6 , cmViewCorrectSklad, hcDosShell,
      NewItem('Протокол корректировок и во~з~вратов', 'Ctrl-F6',KbCtrlF6 , cmViewCorrectVozwrat, hcDosShell,
      Nil))),
      nil)))))))))){)},
    NewSubMenu('Сервис', $A025, NewMenu(
      NewItem('~К~алькулятор', 'Alt-К',KbAltRusK , cmCalculator, hcDosShell,
      NewItem('Календар~ь~', 'Alt-Ь',KbAltRus , cmCalendar, hcDosShell,
      NewLine(
      NewSubMenu('Конфигураци~я~',hcDosShell,NewMenu(
      NewItem('~Р~азмещение баз данных', '',KbAltRusJa,   cmConfig , hcDosShell,
      NewItem('~П~ечать', '',KbAlt9 ,   cmConfigPrint , hcDosShell,
      NewSubMenu('На~с~тройка продаж',hcDosShell,NewMenu(

      NewItem('~Д~окументы продажи', '',KbNoKey , cmSetupMarketDoc , hcDosShell,
      NewItem('Документы конси~г~нации', '',KbNoKey , cmSetupDebitDoc , hcDosShell,
      NewItem('Разделы и доку~м~енты', '',KbNoKey , cmConfigMarket , hcDosShell, Nil)))),

      NewSubMenu('И~н~струменты',hcDosShell,NewMenu(
      NewItem('~К~онсолидация', '',KbNoKey , cmIndex , hcDosShell,
      NewItem('~В~осстановление индексов товаров', '',KbNoKey , cmReanim , hcDosShell,
      NewItem('В~о~сстановление индексов клиентов', '',KbNoKey , cmReanimClient , hcDosShell,
      NewItem('Б~л~окировать период', '',KbNoKey , cmLockPeriod, hcDosShell,
      NewItem('~Д~еблокировать период','',KbNoKey , cmUnLockPeriod, hcDosShell,
      NewItem('Де~б~локировать документ','',KbNoKey , cmUnLockDoc, hcDosShell,
      NewItem('~А~варийное создание служебных файлов','',KbNoKey , cmCreatSpecialFile, hcDosShell,
      NewItem('Настройка паролей','',KbNoKey , cmSetupPassword, hcDosShell,

      NewSubMenu('В~и~деорежим',hcDosShell,NewMenu(
      NewMarkedItem(S+'~Ц~ветной', '',KbNoKey , cmColor , hcDosShell,
      NewMarkedItem(S+'~Ч~ерно-белый', '',KbNoKey , cmBlack , hcDosShell,
         Nil))),Nil)))))))))),

      NewItem('Скидк~и~', '',KbNoKey , cmSkidki , hcDosShell,
      NewItem('~О~ператоры', '',KbNoKey , cmOperator , hcDosShell,
      NewItem('~Р~еквизиты', 'Alt-Р',KbAltRusR ,   cmRekwiziti , hcDosShell,
      NewItem('Корректировать кассу', '',KbAltSpace ,   cmCorrectKassa , hcDosShell,Nil))))))))),
      NewItem('Копия остатков', 'Alt-F10', kbAltF10, cmCreatReport, hcDosShell,
      NewItem('~В~ыход в OS', '', kbNoKey, cmDosShell, hcDosShell,
      NewItem('В арх~и~в', 'Shift-F10', kbShiftF10, cmCopyToArc, hcDosShell,
      NewItem('~О~ программе', 'F1', kbF1, cmAbout, hcDosShell,
      Nil))))))))),
      NewItem('Выход','',KbAltRusCh , cmQuit, $A030,nil)))))))))));
      PbxMenuBar(MenuBar)^.SetMarker(cmColor);
end;
*)
procedure TEditorApp.InitMenuBar;
var
  R: TRect;
  s : ArtikulStr;
begin
  GetExtent(R);
  s:=' ';
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
      NewSubMenu('На склад', $A001, NewMenu(
      NewItem('Сформировать ~п~риход', 'Ctrl+П',KbCtrlRusP , cmPrihod, hcDosShell,
      NewItem('Сформировать ~в~озврат', 'Ctrl+В',KbCtrlRusW , cmVozwrat, hcDosShell,
      NewItem('Заявка поставщику', '',kbNokey, cmPostZak, hcDosShell,
      NewItem('Поступление товара на ~с~клад','',KbCtrlRusC, cmInputToSklad, hcDosShell,
      nil))))),
      NewItem('Со склад~а~','',kbNokey,cmSupermarket,$A015,
      NewSubMenu('Долги', $A055, NewMenu(
      NewItem('Консигнаторы','',kbNokey,cmDolg,$A055,
      NewItem('Поставщики','',kbNokey,cmBarter,$A055,
      NewItem('Сотрудники','',kbNokey,cmEmlDolg,$A055
      ,Nil)))),

      NewSubMenu('~?~', $A070, NewMenu(
      NewSubMenu('Движение ~т~овара',hcDosShell,NewMenu(
{        NewItem('~В~ыборка товара', '',KbNoKey, cmTovarStat, hcDosShell,}
         NewItem('Движение ~т~овара', '',KbNoKey, cmTovarStat, hcDosShell,
         NewItem('~К~онкурс', '',KbNoKey, cmLeftConcurs, hcDosShell,
         NewItem('~А~нализ продаж', '',KbNoKey, cmMArketStat, hcDosShell,
         NewItem('~П~родажи и приходы', '',KbNoKey, cmSpecialMArketStat, hcDosShell,
         NewItem('~Б~алансировка', '',KbNoKey, cmBalance, hcDosShell,
         Nil)))))),
         NewItem('Поставщики', '',KbNoKey, cmMakeStat, hcDosShell,
         NewItem('~П~ерсонально', 'Alt-F7',KbAltF7, cmStat, hcDosShell,
         NewItem('~В~ыборка', 'Alt-F8',KbAltF8, cmClientStat, hcDosShell,
         NewItem('Выборка по взаимозачетам', '',kbNoKey, cmStat1, hcDosShell,
         NewItem('~О~плата консигнации', 'Alt-F2',KbAltF2, cmInfoDebit, hcDosShell,
         NewItem('Оплаченные отгрузки по ~а~гентам', '^A',KbCtrlRusA, cmCalcMenedger, hcDosShell,
         NewItem('Детальные отгрузки по разделам', '',KbNoKey, cmGrAgent, hcDosShell,
         NewItem('Отчет по агентам', '',KbNoKey, cmCalcMenedger2, hcDosShell,
         NewItem('~В~озвраты', 'Alt-F3',KbAltF3, cmInfoReturn, hcDosShell,

      NewSubMenu('Бухгалтер',hcDosShell,NewMenu(
         NewItem('Книга покупок', '',KbNoKey, cmBuchPrihod, hcDosShell,
         NewItem('Книга продаж', '',KbNoKey, cmBuchProd, hcDosShell,
         Nil))),


         Nil)))))))))))),


      NewSubMenu('Док~у~мент', $A005, NewMenu(
      NewSubMenu('Р~е~естр документов',hcDosShell,NewMenu(
      NewItem('~О~тгрузки', 'F2',KbF2, cmReestrDoc, hcDosShell,
      NewItem('~Д~оставки', 'Alt-F2',KbAltF2, cmReestrDost, hcDosShell,
      NewItem('~П~рихода', 'Ctrl-F2',KbCtrlF2, cmReestrPrh, hcDosShell,
      NewItem('~Р~евизий', 'Ctrl-F3',KbCtrlF3, cmReestrRwz, hcDosShell,
      NewItem('Касса', 'Ctrl-F4',KbCtrlF4, cmReestrKassa, hcDosShell,
      NewItem('~В~озвратов', 'Ctrl-F5',KbCtrlF5, cmReestrVzw, hcDosShell,
       Nil))))))),
      NewItem('П~р~осмотреть', 'F3',KbF3, cmViewDoc, hcDosShell,
      NewItem('~К~орректировать', 'F6',KbF6, cmEditDoc, hcDosShell,
      NewItem('~П~ечатать', 'F9',KbF9, cmPrintDoc, hcDosShell,
      {NewLine(}
      NewItem('Сводный отчет склада', '',KbNoKey , cmEndRep, hcDosShell,
      NewItem('Наличие на ~с~кладе', 'Shift-F1',KbShiftF1 , cmPrintSklad, hcDosShell,
      NewItem('Архив наличия на ~с~кладе', '',KbnoKey , cmArcOst, hcDosShell,
      NewItem('Архив долгов', '',KbnoKey , cmArcDlg, hcDosShell,
      NewItem('Прайс-~л~ист', 'Shift-F2',KbShiftF2 , cmPrintPreisList, hcDosShell,
      NewItem('Бланк реви~з~ии на складе', 'Shift-F3',KbShiftF3 , cmPrintRewizia, hcDosShell,
      NewItem('Контрольный кассов~ы~й лист', 'Shift-F4',KbShiftF4 , cmPrintKassa, hcDosShell,
      NewItem('Дополнительно', '',kbNoKey, cmViewSpecialKassa, hcDosShell,
      NewItem('~В~едомость "ОСТАТКИ-ОТГРУЗКА"', 'Shift-F5',KbShiftF5 , cmOstatki_Market, hcDosShell,
      NewSubMenu('~Б~ухгалтер',hcDosShell,NewMenu(
      NewItem('Бухгалтер', '',KbNoKey , cmBuch, hcDosShell,
      NewItem('Бухгалтер 2', '',KbNoKey , cmBuch2, hcDosShell,
      NewItem('Бухгалтер 3', '',KbNoKey , cmBuchNovarReport, hcDosShell,
      NewItem('Поставщики', '',KbNoKey , cmCalcPost, hcDosShell,
      NewItem('Покупатели', '',KbNoKey , cmCalcMarket, hcDosShell,
      NewItem('Выгрузить в 1С', '',KbNoKey , cmTo1c, hcDosShell,
      NewItem('Процент НДС ', '',KbNoKey , cmProzNdsDay, hcDosShell,
            Nil)))))))),
      NewItem('Оплата конси~г~нации', 'Shift-F6',KbShiftF6 , cmViewOplataRealiz, hcDosShell,
      NewItem('Долги дебиторо~в~', 'Shift-F7',KbShiftF7 , cmPrintDebitDolg, hcDosShell,
      NewItem('Долги по агентам', '',KbNoKey , cmCalcDebitAgent,hcDosShell,
      NewItem('Долги сотрудников', '',KbNoKey , cmCalcDebitEmpl,hcDosShell,
      NewItem('Проверка сроков действия сертификатов', 'Shift-F8',KbShiftF8 , cmFindDSertif, hcDosShell,
      NewItem('Проверка сроков реализации товаров', '',KbNoKey , cmFindSrok, hcDosShell,
      NewItem('Отчет оператора', '',KbNoKey , cmOperatorReport, hcDosShell,
      NewItem('Итоговые взаимоза~ч~еты', 'Shift-F9',KbShiftF9 ,cmCalcSaldoBarter, hcDosShell,
      NewItem('Денежные расчеты с поставщиками', '',KbNoKey, cmViewOplataBarter, hcDosShell,
      NewItem('Планирование платежей', '',KbNoKey , cmCreatPlan, hcDosShell,
{     NewItem('Сводные розни~ч~ные продажи', 'Shift-F8',KbShiftF8 , cmCalcRozniza, hcDosShell,}
      Nil))))))))))))))))))))))))),
      NewSubMenu('Ск~л~ад', $A020, NewMenu(
      NewItem('~П~ереоценка товара', 'F8',KbF8 , cmPereozen, hcDosShell,
      NewItem('Корректирова~т~ь склад', 'F7',KbF7 , cmCorrectSklad, hcDosShell,
      NewItem('Сформироать наборы', '',KbNoKey, cmNabor, hcDosShell,
      NewItem('Вн~у~треннее перемещение', '^У',KbCtrlRusU , cmTransport, hcDosShell,
      NewItem('Ревизи~я~ на складе', 'Ctrl-Р',KbCtrlRusR , cmRewisia, hcDosShell,
      (*NewItem('Загрузка товара (ВЭН)', '',KbNoKey , cmLoadMainSklad, hcDosShell,
      NewItem('Сохранить продажи (ВЭН)', '',KbNoKey , cmSaveRemote, hcDosShell,*)


      NewLine(
      NewItem('Ито~г~и дня', 'Alt-Г',KbAltRusG , cmItogi, hcDosShell,
{     NewItem('Максимум/минимум', 'Ctrl-Т',KbCtrlRusT , cmMaxMin, hcDosShell,}
      NewItem('Блокиров~а~ть день', 'Ctrl-З', KbCtrlRusZ , cmLockDay, hcDosShell,
      NewItem('~Д~еблокировать день', 'Ctrl-Д', KbCtrlRusD , cmUnLockDay, hcDosShell,
      NewLine(
      NewSubMenu('П~р~отокол',hcDosShell,NewMenu(
      NewItem('П~р~отокол операций', 'Alt-F6',KbAltF6 , cmViewCorrectSklad, hcDosShell,
      NewItem('Протокол корректировок и во~з~вратов', 'Ctrl-F6',KbCtrlF6 , cmViewCorrectVozwrat, hcDosShell,
      Nil))),
      nil)))))))))))){)},
      NewSubMenu('Сервис', $A025, NewMenu(
      NewItem('~К~алькулятор', 'Alt-К',KbAltRusK , cmCalculator, hcDosShell,
      NewItem('Календар~ь~', 'Alt-Ь',KbAltRus , cmCalendar, hcDosShell,
      NewItem('Импорт кл.базы', '',KbNoKey,cmImpClient,hcDosShell,
      NewSubMenu('Конфигураци~я~',hcDosShell,NewMenu(
      NewItem('~Р~азмещение баз данных', '',KbAltRusJa,   cmConfig , hcDosShell,
      NewItem('~П~ечать', '',KbAlt9 ,   cmConfigPrint , hcDosShell,
      NewSubMenu('На~с~тройка продаж',hcDosShell,NewMenu(

      NewItem('~Д~окументы продажи', '',KbNoKey , cmSetupMarketDoc , hcDosShell,
      NewItem('Документы конси~г~нации', '',KbNoKey , cmSetupDebitDoc , hcDosShell,
      NewItem('Разделы и доку~м~енты', '',KbNoKey , cmConfigMarket , hcDosShell,
      NewItem('Стартовые номера', '',KbNoKey , cmSetupStart , hcDosShell,
      NewItem('Настройка кредита', '',KbNoKey , cmInputKreditClient , hcDosShell, Nil)))))),

      NewSubMenu('И~н~струменты',hcDosShell,NewMenu(
      NewItem('Автоскидки', '',KbNoKey , cmVvodSkidki , hcDosShell,
      NewItem('Сменить код объекта ', '',KbNoKey , cmChangeNumber , hcDosShell,
      NewItem('~К~онсолидация', '',KbNoKey , cmIndex , hcDosShell,
      NewItem('~В~осстановление индексов товаров', '',KbNoKey , cmReanim , hcDosShell,
      NewItem('В~о~сстановление индексов клиентов', '',KbNoKey , cmReanimClient , hcDosShell,
      NewItem('~В~осстановление индексов скидок', '',KbNoKey , cmIndexSkidki , hcDosShell,
      NewItem('Б~л~окировать период', '',KbNoKey , cmLockPeriod, hcDosShell,
      NewItem('~Д~еблокировать период','',KbNoKey , cmUnLockPeriod, hcDosShell,
      NewItem('Де~б~локировать документ','',KbNoKey , cmUnLockDoc, hcDosShell,
      NewItem('~А~варийное создание служебных файлов','',KbNoKey , cmCreatSpecialFile, hcDosShell,
      NewItem('~И~ндексы по оборотам клиентов', '',KbNoKey , cmMakeHistory , hcDosShell,
      NewItem('~И~ндексы по оплатам клиентов', '',KbNoKey , cmMakeHistoryOpl , hcDosShell,
      NewItem('~И~ндексы по возвратам клиентов', '',KbNoKey , cmMakeHistoryReturn , hcDosShell,

      NewSubMenu('В~и~деорежим',hcDosShell,NewMenu(
      NewMarkedItem(S+'~Ц~ветной', '',KbNoKey , cmColor , hcDosShell,
      NewMarkedItem(S+'~Ч~ерно-белый', '',KbNoKey , cmBlack , hcDosShell,
      Nil))),
      NewItem('Настройка паролей','',KbNoKey , cmSetupPassword, hcDosShell,
      {NewItem('Исправить ошибку -> первая фаза','',KbNoKey , cmError, hcDosShell,}
      {NewItem('Исправить ошибку -> вторая фаза','',KbNoKey , cmError2, hcDosShell,}
      Nil)))))))))))))))),

      NewItem('Скидк~и~', '',KbNoKey , cmSkidki , hcDosShell,
      NewItem('Просмотр скидок', '',KbNoKey , cmViewSkidki , hcDosShell,
      NewItem('Просмотр персональных скидок', '',KbNoKey , cmViewSkidkiPeronal , hcDosShell,

      NewItem('Просмотр разногласий (авто)', '',KbNoKey , cmViewSkidki1 , hcDosShell,
      NewItem('Просмотр разногласий (ручн)', '',KbNoKey , cmViewSkidki2 , hcDosShell,
      NewItem('Анализ скидок', '',KbNoKey , cmPolitikaSkidok , hcDosShell,
      NewItem('За период...', '',KbNoKey , cmKassaStat , hcDosShell,
      NewItem('Блокировки за период...', '',KbNoKey , cmLockFromPeriod , hcDosShell,
      NewItem('Список пассивных клиентов', '',KbNoKey , cmViewLockBaza, hcDosShell,
     {
      NewSubMenu('Настройка кредита',hcDosShell,NewMenu(
      NewItem('~С~амовывоз', '',KbNoKey , cmInputKreditClient , hcDosShell,
      NewItem('~Т~орг.предст.', '',KbNoKey , cmInputKreditAgent , hcDosShell,
      Nil))),
       }
      NewItem('~О~ператоры', '',KbNoKey , cmOperator , hcDosShell,
      NewItem('~Р~еквизиты', 'Alt-Р',KbAltRusR ,   cmRekwiziti , hcDosShell,
      NewItem('Реквизиты 2', '',KbNoKey ,   cmRekwiziti2 , hcDosShell,
      NewItem('Корректировать кассу', '',KbAltSpace ,   cmCorrectKassa , hcDosShell,
	 Nil)))))))))))))))))),
      NewItem('Копия остатков', 'Alt-F10', kbAltF10, cmCreatReport, hcDosShell,
     { NewItem('~В~ыход в OS', '', kbNoKey, cmDosShell, hcDosShell,
      NewItem('В арх~и~в', 'Shift-F10', kbShiftF10, cmCopyToArc, hcDosShell,}
      NewItem('~П~ омощь', 'F1', kbF1, cmAbout, hcDosShell,
      Nil))))))),
      NewItem('Выход','',KbAltRusCh , cmQuit, $A030,nil)))))))))));
      PbxMenuBar(MenuBar)^.SetMarker(cmColor);
end;



procedure TEditorApp.InitStatusLine;
var
  R: TRect;
begin
  StatusLine := PStatusLine(RezFile.Get('StatusLine'));
  StatusLine^.Show;
end;
Label Stop;

Var Mode,OrigMode : Integer;
    f : File;
 {  c : String;
    c1 : Char;}
    l : Boolean;
 {   st : String;}
    Res : Byte;
Begin
{TestPc;}
Starting:=False;

Mode:=FileMode;
FileMode:=66;
ProdagaWindow:=False;

Res:=0;
EditorApp.Init(Res);
Case Res of
1:Begin
  SpecialBeep;
  SpecialBeep;
(*   MessageBox(#3+'Незаконная копия!'+' При дальнейших попытках запуска'+
              '-данные могут быть уничтожены!'+^M+
              #3+' Лучше легально приобрести программное обеспечение,'+
                    +'которому вы доверяете свои деньги.',Nil,mfWarning+mfCancelButton);*)
   EditorApp.Done;
   FileMode:=Mode;
   Halt;
  End;
2:Begin
  SpecialBeep;
  SpecialBeep;
   MessageBox(#3+'ИСТЕК срок лицензионного соглашения!'^M+
              #3+'Для продления лицензионного соглашения обратитесь к разработчику!',
                    Nil,mfWarning+mfCancelButton);
   EditorApp.Done;
   FileMode:=Mode;
   HAlt;
  End;
3:Begin
  SpecialBeep;
  SpecialBeep;
   MessageBox(#3'ИСТЕКАЕТ срок лицензионного соглашения!'^M+
              #3'Для продления лицензионного соглашения обратитесь к разработчику!',
                    Nil,mfWarning+mfCancelButton);
  End;
Else;
End;

{  If TDate Then
  Begin}
If Not(Wzlom) Then
Begin
(*
l:=(TestFlag);
If (Not(l) Or (StrToInt(CurrentPassword)=0))    Then
  Begin
  If (l) And (StrToInt(CurrentPassword)=0) Then
    MessageBox(^M+#3'Будьте внимательны! Программа уже запущена в одном из окон Windows!',
    Nil,mfWarning+mfCancelButton);
    OldExit:=ExitProc;
    ExitProc:=@UserExit;
*)
  New(MakeElement,Init);
  New(BazElement,Init);
  New(Element,Init);
  EditorApp.Run;
  DelFlag;
(*
  End
  Else
   Begin
    SpecialBeep;
    MessageBox(#3'Программа уже запущена в одном из окон Windows!'+
    ' Воспользуйтесь сочетанием клавиш Alt-Tab или Ctrl-Esc для переключения в уже запущенную копию!',
    Nil,mfError+mfCancelButton);
   End;
*)
End;
{   End;}
Dispose(BazElement,Done);
Dispose(Element,Done);
Dispose(MakeElement,Done);
EditorApp.Done;
FileMode:=Mode;
ExitProc:=OldExit;
end.

