
Uses Serv,ServSTr,glob;

Type OldBazType = Record
     Name  : String[CName];
     Name2 : String[CName];
     Litr  : String[CLitr];
     InPack: String[CInPack];
    InPack2: String[CInPack];
     OKP   : LongInt{String[COKP]};
     Massa : String[CMassa];
 BuchGroup : LongInt;
     Etil  : String[CLitr];
     Market: Word;
   EnableDebit: Word;  {ࠧ�襭�� ���ᨣ��樨}
     VidNalog : Word; { ��� ������ 0=5% 1=3% 2=��祥}
     Nalog    : String[CLitr];
     VidNDS   : Word; { ��� ��� 0=20% 1=10% 2=��祥}
     NDS      : String[CLitr];
     Mera     : String[CMera];
     EnableContract : Word;
     Contract : String[CContract];
 ContractDate : String[CDate];
     EnableSklads : Word;
     KSertif : String[CKSertif];
     DSertif : String[CDSertif];
     BazKod  : String[CArtikul];
     Employ: Boolean;
    Caption: String[CRazdelKod];
LockCaption: String[CRazdelKod];
ComputerNameLocked : String[CCNAme];
     Locked: Boolean;
     End;

     Var f : File Of OLDBAzType;
         ff : OLdBazType;
         c : Word;

Begin

Assign(f,ParamStr(1));
Reset(f);

c:=0;
While Not(Eof(f))Do
 Begin
  Read(f,ff);
  ff.BazKod:=IntToStr(C,3);
  RFormatZerro(ff.BazKod,3);
  ff.BazKod:=ParamStr(2)+ff.BazKod;

  Seek(f,FilePos(f)-1);
  Write(f,ff);

 End;

Close(f);

End.