Uses Glob,ServStr,Objects,TpDAte;


Type TBakKolString = Array [1..5] Of String[CKol];

Type BakInputPrihodType = Record
     Division: TBakKolString;
     Zakupka : String[CZena];
     R_Zena  : String[CZena];
     O_Zena  : String[CZena];
     AutoSkidka: TAutoString;
     NSertif : String[CNSertif];
     DSertif : String[CDSertif];
     KSertif : String[CKSertif];
{  Sertifikat : String[CSertif];}
     Akzis1  : String[CAkzis1];
       Post  : String[CPost];
     Kol     : String[CKol];
     Caption : String [CRazdelKod];
        Auto : Boolean;
     End;



{информация по приходу наименования}
Type BakElement = Record
     BazKod : String[CArtikul];
     Input  : BakInputPrihodType;
     End;


{Приход}
Type BakPrihodType = Record
     OperatorSelector:Word;
     MakeKod : String[CMakeKod];
     PrihodElement : Array[1..CMax] Of BakElement;
     Document : String[CDocNumer];
     DocumentPrz : String[CDocNumer]; {позиция в файле переоценки, а не номер акта переоценки
	                                  это две большие разницы}
     SummaL,SummaR,SummaO,SummaZakupka : String[CIZena];
    SkladKod : String[CClientKod];
     Caption : String[CRazdelKod];
     DateC   : TDateString;
     TimeC   : TDateString;
     DateM   : TDateString;
     TimeM   : TDateString;
     Amount  : Word;
   StatusDoc : Word; {1 : Буфер; 0 :Документ попал на склад}
     Locked  : Boolean;
 end;




Type
    PBakPrihodType = ^BakPrihodPtr;
    BakPrihodPtr=Object(TObject)
    Dat  :  BakPrihodType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Constructor BakPrihodPtr.Init ;
Var i,j : Byte;
Begin
TObject.Init;
 Dat.Locked:=False;
 For i:=1 To CMax Do
  Begin
   {обнуляется приход}
  With Dat.PrihodElement[i].Input Do
   Begin
   Zakupka[0]:=#0;
       Kol[0]:=#0;
    R_Zena[0]:=#0;
    O_Zena[0]:=#0;
 NSertif[0]:=#0;
DSertif[0]:=#0;
 KSertif[0]:=#0;
{Sertifikat[0]:=#0;}
     Akzis1[0]:=#0;
     Post [0]:=#0;
   For j:=1 To 5 Do Division[j,0]:=#0;
   For j:=1 To CShkala Do AutoSkidka[j,0]:=#0;
   Auto:=False;
   End;
   With Dat.PrihodElement[i] Do
   Begin
    BazKod[0]:=#0;
     Dat.OperatorSelector:=0;
     Dat.MakeKod[0]:=#0;
     Dat.Document[0]:=#0;
     Dat.DocumentPrz[0]:=#0;
     Dat.SummaL[0]:=#0;
     Dat.DateC[0]:=#0;
     Dat.TimeC[0]:=#0;
     Dat.DateM:=FDate;
     Dat.TimeM:=CurrentTimeString('hh:mm:ss');
     Dat.SummaR[0]:=#0;
     Dat.SummaO[0]:=#0;
     Dat.SummaZakupka[0]:=#0;
     DAt.Caption:=CurrentPassword;
        DAt.SkladKod:=FormKod(Rek.Kod);
        Dat.Amount:=0;
   End;
  End;
End;

Destructor BakPrihodPtr.Done;
Begin
TObject.Done;
End;



Var BakFile : File Of BakPrihodType;
    F :File Of PrihodType;
    BakPtr :PBakPrihodType;
    Ptr :PPrihodType;
    s1,s2:String;
    j,i : Word;

Begin
s1:=ParamStr(1);
Assign(BakFile,s1+'.prh');
i:=IOResult;
Reset(BakFile);
i:=IOResult;
If I<>0 Then
 Begin
  Writeln('Не могу открыть '+s1+'.prh');
  Halt;
 End;

Assign(F,s1+'.new');
i:=IOResult;
Rewrite(F);
i:=IOResult;
If I<>0 Then
 Begin
  Close(BakFile);
  Writeln('Не могу создать '+s1+'.prh');
  Halt;
 End;

New(BakPtr,Init);
New(Ptr,Init);

While Not(Eof(BakFile)) Do
 Begin
  Read(BakFile,BakPtr^.Dat);
  With Ptr^.Dat Do
   Begin
     OperatorSelector:=BakPtr^.Dat.OperatorSelector;
     MakeKod:=BakPtr^.Dat.MakeKod;
     Document:=BakPtr^.Dat.Document;
     DocumentPrz:=BakPtr^.Dat.DocumentPrz;
     SummaL:=BakPtr^.Dat.SummaL;
	SummaR:=BakPtr^.Dat.SummaR;
	SummaO:=BakPtr^.Dat.SummaO;
	SummaZakupka:=BakPtr^.Dat.SummaZakupka;
    SkladKod:=BakPtr^.Dat.SkladKod;
     Caption:=BakPtr^.Dat.Caption;
     DateC  :=BakPtr^.Dat.DateC;
     TimeC  :=BakPtr^.Dat.TimeC;
     DateM  :=BakPtr^.Dat.DateM;
     TimeM  :=BakPtr^.Dat.TimeM;
     Amount :=BakPtr^.Dat.Amount;
   StatusDoc:=BakPtr^.Dat.StatusDoc;
     Locked :=BakPtr^.Dat.Locked;

 For i:=1 To CMax Do
  Begin

  With PrihodElement[i].Input Do
   Begin
    Zakupka :=BakPtr^.Dat.PrihodElement[i].Input.Zakupka;
     R_Zena  :=BakPtr^.Dat.PrihodElement[i].Input.R_Zena;
     O_Zena  :=BakPtr^.Dat.PrihodElement[i].Input.O_Zena;
     AutoSkidka:=BakPtr^.Dat.PrihodElement[i].Input.AutoSkidka;
     NSertif :=BakPtr^.Dat.PrihodElement[i].Input.NSertif;
     DSertif :=BakPtr^.Dat.PrihodElement[i].Input.DSertif;
     KSertif :=BakPtr^.Dat.PrihodElement[i].Input.KSertif;
     Akzis1  :=BakPtr^.Dat.PrihodElement[i].Input.Akzis1;
       Post  :=BakPtr^.Dat.PrihodElement[i].Input.Post;
     Kol     :=BakPtr^.Dat.PrihodElement[i].Input.Kol;
     Caption :=BakPtr^.Dat.PrihodElement[i].Input.Caption;
        Auto :=BakPtr^.Dat.PrihodElement[i].Input.Auto;

   For j:=1 To 5 Do Divisions[j]:=BakPtr^.Dat.PrihodElement[i].Input.Division[j];

   Divisions[6,0]:=#0;
   Divisions[7,0]:=#0;
   Divisions[8,0]:=#0;

   End;

   PrihodElement[i].BazKod:=BakPtr^.Dat.PrihodElement[i].BazKod;
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
Rename(F,s1+'.prh');
Writeln('All ok');
End.