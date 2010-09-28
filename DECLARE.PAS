{Алгоритм предложенный для облегчения вывода безналичных долгов
 1: Вводится }


{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Declare;

INTERFACE

{

  Вызов - SelectClass;


  SelectImport из Utils4

 33:
  Begin
   R.Assign(1, 1, 33, 3);
   Control := New(PRadioButtons, Init(R,
   NewSItem('По разделам',
   NewSItem('По классам',
   Nil))));
}



procedure CalcLitrINN;
function SelectClass:boolean;

{$I Compile.INC}

IMPLEMENTATION



Uses Objects,App,Views,Validate,MsgBox, TPDate,Printers,Prise,
     Glob,ServStr,Serv,Dialogs,Drivers,
     NetDbEng,DBEngine, Tools, Utils,Utils5, ColorTxt,Utils3,Utils4;


const Space = ' ';
      CINNRegion = 4;

Type
  PClassSelectWindows = ^TClassSelectWindows;
  TClassSelectWindows = object(TDialog)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure AddName;
    Destructor Done; virtual;
  end;

Type
  PRazdelINNSelectWindows = ^TRazdelINNSelectWindows;
  TRazdelINNSelectWindows = object(TDialog)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure AddName;
    Destructor Done; virtual;
  end;




Var Class,ClassSelect : PBox;
    Razdel,RazdelSelect: PBox;
    ClassWinS : PClassSelectWindows;
    RazdelWinS: PRazdelINNSelectWindows;
    ControlAmount : PView;
    TempBox: PBox;
    AllEnable: longint;
    StartDate,StopDate : TDateString;
    OldFileMode : Word;
    Izmen,Direction ,Sorting : Word;
    bTula: boolean;
    FiltrDoc : MAska9;
    FiltrOtdel: MAska8;
    FiltrRash : MAska3;
    Auto : Word;
    Sertifword,Activ,Filtr,FiltrR : Word;
    RegimExt: Word;
    ActivMas:Maska2;
    M3:Maska3;
    sertif2:Maska2;
    c: word;


Function SelectVzw:Byte;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelectVzw:=1;

R.Assign(26, 9, 56, 13);

New(Dlg, Init(R, 'Назначение'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 29, 3);

  Control := New(PRadioButtons, Init(R,
  NewSItem('Без возвратов',
  NewSItem('С учетом возвратов', Nil))));

Dlg^.Insert(Control);

c:=1;

Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
  Begin
   Dlg^.GetData(c);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectVzw:=c;
  End
  Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectVzw:=2;
  End;
end;

Function SelectionRazdel:Boolean;
Var RazdelFile : File;
    RazdelElement : PBufRazdelType;
    c1,Count1 : Word;
var
  R : TRect;
  Control : PView;
begin
SelectionRazdel:=False;
ClearFind;
DInfoMsg('Минуточку...',False);

R.Assign(1, 0, 54, 23);
New(RazdelWinS, Init(R, 'Укажите разделы для расчета объема отгрузки'));
RazdelWinS^.Options := RazdelWinS^.Options or ofCenterX or ofCenterY;
RazdelWinS^.HelpCtx:=$E002;

R.Assign(25, 2, 26, 22);
Control := New(PScrollBar, Init(R));
RazdelWinS^.Insert(Control);

R.Assign(1, 2, 25, 22);
Razdel := New(PBox, Init(R, 1, PScrollbar(Control)));
Razdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path^.Dat.Torazdel+'razdel.db');
c1:=IoResult;
Reset (RazdelFile,SizeOf(RazdelType));
c1:=IoResult;
If c1=0 Then
Begin
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
    Razdel^.List^.Insert(NewStr(RazdelElement^.Point.Dat[c1].Name+'│'+RazdelElement^.Point.Dat[c1].Kod));
    Razdel^.SetRange(Razdel^.List^.Count);
   End;
End;{For}
Dispose(RAzdelElement,Done);
End;{While}
System.Close(RazdelFile);
End;

Razdel^.FocusItem(0);
Razdel^.HelpCtx:=$E044;
RazdelWinS^.Insert(Razdel);

  R.Assign(1, 1, 25, 2);
  RazdelWinS^.Insert(New(PLabel, Init(R, 'Ра~з~делы             Код', Razdel)));

R.Assign(51, 2, 52, 22);
Control := New(PScrollBar, Init(R));
RazdelWinS^.Insert(Control);

R.Assign(27, 2, 51, 22);
RazdelSelect := New(PBox, Init(R, 1, PScrollbar(Control)));
RazdelSelect^.NewList(New(PTextCollection, Init(1,1)));
RazdelSelect^.HelpCtx:=$E041;
RazdelWinS^.Insert(RazdelSelect);

  R.Assign(27, 1, 51, 2);

  RazdelWinS^.Insert(New(PLabel, Init(R, 'Выбранн~ы~е разделы   Код', RazdelSelect)));


R.Assign(17, 22, 35, 23);
Control := New(PColoredText, Init(R, ' Выбрано разделов:', $74));
RazdelWinS^.Insert(Control);

R.Assign(35, 22, 40, 23);
ControlAmount := New(PColoredText, Init(R, #3+'0', $4e));
RazdelWinS^.Insert(ControlAmount);

RazdelWinS^.SelectNext(False);
RazdelWinS^.AddName;
NoInfoMsg;
C := Desktop^.ExecView(RazdelWinS);

If C <> cmCancel Then
 Begin
  ClearFind;
  If RazdelSelect^.List^.Count=0 Then
   Begin
    Dispose(ControlAmount,Done);
    Dispose(RazdelSelect,Done);
    Dispose(RazdelWinS,Done);
    MessageBox(^M+#3'Не выбрано ни одного раздела !',Nil,mfError+mfCancelButton);
    Exit;
   End;
   SelectionRazdel:=True;
   CalcLitrInn;
   Dispose(Control,Done);
   Dispose(ControlAmount,Done);
   Dispose(Razdel,Done);
   Dispose(RazdelSelect,Done);
   Dispose(RazdelWinS,Done);
 End
 else
 Begin
   Dispose(Control,Done);
   Dispose(ControlAmount,Done);
   Dispose(Razdel,Done);
   Dispose(RazdelSelect,Done);
   Dispose(RazdelWinS,Done);
 End;

End;


Destructor TRazdelINNSelectWindows.Done;
Begin
TDialog.Done;
End;

procedure TRazdelINNSelectWindows.AddName;
Var R : TRect;
    KolStr : String[3];
Begin
  Str(RazdelSelect^.List^.Count:2,KolStr);
  Dispose(ControlAmount,Done);
  R.Assign(35, 22, 40, 23);
  ControlAmount := New(PColoredText, Init(R, #3+KolStr, $4e));
  RazdelWinS^.Insert(ControlAmount);
End;

procedure TRazdelINNSelectWindows.HandleEvent(var Event: TEvent);
Label 2,3;
Var s,s1,fstr : TMyString;
    Res : Word;
    Logik : Boolean;
    ls : Word;
Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
   kbEnter  :Begin
                ClearFind;
                inherited HandleEvent(Event);
                If (RazdelWinS^.Current=PView(Razdel)) Then
                   Begin
                    Event.What:=evCommand;
                    Event.Command:=CmOk;
                   End;
             End;

   kbGrayPlus,kbAltF1:Begin
                ClearFind;
          If ((RAzdel^.State and sfFocused <> 0)And(RAzdel^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...',True);
             For ls :=0 To RAzdel^.List^.Count-1 Do
              Begin
               s:=RAzdel^.GetText(ls,RAzdel^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CRAzdel);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               If TestElement(Copy(s,1+CRAzdel+1,CRazdelKod),RazdelSelect) Then
                Begin
                 RazdelSelect^.List^.Insert(NewStr(s));
                 RazdelSelect^.SetRange(RAzdelSelect^.List^.Count);
                End;{TestElement}
              End;{For}
              NoInfoMsg;
              ProdagaWindow:=False;
              If RAzdelSelect^.Focused+1<RAzdelSelect^.List^.Count Then
              RAzdelSelect^.FocusItem(RAzdelSelect^.List^.Count-1);
              RAzdelSelect^.FocusItem(0);
                End;{Maska}
              Redraw;
              AddName;
            End;{Nil}
              ClearEvent(Event);
              End;
   kbGrayMinus,kbAltF2:Begin
                ClearFind;
          If ((RAzdelSelect^.State and sfFocused <> 0)And(RAzdelSelect^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...',True);
             3:
             if (RAzdelSelect^.List^.Count>= 1) Then
             For ls :=0 To RAzdelSelect^.List^.Count-1 Do
              Begin
               s:=RAzdelSelect^.GetText(ls,RAzdelSelect^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CRAzdel);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               Begin
                RAzdelSelect^.List^.AtFree(Ls);
                RAzdelSelect^.SetRange(RAzdelSelect^.List^.Count);
                goto 3;
               End;
              End;{For}

             If RAzdelSelect^.Focused>0 Then
             RAzdelSelect^.FocusItem(RAzdelSelect^.Focused);

             If (RAzdelSelect^.Focused>=RAzdelSelect^.List^.Count) and(RAzdelSelect^.Focused>0) Then
             RAzdelSelect^.FocusItem(RAzdelSelect^.Focused-1);


              NoInfoMsg;
              ProdagaWindow:=False;
              RAzdelSelect^.FocusItem(0);
                End;{Maska}
             Redraw;
             AddName;
            End;{Nil}
              ClearEvent(Event);
              End;
   kbF1   : Begin
            ClearFind;
            If ((Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>= 1)) Then
            Begin
             RazdelSelect^.Focusitem(0);
             DInfoMsg('Минуточку...',True);
             For ls :=0 To Razdel^.List^.Count-1 Do
              Begin
               s:=Razdel^.GetText(ls,Razdel^.List^.Count);
               If GetRAzdelLitr(Copy(s,1+CRazdel+1,CRazdelKod))=1 Then
               if Testelement(Copy(s,1+CRazdel+1,CRazdelKod),RazdelSelect) then
                Begin
                 RazdelSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
                 If RazdelSelect^.Focused+1<RazdelSelect^.List^.Count Then
                 RazdelSelect^.FocusItem(RazdelSelect^.List^.Count-1);
              AddName;
             NoInfoMSg;
             End
            Else ClearEvent(Event);
            Redraw;
            End;

   kbF2   : Begin
            ClearFind;
            If ((Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>= 1)) Then
            Begin
             RazdelSelect^.Focusitem(0);
             DInfoMsg('Минуточку...',True);
             For ls :=0 To Razdel^.List^.Count-1 Do
              Begin
               s:=Razdel^.GetText(ls,Razdel^.List^.Count);
               If GetRAzdelStatus(Copy(s,1+CRazdel+1,CRazdelKod)) Then
               if Testelement(Copy(s,1+CRazdel+1,CRazdelKod),RazdelSelect) then
                Begin
                 RazdelSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
                 If RazdelSelect^.Focused+1<RazdelSelect^.List^.Count Then
                 RazdelSelect^.FocusItem(RazdelSelect^.List^.Count-1);
              AddName;
             NoInfoMSg;
             End
            Else ClearEvent(Event);
            Redraw;
            End;


   kbF3   : Begin
            ClearFind;
            If ((Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>= 1)) Then
            Begin
             RazdelSelect^.Focusitem(0);
             DInfoMsg('Минуточку...',True);
             For ls :=0 To Razdel^.List^.Count-1 Do
              Begin
               s:=Razdel^.GetText(ls,Razdel^.List^.Count);
               If GetRAzdelLitr(Copy(s,1+CRazdel+1,CRazdelKod))=0 Then
               if Testelement(Copy(s,1+CRazdel+1,CRazdelKod),RazdelSelect) then
                Begin
                 RazdelSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
                 If RazdelSelect^.Focused+1<RazdelSelect^.List^.Count Then
                 RazdelSelect^.FocusItem(RazdelSelect^.List^.Count-1);
              AddName;
             NoInfoMSg;
             End
            Else ClearEvent(Event);
            Redraw;
            End;


   kbCtrlIns: Begin
                ClearFind;
            If ((Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>= 1)) Then
            Begin
             RazdelSelect^.Focusitem(0);
             For ls :=0 To Razdel^.List^.Count-1 Do
              Begin
               s:=Razdel^.GetText(ls,Razdel^.List^.Count);
               if Testelement(Copy(s,1+CRazdel+1,CRazdelKod),RazdelSelect) then
                Begin
                 RazdelSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
                 If Razdel^.Focused+1<Razdel^.List^.Count Then Razdel^.FocusItem(Razdel^.Focused+1);
                 If RazdelSelect^.Focused+1<RazdelSelect^.List^.Count Then
                 RazdelSelect^.FocusItem(RazdelSelect^.List^.Count-1);
              AddName;
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
             AddName;
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
              AddName;
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
              AddName;
              Redraw;
            End;
    Else;
    End;
    Else;
    End;
  inherited HandleEvent(Event);
End;



Destructor TClassSelectWindows.Done;
Begin
TDialog.Done;
End;

procedure TClassSelectWindows.AddName;
Var R : TRect;
    KolStr : String[3];
Begin
  Str(ClassSelect^.List^.Count:2,KolStr);
  Dispose(ControlAmount,Done);
  R.Assign(35, 22, 40, 23);
  ControlAmount := New(PColoredText, Init(R, #3+KolStr, $4e));
  ClassWinS^.Insert(ControlAmount);
End;

procedure TClassSelectWindows.HandleEvent(var Event: TEvent);
Label 2,3;
Var s,s1,fstr : TMyString;
    Res : Word;
    Logik : Boolean;
    ls : Word;
Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
   kbEnter  :Begin
                ClearFind;
                inherited HandleEvent(Event);
                If (ClassWinS^.Current=PView(Razdel)) Then
                   Begin
                    Event.What:=evCommand;
                    Event.Command:=CmOk;
                   End;
             End;
      kbGrayPlus,kbAltF1:Begin
                ClearFind;
          If ((Class^.State and sfFocused <> 0)And(Class^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...',True);
             For ls :=0 To Class^.List^.Count-1 Do
              Begin
               s:=Class^.GetText(ls,Class^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CRAzdel);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               If TestElement(Copy(s,1+CSertif+1,CClientKod),ClassSelect) Then
                Begin
                 ClassSelect^.List^.Insert(NewStr(s));
                 ClassSelect^.SetRange(ClassSelect^.List^.Count);
                End;{TestElement}
              End;{For}
              NoInfoMsg;
              ProdagaWindow:=False;
              If ClassSelect^.Focused+1<ClassSelect^.List^.Count Then
              ClassSelect^.FocusItem(ClassSelect^.List^.Count-1);
              ClassSelect^.FocusItem(0);
                End;{Maska}
              Redraw;
              {AddName;}
            End;{Nil}
              ClearEvent(Event);
              End;

      kbGrayMinus,kbAltF2:Begin
                ClearFind;
          If ((ClassSelect^.State and sfFocused <> 0)And(ClassSelect^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...',True);
             3:
             if (ClassSelect^.List^.Count>= 1) Then
             For ls :=0 To ClassSelect^.List^.Count-1 Do
              Begin
               s:=ClassSelect^.GetText(ls,ClassSelect^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CSertif);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               Begin
                ClassSelect^.List^.AtFree(Ls);
                ClassSelect^.SetRange(ClassSelect^.List^.Count);
                goto 3;
               End;
              End;{For}

             If ClassSelect^.Focused>0 Then
             ClassSelect^.FocusItem(ClassSelect^.Focused);

             If (ClassSelect^.Focused>=ClassSelect^.List^.Count) and(ClassSelect^.Focused>0) Then
             ClassSelect^.FocusItem(ClassSelect^.Focused-1);


              NoInfoMsg;
              ProdagaWindow:=False;
              ClassSelect^.FocusItem(0);
                End;{Maska}
             Redraw;
             {AddName;}
            End;{Nil}
              ClearEvent(Event);
              End;


   kbCtrlIns: Begin
                ClearFind;
            If ((Class^.State and sfFocused <> 0)And(Class^.List^.Count>= 1)) Then
            Begin
             ClassSelect^.Focusitem(0);
             For ls :=0 To Class^.List^.Count-1 Do
              Begin
               s:=Class^.GetText(ls,Class^.List^.Count);
               if Testelement1(Copy(s,1+CSertif+1,CClientKod),ClassSelect) then
                Begin
                 ClassSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 ClassSelect^.SetRange(ClassSelect^.List^.Count);
                 If Class^.Focused+1<Class^.List^.Count Then Class^.FocusItem(Class^.Focused+1);
                 If ClassSelect^.Focused+1<ClassSelect^.List^.Count Then
                 ClassSelect^.FocusItem(ClassSelect^.List^.Count-1);
              {AddName;}
             End
            Else ClearEvent(Event);
            Redraw;
            End;

  kbCtrLDel: Begin
                ClearFind;
     If (ClassSelect^.State and sfFocused <> 0) And (ClassSelect^.List<>Nil)And(ClassSelect^.List^.Count>=1) Then
            Begin
             ClassSelect^.NewList(nil);
             ClassSelect^.NewList(New(PTextCollection, Init(1,25)));
            End;
            ClearEvent(Event);
            { AddName;}
             Redraw;
            End;
     kbDel: Begin
                ClearFind;
     If (ClassSelect^.State and sfFocused <> 0) And (ClassSelect^.List<>Nil)And(ClassSelect^.List^.Count>=1) Then
            Begin
             ClassSelect^.List^.AtFree(ClassSelect^.Focused);
             ClassSelect^.SetRange(ClassSelect^.List^.Count);
             If ClassSelect^.Focused>0 Then
             ClassSelect^.FocusItem(ClassSelect^.Focused);

             If (ClassSelect^.Focused>=ClassSelect^.List^.Count) and(ClassSelect^.Focused>0) Then
             ClassSelect^.FocusItem(ClassSelect^.Focused-1);

            End;
              ClearEvent(Event);
              {AddName;}
              Redraw;
            End;
      kbIns: Begin
                ClearFind;
            If(Class^.State and sfFocused <> 0) And (Class^.List^.Count>=1) Then
            Begin
               s:=Class^.GetText(Class^.Focused,Class^.List^.COunt);
               If TestElement1(Copy(s,1+CSertif+1,CClientKod),ClassSelect) Then
               Begin
               ClassSelect^.List^.Insert(NewStr(s));
               ClassSelect^.SetRange(ClassSelect^.List^.Count);
               s:=Copy(s,1+CSertif+1,CClientKod);
               ClassSelect^.FocusItem(LoCation(ClassSelect,S,ProdagaWindow));
             If ClassSelect^.Focused+1<ClassSelect^.List^.Count Then
             ClassSelect^.FocusItem(ClassSelect^.List^.Count-1);
               End;
               If (Class^.Focused+1) <  Class^.List^.Count Then
               Class^.FocusItem(Class^.Focused+1);
              End;
              ClearEvent(Event);
              {AddName;}
              Redraw;
            End;
    Else;
    End;
    Else;
    End;
  inherited HandleEvent(Event);
End;


function SelectClass:boolean;
var R: TRect;
    Control: PView;
    c, c1, Count1: word;
    ClassFile : File;
    ClassElement : PBufClassificatorBuchType;
Begin
SelectClass:=False;
bTula:=false;
c:=SelectImport(33);
if c=2 then exit;
if c=0 then
begin
  bTula:=true;
  SelectionRazdel;
  SelectClass:=true;
  Exit;
end;

SelectClass:=False;
ClearFind;
DInfoMsg('Минуточку...',False);
R.Assign(1, 0, 79, 23);
New(ClassWinS, Init(R, 'Выбор классов продукции'));

ClassWinS^.Options := ClassWinS^.Options or ofCenterX or ofCenterY;
ClassWinS^.HelpCtx:=$E002;

R.Assign(76, 13, 77, 22);
Control := New(PScrollBar, Init(R));
ClassWinS^.Insert(Control);


R.Assign(1, 13, 76, 22);
ClassSelect := New(PBox, Init(R, 1, PScrollbar(Control)));
ClassSelect^.NewList(New(PTextCollection, Init(1,1)));
ClassSelect^.HelpCtx:=$E041;

ClassSelect^.FocusItem(1);
ClassSelect^.HelpCtx:=$E044;
ClassWinS^.Insert(ClassSelect);

  R.Assign(2, 12, 70, 13);

  ClassWinS^.Insert(New(PLabel, Init(R, 'Выбранн~ы~е классы                                               Код', ClassSelect)));



R.Assign(76, 2, 77, 12);
Control := New(PScrollBar, Init(R));
ClassWinS^.Insert(Control);

R.Assign(1, 2, 76, 12);
Class := New(PBox, Init(R, 1, PScrollbar(Control)));
Class^.NewList(New(PTextCollection, Init(1,1)));
Assign (ClassFile,Path^.Dat.ToSpr+'class.db');
c1:=IoResult;
Reset (ClassFile,SizeOf(ClassificatorBuchType));
c1:=IoResult;
If c1=0 Then
Begin
While Not(Eof(ClassFile)) Do
 Begin
Count1:=0;
New(ClassElement,Init);
BlockRead(ClassFile,ClassElement^.Point,BufferClass,Count1);
For c1:=1 To Count1 Do
Begin
  If ClassElement^.Point.Dat[c1].Employ Then
   Begin
    Format (ClassElement^.Point.Dat[c1].Name,CSertif);
    Class^.List^.Insert(NewStr(ClassElement^.Point.Dat[c1].Name+'│'+ClassElement^.Point.Dat[c1].Kod));
    Class^.SetRange(Class^.List^.Count);
   End;
End;{For}
Dispose(ClassElement,Done);
End;{While}
System.Close(ClassFile);
End;

Class^.FocusItem(0);
Class^.HelpCtx:=$E044;
ClassWinS^.Insert(Class);

  R.Assign(2, 1, 76, 2);
  ClassWinS^.Insert(New(PLabel, Init(R, ' Классы                                                          Код', Class)));




NoInfoMsg;
C := Desktop^.ExecView(ClassWinS);
If C <> cmCancel Then
 Begin
  ClearFind;
  If ClassSelect^.List^.Count=0 Then
   Begin
    Dispose(Class,Done);
    Dispose(ClassSelect,Done);
    Dispose(ClassWinS,Done);
    MessageBox(^M+#3'Не выбрано ни одного класса !',Nil,mfError+mfCancelButton);
    Exit;
   End;

   CalcLitrINN;
   SelectClass:=true;
   Dispose(Control,Done);
   Dispose(Class,Done);
   Dispose(ClassSelect,Done);
   Dispose(ClassWinS,Done);
 end
 else
 begin
   Dispose(Control,Done);
   Dispose(Class,Done);
   Dispose(ClassSelect,Done);
   Dispose(ClassWinS,Done);
 end;

End;

Function Setup:Boolean;

Type MyType=Record
    Docs : Word;
    Operation : Word;
    Otdel: Word;
  end;

var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  VVV : MyType;
  c : Word;
  Change : Boolean;

begin
Setup:=FAlse;


With VVV Do
 Begin

Convert9(FiltrDoc);
BitToWord9(FiltrDoc,c);
Docs:=c;

Convert8(FiltrOtdel);
BitToWord8(FiltrOtdel,c);
Otdel:=c;

Convert3(M3);
BitToWord3(M3,Filtr);
Operation:=Filtr;
End;


R.Assign(10, 9, 63, 18);
New(Dlg, Init(R, 'Параметры включаемых в отчет документов'));
Dlg^.Options := Dlg^.Options or ofCenterX;
Dlg^.HelpCtx:=$E002;

R.Assign(1, 2, 34, 5);
Control := New(PCheckboxes, Init(R,
  NewSItem('Списо~к~',
  NewSItem('Тов.ч~е~к',
  NewSItem('Фи~з~.лиц',
  NewSItem('С~Ф~',
  NewSItem('СФБ',
  NewSItem('Д*',
  NewSItem('ДСФ',
  NewSItem('Д',
  NewSItem('~Д~СФБ', Nil)))))))))));
Dlg^.Insert(Control);

  R.Assign(1, 1, 16, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид документа:', Control)));

R.Assign(35, 2, 50, 5);
Control := New(PCheckboxes, Init(R,
  NewSItem('К~л~иент',
  NewSItem('~С~клад',
  NewSItem('~О~бмен', Nil)))));
Dlg^.Insert(Control);

  R.Assign(35, 1, 49, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид опреаций:', Control)));


R.Assign(1, 6, 29, 8);
Control := New(PCheckboxes, Init(R,
  NewSItem('~1~',
  NewSItem('~2~',
  NewSItem('~3~',
  NewSItem('~4~',
  NewSItem('~5~',
  NewSItem('~6~',
  NewSItem('~7~',
  NewSItem('~8~', Nil))))))))));
Dlg^.Insert(Control);

  R.Assign(1, 5, 12, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Отделения:', Control)));


Dlg^.SelectNext(False);

Dlg^.SetData(VVV);

c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
Begin
 Setup:=True;
 Dlg^.GetData(VVV);

With VVV Do
 Begin
WordToBit9(Docs,FiltrDoc);
WordToBit8(Otdel,FiltrOtdel);
WordToBit3(Operation,M3);
 End;

End;
Convert9(FiltrDoc);
Convert3(M3);
Convert8(FiltrOtdel);
Dispose(Control,Done);
Dispose(Dlg,Done);
end;




procedure MrkAddToList(E: SuperMarkettype);
var i,j : word;
    find: boolean;
    SumLitr:String[CIZena];
    SumZena:String[CIZena];
    sZena: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    s: string;
Begin

find:=false;

For i:=1 to E.Amount do
begin
  sClass:=GetIdField(FClass,E.MarketElement[i].BazKod);
  sRazd:=Copy(E.MarketElement[i].BazKod,1,CRazdelKod);

  if FiltrOtdel[E.MarketElement[i].Input.DiviSionNumber]<>1 then Continue;


if (not bTula) and (not TestElement1(sClass,ClassSelect)) then
Begin
find:=false;
If TempBox^.List^.Count>0 Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
        s:=TempBox^.GetText(j,TempBox^.List^.Count);
        if (StrToInt(e.ClientKod)=StrToInT(copy(s,1,CClientKod))) then
        begin
         SumLitr:='0.00';
         SumZena:='0.00';
         SZena:='0.00';
         MyStr(StrToReal(copy(s,1+CClientKod,CIZena))+StrToReal(GetIdField(FLitr,E.MarketElement[i].BazKod))
             *StrToReal(E.MarketElement[i].Input.Kol)/10,CIZena,CMantissaZ,SumLitr);

         if E.SkidkaSelector=0 Then{Если автомат}
         begin
           DelSpace(E.MarketElement[i].Input.Proz);
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)/
           (1+StrToReal(E.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,sZena);
         end
         else
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)-StrToReal(E.MarketElement[i].Input.Skidka))
          ,CZena,CMantissa,sZena);
         MyStr(StrToReal(copy(s,1+CClientKod+CIZena,CIZena))+StrToReal(sZena)
           *StrToReal(E.MarketElement[i].Input.Kol),CIZena,CMantissa,SumZena);

         rFormat(SumZena,CIZena);
         System.Delete(s,1+CClientKOd+CIZena,CIZena);
         System.Insert(SumZena,s,1+CClientKOd+CIZena);

         System.Delete(s,1+CClientKOd,CIZena);
         System.Insert(SumLitr,s,1+CClientKOd);

         TempBox^.List^.AtFree(j);
         TempBox^.SetRange(TempBox^.List^.Count);

         TempBox^.List^.Insert(NewStr(s));
         TempBox^.SetRange(TempBox^.List^.Count);

         find:=true;
         break;
        end; {if (StrToInt(e.ClientKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end;  {If TempBox^.List^.Count>0}

   if not Find then
   begin
    MyStr(StrToReal(GetIdField(FLitr,E.MarketElement[i].BazKod))
     *StrToReal(E.MarketElement[i].Input.Kol)/10,CIZena,CMantissaZ,SumLitr);
    format(SumLitr,CIZeNa);
    if E.SkidkaSelector=0 Then{Если автомат}
         begin
           DelSpace(E.MarketElement[i].Input.Proz);
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)/
           (1+StrToReal(E.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,sZena);
         end
         else
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)-StrToReal(E.MarketElement[i].Input.Skidka))
          ,CZena,CMantissa,sZena);

    MyStr(sTRtOrEAL(sZena)*StrToReal(E.MarketElement[i].Input.Kol),CZena,CMantissa,sZena);
    rFormat(SZena,CIZena);

    s:=E.ClientKod+SumLitr+SZena;

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

 end;{if not TestElement1(sClass,ClassSelect)}

 if bTula AND (not TestElement(sRazd,RazdelSelect)) then
Begin
find:=false;
If TempBox^.List^.Count>0 Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
        s:=TempBox^.GetText(j,TempBox^.List^.Count);
        ;
        if (StrToInt(e.ClientKod)=StrToInT(copy(s,1,CClientKod))) then
        begin
         SumLitr:='0.00';
         SumZena:='0.0';
         sZena:='0.0';
         MyStr(StrToReal(copy(s,1+CClientKod,CIZena))+StrToReal(GetIdField(FLitr,E.MarketElement[i].BazKod))
             *StrToReal(E.MarketElement[i].Input.Kol)/10,CIZena,CMantissaZ,SumLitr);

         if E.SkidkaSelector=0 Then{Если автомат}
         begin
           DelSpace(E.MarketElement[i].Input.Proz);
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)/
           (1+StrToReal(E.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,sZena);
         end
         else
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)-StrToReal(E.MarketElement[i].Input.Skidka))
          ,CZena,CMantissa,sZena);

         MyStr(StrToReal(copy(s,1+CClientKod+CIZena,CIZena))+StrToReal(sZena)*
           StrToReal(E.MarketElement[i].Input.Kol),CIZena,CMantissa,SumZena);

         rFormat(SumZena,CIZena);

         System.Delete(s,1+CClientKOd+CIZena,CIZena);
         System.Insert(SumZena,s,1+CClientKOd+CIZena);

         System.Delete(s,1+CClientKOd,CIZena);
         System.Insert(SumLitr,s,1+CClientKOd);

         TempBox^.List^.AtFree(j);
         TempBox^.SetRange(TempBox^.List^.Count);

         TempBox^.List^.Insert(NewStr(s));
         TempBox^.SetRange(TempBox^.List^.Count);

         find:=true;
         break;
        end; {if (StrToInt(e.ClientKod)}
      end; {for j:=0 to TulaBox^.List^.Count-1}
   end;  {If TulaBox^.List^.Count>0}

   if not Find then
   begin
    MyStr(StrToReal(GetIdField(FLitr,E.MarketElement[i].BazKod))
     *StrToReal(E.MarketElement[i].Input.Kol)/10,CIZena,CMantissaZ,SumLitr);
    format(SumLitr,CIZeNa);
    if E.SkidkaSelector=0 Then{Если автомат}
         begin
           DelSpace(E.MarketElement[i].Input.Proz);
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)/
           (1+StrToReal(E.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,sZena);
         end
         else
           MyStr((StrToReal(E.MarketElement[i].Input.Zena)-StrToReal(E.MarketElement[i].Input.Skidka))
          ,CZena,CMantissa,sZena);

         MyStr(sTRtOrEAL(sZena)*StrToReal(E.MarketElement[i].Input.Kol),CZena,CMantissa,sZena);

    rFormat(SZena,CIZena);
    s:=E.ClientKod+SumLitr+sZena;

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

 end;{if sRazd='00'}
end;
End;

procedure VzwAddToList(E: NewVozwratType);
var i,j : word;
    find: boolean;
    SumLitr:String[CIZena];
    SumZena:String[CIZena];
    sZena: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    s: string;
Begin

find:=false;

For i:=1 to E.Amount do
begin
  sClass:=GetIdField(FClass,E.VozwratElement[i].BazKod);
  sRazd:=Copy(E.VozwratElement[i].BazKod,1,CRazdelKod);

 { if FiltrOtdel[E.VozwratElement[i].Input.DiviSionNumber]<>1 then Continue;}


if (not bTula) and (not TestElement1(sClass,ClassSelect)) then
Begin
find:=false;
If TempBox^.List^.Count>0 Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
        s:=TempBox^.GetText(j,TempBox^.List^.Count);
        if (StrToInt(e.MakeKod)=StrToInT(copy(s,1,CClientKod))) then
        begin
         SumLitr:='0.00';
         SumZena:='0.00';
         SZena:='0.00';
         MyStr(StrToReal(copy(s,1+CClientKod,CIZena))-StrToReal(GetIdField(FLitr,E.VozwratElement[i].BazKod))
             *StrToReal(E.VozwratElement[i].Input.Kol)/10,CIZena,CMantissaZ,SumLitr);


           MyStr((StrToReal(E.VozwratElement[i].Input.Zena)-StrToReal(E.VozwratElement[i].Input.LocalSkidka))
          ,CZena,CMantissa,sZena);
         MyStr(StrToReal(copy(s,1+CClientKod+CIZena,CIZena))+StrToReal(sZena)
           *StrToReal(E.VozwratElement[i].Input.Kol),CIZena,CMantissa,SumZena);

         rFormat(SumZena,CIZena);
         System.Delete(s,1+CClientKOd+CIZena,CIZena);
         System.Insert(SumZena,s,1+CClientKOd+CIZena);

         System.Delete(s,1+CClientKOd,CIZena);
         System.Insert(SumLitr,s,1+CClientKOd);

         TempBox^.List^.AtFree(j);
         TempBox^.SetRange(TempBox^.List^.Count);

         TempBox^.List^.Insert(NewStr(s));
         TempBox^.SetRange(TempBox^.List^.Count);

         find:=true;
         break;
        end; {if (StrToInt(e.ClientKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end;  {If TempBox^.List^.Count>0}

   if not Find then
   begin
    MyStr(StrToReal(GetIdField(FLitr,E.VozwratElement[i].BazKod))
     *StrToReal(E.VozwratElement[i].Input.Kol)/10,CIZena,CMantissaZ,SumLitr);
    format(SumLitr,CIZeNa);
           MyStr((StrToReal(E.VozwratElement[i].Input.Zena)-StrToReal(E.VozwratElement[i].Input.LocalSkidka))
          ,CZena,CMantissa,sZena);

    MyStr(-sTRtOrEAL(sZena)*StrToReal(E.VozwratElement[i].Input.Kol),CZena,CMantissa,sZena);
    rFormat(SZena,CIZena);

    s:=E.MakeKod+SumLitr+SZena;

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

 end;{if not TestElement1(sClass,ClassSelect)}

 if bTula AND (not TestElement(sRazd,RazdelSelect)) then
Begin
find:=false;
If TempBox^.List^.Count>0 Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
        s:=TempBox^.GetText(j,TempBox^.List^.Count);
        ;
        if (StrToInt(e.MakeKod)=StrToInT(copy(s,1,CClientKod))) then
        begin
         SumLitr:='0.00';
         SumZena:='0.0';
         sZena:='0.0';
         MyStr(StrToReal(copy(s,1+CClientKod,CIZena))+StrToReal(GetIdField(FLitr,E.VozwratElement[i].BazKod))
             *StrToReal(E.VozwratElement[i].Input.Kol)/10,CIZena,CMantissaZ,SumLitr);

           MyStr((StrToReal(E.VozwratElement[i].Input.Zena)-StrToReal(E.VozwratElement[i].Input.LocalSkidka))
          ,CZena,CMantissa,sZena);

         MyStr(StrToReal(copy(s,1+CClientKod+CIZena,CIZena))-StrToReal(sZena)*
           StrToReal(E.VozwratElement[i].Input.Kol),CIZena,CMantissa,SumZena);

         rFormat(SumZena,CIZena);

         System.Delete(s,1+CClientKOd+CIZena,CIZena);
         System.Insert(SumZena,s,1+CClientKOd+CIZena);

         System.Delete(s,1+CClientKOd,CIZena);
         System.Insert(SumLitr,s,1+CClientKOd);

         TempBox^.List^.AtFree(j);
         TempBox^.SetRange(TempBox^.List^.Count);

         TempBox^.List^.Insert(NewStr(s));
         TempBox^.SetRange(TempBox^.List^.Count);

         find:=true;
         break;
        end; {if (StrToInt(e.ClientKod)}
      end; {for j:=0 to TulaBox^.List^.Count-1}
   end;  {If TulaBox^.List^.Count>0}

   if not Find then
   begin
    MyStr(StrToReal(GetIdField(FLitr,E.VozwratElement[i].BazKod))
     *StrToReal(E.VozwratElement[i].Input.Kol)/10,CIZena,CMantissaZ,SumLitr);
    format(SumLitr,CIZeNa);
           MyStr((StrToReal(E.VozwratElement[i].Input.Zena)-StrToReal(E.VozwratElement[i].Input.LocalSkidka))
          ,CZena,CMantissa,sZena);

         MyStr(-sTRtOrEAL(sZena)*StrToReal(E.VozwratElement[i].Input.Kol),CZena,CMantissa,sZena);

    rFormat(SZena,CIZena);
    s:=E.MakeKod+SumLitr+sZena;

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

 end;{if sRazd='00'}
end;
End;


procedure CalcLitrINN;
var AllSkl: Maska30;
    t: text;
    IORez,cc, Count,i: word;
    Den, Start, Stop: longint;
    Errors: PBox;
    tekSkl: word;
    Date: TDateString;
    fm:File;
    m: PBufSuperMarketType;
    R: Trect;
    fv: file of NewVozwratType;
    v: PNewVozwratType;
    s: string;
    sClKod: string[CClientKod];
    SortBox: PBox;
    INN : String[CName];
    AdressF : String[CAll];
    FullName : String[CAll];
    SumLitr, SumLitrRegion: string[CIZena];
    SumZena, SumZenaRegion: string[CIZena];
    OldRegion, NewRegion: string[CINNRegion];
    sn: string[CClientKod];
    bVzw: boolean;
Begin
 FiltrDoc[1]:=0;
 FiltrDoc[2]:=0;
 FiltrDoc[3]:=0;
 FiltrDoc[4]:=1;
 FiltrDoc[5]:=1;
 FiltrDoc[6]:=0;
 FiltrDoc[7]:=1;
 FiltrDoc[8]:=0;
 FiltrDoc[9]:=1;

 For i:=1 To CDivision Do
 Begin
  FiltrOtdel[i]:=1;
 End;

 M3[1]:=1;
 M3[2]:=0;
 M3[3]:=1;

 {Учитывать возвраты}
 bVzw:=true;
 i:=SelectVzw;
 if i=2 then exit;
 if i=0 then bVzw:=false;

 {Выбор периода}
 If Not DatePeriodDialog(StartDate,StopDate,False) Then Exit;
 Start:=DateStringToDate(DateMask,StartDate);
 Stop:=DateStringToDate(DateMask,StopDate);

 {Выбор складов}
 AllEnable:=AllSKlads;
 If Not SelAssortiment(AllEnable) Then Exit;
 WordToBit30(AllEnable,AllSkl);
 Convert30(AllSkl);
 {Тип док-та}
 if not Setup Then Exit;

 R.Assign(0, 0, 0, 0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));


{Выбор данных}
  {по складам}
  for TekSkl:=1 to CMaxSklads do
  begin
   if AllSkl[TekSkl]=1 then
   {по датам}
   for Den:=Start to stop do
   begin
     Date:=DateToDateString(DateMask,DEn);
     DelSpace(PathSklads^.Dat.Path[TekSkl]);
     DInfoMsgShkala('Просматриваю продажи склада '+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)+'...',Start,Stop,Den);
     if PathSklads^.Dat.Path[TekSkl]<>'' then
     begin
      Assign(FM,PathSklads^.Dat.Path[TekSkl]+'MARKET\'+Date+'.mrk');
      OldFileMode:=FileMode;
      FileMode:=ReadOnlyN;
      IORez:=IOResult;
      Reset(fm,SizeOf(SuperMarketType));
      IORez:=IOResult;
      FileMode:=OldFileMode;
      If IORez <> 0 Then
      Begin
       {MessageBox(#3^M+#3'Не могу ... файл '+PathSklads^.Dat.Path[TekSkl]+Date+'.mrk',Nil,mfError+mfCancelButton);}
       NoInfoMsg;
       continue;
      End;

       While Not(Eof(fm)) Do
       Begin
       cc:=0;
       New(m,Init);
       ReadBufMarket(fm,m,Count);
       For cc:=1 To Count Do
        Begin
         If m^.Point.Dat[cc].Active Then
         If M3[m^.Point.Dat[cc].OperatorSelector+1]=1 Then
         If FiltrDoc[m^.Point.Dat[cc].DocSelector+1]=1 Then
         If ((m^.Point.Dat[cc].Realiz) And (m^.Point.Dat[cc].DocSelector in [5,6,7,8])) or Not(m^.Point.Dat[cc].Realiz) Then

         BEGIN
            MrkAddToList(m^.Point.Dat[cc]);
         END; {If m^.Point.Dat[cc].Active}
        End; {For cc:=1 To}
        Dispose(m,Done);
       End;{While Not(Eof(ef)) Do}
     IORez:=ioresult;
     close(fm);
     IORez:=ioresult;
     end;{if PathSklads^.Dat.Path[TekSkl]<>''}
   end;{по датам}
     NoInfoMsg;
  end;{по складам}

{Просмотр возвратов}
if bVzw then
  for TekSkl:=1 to CMaxSklads do
  begin
   if AllSkl[TekSkl]=1 then
   {по датам}
   for Den:=Start to stop do
   begin
     Date:=DateToDateString(DateMask,DEn);
     DelSpace(PathSklads^.Dat.Path[TekSkl]);
   DInfoMsgShkala('Просматриваю возвраты склада '+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)+'...',Start,Stop,Den);
     if PathSklads^.Dat.Path[TekSkl]<>'' then
     begin
      Assign(FV,PathSklads^.Dat.Path[TekSkl]+'RETURN\'+Date+'.vzw');
      OldFileMode:=FileMode;
      FileMode:=ReadOnlyN;
      IORez:=IOResult;
      Reset(fv);
      IORez:=IOResult;
      FileMode:=OldFileMode;
      If IORez <> 0 Then
      Begin
       {MessageBox(#3^M+#3'Не могу ... файл '+PathSklads^.Dat.Path[TekSkl]+Date+'.mrk',Nil,mfError+mfCancelButton);}
       NoInfoMsg;
       continue;
      End;

       While Not(Eof(fv)) Do
       Begin
       cc:=0;
       New(v,Init);
       Read(fv,v^.Dat);

         If M3[v^.Dat.OperatorSelector+1]=1 Then
         If FiltrDoc[v^.Dat.DocSelector+1]=1 Then
         BEGIN
            VzwAddToList(v^.Dat);
         END; {If m^.Point.Dat[cc].Active}

        Dispose(v,Done);
       End;{While Not(Eof(ef)) Do}
     IORez:=ioresult;
     close(fv);
     IORez:=ioresult;
     end;{if PathSklads^.Dat.Path[TekSkl]<>''}
   end;{по датам}
     NoInfoMsg;
  end;{по складам}



 {формирование отчета}
 Assign(T,Path^.Dat.ToTemp+'litrinn.txt');
 IORez:=IOResult;
 Rewrite(T);
 IORez:=IOResult;
 If IORez <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path^.Dat.ToTemp+'litrinn.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

  Writeln(T,Header+Space+'Оператор: '+CurrentPassword+HeaderStop);
  Writeln(t,Space+'Выбраны следующие виды продукции:');

  if not bTula then
  if (ClassSelect<>nil) and (ClassSelect^.List^.Count>0) then
  for i:=0 to ClassSelect^.List^.Count-1 do
  begin
    s:=copy(ClassSelect^.GetText(i,ClassSelect^.List^.Count),1,CSertif);
    Writeln(t,Space+s);
  end;
  if bTula Then
  if (RazdelSelect<>nil) and (RazdelSelect^.List^.Count>0) then
  for i:=0 to RazdelSelect^.List^.Count-1 do
  begin
    s:=copy(RazdelSelect^.GetText(i,RazdelSelect^.List^.Count),1,CClient);
    Writeln(t,Space+s);
  end;

  Writeln(t);
  Writeln(t,Space+'Выбраны следующие склады:');
  for TekSkl:=1 to CMaxSklads do
  if AllSkl[TekSkl]=1 then
  writeln(t,Space+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1));
  Writeln(t);

 Writeln(t,Space+'Включены в рассмотрение виды документов:');
 Write(t,Space);
 For i:=1 To Max9 Do
  Begin
   If FiltrDoc[i]=1 Then
    Case i Of
    1:Write(t,' "Список" ');
    2:Write(t,' "Тов.Чек*" ');
    3:Write(t,' "Физ.Л*" ');
    4:Write(t,' "СФ*" ');
    5:Write(t,' "СФ Б" ');
    6:Write(t,' "Дебит*" ');
    7:Write(t,' "Дебит СФ*" ');
    8:Write(t,' "Дебит" ');
    9:Write(t,' "Дебит СФБ" ');
    Else;
    End;
  End;
 Writeln(t);


 Writeln(t,Header+Space+'          ПРОДАНО (реализовано) В РАЗРЕЗЕ ПО ПОТРЕБИТЕЛЯМ за период '+
 ' с '+StartDate+' по '+StopDate);

 Writeln(t,Space+'┌───┬───────────────────────────┬─────────────────────────────────────────────┬────────────────────'+
 '─────────────────────────┬───────────────┬───────────────┐');
 Writeln(t,Space+'│ N │ИНН                        │Наименовние покупателя                       │Адрес               '+
 '                         │Далл.          │ Руб.          │');
 Writeln(t,Space+'└───┴───────────────────────────┴─────────────────────────────────────────────┴────────────────────'+
 '─────────────────────────┴───────────────┴───────────────┘',
   HeaderStop);

  R.Assign(0, 0, 0, 0);
 SortBox := New(PBox, Init(R, 1, Nil));
 SortBox^.NewList(New(PTextCollection, Init(0,1)));

 if TempBox^.List^.Count>0 then
 for i:=0 to TempBox^.List^.Count-1 do
 Begin
   DInfoMsgShkala('Сортирую отчет...',0,TempBox^.List^.Count-1,i);
   s:=TEmpBox^.GetText(i,TempBox^.List^.Count);
   sClKod:=copy(s,1,CClientKod);
   INN:=GetClientField(FINN,sClKod,0);
   format(INN,CName);
   AdressF:=GetClientField(FAdress,sClKod,0);
   format(AdressF,CAll);
   FullName:=GetClientField(FFullClient,sClKod,0);
   format(FullName,CAll);
   {writeln(INN+s+FullName+AdressF);
   readln;}
   SortBox^.List^.Insert(NewStr(INN+s+FullName+AdressF));
   SortBox^.SetRange(SortBox^.List^.Count);
 End;
   NoInfoMsg;

 SumLitr:='0.00';
 SumLitrRegion:='0.00';
 SumZena:='0.00';
 SumZenaRegion:='0.00';


 if SortBox^.List^.Count>0 then
 Begin
  OldRegion:=Copy(SortBox^.GetText(0,SortBox^.List^.Count),1,CINNRegion);
 End;
 if SortBox^.List^.Count>0 then
 for i:=0 to SortBox^.List^.Count-1 do
 Begin
   DInfoMsgShkala('Формирую отчет...',0,SortBox^.List^.Count-1,i);
   s:=SortBox^.GetText(i,SortBox^.List^.Count);
   NewRegion:=Copy(S,1,CINNRegion);
   sn:=IntToStr(i+1,CClientKod);
   rformat(sn,CClientKod);
   if (OldRegion<>NewRegion)
   then
   begin
    Writeln(t,Space+'──────────────────────────────────────────────────────────────────────────────────────────────────────'
   +'───────────────────────────────────────────────────────');
    Writeln(t,Space+SeparatorChar+'ИТОГО ПО РАЙОНУ '+OldRegion+':'+SeparatorChar+SeparatorChar+SeparatorChar,
       SumLitrRegion,SeparatorChar,SumZenaRegion);
    Writeln(t,Space+'──────────────────────────────────────────────────────────────────────────────────────────────────────'
   +'───────────────────────────────────────────────────────');
    OldRegion:=NewRegion;
    SumLitrRegion:='0.00';
    SumZenaRegion:='0.00';
   end;
   MyStr(StrToReal(SumLitrRegion)+StrToReal(copy(s,1+CName+CClientKOd,CIZena)),CIZena,CMantissaZ,SumLitrRegion);
   MyStr(StrToReal(SumZenaRegion)+StrToReal(copy(s,1+CName+CClientKOd+CIzena,CIZena)),CIZena,CMantissa,SumZenaRegion);
   MyStr(StrToReal(SumLitr)+StrToReal(copy(s,1+CName+CClientKOd,CIZena)),CIZena,CMantissaZ,SumLitr);
   MyStr(StrToReal(SumZena)+StrToReal(copy(s,1+CName+CClientKOd+CIzena,CIZena)),CIZena,CMantissa,SumZena);

   AdressF:=Copy(s,1+CName+CClientKod+CIZena+CIZena+Call,Call);
   FullName:=Copy(s,1+CName+CClientKod+CIZena+CIZena,Call);
   INN:=Copy(s,1,CName);
   write(t,Space+sn+SeparatorChar+'_'+Inn);
   write(t,SeparatorChar+FullName);
   writeln(t,SeparatorChar+AdressF+SeparatorChar+copy(s,1+CName+CClientKOd,CIZena)+
      SeparatorChar+copy(s,1+CName+CClientKOd+CIZena,CIZena));
   if i=SortBox^.List^.Count-1
   then
   begin
    Writeln(t,Space+'──────────────────────────────────────────────────────────────────────────────────────────────────────'
   +'───────────────────────────────────────────────────────');
    Writeln(t,Space+SeparatorChar+'ИТОГО ПО РАЙОНУ '+NewRegion+':'+SeparatorChar+SeparatorChar+SeparatorChar,SumLitrRegion,
      SeparatorChar,SumZenaRegion);
    Writeln(t,Space+'──────────────────────────────────────────────────────────────────────────────────────────────────────'
   +'───────────────────────────────────────────────────────');
    OldRegion:=NewRegion;
    SumLitrRegion:='0.00';
   end;
   {Writeln(t,Space+'-------------------------------------------------------------------');}
 End;
    NoInfoMsg;


   Writeln(t,Space+'ИТОГО: ',SeparatorChar,SumLitr,SeparatorChar,SumZena);
   Writeln(t);

   Writeln(t,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
   Writeln(t,Space+'======================================================================================================'
   +'=======================================================');

 Dispose(SortBox,Done);
 Dispose(TempBox,Done);
 IORez:=ioresult;
 System.Close(t);
 IORez:=ioresult;

 ViewAsText(Path^.Dat.ToTemp+'litrinn.txt',
 'Отчет по литражу для декларации по районам '+' с '+StartDate+' по '+StopDate+' ('+Times+')',
  True);

End;

BEGIN


END.