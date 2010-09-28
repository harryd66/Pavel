{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Nabor;


Interface

Uses Dialogs,Drivers;

Type
  PNaborWindow = ^TNaborWindow;
  TNaborWindow = object(TDialog)
	 procedure OpenNaborWindow;
	 procedure AddName;
      Procedure SpecialRecalc(Const VarList:PBox);
	 procedure Refresh;
	 procedure DrawCurrent;
	 constructor Init(Var l: Boolean);
	 procedure HandleEvent(var Event: TEvent); virtual;
  end;

{$I Compile.INC}
Procedure ImportClientInfo(Reg,Sel:Word);

Implementation

Uses Glob,Access,ServStr,MyCalc,LockInfo,DStat,TStatu,TStatu2,Utils,DosWin,
     DBEngine,Objects, Views, MsgBox,Protect,TPDate,Market,Tools,Printers,
     Prise,StatTols,
     App, ColorTxt,Validate,Serv,Nastr,NetDbEng;

var

 {sstarttov,sstoptov,StopDatetov ,StartDatetov : TDateString;}
 PrevLine,SKodTov: string;
 OplataTov,OperationTov:Word;
 SVidDocTov :  Maska9;

 NaborWindow : PNaborWindow;

 NoScreenList,ScreenList,NAmeList,SelectNameList : PBox;

 Prevs: TEnjoyStr;

  scontrol,
  control1,

  ControlSorting,
  ControlDirection
   : PView;


 SControlVidProd,
 SControlKolPos,
 ControlFullName,ControlFullName2: PView;

 Ws : String[CIZena];

 SStatusOplata : Maska2;
 SClient : Maska3;
 SLocVidOperation,SVidOperation : Maska6;

 LStart,LStop:LongInt;

 OperationFiltr,VidProd,Filtr: Word;
 Sort,Direction : Word;
 PrevName,PrevCurrent,PrevCurLoc: string;
 ControlStartOst,ControlStopOst : PView;

procedure TNaborWindow.OpenNaborWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmNabor, nil) = nil then
  begin
	 DInfo('Инициализация анализа...');
	 L:=True;
	 NaborWindow := New(PNaborWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(NaborWindow);
    NoInfo;
    End
    Else
        Begin
         Status:=DocNormal;
         Dispose(NaborWindow,Done);
         NoInfo;
        End;
  end
  else
    if PView(NaborWindow) <> Desktop^.TopView then NaborWindow^.Select;
end;

Procedure ImportClientInfo(Reg,Sel:Word);
Const SeparatorChar=';';
Var f : ClientFileType;
    Rd : ClientType;
    s : String;
    txt : Text;
    i : LongInt;
    Gorod: string;
    Buf: string[1];
Begin
Case Reg Of
0:begin
     Case Sel Of
     0:s:=Path.ToClient+'Client.db';
     1:s:=Path.ToClient+'Sklad.db';
     2:s:=Path.ToClient+'Barter.db';
     Else;
     End;{CAse}

  end;
1:begin
       Case Sel Of
     0:s:=Path.ToClient+'Make.db';
     1:s:=Path.ToClient+'Sklad.db';
     2:s:=Path.ToClient+'Barter.db';
     Else;
     End;{CAse}
  End;
Else;
End;{Case}
DInfoMsg('Импортирую данные. Ждите...');
Assign (F,s);
i:=IOResult;
Reset(f);
i:=IOResult;

If i<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка открытия '+s+'! (Код:'+IntToStr(i,CLitrMantissa)+')'+
  ClicProgrammer,Nil,
  mfError+mfCancelButton);
  Exit;
 End;

Assign(txt,Path.ToTemp+'impbaza.csv');
i:=IOResult;
Rewrite(txt);
i:=IOResult;
If i<>0 Then
 Begin
  Close(f);
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка создания '+Path.ToTemp+'impbaza.csv'+'! (Код:'+IntToStr(i,CLitrMantissa)+')'+
  ClicProgrammer,Nil,
  mfError+mfCancelButton);
  Exit;
 End;

Case Reg Of
0:begin
     Case Sel Of
     0:s:=SeparatorChar+'БАЗА КЛИЕНТОВ';
     1:s:=SeparatorChar+'БАЗА СКЛАДОВ';
     2:s:=SeparatorChar+'БАЗА КЛИЕНТОВ (БАРТЕР)';
     Else;
     End;{CAse}

  end;
1:begin
       Case Sel Of
     0:s:=SeparatorChar+'БАЗА ПОСТАВЩИКОВ';
     1:s:=SeparatorChar+'БАЗА СКЛАДОВ';
     2:s:=SeparatorChar+'БАЗА ПОСТАВЩИКА (БАРТЕР)';
     Else;
     End;{CAse}
  End;
Else;
End;{Case}
Writeln(txt,DosToWin(s));
Writeln(txt,DosToWin(s));
Write(txt,DosToWin(
'код контрагента'+SeparatorChar+
'наименование контрагента'+SeparatorChar+
'Договор'+SeparatorChar+
'Консигнация'+SeparatorChar+
'Срок консигнации'+SeparatorChar+
'Условия доставки'+SeparatorChar+
'Вид клиента'+SeparatorChar+
'Маршрут'+SeparatorChar+
'Лимит'+SeparatorChar+
'Город'+SeparatorChar+
'Адрес юридический'+SeparatorChar+
'Адрес фактический'+SeparatorChar+
'Телефон'+SeparatorChar+
'Агент ЗАК'+SeparatorChar+
'Агент ВЭН'+SeparatorChar+
'Контроль просрочки'+SeparatorChar+
'Блокировка'+SeparatorChar
)

);
writeln(txt);
While not(eof(f)) do
 begin
  read(f,Rd);
  If rd.Employ Then
   Begin
    With Rd Do
     Begin

Write(txt,DosToWin(Kod)+SeparatorChar);

Write(txt,DosToWin(Name)+SeparatorChar);

Write(txt,DosToWin(Dogovor)+SeparatorChar);

If Debit=0 Then Write(Txt,DosToWin('запрещена')+SeparatorChar)
Else Write(Txt,DosToWin('разрешена')+SeparatorChar);

Write(txt,Punkt[1]+SeparatorChar);

DelSpace(Punkt[2]);
if Punkt[2]='+' then
Write(txt,DosToWin('Дост.')+SeparatorChar);

if Punkt[2]='-' then
Write(txt,DosToWin('Сам.')+SeparatorChar);

if (Punkt[2]<>'-') and (Punkt[2]<>'+') then
Write(txt,DosToWin('???')+SeparatorChar);

if opt then Write(txt,DosToWin('Опт.')+SeparatorChar)
else Write(txt,DosToWin('Розн.')+SeparatorChar);

Write(txt,Punkt[4]+SeparatorChar);

Write(txt,Limit+SeparatorChar);

Gorod:='';

if pos('Г.',Enviropment)>0 then
begin
  i:=pos('Г.',Enviropment);
  while((Enviropment[i]<>' ') and (Enviropment[i]<>',')) do
  begin
   Gorod:=Gorod+Enviropment[i];
   inc(i);
  end;
end
(*else
if pos('Р-Н',Adress)>0 then
begin
  i:=pos('Р-Н',Adress)+2;
  while((Adress[i]<>' ') {and (Adress[i]<>',')} and (i<>0)) do
  begin
   Gorod:=Gorod+Adress[i];
   Buf:=Gorod[1];
   Gorod[1]:=Gorod[length(Gorod)+1];
   Gorod[length(Gorod)+1]:=Buf[1];
   Dec(i);
   memcc(Gorod);
  end;
end *)
else
if pos('ПОС.',Enviropment)>0 then
begin
  i:=pos('ПОС.',Enviropment);
  while((Enviropment[i]<>' ') and (Enviropment[i]<>',')) do
  begin
   Gorod:=Gorod+Enviropment[i];
   inc(i);
  end;
end
else
if pos('П.',Enviropment)>0 then
begin
  i:=pos('П.',Enviropment);
  while((Enviropment[i]<>' ') and (Enviropment[i]<>',')) do
  begin
   Gorod:=Gorod+Enviropment[i];
   inc(i);
  end;
end;


Write(txt,DosToWin(Gorod)+SeparatorChar);

Write(txt,DosToWin(Adress)+SeparatorChar);

Write(txt,DosToWin(Enviropment)+SeparatorChar);

while pos(';',Telefon)>0 do Telefon[pos(';',Telefon)]:=',';
Write(txt,DosToWin(Telefon)+SeparatorChar);

Write(txt,AgentKod[1]+SeparatorChar);

Write(txt,AgentKod[2]+SeparatorChar);

if NoLimit=0 then
Write(txt,DosToWin('Вкл.')+SeparatorChar)
else Write(txt,DosToWin('Откл.')+SeparatorChar);

if LockTime then
Write(txt,DosToWin('Блок.')+SeparatorChar)
else Write(txt,DosToWin('Разблок.')+SeparatorChar);

Writeln(txt);
i:=IOResult;

     End;
   End;
 end;

Close(f);
i:=IOResult;
Close(txt);
i:=IOResult;

NoInfoMsg;
MessageBox(^M+#3'Данные успешно импортированы в '+Path.ToTemp+'impbaza.csv!',Nil,
  mfInformation+mfCancelButton);
End;



procedure TNaborWindow.Refresh;
Var l : Boolean;
    i,res  : Word;
    s,ws : string[150];
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



constructor TNaborWindow.Init(Var l : Boolean);
Var R  : TRect;
    i,res  : Word;
    s,ws : string[150];
    id : PBazType;
    Baz : BazFileType;
Begin
L:=False;
R.Assign(1, 0, 78, 23);

memc;

inherited Init(R, 'Формирование выборки наименований товаров');
TekDate:=FDate;
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E602;

OperationFiltr:=63;
Filtr:=511;
OplataTov:=3;
OperationTov:=7;

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


SelectNext(False);

AddName;
Refresh;
PrevCurrent[0]:=#0;
PrevName[0]:=#0;
L:=True;
End;


procedure TNaborWindow.AddName;

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
{
End
 Else
  Begin
   PCluster(SControlDocFiltr)^.SetButtonState($000001FF, False);
   PCluster(SControlOplataFiltr)^.SetButtonState($00000003, False);
  End;
}
End;




procedure TNaborWindow.DrawCurrent;
Var R : TRect;
    s,st : string[150];
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
	 {R.Assign(2, 21, 39, 22);}
    Redraw;
   End;
 End
 Else
  Begin
   PrevCurrent[0]:=#0;
   s:='???';
   Redraw;
  End;
End;


procedure TNaborWindow.HandleEvent(var Event: TEvent);
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
  cmRefresh :Begin
				  Refresh;
              PrevCurrent[0]:=#0;
             End;

  cmCalcStat :Begin
              ClearFind;
              If (SelectNameList^.List<>Nil)And(SelectNAmeList^.List^.Count>0)  Then
               Begin
               {проверяем стартовую дату}
           (*    SControlStartDate^.GetData(sstarttov);
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
               SControlStopDate^.SetData(stopDatetov);  *)


               {назначаем фильтр видов документов}

               {назначаем фильтр видов операций}

               {назначаем фильтр видов клиентов}

               {назначаем фильтр оплаты}

               {старт загрузки ответа на сформированный запрос}
					{GroupCalcWindow^.Start(l);}
               ClearEvent(Event);
{               MessageBox(^M+#3'Начало расчета!',Nil,mfInformation+mfCancelButton);}
					{Tvr^.Start(SelectNameList);}
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
          (*     SControlStartDate^.GetData(sstarttov);
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
               SControlStopDate^.SetData(stopDatetov);    *)



               {назначаем фильтр видов документов}

               {назначаем фильтр видов операций}

               {назначаем фильтр видов клиентов}

               {назначаем фильтр оплаты}


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
  if (User[72] or (CurrentPassword='00')) then
  If (StrToInt(CurrentPassword)=0) Or (Password(7)) Then
   Begin

              If (SelectNameList^.List<>Nil)And(SelectNAmeList^.List^.Count>0)  Then
               Begin
               {проверяем стартовую дату}
           (*    SControlStartDate^.GetData(sstarttov);
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
               SControlDocFiltr^.GetData(Filtr);   *)

               {назначаем фильтр видов операций}

               {назначаем фильтр видов клиентов}

               {назначаем фильтр оплаты}

               {старт загрузки ответа на сформированный запрос}
                                        {GroupCalcWindow^.Start(l);}
               ClearEvent(Event);
{               MessageBox(^M+#3'Начало расчета!',Nil,mfInformation+mfCancelButton);}
               {SpecialRecalc(SelectNameList);}



            (*   Concurs(SelectNameList,OperationFiltr,SVidOperation,OperationToV,SClient,Filtr,SVidDocTov,
               OplataToV,SStatusOplata,StartDatetov,StOpDatetov);**)
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

  If (Desktop^.Current=PView(NaborWindow)) And (Event.What <> EvKeyDown) Then
   Begin
      DrawCurrent;
               Begin
                  Redraw;
               End;

   End;
{  ClearEvent(Event);}

end;

Procedure TNaborWindow.SpecialRecalc(Const VarList:PBox);
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
 (*LStart:=DateStringToDate(DateMask,StartDatetov);
 LStop :=DateStringToDate(DateMask ,StopDatetov);*)

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

   NoInfoMsg;
  End;

 (*FormReportS(Cl,Agent,NoScreenList,NMAkeList,StartDateTov,StopDateTov,VidReport,txt,er);*)

 Dispose(NoScreenList,Done);
 Dispose(Agent,Done);
 Dispose(Cl,Done);
 Dispose(NMAkeList,Done);

 ViewAsText(Path.ToTemp+'Zapr.txt',True);
 {Report(Path^.Dat.ToTemp+'Zapr.txt','',NprintC^.DAt.CopyAll,False,False);}

{$ENDIF}
End;


Begin

End.
