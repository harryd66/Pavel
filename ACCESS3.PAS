
{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Access3;

Interface

Uses Dialogs,Glob,Drivers,ServStr,MyCAlc;


(*
Type
  PLinkGroupWindow = ^TLinkGroupWindow;
  TLinkGroupWindow = object(TDialog)
         Calc    : PMyCalculator;
         procedure Start(LinkArt:ArtikulStr);
         procedure FormReport;
         procedure Refresh;
         procedure DrawCurrent;
         procedure HandleEvent(var Event: TEvent); virtual;
         Destructor Done;Virtual;
  end;
*)

Type
    PGroupWindow= ^TGroupWindow;
    TGroupWindow = object(TDialog)
    {lnk : PLinkGroupWindow;}
    Procedure ShowGroupList(Var st:AllStr;Var Res: Word);
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type
    PRewGroupWindow= ^TRewGroupWindow;
    TRewGroupWindow = object(TDialog)
    Procedure ShowRewGroupList(Var st:AllStr;Var Res: Word);
    Procedure RefreshRew;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;

Procedure SortNKLIDX (Var L:PSuperMarketType);

Implementation

{$I Compile.INC}

Uses Printers,App,Views,Objects,MsgBox,Serv,
     ColorTxt,Validate,DbEngine,Memory,TpDate,Utils,
     Protect,Net,NetDbEng,NetCall,WinDos;

Var

   PrevCurrentLine : TMyString;

   GroupWindow : PGroupWindow;
   RewGroupWindow : PRewGroupWindow;
   PrevGroup : String[CAll];
   GroupNum: PBox;
   GroupFile : GroupFileType;
   GroupElement : GroupType;







Function AddGroup( Cod:Integer; Var GroupElement:GroupType):Boolean;
Label 1;
var
  R : TRect;
  AddGroupWin : PDialog;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full,Full1 : Boolean;
  k : LongInt;
  GroupNum : PBox;
{  l : Boolean;}
  Event:TEvent;
  SRegName : AllStr;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddGroup:=False;
    Exit;
   End;




C:=IOResult;
AddGroup:=False;
Full:=True;
Full1:=False;

{If Password(5) Then Full1:=True;}

Assign(GroupFile,Path.ToClient+'Group.db');

Reset(GroupFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу регионов!',nil,mfError+mfCancelButton);
 AddGroup:=False;
 Exit;
End;
AInfo('Читаю списки...');
 Case Cod Of
  kbGrayPlus:Begin
     GroupElement.Employ:=True;
     While Not(Eof(GroupFile)) And (GroupElement.Employ) Do
     begin
      ReadGroup(GroupFile,GroupElement);
     end;


     If Eof(GroupFile) And (GroupElement.Employ) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Свободных позиций для групп - нет!',nil,mfWarning+mfCancelButton);
       System.Close(GroupFile);
       AddGroup:=False;
       Exit;
      End;
      s:=GroupElement.Kod;
      GroupElement.GroupName[0]       :=#0;
      GroupElement.Locked        :=True;
      GroupElement.Kod     :='0000';
      GroupElement.LockCaption:=CurrentPassword;
    End;

  kbF4:Begin
     s:=Copy(GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count),1+CNAme+1,CClientKod);
     Seek(GroupFile,StrToInt(s));
     Repeat
      ReadGroup(GroupFile,GroupElement);
     Until (Eof(GroupFile)) Or (GroupElement.Kod=s);
     If Eof(GroupFile) And (GroupElement.Kod<>s) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Группа в базе не найдена!',nil,mfError+mfCancelButton);
       System.Close(GroupFile);
       AddGroup:=False;
       Exit;
      End;
    End;
  Else;
 End;
System.Close(GroupFile);
1:


If Cod=kbGrayPlus Then
Begin
R.Assign(11, 7, 68, 15);
New(AddGroupWin, Init(R, 'Добавить группу'));
End
Else
Begin
R.Assign(11, 7, 68, 11);
New(AddGroupWin, Init(R, 'Изменить группу'));
End;
AddGroupWin^.Options := AddGroupWin^.Options or ofCenterX or ofCenterY;
AddGroupWin^.Palette := dpCyanDialog;
AddGroupWin^.HelpCtx:=$E011;
R.Assign(9, 1, 37, 2);
Control := New(PInputLine, Init(R, CName));
AddGroupWin^.Insert(Control);

  R.Assign(37, 1, 40, 2);
  AddGroupWin^.Insert(New(PHistory, Init(R, PInputline(Control), 18)));

  R.Assign(1, 1, 9, 2);
  AddGroupWin^.Insert(New(PLabel, Init(R, '~Г~руппа:', Control)));


AddGroupWin^.SetData(GroupElement);


If Cod = kbGrayPlus  Then
Begin
 R.Assign(56, 3, 57, 7);
 Control := New(PScrollBar, Init(R));
 AddGroupWin^.Insert(Control);
 R.Assign(1, 3, 56, 7);
 GroupNum := New(PBox, Init(R, 9, PScrollbar(Control)));
 GroupNum^.NewList(New(PTextCollection, Init(0,1)));

Assign(GroupFile,Path.ToClient+'Group.db');
Reset (GroupFile);
 While Not(Eof(GroupFile)) Do
  Begin
   ReadGroup(GroupFile,GroupElement);
   If Not(GroupElement.Employ) Then
   Begin
   Format (GroupElement.GroupName,CNAme);
   GroupNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+GroupElement.Kod));
   GroupNum^.SetRange(GroupNum^.List^.Count);
   GroupNum^.FocusItem(GroupNum^.List^.Count);
   End;
  End;
 System.Close(GroupFile);
 If Cod=kbF4 Then GroupNum^.FocusItem(LoCation(GroupNum,s,ProdagaWindow))
 Else GroupNum^.FocusItem(0);

 AddGroupWin^.Insert(GroupNum);
 GroupNum^.HelpCtx:=$E011;

  R.Assign(1, 2, 17, 3);
  AddGroupWin^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', GroupNum)));
  AddGroupWin^.Insert(Control);
 End;
If Cod=kbF4 Then
 Begin
  R.Assign(40, 1, 52, 2);
  Control := New(PColoredText, Init(R, 'Код группы:', $3E));
  AddGroupWin^.Insert(Control);
  R.Assign(52, 1, 56, 2);
  Control := New(PColoredText, Init(R, GroupElement.Kod,$3E));
  AddGroupWin^.Insert(Control);
 End;

AddGroupWin^.SelectNext(False);
NoInfo;
c:=Desktop^.ExecView(AddGroupWin);
If c<>cmCancel Then
 Begin
    AddGroupWin^.GetData(GroupElement);
    DelSpaceRight(GroupElement.GroupName);

    If GroupElement.GroupName[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название группы!',nil,mfError+mfCancelButton);
If Cod=kbGrayPlus Then
  Begin
   s:=GroupNum^.GetText(GroupNum^.Focused,GroupNum^.List^.Count);
   s:=Copy(s,1+CName+1,CClientKod);
  GroupNum^.NewList(Nil);
  Dispose(GroupNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddGroupWin,Done);
    Goto 1;
   End;

  C:=IOResult;

If Cod=kbGrayPlus Then
  Begin
   s:=GroupNum^.GetText(GroupNum^.Focused,GroupNum^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If Cod=kbGrayPlus Then
  Begin
   If Not(TestEmployGroupAndLock(s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать группу с кодом '+s+'... Попробуйте изменить код!');
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(GroupNum,Done);
     Dispose(Control,Done);
     Dispose(AddGroupWin,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(GroupElement.GroupName);
   GroupElement.Employ:=True;
   GroupElement.Locked:=True;

   If Cod=kbGrayPlus Then GroupElement.Kod:=s;


  {если не удалось записать информацию}
  If Not (WriteLockGroup(GroupElement)) Then
    Begin
     If Cod=kbGrayPlus Then Dispose(GroupNum,Done);
     Dispose(Control,Done);
     Dispose(AddGroupWin,Done);
     Repeat
     Until (SetGroupUnLock(s));
     Goto 1;
    End;

  If Cod=kbGrayPlus Then
  Begin
   AddProtocol('Добавление новой группы:'+GroupElement.GroupName+' ('+s+')','','');
   Repeat
   Until (SetGroupUnLock(s));
  End
  Else
   AddProtocol('Корректировка данных группы:'+GroupElement.GroupName+' ('+GroupElement.Kod+')','','');
  AddGroup:=True;
 End;

If Cod=kbGrayPlus Then
  Begin
  GroupNum^.NewList(Nil);
  Dispose(GroupNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddGroupWin,Done);

  PrevGroup[0]:=#0;

End;


Function AddRewGroup( Cod:Integer; Var GroupElement:GroupType):Boolean;
Label 1;
var
  R : TRect;
  AddGroupWin : PDialog;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full,Full1 : Boolean;
  k : LongInt;
  GroupNum : PBox;
{  l : Boolean;}
  Event:TEvent;
  SRegName : AllStr;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddRewGroup:=False;
    Exit;
   End;




C:=IOResult;
AddRewGroup:=False;
Full:=True;
Full1:=False;

{If Password(5) Then Full1:=True;}

Assign(GroupFile,Path.ToClient+'rGroup.db');

Reset(GroupFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу видов ревизий!',nil,mfError+mfCancelButton);
 AddRewGroup:=False;
 Exit;
End;
AInfo('Читаю списки...');
 Case Cod Of
  kbGrayPlus:Begin
     GroupElement.Employ:=True;
     While Not(Eof(GroupFile)) And (GroupElement.Employ) Do
     begin
      ReadRewGroup(GroupFile,GroupElement);
     end;


     If Eof(GroupFile) And (GroupElement.Employ) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Свободных позиций для групп - нет!',nil,mfWarning+mfCancelButton);
       System.Close(GroupFile);
       AddRewGroup:=False;
       Exit;
      End;
      s:=GroupElement.Kod;
      GroupElement.GroupName[0]       :=#0;
      GroupElement.Locked        :=True;
      GroupElement.Kod     :='0000';
      GroupElement.LockCaption:=CurrentPassword;
    End;

  kbF4:Begin
     s:=Copy(GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count),1+CNAme+1,CClientKod);
     Seek(GroupFile,StrToInt(s));
     Repeat
      ReadGroup(GroupFile,GroupElement);
     Until (Eof(GroupFile)) Or (GroupElement.Kod=s);
     If Eof(GroupFile) And (GroupElement.Kod<>s) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Группа в базе не найдена!',nil,mfError+mfCancelButton);
       System.Close(GroupFile);
       AddRewGroup:=False;
       Exit;
      End;
    End;
  Else;
 End;
System.Close(GroupFile);
1:


If Cod=kbGrayPlus Then
Begin
R.Assign(11, 7, 68, 15);
New(AddGroupWin, Init(R, 'Добавить группу ревизий'));
End
Else
Begin
R.Assign(11, 7, 68, 11);
New(AddGroupWin, Init(R, 'Изменить группу ревизий'));
End;
AddGroupWin^.Options := AddGroupWin^.Options or ofCenterX or ofCenterY;
AddGroupWin^.Palette := dpCyanDialog;
AddGroupWin^.HelpCtx:=$E011;
R.Assign(9, 1, 37, 2);
Control := New(PInputLine, Init(R, CName));
AddGroupWin^.Insert(Control);

  R.Assign(37, 1, 40, 2);
  AddGroupWin^.Insert(New(PHistory, Init(R, PInputline(Control), 18)));

  R.Assign(1, 1, 9, 2);
  AddGroupWin^.Insert(New(PLabel, Init(R, '~Г~руппа:', Control)));


AddGroupWin^.SetData(GroupElement);


If Cod = kbGrayPlus  Then
Begin
 R.Assign(56, 3, 57, 7);
 Control := New(PScrollBar, Init(R));
 AddGroupWin^.Insert(Control);
 R.Assign(1, 3, 56, 7);
 GroupNum := New(PBox, Init(R, 9, PScrollbar(Control)));
 GroupNum^.NewList(New(PTextCollection, Init(0,1)));

Assign(GroupFile,Path.ToClient+'rGroup.db');
Reset (GroupFile);
 While Not(Eof(GroupFile)) Do
  Begin
   ReadRewGroup(GroupFile,GroupElement);
   If Not(GroupElement.Employ) Then
   Begin
   Format (GroupElement.GroupName,CNAme);
   GroupNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+GroupElement.Kod));
   GroupNum^.SetRange(GroupNum^.List^.Count);
   GroupNum^.FocusItem(GroupNum^.List^.Count);
   End;
  End;
 System.Close(GroupFile);
 If Cod=kbF4 Then GroupNum^.FocusItem(LoCation(GroupNum,s,ProdagaWindow))
 Else GroupNum^.FocusItem(0);

 AddGroupWin^.Insert(GroupNum);
 GroupNum^.HelpCtx:=$E011;

  R.Assign(1, 2, 17, 3);
  AddGroupWin^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', GroupNum)));
  AddGroupWin^.Insert(Control);
 End;
If Cod=kbF4 Then
 Begin
  R.Assign(40, 1, 52, 2);
  Control := New(PColoredText, Init(R, 'Код группы:', $3E));
  AddGroupWin^.Insert(Control);
  R.Assign(52, 1, 56, 2);
  Control := New(PColoredText, Init(R, GroupElement.Kod,$3E));
  AddGroupWin^.Insert(Control);
 End;

AddGroupWin^.SelectNext(False);
NoInfo;
c:=Desktop^.ExecView(AddGroupWin);
If c<>cmCancel Then
 Begin
    AddGroupWin^.GetData(GroupElement);
    DelSpaceRight(GroupElement.GroupName);

    If GroupElement.GroupName[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название группы!',nil,mfError+mfCancelButton);
If Cod=kbGrayPlus Then
  Begin
   s:=GroupNum^.GetText(GroupNum^.Focused,GroupNum^.List^.Count);
   s:=Copy(s,1+CName+1,CClientKod);
  GroupNum^.NewList(Nil);
  Dispose(GroupNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddGroupWin,Done);
    Goto 1;
   End;

  C:=IOResult;

If Cod=kbGrayPlus Then
  Begin
   s:=GroupNum^.GetText(GroupNum^.Focused,GroupNum^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If Cod=kbGrayPlus Then
  Begin
   If Not(TestRewEmployGroupAndLock(s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать группу с кодом '+s+'... Попробуйте изменить код!');
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(GroupNum,Done);
     Dispose(Control,Done);
     Dispose(AddGroupWin,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(GroupElement.GroupName);
   GroupElement.Employ:=True;
   GroupElement.Locked:=True;

   If Cod=kbGrayPlus Then GroupElement.Kod:=s;


  {если не удалось записать информацию}
  If Not (WriteRewLockGroup(GroupElement)) Then
    Begin
     If Cod=kbGrayPlus Then Dispose(GroupNum,Done);
     Dispose(Control,Done);
     Dispose(AddGroupWin,Done);
     Repeat
     Until (SetRewGroupUnLock(s));
     Goto 1;
    End;

  If Cod=kbGrayPlus Then
  Begin
   AddProtocol('Добавление новой группы:'+GroupElement.GroupName+' ('+s+')','','');
   Repeat
   Until (SetRewGroupUnLock(s));
  End
  Else
   AddProtocol('Корректировка данных группы:'+GroupElement.GroupName+' ('+GroupElement.Kod+')','','');
  AddRewGroup:=True;
 End;

If Cod=kbGrayPlus Then
  Begin
  GroupNum^.NewList(Nil);
  Dispose(GroupNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddGroupWin,Done);

  PrevGroup[0]:=#0;

End;





Procedure TGroupWindow.ShowGroupList(Var st:AllStr;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c: Word;
  c1,Count : Word;
  GroupFile : File;
  GroupElement : PBufGroupType;
begin
ClearFind;
AInfo('Читаю списки...');

Res:=0;
R.Assign(45, 5, 79, 22);
New(GroupWindow, Init(R, 'Выбор группы'));

R.Assign(33, 1, 34, 16);
Control := New(PScrollBar, Init(R));
GroupWindow^.Insert(Control);

R.Assign(1, 1, 33, 16);
GroupList := New(PBox, Init(R, 1, PScrollbar(Control)));
GroupList^.NewList(New(PTextCollection, Init(0,1)));
Assign (GroupFile,Path.ToClient+'Group.db');
c:=IOResult;
Reset (GroupFile,SizeOf(GroupType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(GroupFile)) Do
 Begin
    New(GroupElement,Init);
    ReadBufGroup(GroupFile,GroupElement,Count);
For c1:=1 To Count Do
Begin
  If GroupElement^.Point.Dat[c1].Employ Then
   Begin
    Format (GroupElement^.Point.Dat[c1].GroupName,CName);
    GroupList^.List^.Insert(NewStr(GroupElement^.Point.Dat[c1].GroupName+'│'+GroupElement^.Point.Dat[c1].Kod));
    GroupList^.SetRange(GroupList^.List^.Count);
   End;
End;{For}
  Dispose(GroupElement,Done);
 End;{While}
System.Close(GroupFile);
End
Else
 Begin
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
s:=Copy(st,1+CNAme+1,CClientKod);
GroupList^.FocusItem(Location(GroupList,S,ProdagaWindow));


GroupList^.HelpCtx:={F371}$E011;
GroupWindow^.Insert(GroupList);
PrevGroup:=Copy(GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count),1+CName+1,CClientKod);

GroupWindow^.SelectNext(False);
PrevGroup[0]:=#0;
NoInfo;
c:=Desktop^.ExecView(GroupWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Res in [2,3] Then
   St:=GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count);
1:
Dispose(COntrol,Done);
Dispose(GroupWindow,Done);
end;



Procedure TGroupWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c,Cod: Word;
  GroupFile : File;
  GroupElement : PBufGroupType;
  c1,Count : Word;
begin
ClearFind;
DInfoMsg('Обновляю списки групп...');
Cod:=GroupList^.Focused;

     Assign (GroupFile,Path.ToClient+'Group.db');
     GroupList^.NewList(Nil);
     GroupList^.NewList(New(PTextCollection, Init(0,1)));

c:=IOResult;
Reset (GroupFile,SizeOf(GroupType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(GroupFile)) Do
 Begin
    New(GroupElement,Init);
    ReadBufGroup(GroupFile,GroupElement,Count);
For c1:=1 To Count Do
Begin
  If GroupElement^.Point.Dat[c1].Employ Then
   Begin
    Format (GroupElement^.Point.Dat[c1].GroupName,CName);
    GroupList^.List^.Insert(NewStr(GroupElement^.Point.Dat[c1].GroupName+'│'+GroupElement^.Point.Dat[c1].Kod));
    GroupList^.SetRange(GroupList^.List^.Count);
   End;
End;{For}
  Dispose(GroupElement,Done);
 End;
System.Close(GroupFile);
If Cod<>0 Then Dec(Cod);

GroupList^.FocusItem(Cod);
NoInfoMsg;
End
Else
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;
PrevGroup[0]:=#0;
end;


Destructor TGroupWindow.Done;
Begin
ClearFind;
Dispose(GroupList,Done);
TDialog.Done;
End;


procedure TGroupWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;
    Op : StrNAme;
    Art : ArtikulStr;


Function LockSelect:Boolean;
Var s : string[150];
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count);
  s:=Copy(s,1+CNAme+1,CClientKod);

  R:=GetGroupEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать группу с кодом '+s+'. Группа отмечена как удаленная!');
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

  If SetGroupLock(s,Op) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg('Группа ['+s+'] используется '+Op+'! Не могу заблокировать группу!');
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
Var s : string[150];
    Event : TEvent;
    R : Boolean;
Begin
  TestEmploy:=False;
  s:=GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count);
  s:=Copy(s,1+CName+1,CClientKod);

  r:=False;
  R:=GetGroupEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Нельзя работать с группой '+s+'. Группа отмечена как удаленная!');
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
Var  f : File Of GroupType;
     cl : GroupType;
     r : Byte;
     cod : ArtikulStr;
Begin
AInfo('Минуточку...');
Assign (F,Path.ToClient+'Group.db');

r:=IOResult;
Reset(f);
r:=IOResult;
If R<>0 Then
 Begin
  NoInfo;
  Exit;
 End;

While Not(Eof(f)) Do
  Begin
   Read(f,Cl);
   r:=IOResult;

   cl.Locked:=False;
   Seek(f,FilePos(f)-1);
   r:=IOResult;

   Write(f,cl);
   r:=IOResult;

  End;
System.close(f);
   r:=IOResult;

NoInfo;
AddProtocol('Общая деблокировка групп {сетевая безопасность транзакций}','','');
End;



begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbDel: if (User[65] or (CurrentPassword='00')) then
	Begin

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;


     L:=False;
     If (GroupList^.State and sfFocused <> 0) And (GroupList^.List<>Nil)And(GroupList^.List^.Count>=2) Then L:=True;

     If L Then
            Begin
     If Password(3) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count);
                s:=Copy(s,1+CName+1,CClientKod);


If (StrToInt(s)<>0) Then
Begin
              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count);
                 s:=Copy(s,1+CNAme+1,CClientKod);

                 Assign (GroupFile,Path.ToClient+'Group.db');
                 GroupElement.GroupName[0]:=#0;
                 GroupElement.Kod:=s;
                 GroupElement.Employ:=False;
                 GroupElement.Locked:=True;

  If Not (WriteLockGroup(GroupElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлам групп !',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetGroupUnLock(s));
     ClearEvent(Event);
     Exit;
    End;

    Repeat
    Until (SetGroupUnLock(s));
    AddProtoCol('Удаление группы:'+s,'','');
    GroupList^.List^.AtFree(GroupList^.Focused);
    GroupList^.SetRange(GroupList^.List^.Count);
    If GroupList^.Focused>0 Then   GroupList^.FocusItem(GroupList^.Focused);
    If (GroupList^.Focused>=GroupList^.List^.Count) and(GroupList^.Focused>0) Then
    GroupList^.FocusItem(GroupList^.Focused-1);
End;
    ClearEvent(Event);
    Redraw;

            End;
           End;
          End;
          End;


kbAlt1         : If Password(5) Then UnlockAll;

{временно выключено пока не написана процедура добавления нового региона}
kbGrayPlus,kbF4:
if  ((User[65] or (CurrentPassword='00')) and (Event.KeyCode=kbF4))
or ((User[66] or (CurrentPassword='00')) and (Event.KeyCode=kbGrayPlus)) then
Begin
L:=False;
If(GroupList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(GroupList^.List<>Nil)And(GroupList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
      If AddGroup(Event.KeyCode,GroupElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(GroupList^.List<>Nil)And(GroupList^.List^.Count>=1) Then
           GroupList^.List^.AtFree(GroupList^.Focused);
        Format(GroupElement.GroupName,CName);
        GroupList^.List^.Insert(NewStr(GroupElement.GroupName+'│'+GroupElement.Kod));
        GroupList^.SetRange(GroupList^.List^.Count);
        GroupList^.FocusItem(LoCation(GroupList,GroupElement.Kod,ProdagaWindow));
        Redraw;
       End
       Else
        Begin
         s:=GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count);
         GroupElement.Kod:=Copy(s,1+CName+1,CClientKod);
        End;

   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=GroupElement.Kod;
    Repeat
    Until (SetGroupUnLock(Cod));
   End;
            ClearEvent(Event);
            Redraw;
            End;

      Else;
      End;{KeyDown}
evCommand:
 Case Event.Command Of
 cmRefresh: Refresh;

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
     (Event.Command = cmSelectGroup) then ClearEvent(Event);


  inherited HandleEvent(Event);
  {
  If (Desktop^.Current=PView(GroupWindow)) And (Event.What <> EvKeyDown) Then
          Begin
                If (Client^.List <> Nil) And (Group^.List^.Count>=1) Then
                 Begin
                  s:=Group^.GetText(Group^.Focused,Group^.List^.Count);
                  If s<>PrevGroup Then
                   Begin
                    PrevGroup:=S;
                    DrawCurrent;
                   End;
                 End;
          End;
  }
  ClearEvent(Event);
end;




Procedure SortNKLIDX (Var L:PSuperMarketType);
Var i : Word;
    R : TRect;
    E : PSuperMarketType;
    Wl,Wk,Wn : AllStr;
    S : TMyString;
    TempBox : PBox;
    NGK : ArtikulStr;
    LLL : Word;
Begin

 R.Assign(0, 0, 0, 0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));
 For i :=1 To L^.Dat.Amount Do
  Begin
   With L^.Dat.MarketElement[i].Input Do
   Begin
   Format(Kol,CKol);
   Format(Zena,CZena);
   Format(Skidka,CZena);
   Format(Itogo,CInputIZena);
   Format(R_Zena,CZena);
   Format(O_Zena,CZena);
   Format(Proz,CLitr+1);
   Format(SpecNalog,CLitr);
   Format(NDS,CLitr);
   Format(Zakupka,CZena);
   Wk := Copy(L^.Dat.MarketElement[i].BazKod,1,CRazdelKod);
   Wn := GetIdField(FName,L^.Dat.MarketElement[i].BazKod);
   Wl := GetIdField(FLitr,L^.Dat.MarketElement[i].BazKod);
   Format (wn,CName);
   Str(L^.Dat.MarketElement[i].Input.DivisionSNumber:1,s);
   NGK:=BakGetField(FGroup,L^.Dat.MarketElement[i].BazKod,0);
   RFormatZerro(NGK,CClientKod);


   If Last Then LLL:=1
   Else LLL:=0;

   s:=s+NGK+'│'+'│'+wk+'│'+Wn+'│'+L^.Dat.MarketElement[i].BazKod+'│'+
   +L^.Dat.MarketElement[i].Input.Kol+'│'+Wl+'│'+L^.Dat.MarketElement[i].Input.Zena+'│'+
   +L^.Dat.MarketElement[i].Input.Skidka+'│'+L^.Dat.MarketElement[i].Input.R_Zena+'│'+
   +L^.Dat.MarketElement[i].Input.O_Zena+'│'+L^.Dat.MarketElement[i].input.Itogo+'│'+L^.Dat.MarketElement[i].Input.Proz+
   '│'+L^.Dat.MarketElement[i].Input.SpecNalog+'│'+IntToStr(VidNalog,COne)+
   '│'+L^.Dat.MarketElement[i].Input.Nds+'│'+IntToStr(VidNDS,COne)+
   '│'+L^.Dat.MarketElement[i].Input.Zakupka+'│'+IntToStr(LLL,COne);
   TempBox^.List^.Insert(NewStr(s));
   TempBox^.SetRange(TempBox^.List^.Count);
   End;{With}
  End;{For}
  New(E,Init);
  E^.Dat:=L^.Dat;

If (TempBox^.List^.Count)>0 Then
For i:=0 To TempBox^.List^.Count-1 Do
 Begin
  s:=TempBox^.GetText(i,TempBox^.List^.Count);
{для новой структуры стороки}
  E^.Dat.MarketElement[i+1].BazKod:=Copy(s,1+CClientKod+1+COne+1+CRazdelKod+1+CName+1,CArtikul);
  With E^.Dat.MarketElement[i+1].Input Do
   Begin
   {
    NDS:=BakGetField(FNds,E^.Dat.MarketElement[i+1].BazKod,0);
    DelSpace(Nds);
   }
    Kol:=Copy(s,1+CClientKod+1+COne+1+CName+1+CArtikul+1+CRazdelKod+1,CKol);
    DelSpace(Kol);
    Zena:=Copy(s,1+CClientKod+1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CRazdelKod+1,CZena);
    DelSpace(Zena);
    Skidka:=Copy(s,1+CClientKod+1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CRazdelKod+1,CZena);
    DelSpace(Skidka);
    Itogo:=Copy(s,1+CClientKod+1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CRazdelKod+1,
    CInputIZena);
    DelSpace(Itogo);
    R_Zena:=Copy(s,1+CClientKod+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+COne+1+CRazdelKod+1,CZena);
    DelSpace(R_Zena);
    O_Zena:=Copy(s,1+CClientKod+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+COne+1+CZena+1+CRazdelKod+1,CZena);
    DelSpace(O_Zena);

    DiviSionSNumber:=StrToInt(Copy(s,1,COne));
    Proz:=Copy(s,1+CClientKod+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+1+
    CRazdelKod+
    1{CZena+1},CLitr+1);
    DelSpace(Proz);

    SpecNalog:=Copy(s,1+CClientKod+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+1+
    CRazdelKod+
    1+(CLitr+1)+1,CLitr);
    DelSpace(SpecNalog);

    VidNalog:=StrToInt(Copy(s,1+CClientKod+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+
    COne+
    1+CRazdelKod+1+(CLitr+1)+1+CLitr+1,COne));

    NDS:=Copy(s,1+CClientKod+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+(CLitr+1)+1+CLitr+1+COne+1,CLitr);
    DelSpace(NDS);

    VidNDS:=StrToInt(Copy(s,1+CClientKod+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+
    COne+
    1+CRazdelKod+1+(CLitr+1)+1+CLitr+1+COne+1+CLitr+1,COne));

    Zakupka:=Copy(s,1+CClientKod+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+(CLitr+1)+1+CLitr+1+COne+1+CLitr+1+COne+1,CZena);
    DelSpace(Zakupka);


    LLL:=StRToInt(Copy(s,1+CClientKod+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+(CLitr+1)+1+CLitr+1+COne+1+CLitr+1+COne+1+CZena+1,COne));

   If LLL=1 Then LAst:=True
   Else LAst:=FAlse;


   End;
 End;
 L^.Dat:=E^.Dat;
 Dispose(TempBox,Done);
 Dispose(E,Done);

End;




Procedure TRewGroupWindow.ShowRewGroupList(Var st:AllStr;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c: Word;
  c1,Count : Word;
  GroupFile : File;
  GroupElement : PBufGroupType;
begin
ClearFind;
AInfo('Читаю списки...');

Res:=0;
R.Assign(45, 5, 79, 22);
New(RewGroupWindow, Init(R, 'Выбор группы'));

R.Assign(33, 1, 34, 16);
Control := New(PScrollBar, Init(R));
RewGroupWindow^.Insert(Control);

R.Assign(1, 1, 33, 16);
GroupList := New(PBox, Init(R, 1, PScrollbar(Control)));
GroupList^.NewList(New(PTextCollection, Init(0,1)));
Assign (GroupFile,Path.ToClient+'rGroup.db');
c:=IOResult;
Reset (GroupFile,SizeOf(GroupType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(GroupFile)) Do
 Begin
    New(GroupElement,Init);
    ReadRewBufGroup(GroupFile,GroupElement,Count);
For c1:=1 To Count Do
Begin
  If GroupElement^.Point.Dat[c1].Employ Then
   Begin
    Format (GroupElement^.Point.Dat[c1].GroupName,CName);
    GroupList^.List^.Insert(NewStr(GroupElement^.Point.Dat[c1].GroupName+'│'+GroupElement^.Point.Dat[c1].Kod));
    GroupList^.SetRange(GroupList^.List^.Count);
   End;
End;{For}
  Dispose(GroupElement,Done);
 End;{While}
System.Close(GroupFile);
End
Else
 Begin
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файла базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
s:=Copy(st,1+CNAme+1,CClientKod);
GroupList^.FocusItem(Location(GroupList,S,False));


GroupList^.HelpCtx:={F371}$E011;
RewGroupWindow^.Insert(GroupList);
PrevGroup:=Copy(GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count),1+CName+1,CClientKod);

RewGroupWindow^.SelectNext(False);
PrevGroup[0]:=#0;
NoInfo;
c:=Desktop^.ExecView(RewGroupWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Res in [2,3] Then
   St:=GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count);
1:
Dispose(COntrol,Done);
Dispose(RewGroupWindow,Done);
end;



Procedure TRewGroupWindow.RefreshRew;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c,Cod: Word;
  GroupFile : File;
  GroupElement : PBufGroupType;
  c1,Count : Word;
begin
ClearFind;
DInfoMsg('Обновляю списки групп...');
Cod:=GroupList^.Focused;

     Assign (GroupFile,Path.ToClient+'rGroup.db');
     GroupList^.NewList(Nil);
     GroupList^.NewList(New(PTextCollection, Init(0,1)));

c:=IOResult;
Reset (GroupFile,SizeOf(GroupType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(GroupFile)) Do
 Begin
    New(GroupElement,Init);
    ReadBufGroup(GroupFile,GroupElement,Count);
For c1:=1 To Count Do
Begin
  If GroupElement^.Point.Dat[c1].Employ Then
   Begin
    Format (GroupElement^.Point.Dat[c1].GroupName,CName);
    GroupList^.List^.Insert(NewStr(GroupElement^.Point.Dat[c1].GroupName+'│'+GroupElement^.Point.Dat[c1].Kod));
    GroupList^.SetRange(GroupList^.List^.Count);
   End;
End;{For}
  Dispose(GroupElement,Done);
 End;
System.Close(GroupFile);
If Cod<>0 Then Dec(Cod);

GroupList^.FocusItem(Cod);
NoInfoMsg;
End
Else
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;
PrevGroup[0]:=#0;
end;


Destructor TRewGroupWindow.Done;
Begin
ClearFind;
Dispose(GroupList,Done);
TDialog.Done;
End;


procedure TRewGroupWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;
    Op : StrNAme;
    Art : ArtikulStr;


Function LockSelectRew:Boolean;
Var s : string[150];
    Event : TEvent;
    R : Boolean;
Begin
  LockSelectRew:=False;
  s:=GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count);
  s:=Copy(s,1+CNAme+1,CClientKod);

  If s='0000' Then
   Begin
    Beep;
    DInfoMsg('Этот элемент выбрать нельзя!');
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

  R:=GetRewGroupEmploy(s);

  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать группу с кодом '+s+'. Группа отмечена как удаленная!');
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

  If SetRewGroupLock(s,Op) Then LockSelectRew:=True
  Else
   Begin
    Beep;
    DInfoMsg('Группа ['+s+'] используется '+Op+'! Не могу заблокировать группу!');
    ClearEvent(Event);
    ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing);
    NoInfoMsg;
    ClearEvent(Event);
   End;
End;

Function TestEmployRew:Boolean;
Var s : string[150];
    Event : TEvent;
    R : Boolean;
Begin
  TestEmployRew:=False;
  s:=GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count);
  s:=Copy(s,1+CName+1,CClientKod);

  r:=False;
  R:=GetRewGroupEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Нельзя работать с группой '+s+'. Группа отмечена как удаленная!');
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
   TestEmployRew:=True;
End;



Procedure UnlockAll;
Var  f : File Of GroupType;
     cl : GroupType;
     r : Byte;
     cod : ArtikulStr;
Begin
AInfo('Минуточку...');
Assign (F,Path.ToClient+'rGroup.db');

r:=IOResult;
Reset(f);
r:=IOResult;
If R<>0 Then
 Begin
  NoInfo;
  Exit;
 End;

While Not(Eof(f)) Do
  Begin
   Read(f,Cl);
   r:=IOResult;

   cl.Locked:=False;
   Seek(f,FilePos(f)-1);
   r:=IOResult;

   Write(f,cl);
   r:=IOResult;

  End;
System.close(f);
   r:=IOResult;

NoInfo;
AddProtocol('Общая деблокировка групп {сетевая безопасность транзакций}','','');
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


     L:=False;
     If (GroupList^.State and sfFocused <> 0) And (GroupList^.List<>Nil)And(GroupList^.List^.Count>=2) Then L:=True;

     If L Then
            Begin
     If Password(3) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count);
                s:=Copy(s,1+CName+1,CClientKod);


If (StrToInt(s)<>0) Then
Begin
              {сетевая блокировка}
               If Not(LockSelectRew) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count);
                 s:=Copy(s,1+CNAme+1,CClientKod);

                 Assign (GroupFile,Path.ToClient+'rGroup.db');
                 GroupElement.GroupName[0]:=#0;
                 GroupElement.Kod:=s;
                 GroupElement.Employ:=False;
                 GroupElement.Locked:=True;

  If Not (WriteRewLockGroup(GroupElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлам групп ревизий!',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetRewGroupUnLock(s));
     ClearEvent(Event);
     Exit;
    End;

    Repeat
    Until (SetRewGroupUnLock(s));
    AddProtoCol('Удаление группы ревизий:'+s,'','');
    GroupList^.List^.AtFree(GroupList^.Focused);
    GroupList^.SetRange(GroupList^.List^.Count);
    If GroupList^.Focused>0 Then   GroupList^.FocusItem(GroupList^.Focused);
    If (GroupList^.Focused>=GroupList^.List^.Count) and(GroupList^.Focused>0) Then
    GroupList^.FocusItem(GroupList^.Focused-1);
End;
    ClearEvent(Event);
    Redraw;

            End;
           End;
          End;
          End;


kbAlt1         : If Password(5) Then UnlockAll;

{временно выключено пока не написана процедура добавления нового региона}
kbGrayPlus,kbF4:
Begin
L:=False;
If(GroupList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(GroupList^.List<>Nil)And(GroupList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelectRew) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
      If AddRewGroup(Event.KeyCode,GroupElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(GroupList^.List<>Nil)And(GroupList^.List^.Count>=1) Then
           GroupList^.List^.AtFree(GroupList^.Focused);
        Format(GroupElement.GroupName,CName);
        GroupList^.List^.Insert(NewStr(GroupElement.GroupName+'│'+GroupElement.Kod));
        GroupList^.SetRange(GroupList^.List^.Count);
        GroupList^.FocusItem(LoCation(GroupList,GroupElement.Kod,ProdagaWindow));
        Redraw;
       End
       Else
        Begin
         s:=GroupList^.GetText(GroupList^.Focused,GroupList^.List^.Count);
         GroupElement.Kod:=Copy(s,1+CName+1,CClientKod);
        End;

   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=GroupElement.Kod;
    Repeat
    Until (SetRewGroupUnLock(Cod));
   End;
            ClearEvent(Event);
            Redraw;
            End;

      Else;
      End;{KeyDown}
evCommand:
 Case Event.Command Of
 cmRefresh: RefreshRew;

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
                          If Not(TestEmployRew) Then
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
     (Event.Command = cmSelectRewGroup) then ClearEvent(Event);


  inherited HandleEvent(Event);
  {
  If (Desktop^.Current=PView(GroupWindow)) And (Event.What <> EvKeyDown) Then
          Begin
                If (Client^.List <> Nil) And (Group^.List^.Count>=1) Then
                 Begin
                  s:=Group^.GetText(Group^.Focused,Group^.List^.Count);
                  If s<>PrevGroup Then
                   Begin
                    PrevGroup:=S;
                    DrawCurrent;
                   End;
                 End;
          End;
  }
  ClearEvent(Event);
end;







End.