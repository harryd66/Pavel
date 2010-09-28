{Разобраться с деблокировкой клиентов при отказе от корректировки или формирования
документа возврата}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Return;

Interface


Uses Dialogs,Drivers,Glob,Access,ServStr,MyCalc,Market;

Type
  PPositionReturnWindow = ^TPositionReturnWindow;
  TPositionReturnWindow = object(TDialog)
    Calc        : PMyCalculator;
    Procedure Ini(s:String;Regim:Word);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;

Type
  PSelectReturnDocWindow = ^TSelectReturnDocWindow;
  TSelectReturnDocWindow = object(TDialog)
    Cl : PClientWindow;
    Procedure Parameter(Var Res:Word;Var SVidOperation:Word;
                  Var SDocument,SDate,SClientKod:AllStr;Var Summa,Skidka:AllStr);
{Значения возвращаемые функцией
0 - наличная продажа скидка автоматическая
1 - наличная продажа скидка ручная
2 - закрытая консигнация авоматическая
3 - закрытая консигнация ручная
4 - открытая консигнация автоматическая
5 - открытая консигнация ручная
7 - ошибка ! указан первичный документ закрытой консигнации
8 - ошибка ! отказ от возврата
9 - ошибка ! нет доступа к файлу долгов клиента!
10 - ошибка ! документ не найден в долгах клиента
11 - не могу заблокировать клиента
12 - имеется сформированный, но не введенный на склад возврат по этой накладной}
    procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;



Type
  PReturnWindow = ^TReturnWindow;
  TReturnWindow = object(TDialog)
         Mark : PPositionReturnWindow;
   SRDocWindow: PSelectReturnDocWindow;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure AddName;
    procedure ClearReturnList;
    procedure OpenReturnWindow;
    Function  CalcItogo(Var O,R,Z:Real;Var ItogoNalog:NalogType) : Real;
    Procedure SaveToFile(Var Save : Boolean);
    Procedure Refresh(SDoc,SDate,SClientKod:AllStr;Summa,Skidka:AllStr;VidOperation,VidDocument:Word);
    Procedure ChangeDoc;
    Procedure FreshReturnHint;
    Procedure FreshNaklHint;
    end;

Procedure InputNewVozwratToSklad(As : DocumentEdit);


 Implementation

uses App,DBEngine,Objects, Views, MsgBox,Nastr,Protect,{Calc,}Prihod,NetCall,WinDos,
        ColorTxt,Serv,Validate,TpDate,Vision1,Vision2,Net,NetDbEng,UtilsP;

Type MW = Record
     Pack   : Word;
     Kol    : String[CKol];
     Skidka : String[CZena];
     End;

Var ReturnList,NaklList : PBox;
  ControlVid,ControlClientSelectDoc,ControlDocument,ControlDate : PView;
  ControlRDate,ControlRDoc , ControlDocWith,ControlDateWith ,ControlSkidkaSelWidth,
  ControlSkidkaWidth, ControlSkidkaWidthDoc, ControlTipWidth, ControlSummaWidthDoc,
  ControlKol, ControlZena, ControlPos, ControlZenaWidth, ControlLocSkidkaWidth ,
  ControlItogoSkidka, ControlSkid,ControlClientWith, ControlItogo,
  ControlPosKol,ControlPosPack,ControlPosReturnKol,ControlENalog : PView;

    ReturnWindow : PReturnWindow;
    SelectReturnDocWindow : PSelectReturnDocWindow;
    PosWindow : PPositionReturnWindow;
    PrevSMarket,PrevS : string[150];
    PrevVozwrat : PNewVozwratType;
    SupMarket : PSuperMarketType;
    VidDocument, {0 - наличная продажа скидка автоматическая
                  1 - наличная продажа скидка ручная
                  2 - закрытая консигнация авоматическая
                  3 - закрытая консигнация ручная
                  4 - открытая консигнация автоматическая
                  5 - открытая консигнация ручная}
    VidOperation {клиент или склад}: Word;
    VidDocSelector : Word;
           EditMode : Boolean;
           EditCod  : ArtikulStr;
EditOperatorSelector: Word;
    SArtikul : ArtikulStr;
    ItogoNalog: NalogType;



Function TestRealizOpen(E:PSuperMarketType):Word;
Var Er:PRealizasiaType;
    Fr: File Of RealizasiaType;
    i : Byte;
    Find : Boolean;
Begin
TestRealizOpen:=0;
Assign(fr,Path.ToDolg+E^.Dat.ClientKod+'.dlg');
i:=IOResult;
Reset(fr);
i:=IOResult;
If i<>0 Then
 Begin
  TestRealizOpen:=9;
  {MessageBox(^M+#3'Не найден файл задолженности клиента '+E^.Dat.ClientKod,Nil,mfError+mfCancelButton);}
  Exit;
 End;
Find := False;
{ищем исходный документ реализации в файле задолженности}

New(Er,Init);
While Not(Eof(fr)) And Not(Find) Do
 Begin
  Read(fr,Er^.Dat);
  Clearchar(Er^.Dat.Market.Document);
  DelSpace(Er^.Dat.MArket.DateC);
  If (Er^.Dat.Market.Document=E^.Dat.Document) And (Er^.DAt.Market.DateC=E^.Dat.DateC)
  And (E^.Dat.ClientKod=Er^.Dat.Market.ClientKod) And
  (Er^.Dat.Market.Active) Then Find := True;
 End;
System.Close(fr);

If Not(Find) Then
   Begin
    Dispose(Er,DOne);
    {MessageBox(#3+'Документ консигнации N '+E^.Dat.Document+' за '+E^.Dat.DateC+''^M
    +#3'в долгах клиента не найден!',Nil,mfError+mfCancelButton);}
    TestRealizOpen:=10;
    Exit;
   End;

 If (Er^.Dat.Full) Then TestRealizOpen:=7;
Dispose(Er,DOne);
End;


Function TestTodayReturn(SDate,Sdoc,SClient:AllStr; Vid:Word;Var Ttt:ArtikulStr):Word;
Var E : PNewVozwratType;
    f : NewVozwratFileType;
    k : Word;
    Find : Boolean;
Begin
  ttt[0]:=#0;
  k:=0;
  TestTodayReturn:=k;
  Assign(f,Path.ToReturn+FDate+'.vzw');
  k:=IOResult;
  Reset(f);
  k:=IOResult;
  If k<>0 Then  Exit;

   New(E,Init);
   Find:=False;
   While Not(Eof(f)) And Not(Find) Do
    Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     }
     ReadNewVozwrat(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     }
     DelSpace(SDoc);
     DelSpace(SDate);
     DelSpace(SClient);
     DelZerro(SDoc);
     DelSpace(E^.Dat.BasisDoc);
     DelZerro(E^.Dat.BasisDoc);
     DelSpace(E^.Dat.BasisDate);
     DelSpace(E^.Dat.MAkeKod);

     If (StrToInt(SDoc)=StrToInt(E^.Dat.BasisDoc)) And
        (StrToInt(SClient)=StrToInt(E^.Dat.MakeKod)) And
        (Vid=E^.Dat.OperatorSelector)And
        (SDAte=E^.Dat.BasisDate) And
           (E^.Dat.StatusDoc=1) Then
         Begin
          DelSpace(E^.Dat.Document);
          DelZerro(E^.Dat.Document);
          ttt:=E^.Dat.Document;
          Find:=True;
          k:=12;
         End;
    End;

   Close(f);
   Dispose(E,Done);

   If Find Then
    Begin
     k:=12;
     TestTodayReturn:=k;
    End;





End;



Function Existention(SDate,Sdoc,SClient:AllStr; Vid:Word;
                      Var Res:Word;Var Summa,Skidka:AllStr):Word;
Var E : PSuperMarketType;
    F : MarketFileType;
    i : Byte;
    Find : Boolean;
Begin
 Existention:=8;
 Res:=8;
 Assign(F,Path.ToMarket+SDate+'.mrk');
 i:=IOResult;
 Reset(f);
 i:=Ioresult;
 If i <> 0 Then
  Begin
   Existention:=1;
{  MessageBox(#3^M+#3'Не найден файл '+Print.PathToMarket+SDate+'.mrk',Nil,mfError+mfCancelButton);}
   Exit;
  End;
 Find :=False;
 New(E,Init);
 ClearChar(SDoc);
 While Not(Eof(f))And Not(Find) Do
 Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMarket(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
  DelSpace(E^.Dat.Document);
  If  (ClearChar(E^.Dat.Document)=Sdoc) And (E^.Dat.Active)And
  (E^.Dat.DateC=SDate) And (E^.Dat.ClientKod=SClient) And
  (E^.Dat.OperatorSelector=Vid) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Dispose(E,Done);
   System.Close(f);
   Existention:=2;
{  MessageBox(#3^M+#3'Документ N '+ SDoc+' в базе за '+SDate+' не найден!',Nil,mfError+mfCancelButton);}
   Exit;
 End;
 System.Close(f);
 Existention:=0;
 MyStr(StrToReal(E^.Dat.SummaZ),CIZena,CMantissa,Summa);
 MyStr(StrToReal(E^.Dat.Skidka),CIZena,CMantissa,Skidka);
  Case (E^.Dat.Realiz) Of
   False: Begin
           Case E^.Dat.SkidkaSelector Of
            0,2:Res:=0;
            1:Res:=1;
           Else Res:=8;
           End;
          End;
   True:  Begin
           If (E^.Dat.DocSelector in [5..8]) Then
           Begin
            i:= TestRealizOpen(E);
            Existention:=i;
            If i=0 Then
              Case E^.Dat.SkidkaSelector Of
              0,2:Res:=4;
              1:Res:=5;
              Else Res:=8;
              End;
           End
           Else
            Case E^.Dat.SkidkaSelector Of
             0,2:Res:=2;
             1:Res:=3;
             Else Res:=8;
             End;

          End;
  Else;
  End;

 Dispose(E,Done);
End;




Procedure TSelectReturnDocWindow.Parameter(Var Res:Word;Var SVidOperation:Word;
                              Var SDocument,SDate,SClientKod:AllStr;Var Summa,Skidka:AllStr);
Label 1;
var
  R : TRect;
  Control : PView;
  Num : ArtikulStr;
  ClientFile : ClientFileType;
  PrevClient : String[Call];
  i : Byte;
  c: Word;
  Lk : LongInt;
  Event : TEvent;
begin
1:
Res:=8;
DInfo('Минуточку...');
R.Assign(11, 8, 68, 15);
New(SelectReturnDocWindow, Init(R, 'Возврат товара'));
SelectReturnDocWindow^.Options := SelectReturnDocWindow^.Options or ofCenterX or ofCenterY;
SelectReturnDocWindow^.HelpCtx:=$E002;

R.Assign(2, 2, 25, 3);
ControlVid := New(PRadioButtons, Init(R,
  NewSItem('~К~лиент',
  NewSItem('~С~клад', Nil))));
SelectReturnDocWindow^.Insert(ControlVid);
ControlVid^.SetData(SVidOperation);

VidOperation:=SVidOperation;

  R.Assign(1, 1, 15, 2);
  SelectReturnDocWindow^.Insert(New(PLabel, Init(R, 'Вид операций:', ControlVid)));

R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(1,1)));
If SVidOperation=0 Then Assign (ClientFile,Path.ToClient+'Client.db')
Else Assign (ClientFile,Path.ToClient+'Sklad.db');
I:=IOResult;
Reset (ClientFile);
I:=IOResult;
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
     Client^.List^.Insert(NewStr(ClientElement^.Dat.Name+'│'+ClientElement^.Dat.Kod));
     Client^.SetRange(Client^.List^.Count);
    End;
  End;
 System.Close(ClientFile);
End;

Client^.FocusItem(Location(Client,SClientKod,False));
PrevClient:=Client^.GEtText(Client^.Focused,Client^.List^.COunt);
Dispose(Client,Done);

R.Assign(28, 2, 55, 3);
if prevClient[0]=#0 then prevClient:='│';
ControlClientSelectDoc := New(PColoredText, Init(R, #3+prevClient, $1F));
ControlClientSelectDoc^.Options := ControlClientSelectDoc^.Options or ofSelectable;
SelectReturnDocWindow^.Insert(ControlClientSelectDoc);

R.Assign(28, 1, 35, 2);
SelectReturnDocWindow^.Insert(New(PLabel, Init(R, 'Кл~и~ент:', ControlClientSelectDoc)));


R.Assign(23, 4, 29, 5);
ControlDocument := New(PInputLine, Init(R, CDocNumer));
SelectReturnDocWindow^.Insert(ControlDocument);

  PInputLine(ControlDocument)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));


DelSpace(SDocument);
ControlDocument^.SetData(SDocument);


  R.Assign(7, 4, 23, 5);
  SelectReturnDocWindow^.Insert(New(PLabel, Init(R, 'по ~д~окументу N:', ControlDocument)));

R.Assign(37, 4, 47, 5);
ControlDate := New(PInputLine, Init(R, CDate));

DelSpace(SDate);
ControlDate^.SetData(SDate);

SelectReturnDocWindow^.Insert(ControlDate);
  PInputLine(ControlDate)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));


  R.Assign(33, 4, 37, 5);
  SelectReturnDocWindow^.Insert(New(PLabel, Init(R, 'о~т~:', ControlDate)));

SelectReturnDocWindow^.SelectNext(False);
NoInfo;

c:=Desktop^.ExecView(SelectReturnDocWindow);
If c<>CmCancel Then
 Begin
  ClearFind;
  ControlVid^.GetData(VidOperation);
  SVidOperation:=VidOperation;
  ControlDocument^.GetData(SDocument);
  ControlDate^.GetData(SDate);
  PStaticText(ControlClientSelectDoc)^.GetText(PrevClient);
  System.Delete(PrevClient,Pos(#3,PrevClient),1);
  SClientKod:=Copy(PrevClient,1+CClient+1,CClientKod);
  {проверка правильности даты}
  DelSpace(SDate);
  If (SDate=FDate) Then
      Begin
       Dispose(SelectReturnDocWindow,Done);
       MessageBox(#3'Возврат товара за текущий день проводиться путем корректировки документа отгрузки!',
       Nil,mfError+mfCancelButton);
       Goto 1;
      End;

  If Not(TestDate(SDate,Lk)) Then
      Begin
       Dispose(SelectReturnDocWindow,Done);
       MessageBox(^M+#3'Не существующая дата!',Nil,mfError+mfCancelButton);
       Goto 1;
      End;

  {проверка номера документа}
  DelSpace(SDocument);
  DelZerro(SDocument);
  If SDocument[0]=#0 Then
      Begin
       Dispose(SelectReturnDocWindow,Done);
       MessageBox(#3^M+#3'Не введен номер документа!',Nil,mfError+mfCancelButton);
       Goto 1;
      End;

  c:=Existention(SDate,Sdocument,SClientKod,VidOperation,Res,Summa,Skidka);
  If c<>0 Then
      Begin
       Dispose(SelectReturnDocWindow,Done);
       Case c Of
       1: MessageBox(#3^M+#3'Не найден файл '+SDate+'.mrk',Nil,mfError+mfCancelButton);
       2: MessageBox(#3^M+#3'Документ N '+ SDocument+' в базе за '+SDate+' с клиентом ('+SClientKod+') не найден!',
       Nil,mfError+mfCancelButton);
       7:MessageBox(^M+#3'Вы пытаетесь использовать первичный документ закрытой консигнации!',Nil,
       mfError+mfCancelButton);
       9:MessageBox(^M+#3'Не найден файл долгов клиента '+SClientKod,Nil,mfError+mfCancelButton);
      10:MessageBox(#3+'Документ консигнации N '+SDocument+' за '+SDate+''^M
    +#3'в долгах клиента не найден!',Nil,mfError+mfCancelButton);

       Else;
       End;
       Goto 1;
      End;
  c:=TestTodayReturn(SDate,Sdocument,SClientKod,VidOperation,Num);

  If c<>0 Then
      Begin
       Dispose(SelectReturnDocWindow,Done);
       Beep;
       MessageBox(#3+'Обнаружен сформированный, но не введенный на склад возврат по документу N '+
       SDocument+' от '+SDate+' !'+
       +' Корректируйте документ возврата N '+Num+' !',Nil,mfWarning+mfCancelButton);
       Goto 1;
      End;

 If Status=DocNormal Then
 Begin
  If EditMode Then
  Begin
   If Not((editoperatorselector=VidOperation) and
        (StrToInt(EditCod)=StrToInt(SClientKod))) Then
    Begin
       If Not(SetClientLock(SClientKod,0,VidOperation)) Then
        Begin
         Beep;
         DInfoMsg('Не могу заблокировать клиента с кодом '+sClientKod+'. Попробуйте повторить!');
         Application^.GetEvent(Event);
         Application^.ClearEvent(Event);
         Application^.GetEvent(Event);
         Application^.ClearEvent(Event);
         repeat
          Application^.GetEvent(Event);
         until (Event.What <> evNothing) And (Event.Command<>cmMenu);
         Application^.ClearEvent(Event);
         NoInfoMsg;
         Dispose(SelectReturnDocWindow,Done);
         Goto 1;
        End;

    Repeat
    Until (SetClientUnLock(EditCod,0,EditOperatorSelector));
    End;{если выбран не заблокированный клиент}
  End{EditMode}
   Else
    Begin
       If Not(SetClientLock(SClientKod,0,VidOperation)) Then
        Begin
         Beep;
         DInfoMsg('Не могу заблокировать клиента с кодом '+sClientKod+'. Попробуйте повторить!');
         Application^.GetEvent(Event);
         Application^.ClearEvent(Event);
         Application^.GetEvent(Event);
         Application^.ClearEvent(Event);
         repeat
          Application^.GetEvent(Event);
         until (Event.What <> evNothing) And (Event.Command<>cmMenu);
         Application^.ClearEvent(Event);
         NoInfoMsg;
         Dispose(SelectReturnDocWindow,Done);
         Goto 1;
       End;
    End;{Not(editMode)}
 End{DocNormal}
 Else
  Begin{DocEdit}

   If Not((editoperatorselector=VidOperation) and
        (StrToInt(EditCod)=StrToInt(SClientKod))) Then
    Begin
       If Not(SetClientLock(SClientKod,0,VidOperation)) Then
        Begin
         Beep;
         DInfoMsg('Не могу заблокировать клиента с кодом '+sClientKod+'. Попробуйте повторить!');

         Application^.GetEvent(Event);
         Application^.ClearEvent(Event);
         Application^.GetEvent(Event);
         Application^.ClearEvent(Event);
         repeat
          Application^.GetEvent(Event);
         until (Event.What <> evNothing) And (Event.Command<>cmMenu);
         Application^.ClearEvent(Event);

         NoInfoMsg;
         Dispose(SelectReturnDocWindow,Done);
         Goto 1;
        End;
       {
        If ((StrToInt(PrevVozwrat^.Dat.Makekod)=StrToInt(EditCod))
        And(PrevVozwrat^.Dat.OperatorSelector=editoperatorselector)) Then}
        Repeat
        Until (SetClientUnLock(EditCod,0,EditOperatorSelector));
    End;

  End;
 End{cmOk}
 Else
 Begin
{!!!
  ControlVid^.GetData(Res);
  PStaticText(ControlClientSelectDoc)^.GetText(PrevClient);
  System.Delete(PrevClient,Pos(#3,PrevClient),1);
  PrevClient:=Copy(PrevClient,1+CClient+1,CClientKod);
  if status=docnormal then
   begin
    If EditMode Then
     Begin
     if Not((editoperatorselector=res) and
        (StrToInt(EditCod)=StrToInt(PrevClient))) then
        Repeat
        Until (SetClientUnLock(PrevClient,0,res));
     End;
   end
  Else
   begin
     if Not((editoperatorselector=res) and
        (StrToInt(EditCod)=StrToInt(PrevClient)))
           And
        Not((STrToInt(PrevVozwrat^.Dat.Makekod)=StrToInt(PrevcLIENT)) And
        (PrevVozwrat^.Dat.OperatorSelector=Res)) Then
        Repeat
        Until (SetClientUnLock(PrevClient,0,res));
   end;
}
  Res:=8;

 End;
 Dispose(SelectReturnDocWindow,Done);

end;


Procedure TSelectReturnDocWindow.Refresh;
Var i : Byte;
    R : TRect;
    PrevClient : String[CAll];
    Cod : ArtikulStr;
Begin
R.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R, 1, Nil));
Client^.NewList(New(PTextCollection, Init(1,1)));
AInfo('Обновляю список клиентов...');
If VidOperation=0 Then Assign (ClientFile,Path.ToClient+'Client.db')
Else Assign (ClientFile,Path.ToClient+'Sklad.db');
I:=IOResult;
Reset (ClientFile);
I:=IOResult;
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
    Client^.List^.Insert(NewStr(ClientElement^.Dat.Name+'│'+ClientElement^.Dat.Kod));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End;

{здесь вставить код осуществляющий блокировку ближайшего доступного клиента
 и деблокировку прежнего клиента}
{
If Not(SetLockNearClient(Client,0,VidOperation,Cod)) Then
  Begin
   Dispose(Client,Done);
   NoInfo;
   MessageBox(^M+#3'Не могу заблокировать ни одного клиента!',Nil,mfError+mfCancelButton);
   Exit;
  End;
End
Else
 Begin
  Dispose(Client,Done);
  NoInfo;
  Exit;
 End;
!!!}
{PStaticText(ControlVid)^.GetData(Test);
 PStaticText(ControlClientSelectDoc)^.GetText(S);}

Client^.FocusItem(0{Location(Client,Cod,False)});
PrevClient:=Client^.GetText(Client^.Focused,Client^.List^.Count);
Dispose(Client,Done);

If PrevClient[0]=#0 then PrevClient:='│';

PStaticText(ControlClientSelectDoc)^.Text^:=#3+PrevClient;
ControlClientSelectDoc^.draw;
NoInfo;
End;


Procedure TSelectReturnDocWindow.HandleEvent(var Event: TEvent);
Var s: string[150];
    L : Boolean;
    Test : Word;
Begin
  Case Event.KeyCode Of
     kbF1: AboutChm('2');
  End;
  Case Event.What Of

  evCommand :
     Case Event.Command Of
  cmSelectClient:
 Begin
  If (PView(Cl)<>Desktop^.TopView)And(ControlClientSelectDoc^.State and sfFocused <> 0) Then
  Begin
     PStaticText(ControlVid)^.GetData(Test);
     PStaticText(ControlClientSelectDoc)^.GetText(S);
     System.Delete(S,1,1);
     If Not(EditMode) Then
     Cl^.ShowClientList(s,VidOperation,0,True,False,True,-1,-1,-1,-1,Test)
     Else
     Cl^.ShowClientList(s,VidOperation,0,True,False,True,StrToInt(EditCod),EditOperatorSelector,-1,-1,Test);

     PStaticText(ControlClientSelectDoc)^.Text^:=#3+S;
     Redraw;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
     End;
     ClearEvent(Event);
  End
 End;
      Else;
      End;{evCommand}
      Else;
      End;{*Case*}


 If (PView(Cl)<>Desktop^.TopView)And
    (ControlClientSelectDoc^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectClient) And (Event.What <> EvKeyDown)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectClient;
             PutEvent(Event);
             ClearEvent(Event);
            End;


  inherited HandleEvent(Event);

  If (Desktop^.Current=PView(SelectReturnDocWindow)) And (Event.What <> EvKeyDown) Then
   Begin
          if (ControlVid^.State and sfFocused <> 0)Then
              Begin
               ControlVid^.GetData(Test);
               If Test <> VidOperation Then
               Begin
                PStaticText(ControlClientSelectDoc)^.GetText(S);
                System.Delete(S,1,1);
                VidOperation:=Test;
                Refresh;
               End;
              End;
    End;
End;




Destructor TSelectReturnDocWindow.Done;
Begin
 Dispose(ControlVid,Done);
 Dispose(ControlClientSelectDoc,Done);
 Dispose(ControlDocument,Done);
 Dispose(ControlDate,Done);
 TDialog.Done;
End;


Procedure DrawPack;
Var s: String[CPack];
    R : TRect;
    i : Byte;
    St : String[CKol];
Begin
    PosWindow^.GetData(St);
    Str(StrToInt(St),St);
    DelSpace(St);

    Dispose(ControlPosKol,Done);
    R.Assign(8, 3, 13, 4);
    ControlPosKol := New(PStaticText, Init(R, #3+St));
    PosWindow^.Insert(ControlPosKol);

    s:=CalcPack(sArtikul,St);
    DelSpace(s);
    Dispose(ControlPosPack,Done);
    R.Assign(23, 3, 32, 4);
    ControlPosPack := New(PColoredText, Init(R, #3+s, $3E));
    PosWindow^.Insert(ControlPosPack);
End;


Procedure GetKol(S:ArtikulStr;Division:ArtikulStr;Var Skol:ArtikulStr;Const P:PBox);
Var ls : Word;
    k  : Byte;
    st : String[CALL];
Begin
sKol[0]:=#0;
If P^.List^.Count>=1 Then
Begin
For ls :=0 To P^.List^.Count-1 Do
Begin
St:=Copy(P^.GetText(ls,P^.List^.Count),1+CName+1,Cartikul+1+COne);
If St=S+'│'+Division Then
   Begin
    SKol:=Copy(P^.GetText(ls,P^.List^.Count),1+CName+1+Cartikul+1+COne+1,CKol);
    Break;
   End;
End;
End;
End;


Procedure  TPositionReturnWindow.Ini(s:String;Regim:Word);
Label Start;
var
  R : TRect;
  Control : PView;
  Pack : String[CPack];
  SZakupka,TempKol,ws,wsKol,SKol,SNAme,SLitr,SInPack,SOne,SVidNalog,SNDS,
  SNalog,SRZena,SOZena,SZena,SSkidka,SProz: String[CName];
  L : LongInt;
  c: Word;
begin
ClearFind;
SName:=Copy(S,1,CName);
SArtikul:=Copy(S,1+CName+1,CArtikul);
SLitr:=GetIdField(FLitr,SArtikul);
SInPack:=GetIdField(FInPack,SArtikul);
SOne:=Copy(S,1+CName+1+CArtikul+1,COne);

GetKol(SArtikul,SOne,wsKol,NaklList);

SKol:=Copy(S,1+CName+1+CArtikul+1+COne+1,CKol);
SSkidka:=Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1,CZena);
MyStr(StrToReal(SSkidka),CZena,CMantissa,SSkidka);
SZena:=Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1,CZena);
MyStr(StrToReal(SZena),CZena,CMantissa,SZena);
SProz:=Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1,CLitr+1);
MyStr(StrToReal(SProz),CLitr+1,CMantissa+2,SProz);

SRZena:=Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1,CZena);
MyStr(StrToReal(SRZena),CZena,CMantissa,SRZena);

SOZena:=Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1+CZena+1,CZena);
MyStr(StrToReal(SOZena),CZena,CMantissa,SOZena);

SNalog:=Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1+CZena+1+CZena+1,CLitr);
MyStr(StrToReal(SNalog),CLitr,CMantissa,SNalog);

SVidNalog:=Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1+CZena+1+CZena+1+CLitr+1,COne);

SNDS:=Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1+CZena+1+CZena+1+CLitr+1+COne+1,CLitr);
MyStr(StrToReal(SNDS),CLitr,CMantissa,SNDS);

SZakupka:=

        Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1+CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1,CZena);
MyStr(StrToReal(SZakupka),CZena,CMantissa,SZakupka);


{
Наименование              │00258│N│Ко-во│Цена    │Скидка
12345678901234567890123456 12345 1 12345 12345678912345678}

Start:
R.Assign(0, 15, 80, 21);
New(PosWindow, Init(R, 'Возврат наименования товара - отделение ['+SOne+']'));
PosWindow^.Options := PosWindow^.Options or ofCenterX;
PosWindow^.Palette := dpCyanDialog;
PosWindow^.HelpCtx:=$E191;

R.Assign(71, 2, 78, 3);
ControlPosReturnKol := New(PInputLine, Init(R, 5));
PosWindow^.Insert(ControlPosReturnKol);
  PInputLine(ControlPosReturnKol)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(59, 2, 71, 3);
  PosWindow^.Insert(New(PLabel, Init(R, 'Возврат,шт:', ControlPosReturnKol)));
DelSpace(SKol);
{ControlPosReturnKol^.SetData(SKol);}

R.Assign(10, 2, 29, 3);
Control := New(PColoredText, Init(R, '┌─ Всего возврат ─┐', $31));
PosWindow^.Insert(Control);

R.Assign(1, 3, 8, 4);
Control := New(PColoredText, Init(R, 'Кол-во:', $31));
PosWindow^.Insert(Control);

R.Assign(8, 3, 13, 4);
ControlPosKol := New(PStaticText, Init(R, #3+'0'));
PosWindow^.Insert(ControlPosKol);

R.Assign(14, 3, 23, 4);
Control := New(PColoredText, Init(R, 'Упаковок:', $31));
PosWindow^.Insert(Control);

R.Assign(23, 3, 32, 4);
ControlPosPack := New(PStaticText, Init(R, #3+'0'));
PosWindow^.Insert(ControlPosPack);

R.Assign(4, 4, 59, 5);
Control := New(PColoredText, Init(R, 'Лобовая цены продажи => Р/Цена:'+SRZena+' О/Цена:'+SOZena, $31));
PosWindow^.Insert(Control);

R.Assign(60, 4, 75, 5);
Control := New(PColoredText, Init(R, 'Скидка:'+SSkidka, $31));
PosWindow^.Insert(Control);

R.Assign(2, 1, 75, 2);
Control := New(PStaticText, Init(R, 'Наименование:'+SNAme+'  Код:'+SArtikul+'  Литраж:'+SLitr+'  Фас:'+SInPack));
PosWindow^.Insert(Control);

Pack:=CalcPack(sArtikul,wsKol);
DelSpace(wsKol);
DelSpace(Pack);
R.Assign(33, 3, 76, 4);
Control := New(PColoredText, Init(R, 'В документе продажи: '+wsKol+' шт.  '+Pack+' уп.', $31));
PosWindow^.Insert(Control);


R.Assign(33, 2, 53, 3);
Control := New(PStaticText, Init(R, 'Имеется в отделении:'));
PosWindow^.Insert(Control);

R.Assign(68, 0, 78, 1);
Control := New(PColoredText, Init(R, 'НП: '+SNalog+'%', $31));
PosWindow^.Insert(Control);


R.Assign(53, 2, 58, 3);
ws:=BakGetField(FDiv,SArtikul,StrToInt(SOne));
Control := New(PStaticText, Init(R, ws));
PosWindow^.Insert(Control);

PosWindow^.SelectNext(False);
PosWindow^.SetData(SKol);
DrawPack;
C := Desktop^.ExecView(PosWindow);
If c <> cmCancel Then
  Begin
  PosWindow^.GetData(ws);
  DelSpace(Ws);
  Dispose(Control,Done);
  Dispose(PosWindow,Done);

  If (StrToInt(wsKol)<StrToInt(ws)) Then
   Begin
    MessageBox(#3^M+#3'Возврат превышает расход !',nil, mfError + mfCancelButton);
    Goto Start;
   End;
  If (ws[0]=#0) Or (StrTOInt(ws)=0) Then
   Begin
    MessageBox(#3+NullKol,nil, mfError + mfCancelButton);
    {Goto 1;}
   End;
  If (StrToInt(BakGetField(FKol,SArtikul,0))+(StrTOInt(ws))> CMaxKol) Then
   Begin
     MessageBox('Слишком большое количество товара'^M+
                'Попробуйте оприходывать его в другую позицию! ',nil, mfError + mfCancelButton);
     GoTo Start;
   End;

   L:=0;
   TempKol[0]:=#0;
   For c:=1 To CDivision Do
   Begin
    Str(c:1,SLitr);
    GetKol(SArtikul,SLitr,TempKol,ReturnList);
    L:=l+StrToInt(TempKol);
   End;

  If (StrToInt(BakGetField(FKol,SArtikul,0))+L+(StrTOInt(ws))> CMaxKol) Then
   Begin
     MessageBox('Слишком большое количество товара'^M+
                'Попробуйте оприходывать его в другую позицию! ',nil, mfError + mfCancelButton);
     GoTo Start;
   End;

   Format(Ws,CKol);
   s:=SName+'│'+SArtikul+'│'+SOne+'│'+ws+'│'+SZena+'│'+SSkidka+'│'+SProz+'│'+SRZena+'│'+SOZena+
   '│'+SNalog+'│'+SVidNalog+'│'+SNDS+'│'+SZakupka;

   If Regim=1 Then
    Begin
     ReturnList^.List^.AtFree(ReturnList^.Focused);
     ReturnList^.SetRange(ReturnList^.List^.Count);
    End;
   ReturnList^.List^.Insert(NewStr(S));
   ReturnList^.SetRange(ReturnList^.List^.Count);
   ReturnList^.FocusItem(LoCation(ReturnList,SArtikul,False));
  End
  Else
  Begin
   Dispose(Control,Done);
   Dispose(PosWindow,Done);
  End;
ClearFind;
end;


procedure TPositionReturnWindow.HandleEvent(var Event: TEvent);
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

Var DrawP : Boolean;
Begin
If (Event.What=evKeyboard)And(Event.KeyCode=kbF1)  then AboutCHM('19');
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
   Else;
   End;
   Else;
   End;


  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbBack)) Then DrawP:=True
  Else DrawP:=False;

  inherited HandleEvent(Event);
  If DrawP Then Begin
                 DrawPack;
                 Redraw;
                End;
  ClearEvent(Event);
End;




Destructor TPositionReturnWindow.Done;
Begin
Dispose(ControlPosReturnKol,Done);
Dispose(ControlPosKol,Done);
Dispose(ControlPosPack,Done);
TDialog.Done;
End;


(************************ Основное окно возврата ****************************)

Procedure TReturnWindow.FreshNaklHint;
Var s : TEnjoyStr;
    R : TRect;
    SKol : String[CKol];
    SZena,SSkid : String[CZena];
Begin

Dispose(ControlKol,Done);
Dispose(ControlZena,Done);
Dispose(ControlSkid,Done);
SKol[0]:=#0;
SZena[0]:=#0;
SSkid[0]:=#0;
If NaklList^.List^.Count>=1 Then
 Begin
  PrevS:=NaklList^.GetText(NaklList^.Focused,NaklList^.List^.Count);
  SKol:=Copy(PrevS,1+CName+1+CArtikul+1+COne+1,CKol);
  Szena:=Copy(PrevS,1+CName+1+CArtikul+1+COne+1+CKol+1,CZena);
  SSkid:=Copy(PrevS,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1,CZena);
  DelSpace(SKol);
  DelSpace(SZena);
  DelSpace(SSkid);
 End;

R.Assign(7, 21, 12, 22);
ControlKol := New(PColoredText, Init(R, #3+SKol, $7E));
Insert(ControlKol);

R.Assign(18, 21, 26, 22);
ControlZena := New(PColoredText, Init(R, #3+SZena, $7E));
Insert(ControlZena);

R.Assign(32, 21, 40, 22);
Controlskid := New(PColoredText, Init(R, #3+SSkid, $7E));
Insert(ControlSkid);
Redraw;

End;


Procedure TReturnWindow.FreshReturnHint;
Var s : TEnjoyStr;
    R : TRect;
    SZena,SSkid : String[CZena];
Begin

Dispose(ControlZenaWidth,Done);
Dispose(ControlSkidkaWidth,Done);
SZena[0]:=#0;
SSkid[0]:=#0;
If ReturnList^.List^.Count>=1 Then
 Begin
  PrevSMarket:=ReturnList^.GetText(ReturnList^.Focused,ReturnList^.List^.Count);
  Szena:=Copy(PrevSMarket,1+CName+1+CArtikul+1+COne+1+CKol+1,CZena);
  SSkid:=Copy(PrevSMarket,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1,CZena);
  DelSpace(SZena);
  DelSpace(SSkid);
 End;

R.Assign(57, 21, 65, 22);
ControlZenaWidth := New(PColoredText, Init(R, #3+SZena, $7E));
Insert(ControlZenaWidth);


R.Assign(71, 21, 79, 22);
ControlskidkaWidth := New(PColoredText, Init(R, #3+SSkid, $7E));
Insert(ControlSkidkaWidth);
Redraw;

End;


Procedure TReturnWindow.Refresh(SDoc,SDate,SClientKod:AllStr;Summa,Skidka:AllStr;VidOperation,VidDocument:Word);
Var R : TRect;
    St : TEnjoyStr;
    ww,Skol,ws : AllStr;
    F : MarketFIleType;
    E : PSuperMarketType;
    I : Byte;
    Find : Boolean;
Begin
ClearFind;

Dispose(ControlDocWith,Done);
R.Assign(16, 1, 20, 2);
ControlDocWith := New(PColoredText, Init(R, #3+SDoc, $7E));
Insert(ControlDocWith);


Dispose(ControlDateWith,Done);
R.Assign(24, 1, 32, 2);
ControlDateWith := New(PColoredText, Init(R, #3+SDate, $7E));
Insert(ControlDateWith);

Dispose(ControlSkidkaSelWidth,Done);
R.Assign(40, 1, 46, 2);
Case VidDocument Of
0,2,4:st:='Авто';
1,3,5:St:='Ручная';
Else;
End;
ControlSkidkaSelWidth := New(PColoredText, Init(R, #3+St, $7E));
Insert(ControlSkidkaSelWidth);

DelSpace(Skidka);
Dispose(ControlSkidkaWidthDoc,Done);
R.Assign(64, 1, 79, 2);
ControlSkidkaWidthDoc := New(PColoredText, Init(R, #3+Skidka, $7E));
Insert(ControlSkidkaWidthDoc);

DelSpace(Summa);
Dispose(ControlSummaWidthDoc,Done);
R.Assign(64, 2, 79, 3);
ControlSummaWidthDoc:= New(PColoredText, Init(R, #3+Summa, $4E));
Insert(ControlSummaWidthDoc);

St:=GetClientField(FClient,SCLientKod,VidOperation);
Format(st,CClient);
St:=St+'│'+SClientKod;

Dispose(ControlClientWith,Done);
R.Assign(52, 0, 79, 1);
ControlClientWith := New(PColoredText, Init(R, #3+St, $1F));
Insert(ControlClientWith);

 DInfo('Ищу документ...');
 Assign(F,Path.ToMarket+SDate+'.mrk');
 i:=IOResult;
 Reset(f);
 i:=Ioresult;
 If i <> 0 Then
  Begin
   NoInfo;
   MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+SDate+'.mrk',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Find :=False;
 New(E,Init);
 ClearChar(SDoc);

 While Not(Eof(f))And Not(Find) Do
 Begin
     {
     Repeat
     Until NetCall.Lock(f,FilePos(f)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMarket(f,E);
     {
     Repeat
      NetCall.UnLock(f,(FilePos(f)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
  DelSpace(E^.Dat.Document);
  If  (ClearChar(E^.Dat.Document)=Sdoc) And (E^.Dat.Active)And
  (E^.Dat.DateC=SDate) And (E^.Dat.ClientKod=SClientKod) And
  (E^.Dat.OperatorSelector=VidOperation) Then Find:=True;
 End;
 System.Close(f);

 If Not(Find) Then
 Begin
   Dispose(E,Done);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ SDoc+' в базе за '+SDate+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
 End;

NaklList^.NewList(nil);
NaklList^.NewList(New(PTextCollection, Init(1,1)));

VidDocSelector:=E^.Dat.DocSelector;

For I:=1 To E^.Dat.Amount Do
 Begin
  ws:=GetIdField(FName,E^.Dat.MarketElement[i].BazKod);

  Format(Ws,CName);
  st:=ws+'│'+E^.Dat.MarketElement[i].BazKod+'│';
  Str(E^.Dat.MarketElement[i].Input.DivisionSNumber:1,ws);

  Str(STrToInt(E^.Dat.MarketElement[i].Input.Kol):Ckol,E^.Dat.MarketElement[i].Input.Kol);
  MyStr(STrToReal(E^.Dat.MarketElement[i].Input.R_Zena),CZena,CMantissa,E^.Dat.MarketElement[i].Input.R_Zena);
  MyStr(STrToReal(E^.Dat.MarketElement[i].Input.Zakupka),CZena,CMantissa,E^.Dat.MarketElement[i].Input.Zakupka);
  MyStr(STrToReal(E^.Dat.MarketElement[i].Input.O_Zena),CZena,CMantissa,E^.Dat.MarketElement[i].Input.O_Zena);
  MyStr(STrToReal(E^.Dat.MarketElement[i].Input.Skidka),CZena,CMantissa,E^.Dat.MarketElement[i].Input.Skidka);

  Str(STrToInt(E^.Dat.MarketElement[i].Input.Kol)-
  StrToInt(GetReturnKol(E^.Dat.Document,E^.Dat.DateC,E^.Dat.ClientKod,E^.Dat.MarketElement[i].BazKod,ws,
  E^.Dat.OperatorSelector)):CKol,SKol);

  DelSpace(E^.Dat.MarketElement[i].Input.Kol);
  Format(E^.Dat.MarketElement[i].Input.Kol,CKol);

  DelSpace(E^.Dat.MarketElement[i].Input.Zena);
  Format(E^.Dat.MarketElement[i].Input.Zena,CZena);

  DelSpace(E^.Dat.MarketElement[i].Input.R_Zena);
  Format(E^.Dat.MarketElement[i].Input.R_Zena,CZena);

  DelSpace(E^.Dat.MarketElement[i].Input.O_Zena);
  Format(E^.Dat.MarketElement[i].Input.O_Zena,CZena);

  DelSpace(E^.Dat.MarketElement[i].Input.Zakupka);
  Format(E^.Dat.MarketElement[i].Input.Zakupka,CZena);


  DelSpace(E^.Dat.MarketElement[i].Input.Skidka);
  Format(E^.Dat.MarketElement[i].Input.Skidka,CZena);

  DelSpace(E^.Dat.MarketElement[i].Input.Proz);
  Format(E^.Dat.MarketElement[i].Input.Proz,CLitr+1);

  DelSpace(E^.Dat.MarketElement[i].Input.NDS);
  Format(E^.Dat.MarketElement[i].Input.NDS,CLitr);

  DelSpace(E^.Dat.MarketElement[i].Input.SpecNalog);
  Format(E^.Dat.MarketElement[i].Input.SpecNalog,CLitr);


  Str(E^.Dat.MarketElement[i].Input.VidNalog:COne,ww);

  st:=st+ws+'│'+{E^.Dat.MarketElement[i].Input.Kol}SKol+'│'+E^.Dat.MarketElement[i].Input.Zena+
  +'│'+E^.Dat.MarketElement[i].Input.Skidka+'│'+E^.Dat.MarketElement[i].Input.Proz+
  +'│'+E^.Dat.MarketElement[i].Input.R_Zena+'│'+E^.Dat.MarketElement[i].Input.O_Zena+
  +'│'+E^.Dat.MarketElement[i].Input.SpecNalog+'│'+ww+'│'+E^.Dat.MarketElement[i].Input.NDS+'│'+
       E^.Dat.MarketElement[i].Input.Zakupka;

  NaklList^.List^.Insert(NewStr(st));
  NaklList^.SetRange(NaklList^.List^.Count);
 End;
NaklList^.FocusItem(0);
Dispose(E,Done);

{Значения возвращаемые функцией
0 - наличная продажа скидка автоматическая
1 - наличная продажа скидка ручная
2 - закрытая консигнация авоматическая
3 - закрытая консигнация ручная
4 - открытая консигнация автоматическая
5 - открытая консигнация ручная}

Case VidDocument Of
0,1:St:='Продажа';
2,3:St:='Закрытая консигнация';
4,5:St:='Открытая консигнация';
Else;
End;

If VidDocSelector in [2,3,5,6] Then St:=St+'*';

Dispose(ControlTipWidth,Done);
R.Assign(16, 2, 39, 3);
ControlTipWidth := New(PColoredText, Init(R, #3+St, $7E));
Insert(ControlTipWidth);


NoInfo;
{Структура строки исходной накладной
Наименование              │00258│N│Ко-во│Цена    │Скидка
12345678901234567890123456 12345 1 12345 12345678912345678}
Redraw;
End;

Procedure SortReturnDoc(Var L:PNewVozwratType);
Var R : TRect;
    TempBox : PBox;
    i : Word;
    Wl,Wk,Wn : AllStr;
    S : string[150];
    E : PNewVozwratType;

Begin
 R.Assign(0, 0, 0, 0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(1,1)));
 For i :=1 To L^.Dat.Amount Do
  Begin
   With L^.Dat.VozwratElement[i].Input Do
   Begin
   Format(Kol,CKol);
   Format(Zena,CZena);
   Format(R_Zena,CZena);
   Format(O_Zena,CZena);
   Format(Zakupka,CZena);
   Format(LocalSkidka,CZena);
   Format(LocalProz,CLitr+1);
   Format(SpecNalog,CLitr);
   Format(NDS,CLitr);
   Format(DivisionS,COne);
   Wk := Copy(L^.Dat.VozwratElement[i].BazKod,1,CRazdelKod);
   Wn := GetIdField(FName,L^.Dat.VozwratElement[i].BazKod);
   Format (wn,CName);
   s:=DivisionS;
   s:=s+'│'+wk+'│'+Wn+'│'+L^.Dat.VozwratElement[i].BazKod+'│'+
   +L^.Dat.VozwratElement[i].Input.Kol+'│'+L^.Dat.VozwratElement[i].Input.Zena+'│'+
   +L^.Dat.VozwratElement[i].Input.LocalSkidka+'│'+L^.Dat.VozwratElement[i].Input.LocalProz+
   '│'+L^.Dat.VozwratElement[i].Input.R_Zena+'│'+
   +L^.Dat.VozwratElement[i].Input.O_Zena+'│'+L^.Dat.VozwratElement[i].Input.SpecNalog+
   +'│'+IntToStr(L^.Dat.VozwratElement[i].Input.VidNalog,COne)+
   +'│'+L^.Dat.VozwratElement[i].Input.NDS+'│'+L^.Dat.VozwratElement[i].Input.Zakupka;
   TempBox^.List^.Insert(NewStr(s));
   TempBox^.SetRange(TempBox^.List^.Count);
   End;{With}
  End;{For}
  New(E,Init);
  E^.Dat.Amount:=L^.Dat.Amount;

If (TempBox^.List^.Count)>0 Then
For i:=0 To TempBox^.List^.Count-1 Do
 Begin
  s:=TempBox^.GetText(i,TempBox^.List^.Count);
{для новой структуры стороки}
  E^.Dat.VozwratElement[i+1].BazKod:=Copy(s,1+COne+1+CRazdelKod+1+CName+1,CArtikul);
  With E^.Dat.VozwratElement[i+1].Input Do
   Begin
    Kol:=Copy(s,1+COne+1+CName+1+CArtikul+1+CRazdelKod+1,CKol);
    DelSpace(Kol);
    Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CKol+1+CRazdelKod+1,CZena);
    DelSpace(Zena);
    LocalSkidka:=Copy(s,1+COne+1+CName+1+CArtikul+1+CKol+1+CZena+1+CRazdelKod+1,CZena);
    DelSpace(LocalSkidka);
    LocalProz:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CZena+1+CZena+1+COne+1+CRazdelKod+1,CLitr+1);
    DelSpace(LocalProz);
    R_Zena:=   Copy(s,1+CName+1+CArtikul+1+CLitr+1+1+CKol+1+CZena+1+CZena+1+COne+1+CRazdelKod+1,CZena);
    DelSpace(R_Zena);
    O_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+1+CKol+1+CZena+1+CZena+1+COne+1+CZena+1+CRazdelKod+1,CZena);
    DelSpace(O_Zena);
    DiviSionS:=Copy(s,1,COne);
    SpecNalog:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+1+CKol+1+CZena+1+CZena+1+COne+1+CZena+1+CRazdelKod+1+CZena+1,CLitr);
    DelSpace(SpecNalog);
    VidNalog:=StrToInt(
    Copy(s,1+CName+1+CArtikul+1+CLitr+1+1+CKol+1+CZena+1+CZena+1+COne+1+CZena+1+CRazdelKod+1+CZena+1+CLitr+1,COne));
    NDS:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+1+CKol+1+CZena+1+CZena+1+COne+1+CZena+1+CRazdelKod+1+CZena+1+CLitr+1+COne+1,
    CLitr);
    DelSpace(NDS);
    Zakupka:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+1+CKol+1+CZena+1+CZena+1+COne+1+CZena+1+CRazdelKod+1+CZena+1+CLitr+1+COne+1+
    CLitr+1,CZena);
    DelSpace(Zakupka);
   End;
 End;
 L^.Dat:=E^.Dat;
 Dispose(TempBox,Done);
 Dispose(E,Done);
End;


Procedure TReturnWindow.SaveToFile(VAr Save:Boolean);
Label Stop;
Var
    L : PNewVozwratType;
    PereozenkaElement : PPereozenkaType;
    PereozenkaFile : File of PereozenkaType;
    I : Byte;
    J : Word;
    s : string[150];
    st : String[CAll];
    As : DocumentEdit;
    R : TRect;
    Logik : Boolean;
    Opts ,Rozs,Zakup :Real;
Begin
Save:=False;
New(L,Init);{:=TestPr;}
{чтение с экрана прихода}
If ReturnList^.List^.Count>0 Then
Begin
For i:=0 To ReturnList^.List^.Count-1 Do
 Begin
  s:=ReturnList^.GetText(i,ReturnList^.List^.Limit);
  With L^.Dat.VozwratElement[i+1].Input Do
   Begin
    Kol:=Copy(s,1+CName+1+CArtikul+1+COne+1,CKol);
    DelSpace(Kol);
    Zena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1,CZena);
    DelSpace(Zena);
    LocalSkidka:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1,CZena);
    DelSpace(LocalSkidka);
    LocalProz:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1,CLitr+1);
    DelSpace(LocalProz);
    R_Zena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1,CZena);
    DelSpace(R_Zena);
    O_Zena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1+CZena+1,CZena);
    DelSpace(O_Zena);
    DivisionS:=Copy(s,1+CName+1+CArtikul+1,COne);
    DelSpace(DivisionS);

    SpecNalog:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1+CZena+1+CZena+1,CLitr);
    DelSpace(SpecNalog);

    VidNalog:=StrToInt(

    Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1+CZena+1+CZena+1+CLitr+1,COne));
    NDS:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1+CZena+1+CZena+1+CLitr+1+COne+1,CLitr);
    DelSpace(NDS);
    Zakupka:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1+CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1,CZena);
    DelSpace(Zakupka);

   End;{With}
   L^.Dat.VozwratElement[i+1].BazKod:=Copy(s,1+CName+1,CArtikul);
 End;{For}
 L^.Dat.Amount:=ReturnList^.List^.Count;
 SortReturnDoc(l);
End;{If ReturnList^.List^.Count>0 Then}


{Вставить
 PrevSummaZ[0]:=#0;
 PrevSkidka[0]:=#0;}

Opts:=0;
Rozs:=0;
Zakup:=0;
With L^.Dat Do
 Begin
  OperatorSelector:=VidOperation;
  DocSelector:=VidDocSelector;
  CalcItogo(Opts,Rozs,Zakup,ItogoNalog);

  MyStr(Opts,CIZena,CMantissa,SummaO);
  DelSpace(SummaO);

  MyStr(Zakup,CIZena,CMantissa,SummaZakupka);
  DelSpace(SummaZakupka);


  MyStr(Rozs,CIZena,CMantissa,SummaR);
  DelSpace(SummaR);

  PStaticText(ControlItogoSkidka)^.GetText(s);
  DelSpace(S);
  System.Delete(S,Pos(#3,S),1);
  MySTr(StrToReal(s),CIZena,CMantissa,s);
  DelSpace(S);
  L^.Dat.Skidka:=s;


  L^.Dat.ENalog:=ItogoNalog.ENalog;
  DelSpace(L^.Dat.ENalog);
  L^.Dat.Nalog5:=ItogoNalog.Nalog5;
  DelSpace(L^.Dat.Nalog5);
  L^.Dat.Nalog3:=ItogoNalog.Nalog3;
  DelSpace(L^.Dat.Nalog3);
  L^.Dat.Nalog_:=ItogoNalog.Nalog_;
  DelSpace(L^.Dat.Nalog_);

  Caption:=CurrentPassword;
  DateM:=FDate;
  TimeM:=Times;
  If Status=DocNormal Then
  Begin
   DateC:=FDate;
   TimeC:=Times;
  End
  Else
   Begin
    DateC:=PrevVozwrat^.Dat.DateC;
    TimeC:=PrevVozwrat^.Dat.TimeC;
   End;
  StatusDoc:=1;
  PStaticText(ControlClientWith)^.GetText(S);
  System.Delete(S,Pos(#3,S),1);
  MakeKod:=Copy(S,1+CMake+1,CMakeKod);

  PStaticText(ControlRDoc)^.GetText(s);
  DelSpace(S);
  System.Delete(S,Pos(#3,S),1);
  Document:=s;

  PStaticText(ControlDocWith)^.GetText(s);
  DelSpace(S);
  System.Delete(S,Pos(#3,S),1);
  BasisDoc:=s;

  PStaticText(ControlDateWith)^.GetText(s);
  DelSpace(S);
  System.Delete(S,Pos(#3,S),1);
  BasisDate:=s;

  PStaticText(ControlSkidkaWidthDoc)^.GetText(s);
  DelSpace(S);
  System.Delete(S,Pos(#3,S),1);
  PrevSkidka:=s;

  PStaticText(ControlSummaWidthDoc)^.GetText(s);
  DelSpace(S);
  System.Delete(S,Pos(#3,S),1);
  PrevSummaZ:=s;

  Opt:=GetOpt(L);

  {устанавливаем будет расход из кассы или нет}
  L^.Dat.VidDocument:=Return.VidDocument;
  L^.Dat.DocSelector:=Return.VidDocSelector;

  (*
  Case L^.Dat.VidDocument Of
  0,1,2,3:Begin
           MyStr(StrToReal(L^.Dat.SummaR)-StrToReal(L^.Dat.Skidka)-
  	      StrToReal(L^.Dat.SummaZakupka),CIZena,CMAntissa,L^.Dat.Delta);
           L^.Dat.Rashod:=True;
           Str(StrToReal(L^.Dat.SummaR)-StrToReal(L^.Dat.Skidka)+StrToReal(L^.Dat.ENalog):CIZena:CMantissa,L^.Dat.RashodSumma);
          End;
  Else Begin
           MyStr(StrToReal(L^.Dat.SummaR)-StrToReal(L^.Dat.Skidka)-
  	      StrToReal(L^.Dat.SummaZakupka),CIZena,CMAntissa,L^.Dat.Delta);
           L^.Dat.Rashod:=False;
           L^.Dat.RashodSumma[0]:=#0;
       End;
  End;
  *)

  Case L^.Dat.VidDocument Of
  0,1,2,3:Begin
           MyStr(StrToReal(L^.Dat.SummaR)-StrToReal(L^.Dat.Skidka)-
  	      StrToReal(L^.Dat.SummaZakupka),CIZena,CMAntissa,L^.Dat.Delta);
           L^.Dat.Rashod:=True;
           MyStr(StrToReal(L^.Dat.SummaR)-StrToReal(L^.Dat.Skidka)+StrToReal(L^.Dat.ENalog)
                 ,CIZena,CMantissa,L^.Dat.RashodSumma);
                          If Abs(StrToReal(L^.Dat.RashodSumma))<0.009 Then
            Begin
             L^.Dat.Rashod:=False;
             L^.Dat.RashodSumma[0]:=#0;
            End;
          End;
  Else Begin
           MyStr(StrToReal(L^.Dat.SummaR)-StrToReal(L^.Dat.Skidka)-
  	      StrToReal(L^.Dat.SummaZakupka),CIZena,CMAntissa,L^.Dat.Delta);
           L^.Dat.Rashod:=False;
           L^.Dat.RashodSumma[0]:=#0;
       End;
  End;



 End;

 {Цикл проверки возможности автоматической переоценки}

New(PereozenkaElement,Init);
PereozenkaElement^.Dat.DateM:=FDate;
PereozenkaElement^.Dat.TimeM:=Times;
PereozenkaElement^.Dat.DateC:=FDate;
PereozenkaElement^.Dat.TimeC:=Times;
PereozenkaElement^.Dat.Vid:=1;
j:=1;
For i:=1 To L^.Dat.Amount Do
 Begin
If ((StrToReal(L^.Dat.VozwratElement[i].Input.R_Zena)<>StrToReal(BakGetField(FRZena,L^.Dat.VozwratElement[i].Bazkod,
0)))Or
(StrToReal(L^.Dat.VozwratElement[i].Input.O_Zena)<>StrToReal(BakGetField
(FOZena,L^.Dat.VozwratElement[i].Bazkod,0))))
  And (StrToInt(L^.Dat.VozwratElement[i].Input.Kol)>0) Then
   Begin
    PereozenkaElement^.Dat.Element[j].BazKod:=L^.Dat.VozwratElement[i].BazKod;
    PereozenkaElement^.Dat.Element[j].Kol:=L^.Dat.VozwratElement[i].Input.Kol;
    PereozenkaElement^.Dat.Element[j].Bak_R_Zena:=L^.Dat.VozwratElement[i].Input.R_Zena;
    PereozenkaElement^.Dat.Element[j].Bak_O_Zena:=L^.Dat.VozwratElement[i].Input.O_Zena;
    PereozenkaElement^.Dat.Element[j].New_R_Zena:=BakGetField(FRZena,L^.Dat.VozwratElement[i].BazKod,0);
    PereozenkaElement^.Dat.Element[j].New_O_Zena:=BakGetField(FOZena,L^.Dat.VozwratElement[i].BazKod,0);
{    PereozenkaElement^.Dat.Sklad:=Rek.SkladsName;}
    PereozenkaElement^.Dat.Caption := CurrentPassword;

    {Расчет суммы по новым РЦ}
    MyStr(StrToInt(L^.Dat.VozwratElement[i].Input.Kol)*StrToReal(BakGetField
    (FRZena,L^.Dat.VozwratElement[i].BazKod,0))+
     StrToReal(PereozenkaElement^.Dat.Itogo_New_R_Zena),CIZena,CMantissa
    ,PereozenkaElement^.Dat.Itogo_New_R_Zena);

    DelSpace(PereozenkaElement^.Dat.Itogo_New_R_Zena);

    {Расчет суммы по новым ОЦ}
    MyStr(StrToInt(L^.Dat.VozwratElement[i].Input.Kol)*StrToReal(BakGetField
    (FOZena,L^.Dat.VozwratElement[i].BazKod,0 ))+
     StrToReal(PereozenkaElement^.Dat.Itogo_New_O_Zena),CIZena,CMantissa
    ,PereozenkaElement^.Dat.Itogo_New_O_Zena);

    DelSpace(PereozenkaElement^.Dat.Itogo_New_O_Zena);

    {Расчет суммы по старым РЦ}
    MyStr(StrToInt(L^.Dat.VozwratElement[i].Input.Kol)*StrToReal(L^.Dat.VozwratElement[i].Input.R_Zena)+
     StrToReal(PereozenkaElement^.Dat.Itogo_Bak_R_Zena),CIZena,CMantissa
    ,PereozenkaElement^.Dat.Itogo_Bak_R_Zena);

    DelSpace(PereozenkaElement^.Dat.Itogo_Bak_R_Zena);

    {Расчет суммы по старым ОЦ}
    MyStr(StrToInt(L^.Dat.VozwratElement[i].Input.Kol)*StrToReal(L^.Dat.VozwratElement[i].Input.O_Zena)+
     StrToReal(PereozenkaElement^.Dat.Itogo_Bak_O_Zena),CIZena,CMantissa
    ,PereozenkaElement^.Dat.Itogo_Bak_O_Zena);

    DelSpace(PereozenkaElement^.Dat.Itogo_Bak_O_Zena);

    Inc(j);
    Inc(PereozenkaElement^.Dat.Amount);
   End;
 End;
    MyStr(StrToReal(PereozenkaElement^.Dat.Itogo_New_R_Zena)-StrToReal(PereozenkaElement^.Dat.Itogo_Bak_R_Zena),
    CIZena,CMantissa,PereozenkaElement^.Dat.Delta_RZ);
    DelSpace(PereozenkaElement^.Dat.Delta_RZ);
    MyStr(StrToReal(PereozenkaElement^.Dat.Itogo_New_O_Zena)-StrToReal(PereozenkaElement^.Dat.Itogo_Bak_O_Zena),
    CIZena,CMantissa,PereozenkaElement^.Dat.Delta_OZ);
    DelSpace(PereozenkaElement^.Dat.Delta_OZ);
{конец Цикла проверки возможности автоматической переоценки}

    Assign(PereozenkaFile,Path.ToCorrect+TekDate+'.prz');
    i:=IOResult;
    Reset(Pereozenkafile);
    i:=IOResult;
    If I <> 0 Then
    Begin
  If MessageBox(#3'Файл переоценки '+TekDate+'.prz не найден!'^M+
     'Создаю файл ? Если вы раньше что-либо переоценили позовите программиста!'+
        +' Код:'+IntToStr(i,3),nil, mfConfirmation + mfOkCancel)=cmOk  Then
     Begin
{     i:=IOresult;
      Reset(PereozenkaFile);
      i:=IOresult;
      If i<>0 Then  Rewrite(PereozenkaFile);}
      If Not(CreatToDayF(DocPereozen,TekDate)) Then
          Begin
        Save:=False;
        Dispose(L,Done);
        Dispose(PereozenkaElement,Done);
           Exit;
       End;
      Reset(PereozenkaFile);
      i:=IOResult;
     End
    Else
     Begin
      Save:=False;
      Dispose(L,Done);
      Dispose(PereozenkaElement,Done);
      Exit;
     End;
    End;{I<>0}
  PereozenkaElement^.Dat.Document:=InttoStr(FileSize(PereozenkaFile)+1,CDocNumer);
  System.Close(PereozenkaFile);
  L^.Dat.DocumentPrz:=PereozenkaElement^.Dat.Document;

If PereozenkaElement^.Dat.Amount>0 Then {если нужна переоценка, тогда запрос на экран}
  Begin

  If Not(UseDocNumer(DocPereozen,TekDate,PereozenkaElement^.Dat.Document)) Then
   Begin
    Save:=False;
    Dispose(L,Done);
    Dispose(PereozenkaElement,Done);
    Exit;
   End;
{
   Repeat
   Until (FreeDocNumer(Docpereozen,TekDate,PereozenkaElement^.Dat.Document));
}
    If Zapros(PereozenkaElement,PereozenkaElement^.Dat.Amount) Then
     Begin
       {вставит запись в файл возврата}
      Save:=LockAndWriteReturn(L,False);

       {деблокировка накладной возврата
          накладная деблокируется здесь только в случае удачной записи}
        If Save Then
        Repeat
        Until (UnLockReturn(L^.Dat.Document,L^.Dat.DateC) in [0,2]);

      If Not(Save) Then
       Begin
        Dispose(L,Done);
        Dispose(PereozenkaElement,Done);
        Exit;
       End;
      If Save Then
                 Begin
                 If Status=DocNormal Then
                 AddProtocolVozwrat('Формирование накладной возврата N '+L^.Dat.Document+' от '+L^.Dat.DateC)
                 Else
                 AddProtocolVozwrat('Корректировка накладной возврата N '+L^.Dat.Document+' от '+L^.Dat.DateC);
                 If MessageBox(#3^M+#3'Накладная возврата сформирована !'^M+
                 #3'Печатать накладную возврата ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
                  Begin
                   As.D:=L^.Dat.Datec;
                   As.EditPosition:=L^.Dat.Document;
                   NewPrintVozwrat(As);
                  End;
                 End;
     End
     Else Save:=False;
  Dispose(PereozenkaElement,Done);
  End{конец если переоценка}
  Else{если нет переоценки}
   Begin
     Dispose(PereozenkaElement,Done);
     {вставит запись в файл возврата}
     Save:=LockAndWriteReturn(L,False);
      if save then
      {деблокировка накладной возврата}
      Repeat
      Until (UnLockReturn(L^.Dat.Document,L^.Dat.DateC) in [0,2]);

      If Not(Save) Then
       Begin
        Dispose(l,Done);
        Exit;
       End;

         If Save Then
                 Begin
                 If Status=DocNormal Then
                 AddProtocolVozwrat('Формирование накладной возврата N '+L^.Dat.Document+' от '+L^.Dat.DateC)
                 Else
                 AddProtocolVozwrat('Корректировка накладной возврата N '+L^.Dat.Document+' от '+L^.Dat.DateC);
                 If MessageBox(#3^M+#3'Накладная возврата сформирована !'^M+
                 #3'Печатать накладную возврата ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
                  Begin
                   As.D:=L^.Dat.Datec;
                   As.EditPosition:=L^.Dat.Document;
                   NewPrintVozwrat(As);
                  End;
                 End;
   End;
Stop:Dispose(L,Done);
End;



Procedure  TReturnWindow.ChangeDoc;
Var S,SDoc,SDate,SClientKod,Summa,Skidka:AllStr;
    Res,c : Word;
    O,R,Z:Real;
    Start : Boolean;
Begin
 ClearFind;
 Start:=True;
 If ReturnList^.List^.Count>=1 Then
  Start:=MessageBox(#3'Эта процедура возможно приведет'^M+#3+'к полной очистке уже сформированной накладной возврата!'+
  ^M+#3+'Вы согласны очистить накладную?',Nil,
    mfWarning+mfOkCancel)=cmOk;
 If Start Then
  Begin
  Res:=8;
  c:=VidOperation;
  SDoc[0]:=#0;
  SDate[0]:=#0;

  PStaticText(ControlClientWith)^.GetText(S);
  System.Delete(S,1,1);
  SClientKod:=Copy(s,1+CClient+1,CClientKod);
  Summa[0]:=#0;
  Skidka[0]:=#0;
  EditMode:=True;
  EditCod:=SClientKod;
  EditOperatorSelector:=VidOperation;
  SRDocWindow^.Parameter(Res,c,SDoc,SDate,SClientKod,Summa,Skidka);
  EditMode:=False;
  EditCod[0]:=#0;
  EditOperatorSelector:=0;
  VidOperation:=c;
  VidDocument:=Res;
  If Res <> 8 Then
   Begin
    {Вставить код блокировки нового клиента!!!}
    Refresh(SDoc,SDate,SClientKod,Summa,Skidka,VidOperation,VidDocument);
    ClearReturnList;
    CalcItogo(o,r,z,ItogoNalog);
    AddName;
   End;

  End;
End;




Function  TReturnWindow.CalcItogo(Var O,R,Z:Real;Var ItogoNalog:NalogType) : Real;
Var R1 : TRect;
    S : TEnjoyStr;
    SKol: ArtikulStr;
    SZZena,Zena,RealZena,RealZakupka,Koefficient,SNalog,SZena,SRZena,SOZena,SSkidka,SProz : String[CZena];
    AllSkidka,AllReturn,AllNalog : String[CIZena];
    vidnalog,c : Word;
Begin
AllSkidka[0]:=#0;
AllReturn[0]:=#0;
AllNalog[0]:=#0;

ItogoNalog.ENalog[0]:=#0;
ItogoNalog.Nalog5[0]:=#0;
ItogoNalog.Nalog3[0]:=#0;
ItogoNalog.Nalog_[0]:=#0;
ItogoNalog.Zakupka[0]:=#0;


MySTr(StrToReal(ItogoNalog.ENalog),CIZena,CMantissa,ItogoNalog.ENalog);
MySTr(StrToReal(ItogoNalog.Nalog5),CIZena,CMantissa,ItogoNalog.Nalog5);
MySTr(StrToReal(ItogoNalog.Nalog3),CIZena,CMantissa,ItogoNalog.Nalog3);
MySTr(StrToReal(ItogoNalog.Nalog_),CIZena,CMantissa,ItogoNalog.Nalog_);

MySTr(StrToReal(AllSkidka),CIZena,CMantissa,AllSkidka);
MysTr(StrToReal(AllReturn),CIZena,CMantissa,AllReturn);
MysTr(StrToReal(AllNalog),CIZena,CMantissa,AllNalog);

CalcItogo:=0;
O:=0;
R:=0;
Z:=0;

If ReturnList^.List^.Count>=1 Then
 Begin
  For c:=0 To ReturnList^.List^.Count-1 Do
   Begin
    s:=ReturnList^.GetText(c,ReturnList^.List^.Count);
    {количество товара}
    SKol:=Copy(S,1+CName+1+CArtikul+1+COne+1,CKol);
    {скидка позиционная ручная}
    SSkidka:=Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1,CZena);
    {лобовая цена}
    SZena:=Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1,CZena);
    {скидка позиционная автоматическая}
    SProz:=Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1,CLitr+1);

    SRZena:=Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1,CZena);

    SOZena:=Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1+CZena+1,CZena);

    SNalog:=Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1+CZena+1+CZena+1,CLitr);

    VidNalog:=StrToInt(Copy(S,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1+CZena+1+CZena+1+CLitr+1,COne));

    SZZena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CZena+1+CZena+1+CLitr+1+1+CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1,CZena);
    DelSpace(SZZena);



    MyStr((1+StrToReal(SNalog)/100),CLitr,CMantissa,Koefficient);
    DelSpace(Koefficient);


    MyStr(StrToReal(AllReturn)+StrToInt(SKol)*StrToReal(SZena),CIZena,CMantissa,AllReturn);

    O:=O+StrToInt(SKol)*StrToReal(SOZena);
    R:=R+StrToInt(SKol)*StrToReal(SRZena);
    Z:=Z+StrToInt(SKol)*StrToReal(SZZena);


If VidDocSelector in [{1,}2,3,5,6] Then {отключен расчет налога с продажи при взв по тч}
   Begin

Case VidDocument Of
0,2,4:{}
       Begin
        {получили новую цену с учетом налога}
        MyStr(StrToReal(SZena)*(StrToReal(SProz)),CZena,CMantissa,RealZena);
        MyStr(StrToREal(RealZena)*StrToReal(Koefficient),CZena,CMantissa,Zena);
        MySTr(StrToReal(Zena)-StrToReal(RealZena),CZena,CMantissa,Zena);
        MyStr(StrToReal(Zena)*StrToInt(SKol),CIZena,CMantissa,RealZena);
        DelSpace(RealZena);
        MyStr(StrToReal(SZZena)*STrToInt(SKol),CIZena,CMantissa,RealZakupka);
        DelSpaCe(RealZakupka);
       End;
1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(SZena)-StrToReal(SSkidka),CZena,CMantissa,RealZena);
          MyStr(StrToREal(RealZena)*StrToReal(Koefficient),CZena,CMantissa,Zena);
          MySTr(StrToReal(Zena)-StrToReal(RealZena),CZena,CMantissa,Zena);
          MyStr(StrToReal(Zena)*StrToInt(SKol),CIZena,CMantissa,RealZena);
          DelSpace(RealZena);
          MyStr(StrToReal(SZZena)*STrToInt(SKol),CIZena,CMantissa,RealZakupka);
          DelSpaCe(RealZakupka);
        End;
Else;
End;{Case}

{суммарная ставка налога}
MyStr((StrToReal(RealZena)+StrToReal(ItogoNalog.ENalog)),CIZena,CMantissa,ItogoNalog.ENalog);
CAse VidNalog Of
0:MyStr((StrToReal(RealZena)+StrToReal(ItogoNalog.Nalog5)),CIZena,CMantissa,ItogoNalog.Nalog5);
1:MyStr((StrToReal(RealZena)+StrToReal(ItogoNalog.Nalog3)),CIZena,CMantissa,ItogoNalog.Nalog3);
2:MyStr((StrToReal(RealZena)+StrToReal(ItogoNalog.Nalog_)),CIZena,CMantissa,ItogoNalog.Nalog_);
Else;
End;
   End;{VidDocSelector}


Case VidDocument Of
0,2,4:{Авто}  Begin
               MyStr(StrToReal(SZena)-(StrToReal(SZena)*(StrToReal(SProz))),CZena,CMantissa,RealZena);
               MyStr(StrToReal(AllSkidka)+StrToReal(RealZena)*StrToInt(SKol),CIZena,CMantissa,AllSkidka);
              End;

1,3,5:{Ручная}MyStr(StrToReal(AllSkidka)+StrToReal(SSkidka)*StrToInt(SKol)
              ,CIZena,CMantissa,AllSkidka);
Else;
End;
   End;
   CalcItogo:=StrToReal(AllReturn);
 End;

Dispose(ControlItogoSkidka,Done);
DelSpace(AllSkidka);
R1.Assign(19, 22, 34, 23);
ControlItogoSkidka := New(PColoredText, Init(R1, #3+AllSkidka, $4E));
Insert(ControlItogoSkidka);

Dispose(ControlItogo,Done);
DelSpace(AllReturn);
R1.Assign(64, 22, 79, 23);
ControlItogo := New(PColoredText, Init(R1, #3+AllReturn, $4E));
Insert(ControlItogo);

Dispose(ControlENalog,Done);
DelSpace(AllNAlog);
R1.Assign(38, 22, 53, 23);
DelSpace(ItogoNalog.ENalog);
ControlENalog := New(PColoredText, Init(R1, #3+ItogoNalog.ENalog, $4E));
Insert(ControlENalog);
End;

procedure TReturnWindow.OpenReturnWindow;
Var l : Boolean;
begin
  l:=False;
  ClearFind;
  l:=Message(Desktop, evBroadcast, cmVozwrat, nil) = nil;
  if L then
  begin
    DInfo('Инициализация возврата...');
    L:=True;
    ReturnWindow := New(PReturnWindow, Init(L));
    If L Then
    Begin
     Application^.InsertWindow(ReturnWindow);
     NoInfo;
    End
    Else
     Begin
      TekDate:=FDate;
      Status:=DocNormal;
      Dispose(ReturnWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(ReturnWindow) <> Desktop^.TopView then ReturnWindow^.Select;
end;


Constructor  TReturnWindow.Init(Var l : Boolean);
var
  R1 : TRect;
  Control : PView;
  Res,C : Word;
  DocumentNumer : TDateString;
  VozwratFile : NewVozwratFileType;
  s: string[150];
  ws : TDateString;
  i : Byte;
  SDoc,SDate,SClientKod:TDateString;
  SName : String[CName];
  SLitr : String[CLitr+1];
  SPack : String[CInPack];
  Summa,Skidka :String[CIZena];
  Cod : ArtikulStr;
  O,r,Z : Real;
  Event : TEvent;

begin
 EditMode:=False;
 EditCod[0]:=#0;
 EditOperatorSelector:=0;
 R1.Assign(0, 0, 80, 23);
 PrevS:='Возврат';

 inherited Init(R1, PrevS);
 Options := Options or ofCenterX or ofCenterY;
 HelpCtx:=$E011;
 L:=False;

 ClearFind;

If Not(TestOpenDate1(TekDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+TekDate+' заблокирован!',Nil,mfError+mfCancelButton);
    TekDate:=FDate;
    Exit;
   End;
  C:=IOResult;
  Assign(VozwratFile,Path.ToReturn+TekDate+'.vzw');
  Reset(VozwratFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    If MessageBox(#3'Файл возврата за '+TekDate+' не найден'^M+
    #3'Если Вы раннее что-то возвратили'^M+
    #3'немедленно позовите программиста'^M+
    #3'Создавать файл возврата?'+
    +' Код:'+IntToStr(c,3),Nil, mfWarning+mfOkCancel)=cmOk Then
     Begin
{      c:=IOresult;
      Reset(VozwratFile);
      c:=IOresult;
      If c<>0 Then  Rewrite(VozwratFile);}
      If Not(CreatToDayF(DocReturn,TekDate)) Then Exit;
      Reset(VozwratFile);
      c:=IOResult;
     End
    Else Exit;
   End;
  System.Close(VozwratFile);
  If Status=DocNormal Then
  Begin
{
   DocumentNumer:=IntToStr(FileSize(VozwratFile)+1,CDocNumer);
   System.Close(VozwratFile);
}
   If Not(UseDocNumer(DocReturn,TekDate,DocumentNumer)) Then Exit;
  End
  Else
   Begin

    New(PrevVozwrat,Init);
(*
    While Not(Eof(VozwratFile)) And
     (ClearChar(Assistent.EditPosition)<>ClearChar(PrevVozwrat^.Dat.Document))Or
     (Assistent.D<>PrevVozwrat^.Dat.DateC)Do
     Begin
     Read(VozwratFile,PrevVozwrat^.Dat);
     End;
     System.Close(VozwratFile);

    If ClearChar(Assistent.EditPosition)<>ClearChar(PrevVozwrat^.Dat.Document) Then
    Begin
     MessageBox(#3^M+#3'Документ возврата N '+Assistent.EditPosition+''^M+
     #3'в базе за '+TekDate+' не найден!',Nil, mfError+mfCancelButton);
     Dispose(PrevVozwrat,Done);
     Exit;
    End;

    If (PrevVozwrat^.Dat.StatusDoc<>1) Then
    Begin
     MessageBox(#3'Говорил Вам - ПРОВЕРЯЙТЕ возврат!'^M+#3'Документ возврата N '+Assistent.EditPosition+''^M+
     #3'введен на склад и корректироваться не может!',Nil, mfError+mfCancelButton);
     Dispose(PrevVozwrat,Done);
     Exit;
    End;*)

    i:=LockReturn(Assistent,PrevVozwrat);
    If I=3 Then
     Begin
      Beep;
      DinfoMsg('Не могу заблокировать док-т возврата N '+PrevVozwrat^.Dat.Document+' от '+PrevVozwrat^.Dat.DateC+
         '. Попробуйте повторить!');
      Dispose(PrevVozwrat,Done);
      ClearEvent(Event);
      Application^.GetEvent(Event);
      ClearEvent(Event);
      repeat
        Application^.GetEvent(Event);
      until (Event.What <> evNothing)And(Event.Command<>cmMenu);
      NoInfoMsg;
      ClearEvent(Event);
      Exit;
     End;

    If I<>0 Then
     Begin
      Dispose(PrevVozwrat,Done);
      Exit;
     End;


    If Not(SetClientLock(PrevVozwrat^.Dat.MAkeKod,0,PrevVozwrat^.Dat.OperatorSelector)) Then
     Begin
     Repeat
     Until (UnLockReturn(PrevVozwrat^.Dat.Document,PrevVozwrat^.Dat.DateC) in [0,2]);

     DinfoMsg('Не могу заблокировать клиента '+PrevVozwrat^.Dat.MakeKod+'! Попробуйте повторить!');
     Dispose(PrevVozwrat,Done);
     ClearEvent(Event);
     Application^.GetEvent(Event);
     ClearEvent(Event);
     repeat
       Application^.GetEvent(Event);
     until (Event.What <> evNothing) And (Event.Command<>cmMenu);
     NoInfoMsg;
     ClearEvent(Event);
     Exit;
     End;

    DocumentNumer:=PrevVozwrat^.Dat.Document;

  End;{If Status<>DocNormal}

R1.Assign(36, 4, 37, 21);
Control := New(PScrollBar, Init(R1));
Insert(Control);

R1.Assign(1, 4, 36, 21);
NaklList := New(PBox, Init(R1, 1, PScrollbar(Control)));
NaklList^.NewList(New(PTextCollection, Init(1,1)));
NaklList^.HelpCtx:=$E157;
NaklList^.FocusItem(0);
Insert(NaklList);

  R1.Assign(1, 3, 36, 4);
  Insert(New(PLabel, Init(R1, 'В накла~д~ной продажи         Код  N', NaklList)));


R1.Assign(79, 4, 80, 21);
Control := New(PScrollBar, Init(R1));
Insert(Control);

R1.Assign(37, 4, 79, 21);
ReturnList:= New(PBox, Init(R1, 1,PScrollbar(Control)));
ReturnList^.NewList(New(PTextCollection, Init(1,1)));
If Status=DocEdit Then
 Begin
  For c:=1 To PrevVozwrat^.Dat.Amount Do
   Begin
    SName:=GetIdField(FName,PrevVozwrat^.Dat.VozwratElement[c].BazKod);
    Format(SName,CName);
    s:=SName+'│'+PrevVozwrat^.Dat.VozwratElement[c].BazKod;
    Format(PrevVozwrat^.Dat.VozwratElement[c].Input.DivisionS,COne);
    Format(PrevVozwrat^.Dat.VozwratElement[c].Input.Kol,CKol);
    Format(PrevVozwrat^.Dat.VozwratElement[c].Input.Zena,CZena);
    Format(PrevVozwrat^.Dat.VozwratElement[c].Input.R_Zena,CZena);
    Format(PrevVozwrat^.Dat.VozwratElement[c].Input.O_Zena,CZena);
    Format(PrevVozwrat^.Dat.VozwratElement[c].Input.Zakupka,CZena);
    Format(PrevVozwrat^.Dat.VozwratElement[c].Input.LocalSkidka,CZena);
    Format(PrevVozwrat^.Dat.VozwratElement[c].Input.LocalProz,CLitr+1);
    Format(PrevVozwrat^.Dat.VozwratElement[c].Input.SpecNalog,CLitr);
    Format(PrevVozwrat^.Dat.VozwratElement[c].Input.NDS,CLitr);




    s:=s+'│'+PrevVozwrat^.Dat.VozwratElement[c].Input.DivisionS+'│'+
             PrevVozwrat^.Dat.VozwratElement[c].Input.Kol+'│'+
             PrevVozwrat^.Dat.VozwratElement[c].Input.Zena+'│'+
             PrevVozwrat^.Dat.VozwratElement[c].Input.LocalSkidka+'│'+
             PrevVozwrat^.Dat.VozwratElement[c].Input.LocalProz+'│'+
             PrevVozwrat^.Dat.VozwratElement[c].Input.R_Zena+'│'+
             PrevVozwrat^.Dat.VozwratElement[c].Input.O_Zena+'│'+
             PrevVozwrat^.Dat.VozwratElement[c].Input.SpecNalog+'│'+
             IntToStr(PrevVozwrat^.Dat.VozwratElement[c].Input.VidNalog,COne)+'│'+
             PrevVozwrat^.Dat.VozwratElement[c].Input.NDS+'│'+
             PrevVozwrat^.Dat.VozwratElement[c].Input.Zakupka;
    ReturnList^.List^.Insert(NewStr(s));
    ReturnList^.SetRange(ReturnList^.List^.Count);
   End;
 End;
ReturnList^.HelpCtx:=$E159;
ReturnList^.FocusItem(0);
Insert(ReturnList);


  R1.Assign(37, 3, 79, 4);
  Insert(New(PLabel, Init(R1, 'Возвращаем~ы~й товар          Код  N Колич ', ReturnList)));


R1.Assign(2, 0, 7, 1);
Control := New(PColoredText, Init(R1, 'Дата:', $74));
Insert(Control);

R1.Assign(7, 0, 15, 1);
ControlRDate := New(PColoredText, Init(R1, #3+TekDate, $7E));
Insert(ControlRDate);

R1.Assign(17, 0, 26, 1);
Control := New(PColoredText, Init(R1, 'Документ:', $74));
Insert(Control);

R1.Assign(26, 0, 30, 1);
ControlRDoc := New(PColoredText, Init(R1, #3+DocumentNumer, $7E));
Insert(ControlRDoc);

R1.Assign(1, 1, 16, 2);
Control := New(PColoredText, Init(R1, 'По документу N:', $74));
Insert(Control);

R1.Assign(16, 1, 20, 2);
ControlDocWith := New(PColoredText, Init(R1, #3+'', $7E));
Insert(ControlDocWith);

R1.Assign(21, 1, 24, 2);
Control := New(PColoredText, Init(R1, 'от:', $74));
Insert(Control);

R1.Assign(24, 1, 32, 2);
ControlDateWith := New(PColoredText, Init(R1, #3+'', $7E));
Insert(ControlDateWith);

R1.Assign(33, 1, 40, 2);
Control := New(PColoredText, Init(R1, 'Скидка:', $74));
Insert(Control);

R1.Assign(40, 1, 46, 2);
ControlSkidkaSelWidth := New(PColoredText, Init(R1, #3+'', $7E));
Insert(ControlSkidkaSelWidth);


R1.Assign(47, 1, 64, 2);
Control := New(PColoredText, Init(R1, 'Скидка по док-ту:', $74));
Insert(Control);

R1.Assign(64, 1, 79, 2);
ControlSkidkaWidthDoc := New(PColoredText, Init(R1, #3+'', $7E));
Insert(ControlSkidkaWidthDoc);

R1.Assign(2, 2, 16, 3);
Control := New(PColoredText, Init(R1, 'Тип документа:', $74));
Insert(Control);


R1.Assign(16, 2, 39, 3);
ControlTipWidth := New(PColoredText, Init(R1, #3+'', $7E));
Insert(ControlTipWidth);


R1.Assign(48, 2, 64, 3);
Control := New(PColoredText, Init(R1, 'Сумма по док-ту:', $74));
Insert(Control);

R1.Assign(64, 2, 79, 3);
ControlSummaWidthDoc := New(PColoredText, Init(R1, #3+'', $4E));
Insert(ControlSummaWidthDoc);

R1.Assign(1, 21, 7, 22);
Control := New(PColoredText, Init(R1, 'Колич:', $71));
Insert(Control);

R1.Assign(7, 21, 12, 22);
ControlKol := New(PColoredText, Init(R1, #3+'', $7E));
Insert(ControlKol);

R1.Assign(13, 21, 18, 22);
Control := New(PColoredText, Init(R1, 'Цена:', $71));
Insert(Control);

R1.Assign(18, 21, 26, 22);
ControlZena := New(PColoredText, Init(R1, #3+'', $7E));
Insert(ControlZena);

R1.Assign(27, 21, 32, 22);
Control := New(PColoredText, Init(R1, 'Скид:', $71));
Insert(Control);

R1.Assign(32, 21, 40, 22);
ControlSkid := New(PColoredText, Init(R1, #3+'', $7E));
Insert(ControlSkid);

R1.Assign(41, 21, 49, 22);
Control := New(PColoredText, Init(R1, 'Выбрано:', $74));
Insert(Control);

R1.Assign(49, 21, 51, 22);
ControlPos := New(PColoredText, Init(R1, #3+'', $7E));
Insert(ControlPos);


R1.Assign(52, 21, 57, 22);
Control := New(PColoredText, Init(R1, 'Цена:', $71));
Insert(Control);

R1.Assign(57, 21, 65, 22);
ControlZenaWidth := New(PColoredText, Init(R1, #3+'', $7E));
Insert(ControlZenaWidth);

R1.Assign(66, 21, 71, 22);
Control := New(PColoredText, Init(R1, 'Скид:', $71));
Insert(Control);

R1.Assign(71, 21, 79, 22);
ControlSkidkaWidth := New(PColoredText, Init(R1, #3+'', $7E));
Insert(ControlSkidkaWidth);


R1.Assign(1, 22, 19, 23);
Control := New(PColoredText, Init(R1, ' E скидка возв-та:', $74));
Insert(Control);

R1.Assign(19, 22, 34, 23);
ControlItogoSkidka := New(PColoredText, Init(R1, #3+'', $4E));
Insert(ControlItogoSkidka);

R1.Assign(53, 22, 64, 23);
Control := New(PColoredText, Init(R1, ' E возврат:', $74));
Insert(Control);

R1.Assign(64, 22, 79, 23);
ControlItogo := New(PColoredText, Init(R1, #3+'', $4E));
Insert(ControlItogo);

R1.Assign(34, 22, 38, 23);
Control := New(PColoredText, Init(R1, ' НП:', $74));
Insert(Control);

R1.Assign(38, 22, 53, 23);
ControlENalog := New(PColoredText, Init(R1, #3+'', $4E));
Insert(ControlENalog);

R1.Assign(45, 0, 52, 1);
Control := New(PStaticText, Init(R1, 'Клиент:'));
Insert(Control);

R1.Assign(52, 0, 79, 1);
ControlClientWith := New(PColoredText, Init(R1, #3+'', $1F));
Insert(ControlClientWith);

If Status=DocNormal Then
 Begin
  Res:=8;
  c:=0;
  SDoc[0]:=#0;
  SDate[0]:=#0;
  SClientKod:='0000';

R1.Assign(0, 0, 0, 0);
Client := New(PBox, Init(R1, 1, Nil));
Client^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c=0 Then
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
    Client^.List^.Insert(NewStr(ClientElement^.Dat.Name+'│'+ClientElement^.Dat.Kod));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End;
{здесь вставить код осуществляющий блокировку ближайшего доступного клиента}
{
If Not(SetLockNearClient(Client,0,0,SClientKod)) Then
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
  MessageBox(^M+#3'Ошибка сетевого открытия файла клиентов!',Nil,mfError+mfCancelButton);
  Exit;
 End;
!!!}
  Dispose(Client,Done);

  Summa[0]:=#0;
  Skidka[0]:=#0;
  SRDocWindow^.Parameter(Res,c,SDoc,SDate,SClientKod,Summa,Skidka);
  VidOperation:=c;
  VidDocument:=Res;
  If Res=8 Then
   Begin
  {
    Repeat
    Until (SetClientUnLock(SClientKod,0,VidOperation));
  !!!}

    {освобождаем номер документа}
    DelSpace(DocumentNumer);
{
    Repeat
    Until (FreeDocNumer(DocReturn,TekDate,DocumentNumer));
}
    L:=False;
    TekDate:=FDate;
    Status:=DocNormal;
    Exit;
   End;
 End
 Else
  Begin
   VidDocument:=PrevVozwrat^.Dat.VidDocument;
   VidDocSelector:=PrevVozwrat^.Dat.DocSelector;
   VidOperation:=PrevVozwrat^.Dat.OperatorSelector;
   SDoc:=PrevVozwrat^.Dat.BasisDoc;
   SDate:=PrevVozwrat^.Dat.BasisDate;
   SClientKod:=PrevVozwrat^.Dat.MAkeKod;
   Summa:=PrevVozwrat^.Dat.PrevSummaZ;
   Skidka:=PrevVozwrat^.Dat.PrevSkidka;
  End;

SelectNext(False);
Refresh(SDoc,SDate,SClientKod,Summa,Skidka,VidOperation,VidDocument);
CalcItogo(O,r,z,ItogoNalog);
AddName;
L:=True;
PrevS[0]:=#0;
end;


procedure TReturnWindow.AddName;
Var R : TRect;
    KolStr : String[3];
Begin
  Str(ReturnList^.List^.Count:2,KolStr);
  Dispose(ControlPos,Done);
  R.Assign(49, 21, 51, 22);
  ControlPos := New(PColoredText, Init(R, #3+KolStr, $7E));
  Insert(ControlPos);
End;

procedure TReturnWindow.ClearReturnList;
Begin
{   DInfo('Минуточку...');}
   returnList^.NewList(nil);
   returnList^.NewList(New(PTextCollection, Init(1,1)));
{   NoInfo;}
End;


procedure TReturnWindow.HandleEvent(var Event: TEvent);
Var s,s1 : string[150];
    ws : AllStr;
    L : Boolean;
    c : Word;
    O,r,Z : Real;
    SDoc : ArtikulStr;
    SDate :TDateString;
    SClientKod : String[CClientKod];

Function TestEmploy:Boolean;
Var s : string[150];
    Event : TEvent;
    R : Boolean;
    Msg : StrNAme;
Begin
  TestEmploy:=False;
  s:=Copy(NaklList^.GetText(NaklList^.Focused,NaklList^.List^.Count),1+CName+1,CArtikul);
  R:=GetIdEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Позиция ['+s+'] отмечена как удаленная. Нельзя использовать эту позицию!');
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing) And (Event.Command <> cmMenu);
    NoInfoMsg;
    ClearEvent(Event);
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End;
  TestEmploy:=R;
End;



Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of

     kbDel: Begin
     If (ReturnList^.State and sfFocused <> 0) And (ReturnList^.List<>Nil)And(ReturnList^.List^.Count>=1) Then
            Begin
              If MessageBox(#3+DelTovar,nil,mfConfirmation+mfOkCancel)=cmOk Then
               Begin
                ReturnList^.List^.AtFree(ReturnList^.Focused);
                ReturnList^.SetRange(ReturnList^.List^.Count);
                If ReturnList^.Focused>0 Then ReturnList^.FocusItem(ReturnList^.Focused);

                If (ReturnList^.Focused>=ReturnList^.List^.Count) and(ReturnList^.Focused>0) Then
                ReturnList^.FocusItem(ReturnList^.Focused-1);

                FreshReturnHint;
                PrevSMarket[0]:=#0;
                CalCItogo(O,R,Z,ItogoNalog);
                AddName;
                Redraw;
               End;
              ClearEvent(Event);
            End;
            End;
  kbCtrLDel: Begin
     If (ReturnList^.State and sfFocused <> 0) And (ReturnList^.List<>Nil) And (ReturnList^.List^.Count>=1) Then
            Begin
             If MessageBox(#3+DelAll,nil,mfConfirmation+mfOkCancel)=cmOk Then
             Begin
                 ClearReturnList;
                 PrevSMarket[0]:=#0;
                 FreshReturnHint;
                 CalCItogo(O,r,Z,ItogoNalog);
                 AddName;
                 Redraw;
                End;
             End;

            End;
kbEnter,kbF4: Begin
            If ((Event.KeyCode=kbF4) Or (Event.KeyCode=kbEnter))And(ReturnList^.State and sfFocused <> 0)
               And (ReturnList^.List^.Count>=1)  Then
            Begin

              s:=ReturnList^.GetText(ReturnList^.Focused,ReturnList^.List^.Count);
              s1:=Copy(s,1+CName+1,CArtikul);
              Mark^.Ini(s,1);
              {вставит обработку события - корректировка накладной возврата}
              FreshReturnHint;
              PrevSMarket[0]:=#0;
              CalcItogo(O,r,Z,ItogoNalog);
              AddName;
              Redraw;
              ClearEvent(Event);
            End;

     If (Event.KeyCode=kbEnter) And (NaklList^.State and sfFocused <> 0) And(NaklList^.List^.Count>=1) Then
        Begin
           If (NaklList^.State and sfFocused <> 0) And(ReturnList^.List^.Count>CMax-1) Then
                Begin
                 MessageBox(#3^M+#3'В документе может быть'^M+
                 #3'не более '+ IntToStr(CMax,2)+' наименований !',Nil,mfError+mfCanCelButton);
                 ClearEVent(Event);
                 Exit;
                End;

             If Not(TestEmploy) Then
              Begin
                ClearEvent(Event);
                Exit;
              End;

             s:=Copy(NaklList^.GetText(NaklList^.Focused,NaklList^.List^.Count),1+CName+1,CArtikul);
             s1:=Copy(NaklList^.GetText(NaklList^.Focused,NaklList^.List^.Count),1+CName+1+CArtikul+1,COne);
           If TestElementDivision(S,s1,ReturnList) Then
                Begin
                {Вставить код добавки в накладную возврата}
                 s:=NaklList^.GetText(NaklList^.Focused,NaklList^.List^.Count);
                 Mark^.Ini(s,0);
                 PrevSMarket[0]:=#0;
                 CalcItogo(O,r,Z,ItogoNalog);
                 AddName;
                 Redraw;
                 If (NaklList^.Focused+1)<NaklList^.List^.Count Then
                  Begin
                   NaklList^.FocusItem(NaklList^.Focused+1);
                   PrevS[0]:=#0;
                  End;
                 ClearEvent(Event);
                End
                 Else
                  Begin
                   MessageBox(#3^M+#3'Товар с кодом '+s+' (отделение '+S1+') уже есть в накладной !',
                   Nil,mfError+mfCanCelButton);
                   ClearEvent(Event);
                   Exit;
                  End;
           ClearEvent(Event);
        End;
            End;
     kbF5 : Begin
                 PStaticText(ControlItogo)^.GetTExt(s);
                 If Pos(#3,s)>0 Then System.Delete(s,1,1);
                 PStaticText(ControlItogoSkidka)^.GetTExt(s1);
                 If Pos(#3,s1)>0 Then System.Delete(s1,1,1);
                 MyStr(StrToReal(s)-StrToReal(s1),CIZena,CMantissa,ws);
                 DelSpace(ws);
                 s:=' Всего возврат:'+s+'  Скидка возврата:'+S1+'  К выдаче клиенту:'+ws;
                 {Вставить номер и дату документа в просмотре}
             If Status=DocEdit Then
              Begin
               SDoc:=PrevVozwrat^.Dat.Document;
               SDate:=PrevVozwrat^.Dat.DateC;
              End
              Else
              Begin
               PStaticText(ControlRDoc)^.GetTExt(sdoc);
               If Pos(#3,sdoc)>0 Then System.Delete(sdoc,1,1);
               SDate:=FDate;
              End;

                 FullScreen(ReturnList,'Возвращаемые товары         Код  N Колич   Цена    Скидка  Проц   Р/Цена ',S,
                 SDoc,SDate,0);
            End;
     kbEsc: Begin
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);

            End;
      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of
 cmVozwrat: Begin
             ClearEvent(Event);
            End;
 cmChangeDoc :Begin
               ClearEvent(Event);
               ChangeDoc;
               PrevS[0]:=#0;
               PrevSMarket[0]:=#0;
              End;
 cmAbout: Begin
   ClearEvent(Event);
   AboutCHM('18');
          End;
     cmOk : Begin
               PStaticText(ControlClientWith)^.GetText(S);
               System.Delete(S,1,1);
               DelSpace(s);
               SClientKod:=Copy(s,1+CClient+1,CClientKod);

               If ((STRToInt(SClientKod)=StrToInt(ClientRP)) And (VidOperation=1)) Or
                  ((STRToInt(SClientKod)=StrToInt(Rek.Kod)) And (VidOperation=1)) Then
                Begin
                 Beep;
                 DinfoMsg('Ошибка! Нельзя делать возврат от внутреннего поставщика с кодом '+SClientKod+'!');
                 ClearEvent(Event);
                repeat
                  Application^.GetEvent(Event);
                {until (Event.What in [evKeyDown,evMouseDown]);}
                until (Event.What <> evNothing)And(Event.Command<>cmMenu);


                 NoInfoMsg;
                 ClearEvent(Event);
                 Exit;
                End;

            If (s<>'│')And(s[0]<>#0) Then
             Begin
      If ((ReturnList^.List<>Nil)And(ReturnList^.List^.Count>0))Or(Status=DocEdit) Then
     Begin
       PStaticText(ControlItogo)^.GetTExt(s);
       If Pos(#3,s)>0 Then System.Delete(s,1,1);
       PStaticText(ControlItogoSkidka)^.GetTExt(s1);
       If Pos(#3,s1)>0 Then System.Delete(s1,1,1);
       MyStr(StrToReal(s)-StrToReal(s1),CIZena,CMantissa,ws);
       DelSpace(ws);
       s:=' Всего возврат:'+s+'  Скидка возврата:'+S1+'  К выдаче клиенту:'+ws;
       {Вставить номер и дату документа в просмотре}
       If Status=DocEdit Then
          Begin
           SDoc:=PrevVozwrat^.Dat.Document;
           SDate:=PrevVozwrat^.Dat.DateC;
          End
          Else
           Begin
            PStaticText(ControlRDoc)^.GetTExt(sdoc);
            If Pos(#3,sdoc)>0 Then System.Delete(sdoc,1,1);
            SDate:=FDate;
           End;
          If FullScreen(ReturnList,'Возвращаемые товары         Код  N Колич   Цена    Скидка  Проц   Р/Цена ',S,
              SDoc,SDate,1)
  {                                    12345678901234567890123456 12345 1 12345 12345678 12345678 12345 12345678 12345678}
{12345678901234567890123456 12345 1 12345 12345678 12345678 12345}
                Then
                  Begin
                   L:=False;
                   SaveToFile(L);
                   If L Then
                     Begin
                       PStaticText(ControlClientWith)^.GetText(S);
                       System.Delete(S,1,1);
                       Repeat
                       Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,VidOperation));

                       Event.What:=evCommand;
                       Event.Command:=cmClose;
                       PutEvent(Event);
                       ClearEvent(Event);
                       If Status = DocEdit Then
                        Begin
                  {
                   If Not((StrToInt(Copy(s,1+CClient+1,CClientKod))
                                 =StrToInt(PrevVozwrat^.Dat.MakeKod))
                      And (VidOperation=PrevVozwrat^.Dat.OperatorSelector)) Then
                      Repeat
                      Until (SetClientUnLock(PrevVozwrat^.Dat.MakeKod,0,PrevVozwrat^.Dat.OperatorSelector));
                  }
                               Dispose(PrevVozwrat,Done);
                        End;
                       Status:=DocNormal;
                       ProdagaWindow:=False;
                       TekDate := FDate;
                       ClearEvent(Event);
                     End;
                  End{If FullScreen}
                 Else ClearEvent(Event);
               End{если можно закрывать документ}
               Else
                Begin
                 ClearEvent(Event);
                 Exit;
                End;
              End;
              ClearFind;

            End;
  cmCancel : Begin
                l:=True;
                If (ReturnList^.List^.Count>0) Or
                   (Status=DocEdit) Then
                l:=MessageBox(^M+#3'Желаете отказаться от регистрации/корректировки возврата ?',
                   Nil,mfConFirmation+mfOkCancel)=cmOk;

                If L Then
                Begin
                 PStaticText(ControlClientWith)^.GetText(S);
                 System.Delete(S,1,1);
                 Repeat
                 Until (SetClientUnLock(Copy(s,1+CClient+1,CClientKod),0,VidOperation));

                 If Status = DocEdit Then
                  Begin
                    Repeat
                    Until (UnLockReturn(PrevVozwrat^.Dat.Document,PrevVozwrat^.Dat.DateC) in [0,2]);
                  End
                  Else
                   Begin
                    PStaticText(ControlRDoc)^.GetText(sdoc);
                    If Pos(#3,sdoc)>0 Then System.Delete(sdoc,1,1);
                    DelSpace(SDoc);
{
                    Repeat
                    Until (FreeDocNumer(DocReturn,TekDate,SDoc));
}
                   End;

                 If Status = DocEdit Then
                 Begin
                   {
                   If Not((StrToInt(Copy(s,1+CClient+1,CClientKod))
                                 =StrToInt(PrevVozwrat^.Dat.MakeKod))
                      And (VidOperation=PrevVozwrat^.Dat.OperatorSelector)) Then
                      Repeat
                      Until (SetClientUnLock(PrevVozwrat^.Dat.MakeKod,0,PrevVozwrat^.Dat.OperatorSelector));
                   }
                               Dispose(PrevVozwrat,Done);
                 End;

                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);

                 ProdagaWindow:=False;
                 Status:=DocNormal;
                 TekDate := FDate;
                 ClearEvent(Event);
                End;
                End;

      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
 if (Event.What = evBroadcast) and
     (Event.Command = cmVozwrat) then ClearEvent(Event);

  inherited HandleEvent(Event);

 If (Desktop^.Current=PView(ReturnWindow)) And (Event.What <> EvKeyDown) Then
           Begin

              if (NaklList^.State and sfFocused <> 0)  And(NaklList^.List<>Nil)And(NaklList^.List^.Count>=1)Then
              Begin
               s:=NaklList^.GetText(NaklList^.Focused,NaklList^.List^.Count);
               If s <> PrevS Then
                 Begin
                  PrevS:=Copy(s,1+CName+1,CArtikul);
                  FreshNaklHint;
                  PrevS:=NaklList^.GetText(NaklList^.Focused,NaklList^.List^.Count);
                 End
              End;

              if (ReturnList^.State and sfFocused <> 0)  And(ReturnList^.List<>Nil)And(ReturnList^.List^.Count>=1)Then
              Begin
               s:=ReturnList^.GetText(ReturnList^.Focused,ReturnList^.List^.Count);
               If s <> PrevSMarket Then
                 Begin
                  PrevSMarket:=Copy(s,1+CName+1,CArtikul);
                  FreshReturnHint;
                  PrevSMarket:=ReturnList^.GetText(ReturnList^.Focused,ReturnList^.List^.Count);
                 End
              End;

          End;

end;

Function LockAndWriteReturnToSkladFile(L:PNewVozwratType) : Boolean;
Var SkladFile : File Of SkladType;
    Sklad : PSkladType;
    i,p,k : Byte;
    Ls:LongInt;
    s1,s2 : TEnjoyStr;
Begin
 LockAndWriteReturnToSkladFile:=False;
 New(Sklad,Init);
 For i:=1 To L^.DAt.Amount{J} Do
  Begin
   S1:=Copy(L^.Dat.VozwratElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Exit;
    End;
   Ls:=GetFileLocation3(Copy(L^.Dat.VozwratElement[i].BazKod,CRazdelKod+1,CKod));
   Seek(SkladFile,Ls);
   {блокируем позицию предварительной блокировкой}

   Repeat
    Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Sklad^.DAt);

   With Sklad^.Dat.Input Do
   Begin
     Caption:=L^.Dat.Caption;
     DelSpace(L^.Dat.VozwratElement[i].Input.Kol);
     Sklad^.Dat.Date := FDate;
     Sklad^.Dat.Time := Times;
     k:=StrToInt(L^.Dat.VozwratElement[i].Input.DivisionS);{т.к. все возвраты теперь приходуются в 5-ое отделение}
     Str(StrToInt(DivisionS[k])+StrToInt(L^.Dat.VozwratElement[i].Input.Kol):CKol,DivisionS[k]);
   End;
  {Sklad^.Dat.MakeVid:=L^.Dat.OperatorSelector;}
   Sklad^.Dat.Input.Kol[0]:=#0;

   For k:=1 To CDivision Do
   Str((StrToInt(Sklad^.Dat.Input.DivisionS[k])+StrToInt(Sklad^.Dat.Input.Kol)):CKol,Sklad^.Dat.Input.Kol);
   Sklad^.Dat.Employ:=True;
   {сохраняем изменения}
   Seek(SkladFile,FilePos(SkladFile)-1);
   Write(SkladFile,Sklad^.Dat);
   {деблокируем позицию}

   Seek(SkladFile,FilePos(SkladFile)-1);
   Repeat
    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

   Close(SkladFile);{закрытие файла}
  End;
Dispose(Sklad,Done);
LockAndWriteReturnToSkladFile:=True;
End;

Function TestFromLastPosition(Index:Byte;E:PNewVozwratType):Boolean;
Var j : Byte;
   Shablon : ArtikulStr;
Begin
TestFromLastPosition:=True;
Shablon:=E^.Dat.VozwratElement[Index].BazKod;
If (Index+1)<=E^.DAt.Amount Then
Begin
 For j:=Index+1 To E^.Dat.Amount Do
  Begin
   If E^.Dat.VozwratElement[j].BazKod=Shablon Then
    Begin
     TestFromLastPosition:=False;
     Break;
    End;
  End;
End;
End;


Function TestFromFirstPosition(Index:Byte;E:PNewVozwratType):Boolean;
Var j : Byte;
   Shablon : ArtikulStr;
Begin
TestFromFirstPosition:=True;
Shablon:=E^.Dat.VozwratElement[Index].BazKod;
If (Index-1)<=1 Then
Begin
 For j:=Index-1 DownTo 1 Do
  Begin
   If E^.Dat.VozwratElement[j].BazKod=Shablon Then
    Begin
     TestFromFirstPosition:=False;
     Break;
    End;
  End;
End;
End;


Function ExclusiveLockAllPosition(E:PNewVozwratType):Boolean;
Var l,Count : Word;
    Error : Boolean;
    Operator : Strname;
    Event : TEvent;

Begin
ExclusiveLockAllPosition:=False;
Error:=False;
For Count:=1 To E^.Dat.Amount Do
 Begin
  if testfromlastposition(count,E) then
  begin
  If Not(SetNameLock(E^.Dat.VozwratElement[Count].BazKod,Operator)) Then
   Begin
    Beep;
    DInfoMsg('Позиция ['+E^.Dat.VozwratElement[Count].BazKod+'] используется'+Operator+'. Не могу заблокировать позицию!');
    Application^.ClearEvent(Event);
    Application^.ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing) And (Event.Command<>cmMenu);
    NoInfoMsg;
    Application^.ClearEvent(Event);
    Error:=True;
    Break;
   End;
  end;
 End;

If Not (Error) Then ExclusiveLockAllPosition:=True;

If (Error) And (Count>1) Then
 Begin
  For l:=Count-1 DownTo 1 Do
   Begin
    if testfromfirstposition(l,E) then
    Repeat
    Until SetNameUnLock(E^.Dat.VozwratElement[l].BazKod);
   End;
 End;

End;

Procedure UnLockAllPosition(E:PNewVozwratType);
Var L : Word;
Begin
  For l:=1 To E^.Dat.Amount Do
  Begin
  if testfromfirstposition(l,E) then
  Repeat
  Until SetNameUnLock(E^.Dat.VozwratElement[l].BazKod);
  End;
End;


Function WriteReturnToClientVozwratFile(L:PNewVozwratType) : Boolean;
Var ReturnFile : File Of ClientNewVozwratType;
    i,p,k : Byte;
    Ls:LongInt;
    s1,s2 : TEnjoyStr;
    CV : PClientNewVozwratType;
Begin
   WriteReturnToClientVozwratFile:=False;
   If L^.Dat.OperatorSelector=0 Then
   Assign(ReturnFile,Path.ToClientReturn+L^.Dat.MakeKod+'.cvz')
   Else
   Assign(ReturnFile,Path.ToClientReturn+L^.Dat.MakeKod+'.svz');
   p:=IOResult;
   Reset(ReturnFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
      Rewrite(ReturnFile);
      p:=IOResult;
    End;

   Seek(ReturnFile,FileSize(ReturnFile));
   New(CV,Init);
   CV^.Dat.Return:=L^.Dat;
   Write(ReturnFile,CV^.Dat);
   Close(ReturnFile);
   Dispose(Cv,Done);
   WriteReturnToClientVozwratFile:=True;
End;



Function SpisDolgFromReal(L:PNewVozwratType) : Boolean;
Var c : Byte;
    R : Real;
    RealFile   : File Of RealizasiaType;
    MarketFile : File Of SuperMarketType;
    Realizasia : Boolean;
    ws : String[3];
    st : AllStr;
    Er : PRealizasiaType;
    Pos1,i : LongInt;
    Find:Boolean;
    Vid : Word;
    Oplata : OplataRealizasiaType;
    OplataFile : File Of OplataRealizasiaType;
    ClientOplata : ClientOplataRealizasiaType;
    ClientOplataFile : File Of ClientOplataRealizasiaType;
Begin
 SpisDolgFromReal:=True;
 Realizasia := False;
 If L^.Dat.VidDocument in [4,5] Then Realizasia:=True;

   If Realizasia Then
Begin
    Assign(RealFile,Path.ToDolg+L^.Dat.MakeKod+'.dlg');
    c:=IOResult;
    Reset(RealFile);
    c:=IOResult;
    If c <> 0 Then
                Begin
                 SpisDolgFromReal:=False;
                 MessageBox(#3^M+#3'Нет доступа к файлу '+L^.Dat.MakeKod+'.dlg!'
                 +^M+#3'Возврат не введен на склад!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;

    New(Er,Init);
    Find:=False;

    While Not(Eof(RealFile)) And Not(Find) Do
     Begin
      Read(RealFile,Er^.Dat);
      DelSpace(Er^.Dat.Market.Document);
      If (ClearChar(Er^.Dat.Market.Document)=ClearChar(L^.Dat.BasisDoc)) and (Er^.Dat.MArket.Active)
         and (Er^.Dat.Market.DateC=L^.Dat.BasisDate) And
            (Er^.Dat.Market.Active)Then Find:=True;
     End;

    If Not(Find) Then
     Begin
      SpisDolgFromReal:=False;
      Dispose(Er,Done);
      Close(RealFile);
      MessageBox(#3'Документ '+L^.Dat.BasisDoc+' от '+L^.Dat.BasisDate+^M+
      #3'в долгах клиента ('+L^.Dat.MakeKod+') не найден!'
      +^M+#3'Возврат не введен на склад!',
      nil, mfError + mfOkButton);
      Exit;
     End;

     St:=GetClientField(FClient,L^.Dat.MakeKod,0);
     DelSpaceRight(st);
     If MessageBox(^M+#3'Списывать долг с клиента '+St+' ('+L^.Dat.MakeKod+')?',Nil,mfWarning+mfOkCancel)<>cmOk Then
      Begin
      SpisDolgFromReal:=False;
      Dispose(Er,Done);
      Close(RealFile);
      Exit;
      End;


  If (Er^.Dat.Dolg-StrToReal(L^.Dat.SummaR)+StrToReal(L^.Dat.Skidka)-StrToReal(L^.Dat.ENalog))<-0.009 Then
    Begin

     If MessageBox(#3+'Сумма возврата клиента превышает сумму долга по оплате!'^M+
     #3'Клиенту придется выдавать деньги из кассы!', Nil,mfWarning+mfOkCancel)=cmOk
     Then
     Begin
      L^.Dat.Rashod:=True;
      MyStr(StrToReal(L^.Dat.SummaR)-StrToReal(L^.Dat.Skidka)
            +StrToReal(L^.Dat.ENalog)-Er^.Dat.Dolg,CIZena,CMantissa,
         L^.Dat.RashodSumma);
     End
     Else
     Begin
      SpisDolgFromReal:=False;
      Dispose(Er,Done);
      Close(RealFile);
      Exit;
     End


{    SpisDolgFromReal:=False;
     Dispose(Er,Done);
     Close(RealFile);
     MessageBox(#3+'Сумма возврата превышает сумму долга по оплате!'^M+
     #3'Сначала необходимо восстановить долг клиента и выдать ему деньги из кассы!',
     Nil,mfError+mfCancelButton);
     Exit;}


    End
    Else
     Begin
       L^.Dat.Rashod:=False;
       L^.Dat.RashodSumma[0]:=#0;
     End;


   Assign(OplataFile,Path.ToOplata+FDate+'.opl');
   c:=IOResult;
   Reset(OplataFile);
   c:=IOResult;
   If c<>0 Then
    Begin
     If MessageBox(#3'Файл оплаты консигнации за '+FDate+' не найден!'^M+
     #3'Создавать файл оплаты консигнации? '+
        +' Код:'+IntToStr(c,3),Nil,mfError+mfOkCancel)=cmOk Then
      Begin
{       c:=IOResult;
       Reset(Oplatafile);
       c:=IOresult;
       If c<>0 Then Rewrite(OplataFile);}
      If Not(CreatToDayF(DocOplata,FDate)) Then
          Begin
        SpisDolgFromReal:=False;
        Dispose(Er,Done);
        Close(RealFile);
           Exit;
       End;
      Reset(OplataFile);
      c:=IOResult;
      End
      Else
        Begin
         Dispose(Er,Done);
         Close(RealFile);
         SpisDolgFromReal:=False;
         Exit;
        End;
    End;

   Assign(ClientOplataFile,Path.ToClientOplata+L^.Dat.MakeKod+'.cpl');
   c:=IOResult;
   Reset(ClientOplataFile);
   c:=IOResult;
   If c<>0 Then
    Begin
     If MessageBox(#3'Файл хронологии оплаты консигнации клиента '+L^.Dat.MakeKod+' не найден!'^M+
     #3'Создавать файл хронологии оплаты консигнации?'+
        +' Код:'+IntToStr(c,3) ,Nil,mfError+mfOkCancel)=cmOk Then
      Begin
       c:=IOResult;
       Reset(ClientOplatafile);
       c:=IOresult;
       If c<>0 Then Rewrite(ClientOplataFile);
       c:=IOResult;
      End
      Else
        Begin
         Dispose(Er,Done);
         Close(RealFile);
         Close(OplataFile);
         SpisDolgFromReal:=False;
         Exit;
        End;
    End;

     i:= DateStringToDate(DateMask,FDate)-Er^.DAt.Market.Srok;
     Str(i:3,ws);
     DelSpace(ws);



    Oplata.Vozwrat:=True;
    Oplata.DocNumerReturn:=L^.Dat.Document;
    Oplata.DocDateReturn:=L^.Dat.DateC;

    Oplata.SkladKod:=Rek.Kod;
    Oplata.ClientKod:=L^.Dat.MakeKod;
    Oplata.DateC:=FDate;
    Oplata.Document:=L^.Dat.BasisDoc;
    Oplata.DateDoc:=L^.Dat.BasisDate;
    Oplata.TimeC:=Times; {время создания}
{   Oplata.SummaZ:=L^.Dat.SummaR;  {сумма оплаты}
{   Oplata.Skidka:=L^.Dat.Skidka;  {сумма оплаты}

    MyStr(StrToReal(L^.Dat.SummaR)
       +StrToReal(L^.Dat.ENalog),CIZena,CMantissa,Oplata.SummaZ);  {сумма оплаты}
    MyStr(StrToReal(L^.Dat.Skidka),CIZena,CMantissa,Oplata.Skidka);  {сумма оплаты}

    Oplata.Caption :=CurrentPassword;{признак оператора}

    Oplata.Rashet  :=False;
  {Очищаем без нальную переменную}
  With Oplata.Bn Do
  Begin
    Date [0] :=#0;
    NPlat[0] :=#0;
    Summa[0] :=#0;
    Bank [0] :=#0;
  End;

    ClientOplata.Vozwrat:=True;
    ClientOplata.DocNumerReturn:=L^.Dat.Document;
    ClientOplata.DocDateReturn:=L^.Dat.DateC;

    ClientOplata.SkladKod:=Rek.Kod;
    ClientOplata.ClientKod:=L^.Dat.MakeKod;
    ClientOplata.DateC:=FDate;
    ClientOplata.Document:=L^.Dat.BasisDoc;
    ClientOplata.DateDoc:=L^.Dat.BasisDate;
    ClientOplata.TimeC:=Times; {время создания}
    MyStr(StrToReal(L^.Dat.SummaR)
       +StrToReal(L^.Dat.ENalog),CIZena,CMantissa,ClientOplata.SummaZ);  {сумма оплаты}
    MyStr(StrToReal(L^.Dat.Skidka),CIZena,CMantissa,ClientOplata.Skidka);  {сумма оплаты}

    ClientOplata.Caption :=CurrentPassword;{признак оператора}

    ClientOplata.Srok:=DateToDAteString(DAteMask,DateStringToDate(DateMask,FDate)-StrToInt(ws));{срок опоздания}
    ClientOplata.Delta :=ws; {срок опоздания}


    ClientOplata.Rashet  :=False;
  {Очищаем безнальную переменную}
  With ClientOplata.Bn Do
  Begin
    Date [0] :=#0;
    NPlat[0] :=#0;
    Summa[0] :=#0;
    Bank [0] :=#0;
  End;

    DInfoNetMsg('Сохраняю оплату консигнации по докумену N '+Oplata.Document+' от '+Oplata.DateDoc+'...');
    (*********************************)
    Repeat
     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(OplataFile);
      Seek(OplataFile,Pos1);
     Until (Lock(OplataFile,FilePos(OplataFile)*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)*5));

     Pos1:=FileSize(OplataFile);

     If FilePos(OplataFile)<>Pos1{FileSize(OplataFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        Pause(1);
        UnLock(OplataFile,(FilePos(OplataFile))*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)*5);
       Until (DosError=0);
      End;

    Until (FilePos(OplataFile)=Pos1{FileSize(OplataFile)});

     Write(OplataFile,Oplata);
     Seek(OplataFile,FilePos(OplataFile)-1);
     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле оплаты консигнации...');


     Repeat {деблокируем участок записи}
      UnLock(OplataFile,(FilePos(OplataFile))*SizeOf(OplataRealizasiaType),
         SizeOf(OplataRealizasiaType)*5);
     Until (DosError=0);
    Close(OplataFile);

    NoInfoMsg;

{    Repeat
      Seek(OplataFile,FileSize(OplataFile));
      Pause(1);
     Until (Lock(OplataFile,FilePos(OplataFile)*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)*5));
     Write(OplataFile,Oplata);
     Seek(OplataFile,FilePos(OplataFile)-1);
     Repeat
      UnLock(OplataFile,FilePos(OplataFile)*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)*5);
     Until (DosError=0);}


    Seek(ClientOplataFile,FileSize(ClientOplataFile));
    Write(ClientOplataFile,ClientOplata);
    Close(ClientOplataFile);

    Er^.Dat.Dolg := Er^.Dat.Dolg
                   -StrToReal(L^.Dat.SummaR)
                            -StrToReal(L^.Dat.ENalog)
                            +StrToReal(L^.Dat.Skidka);
    MyStr(StrToReal(Er^.Dat.Market.Skidka)
       -StrToReal(L^.Dat.Skidka),CIZena,CMantissa,Er^.Dat.Market.Skidka);

     Seek(RealFile,FilePos(RealFile)-1);
     If Er^.Dat.Dolg<0 Then Er^.Dat.Dolg:=0;
     Write(RealFile,Er^.Dat);
     Dispose(Er,Done);
     Close(RealFile);
   End;
End;


Procedure InputNewVozwratToSklad(As : DocumentEdit);
Var f : File Of NewVozwratType;
    E : PNewVozwratType;
    PereozenkaElement :PPereozenkaType;
    PereozenkaFile : File Of PereozenkaType;
    l  : LongInt;
    j,i:Byte;
    free,Zapis,Save : Boolean;
    Event: TEvent;

Begin
 ClearFind;
 Save:=False;
 New(E,Init);
(*
 Assign(F,Path.ToReturn+As.D+'.vzw');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не найден файл '+Path.ToReturn+As.D+'.vzw',Nil,mfError+mfCancelButton);
   Exit;
  End;

 L:=GetFileLocation3(ClearChar(As.EditPosition));
 If (FileSize(f)<L) Or (L=0) Then
 Begin
   Close(f);
   MessageBox(#3^M+#3'Документ возврата N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
 End;

 Seek(f,L-1);
 New(E,Init);
 Read(f,E^.Dat);
 Close(f);

 If (E^.Dat.StatusDoc=0) Then
 Begin
 MessageBox(#3^M+#3'Документ возврата N '+As.EditPosition+' от '+As.D+''^M+
 #3'уже введен на склад!',Nil,mfError+mfCancelButton);
 Dispose(E,Done);
 Exit;
 End;
*)

 i:=LockReturn(As,E);
    If I=3 Then
     Begin
      DinfoMsg('Не могу заблокировать док-т возврата N '+E^.Dat.Document+' от '+E^.Dat.DateC+
         '. Попробуйте повторить!');
      Dispose(E,Done);
      Beep;
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

If Not(ExclusiveLockAllPosition(E)) Then
     Begin
      Repeat
      Until (UnLockReturn(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
      Dispose(E,Done);
      Exit;
     End;

    If Not(SetClientLock(E^.Dat.MAkeKod,0,E^.Dat.OperatorSelector)) Then
     Begin
     Repeat
     Until (UnLockReturn(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
     UnLockAllPosition(E);
     DinfoMsg('Не могу заблокировать клиента '+E^.Dat.MakeKod+'! Попробуйте повторить!');
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



 E^.Dat.StatusDoc:=0;

New(PereozenkaElement,Init);
PereozenkaElement^.Dat.DateM:=FDate;
PereozenkaElement^.Dat.TimeM:=Times;
PereozenkaElement^.Dat.DateC:=FDate;
PereozenkaElement^.Dat.TimeC:=Times;
PereozenkaElement^.Dat.Vid:=As.Vid;{надо исправит для случая возврата и прихода}
j:=1;
For i:=1 To E^.Dat.Amount Do
 Begin
If ((StrToReal(E^.Dat.VozwratElement[i].Input.R_Zena)<>StrToReal(BakGetField(FRZena,E^.Dat.VozwratElement[i].Bazkod,
0)))Or
(StrToReal(E^.Dat.VozwratElement[i].Input.O_Zena)<>StrToReal(BakGetField
(FOZena,E^.Dat.VozwratElement[i].Bazkod,0))))
  And (StrToInt(E^.Dat.VozwratElement[i].Input.Kol)>0) Then
   Begin
    PereozenkaElement^.Dat.Element[j].BazKod:=E^.Dat.VozwratElement[i].BazKod;
    PereozenkaElement^.Dat.Element[j].Kol:=E^.Dat.VozwratElement[i].Input.Kol;
    PereozenkaElement^.Dat.Element[j].Bak_R_Zena:=E^.Dat.VozwratElement[i].Input.R_Zena;
    PereozenkaElement^.Dat.Element[j].Bak_O_Zena:=E^.Dat.VozwratElement[i].Input.O_Zena;
    PereozenkaElement^.Dat.Element[j].New_R_Zena:=BakGetField(FRZena,E^.Dat.VozwratElement[i].BazKod,0);
    PereozenkaElement^.Dat.Element[j].New_O_Zena:=BakGetField(FOZena,E^.Dat.VozwratElement[i].BazKod,0);
{    PereozenkaElement^.Dat.Sklad:=Rek.SkladsName;}
    PereozenkaElement^.Dat.Caption := CurrentPassword;

    {Расчет суммы по новым РЦ}
    MyStr(StrToInt(E^.Dat.VozwratElement[i].Input.Kol)*StrToReal(BakGetField
    (FRZena,E^.Dat.VozwratElement[i].BazKod,0))+
     StrToReal(PereozenkaElement^.Dat.Itogo_New_R_Zena),CIZena,CMantissa
    ,PereozenkaElement^.Dat.Itogo_New_R_Zena);

    DelSpace(PereozenkaElement^.Dat.Itogo_New_R_Zena);

    {Расчет суммы по новым ОЦ}
    MyStr(StrToInt(E^.Dat.VozwratElement[i].Input.Kol)*StrToReal(BakGetField
    (FOZena,E^.Dat.VozwratElement[i].BazKod,0 ))+
     StrToReal(PereozenkaElement^.Dat.Itogo_New_O_Zena),CIZena,CMantissa
    ,PereozenkaElement^.Dat.Itogo_New_O_Zena);

    DelSpace(PereozenkaElement^.Dat.Itogo_New_O_Zena);

    {Расчет суммы по старым РЦ}
    MyStr(StrToInt(E^.Dat.VozwratElement[i].Input.Kol)*StrToReal(E^.Dat.VozwratElement[i].Input.R_Zena)+
     StrToReal(PereozenkaElement^.Dat.Itogo_Bak_R_Zena),CIZena,CMantissa
    ,PereozenkaElement^.Dat.Itogo_Bak_R_Zena);

    DelSpace(PereozenkaElement^.Dat.Itogo_Bak_R_Zena);

    {Расчет суммы по старым ОЦ}
    MyStr(StrToInt(E^.Dat.VozwratElement[i].Input.Kol)*StrToReal(E^.Dat.VozwratElement[i].Input.O_Zena)+
     StrToReal(PereozenkaElement^.Dat.Itogo_Bak_O_Zena),CIZena,CMantissa
    ,PereozenkaElement^.Dat.Itogo_Bak_O_Zena);

    DelSpace(PereozenkaElement^.Dat.Itogo_Bak_O_Zena);

    Inc(j);
    Inc(PereozenkaElement^.Dat.Amount);
   End;
 End;
    MyStr(StrToReal(PereozenkaElement^.Dat.Itogo_New_R_Zena)-StrToReal(PereozenkaElement^.Dat.Itogo_Bak_R_Zena),
    CIZena,CMantissa
    ,PereozenkaElement^.Dat.Delta_RZ);
    DelSpace(PereozenkaElement^.Dat.Delta_RZ);
    MyStr(StrToReal(PereozenkaElement^.Dat.Itogo_New_O_Zena)-StrToReal(PereozenkaElement^.Dat.Itogo_Bak_O_Zena),
    CIZena,CMantissa
    ,PereozenkaElement^.Dat.Delta_OZ);
    DelSpace(PereozenkaElement^.Dat.Delta_OZ);
{конец Цикла проверки возможности автоматической переоценки}

    Assign(PereozenkaFile,Path.ToCorrect+TekDate+'.prz');
    i:=IOResult;
    Reset(Pereozenkafile);
    i:=IOResult;
    If I <> 0 Then
    Begin
  If MessageBox(#3'Файл переоценки '+TekDate+'.prz не найден!'^M+
     'Создаю файл ? Если вы раньше что-либо переоценили позовите программиста!'
        +' Код:'+IntToStr(i,3),nil, mfConfirmation + mfOkCancel)=cmOk  Then
     Begin
{     i:=IOresult;
      Reset(PereozenkaFile);
      i:=IOresult;
      If i<>0 Then Rewrite(PereozenkaFile);}
      If Not(CreatToDayF(DocPereozen,TekDate)) Then
          Begin
        Save:=False;
        Repeat
        Until (UnLockReturn(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
        UnLockAllPosition(E);
        Repeat               {деблокировка клиента проводящего возврат}
        Until (SetClientUnLock(E^.Dat.MakeKod,0,E^.Dat.OperatorSelector));
        Dispose(E,Done);
        Dispose(PereozenkaElement,Done);
           Exit;
       End;
      Reset(PereoZenkaFile);
      i:=IOResult;
     End
    Else
     Begin
      Save:=False;
      Repeat
      Until (UnLockReturn(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
      UnLockAllPosition(E);
      Repeat               {деблокировка клиента проводящего возврат}
      Until (SetClientUnLock(E^.Dat.MakeKod,0,E^.Dat.OperatorSelector));
      Dispose(E,Done);
      Dispose(PereozenkaElement,Done);
      Exit;
     End;
    End;{I<>0}
  PereozenkaElement^.Dat.Document:=InttoStr(FileSize(PereozenkaFile)+1,CDocNumer);
  System.Close(PereozenkaFile);
  E^.Dat.DocumentPrz:=PereozenkaElement^.Dat.Document;
  free:=false;
If {J>1}PereozenkaElement^.Dat.Amount>0 Then {если нужна переоценка, тогда запрос на экран}
  Begin
  If Not(UseDocNumer(DocPereozen,TekDate,PereozenkaElement^.Dat.Document)) Then
   Begin
    Save:=False;
    Repeat
    Until (UnLockReturn(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
    UnLockAllPosition(E);
    Repeat               {деблокировка клиента проводящего возврат}
    Until (SetClientUnLock(E^.Dat.MakeKod,0,E^.Dat.OperatorSelector));
    Dispose(E,Done);
    Dispose(PereozenkaElement,Done);
    Exit;
   End;

    If Zapros(PereozenkaElement,{j-1}PereozenkaElement^.Dat.Amount) Then
     Begin
      PereoZenkaElement^.Dat.DocumentWith:=E^.DAt.Document;
      PereoZenkaElement^.Dat.DateWith:=E^.DAt.DateC;
      j:=E^.DAt.Amount;
      {0.Списать долг если это открытая консигнация
       1.Записать возврат на склад
       2.Записать возврат в файл возврата
       3.Записать возврат в персональный файл возврата клиента
       4.Записать доценки в файл переоценки}

      {вставить соответствующий код}
      Save:= SpisDolgFromReal(E);

      If Not(Save) Then
       Begin
{
        Repeat
        Until (FreeDocNumer(Docpereozen,TekDate,PereozenkaElement^.Dat.Document));
}
        free:=true;
       End;

      Zapis:=False;
      If Save Then
                           Begin
                             Zapis:= LockAndWriteReturn(E,True);{2}
                             Save:=Zapis;
                           End;

      Repeat
      Until (UnLockReturn(E^.Dat.Document,E^.Dat.DateC) in [0,2]);

      If Not(Save) Then
       Begin
{
        If Not(Free) Then
        Repeat
        Until (FreeDocNumer(Docpereozen,TekDate,PereozenkaElement^.Dat.Document));
}
       End;

      If Save Then Save:=LockAndWriteReturnToSkladFile(E);{1}
      If Not(Save) Then
       Begin
{
        If Not(Free) Then
        Repeat
        Until (FreeDocNumer(Docpereozen,TekDate,PereozenkaElement^.Dat.Document));
}
       End;

      If Save Then Save:=WriteReturnToClientVozwratFile(E);{3}


      {If Save Then Save:=WriteVozwratToFile(E);}

      If Not(Save) Then
       Begin
{
        If Not(Free) Then
        Repeat
        Until (FreeDocNumer(Docpereozen,TekDate,PereozenkaElement^.Dat.Document));
}
       End;
      If Save Then Save:=LockAndWritePereozenka(PereozenkaElement)
      Else
       Begin
{
        If Not(Free) Then
        Repeat
        Until (FreeDocNumer(Docpereozen,TekDate,PereozenkaElement^.Dat.Document));
}
       End;
      If Save Then
                 Begin
                 If MessageBox(#3^m+#3'Накладная возврата введена на склад !'^M+
                 #3'Печатать накладную возврата ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
                  Begin
                   As.D:=TekDate;
                   As.EditPosition:=E^.Dat.Document;
                   If NewPrintVozwrat(As) Then PrintRashodOrder(As);
                  End;
                 If MessageBox(#3^M+#3'Печатать акт переоценки ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
                  Begin
                   As.D:=TekDate;
                   As.EditPosition:=E^.Dat.DocumentPrz;
                   PrintAktPrz(As);
                  End;
                  AddProtocol('Ввод накладной возврата N '+E^.Dat.Document+' от '+TekDate+' на склад','','');
                 End;
     End
     Else
	 Begin
	  Save:=False;
       Repeat
       Until (UnLockReturn(E^.Dat.Document,E^.Dat.DateC) in [0,2]);
      End;
   Dispose(PereozenkaElement,Done);
  End{конец если переоценка}
  Else{если нет переоценки}
   Begin
      Dispose(PereozenkaElement,Done);
      Save:= SpisDolgFromReal(E);
      Zapis:=False;
      If Save Then Begin
                    Zapis:=LockAndWriteReturn(E,True);{2}
                    Save:=Zapis;
                   End;
      Repeat
      Until (UnLockReturn(E^.Dat.Document,E^.Dat.DateC) in [0,2]);

      If Save Then Save:=LockAndWriteReturnToSkladFile(E);{1}


      If Save Then Save:=WriteReturnToClientVozwratFile(E);{3}

   If Save Then
                 Begin
                 If MessageBox(^M+#3'Накладная возврата введена на склад !'^M+
                 #3'Печатать накладную возврата ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
                  Begin
                   As.D:=TekDate;
                   As.EditPosition:=E^.Dat.Document;
                   If NewPrintVozwrat(As) Then PrintRashodOrder(As);
                  End;
                 AddProtocol('Ввод накладной возврата N '+E^.Dat.Document+' от '+TekDate+' на склад','','');
                 End;
   End;

UnLockAllPosition(E);{деблокировка всех позиций на складе}
Repeat               {деблокировка клиента проводящего возврат}
Until (SetClientUnLock(E^.Dat.MakeKod,0,E^.Dat.OperatorSelector));

Dispose(E,Done);
ClearFind;
End;

{
Var f: File Of SkladType;
    e : SkladType;
Begin
 filemode:=66;
 Assign(f,'c:\1.txt');
 Rewrite(f);
 Write(f,e);
 Close(f)}
End.