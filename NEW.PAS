Uses Glob,DBEngine;

Var E : PSuperMArketType;
    f : File Of SuperMArketType;

Begin
Assign(f,'c:\newskl\market\19-03-01.mrk');
reset(f);
Seek(f,75);
New(E,Init);
Read(f,E^.DAt);
E^.Dat.Oformlenie:=0;
seek(f,FilePos(f)-1);
Write(f,E^.DAt);
Close(f);
Dispose(E,Done);
Writeln('All ok');

End.