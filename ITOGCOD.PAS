Uses Glob,ServStr,Serv,Objects,TpDAte,NetDbEng;

Const ReadOnly=0+$42 {на самом деле не ReadOnly a DenyNone
                      открытие на чтениеи запись но всем разрешено все};


Type Data = Record
 OldCod : ArtikulStr;
 NewCod : ArtikulStr;
End;


VAr fId : File Of Data;
    Id : Data;
    OldFileMode : Word;

Function GetNewKod(c:ArtikulStr):ArtikulStr;
Var l    : LongInt;
    Code : Integer;
    Art,st   : ArtikulStr;

Begin
 GetNewKod[0]:=#0;
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 Art:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fId,ParamStr(2)+c+'.nk');
 GetNewKod[0]:=#0;
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Writeln(ParamStr(2)+c+'.nk'+' Код:['+st+']');
  Readln;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Seek(fid,L);
   Code:=IOResult;
   Read(FId,Id);
   Close(fid);
   FileMode:=OldFileMode;
   GetNewKod := Id.NewCod;
   If Id.NewCod[0]=#0 Then
    Begin
     Writeln('Нет кода сооветствия для '+Art);
     Readln;
    End;
  End;
End;




Var BakFile : File Of NewItogType;
    F :File Of NewItogType;
    BakPtr :PNewItogType;
    Ptr :PNewItogType;
    s1,s2:String;
    i : Word;

Begin
s1:=ParamStr(1);
Assign(BakFile,s1+'.'+ParamStr(3));
i:=IOResult;
Reset(BakFile);
i:=IOResult;
If I<>0 Then
 Begin
  Writeln('Не могу открыть '+s1+ParamStr(3));
  Halt;
 End;

Assign(F,s1+'.new');
i:=IOResult;
Rewrite(F);
i:=IOResult;
If I<>0 Then
 Begin
  Close(BakFile);
  Writeln('Не могу создать '+s1+'.new');
  Halt;
 End;

New(BakPtr,Init);
New(Ptr,Init);

While Not(Eof(BakFile)) Do
 Begin
     Read(BakFile,BakPtr^.Dat);
     Ptr^.Dat:=BakPtr^.Dat;
         Ptr^.Dat.BazKod:=GetNewKod(BakPtr^.Dat.BazKod);
   seek(f,filesize(f));
   Write(f,ptr^.dat);
 End;
Dispose(BakPtr,Done);
Dispose(Ptr,Done);
Close(BakFile);
Close(f);
Rename(BakFile,s1+'.bak');
Rename(F,s1+ParamStr(3));
Writeln('All Ok')
End.
