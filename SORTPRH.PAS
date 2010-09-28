Unit SortPRh;

INTERFACE
Uses Objects,App,Views,Validate,MsgBox, TPDate,Printers,Prise,
     Glob,ServStr,Serv,Dialogs,Drivers,
     NetDbEng,DBEngine, Tools, Utils,Utils5, ColorTxt,Utils3,Utils4;

procedure SortPrihod(var E:PrihodType);

procedure TestSortPrh;

IMPLEMENTATION

var Sort: word;
    {0 - наименование - раздел
     1 - раздел - наименование
     2 - раздел - код - наименование}

procedure SortPrihod(var E:PrihodType);

const PosI = 1+CName+CRazdelKOd+CArtikul;

var TempE: PPrihodType;
    TempBox: PBox;
    R: TRect;
    sName: string[CName];
    sRazdel: string[CRazdelKod];
    sArt: string[CArtikul];
    i: word;
    sPos: string[CRazdelKod];
    iPos: word;
    s: string;
Begin

 R.Assign(0,0,0,0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));

 for i:=1 To E.Amount do
 begin
   sArt:=E.PrihodElement[i].BazKod;
   sName:=GetIdField(FName,sArt);
   sRazdel:=copy(sArt,1,CRazdelKod);
   sPos:=IntToStr(i,CRazdelKod);
   format(sArt,CArtikul);
   format(sName,CName);
   format(sRazdel,CRazdelKod);
   format(sPos,CRazdelKod);
   {заполняем список}
   s:='';
   case Sort of
   0: begin
       {наименование - раздел}
        s:=sName+sRazdel+sArt+sPos;
      end;

   1: begin
       {раздел - наименование}
        s:=sRazdel+sName+sArt+sPos;
      end;

   2: begin
       {раздел - код - наименование}
        s:=sRazdel+sArt+sName+sPos;
      end;

   end; {case Sort of}

   TempBox^.List^.Insert(NewStr(s));
   TempBox^.SetRange(TempBox^.List^.Count);
  end; {for i:=1 To E.Amount}

 {перестановка элементов прихода}
 {из накладной в темп}
 new(TempE,Init);
 TempE^.Dat.Amount:=E.Amount;
 if TempBox^.List^.Count>0 then
 for i:=0 to TempBox^.List^.Count-1 do
 with TempE^.Dat.PrihodElement[i+1] do
 begin
   s:=TempBox^.GetText(i,TempBox^.List^.Count);
   sPos:=copy(s,PosI,CRazdelKod);
{   writeln(s);
   writeln(sPos);
   readln;}
   iPos:=StrToInt(sPos);
   BazKod:=E.PrihodElement[iPos].BazKod;
   VidNalog :=E.PrihodElement[iPos].VidNalog;
   Nalog    :=E.PrihodElement[iPos].Nalog;
   VidNDS   :=E.PrihodElement[iPos].VidNDS;
   NDS      :=E.PrihodElement[iPos].NDS;
   Input.Division:=E.PrihodElement[iPos].Input.Division;
   Input.USD     :=E.PrihodElement[iPos].Input.USD;
   Input.GRZena  :=E.PrihodElement[iPos].Input.GRZena;
   Input.Proz    :=E.PrihodElement[iPos].Input.Proz;
   Input.Zakupka :=E.PrihodElement[iPos].Input.Zakupka;
   Input.Zakupka2:=E.PrihodElement[iPos].Input.Zakupka2;
   Input.Nazenka :=E.PrihodElement[iPos].Input.Nazenka;
   Input.R_Zena :=E.PrihodElement[iPos].Input.R_Zena;
   Input.O_Zena  :=E.PrihodElement[iPos].Input.O_Zena;
   Input.Spec_Zena :=E.PrihodElement[iPos].Input.Spec_Zena;
   Input.NMakeKod:=E.PrihodElement[iPos].Input.NMakeKod;
   Input.Virabotano :=E.PrihodElement[iPos].Input.Virabotano;
   Input.Godnost :=E.PrihodElement[iPos].Input.Godnost;
   Input.RegionMarka:=E.PrihodElement[iPos].Input.RegionMarka;
   Input.AkzisSbor:=E.PrihodElement[iPos].Input.AkzisSbor;
   Input.ZenaMarki:=E.PrihodElement[iPos].Input.ZenaMarki;
   Input.NGTD    :=E.PrihodElement[iPos].Input.NGTD;
   Input.Marka   :=E.PrihodElement[iPos].Input.Marka;
   Input.SpecMarka :=E.PrihodElement[iPos].Input.SpecMarka;
   Input.Expert :=E.PrihodElement[iPos].Input.Expert;
   Input.NSertif :=E.PrihodElement[iPos].Input.NSertif;
   Input.StrihKod :=E.PrihodElement[iPos].Input.StrihKod;
   Input.Kol     :=E.PrihodElement[iPos].Input.Kol;
   Input.Caption :=E.PrihodElement[iPos].Input.Caption;
   Input.ZakupkaS:=E.PrihodElement[iPos].Input.ZakupkaS;
   Input.Auto :=E.PrihodElement[iPos].Input.Auto;
 end; {for i:=0 to TempBox^.List^.Count-1 do}
 {из темпа в накладную}
 for i:=1 to E.Amount do
 with E.PrihodElement[i] do
 Begin
   BazKod:=TempE^.Dat.PrihodElement[i].BazKod;
   VidNalog :=TempE^.Dat.PrihodElement[i].VidNalog;
   Nalog    :=TempE^.Dat.PrihodElement[i].Nalog;
   VidNDS   :=TempE^.Dat.PrihodElement[i].VidNDS;
   NDS      :=TempE^.Dat.PrihodElement[i].NDS;
   Input.Division:=TempE^.Dat.PrihodElement[i].Input.Division;
   Input.USD     :=TempE^.Dat.PrihodElement[i].Input.USD;
   Input.GRZena  :=TempE^.Dat.PrihodElement[i].Input.GRZena;
   Input.Proz    :=TempE^.Dat.PrihodElement[i].Input.Proz;
   Input.Zakupka :=TempE^.Dat.PrihodElement[i].Input.Zakupka;
   Input.Zakupka2:=TempE^.Dat.PrihodElement[i].Input.Zakupka2;
   Input.Nazenka :=TempE^.Dat.PrihodElement[i].Input.Nazenka;
   Input.R_Zena :=TempE^.Dat.PrihodElement[i].Input.R_Zena;
   Input.O_Zena  :=TempE^.Dat.PrihodElement[i].Input.O_Zena;
   Input.Spec_Zena :=TempE^.Dat.PrihodElement[i].Input.Spec_Zena;
   Input.NMakeKod:=TempE^.Dat.PrihodElement[i].Input.NMakeKod;
   Input.Virabotano :=TempE^.Dat.PrihodElement[i].Input.Virabotano;
   Input.Godnost :=TempE^.Dat.PrihodElement[i].Input.Godnost;
   Input.RegionMarka:=TempE^.Dat.PrihodElement[i].Input.RegionMarka;
   Input.AkzisSbor:=TempE^.Dat.PrihodElement[i].Input.AkzisSbor;
   Input.ZenaMarki:=TempE^.Dat.PrihodElement[i].Input.ZenaMarki;
   Input.NGTD    :=TempE^.Dat.PrihodElement[i].Input.NGTD;
   Input.Marka   :=TempE^.Dat.PrihodElement[i].Input.Marka;
   Input.SpecMarka :=TempE^.Dat.PrihodElement[i].Input.SpecMarka;
   Input.Expert :=TempE^.Dat.PrihodElement[i].Input.Expert;
   Input.NSertif :=TempE^.Dat.PrihodElement[i].Input.NSertif;
   Input.StrihKod :=TempE^.Dat.PrihodElement[i].Input.StrihKod;
   Input.Kol     :=TempE^.Dat.PrihodElement[i].Input.Kol;
   Input.Caption :=TempE^.Dat.PrihodElement[i].Input.Caption;
   Input.ZakupkaS:=TempE^.Dat.PrihodElement[i].Input.ZakupkaS;
   Input.Auto :=TempE^.Dat.PrihodElement[i].Input.Auto;
 end;{for i:=1 to E.Amount}

 Dispose(TempE,Done);

 Dispose(TempBox,Done);
ENd;

procedure TestSortPrh;
var PF: PrihodFileType;
    P: PPrihodType;
Begin
  Assign(PF,'s:\04\newskl\prihod\29-04-05.prh');
  reset(PF);
  New(P,Init);
  ReadPrihod(PF,P);
  ReadPrihod(PF,P);
  ReadPrihod(PF,P);
  ReadPrihod(PF,P);
  ReadPrihod(PF,P);
  ReadPrihod(PF,P);
  ReadPrihod(PF,P);
  ReadPrihod(PF,P);
  sort:=1;
  SortPrihod(p^.Dat);
  Dispose(P,Done);
End;

BEGIN
 Sort:=0;
END.