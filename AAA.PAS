uses Glob,ServStr;

var f:file of SuperMarketType;
    e: pSuperMarketType;
    i,j : word;

Begin
 New(e,Init);
 i:=ioresult;
 assign(f,ParamStr(1));
 reset(f);
 i:=ioresult;
 if i<>0 then
   begin
    writeln('OOO!!!');
    exit;
   end;

 while not eof(f) do
  begin
   read(f,E^.dat);
   if (strtoint(e^.Dat.Document)=29) and (E^.Dat.Active=true) then
      begin
       Writeln('Nashli',filepos(f)-1);
       Seek(f,FilePos(f)-1);
       E^.Dat.Active:=False;
       {truncate(f);}
       Write(f,E^.Dat);
       close(f);
       exit;
      end;
  end;

 close(f);
 dispose(e);

End.