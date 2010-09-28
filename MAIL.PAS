{$I Compile.INC}
{$IfNDEF DPMI}
{$F+}
{$O+}
{$EndIf}

Unit Mail;

INTERFACE

uses Glob,
     Servstr, Dos, Memory, Drivers, App, Serv, Dialogs, MyCalc;

const FMailNDoc = 100;
      FMailDate = 101;
      FMailPost = 102;
      FMailPoluch = 103;



Type
  PSelectImportWindow = ^TSelectImportWindow;
  TSelectImportWindow = object(TDialog)
  Calc        : PMyCalculator;
   Function Start(Var P:PImportSuperMarketType;Var ss :TMyString):Boolean;
   Procedure FullPreView;
   Procedure Refresh;
   procedure HandleEvent(var Event: TEvent); virtual;
   Destructor Done;Virtual;
  end;




 Procedure DialUpAuto;
 Procedure AddProtocolNoMsg(s,s1,s2:String);


{ Имя Файла:
   N  Дата Поставщ Получатель
  111 1111 0.2     03,       }

{Формирует имя файла}
Function GetImportFileName(As:DocumentEditZ;SklPoluch:ArtikulStr):AllStr;
Function GetExportFileName(As:DocumentEditZ;SklPost:ArtikulStr):AllStr;

{установка признака чтения}
Function SetReadMailAttribute(FN:String):boolean;
{Запись архива}
Function PackMailFile(FName:TMyString; ClKod:ArtikulStr):boolean;
{Распаковка архива}
Function UnpackMailFile(FName:TMyString; ClKod:ArtikulStr):boolean;
{для типа клиент-банка}
Function PackMailFileClient(FName:TMyString; ClKod:ArtikulStr):boolean;
Function UnpackMailFileClient(FName:TMyString; ClKod:ArtikulStr):boolean;
Function GetExportFileNameClient(As:DocumentEditZ;SklPost:ArtikulStr):AllStr;
Function GetExportFileNameClientMail(As:DocumentEditZ;SklPost:ArtikulStr):AllStr;
Function GetExportFileNameClientConfirmation(As:DocumentEditZ;SklPost:ArtikulStr):AllStr;
Function GetExportFileNameClientConfirmationNew(As:DocumentEditZ;SklPost:ArtikulStr):AllStr;
{для мобильной торговли}
Function GetExportFileNameClientNew(As:DocumentEditZ;SklPost:ArtikulStr;AgentKod:ArtikulStr):AllStr;
Function PackMailFileClientNew(FName:TMyString; ClKod:ArtikulStr):boolean;
Function UnpackMailFileClientNew(FName:TMyString; ClKod:ArtikulStr):boolean;


Function SetCopyMailAttribute(FN:String):boolean;
Function SetCopyMailTime(FN:String;TM:LongInt):boolean;
Procedure CalcTrashAndErase;

function TestTMailCatalog(s:String): boolean;

IMPLEMENTATION

Uses TPDate,Objects, MsgBox, Utils, Utils1, Utils4, DBEngine,
     Utils5, DbEngin2,Hex,ServStr2,
     Views,Protect, NetCAll, DiskUtil, Utils9;

Const RecievBuffer=10000;


Type NoType = Array[1..RecievBuffer] Of Char;

Type PNoType = ^NoTypePtr;
     NoTypePtr =Object(TObject)
     Dat : NoType;
     Constructor Init;
     Destructor Done; Virtual;
     End;



Var
    MakeKod : ArtikulStr;




Constructor NoTypePtr.Init;
VAr c: Word;
Begin
TObject.Init;
 For c:=1 To RecievBuffer Do
  begin
   DAt[c]:=#0;
  End;
End;

Destructor NoTypePtr.Done;
Begin
TObject.Done;
End;


Function PackMailFileClientNew(FName:TMyString; ClKod:ArtikulStr):boolean;
 var s1:string;
     Result : LongInt;
begin
  PackMailFileClientNew:=False;
  DInfoMsg('Упаковываю почту...',True);


  s1:=Path^.Dat.ToUtils+'rar.exe'+' a -m5 -ep -ep1 -av- -inul -y -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToExport[1]+Fname+' '+Path^.Dat.ToTemp+TruncStr(FNAme){+' '+NullStr^};
  DelSpaceRight(s1);

  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;
{
  Writeln(s1);
  Readln;
 }
  {exec (GetEnv('Comspec'),' /C '+S1);}
  exec (Path^.Dat.ToUtils+'rar.exe',' a -m5 -ep -ep1 -av- -inul -y -w'+Path^.Dat.ToTemp+' '+
  Path^.Dat.ToWinLnk+'out\'+Fname+' '+Path^.Dat.ToTemp+TruncStr(FNAme){+' '+NullStr^});



  DelSpaceRight(s1);

(*
  Writeln(Path^.Dat.ToUtils+'rar.exe',' a -m5 -ep -ep1 -av- '{-inul}+' -ds -y -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToExport[StrToInt(ClKod)]+Fname+' '+Path^.Dat.ToTemp+TruncStr(FNAme){+' '+NullStr^});
  Readln;
*)

  Result:=DosError;

  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  If Result=0 Then
  PackMailFileClientNew:=True;
  CursorLines:=1543;
  NoInfoMsg;
  Application^.Redraw;

  If FExists(Path^.Dat.ToWinLnk+'out\'+Fname) Then
    Begin
     PackMailFileClientNew:=True;
    End
  Else
     PackMailFileClientNew:=False;
    Case Result Of
   {0:MessageBox(#3'Упаковка почты успешно завершена!'^M
  +#3'Данные упакованы в '+PathExpImp.ToExport[StrToInt(ClKod)]+Fname,
  Nil,mfInformation+mfCancelButton);}
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
End;

Function UnpackMailFileClientNew(FName:TMyString; ClKod:ArtikulStr):boolean;
var s:string;
     Result : LongInt;

Begin

  UnpackMailFileClientNew:=false;

  DInfoMsg('Распаковываю почту...',True);
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;

  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y -av- -w'+Path^.Dat.ToTemp+' '+
  Path^.Dat.ToWinLnk+'IN\'+FName+' '+
  Path^.Dat.ToTemp+' '+NullStr^;

  {exec (GetEnv('Comspec'),' /c '+s);}
  exec (Path^.Dat.ToUtils+'rar.exe',' e -inul -y '{-av-} +'-w'+Path^.Dat.ToTemp+' '+
  Path^.Dat.ToWinLnk+'IN\'+FName+' '+
  Path^.Dat.ToTemp{+' '+NullStr^});


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
   UnpackMailFileClientNew:=true;
   End;
End;




Function GetExportFileNameClientNew(As:DocumentEditZ;SklPost:ArtikulStr;AgentKod:ArtikulStr):AllStr;
var
  Test: AllStr;
Begin
 GetExportFileNameClientNew[0]:=#0;

 SklPost:=IntToStr(StrToInt(SklPost),CMantissa);
 RFormatZerro(SklPost,CMantissa);

 AgentKod:=IntToStr(StrToInt(AgentKod),{CKod}3);
 RFormatZerro(AgentKod,{CKod}3);
 System.Insert('.',AgentKod,3);

 DelSpace(As.EditPosition);
 As.EditPosition:=IntToStr(StrToInt(As.EditPosition),{CDocNumer}CArtikul);
 RFormatZerro(As.EditPosition,CArtikul{CDocNumer});

 Test:=As.EditPosition;
{
 Test:=HexLong(StrToInt(As.EditPosition));
 Test:=copy(Test,Length(Test)-4,5);

 RFormatZerro(Test,3);
}
 GetExportFileNameClientNew:=PredZakazPrefix+Test+AgentKod+SklPost;
End;





Procedure RunMailScript;
Var Event : TEvent;
    s1,s2,s3,s4 : String;
    c : Word;
    Cmd : Text;
Begin

If Not FExists(Path^.Dat.ToUtils+'netsc.bat') Then
 Begin
  MessageBox(NoExistsModul^+ClicProgrammer^,Nil,mfError+mfCancelButton);
  Exit;
 End;

  CursorLines:=1543;
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SwapVectors;

  Exec(GetEnvMy,' /C '+Path^.Dat.ToUtils+'netsc.bat '+NullStr^);

  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;

  Event.What:=evCommand;
  Event.Command:=cmNone;
  Application^.PutEvent(Event);

  Application^.Redraw;
End;





Procedure AddProtocolNoMsg(s,s1,s2:String);
Var f : Text;
         i : Byte;
         s3 : String;
Begin
  If DisableProtocol=1 Then Exit;
  i:=IOResult;
  Assign(f,Path^.Dat.ToProtocol+FDate+'.pr');
  If LockPrWriteRead(FDate,FAlse) Then
  Begin
  i:=IOResult;
  Append(f);
  i:=IOResult;
  If I<>0 Then
  Begin
    NoInfoMsg;
    MessageBox(^M+#3'Ошибка записи протокола!'+ClicProgrammer^+' Код:'+
    IntToStr(I,CKol),Nil,
    mfError+mfCancelButton);
    Exit;
  End;
  i:=IOResult;
  s3:=FDate+'('+Times+') Оператор: ('+CurrentPassword+') '+GetOperatorField(FNAme,CurrentPassword)+
  ' Компьютер: ('+NetComputerName+')';
  s3:=Code(s3);
  Writeln(f,s3);
{
  Writeln(f,FDate+'('+Times+') Оператор: ('+CurrentPassword+') '+GetOperatorName(CurrentPassword)+
  ' Компьютер: ('+GetMachineName+')');
}
  s:=Code(s);
  Writeln(f,s);

  If s1[0]<>#0 Then
  Begin
   s1:=Code(s1);
   Writeln(f,s1);
  End;

  If s2[0]<>#0 Then
  Begin
   s2:=Code(s2);
   Writeln(f,s2);
  End;

  Writeln(f,'-------------------------------------------------------');
  Close(f);
  Repeat
  Until UnLockPrWriteRead(FDate,FAlse);

  End;
  i:=IOResult;
End;


{
27-08-01(17:33:36) Оператор: (31) СВИСТУНОВА Склад:МАГАЗИН N 22-НАДЕЖДА
Прием прайс-листа 01-09-01.EXE
}
Procedure AddRemoteProtocol(s,s1,s2:String);
Var f : Text;
         i : Byte;
         s3 : String;
Begin
  If RemoteProtocol=0 Then Exit;
  i:=IOResult;
  Assign(f,Path^.Dat.ToRemoteDir+'dialup.txt');
  i:=IOResult;
  Append(f);
  i:=IOResult;
  If I<>0 Then
  Begin
    MessageBox(^M+#3'Ошибка записи протокола удаленного доступа!'+ClicProgrammer^+' Код:'+
    IntToStr(I,CKol),Nil,
    mfError+mfCancelButton);
    Exit;
  End;
  i:=IOResult;
  s3:=FDate+'('+Times+') '+' Склад:'+GetClientField(FClient,Rek^.Dat.Kod,1);
  Format(s3,50);
  Format(s,35);
  WriteLn(f,''+s3+'│'+s+'│Оператор: ('+CurrentPassword+') '+GetOperatorField(FNAme,CurrentPassword));

  {Writeln(f,s);}
{ If s1[0]<>#0 Then
  Begin
   Writeln(f,s1);
  End;

  If s2[0]<>#0 Then
  Begin
   Writeln(f,s2);
  End;

  Writeln(f,'-------------------------------------------------------');}
  Close(f);
  i:=IOResult;
End;




Function GetImportFileName(As:DocumentEditZ;SklPoluch:ArtikulStr):AllStr;
 var
    test,d,SklPost : ArtikulStr;

Begin
 SklPost:=IntToStr(StrToInt(Rek^.Dat.Kod),CMantissa);
 RFormatZerro(SklPost,CMantissa);
 SklPoluch:=IntToStr(StrToInt(SklPoluch),CMantissa);
 RFormatZerro(SklPoluch,CMantissa);
 DelSpace(As.EditPosition);
 As.EditPosition:=IntToStr(StrToInt(As.EditPosition),CDocNumer);
 RFormatZerro(As.EditPosition,CLitrMantissa);
 While Pos('-',As.D)>0 Do As.D[Pos('-',As.D)]:=' ';
 DelSpace(As.D);
 d:=copy(As.D,1,4);
 Test:=WordToMyHex(StrToInt(As.EditPosition));
 RFormatZerro(Test,CMantissa);
 GetImportFileName:=PrihodPrefix+Test+d+SklPost[1]+'.'+SklPost[2]+SklPOluch;
End;



Function GetExportFileName(As:DocumentEditZ;SklPost:ArtikulStr):AllStr;
 var
    Test,d,SklPoluch : ArtikulStr;
Begin
 SklPost:=IntToStr(StrToInt(SklPost),CMantissa);
 RFormatZerro(SklPost,CMantissa);
 SklPoluch:=IntToStr(StrToInt(Rek^.Dat.Kod),CMantissa);
 RFormatZerro(SklPoluch,CMantissa);
 DelSpace(As.EditPosition);
 As.EditPosition:=IntToStr(StrToInt(As.EditPosition),CDocNumer);
 RFormatZerro(As.EditPosition,CLitrMantissa);
 While Pos('-',As.D)>0 Do As.D[Pos('-',As.D)]:=' ';
 DelSpace(As.D);
 d:=copy(As.D,1,4);
 Test:=WordToMyHex(StrToInt(As.EditPosition));
 RFormatZerro(Test,CMantissa);
 GetExportFileName:=PrihodPrefix+Test+d+SklPost[1]+'.'+SklPost[2]+SklPoluch;
{Writeln(As.EditPosition+d+SklPost[1]+'.'+SklPost[2]+SklPOluch);
 Readln;}
End;





Function GetExportFileNameClient(As:DocumentEditZ;SklPost:ArtikulStr):AllStr;
var
  Test,d,SklPoluch : AllStr;
  Start : LongInt;
  StartS : TDAteString;
Begin
 GetExportFileNameClient[0]:=#0;
 SklPost:=IntToStr(StrToInt(SklPost),CMantissa);
 RFormatZerro(SklPost,CClientKod);

 DelSpace(As.EditPosition);
 As.EditPosition:=IntToStr(StrToInt(As.EditPosition),CDocNumer);
 RFormatZerro(As.EditPosition,CDocNumer);

 StartS:='01-01-'+Copy(As.D,1+2+1+2+1,CMantissa);
 StartS:=IntToStr(DateStringToDate(DateMask,As.D)-DateStringToDate(DateMask,StartS),3);
 RFormatZerro(StartS,3);
 Test:=HexLong(StrToInt(As.EditPosition));
 Test:=copy(Test,Length(Test)-2,3);

 RFormatZerro(Test,3);

 GetExportFileNameClient:=PredZakazPrefix+SklPost+StartS+'.'+Test;
End;



Function GetExportFileNameClientConfirmation(As:DocumentEditZ;SklPost:ArtikulStr):AllStr;
var
  Test,d,SklPoluch : AllStr;
  Start : LongInt;
  StartS : TDAteString;
Begin
 GetExportFileNameClientConfirmation[0]:=#0;
 SklPost:=IntToStr(StrToInt(SklPost),CMantissa);
 RFormatZerro(SklPost,CClientKod);

 DelSpace(As.EditPosition);
 As.EditPosition:=IntToStr(StrToInt(As.EditPosition),CDocNumer);
 RFormatZerro(As.EditPosition,CDocNumer);

 StartS:='01-01-'+Copy(As.D,1+2+1+2+1,CMantissa);
 StartS:=IntToStr(DateStringToDate(DateMask,As.D)-DateStringToDate(DateMask,StartS),3);
 RFormatZerro(StartS,3);
 Test:=HexLong(StrToInt(As.EditPosition));
 Test:=copy(Test,Length(Test)-2,3);

 RFormatZerro(Test,3);

 GetExportFileNameClientConfirmation:=ConfirmationPredZakazPrefix+SklPost+StartS+'.'+Test;
End;



Function GetExportFileNameClientConfirmationNew(As:DocumentEditZ;SklPost:ArtikulStr):AllStr;
var
  Test,d,SklPoluch : AllStr;
  Start : LongInt;
  StartS : TDAteString;
Begin
 GetExportFileNameClientConfirmationNew[0]:=#0;
 SklPost:=IntToStr(StrToInt(SklPost),CMantissa);
 RFormatZerro(SklPost,CMantissa);

 DelSpace(As.EditPosition);
 As.EditPosition:=IntToStr(StrToInt(As.EditPosition),CArtikul);
 RFormatZerro(As.EditPosition,CArtikul);

 GetExportFileNameClientConfirmationNew:=ConfirmationPredZakazPrefix+As.EditPosition+'.'+SklPost;
End;







Function GetExportFileNameClientMail(As:DocumentEditZ;SklPost:ArtikulStr):AllStr;
var
  Test,d,SklPoluch : AllStr;
  Start : LongInt;
  StartS : TDAteString;
Begin
 SklPost:=IntToStr(StrToInt(SklPost),CMantissa);
 RFormatZerro(SklPost,CMantissa);

 DelSpace(As.EditPosition);
 As.EditPosition:=IntToStr(StrToInt(As.EditPosition),CDocNumer);
 RFormatZerro(As.EditPosition,CDocNumer);

 StartS:='01-01-'+Copy(As.D,1+2+1+2+1,CMantissa);
 StartS:=IntToStr(DateStringToDate(DateMask,As.D)-DateStringToDate(DateMask,StartS),3);
 RFormatZerro(StartS,3);

 Test:=HexLong(StrToInt(As.EditPosition));
 Test:=copy(Test,Length(Test)-2,3);

 RFormatZerro(Test,3);

 GetExportFileNameClientMail:=SklPost+StartS+Test+'.txt';
{Writeln(As.EditPosition+d+SklPost[1]+'.'+SklPost[2]+SklPOluch);
 Readln;}
End;






Function SetReadMailAttribute(FN:String):boolean;
Var F: File;
    Attr: word;
Begin
  SetReadMailAttribute:=False;
  Assign(f,FN);
  GetFAttr(f,Attr);
   if doserror=0 then
     begin
      SetFAttr(f,Dos.Hidden+Dos.Archive);
      SetReadMailAttribute:=True;
     end
   else
     begin
      MessageBox(^M+#3+'Ошибка доступа к файлу архива '+FN+'!'^M+
	 #3+' Код: '+IntToStr(DosError,CLitrMantissa),Nil,mfError+mfCancelButton);
     end;
End;


Function PackMailFile(FName:TMyString; ClKod:ArtikulStr):boolean;
 var s1:string;
     Result : LongInt;
begin
  PackMailFile:=False;
  DInfoMsg('Упаковываю почту...',True);


  s1:=Path^.Dat.ToUtils+'rar.exe'+' a -m5 -ep -ep1 -av- -inul -y -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToExport[StrToInt(ClKod)]+Fname+' '+Path^.Dat.ToTemp+TruncStr(FNAme){+' '+NullStr^};
  DelSpaceRight(s1);

  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;
{
  Writeln(s1);
  Readln;
 }
  {exec (GetEnv('Comspec'),' /C '+S1);}
  exec (Path^.Dat.ToUtils+'rar.exe',' a -m5 -ep -ep1 -av- -inul -y -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToExport[StrToInt(ClKod)]+Fname+' '+Path^.Dat.ToTemp+TruncStr(FNAme){+' '+NullStr^});



  DelSpaceRight(s1);

(*
  Writeln(Path^.Dat.ToUtils+'rar.exe',' a -m5 -ep -ep1 -av- '{-inul}+' -ds -y -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToExport[StrToInt(ClKod)]+Fname+' '+Path^.Dat.ToTemp+TruncStr(FNAme){+' '+NullStr^});
  Readln;
*)

  Result:=DosError;

  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  If Result=0 Then
  PackMailFile:=True;
  CursorLines:=1543;
  NoInfoMsg;
  Application^.Redraw;

  If FExists(PathExpImp^.Dat.ToExport[StrToInt(ClKod)]+Fname) Then
    Begin
     PackMailFile:=True;
    End
  Else
     PackMailFile:=False;
    Case Result Of
   {0:MessageBox(#3'Упаковка почты успешно завершена!'^M
  +#3'Данные упакованы в '+PathExpImp.ToExport[StrToInt(ClKod)]+Fname,
  Nil,mfInformation+mfCancelButton);}
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
End;



Function PackMailFileClient(FName:TMyString; ClKod:ArtikulStr):boolean;
 var s1:string;
     Result : LongInt;
begin
  PackMailFileClient:=False;
  DInfoMsg('Упаковываю почту...',True);


  s1:=Path^.Dat.ToUtils+'rar.exe'+' a -m5 -ep -ep1 -av- -inul -y -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToExport[1]+Fname+' '+Path^.Dat.ToTemp+TruncStr(FNAme){+' '+NullStr^};
  DelSpaceRight(s1);

  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;
{
  Writeln(s1);
  Readln;
 }
  {exec (GetEnv('Comspec'),' /C '+S1);}
  exec (Path^.Dat.ToUtils+'rar.exe',' a -m5 -ep -ep1 -av- -inul -y -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToExport[1]+Fname+' '+Path^.Dat.ToTemp+TruncStr(FNAme){+' '+NullStr^});



  DelSpaceRight(s1);

(*
  Writeln(Path^.Dat.ToUtils+'rar.exe',' a -m5 -ep -ep1 -av- '{-inul}+' -ds -y -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToExport[StrToInt(ClKod)]+Fname+' '+Path^.Dat.ToTemp+TruncStr(FNAme){+' '+NullStr^});
  Readln;
*)

  Result:=DosError;

  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  If Result=0 Then
  PackMailFileClient:=True;
  CursorLines:=1543;
  NoInfoMsg;
  Application^.Redraw;

  If FExists(PathExpImp^.Dat.ToExport[1]+Fname) Then
    Begin
     PackMailFileClient:=True;
    End
  Else
     PackMailFileClient:=False;
    Case Result Of
   {0:MessageBox(#3'Упаковка почты успешно завершена!'^M
  +#3'Данные упакованы в '+PathExpImp.ToExport[StrToInt(ClKod)]+Fname,
  Nil,mfInformation+mfCancelButton);}
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
End;




Function UnpackMailFile(FName:TMyString; ClKod:ArtikulStr):boolean;

var s:string;
     Result : LongInt;

Begin
  DInfoMsg('Распаковываю почту...',True);
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;

  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y -av- -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[StrToInt(ClKod)]+FName+' '+
  Path^.Dat.ToTemp+' '+NullStr^;

  {exec (GetEnv('Comspec'),' /c '+s);}
  exec (Path^.Dat.ToUtils+'rar.exe',' e -inul -y '{-av-} +'-w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[StrToInt(ClKod)]+FName+' '+
  Path^.Dat.ToTemp{+' '+NullStr^});

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
End;

Function UnpackMailFileClient(FName:TMyString; ClKod:ArtikulStr):boolean;

var s:string;
     Result : LongInt;

Begin
  DInfoMsg('Распаковываю почту...',True);
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;

  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y -av- -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+FName+' '+
  Path^.Dat.ToTemp+' '+NullStr^;

  {exec (GetEnv('Comspec'),' /c '+s);}
  exec (Path^.Dat.ToUtils+'rar.exe',' e -inul -y '{-av-} +'-w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+FName+' '+
  Path^.Dat.ToTemp{+' '+NullStr^});

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
End;


Var
    ViewImportWindow : PSelectImportWindow;
    PrhNaklList,ScreenList : PBox;
    StatusMail  : Word;
    MasStatusMail : Maska2;
    Control, ControlStatusMail : PView;
    R : TRect;


Function TSelectImportWindow.Start(Var P:PImportSuperMarketType;Var ss : TMyString):Boolean;
Label 1;
Var  c : Word;
     As : DocumentEditZ;
     s : String;
     AllSkl : Maska30;
Begin



Start:=False;
MasStatusMail[1]:=0;
MasStatusMail[2]:=1;
Convert2(MasStatusMail);

BitToWord2(MasStatusMail,StatusMail);


1:

R.Assign(14, 3, 65, 19);
New(ViewImportWindow, Init(R, 'Укажите импортируемую накладную'));
ViewImportWindow^.Options := ViewImportWindow^.Options or ofCenterX or ofCenterY;
ViewImportWindow^.HelpCtx := $E002;


R.Assign(6, 1, 45, 2);
ControlStatusMail := New(PCheckboxes, Init(R,
  NewSItem('~О~бработанные',
  NewSItem('~Н~е обработанные', Nil))));
ViewImportWindow^.Insert(ControlStatusMail);
ControlStatusMail^.SetData(StatusMail);

R.Assign(0, 0, 0, 0);
PrhNaklList := New(PBox, Init(R, 1, Nil));
PrhNaklList^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(50, 3, 51, 15);
Control := New(PScrollBar, Init(R));
ViewImportWindow^.Insert(Control);

R.Assign(1, 3, 50, 15);
ScreenList := New(PBox, Init(R, 1, PScrollbar(Control)));
ScreenList^.NewList(New(PMyCollection, Init(0,1)));
ScreenList^.HelpCtx:=$F212;
ScreenList^.FocusItem(0);

ViewImportWindow^.Insert(ScreenList);

  R.Assign(1, 2, 47, 3);
  ViewImportWindow^.Insert(New(PLabel, Init(R, 'Поставщик             N     Дата       Статус', ScreenList)));

ViewImportWindow^.SelectNext(False);

ViewImportWindow^.SelectNext(False);

ViewImportWindow^.Refresh;

c:=Desktop^.ExecView(ViewImportWindow);
If c<>cmCancel Then
 Begin

  s:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);
  As.EditPosition:=Copy(s,1+CClient+1,CDocNumer);

  As.EditPosition:=IntToStr(StrToInt(As.EditPosition),CDocNumer);
  As.D:=Copy(s,1+CClient+1+CDocNumer+1,CDate);
  MakeKod:=Copy(s,1+CClient+1+CDocNumer+1+CDate+1+13+1,CMakeKod);
  MakeKod:=IntToStr(StrToInt(MAkeKod),CDocNumer);


   {
   As.EditPosition:=A.Document;
   As.D:=A.Date;
   }

WordToBit30(AllSkladS,AllSkl);
Convert30(AllSkl);
 If StrToInt(MakeKod)=0 Then
 Begin
   Dispose(Control,Done);
   Dispose(PrhNaklList,Done);
   Dispose(ScreenList,Done);
   Dispose(ViewImportWindow,Done);
   DInfoMsg('Операции с этим объектом на Вашем складе запрещены!',False);
   Beep1;
   NoInfoMsg;
   Goto 1;
 End;

 If AllSkl[StrToInt(MakeKod)]=0 Then
  Begin
   Dispose(Control,Done);
   Dispose(PrhNaklList,Done);
   Dispose(ScreenList,Done);
   Dispose(ViewImportWindow,Done);
   DInfoMsg('Операции с этим объектом на Вашем складе запрещены!',False);
   Beep1;
   NoInfoMsg;
   Goto 1;
  End;



  If Not(GetImport(As,MakeKod,P,ss,true)) Then
   Begin
    Dispose(Control,Done);
    Dispose(PrhNaklList,Done);
    Dispose(ScreenList,Done);
    Dispose(ViewImportWindow,Done);
    Goto 1;
   End
   Else
     Start:=True;


 End;
Dispose(Control,Done);
Dispose(PrhNaklList,Done);
Dispose(ScreenList,Done);
Dispose(ViewImportWindow,Done);
End;



Procedure TSelectImportWindow.FullPreView;
VAr ws,S : String;
   As : DocumentEditZ;
    P1 : PImportSuperMArketType;
    R : TRect;
    PList : PBox;
    c : Word;
    SDoc,SDAte : TDAteString;
    ss : TMyString;

Function GetImportIDField(Field:Byte;Art:ArtikulStr; PP: PImportSuperMarketType):TEnjoyStr;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    c : Word;
Begin
 GetImportIdField[0]:=#0;
 For c:=1 To CMAx Do
  Begin
   If PP^.Dat.NSertif[c].Baz.BazKod=Art Then  Break;
  End;
 If Not(PP^.Dat.NSertif[c].Baz.BazKod=Art) Then Exit;

   Case Field Of
  FFFName:Begin
           DelSpaceRight(PP^.Dat.NSertif[c].Baz.Name);
           DelSpaceRight(PP^.Dat.NSertif[c].Baz.Name2);
           GetImportIdField:=PP^.Dat.NSertif[c].Baz.Name+' '+PP^.Dat.NSertif[c].Baz.Name2;
          End;

  FName:GetImportIDField:=PP^.Dat.NSertif[c].Baz.Name;
  FName2:GetImportIDField:=PP^.Dat.NSertif[c].Baz.Name2;
  FFName:GetImportIDField:=PP^.Dat.NSertif[c].Baz.Name;
  FFName2:GetImportIDField:=PP^.Dat.NSertif[c].Baz.Name2;
  FLitr:GetImportIDField:=PP^.Dat.NSertif[c].Baz.Litr;
  FMAssa:GetImportIDField:=PP^.Dat.NSertif[c].Baz.Massa;
  FInPack:GetImportIDField:=PP^.Dat.NSertif[c].Baz.InPack;
  FOperator:GetImportIDField:=PP^.Dat.NSertif[c].Baz.CAption;
  {FLock:GetImportIDField:=PP^.Dat.NSertif[c].Baz.LockCAption;}
  FKtoSertif:GetImportIDField:=PP^.Dat.NSertif[c].Baz.KSertif;
 FDateSertif:GetImportIDField:=PP^.Dat.NSertif[c].Baz.DSertif;

  FNalog:GetImportIDField:=PP^.Dat.NSertif[c].Baz.Nalog;
  FVidNalog:Begin
             Str(PP^.Dat.NSertif[c].Baz.VidNalog:COne,St);
             DelSpace(St);
             GetImportIDField:=St;
            End;
  FNDS     :GetImportIDField:=PP^.Dat.NSertif[c].Baz.NDS;
  FVidNDS  :Begin
             Str(PP^.Dat.NSertif[c].Baz.VidNDS:COne,St);
             DelSpace(St);
             GetImportIDField:=St;
            End;
 FOrganization :Begin
             {
             Str(PP^.Dat.NSertif[c].Baz.Organization:COne,St);
             DelSpace(St);
             GetImportIDField:=St;
             }
            End;
{$IfDEF Tara}
  FFEnable :Begin
             Str(PP^.Dat.NSertif[c].Baz.FantomEnable:COne,St);
             DelSpace(St);
             GetImportIDField:=St;
            End;
  FFKod    :GetImportIDField:=PP^.Dat.NSertif[c].Baz.FantomKod;
  FFInPack :GetImportIDField:=PP^.Dat.NSertif[c].Baz.FantomInPack;
{$EndIF}

  FMera    : Begin
             st:=PP^.Dat.NSertif[c].Baz.Mera;
             DelSpaceRight(St);
             GetImportIDField:=St;
            {
              Case PP^.Dat.NSertif[c].Baz.Mera Of
              0:st:='шт';
              1:st:='кг';
              2:st:='мш';
              3:st:='л ';
              4:st:='бл';
              5:st:='бр';
              Else St:='??';
              End;{Case}
             { GetImportIDField:=St;}
             End;
   Else;
   End;{CAse}

  If Not(PP^.Dat.NSertif[c].Baz.Employ) And (Field in [FFName,FNAme]) Then GetImportIDField:='!!!ТОВАР УДАЛЕН!!!';
End;


Begin
  DInfoMsg('Формирую документ. Ждите...',True);

  s:=ScreenList^.GetText(ScreenList^.Focused,ScreenList^.List^.Count);
  As.EditPosition:=Copy(s,1+CClient+1,CDocNumer);

  As.EditPosition:=IntToStr(StrToInt(As.EditPosition),CDocNumer);
  As.D:=Copy(s,1+CClient+1+CDocNumer+1,CDate);
  MakeKod:=Copy(s,1+CClient+1+CDocNumer+1+CDate+1+13+1,CMakeKod);
  MakeKod:=IntToStr(StrToInt(MAkeKod),CDocNumer);

  New(P1,Init);
  If Not(GetImport(As,MakeKod,P1,ss,False)) Then
   Begin
    NoInfoMsg;
    Dispose(P1,Done);
    Exit;
   End;

{из просмотра прихода}

R.Assign(0,0,0,0);

PList := New(PBox, Init(R, 1, Nil));
PList^.NewList(New(PTextCollection, Init(1,1)));

For c:=1 To P1^.Dat.Amount Do
 Begin
  S:=P1^.Dat.Element[c].Baz.BazKod;
  ws:=P1^.Dat.Element[c].Baz.Name{GetImportIdField(FNAme,P1^.Dat.Element[c].BazKod,P1)};
  Format(ws,CName);
  s:=ws+'│'+s;

  ws:=P1^.Dat.Element[c].Baz.InPack{GetImportIdField(FInPack,P1^.Dat.Element[c].BazKod,P1)};
  RFormat(ws,CInPack);
  s:=s+'│'+ws;

  ws:=P1^.Dat.Element[c].Baz.Litr{GetImportIdField(FLitr,P1^.Dat.Element[c].BazKod,P1)};
  RFormat(ws,CLitr);
  s:=s+'│'+ws;

  DelSpace(P1^.Dat.Element[c].Input.Kol);
  RFormat(P1^.Dat.Element[c].Input.Kol,CKol);
  s:=s+'│'+P1^.Dat.Element[c].Input.Kol;

  DelSpace(P1^.Dat.Element[c].Input.Zakupka);
  RFormat(P1^.Dat.Element[c].Input.Zakupka,CZenaZ);

  If ({FindParam('/EZ')}(EnableZakupka=1)) Or (StrToInt(CurrentPassword)=0) Then
  s:=s+'│'+P1^.Dat.Element[c].Input.Zakupka
  Else
  s:=s+'│'+CodeZakupka;

  DelSpace(P1^.Dat.Element[c].Input.R_Zena);
  RFormat(P1^.Dat.Element[c].Input.R_Zena,CZena);
  s:=s+'│'+P1^.Dat.Element[c].Input.R_Zena;{+
  IntToStr(P1^.Dat.Element[c].Input.DivisionNumber,COne);}

  ws:=CalcPackNoFile({GetImportIDField(FInPack,P1^.Dat.Element[c].BazKod,P1)}
  P1^.Dat.Element[c].Baz.InPack,P1^.Dat.Element[c].Input.Kol);
  DelSpace(ws);
  Format(ws,CPAck);
  s:=s+'│'+ws+'│';


  PList^.List^.Insert(NewStr(s));
  PList^.SetRange(PList^.List^.Count);
 End;

For c:=1 To P1^.Dat.AmountS Do
 Begin
  S:=P1^.Dat.ElementS[c].Baz.BazKod;
  ws:=P1^.Dat.ElementS[c].Baz.Name{GetImportIdField(FNAme,P1^.Dat.Element[c].BazKod,P1)};
  Format(ws,CName);
  s:=ws+'│'+s;

  ws:=P1^.Dat.ElementS[c].Baz.InPack{GetImportIdField(FInPack,P1^.Dat.Element[c].BazKod,P1)};
  RFormat(ws,CInPack);
  s:=s+'│'+ws;

  ws:=P1^.Dat.ElementS[c].Baz.Litr{GetImportIdField(FLitr,P1^.Dat.Element[c].BazKod,P1)};
  RFormat(ws,CLitr);
  s:=s+'│'+ws;

  DelSpace(P1^.Dat.ElementS[c].Input.Kol);
  RFormat(P1^.Dat.ElementS[c].Input.Kol,CKol);
  s:=s+'│'+P1^.Dat.ElementS[c].Input.Kol;

  DelSpace(P1^.Dat.ElementS[c].Input.Zakupka);
  RFormat(P1^.Dat.ElementS[c].Input.Zakupka,CZenaZ);

  If ({FindParam('/EZ')}(EnableZakupka=1)) Or (StrToInt(CurrentPassword)=0) Then
  s:=s+'│'+P1^.Dat.ElementS[c].Input.Zakupka
  Else
  s:=s+'│'+CodeZakupka;

  DelSpace(P1^.Dat.ElementS[c].Input.R_Zena);
  RFormat(P1^.Dat.ElementS[c].Input.R_Zena,CZena);
  s:=s+'│'+P1^.Dat.ElementS[c].Input.R_Zena;{+
  IntToStr(P1^.Dat.Element[c].Input.DivisionNumber,COne);}

  ws:=CalcPackNoFile({GetImportIDField(FInPack,P1^.Dat.Element[c].BazKod,P1)}
  P1^.Dat.ElementS[c].Baz.InPack,P1^.Dat.ElementS[c].Input.Kol);
  DelSpace(ws);
  Format(ws,CPAck);
  s:=s+'│'+ws+'│';


  PList^.List^.Insert(NewStr(s));
  PList^.SetRange(PList^.List^.Count);
 End;


PList^.FocusItem(0);

s[0]:=#0;
If ({FindParam('/EZ')}(EnableZakupka=1)) Or (StrToInt(CurrentPassword)=0) Then
Begin
MyStr(P1^.Dat.SummaZakupka,CIZena,CMAntissaZ,s);
{s:=P1^.Dat.SummaZakupka;}
DelSpace(s);
s:=' Всего по З/Ценам: '+s;
End;
MyStr(P1^.Dat.SummaZ,CIZena,CMAntissa,ws);
DelSpace(ws);
s:=s+' Всего по Р/Ценам: '+ws+'  Оператор:'+GetOperatorField(FNAme,P1^.Dat.Caption);


SDoc:=P1^.Dat.Document;
SDate:=DateToDateString(DAteMask,P1^.Dat.DateC);

Dispose(P1,Done);

NoInfoMsg;
                   {Вставить номер и дату документа в просмотре}
FullScreen(PList,'Наименование товара         Код  Фас Литр  Колич   З/Цена   Р/Цена   Упаковок',s,
SDoc,SDAte,0);
Dispose(PList,Done);
End;





Procedure TSelectImportWindow.Refresh;
Var F : File;
    s,s1 : String;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
SDoc,SDate,STime : TDAteString;
    SName,StatusMailStr  : AllStr;
    c : Word;
    Ch : Char;

Function TestNameFromRP(s:AllStr):Boolean;
Var ResStr:ArtikulStr;
    l : LongInt;
Begin
TestNameFromRP:=False;
ReSStr[0]:=#0;

ResStr:=Copy(S,8,1)+Copy(s,10,1);

If Not(ResStr='00') Then
 Begin
  TestNameFromRP:=True;
 End
 Else TestNameFromRP:=False;


ResStr:=Copy(S,8,1)+Copy(s,10,1);

If Not(StrToInt(ResStr) in [0,20,30,40,50,60,70,80,90]) Then
 Begin
  TestNameFromRP:=True;
 End
 Else TestNameFromRP:=False;


if (s[10] in ['k','K','p','P','d','D']) Then
 Begin
  TestNameFromRP:=False;
 End;

End;


Begin
DInfoMsg('Читаю входящую почту...',True);
PrhNaklList^.NewList(Nil);
PrhNaklList^.NewList(New(PTextCollection, Init(0,1)));
ScreenList^.NewList(Nil);
ScreenList^.NewList(New(PMyCollection, Init(0,1)));

WordToBit2(StatusMail,MasStatusMail);
Convert2(MAsStatusMail);

 FindFirst(PathExpImp^.Dat.ToImport[1]+PrihodPrefix+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
  If TestNameFromRP(DirInfo.Name) Then
  Begin
   SDoc:=IntToStr(MyHexToWord(Copy(DirInfo.Name,{1}2,{CLitrMantissa}CMantissa)),CDocNumer);
   RFormatZerro(SDoc,CDocNumer);
   SDAte:=Copy(DirInfo.Name,CLitrMantissa+1,4);
   System.Insert('-',SDAte,3);
   SDAte:=SDate+'-'+Copy(FDAte,7,2);
   MakeKod:=DirInfo.Name[8]+DirInfo.Name[10];
   RFormatZerro(MakeKod,CMAkeKod);

   If HiddenAttribute(PathExpImp^.Dat.ToImport[1]+DirInfo.Name) Then
     StatusMailStr:='Обработано   '
   Else
     StatusMailStr:='Не обработано';

   SName:=GetMakeField(FClient,MakeKod,1);
   Format(SName,CClient);
   s:=SName+'│'+SDoc+'│'+SDate+'│'+StatusMailStr+'│'+MAkeKod;

   If ((MasStatusMail[1]=1) And (StatusMailStr='Обработано   ')) Or
      ((MasStatusMail[2]=1) And (StatusMailStr='Не обработано')) Then
    Begin
   PrhNaklList^.List^.Insert(NewStr(s));
   PrhNaklList^.SetRange(PrhNaklList^.List^.Count);
    End;
  End;{TestNameFromRP}
   FindNext(DirInfo);
 end;{While}

If PrhNaklList^.List^.Count>0 Then
 Begin
  For c:=0 To PrhNaklList^.List^.Count-1 Do
   Begin
    s:=PrhNaklList^.GetText(c,PrhNaklList^.List^.Count);
    ScreenList^.List^.Insert(NewStr(s));
    ScreenList^.SetRange(ScreenList^.List^.Count);
    ScreenList^.FocusItem(0);
   End;
 End;
NoInfoMsg;
Redraw;
End;



procedure TSelectImportWindow.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var Test : Word;

begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc:Calculator;
        cmFullview :
	     Begin
          ClearFind;
     If (ScreenList^.State and sfFocused <> 0) And (ScreenList^.List<>Nil)And(ScreenList^.List^.Count>=1) Then
            Begin
		   FullPreView;
            End;
          End;
        cmRefresh  :Refresh;
   Else;
   End;

   Else;
   End;

  Inherited HandleEvent(Event);

  If (Desktop^.Current=PView(ViewImportWindow)) And (Event.What <> EvKeyDown) Then
        Begin
                         if (ControlStatusMail^.State and sfFocused <> 0)Then
                                  Begin
                                        ControlStatusMail^.GetData(Test);
                                        If Test <> StatusMail Then
                                        Begin
                                         StatusMail:=Test;
                                         Refresh;
                                         ViewImportWindow^.Redraw;
                                        End;
                                  End;
        End;
  ClearEvent(Event);
End;


Destructor TSelectImportWindow.Done;
Begin
Dispose(ControlStatusMail,Done);
TDialog.Done;
End;




function ReadFromFile(FName:string;Var NumRead:word;Var Buf:PNoType):boolean;

Var FromF:File;
    i :word;
Begin
  ReadFromFile:= false;
  Assign(FromF, FName);
  i:=IOResult;
  Reset(FromF, 1);
  i:=IOResult;
  if i<>0 then
   begin
    MessageBox(^M+#3'Не могу открыть файл '+FNAme+'. Код:'+IntToStr(i,CKol),nil,mfError+mfCancelButton);
    exit;
   end;
  i:=IOResult;
  BlockRead(FromF, Buf^.DAt, SizeOf(Buf^.Dat), NumRead);
  i:=IOResult;
  if i<>0 then
     begin
      MessageBox(^M+#3'Ошибка чтения! '+FNAme+'. Код:'+IntToStr(i,CKol),nil,mfError+mfCancelButton);
      i:=IOResult;
      System.close(FromF);
      i:=IOResult;
      exit;
    end;
  i:=IOResult;
  System.close(FromF);
  i:=IOResult;
  if i=0 then ReadFromFile:=true;
End;





function WriteToFile(FName:string;NumRead:word;Var Buf:PNoType):boolean;
var ToF: file;
    NumWritten,i: Word;
Begin
  WriteToFile:=false;
  Assign(ToF,FName);
  i:=IOResult;
  Rewrite(ToF, 1);
  i:=IOResult;
  if i<>0 then
   begin
    MessageBox(^M+#3'Не могу создать файл '+FNAme+'. Код:'+IntToStr(i,CKol),nil,mfError+mfCancelButton);
    exit;
   end;
  i:=IOResult;
    BlockWrite(ToF, Buf^.DAt, NumRead, NumWritten);
    i:=IOResult;
    if i<>0 then
     begin
      MessageBox(^M+#3'Ошибка записи в '+FNAme+'. Код:'+IntToStr(i,CKol),nil,mfError+mfCancelButton);
      i:=IOResult;
      System.close(ToF);
      i:=IOResult;
      FlushFile;
      exit;
    end;
   i:=IOResult;
   System.close(ToF);
   i:=IOResult;
   if i=0 then WriteToFile:=true;
End;


function ReadFromFileNew(VAr FromF:File;Var NumRead:word;Var Buf:PNoType):Word;
Var i :word;
Begin
  ReadFromFileNew:= 0;
  i:=IOResult;
  BlockRead(FromF, Buf^.DAt, SizeOf(Buf^.Dat), NumRead);
  ReadFromFileNew:=IOResult;
End;



function WriteToFileNew(s:TMyString; NumRead:word;Var Buf:PNoType;Position:LongInt):Word;
var NumWritten,i: Word;
    VAr ToF:File;
Begin
  WriteToFileNew:=0;
  Assign(ToF,s);
  i:=IOResult;
  Reset(Tof,1);
  i:=IOResult;
  If i<>0 Then
   Begin
    WriteToFileNew:=I;
    Exit;
   End;
  Seek(ToF,Position);
{!!!}
  i:=IOResult;
  If i<>0 Then
   Begin
    WriteToFileNew:=I;
    Exit;
   End;

  BlockWrite(ToF, Buf^.DAt, NumRead, NumWritten);
{!!!}
  i:=IOResult;
  If i<>0 Then
   Begin
    WriteToFileNew:=I;
    Exit;
   End;
  Close(ToF);
  i:=IOResult;
  WriteToFileNew:=I;
End;


{эта процедура работает на машине отправителя
и помечает на своей машине уже переданные получателю файлы
и на машине отправителя успешно полученные файла}
Function SetCopyMailAttribute(FN:String):boolean;
Var F: File;
    Attr: word;
Begin
  SetCopyMailAttribute:=False;
  Assign(f,FN);
  GetFAttr(f,Attr);
   if doserror=0 then
     begin
      SetFAttr(f,Dos.Hidden+Dos.Archive+Dos.SysFile);
      if doserror=0 then SetCopyMailAttribute:=True;
     end
   else
     begin
      MessageBox(^M+#3+'Ошибка доступа к файлу архива '+FN+'!'^M+
	 #3+' Код: '+IntToStr(DosError,CLitrMantissa)+' Отметка об успешной передаче не установлена',Nil,mfError+mfCancelButton);
     end;
End;


Function SetCopyMailTime(FN:String;TM:LongInt):boolean;
Var F: File;
    Attr: word;
Begin
  SetCopyMailTime:=False;
  Assign(f,FN);
  Attr:=IOResult;
  Reset(f);
  Attr:=IOResult;
   if Attr=0 then
     begin
      SetFTime(f,TM);
      Close(f);
      Attr:=IOResult;
      SetCopyMailTime:=True;
     end
   else
     begin
      MessageBox(^M+#3+'Ошибка доступа к файлу архива '+FN+'!'^M+
	 #3+' Код: '+IntToStr(Attr,CLitrMantissa)+' Отметка об успешной передаче не установлена',Nil,mfError+mfCancelButton);
     end;
End;

{генерируем список файлов подлежащих отправке}
{эта процедура работает с локальными данными}
Procedure MakeListOutFile(Var P : PBox);
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


{генерируем список файлов подлежащих отправке}
{эта процедура работает с локальными данными}
Procedure MakeListOutFileDAyReport(Var P : PBox);
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


{генерируем список файлов подлежащих получению эта процедура работает с удаленнм диском}
Procedure MakeListInFile(Var P : PBox);
Var s : TMyString;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
    c : Word;
    size : String[CIZena];
    Find : Boolean;
Begin
 DInfoMsg('Формирую список накладных, подлежащих приему. Ждите...',True);
 FindFirst(PAth^.Dat.ToRemoteDir+PrihodPrefix+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
    s:=DirInfo.Name;

   If Not SystemAttribute(PAth^.Dat.ToRemoteDir+DirInfo.Name) Then
   Begin
    If Not(s=FDAte+'.0'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4]) And
       Not(s=FDAte+'.k'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4])
       Then

    If Not (Pos('.0'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4],s)>0) And
       Not (Pos('.k'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4],s)>0) And
       Not (Pos('.K'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4],s)>0) Then
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


NoInfoMsg;
End;



Procedure MakeListInFilePrice(Var P : PBox);
Var s : TMyString;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
    c : Word;
    size : String[CIZena];
    f : File;
Begin

 If FExists(PAth^.Dat.ToArchiv+Path^.Dat.PriceName{'remote.exe'}) Then
  Begin
   If SystemAttribute(PAth^.Dat.ToArchiv+Path^.Dat.PriceName{'remote.exe'}) Then
    begin
     Assign(f,Path^.Dat.ToArchiv+Path^.Dat.PriceName{'remote.exe'});
     c:=IOResult;
     Erase(f);
     c:=IOResult;
    End;
  End;

DInfoMsg('Формирую список накладных, подлежащих приему. Ждите...',True);

 FindFirst(PAth^.Dat.ToRemoteDir+Path^.Dat.PriceName{'remote.exe'}, AnyFile, DirInfo);
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

NoInfoMsg;
End;



Procedure MakeListInFilePassword(Var P : PBox;Var TT :LongInt);
Var s : TMyString;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
 DirInfoB: SearchRec;         { For Windows, use TSearchRec }
    c : Word;
    size : String[CIZena];
    f : File;
Begin

DInfoMsg('Формирую список для обновления паролей. Ждите...',True);

 FindFirst(PAth^.Dat.ToArchiv+'system.pwl', AnyFile, DirInfoB);
 while DosError = 0 do
 begin
    FindNext(DirInfoB);
 end;{While}
 DosError := 0;

 FindFirst(PAth^.Dat.ToRemoteDir+'system.pwl', AnyFile, DirInfo);
 while DosError=0 do
 begin
    s:=DirInfo.Name;
   If (DirInfoB.Time<>DirInfo.Time) Or (DirInfoB.Size<>DirInfo.Size) Then
   Begin
    TT:=DirInfo.Time;
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
Procedure MakeListInFileBase(Prf:ArtikulStr;Var P : PBox);
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

(*
Function LockUnLockObject2(Prefix:Char;c:ArtikulStr;SetLock:Boolean;Var Operator:StrNAme):Boolean;
Var f : File of RegionType;
    Pos,l : LongInt;
    Code : Integer;
    Paths : String;
    s : RegionType;
    st : ArtikulStr;
    AllSkl : Maska15;
Begin
 Operator[0]:=#0;
 DInfoNetMsg('Блокирую регион, группу, маршрут с кодом '+c);
 LockUnLockObject2:=False;
 Paths[0]:=#0;
Case Prefix Of
    GroupPrefix:Paths:=Path^.Dat.ToSPR+'Group.db';
    RegionPrefix  :Paths:=Path^.Dat.ToSPR+'Region.db';
    RoutePrefix  :Paths:=Path^.Dat.ToSPR+'Route.db';
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
     MessageBox(^M+#3'Обращение к группе, региону, маршруту - позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(RegionType),SizeOf(RegionType));{предварительная блокировка}
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
       Seek(f,{Filepos(f)}Pos{-1});
       Repeat
        Unlock(f,{FilePos(f)}Pos*SizeOf(RegionType),SizeOf(RegionType));
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
      Unlock(f,{FilePos(f)}Pos*SizeOf(RegionType),SizeOf(RegionType));
      Until DosError=0;
      Close(f);
      L:=IOResult;
      NoNetInfoMsg;
      LockUnLockObject2:=True;
      Exit;
  End;
End;
*)











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
AutoSearchBank(BankPrefix);{пока не работает т.к. не перешли еще к справочнику банков}
AutoSearchMera(MeraPrefix);
AutoSearchKSertif(KSertifPrefix);
AutoSearchExpert(ExpertPrefix);
AutoSearchClass(ClassPrefix);
AutoSearchPersonal(PersonalPrefix);
AutoSearchKassa(KassaPrefix);

End;





{генерируем список файлов подлежащих получению эта процедура работает с удаленнм диском}
Procedure MakeListInFileFromUpDAte(Var P : PBox);
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



{генерируем список файлов подлежащих отправке эта процедура работает с локальными данными}
Procedure MakeListOutFileTools(Var P : PBox);
Var s : TMyString;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
    c : Word;
    Size:String[CIZena];
Begin

DInfoMsg('Формирую список накладных к отправке. Ждите...',True);

 FindFirst(PathExpImp^.Dat.ToImport[1]+'mail.*', AnyFile, DirInfo);

 while DosError = 0 do
 begin
    s:=DirInfo.Name;
   If Not SystemAttribute(PathExpImp^.Dat.ToImport[1]+DirInfo.Name) Then
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

  s:=Path^.Dat.ToUtils+'rar.exe x -inul -y -w'+Path^.Dat.ToTemp+' '+Path^.Dat.ToArchiv+'system.pwl'+
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







Procedure DialUpAuto;
Label RestartWrite,RestartRead,
      RestartWrite1,RestartRead1,
	 RestartWrite2,RestartRead2,
	 RestartWrite3,RestartRead3,
	 RestartWrite4,RestartRead4,
	 RestartWrite5,RestartRead5,
	 RestartWrite6,RestartRead6,
	 RestartWrite7,RestartRead7,
	 RestartWrite8,RestartRead8;

VAr L : Word;
    P : PBox;
    R : TRect;
    M : MAska7;
    s : String;
    PP : PNoType;
    IO,NumRead : Word;
    StartF,StopF : File;
    c : LongInt;
    Position : LongInt;
    InpErr,OutErr,Inp,Out : Word;
    CurSize,Size : LongInt;
    Event : TEvent;
    Res : LongInt;
    SpecNAme : AllStr;
    NewBaz,BeginUpdate:Boolean;
    f : File;
    TM : LongInt;
Begin
 {l:=64;}
 If Not SelectOperation(l) Then Exit;
{
 M[1]:=1;
 M[2]:=1;
 M[3]:=0;
 M[4]:=0;
 M[5]:=0;
 M[6]:=0;
 M[7]:=1;
 Convert7(M);
 BitToWord7(M,L);
 Writeln(l);
 Readln;
}

 WordToBit7(l,M);
 Convert7(M);

 If (M[1]=0)And(M[2]=0)And(M[3]=0)And(M[4]=0)And(M[5]=0)And(M[6]=0)
 And(M[7]=0) Then
  Begin
   {выход если не выбрано ни одной операции}
   Exit;
  End;


{1.сначала диалоговое окно с выбором вида операции
[принять и отправть почту]
  если ничего не надо то выход

2.Проверяем готовность удаленного диска к работе
  FExists(RemoteDit+'dialup.txt')
  если нет то выход

3.Если отправить тогда формируем список файлов
  подлежащих отправке

  a) отправляем все что нужно и на отправленных файлах
     на локальной машине проставляем аттрибут System

4.Если нужно принять почту формирум на удаленной машине
  список файлов, подлежащих получению

  а) копируем все файлы на локальный диск и проставляем
     аттрибут системный


5. Сообщение на экран об окончании операции
   и предупреждение о необходимости выключить удаленной доступ!
}
 If RemoteScript=1 Then
 Begin
  DInfoMsg('Выполняю сценарий подключения...',False);
  RunMailScript;
  NoInfoMsg;
 End;



 If Not FExists1(Path^.Dat.ToRemoteDir+Rek^.Dat.Kod+'\'+'dialup.txt',Res) Then
  Begin
   NoInfoMsgCopy;
   NoInfoMsg;
   MessageBox(^M+#3+'Удаленный диск не готов к работе!'^M+
   #3+'Повторите попытку соединения!'+' Код:'+IntToStr(Res,CKOl),Nil,mfError+mfCAncelButton);
   AddProtocolNoMsg('Удаленный доступ: Удаленный диск не готов к работе!','','');
   Exit;
  End;

{
   If (FExists(Path^.Dat.ToFlagDir+'lockadmp')) Then
    Begin
      NoInfoMsgCopy;
      NoInfoMsg;
      MessageBox(^M+#3'Операция импорта производится на другой рабочей станции!'^M+
         #3+'Попробуйте повторить позже!',Nil,mfError+mfCancelButton);
      Exit;
    End;
}

  Assign(f,Path^.Dat.ToFlagDir+'lockadmp');

  If Not CreatLockPrihod(f) Then
    Begin
      NoInfoMsgCopy;
      NoInfoMsg;
      MessageBox(^M+#3'Операция импорта производится на другой рабочей станции!'^M+
         #3+'Попробуйте повторить позже!',Nil,mfError+mfCancelButton);
      Exit;
    End;

  AddRemoteProtocol('Старт сеанса связи! ','','');

Inp:=0;
InpErr:=0;
Out:=0;
OutErr:=0;


If M[1]=1 Then
Begin
{создаем динамический список файлов подлежащих приему}
R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));
MakeListInFile(P);


If (P^.List^.Count)>0 Then
 Begin
   For l:=0 To P^.List^.Count-1 Do
    Begin
     s:=P^.GetText(l,P^.List^.Count);
     Size:=StrToInt(Copy(s,1+12+1,CIZena));
     s:=Copy(s,1,12);
     DelSpace(S);

{     DInfoMSgShkala(' Принимаю '+Path^.Dat.ToRemoteDir+s+' ...',0,P^.List^.Count-1,l);}

     New(PP,Init);


     Assign(StartF,Path^.Dat.ToRemoteDir+s);
     c:=IOResult;
     Reset(StartF,1);
     c:=IOResult;
      If C=0 Then
      Begin

       Assign(StopF,PathExpImp^.DAt.ToImport[1]+S);
       c:=IOResult;
       Rewrite(StopF,1);
       c:=IOResult;
       If C=0 Then
        Begin
         Close(StopF);
         c:=IOResult;
          If c=0 Then
        Begin
         CurSize:=0;
         While (CurSize<Size) Do
          Begin

DInfoMSgShkalaCopy('Прием '+Path^.Dat.ToRemoteDir+s+
' Принято:'+REalToStr(CurSize / 1024,7,2)+'Кб  из '+
             RealToStr(Size / 1024,7,2)+'Кб ...',0,Size,CurSize);


      Application^.GetEvent(Event);


      If Event.KeYCode=kbEsc Then
       Begin
        If Password(4) Then
        If MessageBox(^M+#3'Прервать операцию приема передачи?',Nil,mfWarning+mfOkCancel)=cmOk Then
         Begin
          Erase(StopF);
          Inc(InpErr);
          c:=IOResult;
          Close(StartF);
          c:=IOResult;
          AddProtocolNoMsg('Удаленный доступ: Прием '+s+' прерван оператором',
	     '','');
          AddRemoteProtocol('Прием '+s+' прерван оператором',
	     '','');
          Break;
         End;
       End;

RestartRead:{метка начала чтения}
           numread:=0;
           c:=ReadFromFileNew(StartF,NumRead,PP);
           If  c<>0 Then
            Begin
       If MessageBox(#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку чтения?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Begin
          System.CLose(StartF);
          c:=IOResult;
          Reset(StartF,1);
          c:=IOResult;
          Seek(StartF,CurSize);
          c:=IOResult;
          If c=0 Then AddRemoteProtocol('Восстановлен прием '+s,'','');

          Goto RestartRead
        End
       Else
        Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка чтения '+s,
	    'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')','');
         Break;{Выход из цикла чтения документа}
         Inc(InpErr);
        End;
            End;{c=0}

             Inc(CurSize,NumRead);

RestartWrite:

           c:=WriteToFileNew(PathExpImp^.DAt.ToImport[1]+S,NumRead,PP,CurSize-NumRead);

         If c<>0 Then
      Begin
       If MessageBox(#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку записи?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Goto RestartWrite
       Else
        Begin
         Inc(InpErr);
         AddProtocolNoMsg('Удаленный доступ: Ошибка записи '+s,
	    'Ошибка записи ( Код: '+IntToStr(c,CKol)+')','');
          Break;
        End;
      End;
          End;{While}
        c:=IOResult;
        Close(StartF);
        c:=IOResult;
       If Not(SetCopyMailAttribute(Path^.Dat.ToRemoteDir+s)) Then
	   Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка установки аттрибута о передаче на удаленной машине '+s,'','');
	   End;
End{закрытие файла}
Else
         Begin
          MessageBox(#3'Ошибка закрытия '+PathExpImp^.DAt.ToImport[1]+S,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;
        End
        Else
         Begin
          MessageBox(#3'Ошибка создания '+PathExpImp^.DAt.ToImport[1]+s,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;
      End
      Else
         Begin
          MessageBox(#3'Ошибка открытия '+Path^.Dat.ToRemoteDir+s,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;
NoInfoMsgCopy;
      Dispose(PP,Done);
      Inc(Inp);
     AddProtocolNoMsg('Удаленный доступ: Прием файла '+s,'','');
     AddRemoteProtocol('Прием файла '+s,'','');
    End;
{    NoInfoMsg;}
 End
 Else
    Begin
     AddProtocolNoMsg('Удаленный доступ: Нет файлов для приема ','','');
     AddRemoteProtocol('Нет файлов для приема ','','');
    End;

Dispose(P,Done);
End;{завершен прием файлов}


 If Not FExists1(Path^.Dat.ToRemoteDir+Rek^.Dat.Kod+'\'+'dialup.txt',Res) Then
  Begin
   UnLockImportPrihod(f);
   NoInfoMsgCopy;
   NoInfoMsg;
   MessageBox(^M+#3+'Удаленный диск не готов к работе!'^M+
   #3+'Повторите попытку соединения!'+' Код:'+IntToStr(Res,CKOl),Nil,mfError+mfCAncelButton);
   AddProtocolNoMsg('Удаленный доступ: Удаленный диск не готов к работе!','','');
   Exit;
  End;



If M[2]=1 Then
Begin
{создаем динамический список файлов подлежащих отправке}
R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));
MakeListOutFile(P);

If (P^.List^.Count)>0 Then
 Begin
   For l:=0 To P^.List^.Count-1 Do
    Begin
     s:=P^.GetText(l,P^.List^.Count);
     Size:=StrToInt(Copy(s,1+12+1,CIZena));
     s:=Copy(s,1,12);
     DelSpace(S);

{     DInfoMSgShkala(' Отправляю '+PathExpImp^.Dat.ToImport[1]+s+' ...',0,P^.List^.Count-1,l);}

     New(PP,Init);

     Assign(StartF,PathExpImp^.Dat.ToImport[1]+s);
     c:=IOResult;
     Reset(StartF,1);
     c:=IOResult;
      If C=0 Then
      Begin

       Assign(StopF,Path^.DAt.ToRemoteDir+S);
       c:=IOResult;
       Rewrite(StopF,1);
       c:=IOResult;
       If C=0 Then
        Begin
         Close(StopF);
         c:=IOResult;
          If c=0 Then
        Begin



         CurSize:=0;
         While (CurSize<Size) Do
          Begin

DInfoMSgShkalaCopy('Передача '+PathExpImp^.Dat.ToImport[1]+s+
' Отправлено:'+REalToStr(CurSize / 1024,7,2)+'Кб  из '+
             RealToStr(Size / 1024,7,2)+'Кб ...',0,Size,CurSize);

      Application^.GetEvent(Event);

      If Event.KeYCode=kbEsc Then
       Begin
        If Password(4) Then
        If MessageBox(^M+#3'Прервать операцию приема передачи?',Nil,mfWarning+mfOkCancel)=cmOk Then
         Begin
          Erase(StopF);
          Inc(OutErr);
          c:=IOResult;
          Close(StartF);
          c:=IOResult;
          AddProtocolNoMsg('Удаленный доступ: Передача '+s+' прервана оператором',
	     '','');
          AddRemoteProtocol('Передача '+s+' прервана оператором',
	     '','');
          Break;
         End;
       End;

RestartRead1:{метка начала чтения}
           numread:=0;
           c:=ReadFromFileNew(StartF,NumRead,PP);
           If  c<>0 Then
            Begin
       If MessageBox(#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку чтения?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Begin
          System.CLose(StartF);
          c:=IOResult;
          Reset(StartF,1);
          c:=IOResult;
          Seek(StartF,CurSize);
          c:=IOResult;
          Goto RestartRead1
        End
       Else
        Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка чтения '+s,
	    'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')','');
         Break;{Выход из цикла чтения документа}
         Inc(OutErr);
        End;
            End;{c=0}

             Inc(CurSize,NumRead);

RestartWrite1:

           c:=WriteToFileNew(Path^.DAt.ToRemoteDir+S,NumRead,PP,CurSize-NumRead);

         If c<>0 Then
      Begin
       If MessageBox(#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку записи?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Goto RestartWrite1
       Else
        Begin
         Inc(OutErr);
         AddRemoteProtocol('Восстановлена передача '+s,'','');
         AddProtocolNoMsg('Удаленный доступ: Ошибка записи '+s,
	    'Ошибка записи ( Код: '+IntToStr(c,CKol)+')','');
          Break;
        End;
      End;

          End;{While}


        c:=IOResult;
        Close(StartF);
        c:=IOResult;

       If Not(SetCopyMailAttribute(PathExpImp^.Dat.ToImport[1]+s)) Then
	   Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка установки аттрибута о передаче на локальной машине '+s,'','');
	   End;

End{закрытие файла}
Else
         Begin
          MessageBox(#3'Ошибка закрытия '+Path^.DAt.ToRemoteDir+S,Nil,mfError+mfCancelButton);
          Inc(OutErr);
         End;

        End
        Else
         Begin
          MessageBox(#3'Ошибка создания '+Path^.DAt.ToRemoteDir+s,Nil,mfError+mfCancelButton);
          Inc(OutErr);
         End;
      End
      Else
         Begin
          MessageBox(#3'Ошибка открытия '+PathExpImp^.Dat.ToImport[1]+s,Nil,mfError+mfCancelButton);
          Inc(OutErr);
         End;

NoInfoMsgCopy;

      Dispose(PP,Done);
      Inc(Out);

     AddProtocolNoMsg('Удаленный доступ: Отправка файла '+s,'','');
     AddRemoteProtocol('Отправка файла '+s,'','');
    End;
{    NoInfoMsg;}
 End
 Else
    Begin
     AddProtocolNoMsg('Удаленный доступ: Нет файлов для отправки ','','');
     AddRemoteProtocol('Нет файлов для отправки ','','');
    End;

Dispose(P,Done);
End;

 If Not FExists1(Path^.Dat.ToRemoteDir+Rek^.Dat.Kod+'\'+'dialup.txt',Res) Then
  Begin
   UnLockImportPrihod(f);
   NoInfoMsgCopy;
   NoInfoMsg;
   MessageBox(^M+#3+'Удаленный диск не готов к работе!'^M+
   #3+'Повторите попытку соединения!'+' Код:'+IntToStr(Res,CKOl),Nil,mfError+mfCAncelButton);
   AddProtocolNoMsg('Удаленный доступ: Удаленный диск не готов к работе!','','');
   Exit;
  End;

{отправка архива mail.* }
If M[4]=1 Then
Begin
{создаем динамический список файлов подлежащих отправке}
R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));
MakeListOutFileTools(P);

If (P^.List^.Count)>0 Then
 Begin
   For l:=0 To P^.List^.Count-1 Do
    Begin
     s:=P^.GetText(l,P^.List^.Count);
     Size:=StrToInt(Copy(s,1+12+1,CIZena));
     s:=Copy(s,1,12);
     DelSpace(S);

{     DInfoMSgShkala(' Отправляю '+PathExpImp^.Dat.ToImport[1]+s+' ...',0,P^.List^.Count-1,l);}

     New(PP,Init);

     Assign(StartF,PathExpImp^.Dat.ToImport[1]+s);
     c:=IOResult;
     Reset(StartF,1);
     c:=IOResult;
      If C=0 Then
      Begin

       Assign(StopF,Path^.DAt.ToRemoteDir+Rek^.DAt.Kod+'\'+S);
       c:=IOResult;
       Rewrite(StopF,1);
       c:=IOResult;
       If C=0 Then
        Begin
         Close(StopF);
         c:=IOResult;
          If c=0 Then
        Begin

         CurSize:=0;
         While (CurSize<Size) Do
          Begin

DInfoMSgShkalaCopy('Передача '+PathExpImp^.Dat.ToImport[1]+s+
' Отправлено:'+REalToStr(CurSize / 1024,7,2)+'Кб  из '+
             RealToStr(Size / 1024,7,2)+'Кб ...',0,Size,CurSize);

      Application^.GetEvent(Event);

      If Event.KeYCode=kbEsc Then
       Begin
        If Password(4) Then
        If MessageBox(^M+#3'Прервать операцию приема передачи?',Nil,mfWarning+mfOkCancel)=cmOk Then
         Begin
          Erase(StopF);
          Inc(OutErr);
          c:=IOResult;
          Close(StartF);
          c:=IOResult;
          AddProtocolNoMsg('Удаленный доступ: Передача '+s+' прервана оператором',
	     '','');
          AddRemoteProtocol('Передача '+s+' прервана оператором',
	     '','');
          Break;
         End;
       End;

RestartRead4:{метка начала чтения}
           numread:=0;
           c:=ReadFromFileNew(StartF,NumRead,PP);
           If  c<>0 Then
            Begin
       If MessageBox(^M+#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку чтения?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Begin
          System.CLose(StartF);
          c:=IOResult;
          Reset(StartF,1);
          c:=IOResult;
          Seek(StartF,CurSize);
          c:=IOResult;
          Goto RestartRead4
        End
       Else
        Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка чтения '+s,
	    'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')','');
         Break;{Выход из цикла чтения документа}
         Inc(OutErr);
        End;
            End;{c=0}

             Inc(CurSize,NumRead);

RestartWrite4:

           c:=WriteToFileNew(Path^.DAt.ToRemoteDir+Rek^.Dat.Kod+'\'+S,NumRead,PP,CurSize-NumRead);

         If c<>0 Then
      Begin
       If MessageBox(#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку записи?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Goto RestartWrite4
       Else
        Begin
         Inc(OutErr);
         AddRemoteProtocol('Восстановлена передача '+s,'','');
         AddProtocolNoMsg('Удаленный доступ: Ошибка записи '+s,
	    'Ошибка записи ( Код: '+IntToStr(c,CKol)+')','');
          Break;
        End;
      End;
          End;{While}

        c:=IOResult;
        Close(StartF);
        c:=IOResult;

       If Not(SetCopyMailAttribute(PathExpImp^.Dat.ToImport[1]+s)) Then
	   Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка установки аттрибута о передаче на локальной машине '+s,'','');
	   End;

End{закрытие файла}
Else
         Begin
          MessageBox(#3'Ошибка закрытия '+Path^.DAt.ToRemoteDir+Rek^.Dat.Kod+'\'+S,Nil,mfError+mfCancelButton);
          Inc(OutErr);
         End;

        End
        Else
         Begin
          MessageBox(#3'Ошибка создания '+Path^.DAt.ToRemoteDir+Rek^.Dat.Kod+'\'+s+' Код: '+IntToStr(c,CKOl),Nil,mfError+
		mfCancelButton);
          Inc(OutErr);
         End;
      End
      Else
         Begin
          MessageBox(#3'Ошибка открытия '+PathExpImp^.Dat.ToImport[1]+s,Nil,mfError+mfCancelButton);
          Inc(OutErr);
         End;

NoInfoMsgCopy;

      Dispose(PP,Done);
      Inc(Out);

     AddProtocolNoMsg('Удаленный доступ: Отправка файла '+s,'','');
     AddRemoteProtocol('Отправка файла '+s,'','');
    End;
{    NoInfoMsg;}
 End
 Else
    Begin
     AddProtocolNoMsg('Удаленный доступ: Нет файлов для отправки служебной почты','','');
     AddRemoteProtocol('Нет файлов для отправки служебной почты','','');
    End;

Dispose(P,Done);
End;

 If Not FExists1(Path^.Dat.ToRemoteDir+Rek^.Dat.Kod+'\'+'dialup.txt',Res) Then
  Begin
   UnLockImportPrihod(f);
   NoInfoMsgCopy;
   NoInfoMsg;
   MessageBox(^M+#3+'Удаленный диск не готов к работе!'^M+
   #3+'Повторите попытку соединения!'+' Код:'+IntToStr(Res,CKOl),Nil,mfError+mfCAncelButton);
   AddProtocolNoMsg('Удаленный доступ: Удаленный диск не готов к работе!','','');
   Exit;
  End;

{отправка отчетов архива }
If M[5]=1 Then
Begin
{создаем динамический список файлов подлежащих отправке}
R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));
MakeListOutFileDAyReport(P);

If (P^.List^.Count)>0 Then
 Begin
   For l:=0 To P^.List^.Count-1 Do
    Begin
     s:=P^.GetText(l,P^.List^.Count);
     Size:=StrToInt(Copy(s,1+12+1,CIZena));
     s:=Copy(s,1,12);
     DelSpace(S);

     {DInfoMsgShkala(' Отправляю '+PathExpImp^.Dat.ToImport[1]+s+' ...',0,P^.List^.Count-1,l);}
     SpecNAme:='jet.'+IntToStr(StrToInt(Copy(s,Pos('.',s)+1,3)),CMantissa);{формируем фиктивное имя}

     New(PP,Init);


     Assign(StartF,PathExpImp^.Dat.ToImport[1]+s);
     c:=IOResult;
     Reset(StartF,1);
     c:=IOResult;
      If C=0 Then
      Begin

       Assign(StopF,Path^.DAt.ToRemoteDir+SpecName);
       c:=IOResult;
       Rewrite(StopF,1);
       c:=IOResult;
       If C=0 Then
        Begin
         Close(StopF);
         c:=IOResult;
          If c=0 Then
        Begin

         CurSize:=0;
         While (CurSize<Size) Do
          Begin

DInfoMSgShkalaCopy('Передача '+PathExpImp^.Dat.ToImport[1]+s+
' Отправлено:'+REalToStr(CurSize / 1024,7,2)+'Кб  из '+
             RealToStr(Size / 1024,7,2)+'Кб ...',0,Size,CurSize);

      Application^.GetEvent(Event);

      If Event.KeYCode=kbEsc Then
       Begin
        If Password(4) Then
        If MessageBox(^M+#3'Прервать операцию приема передачи?',Nil,mfWarning+mfOkCancel)=cmOk Then
         Begin
          Erase(StopF);
          Inc(OutErr);
          c:=IOResult;
          Close(StartF);
          c:=IOResult;
          AddProtocolNoMsg('Удаленный доступ: Передача '+s+' прервана оператором',
	     '','');
          AddRemoteProtocol('Передача '+s+' прервана оператором',
	     '','');
          Break;
         End;
       End;

RestartRead2:{метка начала чтения}
           numread:=0;
           c:=ReadFromFileNew(StartF,NumRead,PP);
           If  c<>0 Then
            Begin
       If MessageBox(^M+#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку чтения?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Begin
          System.CLose(StartF);
          c:=IOResult;
          Reset(StartF,1);
          c:=IOResult;
          Seek(StartF,CurSize);
          c:=IOResult;
          Goto RestartRead2
        End
       Else
        Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка чтения '+s,
	    'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')','');
         Break;{Выход из цикла чтения документа}
         Inc(OutErr);
        End;
            End;{c=0}

             Inc(CurSize,NumRead);

RestartWrite2:
           c:=WriteToFileNew(Path^.DAt.ToRemoteDir+SpecName,NumRead,PP,CurSize-NumRead);
         If c<>0 Then
      Begin
       If MessageBox(#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку записи?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Goto RestartWrite2
       Else
        Begin
         Inc(OutErr);
         AddRemoteProtocol('Восстановлена передача '+s,'','');
         AddProtocolNoMsg('Удаленный доступ: Ошибка записи '+s,
	    'Ошибка записи ( Код: '+IntToStr(c,CKol)+')','');
          Break;
        End;
      End;

          End;{While}


        c:=IOResult;
        Close(StartF);
        c:=IOResult;

       If CurSize>=Size Then
       If Not(SetCopyMailAttribute(PathExpImp^.Dat.ToImport[1]+s)) Then
	   Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка установки аттрибута о передаче на локальной машине '+s,'','');
	   End;

End{закрытие файла}
Else
         Begin
          MessageBox(#3'Ошибка закрытия '+Path^.DAt.ToRemoteDir+specName,Nil,mfError+mfCancelButton);
          Inc(OutErr);
         End;

        End
        Else
         Begin
          MessageBox(#3'Ошибка создания '+Path^.DAt.ToRemoteDir+specName+' Код: '+IntToStr(c,CKOl),Nil,mfError+mfCancelButton);
          Inc(OutErr);
         End;
      End
      Else
         Begin
          MessageBox(#3'Ошибка открытия '+PathExpImp^.Dat.ToImport[1]+s,Nil,mfError+mfCancelButton);
          Inc(OutErr);
         End;
NoInfoMsgCopy;

      Dispose(PP,Done);
      Inc(Out);


     AddProtocolNoMsg('Удаленный доступ: Отправка файла '+s,'','');
     AddRemoteProtocol('Отправка файла '+s,'','');

     Assign(StopF,Path^.DAt.ToRemoteDir+SpecName);
     Io:=IOResult;
     Rename(StopF,Path^.DAt.ToRemoteDir+s);
     Io:=IOResult;

     If IO <> 0 Then
      Begin
       MessageBox(#3'Ошибка перенаименования '+Path^.DAt.ToRemoteDir+s+' (Код:'+IntToStr(IO,4)+')',Nil,mfError+mfCancelButton);
       Inc(OutErr);
       AddProtocolNoMsg('Удаленный доступ: ошибка перенаименования '+Path^.DAt.ToRemoteDir+s,
	  ' (Код:'+IntToStr(IO,4)+')','');
      End;

    End;
    {NoInfoMsg;}
 End
 Else
    Begin
     AddProtocolNoMsg('Удаленный доступ: Нет файлов для отправки ','','');
     AddRemoteProtocol('Нет файлов для отправки ','','');
    End;

Dispose(P,Done);

End;



 If Not FExists1(Path^.Dat.ToRemoteDir+Rek^.Dat.Kod+'\'+'dialup.txt',Res) Then
  Begin
   UnLockImportPrihod(f);
   NoInfoMsgCopy;
   NoInfoMsg;
   MessageBox(^M+#3+'Удаленный диск не готов к работе!'^M+
   #3+'Повторите попытку соединения!'+' Код:'+IntToStr(Res,CKOl),Nil,mfError+mfCAncelButton);
   AddProtocolNoMsg('Удаленный доступ: Удаленный диск не готов к работе!','','');
   Exit;
  End;

BeginUpdate:=False;
If M[3]=1 Then BeginUpDAte:=True
Else
 Begin
  R.Assign(0,0,0,0);
  P := New(PBox, Init(R, 1, Nil));
  P^.NewList(New(PTextCollection, Init(0,1)));
  MakeListInFileFromUpDate(P);
  If (P^.List^.Count)>0 Then
   Begin
    If MessageBox(^M+WarningUpDAte^,Nil,mfConfirmation+mfOkCAncel)=cmOk
    Then BeginUpDAte:=True;
    If BeginUpDAte Then MessageBox(^M+WarningToProgramer^,Nil,mfWarning+mfCAncelButton);
   End;
  Dispose(P,Done);
 End;

If BeginUpDAte Then
Begin
{создаем динамический список файлов подлежащих приему}
R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));
MakeListInFileFromUpDate(P);


If (P^.List^.Count)>0 Then
 Begin
   For l:=0 To P^.List^.Count-1 Do
    Begin
     s:=P^.GetText(l,P^.List^.Count);
     Size:=StrToInt(Copy(s,1+12+1,CIZena));
     s:=Copy(s,1,12);
     DelSpace(S);

     {DInfoMSgShkala(' Принимаю '+Path^.Dat.ToRemoteDir+Rek^.Dat.Kod+'\'+s+' ...',0,P^.List^.Count-1,l);}

     New(PP,Init);

     Assign(StartF,Path^.Dat.ToRemoteDir+Rek^.Dat.Kod+'\'+s);
     c:=IOResult;
     Reset(StartF,1);
     c:=IOResult;
     If C=0 Then
      Begin

       Assign(StopF,PathExpImp^.DAt.ToImport[1]+S);
       c:=IOResult;
       Rewrite(StopF,1);
       c:=IOResult;
       If C=0 Then
        Begin
         Close(StopF);
         c:=IOResult;
          If c=0 Then
        Begin

         CurSize:=0;
         While (CurSize<Size) Do
          Begin

DInfoMSgShkalaCopy('Прием '+Path^.Dat.ToRemoteDir+Rek^.DAt.Kod+'\'+s+
' Принято:'+REalToStr(CurSize / 1024,7,2)+'Кб  из '+
RealToStr(Size / 1024,7,2)+'Кб ...',0,Size,CurSize);


      Application^.GetEvent(Event);


      If Event.KeYCode=kbEsc Then
       Begin
        If Password(4) Then
        If MessageBox(^M+#3'Прервать операцию приема передачи?',Nil,mfWarning+mfOkCancel)=cmOk Then
         Begin
          Erase(StopF);
          Inc(InpErr);
          c:=IOResult;
          Close(StartF);
          c:=IOResult;
          AddProtocolNoMsg('Удаленный доступ: Прием '+s+' прерван оператором',
	     '','');
          AddRemoteProtocol('Прием '+s+' прерван оператором',
	     '','');
          Break;
         End;
       End;



RestartRead3:{метка начала чтения}
           numread:=0;
           c:=ReadFromFileNew(StartF,NumRead,PP);
           If  c<>0 Then
            Begin
       If MessageBox(#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку чтения?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Begin
          System.CLose(StartF);
          c:=IOResult;
          Reset(StartF,1);
          c:=IOResult;
          Seek(StartF,CurSize);
          c:=IOResult;
          If c=0 Then AddRemoteProtocol('Восстановлен прием '+s,'','');

          Goto RestartRead3
        End
       Else
        Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка чтения '+s,
	    'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')','');
         Break;{Выход из цикла чтения документа}
         Inc(InpErr);
        End;
            End;{c=0}
            Inc(CurSize,NumRead);

RestartWrite3:
           c:=WriteToFileNew(PathExpImp^.DAt.ToImport[1]+S,NumRead,PP,CurSize-NumRead);
         If c<>0 Then
      Begin
       If MessageBox(#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку записи?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Goto RestartWrite3
       Else
        Begin
         Inc(InpErr);
         AddProtocolNoMsg('Удаленный доступ: Ошибка записи '+s,
	    'Ошибка записи ( Код: '+IntToStr(c,CKol)+')','');
          Break;
        End;
      End;

          End;{While}


        c:=IOResult;
        Close(StartF);
        c:=IOResult;

       If Not(SetCopyMailAttribute(Path^.Dat.ToRemoteDir+Rek^.DAt.Kod+'\'+s)) Then
	   Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка установки аттрибута о передаче на удаленной машине '+s,'','');
	   End;

End{закрытие файла}
Else
         Begin
          MessageBox(#3'Ошибка закрытия '+PathExpImp^.DAt.ToImport[1]+S,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;

        End
        Else
         Begin
          MessageBox(#3'Ошибка создания '+PathExpImp^.DAt.ToImport[1]+s,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;
      End
      Else
         Begin
          MessageBox(#3'Ошибка открытия '+Path^.Dat.ToRemoteDir+Rek^.Dat.Kod+'\'+s,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;

NoInfoMsgCopy;

      Dispose(PP,Done);
      Inc(Inp);

     AddProtocolNoMsg('Удаленный доступ: Прием файла '+s,'','');
     AddRemoteProtocol('Прием файла '+s,'','');
    End;
{    NoInfoMsg;}
 End
 Else
    Begin
     AddProtocolNoMsg('Удаленный доступ: Нет файлов для приема обновления ','','');
     AddRemoteProtocol('Нет файлов для приема обновления ','','');
    End;
Dispose(P,Done);
End;{завершен прием файлов}


 If Not FExists1(Path^.Dat.ToRemoteDir+Rek^.Dat.Kod+'\'+'dialup.txt',Res) Then
  Begin
   UnLockImportPrihod(f);
   NoInfoMsgCopy;
   NoInfoMsg;
   MessageBox(^M+#3+'Удаленный диск не готов к работе!'^M+
   #3+'Повторите попытку соединения!'+' Код:'+IntToStr(Res,CKOl),Nil,mfError+mfCAncelButton);
   AddProtocolNoMsg('Удаленный доступ: Удаленный диск не готов к работе!','','');
   Exit;
  End;


If M[6]=1 Then
Begin
{создаем динамический список файлов подлежащих приему}
R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));
MakeListInFilePrice(P);


If (P^.List^.Count)>0 Then
 Begin
   For l:=0 To P^.List^.Count-1 Do
    Begin
     s:=P^.GetText(l,P^.List^.Count);
     Size:=StrToInt(Copy(s,1+12+1,CIZena));
     s:=Copy(s,1,12);
     DelSpace(S);

     {DInfoMSgShkala(' Принимаю '+Path^.Dat.ToRemoteDir+s+' ...',0,P^.List^.Count-1,l);}

     New(PP,Init);


     Assign(StartF,Path^.Dat.ToRemoteDir+s);
     c:=IOResult;
     Reset(StartF,1);
     c:=IOResult;
      If C=0 Then
      Begin

       Assign(StopF,PathExpImp^.DAt.ToImport[1]+S);
       c:=IOResult;
       Rewrite(StopF,1);
       c:=IOResult;
       If C=0 Then
        Begin
         Close(StopF);
         c:=IOResult;
          If c=0 Then
        Begin

         CurSize:=0;
         While (CurSize<Size) Do
          Begin

DInfoMSgShkalaCopy('Прием '+Path^.Dat.ToRemoteDir+s+
' Принято:'+REalToStr(CurSize / 1024,7,2)+'Кб  из '+
             RealToStr(Size / 1024,7,2)+'Кб ...',0,Size,CurSize);

      Application^.GetEvent(Event);

      If Event.KeYCode=kbEsc Then
       Begin
        If Password(4) Then
        If MessageBox(^M+#3'Прервать операцию приема передачи?',Nil,mfWarning+mfOkCancel)=cmOk Then
         Begin
          Erase(StopF);
          Inc(InpErr);
          c:=IOResult;
          Close(StartF);
          c:=IOResult;
          AddProtocolNoMsg('Удаленный доступ: Прием '+s+' прерван оператором',
	     '','');
          AddRemoteProtocol('Прием '+s+' прерван оператором',
	     '','');
          Break;
         End;
       End;



RestartRead5:{метка начала чтения}
           numread:=0;
           c:=ReadFromFileNew(StartF,NumRead,PP);
           If  c<>0 Then
            Begin
       If MessageBox(#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку чтения?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Begin
          System.CLose(StartF);
          c:=IOResult;
          Reset(StartF,1);
          c:=IOResult;
          Seek(StartF,CurSize);
          c:=IOResult;
          If c=0 Then AddRemoteProtocol('Восстановлен прием '+s,'','');

          Goto RestartRead5
        End
       Else
        Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка чтения '+s,
	    'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')','');
         Break;{Выход из цикла чтения документа}
         Inc(InpErr);
        End;
            End;{c=0}
             Inc(CurSize,NumRead);

RestartWrite5:

           c:=WriteToFileNew(PathExpImp^.DAt.ToImport[1]+S,NumRead,PP,CurSize-NumRead);
         If c<>0 Then
      Begin
       If MessageBox(#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку записи?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Goto RestartWrite5
       Else
        Begin
         Inc(InpErr);
         AddProtocolNoMsg('Удаленный доступ: Ошибка записи '+s,
	    'Ошибка записи ( Код: '+IntToStr(c,CKol)+')','');
          Break;
        End;
      End;

          End;{While}


        c:=IOResult;
        Close(StartF);
        c:=IOResult;

       If Not(SetCopyMailAttribute(Path^.Dat.ToRemoteDir+s)) Then
	   Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка установки аттрибута о передаче на удаленной машине '+s,'','');
	   End;

End{закрытие файла}
Else
         Begin
          MessageBox(#3'Ошибка закрытия '+PathExpImp^.DAt.ToImport[1]+S,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;

        End
        Else
         Begin
          MessageBox(#3'Ошибка создания '+PathExpImp^.DAt.ToImport[1]+s,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;
      End
      Else
         Begin
          MessageBox(#3'Ошибка открытия '+Path^.Dat.ToRemoteDir+s,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;

NoInfoMsgCopy;

      Dispose(PP,Done);
      Inc(Inp);

     AddProtocolNoMsg('Удаленный доступ: Прием прайс-листа '+s,'','');
     AddRemoteProtocol('Прием прайс-листа '+s,'','');
    End;
{    NoInfoMsg;}
 End
 Else
    Begin
     AddProtocolNoMsg('Удаленный доступ: Нет прайс-листа для приема ','','');
     AddRemoteProtocol('Нет прайс-листа для приема ','','');
    End;

Dispose(P,Done);
End;{завершен прием файлов}

{участок реплицирующий на справочники клиентов и прочую херь}

 If Not FExists1(Path^.Dat.ToRemoteDir+Rek^.Dat.Kod+'\'+'dialup.txt',Res) Then
  Begin
   UnLockImportPrihod(f);
   NoInfoMsgCopy;
   NoInfoMsg;
   MessageBox(^M+#3+'Удаленный диск не готов к работе!'^M+
   #3+'Повторите попытку соединения!'+' Код:'+IntToStr(Res,CKOl),Nil,mfError+mfCAncelButton);
   AddProtocolNoMsg('Удаленный доступ: Удаленный диск не готов к работе!','','');
   Exit;
  End;



{создаем динамический список файлов подлежащих приему}
R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));

  MakeListInFileBase(ClientPrefix,P);
  MakeListInFileBase(MakePrefix,P);
  MakeListInFileBase(BarterPrefix,P);
  MakeListInFileBase(SkladPrefix,P);
  MakeListInFileBase(AgentPrefix,P);
  MakeListInFileBase(EkspeditorPrefix,P);
  MakeListInFileBase(GroupPrefix,P);
  MakeListInFileBase(RegionPrefix,P);
  MakeListInFileBase(NGTDPrefix,P);
  MakeListInFileBase(MarkaPrefix,P);
  MakeListInFileBase(SMarkaPrefix,P);
  MakeListInFileBase(LandsPrefix,P);
  MakeListInFileBase(FirmaPrefix,P);
  MakeListInFileBase(BankPrefix,P);
  MakeListInFileBase(RoutePrefix,P);
  MakeListInFileBase(MeraPrefix,P);
  MakeListInFileBase(KSertifPrefix,P);
  MakeListInFileBase(ExpertPrefix,P);
  MakeListInFileBase(ClassPrefix,P);
  MakeListInFileBase(KassaPrefix,P);
  MakeListInFileBase(PersonalPrefix,P);


If (P^.List^.Count)>0 Then
 Begin
   For l:=0 To P^.List^.Count-1 Do
    Begin
     s:=P^.GetText(l,P^.List^.Count);
     Size:=StrToInt(Copy(s,1+12+1,CIZena));
     s:=Copy(s,1,12);
     DelSpace(S);

     {DInfoMSgShkala(' Принимаю '+Path^.Dat.ToRemoteDir+Rek^.Dat.Kod+'\'+s+' ...',0,P^.List^.Count-1,l);}

     New(PP,Init);

     Assign(StartF,Path^.Dat.ToRemoteDir+s);
     c:=IOResult;
     Reset(StartF,1);
     c:=IOResult;
     If C=0 Then
      Begin

       Assign(StopF,PathExpImp^.DAt.ToImport[1]+S);
       c:=IOResult;
       Rewrite(StopF,1);
       c:=IOResult;
       If C=0 Then
        Begin
         Close(StopF);
         c:=IOResult;
          If c=0 Then
        Begin
         CurSize:=0;
         While (CurSize<Size) Do
          Begin
DInfoMSgShkalaCopy('Прием '+Path^.Dat.ToRemoteDir+s+
' Принято:'+REalToStr(CurSize / 1024,7,2)+'Кб  из '+
RealToStr(Size / 1024,7,2)+'Кб ...',0,Size,CurSize);


      Application^.GetEvent(Event);


      If Event.KeYCode=kbEsc Then
       Begin
        If Password(4) Then
        If MessageBox(^M+#3'Прервать операцию приема-передачи?',Nil,mfWarning+mfOkCancel)=cmOk Then
         Begin
          Erase(StopF);
          Inc(InpErr);
          c:=IOResult;
          Close(StartF);
          c:=IOResult;
          AddProtocolNoMsg('Удаленный доступ: Прием '+s+' прерван оператором',
	     '','');
          AddRemoteProtocol('Прием '+s+' прерван оператором',
	     '','');
          Break;
         End;
       End;



RestartRead7:{метка начала чтения}
           numread:=0;
           c:=ReadFromFileNew(StartF,NumRead,PP);
           If  c<>0 Then
            Begin
       If MessageBox(#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку чтения?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Begin
          System.Close(StartF);
          c:=IOResult;
          Reset(StartF,1);
          c:=IOResult;
          Seek(StartF,CurSize);
          c:=IOResult;
          If c=0 Then AddRemoteProtocol('Восстановлен прием '+s,'','');
          Goto RestartRead7
        End
       Else
        Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка чтения '+s,
	    'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')','');
         Break;{Выход из цикла чтения документа}
         Inc(InpErr);
        End;
            End;{c=0}

             Inc(CurSize,NumRead);

RestartWrite7:

           c:=WriteToFileNew(PathExpImp^.DAt.ToImport[1]+S,NumRead,PP,CurSize-NumRead);

         If c<>0 Then
      Begin
       If MessageBox(#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку записи?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Goto RestartWrite7
       Else
        Begin
         Inc(InpErr);
         AddProtocolNoMsg('Удаленный доступ: Ошибка записи '+s,
	    'Ошибка записи ( Код: '+IntToStr(c,CKol)+')','');
          Break;
        End;
      End;

          End;{While}


        c:=IOResult;
        Close(StartF);
        c:=IOResult;

       If Not(SetCopyMailAttribute(Path^.Dat.ToRemoteDir+s)) Then
	   Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка установки аттрибута о передаче на удаленной машине '+s,'','');
	   End;

End{закрытие файла}
Else
         Begin
          MessageBox(#3'Ошибка закрытия '+PathExpImp^.DAt.ToImport[1]+S,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;

        End
        Else
         Begin
          MessageBox(#3'Ошибка создания '+PathExpImp^.DAt.ToImport[1]+s,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;
      End
      Else
         Begin
          MessageBox(#3'Ошибка открытия '+Path^.Dat.ToRemoteDir+s,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;

NoInfoMsgCopy;

      Dispose(PP,Done);
      Inc(Inp);

     AddProtocolNoMsg('Удаленный доступ: Прием файла '+s,'','');
     AddRemoteProtocol('Прием файла '+s,'','');
    End;
{    NoInfoMsg;}
 End
 Else
    Begin
     AddProtocolNoMsg('Удаленный доступ: Нет файлов для приема обновления ','','');
     AddRemoteProtocol('Нет файлов для приема обновления ','','');
    End;

Dispose(P,Done);

{вставить код заносящий изменения в базы}
ScanCatolgFromUpDAteBase;

{завершен прием файлов}

{создаем динамический список файлов подлежащих приему}
R.Assign(0,0,0,0);
P := New(PBox, Init(R, 1, Nil));
P^.NewList(New(PTextCollection, Init(0,1)));
TM:=0;
MakeListInFilePassword(p,TM);
NewBaz:=False;

If (P^.List^.Count)>0 Then
 Begin
   For l:=0 To P^.List^.Count-1 Do
    Begin
     s:=P^.GetText(l,P^.List^.Count);
     Size:=StrToInt(Copy(s,1+12+1,CIZena));
     s:=Copy(s,1,12);
     DelSpace(S);
{     DInfoMSgShkala(' Принимаю '+Path^.Dat.ToRemoteDir+s+' ...',0,P^.List^.Count-1,l);}
     New(PP,Init);
     Assign(StartF,Path^.Dat.ToRemoteDir+s);
     c:=IOResult;
     Reset(StartF,1);
     c:=IOResult;
      If C=0 Then
      Begin
       Assign(StopF,PathExpImp^.DAt.ToImport[1]+S);
       c:=IOResult;
       Rewrite(StopF,1);
       c:=IOResult;
       If C=0 Then
        Begin
         Close(StopF);
         c:=IOResult;
          If c=0 Then
        Begin



         CurSize:=0;
         While (CurSize<Size) Do
          Begin

DInfoMSgShkalaCopy('Прием '+Path^.Dat.ToRemoteDir+s+
' Принято:'+REalToStr(CurSize / 1024,7,2)+'Кб  из '+
             RealToStr(Size / 1024,7,2)+'Кб ...',0,Size,CurSize);


      Application^.GetEvent(Event);


      If Event.KeYCode=kbEsc Then
       Begin
        If Password(4) Then
        If MessageBox(^M+#3'Прервать операцию приема?',Nil,mfWarning+mfOkCancel)=cmOk Then
         Begin
          Erase(StopF);
          Inc(InpErr);
          c:=IOResult;
          Close(StartF);
          c:=IOResult;
          AddProtocolNoMsg('Удаленный доступ: Прием '+s+' прерван оператором',
	     '','');
          AddRemoteProtocol('Прием '+s+' прерван оператором',
	     '','');
          Break;
         End;
       End;



RestartRead6:{метка начала чтения}
           numread:=0;
           c:=ReadFromFileNew(StartF,NumRead,PP);
           If  c<>0 Then
            Begin
       If MessageBox(#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку чтения?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Begin
          System.CLose(StartF);
          c:=IOResult;
          Reset(StartF,1);
          c:=IOResult;
          Seek(StartF,CurSize);
          c:=IOResult;
          If c=0 Then AddRemoteProtocol('Восстановлен прием '+s,'','');
          Goto RestartRead6
        End
       Else
        Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка чтения '+s,
	    'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')','');
         Break;{Выход из цикла чтения документа}
         Inc(InpErr);
        End;
            End;{c=0}

             Inc(CurSize,NumRead);

RestartWrite6:

           c:=WriteToFileNew(PathExpImp^.DAt.ToImport[1]+S,NumRead,PP,CurSize-NumRead);

         If c<>0 Then
      Begin
       If MessageBox(#3'Ошибка чтения ( Код: '+IntToStr(c,CKol)+')'^M+
	  #3+'Повторить попытку записи?',Nil,mfWarning+mfOkCancel)=cmOk Then
        Goto RestartWrite6
       Else
        Begin
         Inc(InpErr);
         AddProtocolNoMsg('Удаленный доступ: Ошибка записи '+s,
	    'Ошибка записи ( Код: '+IntToStr(c,CKol)+')','');
          Break;
        End;
      End;

          End;{While}


        c:=IOResult;
        Close(StartF);
        c:=IOResult;


       If Not(SetCopyMailTime(PathExpImp^.DAt.ToImport[1]+S,TM)) Then
	   Begin
         AddProtocolNoMsg('Удаленный доступ: Ошибка установки аттрибута о передаче на удаленной машине '+s,'','');
	   End;

End{закрытие файла}
Else
         Begin
          MessageBox(#3'Ошибка закрытия '+PathExpImp^.DAt.ToImport[1]+S,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;

        End
        Else
         Begin
          MessageBox(#3'Ошибка создания '+PathExpImp^.DAt.ToImport[1]+s,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;
      End
      Else
         Begin
          MessageBox(#3'Ошибка открытия '+Path^.Dat.ToRemoteDir+s,Nil,mfError+mfCancelButton);
          Inc(InpErr);
         End;

NoInfoMsgCopy;

      Dispose(PP,Done);
      Inc(Inp);

     AddProtocolNoMsg('Удаленный доступ: Прием базы паролей '+s,'','');
     AddRemoteProtocol('Прием базы паролей '+s,'','');
     NewBaz:=True;
    End;
{    NoInfoMsg;}
 End
 Else
    Begin
     AddProtocolNoMsg('Удаленный доступ: Нет обновлений базы паролей для приема ','','');
     AddRemoteProtocol('Нет базы паролей для приема ','','');
    End;

Dispose(P,Done);
{конец репликаций на складах базы паролей}

AddRemoteProtocol('Завершение сеанса связи! ','','');

UnLockImportPrihod(f);

MessageBox(#3+'Операция успешно завершена!'^M^M+
'   Всего принято: '+IntToStr(Inp,CLitr)+',  Ошибок: '+IntToStr(InpErr,CLitr)+^M+
'Всего отправлено: '+IntToStr(Out,CLitr)+',  Ошибок: '+IntToStr(OutErr,CLitr),Nil,mfInformation+mfCAncelButton);

If NewBaz Then
Begin
 CopyNewPassword;
End;

End;


Function TestingDate(S:SearchRec):Boolean;
Var SY,SD,SM : ArtikulStr;
    NewDate : AllStr;
    D : DAteTime;
Begin
 TestingDate:=False;
   With S Do
   Begin
    UnpackTime(Time,D);
    SY:=Copy(LeadingZero(D.Year),3,2);
    SM:=LeadingZero(D.Month);
    SD:=LeadingZero(D.Day);
    NewDAte:=SD+'-'+SM+'-'+SY;
    If (((DateStringToDate(DateMask,FDate)-DateStringToDAte(DateMask,NewDate))) >= 7) Then
     Begin
      TestingDate:=True;
     End;
   End;
End;


Function TestNameFromRP(s:AllStr):Boolean;
Var ResStr:ArtikulStr;
    l : LongInt;
Begin
TestNameFromRP:=False;
ReSStr[0]:=#0;

ResStr:=Copy(S,8,1)+Copy(s,10,1);

If Not(ResStr='00') Then
 Begin
  TestNameFromRP:=True;
 End
 Else TestNameFromRP:=False;


ResStr:=Copy(S,8,1)+Copy(s,10,1);

If Not(StrToInt(ResStr) in [0,20,30,40,50,60,70,80,90]) Then
 Begin
  TestNameFromRP:=True;
 End
 Else TestNameFromRP:=False;


if (s[10] in ['k','K','p','P','d','D']) Then
 Begin
  TestNameFromRP:=False;
 End;

End;



Procedure CalcTrashAndErase;
Var F : File;
    s : String;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
SDoc,SDate,STime : TDAteString;
    Pr : ArtikulStr;
    c : Word;
    j : Word;
Begin
If DisableControlTulaSpirt=1 Then Exit;

DInfoMsg('Проверяю каталоги экспорта/импорта...',False);
R.Assign(0, 0, 0, 0);
PrhNaklList := New(PBox, Init(R, 1, Nil));
PrhNaklList^.NewList(New(PTextCollection, Init(0,1)));

For c:=1 To 23 {максимальное количество почтовых тематик} Do
Begin
 Case c Of
  1:Pr:=PrihodPrefix;{приходы}
  2:Pr:=PereozenkaPrefix;{переоценки}
  3:Pr:=ClientPrefix;{клиентский справочник}
  4:Pr:=MakePrefix;  {префикс поставщиков}
  5:Pr:=BarterPrefix; {префикс взаимозачетников}
  6:Pr:=AgentPrefix;  {префикс агентов}
  7:Pr:=SkladPrefix;  {префикс складского справочника}
  8:Pr:=EkspeditorPrefix;{префикс справочника экспедиторов}
  9:Pr:=GroupPrefix; {префикс справочника групп}
 10:Pr:=RegionPrefix;{префикс справочника регионов}
 11:Pr:=NGTDPrefix;{префикс справочника гтд}
 12:Pr:=MarkaPrefix;{префикс справочника акцизных марок}
 13:Pr:=SMarkaPrefix;{префикс справочника спец марок}
 14:Pr:=LandsPrefix;{префикс справочника стран}
 15:Pr:=FIRMAPrefix;{префикс справочника фирм}
 16:Pr:=ClassPrefix;{префикс справочника классов по бухгалтерии}
 17:Pr:=BankPrefix;{префикс справочника банков}
 18:Pr:=RoutePrefix;{префикс справочника маршрутов}
 19:Pr:=MeraPrefix;{префикс справочника единиц измерения}
 20:Pr:=KsertifPrefix;{префикс справочника органов сертификации}
 21:Pr:=ExpertPrefix;{префикс справочника экспертных заключений}
 22:Pr:=KassaPrefix;{префикс справочника кассовых операций}
 23:Pr:=PersonalPrefix;{префикс справочника персонала}
 Else;
 End;

 {входящие сообщения}
 FindFirst(PathExpImp^.Dat.ToImport[1]+Pr+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
  If TestNameFromRP(DirInfo.Name) Then
  Begin
    If TestingDate(DirInfo) Then
    Begin
     s:=PathExpImp^.Dat.ToImport[1]+DirInfo.Name;
     PrhNaklList^.List^.Insert(NewStr(s));
     PrhNaklList^.SetRange(PrhNaklList^.List^.Count);
    End;
  End;{TestNameFromRP}
   FindNext(DirInfo);
 end;{While}

 {исходящие сообщения}
 FindFirst(PathExpImp^.Dat.ToExport[1]+Pr+'*'+Rek^.Dat.Kod[3]+'.'+Rek^.Dat.Kod[4]+'*', AnyFile, DirInfo);
 while DosError = 0 do
 begin
  If TestNameFromRP(DirInfo.Name) Then
  Begin
    If TestingDate{AndSend}(DirInfo) Then
    Begin
     s:=PathExpImp^.Dat.ToExport[1]+DirInfo.Name;
     PrhNaklList^.List^.Insert(NewStr(s));
     PrhNaklList^.SetRange(PrhNaklList^.List^.Count);
    End;
  End;{TestNameFromRP}
   FindNext(DirInfo);
 end;{While}
End;{For  по префиксам}

NoInfoMsg;

If PrhNaklList^.List^.Count>0 Then
 Begin
  For c:=0 To PrhNaklList^.List^.Count-1 Do
   Begin
    DInfoMSgShkala('Выполняется автоочистка '+Formats(IntToStr(c+1,CKol),CKol)+' из '+
    IntToStr(PrhNaklList^.List^.Count-1,CKol)+' ...'
    ,0,PrhNaklList^.List^.Count-1,c);
    s:=PrhNaklList^.GetText(c,PrhNaklList^.List^.Count);
    Assign(f,s);
    j:=IOResult;
    Erase(f);
    j:=IOResult;
   End;
 End;
Dispose(PrhNaklList,Done);

NoInfoMsg;

End;




function TestTMailCatalog(s:String): boolean;
var
 DirInfo: SearchRec;
begin
 TestTMailCatalog:=false;
 FindFirst(s+'*.*', Archive, DirInfo);
 if DosError = 0 then TestTMailCatalog:=true;
end;



Begin
MasStatusMail[1]:=0;
MasStatusMail[2]:=1;
Convert2(MasStatusMail);
BitToWord2(MasStatusMail,StatusMail);
End.
