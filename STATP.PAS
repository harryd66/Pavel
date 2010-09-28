{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit StatP;


Interface


Uses Dialogs,Drivers,Glob,Access,LockInfo,ServStr,MyCalc,DStat,Serv;



Type{окно подробная раскладка по документам,просмотр документов,
     просмотр оплаты}
  PLocCalcMakeWindow = ^TLocCalcMakeWindow;
  TLocCalcMAkeWindow = object(TDialog)
    Calc        : PMyCalculator;
    Procedure Start;
    Procedure FormReport(Spis:PBox);
    Procedure FullPreview;
    Procedure DrawCurrent;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;virtual;
  end;



Type {окно результат запроса к БД клиент-сумма}
  PCalcMakeWindow = ^TCalcMakeWindow;
  TCalcMakeWindow = object(TDialog)
    LocCalc : PLocCalcMAkeWindow;
    Calc        : PMyCalculator;
    Procedure Start(Var l: Boolean);
    Procedure Refresh;
    Procedure FreshReiting;
    Procedure FormReport(S:PBox);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;virtual;
  end;

Type {главное окно статистики,фильтры документов,оплаты,выбор клиентов}
  PSelectMakeWindow = ^TSelectMakeWindow;
  TSelectMakeWindow = object(TDialog)
    GroupCalcWindow : PCalcMakeWindow;
    procedure OpenSelectMakeWindow;
    procedure DrawCurrent;
    procedure Refresh;
    procedure AddName;
    Procedure FullPreview;
    constructor Init(Var l: Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

Implementation

uses DBEngine,Objects, Views, MsgBox,Protect,{Calc,}TPDate,Market,Tools,Printers,UtilsP,
     App, ColorTxt,Validate,Nastr,Vision1,Vision2,Vision3,Vision4,NetDbEng,Utils;

var
  Reiting,PrevCurrent,PrevCur : String;
 ClientStatWindow : PSelectMakeWindow;
 SelectMake,CalcList,TempCalcList,LocCalcList : PBox;
 CalcWindow : PCalcMakeWindow;
 LocCalcMakeWindow : PLocCalcMAkeWindow;

 Prevs: TEnjoyStr;
 {Метки в окне последних цен}
 sControlPos,
 sControl,
 sControlStartDate,
 sControlVidFiltr,
 sControlOperationFiltr,
 sControlStopDate: PView;
 SControlSort,SControlVidSort,SControlReiting:PView;

 sControlVidDoc,sControlSkidka,sControlItogo,sControlDoc,
 sControlItogoSkidka:PView;

 Ws : String[CIZena];
 LastClientKod : ArtikulStr;
 PrevPosition : TMyString;
 Operation,Bufer : Word;{вид операций и буфер и введенные на склад}
 ss : Maska2;{буфер введенные на склад}
 StopDate ,StartDate ,StopDateA ,StartDateA : TDateString;
 VidSorting,Sorting : Word;
 AllSumma,AllSummaPrhR,AllSummaPrhZ : String[CIZena+5];


procedure MakeFile(Const VarList:PBox);
Var
   Cur : LongInt;
      F: File;
      I : Byte;
  Artikul : ArtikulStr;
Begin
 DInfoMsg('Создаю временные файлы...');
 For cur:=0 To VarList^.List^.Count-1 Do
  Begin
   Artikul:=Copy(VarList^.GetText(cur,VarList^.List^.Count),1+CClient+1,CMakeKod);

   {приход}
       Assign(f,Path.ToAnalys+Artikul+'.prh');
       i:=IOResult;
       Rewrite(f);
       i:=IOResult;
       If I<>0 Then
	   MessageBox(^M+#3+'Ошибка создания файла '+Path.ToAnalys+Artikul+'.prh'+
	   ClicProgrammer,nil,mfError+mfCancelButton)
        Else Close(f);
  End;
 NoInfoMsg;
End;


procedure EraseFile(Const VarList:PBox);
Var
   Cur : LongInt;
      F: File;
      I : Byte;
  Artikul : ArtikulStr;
Begin
 DInfoMsg('Удаляю временные файлы...');
 For cur:=0 To VarList^.List^.Count-1 Do
  Begin
   Artikul:=Copy(VarList^.GetText(cur,VarList^.List^.Count),1+CClient+1,CMakeKod);

       Assign(f,Path.ToAnalys+Artikul+'.prh');
       i:=IOResult;
       Erase(f);
       i:=IOResult;
       If I<>0 Then
	   MessageBox(^M+#3+'Ошибка удаления файла '+Path.ToAnalys+Artikul+'.prh'+
	   ClicProgrammer,nil,mfError+mfCancelButton)
        Else Close(f);
  End;
 NoInfoMsg;
End;



procedure TSelectMakeWindow.OpenSelectMakeWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmMakeStat, nil) = nil then
  begin
    DInfo('Инициализация анализа...');
    L:=True;
    ClientStatWindow := New(PSelectMakeWindow, Init(L));
    If L Then
    Begin
    NoInfo;
    Application^.InsertWindow(ClientStatWindow);
    End
    Else
        Begin
         Status:=DocNormal;
         NoInfo;
         Dispose(ClientStatWindow,Done);
        End;
  end
  else
    if PView(ClientStatWindow) <> Desktop^.TopView then ClientStatWindow^.Select;
end;



constructor TSelectMakeWindow.Init(Var l : Boolean);
Var R : TRect;
    i : Word;
    s : String[CIZena];
Begin
L:=False;
R.Assign(0, 0, 80, 23);
inherited Init(R, '');
TekDate:=FDate;
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E602;

R.Assign(52, 0, 62, 1);
SControlStartDate := New(PInputLine, Init(R, CDate));
Insert(sControlStartDate);
  PInputLine(SControlstartDate)^.Validator := New(PPXPictureValidator, Init(DAteFiltr{'##-##-9#'}, True));

  R.Assign(39, 0, 52, 1);
  Insert(New(PLabel, Init(R, 'З~а~ период с:', SControlStartDAte)));
s:='01-01-09';{специально для бакши}

SControlStartDate^.SetData(s);


R.Assign(66, 0, 76, 1);
sControlStopDate := New(PInputLine, Init(R, CDate));
Insert(sControlStopDate);
  PInputLine(sControlStopDate)^.Validator := New(PPXPictureValidator, Init(DAteFiltr{'##-##-9#'}, True));

  R.Assign(62, 0, 66, 1);
  Insert(New(PLabel, Init(R, '~п~о:', SControlStopDate)));

SControlStopDate^.SetData(FDate);

Operation:=2;
Bufer:=3;

R.Assign(15, 1, 50, 2);
  SControlOperationFiltr := New(PRadioButtons, Init(R,
  NewSItem('Кл~и~ент',
  NewSItem('~С~клад',
  NewSItem('~О~бмен', Nil)))));
  Insert(SControlOperationFiltr);

  R.Assign(1, 1, 15, 2);
  Insert(New(PLabel, Init(R, 'Вид операций:', SControlOperationFiltr)));

SControlOperationFiltr^.SetData(Operation);

  R.Assign(53, 1, 79, 2);
  SControlVidFiltr := New(PCheckboxes, Init(R,
  NewSItem('Вве~д~енные',
  NewSItem('Буф~е~р', Nil))));
  Insert(SControlVidFiltr);

SControlVidFiltr^.SetData(Bufer);



R.Assign(52, 3, 53, 22);
SControl := New(PScrollBar, Init(R));
Insert(SControl);

R.Assign(0, 3, 52, 22);
MakeList := New(PBox, Init(R, 2, PScrollbar(SControl)));
MakeList^.NewList(New(PTextCollection, Init(0,1)));
MakeList^.FocusItem(0);
MakeList^.HelpCtx:=$E586;
Insert(MakeList);


  R.Assign(1, 2, 19, 3);
  Insert(New(PLabel, Init(R, 'Ба~з~а поставщиков:', MakeList)));


R.Assign(79, 3, 80, 22);
SControl := New(PScrollBar, Init(R));
Insert(SControl);

R.Assign(53, 3, 79, 22);
SelectMake := New(PBox, Init(R, 1, PScrollbar(SControl)));
SelectMake^.NewList(New(PTextCollection, Init(0,1)));
SelectMake^.FocusItem(0);
SelectMake^.HelpCtx:=$E596;
Insert(SelectMake);

  R.Assign(53, 2, 79, 3);
  Insert(New(PLabel, Init(R, '~В~ыбранные поставщики  Код', SelectMake)));

R.Assign(22, 22, 43, 23);
SControl := New(PColoredText, Init(R, ' Выбрано поставщиков:', $74));
Insert(SControl);

R.Assign(43, 22, 48, 23);
SControlPos := New(PColoredText, Init(R, #3+'???', $4E));
Insert(SControlPos);

R.Assign(2, 0, 36, 1);
SControl := New(PColoredText, Init(R, ' Формирование выборки поставщиков ', $4F));
Insert(SControl);


SelectNext(False);
AddNAme;
PrevCurrent[0]:=#0;
L:=True;
Refresh;
End;



procedure TSelectMakeWindow.AddName;

Var R : TRect;
    R1,R2 : Real;
    KolStr : String[CKol];
Begin
  Str(SelectMake^.List^.Count:CKol,Kolstr);
  DelSpace(KolStr);
  Dispose(SControlPos,Done);
  R.Assign(43, 22, 48, 23);
  SControlPos := New(PColoredText, Init(R, #3+KolStr, $4E));
  Insert(SControlPos);
End;


procedure TSelectMakeWindow.DrawCurrent;
Var St : TEnjoyStr;
     R : TRect;
Begin
End;

procedure TSelectMakeWindow.FullPreview;
Begin
End;

procedure TSelectMakeWindow.Refresh;
Var s : String;
    f : ClientFileType;
    i : Word;
Begin
MakeList^.NewList(Nil);
MakeList^.NewList(New(PTextCollection, Init(0,1)));
Case Operation Of
0:s:=Path.ToClient+'make.db';
1:s:=Path.ToClient+'sklad.db';
2:s:=Path.ToClient+'barter.db';
Else;
End;
Assign(f,s);
i:=IOResult;
Reset(f);
i:=IOResult;

If i<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла постащиков!'^M+#3+ClicProgrammer,Nil,mfError+mfCancelButton);
  Exit;
 End;

While Not(Eof(f)) Do
 Begin
  ReadClient(f,ClientElement^.Dat);
  If ClientElement^.Dat.Employ Then
  Begin
  Format(ClientElement^.Dat.Name,CCLIent);
  Format(ClientElement^.Dat.Kod,CCLIentKod);
  s:=ClientElement^.Dat.Name+'│'+ClientElement^.Dat.Kod;
  PrevCurrent:=s;
  MakeList^.List^.Insert(NewStr(s));
  MakeList^.SetRange(MakeList^.List^.Count);
  End;
 End;

MakeList^.FocusItem(0);
System.Close(f);
Redraw;
End;



procedure TSelectMakeWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1 : String;
    SDoc : ArtikulStr;
    SDate: TDateString;
    ClientKod : ArtikulStr;
    Ls : LongInt;
    l : Boolean;
    sstart,sstop : TDateString;
begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
      kbIns: Begin
               ProdagaWindow:=False;
                ClearFind;
            If(MakeList^.State and sfFocused <> 0) And (MakeList^.List^.Count>=1) Then
            Begin
               s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.COunt);
               If TestElement(Copy(s,1+CClient+1,CClientKod),SelectMake) Then
               Begin
                s:=Copy(s,1,CCLient+1+CClientKod);
                SelectMake^.List^.Insert(NewStr(s));
                SelectMake^.SetRange(SelectMake^.List^.Count);
                ProdagaWindow:=False;
                s:=MakeList^.GetText(MakeList^.Focused,MakeList^.List^.COunt);
                s:=Copy(s,1+CClient+1,CClientKod);
                SelectMake^.FocusItem(LoCation(SelectMake,S,ProdagaWindow));
                If SelectMake^.Focused+1<SelectMake^.List^.Count Then
                SelectMake^.FocusItem(SelectMake^.List^.Count-1);
                PCluster(SControlOperationFiltr)^.SetButtonState($7,False);
               End;
               If (MakeList^.Focused+1)<MakeList^.List^.Count Then
               MakeList^.FocusItem(MakeList^.Focused+1);
            End;
              ClearEvent(Event);
              Redraw;
              AddName;
              PrevCurrent[0]:=#0;
            End;


  kbCtrLDel: Begin
               ClearFind;
               ProdagaWindow:=False;
     If (SelectMake^.State and sfFocused <> 0) And (SelectMake^.List<>Nil)And(SelectMake^.List^.Count>=1) Then
            Begin
             SelectMake^.NewList(nil);
             SelectMake^.NewList(New(PTextCollection, Init(0,1)));
             PCluster(SControlOperationFiltr)^.SetButtonState($7,True);
            End;
            ClearEvent(Event);
             Redraw;
             PrevCurrent[0]:=#0;
             AddName;
            End;

     kbDel: Begin
                ClearFind;
               ProdagaWindow:=False;
     If (SelectMake^.State and sfFocused <> 0) And (SelectMake^.List<>Nil)And(SelectMake^.List^.Count>=1) Then
            Begin
             SelectMake^.List^.AtFree(SelectMake^.Focused);
             SelectMake^.SetRange(SelectMake^.List^.Count);
             If SelectMake^.Focused>0 Then
             SelectMake^.FocusItem(SelectMake^.Focused);

             If (SelectMake^.Focused>=SelectMake^.List^.Count) and(SelectMake^.Focused>0) Then
             SelectMake^.FocusItem(SelectMake^.Focused-1);

              ClearEvent(Event);
        If (SelectMake^.List=Nil)or(SelectMake^.List^.Count=0) Then
              PCluster(SControlOperationFiltr)^.SetButtonState($7,True);
              Redraw;
              AddName;
            End;
              PrevCurrent[0]:=#0;
            End;

   kbGrayPlus,
   kbCtrlIns: Begin
                ClearFind;
                 ProdagaWindow:=False;
          If ((MakeList^.State and sfFocused <> 0)And(MakeList^.List^.Count>= 1)) Then
            Begin
             DInfo('Минуточку...');
             SelectMake^.Focusitem(0);
             If MakeList^.List^.Count>0 Then
             Begin
             SelectMake^.NewList(nil);
             SelectMake^.NewList(New(PTextCollection, Init(0,1)));

             For ls :=0 To MakeList^.List^.Count-1 Do
              Begin
               s:=MakeList^.GetText(ls,MakeList^.List^.Count);
               {if Testelement(Copy(s,1+CClient+1,CClientKod),SelectMake) then}
                Begin
                 s:=Copy(s,1,CCLient+1+CClientKod);
                 SelectMake^.List^.Insert(NewStr(s));
                 SelectMake^.SetRange(SelectMake^.List^.Count);
                End;
              End;
             End;
              NoInfo;
                 ProdagaWindow:=False;
                 {SelectMake^.SetRange(SelectMake^.List^.Count);}
                 If MakeList^.Focused+1<MakeList^.List^.Count Then MakeList^.FocusItem(MakeList^.Focused+1);
                 If SelectMake^.Focused+1<SelectMake^.List^.Count Then
                 SelectMake^.FocusItem(SelectMake^.List^.Count-1);
              PCluster(SControlOperationFiltr)^.SetButtonState($7,False);
             End
            Else ClearEvent(Event);
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
     AboutChm('35');
     ClearEvent(Event);
    end;

  cmFullView:Begin

             End;

  cmCalcStat :Begin
              ClearFind;
              If (SelectMake^.List<>Nil)And(SelectMake^.List^.Count>0)
		       Then
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
               {назначаем фильтр видов документов}
               SControlOperationFiltr^.GetData(Operation);

               {назначаем фильтр оплаты}
               sControlVidFiltr^.GetData(Bufer);


               GroupCalcWindow^.Start(l);

               {старт загрузки ответа на сформированный запрос}
               End
               Else
                Begin
              If (SelectMake^.List<>Nil)And(SelectMake^.List^.Count>0) Then
                 MessageBox(^M+#3'Список выбранных поставщиков - пустой!',Nil,mfError+mfCancelButton);
                 ClearEvent(Event);
                 Exit;
                End;

               PrevCurrent[0]:=#0;
              End;

cmMakeStat:Begin
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
    (Event.Command = cmClientStat) then ClearEvent(Event);



  inherited HandleEvent(Event);

  If (Desktop^.Current=PView(ClientStatWindow)) And (Event.What <> EvKeyDown) Then
   Begin
                DrawCurrent;
{
        If (SelectMake^.List<>Nil)And(SelectMake^.List^.Count>=1) Then
            Begin
                    PCluster(SControlOperationFiltr)^.SetButtonState($7,False);
                    Redraw;
            End
        Else
            Begin
                    PCluster(SControlOperationFiltr)^.SetButtonState($7,True);
                    Redraw;
            End;
}
                if (sControlOperationFiltr^.State and sfFocused <> 0)Then
                    Begin
                        sControlOperationFiltr^.GetData(Test);
                        If Test <> Operation Then
                        Begin
                           ClearFind;
                           Operation:=Test;
                           Refresh;
                           PrevCurrent[0]:=#0;
                        End;
                    End;

   End;
end;

Procedure TCalcMakeWindow.Start(Var l : Boolean);
Var R : TRect;
    Res,C : Word;
    Control : PView;
    i,Cur,Min,Max,k,j : LongInt;
    s,ws1,ws2 : String;
    SummaPrhZ,SummaPrhR:String[CIZena];
    SClientKod,SDoc : String[CClientKod];
    Add , Find : Boolean;
    Er : PPrihodType;
    Ef : PrihodFileType;

Function WriteToFile(sP: PPrihodType):Boolean;
var Es: PrihodFileType;
    i : Word;
Begin
 Assign(es,Path.ToAnalys+Sp^.Dat.MakeKod+'.prh');
 i:=IOResult;
 Reset(es);
 i:=IOResult;
 If i<>0 Then
 Begin
  MessageBox(^M+#3+'Ошибка запсиси '+Path.ToAnalys+Sp^.Dat.MakeKod+'.prh!'^M+
  #3+ClicProgrammer,Nil,mfError+mfCancelButton);
  Exit;
 End;
 Seek(es,FileSize(es));
 Write(es,Sp^.DAt);
 System.Close(es);
 i:=IOResult;
End;



Begin
{AInfo('Формирую выборку...');}
MakeFile(SelectMAke);
R.Assign(0, 0, 67, 23);
New(CalcWindow, Init(R, 'Приходы от выбранных поставщиков с '+StartDate+' по '+StopDate));
CalcWindow^.Options := CalcWindow^.Options or ofCenterX;
CalcWindow^.HelpCtx := $E191;


R.Assign(0,0,0,0);
TempCalcList := New(PBox, Init(R, 1, Nil));
TempCalcList^.NewList(New(PTextCollection, Init(0,1)));

 WordToBit2(Bufer,ss);
 Convert2(ss);

  Min:=DateStringToDate(DateMask,StartDate);
  Max:=DateStringToDate(DateMask,StopDate);

  AllSumma[0]:=#0;
  AllSummaPrhR[0]:=#0;
  AllSummaPrhZ[0]:=#0;

New(Er,Init);
If (SelectMake^.List^.Count>0) Then
Begin
For cur:=Min To Max Do
 Begin
  s:=DateToDateString(DateMask,Cur);
  DInfoMsg('Просматриваю приходы за '+s+'...');
  SummaPrhZ[0]:=#0;
  SummaPrhZ[0]:=#0;
  SDoc[0]:=#0;
  Assign(Ef,Path.ToPrihod+s+'.prh');
  i:=IOResult;
  Reset(ef);
  i:=IOResult;
  If I=0 Then
   Begin
    While Not(Eof(Ef))Do
     Begin
      ReadPrihod(Ef,Er);
      If (StrToInt(Er^.Dat.SkladKod)=StrToInt(Rek.Kod)) Then
      If (Er^.Dat.OperatorSelector=Operation) And (ss[Er^.Dat.StatusDoc+1]=1) Then
      Begin
      If Not(TestElement(Er^.Dat.MakeKod,SelectMake)) Then
       Begin
         WriteToFile(Er);
         {если поставщика нет в списке}
         If (TestElement(Er^.Dat.MakeKod+'│',TempCalcList)) Then
          Begin
           ws1:=GetMakeField(FMake,Er^.Dat.MakeKod,Operation);
           Format(ws1,CMake);
           Str(StrToReal(Er^.Dat.SummaZakupka):CIZena:CMantissa,ws2);
           Str(StrToReal(Er^.Dat.SummaR)+StrToReal(AllSummaPrhR):CIZena:CMantissa,AllSummaPrhR);
           Str(StrToReal(Er^.Dat.SummaZakupka)+StrToReal(AllSummaPrhZ):CIZena:CMantissa,AllSummaPrhZ);
           ws1:=ws1+'│'+Er^.Dat.MakeKod+'│'+ws2;
           Str(StrToReal(Er^.Dat.SummaR):CIZena:CMantissa,ws2);
           ws1:=ws1+'│'+ws2+'│'+'    1│';
           TempCalcList^.List^.Insert(NewStr(ws1));
           TempCalcList^.SetRange(TempCalcList^.List^.Count);
          End
         Else
         {если поставщик есть в списке}
          Begin
           i:=Location(TempCalcList,Er^.Dat.MakeKod+'│',False);
           ws1:=TempCalcList^.GetText(i,TempCalcList^.List^.Count);
           {вставляем закпку}
           ws2:=Copy(ws1,1+CClient+1+CMakeKod+1,CIZena);
           System.Delete(ws1,1+CClient+1+CMakeKod+1,CIZena);
           Str(StrToReal(ws2)+StrToReal(Er^.Dat.SummaZakupka):CIZena:CMantissa,ws2);

           Str(StrToReal(Er^.Dat.SummaZakupka)+StrToReal(AllSummaPrhZ):CIZena:CMantissa,AllSummaPrhz);

           System.Insert(ws2,ws1,1+CClient+1+CMakeKod+1);

           {вставляем продажу}
           ws2:=Copy(ws1,1+CClient+1+CMakeKod+1+CIZena+1,CIZena);
           System.Delete(ws1,1+CClient+1+CMakeKod+1+CIZena+1,CIZena);
           Str(StrToReal(ws2)+StrToReal(Er^.Dat.SummaR):CIZena:CMantissa,ws2);

           Str(StrToReal(Er^.Dat.SummaR)+StrToReal(AllSummaPrhR):CIZena:CMantissa,AllSummaPrhR);

           System.Insert(ws2,ws1,1+CClient+1+CMakeKod+1+CIZena+1);

           {увеличиваем счетчик документов}
           ws2:=Copy(ws1,1+CClient+1+CMakeKod+1+CIZena+1+CIZena+1,CKol);
           System.Delete(ws1,1+CClient+1+CMakeKod+1+CIZena+1+CIZena+1,CKol);
           ws2:=IntToStr((StrToInt(ws2)+1),CKol);
           DelSpace(ws2);
           RFormat(ws2,CKol);
           System.Insert(ws2,ws1,1+CClient+1+CMakeKod+1+CIZena+1+CIZena+1);
           TempCalcList^.List^.Atfree(i);
           TempCalcList^.SetRange(TempCalcList^.List^.Count);

           TempCalcList^.List^.Insert(NewStr(ws1));
           TempCalcList^.SetRange(TempCalcList^.List^.Count);
          End;
       End;{TestElement}
       End;{OperatorSelector}
	End;{While}
     i:=IOResult;
     System.Close(Ef);
     i:=IOResult;
   End;{IOResult<>0}
 NoInfoMsg;
 End;{For}
End;{SelectMake^.List^.Count>0}

Dispose(Er,Done);

R.Assign(1, 1, 48, 2);
SControlSort := New(PRadioButtons, Init(R,
  NewSItem('По~с~тавщик',
  NewSItem('E ~з~акупка',
  NewSItem('E ~п~родажа', Nil)))));
Sorting:=0;
SControlSort^.SetData(Sorting);

CalcWindow^.Insert(SControlSort);

{
  R.Assign(1, 0, 13, 1);
  CalcWindow^.Insert(New(PLabel, Init(R, 'Сортировка:', SControlSort)));
}

R.Assign(52, 1, 66, 2);
SControlVidSort := New(PRadioButtons, Init(R,
  NewSItem(#30,
  NewSItem(#31, Nil))));

VidSorting:=0;

SControlVidSort^.SetDAta(VidSorting);

CalcWindow^.Insert(SControlVidSort);

  R.Assign(47, 1, 52, 2);
  CalcWindow^.Insert(New(PLabel, Init(R, '~Т~ип:', SControlVidSort)));

R.Assign(66, 3, 67, 22);
Control := New(PScrollBar, Init(R));
CalcWindow^.Insert(Control);

R.Assign(1, 3, 66, 22);
CalcList := New(PBox, Init(R, 1, PScrollbar(Control)));
CalcList^.NewList(New(PMyCollection, Init(0,1)));
CalcList^.HelpCtx:={F087}$E612;
CAlcList^.FocusItem(0);
CalcWindow^.Insert(CalcList);

  R.Assign(1, 2, 66, 3);
  CalcWindow^.Insert(New(PLabel, Init(R, 'Поста~в~щик             Код Сумма по З/Цен. Сумма по Р/Цен. Док.',
  CalcList)));


R.Assign(2, 22, 13, 23);
Control := New(PColoredText, Init(R, 'E Закупка:', $74));
CalcWindow^.Insert(Control);

R.Assign(13, 22, 28, 23);
Str(StrToReal(AllSummaPrhZ):CIZena:CMantissa,AllSummaPrhZ);
DelSpace(AllSummaPrhZ);
Control := New(PColoredText, Init(R, #3+AllSummaPrhZ, $4E));
CalcWindow^.Insert(Control);

R.Assign(28, 22, 39, 23);
Control := New(PColoredText, Init(R, ' E Продажа:', $74));
CalcWindow^.Insert(Control);

R.Assign(39, 22, 54, 23);
Str(StrToReal(AllSummaPrhR):CIZena:CMantissa,AllSummaPrhR);
DelSpace(AllSummaPrhR);
Control := New(PColoredText, Init(R, #3+AllSummaPrhR, $4E));
CalcWindow^.Insert(Control);

R.Assign(57, 22, 62, 23);
SControlReiting := New(PColoredText, Init(R, #3+'1', $4E));
CalcWindow^.Insert(SControlReiting);
Reiting[0]:=#0;

R.Assign(54, 22, 57, 23);
Control := New(PColoredText, Init(R, ' N:', $74));
CalcWindow^.Insert(Control);

CalcWindow^.SelectNext(False);

{NoInfo;}

Refresh;

c:=Desktop^.ExecView(CalcWindow);

l:=True;

Dispose(Control,Done);
Dispose(TempCalcList,Done);
Dispose(CalcWindow,Done);
EraseFile(SelectMAke);

End;




Procedure TCalcMakeWindow.Refresh;
Var i,j : Word;
    ws,ws1 : String;
    TempBox : PBox;
    R : TRect;
Begin

R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

CalcList^.NewList(Nil);
CalcList^.NewList(New(PMyCollection, Init(0,1)));


DInfoMsg('Сортирую выборку...');



If VidSorting=1 Then
DistanationSorting:=False
Else
DistanationSorting:=True;


If TempCalcList^.List^.Count>0 Then
Begin
{формируем отсортированый список}
For j:=0 to TempCalcList^.List^.Count-1 Do
Begin
 ws:=TempCalcList^.GEtText(j,TempCalcList^.List^.Count);
Case Sorting Of
{поставщик}
0:ws:=ws;
{сумма закупки}
1:Begin
   ws1:=Copy(ws,1+CClient+1+CClientKod+1,CIZena);
   System.Delete(ws,1+CClient+1+CClientKod+1,CIZena+1);
   ws:=ws1+' '+ws;
  End;
{сумма продажи}
2:Begin
   ws1:=Copy(ws,1+CClient+1+CClientKod+1+CIZena+1,CIZena);
   RFormatZerro(ws1,CIZena);
   {System.Delete(ws,1+CClient+1+CClientKod+1+CIZena+1,CIZena+1);}
   ws:=ws1+' '+ws;
  End;
Else;
End;{CAse}
  TempBox^.List^.Insert(NewStr(ws));
  TempBox^.SetRange(TempBox^.List^.Count);
End;



{форматируем сформированый список под экранную форму}
If TempBox^.List^.Count>0 Then
Begin
For j:=0 to TempBox^.List^.Count-1 Do
Begin
  ws:=TempBox^.GEtText(j,TempBox^.List^.Count);

Case Sorting Of
{клиент}
0:ws:=ws;
{сумма отгрузки}
1:Begin
   ws1:=Copy(ws,1,CIZena);
   System.Delete(ws,1,CIZena+1);
   System.Insert(ws1+'│',ws,1+CClient+1+CClientKod+1);
  End;
{сумма скидки}
2:Begin
   ws1:=Copy(ws,1,CIZena);
   System.Delete(ws,1,CIZena+1);
   {System.Insert(ws1+'│',ws,1+CClient+1+CClientKod+1+CIZena+1);}
  End;
Else;
End;{CAse}

  CalcList^.List^.Insert(NewStr(ws));
  CalcList^.SetRange(CalcList^.List^.Count);
End;
End;
End;{If TempCalcList^.List^.Count>0 Then}


NoInfoMsg;


Dispose(TempBox,Done);

CalcList^.FocusItem(0);

DistanationSorting:=True;

End;


Procedure TCalcMakeWindow.FormReport(S:PBox);
Const Space='         ';
Var Txt : Text;
    k,c : Word;
    ws : String;
    Numer : ArtikulStr;
Begin
{$IFDEF DPMI}
 Assign(txt,Path.ToTemp+'selprih.txt');
 c := IOResult;
 Rewrite(txt);
 c:=IoResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3+'Не могу создать файл '+Path.ToTemp+'coborot.txt!',Nil,mfError+mfCancelButton);
   Exit;
  End;
 DInfoMsg('Формирую отчет. Ждите...');
 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');
 Writeln(txt,Space+'Включены в рассмотрение документы со статусом:');
 Write(txt,Space);
 For c:=1 To Max2 Do
  Begin
   If ss[c]=1 Then
    Case c Of
    1:Write(txt,' "Введен на склад" ');
    2:Write(txt,' "Буфер" ');
    Else;
    End;
  End;
 Writeln(txt);

 Write(txt,Space+'Вид операций:');
    Case Operation Of
    0:WriteLN(txt,' "Клиент" ');
    1:WriteLN(txt,' "Склад" ');
    2:WriteLn(txt,' "Обмен" ');
    Else Writeln(txt);
    End;

 Write(txt,Space+'Вид сортировки:');
    Case Sorting Of
    0:Writeln(txt,' "Поставщик" ');
    1:Writeln(txt,' "Сумма по закупочным ценам" ');
    2:Writeln(txt,' "Сумма по продажным ценам" ');
    Else Writeln(txt);
    End;
 Writeln(txt);

  AllSummaPrhZ[0]:=#0;
  AllSummaPrhR[0]:=#0;


 Writeln(txt,Space+' СПРАВКА ПО ПРИХОДАМ ОТ ПОСТАВЩИКОВ ЗА ПЕРИОД с '+StartDate+' по '+StopDate);
 Writeln(txt,Space+'---------------------------------------------------------------------');
 Writeln(txt,Space+' N    Поставщик             Код   Сумма З/Ц        Сумма Р/Ц    Док.');
 Writeln(txt,Space+'---------------------------------------------------------------------');
                   {12345│12345678901234567890│1234│123456789012345│123456789012345│12345}
 For c:=0 To S^.List^.Count-1 Do
 Begin
    ws := S^.GetText(c,S^.List^.Count);
    Str(StrToReal(AllSummaPrhZ)+StrToReal(Copy(ws,1+CCLient+1+CClientKod+1,CIZena)):CIZena:CMantissa,AllSummaPrhZ);
    Str(StrToReal(AllSummaPrhR)+StrToReal(Copy(ws,1+CCLient+1+CClientKod+1+CIZena+1,CIZena)):CIZena:CMantissa,AllSummaPrhR);

    While Pos('│',ws)>0 Do
    Begin
     k:=Pos('│',ws);
     System.Delete(ws,k,1);
     System.Insert(' ',ws,k);
    End;
    Str(c+1:CArtikul,Numer);
    ws:=Numer+' '+ws;
    Writeln(txt,Space+Ws);
 End;
 Writeln(txt,Space+'---------------------------------------------------------------------');
 Writeln(txt,Space+'                         Всего по закупочным ценам: '+Recogniz(AllSummaPrhZ));
 Writeln(txt,Space+'                          Всего по продажным ценам: '+Recogniz(AllSummaPrhR));
If (StrToReal(AllSummaPrhZ)>0.009) Then
 Begin
  Writeln(txt,Space+'                                          Наценка: '+RecognizReal(
  (StrToReal(AllSummaPrhR)-StrToReal(AllSummaPrhZ))
   /StrToReal(AllSummaPrhZ)*100,CIZena,CMAntissa));
 End;
  Writeln(txt,Space+'                                            Delta: '+RecognizReal(
  (StrToReal(AllSummaPrhR)-StrToReal(AllSummaPrhZ)),CIZena,CMAntissa));
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'=====================================================================');


 System.Close(txt);
 NoInfoMsg;
 Report(Path.ToTemp+'selprih.txt','',1,False,False,false);
{$EndIF}
End;

procedure TCalcMakeWindow.HandleEvent(var Event: TEvent);
procedure Calculator;
begin
  Calc^.Start;
end;


Var Test : Word;
    s : String;

Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Begin
                     ClearFind;
                        Calculator;
                    End;
        cmView     :Begin
              if (CalcList^.List<>Nil) And (CalcList^.List^.Count>=1)Then
              Begin
                     ClearFind;
                     LocCalc^.Start;
                     PrevCur[0]:=#0;
              End;
                    End;
        cmOk       :Begin
                     ClearFind;
                     ClearEvent(Event);
                    End;
     cmReestrReport:Begin
                     If (CalcList^.State and sfFocused <> 0) And (CalcList^.List<>Nil)And(CalcList^.List^.Count>=1) Then
                       Begin
                        ClearFind;
                        FormReport(CalcList);
                        PrevCur[0]:=#0;
                       End;
                     ClearEvent(Event);

                    End;
   Else;
   End;
   EvKeyDown       :
       Case Event.KeyCode Of
       kbF5 :Begin
              ClearFind;
              Event.What:=EvCommand;
              Event.Command:=cmView;
              PutEvent(Event);
              ClearEvent(Event);
              PrevCur[0]:=#0;
             End;
      Else;
      End;
   Else;
   End;

  if ((Event.What = evMouseDown) and (Event.Double)) And
  ((CalcList^.State and sfFocused <> 0) And (CalcList^.List<>Nil)And(CalcList^.List^.Count>=1))Then
  begin
    Event.What:=evCommand;
    Event.Command:=cmView;
    PutEvent(Event);
    ClearEvent(Event);
    PrevCur[0]:=#0;
  end;




inherited HandleEvent(Event);


  If (Desktop^.Current=PView(CalcWindow)) And (Event.What <> EvKeyDown) Then
  Begin

              if {(CalcList^.State and sfFocused <> 0)  And}(CalcList^.List<>Nil) And (CalcList^.List^.Count>=1)Then
              Begin
               s:=CalcList^.GetText(CalcList^.Focused,CalcList^.List^.Count);
               If s <> Reiting Then
                 Begin
                  FreshReiting;
                 End
              End;


                if (sControlSort^.State and sfFocused <> 0)Then
                    Begin
                        sControlSort^.GetData(Test);
                        If Test <> Sorting Then
                        Begin
                           ClearFind;
                           Sorting:=Test;
                           Refresh;
                           Redraw;
                           Reiting[0]:=#0;
                        End;
                    End;

                if (sControlVidSort^.State and sfFocused <> 0)Then
                    Begin
                        sControlVidSort^.GetData(Test);
                        If Test <> VidSorting Then
                        Begin
                           ClearFind;
                           VidSorting:=Test;
                           Refresh;
                           Redraw;
                           Reiting[0]:=#0;
                        End;
                    End;
  End;


ClearEvent(Event);
End;


Procedure TCalcMakeWindow.FreshReiting;
VAr R :TRect;
    s : ArtikulStr;
    ws : ArtikulStr;
Begin
If (CalcList^.List^.Count>=1) Then
Begin
Dispose(SControlReiting,Done);
R.Assign(57, 22, 62, 23);
Reiting:=CalcList^.GetText(CalcList^.Focused,CalcList^.List^.Count);
Str((CalcList^.Focused+1):Ckol,s);
DelSpace(s);
SControlReiting := New(PColoredText, Init(R, #3+s, $4E));
CalcWindow^.Insert(SControlReiting);
Redraw;
End;
End;



Destructor TCalcMakeWindow.Done;
Begin
Dispose(SControlSort,Done);
Dispose(SControlVidSort,Done);
Dispose(SControlReiting,Done);
TDialog.Done;
End;


Procedure TLocCalcMAkeWindow.Start;
Var R : TRect;
    Res,C : Word;
    Control : PView;
    Cur,Min,Max,k,j : LongInt;
    ws,s : String;
    Es : PPrihodType;
    Esf : PrihodFileType;
    SummaPrhZ,SummaPrhR:String[CIZena];
    ClientKod,SDoc : String[CClientKod];
    Add , Find : Boolean;
Begin
ClientKod:=Copy(CalcList^.GetText(CalcList^.Focused,CalcList^.List^.Count),1+CClient+1,CMakeKod);
s:=GetMakeField(FMake,ClientKod,Operation);
DelSpaceRight(ws);

R.Assign(0, 0, 80, 23);
New(LocCalcMAkeWindow, Init(R, 'Приходы от поставщика '+s+' ('+ClientKod+') с '+StartDAte+' по '+StopDate));
LocCalcMAkeWindow^.Options := LocCalcMAkeWindow^.Options or ofCenterX or ofCenterY;
LocCalcMAkeWindow^.HelpCtx:=$E618;

TekDate:=FDate;

R.Assign(79, 2, 80, 21);
Control := New(PScrollBar, Init(R));
LocCalcMAkeWindow^.Insert(Control);

R.Assign(1, 2, 79, 21);
LocCalcList := New(PBox, Init(R, 1, PScrollbar(Control)));
LocCalcList^.NewList(New(PMyCollection, Init(0,1)));

  Min:=DateStringToDate(DateMask,StartDate);
  Max:=DateStringToDate(DateMask,StopDate);


 Assign(Esf,Path.ToAnalys+ClientKod+'.prh');
 j:=IOResult;
 Reset(Esf);
 j:=IOResult;

  AllSummaPrhZ[0]:=#0;
  AllSummaPrhR[0]:=#0;

 If j=0 Then
Begin
AInfo('Минуточку...');
Cur:=0;
 New(Es,Init);
 While Not(Eof(Esf)) Do
  Begin
   Read(Esf,Es^.Dat);
  If (StrToInt(Es^.Dat.SkladKod)=StrToInt(Rek.Kod)) Then
  If (ss[Es^.Dat.StatusDoc+1]=1) Then
   Begin
    RFormatZerro(Es^.Dat.Document,CDocNumer);
    Format(Es^.Dat.Document,CDocNumer);
    s:='│'+Es^.Dat.Document+'│'+Es^.Dat.DateC+'│'+Es^.Dat.TimeC+'│';
    DelSpace(Es^.Dat.SummaR);
    RFormat(Es^.Dat.SummaR,CIZena);
    DelSpace(Es^.Dat.SummaZakupka);
    RFormat(Es^.Dat.SummaZakupka,CIZena);
    Str(StrToReal(AllSummaPrhR)+StrToReal(Es^.Dat.SummaR):CIZena:CMantissa,AllSummaPrhR);
    DelSpace(AllSummaPrhR);
    Str(StrToReal(AllSummaPrhZ)+StrToReal(Es^.Dat.SummaZakupka):CIZena:CMantissa,AllSummaPrhZ);
    DelSpace(AllSummaPrhZ);
    s:=s+Es^.Dat.SummaZakupka+'│'+Es^.Dat.SummaR+'│';
    ws:=GetOperatorName(Es^.Dat.Caption);
    Format(Ws,CKto);
    s:=s+ws+'│'+Es^.Dat.TimeM;
    Str(Es^.Dat.StatusDoc:1,ws);
    s:=s+'│'+ws+'│'+IntToStr(Es^.Dat.OperatorSelector,COne);
    LocCalcList^.List^.Insert(NewStr(s));
    LocCalcList^.SetRange(LocCalcList^.List^.Count);
   End;{If StatusDoc=0}

  End;{While}

 Dispose(Es,Done);

 System.Close(Esf);

 End{If}
 Else
  Begin
   MessageBox(^M+#3+'Не могу открыть файл '+Path.ToAnalys+ClientKod+'.prh'+'!',Nil,mfError+mfCancelButton);
  End;


  Str(StrToReal(AllSummaPrhZ):CIZena:CMantissa,AllSummaPrhZ);
  Str(StrToReal(AllSummaPrhR):CIZena:CMantissa,AllSummaPrhR);



LocCalcList^.HelpCtx:=$F061;
LocCalcList^.FocusItem(0);
LocCalcMAkeWindow^.Insert(LocCalcList);

  R.Assign(2, 1, 78, 2);
  LocCalcMAkeWindow^.Insert(New(PLabel, Init(R,
' N     Дата    Время  Сумма по З/Ценам Сумма по Р/Ценам  Оператор   Изменен.',
  LocCalcList)));


R.Assign(2, 21, 9, 22);
Control := New(PColoredText, Init(R, 'Статус:', $74));
LocCalcMAkeWindow^.Insert(Control);

R.Assign(9, 21, 24, 22);
sControlVidDoc := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcMAkeWindow^.Insert(sControlVidDoc);

R.Assign(28, 21, 41, 22);
Control := New(PColoredText, Init(R, 'Вид операции:', $74));
LocCalcMAkeWindow^.Insert(Control);

R.Assign(41, 21, 47, 22);
sControlSkidka := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcMAkeWindow^.Insert(sControlSkidka);

R.Assign(49, 22, 63, 23);
Control := New(PColoredText, Init(R, ' Итого по З/Ц:', $74));
LocCalcMAkeWindow^.Insert(Control);

R.Assign(63, 22, 79, 23);
DelSpace(AllSummaPrhZ);
sControlItogo := New(PColoredText, Init(R, #3+AllSummaPrhZ, $4E));
LocCalcMAkeWindow^.Insert(sControlItogo);

R.Assign(18, 22, 32, 23);
Control := New(PColoredText, Init(R, ' Итого по Р/Ц:', $74));
LocCalcMAkeWindow^.Insert(Control);

R.Assign(32, 22, 48, 23);
DelSpace(AllSummaPrhR);
sControlItogoSkidka := New(PColoredText, Init(R, #3+AllSummaPrhR, $4E));
LocCalcMAkeWindow^.Insert(sControlItogoSkidka);

R.Assign(1, 22, 12, 23);
Control := New(PColoredText, Init(R, 'Документов:', $74));
LocCalcMAkeWindow^.Insert(Control);

R.Assign(12, 22, 17, 23);
Str(LocCalcList^.List^.Count:CClientKod,ws);
DelSpace(ws);
sControlDoc := New(PColoredText, Init(R, #3+ws, $4E));
LocCalcMAkeWindow^.Insert(sControlDoc);

LocCalcMAkeWindow^.SelectNext(False);
PrevCur[0]:=#0;

NoInfo;

c:=Desktop^.ExecView(LocCalcMAkeWindow);

Dispose(Control,Done);
LocCalcList^.NewList(Nil);
Dispose(LoccalcList,Done);
Dispose(LocCalcMAkeWindow,Done);
PrevCur[0]:=#0;

End;


Procedure TLocCalcMAkeWindow.FormReport(Spis:PBox);
Const Space='';
Var Txt : Text;
    k,c : Word;
    st,s,ws : String;
    TempS : AllStr;
    Numer : ArtikulStr;
    R : TRect;
    Clientkod : String[cclientkod];

Begin
{$IFDEF DPMI}
 Assign(txt,Path.ToTemp+'stprho.txt');
 c := IOResult;
 Rewrite(txt);
 c:=IoResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3+'Не могу создать файл '+Path.ToTemp+'stprho.txt!',Nil,mfError+mfCancelButton);
   Exit;
  End;
 DInfoMsg('Формирую отчет. Ждите...');
 Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');
 Writeln(txt,Space+'Включены в рассмотрение документы со статусом:');

 For c:=1 To Max2 Do
  Begin
   If ss[c]=1 Then
    Case c Of
    1:Write(txt,Space+' "Введен на склад" ');
    2:Write(txt,Space+' "Буфер" ');
    Else;
    End;
  End;
 Writeln(txt);

 Write(txt,Space+'Вид операций:');
    Case Operation Of
    0:WriteLN(txt,' "Клиент" ');
    1:WriteLN(txt,' "Склад" ');
    2:WriteLn(txt,' "Обмен" ');
    Else Writeln(txt);
    End;
 Writeln(txt);


 ws:=GetMakeField(FClient,LastClientKod,Operation);
 DelSpaceRight(ws);

 Writeln(txt,Space+'СПРАВКА ПО ПРИХОДАМ ОТ ПОСТАВЩИКА '+ws+' ('+lastClientKod+') ЗА ПЕРИОД с '+StartDate+' по '+
 StopDate);
 Writeln(txt,Space+'------------------------------------------------------------------------------------');
 Writeln(txt,Space+'  N     Дата     Время  Сумма по З/Цен. Сумма по Р/Цен.   Оператор   Врем.изм.Статус   ');
                    {1234 12345678 12345678 123456789012345 123456789012345 123456789012 12345678 Введен}
 Writeln(txt,Space+'------------------------------------------------------------------------------------');

If Spis^.List^.Count>0 Then
Begin
 For c:=0 To Spis^.List^.Count-1 Do
 Begin
    ws := Spis^.GetText(c,Spis^.List^.Count);
    s:= ws;
    While Pos('│',ws)>0 Do
    Begin
     k:=Pos('│',ws);
     System.Delete(ws,k,1);
     System.Insert(' ',ws,k);
    End;
    ws[0]:=Chr(1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate);


    st:=Copy(s,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1,COne);
    {Вид расчета}
    Case StrToInt(st) Of
    0:st:='Введен';
    1:st:='Буфер ';
    Else
      st:='???   ';
    End;
    ws:=ws+' '+st;


    Writeln(txt,Space+Ws);
 End;
End;


 Writeln(txt,Space+'------------------------------------------------------------------------------------');

 PStaticText(sControlItogo)^.GetText(wS);
 System.Delete(wS,1,1);
 delspace(ws);
 Str(StrToReal(ws):CIZena:CMantissa,ws);

 PStaticText(sControlItogoskidka)^.GetText(S);
 System.Delete(S,1,1);
 delspace(s);
 Str(StrToReal(s):CIZena:CMantissa,s);

 Writeln(txt,Space,'                                       Всего документов: ',Spis^.List^.Count:5);
 Writeln(txt,Space,'                                Всего приход по З/Ценам: ',RecognizReal(StrToREal(ws),CIZena,CMantissa));
 Writeln(txt,Space,'                                Всего приход по Р/Ценам: ',RecognizReal(StrToREal(S),CIZena,CMantissa));

 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'====================================================================================');
 System.Close(txt);
 NoInfoMsg;
 Report(Path.ToTemp+'stprho.txt','',1,False,False,false);
{$EndIF}
End;




Procedure TLocCalcMAkeWindow.FullPreview;
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
If (LocCalcList^.List<>Nil)And(LocCalcList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(LocCalcList^.GetText(LocCalcList^.Focused,LocCalcList^.List^.Count),1+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=Copy(LocCalcList^.GetText(LocCalcList^.Focused,LocCalcList^.List^.Count),1+1+CDocNumer+1,CDate);
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
  DInfoMsg('Ищу документ...');
  New(E,Init);
  Find := False;
  ClearChar(Ass.EditPosition);
  While Not(Eof(f)) And Not(Find) Do
   Begin
   ReadPrihod(F,E);
   ClearChar(E^.Dat.Document);
    If (StrToInt(E^.Dat.SkladKod)=StrToInt(Rek.Kod)) Then
    If (E^.Dat.DateC=Ass.D) and (E^.Dat.Document=Ass.EditPosition) Then
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

s:=E^.Dat.SummaZakupka;
DelSpace(s);
s:=' Всего по З/Ценам: '+s;
ws:=E^.Dat.SummaR;
DelSpace(ws);
s:=s+' Всего по Р/Ценам: '+ws;

SDoc:=E^.Dat.Document;
SDate:=E^.Dat.DateC;

Dispose(E,Done);

NoInfoMsg;
                   {Вставить номер и дату документа в просмотре}
FullScreen(P,'Наименование товара         Код  Фас Литр  Колич  З/Цена   Р/Цена   Упаковок',s,
             {12345678901234567890123456│12345│123│12345│12345│12345678│12345678│123456789}
SDoc,SDAte,0);



Dispose(P,Done);
    End
Else
  Begin
  NoInfoMsg;
  MessageBox(#3^M+#3'Документ не найден!',Nil,mfError+mfCancelButton);
  Dispose(E,Done);
  End;
End;

End;


procedure TLocCalcMAkeWindow.DrawCurrent;
Var R : TRect;
    st : String;
    TempS: AllStr;
    ClientKod : ArtikulStr;
    SDoc,SDate : TDateString;
    er : PRealizasiaType;
    ef : File Of RealizasiaType;
    j : Word;
    Find : Boolean;

Begin
If (LocCalcList^.List<>Nil)And(LocCalcList^.List^.Count>0)  Then
 Begin
  st:=LocCalcList^.GetText(LocCalcList^.Focused,LocCalcList^.List^.Count);
  If St <> PrevCur Then
   Begin
    PrevCur:=St;

    st:=Copy(PrevCur,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1,COne);

    Case StrToInt(st) Of
    0:st:='Введен на склад';
    1:st:='Буфер';
    Else St:='???';;
    End;
    Dispose(sControlVidDoc,Done);
    R.Assign(9, 21, 24, 22);
    sControlVidDoc := New(PColoredText, Init(R, st, $7E));
    LocCalcMAkeWindow^.Insert(sControlVidDoc);


    st:=Copy(PrevCur,1+1+CDocNumer+1+CDate+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CDate+1+COne+1,COne);
    {Вид скидки}
    Case StrToInt(st) Of
    0:st:='Клиент';
    1:st:='Склад';
    2:st:='Обмен';
    Else st:='???';
    End;

        Dispose(sControlSkidka,Done);
        R.Assign(41, 21, 47, 22);
        sControlSkidka := New(PColoredText, Init(R, St, $7E));
        LocCalcMAkeWindow^.Insert(sControlSkidka);

   Redraw;
   End;

 End

 Else
  Begin

PrevCur[0]:=#0;

Dispose(sControlVidDoc,Done);
R.Assign(25, 21, 34, 22);
sControlVidDoc := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcMAkeWindow^.Insert(sControlVidDoc);

Dispose(sControlSkidka,Done);
R.Assign(43, 21, 49, 22);
sControlSkidka := New(PColoredText, Init(R, #3+'???', $7E));
LocCalcMAkeWindow^.Insert(sControlSkidka);


Redraw;
  End;
End;




procedure TLocCalcMAkeWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var Test : Word;
    s,s1 : String;
    ClientKod : ArtikulStr;
    R : TRect;


Begin
Case Event.What Of
 evKeyDown :
  Case Event.KeyCode Of
          kbAltRusK: Begin
                    Event.What:=evCommand;
                    Event.Command:=cmLocalCalc;
                    PutEvent(Event);
                    ClearEvent(Event);
                    End;
  Else;
  End;

 evCommand :
   Case Event.Command Of
        cmLocalCalc:Begin
                     ClearFind;
                        Calculator;
                    End;
  cmPrintReestr:    Begin
        If (LocCalcList^.State and sfFocused <> 0) And (LocCalcList^.List<>Nil)And(LocCalcList^.List^.Count>=1) Then
                  Begin
                         ClearFind;
                         Assistent.EditPosition:=Copy(LocCalcList^.GetText(LocCalcList^.Focused,LocCalcList^.List^.Count),
                                        1+1,CDocNumer);
                         DelSpace(Assistent.EditPosition);
                         DelZerro(Assistent.EditPosition);
                         Assistent.D:=Copy(LocCalcList^.GetText(LocCalcList^.Focused,LocCalcList^.List^.Count),
                                        1+1+CDocNumer+1,CDate);
                         DelSpace(Assistent.D);
                If MessageBox(^M+#3'Печатать накладную прихода N '+Assistent.EditPosition+' от '+Assistent.D+'?',Nil,
			 mfConfirmation+mfOKCancel)=cmOk Then PrintPrihod(Assistent);
                         ClearEvent(Event);
                  End
                  End;

  cmFullView:    Begin
        If (LocCalcList^.State and sfFocused <> 0) And (LocCalcList^.List<>Nil)And(LocCalcList^.List^.Count>=1) Then
                  Begin
                    ClearFind;
                    FullPreview;
                  End;
                  ClearEvent(Event);
                 End;
        cmOk       :Begin
                     ClearFind;
                     ClearEvent(Event);
                    End;

     cmReestrReport:Begin
                     If (LocCalcList^.State and sfFocused <> 0) And (LocCalcList^.List<>Nil)And(LocCalcList^.List^.Count>=1)
                                 Then
                       Begin
                        ClearFind;
                        s:=CalcList^.GetText(CalcList^.Focused,CalcList^.List^.Count);
                        ClientKod:=Copy(s,1+CClient+1,CClientKod);
                        LastClientKod:=ClientKod;
                        FormReport(LocCalcList);
                       End;
                     ClearEvent(Event);

                    End;
   Else;
   End;
   Else;
   End;

inherited HandleEvent(Event);

  If (Desktop^.Current=PView(LocCalcMAkeWindow)) And (Event.What <> EvKeyDown) Then
   Begin
      DrawCurrent;
   End;

ClearEvent(Event);
End;



Destructor TLocCalcMAkeWindow.Done;
Begin
 Dispose(sControlSkidka,Done);
 Dispose(sControlVidDoc,Done);
 Dispose(sControlItogo,Done);
 Dispose(sControlItogoSkidka,Done);
 Dispose(sControlDoc,Done);
 TDialog.Done;
 PrevCur[0]:=#0;
End;





End.