Unit UtilsSS;

INTERFACE

Uses Dialogs,Glob,CorMrk,ColorTxt,ServStr,Drivers,Utils4,
     Utils1,NetCall,WinDos,Dos,Net2,Net,PZakaz,
     Views,MyCalc,ViewMrk,LockInfo,FindPrh,TrNakl;


function FindAllKol(kod:ArtikulStr;P:PPredZakazType;i:word):ArtikulStr;

IMPLEMENTATION
Uses Objects,MSGBox,App,Serv,DbEngine,Utils,Utils3,Tools,Vision2,Vision3,netDbEng,
     Validate,ServStr2,Access,Mail,StHolder,MrkTool,
     dbEngin2,dbEngin3,TpDate,Printers,Protect,Utils5;



function FindAllKol(kod:ArtikulStr;P:PPredZakazType;i:word):ArtikulStr;
var M: PBox;
    Find: boolean;
    sKod: ArtikulStr;
    k,k1,ii,jk: word;
    sKol:string[CKol];
    s: string;
    Kdx : PSkladTypeNew;
    KdxFile : File Of SkladTypeNew;
    R: TRect;
Begin
   FindAllKol:='';

   memc(kod);
   Assign(KdxFile,Path^.Dat.ToIndex+Copy(kod,1,CrazdelKod)+'.kdx');
   jk:=IOResult;
   Reset(KdxFile);
   jk:=IOResult;
   If jk <> 0 Then
    Begin
      MessageBox(
      #3^M+#3'Ошибка доступа к файлу '+Copy(kod,1,CrazdelKod)+'.kdx! Код:'+IntToStr(jk,cKol),Nil,mfError+mfCancelButton);
     Exit;
    End;

   R.Assign(0,0,0,0);
   M := New(PBox, Init(R, 1, Nil));
   M^.NewList(New(PTextCollection, Init(0,1)));

   new(Kdx,Init);
   jk:=IOResult;
   seek(KdxFile,StrToInt(copy(kod,3,3)));
   jk:=IOResult;
   read(KdxFile,Kdx^.Dat);
   jk:=IOResult;

   if Kdx^.DAt.main=0 then sKod:=kod
   else
   begin
    sKod:=IntToStr(Kdx^.DAt.FantomKod,CArtikul);
    RFormatZerro(sKod,CArtikul);
   end;

   jk:=IOResult;
   Close(KdxFile);
   jk:=IOResult;

   reset(KdxFile);
   jk:=IOResult;

   find:=false;
   while not eof(KdxFile) do
   begin
    jk:=IOResult;
    read(KdxFile,Kdx^.Dat);

    jk:=IOResult;
    if Kdx^.DAt.Employ then
    if Kdx^.Dat.FantomKod=StrToInt(sKOd) then
    begin
      k:=0;
      k1:=0;
      for ii:=1 to CDivision do
      begin
        k:=k+Kdx^.Dat.Division[ii];
        k1:=k1+Kdx^.Dat.DivisionR[ii];
      end;
      if k-k1>=StrToInt(P^.Dat.Element[i].Kol) then
      begin
        s:='';
        format(P^.Dat.Element[i].BazKod,CArtikul);
        sKol:=IntToStr(k-k1,CKOl);
        format(sKol,CKol);
        s:=sKol+P^.Dat.Element[i].BazKod;
        M^.List^.Insert(NewStr(s));
        M^.SetRange(M^.List^.Count);
        find:=true;
      end;
    end;
  end;

    jk:=IOResult;
    close(KdxFile);
    jk:=IOResult;

    if find then
    begin
      FindAllKol:=copy(M^.GetText(0,M^.List^.Count),1+CKol,CArtikul);
    end
    else FindAllKol:=kod;


   Dispose(kdx,Done);
   Dispose(M,Done);

   memc(kod+' !!!');

End;

BEGIN
END.

