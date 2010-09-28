Uses Glob;


Var E : PSuperMarketType;
    f : File;

Begin
Assign(f,'c:\14-08-01.mrk');
Reset(f,1);
Seek(f,30*(SiZeOf(SuperMArketType)-110*2));
New(E,Init);
BlockRead(f,E^.DAt,SizeOf(SuperMarketType));
Dispose(E,Done);
Close(f);
End.