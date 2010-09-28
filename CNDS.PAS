Uses Glob,Serv,ServStr,NetDbEng,TpDAte;

Var  c,L : LongInt;
     E : PSuperMArketType;
     Ef : MarketFileType;

Begin
New(E,Init);
Assign(ef,'29-12-01.mrk');
c:=IOResult;
Reset(ef);
c:=IOResult;
If c<>0 Then
 Begin
  Writeln('Нет данных');
  Halt;
 End;

While Not(Eof(ef)) Do
 Begin
  ReadMArket(Ef,E);

  If E^.DAt.Active Then
   Begin
    For c:=1 To E^.DAt.Amount Do
     Begin
      E^.DAt.MArketElement[c].Input.VidNDS:=2;
      E^.DAt.MArketElement[c].Input.NDS:='0.00';
     End;
    Seek(Ef,FilePos(Ef)-1);
    Write(Ef,E^.Dat);
   End;


 End;



c:=IOResult;
Close(ef);
c:=IOResult;
Dispose(E,Done);
Writeln('AllOk');
End.