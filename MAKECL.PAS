Uses Glob,Serv,ServStr;

{Клиент}
Type BakClientType = Record
Name     : String[CClient];
FullName : String[CAll];
Dogovor  : String[CAll];
Punkt    : Array [1..4] Of String[CRazdelKod];
{1 Павильоны} {2 Палатки} {3 Магазин} {4 Кафе}
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
NoLimit  : Word;
ClientShkala : Word;
SrokLizensia : TDateString;
Test_Srok: String[CArtikul];
Region   : Word;
Prozent  : String[Clitr];
AgentKod : ArtikulStr;
Kod      : String[CClientKod];
Employ   : Boolean;
LockTime : Boolean;
LOCKDATE : TDAteString;
LockTimeCaption : String[CRazdelKod];
Stat     : Boolean;
Locked   : Boolean;
End;

Var b : MakeType;
    bf : File Of MakeType;
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
l:=IOResult;
Rewrite(cf);
l:=IOResult;
While Not Eof(bf) Do
Begin
l:=IOResult;
 Read(bf,b);
 With c Do
  Begin
   Name     :=B.Name;
   FullName :='';
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
   NoLimit  :=0;
   ClientShkala :=b.ClientShkala;
   SrokLizensia :=b.SrokLizensia;
   Kod      :=b.Kod;
   Test_Srok:=b.Test_Srok;
   DelSpace(Test_Srok);
   AgentKod :='';
   Prozent  :='';
   locktime :=False;
   Employ   :=b.Employ;
   Stat     :=b.Stat;
   Locked   :=b.Locked;
   Region   :=0;
   LOCKDATE:=FDate;
   LockTimeCaption:='';
   Opt:=false;
  End;
 l:=IOResult;
 Write(cf,c);
 l:=IOResult;
End;

l:=IOResult;
Close(cf);
l:=IOResult;
Close(bf);
l:=IOResult;

Writeln('Ok');

End.