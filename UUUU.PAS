Uses ServStr;

Type
FaktBazType = Record
    Name  : String[CName];
    Name2 : String[CName];
    Litr  : String[CLitr];
    InPack: String[CInPack];
  VidNDS   : Word; { вид НДС 0=20% 1=10% 2=прочее}
     NDS      : String[CLitr];
  VidNalog: Word;
    Nalog : String[CLitr];
    BazKod: String[CArtikul];
    Zena  : String[CZena];
    Employ: Boolean;
    Stat  : Boolean;
   End;

Type Element1 = Record
Kol     : String[CKol];
Zena    : String[CZena];
Artikul : String[CArtikul];
End;

Type Shet = Record
Numer  : String[CKol+1];
Dat    : String[CDate];
Bn     : Word;
Sklad  : String[COne];
Client : String[CClientKod];
Pos    : Array[1..60] Of Element1;
ItogoN : String[CIZena];
ItogoN5: String[CIZena];
ItogoN3: String[CIZena];
ItogoN_: String[CIZena];
ItogoZ : String[CIZena];
ItogoL : String[CILitr];
end;


Var E : File Of FaktBazType;
    EE : FaktBazType;
    c : Word;
    ss : AllStr;

Begin
Assign(e,ParamStr(1));
Rewrite(e);

For c:=0 to 999 Do
Begin
  Read(e,ee);
  With EE Do
  Begin
   ss:=IntToStr(c,3);
   RFormatZerro(ss,3);
   Name  :='';
   Litr  :='';
   InPack:='';
   VidNalog:=0;
   Nalog :='5.00';
   BazKod:=ParamStr(2)+ss;
   Zena  :='';
   Employ:=False;
   Stat  :=False;
  End;
  Write(e,EE);
End;

Close(e);

End.