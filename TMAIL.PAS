Unit TMAil;

INTERFACE

Uses Glob, ServStr,Dos, Memory, Drivers, App, Serv, Dialogs,Mail;

Procedure TMailDialUpAuto;

{Путь к T-Mail - Path^.Dat.ToTerminal }

IMPLEMENTATION

Uses TPDate,Objects, MsgBox, Utils, Utils1, Utils4, DBEngine,
     Utils5, DbEngin2,Hex,ServStr2,
     Views,Protect, NetCAll, DiskUtil, Utils9;


Function TestFileName(S:AllStr;Const P:PBox):Boolean;
Var Ls : Word;
    st : AllStr;
Begin
TestFileName:=True;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
DelSpace(s);
DelSpace(st);
If St=S Then
   Begin
    TestFileName:=False;
    Break;
   End;
End;
End;



Procedure ScanOutErrors(Const P:PBox);
{Проверяем что осталось в OUT, прибиваем их и снимаем аттрибуты в ARC}
var DirInfo: SearchRec;
    s: string;
    f: file;
    Rez: word;
Begin
FindFirst(Path^.Dat.ToTerminal+'OUT\*.*', Archive, DirInfo);
 while DosError = 0 do
 begin
    s:=DirInfo.Name;
    Assign(f,Path^.Dat.ToTerminal+'OUT\'+s);
    Erase(f);
    If TestFileName(s,P) Then
    Begin
     Assign(f,PathExpImp^.Dat.ToImport[1]+s);
     SetFAttr(f,Archive);
    End;
    FindNext(DirInfo);
 end;

End;

Function TMailSelectOperation(Var l : Word):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
TMailSelectOperation:=False;
l:=1;
R.Assign(15, 8, 64, 12);
New(Dlg, Init(R, 'Удаленный доступ'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 48, 3);
Control := New(PCheckboxes, Init(R,
  NewSItem('~О~тправить документы (перевозки со склада)',
  NewSItem('Отправить отчет склада (*.?0?)',
  Nil)))){)};

Dlg^.Insert(Control);
Dlg^.SetData(L);
Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(l);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  TMailSelectOperation:=True;
 End
 Else Begin
       Dispose(Control,Done);
       Dispose(Dlg,Done);
      End;
end;



function CopyFileWithList(const E:PBox;msg:string):word;
var i: word;
    s: string;
Begin
CopyFileWithList:=100;
if (E<>nil) and (E^.List^.Count>0) then
Begin
  for i:=0 to E^.List^.Count-1 do
  begin
  s:=E^.GetText(i,E^.List^.Count);
  DInfoMSgShkala(msg+Copy(s,8,50),0,E^.List^.Count-1,i);
  {memc(s+NullStr^);}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SwapVectors;

  Exec(GetEnv('Comspec'),' /c '+s+NullStr^);

  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

  {memc(IntToStr(DosError,4));}

  Case DosError Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    4:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
  Else;
  End;
  CopyFileWithList:=DosError;
  End;
End;
NoInfoMsg;
End;



function CopyFile(s:string;msg:String):word;
var i: word;
Begin
  DInfoMSg(msg,False);
  CopyFile:=100;
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SwapVectors;

  Exec(GetEnv('Comspec'),' /c '+s+NullStr^);

  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;
  Application^.Redraw;

  {memc(IntToStr(DosError,4));}

  Case DosError Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    4:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
  Else;
  End;
  CopyFile:=DosError;
  NoInfoMsg;
End;


Function CopyNewPassword:boolean;
var s:string;
     Result : LongInt;
     Kuda : String;

Begin
  CopyNewPassword:=FAlse;
  DInfoMsg('Синхронизирую базу операторов...',False);
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  Kuda:=Path^.Dat.ToOperator;
  Kuda[0]:=Chr(Ord(Kuda[0])-1);
  {копирую system.db и p.pwl}
  s:=Path^.Dat.ToUtils+'rar.exe x -inul'+' -y -w'+Path^.Dat.ToTemp+' '+Path^.Dat.ToArchiv+'system.pwl'+
  ' '+Kuda+' '+NullStr^;
  exec (GetEnv('Comspec'),' /c '+s);

  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;
  CopyNewPassword:=True;
  AddProtocolNoMsg('Обновление базы операторов и паролей успешно завершено !','','');
End;



Function LockUnLockObject(Prefix:Char;c:ArtikulStr;SetLock:Boolean;Var Operator:StrNAme):Boolean;
Var f : File of LockBazType;
    Pos,l : LongInt;
    Code : Integer;
    Paths : String;
    s : LockBazType;
    st : ArtikulStr;
    AllSkl : Maska15;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую контрагента с кодом '+c);
 LockUnLockObject:=False;
 Paths[0]:=#0;
Case Prefix Of
    ClientPrefix:Paths:=Path^.Dat.ToClient+'Client.lck';
    MakePrefix  :Paths:=Path^.Dat.ToClient+'Make.lck';
    BarterPrefix:Paths:=Path^.Dat.ToClient+'Barter.lck';
    AgentPrefix :Paths:=Path^.Dat.ToClient+'Agent.lck';
    SkladPrefix :Paths:=Path^.Dat.ToClient+'Sklad.lck';
EkspeditorPrefix:Paths:=Path^.Dat.ToClient+'Eksped.lck';
Else
  Begin
   NoNetInfoMsg;
   exit;
  End;
End;

 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к контрагенту - позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(LockBazType),SizeOf(LockBazType));{предварительная блокировка}
   Read(f,s);

     L:=IOResult;

     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorField(FNAme,Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Pos);
       Repeat
        Unlock(f,Pos*SizeOf(LockBazType),SizeOf(LockBazType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
        L:=IOResult;
       Exit;
      End;

{$IFDEF NetVersion}
      s.Locked:=SetLock;            {проведение вторичной блокировки/деблокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;

{$ENDIF}
      Seek(f,{Filepos(f)}Pos{-1});
      Write(f,s);
      {Seek(f,Filepos(f)-1);}
      Repeat
      Unlock(f,{FilePos(f)}Pos*SizeOf(LockBazType),SizeOf(LockBazType));
      Until DosError=0;
      Close(f);
      L:=IOResult;
      NoNetInfoMsg;
      LockUnLockObject:=True;
      Exit;
  End;
End;



Procedure ScanCatolgFromUpDAteBase;
Var    s : TMyString;
 DirInfo : SearchRec;         { For Windows, use TSearchRec }
       c : Word;
    SKod : String[CIZena];
    Find : Boolean;
       P : PBox;
       Msg : String;

Procedure EraseFile(ss:String);
Var c : Word;
    f : File;
Begin
Assign(f,ss);
c:=IoResult;
Erase(f);
c:=IoResult;
End;

Procedure AutoSearch(Pr:char);
Begin
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   {If (s[1] in [ClientPrefix,MakePrefix,BarterPrefix,AgentPrefix,SkladPrefix,EkspeditorPrefix]) Then}
   If Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    SKod:=Copy(s,1+1,CClientKod);
    If ExtendedBases(Pr,SKod) Then
      Begin
        {If LockUnLockObject(Pr,SKod,True,Msg) Then}{сетевая блокировка}
         Begin
          AddContrAgent(s);
          LockUnLockObject(Pr,SKod,False,Msg);
          EraseFile(s);
         End
        {Else
          Begin
           MessageBox('Добавление контрагента из '+s+' отложено!',Nil,MfError+mfCAncelButton);
           AddProtocol('Автоматическое добавление контрагента из '+s+' отложено!',
		 'по причине не удачной попытки блокировки','');
          End;
        }
      End;
   End;
   FindNext(DirInfo);
 end;{While}
End;


Procedure AutoSearch2(Pr:char);
Begin
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   {If (s[1] in [GroupPrefix,RegionPrefix]) Then}
   If Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    SKod:=Copy(s,1+1,CClientKod);
    If ExtendedBases2(Pr,SKod) Then
      Begin
        {If LockUnLockObject(Pr,SKod,True,Msg) Then}{сетевая блокировка}
         Begin
          AddContrAgent2(s);
          {LockUnLockObject2(Pr,SKod,False,Msg);}
          EraseFile(s);
         End
         {
	     Else
          Begin
           MessageBox('Добавление контрагента из '+s+' отложено!',Nil,MfError+mfCAncelButton);
           AddProtocol('Автоматическое добавление контрагента из '+s+' отложено!',
		 'по причине не удачной попытки блокировки','');
          End;
         }
      End;
   End;
   FindNext(DirInfo);
 end;{While}
End;


Procedure AutoSearchGTD(Pr:char);
Var sKod : AllStr;
Begin
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    SKod:=Copy(s,1+1,CArtikul);
    If TestExtendedNGTD(StrToInt(SKod)) Then
      Begin
         Begin
          AddNGTDAuto(s);
          EraseFile(s);
         End
      End;
   End;
   FindNext(DirInfo);
 end;
End;


Procedure AutoSearchMarka(Pr:char);
Var sKod : AllStr;
Begin
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    SKod:=Copy(s,1+1,CArtikul);
    If TestExtendedMarka(StrToInt(SKod)) Then
      Begin
         Begin
          AddMarkaAuto(s);
          EraseFile(s);
         End
      End;
   End;
   FindNext(DirInfo);
 end;
End;



Procedure AutoSearchSMarka(Pr:char);
Var sKod : AllStr;
Begin
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    SKod:=Copy(s,1+1,CArtikul);
    If TestExtendedSpecMarka(StrToInt(SKod)) Then
      Begin
         Begin
          AddSpecMarkaAuto(s);
          EraseFile(s);
         End
      End;
   End;
   FindNext(DirInfo);
 end;
End;


Procedure AutoSearchStrana(Pr:char);
Var sKod : AllStr;
Begin
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    SKod:=Copy(s,1+1,CClientKod);
    If TestExtendedPost(StrToInt(SKod)) Then
      Begin
         Begin
          AddPostAuto(s);
          EraseFile(s);
         End
      End;
   End;
   FindNext(DirInfo);
 end;
End;


Procedure AutoSearchFirma(Pr:char);
Var sKod : AllStr;
Begin
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    SKod:=Copy(s,1+1,CClientKod);
    If TestExtendedFirmaPost(StrToInt(SKod)) Then
      Begin
         Begin
          AddFirmaPostAuto(s);
          EraseFile(s);
         End
      End;
   End;
   FindNext(DirInfo);
 end;
End;



Procedure AutoSearchMera(Pr:char);
Var sKod : AllStr;
Begin
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    SKod:=Copy(s,1+1,CClientKod);
    If TestExtendedMera(StrToInt(SKod)) Then
      Begin
         Begin
          AddMeraAuto(s);
          EraseFile(s);
         End
      End;
   End;
   FindNext(DirInfo);
 end;
End;


Procedure AutoSearchKSertif(Pr:char);
Var sKod : AllStr;
Begin
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    SKod:=Copy(s,1+1,CClientKod);
    If TestExtendedKSertif(StrToInt(SKod)) Then
      Begin
         Begin
          AddKSertifAuto(s);
          EraseFile(s);
         End
      End;
   End;
   FindNext(DirInfo);
 end;
End;



Procedure AutoSearchExpert(Pr:char);
Var sKod : AllStr;
Begin
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    SKod:=Copy(s,1+1,CArtikul);
    If TestExtendedExpert(StrToInt(SKod)) Then
      Begin
         Begin
          AddExpertAuto(s);
          EraseFile(s);
         End
      End;
   End;
   FindNext(DirInfo);
 end;
End;


Procedure AutoSearchClass(Pr:char);
Var sKod : AllStr;
Begin
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    SKod:=Copy(s,1+1,CClientKod);
    If TestExtendedClass(StrToInt(SKod)) Then
      Begin
         Begin
          AddClassAuto(s);
          EraseFile(s);
         End
      End;
   End;
   FindNext(DirInfo);
 end;
End;


Procedure AutoSearchKassa(Pr:char);
Var sKod : AllStr;
Begin
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    SKod:=Copy(s,1+1,CClientKod);
    If TestExtendedKassa(StrToInt(SKod)) Then
      Begin
         Begin
          AddKassaAuto(s);
          EraseFile(s);
         End
      End;
   End;
   FindNext(DirInfo);
 end;
End;


Procedure AutoSearchBank(Pr:char);
Var sKod : AllStr;
Begin
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    SKod:=Copy(s,1+1,CClientKod);
    If TestExtendedBank(StrToInt(SKod)) Then
      Begin
         Begin
          AddBankAuto(s);
          EraseFile(s);
         End
      End;
   End;
   FindNext(DirInfo);
 end;
End;


Procedure AutoSearchPersonal(Pr:char);
Var sKod : AllStr;
Begin
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not HiddenAttribute(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    SKod:=Copy(s,1+1,CClientKod);
    If TestExtendedPersonal(StrToInt(SKod)) Then
      Begin
         Begin
          AddPersonalAuto(s);
          EraseFile(s);
         End
      End;
   End;
   FindNext(DirInfo);
 end;
End;

Begin
AutoSearch(ClientPrefix);
AutoSearch(MakePrefix);
AutoSearch(BarterPrefix);
AutoSearch(AgentPrefix);
AutoSearch(SkladPrefix);
AutoSearch(EkspeditorPrefix);
AutoSearch2(GroupPrefix);
AutoSearch2(RegionPrefix);
AutoSearch2(RoutePrefix);


AutoSearchGTD(NGTDPrefix);
AutoSearchMarka(MarkaPrefix);
AutoSearchSMarka(SMarkaPrefix);
AutoSearchStrana(LandsPrefix);
AutoSearchFirma(FirmaPrefix);
AutoSearchBank(BankPrefix);
AutoSearchMera(MeraPrefix);
AutoSearchKSertif(KSertifPrefix);
AutoSearchExpert(ExpertPrefix);
AutoSearchClass(ClassPrefix);
AutoSearchPersonal(PersonalPrefix);
AutoSearchKassa(KassaPrefix);

End;


{генерируем список файлов подлежащих отправке}
{эта процедура работает с локальными данными}
Procedure TMailMakeListOutFile(Var P : PBox);
Var s : TMyString;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
    c : Word;
    Size:String[CIZena];
    TekDAte : TDAteString;
Begin

TekDAte:=FDAte;
DInfoMsg('Формирую список накладных к отправке. Ждите...',True);

 FindFirst(PathExpImp^.Dat.ToImport[1]+PrihodPrefix+'*'+Rek^.Dat.Kod[3]+'.'+Rek^.Dat.Kod[4]+'??', AnyFile, DirInfo);

 while DosError = 0 do
 begin
    s:=DirInfo.Name;
   If Not SystemAttribute(PathExpImp^.Dat.ToImport[1]+DirInfo.Name) Then
   Begin
    If Not(s=FDAte+'.0'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) And
       Not(s=FDAte+'.k'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4])
       {Not(s=ClearChar(TekDAte)+'.p'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4])} Then
    Begin
    Format(s,12);
    Size:=IntToStr(DirInfo.Size,CIZena);
    Format(Size,CIZena);
    s:=s+'│'+Size;
    P^.List^.Insert(NewStr(s));
    P^.SetRange(P^.List^.Count);
    End;
   End;
   FindNext(DirInfo);
 end;{While}
TekDate:=FDate;

NoInfoMsg;
End;


Procedure TMailMakeListOutFileDAyReport(Var P : PBox);
Var s : TMyString;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
    c : Word;
    Size:String[CIZena];
    Sd : TDateString;
Begin

If MessageBox(^M+#3'Сформировать список отчетов к отправке АВТОМАТИЧЕСКИ ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
Begin
DInfoMsg('Формирую список отчетов к отправке. Ждите...',True);

 FindFirst(PathExpImp^.Dat.ToImport[1]+FDAte+'.0'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);

 If FExists(PathExpImp^.Dat.ToImport[1]+FDAte+'.0'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
  Begin
    s:=DirInfo.Name;
   If Not SystemAttribute(PathExpImp^.Dat.ToImport[1]+FDAte+'.0'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    Format(s,12);
    Size:=IntToStr(DirInfo.Size,CIZena);
    Format(Size,CIZena);
    s:=s+'│'+Size;
    P^.List^.Insert(NewStr(s));
    P^.SetRange(P^.List^.Count);
   End;
  End;
{FindFirst(PathExpImp^.Dat.ToImport[1]+FDAte+'.p'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 If FExists(PathExpImp^.Dat.ToImport[1]+FDAte+'.p'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
  Begin
    s:=DirInfo.Name;
   If Not SystemAttribute(PathExpImp^.Dat.ToImport[1]+FDAte+'.p'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    Format(s,12);
    Size:=IntToStr(DirInfo.Size,CIZena);
    Format(Size,CIZena);
    s:=s+'│'+Size;
    P^.List^.Insert(NewStr(s));
    P^.SetRange(P^.List^.Count);
   End;
  End;}


 FindFirst(PathExpImp^.Dat.ToImport[1]+FDAte+'.k'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);

 If FExists(PathExpImp^.Dat.ToImport[1]+FDAte+'.k'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
  Begin
    s:=DirInfo.Name;
   If Not SystemAttribute(PathExpImp^.Dat.ToImport[1]+FDAte+'.k'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
   Begin
    Format(s,12);
    Size:=IntToStr(DirInfo.Size,CIZena);
    Format(Size,CIZena);
    s:=s+'│'+Size;
    P^.List^.Insert(NewStr(s));
    P^.SetRange(P^.List^.Count);
   End;
  End;
NoInfoMsg;
AddProtocol('Автоматическое формирование списка отчетов склада за '+FDate+'!','','');
End
Else
 Begin

  If Not DateDialog(SD) Then Exit;

  FindFirst(PathExpImp^.Dat.ToImport[1]+SD+'.0'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);

 If FExists(PathExpImp^.Dat.ToImport[1]+SD+'.0'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
  Begin
    s:=DirInfo.Name;
    Format(s,12);
    Size:=IntToStr(DirInfo.Size,CIZena);
    Format(Size,CIZena);
    s:=s+'│'+Size;
    P^.List^.Insert(NewStr(s));
    P^.SetRange(P^.List^.Count);
  End;

 FindFirst(PathExpImp^.Dat.ToImport[1]+SD+'.k'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);


 If FExists(PathExpImp^.Dat.ToImport[1]+SD+'.k'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) Then
  Begin
    s:=DirInfo.Name;
    Format(s,12);
    Size:=IntToStr(DirInfo.Size,CIZena);
    Format(Size,CIZena);
    s:=s+'│'+Size;
    P^.List^.Insert(NewStr(s));
    P^.SetRange(P^.List^.Count);
  End;
AddProtocol('Ручное формирование списка отчетов склада за '+SD+'!','','');
 End;

End;

Procedure TMAilMakeListInFileFromUpDAte(Var P : PBox);
Var s : TMyString;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
    c : Word;
    size : String[CIZena];
Begin
DInfoMsg('Формирую список обновлений, подлежащих приему. Ждите...',True);

 FindFirst(PAth^.Dat.ToRemoteDir+Rek^.DAt.Kod+'\'+'update.*', AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not SystemAttribute(PAth^.Dat.ToRemoteDir+Rek^.DAt.Kod+'\'+DirInfo.Name) Then
   Begin
    Format(s,12);
    Size:=IntToStr(DirInfo.Size,CIZena);
    Format(Size,CIZena);
    s:=s+'│'+Size;
    P^.List^.Insert(NewStr(s));
    P^.SetRange(P^.List^.Count);
   End;
   FindNext(DirInfo);
 end;{While}
NoInfoMsg;
End;

{генерируем список файлов подлежащих получению эта процедура работает с удаленнм диском}
Procedure TMailMakeListInFileBase(Prf:ArtikulStr;Var P : PBox);
Var s : TMyString;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
    c : Word;
    size : String[CIZena];
    Find : Boolean;
Begin
 FindFirst(PAth^.Dat.ToRemoteDir+Prf+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   s:=DirInfo.Name;
   If Not SystemAttribute(PAth^.Dat.ToRemoteDir+DirInfo.Name) Then
   Begin
    Format(s,12);
    Size:=IntToStr(DirInfo.Size,CIZena);
    Format(Size,CIZena);
    s:=s+'│'+Size;
    P^.List^.Insert(NewStr(s));
    P^.SetRange(P^.List^.Count);
   End;
   FindNext(DirInfo);
 end;{While}
End;

Procedure TMailDialUpAuto;

VAr L,i : Word;
    OutFirst,InFirst,OutSecond,InSecond : PBox;
    NoCopyBox,CopyBox: PBox;
    R : TRect;
    M : MAska2;
    s : String;
    IO,NumRead,Result : Word;
    StartF,StopF : File;
    c : LongInt;
    Position : LongInt;
    InpErr,OutErr,Inp,Out : Word;
    CurSize,Size : LongInt;
    Event : TEvent;
    Res : LongInt;
    SName,SpecNAme : AllStr;
    NewBaz,BeginUpdate:Boolean;
    f : File;
    TM : LongInt;
    DirInfo: SearchRec;
    Attr: word;
    ff : File;
    Change : Boolean;
Begin

 If Not TMailSelectOperation(l) Then Exit;

 WordToBit2(l,M);
 Convert2(M);

 { 1. Сканируем каталог импорта ARC
       - Подкладываем неотправленныеы файлы T-Mail/OUT
       - проверяем каталог T-Mail/OUT и устанавл. аттрибуты в ARC
   2. Проверяем каталог T-Mail/IN и обрабатываем файлы, затем
   вычищаем каталог (hidden - недокачанные файлы - не тогать!)

   3. Запуск T-Mail

   4. Отправленные файлы -
      Не отправленные файлы - сообщение о повторении сеанса связи
      Принятые файлы - переносим в ARC и обрабатываем
 }

Inp:=0;
InpErr:=0;
Out:=0;
OutErr:=0;
NewBaz:=False;

{создаем динамический список файлов подлежащих отправке}
R.Assign(0,0,0,0);
OutFirst := New(PBox, Init(R, 1, Nil));
OutFirst^.NewList(New(PTextCollection, Init(0,1)));

if (M[1]=1) then
TMailMakeListOutFile(OutFirst);

if M[2]=1 then
TMailMakeListOutFileDAyReport(OutFirst);

{Копируем файлы в T-MAil}

R.Assign(0,0,0,0);
CopyBox := New(PBox, Init(R, 1, Nil));
CopyBox^.NewList(New(PTextCollection, Init(0,1)));


R.Assign(0,0,0,0);
NoCopyBox := New(PBox, Init(R, 1, Nil));
NoCopyBox^.NewList(New(PTextCollection, Init(0,1)));


If (OutFirst^.List^.Count)>0 Then
for i:=0 to OutFirst^.List^.Count do
Begin
  s:=OutFirst^.GetText(i,OutFirst^.List^.Count);

  Change:=False;
  If SystemAttribute(PathExpImp^.Dat.ToImport[1]+copy(s,1,pos('│',s)-1)) Or
     HiddenAttribute(PathExpImp^.Dat.ToImport[1]+copy(s,1,pos('│',s)-1)) Then
  Begin
   Assign(ff,PathExpImp^.Dat.ToImport[1]+copy(s,1,pos('│',s)-1));
   GetFAttr(ff,Attr);
   SetFAttr(ff,Dos.Archive);
   Change:=True;
   SName:=copy(s,1,pos('│',s)-1);
   s:='copy /b '+PathExpImp^.Dat.ToImport[1]+copy(s,1,pos('│',s)-1)
   +' '+Path^.Dat.ToTerminal+'OUT';
   CopyFile(s,'Копирую '+PathExpImp^.Dat.ToImport[1]+copy(s,1,pos('│',s)-1)+'...');

   SetFAttr(ff,Attr);
   NoCopyBox^.List^.Insert(NewStr(sName));
   NoCopyBox^.SetRange(NoCopyBox^.List^.Count);
  End
   Else
  Begin
  s:='copy /b '+PathExpImp^.Dat.ToImport[1]+copy(s,1,pos('│',s)-1)
  +' '+Path^.Dat.ToTerminal+'OUT';
  CopyBox^.List^.Insert(NewStr(s));
  CopyBox^.SetRange(CopyBox^.List^.Count);
  End;

End;

CopyFileWithList(CopyBox,'Перенос отправляемых документов...');

Dispose(CopyBox,Done);

Dispose(OutFirst,DOne);

{Смотрим, что передалось в T-Mail}
R.Assign(0,0,0,0);
OutFirst := New(PBox, Init(R, 1, Nil));
OutFirst^.NewList(New(PTextCollection, Init(0,1)));
FindFirst(Path^.Dat.ToTerminal+'OUT\*.*', Archive, DirInfo);
 while DosError = 0 do
 begin
    s:=DirInfo.Name;
    {ставим аттрибуты в импорте}
    SetCopyMailAttribute(PathExpImp^.Dat.ToImport[1]+s);
    OutFirst^.List^.Insert(NewStr(s));
    OutFirst^.SetRange(OutFirst^.List^.Count);
    FindNext(DirInfo);
 end;

{Необработанные сообщения}
R.Assign(0,0,0,0);
InFirst := New(PBox, Init(R, 1, Nil));
InFirst^.NewList(New(PTextCollection, Init(0,1)));
FindFirst(Path^.Dat.ToTerminal+'IN\*.*', Archive, DirInfo);
 while DosError = 0 do
 begin
    s:=DirInfo.Name;
    Assign(f,Path^.Dat.ToTerminal+'IN\'+s);
    GetFAttr(f,Attr);
    if  Attr<>Hidden then
    begin
     {Обнаружены необработанные сообщения}
     InFirst^.List^.Insert(NewStr(s));
     InFirst^.SetRange(InFirst^.List^.Count);
    end;
    FindNext(DirInfo);
 end;

{Переносим необработанные сообщения}
R.Assign(0,0,0,0);
CopyBox := New(PBox, Init(R, 1, Nil));
CopyBox^.NewList(New(PTextCollection, Init(0,1)));

If (InFirst^.List^.Count)>0 Then
for i:=0 to InFirst^.List^.Count do
Begin
  s:=InFirst^.GetText(i,InFirst^.List^.Count);
  s:='copy /b '+Path^.Dat.ToTerminal+'IN\'+s+' '+
    Copy(PathExpImp^.Dat.ToImport[1],1,length(PathExpImp^.Dat.ToImport[1])-1);
  {memc(s);}
  CopyBox^.List^.Insert(NewStr(s));
  CopyBox^.SetRange(CopyBox^.List^.Count);
End;

if CopyFileWithList(CopyBox,'Перенос необработанных собщений...')=0 then
Begin
{Прибиваем необработанные сообщения}
FindFirst(Path^.Dat.ToTerminal+'IN\*.*', Archive, DirInfo);
 while DosError = 0 do
 begin
    s:=DirInfo.Name;
    Assign(f,Path^.Dat.ToTerminal+'IN\'+s);
    GetFAttr(f,Attr);
    if UpCases(s)=UpCases('system.pwl') Then NewBaz:=True;
    if  Attr<>Hidden then
    begin
     Erase(f);
    end;
    FindNext(DirInfo);
 end;
End;

Dispose(CopyBox,Done);

{обработка сообщений}
ScanCatolgFromUpDAteBase;

{Запуск T_Mail}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToTerminal+'mail.bat';

  exec (GetEnvMy,' /c '+s);

  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  Result:=DosExitCode;
  InitSysError;


  GlobalTime:=TimeStringToTime('hh:mm:ss',Times);
  Application^.Redraw;

  if Result<>0 then
  MessageBox(^M+#3+'Ошибка при запуске T-Mail !',Nil,mfError+mfCancelButton);

  {readln;}

{Проверяем, что пришло и что передалось}

Dispose(inFirst,Done);

R.Assign(0,0,0,0);
InFirst := New(PBox, Init(R, 1, Nil));
InFirst^.NewList(New(PTextCollection, Init(0,1)));
FindFirst(Path^.Dat.ToTerminal+'IN\*.*', Hidden, DirInfo);
 while DosError = 0 do
 begin
    s:=DirInfo.Name;
    if HiddenAttribute(Path^.Dat.ToTerminal+'IN\'+s) then
    begin
    InFirst^.List^.Insert(NewStr(s));
    InFirst^.SetRange(InFirst^.List^.Count);
    end;
    FindNext(DirInfo);
 end;

R.Assign(0,0,0,0);
OutSecond := New(PBox, Init(R, 1, Nil));
OutSecond^.NewList(New(PTextCollection, Init(0,1)));
FindFirst(Path^.Dat.ToTerminal+'OUT\*.*', Archive, DirInfo);
 while DosError = 0 do
 begin
    s:=DirInfo.Name;
    OutSecond^.List^.Insert(NewStr(s));
    OutSecond^.SetRange(OutSecond^.List^.Count);
    FindNext(DirInfo);
 end;

R.Assign(0,0,0,0);
InSecond := New(PBox, Init(R, 1, Nil));
InSecond^.NewList(New(PTextCollection, Init(0,1)));
FindFirst(Path^.Dat.ToTerminal+'IN\*.*', Archive, DirInfo);
 while DosError = 0 do
 begin
    s:=DirInfo.Name;
    InSecond^.List^.Insert(NewStr(s));
    InSecond^.SetRange(InSecond^.List^.Count);
    FindNext(DirInfo);
 end;

R.Assign(0,0,0,0);
CopyBox := New(PBox, Init(R, 1, Nil));
CopyBox^.NewList(New(PTextCollection, Init(0,1)));

If (InSecond^.List^.Count)>0 Then
for i:=0 to InSecond^.List^.Count do
Begin
  s:=InSecond^.GetText(i,InSecond^.List^.Count);
  s:='copy /b '+Path^.Dat.ToTerminal+'IN\'+s+' '+
    Copy(PathExpImp^.Dat.ToImport[1],1,length(PathExpImp^.Dat.ToImport[1])-1);
  CopyBox^.List^.Insert(NewStr(s));
  CopyBox^.SetRange(CopyBox^.List^.Count);
End;

if CopyFileWithList(CopyBox,'Перенос принятых собщений...')=0 then
Begin
 FindFirst(Path^.Dat.ToTerminal+'IN\*.*', Archive, DirInfo);
 while DosError = 0 do
 begin
    s:=DirInfo.Name;
    Assign(f,Path^.Dat.ToTerminal+'IN\'+s);
    GetFAttr(f,Attr);
    if  Attr<>Hidden then
    begin
     Erase(f);
    end;
    FindNext(DirInfo);
 end;
End;

Dispose(CopyBox,Done);

ScanCatolgFromUpDAteBase;

ScanOutErrors(NoCopyBox);  {ПРибиваем оставшиеся в OUT и снимаем аттр в ARC}

Dispose(NoCopyBox,Done);

{Сколько передалось и осталось}
Inp:=InSecond^.List^.Count;
Out:=OutFirst^.List^.Count-OutSecond^.List^.Count;
InpErr:=InFirst^.List^.Count;
OutErr:=OutSecond^.List^.Count;

{завершен прием файлов}
Dispose(OutFirst,Done);
Dispose(InFirst,Done);
Dispose(OutSecond,Done);
Dispose(InSecond,Done);

AddProtocol('Завершение сеанса связи! ','','');

MessageBox(#3+'Операция успешно завершена!'^M^M+
'   Всего принято: '+IntToStr(Inp,CLitr)+',  Ошибок: '+IntToStr(InpErr,CLitr)+^M+
'Всего отправлено: '+IntToStr(Out,CLitr)+',  Ошибок: '+IntToStr(OutErr,CLitr),Nil,mfInformation+mfCAncelButton);

If NewBaz Then
Begin
 CopyNewPassword;
End;

End;


BEGIN
END.