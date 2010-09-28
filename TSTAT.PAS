{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit tStat;


Interface


Uses Dialogs,Drivers,Glob,Access,ServStr,MyCalc,LockInfo,DStat,TStatu,TStatu2,Utils;


Type
  PCalcTovarWindow = ^TCalcTovarWindow;
  TCalcTovarWindow = object(TDialog)
	 PrhW        : PViewPrihodWindow;
	 MrkW        : PViewMarketWindow;
	 RpW         : PViewRpWindow;
	 RetW        : PViewReturnWindow;
	 RwzW        : PViewRwzWindow;
	 Calc        : PMyCalculator;
	 procedure Start(Const VarList:PBox);
	 procedure DrawCurrent;
	 procedure Refresh;
	 procedure FormReport(E:PBox);
	 procedure HandleEvent(var Event: TEvent); virtual;
	 Destructor Done;Virtual;
  end;


Type
  PTovarStatWindow = ^TTovarStatWindow;
  TTovarStatWindow = object(TDialog)
	 Tvr : PCalcTovarWindow;
	 procedure OpenTovarStatWindow;
	 procedure AddName;
      Procedure SpecialRecalc(Const VarList:PBox);
	 procedure Refresh;
	 procedure DrawCurrent;
	 constructor Init(Var l: Boolean);
	 procedure HandleEvent(var Event: TEvent); virtual;
  end;

{$I Compile.INC}

Const

  {приход}
      CPrihC=1+CName+1+CArtikul+1;
      CPrihS=1+CName+1+CArtikul+1+(CKol+2)+1;
      CPrihB=1+CName+1+CArtikul+1+(CKol+2)+1+(CKol+2)+1;
  {продажи}
    cMrkC=1+CName+1+CArtikul+1+(CKol+2)+1+(CKol+2)+1+(CKol+2)+1;
    cMrkS=CMrkC+(ckol+2)+1;
    cMrkB=CMrkS+(ckol+2)+1;
   {возврат}
   cReturnC=CMrkB+(ckol+2)+1;
   cReturnS=CReturnC+(ckol+2)+1;
  {переоценка}
   cPrz=CReturnS+(ckol+2)+1;
  {ревизия}
	cRwz=CPrz+(ckol+2)+1;
  {РП}
   cRP=CRwz+(ckol+2)+1;
   CMantissaZ=10;

Var
	sstarttov,sstoptov,StopDatetov ,StartDatetov : TDateString;
   PrevLine,SKodTov: string[150];
   OplataTov,OperationTov:Word;
   SVidDocTov :  Maska9;

   procedure LeftConcurs;

Implementation

uses DBEngine,Objects, Views, MsgBox,Protect,TPDate,Market,Tools,Printers,
     Prise,StatTols,UtilsP,
     App, ColorTxt,Validate,Serv,Nastr,Vision1,Vision2,Vision3,NetDbEng;

(*
  {приход}
      CPrihC=1+CName+1+CArtikul+1;
   CPrihCSum=CPrihC+(CKol+1)+1;
		CPrihS=CPrihCSum+(CIZena-2)+1;
   CPrihSSum=CPrihS+(CKol+1)+1;
      CPrihB=CPrihSSum+(CIZena-2)+1;
   CPrihBSum=CPrihB+(CKol+1)+1;
  {продажи}
    cMrkC=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*3;
 cMrkCSum=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*3+(CKol+1)+1;
    cMrkS=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*4;
 cMrkSSum=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*4+(CKol+1)+1;
    cMrkB=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*5;
 cMrkBSum=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*5+(CKol+1)+1;

  {возврат}
   cReturnC=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*6;
cReturnCSum=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*6+(CKol+1)+1;
   cReturnS=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*7;
cReturnSSum=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*7+(CKol+1)+1;

  {переоценка}
   cPrz=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*8;
cPrzSum=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*8+(CKol+1)+1;

  {ревизия}
   cRwz=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*9;
cRwzSum=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*9+(CKol+1)+1;

  {РП}
   cRP=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*10;
cRPSum=1+CName+1+CArtikul+1+((ckol+1)+1+(CIZena-2)+1)*10+(CKol+1)+1;
*)




var
 TStatWindow : PTovarStatWindow;
 CalcTWindow : PCalcTovarWindow;

 NoScreenList,ScreenList,NAmeList,SelectNameList : PBox;

 Prevs: TEnjoyStr;

 SControlComment,
 SControlDocFiltr,
 sControlOplataFiltr,
 SControlClientFiltr,
 scontrol,
  control1,
  ControlPrz,
  ControlRwz,
  ControlRp ,
  ControlReturnC,
  ControlReturnS,
  ControlMrkS,
  ControlMrkB,
  ControlMrkC,
  ControlPrihC,
  ControlPrihS,
  ControlPrihB,
  ControlSorting,
  ControlDirection
   : PView;


 SControlVidProd,
 sControlStartDate,
 sControlStopDate,
 sControlStatus,
 sControlDoc,
 SControlOperationFiltr,
 SControlKolPos,
 ControlFullName,ControlFullName2: PView;

 Ws : String[CIZena];
 SStatusOplata : Maska2;
 SClient : Maska3;
 SLocVidOperation,SVidOperation : Maska6;

 LStart,LStop:LongInt;

 OperationFiltr,VidProd,Filtr: Word;
 Sort,Direction : Word;
 PrevName,PrevCurrent,PrevCurLoc: string[150];
 ControlStartOst,ControlStopOst : PView;

procedure TTovarStatWindow.OpenTovarStatWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmToVarStat, nil) = nil then
  begin
	 DInfo('Инициализация анализа...');
	 L:=True;
	 TStatWindow := New(PTovarStatWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(TStatWindow);
    NoInfo;
    End
    Else
        Begin
         Status:=DocNormal;
         Dispose(TStatWindow,Done);
         NoInfo;
        End;
  end
  else
    if PView(TStatWindow) <> Desktop^.TopView then TStatWindow^.Select;
end;



procedure TTovarStatWindow.Refresh;
Var l : Boolean;
    i,res  : Word;
    s,ws : string;
    id : PBazType;
	 Baz : BazFileType;
    MySet:Set Of Byte;
begin
DInfo('Обновляю список наименований...');

New(Id,Init);
Assign(RazdelFile,Path.ToRazdel+'razdel.db');
Res:=IOResult;
Reset(RazdelFile);
Res:=IOResult;
If Res=0 Then
 Begin
 NameList^.NewList(Nil);
 NameList^.NewList(New(PTextCollection, Init(0,1)));

  MySet:=[];

  Case VidProd Of
  0:MySet:=[0..29];
  1:MySet:=[30..75];
  2:MySet:=[76..99];
  Else Exit;
  End;


  While Not(Eof(RazdelFile)) Do{!!!!!!!!!}
  Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
   If StrToInt(RAzdelElement.Kod) in MySet Then
 Begin
  Begin
{  DInfoMsg('Читаю наименования раздела '+RazdelElement.Kod+'...');}
  Assign(Baz,Path.ToName+RazdelElement.Kod+'.id');
  Res:=IOResult;
  Reset(Baz);
  Res:=IOResult;
  If Res=0 Then
   Begin

    While Not (Eof(Baz)) Do
     Begin
      ReadBazPointer(Baz,Id);
      If Id^.Dat.Employ Then
       Begin
        ws:=Id^.Dat.BazKod;
        s:=Id^.Dat.NAme{GetIdField(FName,ws)};
        DelSpaceRight(s);
        Format(S,CNAme);
        s:=s+'│'+ws+'│';
        ws:=Id^.Dat.InPack{GetIdField(FInPack,ws)};
        DelSpaceRight(ws);
        RFormat(wS,CInPaCk);
        s:=s+ws;
        NameList^.List^.Insert(NewStr(s));
        NameList^.SetRange(NameList^.List^.Count);
       End;
	  End;
    System.Close(Baz);
   End
   Else
    MessageBox(^M+#3'Ошибка открытия '+Path.ToName+RazdelElement.Kod+'.id'+^M+ClicProgrammer,Nil,mfError+mfCancelButton);
{    NoInfoMsg;}
  End;
   End;{RazdelElement.Employ}

  End;{While Not(Eof(RazdelFile))}
  System.Close(RazdelFile);
 End
 Else
	Begin
	NoInfo;
	MessageBox(^M+#3'Ошибка открытия '+Path.ToRazdel+'Razdel.db'^M+ClicProgrammer,Nil,mfError+mfCancelButton);
	End;
Dispose(Id,Done);

NameList^.FocusItem(0);
NameList^.HelpCtx:=$E586;
Insert(NameList);
NoInfo;
Redraw;
end;


procedure FormNameList;
Var l : Boolean;
    i,res  : Word;
    s,ws : string;
    id : PBazType;
    Baz : BazFileType;
    R: Trect;
begin
DInfo('Обновляю список наименований...');
New(Id,Init);
Assign(RazdelFile,Path.ToRazdel+'razdel.db');
Res:=IOResult;
Reset(RazdelFile);
Res:=IOResult;
If Res=0 Then
 Begin
 R.Assign(0, 0, 0, 0);
 NameList := New(PBox, Init(R, 1, PScrollbar(SControl)));
 NameList^.NewList(New(PTextCollection, Init(0,1)));

  While Not(Eof(RazdelFile)) Do
  Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
 Begin
  Begin
  Assign(Baz,Path.ToName+RazdelElement.Kod+'.id');
  Res:=IOResult;
  Reset(Baz);
  Res:=IOResult;
  If Res=0 Then
   Begin
    While Not (Eof(Baz)) Do
     Begin
      ReadBazPointer(Baz,Id);
      If Id^.Dat.Employ Then
       Begin
        ws:=Id^.Dat.BazKod;
        s:=Id^.Dat.NAme{GetIdField(FName,ws)};
        DelSpaceRight(s);
        Format(S,CNAme);
        s:=s+'│'+ws+'│';
        ws:=Id^.Dat.InPack{GetIdField(FInPack,ws)};
        DelSpaceRight(ws);
        RFormat(wS,CInPaCk);
        s:=s+ws;
        NameList^.List^.Insert(NewStr(s));
        NameList^.SetRange(NameList^.List^.Count);
       End;
	  End;
    System.Close(Baz);
   End
   Else
    MessageBox(^M+#3'Ошибка открытия '+Path.ToName+RazdelElement.Kod+'.id'+^M+ClicProgrammer,Nil,mfError+mfCancelButton);
{    NoInfoMsg;}
  End;
   End;{RazdelElement.Employ}

  End;{While Not(Eof(RazdelFile))}
  System.Close(RazdelFile);
 End
 Else
	Begin
	NoInfo;
	MessageBox(^M+#3'Ошибка открытия '+Path.ToRazdel+'Razdel.db'^M+ClicProgrammer,Nil,mfError+mfCancelButton);
	End;
Dispose(Id,Done);

NoInfo;
end;

procedure LeftConcurs;
var i: word;
Begin
 if not ((User[72]) or (CurrentPassword='00')) then exit;
 {заполняем список товаров}
 FormNameList;
 {спрашиваем дату}
 If Not(DatePeriodDialog(StartDatetov,StopDatetov,False)) Then
 begin
  Dispose(NameList,Done);
  Exit;
 end;
 {выставим начальные условия}
 OperationFiltr:=63;
 for i:=1 to 6 do SVidOperation[i]:=0;
 OperationToV:=7;
 for i:=1 to 3 do SClient[i]:=0;
 Filtr:=511;
 for i:=1 to 9 do SVidDocTov[i]:=0;
 OplataToV:=3;
 for i:=1 to 2 do SStatusOplata[i]:=0;

 Concurs(NameList,OperationFiltr,SVidOperation,OperationToV,SClient,Filtr,SVidDocTov,
               OplataToV,SStatusOplata,StartDatetov,StOpDatetov,false);

 Dispose(NameList,Done);

End;

constructor TTovarStatWindow.Init(Var l : Boolean);
Var R  : TRect;
    i,res  : Word;
    s,ws : string[150];
    id : PBazType;
    Baz : BazFileType;
Begin
L:=False;
R.Assign(1, 0, 78, 23);


inherited Init(R, 'Формирование выборки наименований товаров');
TekDate:=FDate;
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E602;

OperationFiltr:=63;
Filtr:=511;
OplataTov:=3;
OperationTov:=7;

R.Assign(1, 1, 31, 4);
SControlOperationFiltr := New(PCheckboxes, Init(R,
  NewSItem('Приход',
  NewSItem('Отгрузка',
  NewSItem('Возврат',
  NewSItem('Переоценка',
  NewSItem('Ревизия',
  NewSItem('Р/П', Nil))))))));
Insert(SControlOperationFiltr);

  R.Assign(1, 0, 12, 1);
  Insert(New(PLabel, Init(R, 'Вид опер.:', SControlOperationFiltr)));

sControlOperationFiltr^.SetData(OperationFiltr);

R.Assign(2, 5, 36, 6);
SControlClientFiltr := New(PCheckboxes, Init(R,
  NewSItem('Кли~е~нт',
  NewSItem('Скл~а~д',
  NewSItem('Обмен',
  Nil)))));
Insert(SControlClientFiltr);
SControlClientFiltr^.SetData(OperationTov);

  R.Assign(1, 4, 14, 5);
  Insert(New(PLabel, Init(R, 'Вид клиента:', SControlClientFiltr)));

R.Assign(35, 1, 45, 2);
sControlStartDate := New(PInputLine, Init(R, CDate));
sControlStartDate^.SetData(StartDatetov);
Insert(sControlStartDate);
  PInputLine(sControlStartDate)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));

  R.Assign(32, 1, 35, 2);
  Insert(New(PLabel, Init(R, 'с:',sControlStartDate)));

R.Assign(35, 2, 45, 3);
sControlStopDate:= New(PInputLine, Init(R, CDate));
sControlStopDate^.SetData(StopDatetov);
Insert(sControlStopDate);
  PInputLine(sControlStopDate)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));


  R.Assign(31, 2, 35, 3);
  Insert(New(PLabel, Init(R, '~п~о:', sControlStopDate)));

R.Assign(47, 1, 76, 4);
sControlDocFiltr := New(PCheckboxes, Init(R,
  NewSItem('~С~п',
  NewSItem('~Т~Ч*',
  NewSItem('ФЛ*',
  NewSItem('С~Ф~*',
  NewSItem('СФ',
  NewSItem('Д~*~',
  NewSItem('Д СФ*',
  NewSItem('Д',
  NewSItem('Д СФ', Nil)))))))))));
Insert(sControlDocFiltr);
sControlDocFiltr^.SetData(Filtr);

  R.Assign(63, 0, 76, 1);
  Insert(New(PLabel, Init(R, 'Вид док-тов:', sControlDocFiltr)));

R.Assign(47, 5, 76, 6);
sControlOplataFiltr := New(PCheckboxes, Init(R,
  NewSItem('~О~плачен',
  NewSItem('~Н~е оплачен', Nil))));
Insert(sControlOplataFiltr);
sControlOplataFiltr^.SetData(OplataTov);

  R.Assign(39, 5, 47, 6);
  Insert(New(PLabel, Init(R, 'Статус док-ов:', sControlOplataFiltr)));


VidProd:=0;

R.Assign(2, 6, 36, 7);
SControlVidProd := New(PRadioButtons, Init(R,
  NewSItem('0-29',
  NewSItem('30-75',
  NewSItem('76-99', Nil)))));
Insert(SControlVidProd);
SControlVidProd^.SetData(VidProd);



R.Assign(38, 8, 39, 20);
sControl := New(PScrollBar, Init(R));
Insert(sControl);

R.Assign(1, 8, 38, 20);
NameList := New(PBox, Init(R, 1, PScrollbar(SControl)));
NameList^.NewList(New(PTextCollection, Init(0,1)));

(*
New(Id,Init);
Assign(RazdelFile,Path.ToRazdel+'razdel.db');
Res:=IOResult;
Reset(RazdelFile);
Res:=IOResult;
If Res=0 Then
 Begin
  While Not(Eof(RazdelFile)) Do{!!!!!!!!!}
  Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
{  DInfoMsg('Читаю наименования раздела '+RazdelElement.Kod+'...');}
  Assign(Baz,Path.ToName+RazdelElement.Kod+'.id');
  Res:=IOResult;
  Reset(Baz);
  Res:=IOResult;
  If Res=0 Then
   Begin

    While Not (Eof(Baz)) Do
     Begin
      ReadBazPointer(Baz,Id);
      If Id^.Dat.Employ Then
       Begin
        ws:=Id^.Dat.BazKod;
        s:=GetIdField(FName,ws);
        DelSpaceRight(s);
        Format(S,CNAme);
        s:=s+'│'+ws+'│';
        ws:=GetIdField(FInPack,ws);
        DelSpaceRight(ws);
        RFormat(wS,CInPaCk);
        s:=s+ws;
		  NameList^.List^.Insert(NewStr(s));
        NameList^.SetRange(NameList^.List^.Count);
       End;
     End;
    System.Close(Baz);
   End
	Else
    MessageBox(^M+#3'Ошибка открытия '+Path.ToName+RazdelElement.Kod+'.id'+^M+ClicProgrammer,Nil,mfError+mfCancelButton);
{    NoInfoMsg;}
   End;{RazdelElement.Employ}
  End;{While Not(Eof(RazdelFile))}
  System.Close(RazdelFile);
 End
 Else
   MessageBox(^M+#3'Ошибка открытия '+Path.ToRazdel+'Razdel.db'^M+ClicProgrammer,Nil,mfError+mfCancelButton);

Dispose(Id,Done);
*)

NameList^.FocusItem(0);
NameList^.HelpCtx:=$E586;
Insert(NameList);

  R.Assign(1, 7, 38, 8);
  Insert(New(PLabel, Init(R, 'Наи~м~енование товара         Код  Фас', NameList)));

R.Assign(76, 8, 77, 21);
sControl := New(PScrollBar, Init(R));
Insert(sControl);

R.Assign(39, 8, 76, 21);
SelectNameList := New(PBox, Init(R, 1, PScrollbar(SControl)));
SelectNameList^.NewList(New(PTextCollection, Init(0,1)));
SelectNameList^.FocusItem(0);
SelectNameList^.HelpCtx:=$E596;
Insert(SelectNameList);

  R.Assign(39, 6, 76, 7);
  Insert(New(PLabel, Init(R, '~В~ыбранные наименования      Код  Фас', SelectNameList)));


R.Assign(2, 21, 22, 22);
sControl := New(PColoredText, Init(R, 'Наименование товара:', $74));
Insert(SControl);

R.Assign(22, 21, 75, 22);
ControlFullName := New(PColoredText, Init(R, ' ', $7E));
Insert(ControlFullName);

R.Assign(2, 20, 38, 21);
sControlComment := New(PColoredText, Init(R, 'На складе:     0 шт. Р/Цена:    0.00', $71));
Insert(SControlComment);

R.Assign(44, 22, 72, 23);
sControlkolpos := New(PColoredText, Init(R, #3+'Выбрано 0 позиций', $4E));
Insert(sControlkolpos);

SelectNext(False);

AddName;
Refresh;
PrevCurrent[0]:=#0;
PrevName[0]:=#0;
L:=True;
End;


procedure TTovarStatWindow.AddName;

Var R : TRect;
    R1,R2 : Real;
    s1,s2 :String[CIZena+1];
    i : Word;
    r3: Word;
Begin
Dispose(sControlkolpos,Done);
R.Assign(44, 22, 72, 23);
sControlkolpos := New(PColoredText, Init(R, #3+'Выбрано '+IntToStr(SelectNameList^.List^.Count,CKol)+' позиций', $4E));
Insert(sControlkolpos);
Redraw;
If (SelectNameList^.List^.Count>=300) Then
 MessageBox(#3+'Вы выбрали слишком большое количество позиций!'^M+
            #3+'Расчет может сильно затянуться!!',nil,mfError+mfCancelButton);
End;


Procedure SetDocFiltrMaska;
Var mm6 : Maska6;
    mm3 : Maska3;
Begin
 WordToBit6(OperationFiltr,mm6);
 Convert6(mm6);
 WordToBit3(OperationTov,mm3);
 Convert3(mm3);
{
If (mm3[1]=1) Then
Begin
}
If (mm6[2]=0) Then
 Begin
  PCluster(SControlDocFiltr)^.SetButtonState($000001FF, False);
  PCluster(SControlOplataFiltr)^.SetButtonState($00000003, False);
 End
Else
 Begin
  PCluster(SControlDocFiltr)^.SetButtonState($000001FF, True);
  PCluster(SControlOplataFiltr)^.SetButtonState($00000003, True);
 End;
{
End
 Else
  Begin
   PCluster(SControlDocFiltr)^.SetButtonState($000001FF, False);
   PCluster(SControlOplataFiltr)^.SetButtonState($00000003, False);
  End;
}
End;




procedure TTovarStatWindow.DrawCurrent;
Var R : TRect;
    s,st : string;
    Artikul : ArtikulStr;
    j : Word;
	 Find : Boolean;

Begin
If (NameList^.List<>Nil)And(NameList^.List^.Count>0)  Then
 Begin
  st:=NameList^.GetText(NameList^.Focused,NAmeList^.List^.Count);
  If St <> PrevCurrent Then
   Begin
    PrevCurrent:=St;
    Artikul:=Copy(st,1+CNAme+1,CArtikul);
    s :=BakGetField(FKol,Artikul,0);
    S:=IntToStr(StrToInt(s),CKol);
    DelSpace(s);
    st:=BakGetField(FRZena,Artikul,0);
    st:=RealToStr(StrToReal(st),CZena,CMAntissa);
	 DiSpose(sControlComment,Done);
	 {R.Assign(2, 21, 39, 22);}
	 R.Assign(2, 20, 38, 21);
	 sControlComment := New(PColoredText, Init(R,'На складе: '+s+' шт. Р/Цена: '+St, $71));
    Insert(SControlComment);
    Redraw;
   End;
 End
 Else
  Begin
   PrevCurrent[0]:=#0;
   s:='???';
DiSpose(sControlComment,Done);
R.Assign(2, 21, 39, 22);
sControlComment := New(PColoredText, Init(R,s, $71));
Insert(SControlComment);
   Redraw;
  End;
End;


procedure TTovarStatWindow.HandleEvent(var Event: TEvent);
LAbel 1,2,3;
Var test : Word;
    s,s1,fstr : string[150];
    razd,SDoc : ArtikulStr;
    SDate: TDateString;
    ClientKod : ArtikulStr;
    ls : LongInt;
    Res : Word;
	 l : Boolean;
    R : TRect;
    Logik : Boolean;
    INSDEL : PBox;
begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
      kbIns: Begin
               ProdagaWindow:=False;
                ClearFind;
            If(NameList^.State and sfFocused <> 0) And (NameList^.List^.Count>=1) Then
            Begin
               s:=NAmeList^.GetText(NameList^.Focused,NAmeList^.List^.COunt);
               If TestElement(Copy(s,1+CName+1,CArtikul),SelectNameList) Then
               Begin
               s:=Copy(s,1,CName+1+CArtikul+1+CInPack);
               SelectNameList^.List^.Insert(NewStr(s));
               SelectNAmeList^.SetRange(SelectNameList^.List^.Count);
               ProdagaWindow:=False;
               s:=NAmeList^.GetText(NameList^.Focused,NameList^.List^.COunt);
               s:=Copy(s,1+CName+1,CArtikul);
					SelectNAmeList^.FocusItem(LoCation(SelectNameList,S,ProdagaWindow));
             If SelectNameList^.Focused+1<SelectNameList^.List^.Count Then
             SelectNameList^.FocusItem(SelectNameList^.List^.Count-1);
               End;
               If (NameList^.Focused+1)<NameList^.List^.Count Then
               NameList^.FocusItem(NameList^.Focused+1);
              End;
              ClearEvent(Event);
              Redraw;
              AddName;
              PrevCurrent[0]:=#0;
            End;

  kbCtrLDel: Begin
               ClearFind;
               ProdagaWindow:=False;
     If (SelectNameList^.State and sfFocused <> 0) And (SelectNameList^.List<>Nil)And(SelectNameList^.List^.Count>=1) Then
            Begin
             SelectNameList^.NewList(nil);
             SelectNameList^.NewList(New(PTextCollection, Init(0,1)));
            End;
            ClearEvent(Event);
             Redraw;
             AddName;
             PrevCurrent[0]:=#0;
            End;

     kbShiftDel: Begin
                ClearFind;
               ProdagaWindow:=False;
     If (SelectNameList^.State and sfFocused <> 0) And (SelectNameList^.List<>Nil)And(SelectNameList^.List^.Count>=1) Then
            Begin
             DInfoMsg('Минуточку...');
              razd:=copy(SelectNameList^.GetText(SelectNameList^.Focused,SelectNameList^.List^.Count),1+CNAme+1,CRazdelKod);
            1:
             If (SelectNameList^.List^.Count>=1) Then
             For ls :=0 To SelectNameList^.List^.Count-1 Do
              Begin
               s:=SelectNameList^.GetText(ls,SelectNameList^.List^.Count);
               If StrToInt(Copy(s,1+CNAme+1,CRazdelKod))=StrToInt(RAzd) Then
                Begin
                 {SelectNameList^.FocusItem(ls);}
                 SelectNameList^.List^.AtFree(Ls);
                 SelectNameList^.SetRange(SelectNameList^.List^.Count);
                 goto 1;
					 End;
              End;

                 If SelectNameList^.Focused>0 Then
			    SelectNameList^.FocusItem(SelectNameList^.Focused);

                 If (SelectNameList^.Focused>=SelectNameList^.List^.Count)
			  and(SelectNameList^.Focused>0) Then
                   SelectNameList^.FocusItem(SelectNameList^.Focused-1);
             NoInfoMsg;

              ClearEvent(Event);
              Redraw;
            End;
              AddName;
              PrevCurrent[0]:=#0;
            End;

     kbDel: Begin
               ClearFind;
               ProdagaWindow:=False;
     If (SelectNameList^.State and sfFocused <> 0) And (SelectNameList^.List<>Nil)And(SelectNameList^.List^.Count>=1) Then
            Begin
              {
              R.Assign(0,0,0,0);
              INSDel := New(PBox, Init(R, 1, Nil));
              INSDel^.NewList(New(PTextCollection, Init(0,1)));
              For ls:=0 To SelectNameList^.List^.Count-1 Do
              Begin
               if ls <> SelectNameList^.Focused Then
                Begin
                 s:=NAmeList^.GetText(NameList^.Focused,NAmeList^.List^.COunt);
                 s:=Copy(s,1,CName+1+CArtikul+1+CInPack);
                 INSDel^.List^.Insert(NewStr(s));
                 INSDel^.SetRange(SelectNameList^.List^.Count);
                 s:=Copy(s,1+CName+1,CArtikul);
                 INSDel^.FocusItem(LoCation(INSDel,S,ProdagaWindow));
                End;
              End;
              }


             SelectNameList^.List^.AtFree(SelectNameList^.Focused);
             SelectNameList^.SetRange(SelectNameList^.List^.Count);
             If SelectNameList^.Focused>0 Then
				 SelectNameList^.FocusItem(SelectNameList^.Focused);

             If (SelectNameList^.Focused>=SelectNameList^.List^.Count) and(SelectNameList^.Focused>0) Then
             SelectNameList^.FocusItem(SelectNameList^.Focused-1);

              ClearEvent(Event);
              Redraw;
            End;
              AddName;
              PrevCurrent[0]:=#0;
            End;


   kbShiftIns:Begin
                ClearFind;
                 ProdagaWindow:=False;
          If ((NameList^.State and sfFocused <> 0)And(NameList^.List^.Count>= 1)) Then
            Begin
             DInfoMsg('Минуточку...');
             razd:=copy(NameList^.GetText(NameList^.Focused,NameList^.List^.Count),1+CNAme+1,CRazdelKod);
             If NameList^.List^.Count>0 Then
             Begin
             {
             SelectNameList^.NewList(nil);
             SelectNameList^.NewList(New(PTextCollection, Init(0,1)));
             }
             For ls :=0 To NameList^.List^.Count-1 Do
              Begin
               s:=NameList^.GetText(ls,NameList^.List^.Count);
               If TestElement(Copy(s,1+CName+1,CArtikul),SelectNameList) Then
               If StrToInt(Copy(s,1+CNAme+1,CRazdelKod))=
                  StrToInt(RAzd) Then
                Begin
                 s:=Copy(s,1,CName+1+CArtikul+1+CInPack);
                 SelectNameList^.List^.Insert(NewStr(s));
                 SelectNameList^.SetRange(SelectNameList^.List^.Count);
                End;
              End;
             End;
                 ProdagaWindow:=False;
                 {SelectNameListList^.SetRange(SelectNameListList^.List^.Count);}
                 If NameList^.Focused+1<NameList^.List^.Count Then NameList^.FocusItem(NameList^.Focused+1);
                 If SelectNameList^.Focused+1<SelectNameList^.List^.Count Then
                 SelectNameList^.FocusItem(SelectNameList^.List^.Count-1);
              NoInfoMsg;
				 ClearEvent(Event);
             End;
            {else ClearEvent(Event);}
            Redraw;
              AddName;
              PrevCurrent[0]:=#0;
              SelectNameList^.FocusItem(0);
              End;
   kbGrayPlus:Begin
          If ((NameList^.State and sfFocused <> 0)And(NameList^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...');
             For ls :=0 To NameList^.List^.Count-1 Do
              Begin
               s:=NameList^.GetText(ls,NameList^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CName);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               If TestElement(Copy(s,1+CName+1,CArtikul),SelectNameList) Then
                Begin
                 s:=Copy(s,1,CName+1+CArtikul+1+CInPack);
                 SelectNameList^.List^.Insert(NewStr(s));
                 SelectNameList^.SetRange(SelectNameList^.List^.Count);
                End;{TestElement}
              End;{For}
              NoInfoMsg;
              ProdagaWindow:=False;
              If SelectNameList^.Focused+1<SelectNameList^.List^.Count Then
              SelectNameList^.FocusItem(SelectNameList^.List^.Count-1);
              AddName;
              SelectNameList^.FocusItem(0);
                End;{Maska}
				  Redraw;
            End;{Nil}
              ClearEvent(Event);

              End;
   kbGrayMinus:Begin
          If ((SelectNameList^.State and sfFocused <> 0)And(SelectNameList^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...');
             2:
             if (SelectNameList^.List^.Count>= 1) Then
             For ls :=0 To SelectNameList^.List^.Count-1 Do
              Begin
               s:=SelectNameList^.GetText(ls,SelectNameList^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CName);
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
              ProdagaWindow:=False;
              AddName;
				  SelectNameList^.FocusItem(0);
                End;{Maska}
              Redraw;
            End;{Nil}
              ClearEvent(Event);

              End;
   kbCtrlIns: Begin
                ClearFind;
                 ProdagaWindow:=False;
          If ((NameList^.State and sfFocused <> 0)And(NameList^.List^.Count>= 1)) Then
            Begin
             DInfoMSg('Минуточку...');
             SelectNameList^.Focusitem(0);
             If NameList^.List^.Count>0 Then
             Begin
             SelectNameList^.NewList(nil);
             SelectNameList^.NewList(New(PTextCollection, Init(0,1)));

             For ls :=0 To NameList^.List^.Count-1 Do
              Begin
               s:=NameList^.GetText(ls,NameList^.List^.Count);
               {if Testelement(Copy(s,1+CNameList+1,CNameListKod),SelectNameListList) then}
                Begin
                 s:=Copy(s,1,CName+1+CArtikul+1+CInPack);
                 SelectNameList^.List^.Insert(NewStr(s));
                 SelectNameList^.SetRange(SelectNameList^.List^.Count);
                End;
              End;
             End;
                 ProdagaWindow:=False;
                 {SelectNameListList^.SetRange(SelectNameListList^.List^.Count);}
                 If NameList^.Focused+1<NameList^.List^.Count Then NameList^.FocusItem(NameList^.Focused+1);
                 If SelectNameList^.Focused+1<SelectNameList^.List^.Count Then
                 SelectNameList^.FocusItem(SelectNameList^.List^.Count-1);
              NoInfoMsg;
              ClearEvent(Event);
             End;
            {Else ClearEvent(Event);}
            Redraw;
              AddName;
              PrevCurrent[0]:=#0;
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
    AboutCHM('43');
    ClearEvent(Event);
  End;

  cmRefresh :Begin
				  Refresh;
              PrevCurrent[0]:=#0;
             End;

  cmCalcStat :Begin
              ClearFind;
              If (SelectNameList^.List<>Nil)And(SelectNAmeList^.List^.Count>0)  Then
               Begin
               {проверяем стартовую дату}
               SControlStartDate^.GetData(sstarttov);
               If Not(TestDate(sstarttov,Ls)) Then
                Begin
                 MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;
               {проверям конечную дату}
               SControlStopDate^.GetData(sstoptov);
               If Not(TestDate(sstoptov,Ls)) Then
                Begin
                 MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;


               {назначаем диапазон дат}
               StopDatetov :=SStoptov;
               StartDatetov:=SStarttov;

               If DateStringToDate(DateMask,StartDatetov)>DateStringToDate(DateMask,StopDatetov) Then
                Begin
					  s1:=StartDatetov;
                 StartDatetov:=stopDatetov;
                 StopDatetov:=s1;
                End;

               SControlStartDate^.SetData(startDatetov);
               SControlStopDate^.SetData(stopDatetov);


               {назначаем фильтр видов документов}
               SControlDocFiltr^.GetData(Filtr);

               {назначаем фильтр видов операций}
               SControlOperationFiltr^.GetData(OperationFiltr);

               {назначаем фильтр видов клиентов}
               SControlClientFiltr^.GetData(OperationTov);

               {назначаем фильтр оплаты}
               sControlOplataFiltr^.GetData(OplataTov);

               {старт загрузки ответа на сформированный запрос}
					{GroupCalcWindow^.Start(l);}
               ClearEvent(Event);
{               MessageBox(^M+#3'Начало расчета!',Nil,mfInformation+mfCancelButton);}
					Tvr^.Start(SelectNameList);
               End
               Else
                Begin
                 MessageBox(^M+#3'Список выбранных наименований - пустой!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;

               PrevCurrent[0]:=#0;
              End;

cmAllSfB :Begin
           ClearFind;

  If (StrToInt(CurrentPassword)=0) Or (Password(7)) Then
   Begin
              If (SelectNameList^.List<>Nil)And(SelectNAmeList^.List^.Count>0)  Then
               Begin

               {проверяем стартовую дату}
               SControlStartDate^.GetData(sstarttov);
               If Not(TestDate(sstarttov,Ls)) Then
                Begin
                 MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;
               {проверям конечную дату}
               SControlStopDate^.GetData(sstoptov);
               If Not(TestDate(sstoptov,Ls)) Then
                Begin
                 MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;


               {назначаем диапазон дат}
               StopDatetov :=SStoptov;
               StartDatetov:=SStarttov;

               If DateStringToDate(DateMask,StartDatetov)>DateStringToDate(DateMask,StopDatetov) Then
                Begin
					  s1:=StartDatetov;
                 StartDatetov:=stopDatetov;
                 StopDatetov:=s1;
                End;

               SControlStartDate^.SetData(startDatetov);
               SControlStopDate^.SetData(stopDatetov);



               {назначаем фильтр видов документов}
               SControlDocFiltr^.GetData(Filtr);

               {назначаем фильтр видов операций}
               SControlOperationFiltr^.GetData(OperationFiltr);

               {назначаем фильтр видов клиентов}
               SControlClientFiltr^.GetData(OperationTov);

               {назначаем фильтр оплаты}
               sControlOplataFiltr^.GetData(OplataTov);


               {старт загрузки ответа на сформированный запрос}
               {GroupCalcWindow^.Start(l);}
               ClearEvent(Event);
{               MessageBox(^M+#3'Начало расчета!',Nil,mfInformation+mfCancelButton);}
               SpecialRecalc(SelectNameList);
               End
               Else
                Begin
                 MessageBox(^M+#3'Список выбранных наименований - пустой!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;
   End;{Password(7)}
               PrevCurrent[0]:=#0;

          End;

  cmAllSpis:Begin
           ClearFind;
  if (CurrentPassword='00') then
  If (StrToInt(CurrentPassword)=0) Or (Password(7)) Then
   Begin

              If (SelectNameList^.List<>Nil)And(SelectNAmeList^.List^.Count>0)  Then
               Begin
               {проверяем стартовую дату}
               SControlStartDate^.GetData(sstarttov);
               If Not(TestDate(sstarttov,Ls)) Then
                Begin
                 MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;

               {проверям конечную дату}
               SControlStopDate^.GetData(sstoptov);
               If Not(TestDate(sstoptov,Ls)) Then
                Begin
                 MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;

               {назначаем диапазон дат}
               StopDatetov :=SStoptov;
               StartDatetov:=SStarttov;

               If DateStringToDate(DateMask,StartDatetov)>DateStringToDate(DateMask,StopDatetov) Then
                Begin
                 s1:=StartDatetov;
                 StartDatetov:=stopDatetov;
                 StopDatetov:=s1;
                End;

               {назначаем фильтр видов документов}
               SControlDocFiltr^.GetData(Filtr);

               {назначаем фильтр видов операций}
               SControlOperationFiltr^.GetData(OperationFiltr);

               {назначаем фильтр видов клиентов}
               SControlClientFiltr^.GetData(OperationTov);

               {назначаем фильтр оплаты}
               sControlOplataFiltr^.GetData(OplataTov);

               {старт загрузки ответа на сформированный запрос}
                                        {GroupCalcWindow^.Start(l);}
               ClearEvent(Event);
{               MessageBox(^M+#3'Начало расчета!',Nil,mfInformation+mfCancelButton);}
               {SpecialRecalc(SelectNameList);}


               Concurs(SelectNameList,OperationFiltr,SVidOperation,OperationToV,SClient,Filtr,SVidDocTov,
               OplataToV,SStatusOplata,StartDatetov,StOpDatetov,true);
               End
               Else
                Begin
                 MessageBox(^M+#3'Список выбранных наименований - пустой!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;
   End;{Password(7)}
               PrevCurrent[0]:=#0;

          End;



cmToVarStat:Begin
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
    (Event.Command = cmToVarStat) then ClearEvent(Event);



  inherited HandleEvent(Event);

  If (Desktop^.Current=PView(TStatWindow)) And (Event.What <> EvKeyDown) Then
   Begin
      DrawCurrent;
			 if (SControlOperationFiltr^.State and sfFocused <> 0)Then
				  Begin
					SControlOperationFiltr^.GetData(Test);
					If Test <> OperationFiltr Then
					Begin
						OperationFiltr:=Test;
                  SetDocFiltrMaska;
                  Redraw;
               End;
              End;

          if (SControlClientFiltr^.State and sfFocused <> 0)Then
              Begin
               SControlClientFiltr^.GetData(Test);
               If Test <> OperationToV Then
               Begin
                  OperationToV:=Test;
                  SetDocFiltrMaska;
                  Redraw;
               End;
              End;

          if (SControlVidProd^.State and sfFocused <> 0)Then
              Begin
               SControlVidProd^.GetData(Test);
               If Test <> VidProd Then
               Begin
                  VidProd:=Test;
                  Refresh;
                  Redraw;
               End;
              End;

   End;
{  ClearEvent(Event);}

end;



Procedure CalcPrihod(l:LongInt;Var EList:PBox);

Function SaveStatPrihod(sP: PStatTovarPrihodType):Boolean;
var Es: File Of StatTovarPrihodType;
    i : Word;
Begin
{ CAse Sp^.DAt.OperatorSelector Of}
{ 0:} Assign(es,Path.ToAnalys+Sp^.Dat.BazKod+'.prh');
{ 1: Assign(es,Path.ToAnalys+Sp^.Dat.BazKod+'.prs');
 2: Assign(es,Path.ToAnalys+Sp^.Dat.BazKod+'.prb');
 Else;
 End;}
 i:=IOResult;
 Reset(es);
 i:=IOResult;
 If i<> 0 Then Exit;
 Seek(es,FileSize(es));
 Write(es,Sp^.DAt);
 Close(es);

End;

Var
   Kol,pos,Cur : LongInt;
   i : Word;
   Find : Boolean;
   E:  PPrihodType;
   ef : PrihodFileType;
   skol,ssum:AllStr;
   statPrih: PStatTovarPrihodType;
   Artikul : ArtikulStr;
   temps : string[150];
Begin
 Assign(eF,Path.ToPrihod+DateToDAteString(DAteMask,L)+'.prh');
 i:=IOResult;
 Reset(ef);
 i:=IOResult;
 If i<>0 Then Exit;

 New(E,Init);
 New(StatPrih,Init);

 While Not(Eof(ef)) Do
  Begin
   ReadPrihod(ef,E);
   If (E^.Dat.StatusDoc=0) Then {если введен на склад}
    Begin
     If E^.Dat.Amount>0 Then

     For i:=1 To E^.Dat.Amount Do
      Begin
         Find:=False;
         For Kol:=0 To EList^.List^.Count-1 Do
          begin
           temps:=Copy(EList^.GetText(Kol,EList^.List^.Count),1+CNAme+1,CArtikul);
           {если нашли код и в накладной и списке}
           If TempS = E^.Dat.PrihodElement[i].BazKod Then
            Begin
             Find:=True;
             Break;
            End;
          end;
        If Find Then
         Begin
          temps:=EList^.GetText(Kol,EList^.List^.Count);
        {обновляю информацию в файле}
          With StatPrih^.Dat Do
           Begin
        BazKod := E^.Dat.PrihodElement[i].BazKod;
        OperatorSelector:=E^.Dat.OperatorSelector;
        StatusDoc:=E^.Dat.StatusDoc;

        MakeKod :=E^.Dat.MakeKod;
        Document:=E^.Dat.Document;
        DateC   :=E^.Dat.DateC;
        TimeC   :=E^.Dat.TiMeC;
        Kol     :=E^.Dat.PrihodElement[i].Input.Kol;
        Str( StrToInt(E^.Dat.PrihodElement[i].Input.Kol)*
                      StrToReal(E^.Dat.PrihodElement[i].Input.R_Zena):CIZena:CMAntissa,SummaPrihod );
        Str( StrToInt(E^.Dat.PrihodElement[i].Input.Kol)*
                      StrToReal(E^.Dat.PrihodElement[i].Input.Zakupka):CIZena:CMAntissa,SummaZakupka);
        SkladKod:=E^.Dat.SkladKod;
        Caption :=E^.Dat.Caption;
           End;
        If Not(SaveStatPrihod(StatPrih)) Then
        MessageBox('Ошибка записи в файл '+E^.Dat.PrihodElement[i].BazKod,nil,mfError+mfCancelButton);
        {конец обновления информации в файле}
        {обновление количества и суммы в списке}
        EList^.List^.AtFree(Kol);
        EList^.SetRange(EList^.List^.Count);
        If (SClient[1]=1) And (E^.Dat.OperatorSelector=0) Then
         Begin
          skol:=copy(temps,CPrihC,CKol+2);
          Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
          Delete(Temps,CPrihC,CKol+2+1);
          Insert(SKol+'│',Temps,CPrihC);
         End;
        If (SClient[2]=1) And (E^.Dat.OperatorSelector=1) Then
          Begin
           skol:=copy(temps,CPrihS,CKol+2);
           Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
           Delete(Temps,CPrihS,CKol+2+1);
           Insert(SKol+'│',Temps,CPrihS);
          End;
        {вставляем бартер}
        If (SClient[3]=1) And (E^.Dat.OperatorSelector=2) Then
          Begin
           skol:=copy(temps,CPrihB,CKol+2);
           Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
           Delete(Temps,CPrihB,CKol+2+1);
           Insert(SKol+'│',Temps,CPrihB);
          End;
        EList^.List^.Insert(NewStr(temps));
        EList^.SetRange(SelectNameList^.List^.Count);
         End;{if find}

      End;

    End;
  End;

 Dispose(StatPrih,Done);
 Dispose(e,Done);
 Close(Ef);
{
 For cur:=0 To EList^.List^.Count-1 Do
  Begin

  End;
 }
End;



Procedure CalcReturn(l:LongInt;Var EList:PBox);

Function SaveStatReturn(sP: PStatTovarReturnType):Boolean;
var Es: File Of StatTovarReturnType;
    i : Word;
Begin
 Assign(es,Path.ToAnalys+Sp^.Dat.BazKod+'.vzw');
 i:=IOResult;
 Reset(es);
 i:=IOResult;
 If i<> 0 Then Exit;
 Seek(es,FileSize(es));
 Write(es,Sp^.DAt);
 Close(es);

End;

Var
   Kol,pos,Cur : LongInt;
   i : Word;
   Find : Boolean;
   E  : PNewVozwratType;
   ef : NewVozwratFileType;
   skol,ssum:AllStr;
   statPrih: PStatTovarReturnType;
   Artikul : ArtikulStr;
   temps : string[150];
Begin
 Assign(eF,Path.ToReturn+DateToDAteString(DAteMask,L)+'.vzw');
 i:=IOResult;
 Reset(ef);
 i:=IOResult;
 If i<>0 Then Exit;

 New(E,Init);
 New(StatPrih,Init);

 While Not(Eof(ef)) Do
  Begin
   ReadNewVozwrat(ef,E);
   If (E^.Dat.StatusDoc=0) Then {если введен на склад}
    Begin
     If E^.Dat.Amount>0 Then

     For i:=1 To E^.Dat.Amount Do
      Begin
         Find:=False;
         For Kol:=0 To EList^.List^.Count-1 Do
          begin
           temps:=Copy(EList^.GetText(Kol,EList^.List^.Count),1+CNAme+1,CArtikul);
           {если нашли код и в накладной и списке}
           If TempS = E^.Dat.VozwratElement[i].BazKod Then
            Begin
             Find:=True;

{             Str(StrToInt(Kol1)+StrToInt(E^.Dat.VozwratElement[i].Input.Kol):CKol+2,Kol1);
             {Str(StrToReal(Sum1)+StrToInt(E^.Dat.VozwratElement[i].Input.Kol)*
                                 StrToInt(E^.Dat.VozwratElement[i].Input.R_Zena):CIZena:CMantissa,Sum1);
             }
             break;
            End;
          end;
        If Find Then
         Begin
          temps:=EList^.GetText(Kol,EList^.List^.Count);
        {обновляю информацию в файле}
          With StatPrih^.Dat Do
           Begin
     VidDocument:=E^.Dat.VidDocument;
        BasisDoc:=E^.Dat.BasisDoc;
      BasisDate :=E^.Dat.BasisDate;

        BazKod:=E^.Dat.VozwratElement[i].BazKod;
        OperatorSelector:=E^.Dat.OperatorSelector;
        DocSelector:=E^.Dat.DocSelector;
        StatusDoc:=E^.Dat.StatusDoc;
        MakeKod :=E^.Dat.MakeKod;
        Document:=E^.Dat.Document;
        DateC   :=E^.Dat.DateC;
        TimeC   :=E^.Dat.TiMeC;
        Opt     :=E^.Dat.Opt;
        Rashod  :=E^.Dat.Rashod;
        RashodSumma:=E^.Dat.RashodSumma;
        Kol     := E^.Dat.VozwratElement[i].Input.Kol;
        Str(StrToInt(E^.Dat.VozwratElement[i].Input.Kol)*
            StrToReal(E^.Dat.VozwratElement[i].Input.R_Zena):CIZena:CMantissa,Summa);
        SkladKod:=E^.Dat.SkladKod;
        Caption :=E^.Dat.Caption;
           End;
        If Not(SaveStatReturn(StatPrih)) Then
        MessageBox('Ошибка записи в файл '+E^.Dat.VozwratElement[i].BazKod,nil,mfError+mfCancelButton);
        {конец обновления информации в файле}

        {обновление количества и суммы в списке}
        EList^.List^.AtFree(Kol);
        EList^.SetRange(EList^.List^.Count);
        If (SClient[1]=1) And (E^.Dat.OperatorSelector=0) Then
         Begin
          skol:=copy(temps,CReturnC,CKol+2);
          Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
          Delete(Temps,CReturnC,CKol+2+1);
          Insert(SKol+'│',Temps,CReturnC);
         End;

        If (SClient[2]=1) And (E^.Dat.OperatorSelector=1) Then
          Begin
           skol:=copy(temps,CReturnS,CKol+2);
           Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
           Delete(Temps,CReturnS,CKol+2+1);
           Insert(SKol+'│',Temps,CReturnS);
          End;

        EList^.List^.Insert(NewStr(temps));
        EList^.SetRange(SelectNameList^.List^.Count);
         End;{if find}

      End;
    End;
  End;

 Dispose(StatPrih,Done);
 Dispose(e,Done);
 Close(Ef);
End;



Procedure CalcMrk(l:LongInt;Var EList:PBox);

Function SaveStatMrk(sP: PStatTovarMarketType):Boolean;
var Es: File Of StatTovarMarketType;
    i : Word;
Begin
 Assign(es,Path.ToAnalys+Sp^.Dat.BazKod+'.mrk');
 i:=IOResult;
 Reset(es);
 i:=IOResult;
 If i<> 0 Then Exit;
 Seek(es,FileSize(es));
 Write(es,Sp^.DAt);
 Close(es);
End;

Var
   Kol,pos,Cur : LongInt;
   i : Word;
   Find : Boolean;
   lg,E  : PSuperMarketType;
   ef : MarketFileType;
   zakupka,ws2,koefficient,kol1,sum1,enalog1,skidka1,skol,ssum:AllStr;
   statPrih: PStatTovarMarketType;
   Artikul : ArtikulStr;
   temps,ws : string[150];
   SumOpl : AllStr;
   k,j,r : Byte;

Begin
 Assign(eF,Path.ToMarket+DateToDAteString(DAteMask,L)+'.mrk');
 i:=IOResult;
 Reset(ef);
 i:=IOResult;
 If i<>0 Then Exit;

 New(E,Init);
 New(StatPrih,Init);

 While Not(Eof(ef)) Do
  Begin
   ReadMArket(ef,e);
   If E^.Dat.Active Then
Begin
   k:=1;j:=1;
   new(lg,init);

   For l:=1 To E^.Dat.Amount Do
    Begin
     If testMarketSF(E^.Dat.MarketElement[l].BazKod,Lg,j) Then
      Begin
       Str((StrToInt(Lg^.Dat.MarketElement[j].Input.Kol)+
            StrToInt( E^.Dat.MarketElement[l].Input.Kol)):CKol,Lg^.Dat.MarketElement[j].Input.Kol);

       Lg^.Dat.MarketElement[j].Input.Zena:=E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[j].Input.Zakupka:=E^.Dat.MarketElement[l].Input.Zakupka;
       Lg^.Dat.MarketElement[j].Input.Skidka:=E^.Dat.MarketElement[l].Input.Skidka;
       Lg^.Dat.MarketElement[j].Input.Proz:=E^.Dat.MarketElement[l].Input.Proz;
       Lg^.Dat.MarketElement[j].Input.SpecNalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
       Lg^.Dat.MarketElement[j].Input.NDS:=E^.Dat.MarketElement[l].Input.NDS;

      End
      Else
      Begin
       Lg^.Dat.MarketElement[k]:=E^.Dat.MarketElement[l];
       Lg^.Dat.MarketElement[k].Input.Zena:=E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[k].Input.Zakupka:=E^.Dat.MarketElement[l].Input.Zakupka;
       Lg^.Dat.MarketElement[k].Input.Skidka:=E^.Dat.MarketElement[l].Input.Skidka;
       Lg^.Dat.MarketElement[k].Input.Proz:=E^.Dat.MarketElement[l].Input.Proz;
       Lg^.Dat.MarketElement[k].Input.SpecNalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
       Lg^.Dat.MarketElement[k].Input.NDS:=E^.Dat.MarketElement[l].Input.NDS;
       Inc(k);
       Lg^.DAt.Amount:=k-1;
      End;
    End;
    Lg^.DAt.Amount:=k-1;

   If Not((E^.Dat.OperatorSelector=1) And (E^.Dat.ClientKod=ClientRP)) Then
   Begin
   If Not ((E^.Dat.Realiz) And (E^.Dat.DocSelector in [0,1,2,3,4])) Then
   Begin
   If ((SVidDocTov[E^.Dat.DocSelector+1]=1)  And (E^.Dat.OperatorSelector in [0,2]))
    Or (E^.Dat.OperatorSelector=1)  Then
   Begin
     If Lg^.Dat.Amount>0 Then
     For i:=1 To Lg^.Dat.Amount Do
      Begin
        Find:=False;
        kol1[0]:=#0;
        sum1[0]:=#0;
        SumOpl[0]:=#0;
        skidka1[0]:=#0;
        enalog1[0]:=#0;
        Zakupka[0]:=#0;
        For Kol:=0 To EList^.List^.Count-1 Do
         begin
          temps:=Copy(EList^.GetText(Kol,EList^.List^.Count),1+CNAme+1,CArtikul);
          {если нашли код и в накладной и списке}
          If TempS = Lg^.Dat.MarketElement[i].BazKod Then
           Begin
            Find:=True;
            Str(StrToInt(Kol1)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol+2,Kol1);

            {сумма отгрузки}
            Str(StrToReal(Sum1)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
            StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CIZena:CMantissa,Sum1);


            {сумма отгрузки по закупке}
            Str(StrToReal(Zakupka)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
            StrToReal(Lg^.Dat.MarketElement[i].Input.Zakupka):CIZena:CMantissa,Zakupka);
            {цена отгрузки}

            If E^.Dat.OperatorSelector in [0,2] Then
             Begin
              Case E^.DAt.SkidkaSelector Of
              0:
               Begin
                DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);

                Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*
                (StrToReal(Lg^.Dat.MarketElement[{l}i].Input.Proz))):CZena:CMantissa,ws);

                Str(StrToReal(SumOpl)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
                StrToReal(ws):CIZena:CMantissa,SumOpl);

                {ws - теперь цена с учетом скидки}
                str(strtoreal(Lg^.Dat.MarketElement[i].Input.Zena)-
                    strtoreal(ws):CZena:CMantissa,ws);
                {ws - теперь велечина позиционной скидки}
                Str(StrToReal(Skidka1)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
                StrToReal(ws):CIZena:CMantissa,Skidka1);

                DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);

                Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*
                (StrToReal(Lg^.Dat.MarketElement[{l}i].Input.Proz))):CZena:CMantissa,ws);


               End;
              1:Begin
                  {сумма скидки}
                  Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-
			   StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
                  :CZena:CMantissa,ws);

                Str(StrToReal(SumOpl)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
                StrToReal(ws):CIZena:CMantissa,SumOpl);

                  Str(StrToReal(Skidka1)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
                  StrToReal(ws):CIZena:CMantissa,Skidka1);
                 End;
              2: Begin
                DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);

                Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*
                (StrToReal(Lg^.Dat.MarketElement[{l}i].Input.Proz))):CZena:CMantissa,ws);

                Str(StrToReal(SumOpl)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
                StrToReal(ws):CIZena:CMantissa,SumOpl);

                {ws - теперь цена с учетом скидки}
                str(strtoreal(Lg^.Dat.MarketElement[i].Input.Zena)-
                    strtoreal(ws):CZena:CMantissa,ws);
                {ws - теперь велечина позиционной скидки}
                Str(StrToReal(Skidka1)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
                StrToReal(ws):CIZena:CMantissa,Skidka1);

                DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
                Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*
                (StrToReal(Lg^.Dat.MarketElement[{l}i].Input.Proz))):CZena:CMantissa,ws);

                 End;
              Else;
              End;


                If E^.DAt.DocSelector in [{1,}2,3,5,6] Then
                 Begin
                  str(((1+strtoreal(lg^.dat.marketelement[i].Input.SpecNalog)
                  /100)):CLitr:CMantissa,koefficient);
                  Str(StrToReal(ws)*StrToReal(Koefficient):CZena:CMantissa,ws2);
                  Str(StrToReal(ws2)-StrToReal(ws):CZena:CMAntissa,ws);
			   {абсолютная величина сбора Налога с продажи}
                  Str(StrtoReal(ENalog1)+StrToReal(ws)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:
			   CMAntissa,ENalog1);
                 End;
             End;
          break;

    End;{фильтр документов отгрузки}

         end;
        If Find Then
         Begin
          temps:=EList^.GetText(Kol,EList^.List^.Count);
        {обновляю информацию в файле}
          With StatPrih^.Dat Do
           Begin
        BazKod  :=Lg^.dat.marketelement[i].BazKod;
        {
        If E^.Dat.DocSelector in [4,8] Then  Rashet    :=0
        Else Rashet    :=1;
        }

OperatorSelector:=e^.dat.OperatorSelector;
    DocSelector :=e^.dat.DocSelector;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
        Realiz  :=E^.Dat.Realiz;     {признак что товар был выдан на реадизацию}
 SkidkaSelector :=E^.Dat.SkidkaSelector; {вид скидки}
        {Oplata :=True;}
      ClientKod :=E^.Dat.ClientKod; {код клиента}
       AgentKod :=E^.Dat.AgentKod; {код клиента}
        Document:=E^.Dat.Document; {номер документа}
        DateC   :=E^.Dat.DateC; {дата создания}
        TimeC   :=E^.Dat.TimeC; {время создания}
        DateM   :=E^.Dat.DateM; {дата создания}
        TimeM   :=E^.Dat.TimeM; {время создания}
        Kol     :=kol1;
        SummaZ  :=SumOpl{sum1};  {сумма по позиции к оплате}
        ENalog  :=ENalog1;  {сумма по позиции налог с продажи}
        SNalog  :=lg^.dat.marketelement[i].Input.SpecNalog;
        Skidka  :=Skidka1;  {сумма по документу к оплате}
   SummaZakupka :=Zakupka;  {сумма документа по закупочным ценнам}
        SkladKod:=e^.dat.SkladKod;{признак склада}
        Caption :=e^.dat.caption;{признак оператора}
        BN      :=e^.Dat.Bn;
           End;

        If Not(SaveStatMrk(StatPrih)) Then
        MessageBox('Ошибка записи в файл '+lg^.Dat.MarketElement[i].BazKod,nil,mfError+mfCancelButton);
        {конец обновления информации в файле}

        {обновление количества и суммы в списке}
        EList^.List^.AtFree(Kol);
        EList^.SetRange(EList^.List^.Count);
        If (SClient[1]=1) And (E^.Dat.OperatorSelector=0) Then
         Begin
          skol:=copy(temps,CMrkC,CKol+2);
          Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
          Delete(Temps,CMrkC,CKol+2+1);
          Insert(SKol+'│',Temps,CMrkC);
         End;

        If (SClient[2]=1) And (E^.Dat.OperatorSelector=1) Then
          Begin
           skol:=copy(temps,CMrkS,CKol+2);
           Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
           Delete(Temps,CMrkS,CKol+2+1);
           Insert(SKol+'│',Temps,CMrkS);
          End;

        If (SClient[3]=1) And (E^.Dat.OperatorSelector=2) Then
          Begin
           skol:=copy(temps,CMrkB,CKol+2);
           Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
           Delete(Temps,CMrkB,CKol+2+1);
           Insert(SKol+'│',Temps,CMrkB);
          End;

        EList^.List^.Insert(NewStr(temps));
        EList^.SetRange(SelectNameList^.List^.Count);
         End;{if find}
    End;{фильтр документов отгрузки}
   End;{фильтр вторичных документов консигнации}
  End;{фильтр РП}
  End;
  Dispose(lg,Done);
{End;{Active}
End;{Active}

  End;{While}





 Dispose(StatPrih,Done);
 Dispose(e,Done);
 Close(Ef);
End;


Procedure CalcRP(l:LongInt;Var EList:PBox);

Function SaveStatMrk(sP: PStatTovarMarketType):Boolean;
var Es: File Of StatTovarMarketType;
    i : Word;
Begin
 Assign(es,Path.ToAnalys+Sp^.Dat.BazKod+'.rp');
 i:=IOResult;
 Reset(es);
 i:=IOResult;
 If i<> 0 Then Exit;
 Seek(es,FileSize(es));
 Write(es,Sp^.DAt);
 Close(es);

End;

Var
   Kol,pos,Cur : LongInt;
   i : Word;
   Find : Boolean;
   lg,E  : PSuperMarketType;
   ef : MarketFileType;
   zakupka,ws2,koefficient,kol1,sum1,enalog1,skidka1,skol,ssum:AllStr;
   statPrih: PStatTovarMarketType;
   Artikul : ArtikulStr;
   temps,ws : string[150];
   k,j,r : Byte;

Begin
 Assign(eF,Path.ToMarket+DateToDAteString(DAteMask,L)+'.mrk');
 i:=IOResult;
 Reset(ef);
 i:=IOResult;
 If i<>0 Then Exit;

 New(E,Init);
 New(StatPrih,Init);

 While Not(Eof(ef)) Do
  Begin
   ReadMArket(ef,e);
If E^.Dat.Active Then
Begin
   k:=1;j:=1;
   new(lg,init);

   For l:=1 To E^.Dat.Amount Do
    Begin

     If testMarketSF(E^.Dat.MarketElement[l].BazKod,Lg,j) Then
      Begin
       Str((StrToInt(Lg^.Dat.MarketElement[j].Input.Kol)+
            StrToInt( E^.Dat.MarketElement[l].Input.Kol)):CKol,Lg^.Dat.MarketElement[j].Input.Kol);

       Lg^.Dat.MarketElement[j].Input.Zena:=E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[j].Input.Zakupka:=E^.Dat.MarketElement[l].Input.Zakupka;
       Lg^.Dat.MarketElement[j].Input.Skidka:=E^.Dat.MarketElement[l].Input.Skidka;
       Lg^.Dat.MarketElement[j].Input.Proz:=E^.Dat.MarketElement[l].Input.Proz;
       Lg^.Dat.MarketElement[j].Input.SpecNalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
       Lg^.Dat.MarketElement[j].Input.NDS:=E^.Dat.MarketElement[l].Input.NDS;

      End
      Else
      Begin
       Lg^.Dat.MarketElement[k]:=E^.Dat.MarketElement[l];
       Lg^.Dat.MarketElement[k].Input.Zena:=E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[k].Input.Zakupka:=E^.Dat.MarketElement[l].Input.Zakupka;
       Lg^.Dat.MarketElement[k].Input.Skidka:=E^.Dat.MarketElement[l].Input.Skidka;
       Lg^.Dat.MarketElement[k].Input.Proz:=E^.Dat.MarketElement[l].Input.Proz;
       Lg^.Dat.MarketElement[k].Input.SpecNalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
       {Lg^.Dat.MarketElement[j].BazKod:=E^.Dat.MarketElement[l].BazKod;}
       Lg^.Dat.MarketElement[k].Input.NDS:=E^.Dat.MarketElement[l].Input.NDS;
       Inc(k);
       Lg^.DAt.Amount:=k-1;
      End;
      {
      Begin
       Str((StrToInt(Lg^.Dat.MarketElement[j].Input.Kol)+
            StrToInt( E^.Dat.MarketElement[l].Input.Kol)):CKol,Lg^.Dat.MarketElement[j].Input.Kol);

       Lg^.Dat.MarketElement[j].Input.Zena:=E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[j].Input.Zakupka:=E^.Dat.MarketElement[l].Input.Zakupka;
       Lg^.Dat.MarketElement[j].Input.Skidka:=E^.Dat.MarketElement[l].Input.Skidka;
       Lg^.Dat.MarketElement[j].Input.Proz:=E^.Dat.MarketElement[l].Input.Proz;
       Lg^.Dat.MarketElement[j].Input.SpecNalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
       Lg^.Dat.MarketElement[j].Input.NDS:=E^.Dat.MarketElement[l].Input.NDS;

      End
      Else
      Begin
       Lg^.Dat.MarketElement[k]:=E^.Dat.MarketElement[l];
       Lg^.Dat.MarketElement[j].Input.Zena:=E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[j].Input.Zakupka:=E^.Dat.MarketElement[l].Input.Zakupka;
       Lg^.Dat.MarketElement[j].Input.Skidka:=E^.Dat.MarketElement[l].Input.Skidka;
       Lg^.Dat.MarketElement[j].Input.Proz:=E^.Dat.MarketElement[l].Input.Proz;
       Lg^.Dat.MarketElement[j].Input.SpecNalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
       Lg^.Dat.MarketElement[j].Input.NDS:=E^.Dat.MarketElement[l].Input.NDS;
       Inc(k);
       Lg^.DAt.Amount:=k-1;
      End;
      }
    End;
    Lg^.DAt.Amount:=k-1;

   If (E^.Dat.OperatorSelector=1) And (E^.Dat.ClientKod=ClientRP) Then
   Begin
   If Not ((E^.Dat.Realiz) And (E^.Dat.DocSelector in [0,1,2,3,4])) Then
   Begin
     If Lg^.Dat.Amount>0 Then
     For i:=1 To Lg^.Dat.Amount Do
      Begin
        Find:=False;
        kol1[0]:=#0;
        sum1[0]:=#0;
        skidka1[0]:=#0;
        enalog1[0]:=#0;
        Zakupka[0]:=#0;
        For Kol:=0 To EList^.List^.Count-1 Do
         begin
          temps:=Copy(EList^.GetText(Kol,EList^.List^.Count),1+CNAme+1,CArtikul);
          {если нашли код и в накладной и списке}
          If TempS = Lg^.Dat.MarketElement[i].BazKod Then
           Begin
            Find:=True;
            Str(StrToInt(Kol1)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol+2,Kol1);
            {сумма отгрузки}
            Str(StrToReal(Sum1)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
            StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CIZena:CMantissa,Sum1);

            {сумма отгрузки}
            Str(StrToReal(Zakupka)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
            StrToReal(Lg^.Dat.MarketElement[i].Input.Zakupka):CIZena:CMantissa,Zakupka);
            {цена отгрузки}
            If E^.Dat.OperatorSelector=0 Then
             Begin
              If E^.DAt.SkidkaSelector=0 Then
               Begin
                DelSpace(Lg^.Dat.MarketElement[l].Input.Proz);
                Str((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)*
                (StrToReal(Lg^.Dat.MarketElement[l].Input.Proz))):CZena:CMantissa,ws);
                {ws - теперь цена с учетом скидки}
                str(strtoreal(Lg^.Dat.MarketElement[l].Input.Zena)-
                    strtoreal(ws):CZena:CMantissa,ws);
                {ws - теперь велечина позиционной скидки}
                Str(StrToReal(Skidka1)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
                StrToReal(ws):CIZena:CMantissa,Skidka1);

                DelSpace(Lg^.Dat.MarketElement[l].Input.Proz);
                Str((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)*
                (StrToReal(Lg^.Dat.MarketElement[l].Input.Proz))):CZena:CMantissa,ws);
               End
                Else
                 Begin
                  {сумма скидки}
                  Str((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[l].Input.Skidka))
                  :CZena:CMantissa,ws);
                  Str(StrToReal(Skidka1)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
                  StrToReal(ws):CIZena:CMantissa,Skidka1);
                 End;

                If E^.DAt.DocSelector in [{1,}2,3,5,6] Then
                 Begin
                  str(((1+strtoreal(lg^.dat.marketelement[l].Input.SpecNalog)
                  /100)):CLitr:CMantissa,koefficient);
                  Str(StrToReal(ws)*StrToReal(Koefficient):CZena:CMantissa,ws2);
                  Str(StrToReal(ws2)-StrToReal(ws):CZena:CMAntissa,ws);
			   {абсолютная величина сбора Налога с продажи}
                  Str(StrtoReal(ENalog1)+StrToReal(ws)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):
			   CIZena:CMAntissa,ENalog1);
                 End;
             End;
          break;

    End;{фильтр документов отгрузки}

         end;
        If Find Then
         Begin
          temps:=EList^.GetText(Kol,EList^.List^.Count);
        {обновляю информацию в файле}
          With StatPrih^.Dat Do
           Begin
        BazKod  :=Lg^.dat.marketelement[i].BazKod;
        If E^.Dat.DocSelector in [4,8] Then  Rashet    :=0
        Else Rashet    :=1;
OperatorSelector:=e^.dat.OperatorSelector;
    DocSelector :=e^.dat.DocSelector;    {список, тов чек, физ.лиц, с/ф,с/ф б, дебит то есть деньги еще не проплачены}
        Realiz  :=E^.Dat.Realiz;     {признак что товар был выдан на реадизацию}
 SkidkaSelector :=E^.Dat.SkidkaSelector; {вид скидки}
        Oplata  :=True;
      ClientKod :=E^.Dat.ClientKod; {код клиента}
       AgentKod :=E^.Dat.AgentKod; {код клиента}
        Document:=E^.Dat.Document; {номер документа}
        DateC   :=E^.Dat.DateC; {дата создания}
        TimeC   :=E^.Dat.TimeC; {время создания}
        DateM   :=E^.Dat.DateM; {дата создания}
        TimeM   :=E^.Dat.TimeM; {время создания}
        Kol     :=kol1;
        SummaZ  :=sum1;  {сумма по позиции к оплате}
        ENalog  :=ENalog1;  {сумма по позиции налог с продажи}
        SNalog  :=lg^.dat.marketelement[i].Input.SpecNalog;
        Skidka  :=Skidka1;  {сумма по документу к оплате}
   SummaZakupka :=Zakupka;  {сумма документа по закупочным ценнам}
        SkladKod:=e^.dat.SkladKod;{признак склада}
        Caption :=e^.dat.caption;{признак оператора}
           End;
        If Not(SaveStatMrk(StatPrih)) Then
        MessageBox('Ошибка записи в файл '+lg^.Dat.MarketElement[i].BazKod,nil,mfError+mfCancelButton);
        {конец обновления информации в файле}

        {обновление количества и суммы в списке}
        EList^.List^.AtFree(Kol);
        EList^.SetRange(EList^.List^.Count);
        If (SClient[1]=1) Then
         Begin
          skol:=copy(temps,CRp,CKol+2);
          Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
          Delete(Temps,CRp,CKol+2+1);
          Insert(SKol+'│',Temps,CRp);
         End;
        EList^.List^.Insert(NewStr(temps));
        EList^.SetRange(SelectNameList^.List^.Count);
         End;{if find}
    End;{фильтр документов отгрузки}
  End;{фильтр РП}
  End;
  Dispose(lg,Done);
{закончили с товаром}


End;
  End;

 Dispose(StatPrih,Done);
 Dispose(e,Done);
 Close(Ef);
End;





Procedure CalcPrz(l:LongInt;Var EList:PBox);

Function SaveStatPereozenka(sP: PStatTovarPrzType):Boolean;
var Es: File Of StatTovarPrzType;
    i : Word;
Begin
 Assign(es,Path.ToAnalys+Sp^.Dat.BazKod+'.prz');
 i:=IOResult;
 Reset(es);
 i:=IOResult;
 If i<> 0 Then Exit;
 Seek(es,FileSize(es));
 Write(es,Sp^.DAt);
 Close(es);

End;

Var
   Kol,pos,Cur : LongInt;
   i : Word;
   Find : Boolean;
   E  : PPereozenkaType;
   ef : PereozenkaFileType;
   kol1,sum1,skol,ssum:AllStr;
   statPrih: PStatTovarPrzType;
   Artikul : ArtikulStr;
   temps : string[150];
Begin
 Assign(eF,Path.ToCorrect+DateToDAteString(DAteMask,L)+'.prz');
 i:=IOResult;
 Reset(ef);
 i:=IOResult;
 If i<>0 Then Exit;

 New(E,Init);
 New(StatPrih,Init);

 While Not(Eof(ef)) Do
  Begin
   ReadPereozenka(ef,E);
     kol1[0]:=#0;
     sum1[0]:=#0;
     If E^.Dat.Amount>0 Then
     For i:=1 To E^.Dat.Amount Do
      Begin
         Find:=False;
         For Kol:=0 To EList^.List^.Count-1 Do
          begin
           temps:=Copy(EList^.GetText(Kol,EList^.List^.Count),1+CNAme+1,CArtikul);
           {если нашли код и в накладной и списке}
           If TempS = E^.Dat.Element[i].BazKod Then
            Begin
             Find:=True;
             Str(StrToInt(Kol1)+StrToInt(E^.Dat.Element[i].Kol):CKol+2,Kol1);
             Str(StrToReal(Sum1)+StrToInt(E^.Dat.Element[i].Kol)*
                                (StrToReal(E^.Dat.Element[i].New_R_Zena)-
                                 StrToReal(E^.Dat.Element[i].Bak_R_Zena)):CIZena:CMantissa,Sum1);
             break;
            End;
          end;
        If Find Then
         Begin
          temps:=EList^.GetText(Kol,EList^.List^.Count);
        {обновляю информацию в файле}
          With StatPrih^.Dat Do
           Begin

        BazKod:=E^.Dat.Element[i].BazKod;
        Document:=E^.Dat.Document;
        DateC   :=E^.Dat.DateC;
        TimeC   :=E^.Dat.TiMeC;
        Kol     :=E^.Dat.Element[i].Kol;
        Str(StrToInt(E^.Dat.Element[i].Kol)*
            (StrToReal(E^.Dat.Element[i].New_R_Zena)-
            StrToReal(E^.Dat.Element[i].Bak_R_Zena))
		  :CIZena:CMantissa,Summa);
        SkladKod:=E^.Dat.SkladKod;
        Caption :=E^.Dat.Caption;
           End;
        If Not(SaveStatPereozenka(StatPrih)) Then
        MessageBox('Ошибка записи в файл '+E^.Dat.Element[i].BazKod,nil,mfError+mfCancelButton);
        {конец обновления информации в файле}

        {обновление количества и суммы в списке}
        EList^.List^.AtFree(Kol);
        EList^.SetRange(EList^.List^.Count);
        skol:=copy(temps,CPrz,CKol+2);
        Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
        Delete(Temps,CPrz,CKol+2+1);
        Insert(SKol+'│',Temps,CPrz);

        EList^.List^.Insert(NewStr(temps));
        EList^.SetRange(SelectNameList^.List^.Count);
         End;{if find}

    End;
  End;

 Dispose(StatPrih,Done);
 Dispose(e,Done);
 Close(Ef);
End;


Procedure CalcRwz(l:LongInt;Var EList:PBox);

Function SaveStatRewisia(sP: PStatTovarRwzType):Boolean;
var Es: File Of StatTovarrwzType;
    i : Word;
Begin
 Assign(es,Path.ToAnalys+Sp^.Dat.BazKod+'.rwz');
 i:=IOResult;
 Reset(es);
 i:=IOResult;
 If i<> 0 Then Exit;
 Seek(es,FileSize(es));
 Write(es,Sp^.DAt);
 Close(es);

End;

Var
   Kol,pos,Cur : LongInt;
   i : Word;
   Find : Boolean;
   E  : PRewisiaType;
   ef : RewisiaFileType;
   kol1,sum1,skol,ssum:AllStr;
   statPrih: PStatTovarRwzType;
   Artikul : ArtikulStr;
   temps : string[150];
Begin
 Assign(eF,Path.ToRewisia+DateToDAteString(DAteMask,L)+'.rwz');
 i:=IOResult;
 Reset(ef);
 i:=IOResult;
 If i<>0 Then Exit;

 New(E,Init);
 New(StatPrih,Init);

 While Not(Eof(ef)) Do
  Begin
   ReadRewisia(ef,E);
     kol1[0]:=#0;
     sum1[0]:=#0;
     If E^.Dat.Amount>0 Then

     For i:=1 To E^.Dat.Amount Do
      Begin
         Find:=False;
         For Kol:=0 To EList^.List^.Count-1 Do
          begin
           temps:=Copy(EList^.GetText(Kol,EList^.List^.Count),1+CNAme+1,CArtikul);
           {если нашли код и в накладной и списке}
           If TempS = E^.Dat.Element[i].BazKod Then
            Begin
             Find:=True;
             Str(StrToInt(Kol1)+StrToInt(E^.Dat.Element[i].Input.Kol):CKol+2,Kol1);
             Str(StrToReal(Sum1)+StrToInt(E^.Dat.Element[i].Input.Kol)*
                                 StrToReal(E^.Dat.Element[i].Input.R_Zena)
                                 :CIZena:CMantissa,Sum1);
             break;
            End;
          end;
        If Find Then
         Begin
          temps:=EList^.GetText(Kol,EList^.List^.Count);
        {обновляю информацию в файле}
          With StatPrih^.Dat Do
           Begin
        BazKod:=E^.Dat.Element[i].BazKod;
        Document:=E^.Dat.Document;
        DateC   :=E^.Dat.DateC;
        TimeC   :=E^.Dat.TiMeC;
        Kol     :=E^.Dat.Element[i].Input.Kol;
        Zena    :=E^.Dat.Element[i].Input.R_Zena;
        Str(StrToInt(E^.Dat.Element[i].Input.Kol)*
            StrToReal(E^.Dat.Element[i].Input.R_Zena)
		  :CIZena:CMantissa,Summa);
        SkladKod:=E^.Dat.SkladKod;
        Caption :=E^.Dat.Caption;

           {для ХЭППИ}
           End;
        If Not(SaveStatRewisia(StatPrih)) Then
        MessageBox('Ошибка записи в файл '+E^.Dat.Element[i].BazKod,nil,mfError+mfCancelButton);
        {конец обновления информации в файле}

        {обновление количества и суммы в списке}
        EList^.List^.AtFree(Kol);
        EList^.SetRange(EList^.List^.Count);
        skol:=copy(temps,CRwz,CKol+2);
        Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
        Delete(Temps,CRwz,CKol+2+1);
        Insert(SKol+'│',Temps,CRwz);

        EList^.List^.Insert(NewStr(temps));
        EList^.SetRange(SelectNameList^.List^.Count);
         End;{if find}

    End;
  End;

 Dispose(StatPrih,Done);
 Dispose(e,Done);
 Close(Ef);
End;



(*
Procedure CalcRwz(l:LongInt;Var EList:PBox);
Function SaveStatRewisia(sP: PStatTovarRwzType):Boolean;
var Es: File Of StatTovarrwzType;
    i : Word;
Begin
 Assign(es,Path.ToAnalys+Sp^.Dat.BazKod+'.rwz');
 i:=IOResult;
 Reset(es);
 i:=IOResult;
 If i<> 0 Then Exit;
 Seek(es,FileSize(es));
 Write(es,Sp^.DAt);
 Close(es);

End;

Var
   Kol,pos,Cur : LongInt;
   i : Word;
   Find : Boolean;
   E  : PRewisiaType;
   ef : RewisiaFileType;
   kol1,sum1,skol,ssum:AllStr;
   statPrih: PStatTovarRwzType;
   Artikul : ArtikulStr;
   temps : string[150];
Begin
 Assign(eF,Path.ToRewisia+DateToDAteString(DAteMask,L)+'.rwz');
 i:=IOResult;
 Reset(ef);
 i:=IOResult;
 If i<>0 Then Exit;

 New(E,Init);
 New(StatPrih,Init);

 While Not(Eof(ef)) Do
  Begin
   ReadRewisia(ef,E);
     kol1[0]:=#0;
     sum1[0]:=#0;
     If E^.Dat.Amount>0 Then

     For i:=1 To E^.Dat.Amount Do
      Begin
         Find:=False;
         For Kol:=0 To EList^.List^.Count-1 Do
          begin
           temps:=Copy(EList^.GetText(Kol,EList^.List^.Count),1+CNAme+1,CArtikul);
           {если нашли код и в накладной и списке}
           If TempS = E^.Dat.Element[i].BazKod Then
            Begin
             Find:=True;
             Str(StrToInt(Kol1)+StrToInt(E^.Dat.Element[i].Input.Kol):CKol+2,Kol1);
             Str(StrToReal(Sum1)+StrToInt(E^.Dat.Element[i].Input.Kol)*
                                 StrToReal(E^.Dat.Element[i].Input.R_Zena)
                                 :CIZena:CMantissa,Sum1);
             break;
            End;
          end;
        If Find Then
         Begin
          temps:=EList^.GetText(Kol,EList^.List^.Count);
        {обновляю информацию в файле}
          With StatPrih^.Dat Do
           Begin
        BazKod:=E^.Dat.Element[i].BazKod;
        Document:=E^.Dat.Document;
        DateC   :=E^.Dat.DateC;
        TimeC   :=E^.Dat.TiMeC;
        Kol     :=E^.Dat.Element[i].Input.Kol;
        Str(StrToInt(E^.Dat.Element[i].Input.Kol)*
            StrToReal(E^.Dat.Element[i].Input.R_Zena)
		  :CIZena:CMantissa,Summa);
        SkladKod:=E^.Dat.SkladKod;
        Caption :=E^.Dat.Caption;

           {для ХЭППИ}
           End;
        If Not(SaveStatRewisia(StatPrih)) Then
        MessageBox('Ошибка записи в файл '+E^.Dat.Element[i].BazKod,nil,mfError+mfCancelButton);
        {конец обновления информации в файле}

        {обновление количества и суммы в списке}
        EList^.List^.AtFree(Kol);
        EList^.SetRange(EList^.List^.Count);
        skol:=copy(temps,CRwz,CKol+2);
        Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
        Delete(Temps,CRwz,CKol+2+1);
        Insert(SKol+'│',Temps,CRwz);

        EList^.List^.Insert(NewStr(temps));
        EList^.SetRange(SelectNameList^.List^.Count);
         End;{if find}

    End;
  End;

 Dispose(StatPrih,Done);
 Dispose(e,Done);
 Close(Ef);
End;
*)


procedure MakeFile(Const VarList:PBox);
Var
   Cur : LongInt;
      F: File;
      I : Byte;
  Artikul : ArtikulStr;
Begin
 For cur:=0 To VarList^.List^.Count-1 Do
  Begin
   Artikul:=Copy(VarList^.GetText(cur,VarList^.List^.Count),1+CNAme+1,CArtikul);
   DInfoMsg('Создаю временные файлы для позиции '+artikul+'...');

   {приход}
   If SVidOperation[1]=1 Then
    Begin
       Assign(f,Path.ToAnalys+Artikul+'.prh');
       i:=IOResult;
       Rewrite(f);
       i:=IOResult;
       If I<>0 Then
	   MessageBox(^M+#3+'Ошибка создания файла '+Path.ToAnalys+Artikul+'.prh'+
	   ClicProgrammer,nil,mfError+mfCancelButton)
        Else Close(f);
    End;{конец прихода}

   {переоценка}
   If SVidOperation[4]=1 Then
    Begin
       Assign(f,Path.ToAnalys+Artikul+'.prz');
       i:=IOResult;
       Rewrite(f);
       i:=IOResult;
       If I<>0 Then
	   MessageBox(^M+#3+'Ошибка создания файла '+Path.ToAnalys+Artikul+'.prz'+
	   ClicProgrammer,nil,mfError+mfCancelButton)
        Else Close(f);
    End;{конец прихода}

   {ревизия}
   If SVidOperation[5]=1 Then
    Begin
       Assign(f,Path.ToAnalys+Artikul+'.rwz');
       i:=IOResult;
       Rewrite(f);
       i:=IOResult;
       If I<>0 Then
	   MessageBox(^M+#3+'Ошибка создания файла '+Path.ToAnalys+Artikul+'.rwz'+
	   ClicProgrammer,nil,mfError+mfCancelButton)
        Else Close(f);
    End;{конец ревизии}

   {рп}
   If SVidOperation[6]=1 Then
    Begin
       Assign(f,Path.ToAnalys+Artikul+'.rp');
       i:=IOResult;
       Rewrite(f);
       i:=IOResult;
       If I<>0 Then
	   MessageBox(^M+#3+'Ошибка создания файла '+Path.ToAnalys+Artikul+'.rp'+
	   ClicProgrammer,nil,mfError+mfCancelButton)
        Else Close(f);
    End;{конец рп}


   {продажа}
   If SVidOperation[2]=1 Then
    Begin
       Assign(f,Path.ToAnalys+Artikul+'.mrk');
       i:=IOResult;
       Rewrite(f);
       i:=IOResult;
       If I<>0 Then
	   MessageBox(^M+#3+'Ошибка создания файла '+Path.ToAnalys+Artikul+'.mrk'+
	   ClicProgrammer,nil,mfError+mfCancelButton)
        Else Close(f);
    End;{конец продажи}

   {возврат}
   If SVidOperation[3]=1 Then
    Begin
       Assign(f,Path.ToAnalys+Artikul+'.vzw');
       i:=IOResult;
       Rewrite(f);
       i:=IOResult;
       If I<>0 Then
	   MessageBox(^M+#3+'Ошибка создания файла '+Path.ToAnalys+Artikul+'.vzw'+
	   ClicProgrammer,nil,mfError+mfCancelButton)
        Else Close(f);
    End;{конец возврата}
   NoInfoMsg;
  End;
End;

procedure EraseFile(Const VarList:PBox);
Var
   Cur : LongInt;
      F: File;
      I : Byte;
  Artikul : ArtikulStr;
Begin
 For cur:=0 To VarList^.List^.Count-1 Do
  Begin
   Artikul:=Copy(VarList^.GetText(cur,VarList^.List^.Count),1+CNAme+1,CArtikul);

   {приход}
   If SVidOperation[1]=1 Then
    Begin
       Assign(f,Path.ToAnalys+Artikul+'.prh');
       i:=IOResult;
       Erase(f);
       i:=IOResult;
       If I<>0 Then
	   MessageBox(^M+#3+'Ошибка удаления файла '+Path.ToAnalys+Artikul+'.prh'+
	   ClicProgrammer,nil,mfError+mfCancelButton)
        Else Close(f);
    End;{конец прихода}

   {переоценка}
   If SVidOperation[4]=1 Then
    Begin
       Assign(f,Path.ToAnalys+Artikul+'.prz');
       i:=IOResult;
       Erase(f);
       i:=IOResult;
       If I<>0 Then
	   MessageBox(^M+#3+'Ошибка удаления файла '+Path.ToAnalys+Artikul+'.prz'+
	   ClicProgrammer,nil,mfError+mfCancelButton)
        Else Close(f);
    End;{конец прихода}

   {ревизия}
   If SVidOperation[5]=1 Then
    Begin
       Assign(f,Path.ToAnalys+Artikul+'.rwz');
       i:=IOResult;
       Erase(f);
       i:=IOResult;
       If I<>0 Then
	   MessageBox(^M+#3+'Ошибка удаления файла '+Path.ToAnalys+Artikul+'.rwz'+
	   ClicProgrammer,nil,mfError+mfCancelButton)
        Else Close(f);
    End;{конец ревизии}

   {рп}
   If SVidOperation[6]=1 Then
    Begin
       Assign(f,Path.ToAnalys+Artikul+'.rp');
       i:=IOResult;
       Erase(f);
       i:=IOResult;
       If I<>0 Then
	   MessageBox(^M+#3+'Ошибка удаления файла '+Path.ToAnalys+Artikul+'.rp'+
	   ClicProgrammer,nil,mfError+mfCancelButton)
        Else Close(f);
    End;{конец рп}


   {продажа}
   If SVidOperation[2]=1 Then
    Begin
       Assign(f,Path.ToAnalys+Artikul+'.mrk');
       i:=IOResult;
       Erase(f);
       i:=IOResult;
       If I<>0 Then
	   MessageBox(^M+#3+'Ошибка удаления файла '+Path.ToAnalys+Artikul+'.mrk'+
	   ClicProgrammer,nil,mfError+mfCancelButton)
        Else Close(f);
    End;{конец продажи}

   {возврат}
   If SVidOperation[3]=1 Then
    Begin
       Assign(f,Path.ToAnalys+Artikul+'.vzw');
		 i:=IOResult;
		 Erase(f);
		 i:=IOResult;
		 If I<>0 Then
		MessageBox(^M+#3+'Ошибка удаления файла '+Path.ToAnalys+Artikul+'.vzw'+
		ClicProgrammer,nil,mfError+mfCancelButton)
		  Else Close(f);
	 End;{конец возврата}
  End;
End;



procedure TCalcTovarWindow.Start(Const VarList:PBox);
Var R   : TRect;
    Cur : LongInt;
    s   : string[150];
    wsd : TDateString;
Begin
 WordToBit6(OperationFiltr,SVidOperation);
 Convert6(SVidOperation);
 WordToBit3(OperationToV,SClient);
 Convert3(SClient);

 DisableCommands([cmPrihC,cmPrihS,cmPrihB,cmMrkC,cmMrkS,cmMrkB,cmReturnC,cmReturnS,
                  cmPrz,cmRwz,cmRP]);

 If SVidOperation[1]=1 Then
 Begin
  If SClient[1]=1 Then
   EnableCommands([cmPrihC]);
  If SClient[2]=1 Then
   EnableCommands([cmPrihS]);
  If SClient[3]=1 Then
   EnableCommands([cmPrihB]);
 End;

 If SVidOperation[2]=1 Then
 Begin
  If SClient[1]=1 Then
   EnableCommands([cmMrkC]);
  If SClient[2]=1 Then
   EnableCommands([cmMrkS]);
  If SClient[3]=1 Then
   EnableCommands([cmMrkB]);
 End;

 If SVidOperation[3]=1 Then
 Begin
  If SClient[1]=1 Then
   EnableCommands([cmReturnC]);
  If SClient[2]=1 Then
   EnableCommands([cmReturnS]);
 End;

 If SVidOperation[4]=1 Then EnableCommands([cmPRZ]);

 If SVidOperation[5]=1 Then EnableCommands([cmRwz]);

 If SVidOperation[6]=1 Then EnableCommands([cmRp]);


{
 If SClient[1]=0 Then
  DisableCommands([cmPrihC,cmMrkC,cmReturnC])
 Else
  EnableCommands([cmPrihC,cmMrkC,cmReturnC]);


 If SClient[2]=0 Then
  DisableCommands([cmPrihS,cmMrkS,cmReturnS])
 Else
   EnableCommands([cmPrihS,cmMrkS,cmReturnS]);

 If SVidOperation[1]=0 Then
  DisableCommands([cmPrihC,cmPrihS])
 Else

  EnableCommands([cmPrihC,cmPrihS]);
}





 WordToBit9(Filtr,SVidDocTov);
 Convert9(SVidDocTov);
 WordToBit2(OplataToV,SStatusOplata);
 Convert2(SStatusOplata);
 LStart:=DateStringToDate(DateMask,StartDatetov);
 LStop :=DateStringToDate(DateMask ,StopDatetov);

 {формирование списка товаров участвующих в выборке}
 R.Assign (0,0,0,0);
 NoScreenList := New(PBox, Init(R, 1, Nil));
 NoScreenList^.NewList(New(PTextCollection, Init(0,1)));
 For cur:=0 To VarList^.List^.Count-1 Do
  Begin
   s:=VarList^.GetText(cur,VarList^.List^.Count);
   s:=Copy(s,1,CName+1+CArtikul+1);
         {п клиент} {п склад} {п обмен}
   s:=s+'      0│'+'      0│'+'      0│'+
         {о клиент}{о склад}  {о обмен}
		 +'      0│'+'      0│'+'      0│'+
         {возврат клиент}            {возврат склад}
       +'      0│'+'      0│'
	    {переоценка}                {ревизия}
       +'      0│'+'      0│'
         {РП}
       +'      0│';

   NoScreenList^.List^.Insert(NewStr(s));
   NoScreenList^.SetRange(NoScreenList^.List^.Count);
  End;

 MakeFile(NoScreenList);


 For cur:=Lstart To LStop Do
  Begin
   DInfoMsg('Просматриваю операции за '+DateToDateString(DateMask,Cur)+'...');
   if svidoperation[1]=1 Then CalcPrihod(cur,NoScreenList);
   if svidoperation[2]=1 Then CalcMrk(cur,NoScreenList);
   if svidoperation[3]=1 Then CalcReturn(cur,NoScreenList);
   If(svidoperation[4]=1) AND (sClient[2]=1)Then CalcPrz   (cur,NoScreenList);
   If(svidoperation[5]=1) AND (sClient[2]=1)Then CalcRwz   (cur,NoScreenList);
   If(svidoperation[6]=1) AND (sClient[2]=1)Then CalcRp   (cur,NoScreenList);
{   CalcRP    (cur,NoScreenList);}
   NoInfoMsg;
  End;

 R.Assign(0, 0, 78, 23);
 New(CalcTWindow, Init(R, 'Движение товара за период с '+StartDatetov+' по '+StopDatetov));
 CalcTWindow^.Options := CalcTWindow^.Options or ofCenterX;
 CalcTWindow^.HelpCtx:=$E002;

 R.Assign(34, 2, 35, 19);
Control1 := New(PScrollBar, Init(R));
CalcTWindow^.Insert(Control1);

R.Assign(1, 2, 34, 19);
ScreenList := New(PBox, Init(R, 1, PScrollbar(Control1)));
ScreenList^.NewList(New(PTextCollection, Init(0,1)));

 For cur:=0 To NoScreenList^.List^.Count-1 Do
  Begin
   s:=NoScreenList^.GetText(cur,NoScreenList^.List^.Count);
   ScreenList^.List^.Insert(NewStr(s));
	ScreenList^.SetRange(NoScreenList^.List^.Count);
  End;
ScreenList^.FocusItem(0);
ScreenList^.HelpCtx:=$F071;
CalcTWindow^.Insert(ScreenList);

  R.Assign(1, 1, 34, 2);
  CalcTWindow^.Insert(New(PLabel, Init(R, 'Н~а~именование товара         Код ', ScreenList)));

R.Assign(36, 2, 63, 4);
ControlSorting := New(PRadioButtons, Init(R,
  NewSItem('~Н~аименование',
  NewSItem('~Р~аздел',
  NewSItem('К~о~д', Nil)))));
ControlSorting^.Options := ControlSorting^.Options or ofFramed;
CalcTWindow^.Insert(ControlSorting);
Sort:=0;
ControlSorting^.SetDAta(Sort);

  R.Assign(36, 1, 48, 2);
  CalcTWindow^.Insert(New(PLabel, Init(R, 'Сорт~и~ровка:', ControlSorting)));

R.Assign(65, 2, 76, 4);
ControlDirection := New(PRadioButtons, Init(R,
  NewSItem(#30,
  NewSItem(#31, Nil))));
ControlDirection^.Options := ControlDirection^.Options or ofFramed;
CalcTWindow^.Insert(ControlDirection);
Direction:=0;
ControlDirection^.SetDAta(Direction);

  R.Assign(65, 1, 70, 2);
  CalcTWindow^.Insert(New(PLabel, Init(R, '~Т~ип:', ControlDirection)));

R.Assign(36, 5, 76, 8);
Control1 := New(PColoredText, Init(R, '', $70));
Control1^.Options := Control1^.Options or ofFramed;
CalcTWindow^.Insert(Control1);

R.Assign(36, 5, 54, 6);
Control1 := New(PColoredText, Init(R, 'Приход (Клиент)  :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(36, 6, 54, 7);
Control1 := New(PColoredText, Init(R, 'Приход (Склад)   :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(36, 7, 54, 8);
Control1 := New(PColoredText, Init(R, 'Приход (Обмен)   :', $74));
CalcTWindow^.Insert(Control1);


R.Assign(54, 4, 76, 5);
ControlPrihC := New(PColoredText, Init(R, '      0', $7E));
CalcTWindow^.Insert(ControlPrihC);

R.Assign(54, 5, 76, 6);
ControlPrihS := New(PColoredText, Init(R, '      0', $7E));
CalcTWindow^.Insert(ControlPrihS);

R.Assign(54, 6, 76, 7);
ControlPrihB := New(PColoredText, Init(R, '      0', $7E));
CalcTWindow^.Insert(ControlPrihB);

{отгрузка}
R.Assign(36, 9, 76, 12);
Control1 := New(PColoredText, Init(R, '', $70));
Control1^.Options := Control1^.Options or ofFramed;
CalcTWindow^.Insert(Control1);

R.Assign(36, 9, 54, 10);
Control1 := New(PColoredText, Init(R, 'Отгрузка (Клиент):', $74));
CalcTWindow^.Insert(Control1);

R.Assign(36, 10, 54, 11);
Control1 := New(PColoredText, Init(R, 'Отгрузка (Склад) :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(36, 11, 54,12);
Control1 := New(PColoredText, Init(R, 'Отгрузка (Обмен) :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(54, 9, 71, 10);
ControlMrkC := New(PColoredText, Init(R, '      0', $7E));
CalcTWindow^.Insert(ControlMrkC);

R.Assign(54, 10, 71, 11);
ControlMrkS := New(PColoredText, Init(R, '      0', $7E));
CalcTWindow^.Insert(ControlMrkS);

R.Assign(54, 11, 71, 12);
ControlMrkB := New(PColoredText, Init(R, '      0', $7E));
CalcTWindow^.Insert(ControlMrkB);



{возврат}
R.Assign(36, 13, 76, 15);
Control1 := New(PColoredText, Init(R, '', $70));
Control1^.Options := Control1^.Options or ofFramed;
CalcTWindow^.Insert(Control1);

R.Assign(36, 14, 54, 15);
Control1 := New(PColoredText, Init(R, 'Возврат (Склад)  :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(36, 13, 54, 14);
Control1 := New(PColoredText, Init(R, 'Возврат (Клиент) :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(54, 13, 71, 14);
ControlReturnC := New(PColoredText, Init(R, '      0', $7E));
CalcTWindow^.Insert(ControlReturnC);

R.Assign(54, 14, 71, 15);
ControlReturnS := New(PColoredText, Init(R, '      0', $7E));
CalcTWindow^.Insert(ControlReturnS);


R.Assign(36, 16, 76, 17);
Control1 := New(PColoredText, Init(R, '', $70));
Control1^.Options := Control1^.Options or ofFramed;
CalcTWindow^.Insert(Control1);

R.Assign(36, 16, 54, 17);
Control1 := New(PColoredText, Init(R, 'Ревизия          :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(54, 16, 71, 17);
ControlRwz := New(PColoredText, Init(R, '      0', $7E));
CalcTWindow^.Insert(ControlRwz);


R.Assign(36, 18, 76, 19);
Control1 := New(PColoredText, Init(R, '', $70));
Control1^.Options := Control1^.Options or ofFramed;
CalcTWindow^.Insert(Control1);

R.Assign(36, 18, 54, 19);
Control1 := New(PColoredText, Init(R, 'Переоценка       :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(54, 18, 71, 19);
ControlPrz := New(PColoredText, Init(R, '      0', $7E));
CalcTWindow^.Insert(ControlPrz);


R.Assign(36, 20, 76, 21);
Control1 := New(PColoredText, Init(R, '', $70));
Control1^.Options := Control1^.Options or ofFramed;
CalcTWindow^.Insert(Control1);

R.Assign(36, 20, 54, 21);
Control1 := New(PColoredText, Init(R, 'Р/П              :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(54, 20, 71, 21);
ControlRp := New(PColoredText, Init(R, '      0', $7E));
CalcTWindow^.Insert(ControlRp);

R.Assign(2, 19, 22, 20);
wsd:=DateToDateString(DateMask,DateStringToDate(DateMask,SStartTov)-1);
Control1 := New(PColoredText, Init(R, 'Остаток на '+Wsd{SStartTov}+':', $74));
CalcTWindow^.Insert(Control1);


R.Assign(2, 20, 22, 21);
Control1 := New(PColoredText, Init(R, 'Остаток на '+SStopTov+':', $74));
CalcTWindow^.Insert(Control1);

R.Assign(22, 19, 27, 20);
ControlStartOst := New(PColoredText, Init(R, #3+'0', $74));
CalcTWindow^.Insert(ControlStartOst);

R.Assign(22, 20, 27, 21);
ControlStopOst := New(PColoredText, Init(R, #3+'0', $74));
CalcTWindow^.Insert(ControlStopOst);


R.Assign(1, 22, 23, 23);
Control1 := New(PColoredText, Init(R, ' Наименование товара:', $74));
CalcTWindow^.Insert(Control1);

R.Assign(23, 22, 23, 23);
ControlFullName2 := New(PColoredText, Init(R, ' ', $7e));
CalcTWindow^.Insert(ControlFullName2);





 CalcTWindow^.SelectNext(False);
 PrevCurLoc[0]:=#0;
 PrevName[0]:=#0;
 Desktop^.ExecView(CalcTWindow);

 DInfoMsg('Удаляю временные файлы...');
 EraseFile(NoScreenList);
 NoInfoMsg;

 Dispose(NoScreenList,Done);
 Dispose(ControlSorting,Done);
 Dispose(ControlFullName2,Done);
 Dispose(ControlDirection,Done);
 Dispose(Control1,Done);
 Dispose(ScreenList,Done);

 Dispose(CAlcTWindow,Done);
End;





procedure TCalcTovarWindow.DrawCurrent;
Var R   : TRect;
	 Kol : AllStr;
	 Pack : AllStr;
      TestStr : string[150];
	 BArt : ArtikulStr;
	 Minus:Boolean;
	 Fas : ArtikulStr;
Begin
If ScreenList^.List^.Count>0 Then
Begin
PrevCurLoc:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);
Dispose(ControlPrihC,Done);
R.Assign(54, 5, 76, 6);
BArt:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),1+CNAme+1,CArtikul);
Fas:=GetIdField(FInPack,BArt);
DelSpace(Fas);
TestStr:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CPrihC,CKol+2);
TestStr[8]:=' ';

Minus:=False;
If Pos('-',TestStr)>0 Then
 Begin
  Minus:=True;
  System.Delete(TestStr,Pos('-',TestStr),1);
 End;
Pack:=CalcPackNoFile(Fas,TestStr);
DelSpace(Pack);
RFormat(Pack,CPAck);
PAck:='('+Pack+')';
If Minus Then
  Begin
	DelSpace(TestStr);
   TestStr:='-'+TestStr;
   RFormat(TestStr,CKol+2);
   PAck:='-'+Pack;
  End
 Else PAck:=' '+Pack;

If (svidOperation[1]=1) And (SClient[1]=1) Then
ControlPrihC := New(PColoredText, Init(R, TestStr+'   '+Pack, $7E))
Else
ControlPrihC := New(PColoredText, Init(R, TestStr+'   '+Pack, $78));
CalcTWindow^.Insert(ControlPrihC);


Dispose(ControlPrihS,Done);
R.Assign(54, 6, 76, 7);
TestStr:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CPrihS,CKol+2);
TestStr[8]:=' ';


Minus:=False;
If Pos('-',TestStr)>0 Then
 Begin
  Minus:=True;
  System.Delete(TestStr,Pos('-',TestStr),1);
 End;
Pack:=CalcPackNoFile(Fas,TestStr);
DelSpace(Pack);
RFormat(Pack,CPAck);
PAck:='('+Pack+')';
If Minus Then
  Begin
   DelSpace(TestStr);
   TestStr:='-'+TestStr;
   RFormat(TestStr,CKol+2);
	PAck:='-'+Pack;
  End
 Else PAck:=' '+Pack;

If (svidOperation[1]=1) And (SClient[2]=1) Then
ControlPrihS := New(PColoredText, Init(R, TestStr+'   '+Pack, $7E))
Else
ControlPrihS := New(PColoredText, Init(R, TestStr+'   '+Pack, $78));
CalcTWindow^.Insert(ControlPrihS);

Dispose(ControlPrihB,Done);
R.Assign(54, 7, 76, 8);
TestStr:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CPrihB,CKol+2);
TestStr[8]:=' ';

Minus:=False;
If Pos('-',TestStr)>0 Then
 Begin
  Minus:=True;
  System.Delete(TestStr,Pos('-',TestStr),1);
 End;
Pack:=CalcPackNoFile(Fas,TestStr);
DelSpace(Pack);
RFormat(Pack,CPAck);
PAck:='('+Pack+')';
If Minus Then
  Begin
   DelSpace(TestStr);
   TestStr:='-'+TestStr;
   RFormat(TestStr,CKol+2);
   PAck:='-'+Pack;
  End
 Else PAck:=' '+Pack;

If (svidOperation[1]=1) And (SClient[3]=1) Then
ControlPrihB := New(PColoredText, Init(R, TestStr+'   '+Pack, $7E))
Else
ControlPrihB := New(PColoredText, Init(R, TestStr+'   '+Pack, $78));
CalcTWindow^.Insert(ControlPrihB);


Dispose(ControlreturnC,Done);
R.Assign(54, 13, 76, 14);
TestStr:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CReturnC,CKol+2);
TestStr[8]:=' ';

Minus:=False;
If Pos('-',TestStr)>0 Then
 Begin
  Minus:=True;
  System.Delete(TestStr,Pos('-',TestStr),1);
 End;
Pack:=CalcPackNoFile(Fas,TestStr);
DelSpace(Pack);
RFormat(Pack,CPAck);
PAck:='('+Pack+')';
If Minus Then
  Begin
   DelSpace(TestStr);
   TestStr:='-'+TestStr;
   RFormat(TestStr,CKol+2);
   PAck:='-'+Pack;
  End
 Else PAck:=' '+Pack;

If (svidOperation[3]=1) And (SClient[1]=1) Then
ControlReturnC := New(PColoredText, Init(R, TestStr+'   '+Pack, $7e))
Else
ControlReturnC := New(PColoredText, Init(R, TestStr+'   '+Pack, $78));
CalcTWindow^.Insert(ControlReturnC);

Dispose(ControlreturnS,Done);
R.Assign(54, 14, 76, 15);
TestStr:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);
TestStr:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CReturnS,CKol+2);
TestStr[8]:=' ';

Minus:=False;
If Pos('-',TestStr)>0 Then
 Begin
  Minus:=True;
  System.Delete(TestStr,Pos('-',TestStr),1);
 End;
Pack:=CalcPackNoFile(Fas,TestStr);
DelSpace(Pack);
RFormat(Pack,CPAck);
PAck:='('+Pack+')';
If Minus Then
  Begin
   DelSpace(TestStr);
   TestStr:='-'+TestStr;
   RFormat(TestStr,CKol+2);
   PAck:='-'+Pack;
  End
 Else PAck:=' '+Pack;

If (svidOperation[3]=1) And (SClient[2]=1) Then
ControlReturnS := New(PColoredText, Init(R, TestStr+'   '+Pack, $7e))
Else
ControlReturnS := New(PColoredText, Init(R, TestStr+'   '+Pack, $78));

CalcTWindow^.Insert(ControlReturnS);


Dispose(ControlMrkC,Done);
R.Assign(54, 9, 76, 10);
TestStr:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CMrkC,CKol+2);
TestStr[8]:=' ';

Minus:=False;
If Pos('-',TestStr)>0 Then
 Begin
  Minus:=True;
  System.Delete(TestStr,Pos('-',TestStr),1);
 End;
Pack:=CalcPackNoFile(Fas,TestStr);
DelSpace(Pack);
RFormat(Pack,CPAck);
PAck:='('+Pack+')';
If Minus Then
  Begin
   DelSpace(TestStr);
   TestStr:='-'+TestStr;
   RFormat(TestStr,CKol+2);
   PAck:='-'+Pack;
  End
 Else PAck:=' '+Pack;

If (svidOperation[2]=1) And (SClient[1]=1) Then
ControlMrkC := New(PColoredText, Init(R, TestStr+'   '+Pack, $7e))
Else
ControlMrkC := New(PColoredText, Init(R, TestStr+'   '+Pack, $78));
CalcTWindow^.Insert(ControlMrkC);

Dispose(ControlMrkS,Done);
R.Assign(54, 10, 76, 11);
TestStr:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CMrkS,CKol+2);
TestStr[8]:=' ';

Minus:=False;
If Pos('-',TestStr)>0 Then
 Begin
  Minus:=True;
  System.Delete(TestStr,Pos('-',TestStr),1);
 End;
Pack:=CalcPackNoFile(Fas,TestStr);
DelSpace(Pack);
RFormat(Pack,CPAck);
PAck:='('+Pack+')';
If Minus Then
  Begin
   DelSpace(TestStr);
   TestStr:='-'+TestStr;
   RFormat(TestStr,CKol+2);
   PAck:='-'+Pack;
  End
 Else PAck:=' '+Pack;

If (svidOperation[2]=1) And (SClient[2]=1) Then
ControlMrkS := New(PColoredText, Init(R, TestStr+'   '+Pack, $7e))
Else
ControlMrkS := New(PColoredText, Init(R, TestStr+'   '+PAck, $78));
CalcTWindow^.Insert(ControlMrkS);

Dispose(ControlMrkB,Done);
R.Assign(54, 11, 76, 12);
TestStr:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CMrkB,CKol+2);
TestStr[8]:=' ';

Minus:=False;
If Pos('-',TestStr)>0 Then
 Begin
  Minus:=True;
  System.Delete(TestStr,Pos('-',TestStr),1);
 End;
Pack:=CalcPackNoFile(Fas,TestStr);
DelSpace(Pack);
RFormat(Pack,CPAck);
PAck:='('+Pack+')';
If Minus Then
  Begin
   DelSpace(TestStr);
   TestStr:='-'+TestStr;
   RFormat(TestStr,CKol+2);
   PAck:='-'+Pack;
  End
 Else PAck:=' '+Pack;

If (svidOperation[2]=1) And (SClient[3]=1) Then
ControlMrkB := New(PColoredText, Init(R, TestStr+'   '+Pack, $7e))
Else
ControlMrkB := New(PColoredText, Init(R, TestStr+'   '+Pack, $78));
CalcTWindow^.Insert(ControlMrkB);

Dispose(ControlPrz,Done);
R.Assign(54, 18, 76, 19);
TestStr:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CPrz,CKol+2);
TestStr[8]:=' ';


Minus:=False;
If Pos('-',TestStr)>0 Then
 Begin
  Minus:=True;
  System.Delete(TestStr,Pos('-',TestStr),1);
 End;
Pack:=CalcPackNoFile(Fas,TestStr);
DelSpace(Pack);
RFormat(Pack,CPAck);
PAck:='('+Pack+')';
If Minus Then
  Begin
   DelSpace(TestStr);
   TestStr:='-'+TestStr;
   RFormat(TestStr,CKol+2);
   PAck:='-'+Pack;
  End
 Else PAck:=' '+Pack;

If (svidOperation[4]=1) And (SClient[2]=1) Then
ControlPrz := New(PColoredText, Init(R, TestStr+'   '+Pack, $7e))
Else
ControlPrz := New(PColoredText, Init(R, TestStr+'   '+Pack, $78));
CalcTWindow^.Insert(ControlPrz);

Dispose(Controlrwz,Done);
R.Assign(54, 16, 76, 17);
TestStr:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CRwz,CKol+2);
TestStr[8]:=' ';



Minus:=False;
If Pos('-',TestStr)>0 Then
 Begin
  Minus:=True;
  System.Delete(TestStr,Pos('-',TestStr),1);
 End;


Pack:=CalcPackNoFile(Fas,TestStr);

DelSpace(Pack);
RFormat(Pack,CPAck);
PAck:='('+Pack+')';
If Minus Then
  Begin
   DelSpace(TestStr);
   TestStr:='-'+TestStr;
   RFormat(TestStr,CKol+2);
   PAck:='-'+Pack;
  End
 Else PAck:=' '+Pack;

If (svidOperation[5]=1) And (SClient[2]=1) Then
ControlRwz := New(PColoredText, Init(R, TestStr+'   '+Pack, $7e))
Else
ControlRwz := New(PColoredText, Init(R, TestStr+'   '+Pack, $78));

CalcTWindow^.Insert(ControlRwz);

Dispose(ControlRp,Done);
R.Assign(54, 20, 76, 21);
TestStr:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CRp,CKol+2);
TestStr[8]:=' ';

Minus:=False;
If Pos('-',TestStr)>0 Then
 Begin
  Minus:=True;
  System.Delete(TestStr,Pos('-',TestStr),1);
 End;
Pack:=CalcPackNoFile(Fas,TestStr);
DelSpace(Pack);
RFormat(Pack,CPAck);
PAck:='('+Pack+')';
If Minus Then
  Begin
   DelSpace(TestStr);
   TestStr:='-'+TestStr;
   RFormat(TestStr,CKol+2);
   PAck:='-'+Pack;
  End
 Else PAck:=' '+Pack;

If (svidOperation[6]=1) And (SClient[2]=1) Then
ControlRp := New(PColoredText, Init(R, TestStr+'   '+Pack, $7E))
Else
ControlRp := New(PColoredText, Init(R, TestStr+'   '+Pack, $78));
CalcTWindow^.Insert(ControlRp);

DInfoMsg('Определяю остатки товара на складе...');


TestStr:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);

TestStr:=Copy(TestStr,1+CNAme+1,CArtikul);
GetKolFromOstat(DateToDateString(DateMask,DateStringToDate(DateMask,SStartTov)-1),TestStr,TestStr);
Dispose(ControlStartOst,Done);
R.Assign(22, 19, 27, 20);
ControlStartOst := New(PColoredText, Init(R, #3+TestStr, $7e));
CalcTWindow^.Insert(ControlStartOst);

TestStr:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);
TestStr:=Copy(TestStr,1+CNAme+1,CArtikul);
GetKolFromOstat(SStopTov,TestStr,TestStr);
Dispose(ControlStopOst,Done);
R.Assign(22, 20, 27, 21);
ControlStopOst := New(PColoredText, Init(R, #3+TestStr, $7e));
CalcTWindow^.Insert(ControlStopOst);

PrevCurLoc:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);

NoInfoMsg;

End
Else
 Begin
Dispose(ControlPrihC,Done);
R.Assign(54, 5, 76, 6);
TestStr[0]:=#0;
PrevCurLoc[0]:=#0;
ControlPrihC := New(PColoredText, Init(R, TestStr+'    (        0)', $78));
CalcTWindow^.Insert(ControlPrihC);

Dispose(ControlPrihS,Done);
R.Assign(54, 6, 76, 7);
ControlPrihS := New(PColoredText, Init(R, TestStr+'    (        0)', $78));
CalcTWindow^.Insert(ControlPrihS);

Dispose(ControlPrihB,Done);
R.Assign(54, 7, 76, 8);
ControlPrihB := New(PColoredText, Init(R, TestStr+'    (        0)', $78));
CalcTWindow^.Insert(ControlPrihB);


Dispose(ControlreturnC,Done);
R.Assign(54, 13, 76, 14);
ControlReturnC := New(PColoredText, Init(R,TestStr+'    (        0)', $78));
CalcTWindow^.Insert(ControlReturnC);

Dispose(ControlreturnS,Done);
R.Assign(54, 14, 76, 15);
ControlReturnS := New(PColoredText, Init(R,TestStr+'    (        0)', $78));
CalcTWindow^.Insert(ControlReturnS);

Dispose(ControlPrz,Done);
R.Assign(54, 18, 76, 19);
ControlPrz := New(PColoredText, Init(R,TestStr+'    (        0)', $78));
CalcTWindow^.Insert(ControlPrz);

Dispose(Controlrwz,Done);
R.Assign(54, 16, 76, 17);
ControlRwz := New(PColoredText, Init(R,TestStr+'    (        0)', $78));
CalcTWindow^.Insert(ControlRwz);

Dispose(ControlMrkC,Done);
R.Assign(54, 8, 76, 9);
ControlMrkC := New(PColoredText, Init(R,TestStr+'    (        0)', $78));
CalcTWindow^.Insert(ControlMrkC);

Dispose(ControlMrkS,Done);
R.Assign(54, 9, 76, 10);
ControlMrkS := New(PColoredText, Init(R,TestStr+'    (        0)', $78));
CalcTWindow^.Insert(ControlMrkS);

Dispose(ControlMrkB,Done);
R.Assign(54, 11, 76, 12);
ControlMrkB := New(PColoredText, Init(R,TestStr+'    (        0)', $78));
CalcTWindow^.Insert(ControlMrkB);

Dispose(ControlRp,Done);
R.Assign(54, 20, 76, 21);
ControlRp := New(PColoredText, Init(R,TestStr+'    (        0)', $78));
CalcTWindow^.Insert(ControlRp);

Dispose(ControlStartOst,Done);
R.Assign(22, 19, 27, 20);
ControlStartOst := New(PColoredText, Init(R,TestStr+'    (        0)', $7e));
CalcTWindow^.Insert(ControlStartOst);

Dispose(ControlStopOst,Done);
R.Assign(22, 20, 27, 21);
ControlStopOst := New(PColoredText, Init(R,TestStr+'    (        0)', $7e));
CalcTWindow^.Insert(ControlStopOst);
 End;
Redraw;
End;



procedure TCalcTovarWindow.Refresh;
Var i,j : Word;
    ws,ws1 : string[150];
    TempBox : PBox;
    R : TRect;
Begin

R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

ScreenList^.NewList(Nil);
ScreenList^.NewList(New(PMyCollection, Init(0,1)));

DinfoMsg('Сортирую выборку...');

If Direction=1 Then
DistanationSorting:=False
Else
DistanationSorting:=True;


If NoScreenList^.List^.Count>0 Then
Begin
{формируем отсортированый список}
For j:=0 to NoScreenList^.List^.Count-1 Do
Begin
 ws:=NoScreenList^.GEtText(j,NoScreenList^.List^.Count);
Case Sort Of
{Наименование}
0:ws:=ws;
{Раздел}
1:Begin
   ws1:=Copy(ws,1+CName+1,CRazdelKod);
   System.Delete(ws,1+cName+1,CRazdelKod);
   ws:=ws1+ws;
  End;
{Код}
2:Begin
   ws1:=Copy(ws,1+CName+1,CArtikul);
   System.Delete(ws,1+cName+1,CArtikul);
   ws:=ws1+ws;
  End;
Else;
End;{CAse}
  TempBox^.List^.Insert(NewStr(ws));
  TempBox^.SetRange(TempBox^.List^.Count);
End;{for}


{форматируем сформированый список под экранную форму}
If TempBox^.List^.Count>0 Then
Begin
For j:=0 to TempBox^.List^.Count-1 Do
Begin
  ws:=TempBox^.GEtText(j,TempBox^.List^.Count);

Case Sort Of
{клиент}
0:ws:=ws;
{раздел}
1:Begin
   ws1:=Copy(ws,1,CRazdelKod);
   System.Delete(ws,1,CRazdelKod);
   System.Insert(ws1,ws,1+cName+1);
  End;
{код}
2:Begin
   ws1:=Copy(ws,1,CArtikul);
   System.Delete(ws,1,CArtikul);
   System.Insert(ws1,ws,1+cName+1);
  End;
Else;
End;{CAse}
  ScreenList^.List^.Insert(NewStr(ws));
  ScreenList^.SetRange(ScreenList^.List^.Count);
End;
End;
End;{if}


NoInfoMsg;

Dispose(TempBox,Done);

ScreenList^.FocusItem(0);
DistanationSorting:=True;
End;

procedure TCalcTovarWindow.FormReport(E:PBox);
Const Space='';
Var Txt : Text;
    k,c : Word;
    st,s,ws : string[150];
    Numer : ArtikulStr;
    R : TRect;
    Clientkod : String[cclientkod];
    PrKol,RetKol,OstStartKol,RewKol,
    OstStopKol,RPKol,ProdKol : TDateString;
Begin
 Assign(txt,Path.ToTemp+'stattvr.txt');
 c := IOResult;
 Rewrite(txt);
 c:=IoResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3+'Не могу создать файл '+Path.ToTemp+'stattvr.txt!',Nil,mfError+mfCancelButton);
   Exit;
  End;

 DInfoMsg('Формирую отчет. Ждите...');
 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-00');

 Writeln(txt,Space+'Включены в рассмотрение следующие виды операций:');
 Write(txt,Space);
 For c:=1 To Max3 Do
  Begin
   If SClient[c]=1 Then
    Case c Of
    1:Write(txt,' "Клиент" ');
	 2:Write(txt,' "Склад" ');
    3:Write(txt,' "Обмен" ');
    Else;
    End;
  End;
 Writeln(txt);
 Writeln(txt);

 If SClient[1]=1 Then
 Begin

 Writeln(txt,Space+'Включены в рассмотрение следующие виды документов отгрузки:');
 Write(txt,Space);

 For c:=1 To Max9 Do
  Begin
   If SVidDocTov[c]=1 Then
    Case c Of
    1:Write(txt,' "Список" ');
    2:Write(txt,' "Тов.Чек*" ');
    3:Write(txt,' "Физ.Л*" ');
    4:Write(txt,' "СФ*" ');
    5:Write(txt,' "СФ " ');
    6:Write(txt,' "Дебит*" ');
    7:Write(txt,' "Дебит СФ*" ');
    8:Write(txt,' "Дебит" ');
    9:Write(txt,' "Дебит СФ" ');
    Else;
    End;
  End;
 Writeln(txt);
 Writeln(txt);

 Writeln(txt,Space+'Включены в рассмотрение документы со статусом:');
 Write(txt,Space);
 For c:=1 To 2 Do
  Begin
   If SStatusOplata[c]=1 Then
    Case c Of
    1:Write(txt,' "Оплаченные" ');
    2:Write(txt,' "Не оплаченные" ');
    Else;
    End;
  End;
 Writeln(txt);
 Writeln(txt);
 End;

 Writeln(txt,Space+'               СПРАВКА О ДВИЖЕНИИ ТОВАРА ЗА ПЕРИОД С '+StartDAteTov+' ПО '+StopDAteTov);
Writeln(txt,Space+'------------------------------------------------------------------------------------');
Writeln(txt,Space+'Код  Наименование товара         Остат             Операции с товаров          Остат');
Writeln(txt,Space+'                                 '+Copy(DateToDateString(DateMask,DateStringToDate(DateMask,StartDateTov)-1)
,1,CKol)+'  Приход Продажа Возврат Ревизия   РП    '+
Copy(StopDateTov,1,CKol));
Writeln(txt,Space+'------------------------------------------------------------------------------------');

If E^.List^.Count>0 Then
Begin
 For c:=0 To E^.List^.Count-1 Do
 Begin
    ws := E^.GetText(c,E^.List^.Count);
    s:= ws;
    While Pos('│',ws)>0 Do
    Begin
     k:=Pos('│',ws);
     System.Delete(ws,k,1);
     System.Insert(' ',ws,k);
    End;{While}
    Numer:=Copy(ws,1+CNAme+1,CArtikul);
    s:=Numer;
    st:=Copy(ws,1,CNAme);
    s:=s+' '+st;

    PrKol[0]:=#0;
    RetKol[0]:=#0;
    OstStartKol[0]:=#0;
    RewKol[0]:=#0;
    OstStopKol[0]:=#0;
    RPKol[0]:=#0;
    ProdKol[0]:=#0;

    {остатки на начало}
    GetKolFromOstat(DateToDateString(DateMask,DateStringToDate(DateMask,SStartTov)-1),Numer,OstStartKol);
    RFormat(OstStartKol,CKol);
    s:=s+' '+OstStartKol;

    {приходы}
    Str(StrToInt(Copy(ws,CPrihc,CKol+2))+STrToInt(PrKol):CKol+2,PrKol);
    Str(StrToInt(Copy(ws,CPrihS,CKol+2))+STrToInt(PrKol):CKol+2,PrKol);
    Str(StrToInt(Copy(ws,CPrihB,CKol+2))+STrToInt(PrKol):CKol+2,PrKol);
	 s:=s+' '+PrKol;
    {продажи}
    Str(StrToInt(Copy(ws,CMrkc,CKol+2))+STrToInt(ProdKol):CKol+2,ProdKol);
    Str(StrToInt(Copy(ws,CMrkS,CKol+2))+STrToInt(ProdKol):CKol+2,ProdKol);
    Str(StrToInt(Copy(ws,CMrkB,CKol+2))+STrToInt(ProdKol):CKol+2,ProdKol);
    s:=s+' '+ProdKol;
    {возвраты}
    Str(StrToInt(Copy(ws,CReturnc,CKol+2))+STrToInt(RetKol):CKol+2,RetKol);
    Str(StrToInt(Copy(ws,CReturnS,CKol+2))+STrToInt(RetKol):CKol+2,RetKol);
    s:=s+' '+RetKol;
    {ревизии}
    Str(StrToInt(Copy(ws,CRwz,CKol+2))+STrToInt(RewKol):CKol+2,RewKol);
    s:=s+' '+RewKol;
    {РП}
	 Str(StrToInt(Copy(ws,CRP,CKol+2))+STrToInt(RPKol):CKol+2,RPKol);
    s:=s+' '+RPKol;
    {остатки на конец}
    GetKolFromOstat(DateToDateString(DateMask,DateStringToDate(DateMask,StopDateToV)),Numer,OstStopKol);
    RFormat(OstStopKol,CKol);
    s:=s+' '+OstStopKol;

    Writeln(txt,Space+s);
 End;{For}


End;{If}

Writeln(txt,Space);
Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt,Space+'====================================================================================');


 System.Close(txt);
 NoInfoMsg;
 Report(Path.ToTemp+'stattvr.txt','',1,False,False,false);
End;

Procedure CalcScreenList(Const P:PBox);
Var
   Kol,pos,Cur : LongInt;
   Find : Boolean;
   Es: File Of StatTovarMarketType;
   AllKol,AllZakupka,AllOplata,AllDohod:AllStr;
   statPrih: PStatTovarMarketType;
   Kod,Artikul : ArtikulStr;
   SumOpl : AllStr;
   c,i,k,j : Word;

  Dlg : PDialog;
  R : TRect;
  Control : PView;

Begin

R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));

If Not(SelectionAgent(Agent)) Then
 Begin
  Dispose(Agent,Done);
  Exit;
 End;




 AllKol[0]:=#0;
 AllZakupka[0]:=#0;
 AllOplata[0]:=#0;
 AllDohod[0]:=#0;
 If P^.List=Nil Then Exit;
 DInfoMsg('Минуточку...');
 If P^.List^.Count>0 Then
 For k:=0 To P^.List^.Count-1 Do
  Begin
   Kod:=Copy(P^.GetText(k,P^.List^.Count),1+CNAme+1,CArtikul);
   Assign(es,Path.ToAnalys+Kod+'.mrk');
   i:=IOResult;
   Reset(es);
   i:=IOResult;
   If i<> 0 Then Continue;
   New(statPrih,Init);
    While Not(Eof(es)) Do
     Begin
      Read(es,StatPrih^.DAt);
      If (TestAgent(StatPrih^.Dat.AgentKod)) Then
      Begin
      Str(StrToInt(AllKol)+StrToInt(StatPrih^.DAt.Kol):Ckol+2,AllKol);
      Str((StrToReal(AllZakupka)+StrToReal(StatPrih^.DAt.SummaZakupka)):CIZena:CMAntissa,AllZakupka);
      Str(StrToReal(AllOplata)+StrToReal(StatPrih^.DAt.SummaZ):CIZena:CMAntissa,AllOplata);
      Str(StrToReal(AllOplata)-StrToReal(AllZakupka):CIZena:CMAntissa,AllDohod);
      End;
     End;
   Dispose(StatPrih,Done);
   i:=IOResult;
   System.Close(es);
   i:=IOResult;
  End;
 NoInfoMsg;

Dispose(Agent,Done);

R.Assign(21, 8, 59, 15);
New(Dlg, Init(R, 'Кратко'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(7, 1, 22, 2);
Control := New(PColoredText, Init(R, 'Всего отгрузка:', $74));
Dlg^.Insert(Control);

R.Assign(22, 1, 28, 2);
DelSpace(AllKOl);
Control := New(PColoredText, Init(R, #3+AllKol, $7E));
Dlg^.Insert(Control);

R.Assign(1, 2, 22, 3);
Control := New(PColoredText, Init(R, 'Всего отгрузка по ЦО:', $74));
Dlg^.Insert(Control);

R.Assign(22, 2, 37, 3);
DelSpace(AllOplata);
Control := New(PColoredText, Init(R, #3+AllOplata, $7E));
Dlg^.Insert(Control);

R.Assign(1, 3, 22, 4);
Control := New(PColoredText, Init(R, 'Всего отгрузка по ЗЦ:', $74));
Dlg^.Insert(Control);

R.Assign(22, 3, 37, 4);
DelSpace(AllZakupka);
Control := New(PColoredText, Init(R, #3+AllZakupka, $7E));
Dlg^.Insert(Control);

R.Assign(16, 4, 22, 5);
Control := New(PColoredText, Init(R, 'Доход:', $74));
Dlg^.Insert(Control);

R.Assign(22, 4, 37, 5);
DelSpace(AllDohod);
Control := New(PColoredText, Init(R, #3+AllDohod, $7E));
Dlg^.Insert(Control);

R.Assign(20, 5, 22, 6);
Control := New(PColoredText, Init(R, '%:', $74));
Dlg^.Insert(Control);

R.Assign(22, 5, 28, 6);
If Abs(StrToReal(AllZakupka))>0.009 Then
 Begin
  Str(StrToReal(AllDohod)/StrToReal(AllZakupka)*100:CLitr+1:CMAntissa,AllDohod);
  DelSpace(AllDohod);
 End
 Else
  Begin
   AllDohod:='??.??'
  End;
DelSpace(AllDohod);
Control := New(PColoredText, Init(R, #3+AllDohod, $7E));
Dlg^.Insert(Control);


Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
Dispose(Control,Done);
Dispose(Dlg,Done);

End;



procedure TCalcTovarWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;


Var s : string[150];
    Test : Word;
Begin
Case Event.What Of
 evKeyDown:
   Case Event.KeyCode Of
    kbF9 : Begin

if (ScreenList^.State and sfFocused <> 0)  And(ScreenList^.List<>Nil) And (ScreenList^.List^.Count>=1)Then
  Begin
   CalcScreenList(ScreenList);
  End;
            ClearEvent(Event);
            ClearFind;
           End;
   Else;
   End;

 evCommand :
   Case Event.Command Of
       cmLocalCalc:Begin
                     ClearFind;
                     Calculator;
                   End;
        cmRwz     :Begin
if (ScreenList^.State and sfFocused <> 0)  And(ScreenList^.List<>Nil) And (ScreenList^.List^.Count>=1)Then
  Begin
   s:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);
   SKodTov:=Copy(s,1+CName+1,CArtikul);
   RwzW^.Start(Test{в принципе тест не нужен});
  End;
                    ClearFind;
                    ClearEvent(Event);

                   End;
{$IfDef DPMI}
        cmPrihC    :Begin
if (ScreenList^.State and sfFocused <> 0)  And(ScreenList^.List<>Nil) And (ScreenList^.List^.Count>=1)Then
  Begin
   s:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);
   SKodTov:=Copy(s,1+CName+1,CArtikul);
   PrhW^.Start(Test{в принципе тест не нужен});
  End;
                    ClearFind;
                    ClearEvent(Event);

                   End;
        cmMrkC    :Begin
if (ScreenList^.State and sfFocused <> 0)  And(ScreenList^.List<>Nil) And (ScreenList^.List^.Count>=1)Then
  Begin
   s:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);
   SKodtov:=Copy(s,1+CName+1,CArtikul);
   MrkW^.Start(Test{в принципе тест не нужен});
  End;
                    ClearFind;
                    ClearEvent(Event);

                   End;
        cmRP    :Begin
if (ScreenList^.State and sfFocused <> 0)  And(ScreenList^.List<>Nil) And (ScreenList^.List^.Count>=1)Then
  Begin
   s:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);
   SKodtov:=Copy(s,1+CName+1,CArtikul);
   RpW^.Start(Test{в принципе тест не нужен});
  End;
                    ClearFind;
                    ClearEvent(Event);

                   End;
     cmReturnC    :Begin

if (ScreenList^.State and sfFocused <> 0)  And(ScreenList^.List<>Nil) And (ScreenList^.List^.Count>=1)Then
  Begin
   s:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);
   SKodtov:=Copy(s,1+CName+1,CArtikul);
   RetW^.Start(Test{в принципе тест не нужен});
  End;
                    ClearFind;
                    ClearEvent(Event);

                   End;
{$ENDif}

        cmOk      :Begin
                     ClearFind;
                     ClearEvent(Event);
                   End;
{$IfDef DPMI}
     cmPrintReestr:Begin
                     If (ScreenList^.List<>Nil)And(ScreenList^.List^.Count>=1) Then
                       Begin
                        ClearFind;
                        PrevCurLoc[0]:=#0;
                        FormReport(ScreenList);
                       End;
                     ClearEvent(Event);
                   End;
{$ENDif}
   Else;
   End;
   EvKeyDown       :
		 Case Event.KeyCode Of
        kbAltF9   :Begin
                    Event.What:=evCommand;
                    Event.Command:=cmPrintReestr;
                    PutEvent(Event);
						  ClearEvent(Event);
						 End;
		Else;
		End;
	Else;
	End;


inherited HandleEvent(Event);
If (Desktop^.Current=PView(CalcTWindow)) And (Event.What <> EvKeyDown) Then
			  Begin

if (ScreenList^.State and sfFocused <> 0)  And(ScreenList^.List<>Nil) And (ScreenList^.List^.Count>=1)Then
  Begin
	s:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);
	If s<>PrevCurLoc Then DrawCurrent;
  End;


  if (ControlSorting^.State and sfFocused <> 0)Then
						  Begin
								ControlSorting^.GetData(Test);
								If Test <> Sort Then
								Begin
									ClearFind;
									Sort:=Test;
									Refresh;
									Redraw;
									PrevCurLoc[0]:=#0;
								End;
						  End;

  if (ControlDirection^.State and sfFocused <> 0)Then
						  Begin
								ControlDirection^.GetData(Test);
								If Test <> Direction Then
								Begin
									ClearFind;
									Direction:=Test;
									Refresh;
									Redraw;
									PrevCurLoc[0]:=#0;
								End;
						  End;
				End;
End;


Destructor TCalcTovarWindow.Done;
Begin
TDialog.Done;
End;


Function TestAgent(Cod:ArtikulStr;Const Agent:PBox):Boolean;
Var L : Boolean;
    i : word;
    st : string[150];
Begin
TestAgent:=False;
If (Agent^.List^.Count-1)>=0 Then
Begin
For i:=0 To Agent^.List^.Count-1 Do
 Begin
  st:=Agent^.GetText(i,Agent^.List^.Count);
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    TestAgent:=True;
    Break;
   End;{St=Cod}
 End;
End;
End;




Procedure SpecialCalcMrk(l:LongInt;Const Cl,Agent:PBox;SClient:MAska3;SVidDocTov:Maska9;
Var EList,NMakeList:PBox;var er : text);
Var
   cc,count,i : Word;
   E  : PSuperMarketType;
   ef : MarketFileType;
   skol,Ssum,ssumz,bkol,bsum,bsumz :AllStr;
   Artikul : ArtikulStr;
   ws : string[150];
   k,j,r : Byte;
   Pos : LongInt;

Begin
 Assign(eF,Path.ToMarket+DateToDAteString(DAteMask,L)+'.mrk');
 i:=IOResult;
 Reset(ef);
 i:=IOResult;
 If i<>0 Then
  Begin
   Writeln(er,'Не найден файл продаж за '+DateToDAteString(DAteMask,L)+
   '  "'+DayString[DayOfWeek(l)]+'"'+
   +' Код:'+IntToStr(i,3));
   i:=IOResult;
   Exit;
  End;


 While Not(Eof(ef)) Do
  Begin
   cc:=0;
   New(E,Init);
   ReadMarket(Ef,E);

Begin
   If E^.Dat.Active Then
Begin
  If TestAgent(E^.Dat.ClientKod,Cl) Then
  If TestAgent(E^.Dat.AgentKod,Agent) Then
  If (SClient[E^.Dat.OperatorSelector+1]=1) Then{фильтр группы операций}
  If Not((E^.Dat.OperatorSelector=1) And (E^.Dat.ClientKod=ClientRP)) Then
  Begin
   If Not ((E^.Dat.Realiz) And (E^.Dat.DocSelector in [0,1,2,3,4])) Then
   Begin
   If ((SVidDocTov[E^.Dat.DocSelector+1]=1)  And (E^.Dat.OperatorSelector in [0,2]))
    Or (E^.Dat.OperatorSelector=1)  Then
     Begin

        For j:=1 To E^.Dat.Amount Do
         Begin

          If Not TestElement(E^.Dat.MarketElement[j].BazKod,EList) Then
           BEgin
            Pos:=Location(EList,E^.Dat.MarketElement[j].BazKod,False);
            ws:=EList^.GetText(Pos,EList^.List^.Count);
            bKol:=Copy(ws,1+CNAme+1+CArtikul+1,CKol+1);{общее количество}
            bsum:=Copy(ws,1+CNAme+1+CArtikul+1+(CKol+1)+1,CIZena);{сумма по оплате}
           bsumz:=Copy(ws,1+CNAme+1+CArtikul+1+(CKol+1)+1+CIZena+1,CIZena);{сумма по закупке}

              {просчитываем сумму к оплате}
            If E^.Dat.OperatorSelector in [0,2] Then
            Begin
              If E^.Dat.SkidkaSelector=0 Then
               Begin
                DelSpace(E^.Dat.MarketElement[j].Input.Proz);
                MyStr((StrToReal(E^.Dat.MarketElement[j].Input.Zena)/
                (1+StrToReal(E^.Dat.MarketElement[j].Input.Proz)/100)),CZena,CMantissa,
                         E^.Dat.MarketElement[j].Input.Zena);
               End
                Else
               Begin
                {сумма скидки}
                MyStr((StrToReal(E^.Dat.MarketElement[j].Input.Zena)-
                         StrToReal(E^.Dat.MarketElement[j].Input.Skidka)),
                         CZena,CMantissa,
                                        E^.Dat.MarketElement[j].Input.Zena);
               End;
            End
              Else
                MyStr(StRToReal(E^.Dat.MarketElement[j].Input.Zena),CZena,CMantissa,
                         E^.Dat.MarketElement[j].Input.Zena);

              {просчитываем сумму по закупке}

            MyStr(StrToReal(bsum)+StrToInt(E^.Dat.MarketElement[j].Input.Kol)*
                  STrToReal(E^.Dat.MarketElement[j].Input.Zena),CIZena,CMantissa,SSum);

            MyStr(StrToReal(BSumZ)+StrToInt(E^.Dat.MarketElement[j].Input.Kol)*
                  STrToReal(E^.Dat.MarketElement[j].Input.Zakupka),
                  CIZena,CMantissaZ,SSumZ);

            {MemC(BSumZ+' '+ZenaZakup+' '+SSumZ);}

            Str(StrToInt(E^.Dat.MarketElement[j].Input.Kol)+StrToInt(bKol):(Ckol+1),SKol);

            System.Delete(ws,1+CNAme+1+CArtikul+1,(CKOl+1)+1+CIZena+1+CIZena+1);
            System.Insert(SKol+'│'+SSum+'│'+SSumZ+'│',ws,1+CNAme+1+CArtikul+1);
            {удаляем старую строчку}
            EList^.List^.AtFree(Pos);
            {вставлем новую строчку}
            EList^.List^.Insert(NewStr(ws));
            EList^.SetRange(EList^.List^.Count);
           End;{позиция есть в списке}
         End;{For по накладной}
      {код расчета}
     End;
   End;
  End;
End;{Active}
End;{For}
Dispose(E,Done);
  End;{While}
Close(ef);
End;


Function CalcAgentfromMrk(Doc:ArtikulStr;Date:TDateString;Var Cod : ArtikulStr):Boolean;
Var find : Boolean;
    st,s : string[150];
    i : word;
    ef : MarketFileType;
    e : PSupermarketType;
Begin
CalcAgentfromMrk:=False;
Str(StrToInt(Doc):CDocNumer,Doc);
DelSpace(Doc);
DelSpace(Date);
Assign(ef,Path.ToMarket+Date+'.mrk');
i:=IOResult;
Reset(ef);
i:=IOResult;
If i<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия '+Path.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);
  Exit;
 End;

New(E,Init);
Find:=False;

 {оптимизация поиска}
  If FileSize(eF)>(StrToInt(Doc)-1) Then
   Begin
     Seek(eF,StrToInt(Doc)-1);
     ReadMarket(eF,E);
     Str(StrToInt(E^.Dat.Document):CDocNumer,E^.Dat.Document);
     DelSpace(E^.Dat.Document);
     DelSpace(E^.Dat.DAtec);
     If (E^.Dat.Document=Doc) And (E^.Dat.DAtec=Date) Then
         Begin
             Find:=True;
             Cod:=E^.Dat.AgentKod;
         End
         Else Seek(eF,0);
   End;


While Not(Eof(ef)) And Not(Find) Do
Begin
 ReadMarket(ef,E);
 Str(StrToInt(E^.Dat.Document):CDocNumer,E^.Dat.Document);
 DelSpace(E^.Dat.Document);
 DelSpace(E^.Dat.DAtec);
 If (E^.Dat.Document=Doc) And (E^.Dat.DAtec=Date) Then
  Begin
   Find:=True;
   Cod:=E^.Dat.AgentKod;
   Break;
  End;
End;
Close(Ef);
Dispose(E,done);
If Not(Find) Then
 MessageBox(^M+#3'Документ отгрузки N: '+Doc+' от '+Date+' в базе не найден!'^M+
 ClicProgrammer,Nil,MfError+mfCancelButton);
CalcAgentfromMrk:=Find;

End;







Procedure SpecialCalcRet(l:LongInt;Const Cl,Agent:PBox;SClient:MAska3;SVidDocTov:Maska9;
Var EList,NMAkeList:PBox;var er : text);
Var
   i : Word;
   E  : PNewVozwratType;
   ef : NewVozwratFileType;
   skol,Ssum,ssumz,bkol,bsum,bsumz :AllStr;
   Artikul : ArtikulStr;
   ws : string[150];
   k,j,r : Byte;
   Pos : LongInt;
   Ag : String[CClientKod];

Begin
 Assign(eF,Path.ToReturn+DateToDAteString(DAteMask,L)+'.vzw');
 i:=IOResult;
 Reset(ef);
 i:=IOResult;
 If i<>0 Then
  Begin
   Writeln(er,'Не найден файл возврата за '+DateToDAteString(DAteMask,L)+
   '  "'+DayString[DayOfWeek(l)]+'"'+
   +' Код:'+IntToStr(i,3));
   i:=IOResult;
   Exit;
  End;

 New(E,Init);

 While Not(Eof(ef)) Do
  Begin
   ReadNewVozwrat(ef,e);
   If TestAgent(E^.Dat.MakeKod,Cl) Then
   If (SClient[E^.Dat.OperatorSelector+1]=1)And (E^.Dat.StatusDoc=0) Then{фильтр группы операций}
   If CalcAgentfromMrk(E^.Dat.BasisDoc,E^.Dat.BasisDate,Ag) Then
  Begin
    If TestAgent(Ag,Agent) Then
Begin
        For j:=1 To E^.DAt.Amount Do
         Begin
          If Not TestElement(E^.Dat.VozwratElement[j].BazKod,EList) Then
           BEgin
            Pos:=Location(EList,E^.Dat.VozwratElement[j].BazKod,False);
            ws:=EList^.GetText(Pos,EList^.List^.Count);
            bKol :=Copy(ws,1+CNAme+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1,CKol+1);{общее количество}
            bsum :=Copy(ws,1+CNAme+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1+(CKol+1)+1,CIZena);{сумма по оплате}
            bsumz:=Copy(ws,1+CNAme+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1+(CKol+1)+1+CIZena+1,CIZena);{сумма по оплате}

If E^.Dat.DocSelector in [1,2,3,5,6] Then
   Begin
Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(E^.Dat.VozwratElement[j].Input.Zena)/
           (1+StrToReal(E^.Dat.VozwratElement[j].Input.LocalProz)/100),CZena,CMantissa,E^.Dat.VozwratElement[j].Input.Zena);
       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(E^.Dat.VozwratElement[j].Input.Zena)-
                    StrToReal(E^.Dat.VozwratElement[j].Input.LocalSkidka),CZena,CMantissa,
                    E^.Dat.VozwratElement[j].Input.Zena);
        End;
Else;
End;{Case}
End{If VidDocSelector}
Else
 Begin
Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(E^.Dat.VozwratElement[j].Input.Zena)/
           (1+StrToReal(E^.Dat.VozwratElement[j].Input.LocalProz)/100),CZena,CMantissa,E^.Dat.VozwratElement[j].Input.Zena);
       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(E^.Dat.VozwratElement[j].Input.Zena)-
                    StrToReal(E^.Dat.VozwratElement[j].Input.LocalSkidka),CZena,CMantissa,
                    E^.Dat.VozwratElement[j].Input.Zena);
        End;
Else;
End;{Case}
 End;

            MyStr(StrToReal(bsum)+StrToInt(E^.Dat.VozwratElement[j].Input.Kol)*
                  STrToReal(E^.Dat.VozwratElement[j].Input.Zena),CIZena,CMantissa,SSum);
            MyStr(StrToReal(bsumz)+StrToInt(E^.Dat.VozwratElement[j].Input.Kol)*
                  STrToReal(E^.Dat.VozwratElement[j].Input.Zakupka),
                  CIZena,CMantissaZ,SSumZ);

            Str(StrToInt(E^.Dat.VozwratElement[j].Input.Kol)+StrToInt(bKol):(Ckol+1),SKol);

            System.Delete(ws,1+CNAme+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1,(CKol+1)+1+CIZena+1+CIZena+1);
            System.Insert(SKol+'│'+SSum+'│'+SSumZ+'│',ws,1+CNAme+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1);
            {удаляем старую строчку}
            EList^.List^.AtFree(Pos);
            {вставлем новую строчку}
            EList^.List^.Insert(NewStr(ws));
            EList^.SetRange(EList^.List^.Count);
           End;{позиция есть в списке}
         End;{For по накладной}
      {код расчета}
End;
 End;
 End;{While}
Dispose(E,Done);
Close(ef);
End;





Procedure TTovarStatWindow.SpecialRecalc(Const VarList:PBox);
Var R   : TRect;
    Space : AllStr;
    ItogKol,ItogSum,s1,s2,s3,s4,s5,s6,s7 : AllStr;
    Cur : LongInt;
    s   : TMyString;
    wsd : TDateString;
    txt : Text;
    i : Word;
    VidReport:Word;
    er : text;
    Cl,Agent,NMakeList : PBox;
Begin
{$IFDEF DPMI}

 VidReport:=0;
 If {(FindParam('/EZ')) Or} (StrToInt(CurrentPassword)=0) or
 (User[73]) Then
  Begin
   VidReport:=SelectImport(21);
   If VidReport=2 Then Exit;
  End;


R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));
If Not(SelectionAgent(Agent)) Then
 Begin
  Dispose(Agent,Done);
  Exit;
 End;


R.Assign(0, 0, 0, 0);
Cl := New(PBox, Init(R, 1, Nil));
Cl^.NewList(New(PTextCollection, Init(0,1)));
If Not(SelectionClient(False,Cl)) Then
 Begin
  Dispose(Agent,Done);
  Dispose(Cl,Done);
  Exit;
 End;

 R.Assign (0,0,0,0);
 NMakeList := New(PBox, Init(R, 1, Nil));
 NMakeList^.NewList(New(PTextCollection, Init(0,1)));

{If Not(SelectionMake(NMakeList)) Then
 Begin
  Dispose(Agent,Done);
  Dispose(NMakeList,Done);
  Exit;
 End;}

 Assign(txt,Path.ToTemp+'Zapr.txt');
 i:=IOResult;
 Rewrite(txt);
 i:=IOResult;
 If i<>0 Then
  Begin
   Dispose(Agent,Done);
   Dispose(Cl,Done);
   MessageBox(#3'Ошибка создания '+Path.ToTemp+'Zapr.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


 Assign(er,Path.ToTemp+'erzapr.txt');
 i:=IOResult;
 Rewrite(er);
 i:=IOResult;
 If i<>0 Then
  Begin
   System.Close(txt);
   Dispose(Agent,Done);
   Dispose(Cl,Done);
   MessageBox(#3'Ошибка создания '+Path.ToTemp+'erZapr.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 WordToBit6(OperationFiltr,SVidOperation);
 Convert6(SVidOperation);
 WordToBit3(OperationToV,SClient);
 Convert3(SClient);


 WordToBit9(Filtr,SVidDocTov);
 Convert9(SVidDocTov);
 WordToBit2(OplataToV,SStatusOplata);
 Convert2(SStatusOplata);
 LStart:=DateStringToDate(DateMask,StartDatetov);
 LStop :=DateStringToDate(DateMask ,StopDatetov);

 {формирование списка товаров участвующих в выборке}
 R.Assign (0,0,0,0);
 NoScreenList := New(PBox, Init(R, 1, Nil));
 NoScreenList^.NewList(New(PTextCollection, Init(0,1)));
 For cur:=0 To VarList^.List^.Count-1 Do
  Begin
   s:=VarList^.GetText(cur,VarList^.List^.Count);
   s:=Copy(s,1,CName+1+CArtikul+1);

   s:=s+'     0│           0.00│           0.00│'+
        {123456│123456789012345│123456789012345│}
        '     0│           0.00│           0.00│';
   NoScreenList^.List^.Insert(NewStr(s));
   NoScreenList^.SetRange(NoScreenList^.List^.Count);
  End;

 For cur:=Lstart To LStop Do
  Begin
   DInfoMsg('Просматриваю операции за '+DateToDateString(DateMask,Cur)+' ...');

   if svidoperation[2]=1 Then SpecialCalcMrk(cur,Cl,Agent,SClient,SVidDocTov,NoScreenList,NMakeList,er);

   if svidoperation[3]=1 Then SpecialCalcRet(cur,Cl,Agent,SClient,SVidDocTov,NoScreenList,NMAkeList,er);

   NoInfoMsg;
  End;

 FormReportS(Cl,Agent,NoScreenList,NMAkeList,StartDateTov,StopDateTov,VidReport,txt,er);

 Dispose(NoScreenList,Done);
 Dispose(Agent,Done);
 Dispose(Cl,Done);
 Dispose(NMAkeList,Done);

 ViewAsText(Path.ToTemp+'Zapr.txt',True);
 {Report(Path^.Dat.ToTemp+'Zapr.txt','',NprintC^.DAt.CopyAll,False,False);}

{$ENDIF}
End;






Begin
 StopDatetov:=FDate;
 StartDatetov:=DateToDateString(DateMask,DateStringtoDate(DateMask,StopDateTov)-30);
End.
