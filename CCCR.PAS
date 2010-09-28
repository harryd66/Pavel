Uses Glob,Serv,ServStr,TPDAte;


Var
    bf : File Of RazdelType;
    NS : RAzdelType;

    c : Word;

Begin
Assign(bf,'razdel.db');
c:=IoResult;
Reset(bf);
c:=IoResult;
Seek(bf,26);
Read(bf,ns);
Ns.Employ:=False;
Seek(bf,26);
Write(bf,ns);
c:=IoResult;
CLose(bf);
c:=IoResult;



End.