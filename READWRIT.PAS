unit ReadWrit;

INTERFACE

Uses Glob,ServStr,MSGBox;

function ReadFromFile(FName:string;SizeOfBuf:word;Var Buf):boolean;
function WriteToFile(FName:string;SizeOfBuf:word;Var Buf):boolean;

IMPLEMENTATION



function ReadFromFile(FName:string;SizeOfBuf:word;Var Buf):boolean;
Var FromF:File;
    i,NumRead: word;
Begin
  ReadFromFile:= false;
  Assign(FromF, FName);
  i:=IOResult;
  Reset(FromF, 1);
  i:=IOResult;
  if i<>0 then
   begin
    MessageBox(^M+#3'Не могу открыть файл '+FNAme+'. Код:'+IntToStr(i:CKol),nil,mfError+mfCancelButton);
    exit;
   end;
  i:=IOResult;
  BlockRead(FromF, Buf, SizeOfBuf, NumRead);
  i:=IOResult;
  if i<>0 then
     begin
      MessageBox(^M+#3'Ошибка чтения! '+FNAme+'. Код:'+IntToStr(i:CKol),nil,mfError+mfCancelButton);
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



function WriteToFile(FName:string;SizeOfBuf:word;Var Buf):boolean;
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
    MessageBox(^M+#3'Не могу создать файл '+FNAme+'. Код:'+IntToStr(i:CKol),nil,mfError+mfCancelButton);
    exit;
   end;
  i:=IOResult;
    BlockWrite(ToF, Buf, SizeOfBuf, NumWritten);
    i:=IOResult;
    if i<>0 then
     begin
      MessageBox(^M+#3'Ошибка записи в '+FNAme+'. Код:'+IntToStr(i:CKol),nil,mfError+mfCancelButton);
      i:=IOResult;
      System.close(ToF);
      i:=IOResult;
      exit;
    end;
   i:=IOResult;
   System.close(ToF);
   i:=IOResult;
   if i=0 then WriteToFile:=true;
End;



{эта процедура работает на машине отправителя
и помечает на своей машине уже переданные получателю файлы}
Function SetCopyMailAttribute(FN:String):boolean;
Var F: File;
    Attr: word;
Begin
  SetCopyMailAttribute:=False;
  Assign(f,FN);
  GetFAttr(f,Attr);
   if doserror=0 then
     begin
      SetFAttr(f,Dos.Hidden+Dos.Archive+Dos.System);
      SetCopyMailAttribute:=True;
     end
   else
     begin
      MessageBox(^M+#3+'Ошибка доступа к файлу архива '+FN+'!'^M+
	 #3+' Код: '+IntToStr(DosError,CLitrMantissa)+' Отметка об успешной передаче не установлена',Nil,mfError+mfCancelButton);
     end;
End;


{генерируем список файлов подлежащих отправке}
{эта процедура работает с локальными данными}
Procedure MakeListOutFile(Var P : PBox);
Var s : TMyString;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
    c : Word;
Begin

DInfoMsg('Формирую список накладных к отправке. Ждите...',True);

 FindFirst(PathExpImp^.Dat.ToImport[1]+'*'+Rek^.Dat.Kod[3]+'.'+Rek^.Dat.Kod[4]+'??', AnyFile, DirInfo);

 while DosError = 0 do
 begin
   If Not SystemAttribute(PathExpImp^.Dat.ToImport[1]+DirInfo.Name) Then
   Begin
    s:=PathExpImp^.Dat.ToImport[1]+DirInfo.Name;
    P^.List^.Insert(NewStr(s));
    P^.SetRange(P^.List^.Count);
   End;

   FindNext(DirInfo);
 end;{While}
NoInfoMsg;
End;


{генерируем список файлов подлежащих получению
эта процедура работает с удаленнм диском}
Procedure MakeListInFile;
Var s : TMyString;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
    c : Word;
    txt : Text;


Begin
DInfoMsg('Формирую список накладных, подлежащих приему. Ждите...',True);

 FindFirst(ReamoteDir+'*.?'+Rek^.Dat.Kod[3]+Rek^.Dat.Kod[4], AnyFile, DirInfo);
 while DosError = 0 do
 begin
   If Not SystemAttribute(RemoteDir+DirInfo.Name) Then

   s:=RemoteDit+DirInfo.Name;
   Writeln(txt,s);
   FindNext(DirInfo);
 end;{While}

 c := IOResult;
 Close(txt);
 c := IOResult;

NoInfoMsg;
End;



Procedure DialUpAuto;
Begin
{

1.сначала диалоговое окно с выбором вида операции
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




End;



Begin
End.

