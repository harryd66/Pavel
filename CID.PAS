Uses Glob,Serv,Utils,ServStr,Objects;

Type BakBazType = Record
     Name  : String[CName];
     Name2 : String[CName];
     FullName : String[CName];
     FullName2 : String[CName];
    Minimum: String[CArtikul];
 MinNazenka: String[CLitr+1];
     Litr  : String[CLitr];
     InPack: String[CInPack];
     Marker: String[CInPack];
     Market: Word;
     VidNalog : Word; { вид налога 0=5% 1=3% 2=прочее}
     Nalog    : String[CLitr];
     VidNDS      : Word; { вид НДС 0=20% 1=10% 2=прочее}
     NDS         : String[CLitr];
     EnableOtdel : Word;
     Mera   : Word; {0 - шт 1- кг 2-л}
     BazKod: String[CArtikul];
     DostProc: String[CKOl];
     Vol: String[CVol];
     Employ: Boolean;
    Caption: String[CRazdelKod];
LockCaption: String[CRazdelKod];
     Stat  : Boolean;
     Locked: Boolean;
     ZapretOpt: Boolean;
     End;


Type PBakBazType = ^BakBazTypePtr;
     BakBazTypePtr = Object(TObject)
     Dat : BakBazType;
     Constructor Init;
     Destructor Done; Virtual;
     End;


Constructor BakBazTypePtr.Init ;
Begin
TObject.Init;
With Dat Do
 Begin
     Name[0]:=#0;
     FullName[0]:=#0;
     Name2[0]:=#0;
     FullName2[0]:=#0;
     Litr:='0.000';
     InPack[0]:=#0;
     BazKod[0]:=#0;
     Employ:=False;
     Market:=0;
     MinNazenka:='1.000';

     VidNalog:=0;
     Nalog:='5.00';

     VidNDS:=0;
     NDS:='20.00';
     EnableOtdel:=31;

     Mera:=0 {шт};
     DostProc:='0.00';
     Vol[0]:=#0;
     Stat:=False;
     Locked:=False;
     CAption:=CurrentPassword;
     LockCaption[0]:=#0;
     ZapretOpt:=false;
 End;
End;

Destructor BakBazTypePtr.Done;
Begin
TObject.Done;
End;

Var BakFile : File Of BakBazType;
    f : File Of BazType;
    BakPtr :  PBakBazType;
    Ptr    : PBazType;
    s1,s2,s3 : String;
    wspom : Word;
    MMM8 : MaskaNew;
    l,c,i : Word;
Begin
s1:=ParamStr(1);
Assign(BakFile,s1+'.id');
i:=IOResult;
Reset(BakFile);
i:=IOResult;
If I<>0 Then
 Begin
  Writeln('Не могу открыть '+s1+'.id');
  Halt;
 End;

Assign(F,s1+'.new');
i:=IOResult;
Rewrite(F);
i:=IOResult;
If I<>0 Then
 Begin
  Close(BakFile);
  Writeln('Не могу создать '+s1+'.new');
  Halt;
 End;

New(BakPtr,Init);
New(Ptr,Init);

While Not(Eof(BakFile)) Do
 Begin
  Read(BakFile,BakPtr^.Dat);
  If IOResult<>0 Then
   Begin
    Writeln('Read Error');
    Halt;
   End;
   With Ptr^.Dat Do
   Begin
     Name  :=BakPtr^.Dat.Name;
     Name2 :=BakPtr^.Dat.Name2;
     FullName :=BakPtr^.Dat.FullName;
     FullName2 :=BakPtr^.Dat.FullName2;
    Minimum:=BakPtr^.Dat.Minimum;
 MinNazenka:=BakPtr^.Dat.MinNazenka;
     Litr  :=BakPtr^.Dat.Litr;
     InPack:=BakPtr^.Dat.InPack;
     Marker:=BakPtr^.Dat.Marker;
     Market:=BakPtr^.Dat.Market;
     VidNalog :=BakPtr^.Dat.VidNalog; { вид налога 0=5% 1=3% 2=прочее}
     Nalog    :=BakPtr^.Dat.Nalog;
     VidNDS      :=BakPtr^.Dat.VidNDS; { вид НДС 0=20% 1=10% 2=прочее}
     NDS         :=BakPtr^.Dat.NDS;
     EnableOtdel :=BakPtr^.Dat.EnableOtdel;
     Mera   :=BakPtr^.Dat.Mera; {0 - шт 1- кг 2-л}
     BazKod:=BakPtr^.Dat.BazKod;
     DostProc:=BakPtr^.Dat.DostProc;
     Vol:=BakPtr^.Dat.Vol;
     Employ:=BakPtr^.Dat.Employ;
    Caption:=BakPtr^.Dat.Caption;
LockCaption:=BakPtr^.Dat.LockCaption;
     Stat  :=BakPtr^.Dat.Stat;
     Locked:=BakPtr^.Dat.Locked;
     ZapretOpt:=BakPtr^.Dat.ZapretOpt;
     Realiz:=false;
   End;
   Write(f,ptr^.dat);
 End;


Dispose(BakPtr,Done);
Dispose(Ptr,Done);
Close(BakFile);
Close(f);

Rename(BakFile,s1+'.bak');
Rename(F,s1+'.id');
End.