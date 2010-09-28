Uses Glob,Servstr;
VAR O:OplataRealizasiaType;
    fo: file of OplataRealizasiaType;
    i:word;

BEGIN
Assign(fo,'28-03-07.opl');
reset(fo);
while not eof(fo) do
begin
 read(fo,o);
 DelSpace(o.SummaZ);
 if o.SummaZ='5624.34' then
 begin
   O.Rashet:=0;
   Seek(fo,FilePos(fo)-1);
   write(fo,o);
   close(fo);
   writeln('!!!!!!!!!');
   exit
 end;
end;
END.