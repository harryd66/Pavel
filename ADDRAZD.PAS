Uses Glob,Serv,ServStr,TPDAte;



Var bf : File Of RazdelType;
    NS : RAzdelType;
    c : Word;

Begin
Assign(bf,'razdel.db');
Reset(bf);

Seek(bf,0);
  Read(bf,ns);

  With NS Do
   Begin
      MinNazenka :='1.000';
      Kod        :=IntToStr(FileSize(Bf),CMantissa);
      RFormatZerro(Ns.Kod,CMantissa);
      Employ     :=False;
      Locked     :=False;
    For c:=1 To CShkala DO
     Begin
      Skidka[c].Up:=Skidka[c].Up;
      Skidka[c].Proz:=Skidka[c].Proz;
      Skidka[c].MinNaz:='1.000';
     End;
   End;
Seek(bf,FileSize(Bf));

Write(bf,NS);






CLose(bf);



End.