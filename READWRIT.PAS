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
    MessageBox(^M+#3'�� ���� ������ 䠩� '+FNAme+'. ���:'+IntToStr(i:CKol),nil,mfError+mfCancelButton);
    exit;
   end;
  i:=IOResult;
  BlockRead(FromF, Buf, SizeOfBuf, NumRead);
  i:=IOResult;
  if i<>0 then
     begin
      MessageBox(^M+#3'�訡�� �⥭��! '+FNAme+'. ���:'+IntToStr(i:CKol),nil,mfError+mfCancelButton);
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
    MessageBox(^M+#3'�� ���� ᮧ���� 䠩� '+FNAme+'. ���:'+IntToStr(i:CKol),nil,mfError+mfCancelButton);
    exit;
   end;
  i:=IOResult;
    BlockWrite(ToF, Buf, SizeOfBuf, NumWritten);
    i:=IOResult;
    if i<>0 then
     begin
      MessageBox(^M+#3'�訡�� ����� � '+FNAme+'. ���:'+IntToStr(i:CKol),nil,mfError+mfCancelButton);
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



{�� ��楤�� ࠡ�⠥� �� ��設� ��ࠢ�⥫�
� ����砥� �� ᢮�� ��設� 㦥 ��।���� �����⥫� 䠩��}
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
      MessageBox(^M+#3+'�訡�� ����㯠 � 䠩�� ��娢� '+FN+'!'^M+
	 #3+' ���: '+IntToStr(DosError,CLitrMantissa)+' �⬥⪠ �� �ᯥ譮� ��।�� �� ��⠭������',Nil,mfError+mfCancelButton);
     end;
End;


{������㥬 ᯨ᮪ 䠩��� ��������� ��ࠢ��}
{�� ��楤�� ࠡ�⠥� � ������묨 ����묨}
Procedure MakeListOutFile(Var P : PBox);
Var s : TMyString;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
    c : Word;
Begin

DInfoMsg('��ନ��� ᯨ᮪ ��������� � ��ࠢ��. ����...',True);

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


{������㥬 ᯨ᮪ 䠩��� ��������� ����祭��
�� ��楤�� ࠡ�⠥� � 㤠����� ��᪮�}
Procedure MakeListInFile;
Var s : TMyString;
 DirInfo: SearchRec;         { For Windows, use TSearchRec }
    c : Word;
    txt : Text;


Begin
DInfoMsg('��ନ��� ᯨ᮪ ���������, ��������� �ਥ��. ����...',True);

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

1.᭠砫� ���������� ���� � �롮஬ ���� ����樨
[�ਭ��� � ��ࠢ�� �����]
  �᫨ ��祣� �� ���� � ��室

2.�஢��塞 ��⮢����� 㤠������� ��᪠ � ࠡ��
  FExists(RemoteDit+'dialup.txt')
  �᫨ ��� � ��室

3.�᫨ ��ࠢ��� ⮣�� �ନ�㥬 ᯨ᮪ 䠩���
  ��������� ��ࠢ��


  a) ��ࠢ�塞 �� �� �㦭� � �� ��ࠢ������ 䠩���
     �� �����쭮� ��設� ���⠢�塞 ���ਡ�� System

4.�᫨ �㦭� �ਭ��� ����� �ନ�� �� 㤠������ ��設�
  ᯨ᮪ 䠩���, ��������� ����祭��

  �) �����㥬 �� 䠩�� �� ������� ��� � ���⠢�塞
     ���ਡ�� ��⥬��


5. ����饭�� �� ��࠭ �� ����砭�� ����樨
   � �।�०����� � ����室����� �몫���� 㤠������ �����!
  }




End;



Begin
End.

