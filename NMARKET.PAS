{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


{$I Compile.INC}

Unit NMarket;

Interface


Uses Dialogs,Drivers,Glob,ServStr;

Type
  PNetTestWindow = ^TNetTestWindow;
  TNetTestWindow = object(TDialog)
    Function Start(l,PrevMarket:PSuperMarketType;Itog:Real;LockBox:PBox):Boolean;
    procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


VAr

 NetTestWindow : PNetTestWindow;
 NetTestBox : PBox;
 PrevNet : String;


 Implementation

uses CPrihod,App,Objects,Views,Colortxt,DbEngine;

VAr

 ControlError,ControlNetNDS,ControlNetKol,ControlNetZena,
 ControlNetNalog: PView;






Procedure TNetTestWindow.Refresh;
Var r :TRect;
    Ansver,Res : String;
    i : Word;
    Otd,A : ArtikulStr;

Begin
If NetTestBox^.List^.Count>0 Then
Begin
PrevNet:=NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count);
Res:=Copy(PrevNet,1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CLitr+1+CLitr+1+CZena+1+CLitr+1+CZena+1,
     Ord(PrevNet[0])-1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CLitr+1+CLitr+1+CZena+1+CLitr+1+CZena+1);
a:=Copy(NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count),1+CNAme+1,CArtikul);
Otd:=Copy(NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count),1+CNAme+1+CArtikul+1,COne);

{0-все ок
 1-наименование запретили к продаже
 2-отсутствует необходимое количество
 3-изменена цена
 4-изменена ставка ндс
 5-вид НДС
 6-изменена ставка нп
 7-вид НП
 8-изменена ставка скидки (авто)
 9-изменена закупка }

Ansver[0]:=#0;

For i:=1 To Ord(Res[0]) Do
 Begin
  Case StrToInt(Res[i]) Of
  1:If Ord(Ansver[0])<55 then Ansver:=Ansver+'запрет к продаже; '
    else Ansver:=Ansver+^M+'запрет к продаже; ';
  2:If Ord(Ansver[0])<55 then Ansver:=Ansver+'нет необх.колич.; '
    else Ansver:=Ansver+'нет необх.колич.; ';
  3:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.цена; '
    else Ansver:=Ansver+'измен.цена; ';
  4:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.НДС; '
    else Ansver:=Ansver+'измен.НДС; ';
  5:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.вид НДС; '
    else Ansver:=Ansver+'измен.вид НДС; ';
  6:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.НП; '
    else Ansver:=Ansver+'измен.НП; ';
  7:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.вид НП; '
    else Ansver:=Ansver+'измен.вид НП; ';
  8:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.скид.; '
    else Ansver:=Ansver+'измен.скид.; ';
  9:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.закуп.; '
    else Ansver:=Ansver+'измен.закуп.; ';
  Else ansver:='???; ';
  End;
 End;

Dispose(ControlError,Done);
R.Assign(21, 16, 78, 18);
ControlError := New(PColoredText, Init(R,#3+Ansver, $5f));
NetTestWindow^.Insert(ControlError);


AnsVer:=BakGetField(FDiv,a,StrToInt(Otd));
DelSpace(ansver);
Dispose(ControlNetKol,Done);
R.Assign(28, 15, 33, 16);
Controlnetkol := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetkol);


AnsVer:=BakGetField(FRZena,a,0);
DelSpace(ansver);

Dispose(ControlNetZena,Done);
R.Assign(42, 15, 50, 16);
Controlnetzena := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetzena);

AnsVer:=GetIDField(FNDS,a);
DelSpace(ansver);

Dispose(ControlNetNDS,Done);
R.Assign(58, 15, 63, 16);
Controlnetnds := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetnds);

AnsVer:=GetIDField(FNalog,a);
DelSpace(ansver);
Dispose(ControlNetNAlog,Done);
R.Assign(70, 15, 75, 16);
Controlnetnalog := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetnalog);
Redraw;
End;

End;




Function TNetTestWindow.Start(L,PrevMarket:PSuperMarketType;Itog:Real;LockBox:PBox):Boolean;
Label 1,2;
Var R:TRect;
    Control : PView;
    ssk,ErrorStr:AllStr;
    s,Msg:String;
    i : Word;
    FindError:Boolean;
    Temp : PBox;
    sklad,res:longint;
    StopProcess,LogikZena : boolean;

Begin
Start:=True;

R.Assign(0, 0, 0, 0);
Temp := New(PBox, Init(R, 1, Nil));
Temp^.NewList(New(PTextCollection, Init(0,1)));

{0-все ок
 1-наименование запретили к продаже
 2-отсутствует необходимое количество
 3-изменена цена
 4-изменена ставка ндс
 5-вид НДС
 6-изменена ставка нп
 7-вид НП
 8-изменена ставка скидки (авто)
 9-закупка}


FindError:=False;

StopProcess:=False;
 If L^.Dat.Amount>0 Then
  Begin
   For i:=1 To L^.Dat.Amount Do
    Begin
     ErrorStr[0]:=#0;
     {наименование запретили к продаже}
     If Not((L^.Dat.OperatorSelector=1)And(L^.Dat.DocSelector=0)) Then
     {если не межскладская первозка}
     If (GetIdMArket(L^.Dat.MarketElement[i].BazKod)=0) Then ErrorStr:=ErrorStr+'1';

     {в отделении отсутствует необходимое количество}
     res:=0;
     If Status=DocEdit Then
     res:=GetKolMarket(L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionNumber,PrevMarket);
     Res:=StrToInt(L^.Dat.MarketElement[i].Input.Kol)-res;
     sklad:=StrToInt(BakGetField(FDiv,L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionNumber));
     If (Sklad-res)<0 Then
     Begin
      ErrorStr:=ErrorStr+'2';
      Msg:=IntToStr(Sklad,CKol);
      DelSpace(Msg);
      NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),2,Msg);
     End;

     {изменена цена оптовая или розничная}
     If Status=DocNormal Then LogikZena:=True
     Else
      Begin
       {проверяем бала ли позиция в накладной}
       LogikZena:=Not FindMarket(L^.Dat.MarketElement[i].BazKod,PrevMarket);
       If LogikZena Then{если позиции не бало в накладной}
        Begin
         LogikZena:=TestMarket(L^.Dat.MarketElement[i].Bazkod,PrevMarket,0,True);
         {если была переоценка после выписки накладной тогда остановить процесс
	    и запретить выписку товара LogikZena=True}
         If Not(LogikZena) Then StopProcess:=True;
         If Not(LogikZena) Then Goto 2;
        End
       Else             {если позиция была в накладной}
        Begin
                                                                       {не выводить сообщение}
          If Not(TestMarket(L^.Dat.MarketElement[i].Bazkod,PrevMarket,0,False)) Then
            Begin{если переоценки после выписки первого варианта не было}
             LogikZena:=True;
            End
 		Else
  		  Begin{если переоценка была после выписки}
             If GetFullKolMArket(L^.Dat.MarketElement[i].Bazkod,L)>
                GetFullKolMArket(L^.Dat.MarketElement[i].Bazkod,PrevMarket) Then
               Begin{если количество новое изменилось в большую сторону}
                LogikZena:=FAlse;
                StopProcess:=True;
                MessageBox(#3'',Nil,mfError+mfCancelButton);
                MessageBox(#3+'Товар с кодом ('+L^.Dat.MarketElement[i].Bazkod+') после выписки документа уже был переоценен!'+
                           'Редактирование этой позиции документа запрещено!',Nil,mfError+mfCancelButton);
                Goto 2;
               End{конец уловия если новое количество не изменилось}
              Else
               Begin{если новое количество не изменилось или стало меньше}
                LogikZena:=False;
               End;
 		  End;
        End;{Else если позиция была в наклдной}
      End;{Status=DocEdit}
{Алгоритм проверки:
1 позия была в накладной?
 да - была ли переоценка?
  да - новое количество больше старого?
   да - запрет выписки!
  нет - цену не проверяем
 нет - проверяем цену
...}
     If LogikZena Then
     If((StrToReal(BakGetField(FRZena,L^.Dat.MarketElement[i].BazKod,0)))<>
           (StrToReal(L^.Dat.MarketElement[i].Input.R_Zena))) Or
       ((StrToReal(BakGetField(FOZena,L^.Dat.MarketElement[i].BazKod,0)))<>
           (StrToReal(L^.Dat.MarketElement[i].Input.O_Zena))) Then
        Begin
         ErrorStr:=ErrorStr+'3';
         Msg:=BakGetField(FRZena,L^.Dat.MarketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),3,Msg);
         Msg:=BakGetField(FOZena,L^.Dat.MarketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),3,Msg);
        End;

     {изменена ставка ндс}
    If Status<>DocEdit Then
     If (StrToReal(GetIDField(FNDS,L^.Dat.MarketElement[i].BazKod)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.NDS)) Then
        Begin
{        ErrorStr:=ErrorStr+'4';}
         Msg:=GetIDField(FNDS,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),4,Msg);
        End;

     {изменен вид ндс}
    If Status<>DocEdit Then
     If (StrToInt(GetIDField(FVidNDS,L^.Dat.MarketElement[i].BazKod)))<>
           (L^.Dat.MarketElement[i].Input.VidNDS) Then
        Begin
{        ErrorStr:=ErrorStr+'5';}
         Msg:=GetIDField(FVidNDS,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),5,Msg);
        End;

     {изменена ставка нп}
    If Status<>DocEdit Then
     If (StrToReal(GetIDField(FNalog,L^.Dat.MarketElement[i].BazKod)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.SpecNalog)) Then
        Begin
        {ErrorStr:=ErrorStr+'6';}
         Msg:=GetIDField(FNalog,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),6,Msg);
        End;

     {изменен вид нп}
    If Status<>DocEdit Then
     If (StrToInt(GetIDField(FVidNalog,L^.Dat.MarketElement[i].BazKod)))<>
        (L^.Dat.MarketElement[i].Input.VidNAlog) Then
        Begin
         {ErrorStr:=ErrorStr+'7';}
         Msg:=GetIDField(FVidNalog,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),7,Msg);
        End;

     {изменена таблица авто-скидок}
     {If Skidka=0 Then}
     Str((GetSkidkaProz(L^.Dat.MarketElement[i].BazKod,Itog)):CLitr:CMantissa,Msg);
     If Skidka=2 Then
      Str((GetShkalaProz(L^.Dat.MarketElement[i].BazKod,ClientShkala)):CLitr:CMantissa,Msg);
     DelSpace(msg);
{    If Skidka in [0,2] Then}
     If (Msg<>L^.Dat.MarketElement[i].Input.proz) Then ErrorStr:=ErrorStr+'8';

     {изменена закупочная цена}
     If (StrToReal(BakGetField(FZakupka,L^.Dat.MarketElement[i].BazKod,0)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.Zakupka)) Then
        Begin
        {ErrorStr:=ErrorStr+'9';}
         Msg:=BakGetField(FZakupka,L^.Dat.MarketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),9,Msg);
        End;



     If ErrorStr[0]<>#0 Then
      Begin
{наименование код n колич цена ндс нп скидка руч скидка авто errorstr}
       s:=GetIdField(FName,L^.Dat.MarketElement[i].BazKod);
       DelSpaceRight(s);
       Format(s,CName);
       DelSpace(L^.Dat.MarketElement[i].Input.Kol);
       Format(L^.Dat.MarketElement[i].Input.Kol,CKol);
       DelSpace(L^.Dat.MarketElement[i].Input.Zena);
       Format(L^.Dat.MarketElement[i].Input.Zena,CZena);
       DelSpace(L^.Dat.MarketElement[i].Input.NDS);
       Format(L^.Dat.MarketElement[i].Input.NDS,CLitr);
       DelSpace(L^.Dat.MarketElement[i].Input.SpecNalog);
       Format(L^.Dat.MarketElement[i].Input.SpecNAlog,CLitr);
       DelSpace(L^.Dat.MarketElement[i].Input.Skidka);
       Format(L^.Dat.MarketElement[i].Input.Skidka,CZena);
       DelSpace(L^.Dat.MarketElement[i].Input.Proz);
       Format(L^.Dat.MarketElement[i].Input.Proz,CLitr);
       DelSpace(L^.Dat.MarketElement[i].Input.Zakupka);
       Format(L^.Dat.MarketElement[i].Input.Zakupka,CZena);
       s:=s+'│'+L^.Dat.MarketElement[i].BazKod+'│'+IntToSTr(L^.Dat.MarketElement[i].Input.DivisionNumber,COne)+'│'
          +L^.Dat.MarketElement[i].Input.Kol+'│'+L^.Dat.MarketElement[i].Input.Zena+'│'+L^.Dat.MarketElement[i].Input.NDS+'│'+
       +L^.Dat.MarketElement[i].Input.SpecNAlog+'│'+L^.Dat.MarketElement[i].Input.Skidka+'│'+
       +L^.Dat.MarketElement[i].Input.Proz+'│'+L^.Dat.MarketElement[i].Input.Zakupka+'│'+ErrorStr;
       Temp^.List^.Insert(NewStr(s));
       Temp^.SetRange(Temp^.List^.Count);
       DelSpace(L^.Dat.MarketElement[i].Input.Kol);
       DelSpace(L^.Dat.MarketElement[i].Input.Zakupka);
       DelSpace(L^.Dat.MarketElement[i].Input.Zena);
       DelSpace(L^.Dat.MarketElement[i].Input.NDS);
       DelSpace(L^.Dat.MarketElement[i].Input.SpecNalog);
       DelSpace(L^.Dat.MarketElement[i].Input.Skidka);
       DelSpace(L^.Dat.MarketElement[i].Input.Proz);
       findError:=true;
       start:=false;
      End;
   End;
 end;{if}

If Not(FindError) Then
Begin
 Dispose(Temp,Done);
 Exit;
End;

2:
UnLockAllPosition(LockBox);

If StopProcess Then
 Begin
  Dispose(Temp,Done);
  Exit;
 End;


NetBeep;
R.Assign(0, 3, 79, 22);
New(NetTestWindow, Init(R, 'Сетевое предупреждение'));
NetTestWindow^.Options := NetTestWindow^.Options or ofCenterX or ofCenterY;
NetTestWindow^.HelpCtx:=$E090;

R.Assign(78, 2, 79, 15);
Control := New(PScrollBar, Init(R));
NetTestWindow^.Insert(Control);

R.Assign(1, 2, 78, 15);
NetTestBox := New(PBox, Init(R, 1, PScrollbar(Control)));
NetTestBox^.NewList(New(PTextCollection, Init(0,1)));

If (Temp^.List^.Count)>0 Then
  For i:=0 To Temp^.List^.Count-1 Do
   Begin
    s:=Temp^.GetText(i,Temp^.List^.Count);
    NetTestBox^.List^.Insert(NewStr(s));
    NetTestBox^.SetRange(NetTestBox^.List^.Count);
   End;
Dispose(Temp,Done);

NetTestWindow^.Insert(NetTestBox);

R.Assign(1, 1, 77, 2);
NetTestWindow^.Insert(New(PLabel,
Init(R, 'Наименование товара         Код  N Колич.Цена лоб. НДС   НП    Скидка  Проц',
NetTestBox)));

R.Assign(1, 16, 21, 17);
Control := New(PColoredText, Init(R, 'Произошли изменения:', $7E));
NetTestWindow^.Insert(Control);

R.Assign(21, 16, 78, 18);
ControlError := New(PColoredText, Init(R,#3+'', $5f));
NetTestWindow^.Insert(ControlError);

R.Assign(21, 15, 28, 16);
Control := New(PColoredText, Init(R, 'Колич.:', $74));
nettestwindow^.Insert(Control);

R.Assign(28, 15, 33, 16);
Controlnetkol := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetkol);

R.Assign(37, 15, 42, 16);
Control := New(PColoredText, Init(R, 'Цена:', $74));
nettestwindow^.Insert(Control);

R.Assign(42, 15, 50, 16);
Controlnetzena := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetzena);

R.Assign(54, 15, 58, 16);
Control := New(PColoredText, Init(R, 'НДС:', $74));
nettestwindow^.Insert(Control);

R.Assign(58, 15, 63, 16);
Controlnetnds := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetnds);

R.Assign(67, 15, 70, 16);
Control := New(PColoredText, Init(R, 'НП:', $74));
nettestwindow^.Insert(Control);

R.Assign(70, 15, 75, 16);
Controlnetnalog := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetnalog);

R.Assign(4, 15, 16, 16);
Control := New(PColoredText, Init(R, 'На складе: ', $71));
nettestwindow^.Insert(Control);

NetTestWindow^.SelectNext(False);
PrevNet[0]:=#0;
DeskTop^.EXecView(NetTestWindow);
Dispose(Control,Done);
Dispose(NetTestWindow,Done);

1:

  If Prodaga^.List^.Count>0 Then
   Begin
    For i:=0 to prodaga^.list^.Count-1 Do
     Begin
     {колич}
      SSk:=Copy(Prodaga^.GetText(i,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1,CKol);
      DelSpace(sSk);

      If StrToInt(ssk)=0 Then
      Begin
       Prodaga^.List^.AtFree(i);
       Prodaga^.SetRange(Prodaga^.List^.Count);
       If Prodaga^.Focused>0 Then Prodaga^.FocusItem(Prodaga^.Focused);
       If (Prodaga^.Focused>=Prodaga^.List^.Count) and(Prodaga^.Focused>0) Then
       Prodaga^.FocusItem(Prodaga^.Focused-1);
       Goto 1;
      End;
     End;
   End;

End;


Procedure TNetTestWindow.HandleEvent(Var Event:TEvent);
Var s: String;
Begin
inherited handleEvent(Event);
 if (NetTestBox^.State and sfFocused <> 0)  And(NetTestBox^.List<>Nil) And (NetTestBox^.List^.Count>=1)Then
  Begin
   s:=NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count);
   If s <> PrevNet Then
    Begin
     Refresh;
    End
  End;
End;


Destructor TNetTestWindow.Done;
Begin
ClearFind;
Dispose(ControlError,Done);
Dispose(ControlNetKol,Done);
Dispose(ControlNetZena,Done);
Dispose(ControlNetNDS,Done);
Dispose(ControlNetNalog,Done);
TDialog.Done;
End;

End.

(*

Procedure TNetTestWindow.Refresh;
Var r :TRect;
    Ansver,Res : String;
    i : Word;
    Otd,A : ArtikulStr;

Begin
If NetTestBox^.List^.Count>0 Then
Begin
PrevNet:=NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count);
Res:=Copy(PrevNet,1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CLitr+1+CLitr+1+CZena+1+CLitr+1+CZena+1,
     Ord(PrevNet[0])-1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CLitr+1+CLitr+1+CZena+1+CLitr+1+CZena+1);
a:=Copy(NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count),1+CNAme+1,CArtikul);
Otd:=Copy(NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count),1+CNAme+1+CArtikul+1,COne);

{0-все ок
 1-наименование запретили к продаже
 2-отсутствует необходимое количество
 3-изменена цена
 4-изменена ставка ндс
 5-вид НДС
 6-изменена ставка нп
 7-вид НП
 8-изменена ставка скидки (авто)
 9-изменена закупка }

Ansver[0]:=#0;

For i:=1 To Ord(Res[0]) Do
 Begin
  Case StrToInt(Res[i]) Of
  1:If Ord(Ansver[0])<55 then Ansver:=Ansver+'запрет к продаже; '
    else Ansver:=Ansver+^M+'запрет к продаже; ';
  2:If Ord(Ansver[0])<55 then Ansver:=Ansver+'нет необх.колич.; '
    else Ansver:=Ansver+'нет необх.колич.; ';
  3:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.цена; '
    else Ansver:=Ansver+'измен.цена; ';
  4:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.НДС; '
    else Ansver:=Ansver+'измен.НДС; ';
  5:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.вид НДС; '
    else Ansver:=Ansver+'измен.вид НДС; ';
  6:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.НП; '
    else Ansver:=Ansver+'измен.НП; ';
  7:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.вид НП; '
    else Ansver:=Ansver+'измен.вид НП; ';
  8:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.скид.; '
    else Ansver:=Ansver+'измен.скид.; ';
  9:If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.закуп.; '
    else Ansver:=Ansver+'измен.закуп.; ';
  Else ansver:='???; ';
  End;
 End;

Dispose(ControlError,Done);
R.Assign(21, 16, 78, 18);
ControlError := New(PColoredText, Init(R,#3+Ansver, $5f));
NetTestWindow^.Insert(ControlError);


AnsVer:=BakGetField(FDiv,a,StrToInt(Otd));
DelSpace(ansver);
Dispose(ControlNetKol,Done);
R.Assign(28, 15, 33, 16);
Controlnetkol := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetkol);


AnsVer:=BakGetField(FRZena,a,0);
DelSpace(ansver);

Dispose(ControlNetZena,Done);
R.Assign(42, 15, 50, 16);
Controlnetzena := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetzena);

AnsVer:=GetIDField(FNDS,a);
DelSpace(ansver);

Dispose(ControlNetNDS,Done);
R.Assign(58, 15, 63, 16);
Controlnetnds := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetnds);

AnsVer:=GetIDField(FNalog,a);
DelSpace(ansver);
Dispose(ControlNetNAlog,Done);
R.Assign(70, 15, 75, 16);
Controlnetnalog := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetnalog);
Redraw;
End;

End;




Function TNetTestWindow.Start(L:PSuperMarketType;Itog:Real;LockBox:PBox):Boolean;
Label 1,2;
Var R:TRect;
    Control : PView;
    ssk,ErrorStr:AllStr;
    s,Msg:String;
    i : Word;
    FindError:Boolean;
    Temp : PBox;
    sklad,res:longint;
    StopProcess,LogikZena : boolean;

Begin

Start:=True;

R.Assign(0, 0, 0, 0);
Temp := New(PBox, Init(R, 1, Nil));
Temp^.NewList(New(PTextCollection, Init(0,1)));

{0-все ок
 1-наименование запретили к продаже
 2-отсутствует необходимое количество
 3-изменена цена
 4-изменена ставка ндс
 5-вид НДС
 6-изменена ставка нп
 7-вид НП
 8-изменена ставка скидки (авто)
 9-закупка}


FindError:=False;

StopProcess:=False;
 If L^.Dat.Amount>0 Then
  Begin
   For i:=1 To L^.Dat.Amount Do
    Begin
     ErrorStr[0]:=#0;
     {наименование запретили к продаже}
     If Not((L^.Dat.OperatorSelector=1)And(L^.Dat.DocSelector=0)) Then
     {если не межскладская первозка}
     If (GetIdMArket(L^.Dat.MarketElement[i].BazKod)=0) Then ErrorStr:=ErrorStr+'1';

     {в отделении отсутствует необходимое количество}
     res:=0;
     If Status=DocEdit Then
     res:=GetKolMarket(L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionNumber,PrevMarket);
     Res:=StrToInt(L^.Dat.MarketElement[i].Input.Kol)-res;
     sklad:=StrToInt(BakGetField(FDiv,L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionNumber));
     If (Sklad-res)<0 Then
     Begin
      ErrorStr:=ErrorStr+'2';
      Msg:=IntToStr(Sklad,CKol);
      DelSpace(Msg);
      NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),2,Msg);
     End;

     {изменена цена оптовая или розничная}
     If Status=DocNormal Then LogikZena:=True
     Else
      Begin
       {проверяем бала ли позиция в накладной}
       LogikZena:=Not FindMarket(L^.Dat.MarketElement[i].BazKod,PrevMarket);
       If LogikZena Then{если позиции не бало в накладной}
        Begin
         LogikZena:=TestMarket(L^.Dat.MarketElement[i].Bazkod,PrevMarket,0,True);
         {если была переоценка после выписки накладной тогда остановить процесс
	    и запретить выписку товара LogikZena=True}
         If Not(LogikZena) Then StopProcess:=True;
         If Not(LogikZena) Then Goto 2;
        End
       Else             {если позиция была в накладной}
        Begin
                                                                       {не выводить сообщение}
          If Not(TestMarket(L^.Dat.MarketElement[i].Bazkod,PrevMarket,0,False)) Then
            Begin{если переоценки после выписки первого варианта не было}
             LogikZena:=True;
            End
		Else
  		  Begin{если переоценка была после выписки}
             If GetFullKolMArket(L^.Dat.MarketElement[i].Bazkod,L)>
                GetFullKolMArket(L^.Dat.MarketElement[i].Bazkod,PrevMarket) Then
               Begin{если количество новое изменилось в большую сторону}
                LogikZena:=FAlse;
                StopProcess:=True;
                MessageBox(#3'',Nil,mfError+mfCancelButton);
                MessageBox(#3+'Товар с кодом ('+L^.Dat.MarketElement[i].Bazkod+') после выписки документа уже был переоценен!'+
                           'Редактирование этой позиции документа запрещено!',Nil,mfError+mfCancelButton);
                Goto 2;
               End{конец уловия если новое количество не изменилось}
              Else
               Begin{если новое количество не изменилось или стало меньше}
                LogikZena:=False;
               End;
 		  End;
        End;{Else если позиция была в наклдной}
      End;{Status=DocEdit}
{Алгоритм проверки:
1 позия была в накладной?
 да - была ли переоценка?
  да - новое количество больше старого?
   да - запрет выписки!
  нет - цену не проверяем
 нет - проверяем цену
...}
     If LogikZena Then
     If((StrToReal(BakGetField(FRZena,L^.Dat.MarketElement[i].BazKod,0)))<>
           (StrToReal(L^.Dat.MarketElement[i].Input.R_Zena))) Or
       ((StrToReal(BakGetField(FOZena,L^.Dat.MarketElement[i].BazKod,0)))<>
           (StrToReal(L^.Dat.MarketElement[i].Input.O_Zena))) Then
        Begin
         ErrorStr:=ErrorStr+'3';
         Msg:=BakGetField(FRZena,L^.Dat.MarketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),3,Msg);
         Msg:=BakGetField(FOZena,L^.Dat.MarketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),3,Msg);
        End;

     {изменена ставка ндс}
    If Status<>DocEdit Then
     If (StrToReal(GetIDField(FNDS,L^.Dat.MarketElement[i].BazKod)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.NDS)) Then
        Begin
{        ErrorStr:=ErrorStr+'4';}
         Msg:=GetIDField(FNDS,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),4,Msg);
        End;

     {изменен вид ндс}
    If Status<>DocEdit Then
     If (StrToInt(GetIDField(FVidNDS,L^.Dat.MarketElement[i].BazKod)))<>
           (L^.Dat.MarketElement[i].Input.VidNDS) Then
        Begin
{        ErrorStr:=ErrorStr+'5';}
         Msg:=GetIDField(FVidNDS,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),5,Msg);
        End;

     {изменена ставка нп}
    If Status<>DocEdit Then
     If (StrToReal(GetIDField(FNalog,L^.Dat.MarketElement[i].BazKod)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.SpecNalog)) Then
        Begin
        {ErrorStr:=ErrorStr+'6';}
         Msg:=GetIDField(FNalog,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),6,Msg);
        End;

     {изменен вид нп}
    If Status<>DocEdit Then
     If (StrToInt(GetIDField(FVidNalog,L^.Dat.MarketElement[i].BazKod)))<>
        (L^.Dat.MarketElement[i].Input.VidNAlog) Then
        Begin
         {ErrorStr:=ErrorStr+'7';}
         Msg:=GetIDField(FVidNalog,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),7,Msg);
        End;

     {изменена таблица авто-скидок}
     {If Skidka=0 Then}
     Str((GetSkidkaProz(L^.Dat.MarketElement[i].BazKod,Itog)):CLitr:CMantissa,Msg);
     If Skidka=2 Then
     Str((GetShkalaProz(L^.Dat.MarketElement[i].BazKod,ClientShkala)):CLitr:CMantissa,Msg);
     DelSpace(msg);
{    If Skidka in [0,2] Then}
     If (Msg<>L^.Dat.MarketElement[i].Input.proz) Then ErrorStr:=ErrorStr+'8';

     {изменена закупочная цена}
     If (StrToReal(BakGetField(FZakupka,L^.Dat.MarketElement[i].BazKod,0)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.Zakupka)) Then
        Begin
        {ErrorStr:=ErrorStr+'9';}
         Msg:=BakGetField(FZakupka,L^.Dat.MarketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),9,Msg);
        End;



     If ErrorStr[0]<>#0 Then
      Begin
{наименование код n колич цена ндс нп скидка руч скидка авто errorstr}
       s:=GetIdField(FName,L^.Dat.MarketElement[i].BazKod);
       DelSpaceRight(s);
       Format(s,CName);
       DelSpace(L^.Dat.MarketElement[i].Input.Kol);
       Format(L^.Dat.MarketElement[i].Input.Kol,CKol);
       DelSpace(L^.Dat.MarketElement[i].Input.Zena);
       Format(L^.Dat.MarketElement[i].Input.Zena,CZena);
       DelSpace(L^.Dat.MarketElement[i].Input.NDS);
       Format(L^.Dat.MarketElement[i].Input.NDS,CLitr);
       DelSpace(L^.Dat.MarketElement[i].Input.SpecNalog);
       Format(L^.Dat.MarketElement[i].Input.SpecNAlog,CLitr);
       DelSpace(L^.Dat.MarketElement[i].Input.Skidka);
       Format(L^.Dat.MarketElement[i].Input.Skidka,CZena);
       DelSpace(L^.Dat.MarketElement[i].Input.Proz);
       Format(L^.Dat.MarketElement[i].Input.Proz,CLitr);
       DelSpace(L^.Dat.MarketElement[i].Input.Zakupka);
       Format(L^.Dat.MarketElement[i].Input.Zakupka,CZena);
       s:=s+'│'+L^.Dat.MarketElement[i].BazKod+'│'+IntToSTr(L^.Dat.MarketElement[i].Input.DivisionNumber,COne)+'│'
          +L^.Dat.MarketElement[i].Input.Kol+'│'+L^.Dat.MarketElement[i].Input.Zena+'│'+L^.Dat.MarketElement[i].Input.NDS+'│'+
       +L^.Dat.MarketElement[i].Input.SpecNAlog+'│'+L^.Dat.MarketElement[i].Input.Skidka+'│'+
       +L^.Dat.MarketElement[i].Input.Proz+'│'+L^.Dat.MarketElement[i].Input.Zakupka+'│'+ErrorStr;
       Temp^.List^.Insert(NewStr(s));
       Temp^.SetRange(Temp^.List^.Count);
       DelSpace(L^.Dat.MarketElement[i].Input.Kol);
       DelSpace(L^.Dat.MarketElement[i].Input.Zakupka);
       DelSpace(L^.Dat.MarketElement[i].Input.Zena);
       DelSpace(L^.Dat.MarketElement[i].Input.NDS);
       DelSpace(L^.Dat.MarketElement[i].Input.SpecNalog);
       DelSpace(L^.Dat.MarketElement[i].Input.Skidka);
       DelSpace(L^.Dat.MarketElement[i].Input.Proz);
       findError:=true;
       start:=false;
      End;
   End;
 end;{if}

If Not(FindError) Then
Begin
 Dispose(Temp,Done);
 Exit;
End;

2:
UnLockAllPosition(LockBox);

If StopProcess Then
 Begin
  Dispose(Temp,Done);
  Exit;
 End;


NetBeep;
R.Assign(0, 3, 79, 22);
New(NetTestWindow, Init(R, 'Сетевое предупреждение'));
NetTestWindow^.Options := NetTestWindow^.Options or ofCenterX or ofCenterY;
NetTestWindow^.HelpCtx:=$E090;

R.Assign(78, 2, 79, 15);
Control := New(PScrollBar, Init(R));
NetTestWindow^.Insert(Control);

R.Assign(1, 2, 78, 15);
NetTestBox := New(PBox, Init(R, 1, PScrollbar(Control)));
NetTestBox^.NewList(New(PTextCollection, Init(0,1)));

If (Temp^.List^.Count)>0 Then
  For i:=0 To Temp^.List^.Count-1 Do
   Begin
    s:=Temp^.GetText(i,Temp^.List^.Count);
    NetTestBox^.List^.Insert(NewStr(s));
    NetTestBox^.SetRange(NetTestBox^.List^.Count);
   End;
Dispose(Temp,Done);

NetTestWindow^.Insert(NetTestBox);

R.Assign(1, 1, 77, 2);
NetTestWindow^.Insert(New(PLabel,
Init(R, 'Наименование товара         Код  N Колич.Цена лоб. НДС   НП    Скидка  Проц',
NetTestBox)));

R.Assign(1, 16, 21, 17);
Control := New(PColoredText, Init(R, 'Произошли изменения:', $7E));
NetTestWindow^.Insert(Control);

R.Assign(21, 16, 78, 18);
ControlError := New(PColoredText, Init(R,#3+'', $5f));
NetTestWindow^.Insert(ControlError);

R.Assign(21, 15, 28, 16);
Control := New(PColoredText, Init(R, 'Колич.:', $74));
nettestwindow^.Insert(Control);

R.Assign(28, 15, 33, 16);
Controlnetkol := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetkol);

R.Assign(37, 15, 42, 16);
Control := New(PColoredText, Init(R, 'Цена:', $74));
nettestwindow^.Insert(Control);

R.Assign(42, 15, 50, 16);
Controlnetzena := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetzena);

R.Assign(54, 15, 58, 16);
Control := New(PColoredText, Init(R, 'НДС:', $74));
nettestwindow^.Insert(Control);

R.Assign(58, 15, 63, 16);
Controlnetnds := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetnds);

R.Assign(67, 15, 70, 16);
Control := New(PColoredText, Init(R, 'НП:', $74));
nettestwindow^.Insert(Control);

R.Assign(70, 15, 75, 16);
Controlnetnalog := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetnalog);

R.Assign(4, 15, 16, 16);
Control := New(PColoredText, Init(R, 'На складе: ', $71));
nettestwindow^.Insert(Control);

NetTestWindow^.SelectNext(False);
PrevNet[0]:=#0;
DeskTop^.EXecView(NetTestWindow);
Dispose(Control,Done);
Dispose(NetTestWindow,Done);

1:

  If Prodaga^.List^.Count>0 Then
   Begin
    For i:=0 to prodaga^.list^.Count-1 Do
     Begin
     {колич}
      SSk:=Copy(Prodaga^.GetText(i,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1,CKol);
      DelSpace(sSk);

      If StrToInt(ssk)=0 Then
      Begin
       Prodaga^.List^.AtFree(i);
       Prodaga^.SetRange(Prodaga^.List^.Count);
       If Prodaga^.Focused>0 Then Prodaga^.FocusItem(Prodaga^.Focused);
       If (Prodaga^.Focused>=Prodaga^.List^.Count) and(Prodaga^.Focused>0) Then
       Prodaga^.FocusItem(Prodaga^.Focused-1);
       Goto 1;
      End;
     End;
   End;
End;


Procedure TNetTestWindow.HandleEvent(Var Event:TEvent);
Var s: String;
Begin
inherited handleEvent(Event);
 if (NetTestBox^.State and sfFocused <> 0)  And(NetTestBox^.List<>Nil) And (NetTestBox^.List^.Count>=1)Then
  Begin
   s:=NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count);
   If s <> PrevNet Then
    Begin
     Refresh;
    End
  End;
End;


Destructor TNetTestWindow.Done;
Begin
ClearFind;
Dispose(ControlError,Done);
Dispose(ControlNetKol,Done);
Dispose(ControlNetZena,Done);
Dispose(ControlNetNDS,Done);
Dispose(ControlNetNalog,Done);
TDialog.Done;
End;


*)


