{$I Compile.INC}

{$DEFINE Converter}

Uses Glob,ServStr;

Var POstFile : File Of PostType;
    FirmaPostFile : FirmaPostFileType;
    KSertifFile : KSertifFileType;
    PostE : PPostType;
    FirmaPostE : PFirmaPostType;
    KSertifE : PKSertifType;
    txt : Text;
    c,sh : Word;
    s : String;

Begin
Assign(txt,'Post.txt');
Reset(txt);

Assign(POstFile,'lands.db');
Rewrite(PostFile);
If IOResult<>0 Then
Begin
 Writeln('Ошибка создания lands.db');
 Halt;
End;

sh:=0;
While Not(Eof(txt)) Do
 Begin
  Readln(txt,s);
  DelSpaceRight(s);
  UPSTR(S);
  New(PostE,Init);
  PostE^.Dat.Post:=S;

  s:=IntToStr(sh,CCLientKod);
  RFormatZerro(S,CClientKod);
  PostE^.Dat.Kod:=s;
  PostE^.Dat.Employ:=True;
  PostE^.Dat.RCD:=False;
  PostE^.Dat.Locked:=False;

  Write(POstFile,PostE^.Dat);
  Dispose(PostE,Done);
  Inc(sh);
 End;
Close(txt);


For c:=sh To 300 Do
 Begin
  New(PostE,Init);
  s:=IntToStr(c,CCLientKod);
  RFormatZerro(S,CClientKod);
  PostE^.Dat.Kod:=s;
  PostE^.Dat.Employ:=False;
  PostE^.Dat.RCD:=False;
  PostE^.Dat.Locked:=False;

  Write(POstFile,PostE^.Dat);
  Dispose(PostE,Done);
 End;

Close(PostFile);

If IOResult=0 Then Writeln('lands.db Все ок +',(300-sh):CKOl);

Assign(txt,'firma.txt');
Reset(txt);

Assign(FirmaPostFile,'Firma.db');
Rewrite(FirmaPostFile);
If IOResult<>0 Then
Begin
 Writeln('Ошибка создания Firma.db');
 Halt;
End;

sh:=0;
While Not(Eof(txt)) Do
 Begin
  Readln(txt,s);
  DelSpaceRight(s);
  UPSTR(S);
  New(FirmaPostE,Init);
  FirmaPostE^.Dat.FirmaPost:=S;
  s:=IntToStr(sh,CCLientKod);
  RFormatZerro(S,CClientKod);
  FirmaPostE^.Dat.Kod:=s;
  FirmaPostE^.Dat.Employ:=True;
  FirmaPostE^.Dat.RCD:=False;
  FirmaPostE^.Dat.Locked:=False;

  Write(FirmaPostFile,FirmaPostE^.Dat);
  Dispose(FirmaPostE,Done);
  Inc(sh);
 End;
Close(txt);


For c:=sh To 800 Do
 Begin
  New(FirmaPostE,Init);
  s:=IntToStr(c,CCLientKod);
  RFormatZerro(S,CClientKod);
  FirmaPostE^.Dat.Kod:=s;
  FirmaPostE^.Dat.Employ:=False;
  FirmaPostE^.Dat.RCD:=False;
  FirmaPostE^.Dat.Locked:=False;

  Write(FirmaPostFile,FirmaPostE^.Dat);
  Dispose(FirmaPostE,Done);
 End;

Close(FirmaPostFile);



If IOResult=0 Then Writeln('Firma.db Все ок +',(800-sh):CKOl);


Assign(txt,'ksertif.txt');
Reset(txt);

Assign(KSertifFile,'ksertif.db');
Rewrite(KSertifFile);
If IOResult<>0 Then
Begin
 Writeln('Ошибка создания ksertif.db');
 Halt;
End;

sh:=0;
While Not(Eof(txt)) Do
 Begin
  Readln(txt,s);
  DelSpaceRight(s);
  UPSTR(S);
  New(KSertifE,Init);
  KSertifE^.Dat.KSertif:=S;
  s:=IntToStr(sh,CCLientKod);
  RFormatZerro(S,CClientKod);
  KSertifE^.Dat.Kod:=s;
  KSertifE^.Dat.Employ:=True;
  KSertifE^.Dat.RCD:=False;
  KSertifE^.Dat.Locked:=False;

  Write(KSertifFile,KSertifE^.Dat);
  Dispose(KSertifE,Done);
  Inc(sh);
 End;
Close(txt);


For c:=sh To 500 Do
 Begin
  New(KSertifE,Init);
  s:=IntToStr(c,CCLientKod);
  RFormatZerro(S,CClientKod);
  KSertifE^.Dat.Kod:=s;
  KSertifE^.Dat.Employ:=False;
  KSertifE^.Dat.RCD:=False;
  KSertifE^.Dat.Locked:=False;

  Write(KSertifFile,KSertifE^.Dat);
  Dispose(KSertifE,Done);
 End;

Close(KSertifFile);

If IOResult=0 Then Writeln('KSertif.db Все ок +',(500-sh):CKOl);

End.
