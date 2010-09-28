Uses Glob,Serv,ServStr,TpDate;

VAr f : File Of SuperMarketType;
    E : PSuperMarketType;
    i : Word;

Begin
Assign(f,'07-06-01.mrk');
i:=IOresult;
Reset(f);
i:=IOresult;
If i<>0 Then Exit;

New(E,Init);
While Not (Eof(f)) Do
 Begin
  Read(f,E^.DAt);

  If (E^.Dat.Document='4')  And (E^.Dat.Active) Then
   Begin
    Seek(f,Filepos(f)-1);
    E^.Dat.Active:=False;
    Write(f,E^.DAt);
    Writeln('Исправлена');
   End;

  If (E^.Dat.Document='5')  And (E^.Dat.Active) Then
   Begin
    Seek(f,Filepos(f)-1);
    E^.Dat.Active:=False;
    Write(f,E^.DAt);
    Writeln('Исправлена');
   End;

  If (E^.Dat.Document='6')  And (E^.Dat.Active) Then
   Begin
    Seek(f,Filepos(f)-1);
    E^.Dat.Active:=False;
    Write(f,E^.DAt);
    Writeln('Исправлена');
   End;

 End;
i:=IOresult;
Dispose(E,Done);
i:=IOresult;
Close(f);
i:=IOresult;

Writeln('All ok');
End.