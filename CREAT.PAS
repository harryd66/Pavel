Uses Glob,ServStr,Objects,TpDate;

{Информация по наименованию}
Type BakInputType = Record
     DivisionS: TKolString;
     {Group   : }
     NGroupKod: String[CClientKod];{Это поле указывает на код группы которой прин.товар}
     Zakupka : String[CZena];
     R_Zena  : String[CZena];
     O_Zena  : String[CZena];
     NSertif : String[CNSertif];
     DSertif : String[CDSertif];
     KSertif : String[CKSertif];
{  Sertifikat : String[CSertif];}
     Akzis1  : String[CAkzis1];
       Post  : String[CPost];
     Kol     : String[CKol];
     Caption : String[CRazdelKod];
        Auto : Boolean;
     End;


Type BakSkladType = Record
     BazKod  : String[CArtikul];
     MakeKod : String[CMakeKod];
     MakeVid : Word;
     Input   : BakInputType;
     Employ  : Boolean;
     Date    : TDateString;
     Time    : TDateString;
     Tip     : Word;
     Analys  : Boolean;
     Locked  : Boolean;


   End;


Type
    PBakSkladType = ^BakSkladPtr;
    BakSkladPtr=Object(TObject)
    Dat  :  BakSkladType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Constructor BakSkladPtr.Init ;
Begin
TObject.Init;
     Dat.MakeKod[0] :=#0;
     Dat.MakeVid:=0;
     Dat.Date:=FDate;
     Dat.Time:=CurrentTimeString('hh:mm:ss');
     Dat.Tip    :=0;
     Dat.Analys :=False;
     Dat.Locked :=False;
     Dat.Employ :=False;
 With Dat.Input Do
  Begin
     NSertif [0]:=#0;
     Akzis1  [0]:=#0;
     Kol     :='0';
     Zakupka :='0.00';
     R_Zena  :='0.00';
     O_Zena  :='0.00';
     Caption :=CurrentPassword;
     Auto:=False;
  End;

End;


Destructor BAkSkladPtr.Done;
Begin
TObject.Done;
End;


Var fskl : File Of BakSkladtype;
    skl : PBakSkladType;
    idf : File Of BazType;
    id  : PBazType;
    skidf : File Of SkidkaType;
    skid : PSkidkaType;
     cl  : PClientType;

       st : String;
       st1 : String;
       j,c : Word;
    fcl : File Of ClientType;


Begin
For j:=0 to 99 Do
BEgin
 Str(j:2,St1);
 RFormatZerro(st1,2);

Assign(fskl,st1+'.db');
Rewrite(fskl);
Assign(idf,st1+'.id');
Rewrite(idf);

Assign(skidf,st1+'.skl');
Rewrite(skidf);
New(Skl,Init);
New(Id,Init);
New(Skid,Init);

 For c:=0 To 999 Do
  Begin
   Str(c:3,St);
   RFormatZerro(st,3);
   Skl^.DAt.BazKod:=st1+st;
   Id^.DAt.BazKod:=st1+st;
   Skid^.DAt.BazKod:=st1+st;

   Seek(FSkl,FileSize(FSkl));
   Write(FSkl,Skl^.Dat);

   Seek(idf,FileSize(idf));
   Write(idf,Id^.Dat);

   Seek(Skidf,FileSize(SkidF));
   Write(SkidF,Skid^.Dat);
  End;

Close(fskl);
Close(idf);

Close(skidf);

Dispose(Skl,Done);
Dispose(Id,Done);
Dispose(skid,Done);
End;

Assign(fcl,'client.db');
Rewrite(fcl);
 For c:=0 To 1000 Do
  Begin
   Str(c:4,St);
   RFormatZerro(st,4);
   New(cl,Init);
   Cl^.DAt.Kod:=st;
   Cl^.DAt.Employ:=False;

   If c=0 Then
    Begin
     Cl^.DAt.Employ:=True;
     Cl^.DAt.Name:='+';
    End;

   If c=281 Then
    Begin
     Cl^.DAt.Employ:=True;
     Cl^.DAt.Name:='+';
    End;

   If c=282 Then
    Begin
     Cl^.DAt.Employ:=True;
     Cl^.DAt.Name:='+';
    End;


   If c=283 Then
    Begin
     Cl^.DAt.Employ:=True;
     Cl^.DAt.Name:='+';
    End;

   If c=999 Then
    Begin
     Cl^.DAt.Employ:=True;
     Cl^.DAt.Name:='+';
    End;

   Seek(Fcl,FileSize(Fcl));
   Write(Fcl,Cl^.Dat);
   Dispose(Cl,Done);
  End;
Close(fcl);


Assign(fcl,'make.db');
Rewrite(fcl);
 For c:=0 To 250 Do
  Begin
   Str(c:4,St);
   RFormatZerro(st,4);
   New(cl,Init);
   Cl^.DAt.Kod:=st;
   Cl^.DAt.Employ:=False;

    If c=0 Then
    Begin
     Cl^.DAt.Employ:=True;
     Cl^.DAt.Name:='ПРОБНЫЙ';
    End;

   Seek(Fcl,FileSize(Fcl));
   Write(Fcl,Cl^.Dat);
   Dispose(Cl,Done);
  End;
Close(fcl);

Assign(fcl,'barter.db');
Rewrite(fcl);
 For c:=0 To 250 Do
  Begin
   Str(c:4,St);
   RFormatZerro(st,4);
   New(cl,Init);
   Cl^.DAt.Kod:=st;
   Cl^.DAt.Employ:=False;

   If c=0 Then
    Begin
     Cl^.DAt.Employ:=True;
     Cl^.DAt.Name:='ПРОБНЫЙ';
    End;

   Seek(Fcl,FileSize(Fcl));
   Write(Fcl,Cl^.Dat);
   Dispose(Cl,Done);
  End;
Close(fcl);

Assign(fcl,'sklad.db');
Rewrite(fcl);
 For c:=0 To 50 Do
  Begin
   Str(c:4,St);
   RFormatZerro(st,4);
   New(cl,Init);
   Cl^.DAt.Kod:=st;
   Cl^.DAt.Employ:=False;

   If c=1 Then
    Begin
     Cl^.DAt.Employ:=True;
     Cl^.DAt.Name:='СКЛАД 1';
    End;

   Seek(Fcl,FileSize(Fcl));
   Write(Fcl,Cl^.Dat);
   Dispose(Cl,Done);
  End;
Close(fcl);

Assign(fcl,'lizo.db');
Rewrite(fcl);
 For c:=0 To 50 Do
  Begin
   Str(c:4,St);
   RFormatZerro(st,4);
   New(cl,Init);
   Cl^.DAt.Kod:=st;
   Cl^.DAt.Employ:=False;

   If c=1 Then
    Begin
     Cl^.DAt.Employ:=True;
     Cl^.DAt.Name:='ЛИЦО 1';
    End;

   Seek(Fcl,FileSize(Fcl));
   Write(Fcl,Cl^.Dat);
   Dispose(Cl,Done);
  End;
Close(fcl);


End.