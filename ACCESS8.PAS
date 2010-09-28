{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Access8;

Interface

Uses Dialogs,Glob,Slava3,Access,Drivers,ServStr,Utils1;


Type
    PKSertifWindow= ^TKSertifWindow;
    TKSertifWindow = object(TDialog)
    lnk : PLinkKSertifWindow;
    Procedure ImportSPR;
    Procedure ShowKSertifList(Var st:String;Var Res: Word);
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;



Type
    PExpertWindow= ^TExpertWindow;
    TExpertWindow = object(TDialog)
    lnk : PLinkExpertWindow;
    Procedure ImportSPR;
    Procedure ShowExpertList(Var st:String;Var Res: Word);
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type PAgentWindow= ^TAgentWindow;
     TAgentWindow = object(TDialog)
     Add  : PAddClientWindow;
     SetupPlan : PSetupAgentPlanWindow;
    Procedure PrintAgentInfo(s:ArtikulStr);
    Procedure ShowAgentList(Var st:AllStr;Var Res: Word);
    Procedure DrawCurrent;
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Var
  agentFile : ClientFileType;


Implementation

{$I Compile.INC}

Uses Printers,App,Views,Objects,MsgBox,Serv,Utils5,
     ColorTxt,Validate,DbEngin2,Memory,TpDate,Utils,Utils3,Utils4,
     DbEngine,Utils7,Filetool,DbEngin3,Servstr2,MyView,Access4,
     Protect,Net,Net2,NetDbEng,NetCall;

Const LocalReadOnlyN=$42;

Var

   PrevCurrentLine : SertifStr;
   KSertifWindow : PKSertifWindow;
   ExpertWindow :   PExpertWindow;
   KSertifNum,ExpertNum: PBox;
   ExpertFile : ExpertFileType;
   ExpertList : PBox;
   KSertifFile : KSertifFileType;
   KSertif,ff     : File;
   KSertifList : PBox;
   OldFileMode,Count : Word;
   L : Longint;
   FFF : ^Integer;{Handler}
   fId : File;
   FastRead : Boolean;
   SKod : ArtikulStr;
   SElement: String[60];
   AgentWindow : PAgentWindow;
   PrevAgent : String[CAll];




Function AddKSertif( Cod:Integer; Var KSertifElement:KSertifType):Boolean;
Label 1;
var
  R : TRect;
  AddKSertifWin : PDialog;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Find,Full,Full1 : Boolean;
  k : LongInt;
  KSertifNum : PBox;
{ l : Boolean;}
  Event:TEvent;
  SRegName : AllStr;
  BufKSertifElement : PBufKSertifType;
  Count : Word;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddKSertif:=False;
    Exit;
   End;


If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    AddKSertif:=False;
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    AddKSertif:=False;
    Exit;
   End;

  If Not(Password(16)) Then
   Begin
    AddKSertif:=False;
    Exit;
   End;

C:=IOResult;
AddKSertif:=False;
Full:=True;
Full1:=False;

{If Password(5) Then Full1:=True;}

DInfoMsg('Читаю списки...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin

Assign(KSertif,Path^.Dat.ToSPR+'ksertif.db');
Reset(KSertif,SizeOf(KSertifType));
C:=IOResult;
If C<>0 Then
Begin
 NoInfoMsg;
 MessageBox(#3^M+#3'Ошибка доступа к файлу органов сертификации!',nil,mfError+mfCancelButton);
 AddKSertif:=False;
 Exit;
End;

     KSertifElement.Employ:=True;
     Find:=False;
     While Not(Eof(KSertif)) And Not(Find) Do
     begin
      New(BufKSertifElement,Init);
      ReadBufKSertif(KSertif,BufKSertifElement,Count);
      For j:=1 To Count Do
      Begin
       KSertifElement:=BufKSertifElement^.Point.Dat[j];
       If Not KSertifElement.Employ Then
        Begin
         Find:=True;
         Break;
        End;
      End;
      Dispose(BufKSertifElement,Done);
     end;{While}


     If Not Find Then
      Begin
       System.Close(KSertif);
       NoInfoMsg;
       MessageBox(#3^M+#3+NoPosition^,nil,mfWarning+mfCancelButton);
       AddKSertif:=False;
       Exit;
      End;

      C:=IOResult;
      System.Close(KSertif);
      C:=IOResult;

      s:=KSertifElement.Kod;
      KSertifElement.KSertif[0]       :=#0;
      KSertifElement.Kod     :=NoKSertifStr;
    End;

  kbF4:Begin
     Assign(KSertifFile,Path^.Dat.ToSPR+'ksertif.db');
     Reset(KSertifFile);
     C:=IOResult;
     If C<>0 Then
     Begin
     NoInfoMsg;
     MessageBox(#3^M+#3'Ошибка доступа к файлу органов сертификации!',nil,mfError+mfCancelButton);
     AddKSertif:=False;
     Exit;
     End;

     s:=Copy(KSertifList^.GetText(KSertifList^.Focused,KSertifList^.List^.Count),1+CKSertif+1,CClientKod);
     Seek(KSertifFile,StrToInt(s));
     Repeat
      ReadKSertif(KSertifFile,KSertifElement);
     Until (Eof(KSertifFile)) Or (KSertifElement.Kod=s);
     If Eof(KSertifFile) And (KSertifElement.Kod<>s) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoFound^,nil,mfError+mfCancelButton);
       System.Close(KSertifFile);
       AddKSertif:=False;
       Exit;
      End;
     C:=IOResult;
     System.Close(KSertifFile);
     C:=IOResult;
    End;
  Else;
 End;
1:


If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
Begin
R.Assign(11, 7, 70, 15);
New(AddKSertifWin, Init(R, 'Добавить орган сертификации'));
End
Else
Begin
R.Assign(11, 7, 70, 11);
New(AddKSertifWin, Init(R, 'Изменить орган сертификации'));
End;
AddKSertifWin^.Options := AddKSertifWin^.Options or ofCenterX or ofCenterY;
AddKSertifWin^.Palette := dpCyanDialog;
AddKSertifWin^.HelpCtx:=$E011;
R.Assign(9, 1, 37, 2);
Control := New(PInputLine, Init(R, CKSertif));
AddKSertifWin^.Insert(Control);

  R.Assign(37, 1, 40, 2);
  AddKSertifWin^.Insert(New(PHistory, Init(R, PInputline(Control), 100)));

  R.Assign(1, 1, 9, 2);
  AddKSertifWin^.Insert(New(PLabel, Init(R, '~О~рган:', Control)));


AddKSertifWin^.SetData(KSertifElement);


If (Cod = kbGrayPlus)Or (Cod=kbAltF1)  Then
Begin
 R.Assign(58, 3, 59, 7);
 Control := New(PScrollBar, Init(R));
 AddKSertifWin^.Insert(Control);
 R.Assign(1, 3, 58, 7);
 KSertifNum := New(PBox, Init(R, 9, PScrollbar(Control)));
 KSertifNum^.NewList(New(PTextCollection, Init(0,1)));

Assign(KSertif,Path^.Dat.ToSPR+'ksertif.db');
Reset (KSertif,SizeOf(KSertifType));
 While Not(Eof(KSertif)) Do
  Begin
   New(BufKSertifElement,Init);
   ReadBufKSertif(KSertif,BufKSertifElement,Count);
   For j:=1 To Count Do
   Begin
   If Not(BufKSertifElement^.Point.Dat[j].Employ) Then
   Begin
   {Format (BufKSertifElement^.Point.Dat[j].KSertif,CKSertif);}
   KSertifNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+BufKSertifElement^.Point.Dat[j].Kod));
   KSertifNum^.SetRange(KSertifNum^.List^.Count);
   KSertifNum^.FocusItem(KSertifNum^.List^.Count);
   End;
   End;
   Dispose(BufKSertifElement,Done);
  End;
 System.Close(KSertif);
 If Cod=kbF4 Then KSertifNum^.FocusItem(LoCation(KSertifNum,s,False))
 Else KSertifNum^.FocusItem(0);

 AddKSertifWin^.Insert(KSertifNum);
 KSertifNum^.HelpCtx:=$E011;

  R.Assign(1, 2, 17, 3);
  AddKSertifWin^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', KSertifNum)));
  AddKSertifWin^.Insert(Control);
 End;

If Cod=kbF4 Then
 Begin
  R.Assign(40, 1, 53, 2);
  Control := New(PColoredText, Init(R, 'Код органа:', $3E));
  AddKSertifWin^.Insert(Control);
  R.Assign(53, 1, 57, 2);
  Control := New(PColoredText, Init(R, KSertifElement.Kod,$3E));
  AddKSertifWin^.Insert(Control);
 End;

AddKSertifWin^.SelectNext(False);
NoInfoMsg;
c:=Desktop^.ExecView(AddKSertifWin);
If c<>cmCancel Then
 Begin
    AddKSertifWin^.GetData(KSertifElement);
    DelSpaceRight(KSertifElement.KSertif);

    If KSertifElement.KSertif[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название элемент!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=KSertifNum^.GetText(KSertifNum^.Focused,KSertifNum^.List^.Count);
   s:=Copy(s,1+CKSertif+1,CClientKod);
  KSertifNum^.NewList(Nil);
  Dispose(KSertifNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddKSertifWin,Done);
    Goto 1;
   End;

  C:=IOResult;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=KSertifNum^.GetText(KSertifNum^.Focused,KSertifNum^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   If Not(TestEmployElementAndLock(FKSertif,s)) Then
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
     Dispose(KSertifNum,Done);
     Dispose(Control,Done);
     Dispose(AddKSertifWin,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(KSertifElement.KSertif);
   KSertifElement.Employ:=True;

   If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then KSertifElement.Kod:=s;


  {если не удалось записать информацию}
  If Not (WriteLockKSertif(KSertifElement)) Then
    Begin
     If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then Dispose(KSertifNum,Done);
     Dispose(Control,Done);
     Dispose(AddKSertifWin,Done);
     Repeat
     Until (SetELementUnLock(FKSertif,s));
     Goto 1;
    End
    Else
    RefreshCashOneSPR(BKSertif);


  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   AddProtocol('Добавление органа сертификации:'+KSertifElement.KSertif+' ('+s+')','','');
   Repeat
   Until (SetElementUnLock(FKSertif,s));
  End
  Else
   AddProtocol('Корректировка органа сертификации:'+KSertifElement.KSertif+' ('+KSertifElement.Kod+')','','');
  AddKSertif:=True;
 End;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
  KSertifNum^.NewList(Nil);
  Dispose(KSertifNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddKSertifWin,Done);

  PrevCurrentLine[0]:=#0;

End;




Procedure TKSertifWindow.ShowKSertifList(Var st:String;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String;
  Bak : String;
  c: Word;
  c1,Count : Word;
  KSertifFile : File;
  KSertifElement : PBufKSertifType;
begin
Bak :=St;
ClearFind;
DInfoMsg('Читаю списки...',False);

Res:=0;
R.Assign(30, 5, 79, 22);
New(KSertifWindow, Init(R, 'Выбор органа сертификации'));

R.Assign(48, 1, 49, 16);
Control := New(PScrollBar, Init(R));
KSertifWindow^.Insert(Control);

R.Assign(1, 1, 48, 16);
KSertifList := New(PBox, Init(R, 1, PScrollbar(Control)));
KSertifList^.NewList(New(PTextCollection, Init(0,1)));
(*
Assign (KSertifFile,Path^.Dat.ToSPR+'Firma.db');
c:=IOResult;
Reset (KSertifFile,SizeOf(KSertifType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(KSertifFile)) Do
 Begin
    New(KSertifElement,Init);
    ReadBufKSertif(KSertifFile,KSertifElement,Count);
For c1:=1 To Count Do
Begin
  If KSertifElement^.Point.Dat[c1].Employ Then
   Begin
    Format (KSertifElement^.Point.Dat[c1].KSertif,CKSertif);
    KSertifList^.List^.Insert(NewStr(KSertifElement^.Point.Dat[c1].KSertif+'│'+KSertifElement^.Point.Dat[c1].Kod));
    KSertifList^.SetRange(KSertifList^.List^.Count);
   End;
End;{For}
  Dispose(KSertifElement,Done);
 End;{While}
System.Close(KSertifFile);
End
Else
 Begin
  St:=BAk;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
s:=Copy(st,1+CKSertif+1,CClientKod);
KSertifList^.FocusItem(Location(KSertifList,S,False));
KSertifList^.HelpCtx:=$E171;
KSertifWindow^.Insert(KSertifList);
PrevCurrentLine:=Copy(KSertifList^.GetText(KSertifList^.Focused,KSertifList^.List^.Count),1+CKSertif+1,CClientKod);

KSertifWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;
*)
FastRead:=False;
If (Compress=1) And (SprList[bKSertif].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'KSertif.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BKSertif].Time)=L Then  FastRead:=True;
End;

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
Assign (KSertifFile,Path^.Dat.ToSPR+'ksertif.db');
c:=IOResult;
Reset (KSertifFile,SizeOf(KSertifType));
c:=IOResult;
 FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(KSertifFile)) Do
 Begin
    New(KSertifElement,Init);
    ReadBufKSertif(KSertifFile,KSertifElement,Count);
For c1:=1 To Count Do
Begin
  If KSertifElement^.Point.Dat[c1].Employ Then
   Begin
    Format (KSertifElement^.Point.Dat[c1].KSertif,CKSertif);
    KSertifList^.List^.Insert(NewStr(KSertifElement^.Point.Dat[c1].KSertif+'│'+KSertifElement^.Point.Dat[c1].Kod));
    KSertifList^.SetRange(KSertifList^.List^.Count);
   End;
End;{For}
  Dispose(KSertifElement,Done);
 End;{While}
System.Close(KSertifFile);
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
   If SprList[BKSertif].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BKSertif].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BKSertif].Elements^.GetText(l,SprList[BKSertif].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     System.Delete(SKod,1,1);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CKSertif);
     Format (SElement,CKSertif);
     KSertifList^.List^.Insert(NewStr(SElement+'│'+SKod));
     KSertifList^.SetRange(KSertifList^.List^.Count);
     End;
    End;{For}
  End;

if st[0]<>#0 Then
s:=Copy(st,1+CKSertif+1,CClientKod)
Else
s:=NoOrganStr;

RFormatZerro(s,CClientKod);
KSertifList^.FocusItem(Location(KSertifList,S,False));


KSertifList^.HelpCtx:=$F371;
KSertifWindow^.Insert(KSertifList);
PrevCurrentLine:=Copy(KSertifList^.GetText(KSertifList^.Focused,KSertifList^.List^.Count),1+CKSertif+1,CClientKod);
KSertifWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;

c:=Desktop^.ExecView(KSertifWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Res in[2,3] Then
   St:=KSertifList^.GetText(KSertifList^.Focused,KSertifList^.List^.Count)
   Else St:=Bak;
1:
Dispose(COntrol,Done);
Dispose(KSertifWindow,Done);
end;




Procedure TKSertifWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  KSertifFile : File;
  KSertifElement : PBufKSertifType;
  c1,Count : Word;
begin
ClearFind;
DInfoMsg('Обновляю списки органов сертификации...',False);
Cod:=KSertifList^.Focused;

     KSertifList^.NewList(Nil);
     KSertifList^.NewList(New(PTextCollection, Init(0,1)));

FastRead:=False;
If (Compress=1) And (SprList[bKSertif].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'KSertif.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BKSertif].Time)=L Then  FastRead:=True;
End;

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;


Assign (KSertifFile,Path^.Dat.ToSPR+'Ksertif.db');
c:=IOResult;
Reset (KSertifFile,SizeOf(KSertifType));
c:=IOResult;
 FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(KSertifFile)) Do
 Begin
    New(KSertifElement,Init);
    ReadBufKSertif(KSertifFile,KSertifElement,Count);
For c1:=1 To Count Do
Begin
  If KSertifElement^.Point.Dat[c1].Employ Then
   Begin
    Format (KSertifElement^.Point.Dat[c1].KSertif,CKSertif);
    KSertifList^.List^.Insert(NewStr(KSertifElement^.Point.Dat[c1].KSertif+'│'+KSertifElement^.Point.Dat[c1].Kod));
    KSertifList^.SetRange(KSertifList^.List^.Count);
   End;
End;{For}
  Dispose(KSertifElement,Done);
 End;
System.Close(KSertifFile);

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
   {MemC(IntToStr(SprList[BKSertif].Elements^.List^.Count,CKol));}
   If SprList[BKSertif].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BKSertif].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BKSertif].Elements^.GetText(l,SprList[BKSertif].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     System.Delete(SKod,1,1);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CKSertif);
     Format (SElement,CKSertif);
     KSertifList^.List^.Insert(NewStr(SElement+'│'+SKod));
     KSertifList^.SetRange(KSertifList^.List^.Count);
     End;
    End;{For}
  End;

If Cod<>0 Then Dec(Cod);

KSertifList^.FocusItem(Cod);
NoInfoMsg;

Redraw;
PrevCurrentLine[0]:=#0;
end;


Procedure TKSertifWindow.ImportSPR;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  KSertifFile : File;
  KSertifElement : PBufKSertifType;
  c1,Count : Word;
  txt : Text;
  SeparatorChar : AllStr;
begin
ClearFind;
SeparatorChar:=';';
DInfoMsg('Экспортирую списки органов сертификации...',False);

FastRead:=False;

If (Compress=1) And (SprList[bKSertif].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'KSertif.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BKSertif].Time)=L Then  FastRead:=True;
End;



Assign(txt,Path^.Dat.ToTemp+'ksertif.csv');
c:=IOResult;
Rewrite(txt);
c:=IOResult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+'Ошибка создания '+Path^.Dat.ToTemp+'ksertif.csv'+' Код:'+IntToStr(c,ckol),Nil,mfError+mfCancelButton);
  Exit;
 End;
Writeln(txt,DosToWin('Код')+SeparatorChar+DosToWin('Наименование органа сертификации'));

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
Assign (KSertifFile,Path^.Dat.ToSPR+'Ksertif.db');
c:=IOResult;
Reset (KSertifFile,SizeOf(KSertifType));
c:=IOResult;
 FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(KSertifFile)) Do
 Begin
    New(KSertifElement,Init);
    ReadBufKSertif(KSertifFile,KSertifElement,Count);
For c1:=1 To Count Do
Begin
  If KSertifElement^.Point.Dat[c1].Employ Then
   Begin
    RFormatZerro(KSertifElement^.Point.Dat[c1].Kod,CClientKod);
    ChangeSeparator(KSertifElement^.Point.Dat[c1].KSertif);
    Writeln(txt,KSertifElement^.Point.Dat[c1].Kod+SeparatorChar+DosToWin(KSertifElement^.Point.Dat[c1].KSertif));
   End;
End;{For}
  Dispose(KSertifElement,Done);
 End;
System.Close(KSertifFile);

End
Else
 Begin
  c:=IOResult;
  System.Close(txt);
  c:=IOResult;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
End{}
 Else
  Begin{FAstRead=True}
   If SprList[BKSertif].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BKSertif].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BKSertif].Elements^.GetText(l,SprList[BKSertif].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     System.Delete(SKod,1,1);

     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CKSertif);
     Format (SElement,CKSertif);

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

MessageBox(^M+#3'Данные успешно импортированы в '+Path^.Dat.ToTemp+'ksertif.csv!',Nil,
mfInformation+mfCancelButton);


Redraw;
end;





Destructor TKSertifWindow.Done;
Begin
ClearFind;
Dispose(KSertifList,Done);
TDialog.Done;
End;


procedure TKSertifWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;
    Op : StrNAme;
   KSertifElement : KSertifType;

Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=KSertifList^.GetText(KSertifList^.Focused,KSertifList^.List^.Count);
  s:=Copy(s,1+CKSertif+1,CClientKod);

  R:=GetKSertifEmploy(s);
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

  If SetElementLock(FKSertif,s,Op) Then LockSelect:=True
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
  s:=KSertifList^.GetText(KSertifList^.Focused,KSertifList^.List^.Count);
  s:=Copy(s,1+CKSertif+1,CClientKod);

  r:=False;
  R:=GetKSertifEmploy(s);
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
Assign (F,Path^.Dat.ToSPR+'ksertif.lck');

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
AddProtocol('Общая деблокировка органов сертификации','','');
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
     If (KSertifList^.State and sfFocused <> 0) And (KSertifList^.List<>Nil)And(KSertifList^.List^.Count>=2)
	Then L:=True;

     If L Then
            Begin
     If Password(5) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=KSertifList^.GetText(KSertifList^.Focused,KSertifList^.List^.Count);
                s:=Copy(s,1+CKSertif+1,CClientKod);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=KSertifList^.GetText(KSertifList^.Focused,KSertifList^.List^.Count);
                 s:=Copy(s,1+CKSertif+1,CClientKod);

                 Assign (KSertifFile,Path^.Dat.ToSPR+'ksertif.db');
                 KSertifElement.KSertif[0]:=#0;
                 KSertifElement.Kod:=s;
                 KSertifElement.Employ:=False;

  If Not (WriteLockKSertif(KSertifElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлу органов сертификации!',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetElementUnLock(FKSertif,s));
     ClearEvent(Event);
     Exit;
    End
    Else
     RefreshCashOneSPR(bKSertif);


    Repeat
    Until (SetElementUnLock(FKSertif,s));
    AddProtoCol('Удаление органа сертификации:'+s,'','');
    KSertifList^.List^.AtFree(KSertifList^.Focused);
    KSertifList^.SetRange(KSertifList^.List^.Count);
    If KSertifList^.Focused>0 Then   KSertifList^.FocusItem(KSertifList^.Focused);
    If (KSertifList^.Focused>=KSertifList^.List^.Count) and(KSertifList^.Focused>0) Then
    KSertifList^.FocusItem(KSertifList^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
          End;


kbAlt1         : If Password(5) Then UnlockAll;
kbF9           :Begin
                 CorrectKSertif;
                End;



{временно выключено пока не написана процедура добавления нового региона}
kbGrayPlus,kbAltF1,kbF4:
Begin
L:=False;
If(KSertifList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(KSertifList^.List<>Nil)And(KSertifList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
      If AddKSertif(Event.KeyCode,KSertifElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(KSertifList^.List<>Nil)And(KSertifList^.List^.Count>=1) Then
           KSertifList^.List^.AtFree(KSertifList^.Focused);
        Format(KSertifElement.KSertif,CKSertif);
        KSertifList^.List^.Insert(NewStr(KSertifElement.KSertif+'│'+KSertifElement.Kod));
        KSertifList^.SetRange(KSertifList^.List^.Count);
        KSertifList^.FocusItem(LoCation(KSertifList,KSertifElement.Kod,False));
        Redraw;
       End
       Else
        Begin
         s:=KSertifList^.GetText(KSertifList^.Focused,KSertifList^.List^.Count);
         KSertifElement.Kod:=Copy(s,1+CKSertif+1,CClientKod);
        End;

   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=KSertifElement.Kod;
    Repeat
    Until (SetElementUnLock(FKSertif,Cod));
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
             cod:=Copy(KSertifList^.GetText(KSertifList^.Focused,KSertifList^.List^.Count),1+CKSertif+1,CClientKod);
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
     (Event.Command = cmSelectKSertif) then ClearEvent(Event);

 if (Event.What = evBroadcast) and
     (Event.Command = cmViewSPROrgan) then ClearEvent(Event);


  inherited HandleEvent(Event);
  {
  If (Desktop^.Current=PView(KSertifWindow)) And (Event.What <> EvKeyDown) Then
          Begin
                If (Client^.List <> Nil) And (KSertif^.List^.Count>=1) Then
                 Begin
                  s:=KSertif^.GetText(KSertif^.Focused,KSertif^.List^.Count);
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








Function AddExpert( Cod:Integer; Var ExpertElement:ExpertType):Boolean;
Label 1;
var
  R : TRect;
  AddExpertWin : PDialog;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full,Full1 : Boolean;
  k : LongInt;
  ExpertNum : PBox;
  BufExpertElement : PBufExpertType;
{  l : Boolean;}
  Event:TEvent;
  SRegName : AllStr;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddExpert:=False;
    Exit;
   End;


If (GlobalReadOnly=1) Or (ReadOnlyConst=1) Then
   Begin
    MessageBox(#3^M+ReadOnlyStr^,Nil,mfWarning+mfCancelButton);
    AddExpert:=False;
    Exit;
   End;


If Not(TestSetupKurs(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Не установлен курс USD на '+FDate+'!',Nil,mfError+mfCancelButton);
    AddExpert:=False;
    Exit;
   End;

  If Not(Password(16)) Then
   Begin
    AddExpert:=False;
    Exit;
   End;

C:=IOResult;
AddExpert:=False;
Full:=True;
Full1:=False;

{If Password(5) Then Full1:=True;}

Assign(ExpertFile,Path^.Dat.ToSPR+'Expert.db');

Reset(ExpertFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу ЭЗ!',nil,mfError+mfCancelButton);
 AddExpert:=False;
 Exit;
End;
DInfoMsg('Читаю списки...',False);
 Case Cod Of
  kbGrayPlus,kbAltF1:Begin
     ExpertElement.Employ:=True;
     While Not(Eof(ExpertFile)) And (ExpertElement.Employ) Do
     begin
      ReadExpert(ExpertFile,ExpertElement);
     end;

     If Eof(ExpertFile) And (ExpertElement.Employ) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoPosition^,nil,mfWarning+mfCancelButton);
       System.Close(ExpertFile);
       AddExpert:=False;
       Exit;
      End;
      s:=ExpertElement.Kod;
      ExpertElement.Expert[0]       :=#0;
      ExpertElement.Kod     :=NoExpertStr;
    End;

  kbF4:Begin
     s:=Copy(ExpertList^.GetText(ExpertList^.Focused,ExpertList^.List^.Count),1+CExpert+1,CArtikul);
     Seek(ExpertFile,StrToInt(s));
     Repeat
      ReadExpert(ExpertFile,ExpertElement);
     Until (Eof(ExpertFile)) Or (ExpertElement.Kod=s);
     If Eof(ExpertFile) And (ExpertElement.Kod<>s) Then
      Begin
       NoInfoMsg;
       MessageBox(#3^M+#3+NoFound^,nil,mfError+mfCancelButton);
       System.Close(ExpertFile);
       AddExpert:=False;
       Exit;
      End;
    End;
  Else;
 End;
System.Close(ExpertFile);
1:


If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
Begin
R.Assign(11, 7, 70, 15);
New(AddExpertWin, Init(R, 'Добавить экспертное заключение'));
End
Else
Begin
R.Assign(11, 7, 70, 11);
New(AddExpertWin, Init(R, 'Изменить экспертное заключение'));
End;
AddExpertWin^.Options := AddExpertWin^.Options or ofCenterX or ofCenterY;
AddExpertWin^.Palette := dpCyanDialog;
AddExpertWin^.HelpCtx:=$E011;
R.Assign(9, 1, 37, 2);
Control := New(PInputLine, Init(R, CExpert));
AddExpertWin^.Insert(Control);

  R.Assign(1, 1, 9, 2);
  AddExpertWin^.Insert(New(PLabel, Init(R, '~Э~кс.з:', Control)));


AddExpertWin^.SetData(ExpertElement);


If (Cod = kbGrayPlus)Or (Cod=kbAltF1)  Then
Begin
 R.Assign(58, 3, 59, 7);
 Control := New(PScrollBar, Init(R));
 AddExpertWin^.Insert(Control);
 R.Assign(1, 3, 58, 7);
 ExpertNum := New(PBox, Init(R, 8, PScrollbar(Control)));
 ExpertNum^.NewList(New(PTextCollection, Init(0,1)));

(*
Assign(ExpertFile,Path^.Dat.ToSPR+'Expert.db');
Reset (ExpertFile);
 While Not(Eof(ExpertFile)) Do
  Begin
   ReadExpert(ExpertFile,ExpertElement);
   If Not(ExpertElement.Employ) Then
   Begin
   Format (ExpertElement.Expert,CExpert);
   ExpertNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+ExpertElement.Kod));
   ExpertNum^.SetRange(ExpertNum^.List^.Count);
   ExpertNum^.FocusItem(ExpertNum^.List^.Count);
   End;
  End;
 System.Close(ExpertFile);
*)
Assign(ff,Path^.Dat.ToSPR+'Expert.db');
C:=IOResult;
Reset (ff,SizeOf(ExpertTYPE));
C:=IOResult;

 While Not(Eof(ff)) Do
  Begin
    New(BufExpertElement,Init);
    ReadBufExpert(ff,BufExpertElement,Count);
    For j:=1 To Count Do
    Begin
      If Not(BufExpertElement^.Point.Dat[j].Employ) Then
       Begin
        ExpertNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+BufExpertElement^.Point.Dat[j].Kod));
        ExpertNum^.SetRange(ExpertNum^.List^.Count);
        ExpertNum^.FocusItem(ExpertNum^.List^.Count);
       End;
    End;{For}
   Dispose(BufExpertElement,Done);
  End;
 C:=IOResult;
 System.Close(ff);
 C:=IOResult;



 If Cod=kbF4 Then ExpertNum^.FocusItem(LoCation(ExpertNum,s,False))
 Else ExpertNum^.FocusItem(0);

 AddExpertWin^.Insert(ExpertNum);
 ExpertNum^.HelpCtx:=$E011;

  R.Assign(1, 2, 17, 3);
  AddExpertWin^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', ExpertNum)));
  AddExpertWin^.Insert(Control);
 End;
If Cod=kbF4 Then
 Begin
  R.Assign(40, 1, 53, 2);
  Control := New(PColoredText, Init(R, '      Код:', $3E));
  AddExpertWin^.Insert(Control);
  R.Assign(53, 1, 58, 2);
  Control := New(PColoredText, Init(R, ExpertElement.Kod,$3E));
  AddExpertWin^.Insert(Control);
 End;

AddExpertWin^.SelectNext(False);
NoInfoMsg;
c:=Desktop^.ExecView(AddExpertWin);
If c<>cmCancel Then
 Begin
    AddExpertWin^.GetData(ExpertElement);
    DelSpaceRight(ExpertElement.Expert);

    If ExpertElement.Expert[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое название элемента!',nil,mfError+mfCancelButton);
If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=ExpertNum^.GetText(ExpertNum^.Focused,ExpertNum^.List^.Count);
   s:=Copy(s,1+CExpert+1,CArtikul);
  ExpertNum^.NewList(Nil);
  Dispose(ExpertNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddExpertWin,Done);
    Goto 1;
   End;

  C:=IOResult;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   s:=ExpertNum^.GetText(ExpertNum^.Focused,ExpertNum^.List^.Count);
   s:=Copy(s,1+1,CArtikul);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   If Not(TestEmployElementAndLock(FExpert,s)) Then
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
     Dispose(ExpertNum,Done);
     Dispose(Control,Done);
     Dispose(AddExpertWin,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(ExpertElement.Expert);
   ExpertElement.Employ:=True;

   If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then ExpertElement.Kod:=s;


  {если не удалось записать информацию}
  If Not (WriteLockExpert(ExpertElement)) Then
    Begin
     If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then Dispose(ExpertNum,Done);
     Dispose(Control,Done);
     Dispose(AddExpertWin,Done);
     Repeat
     Until (SetElementUnLock(FExpert,s));
     Goto 1;
    End
    Else
    RefreshCashOneSPR(BExpert);


  If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
   AddProtocol('Добавление эксп.заключ.:'+ExpertElement.Expert+' ('+s+')','','');
   Repeat
   Until (SetElementUnLock(FExpert,s));
  End
  Else
   AddProtocol('Корректировка эксп.заключ.:'+ExpertElement.Expert+' ('+ExpertElement.Kod+')','','');
  AddExpert:=True;
 End;

If (Cod=kbGrayPlus)Or (Cod=kbAltF1) Then
  Begin
  ExpertNum^.NewList(Nil);
  Dispose(ExpertNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(AddExpertWin,Done);

  PrevCurrentLine[0]:=#0;

End;




Procedure TExpertWindow.ShowExpertList(Var st:String;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String;
  Bak : String;
  c: Word;
  c1,Count : Word;
  ExpertFile : File;
  ExpertElement : PBufExpertType;
begin
Bak :=St;
ClearFind;
DInfoMsg('Читаю списки...',False);

Res:=0;
R.Assign(30, 5, 79, 22);
New(ExpertWindow, Init(R, Expert_RegNom^));

R.Assign(48, 1, 49, 16);
Control := New(PScrollBar, Init(R));
ExpertWindow^.Insert(Control);

R.Assign(1, 1, 48, 16);
ExpertList := New(PBox, Init(R, 1, PScrollbar(Control)));
ExpertList^.NewList(New(PTextCollection, Init(0,1)));

(*
Assign (ExpertFile,Path^.Dat.ToClient+'.db');
c:=IOResult;
Reset (ExpertFile,SizeOf(ExpertType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(ExpertFile)) Do
 Begin
    New(ExpertElement,Init);
    ReadBufExpert(ExpertFile,ExpertElement,Count);
For c1:=1 To Count Do
Begin
  If ExpertElement^.Point.Dat[c1].Employ Then
   Begin
    Format (ExpertElement^.Point.Dat[c1].Expert,CExpert);
    ExpertList^.List^.Insert(NewStr(ExpertElement^.Point.Dat[c1].Expert+'│'+ExpertElement^.Point.Dat[c1].Kod));
    ExpertList^.SetRange(ExpertList^.List^.Count);
   End;
End;{For}
  Dispose(ExpertElement,Done);
 End;{While}
System.Close(ExpertFile);
End
Else
 Begin
  St:=BAk;
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
s:=Copy(st,1+CExpert+1,CClientKod);
ExpertList^.FocusItem(Location(ExpertList,S,False));
ExpertList^.HelpCtx:=$E171;
ExpertWindow^.Insert(ExpertList);
PrevCurrentLine:=Copy(ExpertList^.GetText(ExpertList^.Focused,ExpertList^.List^.Count),1+CExpert+1,CClientKod);

ExpertWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;
*)
FastRead:=False;
If (Compress=1) And (SprList[bExpert].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'Expert.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BExpert].Time)=L Then  FastRead:=True;
End;

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
Assign (ExpertFile,Path^.Dat.ToSPR+'Expert.db');
c:=IOResult;
Reset (ExpertFile,SizeOf(ExpertType));
c:=IOResult;
FileMode:=OLDFileMOde;
If c=0 Then
Begin
While Not(Eof(ExpertFile)) Do
 Begin
    New(ExpertElement,Init);
    ReadBufExpert(ExpertFile,ExpertElement,Count);
For c1:=1 To Count Do
Begin
  If ExpertElement^.Point.Dat[c1].Employ Then
   Begin
    Format (ExpertElement^.Point.Dat[c1].Expert,CExpert);
    ExpertList^.List^.Insert(NewStr(ExpertElement^.Point.Dat[c1].Expert+'│'+ExpertElement^.Point.Dat[c1].Kod));
    ExpertList^.SetRange(ExpertList^.List^.Count);
   End;
End;{For}
  Dispose(ExpertElement,Done);
 End;{While}
System.Close(ExpertFile);
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
   If SprList[BExpert].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BExpert].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BExpert].Elements^.GetText(l,SprList[BExpert].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CExpert);
     Format (SElement,CExpert);
     ExpertList^.List^.Insert(NewStr(SElement+'│'+SKod));
     ExpertList^.SetRange(ExpertList^.List^.Count);
     End;
    End;{For}
  End;

if st[0]<>#0 Then
s:=Copy(st,Pos('│',st)+1,CArtikul)
Else
s:=NoExpertStr;
RFormatZerro(s,CArtikul);
ExpertList^.FocusItem(Location(ExpertList,S,False));


ExpertList^.HelpCtx:=$F371;
ExpertWindow^.Insert(ExpertList);
PrevCurrentLine:=Copy(ExpertList^.GetText(ExpertList^.Focused,ExpertList^.List^.Count),1+CExpert+1,CArtikul);
ExpertWindow^.SelectNext(False);
PrevCurrentLine[0]:=#0;
NoInfoMsg;

c:=Desktop^.ExecView(ExpertWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   If Res in[2,3] Then
   St:=ExpertList^.GetText(ExpertList^.Focused,ExpertList^.List^.Count)
   Else St:=Bak;
1:
Dispose(COntrol,Done);
Dispose(ExpertWindow,Done);
end;


Procedure TExpertWindow.ImportSpr;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  ExpertFile : File;
  ExpertElement : PBufExpertType;
  c1,Count : Word;
  txt : Text;
  SeparatorChar : AllStr;

begin
ClearFind;
DInfoMsg('Экспортирую базу экспертных заключений ...',False);
SeparatorChar:=';';
FastRead:=False;
If (Compress=1) And (SprList[bExpert].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'Expert.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BExpert].Time)=L Then  FastRead:=True;
End;


Assign(txt,Path^.Dat.ToTemp+'expert.csv');
c:=IOResult;
Rewrite(txt);
c:=IOResult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+'Ошибка создания '+Path^.Dat.ToTemp+'expert.csv'+' Код:'+IntToStr(c,ckol),Nil,mfError+mfCancelButton);
  Exit;
 End;
Writeln(txt,DosToWin('Код')+SeparatorChar+DosToWin('Экспертное заключение'));




If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
Assign (ExpertFile,Path^.Dat.ToSPR+'Expert.db');
c:=IOResult;
Reset (ExpertFile,SizeOf(ExpertType));
c:=IOResult;
FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(ExpertFile)) Do
 Begin
    New(ExpertElement,Init);
    ReadBufExpert(ExpertFile,ExpertElement,Count);
For c1:=1 To Count Do
Begin
  If ExpertElement^.Point.Dat[c1].Employ Then
   Begin
    RFormatZerro (ExpertElement^.Point.Dat[c1].Kod,CArtikul);
    ChangeSeparator(ExpertElement^.Point.Dat[c1].Expert);
    Writeln(txt,ExpertElement^.Point.Dat[c1].Kod+SeparatorChar+DosToWin(ExpertElement^.Point.Dat[c1].Expert));
   End;
End;{For}
  Dispose(ExpertElement,Done);
 End;
System.Close(ExpertFile);
End
Else
 Begin
  System.CLose(txt);
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
End
 Else
  Begin
   If SprList[BExpert].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BExpert].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BExpert].Elements^.GetText(l,SprList[BExpert].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CExpert);
     ChangeSeparator(SElement);
     Writeln(txt,SKod+SeparatorChar+DosToWin(SElement));
     End;
    End;{For}
  End;

c:=IoResult;
System.Close(txt);
c:=IoResult;

NoInfoMsg;

MessageBox(^M+#3'Данные успешно импортированы в '+Path^.Dat.ToTemp+'expert.csv!',Nil,
mfInformation+mfCancelButton);
Redraw;


end;





Procedure TExpertWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String;
  c,Cod: Word;
  ExpertFile : File;
  ExpertElement : PBufExpertType;
  c1,Count : Word;
begin
ClearFind;
DInfoMsg('Обновляю список ...',False);
Cod:=ExpertList^.Focused;

     ExpertList^.NewList(Nil);
     ExpertList^.NewList(New(PTextCollection, Init(0,1)));

FastRead:=False;
If (Compress=1) And (SprList[bExpert].Employ) Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.ToSPR+'Expert.db');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 System.Close(fid);
 Count:=IoResult;
 If (SPRList[BExpert].Time)=L Then  FastRead:=True;
End;

If Not FastRead Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
Assign (ExpertFile,Path^.Dat.ToSPR+'Expert.db');
c:=IOResult;
Reset (ExpertFile,SizeOf(ExpertType));
c:=IOResult;
FileMode:=OldFileMode;
If c=0 Then
Begin
While Not(Eof(ExpertFile)) Do
 Begin
    New(ExpertElement,Init);
    ReadBufExpert(ExpertFile,ExpertElement,Count);
For c1:=1 To Count Do
Begin
  If ExpertElement^.Point.Dat[c1].Employ Then
   Begin
    Format (ExpertElement^.Point.Dat[c1].Expert,CExpert);
    ExpertList^.List^.Insert(NewStr(ExpertElement^.Point.Dat[c1].Expert+'│'+ExpertElement^.Point.Dat[c1].Kod));
    ExpertList^.SetRange(ExpertList^.List^.Count);
   End;
End;{For}
  Dispose(ExpertElement,Done);
 End;
System.Close(ExpertFile);
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
   If SprList[BExpert].Elements^.List^.Count>0 Then
   For l:=0 To SprList[BExpert].Elements^.List^.Count-1 Do
    Begin
     s:=SprList[BExpert].Elements^.GetText(l,SprList[BExpert].Elements^.List^.Count);
     SKod:=Copy(s,1+1,CArtikul);
     If StrToInt(Copy(s,1+1+CArtikul+1,COne))=1 Then
     Begin
     SElement:=Copy(s,1+1+CArtikul+1+COne+1,CExpert);
     Format (SElement,CExpert);
     ExpertList^.List^.Insert(NewStr(SElement+'│'+SKod));
     ExpertList^.SetRange(ExpertList^.List^.Count);
     End;
    End;{For}
  End;

If Cod<>0 Then Dec(Cod);
ExpertList^.FocusItem(Cod);
Redraw;
NoInfoMsg;
PrevCurrentLine[0]:=#0;
end;


Destructor TExpertWindow.Done;
Begin
ClearFind;
Dispose(ExpertList,Done);
TDialog.Done;
End;


procedure TExpertWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;
    Op : StrNAme;
   ExpertElement : ExpertType;


Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=ExpertList^.GetText(ExpertList^.Focused,ExpertList^.List^.Count);
  s:=Copy(s,1+CExpert+1,CArtikul);

  R:=GetExpertEmploy(s);
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

  If SetElementLock(FExpert,s,Op) Then LockSelect:=True
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
  s:=ExpertList^.GetText(ExpertList^.Focused,ExpertList^.List^.Count);
  s:=Copy(s,1+CExpert+1,CArtikul);

  r:=False;
  R:=GetExpertEmploy(s);
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
Assign (F,Path^.Dat.ToSPR+'Expert.lck');

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
AddProtocol('Общая деблокировка экспертных заключений','','');
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
     If (ExpertList^.State and sfFocused <> 0) And (ExpertList^.List<>Nil)And(ExpertList^.List^.Count>=2)
	Then L:=True;

     If L Then
            Begin
     If Password(5) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=ExpertList^.GetText(ExpertList^.Focused,ExpertList^.List^.Count);
                s:=Copy(s,1+CExpert+1,CArtikul);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=ExpertList^.GetText(ExpertList^.Focused,ExpertList^.List^.Count);
                 s:=Copy(s,1+CExpert+1,CArtikul);

                 Assign (ExpertFile,Path^.Dat.ToSPR+'Expert.db');
                 ExpertElement.Expert[0]:=#0;
                 ExpertElement.Kod:=s;
                 ExpertElement.Employ:=False;

  If Not (WriteLockExpert(ExpertElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлу экспертных заключений!',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetElementUnLock(FExpert,s));
     ClearEvent(Event);
     Exit;
    End
    Else
     RefreshCashOneSPR(bExpert);


    Repeat
    Until (SetElementUnLock(FExpert,s));
    AddProtoCol('Удаление экспертного заключения:'+s,'','');
    ExpertList^.List^.AtFree(ExpertList^.Focused);
    ExpertList^.SetRange(ExpertList^.List^.Count);
    If ExpertList^.Focused>0 Then   ExpertList^.FocusItem(ExpertList^.Focused);
    If (ExpertList^.Focused>=ExpertList^.List^.Count) and(ExpertList^.Focused>0) Then
    ExpertList^.FocusItem(ExpertList^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
          End;


kbAlt1         : If Password(5) Then UnlockAll;
kbF9           : CorrectExpert;

{временно выключено пока не написана процедура добавления нового региона}
kbGrayPlus,kbAltF1,kbF4:
Begin
L:=False;
If(ExpertList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(ExpertList^.List<>Nil)And(ExpertList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
      If AddExpert(Event.KeyCode,ExpertElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(ExpertList^.List<>Nil)And(ExpertList^.List^.Count>=1) Then
           ExpertList^.List^.AtFree(ExpertList^.Focused);
        Format(ExpertElement.Expert,CExpert);
        ExpertList^.List^.Insert(NewStr(ExpertElement.Expert+'│'+ExpertElement.Kod));
        ExpertList^.SetRange(ExpertList^.List^.Count);
        ExpertList^.FocusItem(LoCation(ExpertList,ExpertElement.Kod,False));
        Redraw;
       End
       Else
        Begin
         s:=ExpertList^.GetText(ExpertList^.Focused,ExpertList^.List^.Count);
         ExpertElement.Kod:=Copy(s,1+CExpert+1,CArtikul);
        End;

   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=ExpertElement.Kod;
    Repeat
    Until (SetElementUnLock(FExpert,Cod));
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
             cod:=Copy(ExpertList^.GetText(ExpertList^.Focused,ExpertList^.List^.Count),1+CExpert+1,CArtikul);
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
     (Event.Command = cmSelectExpert) then ClearEvent(Event);

 if (Event.What = evBroadcast) and
     (Event.Command = cmViewSPRExpert) then ClearEvent(Event);


  inherited HandleEvent(Event);
  {
  If (Desktop^.Current=PView(ExpertWindow)) And (Event.What <> EvKeyDown) Then
          Begin
                If (Client^.List <> Nil) And (Expert^.List^.Count>=1) Then
                 Begin
                  s:=Expert^.GetText(Expert^.Focused,Expert^.List^.Count);
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




Procedure TAgentWindow.ShowAgentList(Var st:AllStr;Var Res: Word);
Label 1,2;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c: Word;
  c1,Count : Word;
  AgentFile : File;
  AgentElement : PBufKurzClientType;
  st1 : ArtikulStr;
begin
2:
ClearFind;
DInfoMsg('Читаю списки...',False);

Res:=0;
R.Assign(13, 3, 68, 20);
New(AgentWindow, Init(R, 'Выбор агента'));
AgentWindow^.Options := AgentWindow^.Options or ofCenterX Or ofCenterY;

R.Assign(54, 1 ,55, 16);
Control := New(PScrollBar, Init(R));
AgentWindow^.Insert(Control);

R.Assign(1, 1, 54, 16);
Client := New(PBox, Init(R, 2, PScrollbar(Control)));
Client^.NewList(New(PTextCollection, Init(0,1)));
Assign (AgentFile,Path^.Dat.ToClientBaseIndex+'Agent.idx');
c:=IOResult;
Reset (AgentFile,SizeOf(KurzClientType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(AgentFile)) Do
 Begin
    New(AgentElement,Init);
    ReadBufKurzClient(AgentFile,AgentElement,Count);
For c1:=1 To Count Do
Begin
  If AgentElement^.Point.Dat[c1].Employ Then
   Begin
    Format (AgentElement^.Point.Dat[c1].Name,CClient);
    St1:=IntToStr(AgentElement^.Point.Dat[c1].Kod,CClientKod);
    RFormatZerro(St1,CClientKod);

    Client^.List^.Insert(NewStr(AgentElement^.Point.Dat[c1].Name+'│'+st1{AgentElement^.Point.Dat[c1].Kod}));
    Client^.SetRange(Client^.List^.Count);
   End;
End;{For}
  Dispose(AgentElement,Done);
 End;{While}
System.Close(AgentFile);
End
Else
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;

if st[0]<>#0 Then
s:=Copy(st,1+CClient+1,CClientKod)
Else
s:=NoAgentStr;

Client^.FocusItem(Location(Client,S,False{ProdagaWindow}));
Client^.HelpCtx:={E171}$F342;
AgentWindow^.Insert(Client);
PrevAgent:=Copy(Client^.GetText(Client^.Focused,Client^.List^.Count),1+CClient+1,CClientKod);

AgentWindow^.SelectNext(False);
PrevAgent[0]:=#0;
NoInfoMsg;
c:=Desktop^.ExecView(AgentWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   St:=Client^.GetText(Client^.Focused,Client^.List^.Count);

   If (StrToInt(GetAgentField(FEnableMarket,Copy(st,1+CClient+1,CClientKod)))=0) Then
      Begin
       SpecialBeep;
       MessageBox(^M+#3+'Все отгрузки на агента запрещены!',Nil,mfInformation+mfCancelButton);
      End;

   If ShowClients=1 Then
    Begin
     s:=Copy(st,1+CClient+1,CClientKod);
     s:=GetAgentField(FMessages,s);
     If s[0]<>#0 Then
      Begin
       SpecialBeep;
       MessageBox(^M+#3+s,Nil,mfInformation+mfCancelButton);
      End;
    End;
1:
Dispose(COntrol,Done);
Dispose(AgentWindow,Done);
end;



Procedure TAgentWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c,Cod: Word;
  AgentFile : File;
  AgentElement : PBufKurzClientType;
  c1,Count : Word;
  st1 : ArtikulStr;

begin
ClearFind;
DInfoMsg('Обновляю списки агентов...',False);
Cod:=Client^.Focused;

     Assign (AgentFile,Path^.Dat.ToClientBaseIndex+'Agent.idx');
     Client^.NewList(Nil);
     Client^.NewList(New(PTextCollection, Init(0,1)));

c:=IOResult;
Reset (AgentFile,SizeOf(KurzClientType));
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(AgentFile)) Do
 Begin
    New(AgentElement,Init);
    ReadBufKurzClient(AgentFile,AgentElement,Count);
For c1:=1 To Count Do
Begin
  If AgentElement^.Point.Dat[c1].Employ Then
   Begin
    Format (AgentElement^.Point.Dat[c1].Name,CClient);
    St1:=IntToStr(AgentElement^.Point.Dat[c1].Kod,CClientKod);
    RFormatZerro(St1,CClientKod);

    Client^.List^.Insert(NewStr(AgentElement^.Point.Dat[c1].Name+'│'+st1{AgentElement^.Point.Dat[c1].Kod}));
    Client^.SetRange(Client^.List^.Count);
   End;
End;{For}
  Dispose(AgentElement,Done);
 End;
System.Close(AgentFile);
If Cod<>0 Then Dec(Cod);

Client^.FocusItem(Cod);
NoInfoMsg;
End
Else
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;
PrevAgent[0]:=#0;
end;

Procedure TAgentWindow.DrawCurrent;
Var s: String[CAll];
    R : TRect;
Begin
End;



Destructor TAgentWindow.Done;
Begin
ClearFind;
Dispose(Client,Done);
TDialog.Done;
End;



Procedure TAgentWindow.PrintAgentInfo(s:ArtikulStr);
Const Space='           ';
Var f : Text;
    c : Word;
Begin
 Assign(f,Path^.Dat.ToTemp+'rek.txt');
 c:=IOResult;
 Rewrite(f);
 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+'rek.txt!',Nil,mfError+mfCancelButton);
   Exit;
  End;
   Writeln(f,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
   '         РЕКВИЗИТЫ АГЕНТА '+
   GetAgentField(FClient,s)+
   ' ('+s+')'+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
   Writeln(f,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'       Договор: '+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GetAgentField(FNDogovor,s)+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
   Writeln(f,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'   Лимит долга: '+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GetAgentField(FLimit,s)+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);
   Writeln(f,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'         Адрес: '+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GetAgentField(FAdress,s)+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);;
   Writeln(f,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'       Телефон: '+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GetAgentField(FTelefon,s)+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);;
   Writeln(f,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'Расчетный счет: '+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GetAgentField(FRSh,s)+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);;
   Writeln(f,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'             в: '+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GetAgentField(FGde,s)+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);;
   Writeln(f,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'         Город: '+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GetAgentField(FGorod,s)+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);;
   Writeln(f,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'           ИНН: '+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GetAgentField(FINN,s)+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);;
   Writeln(f,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'         ОКОНХ: '+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GetAgentField(FOkonh,s)+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);;
   Writeln(f,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'          ОКПО: '+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GetAgentField(FOkpo,s)+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);;
   Writeln(f,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+'      Лицензия: '+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GetAgentField(FEnvir,s)+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);;
   Writeln(f,Space+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+' Срок лицензии: '+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GetAgentField(FSrok,s)+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);;
   Write(f,Space+GlobalPrn^.Dat.Bold  [Nprint^.DAt.Printer]+'   Консигнация: '+GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]);


   If StrToInt(GetAgentField(FDebit,s))=0 Then
   Writeln(f,'Запрещена!!!'+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
   Else
   Writeln(f,'Разрешена'+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

   Writeln(f,Space+'====================================================================');
System.Close(f);

If (NPrintC^.Dat.AutoAnswerCopy=1) Or FindParam('/AUTOANSWERCOPY') Then
  If MessageBox(^M+#3'Отчет сформирован! Провести печать?',Nil,mfConfirmation+mfOkCAncel)=cmCancel Then Exit;

Report(Path^.Dat.ToTemp+'rek.txt','',1,False,False);
End;


procedure TAgentWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   art,cod : ArtikulStr;
    Op : StrNAme;
 AgentElement : ClientType;


Function LockSelect:Boolean;
Var s : String;
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
  s:=Copy(s,1+CClient+1,CClientKod);

  R:=GetAgentEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать агента с кодом '+s+'. Агент отмечен как удаленный!',False);
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

  If SetClientLock(s,bAgent,0,Op) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg('Агент ['+s+'] используется '+Op+'! Не могу заблокировать агента!',False);
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
  s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
  s:=Copy(s,1+CClient+1,CClientKod);

  r:=False;
  R:=GetAgentEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Нельзя работать с агентом '+s+'. Агент отмечен как удаленный!',False);
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
Assign (F,Path^.Dat.ToClient+'Agent.lck');

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
AddProtocol('Общая деблокировка агентов {сетевая безопасность транзакций}','','');

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
     If (Client^.State and sfFocused <> 0) And (Client^.List<>Nil)And(Client^.List^.Count>=2) Then L:=True;

     If L Then
            Begin
     If Password(3) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
                s:=Copy(s,1+CClient+1,CClientKod);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
                 s:=Copy(s,1+CClient+1,CClientKod);

                 Assign (AgentFile,Path^.Dat.ToClient+'Agent.db');
                 AgentElement.Name[0]:=#0;
                 AgentElement.FullName[0]:=#0;
                 AgentElement.Employ:=False;
                 AgentElement.Limit[0]:=#0;
                 AgentElement.Dogovor[0]:=#0;
{                 For Test:=1 To CPunkt Do
                 AgentElement.Punkt[Test,0]:=#0;}
                 AgentElement.RCD:=False;
                 AgentElement.Adress[0]:=#0;
                 AgentElement.AdressF[0]:=#0;
                 AgentElement.BankKod:=NoBankStr;
                 AgentElement.INN[0]:=#0;
                 AgentElement.R_Sh[0]:=#0;
                 AgentElement.SrokLizensia[0]:=#0;
                 AgentElement.SVidetelstvo[0]:=#0;
                 AgentElement.VekselIP[0]:=#0;
                 AgentElement.VekselDP[0]:=#0;
                 AgentElement.Passport[0]:=#0;
                 AgentElement.Vidan[0]:=#0;
                 AgentElement.Seria[0]:=#0;
                 AgentElement.Lizo:=0;
                 AgentElement.Debit:=0;
                 AgentElement.Messages[0]:=#0;
                 AgentElement.Kod:=s;

  If Not (WriteLockClient(bAgent,0,AgentElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлам агентов !',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetClientUnLock(s,bAgent,0));
     ClearEvent(Event);
     Exit;
    End;

    Repeat
    Until (SetClientUnLock(s,bAgent,0));
    AddProtoCol('Удаление агента:'+s,'','');
    Client^.List^.AtFree(Client^.Focused);
    Client^.SetRange(Client^.List^.Count);
    If Client^.Focused>0 Then   Client^.FocusItem(Client^.Focused);
    If (Client^.Focused>=Client^.List^.Count) and(Client^.Focused>0) Then
    Client^.FocusItem(Client^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
          End;


kbAlt1         : If Password(5) Then UnlockAll;
kbF9           : CorrectAgent(0);

kbGrayPlus,kbAltF1,kbF4:
Begin
L:=False;
If(Client^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(Client^.List<>Nil)And(Client^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
    Begin
      Art:=Copy(Client^.GetText(Client^.Focused,Client^.List^.Count),1+CClient+1,CClientKod);
      Client^.FocusItem(Location(Client,Art,False));
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
    End;
      {If Add^.AddAgent(Event.KeyCode,AgentElement) Then}

      If Add^.AddClient(Event.KeyCode,AgentElement,bAgent,0,{Client}Art) Then
       Begin

        If (Event.KeyCode=kbF4)And(Client^.List<>Nil)And(Client^.List^.Count>=1) Then
           Client^.List^.AtFree(Client^.Focused);
        Format(AgentElement.Name,CClient);
        Client^.List^.Insert(NewStr(AgentElement.Name+'│'+AgentElement.Kod));
        Client^.SetRange(Client^.List^.Count);
        Client^.FocusItem(LoCation(Client,AgentElement.Kod,ProdagaWindow));
        Redraw;
       End
       Else
        Begin
         s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
         AgentElement.Kod:=Copy(s,1+CClient+1,CClientKod);
        End;

   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=AgentElement.Kod;
    Repeat
    Until (SetClientUnLock(Cod,bAgent,0));
   End;
            ClearEvent(Event);
            Redraw;
            End;
kbF3: Begin
     L:=False;
     s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
     s:=Copy(s,1+CClient+1,CClientKod);
     ViewElement(s,bAgent,0);
     ClearEvent(Event);
     Redraw;
      End;

      Else;
      End;{KeyDown}
evCommand:
 Case Event.Command Of
 cmRefresh: Refresh;
 cmLastPrise : Begin
If(Client^.State and sfFocused <> 0)And(Client^.List<>Nil)And(Client^.List^.Count>=1) Then
                Begin
                 s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
                 s:=Copy(s,1+CClient+1,CClientKod);
                 SetupPlan^.SetupPlan(StrToInt(s));
                End;
               End;
 cmPrintReestr:
  Begin
     l:=False;
If(Client^.State and sfFocused <> 0)And(Client^.List<>Nil)And(Client^.List^.Count>=1) Then l:=True;
     If l Then
      Begin
               s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
               s:=Copy(s,1+CClient+1,CClientKod);
               PrintAgentInfo(s);
      End;

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
     (Event.Command = cmSelectAgent) then ClearEvent(Event);

 if (Event.What = evBroadcast) and
     (Event.Command = cmViewSPRAgent) then ClearEvent(Event);


  inherited HandleEvent(Event);
  {
  If (Desktop^.Current=PView(AgentWindow)) And (Event.What <> EvKeyDown) Then
          Begin
                If (Client^.List <> Nil) And (Client^.List^.Count>=1) Then
                 Begin
                  s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
                  If s<>PrevAgent Then
                   Begin
                    PrevAgent:=S;
                    DrawCurrent;
                   End;
                 End;
          End;
  }
  ClearEvent(Event);
end;




End.