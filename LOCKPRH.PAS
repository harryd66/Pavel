Uses Glob, ServStr;

var fp: file of PrihodType;
    p: PrihodType;
    i: word;

begin
   Assign(fp,'27-09-07.prh');
   i:=ioresult;
   Reset(fp);
   i:=ioresult;
   if i=0 then
   while not eof(fp) do
   begin
     read(fp,p);
     if (StrToInt(p.Document)=1) or (StrToInt(p.Document)=2) then
     begin
       p.StatusDoc:=0;
       seek(fp,FilePos(fp)-1);
       write(fp,p);
     end;
   end;
   i:=ioresult;
   close(fp);
   i:=ioresult;
end.
