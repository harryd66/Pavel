Uses Glob, servstr;

var fb: file of BarterClientType;
    b: BarterClientType;
    i: word;

BEGIN

Assign(fb,'0022.brt');
i:=ioresult;
Reset(fb);
i:=ioresult;
while not eof(fb) do
begin
 read(fb,b);
 if ((StrToInt(b.Document)=1)or(StrToInt(b.Document)=2)) and (b.Date='27-09-07') then
 begin
   b.Active:=false;
   i:=ioresult;
   seek(fb,filepos(fb)-1);                   `
   i:=ioresult;
   write(fb,b);
 end;
end;
i:=ioresult;
close(fb);
i:=ioresult;
END.