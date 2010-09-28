{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Access5;

Interface

Uses Dialogs,Glob,Drivers,ServStr,Utils1;



Type
    PPostWindow= ^TPostWindow;
    TPostWindow = object(TDialog)
    Procedure ImportSPR;
    Procedure ShowPostList(Var st:AllStr;Var Res: Word);
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;



Type
    PMeraWindow= ^TMeraWindow;
    TMeraWindow = object(TDialog)
    Procedure ImportSPR;
    Procedure ShowMeraList(Var st:AllStr;Var Res: Word);
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;

Type
    PBankWindow= ^TBankWindow;
    TBankWindow = object(TDialog)
    Procedure ImportSPR;
    Procedure ShowBankList(Var st:TMyStringNew;Var Res: Word);
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type
    PPersonalWindow= ^TPersonalWindow;
    TPersonalWindow = object(TDialog)
    Procedure ImportSPR;
    Procedure ShowPersonalList(Var st:AllStr;Var Res: Word);
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;

Type
    PKassaOperationWindow= ^TKassaOperationWindow;
    TKassaOperationWindow = object(TDialog)
    EnableAdding : Boolean;
    Procedure ImportSPR;
    Procedure ShowKassaOperationList(RO,Reg:Boolean;Var st:AllStr;Var Res: Word);
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;



Type
    PFirmaPostWindow= ^TFirmaPostWindow;
    TFirmaPostWindow = object(TDialog)
    Procedure ImportSPR;
    Procedure ShowFirmaPostList(Var st:AllStr;Var Res: Word);
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Function CopyName(NameKod:ArtikulStr;Var NewNameKod:ArtikulStr):Boolean;


Implementation

{$I Compile.INC}

Uses Printers,App,Views,Objects,MsgBox,Serv,Utils5,TpDate,
     ColorTxt,Validate,DbEngin2,Memory,Utils,Utils3,Utils4,
     DbEngine,Utils7,Filetool,DbEngin3,ServStr2,MyView,
     Protect,Net,Net2,NetDbEng,NetCall;

Const LocalReadOnlyN=$42;

Var

   PrevCurrentLine : SertifStr;
   PostWindow : PPostWindow;
   MeraWindow : PMeraWindow;
   BankWindow : PBankWindow;
   PersonalWindow : PPersonalWindow;
   KassaOperationWindow : PKassaOperationWindow;
   FirmaPostWindow : PFirmaPostWindow;
   BankList,KassaOperationList : PBox;
   MeraNum,PostNum: PBox;
   MeraFile : MeraFileType;
   PersonalFile : PersonalFileType;
   KassaOperationFile : KassaOperationFileType;
   PostFile : PostFileType;
   FirmaPostFile : FirmaPostFileType;
   MeraList,
   PersonalList,FirmaPostList,PostList : PBox;
   OldFileMode,Count : Word;
   L : Longint;
   FFF : ^Integer;{Handler}
   fId : File;
   FastRead : Boolean;
   SKod : ArtikulStr;
   SElement: String[60];





Function AddPost( Cod:Integer; Var PostElement:PostType):Boolean;
Label 1;
var
  R : TRect;
  AddPostWin : PDialog;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full,Full1 : Boolean;
  k : LongInt;
  PostNum : PBox;
{  l : Boolean;}
  Event:TEvent;
  SRegName : AllStr;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddPost:=False;
    Exit;
   End;


If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    AddPost:=False;
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    AddPost:=False;
    Exit;
   End;

  If Not(Password(16)) Then
   Begin
    AddPost:=False;
    Exit;
   End;

C:=IOResult;
AddPost:=False;
Full:=True;
Full1:=False;

{If Password(5) Then Full1:=True;}

Assign(PostFile,Path^.Dat.ToSPR+'lands.db');

Reset(PostFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3+ErrorOpen^+' '+Path^.Dat.ToSPR+'lands.db!',nil,mfError+mfCancelButton);
 AddPost:=False;
 Exit;
End;
DInfoMsg('Читаю списки...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin
     PostElement.Employ:=True;
     While Not(Eof(PostFile)) And (PostElement.Employ) Do
     begin
      ReadPost(PostFile,PostElement);
     end;


     If Eof(PostFile) And (PostElement.Employ) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoPosition^,nil,mfWarning+mfCancelButton);
       System.Close(PostFile);
       AddPost:=False;
       Exit;
      End;
      s:=PostElement.Kod;
      PostElement.Post[0]       :=#0;
      PostElement.Kod     :=NoPostStr;
    End;

  kbF4:Begin
     s:=Copy(PostList^.GetText(PostList^.Focused,PostList^.List^.Count),1+CPost+1,CClientKod);
     Seek(PostFile,StrToInt(s));
     Repeat
      ReadPost(PostFile,PostElement);
     Until (Eof(PostFile)) Or (PostElement.Kod=s);
     If Eof(PostFile) And (PostElement.Kod<>s) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoFound^,nil,mfError+mfCancelButton);
       System.Close(PostFile);
       AddPost:=False;
       Exit;
      End;
    End;
  Else;
 End;
System.Close(PostFile);
1:


If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
Begin
R.Assign(11, 7, 68, 15);
New(AddPostWin, Init(R, 'Добавить страну'));
End
Else
Begin
R.Assign(11, 7, 68, 11);
New(AddPostWin, Init(R, 'Изменить страну'));
End;
AddPostWin^.Options := AddPostWin^.Options or ofCenterX or ofCenterY;
AddPostWin^.Palette := dpCyanDialog;
AddPostWin^.HelpCtx:=$E011;
R.Assign(9, 1, 37, 2);
Control := New(PInputLine, Init(R, CPost));
AddPostWin^.Insert(Control);

  R.Assign(37, 1, 40, 2);
  AddPostWin^.Insert(New(PHistory, Init(R, PInputline(Control), 99)));

  R.Assign(1, 1, 9, 2);
  AddPostWin^.Insert(New(PLabel, Init(R, '~С~трана:', Control)));


AddPostWin^.SetData(PostElement);


If (Cod = kbGrayPlus)Or (Cod=kbAltF1)  Then
Begin
 R.Assign(56, 3, 57, 7);
 Control := New(PScrollBar, Init(R));
 AddPostWin^.Insert(Control);
 R.Assign(1, 3, 56, 7);
 PostNum := New(PBox, Init(R, 9, PScrollbar(Control)));
 PostNum^.NewList(New(PTextCollection, Init(0,1)));

Assign(PostFile,Path^.Dat.ToSPR+'lands.db');
Reset (PostFile);
 While Not(Eof(PostFile)) Do
  Begin
   ReadPost(PostFile,PostElement);
   If Not(PostElement.Employ) Then
   Begin
   Format (PostElement.Post,CPost);
   PostNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+PostElement.Kod));
   PostNum^.SetRange(PostNum^.List^.Count);
   PostNum^.FocusItem(PostNum^.List^.Count);
   End;
  End;
 System.Close(PostFile);
 If Cod=kbF4 Then PostNum^.FocusItem(LoCation(PostNum,s,False))
 Else PostNum^.FocusItem(0);

 AddPostWin^.Insert(PostNum);
 PostNum^.HelpCtx:=$E011;

  R.Assign(1, 2, 17, 3);
  AddPostWin^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', PostNum)));
  AddPostWin^.Insert(Control);
 End;
If Cod=kbF4 Then
 Begin
  R.Assign(40, 1, 52, 2);
  Control := New(PColoredText, Init(R, 'Код страны:', $3E));
  AddPostWin^.Insert(Control);
  R.Assign(52, 1, 56, 2);
  Control := New(PColoredText, Init(R, PostElement.Kod,$3E));
  AddPostWin^.Insert(Control);
 End;

AddPostWin^.SelectNext(False);
NoInfoMsg;
c:=Desktop^.ExecView(AddPostWin);
If c<>cmCancel Then
 Begin
    AddPostWin^.GetData(PostElement);
    DelSpaceRight(PostElement.Post);

    If PostElement.Post[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название страны!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=PostNum^.GetText(PostNum^.Focused,PostNum^.List^.Count);
   s:=Copy(s,1+CPost+1,CClientKod);
  PostNum^.NewList(Nil);
  Dispose(PostNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddPostWin,Done);
    Goto 1;
   End;

  C:=IOResult;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=PostNum^.GetText(PostNum^.Focused,PostNum^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   If Not(TestEmployElementAndLock(FPost,s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать страну с кодом '+s+'... Попробуйте изменить код!',False);
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(PostNum,Done);
     Dispose(Control,Done);
     Dispose(AddPostWin,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(PostElement.Post);
   PostElement.Employ:=True;

   If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then PostElement.Kod:=s;


  {если не удалось записать информацию}
  If Not (WriteLockPost(PostElement)) Then
    Begin
     If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then Dispose(PostNum,Done);
     Dispose(Control,Done);
     Dispose(AddPostWin,Done);
     Repeat
     Until (SetElementUnLock(FPost,s));
     Goto 1;
    End
    Else
    RefreshCashOneSPR(BLands);

  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   AddProtocol('Добавление страны:'+PostElement.Post+' ('+s+')','','');
   Repeat
   Until (SetElementUnLock(FPost,s));
  End
  Else
   AddProtocol('Корректировка страны:'+PostElement.Post+' ('+PostElement.Kod+')','','');
  AddPost:=True;
 End;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
  PostNum^.NewList(Nil);
  Dispose(PostNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddPostWin,Done);

  PrevCurrentLine[0]:=#0;

End;


Procedure TPostWindow.ShowPostList(Var st:AllStr;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  Bak : String;
  c: Word;
  c1,Count : Word;
  PostFile : File;
  PostElement : PBufPostType;
begin
Bak:=st;
ClearFind;
DInfoMsg('Читаю списки...',False);

Res:=0;
R.Assign(56, 5, 79, 22);
New(PostWindow, Init(R, 'Выбор страны'));

R.Assign(22, 1, 23, 16);
Control := New(PScrollBar, Init(R));
PostWindow^.Insert(Control);

R.Assign(1, 1, 22, 16);
PostList := New(PBox, Init(R, 1, PScrollbar(Control)));
PostList^.NewList(New(PTextCollection, Init(0,1)));
Assign (PostFile,Path^.Dat.ToSPR+'lands.db');
c:=IOResult;
Reset (PostFile,SizeOf(PostType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(PostFile)) Do
 Begin
    New(PostElement,Init);
    ReadBufPost(PostFile,PostElement,Count);
For c1:=1 To Count Do
Begin
  If PostElement^.Point.Dat[c1].Employ Then
   Begin
    Format (PostElement^.Point.Dat[c1].Post,CPost);
    PostList^.List^.Insert(NewStr(PostElement^.Point.Dat[c1].Post+'│'+PostElement^.Point.Dat[c1].Kod));
    PostList^.SetRange(PostList^.List^.Count);
   End;
End;{For}
  Dispose(PostElement,Done);
 End;{While}
System.Close(PostFile);
End
Else
 Begin
  st:=Bak;
  NoInfoMsg;
  MessageBox(^M+#3+ErrorOpen^+' '+Path^.Dat.ToSPR+'lands.db',nil,mfError+mfCanCelButton);
  Goto 1;
 End;

If st[0]<>#0 Then
s:=Copy(st,1+CPost+1,CClientKod)
Else s:=NoPostStr;
RFormatZerro(s,CClientKod);
PostList^.FocusItem(Location(PostList,S,False));


PostList^.HelpCtx:=$F957;
PostWindow^.Insert(PostList);
PrevCurrentLine:=Copy(PostList^.GetText(PostList^.Focused,PostList^.List^.Count),1+CPost+1,CClientKod);

PostWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;
c:=Desktop^.ExecView(PostWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Res in[2,3] Then
   St:=PostList^.GetText(PostList^.Focused,PostList^.List^.Count)
   Else St:=Bak;
1:
Dispose(COntrol,Done);
Dispose(PostWindow,Done);
end;



Procedure TPostWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  PostFile : File;
  PostElement : PBufPostType;
  c1,Count : Word;
begin
ClearFind;
DInfoMsg('Обновляю списки стран...',False);
Cod:=PostList^.Focused;

     Assign (PostFile,Path^.Dat.ToSPR+'lands.db');
     PostList^.NewList(Nil);
     PostList^.NewList(New(PTextCollection, Init(0,1)));

c:=IOResult;
Reset (PostFile,SizeOf(PostType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(PostFile)) Do
 Begin
    New(PostElement,Init);
    ReadBufPost(PostFile,PostElement,Count);
For c1:=1 To Count Do
Begin
  If PostElement^.Point.Dat[c1].Employ Then
   Begin
    Format (PostElement^.Point.Dat[c1].Post,CPost);
    PostList^.List^.Insert(NewStr(PostElement^.Point.Dat[c1].Post+'│'+PostElement^.Point.Dat[c1].Kod));
    PostList^.SetRange(PostList^.List^.Count);
   End;
End;{For}
  Dispose(PostElement,Done);
 End;
System.Close(PostFile);
If Cod<>0 Then Dec(Cod);

PostList^.FocusItem(Cod);
NoInfoMsg;
End
Else
 Begin
  NoInfoMsg;
  MessageBox(^M+#3+ErrorOpen^+' '+Path^.Dat.ToSPR+'lands.db',nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;
PrevCurrentLine[0]:=#0;
end;



Procedure TPostWindow.ImportSPR;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  PostFile : File;
  PostElement : PBufPostType;
  c1,Count : Word;
  txt : Text;
  SeparatorChar : ArtikulStr;
begin
ClearFind;
SeparatorChar:=';';
DInfoMsg('Экспортирую списки стран...',False);


Assign(txt,Path^.Dat.ToTemp+'lands.csv');
c:=IOResult;
Rewrite(txt);
c:=IOResult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+'Ошибка создания '+Path^.Dat.ToTemp+'lands.csv'+' Код:'+IntToStr(c,ckol),Nil,mfError+mfCancelButton);
  Exit;
 End;
Writeln(txt,DosToWin('Код')+SeparatorChar+DosToWin('Страна происхождения'));


Assign(PostFile,Path^.Dat.ToSPR+'lands.db');
c:=IOResult;
Reset (PostFile,SizeOf(PostType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(PostFile)) Do
 Begin
    New(PostElement,Init);
    ReadBufPost(PostFile,PostElement,Count);
For c1:=1 To Count Do
Begin
  If PostElement^.Point.Dat[c1].Employ Then
   Begin
    Format (PostElement^.Point.Dat[c1].Post,CPost);
    ChangeSeparator(PostElement^.Point.Dat[c1].Post);
    Writeln(txt,PostElement^.Point.Dat[c1].Kod+SeparatorChar+DosToWin(PostElement^.Point.Dat[c1].Post));
   End;
End;{For}
  Dispose(PostElement,Done);
 End;
System.Close(PostFile);
NoInfoMsg;
End
Else
 Begin
  System.Close(txt);
  NoInfoMsg;
  MessageBox(^M+#3+ErrorOpen^+' '+Path^.Dat.ToSPR+'lands.db Код:'+IntToStr(c,CKol),nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;

c:=IOResult;
System.Close(txt);
c:=IOResult;
MessageBox(^M+#3'Данные успешно импортированы в '+Path^.Dat.ToTemp+'lands.csv!',Nil,
mfInformation+mfCancelButton);



end;


Destructor TPostWindow.Done;
Begin
ClearFind;
Dispose(PostList,Done);
TDialog.Done;
End;


procedure TPostWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;
    Op : StrNAme;
   PostElement : PostType;


Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=PostList^.GetText(PostList^.Focused,PostList^.List^.Count);
  s:=Copy(s,1+CPost+1,CClientKod);

  R:=GetPostEmploy(s);
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

  If SetElementLock(FPost,s,Op) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg(Zanato1^+' '+s+Zanato2^+' '+Op+NoLock^,False);

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
  s:=PostList^.GetText(PostList^.Focused,PostList^.List^.Count);
  s:=Copy(s,1+CPost+1,CClientKod);

  r:=False;
  R:=GetPostEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Нельзя работать с '+s+'. Элемент отмечен как удаленный!',False);
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
Assign (F,Path^.Dat.ToSPR+'lands.lck');

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
AddProtocol('Общая деблокировка стран','','');
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
     If (PostList^.State and sfFocused <> 0) And (PostList^.List<>Nil)And(PostList^.List^.Count>=2) Then L:=True;

     If L Then
            Begin
     If Password(5) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=PostList^.GetText(PostList^.Focused,PostList^.List^.Count);
                s:=Copy(s,1+CPost+1,CClientKod);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=PostList^.GetText(PostList^.Focused,PostList^.List^.Count);
                 s:=Copy(s,1+CPost+1,CClientKod);

                 Assign (PostFile,Path^.Dat.ToSPR+'lands.db');
                 PostElement.Post[0]:=#0;
                 PostElement.Kod:=s;
                 PostElement.Employ:=False;

  If Not (WriteLockPost(PostElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлам стран !',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetElementUnLock(FPost,s));
     ClearEvent(Event);
     Exit;
    End
    Else
     RefreshCashOneSPR(bLands);

    Repeat
    Until (SetElementUnLock(FPost,s));
    AddProtoCol('Удаление страны:'+s,'','');
    PostList^.List^.AtFree(PostList^.Focused);
    PostList^.SetRange(PostList^.List^.Count);
    If PostList^.Focused>0 Then   PostList^.FocusItem(PostList^.Focused);
    If (PostList^.Focused>=PostList^.List^.Count) and(PostList^.Focused>0) Then
    PostList^.FocusItem(PostList^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
          End;


kbAlt1         : If Password(5) Then UnlockAll;
kbF9           : CorrectPost;

{временно выключено пока не написана процедура добавления нового региона}
kbGrayPlus,kbAltF1,kbF4:
Begin
L:=False;
If(PostList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(PostList^.List<>Nil)And(PostList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
      If AddPost(Event.KeyCode,PostElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(PostList^.List<>Nil)And(PostList^.List^.Count>=1) Then
           PostList^.List^.AtFree(PostList^.Focused);
        Format(PostElement.Post,CPost);
        PostList^.List^.Insert(NewStr(PostElement.Post+'│'+PostElement.Kod));
        PostList^.SetRange(PostList^.List^.Count);
        PostList^.FocusItem(LoCation(PostList,PostElement.Kod,False));
        Redraw;
       End
       Else
        Begin
         s:=PostList^.GetText(PostList^.Focused,PostList^.List^.Count);
         PostElement.Kod:=Copy(s,1+CPost+1,CClientKod);
        End;

   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=PostElement.Kod;
    Repeat
    Until (SetElementUnLock(FPost,Cod));
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
     (Event.Command = cmSelectPost) then ClearEvent(Event);

 if (Event.What = evBroadcast) and
     (Event.Command = cmViewSPRLands) then ClearEvent(Event);


  inherited HandleEvent(Event);
  {
  If (Desktop^.Current=PView(PostWindow)) And (Event.What <> EvKeyDown) Then
          Begin
                If (Client^.List <> Nil) And (Post^.List^.Count>=1) Then
                 Begin
                  s:=Post^.GetText(Post^.Focused,Post^.List^.Count);
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


Function AddFirmaPost( Cod:Integer; Var FirmaPostElement:FirmaPostType):Boolean;
Label 1;
var
  R : TRect;
  AddFirmaPostWin : PDialog;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full,Full1 : Boolean;
  k : LongInt;
  FirmaPostNum : PBox;
{  l : Boolean;}
  Event:TEvent;
  SRegName : AllStr;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddFirmaPost:=False;
    Exit;
   End;


If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    AddFirmaPost:=False;
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    AddFirmaPost:=False;
    Exit;
   End;

  If Not(Password(16)) Then
   Begin
    AddFirmaPost:=False;
    Exit;
   End;

C:=IOResult;
AddFirmaPost:=False;
Full:=True;
Full1:=False;

{If Password(5) Then Full1:=True;}

Assign(FirmaPostFile,Path^.Dat.ToSPR+'Firma.db');

Reset(FirmaPostFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу фирм!',nil,mfError+mfCancelButton);
 AddFirmaPost:=False;
 Exit;
End;
DInfoMsg('Читаю списки...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin
     FirmaPostElement.Employ:=True;
     While Not(Eof(FirmaPostFile)) And (FirmaPostElement.Employ) Do
     begin
      ReadFirmaPost(FirmaPostFile,FirmaPostElement);
     end;


     If Eof(FirmaPostFile) And (FirmaPostElement.Employ) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoPosition^,nil,mfWarning+mfCancelButton);
       System.Close(FirmaPostFile);
       AddFirmaPost:=False;
       Exit;
      End;
      s:=FirmaPostElement.Kod;
      FirmaPostElement.FirmaPost[0]       :=#0;
      FirmaPostElement.Kod     :=NoPostStr;
    End;

  kbF4:Begin
     s:=Copy(FirmaPostList^.GetText(FirmaPostList^.Focused,FirmaPostList^.List^.Count),1+CFirmaPost+1,CClientKod);
     Seek(FirmaPostFile,StrToInt(s));
     Repeat
      ReadFirmaPost(FirmaPostFile,FirmaPostElement);
     Until (Eof(FirmaPostFile)) Or (FirmaPostElement.Kod=s);
     If Eof(FirmaPostFile) And (FirmaPostElement.Kod<>s) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoFound^,nil,mfError+mfCancelButton);
       System.Close(FirmaPostFile);
       AddFirmaPost:=False;
       Exit;
      End;
    End;
  Else;
 End;
System.Close(FirmaPostFile);
1:


If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
Begin
R.Assign(11, 7, 68, 15);
New(AddFirmaPostWin, Init(R, 'Добавить фирму'));
End
Else
Begin
R.Assign(11, 7, 68, 11);
New(AddFirmaPostWin, Init(R, 'Изменить фирму'));
End;
AddFirmaPostWin^.Options := AddFirmaPostWin^.Options or ofCenterX or ofCenterY;
AddFirmaPostWin^.Palette := dpCyanDialog;
AddFirmaPostWin^.HelpCtx:=$E011;
R.Assign(9, 1, 37, 2);
Control := New(PInputLine, Init(R, CFirmaPost));
AddFirmaPostWin^.Insert(Control);

  R.Assign(37, 1, 40, 2);
  AddFirmaPostWin^.Insert(New(PHistory, Init(R, PInputline(Control), 105)));

  R.Assign(1, 1, 9, 2);
  AddFirmaPostWin^.Insert(New(PLabel, Init(R, '~Ф~ирма:', Control)));


AddFirmaPostWin^.SetData(FirmaPostElement);


If (Cod = kbGrayPlus)Or (Cod=kbAltF1)  Then
Begin
 R.Assign(56, 3, 57, 7);
 Control := New(PScrollBar, Init(R));
 AddFirmaPostWin^.Insert(Control);
 R.Assign(1, 3, 56, 7);
 FirmaPostNum := New(PBox, Init(R, 9, PScrollbar(Control)));
 FirmaPostNum^.NewList(New(PTextCollection, Init(0,1)));

Assign(FirmaPostFile,Path^.Dat.ToSPR+'Firma.db');
Reset (FirmaPostFile);
 While Not(Eof(FirmaPostFile)) Do
  Begin
   ReadFirmaPost(FirmaPostFile,FirmaPostElement);
   If Not(FirmaPostElement.Employ) Then
   Begin
   Format (FirmaPostElement.FirmaPost,CFirmaPost);
   FirmaPostNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+FirmaPostElement.Kod));
   FirmaPostNum^.SetRange(FirmaPostNum^.List^.Count);
   FirmaPostNum^.FocusItem(FirmaPostNum^.List^.Count);
   End;
  End;
 System.Close(FirmaPostFile);
 If Cod=kbF4 Then FirmaPostNum^.FocusItem(LoCation(FirmaPostNum,s,False))
 Else FirmaPostNum^.FocusItem(0);

 AddFirmaPostWin^.Insert(FirmaPostNum);
 FirmaPostNum^.HelpCtx:=$E011;

  R.Assign(1, 2, 17, 3);
  AddFirmaPostWin^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', FirmaPostNum)));
  AddFirmaPostWin^.Insert(Control);
 End;
If Cod=kbF4 Then
 Begin
  R.Assign(40, 1, 52, 2);
  Control := New(PColoredText, Init(R, 'Код фирма:', $3E));
  AddFirmaPostWin^.Insert(Control);
  R.Assign(52, 1, 56, 2);
  Control := New(PColoredText, Init(R, FirmaPostElement.Kod,$3E));
  AddFirmaPostWin^.Insert(Control);
 End;

AddFirmaPostWin^.SelectNext(False);
NoInfoMsg;
c:=Desktop^.ExecView(AddFirmaPostWin);
If c<>cmCancel Then
 Begin
    AddFirmaPostWin^.GetData(FirmaPostElement);
    DelSpaceRight(FirmaPostElement.FirmaPost);

    If FirmaPostElement.FirmaPost[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название фирмы!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=FirmaPostNum^.GetText(FirmaPostNum^.Focused,FirmaPostNum^.List^.Count);
   s:=Copy(s,1+CFirmaPost+1,CClientKod);
  FirmaPostNum^.NewList(Nil);
  Dispose(FirmaPostNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddFirmaPostWin,Done);
    Goto 1;
   End;

  C:=IOResult;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=FirmaPostNum^.GetText(FirmaPostNum^.Focused,FirmaPostNum^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   If Not(TestEmployELementAndLock(FFirmaPost,s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать фирму с кодом '+s+'... Попробуйте изменить код!',False);
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(FirmaPostNum,Done);
     Dispose(Control,Done);
     Dispose(AddFirmaPostWin,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(FirmaPostElement.FirmaPost);
   FirmaPostElement.Employ:=True;

   If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then FirmaPostElement.Kod:=s;


  {если не удалось записать информацию}
  If Not (WriteLockFirmaPost(FirmaPostElement)) Then
    Begin
     If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then Dispose(FirmaPostNum,Done);
     Dispose(Control,Done);
     Dispose(AddFirmaPostWin,Done);
     Repeat
     Until (SetElementUnLock(FFirmaPost,s));
     Goto 1;
    End
    Else
    RefreshCashOneSPR(BFirma);


  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   AddProtocol('Добавление фирмы:'+FirmaPostElement.FirmaPost+' ('+s+')','','');
   Repeat
   Until (SetElementUnLock(FFirmaPost,s));
  End
  Else
   AddProtocol('Корректировка фирмы:'+FirmaPostElement.FirmaPost+' ('+FirmaPostElement.Kod+')','','');
  AddFirmaPost:=True;
 End;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
  FirmaPostNum^.NewList(Nil);
  Dispose(FirmaPostNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddFirmaPostWin,Done);

  PrevCurrentLine[0]:=#0;

End;


Procedure TFirmaPostWindow.ShowFirmaPostList(Var st:AllStr;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String;
  Bak : String;
  c: Word;
  c1,Count : Word;
  FirmaPostFile : File;
  FirmaPostElement : PBufFirmaPostType;
begin
Bak :=St;
ClearFind;
DInfoMsg('Читаю списки...',False);

Res:=0;
R.Assign(36, 5, 79, 22);
New(FirmaPostWindow, Init(R, 'Выбор фирмы'));

R.Assign(42, 1, 43, 16);
Control := New(PScrollBar, Init(R));
FirmaPostWindow^.Insert(Control);

R.Assign(1, 1, 42, 16);
FirmaPostList := New(PBox, Init(R, 1, PScrollbar(Control)));
FirmaPostList^.NewList(New(PTextCollection, Init(0,1)));
(*
Assign (FirmaPostFile,Path^.Dat.ToSPR+'Firma.db');
c:=IOResult;
Reset (FirmaPostFile,SizeOf(FirmaPostType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(FirmaPostFile)) Do
 Begin
    New(FirmaPostElement,Init);
    ReadBufFirmaPost(FirmaPostFile,FirmaPostElement,Count);
For c1:=1 To Count Do
Begin
  If FirmaPostElement^.Point.Dat[c1].Employ Then
   Begin
    Format (FirmaPostElement^.Point.Dat[c1].FirmaPost,CFirmaPost);
    FirmaPostList^.List^.Insert(NewStr(FirmaPostElement^.Point.Dat[c1].FirmaPost+'│'+FirmaPostElement^.Point.Dat[c1].Kod));
    FirmaPostList^.SetRange(FirmaPostList^.List^.Count);
   End;
End;{For}
  Dispose(FirmaPostElement,Done);
 End;{While}
System.Close(FirmaPostFile);
End
Else
 Begin
  St:=BAk;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
s:=Copy(st,1+CFirmaPost+1,CClientKod);
FirmaPostList^.FocusItem(Location(FirmaPostList,S,False));
FirmaPostList^.HelpCtx:=$E171;
FirmaPostWindow^.Insert(FirmaPostList);
PrevCurrentLine:=Copy(FirmaPostList^.GetText(FirmaPostList^.Focused,FirmaPostList^.List^.Count),1+CFirmaPost+1,CClientKod);

FirmaPostWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;
*)

FastRead:=False;
If (Compress=1) And (SprList[BFirma].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'Firma.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BFirma].Time)=L Then  FastRead:=True;
End;

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
Assign (FirmaPostFile,Path^.Dat.ToSPR+'firma.db');
c:=IOResult;
Reset (FirmaPostFile,SizeOf(FirmaPostType));
 FileMode:=OLDFileMode;

c:=IOResult;
If c=0 Then
Begin
While Not(Eof(FirmaPostFile)) Do
 Begin
    New(FirmaPostElement,Init);
    ReadBufFirmaPost(FirmaPostFile,FirmaPostElement,Count);
For c1:=1 To Count Do
Begin
  If FirmaPostElement^.Point.Dat[c1].Employ Then
   Begin
    Format (FirmaPostElement^.Point.Dat[c1].FirmaPost,CFirmaPost);
    FirmaPostList^.List^.Insert(NewStr(FirmaPostElement^.Point.Dat[c1].FirmaPost+'│'+FirmaPostElement^.Point.Dat[c1].Kod));
    FirmaPostList^.SetRange(FirmaPostList^.List^.Count);
   End;
End;{For}
  Dispose(FirmaPostElement,Done);
 End;{While}
System.Close(FirmaPostFile);
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
   If SprList[BFirma].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BFirma].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BFirma].Elements^.GetText(l,SprList[BFirma].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     System.Delete(SKOd,1,1);

     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CFirmaPost);
     Format (SElement,CFirmaPost);
     FirmaPostList^.List^.Insert(NewStr(SElement+'│'+SKod));
     FirmaPostList^.SetRange(FirmaPostList^.List^.Count);
     End;
    End;{For}

  End;

if st[0]<>#0 Then
s:=Copy(st,1+CFirmaPost+1,CClientKod)
Else
s:=NoPostStr;

RFormatZerro(s,CClientKod);
FirmaPostList^.FocusItem(Location(FirmaPostList,S,False));


FirmaPostList^.HelpCtx:=$F957;
FirmaPostWindow^.Insert(FirmaPostList);
PrevCurrentLine:=Copy(FirmaPostList^.GetText(FirmaPostList^.Focused,FirmaPostList^.List^.Count),1+CFirmaPost+1,CClientKod);
FirmaPostWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;

c:=Desktop^.ExecView(FirmaPostWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Res in[2,3] Then
   St:=FirmaPostList^.GetText(FirmaPostList^.Focused,FirmaPostList^.List^.Count)
   Else St:=Bak;
1:
Dispose(COntrol,Done);
Dispose(FirmaPostWindow,Done);
end;



Procedure TFirmaPostWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  FirmaPostFile : File;
  FirmaPostElement : PBufFirmaPostType;
  c1,Count : Word;
begin
ClearFind;
DInfoMsg('Обновляю списки фирм...',False);
Cod:=FirmaPostList^.Focused;

     FirmaPostList^.NewList(Nil);
     FirmaPostList^.NewList(New(PTextCollection, Init(0,1)));

FastRead:=False;
If (Compress=1) And (SprList[BFirma].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'Firma.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BFirma].Time)=L Then  FastRead:=True;
End;

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
Assign (FirmaPostFile,Path^.Dat.ToSPR+'Firma.db');
c:=IOResult;
Reset (FirmaPostFile,SizeOf(FirmaPostType));
 FileMode:=OldFileMode;
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(FirmaPostFile)) Do
 Begin
    New(FirmaPostElement,Init);
    ReadBufFirmaPost(FirmaPostFile,FirmaPostElement,Count);
For c1:=1 To Count Do
Begin
  If FirmaPostElement^.Point.Dat[c1].Employ Then
   Begin
    Format (FirmaPostElement^.Point.Dat[c1].FirmaPost,CFirmaPost);
    FirmaPostList^.List^.Insert(NewStr(FirmaPostElement^.Point.Dat[c1].FirmaPost+'│'+FirmaPostElement^.Point.Dat[c1].Kod));
    FirmaPostList^.SetRange(FirmaPostList^.List^.Count);
   End;
End;{For}
  Dispose(FirmaPostElement,Done);
 End;
System.Close(FirmaPostFile);


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
   If SprList[BFirma].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BFirma].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BFirma].Elements^.GetText(l,SprList[BFirma].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     System.Delete(SKOd,1,1);

     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CFirmaPost);
     Format (SElement,CFirmaPost);
     FirmaPostList^.List^.Insert(NewStr(SElement+'│'+SKod));
     FirmaPostList^.SetRange(FirmaPostList^.List^.Count);
     End;
    End;{For}

  End;
If Cod<>0 Then Dec(Cod);

FirmaPostList^.FocusItem(Cod);
NoInfoMsg;


Redraw;
PrevCurrentLine[0]:=#0;
end;



Procedure TFirmaPostWindow.ImportSPR;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  FirmaPostFile : File;
  FirmaPostElement : PBufFirmaPostType;
  c1,Count : Word;
  txt : Text;
  SeparatorChar : ArtikulStr;
begin
ClearFind;
SeparatorChar:=';';

DInfoMsg('Экпортирую фирмы...',False);


FastRead:=False;
If (Compress=1) And (SprList[BFirma].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'Firma.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BFirma].Time)=L Then  FastRead:=True;
End;


Assign(txt,Path^.Dat.ToTemp+'firma.csv');
c:=IOResult;
Rewrite(txt);
c:=IOResult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+'Ошибка создания '+Path^.Dat.ToTemp+'firma.csv'+' Код:'+IntToStr(c,ckol),Nil,mfError+mfCancelButton);
  Exit;
 End;
Writeln(txt,DosToWin('Код')+SeparatorChar+DosToWin('Фирма производитель'));




If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
Assign (FirmaPostFile,Path^.Dat.ToSPR+'Firma.db');
c:=IOResult;
Reset (FirmaPostFile,SizeOf(FirmaPostType));
 FileMode:=OldFileMode;
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(FirmaPostFile)) Do
 Begin
    New(FirmaPostElement,Init);
    ReadBufFirmaPost(FirmaPostFile,FirmaPostElement,Count);
For c1:=1 To Count Do
Begin
  If FirmaPostElement^.Point.Dat[c1].Employ Then
   Begin

    ChangeSeparator(FirmaPostElement^.Point.Dat[c1].FirmaPost);
    Writeln(txt,FirmaPostElement^.Point.Dat[c1].Kod+SeparatorChar+DosToWin(FirmaPostElement^.Point.Dat[c1].FirmaPost));
   End;
End;{For}
  Dispose(FirmaPostElement,Done);
 End;
System.Close(FirmaPostFile);


End
Else
 Begin
  System.Close(txt);
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы ! Код:'+IntToStr(c,CKol),nil,mfError+mfCanCelButton);
  Exit;
 End;
End
 Else
  Begin
   If SprList[BFirma].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BFirma].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BFirma].Elements^.GetText(l,SprList[BFirma].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     System.Delete(SKOd,1,1);

     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CFirmaPost);

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

MessageBox(^M+#3'Данные успешно импортированы в '+Path^.Dat.ToTemp+'firma.csv!',Nil,
mfInformation+mfCancelButton);


Redraw;
end;





Destructor TFirmaPostWindow.Done;
Begin
ClearFind;
Dispose(FirmaPostList,Done);
TDialog.Done;
End;


procedure TFirmaPostWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;
    Op : StrNAme;
   FirmaPostElement : FirmaPostType;


Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=FirmaPostList^.GetText(FirmaPostList^.Focused,FirmaPostList^.List^.Count);
  s:=Copy(s,1+CFirmaPost+1,CClientKod);

  R:=GetFirmaPostEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать фирму с кодом '+s+'. Фирма отмечена как удаленная!',False);
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

  If SetElementLock(FFirmaPost,s,Op) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg(Zanato1^+' '+s+Zanato2^+' '+Op+NoLock^,False);
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
  s:=FirmaPostList^.GetText(FirmaPostList^.Focused,FirmaPostList^.List^.Count);
  s:=Copy(s,1+CFirmaPost+1,CClientKod);

  r:=False;
  R:=GetFirmaPostEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Нельзя работать с фирмой '+s+'. Фирма отмечена как удаленная!',False);
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
Assign (F,Path^.Dat.ToSPR+'Firma.lck');

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
AddProtocol('Общая деблокировка фирм','','');
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
     If (FirmaPostList^.State and sfFocused <> 0) And (FirmaPostList^.List<>Nil)And(FirmaPostList^.List^.Count>=2)
	Then L:=True;

     If L Then
            Begin
     If Password(5) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=FirmaPostList^.GetText(FirmaPostList^.Focused,FirmaPostList^.List^.Count);
                s:=Copy(s,1+CFirmaPost+1,CClientKod);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=FirmaPostList^.GetText(FirmaPostList^.Focused,FirmaPostList^.List^.Count);
                 s:=Copy(s,1+CFirmaPost+1,CClientKod);

                 Assign (FirmaPostFile,Path^.Dat.ToSPR+'Firma.db');
                 FirmaPostElement.FirmaPost[0]:=#0;
                 FirmaPostElement.Kod:=s;
                 FirmaPostElement.Employ:=False;

  If Not (WriteLockFirmaPost(FirmaPostElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлам фирм!',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetElementUnLock(FFirmaPost,s));
     ClearEvent(Event);
     Exit;
    End
    Else
     RefreshCashOneSPR(bFirma);


    Repeat
    Until (SetElementUnLock(FFirmaPost,s));
    AddProtoCol('Удаление фирмы:'+s,'','');
    FirmaPostList^.List^.AtFree(FirmaPostList^.Focused);
    FirmaPostList^.SetRange(FirmaPostList^.List^.Count);
    If FirmaPostList^.Focused>0 Then   FirmaPostList^.FocusItem(FirmaPostList^.Focused);
    If (FirmaPostList^.Focused>=FirmaPostList^.List^.Count) and(FirmaPostList^.Focused>0) Then
    FirmaPostList^.FocusItem(FirmaPostList^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
          End;


kbAlt1         : If Password(5) Then UnlockAll;
kbF9           : CorrectFirma;

{временно выключено пока не написана процедура добавления нового региона}
kbGrayPlus,kbAltF1,kbF4:
Begin
L:=False;
If(FirmaPostList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(FirmaPostList^.List<>Nil)And(FirmaPostList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
      If AddFirmaPost(Event.KeyCode,FirmaPostElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(FirmaPostList^.List<>Nil)And(FirmaPostList^.List^.Count>=1) Then
           FirmaPostList^.List^.AtFree(FirmaPostList^.Focused);
        Format(FirmaPostElement.FirmaPost,CFirmaPost);
        FirmaPostList^.List^.Insert(NewStr(FirmaPostElement.FirmaPost+'│'+FirmaPostElement.Kod));
        FirmaPostList^.SetRange(FirmaPostList^.List^.Count);
        FirmaPostList^.FocusItem(LoCation(FirmaPostList,FirmaPostElement.Kod,False));
        Redraw;
       End
       Else
        Begin
         s:=FirmaPostList^.GetText(FirmaPostList^.Focused,FirmaPostList^.List^.Count);
         FirmaPostElement.Kod:=Copy(s,1+CFirmaPost+1,CClientKod);
        End;

   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=FirmaPostElement.Kod;
    Repeat
    Until (SetElementUnLock(FFirmaPost,Cod));
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
     (Event.Command = cmSelectFirmaPost) then ClearEvent(Event);

 if (Event.What = evBroadcast) and
     (Event.Command = cmViewSPRFirma) then ClearEvent(Event);


  inherited HandleEvent(Event);
  {
  If (Desktop^.Current=PView(FirmaPostWindow)) And (Event.What <> EvKeyDown) Then
          Begin
                If (Client^.List <> Nil) And (FirmaPost^.List^.Count>=1) Then
                 Begin
                  s:=FirmaPost^.GetText(FirmaPost^.Focused,FirmaPost^.List^.Count);
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



Function AddMera( Cod:Integer; Var MeraElement:MeraType):Boolean;
Label 1;
var
  R : TRect;
  AddMeraWin : PDialog;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full,Full1 : Boolean;
  k : LongInt;
  MeraNum : PBox;
{  l : Boolean;}
  Event:TEvent;
  SRegName : AllStr;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddMera:=False;
    Exit;
   End;


If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    AddMera:=False;
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    {MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);}
    AddMera:=False;
    Exit;
   End;

  If Not(Password(16)) Then
   Begin
    AddMera:=False;
    Exit;
   End;

C:=IOResult;
AddMera:=False;
Full:=True;
Full1:=False;

{If Password(5) Then Full1:=True;}

Assign(MeraFile,Path^.Dat.ToSPR+'mera.db');

Reset(MeraFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу единиц измерения!',nil,mfError+mfCancelButton);
 AddMera:=False;
 Exit;
End;
DInfoMsg('Читаю списки...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin
     MeraElement.Employ:=True;
     While Not(Eof(MeraFile)) And (MeraElement.Employ) Do
     begin
      ReadMera(MeraFile,MeraElement);
     end;


     If Eof(MeraFile) And (MeraElement.Employ) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoPosition^,nil,mfWarning+mfCancelButton);
       System.Close(MeraFile);
       AddMera:=False;
       Exit;
      End;
      s:=MeraElement.Kod;
      MeraElement.Mera[0]       :=#0;
      MeraElement.Kod     :=NoMeraStr;
    End;

  kbF4:Begin
     s:=Copy(MeraList^.GetText(MeraList^.Focused,MeraList^.List^.Count),1+CMera+1,CClientKod);
     Seek(MeraFile,StrToInt(s));
     Repeat
      ReadMera(MeraFile,MeraElement);
     Until (Eof(MeraFile)) Or (MeraElement.Kod=s);
     If Eof(MeraFile) And (MeraElement.Kod<>s) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoFound^,nil,mfError+mfCancelButton);
       System.Close(MeraFile);
       AddMera:=False;
       Exit;
      End;
    End;
  Else;
 End;
System.Close(MeraFile);
1:


If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
Begin
R.Assign(11, 7, 68, 15);
New(AddMeraWin, Init(R, 'Добавить ед.изм'));
End
Else
Begin
R.Assign(11, 7, 68, 11);
New(AddMeraWin, Init(R, 'Изменить ед.изм'));
End;
AddMeraWin^.Options := AddMeraWin^.Options or ofCenterX or ofCenterY;
AddMeraWin^.Palette := dpCyanDialog;
AddMeraWin^.HelpCtx:=$E011;
R.Assign(9, 1, 37, 2);
Control := New(PInputLine, Init(R, CMera));
AddMeraWin^.Insert(Control);

  R.Assign(37, 1, 40, 2);
  AddMeraWin^.Insert(New(PHistory, Init(R, PInputline(Control), 103)));

  R.Assign(1, 1, 9, 2);
  AddMeraWin^.Insert(New(PLabel, Init(R, '~Е~д.изм:', Control)));


AddMeraWin^.SetData(MeraElement);


If (Cod = kbGrayPlus)Or (Cod=kbAltF1)  Then
Begin
 R.Assign(56, 3, 57, 7);
 Control := New(PScrollBar, Init(R));
 AddMeraWin^.Insert(Control);
 R.Assign(1, 3, 56, 7);
 MeraNum := New(PBox, Init(R, 9, PScrollbar(Control)));
 MeraNum^.NewList(New(PTextCollection, Init(0,1)));

Assign(MeraFile,Path^.Dat.ToSPR+'mera.db');
Reset (MeraFile);
 While Not(Eof(MeraFile)) Do
  Begin
   ReadMera(MeraFile,MeraElement);
   If Not(MeraElement.Employ) Then
   Begin
   Format (MeraElement.Mera,CMera);
   MeraNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+MeraElement.Kod));
   MeraNum^.SetRange(MeraNum^.List^.Count);
   MeraNum^.FocusItem(MeraNum^.List^.Count);
   End;
  End;
 System.Close(MeraFile);
 If Cod=kbF4 Then MeraNum^.FocusItem(LoCation(MeraNum,s,False))
 Else MeraNum^.FocusItem(0);

 AddMeraWin^.Insert(MeraNum);
 MeraNum^.HelpCtx:=$E011;

  R.Assign(1, 2, 17, 3);
  AddMeraWin^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', MeraNum)));
  AddMeraWin^.Insert(Control);
 End;
If Cod=kbF4 Then
 Begin
  R.Assign(40, 1, 52, 2);
  Control := New(PColoredText, Init(R, 'Код ед.изм:', $3E));
  AddMeraWin^.Insert(Control);
  R.Assign(52, 1, 56, 2);
  Control := New(PColoredText, Init(R, MeraElement.Kod,$3E));
  AddMeraWin^.Insert(Control);
 End;

AddMeraWin^.SelectNext(False);
NoInfoMsg;
c:=Desktop^.ExecView(AddMeraWin);
If c<>cmCancel Then
 Begin
    AddMeraWin^.GetData(MeraElement);
    DelSpaceRight(MeraElement.Mera);

    If MeraElement.Mera[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название единицы измерения!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=MeraNum^.GetText(MeraNum^.Focused,MeraNum^.List^.Count);
   s:=Copy(s,1+CMera+1,CClientKod);
  MeraNum^.NewList(Nil);
  Dispose(MeraNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddMeraWin,Done);
    Goto 1;
   End;

  C:=IOResult;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=MeraNum^.GetText(MeraNum^.Focused,MeraNum^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   If Not(TestEmployElementAndLock(FMera,s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать единицу измерения с кодом '+s+'... Попробуйте изменить код!',False);
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(MeraNum,Done);
     Dispose(Control,Done);
     Dispose(AddMeraWin,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(MeraElement.Mera);
   MeraElement.Employ:=True;

   If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then MeraElement.Kod:=s;


  {если не удалось записать информацию}
  If Not (WriteLockMera(MeraElement)) Then
    Begin
     If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then Dispose(MeraNum,Done);
     Dispose(Control,Done);
     Dispose(AddMeraWin,Done);
     Repeat
     Until (SetElementUnLock(FMera,s));
     Goto 1;
    End
    Else
     RefreshCashOneSPR(BMera);

  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   AddProtocol('Добавление единицы измерения:'+MeraElement.Mera+' ('+s+')','','');
   Repeat
   Until (SetElementUnLock(FMera,s));
  End
  Else
   AddProtocol('Корректировка единицы измерения:'+MeraElement.Mera+' ('+MeraElement.Kod+')','','');
  AddMera:=True;
 End;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
  MeraNum^.NewList(Nil);
  Dispose(MeraNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddMeraWin,Done);
  PrevCurrentLine[0]:=#0;
End;





Function AddPersonal( Cod:Integer; Var PersonalElement:PersonalType):Boolean;
Label 1;
var
  R : TRect;
  AddPersonalWin : PDialog;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full,Full1 : Boolean;
  k : LongInt;
  PersonalNum : PBox;
{  l : Boolean;}
  Event:TEvent;
  SRegName : AllStr;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddPersonal:=False;
    Exit;
   End;


If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    AddPersonal:=False;
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    AddPersonal:=False;
    Exit;
   End;

  If Not(Password(16)) Then
   Begin
    AddPersonal:=False;
    Exit;
   End;

C:=IOResult;
AddPersonal:=False;
Full:=True;
Full1:=False;

{If Password(5) Then Full1:=True;}

Assign(PersonalFile,Path^.Dat.ToSPR+'Personal.db');

Reset(PersonalFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу единиц измерения!',nil,mfError+mfCancelButton);
 AddPersonal:=False;
 Exit;
End;
DInfoMsg('Читаю списки...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin
     PersonalElement.Employ:=True;
     While Not(Eof(PersonalFile)) And (PersonalElement.Employ) Do
     begin
      ReadPersonal(PersonalFile,PersonalElement);
     end;


     If Eof(PersonalFile) And (PersonalElement.Employ) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoPosition^,nil,mfWarning+mfCancelButton);
       System.Close(PersonalFile);
       AddPersonal:=False;
       Exit;
      End;
      s:=PersonalElement.Kod;
      PersonalElement.Name[0]:=#0;
      PersonalElement.StatusOut:=0;
      PersonalElement.StatusIn :=0;
      PersonalElement.Kassir   :=0;
      PersonalElement.Kod     :=NoPersonalStr;
    End;

  kbF4:Begin
     s:=Copy(PersonalList^.GetText(PersonalList^.Focused,PersonalList^.List^.Count),1+CPersonal+1,CClientKod);
     Seek(PersonalFile,StrToInt(s));
     Repeat
      ReadPersonal(PersonalFile,PersonalElement);
     Until (Eof(PersonalFile)) Or (PersonalElement.Kod=s);
     If Eof(PersonalFile) And (PersonalElement.Kod<>s) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoFound^,nil,mfError+mfCancelButton);
       System.Close(PersonalFile);
       AddPersonal:=False;
       Exit;
      End;
    End;
  Else;
 End;
System.Close(PersonalFile);
1:


If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
Begin
R.Assign(14, 5, 66, 17);
New(AddPersonalWin, Init(R, 'Добавить сотрудника'));
End
Else
Begin
R.Assign(14, 5, 66, 12);
New(AddPersonalWin, Init(R, 'Изменить сотрудника'));
End;
AddPersonalWin^.Options := AddPersonalWin^.Options or ofCenterX or ofCenterY;
AddPersonalWin^.Palette := dpCyanDialog;
AddPersonalWin^.HelpCtx:=$E011;

R.Assign(1, 2, 23, 3);
Control := New(PInputLine, Init(R, CPersonal));
AddPersonalWin^.Insert(Control);

  R.Assign(1, 1, 10, 2);
  AddPersonalWin^.Insert(New(PLabel, Init(R, 'Ф~И~О:', Control)));

R.Assign(1, 3, 41, 4);
Control := New(PCheckboxes, Init(R,
  NewSItem('Разрешить ~в~ыдавать деньги из кассы', Nil)));
AddPersonalWin^.Insert(Control);


If Not((Cod=kbGrayPlus) Or (Cod=kbAltF1)) Then
Begin
R.Assign(42, 1, 50, 2);
Control := New(PColoredText, Init(R, 'Код:'+PersonalElement.Kod, $3E));
AddPersonalWin^.Insert(Control);
End;

R.Assign(1, 4, 41, 5);
Control := New(PCheckboxes, Init(R,
  NewSItem('Разрешить ~п~олучать деньги из кассы', Nil)));
AddPersonalWin^.Insert(Control);

R.Assign(1, 5, 41, 6);
Control := New(PCheckboxes, Init(R,
  NewSItem('~К~ассир', Nil)));
AddPersonalWin^.Insert(Control);



AddPersonalWin^.SetData(PersonalElement);


If (Cod = kbGrayPlus)Or (Cod=kbAltF1)  Then
Begin
 R.Assign(51, 7, 52, 11);
 Control := New(PScrollBar, Init(R));
 AddPersonalWin^.Insert(Control);
 R.Assign(1, 7, 51, 11);
 PersonalNum := New(PBox, Init(R, 7, PScrollbar(Control)));
 PersonalNum^.NewList(New(PTextCollection, Init(0,1)));

Assign(PersonalFile,Path^.Dat.ToSPR+'Personal.db');
Reset (PersonalFile);
 While Not(Eof(PersonalFile)) Do
  Begin
   ReadPersonal(PersonalFile,PersonalElement);
   If Not(PersonalElement.Employ) Then
   Begin
   Format (PersonalElement.Name,CPersonal);
   PersonalNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+PersonalElement.Kod));
   PersonalNum^.SetRange(PersonalNum^.List^.Count);
   PersonalNum^.FocusItem(PersonalNum^.List^.Count);
   End;
  End;
 System.Close(PersonalFile);
 If Cod=kbF4 Then PersonalNum^.FocusItem(LoCation(PersonalNum,s,False))
 Else PersonalNum^.FocusItem(0);

 AddPersonalWin^.Insert(PersonalNum);
 PersonalNum^.HelpCtx:=$E011;

  R.Assign(1, 6, 17, 7);
  AddPersonalWin^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', PersonalNum)));
  AddPersonalWin^.Insert(Control);
 End;

AddPersonalWin^.SelectNext(False);

NoInfoMsg;
c:=Desktop^.ExecView(AddPersonalWin);
If c<>cmCancel Then
 Begin
    AddPersonalWin^.GetData(PersonalElement);
    DelSpaceRight(PersonalElement.Name);

    If PersonalElement.Name[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=PersonalNum^.GetText(PersonalNum^.Focused,PersonalNum^.List^.Count);
   s:=Copy(s,1+CPersonal+1,CClientKod);
  PersonalNum^.NewList(Nil);
  Dispose(PersonalNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddPersonalWin,Done);
    Goto 1;
   End;

  C:=IOResult;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=PersonalNum^.GetText(PersonalNum^.Focused,PersonalNum^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   If Not(TestEmployElementAndLock(FPersonal,s)) Then
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
     Dispose(PersonalNum,Done);
     Dispose(Control,Done);
     Dispose(AddPersonalWin,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(PersonalElement.Name);
   PersonalElement.Employ:=True;

   If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then PersonalElement.Kod:=s;


  {если не удалось записать информацию}
  If Not (WriteLockPersonal(PersonalElement)) Then
    Begin
     If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then Dispose(PersonalNum,Done);
     Dispose(Control,Done);
     Dispose(AddPersonalWin,Done);
     Repeat
     Until (SetElementUnLock(FPersonal,s));
     Goto 1;
    End
    Else
     RefreshCashOneSPR(BPersonal);

  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   AddProtocol('Добавление сотрудника:'+PersonalElement.Name+' ('+s+')','','');
   Repeat
   Until (SetElementUnLock(FPersonal,s));
  End
  Else
   AddProtocol('Корректировка сотрудника:'+PersonalElement.Name+' ('+PersonalElement.Kod+')','','');
  AddPersonal:=True;
 End;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
  PersonalNum^.NewList(Nil);
  Dispose(PersonalNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddPersonalWin,Done);
  PrevCurrentLine[0]:=#0;
End;



Function AddBank( Cod:Integer; Var BankElement:BankType):Boolean;
Label 1;
var
  R : TRect;
  AddBankWin : PDialog;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full,Full1 : Boolean;
  k : LongInt;
  BankNum : PBox;
  BankFile : BankFileType;
{  l : Boolean;}
  Event:TEvent;
  SRegName : AllStr;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddBank:=False;
    Exit;
   End;


If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    AddBank:=False;
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    AddBank:=False;
    Exit;
   End;

  If Not(Password(16)) Then
   Begin
    AddBank:=False;
    Exit;
   End;

C:=IOResult;
AddBank:=False;
Full:=True;
Full1:=False;

{If Password(5) Then Full1:=True;}

Assign(BankFile,Path^.Dat.ToSPR+'Banks.db');

Reset(BankFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу банков!',nil,mfError+mfCancelButton);
 AddBank:=False;
 Exit;
End;
DInfoMsg('Читаю списки...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin
     BankElement.Employ:=True;
     While Not(Eof(BankFile)) And (BankElement.Employ) Do
     begin
      ReadBank(BankFile,BankElement);
     end;


     If Eof(BankFile) And (BankElement.Employ) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoPosition^,nil,mfWarning+mfCancelButton);
       System.Close(BankFile);
       AddBank:=False;
       Exit;
      End;
      s:=BankElement.Kod;
      BankElement.FullName [0]:= #0;
      BankElement.Gde      [0]:= #0;
      BankElement.Bik      [0]:= #0;
      BankElement.KSh      [0]:= #0;
      BankElement.RSh      [0]:= #0;
      BankElement.INN      [0]:= #0;
      BankElement.KPP      [0]:= #0;
      BankElement.DateC     :=ToDay;
      BankElement.DateM     :=ToDay;
      BankElement.TimeM     :=CurrentTime;
      BankElement.Status:=0;
      BankElement.Kod     :=NoBankStr;
    End;

  kbF4:Begin
     s:=Copy(BankList^.GetText(BankList^.Focused,BankList^.List^.Count),1+CAll+1,CClientKod);
     Seek(BankFile,StrToInt(s));
     Repeat
      ReadBank(BankFile,BankElement);
     Until (Eof(BankFile)) Or (BankElement.Kod=s);
     If Eof(BankFile) And (BankElement.Kod<>s) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoFound^,nil,mfError+mfCancelButton);
       System.Close(BankFile);
       AddBank:=False;
       Exit;
      End;
    End;
  Else;
 End;
System.Close(BankFile);
1:


If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
Begin
R.Assign(16, 4, 63, 18);
New(AddBankWin, Init(R, 'Добавить банк'));
End
Else
Begin
R.Assign(16, 4, 63, 14);
New(AddBankWin, Init(R, 'Изменить банк'));
End;
AddBankWin^.Options := AddBankWin^.Options or ofCenterX or ofCenterY;
AddBankWin^.Palette := dpCyanDialog;
AddBankWin^.HelpCtx:=$E011;


R.Assign(18, 1, 46, 2);
Control := New(PInputLine, Init(R, CAll));
AddBankWin^.Insert(Control);

  R.Assign(1, 1, 18, 2);
  AddBankWin^.Insert(New(PLabel, Init(R, 'По~л~ное название:', Control)));

R.Assign(18, 2, 46, 3);
Control := New(PInputLine, Init(R, CAll));
AddBankWin^.Insert(Control);

  R.Assign(11, 2, 18, 3);
  AddBankWin^.Insert(New(PLabel, Init(R, '~Г~ород:', Control)));

R.Assign(18, 3, 46, 4);
Control := New(PInputLine, Init(R, CBAnk));
AddBankWin^.Insert(Control);

  R.Assign(13, 3, 18, 4);
  AddBankWin^.Insert(New(PLabel, Init(R, 'Б~И~К:', Control)));

R.Assign(18, 4, 46, 5);
Control := New(PInputLine, Init(R, CBank));
AddBankWin^.Insert(Control);

  R.Assign(2, 4, 18, 5);
  AddBankWin^.Insert(New(PLabel, Init(R, '~Р~асчетный счет:', Control)));

R.Assign(18, 5, 46, 6);
Control := New(PInputLine, Init(R, CBank));
AddBankWin^.Insert(Control);

  R.Assign(8, 5, 18, 6);
  AddBankWin^.Insert(New(PLabel, Init(R, 'Кор.~с~чет:', Control)));

R.Assign(18, 6, 46, 7);
Control := New(PInputLine, Init(R, CBank));
AddBankWin^.Insert(Control);

  R.Assign(13, 6, 18, 7);
  AddBankWin^.Insert(New(PLabel, Init(R, 'И~Н~Н:', Control)));

R.Assign(18, 7, 46, 8);
Control := New(PInputLine, Init(R, CBank));
AddBankWin^.Insert(Control);

  R.Assign(13, 7, 18, 8);
  AddBankWin^.Insert(New(PLabel, Init(R, 'К~П~П:', Control)));

R.Assign(18, 8, 46, 9);
Control := New(PCheckboxes, Init(R,
  NewSItem('Разреши~т~ь использовать', Nil)));
AddBankWin^.Insert(Control);


AddBankWin^.SetData(BankElement);


If (Cod = kbGrayPlus)Or (Cod=kbAltF1)  Then
Begin
 R.Assign(46, 10, 47, 13);
 Control := New(PScrollBar, Init(R));
 AddBankWin^.Insert(Control);
 R.Assign(1, 10, 46, 13);
 BankNum := New(PBox, Init(R, 7, PScrollbar(Control)));
 BankNum^.NewList(New(PTextCollection, Init(0,1)));

Assign(BankFile,Path^.Dat.ToSPR+'Banks.db');
Reset (BankFile);
 While Not(Eof(BankFile)) Do
  Begin
   ReadBank(BankFile,BankElement);
   If Not(BankElement.Employ) Then
   Begin
   Format (BankElement.FullName,CAll);
   BankNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+BankElement.Kod));
   BankNum^.SetRange(BankNum^.List^.Count);
   BankNum^.FocusItem(BankNum^.List^.Count);
   End;
  End;
 System.Close(BankFile);
 If Cod=kbF4 Then BankNum^.FocusItem(LoCation(BankNum,s,False))
 Else BankNum^.FocusItem(0);

 AddBankWin^.Insert(BankNum);
 BankNum^.HelpCtx:=$E011;

  R.Assign(1, 9, 17, 10);
  AddBankWin^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', BankNum)));
  AddBankWin^.Insert(Control);


 End
 Else
 Begin
R.Assign(36, 0, 44, 1);
Control := New(PStaticText, Init(R, 'Код:'+BankElement.Kod));
AddBankWin^.Insert(Control);
 End;

AddBankWin^.SelectNext(False);

NoInfoMsg;
c:=Desktop^.ExecView(AddBankWin);
If c<>cmCancel Then
 Begin
    AddBankWin^.GetData(BankElement);
    DelSpaceRight(BankElement.FullName);

    If BankElement.FullName[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=BankNum^.GetText(BankNum^.Focused,BankNum^.List^.Count);
   s:=Copy(s,1+CAll+1,CClientKod);
  BankNum^.NewList(Nil);
  Dispose(BankNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddBankWin,Done);
    Goto 1;
   End;

  C:=IOResult;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=BankNum^.GetText(BankNum^.Focused,BankNum^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   If Not(TestEmployElementAndLock(FBank,s)) Then
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
     Dispose(BankNum,Done);
     Dispose(Control,Done);
     Dispose(AddBankWin,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(BankElement.FullName);
   BankElement.Employ:=True;

   If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then BankElement.Kod:=s;


  {если не удалось записать информацию}
  If Not (WriteLockBank(BankElement)) Then
    Begin
     If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then Dispose(BankNum,Done);
     Dispose(Control,Done);
     Dispose(AddBankWin,Done);
     Repeat
     Until (SetElementUnLock(FBank,s));
     Goto 1;
    End
    Else
     RefreshCashOneSPR(BBank);

  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   AddProtocol('Добавление банка:'+BankElement.FullName+' ('+s+')','','');
   Repeat
   Until (SetElementUnLock(FBank,s));
  End
  Else
   AddProtocol('Корректировка банка:'+BankElement.FullName+' ('+BankElement.Kod+')','','');
   AddBank:=True;
 End;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
  BankNum^.NewList(Nil);
  Dispose(BankNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddBankWin,Done);
  PrevCurrentLine[0]:=#0;
End;





Procedure TPersonalWindow.ShowPersonalList(Var st:AllStr;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  Bak : String;
  c: Word;
  c1,Count : Word;
  PersonalFile : File;
  PersonalElement : PBufPersonalType;
begin
Bak:=st;
ClearFind;
DInfoMsg('Читаю списки...',False);

Res:=0;
{
R.Assign(45, 5, 79, 22);
New(KassaOperationWindow, Init(R, 'Выбор статьи'));
KassaOperationWindow^.HelpCtx:=$F957;

R.Assign(33, 1, 34, 16);
Control := New(PScrollBar, Init(R));
KassaOperationWindow^.Insert(Control);

R.Assign(1, 1, 33, 16);
}
R.Assign(51, 5, 79, 22);
New(PersonalWindow, Init(R, 'Выбор сотрудника'));

R.Assign(27, 1, 28, 16);
Control := New(PScrollBar, Init(R));
PersonalWindow^.Insert(Control);

R.Assign(1, 1, 27, 16);
PersonalList := New(PBox, Init(R, 1, PScrollbar(Control)));
PersonalList^.NewList(New(PTextCollection, Init(0,1)));
Assign (PersonalFile,Path^.Dat.ToSPR+'Personal.db');
c:=IOResult;
Reset (PersonalFile,SizeOf(PersonalType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(PersonalFile)) Do
 Begin
    New(PersonalElement,Init);
    ReadBufPersonal(PersonalFile,PersonalElement,Count);
For c1:=1 To Count Do
Begin
  If PersonalElement^.Point.Dat[c1].Employ Then
   Begin
    Format (PersonalElement^.Point.Dat[c1].Name,CPersonal);
    PersonalList^.List^.Insert(NewStr(PersonalElement^.Point.Dat[c1].Name+'│'+PersonalElement^.Point.Dat[c1].Kod));
    PersonalList^.SetRange(PersonalList^.List^.Count);
   End;
End;{For}
  Dispose(PersonalElement,Done);
 End;{While}
System.Close(PersonalFile);
End
Else
 Begin
  st:=Bak;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;

If st[0]<>#0 Then
s:=Copy(st,1+CPersonal+1,CClientKod)
Else
s:=NoPersonalStr;
RFormatZerro(s,CClientKod);
PersonalList^.FocusItem(Location(PersonalList,S,False));


PersonalList^.HelpCtx:=$F957;
PersonalWindow^.Insert(PersonalList);
PrevCurrentLine:=Copy(PersonalList^.GetText(PersonalList^.Focused,PersonalList^.List^.Count),1+CPersonal+1,CClientKod);

PersonalWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;
c:=Desktop^.ExecView(PersonalWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Res in[2,3] Then
   St:=PersonalList^.GetText(PersonalList^.Focused,PersonalList^.List^.Count)
   Else St:=Bak;
1:
Dispose(COntrol,Done);
Dispose(PersonalWindow,Done);
end;



Procedure TPersonalWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  PersonalFile : File;
  PersonalElement : PBufPersonalType;
  c1,Count : Word;
begin
ClearFind;
DInfoMsg('Обновляю списки сотрудников...',False);
Cod:=PersonalList^.Focused;

     Assign (PersonalFile,Path^.Dat.ToSPR+'Personal.db');
     PersonalList^.NewList(Nil);
     PersonalList^.NewList(New(PTextCollection, Init(0,1)));

c:=IOResult;
Reset (PersonalFile,SizeOf(PersonalType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(PersonalFile)) Do
 Begin
    New(PersonalElement,Init);
    ReadBufPersonal(PersonalFile,PersonalElement,Count);
For c1:=1 To Count Do
Begin
  If PersonalElement^.Point.Dat[c1].Employ Then
   Begin
    Format (PersonalElement^.Point.Dat[c1].Name,CPersonal);
    PersonalList^.List^.Insert(NewStr(PersonalElement^.Point.Dat[c1].Name+
    '│'+PersonalElement^.Point.Dat[c1].Kod));
    PersonalList^.SetRange(PersonalList^.List^.Count);
   End;
End;{For}
  Dispose(PersonalElement,Done);
 End;
System.Close(PersonalFile);
If Cod<>0 Then Dec(Cod);

PersonalList^.FocusItem(Cod);
NoInfoMsg;
End
Else
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;
PrevCurrentLine[0]:=#0;
end;

Procedure TPersonalWindow.ImportSPR;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  PersonalFile : File;
  PersonalElement : PBufPersonalType;
  c1,Count : Word;
  txt : Text;
  SeparatorChar : ArtikulStr;
begin
ClearFind;
SeparatorChar:=';';
DInfoMsg('Экспортирую список сотрудников...',False);

Assign(txt,Path^.Dat.ToTemp+'personal.csv');
c:=IOResult;
Rewrite(txt);
c:=IOResult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+'Ошибка создания '+Path^.Dat.ToTemp+'personal.csv'+' Код:'+IntToStr(c,ckol),Nil,mfError+mfCancelButton);
  Exit;
 End;
Writeln(txt,DosToWin('Код')+SeparatorChar+DosToWin('Сотрудник'));



Assign (PersonalFile,Path^.Dat.ToSPR+'Personal.db');
c:=IOResult;
Reset (PersonalFile,SizeOf(PersonalType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(PersonalFile)) Do
 Begin
    New(PersonalElement,Init);
    ReadBufPersonal(PersonalFile,PersonalElement,Count);
For c1:=1 To Count Do
Begin
  If PersonalElement^.Point.Dat[c1].Employ Then
   Begin
    ChangeSeparator(PersonalElement^.Point.Dat[c1].Name);
    Writeln(txt,PersonalElement^.Point.Dat[c1].Kod+SeparatorChar+DosToWin(PersonalElement^.Point.Dat[c1].Name));
   End;
End;{For}
  Dispose(PersonalElement,Done);
 End;
System.Close(PersonalFile);

NoInfoMsg;
End
Else
 Begin
  System.Close(txt);
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;

c:=IOResult;
System.Close(txt);
c:=IOResult;

MessageBox(^M+#3'Данные успешно импортированы в '+Path^.Dat.ToTemp+'personal.csv!',Nil,
mfInformation+mfCancelButton);


end;




Destructor TPersonalWindow.Done;
Begin
ClearFind;
Dispose(PersonalList,Done);
TDialog.Done;
End;


procedure TPersonalWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;
    Op : StrNAme;
PersonalElement : PersonalType;


Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=PersonalList^.GetText(PersonalList^.Focused,PersonalList^.List^.Count);
  s:=Copy(s,1+CPersonal+1,CClientKod);

  R:=GetPersonalEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать элемент с кодом '+s+'. Элемент отмечена как удаленная!',False);
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

  If SetElementLock(FPersonal,s,Op) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg(Zanato1^+' '+s+Zanato2^+' '+Op+NoLock^,False);
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
  s:=PersonalList^.GetText(PersonalList^.Focused,PersonalList^.List^.Count);
  s:=Copy(s,1+CPersonal+1,CClientKod);

  r:=False;
  R:=GetPersonalEmploy(s);
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
Assign (F,Path^.Dat.ToSPR+'Personal.lck');

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
AddProtocol('Общая деблокировка персонала','','');
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
    {MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);}
    ClearEvent(Event);
    Exit;
   End;

     L:=False;
     If (PersonalList^.State and sfFocused <> 0) And (PersonalList^.List<>Nil)And(PersonalList^.List^.Count>=2) Then L:=True;

     If L Then
            Begin
     If Password(5) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=PersonalList^.GetText(PersonalList^.Focused,PersonalList^.List^.Count);
                s:=Copy(s,1+CPersonal+1,CClientKod);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=PersonalList^.GetText(PersonalList^.Focused,PersonalList^.List^.Count);
                 s:=Copy(s,1+CPersonal+1,CClientKod);

                 Assign (PersonalFile,Path^.Dat.ToSPR+'Personal.db');
                 PersonalElement.Name[0]:=#0;
                 PersonalElement.Kod:=s;
                 PersonalElement.Employ:=False;

  If Not (WriteLockPersonal(PersonalElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлу сотрудников !',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetElementUnLock(FPersonal,s));
     ClearEvent(Event);
     Exit;
    End
    Else
     RefreshCashOneSPR(bPersonal);


    Repeat
    Until (SetElementUnLock(FPersonal,s));
    AddProtoCol('Удаление сотрудника:'+s,'','');
    PersonalList^.List^.AtFree(PersonalList^.Focused);
    PersonalList^.SetRange(PersonalList^.List^.Count);
    If PersonalList^.Focused>0 Then   PersonalList^.FocusItem(PersonalList^.Focused);
    If (PersonalList^.Focused>=PersonalList^.List^.Count) and(PersonalList^.Focused>0) Then
    PersonalList^.FocusItem(PersonalList^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
          End;


kbAlt1         : If Password(5) Then UnlockAll;
kbF9           : CorrectPersonal;

{временно выключено пока не написана процедура добавления нового региона}
kbGrayPlus,kbAltF1,kbF4:
Begin
L:=False;
If(PersonalList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(PersonalList^.List<>Nil)And(PersonalList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;


      If AddPersonal(Event.KeyCode,PersonalElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(PersonalList^.List<>Nil)And(PersonalList^.List^.Count>=1) Then
           PersonalList^.List^.AtFree(PersonalList^.Focused);
        Format(PersonalElement.Name,CPersonal);
        PersonalList^.List^.Insert(NewStr(PersonalElement.Name+'│'+PersonalElement.Kod));
        PersonalList^.SetRange(PersonalList^.List^.Count);
        PersonalList^.FocusItem(LoCation(PersonalList,PersonalElement.Kod,False));
        Redraw;
       End
       Else
        Begin
         s:=PersonalList^.GetText(PersonalList^.Focused,PersonalList^.List^.Count);
         PersonalElement.Kod:=Copy(s,1+CPersonal+1,CClientKod);
        End;

   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=PersonalElement.Kod;
    Repeat
    Until (SetElementUnLock(FPersonal,Cod));
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
     (Event.Command = cmSelectPersonal) then ClearEvent(Event);

 if (Event.What = evBroadcast) and
     (Event.Command = cmViewSPRPersonal) then ClearEvent(Event);


  inherited HandleEvent(Event);
  {
  If (Desktop^.Current=PView(PersonalWindow)) And (Event.What <> EvKeyDown) Then
          Begin
                If (Client^.List <> Nil) And (Personal^.List^.Count>=1) Then
                 Begin
                  s:=Personal^.GetText(Personal^.Focused,Personal^.List^.Count);
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










Function GetRazdelEmpoyKod(Var TempArt:ArtikulStr):Boolean;
Var ElementFile:File;
    St : ArtikulStr;
    c,Count : Word;
    Find: Boolean;
    BE : PBufBazType;
    OldFileMode : Word;
Begin
GetRazdelEmpoyKod:=False;
St:=Copy(TempArt,1,CRazdelKod);
Assign(ElementFile,Path^.Dat.ToName+st+'.id');
OldFileMode:=FileMode;
FileMode:=$42;
c:=IOResult;
Reset(ElementFile,SizeOf(BazType));
c:=IOResult;
FileMode:=OldFileMode;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к файлу '+st+'.id!',nil,mfError+mfCancelButton);
 Exit;
End;

DInfoMsg('Читаю информацию о товарах...',False);
     Find:=False;
     While Not(Eof(ElementFile)) And Not(Find) Do
     Begin
      New(BE,Init);
      ReadBufBaz(ElementFile,BE,Count);
      For c:=1 To Count Do
       Begin
        If Not BE^.Point.Dat[c].Employ Then
         Begin
          Find:=True;
          TempArt:=BE^.Point.Dat[c].BazKod;
          Break;
         End;
       End;{For}
      Dispose(BE,Done);
     End;{While}

     If Not Find Then
      Begin
       NoInfoMsg;
       c:=IOResult;
       System.Close(ElementFile);
       c:=IOResult;
       Exit;
      End;

c:=IOResult;
  System.Close(ElementFile);
c:=IOResult;

If Find Then GetRazdelEmpoyKod:=True;
End;




Function CopyName(NameKod:ArtikulStr;Var NewNameKod:ArtikulStr):Boolean;
{
 1.достаем наименование
   иначе вообще идем на хрен

 2.ищем свободный код в текущем разделе
   и делаем его временно заблокированным TestEmployNameAndLock
   ежели неудача идем на хрен просим повторить операцию позже

 3.копируем из старой переменной в новую
   и пробуем сохранить если никак идем на хрен

 4.Рапортуем в протоколе о результатах
}

Var BakBBB,BBB: PBAzType;
    BakSkl,Skl: PSkladType;
    BakKDX,KDX : PSkladTypeNew;
    TempArt : ArtikulStr;
    Sertif : Boolean;
    Inform : StrName;
    Event : TEvent;
    c : Word;
Begin
CopyName:=False;

If (EnableNewTovar=0) Then
   Begin
    MessageBox(#3^M+#3'На данной рабочей станции операция запрещена!',Nil,mfError+mfCancelButton);
    Exit;
   End;



If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    Exit;
   End;

If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    Exit;
   End;

If Not(TestSetupKurs(FDate)) Then
   Begin
    Exit;
   End;


New(BakBBB,Init);
New(BakSkl,Init);
New(BakKDX,Init);

New(BBB,Init);
New(Skl,Init);
New(KDX,Init);


BakBBB^.Dat.BazKod:=NameKod;
BakSkl^.Dat.BazKod:=NameKod;
BakKDX^.Dat.BazKod:=StrToInt(NameKod);

   GetBazElement(NameKod,BakBBB^.Dat);
   GetSkladRecord(BakSkl);
   GetSkladNewRecord(BakKDX);

   TempArt:=NameKod;

If GetRazdelStatus(NameKod) Then Sertif:=True
Else Sertif:=False;

If Not(GetRazdelEmpoyKod(TempArt)) Then
 Begin
  Dispose(BakBBB,Done);
  Dispose(BakSkl,Done);
  Dispose(BakKDX,Done);

  Dispose(BBB,Done);
  Dispose(Skl,Done);
  Dispose(KDX,Done);
  MessageBox(^M+#3+NoPosition^,Nil,mfWarning+mfCancelButton);
  Exit;
 End;


If Not(TestEmployNameAndLock(TempArt,Inform)) Then
 Begin
  Dispose(BakBBB,Done);
  Dispose(BakSkl,Done);
  Dispose(BakKDX,Done);

  Dispose(BBB,Done);
  Dispose(Skl,Done);
  Dispose(KDX,Done);

  Beep;
  DInfoMsg('Позиция ['+TempArt+'] используется'+Inform+'. Попробуйте повторить попытку!',False);

     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
  Exit;
 End;


{начинаем клонирование}
 BBB^.Dat:=BakBBB^.Dat;
 BBB^.Dat.BazKod:=TempArt;
 BBB^.Dat.Caption:=CurrentPassword;


 If Not Sertif Then
Begin
 If BBB^.Dat.Main=1 Then
  Begin
   BBB^.Dat.FantomKod:=BakBBB^.Dat.FantomKod;
  End
 Else
  Begin
   BBB^.Dat.FantomKod:={TempArt}BakBBB^.Dat.BazKod;
   BBB^.Dat.Main:=1;
  End;
End
  Else
   Begin
    BBB^.Dat.FantomKod:=TempArt;
    BBB^.Dat.Main:=0;
   End;

 {BBB^.Dat.LockCaption:=CurrentPassword;}
 {BBB^.Dat.ComputerNameLocked:=NetComputerNAme;}

 Skl^.Dat:=BakSkl^.Dat;
 Skl^.Dat.DAte:=DateStringToDAte(DateMask,FDAte);
 Skl^.Dat.Employ:=True;
 Skl^.Dat.Locked:=False;
 Skl^.Dat.Time:=CurrentTime;
 Skl^.Dat.BazKod:=TempArt;

 Skl^.Dat.Input.Kol:='0';
 Skl^.Dat.Input.KolR:='0';
 Skl^.Dat.Input.StrihKod[0]:=#0;

 Skl^.Dat.Input.NSertif:=NoSertifStr;
 Skl^.Dat.Input.NGTD:=NoNGTDStr;
 Skl^.Dat.Input.Marka:=NoMarkaStr;
 Skl^.Dat.Input.SpecMarka:=NoSpecMarkaStr;
 Skl^.Dat.Input.Expert:=NoExpertStr;
 Skl^.Dat.Input.Godnost[0]:=#0;
 Skl^.Dat.Input.Virabotano[0]:=#0;

 For c:=1 To CDivision Do
  Begin
   Skl^.Dat.Input.Division[c,0]:=#0;
   Skl^.Dat.Input.DivisionR[c,0]:=#0;
  End;

 KDX^.Dat:=BakKDX^.Dat;
 KDX^.Dat.BazKod:=StrToInt(TempArt);
 KDX^.Dat.Kol:=0;
 KDX^.Dat.StrihKod[0]:=#0;
 KDX^.Dat.NSertif:=StrToInt(NoSertifStr);
 KDX^.Dat.Main:=BBB^.Dat.Main;
 KDX^.Dat.FantomKod:=StrToInt(BBB^.Dat.FantomKod);
 KDX^.Dat.Virabotano :=0;

{$IFDEF Pharm}
 Skl^.Dat.Input.NGTD:=NoNGTDStr;
 Skl^.Dat.Input.Godnost[0]:=#0;
 Skl^.Dat.Input.Virabotano[0]:=#0;
 KDX^.Dat.Virabotano :=0;
{$EndIF}


 NewNameKod:=TempArt;

 For c:=1 To CDivision Do KDX^.Dat.Division[c]:=0;
{заканчиваем клонирование}

{начинаем запись}

  {если не удалось записать информацию}
  If Not (WriteLockName(BBB^.Dat,Skl^.Dat,Kdx^.Dat)) Then
    Begin
     Repeat
     Until (SetNAmeUnLock(TempArt));
     AddProtocol('Ошибка при копирование наименования из '+BakBBB^.Dat.Name+' ('+BakBBB^.Dat.BazKod+')',
     'в '+BBB^.Dat.Name+' ('+BBB^.Dat.BazKod+')','');
     Dispose(BakBBB,Done);
     Dispose(BakSkl,Done);
     Dispose(BakKDX,Done);

     Dispose(BBB,Done);
     Dispose(Skl,Done);
     Dispose(KDX,Done);

     Exit;
    End;

   AddProtocol('Копирование наименования из '+BakBBB^.Dat.Name+' ('+BakBBB^.Dat.BazKod+')',
   'в '+BBB^.Dat.Name+' ('+BBB^.Dat.BazKod+')','');

   Repeat
   Until (SetNAmeUnLock(TempArt));
{закончили запись}

{уничтожаем старые экземпляры}
Dispose(BakBBB,Done);
Dispose(BakSkl,Done);
Dispose(BakKDX,Done);

RefreshCashOneRazdel(BBB^.Dat.BazKod);

Dispose(BBB,Done);
Dispose(Skl,Done);
Dispose(KDX,Done);

CopyName:=True;
End;


Var Vid : Word;
    ControlVid : PView;
    Edit : Boolean;



Function AddKassa(Cod:Integer; Var KassaElement:KassaOperationType):Boolean;
Label 1;
var
  R : TRect;
  AddKassaWin : PDialog;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  k : LongInt;
  Event:TEvent;
  KassaNum : PBox;
  KassaFile : KassaOperationFileType;
begin
ClearFind;


If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddKassa:=False;
    Exit;
   End;


If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    AddKassa:=False;
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    AddKassa:=False;
    Exit;
   End;

  If Not(Password(17)) Then
   Begin
    AddKassa:=False;
    Exit;
   End;

C:=IOResult;
AddKassa:=False;

Assign(KassaFile,Path^.Dat.ToSPR+'Kassa.db');

Reset(KassaFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу кассовых операций!',nil,mfError+mfCancelButton);
 AddKassa:=False;
 Exit;
End;

DInfoMsg('Читаю списки...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin
     KassaElement.Employ:=True;
     While Not(Eof(KassaFile)) And (KassaElement.Employ) Do
     begin
      ReadKassa(KassaFile,KassaElement);
     end;


     If Eof(KassaFile) And (KassaElement.Employ) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoPosition^,nil,mfWarning+mfCancelButton);
       System.Close(KassaFile);
       AddKassa:=False;
       Exit;
      End;
      s:=KassaElement.Kod;
      KassaElement.Name1[0]       :=#0;
      KassaElement.Name2[0]       :=#0;
      KassaElement.Status   :=0;
      KassaElement.Enable   :=0;
      KassaElement.Kod     :=NoKassaOperationStr;
    End;

  kbF4:Begin
     s:=Copy(KassaOperationList^.GetText(KassaOperationList^.Focused,KassaOperationList^.List^.Count),
	1+CKassaName+1,CClientKod);
     Seek(KassaFile,StrToInt(s));
     Repeat
      ReadKassa(KassaFile,KassaElement);
     Until (Eof(KassaFile)) Or (KassaElement.Kod=s);
     If Eof(KassaFile) And (KassaElement.Kod<>s) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoFound^,nil,mfError+mfCancelButton);
       System.Close(KassaFile);
       AddKassa:=False;
       Exit;
      End;
    End;
  Else;
 End;
System.Close(KassaFile);

1:



If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
Begin
R.Assign(13, 6, 66, 17);
New(AddKassaWin, Init(R, 'Добавить статью'));
End
Else
Begin
R.Assign(13, 6, 66, 12);
New(AddKassaWin, Init(R, 'Изменить статью'));
End;
AddKassaWin^.Options := AddKassaWin^.Options or ofCenterX or ofCenterY;

AddKassaWin^.Palette := dpCyanDialog;
AddKassaWin^.HelpCtx:=$E011;

R.Assign(4, 1, 23, 2);
Control := New(PStaticText, Init(R, 'Наименование статьи'));
AddKassaWin^.Insert(Control);


R.Assign(4, 2, 32, 3);
Control := New(PInputLine, Init(R, CKassaName));
AddKassaWin^.Insert(Control);

  R.Assign(1, 2, 4, 3);
  AddKassaWin^.Insert(New(PLabel, Init(R, '~1~:', Control)));

R.Assign(4, 3, 32, 4);
Control := New(PInputLine, Init(R, CKAssaName));
AddKassaWin^.Insert(Control);

  R.Assign(1, 3, 4, 4);
  AddKassaWin^.Insert(New(PLabel, Init(R, '~2~:', Control)));

R.Assign(35, 2, 52, 4);
Control := New(PRadioButtons, Init(R,
  NewSItem('~П~оступление',
  NewSItem('~Р~асход', Nil))));
AddKassaWin^.Insert(Control);

R.Assign(4, 4, 33, 5);
Control := New(PCheckboxes, Init(R,
  NewSItem('Разрешить ~и~спользование', Nil)));
AddKassaWin^.Insert(Control);



AddKassaWin^.SetData(KassaElement);


If (Cod = kbGrayPlus)Or (Cod=kbAltF1)  Then
Begin
 R.Assign(52, 6, 53, 10);
 Control := New(PScrollBar, Init(R));
 AddKassaWin^.Insert(Control);
 R.Assign(1, 6, 52, 10);
 KassaNum := New(PBox, Init(R, 6, PScrollbar(Control)));
 KassaNum^.NewList(New(PTextCollection, Init(0,1)));

Assign(KassaFile,Path^.Dat.ToSPR+'Kassa.db');
Reset (KassaFile);
 While Not(Eof(KassaFile)) Do
  Begin
   ReadKassa(KassaFile,KassaElement);
   If Not(KassaElement.Employ) Then
   Begin
   KassaNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+KassaElement.Kod));
   KassaNum^.SetRange(KassaNum^.List^.Count);
   KassaNum^.FocusItem(KassaNum^.List^.Count);
   End;
  End;
 System.Close(KassaFile);
 If Cod=kbF4 Then KassaNum^.FocusItem(LoCation(KassaNum,s,False))
 Else KassaNum^.FocusItem(0);

 AddKassaWin^.Insert(KassaNum);
 KassaNum^.HelpCtx:=$E011;

  R.Assign(1, 5, 17, 6);
  AddKassaWin^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', KassaNum)));
  AddKassaWin^.Insert(Control);
 End;



If Cod=kbF4 Then
 Begin
  R.Assign(33, 1, 45, 2);
  Control := New(PColoredText, Init(R, 'Код статьи:', $3E));
  AddKassaWin^.Insert(Control);
  R.Assign(45, 1, 49, 2);
  Control := New(PColoredText, Init(R, KassaElement.Kod,$3E));
  AddKassaWin^.Insert(Control);
 End;



AddKassaWin^.SelectNext(False);


NoInfoMsg;


c:=Desktop^.ExecView(AddKassaWin);

If c<>cmCancel Then
 Begin
    AddKassaWin^.GetData(KassaElement);

    DelSpaceRight(KassaElement.Name1);
    DelSpaceRight(KassaElement.Name2);

    If KassaElement.Name1[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название статьи!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=KassaNum^.GetText(KassaNum^.Focused,KassaNum^.List^.Count);
   s:=Copy(s,1+CKassaName+1,CClientKod);
  KassaNum^.NewList(Nil);
  Dispose(KassaNum,Done);
  End;


  Dispose(Control,Done);
  Dispose(AddKassaWin,Done);
    Goto 1;
   End;


    If KassaElement.Name2[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название2 статьи!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=KassaNum^.GetText(KassaNum^.Focused,KassaNum^.List^.Count);
   s:=Copy(s,1+CKassaName+1,CClientKod);
  KassaNum^.NewList(Nil);
  Dispose(KassaNum,Done);
  End;


  Dispose(Control,Done);
  Dispose(AddKassaWin,Done);
    Goto 1;
   End;

  C:=IOResult;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=KassaNum^.GetText(KassaNum^.Focused,KassaNum^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   If Not(TestEmployElementAndLock(FKassa,s)) Then
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
     Dispose(KassaNum,Done);
     Dispose(Control,Done);
     Dispose(AddKassaWin,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(KassaElement.Name1);
   UpStr(KassaElement.Name2);
   KassaElement.Employ:=True;

   If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then KassaElement.Kod:=s;


  {если не удалось записать информацию}
  If Not (WriteLockKassa(KassaElement)) Then
    Begin
     If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then Dispose(KassaNum,Done);
     Dispose(Control,Done);
     Dispose(AddKassaWin,Done);
     Repeat
     Until (SetElementUnLock(FKassa,s));
     Goto 1;
    End
    Else
     RefreshCashOneSPR(BKassa);

  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   AddProtocol('Добавление новой статьи:'+KassaElement.Name1+' ('+s+')','','');
   Repeat
   Until (SetElementUnLock(FKassa,s));
  End
  Else
   AddProtocol('Корректировка данных статьи:'+KassaElement.Name2+' ('+KassaElement.Kod+')','','');
  AddKassa:=True;
End;


If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
  KassaNum^.NewList(Nil);
  Dispose(KassaNum,Done);
  End;

  Dispose(Control,Done);

  Dispose(AddKassaWin,Done);

End;





Procedure TKassaOperationWindow.ShowKassaOperationList(RO,Reg:Boolean;Var st:AllStr;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  Bak : String;
  c: Word;
  c1,Count : Word;
  KassaOperationFile : File;
  KassaOperationElement : PBufKassaOperationType;
begin
Edit:=False;
Edit:=Reg;
Bak:=st;
ClearFind;
DInfoMsg('Читаю списки...',False);

If Not RO Then
Begin
If Not(Password(17)) Then Edit:=False
End;

Res:=0;
R.Assign(45, 5, 79, 22);
New(KassaOperationWindow, Init(R, 'Выбор статьи'));
KassaOperationWindow^.HelpCtx:=$F957;
If Not RO Then
KassaOperationWindow^.EnableAdding:=False
Else
KassaOperationWindow^.EnableAdding:=True;

R.Assign(33, 1, 34, 16);
Control := New(PScrollBar, Init(R));
KassaOperationWindow^.Insert(Control);

R.Assign(1, 1, 33, 16);
KassaOperationList := New(PBox, Init(R, 1, PScrollbar(Control)));
KassaOperationList^.NewList(New(PTextCollection, Init(0,1)));
Assign (KassaOperationFile,Path^.Dat.ToSPR+'Kassa.db');
c:=IOResult;
Reset (KassaOperationFile,SizeOf(KassaOperationType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(KassaOperationFile)) Do
 Begin
    New(KassaOperationElement,Init);
    ReadBufKassa(KassaOperationFile,KassaOperationElement,Count);
For c1:=1 To Count Do
Begin
  If KassaOperationElement^.Point.Dat[c1].Employ Then
   Begin
    Format (KassaOperationElement^.Point.Dat[c1].Name2,CKassaName);
    KassaOperationList^.List^.Insert(NewStr(KassaOperationElement^.Point.Dat[c1].Name2+'│'+
    KassaOperationElement^.Point.Dat[c1].Kod));
    KassaOperationList^.SetRange(KassaOperationList^.List^.Count);
   End;
End;{For}
  Dispose(KassaOperationElement,Done);
 End;{While}
System.Close(KassaOperationFile);
End
Else
 Begin
  st:=Bak;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;

If st[0]<>#0 Then
s:=Copy(st,1+CKassaName+1,CClientKod)
Else
s:=NoKassaOperationStr;
RFormatZerro(s,CClientKod);
KassaOperationList^.FocusItem(Location(KassaOperationList,S,False));


KassaOperationList^.HelpCtx:=$F957;
KassaOperationWindow^.Insert(KassaOperationList);
PrevCurrentLine:=Copy(KassaOperationList^.GetText(KassaOperationList^.Focused,KassaOperationList^.List^.Count),
1+CKassaName+1,CClientKod);

Vid:=1;

If Edit Then
Begin
R.Assign(1, 16, 15, 17);
ControlVid := New(PRadioButtons, Init(R,
  NewSItem('1',
  NewSItem('~2~', Nil))));
KassaOperationWindow^.Insert(ControlVid);

ControlVid^.SetData(Vid);
End;


KassaOperationWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;
c:=Desktop^.ExecView(KassaOperationWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Res in[2,3] Then
   St:=KassaOperationList^.GetText(KassaOperationList^.Focused,KassaOperationList^.List^.Count)
   Else St:=Bak;
1:
Dispose(COntrol,Done);
If Edit Then
Dispose(COntrolVid,Done);
Dispose(KassaOperationWindow,Done);
end;



Procedure TKassaOperationWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  KassaOperationFile : File;
  KassaOperationElement : PBufKassaOperationType;
  c1,Count : Word;
begin
ClearFind;
DInfoMsg('Обновляю список статей...',False);
Cod:=KassaOperationList^.Focused;

     Assign (KassaOperationFile,Path^.Dat.ToSPR+'Kassa.db');
     KassaOperationList^.NewList(Nil);
     KassaOperationList^.NewList(New(PTextCollection, Init(0,1)));

c:=IOResult;
Reset (KassaOperationFile,SizeOf(KassaOperationType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(KassaOperationFile)) Do
 Begin
    New(KassaOperationElement,Init);
    ReadBufKassa(KassaOperationFile,KassaOperationElement,Count);
For c1:=1 To Count Do
Begin
  If KassaOperationElement^.Point.Dat[c1].Employ Then
   Begin
    If Vid=0 Then
    KassaOperationElement^.Point.Dat[c1].Name2:=KassaOperationElement^.Point.Dat[c1].Name1;

    Format (KassaOperationElement^.Point.Dat[c1].Name2,CKassaName);
    KassaOperationList^.List^.Insert(NewStr(KassaOperationElement^.Point.Dat[c1].Name2+
    '│'+KassaOperationElement^.Point.Dat[c1].Kod));
    KassaOperationList^.SetRange(KassaOperationList^.List^.Count);
   End;
End;{For}
  Dispose(KassaOperationElement,Done);
 End;
System.Close(KassaOperationFile);
If Cod<>0 Then Dec(Cod);

KassaOperationList^.FocusItem(Cod);
NoInfoMsg;
End
Else
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;
PrevCurrentLine[0]:=#0;
end;



Procedure TKassaOperationWindow.ImportSPR;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  KassaOperationFile : File;
  KassaOperationElement : PBufKassaOperationType;
  c1,Count : Word;
  Txt : Text;
  SeparatorChar : ArtikulStr;
begin
If Not Password(20) Then Exit;
ClearFind;
SeparatorChar:=';';
DInfoMsg('Экспортирую список статей...',False);


Assign(txt,Path^.Dat.ToTemp+'kassaop.csv');
c:=IOResult;
Rewrite(txt);
c:=IOResult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+'Ошибка создания '+Path^.Dat.ToTemp+'kassaop.csv'+' Код:'+IntToStr(c,ckol),Nil,mfError+mfCancelButton);
  Exit;
 End;
Writeln(txt,DosToWin('Код')+SeparatorChar+DosToWin('Наименование статьи 1; Наименование статьи 2'));



Assign (KassaOperationFile,Path^.Dat.ToSPR+'Kassa.db');

c:=IOResult;
Reset (KassaOperationFile,SizeOf(KassaOperationType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(KassaOperationFile)) Do
 Begin
    New(KassaOperationElement,Init);
    ReadBufKassa(KassaOperationFile,KassaOperationElement,Count);
For c1:=1 To Count Do
Begin
  If KassaOperationElement^.Point.Dat[c1].Employ Then
   Begin
    ChangeSeparator(KassaOperationElement^.Point.Dat[c1].Name1);
    ChangeSeparator(KassaOperationElement^.Point.Dat[c1].Name2);
    Writeln(txt,KassaOperationElement^.Point.Dat[c1].Kod+SeparatorChar+
    DosToWin(KassaOperationElement^.Point.Dat[c1].Name1+SeparatorChar+KassaOperationElement^.Point.Dat[c1].Name2));
   End;
End;{For}
  Dispose(KassaOperationElement,Done);
 End;
System.Close(KassaOperationFile);
End
Else
 Begin
  System.Close(txt);
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы ! Код:'+IntToStr(c,CKol),nil,mfError+mfCanCelButton);
  Exit;
 End;

NoInfoMsg;

c:=IOResult;
System.Close(txt);
c:=IOResult;

MessageBox(^M+#3'Данные успешно импортированы в '+Path^.Dat.ToTemp+'kassaop.csv!',Nil,
mfInformation+mfCancelButton);


Redraw;


end;


Destructor TKassaOperationWindow.Done;
Begin
ClearFind;
Dispose(KassaOperationList,Done);
TDialog.Done;
End;


procedure TKassaOperationWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;
    Op : StrNAme;
    KO : KassaOperationType;


Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=KassaOperationList^.GetText(KassaOperationList^.Focused,KassaOperationList^.List^.Count);
  s:=Copy(s,1+CKassaName+1,CClientKod);

  R:=GetKassaOperationEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать элемент с кодом '+s+'. Элемент отмечена как удаленная!',False);
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

  If SetElementLock(FKassa,s,Op) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg(Zanato1^+' '+s+Zanato2^+' '+Op+NoLock^,False);
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
  s:=KassaOperationList^.GetText(KassaOperationList^.Focused,KassaOperationList^.List^.Count);
  s:=Copy(s,1+CKassaName+1,CClientKod);

  r:=False;
  R:=GetKassaOperationEmploy(s);
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
Assign (F,Path^.Dat.ToSPR+'Kassa.lck');

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
AddProtocol('Общая деблокировка статей','','');
End;



begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbDel: Begin
If EnableAdding Then
Begin

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
     If (KassaOperationList^.State and sfFocused <> 0) And (KassaOperationList^.List<>Nil)And
	(KassaOperationList^.List^.Count>=2) Then L:=True;

     If L Then
            Begin
     If Password(20) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=KassaOperationList^.GetText(KassaOperationList^.Focused,KassaOperationList^.List^.Count);
                s:=Copy(s,1+CKassaName+1,CClientKod);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=KassaOperationList^.GetText(KassaOperationList^.Focused,KassaOperationList^.List^.Count);
                 s:=Copy(s,1+CKassaName+1,CClientKod);

                 Assign (KassaOperationFile,Path^.Dat.ToSPR+'Kassa.db');
                 KO.Name1[0]:=#0;
                 KO.Name2[0]:=#0;
                 KO.Kod:=s;
                 KO.Employ:=False;

  If Not (WriteLockKassa(KO)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к базе статей !',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetElementUnLock(FKassa,s));
     ClearEvent(Event);
     Exit;
    End
    Else
     RefreshCashOneSPR(bKassa);


    Repeat
    Until (SetElementUnLock(FKassa,s));
    AddProtoCol('Удаление статьи:'+s,'','');
    KassaOperationList^.List^.AtFree(KassaOperationList^.Focused);
    KassaOperationList^.SetRange(KassaOperationList^.List^.Count);
    If KassaOperationList^.Focused>0 Then   KassaOperationList^.FocusItem(KassaOperationList^.Focused);
    If (KassaOperationList^.Focused>=KassaOperationList^.List^.Count) and(KassaOperationList^.Focused>0) Then
    KassaOperationList^.FocusItem(KassaOperationList^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
End;
          End;


kbAlt1         : If Password(5) Then UnlockAll;

kbF9           : CorrectKassa;

{временно выключено пока не написана процедура добавления нового региона}
kbGrayPlus,kbAltF1,kbF4:
Begin
L:=False;
If EnableAdding Then
Begin
If(KassaOperationList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(KassaOperationList^.List<>Nil)And(KassaOperationList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;

      If AddKassa(Event.KeyCode,KO) Then
       Begin
        If (Event.KeyCode=kbF4)And(KassaOperationList^.List<>Nil)And(KassaOperationList^.List^.Count>=1) Then
        KassaOperationList^.List^.AtFree(KassaOperationList^.Focused);
        If Vid=0 Then
        KO.Name2:=KO.Name1;
        Format(KO.Name2,CKassaName);
        KassaOperationList^.List^.Insert(NewStr(KO.Name2+'│'+KO.Kod));
        KassaOperationList^.SetRange(KassaOperationList^.List^.Count);
        KassaOperationList^.FocusItem(LoCation(KassaOperationList,KO.Kod,False));
        Redraw;
       End
       Else
        Begin
         s:=KassaOperationList^.GetText(KassaOperationList^.Focused,KassaOperationList^.List^.Count);
         KO.Kod:=Copy(s,1+CKassaName+1,CClientKod);
        End;

   End;

 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=KO.Kod;
    Repeat
    Until (SetElementUnLock(FKassa,Cod));
   End;
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
  Else;
  End;{evCommand}
      Else;
      End;{*Case*}



  If (Desktop^.Current=PView(KassaOperationWindow)) And (Event.What <> EvKeyDown) Then
Begin

  If Not(Edit) Then
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
End;
End;

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
     (Event.Command = cmSelectKassaOperation) then ClearEvent(Event);

 if (Event.What = evBroadcast) and
     (Event.Command = cmViewSPRKassa) then ClearEvent(Event);

  inherited HandleEvent(Event);


  If (Desktop^.Current=PView(KassaOperationWindow)) And (Event.What <> EvKeyDown) Then
          Begin
          If Edit Then
          Begin
          if (ControlVid^.State and sfFocused <> 0)Then
              Begin
               ControlVid^.GetData(Test);
               If Test <> Vid Then
               Begin
                  Vid:=Test;
                  Refresh;
                  Redraw;
               End;
              End;
          End;
          End;


  {
  If (Desktop^.Current=PView(KassaOperationWindow)) And (Event.What <> EvKeyDown) Then
          Begin
                If (Client^.List <> Nil) And (KassaOperation^.List^.Count>=1) Then
                 Begin
                  s:=KassaOperation^.GetText(KassaOperation^.Focused,KassaOperation^.List^.Count);
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



Procedure TMeraWindow.ShowMeraList(Var st:AllStr;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  Bak : String;
  c: Word;
  c1,Count : Word;
  MeraFile : File;
  MeraElement : PBufMeraType;
begin
Bak:=st;
ClearFind;
DInfoMsg('Читаю списки...',False);

Res:=0;
R.Assign(56, 5, 79, 22);
New(MeraWindow, Init(R, 'Выбор ед.изм.'));

R.Assign(22, 1, 23, 16);
Control := New(PScrollBar, Init(R));
MeraWindow^.Insert(Control);

R.Assign(1, 1, 22, 16);
MeraList := New(PBox, Init(R, 1, PScrollbar(Control)));
MeraList^.NewList(New(PTextCollection, Init(0,1)));
Assign (MeraFile,Path^.Dat.ToSPR+'mera.db');
c:=IOResult;
Reset (MeraFile,SizeOf(MeraType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(MeraFile)) Do
 Begin
    New(MeraElement,Init);
    ReadBufMera(MeraFile,MeraElement,Count);
For c1:=1 To Count Do
Begin
  If MeraElement^.Point.Dat[c1].Employ Then
   Begin
    Format (MeraElement^.Point.Dat[c1].Mera,CMera);
    MeraList^.List^.Insert(NewStr(MeraElement^.Point.Dat[c1].Mera+'│'+MeraElement^.Point.Dat[c1].Kod));
    MeraList^.SetRange(MeraList^.List^.Count);
   End;
End;{For}
  Dispose(MeraElement,Done);
 End;{While}
System.Close(MeraFile);
End
Else
 Begin
  st:=Bak;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;

If st[0]<>#0 Then
s:=Copy(st,1+CMera+1,CClientKod)
Else
s:=NoMeraStr;
RFormatZerro(s,CClientKod);
MeraList^.FocusItem(Location(MeraList,S,False));


MeraList^.HelpCtx:=$F371;
MeraWindow^.Insert(MeraList);
PrevCurrentLine:=Copy(MeraList^.GetText(MeraList^.Focused,MeraList^.List^.Count),1+CMera+1,CClientKod);

MeraWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;
c:=Desktop^.ExecView(MeraWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Res in[2,3] Then
   St:=MeraList^.GetText(MeraList^.Focused,MeraList^.List^.Count)
   Else St:=Bak;
1:
Dispose(COntrol,Done);
Dispose(MeraWindow,Done);
end;



Procedure TMeraWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  MeraFile : File;
  MeraElement : PBufMeraType;
  c1,Count : Word;
begin
ClearFind;
DInfoMsg('Обновляю списки единиц.измерения...',False);
Cod:=MeraList^.Focused;

     Assign (MeraFile,Path^.Dat.ToSPR+'mera.db');
     MeraList^.NewList(Nil);
     MeraList^.NewList(New(PTextCollection, Init(0,1)));

c:=IOResult;
Reset (MeraFile,SizeOf(MeraType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(MeraFile)) Do
 Begin
    New(MeraElement,Init);
    ReadBufMera(MeraFile,MeraElement,Count);
For c1:=1 To Count Do
Begin
  If MeraElement^.Point.Dat[c1].Employ Then
   Begin
    Format (MeraElement^.Point.Dat[c1].Mera,CMera);
    MeraList^.List^.Insert(NewStr(MeraElement^.Point.Dat[c1].Mera+'│'+MeraElement^.Point.Dat[c1].Kod));
    MeraList^.SetRange(MeraList^.List^.Count);
   End;
End;{For}
  Dispose(MeraElement,Done);
 End;
System.Close(MeraFile);
If Cod<>0 Then Dec(Cod);

MeraList^.FocusItem(Cod);
NoInfoMsg;
End
Else
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;
PrevCurrentLine[0]:=#0;
end;


Procedure TMeraWindow.ImportSPR;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  MeraFile : File;
  MeraElement : PBufMeraType;
  c1,Count : Word;
  txt : Text;
  SeparatorChar : ArtikulStr;

begin
ClearFind;
SeparatorChar:=';';
DInfoMsg('Экспортирую списки ...',False);

Assign(txt,Path^.Dat.ToTemp+'mera.csv');
c:=IOResult;
Rewrite(txt);
c:=IOResult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+'Ошибка создания '+Path^.Dat.ToTemp+'mera.csv'+' Код:'+IntToStr(c,ckol),Nil,mfError+mfCancelButton);
  Exit;
 End;
Writeln(txt,DosToWin('Код')+SeparatorChar+DosToWin('Единица измерения'));


Assign (MeraFile,Path^.Dat.ToSPR+'mera.db');
c:=IOResult;
Reset (MeraFile,SizeOf(MeraType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(MeraFile)) Do
 Begin
    New(MeraElement,Init);
    ReadBufMera(MeraFile,MeraElement,Count);
For c1:=1 To Count Do
Begin
  If MeraElement^.Point.Dat[c1].Employ Then
   Begin
    RFormatZerro(MeraElement^.Point.Dat[c1].Kod,CClientKod);
    ChangeSeparator(MeraElement^.Point.Dat[c1].Mera);
    Writeln(txt,MeraElement^.Point.Dat[c1].Kod+SeparatorChar+DosToWin(MeraElement^.Point.Dat[c1].Mera));
   End;
End;{For}
  Dispose(MeraElement,Done);
 End;
System.Close(MeraFile);
NoInfoMsg;
End
Else
 Begin
  System.Close(txt);
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы ! Код:'+IntToStr(c,CKol),nil,mfError+mfCanCelButton);
  Exit;
 End;

c:=IOResult;
System.Close(txt);
c:=IOResult;

MessageBox(^M+#3'Данные успешно импортированы в '+Path^.Dat.ToTemp+'mera.csv!',Nil,
mfInformation+mfCancelButton);



Redraw;
end;




Destructor TMeraWindow.Done;
Begin
ClearFind;
Dispose(MeraList,Done);
TDialog.Done;
End;


procedure TMeraWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;
    Op : StrNAme;
    MeraElement : MeraType;


Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=MeraList^.GetText(MeraList^.Focused,MeraList^.List^.Count);
  s:=Copy(s,1+CMera+1,CClientKod);

  R:=GetMeraEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать элемент с кодом '+s+'. Элемент отмечена как удаленная!',False);
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

  If SetElementLock(FMera,s,Op) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg(Zanato1^+' '+s+Zanato2^+' '+Op+NoLock^,False);
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
  s:=MeraList^.GetText(MeraList^.Focused,MeraList^.List^.Count);
  s:=Copy(s,1+CMera+1,CClientKod);

  r:=False;
  R:=GetMeraEmploy(s);
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
Assign (F,Path^.Dat.ToSPR+'mera.lck');

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
AddProtocol('Общая деблокировка единиц измерения','','');
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
     If (MeraList^.State and sfFocused <> 0) And (MeraList^.List<>Nil)And(MeraList^.List^.Count>=2) Then L:=True;

     If L Then
            Begin
     If Password(5) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=MeraList^.GetText(MeraList^.Focused,MeraList^.List^.Count);
                s:=Copy(s,1+CMera+1,CClientKod);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=MeraList^.GetText(MeraList^.Focused,MeraList^.List^.Count);
                 s:=Copy(s,1+CMera+1,CClientKod);

                 Assign (MeraFile,Path^.Dat.ToSPR+'mera.db');
                 MeraElement.Mera[0]:=#0;
                 MeraElement.Kod:=s;
                 MeraElement.Employ:=False;

  If Not (WriteLockMera(MeraElement)) Then
    Begin
     MessageBox(^M+#3+ErrorOpen^+' '+Path^.Dat.ToSPR+'mera.db',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetElementUnLock(FMera,s));
     ClearEvent(Event);
     Exit;
    End
    Else
     RefreshCashOneSPR(bMera);


    Repeat
    Until (SetElementUnLock(FMera,s));
    AddProtoCol('Удаление единицы измерения:'+s,'','');
    MeraList^.List^.AtFree(MeraList^.Focused);
    MeraList^.SetRange(MeraList^.List^.Count);
    If MeraList^.Focused>0 Then   MeraList^.FocusItem(MeraList^.Focused);
    If (MeraList^.Focused>=MeraList^.List^.Count) and(MeraList^.Focused>0) Then
    MeraList^.FocusItem(MeraList^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
          End;


kbAlt1         : If Password(5) Then UnlockAll;
kbF9           : CorrectMera;

{временно выключено пока не написана процедура добавления нового региона}
kbGrayPlus,kbAltF1,kbF4:
Begin
L:=False;
If(MeraList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(MeraList^.List<>Nil)And(MeraList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
      If AddMera(Event.KeyCode,MeraElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(MeraList^.List<>Nil)And(MeraList^.List^.Count>=1) Then
           MeraList^.List^.AtFree(MeraList^.Focused);
        Format(MeraElement.Mera,CMera);
        MeraList^.List^.Insert(NewStr(MeraElement.Mera+'│'+MeraElement.Kod));
        MeraList^.SetRange(MeraList^.List^.Count);
        MeraList^.FocusItem(LoCation(MeraList,MeraElement.Kod,False));
        Redraw;
       End
       Else
        Begin
         s:=MeraList^.GetText(MeraList^.Focused,MeraList^.List^.Count);
         MeraElement.Kod:=Copy(s,1+CMera+1,CClientKod);
        End;

   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=MeraElement.Kod;
    Repeat
    Until (SetElementUnLock(FMera,Cod));
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
     (Event.Command = cmSelectMera) then ClearEvent(Event);

 if (Event.What = evBroadcast) and
     (Event.Command = cmViewSPRMera) then ClearEvent(Event);


  inherited HandleEvent(Event);
  {
  If (Desktop^.Current=PView(MeraWindow)) And (Event.What <> EvKeyDown) Then
          Begin
                If (Client^.List <> Nil) And (Mera^.List^.Count>=1) Then
                 Begin
                  s:=Mera^.GetText(Mera^.Focused,Mera^.List^.Count);
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



Procedure TBankWindow.ShowBankList(Var st:TMyStringNew;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  Bak : String;
  c: Word;
  c1,Count : Word;
  BankFile : File;
  BankElement : PBufBankType;
begin
Bak:=st;
ClearFind;
DInfoMsg('Читаю списки...',False);

Res:=0;
{
R.Assign(30, 5, 79, 22);
New(MarkaWindow, Init(R, 'Выбор акцизной марки'));

R.Assign(48, 1, 49, 16);
Control := New(PScrollBar, Init(R));
MarkaWindow^.Insert(Control);

R.Assign(1, 1, 48, 16);
}
R.Assign(26, 5, 79, 22);
New(BankWindow, Init(R, 'Выбор банка'));

R.Assign(52, 1, 53, 16);
Control := New(PScrollBar, Init(R));
BankWindow^.Insert(Control);

R.Assign(1, 1, 52, 16);
BankList := New(PBox, Init(R, 1, PScrollbar(Control)));
BankList^.NewList(New(PTextCollection, Init(0,1)));
Assign (BankFile,Path^.Dat.ToSPR+'Banks.db');
c:=IOResult;
Reset (BankFile,SizeOf(BankType));
c:=IOResult;

If c=0 Then
Begin
While Not(Eof(BankFile)) Do
 Begin
    New(BankElement,Init);
    ReadBufBank(BankFile,BankElement,Count);

For c1:=1 To Count Do
Begin
  If BankElement^.Point.Dat[c1].Employ Then
   Begin
    Format (BankElement^.Point.Dat[c1].FullName,CAll);
    BankList^.List^.Insert(NewStr(BankElement^.Point.Dat[c1].FullName+'│'+BankElement^.Point.Dat[c1].Kod));
    BankList^.SetRange(BankList^.List^.Count);
   End;
End;{For}

  Dispose(BankElement,Done);
 End;{While}
System.Close(BankFile);
End
Else
 Begin
  st:=Bak;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;

If st[0]<>#0 Then
s:=Copy(st,1+40+1,CClientKod)
Else
s:=NoBankStr;
RFormatZerro(s,CClientKod);
BankList^.FocusItem(Location(BankList,S,False));


BankList^.HelpCtx:=$F957;

BankWindow^.Insert(BankList);
PrevCurrentLine:=Copy(BankList^.GetText(BankList^.Focused,BankList^.List^.Count),1+CAll+1,CClientKod);

BankWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;
c:=Desktop^.ExecView(BankWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If c=CmNo Then Res:=0;
{
   MemC(IntToStr(c,CKol));
   MemC(IntToStr(Res,CKol));
}
   If Res in[2,3] Then
   St:=BankList^.GetText(BankList^.Focused,BankList^.List^.Count)
   Else St:=Bak;

1:
Dispose(COntrol,Done);
Dispose(BankWindow,Done);
end;



Procedure TBankWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  BankFile : File;
  BankElement : PBufBankType;
  c1,Count : Word;
begin
ClearFind;
DInfoMsg('Обновляю список банков...',False);
Cod:=BankList^.Focused;

     Assign (BankFile,Path^.Dat.ToSPR+'Banks.db');
     BankList^.NewList(Nil);
     BankList^.NewList(New(PTextCollection, Init(0,1)));

c:=IOResult;
Reset (BankFile,SizeOf(BankType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(BankFile)) Do
 Begin
    New(BankElement,Init);
    ReadBufBank(BankFile,BankElement,Count);
For c1:=1 To Count Do
Begin
  If BankElement^.Point.Dat[c1].Employ Then
   Begin
    Format (BankElement^.Point.Dat[c1].FullName,CAll);
    BankList^.List^.Insert(NewStr(BankElement^.Point.Dat[c1].FullName+'│'+BankElement^.Point.Dat[c1].Kod));
    BankList^.SetRange(BankList^.List^.Count);
   End;
End;{For}
  Dispose(BankElement,Done);
 End;
System.Close(BankFile);
If Cod<>0 Then Dec(Cod);

BankList^.FocusItem(Cod);
NoInfoMsg;
End
Else
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;
PrevCurrentLine[0]:=#0;
end;


Procedure TBankWindow.ImportSPR;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  BankFile : File;
  BankElement : PBufBankType;
  c1,Count : Word;
  txt : Text;
  SeparatorChar : ArtikulStr;
begin
ClearFind;
SeparatorChar:=';';
DInfoMsg('Экспортирую список банков...',False);


Assign(txt,Path^.Dat.ToTemp+'banks.csv');
c:=IOResult;
Rewrite(txt);
c:=IOResult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+'Ошибка создания '+Path^.Dat.ToTemp+'banks.csv'+' Код:'+IntToStr(c,ckol),Nil,mfError+mfCancelButton);
  Exit;
 End;
Writeln(txt,DosToWin('Код')+SeparatorChar+DosToWin('Наименование банка'));



Assign (BankFile,Path^.Dat.ToSPR+'Banks.db');
c:=IOResult;
Reset (BankFile,SizeOf(BankType));
c:=IOResult;
If c=0 Then
Begin

While Not(Eof(BankFile)) Do
 Begin
    New(BankElement,Init);
    ReadBufBank(BankFile,BankElement,Count);
For c1:=1 To Count Do
Begin
  If BankElement^.Point.Dat[c1].Employ Then
   Begin
    ChangeSeparator(BankElement^.Point.Dat[c1].FullName);
    Writeln(txt,BankElement^.Point.Dat[c1].Kod+SeparatorChar+DosToWin(BankElement^.Point.Dat[c1].FullName));
   End;
End;{For}
  Dispose(BankElement,Done);
 End;
System.Close(BankFile);
NoInfoMsg;
End
Else
 Begin
  System.Close(txt);
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;


c:=IOResult;
System.Close(txt);
c:=IOResult;

MessageBox(^M+#3'Данные успешно импортированы в '+Path^.Dat.ToTemp+'banks.csv!',Nil,
mfInformation+mfCancelButton);


end;


Destructor TBankWindow.Done;
Begin
ClearFind;
Dispose(BankList,Done);
TDialog.Done;
End;


procedure TBankWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;
    Op : StrNAme;
    BankElement : BankType;
    BankFile : File Of BankType;


Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=BankList^.GetText(BankList^.Focused,BankList^.List^.Count);
  s:=Copy(s,1+CAll+1,CClientKod);

  R:=GetBankEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать элемент с кодом '+s+'. Элемент отмечена как удаленная!',False);
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

  If SetElementLock(FBank,s,Op) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg(Zanato1^+' '+s+Zanato2^+' '+Op+NoLock^,False);
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
  s:=BankList^.GetText(BankList^.Focused,BankList^.List^.Count);
  s:=Copy(s,1+CAll+1,CClientKod);

  r:=False;
  R:=GetBankEmploy(s);
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
Assign (F,Path^.Dat.ToSPR+'Banks.lck');

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
AddProtocol('Общая деблокировка банков','','');
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
     If (BankList^.State and sfFocused <> 0) And (BankList^.List<>Nil)And(BankList^.List^.Count>=2) Then L:=True;

     If L Then
            Begin
     If Password(5) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=BankList^.GetText(BankList^.Focused,BankList^.List^.Count);
                s:=Copy(s,1+CAll+1,CClientKod);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=BankList^.GetText(BankList^.Focused,BankList^.List^.Count);
                 s:=Copy(s,1+CAll+1,CClientKod);

                 Assign (BankFile,Path^.Dat.ToSPR+'Banks.db');
                 BankElement.FullName[0]:=#0;
                 BankElement.Kod:=s;
                 BankElement.Employ:=False;

  If Not (WriteLockBank(BankElement)) Then
    Begin
     MessageBox(^M+#3+ErrorOpen^+' '+Path^.Dat.ToSPR+'Banks.db',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetElementUnLock(FBank,s));
     ClearEvent(Event);
     Exit;
    End
    Else
     RefreshCashOneSPR(bBank);


    Repeat
    Until (SetElementUnLock(FBank,s));
    AddProtoCol('Удаление банк:'+s,'','');
    BankList^.List^.AtFree(BankList^.Focused);
    BankList^.SetRange(BankList^.List^.Count);
    If BankList^.Focused>0 Then   BankList^.FocusItem(BankList^.Focused);
    If (BankList^.Focused>=BankList^.List^.Count) and(BankList^.Focused>0) Then
    BankList^.FocusItem(BankList^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
          End;

kbAlt1         : If Password(5) Then UnlockAll;

kbF9           : CorrectBank;

{временно выключено пока не написана процедура добавления нового региона}
kbGrayPlus,kbAltF1,kbF4:
Begin
L:=False;
If(BankList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(BankList^.List<>Nil)And(BankList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;


      If AddBank(Event.KeyCode,BankElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(BankList^.List<>Nil)And(BankList^.List^.Count>=1) Then
           BankList^.List^.AtFree(BankList^.Focused);
        Format(BankElement.FullName,CAll);
        BankList^.List^.Insert(NewStr(BankElement.FullName+'│'+BankElement.Kod));
        BankList^.SetRange(BankList^.List^.Count);
        BankList^.FocusItem(LoCation(BankList,BankElement.Kod,False));
        Redraw;
       End
       Else
        Begin
         s:=BankList^.GetText(BankList^.Focused,BankList^.List^.Count);
         BankElement.Kod:=Copy(s,1+CAll+1,CClientKod);
        End;

   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=BankElement.Kod;
    Repeat
    Until (SetElementUnLock(FBank,Cod));
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
     (Event.Command = cmSelectBank) then ClearEvent(Event);

 if (Event.What = evBroadcast) and
     (Event.Command = cmViewSPRBank) then ClearEvent(Event);


  inherited HandleEvent(Event);

  ClearEvent(Event);
end;






End.