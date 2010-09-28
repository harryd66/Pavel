Uses Glob, Servstr;
{id и prh в одном каталоге}
Var P: PrihodType;
    fp: file of PrihodType;
    id: bazType;
    fid: file of BazType;
    i, iorez: word;
    sKod: ArtikulStr;
BEGIN
  Assign(fp,ParamStr(1));
  iorez:=ioresult;
  Reset(fp);
  if IOrez=0 then
  begin
    while not eof(fp) do
    begin
      read(fp,p);
      for i:=1 to p.amount do
      begin
        sKod:=p.PrihodElement[i].bazkod;
        Assign(fid,copy(sKod,1,2)+'.id');
        iorez:=ioresult;
        Reset(fid);
        iorez:=ioresult;
        if iorez=0 then
        begin
          if strtoint(copy(sKOd,2,3))<=FileSize(fid) then
          begin
           seek(fid,StrToInt(copy(sKOd,2,3)));
           read(fid,id);
           MyStr(StrToReal(p.PrihodElement[i].Input.Zakupka)*StrToReal(id.InPack),
		 CZena,CMantissa,p.PrihodElement[i].Input.Zakupka);
           rformat(p.PrihodElement[i].Input.Zakupka,CZena);
           close(fid);
          end;
        end
        else writeln(copy(sKod,1,2)+'.id'' !!!!!!!!!');
      end;
      seek(fp,FilePOs(fp)-1);
      write(fp,p);
    end;
   close(fp);
  end
  else writeln(ParamStr(1)+' !!!!!!!!!');
END.