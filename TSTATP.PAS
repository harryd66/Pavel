{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit tStat;


Interface


Uses Dialogs,Drivers,Glob,Access,ServStr,MyCalc,DStat ;


Type
  PCalcTovarWindow = ^TCalcTovarWindow;
  TCalcTovarWindow = object(TDialog)
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
    procedure Refresh;
    procedure DrawCurrent;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;


Implementation

uses DBEngine,Objects, Views, MsgBox,Protect,{Calc,}TPDate,Market,Tools,Printers,
     App, ColorTxt,Validate,Serv,Nastr,Vision1,Vision3,NetDbEng;

Const
  {приход}
      CPrihC=1+CName+1+CArtikul+1;
   CPrihCSum=CPrihC+(CKol+2)+1;
      CPrihS=CPrihCSum+CIZena+1;
   CPrihSSum=CPrihS+(CKol+2)+1;
  {продажи}
    cMrkC=1+CName+1+CArtikul+1+((ckol+2)+1+CIZena+1)*2;
 cMrkCSum=1+CName+1+CArtikul+1+((ckol+2)+1+CIZena+1)*2+(CKol+2)+1;
    cMrkS=1+CName+1+CArtikul+1+((ckol+2)+1+CIZena+1)*3;
 cMrkSSum=1+CName+1+CArtikul+1+((ckol+2)+1+CIZena+1)*3+(CKol+2)+1;

  {возврат}
   cReturnC=1+CName+1+CArtikul+1+((ckol+2)+1+CIZena+1)*4;
cReturnCSum=1+CName+1+CArtikul+1+((ckol+2)+1+CIZena+1)*4+(CKol+2)+1;
   cReturnS=1+CName+1+CArtikul+1+((ckol+2)+1+CIZena+1)*5;
cReturnSSum=1+CName+1+CArtikul+1+((ckol+2)+1+CIZena+1)*5+(CKol+2)+1;

  {переоценка}
   cPrz=1+CName+1+CArtikul+1+((ckol+2)+1+CIZena+1)*6;
cPrzSum=1+CName+1+CArtikul+1+((ckol+2)+1+CIZena+1)*6+(CKol+2)+1;

  {ревизия}
   cRwz=1+CName+1+CArtikul+1+((ckol+2)+1+CIZena+1)*7;
cRwzSum=1+CName+1+CArtikul+1+((ckol+2)+1+CIZena+1)*7+(CKol+2)+1;

  {РП}
   cRP=1+CName+1+CArtikul+1+((ckol+2)+1+CIZena+1)*8;
cRPSum=1+CName+1+CArtikul+1+((ckol+2)+1+CIZena+1)*8+(CKol+2)+1;



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
  ControlMrkC,
  ControlPrihC,
  ControlPrihS,
  ControlSorting,
  ControlDirection
   : PView;


 sControlStartDate,
 sControlStopDate,
 sControlStatus,
 sControlDoc,
 SControlOperationFiltr,
 SControlKolPos: PView;

 Ws : String[CIZena];
 SVidDoc : Maska9;
 SStatusOplata,SClient : Maska2;
 SVidOperation : Maska6;

 LStart,LStop:LongInt;

 OperationFiltr,Filtr,Oplata,Operation:Word;
 Sort,Direction : Word;
 sstart,sstop,StopDate ,StartDate : TDateString;
 PrevCurrent,PrevCurLoc: String;




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
    s,ws : String;
    id : PBazType;
    Baz : BazFileType;
begin
DInfo('Обновляю список наименований...');
NameList^.NewList(Nil);
NameList^.NewList(New(PTextCollection, Init(0,1)));

New(Id,Init);
Assign(RazdelFile,Path.ToRazdel+'razdel.db');
Res:=IOResult;
Reset(RazdelFile);
Res:=IOResult;
If Res=0 Then
 Begin
  While Not(Eof(RazdelFile)) Do{!!!!!!!!!}
{  Seek(RazdelFile,26);}
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

NameList^.FocusItem(0);
NameList^.HelpCtx:=$E586;
Insert(NameList);
NoInfo;
Redraw;
end;



constructor TTovarStatWindow.Init(Var l : Boolean);
Var R  : TRect;
    i,res  : Word;
    s,ws : String;
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
Oplata:=3;
Operation:=3;

R.Assign(1, 1, 31, 4);
SControlOperationFiltr := New(PCheckboxes, Init(R,
  NewSItem('Приход',
  NewSItem('Отгрузка',
  NewSItem('Возврат',
  NewSItem('Переоценка',
  NewSItem('Ревизия',
  NewSItem('Р/П', Nil))))))));
Insert(SControlOperationFiltr);

  R.Assign(1, 0, 15, 1);
  Insert(New(PLabel, Init(R, 'Вид операций:', SControlOperationFiltr)));

sControlOperationFiltr^.SetData(OperationFiltr);

R.Assign(14, 5, 37, 6);
SControlClientFiltr := New(PCheckboxes, Init(R,
  NewSItem('Кли~е~нт',
  NewSItem('Скл~а~д', Nil))));
Insert(SControlClientFiltr);
SControlClientFiltr^.SetData(Operation);

  R.Assign(1, 5, 14, 6);
  Insert(New(PLabel, Init(R, 'Вид клиента:', SControlClientFiltr)));

R.Assign(35, 1, 45, 2);
sControlStartDate := New(PInputLine, Init(R, CDate));
sControlStartDate^.SetData(StartDate);
Insert(sControlStartDate);
  PInputLine(sControlStartDate)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(32, 1, 35, 2);
  Insert(New(PLabel, Init(R, 'с:',sControlStartDate)));

R.Assign(35, 2, 45, 3);
sControlStopDate:= New(PInputLine, Init(R, CDate));
sControlStopDate^.SetData(StopDate);
Insert(sControlStopDate);
  PInputLine(sControlStopDate)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));


  R.Assign(31, 2, 35, 3);
  Insert(New(PLabel, Init(R, '~п~о:', sControlStopDate)));

R.Assign(47, 1, 76, 4);
sControlDocFiltr := New(PCheckboxes, Init(R,
  NewSItem('~С~п',
  NewSItem('~Т~Ч',
  NewSItem('ФЛ*',
  NewSItem('С~Ф~*',
  NewSItem('СФБ',
  NewSItem('Д~*~',
  NewSItem('Д СФ*',
  NewSItem('Д',
  NewSItem('Д СФБ', Nil)))))))))));
Insert(sControlDocFiltr);
sControlDocFiltr^.SetData(Filtr);

  R.Assign(63, 0, 76, 1);
  Insert(New(PLabel, Init(R, 'Вид док-тов:', sControlDocFiltr)));

R.Assign(47, 5, 76, 6);
sControlOplataFiltr := New(PCheckboxes, Init(R,
  NewSItem('~О~плачен',
  NewSItem('~Н~е оплачен', Nil))));
Insert(sControlOplataFiltr);
sControlOplataFiltr^.SetData(Oplata);

  R.Assign(39, 5, 47, 6);
  Insert(New(PLabel, Init(R, 'Статус док-ов:', sControlOplataFiltr)));

R.Assign(38, 7, 39, 21);
sControl := New(PScrollBar, Init(R));
Insert(sControl);

R.Assign(1, 7, 38, 21);
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

  R.Assign(1, 6, 38, 7);
  Insert(New(PLabel, Init(R, 'Наи~м~енование товара         Код  Фас', NameList)));

R.Assign(76, 6, 77, 22);
sControl := New(PScrollBar, Init(R));
Insert(sControl);

R.Assign(39, 7, 76, 22);
SelectNameList := New(PBox, Init(R, 1, PScrollbar(SControl)));
SelectNameList^.NewList(New(PTextCollection, Init(0,1)));
SelectNameList^.FocusItem(0);
SelectNameList^.HelpCtx:=$E596;
Insert(SelectNameList);

  R.Assign(39, 6, 76, 7);
  Insert(New(PLabel, Init(R, '~В~ыбранные наименования      Код  Фас', SelectNameList)));

R.Assign(2, 21, 38, 22);
sControlComment := New(PColoredText, Init(R, 'На складе:     0 шт. Р/Цена:    0.00', $71));
Insert(SControlComment);

R.Assign(44, 22, 72, 23);
sControlkolpos := New(PColoredText, Init(R, #3+'Выбрано 0 позиций', $4E));
Insert(sControlkolpos);

SelectNext(False);

AddName;
Refresh;
PrevCurrent[0]:=#0;
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
    mm2 : Maska2;
Begin
 WordToBit6(OperationFiltr,mm6);
 Convert6(mm6);
 WordToBit2(Operation,mm2);
 Convert2(mm2);

If (mm2[1]=1) Then
Begin
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
End
 Else
  Begin
   PCluster(SControlDocFiltr)^.SetButtonState($000001FF, False);
   PCluster(SControlOplataFiltr)^.SetButtonState($00000003, False);
  End;

End;




procedure TTovarStatWindow.DrawCurrent;
Var R : TRect;
    s,st : String;
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
    R.Assign(2, 21, 39, 22);
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
LAbel 1;
Var test : Word;
    s,s1 : String;
    razd,SDoc : ArtikulStr;
    SDate: TDateString;
    ClientKod : ArtikulStr;
    ls : LongInt;
    l : Boolean;
    R : TRect;
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
              razd:=copy(SelectNameList^.GetText(SelectNameList^.Focused,SelectNameList^.List^.Count),1+CNAme+1,CRazdelKod);
            1:
             If (SelectNameList^.List^.Count>=1) Then
             For ls :=0 To SelectNameList^.List^.Count-1 Do
              Begin
               s:=SelectNameList^.GetText(ls,SelectNameList^.List^.Count);
               If StrToInt(Copy(s,1+CNAme+1,CRazdelKod))=StrToInt(RAzd) Then
                Begin
                 SelectNameList^.FocusItem(ls);
                 SelectNameList^.List^.AtFree(Ls);
                 SelectNameList^.SetRange(SelectNameList^.List^.Count);
                 If SelectNameList^.Focused>0 Then
                            SelectNameList^.FocusItem(SelectNameList^.Focused);

                 If (SelectNameList^.Focused>=SelectNameList^.List^.Count)
                          and(SelectNameList^.Focused>0) Then
                   SelectNameList^.FocusItem(SelectNameList^.Focused-1);
                 goto 1;
                End;
              End;

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
             DInfo('Минуточку...');
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
              NoInfo;
                 ProdagaWindow:=False;
                 {SelectNameListList^.SetRange(SelectNameListList^.List^.Count);}
                 If NameList^.Focused+1<NameList^.List^.Count Then NameList^.FocusItem(NameList^.Focused+1);
                 If SelectNameList^.Focused+1<SelectNameList^.List^.Count Then
                 SelectNameList^.FocusItem(SelectNameList^.List^.Count-1);
             ClearEvent(Event);
             End;
            {else ClearEvent(Event);}
            Redraw;
              AddName;
              PrevCurrent[0]:=#0;
              End;
   kbGrayPlus,
   kbCtrlIns: Begin
                ClearFind;
                 ProdagaWindow:=False;
          If ((NameList^.State and sfFocused <> 0)And(NameList^.List^.Count>= 1)) Then
            Begin
             DInfo('Минуточку...');
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
              NoInfo;
                 ProdagaWindow:=False;
                 {SelectNameListList^.SetRange(SelectNameListList^.List^.Count);}
                 If NameList^.Focused+1<NameList^.List^.Count Then NameList^.FocusItem(NameList^.Focused+1);
                 If SelectNameList^.Focused+1<SelectNameList^.List^.Count Then
                 SelectNameList^.FocusItem(SelectNameList^.List^.Count-1);
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
  cmRefresh :Begin
              Refresh;
              PrevCurrent[0]:=#0;
             End;

  cmCalcStat :Begin
              ClearFind;
              If (SelectNameList^.List<>Nil)And(SelectNAmeList^.List^.Count>0)  Then
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

               If DateStringToDate(DateMask,StartDate)>DateStringToDate(DateMask,StopDate) Then
                Begin
                 s1:=StartDate;
                 StartDate:=stopDate;
                 StopDate:=s1;
                End;

               SControlStartDate^.SetData(startDate);
               SControlStopDate^.SetData(stopDate);


               {назначаем фильтр видов документов}
               SControlDocFiltr^.GetData(Filtr);

               {назначаем фильтр видов операций}
               SControlOperationFiltr^.GetData(OperationFiltr);

               {назначаем фильтр видов клиентов}
               SControlClientFiltr^.GetData(Operation);

               {назначаем фильтр оплаты}
               sControlOplataFiltr^.GetData(Oplata);

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
               If Test <> Operation Then
               Begin
                  Operation:=Test;
                  SetDocFiltrMaska;
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
 If Sp^.DAt.OperatorSelector=0 Then
 Assign(es,Path.ToAnalys+Sp^.Dat.BazKod+'.prc')
 Else
 Assign(es,Path.ToAnalys+Sp^.Dat.BazKod+'.prs');
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
   temps : String;
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
          ssum:=copy(temps,CPrihCSum,CIZena);
          Str((StrToReal(SSum)+StrToReal(StatPrih^.Dat.SummaPrihod)):CIZena:CMantissa,SSum);
          Delete(Temps,CPrihC,CKol+2+1+CIZena);
          Insert(SKol+'│'+SSum,Temps,CPrihC);
         End;
        If (SClient[2]=1) And (E^.Dat.OperatorSelector=1) Then
          Begin
           skol:=copy(temps,CPrihS,CKol+2);
           Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
           ssum:=copy(temps,CPrihSSum,CIZena);
           Str((StrToReal(SSum)+StrToReal(StatPrih^.Dat.SummaPrihod)):CIZena:CMantissa,SSum);
           Delete(Temps,CPrihS,CKol+2+1+CIZena);
           Insert(SKol+'│'+SSum,Temps,CPrihS);
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
   temps : String;
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
{        Kol     :=Kol1;}
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
          ssum:=copy(temps,CReturnCSum,CIZena);
          Str((StrToReal(SSum)+StrToReal(StatPrih^.Dat.Summa)):CIZena:CMantissa,SSum);
          Delete(Temps,CReturnC,CKol+2+1+CIZena);
          Insert(SKol+'│'+SSum,Temps,CReturnC);
         End;

        If (SClient[2]=1) And (E^.Dat.OperatorSelector=1) Then
          Begin
           skol:=copy(temps,CReturnS,CKol+2);
           Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
           ssum:=copy(temps,CReturnSSum,CIZena);
           Str((StrToReal(SSum)+StrToReal(StatPrih^.Dat.Summa)):CIZena:CMantissa,SSum);
           Delete(Temps,CReturnS,CKol+2+1+CIZena);
           Insert(SKol+'│'+SSum,Temps,CReturnS);
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
   temps,ws : String;
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
       Lg^.Dat.MarketElement[j].Input.Zena:=E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[j].Input.Zakupka:=E^.Dat.MarketElement[l].Input.Zakupka;
       Lg^.Dat.MarketElement[j].Input.Skidka:=E^.Dat.MarketElement[l].Input.Skidka;
       Lg^.Dat.MarketElement[j].Input.Proz:=E^.Dat.MarketElement[l].Input.Proz;
       Lg^.Dat.MarketElement[j].Input.SpecNalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
       Lg^.Dat.MarketElement[j].Input.NDS:=E^.Dat.MarketElement[l].Input.NDS;
       Inc(k);
       Lg^.DAt.Amount:=k-1;
      End;
    End;
    Lg^.DAt.Amount:=k-1;

   If Not((E^.Dat.OperatorSelector=1) And (E^.Dat.ClientKod=ClientRP)) Then
   Begin
   If Not ((E^.Dat.Realiz) And (E^.Dat.DocSelector in [0,1,2,3,4])) Then
   Begin
   If ((SVidDoc[E^.Dat.DocSelector+1]=1)  And (E^.Dat.OperatorSelector=0))
    Or (E^.Dat.OperatorSelector=1)  Then
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
              If E^.DAt.SkidkaSelector in [0,2] Then
               Begin
                DelSpace(Lg^.Dat.MarketElement[l].Input.Proz);
                Str((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)/
                (1+StrToReal(Lg^.Dat.MarketElement[l].Input.Proz)/100)):CZena:CMantissa,ws);
                {ws - теперь цена с учетом скидки}
                str(strtoreal(Lg^.Dat.MarketElement[l].Input.Zena)-
                    strtoreal(ws):CZena:CMantissa,ws);
                {ws - теперь велечина позиционной скидки}
                Str(StrToReal(Skidka1)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
                StrToReal(ws):CIZena:CMantissa,Skidka1);

                DelSpace(Lg^.Dat.MarketElement[l].Input.Proz);
                Str((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)/
                (1+StrToReal(Lg^.Dat.MarketElement[l].Input.Proz)/100)):CZena:CMantissa,ws);
               End
                Else
                 Begin
                  {сумма скидки}
                  Str((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[l].Input.Skidka))
                  :CZena:CMantissa,ws);
                  Str(StrToReal(Skidka1)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
                  StrToReal(ws):CIZena:CMantissa,Skidka1);
                 End;

                If E^.DAt.DocSelector in [1,2,3,5,6] Then
                 Begin
                  str(((1+strtoreal(lg^.dat.marketelement[l].Input.SpecNalog)
                  /100)):CLitr:CMantissa,koefficient);
                  Str(StrToReal(ws)*StrToReal(Koefficient):CZena:CMantissa,ws2);
                  Str(StrToReal(ws2)-StrToReal(ws):CZena:CMAntissa,ws);
                           {абсолютная величина сбора Налога с продажи}
                  Str(StrtoReal(ENalog1)+StrToReal(ws)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:CMAntissa,ENalog1);
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
        Document:=E^.Dat.Document; {номер документа}
        DateC   :=E^.Dat.DateC; {дата создания}
        TimeC   :=E^.Dat.TimeC; {время создания}
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
        If (SClient[1]=1) And (E^.Dat.OperatorSelector=0) Then
         Begin
          skol:=copy(temps,CMrkC,CKol+2);
          Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
          ssum:=copy(temps,CMrkCSum,CIZena);
          Str((StrToReal(SSum)+StrToReal(StatPrih^.Dat.SummaZ)):CIZena:CMantissa,SSum);
          Delete(Temps,CMrkC,CKol+2+1+CIZena);
          Insert(SKol+'│'+SSum,Temps,CMrkC);
         End;

        If (SClient[2]=1) And (E^.Dat.OperatorSelector=1) Then
          Begin
           skol:=copy(temps,CMrkS,CKol+2);
           Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
           ssum:=copy(temps,CMrkSSum,CIZena);
           Str((StrToReal(SSum)+StrToReal(StatPrih^.Dat.SummaZ)):CIZena:CMantissa,SSum);
           Delete(Temps,CMrkS,CKol+2+1+CIZena);
           Insert(SKol+'│'+SSum,Temps,CMrkS);
          End;

        EList^.List^.Insert(NewStr(temps));
        EList^.SetRange(SelectNameList^.List^.Count);
         End;{if find}
    End;{фильтр документов отгрузки}
   End;{фильтр вторичных документов консигнации}
  End;{фильтр РП}
  End;
  Dispose(lg,Done);
  End;

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
   temps,ws : String;
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
       Lg^.Dat.MarketElement[j].Input.Zena:=E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[j].Input.Zakupka:=E^.Dat.MarketElement[l].Input.Zakupka;
       Lg^.Dat.MarketElement[j].Input.Skidka:=E^.Dat.MarketElement[l].Input.Skidka;
       Lg^.Dat.MarketElement[j].Input.Proz:=E^.Dat.MarketElement[l].Input.Proz;
       Lg^.Dat.MarketElement[j].Input.SpecNalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
       Lg^.Dat.MarketElement[j].Input.NDS:=E^.Dat.MarketElement[l].Input.NDS;
       Inc(k);
       Lg^.DAt.Amount:=k-1;
      End;
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
              If E^.DAt.SkidkaSelector in [0,2] Then
               Begin
                DelSpace(Lg^.Dat.MarketElement[l].Input.Proz);
                Str((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)/
                (1+StrToReal(Lg^.Dat.MarketElement[l].Input.Proz)/100)):CZena:CMantissa,ws);
                {ws - теперь цена с учетом скидки}
                str(strtoreal(Lg^.Dat.MarketElement[l].Input.Zena)-
                    strtoreal(ws):CZena:CMantissa,ws);
                {ws - теперь велечина позиционной скидки}
                Str(StrToReal(Skidka1)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
                StrToReal(ws):CIZena:CMantissa,Skidka1);

                DelSpace(Lg^.Dat.MarketElement[l].Input.Proz);
                Str((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)/
                (1+StrToReal(Lg^.Dat.MarketElement[l].Input.Proz)/100)):CZena:CMantissa,ws);
               End
                Else
                 Begin
                  {сумма скидки}
                  Str((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[l].Input.Skidka))
                  :CZena:CMantissa,ws);
                  Str(StrToReal(Skidka1)+StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)*
                  StrToReal(ws):CIZena:CMantissa,Skidka1);
                 End;

                If E^.DAt.DocSelector in [1,2,3,5,6] Then
                 Begin
                  str(((1+strtoreal(lg^.dat.marketelement[l].Input.SpecNalog)
                  /100)):CLitr:CMantissa,koefficient);
                  Str(StrToReal(ws)*StrToReal(Koefficient):CZena:CMantissa,ws2);
                  Str(StrToReal(ws2)-StrToReal(ws):CZena:CMAntissa,ws);
                           {абсолютная величина сбора Налога с продажи}
                  Str(StrtoReal(ENalog1)+StrToReal(ws)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:CMAntissa,ENalog1);
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
        Document:=E^.Dat.Document; {номер документа}
        DateC   :=E^.Dat.DateC; {дата создания}
        TimeC   :=E^.Dat.TimeC; {время создания}
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
          ssum:=copy(temps,CRpSum,CIZena);
          Str((StrToReal(SSum)+StrToReal(StatPrih^.Dat.SummaZ)):CIZena:CMantissa,SSum);
          Delete(Temps,CRp,CKol+2+1+CIZena);
          Insert(SKol+'│'+SSum,Temps,CRp);
         End;
        EList^.List^.Insert(NewStr(temps));
        EList^.SetRange(SelectNameList^.List^.Count);
         End;{if find}
    End;{фильтр документов отгрузки}
  End;{фильтр РП}
  End;
  Dispose(lg,Done);
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
   temps : String;
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
        ssum:=copy(temps,CPrzSum,CIZena);
        Str((StrToReal(SSum)+StrToReal(StatPrih^.Dat.Summa)):CIZena:CMantissa,SSum);
        Delete(Temps,CPrz,CKol+2+1+CIZena);
        Insert(SKol+'│'+SSum,Temps,CPrz);

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
   temps : String;
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
           End;
        If Not(SaveStatRewisia(StatPrih)) Then
        MessageBox('Ошибка записи в файл '+E^.Dat.Element[i].BazKod,nil,mfError+mfCancelButton);
        {конец обновления информации в файле}

        {обновление количества и суммы в списке}
        EList^.List^.AtFree(Kol);
        EList^.SetRange(EList^.List^.Count);
        skol:=copy(temps,CRwz,CKol+2);
        Str((StrToInt(SKol)+StrToInt(StatPrih^.Dat.Kol)):CKol+2,SKol);
        ssum:=copy(temps,CRwzSum,CIZena);
        Str((StrToReal(SSum)+StrToReal(StatPrih^.Dat.Summa)):CIZena:CMantissa,SSum);
        Delete(Temps,CRwz,CKol+2+1+CIZena);
        Insert(SKol+'│'+SSum,Temps,CRwz);

        EList^.List^.Insert(NewStr(temps));
        EList^.SetRange(SelectNameList^.List^.Count);
         End;{if find}

    End;
  End;

 Dispose(StatPrih,Done);
 Dispose(e,Done);
 Close(Ef);
End;



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
    s   : String;
Begin
 WordToBit6(OperationFiltr,SVidOperation);
 Convert6(SVidOperation);
 WordToBit2(Operation,SClient);
 Convert2(SClient);

 DisableCommands([cmPrihC,cmPrihS,cmMrkC,cmMrkS,cmReturnC,cmReturnS,
                  cmPrz,cmRwz,cmRP]);

 If SVidOperation[1]=1 Then
 Begin
  If SClient[1]=1 Then
   EnableCommands([cmPrihC]);
  If SClient[2]=1 Then
   EnableCommands([cmPrihS]);
 End;

 If SVidOperation[2]=1 Then
 Begin
  If SClient[1]=1 Then
   EnableCommands([cmMrkC]);
  If SClient[2]=1 Then
   EnableCommands([cmMrkS]);
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





 WordToBit9(Filtr,SVidDoc);
 Convert9(SVidDoc);
 WordToBit2(Oplata,SStatusOplata);
 Convert2(SStatusOplata);
 LStart:=DateStringToDate(DateMask,StartDate);
 LStop :=DateStringToDate(DateMask ,StopDate);

 {формирование списка товаров участвующих в выборке}
 R.Assign (0,0,0,0);
 NoScreenList := New(PBox, Init(R, 1, Nil));
 NoScreenList^.NewList(New(PTextCollection, Init(0,1)));
 For cur:=0 To VarList^.List^.Count-1 Do
  Begin
   s:=VarList^.GetText(cur,VarList^.List^.Count);
   s:=Copy(s,1,CName+1+CArtikul+1);
         {приход клиент}             {приход склад}
   s:=s+'      0│           0.00│'+'      0│           0.00│'
         {отгрузка клиент}           {отгрузка склад}
       +'      0│           0.00│'+'      0│           0.00│'
         {возврат клиент}            {возврат склад}
       +'      0│           0.00│'+'      0│           0.00│'
         {переоценка}                {ревизия}
       +'      0│           0.00│'+'      0│           0.00│'
         {РП}
       +'      0│           0.00│';
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

 R.Assign(0, 1, 80, 22);
 New(CalcTWindow, Init(R, 'Движение товара за период с '+StartDate+' по '+StopDate));
 CalcTWindow^.Options := CalcTWindow^.Options or ofCenterX;
 CalcTWindow^.HelpCtx:=$E002;

 R.Assign(34, 2, 35, 20);
Control1 := New(PScrollBar, Init(R));
CalcTWindow^.Insert(Control1);

R.Assign(1, 2, 34, 20);
ScreenList := New(PBox, Init(R, 1, PScrollbar(Control1)));
ScreenList^.NewList(New(PTextCollection, Init(0,1)));

 For cur:=0 To NoScreenList^.List^.Count-1 Do
  Begin
   s:=NoScreenList^.GetText(cur,NoScreenList^.List^.Count);
   ScreenList^.List^.Insert(NewStr(s));
   ScreenList^.SetRange(NoScreenList^.List^.Count);
  End;
ScreenList^.FocusItem(0);
ScreenList^.HelpCtx:=$F021;
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

R.Assign(65, 2, 72, 4);
ControlDirection := New(PRadioButtons, Init(R,
  NewSItem(#30,
  NewSItem(#31, Nil))));
ControlDirection^.Options := ControlDirection^.Options or ofFramed;
CalcTWindow^.Insert(ControlDirection);
Direction:=0;
ControlDirection^.SetDAta(Direction);

  R.Assign(65, 1, 70, 2);
  CalcTWindow^.Insert(New(PLabel, Init(R, '~Т~ип:', ControlDirection)));


R.Assign(36, 5, 78, 7);
Control1 := New(PColoredText, Init(R, '', $70));
Control1^.Options := Control1^.Options or ofFramed;
CalcTWindow^.Insert(Control1);

R.Assign(36, 5, 54, 6);
Control1 := New(PColoredText, Init(R, 'Приход (Клиент)  :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(36, 6, 54, 7);
Control1 := New(PColoredText, Init(R, 'Приход (Склад)   :', $74));
CalcTWindow^.Insert(Control1);


R.Assign(54, 4, 78, 5);
ControlPrihC := New(PColoredText, Init(R, '      0             0.00', $7E));
CalcTWindow^.Insert(ControlPrihC);

R.Assign(54, 5, 78, 6);
ControlPrihS := New(PColoredText, Init(R, '      0             0.00', $7E));
CalcTWindow^.Insert(ControlPrihS);

{возврат}
R.Assign(36, 11, 78, 13);
Control1 := New(PColoredText, Init(R, '', $70));
Control1^.Options := Control1^.Options or ofFramed;
CalcTWindow^.Insert(Control1);

R.Assign(36, 12, 54, 13);
Control1 := New(PColoredText, Init(R, 'Возврат (Склад)  :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(36, 11, 54, 12);
Control1 := New(PColoredText, Init(R, 'Возврат (Клиент) :', $74));
CalcTWindow^.Insert(Control1);



R.Assign(54, 11, 78, 12);
ControlReturnC := New(PColoredText, Init(R, '      0             0.00', $7E));
CalcTWindow^.Insert(ControlReturnC);

R.Assign(54, 12, 78, 13);
ControlReturnS := New(PColoredText, Init(R, '      0             0.00', $7E));
CalcTWindow^.Insert(ControlReturnS);

R.Assign(36, 14, 78, 15);
Control1 := New(PColoredText, Init(R, '', $70));
Control1^.Options := Control1^.Options or ofFramed;
CalcTWindow^.Insert(Control1);

R.Assign(36, 14, 54, 15);
Control1 := New(PColoredText, Init(R, 'Переоценка       :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(54, 14, 78, 15);
ControlPrz := New(PColoredText, Init(R, '      0             0.00', $7E));
CalcTWindow^.Insert(ControlPrz);

R.Assign(36, 16, 78, 17);
Control1 := New(PColoredText, Init(R, '', $70));
Control1^.Options := Control1^.Options or ofFramed;
CalcTWindow^.Insert(Control1);

R.Assign(36, 16, 54, 17);
Control1 := New(PColoredText, Init(R, 'Ревизия          :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(54, 16, 78, 17);
ControlRwz := New(PColoredText, Init(R, '      0             0.00', $7E));
CalcTWindow^.Insert(ControlRwz);

R.Assign(36, 8, 78, 10);
Control1 := New(PColoredText, Init(R, '', $70));
Control1^.Options := Control1^.Options or ofFramed;
CalcTWindow^.Insert(Control1);

R.Assign(36, 9, 54, 10);
Control1 := New(PColoredText, Init(R, 'Отгрузка (Склад) :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(36, 8, 54, 9);
Control1 := New(PColoredText, Init(R, 'Отгрузка (Клиент):', $74));
CalcTWindow^.Insert(Control1);

R.Assign(54, 9, 78, 10);
ControlMrkS := New(PColoredText, Init(R, '      0             0.00', $7E));
CalcTWindow^.Insert(ControlMrkS);

R.Assign(54, 8, 78, 9);
ControlMrkC := New(PColoredText, Init(R, '      0             0.00', $7E));
CalcTWindow^.Insert(ControlMrkC);

R.Assign(36, 18, 78, 19);
Control1 := New(PColoredText, Init(R, '', $70));
Control1^.Options := Control1^.Options or ofFramed;
CalcTWindow^.Insert(Control1);

R.Assign(36, 18, 54, 19);
Control1 := New(PColoredText, Init(R, 'Р/П              :', $74));
CalcTWindow^.Insert(Control1);

R.Assign(54, 18, 78, 19);
ControlRp := New(PColoredText, Init(R, '      0             0.00', $7E));
CalcTWindow^.Insert(ControlRp);



 CalcTWindow^.SelectNext(False);
 PrevCurLoc[0]:=#0;

 Desktop^.ExecView(CalcTWindow);


 DInfoMsg('Удаляю временные файлы...');
 EraseFile(NoScreenList);
 NoInfoMsg;

 Dispose(NoScreenList,Done);
 Dispose(ControlSorting,Done);
 Dispose(ControlDirection,Done);
 Dispose(Control1,Done);
 Dispose(ScreenList,Done);

 Dispose(CAlcTWindow,Done);

End;

procedure TCalcTovarWindow.DrawCurrent;
Var R   : TRect;
Begin
If ScreenList^.List^.Count>0 Then
Begin
Dispose(ControlPrihC,Done);
R.Assign(54, 5, 78, 6);
PrevCurLoc:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CPrihC,CKol+2+1+CIZena);
PrevCurLoc[8]:=' ';
If (svidOperation[1]=1) And (SClient[1]=1) Then
ControlPrihC := New(PColoredText, Init(R, #3+PrevCurLoc, $7E))
Else
ControlPrihC := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlPrihC);

Dispose(ControlPrihS,Done);
R.Assign(54, 6, 78, 7);
PrevCurLoc:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CPrihS,CKol+2+1+CIZena);
PrevCurLoc[8]:=' ';
If (svidOperation[1]=1) And (SClient[2]=1) Then
ControlPrihS := New(PColoredText, Init(R, #3+PrevCurLoc, $7E))
Else
ControlPrihS := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlPrihS);


Dispose(ControlreturnC,Done);
R.Assign(54, 11, 78, 12);
PrevCurLoc:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CReturnC,CKol+2+1+CIZena);
PrevCurLoc[8]:=' ';
If (svidOperation[3]=1) And (SClient[1]=1) Then
ControlReturnC := New(PColoredText, Init(R, #3+PrevCurLoc, $7e))
Else
ControlReturnC := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlReturnC);

Dispose(ControlreturnS,Done);
R.Assign(54, 12, 78, 13);
PrevCurLoc:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CReturnS,CKol+2+1+CIZena);
PrevCurLoc[8]:=' ';
If (svidOperation[3]=1) And (SClient[2]=1) Then
ControlReturnS := New(PColoredText, Init(R, #3+PrevCurLoc, $7e))
Else
ControlReturnS := New(PColoredText, Init(R, #3+PrevCurLoc, $78));

CalcTWindow^.Insert(ControlReturnS);


Dispose(ControlMrkC,Done);
R.Assign(54, 8, 78, 9);
PrevCurLoc:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CMrkC,CKol+2+1+CIZena);
PrevCurLoc[8]:=' ';
If (svidOperation[2]=1) And (SClient[1]=1) Then
ControlMrkC := New(PColoredText, Init(R, #3+PrevCurLoc, $7e))
Else
ControlMrkC := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlMrkC);

Dispose(ControlMrkS,Done);
R.Assign(54, 9, 78, 10);
PrevCurLoc:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CMrkS,CKol+2+1+CIZena);
PrevCurLoc[8]:=' ';
If (svidOperation[2]=1) And (SClient[2]=1) Then
ControlMrkS := New(PColoredText, Init(R, #3+PrevCurLoc, $7e))
Else
ControlMrkS := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlMrkS);

Dispose(ControlPrz,Done);
R.Assign(54, 14, 78, 15);
PrevCurLoc:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CPrz,CKol+2+1+CIZena);
PrevCurLoc[8]:=' ';
If (svidOperation[4]=1) And (SClient[2]=1) Then
ControlPrz := New(PColoredText, Init(R, #3+PrevCurLoc, $7e))
Else
ControlPrz := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlPrz);

Dispose(Controlrwz,Done);
R.Assign(54, 16, 78, 17);
PrevCurLoc:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CRwz,CKol+2+1+CIZena);
PrevCurLoc[8]:=' ';
If (svidOperation[5]=1) And (SClient[2]=1) Then
ControlRwz := New(PColoredText, Init(R, #3+PrevCurLoc, $7e))
Else
ControlRwz := New(PColoredText, Init(R, #3+PrevCurLoc, $78));

CalcTWindow^.Insert(ControlRwz);

Dispose(ControlRp,Done);
R.Assign(54, 18, 78, 19);
PrevCurLoc:=Copy(ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count),CRp,CKol+2+1+CIZena);
PrevCurLoc[8]:=' ';
If (svidOperation[6]=1) And (SClient[2]=1) Then
ControlRp := New(PColoredText, Init(R, #3+PrevCurLoc, $7E))
Else
ControlRp := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlRp);
PrevCurLoc:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);

End
Else
 Begin
Dispose(ControlPrihC,Done);
R.Assign(54, 5, 78, 6);
PrevCurLoc[0]:=#0;
ControlPrihC := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlPrihC);

Dispose(ControlPrihS,Done);
R.Assign(54, 6, 78, 7);
ControlPrihS := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlPrihS);

Dispose(ControlreturnC,Done);
R.Assign(54, 11, 78, 12);
ControlReturnC := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlReturnC);

Dispose(ControlreturnS,Done);
R.Assign(54, 12, 78, 13);
ControlReturnS := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlReturnS);

Dispose(ControlPrz,Done);
R.Assign(54, 14, 78, 15);
ControlPrz := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlPrz);

Dispose(Controlrwz,Done);
R.Assign(54, 16, 78, 17);
ControlRwz := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlRwz);

Dispose(ControlMrkC,Done);
R.Assign(54, 8, 78, 9);
ControlMrkC := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlMrkC);

Dispose(ControlMrkS,Done);
R.Assign(54, 9, 78, 10);
ControlMrkS := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlMrkS);

Dispose(ControlRp,Done);
R.Assign(54, 18, 78, 19);
ControlRp := New(PColoredText, Init(R, #3+PrevCurLoc, $78));
CalcTWindow^.Insert(ControlRp);


 End;
Redraw;
End;



procedure TCalcTovarWindow.Refresh;
Var i,j : Word;
    ws,ws1 : String;
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
Const Space='   ';
Var Txt : Text;
    k,c : Word;
    st,s,ws : String;
    Numer : ArtikulStr;
    R : TRect;
    Clientkod : String[cclientkod];
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
 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1999');

 Writeln(txt,Space+'Включены в рассмотрение следующие виды операций:');
 Write(txt,Space);
 For c:=1 To Max2 Do
  Begin
   If SClient[c]=1 Then
    Case c Of
    1:Write(txt,' "Клиент" ');
    2:Write(txt,' "Склад" ');
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
   If SVidDoc[c]=1 Then
    Case c Of
    1:Write(txt,' "Список" ');
    2:Write(txt,' "Тов.Чек*" ');
    3:Write(txt,' "Физ.Л*" ');
    4:Write(txt,' "СФ*" ');
    5:Write(txt,' "СФ Б" ');
    6:Write(txt,' "Дебит*" ');
    7:Write(txt,' "Дебит СФ*" ');
    8:Write(txt,' "Дебит" ');
    9:Write(txt,' "Дебит СФБ" ');
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

 Writeln(txt,Space+'СПРАВКА О ДВИЖЕНИИ ТОВАРА ЗА ПЕРИОД С '+StartDAte+' ПО '+StopDAte);
 Writeln(txt,Space+'________________________________________________________________________________');
 Writeln(txt,Space+' Код  Наименование товара            Операции с клиентом     Операции со складом');
 Writeln(txt,Space+'                                  Колич.      Сумма, руб  Колич.      Сумма, руб');
                   {12345 12345678901234567890123456 1234567 123456789012345 1234567 123456789012345}
 Writeln(txt,Space+'________________________________________________________________________________');

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
    Writeln(txt,Space+s);

 For k:=1 To Max6 Do
  Begin
   If SVidOperation[k]=1 Then
    Case k Of
    1:Begin
      Write(txt,Space+'                          Приход:');
       If SClient[1]=1 Then
       Begin
       st:=Copy(ws,1+CNAme+1+CArtikul+1,(Ckol+2)+1+CIZena);
       Write(txt,st);
       End;
       If SClient[2]=1 Then
       Begin
       st:=Copy(ws,1+CNAme+1+CArtikul+1+(Ckol+2)+1+CIZena+1,(Ckol+2)+1+CIZena);
       Write(txt,st);
       End;
       Writeln(txt);
      End;
    2:Begin
      Write(txt,Space+'                        Отгрузка:');
      Writeln(txt);
      End;
    3:Begin
      Write(txt,Space+'                         Возврат:');
      Writeln(txt);
      End;
    4:Begin
      Write(txt,Space+'                      Переоценка:');
      Writeln(txt);
      End;
    5:Begin
      Write(txt,Space+'                         Ревизия:');
      Writeln(txt);
      End;
    6:Begin
      Write(txt,Space+'                             Р/П:');
      Writeln(txt);
      End;
    Else;
    End;
  End;
    Writeln(txt,Space+'________________________________________________________________________________');


 End;{For}


End;{If}


 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'================================================================================');


 System.Close(txt);
 NoInfoMsg;
 Report(Path.ToTemp+'stattvr.txt','',1,False,False);
End;


procedure TCalcTovarWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;


Var s : String;
    Test : Word;
Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Begin
                     ClearFind;
                     Calculator;
                    End;
        cmOk       :Begin
                     ClearFind;
                     ClearEvent(Event);
                    End;
     cmPrintReestr:Begin
                     If (ScreenList^.List<>Nil)And(ScreenList^.List^.Count>=1) Then
                       Begin
                        ClearFind;
                        PrevCurLoc[0]:=#0;
                        FormReport(ScreenList);
                       End;
                     ClearEvent(Event);
                    End;
   Else;
   End;
   EvKeyDown       :
       Case Event.KeyCode Of
        kbAltF9   : Begin
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


Destructor TCalcTovarWindow.Done;
Begin
TDialog.Done;
End;




Begin
 StopDate:=FDate;
 StartDate:=DateToDateString(DateMask,DateStringtoDate(DateMask,StopDate)-30);
End.
