Uses Glob, ServStr;

var M: SuperMarketType;
    fm: file of SuperMarketType;
    i,Iorez: word;
BEGIN
  Assign(fm,'z:\nskl\market\12-01-09.mrk');
  Iorez:=ioresult;
  Reset(fm);
  Iorez:=ioresult;
  if iorez<>0 then
  begin
    writeln('z:\nskl\market\12-01-09.mrk');
    halt;
  end;
  i:=1;
  while not eof(fm) do
  begin
    read(fm,m);
    if StrToInt(m.SfNumer)>1000 then
    begin
     writeln(m.SfNumer);
     m.SfNumer:=IntToStr(i,CDocNumer);
     inc(i);
     Iorez:=ioresult;
     seek(fm,filepos(fm)-1);
     Iorez:=ioresult;
     write(fm,m);
     Iorez:=ioresult;
    end;
  end;

  Iorez:=ioresult;
  close(fm);
  Iorez:=ioresult;

END.