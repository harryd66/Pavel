Uses Glob,Serv,ServStr;

{������}
Type BakClientType = Record
Name     : String[CClient];
Dogovor  : String[CAll];
Punkt    : Array [1..4] Of String[CRazdelKod];
{1 �����쮭�} {2 ����⪨} {3 �������} {4 ���}
Limit    : String[CIZena];
Adress   : String[CAll];
Telefon   : String[CAll];
R_Sh    : String[CAll];
Gde      : String[CAll];
Gorod    : String[CAll];
INN      : String[CAll];
OKONH    : String[CAll];
OKPO     : String[CAll];
Enviropment : String[CAll];
Messages : String[CSertif];
Debit    : Word;
ClientShkala : Word;
SrokLizensia : TDateString;
Test_Srok: String[CArtikul];
Region   : Word;
Prozent  : String[Clitr];
Kod      : String[CClientKod];
Employ   : Boolean;
LockTime : Boolean;
LOCKDATE : TDAteString;
LockTimeCaption : String[CRazdelKod];
Stat     : Boolean;
Locked   : Boolean;
End;








Var b : BakClientType;
    bf : File Of BakClientType;
    c  :ClientType;
    cf :File of ClientType;
    l : Word;

Begin
Assign (bf,ParamStr(1));
l:=IOResult;
Reset(bf);
l:=IOResult;
If l <> 0 Then
 Begin
  Writeln('File As ParamStr(1) not found!');
  Halt;
 End;

Assign (cf,ParamStr(2));
Rewrite(cf);

While Not Eof(bf) Do
Begin

 Read(bf,b);
 With c Do
  Begin
   Name     :=B.Name;
   FullName:=B.Name;
   Dogovor  :=b.Dogovor;
   for l:=1 To 4 Do
   Punkt[l]    :=b.Punkt[l];
   Limit    :=b.Limit;
   Adress   :=b.Adress;
   Telefon  :=b.Telefon;
   R_Sh     :=b.R_Sh;
   Gde      :=b.Gde;
   Gorod    :=b.Gorod;
   INN      :=b.INN;
   OKONH    :=b.OKONH;
   OKPO     :=b.OKPO;
   Enviropment :=b.Enviropment;
   Messages :=b.Messages;
   Debit    :=b.Debit;
   ClientShkala :=b.ClientShkala;
   SrokLizensia :=b.SrokLizensia;
   Kod      :=b.Kod;
   Test_Srok:=b.Test_Srok;
   DelSpace(Test_Srok);
   Prozent  :=b.Prozent;
   locktime :=False;
   Employ   :=b.Employ;
   Stat     :=b.Stat;
   Locked   :=b.Locked;
   Region   :=b.Region;
   LOCKDATE:=FDate;
   LockTimeCaption:=b.LockTimeCaption;
  End;
 Write(cf,c);
End;

Close(bf);
Close(cf);

Writeln('Ok');

End.