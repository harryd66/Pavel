Uses Glob,Serv,Servstr;

Var f : File Of KassaOperationType;
    c : Word;
    e : PKassaOperationType;
Begin
Assign(f,'kassa.db');
c:=IoResult;
Rewrite(f);
c:=IoResult;
For c:=0 To 100 Do
 Begin
  New(E,Init);

  E^.Dat.Kod:=IntToStr(c,CClientKod);
  RFormatZerro(E^.Dat.Kod,CClientKod);
  If c=0 Then
   Begin
    E^.Dat.Employ:=True;
    E^.Dat.Name1:='..';
    E^.Dat.Name2:='..';
    E^.Dat.RCD:=False;
   End;
  Write(f,E^.DAt);
  Writeln(E^.Dat.Kod);
  Dispose(E,Done);
 End;
Writeln('Vse');
End.