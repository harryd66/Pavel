
{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Access1;

Interface

Uses Dialogs,Glob,Drivers,ServStr;


Type POperationWindow= ^TOperationWindow;
     TOperationWindow = object(TDialog)
    Procedure ShowOperationList(Var st:AllStr;Var Res: Word; dolg: boolean);
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type PAgentWindow= ^TAgentWindow;
     TAgentWindow = object(TDialog)
    Procedure PrintAgentInfo(s:ArtikulStr);
    Procedure ShowAgentList(Var st:AllStr;Var Res: Word);
    Procedure DrawCurrent;
    Procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;

Function Addagent( Cod:Integer; Var AgentElement:ClientType):Boolean;
Function ViewAgent(Art:ArtikulStr):Boolean;
Function AddOperation1( Cod:Integer; Var OperationElement:KassaOperation):Boolean;

Function CalcDolg(s:ALLStr):TEnjoyStr;
Function CalcDolgSF(s:ALLStr):TEnjoyStr;

Procedure CalcDolgNew(SKod:ArtikulStr;Var s{долг},sk{скидка}:ALLStr);
Procedure CalcDolgNewSF(SKod:ArtikulStr;Var s{долг},sk{скидка}:ALLStr);
Function SpisDolgFromZerroDocRealiz(L:PSuperMarketType):Boolean;
Function CalcDolgClient(Date : TDAteString):Boolean;


Var
 ClientNum: PBox;
 agentFile : ClientFileType;
 AgentElement : ClientType;
 OperationFile : OperationFileType;
 OperationElement : KassaOperation;
 OperationNum: PBox;

Implementation

{$I Compile.INC}

Uses Printers,Vision4,App,Views,Objects,MsgBox,Serv,
     ColorTxt,Validate,DbEngine,Memory,TpDate,
     Protect,Net,NetDbEng,NetCall,WinDos,Utils;

Var
   AgentWindow : PAgentWindow;
   PrevAgent : String[CAll];
   OperationList : PBox;
   OperationWindow : POperationWindow;

Function SpisDolgFromZerroDocRealiz(L:PSuperMarketType):Boolean;
Var OplataFile :File Of OplataRealizasiaType;
    Oplata : OplataRealizasiaType;
    c : Word;
    Pos1 : LongInt;
Begin
   SpisDolgFromZerroDocRealiz:=False;
   Assign(OplataFile,Path.ToOplata+FDate+'.opl');
   c:=IOResult;
   Reset(OplataFile);
   c:=IOResult;
   If c<>0 Then
    Begin
     If MessageBox(#3'Файл оплаты консигнации за '+FDate+' не найден!'^M+
     #3'Создавать?'+
        +' Код:'+IntToStr(c,3),Nil,mfError+mfOkCancel)=cmOk Then
      Begin
{      c:=IOResult;
       Reset(OplataFile);
       c:=Ioresult;
       If c<>0 Then Rewrite(OplataFile);
       c:=IOResult;}
       If Not(CreatToDayF(DocOplata,FDate)) Then Exit;
       Reset(OplataFile);
       c:=IOResult;
       End
      Else
           Begin
            SpisDolgFromZerroDocRealiz:=False;
            Exit;
           End;
    End;
    with Oplata do
    begin
     Rashet:=False;
     Bn.DAte[0]:=#0;
     Bn.NPlat[0]:=#0;
     Bn.Bank[0]:=#0;
     Bn.Summa[0]:=#0;

     Vozwrat:=False;(**)
     DocNumerReturn[0]:=#0;{для документов возврата}
     DocDAteReturn[0]:=#0;{для документов возврата}

     SkladKod:=Rek.Kod;(**)
     ClientKod:=L^.Dat.ClientKod;(**)
     DateC:=FDate;(**)
     TimeC:=Times;(**)

     Document:=L^.Dat.Document;(**)
     DateDoc:=L^.Dat.DateC;(**)

     TimeC:=Times; {время создания}
     Str(0.00:CIZena:CMantissa,SummaZ);  {сумма оплаты}
     Caption :=CurrentPassword;{признак оператора}
    end;

     DInfoNetMsg('Сохраняю оплату консигнации по докумену N '+Oplata.Document+' от '+Oplata.DateDoc+'...');

    Repeat
     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(OplataFile);
      Seek(OplataFile,Pos1);
     Until (Lock(OplataFile,FilePos(OplataFile)*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)*5));

     Pos1:=FileSize(OplataFile);

     If FilePos(OplataFile)<>{FileSize(OplataFile)}Pos1 Then
      Begin
       Repeat {деблокируем участок записи}
        Pause(1);
        UnLock(OplataFile,(FilePos(OplataFile))*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)*5);
       Until (DosError=0);
      End;
    Until (FilePos(OplataFile)={FileSize(OplataFile)}Pos1);

     Write(OplataFile,Oplata);
     Seek(OplataFile,FilePos(OplataFile)-1);

     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле оплаты консигнации...');
     Repeat {деблокируем участок записи}
     Pause(1);
     UnLock(OplataFile,(FilePos(OplataFile))*SizeOf(OplataRealizasiaType),
         SizeOf(OplataRealizasiaType)*5);
     Until (DosError=0);
    Close(OplataFile);
    NoInfoMsg;
    SpisDolgFromZerroDocRealiz:=True;
End;


Function CalcDolg(s:ALLStr):TEnjoyStr;
Label 1;
Var i : Byte;
    R : Real;
    Count : Word;
    c : Word;
    RealFile : File;
    E : PBufRealizasiaType;
    BakFileMode : Word;
Begin
r:=0;
BakFileMode:=FileMode;
FileMode:=$42;
Assign (RealFile,Path.ToDolg+s+'.dlg');
i:=Ioresult;
Reset(Realfile,SizeOf(RealizasiaType));
FileMode:=BakFileMode;
i:=IOresult;
If (i<>0) Then Begin
                s:='НЕТ_КОНСИГНАЦИИ';
                Goto 1;
               End;
While Not(Eof(RealFile)) Do
 Begin
  New(E,Init);
  {Read(RealFile,E^.Dat);}
  BlockRead(RealFile,E^.Point,BufferDLG,Count);
For c:=1 To Count Do
Begin
  If (E^.Point.Dat[c].Market.Active) Then
  If Not(E^.Point.Dat[c].FULL) Then  r:=r+E^.Point.Dat[c].Dolg;
End;{For}
 Dispose(E,Done);
 End;
i:=Ioresult;
Close(RealFile);
i:=Ioresult;
MyStr(R,CIZena,CMantissa,s);
1:
DelSpace(S);
CalcDolg:=s;
End;

Procedure CalcDolgNew(SKod:ArtikulStr;Var s{долг},sk{скидка}:ALLStr);
Var i : Byte;
    R,Rsk : Real;
    Count : Word;
    BakFileMode,c : Word;
    RealFile : File;
    E : PBufRealizasiaType;
Begin
r:=0;
Rsk:=0;
s:='0.00';
sk:='0.00';
BakFileMode:=FileMode;
FileMode:=$42;
Assign (RealFile,Path.ToDolg+SKod+'.dlg');
i:=Ioresult;
Reset(Realfile,SizeOf(RealizasiaType));
i:=IOresult;
FileMode:=BakFileMode;
If (i<>0) Then Exit;

While Not(Eof(RealFile)) Do
 Begin
  New(E,Init);
  {Read(RealFile,E^.Dat);}
  BlockRead(RealFile,E^.Point,BufferDLG,Count);
For c:=1 To Count Do
Begin
  If (E^.Point.Dat[c].Market.Active) Then
  If Not(E^.Point.Dat[c].FULL) Then
   Begin
    r:=r+E^.Point.Dat[c].Dolg;
    rsk:=rsk+StrToReal(E^.Point.Dat[c].Market.Skidka);
   End;
End;{For}
 Dispose(E,Done);
 End;
i:=Ioresult;
Close(RealFile);
i:=Ioresult;
MyStr(R,CIZena,CMantissa,s);
MyStr(Rsk,CIZena,CMantissa,sk);
End;


Function CalcDolgSF(s:ALLStr):TEnjoyStr;
Label 1;
Var i : Byte;
    R : Real;
    Count : Word;
    BakFileMode,c : Word;
    RealFile : File;
    E : PBufRealizasiaType;
Begin
r:=0;
BakFileMode:=FileMode;
FileMode:=$42;
Assign (RealFile,Path.ToDolg+s+'.dlg');
i:=Ioresult;
Reset(Realfile,SizeOf(RealizasiaType));
i:=IOresult;
FileMode:=BakFileMode;
If (i<>0) Then Begin
                s:='НЕТ_КОНСИГНАЦИИ';
                Goto 1;
               End;
While Not(Eof(RealFile)) Do
 Begin
  New(E,Init);
  {Read(RealFile,E^.Dat);}
  BlockRead(RealFile,E^.Point,BufferDLG,Count);
For c:=1 To Count Do
Begin
  If (E^.Point.Dat[c].Market.Active) Then
  If (E^.Point.Dat[c].Market.DocSelector in [3,4,6,8]) Then
  If Not(E^.Point.Dat[c].FULL) Then  r:=r+E^.Point.Dat[c].Dolg;
End;{For}
 Dispose(E,Done);
 End;
i:=Ioresult;
Close(RealFile);
i:=Ioresult;
MyStr(R,CIZena,CMantissa,s);
1:
DelSpace(S);
CalcDolgSF:=s;
End;

Procedure CalcDolgNewSF(SKod:ArtikulStr;Var s{долг},sk{скидка}:ALLStr);
Var i : Byte;
    R,Rsk : Real;
    Count : Word;
    BakFileMode,c : Word;
    RealFile : File;
    E : PBufRealizasiaType;
Begin
r:=0;
Rsk:=0;
s:='0.00';
sk:='0.00';

BakFileMode:=FileMode;
FileMode:=$42;
Assign (RealFile,Path.ToDolg+sKod+'.dlg');
i:=Ioresult;
Reset(Realfile,SizeOf(RealizasiaType));
i:=IOresult;
FileMode:=BakFileMode;
If (i<>0) Then Exit;

While Not(Eof(RealFile)) Do
 Begin
  New(E,Init);
  {Read(RealFile,E^.Dat);}
  BlockRead(RealFile,E^.Point,BufferDLG,Count);
For c:=1 To Count Do
Begin
  If (E^.Point.Dat[c].Market.Active) Then
  If (E^.Point.Dat[c].Market.DocSelector in [3,4,6,8]) Then
  If Not(E^.Point.Dat[c].FULL) Then
   Begin
    r:=r+E^.Point.Dat[c].Dolg;
    rsk:=rsk+StrToReal(E^.Point.Dat[c].Market.Skidka);
   End;
End;{For}
 Dispose(E,Done);
 End;
i:=Ioresult;
Close(RealFile);
i:=Ioresult;
MyStr(R,CIZena,CMantissa,s);
MyStr(Rsk,CIZena,CMantissa,sk);
End;

Function CalcDolgClient(Date : TDAteString):Boolean;
Var ClientFile : File;
    ClientElement : PBufClientType;
    Find : Boolean;
    ClientDolgFile : File Of ClientDolgType;
    ClientDolgElement : ClientDolgType;
    c ,count : Word;
    s,sk: AllStr;
    Ext : TDAteString;
    {s : String;}
Begin
CalcDolgClient:=False;
Assign (ClientFile,Path.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile,SizeOf(ClientType));
c:=IOResult;
If c=0 Then
Begin
Ext:=IntToSTr(StrToInt(Rek.Kod),CMantissa);
RFormatZerro(Ext,CMAntissa);
Assign (ClientDolgFile,Path.TOarchiv+Date+'.d'+Ext);
c:=IOResult;
Rewrite (ClientDolgFile);
c:=IOResult;

If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка создания '+Path.TOarchiv+Date+'.d'+Ext,Nil,mfError+mfCancelButton);
  close(ClientFile);
  Exit;
 End;

While Not(Eof(ClientFile)) Do
 Begin
     DInfoMsgShkala('Подсчитываю долги клиентов. Ждите... ',0,FileSize(CLientFile),FilePos(CLientFile));
     New(ClientElement,Init);
     Count:=0;
     ReadBufClient(ClientFile,ClientElement,Count);
For c:=1 To Count Do
Begin
   ClientDolgElement.Kod:=ClientElement^.Point.Dat[c].Kod;
   ClientDolgElement.Dolg:=0.0000;
   ClientDolgElement.DolgT:=0.0000;
   ClientDolgElement.DolgSF:=0.0000;
   ClientDolgElement.DolgSFT:=0.0000;
   If ClientElement^.Point.Dat[c].Employ Then
   Begin
    s[0]:=#0;
    sk[0]:=#0;
    CalcDolgNew(ClientElement^.Point.Dat[c].Kod,s,sk);
    ClientDolgElement.Dolg:=StrToReal(s);
    ClientDolgElement.DolgT:=StrToReal(s)+StrToReal(sk);

    s[0]:=#0;
    sk[0]:=#0;
    CalcDolgNewSF(ClientElement^.Point.Dat[c].Kod,s,sk);
    ClientDolgElement.DolgSF:=StrToReal(s);
    ClientDolgElement.DolgSFT:=StrToReal(s)+StrToReal(sk);
   {
    ClientDolgElement.Dolg:=StrToReal(CalcDolg(ClientElement^.Point.Dat[c].Kod));
    ClientDolgElement.DolgSF:=StrToReal(CalcDolgSF(ClientElement^.Point.Dat[c].Kod));
   }
   End;
   Write(ClientDolgFile,ClientDolgElement);
End;{For}
  Dispose(ClientElement,Done);
 End;{While}
System.Close(ClientFile);
System.Close(ClientDolgFile);
NoInfoMsg;
CalcDolgClient:=True;
End
Else
  MessageBox(^M+#3'Ошибка открытия '+Path.ToClient+'Client.db',Nil,mfError+mfCancelButton);
End;



Function AddAgent( Cod:Integer; Var AgentElement:ClientType):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full : Boolean;
  k : LongInt;
{  l : Boolean;}
  Event:TEvent;
begin
ClearFind;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddAgent:=False;
    Exit;
   End;

C:=IOResult;
AddAgent:=False;
Full:=True;

Assign(AgentFile,Path.ToClient+'agent.db');

Reset(AgentFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу агентов!',nil,mfError+mfCancelButton);
 AddAgent:=False;
 Exit;
End;
AInfo('Читаю списки...');
 Case Cod Of
  kbGrayPlus:Begin
     AgentElement.Employ:=True;
     While Not(Eof(AgentFile)) And (AgentElement.Employ) Do
     begin
      ReadClient(AgentFile,AgentElement);
     end;


     If Eof(AgentFile) And (AgentElement.Employ) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Свободных позиций для агентов - нет!',nil,mfWarning+mfCancelButton);
       System.Close(AgentFile);
       AddAgent:=False;
       Exit;
      End;
      s:=AgentElement.Kod;
      AgentElement.Name[0]       :=#0;
      AgentElement.FullName[0]       :=#0;

      AgentElement.Adress[0]     :=#0;
      AgentElement.Dogovor[0]    :=#0;
      AgentElement.Limit[0]      :=#0;
      For c:=1 To CPunkt Do
      AgentElement.Punkt[c,0]        :=#0;
      AgentElement.INN[0]        :=#0;
      AgentElement.R_Sh[0]       :=#0;
      AgentElement.Gde[0]        :=#0;
      AgentElement.Gorod[0]      :=#0;
      AgentElement.Test_Srok[0]  :=#0;
      AgentElement.Prozent[0]:=#0;
      AgentElement.Region:=0;
      AgentElement.Okonh[0]      :=#0;
      AgentElement.Okpo[0]       :=#0;
      AgentElement.Enviropment[0]:=#0;
      AgentElement.Telefon[0]    :=#0;
      AgentElement.Debit      :=0;
      AgentElement.SrokLizensia[0]    :=#0;
      AgentElement.Messages[0]:=#0;
      AgentElement.Stat          :=False;
      AgentElement.Locked        :=True;
      AgentElement.NoLimit       :=0;
      AgentElement.AgentKod[1]:='0000';
      AgentElement.AgentKod[2]:='0000';
    End;
  kbF4:Begin
     s:=Copy(Client^.GetText(Client^.Focused,Client^.List^.Count),1+CClient+1,CClientKod);
     Seek(AgentFile,StrToInt(s));
     Repeat
      ReadClient(AgentFile,AgentElement);
     Until (Eof(AgentFile)) Or (AgentElement.Kod=s);
     If Eof(AgentFile) And (AgentElement.Kod<>s) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Агент в базе не найден!',nil,mfError+mfCancelButton);
       System.Close(AgentFile);
       AddAgent:=False;
       Exit;
      End;
    End;
  Else;
 End;
System.Close(AgentFile);
1:
If Cod=kbGrayPlus Then
Begin
R.Assign(9, 1, 71, 24);
New(Dlg, Init(R, 'Добавить агента'));
End
Else
Begin
R.Assign(9, 1, 71, 19);
New(Dlg, Init(R, 'Изменить агента'));
End;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E011;
R.Assign(14, 1, 36, 2);
Control := New(PInputLine, Init(R, 20));
Dlg^.Insert(Control);

  R.Assign(36, 1, 39, 2);
  Dlg^.Insert(New(PHistory, Init(R, PInputline(Control), 12)));

  R.Assign(6, 1, 14, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Аг~е~нт:', Control)));


R.Assign(14, 2, 39, 3);
Control := New(PInputLine, Init(R, 100));
If (Not(Full))Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(5, 2, 14, 3);
{ If Not(VidClienta) Then}
  Dlg^.Insert(New(PLabel, Init(R, 'Пол~н~ое:', Control)));


{ Else
  Dlg^.Insert(New(PLabel, Init(R, 'Дебитор:', Control)));}

R.Assign(48, 2, 61, 3);
Control := New(PInputLine, Init(R, 45));
(*If {((Not(VidClienta)Or Not(l))And}
   Not(l)And(Cod=kbF4){) Or (Not(VidClienta))} Then
Control^.Options := Control^.Options and not ofSelectable;*)
If (Not(Full))Then
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(39, 2, 48, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Д~о~говор:', Control)));





R.Assign(14, 3, 18, 4);
Control := New(PInputLine, Init(R, 2));
{Control^.Options := Control^.Options and not ofSelectable;}
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(3, 3, 14, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'От~д~еление:', Control)));

R.Assign(29, 3, 33, 4);
Control := New(PInputLine, Init(R, 2));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(20, 3, 29, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'П~а~латки:', Control)));

R.Assign(44, 3, 48, 4);
Control := New(PInputLine, Init(R, 2));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(34, 3, 44, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Ма~г~азины:', Control)));

R.Assign(55, 3, 59, 4);
Control := New(PInputLine, Init(R, 2));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(49, 3, 55, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Ка~ф~е:', Control)));

R.Assign(14, 4, 31, 5);
Control := New(PInputLine, Init(R, 15));
{Control^.Options := Control^.Options and not ofSelectable;}
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 4, 14, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~Л~имит долга:', Control)));

R.Assign(14, 5, 61, 6);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(7, 5, 14, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Адре~с~:', Control)));

R.Assign(14, 6, 61, 7);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(5, 6, 14, 7);
  Dlg^.Insert(New(PLabel, Init(R, '~Т~елефон:', Control)));

R.Assign(14, 7, 61, 8);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(6, 7, 14, 8);
  Dlg^.Insert(New(PLabel, Init(R, '~Р~/счет:', Control)));

R.Assign(14, 8, 61, 9);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(11, 8, 14, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'в:', Control)));

R.Assign(14, 9, 61, 10);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(7, 9, 14, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Город:', Control)));

R.Assign(14, 10, 61, 11);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(9, 10, 14, 11);
  Dlg^.Insert(New(PLabel, Init(R, '~И~НН:', Control)));

R.Assign(14, 11, 61, 12);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(7, 11, 14, 12);
  Dlg^.Insert(New(PLabel, Init(R, 'О~К~ОНХ:', Control)));

R.Assign(14, 12, 61, 13);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(8, 12, 14, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'ОК~П~О:', Control)));

R.Assign(14, 13, 61, 14);
Control := New(PInputLine, Init(R, 45));
Dlg^.Insert(Control);

  R.Assign(4, 13, 14, 14);
  Dlg^.Insert(New(PLabel, Init(R, 'Ли~ц~ензия:', Control)));


R.Assign(14, 14, 61, 15);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(3, 14, 14, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Сооб~щ~ение:', Control)));


R.Assign(12, 15, 33, 16);
Control := New(PCheckboxes, Init(R,
  NewSItem('Ра~з~решить дебит', Nil)));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

R.Assign(12, 16, 33, 17);
Control := New(PCheckboxes, Init(R,
  NewSItem('От~к~лючить лимит', Nil)));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);


R.Assign(51, 15, 61, 16);
Control := New(PInputLine, Init(R, 8));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));

  R.Assign(33, 15, 51, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'Срок ли~ц~ензии до:', Control)));

R.Assign(51, 16, 61, 17);
Control := New(PInputLine, Init(R, CArtikul));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(33, 16, 51, 17);
  Dlg^.Insert(New(PLabel, Init(R, 'Периодичность:', Control)));


Dlg^.SetData(AgentElement);


If Cod = kbGrayPlus  Then
Begin
 R.Assign(61, 18, 62, 22);
 Control := New(PScrollBar, Init(R));
 Dlg^.Insert(Control);
 R.Assign(1, 18, 61, 22);
 ClientNum := New(PBox, Init(R, 9, PScrollbar(Control)));
 ClientNum^.NewList(New(PTextCollection, Init(0,1)));

Assign(AgentFile,Path.ToClient+'Agent.db');
Reset (AgentFile);
 While Not(Eof(AgentFile)) Do
  Begin
   ReadClient(AgentFile,AgentElement);
   If Not(AgentElement.Employ) Then
   Begin
   Format (AgentElement.Name,CClient);
   ClientNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+AgentElement.Kod));
   ClientNum^.SetRange(ClientNum^.List^.Count);
   ClientNum^.FocusItem(ClientNum^.List^.Count);
   End;
  End;
 System.Close(AgentFile);
 If Cod=kbF4 Then ClientNum^.FocusItem(LoCation(ClientNum,s,ProdagaWindow))
 Else ClientNum^.FocusItem(0);

 Dlg^.Insert(ClientNum);
 ClientNum^.HelpCtx:=$E011;

  R.Assign(1, 17, 37, 18);
  Dlg^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', ClientNum)));
  Dlg^.Insert(Control);
 End;
If Cod=kbF4 Then
 Begin
  R.Assign(52, 1, 57, 2);
  Control := New(PColoredText, Init(R, 'Код:', $3E));
  Dlg^.Insert(Control);
  R.Assign(57, 1, 61, 2);
  Control := New(PColoredText, Init(R, AgentElement.Kod,$3E));
  Dlg^.Insert(Control);
 End;

Dlg^.SelectNext(False);
NoInfo;
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
    Dlg^.GetData(AgentElement);
    DelSpaceRight(AgentElement.Name);
    DelSpaceRight(AgentElement.Messages);
    DelSpace(AgentElement.SrokLizensia);


    If AgentElement.Name[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое имя агента!',nil,mfError+mfCancelButton);
If Cod=kbGrayPlus Then
  Begin
   s:=ClientNum^.GetText(ClientNum^.Focused,ClientNum^.List^.Count);
   s:=Copy(s,1+CClient+1,CClientKod);
  ClientNum^.NewList(Nil);
  Dispose(ClientNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
    Goto 1;
   End;

  C:=IOResult;

If Cod=kbGrayPlus Then
  Begin
   s:=ClientNum^.GetText(ClientNum^.Focused,ClientNum^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If Cod=kbGrayPlus Then
  Begin
   If Not(TestEmployAgentAndLock(s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать агента с кодом '+s+'... Попробуйте изменить код!');
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(ClientNum,Done);
     Dispose(Control,Done);
     Dispose(Dlg,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(AgentElement.Name);
   UpStr(AgentElement.Adress);
   UpStr(AgentElement.INN);
   UpStr(AgentElement.R_Sh);
   UpStr(AgentElement.Gde);
   UpStr(AgentElement.Gorod);
   UpStr(AgentElement.Okonh);
   UpStr(AgentElement.Okpo);
   UpStr(AgentElement.Enviropment);
   UpStr(AgentElement.Telefon);
   AgentElement.Employ:=True;
   AgentElement.Stat:=False;
   AgentElement.Locked:=True;
   AgentElement.LockTime :=False;

   If Cod=kbGrayPlus Then AgentElement.Kod:=s;

  {если не удалось записать информацию}
  If Not (WriteLockAgent(AgentElement)) Then
    Begin
     If Cod=kbGrayPlus Then Dispose(ClientNum,Done);
     Dispose(Control,Done);
     Dispose(Dlg,Done);
     Repeat
     Until (SetAgentUnLock(s));
     Goto 1;
    End;

  If Cod=kbGrayPlus Then
  Begin
   AddProtocol('Добавление нового агента:'+AgentElement.Name+' ('+s+')','','');
   Repeat
   Until (SetAgentUnLock(s));
  End
  Else
   AddProtocol('Корректировка данных агента:'+AgentElement.Name+' ('+AgentElement.Kod+')','','');
  AddAgent:=True;

 End;

If Cod=kbGrayPlus Then
  Begin
  ClientNum^.NewList(Nil);
  Dispose(ClientNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);

  PrevAgent[0]:=#0;
end;




Function AddOperation1( Cod:Integer; Var OperationElement:KassaOperation):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c,sta: Word;
  Full : Boolean;
  k : LongInt;
{  l : Boolean;}
  Event:TEvent;
begin
ClearFind;

sta:=OperationElement.Status;

If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    AddOperation1:=False;
    Exit;
   End;

C:=IOResult;
AddOperation1:=False;
Full:=True;

Assign(OperationFile,Path.ToClient+'kassa.db');

Reset(OperationFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу кассовых операции!',nil,mfError+mfCancelButton);
 AddOperation1:=False;
 Exit;
End;

AInfo('Читаю списки...');
 Case Cod Of
  kbGrayPlus:Begin
     OperationElement.Employ:=True;
     While Not(Eof(OperationFile)) And (OperationElement.Employ) Do
     begin
      ReadOperation(OperationFile,OperationElement);
     end;


     If Eof(OperationFile) And (OperationElement.Employ) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Свободных позиций для оперций - нет!',nil,mfWarning+mfCancelButton);
       System.Close(OperationFile);
       AddOperation1:=False;
       Exit;
      End;
      s:=OperationElement.Kod;
      OperationElement.Name[0]       :=#0;
      OperationElement.Status   :=sta;
      OperationElement.Employ   :=False;
      OperationElement.Locked        :=True;
    End;
  kbF4:Begin
     s:=Copy(OperationList^.GetText(OperationList^.Focused,OperationList^.List^.Count),1+CClient+1,CClientKod);
     Seek(OperationFile,StrToInt(s));
     Repeat
      ReadOperation(OperationFile,OperationElement);
     Until (Eof(OperationFile)) Or (OperationElement.Kod=s);

     If Eof(OperationFile) And (OperationElement.Kod<>s) Then
      Begin
       NoInfo;
       MessageBox(#3^M+#3'Операция в базе не найден!',nil,mfError+mfCancelButton);
       System.Close(OperationFile);
       AddOperation1:=False;
       Exit;
      End;
    End;
  Else;
 End;
System.Close(OperationFile);

1:
If Cod=kbGrayPlus Then
Begin
R.Assign(11, 7, 68, 16);
New(Dlg, Init(R, 'Добавить операцию'));
End
Else
Begin
R.Assign(11, 7, 68, 12);
New(Dlg, Init(R, 'Изменить операцию'));
End;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E011;

R.Assign(2, 2, 24, 3);
Control := New(PInputLine, Init(R, 20));
Dlg^.Insert(Control);

  R.Assign(1, 1, 24, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~Н~аименование операции:', Control)));


R.Assign(25, 2, 54, 3);
Control := New(PRadioButtons, Init(R,
  NewSItem('~Р~асход',
  NewSItem('~П~оступления',
  Nil))));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);


  R.Assign(24, 1, 38, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Вид операции:', Control)));

Dlg^.SetData(OperationElement);

If Cod = kbGrayPlus  Then
Begin
 R.Assign(56, 4, 57, 8);
 Control := New(PScrollBar, Init(R));
 Dlg^.Insert(Control);

 R.Assign(1, 4, 56, 8);
 OperationNum := New(PBox, Init(R, 9, PScrollbar(Control)));
 OperationNum^.NewList(New(PTextCollection, Init(0,1)));

Assign(OperationFile,Path.ToClient+'Kassa.db');
Reset (OperationFile);
 While Not(Eof(OperationFile)) Do
  Begin
   ReadOperation(OperationFile,OperationElement);
   If Not(OperationElement.Employ) Then
   Begin
   Format (OperationElement.Name,CClient);
   OperationNum^.List^.Insert(NewStr({MakeListElement.Name+}'│'+OperationElement.Kod));
   OperationNum^.SetRange(OperationNum^.List^.Count);
   OperationNum^.FocusItem(OperationNum^.List^.Count);
   End;
  End;
 System.Close(OperationFile);
 If Cod=kbF4 Then OperationNum^.FocusItem(LoCation(OperationNum,s,ProdagaWindow))
 Else OperationNum^.FocusItem(0);

 Dlg^.Insert(OperationNum);
 OperationNum^.HelpCtx:=$E011;

  R.Assign(1, 16, 37, 17);
  Dlg^.Insert(New(PLabel, Init(R, '~Д~оступные коды:', OperationNum)));
  Dlg^.Insert(Control);
 End;



If Cod=kbF4 Then
 Begin
  R.Assign(48, 1, 52, 2);
  Control := New(PColoredText, Init(R, 'Код:', $3E));
  Dlg^.Insert(Control);
  R.Assign(52, 1, 56, 2);
  Control := New(PColoredText, Init(R, OperationElement.Kod,$3E));
  Dlg^.Insert(Control);
 End;



Dlg^.SelectNext(False);
NoInfo;
c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
    Dlg^.GetData(OperationElement);
    DelSpaceRight(OperationElement.Name);

    If OperationElement.Name[0]=#0 Then
   Begin
    MessageBox(^M+#3'Недопустимое наименование операции!',nil,mfError+mfCancelButton);
If Cod=kbGrayPlus Then
  Begin
   s:=OperationNum^.GetText(OperationNum^.Focused,OperationNum^.List^.Count);
   s:=Copy(s,1+CClient+1,CClientKod);
  OperationNum^.NewList(Nil);
  Dispose(OperationNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
    Goto 1;
   End;

  C:=IOResult;

If Cod=kbGrayPlus Then
  Begin
   s:=OperationNum^.GetText(OperationNum^.Focused,OperationNum^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
  end;

  {Если добавляем нового клиента то блокируем выбранный код}
  If Cod=kbGrayPlus Then
  Begin
   If Not(TestEmployKassaAndLock(s)) Then
    Begin
     Beep;
     DInfoMsg('Не могу заблокировать операцию с кодом '+s+'... Попробуйте изменить код!');
     Application^.ClearEvent(Event);
     Application^.ClearEvent(Event);
      repeat
       Application^.GetEvent(Event);
      until (Event.What <> evNothing);
     NoInfoMsg;
     Application^.ClearEvent(Event);
     Dispose(OperationNum,Done);
     Dispose(Control,Done);
     Dispose(Dlg,Done);
     Goto 1;
    End;
  End;

  {исходим из того что блокировка удалась}

   UpStr(OperationElement.Name);
   OperationElement.Employ:=True;
   OperationElement.Locked:=True;

   If Cod=kbGrayPlus Then OperationElement.Kod:=s;

  {если не удалось записать информацию}
  If Not (WriteLockKassa(OperationElement)) Then
    Begin
     If Cod=kbGrayPlus Then Dispose(OperationNum,Done);
     Dispose(Control,Done);
     Dispose(Dlg,Done);
     Repeat
     Until (SetKassaUnLock(s));
     Goto 1;
    End;

  If Cod=kbGrayPlus Then
  Begin
   AddProtocol('Добавление новой кассовой операции:'+OperationElement.Name+' ('+s+')','','');
   Repeat
   Until (SetKassaUnLock(s));
  End
  Else
   AddProtocol('Корректировка кассовой операции:'+OperationElement.Name+' ('+OperationElement.Kod+')','','');
  AddOperation1:=True;

 End;

If Cod=kbGrayPlus Then
  Begin
  OperationNum^.NewList(Nil);
  Dispose(OperationNum,Done);
  End;
  Dispose(Control,Done);
  Dispose(Dlg,Done);

  PrevAgent[0]:=#0;

end;



Function Viewagent(Art:ArtikulStr):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  s : TEnjoyStr;{!!!}
  j,c: Word;
  Full : Boolean;
  k : LongInt;
  Event:TEvent;
begin
{$Ifdef DPMI}
ClearFind;

C:=IOResult;
ViewAgent:=False;

Assign(AgentFile,Path.ToClient+'Agent.db');
Reset(AgentFile);
C:=IOResult;
If C<>0 Then
Begin
 MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов!',nil,mfError+mfCancelButton);
 ViewAgent:=False;
 Exit;
End;

AInfo('Читаю списки...');

If Art[0]=#0 Then
s:=Copy(Client^.GetText(Client^.Focused,Client^.List^.Count),1+CClient+1,CClientKod)
Else
s:=Art;
DelSpace(Art);

Seek(AgentFile,StrToInt(S));

ReadClient(AgentFile,AgentElement);

If (AgentElement.Kod<>s) Then
   Begin
    NoInfo;
    MessageBox(#3^M+#3'Агент в базе не найден!',nil,mfError+mfCancelButton);
    System.Close(AgentFile);
    ViewAgent:=False;
    Exit;
   End;

System.Close(AgentFile);

R.Assign(9, 1, 71, 19);
New(Dlg, Init(R, 'Просмотр агента'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E090;

R.Assign(14, 1, 36, 2);
{Control^.Options := Control^.Options and not ofSelectable;}
Control := New(PInputLine, Init(R, 20));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
{
  R.Assign(36, 1, 39, 2);
  Dlg^.Insert(New(PHistory, Init(R, PInputline(Control), 12)));
}
  R.Assign(6, 1, 14, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Аг~е~нт:', Control)));

R.Assign(14, 2, 61, 3);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(2, 2, 14, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'N д~о~говора:', Control)));

R.Assign(14, 3, 18, 4);
Control := New(PInputLine, Init(R, 2));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);


  R.Assign(3, 3, 14, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'От~д~еление:', Control)));

R.Assign(29, 3, 33, 4);
Control := New(PInputLine, Init(R, 2));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(20, 3, 29, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'П~а~латки:', Control)));

R.Assign(44, 3, 48, 4);
Control := New(PInputLine, Init(R, 2));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(34, 3, 44, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Ма~г~азины:', Control)));

R.Assign(55, 3, 59, 4);
Control := New(PInputLine, Init(R, 2));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(49, 3, 55, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Ка~ф~е:', Control)));

R.Assign(14, 4, 31, 5);
Control := New(PInputLine, Init(R, 15));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(1, 4, 14, 5);
  Dlg^.Insert(New(PLabel, Init(R, '~Л~имит долга:', Control)));
R.Assign(14, 5, 61, 6);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(7, 5, 14, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Адре~с~:', Control)));

R.Assign(14, 6, 61, 7);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(5, 6, 14, 7);
  Dlg^.Insert(New(PLabel, Init(R, '~Т~елефон:', Control)));

R.Assign(14, 7, 61, 8);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(6, 7, 14, 8);
  Dlg^.Insert(New(PLabel, Init(R, '~Р~/счет:', Control)));

R.Assign(14, 8, 61, 9);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(11, 8, 14, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'в:', Control)));

R.Assign(14, 9, 61, 10);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(7, 9, 14, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Город:', Control)));

R.Assign(14, 10, 61, 11);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(9, 10, 14, 11);
  Dlg^.Insert(New(PLabel, Init(R, '~И~НН:', Control)));

R.Assign(14, 11, 61, 12);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(7, 11, 14, 12);
  Dlg^.Insert(New(PLabel, Init(R, 'О~К~ОНХ:', Control)));

R.Assign(14, 12, 61, 13);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(8, 12, 14, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'ОК~П~О:', Control)));

R.Assign(14, 13, 61, 14);
Control := New(PInputLine, Init(R, 45));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(4, 13, 14, 14);
  Dlg^.Insert(New(PLabel, Init(R, 'Ли~ц~ензия:', Control)));


R.Assign(14, 14, 61, 15);
Control := New(PInputLine, Init(R, CSertif));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(3, 14, 14, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Сооб~щ~ение:', Control)));


R.Assign(12, 15, 33, 16);
Control := New(PCheckboxes, Init(R,
  NewSItem('Ра~з~решить дебит', Nil)));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

R.Assign(12, 16, 33, 17);
Control := New(PCheckboxes, Init(R,
  NewSItem('От~к~лючить лимит', Nil)));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);


R.Assign(51, 15, 61, 16);
Control := New(PInputLine, Init(R, 8));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);

  R.Assign(33, 15, 51, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'Срок ли~ц~ензии до:', Control)));

R.Assign(51, 16, 61, 17);
Control := New(PInputLine, Init(R, CArtikul));
Control^.Options := Control^.Options and not ofSelectable;
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(33, 16, 51, 17);
  Dlg^.Insert(New(PLabel, Init(R, 'Периодичность:', Control)));



Dlg^.SetData(AgentElement);


  R.Assign(52, 1, 57, 2);
  Control := New(PColoredText, Init(R, 'Код:', $3E));
  Dlg^.Insert(Control);
  R.Assign(57, 1, 61, 2);
  Control := New(PColoredText, Init(R, AgentElement.Kod,$3E));
  Dlg^.Insert(Control);

Dlg^.SelectNext(False);
NoInfo;

c:=Desktop^.ExecView(Dlg);
Dispose(Control,Done);
Dispose(Dlg,Done);
PrevAgent[0]:=#0;
{$ENDIF}
end;


Procedure TAgentWindow.ShowAgentList(Var st:AllStr;Var Res: Word);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c: Word;
begin
ClearFind;
AInfo('Читаю списки...');

Res:=0;
R.Assign(13, 3, 68, 20);
New(AgentWindow, Init(R, 'Выбор агента'));

R.Assign(54, 1 ,55, 16);
Control := New(PScrollBar, Init(R));
AgentWindow^.Insert(Control);

R.Assign(1, 1, 54, 16);
Client := New(PBox, Init(R, 2, PScrollbar(Control)));
Client^.NewList(New(PTextCollection, Init(0,1)));
Assign (AgentFile,Path.ToClient+'Agent.db');
c:=IOResult;
Reset (AgentFile);
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(AgentFile)) Do
 Begin
     ReadClient(AgentFile,AgentElement);
  If AgentElement.Employ Then
   Begin
    Format (AgentElement.Name,CClient);
    Client^.List^.Insert(NewStr(AgentElement.Name+'│'+AgentElement.Kod));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(AgentFile);
End
Else
 Begin
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
s:=Copy(st,1+CClient+1,CClientKod);
Client^.FocusItem(Location(Client,S,ProdagaWindow));
Client^.HelpCtx:=$E171;
AgentWindow^.Insert(Client);
PrevAgent:=Copy(Client^.GetText(Client^.Focused,Client^.List^.Count),1+CClient+1,CClientKod);

AgentWindow^.SelectNext(False);
PrevAgent[0]:=#0;
NoInfo;
c:=Desktop^.ExecView(AgentWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   St:=Client^.GetText(Client^.Focused,Client^.List^.Count);
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
begin
ClearFind;
AInfo('Обновляю списки агентов...');
Cod:=Client^.Focused;

     Assign (AgentFile,Path.ToClient+'Agent.db');
     Client^.NewList(Nil);
     Client^.NewList(New(PTextCollection, Init(0,1)));

c:=IOResult;
Reset (AgentFile);
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(AgentFile)) Do
 Begin
  ReadClient(AgentFile,AgentElement);
  If AgentElement.Employ Then
   Begin
    Format (AgentElement.Name,CClient);
    Client^.List^.Insert(NewStr(AgentElement.Name+'│'+AgentElement.Kod));
    Client^.SetRange(Client^.List^.Count);
   End;
 End;
System.Close(AgentFile);
If Cod<>0 Then Dec(Cod);

Client^.FocusItem(Cod);
NoInfo;
End
Else
 Begin
  NoInfo;
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
 Assign(f,Path.ToTemp+'rek.txt');
 c:=IOResult;
 Rewrite(f);
 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка создания файла '+Path.ToTemp+'rek.txt!',Nil,mfError+mfCancelButton);
   Exit;
  End;
   Writeln(f,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'         РЕКВИЗИТЫ АГЕНТА '+GetAgentField(FClient,s)+
   ' ('+s+')'+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
   Writeln(f,Space+Bold[NPrint.Printer]+'       Договор: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetAgentField(FNDogovor,s)+NoItalic[NPrint.Printer]);
   Writeln(f,Space+Bold[NPrint.Printer]+'   Лимит долга: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetAgentField(FLimit,s)+NoItalic[NPrint.Printer]);
   Writeln(f,Space+Bold[NPrint.Printer]+'         Адрес: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetAgentField(FAdress,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'       Телефон: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetAgentField(FTelefon,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'Расчетный счет: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetAgentField(FRSh,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'             в: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetAgentField(FGde,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'         Город: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetAgentField(FGorod,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'           ИНН: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetAgentField(FINN,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'         ОКОНХ: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetAgentField(FOkonh,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'          ОКПО: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetAgentField(FOkpo,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+'      Лицензия: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetAgentField(FEnvir,s)+NoItalic[NPrint.Printer]);;
   Writeln(f,Space+Bold[NPrint.Printer]+' Срок лицензии: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]+
   GetAgentField(FSrok,s)+NoItalic[NPrint.Printer]);;
   Write(f,Space+Bold  [NPrint.Printer]+'   Консигнация: '+NoBold[NPrint.Printer]+Italic[NPrint.Printer]);

   If StrToInt(GetAgentField(FDebit,s))=0 Then
   Writeln(f,'Запрещена!!!'+NoItalic[NPrint.Printer])
   Else
   Writeln(f,'Разрешена'+NoItalic[NPrint.Printer]);

   Writeln(f,Space+'====================================================================');
System.Close(f);
Report(Path.ToTemp+'rek.txt','',1,False,False,false);
End;


procedure TAgentWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;

Function LockSelect:Boolean;
Var s : string[150];
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
    DInfoMsg('Не могу заблокировать агента с кодом '+s+'. Агент отмечен как удаленный!');
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

  If SetAgentLock(s) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать агента с кодом '+s+'. Попробуйте повторить!');
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
  s:=Client^.GetText(Client^.Focused,Client^.List^.Count);
  s:=Copy(s,1+CClient+1,CClientKod);

  r:=False;
  R:=GetAgentEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Нельзя работать с агентом '+s+'. Агент отмечен как удаленный!');
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
Var  f : File Of ClientType;
     cl : ClientType;
     r : Byte;
     cod : ArtikulStr;
Begin
AInfo('Минуточку...');
Assign (F,Path.ToClient+'Agent.db');

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

                 Assign (AgentFile,Path.ToClient+'Agent.db');
                 AgentElement.Name[0]:=#0;
                 AgentElement.Employ:=False;
                 AgentElement.Limit[0]:=#0;
                 AgentElement.Dogovor[0]:=#0;
                 For Test:=1 To CPunkt Do
                 AgentElement.Punkt[Test,0]:=#0;
                 AgentElement.Stat:=False;
                 AgentElement.Adress[0]:=#0;
                 AgentElement.Gorod[0]:=#0;
                 AgentElement.Gde[0]:=#0;
                 AgentElement.INN[0]:=#0;
                 AgentElement.R_Sh[0]:=#0;
                 AgentElement.SrokLizensia[0]:=#0;
                 AgentElement.Debit:=0;
                 AgentElement.Messages[0]:=#0;
                 AgentElement.Kod:=s;
                 AgentElement.Locked:=True;

  If Not (WriteLockAgent(AgentElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлам агентов !',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetAgentUnLock(s));
     ClearEvent(Event);
     Exit;
    End;

    Repeat
    Until (SetAgentUnLock(s));
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


kbAlt1         : UnlockAll;
kbGrayPlus,kbF4:
Begin
L:=False;
If(Client^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(Client^.List<>Nil)And(Client^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
      If AddAgent(Event.KeyCode,AgentElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(Client^.List<>Nil)And(Client^.List^.Count>=1) Then
           Client^.List^.AtFree(Client^.Focused);
        Format(AgentElement.Name,CClient);
        Client^.List^.Insert(NewStr(AgentElement.Name+'│'+AgentElement.Kod));
        Client^.SetRange(Client^.List^.Count);
        Client^.FocusItem(LoCation(Client,AgentElement.Kod,ProdagaWindow));
        Redraw;
       End;
   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=AgentElement.Kod;
    Repeat
    Until (SetAgentUnLock(Cod));
   End;
            ClearEvent(Event);
            Redraw;
            End;
kbF3: Begin
     L:=False;
     ViewAgent('');
     ClearEvent(Event);
     Redraw;
      End;

      Else;
      End;{KeyDown}
evCommand:
 Case Event.Command Of
 cmRefresh: Refresh;
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


Procedure TOperationWindow.ShowOperationList(Var st:AllStr;Var Res: Word; dolg: boolean);
Label 1;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c: Word;
begin
ClearFind;
AInfo('Читаю списки...');

Res:=0;

R.Assign(0, 3, 80, 19);
New(OperationWindow, Init(R, 'Выбор вида операции'));

R.Assign(80, 2, 81, 22);
Control := New(PScrollBar, Init(R));
OperationWindow^.Insert(Control);

R.Assign(0, 1, 80, 15);
OperationList := New(PBox, Init(R, 3, PScrollbar(Control)));
OperationList^.NewList(New(PTextCollection, Init(0,1)));
Assign (OperationFile,Path.ToClient+'kassa.db');
c:=IOResult;
Reset (OperationFile);
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(OperationFile)) Do
 Begin
     ReadOperation(OperationFile,OperationElement);
  If OperationElement.Employ Then
  if ((OperationElement.Status=0) and not dolg)
     or ((OperationElement.Status=1) and dolg) then
   Begin
    Format (OperationElement.Name,CClient);
    OperationList^.List^.Insert(NewStr(OperationElement.Name+'│'+OperationElement.Kod));
    OperationList^.SetRange(OperationList^.List^.Count);
   End;
 End;
System.Close(OperationFile);
End
Else
 Begin
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Goto 1;
 End;
s:=Copy(st,1+CClient+1,CClientKod);
OperationList^.FocusItem(Location(OperationList,S,ProdagaWindow));
OperationList^.HelpCtx:=$E171;
OperationWindow^.Insert(OperationList);

PrevAgent:=Copy(OperationList^.GetText(OperationList^.Focused,OperationList^.List^.Count),1+CClient+1,CClientKod);

OperationWindow^.SelectNext(False);
PrevAgent[0]:=#0;
NoInfo;

c:=Desktop^.ExecView(OperationWindow);
If c<>CmCancel Then
   If c=CmOk Then Res:=2;
   If c=CmYes Then Res:=3;
   If c=CmCancel Then Res:=1;
   St:=OperationList^.GetText(OperationList^.Focused,OperationList^.List^.Count);

1:
Dispose(COntrol,Done);
Dispose(OperationWindow,Done);
end;




Procedure TOperationWindow.Refresh;
var
  R : TRect;
  Control : PView;
  s : String[CSertif];

  c,Cod: Word;
begin
ClearFind;
AInfo('Обновляю списки кассовых операции...');
Cod:=OperationList^.Focused;

     Assign (OperationFile,Path.ToClient+'kassa.db');
     OperationList^.NewList(Nil);
     OperationList^.NewList(New(PTextCollection, Init(0,1)));

c:=IOResult;
Reset (OperationFile);
c:=IOResult;
If c=0 Then
Begin
While Not(Eof(OperationFile)) Do
 Begin
  ReadOperation(OperationFile,OperationElement);
  If OperationElement.Employ Then
   Begin
    Format (OperationElement.Name,CClient);
    OperationList^.List^.Insert(NewStr(OperationElement.Name+'│'+OperationElement.Kod));
    OperationList^.SetRange(OperationList^.List^.Count);
   End;
 End;
System.Close(OperationFile);

If Cod<>0 Then Dec(Cod);

OperationList^.FocusItem(Cod);
NoInfo;
End
Else
 Begin
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
Redraw;
PrevAgent[0]:=#0;
end;

Destructor TOperationWindow.Done;
Begin
ClearFind;
Dispose(OperationList,Done);
TDialog.Done;
End;

procedure TOperationWindow.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;

Function LockSelect:Boolean;
Var s : string[150];
    Event : TEvent;
    R : Boolean;
Begin
  LockSelect:=False;
  s:=OperationList^.GetText(OperationList^.Focused,OperationLiSt^.List^.Count);
  s:=Copy(s,1+CClient+1,CClientKod);

  R:=GetKassaEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать операцию с кодом '+s+'. Операция отмечена как удаленная!');
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

  If SetKassaOperationLock(s) Then LockSelect:=True
  Else
   Begin
    Beep;
    DInfoMsg('Не могу заблокировать операцию с кодом '+s+'. Попробуйте повторить!');
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
  s:=OperationList^.GetText(OperationList^.Focused,OperationList^.List^.Count);
  s:=Copy(s,1+CClient+1,CClientKod);

  r:=False;
  R:=GetKAssaEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Нельзя работать с операцией '+s+'. Операция отмечена как удаленная!');
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
Var  f : File Of KassaOperation;
     cl : KassaOperation;
     r : Byte;
     cod : ArtikulStr;
Begin
AInfo('Минуточку...');
Assign (F,Path.ToClient+'kassa.db');

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
End;



begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbDel:
     if (User[90]) or
               ((StrToInt(CurrentPassword)=0)) then
	Begin
If Not(TestOpenDate1(FDate)) Then
   Begin
    MessageBox(#3^M+#3'Доступ к данным за '+FDate+' заблокирован!',Nil,mfError+mfCancelButton);
    ClearEvent(Event);
    Exit;
   End;
     L:=False;
     If (OperationList^.State and sfFocused <> 0) And (OperationList^.List<>Nil)And(OperationList^.List^.Count>=2) Then
        L:=True;

     If L Then
            Begin
     If Password(3) Then
             Begin
             s:=#3^M+#3'Желаете удалить запись?';
             If MessageBox(s,nil,mfConfirmation+mfOkCancel)=cmOk
              Then
              Begin
                s:=OperationList^.GetText(OperationList^.Focused,OperationList^.List^.Count);
                s:=Copy(s,1+CClient+1,CClientKod);

              {сетевая блокировка}
               If Not(LockSelect) Then
                Begin
                 ClearEvent(Event);
                 Redraw;
                 Exit;
                End;

                 test := IOResult;
                 s:=OperationList^.GetText(OperationList^.Focused,OperationList^.List^.Count);
                 s:=Copy(s,1+CClient+1,CClientKod);

                 Assign (OperationFile,Path.ToClient+'KAssa.db');
                 OperationElement.Name[0]:=#0;
                 OperationElement.Employ:=False;
                 OperationElement.Kod:=s;
                 OperationElement.Status:=0;
                 OperationElement.Locked:=True;

  If Not (WriteLockKAssaOperation(OperationElement)) Then
    Begin
     MessageBox(^M+#3'Ошибка доступа к файлам кассовых операций !',nil,mfError+mfCanCelButton);
     Repeat
     Until (SetKassaOperationUnLock(s));
     ClearEvent(Event);
     Exit;
    End;

    Repeat
    Until (SetKassaOperationUnLock(s));
    AddProtoCol('Удаление кассовой операции:'+s,'','');
    OperationList^.List^.AtFree(OperationList^.Focused);
    OperationList^.SetRange(OperationList^.List^.Count);
    If OperationList^.Focused>0 Then   OperationList^.FocusItem(OperationList^.Focused);
    If (OperationList^.Focused>=OperationList^.List^.Count) and(OperationList^.Focused>0) Then
    OperationList^.FocusItem(OperationList^.Focused-1);
    ClearEvent(Event);
    Redraw;
            End;
           End;
          End;
          End;


kbAlt1         : UnlockAll;
kbGrayPlus,kbF4:
if (User[91]) or
               ((StrToInt(CurrentPassword)=0)) then
Begin
L:=False;
If(OperationList^.State and sfFocused <> 0)And(Not(Event.KeyCode=kbF4))Or
((Event.KeyCode=kbF4)And(OperationList^.List<>Nil)And(OperationList^.List^.Count>=1)) Then l:=True;
 If L Then
   Begin
    If Event.KeyCode=kbF4 Then
      If Not(LockSelect) Then
       Begin
        ClearEvent(Event);
        Exit;
       End;
      s:=OperationList^.GetText(OperationList^.Focused,OperationLiSt^.List^.Count);
      s:=Copy(s,1+CClient+1,CClientKod);

      OperationElement.Status:=StrToInt(GetOperationField(FStatus,s));

      If AddOperation1(Event.KeyCode,OperationElement) Then
       Begin
        If (Event.KeyCode=kbF4)And(OperationList^.List<>Nil)And(OperationList^.List^.Count>=1) Then
           OperationList^.List^.AtFree(OperationList^.Focused);
        Format(OperationElement.Name,CClient);
        OperationList^.List^.Insert(NewStr(OperationElement.Name+'│'+OperationElement.Kod));
        OperationList^.SetRange(OperationList^.List^.Count);
        OperationList^.FocusItem(LoCation(OperationList,OperationElement.Kod,ProdagaWindow));
        Redraw;
       End;
   End;
 If Event.KeyCode=kbF4 Then
   Begin
    Cod:=OperationElement.Kod;
    Repeat
    Until (SetKassaOperationUnLock(Cod));
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

 if (Event.What = evBroadcast) and (Event.Command = cmSelectKAssa) then ClearEvent(Event);


  inherited HandleEvent(Event);

  ClearEvent(Event);
end;



Begin
End.