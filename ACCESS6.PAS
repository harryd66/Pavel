{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Access6;

Interface

Uses Dialogs,Glob,Drivers,ServStr,Utils1,Utils8;


Type
    PMarkaWindow= ^TMarkaWindow;
    TMarkaWindow = object(TDialog)
    lnk : PLinkMarkaWindow;
    Procedure ImportSPR;
    Procedure ShowMarkaList(Var st:String;Var Res: Word);
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type
    PSpecMarkaWindow= ^TSpecMarkaWindow;
    TSpecMarkaWindow = object(TDialog)
    lnk : PLinkSpecMarkaWindow;
    Procedure ImportSPR;
    Procedure ShowSpecMarkaList(Var st:String;Var Res: Word);
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type
    PNGTDWindow= ^TNGTDWindow;
    TNGTDWindow = object(TDialog)
    lnk : PLinkNGTDWindow;
    Procedure ImportSPR;
    Procedure ShowNGTDList(Var st:String;Var Res: Word);
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type
    PClassWindow= ^TClassWindow;
    TClassWindow = object(TDialog)
    {lnk : PLinkNGTDWindow;}
    Procedure ImportSPR;
    Procedure ShowClassList(Var st:String;Var Res: Word);
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Implementation

{$I Compile.INC}

Uses Printers,App,Views,Objects,MsgBox,Serv,Utils5,
     ColorTxt,Validate,DbEngin2,Memory,TpDate,Utils,Utils3,Utils4,
     DbEngine,Utils7,FileTool,ServStr2,MyView,
     Protect,Net,Net2,NetDbEng,NetCall;

Const LocalReadOnlyN=$42;

Var

   NGTDWindow :   PNGTDWindow;
   ClassWindow:   PClassWindow;
   PrevCurrentLine :SertifStr;
   MarkaWindow :   PMarkaWindow;
   SpecMarkaWindow :   PSpecMarkaWindow;
   NGTDNum,MarkaNum,SpecMarkaNum: PBox;
   NGTDFile  : NGTDFileType;

   MarkaFile : MarkaFileType;
   ClassFile : ClassFileType;
   SpecMarkaFile : SpecMarkaFileType;
   NGTDList,ClassList,MarkaList,SpecMarkaList : PBox;
   ff : File;
   BufNGTDElement : PBufNGTDType;
   BufMarkaElement : PBufMarkaType;
   BufSpecMarkaElement : PBufSpecMarkaType;
   Count : Word;
   BufClassElement : PBufClassificatorBuchType;
   COntrolCount:PView;

   jk,CountElement : LongInt;


   OldFileMode : Word;
   L : Longint;
   FFF : ^Integer;
   fId : File;
   FastRead : Boolean;
   SKod : ArtikulStr;
   SElement: String[80];



Function AddNGTD( Cod:Integer; Var NGTDElement:NGTDType):Boolean;
Label 1;
var
  R : TRect;
  AddNGTDWin : PDialog;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full,Full1 : Boolean;
  k : LongInt;
  NGTDNum : PBox;
{  l : Boolean;}
  Event:TEvent;
  SRegName : AllStr;
  Find : Boolean;
  Count : Word;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddNGTD:=False;
    Exit;
   End;


If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    AddNGTD:=False;
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    AddNGTD:=False;
    Exit;
   End;

  If Not(Password(16)) Then
   Begin
    AddNGTD:=False;
    Exit;
   End;

C:=IOResult;
AddNGTD:=False;
Full:=True;
Full1:=False;

{If Password(5) Then Full1:=True;}

DInfoMsg('Читаю списки...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin

Assign(ff,Path^.Dat.ToSPR+'ngtd.db');
Reset(ff,SizeOf(NGTDType));
C:=IOResult;
If C<>0 Then
Begin
 NoInfoMsg;
 MessageBox(#3^M+#3'Ошибка доступа к файлу ГТД!',nil,mfError+mfCancelButton);
 AddNGTD:=False;
 Exit;
End;

     NGTDElement.Employ:=True;
     Find:=False;
     While Not(Eof(ff)) And Not(Find) Do
     begin
      New(BufNGTDElement,Init);
      ReadBufNGTD(ff,BufNGTDElement,Count);
      For j:=1 To Count Do
      Begin
       NGTDElement:=BufNGTDElement^.Point.Dat[j];
       If Not NGTDElement.Employ Then
        Begin
         Find:=True;
         Break;
        End;
      End;
      Dispose(BufNGTDElement,Done);
     end;{While}


     If Not Find Then
      Begin
       System.Close(ff);
       NoInfoMsg;
       MessageBox(#3^M+#3'Свободных позиций - нет!',nil,mfWarning+mfCancelButton);
       AddNGTD:=False;
       Exit;
      End;

      C:=IOResult;
      System.Close(ff);
      C:=IOResult;

      s:=NGTDElement.Kod;
      NGTDElement.NGTD[0]:=#0;
      NGTDElement.Kod:=NoNGTDStr;
    End;

  kbF4:Begin

Assign(NGTDFile,Path^.Dat.ToSPR+'ngtd.db');
Reset(NGTDFile);
C:=IOResult;
If C<>0 Then
Begin
 NoInfoMsg;
 MessageBox(#3^M+#3'Ошибка доступа к файлу ГТД!',nil,mfError+mfCancelButton);
 AddNGTD:=False;
 Exit;
End;
     s:=Copy(NGTDList^.GetText(NGTDList^.Focused,NGTDList^.List^.Count),1+CNGTD+1,CArtikul);
     Seek(NGTDFile,StrToInt(s));
     Repeat
      ReadNGTD(NGTDFile,NGTDElement);
     Until (Eof(NGTDFile)) Or (NGTDElement.Kod=s);
     If Eof(NGTDFile) And (NGTDElement.Kod<>s) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3'ГТД с кодом '+s+' в базе не найдена!',nil,mfError+mfCancelButton);
       System.Close(NGTDFile);
       AddNGTD:=False;
       Exit;
      End;
     C:=IOResult;
     System.Close(NGTDFile);
     C:=IOResult;
    End;
  Else;
 End;
1:


If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
Begin
R.Assign(11, 7, 70, 15);
New(AddNGTDWin, Init(R, 'Добавить ГТД'));
End
Else
Begin
R.Assign(11, 7, 70, 11);
New(AddNGTDWin, Init(R, 'Изменить ГТД'));
End;
AddNGTDWin^.Options := AddNGTDWin^.Options or ofCenterX or ofCenterY;
AddNGTDWin^.Palette := dpCyanDialog;
AddNGTDWin^.HelpCtx:=$E011;
R.Assign(9, 1, 37, 2);
Control := New(PInputLine, Init(R, CNGTD));
AddNGTDWin^.Insert(Control);

  R.Assign(37, 1, 40, 2);
  AddNGTDWin^.Insert(New(PHistory, Init(R, PInputline(Control), 102)));

  R.Assign(1, 1, 9, 2);
  AddNGTDWin^.Insert(New(PLabel, Init(R, '  ~Г~ТД:', Control)));


AddNGTDWin^.SetData(NGTDElement);


If (Cod = kbGrayPlus)Or (Cod=kbAltF1)  Then
Begin
 R.Assign(58, 3, 59, 7);
 Control := New(PScrollBar, Init(R));
 AddNGTDWin^.Insert(Control);
 R.Assign(1, 3, 58, 7);
 NGTDNum := New(PBox, Init(R, 8, PScrollbar(Control)));
 NGTDNum^.NewList(New(PTextCollection, Init(0,1)));

Assign(ff,Path^.Dat.ToSPR+'NGTD.db');
C:=IOResult;
Reset (ff,SizeOf(NGTDTYPE));
C:=IOResult;

 While Not(Eof(ff)) Do
  Begin
    New(BufNGTDElement,Init);
    ReadBufNGTD(ff,BufNGTDElement,Count);
    For j:=1 To Count Do
    Begin
      If Not(BufNGTDElement^.Point.Dat[j].Employ) Then
       Begin
        NGTDNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+BufNGTDElement^.Point.Dat[j].Kod));
        NGTDNum^.SetRange(NGTDNum^.List^.Count);
        NGTDNum^.FocusItem(NGTDNum^.List^.Count);
       End;
    End;{For}
   Dispose(BufNGTDElement,Done);
  End;
 C:=IOResult;
 System.Close(ff);
 C:=IOResult;

 If Cod=kbF4 Then NGTDNum^.FocusItem(LoCation(NGTDNum,s,False))
 Else NGTDNum^.FocusItem(0);

 AddNGTDWin^.Insert(NGTDNum);
 NGTDNum^.HelpCtx:=$E011;

  R.Assign(1, 2, 17, 3);
  AddNGTDWin^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', NGTDNum)));
  AddNGTDWin^.Insert(Control);
 End;
If Cod=kbF4 Then
 Begin
  R.Assign(40, 1, 53, 2);
  Control := New(PColoredText, Init(R, 'Код ГТД:', $3E));
  AddNGTDWin^.Insert(Control);
  R.Assign(53, 1, 58, 2);
  Control := New(PColoredText, Init(R, NGTDElement.Kod,$3E));
  AddNGTDWin^.Insert(Control);
 End;

AddNGTDWin^.SelectNext(False);
NoInfoMsg;
c:=Desktop^.ExecView(AddNGTDWin);
If c<>cmCancel Then
 Begin
    AddNGTDWin^.GetData(NGTDElement);
    DelSpaceRight(NGTDElement.NGTD);

    If NGTDElement.NGTD[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название ГТД!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=NGTDNum^.GetText(NGTDNum^.Focused,NGTDNum^.List^.Count);
   s:=Copy(s,1+CNGTD+1,CArtikul);
  NGTDNum^.NewList(Nil);
  Dispose(NGTDNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddNGTDWin,Done);
    Goto 1;
   End;

  C:=IOResult;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=NGTDNum^.GetText(NGTDNum^.Focused,NGTDNum^.List^.Count);
   s:=Copy(s,1+1,CArtikul);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   If Not(TestEmployElementAndLock(FNGTD,s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать ГТД с кодом '+s+'... Попробуйте изменить код!',False);
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(NGTDNum,Done);
     Dispose(Control,Done);
     Dispose(AddNGTDWin,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(NGTDElement.NGTD);
   NGTDElement.Employ:=True;

   If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then NGTDElement.Kod:=s;


  {если не удалось записать информацию}
  If Not (WriteLockNGTD(NGTDElement)) Then
    Begin
     If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then Dispose(NGTDNum,Done);
     Dispose(Control,Done);
     Dispose(AddNGTDWin,Done);
     Repeat
     Until (SetElementUnLock(FNGTD,s));
     Goto 1;
    End
    Else
    RefreshCashOneSPR(BNGTD);


  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   AddProtocol('Добавление ГТД:'+NGTDElement.NGTD+' ('+s+')','','');
   Repeat
   Until (SetElementUnLock(FNGTD,s));
  End
  Else
   AddProtocol('Корректировка ГТД:'+NGTDElement.NGTD+' ('+NGTDElement.Kod+')','','');
  AddNGTD:=True;
 End;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
  NGTDNum^.NewList(Nil);
  Dispose(NGTDNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddNGTDWin,Done);

  PrevCurrentLine[0]:=#0;

End;


Function AddClass( Cod:Integer; Var ClassElement:ClassificatorBuchType):Boolean;
Label 1;
var
  R : TRect;
  AddClassWin : PDialog;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full,Full1 : Boolean;
  k : LongInt;
  ClassNum : PBox;
  Event:TEvent;
  SRegName : AllStr;
  Find : Boolean;
  Count : Word;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddClass:=False;
    Exit;
   End;


If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    AddClass:=False;
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    AddClass:=False;
    Exit;
   End;

  If Not(Password(16)) Then
   Begin
    AddClass:=False;
    Exit;
   End;

C:=IOResult;
AddClass:=False;
Full:=True;
Full1:=False;

{If Password(5) Then Full1:=True;}

DInfoMsg('Читаю списки...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin

Assign(ff,Path^.Dat.ToSPR+'Class.db');
Reset(ff,SizeOf(ClassificatorBuchType));
C:=IOResult;
If C<>0 Then
Begin
 NoInfoMsg;
 MessageBox(#3^M+#3'Ошибка доступа к файлу классов!',nil,mfError+mfCancelButton);
 AddClass:=False;
 Exit;
End;

     ClassElement.Employ:=True;
     Find:=False;
     While Not(Eof(ff)) And Not(Find) Do
     begin
      New(BufClassElement,Init);
      ReadBufClass(ff,BufClassElement,Count);
      For j:=1 To Count Do
      Begin
       ClassElement:=BufClassElement^.Point.Dat[j];
       If Not ClassElement.Employ Then
        Begin
         Find:=True;
         Break;
        End;
      End;
      Dispose(BufClassElement,Done);
     end;{While}


     If Not Find Then
      Begin
       System.Close(ff);
       NoInfoMsg;
       MessageBox(#3^M+#3'Свободных позиций - нет!',nil,mfWarning+mfCancelButton);
       AddClass:=False;
       Exit;
      End;

      C:=IOResult;
      System.Close(ff);
      C:=IOResult;

      s:=ClassElement.Kod;
      ClassElement.Name[0]:=#0;
      ClassElement.Kod:=NoClassStr;
    End;

  kbF4:Begin

Assign(ClassFile,Path^.Dat.ToSPR+'Class.db');
Reset(ClassFile);
C:=IOResult;
If C<>0 Then
Begin
 NoInfoMsg;
 MessageBox(#3^M+#3'Ошибка доступа к файлу классов!',nil,mfError+mfCancelButton);
 AddClass:=False;
 Exit;
End;
     s:=Copy(ClassList^.GetText(ClassList^.Focused,ClassList^.List^.Count),1+(CAll+16)+1,CArtikul);
     Seek(ClassFile,StrToInt(s));
     Repeat
      ReadClass(ClassFile,ClassElement);
     Until (Eof(ClassFile)) Or (ClassElement.Kod=s);
     If Eof(ClassFile) And (ClassElement.Kod<>s) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3'Класс с кодом '+s+' в базе не найдена!',nil,mfError+mfCancelButton);
       System.Close(ClassFile);
       AddClass:=False;
       Exit;
      End;
     C:=IOResult;
     System.Close(ClassFile);
     C:=IOResult;
    End;
  Else;
 End;
1:


If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
Begin
R.Assign(11, 7, 70, 15);
New(AddClassWin, Init(R, 'Добавить класс'));
End
Else
Begin
R.Assign(11, 7, 70, 11);
New(AddClassWin, Init(R, 'Изменить класс'));
End;
AddClassWin^.Options := AddClassWin^.Options or ofCenterX or ofCenterY;
AddClassWin^.Palette := dpCyanDialog;
AddClassWin^.HelpCtx:=$E011;
R.Assign(8, 1, 55, 2);
Control := New(PInputLine, Init(R, CSertif));
AddClassWin^.Insert(Control);

  R.Assign(55, 1, 58, 2);
  AddClassWin^.Insert(New(PHistory, Init(R, PInputline(Control), 165)));

  R.Assign(1, 1, 8, 2);
  AddClassWin^.Insert(New(PLabel, Init(R, 'Клас~с~:', Control)));


AddClassWin^.SetData(ClassElement);


If (Cod = kbGrayPlus)Or (Cod=kbAltF1)  Then
Begin
 R.Assign(58, 3, 59, 7);
 Control := New(PScrollBar, Init(R));
 AddClassWin^.Insert(Control);
 R.Assign(1, 3, 58, 7);
 ClassNum := New(PBox, Init(R, 8, PScrollbar(Control)));
 ClassNum^.NewList(New(PTextCollection, Init(0,1)));

Assign(ff,Path^.Dat.ToSPR+'Class.db');
C:=IOResult;
Reset (ff,SizeOf(ClassificatorBuchTYPE));
C:=IOResult;

 While Not(Eof(ff)) Do
  Begin
    New(BufClassElement,Init);
    ReadBufClass(ff,BufClassElement,Count);
    For j:=1 To Count Do
    Begin
      If Not(BufClassElement^.Point.Dat[j].Employ) Then
       Begin
        ClassNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+BufClassElement^.Point.Dat[j].Kod));
        ClassNum^.SetRange(ClassNum^.List^.Count);
        ClassNum^.FocusItem(ClassNum^.List^.Count);
       End;
    End;{For}
   Dispose(BufClassElement,Done);
  End;
 C:=IOResult;
 System.Close(ff);
 C:=IOResult;

 If Cod=kbF4 Then ClassNum^.FocusItem(LoCation(ClassNum,s,False))
 Else ClassNum^.FocusItem(0);

 AddClassWin^.Insert(ClassNum);
 ClassNum^.HelpCtx:=$E011;

  R.Assign(1, 2, 17, 3);
  AddClassWin^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', ClassNum)));
  AddClassWin^.Insert(Control);
 End;
If Cod=kbF4 Then
 Begin
  R.Assign(40, 0, 53, 1);
  Control := New(PColoredText, Init(R, 'Код:', $3E));
  AddClassWin^.Insert(Control);
  R.Assign(53, 0, 58, 1);
  Control := New(PColoredText, Init(R, ClassElement.Kod,$3E));
  AddClassWin^.Insert(Control);
 End;

AddClassWin^.SelectNext(False);
NoInfoMsg;
c:=Desktop^.ExecView(AddClassWin);
If c<>cmCancel Then
 Begin
    AddClassWin^.GetData(ClassElement);
    DelSpaceRight(ClassElement.Name);

    If ClassElement.Name[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название классов!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=ClassNum^.GetText(ClassNum^.Focused,ClassNum^.List^.Count);
   s:=Copy(s,1+(CAll+16)+1,CArtikul);
  ClassNum^.NewList(Nil);
  Dispose(ClassNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddClassWin,Done);
    Goto 1;
   End;

  C:=IOResult;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=ClassNum^.GetText(ClassNum^.Focused,ClassNum^.List^.Count);
   s:=Copy(s,1+1,CArtikul);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   If Not(TestEmployElementAndLock(FClass,s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать класс с кодом '+s+'... Попробуйте изменить код!',False);
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(ClassNum,Done);
     Dispose(Control,Done);
     Dispose(AddClassWin,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(ClassElement.Name);
   ClassElement.Employ:=True;

   If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then ClassElement.Kod:=s;


  {если не удалось записать информацию}
  If Not (WriteLockClass(ClassElement)) Then
    Begin
     If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then Dispose(ClassNum,Done);
     Dispose(Control,Done);
     Dispose(AddClassWin,Done);
     Repeat
     Until (SetElementUnLock(FClass,s));
     Goto 1;
    End
    Else
    RefreshCashOneSPR(BClass);


  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   AddProtocol('Добавление класса:'+ClassElement.Name+' ('+s+')','','');
   Repeat
   Until (SetElementUnLock(FClass,s));
  End
  Else
   AddProtocol('Корректировка класса:'+ClassElement.Name+' ('+ClassElement.Kod+')','','');
  AddClass:=True;
 End;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
  ClassNum^.NewList(Nil);
  Dispose(ClassNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddClassWin,Done);

  PrevCurrentLine[0]:=#0;

End;






Function AddMarka( Cod:Integer; Var MarkaElement:MarkaType):Boolean;
Label 1;
var
  R : TRect;
  AddMarkaWin : PDialog;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full,Full1 : Boolean;
  k : LongInt;
  MarkaNum : PBox;
{  l : Boolean;}
  Event:TEvent;
  SRegName : AllStr;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddMarka:=False;
    Exit;
   End;


If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    AddMarka:=False;
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    AddMarka:=False;
    Exit;
   End;

  If Not(Password(16)) Then
   Begin
    AddMarka:=False;
    Exit;
   End;

C:=IOResult;
AddMarka:=False;
Full:=True;
Full1:=False;

{If Password(5) Then Full1:=True;}

Assign(MarkaFile,Path^.Dat.ToSPR+'Marka.db');

Reset(MarkaFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу!',nil,mfError+mfCancelButton);
 AddMarka:=False;
 Exit;
End;
DInfoMsg('Читаю списки...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin
     MarkaElement.Employ:=True;
     While Not(Eof(MarkaFile)) And (MarkaElement.Employ) Do
     begin
      ReadMarka(MarkaFile,MarkaElement);
     end;

     If Eof(MarkaFile) And (MarkaElement.Employ) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3'Свободных позиций - нет!',nil,mfWarning+mfCancelButton);
       System.Close(MarkaFile);
       AddMarka:=False;
       Exit;
      End;
      s:=MarkaElement.Kod;
      MarkaElement.Marka[0]       :=#0;
      MarkaElement.Kod     :=NoMarkaStr;
    End;

  kbF4:Begin
     s:=Copy(MarkaList^.GetText(MarkaList^.Focused,MarkaList^.List^.Count),1+CMarka+1,CArtikul);
     Seek(MarkaFile,StrToInt(s));
     Repeat
      ReadMarka(MarkaFile,MarkaElement);
     Until (Eof(MarkaFile)) Or (MarkaElement.Kod=s);
     If Eof(MarkaFile) And (MarkaElement.Kod<>s) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3'Марка с кодом '+s+' в базе не найдена!',nil,mfError+mfCancelButton);
       System.Close(MarkaFile);
       AddMarka:=False;
       Exit;
      End;
    End;
  Else;
 End;
System.Close(MarkaFile);
1:


If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
Begin
R.Assign(11, 7, 70, 15);
New(AddMarkaWin, Init(R, 'Добавить акцизную марку'));
End
Else
Begin
R.Assign(11, 7, 70, 11);
New(AddMarkaWin, Init(R, 'Изменить акцизную марку'));
End;
AddMarkaWin^.Options := AddMarkaWin^.Options or ofCenterX or ofCenterY;
AddMarkaWin^.Palette := dpCyanDialog;
AddMarkaWin^.HelpCtx:=$E011;
R.Assign(9, 1, 37, 2);
Control := New(PInputLine, Init(R, CMarka));
AddMarkaWin^.Insert(Control);

  R.Assign(37, 1, 40, 2);
  AddMarkaWin^.Insert(New(PHistory, Init(R, PInputline(Control), 101)));

  R.Assign(1, 1, 9, 2);
  AddMarkaWin^.Insert(New(PLabel, Init(R, Seria_Akzis^+':', Control)));


AddMarkaWin^.SetData(MarkaElement);


If (Cod = kbGrayPlus)Or (Cod=kbAltF1)  Then
Begin
 R.Assign(58, 3, 59, 7);
 Control := New(PScrollBar, Init(R));
 AddMarkaWin^.Insert(Control);
 R.Assign(1, 3, 58, 7);
 MarkaNum := New(PBox, Init(R, 8, PScrollbar(Control)));
 MarkaNum^.NewList(New(PTextCollection, Init(0,1)));
(*
Assign(MarkaFile,Path^.Dat.ToSPR+'Marka.db');
Reset (MarkaFile);
 While Not(Eof(MarkaFile)) Do
  Begin
   ReadMarka(MarkaFile,MarkaElement);
   If Not(MarkaElement.Employ) Then
   Begin
   MarkaNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+MarkaElement.Kod));
   MarkaNum^.SetRange(MarkaNum^.List^.Count);
   MarkaNum^.FocusItem(MarkaNum^.List^.Count);
   End;
  End;
 System.Close(MarkaFile);
*)

Assign(ff,Path^.Dat.ToSPR+'Marka.db');
C:=IOResult;
Reset (ff,SizeOf(MarkaTYPE));
C:=IOResult;

 While Not(Eof(ff)) Do
  Begin
    New(BufMarkaElement,Init);
    ReadBufMarka(ff,BufMarkaElement,Count);
    For j:=1 To Count Do
    Begin
      If Not(BufMarkaElement^.Point.Dat[j].Employ) Then
       Begin
        MarkaNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+BufMarkaElement^.Point.Dat[j].Kod));
        MarkaNum^.SetRange(MarkaNum^.List^.Count);
        MarkaNum^.FocusItem(MarkaNum^.List^.Count);
       End;
    End;{For}
   Dispose(BufMarkaElement,Done);
  End;
 C:=IOResult;
 System.Close(ff);
 C:=IOResult;

 If Cod=kbF4 Then MarkaNum^.FocusItem(LoCation(MarkaNum,s,False))
 Else MarkaNum^.FocusItem(0);

 AddMarkaWin^.Insert(MarkaNum);
 MarkaNum^.HelpCtx:=$E011;

  R.Assign(1, 2, 17, 3);
  AddMarkaWin^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', MarkaNum)));
  AddMarkaWin^.Insert(Control);
 End;
If Cod=kbF4 Then
 Begin
  R.Assign(40, 1, 53, 2);
  Control := New(PColoredText, Init(R, 'Код марки:', $3E));
  AddMarkaWin^.Insert(Control);
  R.Assign(53, 1, 58, 2);
  Control := New(PColoredText, Init(R, MarkaElement.Kod,$3E));
  AddMarkaWin^.Insert(Control);
 End;

AddMarkaWin^.SelectNext(False);
NoInfoMsg;
c:=Desktop^.ExecView(AddMarkaWin);
If c<>cmCancel Then
 Begin
    AddMarkaWin^.GetData(MarkaElement);
    DelSpaceRight(MarkaElement.Marka);

    If MarkaElement.Marka[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название марки!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=MarkaNum^.GetText(MarkaNum^.Focused,MarkaNum^.List^.Count);
   s:=Copy(s,1+CMarka+1,CArtikul);
  MarkaNum^.NewList(Nil);
  Dispose(MarkaNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddMarkaWin,Done);
    Goto 1;
   End;

  C:=IOResult;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=MarkaNum^.GetText(MarkaNum^.Focused,MarkaNum^.List^.Count);
   s:=Copy(s,1+1,CArtikul);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   If Not(TestEmployElementAndLock(FMarka,s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать элемент с кодом '+s+'... Попробуйте изменить код!',False);
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(MarkaNum,Done);
     Dispose(Control,Done);
     Dispose(AddMarkaWin,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}
   UpStr(MarkaElement.Marka);
   MarkaElement.Employ:=True;

   If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then MarkaElement.Kod:=s;


  {если не удалось записать информацию}
  If Not (WriteLockMarka(MarkaElement)) Then
    Begin
     If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then Dispose(MarkaNum,Done);
     Dispose(Control,Done);
     Dispose(AddMarkaWin,Done);
     Repeat
     Until (SetElementUnLock(FMarka,s));
     Goto 1;
    End
    Else
      RefreshCashOneSPR(BMarka);

  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   AddProtocol('Добавление марки:'+MarkaElement.Marka+' ('+s+')','','');
   Repeat
   Until (SetElementUnLock(FMarka,s));
  End
  Else
   AddProtocol('Корректировка марки:'+MarkaElement.Marka+' ('+MarkaElement.Kod+')','','');
  AddMarka:=True;
 End;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
  MarkaNum^.NewList(Nil);
  Dispose(MarkaNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddMarkaWin,Done);

  PrevCurrentLine[0]:=#0;

End;



Function AddSpecMarka( Cod:Integer; Var SpecMarkaElement:SpecMarkaType):Boolean;
Label 1;
var
  R : TRect;
  AddSpecMarkaWin : PDialog;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full,Full1 : Boolean;
  k : LongInt;
  SpecMarkaNum : PBox;
{ l : Boolean;}
  Event:TEvent;
  SRegName : AllStr;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddSpecMarka:=False;
    Exit;
   End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    AddSpecMarka:=False;
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    AddSpecMarka:=False;
    Exit;
   End;

  If Not(Password(16)) Then
   Begin
    AddSpecMarka:=False;
    Exit;
   End;

C:=IOResult;
AddSpecMarka:=False;
Full:=True;
Full1:=False;

{If Password(5) Then Full1:=True;}

Assign(SpecMarkaFile,Path^.Dat.ToSPR+'SMarka.db');

Reset(SpecMarkaFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу спец.марок!',nil,mfError+mfCancelButton);
 AddSpecMarka:=False;
 Exit;
End;
DInfoMsg('Читаю списки...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin
     SpecMarkaElement.Employ:=True;
     While Not(Eof(SpecMarkaFile)) And (SpecMarkaElement.Employ) Do
     begin
      ReadSpecMarka(SpecMarkaFile,SpecMarkaElement);
     end;

     If Eof(SpecMarkaFile) And (SpecMarkaElement.Employ) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3'Свободных позиций - нет!',nil,mfWarning+mfCancelButton);
       System.Close(SpecMarkaFile);
       AddSpecMarka:=False;
       Exit;
      End;
      s:=SpecMarkaElement.Kod;
      SpecMarkaElement.SpecMarka[0]       :=#0;
      SpecMarkaElement.Kod     :=NoSpecMarkaStr;
    End;

  kbF4:Begin
     s:=Copy(SpecMarkaList^.GetText(SpecMarkaList^.Focused,SpecMarkaList^.List^.Count),1+CMarka+1,CArtikul);
     Seek(SpecMarkaFile,StrToInt(s));
     Repeat
      ReadSpecMarka(SpecMarkaFile,SpecMarkaElement);
     Until (Eof(SpecMarkaFile)) Or (SpecMarkaElement.Kod=s);
     If Eof(SpecMarkaFile) And (SpecMarkaElement.Kod<>s) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3'Элемент с кодом '+s+' в базе не найден!',nil,mfError+mfCancelButton);
       System.Close(SpecMarkaFile);
       AddSpecMarka:=False;
       Exit;
      End;
    End;
  Else;
 End;
System.Close(SpecMarkaFile);
1:


If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
Begin
R.Assign(11, 7, 70, 15);
New(AddSpecMarkaWin, Init(R, 'Добавить спец.марку'));
End
Else
Begin
R.Assign(11, 7, 70, 11);
New(AddSpecMarkaWin, Init(R, 'Изменить спец.марку'));
End;
AddSpecMarkaWin^.Options := AddSpecMarkaWin^.Options or ofCenterX or ofCenterY;
AddSpecMarkaWin^.Palette := dpCyanDialog;
AddSpecMarkaWin^.HelpCtx:=$E011;

R.Assign(9, 1, 37, 2);
Control := New(PInputLine, Init(R, CSpecMarka));
AddSpecMarkaWin^.Insert(Control);

  R.Assign(37, 1, 40, 2);
  AddSpecMarkaWin^.Insert(New(PHistory, Init(R, PInputline(Control), 104)));

  R.Assign(1, 1, 9, 2);
  AddSpecMarkaWin^.Insert(New(PLabel, Init(R, '~М~арка:', Control)));


AddSpecMarkaWin^.SetData(SpecMarkaElement);


If (Cod = kbGrayPlus)Or (Cod=kbAltF1)  Then
Begin
 R.Assign(58, 3, 59, 7);
 Control := New(PScrollBar, Init(R));
 AddSpecMarkaWin^.Insert(Control);
 R.Assign(1, 3, 58, 7);
 SpecMarkaNum := New(PBox, Init(R, 8, PScrollbar(Control)));
 SpecMarkaNum^.NewList(New(PTextCollection, Init(0,1)));

(*
Assign(SpecMarkaFile,Path^.Dat.ToSPR+'SMarka.db');
Reset (SpecMarkaFile);
 While Not(Eof(SpecMarkaFile)) Do
  Begin
   ReadSpecMarka(SpecMarkaFile,SpecMarkaElement);
   If Not(SpecMarkaElement.Employ) Then
   Begin
   SpecMarkaNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+SpecMarkaElement.Kod));
   SpecMarkaNum^.SetRange(SpecMarkaNum^.List^.Count);
   SpecMarkaNum^.FocusItem(SpecMarkaNum^.List^.Count);
   End;
  End;
 System.Close(SpecMarkaFile);
*)
Assign(ff,Path^.Dat.ToSPR+'SMarka.db');
C:=IOResult;
Reset (ff,SizeOf(SpecMarkaTYPE));
C:=IOResult;

 While Not(Eof(ff)) Do
  Begin
    New(BufSpecMarkaElement,Init);
    ReadBufSpecMarka(ff,BufSpecMarkaElement,Count);
    For j:=1 To Count Do
    Begin
      If Not(BufSpecMarkaElement^.Point.Dat[j].Employ) Then
       Begin
        SpecMarkaNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+BufSpecMarkaElement^.Point.Dat[j].Kod));
        SpecMarkaNum^.SetRange(SpecMarkaNum^.List^.Count);
        SpecMarkaNum^.FocusItem(SpecMarkaNum^.List^.Count);
       End;
    End;{For}
   Dispose(BufSpecMarkaElement,Done);
  End;
 C:=IOResult;
 System.Close(ff);
 C:=IOResult;



 If Cod=kbF4 Then SpecMarkaNum^.FocusItem(LoCation(SpecMarkaNum,s,False))
 Else SpecMarkaNum^.FocusItem(0);

 AddSpecMarkaWin^.Insert(SpecMarkaNum);
 SpecMarkaNum^.HelpCtx:=$E011;

  R.Assign(1, 2, 17, 3);
  AddSpecMarkaWin^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', SpecMarkaNum)));
  AddSpecMarkaWin^.Insert(Control);
 End;
If Cod=kbF4 Then
 Begin
  R.Assign(40, 1, 58, 2);
  Control := New(PColoredText, Init(R, 'Код марки:', $3E));
  AddSpecMarkaWin^.Insert(Control);
  R.Assign(53, 1, 58, 2);
  Control := New(PColoredText, Init(R, SpecMarkaElement.Kod,$3E));
  AddSpecMarkaWin^.Insert(Control);
 End;

AddSpecMarkaWin^.SelectNext(False);
NoInfoMsg;
c:=Desktop^.ExecView(AddSpecMarkaWin);
If c<>cmCancel Then
 Begin
    AddSpecMarkaWin^.GetData(SpecMarkaElement);
    DelSpaceRight(SpecMarkaElement.SpecMarka);

    If SpecMarkaElement.SpecMarka[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название марки!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=SpecMarkaNum^.GetText(SpecMarkaNum^.Focused,SpecMarkaNum^.List^.Count);
   s:=Copy(s,1+CMarka+1,CArtikul);
  SpecMarkaNum^.NewList(Nil);
  Dispose(SpecMarkaNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddSpecMarkaWin,Done);
    Goto 1;
   End;

  C:=IOResult;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=SpecMarkaNum^.GetText(SpecMarkaNum^.Focused,SpecMarkaNum^.List^.Count);
   s:=Copy(s,1+1,CArtikul);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   If Not(TestEmployElementAndLock(FSpecMarka,s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать марку с кодом '+s+'... Попробуйте изменить код!',False);
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(SpecMarkaNum,Done);
     Dispose(Control,Done);
     Dispose(AddSpecMarkaWin,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(SpecMarkaElement.SpecMarka);
   SpecMarkaElement.Employ:=True;

   If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then SpecMarkaElement.Kod:=s;


  {если не удалось записать информацию}
  If Not (WriteLockSpecMarka(SpecMarkaElement)) Then
    Begin
     If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then Dispose(SpecMarkaNum,Done);
     Dispose(Control,Done);
     Dispose(AddSpecMarkaWin,Done);
     Repeat
     Until (SetElementUnLock(FSpecMarka,s));
     Goto 1;
    End
    Else
    RefreshCashOneSPR(BSMarka);


  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   AddProtocol('Добавление спец.марки:'+SpecMarkaElement.SpecMarka+' ('+s+')','','');
   Repeat
   Until (SetElementUnLock(FSpecMarka,s));
  End
  Else
   AddProtocol('Корректировка спец.марки:'+SpecMarkaElement.SpecMarka+' ('+SpecMarkaElement.Kod+')','','');
  AddSpecMarka:=True;
 End;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
  SpecMarkaNum^.NewList(Nil);
  Dispose(SpecMarkaNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddSpecMarkaWin,Done);

  PrevCurrentLine[0]:=#0;

End;



Procedure TMarkaWindow.ShowMarkaList(Var st:String;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String;
  Bak : String;
  c: Word;
  c1,Count : Word;
  MarkaFile : File;
  StopRead : Boolean;
  MarkaElement : PBufMarkaType;
begin
Bak :=St;
ClearFind;
DInfoMsg('Читаю списки...',False);

Res:=0;
R.Assign(30, 5, 79, 22);
New(MarkaWindow, Init(R, 'Выбор акцизной марки'));

CountElement:=0;
jk:=0;
jk:=((MaxCollectionSize Div BufferMarka)-1) *BufferMarka;

R.Assign(1, 1, 26, 2);
ControlCount := New(PRadioButtons, Init(R,
  NewSItem('0-'+IntToStr(jk,CKol),
  NewSItem('>'+IntToStr(jk,CKol), Nil))));
MarkaWindow^.Insert(ControlCount);


if st[0]<>#0 Then
s:=Copy(st,Pos('│',st)+1,CArtikul)
Else
s:=NoMarkaStr;

If StrToInt(s)>jk Then CountElement:=1;

ControlCount^.SetData(CountElement);


R.Assign(48, 2, 49, 16);
Control := New(PScrollBar, Init(R));
MarkaWindow^.Insert(Control);

R.Assign(1, 2, 48, 16);
MarkaList := New(PBox, Init(R, 1, PScrollbar(Control)));
MarkaList^.NewList(New(PTextCollection, Init(0,1)));

(*
Assign (MarkaFile,Path^.Dat.ToClient+'.db');
c:=IOResult;
Reset (MarkaFile,SizeOf(MarkaType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(MarkaFile)) Do
 Begin
    New(MarkaElement,Init);
    ReadBufMarka(MarkaFile,MarkaElement,Count);
For c1:=1 To Count Do
Begin
  If MarkaElement^.Point.Dat[c1].Employ Then
   Begin
    Format (MarkaElement^.Point.Dat[c1].Marka,CMarka);
    MarkaList^.List^.Insert(NewStr(MarkaElement^.Point.Dat[c1].Marka+'│'+MarkaElement^.Point.Dat[c1].Kod));
    MarkaList^.SetRange(MarkaList^.List^.Count);
   End;
End;{For}
  Dispose(MarkaElement,Done);
 End;{While}
System.Close(MarkaFile);
End
Else
 Begin
  St:=BAk;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
s:=Copy(st,1+CMarka+1,CClientKod);
MarkaList^.FocusItem(Location(MarkaList,S,False));
MarkaList^.HelpCtx:=$E171;
MarkaWindow^.Insert(MarkaList);
PrevCurrentLine:=Copy(MarkaList^.GetText(MarkaList^.Focused,MarkaList^.List^.Count),1+CMarka+1,CClientKod);

MarkaWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;
*)
FastRead:=False;
If (Compress=1) And (SprList[BMarka].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'Marka.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BMarka].Time)=L Then  FastRead:=True;
End;

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
Assign (MarkaFile,Path^.Dat.ToSPR+'Marka.db');
c:=IOResult;
Reset (MarkaFile,SizeOf(MarkaType));
c:=IOResult;
 FileMode:=OLDFileMode;

If FileSize(MarkaFile)>jk Then
If CountElement=1 Then Seek(MarkaFile,jk);
c:=IOResult;

StopRead:=False;

If c=0 Then
Begin
While Not(Eof(MarkaFile)) And Not(StopRead) Do
 Begin
    New(MarkaElement,Init);
    ReadBufMarka(MarkaFile,MarkaElement,Count);
For c1:=1 To Count Do
Begin
  If MarkaElement^.Point.Dat[c1].Employ Then
   Begin
    Format (MarkaElement^.Point.Dat[c1].Marka,CMarka);

  If MarkaList^.List^.Count>=MaxCollectionSize-1 Then
   Begin
    StopRead:=True;
   End
  Else
  Begin
    MarkaList^.List^.Insert(NewStr(MarkaElement^.Point.Dat[c1].Marka+'│'+MarkaElement^.Point.Dat[c1].Kod));
    MarkaList^.SetRange(MarkaList^.List^.Count);
  End;
   End;

  If CountElement=0 Then
  If StrToInt(MarkaElement^.Point.Dat[c1].Kod)>=jk Then
  Begin
   StopRead:=True;
   Break;
  End;

End;{For}


  Dispose(MarkaElement,Done);
 End;{While}
System.Close(MarkaFile);
End
Else
 Begin
  st:=Bak;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам!',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
End
 Else
  Begin
   If SprList[BMarka].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BMarka].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BMarka].Elements^.GetText(l,SprList[BMarka].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CMarka);
     Format (SElement,CMarka);
     If Not(MarkaList^.List^.Count>=MaxCollectionSize-1) Then
     Begin
     MarkaList^.List^.Insert(NewStr(SElement+'│'+SKod));
     MarkaList^.SetRange(MarkaList^.List^.Count);
     End;
     End;
    End;{For}

  End;

if st[0]<>#0 Then
s:=Copy(st,Pos('│',st)+1,CArtikul)
Else
s:=NoMarkaStr;

RFormatZerro(s,CArtikul);
MarkaList^.FocusItem(Location(MarkaList,S,False));


MarkaList^.HelpCtx:=$F371;
MarkaWindow^.Insert(MarkaList);
PrevCurrentLine:=Copy(MarkaList^.GetText(MarkaList^.Focused,MarkaList^.List^.Count),1+CMarka+1,CArtikul);
MarkaWindow^.SelectNext(False);
MarkaWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;

c:=Desktop^.ExecView(MarkaWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Res in[2,3] Then
   St:=MarkaList^.GetText(MarkaList^.Focused,MarkaList^.List^.Count)
   Else St:=Bak;
1:
Dispose(COntrol,Done);
Dispose(COntrolCount,Done);
Dispose(MarkaWindow,Done);
end;



Procedure TMarkaWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  MarkaFile : File;
  MarkaElement : PBufMarkaType;
  c1,Count : Word;
  StopRead:Boolean;
begin
ClearFind;
DInfoMsg('Обновляю список ...',False);
Cod:=MarkaList^.Focused;

     MarkaList^.NewList(Nil);
     MarkaList^.NewList(New(PTextCollection, Init(0,1)));

FastRead:=False;
If (Compress=1) And (SprList[BMarka].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'Marka.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BMarka].Time)=L Then  FastRead:=True;
End;

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;

Assign (MarkaFile,Path^.Dat.ToSPR+'Marka.db');
c:=IOResult;
Reset (MarkaFile,SizeOf(MarkaType));
c:=IOResult;
If FileSize(MarkaFile)>jk Then
If CountElement=1 Then Seek(MarkaFile,jk);
c:=IOResult;
 StopRead:=False;
 FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(MarkaFile))And Not(StopRead) Do
 Begin
    New(MarkaElement,Init);
    ReadBufMarka(MarkaFile,MarkaElement,Count);
For c1:=1 To Count Do
Begin
  If MarkaElement^.Point.Dat[c1].Employ Then
   Begin
    Format (MarkaElement^.Point.Dat[c1].Marka,CMarka);
  If MarkaList^.List^.Count>=MaxCollectionSize-1 Then
   Begin
    StopRead:=True;
   End
  Else
  Begin
    MarkaList^.List^.Insert(NewStr(MarkaElement^.Point.Dat[c1].Marka+'│'+MarkaElement^.Point.Dat[c1].Kod));
    MarkaList^.SetRange(MarkaList^.List^.Count);
  End;
   End;
  If CountElement=0 Then
  If StrToInt(MarkaElement^.Point.Dat[c1].Kod)>=jk Then
   Begin
    StopRead:=True;
    Break;
   End;
End;{For}

  Dispose(MarkaElement,Done);
 End;
System.Close(MarkaFile);


End
Else
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам!',nil,mfError+mfCanCelButton);
  Exit;
 End;
End
 Else
  Begin
   If SprList[BMarka].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BMarka].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BMarka].Elements^.GetText(l,SprList[BMarka].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CMarka);
     Format (SElement,CMarka);
     MarkaList^.List^.Insert(NewStr(SElement+'│'+SKod));
     MarkaList^.SetRange(MarkaList^.List^.Count);
     End;
    End;{For}
  End;

If Cod<>0 Then Dec(Cod);

MarkaList^.FocusItem(Cod);
NoInfoMsg;

Redraw;
PrevCurrentLine[0]:=#0;
end;


Procedure TMarkaWindow.ImportSPR;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  MarkaFile : File;
  MarkaElement : PBufMarkaType;
  c1,Count : Word;
  txt : Text;
  SeparatorChar : AllStr;
begin
ClearFind;
SeparatorChar:=';';
DInfoMsg('Экпортирую марки ...',False);
Cod:=MarkaList^.Focused;


FastRead:=False;
If (Compress=1) And (SprList[BMarka].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'Marka.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BMarka].Time)=L Then  FastRead:=True;
End;


Assign(txt,Path^.Dat.ToTemp+'marka.csv');
c:=IOResult;
Rewrite(txt);
c:=IOResult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+'Ошибка создания '+Path^.Dat.ToTemp+'marka.csv'+' Код:'+IntToStr(c,ckol),Nil,mfError+mfCancelButton);
  Exit;
 End;
Writeln(txt,DosToWin('Код')+SeparatorChar+DosToWin(Seria_Akzis^));



If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;

Assign (MarkaFile,Path^.Dat.ToSPR+'Marka.db');
c:=IOResult;
Reset (MarkaFile,SizeOf(MarkaType));
c:=IOResult;
 FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(MarkaFile)) Do
 Begin
    New(MarkaElement,Init);
    ReadBufMarka(MarkaFile,MarkaElement,Count);
For c1:=1 To Count Do
Begin
  If MarkaElement^.Point.Dat[c1].Employ Then
   Begin
    RFormatZerro (MarkaElement^.Point.Dat[c1].Kod,CArtikul);
    ChangeSeparator(MarkaElement^.Point.Dat[c1].Marka);
    Writeln(txt,MarkaElement^.Point.Dat[c1].Kod+SeparatorChar+DosToWin(MarkaElement^.Point.Dat[c1].Marka));

   End;
End;{For}
  Dispose(MarkaElement,Done);
 End;
System.Close(MarkaFile);


End
Else
 Begin
  System.Close(txt);
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам!',nil,mfError+mfCanCelButton);
  Exit;
 End;
End
 Else
  Begin
   If SprList[BMarka].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BMarka].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BMarka].Elements^.GetText(l,SprList[BMarka].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CMarka);
     ChangeSeparator(SElement);
     Writeln(txt,SKod+SeparatorChar+DosToWin(SElement));
     End;
    End;{For}
  End;

NoInfoMsg;

c:=IOResult;
System.Close(txt);
c:=IOResult;

MessageBox(^M+#3'Данные успешно импортированы в '+Path^.Dat.ToTemp+'marka.csv!',Nil,
mfInformation+mfCancelButton);



Redraw;
end;





Destructor TMarkaWindow.Done;
Begin
ClearFind;
Dispose(MarkaList,Done);
TDialog.Done;
End;


procedure TMarkaWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   Art,cod : ArtikulStr;
    Op : StrNAme;
   MarkaElement : MarkaType;


Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=MarkaList^.GetText(MarkaList^.Focused,MarkaList^.List^.Count);
  s:=Copy(s,1+CMarka+1,CArtikul);

  R:=GetMarkaEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать марку с кодом '+s+'. Марка отмечена как удаленная!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End;

  If SetElementLock(FMarka,s,Op) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg('Марка ['+s+'] используется '+Op+'! Не могу заблокировать марку!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
   End;
End;


Function TestEmploy:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  TestEmploy:=False;
  s:=MarkaList^.GetText(MarkaList^.Focused,MarkaList^.List^.Count);
  s:=Copy(s,1+CMarka+1,CArtikul);

  r:=False;
  R:=GetMarkaEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Нельзя работать с маркой '+s+'. Марка отмечена как удаленная!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End
   Else
   TestEmploy:=True;
End;



Procedure UnlockAll;
Var  f : LockBazFileType;
     cl : LockBazType;
     r : Byte;
     cod : ArtikulStr;
Begin
DInfoMsg('Минуточку...',False);
Assign (F,Path^.Dat.ToSPR+'Marka.lck');

r:=IOResult;
Reset(f);
r:=IOResult;
If R<>0 Then
 Begin
  NoInfoMsg;
  Exit;
 End;

While Not(Eof(f)) Do
  Begin
   ReadLockBaz(f,Cl);
   r:=IOResult;

   cl.Locked:=False;
   Seek(f,FilePos(f)-1);
   r:=IOResult;

   Write(f,cl);
   r:=IOResult;

  End;
System.close(f);
   r:=IOResult;

NoInfoMsg;
AddProtocol('Общая деблокировка марок {сетевая безопасность транзакций}','','');
End;



begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbDel: Begin
If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

     L:=False;
     If (MarkaList^.State and sfFocused <> 0) And (MarkaList^.List<>Nil)And(MarkaList^.List^.Count>=2)
	Then L:=True;

     If L Then
            Begin
     If Password(5) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=MarkaList^.GetText(MarkaList^.Focused,MarkaList^.List^.Count);
                s:=Copy(s,1+CMarka+1,CArtikul);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=MarkaList^.GetText(MarkaList^.Focused,MarkaList^.List^.Count);
                 s:=Copy(s,1+CMarka+1,CArtikul);

                 Assign (MarkaFile,Path^.Dat.ToSPR+'Marka.db');
                 MarkaElement.Marka[0]:=#0;
                 MarkaElement.Kod:=s;
                 MarkaElement.Employ:=False;

  If Not (WriteLockMarka(MarkaElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлу марок!',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetElementUnLock(FMarka,s));
     ClearEvent(Event);
     Exit;
    End
    Else
     RefreshCashOneSPR(bMarka);


    Repeat
    Until (SetElementUnLock(FMarka,s));
    AddProtoCol('Удаление марки:'+s,'','');
    MarkaList^.List^.AtFree(MarkaList^.Focused);
    MarkaList^.SetRange(MarkaList^.List^.Count);
    If MarkaList^.Focused>0 Then   MarkaList^.FocusItem(MarkaList^.Focused);
    If (MarkaList^.Focused>=MarkaList^.List^.Count) and(MarkaList^.Focused>0) Then
    MarkaList^.FocusItem(MarkaList^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
          End;


kbAlt1         : If Password(5) Then UnlockAll;
kbF9           : CorrectMarka;
{временно выключено пока не написана процедура добавления нового региона}
kbGrayPlus,kbAltF1,kbF4:
Begin
L:=False;
If(MarkaList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(MarkaList^.List<>Nil)And(MarkaList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
      If AddMarka(Event.KeyCode,MarkaElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(MarkaList^.List<>Nil)And(MarkaList^.List^.Count>=1) Then
           MarkaList^.List^.AtFree(MarkaList^.Focused);
        Format(MarkaElement.Marka,CMarka);
        MarkaList^.List^.Insert(NewStr(MarkaElement.Marka+'│'+MarkaElement.Kod));
        MarkaList^.SetRange(MarkaList^.List^.Count);
        MarkaList^.FocusItem(LoCation(MarkaList,MarkaElement.Kod,False));
        Redraw;
       End
       Else
        Begin
         s:=MarkaList^.GetText(MarkaList^.Focused,MarkaList^.List^.Count);
         MarkaElement.Kod:=Copy(s,1+CMarka+1,CArtikul);
        End;

   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=MarkaElement.Kod;
    Repeat
    Until (SetElementUnLock(FMarka,Cod));
   End;
            ClearEvent(Event);
            Redraw;
            End;

      Else;
      End;{KeyDown}
evCommand:
 Case Event.Command Of
 cmRefresh: Refresh;
 cmReestrReport : ImportSPR;

 cmFindLink:Begin
             Art:=Copy(MarkaList^.GetText(MarkaList^.Focused,MarkaList^.List^.Count),1+CMarka+1,CArtikul);
             Lnk^.Start(Art);
             ClearEvent(Event);
            End;

  Else;
  End;{evCommand}
      Else;
      End;{*Case*}

  if ((Event.What = evMouseDown) and (Event.Double)) or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbEnter)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlEnter)){ Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbTab)) Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlRight))} Then
  begin
              Event.What:=evCommand;
              Event.Command:=cmOk;
              PutEvent(Event);
              ClearEvent(Event);
  end;
{
  if ((Event.What = evKeyDown) and (Event.KeyCode =kbShiftTab))Or
     ((Event.What = evKeyDown) and (Event.KeyCode =kbCtrlLeft)) Then
  begin

              Event.What:=evCommand;
              Event.Command:=cmYes;
              PutEvent(Event);
              ClearEvent(Event);

  end;
}
  if ((Event.What = evKeyDown) and (Event.KeyCode = kbEsc))then
  begin
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
  end;

 Case Event.What Of
 EvCommand : Begin
             Case Event.Command Of
 cmCancel,cmYes,cmOk,cmNo,cmClose,cmQuit
                     : Begin
                          If Not(TestEmploy) Then
                                   Begin
                                    ClearEvent(Event);
                                    Exit;
                                   End;
                       End;

             Else Exit;
             End;
             End;
 Else;
 End;


 if (Event.What = evBroadcast) and
     (Event.Command = cmSelectMarka) then ClearEvent(Event);

 if (Event.What = evBroadcast) and
     (Event.Command = cmViewSPRMarka) then ClearEvent(Event);


  inherited HandleEvent(Event);

  If (Desktop^.Current=PView(MarkaWindow)) And (Event.What <> EvKeyDown) Then
        Begin
                         if (ControlCount^.State and sfFocused <> 0)Then
                                  Begin
                                        ControlCount^.GetData(Test);

                                        If Test <> CountElement Then
                                        Begin
                                         CountElement:=Test;
                                         Refresh;
                                         Redraw;
                                        End;
                                  End;
         End;

  {
  If (Desktop^.Current=PView(MarkaWindow)) And (Event.What <> EvKeyDown) Then
          Begin
                If (Client^.List <> Nil) And (Marka^.List^.Count>=1) Then
                 Begin
                  s:=Marka^.GetText(Marka^.Focused,Marka^.List^.Count);
                  If s<>PrevCurrentLine Then
                   Begin
                    PrevCurrentLine:=S;
                    DrawCurrent;
                   End;
                 End;
          End;
  }
  ClearEvent(Event);
end;



Procedure TSpecMarkaWindow.ShowSpecMarkaList(Var st:String;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String;
  Bak : String;
  c: Word;
  c1,Count : Word;
  SpecMarkaFile : File;
  SpecMarkaElement : PBufSpecMarkaType;
begin
Bak :=St;
ClearFind;
DInfoMsg('Читаю списки...',False);

Res:=0;
R.Assign(30, 5, 79, 22);
New(SpecMarkaWindow, Init(R, 'Выбор специальной марки'));

R.Assign(48, 1, 49, 16);
Control := New(PScrollBar, Init(R));
SpecMarkaWindow^.Insert(Control);

R.Assign(1, 1, 48, 16);
SpecMarkaList := New(PBox, Init(R, 1, PScrollbar(Control)));
SpecMarkaList^.NewList(New(PTextCollection, Init(0,1)));

(*
Assign (SpecMarkaFile,Path^.Dat.ToClient+'.db');
c:=IOResult;
Reset (SpecMarkaFile,SizeOf(SpecMarkaType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(SpecMarkaFile)) Do
 Begin
    New(SpecMarkaElement,Init);
    ReadBufSpecMarka(SpecMarkaFile,SpecMarkaElement,Count);
For c1:=1 To Count Do
Begin
  If SpecMarkaElement^.Point.Dat[c1].Employ Then
   Begin
    Format (SpecMarkaElement^.Point.Dat[c1].SpecMarka,CSpecMarka);
    SpecMarkaList^.List^.Insert(NewStr(SpecMarkaElement^.Point.Dat[c1].SpecMarka+'│'+SpecMarkaElement^.Point.Dat[c1].Kod));
    SpecMarkaList^.SetRange(SpecMarkaList^.List^.Count);
   End;
End;{For}
  Dispose(SpecMarkaElement,Done);
 End;{While}
System.Close(SpecMarkaFile);
End
Else
 Begin
  St:=BAk;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
s:=Copy(st,1+CSpecMarka+1,CClientKod);
SpecMarkaList^.FocusItem(Location(SpecMarkaList,S,False));
SpecMarkaList^.HelpCtx:=$E171;
SpecMarkaWindow^.Insert(SpecMarkaList);
PrevCurrentLine:=Copy(SpecMarkaList^.GetText(SpecMarkaList^.Focused,SpecMarkaList^.List^.Count),1+CSpecMarka+1,CClientKod);

SpecMarkaWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;
*)

FastRead:=False;
If (Compress=1) And (SprList[BSMarka].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'SMarka.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BSMarka].Time)=L Then  FastRead:=True;
End;

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
Assign (SpecMarkaFile,Path^.Dat.ToSPR+'SMarka.db');
c:=IOResult;
Reset (SpecMarkaFile,SizeOf(SpecMarkaType));
c:=IOResult;
 FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(SpecMarkaFile)) Do
 Begin
    New(SpecMarkaElement,Init);
    ReadBufSpecMarka(SpecMarkaFile,SpecMarkaElement,Count);
For c1:=1 To Count Do
Begin
  If SpecMarkaElement^.Point.Dat[c1].Employ Then
   Begin
    Format (SpecMarkaElement^.Point.Dat[c1].SpecMarka,CMarka);
    SpecMarkaList^.List^.Insert(NewStr(SpecMarkaElement^.Point.Dat[c1].SpecMarka+'│'+SpecMarkaElement^.Point.Dat[c1].Kod));
    SpecMarkaList^.SetRange(SpecMarkaList^.List^.Count);
   End;
End;{For}
  Dispose(SpecMarkaElement,Done);
 End;{While}
System.Close(SpecMarkaFile);
End
Else
 Begin
  st:=Bak;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
End
 Else
  Begin
   If SprList[BSMarka].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BSMarka].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BSMarka].Elements^.GetText(l,SprList[BSMarka].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CMarka);
     Format (SElement,CMarka);
     SpecMarkaList^.List^.Insert(NewStr(SElement+'│'+SKod));
     SpecMarkaList^.SetRange(SpecMarkaList^.List^.Count);
     End;
    End;{For}
  End;

if st[0]<>#0 Then
s:=Copy(st,Pos('│',st)+1,CArtikul)
Else
s:=NoMarkaStr;

RFormatZerro(s,CArtikul);
SpecMarkaList^.FocusItem(Location(SpecMarkaList,S,False));


SpecMarkaList^.HelpCtx:=$F371;
SpecMarkaWindow^.Insert(SpecMarkaList);
PrevCurrentLine:=Copy(SpecMarkaList^.GetText(SpecMarkaList^.Focused,SpecMarkaList^.List^.Count),1+CMarka+1,CArtikul);
SpecMarkaWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;

c:=Desktop^.ExecView(SpecMarkaWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Res in[2,3] Then
   St:=SpecMarkaList^.GetText(SpecMarkaList^.Focused,SpecMarkaList^.List^.Count)
   Else St:=Bak;
1:
Dispose(COntrol,Done);
Dispose(SpecMarkaWindow,Done);
end;



Procedure TSpecMarkaWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  SpecMarkaFile : File;
  SpecMarkaElement : PBufSpecMarkaType;
  c1,Count : Word;
begin
ClearFind;
DInfoMsg('Обновляю список ...',False);
Cod:=SpecMarkaList^.Focused;

     SpecMarkaList^.NewList(Nil);
     SpecMarkaList^.NewList(New(PTextCollection, Init(0,1)));

FastRead:=False;
If (Compress=1) And (SprList[BSMarka].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'SMarka.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BSMarka].Time)=L Then  FastRead:=True;
End;

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;


Assign (SpecMarkaFile,Path^.Dat.ToSPR+'SMarka.db');
c:=IOResult;
Reset (SpecMarkaFile,SizeOf(SpecMarkaType));
c:=IOResult;
 FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(SpecMarkaFile)) Do
 Begin
    New(SpecMarkaElement,Init);
    ReadBufSpecMarka(SpecMarkaFile,SpecMarkaElement,Count);
For c1:=1 To Count Do
Begin
  If SpecMarkaElement^.Point.Dat[c1].Employ Then
   Begin
    Format (SpecMarkaElement^.Point.Dat[c1].SpecMarka,CMarka);
    SpecMarkaList^.List^.Insert(NewStr(SpecMarkaElement^.Point.Dat[c1].SpecMarka+'│'+SpecMarkaElement^.Point.Dat[c1].Kod));
    SpecMarkaList^.SetRange(SpecMarkaList^.List^.Count);
   End;
End;{For}
  Dispose(SpecMarkaElement,Done);
 End;
System.Close(SpecMarkaFile);


End
Else
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
End
 Else
  Begin
   If SprList[BSMarka].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BSMarka].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BSMarka].Elements^.GetText(l,SprList[BSMarka].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CMarka);
     Format (SElement,CMarka);
     SpecMarkaList^.List^.Insert(NewStr(SElement+'│'+SKod));
     SpecMarkaList^.SetRange(SpecMarkaList^.List^.Count);
     End;
    End;{For}
  End;

If Cod<>0 Then Dec(Cod);

SpecMarkaList^.FocusItem(Cod);
NoInfoMsg;

Redraw;
PrevCurrentLine[0]:=#0;
end;


Procedure TSpecMarkaWindow.ImportSPR;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  SpecMarkaFile : File;
  SpecMarkaElement : PBufSpecMarkaType;
  c1,Count : Word;
  txt : Text;
  SeparatorChar :AllStr;
begin
ClearFind;
DInfoMsg('Экспортирую спец.марки ...',False);
SeparatorChar:=';';

FastRead:=False;
If (Compress=1) And (SprList[BSMarka].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'SMarka.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BSMarka].Time)=L Then  FastRead:=True;
End;


Assign(txt,Path^.Dat.ToTemp+'smarka.csv');
c:=IOResult;
Rewrite(txt);
c:=IOResult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+'Ошибка создания '+Path^.Dat.ToTemp+'smarka.csv'+' Код:'+IntToStr(c,ckol),Nil,mfError+mfCancelButton);
  Exit;
 End;
Writeln(txt,DosToWin('Код')+SeparatorChar+DosToWin('Спец.марка'));



If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;


Assign (SpecMarkaFile,Path^.Dat.ToSPR+'SMarka.db');
c:=IOResult;
Reset (SpecMarkaFile,SizeOf(SpecMarkaType));
c:=IOResult;
 FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(SpecMarkaFile)) Do
 Begin
    New(SpecMarkaElement,Init);
    ReadBufSpecMarka(SpecMarkaFile,SpecMarkaElement,Count);
For c1:=1 To Count Do
Begin
  If SpecMarkaElement^.Point.Dat[c1].Employ Then
   Begin
    RFormatZerro (SpecMarkaElement^.Point.Dat[c1].Kod,CArtikul);
    ChangeSeparator(SpecMarkaElement^.Point.Dat[c1].SpecMarka);
    Writeln(txt,SpecMarkaElement^.Point.Dat[c1].Kod+SeparatorChar+DosToWin(SpecMarkaElement^.Point.Dat[c1].SpecMarka));
   End;
End;{For}
  Dispose(SpecMarkaElement,Done);
 End;
System.Close(SpecMarkaFile);


End
Else
 Begin
  System.Close(txt);
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
End
 Else
  Begin
   If SprList[BSMarka].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BSMarka].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BSMarka].Elements^.GetText(l,SprList[BSMarka].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CMarka);
     ChangeSeparator(SElement);
     Writeln(txt,SKod+SeparatorChar+DosToWin(SElement));
     End;
    End;{For}
  End;

c:=IoResult;
System.Close(txt);
c:=IoResult;

NoInfoMsg;

MessageBox(^M+#3'Данные успешно импортированы в '+Path^.Dat.ToTemp+'smarka.csv!',Nil,
mfInformation+mfCancelButton);

Redraw;


end;



Destructor TSpecMarkaWindow.Done;
Begin
ClearFind;
Dispose(SpecMarkaList,Done);
TDialog.Done;
End;


procedure TSpecMarkaWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;
    Op : StrNAme;
   SpecMarkaElement : SpecMarkaType;

Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=SpecMarkaList^.GetText(SpecMarkaList^.Focused,SpecMarkaList^.List^.Count);
  s:=Copy(s,1+CMarka+1,CArtikul);

  R:=GetSpecMarkaEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать марку с кодом '+s+'. Марка отмечена как удаленная!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End;

  If SetElementLock(FSpecMarka,s,Op) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg('Элемент ['+s+'] используется '+Op+'! Не могу заблокировать элемент!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
   End;
End;


Function TestEmploy:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  TestEmploy:=False;
  s:=SpecMarkaList^.GetText(SpecMarkaList^.Focused,SpecMarkaList^.List^.Count);
  s:=Copy(s,1+CMarka+1,CArtikul);

  r:=False;
  R:=GetSpecMarkaEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Нельзя работать с маркой '+s+'. Марка отмечена как удаленная!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End
   Else
   TestEmploy:=True;
End;



Procedure UnlockAll;
Var  f : LockBazFileType;
     cl : LockBazType;
     r : Byte;
     cod : ArtikulStr;
Begin
DInfoMsg('Минуточку...',False);
Assign (F,Path^.Dat.ToSPR+'SMarka.lck');

r:=IOResult;
Reset(f);
r:=IOResult;
If R<>0 Then
 Begin
  NoInfoMsg;
  Exit;
 End;

While Not(Eof(f)) Do
  Begin
   ReadLockBaz(f,Cl);
   r:=IOResult;

   cl.Locked:=False;
   Seek(f,FilePos(f)-1);
   r:=IOResult;

   Write(f,cl);
   r:=IOResult;

  End;
System.close(f);
   r:=IOResult;

NoInfoMsg;
AddProtocol('Общая деблокировка спец.марок {сетевая безопасность транзакций}','','');
End;



begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbDel: Begin

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

     L:=False;
     If (SpecMarkaList^.State and sfFocused <> 0) And (SpecMarkaList^.List<>Nil)And(SpecMarkaList^.List^.Count>=2)
	Then L:=True;

     If L Then
            Begin
     If Password(5) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=SpecMarkaList^.GetText(SpecMarkaList^.Focused,SpecMarkaList^.List^.Count);
                s:=Copy(s,1+CMarka+1,CArtikul);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=SpecMarkaList^.GetText(SpecMarkaList^.Focused,SpecMarkaList^.List^.Count);
                 s:=Copy(s,1+CMarka+1,CArtikul);

                 Assign (SpecMarkaFile,Path^.Dat.ToSPR+'SMarka.db');
                 SpecMarkaElement.SpecMarka[0]:=#0;
                 SpecMarkaElement.Kod:=s;
                 SpecMarkaElement.Employ:=False;

  If Not (WriteLockSpecMarka(SpecMarkaElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлу спец.марок!',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetElementUnLock(FSpecMarka,s));
     ClearEvent(Event);
     Exit;
    End
    Else
     RefreshCashOneSPR(bSMarka);


    Repeat
    Until (SetElementUnLock(FSpecMarka,s));
    AddProtoCol('Удаление спец.марки:'+s,'','');
    SpecMarkaList^.List^.AtFree(SpecMarkaList^.Focused);
    SpecMarkaList^.SetRange(SpecMarkaList^.List^.Count);
    If SpecMarkaList^.Focused>0 Then   SpecMarkaList^.FocusItem(SpecMarkaList^.Focused);
    If (SpecMarkaList^.Focused>=SpecMarkaList^.List^.Count) and(SpecMarkaList^.Focused>0) Then
    SpecMarkaList^.FocusItem(SpecMarkaList^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
          End;


kbAlt1         : If Password(5) Then UnlockAll;
kbF9           : CorrectSMarka;

{временно выключено пока не написана процедура добавления нового региона}
kbGrayPlus,kbAltF1,kbF4:
Begin
L:=False;
If(SpecMarkaList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(SpecMarkaList^.List<>Nil)And(SpecMarkaList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
      If AddSpecMarka(Event.KeyCode,SpecMarkaElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(SpecMarkaList^.List<>Nil)And(SpecMarkaList^.List^.Count>=1) Then
           SpecMarkaList^.List^.AtFree(SpecMarkaList^.Focused);
        Format(SpecMarkaElement.SpecMarka,CMarka);
        SpecMarkaList^.List^.Insert(NewStr(SpecMarkaElement.SpecMarka+'│'+SpecMarkaElement.Kod));
        SpecMarkaList^.SetRange(SpecMarkaList^.List^.Count);
        SpecMarkaList^.FocusItem(LoCation(SpecMarkaList,SpecMarkaElement.Kod,False));
        Redraw;
       End
       Else
        Begin
         s:=SpecMarkaList^.GetText(SpecMarkaList^.Focused,SpecMarkaList^.List^.Count);
         SpecMarkaElement.Kod:=Copy(s,1+CMarka+1,CArtikul);
        End;

   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=SpecMarkaElement.Kod;
    Repeat
    Until (SetElementUnLock(FSpecMarka,Cod));
   End;
            ClearEvent(Event);
            Redraw;
            End;

      Else;
      End;{KeyDown}
evCommand:
 Case Event.Command Of
 cmRefresh: Refresh;
 cmReestrReport : ImportSPR;
 cmFindLink:Begin
             cod:=Copy(SpecMarkaList^.GetText(SpecMarkaList^.Focused,SpecMarkaList^.List^.Count),1+CMarka+1,CArtikul);
             Lnk^.Start(cod);
             ClearEvent(Event);
            End;
  Else;
  End;{evCommand}
      Else;
      End;{*Case*}

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

 Case Event.What Of
 EvCommand : Begin
             Case Event.Command Of
 cmCancel,cmYes,cmOk,cmNo,cmClose,cmQuit
                     : Begin
                          If Not(TestEmploy) Then
                                   Begin
                                    ClearEvent(Event);
                                    Exit;
                                   End;
                       End;

             Else Exit;
             End;
             End;
 Else;
 End;


 if (Event.What = evBroadcast) and
     (Event.Command = cmSelectSpecMarka) then ClearEvent(Event);

 if (Event.What = evBroadcast) and
     (Event.Command = cmViewSPRSpecMarka) then ClearEvent(Event);


  inherited HandleEvent(Event);

  ClearEvent(Event);
end;



Procedure TNGTDWindow.ShowNGTDList(Var st:String;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String;
  Bak : String;
  c: Word;
  c1,Count : Word;
  NGTDFile : File;
  NGTDElement : PBufNGTDType;
begin
Bak :=St;
ClearFind;
DInfoMsg('Читаю списки...',False);

Res:=0;
R.Assign(30, 5, 79, 22);
New(NGTDWindow, Init(R, 'Выбор ГТД'));

R.Assign(48, 1, 49, 16);
Control := New(PScrollBar, Init(R));
NGTDWindow^.Insert(Control);

R.Assign(1, 1, 48, 16);
NGTDList := New(PBox, Init(R, 1, PScrollbar(Control)));
NGTDList^.NewList(New(PTextCollection, Init(0,1)));

(*
Assign (NGTDFile,Path^.Dat.ToClient+'.db');
c:=IOResult;
Reset (NGTDFile,SizeOf(NGTDType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(NGTDFile)) Do
 Begin
    New(NGTDElement,Init);
    ReadBufNGTD(NGTDFile,NGTDElement,Count);
For c1:=1 To Count Do
Begin
  If NGTDElement^.Point.Dat[c1].Employ Then
   Begin
    Format (NGTDElement^.Point.Dat[c1].NGTD,CNGTD);
    NGTDList^.List^.Insert(NewStr(NGTDElement^.Point.Dat[c1].NGTD+'│'+NGTDElement^.Point.Dat[c1].Kod));
    NGTDList^.SetRange(NGTDList^.List^.Count);
   End;
End;{For}
  Dispose(NGTDElement,Done);
 End;{While}
System.Close(NGTDFile);
End
Else
 Begin
  St:=BAk;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
s:=Copy(st,1+CNGTD+1,CClientKod);
NGTDList^.FocusItem(Location(NGTDList,S,False));
NGTDList^.HelpCtx:=$E171;
NGTDWindow^.Insert(NGTDList);
PrevCurrentLine:=Copy(NGTDList^.GetText(NGTDList^.Focused,NGTDList^.List^.Count),1+CNGTD+1,CClientKod);

NGTDWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;
*)

FastRead:=False;
If (Compress=1) And (SprList[Bngtd].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'ngtd.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[Bngtd].Time)=L Then  FastRead:=True;
End;

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;

Assign (NGTDFile,Path^.Dat.ToSPR+'NGTD.db');
c:=IOResult;
Reset (NGTDFile,SizeOf(NGTDType));
c:=IOResult;
FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(NGTDFile)) Do
 Begin
    New(NGTDElement,Init);
    ReadBufNGTD(NGTDFile,NGTDElement,Count);
For c1:=1 To Count Do
Begin
  If NGTDElement^.Point.Dat[c1].Employ Then
   Begin
    Format (NGTDElement^.Point.Dat[c1].NGTD,CNGTD);
    NGTDList^.List^.Insert(NewStr(NGTDElement^.Point.Dat[c1].NGTD+'│'+NGTDElement^.Point.Dat[c1].Kod));
    NGTDList^.SetRange(NGTDList^.List^.Count);
   End;
End;{For}
  Dispose(NGTDElement,Done);
 End;{While}
System.Close(NGTDFile);
End
Else
 Begin
  st:=Bak;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
End
 Else
  Begin
   If SprList[Bngtd].Elements^.List^.Count>0 Then
   For l:=0 To SprList[Bngtd].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[Bngtd].Elements^.GetText(l,SprList[Bngtd].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,Cngtd);
     Format (SElement,Cngtd);
     ngtdList^.List^.Insert(NewStr(SElement+'│'+SKod));
     ngtdList^.SetRange(ngtdList^.List^.Count);
     End;
    End;{For}
  End;

if st[0]<>#0 Then
s:=Copy(st,Pos('│',st)+1,CArtikul)
Else
s:=NoNGTDStr;
RFormatZerro(s,CArtikul);
NGTDList^.FocusItem(Location(NGTDList,S,False));


NGTDList^.HelpCtx:=$F371;
NGTDWindow^.Insert(NGTDList);
PrevCurrentLine:=Copy(NGTDList^.GetText(NGTDList^.Focused,NGTDList^.List^.Count),1+CNGTD+1,CArtikul);
NGTDWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;

c:=Desktop^.ExecView(NGTDWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Res in[2,3] Then
   St:=NGTDList^.GetText(NGTDList^.Focused,NGTDList^.List^.Count)
   Else St:=Bak;
1:
Dispose(COntrol,Done);
Dispose(NGTDWindow,Done);
end;



Procedure TNGTDWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  NGTDFile : File;
  NGTDElement : PBufNGTDType;
  c1,Count : Word;
begin
ClearFind;
DInfoMsg('Обновляю список ...',False);
Cod:=NGTDList^.Focused;

     NGTDList^.NewList(Nil);
     NGTDList^.NewList(New(PTextCollection, Init(0,1)));
FastRead:=False;
If (Compress=1) And (SprList[Bngtd].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'ngtd.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[Bngtd].Time)=L Then  FastRead:=True;
End;

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;


Assign (NGTDFile,Path^.Dat.ToSPR+'NGTD.db');
c:=IOResult;
Reset (NGTDFile,SizeOf(NGTDType));
c:=IOResult;
 FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(NGTDFile)) Do
 Begin
    New(NGTDElement,Init);
    ReadBufNGTD(NGTDFile,NGTDElement,Count);
For c1:=1 To Count Do
Begin
  If NGTDElement^.Point.Dat[c1].Employ Then
   Begin
    Format (NGTDElement^.Point.Dat[c1].NGTD,CNGTD);
    NGTDList^.List^.Insert(NewStr(NGTDElement^.Point.Dat[c1].NGTD+'│'+NGTDElement^.Point.Dat[c1].Kod));
    NGTDList^.SetRange(NGTDList^.List^.Count);
   End;
End;{For}
  Dispose(NGTDElement,Done);
 End;
System.Close(NGTDFile);


End
Else
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
End
 Else
  Begin
   If SprList[Bngtd].Elements^.List^.Count>0 Then
   For l:=0 To SprList[Bngtd].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[Bngtd].Elements^.GetText(l,SprList[Bngtd].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,Cngtd);
     Format (SElement,Cngtd);
     ngtdList^.List^.Insert(NewStr(SElement+'│'+SKod));
     ngtdList^.SetRange(ngtdList^.List^.Count);
     End;
    End;{For}
  End;

If Cod<>0 Then Dec(Cod);

NGTDList^.FocusItem(Cod);
NoInfoMsg;

Redraw;
PrevCurrentLine[0]:=#0;
end;


Procedure TNGTDWindow.ImportSPR;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  NGTDFile : File;
  NGTDElement : PBufNGTDType;
  c1,Count : Word;
  txt : Text;
  SeparatorChar: ArtikulStr;
begin
ClearFind;
DInfoMsg('Экспортирую ГТД ...',False);
SeparatorChar:=';';
FastRead:=False;
If (Compress=1) And (SprList[Bngtd].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'ngtd.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[Bngtd].Time)=L Then  FastRead:=True;
End;


Assign(txt,Path^.Dat.ToTemp+'ngtd.csv');
c:=IOResult;
Rewrite(txt);
c:=IOResult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+'Ошибка создания '+Path^.Dat.ToTemp+'ngtd.csv'+' Код:'+IntToStr(c,ckol),Nil,mfError+mfCancelButton);
  Exit;
 End;
Writeln(txt,DosToWin('Код')+SeparatorChar+DosToWin('ГТД'));


If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;


Assign (NGTDFile,Path^.Dat.ToSPR+'NGTD.db');
c:=IOResult;
Reset (NGTDFile,SizeOf(NGTDType));
c:=IOResult;
 FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(NGTDFile)) Do
 Begin
    New(NGTDElement,Init);
    ReadBufNGTD(NGTDFile,NGTDElement,Count);
For c1:=1 To Count Do
Begin
  If NGTDElement^.Point.Dat[c1].Employ Then
   Begin
    RFormatZerro(NGTDElement^.Point.Dat[c1].Kod,CArtikul);
    ChangeSeparator(NGTDElement^.Point.Dat[c1].NGTD);
    Writeln(txt,NGTDElement^.Point.Dat[c1].Kod+SeparatorChar+DosToWin(NGTDElement^.Point.Dat[c1].NGTD));
   End;
End;{For}
  Dispose(NGTDElement,Done);
 End;
System.Close(NGTDFile);


End
Else
 Begin
  System.Close(Txt);
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
End
 Else
  Begin
   If SprList[Bngtd].Elements^.List^.Count>0 Then
   For l:=0 To SprList[Bngtd].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[Bngtd].Elements^.GetText(l,SprList[Bngtd].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,Cngtd);
     ChangeSeparator(SElement);
     Writeln(txt,SKod+SeparatorChar+DosToWin(SElement));
     End;
    End;{For}
  End;

NoInfoMsg;

c:=IOResult;
System.Close(txt);
c:=IOResult;

MessageBox(^M+#3'Данные успешно импортированы в '+Path^.Dat.ToTemp+'ngtd.csv!',Nil,
mfInformation+mfCancelButton);

Redraw;
end;





Destructor TNGTDWindow.Done;
Begin
ClearFind;
Dispose(NGTDList,Done);
TDialog.Done;
End;


procedure TNGTDWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;
    Op : StrNAme;
   NGTDElement : NGTDType;

Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=NGTDList^.GetText(NGTDList^.Focused,NGTDList^.List^.Count);
  s:=Copy(s,1+CNGTD+1,CArtikul);

  R:=GetNGTDEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать ГТД с кодом '+s+'. ГТД отмечена как удаленная!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End;

  If SetElementLock(FNGTD,s,Op) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg('ГТД ['+s+'] используется '+Op+'! Не могу заблокировать марку!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
   End;
End;


Function TestEmploy:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  TestEmploy:=False;
  s:=NGTDList^.GetText(NGTDList^.Focused,NGTDList^.List^.Count);
  s:=Copy(s,1+CNGTD+1,CArtikul);

  r:=False;
  R:=GetNGTDEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Нельзя работать с ГТД '+s+'. ГТД отмечена как удаленная!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End
   Else
   TestEmploy:=True;
End;



Procedure UnlockAll;
Var  f : LockBazFileType;
     cl : LockBazType;
     r : Byte;
     cod : ArtikulStr;
Begin
DInfoMsg('Минуточку...',False);
Assign (F,Path^.Dat.ToSPR+'NGTD.lck');

r:=IOResult;
Reset(f);
r:=IOResult;
If R<>0 Then
 Begin
  NoInfoMsg;
  Exit;
 End;

While Not(Eof(f)) Do
  Begin
   ReadLockBaz(f,Cl);
   r:=IOResult;

   cl.Locked:=False;
   Seek(f,FilePos(f)-1);
   r:=IOResult;

   Write(f,cl);
   r:=IOResult;

  End;
System.close(f);
   r:=IOResult;

NoInfoMsg;
AddProtocol('Общая деблокировка ГТД {сетевая безопасность транзакций}','','');
End;



begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbDel: Begin

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

     L:=False;
     If (NGTDList^.State and sfFocused <> 0) And (NGTDList^.List<>Nil)And(NGTDList^.List^.Count>=2)
	Then L:=True;

     If L Then
            Begin
     If Password(5) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=NGTDList^.GetText(NGTDList^.Focused,NGTDList^.List^.Count);
                s:=Copy(s,1+CNGTD+1,CArtikul);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=NGTDList^.GetText(NGTDList^.Focused,NGTDList^.List^.Count);
                 s:=Copy(s,1+CNGTD+1,CArtikul);

                 Assign (NGTDFile,Path^.Dat.ToSPR+'NGTD.db');
                 NGTDElement.NGTD[0]:=#0;
                 NGTDElement.Kod:=s;
                 NGTDElement.Employ:=False;

  If Not (WriteLockNGTD(NGTDElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлу ГТД!',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetElementUnLock(FNGTD,s));
     ClearEvent(Event);
     Exit;
    End
    Else
     RefreshCashOneSPR(bNGTD);


    Repeat
    Until (SetElementUnLock(FNGTD,s));
    AddProtoCol('Удаление ГТД:'+s,'','');
    NGTDList^.List^.AtFree(NGTDList^.Focused);
    NGTDList^.SetRange(NGTDList^.List^.Count);
    If NGTDList^.Focused>0 Then   NGTDList^.FocusItem(NGTDList^.Focused);
    If (NGTDList^.Focused>=NGTDList^.List^.Count) and(NGTDList^.Focused>0) Then
    NGTDList^.FocusItem(NGTDList^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
          End;


kbAlt1         : If Password(5) Then UnlockAll;
kbF9           : CorrectNGTD;

{временно выключено пока не написана процедура добавления нового региона}
kbGrayPlus,kbAltF1,kbF4:
Begin
L:=False;
If(NGTDList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(NGTDList^.List<>Nil)And(NGTDList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
      If AddNGTD(Event.KeyCode,NGTDElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(NGTDList^.List<>Nil)And(NGTDList^.List^.Count>=1) Then
           NGTDList^.List^.AtFree(NGTDList^.Focused);
        Format(NGTDElement.NGTD,CNGTD);
        NGTDList^.List^.Insert(NewStr(NGTDElement.NGTD+'│'+NGTDElement.Kod));
        NGTDList^.SetRange(NGTDList^.List^.Count);
        NGTDList^.FocusItem(LoCation(NGTDList,NGTDElement.Kod,False));
        Redraw;
       End
       Else
        Begin
         s:=NGTDList^.GetText(NGTDList^.Focused,NGTDList^.List^.Count);
         NGTDElement.Kod:=Copy(s,1+CNGTD+1,CArtikul);
        End;

   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=NGTDElement.Kod;
    Repeat
    Until (SetElementUnLock(FNGTD,Cod));
   End;
            ClearEvent(Event);
            Redraw;
            End;

      Else;
      End;{KeyDown}
evCommand:
 Case Event.Command Of
 cmRefresh: Refresh;
 cmReestrReport : ImportSPR;
 cmFindLink:Begin
             cod:=Copy(NGTDList^.GetText(NGTDList^.Focused,NGTDList^.List^.Count),1+CNGTD+1,CArtikul);
             Lnk^.Start(cod);
             ClearEvent(Event);
            End;
  Else;
  End;{evCommand}
      Else;
      End;{*Case*}

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

 Case Event.What Of
 EvCommand : Begin
             Case Event.Command Of
 cmCancel,cmYes,cmOk,cmNo,cmClose,cmQuit
                     : Begin
                          If Not(TestEmploy) Then
                                   Begin
                                    ClearEvent(Event);
                                    Exit;
                                   End;
                       End;

             Else Exit;
             End;
             End;
 Else;
 End;


 if (Event.What = evBroadcast) and
     (Event.Command = cmSelectNGTD) then ClearEvent(Event);

 if (Event.What = evBroadcast) and
     (Event.Command = cmViewSPRNGTD) then ClearEvent(Event);


  inherited HandleEvent(Event);
  ClearEvent(Event);
end;



Procedure TClassWindow.ShowClassList(Var st:String;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String;
  Bak : String;
  c: Word;
  c1,Count : Word;
  ClassFile : File;
  ClassElement : PBufClassificatorBuchType;
begin
Bak :=St;
ClearFind;
DInfoMsg('Читаю списки...',False);

Res:=0;
R.Assign(10, 5, 79, 22);
New(ClassWindow, Init(R, 'Выбор класса'));

R.Assign(68, 1, 69, 16);
Control := New(PScrollBar, Init(R));
ClassWindow^.Insert(Control);

R.Assign(1, 1, 68, 16);
ClassList := New(PBox, Init(R, 1, PScrollbar(Control)));
ClassList^.NewList(New(PTextCollection, Init(0,1)));
(*
Assign (ClassFile,Path^.Dat.ToSPR+'Firma.db');
c:=IOResult;
Reset (ClassFile,SizeOf(ClassType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(ClassFile)) Do
 Begin
    New(ClassElement,Init);
    ReadBufClass(ClassFile,ClassElement,Count);
For c1:=1 To Count Do
Begin
  If ClassElement^.Point.Dat[c1].Employ Then
   Begin
    Format (ClassElement^.Point.Dat[c1].Class,CAll+16);
    ClassList^.List^.Insert(NewStr(ClassElement^.Point.Dat[c1].Class+'│'+ClassElement^.Point.Dat[c1].Kod));
    ClassList^.SetRange(ClassList^.List^.Count);
   End;
End;{For}
  Dispose(ClassElement,Done);
 End;{While}
System.Close(ClassFile);
End
Else
 Begin
  St:=BAk;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
s:=Copy(st,1+CAll+16+1,CClientKod);
ClassList^.FocusItem(Location(ClassList,S,False));
ClassList^.HelpCtx:=$E171;
ClassWindow^.Insert(ClassList);
PrevCurrentLine:=Copy(ClassList^.GetText(ClassList^.Focused,ClassList^.List^.Count),1+CAll+16+1,CClientKod);

ClassWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;
*)
FastRead:=False;
If (Compress=1) And (SprList[bClass].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'Class.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BClass].Time)=L Then  FastRead:=True;
End;

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
Assign (ClassFile,Path^.Dat.ToSPR+'Class.db');
c:=IOResult;
Reset (ClassFile,SizeOf(ClassificatorBuchType));
c:=IOResult;
 FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(ClassFile)) Do
 Begin
    New(ClassElement,Init);
    ReadBufClass(ClassFile,ClassElement,Count);
For c1:=1 To Count Do
Begin
  If ClassElement^.Point.Dat[c1].Employ Then
   Begin
    Format (ClassElement^.Point.Dat[c1].Name,CAll+16);
    ClassList^.List^.Insert(NewStr(ClassElement^.Point.Dat[c1].Name+'│'+ClassElement^.Point.Dat[c1].Kod));
    ClassList^.SetRange(ClassList^.List^.Count);
   End;
End;{For}
  Dispose(ClassElement,Done);
 End;{While}
System.Close(ClassFile);
End
Else
 Begin
  st:=Bak;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
End{}
 Else
  Begin{FAstRead=True}
   If SprList[BClass].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BClass].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BClass].Elements^.GetText(l,SprList[BClass].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     System.Delete(SKod,1,1);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CAll+16);
     Format (SElement,CAll+16);
     ClassList^.List^.Insert(NewStr(SElement+'│'+SKod));
     ClassList^.SetRange(ClassList^.List^.Count);
     End;
    End;{For}
  End;

if st[0]<>#0 Then
s:=Copy(st,1+CName+1,CClientKod)
Else
s:=NoClassStr;

RFormatZerro(s,CClientKod);
ClassList^.FocusItem(Location(ClassList,S,False));


ClassList^.HelpCtx:=$F371;
ClassWindow^.Insert(ClassList);
PrevCurrentLine:=Copy(ClassList^.GetText(ClassList^.Focused,ClassList^.List^.Count),1+CAll+16+1,CClientKod);
ClassWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;

c:=Desktop^.ExecView(ClassWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Res in[2,3] Then
   St:=ClassList^.GetText(ClassList^.Focused,ClassList^.List^.Count)
   Else St:=Bak;
1:
Dispose(Control,Done);
Dispose(ClassWindow,Done);
end;



Procedure TClassWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  ClassFile : File;
  ClassElement : PBufClassificatorBuchType;
  c1,Count : Word;
begin
ClearFind;
DInfoMsg('Обновляю список классов...',False);
Cod:=ClassList^.Focused;

     ClassList^.NewList(Nil);
     ClassList^.NewList(New(PTextCollection, Init(0,1)));

FastRead:=False;
If (Compress=1) And (SprList[bClass].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'Class.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BClass].Time)=L Then  FastRead:=True;
End;

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;


Assign (ClassFile,Path^.Dat.ToSPR+'Class.db');
c:=IOResult;
Reset (ClassFile,SizeOf(ClassificatorBuchType));
c:=IOResult;
 FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(ClassFile)) Do
 Begin
    New(ClassElement,Init);
    ReadBufClass(ClassFile,ClassElement,Count);
For c1:=1 To Count Do
Begin
  If ClassElement^.Point.Dat[c1].Employ Then
   Begin
    Format (ClassElement^.Point.Dat[c1].Name,CAll+16);
    ClassList^.List^.Insert(NewStr(ClassElement^.Point.Dat[c1].Name+'│'+ClassElement^.Point.Dat[c1].Kod));
    ClassList^.SetRange(ClassList^.List^.Count);
   End;
End;{For}
  Dispose(ClassElement,Done);
 End;
System.Close(ClassFile);

End
Else
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
End{}
 Else
  Begin{FAstRead=True}
   {MemC(IntToStr(SprList[BClass].Elements^.List^.Count,CKol));}
   If SprList[BClass].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BClass].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BClass].Elements^.GetText(l,SprList[BClass].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     System.Delete(SKod,1,1);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CAll+16);
     Format (SElement,CAll+16);
     ClassList^.List^.Insert(NewStr(SElement+'│'+SKod));
     ClassList^.SetRange(ClassList^.List^.Count);
     End;
    End;{For}
  End;

If Cod<>0 Then Dec(Cod);

ClassList^.FocusItem(Cod);
NoInfoMsg;

Redraw;
PrevCurrentLine[0]:=#0;
end;


Procedure TClassWindow.ImportSPR;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  ClassFile : File;
  ClassElement : PBufClassificatorBuchType;
  c1,Count : Word;
  txt : Text;
  SeparatorChar : ArtikulStr;
begin
ClearFind;
SeparatorChar:=';';
DInfoMsg('Экспортирую список классов...',False);

FastRead:=False;
If (Compress=1) And (SprList[bClass].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'Class.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BClass].Time)=L Then  FastRead:=True;
End;


Assign(txt,Path^.Dat.ToTemp+'class.csv');
c:=IOResult;
Rewrite(txt);
c:=IOResult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+'Ошибка создания '+Path^.Dat.ToTemp+'class.csv'+' Код:'+IntToStr(c,ckol),Nil,mfError+mfCancelButton);
  Exit;
 End;
Writeln(txt,DosToWin('Код')+SeparatorChar+DosToWin('Класс продукции'));



If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;


Assign (ClassFile,Path^.Dat.ToSPR+'Class.db');
c:=IOResult;
Reset (ClassFile,SizeOf(ClassificatorBuchType));
c:=IOResult;
 FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(ClassFile)) Do
 Begin
    New(ClassElement,Init);
    ReadBufClass(ClassFile,ClassElement,Count);
For c1:=1 To Count Do
Begin
  If ClassElement^.Point.Dat[c1].Employ Then
   Begin
    RFormatZerro(ClassElement^.Point.Dat[c1].Kod,CClientKod);
    ChangeSeparator(ClassElement^.Point.Dat[c1].Name);
    Writeln(txt,ClassElement^.Point.Dat[c1].Kod+SeparatorChar+DosToWin(ClassElement^.Point.Dat[c1].Name));
   End;
End;{For}
  Dispose(ClassElement,Done);
 End;
System.Close(ClassFile);

End
Else
 Begin
  System.Close(txt);
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
End{}
 Else
  Begin{FAstRead=True}
   {MemC(IntToStr(SprList[BClass].Elements^.List^.Count,CKol));}
   If SprList[BClass].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BClass].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BClass].Elements^.GetText(l,SprList[BClass].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     System.Delete(SKod,1,1);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CAll+16);
     RFormatZerro(SKod,CClientKod);
     ChangeSeparator(SElement);
     Writeln(txt,SKod+SeparatorChar+DosToWin(SElement));
     End;
    End;{For}
  End;

NoInfoMsg;

c:=IOResult;
System.Close(txt);
c:=IOResult;

MessageBox(^M+#3'Данные успешно импортированы в '+Path^.Dat.ToTemp+'class.csv!',Nil,
mfInformation+mfCancelButton);

Redraw;
end;





Destructor TClassWindow.Done;
Begin
ClearFind;
Dispose(ClassList,Done);
TDialog.Done;
End;


procedure TClassWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;
    Op : StrNAme;
   ClassElement : ClassificatorBuchType;

Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=ClassList^.GetText(ClassList^.Focused,ClassList^.List^.Count);
  s:=Copy(s,1+CAll+16+1,CClientKod);

  R:=GetClassEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать элемент с кодом '+s+'. Элемент отмечен как удаленный!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End;

  If SetElementLock(FClass,s,Op) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg('Элемент ['+s+'] используется '+Op+'! Не могу заблокировать элемент!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
   End;
End;


Function TestEmploy:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  TestEmploy:=False;
  s:=ClassList^.GetText(ClassList^.Focused,ClassList^.List^.Count);
  s:=Copy(s,1+CAll+16+1,CClientKod);

  r:=False;
  R:=GetClassEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Нельзя работать с элементом '+s+'. Элемент отмечен как удаленный!',False);
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
    Event.What:=EvCommand;
    Event.Command:=cmRefresh;
    PutEvent(Event);
    ClearEvent(Event);
    Exit;
   End
   Else
   TestEmploy:=True;
End;



Procedure UnlockAll;
Var  f : LockBazFileType;
     cl : LockBazType;
     r : Byte;
     cod : ArtikulStr;
Begin
DInfoMsg('Минуточку...',False);
Assign (F,Path^.Dat.ToSPR+'Class.lck');

r:=IOResult;
Reset(f);
r:=IOResult;
If R<>0 Then
 Begin
  NoInfoMsg;
  Exit;
 End;

While Not(Eof(f)) Do
  Begin
   ReadLockBaz(f,Cl);
   r:=IOResult;

   cl.Locked:=False;
   Seek(f,FilePos(f)-1);
   r:=IOResult;

   Write(f,cl);
   r:=IOResult;

  End;
System.close(f);
   r:=IOResult;

NoInfoMsg;
AddProtocol('Общая деблокировка классов {сетевая безопасность транзакций}','','');
End;



begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbDel: Begin

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;

     L:=False;
     If (ClassList^.State and sfFocused <> 0) And (ClassList^.List<>Nil)And(ClassList^.List^.Count>=2)
	Then L:=True;

     If L Then
            Begin
     If Password(5) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=ClassList^.GetText(ClassList^.Focused,ClassList^.List^.Count);
                s:=Copy(s,1+CAll+16+1,CClientKod);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=ClassList^.GetText(ClassList^.Focused,ClassList^.List^.Count);
                 s:=Copy(s,1+CAll+16+1,CClientKod);

                 Assign (ClassFile,Path^.Dat.ToSPR+'Class.db');
                 ClassElement.Name[0]:=#0;
                 ClassElement.Kod:=s;
                 ClassElement.Employ:=False;

  If Not (WriteLockClass(ClassElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлу классов!',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetElementUnLock(FClass,s));
     ClearEvent(Event);
     Exit;
    End
    Else
     RefreshCashOneSPR(bClass);


    Repeat
    Until (SetElementUnLock(FClass,s));
    AddProtoCol('Удаление класса:'+s,'','');
    ClassList^.List^.AtFree(ClassList^.Focused);
    ClassList^.SetRange(ClassList^.List^.Count);
    If ClassList^.Focused>0 Then   ClassList^.FocusItem(ClassList^.Focused);
    If (ClassList^.Focused>=ClassList^.List^.Count) and(ClassList^.Focused>0) Then
    ClassList^.FocusItem(ClassList^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
          End;


kbAlt1         : If Password(5) Then UnlockAll;
kbF9           : CorrectClass;

{временно выключено пока не написана процедура добавления нового региона}
kbGrayPlus,kbAltF1,kbF4:
Begin
L:=False;
If(ClassList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(ClassList^.List<>Nil)And(ClassList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
      If AddClass(Event.KeyCode,ClassElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(ClassList^.List<>Nil)And(ClassList^.List^.Count>=1) Then
           ClassList^.List^.AtFree(ClassList^.Focused);
        Format(ClassElement.Name,CAll+16);
        ClassList^.List^.Insert(NewStr(ClassElement.Name+'│'+ClassElement.Kod));
        ClassList^.SetRange(ClassList^.List^.Count);
        ClassList^.FocusItem(LoCation(ClassList,ClassElement.Kod,False));
        Redraw;
       End
       Else
        Begin
         s:=ClassList^.GetText(ClassList^.Focused,ClassList^.List^.Count);
         ClassElement.Kod:=Copy(s,1+CAll+16+1,CClientKod);
        End;

   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=ClassElement.Kod;
    Repeat
    Until (SetElementUnLock(FClass,Cod));
   End;
            ClearEvent(Event);
            Redraw;
            End;

      Else;
      End;{KeyDown}
evCommand:
 Case Event.Command Of
 cmRefresh: Refresh;
 cmReestrReport : ImportSPR;
{
 cmFindLink:Begin
             cod:=Copy(ClassList^.GetText(ClassList^.Focused,ClassList^.List^.Count),1+CAll+16+1,CClientKod);
             Lnk^.Start(cod);
             ClearEvent(Event);
            End;
}
  Else;
  End;{evCommand}
      Else;
      End;{*Case*}

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

 Case Event.What Of
 EvCommand : Begin
             Case Event.Command Of
 cmCancel,cmYes,cmOk,cmNo,cmClose,cmQuit
                     : Begin
                          If Not(TestEmploy) Then
                                   Begin
                                    ClearEvent(Event);
                                    Exit;
                                   End;
                       End;

             Else Exit;
             End;
             End;
 Else;
 End;


 if (Event.What = evBroadcast) and
     (Event.Command = cmSelectClass) then ClearEvent(Event);


 if (Event.What = evBroadcast) and
     (Event.Command = cmViewSPRClass) then ClearEvent(Event);


  inherited HandleEvent(Event);
  {
  If (Desktop^.Current=PView(ClassWindow)) And (Event.What <> EvKeyDown) Then
          Begin
                If (Client^.List <> Nil) And (Class^.List^.Count>=1) Then
                 Begin
                  s:=Class^.GetText(Class^.Focused,Class^.List^.Count);
                  If s<>PrevCurrentLine Then
                   Begin
                    PrevCurrentLine:=S;
                    DrawCurrent;
                   End;
                 End;
          End;
  }
  ClearEvent(Event);
end;






End.