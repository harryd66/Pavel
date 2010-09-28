Uses Glob,Serv,ServStr,TPDAte;


Type BakShkala = Record
     Up : String[CIZena];
     Proz : String[CLitr];
     End;


{Раздел}

Type BakRazdelType = Record
      Name       : String[CRazdel];
      Designation: String[CDate];
      EnableLitr : Word;
      Skidka     : Array [1..6] of BakShkala;
      Kod        : String[CRazdelKod];
      Employ     : Boolean;
         Locked     : Boolean;
     End;





Var bf : File Of BakRAzdelType;
    nf : File Of RazdelType;
    NS : RAzdelType;
    bs : BakRazdelType;
    c : Word;

Begin
Assign(bf,'razdel.db');
Reset(bf);

Assign(nf,'razdel.new');
Rewrite(nf);


While Not(Eof(bf)) DO
 Begin
  Read(bf,Bs);

  With NS Do
   Begin
      Name       :=BS.Name;
      Designation:=BS.Designation;
      EnableLitr :=BS.EnableLitr;
      MinNazenka :='1.000';
      Kod        :=BS.Kod;
      Employ     :=BS.Employ;
      Locked     :=False;
    For c:=1 To CShkala DO
     Begin
      Skidka[c].Up:='1';
      Skidka[c].Proz:='1.000';
      Skidka[c].MinNaz:='1.000';
     End;
   End;
  Write(nf,NS);


 End;




CLose(bf);
CLose(Nf);



End.