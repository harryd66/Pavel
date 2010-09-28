Uses Glob,Serv,Servstr,Dialogs,Objects;

Type BazType = Record
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
   EnableDebit: Word;  {разрешение консигнации}
     VidNalog : Word; { вид налога 0=5% 1=3% 2=прочее}
     Nalog    : String[CLitr];
     VidNDS   : Word; { вид НДС 0=20% 1=10% 2=прочее 3=18%}
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

Type RazdelType = Record
      Name       : String[CRazdelName];
     {Designation: String[CDate];}
      EnableDoc : Word;{флаг предназначен для того чтобы
                         распознать для чего используется
     			     раздел}
      EnableLitr : Word;
      Skidka     : Array [1..CShkala] of Shkala;
      Kod        : String[CRazdelKod];
      Employ     : Boolean;
      Locked     : Boolean;
     End;

{Регион}
Type BakRegionType = Record
RegionName: String[CNAme];
Kod       : String[CClientKod];
Employ   : Boolean;
RCD      : Boolean;
Locked   : Boolean;
LockCaption: String[CRAzdelKod];
ComputerNameLocked : String[CCNAme];
End;


Type BakInputExtend =Record
	  NGTD    : String[CNSertif];
	    Post  : String[CPost];
    FirmaPost  : String[CFirmaPost];
	  Marka   : String[CNSertif];
	  Godnost : String[CDSertif];
     SpecMarka : String[CSpecMArka];
	  Akzis1  : String[CAkzis1];{Это поле примечания}
	  Ex      : String[CName];{Это поле примечания}
    {LastPrihod : LongInt;{поле фиксирующее дату последнего приход в позицию}
 End;


Type BakExtSkladType = Record
     BazKod  : String[CArtikul];
     Input       : BakInputExtend;
   End;



Var f: File Of PostType;
    ff: File Of FirmaPostType;
    E: PPostType;
    Ef: PFirmaPostType;
    fff: File Of KSertifType;
    Eff: PKSertifType;
    fffm: File Of MeraType;
    Efm: PMeraType;
    c : LongInt;
    txt : Text;
    SArt : ArtikulStr;
    s : String;
    MaxExpert,MaxNGTD,MaxSMarka,MaxMarka,MaxM,MAx,MaxF,MaxS: LongInt;
    fr : File Of RazdelType;
    RazdelElement: RazdelType;
    fe : File Of BakExtSkladType;
    el : BakExtSkladType;

    Idf : File Of BazType;
    Id : BazType;

    Flck : File Of LockBazType;
    lck : LockBazType;

    FMarka : File Of MarkaType;
    EMarka : PMarkaType;

    FExpert : File Of ExpertType;
    EExpert : PExpertType;

    FSMarka : File Of SpecMarkaType;
    ESMarka : PSpecMarkaType;

    Fngtd : File Of NGTDType;
    Engtd : PNGTDType;

    BakFileRegion : File Of BakRegionType;
    BakRegionElement : BakRegionType;

    NewFileRegion : File Of RegionType;
    NewRegionElement : RegionType;

    ExpertList,MarkaList,
    SMarkaList,NGTDList : PBox;
    r : TRect;
    NGTDKOd,MarkaKod,ExpertKod,SMarkaKod : ArtikulStr;

Var KSF : File Of NGTDType;
    NGTDELement :NGTDType;
    KSFM : File Of MarkaType;
    MarkaELement :MarkaType;
    KSFE : File Of ExpertType;
    ExpertELement :ExpertType;

    KSFS : File Of SpecMarkaType;
    SpecMarkaELement :SpecMarkaType;



Function FindElement(s:String):Boolean;
VAr Find : Boolean;
Begin
FindElement:=False;
Assign(f,'lands.db');
c:=IoResult;
Reset(f);
c:=IoResult;
Find := False;

New(E,Init);
While Not(Eof(f)) And Not(Find) Do
 Begin
  Read(f,E^.DAt);
  If E^.DAt.Employ Then
  Begin
   If E^.Dat.Post=S Then
    Begin
     Find:=True;
    End;
  End
   Else
    Begin
     If StrToInt(E^.Dat.Kod)>Max Then Max:=StrToInt(E^.Dat.Kod);
     E^.DAt.Post:=S;
     E^.Dat.Employ:=True;
     Find:=True;
     Seek(f,FilePos(f)-1);
     Write(f,E^.DAt);
    End;
 End;
Dispose(E,Done);
Close(f);
FindElement:=Find;
End;


Function FindElementFirm(s:String):Boolean;
VAr Find : Boolean;
    f: File Of FirmaPostType;
    E: PFirmaPostType;
    c : LongInt;
Begin
FindElementFirm:=False;
Assign(f,'firma.db');
c:=IoResult;
Reset(f);
c:=IoResult;
Find := False;
DelSpaceRight(S);

New(E,Init);
While Not(Eof(f)) And Not(Find) Do
 Begin
  Read(f,E^.DAt);

  If E^.DAt.Employ Then
  Begin
   DelSpaceRight(E^.DAt.FirmaPost);
   If E^.Dat.FirmaPost=S Then
    Begin
     Find:=True;
    End;
  End
   Else
    Begin
     If StrToInt(E^.Dat.Kod)>MaxF Then MaxF:=StrToInt(E^.Dat.Kod);
     E^.DAt.FirmaPost:=S;
     E^.Dat.Employ:=True;
     Find:=True;
     Seek(f,FilePos(f)-1);
     Write(f,E^.DAt);
    End;

 End;
Dispose(E,Done);
c:=IoResult;
Close(f);
c:=IoResult;
FindElementFirm:=Find;
End;


Function FindElementSpecMarka(bk:String):Boolean;
Var KK : String;
    KSF : File Of SpecmarkaType;
    ss : SpecmarkaType;
    Find : Boolean;
    c : Word;
    skod,s : String;
Begin
FindElementSpecMarka:=False;
DelSpaceRight(BK);

If BK[0]=#0 Then Exit;

Del2Space(Bk);
While Pos('"',Bk)>0 Do System.Delete(Bk,Pos('"',Bk),1);
IF Pos('НЕТ ДАННЫХ',Bk)>0 Then Exit;


Find:=False;
For c:=0 To SMarkaList^.List^.Count-1 Do
 Begin
  s:=SMarkaList^.GetText(c,SMarkaList^.List^.Count);
  SKod:=Copy(s,1+CSpecMarka+1,CArtikul);
  s:=Copy(s,1,CSpecMarka);
  DelSpaceRight(s);
  If s=bk Then
   Begin
    Find:=True;
    FindElementSpecMarka:=Find;
    Writeln(bk+' - нашли '+SKod);
    Break;
   End;
 End;

If Find Then Exit;
{поиск в памяти по списку}
{успех выход
 неудача запись в лист
         запись в файл
         увеличение счетчика на 1
	    новый код и выход }


Assign(KSF,'SMarka.db');
Reset(KSF);
If IOResult<>0 Then
 Begin
  Writeln('Ошибка открытия '+'SMarka.db');
  Halt;
 End;

Seek(KSf,StrToInt(SMarkaKod));
Read(KSF,SS);
Seek(KSf,FilePos(KSF)-1);
SS.SpecMarka:=BK;
SS.Employ:=True;
Write(KSF,SS);
c:=IoResult;
Close(KSF);
c:=IoResult;
SMarkaKod:=IntToStr(StrToInt(SS.Kod)+1,CArtikul);
RFormatZerro(SMarkaKod,CArtikul);
Writeln('"'+bk+'"'+' - не найдена в базе спец марок' + 'добавлена '+Ss.Kod+
   ' ('+SMarkaKod+')');
Format(SS.SPecMarka,CSpecMarka);
SMarkaList^.List^.Insert(NewStr(SS.SpecMarka+'│'+SS.Kod));
SMarkaList^.SetRange(SMarkaList^.List^.Count);
FindElementSpecMarka:=True;
End;



Function FindElementngtd(bk:String):Boolean;
Var KK : AllStr;
    KSF : File Of NGTDType;
    ss : NGTDType;
    Find : Boolean;
    c : Word;
    skod,s : String;
Begin
FindElementngtd:=False;
DelSpaceRight(BK);

If BK[0]=#0 Then Exit;

Del2Space(Bk);
While Pos('"',Bk)>0 Do System.Delete(Bk,Pos('"',Bk),1);
IF Pos('НЕТ ДАННЫХ',Bk)>0 Then Exit;


Find:=False;
For c:=0 To NGTDList^.List^.Count-1 Do
 Begin
  s:=NGTDList^.GetText(c,NGTDList^.List^.Count);
  SKod:=Copy(s,1+CNGTD+1,CArtikul);
  s:=Copy(s,1,CNGTD);
  DelSpaceRight(s);
  If s=bk Then
   Begin
    Find:=True;
    FindElementngtd:=Find;
    Writeln(bk+' - нашли '+SKod);
    Break;
   End;
 End;

If Find Then Exit;

{поиск в памяти по списку}
{успех выход
 неудача запись в лист
         запись в файл
         увеличение счетчика на 1
	    новый код и выход }


Assign(KSF,'NGTD.db');
Reset(KSF);
If IOResult<>0 Then
 Begin
  Writeln('Ошибка открытия '+'NGTD.db');
  Halt;
 End;

Seek(KSf,StrToInt(NGTDKod));
Read(KSF,SS);
Seek(KSf,FilePos(KSF)-1);
SS.NGTD:=BK;
SS.Employ:=True;
Write(KSF,SS);
c:=IoResult;
Close(KSF);
c:=IoResult;
NGTDKod:=IntToStr(StrToInt(SS.Kod)+1,CArtikul);
RFormatZerro(NGTDKod,CArtikul);
Writeln('"'+bk+'"'+' - не найдена в базе ГТД' + 'добавлена '+Ss.Kod+
   ' ('+NGTDKod+')');
Format(SS.NGTD,CNGTD);
NGTDList^.List^.Insert(NewStr(SS.NGTD+'│'+SS.Kod));
NGTDList^.SetRange(NGTDList^.List^.Count);
FindElementngtd:=True;

End;



Function FindElementExpert(bk:String):Boolean;
Var KK : AllStr;
    KSF : File Of ExpertType;
    ss : ExpertType;
    Find : Boolean;
    c : Word;
    skod,s : String;
Begin
FindElementExpert:=False;
DelSpaceRight(BK);

If BK[0]=#0 Then Exit;

Del2Space(Bk);
While Pos('"',Bk)>0 Do System.Delete(Bk,Pos('"',Bk),1);
IF Pos('НЕТ ДАННЫХ',Bk)>0 Then Exit;


Find:=False;
For c:=0 To ExpertList^.List^.Count-1 Do
 Begin
  s:=ExpertList^.GetText(c,ExpertList^.List^.Count);
  SKod:=Copy(s,1+CExpert+1,CArtikul);
  s:=Copy(s,1,CExpert);
  DelSpaceRight(s);
  If s=bk Then
   Begin
    Find:=True;
    FindElementExpert:=Find;
    Writeln(bk+' - нашли '+SKod);
    Break;
   End;
 End;

If Find Then Exit;

{поиск в памяти по списку}
{успех выход
 неудача запись в лист
         запись в файл
         увеличение счетчика на 1
	    новый код и выход }


Assign(KSF,'Expert.db');
Reset(KSF);
If IOResult<>0 Then
 Begin
  Writeln('Ошибка открытия '+'Expert.db');
  Halt;
 End;

Seek(KSf,StrToInt(ExpertKod));
Read(KSF,SS);
Seek(KSf,FilePos(KSF)-1);
SS.Expert:=BK;
SS.Employ:=True;
Write(KSF,SS);
c:=IoResult;
Close(KSF);
c:=IoResult;
ExpertKod:=IntToStr(StrToInt(SS.Kod)+1,CArtikul);
RFormatZerro(ExpertKod,CArtikul);
Writeln('"'+bk+'"'+' - не найдена в базе эксп закл ' + 'добавлена '+Ss.Kod+
   ' ('+ExpertKod+')');
Format(SS.Expert,CExpert);
ExpertList^.List^.Insert(NewStr(SS.Expert+'│'+SS.Kod));
ExpertList^.SetRange(ExpertList^.List^.Count);
FindElementExpert:=True;

End;

Function FindElementMarka(bk:String):Boolean;
Var KK : AllStr;
    KSF : File Of MarkaType;
    ss : MarkaType;
    Find : Boolean;
    c : Word;
    skod,s : String;
Begin
FindElementMarka:=False;
DelSpaceRight(BK);

If BK[0]=#0 Then Exit;

Del2Space(Bk);
While Pos('"',Bk)>0 Do System.Delete(Bk,Pos('"',Bk),1);
IF Pos('НЕТ ДАННЫХ',Bk)>0 Then Exit;


Find:=False;
For c:=0 To MarkaList^.List^.Count-1 Do
 Begin
  s:=MarkaList^.GetText(c,MarkaList^.List^.Count);
  SKod:=Copy(s,1+CMarka+1,CArtikul);
  s:=Copy(s,1,CMarka);
  DelSpaceRight(s);
  If s=bk Then
   Begin
    Find:=True;
    FindElementMarka:=Find;
    Writeln(bk+' - нашли '+SKod);
    Break;
   End;
 End;

If Find Then Exit;

{поиск в памяти по списку}
{успех выход
 неудача запись в лист
         запись в файл
         увеличение счетчика на 1
	    новый код и выход }


Assign(KSF,'Marka.db');
Reset(KSF);
If IOResult<>0 Then
 Begin
  Writeln('Ошибка открытия '+'Marka.db');
  Halt;
 End;

Seek(KSf,StrToInt(MarkaKod));
Read(KSF,SS);
Seek(KSf,FilePos(KSF)-1);
SS.Marka:=BK;
SS.Employ:=True;
Write(KSF,SS);
c:=IoResult;
Close(KSF);
c:=IoResult;
MarkaKod:=IntToStr(StrToInt(SS.Kod)+1,CArtikul);
RFormatZerro(MarkaKod,CArtikul);
Writeln('"'+bk+'"'+' - не найдена в базе акц.марок ' + 'добавлена '+Ss.Kod+
   ' ('+MarkaKod+')');
Format(SS.Marka,CMarka);
MarkaList^.List^.Insert(NewStr(SS.Marka+'│'+SS.Kod));
MarkaList^.SetRange(MarkaList^.List^.Count);
FindElementMarka:=True;

End;



Function FindElementSertif(s:String):Boolean;
VAr Find : Boolean;
    f: File Of KSertifType;
    E: PKSertifType;
    c : LongInt;
Begin
FindElementSertif:=False;
Assign(f,'KSertif.db');
c:=IoResult;
Reset(f);
c:=IoResult;
Find := False;
DelSpaceRight(S);

New(E,Init);
While Not(Eof(f)) And Not(Find) Do
 Begin
  Read(f,E^.DAt);

  If E^.DAt.Employ Then
  Begin
    DelSpaceRight(E^.DAt.KSertif);
   If E^.Dat.KSertif=S Then
    Begin
     Find:=True;
     Writeln('Нашли '+S);
    End;
  End
   Else
    Begin
     If StrToInt(E^.Dat.Kod)>MaxS Then MaxS:=StrToInt(E^.Dat.Kod);
     E^.DAt.KSertif:=S;
     E^.Dat.Employ:=True;
     Find:=True;
     Seek(f,FilePos(f)-1);
     Write(f,E^.DAt);
     Writeln('Добавили '+S);
    End;

 End;
Dispose(E,Done);
c:=IoResult;
Close(f);
c:=IoResult;
FindElementSertif:=Find;
End;


Function FindElementMera(s:String):Boolean;
VAr Find : Boolean;
    f: File Of MeraType;
    E: PMeraType;
    c : LongInt;
Begin
FindElementMera:=False;
Assign(f,'mera.db');
c:=IoResult;
Reset(f);
c:=IoResult;
Find := False;
DelSpaceRight(s);

New(E,Init);
While Not(Eof(f)) And Not(Find) Do
 Begin
  Read(f,E^.DAt);

  If E^.DAt.Employ Then
  Begin
   DelSpaceRight(E^.DAt.Mera);
   If E^.Dat.Mera=S Then
    Begin
     Find:=True;
     Writeln('Нашли '+S);
    End;
  End
   Else
    Begin
     If StrToInt(E^.Dat.Kod)>MaxM Then MaxM:=StrToInt(E^.Dat.Kod);
     E^.DAt.Mera:=S;
     E^.Dat.Employ:=True;
     Find:=True;
     Seek(f,FilePos(f)-1);
     Write(f,E^.DAt);
     Writeln('Добавили '+S);
    End;

 End;
Dispose(E,Done);
c:=IoResult;
Close(f);
c:=IoResult;
FindElementMera:=Find;
End;


Var i : Word;

Begin
Max:=0;
MaxF:=0;
Maxs:=0;
MAxM:=0;
MAxMarka:=0;
MAxSMarka:=0;
MAxNGTD:=0;
MaxExpert:=0;
{создание базы smarka.db}
Assign(f,'lands.db');
c:=IoResult;
Rewrite(f);
c:=IoResult;
For c:=0 To 300 Do
 Begin
  New(E,Init);
  E^.Dat.Kod:=IntToStr(c,CClientKod);
  RFormatZerro(E^.Dat.Kod,CClientKod);
  If c=0 Then
   Begin
    E^.Dat.Employ:=True;
    E^.Dat.Post:='..';
    E^.Dat.RCD:=False;
   End;
  Write(f,E^.DAt);
  Dispose(E,Done);
 End;

c:=IoResult;
Close(f);
c:=IoResult;

Assign(flck,'lands.lck');
c:=IoResult;
Rewrite(flck);
c:=IoResult;
For c:=0 To 300 Do
 Begin
  Lck.BazKod:=IntToStr(c,CArtikul);
  RFormatZerro(Lck.BazKod,CArtikul);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(flck,Lck);
 End;
c:=IoResult;
Close(flck);
c:=IoResult;






Assign(ff,'firma.db');
c:=IoResult;
Rewrite(ff);
c:=IoResult;
For c:=0 To 1000 Do
 Begin
  New(Ef,Init);
  Ef^.Dat.Kod:=IntToStr(c,CCLientKod);
  RFormatZerro(Ef^.Dat.Kod,CCLientKod);
  If c=0 Then
   Begin
    Ef^.Dat.Employ:=True;
    Ef^.Dat.FirmaPost:='..';
    Ef^.Dat.RCD:=False;
   End;
  Write(ff,Ef^.DAt);
  Dispose(Ef,Done);
 End;

c:=IoResult;
Close(ff);
c:=IoResult;

Assign(flck,'firma.lck');
c:=IoResult;
Rewrite(flck);
c:=IoResult;
For c:=0 To 1000 Do
 Begin
  Lck.BazKod:=IntToStr(c,CArtikul);
  RFormatZerro(Lck.BazKod,CArtikul);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(flck,Lck);
 End;
c:=IoResult;
Close(flck);
c:=IoResult;


Assign(flck,'region.lck');
c:=IoResult;
Rewrite(flck);
c:=IoResult;
For c:=0 To 1000 Do
 Begin
  Lck.BazKod:=IntToStr(c,CArtikul);
  RFormatZerro(Lck.BazKod,CArtikul);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(flck,Lck);
 End;
c:=IoResult;
Close(flck);
c:=IoResult;


Assign(flck,'route.lck');
c:=IoResult;
Rewrite(flck);
c:=IoResult;
For c:=0 To 1000 Do
 Begin
  Lck.BazKod:=IntToStr(c,CArtikul);
  RFormatZerro(Lck.BazKod,CArtikul);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(flck,Lck);
 End;
c:=IoResult;
Close(flck);
c:=IoResult;

Assign(flck,'group.lck');
c:=IoResult;
Rewrite(flck);
c:=IoResult;
For c:=0 To 1000 Do
 Begin
  Lck.BazKod:=IntToStr(c,CArtikul);
  RFormatZerro(Lck.BazKod,CArtikul);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(flck,Lck);
 End;
c:=IoResult;
Close(flck);
c:=IoResult;


Assign(fff,'ksertif.db');
c:=IoResult;
Rewrite(fff);
c:=IoResult;
For c:=0 To 2000 Do
 Begin
  New(Eff,Init);
  Eff^.Dat.Kod:=IntToStr(c,CCLientKod);
  RFormatZerro(Eff^.Dat.Kod,CCLientKod);
  If c=0 Then
   Begin
    Eff^.Dat.Employ:=True;
    Eff^.Dat.KSertif:='..';
    Eff^.Dat.RCD:=False;
   End;
  Write(fff,Eff^.DAt);
  Dispose(Eff,Done);
 End;

c:=IoResult;
Close(fff);
c:=IoResult;


Assign(flck,'ksertif.lck');
c:=IoResult;
Rewrite(flck);
c:=IoResult;
For c:=0 To 2000 Do
 Begin
  Lck.BazKod:=IntToStr(c,CArtikul);
  RFormatZerro(Lck.BazKod,CArtikul);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(flck,Lck);
 End;
c:=IoResult;
Close(flck);
c:=IoResult;




Assign(fffm,'mera.db');
c:=IoResult;
Rewrite(fffm);
c:=IoResult;
For c:=0 To 100 Do
 Begin
  New(Efm,Init);
  Efm^.Dat.Kod:=IntToStr(c,CCLientKod);
  RFormatZerro(Efm^.Dat.Kod,CCLientKod);
  If c=0 Then
   Begin
    Efm^.Dat.Employ:=True;
    Efm^.Dat.Mera:='..';
    Efm^.Dat.RCD:=False;
   End;
  Write(fffm,Efm^.DAt);
  Dispose(Efm,Done);
 End;

c:=IoResult;
Close(fffm);
c:=IoResult;

Assign(flck,'mera.lck');
c:=IoResult;
Rewrite(flck);
c:=IoResult;
For c:=0 To 100 Do
 Begin
  Lck.BazKod:=IntToStr(c,CArtikul);
  RFormatZerro(Lck.BazKod,CArtikul);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(flck,Lck);
 End;
c:=IoResult;
Close(flck);
c:=IoResult;



Assign(fmarka,'marka.db');
c:=IoResult;
Rewrite(fmarka);
c:=IoResult;
For c:=0 To 7000 Do
 Begin
  New(EMarka,Init);
  EMarka^.Dat.Kod:=IntToStr(c,CArtikul);
  RFormatZerro(EMarka^.Dat.Kod,CArtikul);
  If c=0 Then
   Begin
    EMarka^.Dat.Employ:=True;
    EMarka^.Dat.Marka:='..';
    EMarka^.Dat.RCD:=False;
   End;
  Write(fmarka,EMarka^.DAt);
  Dispose(EMarka,Done);
 End;
c:=IoResult;
Close(fMarka);
c:=IoResult;

Assign(flck,'marka.lck');
c:=IoResult;
Rewrite(flck);
c:=IoResult;
For c:=0 To 7000 Do
 Begin
  Lck.BazKod:=IntToStr(c,CArtikul);
  RFormatZerro(Lck.BazKod,CArtikul);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(flck,Lck);
 End;
c:=IoResult;
Close(flck);
c:=IoResult;


Assign(fExpert,'Expert.db');
c:=IoResult;
Rewrite(fExpert);
c:=IoResult;
For c:=0 To 7000 Do
 Begin
  New(EExpert,Init);
  EExpert^.Dat.Kod:=IntToStr(c,CArtikul);
  RFormatZerro(EExpert^.Dat.Kod,CArtikul);
  If c=0 Then
   Begin
    EExpert^.Dat.Employ:=True;
    EExpert^.Dat.Expert:='..';
    EExpert^.Dat.RCD:=False;
   End;
  Write(fExpert,EExpert^.DAt);
  Dispose(EExpert,Done);
 End;
c:=IoResult;
Close(fExpert);
c:=IoResult;


Assign(flck,'expert.lck');
c:=IoResult;
Rewrite(flck);
c:=IoResult;
For c:=0 To 7000 Do
 Begin
  Lck.BazKod:=IntToStr(c,CArtikul);
  RFormatZerro(Lck.BazKod,CArtikul);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(flck,Lck);
 End;
c:=IoResult;
Close(flck);
c:=IoResult;


Assign(fsmarka,'smarka.db');
c:=IoResult;
Rewrite(fsmarka);
c:=IoResult;
For c:=0 To 7000 Do
 Begin
  New(Esmarka,Init);
  Esmarka^.Dat.Kod:=IntToStr(c,CArtikul);
  RFormatZerro(Esmarka^.Dat.Kod,CArtikul);
  If c=0 Then
   Begin
    Esmarka^.Dat.Employ:=True;
    Esmarka^.Dat.specmarka:='.';
    Esmarka^.Dat.RCD:=False;
   End;
  Write(fsmarka,Esmarka^.DAt);
  Dispose(Esmarka,Done);
 End;
c:=IoResult;
Close(fsmarka);
c:=IoResult;


Assign(flck,'smarka.lck');
c:=IoResult;
Rewrite(flck);
c:=IoResult;
For c:=0 To 7000 Do
 Begin
  Lck.BazKod:=IntToStr(c,CArtikul);
  RFormatZerro(Lck.BazKod,CArtikul);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(flck,Lck);
 End;
c:=IoResult;
Close(flck);
c:=IoResult;



Assign(fngtd,'ngtd.db');
c:=IoResult;
Rewrite(fngtd);
c:=IoResult;
For c:=0 To 7000 Do
 Begin
  New(Engtd,Init);
  Engtd^.Dat.Kod:=IntToStr(c,CArtikul);
  RFormatZerro(Engtd^.Dat.Kod,CArtikul);
  If c=0 Then
   Begin
    Engtd^.Dat.Employ:=True;
    Engtd^.Dat.ngtd:='..';
    Engtd^.Dat.RCD:=False;
   End;
  Write(fngtd,Engtd^.DAt);
  Dispose(Engtd,Done);
 End;
c:=IoResult;
Close(fngtd);
c:=IoResult;

Assign(flck,'ngtd.lck');
c:=IoResult;
Rewrite(flck);
c:=IoResult;
For c:=0 To 7000 Do
 Begin
  Lck.BazKod:=IntToStr(c,CArtikul);
  RFormatZerro(Lck.BazKod,CArtikul);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(flck,Lck);
 End;
c:=IoResult;
Close(flck);
c:=IoResult;


Assign(BakFileRegion,'region.db');
Reset(BakFileRegion);

Assign(NewFileRegion,'region.new');
Rewrite(NewFileRegion);

While Not(Eof(BakFileRegion)) Do
Begin
 Read(BakFileRegion,BakRegionElement);
 With NewRegionElement Do
  Begin
   RegionName:=BakRegionElement.RegionName;
   Kod:=BakRegionElement.Kod;
   Employ:=BakRegionElement.Employ;
   RCD:=BakRegionElement.RCD;
  End;
  Write(NewFileRegion,NewRegionElement);
End;
Close(BakFileRegion);
Close(NewFileRegion);

Rename (BakFileRegion,'region.bak');
Rename (NewFileRegion,'region.db');



Assign(BakFileRegion,'group.db');
Reset(BakFileRegion);

Assign(NewFileRegion,'group.new');
Rewrite(NewFileRegion);

While Not(Eof(BakFileRegion)) Do
Begin
 Read(BakFileRegion,BakRegionElement);
 With NewRegionElement Do
  Begin
   RegionName:=BakRegionElement.RegionName;
   Kod:=BakRegionElement.Kod;
   Employ:=BakRegionElement.Employ;
   RCD:=BakRegionElement.RCD;
  End;
  Write(NewFileRegion,NewRegionElement);
End;
Close(BakFileRegion);
Close(NewFileRegion);

Rename (BakFileRegion,'group.bak');
Rename (NewFileRegion,'group.db');


Assign(BakFileRegion,'route.db');
Reset(BakFileRegion);

Assign(NewFileRegion,'route.new');
Rewrite(NewFileRegion);

While Not(Eof(BakFileRegion)) Do
Begin
 Read(BakFileRegion,BakRegionElement);
 With NewRegionElement Do
  Begin
   RegionName:=BakRegionElement.RegionName;
   Kod:=BakRegionElement.Kod;
   Employ:=BakRegionElement.Employ;
   RCD:=BakRegionElement.RCD;
  End;
  Write(NewFileRegion,NewRegionElement);
End;
Close(BakFileRegion);
Close(NewFileRegion);

Rename (BakFileRegion,'route.bak');
Rename (NewFileRegion,'route.db');



Assign(flck,'Shablon.lck');
c:=IoResult;
Rewrite(flck);
c:=IoResult;
For c:=0 To 30000 Do
 Begin
  Lck.BazKod:=IntToStr(c,CArtikul);
  RFormatZerro(Lck.BazKod,CArtikul);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(flck,Lck);
 End;
c:=IoResult;
Close(flck);
c:=IoResult;



Writeln('Загрузка справочников....');

NGTDKOd:='00001';
MarkaKod:='00001';
ExpertKod:='00001';
SMarkaKod:='00001';


R.Assign(0,0,0,0);
NGTDList := New(PBox, Init(R, 1, Nil));
NGTDList^.NewList(New(PTextCollection, Init(0,1)));
{
ws:='НЕТ ДАННЫХ';
Format(ws,CNGTD);
NGTDList^.List^.Insert(NewStr(ws+'│'+NGTDKod));
NGTDList^.SetRange(NGTDList^.List^.Count);
}
ExpertList := New(PBox, Init(R, 1, Nil));
ExpertList^.NewList(New(PTextCollection, Init(0,1)));
{
ws:='НЕТ ДАННЫХ';
Format(ws,CExpert);
ExpertList^.List^.Insert(NewStr(ws+'│'+ExpertKod));
ExpertList^.SetRange(ExpertList^.List^.Count);
}

MarkaList := New(PBox, Init(R, 1, Nil));
MarkaList^.NewList(New(PTextCollection, Init(0,1)));
{
ws:='НЕТ ДАННЫХ';
Format(ws,CMarka);
MarkaList^.List^.Insert(NewStr(ws+'│'+MarkaKod));
MarkaList^.SetRange(MarkaList^.List^.Count);
}
SMarkaList := New(PBox, Init(R, 1, Nil));
SMarkaList^.NewList(New(PTextCollection, Init(0,1)));
{
ws:='НЕТ ДАННЫХ';
Format(ws,CSpecMarka);
SMarkaList^.List^.Insert(NewStr(ws+'│'+SMarkaKod));
SMarkaList^.SetRange(SMarkaList^.List^.Count);
}




Writeln('Загрузка справочников...');
Assign(KSF,'ngtd.db');
Reset(KSF);
If IOResult<>0 Then
 Begin
  Writeln('Ошибка открытия '+'ngtd.db');
  Halt;
 End;

 While Not Eof(KSF) Do
  Begin
   Read(KSF,NGTDELement);
   If NGTDELement.Employ Then
    Begin
     Format(NGTDELement.NGTD,CNGTD);
     RFormatZerro(NGTDElement.Kod,CArtikul);
     NGTDList^.List^.Insert(NewStr(NGTDElement.NGTD+'│'+NGTDElement.Kod));
     NGTDList^.SetRange(NGTDList^.List^.Count);
     NGTDKOd:=IntToStr(StrToInt(NGTDELement.Kod)+1,CArtikul);
     RFormatZerro(NGTDKOd,CArtikul);
    End;
  End;
i:=IOResult;
Close(KSF);
i:=IOResult;


Assign(KSFM,'Marka.db');
Reset(KSFM);
If IOResult<>0 Then
 Begin
  Writeln('Ошибка открытия '+'Marka.db');
  Halt;
 End;

 While Not Eof(KSFM) Do
  Begin
   Read(KSFM,MarkaELement);
   If MarkaELement.Employ Then
    Begin
     Format(MarkaELement.Marka,CMarka);
     RFormatZerro(MarkaELement.Kod,CArtikul);
     MarkaList^.List^.Insert(NewStr(MarkaELement.Marka+'│'+MarkaELement.Kod));
     MarkaList^.SetRange(MarkaList^.List^.Count);
     MarkaKOd:=IntToStr(StrToInt(MarkaELement.Kod)+1,CArtikul);
     RFormatZerro(MarkaKOd,CArtikul);
    End;
  End;
i:=IOResult;
Close(KSFM);
i:=IOResult;

Assign(KSFE,'Expert.db');
Reset(KSFE);
If IOResult<>0 Then
 Begin
  Writeln('Ошибка открытия '+'Expert.db');
  Halt;
 End;

 While Not Eof(KSFE) Do
  Begin
   Read(KSFE,ExpertELement);
   If ExpertELement.Employ Then
    Begin
     Format(ExpertELement.Expert,CExpert);
     RFormatZerro(ExpertELement.Kod,CArtikul);
     ExpertList^.List^.Insert(NewStr(ExpertELement.Expert+'│'+ExpertELement.Kod));
     ExpertList^.SetRange(ExpertList^.List^.Count);
     ExpertKOd:=IntToStr(StrToInt(ExpertELement.Kod)+1,CArtikul);
     RFormatZerro(ExpertKOd,CArtikul);
    End;
  End;
i:=IOResult;
Close(KSFE);
i:=IOResult;


Assign(KSFS,'SMarka.db');
Reset(KSFS);
If IOResult<>0 Then
 Begin
  Writeln('Ошибка открытия '+'SMarka.db');
  Halt;
 End;

 While Not Eof(KSFS) Do
  Begin
   Read(KSFS,SpecMarkaELement);
   If SpecMarkaELement.Employ Then
    Begin
     Format(SpecMarkaELement.SpecMarka,CSpecMarka);
     RFormatZerro(SpecMarkaELement.Kod,CArtikul);
     SMarkaList^.List^.Insert(NewStr(SpecMarkaELement.SpecMarka+'│'+SpecMarkaELement.Kod));
     SMarkaList^.SetRange(SMarkaList^.List^.Count);
     SMarkaKOd:=IntToStr(StrToInt(SpecMarkaELement.Kod)+1,CArtikul);
     RFormatZerro(SMarkaKOd,CArtikul);
    End;
  End;
i:=IOResult;
Close(KSFS);
i:=IOResult;







Assign(fr,'razdel.db');
Reset(fr);
While Not(Eof(fr)) Do
 Begin
  Read(fr,RazdelElement);
  If RazdelElement.Employ Then
   Begin


Assign(flck,RazdelElement.Kod+'.lck');
c:=IoResult;
Rewrite(flck);
c:=IoResult;
For c:=0 To 999 Do
 Begin
  Lck.BazKod:=IntToStr(c,3);
  Lck.BazKod:=RazdelElement.Kod+Lck.BazKod;
  RFormatZerro(Lck.BazKod,CArtikul);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(flck,Lck);
 End;
c:=IoResult;
Close(flck);
c:=IoResult;



    Assign(fe,RazdelElement.Kod+'.mbx');
    Reset(fe);
    c:=IoResult;
    While Not(Eof(fe)) Do
     Begin
      Read(fe,el);
      {If el.Input.Employ Then}
        DelSpaceRight(el.Input.Post);
        DelSpaceRight(el.Input.FirmaPost);
        DelSpaceRight(el.Input.Marka);
        DelSpaceRight(el.Input.Ex);
        DelSpaceRight(el.Input.NGTD);
        DelSpaceRight(el.Input.SpecMarka);


        Del2Space(el.Input.Post);
        Del2Space(el.Input.FirmaPost);
        Del2Space(el.Input.Marka);
        Del2Space(el.Input.Ex);
        Del2Space(el.Input.NGTD);
        Del2Space(el.Input.SpecMarka);

        While Pos('"',el.Input.FirmaPost)>0 Do System.Delete(el.Input.FirmaPost,Pos('"',el.Input.FirmaPost),1);
        While Pos('"',el.Input.Post)>0 Do System.Delete(el.Input.Post,Pos('"',el.Input.Post),1);
        While Pos('"',el.Input.Marka)>0 Do System.Delete(el.Input.Marka,Pos('"',el.Input.Marka),1);
        While Pos('"',el.Input.Ex)>0 Do System.Delete(el.Input.Ex,Pos('"',el.Input.Ex),1);
        While Pos('"',el.Input.NGTD)>0 Do System.Delete(el.Input.NGTD,Pos('"',el.Input.NGTD),1);
        While Pos('"',el.Input.SpecMarka)>0 Do System.Delete(el.Input.SpecMarka,Pos('"',el.Input.SpecMarka),1);
        {добавить удаление кавычек и двойных пробелов}

        Writeln('Обрабатываю '+RazdelElement.Kod++'.mbx: ',FilePos(fe),' из ',FileSize(fe));

       If el.Input.Post[0]<>#0 Then
       Begin
        If Not FindElement(el.Input.Post) Then
	      Begin
		  Writeln(el.Input.Post+'-Error');
           End;
       End;{El.Employ}

       If el.Input.FirmaPost[0]<>#0 Then
       Begin
        If Not FindElementFirm(el.Input.FirmaPost) Then
           Begin
   	       Writeln(el.Input.FirmaPost+'-Error');
           End;
       End;{El.Employ}

       If el.Input.Marka[0]<>#0 Then
       Begin
        el.Input.Marka:='_'+el.Input.Marka;
        If Not FindElementMarka(el.Input.Marka) Then
           Begin
 	       Writeln(el.Input.Marka+'-Error');
            Readln;
           End;

       End;{El.Employ}


       If el.Input.Ex[0]<>#0 Then
       Begin
        el.Input.Ex:='_'+el.Input.Ex;
        If Not FindElementExpert(el.Input.Ex) Then
           Begin
	       Writeln(el.Input.Ex+'-Error');
            Readln;
           End;

       End;{El.Employ}



       If el.Input.SpecMarka[0]<>#0 Then
       Begin
        el.Input.SpecMarka:='_'+el.Input.SpecMarka;
        If Not FindElementSpecMarka(el.Input.SpecMarka) Then
           Begin
	       Writeln(el.Input.SpecMarka+'-Error');
            Readln;
           End;

       End;{El.Employ}

       If el.Input.NGTD[0]<>#0 Then
       Begin
        el.Input.NGTD:='_'+el.Input.NGTD;
        If Not FindElementNGTD(el.Input.NGTD) Then
           Begin
	       Writeln(el.Input.NGTD+'-Error');
            Readln;
           End;

       End;{El.Employ}


     End;{While}
     Close(fe);
     c:=IoResult;


   Writeln(RazdelElement.Kod+'.mbx');



    Assign(idf,RazdelElement.Kod+'.id');
    Reset(idf);
    c:=IoResult;
    While Not(Eof(idf)) Do
     Begin
      Read(idf,id);
      If Id.Employ Then
     Begin

   If RazdelElement.EnableDoc=1 Then
    Begin
      c:=IoResult;
       DelSpaceRight(id.KSertif);
       Del2Space(id.KSertif);
       While Pos('"',id.KSertif)>0 Do System.Delete(id.KSertif,Pos('"',id.KSertif),1);

       If id.KSertif[0]<>#0 Then
       Begin
        If Not FindElementSertif(id.KSertif) Then
	    Begin
	     Writeln(id.KSertif+'-Error');
         End;
       End;{El.Employ}
     End;

       DelSpaceRight(id.Mera);
       Del2Space(id.Mera);
       While Pos('"',id.Mera)>0 Do System.Delete(id.Mera,Pos('"',id.Mera),1);
       If id.Mera[0]<>#0 Then
       Begin
        If Not FindElementMera(id.Mera) Then
	    Begin
	     Writeln(id.Mera+'-Error');
         End;
       End;
     End;{Employ}
     End;{While}
     Close(idf);
     c:=IoResult;

   Writeln(RazdelElement.Kod+'.id');

   End;{Razdel.Employ}
 End;{While}
close(fr);

(*
Assign(txt,'post.txt');
c:=IoResult;
Reset(txt);
c:=IoResult;
While Not(Eof(txt)) Do
 Begin
  Readln(txt,s);
  c:=Pos('$',s);
  System.Delete(s,1,c);
  DelSpaceRight(s);
  If FindElement(s) Then Writeln(s+'-Ok')
  Else Writeln(s+'-Error');
 End;
c:=IoResult;
Close(txt);
c:=IoResult;
*)


Dispose(NGTDList,Done);
Dispose(ExpertList,Done);
Dispose(MarkaList,Done);
Dispose(SMarkaList,Done);


Writeln(MAx:CDate,' -максимальный код страны');
Writeln(MAxF:CDate,' -максимальный код фирмы производители');
Writeln(MAxs:CDate,' -максимальный код органы сертификации');
Writeln(MAxM:CDate,' -максимальный код единиц измерения');
Writeln(MarkaKod,' -максимальный код акц.марок');
Writeln(SMarkaKod,' -максимальный код спе.марок');
Writeln(NGTDKod,' -максимальный код ГТД');
Writeln(ExpertKod,' -максимальный код экспертного заключения');
Readln;
End.