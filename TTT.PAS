Uses Glob,Serv,Utils,ServStr,Objects;

Var l,c : Word;
    MMM8 : MAskaNew;
    E : BazType;
    f : File Of BazType;

Begin
Assign(f,'c:\nsklder\id\00.id');
Reset(f);
Seek(f,90);
Read(f,E);
Close(f);
Writeln(E.EnableOtdel);
Readln(c);
WordToBitNew(c,MMM8);
ConvertNew(MMM8);

Writeln(MMM8[1]:1,' ',MMM8[2]:1,' ',MMM8[3]:1,' ',
MMM8[4]:1,' ',MMM8[5]:1,' ',MMM8[6]:1,' ',MMM8[7]:1,' ',MMM8[8]:1,' ');

   l:=MMM8[4];
   MMM8[4]:=MMM8[2];
   MMM8[2]:=l;

   l:=MMM8[1];
   MMM8[1]:=MMM8[5];
   MMM8[5]:=l;

ConvertNew(MMM8);

Writeln(MMM8[1]:1,' ',MMM8[2]:1,' ',MMM8[3]:1,' ',
MMM8[4]:1,' ',MMM8[5]:1,' ',MMM8[6]:1,' ',MMM8[7]:1,' ',MMM8[8]:1,' ');


BitToWordNew(MMM8,c);

Writeln(c);

Writeln('Все');





End.