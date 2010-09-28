Uses Glob,Serv,ServStr,TPDAte;

Type BakShkala = Record
     Up : String[CIZena];
     Proz : String[CLitr+1];
     End;

Type BakSkidkaType = Record
     BazKod : String[CArtikul];
     Date   : TDateString;
     Time   : TDateString;
     Caption: String [CRazdelKod];
     Skidka : Array [1..CShkala] of BakShkala;
     End;


Var bf : File Of BakSkidkaType;
    nf : File Of SkidkaType;
    NS : PSkidkaType;
    bs : BakSkidkaType;
    c : Word;

Begin
Assign(bf,PAramStr(1)+'.skl');
Reset(bf);

Assign(nf,PAramStr(1)+'.nsk');
Rewrite(nf);


New(Ns,Init);

While Not(Eof(bf)) DO
 Begin
  Read(bf,Bs);

  With NS^.DAt Do
   Begin
    BazKod:=BS.BAzKod;
    DAte  :=BS.DAte;
    Time  :=BS.Time;
    CAption:=BS.CAption;
    {MinHand:='1.000';}
    For c:=1 To CShkala DO
     Begin
      Skidka[c].Up:=Bs.Skidka[c].Up;
      Skidka[c].Proz:=Bs.Skidka[c].Proz;
      Skidka[c].MinNAz:='1.000';
     End;
   End;
  Write(nf,NS^.Dat);


 End;



Dispose(Ns,Done);

CLose(bf);
CLose(Nf);



End.