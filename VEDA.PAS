Unit Veda;
{Отчет для поставщиков с детализацией отгрузок по клиентам
разрабатываля изначально для Веды, но Стас охотно юзает его и для других
Вызов  Utils4.pas SelectImport(35) - NewSItem('Для ХЗ кого', (возможны варианты)
       TStat.pas - в case reg:
        VedaConcurs(SelectNameList,OperationFiltr,SVidOperation,OperationToV,SClient,Filtr,SVidDocTov,
               OplataToV,SStatusOplata,StartDatetov,StOpDatetov,Otdel,2);
        последний параметр 2 лучше не трогать, хотя по идее отчету пох.....}
INTERFACE

Uses Dialogs, Utils,ServStr,StatTols;

Procedure VedaConcurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska7;
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


Procedure VedaConcurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska7;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;
StartDatetov,StOpDatetov:TDAteString;Otdel:Word;KKK:Word);

label l1,l2;

Var
    pf: file;
    R   : TRect;
    Cur : LongInt;
    s   : String;
    txt : Text;
    i : Word;
    NItg: PNewItogType;
    Agent, ItogBox : PBox;
    LStart,LStop,OstNach: LongInt;
    ostDate: TDAteString;
    Result,Result2,Result3, Result4 : PBox;
    sclKod,sclKodClient,sagKod,ReKod,sVedaKod : AllStr;
    sName: string[CName+1+Cartikul+1];
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
    BufItog: BufNewItogType;
    Kols:string[CKol];
    cc: word;

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


Procedure AddVedaMrk(Var P:PBox;Art:ArtikulStr;KodAg,ClKod:ArtikulStr;
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


Procedure ConcursVedaCalcMrk(mmm:Maska8;l:LongInt;Const VArList,Agent:PBox; Const SClient:MAska3;
Const SVidDocTov:MAska9;Var Result: PBox;bKraft:boolean);
Var
   cc,count,i : Word;
   E  : PBufSuperMarketType;
   ef : File;
   skol,SumOpl,SumZ,Ssum,ssumz :AllStr;
   Artikul : ArtikulStr;
   ws : String;
   k,j,r : Byte;
   Pos : LongInt;
   OldFileMode : word;
Begin

 DelSpace(PathSklads^.Dat.Path[TekSkl]);
 Assign(eF,PathSklads^.Dat.Path[TekSkl]+'MARKET\'+DateToDAteString(DAteMask,L)+'.mrk');
 i:=IOResult;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(ef,SizeOf(SuperMarketType));
 i:=IOResult;
 FileMode:=OldFileMode;
 If i<>0 Then
  Begin
   Exit;
  End;

 While Not(Eof(ef)) Do
  Begin
   cc:=0;
   New(E,Init);
   ReadBufMarket(Ef,E,Count);

For cc:=1 To Count Do
Begin
   If E^.Point.Dat[cc].Active Then
Begin
  {тот ли агент}
  {If (Stat^.Point[StrToInt(E^.Point.Dat[cc].AgentKod)].Employ) Then}
  {If TestAgentSpecial(E^.Point.Dat[cc].AgentKod,Agent) Then}
 (* If (SClient[E^.Point.Dat[cc].OperatorSelector+1]=1) Then{фильтр группы операций}*)

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

(*if MMM[E^.Point.Dat[cc].MarketElement[j].Input.DivisionNumber]=1 Then*)
Begin

  {проверяем по списку позиций}

  if Not TestElement(E^.Point.Dat[cc].MarketElement[j].BazKod,VarList) Then
           Begin

            DelSpace(E^.Point.Dat[cc].MarketElement[j].Input.Kol);
            DelSpace(E^.Point.Dat[cc].MarketElement[j].Input.Zakupka);
            DelSpace(E^.Point.Dat[cc].MarketElement[j].Input.Zakupka2);

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

            If EnableZakupka=1 Then
            MyStr(StrToReal(E^.Point.Dat[cc].MarketElement[j].Input.Zakupka)*
		        StrToInt(E^.Point.Dat[cc].MarketElement[j].Input.Kol),CIZena,CMantissaZ,SumZ)
            Else SumZ:=CodeSummaZ;

            SKol:=E^.Point.Dat[cc].MarketElement[j].Input.Kol;

            AddVedaMrk(Result,E^.Point.Dat[cc].MarketElement[j].BazKod,
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


End;




BEGIN

 {Выбор складов}
 AllEnable:=AllSKlads;
 If Not SelAssortiment(AllEnable) Then Exit;
 WordToBit30(AllEnable,AllSkl);
 Convert30(AllSkl);



 Assign(txt,Path^.Dat.ToTemp+'veda'+'.csv');
 i:=IOResult;
 Rewrite(txt);
 i:=IOResult;
 If i<>0 Then
  Begin
   Dispose(Agent,Done);
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'veda'+'.csv',Nil,mfError+mfCancelButton);
   Exit;
  End;

R.Assign(0, 0, 0, 0);
Result := New(PBox, Init(R, 1, Nil));
Result^.NewList(New(PTextCollection, Init(0,1)));


  writeln(txt,DosToWin('главная'));
  write(txt,DosToWin('7104024633;'));
  write(txt,DosToWin('ООО ТД Триада-Сервис;'));
  write(txt,StartDatetov+';'+StopDatetov+';');
  write(txt,DosToWin(Rek^.Dat.KOd)+'0;');
  writeln(txt,DosToWin(Rek^.Dat.Adress)+';');

  LStart:=DateStringToDate(DateMask,StartDatetov);{начало периода}
  LStop :=DateStringToDate(DateMask ,StopDatetov);{конец периода}

for TekSkl:=1 to CMaxSklads do
begin
if AllSkl[TekSkl]=1 then
  For cur:=Lstart To LStop Do
  Begin
    DInfoMsgShkala('Просматриваю операции за '+DateToDateString(DateMask,Cur)+' ...',LStart,LStop,Cur);

   ConcursVedaCalcMrk(mmm,cur,VarList,Agent,SClient,SVidDocTov,Result,bKraft);

  End;
 NoInfoMsg;
end;

  writeln(txt);
  writeln(txt,DosToWin('товар - движение по складу'));

  If (Result<>nil) and (Result^.List^.Count>0) then
  for i:=0 to Result^.List^.Count-1 do
  begin
   s:=Result^.GetText(i,Result^.List^.Count);
   While Pos('│',s)>0 Do s[Pos('│',s)]:=';';
   sDoc:=copy(s,length(s)-CDate+1,CDate);
   {Наименование}
   sVedaKOd:=GetIDField(FMetroKod,copy(s,1+CDate+1+CName+1,CArtikul));
   sVedaKOd:=IntToStr(StrToInt(sVedaKod),CArtikul);
   format(sVedaKOd,CArtikul);
   System.Delete(s,1+CDate+1+CName+1,CArtikul);
   System.Insert(sVedaKOd,s,1+CDate+1+CName+1);
   sName:=copy(s,1+CDate+1,1+CName+1+CArtikul);
   sName:=copy(sName,1+CName+1,CArtikul)+';'+copy(sName,1,CName+1);
   {Клиент}
   sclKod:=copy(s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1,CArtikul);
   sInn:=GetClientField(FINN,copy(sclKod,2,CCLientKod),StrToInt(copy(sclKod,1,COne)));
   DelSpace(sINN);

 (*  if length(sInn)>=9 then   *)
   begin
     System.Insert(sInn+';;'+
     GetClientField(FAdress,copy(sclKod,2,CCLientKod),StrToInt(copy(sclKod,1,COne)))
     +';'+sDoc+';;;'+sName,
     s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1+CClientKod+1+1);
     System.Insert(GetClientField(FAgent,copy(sclKod,2,CCLientKod),
     StrToInt(copy(sclKod,1,COne)))+';',
     s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1);
   end;
(*   else
   begin
     System.Insert(';;'+
     'частное лицо'+';'+sDoc+';;;'+sName,
     s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1+CClientKod+1+1);
     System.Insert('частное лицо'+';',
     s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1);
   end;        *)
   {Агент}
   sclKod:=copy(s,1+CDate+1+CName+1+CArtikul+1,CClientKod);
   System.Insert(GetAgentField(FAgent,sclKod)+';',s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1);

   System.Delete(s,1+CDate+1,1+CName+1+CArtikul);

   system.Insert(copy(s,1,CDate)+';0;',s,1+CDate+1);
   s:=IntToStr(i+1,5)+';;'+s;
   writeln(txt,DosToWin(s));

  end;

  writeln(txt);
  writeln(txt,DosToWin('товар - остатки товара'));

New(NItg,Init);

R.Assign(0, 0, 0, 0);
ItogBox := New(PBox, Init(R, 1, Nil));
ItogBox^.NewList(New(PTextCollection, Init(0,1)));

cc:=0;

for TekSkl:=1 to CMaxSklads do
begin
if AllSkl[TekSkl]=1 then
  Begin
      OstNach:=LStart-1;
l1:   ostDate:=DateToDateString(DateMask,OstNach);
      while pos('-',ostdate)>0 do delete(ostdate,pos('-',ostdate),1);
      if ostDate[1]='0' then delete(ostdate,1,1);
      SklKOd:=IntToStr(TekSkl,2);
      RformatZerro(SklKOd,CRAzdelKOd);
      if FExists (PathSklads^.Dat.Path[TekSkl]+'arc\'+ostDate+'.p'+sklKod) then
      begin
        inc(cc);
        Assign(pf,PathSklads^.Dat.Path[TekSkl]+'arc\'+ostDate+'.p'+sklKod);
        ioRez:=ioresult;
        Reset(pf,SizeOf(NewItogType));
        ioRez:=ioresult;
      end
      else
      begin
          dec(OstNach);
          if ostNach>LStart-1 then goto l1;
          continue;
      End;

      DInfoMsg('Просматриваю остатки за '+DateToDateString(DateMask,OstNach)+' ...',False);
      while not eof(pf) do
      begin
        Count:=0;
        BlockRead(pf,BufItog.Dat,BufferNewItog,Count);
        For c1:=1 To Count Do
        Begin
           NItg^.Dat:=BufItog.Dat[c1];

           if (NItg^.Dat.NMakeKod ='00307') or (NItg^.Dat.NMakeKod ='00287') then
            if cc=1 then
              begin
               sArt:=NItg^.Dat.BazKOd;
               rformat(sArt,CArtikul);
               s:=sArt+';';
               Kols:=NItg^.Dat.Ost;
               rformat(KOls,CKOl);
               s:=s+Kols+';';
               Kols:=' 0';
               rformat(KOls,CKOl);
               s:=s+Kols+';';
               ItogBox^.List^.Insert(NewStr(s));
               ItogBox^.SetRange(ItogBox^.List^.Count);
             end
             else AddObToList(ItogBox,NItg^.Dat,true);

          end;
        end;
      close(pf);
    NoinfoMsg;
end;
end;

for TekSkl:=1 to CMaxSklads do
begin
if AllSkl[TekSkl]=1 then
  Begin
      OstNach:=LStop;
l2:   ostDate:=DateToDateString(DateMask,OstNach);
      while pos('-',ostdate)>0 do delete(ostdate,pos('-',ostdate),1);
      if ostDate[1]='0' then delete(ostdate,1,1);
      SklKOd:=IntToStr(TekSkl,2);
      RformatZerro(SklKOd,CRAzdelKOd);
      if FExists (PathSklads^.Dat.Path[TekSkl]+'arc\'+ostDate+'.p'+sklKod) then
      begin
        inc(cc);
        Assign(pf,PathSklads^.Dat.Path[TekSkl]+'arc\'+ostDate+'.p'+sklKod);
        ioRez:=ioresult;
        Reset(pf,SizeOf(NewItogType));
        ioRez:=ioresult;
      end
      else
      begin
          dec(OstNach);
          if ostNach>LStop-1 then goto l2;
          continue;
      End;

      DInfoMsg('Просматриваю остатки за '+DateToDateString(DateMask,OstNach)+' ...',False);
      while not eof(pf) do
      begin
        Count:=0;
        BlockRead(pf,BufItog.Dat,BufferNewItog,Count);
        For c1:=1 To Count Do
        Begin
           NItg^.Dat:=BufItog.Dat[c1];
           if (NItg^.Dat.NMakeKod ='00307') or (NItg^.Dat.NMakeKod ='00287') then
              AddObToList(ItogBox,NItg^.Dat,false);
        end;
      end;
      close(pf);
    NoinfoMsg;


  End;
end;


  If (ItogBox<>nil) and (ItogBox^.List^.Count>0) then
  for i:=0 to ItogBox^.List^.Count-1 do
  begin
   s:=ItogBox^.GetText(i,Result^.List^.Count);
   sArt:=copy(s,1,CArtikul);
   {Подстановка Ведовских кодов}
   sVedaKOd:=GetIDField(FMetroKod,sArt);
   sVedaKOd:=IntToStr(StrToInt(sVedaKod),CArtikul);
   format(sVedaKOd,CArtikul);
   System.Delete(s,1,CArtikul);
   System.Insert(sVedaKOd,s,1);

   System.Insert(GetIDField(FName,sArt)+' '+GetIDField(FName2,sArt)+';',s,1+CArtikul+1);
   writeln(txt,DosToWin(s+'1;'));
  end;

   Dispose(NItg,Done);
   Close(txt);

END;

BEGIN

END.
