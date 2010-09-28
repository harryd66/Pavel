Unit ODK;
INTERFACE

Uses Dialogs, Utils,ServStr,StatTols;

Procedure ODKConcurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska7;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;
StartDatetov,StOpDatetov:TDAteString;Otdel:Word;KKK:Word);


IMPLEMENTATION
Uses Serv,Drivers,Glob,TpDate,Tools,Printers,DbEngine,DbEngin2,
     ServStr2,NetDbEng,Objects,Slava2,Prise,Dos,
	App,Views,MsgBox,Utils5,Utils4;

const BufferNewItog = 70;

Type BufNewItogType = Record
     Dat : Array [1..BufferNewItog] Of NewItogType;
     end;


Procedure ODKConcurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska7;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;
StartDatetov,StOpDatetov:TDAteString;Otdel:Word;KKK:Word);

label l1,l2;

Var
    pf: file of NewItogType;
    R   : TRect;
    Cur : LongInt;
    s,ws,ss   : String;
    txt,txt1,txt2 : Text;
    i : Word;
    NItg: PNewItogType;
    Agent, ItogBox : PBox;
    LStart,LStop,OstNach: LongInt;
    ostDate: TDAteString;
    Result,Result2,Result3, Result4 : PBox;
    sclKod,sclKodClient,sagKod,ReKod : AllStr;
    c : Word;
    Event : TEvent;
    MMM : Maska8;
    sKOlMrk,sKolREt : String[CDate];
    Kraft: word;
    bKraft: boolean;
    sArt: string[CArtikul];
    sKol,sKolV,sDoc: string[CDate];
    sSumma,sSummaV: string[CIZena];
    sFas,sMassa: string[CZena];
    AllEnable: longint;
    AllSkl: Maska30;
    tekSkl: word;
    sINN: AllStr;
    SklKOd: string [2];
    IORez,Count,c1: word;
    Kols:string[CKol];
    cc: word;
    Prf: PrihodFileType;
    P: PPrihodType;

 procedure AddObToList(var It: PBox; e:NewItogType; start: boolean);
 var Find: boolean;
     sKOl: string[CKol];
     sArt, sArt1: ArtikulStr;
     i,j: word;
     stek, sit: string;
 Begin
     find:=False;
     sArt:=e.BazKod;

     if It^.List^.Count>0 then
     for i:=0 to It^.List^.Count do
     begin
       sIt:=It^.GetText(i,It^.List^.Count);
       sArt1:=copy(sIt,1,CArtikul);
       if sArt=sArt1 then
         begin
           {Строка уже есть}
           find:=true;
           if Start then
           begin
             sKOl:=copy(sIt,1+CArtikul+1,CKol);
             sKol:=IntToStr(StrToInt(sKOl)+StrToInt(E.Ost),CKol);
             format(sKOl,CKol);
             System.Delete(sIt,1+CArtikul+1,CKol);
             System.Insert(sKol,sIt,1+CArtikul+1);
           end
           else
           begin
             sKOl:=copy(sIt,1+CArtikul+1+CKol+1,CKol);
             sKol:=IntToStr(StrToInt(sKOl)+StrToInt(E.Ost),CKol);
             format(sKOl,CKol);
             System.Delete(sIt,1+CArtikul+1+CKol+1,CKol);
             System.Insert(sKol,sIt,1+CArtikul+1+CKol+1);
           end;
           It^.List^.AtFree(i);
           It^.SetRange(It^.List^.Count);
           It^.List^.Insert(NewStr(sIt));
           It^.SetRange(It^.List^.Count);
           break;
         end;
      end;

    if not find then
    begin
     if Start then
     begin
       sArt:=NItg^.Dat.BazKOd;
       rformat(sArt,CArtikul);
       sIt:=sArt+';';
       sKol:=NItg^.Dat.Ost;
       rformat(sKOl,CKOl);
       sIt:=sIt+sKol+';';
       sKol:='0';
       rformat(sKOl,CKOl);
       sIt:=sIt+sKol+';';
       ItogBox^.List^.Insert(NewStr(s));
       ItogBox^.SetRange(ItogBox^.List^.Count);
     end
     else
     begin
       sArt:=NItg^.Dat.BazKOd;
       rformat(sArt,CArtikul);
       sIt:=sArt+';';
       sKol:='0';
       rformat(sKOl,CKOl);
       sIt:=sIt+sKol+';';
       sKol:=NItg^.Dat.Ost;
       rformat(sKOl,CKOl);
       sIt:=sIt+sKol+';';
       ItogBox^.List^.Insert(NewStr(s));
       ItogBox^.SetRange(ItogBox^.List^.Count);
     end;
    end;

 End;



Function TestAgentSpecial (Const ACod:ArtikulStr ;Const P : PBox) : Boolean;
Var ls : Word;
    k  : Byte;
    st : TMyString;
    AgKod,ClKod,ArtKod : ArtikulStr;
Begin
TestAgentSpecial:=False;
For ls :=0 To P^.List^.Count Do
Begin
 St:=P^.GetText(ls,P^.List^.Count);
 st:=Copy(St,1+1,CClientKod);{код агента}
 If (ACod=St) Then
   Begin
    TestAgentSpecial:=True;
    Break;
   End;
End;
end;


Procedure AddODKMrk(Var P:PBox;Art:ArtikulStr;KodAg,ClKod:ArtikulStr;
                 Kol,RetKol:AllStr;SumOpl,RetSumOpl,SumZ,RetSumZ,Doc:AllStr;sDate:TDateString;
                 bKraft: boolean);
Label 2,3,4;
Var ss,st,st2,st3,st4 : String;
    BiloSumOpl,BiloRetSumOpl,BiloKol,BiloReturnKol,
    BiloRetSummaZ,BiloSummaZ : AllStr;
    ls,c : Word;
    Find : Boolean;
Begin
Find:=False;

{проверяем есть позиция или нет}
For ls :=0 To P^.List^.Count Do
Begin

St:=P^.GetText(ls,P^.List^.Count);
st2:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1,CClientKod);{код агента}
st3:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1,CArtikul);{код клиента}
st4:=Copy(St,1,CDate);
st:=Copy(St,1+CDate+1+CNAme+1,CArtikul);{код товара}
rFormat(Doc,CDate);

If (Art=St) And (KodAg=St2) And (ClKod=St3) And ((sDate=st4) ) Then
   Begin
    Find:=True;
    Break;
   End;

End;{for}

  If (Not (Find))  And (P^.List^.Count>=MaxCollectionSize-1) Then
   Begin
    MessageBox(^M+#3+'Переполнение коллекции!',Nil,mfError+mfCancelButton);
    Exit;
   End;

  DelSpace(KodAg);
  RFormatZerro(KodAg,CCLientKod);
  DelSpace(ClKod);
  RFormatZerro(ClKod,CArtikul);
  DelSpace(Kol);
  RFormat(Kol,CDate);
  DelSpace(RetKol);
  RFormat(RetKol,CDate);
  DelSpace(SumOpl);
  RFormat(SumOpl,CIZena);
  DelSpace(RetSumOpl);
  RFormat(RetSumOpl,CIZena);
  DelSpace(SumZ);
  RFormat(SumZ,CIZena);
  DelSpace(RetSumZ);
  RFormat(RetSumZ,CIZena);


  st:=GetIdField(FName,Art);
  Format(st,CName);
  DelSpace(Art);
  RFormatZerro(Art,CArtikul);
  RFormat(Doc,CDate);

  st:=sDate+'│'+st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl+'│'+SumZ+'│'+
  RetKol+'│'+RetSumOpl+'│'+RetSumZ+'│'+dOC;

  P^.List^.Insert(NewStr(st));
  P^.SetRange(P^.List^.Count);

Exit;


End;{AddMrk}


Procedure ConcursODKCalcMrk(mmm:Maska8;l:LongInt;Const VArList,Agent:PBox; Const SClient:MAska3;
Const SVidDocTov:MAska9;Var Result: PBox;bKraft:boolean);
Var
   cc,count,i : Word;
   E  : PBufSuperMarketType;
   V: PNewVozwratType;
   ef : File;
   vf : File of NewVozwratType;
   skol,SumOpl,SumZ,Ssum,ssumz :AllStr;
   Artikul : ArtikulStr;
   ws : String;
   k,j,r : Byte;
   Pos : LongInt;
   OldFileMode : word;
Begin

{Продажи}
 Assign(eF,Path^.Dat.ToMarket+DateToDAteString(DAteMask,L)+'.mrk');
 i:=IOResult;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(ef,SizeOf(SuperMarketType));
 i:=IOResult;
 FileMode:=OldFileMode;
If i<>0 Then
  Begin
   {Exit;}
  End
Else
BEGIN {i=0}
 While Not(Eof(ef)) Do
  Begin
   cc:=0;
   New(E,Init);
   ReadBufMarket(Ef,E,Count);

For cc:=1 To Count Do
Begin
   If E^.Point.Dat[cc].Active Then
Begin
  If Not((E^.Point.Dat[cc].OperatorSelector=1) And (E^.Point.Dat[cc].ClientKod=ClientRP)) Then
  Begin
   If Not ((E^.Point.Dat[cc].Realiz) And (E^.Point.Dat[cc].DocSelector in [0,1,2,3,4])) Then
   Begin
   If (*((SVidDocTov[E^.Point.Dat[cc].DocSelector+1]=1)  And *)(E^.Point.Dat[cc].OperatorSelector in [0,2])
    (*Or (E^.Point.Dat[cc].OperatorSelector=1)*)  Then
     Begin

        For j:=1 To E^.Point.Dat[cc].Amount Do
         Begin
          Pos:=0;

Begin

  {проверяем по списку позиций}

  if Not TestElement(E^.Point.Dat[cc].MarketElement[j].BazKod,VarList) Then
           Begin

            DelSpace(E^.Point.Dat[cc].MarketElement[j].Input.Kol);
            DelSpace(E^.Point.Dat[cc].MarketElement[j].Input.Zakupka);
            DelSpace(E^.Point.Dat[cc].MarketElement[j].Input.Zakupka2);

            MyStr(StrToReal(E^.Point.Dat[cc].MarketElement[j].Input.Zena)*
		        StrToInt(E^.Point.Dat[cc].MarketElement[j].Input.Kol),CIZena,CMantissaZ,SumZ);
              {просчитываем сумму к оплате}
            If E^.Point.Dat[cc].OperatorSelector in [0,2] Then
            Begin
              If E^.Point.Dat[cc].SkidkaSelector=0 Then
               Begin
                DelSpace(E^.Point.Dat[cc].MarketElement[j].Input.Proz);
                MyStr((StrToReal(E^.Point.Dat[cc].MarketElement[j].Input.Zena)/
                (1+StrToReal(E^.Point.Dat[cc].MarketElement[j].Input.Proz)/100)),CZena,CMantissa,
                         E^.Point.Dat[cc].MarketElement[j].Input.Zena);
               End
                Else
               Begin
                {сумма скидки}
                MyStr((StrToReal(E^.Point.Dat[cc].MarketElement[j].Input.Zena)-
                         StrToReal(E^.Point.Dat[cc].MarketElement[j].Input.Skidka)),
                         CZena,CMantissa,
                                        E^.Point.Dat[cc].MarketElement[j].Input.Zena);
               End;
            End
              Else
                MyStr(StRToReal(E^.Point.Dat[cc].MarketElement[j].Input.Zena),CZena,CMantissa,
                         E^.Point.Dat[cc].MarketElement[j].Input.Zena);


            MyStr(StrToReal(E^.Point.Dat[cc].MarketElement[j].Input.Zena)*
		        StrToInt(E^.Point.Dat[cc].MarketElement[j].Input.Kol),CIZena,CMantissaZ,SumOpl);
            SKol:=E^.Point.Dat[cc].MarketElement[j].Input.Kol;

            AddODKMrk(Result,E^.Point.Dat[cc].MarketElement[j].BazKod,
		  E^.Point.Dat[cc].AgentKod,
		        IntToStr(E^.Point.Dat[cc].OperatorSelector,COne)+E^.Point.Dat[cc].ClientKod,
		        SKol,'0',SumOpl,'0.00',SumZ,'0.00',E^.Point.Dat[cc].Document,E^.Point.Dat[cc].DateC,bKraft);
           End;
End;
         End;{For по накладной}
      {код расчета}
     End;
   End;
  End;
End;{Active}
End;{For}
Dispose(E,Done);
  End;{While}

 i:=IOResult;
Close(ef);
 i:=IOResult;

END;
{возвраты}

 Assign(vF,Path^.Dat.ToReturn+DateToDAteString(DAteMask,L)+'.vzw');
 i:=IOResult;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(vf);
 i:=IOResult;
 FileMode:=OldFileMode;
 If i<>0 Then
  Begin
   {Exit;}
  End
ELSE
BEGIN
New(V,Init);
While Not(Eof(vf)) Do
  Begin

   Read(vf,V^.Dat);

{If V^.Dat.Active Then}
Begin
  Begin
   Begin
     Begin

        For j:=1 To V^.Dat.Amount Do
         Begin
          Pos:=0;

Begin

  {проверяем по списку позиций}

  if Not TestElement(V^.Dat.VozwratElement[j].BazKod,VarList) Then
           Begin

            DelSpace(V^.Dat.VozwratElement[j].Input.Kol);
            DelSpace(V^.DAt.VozwratElement[j].Input.Zakupka);
            DelSpace(V^.Dat.VozwratElement[j].Input.Zakupka2);

            MyStr((StrToReal(V^.Dat.VozwratElement[j].Input.R_Zena)-
            StrToReal(V^.Dat.VozwratElement[j].Input.LocalSkidka))*
		        StrToInt(V^.Dat.VozwratElement[j].Input.Kol),CIZena,CMantissaZ,SumZ);

            MyStr(StrToReal(V^.Dat.VozwratElement[j] .Input.Zena)*
		        StrToInt(V^.Dat.VozwratElement[j].Input.Kol),CIZena,CMantissaZ,SumOpl);
            SKol:=INtToStr(-StrToInt(V^.Dat.VozwratElement[j].Input.Kol),CDate);

            AddODKMrk(Result,V^.Dat.VozwratElement[j].BazKod,
		  '0000',
		  '0'+V^.Dat.MakeKod,
		        '0',SKol,'0.00',SumZ,'0.00',SumOpl,V^.Dat.Document,V^.Dat.DateC,bKraft);
           End;
End;
         End;{For по накладной}
      {код расчета}
     End;
   End;
  End;
End;{Active}

  End;{While}

Dispose(V,Done);

 i:=IOResult;
Close(vf);
 i:=IOResult;
End;

End; {procedure}


BEGIN


 Assign(txt,Path^.Dat.ToTemp+'ok1'+'.csv');
 i:=IOResult;
 Rewrite(txt);
 i:=IOResult;
 If i<>0 Then
  Begin
   Dispose(Agent,Done);
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'odk1'+'.csv',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Assign(txt1,Path^.Dat.ToTemp+'ok2'+'.csv');
 i:=IOResult;
 Rewrite(txt1);
 i:=IOResult;
 If i<>0 Then
  Begin
   Dispose(Agent,Done);
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'odk2'+'.csv',Nil,mfError+mfCancelButton);
   Close(txt);
   Exit;
  End;

 Assign(txt2,Path^.Dat.ToTemp+'ok3'+'.csv');
 i:=IOResult;
 Rewrite(txt2);
 i:=IOResult;
 If i<>0 Then
  Begin
   Dispose(Agent,Done);
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'odk3'+'.csv',Nil,mfError+mfCancelButton);
   close(txt);
   Close(txt2);
   Exit;
  End;

R.Assign(0, 0, 0, 0);
Result := New(PBox, Init(R, 1, Nil));
Result^.NewList(New(PTextCollection, Init(0,1)));


  LStart:=DateStringToDate(DateMask,StartDatetov);{начало периода}
  LStop :=DateStringToDate(DateMask ,StopDatetov);{конец периода}

writeln(txt2,'REP_DATE;CODE_TTN;CODE_PROD;WEIGHT;ID_FACTORY');

  For cur:=Lstart To LStop Do
  Begin
    DInfoMsgShkala('Просматриваю операции за '+DateToDateString(DateMask,Cur)+' ...',LStart,LStop,Cur);

   ConcursODKCalcMrk(mmm,cur,VarList,Agent,SClient,SVidDocTov,Result,bKraft);


   new(P,Init);

   Assign(Prf,Path^.Dat.ToPrihod+DateToDateString(DateMask,Cur)+'.prh');
   CC:=ioresult;
   Reset(PrF);
   CC:=ioresult;
   if CC=0 then
   BEGIN
    while not eof(Prf) do
    begin
      read(Prf,P^.Dat);
      if P^.Dat.OperatorSelector in [0,2] then
      for count:=1 to P^.Dat.Amount do
      begin
        sArt:=P^.Dat.PrihodElement[count].BazKod;
        if Not TestElement(sArt,VarList) Then
           begin
            write(txt2,P^.Dat.DateC+';');
            write(txt2,DosToWin(P^.Dat.Rekwizit.Numer)+';');
            write(txt2,sArt+';');
            MyStr(StrToReal(GetIDField(FMassa,sArt))*StrToReal(P^.Dat.PrihodElement[count].Input.Kol),CDate,CMantissa,sMassa);
            write(txt2,sMassa+';');
            writeln(txt2,DosToWin(GetFirmaPostField(FFirmaPost,GetIdField(FFirmaPost,sArt))));
           end;
      end;
     end;
     close(prF);
    end;

   Dispose(p,Done);

  End;
 NoInfoMsg;

  writeln(txt,DosToWin('REP_DATE;CODE_TTN;CODE_CLN;CODE_PROD;WEIGHT;QNT;S_NDS_DISC;SUM_NDS;SUM_DISC;CODE_TP'));

  If (Result<>nil) and (Result^.List^.Count>0) then
  for i:=0 to Result^.List^.Count-1 do
  begin
   s:=Result^.GetText(i,Result^.List^.Count);
   While Pos('│',s)>0 Do s[Pos('│',s)]:=';';
  { Дата }
  ss:=copy(s,1,CDate)+';';
  { Номер док }
  sDoc:=copy(s,length(s)-CDate+1,CDate);
  ss:=ss+sDoc+';';
  { Код клиента }
  sclKod:=copy(s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1,CArtikul);
  ss:=ss+sclKod+';';
  { код товара }
  sArt:=copy(s,1+CDate+1+CName+1,CArtikul);
  ss:=ss+sArt+';';
 sKol:=copy(s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1+CArtikul+1,CDate);
 if StrToInt(sKol)=0 then  {возврат}
    sKol:=copy(s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIzena+1+CIZena+1,CDate);
  {  вес  }
  if StrToInt(sKol)>0 then
  MyStr(StrToReal(GetIDField(FMassa,sArt))*StrToReal(sKol),CDate,CMantissa,sMassa)
  else MyStr(-StrToReal(GetIDField(FMassa,sArt))*StrToReal(sKol),CDate,CMantissa,sMassa);
  ss:=ss+sMassa+';';
  {  кол-во }
  ss:=ss+sKol+';';
  {  оплата }
  if StrToInt(sKol)>0 then
  ss:=ss+copy(s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIzena)+';'
  else ss:=ss+copy(s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIzena+1+CIzena+1+CDate+1,CIzena)+';';
  {  лоб }
  if StrToInt(sKol)>0 then
  ss:=ss+copy(s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIzena+1,CIZena)+';'
else ss:=ss+copy(s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIzena+1+CIzena+1+CDate+1+CIzena+1,CIzena)+';';
  {  без ндс - пусто }
  ss:=ss+';';
  {  код агента }
  ss:=ss+copy(s,1+CDate+1+CName+1+CArtikul+1,CClientKod);

   writeln(txt,DosToWin(ss));

  end;

writeln(txt1,DosToWin('REP_DATE;CODE_PROD;WEIGHT'));

New(NItg,Init);

      OstNach:=LStop;
      ostDate:=DateToDateString(DateMask,OstNach);
      while pos('-',ostdate)>0 do delete(ostdate,pos('-',ostdate),1);
      if ostDate[1]='0' then delete(ostdate,1,1);
      SklKOd:=IntToStr(StrToInt(Rek^.Dat.KOd),CRazdelKod);
      RformatZerro(SklKOd,CRAzdelKOd);

      if FExists (Path^.Dat.ToArchiv+ostDate+'.p'+sklKod) then
      begin
        Assign(pf,Path^.Dat.ToArchiv+ostDate+'.p'+sklKod);
        ioRez:=ioresult;
        Reset(pf);
        ioRez:=ioresult;

      DInfoMsg('Просматриваю остатки за '+DateToDateString(DateMask,OstNach)+' ...',False);
      while not eof(pf) do
      begin
        Read(pf,NItg^.Dat);
        Begin
           sArt:=NItg^.Dat.BazKOd;
           if Not TestElement(sArt,VarList) Then
           begin
            write(txt1,DateToDateString(DateMask,OstNach)+';');
            write(txt1,sArt+';');
            MyStr(StrToReal(GetIDField(FMassa,sArt))*StrToReal(NItg^.Dat.Ost),CDate,CMantissa,sMassa);
            writeln(txt1,sMassa);
           end;
          end;
        end;
      close(pf);
    NoinfoMsg;
     End; {if FExists (Path^.Dat.ToAr}



   Close(txt);
   Close(txt1);
   Close(txt2);

END;

BEGIN

END.
