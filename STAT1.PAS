{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit Stat1;


Interface


Uses Dialogs,Drivers,Glob,Access,LockInfo,ServStr,MyCalc,DStat;

Type {главное окно статистики,фильтры документов,оплаты,выбор клиентов}
  PSelectClientWindow1 = ^TSelectClientWindow1;
  TSelectClientWindow1 = object(TDialog)
    procedure OpenSelectClientWindow;
    procedure DrawCurrent;
    procedure AddName;
    Procedure FullPreview;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;



Implementation

uses DBEngine,Objects, Views, MsgBox,Protect,{Calc,}TPDate,Market,Tools,Printers,UtilsP,
     App, ColorTxt,Validate,Serv,Nastr,Vision1,Vision3,Barter,Vision4,NetDbEng,Utils;

var
 ClientStatWindow : PSelectClientWindow1;

 SelectClient,CalcList,TempCalcList : PBox;
 StatList: PBox;



 Reiting,PrevCurrent,PrevCur : String;
 LastClientKod : ArtikulStr;
 Prevs: TEnjoyStr;
 {Метки в окне последних цен}
 SControlDocNumer,
 SControlDocDate,
 SControlDocTime,
 SControlDocOperator,

 sControlRashet,
 sControlSkidka,
 sControlVidDoc,
 sControl,
 sControlClient,
 sControlDocFiltr,
 sControlOplataFiltr,
 sControlDatePP,
 sControlSummaPP,
 sControlNPP,
 sControlBank,
 sControlStartDate,
 sControlStopDate,
 sControlStatus,
 sControlItogo,
 sControlItogoSkidka,
 sControlDoc,
 sControlTimeM,
 SControlDop,
 SControlPos,
 SControlSort,
 SControlVidSort,
 SControlReiting: PView;

 Ws : String[CIZena];
 PrevPosition : TMyString;
 mm : Maska9;
 ss : Maska2;
 StopDate ,StartDate ,StopDateA ,StartDateA : TDateString;
 VidSorting,Sorting,Filtr,Oplata : Word;
 AllSumma,AllSummaOtgr,AllSkidka : String[CIZena+5];






Function Period:Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control,ControlStart,ControlStop : PView;
  C : Word;
  l : LongInt;
  s1,s2 : TDateString;

begin
Period :=False;
s1:=StartDate;
s2:=StopDate;

1:
R.Assign(23, 9, 57, 14);
New(Dlg, Init(R, 'Укажите период поиска'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E011;
Dlg^.Palette := dpCyanDialog;

R.Assign(6, 2, 16, 3);
ControlStart := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStart);
  PInputLine(ControlStart)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DAteFiltr, True));

ControlStart^.SetData(s1);

  R.Assign(3, 2, 6, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~с~:', ControlStart)));

R.Assign(20, 2, 30, 3);
ControlStop := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStop);
  PInputLine(ControlStop)^.Validator := New(PPXPictureValidator, Init(DAteFiltr{'[##-##-9#]'}, True));

ControlStop^.SetData(s2);

  R.Assign(16, 2, 20, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~п~о:', ControlStop)));

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
   ControlStart^.GetData(s1);
   ControlStop^.GetData(s2);
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);

   If Not(TestDate(s1,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Not(TestDate(s2,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   StartDate:=s1;
   StopDate:=s2;
   Period:=True;

   {если даты перепутаны переставляем их}
   If DateStringToDate(DateMask,StopDate)<DateStringToDate(DateMask,StartDate) Then
    Begin
        s1:=StopDate;
        StopDate:=StartDate;
        StartDate:=s1;
    End;
 End
 Else
  Begin
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);
  End;
end;









procedure TSelectClientWindow1.OpenSelectClientWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmStat1, nil) = nil then
  begin
    DInfo('Инициализация анализа...');
    L:=True;
    ClientStatWindow := New(PSelectClientWindow1, Init(L));
    If L Then
    Begin
    NoInfo;
    Application^.InsertWindow(ClientStatWindow);
    End
    Else
        Begin
         Status:=DocNormal;
         NoInfo;
         Dispose(ClientStatWindow,Done);
        End;
  end
  else
    if PView(ClientStatWindow) <> Desktop^.TopView then ClientStatWindow^.Select;
end;



constructor TSelectClientWindow1.Init(Var l : Boolean);
Var R : TRect;
    i : Word;
    s : String[CIZena];
Begin
L:=False;
R.Assign(0, 0, 80, 23);
inherited Init(R, '');
TekDate:=FDate;
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$F142;

R.Assign(47, 0, 57, 1);
SControlStartDate := New(PInputLine, Init(R, CDate));
Insert(sControlStartDate);
  PInputLine(SControlstartDate)^.Validator := New(PPXPictureValidator, Init(DAteFiltr{'##-##-9#'}, True));

  R.Assign(34, 0, 47, 1);
  Insert(New(PLabel, Init(R, 'З~а~ период с:', SControlStartDAte)));
s:='01-04-99';{специально для бакши}

SControlStartDate^.SetData(s);


R.Assign(61, 0, 71, 1);
sControlStopDate := New(PInputLine, Init(R, CDate));
Insert(sControlStopDate);
  PInputLine(sControlStopDate)^.Validator := New(PPXPictureValidator, Init(DAteFiltr{'##-##-9#'}, True));

  R.Assign(57, 0, 61, 1);
  Insert(New(PLabel, Init(R, '~п~о:', SControlStopDate)));

SControlStopDate^.SetData(FDate);

R.Assign(1, 1, 50, 3);
SControlDocFiltr := New(PCheckboxes, Init(R,
  NewSItem('С~п~',
  NewSItem('~Т~Ч*',
  NewSItem('ФЛ*',
  NewSItem('~С~Ф*',
  NewSItem('СФ',
  NewSItem('Д~*~',
  NewSItem('Д С~Ф~*',
  NewSItem('~Д~',
  NewSItem('Д СФ', Nil)))))))))));

Insert(SControlDocFiltr);
i:=511;
SControlDocFiltr^.SetData(i);


R.Assign(52, 1, 71, 3);
SControlOplataFiltr := New(PCheckboxes, Init(R,
  NewSItem('~О~плаченные',
  NewSItem('~Н~е оплаченные', Nil))));
Insert(SControlOplataFiltr);
i:=3;
SControlOplataFiltr^.SetDAta(i);

R.Assign(52, 4, 53, 21);
SControl := New(PScrollBar, Init(R));
Insert(SControl);

R.Assign(0, 4, 52, 21);
Client := New(PBox, Init(R, 2, PScrollbar(SControl)));
Client^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'Barter.db');

i:=IOResult;
Reset (ClientFile);
i:=IOResult;
If i=0 Then
Begin
While Not(Eof(ClientFile)) Do
 Begin
    {
     Repeat
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));
    }
     ReadClient(ClientFile,ClientElement^.Dat);
    {
     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
    }
  If ClientElement^.Dat.Employ Then
   Begin
    Format (ClientElement^.Dat.Name,CClient);
    S:='0.00';{CalcDolg(ClientElement.Kod);}
    Str(StrToReal(s):CIZena:CMAntissa,s);
    Client^.List^.Insert(NewStr(ClientElement^.Dat.Name+'│'+ClientElement^.Dat.Kod{+'│'+s}));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  MessageBox(^M+#3'Ошибка доступа к базе клиентов!',nil,mfError+mfCanCelButton);
  L:=False;
  Exit;
 End;
Client^.FocusItem(0);
Client^.HelpCtx:=$F132;
Insert(Client);


  R.Assign(1, 3, 42, 4);
  Insert(New(PLabel, Init(R, 'Ба~з~а клиентов        Код', Client)));


R.Assign(79, 4, 80, 21);
SControl := New(PScrollBar, Init(R));
Insert(SControl);

R.Assign(53, 4, 79, 21);
SelectClient := New(PBox, Init(R, 1, PScrollbar(SControl)));
SelectClient^.NewList(New(PTextCollection, Init(0,1)));
SelectClient^.FocusItem(0);
SelectClient^.HelpCtx:=$F147;
Insert(SelectClient);

  R.Assign(53, 3, 79, 4);
  Insert(New(PLabel, Init(R, '~В~ыбранные клиенты     Код', SelectClient)));


R.Assign(2, 21, 16, 22);
SControl := New(PColoredText, Init(R, '     Лицензия:', $74));
Insert(SControl);

R.Assign(16, 21, 61, 22);
SControlDop := New(PColoredText, Init(R, #3+'???', $7E));
Insert(SControlDop);

R.Assign(25, 22, 43, 23);
SControl := New(PColoredText, Init(R, ' Выбрано клиентов:', $74));
Insert(SControl);

R.Assign(43, 22, 48, 23);
SControlPos := New(PColoredText, Init(R, #3+'???', $4E));
Insert(SControlPos);

R.Assign(2, 0, 32, 1);
SControl := New(PColoredText, Init(R, ' Формирование выборки по В/З ', $4F));
Insert(SControl);

SelectNext(False);
AddNAme;
Filtr:=511;
Oplata:=3;
PrevCurrent[0]:=#0;
L:=True;
End;



procedure TSelectClientWindow1.AddName;

Var R : TRect;
    R1,R2 : Real;
    KolStr : String[CKol];
Begin
  Str(SelectClient^.List^.Count:CKol,Kolstr);
  DelSpace(KolStr);
  Dispose(SControlPos,Done);
  R.Assign(43, 22, 48, 23);
  SControlPos := New(PColoredText, Init(R, #3+KolStr, $4E));
  Insert(SControlPos);
End;


procedure TSelectClientWindow1.DrawCurrent;
Var St : TEnjoyStr;
     R : TRect;
Begin
If (Client^.List<>Nil)And(Client^.List^.Count>0)  Then
 Begin
  st:=Client^.GetText(Client^.Focused,Client^.List^.Count);
  If St <> PrevCurrent Then
   Begin
    PrevCurrent:=St;
    st:=Copy(PrevCurrent,1+CClient+1,CClientKod);
    st:=GetClientField(fEnvir,St,2);
    DelSpaceRight(st);
    Dispose(sControlDop,Done);
    R.Assign(16, 21, 61, 22);
    sControlDop := New(PColoredText, Init(R, #3+st, $7E));
    Insert(sControlDop);
   Redraw;
   End;

 End

 Else
  Begin
If PrevCurrent[0]<>#0 Then
Begin
PrevCurrent[0]:=#0;
Dispose(sControlDop,Done);
R.Assign(16, 21, 61, 22);
sControlDop := New(PColoredText, Init(R, #3+'???', $7E));
Insert(sControlDop);
Redraw;
End;
  End;

End;

procedure TSelectClientWindow1.FullPreview;
Begin
End;



procedure TSelectClientWindow1.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1 : String;
    SDoc : ArtikulStr;
    SDate: TDateString;
    ClientKod : ArtikulStr;
    Ls : LongInt;
    l : Boolean;
    sstart,sstop : TDateString;
begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
      kbIns: Begin
               ProdagaWindow:=False;
                ClearFind;
            If(Client^.State and sfFocused <> 0) And (Client^.List^.Count>=1) Then
            Begin
               s:=Client^.GetText(Client^.Focused,Client^.List^.COunt);
               If TestElement(Copy(s,1+CClient+1,CClientKod),SelectClient) Then
               Begin
                s:=Copy(s,1,CCLient+1+CClientKod);
                SelectClient^.List^.Insert(NewStr(s));
                SelectClient^.SetRange(SelectClient^.List^.Count);
                ProdagaWindow:=False;
                s:=Client^.GetText(Client^.Focused,Client^.List^.COunt);
                s:=Copy(s,1+CClient+1,CClientKod);
                SelectClient^.FocusItem(LoCation(SelectClient,S,ProdagaWindow));
                If SelectClient^.Focused+1<SelectClient^.List^.Count Then
                SelectClient^.FocusItem(SelectClient^.List^.Count-1);
               End;
               If (Client^.Focused+1)<Client^.List^.Count Then
               Client^.FocusItem(Client^.Focused+1);
            End;
              ClearEvent(Event);
              Redraw;
              AddName;
              PrevCurrent[0]:=#0;
            End;


  kbCtrLDel: Begin
               ClearFind;
               ProdagaWindow:=False;
     If (SelectClient^.State and sfFocused <> 0) And (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>=1) Then
            Begin
             SelectClient^.NewList(nil);
             SelectClient^.NewList(New(PTextCollection, Init(0,1)));
            End;
            ClearEvent(Event);
             Redraw;
             PrevCurrent[0]:=#0;
             AddName;
            End;

     kbDel: Begin
                ClearFind;
               ProdagaWindow:=False;
     If (SelectClient^.State and sfFocused <> 0) And (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>=1) Then
            Begin
             SelectClient^.List^.AtFree(SelectClient^.Focused);
             SelectClient^.SetRange(SelectClient^.List^.Count);
             If SelectClient^.Focused>0 Then
             SelectClient^.FocusItem(SelectClient^.Focused);

             If (SelectClient^.Focused>=SelectClient^.List^.Count) and(SelectClient^.Focused>0) Then
             SelectClient^.FocusItem(SelectClient^.Focused-1);

              ClearEvent(Event);
              Redraw;
              AddName;
            End;
              PrevCurrent[0]:=#0;
            End;

   kbGrayPlus,
   kbCtrlIns: Begin
                ClearFind;
                 ProdagaWindow:=False;
          If ((Client^.State and sfFocused <> 0)And(Client^.List^.Count>= 1)) Then
            Begin
             DInfo('Минуточку...');
             If Client^.List^.Count>0 Then
             Begin
             SelectClient^.NewList(nil);
             SelectClient^.NewList(New(PTextCollection, Init(0,1)));

             For ls :=0 To Client^.List^.Count-1 Do
              Begin
               s:=Client^.GetText(ls,Client^.List^.Count);
               {if Testelement(Copy(s,1+CClient+1,CClientKod),SelectClient) then}
                Begin
                 s:=Copy(s,1,CCLient+1+CClientKod);
                 SelectClient^.List^.Insert(NewStr(s));
                 SelectClient^.SetRange(SelectClient^.List^.Count);
                End;
              End;
             End;
              NoInfo;
                 ProdagaWindow:=False;
                 {SelectClient^.SetRange(SelectClient^.List^.Count);}
                 If Client^.Focused+1<Client^.List^.Count Then Client^.FocusItem(Client^.Focused+1);
                 If SelectClient^.Focused+1<SelectClient^.List^.Count Then
                 SelectClient^.FocusItem(SelectClient^.List^.Count-1);
             End
            Else ClearEvent(Event);
           End;

        kbEsc: Begin
{                   Dispose(SControlPos,Done);
                    Dispose(SControlDop,Done);}
                    Event.What:=evCommand;
                    Event.Command:=cmCancel;
                    PutEvent(Event);
                    ClearEvent(Event);
                  End;
         Else;
         End;{KeyDown}
  evCommand :
        Case Event.Command Of

  cmAbout: Begin
    AboutCHM('42');
    ClearEvent(Event);
  End;

  cmFullView:Begin

             End;


        cmAllSfB    :Begin
              ClearFind;
              If (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>0)
		        Then
               Begin
               {проверяем стартовую дату}
               SControlStartDate^.GetData(sstart);
               If Not(TestDate(sstart,Ls)) Then
                Begin
                 MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;
               {проверям конечную дату}
               SControlStopDate^.GetData(sstop);
               If Not(TestDate(sstop,Ls)) Then
                Begin
                 MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;


               {назначаем диапазон дат}
               StopDate :=SStop;
                        StartDate:=SStart;
               {назначаем фильтр видов документов}
               SControlDocFiltr^.GetData(Filtr);

               {назначаем фильтр оплаты}
               sControlOplataFiltr^.GetData(Oplata);

               {старт загрузки ответа на сформированный запрос}
                CalcMenedger3(SelectClient,Filtr,Oplata,StartDate,StopDate);
               End
               Else
                Begin
                 MessageBox(^M+#3'Список выбранных клиентов - пустой!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;






               PrevCurrent[0]:=#0;
                     End;



cmStat1:Begin
         ClearEvent(Event);
        End;
        cmCancel    : Begin
                          Event.What:=evCommand;
                          Event.Command:=cmClose;
                          PutEvent(Event);
                          ClearEvent(Event);
                          PrevCurrent[0]:=#0;
                         End;
         Else;
         End;{evCommand}
         Else;
         End;{*Case*}

  if (Event.What = evBroadcast) and
    (Event.Command = cmStat1) then ClearEvent(Event);



  inherited HandleEvent(Event);

  If (Desktop^.Current=PView(ClientStatWindow)) And (Event.What <> EvKeyDown) Then
   Begin
      DrawCurrent;
   End;


end;










End.