{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


Unit Net;

Interface

Uses ServStr,Dialogs,Glob;

Const
       GroupSize={1}SizeOf(GroupType);
       BufGroupSize={1}SizeOf(BufGroupType);


{процедуры разделение доступа к клиентам}
Function SetClientLock(c:ArtikulStr;VidOperator,Ext:Byte):Boolean;
Function SetClientUnLock(c:ArtikulStr;VidOperator,Ext:Byte):Boolean;
Function SetLockNearClient({P:PBox;}VidOperator,Ext:Byte;Var Cod:ArtikulStr):Boolean;
Function WriteLockClient(VidOperator,Ext:Byte;ClientElement:ClientType):Boolean;
Function TestEmployClientAndLock(VidOperator,Ext:Byte;TestCod:ArtikulStr):Boolean;

{процедуры разделение доступа к агентам}
Function SetAgentLock(c:ArtikulStr):Boolean;
Function SetAgentUnLock(c:ArtikulStr):Boolean;
Function WriteLockAgent(ClientElement:ClientType):Boolean;
Function TestEmployAgentAndLock(TestCod:ArtikulStr):Boolean;


Function SetKassaOperationLock(c:ArtikulStr):Boolean;
Function WriteLockKassaOperation(ClientElement:KassaOperation):Boolean;
Function SetKassaOperationUnLock(c:ArtikulStr):Boolean;
Function TestEmployKassaAndLock(TestCod:ArtikulStr):Boolean;
Function WriteLockKassa(ClientElement:KassaOperation):Boolean;
Function SetKassaUnLock(c:ArtikulStr):Boolean;
Function LockAndWriteKassa( Var L:PItogKassa;var Doc: ArtikulStr) : Boolean;
Function LockAndWriteKassaAs(As:DocumentEdit;Var L:PItogKassa) : Boolean;
Function LockAndWriteLizoKassa( Var L:PDolgKassa;Lizo:ArtikulStr) : Boolean;

Procedure LockUnlockNalog(c:ArtikulStr;LockRegim:Word);

{процедуры разделения доступа к позициям товара}
Function SetNameLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Function SetNameUnLock(c:ArtikulStr):Boolean;
Function WriteLockName(Element:BazType;SkladElement:SkladType):Boolean;
Function TestEmployNameAndLock(TestCod:ArtikulStr;Var Operator:StrNAme):Boolean;

Function LockAndWriteTransport(var L:PTransportType):Boolean;


{процедуры сетевой работы с документами прихода}
Function LockAndWritePrihod(var L:PPrihodType;Mode:Boolean):Boolean;
Function LockPrihod(As : DocumentEdit;Var E:PPrihodType):Word;
Function FindFantom(E:PPrihodType;VAr FantomBox:PBox):Boolean;
Function UnLockPrihod(Doc:ArtikulStr;DD: TDateString):Word;

{процедуры сетевой работы с документами возврата}
Function LockAndWriteReturn(var L:PNewVozwratType;Mode:Boolean):Boolean;
Function LockReturn(As : DocumentEdit;Var E:PNewVozwratType):Word;
Function UnLockReturn(Doc:ArtikulStr;DD: TDateString):Word;

{процедуры сетевой работы с документами продажи}
Function LockAndWriteMarket(var L:PSuperMArketType):Boolean;
Function LockMArket(As : DocumentEdit;Var E:PSuperMarketType):Word;
Function UnLockMArket(Doc:ArtikulStr;DD: TDateString):Word;
Function Activ_DeActiv_Market(Doc:ArtikulStr;DD: TDateString;Mode:Boolean):Boolean;

{процедуры сетевой работы с документами переоценки}
Function LockAndWritePereozenka(var L:PPereozenkaType):Boolean;

{процедуры сетевой работы с документами ревизии}
Function LockAndWriteRewisia(var L:PRewisiaType):Boolean;
Function LockRewisia(As : DocumentEdit;Var E:PRewisiaType):Word;
Function UnLockRewisia(Doc:ArtikulStr;DD: TDateString):Word;
Function LockAndWriteRewisiaOutEdit(Var L:PRewisiaType):Boolean;

{специально для окна продаж}
Function LockAllPosition(Var TempBox,LockBox:PBox):Boolean;
Procedure UnLockAllPosition(LockBox:PBox);
Function SaveRealizasToClientFile(E:PSuperMarketType;sf:Boolean;Realiz: boolean):Boolean;
Function TestDolgClient (S:ArtikulStr):Boolean;
Function TestDolgClientNew1 (S:ArtikulStr):Boolean;
function ReturnDay (i:Real;L:Boolean) : LongInt;


Function SaveToBarterRashodFile(L:PSuperMarketType):Boolean;
Function SaveToBarterPrihodFile(L:PPrihodType):Boolean;
Function DeleteRashodOfBarterFile(PrevMarket:PSuperMarketType):Boolean;
Function DeletePrihodOfBarterFile(PrevPrihod:PPrihodType):Boolean;
Function SaveToBarterOplataFile(L:PBarterClientType):Boolean;
Function SaveOplataBarterToToDayFile(Var L:POplataBarter):Boolean;

Function  DelNameFromDB(s:ArtikulStr):Boolean;
Function  TestSF(Cl:ArtikulStr;Num:ArtikulStr;Date:TDateString):Boolean;
Function  TestPayment(Cl:ArtikulStr;Num:ArtikulStr;Date:TDateString):Boolean;


Procedure SetupPeriodLockAllTemp(REg,Sel:Word);
Procedure SetupProzAll(REg,Sel:Word);


Procedure ReadGroup(Var F : GroupFileType;Var Element:GroupType );
Procedure ReadBufGroup(Var F : File; Var Element:PBufGroupType;Var Count:Word);

{процедуры разделение доступа к группам}
Function SetGroupLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Function SetGroupUnLock(c:ArtikulStr):Boolean;
Function WriteLockGroup(ClientElement:GroupType):Boolean;
Function TestEmployGroupAndLock(TestCod:ArtikulStr):Boolean;


Procedure ReadRewGroup(Var F : GroupFileType;Var Element:GroupType );
Procedure ReadRewBufGroup(Var F : File; Var Element:PBufGroupType;Var Count:Word);

{процедуры разделение доступа к группам}
Function SetRewGroupLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Function SetRewGroupUnLock(c:ArtikulStr):Boolean;
Function WriteRewLockGroup(ClientElement:GroupType):Boolean;
Function TestRewEmployGroupAndLock(TestCod:ArtikulStr):Boolean;

Implementation

Uses Serv,MsgBox,NetCall,Dos,DbEngine,Views,Protect,Access,NetDbEng,
     Drivers,App,Objects,TpDate,inplong,ColorTxt,Utils,Validate;

{
1 открыть файл клиентов
2 заблокировать предварительной блокировкой запись

3 прочитать клиента
4 просмотреть его поле Lock
  Если Lock Истина тогда позиция занята и надо снять предварительную
  блокировку установленную пунктом 2,
  иначе проводим окончательную блокировку клиента, устанавливая Lock=False
}

Function SetAgentLock(c:ArtikulStr):Boolean;
Var f : File of ClientType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Блокирую агента с кодом '+c);
 SetAgentLock:=False;
 Assign (F,Path.ToClient+'agent.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла агентов!',nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetAgentLock:=True;
      Exit;
  End;
End;



{
1 открыть файл клиентов
2 заблокировать предварительной блокировкой запись
  заблокировать надо обязательно успешно

3 прочитать клиента
4 просмотреть его поле Lock
  Если Lock Истина тогда позиция занята и надо снять предварительную
  блокировку установленную пунктом 2,
  иначе проводим окончательную блокировку клиента, устанавливая Lock=False
}

Function SetKassaOperationLock(c:ArtikulStr):Boolean;
Var f : File of KassaOperation;
    l : LongInt;
    Code : Integer;
    s : KassaOperation;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Блокирую кассовую операцию с кодом '+c);
 SetKassaOperationLock:=False;
 Assign (F,Path.ToClient+'kassa.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла кассовых операций!',nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetKassaOperationLock:=True;
      Exit;
  End;
End;




Function SetClientLock(c:ArtikulStr;VidOperator,Ext:Byte):Boolean;
Var f : File of ClientType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Блокирую клиента с кодом '+c);
 SetClientLock:=False;
Case VidOperator Of
0:Begin
 {If Ext = 0 Then Assign (F,Path.ToClient+'Client.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}

  Case Ext Of
  0:Assign (F,Path.ToClient+'Client.db');
  1:Assign (F,Path.ToClient+'Sklad.db');
  2:Assign (F,Path.ToClient+'Barter.db');
  Else;
  End;

  End;
1:Begin
  {If Ext = 0 Then Assign (F,Path.ToClient+'Make.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}

  Case Ext Of
  0:Assign (F,Path.ToClient+'Make.db');
  1:Assign (F,Path.ToClient+'Sklad.db');
  2:Assign (F,Path.ToClient+'Barter.db');
  Else;
  End;


  End;
Else;
End;

 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла клиентов!',nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetClientLock:=True;
      Exit;
  End;
End;

{
1 открыть файл клиентов
2 заблокировать предварительной блокировкой запись
  заблокировать надо обязательно успешно

3 прочитать клиента
4 просмотреть его поле Lock
  Если Lock Истина тогда позиция занята и надо снять предварительную
  блокировку установленную пунктом 2,
  иначе проводим окончательную блокировку клиента, устанавливая Lock=False
}


Function SetAgentUnLock(c:ArtikulStr):Boolean;
Var f : File of ClientType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую агента с кодом '+c);
 SetAgentUnLock:=False;

 Assign (F,Path.ToClient+'agent.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла агентов!',nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetAgentUnLock:=True;
  End;
End;


Function SetClientUnLock(c:ArtikulStr;VidOperator,Ext:Byte):Boolean;
Var f : File of ClientType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую клиента с кодом '+c);
 SetClientUnLock:=False;

Case VidOperator Of
0:Begin
 {If Ext = 0 Then Assign (F,Path.ToClient+'Client.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}

  Case Ext Of
  0:Assign (F,Path.ToClient+'Client.db');
  1:Assign (F,Path.ToClient+'Sklad.db');
  2:Assign (F,Path.ToClient+'Barter.db');
  Else;
  End;

  End;
1:Begin
  {If Ext = 0 Then Assign (F,Path.ToClient+'Make.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}

  Case Ext Of
  0:Assign (F,Path.ToClient+'Make.db');
  1:Assign (F,Path.ToClient+'Sklad.db');
  2:Assign (F,Path.ToClient+'Barter.db');
  Else;
  End;


  End;
Else;
End;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла клиентов!',nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetClientUnLock:=True;
  End;
End;

Function SetLockNearClient({P:PBox;}VidOperator,Ext:Byte;Var Cod:ArtikulStr):Boolean;
Var f : File of ClientType;
    l : LongInt;
    s : ClientType;
   st : TMyString;
    k,Max : LongInt;
    Op : StrNAme;
Begin
 {MemC(TimeS);}
 DInfoNetMsg('Блокирую ближайшего доступного клиента');
 SetLockNearClient:=False;
 Cod[0]:=#0;
 If (VidOperator=0) And (Ext=0) Then
Begin

 For k:=1 To 5 Do
 Begin
 CAse k Of
 1: St:='0999';
 2: St:='0285';
 3: St:='0286';
 4: St:='0287';
 5: St:='0288';
 Else;
 End;{Case}

 If SetClientLock(st,VidOperator,Ext) Then
   Begin
    SetLockNearClient:=True;
    Cod:=ST;
    Cod[0]:=Chr(CClientKod);
    NoNetInfoMsg;
    {MemC(TimeS);}
    Exit;
   End;
 End;

End;

 Max:=0;
Case VidOperator Of
0:Begin

  Case Ext Of
  0:Assign (F,Path.ToClient+'Client.db');
  1:Assign (F,Path.ToClient+'Sklad.db');
  2:Assign (F,Path.ToClient+'Barter.db');
  Else;
  End;

  End;
1:Begin

  Case Ext Of
  0:Assign (F,Path.ToClient+'Make.db');
  1:Assign (F,Path.ToClient+'Sklad.db');
  2:Assign (F,Path.ToClient+'Barter.db');
  Else;
  End;


  End;
Else;
End;
 k:=IOResult;
 Reset(f);
 k:=IOResult;
 If k<>0 Then Begin
                 NoNetInfoMsg;
                 Exit;
              End;
 Max:=FileSize(f);
 k:=IOResult;
 Close(f);
 k:=IOResult;

 For k:=0 To Max Do
  Begin
   St:=IntToStr(k,CClientKod);
   RFormatZerro(St,CCLientKod);
 If SetClientLock(st,VidOperator,Ext) Then
   Begin
    SetLockNearClient:=True;
    Cod:=ST;
    Cod[0]:=Chr(CClientKod);
    {MemC(TimeS);}
    Exit;
   End;
  End;
End;



Function TestEmployAgentAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of ClientType;
    c : LongInt;
    s : ClientType;
Begin
DInfoNetMsg('Блокирую агента с кодом '+TestCod);
TestEmployAgentAndLock:=False;
Assign (F,Path.ToClient+'agent.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла агентов!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType)); {предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployAgentAndLock:=True;
      Exit;
End;


Function TestEmployClientAndLock(VidOperator,Ext:Byte;TestCod:ArtikulStr):Boolean;
Var f : File Of ClientType;
    c : LongInt;
    s : ClientType;
Begin
DInfoNetMsg('Блокирую клиента с кодом '+TestCod);
TestEmployClientAndLock:=False;
Case VidOperator Of
0:Begin
  {If Ext = 0 Then Assign (F,Path.ToClient+'Client.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}

  Case Ext Of
  0:Assign (F,Path.ToClient+'Client.db');
  1:Assign (F,Path.ToClient+'Sklad.db');
  2:Assign (F,Path.ToClient+'Barter.db');
  Else;
  End;

  End;
1:Begin
  {If Ext = 0 Then Assign (F,Path.ToClient+'Make.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}
  Case Ext Of
  0:Assign (F,Path.ToClient+'Make.db');
  1:Assign (F,Path.ToClient+'Sklad.db');
  2:Assign (F,Path.ToClient+'Barter.db');
  Else;
  End;

  End;
Else;
End;
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла клиентов!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType)); {предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployClientAndLock:=True;
      Exit;
End;


Function WriteLockClient(VidOperator,Ext:Byte;ClientElement:ClientType):Boolean;
Var f : File Of ClientType;
    c : LongInt;
    s : ClientType;
Begin
DInfoNetMsg('Сохраняю информацию о клиенте с кодом '+ClientElement.Kod+'...');
WriteLockClient:=False;
Case VidOperator Of
0:Begin
  {If Ext = 0 Then Assign (F,Path.ToClient+'Client.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}
  Case Ext Of
  0:Assign (F,Path.ToClient+'Client.db');
  1:Assign (F,Path.ToClient+'Sklad.db');
  2:Assign (F,Path.ToClient+'Barter.db');
  Else;
  End;

  End;
1:Begin
  {If Ext = 0 Then Assign (F,Path.ToClient+'Make.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}
  Case Ext Of
  0:Assign (F,Path.ToClient+'Make.db');
  1:Assign (F,Path.ToClient+'Sklad.db');
  2:Assign (F,Path.ToClient+'Barter.db');
  Else;
  End;

  End;
Else;
End;

  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла клиентов!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType)));

{$IFDEF NetVersion}
   ClientElement.Locked:=True;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   WriteLockClient:=True;
End;



Function WriteLockAgent(ClientElement:ClientType):Boolean;
Var f : File Of ClientType;
    c : LongInt;
    s : ClientType;
Begin
DInfoNetMsg('Сохраняю информацию об агенте с кодом '+ClientElement.Kod+'...');
WriteLockagent:=False;
Assign (F,Path.ToClient+'agent.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла агентов!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType)));

{$IFDEF NetVersion}
   ClientElement.Locked:=True;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   WriteLockAgent:=True;
End;




Function SetNameLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of BazType;
    l : LongInt;
    Code : Integer;
     s : BazType;
    st : ArtikulStr;
    Nam : ArtikulStr;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую наименование с кодом '+c);
 SetNameLock:=False;
 NAm :=Copy(c,1,CRazdelKod);
 Assign(f,Path.TOName+Nam+'.id');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла'^M+
  #3+Path.TOName+Nam+'.id ('+INtToStr(l,CLitrMantissa)+')',nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End
 Else
  Begin
   Nam:=Copy(c,1+CRazdelKod,CKod);
   DelSpace(Nam);
   l:=StrToInt(Nam);
   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(BazType),SizeOf(BazType)); {предварительная блокировка}

      Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       Operator:=': '+GetOperatorName(Operator);
       End;
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(BazType),SizeOf(BazType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(BazType),SizeOf(BazType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetNameLock:=True;
      Exit;
(*
    Else   {если не удалась предварительная блокировка}
     Begin
      NoNetInfoMsg;
      Close(f);
      Exit;
     End;
*)
  End;
End;

{
1 открыть файл клиентов
2 заблокировать предварительной блокировкой запись
  заблокировать надо обязательно успешно

3 прочитать клиента
4 просмотреть его поле Lock
  Если Lock Истина тогда позиция занята и надо снять предварительную
  блокировку установленную пунктом 2,
  иначе проводим окончательную блокировку клиента, устанавливая Lock=False
}

Function WriteLockKassaOperation(ClientElement:KassaOperation):Boolean;
Var f : File Of KassaOperation;
    c : LongInt;
    s : KassaOperation;
Begin
DInfoNetMsg('Сохраняю информацию об операции с кодом '+ClientElement.Kod+'...');
WriteLockKassaOperation:=False;
Assign (F,Path.ToClient+'kassa.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла кассовых операций!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation)));

{$IFDEF NetVersion}
   ClientElement.Locked:=True;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   WriteLockKassaOperation:=True;
End;





Function SetNameUnLock(c:ArtikulStr):Boolean;
Var f : File of BazType;
    l : LongInt;
    Code : Integer;
    s : BazType;
    st : ArtikulStr;
    Nam : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую наименование с кодом '+c);
 SetNameUnLock:=False;
 NAm :=Copy(c,1,CRazdelKod);
 Assign(f,Path.TOName+Nam+'.id');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла'^M+
  #3+Path.TOName+Nam+'.id ('+INtToStr(l,CLitrMantissa)+')',nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End
 Else
  Begin
   Nam:=Copy(c,1+CRazdelKod,CKod);
   DelSpace(Nam);
   l:=StrToInt(Nam);
   Seek(f,l);
   Repeat
    Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(BazType),SizeOf(BazType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;

   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(BazType),SizeOf(BazType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetNameUnLock:=True;
  End;
End;


Function WriteLockName(Element:BazType;SkladElement:SkladType):Boolean;
Var f : File Of BazType;
 fskl : File Of SkladType;
    c : LongInt;
    s : BazType;
   skl: SkladType;
  Nam : ArtikulStr;
Begin
DInfoNetMsg('Сохраняю информацию о товаре с кодом '+Element.BazKod+'...');
WriteLockName:=False;

 DelSpace(Element.BazKod);
 DelSpace(SkladElement.BazKod);
 NAm :=Copy(Element.BazKod,1,CRazdelKod);
 Assign(f,Path.TOName+Nam+'.id');
 Assign(fskl,Path.TOSklad+Nam+'.db');


  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла'^M+
    #3+Path.TOName+Nam+'.id ('+INtToStr(c,CLitrMantissa)+')',nil,mfError+mfCancelButton);
    Exit;
   End;
  c:=IOResult;
  Reset(fskl);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла'^M+
    #3+Path.TOSklad+Nam+'.db ('+INtToStr(c,CLitrMantissa)+')',nil,mfError+mfCancelButton);
    Exit;
   End;

   Nam:=Copy(Element.BazKod,1+CRazdelKod,CKod);
   c:=StrToInt(Nam);
   Seek(f,c);
   Seek(fskl,c);

{$IFDEF NetVersion}
   Element.Locked:=True;
{$ENDIF}
   SkladElement.Locked:=False;


   Repeat
    Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(BazType),SizeOf(BazType)));

   Repeat
    Pause(1);
   Until (Lock(fskl,FilePos(f)*SizeOf(SkladType),SizeOf(SkladType)));

   Write(f,Element);
   Write(fskl,SkladElement);

   Seek(f,Filepos(f)-1);
   Seek(fskl,Filepos(fskl)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(BazType),SizeOf(BazType));
   Until DosError=0;

   Repeat
   Unlock(fskl,FilePos(fskl)*SizeOf(SkladType),SizeOf(SkladType));
   Until DosError=0;

   Close(f);
   Close(fskl);
   NoNetInfoMsg;
   WriteLockName:=True;
End;


Function TestEmployNameAndLock(TestCod:ArtikulStr;Var Operator:STrName):Boolean;
Var f : File Of BazType;
    c : LongInt;
    s : BazType;
    Nam : ArtikulStr;
Begin
Operator[0]:=#0;
DInfoNetMsg('Блокирую наименование с кодом '+TestCod);
TestEmployNameAndLock:=False;

 NAm :=Copy(TestCod,1,CRazdelKod);
 Assign(f,Path.TOName+Nam+'.id');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла'^M+
  #3+Path.TOName+Nam+'.id ('+INtToStr(c,CLitrMantissa)+')',nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End;

   DelSpace(TestCod);
   Nam:=Copy(TestCod,1+CRazdelKod,CKod);
   c:=StrToInt(Nam);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(BazType),SizeOf(BazType)); {предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       Operator:=': '+GetOperatorName(Operator);
       End;
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(BazType),SizeOf(BazType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(BazType),SizeOf(BazType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;            {проведение вторичной блокировки}
{$ENDIF}
      s.BazKod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(BazType),SizeOf(BazType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployNameAndLock:=True;
      Exit;
End;

Function LockAndWritePrihod(Var L:PPrihodType;Mode:Boolean):Boolean;
{Параметр Mode указывает что это поступление товара на склад или
формирование и корректировка
Mode = True поступление товара на склад
Mode = False формирование и корректировка}
Var PrihodFile : PrihodFileType;
    c : Byte;
    ChangeNumer,Find : Boolean;
    Test : PPrihodType;
    Pos1,pos2,Pos,Code : LongInt;
Begin
 LockAndWritePrihod:=False;
 Assign(PrihodFile,Path.ToPrihod+L^.Dat.DateC+'.prh');
 c:=IOResult;
{$I-}
 Reset(PrihodFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox('Файл '+L^.Dat.DateC+'.prh не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil,
        mfConfirmation + mfOkCancel)=cmOk  Then
     Begin
{     c:=IOResult;
      Reset(PrihodFile);
      c:=IOResult;
      If c<>0 Then Rewrite(PrihodFile);}
      If Not(CreatToDayF(DocPrihod,L^.Dat.DateC)) Then Exit;
      Reset(PrihodFile);
      c:=IOResult;
     End
    Else
     Begin
      Exit;
     End;
 End;
 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу '+L^.Dat.DateC+'.prh!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;
{если открытие прошло нормально}
If Not(Mode) Then
Begin
   If Status=DocEdit Then
    Begin
     {создаем новый экземпляр прихода}
     New(test,Init);
     Find := False;
     DelSPace(L^.DAt.Document);
     DelSPace(L^.DAt.DAteC);
     DelSPace(L^.DAt.SkladKod);
     {цикл поиска исходного документа в файле}
     While Not(Eof(PrihodFile)) And Not(Find) Do
      Begin
     {
     Repeat
     Pause(1);
     Until Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType));
     }
     ReadPrihod(PrihodFile,Test);
     {
     Repeat
      UnLock(PrihodFile,(FilePos(PrihodFile)-1)*SizeOf(PrihodType),SizeOf(PrihodType));
     Until (DosError=0);
     }
       DelSpace(Test^.Dat.Document);
       DelSpace(Test^.Dat.DateC);
       DelSpace(Test^.Dat.SkladKod);
       If (Test^.Dat.Document=L^.DAt.Document) And
          (Test^.Dat.DateC=L^.DAt.DateC) And
          (Test^.Dat.SkladKod=L^.DAt.SkladKod) Then Find:=True;
      End;
      Dispose(Test,Done);

     {если документ не найден тогда выходим с сообщением}
     If Not(Find) Then
      Begin
       Close(PrihodFile);
       MessageBox(#3^M+#3'Документ прихода N '+ L^.Dat.Document+' в базе за '+L^.DAt.DAteC+' не найден!',Nil,
          mfError+mfCancelButton);
       Exit;
      End;

     DInfoNetMsg('Изменяю документ прихода N '+L^.Dat.Document+' от '+L^.Dat.Datec+'...');
     {если мы нашли документ тогда блокируем его и записываем}
     Seek(PrihodFile,FilePos(PrihodFile)-1);
     {блокировка}
     Repeat
      Pause(1);
     Until (Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType)));
     {запись}

{$IFDEF NetVersion}
     L^.Dat.Locked:=True;
{$ENDIF}

     Write(PrihodFile,L^.DAt);
     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле прихода...');
     {снятие блокировки}
     Seek(PrihodFile,FilePos(PrihodFile)-1);
     Repeat
      Pause(1);
      UnLock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType));
     Until (DosError=0);
     Close(PrihodFile);
     LockAndWritePrihod:=True;
     NoInfoMsg;

    End
   Else
    Begin
     {запись прихода для случая формирования накладной}
     DInfoNetMsg('Сохраняю новый документ прихода N '+L^.Dat.Document+' от '+L^.Dat.Datec+'...');

    ChangeNumer:=False;
    Repeat
     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(PrihodFile);
      Seek(PrihodFile,Pos1);
     Until (Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType)*5));

     Pos1:=FileSize(PrihodFile);

     If FilePos(PrihodFile)<>Pos1{FileSize(PrihodFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        Pause(1);
        UnLock(PrihodFile,(FilePos(PrihodFile))*SizeOf(PrihodType),SizeOf(PrihodType)*5);
       Until (DosError=0);
      End;

    Until (FilePos(PrihodFile)=Pos1{FileSize(PrihodFile)});

{$IFDEF NetVersion}
     L^.Dat.Locked:=True;
{$ENDIF}

     If (({FileSize(PrihodFile)}Pos1+1)<>(StrToInt(L^.Dat.Document))) Then
     Begin
      ChangeNumer:=True;
   L^.Dat.Document:=IntToStr({FileSize(PrihodFile)}Pos1+1,CDocNumer);
      DelSpace(L^.Dat.Document);
     End;

     Write(PrihodFile,L^.DAt);
     Seek(PrihodFile,FilePos(PrihodFile)-1);
     NoNetInfoMsg;

     DInfoMsg('Деблокирую запись в файле прихода...');

     Repeat {деблокируем участок записи}
      Pause(1);
      UnLock(PrihodFile,(FilePos(PrihodFile))*SizeOf(PrihodType),
         SizeOf(PrihodType)*5);
    { If DosError<>0 Then
      MessageBox(#3+'DosError='+IntToStr(DosError,3),Nil,
      mfError+mfCancelButton);    }
     Until (DosError=0);

     Close(PrihodFile);
     LockAndWritePrihod:=True;
     NoInfoMsg;

     If ChangeNumer Then
     Begin
      If (ShowNumer=1) Then
       Begin
       MessageBox(#3+'За время формирования Вами прихода проведены другие '+
          'приходы. Присваиваю документу новый номер: '+L^.Dat.Document+'!',
                Nil,mfInformation+mfCancelButton);
       End;
     End;
    End;
End {If NOt(Mode)}
   Else {Если это поступление товара на склад}
    Begin
     {создаем новый экземпляр прихода}
     New(test,Init);
     Find := False;
     DelSPace(L^.DAt.Document);
     DelSPace(L^.DAt.DAteC);
     DelSPace(L^.DAt.SkladKod);
     {цикл поиска исходного документа в файле}
     While Not(Eof(PrihodFile)) And Not(Find) Do
      Begin
     {
     Repeat
     Pause(1);
     Until Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType));
     }
     ReadPrihod(PrihodFile,Test);
     {
     Repeat
      UnLock(PrihodFile,(FilePos(PrihodFile)-1)*SizeOf(PrihodType),SizeOf(PrihodType));
     Until (DosError=0);
     }
       DelSpace(Test^.Dat.Document);
       DelSpace(Test^.Dat.DateC);
       DelSpace(Test^.Dat.SkladKod);
       If (Test^.Dat.Document=L^.DAt.Document) And
          (Test^.Dat.DateC=L^.DAt.DateC) And
          (Test^.Dat.SkladKod=L^.DAt.SkladKod) Then Find:=True;
      End;
      Dispose(Test,Done);

     {если документ не найден тогда выходим с сообщением}
     If Not(Find) Then
      Begin
       Close(PrihodFile);
       MessageBox(#3^M+#3'Документ прихода N '+ L^.Dat.Document+' в базе за '+L^.DAt.DAteC+' не найден!',Nil,
          mfError+mfCancelButton);
       Exit;
      End;

     DInfoNetMsg('Ввожу на склад документ прихода N '+L^.Dat.Document+' от '+L^.Dat.Datec+'...');
     {если мы нашли документ тогда блокируем его и записываем}
     Seek(PrihodFile,FilePos(PrihodFile)-1);
     {блокировка}
     Repeat
      Pause(1);
     Until (Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType)));
     {запись}

{$IFDEF NetVersion}
     L^.Dat.Locked:=True;
{$ENDIF}
     Write(PrihodFile,L^.DAt);
     {снятие блокировки}
     Seek(PrihodFile,FilePos(PrihodFile)-1);

     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле прихода...');

     Repeat
      Pause(1);
      UnLock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType));
     Until (DosError=0);
     Close(PrihodFile);
     LockAndWritePrihod:=True;
     NoInfoMsg;
    End
End;



Function LockPrihod(As : DocumentEdit;Var E:PPrihodType):Word;
{функция возвращает 0 если все прошло ок
1 если документ уже введен на склад
2 если документ не найден
3 если не удалось заблокировать накладную
4 ошибка сетевого открытия файла прихода}

Var C : Byte;
    Find : Boolean;
    PrihodFile : PrihodFileType;
    Code : InTeger;
    Pos : LongInt;
Begin
  LockPrihod:=4;
  C:=IOResult;
  Assign(PrihodFile,Path.ToPrihod+As.D+'.prh');
  Reset(PrihodFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла прихода за '+As.D+'!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    C:=IOResult;
    LockPrihod:=4;
    Exit;
   End;

   Seek(PrihodFile,0);

   DelSpace(As.EditPosition);
   DelSpace(As.D);
   DelZerro(As.EditPosition);
   As.EditPosition:=ClearChar(As.EditPosition);
   Find:=False;

   {цикл поиска накладной}
   While Not(eof(PrihodFile)) And Not(Find) Do
    Begin
     {
     Repeat
     Pause(1);
     Until Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType));
     }
     ReadPrihod(PrihodFile,E);
     {
     Repeat
      UnLock(PrihodFile,(FilePos(PrihodFile)-1)*SizeOf(PrihodType),SizeOf(PrihodType));
     Until (DosError=0);
     }
     DelSpace(E^.DAt.Document);
     DelZerro(E^.Dat.Document);
     If (E^.DAt.Document=As.EditPosition) And (E^.DAt.DateC=As.D) Then Find:=True;
    End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      LockPrihod:=2;
      Close(PrihodFile);
      MessageBox(#3^M+#3'Документ прихода N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}

   DInfoNetMsg('Блокирую документ прихода N '+E^.Dat.Document+' от '+E^.Dat.DateC+'...');
   LockPrihod:=3;
   Seek(PrihodFile,FilePos(PrihodFile)-1);

   Repeat
   Pause(1);
   Until Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType));
   Read(PrihodFile,E^.Dat);

   {если документ уже введен на склад}
   If (E^.Dat.StatusDoc=0) Then
    Begin
     NoNetInfoMsg;
     LockPrihod:=1;
     {снятие предварительной блокировки}
     Seek(PrihodFile,FilePos(PrihodFile)-1);
     Repeat
      UnLock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType))
     Until Doserror=0;
     Close(PrihodFile);
     MessageBox(#3^M+#3'Документ прихода N '+As.EditPosition+' от '+As.D+''^M+
     #3'уже введен на склад и корректироваться не может!',Nil,mfError+mfCancelButton);
     Exit;
    End;

   {если документ уже заблокирован}
   If (E^.Dat.Locked) Then
    Begin
     NoNetInfoMsg;
     LockPrihod:=3;
     {снятие предварительной блокировки}
     Seek(PrihodFile,FilePos(PrihodFile)-1);
     Repeat
      UnLock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType))
     Until Doserror=0;
     Close(PrihodFile);
     Exit;
    End;

   {проведение вторичной блокировки}
{$IFDEF NetVersion}
   E^.DAt.Locked:=True;
{$ENDIF}

   Seek(PrihodFile,FilePos(PrihodFile)-1);
   Write(PrihodFile,E^.DAt);
   Seek(PrihodFile,FilePos(PrihodFile)-1);

   Repeat
    Pause(1);
    UnLock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType))
   Until Doserror=0;

   LockPrihod:=0;
   NoNetInfoMsg;
   Close(PrihodFile);
End;


Function FindFantom(E:PPrihodType;VAr FantomBox:PBox):Boolean;
{функция возвращает 0 если все прошло ок
1 если документ уже введен на склад
2 если документ не найден
3 если не удалось заблокировать накладную
4 ошибка сетевого открытия файла прихода}
Var C : Word;
    Error,Find : Boolean;
    PrihodFile : PrihodFileType;
    L : PPrihodType;
    Dlg : PDialog;
    Control : PView;
    R : TRect;
    S : String;
    TempFantomBox:PBox;

Begin
  FindFantom:=False;
  C:=IOResult;
  Assign(PrihodFile,Path.ToPrihod+E^.DAt.DAteC+'.prh');
  Reset(PrihodFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла прихода за '+E^.Dat.DAteC+'!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    C:=IOResult;
    Exit;
   End;

   Seek(PrihodFile,0);

   DelSpace(E^.Dat.Document);
   DelSpace(E^.Dat.DateC);
   DelZerro(E^.Dat.Document);
   E^.Dat.Document:=ClearChar(E^.Dat.Document);
   Find:=False;

   New(L,Init);

   {цикл поиска накладной}
   While Not(eof(PrihodFile))Do
    Begin
     Error:=False;
     {
     Repeat
     Pause(1);
     Until Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType));
     }
     ReadPrihod(PrihodFile,L);
     {
     Repeat
      UnLock(PrihodFile,(FilePos(PrihodFile)-1)*SizeOf(PrihodType),SizeOf(PrihodType));
     Until (DosError=0);
     }
     DelSpace(L^.DAt.Document);
     DelZerro(L^.Dat.Document);
{    If L^.DAt.PrihodElement[1]=E^.DAt.PrihodElement[1] Then;}

     If  (L^.DAt.Document<>E^.Dat.Document) {другой документ}
  And (L^.DAt.DateC=E^.Dat.DateC)     {одинаковая дата}
  And (L^.DAt.OperatorSelector=E^.Dat.OperatorSelector) {одинаковый вид поставщика}
  And (StrToInt(L^.DAt.MAkeKod)=StrToInt(E^.Dat.MakeKod)) {одинаковый код поставщика}
  And (StrToReal(L^.DAt.SummaR)=StrToReal(E^.Dat.SummaR)) {одинаковая сумма по Р/Ц}
  And (StrToReal(L^.DAt.SummaO)=StrToReal(E^.Dat.SummaO)) {одинаковая сумма по Р/Ц}
  And (StrToReal(L^.DAt.SummaZakupka)=StrToReal(E^.Dat.SummaZakupka)) {одинаковая сумма по З/Ц}
  And (L^.DAt.StatusDoc=0) {признак того что документ введен на склад} Then
   Begin
       Error:=True;
    Find:=True;
      End;
     If Error Then
      Begin
       s:=GetMAkeField(FMAke,L^.DAt.MAkeKod,L^.DAt.OperatorSelector);
       DelSpaceRight(s);
       Format(s,CMAke);
       Str(StrToReal(L^.DAt.SummaR):CIZena:CMAntissa,L^.DAt.SummaR);
       Str(StrToReal(L^.DAt.SummaO):CIZena:CMAntissa,L^.DAt.SummaO);
       s:=s+'│'+IntToStr(L^.DAt.OperatorSelector,COne)+'│'+L^.DAt.MAkeKod+'│'+
    L^.DAt.SummaR+'│'+L^.DAt.SummaO;
       DelSpace(L^.DAt.SummaR);
       DelSpace(L^.DAt.SummaO);
       FantomBox^.List^.Insert(NewStr(s));
       FantomBox^.SetRange(FantomBox^.List^.Count);
      End;
    End;
   Close(PrihodFile);
   Dispose(L,Done);

If Not(Find) Then
 Begin
  Exit;
 End;

R.Assign(10, 6, 72, 16);
New(Dlg, Init(R, 'Предупреждение'));
Dlg^.HelpCtx:=$F016;

R.Assign(61, 4, 62, 9);
Control := New(PScrollBar, Init(R));
Dlg^.Insert(Control);

R.Assign(1, 4, 61, 9);
TempFantomBox := New(PBox, Init(R, 1, PScrollbar(Control)));
TempFantomBox^.NewList(New(PTextCollection, Init(0,1)));

If (FantomBox^.List^.Count)>0 Then
  For c:=0 To FantomBox^.List^.Count-1 Do
   Begin
    s:=FantomBox^.GetText(c,FantomBox^.List^.Count);
    TempFantomBox^.List^.Insert(NewStr(s));
    TempFantomBox^.SetRange(TempFantomBox^.List^.Count);
   End;
Dlg^.Insert(TempFantomBox);


  R.Assign(1, 3, 61, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Поставщик            В  Код   Сумма по Р/Ц    Сумма по О/Ц ', TempFantomBox)));

R.Assign(1, 1, 61, 3);
Control := New(PColoredText, Init(R, 'Внимание! Приход на ту же сумму и от'+
     ' того же поставщика сегодня уже был !', $5E));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);

SpecialBeep;
c:=Desktop^.ExecView(Dlg);
Dispose(TempFantomBox,Done);
Dispose(Control,Done);
Dispose(Dlg,Done);
If c=cmCAncel Then FindFantom:=True;
End;



Function UnLockPrihod(Doc:ArtikulStr;DD:TDateString):Word;
{
 0 деблокировка прошла нормально
 2 документ не найден
 1 не смог деблокировать
 3 ошибка сетевого открытия
}

Var C : Byte;
    Find : Boolean;
    PrihodFile : PrihodFileType;
    Test : PPrihodType;
    Code,Pos :LongInt;

Begin
  UnLockPrihod:=3;
  C:=IOResult;
  Assign(PrihodFile,Path.ToPrihod+DD+'.prh');
  Reset(PrihodFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла прихода за '+DD+'!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    UnLockPrihod:=3;
    C:=IOResult;
    Exit;
   End;

   Seek(PrihodFile,0);

   DelSpace(Doc);
   DelSpace(DD);
   DelZerro(Doc);
   Find:=False;

   New(Test,Init);
   {цикл поиска накладной}
   While Not(eof(PrihodFile)) And Not(Find) Do
    Begin
     {
     Repeat
     Pause(1);
     Until Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType));
     }
     ReadPrihod(PrihodFile,Test);
     {
     Repeat
      UnLock(PrihodFile,(FilePos(PrihodFile)-1)*SizeOf(PrihodType),SizeOf(PrihodType));
     Until (DosError=0);
     }
     DelSpace(Test^.DAt.Document);
     DelZerro(Test^.Dat.Document);
     If (Test^.DAt.Document=Doc) And (TEST^.DAt.DateC=DD) Then Find:=True;
    End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      Dispose(test,Done);
      UnLockPrihod:=2;
      Close(PrihodFile);
      MessageBox(#3^M+#3'Документ прихода N '+ Doc+' в базе за '+DD+' не найден!',
         Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}

   DInfoNetMsg('Деблокирую документ прихода N '+Doc+' от '+DD+'...');
   UnLockPrihod:=1;
   Seek(PrihodFile,FilePos(PrihodFile)-1);

 If Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType)) Then
 Begin
   Read(PrihodFile,Test^.Dat);
   {проведение вторичной блокировки}
   Test^.DAt.Locked:=False;
   Seek(PrihodFile,FilePos(PrihodFile)-1);
   Write(PrihodFile,Test^.DAt);
   Seek(PrihodFile,FilePos(PrihodFile)-1);
   Repeat
    Pause(1);
    UnLock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType))
   Until Doserror=0;
   UnLockPrihod:=0;
   NoNetInfoMsg;
   Close(PrihodFile);
   Dispose(Test,Done);
 End
   Else
      Begin
       NoNetInfoMsg;
       UnLockPrihod:=1;
       Close(PrihodFile);
       Dispose(Test,Done);
      End;
End;



Function LockAndWriteReturn(Var L:PNewVozwratType;Mode:Boolean):Boolean;

{Параметр Mode указывает что это поступление товара на склад или
формирование и корректировка
Mode = True поступление товара на склад
Mode = False формирование и корректировка}
Var ReturnFile : NewVozwratFileType;
    c : Byte;
    ChangeNumer,Find : Boolean;
    Test : PNewVozwratType;
    pos1,Pos,Code : LongInt;
Begin
 LockAndWriteReturn:=False;
 Assign(ReturnFile,Path.ToReturn+L^.Dat.DateC+'.vzw');
 c:=IOResult;
{$I-}
 Reset(ReturnFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox('Файл '+L^.Dat.DateC+'.vzw не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil,
        mfConfirmation + mfOkCancel)=cmOk  Then
     Begin
{      c:=IOResult;
      Reset(ReturnFile);
      c:=IOResult;
      If c<>0 Then Rewrite(ReturnFile);}
      If Not(CreatToDayF(DocReturn,L^.Dat.DateC)) Then Exit;
      Reset(ReturnFile);
      c:=IOResult;
     End
    Else
     Begin
      Exit;
     End;
 End;
 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу '+L^.Dat.DateC+'.vzw!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;
{если открытие прошло нормально}
If Not(Mode) Then
Begin
   If Status=DocEdit Then
    Begin
     {создаем новый экземпляр прихода}
     New(test,Init);
     Find := False;
     DelSPace(L^.DAt.Document);
     DelSPace(L^.DAt.DAteC);
     DelSPace(L^.DAt.SkladKod);
     {цикл поиска исходного документа в файле}
     While Not(Eof(ReturnFile)) And Not(Find) Do
      Begin
{     Repeat
     Pause(1);
     Until Lock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
}
     ReadNewVozwrat(ReturnFile,Test);
{
     Repeat
      UnLock(ReturnFile,(FilePos(ReturnFile)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
}
       DelSpace(Test^.Dat.Document);
       DelSpace(Test^.Dat.DateC);
       DelSpace(Test^.Dat.SkladKod);
       If (Test^.Dat.Document=L^.DAt.Document) And
          (Test^.Dat.DateC=L^.DAt.DateC) And
          (Test^.Dat.SkladKod=L^.DAt.SkladKod) Then Find:=True;
      End;
      Dispose(Test,Done);

     {если документ не найден тогда выходим с сообщением}
     If Not(Find) Then
      Begin
       Close(ReturnFile);
       MessageBox(#3^M+#3'Документ возрата N '+ L^.Dat.Document+' в базе за '+L^.DAt.DAteC+' не найден!',Nil,
          mfError+mfCancelButton);
       Exit;
      End;

     DInfoNetMsg('Изменяю документ возврата N '+L^.Dat.Document+' от '+L^.Dat.Datec+'...');
     {если мы нашли документ тогда блокируем его и записываем}
     Seek(ReturnFile,FilePos(ReturnFile)-1);
     {блокировка}
     Repeat
      Pause(1);
     Until (Lock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType)));
     {запись}

{$IFDEF NetVersion}
     L^.Dat.Locked:=True;
{$ENDIF}

     Write(ReturnFile,L^.DAt);
     {снятие блокировки}
     Seek(ReturnFile,FilePos(ReturnFile)-1);
     NoNetInfoMsg;
     DInfoMSg('Деблокирую запись в файле возврата...');
     Repeat
      Pause(1);
      UnLock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     Close(ReturnFile);
     LockAndWriteReturn:=True;
     NoInfoMsg;

    End
   Else
    Begin
     {запись прихода для случая формирования накладной}
     DInfoNetMsg('Сохраняю документ возврата N '+L^.Dat.Document+' от '+L^.Dat.Datec+'...');
    ChangeNumer:=False;
    Repeat

     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(ReturnFile);
      Seek(ReturnFile,Pos1);
     Until (Lock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType)*5));

     Pos1:=FileSize(ReturnFile);

     If FilePos(ReturnFile)<>Pos1{FileSize(ReturnFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        Pause(1);
        UnLock(ReturnFile,(FilePos(ReturnFile))*SizeOf(NewVozwratType),SizeOf(NewVozwratType)*5);
       Until (DosError=0);
      End;

    Until (FilePos(ReturnFile)=Pos1{FileSize(ReturnFile)});

{$IFDEF NetVersion}
     L^.Dat.Locked:=True;
{$ENDIF}

     If (({FileSize(ReturnFile)}Pos1+1)<>(StrToInt(L^.Dat.Document))) Then
     Begin
      ChangeNumer:=True;
   L^.Dat.Document:=IntToStr({FileSize(ReturnFile)}Pos1+1,CDocNumer);
      DelSpace(L^.Dat.Document);
     End;

     Write(ReturnFile,L^.DAt);
     Seek(ReturnFile,FilePos(ReturnFile)-1);

     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле возврата...');
     Repeat {деблокируем участок записи}
      Pause(1);
      UnLock(ReturnFile,(FilePos(ReturnFile))*SizeOf(NewVozwratType),
      SizeOf(NewVozwratType)*5);
     {If DosError<>0 Then
       MessageBox(#3+'DosError='+IntToStr(DosError,3),Nil,
          mfError+mfCancelButton);}
     Until (DosError=0);
     Close(ReturnFile);
     LockAndWriteReturn:=True;
     NoInfoMsg;


     If ChangeNumer Then
     Begin
      If (ShowNumer=1) Then
       Begin
       MessageBox(#3+'За время формирования Вами возврата проведены другие '+
          'возвраты. Присваиваю документу новый номер: '+L^.Dat.Document+'!',
                Nil,mfInformation+mfCancelButton);
       End;
     End;

    End;
End {If NOt(Mode)}
   Else {Если это поступление товара на склад}
    Begin
     {создаем новый экземпляр прихода}
     New(test,Init);
     Find := False;
     DelSPace(L^.DAt.Document);
     DelSPace(L^.DAt.DAteC);
     DelSPace(L^.DAt.SkladKod);
     {цикл поиска исходного документа в файле}
     While Not(Eof(ReturnFile)) And Not(Find) Do
      Begin
     {
     Repeat
     Pause(1);
     Until Lock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     }
     ReadNewVozwrat(ReturnFile,Test);
     {
     Repeat
      UnLock(ReturnFile,(FilePos(ReturnFile)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     }
       DelSpace(Test^.Dat.Document);
       DelSpace(Test^.Dat.DateC);
       DelSpace(Test^.Dat.SkladKod);
       If (Test^.Dat.Document=L^.DAt.Document) And
          (Test^.Dat.DateC=L^.DAt.DateC) And
          (Test^.Dat.SkladKod=L^.DAt.SkladKod) Then Find:=True;
      End;
      Dispose(Test,Done);

     {если документ не найден тогда выходим с сообщением}
     If Not(Find) Then
      Begin
       Close(ReturnFile);
       MessageBox(#3^M+#3'Документ возврата N '+ L^.Dat.Document+' в базе за '+L^.DAt.DAteC+' не найден!',Nil,
          mfError+mfCancelButton);
       Exit;
      End;

     DInfoNetMsg('Ввожу на склад документ возврата N '+L^.Dat.Document+' от '+L^.Dat.Datec+'...');
     {если мы нашли документ тогда блокируем его и записываем}
     Seek(ReturnFile,FilePos(ReturnFile)-1);
     {блокировка}
     Repeat
      Pause(1);
     Until (Lock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType)));
     {запись}

{$IFDEF NetVersion}
     L^.Dat.Locked:=True;
{$ENDIF}

     Write(ReturnFile,L^.DAt);
     {снятие блокировки}
     Seek(ReturnFile,FilePos(ReturnFile)-1);

     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле возврата...');

     Repeat
      UnLock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     Close(ReturnFile);
     LockAndWriteReturn:=True;
     NoInfoMsg;
    End
End;


Function LockReturn(As : DocumentEdit;Var E:PNewVozwratType):Word;
{функция возвращает 0 если все прошло ок
1 если документ уже введен на склад
2 если документ не найден
3 если не удалось заблокировать накладную
4 ошибка сетевого открытия файла прихода}

Var C : Byte;
    Find : Boolean;
    ReturnFile : NewVozwratFileType;
Begin
  LockReturn:=4;
  C:=IOResult;
  Assign(ReturnFile,Path.ToReturn+As.D+'.vzw');
  Reset(ReturnFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла возврата за '+As.D+'!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    C:=IOResult;
    LockReturn:=4;
    Exit;
   End;

   Seek(ReturnFile,0);

   DelSpace(As.EditPosition);
   DelSpace(As.D);
   DelZerro(As.EditPosition);
   As.EditPosition:=ClearChar(As.EditPosition);
   Find:=False;

   {цикл поиска накладной}
   While Not(eof(ReturnFile)) And Not(Find) Do
    Begin
     {
     Repeat
     Pause(1);
     Until Lock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     }
     ReadNewVozwrat(ReturnFile,E);
     {
     Repeat
      UnLock(ReturnFile,(FilePos(ReturnFile)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     }
     DelSpace(E^.DAt.Document);
     DelZerro(E^.Dat.Document);
     If (E^.DAt.Document=As.EditPosition) And (E^.DAt.DateC=As.D) Then Find:=True;
    End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      LockReturn:=2;
      Close(ReturnFile);
      MessageBox(#3^M+#3'Документ возврата N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}

   DInfoNetMsg('Блокирую документ возврата N '+E^.Dat.Document+' от '+E^.Dat.DateC+'...');
   LockReturn:=3;
   Seek(ReturnFile,FilePos(ReturnFile)-1);

   Repeat
   Pause(1);
   Until Lock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
   Read(ReturnFile,E^.Dat);

   {если документ уже введен на склад}
   If (E^.Dat.StatusDoc=0) Then
    Begin
     NoNetInfoMsg;
     LockReturn:=1;
     {снятие предварительной блокировки}
     Seek(ReturnFile,FilePos(ReturnFile)-1);
     Repeat
      UnLock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType))
     Until Doserror=0;
     Close(ReturnFile);
     MessageBox(#3^M+#3'Документ возврата N '+As.EditPosition+' от '+As.D+''^M+
     #3'уже введен на склад и корректироваться не может!',Nil,mfError+mfCancelButton);
     Exit;
    End;

   {если документ уже заблокирован}
   If (E^.Dat.Locked) Then
    Begin
     NoNetInfoMsg;
     LockReturn:=3;
     {снятие предварительной блокировки}
     Seek(ReturnFile,FilePos(ReturnFile)-1);
     Repeat
      UnLock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType))
     Until Doserror=0;
     Close(ReturnFile);
     Exit;
    End;

   {проведение вторичной блокировки}
{$IFDEF NetVersion}
   E^.DAt.Locked:=True;
{$ENDIF}

   Seek(ReturnFile,FilePos(ReturnFile)-1);
   Write(ReturnFile,E^.DAt);
   Seek(ReturnFile,FilePos(ReturnFile)-1);
   Repeat
    UnLock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType))
   Until Doserror=0;
   LockReturn:=0;
   NoNetInfoMsg;
   Close(ReturnFile);
End;



Function UnLockReturn(Doc:ArtikulStr;DD:TDateString):Word;
{
 0 деблокировка прошла нормально
 2 документ не найден
 1 не смог деблокировать
 3 ошибка сетевого открытия
}

Var C : Byte;
    Find : Boolean;
    ReturnFile : NewVozwratFileType;
    Test : PNewVozwratType;

Begin
  UnLockReturn:=3;
  C:=IOResult;
  Assign(ReturnFile,Path.ToReturn+DD+'.vzw');
  Reset(ReturnFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла возврата за '+DD+'!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    UnLockReturn:=3;
    C:=IOResult;
    Exit;
   End;

   Seek(ReturnFile,0);

   DelSpace(Doc);
   DelSpace(DD);
   DelZerro(Doc);
   Find:=False;

   New(Test,Init);
   {цикл поиска накладной}
   While Not(eof(ReturnFile)) And Not(Find) Do
    Begin
     {
     Repeat
     Pause(1);
     Until Lock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     }
     ReadNewVozwrat(ReturnFile,Test);
     {
     Repeat
      UnLock(ReturnFile,(FilePos(ReturnFile)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     }

     DelSpace(Test^.DAt.Document);
     DelZerro(Test^.Dat.Document);
     If (Test^.DAt.Document=Doc) And (TEST^.DAt.DateC=DD) Then Find:=True;
    End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      Dispose(test,Done);
      UnLockReturn:=2;
      Close(ReturnFile);
      MessageBox(#3^M+#3'Документ возврата N '+ Doc+' в базе за '+DD+' не найден!',
         Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}

   DInfoNetMsg('Деблокирую документ возврата N '+Doc+' от '+DD+'...');
   UnLockReturn:=1;
   Seek(ReturnFile,FilePos(ReturnFile)-1);

 If Lock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType)) Then
 Begin
   Read(ReturnFile,Test^.Dat);
   {проведение вторичной блокировки}
   Test^.DAt.Locked:=False;
   Seek(ReturnFile,FilePos(ReturnFile)-1);
   Write(ReturnFile,Test^.DAt);
   Seek(ReturnFile,FilePos(ReturnFile)-1);
   Repeat
    UnLock(ReturnFile,FilePos(ReturnFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType))
   Until Doserror=0;
   UnLockReturn:=0;
   NoNetInfoMsg;
   Close(ReturnFile);
   Dispose(Test,Done);
 End
   Else
      Begin
       NoNetInfoMsg;
       UnLockReturn:=1;
       Close(ReturnFile);
       Dispose(Test,Done);
      End;
End;





Function LockAndWritePereozenka( Var L:PPereozenkaType) : Boolean;
Var PereozenkaFile : File of PereozenkaType;
     c : Byte;
     ChangeNumer : Boolean;
     Pos1: LongInt;
Begin
 LockAndWritePereozenka:=False;
 Assign(PereozenkaFile,Path.ToCorrect+L^.Dat.DateC+'.prz');
 c:=IOResult;
{$I-}
 Reset(PereozenkaFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox('Файл '+L^.Dat.DateC+'.prz не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil, mfConfirmation + mfOkCancel)=cmOk Then
     Begin
{      c:=IOResult;
      Reset(PereozenkaFile);
      c:=IOResult;
      If c<>0 Then Rewrite(PereozenkaFile);}
      If Not(CreatToDayF(DocPereozen,L^.Dat.DateC)) Then Exit;
      Reset(PereozenkaFile);
      c:=IOResult;
     End
    Else
     Begin
      Exit;
     End;
 End;
 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу '+L^.Dat.DateC+'.prz!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;

     {запись прихода для случая формирования накладной}

     DInfoNetMsg('Сохраняю документ переоценки N '+L^.Dat.Document+' от '+L^.Dat.Datec+'...');
{
     Repeat
      Seek(PereozenkaFile,FileSize(PereozenkaFile));
      Pause(1);
     Until (Lock(PereozenkaFile,FilePos(PereozenkaFile)*SizeOf(PereozenkaType),SizeOf(PereozenkaType)*5));

     If ((FileSize(PereozenkaFile)+1)<>(StrToInt(L^.Dat.Document))) Then
     Begin
      L^.Dat.Document:=IntToStr(FileSize(PereozenkaFile)+1,CDocNumer);
      DelSpace(L^.Dat.Document);
      If (ShowNumer=1) Then
      Begin
       NoNetInfoMsg;
       MessageBox(#3+'За время формирования Вами преоценки проведены другие '+
          'переоценки. Присваиваю документу новый номер: '+L^.Dat.Document+'!',Nil,mfInformation+mfCancelButton);
       DInfoNetMsg('Сохраняю документ переоценки N '+L^.Dat.Document+' от '+L^.Dat.Datec+'...');
      End;
     End;

     Write(PereozenkaFile,L^.Dat);
     Seek(PereozenkaFile,FilePos(PereozenkaFile)-1);
     Repeat
      UnLock(PereozenkaFile,FilePos(PereozenkaFile)*SizeOf(PereozenkaType),SizeOf(PereozenkaType)*5);
     Until (DosError=0);
     }
    ChangeNumer:=False;
    Repeat

     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(PereozenkaFile);
      Seek(PereozenkaFile,Pos1);
     Until (Lock(PereozenkaFile,FilePos(PereozenkaFile)*SizeOf(PereozenkaType),SizeOf(PereozenkaType)*5));

     Pos1:=FileSize(PereozenkaFile);

     If FilePos(PereozenkaFile)<>Pos1{FileSize(PereozenkaFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        Pause(1);
        UnLock(PereozenkaFile,(FilePos(PereozenkaFile))*SizeOf(PereozenkaType),SizeOf(PereozenkaType)*5);
       Until (DosError=0);
      End;

    Until (FilePos(PereozenkaFile)=Pos1{FileSize(PereozenkaFile)});


     If (({FileSize(PereozenkaFile)}Pos1+1)<>(StrToInt(L^.Dat.Document))) Then
     Begin
      ChangeNumer:=True;
   L^.Dat.Document:=IntToStr({FileSize(PereozenkaFile)}Pos1+1,CDocNumer);
      DelSpace(L^.Dat.Document);
     End;

     Write(PereozenkaFile,L^.DAt);
     Seek(PereozenkaFile,FilePos(PereozenkaFile)-1);
     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле переоценок..');

     Repeat {деблокируем участок записи}
      Pause(1);
      UnLock(PereozenkaFile,(FilePos(PereozenkaFile))*SizeOf(PereozenkaType),
         SizeOf(PereozenkaType)*5);
     {
      If DosError<>0 Then
       MessageBox(#3+'DosError='+IntToStr(DosError,3),Nil,
          mfError+mfCancelButton);
     }
     Until (DosError=0);
     Close(PereozenkaFile);
     LockAndWritePereozenka:=True;
     NoInfoMsg;

     If ChangeNumer Then
     Begin
      If (ShowNumer=1) Then
       Begin
       MessageBox(#3+'За время формирования Вами переоценки проведены другие '+
          'переоценки. Присваиваю документу новый номер: '+L^.Dat.Document+'!',
                Nil,mfInformation+mfCancelButton);
       End;
     End;

End;

Function LockAndWriteRewisia( Var L:PRewisiaType) : Boolean;
Var RewisiaFile : File of RewisiaType;
     c : Byte;
     ChangeNumer : Boolean;
     Pos1 : LongInt;
Begin
 LockAndWriteRewisia:=False;
 Assign(RewisiaFile,Path.ToRewisia+L^.Dat.DateC+'.rwz');
 c:=IOResult;
{$I-}
 Reset(RewisiaFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox('Файл '+L^.Dat.DateC+'.rwz не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil, mfConfirmation + mfOkCancel)=cmOk Then
     Begin
{      c:=IOResult;
      Reset(RewisiaFile);
      c:=IOResult;
      If c<>0 Then Rewrite(RewisiaFile);}
      If Not(CreatToDayF(DocRewisia,L^.Dat.DateC)) Then Exit;
      Reset(RewisiaFile);
      c:=IOResult;
     End
    Else
     Begin
      Exit;
     End;
 End;
 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу '+L^.Dat.DateC+'.rwz!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;

     {запись прихода для случая формирования накладной}

     DInfoNetMsg('Сохраняю документ ревизии N '+L^.Dat.Document+' от '+L^.Dat.Datec+'...');

    ChangeNumer:=False;
    Repeat

     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(RewisiaFile);
      Seek(RewisiaFile,Pos1);
     Until (Lock(RewisiaFile,FilePos(RewisiaFile)*SizeOf(RewisiaType),SizeOf(RewisiaType)*5));

      Pos1:=FileSize(RewisiaFile);

     If FilePos(RewisiaFile)<>Pos1{FileSize(RewisiaFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        Pause(1);
        UnLock(RewisiaFile,(FilePos(RewisiaFile))*SizeOf(RewisiaType),SizeOf(RewisiaType)*5);
       Until (DosError=0);
      End;

    Until (FilePos(RewisiaFile)=Pos1{FileSize(RewisiaFile)});

     L^.Dat.Locked:=False;

     If (({FileSize(RewisiaFile)}Pos1+1)<>(StrToInt(L^.Dat.Document))) Then
     Begin
      ChangeNumer:=True;
   L^.Dat.Document:=IntToStr({FileSize(RewisiaFile)}Pos1+1,CDocNumer);
      DelSpace(L^.Dat.Document);
     End;

     Write(RewisiaFile,L^.DAt);
     Seek(RewisiaFile,FilePos(RewisiaFile)-1);
     NoNetInfoMsg;

     DInfoMsg('Деблокирую запись в файле ревизии...');

     Repeat {деблокируем участок записи}
      Pause(1);
      UnLock(RewisiaFile,(FilePos(RewisiaFile))*SizeOf(RewisiaType),
         SizeOf(RewisiaType)*5);
     {
      If DosError<>0 Then
       MessageBox(#3+'DosError='+IntToStr(DosError,3),Nil,
          mfError+mfCancelButton);
     }
     Until (DosError=0);
     Close(RewisiaFile);

     LockAndWriteRewisia:=True;
     NoInfoMsg;

     If ChangeNumer Then
     Begin
      If (ShowNumer=1) Then
       Begin
       MessageBox(#3+'За время формирования Вами акта ревизии проведены другие '+
          'ревизии. Присваиваю документу новый номер: '+L^.Dat.Document+'!',
                Nil,mfInformation+mfCancelButton);
       End;
     End;
End;

Function LockRewisia(As : DocumentEdit;Var E:PRewisiaType):Word;
Var C : Byte;
    Find : Boolean;
    RewisiaFile : RewisiaFileType;
    Code : InTeger;
    Pos : LongInt;
Begin
  LockRewisia:=4;
  C:=IOResult;
  Assign(RewisiaFile,Path.ToRewisia+As.D+'.rwz');
  Reset(RewisiaFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия файла ревизииа за '+As.D+'!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    C:=IOResult;
    Lockrewisia:=4;
    Exit;
   End;

   Seek(RewisiaFile,0);

   DelSpace(As.EditPosition);
   DelSpace(As.D);
   DelZerro(As.EditPosition);
   As.EditPosition:=ClearChar(As.EditPosition);
   Find:=False;

   {цикл поиска накладной}
   While Not(eof(RewisiaFile)) And Not(Find) Do
    Begin
     {
     Repeat
     Pause(1);
     Until Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType));
     }
     ReadRewisia(RewisiaFile,E);
     {
     Repeat
      UnLock(PrihodFile,(FilePos(PrihodFile)-1)*SizeOf(PrihodType),SizeOf(PrihodType));
     Until (DosError=0);
     }
     DelSpace(E^.DAt.Document);
     DelZerro(E^.Dat.Document);
     If (E^.DAt.Document=As.EditPosition) And (E^.DAt.DateC=As.D) Then Find:=True;
    End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      LockRewisia:=2;
      Close(RewisiaFile);
      MessageBox(#3^M+#3'Документ ревизии N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}

   DInfoNetMsg('Блокирую документ ревизии N '+E^.Dat.Document+' от '+E^.Dat.DateC+'...');
   LockRewisia:=3;
   Seek(RewisiaFile,FilePos(RewisiaFile)-1);

   Repeat
   Pause(1);
   Until Lock(RewisiaFile,FilePos(RewisiaFile)*SizeOf(RewisiaType),SizeOf(RewisiaType));
   Read(RewisiaFile,E^.Dat);

   {если документ уже заблокирован}
   If (E^.Dat.Locked) Then
    Begin
     NoNetInfoMsg;
     Lockrewisia:=3;
     {снятие предварительной блокировки}
     Seek(RewisiaFile,FilePos(RewisiaFile)-1);
     Repeat
      UnLock(RewisiaFile,FilePos(RewisiaFile)*SizeOf(RewisiaType),SizeOf(RewisiaType))
     Until Doserror=0;
     Close(RewisiaFile);
     Exit;
    End;

   {проведение вторичной блокировки}
{$IFDEF NetVersion}
   E^.DAt.Locked:=True;
{$ENDIF}

   Seek(RewisiaFile,FilePos(RewisiaFile)-1);
   Write(RewisiaFile,E^.DAt);
   Seek(RewisiaFile,FilePos(RewisiaFile)-1);

   Repeat
    Pause(1);
    UnLock(RewisiaFile,FilePos(RewisiaFile)*SizeOf(RewisiaType),SizeOf(RewisiaType));
   Until Doserror=0;

   LockRewisia:=0;
   NoNetInfoMsg;
   Close(RewisiaFile);
End;

Function UnLockRewisia(Doc:ArtikulStr;DD: TDateString):Word;
Var C : Byte;
    Find : Boolean;
    RewisiaFile : RewisiaFileType;
    Test : PRewisiaType;

Begin
  UnLockRewisia:=3;
  C:=IOResult;
  Assign(RewisiaFile,Path.Torewisia+DD+'.rwz');
  Reset(RewisiaFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла ревизии за '+DD+'!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    UnLockRewisia:=3;
    C:=IOResult;
    Exit;
   End;

   Seek(RewisiaFile,0);

   DelSpace(Doc);
   DelSpace(DD);
   DelZerro(Doc);
   Find:=False;

   New(Test,Init);
   {цикл поиска накладной}
   While Not(eof(RewisiaFile)) And Not(Find) Do
    Begin
     {
     Repeat
     Pause(1);
     Until Lock(RewisiaFile,FilePos(RewisiaFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     }
     ReadRewisia(RewisiaFile,Test);
     {
     Repeat
      UnLock(RewisiaFile,(FilePos(RewisiaFile)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     }

     DelSpace(Test^.DAt.Document);
     DelZerro(Test^.Dat.Document);
     If (Test^.DAt.Document=Doc) And (TEST^.DAt.DateC=DD) Then Find:=True;
    End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      Dispose(test,Done);
      UnLockRewisia:=2;
      Close(RewisiaFile);
      MessageBox(#3^M+#3'Документ ревизии N '+ Doc+' в базе за '+DD+' не найден!',
         Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}

   DInfoNetMsg('Деблокирую документ ревизии N '+Doc+' от '+DD+'...');
   UnLockRewisia:=1;
   Seek(RewisiaFile,FilePos(RewisiaFile)-1);

 If Lock(RewisiaFile,FilePos(RewisiaFile)*SizeOf(RewisiaType),SizeOf(RewisiaType)) Then
 Begin
   Read(RewisiaFile,Test^.Dat);
   {проведение вторичной блокировки}
   Test^.DAt.Locked:=False;
   Seek(RewisiaFile,FilePos(RewisiaFile)-1);
   Write(RewisiaFile,Test^.DAt);
   Seek(RewisiaFile,FilePos(RewisiaFile)-1);
   Repeat
    UnLock(RewisiaFile,FilePos(RewisiaFile)*SizeOf(RewisiaType),SizeOf(RewisiaType))
   Until Doserror=0;
   UnLockRewisia:=0;
   NoNetInfoMsg;
   Close(RewisiaFile);
   Dispose(Test,Done);
 End
   Else
      Begin
       NoNetInfoMsg;
       UnLockRewisia:=1;
       Close(RewisiaFile);
       Dispose(Test,Done);
      End;
End;





Function LockAndWriteRewisiaOutEdit(Var L:PRewisiaType):Boolean;
Var RewisiaFile : RewisiaFileType;
    c : Byte;
    ChangeNumer,Find : Boolean;
    Test : PRewisiaType;
    Pos1,pos2,Pos,Code : LongInt;
Begin
 LockAndWriteRewisiaOutEdit:=False;
 Assign(RewisiaFile,Path.ToRewisia+L^.Dat.DateC+'.rwz');
 c:=IOResult;
{$I-}
 Reset(RewisiaFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox('Файл '+L^.Dat.DateC+'.rwz не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil,
        mfConfirmation + mfOkCancel)=cmOk  Then
     Begin
{     c:=IOResult;
      Reset(RewisiaFile);
      c:=IOResult;
      If c<>0 Then Rewrite(RewisiaFile);}
      If Not(CreatToDayF(DocRewisia,L^.Dat.DateC)) Then Exit;
      Reset(RewisiaFile);
      c:=IOResult;
     End
    Else
     Begin
      Exit;
     End;
 End;
 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу '+L^.Dat.DateC+'.rwz!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;

{если открытие прошло нормально}
     {создаем новый экземпляр прихода}
     New(test,Init);
     Find := False;
     DelSPace(L^.DAt.Document);
     DelSPace(L^.DAt.DAteC);
     DelSPace(L^.DAt.SkladKod);
     {цикл поиска исходного документа в файле}
     While Not(Eof(RewisiaFile)) And Not(Find) Do
      Begin
     ReadRewisia(RewisiaFile,Test);
       DelSpace(Test^.Dat.Document);
       DelSpace(Test^.Dat.DateC);
       DelSpace(Test^.Dat.SkladKod);
       If (Test^.Dat.Document=L^.DAt.Document) And
          (Test^.Dat.DateC=L^.DAt.DateC) And
          (Test^.Dat.SkladKod=L^.DAt.SkladKod) Then Find:=True;
      End;
      Dispose(Test,Done);

     {если документ не найден тогда выходим с сообщением}
     If Not(Find) Then
      Begin
       Close(RewisiaFile);
       MessageBox(#3^M+#3'Документ ревизии N '+ L^.Dat.Document+' в базе за '+L^.DAt.DAteC+' не найден!',Nil,
          mfError+mfCancelButton);
       Exit;
      End;

     DInfoNetMsg('Изменяю документ ревизии N '+L^.Dat.Document+' от '+L^.Dat.Datec+'...');
     {если мы нашли документ тогда блокируем его и записываем}
     Seek(RewisiaFile,FilePos(RewisiaFile)-1);
     {блокировка}
     Repeat
      Pause(1);
     Until (Lock(RewisiaFile,FilePos(RewisiaFile)*SizeOf(RewisiaType),SizeOf(RewisiaType)));
     {запись}

{$IFDEF NetVersion}
     L^.Dat.Locked:=False;
{$ENDIF}

     Write(RewisiaFile,L^.DAt);
     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле ревизии...');
     {снятие блокировки}
     Seek(RewisiaFile,FilePos(RewisiaFile)-1);
     Repeat
      Pause(1);
      UnLock(RewisiaFile,FilePos(RewisiaFile)*SizeOf(RewisiaType),SizeOf(RewisiaType));
     Until (DosError=0);
     Close(RewisiaFile);
     LockAndWriteRewisiaOutEdit:=True;
     NoInfoMsg;
End;





Function LockAndWriteMarket(Var L:PSuperMArketType):Boolean;
{Параметр Mode указывает что это поступление товара на склад или
формирование и корректировка}
Var MarketFile : MarketFileType;
    c : Byte;
    Find : Boolean;
    txt : File;
    Test : PSuperMarketType;
    m,Code,Pos1,Pos2:LongInt;
    ChangeNumer : Boolean;
Begin
 LockAndWriteMarket:=False;
 Assign(MarketFile,Path.ToMarket+L^.Dat.DateC+'.mrk');
 c:=IOResult;
{$I-}
 Reset(MarketFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox(^M+'Файл '+L^.Dat.DateC+'.mrk не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil,
        mfConfirmation + mfOkCancel)=cmOk  Then
     Begin
      If Not(CreatToDayF(DocMArket,L^.Dat.DateC)) Then Exit;
      Reset(MarketFile);
      c:=IOResult;
     End
    Else
     Begin
      Exit;
     End;
 End;
 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу '+L^.Dat.DateC+'.mrk!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;
{если открытие прошло нормально}
   If Status=DocEdit Then
    Begin
     {создаем новый экземпляр прихода}
     New(test,Init);
     Find := False;
     DelSPace(L^.DAt.Document);
     DelSPace(L^.DAt.DAteC);
     DelSPace(L^.DAt.SkladKod);
     {цикл поиска исходного документа в файле}
     While Not(Eof(MarketFile)) And Not(Find) Do
      Begin
    {Repeat
     Pause(1);
     Until Lock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));}
     ReadMarket(MarketFile,Test);
    {Repeat
      UnLock(MarketFile,(FilePos(MarketFile)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);}

       DelSpace(Test^.Dat.Document);
       DelSpace(Test^.Dat.DateC);
       DelSpace(Test^.Dat.SkladKod);
       If (Test^.Dat.Document=L^.DAt.Document) And
          (Test^.Dat.Active)And
          (Test^.Dat.DateC=L^.DAt.DateC) And
          (Test^.Dat.SkladKod=L^.DAt.SkladKod) Then Find:=True;
      End;
      Dispose(Test,Done);

     {если документ не найден тогда выходим с сообщением}
     If Not(Find) Then
      Begin
       Close(MarketFile);
       MessageBox(#3^M+#3'Документ продажи N '+ L^.Dat.Document+' в базе за '+L^.DAt.DAteC+' не найден!',Nil,
          mfError+mfCancelButton);
       Exit;
      End;

     DInfoNetMsg('Сохраняю измененный документ продажи N '+L^.Dat.Document+' от '+L^.Dat.Datec+'...');
     {если мы нашли документ тогда блокируем его и записываем}
     Seek(MarketFile,FilePos(MarketFile)-1);

     {блокировка}
     Repeat
     Pause(1);
     Until (Lock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType)));
     {запись}

{$IFDEF NetVersion}
     L^.Dat.Locked:=True;
{$ENDIF}

     Write(MarketFile,L^.DAt);
     {снятие блокировки}
     Seek(MarketFile,FilePos(MarketFile)-1);
     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле продажи...');
     Repeat
      Pause(1);
      UnLock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     Close(MarketFile);
     LockAndWriteMarket:=True;
     NoInfoMsg;
    End
   Else
    Begin
     {запись прихода для случая формирования накладной}

     If Not(FindPARAM('/FAST')) Then
  Begin
     DInfoNetMsg('Жду очереди на запись документ продажи N '+
     L^.Dat.Document+' от '+L^.Dat.Datec+'...');

     Assign(txt,Path.ToMarket+'works.txt');
     m:=IOResult;

     Repeat
     Delay(150);
     Rewrite(txt);
     m:=IOResult;
     Until m=0;
  End;

     DInfoNetMsg('Сохраняю новый документ продажи N '+
     L^.Dat.Document+' от '+L^.Dat.Datec+'...');




     ChangeNumer:=False;
    Repeat

     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(MarketFile);
      Seek(MarketFile,Pos1{FileSize(MarketFile)});
     Until (Lock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType)*5));

     Pos1:=FileSize(MarketFile);

     If FilePos(MarketFile)<>Pos1{FileSize(MarketFile)} Then
      Begin
{
       MessageBox(#3+'Изменился FileSize необходимо повторить блокировку'^M+
       IntToStr(FilePos(MarketFile),CKol)+' '+IntToStr(FileSize(MarketFile),CKol),Nil,
    mfInformation+mfCancelButton);}

       Repeat {деблокируем участок записи}
        UnLock(MarketFile,(FilePos(MarketFile))*SizeOf(SuperMarketType),SizeOf(SuperMarketType)*5);
       Until (DosError=0);
      End;
    Until (FilePos(MarketFile)=Pos1{FileSize(MarketFile)});

{$IFDEF NetVersion}
     L^.Dat.Locked:=True;
{$ENDIF}


     If ({(FileSize(MarketFile)+1)}(Pos1+1)<>(StrToInt(L^.Dat.Document))) Then
     Begin
      ChangeNumer:=True;
   L^.Dat.Document:=IntToStr({FileSize(MArketFile)}Pos1+1,CDocNumer);
      DelSpace(L^.Dat.Document);
     End;

     Write(MarketFile,L^.DAt);
     Seek(MarketFile,FilePos(MarketFile)-1);
     NonetInfoMsg;

     DInfoMsg('Деблокирую запись в файле продаж...');
     Repeat {деблокируем участок записи}
      UnLock(MarketFile,(FilePos(MarketFile))*SizeOf(SuperMarketType),
      SizeOf(SuperMarketType)*5);
     {If DosError<>0 Then
       MessageBox(#3+'DosError='+IntToStr(DosError,3),Nil,
          mfError+mfCancelButton);}
     Until (DosError=0);

     Close(MarketFile);
     LockAndWriteMarket:=True;
     NoInfoMsg;


     If Not(FindPARAM('/FAST')) Then
  Begin
     m:=IOResult;
     Close(txt);
     m:=IOResult;
     Erase(txt);
     m:=IOResult;
  End;


     If ChangeNumer Then
     Begin
      If (ShowNumer=1) Then
       Begin
       MessageBox(#3+'За время формирования Вами документа проведены другие '+
          'продажи. Присваиваю документу новый номер: '+L^.Dat.Document+'!',
           Nil,mfInformation+mfCancelButton);
       End;
     End;
    End;
c:=IOResult;
End;



Function LockMArket(As : DocumentEdit;Var E:PSuperMarketType):Word;
{функция возвращает 0 если все прошло ок
0 все ок
1 если документ не найден
2 если не удалось заблокировать накладную
4 если по документу началась оплата
5 если это документ вторичной консигнации
3 ошибка сетевого открытия файла продаж}
Var C : Byte;
    Find : Boolean;
    MarketFile : MarketFileType;
Begin
  LockMarket:=3;
  C:=IOResult;
  Assign(MarketFile,Path.ToMarket+As.D+'.mrk');
  Reset(MarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла продаж за '+As.D+'!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    C:=IOResult;
    LockMarket:=3;
    Exit;
   End;

   Seek(MarketFile,0);

   DelSpace(As.EditPosition);
   DelSpace(As.D);
   DelZerro(As.EditPosition);
   As.EditPosition:=ClearChar(As.EditPosition);
   Find:=False;

   {цикл поиска накладной}
   While Not(eof(MarketFile)) And Not(Find) Do
    Begin
     {
     Repeat
     Pause(1);
     Until Lock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMarket(MarketFile,E);

     {
     Repeat
      UnLock(MarketFile,(FilePos(MarketFile)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
     DelSpace(E^.DAt.Document);
     DelZerro(E^.Dat.Document);
     If (E^.DAt.Document=As.EditPosition) And (E^.DAt.DateC=As.D)
  And (StrToInt(E^.DAt.SkladKod)=StrToInt(Rek.Kod))
        And (E^.Dat.Active) Then Find:=True;
    End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      LockMarket:=1;
      Close(MarketFile);
      MessageBox(#3^M+#3'Документ продажи N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}
   DInfoNetMsg('Блокирую документ продажи N '+E^.Dat.Document+' от '+E^.Dat.DateC+'...');
   LockMarket:=2;
   Seek(MarketFile,FilePos(MarketFile)-1);
   Repeat
   Pause(1);
   Until Lock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
   Read(MarketFile,E^.Dat);

   {если документ уже заблокирован}
   If (E^.Dat.Locked) Then
    Begin
     NoNetInfoMsg;
     LockMarket:=2;
     {снятие предварительной блокировки}
     Seek(MarketFile,FilePos(MarketFile)-1);
     Repeat
      UnLock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType))
     Until Doserror=0;
     Close(MarketFile);
     Exit;
    End;

    If (E^.Dat.Realiz) And (E^.Dat.DocSelector in [5..8])Then
    Begin
        If TestPayMent(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC) Then
        Begin
        MessageBox(#3'По документу консигнации N '+As.EditPosition+''^M+
        #3'началась оплата!'^M+#3'Документ корректироваться не может!',Nil, mfWarning+mfCancelButton);
        NoNetInfoMsg;
        LockMarket:=4;
        {снятие предварительной блокировки}
        Seek(MarketFile,FilePos(MarketFile)-1);
        Repeat
         UnLock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMArketType),SizeOf(SuperMarketType))
        Until Doserror=0;
        Close(MarketFile);
        Exit;
        End;
    End;

    If (E^.Dat.Realiz) And not(E^.Dat.DocSelector in [5..8])Then
    Begin
        MessageBox(#3'Документ N '+As.EditPosition+' выведен после оплаты '^M+
        #3'консигнации!'^M+#3'Документ корректироваться не может!',Nil, mfWarning+mfCancelButton);
        NoNetInfoMsg;
        LockMarket:=5;
        {снятие предварительной блокировки}
        Seek(MarketFile,FilePos(MarketFile)-1);
        Repeat
         UnLock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMArketType),SizeOf(SuperMarketType))
        Until Doserror=0;
        Close(MarketFile);
        Exit;
    End;


   {проведение вторичной блокировки}
{$IFDEF NetVersion}
   E^.DAt.Locked:=True;
{$ENDIF}

   Seek(MarketFile,FilePos(MarketFile)-1);
   Write(MarketFile,E^.DAt);
   Seek(MarketFile,FilePos(MarketFile)-1);
   Repeat
    UnLock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType))
   Until Doserror=0;
   LockMarket:=0;
   NoNetInfoMsg;
   Close(MarketFile);
End;


Function UnLockMArket(Doc:ArtikulStr;DD: TDateString):Word;
{
 0 деблокировка прошла нормально
 1 не смог деблокировать
 2 документ не найден
 3 ошибка сетевого открытия
}

{
 0 деблокировка прошла нормально
 2 документ не найден
 1 не смог деблокировать
 3 ошибка сетевого открытия
}


Var C : Byte;
    Find : Boolean;
    MarketFile : MarketFileType;
    Test : PSuperMarketType;

Begin
  UnlockMArket:=3;
  C:=IOResult;
  Assign(MarketFile,Path.ToMarket+DD+'.mrk');
  Reset(MarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла продаж за '+DD+'!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    UnlockMArket:=3;
    C:=IOResult;
    Exit;
   End;

   Seek(MarketFile,0);

   DelSpace(Doc);
   DelSpace(DD);
   DelZerro(Doc);
   Find:=False;

   New(Test,Init);
   {цикл поиска накладной}
   While Not(eof(MarketFile)) And Not(Find) Do
    Begin
     {
     Repeat
     Pause(1);
     Until Lock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMarket(MarketFile,Test);
     {
     Repeat
      UnLock(MarketFile,(FilePos(MarketFile)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
     DelSpace(Test^.DAt.Document);
     DelZerro(Test^.Dat.Document);
     If (Test^.DAt.Document=Doc) And (TEST^.DAt.DateC=DD)
           And (Test^.Dat.Active) Then Find:=True;
    End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      Dispose(test,Done);
      UnlockMArket:=2;
      Close(MarketFile);
      MessageBox(#3^M+#3'Документ продажи N '+ Doc+' в базе за '+DD+' не найден!',
         Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}

   DInfoNetMsg('Деблокирую документ продажи N '+Doc+' от '+DD+'...');
   UnlockMArket:=1;
   Seek(MarketFile,FilePos(MarketFile)-1);

 If Lock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType)) Then
 Begin
   Read(MarketFile,Test^.Dat);
   {проведение вторичной блокировки}
   Test^.DAt.Locked:=False;
   Seek(MarketFile,FilePos(MarketFile)-1);
   Write(MarketFile,Test^.DAt);
   Seek(MarketFile,FilePos(MarketFile)-1);
   Repeat
   UnLock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType))
   Until Doserror=0;
   UnlockMArket:=0;
   NoNetInfoMsg;
   Close(MarketFile);
   Dispose(Test,Done);
 End
   Else
      Begin
       NoNetInfoMsg;
       UnlockMArket:=1;
       Close(MarketFile);
       Dispose(Test,Done);
      End;
End;

Function Activ_DeActiv_MArket(Doc:ArtikulStr;DD: TDateString;Mode:Boolean):Boolean;
Var C : Byte;
    LockOk,Find : Boolean;
    MarketFile : MarketFileType;
    Test : PSuperMarketType;
Begin
  Activ_DeActiv_MArket:=False;
  C:=IOResult;
  Assign(MarketFile,Path.ToMarket+DD+'.mrk');
  Reset(MarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла продаж за '+DD+'!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    C:=IOResult;
    Exit;
   End;
   Seek(MarketFile,0);
   DelSpace(Doc);
   DelSpace(DD);
   DelZerro(Doc);
   Find:=False;

   New(Test,Init);
   {цикл поиска накладной}
   While Not(eof(MarketFile)) And Not(Find) Do
    Begin
     {
     Repeat
     Pause(1);
     Until Lock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMarket(MarketFile,Test);
     {
     Repeat
      UnLock(MarketFile,(FilePos(MarketFile)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
     DelSpace(Test^.DAt.Document);
     DelZerro(Test^.Dat.Document);
     If (Test^.DAt.Document=Doc) And (TEST^.DAt.DateC=DD) Then Find:=True;
    End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      Dispose(test,Done);
      Close(MarketFile);
      MessageBox(#3^M+#3'Документ продажи N '+ Doc+' в базе за '+DD+' не найден!',
         Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}

   If Mode Then
   DInfoNetMsg('Ативизирую документ продажи N '+Doc+' от '+DD+'...')
   Else
   DInfoNetMsg('Деактивизирую документ продажи N '+Doc+' от '+DD+'...');

   LockOk:=False;
   Seek(MarketFile,FilePos(MarketFile)-1);

{цикл блокировки}
   Repeat
    Pause(1);
    If Lock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType)) Then
    Begin
     Read(MarketFile,Test^.Dat);
     LockOk:=Not(Test^.DAt.Locked);
     Seek(MarketFile,FilePos(MarketFile)-1);
     If Not(LockOk) Then
     Repeat
      UnLock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType))
     Until Doserror=0;
    End;
   Until LockOK;

   Test^.DAt.Active:=Mode;
   Write(MarketFile,Test^.DAt);
   Seek(MarketFile,FilePos(MarketFile)-1);

   Repeat
    UnLock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType))
   Until Doserror=0;
   Activ_DeActiv_MArket:=True;
   Close(MarketFile);
   Dispose(Test,Done);
   NoNetInfoMsg;
End;

Function LockAllPosition(Var TempBox,LockBox:PBox):Boolean;
Var l,Count : Word;
    Operator : Strname;
    Event : TEvent;
    A : ArtikulStr;

Begin
LockAllPosition:=False;
If (TempBox^.List^.Count>0) Then
Begin
For Count:=0 To (TempBox^.List^.Count-1) Do
 Begin
  a:=Copy(TempBox^.GetText(Count,TempBox^.List^.Count),1+1,CArtikul);
  If Not(SetNameLock(a,Operator)) Then
   Begin
    Beep;
    DInfoMsg('Позиция ['+A+'] используется'+Operator+'. Не могу заблокировать позицию!');
    Application^.ClearEvent(Event);
    Application^.ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    until (Event.What <> evNothing) And (Event.Command<>cmMenu);
    NoInfoMsg;
    Application^.ClearEvent(Event);
    Exit;
   End
  Else
   begin
     LockBox^.List^.Insert(NewStr('│'+A));
     LockBox^.SetRange(LockBox^.List^.Count);
   end;
 End;
End;
LockAllPosition:=True;
End;


Procedure UnLockAllPosition(LockBox:PBox);
Var L : Word;
    a : ArtikulStr;
    Operator : AllStr;
Begin
If (LockBox^.List^.Count>0) Then
Begin
For L:=0 To (LockBox^.List^.Count-1) Do
 Begin
  a:=Copy(LockBox^.GetText(l,LockBox^.List^.Count),1+1,CArtikul);
  Repeat
  Until SetNameUnLock(a);
 End;
End;
End;


Function SaveRealizasToClientFile(E:PSuperMarketType;sf:Boolean;Realiz: boolean):Boolean;
Var l : PRealizasiaType;
    RealFile : File Of RealizasiaType;
    i : Byte;
Begin
 SaveRealizasToClientFile:=False;
 Assign(RealFile,Path.ToDolg+E^.Dat.ClientKod+'.dlg');
 i:=IOResult;
 Reset(RealFile);
 i:=IOResult;
 If i <> 0 Then
  Begin
   If MessageBox(#3'Файл задолженности клиента '^M+#3+Path.ToDolg+E^.Dat.ClientKod+'.dlg не найден!'^M+
   #3'Создать файл заново?'+
   +' Код:'+IntToStr(i,3),Nil,mfWarning+mfOkCancel)=cmOk Then
    Begin
        i:=IOResult;
        Rewrite(RealFile);
        i:=IOResult;
        If i<>0 Then
         Begin
          MessageBox(^m+#3'Не могу создать файл '^M+
          #3+Path.ToDolg+E^.Dat.ClientKod+'.dlg',Nil,mfError+mfCancelButton);
          Exit;
         End;
    End
    Else Exit;
  End;
  New(l,Init);
  Seek(RealFile,FileSize(RealFile));

  MArketToDolg(E,L);

  {L^.Dat.Market:=E^.Dat;}

  L^.Dat.Dolg:=StrToReal(E^.Dat.SummaZ);
  L^.Dat.Full:=False;
  L^.Dat.PayMent:=False;
  L^.Dat.Sf:=Sf;
  L^.Dat.Realiz:=Realiz;
  Write(RealFile,L^.Dat);
  Close(RealFile);
  Dispose(L,Done);
  SaveRealizasToClientFile:=True;
End;


Function  TestDolgClient(S:ArtikulStr):Boolean;
Var fr : File Of RealizasiaType;
    ss : AllStr;
    Er : PRealizasiaType;
     c : Word;
 t2,t1 : LongInt;
Begin
 TestDolgClient:=True;
 Assign(fr,Path.ToDolg+s+'.dlg');
 c:=IOResult;
 Reset(fr);
 c:=IOResult;
 If c<>0 Then Exit;
 New(Er,Init);
 DInfo('Проверяю долги...');
 While Not(Eof(fr)) Do
  Begin
   Read(Fr,Er^.Dat);
   t2:=DateStringToDate(DAteMask,FDate);
   t1:=Er^.Dat.MArket.Srok;

   if not Er^.Dat.Realiz then
   If (Er^.Dat.MArket.Active) And Not(Er^.Dat.Full)And((Status=DocNormal)And(Er^.Dat.Dolg<>0)And((t2-t1)>0))
   Or ((Status=DocEdit)And (Er^.Dat.MArket.Active)And  Not(Er^.Dat.Full)And(Er^.Dat.Dolg<>0)And((t2-t1)>0)And
   (TekDate<>Er^.Dat.Market.DateC)And(ClearChar(Er^.Dat.Market.Document)<>ClearChar(Assistent.EditPosition))) Then
   Begin
    {
    MemCC(IntToStr(t2,CKOl)+'-'+IntToStr(t1,CKOl)+'-'+
    RealToStr(Er^.Dat.Dolg,CIZena,CMAntissa)+'-'+Er^.Dat.Market.Document+^M+
    FDate+'-'+DateToDateString(DAteMask,Er^.Dat.MArket.Srok));
    }
    TestDolgClient:=False;
    Break;
   End
  End;
 NoInfo;
{
    Begin
     If Er^.Dat.Market.Active Then SS:='True'
     Else SS:='False';
     MemCC(ss+
     RealToStr(Er^.Dat.Dolg,15,2)+';Tek:'+IntToStr(t2,CKOl)+'-Srok:'+IntToStr(t1,CKOl));
    End;
}
 Close(Fr);
 Dispose(Er,Done);
End;


Function  TestDolgClientNew(S:ArtikulStr):Boolean;
Var fr : File Of RealizasiaType;
    Er : PRealizasiaType;
     c : Word;
 t2,t1 : LongInt;
Begin
 TestDolgClientNew:=True;
 Assign(fr,Path.ToDolg+s+'.dlg');
 c:=IOResult;
 Reset(fr);
 c:=IOResult;
 If c<>0 Then Exit;
 New(Er,Init);
 DInfo('Проверяю долги...');
 While Not(Eof(fr)) Do
  Begin
   Read(Fr,Er^.Dat);
   t2:=DateStringToDate(DAteMask,FDate);
   t1:=Er^.Dat.MArket.Srok;
   if not Er^.Dat.Realiz then
   If (Er^.Dat.MArket.Active)
   And Not(Er^.Dat.Full)
   And((Status=DocNormal)And(Er^.Dat.Dolg<>0)And((t2-t1)>=0))
{
   Or ((Status=DocEdit)And(Er^.Dat.Dolg<>0)And((t2-t1)>0)And
   (TekDate<>Er^.Dat.Market.DateC)And(ClearChar(Er^.Dat.Market.Document)<>ClearChar(Assistent.EditPosition)))}
   Then
   Begin
    MemCC(IntToStr(t2,CKOl)+'-'+IntToStr(t1,CKOl));
    TestDolgClientNew:=False;
    Break;
   End;
  End;
 NoInfo;
 Close(Fr);
 Dispose(Er,Done);
End;

Function  TestDolgClientNew1(S:ArtikulStr):Boolean;
Var fr : File Of RealizasiaType;
    Er : PRealizasiaType;
     c : Word;
 t2,t1 : LongInt;
Begin
 TestDolgClientNew1:=True;
 Assign(fr,Path.ToDolg+s+'.dlg');
 c:=IOResult;
 Reset(fr);
 c:=IOResult;
 If c<>0 Then Exit;
 New(Er,Init);
 DInfo('Проверяю долги...');
 While Not(Eof(fr)) Do
  Begin
   Read(Fr,Er^.Dat);
   t2:=DateStringToDate(DAteMask,FDate);
   t1:=Er^.Dat.MArket.Srok;

   if not Er^.Dat.Realiz then
   If (Er^.Dat.MArket.Active)
   And Not(Er^.Dat.Full)
   And((Status=DocNormal)And(Er^.Dat.Dolg<>0)And((t2-t1)>=0)AND(t1=1))
{
   Or ((Status=DocEdit)And(Er^.Dat.Dolg<>0)And((t2-t1)>0)And
   (TekDate<>Er^.Dat.Market.DateC)And(ClearChar(Er^.Dat.Market.Document)<>ClearChar(Assistent.EditPosition)))}
   Then
   Begin
    MemCC(IntToStr(t2,CKOl)+'-'+IntToStr(t1,CKOl));
    TestDolgClientNew1:=False;
    Break;
   End;
  End;
 NoInfo;
 Close(Fr);
 Dispose(Er,Done);
End;



function ReturnDay (i:Real;L:Boolean) : LongInt;
var
   Dlg : PDialog;
   R : TRect;
   ControlF,ControlSF : PView;
   res : Word;
var
  DataRec : record
  c : LongInt;
  end;
begin
l:=False;
(*
If Status=DocEdit Then
 Begin
  If PrevMarket^.Dat.DocSelector=5 Then
  If TestSF(PrevMarket^.Dat.ClientKod,PrevMarket^.Dat.Document,PrevMarket^.Dat.DateC){,Sf} Then DataRec.sf:=1;
 End;
*)
R.Assign(27, 9, 53, 14);
New(Dlg, Init(R, 'Срок консигнации'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E002;

R.Assign(19, 2, 23, 3);
ControlF := New(PInputLong, Init(R, 2, 1, 30, 0));
Dlg^.Insert(ControlF);

  R.Assign(2, 2, 19, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Количество дней:', ControlF)));

{R.Assign(1, 4, 20, 5);
ControlSf := New(PCheckboxes, Init(R,
  NewSItem('Выдать со С/Ф', Nil)));
ControlSf^.Options := ControlSf^.Options or ofCenterX;}

If i > 10000.00 Then Datarec.c:=7
Else Datarec.c:=7;
If i <= 10000.00  Then Datarec.c:=6;
If i <= 7000.00  Then Datarec.c:=5;
If i <= 5000.00  Then Datarec.c:=4;
If i <= 3000.00  Then Datarec.c:=3;

Dlg^.SetData(Datarec);
Dlg^.SelectNext(False);
res:=Desktop^.ExecView(Dlg);
If res <> cmCancel Then
        Begin
        Dlg^.GetData(Datarec);
{        DateMask:=InternationalDate(False,True);}
        DataRec.c:=DateStringToDate(DAteMask,TekDate)+Datarec.c;
        {DateToDateString(DateMask,c);}

        ReturnDay:=Datarec.c;
        {If DataRec.Sf=1 Then l:=True;}
        End
        Else ReturnDay:=0;

  Dispose(ControlF,Done);
{ Dispose(ControlSF,Done);}
  Dispose(Dlg,Done);
end;

Function SaveToBarterRashodFile(L:PSuperMarketType):Boolean;
Var Es : PBarterClientType;
    Esf : File Of BarterClientType;
    i : Byte;
Begin
 SaveToBarterRashodFile:=False;
 Assign(esf,Path.ToBArter+L^.Dat.ClientKod+'.brt');
 i:=IOResult;
 Reset(esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
   If MessageBox(#3'Файл расчетов с клиентом '^M+#3+Path.ToBarter+L^.Dat.ClientKod+'.brt не найден!'^M+
   #3'Создать файл заново ?',Nil,mfWarning+mfOkCancel)=cmOk Then
    Begin
        i:=IOResult;
        Rewrite(Esf);
        i:=IOResult;
        If i<>0 Then
         Begin
          MessageBox(^m+#3'Не могу создать файл '^M+
          #3+Path.ToBarter+L^.Dat.ClientKod+'.brt',Nil,mfError+mfCancelButton);
          Exit;
         End;
    End
    Else Exit;
  End;
 New(Es,Init);
         With Es^.Dat Do
          Begin
        OperatorSelector:=1; {все консигнационные}
        Document:=L^.Dat.Document;
        ENalog  :=L^.Dat.ENalog;
        Nalog5  :=L^.Dat.Nalog5;
        Nalog3  :=L^.Dat.Nalog3;
        Nalog_  :=L^.Dat.Nalog_;


        SummaZ:=L^.Dat.SummaZ;
        Skidka:=L^.Dat.Skidka;
        SummaZakupka:=L^.Dat.SummaZakupka;

        Caption:=L^.Dat.Caption;
        DateC:=L^.Dat.DateC;;
        TimeC:=L^.Dat.TimeC;
        SkladKod:=FormKod(Rek.Kod);
        DocSelector :=L^.Dat.DocSelector;
        SkidkaSelector :=L^.Dat.SkidkaSelector;
        ClientKod:=L^.Dat.ClientKod;
        Active:=True;
          End;
          i:=IOResult;
          Seek(Esf,FileSize(Esf));
          i:=IOResult;
          Write(Esf,Es^.Dat);
          i:=IOResult;

        If i<>0 Then
         Begin
          DiSpose(Es,Done);
          Close(Esf);
          MessageBox(#3'Ошибка записи в файл '^M+
          #3+Path.ToBArter+L^.Dat.ClientKod+'.brt'^M+ClicProgrammer+' '+
    IntToStr(i,3),Nil,mfError+mfCancelButton);
          Exit;
         End;

Dispose(Es,Done);
Close(Esf);
SaveToBarterRashodFile:=True;
End;

Function SaveToBarterPrihodFile(L:PPrihodType):Boolean;
Var Es : PBarterClientType;
    Esf : File Of BarterClientType;
    i : Byte;
    Summa,sVidano: String[CIZena];
    b1: BezNal;
    PBO : POplataBarter;
Begin
 SaveToBarterPrihodFile:=False;
 Assign(esf,Path.ToBArter+L^.Dat.MakeKod+'.brt');
 i:=IOResult;
 Reset(esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
   If MessageBox(#3'Файл расчетов с клиентом '^M+#3+Path.ToBarter+L^.Dat.MakeKod+'.brt не найден!'^M+
   #3'Создать файл заново ?',Nil,mfWarning+mfOkCancel)=cmOk Then
    Begin
        i:=IOResult; Rewrite(Esf); i:=IOResult;
        If i<>0 Then
         Begin
          MessageBox(^m+#3'Не могу создать файл '^M+
          #3+Path.ToBarter+L^.Dat.MakeKod+'.brt',Nil,mfError+mfCancelButton);
          Exit;
         End;
    End
    Else Exit;
  End;

 {Автоматом пишем предоплату}
 Summa:=L^.Dat.SummaZakupka;
 sVidano:='0.00';
 New(Es,Init);
 while not eof(Esf) do
 begin
  {просматриваем переплаты}
  read(Esf,Es^.Dat);
  if Es^.Dat.OperatorSelector=5 then
  if abs(StrToReal(Es^.Dat.Bn.Summa))>0.009 then
  begin

    MyStr(StrToReal(L^.Dat.SummaZakupka)-StrToReal(Es^.Dat.Bn.Summa),CIZena,CMantissa,Summa);
    if StrToReal(Summa)>0.009 then {приход больше предоплаты
      списываем предоплату в 0, остаток = Summa, выдано = предоплата}
    begin
      Es^.Dat.Vidano:=Es^.Dat.Bn.Summa;
      sVidano:=Es^.Dat.Bn.Summa;
      Es^.Dat.Bn.Summa:='0.00';
      seek(Esf,FilePos(Esf)-1);
      write(Esf,Es^.Dat);
      break;
    end

    else      {приход меньше предоплаты - предоплату уменьшаем на сумму прихода
               остаток = 0, выдано = сумма прихода}
    begin
      MyStr(StrToReal(Es^.Dat.Bn.Summa)-StrToReal(L^.Dat.SummaZakupka),CIZena,CMantissa,Es^.Dat.Bn.Summa);
      Summa:='0.00';
      Es^.Dat.Vidano:=L^.Dat.SummaZakupka;
      sVidano:=L^.Dat.SummaZakupka;
      seek(Esf,FilePos(Esf)-1);
      write(Esf,Es^.Dat);
      break;
    end;
  end;
 end;


 Dispose(Es,Done);

 {сохраняем приход}
 New(Es,Init);
         With Es^.Dat Do
          Begin
           VidPrihoda:=1;
           OperatorSelector:=0;
           Document:=L^.Dat.Document;
           PSumma :=L^.Dat.SummaR;;
           PSummaZakupka:=L^.Dat.SummaZakupka;
           OstatokDolga:=Summa;
           Caption:=L^.Dat.Caption;
           DateC:=L^.Dat.DateC;;
           TimeC:=L^.Dat.TimeC;
           SkladKod:=FormKod(Rek.Kod);
           ClientKod:=L^.Dat.MakeKod;
           Active:=True;
           Vidano:=sVidano;
          End;
          i:=IOResult;
          Seek(Esf,FileSize(Esf));
          i:=IOResult;
          Write(Esf,Es^.Dat);
          i:=IOResult;
        If i<>0 Then
         Begin
          DiSpose(Es,Done);
          Close(Esf);
          MessageBox(#3'Ошибка записи в файл '^M+
          #3+Path.ToBArter+L^.Dat.MAkeKod+'.brt'^M+ClicProgrammer+' '+
    IntToStr(i,3),Nil,mfError+mfCancelButton);
          Exit;
         End;
Dispose(Es,Done);

{сохраняем оплату}
if StrToInt(sVidano)>0.009 then
Begin
    New(Es,Init);
         With Es^.Dat Do
          Begin
           OperatorSelector:=2;
           Document:=L^.Dat.Document;
           PSumma :=L^.Dat.SummaR;
           PSummaZakupka:=L^.Dat.SummaZakupka;
           Caption:=L^.Dat.Caption;
           DateC:=L^.Dat.DateC;;
           TimeC:=L^.Dat.TimeC;
           SkladKod:=FormKod(Rek.Kod);
           ClientKod:=L^.Dat.MakeKod;
           Active:=True;
           Vidano:=sVidano;
          End;
          i:=IOResult;
          Seek(Esf,FileSize(Esf));
          i:=IOResult;
          Write(Esf,Es^.Dat);
          i:=IOResult;
        If i<>0 Then
         Begin
          DiSpose(Es,Done);
          Close(Esf);
          MessageBox(#3'Ошибка записи в файл '^M+
          #3+Path.ToBArter+L^.Dat.MAkeKod+'.brt'^M+ClicProgrammer+' '+
          IntToStr(i,3),Nil,mfError+mfCancelButton);
          Exit;
         End;
Dispose(Es,Done);
End;

Close(Esf);

    New(PBO,Init);
    With PBO^.Dat Do
     Begin
      OperatorSelector:=0;
      Vid:=0;
      ClientKod:=L^.Dat.MakeKod;;
      Order[0]:=#0;
      Str(StrToReal(sVidano):CIZena:CMantissa,SummaZ);
      Rashet:=1;
      Bn.Date:=B1.DAte;
      Bn.NPlat:=B1.NPlat;
      Bn.Bank:=B1.Bank;
      Bn.Summa:=B1.Summa;
      Comment:='';
      Link:=1;
      If Link=1 Then
       Begin
        Doc:=L^.Dat.Document;
        Date:=L^.Dat.DAteC;
       End
       Else
        Begin
         Doc[0]:=#0;
         Date[0]:=#0;
        End;
	  End;

     SaveOplataBarterToToDayFile(PBO);

SaveToBarterPrihodFile:=True;
End;


Function SaveToBarterOplataFile(L:PBarterClientType):Boolean;
Var Esf : File Of BarterClientType;
    i : Byte;
Begin
 SaveToBarterOplataFile:=False;
 Assign(esf,Path.ToBArter+L^.Dat.ClientKod+'.brt');
 i:=IOResult;
 Reset(esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
   If MessageBox(#3'Файл расчетов с клиентом '^M+#3+Path.ToBarter+L^.Dat.ClientKod+'.brt не найден!'^M+
   #3'Создать файл заново ?',Nil,mfWarning+mfOkCancel)=cmOk Then
    Begin
        i:=IOResult; Rewrite(Esf); i:=IOResult;
        If i<>0 Then
         Begin
          MessageBox(^m+#3'Не могу создать файл '^M+
          #3+Path.ToBarter+L^.Dat.ClientKod+'.brt',Nil,mfError+mfCancelButton);
          Exit;
         End;
    End
    Else Exit;
  End;
  i:=IOResult;
  Seek(Esf,FileSize(Esf));
  i:=IOResult;
  Write(Esf,L^.Dat);
  i:=IOResult;
  If i<>0 Then
   Begin
    Close(Esf);
    MessageBox(#3'Ошибка записи в файл '^M+
    #3+Path.ToBArter+L^.Dat.ClientKod+'.brt'^M+ClicProgrammer+' '+
    IntToStr(i,3),Nil,mfError+mfCancelButton);
    Exit;
   End;
Close(Esf);
SaveToBarterOplataFile:=True;
End;



Function DeleteRashodOfBarterFile(PrevMarket:PSuperMarketType):Boolean;
Var Es : PBarterClientType;
    Esf : File Of BarterClientType;
    i : Byte;
    Find : Boolean;
Begin
 DeleteRashodOfBarterFile:=False;
 Assign(Esf,Path.ToBarter+PrevMarket^.Dat.ClientKod+'.brt');
 i:=IOResult;
 Reset(Esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
    MessageBox(#3+'Файл расчетов с клиентом '^M+#3+Path.ToBarter+PrevMarket^.Dat.ClientKod+'.brt не найден!'^M+
    ClicProgrammer
   ,Nil,mfError+mfCancelButton);
    Exit;
  End;
        New(Es,Init);
        DelSpace(PrevMarket^.Dat.Document);
        Find:=False;
        DInfoMsg('Ищу документ в файле взаиморасчетов с клиентом '+PrevMarket^.Dat.ClientKod+'...');
        While Not(Eof(Esf)) and not(find) Do
        Begin
         Read(Esf,Es^.Dat);
         DelSpace(Es^.Dat.Document);
          If ((ClearChar(PrevMarket^.Dat.Document)=ClearChar(Es^.Dat.Document))And
          (PrevMArket^.Dat.DateC=Es^.Dat.DateC) And (Es^.Dat.Active) And (Es^.Dat.OperatorSelector=1)) Then Find:=True;
        End;

  If Not(Find) Then
   Begin
    NoInfoMsg;
    Dispose(Es,Done);
    Close(EsF);
    MessageBox(#3'Документ N '+ClearChar(PrevMarket^.Dat.Document)+
    ' от '+PrevMArket^.Dat.DateC+' в файле взаиморасчетов с клиентом не найден!'^M+
    ClicProgrammer,Nil,mfError+mfCancelButton);
    Exit;
   End;

    Seek(Esf,FilePos(Esf)-1);
    Es^.Dat.Active:=False;
    i:=IOResult;
    Write(Esf,Es^.Dat);
    i:=IoREsult;
        If i<>0 Then
         Begin
          DiSpose(Es,Done);
          Close(Esf);
          MessageBox(#3'Ошибка записи в файл '^M+
          #3+Path.ToBarter+PrevMArket^.Dat.ClientKod+'.brt'^M+ClicProgrammer+' '+
    IntToStr(i,3),Nil,mfError+mfCancelButton);
          Exit;
         End;
    Close(EsF);
    i:=IoREsult;
    Dispose(Es,Done);
    NoInfoMsg;
    DeleteRashodOfBarterFile:=True;
End;


Function DeletePrihodOfBarterFile(PrevPrihod:PPrihodType):Boolean;
Var Es : PBarterClientType;
    Esf : File Of BarterClientType;
    i : Byte;
    Find : Boolean;
Begin
 DeletePrihodOfBarterFile:=False;
 Assign(Esf,Path.ToBarter+PrevPrihod^.Dat.MakeKod+'.brt');
 i:=IOResult;
 Reset(Esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
    MessageBox(#3+'Файл расчетов с клиентом '^M+#3+Path.ToBarter+PrevPrihod^.Dat.MakeKod+'.brt не найден!'^M+
    ClicProgrammer,Nil,mfError+mfCancelButton);
    Exit;
  End;
        New(Es,Init);
        DelSpace(PrevPrihod^.Dat.Document);
        Find:=False;
        DInfoMsg('Ищу документ в файле взаиморасчетов с клиентом '+PrevPrihod^.Dat.MakeKod+'...');
        While Not(Eof(Esf)) and not(find) Do
        Begin
         Read(Esf,Es^.Dat);
         DelSpace(Es^.Dat.Document);
          If ((ClearChar(PrevPrihod^.Dat.Document)=ClearChar(Es^.Dat.Document))And
          (PrevPrihod^.Dat.DateC=Es^.Dat.DateC) And (Es^.Dat.Active) And (Es^.Dat.OperatorSelector=0)) Then Find:=True;
        End;

  If Not(Find) Then
   Begin
    NoInfoMsg;
    Dispose(Es,Done);
    Close(EsF);
    MessageBox(#3'Документ N '+ClearChar(PrevPrihod^.Dat.Document)+
    ' от '+PrevPrihod^.Dat.DateC+' в файле взаиморасчетов с клиентом не найден!'^M+
    ClicProgrammer,Nil,mfError+mfCancelButton);
    Exit;
   End;

    Seek(Esf,FilePos(Esf)-1);
    Es^.Dat.Active:=False;
    i:=IOResult;
    Write(Esf,Es^.Dat);
    i:=IoREsult;
        If i<>0 Then
         Begin
          DiSpose(Es,Done);
          Close(Esf);
          MessageBox(#3'Ошибка записи в файл '^M+
          #3+Path.ToBarter+PrevPrihod^.Dat.MakeKod+'.brt'^M+ClicProgrammer+' '+
    IntToStr(i,3),Nil,mfError+mfCancelButton);
          Exit;
         End;
    Close(EsF);
    i:=IoREsult;
    Dispose(Es,Done);
    NoInfoMsg;
    DeletePrihodOfBarterFile:=True;
End;

Function SaveOplataBarterToToDayFile(Var L:POplataBarter):Boolean;
Var OplataFile :File Of OplataBarter;
    c : Word;
    Pos1 : LongInt;
Begin
   SaveOplataBarterToToDayFile:=False;
   Assign(OplataFile,Path.ToBarter+FDate+'.bpl');
   c:=IOResult;
   Reset(OplataFile);
   c:=IOResult;
   If c<>0 Then
    Begin
     If MessageBox(#3'Файл расчетов по взаимозачетам '+Path.ToBarter+FDate+'.bpl'+
  ' не найден!'^M+#3'Создавать файл расчетов?'+
        +' Код:'+IntToStr(c,3),Nil,mfError+mfOkCancel)=cmOk Then
      Begin
{      c:=IOResult;
       Reset(OplataFile);
       c:=Ioresult;
       If c<>0 Then Rewrite(OplataFile);
       c:=IOResult;}
       If Not(CreatToDayF(DocBarterOplata,FDate)) Then Exit;
       Reset(OplataFile);
       c:=IOResult;
       End
      Else
           Begin
            SaveOplataBarterToToDayFile:=False;
            Exit;
           End;
    End;

     DInfoNetMsg('Сохраняю кассовую операцию по взаимозачету...');

    Repeat
     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(OplataFile);
      Seek(OplataFile,Pos1);
     Until (Lock(OplataFile,FilePos(OplataFile)*SizeOf(OplataBarter),SizeOf(OplataBarter)*5));

     Pos1:=FileSize(OplataFile);

     If FilePos(OplataFile)<>{FileSize(OplataFile)}Pos1 Then
      Begin
       Repeat {деблокируем участок записи}
        Pause(1);
        UnLock(OplataFile,(FilePos(OplataFile))*SizeOf(OplataBarter),SizeOf(OplataBarter)*5);
       Until (DosError=0);
      End;
    Until (FilePos(OplataFile)={FileSize(OplataFile)}Pos1);

     L^.Dat.Order:=IntToStr(FilePos(OplataFile)+1,CDocNumer);

     Write(OplataFile,L^.Dat);

     Seek(OplataFile,FilePos(OplataFile)-1);

     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле кассовых операций...');
     Repeat {деблокируем участок записи}
     Pause(1);
     UnLock(OplataFile,(FilePos(OplataFile))*SizeOf(OplataBarter),
         SizeOf(OplataBarter)*5);
     Until (DosError=0);
    Close(OplataFile);
    NoInfoMsg;
    SaveOplataBarterToToDayFile:=True;
End;



Function TestEmployKassaAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of KassaOperation;
    c : LongInt;
    s : KassaOperation;
Begin
DInfoNetMsg('Блокирую операцию с кодом '+TestCod);
TestEmployKassaAndLock:=False;
Assign (F,Path.ToClient+'kassa.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия кассовых операций!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation)); {предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployKassaAndLock:=True;
      Exit;
End;


Function WriteLockKassa(ClientElement:KassaOperation):Boolean;
Var f : File Of KassaOperation;
    c : LongInt;
    s : KassaOperation;
Begin
DInfoNetMsg('Сохраняю информацию об операции с кодом '+ClientElement.Kod+'...');
WriteLockKassa:=False;
Assign (F,Path.ToClient+'kassa.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла кассовых операций!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation)));

{$IFDEF NetVersion}
   ClientElement.Locked:=True;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   WriteLockKAssa:=True;
End;

Function SetKassaUnLock(c:ArtikulStr):Boolean;
Var f : File of KassaOperation;
    l : LongInt;
    Code : Integer;
    s : KassaOperation;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую кассовую операцию с кодом '+c);
 SetKassaUnLock:=False;

 Assign (F,Path.ToClient+'kassa.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла кассовых операций!',nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation)));
   Read(f,s);
   s.Locked:=False;
               {проведение вторичной деблокировки}
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetKassaUnLock:=True;
  End;
End;

Function LockAndWriteKassa( Var L:PItogKassa; var Doc: ArtikulStr) : Boolean;
Var PereozenkaFile : File of ItogKassa;
     c : Byte;
     ChangeNumer : Boolean;
     Pos1: LongInt;
Begin
 LockAndWriteKAssa:=False;
 Assign(PereozenkaFile,Path.ToClient+DateToDateString(DAteMask,L^.Dat.DateC)+'.kas');
 c:=IOResult;
{$I-}
 Reset(PereozenkaFile);
 c:=IOResult;
If c<>0 Then
 Begin
  {If MessageBox('Файл '+DateToDateString(DAteMask,L^.Dat.DateC)+'.kas не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil, mfConfirmation + mfOkCancel)=cmOk Then}
     Begin
      If Not(CreatToDayF(DocKAssa,DateToDateString(DAteMask,L^.Dat.DateC))) Then Exit;
      Reset(PereozenkaFile);
      c:=IOResult;
     End;
 End;
 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу '+DateToDateString(DAteMask,L^.Dat.DateC)+'.kas!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;

     {запись прихода для случая формирования накладной}

     DInfoNetMsg('Сохраняю кассовую операцию ...');
    ChangeNumer:=False;
    Repeat

     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(PereozenkaFile);
      Seek(PereozenkaFile,Pos1);
     Until (Lock(PereozenkaFile,FilePos(PereozenkaFile)*SizeOf(ItogKassa),SizeOf(ItogKassa)*5));

     Pos1:=FileSize(PereozenkaFile);

     If FilePos(PereozenkaFile)<>Pos1{FileSize(PereozenkaFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        Pause(1);
        UnLock(PereozenkaFile,(FilePos(PereozenkaFile))*SizeOf(ItogKassa),SizeOf(ItogKassa)*5);
       Until (DosError=0);
      End;

    Until (FilePos(PereozenkaFile)=Pos1{FileSize(PereozenkaFile)});

     L^.Dat.Doc:=IntToStr(Filepos(PereozenkaFile)+1,CClientKod);
     Write(PereozenkaFile,L^.DAt);

     Seek(PereozenkaFile,FilePos(PereozenkaFile)-1);
     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле кассовых операций..');

     Repeat {деблокируем участок записи}
      Pause(1);
      UnLock(PereozenkaFile,(FilePos(PereozenkaFile))*SizeOf(ItogKassa),
         SizeOf(ItogKassa)*5);
     {
      If DosError<>0 Then
       MessageBox(#3+'DosError='+IntToStr(DosError,3),Nil,
          mfError+mfCancelButton);
     }
     Until (DosError=0);
     Close(PereozenkaFile);
     Doc:=L^.Dat.Doc;
     LockAndWriteKassa:=True;
     NoInfoMsg;


End;


Function LockAndWriteLizoKassa( Var L:PDolgKassa; Lizo:ArtikulStr) : Boolean;
Var PereozenkaFile : File of DolgKassa;
     c : Byte;
     ChangeNumer : Boolean;
     Pos1: LongInt;
Begin
 LockAndWriteLizoKAssa:=False;
 Assign(PereozenkaFile,Path.ToClient+Lizo+'.dls');
 c:=IOResult;
{$I-}
 Reset(PereozenkaFile);
 c:=IOResult;
If c<>0 Then
 Begin
  {If MessageBox('Файл '+DateToDateString(DAteMask,L^.Dat.DateC)+'.kas не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil, mfConfirmation + mfOkCancel)=cmOk Then}
     Begin
      {If Not(CreatToDayF(DocKAssa,DateToDateString(DAteMask,L^.Dat.DateC))) Then Exit;}
      Reset(PereozenkaFile);
      c:=IOResult;
     End;
 End;
 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу '+DateToDateString(DAteMask,L^.Dat.DateC)+'.dls!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;

     {запись прихода для случая формирования накладной}

     DInfoNetMsg('Сохраняю кассовую операцию ...');
    ChangeNumer:=False;
    Repeat

     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(PereozenkaFile);
      Seek(PereozenkaFile,Pos1);
     Until (Lock(PereozenkaFile,FilePos(PereozenkaFile)*SizeOf(DolgKassa),SizeOf(DolgKassa)*5));

     Pos1:=FileSize(PereozenkaFile);

     If FilePos(PereozenkaFile)<>Pos1{FileSize(PereozenkaFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        Pause(1);
        UnLock(PereozenkaFile,(FilePos(PereozenkaFile))*SizeOf(DolgKassa),SizeOf(DolgKassa)*5);
       Until (DosError=0);
      End;

    Until (FilePos(PereozenkaFile)=Pos1{FileSize(PereozenkaFile)});

     {L^.Dat.Doc:=IntToStr(Filepos(PereozenkaFile)+1,CClientKod);}
     Write(PereozenkaFile,L^.DAt);

     Seek(PereozenkaFile,FilePos(PereozenkaFile)-1);
     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле кассовых операций..');

     Repeat {деблокируем участок записи}
      Pause(1);
      UnLock(PereozenkaFile,(FilePos(PereozenkaFile))*SizeOf(DolgKassa),
         SizeOf(DolgKassa)*5);
     {
      If DosError<>0 Then
       MessageBox(#3+'DosError='+IntToStr(DosError,3),Nil,
          mfError+mfCancelButton);
     }
     Until (DosError=0);
     Close(PereozenkaFile);
     LockAndWriteLizoKassa:=True;
     NoInfoMsg;
End;


Function LockAndWriteKassaAs(As:DocumentEdit;Var L:PItogKassa) : Boolean;
Var PereozenkaFile : File of ItogKassa;
     c : Byte;
     ChangeNumer : Boolean;
     Pos1: LongInt;
Begin
 LockAndWriteKAssaAS:=False;
 Assign(PereozenkaFile,Path.ToClient+As.D+'.kas');
 c:=IOResult;
{$I-}
 Reset(PereozenkaFile);
 c:=IOResult;
If c<>0 Then
 Begin
  {If MessageBox('Файл '+As.D+'.kas не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil, mfConfirmation + mfOkCancel)=cmOk Then}
     Begin
      If Not(CreatToDayF(DocKAssa,As.D)) Then Exit;
      Reset(PereozenkaFile);
      c:=IOResult;
     End
   { Else
     Begin
      Exit;
     End; }
 End;
 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу '+As.D+'.kas!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;

     {запись прихода для случая формирования накладной}

     DInfoNetMsg('Сохраняю кассовую операцию ...');

    if (StrToInt(AS.EditPosition)-1> filesize(PereozenkaFile))  then
    Begin
                 MessageBox(#3^M+#3'Позиция  '+As.EditPosition+' > '+
			  IntToStr(FileSize(PereozenkaFile),6),
                 nil, mfError + mfOkButton);
                 Exit;
                End;

    ChangeNumer:=False;
    Repeat

     Repeat {блокируем участок записи}
      Pause(1);
      {Pos1:=FileSize(PereozenkaFile);}
      Pos1:=StrToInt(AS.EditPosition)-1;
      Seek(PereozenkaFile,Pos1);
     Until (Lock(PereozenkaFile,Pos1*SizeOf(ItogKassa),SizeOf(ItogKassa)*5));

     Pos1:=StrToInt(AS.EditPosition)-1;

     If FilePos(PereozenkaFile)<>Pos1{FileSize(PereozenkaFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        Pause(1);
        UnLock(PereozenkaFile,(FilePos(PereozenkaFile))*SizeOf(ItogKassa),SizeOf(ItogKassa)*5);
       Until (DosError=0);
      End;

    Until (FilePos(PereozenkaFile)=Pos1{FileSize(PereozenkaFile)});


     Write(PereozenkaFile,L^.DAt);
     L^.Dat.Doc:=IntToStr(Filepos(PereozenkaFile),CClientKod);
     Seek(PereozenkaFile,FilePos(PereozenkaFile)-1);
     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле кассовых операций..');

     Repeat {деблокируем участок записи}
      Pause(1);
      UnLock(PereozenkaFile,(FilePos(PereozenkaFile))*SizeOf(ItogKassa),
         SizeOf(ItogKassa)*5);
     Until (DosError=0);
     Close(PereozenkaFile);
     LockAndWriteKassaAs:=True;
     NoInfoMsg;
End;


Function SetKassaOperationUnLock(c:ArtikulStr):Boolean;
Var f : File of KassaOperation;
    l : LongInt;
    Code : Integer;
    s : KassaOperation;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую кассовую операцию с кодом '+c);
 SetKassaOperationUnLock:=False;

 Assign (F,Path.ToClient+'kassa.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла кассовых операций!',nil,mfError+mfCancelButton);
  Exit;
  {заблокировать клиента не удалось}
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(KassaOperation),SizeOf(KassaOperation));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetKassaOperationUnLock:=True;
  End;
End;


Procedure LockUnlockNalog(c:ArtikulStr;LockRegim:Word);
Var
    bazF : File Of BazType;
    b : PBazType;
    i : Word;
Begin
 Assign(Bazf,Path.ToName+c+'.id');
 i:=IOResult;
 Reset(Bazf);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3+'Ошибка открытия '+Path.ToName+c+'.id',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(B,Init);
  While Not(Eof(BazF)) Do
   Begin

     Repeat
     Pause(1);
     Until Lock(BazF,FilePos(BazF)*SizeOf(BazType),SizeOf(BazType));

     Read(BazF,b^.Dat);
     If B^.Dat.Employ Then
     Begin
      B^.Dat.VidNDS:=LockRegim;
      Case LockRegim Of
      0:B^.Dat.NDS:='20.00';
      1:B^.Dat.NDS:='10.00';
      Else B^.Dat.NDS:='0.00';
      End;{Case}
      Seek(BazF,FilePos(BazF)-1);
      Write(BazF,B^.Dat);
     End;

     Repeat
     Unlock(Bazf,(FilePos(Bazf)-1)*SizeOf(BazType),SizeOf(BazType));
     Until DosError=0;

   End;
 Close(BazF);
 Dispose(B,Done);
 MessageBox(^M+#3+'Операция успешно завершена!',Nil,mfInformation+mfCancelButton);
End;


Function  DelNameFromDB(s:ArtikulStr):Boolean;
VAr s1 : ArtikulStr;
    Test1,Test2 : Word;
    Skl : PSkladType;
    Elem : PBazType;
Begin
DelNameFromDB:=False;
{If Not(LockSelectName(s)) Then Exit;}
               s1:=Copy(s,1,CRazdelKod);
               Assign(ElementFile,Path.ToName+s1+'.id');
               Reset(ElementFile);
               Test1:=IOResult;
               If (Test1=0) Then
                Begin
                Assign(
       BazFile,Path.ToSklad+s1+'.db');
                Reset(BazFile);
                Test2:=IOResult;
                s1:=Copy(s,3,CKod);
                Seek(ElementFile,GetFileLocation3(s1){-1});


                If (Test2=0) Then
                 Begin
                  Seek(BazFile,GetFileLocation3(s1){-1});
                  New(Skl,Init);
                  Skl^.Dat.BazKod:=s;
                  {блокировка в файле наличия на складе}
                  Repeat
                   Pause(1);
                  Until Lock(BazFile,FilePos(BazFile)*SizeOf(SkladType),SizeOf(SkladType));


                  {запись в файл}
                  Write(BazFile,Skl^.Dat);
                  {деблокировка в файле на личия на складе}
                  Seek(BazFile,FilePos(BazFile)-1);
                  Repeat
                   Unlock(BazFile,FilePos(BazFile)*SizeOf(SkladType),SizeOf(SkladType));
                  Until DosError=0;
                  Dispose(Skl,Done);
                  System.Close(BazFile);

                  New(Elem,Init);
                  {блокировка перед записью в файле наименований}
                  Repeat
                   Pause(1);
                  Until Lock(ElementFile,FilePos(ElementFile)*SizeOf(BAzType),SizeOf(BAzType));



                  Elem^.Dat.BazKod:=s;
                  Elem^.Dat.Locked:=True;
                  Elem^.Dat.LockCaption:=CurrentPassword;
                  {запись в файл наименований}
                  Write(ElementFile,Elem^.Dat);
                  {деблокировка в файле наименований}
                  Repeat
                   Unlock(ElementFile,(FilePos(ElementFile)-1)*SizeOf(BazType),SizeOf(BazType));
                  Until DosError=0;
                  Dispose(Elem,Done);
                  System.Close(ElementFile);
                  Test1:=IOResult;
                  DelNameFromDB:=True;
                 End
                 Else
                 System.Close(ElementFile);
                 Test2:=IOResult;
               End;
{
Repeat
Until (SetNameUnLock(s));
}
End;

Function  TestPayment(Cl:ArtikulStr;Num:ArtikulStr;Date:TDateString):Boolean;
Var Fr : File Of RealizasiaType;
    Er : PRealizasiaType;
  Find : Boolean;
     c : Word;
Begin
TestPAyMent:=False;
DelSpace(cl);
DelSpace(Num);
DelSpace(Date);

Assign(fr,Path.ToDolg+cl+'.dlg');
c:=IOResult;
Reset(fr);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3+'Ошибка доступа к файлу '+cl+'.dlg!',Nil,mfError+mfCancelButton);
  Exit;
 End;
 Find:=False;
 New(Er,Init);
 While Not(Eof(fr)) And Not(Find) Do
  Begin
   Read(fr,Er^.Dat);
   DelSpace(Er^.Dat.Market.Document);
   If (Num=Er^.Dat.Market.Document)And
      (Er^.Dat.Market.DateC=Date)  And
         (Er^.Dat.Market.Active) Then Find:=True;
  End;
 If Not Find Then
  Begin
  Dispose(Er,Done);
  Close(fr);
  Exit;
  End;
  TestPayMent:=Er^.Dat.PayMent;
  Dispose(Er,Done);
  Close(fr);
End;


Function  TestSF(Cl:ArtikulStr;Num:ArtikulStr;Date:TDateString):Boolean;
Var Fr : File Of RealizasiaType;
    Er : PRealizasiaType;
  Find : Boolean;
     c : Word;
Begin
TestSf:=False;
DelSpace(cl);
DelSpace(Num);
DelSpace(Date);

Assign(fr,Path.ToDolg+cl+'.dlg');
c:=IOResult;
Reset(fr);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3+'Ошибка доступа к файлу '+cl+'.dlg!',Nil,mfError+mfCancelButton);
  Exit;
 End;
 Find:=False;
 New(Er,Init);
 While Not(Eof(fr)) And Not(Find) Do
  Begin
   Read(fr,Er^.Dat);
   DelSpace(Er^.Dat.Market.Document);
   If (Num=Er^.Dat.Market.Document)And
      (Er^.Dat.Market.DateC=Date) And
      (Er^.Dat.Market.Active) Then Find:=True;
  End;
 If Not Find Then
  Begin
  Dispose(Er,Done);
  Close(fr);
  Exit;
  End;
  TestSF:=Er^.Dat.Sf;
  Dispose(Er,Done);
  Close(fr);
End;


function SetupSrok(Var St : ArtikulStr;Regim:Boolean) : Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
St[0]:=#0;
SetupSrok:=False;
R.Assign(33, 10, 47, 13);
If Regim Then
New(Dlg, Init(R, 'Срок'))
Else
New(Dlg, Init(R, '%'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;

R.Assign(3, 1, 9, 2);
Control := New(PInputLine, Init(R, CArtikul));
Dlg^.Insert(Control);
  If Regim Then
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']))
  Else
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

Dlg^.SelectNext(False);
c:=Desktop^.execView(Dlg);
If c<>cmCAncel Then
 Begin
  Dlg^.GetDAta(st);
  If Regim Then
  St:=IntToStr(StrToInt(st),CArtikul)
  Else
  St:=RealToStr(StrToReal(st),CArtikul,CMantissa);

  DelSpace(st);
  SetupSrok:=True;
 End;
 Dispose(Control,Done);
 Dispose(Dlg,Done);
end;





Procedure SetupPeriodLockAllTemp(REg,Sel:Word);
Var  f : File Of ClientType;
     cl : ClientType;
     r : Byte;
     cod : ArtikulStr;
     St : ArtikulStr;
Begin
If Password(12) Then
Begin
If SetupSrok(St,True) Then
Begin
AInfo('Минуточку...');
Case Reg Of
0:Begin
 {If Sel = 0 Then Assign (F,Path.ToClient+'Client.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}
    Case Sel Of
     0:Assign (F,Path.ToClient+'Client.db');
     1:Assign (F,Path.ToClient+'Sklad.db');
     2:Assign (F,Path.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
1:Begin
{ If Sel = 0 Then Assign (F,Path.ToClient+'Make.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}
    Case Sel Of
     0:Assign (F,Path.ToClient+'Make.db');
     1:Assign (F,Path.ToClient+'Sklad.db');
     2:Assign (F,Path.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
Else;
End;
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

   cl.Test_Srok:=St;
   Seek(f,FilePos(f)-1);
   r:=IOResult;

   Write(f,cl);
   r:=IOResult;

  End;
System.close(f);
   r:=IOResult;

AddProtocol('Глобальная установка периода временной блокировки '+st+'дней','','');

NoInfo;
End;{SetupSrok}
End;{Password(6)}
End;


Procedure SetupProzAll;
Var  f : File Of ClientType;
     cl : ClientType;
     r : Byte;
     cod : ArtikulStr;
     St : ArtikulStr;
Begin
If Password(10) Then
Begin
If SetupSrok(St,False) Then
Begin
AInfo('Минуточку...');
Case Reg Of
0:Begin
 {If Sel = 0 Then Assign (F,Path.ToClient+'Client.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}
    Case Sel Of
     0:Assign (F,Path.ToClient+'Client.db');
     1:Assign (F,Path.ToClient+'Sklad.db');
     2:Assign (F,Path.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
1:Begin
{ If Sel = 0 Then Assign (F,Path.ToClient+'Make.db')
  Else Assign (F,Path.ToClient+'Sklad.db');}
    Case Sel Of
     0:Assign (F,Path.ToClient+'Make.db');
     1:Assign (F,Path.ToClient+'Sklad.db');
     2:Assign (F,Path.ToClient+'Barter.db');
     Else;
     End;{CAse}
  End;
Else;
End;
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

   cl.Prozent:=St;
   Seek(f,FilePos(f)-1);
   r:=IOResult;

   Write(f,cl);
   r:=IOResult;

  End;
System.close(f);
   r:=IOResult;

AddProtocol('Глобальная установка процента по З/П торговых представителей '+
st+'%','','');

NoInfo;
End;{SetupSrok}
End;{Password(6)}
End;


Procedure ReadGroup(Var F : GroupFileType;Var Element:GroupType );
Var IO : Byte;
    Pos:LongInt;
Begin
Pos:=FilePos(f);
 IO:=IOResult;
Read(f,Element);
 IO:=IOResult;
If IO<>0 Then
Begin
{$IFDEF NetVersion}
 Seek(f,Pos);
 IO:=IOResult;
{Pos:=FilePos(f); до оптимизации была}

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*GroupSize,GroupSize);
{$ENDIF}

  Read(f,Element);

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*GroupSize,GroupSize);
 Until DosError=0;
{$ENDIF}
 IO:=IOResult;
End;

End;


Function SetGroupLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of GroupType;
    l : LongInt;
    Code : Integer;
    s : GroupType;
    st : ArtikulStr;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую группу с кодом '+c);
 SetGroupLock:=False;
 Assign (F,Path.ToClient+'Group.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла групп!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Блокировка группы - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;


   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorName(Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:='???';
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetGroupLock:=True;
      Exit;
  End;
End;




Function SetGroupUnLock(c:ArtikulStr):Boolean;
Var f : File of GroupType;
    l : LongInt;
    Code : Integer;
    s : GroupType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую группу с кодом '+c);
 SetGroupUnLock:=False;

 Assign (F,Path.ToClient+'Group.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла групп!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Деблокировка группы - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;
   s.ComputerNameLocked[0]:=#0;
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetGroupUnLock:=True;
  End;
End;


Function WriteLockGroup(ClientElement:GroupType):Boolean;
Var f : File Of GroupType;
    c : LongInt;
    s : GroupType;
Begin
DInfoNetMsg('Сохраняю информацию о группе с кодом '+ClientElement.Kod+'...');
WriteLockGroup:=False;
Assign (F,Path.ToClient+'Group.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла групп!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType)));

{$IFDEF NetVersion}
   ClientElement.Locked:=True;
   ClientElement.LockCaption:=CurrentPassword;
   ClientElement.ComputerNameLocked:='???';
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   WriteLockGroup:=True;
End;



Function TestEmployGroupAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of GroupType;
    c : LongInt;
    s : GroupType;
Begin
DInfoNetMsg('Блокирую группу с кодом '+TestCod);
TestEmployGroupAndLock:=False;
Assign (F,Path.ToClient+'Group.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла групп!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType)); {предварительная блокировка}

     Read(f,s);

     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:='???';
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployGroupAndLock:=True;
      Exit;
End;


Procedure ReadBufGroup(Var F : File; Var Element:PBufGroupType;Var Count:Word);
Var IO : Byte;
    Pos:LongInt;
Begin
Count:=0;
Pos:=FilePos(f);
 IO:=IOResult;
 BlockRead(f,Element^.Point,{SizeOf(Element)}BufferGroup,Count);
{Pos:=FilePos(f);}
 IO:=IOResult;
If IO<>0 Then
Begin
{$IFDEF NetVersion}
 Seek(f,Pos);
 IO:=IOResult;
{Pos:=FilePos(f); до оптимизации была}

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*GroupSize,BufGroupSize);
{$ENDIF}

 BlockRead(f,Element^.Point,{SizeOf(Element)}BufferGroup,Count);

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*GroupSize,BufGroupSize);
 Until DosError=0;
{$ENDIF}
 IO:=IOResult;
End;

End;



Function SetRewGroupLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of GroupType;
    l : LongInt;
    Code : Integer;
    s : GroupType;
    st : ArtikulStr;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую группу с кодом '+c);
 SetRewGroupLock:=False;
 Assign (F,Path.ToClient+'rGroup.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла групп!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Блокировка группы - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;


   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorName(Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:='???';
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetRewGroupLock:=True;
      Exit;
  End;
End;

Function SetRewGroupUnLock(c:ArtikulStr):Boolean;
Var f : File of GroupType;
    l : LongInt;
    Code : Integer;
    s : GroupType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую группу с кодом '+c);
 SetRewGroupUnLock:=False;

 Assign (F,Path.ToClient+'rGroup.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла групп!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Деблокировка группы - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;
   s.ComputerNameLocked[0]:=#0;
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetRewGroupUnLock:=True;
  End;
End;


Function WriteRewLockGroup(ClientElement:GroupType):Boolean;
Var f : File Of GroupType;
    c : LongInt;
    s : GroupType;
Begin
DInfoNetMsg('Сохраняю информацию о группе с кодом '+ClientElement.Kod+'...');
WriteRewLockGroup:=False;
Assign (F,Path.ToClient+'rGroup.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла групп!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType)));

{$IFDEF NetVersion}
   ClientElement.Locked:=True;
   ClientElement.LockCaption:=CurrentPassword;
   ClientElement.ComputerNameLocked:='???';
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   WriteRewLockGroup:=True;
End;



Function TestRewEmployGroupAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of GroupType;
    c : LongInt;
    s : GroupType;
Begin
DInfoNetMsg('Блокирую группу с кодом '+TestCod);
TestRewEmployGroupAndLock:=False;
Assign (F,Path.ToClient+'rGroup.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла групп!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType)); {предварительная блокировка}

     Read(f,s);

     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:='???';
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestRewEmployGroupAndLock:=True;
      Exit;
End;


Procedure ReadRewBufGroup(Var F : File; Var Element:PBufGroupType;Var Count:Word);
Var IO : Byte;
    Pos:LongInt;
Begin
Count:=0;
Pos:=FilePos(f);
 IO:=IOResult;
 BlockRead(f,Element^.Point,{SizeOf(Element)}BufferGroup,Count);
{Pos:=FilePos(f);}
 IO:=IOResult;
If IO<>0 Then
Begin
{$IFDEF NetVersion}
 Seek(f,Pos);
 IO:=IOResult;
{Pos:=FilePos(f); до оптимизации была}

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*GroupSize,BufGroupSize);
{$ENDIF}

 BlockRead(f,Element^.Point,{SizeOf(Element)}BufferGroup,Count);

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*GroupSize,BufGroupSize);
 Until DosError=0;
{$ENDIF}
 IO:=IOResult;
End;

End;


Procedure ReadREwGroup(Var F : GroupFileType;Var Element:GroupType );
Var IO : Byte;
    Pos:LongInt;
Begin
Pos:=FilePos(f);
 IO:=IOResult;
Read(f,Element);
 IO:=IOResult;
If IO<>0 Then
Begin
{$IFDEF NetVersion}
 Seek(f,Pos);
 IO:=IOResult;
{Pos:=FilePos(f); до оптимизации была}

 Repeat {цикл блокировки}
  Pause(1);
 Until Lock(f,Pos*GroupSize,GroupSize);
{$ENDIF}

  Read(f,Element);

{$IFDEF NetVersion}
 Repeat
  Unlock(f,(Pos)*GroupSize,GroupSize);
 Until DosError=0;
{$ENDIF}
 IO:=IOResult;
End;

End;

Function LockAndWriteTransport(var L:PTransportType):Boolean;
Var TransportFile : File of TransportType;
     c : Byte;
     ChangeNumer : Boolean;
     Pos1: LongInt;
Begin
 LockAndWriteTransport:=False;
 Assign(TransportFile,Path.ToRewisia+L^.Dat.DateC+'.trn');
 c:=IOResult;
{$I-}
 Reset(TransportFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox('Файл '+L^.Dat.DateC+'.trn не существует !'^M+
     'Создать ?',nil, mfConfirmation + mfOkCancel)=cmOk Then
     Begin
{      c:=IOResult;
      Reset(TransportFile);
      c:=IOResult;
      If c<>0 Then Rewrite(TransportFile);}
      If Not(CreatToDayF(DocPereozen,L^.Dat.DateC)) Then Exit;
      Reset(TransportFile);
      c:=IOResult;
     End
    Else
     Begin
      Exit;
     End;
 End;
 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу '+L^.Dat.DateC+'.trn!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;

     {запись прихода для случая формирования накладной}

     {DInfoNetMsg('Сохраняю документ внутреннего перемещения N '+L^.Dat.Document+' от '+L^.Dat.Datec+'...');}

    ChangeNumer:=False;


    Repeat

     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(TransportFile);
      Seek(TransportFile,Pos1);
     Until (Lock(TransportFile,FilePos(TransportFile)*SizeOf(TransportType),SizeOf(TransportType)*2));

     Pos1:=FileSize(TransportFile);

     If FilePos(TransportFile)<>Pos1{FileSize(TransportFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        Pause(1);
        UnLock(TransportFile,(FilePos(TransportFile))*SizeOf(TransportType),SizeOf(TransportType)*2);
       Until (DosError=0);
      End;

    Until (FilePos(TransportFile)=Pos1{FileSize(TransportFile)});


     If (({FileSize(TransportFile)}Pos1+1)<>(StrToInt(L^.Dat.Document))) Then
     Begin
      ChangeNumer:=True;
         L^.Dat.Document:=IntToStr({FileSize(TransportFile)}Pos1+1,CDocNumer);
      DelSpace(L^.Dat.Document);
     End;

     Write(TransportFile,L^.DAt);
     Seek(TransportFile,FilePos(TransportFile)-1);
     {NoNetInfoMsg;}
     {DInfoMsg('Деблокирую запись в файле внутренних перемещений...');}

     Repeat {деблокируем участок записи}
      Pause(1);
      UnLock(TransportFile,(FilePos(TransportFile))*SizeOf(TransportType),
         SizeOf(TransportType)*2);
     {
      If DosError<>0 Then
       MessageBox(#3+'DosError='+IntToStr(DosError,3),Nil,
          mfError+mfCancelButton);
     }
     Until (DosError=0);
     Close(TransportFile);
     LockAndWriteTransport:=True;
     {NoInfoMsg;}
    (* AddProtocol('Добавление документа '+L^.DAt.Document+' успешно завершено {протокол сетевых блокировок}',
	'{внутренние перемещения}',''); *)

{     If ChangeNumer Then
     Begin
      If (ShowNumer=1) Then
       Begin
       MessageBox(#3+'За время формирования Вами документа внутреннего перемещения '+
          'произошли другие операции. Присваиваю документу новый номер: '+L^.Dat.Document+'!',
                Nil,mfInformation+mfCancelButton);
       End;
     End;   }

End;





End.
