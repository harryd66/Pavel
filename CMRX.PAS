
Uses Glob,Serv,TPDate,
     Servstr,NetDbEng;

Var f : File;
    E : PBufSuperMarketTypeIDX;
    cc,count : Word;

Begin
Assign(f,ParamStr(1));
Reset(f,SizeOf(SuperMarketTypeIDX));
While Not(Eof(f)) Do
 Begin
  New(E,Init);
  Count:=0;

  {BlockRead(fp,E^.Point,BufferMrkIDX,Count);}
  ReadBufHeaderMarket(f,E,Count);

For cc:=1 To Count Do
Begin
  If (E^.Point.Dat[cc].Active) Then
   Begin
    Writeln(E^.Point.Dat[cc].Document,' ',DateToDateString(DateMask,E^.Point.Dat[cc].DateC),' ',E^.Point.Dat[cc].Active);
    Readln;
   End;
End;
Dispose(E,Done);
 End;{While}
Close(f);

End.