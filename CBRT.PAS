Uses Glob,ServStr;

Var c  :PClientType;
    cf :File of ClientType;
    l,i : Word;

begin

Assign (cf,'barter.db');
l:=IOResult;
Reset(cf);
l:=IOResult;

new(C,Init);

while not eof(cf) do
begin
 read(cf,c^.Dat);
end;

Dispose(c,Done);

New(c,Init);

for i:=1 to 100 do
begin
 write(cf,c^.Dat);
end;

dispose(c,done);

close(cf);

end.