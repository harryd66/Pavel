Uses Glob, ServStr;

var skld,sklr: SkladType;
    fskld,fsklr: file of SkladType;
    r: RazdelType;
    fr: file of RazdelType;
    KOd, code, i, iorez: word;
    sRazd : string[CRazdelKOd];
    sKOd: string[3];
    sArt: string[CArtikul];
    t: text;
BEGIN

  Assign(fr,'main\razdel.db');
  iorez:=ioresult;
  Reset(fr);
  iorez:=ioresult;
  if iorez<>0 then
    begin
      Writeln('�訡�� ������ razdel.db');
      Writeln('������ ������� Enter!');
      readln;
      exit;
    end;

  while not eof(fr) do
  begin
    read(fr,r);
 if r.Employ then
 Begin
    sRazd:=r.Kod;
    {���뢠�� ���⠢��}
      Assign(fskld,'main\main\'+sRazd+'.db');
      iorez:=ioresult;
      Reset(fskld);
      iorez:=ioresult;
      if iorez<>0 then
      begin
        Writeln('main\main\'+sRazd+'.db');
        Writeln('������ ������� Enter!');
        readln;
        exit;
      end;
     while not eof(fskld) do
     begin
      read(fskld,skld);
      if skld.Employ then
       if strtoint(skld.Input.KOl)>0 then
        begin
         sKOd:=copy(skld.BazKOd,3,3);
         val(sKOd,KOd,Code);
         {���뢠�� १��}
         Assign(fsklr,'main\'+sRazd+'.db');
         iorez:=ioresult;
         Reset(fsklr);
         iorez:=ioresult;
         if iorez<>0 then
         begin
           Writeln('main\'+sRazd+'.db');
           Writeln('������ ������� Enter!');
           readln;
           exit;
         end;
         {�㬬��㥬 ���⪨ १�ࢠ � ���⠢��}
         seek(fsklr,KOd);
         read(fsklr,sklr);
         Str(StrToInt(sklr.Input.KOl)+StrToInt(skld.Input.KOl):CKOl,sklr.Input.KOl);
         for i:=1 to CDivision do
          Str(StrToInt(sklr.Input.Division[i])+StrToInt(skld.Input.Division[i]):CKOl,sklr.Input.Division[i]);

         sklr.Employ:=true;
         seek(fsklr,FilePOs(fsklr)-1);
         write(fsklr,sklr);

         close(fsklr);
        end;
	end;

    {����뢠�� ���⠢��}
    close(fskld);
  End;
  end;

close(fr);

END.