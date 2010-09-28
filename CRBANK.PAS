Uses Glob,Serv,Servstr;

Var f : File Of BankType;
    c : LongInt;
    e : PBankType;
Begin
Assign(f,'banks.db');
c:=IoResult;
Rewrite(f);
c:=IoResult;
For c:=0 To 200 Do
 Begin
  New(E,Init);
  E^.Dat.Kod:=IntToStr(c,CClientKod);
  RFormatZerro(E^.Dat.Kod,CClientKod);
  If c=0 Then
   Begin
    E^.Dat.FullName:='..';
    E^.Dat.Employ:=True;
   End;
  Write(f,E^.Dat);
  Dispose(E,Done);
 End;
End.