Uses Glob,Protect,Serv,ServStr;

Var f : File Of DocBazType;
    P : PDocBazType;
    c : Byte;
    s : String;
    Find:Boolean;

Begin
Assign(f,ParamStr(1));

c:=IOREsult;
Reset(f);
c:=IOREsult;
If c<>0 Then
 Begin
  Writeln('Не открыт '+ParamStr(1));
  Exit;
 End;

New(P,Init);

Seek(f,StrToInt(PAramStr(2))-1);
Read(f,P^.Dat);
Writeln('Найден '+P^.Dat.Numer);
P^.Dat.Status:=False;
P^.Dat.Document:='';
P^.Dat.DateDocument:='';
P^.Dat.DateC:='';
P^.Dat.TimeC:='';

Seek(f,FilePos(f)-1);
Write(f,P^.Dat);

Dispose(P,Done);

c:=IOREsult;
Close(f);
c:=IOREsult;

Writeln('All Ok');

End.

