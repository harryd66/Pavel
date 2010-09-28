Uses Glob,Objects;

Var f : File Of PrihodType;
    E : PPrihodType;
    i : Word;
Begin
Assign(f,'07-05-01.prh');
Reset(f);
i:=IOResult;
Seek(f,1);
i:=IOResult;

New(E,Init);
Read(f,E^.DAt);
Seek(f,1);
E^.Dat.StatusDoc:=0;
Write(f,E^.Dat);
Close(f);
Writeln(IOResult);
End.