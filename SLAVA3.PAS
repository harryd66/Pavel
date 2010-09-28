{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

unit Slava3;

Interface

Uses ServStr,Glob,Dialogs,Drivers,MyCalc;

(*
Type
    PSetupAgentPlanWindow= ^TSetupAgentPlanWindow;
    TSetupAgentPlanWindow = object(TDialog)
    AgKod : String[CClientKod];
    Calc        : PMyCalculator;
    Procedure SetupPlan (Cod:Integer);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure AddNAme;
    procedure AddRazdelToList(Cod:Word;s:String);
    procedure AddClientToList(Cod:Word;s:String);
    procedure CalcItogo(P1,P2:PBox);
    procedure FormReport(P1,P2:PBox);
    Destructor Done;Virtual;
  end;
*)

{
Type PlanClientType=Record
     L:Array [0..80] Of PBox;
     Logik : Array[0..80] Of Boolean;
     End;

Type PlanAgentType=Record
     L:Array [0..100] Of PlanClientType;
     Logik : Array[0..100] Of Boolean;
     End;
}




Implementation

uses Objects, Views, MsgBox,Vision3,Validate,Access,Access3,ColorTxt,App,
     DBEngine,TPDate,NetDbEng,Serv,Utils;

VAr ConfigFile,
    ConfigFileBak,
    ConfigFileNew : Text;
{    SetupWin : PSetupAgentPlanWindow;}
    Control : PView;
    ControlPlanRAzdel,
    ControlRazdelCount,
    ControlClientCount,
    ControlPlanClient : PView;
    AllRazdel,SelectRAzdel,AllClient,SelectCLient : PBox;


(*
Function TestElementR (Const S : AllStr;Const P : PBox) : Boolean;
Var ls : Word;
    k  : Byte;
    st : string[150];
Begin
TestElementR:=True;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
k:=Pos('│',St);
ST:=Copy(St,K+1,CRAzdelKod);
If St=S Then
   Begin
    TestElementR:=False;
    Break;
   End;
End;
End;


Function TestElementC (Const S : AllStr;Const P : PBox) : Boolean;
Var ls : Word;
    k  : Byte;
    st : string[150];
Begin
TestElementC:=True;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
k:=Pos('│',St);
ST:=Copy(St,K+1,CClientKod);
If St=S Then
   Begin
    TestElementC:=False;
    Break;
   End;
End;
End;




Procedure ReadRazdelSection(Var RZ:PBox);
Var Find : Boolean;
    s : string[150];
    c : Word;
Begin
Find:=FAlse;
While Not(Eof(ConfigFile)) And Not(Find) Do
 Begin
  Readln(ConfigFile,S);
  UpCases(s);
  c:=IOResult;
  {нашли секцию}
  If Pos('[RAZDEL]',s)>0 Then
   Begin
    Find:=True;
    Break;{выходим из цикла после удачного поиска}
   End;
 End;

If Find Then
While Not(Eof(ConfigFile)) Do
 Begin
  Readln(ConfigFile,S);
  UpCases(s);
  c:=IOResult;
  {нашли секцию}
  If Pos('[END_RAZDEL]',s)>0 Then
   Begin
    Find:=True;
    Break;{выходим из функции после удачного чтения списка разделов}
   End;
   DelSpaceRight(s);
   s[3]:='│';
   RZ^.List^.Insert(NewStr(s));
   RZ^.SetRange(RZ^.List^.Count);
 End;
End;


Procedure ReadClientSection(Var Cl:PBox);
Var Find : Boolean;
    s : string[150];
    c : Word;
Begin
Find:=FAlse;
While Not(Eof(ConfigFile)) And Not(Find) Do
 Begin
  Readln(ConfigFile,S);
  UpCases(s);
  c:=IOResult;
  {нашли секцию}
  If Pos('[CLIENT]',s)>0 Then
   Begin
    Find:=True;
    Break;{выходим из цикла после удачного поиска}
   End;
 End;

If Find Then
While Not(Eof(ConfigFile)) Do
 Begin
  Readln(ConfigFile,S);
  UpCases(s);
  c:=IOResult;
  {нашли секцию}
  If Pos('[END_CLIENT]',s)>0 Then
   Begin
    Find:=True;
    Break;{выходим из функции после удачного чтения списка клиентов}
   End;
   DelSpaceRight(s);
   s[5]:='│';
   Cl^.List^.Insert(NewStr(s));
   Cl^.SetRange(Cl^.List^.Count);
 End;
End;



Function FindAgent(Kod:ArtikulStr):Boolean;
Var Find : Boolean;
    s : string[150];
    c : Word;
Begin
Find:=FAlse;
FindAgent:=False;
While Not(Eof(ConfigFile)) And Not(Find) Do
 Begin
  Readln(ConfigFile,S);
  c:=IOResult;
  {нашли секцию}
  If Pos('['+Kod+']',s)>0 Then
   Begin
    Find:=True;
    FindAgent:=True;
    Exit;{выходим из функции после удачного поиска}
   End;
 End;
End;


Function ReadAgentPravila(Cod:ArtikulStr;Var ClList:PBox;Var RzList:PBox):Boolean;
Var c: Word;
    s: string[150];
Begin
ReadAgentPravila:=False;
Assign(ConfigFile,Path.ToProgram+'agent.cfg');
c:=IOResult;
Reset(ConfigFile);
c:=IOResult;
If c<>0 Then Exit;
{ищем секцию с нашим агентом [0001]}

If Not(FindAgent(Cod)) Then
 Begin
  c:=IOResult;
  Close(ConfigFile);
  c:=IOResult;
 End;

ReadRazdelSection(RzList);
ReadClientSection(ClList);


c:=IOResult;
Close(ConfigFile);
c:=IOResult;
End;



Function WriteAgentPravila(Cod:ArtikulStr;Const ClList:PBox;Const RzList:PBox):Boolean;
Var c : Word;
    s : string[150];
    Stop : Boolean;
Begin
{читаем из него все секции за исключением той которую собираемся писать}
WriteAgentPravila:=False;
{создаем новый файл agent.new}
Assign(ConfigFileNew,Path.ToProgram+'agent.new');
c:=IOResult;
Rewrite(ConfigFileNew);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка записи в файл настройки '+Path.ToProgram+'agent.new!'+
  ' Код:'+IntToStr(c,4),Nil,mfError+mfCancelButton);
  Exit;
 End;


Assign(ConfigFileBak,Path.ToProgram+'agent.bak');
c:=IOResult;
Erase(ConfigFileBak);
c:=IOResult;



{открываем старый agent.cfg}
Assign(ConfigFile,Path.ToProgram+'agent.cfg');
c:=IOResult;
Reset(ConfigFile);
c:=IOResult;

If c=0 Then
 Begin
  While Not(Eof(ConfigFile)) Do
   Begin
    Readln(ConfigFile,s);
    If Pos('['+COD+']',s)>0 Then{локализовали место старой информации}
     Begin
      {цикл пропуска старой информации}
       Stop:=False;
       While Not(Eof(ConfigFile)) And Not(Stop) Do
        Begin
         Readln(ConfigFile,s);
         If Pos(s,'[END_AGENT]')>0 Then Stop:=True;
        End;
     End
    Else
     Begin
      Writeln(ConfigFileNew,s);
     End;
   End;
  c:=IOResult;
  Close(ConfigFile);
  c:=IOResult;
  Rename(ConfigFile,Path.ToProgram+'agent.bak');
 {закрываем его и переименовываем его в *.bak}
 End;{Если файл существует}

{весь список из памяти запысываем в *.new}
c:=IOResult;
Writeln(ConfigFileNew,'['+Cod+'] '+GetAgentField(FClient,Cod));
Writeln(ConfigFileNew,'[RAZDEL]');
{запоняем список разделов}
If (RzList^.List^.Count)>0 Then
For c:=0 To RzList^.List^.Count-1 Do
 Begin
  s:=RzList^.GetText(c,RzList^.List^.Count);
  System.Delete(s,1,CRAzdel+1);{оставляем только код раздела и сумму}
  Writeln(ConfigFileNew,s);
 End;{For}
Writeln(ConfigFileNew,'[END_RAZDEL]');
Writeln(ConfigFileNew,'[CLIENT]');
{запоняем список клиентов}
If (ClList^.List^.Count)>0 Then
For c:=0 To ClList^.List^.Count-1 Do
 Begin
  s:=ClList^.GetText(c,ClList^.List^.Count);
  System.Delete(s,1,CClient+1);{оставляем только код клиента и сумму}
  Writeln(ConfigFileNew,s);
 End;{For}
Writeln(ConfigFileNew,'[END_CLIENT]');
Writeln(ConfigFileNew,'[END_AGENT] '+GetAgentField(FClient,Cod));

{закрываем new и переименовываем его в agent.cfg}
c:=IOResult;
Close(ConfigFileNew);
c:=IOResult;
Rename(ConfigFileNew,Path.ToProgram+'agent.cfg');
c:=IOResult;
WriteAgentPravila:=True;;
End;{Function}



Procedure TSetupAgentPlanWindow.SetupPlan (Cod:Integer);
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  i,c : Word;
  s,s1 : string[150];
  s2,s3 : AllStr;
  Count,Count1,c1 : Word;
  RazdelFile : File;
  ClF : File;
  ClE : PBufClientType;
  RazdelElement : PBufRAzdelType;
  VR,VC : PBox;
Begin
AInfo('Минуточку...');
s:=GetAgentField(FAgent,IntToStr(Cod,CClientKod));
DelSpaceRight(s);
s1:=IntToStr(Cod,CClientKod);
RFormatZerro(s1,CClientKod);

R.Assign(3, 0, 76, 23);
New(SetupWin, Init(R, 'Параметры расчета ЗП для агента '+s+' ('+s1+')'));
SetupWin^.Options := SetupWin^.Options or ofCenterX or ofCenterY;
SetupWin^.HelpCtx:=$E002;


R.Assign(3, 2, 69, 10);
Control := New(PColoredText, Init(R, #3+'  ', $70));
Control^.Options := Control^.Options or ofFramed;
SetupWin^.Insert(Control);

R.Assign(2, 12, 71, 21);
Control := New(PColoredText, Init(R, #3+'  ', $70));
Control^.Options := Control^.Options or ofFramed;
SetupWin^.Insert(Control);

SetupWin^.AgKod:=s1;


R.Assign(0, 0, 0, 0);
VR := New(PBox, Init(R, 1, Nil));
VR^.NewList(New(PTextCollection, Init(1,1)));
VC := New(PBox, Init(R, 1, Nil));
VC^.NewList(New(PTextCollection, Init(1,1)));

ReadAgentPravila(s1,VC,VR);


R.Assign(27, 2, 28, 10);
Control := New(PScrollBar, Init(R));
SetupWin^.Insert(Control);

R.Assign(3, 2, 27, 10);
AllRazdel := New(PBox, Init(R, 1, PScrollbar(Control)));
AllRazdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path^.Dat.Torazdel+'razdel.db');
Reset (RazdelFile,SizeOf(RazdelType));

While Not(Eof(RazdelFile)) Do
 Begin
Count1:=0;
New(RazdelElement,Init);
BlockRead(RazdelFile,RazdelElement^.Point,BufferRazdel,Count1);
For c1:=1 To Count1 Do
Begin
  If RazdelElement^.Point.Dat[c1].Employ Then
   Begin
    Format (RazdelElement^.Point.Dat[c1].Name,CClient);
    AllRazdel^.List^.Insert(NewStr(RazdelElement^.Point.Dat[c1].Name+'│'+RazdelElement^.Point.Dat[c1].Kod));
    AllRazdel^.SetRange(AllRazdel^.List^.Count);
   End;
End;{For}
Dispose(RAzdelElement,Done);
End;{While}
System.Close(RazdelFile);

AllRazdel^.FocusItem(0);
AllRazdel^.HelpCtx:=$F351;
SetupWin^.Insert(AllRazdel);

  R.Assign(3, 1, 12, 2);
  SetupWin^.Insert(New(PLabel, Init(R, 'Разделы:', AllRazdel)));


R.Assign(69, 2, 70, 10);
Control := New(PScrollBar, Init(R));
SetupWin^.Insert(Control);

R.Assign(29, 2, 69, 10);
SelectRazdel := New(PBox, Init(R, 1, PScrollbar(Control)));
SelectRazdel^.NewList(New(PTextCollection, Init(1,1)));

If VR^.List^.Count-1>=0 Then
For c:=0 To VR^.List^.Count-1 Do
 Begin
  s :=VR^.GetText(c,VR^.List^.Count);
  s1:=Copy(s,1,CRazdelKod);
  s2:=s1;
  s3:=Copy(s,1+CRazdelKod+1,CIZena);
  MyStr(StrToReal(s3),CIZena,CMAntissa,s3);
  s1:=GetRazdel(s1);
  Format(s1,CRazdel);
  s1:=s1+'│'+s2+'│'+s3;
  SelectRazdel^.List^.Insert(NewStr(s1));
  SelectRazdel^.SetRange(SelectRazdel^.List^.Count);
 End;

Dispose(VR,Done);
SelectRazdel^.HelpCtx:=$F356;
SelectRazdel^.FocusItem(0);
SetupWin^.Insert(SelectRazdel);

  R.Assign(29, 1, 48, 2);
  SetupWin^.Insert(New(PLabel, Init(R, 'Выбранные разделы:', SelectRazdel)));

R.Assign(28, 12, 29, 21);
Control := New(PScrollBar, Init(R));
SetupWin^.Insert(Control);

R.Assign(2, 12, 28, 21);
AllClient := New(PBox, Init(R, 1, PScrollbar(Control)));
AllClient^.NewList(New(PTextCollection, Init(1,1)));
Assign (ClF,Path^.Dat.ToClient+'Client.db');
i:=IOResult;
Reset (ClF,SizeOf(ClientType));
i:=IOResult;
If i=0 Then
Begin
While Not(Eof(ClF)) Do
 Begin
    New(CLE,Init);
    Count:=0;
    ReadBufClient(Clf,CLE,Count);
   For c:=1 To Count Do
   Begin
   If ClE^.Point.Dat[c].Employ Then
    Begin
     Format (ClE^.Point.Dat[c].Name,CClient);
     AllClient^.List^.Insert(NewStr(ClE^.Point.Dat[c].Name+'│'+ClE^.Point.Dat[c].Kod));
     AllClient^.SetRange(AllClient^.List^.Count);
    End;
   End;{For}
    Dispose(CLE,Done);
 End;
System.Close(ClF);
i:=IOResult;
End
Else
 Begin
  MessageBox(^M+#3'Ошибка доступа к базе клиентов!',nil,mfError+mfCanCelButton);
 End;
AllClient^.FocusItem(0);
AllClient^.HelpCtx:=$F351;
SetupWin^.Insert(AllClient);

  R.Assign(2, 11, 11, 12);
  SetupWin^.Insert(New(PLabel, Init(R, 'Клиенты:', AllClient)));


R.Assign(71, 12, 72, 21);
Control := New(PScrollBar, Init(R));
SetupWin^.Insert(Control);

R.Assign(29, 12, 71, 21);
SelectClient := New(PBox, Init(R, 1, PScrollbar(Control)));
SelectClient^.NewList(New(PTextCollection, Init(1,1)));
SelectClient^.HelpCtx:=$F356;

If VC^.List^.Count-1>=0 Then
For c:=0 To VC^.List^.Count-1 Do
 Begin
  s :=VC^.GetText(c,VC^.List^.Count);
  s1:=Copy(s,1,CClientKod);

  s2:=s1;
  s3:=Copy(s,1+CClientKod+1,CIZena);
  MyStr(StrToReal(s3),CIZena,CMAntissa,s3);
  s1:=GetClientField(FClient,s1,0);
  Format(s1,CClient);
  s1:=s1+'│'+s2+'│'+s3;
  SelectClient^.List^.Insert(NewStr(s1));
  SelectClient^.SetRange(SelectClient^.List^.Count);
 End;

Dispose(Vc,Done);
SelectClient^.FocusItem(0);
SetupWin^.Insert(SelectClient);

  R.Assign(29, 11, 48, 12);
  SetupWin^.Insert(New(PLabel, Init(R, 'Выбранные клиенты:', SelectClient)));


R.Assign(39, 10, 43, 11);
ControlRazdelCount := New(PColoredText, Init(R, #3+IntToStr(SelectRazdel^.List^.Count,CMantissa), $4E));
SetupWin^.Insert(ControlRazdelCount);

R.Assign(39, 21, 43, 22);
ControlClientCount := New(PColoredText, Init(R, #3+IntToStr(SelectClient^.List^.Count,CMAntissaZ), $4E));
SetupWin^.Insert(ControlClientCount);

R.Assign(30, 10, 39, 11);
Control := New(PColoredText, Init(R, ' Выбрано:', $74));
SetupWin^.Insert(Control);

R.Assign(30, 21, 39, 22);
Control := New(PColoredText, Init(R, ' Выбрано:', $74));
SetupWin^.Insert(Control);

R.Assign(57, 1, 63, 2);
Control := New(PColoredText, Init(R, ' План ', $74));
SetupWin^.Insert(Control);

R.Assign(60, 11, 66, 12);
Control := New(PColoredText, Init(R, ' План ', $74));
SetupWin^.Insert(Control);


R.Assign(54, 10, 69, 11);
ControlPlanRazdel := New(PColoredText, Init(R, #3+'0.00', $4E));
SetupWin^.Insert(ControlPlanRazdel);

R.Assign(56, 21, 71, 22);
ControlPlanClient := New(PColoredText, Init(R, #3+'0.00', $4E));
SetupWin^.Insert(ControlPlanClient);




SetupWin^.SelectNext(False);
NoInfo;

AddName;
CalcItogo(SelectRazdel,SelectClient);
c:=Desktop^.ExecView(SetupWin);
If c<>cmCancel Then
 Begin
  DInfoMsg('Сохраняю изменения...',True);
  WriteAgentPravila(SetupWin^.AgKod,SelectClient,SelectRazdel);
  NoInfoMsg;
 End;
Dispose(Control,Done);
Dispose(AllRazdel,Done);
Dispose(AllClient,Done);
Dispose(SelectClient,Done);
Dispose(SelectRazdel,Done);
Dispose(ControlRazdelCount,Done);
Dispose(ControlClientCount,Done);
Dispose(ControlPlanRazdel,Done);
Dispose(ControlPlanClient,Done);

Dispose(SetupWin,Done);
End;


procedure TSetupAgentPlanWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;


Label 3,4;
Var s,s1,fstr : string[150];
    Res : Word;
    Start2,Start1,Logik : Boolean;
    ls : Word;
Begin
  Case Event.What Of

  evCommand : Begin
               Case Event.Command Of
               cmLocalCalc:Calculator;
               cmReestrReport:Begin
                               FormReport(SelectRazdel,SelectClient);
                              End;
               Else;
               End;
              End;

  evKeyDown :
  Case Event.KeyCode Of
  kbCtrLDel: Begin
                ClearFind;

     If (SelectRazdel^.State and sfFocused <> 0) And (SelectRazdel^.List<>Nil)And(SelectRazdel^.List^.Count>=1) Then
            Begin
             SelectRazdel^.NewList(nil);
             SelectRazdel^.NewList(New(PTextCollection, Init(1,1)));
            End;

     If (SelectClient^.State and sfFocused <> 0) And (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>=1) Then
            Begin
             SelectClient^.NewList(nil);
             SelectClient^.NewList(New(PTextCollection, Init(1,1)));
            End;

             ClearEvent(Event);
             AddName;
             CalcItogo(SelectRazdel,SelectClient);
             Redraw;
            End;

     kbDel: Begin
                ClearFind;
     If (SelectRazdel^.State and sfFocused <> 0) And (SelectRazdel^.List<>Nil)And(SelectRazdel^.List^.Count>=1) Then
            Begin
             s:=SelectRazdel^.GetText(SelectRazdel^.Focused,SelectRazdel^.List^.Count);
             SelectRazdel^.List^.AtFree(SelectRazdel^.Focused);
             SelectRazdel^.SetRange(SelectRazdel^.List^.Count);

             If SelectRazdel^.Focused>0 Then
             SelectRazdel^.FocusItem(SelectRazdel^.Focused);

             If (SelectRazdel^.Focused>=SelectRazdel^.List^.Count) and(SelectRazdel^.Focused>0) Then
             SelectRazdel^.FocusItem(SelectRazdel^.Focused-1);

            End;

     If (SelectClient^.State and sfFocused <> 0) And (SelectClient^.List<>Nil)And(SelectClient^.List^.Count>=1) Then
            Begin
             s:=SelectClient^.GetText(SelectClient^.Focused,SelectClient^.List^.Count);
             SelectClient^.List^.AtFree(SelectClient^.Focused);
             SelectClient^.SetRange(SelectClient^.List^.Count);

             If SelectClient^.Focused>0 Then
             SelectClient^.FocusItem(SelectClient^.Focused);

             If (SelectClient^.Focused>=SelectClient^.List^.Count) and(SelectClient^.Focused>0) Then
             SelectClient^.FocusItem(SelectClient^.Focused-1);
            End;

              ClearEvent(Event);
              AddName;
              CalcItogo(SelectRazdel,SelectClient);
              Redraw;
            End;

      kbEnter: Begin
                ClearFind;
            If (AllRAzdel^.State and sfFocused <> 0) And (AllRAzdel^.List^.Count>=1) Then
            Begin
               s:=AllRAzdel^.GetText(AllRAzdel^.Focused,AllRAzdel^.List^.COunt);
               If TestElementR(Copy(s,1+CRazdel+1,CRazdelKod),SelectRazdel) Then
               Begin
                AddRazdelToList(0,s);
               End
               Else
                MessageBox(^M+#3+'Раздел уже добавлен в план!',Nil,mfError+mfCancelButton);

               If (AllRAzdel^.Focused+1) <  AllRAzdel^.List^.Count Then
               AllRAzdel^.FocusItem(AllRAzdel^.Focused+1);
            End;

            If(AllClient^.State and sfFocused <> 0) And (AllClient^.List^.Count>=1) Then
            Begin
               s:=AllClient^.GetText(AllClient^.Focused,AllClient^.List^.COunt);
               If TestElementC(Copy(s,1+CClient+1,CClientKod),SelectClient) Then
               Begin
                AddClientToList(0,s);
               End
               Else
                MessageBox(^M+#3+'Клиент уже добавлен в план!',Nil,mfError+mfCancelButton);
               If (AllClient^.Focused+1) <  AllClient^.List^.Count Then
               AllClient^.FocusItem(AllClient^.Focused+1);
            End;
              ClearEvent(Event);
              AddName;
              CalcItogo(SelectRazdel,SelectClient);
              Redraw;
            End;

      kbF4: Begin
            ClearFind;
            If(SelectRAzdel^.State and sfFocused <> 0) And (SelectRAzdel^.List^.Count>=1) Then
            Begin
               s:=SelectRAzdel^.GetText(SelectRAzdel^.Focused,SelectRAzdel^.List^.COunt);
               AddRazdelToList(1,s);
            End;

            If(SelectClient^.State and sfFocused <> 0) And (SelectClient^.List^.Count>=1) Then
            Begin
               s:=SelectClient^.GetText(SelectClient^.Focused,SelectClient^.List^.COunt);
               AddClientToList(1,s);
            End;
              ClearEvent(Event);
              AddName;
              CalcItogo(SelectRazdel,SelectClient);
              Redraw;
            End;

    Else;
    End;
    Else;
    End;



inherited HandleEvent(Event);


End;

Destructor TSetupAgentPlanWindow.Done;
Begin
TDialog.Done;
End;





Procedure TSetupAgentPlanWindow.AddName;
Var KolStr : ArtikulStr;
    R : TRect;
Begin

 Str(SelectRazdel^.List^.Count:2,KolStr);
 DelSpace(KolStr);
 Dispose(ControlRazdelCount,Done);
 {R.Assign(42, 10, 46, 11);}
 R.Assign(39, 10, 43, 11);

 ControlRazdelCount := New(PColoredText, Init(R, #3+KolStr, $4e));
 SetupWin^.Insert(ControlRazdelCount);

  Str(SelectClient^.List^.Count:4,KolStr);
  DelSpace(KolStr);
  Dispose(ControlClientCount,Done);
  {R.Assign(43, 21, 47, 22);}
  R.Assign(39, 21, 43, 22);
  ControlClientCount := New(PColoredText, Init(R, #3+KolStr, $4E));
  SetupWin^.Insert(ControlClientCount);

End;



Procedure TSetupAgentPlanWindow.CalcItogo(P1,P2:PBox);
VAr AllClient,AllRAzdel : AllStr;
    s : string[150];
    c : Word;
    R : TRect;
Begin
AllRAzdel[0]:=#0;
If P1^.List^.Count-1>=0 Then
 Begin
  For c:=0 To P1^.List^.Count Do
   Begin
    s:=P1^.GetText(c,P1^.List^.Count);
    s:=Copy(s,1+CRazdel+1+CRAzdelKod+1,CIZena);
    MyStr(StrToReal(s)+StrToReal(AllRAzdel),CIZena,CMantissa,AllRazdel);
   End;
 End;
MyStr(StrToReal(AllRAzdel),CIZena,CMantissa,AllRazdel);
DelSpace(AllRazdel);

Dispose(ControlPlanRazdel,Done);
R.Assign(54, 10, 69, 11);
ControlPlanRazdel := New(PColoredText, Init(R, #3+AllRazdel, $4E));
SetupWin^.Insert(ControlPlanRazdel);


AllClient[0]:=#0;
If P2^.List^.Count-1>=0 Then
 Begin
  For c:=0 To P2^.List^.Count Do
   Begin
    s:=P2^.GetText(c,P2^.List^.Count);
    s:=Copy(s,1+CClient+1+CClientKod+1,CIZena);
    MyStr(StrToReal(s)+StrToReal(AllClient),CIZena,CMantissa,AllClient);
   End;
 End;
MyStr(StrToReal(AllClient),CIZena,CMantissa,AllClient);
DelSpace(AllClient);



Dispose(ControlPlanClient,Done);
R.Assign(56, 21, 71, 22);
ControlPlanClient := New(PColoredText, Init(R, #3+AllClient, $4E));
SetupWin^.Insert(ControlPlanClient);



End;


Procedure TSetupAgentPlanWindow.FormReport(P1,P2:PBox);
Begin
{
SetupWin^.VR^.NewList(nil);
SetupWin^.VR^.NewList(New(PTextCollection, Init(1,1)));
}
End;



procedure TSetupAgentPlanWindow.AddRazdelToList(Cod:Word;s:String);
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  SZ : String[CIZena];
  SNAme : AllStr;
  c : Word;
begin
SNAme:=Copy(s,1+CRazdel+1,CRazdelKod);
SNAme:=GetRAzdel(sName);
If Cod=1 Then
 SZ:=Copy(s,1+CRazdel+1+CRazdelKod+1,CIZena)
Else
 SZ:='0.00';
DelSpace(SZ);

1:
R.Assign(25, 9, 54, 13);
New(Dlg, Init(R, 'Установка плана'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(9, 2, 26, 3);
Control := New(PInputLine, Init(R, CIZena));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(3, 2, 9, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'План:', Control)));

R.Assign(1, 1, 8, 2);
Control := New(PColoredText, Init(R, 'Раздел:', $74));
Dlg^.Insert(Control);

R.Assign(8, 1, 28, 2);
Control := New(PColoredText, Init(R, SNAme, $7E));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetData(SZ);
c:=Desktop^.ExecView(Dlg);
If c<>cmCAncel Then
 Begin
  Dlg^.GetDAta(SZ);
  If StrToReal(SZ)<0.009 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(^M+#3+'Нельзя установть нулевой план!',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  MyStr(StrToReal(SZ),CIZena,CMAntissa,SZ);
  If Cod=0 Then
   Begin
    s:=s+'│'+sz;
   End
   Else
    Begin
     System.Delete(s,1+CRazdel+1+CRazdelKod+1,CIZena);
     s:=s+sz;
     SelectRazdel^.List^.AtFree(SelectRazdel^.Focused);
    End;
   SelectRazdel^.List^.Insert(NewStr(s));
   SelectRazdel^.SetRange(SelectRazdel^.List^.Count);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
 End
 Else
 Begin
 Dispose(Control,Done);
 Dispose(Dlg,Done);
 End;
end;

procedure TSetupAgentPlanWindow.AddClientToList(Cod:Word;s:String);
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  SZ : String[CIZena];
  SNAme : AllStr;
  c : Word;
begin
SNAme:=Copy(s,1+CClient+1,CClientKod);
SNAme:=GetClientField(FClient,sName,0);
If Cod=1 Then
 SZ:=Copy(s,1+CClient+1+CClientKod+1,CIZena)
Else
 SZ:='0.00';
DelSpace(SZ);

1:
R.Assign(25, 9, 54, 13);
New(Dlg, Init(R, 'Установка плана'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;

R.Assign(9, 2, 26, 3);
Control := New(PInputLine, Init(R, CIZena));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(3, 2, 9, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'План:', Control)));

R.Assign(1, 1, 8, 2);
Control := New(PColoredText, Init(R, 'Клиент:', $74));
Dlg^.Insert(Control);

R.Assign(8, 1, 28, 2);
Control := New(PColoredText, Init(R, SNAme, $7E));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);
Dlg^.SetData(SZ);
c:=Desktop^.ExecView(Dlg);
If c<>cmCAncel Then
 Begin
  Dlg^.GetDAta(SZ);
  If StrToReal(SZ)<0.009 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(^M+#3+'Нельзя установть нулевой план!',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  MyStr(StrToReal(SZ),CIZena,CMAntissa,SZ);
  If Cod=0 Then
   Begin
    s:=s+'│'+sz;
   End
   Else
    Begin
     System.Delete(s,1+CClient+1+CClientKod+1,CIZena);
     s:=s+sz;
     SelectClient^.List^.AtFree(SelectClient^.Focused);
    End;
   SelectClient^.List^.Insert(NewStr(s));
   SelectClient^.SetRange(SelectClient^.List^.Count);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
 End
 Else
 Begin
 Dispose(Control,Done);
 Dispose(Dlg,Done);
 End;
end;


*)

End.