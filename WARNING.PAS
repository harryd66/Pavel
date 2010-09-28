Uses Glob,Serv,Servstr;

Var f : File Of ZakazType;
    Zak : ZakazType;

Begin
Assign(f,'zakaz.db');
Reset(f);

While Not (Eof(f)) Do
 Begin
  Read(f,Zak);
  Writeln(Zak.Document+' от '+Zak.DAteC);
 End;


Close(f);

End.