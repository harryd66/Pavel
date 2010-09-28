
Uses Glob,Serv,Servstr;

Var f : File Of SuperMarketTypeIDX;
    e : PSuperMarketTypeIDX;

Begin
Assign(f,ParamStr(1));
Reset(f);
New(E,Init);

While Not(Eof(f)) Do
 Begin
   Read(f,E^.Dat);
   Writeln(E^.DAt.Document);
   Readln;
 End;
Dispose(E,Done);


Close(f);


End.