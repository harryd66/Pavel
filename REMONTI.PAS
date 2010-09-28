{remonti.exe d:\newskl\main\ d:\newskl\main\ d:\newskl\id\}

Uses Glob,Serv,Servstr,Objects;

VAr sklFile : File Of SkladType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    IDFile : File Of BazType;
    Max : LongInt;
    c : Word;
Begin
Assign(RazdelFile,ParamStr(1)+'Razdel.db');
Reset(RazdelFile);
c:=IOResult;

While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
   Assign(SklFile,ParamStr(2)+RazdelElement.Kod+'.db');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;

   Assign(IDFile,ParamStr(3)+RazdelElement.Kod+'.id');
   c:=IOResult;
   Reset(IDFile);
   c:=IOResult;

   Max:=FileSize(SklFile);

   Seek(IdFile,MAx);
   Truncate(IdFile);

   Close(SklFile);
   Close(IDFile);
   End;
   Writeln(RazdelElement.Kod+'-Ok');
 End;
Close(RazdelFile);
c:=IoResult;


End.