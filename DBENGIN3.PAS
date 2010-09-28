{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit DbEngin3;

Interface

Uses Dialogs,Glob,ServStr,DbEngine;



Function GetPersonalEmploy(C:ArtikulStr):Boolean;        {2}
Function GetPersonalField(Field:Byte;C:ArtikulStr):String;

Function GetBankEmploy(C:ArtikulStr):Boolean;        {2}
Function GetBankField(Field:Byte;C:ArtikulStr):String;

Function GetTransport(As:DocumentEditZ;Var E :PTransportType):Boolean;
Function GetPereozenka(As:DocumentEditZ;Var E :PPereozenkaType):Boolean;
Function GetRewisia(As:DocumentEditZ;Var E :PRewisiaType):Boolean;



Procedure CorrectKassa;
Procedure CorrectPersonal;
Procedure CorrectBank;

Function GetKassaOperationEmploy(C:ArtikulStr):Boolean;        {2}
Function GetKassaOperationField(Field:Byte;C:ArtikulStr):String;
Function GetDolgClient(Date : TDAteString;Kod:ArtikulStr; Regim:Word;
{признак какой долг интересует 0 - черный
                               1 - только СФ
						 2 - ВСЕ}
   VAr Summa: AllStr;Var NewStart:TDAteString):Boolean;

Implementation

{$I Compile.INC}
Uses Memory,Dos,MsgBox,Views,Objects,{Validate,}App,Drivers,Protect,SysTime,
     TPDate,NetDbEng,Serv,Access4,Utils5,Utils7,ColorTxt,Validate,
     ServStr2,
     Utils1,Utils,Access1,Mail;

Var OldFileMode : Word;


Function GetPersonalEmploy(C:ArtikulStr):Boolean;
Var f : PersonalFileType;
    l : LongInt;
    Code : Integer;
    s : PersonalType;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'Personal.db');
 GetPersonalEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла персонала!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения персонала '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Code:=IOResult;
   ReadPersonal(f,s);
   Close(f);
   GetPersonalEmploy:=S.Employ;
  End;
End;



Function GetBankEmploy(C:ArtikulStr):Boolean;
Var f : BankFileType;
    l : LongInt;
    Code : Integer;
    s : BankType;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'Banks.db');
 GetBankEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия базы банков!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения банка '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Code:=IOResult;
   ReadBank(f,s);
   Close(f);
   GetBankEmploy:=S.Employ;
  End;
End;



Function GetKassaOperationEmploy(C:ArtikulStr):Boolean;
Var f : KassaOperationFileType;
    l : LongInt;
    Code : Integer;
    s : KassaOperationType;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'Kassa.db');
 GetKassaOperationEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия базы кассовых операций!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения базы кассовых операций '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Code:=IOResult;
   ReadKassa(f,s);
   Close(f);
   GetKassaOperationEmploy:=S.Employ;
  End;
End;



Function GetPersonalField(Field:Byte;C:ArtikulStr):String;
Var f : PersonalFileType;
    l : LongInt;
    s : PersonalType;
    st : ArtikulStr;
    Code : Integer;
    ss : TMyString;
Begin
 GetPersonalField:=#0;
 ss[0]:=#0;

 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'Personal.db');
 GetPersonalField:=#0;
 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла персонала!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения персонала '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   ReadPersonal(f,s);
   Close(f);
   l:=IOResult;
   Case Field Of
    FName,
    FPersonal : GetPersonalField:=S.NAme;
    FInput    : GetPersonalField:=IntToStr(S.StatusIn,CMantissa);
    FOutPut   : GetPersonalField:=IntToStr(S.StatusOut,CMantissa);
    Else;
   End;
  End;

End;


Function GetBankField(Field:Byte;C:ArtikulStr):String;
Var f : BankFileType;
    l : LongInt;
    s : BankType;
    st : ArtikulStr;
    Code : Integer;
    ss : TMyString;
Begin
 GetBankField:=#0;
 ss[0]:=#0;


 If Field in [FBank,FName] Then
 If ReadCashSpr(bBank,c,ss) Then
   Begin
    DelSpaceRight(ss);
    GetBankField:=ss;
    Exit;
   End;

 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'Banks.db');
 GetBankField:=#0;
 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия базы банков!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения банка '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   ReadBank(f,s);
   Close(f);
   l:=IOResult;
   DelSpaceRight(S.FullNAme);
   Case Field Of
    FName,
    FBank : GetBankField:=S.FullNAme;
    FRSh  : GetBankField:=S.RSh;
    FINN  : GetBankField:=S.INN;
    FKPP  : GetBankField:=S.KPP;
    FKSh  : GetBankField:=S.KSh;
    FGde  : GetBankField:=S.Gde;
    FBik  : GetBankField:=S.Bik;
    Else;
   End;
  End;

End;




Function GetKassaOperationField(Field:Byte;C:ArtikulStr):String;
Var f : KassaOperationFileType;
    l : LongInt;
    s : KassaOperationType;
    st : ArtikulStr;
    Code : Integer;
    ss : TMyString;
Begin
 GetKassaOperationField:=#0;
 ss[0]:=#0;

 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Assign (f,Path^.Dat.ToSPR+'Kassa.db');
 GetKassaOperationField:=#0;
 l:=IOResult;
 Reset(f);
 FileMode:=OldFileMode;
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия базы кассовых операций!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     l:=IOResult;
     MessageBox(^M+#3'Попытка чтения кассовой операции '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   ReadKassa(f,s);
   Close(f);
   l:=IOResult;
   Case Field Of
    FName,
    FKassa1: GetKassaOperationField:=S.NAme1;
    FName2,
    FKassa2: GetKassaOperationField:=S.NAme2;
    FStatus: GetKassaOperationField:=IntToStr(S.Status,CMantissa);
    Else;
   End;
  End;

End;


Function GetDolgClient(Date : TDAteString;Kod:ArtikulStr; Regim:Word;
{признак какой долг интересует 0 - только СФ
                               1 - черный
						 2 - ВСЕ}
   VAr Summa: AllStr;Var NewStart:TDAteString):Boolean;
Label 544;
Var ClientDolgFile : File Of ClientDolgType;
    ClientDolgElement : ClientDolgType;
    c : Word;
    l,l1,l2 : LongInt;
    Ext : TDAteSTring;

Begin
GetDolgClient:=False;
Summa[0]:=#0;

Ext:=IntToSTr(StrToInt(Rek^.DAt.Kod),CMantissa);
RFormatZerro(Ext,CMAntissa);

NewStart:=DateToDateString(DateMask,DateStringToDate(DateMask,Date)+1);
Assign (ClientDolgFile,Path^.Dat.TOarchiv+Date+'.d'+Ext);
c:=IOResult;
Reset  (ClientDolgFile);
c:=IOResult;
If c<>0 Then
 Begin
  {цикл поиска ближайшего файла долгов}
   l1:=DateStringToDAte(DAteMAsk,DAte)-1;
   l2:=l1-200;{DateStringToDAte(DAteMAsk,'01-01-00')};
   For l:=l1 DownTo l2 Do
    Begin
     DAte:=DateToDateString(DAteMAsk,l);
     NewStart:=DateToDateString(DateMask,DateStringToDate(DateMask,Date)+1);
     If FExists(Path^.Dat.TOarchiv+Date+'.d'+Ext) Then
      Begin
Assign (ClientDolgFile,Path^.Dat.TOarchiv+Date+'.d'+Ext);
c:=IOResult;
Reset  (ClientDolgFile);
c:=IOResult;
       NewStart:=DateToDateString(DateMask,DateStringToDate(DateMask,Date)+1);
       Goto 544;
      End;
    End;

  Exit;
 End;

544:
DInfoMsg('Определяю долг клиента на '+Date+'. Ждите... ',True);

If (FileSize(ClientDolgFile)-1)<StrToInt(Kod) Then
 Begin
  NoInfoMsg;
  Close(ClientDolgFile);
  c:=IOResult;
  Exit;
 End;

Seek(ClientDolgFile,StrToInt(Kod));
Read(ClientDolgFile,ClientDolgElement);
Case Regim Of
0:Summa:=RealToStr(ClientDolgElement.DolgSF,CIZena,CMantissa);
1:Summa:=RealToStr(ClientDolgElement.Dolg-ClientDolgElement.DolgSF,CIZena,CMantissa);
2:Summa:=RealToStr(ClientDolgElement.Dolg,CIZena,CMantissa);
Else;
End;

System.Close(ClientDolgFile);
  c:=IOResult;

NoInfoMsg;
GetDolgClient:=True;
End;


Procedure CorrectKassa;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of KassaOperationType;
         BB : PKassaOperationType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

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

C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'Kassa.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'Kassa.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),CClientKod);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):CClientKod,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CClientKod);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):CClientKod,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, CClientKod));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),CClientKod)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'Kassa.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CClientKOd,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CClientKod);
   BB^.Dat.Name1[0] :=#0;
   BB^.Dat.Name2[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Kassa.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'Kassa.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Kassa.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'Kassa.db','','');
   RefreshCashOneSPR(bKassa);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;



Procedure CorrectPersonal;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of PersonalType;
         BB : PPersonalType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

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

C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'Personal.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'Personal.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),CClientKod);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):CClientKod,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CClientKod);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):CClientKod,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, CClientKod));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),CClientKod)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'Personal.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CClientKOd,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CClientKod);
   BB^.Dat.Name[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Personal.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'Personal.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Personal.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'Personal.db','','');
   RefreshCashOneSPR(bPersonal);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;

Procedure CorrectBank;
Label 1;
Var      s  : AllStr;
         c,c1  : LongInt;
         Eb : File Of BankType;
         BB : PBankType;
         Max,Pr,Emp : AllStr;
         Setup : String[5];
         RKod : ArtikulStr;
         Dlg : PDialog;
         R : TRect;
         Control : PView;
         j : Word;
Begin
ClearFind;

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

C:=IOResult;

If Not(Password(5)) Then Exit;

Assign(Eb,Path^.Dat.ToSPR+'Banks.db');
Reset(Eb);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(^M+#3'Ошибка доступа к '+Path^.Dat.ToSPR+'Banks.db',nil,mfError+mfCancelButton);
 Exit;
End;

Max:=IntToSTr(FileSize(Eb),CClientKod);
DInfoMsg('Определяю свойства базы...',True);
New(BB,Init);
Emp[0]:=#0;
Pr[0]:=#0;
While Not(Eof(Eb)) Do
 BEgin

 Read(Eb,BB^.Dat);

 If (BB^.DAt.Employ) Then
        Begin
         Str((StrToInt(Emp)+1):CClientKod,Emp);{занятые позиции}
         {Pr:=IntToStr(FilePos(Eb),CDate);{последний занятый код}
         Pr:=IntToStr(StrToInt(BB^.DAt.Kod),CClientKod);
        End;


 End;
CLose(Eb);
Dispose(BB,Done);
NoInfoMsg;

1:
R.Assign(22, 7, 61, 16);
New(Dlg, Init(R, 'Свойства базы'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;


R.Assign(9,3,23,4);
Control := New(PColoredText, Init(R, 'Всего позиций:', $74));
Dlg^.Insert(Control);

R.Assign(23, 3, 28, 4);
STr(StrToInt(MAx):CClientKod,MAx);
Control := New(PColoredText, Init(R, #3+Max, $7E));
Dlg^.Insert(Control);

R.Assign(2, 2, 23, 3);
Control := New(PColoredText, Init(R, 'Используется позиций:', $74));
Dlg^.Insert(Control);

If StrToInt(MAx)>0 Then
MyStr(StrToInt(Emp)/StrToInt(Max)*100,CLitr+1,CMantissa,s)
Else s:='0.00';

R.Assign(23, 2, 38, 3);
Control := New(PColoredText, Init(R, Emp+' '+s+'%', $7E));
Dlg^.Insert(Control);


R.Assign(1, 6, 38, 7);
Control := New(PStaticText, Init(R, ''));
Control^.Options := Control^.Options or ofFramed;
Dlg^.Insert(Control);


R.Assign(24, 6, 31, 7);
Control := New(PInputLine, Init(R, CClientKod));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['0','1','2','3','4','5','6','7','8','9']));

  R.Assign(4, 6, 24, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Установить позиций:', Control)));

R.Assign(6, 4, 23, 5);
Control := New(PColoredText, Init(R, 'Максимальный код:', $74));
Dlg^.Insert(Control);

R.Assign(23, 4, 35, 5);
If pr[0]=#0 Then Pr:='0';
Control := New(PColoredText, Init(R, Pr+' ('+IntToSTr(StrToInt(Pr),CClientKod)+')', $7E));
Dlg^.Insert(Control);

Setup:=Max;
DelSpace(Setup);
Dlg^.SetData(Setup);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
if c<>cmCancel Then
  BEgin

        Dlg^.GetData(Setup);
        If StrToInt(Setup)<(StrToInt(Pr)+1) Then
         BEgin
          Dispose(Control,Done);
          Dispose(Dlg,Done);
          MessageBox(RestructError^,Nil,mfError+mfCAncelButton);
          Goto 1;
         End;

Dispose(Control,Done);
Dispose(Dlg,Done);


DInfoMsg('Провожу реструктуризацию. Ждите ...',True);


        If StrToInt(Setup)>StrToInt(MAx) Then{надо добавлять позиции}
        Begin
         Assign(Eb,Path^.Dat.ToSPR+'Banks.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
          Seek(Eb,StrToInt(Max));
          New(bb,Init);
          For c:=1 To (StrToInt(Setup)-StrToInt(MAx)) Do
                Begin
   BB^.Dat.Employ :=False;
   Str(C-1+StrToInt(MAx):CClientKOd,S);
   BB^.Dat.Kod :=s;
   RFormatZerro(BB^.Dat.Kod,CClientKod);
   BB^.Dat.FullName[0] :=#0;
   BB^.Dat.RCD:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          c:=Ioresult;
          Close(Eb);
          c:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Banks.db',Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

        End;


If StrToInt(Setup)<=StrToInt(MAx) Then{надо сокращать позиции}
Begin
         Assign(Eb,Path^.Dat.ToSPR+'Banks.db');
         Reset(Eb);
         c:=Ioresult;
         If c=0 Then
         Begin
         Seek(Eb,StrToInt(Setup));
         c:=Ioresult;
         Truncate(Eb);
         c:=Ioresult;
         Close(Eb);
         c:=Ioresult;
         End
         Else
          Begin
                NoInfoMsg;
                MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSPR+'Banks.db',Nil,mfError+mfCancelButton);
                Exit;
          End;

End;
   NoInfoMsg;
   MessageBox(^M+#3+'Реструктаризация успешно завершена!',Nil,mfInformation+mfCancelButton);
   AddProtocol('Реструктаризация базы '+Path^.Dat.ToSPR+'Banks.db','','');
   RefreshCashOneSPR(bBank);
  End
Else
Begin
Dispose(Control,Done);
Dispose(Dlg,Done);
End;

End;



Function GetTransport(As:DocumentEditZ;Var E :PTransportType):Boolean;
VAr  ef : TransportFileType;
     Find : Boolean;
     i : Word;
     L : PTransportType;
Begin
  GetTransport:=False;
  Assign(ef,Path^.Dat.ToTransPort+As.D+'.trn');
  i:=IOResult;
  Reset(ef);
  i:=IOResult;
  If i<>0 Then
   Begin
    MessageBox(^M+#3+'Ошибка открытия '+Path^.Dat.ToTransport+As.D+'.trn!'^M+#3+
               ClicProgrammer^,Nil,mfInsertInApp+mfError+mfCancelButton);
    Exit;
   End;

  New(L,Init);
  DelSpace(As.EditPosition);
  Find:=False;
{ DInfoMsg('Ищу документ '+Er^.Dat.Market.Document+' от '+Er^.Dat.Market.DateC+'...',False);}


 {оптимизация поиска}
   If FileSize(ef)>(StrToInt(As.EditPosition)-1) Then
    Begin
     Seek(ef,StrToInt(As.EditPosition)-1);
     ReadTransport(ef,L);
     DelSpace(L^.Dat.Document);
     If ((StrToInt(ClearChar(As.EditPosition))=StrToInt(ClearChar(L^.Dat.Document)))And
          (As.D=L^.Dat.DateC) And (L^.Dat.Active)) Then
         Begin
             Find:=True;
         End
         Else Seek(ef,0);
    End;



  While Not(Eof(ef)) And Not(Find) Do
        Begin
         ReadTransport(ef,L);
         DelSpace(L^.Dat.Document);
          If ((StrToInt(ClearChar(As.EditPosition))=StrToInt(ClearChar(L^.Dat.Document)))And
          (As.D=L^.Dat.DateC) And (L^.Dat.Active)) Then Find:=True;
        End;

  If Not(Find) Then
   Begin
    {NoInfoMsg;}
    Dispose(L,Done);
    Close(Ef);
    MessageBox(^M+#3'Документ N '+ClearChar(As.EditPosition)+
    ' от '+As.D+' не найден !'^M+
    #3+ClicProgrammer^,Nil,mfInsertInApp+mfError+mfCancelButton);
    Exit;
   End;
  E^.Dat:=L^.Dat;
  Dispose(L,Done);
  Close(Ef);
  {NoInfoMsg;}
  GetTransport:=True;
End;


Function GetRewisia(As:DocumentEditZ;Var E :PrewisiaType):Boolean;
VAr  ef : RewisiaFileType;
     Find : Boolean;
     i : Word;
     L : PRewisiaType;
Begin
  GetRewisia:=False;
  Assign(ef,Path^.Dat.ToRewisia+As.D+'.rwz');
  i:=IOResult;
  Reset(ef);
  i:=IOResult;
  If i<>0 Then
   Begin
    MessageBox(^M+#3+'Ошибка открытия '+Path^.Dat.ToRewisia+As.D+'.trn!'^M+#3+
               ClicProgrammer^,Nil,mfInsertInApp+mfError+mfCancelButton);
    Exit;
   End;

  New(L,Init);
  DelSpace(As.EditPosition);
  Find:=False;
{ DInfoMsg('Ищу документ '+Er^.Dat.Market.Document+' от '+Er^.Dat.Market.DateC+'...',False);}


 {оптимизация поиска}
   If FileSize(ef)>(StrToInt(As.EditPosition)-1) Then
    Begin
     Seek(ef,StrToInt(As.EditPosition)-1);
     ReadRewisia(ef,L);
     DelSpace(L^.Dat.Document);
     If ((StrToInt(ClearChar(As.EditPosition))=StrToInt(ClearChar(L^.Dat.Document)))And
          (As.D=L^.Dat.DateC) ) Then
         Begin
             Find:=True;
         End
         Else Seek(ef,0);
    End;



  While Not(Eof(ef)) And Not(Find) Do
        Begin
         ReadRewisia(ef,L);
         DelSpace(L^.Dat.Document);
          If ((StrToInt(ClearChar(As.EditPosition))=StrToInt(ClearChar(L^.Dat.Document)))And
          (As.D=L^.Dat.DateC) ) Then Find:=True;
        End;

  If Not(Find) Then
   Begin
    {NoInfoMsg;}
    Dispose(L,Done);
    Close(Ef);
    MessageBox(^M+#3'Документ N '+ClearChar(As.EditPosition)+
    ' от '+As.D+' не найден !'^M+
    #3+ClicProgrammer^,Nil,mfInsertInApp+mfError+mfCancelButton);
    Exit;
   End;
  E^.Dat:=L^.Dat;
  Dispose(L,Done);
  Close(Ef);
  {NoInfoMsg;}
  GetRewisia:=True;
End;






Function GetPereozenka(As:DocumentEditZ;Var E :PPereozenkaType):Boolean;
VAr  ef : PereozenkaFileType;
     Find : Boolean;
     i : Word;
     L : PPereozenkaType;
Begin
  GetPereozenka:=False;
  Assign(ef,Path^.Dat.ToCorrect+As.D+'.prz');
  i:=IOResult;
  Reset(ef);
  i:=IOResult;
  If i<>0 Then
   Begin
    MessageBox(^M+#3+'Ошибка открытия '+Path^.Dat.ToCorrect+As.D+'.prz!'^M+#3+
               ClicProgrammer^,Nil,mfInsertInApp+mfError+mfCancelButton);
    Exit;
   End;
  New(L,Init);
  DelSpace(As.EditPosition);
  Find:=False;

 {оптимизация поиска}
   If FileSize(ef)>(StrToInt(As.EditPosition)-1) Then
    Begin
     Seek(ef,StrToInt(As.EditPosition)-1);
     ReadPereozenka(ef,L);
     DelSpace(L^.Dat.Document);
     If ((StrToInt(ClearChar(As.EditPosition))=StrToInt(ClearChar(L^.Dat.Document)))And
          (As.D=L^.Dat.DateC) ) Then
         Begin
             Find:=True;
         End
         Else Seek(ef,0);
    End;

  While Not(Eof(ef)) And Not(Find) Do
        Begin
         ReadPereozenka(ef,L);
         DelSpace(L^.Dat.Document);
          If ((StrToInt(ClearChar(As.EditPosition))=StrToInt(ClearChar(L^.Dat.Document)))And
          (As.D=L^.Dat.DateC)) Then Find:=True;
        End;

  If Not(Find) Then
   Begin
    {NoInfoMsg;}
    Dispose(L,Done);
    Close(Ef);
    MessageBox(^M+#3'Документ N '+ClearChar(As.EditPosition)+
    ' от '+As.D+' не найден !'^M+
    #3+ClicProgrammer^,Nil,mfInsertInApp+mfError+mfCancelButton);
    Exit;
   End;
  E^.Dat:=L^.Dat;
  Dispose(L,Done);
  Close(Ef);
  GetPereozenka:=True;
End;






End.