
{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{типы документов
1- приход
2- возврат
3- отгрузка
4- ревизия
5- переоценка}

Unit Protect;

Interface

Uses Glob,ServStr,TPDate,Objects;

Const MaxWspom=50;
      MaxMarket=300;
      SeparatorChar=#221;

Type LockDate = Record
     dt : Date;
     Flag : Boolean;
     End;

Type DocArray50 = Record
     DocEmploy : Array[1..MaxWspom] Of Boolean;
     End;

Type DocArray300 = Record
     DocEmploy : Array[1..MaxMarket] Of Boolean;
     End;

     {не забыть про сетевое использование файла оплаты консигнации}

Type SkladDocNumer =Record
     Day : LockDate;
(*
     Prihod : DocArray50;{сделана полность 16.11}
     Prz    : DocArray50;{сделана полность 16.11}
     Return : DocArray50;{Нет нужно доделать блокировку первичного документа отгрузки
                            -хотя это не обязательно т.к. блокирется клиент}
     Rewisia: DocArray50;{сделана полность 16.11}
     Market : DocArray300;{Нет}
*)
     End;


Type DocBazType = Record
     Numer : ArtikulStr;
     Status: Boolean; {False - свободен; True - занят}
     Document:String[CDocNumer];
     DateDocument:String[CDate];
     DateC : TDateString;
     TimeC : TDateString;
     End;


Type
    PDocBazType = ^DocBazTypePtr;
    DocBazTypePtr=Object(TObject)
    Dat  :  DocBAzType;
     Constructor Init;
     Destructor Done; Virtual;
    end;




Type CreatToDayFile =Record
      CreatPrihod :Boolean;
     CaptionPrihod: String[CRazdelKod];
      CreatPrz    :Boolean;
      CaptionPrz  : String[CRazdelKod];
      CreatReturn :Boolean;
     Captionreturn: String[CRazdelKod];
      CreatRewisia:Boolean;
    Captionrewisia: String[CRazdelKod];
      CreatMarket :Boolean;
     CaptionMarket: String[CRazdelKod];
      CreatOplata :Boolean;
CreatBArterOplata :Boolean;
CaptionBArterOplata: String[CRazdelKod];
   CreatTransport :Boolean;
  CaptionTransport: String[CRazdelKod];

     CaptionOplata: String[CRazdelKod];
     CreatProtocol:Boolean;
   CaptionProtocol: String[CRazdelKod];
CreatProtocolReturn:Boolean;
CaptionProtocolReturn: String[CRazdelKod];

CreatKassa :Boolean;
CaptionKAssa: String[CRazdelKod];


 WriteReadProtocol:Boolean;
   WriteReadReturn:Boolean;
      Locked      :Boolean;

     End;

Type
    PSkladDocNumer = ^SkladDocNumerPtr;
    SkladDocNumerPtr=Object(TObject)
    Dat  :  SkladDocNumer;
     Constructor Init;
     Destructor Done; Virtual;
    end;

Type
    PCreatToDayFile = ^CreatToDayFilePtr;
    CreatToDayFilePtr=Object(TObject)
    Dat  :  CreatToDayFile;
     Constructor Init;
     Destructor Done; Virtual;
    end;

{Function TestOpenDate(S:TDateString):Boolean;
 Function BlockDate(S:TDateString):Boolean;
 Function DEBlockDate(S:TDateString):Boolean;}

Function TestOpenDate1(S:TDateString):Boolean;
Function BlockDate1(S:TDateString):Boolean;
Function DEBlockDate1(S:TDateString):Boolean;
{Function CalcFreeDocNumer(Const VidDoc:Byte;s:DateString;Var Numer:AllStr):Boolean;}
Function UseDocNumer(Const VidDoc:Byte;s:DateString;Var Numer:AllStr):Boolean;
{Function FreeDocNumer(Const VidDoc:Byte;s:DateString;Numer:AllStr):Boolean;}
Function CreatToDayF(Doc:Word;Date:DAteString):Boolean;
Function LockPrWriteRead(Date:DateString):Boolean;
Function UnLockPrWriteRead(Date:DateString):Boolean;
Function LockReturnWriteRead(Date:DateString):Boolean;
Function UnLockReturnWriteRead(Date:DateString):Boolean;
Function GetReestrNum( Res:Byte;Var Num:ArtikulStr;E:SuperMarketType):Boolean;
Function GetReestrNumOpl( Res:Byte;Var Num:ArtikulStr;E:PsevdoSuperMarketType):Boolean;
Function FreeReestrNum( Res:Byte;Var Num:ArtikulStr):Boolean;
Function SetFreeReestrNum( Res:Byte;Var Num:ArtikulStr):Boolean;

(*Procedure FindError;
Procedure FindError2; *)



Implementation


Uses MsgBox,Serv,netcall,Dos,dbEngine;

Constructor SkladDocNumerPtr.Init;
Var i : Integer;
Begin
TObject.Init;

With DAt Do
Begin
(*
For i:=1 To MaxWspom Do
 Begin
  Prihod.DocEmploy[i]:=True;
  Return.DocEmploy[i]:=True;
  Rewisia.DocEmploy[i]:=True;
  Prz.DocEmploy[i]:=True;
  Market.DocEmploy[i]:=True;
 End;
For i:=MaxWspom To MaxMarket Do
 Begin
  Market.DocEmploy[i]:=True;
 End;
*)
 Day.dt:=147192;
 Day.Flag:=False;
End;{With}

End;{Constructor}


Constructor DocBazTypePtr.Init;
Var i : Integer;
Begin
TObject.Init;

With DAt Do
Begin
     Numer :='';
        Status:=False; {False - свободен; True - занят}
     Document[0]:=#0;
     DAteDocument[0]:=#0;
     DateC[0]:=#0;
     TimeC[0]:=#0;
End;{With}

End;{Constructor}

Destructor DocBazTypePtr.Done;
Begin
 TObject.Done;
End;




Constructor CreatToDayFilePtr.Init;
Var i : Integer;
Begin
TObject.Init;
With DAt Do
Begin
 CreatPrihod :=False;
 CaptionPrihod:='00';
 CreatTransport :=False;
 CaptionTransport:='00';
 CreatPrz    :=False;
 CaptionPrz  :='00';
 CreatReturn :=False;
 Captionreturn:='00';
 CreatRewisia:=False;
 Captionrewisia:='00';
 CreatMarket :=False;
 CaptionMarket:='00';
 CreatOplata :=False;
 CaptionOplata:='00';
 CreatProtocol:=False;
 CaptionProtocol:='00';
CreatBArterOplata :=False;
CaptionBArterOplata:='00';
 CreatKassa:=False;
 CaptionKassa:='00';

 CreatProtocolReturn:=False;
 CaptionProtocolReturn:='00';
 Locked      :=False;
 WriteReadProtocol:=False;
 WriteReadReturn:=False;
End;{With}
End;{Constructor}

Destructor SkladDocNumerPtr.Done;
Begin
 TObject.Done;
End;

Destructor CreatToDayFilePtr.Done;
Begin
 TObject.Done;
End;

Var ControlFile : File Of LockDate;
    ControlVar : LockDate;
    l : LongInt;


Function TestOpenDate(S:TDateString):Boolean;
Var {DateMask :TDateString;}
    k : Boolean;
    c : Byte;
Begin
 TestOpenDate:=false;
 Assign(ControlFile,Path.ToSklad+'date.db');
 c:=IOResult;
 Reset(ControlFile);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия реестра рабочих дней! ('+IntToStr(c,3)+')',Nil,mfError+mfCancelButton);
   Exit;
  End;
{ DateMask:=InternationalDate(False,True);}
 l:=DateStringToDate(DateMask,s);
 k:=False;
 While not(Eof(controlFile)) And Not(K) Do
  Begin
   Read(ControlFile,ControlVar);
   If ControlVar.dt=l Then k:=True;
  End;
  close(controlfile);
  If k And (ControlVar.Flag) Then
   Begin
    TestOpenDate:=True;
   End

End;

Function BlockDate(S:TDateString):Boolean;
Var {DateMask :TDateString;}
    K : Boolean;
    c : Byte;
Begin
 BlockDate:=false;
 Assign(ControlFile,Path.ToSklad+'date.db');
 c:=IOResult;
 Reset(ControlFile);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия реестра рабочих дней! ('+IntToStr(c,3)+')',Nil,mfError+mfCancelButton);
   Exit;
  End;

{ DateMask:=InternationalDate(False,True);}
 l:=DateStringToDate(DateMask,s);
 K:=False;
 While not(Eof(controlFile)) And Not(K) Do
  Begin
   Read(ControlFile,ControlVar);
   If ControlVar.dt=l Then k:=True;
  End;
  If k Then
  Begin
   BlockDate:=True;
   Seek(ControlFile,Filepos(ControlFile)-1);
   ControlVar.Flag:=False;
   Write(ControlFile,ControlVar);
  End;
  close(controlfile);
  AddProtocol(s+' Закрытие программного дня!','','');
End;

Function DeBlockDate(S:TDateString):Boolean;
Var {DateMask :TDateString;}
    K : Boolean;
    c : Byte;
Begin
 DeBlockDate:=false;
 Assign(ControlFile,Path.ToSklad+'date.db');
 c:=IOResult;
 Reset(ControlFile);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия реестра рабочих дней! ('+IntToStr(c,3)+')',Nil,mfError+mfCancelButton);
   Exit;
  End;
{ DateMask:=InternationalDate(False,True);}
 l:=DateStringToDate(DateMask,s);
 k:=False;
 While not(Eof(controlFile)) And Not(k) Do
  Begin
   Read(ControlFile,ControlVar);
   If ControlVar.dt=l Then k:=True;
  End;
  If k Then
  Begin
   DeBlockDate:=True;
   Seek(ControlFile,Filepos(ControlFile)-1);
   ControlVar.Flag:=True;
   Write(ControlFile,ControlVar);
  End;
  close(controlfile);
  AddProtocol(s+' Открытие программного дня {Очень важно}','','');
End;


Function GetCurrentDay(Var P:PSkladDocNumer):Boolean;
Var f : File Of SkladDocNumer;
    Pos : LongInt;
    c : Byte;
Begin
 GetCurrentDay:=False;
 Assign(f,Path.ToSklad+'date.db');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия реестра рабочих дней ('+IntToStr(c,3)+')!',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Pos:=P^.DAt.Day.dt-DateStringToDAte(DateMask,'01-01-98');
 If (FileSize(f)<Pos) Then
  Begin
   Close(f);
   MessageBox(^M+#3'Дата '+DateToDAteString(DateMask,P^.DAt.Day.dt)+' не найдена в реестре рабочих дней!',
   Nil,mfError+mfCancelButton);
   Exit;
  End;
 Seek(f,pos);
 Read(f,P^.Dat);
 Close(f);
End;


Function LockPrWriteRead(Date:DateString):Boolean;
Var f : File Of CreatToDayFile;
NoType: Text;
    Pos : LongInt;
    c : Byte;
    P : PCreatToDayFile;
    PathToCreatFile : PathStr;
    s : string[150];
Begin
 LockPrWriteRead:=False;
 Assign(f,Path.ToSklad+'creat.db');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия сетевого реестра ('+IntToStr(c,3)+')!',Nil,mfError+mfCancelButton);
   c:=IOResult;
   Exit;
  End;
 Pos:=DAteStrIngToDate(DAteMask,Date)-DateStringToDAte(DateMask,'01-01-98');

 If (FileSize(f)<Pos) Then
  Begin
   Close(f);
   MessageBox(^M+#3'Дата '+Date+' не найдена в сетевом реестре!',
   Nil,mfError+mfCancelButton);
   c:=IOResult;
   Exit;
  End;

 DInfoNetMsg('Жду доступа к сетевому реестру за '+Date+'...');
 New(P,Init);
 Seek(f,Pos);

 Repeat
 Repeat
  Pause(1);
 Until Lock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile)); {предварительная блокировка}

 Read(f,P^.Dat);

 Seek(f,FilePos(f)-1);

 if not(FindParam('/NOPROTOCOL')) Then
 If (P^.Dat.WriteReadProtocol) Then
  Begin
   Repeat
    Unlock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile));
   Until (DosError=0);
  End;
 Until Not(P^.Dat.WriteReadProtocol) Or FindParam('/NOPROTOCOL');


 If Not(P^.Dat.CreatProtocol) Then
    {если файл приходиться создавать вновь}
    Begin
      Assign(NoType,PAth.ToProtocol+Date+'.pr');
      c:=IOResult;
      If Not(FExists(PAth.ToProtocol+Date+'.pr')) Then
	 Rewrite(NoType);
      c:=IOResult;
      If C<>0 Then
       Begin
        SpecialBeep;
        MessageBox(^M+#3'Ошибка создания файла протокола за '+Date+'!'+
        ClicProgrammer,Nil,MfError+MfCancelButton);
        Repeat
         Unlock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile));
        Until (DosError=0);
        Dispose(P,Done);
        Close(f);
        NoNetInfoMsg;
        Exit;
       End
       Else Begin
             s:='   ПРОТОКОЛ ОПЕРАЦИЙ НА складе: '+Rek.Kod+' за '+Date;
             s:=Code(s);
             Writeln(NoType,S);
             Writeln(NoType);
             Close(NoType);
             P^.Dat.CreatProtocol:=True;{выставляем отметку о создании}
             P^.Dat.CaptionProtocol:=CurrentPassword;
            End;
      c:=IOresult;
    End
    Else
     Begin
      c:=IOResult;
      Assign(NoType,PAth.ToProtocol+Date+'.pr');
      If Not(FExists(PAth.ToProtocol+Date+'.pr')) Then
{
      Reset(NoType);
      c:=IOResult;
      If c<>0 Then}
       Begin
        SpecialBeep;
        MessageBox(#3'Ошибка доступа к файлу протокола. Файл протокола за '+
	   Date+' уже создавался оператором '+
	   GetOperatorName(P^.Dat.CaptionProtocol)+
        ClicProgrammer,Nil,MfError+MfCancelButton);
        Repeat
         Unlock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile));
        Until (DosError=0);
        Dispose(P,Done);
        Close(f);
        NoNetInfoMsg;
        Exit;
       End
       Else
        Begin
         {Close(NoType);}
        End;
      c:=IOResult;
     End;


 P^.Dat.WriteReadProtocol:=True;{отметка о том что доступ к данному файлу закрыт}

 Write(f,P^.Dat);
 Seek(f,FilePos(f)-1);
 Repeat
  Unlock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile));
 Until (DosError=0);
 Close(f);
 Dispose(P,Done);
 NoNetInfoMsg;
 c:=IOresult;
 LockPrWriteRead:=True;
End;


Function UnLockPrWriteRead(Date:DateString):Boolean;
Var f : File Of CreatToDayFile;
NoType: File;
    Pos : LongInt;
    c : Byte;
    P : PCreatToDayFile;
    PathToCreatFile : PathStr;
Begin
 UnLockPrWriteRead:=False;
 Assign(f,Path.ToSklad+'creat.db');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия сетевого реестра ('+IntToStr(c,3)+')!',Nil,mfError+mfCancelButton);
   c:=IOResult;
   Exit;
  End;
 Pos:=DAteStrIngToDate(DAteMask,Date)-DateStringToDAte(DateMask,'01-01-98');

 If (FileSize(f)<Pos) Then
  Begin
   Close(f);
   MessageBox(^M+#3'Дата '+Date+' не найдена в сетевом реестре!',
   Nil,mfError+mfCancelButton);
   c:=IOResult;
   Exit;
  End;

 DInfoNetMsg('Жду доступа к сетевому реестру за '+Date+'...');
 New(P,Init);
 Seek(f,Pos);

 Repeat
  Pause(1);
 Until Lock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile)); {предварительная блокировка}
 Read(f,P^.Dat);

 Seek(f,FilePos(f)-1);

 P^.Dat.WriteReadProtocol:=False;{отметка о том что доступ к данному файлу закрыт}

 Write(f,P^.Dat);
 Seek(f,FilePos(f)-1);
 Repeat
  Unlock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile));
 Until (DosError=0);
 Close(f);
 Dispose(P,Done);
 NoNetInfoMsg;
 c:=IOresult;
 UnLockPrWriteRead:=True;
End;

Function LockReturnWriteRead(Date:DateString):Boolean;
Var f : File Of CreatToDayFile;
NoType: Text;
    Pos : LongInt;
    c : Byte;
    P : PCreatToDayFile;
    PathToCreatFile : PathStr;
    S : string[150];
Begin
 LockReturnWriteRead:=False;
 Assign(f,Path.ToSklad+'creat.db');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия сетевого реестра ('+IntToStr(c,3)+')!',Nil,mfError+mfCancelButton);
   c:=IOResult;
   Exit;
  End;
 Pos:=DAteStrIngToDate(DAteMask,Date)-DateStringToDAte(DateMask,'01-01-98');

 If (FileSize(f)<Pos) Then
  Begin
   Close(f);
   MessageBox(^M+#3'Дата '+Date+' не найдена в сетевом реестре!',
   Nil,mfError+mfCancelButton);
   c:=IOResult;
   Exit;
  End;

 DInfoNetMsg('Жду доступа к сетевому реестру за '+Date+'...');
 New(P,Init);
 Seek(f,Pos);

 Repeat
 Repeat
  Pause(1);
 Until Lock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile)); {предварительная блокировка}
 Read(f,P^.Dat);

 Seek(f,FilePos(f)-1);

 if not(FindParam('/NOPROTOCOL')) Then
 If (P^.Dat.WriteReadReturn) Then
  Begin
   Repeat
    Unlock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile));
   Until (DosError=0);
  End;
 Until Not(P^.Dat.WriteReadProtocol) Or FindParam('/NOPROTOCOL');


 If Not(P^.Dat.CreatProtocolReturn) Then
    {если файл приходиться создавать вновь}
    Begin
      Assign(NoType,PAth.ToProtocol+Date+'.vpr');
      c:=IOResult;
      If Not(FExists(PAth.ToProtocol+Date+'.vpr')) Then Rewrite(NoType);
      c:=IOResult;
      If C<>0 Then
       Begin
        SpecialBeep;
        MessageBox(^M+#3'Ошибка создания файла протокола возврата за '+Date+'!'+
        ClicProgrammer,Nil,MfError+MfCancelButton);
        Repeat
         Unlock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile));
        Until (DosError=0);
        Dispose(P,Done);
        Close(f);
        NoNetInfoMsg;
        Exit;
       End
       Else Begin
             s:='   ПРОТОКОЛ КОРРЕКТИРОВОК И ВОЗВРАТОВ НА складе: '+Rek.Kod+' за '+Date;
             s:=Code(s);
             Writeln(NoType,S);
             Writeln(NoType);
             Close(NoType);
             P^.Dat.CreatProtocolReturn:=True;{выставляем отметку о создании}
             P^.Dat.CaptionProtocolReturn:=CurrentPassword;
            End;
      c:=IOresult;
    End
    Else
     Begin
      c:=IOResult;
      Assign(NoType,PAth.ToProtocol+Date+'.vpr');
      If Not(FExists(PAth.ToProtocol+Date+'.vpr')) Then
{
      Reset(NoType);
      c:=IOResult;
      If c<>0 Then}
       Begin
        SpecialBeep;
        MessageBox(#3'Ошибка доступа к файлу протокола возврата. Файл протокола за '+
	   Date+' уже создавался оператором '+
	   GetOperatorName(P^.Dat.CaptionProtocol)+
        ClicProgrammer,Nil,MfError+MfCancelButton);
        Repeat
         Unlock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile));
        Until (DosError=0);
        Dispose(P,Done);
        Close(f);
        NoNetInfoMsg;
        Exit;
       End
       Else
        Begin
         {Close(NoType);}
        End;
      c:=IOResult;
     End;


 P^.Dat.WriteReadReturn:=True;{отметка о том что доступ к данному файлу закрыт}

 Write(f,P^.Dat);
 Seek(f,FilePos(f)-1);
 Repeat
  Unlock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile));
 Until (DosError=0);
 Close(f);
 Dispose(P,Done);
 NoNetInfoMsg;
 c:=IOresult;
 LockReturnWriteRead:=True;
End;


Function UnLockReturnWriteRead(Date:DateString):Boolean;
Var f : File Of CreatToDayFile;
NoType: File;
    Pos : LongInt;
    c : Byte;
    P : PCreatToDayFile;
    PathToCreatFile : PathStr;
Begin
 UnLockReturnWriteRead:=False;
 Assign(f,Path.ToSklad+'creat.db');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия сетевого реестра ('+IntToStr(c,3)+')!',Nil,mfError+mfCancelButton);
   c:=IOResult;
   Exit;
  End;
 Pos:=DAteStrIngToDate(DAteMask,Date)-DateStringToDAte(DateMask,'01-01-98');

 If (FileSize(f)<Pos) Then
  Begin
   Close(f);
   MessageBox(^M+#3'Дата '+Date+' не найдена в сетевом реестре!',
   Nil,mfError+mfCancelButton);
   c:=IOResult;
   Exit;
  End;

 DInfoNetMsg('Жду доступа к сетевому реестру за '+Date+'...');
 New(P,Init);
 Seek(f,Pos);

 Repeat
  Pause(1);
 Until Lock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile)); {предварительная блокировка}
 Read(f,P^.Dat);

 Seek(f,FilePos(f)-1);

 P^.Dat.WriteReadReturn:=False;{отметка о том что доступ к данному файлу закрыт}

 Write(f,P^.Dat);
 Seek(f,FilePos(f)-1);
 Repeat
  Unlock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile));
 Until (DosError=0);
 Close(f);
 Dispose(P,Done);
 NoNetInfoMsg;
 c:=IOresult;
 UnLockReturnWriteRead:=True;
End;




Function CreatToDayF(Doc:Word;Date:DAteString):Boolean;
Var f : File Of CreatToDayFile;
NoType: File;
    Pos : LongInt;
    c : Byte;
    P : PCreatToDayFile;
    PathToCreatFile : PathStr;
Begin
 CreatToDayF:=False;
 Assign(f,Path.ToSklad+'creat.db');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия сетевого реестра ('+IntToStr(c,3)+')!',Nil,mfError+mfCancelButton);
   c:=IOResult;
   Exit;
  End;
 Pos:=DAteStrIngToDate(DAteMask,Date)-DateStringToDAte(DateMask,'01-01-98');

 If (FileSize(f)<Pos) Then
  Begin
   Close(f);
   MessageBox(^M+#3'Дата '+Date+' не найдена в сетевом реестре!',
   Nil,mfError+mfCancelButton);
   c:=IOResult;
   Exit;
  End;

 DInfoNetMsg('Жду доступа к сетевому реестру за '+Date+'...');
 New(P,Init);
 Seek(f,Pos);
 Repeat
  Pause(1);
 Until Lock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile)); {предварительная блокировка}
 Read(f,P^.Dat);

 Case Doc Of
DocProtocol:Begin
             Assign(NoType,PAth.ToProtocol+Date+'.pr');
             If P^.Dat.CreatProtocol Then
             Begin
              c:=IOResult;
              Reset(NoType);
              c:=IOResult;
              If c<>0 Then
              Begin
              SpecialBeep;
              MessageBox(^M+#3'Файл протокола за '+Date+' уже создавался оператором '+GetOperatorName(P^.Dat.CaptionProtocol)+
              ClicProgrammer,Nil,MfError+MfCancelButton)
              End
              Else
                     Begin
                         Close(NoType);
                CreatToDayF:=true;
               End;
             End
             Else
              Begin
               c:=IOResult;
               Rewrite(NoType);
               c:=IOResult;
               If C<>0 Then
                Begin
                 SpecialBeep;
                 MessageBox(^M+#3'Ошибка создания файла протокола за '+Date+'!'+
                 ClicProgrammer,Nil,MfError+MfCancelButton);
                End
                Else Begin
                               Close(NoType);
                      P^.Dat.CreatProtocol:=True;{выставляем отметку о создании}
                      P^.Dat.CaptionProtocol:=CurrentPassword;
                      CreatToDayF:=true;
                     End;
               c:=IOresult;
              End;
            End;{DocProtocol}
DocProtocolReturn
           :Begin
             Assign(NoType,PAth.ToProtocol+Date+'.vpr');
             If P^.Dat.CreatProtocolReturn Then
             Begin
              c:=IOResult;
              Reset(NoType);
              c:=IOResult;
              If c<>0 Then
              Begin
              SpecialBeep;
              MessageBox(^M+#3'Файл протокола возврата за '+Date+' уже создавался оператором '+
		    GetOperatorName(P^.Dat.CaptionProtocolReturn)+
              ClicProgrammer,Nil,MfError+MfCancelButton)
              End
              Else
                     Begin
                         Close(NoType);
                CreatToDayF:=true;
               End;
             End
             Else
              Begin
               c:=IOResult;
               Rewrite(NoType);
               c:=IOResult;
               If C<>0 Then
                Begin
                 SpecialBeep;
                 MessageBox(^M+#3'Ошибка создания файла протокола возврата за '+Date+'!'+
                 ClicProgrammer,Nil,MfError+MfCancelButton);
                End
                Else Begin
                               Close(NoType);
                      P^.Dat.CreatProtocolReturn:=True;{выставляем отметку о создании}
                      P^.Dat.CaptionProtocolReturn:=CurrentPassword;
                      CreatToDayF:=true;
                     End;
               c:=IOresult;
              End;
            End;{DocProtocolReturn}
DocPrihod  :Begin
             Assign(NoType,PAth.ToPrihod+Date+'.prh');
             If P^.Dat.CreatPrihod Then
             Begin
              c:=IOResult;
              Reset(NoType);
              c:=IOResult;
              If c<>0 Then
              Begin
              SpecialBeep;
              MessageBox(^M+#3'Файл прихода за '+Date+' уже создавался оператором '+GetOperatorName(P^.Dat.CaptionPrihod)+
              ClicProgrammer,Nil,MfError+MfCancelButton)
              End
              Else
                     Begin
                         Close(NoType);
                CreatToDayF:=true;
               End;
             End
             Else
              Begin
               c:=IOResult;
               Rewrite(NoType);
               c:=IOResult;
               If C<>0 Then
                Begin
                 SpecialBeep;
                 MessageBox(^M+#3'Ошибка создания файла прихода за '+Date+'!'+
                 ClicProgrammer,Nil,MfError+MfCancelButton);
                End
                Else Begin
                               Close(NoType);
                      P^.Dat.CreatPrihod:=True;{выставляем отметку о создании}
                      P^.Dat.CaptionPrihod:=CurrentPassword;
                      CreatToDayF:=true;
                     End;
               c:=IOresult;
              End;
            End;{DocPrihod}
DocPereozen:Begin
             Assign(NoType,PAth.ToCorrect+Date+'.prz');
             If P^.Dat.CreatPrz Then
             Begin
              c:=IOResult;
              Reset(NoType);
              c:=IOResult;
              If c<>0 Then
              Begin
              SpecialBeep;
              MessageBox(^M+#3'Файл переоценки за '+Date+' уже создавался оператором '+GetOperatorName(P^.Dat.CaptionPrz)+
              ClicProgrammer,Nil,MfError+MfCancelButton)
              End
              Else
                     Begin
                         Close(NoType);
                CreatToDayF:=true;
               End;
             End
             Else
              Begin
               c:=IOResult;
               Rewrite(NoType);
               c:=IOResult;
               If C<>0 Then
                Begin
                 SpecialBeep;
                 MessageBox(^M+#3'Ошибка создания файла переоценки за '+Date+'!'+
                 ClicProgrammer,Nil,MfError+MfCancelButton);
                End
                Else Begin
                               Close(NoType);
                      P^.Dat.CreatPrz:=True;{выставляем отметку о создании}
                      P^.Dat.CaptionPrz:=CurrentPassword;
                      CreatToDayF:=true;
                     End;
               c:=IOresult;
              End;
            End;{DocPrz}
DocReturn  :Begin
             Assign(NoType,PAth.ToReturn+Date+'.vzw');
             If P^.Dat.CreatReturn Then
             Begin
              c:=IOResult;
              Reset(NoType);
              c:=IOResult;
              If c<>0 Then
              Begin
              SpecialBeep;
              MessageBox(^M+#3'Файл возврата за '+Date+' уже создавался оператором '+GetOperatorName(P^.Dat.CaptionReturn)+
              ClicProgrammer,Nil,MfError+MfCancelButton)
              End
              Else
                     Begin
                         Close(NoType);
                CreatToDayF:=true;
               End;
             End
             Else
              Begin
               c:=IOResult;
               Rewrite(NoType);
               c:=IOResult;
               If C<>0 Then
                Begin
                 SpecialBeep;
                 MessageBox(^M+#3'Ошибка создания файла возврата за '+Date+'!'+
                 ClicProgrammer,Nil,MfError+MfCancelButton);
                End
                Else Begin
                               Close(NoType);
                      P^.Dat.CreatReturn:=True;{выставляем отметку о создании}
                      P^.Dat.CaptionReturn:=CurrentPassword;
                      CreatToDayF:=true;
                     End;
               c:=IOresult;
              End;
            End;{DocReturn}
DocRewisia :Begin
             Assign(NoType,PAth.ToRewisia+Date+'.rwz');
             If P^.Dat.CreatRewisia Then
             Begin
              c:=IOResult;
              Reset(NoType);
              c:=IOResult;
              If c<>0 Then
              Begin
              SpecialBeep;
              MessageBox(^M+#3'Файл ревизии за '+Date+' уже создавался оператором '+GetOperatorName(P^.Dat.CaptionRewisia)+
              ClicProgrammer,Nil,MfError+MfCancelButton);
              End
              Else
                     Begin
                         Close(NoType);
                CreatToDayF:=true;
               End;
             End
             Else
              Begin
               c:=IOResult;
               Rewrite(NoType);
               c:=IOResult;
               If C<>0 Then
                Begin
                 SpecialBeep;
                 MessageBox(^M+#3'Ошибка создания файла ревизии за '+Date+'!'+
                 ClicProgrammer,Nil,MfError+MfCancelButton);
                End
                Else Begin
                               Close(NoType);
                      P^.Dat.CreatRewisia:=True;{выставляем отметку о создании}
                      P^.Dat.CaptionRewisia:=CurrentPassword;
                      CreatToDayF:=true;
                     End;
               c:=IOresult;
              End;
            End;{DocRewisia}

DocKassa  :Begin
             Assign(NoType,PAth.ToClient+Date+'.kas');
             If P^.Dat.CreatKassa Then
             Begin
              c:=IOResult;
              Reset(NoType);
              c:=IOResult;
              If c<>0 Then
              Begin
              SpecialBeep;
              MessageBox(#3'Файл кассы за '+Date+' уже создавался оператором '+GetOperatorName(P^.Dat.CaptionRewisia)+
              ClicProgrammer,Nil,MfError+MfCancelButton);
              End
              Else
                     Begin
                         Close(NoType);
                CreatToDayF:=true;
               End;
             End
             Else
              Begin
               c:=IOResult;
               Rewrite(NoType);
               c:=IOResult;
               If C<>0 Then
                Begin
                 SpecialBeep;
                 MessageBox(^M+#3'Ошибка создания файла кассы за '+Date+'!'+
                 ClicProgrammer,Nil,MfError+MfCancelButton);
                End
                Else Begin
                               Close(NoType);
                      P^.Dat.CreatKassa:=True;{выставляем отметку о создании}
                      P^.Dat.CaptionKassa:=CurrentPassword;
                      CreatToDayF:=true;
                     End;
               c:=IOresult;
              End;
            End;{DocKassa}


DocMarket  :Begin
             Assign(NoType,PAth.ToMarket+Date+'.mrk');
             If P^.Dat.CreatMarket Then
             Begin
              c:=IOResult;
              Reset(NoType);
              c:=IOResult;
              If c<>0 Then
              Begin
              SpecialBeep;
              MessageBox(^M+#3'Файл продаж за '+Date+' уже создавался оператором '+GetOperatorName(P^.Dat.CaptionMarket)+
              ClicProgrammer,Nil,MfError+MfCancelButton);
              End
              Else
                     Begin
                         Close(NoType);
                CreatToDayF:=true;
               End;
             End
             Else
              Begin
               c:=IOResult;
               Rewrite(NoType);
               c:=IOResult;
               If C<>0 Then
                Begin
                 SpecialBeep;
                 MessageBox(^M+#3'Ошибка создания файла продаж за '+Date+'!'+
                 ClicProgrammer,Nil,MfError+MfCancelButton);
                End
                Else Begin
                               Close(NoType);
                      P^.Dat.CreatMarket:=True;{выставляем отметку о создании}
                      P^.Dat.CaptionMArket:=CurrentPassword;
                      CreatToDayF:=true;
                     End;
               c:=IOresult;
              End;
            End;
DocOplata  :Begin
             Assign(NoType,PAth.ToOplata+Date+'.opl');
             If P^.Dat.CreatOplata Then
             Begin
              c:=IOResult;
              Reset(NoType);
              c:=IOResult;
              If c<>0 Then
              Begin
              SpecialBeep;
              MessageBox(^M+#3'Файл оплаты консигнации за '+Date+' уже создавался оператором '+
                    GetOperatorName(P^.Dat.CaptionOplata)+
              ClicProgrammer,Nil,MfError+MfCancelButton);
              End
              Else
                     Begin
                         Close(NoType);
                CreatToDayF:=true;
               End;
             End
             Else
              Begin
               c:=IOResult;
               Rewrite(NoType);
               c:=IOResult;
               If C<>0 Then
                Begin
                 SpecialBeep;
                 MessageBox(^M+#3'Ошибка создания файла оплаты консигнации за '+Date+'!'+
                 ClicProgrammer,Nil,MfError+MfCancelButton);
                End
                Else Begin
                               Close(NoType);
                      P^.Dat.CreatOplata:=True;{выставляем отметку о создании}
                      P^.Dat.CaptionOplata:=CurrentPassword;
                      CreatToDayF:=true;
                     End;
               c:=IOresult;
              End;
            End;

DocBarterOplata  :Begin
             Assign(NoType,PAth.ToBArter+Date+'.bpl');
             If P^.Dat.CreatBarterOplata Then
             Begin
              c:=IOResult;
              Reset(NoType);
              c:=IOResult;
              If c<>0 Then
              Begin
              SpecialBeep;
              MessageBox(#3'Файл оплаты по бартеру за '+Date+' уже создавался оператором '+
                    GetOperatorName(P^.Dat.CaptionBarterOplata)+
              ClicProgrammer,Nil,MfError+MfCancelButton);
              End
              Else
                     Begin
                         Close(NoType);
                CreatToDayF:=true;
               End;
             End
             Else
              Begin
               c:=IOResult;
               Rewrite(NoType);
               c:=IOResult;
               If C<>0 Then
                Begin
                 SpecialBeep;
                 MessageBox(^M+#3'Ошибка создания файла оплаты по бартеру за '+Date+'!'+
                 ClicProgrammer,Nil,MfError+MfCancelButton);
                End
                Else Begin
                               Close(NoType);
                      P^.Dat.CreatBArterOplata:=True;{выставляем отметку о создании}
                      P^.Dat.CaptionBArterOplata:=CurrentPassword;
                      CreatToDayF:=true;
                     End;
               c:=IOresult;
              End;
            End;

DocTransport :Begin
             Assign(NoType,PAth.ToRewisia+Date+'.trn');
             If P^.Dat.CreatTransport Then
             Begin
              c:=IOResult;
              Reset(NoType);
              c:=IOResult;
              If c<>0 Then
              Begin
              SpecialBeep;
              MessageBox(#3'Файл внутренних перемещений за '+Date+' уже создавался оператором '+
                    GetOperatorName(P^.Dat.CaptionTransport)+
              ClicProgrammer,Nil,MfError+MfCancelButton);
              End
              Else
                     Begin
                         Close(NoType);
                CreatToDayF:=true;
               End;
             End
             Else
              Begin
               c:=IOResult;
               Rewrite(NoType);
               c:=IOResult;
               If C<>0 Then
                Begin
                 SpecialBeep;
                 MessageBox(^M+#3'Ошибка создания файла внутренних перемещений за '+Date+'!'+
                 ClicProgrammer,Nil,MfError+MfCancelButton);
                End
                Else Begin
                      Close(NoType);
                      P^.Dat.CreatTransport:=True;{выставляем отметку о создании}
                      P^.Dat.CaptionTransport:=CurrentPassword;
                      CreatToDayF:=true;
                     End;
               c:=IOresult;
              End;
            End;


 Else;
 End;{Case}
 Seek(f,FilePos(f)-1);
 Write(f,P^.Dat);
 Seek(f,FilePos(f)-1);
 Repeat
  Unlock(f,FilePos(f)*SizeOf(CreatToDayFile),SizeOf(CreatToDayFile));
 Until (DosError=0);
 Dispose(P,Done);
 Close(f);
 NoNetInfoMsg;
End;


Function BlockDAte1(S:TDateString):Boolean;
Var f : File Of SkladDocNumer;
 Pos,Date : LongInt;
    c : Byte;
    P : PSkladDocNumer;
Begin
 BlockDAte1:=False;
 Date:=DateStringToDate(DateMask,s);
 Pos:=Date-DateStringToDAte(DateMask,'01-01-98');
 Assign(f,Path.ToSklad+'date.db');
 c:=IOResult;
 Reset(f);
 c:=IOResult;

 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия реестра рабочих дней ('+IntToStr(c,3)+')!',Nil,mfError+mfCancelButton);
   Exit;
  End;

 If (FileSize(f)<Pos) Or (Pos<0) Then
  Begin
   Close(f);
   MessageBox(^M+#3'Дата '+s+' не найдена в реестре рабочих дней!',
   Nil,mfError+mfCancelButton);
   Exit;
  End;

 DInfoNetMsg('Жду доступа к реестру за '+s+'...');
 New(P,Init);
 Seek(f,Pos);
 Repeat
  Pause(1);
 Until Lock(f,FilePos(f)*SizeOf(SkladDocNumer),SizeOf(SkladDocNumer)); {предварительная блокировка}
 Read(f,P^.Dat);
 P^.Dat.Day.Flag:=False;
 Seek(f,FilePos(f)-1);
 Write(f,P^.Dat);
 Seek(f,FilePos(f)-1);
 Repeat
  Unlock(f,FilePos(f)*SizeOf(SkladDocNumer),SizeOf(SkladDocNumer));
 Until (DosError=0);
 Dispose(P,Done);
 Close(f);
 NoNetInfoMsg;
 BlockDAte1:=True;
 AddProtocol(s+' Закрытие программного дня!','','');
End;

Function DeBlockDAte1(S:TDateString):Boolean;
Var f : File Of SkladDocNumer;
 Pos,Date : LongInt;
    c : Byte;
    P : PSkladDocNumer;
Begin
 DeBlockDAte1:=False;
 Date:=DateStringToDate(DateMask,s);
 Pos:=Date-DateStringToDAte(DateMask,'01-01-98');
 Assign(f,Path.ToSklad+'date.db');
 c:=IOResult;
 Reset(f);
 c:=IOResult;

 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия реестра рабочих дней ('+IntToStr(c,3)+')!',Nil,mfError+mfCancelButton);
   Exit;
  End;

 If (FileSize(f)<Pos) Or (Pos<0) Then
  Begin
   Close(f);
   MessageBox(^M+#3'Дата '+s+' не найдена в реестре рабочих дней!',
   Nil,mfError++mfCancelButton);
   Exit;
  End;

 DInfoNetMsg('Жду доступа к реестру за '+s+'...');
 New(P,Init);
 Seek(f,Pos);
 Repeat
  Pause(1);
 Until Lock(f,FilePos(f)*SizeOf(SkladDocNumer),SizeOf(SkladDocNumer)); {предварительная блокировка}
 Read(f,P^.Dat);
 P^.Dat.Day.Flag:=True;
 Seek(f,FilePos(f)-1);
 Write(f,P^.Dat);
 Seek(f,FilePos(f)-1);
 Repeat
  Unlock(f,FilePos(f)*SizeOf(SkladDocNumer),SizeOf(SkladDocNumer));
 Until (DosError=0);
 Dispose(P,Done);
 Close(f);
 NoNetInfoMsg;
 DeBlockDAte1:=True;
 AddProtocol(s+' Открытие программного дня {Очень важно}','','');
End;

Function TestOpenDate1(S:TDateString):Boolean;
Var f : File Of SkladDocNumer;
 Pos,Date : LongInt;
    c : Byte;
    P : PSkladDocNumer;
Begin
 TestOpenDAte1:=False;
 Date:=DateStringToDate(DateMask,s);
 Pos:=Date-DateStringToDAte(DateMask,'01-01-98');
 Assign(f,Path.ToSklad+'date.db');
 c:=IOResult;
 Reset(f);
 c:=IOResult;

 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия реестра рабочих дней ('+IntToStr(c,3)+')!',Nil,mfError+mfCancelButton);
   Exit;
  End;

 If (FileSize(f)<Pos) Then
  Begin
   Close(f);
   MessageBox(^M+#3'Дата '+s+' не найдена в реестре рабочих дней!',
   Nil,mfError+mfCancelButton);
   Exit;
  End;

 DInfoNetMsg('Жду доступа к реестру за '+s+'...');
 New(P,Init);
 Seek(f,Pos);
 Repeat
  Pause(1);
 Until Lock(f,FilePos(f)*SizeOf(SkladDocNumer),SizeOf(SkladDocNumer)); {предварительная блокировка}
 Read(f,P^.Dat);
 If (P^.Dat.Day.Flag) Then TestOpenDAte1:=True;
 Seek(f,FilePos(f)-1);
 Write(f,P^.Dat);
 Seek(f,FilePos(f)-1);
 Repeat
  Unlock(f,FilePos(f)*SizeOf(SkladDocNumer),SizeOf(SkladDocNumer));
 Until (DosError=0);
 Dispose(P,Done);
 Close(f);
 NoNetInfoMsg;
End;

Function UseDocNumer(Const VidDoc:Byte;s:DateString;Var Numer:AllStr):Boolean;
{
  DocPrihod     =0;
  DocPereozen   =1;
  DocReturn     =2;
  DocRewisia    =3;
  DocMarket     =4;
}
Var      f : File Of SkladDocNumer;
  Pos,Date,i : LongInt;
         c : Byte;
         P : PSkladDocNumer;
      FPrihod   : File of PrihodType;
      FMarket   : File of SuperMarketType;
      FRewisia  : File of RewisiaType;
      FReturn   : File of NewVozwratType;
     FPereozenka: File of PereozenkaType;
      FTransport: File of TransportType;

Begin
 Numer[0]:=#0;
 UseDocNumer:=False;
 Date:=DateStringToDate(DateMask,s);
 Pos:=Date-DateStringToDAte(DateMask,'01-01-98');
 Assign(f,Path.ToSklad+'date.db');
 c:=IOResult;
 Reset(f);
 c:=IOResult;

 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия реестра рабочих дней ('+IntToStr(c,3)+')!',Nil,mfError+mfCancelButton);
   Exit;
  End;

 If (FileSize(f)<Pos) Then
  Begin
   Close(f);
   MessageBox(^M+#3'Дата '+s+' не найдена в реестре рабочих дней!',
   Nil,mfError+mfCancelButton);
   Exit;
  End;

 DInfoNetMsg('Определяю предварительный номер для док-та в реестре за '+s+'...');
 New(P,Init);
 Seek(f,Pos);
 Repeat
  Pause(1);
 Until Lock(f,FilePos(f)*SizeOf(SkladDocNumer),SizeOf(SkladDocNumer)); {предварительная блокировка}
 Read(f,P^.Dat);
 Seek(f,FilePos(f)-1);

 If Not(P^.Dat.Day.Flag) Then {если  день закрыт тогда}
  Begin
   Repeat
    Unlock(f,FilePos(f)*SizeOf(SkladDocNumer),SizeOf(SkladDocNumer));
   Until (DosError=0);
   Dispose(P,Done);
   Close(f);
   NoNetInfoMsg;
   MessageBox(#3^M+#3'Доступ к данным за '+S+' заблокирован!',Nil,mfError+mfCancelButton);
   Exit;
  End;

   Repeat
    Unlock(f,FilePos(f)*SizeOf(SkladDocNumer),SizeOf(SkladDocNumer));
   Until (DosError=0);
 Dispose(P,Done);
 Close(f);



 Case VidDoc Of
DocPrihod  :Begin
             Assign(FPrihod,Path.ToPrihod+S+'.Prh');
 i:=IOResult;
 Reset(FPrihod);
 i:=IOResult;
 If I=0 Then
    Begin
     i:=FileSize(FPrihod)+1;
     Close(FPrihod);
    End
 Else i:=1;
{
             While Not(Find) And (i<MaxWspom) Do
              Begin
               Inc(i);
               If (P^.Dat.Prihod.DocEmploy[i]) Then Find:=True;
              End;
              If Find Then P^.Dat.Prihod.DocEmploy[i]:=False;
}
            End;{DocPrihod}


DocTransport :Begin
             Assign(FTransport,Path.ToRewisia+S+'.trn');
 i:=IOResult;
 Reset(FTransport);
 i:=IOResult;
 If I=0 Then
    Begin
     i:=FileSize(FTransport)+1;
     Close(FTransport);
    End
 Else i:=1;
            End;{DocTransport}

DocPereozen:Begin
             Assign(FPereozenka,Path.ToCorrect+S+'.Prz');
 i:=IOResult;
 Reset(FPereozenka);
 i:=IOResult;
 If I=0 Then
    Begin
     i:=FileSize(FPereozenka)+1;
     Close(FPereozenka);
    End
 Else i:=1;
{
             i:=0;
             Find:=False;
             While Not(Find) And (i<MaxWspom) Do
              Begin
               Inc(i);
               If (P^.Dat.Prz.DocEmploy[i]) Then Find:=True;
              End;
              If Find Then P^.Dat.Prz.DocEmploy[i]:=False;}
            End;{DocPrz}
DocReturn  :Begin
             Assign(FReturn,Path.ToReturn+S+'.Vzw');
 i:=IOResult;
 Reset(FReturn);
 i:=IOResult;
 If I=0 Then
    Begin
     i:=FileSize(FReturn)+1;
     Close(FReturn);
    End
 Else i:=1;
{            i:=0;
             Find:=False;
             While Not(Find) And (i<MaxWspom) Do
              Begin
               Inc(i);
               If (P^.Dat.Return.DocEmploy[i]) Then Find:=True;
              End;
              If Find Then P^.Dat.Return.DocEmploy[i]:=False;}
            End;{DocReturn}
DocRewisia :Begin
             Assign(FRewisia,Path.ToRewisia+S+'.rwz');
 i:=IOResult;
 Reset(FRewisia);
 i:=IOResult;
 If I=0 Then
    Begin
     i:=FileSize(FRewisia)+1;
     Close(FRewisia);
    End
 Else i:=1;
{             i:=0;
             Find:=False;
             While Not(Find) And (i<MaxWspom) Do
              Begin
               Inc(i);
               If (P^.Dat.Rewisia.DocEmploy[i]) Then Find:=True;
              End;
              If Find Then P^.Dat.Rewisia.DocEmploy[i]:=False;}
            End;{DocRewisia}
DocMarket  :Begin
             Assign(FMarket,Path.ToMArket+S+'.mrk');
 i:=IOResult;
 Reset(FMarket);
 i:=IOResult;
 If I=0 Then
    Begin
     i:=FileSize(FMarket)+1;
     Close(FMarket);
    End
 Else i:=1;
{            i:=0;
             Find:=False;
             While Not(Find) And (i<MaxMArket) Do
              Begin
               Inc(i);
               If (P^.Dat.Market.DocEmploy[i]) Then Find:=True;
              End;
              If Find Then P^.Dat.Market.DocEmploy[i]:=False;}
            End;
 Else
  Begin
   NoNetInfoMsg;
   MessageBox(#3^M+#3'Не существующий вид документа!',Nil,mfError+mfCancelButton);
   Exit;
  End;{Case Else}
 End;{Case}


 Numer:=IntToStr(i,CDocNumer);
 DelSpace(Numer);
 UseDocNumer:=True;
 NoNetInfoMsg;
End;



Function SetFreeReestrNum( Res:Byte;Var Num:ArtikulStr):Boolean;
Var f : File Of DocBazType;
    P : PDocBazType;
    c : Byte;
    s : string[150];
    Find:Boolean;
    i : LongInt;
Begin
SetFreeReestrNum:=FAlse;
CAse REs Of
0:{приходники}
   Begin
   Assign(f,Path.ToSklad+'prhnum.db');
   DInfoMsg('Устанавливаю номер приходного кассового ордера...');
   End;
1:{счета-факт}
   Begin
   Assign(f,Path.ToSklad+'sfnum.db');
   DInfoMsg('Устанавливаю номер счета-фактуры...');
   End;
2:{накладные}
   Begin
   Assign(f,Path.ToSklad+'naklnum.db');
   DInfoMsg('Устанавливаю номер накладной...');
   End;
Else Exit;
End;
c:=IOREsult;
Reset(f);
c:=IOREsult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox('Ошибка открытия файла номер учетных документов!',Nil,mfError+mfCancelButton);
  Exit;
 End;

New(P,Init);
 For i:=1 to 10000 Do
  Begin
   If (I)<StrToInt(Num) Then P^.Dat.Status :=True
   Else P^.Dat.Status :=False;
   Write(f,p^.Dat);
  End;

c:=IOREsult;
Close(f);
c:=IOREsult;
SetFreeReestrNum:=True;
NoInfoMsg;
Dispose(P,Done);
End;




Function FreeReestrNum(Res:Byte;Var Num:ArtikulStr):Boolean;
Var f : File Of DocBazType;
    P : PDocBazType;
    c : Byte;
    s : string[150];
    Find:Boolean;

Begin
FreeReestrNum:=FAlse;
CAse REs Of
0:{приходники}
   Begin
   Assign(f,Path.ToSklad+'prhnum.db');
   DInfoMsg('Освобождаю номер приходного кассового ордера...');
   End;
1:{счета-факт}
   Begin
   Assign(f,Path.ToSklad+'sfnum.db');
   DInfoMsg('Освобождаю номер счета-фактуры...');
   End;
2:{накладные}
   Begin
   Assign(f,Path.ToSklad+'naklnum.db');
   DInfoMsg('Освобождаю номер накладной...');
   End;
Else Exit;
End;
c:=IOREsult;
Reset(f);
c:=IOREsult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия файла номер учетных документов!',Nil,mfError+mfCancelButton);
  NoInfoMsg;
  Exit;
 End;
New(P,Init);
Seek(f,StrToInt(Num)-1);

 Repeat
  Pause(1);
 Until Lock(f,FilePos(f)*SizeOf(DocBazType),SizeOf(DocBazType));

 Read(f,P^.Dat);

 If Not(P^.Dat.Status) Then
  Begin
    Seek(f,FilePos(f)-1);
    P^.Dat.Status:=False;
    P^.Dat.Document[0]:=#0;
    P^.Dat.DateDocument[0]:=#0;
    P^.Dat.DateC[0]:=#0;
    P^.Dat.TimeC[0]:=#0;
    P^.Dat.Numer[0]:=#0;
    Write(f,P^.Dat);
  End;



 Repeat
  Unlock(f,(FilePos(f)-1)*SizeOf(DocBazType),SizeOf(DocBazType));
 Until (DosError=0);

c:=IOREsult;
Close(f);
c:=IOREsult;
FreeReestrNum:=True;
NoInfoMsg;
Dispose(P,Done);
End;


Function GetReestrNum(Res:Byte;Var Num:ArtikulStr;E:SuperMArketType):Boolean;
Var f : File Of DocBazType;
    P : PDocBazType;
    c : Byte;
    s : string[150];
    Find:Boolean;
Begin
Num[0]:=#0;
GetReestrNum:=FAlse;
CAse REs Of
0:{приходники}
   Begin
   Assign(f,Path.ToSklad+'prhnum.db');
   DInfoMsg('Определяю номер приходного кассового ордера...');
   End;
1:{счета-факт}
   Begin
   Assign(f,Path.ToSklad+'sfnum.db');
   DInfoMsg('Определяю номер счета-фактуры...');
   End;
2:{накладные}
   Begin
   Assign(f,Path.ToSklad+'naklnum.db');
   DInfoMsg('Определяю номер накладной...');
   End;
Else Exit;
End;
c:=IOREsult;
Reset(f);
c:=IOREsult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия файла номер учетных документов!',Nil,mfError+mfCancelButton);
  NoInfoMsg;
  Exit;
 End;
New(P,Init);
Find:=False;
While Not(Eof(f)) And Not(Find) Do
BEgin

 Repeat
  Pause(1);
 Until Lock(f,FilePos(f)*SizeOf(DocBazType),SizeOf(DocBazType));

 Read(f,P^.Dat);

 If Not(P^.Dat.Status) Then
  Begin
   Find:=True;
   Seek(f,FilePos(f)-1);
   P^.Dat.Status:=True;
    P^.Dat.Document:=E.Document;
    P^.Dat.DateDocument:=E.DateC;
    P^.Dat.DateC:=fDate;
    P^.Dat.TimeC:=Times;
    P^.Dat.Numer:=IntToStr((FilePos(f))+1,CArtikul);
    Num:=P^.Dat.Numer;
    Write(f,P^.Dat);
  End;

 Repeat
  Unlock(f,(FilePos(f)-1)*SizeOf(DocBazType),SizeOf(DocBazType));
 Until (DosError=0);

End;
c:=IOREsult;
Close(f);
c:=IOREsult;
If Find Then
 Begin
  GetReestrNum:=True;
 End;
NoInfoMsg;
Dispose(P,Done);
End;


Function GetReestrNumOpl( Res:Byte;Var Num:ArtikulStr;E:PsevdoSuperMarketType):Boolean;
Var f : File Of DocBazType;
    P : PDocBazType;
    c : Byte;
    s : string[150];
    Find:Boolean;
Begin
Num[0]:=#0;
GetReestrNumOpl:=FAlse;
CAse REs Of
0:{приходники}
   Begin
   Assign(f,Path.ToSklad+'prhnum.db');
   DInfoMsg('Определяю номер приходного кассового ордера...');
   End;
1:{счета-факт}
   Begin
   Assign(f,Path.ToSklad+'sfnum.db');
   DInfoMsg('Определяю номер счета-фактуры...');
   End;
2:{накладные}
   Begin
   Assign(f,Path.ToSklad+'naklnum.db');
   DInfoMsg('Определяю номер накладной...');
   End;
Else Exit;
End;
c:=IOREsult;
Reset(f);
c:=IOREsult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия файла номер учетных документов!',Nil,mfError+mfCancelButton);
  NoInfoMsg;
  Exit;
 End;
New(P,Init);
Find:=False;
While Not(Eof(f)) And Not(Find) Do
BEgin

 Repeat
  Pause(1);
 Until Lock(f,FilePos(f)*SizeOf(DocBazType),SizeOf(DocBazType));

 Read(f,P^.Dat);

 If Not(P^.Dat.Status) Then
  Begin
   Find:=True;
   Seek(f,FilePos(f)-1);
   P^.Dat.Status:=True;
    P^.Dat.Document:=E.Document;
    P^.Dat.DateDocument:=E.DateC;
    P^.Dat.DateC:=fDate;
    P^.Dat.TimeC:=Times;
    P^.Dat.Numer:=IntToStr((FilePos(f))+1,CArtikul);
    Num:=P^.Dat.Numer;
    Write(f,P^.Dat);
  End;

 Repeat
  Unlock(f,(FilePos(f)-1)*SizeOf(DocBazType),SizeOf(DocBazType));
 Until (DosError=0);

End;
c:=IOREsult;
Close(f);
c:=IOREsult;
If Find Then
 Begin
  GetReestrNumOpl:=True;
 End;
NoInfoMsg;
Dispose(P,Done);
End;








(*
Function CalcFreeDocNumer(Const VidDoc:Byte;s:DateString;Var Numer:AllStr):Boolean;
{
  DocPrihod     =0;
  DocPereozen   =1;
  DocReturn     =2;
  DocRewisia    =3;
  DocMarket     =4;
}
Var      f : File Of SkladDocNumer;
  Pos,Date,i : LongInt;
         c : Byte;
         P : PSkladDocNumer;
      Find : Boolean;
Begin
 Numer[0]:=#0;
 CalcFreeDocNumer:=False;
 Date:=DateStringToDate(DateMask,s);
 Pos:=Date-DateStringToDAte(DateMask,'01-01-98');
 Assign(f,Path.ToSklad+'date.db');
 c:=IOResult;
 Reset(f);
 c:=IOResult;

 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия реестра рабочих дней ('+IntToStr(c,3)+')!',Nil,mfError+mfCancelButton);
   Exit;
  End;

 If (FileSize(f)<Pos) Then
  Begin
   Close(f);
   MessageBox(^M+#3'Дата '+s+' не найдена в реестре рабочих дней!',
   Nil,mfError+mfCancelButton);
   Exit;
  End;

 DInfoMsg('Выясняю номер для документа в реестре за '+s+'...');
 New(P,Init);
 Seek(f,Pos);
 Read(f,P^.Dat);

 If Not(P^.Dat.Day.Flag) Then {если  день закрыт тогда}
  Begin
   Dispose(P,Done);
   Close(f);
   NoInfoMsg;
   MessageBox(#3^M+#3'Доступ к данным за '+S+' заблокирован!',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Case VidDoc Of
DocPrihod  :Begin
             i:=0;
             Find:=False;
             While Not(Find) And (i<MaxWspom) Do
              Begin
               Inc(i);
               If (P^.Dat.Prihod.DocEmploy[i]) Then Find:=True;
              End;
              If Find Then P^.Dat.Prihod.DocEmploy[i]:=False;
            End;{DocPrihod}
DocPereozen:Begin

             i:=0;
             Find:=False;
             While Not(Find) And (i<MaxWspom) Do
              Begin
               Inc(i);
               If (P^.Dat.Prz.DocEmploy[i]) Then Find:=True;
              End;
              If Find Then P^.Dat.Prz.DocEmploy[i]:=False;
            End;{DocPrz}
DocReturn  :Begin

             i:=0;
             Find:=False;
             While Not(Find) And (i<MaxWspom) Do
              Begin
               Inc(i);
               If (P^.Dat.Return.DocEmploy[i]) Then Find:=True;
              End;
              If Find Then P^.Dat.Return.DocEmploy[i]:=False;
            End;{DocReturn}
DocRewisia :Begin

             i:=0;
             Find:=False;
             While Not(Find) And (i<MaxWspom) Do
              Begin
               Inc(i);
               If (P^.Dat.Rewisia.DocEmploy[i]) Then Find:=True;
              End;
              If Find Then P^.Dat.Rewisia.DocEmploy[i]:=False;
            End;{DocRewisia}
DocMarket  :Begin

             i:=0;
             Find:=False;
             While Not(Find) And (i<MaxMArket) Do
              Begin
               Inc(i);
               If (P^.Dat.Market.DocEmploy[i]) Then Find:=True;
              End;
              If Find Then P^.Dat.Market.DocEmploy[i]:=False;
            End;
 Else
  Begin
   Dispose(P,Done);
   Close(f);
   NoInfoMsg;
   MessageBox(#3^M+#3'Не существующий вид документа!',Nil,mfError+mfCancelButton);
   Exit;
  End;{Case Else}
 End;{Case}

 If Not(Find) Then
  Begin
   Dispose(P,Done);
   Close(f);
   NoInfoMsg;
   MessageBox(#3^M+#3'Исчерпан лимит номеров документов этого вида - '+IntToStr(i,3)+' !',
   Nil,mfError+mfCancelButton);
   Exit;
  End;

 Numer:=IntToStr(i,CDocNumer);
 DelSpace(Numer);
 CalcFreeDocNumer:=True;
 Dispose(P,Done);
 Close(f);
 NoInfoMsg;
End;
*)
(*
Function FreeDocNumer(Const VidDoc:Byte;s:DateString;Numer:AllStr):Boolean;
{
  DocPrihod     =0;
  DocPereozen   =1;
  DocReturn     =2;
  DocRewisia    =3;
  DocMarket     =4;
}
Var      f : File Of SkladDocNumer;
  Pos,Date,i : LongInt;
         c : Byte;
         P : PSkladDocNumer;
      Find : Boolean;
      Klass : String [CIZena];
Begin
 DelSpace(Numer);
 FreeDocNumer:=False;
 Date:=DateStringToDate(DateMask,s);
 Pos:=Date-DateStringToDAte(DateMask,'01-01-98');
 Assign(f,Path.ToSklad+'date.db');
 c:=IOResult;
 Reset(f);
 c:=IOResult;

 If c<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка открытия реестра рабочих дней ('+IntToStr(c,3)+')!',Nil,mfError+mfCancelButton);
   Exit;
  End;


 If (FileSize(f)<Pos) Then
  Begin
   Close(f);
   MessageBox(^M+#3'Дата '+s+' не найдена в реестре рабочих дней!',
   Nil,mfError+mfCancelButton);
   Exit;
  End;

 Case VidDoc Of
DocPrihod  :Klass:='прихода ';
DocPereozen:Klass:='переоценки ';
DocReturn  :Klass:='возврата ';
DocRewisia :Klass:='ревизии ';
DocMarket  :Klass:='продажи ';
 Else;
 End;


 DInfoNetMsg('Снимаю бронь с док-та '+Klass+Numer+' в реестре за '+s+'...');
 New(P,Init);
 Seek(f,Pos);
 Repeat
 Until Lock(f,FilePos(f)*SizeOf(SkladDocNumer),SizeOf(SkladDocNumer)); {предварительная блокировка}
 Read(f,P^.Dat);
 Seek(f,FilePos(f)-1);

 Case VidDoc Of
DocPrihod  :Begin
              P^.Dat.Prihod.DocEmploy[StrToInt(Numer)]:=True;
            End;{DocPrihod}
DocPereozen:Begin
              P^.Dat.Prz.DocEmploy[StrToInt(Numer)]:=True;
            End;{DocPrz}
DocReturn  :Begin
              P^.Dat.Return.DocEmploy[StrToInt(Numer)]:=True;
            End;{DocReturn}
DocRewisia :Begin
              P^.Dat.Rewisia.DocEmploy[StrToInt(Numer)]:=True;
            End;{DocRewisia}
DocMarket  :Begin
              P^.Dat.Market.DocEmploy[StrToInt(Numer)]:=True;
            End;
 Else
  Begin
   Repeat
    Unlock(f,FilePos(f)*SizeOf(SkladDocNumer),SizeOf(SkladDocNumer));
   Until (DosError=0);
   Dispose(P,Done);
   Close(f);
   NoNetInfoMsg;
   MessageBox(#3^M+#3'Не существующий вид документа!',Nil,mfError+mfCancelButton);
   Exit;
  End;{Case Else}
 End;{Case}

 FreeDocNumer:=True;
 Write(f,P^.DAt);
 Seek(f,FilePos(f)-1);
   Repeat
    Unlock(f,FilePos(f)*SizeOf(SkladDocNumer),SizeOf(SkladDocNumer));
   Until (DosError=0);
 Dispose(P,Done);
 Close(f);
 NoNetInfoMsg;
End;
*)

{
Var f : File Of SkladDocNumer;
    f1 : File Of CreatToDayFile;

    b : PSkladDocNumer;
    b1 : PCreatToDayFile;
    r,i : LongInt;
Begin
DateMask:='dd-mm-yy';
r:=DateStringToDate(DAteMask,'03-01-99');
WriteLN('01-01-99',DateStringToDate(DAteMask,'01-01-99'));
WriteLN('31-12-01',DateStringToDate(DAteMask,'31-12-01'));
Writeln ((SizeOf(SkladDocNumer))*365 div 1024 );
Readln;
Assign(f,'e:\nskl\main\date.db');
Rewrite(f);
Assign(f1,'e:\nskl\main\creat.db');
Rewrite(f1);
New(b,Init);
New(b1,Init);
 For i:=145367 to 146827 Do
  Begin
   B^.Dat.Day.Dt:=i;
   If i>r Then B^.Dat.Day.Flag:=True;
   If DayOfWeek(i)=sunday Then B^.Dat.Day.Flag:=False;
   Write(f,b^.Dat);
   Write(f1,b1^.Dat);
  End;
Dispose(b,done);
Dispose(b1,done);
Close(f);
Close(f1);}

(*
Var f : File Of SkladDocNumer;
    f1 : File Of CreatToDayFile;

    b : PSkladDocNumer;
    b1 : PCreatToDayFile;
    r,i : LongInt;


Begin
DateMask:='dd-mm-yy';
r:=DateStringToDate(DAteMask,'03-01-99');
Writeln(DateStringToDate(DAteMask,'31-12-03'));
Readln;
WriteLN('01-01-99',DateStringToDate(DAteMask,'01-01-99'));
WriteLN('31-12-03',DateStringToDate(DAteMask,'31-12-03'));
Writeln ((SizeOf(SkladDocNumer))*365 div 1024 );
Readln;
Assign(f,'c:\nskl\main\date.db');
Rewrite(f);
Assign(f1,'c:\nskl\main\creat.db');
Rewrite(f1);
New(b,Init);
New(b1,Init);
 For i:=145367 to 147557 Do
  Begin
   B^.Dat.Day.Dt:=i;
   If i>r Then B^.Dat.Day.Flag:=True;
   If DayOfWeek(i)=sunday Then B^.Dat.Day.Flag:=False;
   Write(f,b^.Dat);
   Write(f1,b1^.Dat);
  End;
Dispose(b,done);
Dispose(b1,done);
Close(f);
Close(f1);
*)

{
Var f : File Of SkladDocNumer;
    f1 : File Of CreatToDayFile;

    b : PSkladDocNumer;
    b1 : PCreatToDayFile;
    r,i : LongInt;
Begin
DateMask:='dd-mm-yy';
r:=DateStringToDate(DAteMask,'03-01-99');
WriteLN('01-01-99',DateStringToDate(DAteMask,'01-01-99'));
WriteLN('31-12-01',DateStringToDate(DAteMask,'31-12-01'));
Writeln ((SizeOf(SkladDocNumer))*365 div 1024 );
Readln;
Assign(f,'c:\n\main\date.db');
Rewrite(f);
Assign(f1,'c:\n\main\creat.db');
Rewrite(f1);
New(b,Init);
New(b1,Init);
 For i:=145367 to 146827 Do
  Begin
   B^.Dat.Day.Dt:=i;
   If i>r Then B^.Dat.Day.Flag:=True;
   If DayOfWeek(i)=sunday Then B^.Dat.Day.Flag:=False;
   Write(f,b^.Dat);
   Write(f1,b1^.Dat);
  End;
Dispose(b,done);
Dispose(b1,done);
Close(f);
Close(f1);}


(*Procedure FindError2;
Var k : LongInt;
    f : File Of DocBazType;
    P : PDocBazType;
    c : Word;
    Mrf : FIle Of SuperMArketType;
    E : PSuperMarketType;
Begin



Assign(Mrf,PAth.ToMarket+'02-11-04.mrk');
c:=IOREsult;

Reset(Mrf);
c:=IOREsult;
If c<>0 Then
 Begin
  MessageBox(#3+PAth.ToMarket+'02-11-04.mrk',Nil,mfError+mfCancelButton);
  NoInfoMsg;
  Exit;
 End;


New(E,Init);
c:=IOREsult;
Seek(f,12);
c:=IOREsult;
Read(Mrf,E^.Dat);
c:=IOREsult;
E^.Dat.SfNumer:='671';
c:=IOREsult;
Seek(Mrf,FilePos(f)-1);
c:=IOREsult;
Write(Mrf,E^.Dat);
c:=IOREsult;
MemCC(E^.Dat.Document+'=>'+E^.Dat.NaklNumer+'=>'+E^.Dat.SFNumer);
Dispose(E,Done);


New(E,Init);
c:=IOREsult;
Seek(f,102);
c:=IOREsult;
Read(Mrf,E^.Dat);
c:=IOREsult;
E^.Dat.SfNumer:='682';
c:=IOREsult;
Seek(Mrf,FilePos(f)-1);
c:=IOREsult;
Write(Mrf,E^.Dat);
c:=IOREsult;
MemCC(E^.Dat.Document+'=>'+E^.Dat.NaklNumer+'=>'+E^.Dat.SFNumer);
Dispose(E,Done);




c:=IOREsult;
Close(Mrf);
c:=IOREsult;


Assign(Mrf,PAth.ToMarket+'03-11-04.mrk');
c:=IOREsult;

Reset(Mrf);
c:=IOREsult;
If c<>0 Then
 Begin
  MessageBox(#3+PAth.ToMarket+'03-11-04.mrk',Nil,mfError+mfCancelButton);
  NoInfoMsg;
  Exit;
 End;


New(E,Init);
c:=IOREsult;
Seek(f,0);
c:=IOREsult;
Read(Mrf,E^.Dat);
c:=IOREsult;
E^.Dat.SfNumer:='683';
c:=IOREsult;
Seek(Mrf,FilePos(f)-1);
c:=IOREsult;
Write(Mrf,E^.Dat);
c:=IOREsult;
MemCC(E^.Dat.Document+'=>'+E^.Dat.NaklNumer+'=>'+E^.Dat.SFNumer);
Dispose(E,Done);


New(E,Init);
c:=IOREsult;
Seek(f,1);
c:=IOREsult;
Read(Mrf,E^.Dat);
c:=IOREsult;
E^.Dat.SfNumer:='684';
c:=IOREsult;
Seek(Mrf,FilePos(f)-1);
c:=IOREsult;
Write(Mrf,E^.Dat);
c:=IOREsult;
MemCC(E^.Dat.Document+'=>'+E^.Dat.NaklNumer+'=>'+E^.Dat.SFNumer);
Dispose(E,Done);

New(E,Init);
c:=IOREsult;
Seek(f,2);
c:=IOREsult;
Read(Mrf,E^.Dat);
c:=IOREsult;
E^.Dat.SfNumer:='685';
c:=IOREsult;
Seek(Mrf,FilePos(f)-1);
c:=IOREsult;
Write(Mrf,E^.Dat);
c:=IOREsult;
MemCC(E^.Dat.Document+'=>'+E^.Dat.NaklNumer+'=>'+E^.Dat.SFNumer);
Dispose(E,Done);


New(E,Init);
c:=IOREsult;
Seek(f,3);
c:=IOREsult;
Read(Mrf,E^.Dat);
c:=IOREsult;
E^.Dat.SfNumer:='686';
c:=IOREsult;
Seek(Mrf,FilePos(f)-1);
c:=IOREsult;
Write(Mrf,E^.Dat);
c:=IOREsult;
MemCC(E^.Dat.Document+'=>'+E^.Dat.NaklNumer+'=>'+E^.Dat.SFNumer);
Dispose(E,Done);


New(E,Init);
c:=IOREsult;
Seek(f,4);
c:=IOREsult;
Read(Mrf,E^.Dat);
c:=IOREsult;
E^.Dat.SfNumer:='687';
c:=IOREsult;
Seek(Mrf,FilePos(f)-1);
c:=IOREsult;
Write(Mrf,E^.Dat);
c:=IOREsult;
MemCC(E^.Dat.Document+'=>'+E^.Dat.NaklNumer+'=>'+E^.Dat.SFNumer);
Dispose(E,Done);



New(E,Init);
c:=IOREsult;
Seek(f,6);
c:=IOREsult;
Read(Mrf,E^.Dat);
c:=IOREsult;
E^.Dat.SfNumer:='688';
c:=IOREsult;
Seek(Mrf,FilePos(f)-1);
c:=IOREsult;
Write(Mrf,E^.Dat);
c:=IOREsult;
MemCC(E^.Dat.Document+'=>'+E^.Dat.NaklNumer+'=>'+E^.Dat.SFNumer);
Dispose(E,Done);



c:=IOREsult;
Close(Mrf);
c:=IOREsult;

  MessageBox(^M+#3+'Продажи Исправлены - ВСЕ!',Nil,mfInformation+mfCancelButton);

End;

Procedure FindError;
Var k : LongInt;
    f : File Of DocBazType;
    P : PDocBazType;
    c : Word;
    Mrf : FIle Of SuperMArketType;
    E : PSuperMarketType;
Begin
{исправили СФ НУМ}
Assign(f,Path.ToSklad+'sfnum.db');
c:=IOREsult;
Reset(f);
c:=IOREsult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия файла номер учетных документов!',Nil,mfError+mfCancelButton);
  NoInfoMsg;
  Exit;
 End;

New(P,Init);
c:=IOREsult;
Seek(f,669);
c:=IOREsult;
Read(f,P^.Dat);
c:=IOREsult;
For k:=1 To 250 Do
Begin
P^.Dat.Status:=False;
P^.Dat.Document:='';
P^.Dat.DateDocument:='';
P^.Dat.DateC:='';
P^.Dat.TimeC:='';
Write(f,P^.Dat);
End;

Seek(f,670);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,671);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,672);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,673);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,674);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,675);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,676);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,677);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,678);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,679);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,680);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,681);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,682);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,683);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,684);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,685);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,686);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);

Seek(f,687);
c:=IOREsult;
P^.Dat.Status:=True;
Write(f,P^.Dat);



Dispose(P,Done);

c:=IOREsult;
Close(f);
c:=IOREsult;




Assign(f,Path.ToSklad+'sfnum.db');
c:=IOREsult;
Reset(f);
c:=IOREsult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия файла номер учетных документов!',Nil,mfError+mfCancelButton);
  NoInfoMsg;
  Exit;
 End;


New(P,Init);
c:=IOREsult;
Seek(f,670);
c:=IOREsult;
Read(f,P^.Dat);
c:=IOREsult;
P^.Dat.Status:=True;
P^.Dat.Document:='13';
P^.Dat.DateDocument:='02-11-04';
P^.Dat.DateC:='02-11-04';
P^.Dat.TimeC:='14:00:00';
P^.Dat.Numer:='671';
c:=IOREsult;
Seek(f,FilePos(f)-1);
c:=IOREsult;
Write(f,P^.Dat);



c:=IOREsult;
Seek(f,681);
c:=IOREsult;
Read(f,P^.Dat);
c:=IOREsult;
P^.Dat.Status:=True;
P^.Dat.Document:='103';
P^.Dat.DateDocument:='02-11-04';
P^.Dat.DateC:='02-11-04';
P^.Dat.TimeC:='14:00:00';
P^.Dat.Numer:='682';
c:=IOREsult;
Seek(f,FilePos(f)-1);
c:=IOREsult;
Write(f,P^.Dat);


c:=IOREsult;
Seek(f,682);
c:=IOREsult;
Read(f,P^.Dat);
c:=IOREsult;
P^.Dat.Status:=True;
P^.Dat.Document:='1';
P^.Dat.DateDocument:='03-11-04';
P^.Dat.DateC:='03-11-04';
P^.Dat.TimeC:='14:00:00';
P^.Dat.Numer:='683';
c:=IOREsult;
Seek(f,FilePos(f)-1);
c:=IOREsult;
Write(f,P^.Dat);

c:=IOREsult;
Seek(f,683);
c:=IOREsult;
Read(f,P^.Dat);
c:=IOREsult;
P^.Dat.Status:=True;
P^.Dat.Document:='2';
P^.Dat.DateDocument:='03-11-04';
P^.Dat.DateC:='03-11-04';
P^.Dat.TimeC:='14:00:00';
P^.Dat.Numer:='684';
c:=IOREsult;
Seek(f,FilePos(f)-1);
c:=IOREsult;
Write(f,P^.Dat);


c:=IOREsult;
Seek(f,684);
c:=IOREsult;
Read(f,P^.Dat);
c:=IOREsult;
P^.Dat.Status:=True;
P^.Dat.Document:='3';
P^.Dat.DateDocument:='03-11-04';
P^.Dat.DateC:='03-11-04';
P^.Dat.TimeC:='14:00:00';
P^.Dat.Numer:='685';
c:=IOREsult;
Seek(f,FilePos(f)-1);
c:=IOREsult;
Write(f,P^.Dat);


c:=IOREsult;
Seek(f,685);
c:=IOREsult;
Read(f,P^.Dat);
c:=IOREsult;
P^.Dat.Status:=True;
P^.Dat.Document:='4';
P^.Dat.DateDocument:='03-11-04';
P^.Dat.DateC:='03-11-04';
P^.Dat.TimeC:='14:00:00';
P^.Dat.Numer:='686';
c:=IOREsult;
Seek(f,FilePos(f)-1);
c:=IOREsult;
Write(f,P^.Dat);

c:=IOREsult;
Seek(f,686);
c:=IOREsult;
Read(f,P^.Dat);
c:=IOREsult;
P^.Dat.Status:=True;
P^.Dat.Document:='5';
P^.Dat.DateDocument:='03-11-04';
P^.Dat.DateC:='03-11-04';
P^.Dat.TimeC:='14:00:00';
P^.Dat.Numer:='687';
c:=IOREsult;
Seek(f,FilePos(f)-1);
c:=IOREsult;
Write(f,P^.Dat);

c:=IOREsult;
Seek(f,687);
c:=IOREsult;
Read(f,P^.Dat);
c:=IOREsult;
P^.Dat.Status:=True;
P^.Dat.Document:='7';
P^.Dat.DateDocument:='03-11-04';
P^.Dat.DateC:='03-11-04';
P^.Dat.TimeC:='14:00:00';
P^.Dat.Numer:='688';
c:=IOREsult;
Seek(f,FilePos(f)-1);
c:=IOREsult;
Write(f,P^.Dat);


Dispose(P,Done);

c:=IOREsult;
Close(f);
c:=IOREsult;


  MessageBox(^M+#3+'Базу Порядковых номеров иправили ВСЕ!',Nil,mfInformation+mfCancelButton);
  NoInfoMsg;


End;                             *)




Var f : File Of SkladDocNumer;
    f1 : File Of CreatToDayFile;
    df : File Of DocBazType;

    b : PSkladDocNumer;
    b1 : PCreatToDayFile;
    pd : PDocBazType;
    r,i : LongInt;


Begin
If FindParam('/CREAT') Then
Begin

DateMask:='dd-mm-yy';
r:=DateStringToDate(DAteMask,'03-01-99');
WriteLN('01-01-99',DateStringToDate(DAteMask,'01-01-99'));
WriteLN('01-01-10',DateStringToDate(DAteMask,'01-01-10'));
Writeln ((SizeOf(SkladDocNumer))*365 div 1024 );
Readln;
Assign(f,'c:\date.db');
Rewrite(f);
Assign(f1,'c:\creat.db');
Rewrite(f1);
New(b,Init);
New(b1,Init);
 For i:=145367 to 150114 Do
  Begin
   B^.Dat.Day.Dt:=i;
   If i>r Then B^.Dat.Day.Flag:=True;
   If DayOfWeek(i)=sunday Then B^.Dat.Day.Flag:=False;
   Write(f,b^.Dat);
   Write(f1,b1^.Dat);
  End;
Dispose(b,done);
Dispose(b1,done);
Close(f);
Close(f1);



Assign(df,'c:\prhnum.db');
Rewrite(df);
New(pd,Init);
 For i:=1 to 9999 Do
  Begin
   {Pd^.Dat.Numer:=IntToStr(i,CArtikul);}
   Pd^.Dat.Status :=False;
   Pd^.Dat.Document[0]:=#0;
   Pd^.Dat.DateDocument[0]:=#0;
   Write(df,pd^.Dat);
  End;
Dispose(pd,done);
Close(df);

Assign(df,'c:\naklnum.db');
Rewrite(df);
New(pd,Init);
 For i:=1 to 9999 Do
  Begin
   {Pd^.Dat.Numer:=IntToStr(i,CArtikul);}
   Pd^.Dat.Status :=False;
   Pd^.Dat.Document[0]:=#0;
   Pd^.Dat.DateDocument[0]:=#0;
   Write(df,pd^.Dat);
  End;
Dispose(pd,done);
Close(df);

Assign(df,'c:\sfnum.db');
Rewrite(df);
New(pd,Init);
 For i:=1 to 9999 Do
  Begin
   {Pd^.Dat.Numer:=IntToStr(i,CArtikul);}
   Pd^.Dat.Status :=False;
   Pd^.Dat.Document[0]:=#0;
   Pd^.Dat.DateDocument[0]:=#0;
   Write(df,pd^.Dat);
  End;
Dispose(pd,done);
Close(df);
End;

End.

