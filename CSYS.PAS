Uses Glob,Servstr;

Type TSystemReestrOld=Record
      Name : String [CKto];
  Password : String[CInputILitr];
    Employ : Boolean;
      Kod  : String [CRazdelKod];
      End;

var Old: TSystemReestrOld;
    New: TSystemReestr;
    FO: file of TSystemReestrOld;
    FN: file of TSystemReestr;
    c,i:word;
BEGIN
 Assign(FO,'system.db');
 c:=ioresult;
 Reset(FO);
 c:=ioresult;

 Assign(FN,'system.new');
 c:=ioresult;
 Rewrite(FN);
 c:=ioresult;

 while not eof(FO) do
 begin
  read(FO,Old);
  New.Name := Old.Name ;
  New.Password := old.Password;
  New.Employ := old.Employ;
  New.Kod:= old.Kod;
  for i:=0 to 255 do New.User[i]:=false;
  write(FN,New);
 end;

 close(FO);
 Close(FN);

END.