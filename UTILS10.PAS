{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Utils10;

Interface

Uses Dialogs,Glob,CorMrk,ColorTxt,ServStr,Drivers,Utils4,
     Utils1,NetCall,WinDos,Dos,Net2,Net,PZakaz,
     Views,MyCalc,ViewMrk,LockInfo,FindPrh,TrNakl,Utilsss;


Type
  PFullScreenVzw = ^TFullScreenVzw;
  TFullScreenVzw = object(TDialog)
      Calc        : PMyCalculator;
      FP         : PFindPrh;
      Numer      : ArtikulStr;
      Date       : TDateString;
      DocOsn     : ArtikulStr;
      DateOsn    : TDateString;
      Vidano     : String[CIZena];
      VidVozwr   : Word;
      ViewMrk    : PFullScreenMrk;
      Function FullScreenVzw(Ass:DocumentEditZ):Boolean;
      Procedure DrawCurrent;
      Procedure Refresh;
      procedure HandleEvent(var Event: TEvent); virtual;
      Destructor Done;Virtual;
  end;


Type
  PFullScreenPredZakaz = ^TFullScreenPredZakaz;
  TFullScreenPredZakaz = object(TDialog)
      Calc       : PMyCalculator;
      FP         : PFindPrh;{просмотр прихода}
      FR         : PFindRezervWindow;{просмотр брони}
      lnk        : PLinkWindow;
      ViewMrk    : PFullScreenMrk;
      Exampl     : PPredZakazType;
      EditWin    : PSuperZakazWindow;
      Saved      : Boolean;
(*
      ClientKod  : String[CClientKod];
      AgentKod   : String[CClientKod];
      ClientNum  : String[CDocNumer];
      Date       : TDateString;{дата заказа у клиента}
      Numer      : ArtikulStr;{номер предзаказа}
      DateOtp    : TDateString;{дата отправки}
      DateC      : TDateString;{дата регистрации предзаказа}
      TimeC      : TDateString;{время регистрации предзаказа}
      DateM      : TDateString;{дата модификации предзаказа}
      TimeM      : TDateString;{время модификации предзаказа}
      DateConv   : TDateString;{дата преобразования в заказ}
      TimeConv   : TDateString;{время преобразования в заказ}

      DateConfirmation  : TDateString;{дата преобразования в заказ}
      TimeConfirmation  : TDateString;{время преобразования в заказ}

      DateEnd    : TDateString;{дата доставки}
      DocSelector,OperatorSelector : Word;
      SenConfirmation :Word;   {статус отправки подтверждения}
      Versia     : Word;       {версия в позиции товара}
      ZakazNumer : ArtikulStr;{номер заказа}
      Caption    : Word;{кто крайний}
      Status     : Word;{статус}
*)
      Otbor      : Word;{вид отбора}
      Procedure Refresh;
      Procedure DrawCurrent;
      Function FullScreenPredZakaz(Num:ArtikulStr):Boolean;
      procedure HandleEvent(var Event: TEvent); virtual;
      Destructor Done;Virtual;
  end;



Type
  PZenaWindow = ^TZenaWindow;
  TZenaWindow = object(TDialog)
      Calc        : PMyCalculator;
      Procedure  Start;
      Procedure Save(P:PBox);
      Procedure Refresh;
      Procedure DrawCurrent;
      procedure HandleEvent(var Event: TEvent); virtual;
      Destructor Done;Virtual;
  end;

Procedure ViewCorrect;
Procedure ViewVozwrat;
Procedure CorrectVeksel;


Procedure ExportNAkl(As:DocumentEditZ);
Procedure NetUnLock(Const DocList:PBox);

Procedure ReadRek(Var R:PRekwiziti;Regim:Word;Var Res : LongInt);
Procedure WriteRek(Var R:PRekwiziti;Regim:Word;Var Res : LongInt);
Function FindLastRegim(LinkArt:ArtikulStr;Ck:ArtikulStr;VAr ReturnZena:AllStr):Boolean;




Function PredZakazOformlenie(Var P:PPredZakazType):Boolean;
function InputComment(Var Comment1,Comment2:AllStr):Boolean;


implementation

Uses App,Objects,Serv,DbEngine,Utils,Utils3,Tools,Vision2,Vision3,netDbEng,
     Validate,ServStr2,Access,Mail,StHolder,MrkTool,
     dbEngin2,dbEngin3,TpDate,Printers,MsgBox,Protect,Utils5;

Var NoScreenList1 : PBox;
    ViewList : PBoxNew;
    ViewListS: PBoxNew;
    VzwWin : PFullScreenVzw;
    PzWin  : PFullScreenPredZakaz;
    Control,ControlG : PView;
    Filtr : Word;
    ControlClient,ControlAgent : PView;
    LArt : ArtikulStr;
    ControlInfo,ControlCount,ControlSelector,ControlVidOtboraG,ControlGroup,
    ControlOtbor,ControlPosition,ControlConfirmation,ControlComment1,
    ControlComment2,ControlDateOtpr,ControlStatus,ControlDateEnd,
    ControlDoc,ControlDateC,ControlDateM,ControlOperator,
    ControlSum, ControlOtd,
    ControlFiltr,ControlItog,ControlOtdel,ControlAmount,
    ControlVidOtbora : PView;
    VidOtbora,VidProsmotra,Otobragenie : Word;
    ControlHeader,ControlOtobragenie : PView;
    ControlNGTD,ControlKSertif,ControlVid,
    ControlMarka,ControlVirabotano,ControlDo,
    ControlNAme,ControlDocDate,ControlDocNum,
    ControlFullNAme,ControlMsg,ControlR,ControlRz,ControlText,ControlCl : PView;
    CurrentLine : String[220];
    VidSkidki : AllStr;
    ZWin : PZenaWindow;
    Otd,ReturnCount : Word;
    SelectNameList,NameList : PBox;
    OldFileMode,VidProd : Word;

    MMM2 : Maska2;
    MMM8 : Maska8;



function InputComment(Var Comment1,Comment2:AllStr):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control2,Control1 : PView;
  c : Word;

begin
R.Assign(30, 18, 79, 22);
New(Dlg, Init(R, 'Комментарий к заказу'));
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E002;

R.Assign(1, 1, 48, 2);
Control1 := New(PInputLine, Init(R, CAll));
Dlg^.Insert(Control1);

R.Assign(1, 2, 48, 3);
Control2 := New(PInputLine, Init(R, CAll));
Dlg^.Insert(Control2);

Dlg^.SelectNext(False);


Control1^.SetData(Comment1);
Control2^.SetData(Comment2);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Control1^.GetData(Comment1);
  Control2^.GetData(Comment2);
 End;

Dispose(Control1,Done);
Dispose(Control2,Done);
Dispose(Dlg,Done);

end;




{$IFDEF Pharm}

Function PredZakazOformlenie(Var P:PPredZakazType):Boolean;
Var jk,c,i : Word;
    a,b,ls : LongInt;
    PP : PPredZakazType;
    R : TRect;
    LockBox,TempBox,AllKolBox : PBox;
    s,s1 : String;
    Docs,DocumentNumer : AllStr;
    Z : PZakazType;
    Sklad : PSkladType;
    Kdx : PSkladTypeNew;
    SkladFile : SkladFileType;
    KdxFile : File Of SkladTypeNew;
    Event : TEvent;


Begin
  PredZakazOformlenie:=False;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;



{инициализируем новую переменную}
DocumentNumer[0]:=#0;
   If Not(UseDocNumer(DocZakaz,FDate,DocumentNumer)) Then
    Begin
     Exit;
    End;

New(Z,Init);{заказ}
Z^.Dat.Document:=DocumentNumer;
Z^.Dat.Status:=1;{схеме с DialUp}
Z^.Dat.PredZakazNumer:=StrToInt(P^.DAt.Document);
Z^.DAt.PredZakazDate:=P^.Dat.DateC;
Z^.Dat.PredZakazClient:=P^.Dat.ClientKod;
Z^.Dat.OperatorSelector :=P^.Dat.OperatorSelector;
Z^.Dat.DocSelector:=P^.Dat.DocSelector;
Z^.Dat.Versia :=1;
Z^.Dat.ShkalaNumer:=1;
Z^.Dat.SkidkaSelector:=1;
Z^.Dat.ClientKod :=P^.Dat.ClientKod;
Z^.Dat.AgentKod  :=P^.Dat.AgentKod;
Z^.Dat.EkspeditorKod :='0000';
Z^.Dat.Document :=DocumentNumer;
Z^.Dat.DocumentComment:=UseCommentNumer(P^.Dat.ClientKod,P^.Dat.OperatorSelector);
Z^.Dat.SkladKod  :=Rek^.Dat.Kod;
Z^.Dat.Caption :=CurrentPassword;{признак оператора}
Z^.Dat.Locked  :=True;{сетевая блокировка}
Z^.Dat.LockCaption := CurrentPassword;
Z^.Dat.LockTime := CurrentTime;
Z^.Dat.ComputerNameLocked :=NetComputerName;



Z^.Dat.Srok := DateStringToDate(DateMask,P^.Dat.DateEnd)+StrToInt(
GetClientField(FVIP,P^.Dat.ClientKod,P^.Dat.OperatorSelector));

If Z^.Dat.Srok<0 Then Z^.Dat.Srok:=DateStringToDate(DateMask,FDate)+1;



Z^.Dat.EndDate :=DateStringToDate(DateMask,P^.Dat.DateEnd)-DateStringToDate(DateMask,FDate);
If Z^.Dat.EndDate<0 Then Z^.Dat.EndDate:=0;

If P^.DAt.DocSelector in [4,8] Then
Z^.Dat.Rashet  :=1{0-нал/1-бн/2-вексель}
Else
Z^.Dat.Rashet  :=0;
Z^.Dat.Oformlenie :=0;{заказ не оформлен}
Z^.Dat.DateC :=FDAte;
Z^.Dat.TimeC :=Times;

  New(PP,Init);
  PP^.Dat:=P^.Dat;
  Docs:=P^.Dat.Document;
{блокируем заказ}
  i:=LockPredZakaz(Docs,PP);
  If I=2 Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать предзаказ N '+PP^.Dat.Document+'. Попробуйте повторить!',False);
    Dispose(PP,Done);
    Dispose(Z,Done);
    Application^.ClearEvent(Event);
    Application^.GetEvent(Event);
    Application^.ClearEvent(Event);
    repeat
     Application^.GetEvent(Event);
    until (Event.What <> evNothing) And (Event.Command<>cmMenu);
    NoInfoMsg;
    Application^.ClearEvent(Event);
    Exit;
   End;

   If I<>0 Then
    Begin
     Dispose(PP,Done);
     Dispose(Z,Done);
     exit;
    End;


  Dispose(PP,Done);
{Если нет выход}

{блокируем все позиции из заказа}
R.Assign(0,0,0,0);
LockBox := New(PBox, Init(R, 1, Nil));
LockBox^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

For i:=1 To P^.Dat.Amount Do
 Begin
  RFormatZerro(P^.Dat.Element[i].BazKod,CArtikul);
  P^.Dat.Element[i].!
  {код с меньшим кол-вом}
  s:='│'+P^.Dat.Element[i].BazKod;
  TempBox^.List^.Insert(NewStr('│'+P^.Dat.Element[i].BazKod));
  TempBox^.SetRange(TempBox^.List^.Count);
 End;


{если не удалось все заблокировать}
If Not(LockAllPosition(TempBox,LockBox)) Then
 Begin
  UnLockAllPosition(LockBox);
  Dispose(Z,Done);
  Dispose(LockBox,Done);
  Dispose(TempBox,Done);
  Repeat
  Until (UnLockPredZakaz(P^.Dat.Document) in [0,2]);
  Exit;
 End;


{начинаем}
{ищем позицию и блокирем ее}
{проверяем есть ли доступное количество
(
 Division[]-DivisionR[])>0
 a:=Division-DivisionR
 b:=P^.Dat.Element[c].Kol

 Fakt:=Min(a,b)

 далее DivisionR[]:=DivisionR[]+Fakt
 Fakt запоминаем в предзаказе
 запоняем поля в Z^.Dat.MarketElement
 подставляем цену и скидку в заказ

 пересчитываем Kol и KolR
 пересчитываем сумму предзаказа в оплате и закупке
 пересчитываем сумму заказа в оплате и закупке
 увеличиваем Amount у заказа

}

New(Sklad,Init);
New(Kdx,Init);
 c:=1;{индекс элемента заказа}

 For i:=1 To P^.DAt.Amount{J} Do
  Begin
   S1:=Copy(P^.Dat.Element[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path^.Dat.ToSklad+s1+'.db');
   jk:=IOResult;
   Reset(SkladFile);
   jk:=IOResult;
   If jk <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db! Код:'+IntToStr(jk,CKol),Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     UnLockAllPosition(LockBox);
     Dispose(Z,Done);
     Dispose(LockBox,Done);
     Dispose(TempBox,Done);
     Repeat
     Until (UnLockPredZakaz(P^.Dat.Document) in [0,2]);
     Exit;
    End;


   Assign(KdxFile,Path^.Dat.ToIndex+s1+'.kdx');
   jk:=IOResult;
   Reset(KdxFile);
   jk:=IOResult;
   If jk <> 0 Then
    Begin
     Close(SkladFile);
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.kdx! Код:'+IntToStr(jk,cKol),Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     UnLockAllPosition(LockBox);
     Dispose(Z,Done);
     Dispose(LockBox,Done);
     Dispose(TempBox,Done);
     Repeat
     Until (UnLockPredZakaz(P^.Dat.Document) in [0,2]);
     Exit;
    End;



     Ls:=GetFileLocation3(Copy(P^.Dat.Element[i].BazKod,CRazdelKod+1,CKod));
     Seek(SkladFile,Ls);
     Seek(KdxFile,Ls);
     {блокируем позицию предварительной блокировкой}
      Repeat
       Pause(1);
      Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
       Read(SkladFile,Sklad^.DAt);
       Read(KDXFile,Kdx^.DAt);

{
 Division[]-DivisionR[])>0
 a:=Division-DivisionR
 b:=P^.Dat.Element[c].Kol

 Fakt:=Min(a,b)

 далее DivisionR[]:=DivisionR[]+Fakt
 Fakt запоминаем в предзаказе
 запоняем поля в Z^.Dat.MarketElement
 подставляем цену и скидку в заказ

 пересчитываем Kol и KolR
 пересчитываем сумму предзаказа в оплате и закупке
 пересчитываем сумму заказа в оплате и закупке
 увеличиваем Amount у заказа
}

       {очищаем возможный мусор}
       P^.Dat.Element[i].Fakt:=0;
       {хоть какое то количество есть}
       If (StrToInt(Sklad^.Dat.Input.Division[P^.Dat.Element[i].DivisionNumber])-
          StrToInt(Sklad^.Dat.Input.DivisionR[P^.Dat.Element[i].DivisionNumber]))>0 Then
         Begin
          a:=StrToInt(Sklad^.Dat.Input.Division[P^.Dat.Element[i].DivisionNumber])-
          StrToInt(Sklad^.Dat.Input.DivisionR[P^.Dat.Element[i].DivisionNumber]);
          b:=StrToInt(P^.Dat.Element[i].Kol);

          If A<B Then P^.Dat.Element[i].Fakt:=A
          Else P^.Dat.Element[i].Fakt:=B;

          {дописываем бронь в *.db и *.kdx}
          Sklad^.Dat.Input.DivisionR[P^.Dat.Element[i].DivisionNumber]:=
		IntToStr(StrToInt(Sklad^.Dat.Input.DivisionR[P^.Dat.Element[i].DivisionNumber])+
		P^.Dat.Element[i].Fakt,CKol);

          Kdx^.Dat.DivisionR[P^.Dat.Element[i].DivisionNumber]:=
		StrToInt(Sklad^.Dat.Input.DivisionR[P^.Dat.Element[i].DivisionNumber]);

         End
          Else
           Begin
            P^.Dat.Element[i].Fakt:=0;
           End;

        If StrToInt(P^.Dat.Element[i].Kol)<P^.Dat.Element[i].Fakt Then Inc(P^.Dat.Defizit);

        {заполняем поля заказа и предзаказа модифицируем }
     If P^.Dat.Element[i].Fakt>0 Then
     Begin
        Z^.Dat.MarketElement[c].BazKod:=P^.Dat.Element[i].BazKod;
        {сохранили запись в заказе}
        With Z^.Dat.MarketElement[c].Input Do
        Begin
         Kol:=IntToStr(P^.Dat.Element[i].Fakt,CKol);
         MyStr(StrToReal(Sklad^.DAt.Input.R_Zena)-StrToReal(P^.Dat.Element[i].Zena),CZena,CMantissa,
	    Skidka);
         DelSpace(Skidka);
         Zena    := Sklad^.DAt.Input.R_Zena;
         Proz    := '0.00';
         InputDiviSion:=P^.Dat.Element[i].DivisionNumber;
         NSertif:=Sklad^.Dat.Input.NSertif;
         SertifKol:='0';
         Version:=1;
         MarkaKod:=Sklad^.Dat.Input.Marka;
         SMarkaKod:=Sklad^.Dat.Input.SpecMarka;
         NGTDKod:=Sklad^.Dat.Input.NGTD;
         ExpertKod:=Sklad^.Dat.Input.Expert;

         MyStr(StrToReal(Z^.Dat.Skidka)+StrToReal(Z^.Dat.MarketElement[c].Input.Skidka)*StrToInt(Kol),CIZena,CMantissa,
	    Z^.Dat.Skidka);

         MyStr(StrToReal(Z^.Dat.SummaZ)+
	    (StrToReal(Z^.Dat.MarketElement[c].Input.Zena)-StrToReal(Z^.Dat.MarketElement[c].Input.Skidka))*StrToInt(Kol),
	    CIZena,CMantissa,Z^.Dat.SummaZ);

         Srok:=0;
         DelSpace(Sklad^.Dat.Input.Godnost);
         If Sklad^.Dat.Input.Godnost[0]<>#0 Then Srok:=DateStringToDate(DateMask,Sklad^.Dat.Input.Godnost);
         Virabotano:=0;
         DelSpace(Sklad^.Dat.Input.Virabotano);
         If Sklad^.Dat.Input.Virabotano[0]<>#0 Then Virabotano:=DateStringToDate(DateMask,Sklad^.Dat.Input.Virabotano);
        End;

        {сохраняем брноь в складской базе}

        With Sklad^.Dat Do

         Begin
          Input.Kol[0]:=#0;

          Input.KolR[0]:=#0;
          For jk:=1 To CDivision Do
          Begin
          Str((StrToInt(Input.Division[jk])+StrToInt(Input.Kol)):CKol,Input.Kol);
          DelSpace(Input.Kol);

          Str((StrToInt(Input.DivisionR[jk])+StrToInt(Input.KolR)):CKol,Input.KolR);
          DelSpace(Input.KolR);
          End;
         End;

        With Kdx^.Dat Do
         Begin
          Kol:=0;
          Kol:=StrToInt(Sklad^.DAt.Input.Kol);
         End;

  {сохраняем изменения}
          Seek(SkladFile,FilePos(SkladFile)-1);
          Write(SkladFile,Sklad^.Dat);
          Seek(KdxFile,FilePos(KdxFile)-1);
          Write(KdxFile,Kdx^.Dat);
  {деблокируем позицию}

        Seek(SkladFile,FilePos(SkladFile)-1);

        Repeat
         UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
        Until (DosError=0);

        Inc(c);{увеличиваем счетчик позиций заказа}
      End;

   jk:=IOResult;
        Close(SkladFile);{закрытие файла}
   jk:=IOResult;
        Close(KdxFile);{закрытие файла}
   jk:=IOResult;
 End; {For по пред заказу}


Dispose(Sklad,Done);
Dispose(Kdx,Done);

Z^.Dat.AmountS:=0;
Z^.Dat.Amount:=c-1;{запоминаем количество позиций в заказе}

UnLockAllPosition(LockBox);
Dispose(LockBox,Done);
Dispose(TempBox,Done);


Glob.Status:=DocNormal;
LockAndWriteZakaz(Z);

Glob.Status:=DocNormal;

P^.Dat.ZakazNumer:=Z^.Dat.Document;
P^.Dat.Locked :=False;
P^.Dat.Caption := CurrentPassword;

SetPredZakazStatus(5,P,P^.Dat.Document,P^.Dat.ZakazNumer);

Repeat
Until (UnLockPredZakaz(P^.Dat.Document) in [0,2]);

{деблокируем вновь созданный документ}
Repeat
Until (UnLockZakaz(Z^.Dat.Document) in [0,2]);

Dispose(Z,Done);

PredZakazOformlenie:=True;

AddProtocol('Оформление предзаказа N '+P^.Dat.Document+' в заказ N '+P^.Dat.ZakazNumer,'','');

{копируем товары из  предзаказа в заказ и проводим одновременно
 заполнение поля факт в предзаказе}

end;


{$Else}


Function AddSertifKol(SArt:ArtikulStr;Otd:Word;Var SKol:AllStr):Boolean;
Var
    Sklad : PSkladType;
    Kdx : PSkladTypeNew;
    SkladFile : SkladFileType;
    KdxFile : File Of SkladTypeNew;
    s1 : AllStr;
    jk : Word;
    Ls : LongInt;
Begin
AddSertifKol:=False;

SKol[0]:=#0;
New(Sklad,Init);
New(Kdx,Init);

   s1:=Copy(SArt,1,CRazdelKod);
   Assign(SkladFile,Path^.Dat.ToSklad+s1+'.db');
   jk:=IOResult;
   Reset(SkladFile);
   jk:=IOResult;
   If jk <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db! Код:'+IntToStr(jk,CKol),Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;


   Assign(KdxFile,Path^.Dat.ToIndex+s1+'.kdx');
   jk:=IOResult;
   Reset(KdxFile);
   jk:=IOResult;
   If jk <> 0 Then
    Begin
     Close(SkladFile);
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.kdx! Код:'+IntToStr(jk,cKol),Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;

     Ls:=GetFileLocation3(Copy(SArt,CRazdelKod+1,CKod));
     Seek(SkladFile,Ls);
     Seek(KdxFile,Ls);
     {блокируем позицию предварительной блокировкой}
      Repeat
       Pause(1);
      Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

       Read(SkladFile,Sklad^.DAt);
       Read(KDXFile,Kdx^.DAt);

       If (StrToInt(Sklad^.Dat.Input.Division[Otd])-
          StrToInt(Sklad^.Dat.Input.DivisionR[Otd]))>0 Then
         Begin
          {дописываем бронь в *.db и *.kdx}

          {увеличиваем бронь по отделению}
          Str(StrToInt(Sklad^.Dat.Input.DivisionR[Otd])+1:CKol,Sklad^.Dat.Input.DivisionR[Otd]);
          DelSpace(Sklad^.Dat.Input.DivisionR[Otd]);

          {увеличиваем бронь по позиции}
          Str(StrToInt(Sklad^.Dat.Input.KolR)+1:CKol,Sklad^.Dat.Input.KolR);
          DelSpace(Sklad^.Dat.Input.KolR);

          {увеличиваем бронь по позиции в индексе}
          Kdx^.Dat.DivisionR[Otd]:=StrToInt(Sklad^.Dat.Input.DivisionR[Otd]);

  {сохраняем изменения}
          Seek(SkladFile,FilePos(SkladFile)-1);
          Write(SkladFile,Sklad^.Dat);
          Seek(KdxFile,FilePos(KdxFile)-1);
          Write(KdxFile,Kdx^.Dat);
  {деблокируем позицию}
          SKol:='1';
          AddSertifKol:=True;


         End
          Else
         Begin
          SKol[0]:=#0;
         End;


        Seek(SkladFile,FilePos(SkladFile)-1);

        Repeat
         UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
        Until (DosError=0);

  Dispose(Sklad,Done);
  Dispose(Kdx,Done);

   jk:=IOResult;
        Close(SkladFile);{закрытие файла}
   jk:=IOResult;
        Close(KdxFile);{закрытие файла}
   jk:=IOResult;

End;






Function PredZakazOformlenie(Var P:PPredZakazType):Boolean;
Var jk,c,i,sh,Position : Word;
    a,b,ls : LongInt;
    PP : PPredZakazType;
    R : TRect;
    LockBox,TempBox : PBox;
    s,s1 : String;
    Docs,DocumentNumer : AllStr;
    Z : PZakazType;
    L : PSuperMarketType;
    Sklad : PSkladType;
    SkladS : PSkladType;
    Kdx : PSkladTypeNew;
    KdxS : PSkladTypeNew;
    SkladFileS : SkladFileType;
    SkladFile : SkladFileType;
    KdxFileS : File Of SkladTypeNew;
    KdxFile : File Of SkladTypeNew;
    Event : TEvent;
    SFantomArtikul : AllStr;


Begin
  PredZakazOformlenie:=False;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

{инициализируем новую переменную}
DocumentNumer[0]:=#0;
   If Not(UseDocNumer(DocZakaz,FDate,DocumentNumer)) Then
    Begin
     Exit;
    End;

New(Z,Init);{заказ}
Z^.Dat.Document:=DocumentNumer;
Z^.Dat.Status:=1;{схеме с DialUp}
Z^.Dat.PredZakazNumer:=StrToInt(P^.DAt.Document);
Z^.DAt.PredZakazDate:=P^.Dat.DateC;
Z^.Dat.PredZakazClient:=P^.Dat.ClientKod;
Z^.Dat.OperatorSelector :=P^.Dat.OperatorSelector;
Z^.Dat.DocSelector:=P^.Dat.DocSelector;
Z^.Dat.Versia :=1;
Z^.Dat.ShkalaNumer:=1;
Z^.Dat.SkidkaSelector:=1;
Z^.Dat.ClientKod :=P^.Dat.ClientKod;
Z^.Dat.AgentKod  :=P^.Dat.AgentKod;
Z^.Dat.EkspeditorKod :='0000';
Z^.Dat.Document :=DocumentNumer;
Z^.Dat.DocumentComment:=UseCommentNumer(P^.Dat.ClientKod,P^.Dat.OperatorSelector);
Z^.Dat.SkladKod  :=Rek^.Dat.Kod;
Z^.Dat.Caption :=CurrentPassword;{признак оператора}
Z^.Dat.Locked  :=True;{сетевая блокировка}
Z^.Dat.LockCaption := CurrentPassword;
Z^.Dat.LockTime := CurrentTime;
Z^.Dat.ComputerNameLocked :=NetComputerName;
Z^.Dat.Comment1:=P^.Dat.Comment1;
Z^.Dat.Comment2:=P^.Dat.Comment2;
Z^.Dat.Amount:=0;
Z^.Dat.AmountS:=0;


{втавлен контроль статуса клиента}
New(l,Init);
ZakazToMarket(L,Z);
If Not TestClientStatus(False,L) Then
 Begin
    Dispose(Z,Done);
    Dispose(L,Done);
    NoInfoMsg;
    Exit;
 End;
Dispose(L,Done);
{конец контроля статуса клиента}


Z^.Dat.Srok := DateStringToDate(DateMask,P^.Dat.DateEnd)+P^.Dat.Rezerv;


If Z^.Dat.Srok<0 Then Z^.Dat.Srok:=DateStringToDate(DateMask,FDate)+1;

Z^.Dat.EndDate :=DateStringToDate(DateMask,P^.Dat.DateEnd)-DateStringToDate(DateMask,FDate);
If Z^.Dat.EndDate<0 Then Z^.Dat.EndDate:=0;

If P^.DAt.DocSelector in [4,8] Then
Z^.Dat.Rashet  :=1{0-нал/1-бн/2-вексель}
Else
Z^.Dat.Rashet  :=0;
Z^.Dat.Oformlenie :=0;{заказ не оформлен}
Z^.Dat.DateC :=FDAte;
Z^.Dat.TimeC :=Times;

  New(PP,Init);
  PP^.Dat:=P^.Dat;
  Docs:=P^.Dat.Document;
{блокируем заказ}
  i:=LockPredZakaz(Docs,PP);
  If I=2 Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать предзаказ N '+PP^.Dat.Document+'. Попробуйте повторить!',False);
    Dispose(PP,Done);
    Dispose(Z,Done);
    Application^.ClearEvent(Event);
    Application^.GetEvent(Event);
    Application^.ClearEvent(Event);
    repeat
     Application^.GetEvent(Event);
    until (Event.What <> evNothing) And (Event.Command<>cmMenu);
    NoInfoMsg;
    Application^.ClearEvent(Event);
    Exit;
   End;

   If I<>0 Then
    Begin
     Dispose(PP,Done);
     Dispose(Z,Done);
     exit;
    End;


  Dispose(PP,Done);
{Если нет выход}

{блокируем все позиции из заказа}
R.Assign(0,0,0,0);
LockBox := New(PBox, Init(R, 1, Nil));
LockBox^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

For i:=1 To P^.Dat.Amount Do
 Begin
  RFormatZerro(P^.Dat.Element[i].BazKod,CArtikul);

  {определение кода с меньшим кол-вом - нах!!!!}

(*  s:='│'+FindAllKol(P^.Dat.Element[i].BazKod,P,i);
  TempBox^.List^.Insert(NewStr('│'+FindAllKol(P^.Dat.Element[i].BazKod,P,i)));*)
  s:='│'+P^.Dat.Element[i].BazKod;
  TempBox^.List^.Insert(NewStr('│'+P^.Dat.Element[i].BazKod));

  TempBox^.SetRange(TempBox^.List^.Count);

  If P^.Dat.Element[i].NadoSertif=1 Then{обрабатываем сертификаты}
   Begin
    SFantomArtikul:=BakGetField(FNSertif,P^.Dat.Element[i].BazKod,1);
    RFormatZerro(SFantomArtikul,CArtikul);
    If SFantomArtikul<>NoSertifStr Then
     Begin
      If TestElement(SFantomArtikul,TempBox) Then
       Begin
        TempBox^.List^.Insert(NewStr('│'+SFantomArtikul));
        TempBox^.SetRange(TempBox^.List^.Count);
       End;
     End;
   End;

 End;


{если не удалось все заблокировать}
If Not(LockAllPosition(TempBox,LockBox)) Then
 Begin
  UnLockAllPosition(LockBox);
  Dispose(Z,Done);
  Dispose(LockBox,Done);
  Dispose(TempBox,Done);
  Repeat
  Until (UnLockPredZakaz(P^.Dat.Document) in [0,2]);
  Exit;
 End;


{начинаем}
{ищем позицию и блокирем ее}
{проверяем есть ли доступное количество
(
 Division[]-DivisionR[])>0
 a:=Division-DivisionR
 b:=P^.Dat.Element[c].Kol

 Fakt:=Min(a,b)

 далее DivisionR[]:=DivisionR[]+Fakt
 Fakt запоминаем в предзаказе
 запоняем поля в Z^.Dat.MarketElement
 подставляем цену и скидку в заказ

 пересчитываем Kol и KolR
 пересчитываем сумму предзаказа в оплате и закупке
 пересчитываем сумму заказа в оплате и закупке
 увеличиваем Amount у заказа

}

New(Sklad,Init);
New(Kdx,Init);
 c:=1;{индекс элемента заказа}
 sh:=0;{количество сертификатов}

 For i:=1 To P^.DAt.Amount{J} Do
  Begin
   S1:=Copy(P^.Dat.Element[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path^.Dat.ToSklad+s1+'.db');
   jk:=IOResult;
   Reset(SkladFile);
   jk:=IOResult;
   If jk <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db! Код:'+IntToStr(jk,CKol),Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     UnLockAllPosition(LockBox);
     Dispose(Z,Done);
     Dispose(LockBox,Done);
     Dispose(TempBox,Done);
     Repeat
     Until (UnLockPredZakaz(P^.Dat.Document) in [0,2]);
     Exit;
    End;


   Assign(KdxFile,Path^.Dat.ToIndex+s1+'.kdx');
   jk:=IOResult;
   Reset(KdxFile);
   jk:=IOResult;
   If jk <> 0 Then
    Begin
     Close(SkladFile);
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.kdx! Код:'+IntToStr(jk,cKol),Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     UnLockAllPosition(LockBox);
     Dispose(Z,Done);
     Dispose(LockBox,Done);
     Dispose(TempBox,Done);
     Repeat
     Until (UnLockPredZakaz(P^.Dat.Document) in [0,2]);
     Exit;
    End;

     Ls:=GetFileLocation3(Copy(P^.Dat.Element[i].BazKod,CRazdelKod+1,CKod));
     Seek(SkladFile,Ls);
     Seek(KdxFile,Ls);
     {блокируем позицию предварительной блокировкой}
      Repeat
       Pause(1);
      Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
       Read(SkladFile,Sklad^.DAt);
       Read(KDXFile,Kdx^.DAt);

{
 Division[]-DivisionR[])>0
 a:=Division-DivisionR
 b:=P^.Dat.Element[c].Kol

 Fakt:=Min(a,b)

 далее DivisionR[]:=DivisionR[]+Fakt
 Fakt запоминаем в предзаказе
 запоняем поля в Z^.Dat.MarketElement
 подставляем цену и скидку в заказ

 пересчитываем Kol и KolR
 пересчитываем сумму предзаказа в оплате и закупке
 пересчитываем сумму заказа в оплате и закупке
 увеличиваем Amount у заказа
}

       {очищаем возможный мусор}
       P^.Dat.Element[i].Fakt:=0;
       {хоть какое то количество есть}
       If (StrToInt(Sklad^.Dat.Input.Division[P^.Dat.Element[i].DivisionNumber])-
          StrToInt(Sklad^.Dat.Input.DivisionR[P^.Dat.Element[i].DivisionNumber]))>0 Then
         Begin
          a:=StrToInt(Sklad^.Dat.Input.Division[P^.Dat.Element[i].DivisionNumber])-
          StrToInt(Sklad^.Dat.Input.DivisionR[P^.Dat.Element[i].DivisionNumber]);
          b:=StrToInt(P^.Dat.Element[i].Kol);

          If A<B Then P^.Dat.Element[i].Fakt:=A
          Else P^.Dat.Element[i].Fakt:=B;

          {дописываем бронь в *.db и *.kdx}
          Sklad^.Dat.Input.DivisionR[P^.Dat.Element[i].DivisionNumber]:=
		IntToStr(StrToInt(Sklad^.Dat.Input.DivisionR[P^.Dat.Element[i].DivisionNumber])+
		P^.Dat.Element[i].Fakt,CKol);

          Kdx^.Dat.DivisionR[P^.Dat.Element[i].DivisionNumber]:=
		StrToInt(Sklad^.Dat.Input.DivisionR[P^.Dat.Element[i].DivisionNumber]);

         End
          Else
           Begin
            P^.Dat.Element[i].Fakt:=0;
           End;

        If StrToInt(P^.Dat.Element[i].Kol)<P^.Dat.Element[i].Fakt Then Inc(P^.Dat.Defizit);

        {заполняем поля заказа и предзаказа модифицируем }
     If P^.Dat.Element[i].Fakt>0 Then
     Begin
        Z^.Dat.MarketElement[c].BazKod:=P^.Dat.Element[i].BazKod;
        {сохранили запись в заказе}
        With Z^.Dat.MarketElement[c].Input Do
        Begin
         Kol:=IntToStr(P^.Dat.Element[i].Fakt,CKol);
         MyStr(StrToReal(Sklad^.DAt.Input.R_Zena)-StrToReal(P^.Dat.Element[i].Zena),CZena,CMantissa,
	    Skidka);
         DelSpace(Skidka);
         Zena    := Sklad^.DAt.Input.R_Zena;
         {
         Zakupka := Sklad^.DAt.Input.Zakupka;
         Zakupka2 := Sklad^.DAt.Input.Zakupka2;
         }
         Proz    := '0.00';
         InputDiviSion:=P^.Dat.Element[i].DivisionNumber;
         NSertif:=Sklad^.Dat.Input.NSertif;

         Version:=1;
         MarkaKod:=Sklad^.Dat.Input.Marka;
         SMarkaKod:=Sklad^.Dat.Input.SpecMarka;
         NGTDKod:=Sklad^.Dat.Input.NGTD;
         ExpertKod:=Sklad^.Dat.Input.Expert;

         MyStr(StrToReal(Z^.Dat.Skidka)+StrToReal(Z^.Dat.MarketElement[c].Input.Skidka)*
	    StrToInt(Kol),CIZena,CMantissa,Z^.Dat.Skidka);

         MyStr(StrToReal(Z^.Dat.SummaZ)+(StrToReal(Z^.Dat.MarketElement[c].Input.Zena)-
	    StrToReal(Z^.Dat.MarketElement[c].Input.Skidka))*StrToInt(Kol),CIZena,CMantissa,
	    Z^.Dat.SummaZ);

         Srok:=0;
         DelSpace(Sklad^.Dat.Input.Godnost);
         If Sklad^.Dat.Input.Godnost[0]<>#0 Then Srok:=DateStringToDate(DateMask,Sklad^.Dat.Input.Godnost);
         Virabotano:=0;
         DelSpace(Sklad^.Dat.Input.Virabotano);
         If Sklad^.Dat.Input.Virabotano[0]<>#0 Then Virabotano:=DateStringToDate(DateMask,Sklad^.Dat.Input.Virabotano);

         If P^.Dat.Element[i].NadoSertif=0 Then SertifKol:='0'
         Else
           Begin
           {SFantomArtikul:=BakGetField(FNSertif,P^.Dat.Element[i].BazKod,1);}
           SFantomArtikul:=Sklad^.Dat.Input.NSertif;
           RFormatZerro(SFantomArtikul,CArtikul);
           If Not TestElement(SFantomArtikul,LockBox) Then
            Begin

              SertifKol[0]:=#0;
             If AddSertifKol(SFantomArtikul,P^.Dat.Element[i].DivisionNumber,SertifKol) Then
              Begin
               Inc(Sh,1);
               Z^.Dat.DocumentElement[sh].BazKod:=SFantomArtikul;
               Z^.Dat.DocumentElement[sh].Input.Kol:=SertifKol;
               Z^.Dat.DocumentElement[sh].Input.Zena    :=BakGetField(FRZena,SFantomArtikul,1);
               {
               Z^.Dat.DocumentElement[sh].Input.Zakupka :=BakGetField(FZakupka,SFantomArtikul,1);
               Z^.Dat.DocumentElement[sh].Input.Zakupka2:=BakGetField(FZakupka2,SFantomArtikul,1);
               }
               Z^.Dat.DocumentElement[sh].Input.Skidka  :=Z^.Dat.DocumentElement[sh].Input.Zena;
               Z^.Dat.DocumentElement[sh].Input.Proz    :='0.00';
               Z^.Dat.DocumentElement[sh].Input.InputDiviSion:=P^.Dat.Element[i].DivisionNumber;
               Z^.Dat.DocumentElement[sh].Input.NSertif  :=NoSertifStr;
               Z^.Dat.DocumentElement[sh].Input.SertifKol:='0';
               Z^.Dat.DocumentElement[sh].Input.Version :=1;
               Z^.Dat.DocumentElement[sh].Input.MarkaKod :=NoMarkaStr;
               Z^.Dat.DocumentElement[sh].Input.SMarkaKod:=NoSpecMarkaStr;
               Z^.Dat.DocumentElement[sh].Input.NGTDKod  :=NoNGTDStr;
               Z^.Dat.DocumentElement[sh].Input.ExpertKod:=NoExpertStr;
               Z^.Dat.DocumentElement[sh].Input.Srok     :=0;
               Z^.Dat.DocumentElement[sh].Input.Virabotano:=0;

         MyStr(StrToReal(Z^.Dat.SertifSkidka)+StrToReal(Z^.Dat.DocumentElement[sh].Input.Skidka)*StrToInt(SertifKol),CIZena,
	    CMantissa,Z^.Dat.SertifSkidka);

         MyStr(StrToReal(Z^.Dat.SertifSummaZ)+(StrToReal(Z^.Dat.DocumentElement[sh].Input.Zena)-
	    StrToReal(Z^.Dat.DocumentElement[sh].Input.Skidka))*StrToInt(SertifKol),
	    CIZena,CMantissa,Z^.Dat.SertifSummaZ);
         {удаляем из списка}
         Position:=Location(LockBox,SFantomArtikul,False);
         If Position>=0 Then
         Begin
          LockBox^.List^.AtFree(Position);
          LockBox^.SetRange(LockBox^.List^.Count);
         End;
         {разбликируем позицию}
         Repeat
         Until SetNameUnLock(SFantomArtikul);
           {проверяем есть ли сертификат в списке
		 код для проверки остатка по сертификатам и
		 и записи брони на склад
		 если все ок то записываем в количество единицу и
		 удаляем код сертификата из списка увеличиваем счетчик сертификатов на 1
		 и заполняем поля DocumentElement[sh]}
              End{AddSertifKol}
              Else
                SertifKol:='0';
            End
            Else
             SertifKol:='0';
           End;
        End;

        {сохраняем бронь в складской базе}

        With Sklad^.Dat Do

         Begin
          Input.Kol[0]:=#0;

          Input.KolR[0]:=#0;
          For jk:=1 To CDivision Do
          Begin
          Str((StrToInt(Input.Division[jk])+StrToInt(Input.Kol)):CKol,Input.Kol);
          DelSpace(Input.Kol);

          Str((StrToInt(Input.DivisionR[jk])+StrToInt(Input.KolR)):CKol,Input.KolR);
          DelSpace(Input.KolR);
          End;
         End;

        With Kdx^.Dat Do
         Begin
          Kol:=0;
          Kol:=StrToInt(Sklad^.DAt.Input.Kol);
         End;

  {сохраняем изменения}
          Seek(SkladFile,FilePos(SkladFile)-1);
          Write(SkladFile,Sklad^.Dat);
          Seek(KdxFile,FilePos(KdxFile)-1);
          Write(KdxFile,Kdx^.Dat);
  {деблокируем позицию}

        Seek(SkladFile,FilePos(SkladFile)-1);

        Repeat
         UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
        Until (DosError=0);

        Inc(c);{увеличиваем счетчик позиций заказа}
      End;

   jk:=IOResult;
        Close(SkladFile);{закрытие файла}
   jk:=IOResult;
        Close(KdxFile);{закрытие файла}
   jk:=IOResult;
 End; {For по пред заказу}


Dispose(Sklad,Done);
Dispose(Kdx,Done);

Z^.Dat.AmountS:=sh;
Z^.Dat.Amount:=c-1;{запоминаем количество позиций в заказе}

UnLockAllPosition(LockBox);
Dispose(LockBox,Done);
Dispose(TempBox,Done);


Glob.Status:=DocNormal;
LockAndWriteZakaz(Z);

Glob.Status:=DocNormal;

P^.Dat.ZakazNumer:=Z^.Dat.Document;
P^.Dat.Locked :=False;
P^.Dat.Caption := CurrentPassword;

SetPredZakazStatus(5,P,P^.Dat.Document,P^.Dat.ZakazNumer);

Repeat
Until (UnLockPredZakaz(P^.Dat.Document) in [0,2]);

{деблокируем вновь созданный документ}
Repeat
Until (UnLockZakaz(Z^.Dat.Document) in [0,2]);

Dispose(Z,Done);

PredZakazOformlenie:=True;

AddProtocol('Оформление предзаказа N '+P^.Dat.Document+' в заказ N '+P^.Dat.ZakazNumer,'','');

{копируем товары из  предзаказа в заказ и проводим одновременно
 заполнение поля факт в предзаказе}

end;







{$EndIF}



Function TFullScreenVzw.FullScreenVzw(Ass:DocumentEditZ):Boolean;
var
  R : TRect;
  ws,s,s1,St,s2 : String;
  AgName,ClName : AllStr;
  c,i : Word;
  ff,ff1,ff2 : String;
  E :PNewVozwratType;
  Find:Boolean;
  SDate : TDateString;
  ws1,WspomSkidka:String[CIZena];
  WithOutZena : AllStr;
  Res : Word;
  DDD3,DDD4,DDD,DDD2,Status : AllStr;
  Color : Word;
  AssZ:DocumentEditZ;
  BArter : AllStr;
  add : Boolean;
begin
  FullScreenVzw:=False;
  Find := False;
  DInfoMsg('Ищу документ...',True);
  New(E,Init);
  ClearChar(Ass.EditPosition);
  DelSpace(Ass.D);
  Find:=GetReturnDoc(Ass,E);
  NoInfoMsg;

If Not Find Then
  Begin
   Dispose(E,Done);
   NoInfoMsg;
   Exit;
  End;

DInfoMsg('Формирую документы...',True);
ClearFind;

R.Assign(0, 0, 80, 23);
New(VzwWin, Init(R, 'Просмотр возврата'));
VzwWin^.HelpCtx:={E091}{E556}$F962{F222};

VzwWin^.Numer:=Ass.EditPosition;
VzwWin^.Date:=Ass.D;
VzwWin^.DocOsn:=E^.Dat.BasisDoc;
VzwWin^.DateOsn:=E^.Dat.BasisDate;
VzwWin^.Vidano[0]:=#0;
If E^.DAt.Rashod Then
VzwWin^.Vidano:=E^.DAt.RashodSumma;
VzwWin^.VidVozwr:=E^.Dat.VidDocument;

R.Assign(79, 4, 80, 21);
Control := New(PScrollBar, Init(R));
VzwWin^.Insert(Control);

R.Assign(75, 22, 78, 23);
ControlG := New(PScrollBar, Init(R));
ControlG^.Options := ControlG^.Options or ofPostProcess;
VzwWin^.Insert(ControlG);


R.Assign(1, 4, 79, 21);
ViewList := New(PBoxNew, Init(R, 1,
PScrollBar(ControlG), PScrollBar(Control)));
ViewList^.NewList(New(PTextCollection, Init(0,1)));


Otd:=255;
WordToBit8(Otd,MMM8);
Convert8(MMM8);

E^.Dat.SummaR[0]:=#0;{сюда пишем сумму по ценам к оплате}
E^.Dat.SummaZakupka[0]:=#0;
E^.Dat.SummaO[0]:=#0;{сюда пишем сумму по базовым ценам}

For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.VozwratElement[c].BazKod;
  ws:=GetIdField(FFFName,s);
  Format(ws,CName+1+CName);
  s:=ws+'│'+s;

  MyStr(StrToReal(E^.Dat.VozwratElement[c].Input.Zena),CZena,CMantissa,E^.Dat.VozwratElement[c].Input.Zena);
  MyStr(StrToReal(E^.Dat.VozwratElement[c].Input.R_Zena),CZena,CMantissa,E^.Dat.VozwratElement[c].Input.R_Zena);

Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(E^.Dat.VozwratElement[c].Input.Zena)/
           (1+StrToReal(E^.Dat.VozwratElement[c].Input.LocalProz)/100),CZena,CMantissa,E^.Dat.VozwratElement[c].Input.Zena);
        MyStr(StrToREal(E^.Dat.VozwratElement[c].Input.Zena),CZena,CMantissa,
                         WithOutZena);
       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(E^.Dat.VozwratElement[c].Input.Zena)-
                    StrToReal(E^.Dat.VozwratElement[c].Input.LocalSkidka),CZena,CMantissa,
                    E^.Dat.VozwratElement[c].Input.Zena);
          MyStr(StrToREal(E^.Dat.VozwratElement[c].Input.Zena),CZena,CMantissa,
                    WithOutZena);
        End;
Else;
End;{Case}

  E^.Dat.VozwratElement[c].Input.Zena:=WithOutZena;

  If Not(EnableZakupka=1)  Then
  E^.Dat.VozwratElement[c].Input.Zakupka:=CodeZakupka
  Else
  MyStr(StrToReal(E^.Dat.VozwratElement[c].Input.Zakupka),CZenaZ,CMantissaZ,E^.Dat.VozwratElement[c].Input.Zakupka);

  If MMM8[StrToInt(E^.Dat.VozwratElement[c].Input.Division)]=0
  Then E^.Dat.VozwratElement[c].Input.Kol[0]:=#0;

  Add:=False;

  If StrToInt(E^.Dat.VozwratElement[c].Input.Kol)>0 Then Add:=True;

(*
  For i:=1 To CDivision Do
   Begin

    If MMM8[i]=0 Then E^.Dat.VozwratElement[c].Input.Division[i,0]:=#0;

    If MMM2[1]=0 Then
    If StrToInt(E^.Dat.Element[c].Input.Division[i])>0 Then E^.Dat.Element[c].Input.Division[i,0]:=#0;

    If MMM2[2]=0 Then
    If StrToInt(E^.Dat.Element[c].Input.Division[i])<0 Then E^.Dat.Element[c].Input.Division[i,0]:=#0;

    E^.Dat.Element[c].Input.Division[i]:=IntToStr(StrToInt(E^.Dat.Element[c].Input.Division[i]),CKol+1);
    RFormat(E^.Dat.Element[c].Input.Division[i],CKol+1);

    E^.Dat.Element[c].Input.Kol:=IntToStr(
    StrToInt(E^.Dat.Element[c].Input.Kol)+
    StrToInt(E^.Dat.Element[c].Input.Division[i]),CKol+1);

    If StrToInt(E^.Dat.Element[c].Input.Division[i])<>0 Then Add:=True;
   End;{For i}
*)

  If Add Then{т.е есть не нулевая позиция}
Begin
  E^.Dat.VozwratElement[c].Input.Kol:=IntToStr(StrToInt(E^.Dat.VozwratElement[c].Input.Kol),CKOl);
  E^.Dat.VozwratElement[c].Input.Division:=IntToStr(StrToInt(E^.Dat.VozwratElement[c].Input.Division),COne);
  RFormat(E^.Dat.VozwratElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.VozwratElement[c].Input.Division+'│'+E^.Dat.VozwratElement[c].Input.Kol+'│'+
  E^.Dat.VozwratElement[c].Input.Zena+'│'+
  E^.Dat.VozwratElement[c].Input.Zakupka+'│'+E^.Dat.VozwratElement[c].Input.R_Zena+'│';


  MyStr(StrToReal(E^.Dat.SummaR)+
  StrToInt(E^.Dat.VozwratElement[c].Input.Kol)*
  StrToReal(E^.Dat.VozwratElement[c].Input.Zena),CIZena,CMAntissa,E^.Dat.SummaR);
  DelSpace(E^.DAt.SummaR);

  MyStr(StrToReal(E^.Dat.SummaO)+
  StrToInt(E^.Dat.VozwratElement[c].Input.Kol)*
  StrToReal(E^.Dat.VozwratElement[c].Input.R_Zena),CIZena,CMAntissa,E^.Dat.SummaO);
  DelSpace(E^.DAt.SummaO);

  MyStr(StrToReal(E^.Dat.SummaZakupka)+
  StrToInt(E^.Dat.VozwratElement[c].Input.Kol)*
  StrToReal(E^.Dat.VozwratElement[c].Input.Zakupka),CIZena,CMAntissaZ,E^.Dat.SummaZakupka);
  DelSpace(E^.DAt.SummaZakupka);

  ViewList^.List^.Insert(NewStr(s));
  ViewList^.SetRange(ViewList^.List^.Count);
End;

 End;



ViewList^.FocusItem(0);

VzwWin^.Insert(ViewList);

  R.Assign(1, 3, 78, 4);
  VzwWin^.Insert(New(PLabel,
  Init(R,'Наименование товара                                    Код  О Колич Цена Опл', ViewList)));


R.Assign(1, 0, 27, 1);
Control := New(PColoredText, Init(R, 'Документ:'+E^.Dat.Document+' от '+E^.Dat.DateC, $4E));
VzwWin^.Insert(Control);

R.Assign(61, 0, 79, 1);
ControlAmount := New(PColoredText, Init(R, 'Позиций:'+IntToStr(ViewList^.List^.Count,CMAntissa)+' из '+
IntToStr(E^.Dat.Amount,CMantissa), $4E));
VzwWin^.Insert(ControlAmount);

MyStr(StrToReal(E^.DAt.SummaR),CIZena,CMAntissa,E^.DAt.SummaR);
DelSpace(E^.DAt.SummaR);
MyStr(StrToReal(E^.DAt.SummaZakupka),CIZena,CMAntissaZ,E^.DAt.SummaZakupka);
DelSpace(E^.DAt.SummaZakupka);

If Not(EnableZakupka=1) Then
  E^.Dat.SummaZakupka:=CodeSummaZ;

s:=#3+'Всего по ЦО:'+E^.DAt.SummaR+'  РЦ:'+E^.DAt.SummaO+
     '   ЗЦ:'+E^.DAt.SummaZakupka;

R.Assign(2, 22, 2+Length(s)+1, 23);
ControlItog := New(PColoredText, Init(R, s, $4E));
ControlItog^.Options := ControlItog^.Options or ofCenterX;
VzwWin^.Insert(ControlItog);

R.Assign(61, 2, 79, 3);
Control := New(PColoredText, Init(R, #3+GetOperatorField(FName,E^.Dat.Caption)+'('+E^.Dat.Caption+')', $4E));
VzwWin^.Insert(Control);

R.Assign(1, 2, 57, 3);
ControlOtd := New(PCheckboxes, Init(R,
  NewSItem('~1~',
  NewSItem('~2~',
  NewSItem('~3~',
  NewSItem('~4~',
  NewSItem('~5~',
  NewSItem('~6~',
  NewSItem('~7~',
  NewSItem('~8~', Nil))))))))));
VzwWin^.Insert(ControlOtd);
ControlOtd^.SetData(Otd);

R.Assign(31, 21, 38, 22);
Control := New(PColoredText, Init(R, 'Статус:', $74));
VzwWin^.Insert(Control);

R.Assign(36, 1, 46, 2);
Control := New(PColoredText, Init(R, 'Основание:', $71));
VzwWin^.Insert(Control);

R.Assign(38, 21, 79, 22);
s[0]:=#0;
Case E^.Dat.VidDocument Of
0:s:='Наличная продажа скидка автоматическая';
1:s:='Наличная продажа скидка ручная';
2:s:='Закрытая консигнация автоматическая';
3:s:='Закрытая консигнация ручная';
4:s:='Открытая консигнация автоматическая';
5:s:='Открытая консигнация ручная';
Else s:='???';
End;

Control := New(PColoredText, Init(R, s, $7E));
VzwWin^.Insert(Control);

R.Assign(1, 21, 17, 22);
Control := New(PColoredText, Init(R, 'Скидка возврата:', $74));
VzwWin^.Insert(Control);

R.Assign(17, 21, 25, 22);
ControlOtdel := New(PColoredText, Init(R, #3+'', $7E));
VzwWin^.Insert(ControlOtdel);

R.Assign(46, 1, 61, 2);
Control := New(PColoredText, Init(R, E^.Dat.BasisDoc+' от '+E^.Dat.BasisDate, $7E));
VzwWin^.Insert(Control);

R.Assign(8, 1, 35, 2);
s:=GetClientField(FClient,E^.Dat.MakeKod,0);
Format(s,CClient);
RFormatZerro(E^.Dat.MakeKod,CClientKod);
Control := New(PColoredText, Init(R, ' '+s+'│'+E^.Dat.MakeKod, $1F));
VzwWin^.Insert(Control);

R.Assign(1, 1, 8, 2);
Control := New(PStaticText, Init(R, 'Клиент:'));
VzwWin^.Insert(Control);

If E^.Dat.Rashod Then
Begin
MyStr(StrToReal(E^.Dat.RashodSumma),CIZena,CMantissa,E^.Dat.RashodSumma);
DelSpace(E^.Dat.RashodSumma);
R.Assign(62, 1, 79, 2);
Control := New(PColoredText, Init(R, 'Выдано:'+E^.Dat.RashodSumma, $5F));
VzwWin^.Insert(Control);
End;

Dispose(E,Done);

NoInfoMsg;
CurrentLine[0]:=#0;
DrawCurrent;
VzwWin^.SelectNext(False);
i := Desktop^.ExecView(VzwWin);

Dispose(Control,Done);
Dispose(ControlG,Done);
Dispose(ControlItog,Done);
Dispose(ControlOtd,Done);
Dispose(ControlAmount,Done);
Dispose(ControlOtdel,Done);
Dispose(ViewList,Done);
Dispose(VzwWin,Done);

end;




procedure TFullScreenVzw.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var s : String;
    Prom : Word;
    Assistent : DocumentEditZ;
    Sn : ArtikulStr;
Begin

Case Event.What Of
 evCommand :
   Case Event.Command Of
  cmLocalCalc:Calculator;

cmViewPrihodTovar
     :Begin
if (ViewList^.State and sfFocused <> 0) And(ViewList^.List<>Nil) And (ViewList^.List^.Count>=1)Then
      If (ViewList^.List^.Count-1)>=0 Then
       begin
        Sn:=Copy(ViewList^.GEtTExt(ViewList^.Focused,ViewList^.List^.Count),1+CName+1+CName+1,CArtikul);
        FP^.FindScreenPrh(SN);
        ClearEvent(Event);
       End;
      End;

  cmFullView:Begin
              ClearFind;

  Assistent.EditPosition:=VzwWin^.DocOsn;
  Assistent.D:=VzwWin^.DateOsn;
  ClearChar(Assistent.EditPosition);
  DelSpace(Assistent.D);
  ViewMrk^.FullScreenMrk(Assistent,False);
            End;

  cmPrintReestr:    Begin
                ClearFind;
                Assistent.EditPosition:=Numer;
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Date;
                DelSpace(Assistent.D);
                NewPrintVozwrat(Assistent);
                    End;
        Else;
        End;
 Else;
 End;

  If (Desktop^.Current=PView(VzwWin)) And (Event.What <> EvKeyDown) Then
   Begin

          if (ControlOtd^.State and sfFocused <> 0)Then
              Begin
               ControlOtd^.GetData(Prom);
               If Prom <> Otd Then
               Begin
                  Otd:=Prom;
                  Refresh;
                  Redraw;
               End;
              End;

    DrawCurrent;


   End;


inherited HandleEvent(Event);
End;


Destructor TFullScreenVzw.Done;
Begin
TDialog.Done;
End;


Procedure TFullScreenVzw.DrawCurrent;
Var st,s,s2 : String;
    R : TRect;
    c : Word;
Begin
if (ViewList^.List<>Nil)And(ViewList^.List^.Count>=1) Then
 Begin
  st:=ViewList^.GetText(ViewList^.Focused,ViewList^.List^.Count);

  If st <> CurrentLine Then
    Begin
      CurrentLine:=St;
      Dispose(ControlOtdel,Done);
      s2[0]:=#0;
      R.Assign(17, 21, 25, 22);

       s:=Copy(st,1+CNAme+1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZenaZ+1,CZena);
       st:=Copy(st,1+CNAme+1+CNAme+1+CArtikul+1+COne+1+CKol+1,CZena);
       MyStr(StrToReal(s)-StrToReal(st),CZena,CMantissa,s2);
       DelSpace(s2);
      ControlOtdel := New(PColoredText, Init(R, #3+s2, $71));
      VzwWin^.Insert(ControlOtdel);

    End;

 End
End;


Procedure TFullScreenVzw.Refresh;
Var e : PNewVozwratType;
    Ass : DocumentEditZ;
    Add,Find : Boolean;
    s,ws : String;
    WithOutZena : AllStr;
    i,c : Word;
    R : TRect;
Begin

  DInfoMsg('Минуточку...',False);
  New(E,Init);
  Ass.EditPosition:=VzwWin^.Numer;
  Ass.D:=VzwWin^.Date;
  ClearChar(Ass.EditPosition);
  DelSpace(Ass.D);
  Find:=GetReturnDoc(Ass,E);

If Not Find Then
  Begin
   Dispose(E,Done);
   NoInfoMsg;
   Exit;
  End;

ViewList^.NewList(Nil);
ViewList^.NewList(New(PTextCollection, Init(0,1)));

WordToBit8(Otd,MMM8);
Convert8(MMM8);

E^.Dat.SummaR[0]:=#0;{сюда пишем сумму по ценам к оплате}
E^.Dat.SummaZakupka[0]:=#0;
E^.Dat.SummaO[0]:=#0;{сюда пишем сумму по базовым ценам}

For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.VozwratElement[c].BazKod;
  ws:=GetIdField(FFFName,s);
  Format(ws,CName+1+CName);
  s:=ws+'│'+s;

  MyStr(StrToReal(E^.Dat.VozwratElement[c].Input.Zena),CZena,CMantissa,E^.Dat.VozwratElement[c].Input.Zena);
  MyStr(StrToReal(E^.Dat.VozwratElement[c].Input.R_Zena),CZena,CMantissa,E^.Dat.VozwratElement[c].Input.R_Zena);

Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(E^.Dat.VozwratElement[c].Input.Zena)/
           (1+StrToReal(E^.Dat.VozwratElement[c].Input.LocalProz)/100),CZena,CMantissa,E^.Dat.VozwratElement[c].Input.Zena);
        MyStr(StrToREal(E^.Dat.VozwratElement[c].Input.Zena),CZena,CMantissa,
                         WithOutZena);
       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(E^.Dat.VozwratElement[c].Input.Zena)-
                    StrToReal(E^.Dat.VozwratElement[c].Input.LocalSkidka),CZena,CMantissa,
                    E^.Dat.VozwratElement[c].Input.Zena);
          MyStr(StrToREal(E^.Dat.VozwratElement[c].Input.Zena),CZena,CMantissa,
                    WithOutZena);
        End;
Else;
End;{Case}

  E^.Dat.VozwratElement[c].Input.Zena:=WithOutZena;

  If Not(EnableZakupka=1)  Then
  E^.Dat.VozwratElement[c].Input.Zakupka:=CodeZakupka
  Else
  MyStr(StrToReal(E^.Dat.VozwratElement[c].Input.Zakupka),CZenaZ,CMantissaZ,E^.Dat.VozwratElement[c].Input.Zakupka);

  If MMM8[StrToInt(E^.Dat.VozwratElement[c].Input.Division)]=0
  Then E^.Dat.VozwratElement[c].Input.Kol[0]:=#0;

  Add:=False;

  If StrToInt(E^.Dat.VozwratElement[c].Input.Kol)>0 Then Add:=True;

(*
  For i:=1 To CDivision Do
   Begin

    If MMM8[i]=0 Then E^.Dat.VozwratElement[c].Input.Division[i,0]:=#0;

    If MMM2[1]=0 Then
    If StrToInt(E^.Dat.Element[c].Input.Division[i])>0 Then E^.Dat.Element[c].Input.Division[i,0]:=#0;

    If MMM2[2]=0 Then
    If StrToInt(E^.Dat.Element[c].Input.Division[i])<0 Then E^.Dat.Element[c].Input.Division[i,0]:=#0;

    E^.Dat.Element[c].Input.Division[i]:=IntToStr(StrToInt(E^.Dat.Element[c].Input.Division[i]),CKol+1);
    RFormat(E^.Dat.Element[c].Input.Division[i],CKol+1);

    E^.Dat.Element[c].Input.Kol:=IntToStr(
    StrToInt(E^.Dat.Element[c].Input.Kol)+
    StrToInt(E^.Dat.Element[c].Input.Division[i]),CKol+1);

    If StrToInt(E^.Dat.Element[c].Input.Division[i])<>0 Then Add:=True;
   End;{For i}
*)

  If Add Then{т.е есть не нулевая позиция}
Begin
  E^.Dat.VozwratElement[c].Input.Kol:=IntToStr(StrToInt(E^.Dat.VozwratElement[c].Input.Kol),CKOl);
  RFormat(E^.Dat.VozwratElement[c].Input.Kol,CKol);
  E^.Dat.VozwratElement[c].Input.Division:=IntToStr(StrToInt(E^.Dat.VozwratElement[c].Input.Division),COne);
  s:=s+'│'+E^.Dat.VozwratElement[c].Input.Division+'│'+
           E^.Dat.VozwratElement[c].Input.Kol+'│'+
		 E^.Dat.VozwratElement[c].Input.Zena+'│'+
           E^.Dat.VozwratElement[c].Input.Zakupka+'│'+
		 E^.Dat.VozwratElement[c].Input.R_Zena+'│';


  MyStr(StrToReal(E^.Dat.SummaR)+
  StrToInt(E^.Dat.VozwratElement[c].Input.Kol)*
  StrToReal(E^.Dat.VozwratElement[c].Input.Zena),CIZena,CMAntissa,E^.Dat.SummaR);
  DelSpace(E^.DAt.SummaR);

  MyStr(StrToReal(E^.Dat.SummaO)+
  StrToInt(E^.Dat.VozwratElement[c].Input.Kol)*
  StrToReal(E^.Dat.VozwratElement[c].Input.R_Zena),CIZena,CMAntissa,E^.Dat.SummaO);
  DelSpace(E^.DAt.SummaO);

  MyStr(StrToReal(E^.Dat.SummaZakupka)+
  StrToInt(E^.Dat.VozwratElement[c].Input.Kol)*
  StrToReal(E^.Dat.VozwratElement[c].Input.Zakupka),CIZena,CMAntissaZ,E^.Dat.SummaZakupka);
  DelSpace(E^.DAt.SummaZakupka);

  ViewList^.List^.Insert(NewStr(s));
  ViewList^.SetRange(ViewList^.List^.Count);
End;

 End;


ViewList^.FocusItem(0);

Dispose(ControlAmount,Done);
R.Assign(61, 0, 79, 1);
ControlAmount := New(PColoredText, Init(R, 'Позиций:'+IntToStr(ViewList^.List^.Count,CMAntissa)+' из '+
IntToStr(E^.Dat.Amount,CMantissa), $4E));
VzwWin^.Insert(ControlAmount);

If Not(EnableZakupka=1) Then
  E^.Dat.SummaZakupka:=CodeSummaZ;

Dispose(ControlItog,Done);
s:=#3+'Всего по ЦО:'+E^.DAt.SummaR+'  РЦ:'+E^.DAt.SummaO+
     '   ЗЦ:'+E^.DAt.SummaZakupka;
R.Assign(2, 22, 2+Length(s)+1, 23);
ControlItog := New(PColoredText, Init(R, s, $4E));
ControlItog^.Options := ControlItog^.Options or ofCenterX;
VzwWin^.Insert(ControlItog);

Redraw;

Dispose(E,Done);
NoInfoMsg;
CurrentLine[0]:=#0;

End;


Procedure TZenaWindow.Save(P:PBox);
Var f : Text;
    c,Res : Word;
    sComment,s : String;
Begin
Assign (f,Path^.DAt.ToOperator+'range');
Res := IOResult;
Rewrite(f);
Res := IOResult;
If Res <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка записи файла ценовых ограничений!',Nil,mfError+mfCancelButton);
  Exit;
 End;

If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
  For c:=0 To P^.List^.Count-1 Do
  Begin
   s := P^.GetText(c,P^.List^.Count);
   sComment:=Copy(s,1,CName+CName);
   System.Delete(s,1,CName+1+CName);
   Writeln(f,';'+SComment);
   Writeln(f,S+'│');
  End;
 End;

Res := IOResult;
System.Close(f);
Res := IOResult;
End;{Procedure Save}


Procedure TZenaWindow.Refresh;
Var l : Boolean;
    i,res  : Word;
    s,ws : String;
    c,Count : Word;
    id : PBufBazType;
    Baz : File;
    SklF : File;
    Skl : PBufSkladType;
    BazFilef : File;
    BazElement1 : PBufSkladTypeNew;
    SMake,SGroup : TDAteString;
    MySet:Set Of Byte;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;

Begin
Assign(RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
Res:=IOResult;
Reset(RazdelFile);
Res:=IOResult;
If Res=0 Then
 Begin
 NameList^.NewList(Nil);
 NameList^.NewList(New(PTextCollection, Init(0,1)));

  MySet:=[];

  Case VidProd Of
  0:MySet:=[0..25];
  1:MySet:=[26..50];
  2:MySet:=[51..99];
  Else Exit;
  End;

  While Not(Eof(RazdelFile)) Do
  Begin

  Read(RazdelFile,RazdelElement);


  DInfoMsgShkala('Читаю базу товаров раздел '+RazdelElement.Kod+' ...',
  1,EmployRazdel,StrToInt(RazdelElement.Kod)+1);

  If (RazdelElement.Employ) And (RazdelElement.EnableDoc=0) Then
  Begin
   If StrToInt(RAzdelElement.Kod) in MySet Then
 Begin
  Assign(BazFilef,Path^.Dat.ToIndex+RazdelElement.Kod+'.kdx');
  Res:=IOResult;
  OldFileMode:=FileMode;
  FileMode:=ReadOnlyN;
  Reset (BazFilef,SizeOf(SkladTypeNew));
  Res:=IOResult;
  FileMode:=OldFileMode;
  If Res=0 Then
   Begin
    While Not (Eof(BazFileF)) Do
     Begin
      Count:=0;
      New(BazElement1,Init);
      ReadBufNewSklad(BazFilef,BazElement1,Count);
For c:=1 To Count Do
Begin
      If BazElement1^.Point.Dat[c].Employ Then
      If BazElement1^.Point.Dat[c].Main=0 Then{только главные позиции}
       Begin
        ws:=IntToStr(BazElement1^.Point.Dat[c].BazKod,CArtikul);
        RFormatZerro(ws,CArtikul);
        s:=BazElement1^.Point.Dat[c].NAme+' '+BazElement1^.Point.Dat[c].NAme2;
        DelSpaceRight(s);
        If RazdelElement.EnableDoc=1 Then s:='■'+s;
        Format(S,CNAme+6);
        s:=s+'│'+ws+'│';

      If NameList^.List^.Count>=MaxCollectionSize-1 Then
      Begin
       NoInfoMsg;
       NameList^.FocusItem(0);
       ZWin^.Insert(NameList);
       Redraw;
       MessageBox(^M+#3+'Переполнение коллекции!',Nil,mfError+mfCancelButton);
       Break;
      End;

        NameList^.List^.Insert(NewStr(s));
        NameList^.SetRange(NameList^.List^.Count);
       End;

End;{For}

     Dispose(BazElement1,Done);
          End;{While}
    System.Close(BazFileF);
   End
   Else
    MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToIndex+RazdelElement.Kod+'.kdx'+^M+
    ClicProgrammer^,Nil,mfError+mfCancelButton);
   End;{RazdelElement.Employ}
End;{}
  End;{While Not(Eof(RazdelFile))}
  System.Close(RazdelFile);
 End
 Else
        Begin
         NoInfoMsg;
	    MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToRazdel+'Razdel.db'^M+ClicProgrammer^,Nil,mfError+mfCancelButton);
        End;
{Dispose(Id,Done);}
NoInfoMsg;
NameList^.FocusItem(0);
ZWin^.Insert(NameList);
Redraw;
End;


Procedure TZenaWindow.Start;
Label 4;
Var l : Boolean;
    i,res  : Word;
    s,ws : String;
    c,Count : Word;
    id : PBufBazType;
    BBB : PBazType;
    Adding : Boolean;
    Baz : File;
    SklF : File;
    Skl : PBufSkladType;
    art,SName : TMyString;
    SZena1,SZena2,SZena3 : AllStr;
    BazFilef : File;
    R : TRect;
    BazElement1 : PBufSkladTypeNew;
    f : Text;
    MySet:Set Of Byte;

begin
R.Assign(0, 0, 80, 23);
New(ZWin, Init(R, 'Настройка ценовых ограничений'));
ZWin^.HelpCtx:=$F971;


VidProd:=0;
R.Assign(2, 1, 45, 2);
ControlVid := New(PRadioButtons, Init(R,
  NewSItem('0-25',
  NewSItem('26-50',
  NewSItem('51-99',
  Nil)))));
ZWin^.Insert(ControlVid);


R.Assign(79, 2, 80, 11);
Control := New(PScrollBar, Init(R));
ZWin^.Insert(Control);


R.Assign(0, 2, 79, 11);
NameList := New(PBox, Init(R, 2, PScrollbar(Control)));
NameList^.NewList(New(PTextCollection, Init(0,1)));
ZWin^.Insert(NameList);
NameList^.FocusItem(0);
NameList^.HelpCtx:=$F969;

R.Assign(79, 12, 80, 22);
Control := New(PScrollBar, Init(R));
ZWin^.Insert(Control);

R.Assign(0, 12, 79, 22);
SelectNameList := New(PBox, Init(R, 1, PScrollbar(Control)));
SelectNameList^.NewList(New(PTextCollection, Init(0,1)));
ZWin^.Insert(SelectNameList);

  R.Assign(1, 11, 77, 12);
  ZWin^.Insert(New(PLabel, Init(R, 'Наименование товара                                  Код  Т  Цена 1  Цена 2',
  SelectNameList)));

{вставляем в лист текущие настройки}
Assign (f,Path^.DAt.ToOperator+'range');
Res := IOResult;
Reset(f);
Res := IOResult;
If Res = 0 Then
 Begin
DInfoMsg('Минуточку....',False);
While Not(Eof(f)) Do
 Begin
  Readln(f,s);
  s:=UpCases(s);
  If (Not(Pos('REM',s)=1)) And (Not(Pos(';',s)=1)) And (Not(Pos('│',s)=1)) Then
   Begin
    Art:=Copy(s,1,CArtikul);

    Art:=CalcMainKod(Art);

    If {Not}TestElement(Art,SelectNameList) Then
     Begin
 {    MessageBox(#3'Обнаружено дублирование ценновых ограничений для позиции '+Art+'!'+
	ClicProgrammer^,Nil,mfError+mfCancelButton);}

  DelSpaceRight(s);
  sName:=GetIdField(FFFNAme,Art);
  Format(SNAme,CName+CName);
  SZena1:=Copy(s,1+CArtikul+1+COne+1,CZena);
  MyStr(StrToReal(SZena1),CZena,CMantissa,SZena1);
  SZena2:=Copy(s,1+CArtikul+1+COne+1+CZena+1,CZena);
  MyStr(StrToReal(SZena2),CZena,CMantissa,SZena2);
  SZena3:=Copy(s,1+CArtikul+1+COne+1+CZena+1+CZena+1,CZena);
  MyStr(StrToReal(SZena3),CZena,CMantissa,SZena3);

  If s[0]<>#0 Then
  Begin
   SelectNameList^.List^.Insert(NewStr(SName+'│'+{s}+Art+'│1│'+SZena1+'│'+SZena2+'│'+SZena3));
   SelectNameList^.SetRange(SelectNameList^.List^.Count);
  End;{TestElement}
     End;

     End;
 End;
 NoInfoMsg;

  Res := IOResult;
  System.Close(f);
  Res := IOResult;
 End;

SelectNameList^.FocusItem(0);
SelectNameList^.HelpCtx:=$F965;


R.Assign(58, 22, 74, 23);
Control := New(PColoredText, Init(R, 'Выбрано позиций:', $7E));
ZWin^.Insert(Control);

R.Assign(74, 22, 79, 23);
ControlCount := New(PColoredText, Init(R, #3+IntToStr(SelectNameList^.List^.Count,CMAntissa), $4E));
ZWin^.Insert(ControlCount);

ZWin^.SelectNext(False);

ZWin^.Refresh;

4:

c:=Desktop^.ExecView(ZWin);

If c=cmOk Then
 Begin
  ZWin^.Save(SelectNameList);
  DInfoMsg('Ценовые ограничения успешно сохранены!',False);
  Delay(1000);
  NoInfoMsg;
  AddProtocol('Корректировка ценновых ограничений','','');
 End;

if c=cmCancel Then
 Begin
  If MessageBox(^M+#3'Отказываетесь от изменений?',Nil,mfConfirmation+
  mfOkCancel)<>cmOk Then Goto 4;
 End;

Dispose(Control,Done);
Dispose(ControlCount,Done);
Dispose(NameList,Done);
Dispose(SelectNameList,Done);
Dispose(ControlVid,Done);
Dispose(ZWin,Done);

end;



function CorrectZena(Regim:Word;s : String):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  c : Word;
  Position : Word;
  Control : PView;
  SArt : ArtikulStr;
  SNAme : TMyString;
  ws : String;
Var
  DataRec : record
    Zena1 : String[CZena];
    Zena2 : String[CZena];
    Zena3 : String[CZena];
  end;

begin

If Regim=0 Then
 Begin
  SArt:=system.Copy(s,Pos('│',s)+1,CArtikul);
  If Not TestElement(SArt,SelectNameList) Then
   Begin
    c:=Location(SelectNameList,sart,False);
    Position:=c;
    s:=SelectNameList^.GetText(c,SelectNameList^.List^.Count);
    Regim:=1;
   End;
 End;

R.Assign(12, 8, 67, 13);
New(Dlg, Init(R, 'Ценовые органичения по позиции товара'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E011;

R.Assign(8, 3, 18, 4);
Control := New(PRealInputLine, Init(R, CZena));
Dlg^.Insert(Control);

  R.Assign(1, 3, 8, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Цена1:', Control)));


If Regim=0 Then
 Begin
  SArt:=Copy(s,Pos('│',s)+1,CArtikul);
  SNAme := GetIDField(FFFName,SArt);
  DataRec.Zena1:=BAkGetField(FRZena,SArt,1);
  DelSpace(DataRec.Zena1);
  DataRec.Zena2:=DataRec.Zena1;
  DelSpace(DataRec.Zena2);
  DataRec.Zena3:=DataRec.Zena1;
  DelSpace(DataRec.Zena3);
 End;

If Regim=1 Then
 Begin
  SArt:=Copy(s,Pos('│',s)+1,CArtikul);
  Position:=Location(SelectNameList,sart,False);
  SNAme := GetIDField(FFFName,SArt);
  DataRec.Zena1:=Copy(s,Pos('│',s)+1+CArtikul+1+COne+1,CZena);
  DelSpace(DataRec.Zena1);
  DataRec.Zena2:=Copy(s,Pos('│',s)+1+CArtikul+1+COne+1+CZena+1,CZena);
  DelSpace(DataRec.Zena2);
  DataRec.Zena3:=Copy(s,Pos('│',s)+1+CArtikul+1+COne+1+CZena+1+CZena+1,CZena);
  DelSpace(DataRec.Zena3);
 End;

{
 Regim=0 идет добавление новой позиции
 Regim=1 идет корректировка существующей
}

R.Assign(1, 1, 12, 2);
Control := New(PStaticText, Init(R, 'Код:'+SArt));
Dlg^.Insert(Control);

R.Assign(19, 1, 31, 2);
Control := New(PStaticText, Init(R, 'РЦ:'+BakgetField(FRZena,SArt,1)));
Dlg^.Insert(Control);

R.Assign(35, 1, 48, 2);
Control := New(PStaticText, Init(R, 'ЗЦ:'+BakgetField(FZakupka,SArt,1)));
Dlg^.Insert(Control);

If Regim=1 Then
Begin
R.Assign(23, 4, 34, 5);
Control := New(PColoredText, Init(R, 'Коррекция', $4E));
Dlg^.Insert(Control);
End;




R.Assign(1, 2, 53, 3);
Control := New(PStaticText, Init(R, SNAme));
Dlg^.Insert(Control);



R.Assign(25, 3, 35, 4);
Control := New(PRealInputLine, Init(R, CZena));
Dlg^.Insert(Control);

  R.Assign(18, 3, 25, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Цена2:', Control)));

R.Assign(42, 3, 52, 4);
Control := New(PRealInputLine, Init(R, CZena));
Dlg^.Insert(Control);

  R.Assign(35, 3, 42, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Цена3:', Control)));




Dlg^.SelectNext(False);

Dlg^.SetData(DataRec);

1:

c:=DeskTop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(DataRec);

  If StrToReal(DataRec.Zena1)<0.009 Then
   Begin
    MessageBox(^M+#3'Недопустимое значение цены1!',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  If StrToReal(DataRec.Zena2)<0.009 Then
   Begin
    MessageBox(^M+#3'Недопустимое значение цены2!',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  If StrToReal(DataRec.Zena3)<0.009 Then
   Begin
    MessageBox(^M+#3'Недопустимое значение цены3!',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  MyStr(StrToReal(DataRec.Zena1),CZena,CMantissa,DataRec.Zena1);
  DelSpace(DataRec.Zena1);
  MyStr(StrToReal(DataRec.Zena2),CZena,CMantissa,DataRec.Zena2);
  DelSpace(DataRec.Zena2);
  MyStr(StrToReal(DataRec.Zena3),CZena,CMantissa,DataRec.Zena3);
  DelSpace(DataRec.Zena3);

  If Regim=1 Then
  Begin
   SelectNameList^.List^.AtFree(Position);
   SelectNameList^.SetRange(SelectNameList^.List^.Count);
  End;

  Format(SName,CNAme+CName);
  RFormat(DataRec.Zena1,CZena);
  RFormat(DataRec.Zena2,CZena);
  RFormat(DataRec.Zena3,CZena);
  s:=SName+'│'+SArt+'│1│'+DataRec.Zena1+'│'+DataRec.Zena2+'│'+DataRec.Zena3;

  SelectNameList^.List^.Insert(NewStr(s));
  SelectNameList^.SetRange(SelectNameList^.List^.Count);

 End;

Dispose(Control,Done);
Dispose(Dlg,Done);

end;






procedure TZenaWindow.HandleEvent(var Event: TEvent);
Label 1,2;
procedure Calculator;
begin
  Calc^.Start;
end;

Var Test : Word;
    razd : ArtikulStr;
    R : TRect;
    s1,s : String;
    FStr : TMyString;
    Res,ls : Word;
    Logik : Boolean;

    tempBox : PBox;

Begin

Case Event.What Of
 evKeyDown :
   Case Event.KeyCode Of
   kbF4      :Begin
          If (((SelectNameList^.State and sfFocused <> 0)And(SelectNameList^.List^.Count>= 1)))
		 Then
            Begin
             s:=SelectNameList^.GetText(SelectNameList^.Focused,SelectNameList^.List^.Count);
             CorrectZena(1,s);
             DrawCurrent;
            End;
             ClearEvent(Event);
             Redraw;
              End;
   kbEnter   : Begin

          If (((SelectNameList^.State and sfFocused <> 0)And(SelectNameList^.List^.Count>= 1)))
		 Or ( ((NameList^.State and sfFocused <> 0)And(NameList^.List^.Count>= 1)))Then
            Begin

          If ((SelectNameList^.State and sfFocused <> 0)And(SelectNameList^.List^.Count>= 1)) Then
            Begin
             s:=SelectNameList^.GetText(SelectNameList^.Focused,SelectNameList^.List^.Count);
             CorrectZena(1,s);
            End;

          If ((NameList^.State and sfFocused <> 0)And(NameList^.List^.Count>= 1)) Then
            Begin
             s:=NameList^.GetText(NameList^.Focused,NameList^.List^.Count);
             CorrectZena(0,s);

                If (NameList^.Focused+1)<NameList^.List^.Count Then
                 Begin
                 NameList^.FocusItem(NameList^.Focused+1);
                 End;

             DrawCurrent;

            End;
             ClearEvent(Event);
            End;
               Redraw;
               End;

   kbGrayMinus,kbAltF2:Begin
          If ((SelectNameList^.State and sfFocused <> 0)And(SelectNameList^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...',True);
             2:
             if (SelectNameList^.List^.Count>= 1) Then
             For ls :=0 To SelectNameList^.List^.Count-1 Do
              Begin
               s:=SelectNameList^.GetText(ls,SelectNameList^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CName+CName);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0) Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               Begin
               SelectNameList^.List^.AtFree(Ls);
               SelectNameList^.SetRange(SelectNameList^.List^.Count);
               goto 2;
               End;
              End;{For}
                 If SelectNameList^.Focused>0 Then
                            SelectNameList^.FocusItem(SelectNameList^.Focused);

                 If (SelectNameList^.Focused>=SelectNameList^.List^.Count)
                          and(SelectNameList^.Focused>0) Then
                   SelectNameList^.FocusItem(SelectNameList^.Focused-1);
              NoInfoMsg;
              DrawCurrent;
              SelectNameList^.FocusItem(0);
                End;{Maska}
              Redraw;
            End;{Nil}
              ClearEvent(Event);
              End;
     kbDel: Begin
               ClearFind;
     If (SelectNameList^.State and sfFocused <> 0) And (SelectNameList^.List<>Nil)And(SelectNameList^.List^.Count>=1) Then
            Begin
             SelectNameList^.List^.AtFree(SelectNameList^.Focused);
             SelectNameList^.SetRange(SelectNameList^.List^.Count);
             If SelectNameList^.Focused>0 Then
                                 SelectNameList^.FocusItem(SelectNameList^.Focused);

             If (SelectNameList^.Focused>=SelectNameList^.List^.Count) and(SelectNameList^.Focused>0) Then
             SelectNameList^.FocusItem(SelectNameList^.Focused-1);

              DrawCurrent;
              ClearEvent(Event);
              Redraw;
            End;
              DrawCurrent;
            End;
  kbCtrLDel: Begin
               ClearFind;
     If (SelectNameList^.State and sfFocused <> 0) And (SelectNameList^.List<>Nil)And(SelectNameList^.List^.Count>=1) Then
            Begin
             SelectNameList^.NewList(nil);
             SelectNameList^.NewList(New(PTextCollection, Init(0,1)));
            End;
             ClearEvent(Event);
             DrawCurrent;
             Redraw;
             DrawCurrent;
            End;

     kbShiftDel: Begin
                ClearFind;
     If (SelectNameList^.State and sfFocused <> 0) And (SelectNameList^.List<>Nil)And(SelectNameList^.List^.Count>=1) Then
        Begin
             DInfoMsg('Минуточку...',True);
             razd:=copy(SelectNameList^.GetText(SelectNameList^.Focused,SelectNameList^.List^.Count),1+CNAme+CNAme+1,
		   CRazdelKod);

            If (SelectNameList^.List^.Count>=1) Then
            Begin

             R.Assign(0,0,0,0);
             tempBox := New(PBox, Init(R, 1, Nil));
             tempBox^.NewList(New(PTextCollection, Init(0,1)));

             {Цикл удаления}
             For ls :=0 To SelectNameList^.List^.Count-1 Do
              Begin
               s:=SelectNameList^.GetText(ls,SelectNameList^.List^.Count);
               If Not (StrToInt(Copy(s,1+CNAme+CNAme+1,CRazdelKod))=StrToInt(RAzd)) Then
                Begin
                 TempBox^.List^.Insert(NewStr(s));
                 TempBox^.SetRange(TempBox^.List^.Count);
                End;
              End;{For}

              SelectNameList^.NewList(nil);
              SelectNameList^.NewList(New(PTextCollection, Init(0,1)));

             For ls :=0 To TempBox^.List^.Count-1 Do
              Begin
               s:=TempBox^.GetText(ls,TempBox^.List^.Count);
               SelectNameList^.List^.Insert(NewStr(s));
               SelectNameList^.SetRange(SelectNameList^.List^.Count);
              End;{For}

               Dispose(TempBox,Done);
            End;{SelectNameList^.List^.Count>=1}

                 If SelectNameList^.Focused>0 Then
                            SelectNameList^.FocusItem(SelectNameList^.Focused);

                 If (SelectNameList^.Focused>=SelectNameList^.List^.Count)
                          and(SelectNameList^.Focused>0) Then
                   SelectNameList^.FocusItem(SelectNameList^.Focused-1);
             NoInfoMsg;
             DrawCurrent;

              ClearEvent(Event);
              Redraw;
        End;

             DrawCurrent;
            End;

   Else;
   End;

 evCommand :
   Case Event.Command Of
  cmLocalCalc:Calculator;
  cmRefresh:Begin
             ClearEvent(Event);
             Refresh;
             DrawCurrent;
            End;
        Else;
        End;
 Else;
 End;


  If (Desktop^.Current=PView(ZWin)) And (Event.What <> EvKeyDown) Then
   Begin
          if (ControlVid^.State and sfFocused <> 0)Then
              Begin
               ControlVid^.GetData(Test);
               If Test <> VidProd Then
               Begin
                  VidProd:=Test;
                  Refresh;
                  DrawCurrent;
                  Redraw;
               End;
              End;

   End;

(*
Case Event.What Of
 evCommand :
   Case Event.Command Of
  cmOk: Begin
         If MessageBox(^M+#3'Сохранить внесенные изменения?',Nil,mfOkCancel)<>cmOk Then
          Begin
           ClearEvent(Event);
          End;
        End;
        Else;
        End;
 Else;
 End;
*)

inherited HandleEvent(Event);

End;


Destructor TZenaWindow.Done;
Begin
TDialog.Done;
End;


Procedure TZenaWindow.DrawCurrent;
Var st,s,s2 : String;
    R : TRect;
    c : Word;
Begin
      Dispose(ControlCount,Done);
      s2[0]:=#0;
      R.Assign(74, 22, 79, 23);
      ControlCount := New(PColoredText, Init(R, #3+IntToStr(SelectNameList^.List^.Count,CMAntissa), $4E));
      ZWin^.Insert(ControlCount);
End;





Procedure ViewCorrect;
Var s1,s2:TDateString;
    protocol,txt : Text;
    i : word;
    ws : String;
    Line,Cur,l1,l2 : LongInt;

Begin
 If DatePeriodDialog(s1,s2,True) Then
 Begin
 Assign(txt,Path^.Dat.ToTemp+s2+'.tmp');
 i:=ioresult;
 rewrite(txt);
 i:=ioresult;
 if i<>0 then
  begin
   messagebox(^M+#3+'Не могу создать временный файл!',nil,mfError+mfCancelButton);
   exit;
  end;
 DInfoMsg('Выполняю слияние протоколов...',False);
 l1:=DAteStringToDate(DateMask,s1);
 l2:=DAteStringToDate(DateMask,s2);
 Line:=0;

 For Cur:=l1 To L2 Do
 Begin
    {If DayOfWeek(Cur)<>Sunday Then}
     Begin
 s1:=DAteToDAteString(DAteMask,Cur);
 Assign(protocol,Path^.Dat.Toprotocol+s1+'.pr');
 If LockPrWriteRead(s1,True) Then
Begin
 i:=ioresult;
 reset(protocol);
 i:=ioresult;
 if i=0 then
  begin
  If Cur=L1 Then
   Writeln(txt,'ПРОТОКОЛ ОПЕРАЦИЙ НА СКЛАДЕ ЗА ПЕРИОД С '+s1+' по '+S2);
   Inc(Line);
  While Not(Eof(protocol)) Do
   Begin
    Readln(protocol,ws);
    If Not(Pos('--------',ws)>0) Then
    ws:=Decode(ws);
    Writeln(txt,ws);
    Inc(Line);
   End;
   Close(Protocol);
  end
  Else
    messagebox(^M+#3+'Не могу открыть файл протокола за '+s1+ '!',nil,mfError+mfCancelButton);
  Repeat
  Until UnLockPrWriteRead(s1,True);
End;
End;{если не воскресенье}
  End;
 i:=ioresult;
 Close(txt);
 i:=ioresult;
 NoInfoMsg;

 If Line>32700 Then
  Begin
   If fExists(Path^.Dat.ToUtils+'ed.com') Then RunExternalEdit(Path^.Dat.ToTemp+S2+'.tmp')
    Else
     Begin
      ViewAsText(Path^.Dat.ToTemp+S2+'.tmp','Протокол операций за период с '+s1+' по '+s2,True);
     End;

  End
  Else
 ViewAsText(Path^.Dat.ToTemp+S2+'.tmp','Протокол операций за период с '+s1+' по '+s2,True);
 End;

End;

Procedure ViewVozwrat;
Var s1,s2:TDateString;
    protocol,txt : Text;
    i : word;
    ws : String;
    Line,Cur,l1,l2 : LongInt;

Begin
 If DatePeriodDialog(s1,s2,True) Then
 Begin
 Assign(txt,Path^.Dat.ToTemp+s2+'.tmp');
 i:=ioresult;
 rewrite(txt);
 i:=ioresult;
 if i<>0 then
  begin
   messagebox(^M+#3+'Не могу создать временный файл!',nil,mfError+mfCancelButton);
   exit;
  end;
 DInfoMsg('Выполняю слияние протоколов возврата...',False);
 l1:=DAteStringToDate(DateMask,s1);
 l2:=DAteStringToDate(DateMask,s2);
 Line:=0;

 For Cur:=l1 To L2 Do
 Begin
{    If DayOfWeek(Cur)<>Sunday Then}
     Begin
 s1:=DAteToDAteString(DAteMask,Cur);
 Assign(protocol,Path^.Dat.Toprotocol+s1+'.vpr');
 If LockreturnWriteRead(s1) Then
Begin
 i:=ioresult;
 reset(protocol);
 i:=ioresult;
 if i=0 then
  begin
  If Cur=L1 Then
  Begin
   Writeln(txt,'ПРОТОКОЛ ОПЕРАЦИЙ ВОЗВРАТА НА СКЛАДЕ ЗА ПЕРИОД С '+s1+' по '+S2);
   Inc(Line);
  End;
  While Not(Eof(protocol)) Do
   Begin
    Readln(protocol,ws);
    If Not(Pos('--------',ws)>0) Then
    ws:=Decode(ws);
    Writeln(txt,ws);
    Inc(Line);
   End;
   Close(Protocol);
  end
  Else
    messagebox(^M+#3+'Не могу открыть файл протокола возврата за '+s1+ '!',nil,mfError+mfCancelButton);
  Repeat
  Until UnLockreturnWriteRead(s1);
End;
End;{если не воскресенье}
  End;
 i:=ioresult;
 Close(txt);
 i:=ioresult;
 NoInfoMsg;
 If Line>32700 Then
  Begin
   If fExists(Path^.Dat.ToUtils+'ed.com') Then
   RunExternalEdit(Path^.Dat.ToTemp+S2+'.tmp')
    Else
     Begin
      ViewAsText(Path^.Dat.ToTemp+S2+'.tmp','Протокол возврата и корректировок за период с '+s1+' по '+s2,True);
     End;
  End
  Else
 ViewAsText(Path^.Dat.ToTemp+S2+'.tmp','Протокол возврата и корректировок за период с '+s1+' по '+s2,True);
 End;

End;



Procedure CorrectVeksel;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of DocBazType;
         BB : PDocBazType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
        Begin
         MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
         Exit;
        End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;


C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSklad+'veksel.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к наименований '+Path^.Dat.ToName+s+'.id!',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),5);
DInfoMsg('Определяю свойства базы векселей...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Status) Then
        Begin
         Str((StrToInt(Emp)+1):5,Emp);{занятые позиции}
         Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 58, 16);
New(Dlg, Init(R, 'Свойства базы векселей'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):5,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 35, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 35, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, 5));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),5)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSklad+'veksel.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Status :=False;
   BB^.Dat.Locked :=False;
   BB^.Dat.ClientKod[0] :=#0;
   BB^.Dat.AgentKod[0] :=#0;

   BB^.Dat.DocSelector :=0;

   BB^.Dat.Document[0]:=#0;
   BB^.Dat.DateDocument[0]:=#0;
   BB^.Dat.Seria[0]:=#0;
   BB^.Dat.Summa[0]:=#0;
   BB^.Dat.Proz :='0';
   BB^.Dat.DogovorNumer[0]:=#0;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSklad+'veksel.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSklad+'veksel.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSklad+'veksel.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы векселей','','');
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;


Function TFullScreenPredZakaz.FullScreenPredZakaz(Num:ArtikulStr):Boolean;
var
  R : TRect;
  ws,s,s1,St,s2 : String;
  AgName,ClName : AllStr;
  c,i : Word;
  ff,ff1,ff2 : String;
  G :PPredZakazType;
  Find:Boolean;
  SDate : TDateString;
  ws1,WspomSkidka:String[CIZena];
  Res : Word;
  DDD3,DDD4,DDD,DDD2 : AllStr;
  Color : Word;
  AssZ:DocumentEditZ;
  Barter : AllStr;

begin
  FullScreenPredZakaz:=False;
  Find := False;
  DInfoMsg('Ищу документ...',True);
  New(G,Init);
  ClearChar(Num);
  Find:=GetPredZakaz(Num,G);
  NoInfoMsg;



If Not Find Then
  Begin
   Dispose(G,Done);
   NoInfoMsg;
   Exit;
  End;


DInfoMsg('Формирую документы...',True);
ClearFind;


R.Assign(0, 0, 80, 23);
New(PzWin, Init(R, 'Просмотр предзаказа'));
PzWin^.HelpCtx:={E091}{E556}$F978{F222};

New(PzWin^.Exampl,Init);

PzWin^.Exampl^.Dat:=G^.Dat;
PzWin^.Saved:=False;

Dispose(G,Done);

R.Assign(79, 3, 80, 16);
Control := New(PScrollBar, Init(R));
PzWin^.Insert(Control);


R.Assign(0, 3, 79, 16);
NoScreenList1 := New(PBox, Init(R, 1,PScrollBar(Control)));
NoScreenList1^.NewList(New(PTextCollection, Init(0,1)));

{вставляем в список товары}
{
For c:=1 To PzWin^.Exampl^.Dat.Amount Do
 Begin
  S:=PzWin^.Exampl^.Dat.Element[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,CName);
  s:=ws+'│'+s;


  NoScreenList1^.List^.Insert(NewStr(s));
  NoScreenList1^.SetRange(NoScreenList1^.List^.Count);
 End;
}
NoScreenList1^.FocusItem(0);
PzWin^.Insert(NoScreenList1);

R.Assign(1, 2, 79, 3);
ControlHeader := New(PColoredText, Init(R, '', $70));
PzWin^.Insert(ControlHeader);


R.Assign(1, 1, 8, 2);
Control := New(PStaticText, Init(R, 'Клиент:'));
PzWin^.Insert(Control);

RFormatZerro(PzWin^.Exampl^.Dat.ClientKod,CClientKod);
s:=GetClientField(FClient,PzWin^.Exampl^.Dat.ClientKod,PzWin^.Exampl^.Dat.OperatorSelector);
Format(s,CClient);
R.Assign(8, 1, 35, 2);
ControlClient := New(PColoredText, Init(R, #3+s+'│'+PzWin^.Exampl^.Dat.ClientKod, $1F));
PzWin^.Insert(ControlClient);

R.Assign(46, 1, 52, 2);
Control := New(PStaticText, Init(R, 'Агент:'));
PzWin^.Insert(Control);

RFormatZerro(PzWin^.Exampl^.Dat.AgentKod,CClientKod);
s:=GetAgentField(FAgent,PzWin^.Exampl^.Dat.AgentKod);
Format(s,CClient);
R.Assign(52, 1, 79, 2);
ControlAgent := New(PColoredText, Init(R, #3+s+'│'+PzWin^.Exampl^.Dat.AgentKod, $1F));
PzWin^.Insert(ControlAgent);



R.Assign(1, 0, 1+2+Length('Документ:'+PzWin^.Exampl^.Dat.Document+'/'+
IntToStr(PzWin^.Exampl^.Dat.ClientNumer,CDocNumer)+' '+PzWin^.Exampl^.Dat.Date), 1);
DelSpace(PzWin^.Exampl^.Dat.Document);
Control := New(PColoredText, Init(R, #3'Документ:'+PzWin^.Exampl^.Dat.Document+'/'+
IntToStr(PzWin^.Exampl^.Dat.ClientNumer,CDocNumer)+' '+PzWin^.Exampl^.Dat.Date, $4E));
PzWin^.Insert(Control);


R.Assign(67, 0, 79, 1);
ControlPosition := New(PColoredText, Init(R, 'Позиций:', $4E));
PzWin^.Insert(ControlPosition);


PzWin^.Otbor:=0;


R.Assign(49, 18, 77, 20);
ControlOtbor := New(PRadioButtons, Init(R,
  NewSItem('~В~се',
  NewSItem('Дефицит',
  NewSItem('Доступно', Nil)))));
PzWin^.Insert(ControlOtbor);
ControlOtbor^.SetData(PzWin^.Otbor);

R.Assign(15, 20, 50, 21);
ControlConfirmation := New(PColoredText, Init(R, '', $7E));
PzWin^.Insert(ControlConfirmation);

R.Assign(1, 20, 15, 21);
Control := New(PColoredText, Init(R, 'Подтверждение:', $74));
PzWin^.Insert(Control);

R.Assign(8, 21, 52, 22);
ControlStatus := New(PColoredText, Init(R, '', $7E));
PzWin^.Insert(ControlStatus);

R.Assign(1, 21, 8, 22);
Control := New(PColoredText, Init(R, 'Статус:', $74));
PzWin^.Insert(Control);

R.Assign(69, 21, 77, 22);
ControlDateEnd := New(PColoredText, Init(R, '', $5E));
PzWin^.Insert(ControlDateEnd);



R.Assign(55, 21, 69, 22);
Control := New(PColoredText, Init(R, 'Срок доставки:', $74));
PzWin^.Insert(Control);

R.Assign(69, 20, 77, 21);
ControlDateOtpr := New(PColoredText, Init(R, '', $7E));
PzWin^.Insert(ControlDateOtpr);

R.Assign(55, 20, 69, 21);
Control := New(PColoredText, Init(R, 'Дата отправки:', $74));
PzWin^.Insert(Control);

R.Assign(11, 22, 11, 23);
ControlSum := New(PColoredText, Init(R, '', $4E));
PzWin^.Insert(ControlSum);

R.Assign(1, 18, 49, 19);
ControlComment1 := New(PColoredText, Init(R, '', $1F));
PzWin^.Insert(ControlComment1);

R.Assign(1, 19, 49, 20);
ControlComment2 := New(PColoredText, Init(R, '', $1F));
PzWin^.Insert(ControlComment2);

R.Assign(64, 19, 69, 20);
Control := New(PColoredText, Init(R, ' Вид:', $74));
PzWin^.Insert(Control);

R.Assign(69, 19, 78, 20);
ControlDoc := New(PColoredText, Init(R, #3+'', $7E));
PzWin^.Insert(ControlDoc);

R.Assign(55, 17, 57, 18);
Control := New(PColoredText, Init(R, 'N:', $74));
PzWin^.Insert(Control);

R.Assign(57, 17, 61, 18);
ControlDocNum := New(PColoredText, Init(R, #3+'', $7E));
PzWin^.Insert(ControlDocNum);

R.Assign(61, 17, 65, 18);
Control := New(PColoredText, Init(R, ' от', $74));
PzWin^.Insert(Control);

R.Assign(65, 17, 73, 18);
ControlDocDate := New(PColoredText, Init(R, #3+'', $7E));
PzWin^.Insert(ControlDocDate);

R.Assign(52, 0, 66, 1);
ControlOperator := New(PColoredText, Init(R, #3'', $4E));
PzWin^.Insert(ControlOperator);

R.Assign(1, 17, 8, 18);
Control := New(PColoredText, Init(R, 'Создан:', $74));
PzWin^.Insert(Control);

R.Assign(8, 17, 26, 18);
ControlDateC := New(PColoredText, Init(R, #3+'', $7E));
PzWin^.Insert(ControlDateC);

R.Assign(27, 17, 35, 18);
Control := New(PColoredText, Init(R, 'Изменен:', $74));
PzWin^.Insert(Control);

R.Assign(35, 17, 53, 18);
ControlDateM := New(PColoredText, Init(R, #3+'', $7E));
PzWin^.Insert(ControlDateM);


R.Assign(1, 16, 79, 17);
ControlName := New(PColoredText, Init(R, '', $7E));
PzWin^.Insert(ControlName);


PzWin^.SelectNext(False);

NoInfoMsg;

Refresh;

CurrentLine[0]:=#0;

DrawCurrent;

i := Desktop^.ExecView(PzWin);

Dispose(Control,Done);
Dispose(ControlName,Done);
Dispose(ControlDateM,Done);
Dispose(ControlDateC,Done);
Dispose(ControlOperator,Done);
Dispose(ControlDocNum,Done);
Dispose(ControlDoc,Done);
Dispose(ControlComment1,Done);
Dispose(ControlComment2,Done);
Dispose(ControlDateOtpr,Done);
Dispose(ControlSum,Done);
Dispose(ControlStatus,Done);
Dispose(ControlOtbor,Done);
Dispose(ControlConfirmation,Done);
Dispose(ControlPosition,Done);
Dispose(ControlHeader,Done);

Dispose(ControlClient,Done);
Dispose(ControlAgent,Done);
Dispose(NoScreenList1,Done);
Dispose(PzWin^.Exampl,Done);

FullScreenPredZakaz:=PzWin^.Saved;


Dispose(PzWin,Done);

end;




procedure TFullScreenPredZakaz.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var s : String;
    Test,Prom : Word;
    Assistent : DocumentEditZ;
    Num,Sn : ArtikulStr;
    R : TRect;

Begin

Case Event.What Of
 evKeyDown :
   Case Event.KeyCode Of
   kbEnter : Begin
              ClearFind;
if (NoScreenList1^.State and sfFocused <> 0) And(NoScreenList1^.List<>Nil) And (NoScreenList1^.List^.Count>=1)Then
      If (NoScreenList1^.List^.Count-1)>=0 Then
      Begin
       Event.What:=evCommand;
       Event.Command:=cmEdit;
       PutEvent(Event);
       ClearEvent(Event);
      End;
             End;
   Else;
   End;
 evCommand :
   Case Event.Command Of
  cmLocalCalc:Calculator;


     cmEdit:Begin

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;
ClearFind;

             If PZWin^.Exampl^.Dat.Status =4 Then
             Begin
             If EditWin^.Start(PZWin^.Exampl) Then
              Begin
               Num:=PzWin^.Exampl^.Dat.Document;
               Dispose(PzWin^.Exampl,Done);
               DInfoMsg('Ищу документ...',True);
               New(PzWin^.Exampl,Init);
               ClearChar(Num);
               GetPredZakaz(Num,PzWin^.Exampl);
               NoInfoMsg;
               PzWin^.Saved:=True;

(*
RFormatZerro(PzWin^.Exampl^.Dat.ClientKod,CClientKod);
s:=GetClientField(FClient,PzWin^.Exampl^.Dat.ClientKod,PzWin^.Exampl^.Dat.OperatorSelector);
Format(s,CClient);
Dispose(ControlClient,Done);
R.Assign(8, 1, 35, 2);
ControlClient := New(PColoredText, Init(R, #3+s+'│'+PzWin^.Exampl^.Dat.ClientKod, $1F));
PzWin^.Insert(ControlClient);


Dispose(ControlAgent,Done);
RFormatZerro(PzWin^.Exampl^.Dat.AgentKod,CClientKod);
s:=GetAgentField(FAgent,PzWin^.Exampl^.Dat.AgentKod);
Format(s,CClient);
R.Assign(52, 1, 79, 2);
ControlAgent := New(PColoredText, Init(R, #3+s+'│'+PzWin^.Exampl^.Dat.AgentKod, $1F));
PzWin^.Insert(ControlAgent);
*)


               Refresh;
               ClearEvent(Event);
              End;
             End
             Else
              MessageBox(^M+#3'Редактирование запрещено! Документ уже обработан!',Nil,mfInformation+mfCancelButton);

              ClearEvent(Event);
            End;

     cmViewBron
        :Begin
       ClearFind;
if (NoScreenList1^.State and sfFocused <> 0) And(NoScreenList1^.List<>Nil) And (NoScreenList1^.List^.Count>=1)Then
      If (NoScreenList1^.List^.Count-1)>=0 Then
       begin
        Sn:=Copy(NoScreenList1^.GEtTExt(NoScreenList1^.Focused,NoScreenList1^.List^.Count),1+CName-2+1,CArtikul);
        FR^.Start(Sn,True);
        Refresh;
        ClearEvent(Event);
       End;
       ClearEvent(Event);
      End;

        cmAllSfB   :Begin
                     ViewElement(PZWin^.Exampl^.Dat.ClientKod,bClient,PZWin^.Exampl^.Dat.OperatorSelector);
                    End;

 {процедура оформления в заказ}
 cmAllTch : Begin
If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;
ClearFind;
  If MessageBox(^M+#3'Провести преобразование в заказ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
  Begin
             If PredZakazOformlenie(PzWin^.Exampl) Then
		    Begin
               Num:=PzWin^.Exampl^.Dat.Document;
               Dispose(PzWin^.Exampl,Done);
               DInfoMsg('Ищу документ...',True);
               New(PzWin^.Exampl,Init);
               ClearChar(Num);
               GetPredZakaz(Num,PzWin^.Exampl);
               NoInfoMsg;

               Refresh;
		    End;
  End;
               ClearEvent(Event);
            End;

 cmRefresh : Begin
              Refresh;
              ClearEvent(Event);
             End;

 CmLocalInfo: Begin

if (NoScreenList1^.List<>Nil)And(NoScreenList1^.List^.Count>=1) Then
 Begin
  s:=NoScreenList1^.GetText(NoScreenList1^.Focused,NoScreenList1^.List^.Count);
  s:=Copy(s,1+CArtikul+1+(CName-2)+1+CKol+1+(CKOl+1)+1+CKol+1+COne+1+CZena+1+CZena+1+CZena+1,CDocNumer);
  DelSpace(s);
  Assistent.D:=Copy(s,1+CArtikul+1+(CName-2)+1+CKol+1+(CKOl+1)+1+CKol+1+COne+1+CZena+1+CZena+1+CZena+1+CDocNumer+1,CDAte);
  Assistent.EditPosition:=s;
  ClearChar(Assistent.EditPosition);
  If StrToInt(Assistent.EditPosition)>0 Then ViewMrk^.FullScreenMrk(Assistent,True);
 End;
       ClearEvent(Event);

              End;

 cmFindLink:Begin
             ClearFind;
if (NoScreenList1^.State and sfFocused <> 0) And(NoScreenList1^.List<>Nil) And (NoScreenList1^.List^.Count>=1)Then
      If (NoScreenList1^.List^.Count-1)>=0 Then
       begin
        Sn:=Copy(NoScreenList1^.GEtTExt(NoScreenList1^.Focused,NoScreenList1^.List^.Count),1+CName-2+1,CArtikul);
        Lnk^.Start(Sn);
        ClearEvent(Event);
       End;
        ClearEvent(Event);
            End;


  cmFullView:Begin
  If PZWin^.Exampl^.Dat.Status<>5 Then
   Begin
    MessageBox(^M+#3'Оформление заказа не производилось!',Nil,mfInformation+mfCancelButton);
    Exit;
   End;
  ClearFind;
  Assistent.EditPosition:=PZWin^.Exampl^.Dat.ZakazNumer;
  ClearChar(Assistent.EditPosition);
  ViewMrk^.FullScreenMrk(Assistent,True);
            End;


cmViewPrihodTovar
     :Begin
if (NoScreenList1^.State and sfFocused <> 0) And(NoScreenList1^.List<>Nil) And (NoScreenList1^.List^.Count>=1)Then
      If (NoScreenList1^.List^.Count-1)>=0 Then
       begin
        Sn:=Copy(NoScreenList1^.GEtTExt(NoScreenList1^.Focused,NoScreenList1^.List^.Count),1+CName-2+1,CArtikul);
        FP^.FindScreenPrh(SN);
        ClearEvent(Event);
       End;
      End;

  cmPrintReestr:    Begin
                ClearFind;
                    End;
        Else;
        End;
 Else;
 End;

  If (Desktop^.Current=PView(PZWin)) And (Event.What <> EvKeyDown) Then
   Begin
          if (ControlOtbor^.State and sfFocused <> 0)Then
              Begin
               ControlOtbor^.GetData(Test);
               If Test <> PzWin^.Otbor Then
               Begin
                  PzWin^.Otbor:=Test;
                  Refresh;
               End;
              End;
          DrawCurrent;
   End;



inherited HandleEvent(Event);

End;


Function CalcLastZena(Var SDoc,SDAte:TDAteString;Art:ArtikulStr;Const P : PBox) : TDateString;
Var Position : Word;
    ss : AllStr;
Begin
CalcLastZena:='???';
SDoc:='?';
SDate:='?';

   If Not TestElement(Art,P) Then
    Begin{Элемент найден}
     Position:=Location(P,Art,False);
     ss:=P^.GetText(Position,P^.List^.Count);
     CalcLastZena:=Copy(ss,1+1+CArtikul+1,CZena);

     SDoc:=Copy(ss,1+1+CArtikul+1+CZena+1,CDocNumer);
     SDate:=Copy(ss,1+1+CArtikul+1+CZena+1+CDocNumer+1,CDate);

     If StrToInt(Copy(ss,1+1+CArtikul+1+CZena+1,CDocNumer))=0 Then
     Begin
      CalcLastZena:='???';
      SDoc:='?';
      SDate:='?';
     End;
    End;
End;


Procedure FindLastZena(FindDate:TDateString;Ck:ArtikulStr;Var P:PBox);
var
  R : TRect;
  R1 : LongInt;
  Control : PView;
  ZF : File;
  Z  : PBufLAstClientToVArType;
  Position,jj,cc,Count,C,i : Word;
  s : String;
  SDAte,SZena,ss:AllStr;
begin

Assign(ZF,Path^.Dat.ToClientIndex+ck+'.tlx');
i:=IOResult;
Reset(ZF,SizeOf(LastClientToVarType));
i:=IOResult;
If i=0 Then
Begin


While Not(Eof(ZF)) Do
 Begin
  New(Z,Init);
  Count:=0;
  BlockRead(ZF,Z^.Point,BufferLAstTovar,Count);

For cc:=1 To Count Do
Begin
 If Z^.Point.Dat[cc].Active Then
 Begin
  If Z^.Point.Dat[cc].DateC>DateStringToDate(DateMask,FindDate) Then Continue;
  For jj:=1 To Z^.Point.Dat[cc].Amount Do
  Begin
   If Not TestElement(Z^.Point.Dat[cc].Element[jj].BazKod,P) Then
    Begin{Элемент найден}
     Position:=Location(P,Z^.Point.Dat[cc].Element[jj].BazKod,False);
     ss:=P^.GetText(Position,P^.List^.Count);
     ss[0]:=Chr(1+CArtikul+1);
     MyStr(Z^.Point.Dat[cc].Element[jj].Zena,CZena,CMantissa,SZena);
     Format(SZena,CZena);
     P^.List^.AtFree(Position);
     RFormat(Z^.Point.Dat[cc].Document,CDocNumer);
     SDate:=DateToDateString(DateMask,Z^.Point.Dat[cc].DateC);
     ss:=ss+SZena+'│'+Z^.Point.Dat[cc].Document+'│'+SDate;
     P^.List^.Insert(NewStr(ss));
     P^.SetRange(P^.List^.Count);
    End;
  End;{For jj}

End;{If Active=0}

End;{For cc}
  Dispose(Z,Done);
End;{While}
System.Close(ZF);
i:=IOResult;

End;

NoInfoMsg;

End;



Procedure TFullScreenPredZakaz.Refresh;
Var R:TRect;
    c : Word;
    ws2,ws,s : String;
    Doh,Sum : AllStr;
    Skl : PSkladType;
    SDoc,SDAte,
    SPrevZena,SSkl,SDefizit,SFakt,Skidka : AllStr;
    P : PBox;
    Otsr : AllStr;
    BBB : PBazType;
Begin

DInfoMsg('Минуточку...',False);

NoScreenList1^.NewList(Nil);
NoScreenList1^.NewList(New(PTextCollection, Init(0,1)));

{промежуточный список для поиска последних цен отгрузки}
Sum[0]:=#0;
Doh[0]:=#0;

R.Assign(0, 0, 0, 0);
P := New(PBox, Init(R, 1,Nil));
P^.NewList(New(PTextCollection, Init(0,1)));



{формируем список с последними ценами}
For c:=1 To PzWin^.Exampl^.Dat.Amount Do
 Begin
  If TestElement(PzWin^.Exampl^.Dat.Element[c].BazKod,P) Then
  Begin
   S:='│'+PzWin^.Exampl^.Dat.Element[c].BazKod+'│';
   P^.List^.Insert(NewStr(s));
   P^.SetRange(P^.List^.Count);
  End;
 End;

FindLastZena(DateToDateString(DateMask,PzWin^.Exampl^.Dat.DateC),PzWin^.Exampl^.Dat.ClientKod,P);

{вставляем в список товары}
For c:=1 To PzWin^.Exampl^.Dat.Amount Do
 Begin
  S:=PzWin^.Exampl^.Dat.Element[c].BazKod;

  New(BBB,Init);
  BBB^.Dat.BazKod:=PzWin^.Exampl^.Dat.Element[c].BazKod;
  GetBazElement(s,BBB^.Dat);

  DelSpaceRight(BBB^.Dat.Name);
  DelSpaceRight(BBB^.Dat.Name2);
  ws:=BBB^.Dat.Name;

  ws2:=BBB^.Dat.Name+' '+BBB^.Dat.Name2+' '+GetFirmaPostField(FFirmaPost,BBB^.DAt.FirmaPostKod);
  Format(ws,CName-2);

  Dispose(BBB,Done);

  DelSpace(PzWin^.Exampl^.Dat.Element[c].Kol);
  RFormat(PzWin^.Exampl^.Dat.Element[c].Kol,CKol);

  DelSpace(PzWin^.Exampl^.Dat.Element[c].Zena);
  RFormat(PzWin^.Exampl^.Dat.Element[c].Zena,CZena);


  If Not(PzWin^.Exampl^.Dat.Status in [5]) Then
  Begin
  SFakt:='      ';{ежели всего хватает}
  New(Skl,Init);
  Skl^.Dat.BazKod:=PzWin^.Exampl^.Dat.Element[c].BazKod;
  GetSkladRecord(Skl);

  MyStr(StrToReal(Skl^.Dat.Input.R_Zena)-
  StrToReal(PzWin^.Exampl^.Dat.Element[c].Zena),CZena,CMantissa,
  Skidka);

  SSkl:=IntToStr(StrToInt(Skl^.Dat.Input.Division[PzWin^.Exampl^.Dat.Element[c].DivisionNumber])-
  StrToInt(Skl^.Dat.Input.DivisionR[PzWin^.Exampl^.Dat.Element[c].DivisionNumber]),CKol);

  If StrToInt(SSkl)<StrToInt(PzWin^.Exampl^.Dat.Element[c].Kol) Then
     Begin
      SFakt:=IntToStr(StrToInt(SSkl)-StrToInt(PzWin^.Exampl^.Dat.Element[c].Kol),CKol+1);
     End;

  MyStr(StrToReal(Doh)+(StrToReal(PzWin^.Exampl^.Dat.Element[c].Zena)-StrToReal(Skl^.Dat.Input.Zakupka))*
  StrToInt(PzWin^.Exampl^.Dat.Element[c].Kol),CIZena,CMAntissa,Doh);
  DelSpace(Doh);

  Dispose(Skl,Done);

  End
   Else
    Begin

     MyStr(PzWin^.Exampl^.Dat.Element[c].Skidka,CZena,CMantissa,Skidka);

     SSkl:=IntToStr(PzWin^.Exampl^.Dat.Element[c].Fakt,CKol);

     SFakt:=IntToStr(PzWin^.Exampl^.Dat.Element[c].Fakt,CKol+1);

     If PzWin^.Exampl^.Dat.Status=6 Then SFakt:='      '
     Else
      Begin
  If StrToInt(SSkl)<StrToInt(PzWin^.Exampl^.Dat.Element[c].Kol) Then
     Begin
      SFakt:=IntToStr(StrToInt(SSkl)-StrToInt(PzWin^.Exampl^.Dat.Element[c].Kol),CKol+1);
     End
     Else SFakt:='      ';
      End;



     MyStr(StrToReal(Doh)+(StrToReal(PzWin^.Exampl^.Dat.Element[c].Zena)-PzWin^.Exampl^.Dat.Element[c].Zakupka)*
     StrToInt(PzWin^.Exampl^.Dat.Element[c].Kol),CIZena,CMAntissa,Doh);
     DelSpace(Doh);
    End;


  RFormat(SFakt,CKol+1);
  RFormat(SSkl,CKol);

  MyStr(StrToReal(Sum)+StrToReal(PzWin^.Exampl^.Dat.Element[c].Zena)*
  StrToInt(PzWin^.Exampl^.Dat.Element[c].Kol),CIZena,CMAntissa,Sum);
  DelSpace(Sum);

  SPrevZena:=CalcLastZena(SDoc,SDAte,PzWin^.Exampl^.Dat.Element[c].BazKod,P);
  DelSpace(SPrevZena);
  RFormat(SPrevZena,CZena);

  RFormat(SDoc,CDocNumer);
  RFormat(SDate,CDAte);

  s:=ws+'│'+s+'│'+PzWin^.Exampl^.Dat.Element[c].Kol+'│'+
  SSkl+'│'+IntToStr(PzWin^.Exampl^.Dat.Element[c].DivisionNumber,COne)+'│'+SFakt+'│'+
  SPrevZena+'│'+PzWin^.Exampl^.Dat.Element[c].Zena+'│'+Skidka+'│'+SDoc+'│'+SDate+'│'+ws2;


  If (PzWin^.Otbor=0) Or ((PzWin^.Otbor=1)And(StrToInt(SFAkt)<0)) Or
  ((PzWin^.Otbor=2)And(StrToInt(SFAkt)>=0)) Then
  Begin
   NoScreenList1^.List^.Insert(NewStr(s));
   NoScreenList1^.SetRange(NoScreenList1^.List^.Count);
  End;

 End;

NoScreenList1^.FocusItem(0);


Dispose(P,Done);


Dispose(ControlHeader,Done);
R.Assign(1, 2, 79, 3);
If Not(PzWin^.Exampl^.Dat.Status in [5]) Then
ControlHeader := New(PColoredText, Init(R, 'Наименование товара       Код  Заказ '+
     'Склад О  Delta Последн. Цена опл  Скидка', $70))
Else
ControlHeader := New(PColoredText, Init(R, 'Наименование товара       Код  Заказ '+
     'Факт. О  Дефиц.Последн. Цена опл  Скидка', $70));
PzWin^.Insert(ControlHeader);




Dispose(ControlPosition,Done);
R.Assign(60, 0, 78, 1);
ControlPosition := New(PColoredText, Init(R, 'Позиций:'+
IntToStr(NoScreenList1^.List^.Count,CMantissa)+' из '+
IntToStr(PzWin^.Exampl^.Dat.Amount,CMantissa), $4E));
PzWin^.Insert(ControlPosition);

Dispose(ControlConfirmation,Done);
R.Assign(15, 20, 50, 21);
Case PzWin^.Exampl^.DAt.SendConfirmation Of
0:s:='Не требует';
1:s:='Не отправлено';
2:s:='Отправлено '+DateToDateString(DateMask,PzWin^.Exampl^.DAt.DateConfirmation)+
'('+TimeToTimeString(TimeMask,PzWin^.Exampl^.DAt.TimeConfirmation)+')';
Else s:='???';
End;
ControlConfirmation := New(PColoredText, Init(R, s, $7E));
PzWin^.Insert(ControlConfirmation);


Dispose(ControlStatus,Done);
DelSpace(PzWin^.Exampl^.DAt.ZakazNumer);
Case PzWin^.Exampl^.DAt.Status Of
0:s:='Буфер';
1:s:='Подписан';
2:s:='Отправлен';
3:s:='Удален';
4:s:='Не оформлен';
5:s:='Оформлен в заказ '+PzWin^.Exampl^.DAt.ZakazNumer+' '+
DateToDateString(DateMask,PzWin^.Exampl^.DAt.DateConv)+
'('+TimeToTimeString(TimeMask,PzWin^.Exampl^.DAt.TimeConv)+')';
6:s:='Анулирован '+DateToDateString(DateMask,PzWin^.Exampl^.DAt.DateConv)+
'('+TimeToTimeString(TimeMask,PzWin^.Exampl^.DAt.TimeConv)+')';
Else s:='???';
End;

R.Assign(8, 21, 52, 22);
ControlStatus := New(PColoredText, Init(R, s, $7E));
PzWin^.Insert(ControlStatus);

Dispose(ControlDateEnd,Done);
R.Assign(69, 21, 77, 22);
DelSpace(PzWin^.Exampl^.DAt.DateEnd);
ControlDateEnd := New(PColoredText, Init(R, #3+PzWin^.Exampl^.DAt.DateEnd, $5E));
PzWin^.Insert(ControlDateEnd);

Dispose(ControlDateOtpr,Done);
R.Assign(69, 20, 77, 21);
DelSpace(PzWin^.Exampl^.DAt.DataOtpr);
ControlDateOtpr := New(PColoredText, Init(R, #3+PzWin^.Exampl^.DAt.DataOtpr, $7E));
PzWin^.Insert(ControlDateOtpr);

Otsr[0]:=#0;

{$IFNDEF Pharm}
If PzWin^.Exampl^.Dat.Rezerv in [1..99] Then
 Begin
  Otsr:=' отсрочка:'+IntToStr(PzWin^.Exampl^.Dat.Rezerv,CKol)+' дней';
 End
 Else
  Otsr[0]:=#0;
{$ENDIF}



MyStr(StrToReal(Sum),CIZena,CMAntissa,Sum);
DelSpace(Sum);
MyStr(StrToReal(Doh),CIZena,CMAntissa,Doh);
DelSpace(Doh);
If EnableZakupka=0 Then Doh:=CodeSummaZ;
Dispose(ControlSum,Done);
R.Assign(11, 22, 2+11+Length(' ўК оплате:'+Sum+' ўДоход:'+Doh+Otsr), 23);
ControlSum := New(PColoredText, Init(R, #3+' ўК оплате:'+Sum+' ўДоход:'+Doh+Otsr, $4E));
ControlSum^.Options:=ControlSum^.Options And OfCenterX;
PzWin^.Insert(ControlSum);

Dispose(ControlComment1,Done);
R.Assign(1, 18, 49, 19);
ControlComment1 := New(PColoredText, Init(R, PzWin^.Exampl^.DAt.Comment1, $1F));
PzWin^.Insert(ControlComment1);

Dispose(ControlComment2,Done);
R.Assign(1, 19, 49, 20);
ControlComment2 := New(PColoredText, Init(R, PzWin^.Exampl^.DAt.Comment2, $1F));
PzWin^.Insert(ControlComment2);

Dispose(ControlDoc,Done);
R.Assign(69, 19, 78, 20);
Case PzWin^.Exampl^.DAt.DocSelector Of
0:s:='Список';
1:s:='Тов.чек';
2:s:='Физ.лицо';
3:s:='СФ*';
4:s:='СФБ';
5:s:='Д*';
6:s:='ДСФ';
7:s:='Д';
8:s:='ДСФБ';
Else s:='???';
End;
ControlDoc := New(PColoredText, Init(R, s, $7E));
PzWin^.Insert(ControlDoc);


Dispose(ControlOperator,Done);
R.Assign(65, 22, 79, 23);
ControlOperator := New(PColoredText, Init(R, #3+GetOperatorField(FName,
PzWin^.Exampl^.DAt.Caption), $4E));
PzWin^.Insert(ControlOperator);

Dispose(ControlDateC,Done);
R.Assign(8, 17, 27, 18);
ControlDateC := New(PColoredText, Init(R, #3+DateToDateString(DateMask,PzWin^.Exampl^.DAt.DateC)+
'('+TimeToTimeString(TimeMask,PzWin^.Exampl^.DAt.TimeC)+')', $7E));
PzWin^.Insert(ControlDateC);

Dispose(ControlDateM,Done);
R.Assign(35, 17, 53, 18);
If PzWin^.Exampl^.DAt.Versia >1 Then
ControlDateM := New(PColoredText, Init(R, #3+DateToDateString(DateMask,PzWin^.Exampl^.DAt.DateM)+
'('+TimeToTimeString(TimeMask,PzWin^.Exampl^.DAt.TimeM)+')', $7E))
Else
ControlDateM := New(PColoredText, Init(R, #3+'', $7E));
PzWin^.Insert(ControlDateM);

RFormatZerro(PzWin^.Exampl^.Dat.ClientKod,CClientKod);
s:=GetClientField(FClient,PzWin^.Exampl^.Dat.ClientKod,PzWin^.Exampl^.Dat.OperatorSelector);
Format(s,CClient);
Dispose(ControlClient,Done);
R.Assign(8, 1, 35, 2);
ControlClient := New(PColoredText, Init(R, #3+s+'│'+PzWin^.Exampl^.Dat.ClientKod, $1F));
PzWin^.Insert(ControlClient);

RFormatZerro(PzWin^.Exampl^.Dat.AgentKod,CClientKod);
s:=GetAgentField(FAgent,PzWin^.Exampl^.Dat.AgentKod);
Format(s,CClient);
Dispose(ControlAgent,Done);
R.Assign(52, 1, 79, 2);
ControlAgent := New(PColoredText, Init(R, #3+s+'│'+PzWin^.Exampl^.Dat.AgentKod, $1F));
PzWin^.Insert(ControlAgent);



NoInfoMsg;

CurrentLine[0]:=#0;

PzWin^.Redraw;

End;



Procedure TFullScreenPredZakaz.DrawCurrent;
Var st,ss : String[220];
    R : TRect;
    c : Word;
Begin
if (NoScreenList1^.List<>Nil)And(NoScreenList1^.List^.Count>=1) Then
 Begin
  st:=NoScreenList1^.GetText(NoScreenList1^.Focused,NoScreenList1^.List^.Count);
  If st <> CurrentLine Then
    Begin
     CurrentLine:=st;

     Dispose(ControlDocNum,Done);
     ss:=Copy(st,1+CArtikul+1+(CName-2)+1+CKol+1+(CKOl+1)+1+CKol+1+COne+1+CZena+1+CZena+1+CZena+1,CDocNumer);
     DelSpace(ss);
     R.Assign(57, 17, 61, 18);
     ControlDocNum := New(PColoredText, Init(R, #3+ss, $7E));
     PzWin^.Insert(ControlDocNum);

     Dispose(ControlDocDate,Done);
     ss:=Copy(st,1+CArtikul+1+(CName-2)+1+CKol+1+(CKOl+1)+1+CKol+1+COne+1+CZena+1+CZena+1+CZena+1+CDocNumer+1,CDAte);
     R.Assign(65, 17, 73, 18);
     ControlDocDate := New(PColoredText, Init(R, #3+ss, $7E));
     PzWin^.Insert(ControlDocDate);

     ss:=Copy(st,1+CArtikul+1+(CName-2)+1+CKol+1+(CKOl+1)+1+CKol+1+COne+1+CZena+1+CZena+1+CZena+1+CDocNumer+1+CDAte+1,
	80);
     DelSpaceRight(ss);
     Dispose(ControlName,Done);
     R.Assign(1, 16, 79, 17);
     ControlName := New(PColoredText, Init(R, ss, $7E));
     PzWin^.Insert(ControlName);
     PzWin^.Redraw;

    End;

 End
End;





Destructor TFullScreenPredZakaz.Done;
Begin
TDialog.Done;
End;



Procedure ExportNAkl(As:DocumentEditZ);
Label 1,2;
 Var Fexp : File Of ImportSuperMarketType;
     Exp : PImportSuperMarketType;
     E : PSuperMarketType;
     s : String;
     ok : Boolean;
     c,i,j,k : Word;
     Event : TEvent;
     f : File;

Procedure EraseFile(s:TMySTring);
Var F : File;
    c : Word;
Begin
 Assign(f,s);
 c:=IOResult;
 Erase(f);
 c:=IOResult;
End;

Function CalcIndex(Art:ArtikulStr):Word;
Var c:Word;
Begin
 For c:=1 To CMax Do
  Begin
   If Exp^.Dat.Element[c].Employ Then{Если занята}
    Begin
     If Exp^.Dat.Element[c].Baz.BazKod=Art Then
      Begin
       CalcIndex:=c;
       Break;
      End;
    End
   Else{если не заната}
    Begin
     CalcIndex:=c;
     Break;
    End;
  End;{For}
End;

Function CalcIndexSertif(Art:ArtikulStr):Word;
Var c:Word;
Begin
 For c:=1 To CMax Do
  Begin
   If Exp^.Dat.ElementS[c].Employ Then{Если занята}
    Begin
     If Exp^.Dat.ElementS[c].Baz.BazKod=Art Then
      Begin
       CalcIndexSertif:=c;
       Break;
      End;
    End
   Else{если не заната}
    Begin
     CalcIndexSertif:=c;
     Break;
    End;
  End;{For}
End;


Function CalcIndexNSertif(Art:ArtikulStr):Word;
Var c:Word;
Begin
 For c:=1 To CMax Do
  Begin
   If Exp^.Dat.NSertif[c].Employ Then{Если занята}
    Begin
     If Exp^.Dat.NSertif[c].Baz.BazKod=Art Then
      Begin
       CalcIndexNSertif:=c;
       Break;
      End;
    End
   Else{если не заната}
    Begin
     CalcIndexNSertif:=c;
     Break;
    End;
  End;{For}
End;


Begin
New(E,Init);

If Not(GetMarket1(As,E)) Then
 Begin
  Dispose(E,Done);
  Exit;
 End;


    If Not TestExportMarket(E,FAlse)  Then
     Begin
      If MessageBox(^M+#3'Желаете провести удаление отправленного сообщение и повторный экспорт?',Nil,
	 mfConfirmation+mfOkCancel)=cmOk Then
      Begin
      If Password(17) Then
       Begin
         Assign(f,PathExpImp^.Dat.ToImport[1]+GetImportFileName(As,E^.Dat.ClientKod));
         c:=IoResult;
         Erase(f);
         c:=IoResult;
         If c<>0 Then
              Begin
               MessageBox(^M+#3'Ошибка при удалении',Nil,mfError+mfCancelButton);
               Dispose(E,Done);
               TekDate:=FDAte;
               Exit;
              End;{c<>0}
       End{Password(16)}
        Else
        Begin
         Dispose(E,Done);
         TekDate:=FDAte;
         Exit;
        End;
      End{MessgeBox}
       Else
        Begin
         Dispose(E,Done);
         TekDate:=FDAte;
         Exit;
        End;
     End;


    i:=LockMArket(As,E);
    If I=2 Then
     Begin
      Beep;
      DinfoMsg('Не могу заблокировать док-т продажи N '+E^.Dat.Document+' от '+E^.Dat.DateC+
         '. Попробуйте повторить!',False);
      Dispose(E,Done);
      Application^.ClearEvent(Event);
      Application^.GetEvent(Event);
      Application^.ClearEvent(Event);
      repeat
        Application^.GetEvent(Event);
      until (Event.What <> evNothing) And (Event.Command<>cmMenu);
      NoInfoMsg;
      Application^.ClearEvent(Event);
      Exit;
     End;

    If I<>0 Then
     Begin
      Dispose(E,Done);
      Exit;
     End;



 If (E^.DAt.Amount+E^.DAt.AmountS)>CMax Then
  Begin
   Repeat
   Until (UnLockMarket(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
   MessageBox(^M+#3'Документ '+E^.DAt.Document+' от '+E^.DAt.DateC+
   'не может быть экспортирован! Слишком много позиций!',Nil,mfError+mfCancelButton);
   Dispose(E,Done);
   Exit;
  End;

 If (E^.DAt.OperatorSelector <> 1) Or ((E^.Dat.OperatorSelector=1)And(StrToInt(E^.DAt.ClientKod)=StrToInt(ClientRP))) Then
  Begin
   SpecialBeep;
   MessageBox(^M+#3'Экспортировать можно только межскладские перевозки!',
   Nil,mfError+mfCancelButton);
   Repeat
   Until (UnLockMarket(E^.Dat.Document,E^.Dat.DateC) in [0,2]);

   Dispose(E,Done);
   Exit;
  End;

 Assign(FExp,Path^.Dat.ToTemp+GetImportFileName(As,E^.Dat.ClientKod));
 I:=IoResult;
 Rewrite(FExp);
 I:=IoResult;
 If I<>0 Then
  Begin
   Repeat
   Until (UnLockMarket(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
   MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+GetImportFileName(As,E^.Dat.ClientKod)+
   '!'+ClicProgrammer^,Nil,mfError+mfCancelButton);
   Dispose(E,Done);
   Exit;
  End;

 DInfoMsg('Экспортирую документ. Ждите...',True);
 New(Exp,Init);
 {цикл конвертации}
 With Exp^.Dat Do
  Begin
     {OperatorSelector :=E^.DAt.OperatorSelector;}
     Status    :=0;           {статус: импортирован 1 или нет 0}
     {ClientKod :=E^.Dat.ClientKod; {код клиента}
     {AgentKod  :=E^.Dat.AgentKod; {код агента}
     Document  :=E^.DAt.Document; {номер документа}
     DateC     :=DateStringToDate(DAteMAsk,E^.DAt.DAteC); {дата импорта}
     TimeC     :=TimeStringToTime('hh:mm:ss',Times); {время импорта}
     {только для сертификатов}

     Summaz:=StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.SertifSummaZ);
     SummaZakupka:=StrToReal(E^.Dat.SummaZakupka)+StrToReal(E^.Dat.SertifSummaZakupka);

    SkladKod :=Rek^.Dat.Kod;{признак склада}
     Caption :=CurrentPAssword;{признак оператора}
     {цикл заполнения накладной}

   If E^.Dat.Amount>0 Then
   Begin
   For i:=1 To E^.Dat.Amount Do
   Begin
    j:=CalcIndex(E^.DAt.MarketElement[i].Bazkod);
    With Element[j] Do
     Begin
      If GetBazElement(E^.DAt.MarketElement[i].Bazkod,Element[j].Baz) Then
       Begin
        {Element[j].Baz.Locked:=False;}
        {Element[j].Baz.Stat:=False;}
        Element[j].Baz.Employ:=True;
        Element[j].Employ:=True;
        Element[j].Baz.BazKod:=E^.Dat.MarketElement[i].BazKod;
           {
           Input.USD    :=StrToInt(BakGetfield(FUSD,E^.Dat.MarketElement[i].BazKod,0));
           Input.GRZena :=BakGetfield(FGRZena,E^.Dat.MarketElement[i].BazKod,0);
           }
           Input.Zakupka    :=E^.Dat.MarketElement[i].Input.Zakupka;
           Input.Zakupka2    :=E^.Dat.MarketElement[i].Input.Zakupka2;

           Input.RegionMArka :=E^.Dat.MarketElement[i].Input.RegionMarka;

           Input.AkzisSbor:=E^.Dat.MarketElement[i].Input.AkzisSbor;
           Input.ZenaMarki:=E^.Dat.MarketElement[i].Input.ZenaMarki;

           Input.R_Zena     :=E^.Dat.MarketElement[i].Input.R_Zena;

           If FindParam('/TRIADA') and (StrToInt(E^.Dat.ClientKod) in [12,13,4,11,10,8,19]) Then
           Begin
            MyStr(StrToreal(E^.Dat.MarketElement[i].Input.R_Zena)-
            StrToReal(E^.Dat.MarketElement[i].Input.Skidka),CZena,CMAntissa,Input.R_Zena);
            DelSpace(Input.R_Zena);
           End;

           Input.Spec_Zena  :=BakGetField(FSpecZena,E^.Dat.MarketElement[i].BazKod,0);
           Input.O_Zena     :=E^.Dat.MarketElement[i].Input.R_Zena;
           Input.NMakeKod   :=E^.Dat.MarketElement[i].Input.NMakeKod;

           {Input.DivisionNumber:=E^.Dat.MarketElement[i].Input.DivisionNumber;}

       If MarketSD=1 Then
        Begin
           Input.NGTD       :=BakGetfield(FNGTD,E^.Dat.MarketElement[i].BazKod,0);
           DelSpaceRight(Input.NGTD);
           Input.Expert     :=BakGetfield(FExpert,E^.Dat.MarketElement[i].BazKod,0);
           DelSpaceRight(Input.Expert);
           Input.Marka      :=BakGetfield(FMarka,E^.Dat.MarketElement[i].BazKod,0);;
           DelSpaceRight(Input.Marka);
           Input.SpecMarka     :=BakGetfield(FSpecMarka,E^.Dat.MarketElement[i].BazKod,0);
           DelSpaceRight(Input.SpecMarka);
           Input.Godnost    :=BakGetfield(FGodnost,E^.Dat.MarketElement[i].BazKod,0);
           DelSpaceRight(Input.Godnost);
           Input.Virabotano :=BakGetfield(FVirabotano,E^.Dat.MarketElement[i].BazKod,0);;
           DelSpaceRight(Input.Virabotano);
       End
       Else
        Begin
           {режим автономной накладной}
           Input.NGTD       :=E^.Dat.MarketElement[i].Input.NGTDKod;
           DelSpaceRight(Input.NGTD);
           Input.Expert     :=E^.Dat.MarketElement[i].Input.ExpertKod;
           DelSpaceRight(Input.Expert);
           Input.Marka      :=E^.Dat.MarketElement[i].Input.MarkaKod;
           DelSpaceRight(Input.Marka);
           Input.SpecMarka     :=E^.Dat.MarketElement[i].Input.SMarkaKod;
           DelSpaceRight(Input.SpecMarka);

           If E^.Dat.MarketElement[i].Input.Srok<>-1 Then
           Input.Godnost    :=DateToDateString(DateMask,E^.Dat.MarketElement[i].Input.Srok)
           Else
           Input.Godnost   [0]:=#0;
           DelSpaceRight(Input.Godnost);

           If E^.Dat.MarketElement[i].Input.Virabotano<>-1 Then
           Input.Virabotano :=DateToDateString(DateMask,E^.Dat.MarketElement[i].Input.Virabotano)
           Else
           Input.Virabotano   [0]:=#0;
           DelSpaceRight(Input.Virabotano);
	   End;

           Input.StrihKod   :=BakGetfield(FStrihKod,E^.Dat.MarketElement[i].BazKod,0);
           DelSpaceRight(Input.StrihKod);

        {Input.Proz:=BakGetfield(FProz,E^.Dat.MarketElement[i].BazKod,0);}

        Input.NSertif    :=E^.Dat.MarketElement[i].Input.NSertif;{Это поле указывает на код сертификата}
        Input.Kol:=IntToStr(StrToInt(Input.Kol)+StrToInt(E^.Dat.MarketElement[i].Input.Kol),CKol);
        {Input.Division[E^.Dat.MarketElement[i].Input.DiviSionNumber]:=E^.Dat.MarketElement[i].Input.Kol;}
           {Input.Kol        :=E^.Dat.MarketElement[i].Input.Kol;}
       End
       Else {если не удалось прочитать наименования}
        Begin
         NoInfoMsg;
         Dispose(Exp,Done);
         Dispose(E,Done);
         System.Close(FExp);
         EraseFile(Path^.Dat.ToTemp+GetImportFileName(As,E^.Dat.ClientKod));
         Exit;
        End;
     End;{With Element[i]}
   End;{For}
   End;


   If E^.Dat.Amount>0 Then
   Begin
   For i:=1 To E^.Dat.Amount Do
   Begin
   j:=CalcIndexNSertif(E^.DAt.MarketElement[i].Input.NSertif);

    With NSertif[j] Do
     Begin
      If GetBazElement(E^.DAt.MarketElement[i].Input.NSertif,NSertif[j].Baz) Then
       Begin
        {Baz.Locked:=False;}
        {Baz.Stat:=False;}
        Baz.Employ:=True;
        Employ:=True;
        Baz.BazKod:=E^.Dat.MarketElement[i].Input.NSertif;
      NMakeKod:=BakGetField(FNMakeKod,E^.DAt.MarketElement[i].Input.NSertif,0);
        End
       Else {если не удалось прочитать наименования}
        Begin
         NoInfoMsg;
         Dispose(Exp,Done);
         Dispose(E,Done);
         System.Close(FExp);
         EraseFile(Path^.Dat.ToTemp+GetImportFileName(As,E^.Dat.ClientKod));
         Exit;
        End;
     End;{With Element[i]}
   End;{For}
   End;{E^.Dat.Amount}

   If E^.DAt.Amounts>0 Then
   For i:=1 To E^.Dat.AmountS Do
   Begin
    j:=CalcIndexSertif(E^.DAt.DocumentElement[i].Bazkod);
    With ElementS[j] Do
     Begin
      If GetBazElement(E^.DAt.DocumentElement[i].Bazkod,ElementS[j].Baz) Then
       Begin
        {ElementS[j].Baz.Locked:=False;}
        {ElementS[j].Baz.Stat:=False;}
        ElementS[j].Baz.Employ:=True;
        ElementS[j].Employ:=True;
        ElementS[j].Baz.BazKod:=E^.Dat.DocumentElement[i].BazKod;

           Input.Zakupka     :=E^.Dat.DocumentElement[i].Input.Zakupka;
           Input.Zakupka2    :=E^.Dat.DocumentElement[i].Input.Zakupka2;
           Input.Spec_Zena   :=BakGetfield(FSpecZena,E^.Dat.DocumentElement[i].BazKod,0);
           Input.R_Zena      :=E^.Dat.DocumentElement[i].Input.R_Zena;
           Input.O_Zena      :=E^.Dat.DocumentElement[i].Input.O_Zena;
           Input.NMakeKod    :=E^.Dat.DocumentElement[i].Input.NMakeKod;


       {Input.NGTD      [0] :=#0;
           Input.Post      [0] :=#0;
           Input.Marka     [0] :=#0;
        Input.Virabotano[0] :=#0;
           Input.Godnost   [0] :=#0;
           Input.Akzis1    [0] :=#0;}


           {Input.NSertif  :=Glob.NoSertifStr;}
        Input.Kol:=IntToStr(StrToInt(Input.Kol)+StrToInt(E^.Dat.DocumentElement[i].Input.Kol),CKol);
       End
       Else {если не удалось прочитать наименования}
        Begin
         NoInfoMsg;
         Dispose(Exp,Done);
         Dispose(E,Done);
         System.Close(FExp);
         EraseFile(Path^.Dat.ToTemp+GetImportFileName(As,E^.Dat.ClientKod));
         Exit;
        End;
     End;{With Element[i]}
   End;{For}

   {счетчик товара}
   For i:=1 To CMax Do
   Begin
    If Not(Element[i].Employ) Then Break;
   End;

   If Element[CMax].Employ Then Amount:=CMAx
   Else Amount:=i-1;

   {счетчик сертификатов}
   For i:=1 To CMax Do
   Begin
    If Not(ElementS[i].Employ) Then Break;
   End;

   If ElementS[CMax].Employ Then AmountS:=CMAx
   Else AmountS:=i-1;

   {счетчик ссылок сертификатов}
   For i:=1 To CMax Do
   Begin
    If Not(NSertif[i].Employ) Then Break;
   End;

   If NSertif[CMax].Employ Then AmountNS:=CMAx
   Else AmountNS:=i-1;
  End;{With}

1:
 Ok:=True;
 i:=IOResult;
 Seek(FExp,0);
 Write(FExp,Exp^.Dat);
 i:=IOResult;
 If i<>0 Then
  Begin
   2:
   If MessageBox(#3'Ошибка экспортирования документа! Код:'+IntToStr(i,CLitrMantissa)+'!'^M+
   #3'Повторить попытку?',Nil,mfWarning+mfOkCancel)= cmOk Then
    Begin

 Assign(FExp,Path^.Dat.ToTemp+GetImportFileName(As,E^.Dat.ClientKod));
 I:=IoResult;
 Rewrite(FExp);
 I:=IoResult;
 If I<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+GetImportFileName(As,E^.Dat.ClientKod)+
   '!'+ClicProgrammer^,Nil,mfError+mfCancelButton);
   Goto 2;
  End;
     Goto 1;
    End
    Else Ok:=False;
  End;
 {конец цикла конвертации}
 I:=IoResult;
 System.Close(FExp);
 I:=IoResult;


 {установка статуса экспорта документа}
 If Ok Then Ok:=SetExportStatus(As.EditPosition,As.D,1);

 If Ok Then
 If Not(PackMailFile(GetImportFileName(As,E^.Dat.ClientKod),E^.Dat.ClientKod)) Then
   Begin
    {
    I:=IoResult;
    Rewrite(FExp);
    I:=IoResult;
    Goto 1;
    }ok:=False;
   End;

   Repeat
   Until (UnLockMarket(E^.Dat.Document,E^.Dat.DateC) in [0,2]);

 EraseFile(Path^.Dat.ToTemp+GetImportFileName(As,E^.Dat.ClientKod));

 Dispose(Exp,Done);
 Dispose(E,Done);
 NoInfoMsg;

 If Ok Then
 AddProtocol('Экспорт документа N '+As.EditPosition+' от '+As.D,'','');
 If Ok Then
 MessageBox(^M+#3'Экспорт документа успешно завершен!',Nil,mfInformation+mfCancelButton);

 If Not Ok Then
 Begin
  SpecialBeep;
  MessageBox(^M+#3'Экспорт документа не был произведен! Повторите операцию!',Nil,mfError+mfCancelButton);
 End;

End;





Procedure NetUnLock(Const DocList:PBox);
Var Ass : DocumentEdit;
     s : String;
Begin
If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
Begin
  If Password(2) Then
  Begin
  Ass.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
  Ass.D:=Copy(s,1+CClient+1+CDocNumer+1,CDate);
  {Copy(s,Ord(s[0])-CArtikul-1-CDAte-1-CMantissa,CDate);;}

  {Ass.D:=DocDate;}
  DelSpace(Ass.D);
  Repeat
  Until (UnLockMarket(Ass.EditPosition,Ass.D) in [0,2]);
  MessageBox(^M+#3'Документ N '+Ass.EditPosition+' от '+Ass.D+' '+
  'успешно деблокирован!',Nil,mfInformation+mfCancelButton);
  End;
end;
End;



Procedure ReadRek(Var R:PRekwiziti;Regim:Word;Var Res : LongInt);
Var f : Text;
    SH: TStringHolder;
    Paths : String;
    c : Word;

Function GetAsString(Name:AllStr):String;
Begin
GetAsString[0]:=#0;
GetAsString:=SH.GetString (Name);
End;

Begin
Case regim Of
0:Paths:=Path^.Dat.ToRekwiziti+'Sklad.inf';
1:Paths:=Path^.Dat.ToRekwiziti+'Sklad1.inf';
2:Paths:=Path^.Dat.ToRekwiziti+'Skladc.inf';
Else Exit;
End;

Assign(f,Paths);
Reset(f);
Res := IOResult;
If Res <> 0 Then Exit;
Close(f);
Res := IOResult;
SH.Init;
SH.LoadFromFile (PAths);



R^.Dat.Kod:=GetAsString('PodrazdelenieKod');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.ClientKod:=GetAsString('ClientKod');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.AgentKod:=GetAsString('AgentKod');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.Name:=GetAsString('FullOrganizationName');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.Adress:=GetAsString('Adress');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.AdressCopySertif:=GetAsString('FirstCopyAdress');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.Telefon:=GetAsString('Telefon');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.R_Sh:=GetAsString('R_Sh');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.K_Sh:=GetAsString('K_Sh');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.Gde:=GetAsString('BANK');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.BIK:=GetAsString('BIK');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.Gorod:=GetAsString('Gorod');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.INN:=GetAsString('INN');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.TextMsg_SF:=GetAsString('TextMsg_SF');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.OKONH:=GetAsString('OKONH');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.OKPO:=GetAsString('OKPO');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.AdressGruza:=GetAsString('AdressGruzaOtpravitela');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.LizensiaOptL_V:=GetAsString('LizensiaOptL_V');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.LizensiaOptSig:=GetAsString('LizensiaOptSig');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.LizensiaOptPiv:=GetAsString('LizensiaOptPiv');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.LizensiaRoznL_V:=GetAsString('LizensiaRoznL_V');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.LizensiaRoznSig:=GetAsString('LizensiaRoznSig');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.LizensiaRoznPiv:=GetAsString('LizensiaRoznPiv');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.Organ:=GetAsString('Organ');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.Director:=GetAsString('Director');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.Cladovshik:=GetAsString('Cladovshik');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.Buchgalter:=GetAsString('Buchgalter');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.Kassir:=GetAsString('Kassir');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

R^.Dat.SkladsName:=GetAsString('SkladsName');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

GlobalSkladsName:=GetClientField(FClient,R^.Dat.Kod,1);

DelSpaceRight(GlobalSkladsName);
GlobalSkladsName:=' Склад:'+GlobalSkladsName+'  Дата:'+FDAte+' ';

For c:=1 To CDivision Do
 Begin
  R^.Dat.Otdel[c]:=GetAsString('Otdel['+IntToStr(c,COne)+']');
  If Not Sh.IsOk Then Begin
                       Res:=1;Exit;
                      End;
 End;



Sh.Done;

DeskTop^.Redraw;

If Regim=0 Then GlobalSkladKod:=R^.Dat.Kod;



End;


Procedure WriteRek(Var R:PRekwiziti;Regim:Word;Var Res : LongInt);
Var f,txt : Text;
    paths,comment : string;
    SH: TStringHolder;
    c : Word;

Function GetAsString(Name:AllStr):String;
Begin
GetAsString[0]:=#0;
GetAsString:=SH.GetString (Name);
End;


Begin

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;



Case regim Of
0:Paths:=Path^.Dat.ToRekwiziti+'Sklad.inf';
1:Paths:=Path^.Dat.ToRekwiziti+'Sklad1.inf';
2:Paths:=Path^.Dat.ToRekwiziti+'Skladc.inf';
Else Exit;
End;
Assign(f,Paths);
Rewrite(f);
Res := IOResult;
If Res <> 0 Then Exit;
Close(f);
Res := IOResult;

Assign (txt,'sklad.lng');
Res := IOResult;
Reset(txt);
Res := IOResult;
If Res <> 0 Then
 Begin
  Close(f);
  Exit;
 End;
Close(txt);
Res := IOResult;

SH.Init;
SH.LoadFromFile ('sklad.lng');


Assign (f,Paths);
Rewrite(f);
Res := IOResult;

Comment:=GetAsString('PodrazdelenieKod');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'PodrazdelenieKod=',R^.Dat.Kod);

Comment:=GetAsString('ClientKod');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'ClientKod=',R^.Dat.ClientKod);

Comment:=GetAsString('AgentKod');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'AgentKod=',R^.Dat.AgentKod);

Comment:=GetAsString('FullOrganizationName');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'FullOrganizationName=',R^.Dat.Name);

Comment:=GetAsString('Adress');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Adress=',R^.Dat.Adress);

Comment:=GetAsString('FirstCopyAdress');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'FirstCopyAdress=',R^.Dat.AdressCopySertif);

Comment:=GetAsString('Telefon');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Telefon=',R^.Dat.Telefon);

Comment:=GetAsString('R_Sh');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'R_Sh=',R^.Dat.R_Sh);

Comment:=GetAsString('K_Sh');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'K_Sh=',R^.Dat.K_Sh);

Comment:=GetAsString('BANK');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'BANK=',R^.Dat.Gde);

Comment:=GetAsString('Bik');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Bik=',R^.Dat.Bik);

Comment:=GetAsString('Gorod');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Gorod=',R^.Dat.Gorod);

Comment:=GetAsString('INN');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'INN=',R^.Dat.INN);

Comment:=GetAsString('TextMsg_Sf');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'TextMsg_Sf=',R^.Dat.TextMsg_Sf);

Comment:=GetAsString('OKONH');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'OKONH=',R^.Dat.OKONH);

Comment:=GetAsString('OKPO');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'OKPO=',R^.Dat.OKPO);

Comment:=GetAsString('AdressGruzaOtpravitela');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'AdressGruzaOtpravitela=',R^.Dat.AdressGruza);

Comment:=GetAsString('LizensiaOptL_V');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'LizensiaOptL_V=',R^.Dat.LizensiaOptL_V);

Comment:=GetAsString('LizensiaOptSig');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'LizensiaOptSig=',R^.Dat.LizensiaOptSig);

Comment:=GetAsString('LizensiaOptPiv');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'LizensiaOptPiv=',R^.Dat.LizensiaOptPiv);

Comment:=GetAsString('LizensiaRoznL_V');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'LizensiaRoznL_V=',R^.Dat.LizensiaRoznL_V);

Comment:=GetAsString('LizensiaRoznSig');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'LizensiaRoznSig=',R^.Dat.LizensiaRoznSig);

Comment:=GetAsString('LizensiaRoznPiv');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'LizensiaRoznPiv=',R^.Dat.LizensiaRoznPiv);

Comment:=GetAsString('Organ');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Organ=',R^.Dat.Organ);


Comment:=GetAsString('Director');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Director=',R^.Dat.Director);

Comment:=GetAsString('Cladovshik');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Cladovshik=',R^.Dat.Cladovshik);

Comment:=GetAsString('Buchgalter');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Buchgalter=',R^.Dat.Buchgalter);

Comment:=GetAsString('Kassir');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Kassir=',R^.Dat.Kassir);


Comment:=GetAsString('SkladsName');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'SkladsName=',R^.Dat.SkladsName);

For c:=1 To CDivision Do
Begin
Comment:=GetAsString('Otdel['+IntToStr(c,COne)+']');
If Comment[0]<>#0  Then Writeln(f,';'+Comment);
Writeln(f,'Otdel['+IntToStr(c,COne)+']=',R^.Dat.Otdel[c]);
End;

Close(f);
Res := IOResult;

Sh.Done;

If Regim=0 Then GlobalSkladKod:=R^.Dat.Kod;


DInfoMsg('Реквизиты успешно сохранены!',False);
Delay(1000);
NoInfoMsg;

GlobalSkladsName:=GetClientField(FClient,R^.Dat.Kod,1);
DelSpaceRight(GlobalSkladsName);
GlobalSkladsName:=' Склад:'+GlobalSkladsName+'  Дата:'+FDAte+' ';
DeskTop^.Redraw;
End;



Function FindLastRegim(LinkArt:ArtikulStr;Ck:ArtikulStr;VAr ReturnZena:AllStr):Boolean;
var
  R : TRect;
  ZF : File;
  Z  : PBufLAstClientToVArType;
  cc,Count,C,i : Word;
  s : String;
  Find : Boolean;
  SDateC,SDAte : TDateString;
  CurZena,CurZakupka,
  SRZena,SNazenka,SSkidka,SProz,SZena,SZakupka : String[CZenaZ];
  CurrFull, Full : TMyString;
  SKol : ArtikulStr;
  SNAme : TMyString;
  FantomArt : ArtikulStr;
  Sh : LongInt;
  FantomMain,PrevD : Word;
  NoScreenList : PBox;
begin

FindLastRegim:=False;
ReturnZena[0]:=#0;


If EnableManageZeni=0 Then
 Begin
  ReturnZena:=BakGetField(FRZena,LinkArt,0);
  DelSpace(ReturnZena);
  FindLastRegim:=True;
  Exit;
 End;

FantomArt[0]:=#0;
FantomMain:=StrToInt(GetIdField(FMain,LinkArt));
If FantomMain=0 Then FantomArt:=LinkArt
Else
 Begin
  FantomArt:=GetIdField(FFantomKod,LinkArt);
  RFormatZerro(FantomArt,CArtikul);
 End;





R.Assign(0, 0, 0, 0);
NoScreenList := New(PBox, Init(R, 1, Nil));
NoScreenList^.NewList(New(PTextCollection, Init(0,1)));

Assign(ZF,Path^.Dat.ToClientIndex+ck+'.tlx');
i:=IOResult;
Reset(ZF,SizeOf(LastClientToVarType));
i:=IOResult;
If i=0 Then
Begin
Full:=GetIdField(FFFName,LinkArt);
DelSpaceRight(Full);

CurZena:=BakGetField(FRZena,LinkArt,0);
CurZakupka:=BakGetField(FZakupka,LinkArt,0);

sh:=1;


PrevD:=DistanationSorting;

DistanationSorting:=1;

While Not(Eof(ZF)) Do
 Begin
  DInfoMsgShkala('Просматриваю последние цены по позиции '+LinkArt+'...',0,FileSize(ZF),
  FilePos(ZF));
  New(Z,Init);
  Count:=0;
  BlockRead(ZF,Z^.Point,BufferLAstTovar,Count);


For cc:=1 To Count Do
Begin
 If Z^.Point.Dat[cc].Active Then
 Begin
With Z^.Point.Dat[cc] Do
Begin
   Find:=False;
Begin
 For c:=1 To Amount Do
 Begin
   Find:=False;
{
   If StrToInt(Copy(Element[c].BazKod,1,2))=StrToInt(Copy(LinkArt,1,2)) Then
   Begin
    CurrFull:=GetIdField(FFFNAme,Element[c].BazKod);
    DelSpaceRight(CurrFull);
    If Full=CurrFull Then Find:=True;
   End;
}

   If (StrToInt(Copy(Element[c].BazKod,1,2))=StrToInt(Copy(LinkArt,1,2))) Or
      (StrToInt(Copy(Element[c].BazKod,1,2))=StrToInt(Copy(FantomArt,1,2))) Then
   Begin

   CurrFull:=GetIdField(FFantomKod,Element[c].BazKod);

   If (StrToInt(Element[c].BazKod)=StrToInt(LinkArt)) Or
      (StrToInt(CurrFull)=StrToInt(LinkArt)) Or
      (StrToInt(Element[c].BazKod)=StrToInt(FantomArt)) Or
      (StrToInt(CurrFull)=StrToInt(FantomArt)) Then Find:=True;
   End;



  If Find Then
  Begin
   RFormatZerro(Document,CDocNumer);

   SDate:=IntToStr(Datec,CDAte);
   SDateC:=DateToDateString(DateMask,Datec);
   RFormat(SDate,CDate);

   MyStr(Element[c].Zena,CZena,CMantissa,SZena);
   MyStr(Element[c].RZena,CZena,CMantissa,SRZena);
   MyStr(Element[c].Zakupka,CZenaZ,CMantissaZ,SZakupka);


   {расчет наценки от ЗЦ}
   If Element[c].Zakupka>0.00009 Then
   Begin
     MyStr((Element[c].Zena/Element[c].Zakupka),CZena,CMantissaZ,SNazenka)
   End
    Else SNazenka:='  0.0000';



   {расчет скидки наценки}
   If Element[c].RZena>0.00009 Then
   Begin
   MyStr((Element[c].Zena/Element[c].RZena),CZena,CMantissaZ,SProz);
   End
    Else SProz:='  0.0000';


   {абс велич скидки/наценки}
   MyStr((Element[c].RZena-Element[c].Zena),CZena,CMantissa,SSkidka);


   s:=SDate+'│'+Document+'│'+SDateC+'│'+SZena+'│'+SProz+'│'+SSkidka+'│'+SNazenka+'│'+
   +IntToStr(sh,CKOl);

   Inc(Sh,1);

   NoScreenList^.List^.Insert(NewStr(s));
   NoScreenList^.SetRange(NoScreenList^.List^.Count);
  End;{find}
 End;{For по товару}
End;

 End;{With}

End;{If Active=0}
End;{For}
  Dispose(Z,Done);
End;{While}
System.Close(ZF);
i:=IOResult;

DistanationSorting:=PrevD;

End;{i=0 открытие прошло нормально}

NoInfoMsg;


i:=IOResult;
System.Close(ZF);
i:=IOResult;
NoScreenList^.FocusItem(0);
{закончили чтение статистики}


 If NoScreenList^.List^.Count-1>=0 Then
  Begin
   s:=NoScreenList^.GetText(0,NoScreenList^.List^.Count);
   System.Delete(s,1,CDate);

   Case EnableManageZeni Of
    {цена оплаты}
   1:Begin
     ReturnZena:=Copy(s,1+1+CDocNumer+1+CDate+1,CZena);
     DelSpace(ReturnZena);
     FindLastRegim:=True;
     End;
   2:Begin{% скидки наценки}
     ReturnZena:=Copy(s,1+1+CDocNumer+1+CDate+1+CZena+1,CZena);
     If Abs(StrToReal(ReturnZena))>0.009 Then
      Begin
       MyStr(StrToReal(CurZena)*StrToReal(ReturnZena),CZena,CMantissa,ReturnZena);
      End
      Else ReturnZena:=CurZena;

     DelSpace(ReturnZena);
     FindLastRegim:=True;
     End;
   3:Begin{абс.значение скидки наценки}
     ReturnZena:=Copy(s,1+1+CDocNumer+1+CDate+1+CZena+1+
	CZena+1,CZena);
     MyStr(StrToReal(CurZena)-StrToReal(ReturnZena),CZena,CMantissa,ReturnZena);
     DelSpace(ReturnZena);
     FindLastRegim:=True;
     End;
   4:Begin{% наценки от ЗЦ}
     ReturnZena:=Copy(s,1+1+CDocNumer+1+CDate+1+CZena+1+CZena+1+CZena+1,CZena);
     If Abs(StrToReal(ReturnZena))>0.009 Then
      Begin
       MyStr(StrToReal(CurZakupka)*StrToReal(ReturnZena),CZena,CMantissa,ReturnZena);
      End
      Else ReturnZena:=CurZena;

     FindLastRegim:=True;
     DelSpace(ReturnZena);
     End;
   Else Begin
         ReturnZena:=CurZena;
         DelSpace(ReturnZena);
         FindLastRegim:=True;
        End;
   End;
  End;

Dispose(NoScreenList,Done);

End;

End.