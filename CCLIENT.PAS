Uses Glob,Serv,ServStr;

{Клиент}
Type BakClientType = Record
Name     : String[CClient];
FullName : String[CAll];
Dogovor  : String[CAll];
Punkt    : Array [1..4] Of String[CRazdelKod];
{1 Срок оплаты} {2 Дост/Самовывоз} {3 Магазин} {4 Маршруты}
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
AgentKod : array [1..2] of ArtikulStr;
Kod      : String[CClientKod];
Employ   : Boolean;
LockTime : Boolean;
LOCKDATE : TDAteString;
LockTimeCaption : String[CRazdelKod];
Stat     : Boolean;
Locked   : Boolean;
Opt: Boolean;
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
FullName :=B.FullName;
Dogovor  :=B.Dogovor;
for l:=1 to 4 do
Punkt[l]:=B.Punkt[l];
Limit    :=B.Limit;
Adress   :=B.Adress;
Telefon   :=B.Telefon;
R_Sh    :=B.R_Sh;
Gde      :=B.Gde;
Gorod    :=B.Gorod;
INN      :=B.INN;
OKONH    :=B.OKONH;
OKPO     :=B.OKPO;
Enviropment :=B.Enviropment;
Messages :=B.Messages;
Debit    :=B.Debit;
NoLimit  :=B.NoLimit;
ClientShkala :=B.ClientShkala;
SrokLizensia :=B.SrokLizensia;
Test_Srok:=B.Test_Srok;
Region   :=B.Region;
Prozent  :=B.Prozent;
for l:=1 to 2 do
AgentKod[l]:=B.AgentKod[l];
Kod      :=B.Kod;
Employ   :=B.Employ;
LockTime :=B.LockTime;
LOCKDATE :=B.LOCKDATE;
LockTimeCaption :=B.LockTimeCaption;
Stat     :=B.Stat;
Locked   :=B.Locked;
Opt:=B.Opt;
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