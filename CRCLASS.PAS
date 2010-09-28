Uses Glob,Serv,Servstr;

Var f : File Of LockBazType;
    c : LongInt;
    e : LockBazType;
Begin
Assign(f,'5000.lck');
c:=IoResult;
Rewrite(f);
c:=IoResult;
For c:=0 To 5000 Do
 Begin
  E.BazKod:=IntToStr(c,CArtikul);
  E.Locked:=False;
  E.LockCaption[0]:=#0;
  E.LockTime:=0;
  E.ComputerNameLocked[0]:=#0;
  RFormatZerro(E.BazKod,CArtikul);
  Write(f,E);
 End;
cLOSE(F);


Assign(f,'1000.lck');
c:=IoResult;
Rewrite(f);
c:=IoResult;
For c:=0 To 1000 Do
 Begin
  E.BazKod:=IntToStr(c,CArtikul);
  E.Locked:=False;
  E.LockCaption[0]:=#0;
  E.LockTime:=0;
  E.ComputerNameLocked[0]:=#0;
  RFormatZerro(E.BazKod,CArtikul);
  Write(f,E);
 End;
cLOSE(F);


Assign(f,'00.lck');
c:=IoResult;
Rewrite(f);
c:=IoResult;
For c:=0 To 1000 Do
 Begin
  E.BazKod:=IntToStr(c,CArtikul);
  E.Locked:=False;
  E.LockCaption[0]:=#0;
  E.LockTime:=0;
  E.ComputerNameLocked[0]:=#0;
  RFormatZerro(E.BazKod,CArtikul);
  Write(f,E);
 End;
cLOSE(F);




Assign(f,'10000.lck');
c:=IoResult;
Rewrite(f);
c:=IoResult;
For c:=0 To 10000 Do
 Begin
  E.BazKod:=IntToStr(c,CArtikul);
  E.Locked:=False;
  E.LockCaption[0]:=#0;
  E.LockTime:=0;
  E.ComputerNameLocked[0]:=#0;
  RFormatZerro(E.BazKod,CArtikul);
  Write(f,E);
 End;
cLOSE(F);

Assign(f,'50000.lck');
c:=IoResult;
Rewrite(f);
c:=IoResult;
For c:=0 To 50000 Do
 Begin
  E.BazKod:=IntToStr(c,CArtikul);
  E.Locked:=False;
  E.LockCaption[0]:=#0;
  E.LockTime:=0;
  E.ComputerNameLocked[0]:=#0;
  RFormatZerro(E.BazKod,CArtikul);
  Write(f,E);
 End;
cLOSE(F);

Assign(f,'99999.lck');
c:=IoResult;
Rewrite(f);
c:=IoResult;
For c:=0 To 99999 Do
 Begin
  E.BazKod:=IntToStr(c,CArtikul);
  E.Locked:=False;
  E.LockCaption[0]:=#0;
  E.LockTime:=0;
  E.ComputerNameLocked[0]:=#0;
  RFormatZerro(E.BazKod,CArtikul);
  Write(f,E);
 End;
cLOSE(F);

Assign(f,'500.lck');
c:=IoResult;
Rewrite(f);
c:=IoResult;
For c:=0 To 500 Do
 Begin
  E.BazKod:=IntToStr(c,CArtikul);
  E.Locked:=False;
  E.LockCaption[0]:=#0;
  E.LockTime:=0;
  E.ComputerNameLocked[0]:=#0;
  RFormatZerro(E.BazKod,CArtikul);
  Write(f,E);
 End;
cLOSE(F);

End.