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

  If (E^.Dat.Document='8')And (E^.Dat.Active)  Then
   Begin
    Seek(f,Filepos(f)-1);
    E^.DAt.Skidka:='0.00';
    Write(f,E^.DAt);
    Writeln('��ࠢ����');
   End;

  If (E^.Dat.Document='9')And (E^.Dat.Active)  Then
   Begin
    Seek(f,Filepos(f)-1);
    E^.DAt.Skidka:='0.00';
    Write(f,E^.DAt);
    Writeln('��ࠢ����');
   End;

 End;
i:=IOresult;
Dispose(E,Done);
i:=IOresult;
Close(f);
i:=IOresult;

Writeln('All ok');
End.
