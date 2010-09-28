{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit ViewMrk;

Interface

Uses Dialogs,Glob,CorMrk,ServStr,Drivers,
     MyCalc,FindPrh;

Type PLocalInfoDynamicDebit =^TLocalInfoDynamicDebit;
    TLocalInfoDynamicDebit = object(TDialog)
    Calc        : PMyCalculator;
    procedure LockPrintReport;
    Procedure LockStart(S:String;Clientkod:ArtikulStr);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure LockFreshRashetHint;
    Destructor Done;virtual;
  end;



Type
  PFullScreenMrk = ^TFullScreenMrk;
  TFullScreenMrk = object(TDialog)
        Calc        : PMyCalculator;
     LockInfo    : PLocalInfoDynamicDebit;
    CMrk     : PCorrectMarket;
      Numer      : ArtikulStr;
      Date       : TDateString;
      Kto        : ArtikulStr;
      DocSelector: Word;
 OperatorSelector: Word;
      ZakazField : Boolean;
      FP         : PFindPrh;
      Function FullScreenMrk(Ass:DocumentEditZ;Zakaz:Boolean):Boolean;
      procedure CalcItogo;
      procedure DrawCurrent(s: String);
      procedure Refresh;
      procedure RefreshNakl;
      procedure HandleEvent(var Event: TEvent); virtual;
      Destructor Done;Virtual;
  end;

implementation


Uses app,MsgBox,Objects,TpDate,Editors,Vision4,ColorTxt,Access,
  Utils3,Utils1,Vision8,Access1,DbEngine,DbEngin3,NetCall,Views,Printers,
  Serv,ServStr2,Utils;


Const StartPos= 1+CArtikul+1+CName+1+COne+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+(CName+1+CName)+COne+CZenaZ+CZenaZ;

Var FullScr : PFullScreenMrk;
    ControlFull : PBox;
    MrkWin :PFullScreenMrk;
    ControlHeader,ControlOtobragenie : PView;
    ControlNGTD,ControlMarka,ControlVirabotano,ControlDo,
    ControlRegionMarka,ControlShowReturn,
    ControlAkzisSbor,
    ControlZenaMarki,
    ControlFullNAme,ControlFullSertif,
    ControlMsg,ControlR,ControlRz,ControlText,ControlCl,Control : PView;
    CurrentLine : String;
    VidSkidki : AllStr;
    ReturnCount : Word;
    ControlInfo,ControlCount,ControlSelector,ControlVidOtbora : PView;
    VidOtbora,VidProsmotra,Otobragenie,ShowOnlyReturn : Word;
    LinkList,NoScreenList1: PBox;
    Filtr : Maska2;
    AllLitr,LitrT,LitrS : Real;
    LocalInfo :PLocalInfoDynamicDebit;
    LocalDolgList: PBox;

     ControlReturn,ControlVid,ControlKassa,ControlClient,ControlBank,ControlPP,ControlRashet,ControlSummaPP,ControlDatePP,
     ControlPrim,ControlPassword  : PView;
     ControlClientLock : PView;
     PrevS,PrevSLock : TEnjoyStr;
     PrevDoc:ArtikulStr;
     PrevDate :TDateString;
     PrevCurrent : TMyString;



Function TFullScreenMrk.FullScreenMrk(Ass:DocumentEditZ;Zakaz:Boolean):Boolean;
var
  R : TRect;
  ws,s,s1,St,s2 : String;
  AgName,ClName : AllStr;
  c,i : Word;
  ff,ff1,ff2 : String;
  F : MArketFileType;
  E :PSuperMarketType;
  E1 :PZakazType;
  Find:Boolean;
    SKolish,SDoc,SClientKod,SAgentKod : ArtikulStr;
    SCommentr : String;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];
    Res : Word;
    P : PCommentClientType;
    DDD3,DDD4,DDD,DDD2,Status : AllStr;
    Color : Word;
    AssZ:DocumentEditZ;
    L : PZakazType;
    BArter : AllStr;
    PZNumer : LongInt;

begin
  FullScreenMrk:=False;


  Find := False;

  DInfoMsg('Ищу документ...',True);
  New(E,Init);

  ClearChar(Ass.EditPosition);
  DelSpace(Ass.D);

  AssZ.EditPosition:=Ass.EditPosition;
  AssZ.D:=Ass.D;

  PZNumer:=0;

  If Not Zakaz Then
  Find:=GetMarket1(Assz,E)
  Else
   Begin
    New(L,Init);
    Find:=GetZakaz(AssZ.EditPosition,L);
    ZakazToMArket(E,L);
    E^.DAt.Caption:=L^.Dat.Caption;

    If L^.Dat.Status=1 Then
    PZNumer:=L^.Dat.PredZakazNumer
    Else
    PZNumer:=0;


    AssZ.EditPosition:=L^.DAt.Document;
    AssZ.D:=L^.DAt.DateC;
    Ass.EditPosition:=L^.DAt.Document;
    Ass.D:=L^.DAt.DateC;

    DelSpace(L^.Dat.DocDate);
    DelSpace(L^.Dat.DocReal);
    DDD3[0]:=#0;
    DDD4[0]:=#0;
    CAse L^.Dat.Oformlenie Of
    1:DDD3:='Оформлен N'+L^.Dat.DocReal+' от '+L^.Dat.DocDate;
    0:DDD3:='Не оформлен до:'+DAteToDateString(DAteMask,
     DateStringToDate(DateMAsk,L^.DAt.DateC)+L^.Dat.EndDate);
    2:DDD3:='Анулирован'
    Else;
    End;
    Dispose(L,Done);
   End;


(*
  Find := False;


{оптимизация поиск}
   If FileSize(f)>=(StrToInt(Ass.EditPosition)-1) Then
    Begin
     Seek(f,StrToInt(Ass.EditPosition)-1);
     ReadMarket(F,E);
     DelSpace(E^.DAt.Document);
     DelZerro(E^.Dat.Document);
     ClearChar(E^.Dat.Document);
     If (E^.Dat.Active) And (E^.Dat.DateC=Ass.D) and
     (StrToInt(E^.Dat.Document)=StrToInt(Ass.EditPosition)) Then
            Begin
             Find:=True;
         End
         Else Seek(F,0);
    End;




  While Not(Eof(f)) And Not(Find) Do
   Begin
    ReadMarket(F,E);
    ClearChar(E^.Dat.Document);
    If (E^.Dat.Active) And (E^.Dat.DateC=Ass.D) and
    (StrToInt(E^.Dat.Document)=StrToInt(Ass.EditPosition)) Then
          Begin
           Find:=True;
           Break;
          End;
   End;
   System.Close(f);
*)


   NoInfoMsg;



If Not Find Then
  Begin
   Dispose(E,Done);
   NoInfoMsg;
   (*MessageBox(#3^M+#3'Искомый документ не найден!',Nil,mfError+mfCancelButton);*)
   Exit;
  End;

DInfoMsg('Формирую документы...',True);
ClearFind;
ProdagaWindow:=False;


{Формируем список позиций в перемешку товар и сертификаты}
  R.Assign(0,0,0,0);
  NoScreenList1 := New(PBox, Init(R, 1, Nil));
  NoScreenList1^.NewList(New(PTextCollection, Init(0,1)));
(*
{вставляем в список товары}
For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.MarketElement[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,CName);
  s:=s+'│'+ws+'│';
  Str(E^.Dat.MarketElement[c].Input.DivisionNumber:1,ws);
  s:=s+ws;



  DelSpace(E^.Dat.MarketElement[c].Input.Kol);
  RFormat(E^.Dat.MarketElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Kol;
  {  ws:=GetIdField(FLitr,E^.Dat.MarketElement[c].BazKod);
  Format(Ws,CLitr);
  s:=s+'│'+ws;}
  DelSpace(E^.Dat.MarketElement[c].Input.Zena);
  RFormat(E^.Dat.MarketElement[c].Input.Zena,CZena);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Zena;

        Case E^.Dat.SkidkaSelector Of
      0:Begin{скидка автоматическая}
         MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
         (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100),CZena,CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         {форматируем прценты}
         MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Proz),CZena,CMantissa,ws1);
         MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Skidka),CZena,CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         MyStr((StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
        (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100)),CZena,CMantissa,wspomSkidka);

         S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      1:Begin{скидка ручная}
          If StrToReal(E^.Dat.MarketElement[c].Input.Skidka)>=0 Then
          Begin
          If (StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka))>0.009 Then
          MyStr(((StrToReal(E^.Dat.MarketElement[c].Input.Zena))/((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
          StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))-1)*100
          ,CZena,CLitrMantissa,ws1)
          Else ws1:='100.00';
          MyStr(StrToReal(Ws1),CZena,CMantissa,ws1);
           End
           Else
             Begin
              MyStr((-(Abs(StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))/
              ((StrToReal(E^.Dat.MarketElement[c].Input.Zena)))*100),CZena,CMantissa,Ws1);
             End;

          MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Skidka),CZena,CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

          MyStr((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka))
          ,CZena,CMantissa,wspomSkidka);

          S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      Else;
      End;{E^.Dat.SkidkaSelector}

  SKolish[0]:=#0;
  SCommentr[0]:=#0;
  CalcReturnPosition(E^.Dat.Document,E^.Dat.DateC,E^.Dat.ClientKod,E^.Dat.MarketElement[c].BazKod,
  IntToStr(E^.Dat.MarketElement[c].Input.DivisionNumber,COne),E^.Dat.OperatorSelector,Skolish,SCommentr);
  Format(SKolish,CKol);
  s:=s+SKolish+'│'+sCommentr;
  NoScreenList1^.List^.Insert(NewStr(s));
  NoScreenList1^.SetRange(NoScreenList1^.List^.Count);
 End;


{вставляем в список сертификаты}
For c:=1 To E^.Dat.AmountS Do
 Begin
  S:=E^.Dat.DocumentElement[c].BazKod;
  ws:=GetIdField(FName,s);
  ws:='■'+ws;
  Format(ws,CName);
  s:=s+'│'+ws+'│';
  Str(E^.Dat.DocumentElement[c].Input.DivisionNumber:1,ws);
  s:=s+ws;



  DelSpace(E^.Dat.DocumentElement[c].Input.Kol);
  RFormat(E^.Dat.DocumentElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.DocumentElement[c].Input.Kol;
  {  ws:=GetIdField(FLitr,E^.Dat.DocumentElement[c].BazKod);
  Format(Ws,CLitr);
  s:=s+'│'+ws;}
  DelSpace(E^.Dat.DocumentElement[c].Input.Zena);
  RFormat(E^.Dat.DocumentElement[c].Input.Zena,CZena);
  s:=s+'│'+E^.Dat.DocumentElement[c].Input.Zena;

        Case E^.Dat.SkidkaSelector Of
      0:Begin{скидка автоматическая}
         MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Zena)-StrToReal(E^.Dat.DocumentElement[c].Input.Zena)/
         (1+StrToReal(E^.Dat.DocumentElement[c].Input.Proz)/100),CZena,CMantissa,E^.Dat.DocumentElement[c].Input.Skidka);

         {форматируем прценты}
         MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Proz),CZena,CMantissa,ws1);
         MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Skidka),CZena,CMantissa,E^.Dat.DocumentElement[c].Input.Skidka);

         MyStr((StrToReal(E^.Dat.DocumentElement[c].Input.Zena)/
        (1+StrToReal(E^.Dat.DocumentElement[c].Input.Proz)/100)),CZena,CMantissa,wspomSkidka);

         S:=s+'│'+WspomSkidka+'║'+E^.Dat.DocumentElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      1:Begin{скидка ручная}
          If StrToReal(E^.Dat.DocumentElement[c].Input.Skidka)>=0 Then
          Begin
          If (StrToReal(E^.Dat.DocumentElement[c].Input.Zena)-StrToReal(E^.Dat.DocumentElement[c].Input.Skidka))>0.009 Then
          MyStr(((StrToReal(E^.Dat.DocumentElement[c].Input.Zena))/((StrToReal(E^.Dat.DocumentElement[c].Input.Zena)-
          StrToReal(E^.Dat.DocumentElement[c].Input.Skidka)))-1)*100
          ,CZena,CLitrMantissa,ws1)
          Else ws1:='100.00';
          MyStr(StrToReal(Ws1),CZena,CMantissa,ws1);
           End
           Else
             Begin
              MyStr((-(Abs(StrToReal(E^.Dat.DocumentElement[c].Input.Skidka)))/
              ((StrToReal(E^.Dat.DocumentElement[c].Input.Zena)))*100),CZena,CMantissa,Ws1);
             End;

          MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Skidka),CZena,CMantissa,E^.Dat.DocumentElement[c].Input.Skidka);

          MyStr((StrToReal(E^.Dat.DocumentElement[c].Input.Zena)-StrToReal(E^.Dat.DocumentElement[c].Input.Skidka))
          ,CZena,CMantissa,wspomSkidka);

          S:=s+'│'+WspomSkidka+'║'+E^.Dat.DocumentElement[c].Input.Skidka+'│'+ws1+'║';
        End;
      Else;
      End;{E^.Dat.SkidkaSelector}

  SKolish[0]:=#0;
  SCommentr[0]:=#0;
  Format(SKolish,CKol);
  s:=s+SKolish+'│'+sCommentr;
  NoScreenList1^.List^.Insert(NewStr(s));
  NoScreenList1^.SetRange(NoScreenList1^.List^.Count);
 End;
*)

Case E^.Dat.SkidkaSelector Of
0:Vidskidki:='(Авто)';
1:Vidskidki:='(Ручная)';
2:Vidskidki:='(Шкала)';
Else Vidskidki:='???';
End;


R.Assign(0, 0, 80, 23);
New(MrkWin, Init(R, 'Просмотр отгрузки'));
MrkWin^.HelpCtx:={E091}{E556}$F421{F222};


R.Assign(1, 1, 8, 2);
Control := New(PColoredText, Init(R, 'Клиент:', $74));
MrkWin^.Insert(Control);


MrkWin^.Kto:=E^.Dat.ClientKod;
MrkWin^.DocSelector:=E^.Dat.DocSelector;
MrkWin^.OperatorSelector:=E^.Dat.OperatorSelector;
MrkWin^.ZakazField:=Zakaz;



ClName:=GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format(ClName,CClient);
R.Assign(8, 1, 35, 2);
Control := New(PColoredText, Init(R, #3+ClName+'│'+E^.Dat.ClientKod, $1F));
MrkWin^.Insert(Control);

AgName:=GetAgentField(FAgent,E^.Dat.AgentKod);
Format(AgName,CClient);
R.Assign(37, 1, 64, 2);
Control := New(PColoredText, Init(R, #3+AgName+'│'+E^.Dat.AgentKod, $1F));
MrkWin^.Insert(Control);


R.Assign(65, 1, 73, 2);
ControlRZ := New(PColoredText, Init(R, 'Возврат:', $77{74}));
MrkWin^.Insert(ControlRZ);

R.Assign(73, 1, 78, 2);
ControlR := New(PColoredText, Init(R, #3+'', $77{1f}));
MrkWin^.Insert(ControlR);

R.Assign(1, 2, 79, 2);
ControlText := New(PColoredText, Init(R, #3+'', $5E));
MrkWin^.Insert(ControlText);


R.Assign(1, 3, 8, 4);
Control := New(PColoredText, Init(R, 'Статус:', $74));
MrkWin^.Insert(Control);

Status[0]:=#0;
DDD[0]:=#0;
DDD2[0]:=#0;
Color:=$7E;
If Not MrkWin^.ZakazField Then
Begin
Case E^.Dat.DocSelector Of
0..4:Begin
      Status:='Оплачен';
      DDD[0]:=#0;
      DDD2[0]:=#0;
     End;
5..8:Begin
      Status:=TestDolgOplata(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC);
      If Abs(StrToReal(Status))<0.009 Then Status:='Оплачен'
      Else
          Begin
        {Color:=$5e;}
        DelSpace(Status);
        DDD:=DateToDateString(DateMask,E^.Dat.Srok);
        DDD:=' до '+DDD;
        DDD2[0]:=#0;
       End;
     End;
Else;
End;
End
 Else
Begin
  Status:=DDD3;
  DDD[0]:=#0;
  DDD2[0]:=#0;
End;


If MrkWin^.ZakazField Then
If PzNumer>0 Then
 Begin
  R.Assign(67, 18, 79, 19);
  Control := New(PColoredText, Init(R, ' ПЗ N '+IntToStr(PZNumer,CArtikul), $5E));
  MrkWin^.Insert(Control);
 End;


R.Assign(8, 3, 36, 4);
Control := New(PColoredText, Init(R, Status+DDD+DDD2 {'Не оплачен до: 25-06-00'}, Color));
MrkWin^.Insert(Control);

Otobragenie:=0;
ShowOnlyReturn:=0;



R.Assign(34, 3, 79, 4);
ControlOtobragenie := New(PRadioButtons, Init(R,
  NewSItem('~С~тандартный',
  NewSItem('Дополн.~1~',
  NewSItem('Дополн.~2~',
  Nil)))));

If Not (StrToInt(CurrentPassword)in[0]) and Not({FindParam('/EZ')}(EnableZakupka=1)) Then
ControlOtobragenie^.Options := ControlOtobragenie^.Options and not ofSelectable;

ControlOtobragenie^.SetData(Otobragenie);
MrkWin^.Insert(ControlOtobragenie);

R.Assign(79, 5, 80, 15);
Control := New(PScrollBar, Init(R));
MrkWin^.Insert(Control);


ReturnCount:=0;

R.Assign(1, 5, 79, 15);
ControlFull := New(PBox, Init(R, 1, PScrollbar(Control)));
ControlFull^.NewList(New(PTextCollection, Init(0,1)));

If (NoScreenList1^.List^.Count-1)>=0 Then
For i:=0 To NoScreenList1^.List^.Count-1 Do
 Begin
  st :=NoScreenList1^.GetText(i,NoScreenList1^.List^.Count);
  s2:=Copy(st,StartPos,CKol);

  If StrToInt(s2)>0 Then Inc(ReturnCount);

  ControlFull^.List^.Insert(NewStr(St));
  ControlFull^.SetRange(ControlFull^.List^.Count);
 End;

(*ControlFull^.HelpCtx:={E091}$E556;*)

ControlFull^.FocusItem(0);

MrkWin^.Insert(ControlFull);





  R.Assign(35, 4, 79, 5);
  ControlHeader := New(PColoredText, Init(R,
  'N Колич Цена лоб Цена опл  Скидка   Процент', $7F));
  MrkWin^.Insert(ControlHeader);

R.Assign(1, 4, 8, 5);
Control := New(PColoredText, Init(R, 'Экспед:', $74));
MrkWin^.Insert(Control);

AgName:=GetEkspedField(FEksped,E^.Dat.EkspeditorKod);
Format(AgName,CClient);
R.Assign(8, 4, 35, 5);
Control := New(PColoredText, Init(R, #3+AgName+'│'+E^.Dat.EkspeditorKod, $1F));
MrkWin^.Insert(Control);


{
  MrkWin^.Insert(New(PLabel, Init(R,
  ' Код  Выбранн~ы~е товары           N Колич Цена лоб Цена опл  Скидка   Процент', ControlFull)));
}

R.Assign(1, 16, 57, 17);
ControlFullNAme := New(PColoredText, Init(R, #3+'', $7e));
MrkWin^.Insert(ControlFullNAme);

R.Assign(1, 15, 57, 16);
ControlFullSertif := New(PColoredText, Init(R, #3+'', $7e));
MrkWin^.Insert(ControlFullSertif);


R.Assign(59, 16, 79, 17);
ControlShowReturn := New(PCheckboxes, Init(R,
  NewSItem('С во~з~вратом', Nil)));

ControlShowReturn^.SetData(ShowOnlyReturn);

MrkWin^.Insert(ControlShowReturn);


Str(ControlFull^.List^.Count:CMantissa,st);
R.Assign(53, 0, 71, 1);
ControlCount := New(PColoredText, Init(R, 'Всего позиций:'+st, $4E));
MrkWin^.Insert(ControlCount);






R.Assign(13, 17, 23, 18);
ControlAkzisSbor := New(PColoredText, Init(R, #3'???', $7E));
MrkWin^.Insert(ControlAkzisSbor);

R.Assign(2, 17, 13, 18);
Control := New(PColoredText, Init(R, 'Акциз.сбор:', $74));
MrkWin^.Insert(Control);

R.Assign(25, 17, 36, 18);
Control := New(PColoredText, Init(R, 'Цена марки:', $74));
MrkWin^.Insert(Control);

R.Assign(36, 17, 46, 18);
ControlZenaMarki := New(PColoredText, Init(R, #3'???', $7E));
MrkWin^.Insert(ControlZenaMarki);



R.Assign(48, 17, 54, 18);
Control := New(PColoredText, Init(R, 'Марка:', $74));
MrkWin^.Insert(Control);

 R.Assign(54, 17, 59, 18);
 ControlRegionMarka := New(PColoredText, Init(R, #3+'', $5F));
 MrkWin^.Insert(ControlRegionMarka);

st:=IntToStr(E^.Dat.DocSelector,CMAntissa);

RFormatZerro(St,CMAntissa);

If E^.DAt.Rashet=2 Then
 st:=st+'-В';

R.Assign(73, 0, 79, 1);
Control := New(PColoredText, Init(R, #3+'('+st+')', $4E));
MrkWin^.Insert(Control);


If Not MrkWin^.ZakazField Then
Begin
If ReturnCount>0 Then
Begin
R.Assign(26, 2, 52, 3);
ControlMsg := New(PColoredText, Init(R, #3' Возрат по '+InttoStr(ReturnCount,CMantissa)+' позиции(ям)', $5E));
ControlMsg^.Options := ControlMsg^.Options or ofCenterX;
End
Else
Begin
R.Assign(26, 2, 52, 3);
ControlMsg := New(PColoredText, Init(R, #3+' Возратов не было !!!', $5E));
ControlMsg^.Options := ControlMsg^.Options or ofCenterX;
End;
End
Else
Begin
R.Assign(26, 2, 52, 3);
ControlMsg := New(PColoredText, Init(R, #3+' Возратов не было !!!', $5E));
ControlMsg^.Options := ControlMsg^.Options or ofCenterX;
End;


MrkWin^.Insert(ControlMsg);


DelZerro(Ass.EditPosition);
R.Assign(1, 0, 29, 1);
MrkWin^.Numer:=Ass.EditPosition;
MrkWin^.Date:=Ass.D;


BArter[0]:=#0;
If E^.DAt.OperatorSelector=2 Then Barter:='-Б';

If Not MrkWin^.ZakazField Then
Control := New(PColoredText, Init(R, 'Документ:'+Ass.EditPosition+BArter+' от '+Ass.D, $4E))
Else
Control := New(PColoredText, Init(R, 'Заказ:'+Ass.EditPosition+BArter+' от '+Ass.D, $4E));

MrkWin^.Insert(Control);

s1:='???';
R.Assign(1, 22, 2+Ord(s1[0]), 23);
ControlInfo := New(PColoredText, Init(R, #3+S1, $4E));
ControlInfo^.Options := ControlInfo^.Options or ofCenterX;
MrkWin^.Insert(ControlInfo);

Filtr[1]:=1;
Filtr[2]:=1;

BitToWord2(Filtr,VidProsmotra);
Convert2(Filtr);

{R.Assign(57, 21, 79, 22);}
R.Assign(59, 17, 79, 18);
ControlSelector := New(PCheckboxes, Init(R,
  NewSItem('~Т~овар',
  NewSItem('~Д~ок.', Nil))));
ControlSelector^.SetData(VidProsmotra);
MrkWin^.Insert(ControlSelector);

New(p,Init);
GetClientCommentNumer(P,E^.Dat.DocumentComment,Res,E^.Dat.ClientKod,E^.Dat.OperatorSelector);

If StrToInt(CurrentPassword)=0 Then
Begin
R.Assign(39, 19, 40, 22);
Control := New(PScrollBar, Init(R));
MrkWin^.Insert(Control);

R.Assign(1, 19, 39, 22);
Control := New(PMemo, Init(R, Nil, PScrollbar(Control), Nil, CMaxMemo,True));
Control^.Options := Control^.Options or ofFramed;
Control^.SetData(P^.Dat.Memo);
MrkWin^.Insert(Control);

  R.Assign(1, 18, 14, 19);
  MrkWin^.Insert(New(PLabel, Init(R, 'Комментарий:', Control)));
End;

R.Assign(79, 19, 80, 22);
Control := New(PScrollBar, Init(R));
MrkWin^.Insert(Control);

If StrToInt(CurrentPassword)=0 Then R.Assign(40, 19, 79, 22)
Else R.Assign(1, 19, 79, 22);
Control := New(PMemo, Init(R, Nil, PScrollbar(Control), Nil, CMaxMemo,True));
Control^.Options := Control^.Options or ofFramed;
P^.Dat.Memo1.Length:=Length(E^.DAt.Comment1)+1+Length(E^.DAt.Comment2);

For c := 0 To Length(E^.DAt.Comment1) Do P^.Dat.Memo1.buffer[c]:=E^.DAt.Comment1[c+1];

P^.Dat.Memo1.buffer[c+1]:=#12;

For c := 0 To Length(E^.DAt.Comment2) Do
P^.Dat.Memo1.buffer[c+Length(E^.DAt.Comment1)+1]:=E^.DAt.Comment2[c+1];


Control^.SetData(P^.Dat.Memo1);
MrkWin^.Insert(Control);


If StrToInt(CurrentPassword)=0 Then R.Assign(40, 18, 55, 19)
Else R.Assign(1, 18, 16, 19);
  MrkWin^.Insert(New(PLabel, Init(R, 'Для оператора:', Control)));


Dispose(P,Done);

If StrToInt(CurrentPassword)=0 Then R.Assign(55, 18, 67, 19)
Else R.Assign(16, 18, 28, 19);
Control := New(PColoredText, Init(R, #3+GetOperatorField(FNAme,E^.DAt.Caption), $4E));
MrkWin^.Insert(Control);


Dispose(E,Done);


MrkWin^.SelectNext(False);

If (StrToInt(CurrentPassword)=0) Or ({FindParam('/EZ')}(EnableZakupka=1)) Then
MrkWin^.SelectNext(False);



CurrentLine[0]:=#0;



RefreshNakl;

Refresh;

CalcItogo;

NoInfoMsg;

i := Desktop^.ExecView(MrkWin);
ProdagaWindow:=False;
ClearFind;
If i=cmOk Then FullScreenMrk:=True;

Dispose(Control,Done);
{Dispose(ControlSelector,Done);
Dispose(ControlCount,Done);
Dispose(ControlInfo,Done);}
Dispose(MrkWin,Done);
Dispose(NoScreenList1,Done);

CurrentLine[0]:=#0;

end;



Procedure TFullScreenMrk.RefreshNAkl;
var
  ws,s,s1,St,s2 : String;
  c,i : Word;
  ff,ff1,ff2 : String;
  F : MArketFileType;
  E :PSuperMarketType;
  Find:Boolean;
    SKolish,SDoc,SClientKod,SAgentKod : ArtikulStr;
    SCommentr : String;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];
    Res : Word;
    P : PCommentClientType;
    DDD,DDD2,Status : AllStr;
    Color : Word;
    R : TRect;
    WspomProz : ArtikulStr;
    As : DocumentEditZ;
    L :PZakazType;
    SSS,SFullName : String[CName+1+CName];
    Koefficient : TDateString;
Begin

(*Assign(f,Path^.Dat.ToMarket+MrkWin^.Date+'.mrk');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
  Begin
   MessageBox(#3^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToMarket+MrkWin^.Date+'.mrk',Nil,mfError+mfCancelButton);
   Exit;
  End;*)

  Find := False;
  LitrT:=0.00;
  LitrS:=0.00;

  DInfoMsg('Ищу документ...',True);

  ClearChar(MrkWin^.Numer);
  DelSpace(MrkWin^.Numer);

  As.EditPosition:=MrkWin^.Numer;
  As.D:=MrkWin^.Date;

  New(E,Init);

  If Not MrkWin^.ZakazField Then
  Find := GetMArket1(As,E)
  Else
   Begin
    New(L,Init);
    Find:=GetZakaz(As.EditPosition,L);
    ZakazToMArket(E,L);
    Dispose(L,Done);
   End;






   NoInfoMsg;

If Not Find Then
  Begin
   Dispose(E,Done);
   NoInfoMsg;
   Exit;
  End;

DInfoMsg('Формирую документы...',True);
ClearFind;
ProdagaWindow:=False;

{Формируем список позиций в перемешку товар и сертификаты}
  NoScreenList1^.NewList(Nil);
  NoScreenList1^.NewList(New(PTextCollection, Init(0,1)));





{вставляем в список товары}
For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.MarketElement[c].BazKod;
  LitrT:=LitrT+StrToReal(GetIdField(FLitr,E^.Dat.MarketElement[c].BazKod))*StrToInt
  (E^.Dat.MarketElement[c].Input.Kol);
  SFullNAme:=GetIdField(FFFName,s);
  Format(SFullNAme,CNAme+1+CNAme);
  ws:=Copy(SFullNAme,1,CName);
  DelSpaceRight(ws);
  Format(ws,CName);
  s:=ws+'│'+s+'│';
  Str(E^.Dat.MarketElement[c].Input.DivisionNumber:1,ws);
  s:=s+ws;

  DelSpace(E^.Dat.MarketElement[c].Input.Kol);
  RFormat(E^.Dat.MarketElement[c].Input.Kol,CKol);

  If (ShowOnlyReturn=1) Then
  If Not(MrkWin^.ZakazField) Then
  begin
  CalcReturnPosition(E^.Dat.Document,E^.Dat.DateC,E^.Dat.ClientKod,E^.Dat.MarketElement[c].BazKod,
  IntToStr(E^.Dat.MarketElement[c].Input.DivisionNumber,COne),E^.Dat.OperatorSelector,Skolish,SCommentr);
  Str(StrToInt(E^.Dat.MarketElement[c].Input.Kol)-StrToInt(Skolish):CKOl,
  E^.Dat.MarketElement[c].Input.Kol);
  end;



If StrToInt(E^.Dat.MarketElement[c].Input.Kol)>0 Then
Begin

  s:=s+'│'+E^.Dat.MarketElement[c].Input.Kol;

       If E^.DAt.DocSelector in [{1,}2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(e^.dat.marketelement[c].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);

       {новая цена}

{$IFDEF NSP}
       MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena),CZena,CMantissa,
          E^.Dat.MarketElement[c].Input.Zena);
{$ELSE}
       MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena)*StrToReal(Koefficient),CZena,CMantissa,
          E^.Dat.MarketElement[c].Input.Zena);
{$ENDIF}
       End;

  {ws:=GetIdField(FLitr,E^.Dat.MarketElement[c].BazKod);
  Format(Ws,CLitr);
  s:=s+'│'+ws;}

Case Otobragenie Of
0:Begin
   MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena),CZena,CMantissa,E^.Dat.MarketElement[c].Input.Zakupka);
   DelSpace(E^.Dat.MarketElement[c].Input.Zena);
   RFormat(E^.Dat.MarketElement[c].Input.Zena,CZena);
   s:=s+'│'+E^.Dat.MarketElement[c].Input.Zena;
  End;{0}
1:Begin
   MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zakupka),CZenaZ,CMantissaZ,E^.Dat.MarketElement[c].Input.Zakupka);
   DelSpace(E^.Dat.MarketElement[c].Input.Zakupka);
   RFormat(E^.Dat.MarketElement[c].Input.Zakupka,CZenaZ);
   s:=s+'│'+E^.Dat.MarketElement[c].Input.Zakupka;
  End;{1}
Else
 Begin
   MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zakupka2),CZenaZ,CMantissaZ,E^.Dat.MarketElement[c].Input.Zakupka2);
   DelSpace(E^.Dat.MarketElement[c].Input.Zakupka2);
   RFormat(E^.Dat.MarketElement[c].Input.Zakupka2,CZenaZ);
   s:=s+'│'+E^.Dat.MarketElement[c].Input.Zakupka2;
 End;{Else}
End;{CAse}

{ If Otobragenie=0 Then
  Begin
  MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena),CZena,CMantissa,E^.Dat.MarketElement[c].Input.Zakupka);
  DelSpace(E^.Dat.MarketElement[c].Input.Zena);
  RFormat(E^.Dat.MarketElement[c].Input.Zena,CZena);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Zena;
  End
  Else
  Begin
  MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zakupka),CZenaZ,CMantissaZ,E^.Dat.MarketElement[c].Input.Zakupka);
  DelSpace(E^.Dat.MarketElement[c].Input.Zakupka);
  RFormat(E^.Dat.MarketElement[c].Input.Zakupka,CZenaZ);
  s:=s+'│'+E^.Dat.MarketElement[c].Input.Zakupka;
  End;}


        Case E^.Dat.SkidkaSelector Of
      0:Begin{скидка автоматическая}
         MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
         (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100),CZena,CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         {форматируем проценты}
         MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Proz),CZena,CMantissa,ws1);
         MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Skidka),CZena,CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

         MyStr((StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
        (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100)),CZena,CMantissa,wspomSkidka);

         Case Otobragenie Of
         0:Begin
            S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║'
           End;
         1:Begin
            S:=s+'│'+WspomSkidka+'║';
            {добавили доходность}
            MyStr(StrToREal(WspomSkidka)-StrToReal(E^.Dat.MarketElement[c].Input.Zakupka)-
                  StrToReal(E^.Dat.MarketElement[c].Input.AkzisSbor),CZenaZ,CMantissaZ,WspomSkidka);
            S:=s+WspomSkidka+'│';
            {добавили процент доходности}
            If Abs(StrToReal(E^.Dat.MarketElement[c].Input.Zakupka))>0.009 Then
            MyStr((StrToREal(WspomSkidka))/
                  StrToReal(E^.Dat.MarketElement[c].Input.Zakupka)*100,
                  CLitr,CMantissa,WspomProz)
            Else WspomProz:='??.??';
            S:=s+WspomProz+'';
           End;
         Else
            Begin
            S:=s+'│'+WspomSkidka+'║';
            {добавили доходность}
            MyStr(StrToREal(WspomSkidka)-StrToReal(E^.Dat.MarketElement[c].Input.Zakupka2)-
            StrToReal(E^.Dat.MarketElement[c].Input.AkzisSbor),CZenaZ,CMantissaZ,WspomSkidka);
            S:=s+WspomSkidka+'│';
            {добавили процент доходности}
            If Abs(StrToReal(E^.Dat.MarketElement[c].Input.Zakupka2))>0.009 Then
            MyStr((StrToREal(WspomSkidka))/
                  StrToReal(E^.Dat.MarketElement[c].Input.Zakupka2)*100,CLitr,CMantissa,WspomProz)
            Else WspomProz:='??.??';
            S:=s+WspomProz+'';
            End;
         End;{CAse}
(*
         If Otobragenie=0 Then
         S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║'
         Else
          Begin
         {добавили цену оплаты}
         S:=s+'│'+WspomSkidka+'║';
         {добавили доходность}
         MyStr(StrToREal(WspomSkidka)-StrToReal(E^.Dat.MarketElement[c].Input.Zakupka),CZenaZ,CMantissaZ,WspomSkidka);
         S:=s+WspomSkidka+'│';
         {добавили процент доходности}
         If Abs(StrToReal(E^.Dat.MarketElement[c].Input.Zakupka))>0.009 Then
         MyStr(StrToREal(WspomSkidka)/StrToReal(E^.Dat.MarketElement[c].Input.Zakupka)*100,CLitr,CMantissa,WspomProz)
         Else WspomProz:='??.??';
         S:=s+WspomProz+'';
          End;
*)

            {+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';}
        End;
      1:Begin{скидка ручная}
          If StrToReal(E^.Dat.MarketElement[c].Input.Skidka)>=0 Then
          Begin
          If (StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka))>0.009 Then
          MyStr(((StrToReal(E^.Dat.MarketElement[c].Input.Zena))/((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
          StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))-1)*100
          ,CZena,CLitrMantissa,ws1)
          Else ws1:='100.00';
          MyStr(StrToReal(Ws1),CZena,CMantissa,ws1);
           End
           Else
             Begin
              If Abs(StrToReal(E^.Dat.MarketElement[c].Input.Zena))>0.009 Then
              MyStr((-(Abs(StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))/
              ((StrToReal(E^.Dat.MarketElement[c].Input.Zena)))*100),CZena,CMantissa,Ws1)
              Else
              ws1:='   ??.??';
             End;

          MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Skidka),CZena,CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

          MyStr((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka)),
                CZena,CMantissa,wspomSkidka);


      CAse Otobragenie Of
      0:Begin
         S:=s+'│'+WspomSkidka+'║'+E^.Dat.MarketElement[c].Input.Skidka+'│'+ws1+'║';
        End;{0}
      1:Begin
         {добавили цену оплаты}
         S:=s+'│'+WspomSkidka+'║';
         {добавили доходность}

         MyStr(StrToREal(WspomSkidka)-StrToReal(E^.Dat.MarketElement[c].Input.Zakupka)
            -StrToReal(E^.Dat.MarketElement[c].Input.AkzisSbor),CZenaZ,CMantissaZ,WspomSkidka);


         S:=s+WspomSkidka+'│';
         {добавили процент доходности}
         If Abs(StrToReal(E^.Dat.MarketElement[c].Input.Zakupka))>0.009 Then
         MyStr((StrToREal(WspomSkidka))/
            StrToReal(E^.Dat.MarketElement[c].Input.Zakupka)*100,CLitr,CMantissa,WspomProz)
         Else WspomProz:='??.??';

         S:=s+WspomProz+'';
        End;{1}
      Else Begin
         {добавили цену оплаты}
         S:=s+'│'+WspomSkidka+'║';
         {добавили доходность}
         MyStr(StrToREal(WspomSkidka)-StrToReal(E^.Dat.MarketElement[c].Input.Zakupka2)
         -StrToReal(E^.Dat.MarketElement[c].Input.AkzisSbor),CZenaZ,CMantissaZ,WspomSkidka);
         S:=s+WspomSkidka+'│';
         {добавили процент доходности}
         If Abs(StrToReal(E^.Dat.MarketElement[c].Input.Zakupka2))>0.009 Then
         MyStr((StrToREal(WspomSkidka))/
            StrToReal(E^.Dat.MarketElement[c].Input.Zakupka2)*100,CLitr,CMantissa,WspomProz)
         Else WspomProz:='??.??';
         S:=s+WspomProz+'';
           End;{Else}
      End;{CAse}
        End;
      Else;
      End;{E^.Dat.SkidkaSelector}

  SKolish[0]:=#0;
  SCommentr[0]:=#0;
  If Not MrkWin^.ZakazField Then
  begin
  CalcReturnPosition(E^.Dat.Document,E^.Dat.DateC,E^.Dat.ClientKod,E^.Dat.MarketElement[c].BazKod,
  IntToStr(E^.Dat.MarketElement[c].Input.DivisionNumber,COne),E^.Dat.OperatorSelector,Skolish,SCommentr);
  {memc(SKolish);}
  end;
  Format(SKolish,CKol);
  sss:=GetIDField(FFFName,E^.Dat.MarketElement[c].Input.NSertif);
  Format(sss,CName+1+CName);
  MyStr(StrToReal(E^.Dat.MarketElement[c].Input.AkzisSbor),CZenaZ,CMAntissaZ,E^.Dat.MarketElement[c].Input.AkzisSbor);
  MyStr(StrToReal(E^.Dat.MarketElement[c].Input.ZenaMarki),CZenaZ,CMAntissaZ,E^.Dat.MarketElement[c].Input.ZenaMarki);
  s:=s+SFullName+IntToStr(E^.Dat.MarketElement[c].Input.RegionMarka,COne)+
  E^.Dat.MarketElement[c].Input.AkzisSbor+E^.Dat.MarketElement[c].Input.ZenaMArki+
  SKolish+'│'+SSS+'│'+E^.Dat.MarketElement[c].Input.NSertif+'│'+sCommentr;
  NoScreenList1^.List^.Insert(NewStr(s));
  NoScreenList1^.SetRange(NoScreenList1^.List^.Count);



End;
 End;


{вставляем в список сертификаты}
For c:=1 To E^.Dat.AmountS Do
 Begin
  S:=E^.Dat.DocumentElement[c].BazKod;
  LitrS:=0;
  SFullNAme:=GetIdField(FFFName,s);
  Format(SFullNAme,CNAme+1+CNAme);
  ws:=Copy(SFullNAme,1,CName);
  DelSpaceRight(ws);
  ws:='■'+ws;
  Format(ws,CName);
  s:=ws+'│'+s+'│';
  Str(E^.Dat.DocumentElement[c].Input.DivisionNumber:1,ws);
  s:=s+ws;



  DelSpace(E^.Dat.DocumentElement[c].Input.Kol);
  RFormat(E^.Dat.DocumentElement[c].Input.Kol,CKol);
  s:=s+'│'+E^.Dat.DocumentElement[c].Input.Kol;
  {  ws:=GetIdField(FLitr,E^.Dat.DocumentElement[c].BazKod);
  Format(Ws,CLitr);
  s:=s+'│'+ws;}
{ DelSpace(E^.Dat.DocumentElement[c].Input.Zena);
  RFormat(E^.Dat.DocumentElement[c].Input.Zena,CZena);
  s:=s+'│'+E^.Dat.DocumentElement[c].Input.Zena;}
  {
  MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka),CZenaZ,CMantissa,E^.Dat.DocumentElement[c].Input.Zakupka);
  DelSpace(E^.Dat.DocumentElement[c].Input.Zakupka);
  RFormat(E^.Dat.DocumentElement[c].Input.Zakupka,CZenaZ);
  s:=s+'│'+E^.Dat.DocumentElement[c].Input.Zakupka;}

  Case Otobragenie Of
  0:Begin
     MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Zena),CZena,CMantissa,E^.Dat.DocumentElement[c].Input.Zakupka);
     DelSpace(E^.Dat.DocumentElement[c].Input.Zena);
     RFormat(E^.Dat.DocumentElement[c].Input.Zena,CZena);
     s:=s+'│'+E^.Dat.DocumentElement[c].Input.Zena;
    End;
  1:Begin
     MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka),CZenaZ,CMantissaZ,E^.Dat.DocumentElement[c].Input.Zakupka);
     DelSpace(E^.Dat.DocumentElement[c].Input.Zakupka);
     RFormat(E^.Dat.DocumentElement[c].Input.Zakupka,CZenaZ);
     s:=s+'│'+E^.Dat.DocumentElement[c].Input.Zakupka;
    End;
  Else
   Begin
     MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka2),CZenaZ,CMantissaZ,E^.Dat.DocumentElement[c].Input.Zakupka2);
     DelSpace(E^.Dat.DocumentElement[c].Input.Zakupka2);
     RFormat(E^.Dat.DocumentElement[c].Input.Zakupka2,CZenaZ);
     s:=s+'│'+E^.Dat.DocumentElement[c].Input.Zakupka2;
   End;
 End;{Case}
        Case E^.Dat.SkidkaSelector Of
      0:Begin{скидка автоматическая}
         MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Zena)-StrToReal(E^.Dat.DocumentElement[c].Input.Zena)/
         (1+StrToReal(E^.Dat.DocumentElement[c].Input.Proz)/100),CZena,CMantissa,E^.Dat.DocumentElement[c].Input.Skidka);

         {форматируем прценты}
         MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Proz),CZena,CMantissa,ws1);
         MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Skidka),CZena,CMantissa,E^.Dat.DocumentElement[c].Input.Skidka);

         MyStr((StrToReal(E^.Dat.DocumentElement[c].Input.Zena)/
        (1+StrToReal(E^.Dat.DocumentElement[c].Input.Proz)/100)),CZena,CMantissa,wspomSkidka);

         {S:=s+'│'+WspomSkidka+'║'+E^.Dat.DocumentElement[c].Input.Skidka+'│'+ws1+'║';}

         Case Otobragenie Of
         0:Begin
            S:=s+'│'+WspomSkidka+'║'+E^.Dat.DocumentElement[c].Input.Skidka+'│'+ws1+'║'
           End;
         1:Begin
           {добавили цену оплаты}
            S:=s+'│'+WspomSkidka+'║';
           {добавили доходность}
            MyStr(StrToREal(WspomSkidka)-StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka)
                  -StrToReal(E^.Dat.DocumentElement[c].Input.AkzisSbor),CZenaZ,CMantissaZ,WspomSkidka);
            S:=s+WspomSkidka+'│';
           {добавили процент доходности}
            If Abs(StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka))>0.009 Then
            MyStr((StrToREal(WspomSkidka))/
                  StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka)*100,CLitr,CMantissa,WspomProz)
            Else WspomProz:='??.??';
            S:=s+WspomProz+'';
           End;
         Else
          Begin
           {добавили цену оплаты}
            S:=s+'│'+WspomSkidka+'║';
           {добавили доходность}
            MyStr(StrToREal(WspomSkidka)-StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka2)-
                  StrToReal(E^.Dat.DocumentElement[c].Input.AkzisSbor),CZenaZ,CMantissaZ,WspomSkidka);
            S:=s+WspomSkidka+'│';
           {добавили процент доходности}
            If Abs(StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka2))>0.009 Then
            MyStr((StrToREal(WspomSkidka))/
                  StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka)*100,CLitr,CMantissa,WspomProz)
            Else WspomProz:='??.??';
            S:=s+WspomProz+'';
          End;
         End;{CAse}

        End;
      1:Begin{скидка ручная}
          If StrToReal(E^.Dat.DocumentElement[c].Input.Skidka)>=0 Then
          Begin
          If (StrToReal(E^.Dat.DocumentElement[c].Input.Zena)-StrToReal(E^.Dat.DocumentElement[c].Input.Skidka))>0.009 Then
          MyStr(((StrToReal(E^.Dat.DocumentElement[c].Input.Zena))/((StrToReal(E^.Dat.DocumentElement[c].Input.Zena)-
          StrToReal(E^.Dat.DocumentElement[c].Input.Skidka)))-1)*100
          ,CZena,CLitrMantissa,ws1)
          Else ws1:='100.00';
          MyStr(StrToReal(Ws1),CZena,CMantissa,ws1);
           End
           Else
             Begin
              MyStr((-(Abs(StrToReal(E^.Dat.DocumentElement[c].Input.Skidka)))/
              ((StrToReal(E^.Dat.DocumentElement[c].Input.Zena)))*100),CZena,CMantissa,Ws1);
             End;

          MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Skidka),CZena,CMantissa,E^.Dat.DocumentElement[c].Input.Skidka);

          MyStr((StrToReal(E^.Dat.DocumentElement[c].Input.Zena)-StrToReal(E^.Dat.DocumentElement[c].Input.Skidka))
          ,CZena,CMantissa,wspomSkidka);

          {S:=s+'│'+WspomSkidka+'║'+E^.Dat.DocumentElement[c].Input.Skidka+'│'+ws1+'║';}

         Case Otobragenie Of
         0:Begin
            S:=s+'│'+WspomSkidka+'║'+E^.Dat.DocumentElement[c].Input.Skidka+'│'+ws1+'║'
           End;
         1:Begin
           {добавили цену оплаты}
            S:=s+'│'+WspomSkidka+'║';
           {добавили доходность}
            MyStr(StrToREal(WspomSkidka)-StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka)-
                  StrToReal(E^.Dat.DocumentElement[c].Input.AkzisSbor),CZenaZ,CMantissaZ,WspomSkidka);
            S:=s+WspomSkidka+'│';
           {добавили процент доходности}
            If Abs(StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka))>0.009 Then
            MyStr((StrToREal(WspomSkidka))/
                  StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka)*100,CLitr,CMantissa,WspomProz)
            Else WspomProz:='??.??';
            S:=s+WspomProz+'';
           End;
          Else
           Begin
           {добавили цену оплаты}
            S:=s+'│'+WspomSkidka+'║';
           {добавили доходность}
            MyStr(StrToREal(WspomSkidka)-StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka2)-
                  StrToReal(E^.Dat.DocumentElement[c].Input.AkzisSbor),CZenaZ,CMantissaZ,WspomSkidka);
            S:=s+WspomSkidka+'│';
           {добавили процент доходности}
            If Abs(StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka2))>0.009 Then
            MyStr((StrToREal(WspomSkidka))/
                  StrToReal(E^.Dat.DocumentElement[c].Input.Zakupka2)*100,CLitr,CMantissa,WspomProz)
            Else WspomProz:='??.??';
            S:=s+WspomProz+'';
           End;
         End;

        End;
      Else;
      End;{E^.Dat.SkidkaSelector}

  SKolish[0]:=#0;
  SCommentr[0]:=#0;
  Format(SKolish,CKol);
  MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.AkzisSbor),CZenaZ,CMAntissaZ,E^.Dat.DocumentElement[c].Input.AkzisSbor);
  MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.ZenaMarki),CZenaZ,CMAntissaZ,E^.Dat.DocumentElement[c].Input.ZenaMarki);

  sss:=GetIDField(FFFName,NoSertifStr);
  Format(sss,CName+1+CName);
  s:=s+SFullName{ пока до проведения модернизации возврата выключена}+
  IntToStr(E^.Dat.DocumentElement[c].Input.RegionMarka,COne)+
  E^.Dat.DocumentElement[c].Input.AkzisSbor+E^.Dat.DocumentElement[c].Input.ZenaMArki+
  SKolish+'│'+SSS+'│'+NoSertifStr+'│'+sCommentr;


  NoScreenList1^.List^.Insert(NewStr(s));
  NoScreenList1^.SetRange(NoScreenList1^.List^.Count);
 End;

Case Otobragenie Of
0:Begin
   Dispose(ControlHeader,Done);
   R.Assign(35, 4, 79, 5);
   ControlHeader := New(PColoredText, Init(R,
   'N Колич Цена лоб Цена опл  Скидка   Процент', $7F));
   MrkWin^.Insert(ControlHeader);
  End;
1,2
  :Begin
   Dispose(ControlHeader,Done);
   R.Assign(35, 4, 79, 5);
   ControlHeader := New(PColoredText, Init(R,
   'N Колич   З/Цена   Цена опл   Доход      % ', $7F));
   MrkWin^.Insert(ControlHeader);
  End;
Else;
End;
Dispose(E,Done);



CurrentLine[0]:=#0;

End;



procedure TFullScreenMrk.HandleEvent(var Event: TEvent);

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
 evKeyDown :
   Case Event.KeyCode Of

        kbF5:Begin
             If Not MrkWin^.ZakazField Then
             Begin
              Event.What:=evCommand;
              Event.Command:=cmLocalInfo;
              PutEvent(Event);
             End;
              ClearEvent(Event);
             End;

       Else;
       End;

 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;

        cmViewVersion:
                 Begin
             If Not MrkWin^.ZakazField Then
             Begin
                If Password(3) Then
                 Begin
                Assistent.EditPosition:=Numer;
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Date;
                DelSpace(Assistent.D);
                CMrk^.Start(Assistent.EditPosition,Assistent.D);
                 End;
             End;
              End;

        cmAllSfB   :Begin
                     ViewElement(Kto,bClient,MrkWin^.OperatorSelector);
                    End;

cmViewPrihodTovar
     :Begin
if (ControlFull^.State and sfFocused <> 0) And(ControlFull^.List<>Nil) And (ControlFull^.List^.Count>=1)Then
      If (ControlFull^.List^.Count-1)>=0 Then
       begin
        Sn:=Copy(ControlFull^.GEtTExt(ControlFull^.Focused,ControlFull^.List^.Count),1+CName+1,CArtikul);
        FP^.FindScreenPrh(SN);
        ClearEvent(Event);
       End;
      End;

  cmPrintReestr:    Begin
                ClearFind;
                Assistent.EditPosition:=Numer;
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Date;
                DelSpace(Assistent.D);

                If Not(MrkWin^.ZakazField) Then
                PrintNakl(Assistent,NprintC^.DAt.CopyNaklC)
                Else
                PrintZakaz(Assistent,NprintC^.DAt.CopyZakaz);
                    End;
    cmLocalInfo: Begin
  If (MrkWin^.OperatorSelector=0) And (MrkWin^.DocSelector in [5..8]) And Not(MrkWin^.ZakazField) Then
  Begin
                 Sn:=Numer;
                 RFormatZerro(Sn,CDocNumer);
                 s:='│'+Sn+'│'+Date;
                 LockInfo^.LockStart(s,Kto{ClientKodes});
                 CurrentLine[0]:=#0;

  End;
                  End;
        Else;
        End;
 Else;
 End;

inherited HandleEvent(Event);


 If (Desktop^.Current=PView(MrkWin)) And (Event.What <> EvKeyDown) Then
     Begin

if (ControlFull^.State and sfFocused <> 0) And(ControlFull^.List<>Nil) And (ControlFull^.List^.Count>=1)Then
   Begin
    s:=ControlFull^.GetText(ControlFull^.Focused,ControlFull^.List^.Count);
    If s <> CurrentLine Then
     Begin
      DrawCurrent(s);
     End
   End;

          if (ControlSelector^.State and sfFocused <> 0)Then
              Begin
               ControlSelector^.GetData(Prom);
               If Prom <> VidProsmotra Then
               Begin
                Begin
                  VidProsmotra:=Prom;
                  DInfoMsg('Минуточку...',True);
                  Refresh;
                  CalcItogo;
                  NoInfoMsg;
                  Redraw;
                End;
               End;
              End;

          if (ControlOtobragenie^.State and sfFocused <> 0)Then
              Begin
               ControlOtobragenie^.GetData(Prom);
               If Prom <> Otobragenie Then
               Begin
                Begin
                  Otobragenie:=Prom;
                  DInfoMsg('Минуточку...',True);
                  RefreshNakl;
                  Refresh;
                  CalcItogo;
                  NoInfoMsg;
                  Redraw;
                End;
               End;
              End;


          if (ControlShowReturn^.State and sfFocused <> 0)Then
              Begin
               ControlShowReturn^.GetData(Prom);
               If Prom <> ShowOnlyReturn Then
               Begin
                Begin
                  ShowOnlyReturn:=Prom;
                  DInfoMsg('Минуточку...',True);
                  RefreshNakl;
                  Refresh;
                  CalcItogo;
                  NoInfoMsg;
                  Redraw;
                End;
               End;
              End;



     End;


End;

procedure TFullScreenMrk.DrawCurrent(s: String);
Var s1,s2,s3,s4: String;
    R : TRect;
    Art : ArtikulStr;
    f1,f2 : String;
Begin

s1:=Copy(s,StartPos,CKol);
If StrToInt(s1)>0 Then
 Begin

 Dispose(ControlFullName,Done);
 {
 Art:=Copy(s,1,CArtikul);
 f1:=GetIdField(FFFName,Art);
 DelSpaceRight(f1);
 {
 f2:=GetIdField(FName2,Art);
 DelSpaceRight(f2);}
{R.Assign(1, 21, 54, 22);}

 f2[0]:=#0;
 f1:=Copy(s,StartPos-CName-1-CName-COne-CZenaZ-CZenaZ,CName+1+CName);
 DelSpaceRight(f1);

 R.Assign(1, 16, 55, 17);
 ControlFullName := New(PColoredText, Init(R, f1{+f2}, $7e));
 MrkWin^.Insert(ControlFullName);



 Dispose(ControlFullSertif,Done);
 f2[0]:=#0;
 f1:=Copy(s,StartPos+CKol+1,CName+1+CNAme);
 DelSpaceRight(f1);
 R.Assign(1, 15, 55, 16);
 ControlFullSertif := New(PColoredText, Init(R, f1+' ['+
 +Copy(s,StartPos+CKol+1+CName+1+CNAme+1,CArtikul)+']'{+f2}, $7e));
 MrkWin^.Insert(ControlFullSertif);




 Dispose(ControlRegionMarka,Done);
 R.Assign(54, 17, 59, 18);
 f1:=Copy(s,StartPos-COne-CZenaZ-CZenaZ,COne);
 DelSpaceRight(f1);
  Case StrToInt(f1) Of
  0:Begin
     f1:='Нет';
     ControlRegionMarka := New(PColoredText, Init(R, #3+f1, $5F));
    End;
  1:Begin
     f1:='Есть';
     ControlRegionMarka := New(PColoredText, Init(R, #3+f1, $7E));
    End;
  Else;
  End;{Case}
 MrkWin^.Insert(ControlRegionMarka);

 Dispose(ControlAkzisSbor,Done);
 f1:=Copy(s,StartPos-CZenaZ-CZenaZ,CZenaZ);
 DelSpace(f1);
 R.Assign(13, 17, 23, 18);
 ControlAkzisSbor := New(PColoredText, Init(R, #3+f1, $7E));
 MrkWin^.Insert(ControlAkzisSbor);


 Dispose(ControlZenaMarki,Done);
 f1:=Copy(s,StartPos-CZenaZ,CZenaZ);
 DelSpace(f1);
 R.Assign(36, 17, 46, 18);
 ControlZenaMarki := New(PColoredText, Init(R, #3+f1, $7E));
 MrkWin^.Insert(ControlZenaMarki);



 Dispose(ControlRZ,Done);
 R.Assign(65, 1, 73, 2);
 ControlRZ := New(PColoredText, Init(R, 'Возврат:', $74));
 MrkWin^.Insert(ControlRZ);

 Dispose(ControlR,Done);
 R.Assign(73, 1, 78, 2);
 ControlR := New(PColoredText, Init(R, #3+IntToStr(StrToInt(s1),CKol), $1F));
 MrkWin^.Insert(ControlR);

 Dispose(ControlMsg,Done);
If ReturnCount>0 Then
 Begin
  R.Assign(26, 2, 52, 3);
  ControlMsg := New(PColoredText, Init(R, #3+' Возрат по '+InttoStr(ReturnCount,CMantissa)+' позиции(ям)', $77));
  ControlMsg^.Options := ControlMsg^.Options or ofCenterX;
 End
 Else
 Begin
  R.Assign(26, 2, 52, 3);
  ControlMsg := New(PColoredText, Init(R, #3+' Возратов не было !', $77));
  ControlMsg^.Options := ControlMsg^.Options or ofCenterX;
 End;
 MrkWin^.Insert(ControlMsg);


 s2:=Copy(s,StartPos+CKol+1+CArtikul+1+(CName+1+CName)+1,Ord(s[0])-StartPos-CKol-1);
 Dispose(ControlText,Done);
 R.Assign(1, 2, 1+Ord(s[0])-StartPos-CKol-CArtikul-1-(CName+1+CName)-1, 3);
 ControlText := New(PColoredText, Init(R, s2, $5E{de}));
 ControlText^.Options := ControlText^.Options or ofCenterX;

 MrkWin^.Insert(ControlText);
 End
Else
 Begin

 Dispose(ControlFullName,Done);
 {
 Art:=Copy(s,1,CArtikul);
 f1:=GetIdField(FName,Art);
 DelSpaceRight(f1);
 f2:=GetIdField(FName2,Art);
 DelSpaceRight(f2);
 }
 f2[0]:=#0;
 f1:=Copy(s,StartPos-CName-1-CName-COne-CZenaZ-CZenaZ,CName+1+CName);
 DelSpaceRight(f1);

 {R.Assign(1, 21, 54, 22);}
 R.Assign(1, 16, 55, 17);
 ControlFullName := New(PColoredText, Init(R, f1+f2, $7e));
 MrkWin^.Insert(ControlFullName);


 Dispose(ControlFullSertif,Done);
 f2[0]:=#0;
 f1:=Copy(s,StartPos+CKol+1,CName+1+CNAme);
 DelSpaceRight(f1);
 R.Assign(1, 15, 55, 16);
 ControlFullSertif := New(PColoredText, Init(R, f1+' ['+
 +Copy(s,StartPos+CKol+1+CName+1+CNAme+1,CArtikul)+']'{+f2}, $7e));
 MrkWin^.Insert(ControlFullSertif);





 Dispose(ControlRegionMarka,Done);
 R.Assign(54, 17, 59, 18);

 f1:=Copy(s,StartPos-COne-CZenaZ-CZenaZ,COne);
 DelSpaceRight(f1);
  Case StrToInt(f1) Of
  0:Begin
     f1:='Нет';
     ControlRegionMarka := New(PColoredText, Init(R, #3+f1, $5F));
    End;
  1:Begin
     f1:='Есть';
     ControlRegionMarka := New(PColoredText, Init(R, #3+f1, $7E));
    End;
  Else;
  End;{Case}
 MrkWin^.Insert(ControlRegionMarka);


 Dispose(ControlAkzisSbor,Done);
 f1:=Copy(s,StartPos-CZenaZ-CZenaZ,CZenaZ);
 DelSpace(f1);
 R.Assign(13, 17, 23, 18);
 ControlAkzisSbor := New(PColoredText, Init(R, #3+f1, $7E));
 MrkWin^.Insert(ControlAkzisSbor);


 Dispose(ControlZenaMarki,Done);
 f1:=Copy(s,StartPos-CZenaZ,CZenaZ);
 DelSpace(f1);
 R.Assign(36, 17, 46, 18);
 ControlZenaMarki := New(PColoredText, Init(R, #3+f1, $7E));
 MrkWin^.Insert(ControlZenaMarki);


 Dispose(ControlRZ,Done);
 R.Assign(65, 1, 73, 2);
 ControlRZ := New(PColoredText, Init(R, 'Возврат:', $77));
 MrkWin^.Insert(ControlRZ);

 Dispose(ControlR,Done);
 R.Assign(73, 1, 78, 2);
 ControlR := New(PColoredText, Init(R, #3+IntToStr(StrToInt(s1),CKol), $77));
 MrkWin^.Insert(ControlR);

 s2:=Copy(s,StartPos+CKol+1,Ord(s[0])-StartPos+CKol+1);
 Dispose(ControlText,Done);
 R.Assign(1, 2, 79, 3);
 ControlText := New(PColoredText, Init(R, #3+'', $77));
 ControlText^.Options := ControlText^.Options or ofCenterX;
 MrkWin^.Insert(ControlText);

 Dispose(ControlMsg,Done);
If ReturnCount>0 Then
 Begin
  R.Assign(26, 2, 52, 3);
  ControlMsg := New(PColoredText, Init(R, #3+' Возрат по '+InttoStr(ReturnCount,CMantissa)+' позиции(ям)', $5E));
  ControlMsg^.Options := ControlMsg^.Options or ofCenterX;
 End
 Else
 Begin
  R.Assign(26, 2, 52, 3);
  ControlMsg := New(PColoredText, Init(R, #3+' Возратов не было !', $5E));
  ControlMsg^.Options := ControlMsg^.Options or ofCenterX;
 End;
 MrkWin^.Insert(ControlMsg);

 End;
Redraw;
CurrentLine:=s;
End;




procedure TFullScreenMrk.Refresh;
Var s,st,s2: String;
    R : TRect;
    L : Boolean;
    i : Word;
    SArt:ArtikulStr;
    V :MAska2;
Begin
WordToBit2(VidProsmotra,V);
Convert2(V);
ControlFull^.NewList(Nil);
ControlFull^.NewList(New(PTextCollection, Init(0,1)));
ReturnCount:=0;
AllLitr :=0.00;
If (NoScreenList1^.List^.Count-1)>=0 Then
For i:=0 To NoScreenList1^.List^.Count-1 Do
 Begin
  st:=NoScreenList1^.GetText(i,NoScreenList1^.List^.Count);
  SArt:=Copy(st,1+CName+1,CArtikul);
  l:=GetRazdelStatus(SArt);
  If (Not l And (v[1]=1)) Or (l And (v[2]=1)) Then
  Begin
   s2:=Copy(st,StartPos,CKol);
   If StrToInt(s2)>0 Then Inc(ReturnCount);
   ControlFull^.List^.Insert(NewStr(St));
   ControlFull^.SetRange(ControlFull^.List^.Count);
  End;


 End;
  If V[1]=1 Then AllLitr:=AllLitr+LitrT;
  If V[2]=1 Then AllLitr:=AllLitr+LitrS;


ControlFull^.FocusItem(0);

End;


procedure TFullScreenMrk.CalcItogo;
Var st,s2: String;
    R : TRect;
    L : Boolean;
    i : Word;
    SArt:ArtikulStr;
    V :MAska2;
    WspomProz,SKol : ArtikulStr;
    SZena,Skidka: AllStr;
    SLitr,SoSklada,SoSkidka,Amount,Oplata: AllStr;

Begin

SoSklada:='0.00';
Skidka:='0.00';
SoSkidka:='0.00';
Oplata:='0.00';
Amount:='0';


If (ControlFull^.List^.Count-1)>=0 Then
If Otobragenie=0 Then
Begin
For i:=0 To ControlFull^.List^.Count-1 Do
 Begin
  st:=ControlFull^.GetText(i,ControlFull^.List^.Count);
  SKol:=Copy(st,1+CName+1+CArtikul+1+COne+1,CKol);
  SZena:=Copy(st,1+CName+1+CArtikul+1+COne+1+CKol+1,CZena);
  Skidka:=Copy(st,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1,CZena);
  MyStr(StrToReal(SoSklada)+
  StrToInt(SKol)*StrToReal(SZena),CIZena,CMAntissa,SoSklada);

  MyStr(StrToReal(SoSkidka)+
  StrToInt(SKol)*StrToReal(Skidka),CIZena,CMAntissa,SoSkidka);
 End;
End
 Else
  Begin
For i:=0 To ControlFull^.List^.Count-1 Do
 Begin
  st:=ControlFull^.GetText(i,ControlFull^.List^.Count);
  SKol:=Copy(st,1+CName+1+CArtikul+1+COne+1,CKol);
  SZena:=Copy(st,1+CName+1+CArtikul+1+COne+1+CKol+1,CZenaZ);
  Skidka:=Copy(st,1+CName+1+CArtikul+1+COne+1+CKol+1+CZenaZ+1+CZena+1,CZenaZ);
  MyStr(StrToReal(SoSklada)+
  StrToInt(SKol)*StrToReal(SZena),CIZena,CMAntissaZ,SoSklada);



  MyStr(StrToReal(SoSkidka)+
  StrToInt(SKol)*StrToReal(Skidka),CIZena,CMAntissaZ,SoSkidka);
 End;
  End;


If Otobragenie=0 Then
  MyStr(StrToReal(SoSklada)-
        StrToReal(SoSkidka),CIZena,CMAntissa,Oplata)
Else
Begin
  MyStr(StrToReal(SoSklada)+
        StrToReal(SoSkidka),CIZena,CMAntissa,Oplata);
  If Abs(StrToREal(SoSklada))>0.009 Then
  MyStr(StrToReal(SoSkidka)/StrToReal(SoSklada)*100,CLitr,CMAntissa,WspomProz)
  Else
  WspomProz:='??.??';
End;

Str(ControlFull^.List^.Count:CMantissa,Amount);


Dispose(ControlCount,Done);
R.Assign(53, 0, 71, 1);
ControlCount := New(PColoredText, Init(R, 'Всего позиций:'+Amount, $4E));
MrkWin^.Insert(ControlCount);



DelSpace(Oplata);
DelSpace(SoSklada);
DelSpace(SoSkidka);
SLitr:=RealToStr(AllLitr,CZenaZ,CLitrMantissa);
DelSpace(SLitr);

Case Otobragenie Of
0:s2:=' К оплате:'+Oplata+' '+' Скидка '+VidSkidki+':'+SoSkidka+' '+
' Со склада: '+SoSklada+' ('+SLitr+'л)';

1:s2:=' К оплате:'+Oplata+' '+' Доход:'+SoSkidka+' ('+WspomProz+'%)'+
' Со склада по З/Ц: '+SoSklada;

Else
 Begin
s2:=' К оплате:'+Oplata+' '+' Доход2:'+SoSkidka+' ('+WspomProz+'%)'+
' Со склада по ЗЦ2: '+SoSklada;

 End;
End;


Dispose(ControlInfo,Done);
R.Assign(1, 22, 2+Ord(s2[0]), 23);
ControlInfo := New(PColoredText, Init(R, #3+S2, $4E));
ControlInfo^.Options := ControlInfo^.Options or ofCenterX;
MrkWin^.Insert(ControlInfo);

CurrentLine[0]:=#0;

End;

Destructor TFullScreenMrk.Done;
Begin
TDialog.Done;
End;


Procedure TLocalInfoDynamicDebit.LockPrintReport;
Const Space=' ';
Var Ass : DocumentEdit;
    s : String;
    SClientKod : ArtikulStr;
    Txt : Text;
    w : Word;
    wp : AllStr;
    p1,p2,p0 : Real;
    clf : File;
    ClientOplata  : PBufClientOplataRealizasiaType;
    BakFileMode,Count,c:Word;
    SDateDoc,sSrok,SDAteC,STimeC:TDateString;
    SSummaZ,SSkidka:AllStr;

Begin
If (LocalDolgList^.List<>Nil)And(LocalDolgList^.List^.Count>=1) Then
 Begin
  Assign(txt,Path^.Dat.ToTemp+'lockrep.txt');
  w:=IOResult;
  Rewrite(Txt);
  w:=IOResult;
  If w <>0 Then
   Begin
    MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'lockrep.txt',Nil,mfError+mfCancelButton);
    Exit;
   End;
  s:=LocalDolgList^.GetText(0,LocalDolgList^.List^.Count);
  Ass.EditPosition:=copy(s,1+1,CDocNumer);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(s,1+1+CDocNumer+1,CDAte);

  PStaticText(ControlClientLock)^.GetText(s);
  System.Delete(s,1,1);
  SClientKod:=Copy(s,1+CClient+1,CClientKod);

  BakFileMode:=FileMode;
  FileMode:=$42;
  Assign (ClF,Path^.Dat.ToClientOplata+SClientKod+'.cpl');
  w:=IOResult;
  Reset (ClF,SizeOf(ClientOplataRealizasiaType));
  w:=IOResult;
  FileMode:=BakFileMode;
  If w <>0 Then
   Begin
    System.Close(txt);
    MessageBox(#3^M+#3'Не найден файл оплаты долгов клиента '+SClientKod,Nil,mfError+mfCancelButton);
    Exit;
   End;
  wp:=GetClientField(FClient,SClientKod,0);
  Writeln(txt,Space+
  GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+'ХРОНОЛОГИЯ ОПЛАТЫ ДОЛГОВ ПО ДОКУМЕНТУ N '+
  Ass.EditPosition+' от '+
  Ass.D+' клиент:'+wp+'('+SClientKod+')'+
  GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]);
  Writeln(txt,Space+'┌───┬────────┬───────┬────────┬─────────┬───────────────┬───────────────┬────┬───────────┐');
  Writeln(txt,Space+'│N  │Дата Док│Срок Оп│ Дата Оп│ Время Оп│   Сумма оплаты│  Скидка возвр.│Del │  Оператор │');
                    {1234 12345678 12345678 12345678 12345678 1234567890123450123456789012345 1234 123456789012}
{123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890}
  Writeln(txt,Space+'└───┴────────┴───────┴────────┴─────────┴───────────────┴───────────────┴────┴───────────┘');

   p0:=0;
   p1:=0;
   p2:=0;
   While Not(Eof(ClF))Do
    Begin
     New(ClientOplata,Init);
     BlockRead(CLF,ClientOplata^.Point,BufferOpl,Count);
For c:=1 To Count Do
Begin
    With ClientOplata^.Point.Dat[c] Do
    Begin
     ClearChar(Document);
     DelZerro(Document);
     If (Document=Ass.EditPosition) And (DateStringToDAte(DateMask,Ass.D)=DateDoc)  Then
     Begin
    Format (Document,CDocNumer);

    SDAteDoc:=DateToDateString(DateMask,DateDoc);
    SSrok:=DateToDateString(DateMask,Srok);
    SDateC:=DateToDateString(DateMask,DAteC);
    STimeC:=TimeToTimeString('hh:mm:ss',TimeC);
    MyStr(SummaZ,CIZena,CMantissa,SSummaZ);
    MyStr(Skidka,CIZena,CMantissa,SSkidka);
    p2:=p2+Skidka;{скидка возврата}

    if Vozwrat Then
    Begin
    p1:=p1+SummaZ;{сумма  возврата}
    MyStr(SummaZ-Skidka,CIZena,CMantissa,SSummaZ);
    End
    else
    p0:=p0+SummaZ;{сумма  опдаты}



    wp:=GetOperatorField(FNAme,Caption);
    Format(wp,CKto);
    Format(Delta,CLitrMantissa+1);
    Writeln(txt,Space+Document+' '+SDateDoc+' '+SSrok+' '+SDateC+' '+STimeC+' '+SSummaZ+' '+SSkidka+' '+Delta+' '+wp);
    If Vozwrat Then
     Begin
        Writeln(txt,Space+'Возврат по документу N'+DocNumerReturn+' от '+DateToDAteString(DAteMask,DocDateReturn));
     End;
    End;{If}
   End;{With}
End;{For}
 Dispose(ClientOplata,Done);
End;{While}
  Writeln(txt,Space+'─────────────────────────────────────────────────────────────────────────────────────────');
  Writeln(Txt,Space+'                                                Всего скидка возврата:',
  RecognizReal(p2,CIZena,CMantissa));
  Writeln(Txt,Space+'                                                 Всего сумма возврата:',
  RecognizReal(p1,CIZena,CMantissa));
  Writeln(Txt,Space+'                                                       Всего оплачено:',
  RecognizReal(p0,CIZena,CMantissa));

  Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  Writeln(txt,Space+'=========================================================================================');
  System.Close(ClF);
  System.Close(txt);
  Report(Path^.Dat.ToTemp+'lockrep.txt','',NprintC^.DAt.CopyAll,False,False);
 End;
End;

Procedure TLocalInfoDynamicDebit.LockStart(S:String;ClientKod:ArtikulStr);
var
  R : TRect;
  Control : PView;
  C : LongInt;
  p0,p1,p2 : Real;
  wp : String[cIzena];
  ClientOplataFile : File;
  ClientOplata     : PBufClientoplataRealizasiaType;
  SDoc:ArtikulStr;
  SDate:TDateString;
  SClientkod:ArtikulStr;
  s1 : AllStr;
  PrevProdaga : Boolean;
  BakFileMode,c1,Count : Word;

    SDateDoc,sSrok,SDAteC,STimeC:TDateString;
    SSummaZ,SSkidka:AllStr;




begin
ClearFind;

SDoc:=Copy(s,1+1,CDocNumer);
DelSpace(SDoc);
DelZerro(SDoc);

SDate:=Copy(s,1+1+CDocNumer+1,CDate);
DelSpace(SDate);

SClientKod:=ClientKod;
 BakFileMode:=FileMode;
 FileMode:=$42;

Assign(ClientOplataFile,Path^.Dat.ToClientOplata+SClientKod+'.cpl');
c:=IOResult;
Reset(ClientOplataFile,SizeOf(ClientOplataRealizasiaType));
c:=IOResult;
FileMode:=BakFileMode;
If c<>0 Then
 Begin
  MessageBox(#3+'Клиент не проводил оплаты долгов!'^M+#3'Ошибка доступа к файлу оплаты консигнации клиента ('
  +SclientKod+')',
                   Nil,mfError+mfCancelButton);
  Exit;
 End;

{AInfo('Читаю хронологию оплаты долгов клиентом...');}

PrevSLock:=GetClientField(FClient,SClientKod,0);
Format(PrevSLock,CClient);

R.Assign(0, 0, 80, 23);
New(LocalInfo, Init(R, 'Хронология оплаты клиентом долга по документу N '+SDoc+' от '+SDate));

LocalInfo^.Options := LocalInfo^.Options or ofCenterX or ofCenterY;
R.Assign(51, 1, 79, 2);
PrevSLock:=PrevSLock+'('+SClientKod+')';
ControlClientLock := New(PColoredText, Init(R, #3+PrevSLock, $7E));
LocalInfo^.Insert(ControlClientLock);

 R.Assign(43, 1, 51, 2);
Control := New(PColoredText, Init(R, 'Клиент:', $74));
LocalInfo^.Insert(Control);

R.Assign(80, 3, 80, 19);
Control := New(PScrollBar, Init(R));
LocalInfo^.Insert(Control);

R.Assign(1, 3, 80, 19);
LocalDolgList := New(PBox, Init(R, 1, PScrollbar(Control)));
LocalDolgList^.NewList(New({PText}PMyCollection, Init(0,1)));

p0:=0;
p1:=0;
p2:=0;

PrevProdaga:=ProdagaWindow;
ProdagaWindow:=True;

While Not(Eof(ClientOplataFile)) Do
 Begin
  DInfoMsgShkala('Читаю хронологию оплаты долгов клиентом....',0,FileSize(ClientOplataFile),FilePos(ClientOplataFile));
  New(ClientOplata,Init);
  BlockRead(ClientOplataFile,ClientOplata^.Point,BufferOpl,Count);
For c1:=1 To Count Do
Begin
    With ClientOplata^.Point.Dat[c1] Do
    Begin


  DelZerro(Document);
  If (StrToInt(ClearChar(Document))=StrToInt(ClearChar(SDoc))) And
        (DateToDateString(DateMask,DateDoc)=SDate) Then
   Begin
    RFormatZerro(Document,CDocNumer);
    Format (Document,CDocNumer);

    SDAteDoc:=DateToDateString(DateMask,DateDoc);
    SSrok:=DateToDateString(DateMask,Srok);
    SDateC:=DateToDateString(DateMask,DAteC);
    STimeC:=TimeToTimeString('hh:mm:ss',TimeC);

    MyStr(Skidka,CIZena,CMantissa,SSkidka);
    p2:=p2+Skidka;{скидка возврата}
    if Vozwrat Then
    Begin
    p1:=p1+SummaZ{сумма  возврата};
    MyStr(SummaZ-Skidka,CIZena,CMantissa,SSummaZ);
    End
    else
    p0:=p0+SummaZ;{сумма  опдаты}

    MyStr(SummaZ,CIZena,CMantissa,SSummaZ);

    wp:=GetOperatorField(FNAme,Caption);
    Format(wp,CKto);
    Format(Delta,CLitrMantissa+1);
    LocalDolgList^.List^.Insert(NewStr('│'+Document+'│'
    +SDateDoc+'│'+SSrok+'│'+SDateC+'│'+STimeC+'│'+SSummaZ+'│'+SSkidka+'│'+Delta+'│'+wp));
    LocalDolgList^.SetRange(LocalDolgList^.List^.Count);
  End;{If}
  End;{With}
End;{For}
  Dispose(ClientOplata,Done);
 End;{While}
System.Close(ClientOplataFile);
NoInfoMsg;

PrevDoc:=SDoc;
PrevDate:=SDate;

LocalDolgList^.FocusItem(0);
LocalDolgList^.HelpCtx:=$E100;

LocalInfo^.Insert(LocalDolgList);

R.Assign(1, 2, 79, 3);
{LocalInfo^.Insert(New(PLabel, Init(R, ' Дата Док   N   Срок Оп Дата Оп. Время Оп.   Сумма оплаты   Скидка возвр. Del',}
LocalInfo^.Insert(New(PLabel, Init(R, '  N   Дата Док Срок Оп. Дата Оп. Время Оп.   Сумма оплаты   Скидка возвр. Del',
LocalDolgList)));

R.Assign(18, 20, 24, 21);
Control := New(PColoredText, Init(R, 'N п/п:', $74));
LocalInfo^.Insert(Control);

R.Assign(15, 19, 24, 20);
Control := New(PColoredText, Init(R, 'Дата п/п:', $74));
LocalInfo^.Insert(Control);

R.Assign(24, 20, 34, 21);
ControlPP := New(PColoredText, Init(R, #3'', $7E));
LocalInfo^.Insert(ControlPP);

R.Assign(24, 19, 32, 20);
ControlDatePP := New(PColoredText, Init(R, #3'', $7E));
LocalInfo^.Insert(ControlDatePP);

R.Assign(35, 19, 45, 20);
Control := New(PColoredText, Init(R, 'Сумма п/п:', $74));
LocalInfo^.Insert(Control);

R.Assign(45, 19, 60, 20);
ControlSummaPP := New(PColoredText, Init(R, #3'', $7E));
LocalInfo^.Insert(ControlSummaPP);

R.Assign(40, 20, 45, 21);
Control := New(PColoredText, Init(R, 'Банк:', $74));
LocalInfo^.Insert(Control);

R.Assign(45, 20, 78, 21);
ControlBank := New(PColoredText, Init(R, '', $7E));
LocalInfo^.Insert(ControlBank);

R.Assign(3, 19, 10, 20);
Control := New(PColoredText, Init(R, 'Расчет:', $71));
LocalInfo^.Insert(Control);

R.Assign(10, 19, 13, 20);
ControlRashet := New(PColoredText, Init(R, #3'', $7E));
LocalInfo^.Insert(ControlRashet);

R.Assign(2, 21, 13, 22);
Control := New(PColoredText, Init(R, 'Примечание:', $71));
LocalInfo^.Insert(Control);

R.Assign(13, 21, 53, 22);
ControlPrim := New(PColoredText, Init(R, #3'', $7E));
LocalInfo^.Insert(ControlPrim);

R.Assign(55, 21, 64, 22);
Control := New(PColoredText, Init(R, 'Оператор:', $74));
LocalInfo^.Insert(Control);

R.Assign(64, 21, 76, 22);
ControlPassword := New(PColoredText, Init(R, #3+'', $7E));
LocalInfo^.Insert(ControlPassword);

R.Assign(29, 22, 38, 23);
Control := New(PColoredText, Init(R, ' Возврат:', $74));
LocalInfo^.Insert(Control);

MyStr(p1,CIZena,CMantissa,wp);
DelSpace(wp);
R.Assign(38, 22, 53, 23);
Control := New(PColoredText, Init(R, #3+wp, $4E));
LocalInfo^.Insert(Control);

R.Assign(1, 22, 13, 23);
Control := New(PColoredText, Init(R, ' Cкид.возвр:', $74));
LocalInfo^.Insert(Control);

MyStr(p2,CIZena,CMantissa,wp);
DelSpace(wp);
R.Assign(13, 22, 28, 23);
Control := New(PColoredText, Init(R, #3+wp, $4E));
LocalInfo^.Insert(Control);

R.Assign(54, 22, 64, 23);
Control := New(PColoredText, Init(R, ' Оплачено:', $74));
LocalInfo^.Insert(Control);

MyStr(p0,CIZena,CMantissa,wp);
DelSpace(wp);
R.Assign(64, 22, 79, 23);
Control := New(PColoredText, Init(R, #3+wp, $4E));
LocalInfo^.Insert(Control);

PrevCurrent[0]:=#0;

LocalInfo^.SelectNext(False);
PrevCurrent[0]:=#0;
LocalInfo^.LockFreshRashetHint;
{NoInfo;}
c:=Desktop^.ExecView(LocalInfo);
Dispose(Control,Done);
Dispose(LocalInfo,Done);

ProdagaWindow:=PrevProdaga;

end;




Procedure TLocalInfoDynamicDebit.HandleEvent(Var Event : TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Begin
  Case Event.What Of
   EvCommand:
    Case Event.Command Of
    cmReestrReport :Begin
                    LockPrintReport;
                    End;
        cmLocalCalc:Begin
                     ClearFind;
                        Calculator;
                    End;
    Else;
    End;
  Else;
  End;

  inherited HandleEvent(Event);
  LockFreshRashetHint;
  ClearEvent(Event);
End;



Procedure TLocalInfoDynamicDebit.LockFreshRashetHint;
Var Ass : DocumentEdit;
    Test : Word;
    R : TRect;
    s,ws : TMyString;
    SClientKod,SDAte,STime:TDateString;
    SSumma :String[CIZena];
    Find : Boolean;
    Kto : String[CKto];
    ClientOplataFile : File;
    ClientOplata : PBufClientOplataRealizasiaType;
    cpl:ClientOplataRealizasiaType;
    BakFileMode,c,Count : Word;
    SDAteDoc,SDAteC:TDateString;
Begin
{memc;}
If (LocalDolgList^.State and sfFocused <> 0) And (LocalDolgList^.List<>Nil)And(LocalDolgList^.List^.Count>=1) Then
 Begin
  s:=LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count);
  If s <> PrevCurrent Then
  Begin
  PrevCurrent:=S;
{ Ass.EditPosition:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDate+1,CDocNumer);}
  Ass.EditPosition:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  ClearChar(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
{ Ass.D:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1,CDate);}
  Ass.D:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1,CDate);
  DelSpace(Ass.D);
  SDate:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1,CDate);
  STime:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1+
  CDate+1,CDate);
  SSumma:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1+
  CDate+1+CDate+1,  CIZena);
  Kto:=Copy(LocalDolgList^.GetText(LocalDolgList^.Focused,LocalDolgList^.List^.Count),1+1+CDocNumer+1+CDate+1+CDate+1+CDate+
  1+CDate+1+CIZena+1+CIZena+1+(CLitrMantissa+1)+1,CKto);
  DelSpace(sdate);
  DelSpace(stime);
  DelSpace(ssumma);

  PStaticText(ControlClientLock)^.GetText(ws);
  System.Delete(ws,1,1);
  SClientKod:=Copy(ws,1+CClient+1,CClientKod);

 BakFileMode:=FileMode;
 FileMode:=$42;
  Assign (ClientOplataFile,Path^.Dat.ToClientOplata+SClientKod+'.cpl');
  Test:=IOResult;
  Reset (ClientOplataFile,SizeOf(ClientOplataRealizasiaType));
  Test:=IOResult;
  FileMode:=BakFileMode;
  If Test=0 Then
  Begin
   Find:=False;
   DelZerro(Ass.EditPosition);
   While Not(Eof(ClientOplataFile))And Not(find) Do
    Begin
  New(ClientOplata,Init);
  BlockRead(ClientOplataFile,ClientOplata^.Point,BufferOpl,Count);
For c:=1 To Count Do
Begin
    With ClientOplata^.Point.Dat[c] Do
    Begin
        ClearChar(Document);
        DelZerro(Document);
        SDateDoc:=DateToDateString(DateMask,DAteDoc);
        SDatec:=DateToDateString(DateMask,DAtec);

        If (StrToInt(Document)=StrToInt(Ass.EditPosition)) And (Ass.D=SDateDoc)
    And (SDateC=SDate) And (TimeToTimeString('hh:mm:ss',TimeC)=STime){ And (SummaZ=SSumma)} Then
         Begin
          Find:=True;
          CPl:=ClientOplata^.Point.Dat[c];
          Break;
         End;
    End;{With}
End;{For}
Dispose(ClientOplata,Done);
    End;{While}
System.Close(ClientOplataFile);
    If Not(Find) Then
        Begin
         MessageBox(^M+#3'Документ '+Ass.EditPosition+' в файле оплаты долгов клиента не найден!',Nil,mfError+mfCancelButton);
         Exit;
        End;

Dispose(ControlPP,Done);
R.Assign(24, 20, 34, 21);
ControlPP := New(PColoredText, Init(R, #3+CPL.Bn.NPLat, $7E));
LocalInfo^.Insert(ControlPP);

Dispose(ControlDatePP,Done);
R.Assign(24, 19, 32, 20);
If CPL.Rashet in [0,1] Then
ControlDatePP := New(PColoredText, Init(R, #3+CPL.Bn.Date, $7E))
Else
ControlDatePP := New(PColoredText, Init(R, #3'СМ.ВЕКС.'{+CPL.Veksel.Exampl[1].Data}, $7E));

LocalInfo^.Insert(ControlDatePP);

Dispose(ControlSummaPP,Done);
R.Assign(45, 19, 60, 20);
ControlSummaPP := New(PColoredText, Init(R, #3+CPL.Bn.Summa, $7E));
LocalInfo^.Insert(ControlSummaPP);

Dispose(ControlBank,Done);
R.Assign(45, 20, 78, 21);
If CPL.Rashet in [0,1] Then
ControlBank := New(PColoredText, Init(R, GetBankField(FBank,CPL.Bn.BankKod), $7E))
Else
ControlBank := New(PColoredText, Init(R, 'СМ.ВЕКС.'{CPL.Veksel.Exampl[1].Numer}+'...', $7E));
LocalInfo^.Insert(ControlBank);

Dispose(ControlRashet,Done);
R.Assign(10, 19, 13, 20);

Case CPL.Rashet Of
0:ControlRashet := New(PColoredText, Init(R, #3'Нал', $7E));
1:ControlRashet := New(PColoredText, Init(R, #3'Б/Н', $7E));
2:ControlRashet := New(PColoredText, Init(R, #3'Вкс', $7E));
Else;
End;
LocalInfo^.Insert(ControlRashet);

Dispose(ControlPrim,Done);
R.Assign(13, 21, 53, 22);
If CPL.Vozwrat Then
ControlPrim := New(PColoredText, Init(R, #3'Возврат по документу N'+CPL.DocNumerReturn+
 ' от '+DateToDateString(DAteMask,CPL.DocDateReturn), $7E))
 Else
ControlPrim := New(PColoredText, Init(R, #3'', $7E));
LocalInfo^.Insert(ControlPrim);

Dispose(ControlPassword,Done);
R.Assign(64, 21, 76, 22);
ControlPassword := New(PColoredText, Init(R, #3+Kto, $7E));
LocalInfo^.Insert(ControlPassword);
  End
  Else
   MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToClientOplata+PrevS+'.cpl!',Nil,mfError+mfCancelButton);
   Redraw;
 End;
 End;
End;



Destructor TLocalInfoDynamicDebit.Done;
Begin
Dispose(ControlClientLock,Done);
Dispose(ControlPassword,Done);
Dispose(ControlPrim,Done);
Dispose(ControlRashet,Done);
Dispose(ControlBank,Done);
Dispose(ControlSummaPP,Done);
Dispose(ControlDatePP,Done);
Dispose(ControlPP,Done);
Dispose(LocalDolgList,Done);
TDialog.Done;
End;





End.