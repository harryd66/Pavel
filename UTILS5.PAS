{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit utils5;


Interface

Uses Glob,ServStr,Dialogs,MyCalc,Drivers;



Type
    PSelAkzisWindow= ^TSelAkzisWindow;
    TSelAkzisWindow = object(TDialog)
    Procedure SelectVidAkzis(Var res:LongInt;Var LL:Word);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;



Function CompareFile(Dest:string;Sourse:string):boolean;
Procedure TestDolgMrkDate(var p:PBox;cl:RealizasiaType);
Function TestHisElement(const P:PBox;s: string):boolean;

Function GetOpt(Lz:PNewVozwratType):Boolean;


Function Zapros(PereozenkaElement : PPereozenkaType;j:Byte): Boolean;
function MakeSkidka(Var AllSum,Sk : Float): Boolean;
Function TestExportMarket(E:PSuperMArketType;Video:Boolean):Boolean;
Function SelectDSertif(Var VidZaprosa,VidProsmotra,Diapason:Word):Boolean;
Function ChistkaCataloga(Cod:ArtikulStr):Boolean;
Function InputProzFromZennik(VAr Proz:ArtikulStr):Boolean;
Procedure GlobalNazenkaOutZakupka2(Var P:PBox);
Function SelAssortiment(Var ES:LongInt):Boolean;
Function Menedger(Var K:TDateString):Word;
Procedure CreatBinAndRun(VAr Event:TEvent);
Procedure CreatBinAndRunTools(VAr Event:TEvent);

Function PeriodFromLock(Regim:Boolean):Boolean;
function DosToWin(s:string):string;
Function SelIndex (VAr Res : Word):Boolean;
Function Kurs(Var K:TDateString):Word;
Procedure DelFlag;
Function TestFlag:Boolean;
Function TestSrokLizensia(c:AllStr;vid:byte;Date:TDateString):Boolean;
Procedure GlobalNazenka(Var P:PBox);
Procedure GlobalSkidkaSpec (Var P:PBox);
Procedure GlobalSkidka (Var P:PBox);
Procedure CalcComputer(VAr S: String;Res:Boolean);
Function GetLizensiaFromProgramm:AllStr;
Function TestPC:Byte;
Function Install(Var Password,DAte:LongInt):Boolean;
Function TestMarketFile(TekDate:TDateString):Boolean;
Procedure CreatSpecialFile(Doc:Word;Date:TDateString);
Function SelectOperation(Var l : Word):Boolean;
Function KeySorting(Var Key,D:Word;Const Bak:Boolean):Boolean;
Function CalcMesto(E:PSuperMArketType):ArtikulStr;
Function CalcMestoDiv(E:PSuperMArketType;Division:Word):ArtikulStr;
Function CalcMestoP(E:PrihodType):ArtikulStr;
Function SelectOtd(Var l : Word):Boolean;
Function Test3000(Cod:ArtikulStr;Summa:AllStr):Boolean;
function SelVidKAssa : Word;
function FExists(FileName: TMyString): Boolean;
function FExists1(FileName: TMyString;Var Res : LongInt): Boolean;
Function FullScreen(Const P:PBox;Const s,s1:TMyString;SDoc:ArtikulStr;SDate:TDateString;
                          t:Byte):Boolean;
Procedure AddProtocolVozwrat(s:String);
Procedure AddProtocol(s,s1,s2:String);

Function IncData(D:TDateString):TDateString;
Function TestDate(Const s:TDateString;Var l:LongInt) : Boolean;
Function SelectSpecify(Regim :Boolean;Reg:Byte):Byte;
Function TestFromReturn(Const SClient,SDoc,SDate:AllStr; Var SDocReturn,SDocReturnDate:AllStr):Boolean;

Procedure SortNaklPrh (Var E:PrihodType);


Function CreatLockPrihod(Var F : File):Boolean;
Procedure UnLockImportPrihod(Var F : File);

implementation


Uses Serv,Objects,DbEngine,MsgBox,NetDbEng,Protect,Editors,TpDate,NetCall,
     CPrihod,Mail,Utils1,Memory,Utils7,DbEngin2,X_Dialog,ServStr2,
     Views,ColorTxt,Validate,App,Printers,Utils,DOS,Vision1,MrkTools,
  TVInput,TvType,TvConst;


Var LArt : ArtikulStr;
    LinkList,NoScreenList1: PBox;
    ControlInfo,ControlCount,ControlSelector,ControlVidOtbora : PView;
    VidOtbora,VidProsmotra,Otobragenie : Word;
    ControlHeader,ControlOtobragenie : PView;
    ControlNGTD,ControlMarka,ControlVirabotano,ControlDo,
    ControlFullNAme,ControlMsg,ControlR,ControlRz,ControlText,ControlCl,Control : PView;
    VidSkidki : AllStr;
    ReturnCount : Word;
    SelAkzisWin :PSelAkzisWindow;
    {SelObjectsWin :PSelObjectsWindow;}




Function GetOpt(Lz:PNewVozwratType):Boolean;
Var F : MarketFIleType;
    i : Byte;
    l : LongInt;
    E : PSuperMarketType;
Begin
GetOpt:=True;
Assign(f,Path^.Dat.ToMarket+Lz^.Dat.BasisDate+'.mrk');
i:=IOResult;
Reset(F);
i:=IOResult;
If i <> 0 Then
  Begin
   MessageBox(#3^M+#3+'Данные за '+Lz^.Dat.BasisDate+' в базе отсутствуют !',Nil,mfError+mfCancelButton);
   Exit;
  End;
  New(E,Init);

DelSpace(Lz^.Dat.BasisDoc);
While Not(Eof(f)) And
      Not((ClearChar(Lz^.Dat.BasisDoc)=ClearChar(E^.Dat.Document))
      And(Lz^.Dat.MakeKod=E^.Dat.ClientKod)And(E^.Dat.Active)) Do
      Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMArket(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
      DelSpace(E^.Dat.Document);
      DelSpace(E^.Dat.ClientKod);
      End;

If Eof(f) And Not
   ((ClearChar(Lz^.Dat.BasisDoc)=ClearChar(E^.Dat.Document))And
   (Lz^.Dat.MakeKod=E^.Dat.ClientKod)And(E^.DAt.Active))
      Then
   Begin
   Close(f);
   Dispose(E,Done);
   MessageBox(^M+#3+'В базе данных за '+Lz^.Dat.BasisDate+' документ N '+Lz^.Dat.BasisDoc+ ' с клиентом '+
   Lz^.Dat.MakeKod+
   ' не найден!',Nil,mfError+mfCancelButton);
   Exit;
   End;

   Close(f);

If E^.Dat.DocSelector in [0,1,2] Then GetOpt:=False
Else
 Begin

  If E^.Dat.DocSelector in [6,8] Then
         GetOpt:=True{TestSf(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC)};
  If E^.Dat.DocSelector in [5,7] Then
         GetOpt:=False{TestSf(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC)};
 End;
{
 Else
  If E^.Dat.DocSelector=5 Then
  GetOpt:=TestSf(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC);
}
Dispose(E,Done);
End;












Function Zapros(PereozenkaElement : PPereozenkaType;j:Byte): Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  ControlBak_R_Zena : PColoredText;
  ControlBak_O_Zena : PColoredText;
  ControlNew_R_Zena : PColoredText;
  ControlNew_O_Zena : PColoredText;
  ControlItogo_R_Zena : PColoredText;
  ControlItogo_O_Zena : PColoredText;
  ControlDocNum : PColoredText;
  ControlDate : PColoredText;
  ControlSklad : PColoredText;
  ws,s : String;
  c:Word;

begin

ClearFind;
R.Assign(1, 0, 78, 23);
New(Dlg, Init(R, 'Автоматическая переоценка товара'));
Dlg^.Options := Dlg^.Options or ofTileable or ofCenterX or ofCenterY;
Dlg^.HelpCtx :=$E080;

R.Assign(76, 3, 77, 19);
Control := New(PScrollBar, Init(R));
Dlg^.Insert(Control);

R.Assign(1, 3, 76, 19);
Pereozenka := New(PBox, Init(R, 1, PScrollbar(Control)));
Pereozenka^.NewList(New(PTextCollection, Init(1,1)));
For c:=1 To j Do
 Begin
  ws:=GetIdField(FName,PereozenkaElement^.Dat.Element[c].BazKod);
  Format(ws,CName);
  s:=ws;
  ws:=PereozenkaElement^.Dat.Element[c].BazKod;
  Format(ws,CArtikul);
  s:=s+'│'+ws;
  ws:=PereozenkaElement^.Dat.Element[c].Kol;
  Format(ws,CKol);
  s:=s+'│'+ws;
  ws:=PereozenkaElement^.Dat.Element[c].Bak_R_Zena;
  MySTr(StrToReal(ws),CZena,CMantissa,ws);
  Format(ws,CZena);
  s:=s+'│'+ws;
  ws:=PereozenkaElement^.Dat.Element[c].Bak_O_Zena;
  MySTr(StrToReal(ws),CZena,CMantissa,ws);
  Format(ws,CZena);
  s:=s+'│'+ws;
  ws:=PereozenkaElement^.Dat.Element[c].New_R_Zena;
  MySTr(StrToReal(ws),CZena,CMantissa,ws);
  Format(ws,CZena);
  s:=s+'│'+ws;
  ws:=PereozenkaElement^.Dat.Element[c].New_O_Zena;
  MySTr(StrToReal(ws),CZena,CMantissa,ws);
  Format(ws,CZena);
  s:=s+'│'+ws;
  Pereozenka^.List^.Insert(NewStr(s));
  Pereozenka^.SetRange(Pereozenka^.List^.Count);
 End;
Pereozenka^.FocusItem(0);

Dlg^.Insert(Pereozenka);

  R.Assign(1, 2, 76, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Наименование               Код   Колич Р/Цена   О/Цена   Р/Цена   О/Цена  ', Pereozenka)));

R.Assign(3, 19, 23, 20);
Control := New(PColoredText, Init(R, 'Итого по старым Р/Ц:', $74));
Dlg^.Insert(Control);

R.Assign(3, 20, 23, 21);
Control := New(PColoredText, Init(R, 'Итого по старым С/Ц:', $74));
Dlg^.Insert(Control);

R.Assign(23, 19, 38, 20);
ControlBak_R_Zena := New(PColoredText, Init(R, ''+PereozenkaElement^.Dat.Itogo_Bak_R_Zena, $7E));
Dlg^.Insert(ControlBak_R_Zena);

R.Assign(23, 20, 38, 21);
ControlBak_O_Zena := New(PColoredText, Init(R, ''+PereozenkaElement^.Dat.Itogo_Bak_O_Zena, $7E));
Dlg^.Insert(ControlBak_O_Zena);

R.Assign(40, 19, 59, 20);
Control := New(PColoredText, Init(R, 'Итого по новым Р/Ц:', $74));
Dlg^.Insert(Control);

R.Assign(59, 19, 74, 20);
ControlNew_R_Zena := New(PColoredText, Init(R, ''+PereozenkaElement^.Dat.Itogo_New_R_Zena, $7E));
Dlg^.Insert(ControlNew_R_Zena);

R.Assign(40, 20, 59, 21);
Control := New(PColoredText, Init(R, 'Итого по новым С/Ц:', $74));
Dlg^.Insert(Control);

R.Assign(59, 20, 74, 21);
ControlNew_O_Zena := New(PColoredText, Init(R, ''+PereozenkaElement^.Dat.Itogo_New_O_Zena, $7E));
Dlg^.Insert(ControlNew_O_Zena);

R.Assign(1, 1, 12, 2);
Control := New(PColoredText, Init(R, 'Документ N:', $74));
Dlg^.Insert(Control);

R.Assign(16, 1, 21, 2);
Control := New(PColoredText, Init(R, 'Дата:', $74));
Dlg^.Insert(Control);

R.Assign(3, 21, 23, 22);
Control := New(PColoredText, Init(R, 'Переоценка  по Р/Ц:', $74));
Dlg^.Insert(Control);

R.Assign(23, 21, 38, 22);
ControlItogo_R_Zena := New(PColoredText, Init(R, ''+PereozenkaElement^.Dat.Delta_RZ, $7E));
Dlg^.Insert(ControlItogo_R_Zena);

R.Assign(40, 21, 59, 22);
Control := New(PColoredText, Init(R, 'Переоценка  по С/Ц:', $74));
Dlg^.Insert(Control);

R.Assign(59, 21, 74, 22);
ControlItogo_O_Zena := New(PColoredText, Init(R, ''+PereozenkaElement^.Dat.Delta_OZ, $7E));
Dlg^.Insert(ControlItogo_O_Zena);

{Str(PereozenkaElement.Document:3,S);}
R.Assign(12, 1, 15, 2);
ControlDocNum := New(PColoredText, Init(R, ''+PereozenkaElement^.Dat.Document, $7E));
Dlg^.Insert(ControlDocNum);

R.Assign(21, 1, 29, 2);
ControlDate := New(PColoredText, Init(R, ''+TekDate, $7E));
Dlg^.Insert(ControlDate);

R.Assign(57, 0, 64, 1);
ControlSklad := New(PColoredText, Init(R, ' Склад:', $74));
Dlg^.Insert(ControlSklad);

R.Assign(64, 0, 76, 1);
Control := New(PColoredText, Init(R, ''+GetClientField(FClient,PereozenkaElement^.Dat.SkladKod,1), $7E));
Dlg^.Insert(Control);

R.Assign(45, 1, 51, 2);
Control := New(PColoredText, Init(R, 'Старые', $74));
Dlg^.Insert(Control);

R.Assign(64, 1, 69, 2);
Control := New(PColoredText, Init(R, 'Новые', $74));
Dlg^.Insert(Control);

R.Assign(2, 0, 16, 1);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

Str(j:2,ws);
DelSpace(ws);

R.Assign(16, 0, 20, 1);
Control := New(PColoredText, Init(R, #3+ws, $4E));
Dlg^.Insert(Control);



Dlg^.SelectNext(False);
C:=Desktop^.ExecView(Dlg);
If c<> CmCancel Then
      Zapros:=True
Else
     Zapros:=False;
Dispose(  Pereozenka,Done);
Dispose(  ControlBak_R_Zena,Done);
Dispose(  ControlBak_O_Zena,Done);
Dispose(  ControlNew_R_Zena,Done);
Dispose(  ControlNew_O_Zena,Done);
Dispose(  ControlItogo_R_Zena,Done);
Dispose(  ControlItogo_O_Zena,Done);
Dispose(  ControlDocNum,Done);
Dispose(  ControlDate,Done);
Dispose(  ControlSklad,Done);
Dispose(  Control,Done);
Dispose(Dlg,Done);
ClearFind;

End;




Function TestExportMarket(E:PSuperMArketType;Video:Boolean):Boolean;
VAr F : File;
    c : Word;
    As : DocumentEditZ;
Begin
TestExportMArket:=True;
As.EditPosition:=E^.DAt.Document;
As.D:=E^.DAt.DAteC;
If E^.Dat.Exporting=1 Then{т.е. экспорт производился}
If FExists(PathExpImp^.Dat.ToImport[1]+GetImportFileName(As,E^.Dat.ClientKod)) Then
   Begin
    If(Not SystemAttribute(PathExpImp^.Dat.ToImport[1]+GetImportFileName(As,E^.Dat.ClientKod))) And
      (Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+GetImportFileName(As,E^.Dat.ClientKod))) Then
    Begin
     Assign(f,PathExpImp^.Dat.ToImport[1]+GetImportFileName(As,E^.Dat.ClientKod));
     c:=IoResult;
     Erase(f);
     c:=IoResult;
     If Video Then
     MessageBox(WarningExportRepeat^,Nil,mfWarning+mfCAncelButton);
    End
    Else
     Begin
      MessageBox(WarningExport^,Nil,mfWarning+mfCAncelButton);
      TestExportMArket:=False;
     End;
   End;
End;



function MakeSkidka(Var AllSum,Sk : Float): Boolean;
var
  Dlg     : PDialog;
  R       : TRect;
  Control : PView;
  c       : Word;
  ss      : String[CIZena];


begin
MakeSkidka:=False;
ss:=RealToStr(sk,CIZena,CMAntissa);
DelSpace(ss);
R.Assign(23, 7, 56, 19);
New(Dlg, Init(R, 'Фикт.скидка'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(1, 1, 32, 11);
Control := New(PRadioButtons, Init(R,
  NewSItem('~1~ %',
  NewSItem('~2~ %',
  NewSItem('~3~ %',
  NewSItem('~4~ %',
  NewSItem('~5~ %',
  NewSItem('~6~ %',
  NewSItem('~7~ %',
  NewSItem('~8~ %',
  NewSItem('~9~ %',
  NewSItem(RealToStr(sk,CIZena,CMAntissa)+' (как есть)', Nil))))))))))));
Dlg^.Insert(Control);

c:=9;

Dlg^.SetDAta(c);
Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(c);
  sk:=StrToReal(ss);
  Case c Of
  0..8:sk:=AllSum-AllSum/(StrToReal('1.0'+IntToStr(c+1,COne)));
  Else;
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  MakeSkidka:=True;
 End;


end;




Procedure TSelAkzisWindow.SelectVidAkzis(Var res:LongInt;Var LL:Word);
var
  R : TRect;
  Control : PView;
  c : Word;
begin
LL:=0;

R.Assign(1, 7, 78, 18);
New(SelAkzisWin, Init(R, 'Укажите вид продукции'));
SelAkzisWin^.Options := SelAkzisWin^.Options or ofCenterX or ofCenterY;
SelAkzisWin^.HelpCtx := $E002;

R.Assign(1, 1, 76, 10);
Control := New(PRadioButtons, Init(R,
  NewSItem(GroupName[0]^,
  NewSItem(GroupName[1]^,
  NewSItem(GroupName[2]^,
  NewSItem(GroupName[3]^,
  NewSItem(GroupName[4]^,
  NewSItem(GroupName[5]^,
  NewSItem(GroupName[6]^,
  NewSItem(GroupName[7]^,
  NewSItem(GroupName[8]^,
  Nil)))))))))));
SelAkzisWin^.Insert(Control);

c:=Res;

SelAkzisWin^.SelectNext(False);
SelAkzisWin^.SetDAta(c);

c:=Desktop^.ExecView(SelAkzisWin);
If c<>cmCAncel Then
 Begin
   If c=CmOk Then LL:=2;
   If c=CmYes Then LL:=3;
   If c=CmCancel Then LL:=1;
  SelAkzisWin^.GetDAta(c);
  Res:=c;
  Dispose(Control,Done);
  Dispose(SelAkzisWin,Done);
 End
Else
 Begin
  LL:=1;
  Dispose(Control,Done);
  Dispose(SelAkzisWin,Done);
 End;
end;


procedure TSelAkzisWindow.HandleEvent(var Event: TEvent);
Begin


  if ((Event.What = evMouseDown) and (Event.Double)) or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbEnter)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlEnter)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbTab)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlRight)) Then
  begin
              Event.What:=evCommand;
              Event.Command:=cmOk;
              PutEvent(Event);
              ClearEvent(Event);
  end;

  if ((Event.What = evKeyDown) and (Event.KeyCode =kbShiftTab))Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlLeft)) Then
  begin
              Event.What:=evCommand;
              Event.Command:=cmYes;
              PutEvent(Event);
              ClearEvent(Event);

  end;

  if ((Event.What = evKeyDown) and (Event.KeyCode = kbEsc))then
  begin
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
  end;



inherited HandleEvent(Event);



End;

Destructor TSelAkzisWindow.Done;
Begin
TDialog.Done;
End;




Function ChistkaCataloga(Cod:ArtikulStr):Boolean;
VAr f : Text;
    c : Word;
Begin

 RFormatZerro(Cod,CMAntissa);
 MkDir(Path^.Dat.ToOperator+Cod);
 MkDir(Path^.Dat.ToOperator+Cod+'\Temp');
 c:=IOResult;
 Assign(f,Path^.Dat.ToOperator+Cod+'\Trash.bat');
 c:=IOResult;
 Rewrite(f);
 c:=IOResult;
 Writeln(f,'@deltree /Y '+Path^.Dat.ToOperator+Cod+'\Temp\*.* '+NULLSTR^);
 c:=IOResult;
 Close(f);
 c:=IOResult;
 DInfoMsg('Очистка мусора в каталоге пользователя...',False);

  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneVideo;
  DoneDosMem;
  SwapVectors;
  Exec (GetEnv('Comspec'),' /c '+Path^.Dat.ToOperator+Cod+'\Trash.bat');

  SwapVectors;
  InitDosMem;
  InitVideo;
  InitEvents;
  InitSysError;
  CursorLines:=1543;
  Application^.Redraw;
                      Case DosError Of
                      2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
                      3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
                      5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
                      6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
                      8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
                     10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
                     11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
                     18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
                        Else;
                       End;

 c:=IOResult;
 NoInfoMsg;

 If (FindParam('/TERMINAL')) Or (Terminal=1) Then
 Path^.Dat.ToTemp:=Path^.Dat.ToOperator+Cod+'\Temp\';

End;



Function InputProzFromZennik(VAr Proz:ArtikulStr):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
InputProzFromZennik:=FAlse;
Proz:='5.00';
R.Assign(34, 9, 46, 12);
New(Dlg, Init(R, ''));
Dlg^.HelpCtx:=$E002;

R.Assign(4, 1, 11, 2);
Control := New(PInputLine, Init(R, CLitr));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init('#[[#].[#][#]]', True));

  R.Assign(1, 1, 4, 2);
  Dlg^.Insert(New(PLabel, Init(R, '%:', Control)));

Dlg^.SelectNext(False);
Dlg^.SetDAta(Proz);
c:=Desktop^.ExecView(Dlg);
If c<> cmCAncel Then
 Begin
  Dlg^.GetDAta(Proz);
  DelSpace(Proz);
  MyStr(1+StrToReal(Proz)/100,CLitr,CMAntissa,Proz);
  DelSpace(Proz);
  InputProzFromZennik:=True;
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;


Procedure CreatMonopolia(St:ArtikulStr);
Var f : File;
Begin
{
 DelSpace(St);
 If St[0]=#0 Then Exit;
 If Not FExist(PAth.ToSklad+CurrentPAssword+'.txt') Then
  Begin
  End;
}
End;



Function SelectDSertif(Var VidZaprosa,VidProsmotra,Diapason:Word):Boolean;
Label 1;
var
  DataRec : record
         VidProsmotra : Word;
         Diapason : String[3];
  end;

  Dlg : PDialog;
  R : TRect;
  Control : PView;
  Res : Word;
  S : String[3];
begin
Res:=14;
DataRec.Diapason:='7';
DataRec.VidProsmotra:=1;

1:
R.Assign(13, 9, 67, 13);
Case VidZaprosa Of
0:New(Dlg, Init(R, 'Анализ сертификатов'));
1:New(Dlg, Init(R, 'Анализ сроков реализации'));
2:New(Dlg, Init(R, 'Анализ комментариев клиентов'));
Else New(Dlg, Init(R, 'Анализ сертификатов'));
End;

Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E002;


R.Assign(1, 1, 30, 3);
Case VidZaprosa Of
0:
Control := New(PRadioButtons, Init(R,
  NewSItem('Вывести базу полностью',
  NewSItem('Отбор по сроку действия', Nil))));
1:
Control := New(PRadioButtons, Init(R,
  NewSItem('Вывести базу полностью',
  NewSItem('Отбор по сроку реализац', Nil))));
2:
Control := New(PRadioButtons, Init(R,
  NewSItem('Вывести базу полностью',
  NewSItem('Отбор по сроку действия', Nil))));
Else Control := New(PRadioButtons, Init(R,
  NewSItem('Вывести базу полностью',
  NewSItem('Отбор по сроку действия', Nil))));

End;
Dlg^.Insert(Control);

R.Assign(31, 1, 53, 3);
Case VidZaprosa Of
0:
Control := New(PColoredText, Init(R, SrokDeistvIstekaet^, $3E));
1:
Control := New(PColoredText, Init(R, SrokRealizIstekaet^, $3E));
2:
Control := New(PColoredText, Init(R, SrokDeistvIstekaet^, $3E));
Else
Control := New(PColoredText, Init(R, SrokDeistvIstekaet^, $3E));

End;

Dlg^.Insert(Control);


R.Assign(47, 2, 52, 3);
Control := New(PInputLine, Init(R, 3));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  Dlg^.SetDAta(DataRec);
Dlg^.SelectNext(False);
Res := Desktop^.ExecView(dlg);
If Res<>cmCancel Then
 Begin
  Dlg^.GetData(DataRec);

  If DataRec.VidProsmotra=1 Then
  Begin
   Res:=StrToInt(DataRec.Diapason);
   If Res=0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(^M+#3'Недопустимый диапазон поиска!',Nil,mfError+mfCancelButton);
    Goto 1;
   End;
  End;
  VidProsmotra:=DataRec.VidProsmotra;
  Diapason:=Res;
  SelectDSertif:=True;
 End
 Else
  SelectDSertif:=False;

Dispose(Control,Done);
Dispose(Dlg,Done);
End;


Procedure GlobalNazenkaOutZakupka2(Var P:PBox);
Var Tec : Record
  st : String[CZena];
 End;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  Zakupka,ws1,ws,Zena,Skidka : AllStr;
  s : String;
  WspomList1:PBox;
  ls : Word;


begin
If (P^.List^.Count>0) Then
Begin
R.Assign(29, 9, 51, 12);
New(Dlg, Init(R, 'Наценка'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E003;

R.Assign(12, 1, 19, 2);
Control := New(PRealInputLine, Init(R, CZena));
Dlg^.Insert(Control);
  {PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));}

  R.Assign(1, 1, 12, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Наценка,р:', Control)));

Tec.St[0]:=#0;
Dlg^.SetData(Tec);

Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(Tec);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  DelSpace(Tec.St);

  If (StrToReal(Tec.St)>0.10) And Not(StrToInt(CurrentPassword)=0) Then
   Begin
    MessageBox(NoRightAccess^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

  {вставить код изменения скидки}

If P^.List^.Count>0 Then
Begin

  R.Assign(0,0,0,0);
  WspomlIST1 := New(PBox, Init(R, 1, Nil));
  WspomList1^.NewList(New(PTextCollection, Init(0,1)));

For ls:=0 To P^.List^.Count-1 Do
 Begin
{артикул}
 s:=P^.GetText(ls,P^.List^.Count);
 {вторая закупка}
 Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);
 Zakupka:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+
       CInputIZena+1+CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1,CZenaZ);

 {величина ручной скидки}
 MyStr(StrToReal(Zena)-(StrToReal(Zakupka)+StrToReal(Tec.st)),CZena,CMantissa,ws);

{Удаляем старую ручную скидку}
 System.Delete(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);
{Добавляем новую ручную скидку}
 System.Insert(ws,S,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1);
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



Function SelAssortiment(Var ES:LongInt):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  A : PMyListBox;
  P : PBoxData;
  j,c : LongInt;
  ss,st : AllStr;
  MMM : Maska30;

begin
SelAssortiment:=FAlse;

c:=AllSklads;
j:=c;
WordToBit30(j,MMM);

1:
DInfoMsg('Минуточку...',False);
R.Assign(8, 7, 72, 17);
New(Dlg, Init(R, 'Ассортимент каких складов включить в отчет'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(1, 1, 63, 9);
A := New(PMyListBox, Init(R, 'X', 2, Nil,False{ReadOnly=False}));
A^.NewList(New(PCollection, Init(0,1)));

For c:=1 To Max30 Do
 Begin
  St:=IntToStr(C,CClientKod);
  RFormatZerro(st,CClientKod);
  ss:=GetMakeField(FClient,st,1);
  Format(ss,CClient);
  A^.List^.Insert(New(PStringO,Init(ss+'│'+st)));
  A^.SetRange(A^.List^.Count);
 End;

Dlg^.Insert(A);
Dlg^.SetData(j);

Dlg^.SelectNext(False);
NoInfoMsg;
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
Begin
Dlg^.GetDAta(j);

 If j=0 Then
  Begin
   Dispose(PMyListBox(A)^.List,Done);
   Dispose(A,Done);
   Dispose(Dlg,Done);
   MessageBox(^M+#3'Не выбрано ни одного объекта',Nil,mfError+mfCancelButton);
   Goto 1;
  End;

 Es:=J;
 SelAssortiment:=True;


End;
Dispose(PMyListBox(A)^.List,Done);
Dispose(A,Done);
Dispose(Dlg,Done);


{
R.Assign(10, 10, 72, 14);
New(Dlg, Init(R, 'Ассортимент каких складов включить в отчет'));
Dlg^.HelpCtx:=$E002;

R.Assign(1, 1, 61, 3);
Control := New(PCheckboxes, Init(R,
  NewSItem('1',
  NewSItem('2',
  NewSItem('3',
  NewSItem('4',
  NewSItem('5',
  NewSItem('6',
  NewSItem('7',
  NewSItem('8',
  NewSItem('9',
  NewSItem('10',
  NewSItem('11',
  NewSItem('12',
  NewSItem('13',
  NewSItem('14',
  NewSItem('15', Nil)))))))))))))))));
Dlg^.Insert(Control);

Dlg^.SetData(ES);
Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCAncel Then
 Begin
  Dlg^.GetData(ES);
  SelAssortiment:=True;
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
}
end;



Function Menedger(Var K:TDateString):Word;
Label Start;
var
  Dlg : PDialog;
  R : TRect;
  ControlSel,ControlK : PView;
  c : Word;

begin
Start:
k[0]:=#0;
Menedger:=2;
c:=0;
R.Assign(29, 8, 51, 14);
New(Dlg, Init(R, '+/-'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

R.Assign(5, 1, 18, 3);
ControlSel := New(PRadioButtons, Init(R,
  NewSItem('~С~кидка',
  NewSItem('~Н~аценка',
  Nil))));
Dlg^.Insert(ControlSel);
ControlSel^.SetData(c);

R.Assign(14, 4, 20, 5);
ControlK := New(PRealInputLine, Init(R, 5));
Dlg^.Insert(ControlK);
  {PInputLine(ControlK)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));}

  R.Assign(1, 4, 14, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Коэ~ф~фициент:', ControlK)));

Dlg^.SelectNext(False);

k:='1';
ControlK^.SetData(k);


c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  ControlSel^.GetData(c);
  ControlK^.GetData(k);
  Dispose(ControlSel,Done);
  Dispose(ControlK,Done);
  Dispose(DLG,Done);
  If (c=0) And (Not(StrToreal(K)>=1.00) Or Not(StrToReal(K)<=1.99)) Then
   Begin
    MessageBox(SkidkaError^,Nil,mfError+mfCancelButton);
    Goto Start;
   End;
  If (c=1) And (Not(StrToreal(K)>=0.00) Or Not(StrToReal(K)<=99.99)) Then
   Begin
    MessageBox(NazenkaError^,Nil,mfError+mfCancelButton);
    Goto Start;
   End;
  Menedger:=c;
 End
 Else
 Begin
  Menedger:=2;
  k:='0.00';
  Dispose(ControlSel,Done);
  Dispose(ControlK,Done);
  Dispose(DLG,Done);
 End;
end;


(*
Procedure CreatBinAndRun(VAr Event:TEvent);
Var f : File;
    c : Word;
    Dopolnenie : TMyString;
    s : String;
    BatTxt : Text;
Begin
If Not FExists(Path^.Dat.ToProgram+'sklad.bin') Then
 Begin
  MessageBox(NoExistsModul^+ClicProgrammer^,Nil,mfError+mfCancelButton);
  Exit;
 End;

If FExists(Path^.Dat.ToProgram+'sklstat.exe') Then
 Begin
  Assign(f,Path^.Dat.ToProgram+'sklstat.exe');
  c:=IoResult;
  Erase(f);
  c:=IoResult;
 End;

  Dopolnenie[0]:=#0;
  If FindParam('/WIN2K') Then Dopolnenie:='/WIN2K'
  Else Dopolnenie[0]:=#0;

  If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then Dopolnenie:=Dopolnenie+' '+'/READONLY';

  s:=Path^.Dat.ToProgram+'sklstat.exe'+' '+Dopolnenie+' '+KeyStr+CurrentPassword+
  ' '+NullStr^;

  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SwapVectors;
  Exec(GetEnv('Comspec'),' /c '+'copy '+Path^.Dat.ToProgram+'sklad.bin'+' '+
                            Path^.Dat.ToProgram+'sklstat.exe'+' '+NullStr^);

  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;

  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SwapVectors;

  Exec(GetEnv('Comspec'),' /c '+Path^.Dat.ToProgram+'sklstat.exe'+' '+Dopolnenie+' '+
  '/CPATH='+PathToConfig^+' '+KeyStr+CurrentPassword+' '+NullStr^);

  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;


If FExists(Path^.Dat.ToProgram+'sklstat.exe') Then
 Begin
  Assign(f,Path^.Dat.ToProgram+'sklstat.exe');
  c:=IoResult;
  Erase(f);
  c:=IoResult;
 End;

  Event.What:=evCommand;
  Event.Command:=cmNone;
  Application^.PutEvent(Event);

  Application^.Redraw;
End;
*)


Procedure CreatBinAndRun(VAr Event:TEvent);
Var f : File;
    c : Word;
    Dopolnenie : TMyString;
    s : String;
    BatTxt : Text;
Begin
If Not FExists(Path^.Dat.ToProgram+'sklad.bin') Then
 Begin
  MessageBox(NoExistsModul^+ClicProgrammer^,Nil,mfError+mfCancelButton);
  Exit;
 End;

  Dopolnenie[0]:=#0;
  If FindParam('/WIN2K') Then Dopolnenie:='/WIN2K'
  else
  If FindParam('/W2K3') Then Dopolnenie:='/W2K3'
  Else Dopolnenie[0]:=#0;

  Dopolnenie:=Dopolnenie+' OUTDATE='+FDate;

  If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then Dopolnenie:=Dopolnenie+' '+'/READONLY';

  CursorLines:=1543;
  Application^.HideCursor;
  DoneSysError;
  DoneEvents;
  DoneVideo;
  DoneDosMem;
  SwapVectors;
(*
  Exec(GetEnvMy,' /C Start D'+Path^.Dat.ToProgram+'sklad.bin'+' '+Dopolnenie+' '+
  '/CPATH='+PathToConfig^+' '+KeyStr+CurrentPassword{+' '+NullStr^});
*)

  If FindParam('/W2K3') Then
  Exec(GetEnvMy,'/c Start "Статистика" '+Path^.Dat.ToProgram+'sklad.bin '+
  '/CPATH='+PathToConfig^+' '+KeyStr+CurrentPassword{+' '+NullStr^})
Else
  Exec(Path^.Dat.ToProgram+'sklad.bin',' '+Dopolnenie+' '+
  '/CPATH='+PathToConfig^+' '+KeyStr+CurrentPassword+' '+NullStr^);

{
  Writeln(GetEnvMy+' /C Start "Статистика" '+Path^.Dat.ToProgram+'sklad.bin '+Dopolnenie+' '+
  '/CPATH='+PathToConfig^+' '++KeyStr+CurrentPassword+' '+NullStr^);
}
  SwapVectors;
  InitDosMem;
  InitVideo;
  InitEvents;
  InitSysError;
  CursorLines:=1543;

  Event.What:=evCommand;
  Event.Command:=cmNone;
  Application^.PutEvent(Event);

  Application^.Redraw;

End;


Procedure CreatBinAndRunTools(VAr Event:TEvent);
Var f : File;
    c : Word;
    Dopolnenie : TMyString;
    s : String;
    BatTxt : Text;
Begin
If Not FExists(Path^.Dat.ToProgram+'tools.bin') Then
 Begin
  MessageBox(NoExistsModul^+ClicProgrammer^,Nil,mfError+mfCancelButton);
  Exit;
 End;

  Dopolnenie[0]:=#0;
  If FindParam('/WIN2K') Then Dopolnenie:='/WIN2K'
  else
  If FindParam('/W2K3') Then Dopolnenie:='/W2K3'
  Else Dopolnenie[0]:=#0;

  Dopolnenie:=Dopolnenie+' OUTDATE='+FDate;

  If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then Dopolnenie:=Dopolnenie+' '+'/READONLY';

  CursorLines:=1543;
  Application^.HideCursor;
  DoneSysError;
  DoneEvents;
  DoneVideo;
  DoneDosMem;
  SwapVectors;

  If FindParam('/W2K3') Then
  Exec(GetEnvMy,'/c Start "Конфигуратор" '+Path^.Dat.ToProgram+'tools.bin '+
  '/CPATH='+PathToConfig^+' '+KeyStr+CurrentPassword{+' '+NullStr^})
Else
  Exec(Path^.Dat.ToProgram+'tools.bin',' '+Dopolnenie+' '+
  '/CPATH='+PathToConfig^+' '+KeyStr+CurrentPassword+' '+NullStr^);

  SwapVectors;
  InitDosMem;
  InitVideo;
  InitEvents;
  InitSysError;
  CursorLines:=1543;

  Event.What:=evCommand;
  Event.Command:=cmNone;
  Application^.PutEvent(Event);

  Application^.Redraw;
End;




Function PeriodFromLock(Regim:Boolean):Boolean;
Label 1;
var
{ Dlg : PDialog;}
  R : TRect;
  Control{,ControlStart,ControlStop} : PView;
  C : Word;

  ControlStart,ControlStop : PbxEditLine;{PView}
  Dlg  : PbxEntryDialog;
  Dt1,Dt2: TbxDateRec;

  Start,Stop,l : LongInt;
  s1,s2,StartLockDAte,StopLockDate : TDateString;
  Full : Boolean;

begin
PeriodFromLock:=False;
s1:='01-01-98';
s2:=FDate;

1:
R.Assign(23, 9, 57, 14);
If Regim Then
New(Dlg, Init(R, 'Укажите период блокировки'))
Else
New(Dlg, Init(R, 'Укажите период деблокировки'));

Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E011;
Dlg^.Palette := dpCyanDialog;

R.Assign(6, 2, 16, 3);
{ControlStart := New(PInputLine, Init(R, 8));}
      ControlStart:= New(PbxDateEdit, Init(R, DateMask));
      ControlStart^.SetEditFlag(dfRequired, True);
      Dlg^.Insert(ControlStart);
  (*PInputLine(ControlStart)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));*)

      ExtractDateFromString(Dt1,DateMask,S1);

  R.Assign(3, 2, 6, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~с~:', ControlStart)));


ControlStart^.SetData(dt1{s1});


R.Assign(20, 2, 30, 3);
{ControlStop := New(PInputLine, Init(R, 8));}
      ControlStop:= New(PbxDateEdit, Init(R, DateMask));
      ControlStop^.SetEditFlag(dfRequired, True);
Dlg^.Insert(ControlStop);
  (*PInputLine(ControlStop)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));*)

      ExtractDateFromString(Dt2,DateMask,S2);

ControlStop^.SetData(dt2{s2});

  R.Assign(16, 2, 20, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~п~о:', ControlStop)));

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
   {
   ControlStart^.GetData(s1);
   ControlStop^.GetData(s2);
   }
  ControlStart^.GetData(Dt1);
  ControlStop^.GetData(Dt2);

  S1:=DateToDateStr(DT1,DateMask);
  S2:=DateToDateStr(DT2,DateMask);

  DelSpace(s1);
  DelSpace(s2);

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

   StartLockDate:=s1;
   StopLockDate:=s2;
   PeriodFromLock:=True;

   {если даты перепутаны переставляем их}
   If DateStringToDate(DateMask,StopLockDate)<DateStringToDate(DateMask,StartLockDate) Then
    Begin
        s1:=StopLockDate;
        StopLockDate:=StartLockDate;
        StartLockDate:=s1;
    End;

   If DateStringToDate(DAteMask,'01-01-98')>DateStringToDate(DAteMask,StartLockDate) Then
   StartLockDate :='01-01-98';
   {
   If DateStringToDate(DAteMask,FDAte)<DateStringToDate(DAteMask,StopLockDate) Then
   StopLockDate :=FDate;
   }
   Start:=DateStringToDate(DAteMask,StartLockDate);
   Stop:=DateStringToDate(DAteMask,StopLockDate);

   Full:=False;
   If MessageBox(^M+#3'Обрабатывать воскресенье?',Nil,mfOkCancel)=cmOk Then Full:=True;



If Regim Then
   DInfoMsg('Блокирую период с '+StartLockDate+' по '+StopLockDAte+'...',False)
   Else
   DInfoMsg('Деблокирую период с '+StartLockDate+' по '+StopLockDAte+'...',False);

   For l:=Start To Stop Do
    Begin
    If (DayOfWeek(L)<>Sunday) Or ((Full)And(DayOfWeek(L)=Sunday)) Then
     Begin
      s1:=DateToDAteString(DateMask,l);
      If Regim Then  BlockDate1(S1)
      Else DeBlockDate1(S1);
     End;
      c:=IOResult;
    End;
   NoInfoMsg;

 End
 Else
  Begin
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);
  End;
end;


Const

 koi82win: array[0..127] of byte = (
 $20, $20, $20, $20, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $95, $20, $20,
 $20, $20, $a0, $20, $b0, $20, $b7, $20,
 $20, $20, $20, $b8, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $20, $20, $20,
 $20, $20, $20, $a8, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $20, $20, $a9,
 $fe, $e0, $e1, $f6, $e4, $e5, $f4, $e3,
 $f5, $e8, $e9, $ea, $eb, $ec, $ed, $ee,
 $ef, $ff, $f0, $f1, $f2, $f3, $e6, $e2,
 $fc, $fb, $e7, $f8, $fd, $f9, $f7, $fa,
 $de, $c0, $c1, $d6, $c4, $c5, $d4, $c3,
 $d5, $c8, $c9, $ca, $cb, $cc, $cd, $ce,
 $cf, $df, $d0, $d1, $d2, $d3, $c6, $c2,
 $dc, $db, $c7, $d8, $dd, $d9, $d7, $da
);


alt2koi8: array[0..127] of byte = (
 $e1, $e2, $f7, $e7, $e4, $e5, $f6, $fa,
 $e9, $ea, $eb, $ec, $ed, $ee, $ef, $f0,
 $f2, $f3, $f4, $f5, $e6, $e8, $e3, $fe,
 $fb, $fd, $ff, $f9, $f8, $fc, $e0, $f1,
 $c1, $c2, $d7, $c7, $c4, $c5, $d6, $da,
 $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0,
 $90, $91, $92, $81, $87, $b2, $b4, $a7,
 $a6, $b5, $a1, $a8, $ae, $ad, $ac, $83,
 $84, $89, $88, $86, $80, $8a, $af, $b0,
 $ab, $a5, $bb, $b8, $b1, $a0, $be, $b9,
 $ba, $b6, $b7, $aa, $a9, $a2, $a4, $bd,
 $bc, $85, $82, $8d, $8c, $8e, $8f, $8b,
 $d2, $d3, $d4, $d5, $c6, $c8, $c3, $de,
 $db, $dd, $df, $d9, $d8, $dc, $c0, $d1,
 $b3, $a3, $99, $98, $93, $9b, $9f, $97,
 $9c, $95, $9e, $96, $bf, $9d, $94, $9a
);


function DosToWin(s:string):string;

Const Digits=['0','1','2','3','4','5','6','7','8','9'];
var i: byte;
begin
  for i:=1 to word(s[0]) do
    begin
       If s[i]=SeparatorChar Then s[i]:=';';

       IF Ord(s[i]) > 127 then
       begin
         s[i] := Chr(alt2Koi8[Ord(s[i])-128]);
         s[i] := Chr(Koi82Win[Ord(s[i])-128]);
       end;

       If i>1 Then
        Begin
         If s[i]='.' Then
          If s[i-1] in Digits Then s[i]:=',';
        End;

    end;
  DosToWin:=s;
end;




Function SelIndex (VAr Res : Word):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;

begin
c:=1;
SelIndex:=False;
R.Assign(26, 9, 54, 13);
New(Dlg, Init(R, ''));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;

R.Assign(1, 1, 27, 3);
Control := New(PRadioButtons, Init(R,
  NewSItem('Создать индекс вновь',
  NewSItem('Редактировать индекс', Nil))));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetDAta(c);
c:=Desktop^.ExecView(Dlg);
If c<>cmCAncel Then
 Begin
  Dlg^.GetDAta(c);
  Res:=c;
  SelIndex:=True;
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;



Function Kurs(Var K:TDateString):Word;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  ControlWal,ControlKurs : PView;
  Wal,c : Word;

begin
Kurs:=2;
k[0]:=#0;
wal:=0;

1:
R.Assign(28, 9, 52, 14);
New(Dlg, Init(R, ''));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

R.Assign(1, 2, 12, 4);
ControlWal := New(PRadioButtons, Init(R,
  NewSItem('~Р~убли',
  NewSItem('USD', Nil))));
Dlg^.Insert(ControlWal);

ControlWal^.SetData(Wal);


  R.Assign(1, 1, 9, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Валюта:', ControlWal)));

R.Assign(13, 3, 23, 4);
ControlKurs := New(PRealInputLine, Init(R, CZena));
Dlg^.Insert(ControlKurs);
{ PInputLine(ControlKurs)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));}

  R.Assign(12, 2, 22, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~К~урс USD:', ControlKurs)));

ControlKurs^.SetData(k);

Dlg^.SelectNext(False);

c:=DeskTop^.ExecView(Dlg);
If c<>cmCancel Then
  Begin
  ControlWal^.GetData(Wal);
  ControlKurs^.GetData(K);
  Dispose(ControlWal,Done);
  Dispose(ControlKurs,Done);
  Dispose(Dlg,Done);

  If Wal=1 Then
   Begin
    If (StrToReal(k)<0.01) Then
     Begin
      MessageBox(^m+#3'Ошибка при вводе курса USD!',Nil,mfError+mfCancelButton);
      Goto 1;
     End;
     Kurs:=1;
   End
   Else Kurs:=0;

  End
  Else
  Begin
  Dispose(ControlWal,Done);
  Dispose(ControlKurs,Done);
  Dispose(Dlg,Done);
  End;
end;



Procedure DelFlag;
Var C : Word;
Begin
{Assign(SignalFile,Path^.Dat.ToFlagDir+Path^.Dat.FileFlag);}
c:=IOResult;
Close(SignalFile);
c:=IOResult;
Erase(SignalFile);
c:=IOResult;
End;

{$IFDEF RemoteClient}
Function TestFlag:Boolean;{False- файла нет или создан успешно
                           True - файл либо есть, либо возникла ошибка при его создании}
Var c : Byte;
Begin
TestFlag:=False;
Assign(SignalFile,Path^.Dat.ToProgram+Path^.Dat.FileFlag);

If Not FindParam('/ONLYONECOPY') And Not (ONLYONECOPY=1) Then Exit;

if FExists(Path^.Dat.ToFlagDir+Path^.Dat.FileFlag) Then
 Begin
  c:=IOResult;
  Erase(SignalFile);
  c:=IOResult;
  If c<>0 Then
   Begin
    TestFlag:=True;
    Exit;
   End;
 End;

c:=IOResult;
Rewrite(SignalFile);
c:=IOResult;
If c<>0 Then
Begin
c:=IOResult;
TestFlag:=True;
End
Else
 Begin
 End;
c:=IOResult;
End;

{$Else}

Function TestFlag:Boolean;{False- файла нет или создан успешно
                           True - файл либо есть, либо возникла ошибка при его создании}
Var c : Byte;
Begin
TestFlag:=False;
Assign(SignalFile,Path^.Dat.ToFlagDir+Path^.Dat.FileFlag);

If Not FindParam('/ONLYONECOPY') And Not (ONLYONECOPY=1) Then Exit;

if FExists(Path^.Dat.ToFlagDir+Path^.Dat.FileFlag) Then
 Begin
  c:=IOResult;
  Erase(SignalFile);
  c:=IOResult;
  If c<>0 Then
   Begin
    TestFlag:=True;
    Exit;
   End;
 End;

c:=IOResult;
Rewrite(SignalFile);
c:=IOResult;
If c<>0 Then
Begin
c:=IOResult;
TestFlag:=True;
End
Else
 Begin
 End;
c:=IOResult;
End;


{$EndIf}




Function TestSrokLizensia(c:AllStr;vid:byte;Date:TDateString):Boolean;
Var f : ClientFileType;
    l : LongInt;
         Code : Integer;
    s : ClientType;
    st : ArtikulStr;
Begin
 TestSrokLizensia:=False;
 {Assign(f,Path^.Dat.ToClient+'Client.db');}
 Case Vid Of
 0:Assign(f,Path^.Dat.ToClient+'Client.db');
 2:Assign(f,Path^.Dat.ToClient+'Barter.db');
 Else Exit;
 End;

 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(#3'Ошибка открытия файла клиентов!',nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
     {
     Repeat
     Until NetCall.Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
     }
     ReadClient(f,s);
     {
     Repeat
      NetCall.UnLock(f,(FilePos(f)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
     }
   Close(f);
   {l:=DateStringToDate(DateMask,S.SrokLizensia);}
   DelSpace(S.SrokLizensia);
   If (DateStringToDate(DateMAsk,Date)<=DateStringToDate(DateMask,S.SrokLizensia))And
      (S.SrokLizensia[0]<>#0)  Then
   TestSrokLizensia:=True;
  End;
End;


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

{$IFNDEF Tabak}
If Not (Pharm=1) Then Control^.Options := Control^.Options and not ofSelectable;
{$ENDIF}

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

For ls:=0 To P^.List^.Count-1 Do
 Begin
{артикул}
 s:=P^.GetText(ls,P^.List^.Count);
 Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);

 If Tec.Moroz=1 Then
  Begin
   {все расчеты строятся от текущей цены к оплате}
   Skidka:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);
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
 System.Delete(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);
{Добавляем новую ручную скидку}
 System.Insert(ws,S,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1);
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

For ls:=0 To P^.List^.Count-1 Do
 Begin
{артикул}
 s:=P^.GetText(ls,P^.List^.Count);
 Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);

 If Moroz=1 Then
  Begin
   Skidka:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);
   MyStr(StrToReal(Zena)-StrToReal(Skidka),CZena,CMantissa,Zena);
  End;

 MyStr(StrToReal(Zena)-(StrToReal(Zena)/(StrToReal(st))),CZena,CMantissa,ws);
{Удаляем старую ручную скидку}

 If Moroz=1 Then
  Begin
   MyStr(StrToReal(ws)+StrToReal(Skidka),CZena,CMantissa,ws);
  End;


 System.Delete(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);
{Добавляем новую ручную скидку}
 System.Insert(ws,S,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1);
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



Procedure GlobalSkidkaSpec (Var P:PBox);
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  st : ArtikulStr;
  sw : String[CLitrMantissa];
  SZena,ws,Zena : TDateString;
  s : String;
  WspomList1:PBox;
  ls : Word;
  Event : TEvent;
begin
If P^.List^.Count>0 Then
Begin
  R.Assign(0,0,0,0);
  WspomlIST1 := New(PBox, Init(R, 1, Nil));
  WspomList1^.NewList(New(PTextCollection, Init(0,1)));

For ls:=0 To P^.List^.Count-1 Do
 Begin
{артикул}
 s:=P^.GetText(ls,P^.List^.Count);
 SZena:=BAkGetField(FSpecZena,Copy(s,1,CArtikul),0);
 Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);
 MyStr(StrToReal(Zena)-StrToReal(SZena),CZena,CMantissa,ws);
{Удаляем старую ручную скидку}
 System.Delete(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);
{Добавляем новую ручную скидку}
 System.Insert(ws,S,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1);
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
end;





Procedure CalcComputer(VAr S: String;Res:Boolean);
Var k,a,b,c,m,e : Word;
    r : LongInt;
Begin
 s[0]:=#0;
{$IfNDEF DPMI}

 For k:=0 To 7 Do
  Begin
   s[k+1]:=chr(Mem[$F000:$FFF5+k]);
  End;
 s[0]:=Chr(k+1);
 r:=DateStringToDAte('mm/dd/yy',s);{Дата прошивки ПЗУ}
 s:=IntToStr(r,CIZena);

 Writeln(s);
r:=MemW[0:$413];
r:=r*1024;           {общий объем памяти}


If MEM [$F000:$FFFE]= $FC Then
 Begin {AT}
  Res:=True;
  Port[$70]:=$15;
  m:=Port[$71];
  Port[$70]:=$16;
  m:=m+Port[$71] shl 8; {основная память}
  Port[$70]:=$17;
  e:=Port[$71];
  Port[$70]:=$18;
  e:=e+Port[$71] shl 8; {дополнительная память}

  a:=0;
  for b:=0 to 3 Do
  If MemW[0:$400+b shl 2] <>0 Then Inc(a); {количество последовательный портов}

  c:=0;
  for b:=0 to 3 Do
  If MemW[0:$408+b shl 2] <>0 Then Inc(c); {количество параллельных портов}

 s:=s+' '+IntToStr(r,CIZena)+' '+IntToStr(m,CIZena)+' '+IntToStr(e,CIZena)+
 ' '+IntToStr(a,CIZena)+' '+IntToStr(c,CIZena);
 {Пароль СрокЛицензии Датапрошивки}

 End
 Else {XT}
  Begin
   Res:=FAlse;
  End;

{$ENDIF}
End;




Function Install(Var Password,DAte:LongInt):Boolean;
LAbel Start;
var
  c : Word;
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  f : File;
  l : LongInt;
  s : String;
  Ran,ran1 : LongInt;
  PsevdoKod,PsevdoKod1 : AllStr;

  DataRec : record
    Password : String[8];
    DateLS   : String[8];

  end;

Begin
Install:=False;

DAtaRec.Password[0]:=#0;
DAtaRec.DateLS[0]:=#0;

Start:

Ran:=0;
While (Ran<1000) Do Ran:=Random(1500);

Ran1:=0;
While (Ran1<1) or (Ran1>1500) Do Ran1:=Random(500);

ran:=Ran*ran1;

PsevdoKod:=IntToStr(Ran * 8 div 3,10);

R.Assign(24, 8, 56, 15);
New(Dlg, Init(R, 'Инсталяция'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E002;


R.Assign(10, 6, 10+Ord(PsevdoKod[0])+2, 7);
Control := New(PColoredText, Init(R, #3+PsevdoKod, $4F));
Control^.Options := Control^.Options or ofCenterX;
Dlg^.Insert(Control);



R.Assign(20, 2, 30, 3);
Control := New(PSInputLine, Init(R, CDAte));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(1, 2, 20, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Пароль инсталяции:', Control)));

R.Assign(20, 4, 30, 5);
Control := New(PInputLine, Init(R, CDate));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DAteFiltr{'[##-##-9#]'}, True));

  R.Assign(2, 4, 20, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Срок лиц.соглаш.:', Control)));

Dlg^.SetData(DataRec);

Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);

If c<>cmCAncel Then
 Begin
  Dlg^.GetDAta(DataRec);
  Password:=StrToInt(DataRec.Password);


  If Password<>Crypto Then
   Begin

    Str(StrToInt(GetNValue(Ran * 8 div 3))*3,PsevDoKod1);
    DelSpace(PsevDoKod1);
    If PsevdoKod1<>DataRec.Password Then
    Begin
    MessageBox(^M+#3'Неправильно указан пароль инсталяции!',Nil,mfError+mfCancelButton);
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    Goto Start;
    End;
   End;



  If Not(TestDate(DataRec.DAteLS,DAte)) Then
   Begin
    MessageBox(#3'Неправильно указана дата лицензионного соглашения!',Nil,mfError+mfCancelButton);
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    Goto Start;
   End;

   Assign(f,{Path^.Dat.ToProgram+}'sklad.key');
   Rewrite(f);

   For c:=1 To 120 Do
    Begin
     l:=Random(65000);
     BlockWrite(F,l,1);
     Write(l,' ');
    End;

   L:=FileSize(F);
   Seek(F,L);

   s[0]:=#0;

   Date:=DateStringToDate(DAteMAsk,DataRec.DAteLS);

   Password:=Crypto;

   s:=IntToStr(Password,CIZena)+' '+{s+' '+}IntToStr(Date,CIZena);

   BlockWrite(F,s,Succ(Length(s)));{контрольная сумма}
   Seek(F,L);
   Truncate(F);
   Close(F);

   Delay(1000);
 End;
Application^.Redraw;
Dispose(Control,Done);
Dispose(Dlg,Done);
End;





Function TestPC:Byte;
Label Test;
VAr PZU : AllStr;
    s,s1 : String;
    k,Max,L,Password : LongInt;
    F : File;
    Res : Boolean;
Begin
      TestPC:=0;


(*
      l:=IOResult;
      If FindPAram('/ADM') Then
       begin
        Beep;
        Install(Password,Max);
        Goto Test;
       end
       else
       begin

       Test:
        Assign(F,{Path^.Dat.ToProgram+}'sklad.key');
        l:=ioresult;
        Reset(F,1);
        If IOResult<>0 Then
            Begin
          TestPC:=1;
          NoInfoMsg;
          Exit;
         End;
        DInfoMsg('Проверяю легальность копии программы...',False);
        L:=FileSize(F);
        Seek(F,L);
        s[0]:=#255;
        Seek(F,L+256);

        BlockWrite(F,s,1);
        Seek(F,L);
        BlockRead(F,s,256);

        Seek(F,L);
        Truncate(F);
        Close(f);


        k:=1;
        If Ord(S[0])>0 Then
        For k:=Ord(S[0]) DownTo 1 Do
         If s[k]=' ' Then Break;

        PZU := Copy (s,k+1,Ord(s[0])-(k));

        s[0]:=Chr(k-1);



        If (s)<>(IntToStr(Crypto,CIZena){+s1}) Then
            Begin
          TestPC:=1;
          NoInfoMsg;
          Exit;
            End;

        If Today > StrToInt(PZU) Then
            Begin
          TestPC:=2;
          NoInfoMsg;
          Exit;
            End;

        If Today = StrToInt(PZU) Then
            Begin
          TestPC:=3;
          NoInfoMsg;
          Exit;
            End;
          NoInfoMsg;
       end;
*)

 end;





Function GetLizensiaFromProgramm:AllStr;
Label Test;
VAr PZU : AllStr;
    s,s1 : String;
    k,Max,L,Password : LongInt;
    F : File;
    Res : Boolean;
Begin
        Assign(F,{Path^.Dat.ToProgram+}'sklad.key');
        l:=ioresult;
        Reset(F,1);
        l:=ioresult;
        If L<>0 Then
            Begin
             GetLizensiaFromProgramm:='Ошибка';
          Exit;
         End;
        L:=FileSize(F);
        Seek(F,L);
        s[0]:=#255;
        Seek(F,L+256);
        BlockWrite(F,s,1);
        Seek(F,L);
        BlockRead(F,s,256);
        Seek(F,L);
        Truncate(F);
        Close(f);

        k:=1;
        If Ord(S[0])>0 Then
        For k:=Ord(S[0]) DownTo 1 Do
         If s[k]=' ' Then Break;

        PZU := Copy (s,k+1,Ord(s[0])-(k));
        s[0]:=Chr(k-1);
        GetLizensiaFromProgramm:=DateToDAteString(DAteMAsk,StrToInt(PZU));
end;





Function TestMarketFile(TekDate:TDateString):Boolean;
VAr SuperMArketFile : MarketFileType;
    c : Word;
Begin
  TestMarketFile:=True;

  Assign(SuperMarketFile,Path^.Dat.ToMarket+TekDate+'.mrk');
  Reset(SuperMarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    If MessageBox(#3'Файл продаж за '+TekDate+' не найден'^M+
    #3'Если Вы раннее что-то продавали'^M+
    #3'немедленно позовите программиста'^M+
    #3'Создавать файл продажи?'+' Код:'+IntToStr(c,3),Nil, mfWarning+mfOkCancel)=cmOk Then
     Begin
      If Not(CreatToDayF(DocMarket,TekDate)) Then
          Begin
        TestMarketFile:=False;
           Exit;
       End;
      Reset(SuperMarketFile);
      c:=IOResult;
     End
    Else Begin
          TestMarketFile:=False;
          Exit;
         End;
   End;
   System.Close(SuperMarketFile);
End;






{$IFDEF DPMI}
Procedure CreatSpecialFile(Doc:Word;Date:TDateString);
Var F : file;
    s : PathStr;
    i : byte;
Begin
 Case Doc Of
DocProtocol:s:=Path^.Dat.ToProtocol+Date+'.pr';

DocProtocolReturn:s:=Path^.Dat.ToProtocol+Date+'.vpr';

DocPrihod:s:=Path^.Dat.ToPrihod+Date+'.prh';

DocPereozen:s:=Path^.Dat.ToCorrect+Date+'.prz';

DocReturn:s:=Path^.Dat.ToReturn+Date+'.vzw';

DocRewisia:s:=Path^.Dat.ToRewisia+Date+'.rwz';

DocMArket:
 Begin
 s:=Path^.Dat.ToMarket+Date+'.cor';
 Assign(f,s);
 i:=IOResult;
 Reset(f);
 i:=IOResult;
 If i<>0 Then
   Begin
    Rewrite(f);
    i:=IOResult;
    If i<>0 Then
     Begin
      MessageBox(#3'Ошибка создания '+s+'!'+
      ^M+#3+ClicProgrammer^+' Существует опасность потери данных!',Nil,mfFatalError+mfCancelButton);
      Exit;
     End
     Else
      MessageBox(^M+#3'Файл '+s+' успешно создан!',Nil,mfInformation+mfCancelButton);
   End
    Else
      MessageBox(^M+#3'Файл '+s+' уже существует!',Nil,mfInformation+mfCancelButton);
  Close(f);
  i:=IOResult;

 s:=Path^.Dat.ToMarketIndex+Date+'.mrx';
 Assign(f,s);
 i:=IOResult;
 Reset(f);
 i:=IOResult;
 If i<>0 Then
   Begin
    Rewrite(f);
    i:=IOResult;
    If i<>0 Then
     Begin
      MessageBox(#3'Ошибка создания '+s+'!'+
      ^M+#3+ClicProgrammer^+' Существует опасность потери данных!',Nil,mfFatalError+mfCancelButton);
      Exit;
     End
     Else
      MessageBox(^M+#3'Файл '+s+' успешно создан!',Nil,mfInformation+mfCancelButton);
   End
    Else
      MessageBox(^M+#3'Файл '+s+' уже существует!',Nil,mfInformation+mfCancelButton);
  Close(f);
  i:=IOResult;
   s:=Path^.Dat.ToMarket+Date+'.mrk';
  End;

DocOplata:s:=Path^.Dat.ToOplata+Date+'.opl';

DocBarterOplata:s:=Path^.Dat.ToBarter+Date+'.bpl';

DocTransport:s:=Path^.Dat.ToTransport+Date+'.trn';

DocOplataOtkat:s:=Path^.Dat.ToOplata+Date+'.otp';
 Else;
 End;

 Assign(f,s);
 i:=IOResult;
 Reset(f);
 i:=IOResult;
 If i<>0 Then
   Begin
    Rewrite(f);
    i:=IOResult;
    If i<>0 Then
     Begin
      MessageBox(#3'Ошибка создания '+s+'!'+
      ^M+#3+ClicProgrammer^+' Существует опасность потери данных!',Nil,mfFatalError+mfCancelButton);
      Exit;
     End
     Else
      MessageBox(^M+#3'Файл '+s+' успешно создан!',Nil,mfInformation+mfCancelButton);
   End
    Else
      MessageBox(^M+#3'Файл '+s+' уже существует!',Nil,mfInformation+mfCancelButton);
  Close(f);
  i:=IOResult;
End;

{$ELSE}

Procedure CreatSpecialFile(Doc:Word;Date:TDateString);
Begin
End;

{$ENDIF}


Function SelectOperation(Var l : Word):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelectOperation:=False;
l:=195{67{3};
R.Assign(15, 8, 64, 17);
New(Dlg, Init(R, 'Удаленный доступ'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 48, 8);
Control := New(PCheckboxes, Init(R,
  NewSItem('~П~ринять документы (перевозки на склад)',
  NewSItem('~О~тправить документы (перевозки со склада)',
  NewSItem('Принять обновление (update.exe)',
  NewSItem('Отправить почту (mail.*)',
  NewSItem('Отправить отчет склада (*.?0?)',
  NewSItem('Принять базу удаленных складов',
  NewSItem('Принять обновления баз контрагентов',
{  NewSItem('Принять обновления справочников',}
  Nil))))))))){)};
If Not (StrToInt(Rek^.DAt.Kod) in [2,10]) Then
 Begin
  PCluster(Control)^.SetButtonState($00000020, False);
  PCluster(Control)^.SetButtonState($00000040, False);
{ PCluster(Control)^.SetButtonState($00000080, False);}
 End;
Dlg^.Insert(Control);
Dlg^.SetData(L);
Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(l);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  SelectOperation:=True;
 End
 Else Begin
       Dispose(Control,Done);
       Dispose(Dlg,Done);
      End;
end;




Function KeySorting(Var Key,D:Word;Const Bak:Boolean):Boolean;
Var c: Word;
    Dlg : PDialog;
    R : TRect;
    ControlKey,ControlD : PView;
Begin
KeySorting:=False;
R.Assign(29, 4, 51, 18);
New(Dlg, Init(R, 'Сортировка'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(1, 2, 21, 9);

If Bak Then
ControlKey := New(PRadioButtons, Init(R,
  NewSItem('~К~лиент',
  NewSItem('~Д~ата отгрузки',
  NewSItem('Дата оплаты',
  NewSItem('~С~кидка',
  NewSItem('С~у~мма к оплате',
  NewSItem('~В~ид документа',
  NewSItem('Опоз~д~ание', Nil)))))))))
Else
ControlKey := New(PRadioButtons, Init(R,
  NewSItem('~К~лиент',
  NewSItem('~Д~ата отгрузки',
  NewSItem('~С~умма к оплате',
  NewSItem('Су~м~ма по ЗЦ',
  NewSItem('~Д~оходность',
  NewSItem('резервная',
  NewSItem('Аге~н~т',
  Nil)))))))));



ControlKey^.SetData(Key);
Dlg^.Insert(ControlKey);

  R.Assign(1, 1, 18, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Ключ сортировки:', ControlKey)));

R.Assign(1, 11, 21, 13);
ControlD := New(PRadioButtons, Init(R,
  NewSItem('По во~з~растанию',
  NewSItem('По убыван~и~ю', Nil))));
ControlD^.SetData(D);
Dlg^.Insert(ControlD);

  R.Assign(1, 10, 14, 11);
  Dlg^.Insert(New(PLabel, Init(R, 'Направление:', ControlD)));

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  ControlKey^.GetData(Key);
  ControlD^.GetData(D);
  KeySorting:=True;
 End;
Dispose(ControlKey,Done);
Dispose(ControlD,Done);
Dispose(Dlg,Done);
End;


Function Test3000(Cod:ArtikulStr;Summa:AllStr):Boolean;
Var    s : TEnjoyStr;
Begin
 Test3000:=True;
 s:=GetClientField(FClient,Cod,0);
 If not(Pos(' ЧП',s)>0) And (StrToReal(Summa)>PrihodMax) Then
 Test3000:=False;
End;


Function SelectOtd(Var l : Word):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelectOtd:=False;
R.Assign(27, 8, 52, 18);
New(Dlg, Init(R, 'Отделения'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 24, 9);
Control := New(PCheckboxes, Init(R,
  NewSItem('~1~ '+Rek^.Dat.Otdel[1],
  NewSItem('~2~ '+Rek^.Dat.Otdel[2],
  NewSItem('~3~ '+Rek^.Dat.Otdel[3],
  NewSItem('~4~ '+Rek^.Dat.Otdel[4],
  NewSItem('~5~ '+Rek^.Dat.Otdel[5],
  NewSItem('~6~ '+Rek^.Dat.Otdel[6],
  NewSItem('~7~ '+Rek^.Dat.Otdel[7],
  NewSItem('~8~ '+Rek^.Dat.Otdel[8],
  Nil))))))))));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);
Dlg^.SetData(L);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(l);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  SelectOtd:=True;
 End
 Else Begin
       Dispose(Control,Done);
       Dispose(Dlg,Done);
      End;
end;



Function CalcMesto(E:PSuperMArketType):ArtikulStr;
VAr ws:AllStr;
    i : Word;
    Mesto:Word;
Begin
 CalcMesto[0]:=#0;
 Mesto:=0;
 For i:=1 To E^.DAt.Amount Do
  Begin
   ws:=CalcPack(E^.Dat.MarketElement[i].Bazkod,
                E^.Dat.MarketElement[i].Input.Kol);
   DelSpace(ws);
   If Pos('+',ws)>0 Then ws:=Copy(ws,1,Pos('+',ws)-1);
   Mesto:=Mesto+StrToInt(ws);
  End;
  Str(Mesto:CKol-1,ws);
  CalcMesto:=ws;
End;


Function CalcMestoDiv(E:PSuperMArketType;Division:Word):ArtikulStr;
VAr ws:AllStr;
    i : Word;
    Mesto:Word;
Begin
 CalcMestoDiv[0]:=#0;
 Mesto:=0;
 For i:=1 To E^.DAt.Amount Do
  Begin
   If E^.Dat.MarketElement[i].Input.DivisionNumber<>Division Then Continue;
   ws:=CalcPack(E^.Dat.MarketElement[i].Bazkod,
                E^.Dat.MarketElement[i].Input.Kol);
   DelSpace(ws);
   If Pos('+',ws)>0 Then ws:=Copy(ws,1,Pos('+',ws)-1);
   Mesto:=Mesto+StrToInt(ws);
  End;
  Str(Mesto:CKol-1,ws);
  CalcMestoDiv:=ws;
End;


Function CalcMestoP(E:PrihodType):ArtikulStr;
VAr ws:AllStr;
    i : Word;
    Mesto:Word;
Begin
 CalcMestoP[0]:=#0;
 Mesto:=0;
 For i:=1 To E.Amount Do
  Begin
   ws:=CalcPack(E.PrihodElement[i].Bazkod,
                E.PrihodElement[i].Input.Kol);
   DelSpace(ws);
   If Pos('+',ws)>0 Then ws:=Copy(ws,1,Pos('+',ws)-1);
   Mesto:=Mesto+StrToInt(ws);
  End;
  Str(Mesto:CKol-1,ws);
  CalcMestoP:=ws;
End;



function SelVidKAssa : Word;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelVidKAssa:=0;
c:=0;
R.Assign(29, 9, 51, 13);
New(Dlg, Init(R, ''));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(1, 1, 21, 3);
Control := New(PRadioButtons, Init(R,
  NewSItem('Основной',
  NewSItem('Дополнительный', Nil))));
Dlg^.Insert(Control);
Dlg^.SelectNext(False);
  Dlg^.SetDAta(c);

c:=Desktop^.ExecView(Dlg);
If c<>cmCAncel Then
 Begin
  Dlg^.GetDAta(c);
  SelVidKAssa:=c;
 End
 Else
  SelVidKAssa:=2;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;





function FExists(FileName: TMyString): Boolean;
var
  F: file;
  Attr: Word;
begin
  Attr:=IOResult;
  Assign(F, FileName);
  GetFAttr(F, Attr);
  Attr:=IOResult;
  FExists := DosError = 0;
  Attr:=IOResult;
  DosError:=0;
end;



function FExists1(FileName: TMyString;Var Res : LongInt): Boolean;
var
  F: file;
  Attr: Word;
begin
  Res:=0;
  Attr:=IOResult;
  Assign(F, FileName);
  GetFAttr(F, Attr);
  Attr:=IOResult;
  Res:=DosError;
  FExists1 := DosError = 0;
  Attr:=IOResult;
  DosError:=0;
end;




Function FullScreen(Const P:PBox;Const s,s1:TMyString;SDoc:ArtikulStr;SDate:TDateString;
                          t:Byte):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  ControlFull : PBox;
  St : String[80];
  i : Word;
begin
ClearFind;
FullScreen:=False;
R.Assign(0, 0, 80, 23);
New(Dlg, Init(R, 'Просмотр документа'));


R.Assign(79, 2, 80, 22);
Control := New(PScrollBar, Init(R));
Dlg^.Insert(Control);

R.Assign(1, 2, 79, 22);
ControlFull := New(PBox, Init(R, 1, PScrollbar(Control)));
ControlFull^.NewList(New(PTextCollection, Init(1,1)));
If (P^.List^.Count-1)>=0 Then
For i:=0 To P^.List^.Count-1 Do
 Begin
  st:=P^.GetText(i,P^.List^.Count);
  ControlFull^.List^.Insert(NewStr(St));
  ControlFull^.SetRange(ControlFull^.List^.Count);
 End;
If t=0 Then
ControlFull^.HelpCtx:=$E091
Else
ControlFull^.HelpCtx:=$E246;
ControlFull^.FocusItem(0);

Dlg^.Insert(ControlFull);

  R.Assign(1, 1, 79, 2);
  Dlg^.Insert(New(PLabel, Init(R, S, ControlFull)));


Str(P^.List^.Count:CMantissa,st);
R.Assign(53, 0, 71, 1);
Control := New(PColoredText, Init(R, 'Всего позиций:'+st, $4E));
Dlg^.Insert(Control);

DelZerro(Sdoc);
R.Assign(2, 0, 28, 1);
Control := New(PColoredText, Init(R, 'Документ:'+SDoc+' от '+SDate, $4E));
Dlg^.Insert(Control);

If S1[0]<>#0 Then
Begin
R.Assign(13, 22, 14+Ord(s1[0]), 23);
Control := New(PColoredText, Init(R, #3+S1, $4E));
Control^.Options := Control^.Options or ofCenterX;
Dlg^.Insert(Control);
End;

Dlg^.SelectNext(False);
i := Desktop^.ExecView(Dlg);
ClearFind;
If i=cmOk Then FullScreen:=True;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;



Procedure AddProtocol(s,s1,s2:String);
Var f : Text;
         i : Byte;
         s3 : String;
Begin
  If DisableProtocol=1 Then Exit;
  i:=IOResult;
  Assign(f,Path^.Dat.ToProtocol+FDate+'.pr');
  If LockPrWriteRead(FDate,True) Then
  Begin
  DInfoMsg('Обновляю протокол...',False);
  i:=IOResult;
  Append(f);
  i:=IOResult;
  If I<>0 Then
  Begin
    NoInfoMsg;
    MessageBox(^M+#3'Ошибка записи протокола!'+ClicProgrammer^+' Код:'+
    IntToStr(I,CKol),Nil,
    mfError+mfCancelButton);
    Exit;
  End;
  i:=IOResult;
  s3:=FDate+'('+Times+') Оператор: ('+CurrentPassword+') '+GetOperatorField(FNAme,CurrentPassword)+
  ' \\'+NetComputerName+'('+IntToStr(ListRange^.List^.Count,CKol)+','+
  IntToStr(DixyList^.List^.Count,CKol)+')Сеть:'+IntToStr(FileMode,3)+' Ver:'+CompileDate;
  s3:=Code(s3);
  Writeln(f,s3);
{
  Writeln(f,FDate+'('+Times+') Оператор: ('+CurrentPassword+') '+GetOperatorName(CurrentPassword)+
  ' Компьютер: ('+GetMachineName+')');
}
  s:=Code(s);
  Writeln(f,s);

  If s1[0]<>#0 Then
  Begin
   s1:=Code(s1);
   Writeln(f,s1);
  End;

  If s2[0]<>#0 Then
  Begin
   s2:=Code(s2);
   Writeln(f,s2);
  End;

  Writeln(f,'-------------------------------------------------------');
  Close(f);
  NoInfoMsg;
  Repeat
  Until UnLockPrWriteRead(FDate,True);

  End;
  i:=IOResult;
End;



Procedure AddProtocolVozwrat(s:String);
Var f : Text;
    i : Byte;
    s1 : String;
Begin
  If DisableProtocol=1 Then Exit;
 i:=IOResult;
 Assign(f,Path^.Dat.ToProtocol+FDate+'.vpr');
 If LockReturnWriteRead(FDate) Then
  Begin
   DInfoMsg('Обновляю протокол возврата...',False);
   i:=IOResult;
   Append(f);
   i:=IOResult;
   If I<>0 Then
    Begin
     NoInfoMsg;
     MessageBox(^M+#3'Ошибка записи протокола возврата!'+ClicProgrammer^+' Код:'+
  IntToStr(I,CKol),Nil,
     mfError+mfCancelButton);
     Exit;
    End;
   i:=IOResult;
  s1:=FDate+'('+Times+') Оператор: ('+CurrentPassword+') '+GetOperatorField(FNAme,CurrentPassword)+
  ' \\'+NetComputerName+' Сеть:'+IntToStr(FileMode,3)+' Ver:'+CompileDate;

         s1:=Code(s1);
         Writeln(f,s1);
         s:=Code(s);
         Writeln(f,s);

(*
  s1:=Encrypt{Code}(s1);
  Writeln(f,s1);
  s:=Encrypt{Code}(s);
  Writeln(f,s);

*)
  Writeln(f,'-------------------------------------------------------');
        Close(f);
        NoInfoMsg;
        Repeat
        Until UnLockReturnWriteRead(FDate);
  End;
i:=IOResult;
End;


Function IncData(D:TDateString):TDateString;
Var {DateMask : String[CDate];}
    l : LongInt;
Begin
 l:=DateStringToDate(DateMask,D);
 Inc(l);
 IncData:=DateToDateString(DateMask,L);
End;



Function TestDate(Const s:TDateString;Var l:LongInt) : Boolean;
Var Y,M,D : Integer;
    s1 : TDateString;
    Code : Integer;
Begin
 TestDate := False;
 s1 := Copy (s,1,2);
 Val (s1,d,Code);
 If (s1[0]<>#2)Or(Code <> 0) Then Exit;
 s1 := Copy (s,4,2);
 Val (s1,M,Code);
 If (s1[0]<>#2)Or(Code <> 0) Then Exit;
 s1 := Copy (s,7,2);

 If StrToInt(s1)<95 Then
     Begin
      Insert('20',s1,1);
     End;

 Val (s1,Y,Code);
 If ((s1[0]<>#4)And(s1[0]<>#2))Or(Code <> 0) Then Exit;


 If ValidDate(d,m,y) Then TestDate:=True;
 L:=DMYToDate(d,m,y);
End;



Function CreatLockPrihod(Var F : File):Boolean;
Var {f : File;}
    c : Word;
Begin
 CreatLockPrihod:=False;
 c:=IoResult;
 Rewrite(f);
 c:=IoResult;
 if c=0 Then
  Begin
        CreatLockPrihod:=True;
        {Close(f);}
        c:=IoResult;
  End;
End;


Procedure UnLockImportPrihod(Var f:File);
Var c : Word;
Begin
 {Assign(f,Path^.Dat.ToFlagDir+'lockadmp');}
 c:=IoResult;
 c:=2;
 DInfoMsg('Деблокирую буфер прихода...',True);
 If Not FExists(Path^.Dat.ToFlagDir+'lockadmp') Then
  Begin
   NoInfoMsg;
   Exit;
  End;

 While c<>0 Do
 Begin
  c:=IoResult;
  Close(f);
  c:=IoResult;
  Erase(f);
  c:=IoResult;
  If FExists(Path^.Dat.ToFlagDir+'lockadmp') Then
   If MessageBox(^M+#3'Ошибка деблокировки буфера прихода! Код: '+IntToStr(c,CLitrMAntissa)+
   ^M+#3'Повторить попытку?',Nil,mfError+mfOkCAncel)<>cmOk Then Break;{c:=0;}
 End;
 NoInfoMsg;
End;





Function SelectSpecify(Regim :Boolean;Reg:Byte):Byte;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelectSpecify:=0;
Case Reg Of
0:R.Assign(31, 9, 48, 14);
1:R.Assign(29, 9, 51, 14);
2:R.Assign(28, 9, 51, 14);
3,8:R.Assign(29, 9, 51, 14);
4:R.Assign(31, 9, 48, 14);
5:If Not Regim Then R.Assign(31, 9, 48, 15)
  Else R.Assign(31, 9, 48, 14);
6:R.Assign(27, 9, 53, 14);
7:R.Assign(27, 9, 53, 13);
9:R.Assign(27, 9, 55, 13);
10:R.Assign(27, 9, 53, 14);
11:R.Assign(27, 9, 58, 14);
12:R.Assign(27, 9, 58, 14);
13:R.Assign(27, 9, 58, 14);

Else;
End;

{
If Reg=0 Then R.Assign(31, 9, 48, 14)
Else R.Assign(29, 9, 51, 14);
}

New(Dlg, Init(R, 'Точнее'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;


Case Reg Of
0:Begin
  R.Assign(1, 1, 16, 4);
  If Not(Regim) Then
  Control := New(PRadioButtons, Init(R,
  NewSItem('С ~к~лиентом',
  NewSItem('Со ~с~кладом',
  NewSItem('~В~се', Nil)))))
Else
Control := New(PRadioButtons, Init(R,
  NewSItem('~О~плаченные',
  NewSItem('В~ы~данные',
  NewSItem('~В~се', Nil)))));
 End;
1: Begin
   R.Assign(1, 1, 21, 4);
  Control := New(PRadioButtons, Init(R,
  NewSItem('~Н~е просроченные',
  NewSItem('~П~росроченные',
  NewSItem('~В~се', Nil)))));
 End;

2: Begin
  R.Assign(1, 1, 22, 4);
  Control := New(PRadioButtons, Init(R,
  NewSItem('~О~плата в кассу',
  NewSItem('Оплата во~з~вратом',
  NewSItem('~В~се оплаты', Nil)))));
 End;

3: Begin
  R.Assign(1, 1, 21, 4);
  Control := New(PRadioButtons, Init(R,
  NewSItem('~П~риходная часть',
  NewSItem('~Р~асходная часть',
  NewSItem('~В~се', Nil)))));
 End;
4: Begin
  R.Assign(1, 1, 16, 4);
  Control := New(PRadioButtons, Init(R,
  NewSItem('~С~о С/Ф',
  NewSItem('Бе~з~ С/Ф',
  NewSItem('~В~се', Nil)))));
 End;
5:Begin
  R.Assign(1, 1, 16, 5);
  If Not(Regim) Then
  Begin
  Control := New(PRadioButtons, Init(R,
  NewSItem('С ~к~лиентом',
  NewSItem('Со ~с~кладом',
  NewSItem('В ~о~бмен',
  NewSItem('~В~се', Nil))))));
  End
Else
  Begin
  R.Assign(1, 1, 16, 4);
  Control := New(PRadioButtons, Init(R,
  NewSItem('~О~плаченные',
  NewSItem('В~ы~данные',
  NewSItem('~В~се', Nil)))));
  End;
  End;

6: Begin
  R.Assign(1, 1, 25, 4);
  Control := New(PRadioButtons, Init(R,
  NewSItem('~Р~асходы из кассы',
  NewSItem('~П~оступления в кассу',
  NewSItem('~В~се', Nil)))));
 End;

7: Begin
  R.Assign(1, 1, 25, 3);
  Control := New(PRadioButtons, Init(R,
  NewSItem('Служба ~д~оставки',
  NewSItem('~В~се', Nil))));
 End;

8:Begin
   R.Assign(1, 1, 21, 4);
   Control := New(PRadioButtons, Init(R,
   NewSItem('~О~дел доставки',
   NewSItem('~Т~абак',
   NewSItem('~В~се', Nil)))));
  End;
9: Begin
  R.Assign(1, 1, 27, 3);
  Control := New(PRadioButtons, Init(R,
  NewSItem('Содержание ревизий',
  NewSItem('Без содержания', Nil))));
 End;
10:Begin
  R.Assign(1, 1, 25, 4);
  Control := New(PRadioButtons, Init(R,
  NewSItem('~Т~овары',
  NewSItem('~С~ертификаты',
  NewSItem('~В~се', Nil)))));
  End;
11:Begin
  R.Assign(1, 1, 30, 4);
  Control := New(PRadioButtons, Init(R,
  NewSItem('Наименование+Производ.',
  NewSItem('Наименование+Цены...',
  NewSItem('Наименование+Спец.Цены', Nil)))));
  If (StrToInt(CurrentPassword)<>0) And (EnableZakupka=0) Then
  PCluster(Control)^.SetButtonState($00000004, False);

  End;

12:Begin
  R.Assign(1, 1, 30, 4);
  Control := New(PRadioButtons, Init(R,
  NewSItem('~Н~е маркированные',
  NewSItem('~М~аркированные',
  NewSItem('~В~се', Nil)))));
  End;
13:Begin
  R.Assign(1, 1, 30, 4);
  Control := New(PRadioButtons, Init(R,
  NewSItem('Форма ~1~',
  NewSItem('Форма ~2~',
  NewSItem('Форма ~3~',
  Nil)))));
  End;
Else;
End;

{
If Reg=0 Then
Begin
R.Assign(1, 1, 16, 4);
If Not(Regim) Then
Control := New(PRadioButtons, Init(R,
  NewSItem('С ~к~лиентом',
  NewSItem('Со ~с~кладом',
  NewSItem('~В~се', Nil)))))
Else
Control := New(PRadioButtons, Init(R,
  NewSItem('~О~плаченные',
  NewSItem('В~ы~данные',
  NewSItem('~В~се', Nil)))));
End
Else
 Begin
R.Assign(1, 1, 21, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('~Н~е просроченные',
  NewSItem('~П~росроченные',
  NewSItem('~В~се', Nil)))));
 End;
}
Dlg^.Insert(Control);

If Reg<>5 Then c:=2
Else If Not(Regim) Then c:=3 Else c:=2;
If Reg in [7..9,11] Then c:=1;

Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
  Begin
   Dlg^.GetData(c);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectSpecify:=c;
  End
  Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   if reg<>5 then SelectSpecify:=3
   else SelectSpecify:=4;
   If reg in [7,9] Then SelectSpecify:=2;
  End;
end;


Function TestFromReturn(Const SClient,SDoc,SDate:AllStr; Var SDocReturn,SDocReturnDate:AllStr):Boolean;
{открываем vzw-файл
 ищем возвратную накладную с клиентом SClient
 и документом основание SDoc от SDate
 если находим то все - трандец - удалять нельзя
 такую эе проверку надо поставить перед поступлением товара на склад
 если документ деактивизирован то все трандец возврат надо переформировывать
 и менять документ основание}
 Var E : PNewVozwratType;
     f : NewVozwratFileType;
     Start,Stop :LongInt;
     j,l : LongInt;
     RDAte : DateSTring;
Begin
TestFromReturn:=False;
Start:=DateStringToDAte(DAteMask,SDAte);
If Start>10 Then Start:=Start-10;
Stop :=DateStringToDAte(DAteMask,FDAte);
Stop:=Start+50;

For l:=Start To Stop Do
 Begin
  RDate:=DateToDAteString(DateMask,L);
  Assign(f,Path^.DAt.ToReturn+RDate+'.vzw');
  j:=IOResult;
  Reset(f);
  j:=IOResult;
  If J=0 Then
    Begin
     New(E,Init);
     While Not(Eof(f)) Do
      Begin
       ReadNewVozwrat(f,E);
       If (StrToInt(E^.DAt.SkladKod)=StrToInt(Rek^.DAt.Kod)) Then
       If (StrToInt(E^.DAt.MAkeKod)=StrToInt(SClient)) And (E^.DAt.OperatorSelector=0) Then
       If (StrToInt(E^.DAt.BasisDoc)=StrToInt(SDoc)) And
          (E^.DAt.BasisDAte=SDAte) Then
         Begin
          {найден объект удовлетворяющий условиям
    поиска}
          TestFromReturn:=True;
          SDocReturn:=E^.DAt.Document;
          SDocReturnDAte:=E^.DAt.DateC;
          Dispose(E,Done);
          j:=IOResult;
          Close(f);
          j:=IOResult;
          Exit;
         End;
      End;

     Dispose(E,Done);
     j:=IOResult;
     Close(f);
     j:=IOResult;
    End;{j=0}
 End;{For l:=Start To Stop}
End;



function CompareFile(Dest:string;Sourse:string):boolean;
   {Dest - имя файла-приемника;
    Sourse - имя файла - источника}
Var D,S: file of Byte;
    IORez: word;
    SizeD, SizeS, timeD, timeS: longint;
Begin

  CompareFile:=false;

  Assign(D,Dest);
  IOrez:=ioresult;
  reset(D);
  IOrez:=ioresult;
  if iorez<>0 then exit
  else
   begin
   { SizeD:=FileSize(D);}
    GetFTime(D,timeD);
    close(D);
   end;

  Assign(S,Sourse);
  IOrez:=ioresult;
  reset(S);
  IOrez:=ioresult;
  if iorez<>0 then exit;
  {SizeS:=FileSize(S);}
  GetFTime(S,timeS);
  close(S);

  if {(SizeD=SizeS) and} (TimeD=TimeS) then CompareFile:=true;

End;



procedure TestDolgMrkDate(var p:PBox;cl:RealizasiaType);
var i: word;
    s: string;
    d: TDateString;
Begin
  if not Cl.Market.Active then exit;
  if not Cl.Full then exit;
  for i:=1 to 4 do
  begin
    if Cl.Doc[i].Employ then
    begin
      d:=DateToDateString(DateMask,Cl.Doc[i].DocDate);
      {продажи}
      {если не одинаковые файлы}
      if not CompareFile(Path^.Dat.ToMarket+D+'.mrk',NetPath^.Dat.ToMarket+D+'.mrk') then
      begin
        s:='copy /b '+NetPath^.Dat.ToMarket+D+'.mrk '
         +copy(Path^.Dat.ToMarket,1,length(Path^.Dat.ToMarket)-1)+' ';
        {если нет уже в списке}
        if not TestHisElement(P,s) then
        begin
          P^.List^.Insert(NewStr(s));
          P^.SetRange(P^.List^.Count);
        end;
      end;
      {индексы}
      if not CompareFile(Path^.Dat.ToMarketIndex+D+'.mrx',NetPath^.Dat.ToMarketIndex+D+'.mrx') then
      begin
        s:='copy /b '+NetPath^.Dat.ToMarketIndex+D+'.mrx '
         +copy(Path^.Dat.ToMarketIndex,1,length(Path^.Dat.ToMarketIndex)-1)+' ';
        if not TestHisElement(P,s) then
        begin
          P^.List^.Insert(NewStr(s));
          P^.SetRange(P^.List^.Count);
        end;
      end;
    end;
  end;
End;


function TestHisElement(const P:PBox;s: string):boolean;
var i: word;
    ws: string;
Begin
 TestHisElement:=false;
 if (P<>nil) and (P^.List^.Count>0) then
 for i:=0 to P^.List^.Count-1 do
 begin
   ws:=P^.GetText(i,P^.List^.Count);
   if (ws=s) then
    begin
      TestHisElement:=true;
      exit;
    end;
 end;
End;




Procedure SortNaklPrh (Var E:PrihodType);
const PosI = 1+CName+CRazdelKOd+CArtikul;
var TempE: PPrihodType;
    TempBox: PBox;
    R: TRect;
    sName: string[CName];
    sRazdel: string[CRazdelKod];
    sArt: string[CArtikul];
    i: word;
    sPos: string[CRazdelKod];
    iPos: word;
    s: string;
Begin

 R.Assign(0,0,0,0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));

 for i:=1 To E.Amount do
 begin
   sArt:=E.PrihodElement[i].BazKod;
   sName:=GetIdField(FName,sArt);
   sRazdel:=copy(sArt,1,CRazdelKod);
   sPos:=IntToStr(i,CRazdelKod);
   format(sArt,CArtikul);
   format(sName,CName);
   format(sRazdel,CRazdelKod);
   format(sPos,CRazdelKod);
   {заполняем список}
   s:='';
   case SortPrihod of
   0: begin
       {наименование - раздел}
        s:=sName+sRazdel+sArt+sPos;
      end;

   1: begin
       {раздел - наименование}
        s:=sRazdel+sName+sArt+sPos;
      end;

   2: begin
       {раздел - код - наименование}
        s:=sRazdel+sArt+sName+sPos;
      end;

   end; {case Sort of}

   TempBox^.List^.Insert(NewStr(s));
   TempBox^.SetRange(TempBox^.List^.Count);
  end; {for i:=1 To E.Amount}

 {перестановка элементов прихода}
 {из накладной в темп}
 new(TempE,Init);
 TempE^.Dat.Amount:=E.Amount;
 if TempBox^.List^.Count>0 then
 for i:=0 to TempBox^.List^.Count-1 do
 with TempE^.Dat.PrihodElement[i+1] do
 begin
   s:=TempBox^.GetText(i,TempBox^.List^.Count);
   sPos:=copy(s,PosI,CRazdelKod);
{   writeln(s);
   writeln(sPos);
   readln;}
   iPos:=StrToInt(sPos);
   BazKod:=E.PrihodElement[iPos].BazKod;
   VidNalog :=E.PrihodElement[iPos].VidNalog;
   Nalog    :=E.PrihodElement[iPos].Nalog;
   VidNDS   :=E.PrihodElement[iPos].VidNDS;
   NDS      :=E.PrihodElement[iPos].NDS;
   Input.Division:=E.PrihodElement[iPos].Input.Division;
   Input.USD     :=E.PrihodElement[iPos].Input.USD;
   Input.GRZena  :=E.PrihodElement[iPos].Input.GRZena;
   Input.Proz    :=E.PrihodElement[iPos].Input.Proz;
   Input.Zakupka :=E.PrihodElement[iPos].Input.Zakupka;
   Input.Zakupka2:=E.PrihodElement[iPos].Input.Zakupka2;
   Input.Nazenka :=E.PrihodElement[iPos].Input.Nazenka;
   Input.R_Zena :=E.PrihodElement[iPos].Input.R_Zena;
   Input.O_Zena  :=E.PrihodElement[iPos].Input.O_Zena;
   Input.Spec_Zena :=E.PrihodElement[iPos].Input.Spec_Zena;
   Input.NMakeKod:=E.PrihodElement[iPos].Input.NMakeKod;
   Input.Virabotano :=E.PrihodElement[iPos].Input.Virabotano;
   Input.Godnost :=E.PrihodElement[iPos].Input.Godnost;
   Input.RegionMarka:=E.PrihodElement[iPos].Input.RegionMarka;
   Input.AkzisSbor:=E.PrihodElement[iPos].Input.AkzisSbor;
   Input.ZenaMarki:=E.PrihodElement[iPos].Input.ZenaMarki;
   Input.NGTD    :=E.PrihodElement[iPos].Input.NGTD;
   Input.Marka   :=E.PrihodElement[iPos].Input.Marka;
   Input.SpecMarka :=E.PrihodElement[iPos].Input.SpecMarka;
   Input.Expert :=E.PrihodElement[iPos].Input.Expert;
   Input.NSertif :=E.PrihodElement[iPos].Input.NSertif;
   Input.StrihKod :=E.PrihodElement[iPos].Input.StrihKod;
   Input.Kol     :=E.PrihodElement[iPos].Input.Kol;
   Input.Caption :=E.PrihodElement[iPos].Input.Caption;
   Input.ZakupkaS:=E.PrihodElement[iPos].Input.ZakupkaS;
   Input.Auto :=E.PrihodElement[iPos].Input.Auto;
 end; {for i:=0 to TempBox^.List^.Count-1 do}
 {из темпа в накладную}
 for i:=1 to E.Amount do
 with E.PrihodElement[i] do
 Begin
   BazKod:=TempE^.Dat.PrihodElement[i].BazKod;
   VidNalog :=TempE^.Dat.PrihodElement[i].VidNalog;
   Nalog    :=TempE^.Dat.PrihodElement[i].Nalog;
   VidNDS   :=TempE^.Dat.PrihodElement[i].VidNDS;
   NDS      :=TempE^.Dat.PrihodElement[i].NDS;
   Input.Division:=TempE^.Dat.PrihodElement[i].Input.Division;
   Input.USD     :=TempE^.Dat.PrihodElement[i].Input.USD;
   Input.GRZena  :=TempE^.Dat.PrihodElement[i].Input.GRZena;
   Input.Proz    :=TempE^.Dat.PrihodElement[i].Input.Proz;
   Input.Zakupka :=TempE^.Dat.PrihodElement[i].Input.Zakupka;
   Input.Zakupka2:=TempE^.Dat.PrihodElement[i].Input.Zakupka2;
   Input.Nazenka :=TempE^.Dat.PrihodElement[i].Input.Nazenka;
   Input.R_Zena :=TempE^.Dat.PrihodElement[i].Input.R_Zena;
   Input.O_Zena  :=TempE^.Dat.PrihodElement[i].Input.O_Zena;
   Input.Spec_Zena :=TempE^.Dat.PrihodElement[i].Input.Spec_Zena;
   Input.NMakeKod:=TempE^.Dat.PrihodElement[i].Input.NMakeKod;
   Input.Virabotano :=TempE^.Dat.PrihodElement[i].Input.Virabotano;
   Input.Godnost :=TempE^.Dat.PrihodElement[i].Input.Godnost;
   Input.RegionMarka:=TempE^.Dat.PrihodElement[i].Input.RegionMarka;
   Input.AkzisSbor:=TempE^.Dat.PrihodElement[i].Input.AkzisSbor;
   Input.ZenaMarki:=TempE^.Dat.PrihodElement[i].Input.ZenaMarki;
   Input.NGTD    :=TempE^.Dat.PrihodElement[i].Input.NGTD;
   Input.Marka   :=TempE^.Dat.PrihodElement[i].Input.Marka;
   Input.SpecMarka :=TempE^.Dat.PrihodElement[i].Input.SpecMarka;
   Input.Expert :=TempE^.Dat.PrihodElement[i].Input.Expert;
   Input.NSertif :=TempE^.Dat.PrihodElement[i].Input.NSertif;
   Input.StrihKod :=TempE^.Dat.PrihodElement[i].Input.StrihKod;
   Input.Kol     :=TempE^.Dat.PrihodElement[i].Input.Kol;
   Input.Caption :=TempE^.Dat.PrihodElement[i].Input.Caption;
   Input.ZakupkaS:=TempE^.Dat.PrihodElement[i].Input.ZakupkaS;
   Input.Auto :=TempE^.Dat.PrihodElement[i].Input.Auto;
 end;{for i:=1 to E.Amount}

 Dispose(TempE,Done);

 Dispose(TempBox,Done);
ENd;





{Var s : String;
    b : Boolean;
Begin
CalcComputer(s,b);}



End.