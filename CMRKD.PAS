Uses Glob,Serv,ServStr,TpDAte;

VAr e : SuperMArketType;
    f : File Of SuperMArketType;
    c : Word;

Begin
Assign(f,'03-03-06.mrk');
c:=IOResult;
Reset(f);
c:=IOResult;
Seek(f,9);
Truncate(f);
close(f);
c:=IOResult;
End.
