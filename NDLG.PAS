Uses Glob,Serv,ServStr,TpDate;

VAr f : File Of RealizasiaType;
    E : PRealizasiaType;
    i : Word;

Begin
Assign(f,'1878.dlg');
i:=IOresult;
Reset(f);
i:=IOresult;
If i<>0 Then Exit;

New(E,Init);
While Not (Eof(f)) Do
 Begin
  Read(f,E^.DAt);

  Writeln(E^.Dat.Market.Document);

  If (E^.Dat.Market.Document='226')  And (E^.Dat.Market.Active) And
  (DateToDateString(DAteMask,E^.Dat.Market.DateC)='27-04-01') Then
   Begin
    Seek(f,Filepos(f)-1);
    E^.Dat.Dolg:=0.00;
    E^.Dat.Full:=True;
    E^.Dat.Payment:=True ;
    E^.Dat.Doc[1].DocReal:='1';
    E^.Dat.Doc[1].DocDate:=DateStringToDate(DAteMask,'29-05-01');
    E^.Dat.Doc[1].Employ:=True;

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