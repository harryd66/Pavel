Uses Glob,ServStr,Objects,TpDAte;



Type BakInputRewisiaType = Record
     DivisionS: TRewString{Array[1..CDivision] Of String[CKol+1]};
     Zakupka : String[CZena];
     R_Zena  : String[CZena];
     O_Zena  : String[CZena];
     Kol     : String[CKol+1];
     Caption : String [CRazdelKod];
     Auto : Boolean;
     End;


Type BakRewisiaElement = Record
     BazKod : String[CArtikul];
     Input  : BakInputRewisiaType;
     End;


Type BakRewisiaType = Record
        Element : Array[1..CMax] Of BakRewisiaElement;
        Document: String[CDocNumer];
        Itogo,ItogoPlus,ItogoMinus : String[CIZena];
        ItogoZ,ItogoPlusZ,ItogoMinusZ : String[CIZena];
        SkladKod: String[CClientKod];
        Caption : String [CRazdelKod];
        DateC   : TDateString;
        TimeC   : TDateString;
        DateM   : TDateString;
        TimeM   : TDateString;
        Comment : SertifStr;
        Class   : Word;
        Amount  : Word;
        Locked  : Boolean;
 end;




Type
    PBakRewisiaType = ^BakRewisiaPtr;
    BakRewisiaPtr=Object(TObject)
    Dat  :  BakRewisiaType;
     Constructor Init;
     Destructor  Done; Virtual;
 end;

Constructor BakRewisiaPtr.Init ;
Var i,j : Byte;
Begin
TObject.Init;
 Dat.Locked:=False;
 For i:=1 To CMax Do
  Begin
   {обнуляется приход}
  With Dat.Element[i].Input Do
   Begin
       Kol[0]:=#0;
    Zakupka[0]:=#0;
    R_Zena[0]:=#0;
    O_Zena[0]:=#0;
     {
     NSertif[0] :=#0;
     DSertif[0] :=#0;
     KSertif[0] :=#0;
     Akzis1 [0] :=#0;
       Post [0] :=#0;
     }
   For j:=1 To CDivision Do DivisionS[j,0]:=#0;
   Auto:=False;
   End;
   With Dat.Element[i] Do
   Begin
        BazKod[0]:=#0;
        Dat.Document[0]:=#0;
        Dat.Itogo[0]:=#0;
        Dat.ItogoPlus[0]:=#0;
        Dat.ItogoMinus[0]:=#0;
        Dat.ItogoZ[0]:=#0;
        Dat.ItogoPlusZ[0]:=#0;
        Dat.ItogoMinusZ[0]:=#0;
        Dat.DateC[0]:=#0;
        Dat.TimeC[0]:=#0;
        Dat.DateM:=FDate;
        Dat.TimeM:=CurrentTimeString('hh:mm:ss');
        DAt.Caption:=CurrentPassword;
        DAt.SkladKod:=FormKod(Rek.Kod);
        DAt.Comment[0]:=#0;
        Dat.Amount:=0;
        Dat.Class:=0;
        Dat.Locked:=False;
   End;
  End;
End;

Destructor BakRewisiaPtr.Done;
Begin
TObject.Done;
End;


Var BakFile : File Of BakRewisiaType;
    F :File Of RewisiaType;
    BakPtr :PBakRewisiaType;
    Ptr :PRewisiaType;
    s1,s2:String;
    j,i : Word;

Begin
s1:=ParamStr(1);
Assign(BakFile,s1+'.rwz');
i:=IOResult;
Reset(BakFile);
i:=IOResult;
If I<>0 Then
 Begin
  Writeln('Не могу открыть '+s1+'.rwz');
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
  With Ptr^.Dat Do
   Begin
        Document :=BakPtr^.Dat.Document;
        Itogo:=BakPtr^.Dat.Itogo;
	   ItogoPlus:=BakPtr^.Dat.ItogoPlus;
	   ItogoMinus:=BakPtr^.Dat.ItogoMinus;
        ItogoZ:=BakPtr^.Dat.ItogoZ;
	   ItogoPlusZ:=BakPtr^.Dat.ItogoPlusZ;
	   ItogoMinusZ:=BakPtr^.Dat.ItogoMinusZ;
        SkladKod:=BakPtr^.Dat.SkladKod;
        Caption :=BakPtr^.Dat.Caption;
        DateC   :=BakPtr^.Dat.DateC;
        TimeC   :=BakPtr^.Dat.TimeC;
        DateM   :=BakPtr^.Dat.DateM;
        TimeM   :=BakPtr^.Dat.TimeM;
        Amount  :=BakPtr^.Dat.Amount;
        Locked  :=BakPtr^.Dat.Locked;
         Comment:=BakPtr^.Dat.Comment;
         Class:=BakPtr^.Dat.Class;

 For i:=1 To CMax Do
  Begin
  With Element[i].Input Do
   Begin
       Kol:=BakPtr^.Dat.Element[i].Input.Kol;
    R_Zena:=BakPtr^.Dat.Element[i].Input.R_Zena;
    Zakupka:=BakPtr^.Dat.Element[i].Input.Zakupka;
    O_Zena:=BakPtr^.Dat.Element[i].Input.O_Zena;
    Osn.NaklNumer[0]:=#0;
    Osn.DateNakl[0]:=#0;

   For j:=1 To CDivision Do Divisions[j]:=BakPtr^.Dat.Element[i].Input.Divisions[j];


   Auto:=BakPtr^.Dat.Element[i].Input.Auto;

   End;
   Element[i].BazKod:=BakPtr^.Dat.Element[i].BazKod;
  End;{For}

   End;
   seek(f,filesize(f));
   Write(f,ptr^.dat);
 End;

Dispose(BakPtr,Done);
Dispose(Ptr,Done);

Close(BakFile);
Close(f);

Rename(BakFile,s1+'.bak');
Rename(F,s1+'.rwz');
Writeln('All ok');

End.