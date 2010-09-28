Uses Glob,Serv,ServStr;

Var f : File Of SuperMArketType;
    E : PSuperMarketType;

Begin
Assign(f,'28-06-04.mrk');
reset(f);
New(E,Init);
while not (eof(f)) do
 begin
  Read(f,E^.dat);
  Writeln(E^.dat.document+' от '+E^.DAt.DAteC);
  Writeln(E^.dat.Active);
  Readln;
  If StrToInt(E^.dat.document)=165 Then
   Begin
    TrunCate(f);
   End;



 end;

Close(f);

End.