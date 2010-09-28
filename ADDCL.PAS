Uses Glob, Servstr;

var c: ClientType;
    fc, fadd: file of ClientType;
    i, IORez, kod: word;
    sKOd: string[CCLientKOd];
    Code: integer;
    ch:char;
    Pstr: string;

BEGIN


 PStr:=ParamStr(1);
 ch:=PStr[Pos('.',PStr)-1];
 {writeln(ch);
 Halt(0);}

 case ch of

  'c','C': Begin
       if Paramstr(2)<>'' then
         Assign(fc,Paramstr(2)+'client.db')
         else Assign(fc,'client.db');
         IOrez:=ioresult;
         Reset(fc);
         IOrez:=ioresult;
         If IOrez<>0 then begin
          writeln( 'Ошибка открытия client.db');
          exit;
         end;
         Writeln('Клиент');
        End;

   's','S': Begin
       if Paramstr(2)<>'' then
         Assign(fc,Paramstr(2)+'sklad.db')
         else Assign(fc,'sklad.db');
         IOrez:=ioresult;
         Reset(fc);
         IOrez:=ioresult;
         If IOrez<>0 then begin
          writeln( 'Ошибка открытия sklad.db');
          exit;
         end;
         Writeln('Склад');
        End;

    'm','M': Begin
        if Paramstr(2)<>'' then
              Assign(fc,Paramstr(2)+'make.db')
         else Assign(fc,'make.db');
         IOrez:=ioresult;
         Reset(fc);
         IOrez:=ioresult;
         If IOrez<>0 then begin
          writeln( 'Ошибка открытия make.db');
          exit;
         end;
         Writeln('Поставщик');
        End;

   end;{case}

 Assign(fadd,ParamStr(1));
 IOrez:=ioresult;
 Reset(fadd);
 IOrez:=ioresult;
 If IOrez<>0 then begin
    writeln( 'Ошибка открытия '+ParamStr(1));
    exit;
   end;


 While not eof(fadd) do
  begin
   read(fadd,c);
   skod:=c.KOd;
   val(skod,kod,Code);
   if code <> 0 then begin
     Writeln('Error at position: ', Code);
     exit;
    end;
   seek(fc,kod);
   write(fc,c);
  end;

 close(fc);
 close(fadd);
 writeln('All ok');
END.
