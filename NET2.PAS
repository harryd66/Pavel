{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


Unit Net2;

Interface

Uses ServStr,Dialogs,Glob;


{процедуры разделение доступа к регионам}
Function SetElementLock(Vid:Word;c:ArtikulStr;Var Operator:StrNAme):Boolean;
Function SetElementUnLock(Vid:Word;c:ArtikulStr):Boolean;
Function TestEmployElementAndLock(Vid:Word;TestCod:ArtikulStr):Boolean;


Function WriteLockRegion(ClientElement:RegionType):Boolean;
Function WriteLockGroup(ClientElement:GroupType):Boolean;
Function WriteLockMera(ClientElement:MeraType):Boolean;
Function WriteLockKsertif(ClientElement:KSertifType):Boolean;
Function WriteLockMarka(ClientElement:MarkaType):Boolean;
Function WriteLockExpert(ClientElement:ExpertType):Boolean;
Function WriteLockSpecMarka(ClientElement:SpecMarkaType):Boolean;
Function WriteLockNGTD(ClientElement:NGTDType):Boolean;
Function WriteLockClass(ClientElement:ClassificatorBuchType):Boolean;
Function WriteLockKassa(ClientElement:KassaOperationType):Boolean;
Function WriteLockPersonal(ClientElement:PersonalType):Boolean;
Function WriteLockBank(ClientElement:BankType):Boolean;
Function WriteLockRoute(ClientElement:RouteType):Boolean;
Function WriteLockPost(ClientElement:PostType):Boolean;
Function WriteLockFirmaPost(ClientElement:FirmaPostType):Boolean;

(*
{процедуры разделение доступа к группам}
Function SetGroupLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Function SetGroupUnLock(c:ArtikulStr):Boolean;
Function TestEmployGroupAndLock(TestCod:ArtikulStr):Boolean;

{процедуры разделение доступа к единицам измерения}
Function SetMeraLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Function SetMeraUnLock(c:ArtikulStr):Boolean;
Function TestEmployMeraAndLock(TestCod:ArtikulStr):Boolean;

{процедуры разделение доступа к единицам измерения}
Function SetKsertifLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Function SetKsertifUnLock(c:ArtikulStr):Boolean;
Function TestEmployKsertifAndLock(TestCod:ArtikulStr):Boolean;


{процедуры разделение доступа к единицам измерения}
Function SetMarkaLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Function SetMarkaUnLock(c:ArtikulStr):Boolean;
Function TestEmployMarkaAndLock(TestCod:ArtikulStr):Boolean;


{процедуры разделение доступа к единицам измерения}
Function SetExpertLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Function SetExpertUnLock(c:ArtikulStr):Boolean;
Function TestEmployExpertAndLock(TestCod:ArtikulStr):Boolean;

{процедуры разделение доступа к единицам измерения}
Function SetSpecMarkaLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Function SetSpecMarkaUnLock(c:ArtikulStr):Boolean;
Function TestEmploySpecMarkaAndLock(TestCod:ArtikulStr):Boolean;

{процедуры разделение доступа к единицам измерения}
Function SetNGTDLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Function SetNGTDUnLock(c:ArtikulStr):Boolean;
Function TestEmployNGTDAndLock(TestCod:ArtikulStr):Boolean;



{процедуры разделение доступа к маршрутам}
Function SetRouteLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Function SetRouteUnLock(c:ArtikulStr):Boolean;
Function TestEmployRouteAndLock(TestCod:ArtikulStr):Boolean;

{процедуры разделение доступа к справочнику стран мира}
Function SetPostLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Function SetPostUnLock(c:ArtikulStr):Boolean;
Function TestEmployPostAndLock(TestCod:ArtikulStr):Boolean;

{процедуры разделение доступа к справочнику фирм производителей}
Function SetFirmaPostLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Function SetFirmaPostUnLock(c:ArtikulStr):Boolean;
Function TestEmployFirmaPostAndLock(TestCod:ArtikulStr):Boolean;
*)



{процедуры разделение доступа к экспедиторам}
{Function SetEkspedLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;}
{Function SetEkspedUnLock(c:ArtikulStr):Boolean;}
{Function WriteLockEksped(ClientElement:ClientType):Boolean;}
{Function TestEmployEkspedAndLock(TestCod:ArtikulStr):Boolean;}


{процедуры сетевой работы с документами заказа (перемещения товара)}
Function LockAndWriteZakaz(var L:PZakazType):Boolean;
Function SetZakazStatus(Oforml:Word;EditPosition:ArtikulStr;Doc,DAte:TDAteString):Boolean;
Function LockZakaz(EditPosition : ArtikulStr; Var E:PZakazType):Word;
Function UnLockZakaz(Doc:ArtikulStr):Word;
Function WriteZakazCor(var L:PZakazType):Boolean;


Function LockAndWritePredZakaz(var L:PPredZakazType):Boolean;
Function SetPredZakazStatus(Oforml:Word;P:PPredZakazType;EditPosition:ArtikulStr;Doc:TDAteString):Boolean;
Function LockPredZakaz(EditPosition : ArtikulStr; Var E:PPredZakazType):Word;
Function LockPredZakazSpecial(EditPosition:ArtikulStr;Var E:PPredZakazType):Word;
Function UnLockPredZakaz(Doc:ArtikulStr):Word;


Implementation

Uses Serv,ServStr2,MsgBox,NetCall,Dos,DbEngine,Views,Protect,Access,NetDbEng,
     Net,DbEngin2,DbEngin3,Memory,Mail,Printers,Tools,Utils5,Utils4,
     Drivers,App,Objects,TpDate,Inplong,ColorTxt,Utils,Utils1,Utils3;

Const MArketSize=SizeOf(SuperMarketType);
      HeaderSize=SizeOf(SuperMarketTypeIDX);


{
1 открыть файл клиентов
2 заблокировать предварительной блокировкой запись

3 прочитать клиента
4 просмотреть его поле Lock
  Если Lock Истина тогда позиция занята и надо снять предварительную
  блокировку установленную пунктом 2,
  иначе проводим окончательную блокировку клиента, устанавливая Lock=False
}

(*
Function SetGroupLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of LockBazType;
    l : LongInt;
    Code : Integer;
    s : LockBazType;
    st : ArtikulStr;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую группу с кодом '+c);
 SetGroupLock:=False;
 Assign (F,Path^.Dat.ToSPR+'Group.lck');
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
   Until Lock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorField(FNAme,Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetGroupLock:=True;
      Exit;
  End;
End;




Function SetGroupUnLock(c:ArtikulStr):Boolean;
Var f : File of LockBazType;
    l : LongInt;
    Code : Integer;
    s : LockBazType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую группу с кодом '+c);
 SetGroupUnLock:=False;

 Assign (F,Path^.Dat.ToSPR+'Group.lck');
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
   Until (Lock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;
   s.ComputerNameLocked[0]:=#0;
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetGroupUnLock:=True;
  End;
End;
*)

Function WriteLockGroup(ClientElement:GroupType):Boolean;
Var f : File Of GroupType;
    c : LongInt;
    s : GroupType;
  Flck: File Of LockBazType;
   lck: LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию о группе с кодом '+ClientElement.Kod+'...');
WriteLockGroup:=False;
  Assign (F,Path^.Dat.ToSPR+'Group.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла групп!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'Group.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла групп!',Nil,mfError+mfCancelButton);
    Exit;
   End;


   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Seek(f,c);
   Seek(flck,c);

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

{$IFDEF NetVersion}
   ClientElement.Rcd:=True;
   Lck.Locked:=True;
   Lck.LockCaption:=CurrentPassword;
   Lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Write(flck,lck);
   Seek(f,Filepos(f)-1);
   Seek(flck,Filepos(flck)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(GroupType),SizeOf(GroupType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   Close(flck);
   NoNetInfoMsg;
   WriteLockGroup:=True;
End;


(*
Function TestEmployGroupAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of LockBazType;
    c : LongInt;
    s : LockBazType;
Begin
DInfoNetMsg('Блокирую группу с кодом '+TestCod);
TestEmployGroupAndLock:=False;
Assign (F,Path^.Dat.ToSPR+'Group.lck');
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
   Until Lock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType)); {предварительная блокировка}

     Read(f,s);

     If GetGroupEmploy(TestCod){s.Locked} Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;

{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      s.BazKod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployGroupAndLock:=True;
      Exit;
End;


Function SetRouteLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of LockBazType;
    l : LongInt;
    Code : Integer;
    s : LockBazType;
    st : ArtikulStr;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую маршрут с кодом '+c);
 SetRouteLock:=False;
 Assign (F,Path^.Dat.ToSPR+'Route.lck');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла маршрутов!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Блокировка маршрута - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;


   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorField(FNAme,Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetRouteLock:=True;
      Exit;
  End;
End;




Function SetRouteUnLock(c:ArtikulStr):Boolean;
Var f : File of LockBazType;
    l : LongInt;
    Code : Integer;
    s : LockBazType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую маршрут с кодом '+c);
 SetRouteUnLock:=False;

 Assign (F,Path^.Dat.ToSPR+'Route.lck');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла маршрутов!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Деблокировка маршрутов - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;
   s.ComputerNameLocked[0]:=#0;
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetRouteUnLock:=True;
  End;
End;


*)

Function WriteLockRoute(ClientElement:RouteType):Boolean;
Var f : File Of RouteType;
 flck : File Of LockBAzType;
    c : LongInt;
    s : RouteType;
    lck : LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию о маршруте с кодом '+ClientElement.Kod+'...');
WriteLockRoute:=False;
  Assign (F,Path^.Dat.ToSPR+'Route.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла маршрутов!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'Route.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла маршрутов!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Seek(f,c);
   Seek(flck,c);

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(RouteType),SizeOf(RouteType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

   ClientElement.RCD:=True;

{$IFDEF NetVersion}
   lck.Locked:=True;
   lck.LockCaption:=CurrentPassword;
   lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Write(flck,lck);
   Seek(flck,Filepos(flck)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(RouteType),SizeOf(RouteType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   Close(flck);
   NoNetInfoMsg;
   WriteLockRoute:=True;
End;


(*
Function TestEmployRouteAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of LockBazType;
    c : LongInt;
    s : LockBazType;
Begin
DInfoNetMsg('Блокирую маршрут с кодом '+TestCod);
TestEmployRouteAndLock:=False;
Assign (F,Path^.Dat.ToSPR+'Route.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла маршрутов!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType)); {предварительная блокировка}

     Read(f,s);

     If GetRouteEmploy(TestCod){s.Locked} Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployRouteAndLock:=True;
      Exit;
End;



Function SetPostLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of PostType;
    l : LongInt;
    Code : Integer;
    s : PostType;
    st : ArtikulStr;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую страну с кодом '+c);
 SetPostLock:=False;
 Assign (F,Path^.Dat.ToSPR+'lands.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла стран!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Блокировка страны - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;


   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(PostType),SizeOf(PostType));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorField(FNAme,Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(PostType),SizeOf(PostType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(PostType),SizeOf(PostType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetPostLock:=True;
      Exit;
  End;
End;




Function SetPostUnLock(c:ArtikulStr):Boolean;
Var f : File of PostType;
    l : LongInt;
    Code : Integer;
    s : PostType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую страну с кодом '+c);
 SetPostUnLock:=False;

 Assign (F,Path^.Dat.ToSPR+'lands.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла стран!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Деблокировка стран - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(PostType),SizeOf(PostType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;
   s.ComputerNameLocked[0]:=#0;
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(PostType),SizeOf(PostType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetPostUnLock:=True;
  End;
End;

*)

Function WriteLockPost(ClientElement:PostType):Boolean;
Var f : File Of PostType;
 flck : File Of LockBAzType;
    c : LongInt;
    s : PostType;
    lck : LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию о стране с кодом '+ClientElement.Kod+'...');
WriteLockPost:=False;
  Assign (F,Path^.Dat.ToSPR+'lands.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла стран!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'lands.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла стран!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Seek(f,c);
   Seek(flck,c);

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(PostType),SizeOf(PostType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

   ClientElement.RCD:=True;

{$IFDEF NetVersion}
   lck.Locked:=True;
   lck.LockCaption:=CurrentPassword;
   lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Write(flck,lck);
   Seek(flck,Filepos(flck)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(PostType),SizeOf(PostType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   Close(flck);
   NoNetInfoMsg;
   WriteLockPost:=True;
End;


(*
Function TestEmployPostAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of PostType;
    c : LongInt;
    s : PostType;
Begin
DInfoNetMsg('Блокирую страну с кодом '+TestCod);
TestEmployPostAndLock:=False;
Assign (F,Path^.Dat.ToSPR+'lands.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла стран!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(PostType),SizeOf(PostType)); {предварительная блокировка}

     Read(f,s);

     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(PostType),SizeOf(PostType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(PostType),SizeOf(PostType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(PostType),SizeOf(PostType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployPostAndLock:=True;
      Exit;
End;



Function SetFirmaPostLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of FirmaPostType;
    l : LongInt;
    Code : Integer;
    s : FirmaPostType;
    st : ArtikulStr;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую фирму-производителя с кодом '+c);
 SetFirmaPostLock:=False;
 Assign (F,Path^.Dat.ToSPR+'Firma.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла фирм производителей!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Блокировка фирмы-роизводителя - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;


   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(FirmaPostType),SizeOf(FirmaPostType));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorField(FNAme,Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(FirmaPostType),SizeOf(FirmaPostType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(FirmaPostType),SizeOf(FirmaPostType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetFirmaPostLock:=True;
      Exit;
  End;
End;




Function SetFirmaPostUnLock(c:ArtikulStr):Boolean;
Var f : File of FirmaPostType;
    l : LongInt;
    Code : Integer;
    s : FirmaPostType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую фирму-производителя с кодом '+c);
 SetFirmaPostUnLock:=False;

 Assign (F,Path^.Dat.ToSPR+'Firma.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла фирм-производителей!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Деблокировка фирм-производителей - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(FirmaPostType),SizeOf(FirmaPostType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;
   s.ComputerNameLocked[0]:=#0;
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(FirmaPostType),SizeOf(FirmaPostType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetFirmaPostUnLock:=True;
  End;
End;

*)

Function WriteLockFirmaPost(ClientElement:FirmaPostType):Boolean;
Var f : File Of FirmaPostType;
 flck : File Of LockBAzType;
    c : LongInt;
    s : FirmaPostType;
    lck : LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию о фирме с кодом '+ClientElement.Kod+'...');
WriteLockFirmaPost:=False;
  Assign (F,Path^.Dat.ToSPR+'Firma.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла фирм-производителей!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'Firma.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла фирм-производителей!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Seek(f,c);
   Seek(flck,c);

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(FirmaPostType),SizeOf(FirmaPostType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

   ClientElement.RCD:=True;

{$IFDEF NetVersion}
   lck.Locked:=True;
   lck.LockCaption:=CurrentPassword;
   lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Write(flck,lck);
   Seek(flck,Filepos(flck)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(FirmaPostType),SizeOf(FirmaPostType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   Close(flck);
   NoNetInfoMsg;
   WriteLockFirmaPost:=True;
End;


(*
Function TestEmployFirmaPostAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of FirmaPostType;
    c : LongInt;
    s : FirmaPostType;
Begin
DInfoNetMsg('Блокирую фирму-производителя с кодом '+TestCod);
TestEmployFirmaPostAndLock:=False;
Assign (F,Path^.Dat.ToSPR+'Firma.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла фирм-производителей!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(FirmaPostType),SizeOf(FirmaPostType)); {предварительная блокировка}

     Read(f,s);

     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(FirmaPostType),SizeOf(FirmaPostType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(FirmaPostType),SizeOf(FirmaPostType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(FirmaPostType),SizeOf(FirmaPostType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployFirmaPostAndLock:=True;
      Exit;
End;


*)




Procedure ClientIDX;
Var c : LongInt;
    ws : String;
    ClientFile : File Of ClientType;
    ClientElement :ClientType;
    ClientIdxFile : File Of KurzClientType;
    ClientKurz :KurzClientType;
Begin
If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
Exit;
Assign (ClientFile,Path^.Dat.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'Client.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы клиентов ...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;
  With ClientElement Do
   Begin
     If Lizo>1 Then Lizo:=0;
     If Debit>1 Then Debit:=0;
   End;


  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.Employ:=Employ;
  End;

  Write(ClientIdxFile,ClientKurz);


     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);


  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;

Assign (ClientFile,Path^.Dat.ToClient+'Make.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'Make.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы поставщиков...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;

  With ClientElement Do
   Begin
     If Lizo>1 Then Lizo:=0;
     If Debit>1 Then Debit:=0;
   End;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.Employ:=Employ;
  End;

  Write(ClientIdxFile,ClientKurz);


     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);


  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;

Assign (ClientFile,Path^.Dat.ToClient+'sklad.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'Sklad.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы складов...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;
  With ClientElement Do
   Begin
     If Lizo>1 Then Lizo:=0;
     If Debit>1 Then Debit:=0;
   End;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.Employ:=Employ;
  End;

  Write(ClientIdxFile,ClientKurz);

     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);


  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;


Assign (ClientFile,Path^.Dat.ToClient+'barter.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'barter.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы клиентов...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;
  With ClientElement Do
   Begin
     If Lizo>1 Then Lizo:=0;
     If Debit>1 Then Debit:=0;
   End;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.Employ:=Employ;
  End;

  Write(ClientIdxFile,ClientKurz);

     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);


  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;


Assign (ClientFile,Path^.Dat.ToClient+'agent.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'agent.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы агентов...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;
  With ClientElement Do
   Begin
     If Lizo>1 Then Lizo:=0;
     If Debit>1 Then Debit:=0;
   End;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Employ:=Employ;
  End;
  Write(ClientIdxFile,ClientKurz);
     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;

Assign (ClientFile,Path^.Dat.ToClient+'Eksped.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'Eksped.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы экспедиторов...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;
  With ClientElement Do
   Begin
     If Lizo>1 Then Lizo:=0;
     If Debit>1 Then Debit:=0;
   End;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Employ:=Employ;
  End;
  Write(ClientIdxFile,ClientKurz);
     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;

End;


Procedure ClientIDXAuto;
Var c : LongInt;
    ws : String;
    ClientFile : File Of ClientType;
    ClientElement :ClientType;
    ClientIdxFile : File Of KurzClientType;
    ClientKurz :KurzClientType;
Begin
Assign (ClientFile,Path^.Dat.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'Client.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы клиентов ...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.Employ:=Employ;
  End;

  Write(ClientIdxFile,ClientKurz);


     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);


  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;

Assign (ClientFile,Path^.Dat.ToClient+'Make.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'Make.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы поставщиков...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.Employ:=Employ;
  End;

  Write(ClientIdxFile,ClientKurz);


     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);


  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;

Assign (ClientFile,Path^.Dat.ToClient+'sklad.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'Sklad.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы складов...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.Employ:=Employ;
  End;

  Write(ClientIdxFile,ClientKurz);

     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);


  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;


Assign (ClientFile,Path^.Dat.ToClient+'barter.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'barter.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы клиентов...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.Employ:=Employ;
  End;

  Write(ClientIdxFile,ClientKurz);

     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);


  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;


Assign (ClientFile,Path^.Dat.ToClient+'agent.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'agent.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы агентов...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Employ:=Employ;
  End;
  Write(ClientIdxFile,ClientKurz);
     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;

Assign (ClientFile,Path^.Dat.ToClient+'Eksped.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
Assign (ClientIdxFile,Path^.Dat.ToClientBaseIndex+'Eksped.idx');
c:=IOResult;
Rewrite (ClientIdxFile);
c:=IOResult;
AInfo('Идет восстановление индексов базы экспедиторов...');
c:=0;
While Not(Eof(ClientFile)) Do
 Begin

     Repeat
      Pause(1);
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));

     Read(ClientFile,ClientElement);

  Str(c:4,ws);
  While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';
  Seek(ClientFile,FilePos(ClientFile)-1);
  ClientElement.Kod:=ws;
  Write(ClientFile,ClientElement);

  With ClientElement Do
  Begin
  ClientKurz.Name:=Name;
  ClientKurz.Kod:=StrToInt(Kod);
  ClientKurz.Inn:=Copy(Inn,1,CIZena);
  ClientKurz.Employ:=Employ;
  End;
  Write(ClientIdxFile,ClientKurz);
     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
  Inc(c);
 End;
System.Close(ClientFile);
System.Close(ClientIdxFile);
NoInfo;
End;




Procedure CreatIDX;
VAr sklFile : File Of SkladType;
    skl : pSkladType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;

    IndexFileNew : File Of SkladTypeNew;
    Indexnew : PSkladTypenew;

    F : Boolean;
    c : Word;
    ch : LongInt;
    ws : String;
    k,All : LongInt;
    j : Word;
    Be : PBazType;
Begin
If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
Exit;
c:=IOResult;
Assign(RazdelFile,Path^.Dat.ToRazdel+'Razdel.db');
Reset(RazdelFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу разделов!',Nil,mfError+mfCancelButton);
  Exit;
 End;
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
   DInfo('Идет восстановление индексов раздела '+RazdelElement.Kod+'...');
   Assign(SklFile,Path^.Dat.ToSklad+RazdelElement.Kod+'.db');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToSklad+RazdelElement.Kod+'.db',Nil,mfError+mfCancelButton);
  Exit;
 End;

c:=IOResult;
Assign(IndexFileNew,Path^.Dat.ToIndex+RazdelElement.Kod+'.kdx');
Rewrite(IndexFileNew);
c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  Close(SklFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка создания файла индексов '+Path^.Dat.ToIndex+RazdelElement.Kod+'.kdx'+'!',Nil,
  mfError+mfCancelButton);
  Exit;
 End;

   New(Skl,Init);
   New(IndexNew,Init);
   ch:=0;
   While Not(Eof(sklFile)) Do
    Begin

     Repeat
      Pause(1);
     Until NetCAll.Lock(SklFile,FilePos(SklFile)*SizeOf(SkladType),SizeOf(SkladType));

     Read(SklFile,Skl^.Dat);
     Str(ch:3,ws);
     While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';

     If Skl^.Dat.Employ Then
     With Skl^.Dat.Input Do
     Begin
      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(Division[k]):CKol,Division[k]);
           DelSpace(Division[k]);
           All:=All+StrToInt(Division[k]);
        End;
     Str(All:CKol,Skl^.Dat.Input.Kol);
     DelSpace(Skl^.Dat.Input.Kol);

     DelSpace(Skl^.Dat.Input.Kol);



      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(DivisionR[k]):CKol,DivisionR[k]);
           DelSpace(DivisionR[k]);
           All:=All+StrToInt(DivisionR[k]);
        End;
     Str(All:CKol,Skl^.Dat.Input.KolR);
     DelSpace(Skl^.Dat.Input.KolR);





     MyStr(StrToReal(Skl^.Dat.Input.R_Zena),CZena,CMantissa,Skl^.Dat.Input.R_Zena);
     DelSpace(Skl^.Dat.Input.R_Zena);

     MyStr(StrToReal(Skl^.Dat.Input.O_Zena),CZena,CMantissa,Skl^.Dat.Input.O_Zena);
     DelSpace(Skl^.Dat.Input.O_Zena);

     Skl^.Dat.Date:=DateStringToDAte(DateMask,FDate);
     Skl^.Dat.Time:=CurrentTime;
     MyStr(StrToReal(Skl^.Dat.Input.Zakupka),CZenaZ,CMantissaZ,Skl^.Dat.Input.Zakupka);
    {Skl^.Dat.Input.Akzis1:=#0;
     Skl^.Dat.Input.Sertifikat[0]:=#0;
     Skl^.Dat.Input.Post[0]:=#0;}
     Skl^.Dat.Input.Caption:='00';

     End;

     New(Be,Init);
     GetBazElement(Skl^.DAt.BAzKod,BE^.Dat);
     IndexNew^.Dat.Name :=Be^.Dat.Name{GetIdField(FName,Skl^.Dat.BazKod)};
     IndexNew^.Dat.Name2:=Be^.Dat.Name2{GetIdField(FName2,Skl^.Dat.BazKod)};
     {IndexNew^.Dat.NGroupKod:=StrToInt(Be^.Dat.NGroupKod);}
     Dispose(Be,Done);

     IndexNew^.Dat.Virabotano :=DateStringToDate(DateMask,Skl^.Dat.input.Virabotano);
     IndexNew^.Dat.EnableSklads:=StrToInt(GetIdField(FEnableSklads,Skl^.DAt.BAzKod));
     IndexNew^.Dat.Employ :=Skl^.DAt.Employ;
     IndexNew^.Dat.NSertif :=StrToInt(Skl^.DAt.Input.NSertif);
     For j:=1 To CDivision Do IndexNew^.Dat.Division[j]:=StrToInt(Skl^.Dat.Input.Division[j]);
     For j:=1 To CDivision Do IndexNew^.Dat.DivisionR[j]:=StrToInt(Skl^.Dat.Input.DivisionR[j]);
     IndexNew^.Dat.R_Zena  :=StrToreal(Skl^.Dat.Input.R_Zena);
     IndexNew^.Dat.RegionMarka:=Skl^.Dat.Input.RegionMarka;
     IndexNew^.Dat.BazKod:=StrToInt(Skl^.Dat.BazKod);
     IndexNew^.Dat.Kol:=StrToInt(Skl^.Dat.Input.Kol);
     IndexNew^.Dat.StrihKod:=Skl^.Dat.Input.StrihKod;
     IndexNew^.Dat.NMakeKod:=StrToInt(Skl^.Dat.Input.NMakeKod);


     ws:=RazdelElement.Kod+ws;

     Seek(SklFile,FilePos(SklFile)-1);
     Skl^.Dat.BazKod:=ws;
     Write(SklFile,Skl^.Dat);

     Write(IndexFileNew,IndexNew^.Dat);

     Repeat
      NetCall.UnLock(SklFile,(FilePos(SklFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
     Until (DosError=0);

     Inc(ch);
     End;

   Dispose(Skl,Done);
   Close(SklFile);
   Close(IndexFileNew);
   Dispose(IndexNew,Done);
   NoInfo;
   End;
 End;
Close(RazdelFile);
MessageBox(^M+#3'Переиндексация завершена!',Nil,mfInformation+mfCancelButton);
End;




(*
Procedure CreatIDX;
VAr sklFile : File Of SkladType;
    skl : pSkladType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    IndexFile : IndexFileType;
    Index : PIndexType;
    F : Boolean;
    c : Word;
    ch : LongInt;
    ws : String;
    k,All : LongInt;

Begin
If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
Exit;
c:=IOResult;
Assign(RazdelFile,Path^.Dat.ToRazdel+'Razdel.db');
Reset(RazdelFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу разделов!',Nil,mfError+mfCancelButton);
  Exit;
 End;
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
   DInfo('Идет восстановление индексов раздела '+RazdelElement.Kod+'...');
   Assign(SklFile,Path^.Dat.ToSklad+RazdelElement.Kod+'.db');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToSklad+RazdelElement.Kod+'.db',Nil,mfError+mfCancelButton);
  Exit;
 End;

c:=IOResult;
Assign(IndexFile,Path^.Dat.ToIndex+RazdelElement.Kod+'.idx');
Rewrite(IndexFile);
c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  Close(SklFile);
  NoInfo;
  MessageBox(^M+#3'Ошибка создания файла индексов '+Path^.Dat.ToIndex+RazdelElement.Kod+'.idx'+'!',Nil,
  mfError+mfCancelButton);
  Exit;
 End;

   New(Skl,Init);
   New(Index,Init);
   ch:=0;
   While Not(Eof(sklFile)) Do
    Begin

     Repeat
      Pause(1);
     Until NetCAll.Lock(SklFile,FilePos(SklFile)*SizeOf(SkladType),SizeOf(SkladType));

     Read(SklFile,Skl^.Dat);
     Str(ch:3,ws);
     While Pos(' ',ws)>0 Do Ws[Pos(' ',ws)]:='0';

     If Skl^.Dat.Employ Then
     With Skl^.Dat.Input Do
     Begin
      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(Division[k]):CKol,Division[k]);
           DelSpace(Division[k]);
           All:=All+StrToInt(Division[k]);
        End;
     Str(All:CKol,Skl^.Dat.Input.Kol);
     DelSpace(Skl^.Dat.Input.Kol);

     If StrToInt(Skl^.Dat.Input.Kol)>0 Then
     Index^.Dat.Present[StrToInt(ws)]:=True
     Else
     Index^.Dat.Present[StrToInt(ws)]:=False;

     DelSpace(Skl^.Dat.Input.Kol);



      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(DivisionR[k]):CKol,DivisionR[k]);
           DelSpace(DivisionR[k]);
           All:=All+StrToInt(DivisionR[k]);
        End;
     Str(All:CKol,Skl^.Dat.Input.KolR);
     DelSpace(Skl^.Dat.Input.KolR);





     MyStr(StrToReal(Skl^.Dat.Input.R_Zena),CZena,CMantissa,Skl^.Dat.Input.R_Zena);
     DelSpace(Skl^.Dat.Input.R_Zena);

     MyStr(StrToReal(Skl^.Dat.Input.O_Zena),CZena,CMantissa,Skl^.Dat.Input.O_Zena);
     DelSpace(Skl^.Dat.Input.O_Zena);

     Skl^.Dat.Date:=DateStringToDAte(DateMask,FDate);
     Skl^.Dat.Time:=CurrentTime;
     MyStr(StrToReal(Skl^.Dat.Input.Zakupka),CZenaZ,CMantissaZ,Skl^.Dat.Input.Zakupka);
    {Skl^.Dat.Input.Akzis1:=#0;
     Skl^.Dat.Input.Sertifikat[0]:=#0;
     Skl^.Dat.Input.Post[0]:=#0;}
     Skl^.Dat.Input.Caption:='00';
     End;


     ws:=RazdelElement.Kod+ws;

     Seek(SklFile,FilePos(SklFile)-1);
     Skl^.Dat.BazKod:=ws;
     Write(SklFile,Skl^.Dat);

     Repeat
      NetCall.UnLock(SklFile,(FilePos(SklFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
     Until (DosError=0);

     Inc(ch);
     End;

   Dispose(Skl,Done);
   Close(SklFile);
   Write(IndexFile,Index^.Dat);
   Close(IndexFile);
   Dispose(Index,Done);
   NoInfo;
   End;
 End;
Close(RazdelFile);
MessageBox(^M+#3'Переиндексация завершена!',Nil,mfInformation+mfCancelButton);
End;
*)



Function WriteZakazCor(Var L:PZakazType):Boolean;
{Параметр Mode указывает что это поступление товара на склад или
формирование и корректировка}
Var MarketFile : ZakazFileType;
    c : Byte;
    Code,Pos1,Pos2:LongInt;
Begin
 If Status<>DocEdit Then
  Begin
   WriteZakazCor:=True;
   Exit;
  End;

 WriteZakazCor:=False;
 Assign(MarketFile,Path^.Dat.ToMarket+'zakaz.cor');
 c:=IOResult;
{$I-}
 Reset(MarketFile);
 c:=IOResult;

If c<>0 Then
 Begin
  Exit;
 End;

     {запись прихода для случая формирования накладной}
    DInfoNetMsg('Сохраняю копию заказа N '+
    L^.Dat.Document+' от '+L^.Dat.Datec+'...');

     Repeat
     Until LockAppendBase(NetlockZakazCor,False);


    Repeat

     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(MarketFile);
      Seek(MarketFile,Pos1{FileSize(MarketFile)});
     Until (Lock(MarketFile,FilePos(MarketFile)*SizeOf(ZakazType),SizeOf(ZakazType)*ComputersKol));

     Pos1:=FileSize(MarketFile);

     If FilePos(MarketFile)<>Pos1{FileSize(MarketFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        UnLock(MarketFile,(FilePos(MarketFile))*SizeOf(ZakazType),SizeOf(ZakazType)*ComputersKol);
       Until (DosError=0);
      End;
    Until (FilePos(MarketFile)=Pos1{FileSize(MarketFile)});

     L^.Dat.Locked:=False;

     Write(MarketFile,L^.DAt);
     Seek(MarketFile,FilePos(MarketFile)-1);
     NonetInfoMsg;

     DInfoMsg('Деблокирую запись в файле копии заказов...',False);
     Repeat {деблокируем участок записи}
      UnLock(MarketFile,(FilePos(MarketFile))*SizeOf(ZakazType),
      SizeOf(ZakazType)*ComputersKol);
     Until (DosError=0);
c:=IOResult;
     Close(MarketFile);
     WriteZakazCor:=True;
     NoInfoMsg;

     AddProtocol('Добавление документа '+L^.DAt.Document+
	' успешно завершено {протокол сетевых блокировок}','{заказы копии}','');


     Repeat
     Until UnLockAppendBase(NetlockZakazCor,False);


c:=IOResult;
End;




Procedure RecalcPositionVersionZakaz(Var N,B : PZakazType);
Var j,c,Vers:Word;
    Find : Boolean;
Begin
 Vers:=B^.Dat.Versia;
 For c:=1 To N^.Dat.Amount Do
  Begin
   Find:=False;
    For j:=1 To B^.Dat.Amount Do
     Begin
      If N^.Dat.MarketElement[c].BazKod=B^.Dat.MarketElement[j].BAzKod Then
       Begin
        Find:=True;
        Break;
       End{If}
     End;{For по старому варианту накладной}

   If Find Then N^.Dat.MarketElement[c].Input.Version:=B^.DAt.MarketElement[j].Input.Version
   Else N^.Dat.MarketElement[c].Input.Version:=N^.DAt.Versia;
  End;{ For по новому варианту накладной}

 For c:=1 To N^.Dat.AmountS Do
  Begin
   Find:=False;
    For j:=1 To B^.Dat.AmountS Do
     Begin
      If N^.Dat.DocumentElement[c].BazKod=B^.Dat.DocumentElement[j].BAzKod Then
       Begin
        Find:=True;
        Break;
       End{If}
     End;{For по старому варианту накладной}

   If Find Then N^.Dat.DocumentElement[c].Input.Version:=B^.DAt.DocumentElement[j].Input.Version
   Else N^.Dat.DocumentElement[c].Input.Version:=N^.DAt.Versia;
  End;{ For по новому варианту накладной}
End;{Procedure}



Function LockAndWriteZakaz(Var L:PZakazType):Boolean;
{Параметр Mode указывает что это поступление товара на склад или
формирование и корректировка}
Var MarketFile : ZakazFileType;
    HeaderFile : HeaderZakazFileType;
    c : Byte;
    Find : Boolean;
    Test : PZakazType;
    Er,Position,Code,Pos1,Pos2:LongInt;
    ChangeNumer : Boolean;
    Lh : PHeaderZakazType;
Begin
 LockAndWriteZakaz:=False;
 Assign(MarketFile,Path^.Dat.ToMarket+'zakaz.db');
 c:=IOResult;
{$I-}
 Reset(MarketFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox(^M+'Файл zakaz.db не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil,
        mfConfirmation + mfOkCancel)=cmOk  Then
     Begin
      If Not(CreatToDayF(DocZakaz,L^.Dat.DateC)) Then Exit;
      Reset(MarketFile);
      c:=IOResult;
     End
    Else
     Begin
      Exit;
     End;
 End;

 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу zakaz.db!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;


 Assign(HeaderFile,Path^.Dat.ToMarketIndex+'zakaz.idx');
 c:=IOResult;
{$I-}
 Reset(HeaderFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox(^M+'Файл zakaz.idx не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil,
        mfConfirmation + mfOkCancel)=cmOk  Then
     Begin
      If Not(CreatToDayF(DocZakaz,L^.Dat.DateC)) Then Exit;
      Reset(HeaderFile);
      c:=IOResult;
     End
    Else
     Begin
      Close(MarketFile);
      c:=IOResult;
      Exit;
     End;
 End;


 If c <> 0 Then Begin
                 Close(MarketFile);
                 c:=IOResult;
                 MessageBox(#3^M+#3'Нет доступа к файлу zakaz.idx!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;

If (StrToInt(L^.Dat.Document)-1)<0 Then
 begin
   Close(MarketFile);
   If Status=DocEdit Then
   MessageBox(#3^M+#3'Заказ N '+ L^.Dat.Document+' в базе за '+L^.DAt.DAteC+' не найден!',Nil,
   mfError+mfCancelButton)
   Else
   MessageBox(#3^M+#3'Недопустимый номер заказа N '+ L^.Dat.Document+' в базе не найден!',Nil,
   mfError+mfCancelButton);
   Exit;
 end;


   New(Lh,Init);
   ZakazToIndex(L,Lh);
{если открытие прошло нормально}
   If Status=DocEdit Then
    Begin
     {создаем новый экземпляр прихода}
     New(test,Init);
     Find := False;
     DelSPace(L^.DAt.Document);
     DelSPace(L^.DAt.DAteC);
     DelSPace(L^.DAt.SkladKod);

   {оптимизация}

   If FileSize(MarketFile)>(StrToInt(L^.Dat.Document)-1) Then
    Begin
     Seek(MarketFile,StrToInt(L^.DAt.Document)-1);
     ReadZakaz(MarketFile,Test);
     DelSpace(Test^.DAt.Document);
     DelZerro(Test^.Dat.Document);
     If (StrToInt(Test^.Dat.Document)=StrToInt(L^.DAt.Document)) And
          (Test^.Dat.DateC=L^.DAt.DateC) And
          (Test^.Dat.SkladKod=L^.DAt.SkladKod) Then
            Begin
             Find:=True;
         End
         Else Seek(MarketFile,0);
    End;


     {цикл поиска исходного документа в файле}
     While Not(Eof(MarketFile)) And Not(Find) Do
      Begin
       ReadZakaz(MarketFile,Test);

       DelSpace(Test^.Dat.Document);
       DelSpace(Test^.Dat.DateC);
       DelSpace(Test^.Dat.SkladKod);
       If (Test^.Dat.Document=L^.DAt.Document) And
          (Test^.Dat.DateC=L^.DAt.DateC) And
          (Test^.Dat.SkladKod=L^.DAt.SkladKod) Then Find:=True;
      End;

      If Find Then
       Begin
        RecalcPositionVersionZakaz(L,Test);
       End;


      Dispose(Test,Done);

     {если документ не найден тогда выходим с сообщением}
     If Not(Find) Then
      Begin
       Close(MarketFile);
       MessageBox(#3^M+#3'Заказ N '+ L^.Dat.Document+' в базе за '+L^.DAt.DAteC+' не найден!',Nil,
          mfError+mfCancelButton);
       Exit;
      End;

     DInfoNetMsg('Сохраняю измененный заказ N '+L^.Dat.Document+'...');
     {если мы нашли документ тогда блокируем его и записываем}
     Seek(MarketFile,FilePos(MarketFile)-1);

     {блокировка}
     Repeat
     Pause(1);
     Until (Lock(MarketFile,FilePos(MarketFile)*SizeOf(ZakazType),SizeOf(ZakazType)));
     {запись}

{$IFDEF NetVersion}
     L^.Dat.Locked:=True;
{$ENDIF}

     Write(MarketFile,L^.DAt);
     {снятие блокировки}
     Seek(MarketFile,FilePos(MarketFile)-1);

     {запись в idx file}
     Seek(HeaderFile,FilePos(MarketFile));
     Write(HeaderFile,Lh^.DAt);
     {снятие блокировки}


     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле заказов...',False);
     Repeat
      Pause(1);
      UnLock(MarketFile,FilePos(MarketFile)*SizeOf(ZakazType),SizeOf(ZakazType));
     Until (DosError=0);
     Close(MarketFile);
     Close(HeaderFile);
     LockAndWriteZakaz:=True;
     NoInfoMsg;
    End
   Else
    Begin
     {запись прихода для случая формирования накладной}
     DInfoNetMsg('Сохраняю новый заказ N '+L^.Dat.Document+'...');
     ChangeNumer:=False;

     Repeat
     Until LockAppendBase(NetlockZakaz,False);


    Repeat

     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(MarketFile);
      Seek(MarketFile,Pos1{FileSize(MarketFile)});
     Until (Lock(MarketFile,FilePos(MarketFile)*SizeOf(ZakazType),SizeOf(ZakazType)*ComputersKol));

     Pos1:=FileSize(MarketFile);

     If FilePos(MarketFile)<>Pos1{FileSize(MarketFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        UnLock(MarketFile,(FilePos(MarketFile))*SizeOf(ZakazType),SizeOf(ZakazType)*ComputersKol);
       Until (DosError=0);
      End;
    Until (FilePos(MarketFile)=Pos1);

{$IFDEF NetVersion}
     L^.Dat.Locked:=True;
{$ENDIF}

     If ({(FileSize(MarketFile)+1)}(Pos1+1)<>(StrToInt(L^.Dat.Document))) Then
     Begin
      ChangeNumer:=True;
      L^.Dat.Document:=IntToStr({FileSize(MArketFile)}Pos1+1,CDocNumer);
      DelSpace(L^.Dat.Document);

      Dispose(Lh,Done);
      New(Lh,Init);
      ZakazToIndex(L,Lh);
     End;

     Position:=FilePos(MarketFile);

     Er:=IOResult;
     Write(MarketFile,L^.DAt);
     Er:=IOResult;
     Seek(MarketFile,FilePos(MarketFile)-1);
     Er:=IOResult;

     {запись в idx file}
     Seek(HeaderFile,{FilePos(MarketFile)}Position);
     Er:=IOResult;
     Write(HeaderFile,Lh^.DAt);
     Er:=IOResult;
     {снятие блокировки}

     NonetInfoMsg;

     DInfoMsg('Деблокирую запись в файле заказов...',False);
     Repeat {деблокируем участок записи}
      UnLock(MarketFile,(FilePos(MarketFile))*SizeOf(ZakazType),
      SizeOf(ZakazType)*ComputersKol);
     {If DosError<>0 Then
       MessageBox(#3+'DosError='+IntToStr(DosError,3),Nil,
          mfError+mfCancelButton);}
     Until (DosError=0);

     Close(MarketFile);
     Close(HeaderFile);
     LockAndWriteZakaz:=True;
     NoInfoMsg;

     AddProtocol('Добавление документа '+L^.DAt.Document+'('+
	IntToStr(Lh^.DAt.Document,CKOl)+
	') успешно завершено {протокол сетевых блокировок}','{заказы}','');


     Repeat
     Until UnLockAppendBase(NetlockZakaz,False);


     If ChangeNumer Then
     Begin
      If (ServStr.ShowNumer=1) Then
       Begin
       MessageBox(#3+'За время формирования Вами документа проведены другие '+
          'заказы. Присваиваю документу новый номер: '+L^.Dat.Document+'!',
           Nil,mfInformation+mfCancelButton);
       End;
     End;
    End;

c:=IOResult;
Dispose(Lh,Done);

End;


(*
Function LockAndWriteZakaz(var L:PZakazType):Boolean;
{Параметр Mode указывает что это поступление товара на склад или
формирование и корректировка}
Var ZakazFile : ZakazFileType;
    c : Byte;
    Find : Boolean;
    Test : PZakazType;
    Code,Pos1,Pos2:LongInt;
    ChangeNumer : Boolean;
Begin
 LockAndWriteZakaz:=False;
 Assign(ZakazFile,Path^.Dat.ToMarket+'Zakaz.db');
 c:=IOResult;
{$I-}
 Reset(ZakazFile);
 c:=IOResult;
If c<>0 Then
 Begin
   MessageBox(^M+#3+'Ошибка открытия Файла Zakaz.db!'^M+
     'Позови программиста!'+' Код:'+IntToStr(c,3),nil,mfFatalError+mfCancelButton);
      Exit;
 End;
     {запись прихода для случая формирования накладной}
     DInfoNetMsg('Сохраняю заказ N '+
     L^.Dat.Document+' от '+L^.Dat.Datec+'...');
     ChangeNumer:=False;
    Repeat
     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(ZakazFile);
      Seek(ZakazFile,Pos1{FileSize(MarketFile)});
     Until (Lock(ZakazFile,FilePos(ZakazFile)*SizeOf(ZakazType),SizeOf(ZakazType)*ComputersKol));

     Pos1:=FileSize(ZakazFile);

     If FilePos(ZakazFile)<>Pos1{FileSize(MarketFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        UnLock(ZakazFile,(FilePos(ZakazFile))*SizeOf(ZakazType),SizeOf(ZakazType)*ComputersKol);
       Until (DosError=0);
      End;
    Until (FilePos(ZakazFile)=Pos1{FileSize(MarketFile)});

{$IFDEF NetVersion}
     L^.Dat.Locked:=True;
{$ENDIF}


     If ({(FileSize(MarketFile)+1)}(Pos1+1)<>(StrToInt(L^.Dat.Document))) Then
     Begin
      ChangeNumer:=True;
         L^.Dat.Document:=IntToStr({FileSize(MArketFile)}Pos1+1,CDocNumer);
      DelSpace(L^.Dat.Document);
     End;

     Write(ZakazFile,L^.DAt);
     Seek(ZakazFile,FilePos(ZakazFile)-1);
     NonetInfoMsg;

     DInfoMsg('Деблокирую запись в файле заказов...',False);
     Repeat {деблокируем участок записи}
      UnLock(ZakazFile,(FilePos(ZakazFile))*SizeOf(ZakazType),
      SizeOf(ZakazType)*ComputersKol);
     {If DosError<>0 Then
       MessageBox(#3+'DosError='+IntToStr(DosError,3),Nil,
          mfError+mfCancelButton);}
     Until (DosError=0);

     Close(ZakazFile);
     LockAndWriteZakaz:=True;
     NoInfoMsg;

     If ChangeNumer Then
     Begin
      If (ShowNumer=1) Then
       Begin
       MessageBox(#3+'За время формирования Вами заказа проведены другие '+
          'заказы товара. Присваиваю документу новый номер: '+L^.Dat.Document+'!',
           Nil,mfInformation+mfCancelButton);
       End;
     End;
c:=IOResult;
End;
*)


Function LockZakaz(EditPosition:ArtikulStr;Var E:PZakazType):Word;
{функция возвращает 0 если все прошло ок
0 все ок
1 если документ не найден
2 если не удалось заблокировать накладную
3 ошибка сетевого открытия файла продаж
4 если по документу оормлен заказ
5 если заказ онулирован по времени}
Var C : Byte;
    Find : Boolean;
    MarketFile : ZakazFileType;
    Pos : LongInt;
Begin
  LockZakaz:=3;
  C:=IOResult;
  Assign(MarketFile,Path^.Dat.ToMarket+'zakaz.db');
  Reset(MarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла заказов!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    C:=IOResult;
    LockZakaz:=3;
    Exit;
   End;

   Seek(MarketFile,0);

   DelSpace(EditPosition);
   DelZerro(EditPosition);
   EditPosition:=ClearChar(EditPosition);
   Find:=False;

If (StrToInt(EditPosition)-1)<0 Then
    Begin
      LockZakaz:=1;
      Close(MarketFile);
      MessageBox(#3^M+#3'Заказ N '+ EditPosition+' в базе не найден!',Nil,mfError+mfCancelButton);
      Exit;
    End;

If (FileSize(MarketFile)>(StrToInt(EditPosition)-1))
    Then
 Begin
     Seek(MarketFile,StrToInt(EditPosition)-1);
     ReadZakaz(MarketFile,E);
     DelSpace(E^.DAt.Document);
     DelZerro(E^.Dat.Document);

     If (StrToInt(E^.DAt.Document)=StrToInt(EditPosition))
        And (StrToInt(E^.DAt.SkladKod)=StrToInt(Rek^.Dat.Kod))
         Then
            Begin
             Find:=True;
         End;
 End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      LockZakaz:=1;
      Close(MarketFile);
      MessageBox(#3^M+#3'Заказ N '+ EditPosition+' в базе не найден!',Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}
   DInfoNetMsg('Блокирую заказ N '+EditPosition+'...');
   LockZakaz:=2;
   Seek(MarketFile,FilePos(MarketFile)-1);
   Repeat
   Pause(1);
   Until Lock(MarketFile,FilePos(MarketFile)*SizeOf(ZakazType),SizeOf(ZakazType));
   Read(MarketFile,E^.Dat);

   {если документ уже заблокирован}
   If (E^.Dat.Locked) Then
    Begin
     NoNetInfoMsg;
     LockZakaz:=2;
     {снятие предварительной блокировки}
     Seek(MarketFile,FilePos(MarketFile)-1);
     Repeat
      UnLock(MarketFile,FilePos(MarketFile)*SizeOf(ZakazType),SizeOf(ZakazType))
     Until Doserror=0;
     Close(MarketFile);
     Exit;
    End;

    If (E^.Dat.Oformlenie=1)Then
    Begin
        MessageBox(^M+#3'По заказу уже оформлен документ отгрузки!',Nil, mfWarning+mfCancelButton);
        NoNetInfoMsg;
        LockZakaz:=4;
        {снятие предварительной блокировки}
        Seek(MarketFile,FilePos(MarketFile)-1);
        Repeat
         UnLock(MarketFile,FilePos(MarketFile)*SizeOf(ZakazType),SizeOf(ZakazType))
        Until Doserror=0;
        Close(MarketFile);
        Exit;
    End;

    If (E^.Dat.Oformlenie=2)Then
    Begin
        MessageBox(#3+'Заказ анулирован по истечении срока доставки!',Nil, mfWarning+mfCancelButton);
        NoNetInfoMsg;
        LockZakaz:=5;
        {снятие предварительной блокировки}
        Seek(MarketFile,FilePos(MarketFile)-1);
        Repeat
         UnLock(MarketFile,FilePos(MarketFile)*SizeOf(ZakazType),SizeOf(ZakazType))
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
    UnLock(MarketFile,FilePos(MarketFile)*SizeOf(ZakazType),SizeOf(ZakazType))
   Until Doserror=0;
   LockZakaz:=0;
   NoNetInfoMsg;
   Close(MarketFile);
End;



Function SetZakazStatus(Oforml:Word;EditPosition:ArtikulStr;Doc,DAte:TDAteString):Boolean;

{функция возвращает 0 если все прошло ок
0 все ок
1 если документ не найден
2 если не удалось заблокировать накладную
3 ошибка сетевого открытия файла продаж
4 если по документу оормлен заказ
5 если заказ онулирован по времени}

Var C : Byte;
    Find : Boolean;
    MarketFile : ZakazFileType;
    HeaderFile : HeaderZakazFileType;
    E : PZakazType;
    Lh : PHeaderZakazType;

Begin
  SetZakazStatus:=False;
  C:=IOResult;
  Assign(MarketFile,Path^.Dat.ToMarket+'zakaz.db');
  Reset(MarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла заказов!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    C:=IOResult;
    Exit;
   End;

  C:=IOResult;
  Assign(HeaderFile,Path^.Dat.ToMarketIndex+'zakaz.idx');
  Reset(HeaderFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    Close(MarketFile);
    MessageBox(^M+#3'Ошибка сетевого открытия Файла заказов-idx!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    C:=IOResult;
    Exit;
   End;

   New(E,Init);
   New(Lh,Init);

If (StrToInt(EditPosition)-1)>=0 Then
If FileSize(MarketFile)>(StrToInt(EditPosition)-1) Then
 Begin

   Seek(MarketFile,StrToInt(EditPosition)-1);

   Seek(HeaderFile,StrToInt(EditPosition)-1);

   Repeat
   Pause(1);
   Until Lock(MarketFile,FilePos(MarketFile)*SizeOf(ZakazType),SizeOf(ZakazType));

   {запись статуса заказа}
   Read(MarketFile,E^.Dat);
   E^.Dat.Oformlenie:=Oforml;
   If Oforml=1 Then
   Begin
   E^.Dat.DocReal:=Doc;
   E^.Dat.DocDate:=Date;
   End;

   Seek(MarketFile,FilePos(MarketFile)-1);
   Write(MarketFile,E^.DAt);
   Seek(MarketFile,FilePos(MarketFile)-1);


   {запись статуса заказа}
   Read(HeaderFile,Lh^.Dat);
   Lh^.Dat.Oformlenie:=Oforml;
   If Oforml=1 Then
   Begin
   Lh^.Dat.DocReal:=StrToInt(Doc);
   Lh^.Dat.DocDate:=DateStringToDate(DateMask,Date);
   End;


   Seek(HeaderFile,FilePos(HeaderFile)-1);
   Write(HeaderFile,Lh^.DAt);
   {Seek(HeaderFile,FilePos(HeaderFile)-1);}


   Repeat
    UnLock(MarketFile,FilePos(MarketFile)*SizeOf(ZakazType),SizeOf(ZakazType))
   Until Doserror=0;
   SetZakazStatus:=True;
 End;
   Dispose(E,Done);
   Dispose(Lh,Done);
   c:=IOResult;
   Close(MarketFile);
   c:=IOResult;
   Close(HeaderFile);
   c:=IOResult;
End;




Function UnLockZakaz(Doc:ArtikulStr):Word;
{0 деблокировка прошла нормально
 1 не смог деблокировать
 2 документ не найден
 3 ошибка сетевого открытия}

{0 деблокировка прошла нормально
 2 документ не найден
 1 не смог деблокировать
 3 ошибка сетевого открытия}
Var C : Byte;
    Find : Boolean;
    MarketFile : ZakazFileType;
    Test : PZakazType;
Begin
  Doc:=IntToStr(Strtoint(Doc),CArtikul);
  UnlockZakaz:=3;
  C:=IOResult;
  Assign(MarketFile,Path^.Dat.ToMarket+'zakaz.db');
  Reset(MarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла заказов !'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    UnlockZakaz:=3;
    C:=IOResult;
    Exit;
   End;

   Seek(MarketFile,0);

   DelSpace(Doc);
   DelZerro(Doc);
   Find:=False;

If (StrToInt(Doc)-1)<0 Then
 begin
      UnlockZakaz:=2;
      Close(MarketFile);
      MessageBox(#3^M+#3'Заказ N '+ Doc+' в базе за не найден!',
         Nil,mfError+mfCancelButton);
      Exit;
 end;

   New(Test,Init);
   {цикл поиска накладной}

   {оптимизация поиска}
   If FileSize(MarketFile)>(StrToInt(Doc)-1) Then
    Begin
     Seek(MarketFile,StrToInt(Doc)-1);
     ReadZakaz(MarketFile,Test);
     DelSpace(Test^.DAt.Document);
     DelZerro(Test^.Dat.Document);
     If (StrToInt(Test^.DAt.Document)=StrToInt(Doc)) Then
            Begin
             Find:=True;
         End
         Else Seek(MarketFile,0);
    End;

   C:=IOResult;


   While Not(eof(MarketFile)) And Not(Find) Do
    Begin
     ReadZakaz(MarketFile,Test);
     DelSpace(Test^.DAt.Document);
     DelZerro(Test^.Dat.Document);
     If (StrToInt(Test^.DAt.Document)=StrToInt(Doc))  Then Find:=True;
    End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      Dispose(test,Done);
      UnlockZakaz:=2;
      Close(MarketFile);
      MessageBox(#3^M+#3'Заказ N '+ Doc+' в базе за не найден!',
         Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}

   DInfoNetMsg('Деблокирую заказ N '+Doc+' ...');
   UnlockZakaz:=1;
   Seek(MarketFile,FilePos(MarketFile)-1);
   C:=IOResult;

 If Lock(MarketFile,FilePos(MarketFile)*SizeOf(ZakazType),SizeOf(ZakazType)) Then
 Begin
   Read(MarketFile,Test^.Dat);
   {проведение вторичной блокировки}
   Test^.DAt.Locked:=False;
   Seek(MarketFile,FilePos(MarketFile)-1);
   Write(MarketFile,Test^.DAt);
   Seek(MarketFile,FilePos(MarketFile)-1);
   Repeat
   UnLock(MarketFile,FilePos(MarketFile)*SizeOf(ZakazType),SizeOf(ZakazType))
   Until Doserror=0;
   UnlockZakaz:=0;
   NoNetInfoMsg;
   Close(MarketFile);
   Dispose(Test,Done);
 End
   Else
      Begin
       NoNetInfoMsg;
       UnlockZakaz:=1;
       Close(MarketFile);
       Dispose(Test,Done);
      End;
End;


(*
Function SetMeraLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of MeraType;
    l : LongInt;
    Code : Integer;
    s : MeraType;
    st : ArtikulStr;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую единицу измерения с кодом '+c);
 SetMeraLock:=False;
 Assign (F,Path^.Dat.ToSPR+'mera.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла единиц измерения!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Блокировка единицы измерения - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;


   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(MeraType),SizeOf(MeraType));{предварительная блокировка}
     Read(f,s);

     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorField(FNAme,Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(MeraType),SizeOf(MeraType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(MeraType),SizeOf(MeraType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetMeraLock:=True;
      Exit;
  End;
End;




Function SetMeraUnLock(c:ArtikulStr):Boolean;
Var f : File of MeraType;
    l : LongInt;
    Code : Integer;
    s : MeraType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую единицу измерения с кодом '+c);
 SetMeraUnLock:=False;

 Assign (F,Path^.Dat.ToSPR+'Mera.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла единиц измерения!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Деблокировка единицы измерения - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(MeraType),SizeOf(MeraType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;
   s.ComputerNameLocked[0]:=#0;
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(MeraType),SizeOf(MeraType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetMeraUnLock:=True;
  End;
End;

*)

Function WriteLockMera(ClientElement:MeraType):Boolean;
Var f : File Of MeraType;
 flck : File Of LockBAzType;
    c : LongInt;
    lck : LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию об единице измерения с кодом '+ClientElement.Kod+'...');
WriteLockMera:=False;
  Assign (F,Path^.Dat.ToSPR+'Mera.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла единиц измерения!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'Mera.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла единиц измерения!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Lck.BazKod:=ClientElement.Kod;
   Seek(f,c);
   Seek(flck,c);

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(MeraType),SizeOf(MeraType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

   ClientElement.RCD:=True;

{$IFDEF NetVersion}
   lck.Locked:=True;
   lck.LockCaption:=CurrentPassword;
   lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Write(flck,lck);
   Seek(flck,Filepos(flck)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(MeraType),SizeOf(MeraType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   Close(flck);
   NoNetInfoMsg;
   WriteLockMera:=True;
End;


(*
Function TestEmployMeraAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of MeraType;
    c : LongInt;
    s : MeraType;
Begin
DInfoNetMsg('Блокирую единицу измерения с кодом '+TestCod);
TestEmployMeraAndLock:=False;
Assign (F,Path^.Dat.ToSPR+'Mera.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла единиц измерения!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(MeraType),SizeOf(MeraType)); {предварительная блокировка}

     Read(f,s);

     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(MeraType),SizeOf(MeraType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(MeraType),SizeOf(MeraType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(MeraType),SizeOf(MeraType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployMeraAndLock:=True;
      Exit;
End;




Function SetKSertifLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of KSertifType;
    l : LongInt;
    Code : Integer;
    s : KSertifType;
    st : ArtikulStr;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую орган сертификации с кодом '+c);
 SetKSertifLock:=False;
 Assign (F,Path^.Dat.ToSPR+'KSertif.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла органов сертификации!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Блокировка органа сертификации - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;


   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(KSertifType),SizeOf(KSertifType));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorField(FNAme,Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(KSertifType),SizeOf(KSertifType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(KSertifType),SizeOf(KSertifType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetKSertifLock:=True;
      Exit;
  End;
End;




Function SetKSertifUnLock(c:ArtikulStr):Boolean;
Var f : File of KSertifType;
    l : LongInt;
    Code : Integer;
    s : KSertifType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую орган сертификации с кодом '+c);
 SetKSertifUnLock:=False;

 Assign (F,Path^.Dat.ToSPR+'KSertif.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла органа сертификации!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Деблокировка органа сертификации - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(KSertifType),SizeOf(KSertifType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;
   s.ComputerNameLocked[0]:=#0;
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(KSertifType),SizeOf(KSertifType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetKSertifUnLock:=True;
  End;
End;
*)

Function WriteLockKSertif(ClientElement:KSertifType):Boolean;
Var f : File Of KSertifType;
 flck : File Of LockBAzType;
    c : LongInt;
    lck : LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию об органе сертификации с кодом '+ClientElement.Kod+'...');
WriteLockKSertif:=False;
  Assign (F,Path^.Dat.ToSPR+'KSertif.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла органов сертификации!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'KSertif.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла органов сертификации!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Lck.BazKod:=ClientElement.Kod;
   Seek(f,c);
   Seek(flck,c);

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(KSertifType),SizeOf(KSertifType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

   ClientElement.RCD:=True;

{$IFDEF NetVersion}
   lck.Locked:=True;
   lck.LockCaption:=CurrentPassword;
   lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Write(flck,lck);
   Seek(flck,Filepos(flck)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(KSertifType),SizeOf(KSertifType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   Close(flck);
   NoNetInfoMsg;
   WriteLockKSertif:=True;
End;


(*
Function TestEmployKSertifAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of KSertifType;
    c : LongInt;
    s : KSertifType;
Begin
DInfoNetMsg('Блокирую орган сертификации с кодом '+TestCod);
TestEmployKSertifAndLock:=False;
Assign (F,Path^.Dat.ToSPR+'KSertif.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла органов сертификации!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(KSertifType),SizeOf(KSertifType)); {предварительная блокировка}

     Read(f,s);

     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(KSertifType),SizeOf(KSertifType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(KSertifType),SizeOf(KSertifType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(KSertifType),SizeOf(KSertifType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployKSertifAndLock:=True;
      Exit;
End;




Function SetMarkaLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of MarkaType;
    l : LongInt;
    Code : Integer;
    s : MarkaType;
    st : ArtikulStr;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую акцизную марку с кодом '+c);
 SetMarkaLock:=False;
 Assign (F,Path^.Dat.ToSPR+'Marka.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла акцизных марок!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Блокировка акцизных марок - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;


   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(MarkaType),SizeOf(MarkaType));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorField(FNAme,Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(MarkaType),SizeOf(MarkaType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(MarkaType),SizeOf(MarkaType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetMarkaLock:=True;
      Exit;
  End;
End;




Function SetMarkaUnLock(c:ArtikulStr):Boolean;
Var f : File of MarkaType;
    l : LongInt;
    Code : Integer;
    s : MarkaType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую акцизную марку с кодом '+c);
 SetMarkaUnLock:=False;

 Assign (F,Path^.Dat.ToSPR+'Marka.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла акцизных марок!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Деблокировка акцизных марок - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(MarkaType),SizeOf(MarkaType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;
   s.ComputerNameLocked[0]:=#0;
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(MarkaType),SizeOf(MarkaType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetMarkaUnLock:=True;
  End;
End;
*)

Function WriteLockMarka(ClientElement:MarkaType):Boolean;
Var f : File Of MarkaType;
 flck : File Of LockBAzType;
    c : LongInt;
    lck : LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию об акц.марке с кодом '+ClientElement.Kod+'...');
WriteLockMarka:=False;
  Assign (F,Path^.Dat.ToSPR+'Marka.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла органов акц.марок!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'Marka.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла акц.марок!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Lck.BazKod:=ClientElement.Kod;
   Seek(f,c);
   Seek(flck,c);

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(MarkaType),SizeOf(MarkaType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

   ClientElement.RCD:=True;

{$IFDEF NetVersion}
   lck.Locked:=True;
   lck.LockCaption:=CurrentPassword;
   lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Write(flck,lck);
   Seek(flck,Filepos(flck)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(MarkaType),SizeOf(MarkaType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   Close(flck);
   NoNetInfoMsg;
   WriteLockMarka:=True;
End;


(*
Function TestEmployMarkaAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of MarkaType;
    c : LongInt;
    s : MarkaType;
Begin
DInfoNetMsg('Блокирую акцизную марку с кодом '+TestCod);
TestEmployMarkaAndLock:=False;
Assign (F,Path^.Dat.ToSPR+'Marka.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла акцизных марок!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(MarkaType),SizeOf(MarkaType)); {предварительная блокировка}

     Read(f,s);

     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(MarkaType),SizeOf(MarkaType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(MarkaType),SizeOf(MarkaType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(MarkaType),SizeOf(MarkaType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployMarkaAndLock:=True;
      Exit;
End;

Function SetExpertLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of ExpertType;
    l : LongInt;
    Code : Integer;
    s : ExpertType;
    st : ArtikulStr;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую экспертное заключение с кодом '+c);
 SetExpertLock:=False;
 Assign (F,Path^.Dat.ToSPR+'Expert.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла эксп.заключений!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Блокировка экспертн.заключения - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;


   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(ExpertType),SizeOf(ExpertType));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorField(FNAme,Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(ExpertType),SizeOf(ExpertType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(ExpertType),SizeOf(ExpertType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetExpertLock:=True;
      Exit;
  End;
End;




Function SetExpertUnLock(c:ArtikulStr):Boolean;
Var f : File of ExpertType;
    l : LongInt;
    Code : Integer;
    s : ExpertType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую экспертное заключение с кодом '+c);
 SetExpertUnLock:=False;

 Assign (F,Path^.Dat.ToSPR+'Expert.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла экспертных заключений!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Деблокировка экспертных заключений - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(ExpertType),SizeOf(ExpertType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;
   s.ComputerNameLocked[0]:=#0;
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(ExpertType),SizeOf(ExpertType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetExpertUnLock:=True;
  End;
End;
*)

Function WriteLockExpert(ClientElement:ExpertType):Boolean;
Var f : File Of ExpertType;
 flck : File Of LockBAzType;
    c : LongInt;
    lck : LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию об экспертном заключении с кодом '+ClientElement.Kod+'...');
WriteLockExpert:=False;
  Assign (F,Path^.Dat.ToSPR+'Expert.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла экспертных заключений!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'Expert.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла экспертных заключений!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Lck.BazKod:=ClientElement.Kod;
   Seek(f,c);
   Seek(flck,c);

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(ExpertType),SizeOf(ExpertType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

   ClientElement.RCD:=True;

{$IFDEF NetVersion}
   lck.Locked:=True;
   lck.LockCaption:=CurrentPassword;
   lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Write(flck,lck);
   Seek(flck,Filepos(flck)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(ExpertType),SizeOf(ExpertType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   Close(flck);
   NoNetInfoMsg;
   WriteLockExpert:=True;
End;



(*
Function TestEmployExpertAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of ExpertType;
    c : LongInt;
    s : ExpertType;
Begin
DInfoNetMsg('Блокирую экспертное заключение с кодом '+TestCod);
TestEmployExpertAndLock:=False;
Assign (F,Path^.Dat.ToSPR+'Expert.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла экспертных заключений марок!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(ExpertType),SizeOf(ExpertType)); {предварительная блокировка}

     Read(f,s);

     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(ExpertType),SizeOf(ExpertType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(ExpertType),SizeOf(ExpertType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(ExpertType),SizeOf(ExpertType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployExpertAndLock:=True;
      Exit;
End;





Function SetNGTDLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of NGTDType;
    l : LongInt;
    Code : Integer;
    s : NGTDType;
    st : ArtikulStr;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую ГТД с кодом '+c);
 SetNGTDLock:=False;
 Assign (F,Path^.Dat.ToSPR+'NGTD.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла ГТД !',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Блокировка ГТД - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;


   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(NGTDType),SizeOf(NGTDType));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorField(FNAme,Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(NGTDType),SizeOf(NGTDType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(NGTDType),SizeOf(NGTDType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetNGTDLock:=True;
      Exit;
  End;
End;




Function SetNGTDUnLock(c:ArtikulStr):Boolean;
Var f : File of NGTDType;
    l : LongInt;
    Code : Integer;
    s : NGTDType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую ГТД с кодом '+c);
 SetNGTDUnLock:=False;

 Assign (F,Path^.Dat.ToSPR+'NGTD.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла ГТД!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Деблокировка ГТД - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(NGTDType),SizeOf(NGTDType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;
   s.ComputerNameLocked[0]:=#0;
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(NGTDType),SizeOf(NGTDType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetNGTDUnLock:=True;
  End;
End;
*)


Function WriteLockngtd(ClientElement:ngtdType):Boolean;
Var f : File Of ngtdType;
 flck : File Of LockBAzType;
    c : LongInt;
    lck : LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию об ГТД с кодом '+ClientElement.Kod+'...');
WriteLockngtd:=False;
  Assign (F,Path^.Dat.ToSPR+'ngtd.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла ГТД!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'ngtd.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла ГТД!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Lck.BazKod:=ClientElement.Kod;
   Seek(f,c);
   Seek(flck,c);

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(ngtdType),SizeOf(ngtdType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

   ClientElement.RCD:=True;

{$IFDEF NetVersion}
   lck.Locked:=True;
   lck.LockCaption:=CurrentPassword;
   lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Write(flck,lck);
   Seek(flck,Filepos(flck)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(ngtdType),SizeOf(ngtdType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   Close(flck);
   NoNetInfoMsg;
   WriteLockngtd:=True;
End;


Function WriteLockClass(ClientElement:ClassificatorBuchType):Boolean;
Var f : File Of ClassificatorBuchType;
 flck : File Of LockBAzType;
    c : LongInt;
    lck : LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию о классе с кодом '+ClientElement.Kod+'...');
WriteLockClass:=False;
  Assign (F,Path^.Dat.ToSPR+'class.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла классов!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'class.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла классов!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Lck.BazKod:=ClientElement.Kod;
   Seek(f,c);
   Seek(flck,c);

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(ClassificatorBuchType),SizeOf(ClassificatorBuchType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

   ClientElement.RCD:=True;

{$IFDEF NetVersion}
   lck.Locked:=True;
   lck.LockCaption:=CurrentPassword;
   lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Write(flck,lck);
   Seek(flck,Filepos(flck)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(ClassificatorBuchType),SizeOf(ClassificatorBuchType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   Close(flck);
   NoNetInfoMsg;
   WriteLockClass:=True;
End;



Function WriteLockKassa(ClientElement:KassaOperationType):Boolean;
Var f : File Of KassaOperationType;
 flck : File Of LockBAzType;
    c : LongInt;
  lck : LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию об операции с кодом '+ClientElement.Kod+'...');
WriteLockKassa:=False;
  Assign (F,Path^.Dat.ToSPR+'Kassa.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия справочника кассовых операций!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'Kassa.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия справочника кассовых операций!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Lck.BazKod:=ClientElement.Kod;
   Seek(f,c);
   Seek(flck,c);

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(KassaOperationType),SizeOf(KassaOperationType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

   ClientElement.RCD:=True;
   ClientElement.DateM:=DateStringToDate(DateMask,FDate);
   ClientElement.TimeM:=TimeStringToTime(TimeMask,Times);
   ClientElement.Caption:=CurrentPassword;

{$IFDEF NetVersion}
   lck.Locked:=True;
   lck.LockCaption:=CurrentPassword;
   lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Write(flck,lck);
   Seek(flck,Filepos(flck)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(KassaOperationType),SizeOf(KassaOperationType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   Close(flck);
   NoNetInfoMsg;
   WriteLockKassa:=True;
End;


Function WriteLockPersonal(ClientElement:PersonalType):Boolean;
Var f : File Of PersonalType;
 flck : File Of LockBAzType;
    c : LongInt;
  lck : LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию о сотруднике с кодом '+ClientElement.Kod+'...');
WriteLockPersonal:=False;
  Assign (F,Path^.Dat.ToSPR+'Personal.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия справочника персонала!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'Personal.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия справочника персонала!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Lck.BazKod:=ClientElement.Kod;
   Seek(f,c);
   Seek(flck,c);

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(PersonalType),SizeOf(PersonalType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

   ClientElement.RCD:=True;
   ClientElement.DateM:=DateStringToDate(DateMask,FDate);
   ClientElement.TimeM:=TimeStringToTime(TimeMask,Times);
   ClientElement.Caption:=CurrentPassword;

{$IFDEF NetVersion}
   lck.Locked:=True;
   lck.LockCaption:=CurrentPassword;
   lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Write(flck,lck);
   Seek(flck,Filepos(flck)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(PersonalType),SizeOf(PersonalType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   Close(flck);
   NoNetInfoMsg;
   WriteLockPersonal:=True;
End;




Function WriteLockBank(ClientElement:BankType):Boolean;
Var f : File Of BankType;
 flck : File Of LockBAzType;
    c : LongInt;
  lck : LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию о банке с кодом '+ClientElement.Kod+'...');
WriteLockBank:=False;
  Assign (F,Path^.Dat.ToSPR+'Banks.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия справочника банков!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'Banks.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия справочника банков!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Lck.BazKod:=ClientElement.Kod;
   Seek(f,c);
   Seek(flck,c);

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(BankType),SizeOf(BankType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

   ClientElement.RCD:=True;
   ClientElement.DateM:=ToDay;
   ClientElement.Caption:=CurrentPassword;
   ClientElement.TimeM:=CurrentTime;

{$IFDEF NetVersion}
   lck.Locked:=True;
   lck.LockCaption:=CurrentPassword;
   lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Write(flck,lck);
   Seek(flck,Filepos(flck)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(BankType),SizeOf(BankType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   Close(flck);
   NoNetInfoMsg;
   WriteLockBank:=True;
End;



(*
Function TestEmployNGTDAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of NGTDType;
    c : LongInt;
    s : NGTDType;
Begin
DInfoNetMsg('Блокирую ГТД с кодом '+TestCod);
TestEmployNGTDAndLock:=False;
Assign (F,Path^.Dat.ToSPR+'NGTD.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла ГТД!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(NGTDType),SizeOf(NGTDType)); {предварительная блокировка}

     Read(f,s);

     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(NGTDType),SizeOf(NGTDType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(NGTDType),SizeOf(NGTDType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(NGTDType),SizeOf(NGTDType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmployNGTDAndLock:=True;
      Exit;
End;




Function SetSpecMarkaLock(c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of SpecMarkaType;
    l : LongInt;
    Code : Integer;
    s : SpecMarkaType;
    st : ArtikulStr;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую спец.марку с кодом '+c);
 SetSpecMarkaLock:=False;
 Assign (F,Path^.Dat.ToSPR+'SMarka.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла спец.марок!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Блокировка спец.марок - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType));{предварительная блокировка}
     Read(f,s);
     If s.Locked Then{если позиция кем-то занята}
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorField(FNAme,Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetSpecMarkaLock:=True;
      Exit;
  End;
End;




Function SetSpecMarkaUnLock(c:ArtikulStr):Boolean;
Var f : File of SpecMarkaType;
    l : LongInt;
    Code : Integer;
    s : SpecMarkaType;
    st : ArtikulStr;
Begin
 DInfoNetMsg('Деблокирую спец.марку с кодом '+c);
 SetSpecMarkaUnLock:=False;

 Assign (F,Path^.Dat.ToSPR+'SMarka.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла спец.марок!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Деблокировка спец.марок - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;
   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;
   s.ComputerNameLocked[0]:=#0;
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetSpecMarkaUnLock:=True;
  End;
End;
*)

Function WriteLockSpecMarka(ClientElement:SpecMarkaType):Boolean;
Var f : File Of SpecMarkaType;
 flck : File Of LockBAzType;
    c : LongInt;
    s : SpecMarkaType;
    lck : LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию об спец.марке с кодом '+ClientElement.Kod+'...');
WriteLockSpecMarka:=False;
  Assign (F,Path^.Dat.ToSPR+'SMarka.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла спец.марок!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'SMarka.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла спец.марок!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Lck.BazKod:=ClientElement.Kod;
   Seek(f,c);
   Seek(flck,c);

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

   ClientElement.RCD:=True;

{$IFDEF NetVersion}
   lck.Locked:=True;
   lck.LockCaption:=CurrentPassword;
   lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Write(flck,lck);
   Seek(flck,Filepos(flck)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   Close(flck);
   NoNetInfoMsg;
   WriteLockSpecMarka:=True;
End;



(*
Function TestEmploySpecMarkaAndLock(TestCod:ArtikulStr):Boolean;
Var f : File Of SpecMarkaType;
    c : LongInt;
    s : SpecMarkaType;
Begin
DInfoNetMsg('Блокирую спец.марку с кодом '+TestCod);
TestEmploySpecMarkaAndLock:=False;
Assign (F,Path^.Dat.ToSPR+'SMarka.db');
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла спец.марок!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType)); {предварительная блокировка}

     Read(f,s);

     If s.Locked Then{если позиция кем-то занята}
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;
     if s.employ then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      end;
{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      s.Kod:=TestCod;
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      TestEmploySpecMarkaAndLock:=True;
      Exit;
End;


*)

Function WriteLockRegion(ClientElement:RegionType):Boolean;
Var f : File Of RegionType;
 flck : File Of LockBAzType;
    c : LongInt;
    s : RegionType;
    lck : LockBazType;
Begin
DInfoNetMsg('Сохраняю информацию о регионе с кодом '+ClientElement.Kod+'...');
WriteLockRegion:=False;
  Assign (F,Path^.Dat.ToSPR+'region.db');
  c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла регионов!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  Assign (Flck,Path^.Dat.ToSPR+'region.lck');
  c:=IOResult;
  Reset(flck);
  c:=IOResult;
  If c<>0 Then
   Begin
    Close(f);
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла регионов!',Nil,mfError+mfCancelButton);
    Exit;
   End;

   DelSpace(ClientElement.Kod);
   c:=StrToInt(ClientElement.Kod);
   Lck.BazKod:=ClientElement.Kod;
   Seek(f,c);
   Seek(flck,c);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(RegionType),SizeOf(RegionType)));

   Repeat
   Pause(1);
   Until (Lock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType)));

   ClientElement.RCD:=True;

{$IFDEF NetVersion}
   lck.Locked:=True;
   lck.LockCaption:=CurrentPassword;
   lck.LockTime:=CurrentTime;
   lck.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Write(f,ClientElement);
   Seek(f,Filepos(f)-1);
   Write(flck,lck);
   Seek(flck,Filepos(flck)-1);

   Repeat
   Unlock(f,FilePos(f)*SizeOf(RegionType),SizeOf(RegionType));
   Until DosError=0;

   Repeat
   Unlock(flck,FilePos(flck)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
  c:=IOResult;
   Close(f);
  c:=IOResult;
   Close(flck);
  c:=IOResult;
   NoNetInfoMsg;
   WriteLockRegion:=True;
End;




Function SetElementLock(Vid:Word;c:ArtikulStr;Var Operator:StrNAme):Boolean;
Var f : File of LockBazType;
    l : LongInt;
    Code : Integer;
    s : LockBazType;
    st : ArtikulStr;
    ppp : String;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую элемент с кодом '+c);
 SetElementLock:=False;
 Case Vid Of
 FPost:ppp:=Path^.Dat.ToSPR+'lands.lck';
 FFirmaPost:ppp:=Path^.Dat.ToSPR+'firma.lck';
 FMera:ppp:=Path^.Dat.ToSPR+'mera.lck';
 FKSertif:ppp:=Path^.Dat.ToSPR+'ksertif.lck';
 FGroup:ppp:=Path^.Dat.ToSPR+'group.lck';
 FMarka:ppp:=Path^.Dat.ToSPR+'marka.lck';
 FSpecMarka:ppp:=Path^.Dat.ToSPR+'smarka.lck';
 FNGTD:ppp:=Path^.Dat.ToSPR+'ngtd.lck';
 FExpert:ppp:=Path^.Dat.ToSPR+'expert.lck';
 FRoute:ppp:=Path^.Dat.ToSPR+'route.lck';
 FRegion:ppp:=Path^.Dat.ToSPR+'region.lck';
 FClass:ppp:=Path^.Dat.ToSPR+'class.lck';
 FPersonal:ppp:=Path^.Dat.ToSPR+'personal.lck';
 FKassa:ppp:=Path^.Dat.ToSPR+'kassa.lck';
 FBank :ppp:=Path^.Dat.ToSPR+'banks.lck';
 Else Exit;
 End;

 Assign (F,ppp);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+ppp+'!',nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Блокировка элемента - позиция вне файла '+ppp+'!',nil,mfError+mfCancelButton);
     Exit;
    End;


   Seek(f,l);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));{предварительная блокировка}

     Read(f,s);

    If EnableTempLock=1 Then
    if (Abs(s.LockTime-CurrentTime)>MaxLockTime) Then s.Locked:=False;

     If (s.Locked) Then{если позиция кем-то занята}
     If (s.LockCaption<>CurrentPassword) Or (s.ComputerNameLocked<>NetComputerName) Then
      Begin
       If S.LockCAption[0]<>#0 Then
       Begin
       Operator:=s.LockCaption;
       DelSpace(Operator);
       DelSpaceRight(s.ComputerNameLocked);
       Operator:=': '+GetOperatorField(FNAme,Operator)+' \\'+s.ComputerNameLocked;
       End;
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;


{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.LockTime:=CurrentTime;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}
      Seek(f,Filepos(f)-1);
      Write(f,s);
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
      Until DosError=0;
      Close(f);
      NoNetInfoMsg;
      SetElementLock:=True;
      Exit;
  End;
End;


Function SetElementUnLock(Vid:Word;c:ArtikulStr):Boolean;
Var f : File of LockBazType;
    l : LongInt;
    Code : Integer;
    s : LockBazType;
    st : ArtikulStr;
    ppp : String;
Begin
 DInfoNetMsg('Деблокирую элемент с кодом '+c);
 SetElementUnLock:=False;

 Case Vid Of
 FPost:ppp:=Path^.Dat.ToSPR+'lands.lck';
 FFirmaPost:ppp:=Path^.Dat.ToSPR+'firma.lck';
 FMera:ppp:=Path^.Dat.ToSPR+'mera.lck';
 FKSertif:ppp:=Path^.Dat.ToSPR+'Ksertif.lck';
 FGroup:ppp:=Path^.Dat.ToSPR+'group.lck';
 FMarka:ppp:=Path^.Dat.ToSPR+'marka.lck';
 FSpecMarka:ppp:=Path^.Dat.ToSPR+'smarka.lck';
 FNGTD:ppp:=Path^.Dat.ToSPR+'ngtd.lck';
 FExpert:ppp:=Path^.Dat.ToSPR+'expert.lck';
 FRoute:ppp:=Path^.Dat.ToSPR+'route.lck';
 FRegion:ppp:=Path^.Dat.ToSPR+'region.lck';
 FClass:ppp:=Path^.Dat.ToSPR+'class.lck';
 FPersonal:ppp:=Path^.Dat.ToSPR+'personal.lck';
 FKassa:ppp:=Path^.Dat.ToSPR+'kassa.lck';
 FBank :ppp:=Path^.Dat.ToSPR+'banks.lck';
 Else Exit;
 End;

 Assign (F,ppp);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^m+#3'Ошибка сетевого открытия файла '+ppp+'!',nil,mfError+mfCancelButton);
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
     MessageBox(^M+#3'Деблокировка элемента - позиция вне файла '+ppp+'!',nil,mfError+mfCancelButton);
     Exit;
    End;


   Seek(f,l);
   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType)));
   Read(f,s);
   s.Locked:=False;            {проведение вторичной деблокировки}
   s.LockCaption[0]:=#0;
   s.ComputerNameLocked[0]:=#0;
   Seek(f,Filepos(f)-1);
   Write(f,s);
   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
   Until DosError=0;
   Close(f);
   NoNetInfoMsg;
   SetElementUnLock:=True;
  End;
End;


Function TestEmployElementAndLock(Vid:Word;TestCod:ArtikulStr):Boolean;
Var f : File Of LockBazType;
    c : LongInt;
    s : LockBazType;
    ppp : String;
    Empl : Boolean;
Begin
DInfoNetMsg('Блокирую эелемент с кодом '+TestCod);
TestEmployElementAndLock:=False;

 Case Vid Of
 FPost:ppp:=Path^.Dat.ToSPR+'lands.lck';
 FFirmaPost:ppp:=Path^.Dat.ToSPR+'firma.lck';
 FMera:ppp:=Path^.Dat.ToSPR+'mera.lck';
 FKSertif:ppp:=Path^.Dat.ToSPR+'ksertif.lck';
 FGroup:ppp:=Path^.Dat.ToSPR+'group.lck';
 FMarka:ppp:=Path^.Dat.ToSPR+'marka.lck';
 FSpecMarka:ppp:=Path^.Dat.ToSPR+'smarka.lck';
 FNGTD:ppp:=Path^.Dat.ToSPR+'ngtd.lck';
 FExpert:ppp:=Path^.Dat.ToSPR+'expert.lck';
 FRoute:ppp:=Path^.Dat.ToSPR+'route.lck';
 FRegion:ppp:=Path^.Dat.ToSPR+'region.lck';
 FClass:ppp:=Path^.Dat.ToSPR+'class.lck';
 FPersonal:ppp:=Path^.Dat.ToSPR+'personal.lck';
 FKassa:ppp:=Path^.Dat.ToSPR+'kassa.lck';
 FBank :ppp:=Path^.Dat.ToSPR+'banks.lck';
 Else Exit;
 End;

Assign (F,ppp);
c:=IOResult;
  Reset(f);
  c:=IOResult;
  If c<>0 Then
   Begin
    NoNetInfoMsg;
    MessageBox(^M+#3'Ошибка сетевого открытия файла '+ppp+'!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   DelSpace(TestCod);
   c:=StrToInt(testCod);
   Seek(f,c);
   Repeat
   Pause(1);
   Until Lock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType)); {предварительная блокировка}

     Read(f,s);

     If s.Locked Then{если позиция кем-то занята}
     If (s.LockCaption<>CurrentPassword) Or (s.ComputerNameLocked<>NetComputerName) Then
      Begin
       Seek(f,Filepos(f)-1);
       Repeat
       Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
       Until DosError=0;
       NoNetInfoMsg;
       Close(f);
       Exit;
      End;

     Empl:=True;

 Case Vid Of
 FPost:Empl:=GetPostEmploy(TestCod);
 FFirmaPost:Empl:=GetFirmaPostEmploy(TestCod);
 FMera:Empl:=GetMeraEmploy(TestCod);
 FKSertif:Empl:=GetKSertifEmploy(TestCod);
 FGroup:Empl:=GetGroupEmploy(TestCod);
 FMarka:Empl:=GetMarkaEmploy(TestCod);
 FSpecMarka:Empl:=GetSpecMarkaEmploy(TestCod);
 FNGTD:Empl:=GetNGTDEmploy(TestCod);
 FExpert:Empl:=GetExpertEmploy(TestCod);
 FRoute:Empl:=GetRouteEmploy(TestCod);
 FRegion:Empl:=GetRegionEmploy(TestCod);
 FClass:Empl:=GetClassEmploy(TestCod);
 FPersonal:Empl:=GetPersonalEmploy(TestCod);
 FKassa:Empl:=GetKassaOperationEmploy(TestCod);
 FBank :Empl:=GetBankEmploy(TestCod);
 Else Exit;
 End;

     if Empl then {если позиция ужу помечена как используемая}
      begin
       Seek(f,Filepos(f)-1);
       Repeat
        Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
       Until DosError=0;
       NoNetInfoMsg;
       c:=IOResult;
       Close(f);
       c:=IOResult;
       Exit;
      end;

{$IFDEF NetVersion}
      s.Locked:=True;            {проведение вторичной блокировки}
      s.LockCaption:=CurrentPassword;
      s.ComputerNameLocked:=NetComputerName;
{$ENDIF}

      s.bazKod:=TestCod;
      Seek(f,Filepos(f)-1);
      c:=IOResult;
      Write(f,s);
      c:=IOResult;
      Seek(f,Filepos(f)-1);
      Repeat
      Unlock(f,FilePos(f)*SizeOf(LockBazType),SizeOf(LockBazType));
      Until DosError=0;
      c:=IOResult;
      Close(f);
      c:=IOResult;
      NoNetInfoMsg;
      TestEmployElementAndLock:=True;
      Exit;

End;


Function LockPredZakaz(EditPosition:ArtikulStr;Var E:PPredZakazType):Word;
{функция возвращает 0 если все прошло ок
0 все ок
1 если документ не найден
2 если не удалось заблокировать накладную
3 ошибка сетевого открытия файла продаж
4 если по документу оформлен заказ
5 если заказ онулирован по времени}
Var C : Byte;
    Find : Boolean;
    MarketFile : PredZakazFileType;
    Pos : LongInt;
Begin
  LockPredZakaz:=3;
  C:=IOResult;
  Assign(MarketFile,Path^.Dat.ToMarket+'PZakaz.db');
  Reset(MarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла предзаказов!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    C:=IOResult;
    LockPredZakaz:=3;
    Exit;
   End;

   Seek(MarketFile,0);

   DelSpace(EditPosition);
   DelZerro(EditPosition);
   EditPosition:=ClearChar(EditPosition);
   Find:=False;

If (StrToInt(EditPosition)-1)<0 Then
    Begin
      LockPredZakaz:=1;
      Close(MarketFile);
      MessageBox(#3^M+#3'ПредЗаказ N '+ EditPosition+' в базе не найден!',Nil,mfError+mfCancelButton);
      Exit;
    End;


If (StrToInt(EditPosition)-1)>=0 Then
If (FileSize(MarketFile)>(StrToInt(EditPosition)-1))
    Then
 Begin
     Seek(MarketFile,StrToInt(EditPosition)-1);
     ReadPredZakaz(MarketFile,E);
     DelSpace(E^.DAt.Document);
     DelZerro(E^.Dat.Document);

     If (StrToInt(E^.DAt.Document)=StrToInt(EditPosition))
         Then
            Begin
             Find:=True;
         End;
 End;



  {если накладная не найдена}
   If Not(Find) Then
    Begin
      LockPredZakaz:=1;
      Close(MarketFile);
      MessageBox(#3^M+#3'ПредЗаказ N '+ EditPosition+' в базе не найден!',Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}
   DInfoNetMsg('Блокирую предзаказ N '+EditPosition+'...');
   LockPredZakaz:=2;
   Seek(MarketFile,FilePos(MarketFile)-1);
   Repeat
   Pause(1);
   Until Lock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType));
   Read(MarketFile,E^.Dat);

   {если документ уже заблокирован}
   If (E^.Dat.Locked) Then
    Begin
     NoNetInfoMsg;
     LockPredZakaz:=2;
     {снятие предварительной блокировки}
     Seek(MarketFile,FilePos(MarketFile)-1);
     Repeat
      UnLock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType))
     Until Doserror=0;
     Close(MarketFile);
     Exit;
    End;

    If (E^.Dat.Status=5)Then
    Begin
        MessageBox(^M+#3'По предзаказу уже оформлен заказ!',Nil, mfWarning+mfCancelButton);
        NoNetInfoMsg;
        LockPredZakaz:=4;
        {снятие предварительной блокировки}
        Seek(MarketFile,FilePos(MarketFile)-1);
        Repeat
         UnLock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType))
        Until Doserror=0;
        Close(MarketFile);
        Exit;
    End;

    If (E^.Dat.Status=6)Then
    Begin
        MessageBox(^M+#3+'ПредЗаказ анулирован!',Nil, mfWarning+mfCancelButton);
        NoNetInfoMsg;
        LockPredZakaz:=5;
        {снятие предварительной блокировки}
        Seek(MarketFile,FilePos(MarketFile)-1);
        Repeat
         UnLock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType))
        Until Doserror=0;
        Close(MarketFile);
        Exit;
    End;


    If (E^.Dat.Status in [0,1,2,3])Then
    Begin
        MessageBox(#3+'Недопустимый статус ПредЗаказа!',Nil, mfWarning+mfCancelButton);
        NoNetInfoMsg;
        LockPredZakaz:=5;
        {снятие предварительной блокировки}
        Seek(MarketFile,FilePos(MarketFile)-1);
        Repeat
         UnLock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType))
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
    UnLock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType))
   Until Doserror=0;
   LockPredZakaz:=0;
   NoNetInfoMsg;
   Close(MarketFile);
End;


Function LockPredZakazSpecial(EditPosition:ArtikulStr;Var E:PPredZakazType):Word;
{функция возвращает 0 если все прошло ок
0 все ок
1 если документ не найден
2 если не удалось заблокировать накладную
3 ошибка сетевого открытия файла продаж
4 если по документу оформлен заказ
5 если заказ онулирован по времени}
Var C : Byte;
    Find : Boolean;
    MarketFile : PredZakazFileType;
    Pos : LongInt;
Begin
  LockPredZakazSpecial:=3;
  C:=IOResult;
  Assign(MarketFile,Path^.Dat.ToMarket+'PZakaz.db');
  Reset(MarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла предзаказов!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    C:=IOResult;
    LockPredZakazSpecial:=3;
    Exit;
   End;

   Seek(MarketFile,0);

   DelSpace(EditPosition);
   DelZerro(EditPosition);
   EditPosition:=ClearChar(EditPosition);
   Find:=False;

If (StrToInt(EditPosition)-1)<0 Then
    Begin
      LockPredZakazSpecial:=1;
      Close(MarketFile);
      MessageBox(#3^M+#3'ПредЗаказ N '+ EditPosition+' в базе не найден!',Nil,mfError+mfCancelButton);
      Exit;
    End;

If (FileSize(MarketFile)>(StrToInt(EditPosition)-1))
    Then
 Begin
     Seek(MarketFile,StrToInt(EditPosition)-1);
     ReadPredZakaz(MarketFile,E);
     DelSpace(E^.DAt.Document);
     DelZerro(E^.Dat.Document);

     If (StrToInt(E^.DAt.Document)=StrToInt(EditPosition))
         Then
            Begin
             Find:=True;
         End;
 End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      LockPredZakazSpecial:=1;
      Close(MarketFile);
      MessageBox(#3^M+#3'ПредЗаказ N '+ EditPosition+' в базе не найден!',Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}
   DInfoNetMsg('Блокирую предзаказ N '+EditPosition+'...');
   LockPredZakazSpecial:=2;
   Seek(MarketFile,FilePos(MarketFile)-1);
   Repeat
   Pause(1);
   Until Lock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType));
   Read(MarketFile,E^.Dat);

   {если документ уже заблокирован}
   If (E^.Dat.Locked) Then
    Begin
     NoNetInfoMsg;
     LockPredZakazSpecial:=2;
     {снятие предварительной блокировки}
     Seek(MarketFile,FilePos(MarketFile)-1);
     Repeat
      UnLock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType))
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
    UnLock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType))
   Until Doserror=0;
   LockPredZakazSpecial:=0;
   NoNetInfoMsg;
   Close(MarketFile);
End;



Function UnLockPredZakaz(Doc:ArtikulStr):Word;
{0 деблокировка прошла нормально
 1 не смог деблокировать
 2 документ не найден
 3 ошибка сетевого открытия}

{0 деблокировка прошла нормально
 2 документ не найден
 1 не смог деблокировать
 3 ошибка сетевого открытия}
Var C : Byte;
    Find : Boolean;
    MarketFile : PredZakazFileType;
    Test : PPredZakazType;
Begin
  Doc:=IntToStr(Strtoint(Doc),CArtikul);
  UnlockPredZakaz:=3;
  C:=IOResult;
  Assign(MarketFile,Path^.Dat.ToMarket+'PZakaz.db');
  Reset(MarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла предзаказов !'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    UnlockPredZakaz:=3;
    C:=IOResult;
    Exit;
   End;

   Seek(MarketFile,0);

   DelSpace(Doc);
   DelZerro(Doc);
   Find:=False;

If (StrToInt(Doc)-1)<0 Then
 begin
      UnlockPredZakaz:=2;
      Close(MarketFile);
      MessageBox(#3^M+#3'Заказ N '+ Doc+' в базе за не найден!',
         Nil,mfError+mfCancelButton);
      Exit;
 end;

   New(Test,Init);
   {цикл поиска накладной}

   {оптимизация поиска}
   If (StrToInt(Doc)-1)>=0 Then
   If FileSize(MarketFile)>(StrToInt(Doc)-1) Then
    Begin
     Seek(MarketFile,StrToInt(Doc)-1);
     ReadPredZakaz(MarketFile,Test);
     DelSpace(Test^.DAt.Document);
     DelZerro(Test^.Dat.Document);
     If (StrToInt(Test^.DAt.Document)=StrToInt(Doc)) Then
            Begin
             Find:=True;
         End
         Else Seek(MarketFile,0);
    End;

   C:=IOResult;


   While Not(eof(MarketFile)) And Not(Find) Do
    Begin
     ReadPredZakaz(MarketFile,Test);
     DelSpace(Test^.DAt.Document);
     DelZerro(Test^.Dat.Document);
     If (StrToInt(Test^.DAt.Document)=StrToInt(Doc))  Then Find:=True;
    End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      Dispose(test,Done);
      UnlockPredZakaz:=2;
      Close(MarketFile);
      MessageBox(#3^M+#3'ПредЗаказ N '+ Doc+' в базе за не найден!',
         Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}

   DInfoNetMsg('Деблокирую Предзаказ N '+Doc+' ...');
   UnlockPredZakaz:=1;
   Seek(MarketFile,FilePos(MarketFile)-1);
   C:=IOResult;

 If Lock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType)) Then
 Begin
   Read(MarketFile,Test^.Dat);
   {проведение вторичной блокировки}
   Test^.DAt.Locked:=False;
   Seek(MarketFile,FilePos(MarketFile)-1);
   Write(MarketFile,Test^.DAt);
   Seek(MarketFile,FilePos(MarketFile)-1);
   Repeat
   UnLock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType))
   Until Doserror=0;
   UnlockPredZakaz:=0;
   NoNetInfoMsg;
   Close(MarketFile);
   Dispose(Test,Done);
 End
   Else
      Begin
       NoNetInfoMsg;
       UnlockPredZakaz:=1;
       Close(MarketFile);
       Dispose(Test,Done);
      End;
End;


Function LockAndWritePredZakaz(Var L:PPredZakazType):Boolean;
{Параметр Mode указывает что это поступление товара на склад или
формирование и корректировка}
Var MarketFile : PredZakazFileType;
    HeaderFile : HeaderPredZakazFileType;
    c : Byte;
    Find : Boolean;
    Test : PPredZakazType;
    Er,Position,Code,Pos1,Pos2:LongInt;
    ChangeNumer : Boolean;
    Lh : PHeaderPredZakazType;
Begin
 LockAndWritePredZakaz:=False;
 Assign(MarketFile,Path^.Dat.ToMarket+'PZakaz.db');
 c:=IOResult;
{$I-}
 Reset(MarketFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox(^M+'Файл PZakaz.db не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil,
        mfConfirmation + mfOkCancel)=cmOk  Then
     Begin
      If Not(CreatToDayF(DocPredZakaz,DateToDateString(DateMask,L^.Dat.DateC))) Then Exit;
      Reset(MarketFile);
      c:=IOResult;
     End
    Else
     Begin
      Exit;
     End;
 End;

 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу PZakaz.db!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;


 Assign(HeaderFile,Path^.Dat.ToMarketIndex+'PZakaz.idx');
 c:=IOResult;
{$I-}
 Reset(HeaderFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox(^M+'Файл PZakaz.idx не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil,
        mfConfirmation + mfOkCancel)=cmOk  Then
     Begin
      If Not(CreatToDayF(DocPredZakaz,DateToDateString(DateMask,L^.Dat.DateC))) Then Exit;
      Reset(HeaderFile);
      c:=IOResult;
     End
    Else
     Begin
      Close(MarketFile);
      c:=IOResult;
      Exit;
     End;
 End;


 If c <> 0 Then Begin
                 Close(MarketFile);
                 c:=IOResult;
                 MessageBox(#3^M+#3'Нет доступа к файлу PZakaz.idx!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;


If (StrToInt(L^.Dat.Document)-1)<0 Then
 begin
   Close(MarketFile);
   If Status=DocEdit Then
   MessageBox(#3^M+#3'ПредЗаказ N '+ L^.Dat.Document+' в базе за '+DateToDateString(DateMask,L^.DAt.DAteC)+' не найден!',Nil,
   mfError+mfCancelButton)
   Else
   MessageBox(#3^M+#3'Недопустимый номер Предзаказа N '+ L^.Dat.Document+' в базе не найден!',Nil,
   mfError+mfCancelButton);
   Exit;
 end;


   New(Lh,Init);
   PredZakazToIndex(L,Lh);
{если открытие прошло нормально}
   If Status=DocEdit Then
    Begin
     {создаем новый экземпляр прихода}
     New(test,Init);
     Find := False;
     DelSPace(L^.DAt.Document);

   {оптимизация}

   If FileSize(MarketFile)>(StrToInt(L^.Dat.Document)-1) Then
    Begin
     Seek(MarketFile,StrToInt(L^.DAt.Document)-1);
     ReadPredZakaz(MarketFile,Test);
     DelSpace(Test^.DAt.Document);
     DelZerro(Test^.Dat.Document);
     If (StrToInt(Test^.Dat.Document)=StrToInt(L^.DAt.Document)) And
          (Test^.Dat.DateC=L^.DAt.DateC)
          Then
            Begin
             Find:=True;
         End
         Else Seek(MarketFile,0);
    End;


     {цикл поиска исходного документа в файле}
     While Not(Eof(MarketFile)) And Not(Find) Do
      Begin
       ReadPredZakaz(MarketFile,Test);

       DelSpace(Test^.Dat.Document);
       If (Test^.Dat.Document=L^.DAt.Document) And
          (Test^.Dat.DateC=L^.DAt.DateC)
           Then Find:=True;
      End;


      Dispose(Test,Done);

     {если документ не найден тогда выходим с сообщением}
     If Not(Find) Then
      Begin
       Close(MarketFile);
       MessageBox(#3^M+#3'ПредЗаказ N '+ L^.Dat.Document+' в базе за '+DateToDateString(DateMask,L^.DAt.DAteC)+' не найден!',
	  Nil,mfError+mfCancelButton);
       Exit;
      End;

     DInfoNetMsg('Сохраняю измененный Предзаказ N '+L^.Dat.Document+'...');
     {если мы нашли документ тогда блокируем его и записываем}
     Seek(MarketFile,FilePos(MarketFile)-1);

     {блокировка}
     Repeat
     Pause(1);
     Until (Lock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType)));
     {запись}

{$IFDEF NetVersion}
     L^.Dat.Locked:=True;
{$ENDIF}

     Inc(L^.Dat.Versia);
     Inc(Lh^.Dat.Versia);

     Write(MarketFile,L^.DAt);
     {снятие блокировки}
     Seek(MarketFile,FilePos(MarketFile)-1);

     {запись в idx file}
     Seek(HeaderFile,FilePos(MarketFile));
     Write(HeaderFile,Lh^.DAt);
     {снятие блокировки}


     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле Предзаказов...',False);
     Repeat
      Pause(1);
      UnLock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType));
     Until (DosError=0);
     Close(MarketFile);
     c:=IOResult;
     Close(HeaderFile);
     c:=IOResult;
     LockAndWritePredZakaz:=True;
     NoInfoMsg;
    End
   Else
    Begin
     {запись прихода для случая формирования накладной}
     DInfoNetMsg('Сохраняю новый Предзаказ N '+L^.Dat.Document+'...');
     ChangeNumer:=False;


    Repeat

     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(MarketFile);
      Seek(MarketFile,Pos1{FileSize(MarketFile)});
     Until (Lock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType)*ComputersKol));

     Pos1:=FileSize(MarketFile);

     If FilePos(MarketFile)<>Pos1{FileSize(MarketFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        UnLock(MarketFile,(FilePos(MarketFile))*SizeOf(PredZakazType),SizeOf(PredZakazType)*ComputersKol);
       Until (DosError=0);
      End;
    Until (FilePos(MarketFile)=Pos1);

{$IFDEF NetVersion}
     L^.Dat.Locked:=True;
{$ENDIF}

     If ({(FileSize(MarketFile)+1)}(Pos1+1)<>(StrToInt(L^.Dat.Document))) Then
     Begin
      ChangeNumer:=True;
      L^.Dat.Document:=IntToStr({FileSize(MArketFile)}Pos1+1,CDocNumer);
      DelSpace(L^.Dat.Document);

      Dispose(Lh,Done);
      New(Lh,Init);
      PredZakazToIndex(L,Lh);
     End;

     Position:=FilePos(MarketFile);

     Er:=IOResult;
     Write(MarketFile,L^.DAt);
     Er:=IOResult;
     Seek(MarketFile,FilePos(MarketFile)-1);
     Er:=IOResult;

     {запись в idx file}
     Seek(HeaderFile,{FilePos(MarketFile)}Position);
     Er:=IOResult;
     Write(HeaderFile,Lh^.DAt);
     Er:=IOResult;
     {снятие блокировки}

     NonetInfoMsg;

     DInfoMsg('Деблокирую запись в файле Предзаказов...',False);
     Repeat {деблокируем участок записи}
      UnLock(MarketFile,(FilePos(MarketFile))*SizeOf(PredZakazType),
      SizeOf(PredZakazType)*ComputersKol);
     {If DosError<>0 Then
       MessageBox(#3+'DosError='+IntToStr(DosError,3),Nil,
          mfError+mfCancelButton);}
     Until (DosError=0);

     Close(MarketFile);
     Close(HeaderFile);
     LockAndWritePredZakaz:=True;
     NoInfoMsg;

     AddProtocol('Добавление предзаказа '+L^.DAt.Document+'('+
	IntToStr(Lh^.DAt.Document,CKOl)+
	') успешно завершено {протокол сетевых блокировок}','{предзаказы}','');

     {
     If ChangeNumer Then
     Begin
      If (ServStr.ShowNumer=1) Then
       Begin
       MessageBox(#3+'За время формирования Вами документа проведены другие '+
          'предзаказы. Присваиваю документу новый номер: '+L^.Dat.Document+'!',
           Nil,mfInformation+mfCancelButton);
       End;
     End;
     }

    End;

c:=IOResult;
Dispose(Lh,Done);

End;


Function SetPredZakazStatus(Oforml:Word;P:PPredZakazType;EditPosition:ArtikulStr;Doc:TDAteString):Boolean;
{функция возвращает 0 если все прошло ок
0 все ок
1 если документ не найден
2 если не удалось заблокировать накладную
3 ошибка сетевого открытия файла продаж
4 если по документу оформлен заказ
5 если заказ онулирован по времени}
Var jk,C : Word;
    Find : Boolean;
    MarketFile : PredZakazFileType;
    HeaderFile : HeaderPredZakazFileType;
    E : PPredZakazType;
    Lh : PHeaderPredZakazType;

Begin
  SetPredZakazStatus:=False;
  C:=IOResult;
  Assign(MarketFile,Path^.Dat.ToMarket+'PZakaz.db');
  Reset(MarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла предзаказов!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    C:=IOResult;
    Exit;
   End;

  C:=IOResult;
  Assign(HeaderFile,Path^.Dat.ToMarketIndex+'PZakaz.idx');
  Reset(HeaderFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    Close(MarketFile);
    MessageBox(^M+#3'Ошибка сетевого открытия Файла предзаказов-idx!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    C:=IOResult;
    Exit;
   End;

   New(E,Init);
   New(Lh,Init);

If (StrToInt(EditPosition)-1)>=0 Then
If FileSize(MarketFile)>(StrToInt(EditPosition)-1) Then
 Begin

   Seek(MarketFile,StrToInt(EditPosition)-1);

   Seek(HeaderFile,StrToInt(EditPosition)-1);

   Repeat
   Pause(1);
   Until Lock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType));

   {запись статуса заказа}
   Read(MarketFile,E^.Dat);
   E^.Dat:=P^.Dat;

   E^.Dat.Status:=Oforml;

   If Oforml=5 Then
   Begin
   E^.Dat.ZakazNumer:=Doc;
   E^.Dat.DateConv:=DateStringToDate(DateMask,FDate);
   E^.Dat.TimeConv:=CurrentTime;
   E^.Dat.SendConfirmation:=1;{необходимо отправить подтверждение}
   End;

   If Oforml=6 Then
   Begin
   E^.Dat.ZakazNumer:='';
   E^.Dat.DateConv:=DateStringToDate(DateMask,FDate);
   E^.Dat.TimeConv:=CurrentTime;
   E^.Dat.SendConfirmation:=1;{необходимо отправить подтверждение}
   End;

   If Oforml in [0,1,2,3,4] Then
   Begin
    E^.Dat.ZakazNumer[0]:=#0;
    E^.DAt.Defizit:=0;
    E^.Dat.DateConv:=0;
    E^.Dat.TimeConv:=0;
    E^.Dat.SendConfirmation:=0;
    For jk:=1 To E^.Dat.Amount Do E^.DAt.Element[jk].Fakt:=0;
   End;

   Seek(MarketFile,FilePos(MarketFile)-1);
   Write(MarketFile,E^.DAt);
   Seek(MarketFile,FilePos(MarketFile)-1);

   {запись статуса заказа}
   Read(HeaderFile,Lh^.Dat);
   Lh^.Dat.Status:=Oforml;

   If Oforml=5 Then
   Begin
   Lh^.Dat.ZakazNumer:=StrToInt(Doc);
   Lh^.Dat.DateConv:=DateStringToDate(DateMask,FDate);
   Lh^.Dat.TimeConv:=CurrentTime;
   Lh^.Dat.SendConfirmation:=1;{необходимо отправить подтверждение}
   End;

   If Oforml=6 Then
   Begin
   Lh^.Dat.ZakazNumer:=0;
   Lh^.Dat.DateConv:=DateStringToDate(DateMask,FDate);
   Lh^.Dat.TimeConv:=CurrentTime;
   Lh^.Dat.SendConfirmation:=1;{необходимо отправить подтверждение}
   End;

   If Oforml in [0,1,2,3,4] Then
   Begin
    Lh^.Dat.ZakazNumer:=0;
    Lh^.DAt.Defizit:=0;
    Lh^.Dat.DateConv:=0;
    Lh^.Dat.TimeConv:=0;
    Lh^.Dat.SendConfirmation:=0;
   End;

   Seek(HeaderFile,FilePos(HeaderFile)-1);
   Write(HeaderFile,Lh^.DAt);

   Repeat
    UnLock(MarketFile,FilePos(MarketFile)*SizeOf(PredZakazType),SizeOf(PredZakazType))
   Until Doserror=0;
   SetPredZakazStatus:=True;
 End;
   Dispose(E,Done);
   Dispose(Lh,Done);
   c:=IOResult;
   Close(MarketFile);
   c:=IOResult;
   Close(HeaderFile);
   c:=IOResult;
End;





begin

End.