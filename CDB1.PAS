Uses Glob,ServStr,Serv,Objects,TpDAte;


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
RealizovatDo : String[CDAte];
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


Var BakFile : File Of BakSkladType;
    F :File Of SkladType;
    BakPtr :PBakSkladType;
    Ptr :PSkladType;
    s1,s2:String;
    c,i : Word;


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
  Read(BakFile,BakPtr^.Dat);
  With Ptr^.Dat Do
   Begin
     BazKod  :=BakPtr^.Dat.BazKod;
     MakeKod :=BakPtr^.Dat.MakeKod;
     MakeVid :=BakPtr^.Dat.MakeVid;

     With Ptr^.Dat.Input Do
      Begin
       For c:=1 to 8 Do Divisions[c]:=BakPtr^.Dat.Input.Divisions[c];

     R_Zena  :=BakPtr^.Dat.Input.R_Zena  ;
     O_Zena  :=BakPtr^.Dat.Input.O_Zena  ;
     Zakupka :=BakPtr^.Dat.Input.Zakupka;;
     NSertif :=BakPtr^.Dat.Input.NSertif;
     Akzis1  :=BakPtr^.Dat.Input.Akzis1;;
     Post    :=BakPtr^.Dat.Input.Post;
     DSertif :=BakPtr^.Dat.Input.DSertif;
     KSertif :=BakPtr^.Dat.Input.KSertif;
     Kol     :=BakPtr^.Dat.Input.Kol     ;
     Caption :=BakPtr^.Dat.Input.Caption;
     NGroupKod:=BakPtr^.Dat.Input.NGroupKod;
     RealizovatDo:=BakPtr^.Dat.Input.RealizovatDo;
     Osn.NaklNumer[0]:=#0;
     Osn.DateNakl[0]:=#0;
     Auto :=BakPtr^.Dat.Input.Auto;
      End;
     Employ  :=BakPtr^.Dat.Employ;
     Date    :=BakPtr^.Dat.Date;
     Time    :=BakPtr^.Dat.Time;
     Tip     :=BakPtr^.Dat.Tip;
     Analys  :=BakPtr^.Dat.Analys;
     Locked  :=BakPtr^.Dat.Locked;
   End;
   seek(f,filesize(f));
   Write(f,ptr^.dat);
 End;

Dispose(BakPtr,Done);
Dispose(Ptr,Done);
Close(BakFile);
Close(f);

Rename(BakFile,s1+'.bak');
Rename(F,s1+'.db');

Writeln('All Ok');

End.