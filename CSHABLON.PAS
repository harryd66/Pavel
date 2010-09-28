Uses Glob,Serv,Servstr,Dialogs,Objects;


Var
   Flck : File Of LockBazType;
   lck : LockBazType;
   c : LongInt;


Begin
Assign(flck,'Shablon.lck');
c:=IoResult;
Rewrite(flck);
c:=IoResult;
For c:=0 To 60000 Do
 Begin
  Lck.BazKod:=IntToStr(c,CArtikul);
  RFormatZerro(Lck.BazKod,CArtikul);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(flck,Lck);
 End;
c:=IoResult;
Close(flck);
c:=IoResult;
End.
