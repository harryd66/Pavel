Uses Glob,ServStr,Serv,Objects,TpDAte,vision1;


Type BAkInputType = Record
	  Division: TKolString;
      DivisionR: TKolString;
       USD     : Word;
       GRZena  : String[CZenaZ];
       Proz    : String[CLitr];
	  Zakupka : String[CZenaZ];
       Zakupka2: String[CZenaZ];
       NMakeKod: String[CArtikul];{Это поле указывает на код поставщика}
	  R_Zena  : String[CZena];
	  O_Zena  : String[CZena];
     Spec_Zena : String[CZena];
      StrihKod : String[CStrihKod];
    Virabotano : String[CDSertif];
	  NSertif : String[CArtikul];{Это поле указывает на код сертификата}
    RegionMarka: Word;

      AkzisSbor: String[CZenaZ];
      ZenaMarki: String[CZenaZ];
	  Kol     : String[CKol];
	  KolR    : String[CKol];
	  Caption : String[CRazdelKod];
	     Auto : Boolean;
	  End;



Type BAkSkladType = Record
     BazKod      : String[CArtikul];
     MakeKod     : String[CMakeKod];
     MakeVid     : Word;
     Input       : BakInputType;
     EnableDebit : Word;
     Employ      : Boolean;
     Date        : LongInt{TDateString};
     Time        : LongInt{TDateString};
     Locked      : Boolean;
   End;





Type
    PBakSkladType = ^BakSkladPtr;
    BakSkladPtr=Object(TObject)
    Dat  :  BakSkladType;
     Constructor Init;
     Destructor Done; Virtual;
 end;





Constructor BakSkladPtr.Init ;
var j : byte;
Begin
TObject.Init;
     Dat.MakeKod[0] :=#0;
     Dat.MakeVid:=0;
     Dat.Date:=ToDay;
     Dat.Time:=CurrentTime;
     Dat.Locked :=False;
     Dat.Employ :=False;
     Dat.EnableDebit :=1;
 With Dat.Input Do
  Begin
     NSertif :=NoSertifStr;
        Kol     :='0';
     For j:=1 To CDivision Do Division[j,0]:=#0;


     Zakupka :='0.00';
     R_Zena  :='0.00';
     O_Zena  :='0.00';
     Caption :=CurrentPassword;
     Auto:=False;
  End;

End;

Destructor BakSkladPtr.Done;
Begin
TObject.Done;
End;






Var BakFile : File Of BakSkladType;
    F :File Of SkladType;
    BakPtr :PBakSkladType;
    Ptr :PSkladType;
    s1,s2:String;
    c1,c,i : Word;
    All : LongInt;


Begin
s1:=ParamStr(1);
Assign(BakFile,s1+'.db');
i:=IOResult;
Reset(BakFile);
i:=IOResult;
If I<>0 Then
 Begin
  Writeln('Не могу открыть '+s1+'.db');
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
  c:=IOResult;
  Read(BakFile,BakPtr^.Dat);
  c:=IOResult;
  If c<>0 Then
  Begin
   i:=FilePos(f);
   Writeln('Ошибка чтения c',c:4);
  End;


  With Ptr^.Dat Do
   Begin
     BazKod  :=BakPtr^.Dat.BazKod;
     MakeKod :=BakPtr^.Dat.MakeKod;
     MakeVid :=BakPtr^.Dat.MakeVid;


     With Ptr^.Dat.Input Do
      Begin
      Division:=BakPtr^.Dat.Input.Division;
      DivisionR:=BakPtr^.Dat.Input.DivisionR;

      All:=0;
      For c:=1 To CDivision Do
      Begin
       All:=All+StrToInt(BakPtr^.Dat.Input.Division[c]);
      End;
      Kol :=IntToStr(All,CKOl);;
      DelSpace(Kol);


      All:=0;
      For c:=1 To CDivision Do
      Begin
       All:=All+StrToInt(BakPtr^.Dat.Input.DivisionR[c]);
      End;
      KolR :=IntToStr(All,CKOl);;
      DelSpace(KolR);



     R_Zena := BakPtr^.Dat.Input.R_Zena;
     O_Zena := BakPtr^.Dat.Input.O_Zena;
     Spec_Zena := BakPtr^.Dat.Input.Spec_Zena;
     MyStr(StrToReal(BakPtr^.Dat.Input.Zakupka),CZenaZ,CMantissaZ,Ptr^.Dat.Input.Zakupka);
       DelSpace(Ptr^.Dat.Input.Zakupka);
     MyStr(StrToReal(BakPtr^.Dat.Input.Zakupka2),CZenaZ,CMantissaZ,Ptr^.Dat.Input.Zakupka2);
       DelSpace(Ptr^.Dat.Input.Zakupka2);


     Proz:=BakPtr^.Dat.Input.Proz;
     USD:=BakPtr^.Dat.Input.USD;
     GRZena:=BakPtr^.Dat.Input.GRZena;

     RegionMarka:=BakPtr^.Dat.Input.RegionMarka;
     StrihKod :=BakPtr^.Dat.Input.StrihKod;
     Caption :=BakPtr^.Dat.Input.Caption;
        Auto :=BakPtr^.Dat.Input.Auto;
     NSertif:=BakPtr^.Dat.Input.NSertif;
     NMakeKod:=BakPtr^.Dat.Input.NMakeKod;
     NGroupKod:='0000';
     Virabotano :=BakPtr^.Dat.Input.Virabotano;
     AkzisSbor:=BakPtr^.Dat.Input.AkzisSbor;
     ZenaMarki:=BakPtr^.Dat.Input.ZenaMarki;
      End;


     EnableDebit:=BakPtr^.Dat.EnableDebit;
     Employ  :=BakPtr^.Dat.Employ;
     Date    :=BakPtr^.Dat.Date;
     Time    :=BakPtr^.Dat.Time;
     Locked  :=BakPtr^.Dat.Locked;
   End;
  c:=IOResult;
   Write(f,ptr^.dat);
  c:=IOResult;






  If c<>0 Then
  Begin
   Writeln('Ошибка Записи2 c',c:4);
  End;
 End;

Dispose(BakPtr,Done);
Dispose(Ptr,Done);
Close(BakFile);
Close(f);

Rename(BakFile,s1+'.bak');
Rename(F,s1+'.db');

Writeln('All ok');

End.