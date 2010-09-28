{$I Compile.INC}
{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

unit Nastr;

Interface

Uses Dialogs,Drivers,ServStr,MyCalc,Access4,Access1;

Type
  PNastrWindow = ^TNastrWindow;
  TNastrWindow = object(TDialog)
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done; virtual;
  end;

Type POperatorWindow = ^TOperatorWindow;
     TOperatorWindow = object(TDialog)
     constructor Init(Var l: Boolean);
     procedure OpenOperatorWindow;
     procedure HandleEvent(var Event: TEvent); virtual;
    End;


Type
  PKassaWindow = ^TKassaWindow;
  TKassaWindow = object(TDialog)
    Calc     : PMyCalculator;
    Procedure Start(Mode:Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done; virtual;
  end;

Type
  PBarterItogWindow = ^TBarterItogWindow;
  TBarterItogWindow = object(TDialog)
   Calc        : PMyCalculator;
    Procedure OpenViewBarterItog;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done; virtual;
  end;



Type
  PItogWindow = ^TItogWindow;
  TItogWindow = object(TDialog)
   Calc        : PMyCalculator;
            KW : PKassaWindow;
    Procedure OpenViewItog;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done; virtual;
  end;



Procedure NastrMarket;
Procedure Registr;
{Procedure TestPC;}
Procedure CloseDate(i:Integer);
Procedure ChangeRekwiziti;
Procedure InputToSklad;
{Procedure ViewItog;}
Function  TestOplataClientFile(St : TDateString):Boolean;
Procedure SetupMarketDoc(j:byte);
Function TestPrihod(s:TDateString):Boolean;
Function TestNewVozwrat(s:TDateString):Boolean;
Function OpenRegistrWindow(Var s : TDateString):Boolean;

{Procedure SelectVidDoc;}

Var FZRazdel,TChekRAzdel,SpisokRazdel,SFRazdel,SFBRazdel,DebitRazdel,
    DebitRazdel_SN,DebitSfRazdel,DebitSfBRazdel : PBox;

Implementation


uses Objects, Views, MsgBox,Vision3,Validate,Access,DBEngine,TPDate,Vision1,Vision4,Vision2,
     App, Serv, Glob,ColorTxt,Protect,Prihod,Return,NetDbEng,Printers,Net,Utils,UtilsP;



var
 ControlClients,
 ControlDSertif,
 ControlLizensia,
 ControlReal,
 ControlSelect,
 ControlOperator,
 ControlRP,ControlNumer,
 ControlPrihodMax : PView;
 NastrWin : PNastrWindow;
 OperatorWin : POperatorWindow;
 Previos : string[45];
 Itog : PItogWindow;
 Kassa : PKAssaType;
 KassaWindow : PKassaWindow;
 ShowKassa:Boolean;
 KassaDate : TDateString;
 BarterItog : PBarterItogWindow;
 NoInputBarterPrhRZ,NoInputBarterPrhKolRZ,BarterPrhKolRZ,BarterKol,BarterPrhKol : AllStr;
 KassaH : PHiddenKassaType;


{$IFNDEF Kurz}

Function TestPrihod(s:TDateString):Boolean;
Var PrihodFile : PrihodFileType;
    E : PPrihodType;
    c : Word;
    Find : Boolean;
Begin
 TestPrihod:=True;
 Assign(PrihodFile,Path.ToPrihod+s+'.prh');
 c:=IOResult;
 Reset(PrihodFile);
 c:=IOResult;
 If c=0 Then
  Begin
   New(E,Init);
   Find:=False;
   While Not(Eof(PrihodFile)) And Not(Find) Do
    Begin
     {
     Repeat
     Until NetCall.Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType));
     }
     ReadPrihod(PrihodFile,E);
     {
     Repeat
      NetCall.UnLock(PrihodFile,(FilePos(PrihodFile)-1)*SizeOf(PrihodType),SizeOf(PrihodType));
     Until (DosError=0);
     }
     If E^.Dat.StatusDoc=1 Then Find:=True;
    End;
   Close(PrihodFile);
   If Find Then
    Begin
     TestPrihod:=False;
     MessageBox(#3'В буфере ПРИХОДА обнаружен документ N'+E^.Dat.Document+^M
     +#3'Не могу закрыть день пока Вы не введете его на склад!',Nil,mfError+mfCancelButton);
    End;
   Dispose(E,Done);
  End
  Else
   Begin
     MessageBox(^M+#3'Файл прихода за '+S+' не найден!'+^M
     +#3'Не могу проверить буфер ПРИХОДА!',Nil,mfWarning+mfCancelButton);
   End;
End;





Function TestNewVozwrat(s:TDateString):Boolean;
Var VozwratFile : NewVozwratFileType;
    E : PNewVozwratType;
    c : Word;
    Find : Boolean;
Begin
 TestNewVozwrat:=True;
 Assign(VozwratFile,Path.ToReturn+s+'.vzw');
 c:=IOResult;
 Reset(VozwratFile);
 c:=IOResult;
 If c=0 Then
  Begin
   New(E,Init);
   Find:=False;
   While Not(Eof(VozwratFile)) And Not(Find) Do
    Begin
     {
     Repeat
     Until NetCall.Lock(VozwratFile,FilePos(VozwratFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     }
     ReadNewVozwrat(VozwratFile,E);
     {
     Repeat
      NetCall.UnLock(VozwratFile,(FilePos(VozwratFile)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     }
     If E^.Dat.StatusDoc=1 Then Find:=True;
    End;
   Close(VozwratFile);
   If Find Then
    Begin
     TestNewVozwrat:=False;
     MessageBox(#3'В буфере ВОЗВРАТА обнаружен документ N'+E^.Dat.Document+^M
     +#3'Не могу закрыть день пока Вы не введете его на склад!',Nil,mfError+mfCancelButton);
    End;
   Dispose(E,Done);
  End
  Else
   Begin
     MessageBox(^M+#3'Файл возврата за '+S+' не найден!'+^M
     +#3'Не могу проверить буфер ВОЗВРАТА!',Nil,mfWarning+mfCancelButton);
   End;
End;

{$ELSE}
Function TestNewVozwrat(s:TDateString):Boolean;
Begin
End;

Function TestPrihod(s:TDateString):Boolean;
Begin
End;

{$ENDIF}




Function OpenRegistrWindow(Var s : TDateString):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
ClearFind;
OpenRegistrWindow:=False;
R.Assign(21, 6, 59, 17);
New(Dlg, Init(R, 'Идентификация оператора'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;

R.Assign(35, 2, 36, 10);
Control := New(PScrollBar, Init(R));
Dlg^.Insert(Control);

R.Assign(2, 2, 35, 10);
Operator := New(PBox, Init(R, 2, PScrollBar(Control)));
Operator^.NewList(New(PTextCollection, Init(1,1)));
Assign (OperatorFile,Path.ToOperator+'system.db');
c:=IOResult;
Reset (OperatorFile);
If IOResult=0 Then
Begin
While Not(Eof(OperatorFile)) Do
 Begin
  Read(OperatorFile,OperatorElement);
  If OperatorElement.Employ Then
   Begin
    Format (OperatorElement.Name,CKto);
    Operator^.List^.Insert(NewStr(OperatorElement.Name+'│'+OperatorElement.Kod));
    Operator^.SetRange(Operator^.List^.Count);
   End;
 End;
System.Close(OperatorFile);
Operator^.FocusItem(0);
Operator^.HelpCtx:=$E241;
Dlg^.Insert(Operator);
End
Else
 Begin
  Dispose(Operator,Done);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  Exit;
 End;
  R.Assign(2, 1, 36, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Оператор     Код Оператор     Код', Operator)));
{
  R.Assign(2, 1, 36, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Оператор     Код Оператор     Код', Control)));}
  Dlg^.SelectNext(False);

  c:=Desktop^.ExecView(dlg);
  If c=cmOk Then OpenRegistrWindow:=True;
  s:=Copy(Operator^.GetText(Operator^.Focused,Operator^.List^.Count),1+CKto+1,CRazdelKod);

  Dispose(Operator,Done);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
End;


Function IdentifPassword (s : TDateString):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  ww,st : String[CInputILitr];
  c : WOrd;


begin
ClearFind;
IdentifPassword:=False;
R.Assign(28, 10, 63, 16);
New(Dlg, Init(R, 'Оператор:'+GetOperatorName(s)+'['+s+']'));
Dlg^.HelpCtx:=$E241;

R.Assign(13, 4, 25, 5);
Control := New(PSInputLine, Init(R, 10));
Dlg^.Options:=Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Insert(Control);

  R.Assign(4, 4, 13, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Пароль:', Control)));

R.Assign(1, 2, 34, 3);
Control := New(PColoredText, Init(R, #3+'"'+DayString[DayOfWeek(ToDay)]+'" '+FDate, $BE));
Dlg^.Insert(Control);


Dlg^.SelectNext(False);
st[0]:=#0;
Dlg^.SetData(St);
c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
   Begin
    Dlg^.GetData(St);
    St:=Upcases(St);
    ww:=Decode(GetOperatorPassword(s));
    If ww=St Then
                 IdentifPassword:=True
    Else
                 IdentifPassword:=False;
   End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;



Function TDate:Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  st : TDateString;
  c : Word;
  l : Longint;
begin
TDate := True;
1:
R.Assign(30, 8, 49, 14);
New(Dlg, Init(R, ''));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;

R.Assign(5, 3, 15, 4);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

R.Assign(1, 1, 18, 2);
Control := New(PColoredText, Init(R, 'Введите дату ОС', $BE));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.HelpCtx:=$E002;
c:=Desktop^.ExecView(dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(St);
  Dispose(Control,Done);
  Dispose(Dlg,Done);

  DelSpace(St);

  If st[0]=#0 Then Goto 1;

   If Not(TestDate(st,L)) Then
    Begin
     MessageBox(^M+#3'Указанная дата не существует!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

  If Not FindParam('/NODATECONTROL') Then
  Begin
  If St<>FDate Then
   Begin
    TDate := False;
    AddProtocol('Ошибка при указании даты ОС','','');
    MessageBox(#3^M+#3'Немедленно позовите программиста!',Nil,mfWarning+mfCancelButton);
    Application^.Done;
    Halt;
   End;
  End
  Else
    Begin
     FDate:=St;
     AddProtocol('Внимание! Отключен контроль даты ОС','','');
    End;
 End
 Else
 Begin
  AddProtocol('Отказ от указания даты ОС','','');
  TDate := False;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  Application^.Done;
  Halt;
 End;
End;



(*
Function TTime:Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  st : TDateString;
  c : Word;
begin
TTime := True;
R.Assign(27, 9, 53, 14);
New(Dlg, Init(R, 'Вы согласны ?'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Flags := Dlg^.Flags and not wfClose;

R.Assign(1, 2, 25, 3);
Control := New(PColoredText, Init(R, 'Текущее время:'+Times, $9E));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);

Dlg^.HelpCtx:=$E241;

c:=Desktop^.ExecView(dlg);
If c<>cmCancel Then
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  TTime:=True;
 End
 Else
 Begin
  TTime := False;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  Application^.Done;
  Halt;
 End;
End;
*)


Procedure Registr;
Var st:TDateString;
    Event : TEvent;
Begin

If FindParam('/SOYZ') Then
Begin
  CurrentPassword:='00';
  AddProtocol('Вход в систему нового оператора !','','');
  Exit;
End;

TDate;
TTime;
If OpenRegistrWindow( st ) Then
 Begin
 If Not(IdentifPassword (st)) Then
    Begin
     Wzlom:=True;
     CurrentPassword:=St;
     AddProtocol('Попытка несанкционированного доступа  !!!','','');
     SpecialBeep;
     MessageBox(#3^M+#3+'Попытка несанкционированного доступа!',Nil,mfWarning+mfCancelButton);
     Event.What:=evCommand;
     Event.Command:=cmQuit;
     Application^.PutEvent(Event);
     Application^.ClearEvent(Event);
    End
 Else
  Begin
  CurrentPassword:=st;
  AddProtocol('Вход в систему нового оператора !','','');
  End;
 End
 Else
  Begin
     Wzlom:=True;
     Event.What:=evCommand;
     Event.Command:=cmQuit;
     Application^.PutEvent(Event);
     Application^.ClearEvent(Event);
  End;

{  CurrentPassword:='00';}

End;

(*
Procedure NastrMarket;
var
  R : TRect;
  c: LongInt;
  Control : PView;
  s : String[1+CRazdel+1+CRazdelKod];
  k,MMMS : Word;
  Prihodnik : String[CZena];
  mm : Maska9;
begin
AInfo('Читаю конфигурацию...');
R.Assign(0, 0, 80, 23);
New(NastrWin, Init(R, 'Настройка системы продажи'));
NastrWin^.Options := NastrWin^.Options or ofCenterX or ofCenterY;
NastrWin^.HelpCtx:=$E002;


R.Assign(51, 2, 52, 8);
Control := New(PScrollBar, Init(R));
NastrWin^.Insert(Control);

R.Assign(2, 2, 51, 8);
Razdel := New(PBox, Init(R, 2, PScrollBar(Control)));
Razdel^.NewList(New(PTextCollection, Init(1,1)));
Razdel^.Options := Razdel^.Options or ofFramed;
Assign (RazdelFile,Path.ToRazdel+'razdel.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
   Begin
    Format (RazdelElement.Name,CClient);
    Razdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    Razdel^.SetRange(Razdel^.List^.Count);
   End;
 End;
System.Close(RazdelFile);
Razdel^.FocusItem(0);
Razdel^.HelpCtx:=$E160;
NastrWin^.Insert(Razdel);

  R.Assign(2, 1, 52, 2);
  NastrWin^.Insert(New(PLabel, Init(R, '~Р~аздел               Код Раздел               Код', Razdel)));


R.Assign(26, 10, 27, 21);
Control := New(PScrollBar, Init(R));
NastrWin^.Insert(Control);

R.Assign(2, 10, 26, 21);
TChekRazdel := New(PBox, Init(R, 1, PScrollBar(Control)));
TChekRazdel^.NewList(New(PTextCollection, Init(1,1)));
TChekRazdel^.Options := TChekRAzdel^.Options or ofFramed;
Assign (RazdelFile,Path.ToRazdel+'zaprth!.db');
c:=IOResult;
Reset (RazdelFile);
c:=IoResult;
If c = 0 Then
Begin
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
    Format (RazdelElement.Name,CClient);
    TChekRazdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    TChekRazdel^.SetRange(TChekRazdel^.List^.Count);
 End;
System.Close(RazdelFile);
End;
TChekRazdel^.FocusItem(0);
TChekRazdel^.HelpCtx:=$E042;
NastrWin^.Insert(TChekRazdel);

  R.Assign(2, 9, 15, 10);
  NastrWin^.Insert(New(PLabel, Init(R, 'Запрет на Т~Ч~', TChekRazdel)));



R.Assign(52, 10, 53, 21);
Control := New(PScrollBar, Init(R));
NastrWin^.Insert(Control);

R.Assign(28, 10, 52, 21);
FZRazdel := New(PBox, Init(R, 1, PScrollBar(Control)));
FZRazdel^.NewList(New(PTextCollection, Init(1,1)));
FZRazdel^.Options := FZRAzdel^.Options or ofFramed;
Assign (RazdelFile,Path.ToRazdel+'zaprfl!.db');
c:=IOResult;
Reset (RazdelFile);
c:=IoResult;
If c = 0 Then
Begin
While Not(Eof(RazdelFile)) Do
 Begin
    Read(RazdelFile,RazdelElement);
    Format (RazdelElement.Name,CClient);
    FZRazdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    FZRazdel^.SetRange(FZRazdel^.List^.Count);
 End;
System.Close(RazdelFile);
End;
FZRazdel^.FocusItem(0);
FZRazdel^.HelpCtx:=$E042;
NastrWin^.Insert(FZRazdel);

    R.Assign(28, 9, 48, 10);
  NastrWin^.Insert(New(PLabel, Init(R, 'Запрет на Физ.Ли~ц~о.', FZRazdel)));

R.Assign(55, 2, 77, 8);
ControlSelect := New(PRadioButtons, Init(R,
  NewSItem('Спис~о~к',
  NewSItem('~Т~ Чек',
  NewSItem('Физ.~Л~.',
  NewSItem('С/~Ф~',
  NewSItem('С/Ф Б',
  NewSItem('~Д~ебит',
  Nil))))))));
ControlSelect^.Options := ControlSelect^.Options or ofFramed;
WordToBit6(MasDocNumer,MM);
For c:=1 To 7 Do
If Mm[c]=1 Then Mm[c]:=0
Else Mm[c]:=1;

{
For c:=1 To 7 Do
If MM[c]=1 Then MM[c]:=0
Else MM[c]:=1;
   k:=1;
For c:=7 Downto 1 Do
   Begin
    mm[k]:=masDoc[c];
    inc(k);
   End;
{

mm[2]:=0;
}


BitToWord9(MM,MMMS);

PCluster(ControlSelect)^.SetButtonState(MMMS, False);
NastrWin^.Insert(ControlSelect);

  R.Assign(55, 1, 77, 2);
  NastrWin^.Insert(New(PLabel, Init(R, '~П~родажа по умолчанию:', ControlSelect)));
ControlSelect^.SetData(DefaultDoc);

R.Assign(56, 10, 74, 12);
ControlReal := New(PRadioButtons, Init(R,
  NewSItem('Открытые',
  NewSItem('Закрытые',
  Nil))));
ControlReal^.Options := ControlReal^.Options or ofFramed;
NastrWin^.Insert(ControlReal);

  R.Assign(56, 9, 74, 10);
  NastrWin^.Insert(New(PLabel, Init(R, 'Показ~ы~вать долги:', ControlReal)));

ControlReal^.SetData(DefaultReal);


R.Assign(55, 14, 76, 15);
ControlLizensia := New(PCheckboxes, Init(R,
  NewSItem('~С~рок лицензии', Nil)));
ControlLizensia^.Options := ControlLizensia^.Options or ofFramed;
NastrWin^.Insert(ControlLizensia);

ControlLizensia^.SetData(DefaultLizensia);

  R.Assign(55, 13, 65, 14);
  NastrWin^.Insert(New(PLabel, Init(R, 'Контроль:', ControlLizensia)));


R.Assign(54, 17, 78, 18);
ControlClients := New(PCheckboxes, Init(R,
  NewSItem('~П~оказать при выборе', Nil)));
ControlClients^.Options := ControlClients^.Options or ofFramed;
NastrWin^.Insert(ControlClients);

ControlClients^.SetData(ShowClients);

  R.Assign(54, 16, 75, 17);
  NastrWin^.Insert(New(PLabel, Init(R, 'Сообщение о клиенте:', ControlClients)));

R.Assign(72, 19, 78, 20);
ControlRP := New(PInputLine, Init(R, 4));
NastrWin^.Insert(ControlRP);
  PInputLine(ControlRP)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

ControlRP^.SetData(ClientRP);

  R.Assign(55, 19, 72, 20);
  NastrWin^.Insert(New(PLabel, Init(R, '~К~од клиента Р/П:', ControlRP)));


R.Assign(68, 20, 78, 21);
ControlPrihodMax := New(PInputLine, Init(R, 10));
NastrWin^.Insert(ControlPrihodMax);
  PInputLine(ControlPrihodMax)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

Prihodnik:=RealToSTr(PrihodMax,CZena,CMantissa);
DelSpace(Prihodnik);

ControlPrihodMax^.SetData(Prihodnik);


  R.Assign(54, 20, 68, 21);
  NastrWin^.Insert(New(PLabel, Init(R, '~М~аксимум ПКО:', ControlPrihodMax)));


NastrWin^.SelectNext(False);

NoInfo;
C := Desktop^.ExecView(NastrWin);
If C <> cmCancel Then
 Begin
  Dispose(Control,Done);
  Dispose(Razdel,Done);

  If TChekRazdel^.List^.Count>=0 Then
  Begin
  Assign (RazdelFile,Path.ToRazdel+'zaprth!.db');
  Rewrite (RazdelFile);
  For c:=0 To TChekRazdel^.List^.Count-1 Do
   Begin
    s:=TChekRazdel^.GetText(c,TChekRazdel^.List^.Count);
    RazdelElement.Name:=Copy(s,1,CRazdel);
    RazdelElement.Kod:=Copy(s,1+CRazdel+1,CRazdelKod);
    Seek(RazdelFile,FileSize(RazdelFile));
    Write(RazdelFile,RazdelElement);
   End;
   Close(RazdelFile);
   End;
  Dispose(TChekRazdel,Done);

  If FZRazdel^.List^.Count>=0 Then
  Begin
  Assign (RazdelFile,Path.ToRazdel+'zaprfl!.db');
  Rewrite (RazdelFile);
  For c:=0 To FZRazdel^.List^.Count-1 Do
   Begin
    s:=FZRazdel^.GetText(c,FZRazdel^.List^.Count);
    RazdelElement.Name:=Copy(s,1,CRazdel);
    RazdelElement.Kod:=Copy(s,1+CRazdel+1,CRazdelKod);
    Seek(RazdelFile,FileSize(RazdelFile));
    Write(RazdelFile,RazdelElement);
   End;
   Close(RazdelFile);
  End;
  Dispose(FZRazdel,Done);
  ControlSelect^.GetData(DefaultDoc);
  ControlReal^.GetData(DefaultReal);
  ControlLizensia^.GetData(DefaultLizensia);
  ControlClients^.GetData(ShowClients);
  ControlRP^.GetData(ClientRP);
  Str(StrToInt(ClientRP):CClientKod,ClientRp);
  DelSPace(CLientRP);
  RFormatZerro(CLientRP,CClientKod);

  ControlPrihodMax^.GetData(Prihodnik);
  DelSpace(Prihodnik);
  PrihodMax:=StrToReal(Prihodnik);

  Dispose(ControlSelect,Done);
  Dispose(ControlLizensia,Done);
  Dispose(ControlClients,Done);
  Dispose(ControlRp,Done);
  Dispose(ControlPrihodMax,Done);

  Dispose(NastrWin,Done);
  AddProtocol('Корректировка настройки продаж !!! {Очень важно}');
         c:=0;
         WriteNewIni(c);
         If c<> 0 Then Errors('Ошибка записи файла конфигурации !');

 End
 Else
  Begin
  Dispose(Control,Done);
  Dispose(Razdel,Done);
  Dispose(TChekRazdel,Done);
  Dispose(FZRazdel,Done);
  Dispose(ControlSelect,Done);
  Dispose(ControlReal,Done);
  Dispose(ControlLizensia,Done);
  Dispose(ControlClients,Done);
  Dispose(ControlPrihodMax,Done);

  Dispose(NastrWin,Done);

  End;
End;


Destructor TNastrWindow.Done;
Begin
TDialog.Done;
End;



procedure TNastrWindow.HandleEvent(var Event: TEvent);
Var s : String[CRazdel+1+CRazdelKod];
    ls : Word;
Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
  kbCtrLDel: Begin
     If (TChekRazdel^.State and sfFocused <> 0) And (TChekRazdel^.List<>Nil)And(TChekRazdel^.List^.Count>=1) Then
            Begin
             TChekRazdel^.NewList(nil);
             TChekRazdel^.NewList(New(PTextCollection, Init(1,1)));
            End;
     If (FZRazdel^.State and sfFocused <> 0) And (FZRazdel^.List<>Nil)And(FZRazdel^.List^.Count>=1) Then
            Begin
             FZRazdel^.NewList(nil);
             FZRazdel^.NewList(New(PTextCollection, Init(1,1)));
            End;
             Redraw;
            End;
     kbDel: Begin
     If (TChekRazdel^.State and sfFocused <> 0) And (TChekRazdel^.List<>Nil)And(TChekRazdel^.List^.Count>=1) Then
            Begin
             TChekRazdel^.List^.AtFree(TChekRazdel^.Focused);
             TChekRazdel^.SetRange(TChekRazdel^.List^.Count);
             If TChekRazdel^.Focused>0 Then
             TChekRazdel^.FocusItem(TChekRazdel^.Focused);
             If (TChekRazdel^.Focused>=TChekRazdel^.List^.Count) and(TChekRAzdel^.Focused>0) Then
             TChekRazdel^.FocusItem(TChekRazdel^.Focused-1);

            ClearEvent(Event);
            End;
              Redraw;
     If (FZRazdel^.State and sfFocused <> 0) And (FZRazdel^.List<>Nil)And(FZRazdel^.List^.Count>=1) Then
            Begin
             FZRazdel^.List^.AtFree(FZRazdel^.Focused);
             FZRazdel^.SetRange(FZRazdel^.List^.Count);
             If FZRazdel^.Focused>0 Then
             FZRazdel^.FocusItem(FZRazdel^.Focused);
             If (FZRazdel^.Focused>=FZRazdel^.List^.Count) and(FZRAzdel^.Focused>0) Then
             FZRazdel^.FocusItem(FZRazdel^.Focused-1);
            ClearEvent(Event);
            End;
              Redraw;
            End;
 kbGrayPlus: Begin
            If(Razdel^.State and sfFocused <> 0) And (Razdel^.Focused<Razdel^.List^.Count) Then
            Begin
               s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.COunt);
              If TestElement(Copy(s,1+CRazdel+1,CRazdelKod),TChekRazdel) Then
               Begin
               TChekRazdel^.List^.Insert(NewStr(s));
               TChekRazdel^.SetRange(TChekRazdel^.List^.Count);
               s:=Copy(s,1+CRazdel+1,CRazdelKod);
               TChekRazdel^.FocusItem(LoCation(TChekRazdel,S,ProdagaWindow));
               If TChekRazdel^.Focused+1<TChekRazdel^.List^.Count Then
               TChekRazdel^.FocusItem(TChekRazdel^.List^.Count-1);
               End;
               If (Razdel^.Focused+1) <  Razdel^.List^.Count Then
               Razdel^.FocusItem(Razdel^.Focused+1);
              End;
              ClearEvent(Event);
              Redraw;
            End;
{
kbEnter  : Begin
            If(ControlRP^.State and sfFocused <> 0)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmOk;
             PutEvent(Event);
             ClearEvent(Event);
            End;
            End;
}
kbGrayMinus: Begin
            If(Razdel^.State and sfFocused <> 0) And (Razdel^.Focused<Razdel^.List^.Count) Then
            Begin
               s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.COunt);
               If TestElement(Copy(s,1+CRazdel+1,CRazdelKod),FZRazdel) Then
               Begin
               FZRazdel^.List^.Insert(NewStr(s));
               FZRazdel^.SetRange(FZRazdel^.List^.Count);
               s:=Copy(s,1+CRazdel+1,CRazdelKod);
               FZRazdel^.FocusItem(LoCation(FZRazdel,S,ProdagaWindow));
               If FZRazdel^.Focused+1<FZRazdel^.List^.Count Then
               FZRazdel^.FocusItem(FZRazdel^.List^.Count-1);
               End;
               If (Razdel^.Focused+1) <  Razdel^.List^.Count Then
               Razdel^.FocusItem(Razdel^.Focused+1);
            End;
              ClearEvent(Event);
              Redraw;
            End;
    Else;
    End;
    Else;
    End;
  inherited HandleEvent(Event);
End;
*)
Procedure NastrMarket;
var
  R : TRect;
  c: LongInt;
  Control : PView;
  s : String[1+CRazdel+1+CRazdelKod];
  k,MMMS : Word;
  Prihodnik : String[CZena];
  mm : Maska9;
begin
AInfo('Читаю конфигурацию...');
R.Assign(0, 0, 80, 23);
New(NastrWin, Init(R, 'Настройка системы продажи'));
NastrWin^.Options := NastrWin^.Options or ofCenterX or ofCenterY;
NastrWin^.HelpCtx:=$E002;


R.Assign(50, 1, 51, 5);
Control := New(PScrollBar, Init(R));
NastrWin^.Insert(Control);

R.Assign(1, 1, 50, 5);
Razdel := New(PBox, Init(R, 2, PScrollBar(Control)));
Razdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path.ToRazdel+'razdel.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
   Begin
    Format (RazdelElement.Name,CClient);
    Razdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    Razdel^.SetRange(Razdel^.List^.Count);
   End;
 End;
System.Close(RazdelFile);
Razdel^.FocusItem(0);
Razdel^.HelpCtx:=$E160;
NastrWin^.Insert(Razdel);

  R.Assign(1, 0, 25, 1);
  NastrWin^.Insert(New(PLabel, Init(R, '~Р~аздел              Код', Razdel)));

R.Assign(77, 1, 78, 5);
Control := New(PScrollBar, Init(R));
NastrWin^.Insert(Control);

R.Assign(53, 1, 77, 5);
SpisokRazdel := New(PBox, Init(R, 1, PScrollBar(Control)));
SpisokRazdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprsp.db');
c:=IOResult;
Reset (RazdelFile);
c:=IoResult;
If c = 0 Then
Begin
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
    Format (RazdelElement.Name,CClient);
    SpisokRazdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    SpisokRazdel^.SetRange(SpisokRazdel^.List^.Count);
 End;
System.Close(RazdelFile);
End;
SpisokRazdel^.FocusItem(0);
SpisokRazdel^.HelpCtx:=$E042;
NastrWin^.Insert(SpisokRazdel);

  R.Assign(53, 0, 70, 1);
  NastrWin^.Insert(New(PLabel, Init(R, 'Запрет на ~С~писок', SpisokRazdel)));

{вставляем полосу прокрутки}
R.Assign(25, 6, 26, 10);
Control := New(PScrollBar, Init(R));
NastrWin^.Insert(Control);
{формируем список}
R.Assign(1, 6, 25, 10);
TChekRazdel := New(PBox, Init(R, 1, PScrollBar(Control)));
TChekRazdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprth!.db');
c:=IOResult;
Reset (RazdelFile);
c:=IoResult;
If c = 0 Then
Begin
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
    Format (RazdelElement.Name,CClient);
    TChekRazdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    TChekRazdel^.SetRange(TChekRazdel^.List^.Count);
 End;
System.Close(RazdelFile);
End;
TChekRazdel^.FocusItem(0);
TChekRazdel^.HelpCtx:=$E042;
NastrWin^.Insert(TChekRazdel);

{делаем заголовок}
  R.Assign(1, 5, 15, 6);
  NastrWin^.Insert(New(PLabel, Init(R, 'Запрет на Т~Ч~', TChekRazdel)));

R.Assign(51, 6, 52, 10);
Control := New(PScrollBar, Init(R));
NastrWin^.Insert(Control);

R.Assign(27, 6, 51, 10);
FZRazdel := New(PBox, Init(R, 1, PScrollBar(Control)));
FZRazdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprfl!.db');
c:=IOResult;
Reset (RazdelFile);
c:=IoResult;
If c = 0 Then
Begin
While Not(Eof(RazdelFile)) Do
 Begin
    Read(RazdelFile,RazdelElement);
    Format (RazdelElement.Name,CClient);
    FZRazdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    FZRazdel^.SetRange(FZRazdel^.List^.Count);
 End;
System.Close(RazdelFile);
End;
FZRazdel^.FocusItem(0);
FZRazdel^.HelpCtx:=$E042;
NastrWin^.Insert(FZRazdel);

  R.Assign(27, 5, 46, 6);
  NastrWin^.Insert(New(PLabel, Init(R, 'Запрет на Ф.Ли~ц~о*', FZRazdel)));

{вставляем полосу прокрутки}
R.Assign(77, 6, 78, 10);
Control := New(PScrollBar, Init(R));
NastrWin^.Insert(Control);
{формируем список}
R.Assign(53, 6, 77, 10);
SFRazdel := New(PBox, Init(R, 1, PScrollBar(Control)));
SFRazdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprsf!.db');
c:=IOResult;
Reset (RazdelFile);
c:=IoResult;
If c = 0 Then
Begin
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
    Format (RazdelElement.Name,CClient);
    SFRazdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    SFRazdel^.SetRange(SFRazdel^.List^.Count);
 End;
System.Close(RazdelFile);
End;
SFRazdel^.FocusItem(0);
SFRazdel^.HelpCtx:=$E042;
NastrWin^.Insert(SFRazdel);
{делаем заголовок}
  R.Assign(53, 5, 67, 6);
  NastrWin^.Insert(New(PLabel, Init(R, 'Запрет на С~Ф~*', SFRazdel)));


{вставляем полосу прокрутки}
R.Assign(25, 11, 26, 14);
Control := New(PScrollBar, Init(R));
NastrWin^.Insert(Control);
{формируем список}
R.Assign(1, 11, 25, 14);
SfbRAzdel := New(PBox, Init(R, 1, PScrollBar(Control)));
SfbRAzdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprsb.db');
c:=IOResult;
Reset (RazdelFile);
c:=IoResult;
If c = 0 Then
Begin
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
    Format (RazdelElement.Name,CClient);
    SfbRAzdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    SfbRAzdel^.SetRange(SfbRAzdel^.List^.Count);
 End;
System.Close(RazdelFile);
End;
SfbRAzdel^.FocusItem(0);
SfbRAzdel^.HelpCtx:=$E042;
NastrWin^.Insert(SfbRAzdel);
{делаем заголовок}
  R.Assign(1, 10, 17, 11);
  NastrWin^.Insert(New(PLabel, Init(R, '~З~апрет на СФ Б', SfbRAzdel)));

{вставляем полосу прокрутки}
R.Assign(51, 11, 52, 14);
Control := New(PScrollBar, Init(R));
NastrWin^.Insert(Control);
{формируем список}
R.Assign(27, 11, 51, 14);
DebitRAzdel := New(PBox, Init(R, 1, PScrollBar(Control)));
DebitRAzdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprd!.db');
c:=IOResult;
Reset (RazdelFile);
c:=IoResult;
If c = 0 Then
Begin
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
    Format (RazdelElement.Name,CClient);
    DebitRAzdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    DebitRAzdel^.SetRange(DebitRAzdel^.List^.Count);
 End;
System.Close(RazdelFile);
End;
DebitRAzdel^.FocusItem(0);
DebitRAzdel^.HelpCtx:=$E042;
NastrWin^.Insert(DebitRAzdel);
{делаем заголовок}
  R.Assign(27, 10, 45, 11);
  NastrWin^.Insert(New(PLabel, Init(R, 'Запрет на Деби~т~*', DebitRAzdel)));

{вставляем полосу прокрутки}
R.Assign(77, 11, 78, 14);
Control := New(PScrollBar, Init(R));
NastrWin^.Insert(Control);

{формируем список}
R.Assign(53, 11, 77, 14);
DebitSFRazdel := New(PBox, Init(R, 1, PScrollBar(Control)));
DebitSFRazdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprdsf!.db');
c:=IOResult;
Reset (RazdelFile);
c:=IoResult;
If c = 0 Then
Begin
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
    Format (RazdelElement.Name,CClient);
    DebitSFRazdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    DebitSFRazdel^.SetRange(DebitSFRazdel^.List^.Count);
 End;
System.Close(RazdelFile);
End;
DebitSFRazdel^.FocusItem(0);
DebitSFRazdel^.HelpCtx:=$E042;
NastrWin^.Insert(DebitSFRazdel);

{делаем заголовок}
  R.Assign(53, 10, 73, 11);
  NastrWin^.Insert(New(PLabel, Init(R, 'Запрет на Деб.СФ*', DebitSFRAzdel)));

{вставляем полосу прокрутки}
R.Assign(25, 15, 26, 18);
Control := New(PScrollBar, Init(R));
NastrWin^.Insert(Control);


{формируем список}
R.Assign(1, 15, 25, 18);
{делаем заголовок}
DebitRazdel_SN := New(PBox, Init(R, 1, PScrollBar(Control)));
DebitRazdel_SN^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprd.db');
c:=IOResult;
Reset (RazdelFile);
c:=IoResult;
If c = 0 Then
Begin
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
    Format (RazdelElement.Name,CClient);
    DebitRazdel_SN^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    DebitRazdel_SN^.SetRange(DebitRazdel_SN^.List^.Count);
 End;
System.Close(RazdelFile);
End;
DebitRazdel_SN^.FocusItem(0);
DebitRazdel_SN^.HelpCtx:=$E042;
NastrWin^.Insert(DebitRazdel_SN);

  R.Assign(1, 14, 18, 15);
  NastrWin^.Insert(New(PLabel, Init(R, 'Запрет Дебит', DebitRAzdel_SN)));


{вставляем полосу прокрутки}

R.Assign(51, 15, 52, 18);
Control := New(PScrollBar, Init(R));
NastrWin^.Insert(Control);


{формируем список}
R.Assign(27, 15, 51, 18);
DebitSFBRazdel := New(PBox, Init(R, 1, PScrollBar(Control)));
DebitSFBRazdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path.ToRazdel+'zaprdsb.db');
c:=IOResult;
Reset (RazdelFile);
c:=IoResult;
If c = 0 Then
Begin
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
    Format (RazdelElement.Name,CClient);
    DebitSFBRazdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    DebitSFBRazdel^.SetRange(DebitSFBRazdel^.List^.Count);
 End;
System.Close(RazdelFile);
End;
DebitSFBRazdel^.FocusItem(0);
DebitSFBRazdel^.HelpCtx:=$E042;
NastrWin^.Insert(DebitSFBRazdel);
{делаем заголовок}
  R.Assign(27, 14, 47, 15);
  NastrWin^.Insert(New(PLabel, Init(R, 'Запрет Дебит СФБ', DebitSFBRazdel)));

R.Assign(1, 19, 35, 22);
ControlSelect := New(PRadioButtons, Init(R,
  NewSItem('Сп',
  NewSItem('ТЧ',
  NewSItem('ФЛ*',
  NewSItem('СФ*',
  NewSItem('СФ Б',
  NewSItem('Д*',
  NewSItem('Д СФ*',
  NewSItem('Д',
  NewSItem('Д СФБ', Nil)))))))))));

WordToBit9(MasDocNumer,MM);
For c:=1 To Max9 Do
If Mm[c]=1 Then Mm[c]:=0
Else Mm[c]:=1;

{
For c:=1 To Max9 Do
If MM[c]=1 Then MM[c]:=0
Else MM[c]:=1;
   k:=1;
For c:=Max9 Downto 1 Do
   Begin
    mm[k]:=masDoc[c];
    inc(k);
   End;
{

mm[2]:=0;
}


BitToWord9(MM,MMMS);

PCluster(ControlSelect)^.SetButtonState(MMMS, False);
NastrWin^.Insert(ControlSelect);

  R.Assign(1, 18, 23, 19);
  NastrWin^.Insert(New(PLabel, Init(R, 'Продажа по ~у~молчанию:', ControlSelect)));
ControlSelect^.SetData(DefaultDoc);

R.Assign(36, 19, 50, 21);
ControlReal := New(PRadioButtons, Init(R,
  NewSItem('Откр~ы~тые',
  NewSItem('Закрыты~е~',
  Nil))));
NastrWin^.Insert(ControlReal);

  R.Assign(36, 18, 43, 19);
  NastrWin^.Insert(New(PLabel, Init(R, 'Долги:', ControlReal)));

ControlReal^.SetData(DefaultReal);


R.Assign(52, 17, 59, 18);
Control := New(PColoredText, Init(R, 'Сервис:', $70));
NastrWin^.Insert(Control);


R.Assign(52, 18, 79, 19);
ControlNumer := New(PCheckboxes, Init(R,
  NewSItem('Предупр. об ~и~зм.номера', Nil)));
NastrWin^.Insert(ControlNumer);

ControlNumer^.SetData(ShowNumer);

R.Assign(52, 19, 79, 20);
ControlLizensia := New(PCheckboxes, Init(R,
  NewSItem('Контроль ср~о~к лицензии', Nil)));

NastrWin^.Insert(ControlLizensia);

ControlLizensia^.SetData(DefaultLizensia);


R.Assign(52, 20, 79, 21);
ControlClients := New(PCheckboxes, Init(R,
  NewSItem('~П~оказ при выборе сообщ.', Nil)));
NastrWin^.Insert(ControlClients);
ControlClients^.SetData(ShowClients);

R.Assign(52, 21, 79, 22);
ControlDSertif := New(PCheckboxes, Init(R,
  NewSItem('Контроль ср.дейст.серт.', Nil)));
NastrWin^.Insert(ControlDSertif);
ControlDSertif^.SetData(ShowSertif);


R.Assign(44, 22, 50, 23);
ControlRP := New(PInputLine, Init(R, 4));
NastrWin^.Insert(ControlRP);
  PInputLine(ControlRP)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

ControlRP^.SetData(ClientRP);

  R.Assign(35, 22, 44, 23);
  NastrWin^.Insert(New(PLabel, Init(R, '~К~од Р/П:', ControlRP)));


R.Assign(65, 22, 75, 23);
ControlPrihodMax := New(PInputLine, Init(R, 10));
NastrWin^.Insert(ControlPrihodMax);
  PInputLine(ControlPrihodMax)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

Prihodnik:=RealToSTr(PrihodMax,CZena,CMantissa);
DelSpace(Prihodnik);

ControlPrihodMax^.SetData(Prihodnik);


  R.Assign(51, 22, 65, 23);
  NastrWin^.Insert(New(PLabel, Init(R, '~М~аксимум ПКО:', ControlPrihodMax)));

R.Assign(72, 0, 77, 1);
Control := New(PColoredText, Init(R, '(N=0)', $75));
NastrWin^.Insert(Control);

R.Assign(20, 5, 25, 6);
Control := New(PColoredText, Init(R, '(N=1)', $75));
NastrWin^.Insert(Control);

R.Assign(46, 5, 51, 6);
Control := New(PColoredText, Init(R, '(N=2)', $75));
NastrWin^.Insert(Control);

R.Assign(72, 5, 77, 6);
Control := New(PColoredText, Init(R, '(N=3)', $75));
NastrWin^.Insert(Control);

R.Assign(20, 10, 25, 11);
Control := New(PColoredText, Init(R, '(N=4)', $75));
NastrWin^.Insert(Control);

R.Assign(46, 10, 51, 11);
Control := New(PColoredText, Init(R, '(N=5)', $75));
NastrWin^.Insert(Control);

R.Assign(72, 10, 77, 11);
Control := New(PColoredText, Init(R, '(N=6)', $75));
NastrWin^.Insert(Control);

R.Assign(20, 14, 25, 15);
Control := New(PColoredText, Init(R, '(N=7)', $75));
NastrWin^.Insert(Control);

R.Assign(46, 14, 51, 15);
Control := New(PColoredText, Init(R, '(N=8)', $75));
NastrWin^.Insert(Control);

NastrWin^.SelectNext(False);

NoInfo;
C := Desktop^.ExecView(NastrWin);
If C <> cmCancel Then
 Begin
  Dispose(Control,Done);
  Dispose(Razdel,Done);

  If SpisokRazdel^.List^.Count>=0 Then
  Begin
  Assign (RazdelFile,Path.ToRazdel+'zaprsp.db');
  Rewrite (RazdelFile);
  For c:=0 To SpisokRazdel^.List^.Count-1 Do
   Begin
    s:=SpisokRazdel^.GetText(c,SpisokRazdel^.List^.Count);
    RazdelElement.Name:=Copy(s,1,CRazdel);
    RazdelElement.Kod:=Copy(s,1+CRazdel+1,CRazdelKod);
    Seek(RazdelFile,FileSize(RazdelFile));
    Write(RazdelFile,RazdelElement);
   End;
   Close(RazdelFile);
   End;
  Dispose(SpisokRazdel,Done);

  If TChekRazdel^.List^.Count>=0 Then
  Begin
  Assign (RazdelFile,Path.ToRazdel+'zaprth!.db');
  Rewrite (RazdelFile);
  For c:=0 To TChekRazdel^.List^.Count-1 Do
   Begin
    s:=TChekRazdel^.GetText(c,TChekRazdel^.List^.Count);
    RazdelElement.Name:=Copy(s,1,CRazdel);
    RazdelElement.Kod:=Copy(s,1+CRazdel+1,CRazdelKod);
    Seek(RazdelFile,FileSize(RazdelFile));
    Write(RazdelFile,RazdelElement);
   End;
   Close(RazdelFile);
   End;
  Dispose(TChekRazdel,Done);

  If FZRazdel^.List^.Count>=0 Then
  Begin
  Assign (RazdelFile,Path.ToRazdel+'zaprfl!.db');
  Rewrite (RazdelFile);
  For c:=0 To FZRazdel^.List^.Count-1 Do
   Begin
    s:=FZRazdel^.GetText(c,FZRazdel^.List^.Count);
    RazdelElement.Name:=Copy(s,1,CRazdel);
    RazdelElement.Kod:=Copy(s,1+CRazdel+1,CRazdelKod);
    Seek(RazdelFile,FileSize(RazdelFile));
    Write(RazdelFile,RazdelElement);
   End;
   Close(RazdelFile);
  End;
  Dispose(FZRazdel,Done);

  If SFRazdel^.List^.Count>=0 Then
  Begin
  Assign (RazdelFile,Path.ToRazdel+'zaprsf!.db');
  Rewrite (RazdelFile);
  For c:=0 To SFRazdel^.List^.Count-1 Do
   Begin
    s:=SFRazdel^.GetText(c,SFRazdel^.List^.Count);
    RazdelElement.Name:=Copy(s,1,CRazdel);
    RazdelElement.Kod:=Copy(s,1+CRazdel+1,CRazdelKod);
    Seek(RazdelFile,FileSize(RazdelFile));
    Write(RazdelFile,RazdelElement);
   End;
   Close(RazdelFile);
   End;
  Dispose(SFRazdel,Done);

  If SFBRazdel^.List^.Count>=0 Then
  Begin
  Assign (RazdelFile,Path.ToRazdel+'zaprsb.db');
  Rewrite (RazdelFile);
  For c:=0 To SFBRazdel^.List^.Count-1 Do
   Begin
    s:=SFBRazdel^.GetText(c,SFBRazdel^.List^.Count);
    RazdelElement.Name:=Copy(s,1,CRazdel);
    RazdelElement.Kod:=Copy(s,1+CRazdel+1,CRazdelKod);
    Seek(RazdelFile,FileSize(RazdelFile));
    Write(RazdelFile,RazdelElement);
   End;
   Close(RazdelFile);
   End;
  Dispose(SFBRazdel,Done);

  If DebitRAzdel^.List^.Count>=0 Then
  Begin
  Assign (RazdelFile,Path.ToRazdel+'zaprd!.db');
  Rewrite (RazdelFile);
  For c:=0 To DebitRAzdel^.List^.Count-1 Do
   Begin
    s:=DebitRAzdel^.GetText(c,DebitRAzdel^.List^.Count);
    RazdelElement.Name:=Copy(s,1,CRazdel);
    RazdelElement.Kod:=Copy(s,1+CRazdel+1,CRazdelKod);
    Seek(RazdelFile,FileSize(RazdelFile));
    Write(RazdelFile,RazdelElement);
   End;
   Close(RazdelFile);
   End;
  Dispose(DebitRAzdel,Done);


  If DebitRazdel_Sn^.List^.Count>=0 Then
  Begin
  Assign (RazdelFile,Path.ToRazdel+'zaprd.db');
  Rewrite (RazdelFile);
  For c:=0 To DebitRazdel_Sn^.List^.Count-1 Do
   Begin
    s:=DebitRazdel_Sn^.GetText(c,DebitRazdel_Sn^.List^.Count);
    RazdelElement.Name:=Copy(s,1,CRazdel);
    RazdelElement.Kod:=Copy(s,1+CRazdel+1,CRazdelKod);
    Seek(RazdelFile,FileSize(RazdelFile));
    Write(RazdelFile,RazdelElement);
   End;
   Close(RazdelFile);
   End;
  Dispose(DebitRazdel_Sn,Done);


  If DebitSFRazdel^.List^.Count>=0 Then
  Begin
  Assign (RazdelFile,Path.ToRazdel+'zaprdsf!.db');
  Rewrite (RazdelFile);
  For c:=0 To DebitSFRazdel^.List^.Count-1 Do
   Begin
    s:=DebitSFRazdel^.GetText(c,DebitSFRazdel^.List^.Count);
    RazdelElement.Name:=Copy(s,1,CRazdel);
    RazdelElement.Kod:=Copy(s,1+CRazdel+1,CRazdelKod);
    Seek(RazdelFile,FileSize(RazdelFile));
    Write(RazdelFile,RazdelElement);
   End;
   Close(RazdelFile);
   End;
  Dispose(DebitSFRazdel,Done);

  If DebitSFBRazdel^.List^.Count>=0 Then
  Begin
  Assign (RazdelFile,Path.ToRazdel+'zaprdsb.db');
  Rewrite (RazdelFile);
  For c:=0 To DebitSFBRazdel^.List^.Count-1 Do
   Begin
    s:=DebitSFBRazdel^.GetText(c,DebitSFBRazdel^.List^.Count);
    RazdelElement.Name:=Copy(s,1,CRazdel);
    RazdelElement.Kod:=Copy(s,1+CRazdel+1,CRazdelKod);
    Seek(RazdelFile,FileSize(RazdelFile));
    Write(RazdelFile,RazdelElement);
   End;
   Close(RazdelFile);
   End;
  Dispose(DebitSFBRazdel,Done);




  ControlSelect^.GetData(DefaultDoc);
  ControlReal^.GetData(DefaultReal);
  ControlNumer^.GetData(ShowNumer);
  ControlLizensia^.GetData(DefaultLizensia);
  ControlClients^.GetData(ShowClients);
  ControlDSertif^.GetData(ShowSertif);
  ControlRP^.GetData(ClientRP);
  Str(StrToInt(ClientRP):CClientKod,ClientRp);
  DelSPace(CLientRP);
  RFormatZerro(CLientRP,CClientKod);

  ControlPrihodMax^.GetData(Prihodnik);
  DelSpace(Prihodnik);
  PrihodMax:=StrToReal(Prihodnik);

  Dispose(ControlSelect,Done);
  Dispose(ControlLizensia,Done);
  Dispose(ControlNumer,Done);
  Dispose(ControlClients,Done);
  Dispose(ControlDSertif,Done);
  Dispose(ControlRp,Done);
  Dispose(ControlPrihodMax,Done);

  Dispose(NastrWin,Done);

  AddProtocol('Корректировка настройки продаж !!!','','');
         c:=0;
         WriteNewIni(c);
         If c<> 0 Then Errors('Ошибка записи файла конфигурации !');

 End
 Else
  Begin
  Dispose(Control,Done);
  Dispose(Razdel,Done);
  Dispose(SpisokRazdel,Done);
  Dispose(TChekRazdel,Done);
  Dispose(FZRazdel,Done);
  Dispose(SfRazdel,Done);
  Dispose(SFBRazdel,Done);
  Dispose(DebitRazdel,Done);
  Dispose(DebitRazdel_SN,Done);
  Dispose(DebitSFRazdel,Done);
  Dispose(DebitSFBRazdel,Done);
  Dispose(ControlSelect,Done);
  Dispose(ControlReal,Done);
  Dispose(ControlNumer,Done);
  Dispose(ControlLizensia,Done);
  Dispose(ControlClients,Done);
  Dispose(ControlDSertif,Done);
  Dispose(ControlRp,Done);
  Dispose(ControlPrihodMax,Done);
  Dispose(NastrWin,Done);

  End;
End;


Destructor TNastrWindow.Done;
Begin
TDialog.Done;
End;



procedure TNastrWindow.HandleEvent(var Event: TEvent);
Var s : String[CRazdel+1+CRazdelKod];
    ls : Word;
Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
  kbCtrLDel: Begin
     If (SpisokRazdel^.State and sfFocused <> 0) And (SpisokRazdel^.List<>Nil)And(SpisokRazdel^.List^.Count>=1) Then
            Begin
             SpisokRazdel^.NewList(nil);
             SpisokRazdel^.NewList(New(PTextCollection, Init(1,1)));
            End;
     If (SFRazdel^.State and sfFocused <> 0) And (SFRazdel^.List<>Nil)And(SFRazdel^.List^.Count>=1) Then
            Begin
             SFRazdel^.NewList(nil);
             SFRazdel^.NewList(New(PTextCollection, Init(1,1)));
            End;
     If (SfbRAzdel^.State and sfFocused <> 0) And (SfbRAzdel^.List<>Nil)And(SfbRAzdel^.List^.Count>=1) Then
            Begin
             SfbRAzdel^.NewList(nil);
             SfbRAzdel^.NewList(New(PTextCollection, Init(1,1)));
            End;
     If (DebitRAzdel^.State and sfFocused <> 0) And (DebitRAzdel^.List<>Nil)And(DebitRAzdel^.List^.Count>=1) Then
            Begin
             DebitRAzdel^.NewList(nil);
             DebitRAzdel^.NewList(New(PTextCollection, Init(1,1)));
            End;
     If (DebitRazdel_Sn^.State and sfFocused <> 0) And (DebitRazdel_Sn^.List<>Nil)And(DebitRazdel_Sn^.List^.Count>=1) Then
            Begin
             DebitRazdel_Sn^.NewList(nil);
             DebitRazdel_Sn^.NewList(New(PTextCollection, Init(1,1)));
            End;
     If (DebitSFRazdel^.State and sfFocused <> 0) And (DebitSFRazdel^.List<>Nil)And(DebitSFRazdel^.List^.Count>=1) Then
            Begin
             DebitSFRazdel^.NewList(nil);
             DebitSFRazdel^.NewList(New(PTextCollection, Init(1,1)));
            End;
     If (DebitSFBRazdel^.State and sfFocused <> 0) And (DebitSFBRazdel^.List<>Nil)And(DebitSFBRazdel^.List^.Count>=1) Then
            Begin
             DebitSFBRazdel^.NewList(nil);
             DebitSFBRazdel^.NewList(New(PTextCollection, Init(1,1)));
            End;
     If (TChekRazdel^.State and sfFocused <> 0) And (TChekRazdel^.List<>Nil)And(TChekRazdel^.List^.Count>=1) Then
            Begin
             TChekRazdel^.NewList(nil);
             TChekRazdel^.NewList(New(PTextCollection, Init(1,1)));
            End;
     If (FZRazdel^.State and sfFocused <> 0) And (FZRazdel^.List<>Nil)And(FZRazdel^.List^.Count>=1) Then
            Begin
             FZRazdel^.NewList(nil);
             FZRazdel^.NewList(New(PTextCollection, Init(1,1)));
            End;
             Redraw;
            End;
     kbDel: Begin
     If (SpisokRazdel^.State and sfFocused <> 0) And (SpisokRazdel^.List<>Nil)And(SpisokRazdel^.List^.Count>=1) Then
            Begin
             SpisokRazdel^.List^.AtFree(SpisokRazdel^.Focused);
             SpisokRazdel^.SetRange(SpisokRazdel^.List^.Count);
             If SpisokRazdel^.Focused>0 Then
             SpisokRazdel^.FocusItem(SpisokRazdel^.Focused);
             If (SpisokRazdel^.Focused>=SpisokRazdel^.List^.Count) and(SpisokRazdel^.Focused>0) Then
             SpisokRazdel^.FocusItem(SpisokRazdel^.Focused-1);

            ClearEvent(Event);
            End;
     If (SFRazdel^.State and sfFocused <> 0) And (SFRazdel^.List<>Nil)And(SFRazdel^.List^.Count>=1) Then
            Begin
             SFRazdel^.List^.AtFree(SFRazdel^.Focused);
             SFRazdel^.SetRange(SFRazdel^.List^.Count);
             If SFRazdel^.Focused>0 Then
             SFRazdel^.FocusItem(SFRazdel^.Focused);
             If (SFRazdel^.Focused>=SFRazdel^.List^.Count) and(SFRazdel^.Focused>0) Then
             SFRazdel^.FocusItem(SFRazdel^.Focused-1);

            ClearEvent(Event);
            End;
     If (SfbRAzdel^.State and sfFocused <> 0) And (SfbRAzdel^.List<>Nil)And(SfbRAzdel^.List^.Count>=1) Then
            Begin
             SfbRAzdel^.List^.AtFree(SfbRAzdel^.Focused);
             SfbRAzdel^.SetRange(SfbRAzdel^.List^.Count);
             If SfbRAzdel^.Focused>0 Then
             SfbRAzdel^.FocusItem(SfbRAzdel^.Focused);
             If (SfbRAzdel^.Focused>=SfbRAzdel^.List^.Count) and(SfbRAzdel^.Focused>0) Then
             SfbRAzdel^.FocusItem(SfbRAzdel^.Focused-1);

            ClearEvent(Event);
            End;
     If (DebitRAzdel^.State and sfFocused <> 0) And (DebitRAzdel^.List<>Nil)And(DebitRAzdel^.List^.Count>=1) Then
            Begin
             DebitRAzdel^.List^.AtFree(DebitRAzdel^.Focused);
             DebitRAzdel^.SetRange(DebitRAzdel^.List^.Count);
             If DebitRAzdel^.Focused>0 Then
             DebitRAzdel^.FocusItem(DebitRAzdel^.Focused);
             If (DebitRAzdel^.Focused>=DebitRAzdel^.List^.Count) and(DebitRAzdel^.Focused>0) Then
             DebitRAzdel^.FocusItem(DebitRAzdel^.Focused-1);

            ClearEvent(Event);
            End;
     If (DebitRazdel_Sn^.State and sfFocused <> 0) And (DebitRazdel_Sn^.List<>Nil)And(DebitRazdel_Sn^.List^.Count>=1) Then
            Begin
             DebitRazdel_Sn^.List^.AtFree(DebitRazdel_Sn^.Focused);
             DebitRazdel_Sn^.SetRange(DebitRazdel_Sn^.List^.Count);
             If DebitRazdel_Sn^.Focused>0 Then
             DebitRazdel_Sn^.FocusItem(DebitRazdel_Sn^.Focused);
             If (DebitRazdel_Sn^.Focused>=DebitRazdel_Sn^.List^.Count) and(DebitRazdel_Sn^.Focused>0) Then
             DebitRazdel_Sn^.FocusItem(DebitRazdel_Sn^.Focused-1);

            ClearEvent(Event);
            End;
     If (DebitSFBRazdel^.State and sfFocused <> 0) And (DebitSFBRazdel^.List<>Nil)And(DebitSFBRazdel^.List^.Count>=1) Then
            Begin
             DebitSFBRazdel^.List^.AtFree(DebitSFBRazdel^.Focused);
             DebitSFBRazdel^.SetRange(DebitSFBRazdel^.List^.Count);
             If DebitSFBRazdel^.Focused>0 Then
             DebitSFBRazdel^.FocusItem(DebitSFBRazdel^.Focused);
             If (DebitSFBRazdel^.Focused>=DebitSFBRazdel^.List^.Count) and(DebitSFBRazdel^.Focused>0) Then
             DebitSFBRazdel^.FocusItem(DebitSFBRazdel^.Focused-1);

            ClearEvent(Event);
            End;
     If (DebitSFRazdel^.State and sfFocused <> 0) And (DebitSFRazdel^.List<>Nil)And(DebitSFRazdel^.List^.Count>=1) Then
            Begin
             DebitSFRazdel^.List^.AtFree(DebitSFRazdel^.Focused);
             DebitSFRazdel^.SetRange(DebitSFRazdel^.List^.Count);
             If DebitSFRazdel^.Focused>0 Then
             DebitSFRazdel^.FocusItem(DebitSFRazdel^.Focused);
             If (DebitSFRazdel^.Focused>=DebitSFRazdel^.List^.Count) and(DebitSFRazdel^.Focused>0) Then
             DebitSFRazdel^.FocusItem(DebitSFRazdel^.Focused-1);

            ClearEvent(Event);
            End;
     If (TChekRazdel^.State and sfFocused <> 0) And (TChekRazdel^.List<>Nil)And(TChekRazdel^.List^.Count>=1) Then
            Begin
             TChekRazdel^.List^.AtFree(TChekRazdel^.Focused);
             TChekRazdel^.SetRange(TChekRazdel^.List^.Count);
             If TChekRazdel^.Focused>0 Then
             TChekRazdel^.FocusItem(TChekRazdel^.Focused);
             If (TChekRazdel^.Focused>=TChekRazdel^.List^.Count) and(TChekRAzdel^.Focused>0) Then
             TChekRazdel^.FocusItem(TChekRazdel^.Focused-1);

            ClearEvent(Event);
            End;
     If (FZRazdel^.State and sfFocused <> 0) And (FZRazdel^.List<>Nil)And(FZRazdel^.List^.Count>=1) Then
            Begin
             FZRazdel^.List^.AtFree(FZRazdel^.Focused);
             FZRazdel^.SetRange(FZRazdel^.List^.Count);
             If FZRazdel^.Focused>0 Then
             FZRazdel^.FocusItem(FZRazdel^.Focused);
             If (FZRazdel^.Focused>=FZRazdel^.List^.Count) and(FZRAzdel^.Focused>0) Then
             FZRazdel^.FocusItem(FZRazdel^.Focused-1);
            ClearEvent(Event);
            End;
              Redraw;
            End;
 kbAlt1 : Begin
            If(Razdel^.State and sfFocused <> 0) And (Razdel^.Focused<Razdel^.List^.Count) Then
            Begin
               s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.COunt);
              If TestElement(Copy(s,1+CRazdel+1,CRazdelKod),TChekRazdel) Then
               Begin
               TChekRazdel^.List^.Insert(NewStr(s));
               TChekRazdel^.SetRange(TChekRazdel^.List^.Count);
               s:=Copy(s,1+CRazdel+1,CRazdelKod);
               TChekRazdel^.FocusItem(LoCation(TChekRazdel,S,ProdagaWindow));
               If TChekRazdel^.Focused+1<TChekRazdel^.List^.Count Then
               TChekRazdel^.FocusItem(TChekRazdel^.List^.Count-1);
               End;
               If (Razdel^.Focused+1) <  Razdel^.List^.Count Then
               Razdel^.FocusItem(Razdel^.Focused+1);
              End;
              ClearEvent(Event);
              Redraw;
            End;
 kbAlt0 : Begin
            If(Razdel^.State and sfFocused <> 0) And (Razdel^.Focused<Razdel^.List^.Count) Then
            Begin
               s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.COunt);
              If TestElement(Copy(s,1+CRazdel+1,CRazdelKod),SpisokRazdel) Then
               Begin
               SpisokRazdel^.List^.Insert(NewStr(s));
               SpisokRazdel^.SetRange(SpisokRazdel^.List^.Count);
               s:=Copy(s,1+CRazdel+1,CRazdelKod);
               SpisokRazdel^.FocusItem(LoCation(SpisokRazdel,S,ProdagaWindow));
               If SpisokRazdel^.Focused+1<SpisokRazdel^.List^.Count Then
               SpisokRazdel^.FocusItem(SpisokRazdel^.List^.Count-1);
               End;
               If (Razdel^.Focused+1) <  Razdel^.List^.Count Then
               Razdel^.FocusItem(Razdel^.Focused+1);
              End;
              ClearEvent(Event);
              Redraw;
            End;
{
kbEnter  : Begin
            If(ControlRP^.State and sfFocused <> 0)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmOk;
             PutEvent(Event);
             ClearEvent(Event);
            End;
            End;
}

kbAlt2 : Begin
            If(Razdel^.State and sfFocused <> 0) And (Razdel^.Focused<Razdel^.List^.Count) Then
            Begin
               s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.COunt);
               If TestElement(Copy(s,1+CRazdel+1,CRazdelKod),FZRazdel) Then
               Begin
               FZRazdel^.List^.Insert(NewStr(s));
               FZRazdel^.SetRange(FZRazdel^.List^.Count);
               s:=Copy(s,1+CRazdel+1,CRazdelKod);
               FZRazdel^.FocusItem(LoCation(FZRazdel,S,ProdagaWindow));
               If FZRazdel^.Focused+1<FZRazdel^.List^.Count Then
               FZRazdel^.FocusItem(FZRazdel^.List^.Count-1);
               End;
               If (Razdel^.Focused+1) <  Razdel^.List^.Count Then
               Razdel^.FocusItem(Razdel^.Focused+1);
            End;
              ClearEvent(Event);
              Redraw;
            End;
 kbAlt3 : Begin
{           If MessageBox(#3+'Вы уверены что хотите запретить указанный раздел для С/Ф?'+
                 ' В окне продажи после этого могут возникнуть непредвиденные осложнения!',Nil,mfWarning+mfOkCancel)=cmOk Then}
            If(Razdel^.State and sfFocused <> 0) And (Razdel^.Focused<Razdel^.List^.Count) Then
            Begin
               s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.COunt);
              If TestElement(Copy(s,1+CRazdel+1,CRazdelKod),SFRazdel) Then
               Begin
               SFRazdel^.List^.Insert(NewStr(s));
               SFRazdel^.SetRange(SFRazdel^.List^.Count);
               s:=Copy(s,1+CRazdel+1,CRazdelKod);
               SFRazdel^.FocusItem(LoCation(SFRazdel,S,ProdagaWindow));
               If SFRazdel^.Focused+1<SFRazdel^.List^.Count Then
               SFRazdel^.FocusItem(SFRazdel^.List^.Count-1);
               End;
               If (Razdel^.Focused+1) <  Razdel^.List^.Count Then
               Razdel^.FocusItem(Razdel^.Focused+1);
              End;
              ClearEvent(Event);
              Redraw;
            End;
 kbAlt4 : Begin
            If(Razdel^.State and sfFocused <> 0) And (Razdel^.Focused<Razdel^.List^.Count) Then
            Begin
               s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.COunt);
              If TestElement(Copy(s,1+CRazdel+1,CRazdelKod),SfbRAzdel) Then
               Begin
               SfbRAzdel^.List^.Insert(NewStr(s));
               SfbRAzdel^.SetRange(SfbRAzdel^.List^.Count);
               s:=Copy(s,1+CRazdel+1,CRazdelKod);
               SfbRAzdel^.FocusItem(LoCation(SfbRAzdel,S,ProdagaWindow));
               If SfbRAzdel^.Focused+1<SfbRAzdel^.List^.Count Then
               SfbRAzdel^.FocusItem(SfbRAzdel^.List^.Count-1);
               End;
               If (Razdel^.Focused+1) <  Razdel^.List^.Count Then
               Razdel^.FocusItem(Razdel^.Focused+1);
              End;
              ClearEvent(Event);
              Redraw;
            End;
 kbAlt5 : Begin
            If(Razdel^.State and sfFocused <> 0) And (Razdel^.Focused<Razdel^.List^.Count) Then
            Begin
               s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.COunt);
              If TestElement(Copy(s,1+CRazdel+1,CRazdelKod),DebitRAzdel) Then
               Begin
               DebitRAzdel^.List^.Insert(NewStr(s));
               DebitRAzdel^.SetRange(DebitRAzdel^.List^.Count);
               s:=Copy(s,1+CRazdel+1,CRazdelKod);
               DebitRAzdel^.FocusItem(LoCation(DebitRAzdel,S,ProdagaWindow));
               If DebitRAzdel^.Focused+1<DebitRAzdel^.List^.Count Then
               DebitRAzdel^.FocusItem(DebitRAzdel^.List^.Count-1);
               End;
               If (Razdel^.Focused+1) <  Razdel^.List^.Count Then
               Razdel^.FocusItem(Razdel^.Focused+1);
              End;
              ClearEvent(Event);
              Redraw;
            End;
 kbAlt6 : Begin
            If(Razdel^.State and sfFocused <> 0) And (Razdel^.Focused<Razdel^.List^.Count) Then
            Begin
               s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.COunt);
              If TestElement(Copy(s,1+CRazdel+1,CRazdelKod),DebitSFRazdel) Then
               Begin
               DebitSFRazdel^.List^.Insert(NewStr(s));
               DebitSFRazdel^.SetRange(DebitSFRazdel^.List^.Count);
               s:=Copy(s,1+CRazdel+1,CRazdelKod);
               DebitSFRazdel^.FocusItem(LoCation(DebitSFRazdel,S,ProdagaWindow));
               If DebitSFRazdel^.Focused+1<DebitSFRazdel^.List^.Count Then
               DebitSFRazdel^.FocusItem(DebitSFRazdel^.List^.Count-1);
               End;
               If (Razdel^.Focused+1) <  Razdel^.List^.Count Then
               Razdel^.FocusItem(Razdel^.Focused+1);
              End;
              ClearEvent(Event);
              Redraw;
            End;
 kbAlt7 : Begin
            If(Razdel^.State and sfFocused <> 0) And (Razdel^.Focused<Razdel^.List^.Count) Then
            Begin
               s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.COunt);
              If TestElement(Copy(s,1+CRazdel+1,CRazdelKod),DebitRazdel_Sn) Then
               Begin
               DebitRazdel_Sn^.List^.Insert(NewStr(s));
               DebitRazdel_Sn^.SetRange(DebitRazdel_Sn^.List^.Count);
               s:=Copy(s,1+CRazdel+1,CRazdelKod);
               DebitRazdel_Sn^.FocusItem(LoCation(DebitRazdel_Sn,S,ProdagaWindow));
               If DebitRazdel_Sn^.Focused+1<DebitRazdel_Sn^.List^.Count Then
               DebitRazdel_Sn^.FocusItem(DebitRazdel_Sn^.List^.Count-1);
               End;
               If (Razdel^.Focused+1) <  Razdel^.List^.Count Then
               Razdel^.FocusItem(Razdel^.Focused+1);
              End;
              ClearEvent(Event);
              Redraw;
            End;
 kbAlt8 : Begin
            If(Razdel^.State and sfFocused <> 0) And (Razdel^.Focused<Razdel^.List^.Count) Then
            Begin
               s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.COunt);
              If TestElement(Copy(s,1+CRazdel+1,CRazdelKod),DebitSFBRazdel) Then
               Begin
               DebitSFBRazdel^.List^.Insert(NewStr(s));
               DebitSFBRazdel^.SetRange(DebitSFBRazdel^.List^.Count);
               s:=Copy(s,1+CRazdel+1,CRazdelKod);
               DebitSFBRazdel^.FocusItem(LoCation(DebitSFBRazdel,S,ProdagaWindow));
               If DebitSFBRazdel^.Focused+1<DebitSFBRazdel^.List^.Count Then
               DebitSFBRazdel^.FocusItem(DebitSFBRazdel^.List^.Count-1);
               End;
               If (Razdel^.Focused+1) <  Razdel^.List^.Count Then
               Razdel^.FocusItem(Razdel^.Focused+1);
              End;
              ClearEvent(Event);
              Redraw;
            End;

    Else;
    End;
    Else;
    End;
  inherited HandleEvent(Event);
End;

(*
Procedure SetSkidki;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  C : Word;
  f : File Of SkidkaType;
  s : SkidkaType;
  i : Byte;

begin
For i:=1 To 10 Do
 Begin
  s.Skidka[i].Up:='0.00';
  s.Skidka[i].Proz:='0.00';
 End;
Assign(f,Print.PathToMain+'skidka.db');
c:=IOResult;
Reset(f);
c:=IOResult;
If c=0 Then
   Begin
    Read(f,s);
    Close(f);
   End
Else MessageBox(#3'Файл скидок '+Print.PathToMain+'skidka.Baz не найден !',nil,mfError+mfCancelButton);
1:
R.Assign(21, 5, 58, 18);
New(Dlg, Init(R, 'Скидки'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E003;

R.Assign(5, 2, 22, 3);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(28, 2, 35, 3);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(5, 3, 22, 4);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(28, 3, 35, 4);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(5, 4, 22, 5);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(28, 4, 35, 5);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(5, 5, 22, 6);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(28, 5, 35, 6);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(5, 6, 22, 7);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(28, 6, 35, 7);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(5, 7, 22, 8);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(28, 7, 35, 8);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(5, 8, 22, 9);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(28, 8, 35, 9);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(5, 9, 22, 10);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(28, 9, 35, 10);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(5, 10, 22, 11);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(28, 10, 35, 11);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(5, 11, 22, 12);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(28, 11, 35, 12);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

R.Assign(1, 1, 26, 2);
Control := New(PColoredText, Init(R, 'Сумма по накладной, руб.', $74));

Dlg^.Insert(Control);
R.Assign(27, 1, 36, 2);
Control := New(PColoredText, Init(R, 'Скидка, %', $74));
Dlg^.Insert(Control);
Dlg^.SelectNext(False);
Dlg^.SetData(S);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
  Begin
   Dlg^.GetData(S);
   For i:=1 To 10 Do
 Begin
  Str(StrToReal(s.Skidka[i].Up):CIZena:CMantissa,s.Skidka[i].Up);
  If StrToReal(s.Skidka[i].Up)>999999999999.99 Then
   Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   MessageBox(#3'Сумма по накладной не может быть больше 999999999999.99 руб',Nil,mfError+mfCancelButton);
   DelSpace(s.Skidka[i].Up);
   DelSpace(s.Skidka[i].Proz);
   Goto 1;
   End;
   Str(StrToReal(s.Skidka[i].Proz):CLitr:CMantissa,s.Skidka[i].Proz);
  If StrToReal(s.Skidka[i].Proz)>100 Then
   Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   MessageBox(#3'Скидка не может превышать 100 процентов',Nil,mfError+mfCancelButton);
   DelSpace(s.Skidka[i].Up);
   DelSpace(s.Skidka[i].Proz);
   Goto 1;
   End;
   If i>1 Then
   If StrToreal(s.Skidka[i].Up)<StrToReal(s.Skidka[i-1].Up) Then
   Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   MessageBox(#3'Скидки должны идти по возрастанию !'^M+
   #3'Исправьте ошибку и повторите ввод!',Nil,mfError+mfCancelButton);
   Goto 1;
   End;

   DelSpace(s.Skidka[i].Up);
   DelSpace(s.Skidka[i].Proz);
 End;
   Rewrite(f);
   Write(f,s);
   Close(f);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
  End
  Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
  End;
End;
*)

{Здесь}
procedure TOperatorWindow.OpenOperatorWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmOperator, nil) = nil then
  begin
    DInfo('Инициализация системного реестра...');
    L:=True;
    OperatorWin := New(POperatorWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(OperatorWin);
    NoInfo;
    End
    Else
     Begin
      Status:=DocNormal;
      Dispose(OperatorWin,Done);
      NoInfo;
     End;
  end
  else
    if PView(OperatorWin) <> Desktop^.TopView then OperatorWin^.Select;
    Previos[0]:=#0;
end;



constructor TOperatorWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
begin
ClearFind;
L := False;
R.Assign(21, 5, 59, 18);
inherited Init(R, 'Реестр операторов системы');
Options := Options or ofCenterX or ofCenterY;

R.Assign(35, 2, 36, 10);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(2, 2, 35, 10);
Operator := New(PBox, Init(R, 2, PScrollBar(Control)));
Operator^.NewList(New(PTextCollection, Init(1,1)));
Assign (OperatorFile,Path.ToOperator+'system.db');
Reset (OperatorFile);
While Not(Eof(OperatorFile)) Do
 Begin
  Read(OperatorFile,OperatorElement);
  If OperatorElement.Employ Then
   Begin
    Format (OperatorElement.Name,CKto);
    Operator^.List^.Insert(NewStr(OperatorElement.Name+'│'+OperatorElement.Kod));
    Operator^.SetRange(Operator^.List^.Count);
   End;
 End;
System.Close(OperatorFile);
Operator^.FocusItem(0);
Operator^.HelpCtx:=$E001;
Insert(Operator);
  R.Assign(2, 1, 36, 2);
  Insert(New(PLabel, Init(R, 'Оператор     Код Оператор     Код', Operator)));

R.Assign(6, 11, 23, 12);
Control := New(PColoredText, Init(R, 'Пароль оператора:', $74));
Insert(Control);

R.Assign(23, 11, 33, 12);
ControlOperator := New(PColoredText, Init(R, #3+'', $7E));
Insert(ControlOperator);
SelectNext(False);

L:=True;
End;

procedure TOperatorWindow.HandleEvent(var Event: TEvent);
Var test : Byte;
    s : AllStr;
    R : TRect;
begin
  Case Event.What Of
  evKeyDown :
              Case Event.KeyCode Of
                    kbDel: Begin
                           ClearFind;
     If (Operator^.State and sfFocused <> 0) And (Operator^.List<>Nil)And(Operator^.List^.Count>=1) Then
    Begin
   If MessageBox(#3+DelOperator,Nil,mfConfirmation+mfOkCancel)=cmOk Then
              Begin
               test := IOResult;
               s:=Operator^.GetText(Operator^.Focused,Operator^.List^.Count);
               s:=Copy(s,1+CKto+1,CRazdelKod);
               If (s<>'00') Then
               Begin
               Assign(OperatorFile,Path.ToOperator+'System.db');
               Reset(OperatorFile);
               Test:=IOResult;
               If (Test=0) Then
                Begin
                 Seek(OperatorFile,GetFileLocation3(s){-1});
                 OperatorElement.Name[0]:=#0;
                 OperatorElement.Employ:=False;
                 OperatorElement.Kod:=s;
                 Write(OperatorFile,OperatorElement);
                 System.Close(OperatorFile);
                 AddProtoCol('Удаление оператора:'+s,'','');
                 Operator^.List^.AtFree(Operator^.Focused);
                 Operator^.SetRange(Operator^.List^.Count);
                 If Operator^.Focused>0 Then
                 Operator^.FocusItem(Operator^.Focused);
                 If (Operator^.Focused>=Operator^.List^.Count) and(Operator^.Focused>0) Then
                 Operator^.FocusItem(Operator^.Focused-1);

                End
                Else
                MessageBox(#3+ErrorOperatorFile,nil,mfError+mfCanCelButton);
                End
                Else
                MessageBox(^M+#3+'Ваш уровень доступа не позволяет удалять '+GetOperatorName(s)+' !',nil,
                         mfError+mfCanCelButton);
             End;
                 ClearEvent(Event);
                 Redraw;
                             End;
       End;

kbGrayPlus,kbF4: Begin
     ClearFind;
     If (Operator^.State and sfFocused <> 0) And (Operator^.List<>Nil)And(Operator^.List^.Count>=1) Then
    Begin
             If AddOperator(Event.KeyCode,OperatorElement) Then
              Begin
              If (Event.KeyCode=kbF4)And(Operator^.List<>Nil)And(Operator^.List^.Count>=1) Then
               Operator^.List^.AtFree(Operator^.Focused);
               Format(OperatorElement.Name,CKto);
               Operator^.List^.Insert(NewStr(OperatorElement.Name+'│'+OperatorElement.Kod));
               Operator^.SetRange(Operator^.List^.Count);
               Operator^.FocusItem(LoCation(Operator,OperatorElement.Kod,ProdagaWindow));
               Previos[0]:=#0;
              End;
              ClearEvent(Event);
              Redraw;
    End;
                       End;

kbF6: Begin
     ClearFind;
     If (Operator^.State and sfFocused <> 0) And (Operator^.List<>Nil)And(Operator^.List^.Count>=1) Then
    Begin
             If AddDopOperator(Event.KeyCode,OperatorElement) Then
              Begin
              If (Event.KeyCode=kbF6)And(Operator^.List<>Nil)And(Operator^.List^.Count>=1) Then
               Operator^.List^.AtFree(Operator^.Focused);
               Format(OperatorElement.Name,CKto);
               Operator^.List^.Insert(NewStr(OperatorElement.Name+'│'+OperatorElement.Kod));
               Operator^.SetRange(Operator^.List^.Count);
               Operator^.FocusItem(LoCation(Operator,OperatorElement.Kod,ProdagaWindow));
               Previos[0]:=#0;
              End;
              ClearEvent(Event);
              Redraw;
    End;
          end;


                    kbEsc: Begin
                            Event.What:=evCommand;
                            Event.Command:=cmCancel;
                            PutEvent(Event);
                           End;


          kbF5 : Begin

              If (Operator^.List<>Nil) And (Operator^.List^.Count>=1)Then
              Begin
                  s:=Operator^.GetText(Operator^.Focused,Operator^.List^.Count);
                  Previos:=Copy(s,1+CKto+1,CRazdelKod);
                  s:=Decode(GetOperatorPassword(Previos));
                  Dispose(ControlOperator,Done);
                  R.Assign(23, 11, 33, 12);
                  ControlOperator := New(PColoredText, Init(R, S, $7E));
                  Insert(ControlOperator);
                  Previos:=Operator^.GetText(Operator^.Focused,Operator^.List^.Count);
              End;
                 End;

                Else;
                End;{KeyDown}
  evCommand :
     Case Event.Command Of

     cmAbout: Begin
      AboutCHM('143');
      ClearEvent(Event);
     End;

     cmOperator: Begin
                 ClearEvent(Event);
                 End;
     cmOk : Begin
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 ClearEvent(Event);
            End;
      cmCancel : Begin
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 ClearEvent(Event);
                End;

      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmOperator) then ClearEvent(Event);
  inherited HandleEvent(Event);

 If (Desktop^.Current=PView(OperatorWin)) And (Event.What <> EvKeyDown) Then
              if (Operator^.List<>Nil) And (Operator^.List^.Count>=1)Then
              Begin
               s:=Operator^.GetText(Operator^.Focused,Operator^.List^.Count);
               If s <> Previos Then
                 Begin
                  Previos:=Copy(s,1+CKto+1,CRazdelKod);
                  s:=Decode(GetOperatorPassword(Previos));
                  Dispose(ControlOperator,Done);
                  R.Assign(23, 11, 33, 12);
                  ControlOperator := New(PColoredText, Init(R, '???', $7E));
                  Insert(ControlOperator);
                  Previos:=Operator^.GetText(Operator^.Focused,Operator^.List^.Count);
                End
              End;

end;


Procedure CloseDate(i:Integer);
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  s : TDateString;
  s1 : String;
  ss:TDateString;
begin


ClearFind;

{$IFDEF NetVersion}
{$IFNDEF Kurz}

If (StrToInt(CurrentPassword)<>0) And FindPAram('/NOCLOSE') Then
Begin
 MessageBox(^M+#3'С этой рабочей станции нельзя закрывать день!',Nil,mfError+mfCancelButton);
 Exit;
End;

If i<>0 Then
If MessageBox(#3'Перед закрытием дня Вы убедились, что на всех рабочих станциях работа завершена?'+
' В противном случае правильность расчета не гарантируется!',Nil,mfWarning+
mfOkCancel)<>cmOK Then
 Exit;
{$ENDIF}
{$ENDIF}



If i<>1 Then
 If Not(Password(3)) Then Exit;

1:
R.Assign(27, 9, 55, 14);
If i=1 Then New(Dlg, Init(R, 'Блокировать день'))
Else New(Dlg, Init(R, 'Деблокировать день'));
(*Dlg^.Options := Dlg^.Options {and not(ofSelectable or ofTopSelect)} or ofCenterX or ofCenterY;*)
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(10, 2, 20, 3);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
{Control^.EventMask := Control^.EventMask and not(evMouseDown or evKeyDown or evCommand);}
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init('{##}-{##}-{##}'{'##-##-9#'}, True));

  R.Assign(4, 2, 10, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Дата:', Control)));

Dlg^.SelectNext(False);
Dlg^.SetData(FDate);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(S);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  DelSpace(s);
  If s[0]=#0 Then
  Begin
   MessageBox(^M+#3+'Не указана дата',Nil,mfError+mfCancelButton);
   Goto 1;
  End;
  If i=1 Then
  Begin
   TestClientBaza;
   If ( TestOplataClientFile(s)) And (TestPrihod(s)) And (TestNewVozwrat(s)) Then
   Begin
   If BlockDate1(s) Then
     Begin
      MessageBox(#3^M+#3'День успешно закрыт - доступ к данным за '+S+' заблокирован!',Nil,mfInformation+mfCancelButton);
      If s=FDate Then
      Begin
      s1:=FDate;

      ss:=Fdate;

      If s=FDAte Then CalcDolgClient(s1)
      Else
      If MessageBox(^M+#3'Сохранить базу долгов клиентов за '+S+'?',Nil,MfWarning+mfOkCancel)=cmOk Then
      CalcDolgClient(s1);


      If MessageBox(^M+#3'Сохранить базу остатков и продаж за '+S1+'?',Nil,MfWarning+mfOkCancel)=cmOk Then
	 CreatReport(True,s1);
      End;
      (*AddProtocol(s+' Закрытие программного дня');*)
     End;
   End;
  End
  Else
   If DeBlockDate1(s) Then
     Begin
      MessageBox(#3^M+#3'День успешно открыт - доступ к данным за '+S+' деблокирован!',Nil,mfInformation+mfCancelButton);
      (*AddProtocol(s+' Открытие программного дня {Очень важно}');*)
     End;
 End
 Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
  End;
end;



Procedure ChangeRekwiziti;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  C: LongInt;
begin
ClearFind;
R.Assign(0, 0, 80, 23);
New(Dlg, Init(R, 'Реквизиты предприятия'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E002;

R.Assign(14, 0, 20, 1);
Control := New(PInputLine, Init(R, 4));
If CurrentPassword<>'00' Then
Begin
Control^.Options := Control^.Options and not(ofSelectable or ofFirstClick);
Control^.EventMask := Control^.EventMask and not(evMouseDown or evKeyDown or evCommand);
End;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(2, 0, 14, 1);
  Dlg^.Insert(New(PLabel, Init(R, 'Код склада:', Control)));



R.Assign(27, 1, 74, 2);
Control := New(PInputLine, Init(R, 100));
Dlg^.Insert(Control);

  R.Assign(14, 1, 27, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Пред~п~риятие:', Control)));

R.Assign(27, 2, 74, 3);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(20, 2, 27, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~А~дрес:', Control)));

R.Assign(27, 3, 74, 4);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(18, 3, 27, 4);
  Dlg^.Insert(New(PLabel, Init(R, '~Т~елефон:', Control)));

R.Assign(27, 4, 74, 5);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(11, 4, 27, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~Р~асчетный счет:', Control)));

R.Assign(27, 5, 74, 6);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(24, 5, 27, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'в:', Control)));

R.Assign(27, 6, 74, 7);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(20, 6, 27, 7);
  Dlg^.Insert(New(PLabel, Init(R, '~Г~ород:', Control)));

R.Assign(27, 7, 74, 8);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(22, 7, 27, 8);
  Dlg^.Insert(New(PLabel, Init(R, '~И~НН:', Control)));

R.Assign(27, 8, 74, 9);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(13, 8, 27, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Ко~д~ по ОКОНХ:', Control)));

R.Assign(27, 9, 74, 10);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(14, 9, 27, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Код по ~О~КПО:', Control)));

R.Assign(27, 10, 74, 11);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(8, 10, 27, 11);
  Dlg^.Insert(New(PLabel, Init(R, 'Адрес гру~з~оотправ:', Control)));

R.Assign(27, 11, 74, 12);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(3, 11, 27, 12);
  Dlg^.Insert(New(PLabel, Init(R, '      Почтовый индекс:', Control)));

R.Assign(27, 12, 74, 13);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(2, 12, 27, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'Опт.лицензия сигарет~ы~ N:', Control)));

R.Assign(6, 13, 18, 14);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(3, 13, 6, 14);
  Dlg^.Insert(New(PLabel, Init(R, '1:', Control)));

R.Assign(21, 13, 33, 14);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(18, 13, 21, 14);
  Dlg^.Insert(New(PLabel, Init(R, '2:', Control)));

R.Assign(36, 13, 48, 14);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(33, 13, 36, 14);
  Dlg^.Insert(New(PLabel, Init(R, '3:', Control)));

R.Assign(51, 13, 63, 14);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(48, 13, 51, 14);
  Dlg^.Insert(New(PLabel, Init(R, '4:', Control)));

R.Assign(66, 13, 78, 14);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);

  R.Assign(63, 13, 66, 14);
  Dlg^.Insert(New(PLabel, Init(R, '5:', Control)));



R.Assign(27, 14, 74, 15);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(12, 14, 27, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Свидетельство:', Control)));

R.Assign(27, 15, 74, 16);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(20, 15, 27, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'Девиз:', Control)));

R.Assign(27, 16, 74, 17);
Control := New(PInputLine, Init(R, 16));
Dlg^.Insert(Control);

  R.Assign(7, 16, 27, 17);
  Dlg^.Insert(New(PLabel, Init(R, 'Заголовок прайса 1:', Control)));

R.Assign(27, 17, 74, 18);
Control := New(PInputLine, Init(R, 16));
Dlg^.Insert(Control);

  R.Assign(7, 17, 27, 18);
  Dlg^.Insert(New(PLabel, Init(R, 'Заголовок прайса 2:', Control)));

R.Assign(27, 18, 74, 19);
Control := New(PInputLine, Init(R, 16));
Dlg^.Insert(Control);

  R.Assign(7, 18, 27, 19);
  Dlg^.Insert(New(PLabel, Init(R, 'Заголовок прайса 3:', Control)));



R.Assign(9, 19, 26, 20);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(6, 19, 9, 20);
  Dlg^.Insert(New(PLabel, Init(R, '~1~:', Control)));

R.Assign(9, 20, 26, 21);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(6, 20, 9, 21);
  Dlg^.Insert(New(PLabel, Init(R, '~2~:', Control)));

R.Assign(31, 19, 48, 20);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(28, 19, 31, 20);
  Dlg^.Insert(New(PLabel, Init(R, '~3~:', Control)));

R.Assign(31, 20, 48, 21);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(28, 20, 31, 21);
  Dlg^.Insert(New(PLabel, Init(R, '~4~:', Control)));

R.Assign(53, 19, 70, 20);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(50, 19, 53, 20);
  Dlg^.Insert(New(PLabel, Init(R, '~5~:', Control)));


R.Assign(53, 20, 70, 21);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(50, 20, 53, 21);
  Dlg^.Insert(New(PLabel, Init(R, '~6~:', Control)));


R.Assign(9, 21, 26, 22);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(6, 21, 9, 22);
  Dlg^.Insert(New(PLabel, Init(R, '~7~:', Control)));

R.Assign(31, 21, 48, 22);
Control := New(PInputLine, Init(R, 15));
Dlg^.Insert(Control);

  R.Assign(28, 21, 31, 22);
  Dlg^.Insert(New(PLabel, Init(R, '~8~:', Control)));

R.Assign(56, 21, 70, 22);
Control := New(PInputLine, Init(R, 12));
Dlg^.Insert(Control);

  R.Assign(49, 21, 56, 22);
  Dlg^.Insert(New(PLabel, Init(R, 'Ск~л~ад:', Control)));

R.Assign(72, 21, 78, 22);
Control := New(PInputLine, Init(R, 4));
Dlg^.Insert(Control);

  R.Assign(49, 20, 56, 21);
  Dlg^.Insert(New(PLabel, Init(R, ':', Control)));


Dlg^.SelectNext(False);
Dlg^.SetData(Rek);
c:=Desktop^.ExecView(Dlg);
If c <> cmCancel Then
    Begin
     Dlg^.GetData(Rek);
     Dispose(Control,Done);
     Dispose(Dlg,Done);
     WriteRek(c);
     If C<>0 Then Errors('Ошибка при записи файла реквизитов!');
     AddProtocol('Корректировка реквизитов предприятия !!! {Очень важно}','','');
    End
Else
 Begin
     Dispose(Control,Done);
     Dispose(Dlg,Done);
 End;
End;



Procedure InputToSklad;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  As : DocumentEdit;
begin
R.Assign(21, 8, 59, 14);
New(Dlg, Init(R, 'Поступление товара на склад'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

R.Assign(2, 2, 17, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('~П~риход',
  NewSItem('~В~озврат'
  , Nil))));
Dlg^.Insert(Control);

  R.Assign(1, 1, 16, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид документа:', Control)));

R.Assign(30, 2, 36, 3);
Control := New(PInputLine, Init(R, 4));
Dlg^.Insert(Control);

  R.Assign(18, 2, 30, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~Д~окумент N:', Control)));

R.Assign(25, 4, 35, 5);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(19, 4, 25, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Да~т~а:', Control)));

As:=Assistent;
As.Vid:=0;
As.D:=FDate;
Dlg^.SelectNext(False);
Dlg^.SetData(As);

c:=Desktop^.ExecView(Dlg);
Dlg^.GEtData(As);
Dispose(Control,Done);
Dispose(Dlg,Done);
DelSpace(As.EditPosition);
If As.EditPosition[0]=#0 Then
 Begin
  MessageBox(#3^m+#3'Не указан номер накладной!',Nil,mfError+mfCancelButton);
  Exit;
 End;
 DelZerro(As.EditPosition);
DelSpace(As.D);
If Not(TestOpenDAte1(As.d)) Then
 Begin
  MessageBox(#3^m+#3'Доступ к данным за '+As.D+' заблокирован!',Nil,mfError+mfCancelButton);
  Exit;
 End;

If C<>cmCancel Then
 Begin
  Case As.Vid Of
  0:InputPrihodToSklad(As);
  1:InputNewVozwratToSklad(As);
  2:{Вставит код ввода на склад ревизии}
  Else;
  End;
 End;
end;

Function TestClientList(Const P:PBox;s:AllStr):Boolean;
Var Ls : Word;
    St : AllStr;
Begin
TestClientList:=True;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
DelSpace(St);
DelSpace(s);
If (St=S) Then
   Begin
    TestClientList:=False;
    Break;
   End;
End;
End;


Function TestOplataClientFile(St : TDateString):Boolean;
VAr OplFile : OplataRealizasiaFileType;
    R : TRect;
    Opl :OplataRealizasiaType;
    i : Byte;
    TempList:PBox;
    Control : PView;
    Dlg : PDialog;
    fr : File Of RealizasiaType;
    E : PRealizasiaType;
    Find : Boolean;
    s : AllStr;
    c : Word;
Begin
DInfo('Анализ дебиторов...');
 TestOplataClientFile:=True;
 Assign (OplFile,Path.ToOplata+St+'.opl');
 i:=IOResult;
 Reset(OplFile);
 i:=IOResult;
 If i<>0 Then
  Begin
   NoInfo;
   MessageBox(#3^M+#3'Оплата консигнации '+st+' не проводилась!',Nil,mfInformation+mfCancelButton);
   Exit;
  End;

R.Assign(19, 4, 61, 19);
New(Dlg, Init(R, 'Внимание'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E300;
R.Assign(3, 1, 40, 3);
Control := New(PColoredText, Init(R, 'Обнаружены полностью оплаченные но н'+
     'е закрытые документы консигнации !!!', $74));
Dlg^.Insert(Control);

R.Assign(41, 4, 42, 14);
Control := New(PScrollBar, Init(R));
Dlg^.Insert(Control);

R.Assign(1, 4, 41, 14);
TempList := New(PBox, Init(R, 1, PScrollBar(Control)));
TempList^.NewList(New(PTextCollection, Init(0,1)));
Find := False;
While Not(Eof(OplFile)) Do
Begin
   {
   Repeat
   Until (Lock(OplFile,FilePos(OplFile)*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)));
   }
   ReadOplata(OplFile,Opl);
   {
   Repeat
    UnLock(OplFile,(FilePos(OplFile)-1)*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)*5);
   Until (DosError=0);
   }
 DelSpace(Opl.Document);
 Format(Opl.Document,CDocNumer);
 s:=Opl.ClientKod+'│'+Opl.Document+'│'+Opl.DateDoc;
 i:=IOResult;
 DelSpace(Opl.ClientKod);
(*
 Repeat
 Until SetClientLock(Opl.ClientKod,0{клиент а не склал},0{клиент а не склал});
*)
 Assign(fr,Path.ToDolg+Opl.CLientKod+'.dlg');
 Reset(fr);
 i:=IOResult;
 If (i=0) Then
 Begin
 New(E,Init);
 While Not(Eof(fr)) Do
  Begin
   Read(fr,E^.Dat);
   If (Abs(E^.Dat.Dolg)<0.01) And Not(E^.Dat.Full) And (E^.Dat.Market.Active) Then
    Begin
     s:=GetClientField(FClient,Opl.ClientKod,0);
     Format(s,CClient);
     Format(E^.DAt.MArket.Document,CDocNumer);
     s:=s+'│'+Opl.ClientKod+'│'+E^.DAt.MArket.Document+'│'+E^.DAt.MArket.DateC;
     If TestClientList(TempList,s) Then
      Begin
     TempList^.List^.Insert(NewStr(s));
     TempList^.SetRange(TempList^.List^.Count);
     Find:=True;
     TestOplataClientFile:=False;
      End;
    End;
  End;
  Close(fr);
  Dispose(E,Done);
 End;{i=0}
(*
 Repeat
 Until (SetClientUnLock(Opl.ClientKod,0,0));
*)

End;{While}
TempList^.FocusItem(0); {нашли фокус}
Dlg^.Insert(TempList);


  R.Assign(1, 3, 41, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Клиент               Код   N     Дата  ', TempList)));

NoInfo;

If Not(Find) Then
 Begin
Dispose(Control,Done);
Dispose(TempList,Done);
Dispose(Dlg,Done);
Exit;
 End;

Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);

Dispose(Control,Done);
Dispose(TempList,Done);
Dispose(Dlg,Done);
End;{Procedure}

Procedure SetupMarketDoc(j:byte);
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : LongInt;
  i : LongInt;
  MM1,mm2 : Maska9;
  k,Mas : Word;

begin
1:
R.Assign(24, 9, 56, 14);

If j=0 Then
New(Dlg, Init(R, 'Документы продажи'))
Else
New(Dlg, Init(R, 'Документы дебиторов'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(1, 1, 31, 4);
Control := New(PCheckboxes, Init(R,
  NewSItem('С~п~',
  NewSItem('~Т~Ч',
  NewSItem('~Ф~Л*',
  NewSItem('~С~Ф*',
  NewSItem('СФБ',
  NewSItem('~Д~*',
  NewSItem('Д СФ~*~',
  NewSItem('Д~',
  NewSItem('Д СФБ', Nil)))))))))));

If j=0 Then
   {PCluster(Control)^.SetButtonState($08, False)}
Else
   PCluster(Control)^.SetButtonState($1E4, False);

Dlg^.Insert(Control);


Dlg^.SelectNext(False);
If j=0 Then
Dlg^.SetData(MasDocNumer)
Else
Dlg^.SetData(DebitDocNumer);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(Mas);
  WordToBit9(Mas,MM1);
  k:=1;
For c:=Max9 Downto 1 Do
   Begin
    mm2[k]:=mm1[c];
    inc(k);
   End;
{
If MM[c+1]=1 Then MM[c+1]:=0
Else MM[c+1]:=1;
}

{mm2[2]:=1;}
If j=0 Then
Begin
mm2[4]:=1;
  If mm2[DefaultDoc+1]=0 Then
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   MessageBox(^M+#3'Сначала измените документ по умолчанию!',Nil,mfError+mfCancelButton);
   Goto 1;
  End;
  MasdOc:=MM2;
  MasDocNumer:=Mas;
End
Else
  DebitDocNumer:=Mas;
  WriteNewIni(c);
  If c<> 0 Then Errors('Ошибка записи файла конфигурации !')
  Else AddProtocol('Корректировка общих настроек системы!!!','','');

  Dispose(Control,Done);
  Dispose(Dlg,Done);

 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;

end;


Function WriteSpecialKassa(kk:PHiddenKassaType): Boolean;
Var kf : File Of HiddenKassaType;
    Ext : ArtikulStr;
    w : Byte;
Begin
WriteSpecialKassa:=False;

Str(StrToInt(Rek.Kod):2,Ext);
RFormatZerro(Ext,2);
Assign(kf,Path.ToArchiv+KassaDate+'.h'+Ext);
w:=IOResult;
Rewrite(kf);
w:=IOResult;
If w<>0 Then
 Begin
  MessageBox(^m+#3'Не могу создать файл '+Path.ToArchiv+KassaDate+'.h'+Ext,Nil,mfError+mfCancelButton);
  Exit;
 End;
w:=IOResult;
Seek(kf,0);
w:=IOResult;
Write(kf,kk^.Dat);
w:=IOResult;
Close(kf);
w:=IOResult;
WriteSpecialKassa:=True;
End;

Procedure TItogWindow.OpenViewItog;
 var
 R : TRect;
 Control : PView;
 c : Word;
 PromS,PromP,SSklad,ws,s1,s2,SkidkaK,SkidkaP : AllStr;
 s : String;
 RazdelSelect : PBox;
 M : MaskaNew
 ;
 VidaNoC:AllStr;
 VidanoCKol:ArtikulStr;
 VidanoCSkidki:AllStr;
 SkidkiOfC:AllStr;
 SkidkiOfCKol:ArtikulStr;
 ProdagiC :AllStr;
 ProdagiCKol :ArtikulStr;
 ProdagiCSkidki :AllStr;
 ProdagiS :AllStr;
 ProdagiSKol :ArtikulStr;
 RP :AllStr;
 RPKol :ArtikulStr;
 Sf :AllStr;
 SfKol :ArtikulStr;

 VidanoRashod:AllStr;
 VidanoRashodKol:AllStr;
 VidanoCRashod:AllStr;
 VidanoCRashodKol:AllStr;

 VidanoCSf:AllStr;
 VidanoCSfKol:ArtikulStr;
 VidanoCSfSkid:AllStr;
 VidanoCSfSkidKol:ArtikulStr;
 SkidkiOfCSf:AllStr;
 SkidkiOfCKolSf:ArtikulStr;

 Return:AllStr;
 ReturnKol : ArtikulStr;
 ReturnSkid:AllStr;
 ReturnSf  :AllStr;
 ReturnSfKol : ArtikulStr;
 ReturnSFSkid:AllStr;

 ReturnSfNAl  :AllStr;
 ReturnSfKolNAl : ArtikulStr;
 Temp,ReturnSFSkidNAl:AllStr;
 SpecNalogP,SpecNalogC,SNalogReturnOpenConsig : AllStr;
 Video : Boolean;
 BarterT,BarterSkidki : AllStr;

begin
DInfo('Минуточку...');

New(Kassa,Init);{создается экземпляр объекта кассовый лист}

If Password(3) Then Video:=True
Else Video:=False;

{Video :=True;}

R.Assign(0, 0, 80, 23);
New(Itog, Init(R, 'Итоги дня'));
Itog^.Options := Itog^.Options or ofTileable or ofCenterX or ofCenterY;
Itog^.Palette := dpBlueDialog;
Itog^.HelpCtx:=$F006{E555};

R.Assign(2, 2, 78, 10);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Itog^.Insert(Control);


R.Assign(2, 1, 21, 2);
Control := New(PColoredText, Init(R, ' Итоги консигнации ', $4F));
Itog^.Insert(Control);

R.Assign(2, 11, 78, 21);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Itog^.Insert(Control);


R.Assign(23, 10, 56, 11);
Control := New(PColoredText, Init(R, ' Итоги прихода/расхода на складе ', $4f));
Control^.Options := Control^.Options or ofCenterX;
Itog^.Insert(Control);




R.Assign(2, 0, 7, 1);
Control := New(PColoredText, Init(R, 'Дата:', $1F));
Itog^.Insert(Control);

R.Assign(7, 0, 24, 1);
If TestOpenDate1(FDate) Then
Control := New(PColoredText, Init(R, #3+FDate+' (ОТКРЫТ)', $1A))
Else
Control := New(PColoredText, Init(R, #3+FDate+' (ЗАКРЫТ)', $1A));
Itog^.Insert(Control);

R.Assign(52, 0, 58, 1);
Control := New(PColoredText, Init(R, 'Склад:', $1F));
Itog^.Insert(Control);

R.Assign(58, 0, 70, 1);
Control := New(PColoredText, Init(R, #3+GetClientField(FClient,Rek.Kod,1), $1A));
{Control := New(PColoredText, Init(R, #3+Rek.SkladsName, $1A));}
Itog^.Insert(Control);


New(KassaH,Init);


CalcAllNakl (FDate,VidaNoC,VidanoCKol,VidanoCSkidki,SkidkiOfC,SkidkiOfCKol,
ProdagiC, ProdagiCKol, ProdagiCSkidki, ProdagiS, ProdagiSKol, RP, RPKol,Sf,SfKol,
VidanoCSf,VidanoCSfKol,VidanoCSfSkid,VidanoCSfSkidKol,SkidkiOfCSf,SkidkiOfCKolSf,
SpecNalogP,SpecNalogC,BarterT,BarterKol,BarterSkidki);


Kassa^.Dat.BarterT:=BarterT;
DelSpace(Kassa^.Dat.BarterT);

Kassa^.Dat.BarterSkidki:=BarterSkidki;
DelSpace(Kassa^.Dat.BarterSkidki);




R.Assign(2, 2, 21, 3);
Control := New(PColoredText, Init(R, 'Выдано на консиг.Т', $1F));
Itog^.Insert(Control);

Str(StrToReal(VidaNoC)+StrToReal(VidanoCSkidki):CIZena:CMantissa,Temp);

{5}Kassa^.Dat.VidanoConsig:=Temp;
   DelSpace(Kassa^.Dat.VidanoConsig);

{6}Kassa^.Dat.SkVidanoConsig:=VidanoCSkidki;
   DelSpace(Kassa^.Dat.SkVidanoConsig);

R.Assign(2, 3, 21, 4);
Control := New(PColoredText, Init(R, Temp+' '+VidanoCKol, $5f));
Itog^.Insert(Control);

R.Assign(2, 4, 21, 5);
Control := New(PColoredText, Init(R, 'Скидки выд. консиг.', $1F));
Itog^.Insert(Control);

{DelSpace(VidanoCSkidki);}

R.Assign(2, 5, 21, 6);
Control := New(PColoredText, Init(R, VidanoCSkidki, $5F{1A}));
Itog^.Insert(Control);

R.Assign(2, 6, 21, 7);
Control := New(PColoredText, Init(R, 'Выдан.кон.со СФ Т', $1F));
Itog^.Insert(Control);

Str(StrToReal(VidaNoCSf)+StrToReal(VidanoCSfSkid):CIZena:CMantissa,Temp);

R.Assign(2, 7, 21, 8);
Control := New(PColoredText, Init(R, Temp+' '+VidanoCSfKol, $5F));
Itog^.Insert(Control);

R.Assign(2, 8, 21, 9);
Control := New(PColoredText, Init(R, 'Скид.выд.кон.со СФ', $1F));
Itog^.Insert(Control);

R.Assign(2, 9, 21, 10);
Control := New(PColoredText, Init(R, VidanoCSfSkid+' '+VidanoCSFSkidKol, $5F));
Itog^.Insert(Control);

R.Assign(22, 2, 41, 3);
Control := New(PColoredText, Init(R, 'Опл. конс.в кассу', $1F));
Itog^.Insert(Control);

s:=ViewOplReal(FDate,False);
s1:=Copy(s,1,CIZena);
{DelSpace(s1);
s1:=SClearChar(s1);}

{7}Kassa^.Dat.OplataINKassa :=s1;
   DelSpace(Kassa^.Dat.OplataINKassa);

If Video Then
Begin
R.Assign(22, 3, 41, 4);
Control := New(PColoredText, Init(R, s1, $30{1A}));
Itog^.Insert(Control);
End;

R.Assign(22, 4, 41, 5);
Control := New(PColoredText, Init(R, 'Скидки оф. консигн.', $1F));
Itog^.Insert(Control);


{8}Kassa^.Dat.SkOformConsign :=SkidkiOfC;
   DelSpace(Kassa^.Dat.SkOformConsign);


R.Assign(22, 5, 41, 6);
Control := New(PColoredText, Init(R, SkidkiOfC+' '+SkidkiOfCKol, $30{1A}));

Itog^.Insert(Control);

R.Assign(22, 6, 41, 7);
Control := New(PColoredText, Init(R, 'Опл.конс.СФ в кас.', $1F));
Itog^.Insert(Control);

s1:=Copy(s,1+CIZena+1,CIZena);
{DelSpace(s1);
s1:=SClearChar(s1);}

R.Assign(22, 7, 41, 8);
Control := New(PColoredText, Init(R, s1, $30));
Itog^.Insert(Control);

R.Assign(22, 8, 41, 9);
Control := New(PColoredText, Init(R, 'Скид.оф.кон.со СФ', $1F));
Itog^.Insert(Control);

R.Assign(22, 9, 41, 10);
Control := New(PColoredText, Init(R, SkidkiOfCSf+' '+SkidkiOfCKolSf, $30));
Itog^.Insert(Control);

s:=CalcDolgDebit(2,False);
Str(StrToReal(Copy(S,1,CIZena)){-StrToREal(copy(s,1+CIZena+1,CIZena))}:CIZena:CMantissa,skidkaK);
{DelSpace(SkidkaK);}

R.Assign(42, 2, 59, 3);
Control := New(PColoredText, Init(R, 'Остатат.консиг.Т', $1F));
Itog^.Insert(Control);

{13}Kassa^.Dat.OstatokConsig :=SkidkaK;
    DelSpace(Kassa^.Dat.OstatokConsig);

R.Assign(42, 3, 58, 4);
Control := New(PColoredText, Init(R, skidkaK, $71{1A}));
Itog^.Insert(Control);

s1:=copy(s,1+CIZena+1,CIZena);
{DelSpace(s1);}

{14}Kassa^.Dat.SkOstatokConsig :=s1;
    DelSpace(KAssa^.DAt.skOstatokConsig);

R.Assign(42, 4, 58, 5);
Control := New(PColoredText, Init(R, 'Скид.ост.консиг.', $1F));
Itog^.Insert(Control);

R.Assign(42, 5, 58, 6);
Control := New(PColoredText, Init(R, S1, $71));
Itog^.Insert(Control);


s1:=copy(s,1+CIZena+1+CIZena+1,CIZena);
{DelSpace(s1);}

R.Assign(42, 6, 59, 7);
Control := New(PColoredText, Init(R, 'Ост.конс. прих.', $1F));
Itog^.Insert(Control);               {Ост.конс. С/Ф Т}

R.Assign(42, 7, 58, 8);
Control := New(PColoredText, Init(R, S1, $71));
Itog^.Insert(Control);

s1:=copy(s,1+CIZena+1+CIZena+1+CIZena+1,CIZena);
{DelSpace(s1);}


R.Assign(42, 8, 58, 9);
Control := New(PColoredText, Init(R, 'Скид.ос.кон.прх', $1F));
Itog^.Insert(Control);

R.Assign(42, 9, 58, 10);
Control := New(PColoredText, Init(R, s1, $71));
Itog^.Insert(Control);


{расход по возврату}
CalcRashodfromVozwrat(FDate,VidanoRashod,VidanoRashodKol,VidanoCRashod,VidanoCRashodKol);

R.Assign(21, 1, 29, 2);
Control := New(PColoredText, Init(R, 'Рсх.взв:', $1F));
Itog^.Insert(Control);

{19}Kassa^.Dat.RashodFromReturn :=VidanoRashod;
    DelSpace(Kassa^.Dat.RashodFromReturn);


If Video Then
Begin
R.Assign(29, 1, 48, 2);
Control := New(PColoredText, Init(R, VidanoRashod+' '+VidanoRashodKol, $70));
Itog^.Insert(Control);
End;

R.Assign(49, 1, 59, 2);
Control := New(PColoredText, Init(R, 'Рсх.от.к.:', $1F));
Itog^.Insert(Control);

{??}Kassa^.Dat.RashodFromReturnOpenConsig :=VidanoCRashod;
    DelSpace(Kassa^.Dat.RashodFromReturnOpenConsig);

If Video Then
Begin
R.Assign(59, 1, 78, 2);
Control := New(PColoredText, Init(R, VidanoCRashod+' '+VidanoCRashodKol, $70));
Itog^.Insert(Control);
End;

CalcVozwratfromConsig(FDate,Return, ReturnKol ,ReturnSkid,ReturnSf,
ReturnSfKol, ReturnSFSkid,SNalogReturnOpenConsig);

R.Assign(59, 2, 78, 3);
Control := New(PColoredText, Init(R, 'Возв.по консиг.Т', $1F));
Itog^.Insert(Control);

{9}Kassa^.Dat.ReturnOutOpenConsig:=Return;
   DelSpace(Kassa^.Dat.ReturnOutOpenConsig);

{30}Kassa^.Dat.SNalogReturnOpenConsig:=SNalogReturnOpenConsig;
   DelSpace(Kassa^.Dat.SNalogReturnOpenConsig);

R.Assign(59, 3, 78, 4);
Control := New(PColoredText, Init(R, Return+' '+ReturnKol, $6F));

Itog^.Insert(Control);

R.Assign(59, 4, 78, 6);
Control := New(PColoredText, Init(R, 'Скид.возв.по конс.', $1F));
Itog^.Insert(Control);

{10}Kassa^.Dat.SkReturnOutOpenConsig :=ReturnSkid;
    DelSpace(Kassa^.Dat.SkReturnOutOpenConsig);


R.Assign(59, 5, 78, 6);
Control := New(PColoredText, Init(R, ReturnSkid, $6F));
Itog^.Insert(Control);

R.Assign(59, 6, 78, 7);
Control := New(PColoredText, Init(R, 'Возв.по конс.СФ Т', $1F));
Itog^.Insert(Control);

R.Assign(59, 7, 78, 8);
Control := New(PColoredText, Init(R, ReturnSf+' '+ReturnSfKol, $6F));
Itog^.Insert(Control);

R.Assign(59, 8, 78, 9);
Control := New(PColoredText, Init(R, 'Скид.возв.конс.СФ', $1F));
Itog^.Insert(Control);

R.Assign(59, 9, 78, 10);
Control := New(PColoredText, Init(R, ReturnSfSkid, $6F));
Itog^.Insert(Control);

R.Assign(2, 11, 21, 12);
Control := New(PColoredText, Init(R, 'Продажи (клиент) Т', $1F));
Itog^.Insert(Control);


Str(StrToReal(ProdaGiC)+StrToReal(ProdagiCSkidki):CIZena:CMantissa,Temp);

{40}Kassa^.Dat.Prodagi :=Temp;
    DelSpace(Kassa^.Dat.Prodagi);

If Video Then
Begin
R.Assign(2, 12, 21, 13);
Control := New(PColoredText, Init(R, Temp+' '+ProdagiCKol, $70{1A}));
Itog^.Insert(Control);
End;

R.Assign(2, 15, 16, 16);
Control := New(PColoredText, Init(R, 'Скидки продажи', $1F));
Itog^.Insert(Control);

{DelSpace(ProdagiCSkidki);}

{41}Kassa^.Dat.SkProdagi :=ProdagiCSkidki;
    DelSpace(Kassa^.Dat.SkProdagi);


If Video Then
Begin
R.Assign(2, 16, 21, 17);
Control := New(PColoredText, Init(R, ProdagiCSkidki, $70{1A}));
Itog^.Insert(Control);
End;

R.Assign(2, 13, 21, 14);
Control := New(PColoredText, Init(R, 'Отгрузка (склад)', $1F));
Itog^.Insert(Control);

R.Assign(2, 14, 21, 15);
Control := New(PColoredText, Init(R, ProdagiS+' '+ProdagiSKol, $70{1A}));
Itog^.Insert(Control);


R.Assign(2, 17, 12, 18);
Control := New(PColoredText, Init(R, 'Переоценка', $1F));
Itog^.Insert(Control);

s:=ViewAllAktPrz(FDate,False,0);
ws:=Copy(s,1,CIZena);
s:=Copy(s,1+CIZena+1,CLitrMantissa);

{15}Kassa^.Dat.Pereozenka:=ws;
    DelSpace(Kassa^.Dat.Pereozenka);


R.Assign(2, 18, 21, 19);
Control := New(PColoredText, Init(R, ws+' '+s, $4F));
Itog^.Insert(Control);

R.Assign(2, 19, 21, 20);
Control := New(PColoredText, Init(R, 'Переоценка по возв.', $1F));
Itog^.Insert(Control);

s:=ViewAllAktPrz(FDate,False,1);
ws:=Copy(s,1,CIZena);
s:=Copy(s,1+CIZena+1,CLitrMantissa);

{16}Kassa^.Dat.PereozenkaFromReturn:=ws;
    DelSpace(Kassa^.Dat.PereozenkaFromReturn);

R.Assign(2, 20, 21, 21);
Control := New(PColoredText, Init(R, ws+' '+s, $4F));
Itog^.Insert(Control);

R.Assign(22, 11, 37, 12);
Control := New(PColoredText, Init(R, 'Приход (клиент)', $1F));
Itog^.Insert(Control);

s1:=ViewAllPrihod(FDate,False,0);

ws:=Copy(s1,1,CIZena);
s:=Copy(s1,1+CIZena+1,CIZena);
s2:=Copy(s1,1+CIZena+1+CIZena+1,CLitrMAntissa);
s1:=Copy(s1,1+CIZena+1+CIZena+1+CLitrMantissa+1,CLitrMantissa);

{1}Kassa^.Dat.Prihod :=ws;
   DelSpace(Kassa^.Dat.Prihod);

R.Assign(22, 12, 41, 14);
Control := New(PColoredText, Init(R, ws+' '+s2+^M+
                                                           s+' '+s1, $3F{1A}));
Itog^.Insert(Control);

R.Assign(22, 14, 41, 15);
Control := New(PColoredText, Init(R, 'Приход межскладской', $1F));
Itog^.Insert(Control);

s1:=ViewAllPrihod(FDate,False,1);
ws:=Copy(s1,1,CIZena);
s:=Copy(s1,1+CIZena+1,CIZena);
s2:=Copy(s1,1+CIZena+1+CIZena+1,CLitrMAntissa);
s1:=Copy(s1,1+CIZena+1+CIZena+1+CLitrMantissa+1,CLitrMantissa);

R.Assign(22, 15, 41, 17);
Control := New(PColoredText, Init(R,ws+' '+s2+^M+
                                                         s+' '+s1, $3F{1A}));
Itog^.Insert(Control);

R.Assign(42, 11, 59, 12);
Control := New(PColoredText, Init(R, 'Возврат(клиент)Т', $1F));
Itog^.Insert(Control);

s1:=NewViewAllVozwrat(FDate,False,0);
ws:=Copy(s1,1,CIZena);
s:=Copy(s1,1+CIZena+1,CIZena);
s2:=Copy(s1,1+CIZena+1+CIZena+1,CLitrMAntissa);
s1:=Copy(s1,1+CIZena+1+CIZena+1+CLitrMantissa+1,CLitrMantissa);

R.Assign(42, 12, 61, 14);
Control := New(PColoredText, Init(R,ws+' '+s2+^M+
                                                          s+' '+s1 , $6F{1A}));
Itog^.Insert(Control);


R.Assign(42, 14, 61, 15);
Control := New(PColoredText, Init(R, 'Возврат межскладс.Т', $1F));
Itog^.Insert(Control);

s1:=NewViewAllVozwrat(FDate,False,1);
ws:=Copy(s1,1,CIZena);
s:=Copy(s1,1+CIZena+1,CIZena);
s2:=Copy(s1,1+CIZena+1+CIZena+1,CLitrMAntissa);
s1:=Copy(s1,1+CIZena+1+CIZena+1+CLitrMantissa+1,CLitrMantissa);


R.Assign(42, 15, 61, 17);
Control := New(PColoredText, Init(R, ws+' '+s2+^M+
                                                           s+' '+s1, $6F{1A}));
Itog^.Insert(Control);

{R.Assign(42, 17, 57, 18);}
R.Assign(63, 15, 78, 16);
Control := New(PColoredText, Init(R, 'Сумма со склада', $1F));
Itog^.Insert(Control);


Str(StrToReal(VidaNoC)+StrToReal(ProdagiC)+StrToReal(ProdagiCSkidki)+StrToReal(VidanoCSkidki)
:CIZena:CMantissa,s);

{4} Kassa^.Dat.SummaOutSklad:=s;
DelSpace(Kassa^.Dat.SummaOutSklad);


{R.Assign(42, 18, 61, 19);}
R.Assign(63, 16, 78, 17);
Control := New(PColoredText, Init(R, s, $3E));
Itog^.Insert(Control);

R.Assign(22, 17, 32, 18);
Control := New(PColoredText, Init(R, 'Р/П работы', $1F));
Itog^.Insert(Control);

{3}Kassa^.Dat.RP:=Rp;
   DelSpace(Kassa^.Dat.RP);

R.Assign(22, 18, 41, 19);
Control := New(PColoredText, Init(R, Rp+' '+RpKol, $3E));
Itog^.Insert(Control);

R.Assign(0, 0, 0, 0);
RazdelSelect := New(PBox, Init(R, 1, Nil));
RazdelSelect^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path.ToRazdel+'razdel.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
   Begin
    Format (RazdelElement.Name,CClient);
    RazdelSelect^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
   End;
 End;
System.Close(RazdelFile);
RazdelSelect^.FocusItem(0);
Itog^.Insert(RazdelSelect);

For c:=1 To 8 Do m[c]:=1;

Ssklad:=PrintSklad_Or_Prise(False,0,RazdelSelect,M,0,0,0,0,0);

{Dispose(RazdelSelect,Done);}

{R.Assign(42, 19, 59, 20);}
R.Assign(63, 17, 78, 18);
Control := New(PColoredText, Init(R, 'Остаток на скл.', $1F));
Itog^.Insert(Control);

{2}Kassa^.Dat.Ostatok:=SSklad;
   DelSpace(Kassa^.Dat.Ostatok);

{R.Assign(42, 20, 61, 21);}
R.Assign(63, 18, 78, 19);
Control := New(PColoredText, Init(R, SSklad, $3E));
Itog^.Insert(Control);

R.Assign(22, 19, 41, 20);
Control := New(PColoredText, Init(R, #3+'E.Y.E.', $1F));
Itog^.Insert(Control);


{24}Kassa^.Dat.VidanoSF:=Sf;
    DelSpace(Kassa^.Dat.VidanoSF);

R.Assign(22, 20, 41, 21);
Control := New(PColoredText, Init(R, Sf+' '+SfKol, $3E));
Itog^.Insert(Control);


CalcVozwratfromSfNal(FDate,ReturnSfNal,ReturnSfKolNal, ReturnSFSkidNal);

R.Assign(42, 18, 61, 19);
Control := New(PColoredText, Init(R,ReturnSfNal+' '+ReturnSfKolNal, $6F));
Itog^.Insert(Control);

R.Assign(42, 17, 61, 18);
Control := New(PColoredText, Init(R, 'Возврат по СФ пр.Т', $1F));
Itog^.Insert(Control);

R.Assign(42, 19, 61, 20);
Control := New(PColoredText, Init(R, 'Всего возврат СФ Т', $1F));
Itog^.Insert(Control);


Str(StrToReal(ReturnSfNal)+StrToReal(ReturnSf):CIZena:CMantissa,s1);
Str(StrToInt(ReturnSfKolNal)+StrToInt(ReturnSfKol):CLitrMantissa,s2);

R.Assign(42, 20, 61, 21);
Control := New(PColoredText, Init(R, s1+' '+s2, $6E));
Itog^.Insert(Control);


s1:=ViewAllRewisia(FDate,True,2);
s2:=Copy(s1,1,CIZena);

{25}Kassa^.Dat.Rewisia:=s2;
    DelSpace(Kassa^.Dat.Rewisia);

R.Assign(63, 19, 78, 20);
Control := New(PColoredText, Init(R, 'Всего ревизия', $1F));
Itog^.Insert(Control);

R.Assign(63, 20, 78, 21);
Control := New(PColoredText, Init(R, s2, $70));
Itog^.Insert(Control);

s2:=Copy(s1,1+CIZena+1,CLitr);
DelSpace(s2);

R.Assign(75, 21, 78, 22);
Control := New(PColoredText, Init(R, #3+s2, $70));
Itog^.Insert(Control);


CalcVozwratfromNal(FDate,ReturnSfNal,ReturnSfKolNal, ReturnSFSkidNal);

R.Assign(62, 11, 78, 12);
Control := New(PColoredText, Init(R, 'Возв.пр,оф.кон.Т', $1F));
Itog^.Insert(Control);

{11}Kassa^.Dat.ReturnOutMArketDocAndCloseConsig :=ReturnSFNAl;
    DelSpace(Kassa^.Dat.ReturnOutMArketDocAndCloseConsig);

R.Assign(63, 12, 78, 13);
Control := New(PColoredText, Init(R, ReturnSFNal, $6E));
Itog^.Insert(Control);

R.Assign(62, 13, 78, 14);
Control := New(PColoredText, Init(R, 'Ск.возв.пр,оф.к.', $1F));
Itog^.Insert(Control);

{12}Kassa^.Dat.SkReturnOutMArketDocAndCloseConsig :=ReturnSFSkidNAl;
    DelSpace(Kassa^.Dat.SkReturnOutMArketDocAndCloseConsig);


R.Assign(63, 14, 78, 15);
Control := New(PColoredText, Init(R, ReturnSFSkidNal, $6E));
Itog^.Insert(Control);

R.Assign(1, 22, 10, 23);
Control := New(PStaticText, Init(R, ' НП прод:'));
Itog^.Insert(Control);

DelSpace(SpecNalogP);
If Video Then
Begin
R.Assign(10, 22, 25, 23);
Control := New(PColoredText, Init(R, #3+SpecNalogP, $5E));
Itog^.Insert(Control);
End;

{28}Kassa^.Dat.SNalogP :=SpecNalogP;
    DelSpace(Kassa^.Dat.SNalogP);

R.Assign(25, 22, 39, 23);
Control := New(PStaticText, Init(R, ' НП выд.конс.:'));
Itog^.Insert(Control);

DelSpace(SpecNalogC);
R.Assign(39, 22, 54, 23);
Control := New(PColoredText, Init(R, #3+SpecNAlogC, $5E));
Itog^.Insert(Control);

{29}Kassa^.Dat.SNalogC :=SpecNalogC;
    DelSpace(Kassa^.Dat.SNalogC);


R.Assign(54, 22, 67, 23);
Control := New(PStaticText, Init(R, ' НП взв.о.к.:'));
Itog^.Insert(Control);


DelSpace(SNalogReturnOpenConsig);
If Video Then
Begin
R.Assign(67, 22, 79, 23);
Control := New(PColoredText, Init(R, #3+SNalogReturnOpenConsig, $5E));
Itog^.Insert(Control);
End;

{30}Kassa^.Dat.SNalogReturnOpenConsig :=SNalogReturnOpenConsig;
    DelSpace(Kassa^.Dat.SNalogReturnOpenConsig);





With KassaH^.Dat Do
Begin
CalcSpecialKassa(
{2}                             OstatokZ ,
                                 PrihodZ ,
{26}                            RewisiaZ ,
                                 ReturnZ ,
                               MinusDohod,
                                 AllDohod,
                                AllDohodA,
                                  AllDolg,
                                 AllDolgA,
                           DolgiIstekshie,
  					        DolgiVse,
                         PlategiIstekshie,
                               PlategiVse);
Str(StrToreal(KAssa^.Dat.OstatokConsig)-
StrToreal(KAssa^.Dat.skOstatokConsig)
:CIZena:CMAntissa,DolgiVse);
DelSpace(DolgiVse);
Str(StrToreal(DolgiIstekshie):CIZena:CMAntissa,DolgiIstekshie);
DelSpace(DolgiIstekshie);
Str(StrToreal(PlategiIstekshie):CIZena:CMAntissa,PlategiIstekshie);
DelSpace(PlategiIstekshie);
Str(StrToreal(PlategiVse):CIZena:CMAntissa,PlategiVse);
DelSpace(PlategiVse);



s1:=ViewAllPrihod(FDate,False,2);

ws:=Copy(s1,1,CIZena);
 s:=Copy(s1,1+CIZena+1,CIZena);
s2:=Copy(s1,1+CIZena+1+CIZena+1,CLitrMAntissa);
s1:=Copy(s1,1+CIZena+1+CIZena+1+CLitrMantissa+1,CLitrMantissa);

{1}Kassa^.Dat.BarterPrihodRZ :=ws;
   DelSpace(Kassa^.Dat.BarterPrihodRZ);
   BarterPrhKolRZ:=s2;
   NoInputBarterPrhRZ:=s;
   NoInputBarterPrhKolRZ:=s1;

s1:=CAlcPrihodBarter(FDate);

ws:=Copy(s1,1,CIZena);
s2:=Copy(s1,1+CIZena+1,CLitrMAntissa);
{1}Kassa^.Dat.BarterPrihod :=ws;
   DelSpace(Kassa^.Dat.BarterPrihod);
   BarterPrhKol:=s2;

ws:=CalcDolgBarter(False);
{1}Kassa^.Dat.OstatokBarter:=ws;
   DelSpace(Kassa^.Dat.OstatokBarter);

s1:=ViewOplBarter(FDate,False);
ws:=Copy(s1,1,CIZena);
s1:=copy(s1,1+CIZena+1,CIZena);
{1}Kassa^.Dat.BarterInKassa:=ws;
   DelSpace(Kassa^.Dat.BarterInKassa);
{1}Kassa^.Dat.BarterOutKassa:=s1;
   DelSpace(Kassa^.Dat.BarterOutKassa);



End;



R.Assign(71, 0, 79, 1);
Control := New(PColoredText, Init(R, #3+'[E.Y.E.]', $1B));
Itog^.Insert(Control);

Itog^.SelectNext(False);
NoInfo;
ShowKassa:=False;
c:=Desktop^.ExecView(Itog);

Dispose(Kassa,Done);{уничтожаем экземпляр объекта кассовый лист}
If ShowKassa Then Begin
                   WriteSpecialKassa(KassaH);
                  End;
Dispose(KassaH,Done);{уничтожаем экземпляр объекта кассовый лист}
Dispose(Control,Done);
Dispose(Itog,Done);
If ShowKassa Then Begin
                   ViewKassa(True,KassaDAte);
                  End;
end;



Destructor TItogWindow.Done;
Begin
TDialog.Done;
End;

procedure TItogWindow.HandleEvent(var Event: TEvent);
{
procedure Calculator;
Var Control : PDialog;
begin
  control:=New(PCalculator, Init);
  Desktop^.Execview(Control);
  Dispose(Control,Done);
end;
}

procedure Calculator;
begin
  Calc^.Start;
end;


Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
        cmItogBarter:BarterItog^.OpenViewBarterItog;
        cmFormKassa:Begin
                    If Not(TestOpenDate1(FDate)) Or (StrToInt(CurrentPassword)=0) Then
                     Begin
{$IFDEF NetVersion}
If (StrToInt(CurrentPassword)<>0) And FindPAram('/NOCLOSE') Then
Begin
 MessageBox(^M+#3'С этой рабочей станции нельзя заполнять контрольный кассовый лист!',Nil,mfError+mfCancelButton);
 Exit;
End;
{$EndIF}

                      If (StrToInt(CurrentPassword)<>0) Then
                      MessageBox(#3+'ОБРАЩАЮ Ваше внимание - кассовый лист заполняется ТОЛЬКО ОДИН РАЗ!'^M+
                                  #3+'Будьте внимательней!',Nil,mfInformation+
                                  mfCancelButton);
                      kw^.start(False);
                     End
(*
                    If Not(TestOpenDate1(FDate)) Then
                     Begin
                      MessageBox(#3+'ОБРАЩАЮ Ваше внимание - кассовый лист заполняется ТОЛЬКО ОДИН РАЗ!'^M+
                                  #3+'Будьте внимательней!',Nil,mfInformation+
                                  mfCancelButton);
                      kw^.start(False);
                     End
*)
                    Else
                     Begin
{$IFDEF NetVersion}
If (StrToInt(CurrentPassword)<>0) And FindPAram('/NOCLOSE') Then
Begin
 MessageBox(^M+#3'С этой рабочей станции нельзя заполнять контрольный кассовый лист!',Nil,mfError+mfCancelButton);
 Exit;
End;
{$EndIf}
                      MessageBox(#3'Кассовый лист заполняется только после закрытия дня'^M+
                                  #3+'и ОБРАЩАЮ Ваше внимание - ТОЛЬКО ОДИН РАЗ',Nil,mfError+mfCancelButton);
                     End;
                      ClearEvent(Event);
                     End;
   Else;
   End;

 evKeyDown :
   Case Event.KeyCode Of
       kbAltRusK : Begin
                    Event.What:=EvCommand;
                    Event.Command:=cmLocalCalc;
                       PutEvent(Event);
                   End;
   Else;
   End;
    Else;
    End;

  Inherited HandleEvent(Event);
  {ClearEvent(Event);}
End;


Function WriteKassaToFile(kk:PKassaType;Mode:Boolean): Boolean;
Var kf : File Of KassaType;
    Ext : ArtikulStr;
    w : Byte;
Begin
WriteKassaToFile:=False;
Kk^.Dat.EPerewoskiInp[0]:=#0;
Kk^.Dat.EPerewoskiOut[0]:=#0;
For w:=0 To 6 Do
 Begin
  Str(StrToReal(Kk^.Dat.PerewoskiInp[w])+StrToReal(Kk^.Dat.EPerewoskiInp):CIZena:CMAntissa,
  Kk^.Dat.EPerewoskiInp);
  Str(StrToReal(Kk^.Dat.PerewoskiOut[w])+StrToReal(Kk^.Dat.EPerewoskiOut):CIZena:CMAntissa,
  Kk^.Dat.EPerewoskiOut);
 End;

Str(StrToInt(Rek.Kod):2,Ext);
RFormatZerro(Ext,2);
Assign(kf,Path.ToArchiv+KassaDate+'.k'+Ext);
w:=IOResult;
Rewrite(kf);
w:=IOResult;
If w<>0 Then
 Begin
  MessageBox(^m+#3'Не могу создать файл '+Path.ToArchiv+KassaDate+'.k'+Ext,Nil,mfError+mfCancelButton);
  Exit;
 End;
Seek(kf,0);
Write(kf,kk^.Dat);
Close(kf);
If Not(Mode) Then
AddProtocol('Ввод контрольного кассового листа склада за '+KassaDate,'','')
Else
AddProtocol('Корректировка контрольного кассового листа склада за '+KassaDate,'','');
MessageBox(^M+#3'Контрольный кассовый лист успешно сохранен!',Nil,mfInformation+mfCancelButton);
WriteKassaToFile:=True;
End;


Procedure RunTest(kk:PKassaType);
Var kf : File Of KassaType;
    ktest : PKassaType;
    OstatokKassa,SummaKassa,OstatokC,OstatokB,OstatokS : String[CIZena+1];
    w,i,j : LongInt;
    c : Word;
    res : Real;
    s : DateSTring;
    Ext : ArtikulStr;
    Find : Boolean;
    R : TRect;
    Control : PView;
    Dlg : PDialog;

Begin
Str(StrToInt(Rek.Kod):2,Ext);
RFormatZerro(Ext,2);
Find:=FAlse;
i:=DAteStringToDate(DateMask,KassaDate);
j:=i-10;

 While Not(Find) and (i>=j) Do
  Begin
   Dec(i);
   s:=DAteToDateString(DateMask,i);
   s:=s+'.k'+Ext;
   w := IOResult;
   Assign(kf,Path.ToArchiv+s);
   Reset(kf);
   w:=IOResult;
   If (w=0) Then Find:=True;
  End;

If Not(Find) Then
Begin
 MessageBox(^M+#3'Не могу провести проверку т.к. не найдено ни одного файла за последние 10 дней!',
 Nil,mfError+mfCancelButton);
 Exit;
End;



New(kTest,Init);
w:=IOResult;
Read(kf,KTest^.Dat);
w:=IOResult;
If W<>0 Then
Begin
 Dispose(kTest,Done);
 MessageBox(^M+#3'Ошибка чтения файла '+Path.ToArchiv+s,Nil,mfError+mfCancelButton);
 Close(kf);
 Exit;
End;
Close(kf);


SummaKAssa[0]:=#0;
OstatokKAssa[0]:=#0;
OstatokS[0]:=#0;
OstatokC[0]:=#0;
OstatokB[0]:=#0;

Kk^.Dat.EPerewoskiInp[0]:=#0;
Kk^.Dat.EPerewoskiOut[0]:=#0;
For j:=0 To 6 Do
 Begin
  Str(StrToReal(Kk^.Dat.PerewoskiInp[j])+StrToReal(Kk^.Dat.EPerewoskiInp):CIZena:CMAntissa,
  Kk^.Dat.EPerewoskiInp);
  Str(StrToReal(Kk^.Dat.PerewoskiOut[j])+StrToReal(Kk^.Dat.EPerewoskiOut):CIZena:CMAntissa,
  Kk^.Dat.EPerewoskiOut);
 End;

{Начинаем тестирование}

{сумма в кассе}
With kk^.Dat Do
Begin

Str(STrToReal(SummaInKassa)
-  (StrToReal(Prodagi)
-   StrToReal(SkProdagi)
+   StrToReal(OplataINKassa)
+   StrToReal(Sertifikat)
+   StrToReal(ExtendedDohod)
-   StrToReal(RAshod)
-   StrToReal(RAshodFromReturn)
{-   StrToReal(SkOformConsign)}
+   StrToReal(KTest^.DAt.OstatokInKAssa)
+   StrToReal(SNalogP)  ):CIZena+1:CMAntissa,SummaKAssa);

If (Abs(StrToReal(SummaKAssa))<0.01) Then SummaKassa:='Ок';
DelSpace(SummaKassa);
End;

{Остаток в кассе}
With kk^.Dat Do
Begin

Str(StrToReal(OstatokInKassa)
-  (StrToReal(SummaInKassa)
-   StrToReal(Sdano)
   )
   :CIZena+1:CMAntissa,OstatokKAssa);

If (Abs(StrToReal(OstatokKAssa))<0.01) Then OstatokKassa:='Ок';
DelSpace(OstatokKassa);
End;



{Остаток на складе}
With kk^.Dat Do
Begin
Str(StrToReal(OStatok)
-  (StrToReal(kTest^.DAt.OStatok)
+   StrToReal(Prihod)
+   StrToReal(BarterPrihodRZ)
+   StrToReal(EPerewoskiInp)
-   StrToReal(EPerewoskiOut)
-   StrToReal(RP)
-   StrToReal(Prodagi)
-   StrToReal(VidanoConsig)
-   StrToReal(BarterT)
+   StrToReal(Rewisia)
+   StrToReal(Pereozenka)
+   StrToReal(PereozenkaFromReturn)
+   StrToReal(ReturnOutMArketDocAndCloseConsig)
+   StrToReal(ReturnOutOpenConsig))
   :CIZena+1:CMantissa,OstatokS);
If (Abs(StrToReal(OstatokS))<0.01) Then OstatokS:='Ок';
DelSpace(OstatokS);
End;



{Сальдо бартера}
With kk^.Dat Do
Begin
Str(StrToReal(OstatokBarter)
-   StrToReal(kTest^.DAt.OstatokBarter)
+   StrToReal(BarterPrihod)
+   StrToReal(BarterINKassa)
-   StrToReal(BarterOutKassa)
-   StrToReal(BarterT)
+   StrToReal(BarterSkidki):CIZena+1:CMantissa,OstatokB);
If (Abs(StrToReal(OstatokB))<0.01) Then OstatokB:='Ок';
DelSpace(OstatokB);
End;



{Остаток консигнации}
With kk^.Dat Do
Begin
Str(StrToReal(OstatokConsig)
-  (StrToReal(kTest^.DAt.OstatokConsig)
+   StrToReal(VidanoConsig)
+   StrToReal(SNalogC)
-   StrToReal(OplataINKassa)
-   StrToReal(SkOformConsign)
-   StrToReal(ReturnOutOpenConsig)
-   StrToReal(SNalogReturnOpenConsig)
+   StrToReal(RashodFromReturnOpenConsig))
    :CIZena+1:CMantissa,OstatokC);
If (Abs(StrToReal(OstatokC))<0.01) Then OstatokC:='Ок';
DelSpace(OstatokC);
End;
{конец тестирование}

Dispose(KTest,Done);

{Вывод на экран результатов}
R.Assign(21, 7, 59, 15);
New(Dlg, Init(R, 'Результаты тестирования'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E090;

R.Assign(1, 1, 22, 6);
Control := New(PColoredText, Init(R, '   Остаток на складе:'^M+
     ' Остаток консигнации:'^M+
     '       Сумма в кассе:'^M+
     '     Остаток в кассе:'^M+
     '   Сальдо по бартеру:',$30));
Dlg^.Insert(Control);

R.Assign(22, 1, 37, 2);
Control := New(PColoredText, Init(R, #3+OstatokS, $3E));
Dlg^.Insert(Control);

R.Assign(22, 2, 37, 3);
Control := New(PColoredText, Init(R, #3+OstatokC, $3E));
Dlg^.Insert(Control);

R.Assign(22, 3, 37, 4);
Control := New(PColoredText, Init(R, #3+SummaKassa, $3E));
Dlg^.Insert(Control);

R.Assign(22, 4, 37, 5);
Control := New(PColoredText, Init(R, #3+OstatokKAssa, $3E));
Dlg^.Insert(Control);

R.Assign(22, 5, 37, 6);
Control := New(PColoredText, Init(R, #3+OstatokB, $3E));
Dlg^.Insert(Control);

R.Assign(2, 6, 36, 7);
s:=DAteToDateString(DateMask,i);
Control := New(PStaticText, Init(R, 'Использовались данные за '+s));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);
Dispose(Control,Done);
Dispose(Dlg,Done);
{закрытие окна результатов теста}
End;


{$IfDef DPMI}

Procedure TKassaWindow.Start(Mode:Boolean);
var
  R : TRect;
  Control : PView;
  PrevKassa,KK : PKAssaType;
  c : Word;
  s : AllStr;
  Regim : Boolean;
  FK : File Of KassaType;
  Video : Boolean;

begin
Str(StrToInt(Rek.Kod):2,s);
RFormatZerro(s,2);
KassaDate:=FDate;
If Not(Mode) Then
Begin
Assign(fk,Path.ToArchiv+KassaDate+'.k'+s);
c:=IOResult;
Reset(fk);
c:=IOResult;
If c=0 Then
 Begin
  System.Close(fk);
  If Not(Password(2)) Then
  Begin
  MessageBox(#3+'Кассовый лист уже заполнен!'^M+
  #3+'Его повторный ввод или корректировка запрещены!',Nil,mfError+mfCancelButton);
  Exit;
  End;
 End;

AInfo('Подсчитываю межскладские перевозки...');
End
Else
 Begin
  If Not(DateDialog(KassaDate)) Then Exit;
  Assign(fk,Path.ToArchiv+KassaDate+'.k'+s);
  c:=IOResult;
  Reset(fk);
  c:=IOResult;
  If c<>0 Then
   Begin
    MessageBox(^M+#3+'Ошибка открытия файла кассы за '+KassaDate,Nil,mfError+mfCancelButton);
    Exit;
   End;
  New(PrevKassa,Init);
  c:=IOResult;
  Read(fk,PrevKassa^.Dat);
  c:=IOResult;
  If c<>0 Then
   Begin
    c:=IOResult;
    System.Close(fk);
    Dispose(PrevKassa,Done);
    MessageBox(^M+#3+'Ошибка чтения файла кассы за '+KassaDate,Nil,mfError+mfCancelButton);
    Exit;
   End;
   System.Close(fk);
 End;

New(kk,Init);{создаем редактируемый объект кассового листа}


If Not(Mode) Then
kk^.Dat:=KAssa^.Dat
Else
Begin
kk^.Dat:=PrevKassa^.Dat;
kk^.dat.DateC:=PrevKassa^.DAt.DateC;
kk^.DAt.TimeC:=PrevKassa^.DAt.TimeC;
kk^.Dat.Caption:=CurrentPassword;
DIspose(PrevKassa,Done);
End;

Video:=False;
If Mode Then Video:=True
Else
 Begin
 NoInfo;
 If Password(3) Then Video:=True;
 AInfo('Подсчитываю межскладские перевозки...');
 End;




If (StrToInt(CurrentPassword)=0) Then Regim:=True
Else Regim:=False;


R.Assign(0, 0, 80, 23);

s:=FormKod(Rek.Kod);
s:=GEtClientField(FClient,s,1);
DelSpaceLeftRight(s);

New(KassaWindow, Init(R, 'Контрольный кассовый лист склада '+s+' за '+KassaDate));
kassawindow^.HelpCtx := $E191;

{R.Assign(1, 1, 4, 23);}
R.Assign(1, 1, 6, 23);
Control := New(PColoredText, Init(R, '1'^M+
     '2'^M+
     '3,4'^M+
     '5'^M+
     '6'^M+
     '7'^M+
     '8'^M+
     '9'^M+
     '10'^M+
     '11'^M+
     '12'^M+
     '13'^M+
     '14'^M+
     '15'^M+
     '16'^M+
     '17,18'^M+
     '19'^M+
     '20'^M+
     '21'^M+
     '22'^M+
     '23'^M+
     '24', $7E));
KassaWindow^.Insert(Control);


If Mode Then
Begin
SpecialBeep;
R.Assign(47, 22, 74, 23);
Control := New(PColoredText, Init(R, 'Идет корректировка данных', $DE));
KassaWindow^.Insert(Control);
End;



R.Assign(31, 1, 42, 2);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(3, 1, 31, 2);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Приход на склад от клиента:', Control)));


R.Assign(31, 2, 42, 3);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(12, 2, 31, 3);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Остаток на складе:', Control)));


R.Assign(8, 3, 16, 4);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(4, 3, 8, 4);
  KassaWindow^.Insert(New(PLabel, Init(R, 'РП:', Control)));

R.Assign(31, 3, 42, 4);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(16, 3, 31, 4);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Сумма со скл.:', Control)));



R.Assign(31, 4, 42, 5);
If Video Then
Control := New(PInputLine, Init(R, 15))
Else
Control := New(PSInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(2, 4, 31, 5);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Выдано без отср. платежа(Т):', Control)));

R.Assign(31, 5, 42, 6);
If Video Then
Control := New(PInputLine, Init(R, 15))
Else
Control := New(PSInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(2, 5, 31, 6);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Скидки выдачи без отср.плат:', Control)));

R.Assign(31, 6, 42, 7);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(4, 6, 31, 7);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Выдано на консигнацию (Т):', Control)));

R.Assign(31, 7, 42, 8);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(5, 7, 31, 8);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Скидки выданной консигн.:', Control)));

R.Assign(31, 8, 42, 9);
If Video Then
Control := New(PInputLine, Init(R, 15))
Else
Control := New(PSInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(3, 8, 31, 9);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Оплата консигнации в кассу:', Control)));

R.Assign(31, 9, 42, 10);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(3, 9, 31, 10);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Скидки офомлен.консигнации:', Control)));

R.Assign(31, 10, 42, 11);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(3, 10, 31, 11);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Возврат по открыт.консигн.:', Control)));

R.Assign(31, 11, 42, 12);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(3, 11, 31, 12);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Скид.возврата откр.консиг.:', Control)));

R.Assign(31, 12, 42, 13);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(3, 12, 31, 13);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Возврат по прод.,оф.консиг:', Control)));

R.Assign(31, 13, 42, 14);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(3, 13, 31, 14);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Скид.возвр.прод.,оф.консиг:', Control)));

R.Assign(31, 14, 42, 15);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(6, 14, 31, 15);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Остаток консигнации (Т):', Control)));

R.Assign(31, 15, 42, 16);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(3, 15, 31, 16);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Скидки остатка консигнации:', Control)));

R.Assign(11, 16, 22, 17);
Control := New(PInputLine, Init(R, 15));
Kassawindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(6, 16, 11, 17);
  Kassawindow^.Insert(New(PLabel, Init(R, 'Прц:', Control)));

R.Assign(31, 16, 42, 17);
Control := New(PInputLine, Init(R, 15));
Kassawindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(22, 16, 31, 17);
  Kassawindow^.Insert(New(PLabel, Init(R, 'Прц взв:', Control)));


{
R.Assign(31, 16, 42, 17);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(19, 16, 31, 17);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Переоценка:', Control)));

R.Assign(31, 17, 42, 18);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(7, 17, 31, 18);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Переоценка по возврату:', Control)));
}

R.Assign(31, 17, 42, 18);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));

{  R.Assign(16, 18, 31, 19);}
  R.Assign(5, 17, 31, 18);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Сумма в кассе ('+KassaDAte+'):', Control)));

R.Assign(31, 18, 42, 19);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));

{  R.Assign(14, 19, 31, 20);}
  R.Assign(3, 18, 31, 19);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Остаток в кассе ('+KassaDAte+'):', Control)));


R.Assign(31, 19, 42, 20);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));

  R.Assign(9, 19, 31, 20);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Дополнительный доход:', Control)));


R.Assign(31, 20, 42, 21);
If Video Then
Control := New(PInputLine, Init(R, 15))
Else
Control := New(PSInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(10, 20, 31, 21);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Расходы по возврату:', Control)));

R.Assign(31, 21, 42, 22);
If Video Then
Control := New(PInputLine, Init(R, 15))
Else
Control := New(PSInputLine, Init(R, 15));
Kassawindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(4, 21, 31, 22);
  Kassawindow^.Insert(New(PLabel, Init(R, 'Расход по взв.откр.консиг:', Control)));


R.Assign(43, 15, 78, 22);
Control := New(PColoredText, Init(R, '', $70));
Control^.Options := Control^.Options or ofFramed;
KassaWindow^.Insert(Control);

R.Assign(43, 7, 78, 14);
Control := New(PColoredText, Init(R, '', $70));
Control^.Options := Control^.Options or ofFramed;
KassaWindow^.Insert(Control);



{
R.Assign(14, 22, 25, 23);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));

  R.Assign(6, 22, 14, 23);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Расход:', Control)));
}

R.Assign(31, 22, 42, 23);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));

  R.Assign(3, 22, 31, 23);
  KassaWindow^.Insert(New(PLabel, Init(R, ' Расходы-без учета п.22,23:', Control)));




{R.Assign(52, 1, 60, 2);}
R.Assign(53, 1, 61, 2);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));


  {R.Assign(46, 1, 52, 2);}
  R.Assign(47, 1, 53, 2);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Серт:', Control)));

{R.Assign(67, 1, 78, 2);}
R.Assign(68, 1, 79, 2);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));

  {R.Assign(60, 1, 67, 2);}
  R.Assign(61, 1, 68, 2);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Сдано:', Control)));

{R.Assign(67, 2, 78, 3);}
R.Assign(51, 2, 61, 3);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  {R.Assign(45, 2, 67, 3);}
  R.Assign(47, 2, 51, 3);
  KassaWindow^.Insert(New(PLabel, Init(R, ''+#253+':', Control)));

{R.Assign(67, 3, 78, 4);}
R.Assign(68, 2, 79, 3);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  {R.Assign(48, 3, 67, 4);}
  R.Assign(61, 2, 68, 3);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Ревиз:', Control)));

{R.Assign(67, 4, 78, 5);}
R.Assign(68, 3, 79, 4);
If Video Then
Control := New(PInputLine, Init(R, 15))
Else
Control := New(PSInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  {R.Assign(46, 4, 67, 5);}
  R.Assign(46, 3, 68, 4);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Сбор НП без отср.пл:', Control)));

{R.Assign(67, 5, 78, 6);}
R.Assign(68, 4, 79, 5);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

{  R.Assign(46, 5, 67, 6);}
  R.Assign(47, 4, 68, 5);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Сбор НП выд.консиг.:', Control)));

R.Assign(68, 5, 79, 6);
If Video Then
Control := New(PInputLine, Init(R, 15))
Else
Control := New(PSInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(47, 5, 68, 6);
  KassaWindow^.Insert(New(PLabel, Init(R, 'НП возвр.от.консиг.:', Control)));

R.Assign(43, 1, 47, 6);
Control := New(PColoredText, Init(R,
     '25-6'^M+
     '27-8'^M+
     '29'^M+
     '30'^M+
     '31', $7E));


KassaWindow^.Insert(Control);



R.Assign(43, 6, 47, 23);
Control := New(PColoredText, Init(R,
     '32'^M+
     '33'^M+
     '34'^M+
     '35'^M+
     '36'^M+
     '37'^M+
     '38'^M+
     '39'^M+
     '40'^M+
     '41'^M+
     '42'^M+
     '43'^M+
     '44'^M+
     '45'^M+
     '46'^M+
     '47'^M+
     '48', $7E));
KassaWindow^.Insert(Control);


R.Assign(68, 6, 79, 7);
If Video Then
Control := New(PInputLine, Init(R, 15))
Else
Control := New(PSInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(46, 6, 68, 7);
  KassaWindow^.Insert(New(PLabel, Init(R, '   Сальдо по бартеру:', Control)));

R.Assign(68, 7, 79, 8);
If Video Then
Control := New(PInputLine, Init(R, 15))
Else
Control := New(PSInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(46, 7, 68, 8);
  KassaWindow^.Insert(New(PLabel, Init(R, ' Приход в счет ВЗ ЗЦ:', Control)));

R.Assign(68, 8, 79, 9);
If Video Then
Control := New(PInputLine, Init(R, 15))
Else
Control := New(PSInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(46, 8, 68, 9);
  KassaWindow^.Insert(New(PLabel, Init(R, ' Приход в счет ВЗ РЦ:', Control)));

R.Assign(68, 9, 79, 10);
If Video Then
Control := New(PInputLine, Init(R, 15))
Else
Control := New(PSInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(46, 9, 68, 10);
  KassaWindow^.Insert(New(PLabel, Init(R, 'Выдано клиент.ВЗ (Т):', Control)));


R.Assign(68, 10, 79, 11);
If Video Then
Control := New(PInputLine, Init(R, 15))
Else
Control := New(PSInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.','-']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(46, 10, 68, 11);
  KassaWindow^.Insert(New(PLabel, Init(R, '    Скидки выдачи ВЗ:', Control)));

R.Assign(68, 11, 79, 12);
If Video Then
Control := New(PInputLine, Init(R, 15))
Else
Control := New(PSInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(46, 11, 68, 12);
  KassaWindow^.Insert(New(PLabel, Init(R, '   В кассу в счет ВЗ:', Control)));


R.Assign(68, 12, 79, 13);
If Video Then
Control := New(PInputLine, Init(R, 15))
Else
Control := New(PSInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If Not(Regim) Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(46, 12, 68, 13);
  KassaWindow^.Insert(New(PLabel, Init(R, '  Из кассы в счет ВЗ:', Control)));


For c:=0 To 4 Do
Begin
Str(c+1:CClientKod,s);
s:=GEtClientField(FClient,s,1);
DelSpaceLeftRight(s);

R.Assign(68, 13+c, 79, 14+c);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If (Not(Regim)) Or (StrToInt(Rek.Kod)=(c+1))
                 Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(46, 13+c, 67, 14+c);
  KassaWindow^.Insert(New(PLabel, Init(R, S, Control)));

If Not(Mode) Then
Begin
Str(c+1:CClientKod,s);
s:=CalcOutSkladPerevoski(s);
kk^.Dat.PerewoskiOut[c]:=s;
End;
End;


For c:=0 To 4 Do
Begin
Str(c+1:CClientKod,s);
s:=GEtClientField(FClient,s,1);
DelSpaceLeftRight(s);

R.Assign(67, 18+c, 78, 19+c);
Control := New(PInputLine, Init(R, 15));
KassaWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9','.']));
  If (Not(Regim)) Or (StrToInt(Rek.Kod)=(c+1))
                 Then Control^.Options := Control^.Options and not ofSelectable;

  R.Assign(45, 18+c, 67, 19+c);
  KassaWindow^.Insert(New(PLabel, Init(R, s, Control)));

If Not(Mode) Then
Begin
Str(c+1:CClientKod,s);
s:=CalcInpSkladPerevoski(s);
kk^.Dat.PerewoskiInp[c]:=s;
End;

End;





{
R.Assign(1, 1, 3, 22);
Control := New(PColoredText, Init(R, '1'^M+
     '2'^M+
     '3'^M+
     '4'^M+
     '5'^M+
     '6'^M+
     '7'^M+
     '8'^M+
     '9'^M+
     '10'^M+
     '11'^M+
     '12'^M+
     '13'^M+
     '14'^M+
     '15'^M+
     '16'^M+
     '17'^M+
     '18'^M+
     '19'^M+
     '20'^M+
     '21', $7E));
KassaWindow^.Insert(Control);

R.Assign(43, 1, 45, 5);
Control := New(PColoredText, Init(R, '22'^M+
     '23'^M+
     '24'^M+
     '25', $7E));
KassaWindow^.Insert(Control);

R.Assign(43, 6, 45, 13);
Control := New(PColoredText, Init(R, '26'^M+
     '27'^M+
     '28'^M+
     '29'^M+
     '30'^M+
     '31'^M+
     '32', $7E));
KassaWindow^.Insert(Control);

R.Assign(43, 14, 45, 21);
Control := New(PColoredText, Init(R, '33'^M+
     '34'^M+
     '35'^M+
     '36'^M+
     '37'^M+
     '38'^M+
     '39', $7E));
KassaWindow^.Insert(Control);
}

KassaWindow^.SelectNext(False);
KassaWindow^.SetDAta(kk^.Dat);
If Not(Mode) Then NoInfo;
c:=Desktop^.ExecView(KassaWindow);
If c<>cmCAncel Then
 Begin
 KassaWindow^.GetData(kk^.DAt);
 If Not(Mode) Then kassa^.Dat:=Kk^.Dat;

 If WriteKassaToFile(kk,Mode) And Not(Mode) Then
 {If Not(Mode) Then }ShowKAssa:=True;
 End;
Dispose(kk,Done);
Dispose(Control,Done);
Dispose(KassaWindow,Done);
end;
{$Else}
Procedure TKassaWindow.Start(Mode:Boolean);
Begin
End;



{$EndIF}


Destructor TKassaWindow.Done;
Begin
TDialog.Done;
End;


Procedure TKassaWindow.HAndleEvent(Var Event:TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var kk : PKassaType;

Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
       cmItogBarter:BarterItog^.OpenViewBarterItog;
        cmTestSklad:Begin
                     If Password(3) Then
                     Begin
                      New(kk,Init);
                      KassaWindow^.GetData(kk^.Dat);
                      RunTest(kk);
                      Dispose(kk,Done);
                     End;
                    End;
        cmLocalCalc:Calculator;
        cmOk       :If MessageBox(#3'Вы убеждены что каждая цифра кассового листа введена правильно?'^M+
                                     #3'После ввода данных корректировка будет невозможна!',nil,mfOkCancel)<>cmOk Then
                     Begin
                      ClearEvent(Event);
                                  Exit;
                     End;

   Else;
   End;
 evKeyDown :
 CAse Event.KeyCode Of
  kbAltRusT,kbF9 :
        Begin
         Event.What:=EvCommand;
         Event.Command:=cmTestSklad;
         PutEvent(Event);
         ClearEvent(Event);
        End;
 Else;
 End;
   Else;
   End;
inherited HandleEvent(Event);
End;{handleevent}


(*
Type
  PDocWindow = ^TDocWindow;
  TDocWindow = object(TDialog)
    procedure Start;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done; virtual;
  end;
*)





Type FindMinMax=Record
    FindDoc : Word;
    FStart  : TDateString;
    FStop   : TDateString;
   End;


Var Find : FindMinMax;
{    DocWindow : PDocWindow;}


(*
Procedure TDocWindow.Start;
Const Space='                 ';
Var lStart,LStop,LCur:LongInt;
    Max,Min:Real;
    DocCount,MaxDoc,MinDoc:Word;
    MaxDate,MinDate:TDateString;
    f : MarketFileType;
    E : PSuperMarketType;
    Ok: Boolean;
    i : Word;
    Open,s,ws : String;
    NDoc : ArtikulStr;
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  Txt : Text;


Begin

LStart:= DateStringToDate(DateMask,Find.FStart);
LStop := DateStringToDate(DateMask,Find.FStop);
DocCount:=0;
Ok:=False;
DInfo('Минуточку...');
New(E,Init);
For lcur:=LStart To LStop Do
 Begin
  Assign(f,Path.ToMarket+DateToDateString(DateMask,LCur)+'.mrk');
  i:=IOResult;
  Reset(f);
  i:=IOResult;
  If i=0 Then
   Begin
    While Not(Eof(f)) And Not(ok) Do
     Begin
      ReadMarket(f,e);
      If (E^.Dat.DocSelector=Find.FindDoc) And (E^.Dat.Active)
         And(E^.Dat.OperatorSelector=0)Then
       Begin
 If ((Not(E^.DAt.Realiz)) And (Find.FindDoc in [0,1,2,3,4])) Or
    ((E^.DAt.Realiz) And (Find.FindDoc in [5,6,7,8])) Then
    Begin
        Ok:=True;
        Max:=StrToReal(E^.Dat.SummaZ);
           Min:=StrToReal(E^.Dat.SummaZ);
        MaxDoc:=StrToInt(E^.Dat.Document);
           MinDoc:=StrToInt(E^.Dat.Document);
        MaxDate:=E^.Dat.DateC;
           MinDate:=E^.Dat.DateC;
    End;
       End;
     End;
     System.Close(f);
   End;
 End;

 Dispose(E,Done);

 If Not(Ok) Then
  Begin
   NoInfo;
   SpeCialBeep;
   MessageBox(^M+#3+'Документов указанного вида за период с '+Find.FStart+' по '+
   Find.FStart+' не обнаружено!',Nil,mfInformation+mfCancelButton);
   Exit;
  End;

  New(E,Init);
 For lcur:=LStart To LStop Do
 Begin
  Assign(f,Path.ToMarket+DateToDateString(DateMask,LCur)+'.mrk');
  i:=IOResult;
  Reset(f);
  i:=IOResult;
  If i=0 Then
   Begin
    While Not(Eof(f)) Do
     Begin
      ReadMarket(f,e);
      If (E^.Dat.DocSelector=Find.FindDoc) And (E^.Dat.Active)
         And(E^.Dat.OperatorSelector=0)Then
       Begin

 If ((Not(E^.DAt.Realiz)) And (Find.FindDoc in [0,1,2,3,4])) Or
    ((E^.DAt.Realiz) And (Find.FindDoc in [5,6,7,8])) Then
    Begin
        Inc(DocCount);
        If StrToReal(E^.Dat.SummaZ)>Max Then
         Begin
          Max:=StrToReal(E^.Dat.SummaZ);
          MaxDoc:=StrToInt(E^.Dat.Document);
          MaxDate:=E^.Dat.DateC;
         End;

        If StrToReal(E^.Dat.SummaZ)<Min Then
         Begin
          Min:=StrToReal(E^.Dat.SummaZ);
          MinDoc:=StrToInt(E^.Dat.Document);
          MinDate:=E^.Dat.DateC;
         End;
       End;
    End;
     End;
     System.Close(f);
   End;
 End;

Dispose(E,Done);

Assign(txt,Path.ToTemp+'today.txt');
i:=IOResult;
Rewrite(txt);
i:=IOResult;
If i<>0 Then
 Begin
  MessageBox(#3'Ошибка создания файла '+Path.ToTemp+'today.txt! '+IntToStr(i,3),Nil,mfError+mfCancelButton);
  Exit;
 End;


R.Assign(7, 9, 72, 14);
New(DocWindow, Init(R, 'За период с '+Find.FStart+' по '+Find.FStop));
DocWindow^.Options := DocWindow^.Options or ofCenterX or ofCenterY;
DocWindow^.HelpCtx := $E607;

Case Find.FindDoc Of
0:s:=#3+'Список';
1:s:=#3+'Товарный чек';
2:s:=#3+'Физическое лицо';
3:s:=#3+'Счет-фактура';
4:s:=#3+'Счет-фактура Б';
5:s:=#3+'Дебит*';
6:s:=#3+'Дебит* со счетом-фактурой';
7:s:=#3+'Дебит'^M;
8:s:=#3+'Дебит со счетом-фактурой Б';
Else s:=#3+'???';
End;

s:=s+'  (Всего: '+IntToStr(DocCount,CKol)+')';

Writeln(Txt,Space+'Склад:'+GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1999');

{$IfDEF DPMI}
Writeln(txt,Space+'За период с '+Find.FStart+' по '+Find.FStop+NoBold[NPrint.Printer]);
Writeln(txt,Space+'---------------------------------------------------------------');
Writeln(txt,Space+' Вид док-та:'+Double[NPrint.Printer]+Bold[NPrint.Printer]+S+
NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
{$EndIf}

s:=s+^M;



R.Assign(1, 1, 11, 4);
Control := New(PColoredText, Init(R, ' Вид док.:'^M+
     ' Максимум:'^M+
     '  Минимум:', $30));
DocWindow^.Insert(Control);

Case TestOpenDate1(MaxDate) Of
False  :Open:='Заблокирован';
True   :Open:='Не заблокирован';
Else;
End;

NDoc:=IntToStr(MaxDoc,CDocNumer);
RFormat(NDoc,CDocNumer);

ws:=RealToStr(Max,CIZena,CMantissa);
{$IfDEF DPMI}
Writeln(txt,Space+'   Максимум:'+Bold[NPrint.Printer]+Double[NPrint.Printer]+
RecognizReal(StrToReal(ws),CIZena,CMAntissa)+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]+
+'  N'+NDoc+' от '+MaxDate+' '+Open);
{$EndIf}
s:=s+ws;
s:=s+'│ N'+NDoc+' от '+MaxDate+'│ '+Open+^M;

Case TestOpenDate1(MinDate) Of
False  :Open:='Заблокирован';
True   :Open:='Не заблокирован';
Else;
End;

NDoc:=IntToStr(MinDoc,CDocNumer);
RFormat(NDoc,CDocNumer);

ws:=RealToStr(Min,CIZena,CMantissa);
{$IfDEF DPMI}
Writeln(txt,Space+'    Минимум:'+Bold[NPrint.Printer]+Double[NPrint.Printer]+RecognizReal(StrToReal(ws),CIZena,CMAntissa)
+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]+
+'  N'+NDoc+' от '+MinDate+' '+Open);
Writeln(Txt);
Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt,Space+'===============================================================');
{$EndIf}

system.close(txt);

s:=s+ws;
s:=s+'│ N'+NDoc+' от '+MinDate+'│ '+Open;

R.Assign(11, 1, 64, 4);
Control := New(PColoredText, Init(R, s, $3E));
DocWindow^.Insert(Control);

DocWindow^.SelectNext(False);
NoInfo;
Desktop^.ExecView(DocWindow);
Dispose(Control,Done);
Dispose(DocWindow,Done);
End;


Destructor TDocWindow.Done;
Begin
TDialog.Done;
End;

procedure TDocWindow.HandleEvent(var Event: TEvent);
Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmReestrReport: begin
                        Report(Path.ToTemp+'today.txt','',1,False,False);
                        ClearEvent(Event);
                          end;
   Else;
   End;
 else;
 end;
 inherited HAndleEvent(Event);
 ClearEvent(Event);
End;


Procedure SelectVidDoc;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  l : LongInt;
  s1 : TDateString;

begin

1:
R.Assign(24, 6, 55, 16);
New(Dlg, Init(R, 'Min/Max'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E011;


R.Assign(1, 1, 30, 6);
Control := New(PRadioButtons, Init(R,
  NewSItem('С~п~исок',
  NewSItem('Тов.~Ч~ек',
  NewSItem('Физ.Л*',
  NewSItem('С~Ф~',
  NewSItem('~С~ФБ',
  NewSItem('Дебит~*~',
  NewSItem('Деб~и~т СФ*',
  NewSItem('~Д~ебит',
  NewSItem('Д~е~бит СФБ', Nil)))))))))));
Dlg^.Insert(Control);

R.Assign(2, 7, 29, 8);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);

R.Assign(5, 7, 15, 8);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init('[##-##-##]', True));

  R.Assign(2, 7, 5, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'с:', Control)));

R.Assign(19, 7, 29, 8);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init('[##-##-##]', True));

  R.Assign(15, 7, 19, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'п~о~:', Control)));

Dlg^.SelectNext(False);
Dlg^.SetDAta(Find);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(Find);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
{$IfDEF DPMI}

   If Not(TestDate(Find.FStart,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Not(TestDate(Find.FStop,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If DateStringToDate(DateMask,Find.FStop)<DateStringToDate(DateMask,Find.FStart) Then
    Begin
        s1:=Find.FStop;
        Find.FStop:=Find.FStart;
        Find.FStart:=s1;
    End;
    DocWindow^.Start;
{$EndIf}

 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
end;

*)
Procedure TBarterItogWindow.OpenViewBarterItog;
 var
  R : TRect;
  Control : PView;
  c : Word;
  TempS : AllStr;
begin
{$IFNDEF Kurz}
R.Assign(20, 6, 59, 17);
New(BarterItog, Init(R, 'Взаимозачеты'));
BarterItog^.Options := BarterItog^.Options or ofCenterX or ofCenterY;
BarterItog^.HelpCtx := $E556;

R.Assign(6, 1, 19, 2);
Control := New(PStaticText, Init(R, 'Приход Б З/Ц:'));
BarterItog^.Insert(Control);

TempS:=Kassa^.Dat.BarterPrihod;
RFormat(TempS,CIZena);
RFormat(BarterPrhKol,CLitrMantissa);

R.Assign(19, 1, 38, 2);
Control := New(PColoredText, Init(R, TempS+' '+BarterPrhKol, $1F));
BarterItog^.Insert(Control);


TempS:=Kassa^.Dat.BarterT;
RFormat(TempS,CIZena);
RFormat(BarterKol,CLitrMantissa);

R.Assign(8, 2, 19, 3);
Control := New(PStaticText, Init(R, 'Выдано Б Т:'));
BarterItog^.Insert(Control);

R.Assign(19, 2, 38, 3);
Control := New(PColoredText, Init(R, TempS+' '+BarterKol, $1F));
BarterItog^.Insert(Control);

TempS:=Kassa^.Dat.BarterSkidki;
RFormat(TempS,CIZena);

R.Assign(19, 3, 38, 4);
Control := New(PColoredText, Init(R, TempS, $1F));
BarterItog^.Insert(Control);

R.Assign(2, 3, 19, 4);
Control := New(PStaticText, Init(R, '  Скиди выдачи Б:'));
BarterItog^.Insert(Control);


TempS:=Kassa^.Dat.BarterOutKassa;
RFormat(TempS,CIZena);

R.Assign(19, 4, 38, 5);
Control := New(PColoredText, Init(R, TempS, $1F));
BarterItog^.Insert(Control);

R.Assign(1, 4, 19, 5);
Control := New(PStaticText, Init(R, 'Выдано из кассы Б:'));
BarterItog^.Insert(Control);

TempS:=Kassa^.Dat.BarterInKassa;
RFormat(TempS,CIZena);


R.Assign(19, 5, 38, 6);
Control := New(PColoredText, Init(R, TempS, $1F));
BarterItog^.Insert(Control);

R.Assign(2, 5, 19, 6);
Control := New(PStaticText, Init(R, 'Оплата Б в кассу:'));
BarterItog^.Insert(Control);

TempS:=Kassa^.Dat.OstatokBarter;
RFormat(TempS,CIZena);

R.Assign(19, 6, 38, 7);
Control := New(PColoredText, Init(R, TempS, $1F));
BarterItog^.Insert(Control);

R.Assign(4, 6, 19, 7);
Control := New(PStaticText, Init(R, 'Всего сальдо Б:'));
BarterItog^.Insert(Control);




TempS:=Kassa^.Dat.BarterPrihodRZ;
RFormat(TempS,CIZena);
RFormat(BarterPrhKolRZ,CLitrMantissa);
RFormat(NoInputBarterPrhRZ,CIZena);
RFormat(NoInputBarterPrhKolRZ,CLitrMantissa);



R.Assign(19, 8, 38, 10);
Control := New(PColoredText, Init(R, TempS+' '+BarterPrhKolRZ+^M+
                                     NoInputBarterPrhRZ+' '+NoInputBarterPrhKolRZ, $1F));
BarterItog^.Insert(Control);

R.Assign(6, 8, 19, 9);
Control := New(PStaticText, Init(R, 'Приход Б Р/Ц:'));
BarterItog^.Insert(Control);



BarterItog^.SelectNext(False);

c:=Desktop^.ExecView(BarterItog);

Dispose(Control,Done);
Dispose(BarterItog,Done);
{$ENDIF}
end;


Destructor TBarterItogWindow.Done;
Begin
TDialog.Done;
End;

procedure TBarterItogWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;


Begin
{$IFDEF DPMI}
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
   Else;
   End;
 Else;
 End;
 Inherited HandleEvent(Event);
{$ENDIF}
End;






begin
{$IFDEF DPMI}

 With Find Do
 Begin
  FindDoc:=1;
  FStart:=FDate;
  FStop:=FDate;
 End;
{$ENDIF}
End.