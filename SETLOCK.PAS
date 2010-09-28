Uses Glob,Serv,ServStr,TpDate,Net,Net1,NetDbEng,NetCall,WinDos;
Var
    F: File Of ClientType;
    ClientElement : ClientType;
    txt : Text;
    SKod : allStr;
    c : Word;

Begin
Assign(f,'Client.db');
c:=IOResult;
Reset(f);
c:=IOResult;


Assign(txt,'1.txt');
c:=IOResult;
Reset(txt);
c:=IOResult;


While Not(SeekEof(txt)) Do
 Begin
  Readln(txt,SKod);

  Seek(f,StrToInt(SKod));
  Read(f,ClientElement);
  ClientElement.RCD:=True;
c:=IOResult;
  Seek(f,FilePos(F)-1);
c:=IOResult;
  Write(f,ClientElement);
c:=IOResult;
 End;

c:=IOResult;
Close(txt);
c:=IOResult;
Close(f);
c:=IOResult;

End.
