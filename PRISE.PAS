{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

unit prise;

Interface

Uses Dialogs,Drivers;

Type
  PRazdelWindow = ^TRazdelWindow;
  TRazdelWindow = object(TDialog)
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done; virtual;
  end;

Type {главное окно статистики,фильтры документов,оплаты,выбор клиентов}
  PSelectAgentWindow = ^TSelectagentWindow;
  TSelectAgentWindow = object(TDialog)
    procedure AddName;
    Destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;


Type {главное окно статистики,фильтры документов,оплаты,выбор клиентов}
  PSelectKassaWindow = ^TSelectKassaWindow;
  TSelectKassaWindow = object(TDialog)
    procedure AddName;
    Destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;


Type {главное окно статистики,фильтры документов,оплаты,выбор клиентов}
  PSelectGroup = ^TSelectGroup;
  TSelectGroup = object(TDialog)
    procedure AddName;
    Destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

Type {главное окно статистики,фильтры документов,оплаты,выбор клиентов}
  PSelectClientWindow = ^TSelectClientWindow;
  TSelectClientWindow = object(TDialog)
    procedure AddName;
    Destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;


Function SelectionAgent(Var P:PBox):Boolean;
Function SelectionKAssa(Var P:PBox):Boolean;
Function CreatGroupList(Var P:PBox):Boolean;
Function SelectionGroup(Var P:PBox):Boolean;
Function SelectionClient(Regim:Boolean; Var P:PBox):Boolean;
Function SelectionSortrudn(Var P:PBox):Boolean;

Procedure Selection(K:Byte);

Var RazdelSelect : PBox;

Implementation


uses Objects, Views, MsgBox,Vision1,Vision3,Vision4,Vision5,Balance,Net,Utilsp,
     App, Serv, Glob,ServStr,Utils,NetDbEng,DbEngine,ColorTxt,ArcOst,UchDoh;

var
 RazdelWin : PRazdelWindow;
 RazdelFile : File Of RazdelType;
 RazdelElement : RazdelType;
 ClientAll : PBox;
 ClientSelect : PBox;

 ClientWin : PSelectClientWindow;
 i : Byte;
 M : MaskaNew;
 Sort,Assort,ZapretOpt : Word;
 Wspom,Sertif,Akzis :  Word;
 SSS : Maska2;
 c : Word;
 s : AllStr;
 AgentAll : PBox;
 AgentSelect : PBox;
 AgentFile : ClientFileType;
 AgentWin :PSelectAgentWindow;
 AgentElement : ClientType;

 KassaAll : PBox;
 KassaSelect : PBox;
 KassaWin :PSelectKassaWindow;
 KassaElement : KassaOperation;
 KassaFile : OperationFileType;


 GroupAll : PBox;
 GroupSelect : PBox;
 GroupWin : PSelectGroup;
 GroupElement : GroupType;
 GroupFile : GroupFileType;

 ControlAmount2,ControlAmount1,ControlAmount : PView;


Procedure Selection(K:Byte);
var
  R : TRect;
  ControlOpt,ControlSertif,Control,ControlOtdel,ControlSort,ControlAssort : PView;
begin
ClearFind;
DInfo('Минуточку...');
R.Assign(1, 0, 79, 23);

Case k Of
0:New(RazdelWin, Init(R, 'Печать наличия на складе'));
1:New(RazdelWin, Init(R, 'Печать прайс-листа'));
2:New(RazdelWin, Init(R, 'Печать акта ревизии на складе'));
3:New(RazdelWin, Init(R, 'Печать остатков и продаж на складе'));
4:New(RazdelWin, Init(R, 'Тестирование базы сертификатов'));
5:New(RazdelWin, Init(R, 'Расчет остатков и продаж'));
6:New(RazdelWin, Init(R, 'Балансировка'));
7:New(RazdelWin, Init(R, 'Расчет остатков,продаж и приходов'));
8:New(RazdelWin, Init(R, 'Просмотр таблицы автоматических скидок'));
9:New(RazdelWin, Init(R, 'Просмотр таблицы разногласий авто скидок'));
10:New(RazdelWin, Init(R, 'Просмотр таблицы разногласий ручных скидок'));
11:New(RazdelWin, Init(R, 'Тестирование сроков рализации'));
13:New(RazdelWin, Init(R, 'Архив остатков'));
14:New(RazdelWin, Init(R, 'Учет доходов и расходов'));
Else;
End;

RazdelWin^.Options := RazdelWin^.Options or ofCenterX or ofCenterY;
RazdelWin^.HelpCtx:=$E002;

R.Assign(25, 2, 26, 22);
Control := New(PScrollBar, Init(R));
RazdelWin^.Insert(Control);

R.Assign(1, 2, 25, 22);
Razdel := New(PBox, Init(R, 1, PScrollbar(Control)));
Razdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path.Torazdel+'razdel.db');
Reset (RazdelFile);
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
   Begin
    Format (RazdelElement.Name,CClient);
    Razdel^.List^.Insert(NewStr(RazdelElement.Name+'│'+RazdelElement.Kod));
    Razdel^.SetRange(Razdel^.List^.Count);
   End;
 End;
System.Close(RazdelFile);
Razdel^.FocusItem(0);
Razdel^.HelpCtx:=$E044;
RazdelWin^.Insert(Razdel);

  R.Assign(1, 1, 25, 2);
  RazdelWin^.Insert(New(PLabel, Init(R, 'Ра~з~делы             Код', Razdel)));

R.Assign(50, 2, 51, 22);
Control := New(PScrollBar, Init(R));
RazdelWin^.Insert(Control);

R.Assign(26, 2, 50, 22);
RazdelSelect := New(PBox, Init(R, 1, PScrollbar(Control)));
RazdelSelect^.NewList(New(PTextCollection, Init(1,1)));
RazdelSelect^.HelpCtx:=$E041;
{
For c:=0 To Razdel^.List^.Count-1 Do
Begin
 s:=Razdel^.GetText(c,Razdel^.List^.Count-1);
 RazdelSelect^.List^.Insert(NewStr(S));
 RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
End;
}
RazdelWin^.Insert(RazdelSelect);

  R.Assign(26, 1, 50, 2);
  RazdelWin^.Insert(New(PLabel, Init(R, 'Выбранн~ы~е разделы   Код', RazdelSelect)));


If k in [1] Then
Begin
R.Assign(53, 1, 75, 3);
ControlOpt := New(PRadioButtons, Init(R,
  NewSItem('Розница',
  NewSItem('Опт', Nil))));
  ControlOpt^.Options := ControlOpt^.Options or ofFramed;
RazdelWin^.Insert(ControlOpt);
  R.Assign(53, 0, 65, 1);
  RazdelWin^.Insert(New(PLabel, Init(R, 'Вид прайса:', ControlOpt)));
ControlOpt^.SetData(ZapretOpt);
End;



If not(k in [5,6,7,14]) Then
Begin
R.Assign(53, 4, 75, 6);
ControlAssort := New(PRadioButtons, Init(R,
  NewSItem('~Р~еальное наличие',
  NewSItem('~П~олный перечень', Nil))));
  ControlAssort^.Options := ControlAssort^.Options or ofFramed;
RazdelWin^.Insert(ControlAssort);
  R.Assign(53, 3, 65, 4);
  RazdelWin^.Insert(New(PLabel, Init(R, 'Содержание:', ControlAssort)));
ControlAssort^.SetData(Assort);
End;

R.Assign(53, 8, 75, 10);
ControlSort := New(PRadioButtons, Init(R,
  NewSItem('~К~од',
  NewSItem('~Н~аименование', Nil))));
  Controlsort^.Options := Controlsort^.Options or ofFramed;
  {Controlsort^.Options := Controlsort^.Options and not ofSelectable;}

RazdelWin^.Insert(ControlSort);

  R.Assign(53, 7, 65, 8);
  RazdelWin^.Insert(New(PLabel, Init(R, 'Сортировка:', ControlSort)));

Controlsort^.SetData(sort);

If not(k in [5,6,7]) Then
Begin
R.Assign(53, 12, 76, 20);
ControlOtdel := New(PCheckboxes, Init(R,
  NewSItem('~1~ '+Rek.Otdel[1],
  NewSItem('~2~ '+Rek.Otdel[2],
  NewSItem('~3~ '+Rek.Otdel[3],
  NewSItem('~4~ '+Rek.Otdel[4],
  NewSItem('~5~ '+Rek.Otdel[5],
  NewSItem('~6~ '+Rek.Otdel[6],
  NewSItem('~7~ '+Rek.Otdel[7],
  NewSItem('~8~ '+Rek.Otdel[8],
  Nil))))))))));
ControlOtdel^.Options := ControlOtdel^.Options or ofFramed;

RazdelWin^.Insert(ControlOtdel);

  R.Assign(53, 11, 64, 12);
  RazdelWin^.Insert(New(PLabel, Init(R, 'Отделения:', ControlOtdel)));

ConvertNew(m);
BitToWordNew(M,C);

ControlOtdel^.SetData(C);
End;

If K=0 Then
Begin
 Wspom:=sss[1];
 sss[1]:=sss[2];
 sss[2]:=wspom;

BitToWord2(sss,Wspom);
R.Assign(53, 21, 76, 23);
ControlSertif := New(PCheckboxes, Init(R,
  NewSItem('~С~ертификаты',
  NewSItem('При~м~ечания', Nil))));
RazdelWin^.Insert(ControlSertif);
ControlSertif^.SetData(Wspom);
ControlSertif^.Options := ControlSertif^.Options or ofFramed;

  R.Assign(53, 20, 61, 21);
  RazdelWin^.Insert(New(PLabel, Init(R, 'Печать:', ControlSertif)));
End;


RazdelWin^.SelectNext(False);
NoInfo;
C := Desktop^.ExecView(RazdelWin);
If C <> cmCancel Then
 Begin
  ClearFind;
  if k in [1] then
  ControlOpt^.GetData(ZapretOpt);
  If not(k in [5,6,7]) Then
  ControlOtdel^.GetData(c);
  ControlSort^.GetData(Sort);
  If not(k in [5,6,7,14]) Then
  ControlAssort^.GetData(Assort);
  If k=0 Then Begin
                ControlSertif^.GetData(Wspom);
                WordToBit2(Wspom,sss);
                Wspom:=sss[1];
                sss[1]:=sss[2];
                sss[2]:=wspom;
                Sertif:=sss[1];
                Akzis:=sss[2];
              End;
  {Dispose(Razdel,Done);}
  If not(k in [5,6,7]) Then WordToBitNew(C,M);
  If RazdelSelect^.List^.Count=0 Then
   Begin
    Dispose(Razdel,Done);
    Dispose(RazdelSelect,Done);
    Dispose(RazdelWin,Done);
    MessageBox(^M+#3'Не выбрано ни одного раздела !',Nil,mfError+mfCancelButton);
    ConvertNew(m);
    Exit;
   End;
   If c=0 Then
   Begin
    Dispose(Razdel,Done);
    Dispose(RazdelSelect,Done);
    Dispose(RazdelWin,Done);
    MessageBox(^M+#3'Не выбрано ни одного отделения !',Nil,mfError+mfCancelButton);
    ConvertNew(m);
    Exit;
   End;
   if not (k in [5,6,7,8,9,10,13]) then
   begin
    WordToBitNew(C,M);
    ConvertNew(M);
   end;
   If k<3 Then
   PrintSklad_Or_Prise(True,K,RazdelSelect,M,Assort,ZapretOpt,Sort,Sertif,Akzis)
   Else
   Begin
   If k=3 Then
   Ostatki_Market(RazdelSelect,M,Assort,sort);
   If k=4 Then
   Test_Sertif(RazdelSelect,M,Assort,sort);
   If k=5 Then
   RashetProdag(RazdelSelect,Assort,sort);
   If k=7 Then
   SpecialRashetProdag(RazdelSelect,Assort,sort);
   If k=6 Then
   CalcBalance(RazdelSelect,Assort,sort);
   If k=8 Then
   PrintSKL(RazdelSelect,M,Assort,sort);
   If k=9 Then
   PrintSKL1(RazdelSelect,M,Assort,sort);
   If k=10 Then
   PrintSKL2(RazdelSelect,M,Assort,sort);
   If k=11 Then
   Test_Srok(RazdelSelect,M,Assort,sort);
   If k=13 Then
   CalcOstDate(RazdelSelect,M,sort);
   If k=14 Then
   ReportRashoDohod(RazdelSelect,M,sort);
   End;


   Dispose(Control,Done);
   If not(k in [5,6,7,8,9,10,13]) Then Dispose(ControlOtdel,Done);
   Dispose(Razdel,Done);
   Dispose(RazdelSelect,Done);
   Dispose(RazdelWin,Done);
   {if  k in [1] then Dispose(ControlOpt,Done);}
 End
 Else
  Begin
   If not(k in [5,6,7,8,9,10,13]) Then ConvertNew(m);
   If k=0 Then
       Begin
                Wspom:=sss[1];
                sss[1]:=sss[2];
                sss[2]:=wspom;

       End;
   Dispose(Control,Done);
   Dispose(Razdel,Done);
   Dispose(RazdelSelect,Done);
   Dispose(RazdelWin,Done);
  End;

End;


Destructor TRazdelWindow.Done;
Begin
TDialog.Done;
End;


{
Function TestElement (S : TEnjoyStr;P : PBox) : Boolean;
Var ls : Byte;
    s1,st : String[CArtikul];
Begin
TestElement:=True;
s1:=s;
For ls :=0 To P^.List^.Limit Do
Begin
ST:=Copy(P^.GetText(ls,P^.List^.Limit),1+CRazdel+1,CRazdelKod);
If St=S1 Then
   Begin
    TestElement:=False;
    Break;
   End;
End;
End;
}

procedure TRazdelWindow.HandleEvent(var Event: TEvent);
Var s : String[CRazdel+1+CRazdelKod];
    ls : Word;
    scod : string[150];
Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
   kbEnter  :Begin
                ClearFind;
                inherited HandleEvent(Event);
                If (RazdelWin^.Current=PView(Razdel)) Then
                   Begin
                    Event.What:=evCommand;
                    Event.Command:=CmOk;
                   End;
             End;
   kbGrayPlus,
   kbCtrlIns: Begin
                ClearFind;
            If ((Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>= 1)) Then
            Begin
             For ls :=0 To Razdel^.List^.Count-1 Do
              Begin
               s:=Razdel^.GetText(ls,Razdel^.List^.Count);
               if Testelement(Copy(s,1+CRazdel+1,CRazdelKod),RazdelSelect) then
                Begin
                 RazdelSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
                 {If Razdel^.Focused+1<Razdel^.List^.Count Then Razdel^.FocusItem(Razdel^.Focused+1);}
                 If RazdelSelect^.Focused+1<RazdelSelect^.List^.Count Then
                 RazdelSelect^.FocusItem(RazdelSelect^.List^.Count-1);
             End
            Else ClearEvent(Event);
            Redraw;
            End;

   kbShiftIns: Begin
                ClearFind;
            If ((Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>= 1)) Then
            Begin
             For ls :=0 To Razdel^.List^.Count-1 Do
              Begin
               s:=Razdel^.GetText(ls,Razdel^.List^.Count);
               scod:=Copy(s,1+CRazdel+1,CRazdelKod);
               If GetRazdelDesignation(scod)='СПЕЦ' Then
               if Testelement(Copy(s,1+CRazdel+1,CRazdelKod),RazdelSelect) then
                Begin
                 RazdelSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 RazdelSelect^.SetRange(RazdelSelect^.List^.Count);

                 {If Razdel^.Focused+1<Razdel^.List^.Count Then Razdel^.FocusItem(Razdel^.Focused+1);}
                 If RazdelSelect^.Focused+1<RazdelSelect^.List^.Count Then
                 RazdelSelect^.FocusItem(RazdelSelect^.List^.Count-1);
             End
            Else ClearEvent(Event);
            Redraw;
            End;

  kbCtrLDel: Begin
                ClearFind;
     If (RazdelSelect^.State and sfFocused <> 0) And (RazdelSelect^.List<>Nil)And(RazdelSelect^.List^.Count>=1) Then
            Begin
             RazdelSelect^.NewList(nil);
             RazdelSelect^.NewList(New(PTextCollection, Init(1,25)));
            End;
            ClearEvent(Event);
             Redraw;
            End;
     kbDel: Begin
                ClearFind;
     If (RazdelSelect^.State and sfFocused <> 0) And (RazdelSelect^.List<>Nil)And(RazdelSelect^.List^.Count>=1) Then
            Begin
             RazdelSelect^.List^.AtFree(RazdelSelect^.Focused);
             RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
             If RazdelSelect^.Focused>0 Then
             RazdelSelect^.FocusItem(RazdelSelect^.Focused);

             If (RazdelSelect^.Focused>=RazdelSelect^.List^.Count) and(RazdelSelect^.Focused>0) Then
             RazdelSelect^.FocusItem(RazdelSelect^.Focused-1);

            End;
              ClearEvent(Event);
              Redraw;
            End;
      kbIns: Begin
                ClearFind;
            If(Razdel^.State and sfFocused <> 0) And (Razdel^.List^.Count>=1) Then
            Begin
               s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.COunt);
               If TestElement(Copy(s,1+CRazdel+1,CRazdelKod),RazdelSelect) Then
               Begin
               RazdelSelect^.List^.Insert(NewStr(s));
               RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
               s:=Copy(s,1+CRazdel+1,CRazdelKod);
               RazdelSelect^.FocusItem(LoCation(RazdelSelect,S,ProdagaWindow));
             If RazdelSelect^.Focused+1<RazdelSelect^.List^.Count Then
             RazdelSelect^.FocusItem(RazdelSelect^.List^.Count-1);
               End;
               If (Razdel^.Focused+1) <  Razdel^.List^.Count Then
               Razdel^.FocusItem(Razdel^.Focused+1);
              End;
              ClearEvent(Event);
              Redraw;
            End;
    Else;
    End;
    Else;
    End;
  inherited HandleEvent(Event);
End;

Destructor TSelectAgentWindow.Done;
Begin
TDialog.Done;
End;



procedure TSelectAgentWindow.HandleEvent(var Event: TEvent);
Label 2,3;
Var s,s1 : String{[CClient+1+CClientKod]};
    ls : Word;
    res : Word;
    Logik : Boolean;
    fstr : string[150];
Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
   kbEnter  :Begin
                ClearFind;
                inherited HandleEvent(Event);
                If (AgentWin^.Current=PView(Agent)) Then
                   Begin
                    Event.What:=evCommand;
                    Event.Command:=CmOk;
                   End;
             End;

   kbGrayPlus:Begin
                ClearFind;
          If ((AgentAll^.State and sfFocused <> 0)And(AgentAll^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...');
             For ls :=0 To AgentAll^.List^.Count-1 Do
              Begin
               s:=AgentAll^.GetText(ls,AgentAll^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CClient);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0) Or (Pos('*',Fstr)>0) Then Logik:=True;
               1:If (fstr=s1)Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               If TestElement(Copy(s,1+CClient+1,CArtikul),AgentSelect) Then
                Begin
                 AgentSelect^.List^.Insert(NewStr(s));
                 AgentSelect^.SetRange(AgentSelect^.List^.Count);
                End;{TestElement}
              End;{For}
              NoInfoMsg;
              ProdagaWindow:=False;
              If AgentSelect^.Focused+1<AgentSelect^.List^.Count Then
              AgentSelect^.FocusItem(AgentSelect^.List^.Count-1);
              AddName;
              AgentSelect^.FocusItem(0);
                End;{Maska}
              Redraw;
            End;{Nil}
              ClearEvent(Event);
              End;
   kbGrayMinus:Begin
                ClearFind;

          If ((AgentSelect^.State and sfFocused <> 0)And(AgentSelect^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...');
             3:
             if (AgentSelect^.List^.Count>= 1) Then
             For ls :=0 To AgentSelect^.List^.Count-1 Do
              Begin
               s:=AgentSelect^.GetText(ls,AgentSelect^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CClient);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               Begin
                AgentSelect^.List^.AtFree(Ls);
                AgentSelect^.SetRange(AgentSelect^.List^.Count);
                goto 3;
               End;
              End;{For}

             If AgentSelect^.Focused>0 Then
             AgentSelect^.FocusItem(AgentSelect^.Focused);

             If (AgentSelect^.Focused>=AgentSelect^.List^.Count) and(AgentSelect^.Focused>0) Then
             AgentSelect^.FocusItem(AgentSelect^.Focused-1);


              NoInfoMsg;
              ProdagaWindow:=False;
              AddName;
              AgentSelect^.FocusItem(0);
                End;{Maska}
             Redraw;
            End;{Nil}
              ClearEvent(Event);
              End;
   kbCtrlIns: Begin
                ClearFind;
            If ((AgentAll^.State and sfFocused <> 0)And(AgentAll^.List^.Count>= 1)) Then
            Begin
            DInfoMsg('Минуточку...');
             AgentSelect^.Focusitem(0);
             For ls :=0 To AgentAll^.List^.Count-1 Do
              Begin
               s:=AgentAll^.GetText(ls,AgentAll^.List^.Count);
               if Testelement(Copy(s,1+CClient+1,CClientKod),AgentSelect) then
                Begin
                 AgentSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 AgentSelect^.SetRange(AgentSelect^.List^.Count);
                 If AgentAll^.Focused+1<AgentAll^.List^.Count Then AgentAll^.FocusItem(AgentAll^.Focused+1);
                 If AgentSelect^.Focused+1<AgentSelect^.List^.Count Then
                 AgentSelect^.FocusItem(AgentSelect^.List^.Count-1);
            NoInfoMsg;
             End
            Else ClearEvent(Event);
            Redraw;
            End;

  kbCtrLDel: Begin
                ClearFind;
     If (AgentSelect^.State and sfFocused <> 0) And (AgentSelect^.List<>Nil)And(AgentSelect^.List^.Count>=1) Then
            Begin
             AgentSelect^.NewList(nil);
             AgentSelect^.NewList(New(PTextCollection, Init(1,25)));
            End;
            ClearEvent(Event);
             Redraw;
            End;
     kbDel: Begin
                ClearFind;
     If (AgentSelect^.State and sfFocused <> 0) And (AgentSelect^.List<>Nil)And(AgentSelect^.List^.Count>=1) Then
            Begin
             AgentSelect^.List^.AtFree(AgentSelect^.Focused);
             AgentSelect^.SetRange(AgentSelect^.List^.Count);
             If AgentSelect^.Focused>0 Then
             AgentSelect^.FocusItem(AgentSelect^.Focused);

             If (AgentSelect^.Focused>=AgentSelect^.List^.Count) and(AgentSelect^.Focused>0) Then
             AgentSelect^.FocusItem(AgentSelect^.Focused-1);

            End;
              ClearEvent(Event);
              Redraw;
            End;
      kbIns: Begin
                ClearFind;
            If(AgentAll^.State and sfFocused <> 0) And (AgentAll^.List^.Count>=1) Then
            Begin
               s:=AgentAll^.GetText(AgentAll^.Focused,AgentAll^.List^.COunt);
               If TestElement(Copy(s,1+CClient+1,CClientKod),AgentSelect) Then
               Begin
               AgentSelect^.List^.Insert(NewStr(s));
               AgentSelect^.SetRange(AgentSelect^.List^.Count);
               s:=Copy(s,1+CClient+1,CClientKod);
               AgentSelect^.FocusItem(LoCation(AgentSelect,S,ProdagaWindow));
             If AgentSelect^.Focused+1<AgentSelect^.List^.Count Then
             AgentSelect^.FocusItem(AgentSelect^.List^.Count-1);
               End;
               If (AgentAll^.Focused+1) <  AgentAll^.List^.Count Then
               AgentAll^.FocusItem(AgentAll^.Focused+1);
              End;
              ClearEvent(Event);
              Redraw;
            End;
    Else;
    End;
    Else;
    End;
  inherited HandleEvent(Event);
End;

procedure TSelectAgentWindow.AddName;
Begin
End;



Function SelectionAgent(Var P:PBox):Boolean;
Label 1;
var
  R : TRect;
  Control : PView;
  i : Word;
begin
1:
SelectionAgent:=False;
ClearFind;
AInfo('Минуточку...');
R.Assign(12, 0, 68, 23);

New(AgentWin, Init(R, 'Выборка агентов'));

AgentWin^.Options := AgentWin^.Options or ofCenterX or ofCenterY;
AgentWin^.HelpCtx:=$E002;

R.Assign(27, 2, 28, 22);
Control := New(PScrollBar, Init(R));
AgentWin^.Insert(Control);

R.Assign(1, 2, 27, 22);
AgentAll := New(PBox, Init(R, 1, PScrollbar(Control)));
AgentAll^.NewList(New(PTextCollection, Init(1,1)));
Assign (AgentFile,Path.ToClient+'agent.db');
i:=IOResult;
Reset (AgentFile);
i:=IOResult;
If I=0 Then
Begin
While Not(Eof(AgentFile)) Do
 Begin
  ReadClient(AgentFile,AgentElement);
  If AgentElement.Employ Then
   Begin
    Format (AgentElement.Name,CClient);
    AgentAll^.List^.Insert(NewStr(AgentElement.Name+'│'+AgentElement.Kod));
    AgentAll^.SetRange(AgentAll^.List^.Count);
   End;
 End;
System.Close(AgentFile);
End
 Else
  Begin
   Noinfo;
   Dispose(Control,Done);
   Dispose(AgentAll,Done);
   Dispose(AgentWin,Done);
   MessageBox(^M+#3'Ошибка открытия файла '+Path.ToClient+'agent.db',Nil,mfError+mfCancelButton);
   Exit;
  End;
AgentAll^.FocusItem(0);
AgentAll^.HelpCtx:=$E044;
AgentWin^.Insert(agentAll);


  R.Assign(1, 1, 27, 2);
  AgentWin^.Insert(New(PLabel, Init(R, 'Агент                Код ', AgentAll)));

R.Assign(55, 2, 56, 22);
Control := New(PScrollBar, Init(R));
AgentWin^.Insert(Control);

R.Assign(29, 2, 55, 22);
AgentSelect := New(PBox, Init(R, 1, PScrollbar(Control)));
AgentSelect^.NewList(New(PTextCollection, Init(1,1)));
AgentSelect^.HelpCtx:=$E041;
AgentWin^.Insert(AgentSelect);

{
R.Assign(29, 1, 54, 2);
Control := New(PStaticText, Init(R, 'Выбранные агенты      Код'));
AgentWin^.Insert(Control);
}
  R.Assign(29, 1, 54, 2);
  AgentWin^.Insert(New(PLabel, Init(R,'Выбранные агенты     Код', AgentSelect)));



AgentWin^.SelectNext(False);
NoInfo;
C := Desktop^.ExecView(AgentWin);
If C <> cmCancel Then
 Begin
   ClearFind;
   If (AgentSelect^.List^.Count>= 1) Then
    Begin
     For c :=0 To AgentSelect^.List^.Count-1 Do
      Begin
       s:=AgentSelect^.GetText(c,AgentSelect^.List^.Count);
       Delete(s,1,CClient);
       s:=s+'│           0.00│           0.00';
       P^.List^.Insert(NewStr(s));
       P^.SetRange(P^.List^.Count);
      End;
       Dispose(Control,Done);
       Dispose(AgentAll,Done);
       Dispose(AgentSelect,Done);
       Dispose(AgentWin,Done);
       SelectionAgent:=True;
    End
    Else
     Begin
       MessageBox(^M+#3'Не выбрано ни одного агента!',Nil,mfError+mfCancelButton);
       Dispose(Control,Done);
       Dispose(AgentAll,Done);
       Dispose(AgentSelect,Done);
       Dispose(AgentWin,Done);
       Goto 1;
     End;
 End
 Else
  Begin
   Dispose(Control,Done);
   Dispose(AgentAll,Done);
   Dispose(AgentSelect,Done);
   Dispose(AgentWin,Done);
  End;

End;

Function SelectionSortrudn(Var P:PBox):Boolean;
Label 1;
var
  R : TRect;
  Control : PView;
  i : Word;
begin
1:
SelectionSortrudn:=False;
ClearFind;
AInfo('Минуточку...');
R.Assign(12, 0, 68, 23);

New(AgentWin, Init(R, 'Выборка сотрудников'));

AgentWin^.Options := AgentWin^.Options or ofCenterX or ofCenterY;
AgentWin^.HelpCtx:=$E002;

R.Assign(27, 2, 28, 22);
Control := New(PScrollBar, Init(R));
AgentWin^.Insert(Control);

R.Assign(1, 2, 27, 22);
AgentAll := New(PBox, Init(R, 1, PScrollbar(Control)));
AgentAll^.NewList(New(PTextCollection, Init(1,1)));
Assign (AgentFile,Path.ToClient+'lizo.db');
i:=IOResult;
Reset (AgentFile);
i:=IOResult;
If I=0 Then
Begin
While Not(Eof(AgentFile)) Do
 Begin
  ReadClient(AgentFile,AgentElement);
  If AgentElement.Employ Then
   Begin
    Format (AgentElement.Name,CClient);
    AgentAll^.List^.Insert(NewStr(AgentElement.Name+'│'+AgentElement.Kod));
    AgentAll^.SetRange(AgentAll^.List^.Count);
   End;
 End;
System.Close(AgentFile);
End
 Else
  Begin
   Noinfo;
   Dispose(Control,Done);
   Dispose(AgentAll,Done);
   Dispose(AgentWin,Done);
   MessageBox(^M+#3'Ошибка открытия файла '+Path.ToClient+'agent.db',Nil,mfError+mfCancelButton);
   Exit;
  End;
AgentAll^.FocusItem(0);
AgentAll^.HelpCtx:=$E044;
AgentWin^.Insert(agentAll);


  R.Assign(1, 1, 27, 2);
  AgentWin^.Insert(New(PLabel, Init(R, 'Агент                Код ', AgentAll)));

R.Assign(55, 2, 56, 22);
Control := New(PScrollBar, Init(R));
AgentWin^.Insert(Control);

R.Assign(29, 2, 55, 22);
AgentSelect := New(PBox, Init(R, 1, PScrollbar(Control)));
AgentSelect^.NewList(New(PTextCollection, Init(1,1)));
AgentSelect^.HelpCtx:=$E041;
AgentWin^.Insert(AgentSelect);

{
R.Assign(29, 1, 54, 2);
Control := New(PStaticText, Init(R, 'Выбранные агенты      Код'));
AgentWin^.Insert(Control);
}
  R.Assign(29, 1, 54, 2);
  AgentWin^.Insert(New(PLabel, Init(R,'Выбранные агенты     Код', AgentSelect)));



AgentWin^.SelectNext(False);
NoInfo;
C := Desktop^.ExecView(AgentWin);
If C <> cmCancel Then
 Begin
   ClearFind;
   If (AgentSelect^.List^.Count>= 1) Then
    Begin
     For c :=0 To AgentSelect^.List^.Count-1 Do
      Begin
       s:=AgentSelect^.GetText(c,AgentSelect^.List^.Count);
       Delete(s,1,CClient);
       s:=s+'│           0.00│           0.00';
       P^.List^.Insert(NewStr(s));
       P^.SetRange(P^.List^.Count);
      End;
       Dispose(Control,Done);
       Dispose(AgentAll,Done);
       Dispose(AgentSelect,Done);
       Dispose(AgentWin,Done);
       SelectionSortrudn:=True;
    End
    Else
     Begin
       MessageBox(^M+#3'Не выбрано ни одного агента!',Nil,mfError+mfCancelButton);
       Dispose(Control,Done);
       Dispose(AgentAll,Done);
       Dispose(AgentSelect,Done);
       Dispose(AgentWin,Done);
       Goto 1;
     End;
 End
 Else
  Begin
   Dispose(Control,Done);
   Dispose(AgentAll,Done);
   Dispose(AgentSelect,Done);
   Dispose(AgentWin,Done);
  End;

End;





Function SelectionKassa(Var P:PBox):Boolean;
Label 1;
var
  R : TRect;
  Control : PView;
  i : Word;
begin
1:
SelectionKassa:=False;
ClearFind;
AInfo('Минуточку...');
R.Assign(12, 0, 68, 23);

New(KassaWin, Init(R, 'Выборка кассовых операций'));

KassaWin^.Options := KassaWin^.Options or ofCenterX or ofCenterY;
KassaWin^.HelpCtx:=$E002;

R.Assign(27, 2, 28, 22);
Control := New(PScrollBar, Init(R));
KassaWin^.Insert(Control);

R.Assign(1, 2, 27, 22);
KassaAll := New(PBox, Init(R, 1, PScrollbar(Control)));
KassaAll^.NewList(New(PTextCollection, Init(1,1)));
Assign (KassaFile,Path.ToClient+'Kassa.db');
i:=IOResult;
Reset (KassaFile);
i:=IOResult;
If I=0 Then
Begin
While Not(Eof(KassaFile)) Do
 Begin
  ReadOperation(KassaFile,KassaElement);
  If KassaElement.Employ Then
   Begin
    Format (KassaElement.Name,CClient);
    KassaAll^.List^.Insert(NewStr(KassaElement.Name+'│'+KassaElement.Kod));
    KassaAll^.SetRange(KassaAll^.List^.Count);
   End;
 End;
System.Close(KassaFile);
End
 Else
  Begin
   Noinfo;
   Dispose(Control,Done);
   Dispose(KassaAll,Done);
   Dispose(KassaWin,Done);
   MessageBox(^M+#3'Ошибка открытия файла '+Path.ToClient+'Kassa.db',Nil,mfError+mfCancelButton);
   Exit;
  End;
KassaAll^.FocusItem(0);
KassaAll^.HelpCtx:=$E044;
KassaWin^.Insert(KassaAll);


  R.Assign(1, 1, 27, 2);
  KassaWin^.Insert(New(PLabel, Init(R, 'Кассовая операция    Код ', KassaAll)));

R.Assign(55, 2, 56, 22);
Control := New(PScrollBar, Init(R));
KassaWin^.Insert(Control);

R.Assign(29, 2, 55, 22);
KassaSelect := New(PBox, Init(R, 1, PScrollbar(Control)));
KassaSelect^.NewList(New(PTextCollection, Init(1,1)));

If (P^.List^.Count-1)>0 Then
 Begin
  For c:=0 To P^.List^.Count-1 Do
   Begin
    s:=P^.GetText(c,P^.Focused);
    KassaSelect^.List^.Insert(NewStr(s));
    KassaSelect^.SetRange(KassaSelect^.List^.Count);
   End;
 End;

KassaSelect^.HelpCtx:=$E041;
KassaWin^.Insert(KassaSelect);


  R.Assign(29, 1, 54, 2);
  KassaWin^.Insert(New(PLabel, Init(R,'Выбранные кассовые о Код', KassaSelect)));


KassaWin^.SelectNext(False);
NoInfo;
C := Desktop^.ExecView(KassaWin);
If C <> cmCancel Then
 Begin
   ClearFind;

   P^.NewList(Nil);
   P^.NewList(New(PMyCollection, Init(0,1)));

   If (KassaSelect^.List^.Count>= 1) Then
    Begin
     For c :=0 To KassaSelect^.List^.Count-1 Do
      Begin
       s:=KassaSelect^.GetText(c,KassaSelect^.List^.Count);
       P^.List^.Insert(NewStr(s));
       P^.SetRange(P^.List^.Count);
      End;
       Dispose(Control,Done);
       Dispose(KassaAll,Done);
       Dispose(KassaSelect,Done);
       Dispose(KassaWin,Done);
       SelectionKassa:=True;
    End

 End
 Else
  Begin
   Dispose(Control,Done);
   Dispose(KassaAll,Done);
   Dispose(KassaSelect,Done);
   Dispose(KassaWin,Done);
  End;

End;



procedure TSelectKassaWindow.HandleEvent(var Event: TEvent);
Label 2,3;
Var s,s1 : String{[CClient+1+CClientKod]};
    ls : Word;
    res : Word;
    Logik : Boolean;
    fstr : string[150];
Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of

   kbGrayPlus:Begin
                ClearFind;
          If ((KassaAll^.State and sfFocused <> 0)And(KassaAll^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...');
             For ls :=0 To KassaAll^.List^.Count-1 Do
              Begin
               s:=KassaAll^.GetText(ls,KassaAll^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CClient);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0) Or (Pos('*',Fstr)>0) Then Logik:=True;
               1:If (fstr=s1)Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               If TestElement(Copy(s,1+CClient+1,CArtikul),KassaSelect) Then
                Begin
                 KassaSelect^.List^.Insert(NewStr(s));
                 KassaSelect^.SetRange(KassaSelect^.List^.Count);
                End;{TestElement}
              End;{For}
              NoInfoMsg;
              ProdagaWindow:=False;
              If KassaSelect^.Focused+1<KassaSelect^.List^.Count Then
              KassaSelect^.FocusItem(KassaSelect^.List^.Count-1);
              AddName;
              KassaSelect^.FocusItem(0);
                End;{Maska}
              Redraw;
            End;{Nil}
              ClearEvent(Event);
              End;
   kbGrayMinus:Begin
                ClearFind;

          If ((KassaSelect^.State and sfFocused <> 0)And(KassaSelect^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...');
             3:
             if (KassaSelect^.List^.Count>= 1) Then
             For ls :=0 To KassaSelect^.List^.Count-1 Do
              Begin
               s:=KassaSelect^.GetText(ls,KassaSelect^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CClient);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               Begin
                KassaSelect^.List^.AtFree(Ls);
                KassaSelect^.SetRange(KassaSelect^.List^.Count);
                goto 3;
               End;
              End;{For}

             If KassaSelect^.Focused>0 Then
             KassaSelect^.FocusItem(KassaSelect^.Focused);

             If (KassaSelect^.Focused>=KassaSelect^.List^.Count) and(KassaSelect^.Focused>0) Then
             KassaSelect^.FocusItem(KassaSelect^.Focused-1);


              NoInfoMsg;
              ProdagaWindow:=False;
              AddName;
              KassaSelect^.FocusItem(0);
                End;{Maska}
             Redraw;
            End;{Nil}
              ClearEvent(Event);
              End;
   kbCtrlIns: Begin
                ClearFind;
            If ((KassaAll^.State and sfFocused <> 0)And(KassaAll^.List^.Count>= 1)) Then
            Begin
            DInfoMsg('Минуточку...');
             KassaSelect^.Focusitem(0);
             For ls :=0 To KassaAll^.List^.Count-1 Do
              Begin
               s:=KassaAll^.GetText(ls,KassaAll^.List^.Count);
               if Testelement(Copy(s,1+CClient+1,CClientKod),KassaSelect) then
                Begin
                 KassaSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 KassaSelect^.SetRange(KassaSelect^.List^.Count);
                 If KassaAll^.Focused+1<KassaAll^.List^.Count Then KassaAll^.FocusItem(KassaAll^.Focused+1);
                 If KassaSelect^.Focused+1<KassaSelect^.List^.Count Then
                 KassaSelect^.FocusItem(KassaSelect^.List^.Count-1);
            NoInfoMsg;
             End
            Else ClearEvent(Event);
            Redraw;
            End;

  kbCtrLDel: Begin
                ClearFind;
     If (KassaSelect^.State and sfFocused <> 0) And (KassaSelect^.List<>Nil)And(KassaSelect^.List^.Count>=1) Then
            Begin
             KassaSelect^.NewList(nil);
             KassaSelect^.NewList(New(PTextCollection, Init(1,25)));
            End;
            ClearEvent(Event);
             Redraw;
            End;
     kbDel: Begin
                ClearFind;
     If (KassaSelect^.State and sfFocused <> 0) And (KassaSelect^.List<>Nil)And(KassaSelect^.List^.Count>=1) Then
            Begin
             KassaSelect^.List^.AtFree(KassaSelect^.Focused);
             KassaSelect^.SetRange(KassaSelect^.List^.Count);
             If KassaSelect^.Focused>0 Then
             KassaSelect^.FocusItem(KassaSelect^.Focused);

             If (KassaSelect^.Focused>=KassaSelect^.List^.Count) and(KassaSelect^.Focused>0) Then
             KassaSelect^.FocusItem(KassaSelect^.Focused-1);

            End;
              ClearEvent(Event);
              Redraw;
            End;
      kbIns: Begin
                ClearFind;
            If(KassaAll^.State and sfFocused <> 0) And (KassaAll^.List^.Count>=1) Then
            Begin
               s:=KassaAll^.GetText(KassaAll^.Focused,KassaAll^.List^.COunt);
               If TestElement(Copy(s,1+CClient+1,CClientKod),KassaSelect) Then
               Begin
               KassaSelect^.List^.Insert(NewStr(s));
               KassaSelect^.SetRange(KassaSelect^.List^.Count);
               s:=Copy(s,1+CClient+1,CClientKod);
               KassaSelect^.FocusItem(LoCation(KassaSelect,S,ProdagaWindow));
             If KassaSelect^.Focused+1<KassaSelect^.List^.Count Then
             KassaSelect^.FocusItem(KassaSelect^.List^.Count-1);
               End;
               If (KassaAll^.Focused+1) <  KassaAll^.List^.Count Then
               KassaAll^.FocusItem(KassaAll^.Focused+1);
              End;
              ClearEvent(Event);
              Redraw;
            End;
    Else;
    End;
    Else;
    End;
  inherited HandleEvent(Event);
End;

procedure TSelectKassaWindow.AddName;
Begin
End;

Destructor TSelectKassaWindow.Done;
Begin
TDialog.Done;
End;





Function SelectionGroup(Var P:PBox):Boolean;
Label 1;
var
  R : TRect;
  Control : PView;
  i : Word;
begin
1:
SelectionGroup:=False;
ClearFind;
AInfo('Минуточку...');
R.Assign(12, 0, 80, 23);

New(GroupWin, Init(R, 'Выборка групп ревизий'));

GroupWin^.Options := GroupWin^.Options or ofCenterX or ofCenterY;
GroupWin^.HelpCtx:=$E002;

R.Assign(33, 2, 34, 22);
Control := New(PScrollBar, Init(R));
GroupWin^.Insert(Control);

R.Assign(1, 2, 33, 22);
GroupAll := New(PBox, Init(R, 1, PScrollbar(Control)));
GroupAll^.NewList(New(PTextCollection, Init(1,1)));
Assign (GroupFile,Path.ToClient+'rGroup.db');
i:=IOResult;
Reset (GroupFile);
i:=IOResult;
If I=0 Then
Begin
While Not(Eof(GroupFile)) Do
 Begin
  ReadGroup(GroupFile,GroupElement);
  If GroupElement.Employ Then
   Begin
    Format (GroupElement.GroupName,CName);
    GroupAll^.List^.Insert(NewStr(GroupElement.GroupName+'│'+GroupElement.Kod));
    GroupAll^.SetRange(GroupAll^.List^.Count);
   End;
 End;
System.Close(GroupFile);
End
 Else
  Begin
   Noinfo;
   Dispose(Control,Done);
   Dispose(GroupAll,Done);
   Dispose(GroupWin,Done);
   MessageBox(^M+#3'Ошибка открытия файла '+Path.ToClient+'rGroup.db',Nil,mfError+mfCancelButton);
   Exit;
  End;
GroupAll^.FocusItem(0);
GroupAll^.HelpCtx:=$E044;
GroupWin^.Insert(GroupAll);


  R.Assign(1, 1, 33, 2);
  GroupWin^.Insert(New(PLabel, Init(R, 'Группы ревизий             Код ', GroupAll)));

R.Assign(67, 2, 68, 22);
Control := New(PScrollBar, Init(R));
GroupWin^.Insert(Control);

R.Assign(35, 2, 67, 22);
GroupSelect := New(PBox, Init(R, 1, PScrollbar(Control)));
GroupSelect^.NewList(New(PTextCollection, Init(1,1)));

If (P^.List^.Count-1)>0 Then
 Begin
  For c:=0 To P^.List^.Count-1 Do
   Begin
    s:=P^.GetText(c,P^.Focused);
    GroupSelect^.List^.Insert(NewStr(s));
    GroupSelect^.SetRange(GroupSelect^.List^.Count);
   End;
 End;

GroupSelect^.HelpCtx:=$E041;
GroupWin^.Insert(GroupSelect);


  R.Assign(35, 1, 66, 2);
  GroupWin^.Insert(New(PLabel, Init(R,'Выбранные группы           Код', GroupSelect)));


GroupWin^.SelectNext(False);
NoInfo;
C := Desktop^.ExecView(GroupWin);
If C <> cmCancel Then
 Begin
   ClearFind;

   P^.NewList(Nil);
   P^.NewList(New(PMyCollection, Init(0,1)));

   If (GroupSelect^.List^.Count>= 1) Then
    Begin
     For c :=0 To GroupSelect^.List^.Count-1 Do
      Begin
       s:=GroupSelect^.GetText(c,GroupSelect^.List^.Count);
       P^.List^.Insert(NewStr(s));
       P^.SetRange(P^.List^.Count);
      End;
       Dispose(Control,Done);
       Dispose(GroupAll,Done);
       Dispose(GroupSelect,Done);
       Dispose(GroupWin,Done);
       SelectionGroup:=True;
    End

 End
 Else
  Begin
   Dispose(Control,Done);
   Dispose(GroupAll,Done);
   Dispose(GroupSelect,Done);
   Dispose(GroupWin,Done);
  End;

End;



procedure TSelectGroup.HandleEvent(var Event: TEvent);
Label 2,3;
Var s,s1 : String{[CClient+1+CClientKod]};
    ls : Word;
    res : Word;
    Logik : Boolean;
    fstr : string[150];
Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of

   kbGrayPlus:Begin
                ClearFind;
          If ((GroupAll^.State and sfFocused <> 0)And(GroupAll^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...');
             For ls :=0 To GroupAll^.List^.Count-1 Do
              Begin
               s:=GroupAll^.GetText(ls,GroupAll^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CNAme);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0) Or (Pos('*',Fstr)>0) Then Logik:=True;
               1:If (fstr=s1)Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               If TestElement(Copy(s,1+CName+1,CArtikul),GroupSelect) Then
                Begin
                 GroupSelect^.List^.Insert(NewStr(s));
                 GroupSelect^.SetRange(GroupSelect^.List^.Count);
                End;{TestElement}
              End;{For}
              NoInfoMsg;
              ProdagaWindow:=False;
              If GroupSelect^.Focused+1<GroupSelect^.List^.Count Then
              GroupSelect^.FocusItem(GroupSelect^.List^.Count-1);
              AddName;
              GroupSelect^.FocusItem(0);
                End;{Maska}
              Redraw;
            End;{Nil}
              ClearEvent(Event);
              End;
   kbGrayMinus:Begin
                ClearFind;

          If ((GroupSelect^.State and sfFocused <> 0)And(GroupSelect^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...');
             3:
             if (GroupSelect^.List^.Count>= 1) Then
             For ls :=0 To GroupSelect^.List^.Count-1 Do
              Begin
               s:=GroupSelect^.GetText(ls,GroupSelect^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CName);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               Begin
                GroupSelect^.List^.AtFree(Ls);
                GroupSelect^.SetRange(GroupSelect^.List^.Count);
                goto 3;
               End;
              End;{For}

             If GroupSelect^.Focused>0 Then
             GroupSelect^.FocusItem(GroupSelect^.Focused);

             If (GroupSelect^.Focused>=GroupSelect^.List^.Count) and(GroupSelect^.Focused>0) Then
             GroupSelect^.FocusItem(GroupSelect^.Focused-1);


              NoInfoMsg;
              ProdagaWindow:=False;
              AddName;
              GroupSelect^.FocusItem(0);
                End;{Maska}
             Redraw;
            End;{Nil}
              ClearEvent(Event);
              End;
   kbCtrlIns: Begin
                ClearFind;
            If ((GroupAll^.State and sfFocused <> 0)And(GroupAll^.List^.Count>= 1)) Then
            Begin
            DInfoMsg('Минуточку...');
             GroupSelect^.Focusitem(0);
             For ls :=0 To GroupAll^.List^.Count-1 Do
              Begin
               s:=GroupAll^.GetText(ls,GroupAll^.List^.Count);
               if Testelement(Copy(s,1+CName+1,CClientKod),GroupSelect) then
                Begin
                 GroupSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 GroupSelect^.SetRange(GroupSelect^.List^.Count);
                 If GroupAll^.Focused+1<GroupAll^.List^.Count Then GroupAll^.FocusItem(GroupAll^.Focused+1);
                 If GroupSelect^.Focused+1<GroupSelect^.List^.Count Then
                 GroupSelect^.FocusItem(GroupSelect^.List^.Count-1);
            NoInfoMsg;
             End
            Else ClearEvent(Event);
            Redraw;
            End;

  kbCtrLDel: Begin
                ClearFind;
     If (GroupSelect^.State and sfFocused <> 0) And (GroupSelect^.List<>Nil)And(GroupSelect^.List^.Count>=1) Then
            Begin
             GroupSelect^.NewList(nil);
             GroupSelect^.NewList(New(PTextCollection, Init(1,25)));
            End;
            ClearEvent(Event);
             Redraw;
            End;
     kbDel: Begin
                ClearFind;
     If (GroupSelect^.State and sfFocused <> 0) And (GroupSelect^.List<>Nil)And(GroupSelect^.List^.Count>=1) Then
            Begin
             GroupSelect^.List^.AtFree(GroupSelect^.Focused);
             GroupSelect^.SetRange(GroupSelect^.List^.Count);
             If GroupSelect^.Focused>0 Then
             GroupSelect^.FocusItem(GroupSelect^.Focused);

             If (GroupSelect^.Focused>=GroupSelect^.List^.Count) and(GroupSelect^.Focused>0) Then
             GroupSelect^.FocusItem(GroupSelect^.Focused-1);

            End;
              ClearEvent(Event);
              Redraw;
            End;
      kbIns: Begin
                ClearFind;
            If(GroupAll^.State and sfFocused <> 0) And (GroupAll^.List^.Count>=1) Then
            Begin
               s:=GroupAll^.GetText(GroupAll^.Focused,GroupAll^.List^.COunt);
               If TestElement(Copy(s,1+CName+1,CClientKod),GroupSelect) Then
               Begin
               GroupSelect^.List^.Insert(NewStr(s));
               GroupSelect^.SetRange(GroupSelect^.List^.Count);
               s:=Copy(s,1+CName+1,CClientKod);
               GroupSelect^.FocusItem(LoCation(GroupSelect,S,ProdagaWindow));
             If GroupSelect^.Focused+1<GroupSelect^.List^.Count Then
             GroupSelect^.FocusItem(GroupSelect^.List^.Count-1);
               End;
               If (GroupAll^.Focused+1) <  GroupAll^.List^.Count Then
               GroupAll^.FocusItem(GroupAll^.Focused+1);
              End;
              ClearEvent(Event);
              Redraw;
            End;
    Else;
    End;
    Else;
    End;
  inherited HandleEvent(Event);
End;

procedure TSelectGroup.AddName;
Begin
End;

Destructor TSelectGroup.Done;
Begin
TDialog.Done;
End;




Function SelectionClient(Regim:Boolean; Var P:PBox):Boolean;
Label 1;
var
  R : TRect;
  Control : PView;
  i : Word;
  ClientFile : ClientFileType;
  ClientElement : PClientType;
  c,count : Word;
begin
1:
SelectionClient:=False;
ClearFind;
DInfoMsg('Минуточку...');
R.Assign(12, 0, 68, 23);

New(ClientWin, Init(R, 'Выборка клиентов'));

ClientWin^.Options := ClientWin^.Options or ofCenterX or ofCenterY;

R.Assign(27, 2, 28, 22);
Control := New(PScrollBar, Init(R));
ClientWin^.Insert(Control);

R.Assign(1, 2, 27, 22);
ClientAll := New(PBox, Init(R, 1, PScrollbar(Control)));
ClientAll^.NewList(New(PTextCollection, Init(1,1)));
Assign (ClientFile,Path.ToClient+'Client.db');
i:=IOResult;
Reset (ClientFile);
i:=IOResult;
If I=0 Then
Begin
While Not(Eof(ClientFile)) Do
 Begin
  New(ClientElement,Init);
  ReadClient(ClientFile,ClientElement^.Dat);
  If ClientElement^.Dat.Employ Then
   Begin
    Format (ClientElement^.Dat.Name,CClient);
    ClientAll^.List^.Insert(NewStr(ClientElement^.Dat.Name+'│'+ClientElement^.Dat.Kod));
    ClientAll^.SetRange(ClientAll^.List^.Count);
   End;
  Dispose(ClientElement,Done);
 End;{Eof}
System.Close(ClientFile);
End

 Else
  Begin
   NoinfoMsg;
   Dispose(Control,Done);
   Dispose(ClientAll,Done);
   Dispose(ClientWin,Done);
   MessageBox(^M+#3'Ошибка открытия файла '+Path.ToClient+'client.db',Nil,mfError+mfCancelButton);
   Exit;
  End;
ClientAll^.FocusItem(0);
ClientAll^.HelpCtx:={E044}$E044;
ClientWin^.Insert(ClientAll);


  R.Assign(1, 1, 27, 2);
  ClientWin^.Insert(New(PLabel, Init(R, 'Клиент               Код ', ClientAll)));

R.Assign(55, 2, 56, 22);
Control := New(PScrollBar, Init(R));
ClientWin^.Insert(Control);

R.Assign(29, 2, 55, 22);
ClientSelect := New(PBox, Init(R, 1, PScrollbar(Control)));
ClientSelect^.NewList(New(PTextCollection, Init(1,1)));
ClientSelect^.HelpCtx:=$E044{F362};
ClientWin^.Insert(ClientSelect);

  R.Assign(29, 1, 54, 2);
  ClientWin^.Insert(New(PLabel, Init(R,'Выбранные клиенты    Код', ClientSelect)));


R.Assign(17, 22, 36, 23);
Control := New(PColoredText, Init(R, ' Выбрано клиентов:', $74));
ClientWin^.Insert(Control);

R.Assign(35, 22, 40, 23);
ControlAmount1 := New(PColoredText, Init(R, #3+'0', $4e));
ClientWin^.Insert(ControlAmount1);


ClientWin^.SelectNext(False);
ClientWin^.AddName;
NoInfoMsg;
C := Desktop^.ExecView(ClientWin);
If C <> cmCancel Then
 Begin
   ClearFind;

   If Regim Then
   If (ClientSelect^.List^.Count> 1) Then
   Begin
    MessageBox(^M+#3'Можно выбрать только одного клиента!',Nil,mfError+mfCancelButton);
       Dispose(Control,Done);
       Dispose(ControlAmount1,Done);
       Dispose(ClientAll,Done);
       Dispose(ClientSelect,Done);
       Dispose(ClientWin,Done);
       Goto 1;
   End;

   If (ClientSelect^.List^.Count>0) Then
    Begin
     For c :=0 To ClientSelect^.List^.Count-1 Do
      Begin
       s:=ClientSelect^.GetText(c,ClientSelect^.List^.Count);
       Delete(s,1,CClient);
       s:=s+'│           0.00│           0.00│           0.00│           0.00│';
                                                             {акцизный сбор}
       P^.List^.Insert(NewStr(s));
       P^.SetRange(P^.List^.Count);
      End;
       Dispose(Control,Done);
       Dispose(ControlAmount1,Done);
       Dispose(ClientAll,Done);
       Dispose(ClientSelect,Done);
       Dispose(ClientWin,Done);
       SelectionClient:=True;
    End
    Else
     Begin
       MessageBox(^M+#3'Не выбрано ни одного клиента!',Nil,mfError+mfCancelButton);
       Dispose(Control,Done);
       Dispose(ControlAmount1,Done);
       Dispose(ClientAll,Done);
       Dispose(ClientSelect,Done);
       Dispose(ClientWin,Done);
       Goto 1;
     End;
 End
 Else
  Begin
   Dispose(Control,Done);
   Dispose(ControlAmount1,Done);
   Dispose(ClientAll,Done);
   Dispose(ClientSelect,Done);
   Dispose(ClientWin,Done);
  End;

End;




Destructor TSelectClientWindow.Done;
Begin
TDialog.Done;
End;



procedure TSelectClientWindow.HandleEvent(var Event: TEvent);
Label 2,3;
Var s,s1 : String{[CClient+1+CClientKod]};
    ls : Word;
    res : Word;
    Logik : Boolean;
    fstr : TMyString;
Begin
  Case Event.What Of
  evCommand : Begin
              End;
  evKeyDown :
  Case Event.KeyCode Of
   kbEnter  :Begin
                ClearFind;
                inherited HandleEvent(Event);
                If (ClientWin^.Current=PView(ClientSelect)) Then
                   Begin
                    Event.What:=evCommand;
                    Event.Command:=CmOk;
                   End;
             End;

   kbGrayPlus,kbAltF1:Begin
                ClearFind;
          If ((ClientAll^.State and sfFocused <> 0)And(ClientAll^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...');
             For ls :=0 To ClientAll^.List^.Count-1 Do
              Begin
               s:=ClientAll^.GetText(ls,ClientAll^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CClient);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0) Or (Pos('*',Fstr)>0) Then Logik:=True;
               1:If (fstr=s1)Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               If TestElement(Copy(s,1+CClient+1,CArtikul),ClientSelect) Then
                Begin
                 ClientSelect^.List^.Insert(NewStr(s));
                 ClientSelect^.SetRange(ClientSelect^.List^.Count);
                End;{TestElement}
              End;{For}
              NoInfoMsg;
              ProdagaWindow:=False;
              If ClientSelect^.Focused+1<ClientSelect^.List^.Count Then
              ClientSelect^.FocusItem(ClientSelect^.List^.Count-1);
              ClientSelect^.FocusItem(0);
              AddName;
                End;{Maska}
              Redraw;
            End;{Nil}
              ClearEvent(Event);
              End;
   kbGrayMinus,kbAltF2:Begin
                ClearFind;

          If ((ClientSelect^.State and sfFocused <> 0)And(ClientSelect^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...');
             3:
             if (ClientSelect^.List^.Count>= 1) Then
             For ls :=0 To ClientSelect^.List^.Count-1 Do
              Begin
               s:=ClientSelect^.GetText(ls,ClientSelect^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CClient);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               Begin
                ClientSelect^.List^.AtFree(Ls);
                ClientSelect^.SetRange(ClientSelect^.List^.Count);
                goto 3;
               End;
              End;{For}

             If ClientSelect^.Focused>0 Then
             ClientSelect^.FocusItem(ClientSelect^.Focused);

             If (ClientSelect^.Focused>=ClientSelect^.List^.Count) and(ClientSelect^.Focused>0) Then
             ClientSelect^.FocusItem(ClientSelect^.Focused-1);


              NoInfoMsg;
              ProdagaWindow:=False;
              AddName;
              ClientSelect^.FocusItem(0);
                End;{Maska}
             Redraw;
            End;{Nil}
              ClearEvent(Event);
              End;
   kbCtrlIns: Begin
                ClearFind;
            If ((ClientAll^.State and sfFocused <> 0)And(ClientAll^.List^.Count>= 1)) Then
            Begin
            DInfoMsg('Минуточку...');
             ClientSelect^.Focusitem(0);
             For ls :=0 To ClientAll^.List^.Count-1 Do
              Begin
               s:=ClientAll^.GetText(ls,ClientAll^.List^.Count);
               if Testelement(Copy(s,1+CClient+1,CClientKod),ClientSelect) then
                Begin
                 ClientSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 ClientSelect^.SetRange(ClientSelect^.List^.Count);
                 If ClientAll^.Focused+1<ClientAll^.List^.Count Then ClientAll^.FocusItem(ClientAll^.Focused+1);
                 If ClientSelect^.Focused+1<ClientSelect^.List^.Count Then
                 ClientSelect^.FocusItem(ClientSelect^.List^.Count-1);
            NoInfoMsg;
             End
            Else ClearEvent(Event);
            AddName;
            Redraw;
            End;

  kbCtrLDel: Begin
                ClearFind;
     If (ClientSelect^.State and sfFocused <> 0) And (ClientSelect^.List<>Nil)And(ClientSelect^.List^.Count>=1) Then
            Begin
             ClientSelect^.NewList(nil);
             ClientSelect^.NewList(New(PTextCollection, Init(1,25)));
            End;
            AddName;
            ClearEvent(Event);
             Redraw;
            End;
     kbDel: Begin
                ClearFind;
     If (ClientSelect^.State and sfFocused <> 0) And (ClientSelect^.List<>Nil)And(ClientSelect^.List^.Count>=1) Then
            Begin
             ClientSelect^.List^.AtFree(ClientSelect^.Focused);
             ClientSelect^.SetRange(ClientSelect^.List^.Count);
             If ClientSelect^.Focused>0 Then
             ClientSelect^.FocusItem(ClientSelect^.Focused);

             If (ClientSelect^.Focused>=ClientSelect^.List^.Count) and(ClientSelect^.Focused>0) Then
             ClientSelect^.FocusItem(ClientSelect^.Focused-1);

            End;
              AddName;
              ClearEvent(Event);
              Redraw;
            End;
      kbIns: Begin
                ClearFind;
            If(ClientAll^.State and sfFocused <> 0) And (ClientAll^.List^.Count>=1) Then
            Begin
               s:=ClientAll^.GetText(ClientAll^.Focused,ClientAll^.List^.COunt);
               If TestElement(Copy(s,1+CClient+1,CClientKod),ClientSelect) Then
               Begin
               ClientSelect^.List^.Insert(NewStr(s));
               ClientSelect^.SetRange(ClientSelect^.List^.Count);
               s:=Copy(s,1+CClient+1,CClientKod);
               ClientSelect^.FocusItem(LoCation(ClientSelect,S,ProdagaWindow));
             If ClientSelect^.Focused+1<ClientSelect^.List^.Count Then
             ClientSelect^.FocusItem(ClientSelect^.List^.Count-1);
               End;
               If (ClientAll^.Focused+1) <  ClientAll^.List^.Count Then
               ClientAll^.FocusItem(ClientAll^.Focused+1);
              End;
              AddName;
              ClearEvent(Event);
              Redraw;
            End;
    Else;
    End;
    Else;
    End;

  inherited HandleEvent(Event);

End;


procedure TSelectClientWindow.AddName;
Var R : TRect;
    KolStr : String[5];
Begin

  Str(ClientSelect^.List^.Count:4,KolStr);
  Dispose(ControlAmount1,Done);
  R.Assign(35, 22, 41, 23);
  ControlAmount1 := New(PColoredText, Init(R, #3+KolStr, $4e));
  ClientWin^.Insert(ControlAmount1);
End;



Function CreatGroupList(Var P:PBox):Boolean;
Var
  i : Word;
  GroupFile : File;
  GroupElement : PBufGroupType;
  c,count : Word;
begin
CreatGroupList:=False;
ClearFind;
DInfoMsg('Создаю список групп...');

Assign (GroupFile,Path.ToClient+'Group.db');
i:=IOResult;
Reset (GroupFile,SizeOf(GroupType));
i:=IOResult;
If I=0 Then
Begin
While Not(Eof(GroupFile)) Do
 Begin
  New(GroupElement,Init);
  ReadBufGroup(GroupFile,GroupElement,Count);
For c:=1 To Count Do
Begin
  If GroupElement^.Point.Dat[c].Employ Then
   Begin
    Format (GroupElement^.Point.Dat[c].GroupName,CName);
    P^.List^.Insert(NewStr(GroupElement^.Point.Dat[c].GroupName+'│'+GroupElement^.Point.Dat[c].Kod+
    '│           0.00│         0.0000│           0.00│         0.0000│'));
    P^.SetRange(P^.List^.Count);
   End;
End;{For}
  Dispose(GroupElement,Done);
 End;{Eof}
System.Close(GroupFile);
End
 Else
  Begin
   NoinfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла '+Path.ToClient+'Group.db',Nil,mfError+mfCancelButton);
   Exit;
  End;

NoInfoMsg;
CreatGroupList:=True;
End;







Begin
Sort:=1;
Assort:=0;
ZapretOpt:=0;
Sertif:=0;
Akzis:=0;
sss[1]:=0;
sss[2]:=0;
For c:=1 To CDivision Do M[c]:=1;
End.

