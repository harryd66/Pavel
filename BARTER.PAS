{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Barter;


Interface


Uses Dialogs,Drivers,Glob,Access,ServStr,LockInfo,MyCalc,Market,Utils;

Type
  POplataBarterWindow = ^TOplataBarterWindow;
  TOplataBarterWindow = object(TDialog)
  Calc        : PMyCalculator;
    Regims : Word;
    Procedure Ini(Regim:Word;Var CC:ArtikulStr;Ass: DocumentEdit);

    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;



Type
  PPrihodBarterWindow = ^TPrihodBarterWindow;
  TPrihodBarterWindow = object(TDialog)

  CodS : ArtikulStr;{код клиента}
  DocS: ArtikulStr;{номер документа прихода}
  DateS: TDAteString;{дата документа прихода}

  SummaOplatS : StrIng[CIZena];
  SummaPrihodS : StrIng[CIZena];
  OstatokS : StrIng[CIZena];

  Status : Word;{указывает вид прихода до начала корретировок}

  Calc        : PMyCalculator;
    Procedure Ini(Cod:ArtikulStr;Doc,Date : TDateString);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;



Type
  PBarterWindow = ^TBarterWindow;
  TBarterWindow = object(TDialog)
    OBW  : POplataBarterWindow;
    PrhW : PPrihodBarterWindow;
    Cl  : PClientWindow;
    constructor Init(Var l: Boolean);{*}
    procedure HandleEvent(var Event: TEvent); virtual;{*}
    procedure OpenBarterWindow;{*}
    Procedure FormReport(Const P:PBox;SCKod:ArtikulStr);
    procedure CalcItogo;{*}
    procedure FullPreview;
    procedure Refresh(Auto:Boolean);{*}
    procedure DrawCurrent;{*}
    {Procedure FullPreviewMrk;}{*}
    Procedure PrintMrk;{*}
    Procedure FullPreviewPrh;
    Procedure PrintPrh;
  end;

Procedure CalcMenedger3(Const Client:PBox; Filtr,Oplata:Word;StartD,StopD:TDateString);

Implementation

uses DBEngine,Vision4,Vision5,Objects, Views, MsgBox,Protect,TPDate,Tools,Printers,NetCAll,Windos,
    App, ColorTxt,Validate,Serv,Nastr,Vision1,Vision2,Net,Stat,NetDbEng,Vozwrat,UtilsP;



Type BBBPrh=Record
    VidPrihoda : Word;{отсрочка или  нет}
    Srok : TDAteString;
    OstatokDolga : String[15];
  end;



var
 OplataWindow : POplataBarterWindow;
 PrhWindow : PPrihodBarterWindow;
 BarterWindow : PBarterWindow;
 ControlComment,ControlClient,ControlDoc,ControlViewRashet,
 ControlBank,ControlPP,ControlRashet,ControlSummaPP,ControlDatePP,
 ControlDocNumer,ControlVidPrihodWin,
 ControlVidPrihod,ControlSrokDo,ControlStartSumma,ControlOstatok,ControlOstatokWin,
 ControlLink,ControlDAte,
 ControlOstatokText,
 ControlStart,ControlStop,ControlPrim,ControlPrihod,ControlRashod,ControlSaldo: PView;
 PrevCurrent,PrevS : TMyString;
 Oplata:BBB;
 Prh : BBBPrh;
 BnBarter :BezNal;
 VidPrihod:Word;


 Ws : String[CIZena];
 BarterFile : File Of BarterClientType;
 BarterElement : PBarterClientType;
 BarterList: PBox;
 mm : Maska9;
 mm4 : Maska4;
 FiltrDoc,FiltrOperation:Word;
 StartDate,StopDate :TDateString;

Function NewPassword : Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  s : String[10];
  c : Word;
  L : Boolean;
begin
s[0]:=#0;
NewPassword:=False;
(*R.Assign(18, 8, 61, 15);
New(Dlg, Init(R, ''));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpBlueDialog;
Dlg^.HelpCtx:=$E241;


R.Assign(29, 4, 41, 5);
Control := New(PSInputLine, Init(R, 10));
Dlg^.Insert(Control);

R.Assign(2, 3, 29, 5);
Control := New(PColoredText, Init(R, #3'Если рискнете продолжить'^M+
     'Повторите свой код доступа:',$1F));
Dlg^.Insert(Control); *)


l:=False;
(*Dlg^.SelectNext(False);
SpecialBeep;
c:=Desktop^.ExecView(Dlg);
 If c<>cmCancel Then
 Begin
 Dlg^.GetData(s);
 UpStr(S);
 DelSpace(s);
 If s<>Decode(GetOperatorPassword(CurrentPassword)) Then L:=False
 Else L:=True;
 End;

Dispose(Control,Done);
Dispose(Dlg,Done); *)

l:=true;

If Not(l) Then
 MessageBox(#3^M+#3'Ошибочный код доступа!',Nil,mfError+mfCancelButton);
NewPassword:=l;
end;



Destructor TOplataBarterWindow.Done;
Begin
TDialog.Done;
End;



Procedure TOplataBarterWindow.HandleEvent(Var Event:TEvent);
procedure Calculator;
begin
  Calc^.Start;
end;
VAr Test : Word;
Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
   Else;
   End;
   Else;
   End;
  Inherited HandleEvent(Event);

  If (Desktop^.Current=PView(OplataWindow)) And (Event.What <> EvKeyDown) Then
   Begin
                if (ControlLink^.State and sfFocused <> 0)Then
                    Begin
  ControlLink^.GetDAta(Test);
  If Test<>OPlata.Link Then
   Begin
    Oplata.Link:=Test;
    If Oplata.Link=0 Then
    Begin
    ControlDocNumer^.Options := ControlDocNumer^.Options and not ofSelectable;
    Oplata.Doc[0]:=#0;
    ControlDocNumer^.SetDAta(Oplata.Doc);
    ControlDate^.Options := ControlDate^.Options and not ofSelectable;
    Oplata.Date[0]:=#0;
    ControlDate^.SetDAta(Oplata.Date);

    End
    Else
     Begin
      ControlDocNumer^.Options := ControlDocNumer^.Options Or ofSelectable;
      ControlDate^.Options := ControlDate^.Options Or ofSelectable;
     End;
    redraw;
   End;
                    End;

    End;


  ClearEvent(Event);
End;


Procedure TOplataBarterWindow.Ini(Regim:Word;Var CC:ArtikulStr;Ass: DocumentEdit);
Label 1;
Var
  R : TRect;
  Control : PView;
  C : Word;
  PB : PBarterClientType;
  PBO : POplataBarter;
  Bf : File Of BArterClientType;
  test , Find : Boolean;
  Pos : LongInt;
  bFind: boolean; {признак наличия неоплаченных приходов}
  Pereplata: String[CIZena];


function FindNextPrihod(var Ass: DocumentEdit):boolean;
VAR PB : BarterClientType;
    Bf : File Of BArterClientType;
Begin
  FindNextPrihod:=false;
  Find:=false;
  Assign(Bf,Path.ToBArter+cc+'.brt');
  c:=Ioresult;
reset(bf);
c:=Ioresult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия файла '+Path.ToBArter+cc+'.brt',Nil,mfError+mfCancelButton);
  exit;
 End;
While Not(Eof(bf)) And Not(Find) Do
 Begin
  Read(bf,Pb);
  If Pb.Active Then
   Begin
     If Pb.OperatorSelector=0 Then{если приход}
      Begin
       if abs(StrToReal(Pb.OstatokDolga))>0.009 then
          Begin
           Ass.d:=Pb.DAteC;
           Ass.EditPosition:=Pb.Document;
           FindNextPrihod:=True;
           Find:=True;
           Break;
          End;
      End;{OperatorSelector=0}
   End;{Active}
 End;{While}
c:=Ioresult;
System.Close(bf);
c:=Ioresult;
End;

begin

Pereplata[0]:=#0;
Oplata.Rashet:=1;
Oplata.Prim[0]:=#0;
Oplata.Link:=1;

1:
Oplata.Doc:=Ass.EditPosition;
Oplata.DAte:=Ass.D;
Oplata.Summa:=Pereplata;

If Regim=1 Then
R.Assign(14, 9, 66, {14}30)
Else
R.Assign(14, 9, 74, {16}30);
Case Regim Of
0:New(OplataWindow, Init(R, 'Регистрация оплаты поставщику'));
1:New(OplataWindow, Init(R, 'Регистрация поступления в кассу'));
Else Exit;
End;


OplataWindow^.Options := OplataWindow^.Options or ofCenterX or ofCenterY;
OplataWindow^.Palette := dpCyanDialog;
OplataWindow^.HelpCtx := $E191;
OplataWindow^.Regims:=Regim;


R.Assign(8, 1, 25, 2);
Control := New(PInputLine, Init(R, 15));
OplataWindow^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));

  R.Assign(1, 1, 8, 2);
  OplataWindow^.Insert(New(PLabel, Init(R, 'Сумма:', Control)));

R.Assign(33, 1, 51, 2);
Control := New(PRadioButtons, Init(R,
  NewSItem('Нал',
  NewSItem('Б/Н', Nil))));
OplataWindow^.Insert(Control);

  R.Assign(25, 1, 33, 2);
  OplataWindow^.Insert(New(PLabel, Init(R, 'Расчет:', Control)));

R.Assign(2, 3, 49, 4);
Control := New(PInputLine, Init(R, CAll));
OplataWindow^.Insert(Control);

  R.Assign(1, 2, 13, 3);
  OplataWindow^.Insert(New(PLabel, Init(R, 'Примечание:', Control)));

R.Assign(3, 5, 18, 6);
ControlLink := New(PCheckboxes, Init(R,
  NewSItem('Связать', Nil)));
OplataWindow^.Insert(ControlLink);
{If Regim=1 Then}
  ControlLink^.Options := ControlLink^.Options and not ofSelectable;
ControlLink^.SetData(Oplata.Link);

R.Assign(39, 5, 45, 6);
ControlDocNumer := New(PInputLine, Init(R, CDocNumer));
OplataWindow^.Insert(ControlDocNumer);
{If (Regim=1) Or (Oplata.Link=0) Then}
  ControlDocNumer^.Options := ControlDocNumer^.Options and not ofSelectable;


  R.Assign(18, 5, 39, 6);
  OplataWindow^.Insert(New(PLabel, Init(R, 'с накладной прихода:', ControlDocNumer)));

R.Assign(49, 5, 59, 6);
ControlDAte := New(PInputLine, Init(R, CDAte));
OplataWindow^.Insert(ControlDAte);
  PInputLine(ControlDAte)^.Validator := New(PPXPictureValidator, Init(DAteFiltr, True));
{If (Regim=1) Or (Oplata.Link=0) Then}
  ControlDate^.Options := ControlDate^.Options and not ofSelectable;

  R.Assign(45, 5, 49, 6);
  OplataWindow^.Insert(New(PLabel, Init(R, 'от:', ControlDAte)));

OplataWindow^.SelectNext(False);

OplataWindow^.SetData(Oplata);
c := Desktop^.ExecView(OplataWindow);
If c=cmOk Then
 Begin

  If Not(NewPassword) Then
          Begin
        Dispose(Control,Done);
        Dispose(OplataWindow,Done);
        Goto 1;
          End;

  OplataWindow^.GetData(Oplata);
  If Abs(StrToReal(Oplata.Summa))>0.009 Then
  Begin
   Str(StrToReal(Oplata.Summa):CIZena:CMAntissa,Oplata.Summa);
   DelSpace(Oplata.Summa);
   DelSpaceRight(Oplata.Prim);
   BnBarter.DAte[0]:=#0;
   BnBarter.NPlat[0]:=#0;
   BnBarter.Bank[0]:=#0;
   BnBarter.Summa[0]:=#0;

   If Oplata.Rashet=1 Then{Б/Н}
    Begin
     BnBarter.DAte[0]:=#0;
     BnBarter.NPlat[0]:=#0;
     BnBarter.Bank[0]:=#0;
     BnBarter.Summa[0]:=#0;

     If Not(InputBezNal(BnBArter,Oplata)) Then
          Begin
        Dispose(Control,Done);
        Dispose(OplataWindow,Done);
        Goto 1;
          End;
    End;

  If (Regim=0) And (Oplata.Link=1) Then
   Begin
    DelSpace(Oplata.Doc);
    If Oplata.Doc[0]=#0 Then
     Begin
        MessageBox(^M+#3'Не указан номер накладной для связанного платежа!',Nil,mfError+
	   mfCAncelButton);
        Dispose(Control,Done);
        Dispose(OplataWindow,Done);
        Goto 1;
     End;

    DelSpace(Oplata.Date);
    If Oplata.Date[0]=#0 Then
     Begin
        MessageBox(^M+#3'Не указана дата накладной для связанного платежа!',Nil,mfError+
	   mfCAncelButton);
        Dispose(Control,Done);
        Dispose(OplataWindow,Done);
        Goto 1;
     End;
   End;



Test:=True;
Find:=True;

  If (Regim=0) And (Oplata.Link=1) Then
   Begin
    DInfoMsg('Проверяю возможность проведения платежа. Ждите...');

Assign(Bf,Path.ToBArter+cc+'.brt');
c:=Ioresult;
reset(bf);
c:=Ioresult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox('Ошибка открытия файла '+Path.ToBArter+cc+'.brt',Nil,mfError+mfCancelButton);
  Dispose(Control,Done);
  Dispose(OplataWindow,Done);
  Goto 1;
 End;

Find:=FAlse;{факт нахождения накладной}
Pos:=0;
New(pB,Init);
While Not(Eof(bf)) And Not(Find) Do
 Begin
  Read(bf,Pb^.Dat);
  If Pb^.Dat.Active Then
   Begin
     If Pb^.Dat.OperatorSelector=0 Then{если приход}
      Begin
       If (StrToInt(Oplata.Doc)=StrToInt(Pb^.Dat.Document)) And
          (Oplata.DAte=Pb^.DAt.DAteC) Then
          Begin
           Find:=True;
           Pos:=FilePos(bf)-1;
           Break;
          End;
      End;{OperatorSelector=0}
   End;{Active}
 End;{While}

c:=Ioresult;
System.Close(bf);
c:=Ioresult;

Test:=True;{результат теста после нахождения накладной}

If Not(Find) Then
 Begin
  NoInfoMsg;
  Dispose(Pb,Done);
  MessageBox(#3'Накладная N '+Oplata.Doc+' от '+Oplata.Date+' не найдена в файле взаиморасчетов с клиентом!',Nil,
  mfError+mfCAncelButton);
  Dispose(Control,Done);
  Dispose(OplataWindow,Done);
  Goto 1;
 End;


If (Pb^.DAt.VidPrihoda=0)Then
 Begin
  Dispose(Pb,Done);
  NoInfoMsg;
  MessageBox(#3'Указанная накладная имеет статус оплаченной! Такая операция невозможна!',Nil,
  mfError+mfCAncelButton);
  Dispose(Control,Done);
  Dispose(OplataWindow,Done);
  Goto 1;
 End;

If (StrToReal(Pb^.DAt.OstatokDolga)-StrToReal(Oplata.Summa))<-0.009 Then
 Begin

  MessageBox(^M+#3'Сумма оплаты превышает сумму долга по накладной!',Nil,
  mfError+mfCAncelButton);


  {нада оплатить др.накладные или сформировать переплату}

  MyStr(ABS(StrToReal(Pb^.DAt.OstatokDolga)-StrToReal(Oplata.Summa)),CIZena,CMantissa,Pereplata);
  DelSpace(Pereplata);
  Oplata.Summa:=Pb^.DAt.OstatokDolga;

 End
 else Pereplata:='0.00';

(*If ((StrToReal(Pb^.DAt.OstatokDolga)-StrToReal(Oplata.Summa))-
   StrToreal(Pb^.DAt.PSummaZakupka))>0.009 Then
 Begin
  Dispose(Pb,Done);
  NoInfoMsg;
  MessageBox(^M+#3'После этой операции сумма долга превысит сумму прихода! Повторите ввод',Nil,
  mfError+mfCAncelButton);
  Dispose(Control,Done);
  Dispose(OplataWindow,Done);
  Goto 1;
 End; *)

Dispose(Pb,Done);


    NoInfoMsg;
End;{проверка возможносьт проведения операции}



    New(PBO,Init);
    With PBO^.Dat Do
     Begin
      OperatorSelector:=Regim;
      Vid:=Regim;
      ClientKod:=CC;
      Order[0]:=#0;
      Str(StrToReal(Oplata.Summa):CIZena:CMantissa,SummaZ);
      Rashet:=Oplata.Rashet;
      Bn.Date:=BnBarter.DAte;
      Bn.NPlat:=BnBarter.NPlat;
      Bn.Bank:=BnBarter.Bank;
      Bn.Summa:=BnBarter.Summa;
      DelSpaceRight(Oplata.Prim);
      Comment:=Oplata.Prim;
      Link:=Oplata.Link;
      If Oplata.Link=1 Then
       Begin
        Doc:=Oplata.Doc;
        Date:=Oplata.Date;
       End
       Else
        Begin
         Doc[0]:=#0;
         Date[0]:=#0;
        End;
	  End;

    New(PB,Init);
    With Pb^.Dat Do
    Begin
      OperatorSelector:=Regim+2{2-выыдача из кассы 3 - поступление в кассу};
      ClientKod:=CC;
      If Regim=0 Then
      Str(StrToReal(Oplata.Summa):CIZena:CMantissa,Vidano)
      Else
      Str(StrToReal(Oplata.Summa):CIZena:CMantissa,Priniato);
      Rashet:=Oplata.Rashet;
      Bn.Date:=BnBarter.DAte;
      Bn.NPlat:=BnBarter.NPlat;
      Bn.Bank:=BnBarter.Bank;
      Bn.Summa:=BnBarter.Summa;
      DelSpaceRight(Oplata.Prim);
      Comment:=Oplata.Prim;
      Link:=OPlata.Link;
      If Oplata.Link=1 Then
       Begin
        Doc:=Oplata.Doc;
        Date:=Oplata.Date;
       End
       Else
        Begin
         Doc[0]:=#0;
         Date[0]:=#0;
        End;
      DocSelector :=0;
      Document[0]:=#0;
    End;

    If CreatClientBarterFile(CC) Then
    Begin
    If SaveOplataBarterToToDayFile(PBO) Then
     Begin
       PB^.Dat.Document:=PBO^.Dat.Order;
       If SaveToBarterOplataFile(PB) Then
       Begin

If Oplata.Link=1 Then
Begin
Assign(Bf,Path.ToBArter+cc+'.brt');
c:=Ioresult;
reset(bf);
c:=Ioresult;
DInfoMSg('Сохраняю оплату. Ждите...');

Seek(bf,Pos);
Read(bf,pb^.Dat);
Seek(bf,Pos);

Str(StrToReal(Pb^.DAt.OstatokDolga)-StrToReal(Oplata.Summa):CIZena:CMAntissa,Pb^.DAt.OstatokDolga);
Str(StrToReal(Pb^.DAt.Vidano)+StrToReal(Oplata.Summa):CIZena:CMAntissa,Pb^.DAt.Vidano);
DelSpace(Pb^.DAt.OstatokDolga);

Write(bf,Pb^.DAt);
c:=IoResult;
System.Close(bf);
c:=IoResult;

NoInfoMsg;


End;
       MessageBox(^M+#3'Оплата успешно зафиксирована!'^M+
          #3'Операция успешно сохранена!',Nil,mfInformation+mfCancelButton);


       End;
     End;
    End;


    Dispose(PBO,Done);
    Dispose(PB,Done);


  End{сумма оплаты >= 1 копейки}
   Else
    Begin
     MessageBox(^M+#3'Нулевая сумма оплаты(выдачи) не фиксируется!',Nil,mfError+mfCancelButton);
     Dispose(Control,Done);
     Dispose(OplataWindow,Done);
     Goto 1;
    End;
 End;

 Dispose(Control,Done);
 Dispose(OplataWindow,Done);

 bFind:=FindNextPrihod(ASS);

 if abs(StrToReal(Pereplata))>0.009 then
 begin
  if bfind then goto 1{если есть неоплаченный приход}
  else  {ПЕРЕПЛАТА!}
   begin

     new(pb,Init);
     c:=ioresult;
     Assign(Bf,Path.ToBArter+cc+'.brt');
     c:=ioresult;
     Reset(Bf);
     c:=ioresult;
     if c<>0 then
     begin
       c:=ioresult;
       Rewrite(Bf);
       c:=ioresult;
     end;
     while not eof(Bf) do
        read(Bf,Pb^.Dat);
     Dispose(pb,Done);

     new(pb,Init);
     BnBarter.Summa:=Pereplata;
     Pb^.DAt.bn:=BnBarter;
     Pb^.DAt.OperatorSelector:=5;
     c:=ioresult;
     write(Bf,Pb^.Dat);
     c:=ioresult;
     System.Close(bf);
     c:=ioresult;
   end;
 end;


end;



Destructor TPrihodBarterWindow.Done;
Begin
{
Dispose(ControlVidPrihod,Done);
Dispose(ControlStartSumma,Done);
Dispose(ControlOstatok,Done);
Dispose(ControlSrokDo,Done);
Dispose(ControlOstatok,Done);
}
TDialog.Done;
End;



Procedure TPrihodBarterWindow.HandleEvent(Var Event:TEvent);
procedure Calculator;
begin
  Calc^.Start;
end;

VAr Test : Word;
    R : TRect;

Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
   Else;
   End;
   Else;
   End;
  Inherited HandleEvent(Event);


  If (Desktop^.Current=PView(PrhWindow)) And (Event.What <> EvKeyDown) Then
   Begin
                if (ControlVidPrihod^.State and sfFocused <> 0)Then
                    Begin
  ControlVidPrihod^.GetDAta(Test);
  If Test<>Prh.VidPrihoda Then
   Begin
    Prh.VidPrihoda:=Test;
    If Prh.VidPrihoda=0 Then
    Begin
    ControlSrokDo^.Options := ControlSrokDo^.Options and not ofSelectable;
    Prh.OstatokDolga:='0.00';
    Dispose(ControlOstatokText,Done);
    R.Assign(38, 2, 53, 3);
    ControlOstatokText := New(PColoredText, Init(R, #3+Prh.OstatokDolga, $7E));
    PrhWindow^.Insert(ControlOstatokText);
    ControlOstatok^.SetDAta(Prh.OstatokDolga);

    End
    Else
     Begin
      ControlSrokDo^.Options := ControlSrokDo^.Options Or ofSelectable;
      Prh.OstatokDolga:=PrhWindow^.SummaPrihodS;
      Dispose(ControlOstatokText,Done);
      R.Assign(38, 2, 53, 3);
      ControlOstatokText := New(PColoredText, Init(R, #3+Prh.OstatokDolga, $7E));
      PrhWindow^.Insert(ControlOstatokText);
      ControlOstatok^.SetDAta(Prh.OstatokDolga);
     End;
    redraw;
   End;
                    End;

    End;
  ClearEvent(Event);
End;


Procedure TPrihodBarterWindow.Ini(Cod:ArtikulStr;Doc,Date : TDateString);
Label 1;                          {код клиента}  {номер и дата документа прихода}
Var
  R : TRect;
  Control : PView;
  C : Word;
  BF : File Of BArterClientType;
  PB : PBarterClientType;
  Pos : LongInt;

  SummaOplat : String[CIZena];
  SummaPrihod : String[CIZena];
  Ostatok : String[CIZena];
  Find : Boolean;
  l1 : Longint;
begin



Assign(Bf,Path.ToBArter+cod+'.brt');
c:=Ioresult;
reset(bf);
c:=Ioresult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия файла '+Path.ToBArter+cod+'.brt',Nil,mfError+mfCancelButton);
  Exit;
 End;

DInfoMSg('Анализирую опреации клиента. Ждите...');


SummaOplat :='0.00';
SummaPrihod:='0.00';
Ostatok:='0.00';
Pos:=0;
Find:=FAlse;

Prh.OstatokDolga:='0.00';
Prh.VidPrihoda:=0;
Prh.Srok:='';



New(pB,Init);
While Not(Eof(bf)) Do
 Begin
  Read(bf,Pb^.Dat);
  If Pb^.Dat.Active Then
   Begin
     If Pb^.Dat.OperatorSelector=0 Then{если приход}
      Begin
       If (StrToInt(Doc)=StrToInt(Pb^.Dat.Document)) And
          (DAte=Pb^.DAt.DAteC) Then
          Begin
           Pos:=FilePos(bf)-1;
           SummaPrihod:=Pb^.Dat.PSummaZakupka;
           Find:=True;
           Prh.OstatokDolga:=Pb^.Dat.OstatokDolga;
           Prh.VidPrihoda:=Pb^.Dat.VidPrihoda;
           If Prh.VidPrihoda=1 Then
           Prh.Srok:=Pb^.Dat.SrokPlatega;
           SummaOplat:=Pb^.DAt.Vidano;
          End;
      End;

     If Pb^.Dat.OperatorSelector=2 Then{если расход}
      Begin
        If Pb^.Dat.Link=1 Then{если связанный платеж}
	   Begin
         If (StrToInt(Pb^.Dat.Doc)=StrToInt(Doc)) And
            (DAte=Pb^.DAt.DAte) Then
             Begin
              Str(StrToReal(SummaOplat)+StrToReal(Pb^.DAt.Vidano):CIZena:CMAntissa,SummaOplat);
             End;
	   End;
      End;

   End;{Active}
 End;{While}


c:=Ioresult;
System.Close(bf);
c:=Ioresult;

If Not(Find) Then
 Begin
  MessageBox(#3'Накладная N '+Doc+' от '+Date+' не найдена в файле взаиморасчетов с клиентом!',Nil,
  mfError+mfCAncelButton);
  Exit;
 End;


Str(Strtoreal(SummaOplat):CIZena:cmantissa,SummaOplat);
Str(Strtoreal(SummaPrihod):cizena:cmantissa,SummaPrihod);
Str(Strtoreal(Prh.OstatokDolga):cizena:cmantissa,Ostatok);

DelSpace(SummaOplat);
DelSpace(SummaPrihod);
DelSpace(Ostatok);


{If Prh.VidPrihoda=1 Then
If Abs((StrToreal(SummaPrihod)-StrToReal(SummaOplat)))>0.009 Then
 Begin
  MessageBox(^M+#3'Обнаружена расбалансировка в расчетах с клиентом!',Nil,
  mfError+mfCAncelButton);
 End; }

Dispose(Pb,Done);

NoInfoMsg;

1:

If StrToInt(CurrentPassword)=0 Then
R.Assign(13, 8, 67, 17)
Else
R.Assign(13, 8, 67, 14);
New(PrhWindow, Init(R, 'Свойства накладной прихода'));
PrhWindow^.Options := PrhWindow^.Options or ofCenterX or ofCenterY;
PrhWindow^.HelpCtx := $E191;

PrhWindow^.CodS:= Cod;
PrhWindow^.DocS:= Doc;
PrhWindow^.DateS:= Date;
PrhWindow^.SummaOplatS:= SummaOplat;
PrhWindow^.SummaPrihodS:= SummaPrihod;
PrhWindow^.OstatokS:= Ostatok;


R.Assign(2, 4, 27, 5);
ControlVidPrihod := New(PCheckboxes, Init(R,
  NewSItem('Отсрочка платежа', Nil)));
PrhWindow^.Insert(ControlVidPrihod);
If (Abs(StrToReal(SummaOplat)))>0.009 Then ControlVidPrihod^.Options := ControlVidPrihod^.Options and not ofSelectable;

R.Assign(27, 4, 37, 5);
ControlSrokDo := New(PInputLine, Init(R, CDAte));
PrhWindow^.Insert(ControlSrokDo);
  PInputLine(ControlSrokDo)^.Validator := New(PPXPictureValidator, Init(DAteFiltr, True));

If Prh.VidPrihoda=0 Then ControlSrokDo^.Options := ControlSrokDo^.Options and not ofSelectable;

If Prh.VidPrihoda=0 Then Prh.Srok[0]:=#0;

If (Abs(StrToReal(PrhWindow^.OstatokS))<0.009) And (Prh.VidPrihoda=0)  Then
ControlSrokDo^.Options := ControlSrokDo^.Options and not ofSelectable;

  R.Assign(26, 3, 35, 4);
  PrhWindow^.Insert(New(PLabel, Init(R, 'Срок до:', ControlSrokDo)));

R.Assign(2, 1, 11, 2);
Control := New(PColoredText, Init(R, 'Документ:', $74));
PrhWindow^.Insert(Control);

R.Assign(11, 1, 15, 2);
Control := New(PColoredText, Init(R, #3+Doc, $7E));
PrhWindow^.Insert(Control);

R.Assign(16, 1, 19, 2);
Control := New(PColoredText, Init(R, 'от', $74));
PrhWindow^.Insert(Control);

R.Assign(19, 1, 27, 2);
Control := New(PColoredText, Init(R, #3+Date, $7E));
PrhWindow^.Insert(Control);


R.Assign(2, 2, 16, 3);
Control := New(PColoredText, Init(R, 'Сумма прихода:', $74));
PrhWindow^.Insert(Control);

R.Assign(16, 2, 31, 3);
ControlStartSumma := New(PColoredText, Init(R, #3+SummaPrihod, $7E));
PrhWindow^.Insert(ControlStartSumma);




R.Assign(38, 2, 53, 3);
ControlOstatokText := New(PColoredText, Init(R, #3+Ostatok, $7E));
PrhWindow^.Insert(ControlOstatokText);

R.Assign(33, 2, 38, 3);
Control := New(PColoredText, Init(R, 'Долг:', $74));
PrhWindow^.Insert(Control);




R.Assign(16, 6, 33, 7);
ControlOstatok := New(PInputLine, Init(R, CIZena));
PrhWindow^.Insert(ControlOstatok);

  R.Assign(1, 6, 16, 7);
  PrhWindow^.Insert(New(PLabel, Init(R, 'Остаток долга:', ControlOstatok)));
If StrToInt(CurrentPassword)<>0 Then
ControlOstatok^.Options := ControlOstatok^.Options and not ofSelectable;

PrhWindow^.Insert(ControlOstatok);


PrhWindow^.SelectNext(False);



PrhWindow^.SetData(Prh);

c := Desktop^.ExecView(PrhWindow);

If c=cmOk Then
 Begin
  PrhWindow^.GetData(Prh);
  DelSpace(Prh.OstatokDolga);
  DelSpace(Prh.Srok);

  If Prh.VidPrihoda=1 Then
   Begin
    DelSpace(Prh.Srok);
    If Not TestDAte(Prh.Srok,l1) Then
     Begin
      Dispose(Control,Done);
      Dispose(PrhWindow,Done);
      MessageBox(^M+#3+'Недопустимая дата в сроке платежа!',Nil,mfError+mfCancelButton);
      Goto 1;
     End;

    If (Prh.Srok[0])=#0 Then
     Begin
      Dispose(Control,Done);
      Dispose(PrhWindow,Done);
      MessageBox(^M+#3+'Не указан срок платежа!',Nil,mfError+mfCancelButton);
      Goto 1;
     End;

    If DAteStringToDAte(DateMAsk,FDAte)>DAteStringToDAte(DateMAsk,Prh.Srok) Then
     Begin
      If MessageBox(^M+#3'Указанный Вами срок платежа уже прошел!'^M+
	 #3'Вы уверены что он указан верно?',nil,mfOkCAncel)=cmCancel Then
       BEgin
        Dispose(Control,Done);
        Dispose(PrhWindow,Done);
        Goto 1;
       End;
     End;


   End;

Assign(Bf,Path.ToBArter+cod+'.brt');
c:=Ioresult;
reset(bf);
c:=Ioresult;
If c<>0 Then
 Begin
      Dispose(Control,Done);
      Dispose(PrhWindow,Done);
      MessageBox(^M+#3+'Ошибка открытия файла '+Path.ToBArter+cod+'.brt',Nil,mfError+mfCancelButton);
      Goto 1;
 End;

DInfoMSg('Сохраняю изменения. Ждите...');


Seek(bf,Pos);
New(Pb,Init);
Read(bf,pb^.Dat);
Seek(bf,Pos);

Pb^.DAt.VidPrihoda:=Prh.VidPrihoda;
Pb^.DAt.SrokPlatega:=Prh.Srok;
Pb^.DAt.OstatokDolga:=Prh.OstatokDolga;

Write(bf,Pb^.DAt);
c:=IoResult;
System.Close(bf);
c:=IoResult;

Dispose(Pb,Done);
NoInfoMsg;

AddProtocol('Корректировка статуса накладной прихода N '+Doc+' от '+DAte,'','');

 End;{сумма оплаты >= 1 копейки}
 Dispose(Control,Done);
 Dispose(PrhWindow,Done);
end;


procedure TBArterWindow.OpenBarterWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmDolg, nil) = nil then
  begin
    DInfo('Инициализация взаимозачетов с клиентами...');
    L:=True;
    BarterWindow := New(PBarterWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(BarterWindow);
    NoInfo;
    End
    Else
     Begin
      TekDate:=FDAte;
      Status:=DocNormal;
      Dispose(BArterWindow,Done);
      NoInfo;
     End;
  end
  else
	 if PView(BarterWindow) <> Desktop^.TopView then BarterWindow^.Select;
end;



constructor TBarterWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : LongInt;
  p : Real;
  wp : String[cIzena];
  cod : ArtikulStr;
  i : word;
begin
VidPrihod:=1;
ClearFind;
L:=False;
R.Assign(0, 0, 80, 23);
Inherited Init(R, 'Поставщик');
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E002;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    Exit;
   End;


R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'Barter.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(ClientFile)) Do
 Begin

        ReadClient(ClientFile,ClientElement^.Dat);

  If ClientElement^.Dat.Employ Then
   Begin
    Format (ClientElement^.Dat.Name,CClient);
    Client^.List^.Insert(NewStr(ClientElement^.Dat.Name+'│'+ClientElement^.Dat.Kod));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(ClientFile);
{здесь вставить код осуществляющий блокировку ближайшего доступного клиента}
If Not(SetLockNearClient({Client,}0,2,Cod)) Then
  Begin
   Dispose(Client,Done);
   L:=False;
   MessageBox(^M+#3'Не могу заблокировать ни одного клиента!',Nil,mfError+mfCancelButton);
   Exit;
  End;
End
Else
 Begin
  L:=False;
  Dispose(Client,Done);
  Exit;
 End;


PrevS:=Client^.GEtText(Location(Client,Cod,False),Client^.List^.COunt);{фокус должен попасть на заблокированного клиента}
Dispose(Client,Done);

R.Assign(52, 0, 79, 1);
ControlClient := New(PColoredText, Init(R, #3+PrevS, $1F));
ControlClient^.Options := ControlClient^.Options or ofSelectable;
Insert(ControlClient);

i:=511;
FiltrDoc:=i;

i:=1;
FiltrOperation:=i;


R.Assign(53, 1, 68, 3);
Control := New(PColoredText, Init(R, 'За период  с  '^M+
                                     '           по ', $74));
Insert(Control);

StartDate:='01-04-98';
StopDate:=FDate;

R.Assign(69, 1, 77, 2);
ControlStart := New(PColoredText, Init(R, StartDate, $7E));
Insert(ControlStart);

R.Assign(69, 2, 77, 3);
ControlStop := New(PColoredText, Init(R, StopDate, $7E));
Insert(ControlStop);


R.Assign(79, 5, 80, 20);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(1, 4, 79, 20);
BarterList := New(PBox, Init(R, 1, PScrollbar(Control)));
BarterList^.NewList(New(PMyCollection, Init(0,1)));
PrevS:=Copy(PrevS,1+CClient+1,CClientKod);
BarterList^.FocusItem(0);
BarterList^.HelpCtx:=$C200;

R.Assign(1, 3, 79, 4);
Insert(New(PLabel, Init(R,'  N    Дата     Поступление'+
'       Оплаты        Время   Оператор', BarterList)));
Insert(barterlist);


R.Assign(1, 20, 35, 21);
ControlVidPrihodWin := New(PCheckboxes, Init(R,
NewSItem('Только не оплаченные приходы', Nil)));
Insert(ControlVidPrihodWin);
ControlVidPrihodWin^.SetData(VidPrihod);


R.Assign(39, 20, 55, 21);
ControlOstatokWin := New(PColoredText, Init(R, #3'?', $7E));
Insert(ControlOstatokWin);


R.Assign(1, 21, 6, 22);
Control := New(PColoredText, Init(R, 'Прим:', $74));
Insert(Control);

R.Assign(6, 21, 51, 22);
ControlPrim := New(PColoredText, Init(R, #3'?', $7E));
Insert(ControlPrim);

R.Assign(52, 21, 61, 22);
Control := New(PColoredText, Init(R, 'Вид док.:', $74));
Insert(Control);

R.Assign(61, 21, 65, 22);
ControlDoc := New(PColoredText, Init(R, #3+'?', $7E));
Insert(ControlDoc);

R.Assign(66, 21, 76, 22);
Control := New(PColoredText, Init(R, 'Вид расч.:', $74));
Insert(Control);

R.Assign(76, 21, 79, 22);
ControlViewRashet := New(PColoredText, Init(R, #3+'?', $7E));
Insert(ControlViewRashet);

R.Assign(1, 22, 16, 23);
Control := New(PColoredText, Init(R, ' E  Приход    :', $74));
Insert(Control);

R.Assign(16, 22, 31, 23);
ControlPrihod := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(ControlPrihod);

R.Assign(31, 22, 41, 23);
Control := New(PColoredText, Init(R, ' E Оплата:', $74));
Insert(Control);

R.Assign(41, 22, 56, 23);
ControlRashod := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(ControlRashod);

R.Assign(56, 22, 64, 23);
Control := New(PColoredText, Init(R, ' Сальдо:', $74));
Insert(Control);

R.Assign(64, 22, 79, 23);
ControlSaldo := New(PColoredText, Init(R, #3+'0.00', $4E));
Insert(ControlSaldo);

SelectNext(False);
CalcItogo;
L:=True;
end;


Procedure TBarterWindow.CalcItogo;

Var R : TRect;
    R1,R2 : Real;
    s1,s2 :String[CIZena+1];
    i : Word;
    r3: Word;

Begin
r1:=0;
r2:=0;
If BarterList^.List^.Count-1>=0 Then
 For i:=0 To BarterList^.List^.Count-1 Do
 Begin
  PrevS:=BarterList^.GetText(i,BarterList^.List^.Count);
  s1:=Copy(PrevS,1+CDocNumer+1+CDate+1,CIZena);
  s2:=Copy(PrevS,1+CDocNumer+1+CDate+1+CIZena+1,CIZena);
  r1:=r1+StrToReal(s1);
  r2:=r2+StrToReal(s2);
 End;
Dispose(ControlPrihod,Done);
PrevS:=RealToStr(r1,CIzena,CMantissa);
DelSpace(PrevS);
R.Assign(16, 22, 31, 23);
ControlPrihod := New(PColoredText, Init(R, #3+PrevS, $4E));
Insert(ControlPrihod);

Dispose(ControlRashod,Done);
PrevS:=RealToStr(r2,CIzena,CMantissa);
DelSpace(PrevS);
R.Assign(41, 22, 56, 23);
ControlRashod := New(PColoredText, Init(R, #3+PrevS, $4E));
Insert(ControlRashod);

PrevS:=RealToStr(r2-r1,CIzena,CMantissa);
DelSpace(PrevS);
Dispose(ControlSaldo,Done);
R.Assign(64, 22, 79, 23);
ControlSaldo := New(PColoredText, Init(R, #3+PrevS, $4E));
Insert(ControlSaldo);
Redraw;
End;


Procedure TBarterWindow.DrawCurrent;
Var St : TMyString;
    ww : AllStr;
    R  : TRect;
Begin
if (BarterList^.List<>Nil)And(BarterList^.List^.Count>=1) Then
 Begin
  st:=BarterList^.GetText(BarterList^.Focused,BarterList^.List^.Count);
  If st <> PrevCurrent Then
    Begin
      PrevCurrent:=St;
      ww[0]:=#0;
      ww:=Copy(st,1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1+CDAte+1+CKto+1,COne);
      Dispose(ControlDoc,Done);
      If StrToInt(ww)=1 Then
       Begin
        ww:=Copy(st,1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1+CDAte+1+CKto+1+COne+1+COne+1,COne);
        CAse ww[1] Of
            '0':ww:='Сп';
		  '1':ww:='ТЧ*';
		  '2':ww:='ФЛ*';
		  '3':ww:='СФ*';
		  '4':ww:='СФБ';
		  '5':ww:='Д*';
		  '6':ww:='ДСФ*';
		  '7':ww:='Д';
		  '8':ww:='ДСФБ';
			Else ww:='?';
			End;
		 End
		 Else ww:='?';
		R.Assign(61, 21, 65, 22);
		ControlDoc := New(PColoredText, Init(R, #3+ww, $7E));
		Insert(ControlDoc);

		ww[0]:=#0;
		ww:=Copy(st,1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1+CDAte+1+CKto+1+Cone+1,COne);
		Dispose(ControlViewRashet,Done);
		  CAse ww[1] Of
		  '0':ww:='Б/Н';
		  '1':ww:='Нал';
			Else ww:='?';
			End;
		R.Assign(76, 21, 79, 22);
		ControlViewRashet := New(PColoredText, Init(R, #3+ww, $7E));
		Insert(ControlViewRashet);


		Dispose(ControlPrim,Done);
		ww[0]:=#0;
		ww:={Copy(st,Ord(st[0])-CIZena-1-CAll,CAll);}
          Copy(st,1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1+CDAte+1+CKto+1+COne+1+COne+1+COne+1,CAll);
		R.Assign(6, 21, 51, 22);
		ControlPrim := New(PColoredText, Init(R, #3+ww, $7E));
		Insert(ControlPrim);



		Dispose(ControlOstatokWin,Done);
		ww[0]:=#0;
		ww:=Copy(st,1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1+CDAte+1+CKto+1+COne+1+COne+1+COne+1+CAll+1+
		CIZena+1,CIZena);
          R.Assign(39, 20, 55, 21);
          ControlOstatokWin := New(PColoredText, Init(R, #3+ww, $7E));
          Insert(ControlOstatokWin);

		Redraw;
	 End;
 End
  Else
	Begin
		Dispose(ControlDoc,Done);
		R.Assign(61, 21, 65, 22);
		ControlDoc := New(PColoredText, Init(R, #3+'?', $7E));
		Insert(ControlDoc);

		Dispose(ControlPrim,Done);
		ww[0]:=#0;
		R.Assign(6, 21, 51, 22);
		ControlPrim := New(PColoredText, Init(R, #3+'?', $7E));
		Insert(ControlPrim);

		Dispose(ControlViewRashet,Done);
		ww[0]:=#0;
		R.Assign(76, 21, 79, 22);
		ControlViewRashet := New(PColoredText, Init(R, #3+'?', $7E));
		Insert(ControlViewRashet);

		Dispose(ControlOstatokWin,Done);
		ww[0]:=#0;
          R.Assign(39, 20, 55, 21);
          ControlOstatokWin := New(PColoredText, Init(R, #3+'?', $7E));
          Insert(ControlOstatokWin);


	End;
End;

Procedure TBarterWindow.Refresh(Auto:Boolean);
Var r1 : TRect;
	 r,Test : LongInt;
	 P : Real;
	 vidDoc: String[COne];
	 SCurrentSaldo,s : string[150];

	 Op : AllStr;
	 Add : Boolean;
	 CurrentSaldo : Real;
Begin

 WordTobit9(FiltrDoc,mm);
 Convert9(mm);

 WordToBit4(FiltrOperation,mm4);
 Convert4(mm4);


ClearFind;
BArterList^.NewList(Nil);
BArterList^.NewList(New(PMyCollection, Init(0,1)));
PStaticText(ControlClient)^.GetText(PrevS);
System.Delete(PrevS,1,1);

If Auto Then
Begin
 StartDate:='01-04-98';
 StopDate:=FDate;
End;


PrevS:=Copy(PrevS,1+CClient+1,CClientKod);
Assign (BarterFile,Path.ToBArter+PrevS+'.brt');
Test:=IOResult;
Reset (BarterFile);
Test:=IOResult;
CurrentSaldo:=0;

If Test=0 Then
Begin
DInfo('Читаю взаиморасчеты с клиентом...');
New(BArterElement,Init);
While Not(Eof(BarterFile)) Do
 Begin
  Read(BarterFile,BArterElement^.DAt);

  If (BArterElement^.Dat.Active) Then
  Begin

	 Case BArterElement^.DAt.OperatorSelector Of
	 {приход}
	 0:Begin
		If mm4[1]=1 Then
		Begin
		  CurrentSaldo:=CurrentSaldo-StrToReal(BarterElement^.Dat.PSummaZakupka);
		End;{mm4[1]=1}
		End;{0}
	 {расход}
	 1:Begin
		If mm4[2]=1 Then
		Begin
		  CurrentSaldo:=CurrentSaldo+StrToReal(BarterElement^.Dat.SummaZ)+
		  StrToReal(BarterElement^.Dat.ENalog);
		End;
		End;
	 {из кассы}
	 2:Begin
		If mm4[4]=1 Then
		 Begin
		  CurrentSaldo:=CurrentSaldo+StrToReal(BarterElement^.Dat.Vidano);
		 End;
		End;
	 {в кассу}
	 3:Begin
		If mm4[3]=1 Then
		Begin
		  CurrentSaldo:=CurrentSaldo-StrToReal(BarterElement^.Dat.Priniato);
		End;
		End;
	 Else s:='   ?   ';
	 End;

	 Str(CurrentSaldo:CIZena:CMAntissa,SCurrentSaldo);

If(DateStringToDate(DateMask,BarterElement^.Dat.DateC)<=
	DateStringToDate(DateMask,StopDate)) And
  (DateStringToDate(DateMask,BArterElement^.Dat.DateC)>=
	DateStringToDate(DateMask,StartDate)) Then
Begin
	 Add:=False;
	 S[0]:=#0;
	 RFormatZerro(BArterElement^.Dat.Document,CDocNumer);
	 Format (BArterElement^.Dat.Document,CDocNumer);
	 Format (BarterElement^.Dat.DateC,CDAte);
	 Format (BarterElement^.Dat.TimeC,CDAte);
	 Format (BarterElement^.Dat.Comment,CAll);

	 Op:=GetOperatorName(BarterElement^.Dat.Caption);
	 DelSpaceRight(Op);
	 Format(Op,CKto);

	 Case BArterElement^.DAt.OperatorSelector Of
	 0:Begin
		If mm4[1]=1 Then
		Begin
           If (VidPrihod=0) Or ((VidPrihod=1)And (StrToReal(BarterElement^.Dat.OstatokDolga)>0.009)) Then
           Begin
            Case GetPrihodStatus(BArterElement^.Dat.Document,BArterElement^.Dat.DateC) Of
            0: s:='';
            1: s:='';
            Else s:='';
            End;
            format(BarterElement^.Dat.Vidano,CIZena);
            {If (VidPrihod=1) Then}
		  {Str(StrToReal(BarterElement^.Dat.OstatokDolga):CIZena:CMantissa,BarterElement^.Dat.PSummaZakupka);}
		  Str(StrToReal(BarterElement^.Dat.PSummaZakupka):CIZena:CMantissa,BarterElement^.Dat.PSummaZakupka);
		  s:=s+BArterElement^.Dat.Document+'│'+BarterElement^.Dat.DateC+'│'+
			  {+BarterElement^.Dat.PSummaZakupka+'│'+'           0.00'+'│'+BarterElement^.Dat.TimeC+'│'+Op+'│'+}
                  +BarterElement^.Dat.PSummaZakupka+'│'+BarterElement^.Dat.Vidano+'│'+BarterElement^.Dat.TimeC+'│'+Op+'│'+
			  IntToStr(BArterElement^.DAt.OperatorSelector,COne)+'│';
		  Format(BarterElement^.Dat.Comment,CAll);
		  Str(StrToReal(BarterElement^.Dat.OstatokDolga):CIZena:CMantissa,BarterElement^.Dat.OstatokDolga);
		  s:=s+'  ';{неопределен вид расчета}
		  s:=s+' '+'│'+BarterElement^.Dat.Comment;
		  Add:=True;
           End;
		End;{mm4[1]=1}
		End;{0}
	 1:Begin
		If mm4[2]=1 Then
		Begin
		 If mm[BarterElement^.Dat.DocSelector+1]=1 Then
		 Begin
		  s:='отгрузка';
		  Str(StrToReal(BarterElement^.Dat.SummaZ){+StrToReal(BarterElement^.Dat.ENAlog)}:
		  CIZena:CMantissa,BarterElement^.Dat.SummaZ);
		  s:=s+'│'+BArterElement^.Dat.Document+'│'+BarterElement^.Dat.DateC+'│'
			 +'           0.00'+'│'+BarterElement^.Dat.SummaZ+'│'+BarterElement^.Dat.TimeC+'│'+Op+'│'+
			 IntToStr(BArterElement^.DAt.OperatorSelector,COne)+'│';
		  If BArterElement^.Dat.DocSelector in [4,8] Then s:=s+'0│'{б/н}
		  Else s:=s+'1│';{нал}
		  Format(BarterElement^.Dat.Comment,CAll);
		  s:=s+IntToStr(BArterElement^.Dat.DocSelector,COne)+'│'+BarterElement^.Dat.Comment;
		  Add:=True;
		 End;
		End;
		End;
	 2:Begin
		If mm4[4]=1 Then
		 Begin
		  s:='из кассы';
		  Str(StrToReal(BarterElement^.Dat.SummaZ):CIZena:CMantissa,BarterElement^.Dat.SummaZ);
		  s:=s+'│'+BArterElement^.Dat.Document+'│'+BarterElement^.Dat.DateC+'│'
			  +'           0.00'+'│'+BarterElement^.Dat.Vidano+'│'+BarterElement^.Dat.TimeC+'│'+Op+'│'+
			  IntToStr(BArterElement^.DAt.OperatorSelector,COne)+'│';
		  If BArterElement^.Dat.Rashet=1 Then s:=s+'0│'{б/н}
		  Else s:=s+'1│';{нал}
		  Format(BarterElement^.Dat.Comment,CAll);
		  s:=s+'?'+'│'+BarterElement^.Dat.Comment;
		  Add:=True;
		 End;
		End;
	 3:Begin
		If mm4[3]=1 Then
		Begin
		 s:='в кассу ';
		  Str(StrToReal(BarterElement^.Dat.SummaZ):CIZena:CMantissa,BarterElement^.Dat.SummaZ);
		  s:=s+'│'+BArterElement^.Dat.Document+'│'+BarterElement^.Dat.DateC+'│'
			  +BarterElement^.Dat.Priniato+'│'+'           0.00'+'│'+BarterElement^.Dat.TimeC+'│'+Op+'│'+
			  IntToStr(BArterElement^.DAt.OperatorSelector,COne)+'│';
		  If BArterElement^.Dat.Rashet=1 Then s:=s+'0│'{б/н}
		  Else s:=s+'1│';{нал}
		  Format(BarterElement^.Dat.Comment,CAll);
		  s:=s+'?'+'│'+BarterElement^.Dat.Comment;
		 Add:=True;
		End;
		End;
       5:Begin
		If mm4[1]=1 Then
          if abs(StrToReal(BarterElement^.Dat.Bn.Summa))>0.009 then
		Begin
            s:='';
            BarterElement^.Dat.Vidano:=BarterElement^.Dat.Bn.Summa;
            rformat(BarterElement^.Dat.Vidano,CIZena);
            {If (VidPrihod=1) Then}
		  {Str(StrToReal(BarterElement^.Dat.OstatokDolga):CIZena:CMantissa,BarterElement^.Dat.PSummaZakupka);}
		  Str(StrToReal(BarterElement^.Dat.PSummaZakupka):CIZena:CMantissa,BarterElement^.Dat.PSummaZakupka);
		  s:=s+'п/опл'+BarterElement^.Dat.DateC+'│'+
			  {+BarterElement^.Dat.PSummaZakupka+'│'+'           0.00'+'│'+BarterElement^.Dat.TimeC+'│'+Op+'│'+}
                  +BarterElement^.Dat.PSummaZakupka+'│'+BarterElement^.Dat.Vidano+'│'+BarterElement^.Dat.TimeC+'│'+Op+'│'+
			  IntToStr(BArterElement^.DAt.OperatorSelector,COne)+'│';
		  Format(BarterElement^.Dat.Comment,CAll);
		  Str(StrToReal(BarterElement^.Dat.OstatokDolga):CIZena:CMantissa,BarterElement^.Dat.OstatokDolga);
		  s:=s+'  ';{неопределен вид расчета}
		  s:=s+' '+'│'+BarterElement^.Dat.Comment;
		  Add:=True;
		End;{mm4[1]=1}
		End;{5}
	 Else s:='   ?   ';


	 End;

	 If Add Then
	 Begin
       If BArterElement^.DAt.OperatorSelector=0 Then
	  s:=s+'│'+SCurrentSaldo+'│'+BarterElement^.Dat.OstatokDolga
       Else
	  s:=s+'│'+SCurrentSaldo+'│';
	  BarterList^.List^.Insert(NewStr(s));
	  BarterList^.SetRange(BarterList^.List^.Count);
	 End;
End;
  End;{}
End;
Dispose(BArterElement,Done);
System.Close(BarterFile);
NoInfo;
End;
BArterList^.FocusItem(0);
BarterList^.HelpCtx:=$C200;

Dispose(ControlStart,Done);
R1.Assign(69, 1, 77, 2);
ControlStart := New(PColoredText, Init(R1, #3+StartDate, $7E));
Insert(ControlStart);

Dispose(ControlStop,Done);
R1.Assign(69, 2, 77, 3);
ControlStop := New(PColoredText, Init(R1, #3+StopDate, $7E));
Insert(ControlStop);

CalcItogo;
PrevCurrent[0]:=#0;
End;



Procedure TBarterWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1 : TMyString;
    l : Boolean;
    R : Real;
    b : Byte;
    BnLogik : Boolean;
    Bn : BezNal;
    SClientKod,SDoc : ArtikulStr;
    SDate : TDateString;
    Cod, Doc,DAtes : TDAteString;
    Ass : DocumentEdit;
begin
  Case Event.What Of
  evKeyDown : Begin
        Case Event.KeyCode Of
         kbF2 : Begin
                 Event.What:=evCommand;
                 Event.Command:=cmChangeDiapason;
                 PutEvent(Event);
                 ClearEvent(Event);
                End;
         kbAltF9:Begin
                  Event.What:=evCommand;
                  Event.Command:= cmReestrReport;
						PutEvent(Event);
                  ClearEvent(Event);
                 End;
        Else;
        End;
				  End;
  evCommand :
        Case Event.Command Of

         cmAbout: Begin
              ClearEvent(Event);
              AboutCHM('29');
         End;

         cmCancel : Begin
                 PStaticText(ControlClient)^.GetText(S);
                 System.Delete(S,1,1);

                 Repeat
                 Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,2));

                 Event.What:=evCommand;
                 Event.Command:=cmClose;
					  EnableCommands([cmFullview])
                    End;
 {свойства прихода}
 cmProperties :Begin
                s:=BarterList^.GEtText(BarterList^.Focused,BArterList^.List^.Count);
                s:=Copy(s,1,1);
                s:='п';
         		 if s[1]='п' then
                  Begin
                   PStaticText(ControlClient)^.GetText(S1);
                   System.Delete(S1,1,1);
                   Cod:=Copy(s1,1+CClient+1,CClientKod);
                   s:=BarterList^.GEtText(BarterList^.Focused,BArterList^.List^.Count);
                   Doc:=Copy(s,1,CDocNumer);
                   Dates:=Copy(s,1+CDocNumer+1,CDAte);
                   PrhW^.Ini(Cod,Doc,Dates);
     		    Refresh(False);
                  End;
               End;
 cmChangeDiapason :
        Begin
          If (DAtePeriodDialog(StartDate,StopDate,False)) Then Refresh(False);
          ClearEvent(Event);
        End;
 cmAddKassa : if (User[70] or (CurrentPassword='00')) then
 Begin
              PStaticText(ControlClient)^.GetText(S);
              System.Delete(S,1,1);
              System.Delete(s,1,21);
             { OBW^.Ini(1,s,Ass);}
              Refresh(False);
              ClearEvent(Event);
             End;
 cmOutKassa : if (User[71] or (CurrentPassword='00')) then
 Begin
     If (BarterList^.State and sfFocused <> 0) And (BarterList^.List<>Nil)And(BarterList^.List^.Count>=1) Then
             Begin
              s1:=BarterList^.GEtText(BarterList^.Focused,BArterList^.List^.Count);
                Ass.EditPosition:=Copy(s1,1,CDocNumer);
                DelSpace(Ass.EditPosition);
                DelZerro(Ass.EditPosition);
                Ass.D:=Copy(s1,1+CDocNumer+1,CDate);
                DelSpace(Ass.D);

              PStaticText(ControlClient)^.GetText(S);
              System.Delete(S,1,1);
              System.Delete(s,1,21);
              OBW^.Ini(0,s,Ass);
  		    Refresh(False);
              ClearEvent(Event);
             End;
 End;
 cmRefresh:
        Begin
			 Refresh(False);
          ClearEvent(Event);
        End;

 cmReestrReport:
            Begin
             ClearFind;
     If (BarterList^.State and sfFocused <> 0) And (BarterList^.List<>Nil)And(BarterList^.List^.Count>=1) Then
              Begin
               PStaticText(ControlClient)^.GetText(S);
               System.Delete(S,1,1);
               sClientKod:=Copy(s,1+CClient+1,CClientKod);
               FormReport(BArterList,SClientKod);
              End
            End;
     cmFullview : Begin
     If (BarterList^.State and sfFocused <> 0) And (BArterList^.List<>Nil)And(BarterList^.List^.Count>=1) Then
              Begin
               s:=BarterList^.GEtText(BarterList^.Focused,BArterList^.List^.Count);
               s:=Copy(s,1,1);
               s:='п';
					Case s[1] Of
               'п':FullPreviewPrh;
               'о':FullPreview;
               Else;
               End;
               ClearEvent(Event);
              End;
                  End;
     cmPrintReestr : if (User[69] or (CurrentPassword='00')) then
	Begin
     If (BarterList^.State and sfFocused <> 0) And (BArterList^.List<>Nil)And(BarterList^.List^.Count>=1) Then
              Begin
               s:=BarterList^.GEtText(BarterList^.Focused,BArterList^.List^.Count);
			s:=Copy(s,1,1);
               s:='п';
               Case s[1] Of
               'п':PrintPrh;
               'о':PrintMrk;
               Else;
					End;
               ClearEvent(Event);
              End;
                  End;

  cmSelectClient:
 Begin
  If (PView(Cl)<>Desktop^.TopView)And(ControlClient^.State and sfFocused <> 0) Then
  Begin
     ControlClient^.Focus;
     PStaticText(ControlClient)^.GetText(S);
     System.Delete(S,1,1);
     Repeat
     Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,2));

     Cl^.ShowClientList(s,2,0,l,True,True,-1,-1,-1,-1,Test);

     PStaticText(ControlClient)^.Text^:=#3+S;
     PrevS:=S;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
     End;
     Refresh(True);
     PrevCurrent[0]:=#0;
	  {DrawCurrent;}
     {Redraw;}
     ClearEvent(Event);
  End
  Else
     ClearEvent(Event);
 End;
      Else;
		End;{evCommand}
      Else;
      End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmBarter) then ClearEvent(Event);
  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);

 If (PView(Cl)<>Desktop^.TopView)And(ControlClient^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectClient) And (Event.What <> EvKeyDown)Then
            Begin
                   Event.What:=EvCommand;
                   Event.Command:=cmSelectClient;
                   PutEvent(Event);
                   ClearEvent(Event);
            End;

  inherited HandleEvent(Event);


  If (Desktop^.Current=PView(BarterWindow)) And (Event.What <> EvKeyDown) Then
   Begin

                if (ControlVidPrihodWin^.State and sfFocused <> 0)Then
                    Begin
				    ControlVidPrihodWin^.GetData(Test);
                        If Test <> VidPrihod Then
                        Begin
                           ClearFind;
					  VidPrihod:=Test;
                           Refresh(False);
                           CalcItogo;
                           PrevCurrent[0]:=#0;
                        End;
                    End;
		  DrawCurrent;


	End
End;


Procedure TBarterWindow.FormReport;
Const Space=' ';
Var f : text;
	 ws,s,s1,s2 : string[150];
	 c,w : Word;
	 Find : Boolean;
	 SSaldo:String[CIZena];
Begin
If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path.ToTemp+'saldo.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
	MessageBox(#3^m+#3+'Не могу создать файл '+Path.ToTemp+'saldo.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(f);

 AInfo('Минуточку...');

 Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');
 s:=GetClientField(FClient,SCKod,2);
 DelSpaceRight(s);
 Writeln(f,Space+Space+'СПРАВКА ПО ВЗАИМОРАСЧЕТАМ С КЛИЕНТОМ '+s+'('+SCKod+')');
 Writeln(f,Space+'За период с:'+StartDAte+' по '+StopDAte);
 Writeln(f,Space+'В отчет включены следующие операции:');

 WordTobit9(FiltrDoc,mm);
 Convert9(mm);

 {WordToBit4(FiltrOperation,mm4);}
 WordToBit4(9,mm4);
 Convert4(mm4);
 Write(f,Space);
 For c:=1 To 4 Do
  Begin
	If mm4[c]=1 Then
	 Case c Of
	 1:Write(f,' "приход" ');
	 2:Write(f,' "отгрузка" ');
	 3:Write(f,' "в кассу" ');
	 4:Write(f,' "оплаты" ');
	 Else;
	 End;
  End;
 Writeln(f);

 Writeln(f,Space+'____________________________________________________________________________________________');
 Writeln(f,Space+' N    Дата     Поступления       Оплаты        Время   Оператор     Текущее сальдо');
					  {1234│12345678│12345678│123456789012345│123456789012345│12345678│123456789012│123456789012345'}
 Writeln(f,Space+'____________________________________________________________________________________________');

 For c:=0 To P^.List^.Count-1 Do
  Begin
	s := P^.GetText(c,P^.List^.Count);

	While Pos('│',s)>0 Do
	 Begin
	  w:=Pos('│',s);
	  System.Delete(s,w,1);
	  System.Insert(' ',s,w);
	 End;
	SSaldo:=Copy(s,Ord(s[0])-CIZena,CIZena);

	s[0]:=Chr(1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1+CDAte+1+CKto);
	s:=s{+' '+s1};


	Writeln(f,Space+s+SSaldo);
  End;

 Writeln(f,Space+'____________________________________________________________________________________________');




PStaticText(ControlPrihod)^.GetText(S);
System.Delete(S,1,1);
Writeln(f,Space+'                         Всего поступления составили по З/Ц: '+RecognizReal(StrToReal(s),CIZena,CMantissa));

PStaticText(ControlRashod)^.GetText(S);
System.Delete(S,1,1);
Writeln(f,Space+'                                   Всего оплата   составила: '+RecognizReal(StrToReal(s),CIZena,CMantissa));

PStaticText(ControlSaldo)^.GetText(S);
System.Delete(S,1,1);
Writeln(f,Space+'                                                     САЛЬДО: '+RecognizReal(StrToReal(s),CIZena,CMantissa));


 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'============================================================================================');
 System.Close(f);
 NoInfo;
 ViewAsText(Path.ToTemp+'saldo.txt',True);
 Report(Path.ToTemp+'saldo.txt','',1,False,False
 ,false);
 End;

End;

{
Procedure TBarterWindow.FullPreviewMrk;
Var Ass : DocumentEdit;
	 E : PSuperMarketType;
	 R : TRect;
	 f : MarketFileType;
	 c : Word;
	 P : PBox;
	 s,ws : string[150];
	 Find : Boolean;
	 SDoc : ArtikulStr;
	 SDate : TDateString;
	 ws1,WspomSkidka:String[CIZena];
	 v : Byte;
	 SKolish,SClientKod,SAgentKod : ArtikulStr;
	 SCommentr : string[150];


Begin
If (BarterList^.List<>Nil)And(BarterList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(BarterList^.GetText(BarterList^.Focused,BarterList^.List^.Count),9+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(BarterList^.GetText(BarterList^.Focused,BarterList^.List^.Count),9+1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  ViewMrk^.FullScreenMrk(Ass);
End;
End;
}
Procedure TBarterWindow.PrintMrk;
Var Ass : DocumentEdit;
    c : Word;
Begin
If (BarterList^.List<>Nil)And(BarterList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(BarterList^.GetText(BarterList^.Focused,BarterList^.List^.Count),1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(BarterList^.GetText(BarterList^.Focused,BarterList^.List^.Count),1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  {PrintNaklSklad(Ass,NPrint.CopyNkl);}
  PrintNakl(Ass,NPrint.CopyNkl);
End;
End;


Procedure TBarterWindow.FullPreviewPrh;
Var Ass : DocumentEdit;
    E : PPrihodType;
    R : TRect;
    f : PrihodFileType;
    c : Word;
    P : PBox;
    s,ws : TMyString;
    Find : Boolean;
    SDoc : ArtikulStr;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];

Begin
If (BarterList^.List<>Nil)And(BarterList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(BarterList^.GetText(BarterList^.Focused,BarterList^.List^.Count),1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(BarterList^.GetText(BarterList^.Focused,BarterList^.List^.Count),1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  Assign(f,Path.ToPrihod+Ass.d+'.prh');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
  Begin
   MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path.ToPrihod+Ass.d+'.prh',Nil,mfError+mfCancelButton);
   Exit;
  End;
  AInfo('Ищу документ...');
  New(E,Init);
  Find := False;
  ClearChar(Ass.EditPosition);
  While Not(Eof(f)) And Not(Find) Do
   Begin
     {
     Repeat
     Until NetCAll.Lock(f,FilePos(f)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadPrihod(f,E);
     {
     Repeat
      NetCall.UnLock(f,(FilePos(f)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
    ClearChar(E^.Dat.Document);
    If (E^.Dat.DateC=Ass.D) and
    (E^.Dat.Document=Ass.EditPosition) Then
                Begin
                 Find:=True;
                 Break;
                End;
   End;
   System.Close(f);
   If Find Then
    Begin
        R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));
{Ниаменование                Код  N Фас Литр  Колич  З/Цена   Р/Цена  Упаковок
{12345678901234567890123456│12345│1│123│12345│12345│12345678│12345678│123456789│}

For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.PrihodElement[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,CName);
  s:=ws+'│'+s;
  ws:=GetIdField(FInPack,E^.Dat.PrihodElement[c].BazKod);
  RFormat(ws,CInPack);
  s:=s+'│'+ws;

  ws:=GetIdField(FLitr,E^.Dat.PrihodElement[c].BazKod);
  RFormat(ws,CInPack);
  s:=s+'│'+ws;

  DelSpace(E^.Dat.PrihodElement[c].Input.Kol);
  RFormat(E^.Dat.PrihodElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.PrihodElement[c].Input.Kol;

  DelSpace(E^.Dat.PrihodElement[c].Input.Zakupka);
  RFormat(E^.Dat.PrihodElement[c].Input.Zakupka,CZena);
  s:=s+'│'+E^.Dat.PrihodElement[c].Input.Zakupka;

  DelSpace(E^.Dat.PrihodElement[c].Input.R_Zena);
  RFormat(E^.Dat.PrihodElement[c].Input.R_Zena,CZena);
  s:=s+'│'+E^.Dat.PrihodElement[c].Input.R_Zena;

  ws:=CalcPack(E^.Dat.PrihodElement[c].BazKod,E^.Dat.PrihodElement[c].Input.Kol);
  DelSpace(ws);
  Format(ws,CPAck);
  s:=s+'│'+ws+'│';


  P^.List^.Insert(NewStr(s));
  P^.SetRange(P^.List^.Count);
 End;
P^.FocusItem(0);
{
s:=E^.Dat.SummaZ;
DelSpace(s);
s:=' Всего сумма: '+s;
DelSpace(E^.Dat.Skidka);
s:=s+'  Всего скидка'+ws+': '+E^.Dat.Skidka;
}
s:=E^.Dat.SummaZakupka;
DelSpace(s);
s:=' Всего по З/Ценам: '+s;
ws:=E^.Dat.SummaR;
DelSpace(ws);
s:=s+' Всего по Р/Ценам: '+ws;

SDoc:=E^.Dat.Document;
SDate:=E^.Dat.DateC;

Dispose(E,Done);

NoInfo;
                   {Вставить номер и дату документа в просмотре}

FullScreen(P,'Наименование товара         Код  Фас Литр  Колич  З/Цена   Р/Цена   Упаковок',s,
             {12345678901234567890123456│12345│123│12345│12345│12345678│12345678│123456789}
SDoc,SDAte,0);

Dispose(P,Done);
    End
Else
  Begin
   NoInfo;
   MessageBox(#3^M+#3'Документ в базе прихода не найден!',Nil,mfError+mfCancelButton);
   Dispose(E,Done);
  End;
End;

End;

Procedure TBarterWindow.PrintPrh;
Var Ass : DocumentEdit;
    c : Word;
Begin
If (BarterList^.List<>Nil)And(BarterList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(BarterList^.GetText(BarterList^.Focused,BarterList^.List^.Count),1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(BarterList^.GetText(BarterList^.Focused,BarterList^.List^.Count),1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  If MessageBox(^M+#3'Печатать накладную прихода N '+Ass.EditPosition+' от '+Ass.D+'?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
  PrintPrihod(Ass);
End;
End;

procedure TBarterWindow.FullPreview;
Var Ass : DocumentEdit;
    E : PSuperMarketType;
    R : TRect;
    f : MarketFileType;
    c : Word;
    P : PBox;
    s,ws : TMyString;
    Find : Boolean;
    SDoc : ArtikulStr;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];

Begin
If (BarterList^.List<>Nil)And(BarterList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(BarterList^.GetText(BarterList^.Focused,BarterList^.List^.Count),1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(BarterList^.GetText(BarterList^.Focused,BarterList^.List^.Count),1+CDocNumer+1,CDate);

  DelSpace(Ass.D);
  Assign(f,Path.ToMarket+Ass.d+'.mrk');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
  Begin
   MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path.ToMarket+Ass.d+'.mrk',Nil,mfError+mfCancelButton);
   Exit;
  End;
  DInfo('Ищу документ...');
  New(E,Init);
  Find := False;
  ClearChar(Ass.EditPosition);
  While Not(Eof(f)) And Not(Find) Do
   Begin
  {
  Repeat
  Until NetCall.Lock(F,FilePos(F)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
  }
  ReadMarket(F,E);
  {
  Repeat
  NetCall.UnLock(F,(FilePos(F)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
  Until (DosError=0);
  }
    ClearChar(E^.Dat.Document);
    If (E^.Dat.Active) And (E^.Dat.DateC=Ass.D) and
    (E^.Dat.Document=Ass.EditPosition) Then
          Begin
           Find:=True;
           Break;
          End;
   End;
   System.Close(f);
   If Find Then
    Begin
     R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(1,1)));
For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.MarketElement[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,CName);
  s:=s+'│'+ws+'│';
  Str(E^.Dat.MarketElement[c].Input.DivisionSNumber:1,ws);
  s:=s+ws;
  DelSpace(E^.Dat.MarketElement[c].Input.Kol);
  Format(E^.Dat.MarketElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Kol;
  {  ws:=GetIdField(FLitr,E^.Dat.MarketElement[c].BazKod);
  Format(Ws,CLitr);
  s:=s+'│'+ws;}
  DelSpace(E^.Dat.MarketElement[c].Input.Zena);
  Format(E^.Dat.MarketElement[c].Input.Zena,CZena);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Zena;


      Case E^.Dat.SkidkaSelector Of
      0:Begin{скидка автоматическая}
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
         (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         {форматируем прценты}
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Proz):CZena:CMantissa,ws1);
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Skidka):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
        (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100)):CZena:CMantissa,wspomSkidka);

         S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      2:Begin{скидка ручная по шкалам}
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
         (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         {форматируем проценты}
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Proz):CZena:CMantissa,ws1);
         Str(StrToReal(E^.Dat.MarketElement[c].Input.Skidka):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
        (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100)):CZena:CMantissa,wspomSkidka);

         S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      1:Begin{скидка ручная}

           If StrToReal(E^.Dat.MarketElement[c].Input.Skidka)>=0 Then
           Begin
          If (StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka))>0.009 Then
          Str(((StrToReal(E^.Dat.MarketElement[c].Input.Zena))/((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
          StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))-1)*100
          :CZena:CLitrMantissa,ws1)
          Else ws1:='100.00';

          Str(StrToReal(Ws1){*100}:CZena:CMantissa,ws1);
           End
           Else
             Begin
              Str((-(Abs(StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))/
              ((StrToReal(E^.Dat.MarketElement[c].Input.Zena)))*100):CZena:CMantissa,Ws1);
             End;

          Str(StrToReal(E^.Dat.MarketElement[c].Input.Skidka):CZena:CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

          Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka))
         :CZena:CMantissa,wspomSkidka);

          S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      Else;
      End;{E^.Dat.SkidkaSelector}

  P^.List^.Insert(NewStr(s));
  P^.SetRange(P^.List^.Count);
 End;

 Case E^.Dat.SkidkaSelector Of
 0: ws:=' (Авто)';
 1: ws:=' (Ручная)';
 2: ws:=' (Шкала '+IntToStr(E^.Dat.ShkalaNumer,COne)+')';
 Else;
 End;

P^.FocusItem(0);
s:=E^.Dat.SummaZ;
DelSpace(s);
s:=' К оплате: '+s;
DelSpace(E^.Dat.Skidka);
s:=s+' Всего скидка'+ws+': '+E^.Dat.Skidka;
E^.Dat.ENalog:=RealToStr(StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka)-StrToReal(E^.Dat.ENalog),CIZena,CMantissa);
DelSpace(E^.Dat.ENalog);
s:=s+' Со склада:'+E^.Dat.ENalog;

SDoc:=E^.Dat.Document;
SDate:=E^.Dat.DateC;

Dispose(E,Done);

ProdagaWindow:=True;
NoInfo;
                   {Вставить номер и дату документа в просмотре}

FullScreen(P,' Код  Выбранн~ы~е товары           N Колич Цена лоб Цена опл  Скидка   Процент',s,
             { 12345│12345678901234567890123456│1│12345│12345678│12345│12345678│12345678}
SDoc,SDAte,0);

ProdagaWindow:=False;

Dispose(P,Done);
    End
Else
  Begin
  NoInfo;
  MessageBox(#3^M+#3'Документ не найден!',Nil,mfError+mfCancelButton);
  Dispose(E,Done);
  End;
End;
End;



Procedure CalcMenedger3(Const Client:PBox; Filtr,Oplata:Word;StartD,StopD:TDateString);
Const
      Arhipov=0; Ilishev=1;

Var f : File Of BarterClientType;
    R : TRect;
    E : PBarterClientType;
    s : string[150];
    l : Word;

    Delta,DateOpl,Date : TDAteString;
    NDS,z,AllSkidka,AllItogo,ItogoSkidka,Itogo : Real;
    AllZakupka,AllReturn,AllSkidkaReturn:Real;
    ws,ws2 : TMyString;
    txt1 : Text;
    Res,AllDoc : Word;
    DocS : Word;
    Slujba,Current,Cur,sh,VidSkidka,Vid : Word;

    ws1,Space : TMyString;
    AllReturnDoc,RAbday,Den,Start,Stop : LongInt;
    NoScreen : PBox;
    Key,Distant : Word;
    NameDoc,Names,Otgruz : AllStr;
    DateOtgr,DateOplata: TDateString;
    StartDate,StopDate : TDateString;
    Index :Word;
    FFF : Boolean;
    AgName,ClShk,Dohod,CurClientKod,tr,Doc,Cod,Ag:AllStr;
    Dolg : Real;
    EStraf,Straf: Real;
    mm : Maska9;
    ss : Maska2;
    Find,Add : Boolean;





Begin

 WordTobit9(Filtr,mm);
 Convert9(mm);

 WordToBit2(Oplata,ss);
 Convert2(ss);


 Start:=DateStringToDate(DateMask,StartD);
 Stop:=DateStringToDate(DateMask,StopD);

 Key:=0;
 Distant:=0;
 If Not(KeySorting1(Key,Distant)) Then
   Begin
    Exit;
   End;

If Distant=0 Then DistanationSorting:=True
Else DistanationSorting:=False;


 Space[0]:=#0;
 Assign(Txt1,Path.ToTemp+'cmengob1.txt');
 l:=IOResult;
 Rewrite(Txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path.ToTemp+'cmengob1.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

If Distant=0 Then DistanationSorting:=True
Else DistanationSorting:=False;


R.Assign(0,0,0,0);
NoScreen:= New(PBox, Init(R, 1, Nil));
NoScreen^.NewList(New(PTextCollection, Init(0,1)));


Writeln(txt1,Space+'Склад: '+FormKod(Rek.Kod)++'  Оператор: '+CurrentPassword);

Write(txt1,Space+'Включены документы отгрузки:');
For sh:=1 To Max9 Do
Case (Sh-1) Of
0:If mm[sh]=1 Then Write(txt1,' Список');
1:If mm[sh]=1 Then Write(txt1,' Тов.Ч*');
2:If mm[sh]=1 Then Write(txt1,' Физ.Л*');
3:If mm[sh]=1 Then Write(txt1,' СФ*');
4:If mm[sh]=1 Then Write(txt1,' СФБ');
5:If mm[sh]=1 Then Write(txt1,' Д*');
6:If mm[sh]=1 Then Write(txt1,' ДСФ*');
7:If mm[sh]=1 Then Write(txt1,' Д');
8:If mm[sh]=1 Then Write(txt1,' ДСФБ');
Else;
End;
Writeln(txt1);

Write(txt1,Space+'Включены документы со статусом:');
For sh:=1 To CMantissa Do
Case (Sh-1) Of
0:If ss[sh]=1 Then Write(txt1,' Оплаченные');
1:If ss[sh]=1 Then Write(txt1,' Не оплаченные');
Else;
End;
Writeln(txt1);

Write(txt1,Space+'Сортировка по:');
 Case Key Of
0{клиент}   :Write(txt1,'Клиенту');
1{дата отгр}:Write(txt1,'Дата отгрузки');
2{дата опл} :Write(txt1,'Сумма оплаты');
3{скидка}   :Write(txt1,'Сумма закупки');
4{оплата}   :Write(txt1,'Доход');
5{вид док}  :Write(txt1,'Шкала клиента');
Else;
End;

Case Distant Of
0{клиент}   :WriteLn(txt1,' По возрастанию');
1{дата отгр}:WriteLn(txt1,' По убыванию');
Else WriteLn(txt1);
End;

{
If (Client^.List^.Count)>=1 Then
Begin
 Writeln(txt1,'Выбранные клиенты:');
For Index:=0 To Client^.List^.Count-1 Do
Begin
s:=Client^.GetText(Index,Client^.List^.Count);
While Pos('│',s)>0 Do s[Pos('│',s)]:=' ';
Writeln(txt1,s);
End;
End;
}


Writeln(txt1);
Writeln(txt1,Space,'СПРАВКА ПО ОТГРУЗКАМ ПО ВЗАИМОЗАЧЕТАМ ЗА ПЕРИОД с '+Startd+' по '+Stopd+' (по выбр.клиентам)');
Writeln(txt1,Space+'------------------------------------------------------------------------------------');
Writeln(txt1,Space+' N  Клиент               Код  Док. Дата док  Сумма к оплате     Сумма по ЗЦ   %   Шк');
Writeln(txt1,Space+'------------------------------------------------------------------------------------');
                   {123 12345678901234567890 1234 1234 12345678 123456789012345 123456789012345 12345 12}
AllItogo:=0;
AllZakupka:=0;
AllSkidka:=0;
AllDoc:=0;
DInfoMsg('Обрабатываю запрос...');



New(E,Init);

If Client^.List^.Count>=1 Then
Begin
For Index:=0 To Client^.List^.Count-1 Do
Begin
CurClientKod:=Copy(Client^.GetText(Index,Client^.List^.Count),1+CCLient+1,CClientKod);

 Assign(F,Path.ToBarter+CurClientKod+'.brt');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
If l=0 Then
 Begin
  While Not (Eof(f)) Do
   Begin
      Read(f,E^.Dat);

If (E^.Dat.Active) And (E^.DAt.OperatorSelector=1) Then

    If (mm[E^.Dat.DocSelector+1]=1) Then


   If (DateStringToDate(DateMask,E^.Dat.DateC)<=Stop) And
      (DateStringToDate(DateMask,E^.Dat.DateC)>=Start) Then

       Begin

     Add:=False;

     If ss[1]=1 Then Add:=True;

    If Add Then
    Begin

        FFF:=ProdagaWindow;
        ProdagaWindow:=False;

        ws:=GetClientField(FClient,E^.Dat.ClientKod,2);
        Clshk:=GetClientField(FShkala,E^.Dat.ClientKod,2);
        Format(ws,CClient);

        DelSpace(E^.Dat.Document);
        RFormat(E^.Dat.Document,CDocNumer);
        DelSpace(E^.Dat.DateC);
        RFormat(E^.Dat.DateC,CDate);


        Str(StrToReal(E^.Dat.SummaZakupka):CIZena:CMAntissa,E^.Dat.SummaZakupka);
        Str(StrToReal(E^.Dat.SummaZ)-StrToReal(E^.Dat.ENalog):CIZena:CMAntissa,E^.Dat.SummaZ);

        If (StrToReal(E^.Dat.SummaZakupka)>0.009) Then
         Begin
           Str(
          (StrToReal(E^.Dat.SummaZ)-StrToReal(E^.Dat.SummaZakupka))/
           StrToReal(E^.Dat.SummaZakupka)*100:CLitr+1:CMAntissa,Dohod);
         End
        Else
          Dohod:='  0.00';


        AllItogo:=AllItogo+StrToreal(E^.Dat.SummaZ);
        Allzakupka:=AllZakupka+StrToreal(E^.Dat.SummaZakupka);
        AllSkidka:=AllSkidka+StrToreal(E^.Dat.Skidka);

        {
        DelSpace(E^.Dat.SummaZ);
        RFormat(E^.Dat.SummaZ,CIZena-4);
        DelSpace(E^.Dat.SummaZakupka);
        RFormat(E^.Dat.SummaZakupka,CIZena-4);
        }

        s[0]:=#0;
        s:=s+ws+' '+E^.Dat.ClientKod+' '+
	   +E^.Dat.Document+' '+E^.Dat.DAteC+' '+E^.DAt.SummaZ+' '+E^.Dat.SummaZakupka+' '+
	   Dohod+' '+ClShk;


        Case Key Of
        1{дата отгр}:Begin
                       tr:=IntToStr(
                       DateStringToDate(DateMask,E^.Dat.DateC),CKol+1);
	                  s:=tr+' '+s;
                     End;
        2{Сумма опл}:s:=E^.Dat.SummaZ+' '+s;
        3{Сумма зак}:Begin
	                 s:=E^.Dat.SummaZakupka+' '+s;
                     End;
        4{доход}  :s:=Dohod+' '+s;
        5{шкала клиентов}:s:=ClShk+' '+s;
        Else;
        End;


        NoScreen^.List^.Insert(NewStr(s));
        NoScreen^.SetRange(NoScreen^.List^.Count);
   End;{Add}
       End;{If}
   End;{While}
   Close(f);
 End;{If l=0}

 End;{For по клиентам}
End;{If SelectClient>0}


If NoScreen^.List^.Count>=1 Then
 Begin
  For Den:=0 To NoScreen^.List^.Count-1 Do
   Begin
     s:=NoScreen^.GetText(Den,NoScreen^.List^.Count);
        Case Key Of
        1{дата отгр}:Delete(s,1,CKol+1+1);
        2{сумма опл}:Delete(s,1,(CIZena-4)+1);
        3{сумма зак}:Delete(s,1,(CIZena-4)+1);
        4{доход}    :Delete(s,1,CLitr+1+1);
        5{шкала кли}:Delete(s,1,1+1);
        Else;
        End;

        ws:=IntToStr(dEN+1,3);
        RFormat(ws,CLitrMantissa);


     Writeln(txt1,Space+WS+' '+s);
   End;
 End;


Writeln(txt1,Space+'------------------------------------------------------------------------------------');


Writeln(Txt1,Space+
'                                                     Всего оплачено: ',RecognizReal(AllItogo,CIZena,CMantissa));
Writeln(Txt1,Space+
'                                                       Всего по З/Ц: ',RecognizReal(AllZakupka,CIZena,CMantissa));
If AllZakupka>0.009 Then
Begin
Writeln(Txt1,Space+
'                                                      Всего доход %: ',
RecognizReal((AllItogo-AllZakupka)/AllZakupka*100,CIZena,CMantissa));
End;

Writeln(Txt1,Space+
'                                                        Всего доход: ',RecognizReal(AllItogo-AllZakupka,CIZena,CMantissa));
Dispose(E,Done);
Dispose(NoScreen,Done);
DistanationSorting:=True;
Writeln(txt1);

Writeln(Txt1,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt1,Space+'====================================================================================');

Close(txt1);
NoInfoMsg;
ViewAsText(Path.ToTemp+'cmengob1.txt',True);
End;{CalcTch}




begin
FiltrDoc:=511;
FiltrOperation:=15;
End.
