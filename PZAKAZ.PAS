{$IfNDEF DPMI}
{$F+}
{$O+}
{$EndIf}


{$I Compile.INC}

Unit PZakaz;

Interface

Uses Dialogs,Drivers,Glob,FindPrh,Access,Access8,Utils4,Utils1,MyCalc,ServStr;

Type
  PCartZakazWindow = ^TCartZakazWindow;
  TCartZakazWindow = object(TDialog)
    FR   : PFindRezervWindow;
    LastZena :PLastZenaWindow;
    Calc : PMyCalculator;
    FP   : PFindPrh;
    lnk  : PLinkWindow;
    ClientKOd : ArtikulStr;
    Art  : ArtikulStr;
    Otd  : ArtikulStr;
    Fas  : ArtikulStr;
    RZ   : TDAteString;
    ZZ   : TDAteString;
    Procedure DrawPack;
    Procedure CalcSkidka;
    Procedure CalcZena;
    Procedure ReCalcNazenka;
    Procedure Edit(s:String;kod:ArtikulStr;Koef: Real);
    procedure HandleEvent(var Event: TEvent); virtual;
    end;




Type
  PSuperZakazWindow = ^TSuperZakazWindow;
  TSuperZakazWindow = object(TDialog)
    Cart : PCartZakazWindow;
    Cl   : PClientWindow;
    Ag   : PAgentWindow;
    FR   : PFindRezervWindow;
    Calc : PMyCalculator;
    FP   : PFindPrh;
    lnk  : PLinkWindow;
    Koef : Real;
    Function Start(Var P:PPredZakazType):Boolean;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure AddName;
    procedure RefreshSklad;
    procedure CalcItogo(Var SOpl,SSkid:AllStr);
    Procedure SaveToFile(Var Save : Boolean);
    Procedure DrawCurrent;
    end;

 Implementation

uses App, DBEngine, Objects, Views, MsgBox, Vision4, Nastr, Protect,NetCall,
     Windos, ColorTxt, Serv, InpLong, Validate, TpDate,DbEngin2,ServStr2,
     MrkTool,Net2,Net,NetDbEng,Utils,Utils5,Utils6;


Var SkladList,PredZakazList : PBox;
    WPZ : PPRedZakazType;
    ZWin : PSuperZakazWindow;
    Control,ControlKol,ControlComment1,ControlComment2,
    ControlAmount,ControlDoc,ControlDateEnd,ControlSumma,
    ControlAllSkidka,ControlNAme,ControlPack,ControlDef,
    ControlS,
    ControlMZena,ControlMSkidka,ControlSkidkaSelector,
    ControlZena,ControlAgent,ControlClient: PView;
    ControlLocalKol,ControlLocalZena,ControlStore,
    ControlNSertif,ControlNazenka,ControlProz,
    ControlLocalSkidka :  PView;
    ShowSertif : Word;
    PC : PCartZakazWindow;
    PrevS,PrevAgent : AllStr;
    CurrentLineSklad,CurrentName,CurrentLineZakaz : PString;
    Filtr: Boolean;



Procedure GlobalNazenka(Var P:PBox);

Var Tec : Record
  st : ArtikulStr;
  st2: ArtikulStr;
  Moroz : Word;
 End;


var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  ws1,ws,Zena,Skidka : TDateString;
  s : String;
  WspomList1:PBox;
  ls : Word;


begin
If (P^.List^.Count>0) Then
Begin
R.Assign(29, 9, 51, 13);
New(Dlg, Init(R, 'Наценка'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E003;

R.Assign(12, 1, 19, 2);
Control := New(PRealInputLine, Init(R, CKol));
Dlg^.Insert(Control);
{  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));}

  R.Assign(1, 1, 12, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Наценка 1:', Control)));

R.Assign(19, 1, 21, 2);
Control := New(PStaticText, Init(R, '%'));
Dlg^.Insert(Control);


R.Assign(12, 2, 19, 3);
Control := New(PRealInputLine, Init(R, CKol));
If (StrToInt(CurrentPassword)<>0) And Not((Pharm=1)) Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(1, 2, 12, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Наценка 2:', Control)));

R.Assign(19, 2, 21, 3);
Control := New(PStaticText, Init(R, '%'));
Dlg^.Insert(Control);


R.Assign(3, 3, 19, 4);
Control := New(PCheckboxes, Init(R,
  NewSItem('~О~т текущих', Nil)));
Dlg^.Insert(Control);

If Not (Pharm=1) Then Control^.Options := Control^.Options and not ofSelectable;

Tec.St[0]:=#0;
Tec.St2[0]:=#0;
Tec.Moroz:=0;

Dlg^.SetData(Tec);


Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(Tec);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  DelSpace(Tec.St);
  DelSpace(Tec.St2);
  {вставить код изменения скидки}

  If (StrToReal(Tec.St)>30.00) And Not(StrToInt(CurrentPassword)=0) Then
   Begin
    MessageBox(^M+#3'Ваш уровень доступа не позволяет провести данную операцию',
    Nil,mfWarning+mfCancelButton);
    Exit;
   End;

If Not(StrToReal(Tec.St)>=0.009) And (StrToReal(Tec.St2)>=0.009) Then
   Begin
    MessageBox(^M+#3'Такой вариант наценки является недопустимым!',
    Nil,mfWarning+mfCancelButton);
    Exit;
   End;


  If (StrToReal(Tec.St2)>15.00) And Not(StrToInt(CurrentPassword)=0) Then
   Begin
    MessageBox(^M+#3'Ваш уровень доступа не позволяет провести данную операцию',
    Nil,mfWarning+mfCancelButton);
    Exit;
   End;
  {вставить код изменения скидки}

If P^.List^.Count>0 Then
Begin

  R.Assign(0,0,0,0);
  WspomlIST1 := New(PBox, Init(R, 1, Nil));
  WspomList1^.NewList(New(PTextCollection, Init(0,1)));

{ s:=s+SKol+'│'+SZena+'│'+PC^.RZ+'│'+SSkidka+'│'+IntToStr(SNadoSertif,COne)+'│'+SName;}


For ls:=0 To P^.List^.Count-1 Do
 Begin
{артикул}
 s:=P^.GetText(ls,P^.List^.Count);
 Zena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1,CZena);

 If Tec.Moroz=1 Then
  Begin
   {все расчеты строятся от текущей цены к оплате}
   Skidka:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1,CZena);
   MyStr(StrToReal(Zena)-StrToReal(Skidka),CZena,CMantissa,Zena);
  End;


 {первый процент наценки}
 MyStr((StrToReal(Zena)*StrToReal(Tec.st)/(-100)),CZena,CMantissa,ws);

 {второй процент наценки}
 If StrToReal(Tec.st2)>0.009 Then
 Begin
  MyStr(((StrToReal(Zena)-StrToReal(ws))*StrToReal(Tec.st2)/(-100)),CZena,CMantissa,ws1);
  MyStr(StrToReal(ws1)+StrToReal(ws),CZena,CMantissa,ws);
 End;


 If Tec.Moroz=1 Then
  Begin
   MyStr(StrToReal(ws)+StrToReal(Skidka),CZena,CMantissa,ws);
  End;



{Удаляем старую ручную скидку}
 System.Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1,CZena);
{Добавляем новую ручную скидку}
 System.Insert(ws,S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1);

{удаляем старую цену к оплате}
 Zena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1,CZena);

 MyStr(StrToReal(Zena)-StrToReal(ws),CZena,CMantissa,Zena);

 {исправляем цену к оплате}
 System.Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1,CZena);
 System.Insert(Zena,S,1+CName+1+CArtikul+1+COne+1+CKol+1);

{добавляем новую цену к оплате}




{вставляем исправленную строку}
 WspomList1^.List^.Insert(NewStr(s));
 WspomList1^.SetRange(WspomList1^.List^.Count);

End;{For}
{очистка P}
  P^.NewList(Nil);
  P^.NewList(New(PTextCollection, Init(0,1)));

{обновление P}
For ls:=0 To WspomList1^.List^.Count-1 Do
 Begin
{артикул}
 s:=WspomList1^.GetText(ls,WspomList1^.List^.Count);
 P^.List^.Insert(NewStr(s));
 P^.SetRange(P^.List^.Count);
End;{For}

{удаление Wspom}
Dispose(WspomList1,Done);
P^.FocusItem(0);
End;{P^.List^.Count>0}
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
End;{If P^.List^.Count>0 Then}
end;





Procedure GlobalSkidka (Var P:PBox);
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  Control1 : PView;
  Control2 : PView;
  c : Word;
  st : ArtikulStr;
  sw : String[CLitrMantissa];
  ws,Zena,Skidka : TDateString;
  s : String;
  WspomList1:PBox;
  ls,Moroz : Word;
  Event : TEvent;
begin
If P^.List^.Count>0 Then
Begin

R.Assign(28, 9, 49, 12);
New(Dlg, Init(R, 'Скидка'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E004;
R.Assign(10, 1, 15, 2);
Control1 := New(PInputLine, Init(R, CLitrMantissa));
Dlg^.Insert(Control1);
  PInputLine(Control1)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));
  sw:='0';

  R.Assign(1, 1, 9, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Скидка:', Control1)));

Control1^.SetData(Sw);

R.Assign(9, 1, 11, 2);
Control := New(PColoredText, Init(R, '1.', $1F));
Dlg^.Insert(Control);

R.Assign(3, 2, 19, 3);
Control2 := New(PCheckboxes, Init(R,
  NewSItem('~О~т текущих', Nil)));
Dlg^.Insert(Control2);

If Not (Pharm=1) Then Control2^.Options := Control2^.Options and not ofSelectable;

{If Not (Pharm=1) Then} Moroz:=0;{ Else Moroz:=1;}
Control2^.SetData(Moroz);

Dlg^.SelectNext(False);

Event.KeyCode:=kbEnd;
Event.What:=evKeyDown;
Application^.PutEvent(Event);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Control1^.GetData(sw);
  Control2^.GetData(Moroz);
  st:=sw;
  Dispose(Control,Done);
  Dispose(Control1,Done);
  Dispose(Control2,Done);
  Dispose(Dlg,Done);
  DelSpace(St);

  If (St[1] in['2','3','4','5']) And Not(StrToInt(CurrentPassword)=0) Then
   Begin
    MessageBox(^M+#3'Ваш уровень доступа не позволяет провести данную операцию',Nil,mfWarning+mfCancelButton);
    Exit;
   End;

  St:='1.'+st;
  If StrToReal(st)>1.5 Then
   Begin
    Messagebox(^M+#3'Недопустимая ВЕЛИЧИНА скидки!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  If StrToReal(st)<1.00 Then
   Begin
    Messagebox(^M+#3'Недопустимое ЗНАЧЕНИЕ скидки!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   {вставить код изменения скидки}

If P^.List^.Count>0 Then
Begin

  R.Assign(0,0,0,0);
  WspomlIST1 := New(PBox, Init(R, 1, Nil));
  WspomList1^.NewList(New(PTextCollection, Init(0,1)));

{ s:=s+SKol+'│'+SZena+'│'+PC^.RZ+'│'+SSkidka+'│'+IntToStr(SNadoSertif,COne)+'│'+SName;}


For ls:=0 To P^.List^.Count-1 Do
 Begin
{артикул}
 s:=P^.GetText(ls,P^.List^.Count);
 Zena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1,CZena);{лобовая цена}

 If Moroz=1 Then
  Begin
   Skidka:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1,CZena);{скидка}
   MyStr(StrToReal(Zena)-StrToReal(Skidka),CZena,CMantissa,Zena);
  End;

 MyStr(StrToReal(Zena)-(StrToReal(Zena)/(StrToReal(st))),CZena,CMantissa,ws);
{Удаляем старую ручную скидку}

 If Moroz=1 Then
  Begin
   MyStr(StrToReal(ws)+StrToReal(Skidka),CZena,CMantissa,ws);
  End;

 {справляем скидку}
 System.Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1,CZena);
{Добавляем новую ручную скидку}
 System.Insert(ws,S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1);

 {лобовая цена}
 Zena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1,CZena);
 MyStr(StrToReal(Zena)-StrToReal(ws),CZena,CMantissa,Zena);

 {исправляем цену к оплате}
 System.Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1,CZena);
{Добавляем новую ручную скидку}
 System.Insert(Zena,S,1+CName+1+CArtikul+1+COne+1+CKol+1);



{вставляем исправленную строку}
 WspomList1^.List^.Insert(NewStr(s));
 WspomList1^.SetRange(WspomList1^.List^.Count);

End;{For}
{очистка P}
  P^.NewList(Nil);
  P^.NewList(New(PTextCollection, Init(0,1)));

{обновление P}
For ls:=0 To WspomList1^.List^.Count-1 Do
 Begin
{артикул}
 s:=WspomList1^.GetText(ls,WspomList1^.List^.Count);
 P^.List^.Insert(NewStr(s));
 P^.SetRange(P^.List^.Count);
End;{For}

{удаление Wspom}
Dispose(WspomList1,Done);
P^.FocusItem(0);

End;{P^.List^.Count>0}
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(Control1,Done);
  Dispose(Control2,Done);
  Dispose(Dlg,Done);
 End;
End;{If P^.List^.Count>0 Then}
end;


Function GetSrok(Var P:PPredZakazType):Boolean;
LabeL 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  SSrok : String[CMantissa];
begin
GetSrok:=False;

If P^.Dat.DocSelector in [0,1,2,3,4] Then
 Begin
  P^.Dat.Rezerv:=0;
  GetSrok:=True;
  Exit;
 End;

SSrok:=IntToStr(P^.Dat.Rezerv,CKol);

If StrToInt(SSrok)=0 Then
Begin
SSrok:=GetClientField(FVip,P^.Dat.ClientKod,0);
DelSpace(SSrok);
If StrToInt(SSrok)=0 Then SSrok:='';
End;



1:

R.Assign(29, 9, 51, 14);
New(Dlg, Init(R, ''));
Dlg^.HelpCtx:=$E002;

R.Assign(11, 2, 16, 3);
Control := New(PInputLine, Init(R, CMantissa));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(1, 2, 11, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Отсрочка:', Control)));

R.Assign(17, 2, 21, 3);
Control := New(PColoredText, Init(R, 'дней', $7F));
Dlg^.Insert(Control);


Dlg^.SelectNext(False);

Dlg^.SetData(SSrok);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(SSrok);

  If Not (StrToInt(SSrok) in [1..99]) Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    Goto 1;
   End;

  P^.Dat.Rezerv:=StrToInt(SSrok);
  GetSrok:=True;
 End;

Dispose(Control,Done);
Dispose(Dlg,Done);

end;





Function TSuperZakazWindow.Start(Var P:PPredZakazType):Boolean;
Var Docs : ArtikulStr;
    Event : TEvent;
    c,i : LongInt;
    S : String;
    SProz,SSertif,SZena,SKol,SOtd,SRZena,SSkidka : AllStr;
    SName2 : TMyString;
    R : TRect;
    SOpl,SSkid : AllStr;
    PrevStatus : Word;
Begin
  Start:=False;
  PrevStatus:=Glob.Status;
  Status:=DocEdit;
  FStr[0]:=#0;

  New(WPZ,Init);
  WPZ^.Dat:=P^.Dat;
  Docs:=P^.Dat.Document;
{блокируем заказ}
  i:=LockPredZakaz(Docs,WPZ);
  If I=2 Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать предзаказ N '+WPZ^.Dat.Document+'. Попробуйте повторить!',False);
    Dispose(WPZ,Done);
    Application^.ClearEvent(Event);
    Application^.GetEvent(Event);
    Application^.ClearEvent(Event);
    repeat
     Application^.GetEvent(Event);
    until (Event.What <> evNothing) And (Event.Command<>cmMenu);
    NoInfoMsg;
    Application^.ClearEvent(Event);
    Glob.Status:=PrevStatus;
    Exit;
   End;

   If I<>0 Then
    Begin
     Dispose(WPZ,Done);
     Glob.Status:=PrevStatus;
     exit;
    End;

{Если нет выход}
DInfoMsg('Минуточку...',False);

{создаем окно}
R.Assign(0, 0, 80, 23);
New(ZWin, Init(R, 'Коррекция предзаказа'));
ZWin^.HelpCtx:=$F985;


R.Assign(1, 0, 1+2+Length('Док-нт:'+WPz^.Dat.Document+'/'+
IntToStr(WPz^.Dat.ClientNumer,CDocNumer)+' '+WPz^.Dat.Date), 1);
DelSpace(WPz^.Dat.Document);

Control := New(PColoredText, Init(R, #3'Док-нт:'+WPz^.Dat.Document+'/'+
IntToStr(WPz^.Dat.ClientNumer,CDocNumer)+' '+WPz^.Dat.Date, $4E));
zWin^.Insert(Control);


R.Assign(1, 1, 29, 4);
ControlDoc := New(PRadioButtons, Init(R,
  NewSItem('Сп',
  NewSItem('~Т~ч',
  NewSItem('Ф.Л',
  NewSItem('СФ*',
  NewSItem('СФБ',
  NewSItem('~Д*~',
  NewSItem('Д~С~Ф',
  NewSItem('Д',
  NewSItem('ДС~Ф~Б', Nil)))))))))));
ZWin^.Insert(ControlDoc);

ControlDoc^.SetDAta(WPZ^.Dat.DocSelector);


RFormatZerro(WPZ^.Dat.ClientKod,CClientKod);
PrevS:=GetClientField(FClient,WPZ^.Dat.ClientKod,WPZ^.Dat.OperatorSelector);
Format(PrevS,CClient);
PrevS:=PrevS+'│'+WPZ^.Dat.ClientKod;

ZWin^.Koef:=StrToReal(GetClientField(FProz,WPZ^.Dat.ClientKod,WPZ^.Dat.OperatorSelector));

R.Assign(52, 1, 79, 2);
ControlClient := New(PColoredText, Init(R, #3+PrevS, $1F));
If StrToInt(CurrentPassword)=0 Then
ControlClient^.Options := ControlClient^.Options or ofSelectable;
ZWin^.Insert(ControlClient);

R.Assign(44, 1, 52, 2);
ZWin^.Insert(New(PLabel, Init(R, 'Кл~и~ент:', ControlClient)));

RFormatZerro(WPZ^.Dat.AgentKod,CClientKod);
PrevAgent:=GetAgentField(FAgent,WPZ^.Dat.AgentKod);
Format(PrevAgent,CClient);
PrevAgent:=PrevAgent+'│'+WPZ^.Dat.AgentKod;


R.Assign(52, 2, 79, 3);
ControlAgent := New(PColoredText, Init(R, #3+PrevAgent, $1F));
ControlAgent^.Options := ControlAgent^.Options or ofSelectable;
ZWin^.Insert(ControlAgent);

R.Assign(45, 2, 52, 3);
ZWin^.Insert(New(PLabel, Init(R, '~А~гент:', ControlAgent)));


R.Assign(47, 3, 79, 4);
ControlSkidkaSelector := New(PRadioButtons, Init(R,
  NewSItem('Авто',
  NewSItem('Ручн.',
  NewSItem('Шкала', Nil)))));
ControlSkidkaSelector^.SetData(Wpz^.Dat.SkidkaSelector);
ControlSkidkaSelector^.Options := ControlSkidkaSelector^.Options and Not ofSelectable;
ZWin^.Insert(ControlSkidkaSelector);

  R.Assign(39, 3, 47, 4);
  ZWin^.Insert(New(PLabel, Init(R, 'Скидка:', ControlSkidkaSelector)));

R.Assign(37, 5, 38, 17);
Control := New(PScrollBar, Init(R));
ZWin^.Insert(Control);

R.Assign(1, 5, 37, 17);
SkladList := New(PBox, Init(R, 1, PScrollbar(Control)));
SkladList^.NewList(New(PTextCollection, Init(0,1)));
SkladList^.HelpCtx:=$F985;
SkladList^.FocusItem(0);

ZWin^.Insert(SkladList);

  R.Assign(1, 4, 36, 5);
  ZWin^.Insert(New(PLabel, Init(R, 'На складе                   Код  О', SkladList)));

R.Assign(79, 5, 80, 20);
ControlS := New(PScrollBar, Init(R));
ZWin^.Insert(ControlS);

R.Assign(38, 5, 79, 20);
PredZakazList := New(PBox, Init(R, 1, PScrollbar(ControlS)));
PredZakazList^.NewList(New(PTextCollection, Init(0,1)));

{структура PredZakazList}
{Имя│код│отдел│Колич│Цена опл│цена Лоб│Скидка│}


For c:=1 To Wpz^.Dat.Amount Do
 Begin
  RFormatZerro(Wpz^.DAt.Element[c].BazKod,CArtikul);
  sNAme2:=GetIdField(FFFName,Wpz^.DAt.Element[c].BazKod);
  Format(SNAme2,CName+1+CName);
  s:=Copy(sName2,1,CNAme);
  Format(s,CNAme);
  DelSpace(Wpz^.DAt.Element[c].Kol);
  DelSpace(Wpz^.DAt.Element[c].Zena);
  RFormat(Wpz^.DAt.Element[c].Kol,CKOl);
  RFormat(Wpz^.DAt.Element[c].Zena,CZena);
  SZena:=BakGetField(FRzena,Wpz^.DAt.Element[c].BazKod,0);
  DelSpace(SZena);
  RFormat(SZena,CZena);
  MyStr(StrToReal(SZena)-StrToReal(Wpz^.DAt.Element[c].Zena),CZena,CMantissa,SSkidka);

  If Wpz^.DAt.Element[c].NAdoSertif>1 Then Wpz^.DAt.Element[c].NAdoSertif:=1;
  SSertif:=IntToStr(Wpz^.DAt.Element[c].NAdoSertif,COne);

  SProz:='0.0000';

  s:=s+'│'+Wpz^.DAt.Element[c].BazKod+'│'+IntToStr(Wpz^.DAt.Element[c].DivisionNumber,COne)+'│'+
  Wpz^.DAt.Element[c].Kol+'│'+Wpz^.DAt.Element[c].Zena+'│'+SZena+'│'+SSkidka+'│'+SSertif+'│'+SName2;
  PredZakazList^.List^.Insert(NewStr(s));
  PredZakazList^.SetRange(PredZakazList^.List^.Count);
 End;
PredZakazList^.HelpCtx:=$F985;
PredZakazList^.FocusItem(0);
ZWin^.Insert(PredZakazList);

  R.Assign(38, 4, 55, 5);
  ZWin^.Insert(New(PLabel, Init(R, 'В заказе клиента', PredZakazList)));




R.Assign(64, 4, 79, 5);
ControlDef := New(PColoredText, Init(R, ' Дефицит:???',{77} $5F));
ZWin^.Insert(ControlDef);

R.Assign(29, 17, 37, 18);
ControlZena := New(PColoredText, Init(R, #3+'', $7E));
ZWin^.Insert(ControlZena);

R.Assign(24, 17, 29, 18);
Control := New(PColoredText, Init(R, 'Цена:', $74));
ZWin^.Insert(Control);

R.Assign(10, 17, 22, 18);
ControlKol := New(PColoredText, Init(R, #3+'', $7E));
ZWin^.Insert(ControlKol);

R.Assign(1, 17, 10, 18);
Control := New(PColoredText, Init(R, 'Доступно:', $74));
ZWin^.Insert(Control);

R.Assign(27, 18, 37, 19);
ControlDateEnd := New(PInputLine, Init(R, CDate));
ZWin^.Insert(ControlDateEnd);
  PInputLine(ControlDateEnd)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(12, 18, 27, 19);
  ZWin^.Insert(New(PLabel, Init(R, 'Дата доставки:', ControlDateEnd)));

ControlDateEnd^.SetData(WPz^.Dat.DateEnd);

R.Assign(1, 19, 37, 20);
ControlComment1 := New(PInputLine, Init(R, CAll));
ZWin^.Insert(ControlComment1);

ControlComment1^.SetData(WPz^.Dat.Comment1);


R.Assign(1, 20, 37, 21);
ControlComment2 := New(PInputLine, Init(R, CAll));
ZWin^.Insert(ControlComment2);

ControlComment2^.SetData(WPz^.Dat.Comment2);


DelSpace(Wpz^.Dat.Skidka);
R.Assign(14, 22, 14+2+Length('Скидка:'+Wpz^.Dat.Skidka), 23);
ControlAllSkidka := New(PColoredText, Init(R, #3+'Скидка:'+Wpz^.Dat.Skidka, $4E));
ZWin^.Insert(ControlAllSkidka);

DelSpace(Wpz^.Dat.Summa);
R.Assign(39, 22,39+2+Length('К оплате:'+Wpz^.Dat.Summa), 23);
ControlSumma := New(PColoredText, Init(R, #3+'К оплате:'+Wpz^.Dat.Summa, $4E));
ZWin^.Insert(ControlSumma);

R.Assign(1, 21, 72, 22);
ControlName := New(PColoredText, Init(R, #3+'', $7E));
ZWin^.Insert(ControlName);

R.Assign(66, 22,66+2+Length('Позиций:'+IntToStr(WPZ^.Dat.Amount,CMantissa)), 23);
ControlAmount := New(PColoredText, Init(R, #3'Позиций:'+IntToStr(WPZ^.Dat.Amount,CMantissa), $4E));
ZWin^.Insert(ControlAmount);

R.Assign(1, 18, 12, 19);
Control := New(PColoredText, Init(R, 'Комментарий', $74));
ZWin^.Insert(Control);


R.Assign(39, 20, 51, 21);
Control := New(PColoredText, Init(R, 'Цена оплаты:', $74));
ZWin^.Insert(Control);

R.Assign(51, 20, 59, 21);
ControlMZena := New(PColoredText, Init(R, #3'', $7E));
ZWin^.Insert(ControlMZena);

R.Assign(67, 20, 75, 21);
ControlMSkidka := New(PColoredText, Init(R, #3'', $7E));
ZWin^.Insert(ControlMSkidka);

R.Assign(60, 20, 67, 21);
Control := New(PColoredText, Init(R, 'Скидка:', $74));
ZWin^.Insert(Control);




CurrentLineSklad:=NewStr('?');
CurrentLineZakaz:=NewStr('?');
CurrentName:=NewStr('?');

PredZakazList^.Select;

NoInfoMsg;

RefreshSklad;
CalcItogo(SOpl,SSkid);
AddName;


c:=Desktop^.ExecView(ZWin);

If c<>cmCancel Then
 Begin
  Start:=True;
  P^.DAt:=wPZ^.Dat;
  Repeat
  Until (UnLockPredZakaz(WPZ^.Dat.Document) in [0,2]);
 End
 Else
   Begin
    Repeat
    Until (UnLockPredZakaz(WPZ^.Dat.Document) in [0,2]);
   End;

 Dispose(Control,Done);
 Dispose(ControlS,Done);
 Dispose(SkladList,Done);
 Dispose(PredZakazList,Done);
 Dispose(WPZ,Done);
 Dispose(ZWin,Done);
 DisposeStr(CurrentLineSklad);
 DisposeStr(CurrentLineZakaz);
 DisposeStr(CurrentName);
 Glob.Status:=PrevStatus;


End;

procedure TSuperZakazWindow.HandleEvent(var Event: TEvent);

Var Save : Boolean;


Function FindElement(St:TDateString):Boolean;
Var r,cur : Word;
         s : String;

Begin
 DelSpace(St);
 FindElement:=FAlse;
 DInfoMsg('Минуточку...',False);
 if (SkladList^.State and sfFocused <> 0)Then
 Begin
  R:=SkladList^.Focused;
  For Cur:=R To SkladList^.List^.Count-1 Do
        Begin
         s:=SkladList^.GetText(Cur,SkladList^.List^.Count);
         s:=Copy(s,1+CNAme+1+CArtikul+1+1+1,CZena);
         DelSpace(s);
         If s=St Then
          Begin
                NoInfoMsg;
                SkladList^.FocusItem(Cur);
                FindElement:=True;
                Break;
          End;
        End;{For}
 End;

 NoInfoMsg;
End;




procedure Calculator;
begin
  Calc^.Start;
end;

Var s,ss,sn : String;
    VidSkidka,ls,Test : Word;
    SOpl,ClientKod,SSkid : AllStr;
    R : Trect;
Begin

  Case Event.What Of
  evKeyDown :
        Case Event.KeyCode Of
  kbGrayPlus,
  kbAltF1   : Begin

               ControlSkidkaSelector^.GetData(VidSkidka);
               If ((VidSkidka=1))  Then
               Begin
                {if (PredZakazList^.State and sfFocused <> 0)Then }GlobalSkidka(PredZakazList);
                AddName;
                CalcItogo(SOpl,SSkid);
                Redraw;
                ClearEvent(Event);
               End
               Else ClearEvent(Event);
               End;


  kbGrayMinus,
  kbAltF2   : Begin

               ControlSkidkaSelector^.GetData(VidSkidka);
               If ((VidSkidka=1))  Then
               Begin
                {if (PredZakazList^.State and sfFocused <> 0)Then }GlobalNazenka(PredZakazList);
                AddName;
                CalcItogo(SOpl,SSkid);
                Redraw;
                ClearEvent(Event);
               End
               Else ClearEvent(Event);
               End;

          kbCtrlRusJa,KbIns:Begin
                If  ((SkladList^.State and sfFocused <> 0) And (SkladList^.List<>Nil)And(SkladList^.List^.Count>=1)) Then
                                                Begin
                                                 sn:=FindZena;
                                                 If Sn<>'' Then
                                                  Begin
If Not(FindElement(Sn)) Then
Begin
          DinfoMsg('Внимание! Товар с ценой '+Sn+' не найден!',False);
          ClearEvent(Event);
          repeat
                 Application^.GetEvent(Event);
          until (Event.What <> evNothing) And (Event.Command<>cmMenu);
          NoInfoMsg;
          ClearEvent(Event);
          Exit;
End;                Redraw;
                                                  End
                                                End;
                                          End;

  kbCtrlRusI :Begin
               If InputFindStr Then
                 RefreshSklad;
              End;

        kbCtrlDel:Begin

     If (PredZakazList^.State and sfFocused <> 0) And (PredZakazList^.List<>Nil)And(PredZakazList^.List^.Count>=1) Then
            Begin
             If MessageBox(#3+DelAll^,nil,mfConfirmation+mfOkCancel)=cmOk Then
             Begin
                 {
                 PredZakazList^.NewList(nil);
                 PredZakazList^.NewList(New(PTextCollection, Init(0,1)));
			  }



(*
Dispose(PredZakazList,Done);
Dispose(ControlS,Done);
R.Assign(79, 5, 80, 20);
ControlS := New(PScrollBar, Init(R));
ZWin^.Insert(ControlS);

R.Assign(38, 5, 79, 20);
PredZakazList := New(PBox, Init(R, 1, PScrollbar(ControlS)));
PredZakazList^.NewList(New(PTextCollection, Init(0,1)));
ZWin^.Insert(PredZakazList);
PredZakazList^.HelpCtx:=$F985;
PredZakazList^.FocusItem(0);

R.Assign(38, 4, 55, 5);
ZWin^.Insert(New(PLabel, Init(R, 'В заказе клиента', PredZakazList)));

PredZakazList^.Select;
PredZakazList^.Select;
PredZakazList^.Select;
*)
             PredZakazList^.List^.FreeAll;
             PredZakazList^.SetRange(PredZakazList^.List^.Count);
{
             While (PredZakazList^.List^.Count>0) Do
              Begin
               PredZakazList^.List^.AtFree(0);
               PredZakazList^.SetRange(PredZakazList^.List^.Count);
              End;
}


                 CalcItogo(SOpl,SSkid);
                 AddName;
                 ClearEvent(Event);
                 Redraw;
             End;
            End;
                  End;

        kbDel:Begin
          If (PredZakazList^.State and sfFocused <> 0) And (PredZakazList^.List<>Nil)And(PredZakazList^.List^.Count>=1) Then
                     Begin
                      ClearFind;
                      If MessageBox(#3+DelTovar^,nil,mfConfirmation+mfOkCancel)=cmOk Then
                       Begin
                        PredZakazList^.List^.AtFree(PredZakazList^.Focused);
                        PredZakazList^.SetRange(PredZakazList^.List^.Count);

                        If PredZakazList^.Focused>0 Then PredZakazList^.FocusItem(PredZakazList^.Focused);

                        If (PredZakazList^.Focused>=PredZakazList^.List^.Count) and(PredZakazList^.Focused>0) Then
                        PredZakazList^.FocusItem(PredZakazList^.Focused-1);

                        CalcItogo(SOpl,SSkid);
                        AddName;
                        Redraw;
                       End;
                      ClearEvent(Event);
                     End;
              End;

        kbF4:Begin
              End;

        kbEnter:Begin

     If (SkladList^.State and sfFocused <> 0) And (SkladList^.List<>Nil)And(SkladList^.List^.Count>=1) Then
            Begin
     If (SkladList^.State and sfFocused <> 0) And (SkladList^.List<>Nil) And (PredZakazList^.List^.Count>CMax-1) Then
              Begin
      MessageBox(#3^M+#3'В документе может быть'^M+
                 #3'не более '+ IntToStr(CMax,2)+' наименований !',Nil,mfError+mfCanCelButton);
               ClearEVent(Event);
               Exit;
              End;

              s:=SkladList^.GetText(SkladList^.Focused,SkladList^.List^.Count);

 PStaticText(ControlClient)^.GetText(sS);
 System.Delete(Ss,Pos(#3,Ss),1);
 ClientKod:=Copy(ss,1+CClient+1,CClientKod);

              Cart^.Edit(s,ClientKod,ZWin^.Koef);

                If (SkladList^.Focused+1)<SkladList^.List^.Count Then
                 Begin
                 SkladList^.FocusItem(SkladList^.Focused+1);
                 End;

                        CalcItogo(SOpl,SSkid);
                        AddName;
                        Redraw;

              ClearEVent(Event);
            End;{SkladList^.Focused}


     If (PredZakazList^.State and sfFocused <> 0) And (PredZakazList^.List<>Nil)And(PredZakazList^.List^.Count>=1) Then
            Begin
     If (PredZakazList^.State and sfFocused <> 0) And (PredZakazList^.List<>Nil) And (PredZakazList^.List^.Count>CMax-1) Then
              Begin
      MessageBox(#3^M+#3'В документе может быть'^M+
                 #3'не более '+ IntToStr(CMax,2)+' наименований !',Nil,mfError+mfCanCelButton);
               ClearEVent(Event);
               Exit;
              End;

 PStaticText(ControlClient)^.GetText(sS);
 System.Delete(Ss,Pos(#3,Ss),1);
 ClientKod:=Copy(ss,1+CClient+1,CClientKod);

              s:=PredZakazList^.GetText(PredZakazList^.Focused,PredZakazList^.List^.Count);
              Cart^.Edit(s,ClientKod,ZWin^.Koef);

                If (PredZakazList^.Focused+1)<PredZakazList^.List^.Count Then
                 Begin
                 PredZakazList^.FocusItem(PredZakazList^.Focused+1);
                 End;


              CalcItogo(SOpl,SSkid);
              AddName;
              Redraw;
              ClearEVent(Event);
            End;{SkladList^.Focused}

                End;
        Else;
        End;


  evCommand :
        Case Event.Command Of
        cmLocalCalc:Begin
	               Calculator;
                    End;
        cmRefresh: Begin
                     ClearFind;
                      Begin
                       RefreshSklad;
                       CalcItogo(SOpl,SSkid);
                      End;
                     ClearEvent(Event);
                   End;

cmViewPrihodTovar
     :Begin
       ClearFind;

if (PredZakazList^.State and sfFocused <> 0) And(PredZakazList^.List<>Nil) And (PredZakazList^.List^.Count>=1)Then
      If (PredZakazList^.List^.Count-1)>=0 Then
       begin
         sn:=Copy(PredZakazList^.GetText(PredZakazList^.Focused,PredZakazList^.List^.Count),1+CName+1,Cartikul);
         FP^.FindScreenPrh(sn);
        ClearEvent(Event);
       End;

if (SkladList^.State and sfFocused <> 0) And(SkladList^.List<>Nil) And (SkladList^.List^.Count>=1)Then
      If (SkladList^.List^.Count-1)>=0 Then
       begin
         sn:=Copy(SkladList^.GetText(SkladList^.Focused,SkladList^.List^.Count),1+CName+1,Cartikul);
         FP^.FindScreenPrh(sn);
        ClearEvent(Event);
       End;

       ClearEvent(Event);
      End;

     cmOk:Begin
           {сохранение}
           SaveToFile(Save);
           If Not Save Then
            Begin
             ClearEvent(Event);
             Event.What:=EvCommand;
             Event.Command:=cmNone;
             PutEvent(Event);
             ClearEvent(Event);
            End;
          End;

     cmFindLink:Begin
       ClearFind;

if (PredZakazList^.State and sfFocused <> 0) And(PredZakazList^.List<>Nil) And (PredZakazList^.List^.Count>=1)Then
      If (PredZakazList^.List^.Count-1)>=0 Then
       begin
         sn:=Copy(PredZakazList^.GetText(PredZakazList^.Focused,PredZakazList^.List^.Count),1+CName+1,Cartikul);
         Lnk^.Start(sn);
        ClearEvent(Event);
       End;

if (SkladList^.State and sfFocused <> 0) And(SkladList^.List<>Nil) And (SkladList^.List^.Count>=1)Then
      If (SkladList^.List^.Count-1)>=0 Then
       begin
         sn:=Copy(SkladList^.GetText(SkladList^.Focused,SkladList^.List^.Count),1+CName+1,Cartikul);
         Lnk^.Start(sn);
        ClearEvent(Event);
       End;

       ClearEvent(Event);

                End;


     cmViewBron
        :Begin
       ClearFind;

if (PredZakazList^.State and sfFocused <> 0) And(PredZakazList^.List<>Nil) And (PredZakazList^.List^.Count>=1)Then
      If (PredZakazList^.List^.Count-1)>=0 Then
       begin
        Sn:=Copy(PredZakazList^.GEtTExt(PredZakazList^.Focused,PredZakazList^.List^.Count),1+CName+1,CArtikul);
        If FR^.Start(Sn,True) Then  RefreshSklad;
        ClearEvent(Event);
       End;

if (SkladList^.State and sfFocused <> 0) And(SkladList^.List<>Nil) And (SkladList^.List^.Count>=1)Then
      If (SkladList^.List^.Count-1)>=0 Then
       begin
        Sn:=Copy(SkladList^.GEtTExt(SkladList^.Focused,SkladList^.List^.Count),1+CName+1,CArtikul);
        If FR^.Start(Sn,True) Then  RefreshSklad;
        ClearEvent(Event);
       End;
       ClearEvent(Event);
      End;


  cmCancel: Begin
             If MessageBox(#3^M+#3'Желаете отказаться от корректировки ПредЗаказа ?',Nil,mfConFirmation+mfOkCancel)<>cmOk Then
              Begin
               ClearEvent(Event);
              End;
            End;

  cmSelectAgent:
 Begin
  If (PView(Ag)<>Desktop^.TopView)And(ControlAgent^.State and sfFocused <> 0) Then
  Begin
     PStaticText(ControlAgent)^.GetText(S);
     System.Delete(S,1,1);
     Ag^.ShowAgentList(s,Test);
     PStaticText(ControlAgent)^.Text^:=#3+S;
     Redraw;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
     End;
     Redraw;
     ClearEvent(Event);
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);

     ClearEvent(Event);

  End
  Else
  ClearEvent(Event);
 End;


  cmSelectClient:
 Begin
  If (PView(Cl)<>Desktop^.TopView)And(ControlClient^.State and sfFocused <> 0) Then
  Begin
        ClearFind;
        ControlClient^.Focus;
        PStaticText(ControlClient)^.GetText(S);
        System.Delete(S,1,1);
        Cl^.ShowClientList(s,0,0,True,False,-1,-1,-1,-1,Test);
        PStaticText(ControlClient)^.Text^:=#3+S;
        PrevS:=S;
        Case Test Of
         0,3 :FocusNext(True);
         1,2 :FocusNext(False);
        Else;
        End;
        ClearEvent(Event);
        Redraw;
  End
  Else
        ClearEvent(Event);
 End;
         Else;
         End;{evCommand}
         Else;
         End;{*Case*}


 If (PView(Cl)<>Desktop^.TopView)And(ControlClient^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectClient) And (Event.What <> EvKeyDown)Then
                  Begin
                   Event.What:=EvCommand;
                   Event.Command:=cmSelectClient;
                   PutEvent(Event);
                   ClearEvent(Event);
                  End;

 If (PView(Ag)<>Desktop^.TopView)And(ControlAgent^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectAgent) And (Event.What <> EvKeyDown)Then
                  Begin
                   Event.What:=EvCommand;
                   Event.Command:=cmSelectAgent;
                   PutEvent(Event);
                   ClearEvent(Event);
                  End;
  inherited HandleEvent(Event);


 If (Desktop^.Current=PView(ZWin)) Then
           Begin
            DrawCurrent;
           End;



  ClearEvent(Event);
End;

procedure TSuperZakazWindow.AddName;
Var R : TRect;
Begin
Dispose(ControlAmount,Done);
R.Assign(66, 22,66+2+Length('Позиций:'+IntToStr(PredZakazList^.List^.Count,CMantissa)), 23);
ControlAmount := New(PColoredText, Init(R, #3'Позиций:'+IntToStr(PredZakazList^.List^.Count,CMantissa), $4E));
ZWin^.Insert(ControlAmount);
End;





procedure TSuperZakazWindow.CalcItogo(Var SOpl,SSkid: AllStr);
Var R : TRect;
    wKol,wSkidka,wSumma,wZena,wProz,SSkidka,SSumma : AllStr;
    PrevS : String;
    VidSkidka : Word;
    c : Word;
Begin

SSkidka[0]:=#0;
SSumma[0]:=#0;
ControlSkidkaSelector^.GetData(VidSkidka);

If (PredZakazList^.List<>Nil)And(PredZakazList^.List^.Count>=1) Then
 Begin
  For c:=0 To PredZakazList^.List^.Count-1 Do
   Begin
    PrevS:=PredZakazList^.GetText(c,PredZakazList^.List^.Count);

  {
  s:=s+'│'+Wpz^.DAt.Element[c].BazKod+'│'+IntToStr(Wpz^.DAt.Element[c].DivisionNumber,COne)+'│'+
  Wpz^.DAt.Element[c].Kol+'│'+Wpz^.DAt.Element[c].Zena+'│'+SZena+'│'+SSkidka+'│'+SSertif+'│'+SName2;
  }


   wKol:=Copy(PrevS,1+CNAme+1+CArtikul+1+COne+1,CKol);
   DelSpace(wKol);

   wSkidka:=Copy(PrevS,1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1,CZena);
   DelSpace(wSkidka);

   wZena:=Copy(PrevS,1+CNAme+1+CArtikul+1+COne+1+CKol+1,CZena);
   DelSpace(wZena);

   MyStr(StrToreal(SSkidka)+StrToReal(wSkidka)*StrToInt(wKol),CIZena,CMantissa,SSkidka);
   MyStr(StrToreal(SSumma)+StrToReal(wZena)*StrToInt(wKol),CIZena,CMantissa,SSumma);
{
   Writeln(wKol+';'+wZena+';'+wSkidka);
   readln;
}
   End;
 End;

MyStr(StrToReal(SSkidka),CIZena,CMantissa,SSkidka);
MyStr(StrToReal(SSumma),CIZena,CMAntissa,SSumma);
DelSpace(SSkidka);
DelSpace(SSumma);


SOpl:=SSumma;
SSkid:=SSkidka;
Dispose(ControlAllSkidka,Done);
R.Assign(14, 22, 14+2+Length('Скидка:'+SSkidka), 23);
ControlAllSkidka := New(PColoredText, Init(R, #3+'Скидка:'+SSkidka, $4E));
ZWin^.Insert(ControlAllSkidka);

Dispose(ControlSumma,Done);
R.Assign(39, 22,39+2+Length('К оплате:'+SSumma), 23);
ControlSumma := New(PColoredText, Init(R, #3+'К оплате:'+SSumma, $4E));
ZWin^.Insert(ControlSumma);

End;




Procedure TSuperZakazWindow.SaveToFile(Var Save : Boolean);
Var c : Word;
    j,l : LongInt;
    Ver : Word;
    s : String;
    Event : TEvent;
Begin
Save:=False;{запись не удалась}

If MessageBox(^M+#3'Желаете сохранить внесенные изменения?',Nil,mfConfirmation+mfOkCancel)=cmCancel Then
 Begin
  Exit;
 End;



wPZ^.DAt.Amount:=0;

With wPZ^.DAt Do
Begin
 ClientKod[0]:=#0;
 AgentKod[0] :=#0;

 PStaticText(ControlClient)^.GetText(S);
 System.Delete(S,Pos(#3,S),1);
 ClientKod:=Copy(s,1+CClient+1,CClientKod);


 PStaticText(ControlAgent)^.GetText(S);
 System.Delete(S,Pos(#3,S),1);
 AgentKod:=Copy(s,1+CClient+1,CClientKod);


 Comment1[0] :=#0;
 Comment2[0] :=#0;
 DateM:=DateStringToDate(DateMAsk,FDate);
 TimeM:=TimeStringToTime(TimeMask,Times);
 Sf:=0;
 Summa[0]:=#0;
 SertifSumma[0]:=#0;
 Skidka[0]:=#0;
 SertifSkidka[0]:=#0;
 Caption:=CurrentPassword;
 Amount:=0;

for c:=1 To CMax Do
 Begin
  Element[c].Kol[0]:=#0;
  Element[c].Fakt:=0;
  Element[c].BazKod[0]:=#0;
  Element[c].Zena[0]:=#0;
  Element[c].NadoSertif:=0;
  Element[c].DivisionNumber:=1;
  Element[c].Zakupka :=0.00;
  Element[c].Skidka:=0.00;
 End;
End;{With}
{очистили переменную}

CalcItogo(Wpz^.DAt.Summa,Wpz^.DAt.Skidka);
ControlComment1^.GetData(Wpz^.DAt.Comment1);
ControlComment2^.GetData(Wpz^.DAt.Comment2);
ControlSkidkaSelector^.GetData(Wpz^.DAt.SkidkaSelector);
ControlDoc^.GetData(Wpz^.DAt.DocSelector);


Wpz^.DAt.Amount:=PredZakazList^.List^.Count;

If Wpz^.DAt.DocSelector In [3,4,6,8] Then Wpz^.DAt.SF:=1;

Wpz^.DAt.OperatorSelector:=0;

ControlDateEnd^.GetData(Wpz^.DAt.DateEnd);
DelSpace(Wpz^.DAt.DateEnd);

If Not TestDAte(Wpz^.DAt.DateEnd,l) Then
 Begin
  MessageBox(^M+#3'Не правильно указана дата доставки!',Nil,
  mfError+mfCancelButton);
  Exit;
 End;


{$IFNDef Pharm}
If Not(GetSrok(Wpz)) Then
 Begin
  Exit;
 End;;
{$EndIf}


j:=1;
If (PredZakazList^.List^.Count)>0 Then
For c:=0 To PredZakazList^.List^.Count-1 Do
 Begin
   s:=PredZakazList^.GetText(c,PredZakazList^.List^.Count);

   wPZ^.Dat.Element[j].Kol:=Copy(S,1+CNAme+1+CArtikul+1+COne+1,CKol);
   DelSpace(wPZ^.Dat.Element[j].Kol);

   wPZ^.Dat.Element[j].DivisionNumber:=StrToInt(Copy(S,1+CNAme+1+CArtikul+1,COne));

   wPZ^.Dat.Element[j].BazKod:=Copy(S,1+CName+1,CArtikul);

   wPZ^.Dat.Element[j].Zena:=Copy(s,1+CNAme+1+CArtikul+1+COne+1+CKol+1,CZena);
   DelSpace(wPZ^.Dat.Element[j].Zena);

   wPZ^.Dat.Element[j].NadoSertif:=StrToInt(Copy(s,1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CZena+1,COne));


  wPZ^.Dat.Element[j].Zakupka :=0.00;

  wPZ^.Dat.Element[j].Skidka:=StrToReal(Copy(S,1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1,CZena));

  If Not Test3(wPZ^.Dat.OperatorSelector,wPZ^.Dat.Element[j].BazKod) Then Exit;

  If Not TestOtdel(wPZ^.Dat.Element[j].DivisionNumber) Then
  Begin
          NoInfoMsg;
          Sound(100);
          DinfoMsg('Опреации с отделения '+IntToStr(wPZ^.Dat.Element[j].DivisionNumber,CKol)+' запрещены!',False);
          Delay(300);
          NoSound;
          ClearEvent(Event);
          repeat
           Application^.GetEvent(Event);
          until (Event.What <> evNothing) And (Event.Command<>cmMenu);
          NoInfoMsg;
          ClearEvent(Event);
          Exit;
  End;



  Inc(j);
 End;{}

wPZ^.Dat.Amount:=j-1;




{закончили модернизацию переменной}
If LockAndWritePredZakaz(WpZ) Then
 Begin
  Save:=True;
 End;







End;{Procedure SaveToFile}





Procedure TSuperZakazWindow.DrawCurrent;
Var PrevS : String;
    SOtd,SKol,SKolR,SZena,SSkidka : AllStr;
    R : TRect;
Begin
{сравниваем текущую строку в SkladList}
if (SkladList^.State and sfFocused <> 0)  Then
Begin
{Writeln('Отрисовываем Склад');}
If (SkladList^.List^.Count>=1) And ((SkladList^.List<>Nil)) Then
Begin
PrevS:=SkladList^.GetText(SkladList^.Focused,SkladList^.List^.Count);
 If CurrentLineSklad^<>PrevS Then
  Begin
   DisposeStr(CurrentLineSklad);
   CurrentLineSklad:=NewStr(PrevS);
{
   Prevs:=SName+'│'+SDate+'│'+SArtik+'│'+SArtikul+'│'+SRZena+
                          '│'+SNAme2+'│'+SNSertif+'│'+
					 IntToStr(BazElement1^.Point.Dat[c].RegionMArka,COne)+'│'+SKOlInd;
}
   SZena:=Copy(PrevS,1+CNAme+1+CArtikul+1+COne+1,CZena);
   DelSpace(SZena);


   Dispose(ControlZena,Done);
   R.Assign(29, 17, 37, 18);
   ControlZena := New(PColoredText, Init(R, SZena, $7E));
   ZWin^.Insert(ControlZena);

   SKol:=Copy(PrevS,1+CNAme+1+CArtikul+1+COne+1+CZena+1+(CName+1+CName)+1+CArtikul+1+COne+1,CKol);
   DelSpace(SKol);

   SKolR:=Copy(PrevS,1+CNAme+1+CArtikul+1+COne+1+CZena+1+(CName+1+CName)+1+CArtikul+1+COne+1+CKol+1,CKol);
   DelSpace(SKolR);

   Dispose(ControlKol,Done);
   R.Assign(10, 17, 22, 18);
   ControlKol := New(PColoredText, Init(R, SKol+'('+SKolR+')', $7E));
   ZWin^.Insert(ControlKol);
  End;
End

 Else
  Begin

   If CurrentLineSklad^<>'???' Then
   Begin
   DisposeStr(CurrentLineSklad);
   CurrentLineSklad:=NewStr('???');


   Dispose(ControlZena,Done);
   R.Assign(29, 17, 37, 18);
   ControlZena := New(PColoredText, Init(R, '???', $7E));
   ZWin^.Insert(ControlZena);

   Dispose(ControlKol,Done);
   R.Assign(10, 17, 22, 18);
   ControlKol := New(PColoredText, Init(R, '???', $7E));
   ZWin^.Insert(ControlKol);
   End;
  End;

End;
 {
 Else
  Begin
   If CurrentLineSklad^<>'???' Then
   Begin
   DisposeStr(CurrentLineSklad);
   CurrentLineSklad:=NewStr('???');


   Dispose(ControlZena,Done);
   R.Assign(29, 17, 37, 18);
   ControlZena := New(PColoredText, Init(R, '???', $7E));
   ZWin^.Insert(ControlZena);

   Dispose(ControlKol,Done);
   R.Assign(10, 17, 22, 18);
   ControlKol := New(PColoredText, Init(R, '???', $7E));
   ZWin^.Insert(ControlKol);
   End;
  End;
 }



{отрисовываем подсказку склада}


{сравниваем текущую строку в PredZakazList}
if (PredZakazList^.State and sfFocused <> 0)  Then
Begin
If (PredZakazList^.List^.Count>=1) And (PredZakazList^.List<>Nil) Then
Begin
 PrevS:=PredZakazList^.GetText(PredZakazList^.Focused,PredZakazList^.List^.Count);
 If CurrentLineZakaz^<>PrevS Then
  Begin
   DisposeStr(CurrentLineZakaz);
   CurrentLineZakaz:=NewStr(PrevS);
{
  s:=s+'│'+Wpz^.DAt.Element[c].BazKod+'│'+IntToStr(Wpz^.DAt.Element[c].DivisionNumber,COne)+'│'+
  Wpz^.DAt.Element[c].Kol+'│'+Wpz^.DAt.Element[c].Zena+'│'+SZena+'│'+SSkidka;
}
   {цена оплаты}
   SZena:=Copy(PrevS,1+CNAme+1+CArtikul+1+COne+1+CKol+1,CZena);
   DelSpace(SZena);

   Dispose(ControlMZena,Done);
   R.Assign(51, 20, 59, 21);
   ControlMZena := New(PColoredText, Init(R, SZena, $7E));
   ZWin^.Insert(ControlMZena);

   SSkidka:=Copy(PrevS,1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1,CZena);
   DelSpace(SSkidka);

   Dispose(ControlMSkidka,Done);
   R.Assign(67, 20, 75, 21);
   ControlMSkidka := New(PColoredText, Init(R, SSkidka, $7E));
   ZWin^.Insert(ControlMSkidka);

   Dispose(ControlDef,Done);

   SKol:=Copy(PrevS,1+CNAme+1+CArtikul+1+COne+1,CKol);
   SOtd:=Copy(PrevS,1+CNAme+1+CArtikul+1,COne);
   SKolR:=IntToStr(
   StrToInt(BakGetField(FDiv,Copy(PrevS,1+CName+1,CArtikul),StrToInt(SOtd)))-
   StrToInt(BakGetField(FDivR,Copy(PrevS,1+CName+1,CArtikul),StrToInt(SOtd))),CKOl);
   If StrToInt(SKolR)<0 Then SKolR:='0';

   DelSpace(SKol);

   R.Assign(64, 4, 79, 5);
   If (StrToInt(SKolR)-StrToInt(SKol)<0) Then
   ControlDef := New(PColoredText, Init(R, ' Дефицит:'+IntToStr(Abs(StrToInt(SKolR)-StrToInt(SKol)),CKol),$5F))
   Else
   ControlDef := New(PColoredText, Init(R, ' Дефицит:???',$77));
   ZWin^.Insert(ControlDef);

  End;
End
 Else
  Begin
   If CurrentLineZakaz^<>'???' Then
   Begin
   DisposeStr(CurrentLineZakaz);
   CurrentLineZakaz:=NewStr('???');

   Dispose(ControlMZena,Done);
   R.Assign(51, 20, 59, 21);
   ControlMZena := New(PColoredText, Init(R, '???', $7E));
   ZWin^.Insert(ControlMZena);

   Dispose(ControlMSkidka,Done);
   R.Assign(67, 20, 75, 21);
   ControlMSkidka := New(PColoredText, Init(R, '???', $7E));
   ZWin^.Insert(ControlMSkidka);

   Dispose(ControlDef,Done);
   R.Assign(64, 4, 79, 5);
   ControlDef := New(PColoredText, Init(R, #3+'???',$77));
   ZWin^.Insert(ControlDef);

   End;
  	End;

End;

{отрисовываем подсказку заказа}



if ((SkladList^.State and sfFocused <> 0) And(SkladList^.List<>Nil) And (SkladList^.List^.Count>=1)) Or
   ((PredZakazList^.State and sfFocused <> 0) And(PredZakazList^.List<>Nil) And (PredZakazList^.List^.Count>=1)) Then
Begin
  if (SkladList^.State and sfFocused <> 0) And(SkladList^.List<>Nil) And (SkladList^.List^.Count>=1) Then
  Begin
   {Writeln('Имя на складе');}
   PrevS:=SkladList^.GetText(SkladList^.Focused,SkladList^.List^.Count);
   If CurrentName^<>PrevS Then
    Begin
     DisposeStr(CurrentName);
     CurrentNAme:=NewStr(PrevS);

     PrevS:=Copy(PrevS,1+CNAme+1+CArtikul+1+COne+1+CZena+1,(CName+1+CName));

     Dispose(ControlName,Done);
     R.Assign(1, 21, 72, 22);
     ControlName := New(PColoredText, Init(R, PrevS, $7E));
     ZWin^.Insert(ControlName);
    End;
  End;


  if (PredZakazList^.State and sfFocused <> 0) And(PredZakazList^.List<>Nil) And (PredZakazList^.List^.Count>=1) Then
  Begin
   {Writeln('Имя в заказе');}
   PrevS:=PredZakazList^.GetText(PredZakazList^.Focused,PredZakazList^.List^.Count);
   If CurrentName^<>PrevS Then
    Begin
     DisposeStr(CurrentName);
     CurrentNAme:=NewStr(PrevS);

     PrevS:=Copy(PrevS,1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CZena+1+COne+1,CName+1+CName);

     Dispose(ControlName,Done);
     R.Assign(1, 21, 72, 22);
     ControlName := New(PColoredText, Init(R, PrevS, $7E));
     ZWin^.Insert(ControlName);
    End;
  End;
End

 Else
  Begin
     {Writeln('Пишем чистое имя');}
     If CurrentName^<>'???' Then
     Begin
     DisposeStr(CurrentName);
     CurrentNAme:=NewStr('???');

     Dispose(ControlName,Done);
     R.Assign(1, 21, 72, 22);
     ControlName := New(PColoredText, Init(R, '???', $7E));
     ZWin^.Insert(ControlName);
     End;
  End;



{проверяем длинное наименование}

End;


Procedure TSuperZakazWindow.RefreshSklad;
Var      R : TRect;
         Propusk,SertifRazdel:Boolean;
         SRZena,SDAte,SNSertif : AllStr;
         PrevS,SName,SName2 : String;
         WspomList : PBox;
         sh,i, c,c1,Count,Count1 : Word;
         BazFilef,RazdelFile : File;
         BazElement1   : PBufSkladTypeNew;
         RazdelElement : PBufRazdelType;
         SArtik,SArtikul,SArt,SKolInd,SKolIndR: ArtikulStr;

Begin
If (FStr[0]=#0) Or (FStr='*') Then Filtr:=False
Else Filtr:=True;

SkladList^.NewList(Nil);
SkladList^.NewList(New(PMyCollection, Init(0,1)));

DisposeStr(CurrentLineSklad);

R.Assign(0, 0, 0, 0);
WspomList := New(PBox, Init(R, 1, Nil));
WspomList^.NewList(New(PTextCollection, Init(0,1)));

Assign (RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
i:=IOResult;
Reset (RazdelFile,SizeOf(RazdelType));
i:=IOResult;
If I<>0 Then Exit;

 While Not(Eof(RazdelFile)) Do
  Begin
   New(RazdelElement,Init);
   Count1:=0;
   BlockRead(RazdelFile,RazdelElement^.Point,BufferRazdel,Count1);

   For c1:=1 To Count1 Do
    Begin
     RFormatZerro(RazdelElement^.Point.Dat[c1].Kod,CRazdelKod);
     DInfoMsgShkala('Выполняется загрузка остатков товара. Раздел '+
     RazdelElement^.Point.Dat[c1].Kod+' ... ',1,EmployRazdel,StrToInt(RazdelElement^.Point.Dat[c1].Kod)+1);

     If (RazdelElement^.Point.Dat[c1].Employ) Then
      Begin
       SertifRazdel:=False;

       If (RazdelElement^.Point.Dat[c1].EnableDoc=1) And (ShowSertif=0) Then Continue;
       If RazdelElement^.Point.Dat[c1].EnableDoc=1 Then SertifRazdel:=True;

           Assign (BazFilef,Path^.Dat.ToIndex+RazdelElement^.Point.Dat[c1].Kod+'.kdx');
           i:=ioresult;
           Reset(BazFilef,SizeOf(SkladTypeNew));
           i:=ioresult;
           If i<>0 Then
            Begin
              MessageBox(^M+#3' Ошибка открытия '+Path^.Dat.ToIndex+RazdelElement^.Point.Dat[c1].Kod+'.kdx'^M+
              #3'Код: '+IntToStr(i,3),Nil,mfError+mfCancelButton);
              Continue;
            End;

             While Not(Eof(BazFilef)) Do
              Begin
               Count:=0;
               New(BazElement1,Init);

               ReadBufNewSklad(BazFilef,BazElement1,Count);

                For c:=1 To Count Do
                 Begin
                  If BazElement1^.Point.Dat[c].Employ Then
                   Begin
                    If (BazElement1^.Point.Dat[c].Kol>0) then
                     Begin

                      SName := BazElement1^.Point.Dat[c].Name+' '+BazElement1^.Point.Dat[c].Name2;


                      If Filtr Then
                      If Not(Pos(FStr,SNAme)>0) Then Continue;

                      SName2 := SName;
                      SDate := IntToSTr(BazElement1^.Point.Dat[c].Virabotano,CDate);
                      RFormat(SDate,CDAte);
                      If SertifRazdel Then SName:='■'+SNAme;
                      SName:=Copy(SName,1,CNAme);
                      Format(SName,CName);

                      If (Pharm=1) and Not SertifRazdel Then
                       Begin
                        SNSertif:=IntToStr(BazElement1^.Point.Dat[c].FirmaPostKod,CClientKod);
                        RFormatZerro(SNSertif,CCLientKod);
                        If SNSertif<>NoPostStr Then
                        SName2:=SName2+'('+GetFirmaPostField(FFirmaPost,SNSertif)+')';
                       End;


                      Format(SName2,CName+1+CName);
                      SNSertif:=IntToStr(BazElement1^.Point.Dat[c].NSertif,CArtikul);
                      RFormatZerro(SNSertif,CArtikul);

                      For i:=1 To CDivision Do
                       Begin

                          If BazElement1^.Point.Dat[c].Division[i]<0 Then
                            BazElement1^.Point.Dat[c].Division[i]:=0;

                          SKolInd:=IntToStr(BazElement1^.Point.Dat[c].Division[i],CKOl);
                          DelSpace(SKolInd);
                          Format(SKolInd,CKol);

                          SKolIndR:=IntToStr(BazElement1^.Point.Dat[c].DivisionR[i],CKOl);
                          DelSpace(SKolIndR);
                          Format(SKolIndR,CKol);
                          If BazElement1^.Point.Dat[c].RegionMArka>1 Then BazElement1^.Point.Dat[c].RegionMArka:=1;
                          Str(i:1,SArtikul);
                          MyStr(BazElement1^.Point.Dat[c].R_Zena,CZena,CMantissa,SRZena);
                          SArtik:=IntToSTr(BazElement1^.Point.Dat[c].BazKod,CArtikul);
                          RFormatZerro(SArtik,CArtikul);
                          Prevs:=SName+'│'+SDate+'│'+SArtik+'│'+SArtikul+'│'+SRZena+
                          '│'+SNAme2+'│'+SNSertif+'│'+
					 IntToStr(BazElement1^.Point.Dat[c].RegionMArka,COne)+'│'+SKOlInd+'│'+
					 SKolIndR;


                          If ((BazElement1^.Point.Dat[c].Division[i]-
					 BazElement1^.Point.Dat[c].DivisionR[i])>0)  Then
                           Begin
                            WspomList^.List^.Insert(NewStr(Prevs));
                            WspomList^.SetRange(WspomList^.List^.Count);
                           End

                       End;{For i:=1 To CDivision Do}

                     End;{l}
                   End;{Employ}
                 End;{For Count}

               Dispose(BazElement1,Done);
              End;{While}


              i:=IOResult;
              System.Close(BazFilef);
              i:=IOResult;

      End;{RazdelElement.Employ}
    End;{For по Count1}
     Dispose(RazdelElement,Done);
  End;{While}

i:=IOResult;
System.Close(RazdelFile);
i:=IOResult;


If WspomList^.List^.Count>0 Then
Begin
 For sh:=0 To WspomList^.List^.Count-1 Do
  Begin
        PrevS:=WspomList^.GetText(sh,WspomList^.List^.Count);
        System.Delete(PrevS,1+CNAme+1,CDate+1);
        SkladList^.List^.Insert(NewStr(Prevs));
        SkladList^.SetRange(SkladList^.List^.Count);
  End;
End;

NoInfoMsg;

Dispose(WspomList,Done);

SkladList^.FocusItem(0);
CurrentLineSklad:=NewStr('?');


ZWin^.Redraw;


End;



Procedure TCartZakazWindow.Edit(s:String;Kod:ArtikulStr;Koef:Real);
Label 15;
var
  R : TRect;
  Control1 : PView;
  SName : TMyString;
  SNDS,SArt,SOtd,SKol,SSkidka,SZena : AllStr;
  SNadoSertif,c : Word;
  LocStatus : Boolean;
  Position : LongInt;
  Skl : PSkladType;
  BBB : PBazType;
  Event : TEvent;
Begin
{
определяем режим
1-новая позиция - все достаем со склада и количество 0 а цена исходя из коэффициента клиента
2-позиция была - все достаем со склада а количество цену к оплате и скидку из накладной
}




DInfoMsg('Минуточку...',False);
sArt:=Copy(s,1+CNAme+1,CArtikul);
SOtd:=Copy(s,1+CNAme+1+CArtikul+1,COne);

If Not TestOtdel(StrToInt(SOtd)) Then
  Begin
          NoInfoMsg;
          Sound(100);
          DinfoMsg('Опреации с отделения '+SOtd+' запрещены!',False);
          Delay(300);
          NoSound;
          ClearEvent(Event);
          repeat
           Application^.GetEvent(Event);
          until (Event.What <> evNothing) And (Event.Command<>cmMenu);
          NoInfoMsg;
          ClearEvent(Event);
          Exit;
  End;



If GetIdMarket(Sart)=0 Then
  Begin
   SpecialBeep;
   If MessageBox(^M+#3+'Товар с кодом '+SArt+' запрещен к продаже!'^M+
   #3'Желаете продолжить операцию?',Nil,mfWarning+mfOkCancel)<>cmOk Then
    Begin
     NoInfoMsg;
     ClearEvent(Event);
     Exit;
    End;
  End;




DelSpace(Kod);
RFormatZerro(Kod,CClientKod);



If Not(Test3(0,SArt)) Then
   Begin
    Exit;
   End;

{LocStatus = True редактирование}
{LocStatus = False добавление новой}

New(Skl,Init);
Skl^.Dat.BazKod:=SArt;
GetSkladRecord(Skl);


New(BBB,Init);
BBB^.Dat.BazKod:=SArt;
If Not GetBazElement(SArt,BBB^.Dat) Then
 Begin
  Dispose(Skl,Done);
  Dispose(BBB,Done);
  NoInfoMsg;
  Exit;
 End;

CAse BBB^.DAt.VidNDS Of
0:SNDS:='20%';
1:SNDS:='10%';
2:SNDS:=BBB^.Dat.NDS;
3:SNDS:='18%';
Else SNDS:='0.00';
End;



LocStatus:=TestZakaz(Sart,SOtd,PredZakazList,Position);


Case LocStatus Of
False :Begin
       s:=PredZakazList^.GetText(Position,PredZakazList^.List^.Count);
       SKol:=Copy(s,1+CNAme+1+CArtikul+1+COne+1,CKol);
       SZena:=Copy(s,1+CNAme+1+CArtikul+1+COne+1+CKol+1,CZena);
       MyStr(StrToReal(Skl^.Dat.Input.R_Zena)-StrToReal(SZena),CZena,CMAntissa,SSkidka);
       DelSpace(SSkidka);
       SNadoSertif:=StrToInt(Copy(s,1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CZena+1,COne));
      End;
True:Begin
       SKol:=BBB^.DAt.InPack;

        If (StrToInt(SKol))>((StrToInt(Skl^.DAt.Input.Division[StRToInt(SOtd)])-
                      StrToInt(Skl^.DAt.Input.DivisionR[StRToInt(SOtd)]))) Then
        Begin
        SKol:=IntToStr(StrToInt(Skl^.DAt.Input.Division[StRToInt(SOtd)])-
                      StrToInt(Skl^.DAt.Input.DivisionR[StRToInt(SOtd)]),CKol);
        End;
        DelSpace(SKol);


        If StrToInt(SKol)<=0 Then SKol[0]:=#0;

       SNadoSertif:=1;
       MyStr(StrToReal(Skl^.Dat.Input.R_Zena)*Koef,CZena,CMantissa,SZena);
       DelSpace(SZena);
       MyStr(StrToReal(Skl^.Dat.Input.R_Zena)-StrToReal(SZena),CZena,CMAntissa,SSkidka);
       DelSpace(SSkidka);
      End;
Else Begin
       Dispose(Skl,Done);
       Dispose(BBB,Done);
       NoInfoMsg;
       Exit;
     End;
End;




SName:=BBB^.Dat.NAme+' '+BBB^.Dat.NAme2;

15:
NoInfoMsg;

DInfoMsg('Минуточку...',False);

DelSpace(SKol);
DelSpace(SZena);
DelSpace(SSkidka);



R.Assign(22, 9, 78, 22);
New(PC, Init(R, ''));
PC^.Palette := dpCyanDialog;
PC^.HelpCtx := $F427;
PC^.Art :=SArt;
PC^.Otd :=SOtd;
PC^.ClientKod :=Kod;
PC^.Fas := BBB^.DAt.InPack;
PC^.ZZ:=Skl^.Dat.Input.Zakupka;
PC^.RZ:=Skl^.Dat.Input.R_Zena;

R.Assign(1, 0, 12, 1);
Control1 := New(PColoredText, Init(R, '['+SArt+']-['+SOtd+']', $31));
PC^.Insert(Control1);



If LocStatus Then
Begin
R.Assign(13, 0, 45, 1);
Control1 := New(PColoredText, Init(R, #3+'Предварительное резервирование', $4F))
End
Else
Begin
R.Assign(13, 0, 53, 1);
Control1 := New(PColoredText, Init(R, #3+'Предварительное резервирование(правка)', $4F));
End;
PC^.Insert(Control1);


R.Assign(2, 1, 55, 2);
Control1 := New(PColoredText, Init(R, SNAme, $31));
PC^.Insert(Control1);


R.Assign(25, 3, 34, 4);
ControlPack := New(PColoredText, Init(R, #3+'', $3E));
PC^.Insert(ControlPack);

R.Assign(37, 3, 54, 4);
Control1 := New(PColoredText, Init(R, 'Доступно:      шт', $31));
PC^.Insert(Control1);

R.Assign(46, 3, 51, 4);
ControlStore := New(PStaticText, Init(R, #3+IntToStr(StrToInt(BakGetField(FDiv,SArt,StRToInt(SOtd)))-
                                                     StrToInt(BakGetField(FDivR,SArt,StRToInt(SOtd))),CKol)));
PC^.Insert(ControlStore);

R.Assign(25, 4, 28, 5);
Control1 := New(PColoredText, Init(R, 'ЗЦ:', $31));
PC^.Insert(Control1);

R.Assign(28, 4, 38, 5);
If EnableZakupka=1 Then
Control1 := New(PColoredText, Init(R, Skl^.Dat.Input.Zakupka, $3E))
Else
Control1 := New(PColoredText, Init(R, '???', $3E));
PC^.Insert(Control1);

R.Assign(39, 4, 46, 5);
Control1 := New(PColoredText, Init(R, 'Р/Цена:', $31));
PC^.Insert(Control1);

R.Assign(46, 4, 54, 5);
Control1 := New(PColoredText, Init(R, Skl^.Dat.Input.R_Zena, $3E));
PC^.Insert(Control1);

R.Assign(25, 5, 33, 6);
ControlProz := New(PColoredText, Init(R, #3+'', $3E));
PC^.Insert(ControlProz);

R.Assign(35, 5, 52, 6);
ControlNazenka := New(PColoredText, Init(R, #3+'', $31));
PC^.Insert(ControlNazenka);


R.Assign(3, 7, 14, 8);
Control1 := New(PColoredText, Init(R, 'Сертификат:', $31));
PC^.Insert(Control1);

R.Assign(14, 7, 48, 8);
Control1 := New(PColoredText, Init(R, GetIDField(FName,Skl^.Dat.Input.NSertif)+' ('+
Skl^.Dat.Input.NSertif+')', $31));
PC^.Insert(Control1);

R.Assign(8, 8, 14, 9);
Control1 := New(PColoredText, Init(R, Seria_Akzis^+':', $31));
PC^.Insert(Control1);


R.Assign(14, 8, 48, 9);
Control1 := New(PColoredText, Init(R, GetMarkaField(FMarka,Skl^.Dat.Input.Marka)+' ('+Skl^.Dat.Input.MArka+')', $31));
PC^.Insert(Control1);

R.Assign(8, 9, 14, 10);
Control1 := New(PColoredText, Init(R, '  ГТД:', $31));
PC^.Insert(Control1);

R.Assign(14, 9, 48, 10);
Control1 := New(PColoredText, Init(R, GetNGTDField(FNGTD,Skl^.Dat.Input.NGTD)+' ('+Skl^.Dat.Input.NGTD+')', $31));
PC^.Insert(Control1);

R.Assign(3, 10, 14, 11);
Control1 := New(PColoredText, Init(R, 'Спец.марка:', $31));
PC^.Insert(Control1);

R.Assign(14, 10, 48, 11);
Control1 := New(PColoredText, Init(R, GetSpecMarkaField(FSpecMarka,Skl^.Dat.Input.SpecMarka)+' ('+Skl^.Dat.Input.SpecMarka+')',
$31));
PC^.Insert(Control1);


R.Assign(7, 11, 14, 12);
Control1 := New(PColoredText, Init(R, 'Страна:', $31));
PC^.Insert(Control1);

R.Assign(14, 11, 29, 12);
Control1 := New(PColoredText, Init(R, GetPostField(FPost,BBB^.Dat.PostKod), $31));
PC^.Insert(Control1);

R.Assign(30, 11, 36, 12);
Control1 := New(PColoredText, Init(R, 'Фирма:', $31));
PC^.Insert(Control1);

R.Assign(36, 11, 55, 12);
Control1 := New(PColoredText, Init(R, GetFirmaPostField(FFirmaPost,BBB^.Dat.FirmaPostKod), $31));
PC^.Insert(Control1);

R.Assign(2, 2, 37, 3);
Control1 := New(PColoredText, Init(R, 'Фасовка:'+PC^.Fas+' НДС:'+SNDS+' ГР:'+Skl^.DAt.Input.GRZena, $31));
PC^.Insert(Control1);



R.Assign(14, 3, 21, 4);
ControlLocalKol := New(PInputLine, Init(R, CKol));
PC^.Insert(ControlLocalKol);
  PInputLine(ControlLocalKol)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));
ControlLocalKol^.SetData(SKol);

  R.Assign(2, 3, 14, 4);
  PC^.Insert(New(PLabel, Init(R, 'К~о~личество:', ControlLocalKol)));

R.Assign(14, 4, 24, 5);
ControlLocalZena := New(PInputLine, Init(R, CZena));
PC^.Insert(ControlLocalZena);
  PInputLine(ControlLocalZena)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

ControlLocalZena^.SetData(SZena);

  R.Assign(1, 4, 14, 5);
  PC^.Insert(New(PLabel, Init(R, '~Ц~ена оплаты:', ControlLocalZena)));

R.Assign(14, 5, 24, 6);
ControlLocalSkidka := New(PInputLine, Init(R, CZena));
PC^.Insert(ControlLocalSkidka);
  PInputLine(ControlLocalSkidka)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
ControlLocalSkidka^.SetData(SSkidka);

  R.Assign(6, 5, 14, 6);
  PC^.Insert(New(PLabel, Init(R, 'Ски~д~ка:', ControlLocalSkidka)));

R.Assign(6, 6, 22, 7);
ControlNSertif := New(PCheckboxes, Init(R,
  NewSItem('~С~ертификат', Nil)));
PC^.Insert(ControlNSertif);

ControlNSertif^.SetData(SNAdoSertif);



PC^.SelectNext(False);
NoInfoMsg;


DrawPack;
CalcZena;
CalcSkidka;
RecalcNazenka;

c:=Desktop^.ExecView(PC);

If c=cmOk Then
 Begin
  ControlLocalKol^.GetData(SKol);
  ControlLocalZena^.GetData(SZena);
  ControlLocalSkidka^.GetData(SSkidka);
  ControlNSertif^.GetData(SNadoSertif);

  If StrToInt(SKol)<=0 Then
    Begin
     MessageBox(^M+#3'Недопустимое количество товара',Nil,mfError+mfCancelButton);
     Dispose(Control1,Done);
     Dispose(ControlLocalKol,Done);
     Dispose(ControlLocalZena,Done);
     Dispose(ControlLocalSkidka,Done);
     Dispose(ControlNSertif,Done);
     Dispose(ControlProz,Done);
     Dispose(ControlNazenka,Done);
     Dispose(PC,Done);
     Goto 15;
    End;

  If StrToInt(SKol)>(StrToInt(BakGetField(FDiv,SArt,StRToInt(SOtd)))-
                     StrToInt(BakGetField(FDivR,SArt,StRToInt(SOtd)))) Then
    Begin
     MessageBox(^M+'На складе (отделение ['+IntToStr(StrToInt(SOtd),COne)+
     ']) отсутствует такое количество товара!',nil, mfError+mfCancelButton);
     Dispose(Control1,Done);
     Dispose(ControlLocalKol,Done);
     Dispose(ControlLocalZena,Done);
     Dispose(ControlLocalSkidka,Done);
     Dispose(ControlNSertif,Done);
     Dispose(ControlProz,Done);
     Dispose(ControlNazenka,Done);
     Dispose(PC,Done);
     Goto 15;
    End;

   s[0]:=Chr(CName+1+CArtikul+1+COne+1);

   DelSpace(SKol);
   MyStr(StrToReal(SZena),CZena,CMantissa,SZena);
   MyStr(StrToReal(SSkidka),CZena,CMantissa,SSkidka);
   MyStr(StrToReal(PC^.RZ),CZena,CMantissa,PC^.RZ);
   DelSpace(SZena);
   DelSpace(SSkidka);
   DelSpace(PC^.RZ);
   RFormat(SKol,CKol);
   RFormat(SZena,CZena);
   RFormat(PC^.RZ,CZena);
   RFormat(SSkidka,CZena);
   s:=s+SKol+'│'+SZena+'│'+PC^.RZ+'│'+SSkidka+'│'+IntToStr(SNadoSertif,COne)+'│'+SName;

   {если редактирование то удаляем старую строку}
  If Not LocStatus{редактирование} Then
    Begin
     PredZakazList^.List^.AtFree(Position);
     PredZakazList^.SetRange(PredZakazList^.List^.Count);
    End;

   PredZakazList^.List^.Insert(NewStr(S));
   PredZakazList^.SetRange(PredZakazList^.List^.Count);
   PredZakazList^.FocusItem(Location(PredZakazList,SArt,False));



 End;

Dispose(Skl,Done);
Dispose(BBB,Done);
Dispose(Control1,Done);
Dispose(ControlLocalKol,Done);
Dispose(ControlLocalZena,Done);
Dispose(ControlLocalSkidka,Done);
Dispose(ControlNSertif,Done);
Dispose(ControlProz,Done);
Dispose(ControlNazenka,Done);
Dispose(PC,Done);

End;

procedure TCartZakazWindow.HandleEvent(var Event: TEvent);


Function InputLocalSkidka(Var St1:TDateString):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  st : ArtikulStr;
  SSkidka,Zena : String[CZena];
  Event : TEvent;
begin
InputLocalSkidka:=False;
St1[0]:=#0;
c:=1;

ControlLocalSkidka^.GetData(SSkidka);
Zena:=PC^.RZ;

If StrToREal(SSkidka)>=0.01 Then
 Begin
  If (StrToReal(Zena)-StrToReal(SSkidka))>0.009 Then
  Begin
  MyStr(((StrToReal(Zena))/((StrToReal(Zena)-StrToReal(SSkidka)))-1),COne,CLitrMantissa,st);
  System.Delete(st,Pos('.',st)-1,2);
  System.Delete(st,Pos('-',st)-1,2);
  End
   Else St:='0';
 End
 Else St:='0';


 DelSpace(St);

R.Assign(28, 9, 45, 12);
New(Dlg, Init(R, 'Скидка'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E004;
R.Assign(10, 1, 15, 2);
Control := New(PInputLine, Init(R, CLitrMantissa));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(1, 1, 9, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Скидка:', Control)));

{
R.Assign(15, 1, 18, 2);
Control := New(PStaticText, Init(R, '%'));
Dlg^.Insert(Control);
}

R.Assign(9, 1, 11, 2);
Control := New(PColoredText, Init(R, '1.', $1F));
Dlg^.Insert(Control);


Dlg^.SetData(St);

Dlg^.SelectNext(False);
Event.KeyCode:=kbEnd;
Event.What:=evKeyDown;
PutEvent(Event);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(st);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  DelSpace(St);

  If (St[1] in['2','3','4','5']) And Not(CurrentPassword='00') Then
 If Not (NewPassword(4)) Then Exit;

  St:='1.'+st;
  If StrToReal(st)>1.5 Then
   Begin
    Messagebox(^M+#3'Недопустимая ВЕЛИЧИНА скидки!',Nil,mfError+mfCancelButton);
    Exit;
   End;
  If StrToReal(st)<1.00 Then
   Begin
    Messagebox(^M+#3'Недопустимое ЗНАЧЕНИЕ скидки!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   {}
   MyStr(StrToReal(Zena)-(StrToReal(Zena)/(StrToReal(st))),CZena,CMantissa,SSkidka);
   DelSpace(SSkidka);
   St1:=SSkidka;
   InputLocalSkidka:=True;
 End
 Else
 Begin
  St1[0]:=#0;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
end;



Function InputLocalNazenka(Var St1:TDateString):Boolean;
var
   Dlg : PDialog;
     R : TRect;
Control: PView;
  c    : Word;
  st   : ArtikulStr;
  SSkidka,Zena : String[CZena];
  Event: TEvent;
begin
{If Not(Password(2)) Then Exit;} {убрал по желанию бакши}
St1[0]:=#0;
InputLocalNazenka:=False;

c:=1;

ControlLocalSkidka^.GetData(SSkidka);
Zena:=PC^.RZ;

If (StrToREal(SSkidka))<=-0.01 Then
 Begin
  If StrToReal(Zena)>=0.009 Then
  MyStr((
      (Abs(StrToReal(SSkidka))
      )
      /(
        (StrToReal(Zena)
        )
       )*100
     ),CKol,CMantissa,st)
  Else St:='0';
 End
 Else St:='0';

 DelSpace(St);

R.Assign(29, 10, 50, 13);
New(Dlg, Init(R, 'Наценка'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E003;
R.Assign(10, 1, 17, 2);
Control := New(PInputLine, Init(R, CKol));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 1, 10, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Наценка:', Control)));

R.Assign(18, 1, 20, 2);
Control := New(PColoredText, Init(R, '%',$BE));
Dlg^.Insert(Control);

Dlg^.SetData(St);
Dlg^.SelectNext(False);

{Event.KeyCode:=kbEnd;
Event.What:=evKeyDown;
PutEvent(Event);}

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(st);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  DelSpace(St);
  InputLocalNazenka:=True;
  MyStr((StrToReal(Zena)*StrToReal(st)/(-100)),CZena,CMantissa,SSkidka);
  DelSpace(SSkidka);
  St1:=SSkidka;
 End
 Else
 Begin
  St1[0]:=#0;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
end;





procedure Calculator;
begin
  Calc^.Start;
end;

Var sn : AllStr;
    NewZena : String[CZena];
    R : TRect;
    DS,DZ,DrawP : Boolean;

Begin
  Case Event.What Of
  evKeyDown :
        Case Event.KeyCode Of
        kbEnter:Begin
                inherited HandleEvent(Event);
                If ((PC^.Current=ControlLocalKol)) Then
                   Begin
                    Event.What:=evCommand;
                    Event.Command:=CmOk;
                   End;
                End;
        kbF4:Begin
              End;
        Else;
        End;
  evCommand :
        Case Event.Command Of

      cmLocalSkidka: Begin
                                       If InputLocalSkidka(NewZena) Then
                                        Begin
                                         ControlLocalSkidka^.SetDAta(NewZena);
                                         PC^.Redraw;
                                         CalcZena;
                                         RecalcNazenka;
                                        End;

                     End;

     cmLocalNazenka: Begin
                                        If InputLocalNazenka(NewZena) Then
                                        Begin
                                         ControlLocalSkidka^.SetDAta(NewZena);
                                         PC^.Redraw;
                                         CalcZena;
                                         RecalcNazenka;
                                        End;

                     End;

        cmLocalCalc:Begin
	                Calculator;
                    End;
        cmLastZeni2   :Begin

                    LastZena^.Start(PC^.Art,PC^.ClientKod,NewZena);
                    If NewZena[0]<>#0 Then
                     Begin
                      ControlLocalZena^.SetData(NewZena);
                      CalcSkidka;
                      RecalcNazenka;
                     End;
                     Redraw;

                End;


cmViewPrihodTovar
     :Begin
       ClearFind;
       sn:=PC^.Art;
       FP^.FindScreenPrh(sn);
       ClearEvent(Event);
      End;

     cmFindLink:Begin
        ClearFind;
        sn:=PC^.Art;
        Lnk^.Start(sn);
        ClearEvent(Event);
                End;



     cmViewBron
        :Begin
       ClearFind;
       Sn:=PC^.Art;
       If FR^.Start(Sn,True) Then
        Begin
         Dispose(ControlStore,Done);
         R.Assign(46, 3, 51, 4);
         ControlStore := New(PStaticText, Init(R, #3+IntToStr(StrToInt(BakGetField(FDiv,PC^.Art,StRToInt(PC^.Otd)))-
                                                  StrToInt(BakGetField(FDivR,PC^.Art,StRToInt(PC^.Otd))),CKol)));
         PC^.Insert(ControlStore);

        End;
       ClearEvent(Event);
       End;

         Else;
         End;{evCommand}
         Else;
         End;{*Case*}


  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbBack)
  Or (Event.KeyCode=kbShiftIns) Or (Event.KeyCode=kbCtrlIns)) Then DrawP:=True
  Else DrawP:=False;

  DZ:=False;
  DS:=False;

  If (Event.What=evKeyboard)And
  ((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.','-'])
Or (Event.KeyCode=kbDel)
Or (Event.KeyCode=kbCtrlDel)
Or (Event.KeyCode=kbBack)
Or (Event.KeyCode=kbShiftIns))
  And  ((ControlLocalSkidka^.State and sfFocused <> 0)) Then
  DZ:=True;


  If (Event.What=evKeyboard)And
  ((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.','-'])
Or (Event.KeyCode=kbDel)
Or (Event.KeyCode=kbCtrlDel)
Or (Event.KeyCode=kbBack)
Or (Event.KeyCode=kbShiftIns))
  And  ((ControlLocalZena^.State and sfFocused <> 0)) Then
  DS:=True;

  inherited HandleEvent(Event);

  If DZ Then
   Begin
    CalcZena;
    RecalcNazenka;
   End;

  If DS Then
   Begin
    CalcSkidka;
    RecalcNazenka;
   End;

  inherited HandleEvent(Event);

  If DrawP Then
   If (ControlLocalKol^.State and sfFocused <> 0) Then DrawPack;

  ClearEvent(Event);
end;



procedure TCartZakazWindow.DrawPack;
Var s: String[CPack];
    R : TRect;
    i : Byte;
    SKol : ArtikulStr;
Begin
    ControlLocalKol^.GetData(SKol);
    s:=CalcPackNoFile(Pc^.Fas,Skol);
    DelSpace(s);
    Dispose(ControlPack,Done);
    R.Assign(25, 3, 34, 4);
    ControlPack := New(PColoredText, Init(R, #3+s, $3E));
    PC^.Insert(ControlPack);
End;




procedure TCartZakazWindow.CalcSkidka;
Var SProz,SSkidka,SZena:String[CZena];
    R : TRect;
Begin
    ControlLocalZena^.GetData(SZena);
    MyStr(StrToReal(PC^.RZ)-StrToreal(SZena),CZena,CMAntissa,SSkidka);
    DelSpace(SSkidka);
    ControlLocalSkidka^.SetData(SSkidka);
    Dispose(ControlProz,Done);
    R.Assign(25, 5, 33, 6);
    If Abs(StrToReal(PC^.RZ))>0.009 Then
    Begin
    MyStr(StrToReal(SSkidka)/StrToReal(PC^.RZ)*100,CKol,CMantissa,SProz);
    SProz:=SProz+'%';
    End
    Else
    SProz:='???';
    DelSpace(SProz);
    ControlProz := New(PColoredText, Init(R, #3+SProz, $3E));
    PC^.Insert(ControlProz);
end;


procedure TCartZakazWindow.RecalcNazenka;
Var SProz,SSkidka,SZena:String[CZena];
    R : TRect;
Begin
    ControlLocalZena^.GetData(SZena);

    Dispose(ControlNazenka,Done);
    R.Assign(35, 5, 52, 6);
    If Abs(StrToReal(PC^.ZZ))>0.009 Then
    Begin
    MyStr((StrToReal(SZena)-StrToReal(PC^.ZZ))/StrToReal(PC^.ZZ)*100,CKol,CMantissa,SProz);
    SProz:=SProz+'%';
    End
    Else
    SProz:='???';
    DelSpace(SProz);
    ControlNazenka := New(PColoredText, Init(R, #3+SProz, $3E));
    PC^.Insert(ControlNazenka);
end;

procedure TCartZakazWindow.CalcZena;
Var SProz,SSkidka,SZena:String[CZena];
    R : TRect;
Begin
    ControlLocalSkidka^.GetData(SSKidka);
    MyStr(StrToReal(PC^.RZ)-StrToreal(SSkidka),CZena,CMAntissa,SZena);
    DelSpace(SZena);
    ControlLocalZena^.SetData(SZena);

    Dispose(ControlProz,Done);
    R.Assign(25, 5, 33, 6);
    If Abs(StrToReal(PC^.RZ))>0.009 Then
    Begin
    MyStr(StrToReal(SSkidka)/StrToReal(PC^.RZ)*100,CKol,CMantissa,SProz);
    SProz:=SProz+'%';
    End
    Else
    SProz:='???';
    DelSpace(SProz);
    ControlProz := New(PColoredText, Init(R, #3+SProz, $3E));
    PC^.Insert(ControlProz);
end;






Begin
ShowSertif:=0;
Filtr:=False;
End.