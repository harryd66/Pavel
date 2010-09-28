{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit UchDoh;

INTERFACE

Uses Glob,Servstr,Utils,Dialogs, DosWin;

Procedure ReportRashoDohod(Const Spis:PBox;Const M:MaskaNew;Const Sort:Word);

procedure ProzNdsDay;
procedure to1s;
procedure CalcRashodDohod;
procedure CalcPost;
procedure CalcMarket;
procedure SetNullNDS(MakeKod:ArtikulStr;Null:Boolean);
function GetNullNDS(MakeKod:ArtikulStr):boolean;


IMPLEMENTATION
Uses Prise,Objects,Tools,MSGBox, DBEngine,Serv,
     Printers, TPDate,NetDBEng,Vision1,Utils2;

CONST MSG='Просматриваю продажи за ';
      posDate = 1;
      posDocument = posDate+CDate+1;
      posName = posDocument+CDocNumer+1;
      posKod = posName+CName+1;
      posZC = posKod+CArtikul+1;
      posKOl = posZC+CZena+1;
      posSumZC =posKOl+CKOl+1;
      posOplataNDS =posSumZC+CIZena+1;
      posNds = posOplataNDS+CZena+1;   {НДС из цены!!!}
      posOplata = posNds+CZena+1;
      posSumOplataNDS = posOplata+CZena+1;
      posSumNDS = posSumOplataNDS+CIZena+1;
      posSumOplata = posSumNDS+CIZena+1;
      posSumRez = posSumOplata+CIZena+1;

var NoScreen1: PBox; {1 кв}
    NoScreen2: PBox; {2 кв}
    NoScreen3: PBox; {3 кв}
    NoScreen4: PBox; {4 кв}

    Rep1: PBox;
    Rep2: PBox;
    Rep3: PBox;
    Rep4: PBox;


    RBox: PBox;

procedure SetNullNDS(MakeKod:ArtikulStr;Null:Boolean);
var iorez: word;
    f: file of word;
    n: word;
Begin
  DelSpaceRight(MakeKod);
  Assign(f,Path.ToClient+MakeKod+'.nds');
  iorez:=ioresult;
  Rewrite(f);
  iorez:=ioresult;
  if iorez<>0 then
  begin
  end;
  iorez:=ioresult;
  n:=0;
  if Null then n:=1;
  write(f,n);
  iorez:=ioresult;
  System.close(f);
  iorez:=ioresult;
End;

function GetNullNDS(MakeKod:ArtikulStr):boolean;
var iorez: word;
    f: file of word;
    Null: word; {0-no NullNds, 1-yes NullNDS}
Begin
  GetNullNDS:=false;
  DelSpaceRight(MakeKod);
  Assign(f,Path.ToClient+MakeKod+'.nds');
  iorez:=ioresult;
  Reset(f);
  iorez:=ioresult;
  if iorez<>0 then
  begin
    exit;
  end;
  read(f,Null);
  iorez:=ioresult;
  System.Close(f);
  iorez:=ioresult;
  if Null=1 then GetNullNDS:=true;
End;

procedure CalcRashodDohod;
Begin
 Selection(14);
End;

procedure WriteShapka(var t: text);
Begin
 Write(t,DosToWin(';;;;;Стоимостные показатели материальных ресурсрв на выпущенную готовую продукцию,'
 +'выполненные работы,оказанные услуги'));
 Write(t,DosToWin(';;;Стоимостные показатели подлежащих реализации товаров, работ, услуг'));
 Write(t,DosToWin(';;Стоимостные показатели реализованных товаров, выполненных работ, оказанных услуг по единице(руб.)'));
 Writeln(t,DosToWin(';;;;Стоимостные показатели реализованных товаров, выполненных работ,оказанных услуг'));

 Write(t,DosToWin('N п/п;Дата операции;Номер документа;Наименование приобретенных, изготоаленных товаров, '
 +'выполненных работ,оказанных услуг;'));
Write(t,DosToWin('Единица измерения;Стоимость единицы товара;Количество;Общая стоимомсть готовой подукции без НДС и НП;'));
Write(t,DosToWin('Количество;Общая стоимость;Рыночная цена без учета НДС и НП;Сумма НДС;Сумма НП;Общая стоимость;Количество;'
  +'Сумма дохода;Сумма НДС;Общая сумма с НДС;'));
Writeln(t,DosToWin('Сумма НП;Общая стоимость со всеми налогами;Результат от сделки'));
writeln(t,'1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21');
End;

Procedure ReportRashoDohod(Const Spis:PBox;Const M:MaskaNew;Const Sort:Word);
var  StartDate,StopDate, sDate:  TDateString;
     Start,Stop,Den:longint;
     R:TRect;
     f:MarketFileType;
     E:PSuperMarketType;
     l: word;
     t,t1: text;
     s: string;
     D, MM, Y : Integer;
     sSumOplata : string [CIZena];
     sKol:string[CKol];
     Count: integer;
     SumMesBNDS,SumMesNDS,SumMesOpl,SumMesRez: string [CIZena];
     SumKvBNDS,SumKvNDS,SumKvOpl,SumKvRez: string [CIZena];
     Sum6BNDS,Sum6NDS,Sum6Opl,Sum6Rez: string [CIZena];
     Sum9BNDS,Sum9NDS,Sum9Opl,Sum9Rez: string [CIZena];
     Sum12BNDS,Sum12NDS,Sum12Opl,Sum12Rez: string [CIZena];
     SumposBNDS,SumposNDS,SumposOpl,SumposRez: string [CIZena];
     sName: string [CName+1];

Function TestElementt (Const S : AllStr;Const P : PBox) : Boolean;
Var ls : Word;
    k  : Byte;
    st : String[CALL];
Begin
TestElementt:=True;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
k:=Pos('│',St);
ST:=Copy(St,K+1,CArtikul);
If St=S Then
   Begin
    TestElementt:=False;
    Break;
   End;
End;
End;


procedure AddMrk(P: PBox; E:SuperMArketType);
const CMantissaZ = 4;
var i: word;
    sDate:string [CDate];
    sDocument:string [CDocNumer];
    sName : string [CName];
    sKod : string [CArtikul];
    sZC : string [CZena];
    sKOl : string [CKOl];
    sSumZC: String[CIZena];
    sOplataNDS : string [CZena];
    sNds : string [CZena];
    sOplata : string [CZena];
    sSumOplataNDS : string [CIZena];
    sSumNDS : string [CIZena];
    sSumOplata : string [CIZena];
    sSumRez : string [CIZena];
    s: string;
Begin
   if (P<>nil) then
   Begin
     sDate:=IntToStr(DateStringToDate(DateMask,E.DateC),CDate);
     format(sDate,CDate);
     sDocument:=E.Document;
     rformat(sDocument,CDocNumer);
     for i:=1 to E.Amount do
     Begin
      sKod :=E.MarketElement[i].BazKod;
      if m[E.MarketElement[i].Input.DiviSionSNumber]=1 then
      if not TestElementt(Copy(sKod,1,2),Spis) then
      begin
      sName :=GetIdField(FName,E.MarketElement[i].BazKod);
      format(sName,CName);
      sZC :=E.MarketElement[i].Input.Zakupka;
      rformat(sZC,CZena);
      MyStr(StrToReal(sZC)*StrToREal(E.MarketElement[i].Input.Kol),CIZena,CMantissaZ,sSumZC);
      rformat(sSumZC,CIZena);
      sKOl :=E.MarketElement[i].Input.Kol;
      rformat(sKOl,CKol);

         If E.SkidkaSelector in [0,2] Then
               Begin
                DelSpace(E.MarketElement[i].Input.Proz);
                MyStr((StrToReal(E.MarketElement[i].Input.Zena)*
                (StrToReal(E.MarketElement[i].Input.Proz))),CZena,CMantissa,
                         E.MarketElement[i].Input.Zena);

               End
                Else
               Begin
                {сумма скидки}
                MyStr((StrToReal(E.MarketElement[i].Input.Zena)-
                         StrToReal(E.MarketElement[i].Input.Skidka)),
                         CZena,CMantissa,
                                        E.MarketElement[i].Input.Zena);
               End;

      sOplata :=E.MarketElement[i].Input.Zena;
      rformat(sOplata,CZena);
      {оплата}
       myStr(StrToReal(sOplata)*StrToReal(SKOl),CIZena,CMantissa,sSumOplata);
       rformat(sSumOplata,CIZena);
       {НДС}
       if StrToReal(E.MarketElement[i].Input.NDs)>0.01 then
       MyStr(StrToReal(sSumOplata)*
       (StrToReal(E.MarketElement[i].Input.NDs)/(100+StrToReal(E.MarketElement[i].Input.NDS))),CIZena,CMantissa,sSumNDS)
       else sSumNDS:='0.00';
       rformat(sSumNDS,CIZena);
      {оплата - НДС}
       MyStr(StrToReal(sSumOplata)-StrToReal(sSumNDS),CIZena,CMantissa,sSumOplataNDS);
       rformat(sSumOplataNDS,CIZena);
      {цена безНДС}
      if StrToInt(sKol)>0 then
      MyStr(StrToReal(sSumOplataNDS)/StrToReal(sKol),CZena,CMantissaZ,sOplataNDS)
      else sOplataNDS:='0.00';
      rformat(sOplataNDS,CZena);
      {НДС в цене}
      if StrToInt(sKol)>0 then
      MyStr(StrToReal(sSumNds)/StrToReal(sKol),CZena,CMantissaZ,sNds)
      else sNds:='0.00';
      rformat(sNds,CZena);
      {рез-т от сделки}
      MyStr(StrToReal(sSumOPlataNds)-StrToReal(sSumZC),CIzena,CMantissa,sSumRez);

      s:=sDate+';'+sDocument+';'+sName+';'+sKod+';'+sZC++';'+sKOl+';'+sSumZC+';'+
      sOplataNDS+';'+sNds+';'+sOplata+';'+sSumOPlataNds+';'+sSumNds+';'+sSumOplata
	 +';'+sSumRez;

      P^.List^.Insert(NewStr(s));
      P^.SetRange(P^.List^.Count);

    end;
    end;
   End;
End;

procedure WriteReport1(P:Pbox; var t: Text;kv: word);
var s: string;
    l: word;
    sDate: TDateString;
    D, MM, Y ,OldMes: integer;
Begin

SumMesBNDS := '0.00';
SumMesNDS := '0.00';
SumMesOpl := '0.00';
SumMesRez := '0.00';

SumKvBNDS := '0.00';
SumKvNDS := '0.00';
SumKvOpl := '0.00';
SumKvRez := '0.00';

s:=P^.GetText(0,P^.List^.Count);
sDAte:=DateToDateString(DateMask,StrToInt(copy(s,posDate,CDate)));
DateStringToDMY(DateMask,sDate,D, MM, Y );
OldMes:=MM;
for l:=0 to P^.List^.Count-1 do
begin
  s:=P^.GetText(l,P^.List^.Count);

  sDAte:=copy(s,posDate,CDate);
  sDAte:=DateToDateString(DateMask,StrToInt(copy(s,posDate,CDate)));
  DateStringToDMY(DateMask,sDate,D, MM, Y );

  System.Delete(s,posDate,CDate);
  System.Insert(sDate,s,posDate);

  if (OldMes<>MM) then
  begin
   writeln(t,DosToWin(';;;Итого за месяц;;;;;;;;;;;;'+SumMesBNDS+';'+SumMesNDS+';'+SumMesOpl+';-;'++SumMesOpl+';'+SumMesRez));
   SumMesBNDS:='0.00';
   SumMesNDS:='0.00';
   SumMesOpl:='0.00';
   SumMesRez:='0.00';
   OldMes:=MM;
  end;

  sKol:=copy(s,posKol,CKol);
  MyStr(StrToReal(SumMesBNDS)+StrToReal(copy(s,posSumOplataNDS,CIZena)),CIZena,CMantissa,SumMesBNDS);
  MyStr(StrToReal(SumMesNDS)+StrToReal(copy(s,posSumNDS,CIZena)),CIZena,CMantissa,SumMesNDS);
  MyStr(StrToReal(SumMesOpl)+StrToReal(copy(s,posSumOplata,CIZena)),CIZena,CMantissa,SumMesOpl);
  MyStr(StrToReal(SumMesRez)+StrToReal(copy(s,posSumRez,CIZena)),CIZena,CMantissa,SumMesRez);

  MyStr(StrToReal(SumKvBNDS)+StrToReal(copy(s,posSumOplataNDS,CIZena)),CIZena,CMantissa,SumKvBNDS);
  MyStr(StrToReal(SumKvNDS)+StrToReal(copy(s,posSumNDS,CIZena)),CIZena,CMantissa,SumKvNDS);
  MyStr(StrToReal(SumKvOpl)+StrToReal(copy(s,posSumOplata,CIZena)),CIZena,CMantissa,SumKvOpl);
  MyStr(StrToReal(SumKvRez)+StrToReal(copy(s,posSumRez,CIZena)),CIZena,CMantissa,SumKvRez);

  MyStr(StrToReal(Sum12BNDS)+StrToReal(copy(s,posSumOplataNDS,CIZena)),CIZena,CMantissa,Sum12BNDS);
  MyStr(StrToReal(Sum12NDS)+StrToReal(copy(s,posSumNDS,CIZena)),CIZena,CMantissa,Sum12NDS);
  MyStr(StrToReal(Sum12Opl)+StrToReal(copy(s,posSumOplata,CIZena)),CIZena,CMantissa,Sum12Opl);
  MyStr(StrToReal(Sum12Rez)+StrToReal(copy(s,posSumRez,CIZena)),CIZena,CMantissa,Sum12Rez);

  if kv in [1,2] then
  begin
   MyStr(StrToReal(Sum6BNDS)+StrToReal(copy(s,posSumOplataNDS,CIZena)),CIZena,CMantissa,Sum6BNDS);
   MyStr(StrToReal(Sum6NDS)+StrToReal(copy(s,posSumNDS,CIZena)),CIZena,CMantissa,Sum6NDS);
   MyStr(StrToReal(Sum6Opl)+StrToReal(copy(s,posSumOplata,CIZena)),CIZena,CMantissa,Sum6Opl);
   MyStr(StrToReal(Sum6Rez)+StrToReal(copy(s,posSumRez,CIZena)),CIZena,CMantissa,Sum6Rez);
  end;

  if kv in [1,2,3] then
  begin
   MyStr(StrToReal(Sum9BNDS)+StrToReal(copy(s,posSumOplataNDS,CIZena)),CIZena,CMantissa,Sum9BNDS);
   MyStr(StrToReal(Sum9NDS)+StrToReal(copy(s,posSumNDS,CIZena)),CIZena,CMantissa,Sum9NDS);
   MyStr(StrToReal(Sum9Opl)+StrToReal(copy(s,posSumOplata,CIZena)),CIZena,CMantissa,Sum9Opl);
   MyStr(StrToReal(Sum9Rez)+StrToReal(copy(s,posSumRez,CIZena)),CIZena,CMantissa,Sum9Rez);
  end;

  sSumOplata:=copy(s,posSumOplata,CIZena);
  System.Insert('-;'+sSumOplata+';',s,posSumRez);
  System.Insert(sKol+';',s,posSumOplataNDS);
  System.Insert('-;',s,posOplata);
  System.Insert('-;-;',s,posKol);
  System.Delete(s,posKod,CArtikul);
  System.Insert('шт',s,posKod);
  write(t,Count,';');
  writeln(t,DosToWin(s));
  inc(count);

  if (l=P^.List^.Count-1) then
  begin
   writeln(t,DosToWin(';;;Итого за месяц;;;;;;;;;;;;'+SumMesBNDS+';'+SumMesNDS+';'+SumMesOpl+';-;'++SumMesOpl+';'+SumMesRez));
   writeln(t,DosToWin(';;;Итого за '+IntToStr(kv,2)+' квартал;;;;;;;;;;;;'+SumKvBNDS+';'+SumKvNDS+';'+SumKvOpl+';-;'
   +SumKvOpl+';'+SumKvRez));
   if kv=2 then
   if StrToReal(Sum6BNDS)>0.01 then
   writeln(t,DosToWin(';;;Итого за 6 месяцев;;;;;;;;;;;;'+Sum6BNDS+';'+Sum6NDS+';'+Sum6Opl+';-;'
   +Sum6Opl+';'+Sum6Rez));

   if kv=3 then
   if StrToReal(Sum9BNDS)>0.01 then
   writeln(t,DosToWin(';;;Итого за 9 месяцев;;;;;;;;;;;;'+Sum9BNDS+';'+Sum9NDS+';'+Sum9Opl+';-;'
   +Sum9Opl+';'+Sum9Rez));

   if kv=4 then
   if StrToReal(Sum12BNDS)>0.01 then
   writeln(t,DosToWin(';;;Итого за год;;;;;;;;;;;;'+Sum12BNDS+';'+Sum12NDS+';'+Sum12Opl+';-;'
   +Sum12Opl+';'+Sum12Rez));

  end;
end;
end;


procedure WriteReportPos(P:Pbox; var t: Text;kv: word);
var s: string;
    l: word;
    sDate: TDateString;
    D, MM, Y ,OldMes: integer;
    OldName: String[CName+1];
Begin

   SumposBNDS:='0.00';
   SumposNDS:='0.00';
   SumposOpl:='0.00';
   SumposRez:='0.00';


SumMesBNDS := '0.00';
SumMesNDS := '0.00';
SumMesOpl := '0.00';
SumMesRez := '0.00';

s:=P^.GetText(0,P^.List^.Count);
OldName:=copy(s,1,CName+1);

sDAte:=DateToDateString(DateMask,StrToInt(copy(s,posDate,CDate)));
DateStringToDMY(DateMask,sDate,D, MM, Y );
OldMes:=MM;
for l:=0 to P^.List^.Count-1 do
begin
  s:=P^.GetText(l,P^.List^.Count);
  sName:=copy(s,1,CName+1);
  System.Delete(s,1,CName+1);
  System.Insert(sName,s,posName);

  sDAte:=copy(s,posDate,CDate);
  sDAte:=DateToDateString(DateMask,StrToInt(copy(s,posDate,CDate)));
  DateStringToDMY(DateMask,sDate,D, MM, Y );

  System.Delete(s,posDate,CDate);
  System.Insert(sDate,s,posDate);

  if (OldName<>sName) then
  begin
   writeln(t,DosToWin(';;;Итого по товару(работе, услуге);;;;;;;;;;;;'+SumPosBNDS+';'+SumPosNDS+';'+SumPosOpl+';-;'
    +SumPosOpl+';'+SumPosRez));
   SumposBNDS:='0.00';
   SumposNDS:='0.00';
   SumposOpl:='0.00';
   SumposRez:='0.00';
   OldName:=sName;
  end;

  sKol:=copy(s,posKol,CKol);

  MyStr(StrToReal(SumposBNDS)+StrToReal(copy(s,posSumOplataNDS,CIZena)),CIZena,CMantissa,SumPosBNDS);
  MyStr(StrToReal(SumposNDS)+StrToReal(copy(s,posSumNDS,CIZena)),CIZena,CMantissa,SumposNDS);
  MyStr(StrToReal(SumposOpl)+StrToReal(copy(s,posSumOplata,CIZena)),CIZena,CMantissa,SumposOpl);
  MyStr(StrToReal(SumposRez)+StrToReal(copy(s,posSumRez,CIZena)),CIZena,CMantissa,SumposRez);


  MyStr(StrToReal(SumMesBNDS)+StrToReal(copy(s,posSumOplataNDS,CIZena)),CIZena,CMantissa,SumMesBNDS);
  MyStr(StrToReal(SumMesNDS)+StrToReal(copy(s,posSumNDS,CIZena)),CIZena,CMantissa,SumMesNDS);
  MyStr(StrToReal(SumMesOpl)+StrToReal(copy(s,posSumOplata,CIZena)),CIZena,CMantissa,SumMesOpl);
  MyStr(StrToReal(SumMesRez)+StrToReal(copy(s,posSumRez,CIZena)),CIZena,CMantissa,SumMesRez);

  MyStr(StrToReal(SumKvBNDS)+StrToReal(copy(s,posSumOplataNDS,CIZena)),CIZena,CMantissa,SumKvBNDS);
  MyStr(StrToReal(SumKvNDS)+StrToReal(copy(s,posSumNDS,CIZena)),CIZena,CMantissa,SumKvNDS);
  MyStr(StrToReal(SumKvOpl)+StrToReal(copy(s,posSumOplata,CIZena)),CIZena,CMantissa,SumKvOpl);
  MyStr(StrToReal(SumKvRez)+StrToReal(copy(s,posSumRez,CIZena)),CIZena,CMantissa,SumKvRez);

(*  MyStr(StrToReal(Sum12BNDS)+StrToReal(copy(s,posSumOplataNDS,CIZena)),CIZena,CMantissa,Sum12BNDS);
  MyStr(StrToReal(Sum12NDS)+StrToReal(copy(s,posSumNDS,CIZena)),CIZena,CMantissa,Sum12NDS);
  MyStr(StrToReal(Sum12Opl)+StrToReal(copy(s,posSumOplata,CIZena)),CIZena,CMantissa,Sum12Opl);
  MyStr(StrToReal(Sum12Rez)+StrToReal(copy(s,posSumRez,CIZena)),CIZena,CMantissa,Sum12Rez);

  if kv in [1..6] then
  begin
   MyStr(StrToReal(Sum6BNDS)+StrToReal(copy(s,posSumOplataNDS,CIZena)),CIZena,CMantissa,Sum6BNDS);
   MyStr(StrToReal(Sum6NDS)+StrToReal(copy(s,posSumNDS,CIZena)),CIZena,CMantissa,Sum6NDS);
   MyStr(StrToReal(Sum6Opl)+StrToReal(copy(s,posSumOplata,CIZena)),CIZena,CMantissa,Sum6Opl);
   MyStr(StrToReal(Sum6Rez)+StrToReal(copy(s,posSumRez,CIZena)),CIZena,CMantissa,Sum6Rez);
  end;

  if kv in [1..9] then
  begin
   MyStr(StrToReal(Sum9BNDS)+StrToReal(copy(s,posSumOplataNDS,CIZena)),CIZena,CMantissa,Sum9BNDS);
   MyStr(StrToReal(Sum9NDS)+StrToReal(copy(s,posSumNDS,CIZena)),CIZena,CMantissa,Sum9NDS);
   MyStr(StrToReal(Sum9Opl)+StrToReal(copy(s,posSumOplata,CIZena)),CIZena,CMantissa,Sum9Opl);
   MyStr(StrToReal(Sum9Rez)+StrToReal(copy(s,posSumRez,CIZena)),CIZena,CMantissa,Sum9Rez);
  end;      *)


  sSumOplata:=copy(s,posSumOplata,CIZena);
  System.Insert('-;'+sSumOplata+';',s,posSumRez);
  System.Insert(sKol+';',s,posSumOplataNDS);
  System.Insert('-;',s,posOplata);
  System.Insert('-;-;',s,posKol);
  System.Delete(s,posKod,CArtikul);
  System.Insert('шт',s,posKod);
  write(t,Count,';');
  writeln(t,DosToWin(s));
  inc(count);

  if (l=P^.List^.Count-1) then
  begin
   writeln(t,DosToWin(';;;Итого по товару(работе, услуге);;;;;;;;;;;;'+SumPosBNDS+';'+SumPosNDS+';'+SumPosOpl+';-;'++SumPosOpl
    +';'+SumMesRez));
   writeln(t,DosToWin(';;;Итого за месяц;;;;;;;;;;;;'+SumMesBNDS+';'+SumMesNDS+';'+SumMesOpl+';-;'++SumMesOpl+';'+SumMesRez));
   if kv in [3,6,9,12] then
   writeln(t,DosToWin(';;;Итого за '+IntToStr(kv div 3,2)+' квартал;;;;;;;;;;;;'+SumKvBNDS+';'+SumKvNDS+';'+SumKvOpl+';-;'
   +SumKvOpl+';'+SumKvRez));
   if kv=6 then
   if StrToReal(Sum6BNDS)>0.01 then
   writeln(t,DosToWin(';;;Итого за 6 месяцев;;;;;;;;;;;;'+Sum6BNDS+';'+Sum6NDS+';'+Sum6Opl+';-;'
   +Sum6Opl+';'+Sum6Rez));

   if kv=9 then
   if StrToReal(Sum9BNDS)>0.01 then
   writeln(t,DosToWin(';;;Итого за 9 месяцев;;;;;;;;;;;;'+Sum9BNDS+';'+Sum9NDS+';'+Sum9Opl+';-;'
   +Sum9Opl+';'+Sum9Rez));

   if kv=12 then
   if StrToReal(Sum12BNDS)>0.01 then
   writeln(t,DosToWin(';;;Итого за год;;;;;;;;;;;;'+Sum12BNDS+';'+Sum12NDS+';'+Sum12Opl+';-;'
   +Sum12Opl+';'+Sum12Rez));

  end;
end;
end;



Begin

if not DatePeriodDialog(StartDate,StopDate,False) then exit;

 Start:=DateStringToDate(DateMask,StartDate);
 Stop:=DateStringToDate(DateMask,StopDate);

 R.Assign(0,0,0,0);
 NoScreen1:= New(PBox, Init(R, 1, Nil));
 NoScreen1^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0,0,0,0);
 NoScreen2:= New(PBox, Init(R, 1, Nil));
 NoScreen2^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0,0,0,0);
 NoScreen3:= New(PBox, Init(R, 1, Nil));
 NoScreen3^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0,0,0,0);
 NoScreen4:= New(PBox, Init(R, 1, Nil));
 NoScreen4^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0,0,0,0);
 Rep1:= New(PBox, Init(R, 1, Nil));
 Rep1^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0,0,0,0);
 Rep2:= New(PBox, Init(R, 1, Nil));
 Rep2^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0,0,0,0);
 Rep3:= New(PBox, Init(R, 1, Nil));
 Rep3^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0,0,0,0);
 Rep4:= New(PBox, Init(R, 1, Nil));
 Rep4^.NewList(New(PTextCollection, Init(0,1)));

For Den:=Start To Stop Do
Begin
 sDate:=DateToDateString(DateMask,DEn);
 Assign(F,Path.ToMarket+sDate+'.mrk');
 DInfoMSgShkala(msg+sDate,Start,Stop,Den);
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 if l<>0 then continue;
 If l=0 Then
   Begin
     While Not (Eof(f)) Do
       Begin
        New(E,Init);
        ReadMArket(f,E);
        if E^.Dat.Active then
        If ((E^.Dat.DocSelector in [3,4]) And Not(E^.Dat.Realiz)) Or{не вторичная консигнация}
        (E^.Dat.DocSelector in [6,8]) Then{консигнация}
        {If (E^.Dat.Realiz)  Then}
        begin
        DateStringToDMY(DateMask,sDate,D, MM, Y );
        case MM of
          1, 2, 3: AddMrk(NoScreen1,E^.Dat);
          4, 5, 6: AddMrk(NoScreen2,E^.Dat);
          7, 8, 9: AddMrk(NoScreen3,E^.Dat);
         10,11,12: AddMrk(NoScreen4,E^.Dat);
        end;
        end;
        Dispose(E,Done);
       end; {While Not (Eof(f))}
    close(f);
   End; {If l=0 Then}

End; {For Den:=Start To Stop}
NoInfoMsg;

Count:=1;
Assign(t,'c:\report1.csv');
l:=ioresult;
Rewrite(t);
l:=ioresult;
if l<>0 then
begin
 memcc('Не могу создать файл отчета c:\report1.csv');
 exit;
end;

DInfoMsg('Формирую отчет по видам товаров ');
Writeln(t,DosToWin(';;Учет доходов и расходов по видам товаров (работ, услуг) в момент их совершения'));
Writeln(t,DosToWin(';;за период с '+StartDate+' по '+Stopdate));
WriteShapka(t);

Sum6BNDS := '0.00';
Sum6NDS := '0.00';
Sum6Opl := '0.00';
Sum6Rez := '0.00';

Sum9BNDS := '0.00';
Sum9NDS := '0.00';
Sum9Opl := '0.00';
Sum9Rez := '0.00';

Sum12BNDS := '0.00';
Sum12NDS := '0.00';
Sum12Opl := '0.00';
Sum12Rez := '0.00';


if (NoScreen1<>nil) and (NoScreen1^.List^.Count>0) then
WriteReport1(NoScreen1,t,1);
if (NoScreen2<>nil) and (NoScreen2^.List^.Count>0) then
WriteReport1(NoScreen2,t,2);
if (NoScreen3<>nil) and (NoScreen3^.List^.Count>0) then
WriteReport1(NoScreen3,t,3);
if (NoScreen4<>nil) and (NoScreen4^.List^.Count>0) then
WriteReport1(NoScreen4,t,4);

close(t);

NoInfoMsg;
DInfoMsg('Формирую отчет по видам товаров за месяц');

Assign(t,'c:\report2.csv');
l:=ioresult;
Rewrite(t);
l:=ioresult;
if l<>0 then
begin
 memcc('Не могу создать файл отчета c:\report2.csv');
 exit;
end;

Writeln(t,DosToWin(';;Учет доходов и расходов по всем видам товаров (работ, услуг) за месяц'));
Writeln(t,DosToWin(';;за период с '+StartDate+' по '+Stopdate));
WriteShapka(t);

Count:=1;

(*Sum6BNDS := '0.00';
Sum6NDS := '0.00';
Sum6Opl := '0.00';
Sum6Rez := '0.00';

Sum9BNDS := '0.00';
Sum9NDS := '0.00';
Sum9Opl := '0.00';
Sum9Rez := '0.00';

Sum12BNDS := '0.00';
Sum12NDS := '0.00';
Sum12Opl := '0.00';
Sum12Rez := '0.00'; *)

SumKvBNDS := '0.00';
SumKvNDS := '0.00';
SumKvOpl := '0.00';
SumKvRez := '0.00';


if (NoScreen1<>nil) and (NoScreen1^.List^.Count>0) then
for l:=0 to NoScreen1^.List^.Count-1 do
begin
 s:=NoScreen1^.GetText(l,NoScreen1^.List^.Count);
 sName:=copy(s,posName,CName+1);
 sDate:=copy(s,posDate,CDate);
 System.Delete(s,posName,CName+1);
 s:=sName+s;

DateStringToDMY(DateMask,DateToDateString(DateMask,StrToInt(sDate)),D, MM, Y );
case MM of
1: begin
     Rep1^.List^.Insert(NewStr(s));
     Rep1^.SetRange(Rep1^.List^.Count);
   end;
2: begin
     Rep2^.List^.Insert(NewStr(s));
     Rep2^.SetRange(Rep2^.List^.Count);
    end;
3: begin
     Rep3^.List^.Insert(NewStr(s));
     Rep3^.SetRange(Rep3^.List^.Count);
    end;
 end;{case}
end;

if Rep1^.List^.Count>0 then
  WriteReportPos(Rep1,t,1);
if Rep2^.List^.Count>0 then
  WriteReportPos(Rep2,t,2);
if Rep3^.List^.Count>0 then
  WriteReportPos(Rep3,t,3);



Dispose(Rep1,Done);
Dispose(Rep2,Done);
Dispose(Rep3,Done);

 R.Assign(0,0,0,0);
 Rep1:= New(PBox, Init(R, 1, Nil));
 Rep1^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0,0,0,0);
 Rep2:= New(PBox, Init(R, 1, Nil));
 Rep2^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0,0,0,0);
 Rep3:= New(PBox, Init(R, 1, Nil));
 Rep3^.NewList(New(PTextCollection, Init(0,1)));

SumKvBNDS := '0.00';
SumKvNDS := '0.00';
SumKvOpl := '0.00';
SumKvRez := '0.00';


if (NoScreen2<>nil) and (NoScreen2^.List^.Count>0) then
for l:=0 to NoScreen2^.List^.Count-1 do
begin
 s:=NoScreen2^.GetText(l,NoScreen2^.List^.Count);
 sName:=copy(s,posName,CName+1);
 sDate:=copy(s,posDate,CDate);
 System.Delete(s,posName,CName+1);
 s:=sName+s;

DateStringToDMY(DateMask,DateToDateString(DateMask,StrToInt(sDate)),D, MM, Y );

case MM of
4: begin
     Rep1^.List^.Insert(NewStr(s));
     Rep1^.SetRange(Rep1^.List^.Count);
   end;
5: begin
     Rep2^.List^.Insert(NewStr(s));
     Rep2^.SetRange(Rep2^.List^.Count);
    end;
6: begin
     Rep3^.List^.Insert(NewStr(s));
     Rep3^.SetRange(Rep3^.List^.Count);
    end;
 end;{case}
end;

if Rep1^.List^.Count>0 then
  WriteReportPos(Rep1,t,4);
if Rep2^.List^.Count>0 then
  WriteReportPos(Rep2,t,5);
if Rep3^.List^.Count>0 then
  WriteReportPos(Rep3,t,6);


Dispose(Rep1,Done);
Dispose(Rep2,Done);
Dispose(Rep3,Done);

 R.Assign(0,0,0,0);
 Rep1:= New(PBox, Init(R, 1, Nil));
 Rep1^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0,0,0,0);
 Rep2:= New(PBox, Init(R, 1, Nil));
 Rep2^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0,0,0,0);
 Rep3:= New(PBox, Init(R, 1, Nil));
 Rep3^.NewList(New(PTextCollection, Init(0,1)));

SumKvBNDS := '0.00';
SumKvNDS := '0.00';
SumKvOpl := '0.00';
SumKvRez := '0.00';

if (NoScreen3<>nil) and (NoScreen3^.List^.Count>0) then
for l:=0 to NoScreen3^.List^.Count-1 do
begin
 s:=NoScreen3^.GetText(l,NoScreen3^.List^.Count);
 sName:=copy(s,posName,CName+1);
 sDate:=copy(s,posDate,CDate);
 System.Delete(s,posName,CName+1);
 s:=sName+s;

DateStringToDMY(DateMask,DateToDateString(DateMask,StrToInt(sDate)),D, MM, Y );
case MM of
7: begin
     Rep1^.List^.Insert(NewStr(s));
     Rep1^.SetRange(Rep1^.List^.Count);
   end;
8: begin
     Rep2^.List^.Insert(NewStr(s));
     Rep2^.SetRange(Rep2^.List^.Count);
    end;
9: begin
     Rep3^.List^.Insert(NewStr(s));
     Rep3^.SetRange(Rep3^.List^.Count);
    end;
 end;{case}
end;

if Rep1^.List^.Count>0 then
  WriteReportPos(Rep1,t,7);
if Rep2^.List^.Count>0 then
  WriteReportPos(Rep2,t,8);
if Rep3^.List^.Count>0 then
  WriteReportPos(Rep3,t,9);


Dispose(Rep1,Done);
Dispose(Rep2,Done);
Dispose(Rep3,Done);

 R.Assign(0,0,0,0);
 Rep1:= New(PBox, Init(R, 1, Nil));
 Rep1^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0,0,0,0);
 Rep2:= New(PBox, Init(R, 1, Nil));
 Rep2^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0,0,0,0);
 Rep3:= New(PBox, Init(R, 1, Nil));
 Rep3^.NewList(New(PTextCollection, Init(0,1)));

SumKvBNDS := '0.00';
SumKvNDS := '0.00';
SumKvOpl := '0.00';
SumKvRez := '0.00';

if (NoScreen4<>nil) and (NoScreen4^.List^.Count>0) then
for l:=0 to NoScreen4^.List^.Count-1 do
begin
 s:=NoScreen4^.GetText(l,NoScreen4^.List^.Count);
 sName:=copy(s,posName,CName+1);
 sDate:=copy(s,posDate,CDate);
 System.Delete(s,posName,CName+1);
 s:=sName+s;
DateStringToDMY(DateMask,DateToDateString(DateMask,StrToInt(sDate)),D, MM, Y );

case MM of
10: begin
     Rep1^.List^.Insert(NewStr(s));
     Rep1^.SetRange(Rep1^.List^.Count);
   end;
11: begin
     Rep2^.List^.Insert(NewStr(s));
     Rep2^.SetRange(Rep2^.List^.Count);
    end;
12: begin
     Rep3^.List^.Insert(NewStr(s));
     Rep3^.SetRange(Rep3^.List^.Count);
    end;
 end;{case}
end;

if Rep1^.List^.Count>0 then
  WriteReportPos(Rep1,t,10);
if Rep2^.List^.Count>0 then
  WriteReportPos(Rep2,t,11);
if Rep3^.List^.Count>0 then
  WriteReportPos(Rep3,t,12);

close(t);

Dispose(NoScreen1,Done);
Dispose(NoScreen2,Done);
Dispose(NoScreen3,Done);
Dispose(NoScreen4,Done);

Dispose(Rep1,Done);
Dispose(Rep2,Done);
Dispose(Rep3,Done);
Dispose(Rep4,Done);

NoInfoMsg;

memcc('Результаты в файлах c:\report1.csv,c:\report2.csv');

END; {Procedure ReportRashoDohod}

procedure CalcPost;
const posData = 1;
      posNum = posData+CDate+1;
      posPost = posNum+CDocNumer+1;
      posKOl = posPost+CAll+1;
      posSumma = posKOl+Ckol+1;
      posSumma10 = posSumma+CIZena+1;
      posSumma18 = posSumma10+CIZena+1;
      posSumma_ = posSumma18+CIZena+1;

var Temp: PBox;
    Start,Stop,Den: longint;
    StartDate,StopDate: TDateString;
    R: Trect;
    t: Text;
    IORez,i: word;
    s: string;
    Pr : PrihodType;
    fPr: file of PrihodType;

procedure AddToList;
{работает с накладной}
var bFind: boolean;
    s,ws: string;
    i,count: word;
    sPost: string[CPost];
    sKol,sKol10,sKol18: string[CKol];
    sSumma,sSumma10,sSumma18,sSumma_: string[CIZena];
Begin
 bFind:=false;
 if not bFind then
 begin
  format(Pr.Osn.DateNakl,CDate);
  format(pr.osn.NaklNumer,CDocNumer);
  ws:=GetClientField(FFFName,pr.MakeKod ,2);
  format(ws,CAll);
  sKol:='0';
  sKol10:='0';
  sKol18:='0';
  sSumma:='0.00';
  sSumma10:='0.00';
  sSumma18:='0.00';
  sSumma_:='0.00';
  for count:=1 to Pr.Amount do
  begin
    sKol:=IntToStr(StrToInt(sKol)+StrToInt(pr.PrihodElement[count].Input.kol),CKol);
    if StrToInt(GetIdField(FInPack,Pr.PrihodElement[count].BazKOd))>0 then
    MyStr(StrToReal(Pr.PrihodElement[count].Input.Zakupka)/
    StrToReal(GetIdField(FInPack,Pr.PrihodElement[count].BazKOd)),CZena,CMantissaZ,Pr.PrihodElement[count].Input.Zakupka)
    else;


    MyStr(StrToReal(sSumma)+StrToReal(Pr.PrihodElement[count].Input.Zakupka)*StrToReal(pr.PrihodElement[count].Input.kol)
      ,CIzena,CMantissaZ,sSumma);
    case Round(StrToReal(GetIdField(FNDS,Pr.PrihodElement[count].BazKOd)))  of
    18: begin
       sKol18:=IntToStr(StrToInt(sKol18)+StrToInt(pr.PrihodElement[count].Input.kol),CKol);
       MyStr(StrToReal(sSumma18)+StrToReal(Pr.PrihodElement[count].Input.Zakupka)*StrToReal(pr.PrihodElement[count].Input.kol)
      ,CIzena,CMantissaZ,sSumma18);
        end;
    10: begin
       sKol10:=IntToStr(StrToInt(sKol10)+StrToInt(pr.PrihodElement[count].Input.kol),CKol);
       MyStr(StrToReal(sSumma10)+StrToReal(Pr.PrihodElement[count].Input.Zakupka)*StrToReal(pr.PrihodElement[count].Input.kol)
      ,CIzena,CMantissaZ,sSumma10);
      end;
    else
     MyStr(StrToReal(sSumma_)+StrToReal(Pr.PrihodElement[count].Input.Zakupka)*StrToReal(pr.PrihodElement[count].Input.kol)
	 ,CIzena,CMantissaZ,sSumma_);
    end;
  end;
  rformat(sKOl,Ckol);
  rformat(sSumma,CIZena);
  rformat(sSumma10,CIZena);
  rformat(sSumma18,CIZena);
  rformat(sSumma_,CIZena);
  s:=Pr.Osn.DateNakl+';'+Pr.osn.NaklNumer+';'+ws+';'+sKol+';'+sKol10+';'+sKol18+';'
  +sSumma+';'+sSumma10+';'+sSumma18+';'+sSumma_;
  Temp^.List^.Insert(NewStr(s));
  Temp^.SetRange(Temp^.List^.Count);
 end;

End;

BEGIN
 if not DatePeriodDialog(StartDate,StopDate,False) then exit;

 Start:=DateStringToDate(DateMask,StartDate);
 Stop:=DateStringToDate(DateMask,StopDate);

 R.Assign(0,0,0,0);
 Temp:= New(PBox, Init(R, 1, Nil));
 Temp^.NewList(New(PTextCollection, Init(0,1)));
 {}
 for Den:=Start to Stop do
 begin
  DInfoMSgShkala('Обрабатываю приходы за '+DateToDateString(DateMAsk,Den),Start,Stop,Den);
  Assign(fPr,Path.ToPrihod+DateToDateString(DateMAsk,Den)+'.prh');
  IOrez:=ioresult;
  Reset(fPr);
  IOrez:=ioresult;
  if IOrez = 0 then
  begin
  while not eof(fPr) do
   begin
    read(fpr,pr);
    AddToList;
   end;
   close(fpr);
  end
  else
  begin
    {memcc(Path.ToPrihod+DateToDateString(DateMAsk,Den)+'.prh');}
    continue;
  end;
 end;
 NoInfoMsg;

 Assign(t,'c:\post.csv');
 Iorez:=ioresult;
 Rewrite(t);
 Iorez:=ioresult;
 if iorez = 0 then
 begin
  writeln(t,DosToWin(';;Отчет по поставщикам с '+StartDate+' по '+StopDate));
  writeln(t,DosToWin('Дата;N документа;Поставшик;Количество;Кол.НДС 10%;Кол.НДС 18%;Сумма общая;НДС 10%;НДС 18%;НДС прочее'));
  if (Temp<>nil) and (Temp^.List^.Count>0) then
  for i:=0 to Temp^.List^.Count-1 do
  begin
    s:=Temp^.GetText(i,Temp^.List^.Count);
    writeln(t,DosToWin(s));
  end;
  close(t);
 end
 else memcc('c:\post.csv');

 Dispose (Temp,Done);

 memcc('Результаты сохранены в файле c:\post.csv');

END;

procedure CalcMarket;

const posData = 1;
      posNum = posData+CDate+1;
      posClient = posNum+CDocNumer+1;
      posPost = posClient+CMakeKod+1;
      posKOl = posPost+CMakeKod+1;
      posKOl10 = posKOl+Ckol+1;
      posKOl18 = posKOl10+Ckol+1;
      posKOl_ = posKOl18+Ckol+1;
      posSumma = posKOl_+Ckol+1;
      posSumma10 = posSumma+CIZena+1;
      posSumma18 = posSumma10+CIZena+1;
      posSumma_ = posSumma18+CIZena+1;
      posSummaZ = posSumma_+CIZena+1;
      posSummaZ10 = posSummaZ+CIZena+1;
      posSummaZ18 = posSummaZ10+CIZena+1;
      posSummaZ_ = posSummaZ18+CIZena+1;

var Temp: PBox;
    Start,Stop,Den: longint;
    StartDate,StopDate: TDateString;
    R: Trect;
    t: Text;
    IORez,i,count: word;
    s: string;
    Pr : SuperMarketType;
    fPr: file of SuperMarketType;
    sKod: string[CMakeKod];
    sName: string[CAll];

procedure AddToList;
{работает с товаром - count внешний}

var bFind: boolean;
    s,ws,ws1: string;
    i: word;
    sPost: string[CPost];
    sKol,sKol10,sKol18,sKol_: string[CKol];
    sSumma,sSumma10,sSumma18,sSumma_: string[CIZena];
    sSummaZ,sSummaZ10,sSummaZ18,sSummaZ_: string[CIZena];

procedure CalcElement;
begin
    sKol:=IntToStr(StrToInt(sKol)+StrToInt(pr.MarketElement[count].Input.kol),CKol);
    {отпускная}
    If Pr.SkidkaSelector in [0,2] Then
               Begin
                DelSpace(Pr.MarketElement[count].Input.Proz);
                MyStr((StrToReal(Pr.MarketElement[count].Input.Zena)*
                (StrToReal(Pr.MarketElement[count].Input.Proz))),CZena,CMantissa,
                         Pr.MarketElement[count].Input.Zena);

               End
                Else
               Begin
                {сумма скидки}
                MyStr((StrToReal(Pr.MarketElement[count].Input.Zena)-
                         StrToReal(Pr.MarketElement[count].Input.Skidka)),
                         CZena,CMantissa,
                                        Pr.MarketElement[count].Input.Zena);
               End;
    MyStr(StrToReal(sSumma)+StrToReal(Pr.MarketElement[count].Input.Zena)*StrToReal(pr.MarketElement[count].Input.kol)
    ,CIzena,CMantissaZ,sSumma);
    {закупка}
    MyStr(StrToReal(sSummaZ)+StrToReal(Pr.MarketElement[count].Input.Zakupka)*StrToReal(pr.MarketElement[count].Input.kol)
    ,CIzena,CMantissaZ,sSummaZ);

    case Trunc(StrToReal(Pr.MarketElement[count].Input.Nds))  of

    18: begin
    sKol18:=IntToStr(StrToInt(sKol18)+StrToInt(pr.MarketElement[count].Input.kol),CKol);
    MyStr(StrToReal(sSumma18)+StrToReal(Pr.MarketElement[count].Input.Zena)*StrToReal(pr.MarketElement[count].Input.kol)
    ,CIzena,CMantissaZ,sSumma18);
    MyStr(StrToReal(sSummaZ18)+StrToReal(Pr.MarketElement[count].Input.Zakupka)*StrToReal(pr.MarketElement[count].Input.kol)
    ,CIzena,CMantissaZ,sSummaZ18);
    end;

    10: begin
    sKol10:=IntToStr(StrToInt(sKol10)+StrToInt(pr.MarketElement[count].Input.kol),CKol);
    MyStr(StrToReal(sSumma10)+StrToReal(Pr.MarketElement[count].Input.Zena)*StrToReal(pr.MarketElement[count].Input.kol)
    ,CIzena,CMantissaZ,sSumma10);
    MyStr(StrToReal(sSummaZ10)+StrToReal(Pr.MarketElement[count].Input.Zakupka)*StrToReal(pr.MarketElement[count].Input.kol)
    ,CIzena,CMantissaZ,sSummaZ10);
    end;
    else
    begin
     sKol_:=IntToStr(StrToInt(sKol_)+StrToInt(pr.MarketElement[count].Input.kol),CKol);
     MyStr(StrToReal(sSumma_)+StrToReal(Pr.MarketElement[count].Input.Zena)*StrToReal(pr.MarketElement[count].Input.kol)
    ,CIzena,CMantissaZ,sSumma_);
     MyStr(StrToReal(sSummaZ_)+StrToReal(Pr.MarketElement[count].Input.Zakupka)*StrToReal(pr.MarketElement[count].Input.kol)
	,CIzena,CMantissaZ,sSummaZ_);
     end;
    end;

  rformat(sKOl,Ckol);
  rformat(sKOl10,Ckol);
  rformat(sKOl18,Ckol);
  rformat(sKOl_,Ckol);
  rformat(sSumma,CIZena);
  rformat(sSumma10,CIZena);
  rformat(sSumma18,CIZena);
  rformat(sSumma_,CIZena);
  rformat(sSummaZ,CIZena);
  rformat(sSummaZ10,CIZena);
  rformat(sSummaZ18,CIZena);
  rformat(sSummaZ_,CIZena);

  s:=Pr.DAteC+';'+pr.SfNumer+';'+pr.ClientKod+';'+ws+';'
  +sKol+';'+sKol10+';'+sKol18+';'+sKol_+';'
  +sSumma+';'+sSumma10+';'+sSumma18+';'+sSumma_+';'
  +sSummaZ+';'+sSummaZ10+';'+sSummaZ18+';'+sSummaZ_;

End;


Begin
 bFind:=false;
 if (Temp<>nil) and (Temp^.List^.Count>0) then
 for i:=0 to Temp^.List^.Count-1 do
 begin

  ws:=BakGetField(FKMake,pr.MarketElement[Count].BazKod,0);
  Format(ws,CMAkeKod);

  s:=Temp^.GetText(i,Temp^.List^.Count);
  if (copy(s,1,CDate)=Pr.DateC) and
     (StrToInt(copy(s,posNum,CDocNumer))=StrToInt(pr.SfNumer)) then
  if (StrToInt(copy(s,posClient,CMakeKOd))=StrToInt(Pr.ClientKOd)) and
     (StrToInt(copy(s,posPost,CMakeKOd))=StrToInt(ws)) then
       begin

        format(Pr.DAteC,CDate);
        format(pr.SfNumer,CDocNumer);
        Format(pr.ClientKod,CMAkeKod);

        sKol:=copy(s,posKol,CKol);
        sKol10:=copy(s,posKol10,CKol);
        sKol18:=copy(s,posKol18,CKol);
        sKol_:=copy(s,posKol_,CKol);
        sSumma:=copy(s,posSumma,CIzena);
        sSumma10:=copy(s,posSumma10,CIzena);
        sSumma18:=copy(s,posSumma18,CIzena);
        sSumma_:=copy(s,posSumma_,CIzena);
        sSummaZ:=copy(s,posSummaZ,CIzena);
        sSummaZ10:=copy(s,posSummaZ10,CIzena);
        sSummaZ18:=copy(s,posSummaZ18,CIzena);
        sSummaZ_:=copy(s,posSummaZ_,CIzena);

        {уже есть}
        CalcElement;

        Temp^.List^.AtFree(i);
        Temp^.SetRange(Temp^.List^.Count);

        Temp^.List^.Insert(NewStr(s));
        Temp^.SetRange(Temp^.List^.Count);

        bFind:=true;
       end;
 end;
 if not bFind then
 begin
  {нет в списке}
  format(Pr.DAteC,CDate);
  format(pr.SfNumer,CDocNumer);
  Format(pr.ClientKod,CMAkeKod);

  ws:=BakGetField(FKMake,pr.MarketElement[Count].BazKod,0);
  Format(ws,CMAkeKod);

  sKol:='0';
  sKol10:='0';
  sKol18:='0';
  sKol_:='0';
  sSumma:='0.00';
  sSumma10:='0.00';
  sSumma18:='0.00';
  sSumma_:='0.00';
  sSummaZ:='0.00';
  sSummaZ10:='0.00';
  sSummaZ18:='0.00';
  sSummaZ_:='0.00';

  s:='';
  CalcElement;

  Temp^.List^.Insert(NewStr(s));
  Temp^.SetRange(Temp^.List^.Count);
 end;

End;


BEGIN
 if not DatePeriodDialog(StartDate,StopDate,False) then exit;

 Start:=DateStringToDate(DateMask,StartDate);
 Stop:=DateStringToDate(DateMask,StopDate);

 R.Assign(0,0,0,0);
 Temp:= New(PBox, Init(R, 1, Nil));
 Temp^.NewList(New(PTextCollection, Init(0,1)));
 {}
 for Den:=Start to Stop do
 begin
  DInfoMSgShkala('Обрабатываю продажи за '+DateToDateString(DateMAsk,Den),Start,Stop,Den);
  Assign(fPr,Path.ToMarket+DateToDateString(DateMAsk,Den)+'.mrk');
  IOrez:=ioresult;
  Reset(fPr);
  IOrez:=ioresult;
  if IOrez = 0 then
  begin
  while not eof(fPr) do
    begin
      read(fpr,pr);
      if pr.Active then
        If ((pr.DocSelector in [3,4]) And Not(pr.Realiz)) Or{не вторичная консигнация}
        (pr.DocSelector in [6,8]) Then{консигнация}
      begin
      for count := 1 to pr.Amount do
         AddToList;
      end;

    end;
   close(fpr);
  end
  else
  begin
    {memcc(Path.ToMarket+DateToDateString(DateMAsk,Den)+'.mrk');}
    continue;
  end;
 end;
 NoInfoMsg;

 Assign(t,'c:\market.csv');
 Iorez:=ioresult;
 Rewrite(t);
 Iorez:=ioresult;
 if iorez = 0 then
 begin
  writeln(t,DosToWin(';;Отчет по покупателям с '+StartDate+' по '+StopDate));
  writeln(t,DosToWin('Дата;N документа;Покупатель;Поставшик;Количество;Кол-во 10%;Кол-во 18%;Кол-во проч.;'+
  'Сумма общая;Сумма 10%;Сумма 18%;Сумма прочее;'+
  'Закупка общая;Закупка 10%;Закупка 18%;Закупка прочее;'));
  if (Temp<>nil) and (Temp^.List^.Count>0) then
  for i:=0 to Temp^.List^.Count-1 do
  begin
    s:=Temp^.GetText(i,Temp^.List^.Count);
    sKod:=copy(s,posPost,CMakeKod);
    sName:=GetClientField(FFFname,sKod,2);
    system.Delete(s,posPost,CMakeKod);
    system.Insert(sName,s,posPost);
    sKod:=copy(s,posClient,CMakeKod);
    sName:=GetClientField(FFFname,sKod,0);
    system.Delete(s,posClient,CMakeKod);
    system.Insert(sName,s,posClient);
    writeln(t,DosToWin(s));
  end;
  close(t);
 end
 else memcc('c:\market.csv');

 Dispose (Temp,Done);

 memcc('Результаты сохранены в файле c:\market.csv');



END;

procedure to1s;

var Temp: PBox;
    Start,Stop,Den: longint;
    StartDate,StopDate: TDateString;
    R: Trect;
    t,Txt1: Text;
    IORez,i: word;
    s: string;
    Pr : PrihodType;
    fPr: file of PrihodType;
    sNDS: string[2];
    fMr: file of SuperMarketType;
    fOp: File Of OplataRealizasiaType;
    Op: OplataRealizasiaType;
    Mr: PSuperMarketType;
    sKol: string[CKol];
    sSummaNds,sSumma,sSeb,vxNDS: string[CIzena];
    E:PSuperMarketType;
    NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Real;
    sDoc: String[CDOcNumer];
    sDate: string[CDate];
    fM: file of SuperMarketType;

procedure AddToList;
{работает с накладной}
var bFind: boolean;
    s,ws: string;
    i,count: word;
    sPost: string[CPost];
    sKol: string[CKol];
    sSummaNDS,sSumma: string[CIZena];

Begin
  format(Pr.Osn.DateNakl,CDate);
  format(pr.osn.NaklNumer,CDocNumer);
  ws:=GetClientField(FFFName,pr.MakeKod ,2);
  format(ws,CAll);

  for count:=1 to Pr.Amount do
  begin
    sKol:=pr.PrihodElement[count].Input.kol;
    sNds:=IntToStr(Trunc(StrToReal(GetIdField(FNDS,Pr.PrihodElement[count].BazKOd))),2);

    if StrToInt(GetIdField(FInPack,Pr.PrihodElement[count].BazKOd))>0 then
    MyStr(StrToReal(Pr.PrihodElement[count].Input.Zakupka)/
    StrToReal(GetIdField(FInPack,Pr.PrihodElement[count].BazKOd)),CZena,CMantissaZ,Pr.PrihodElement[count].Input.Zakupka)
    else;

    MyStr(StrToReal(Pr.PrihodElement[count].Input.Zakupka)*StrToReal(pr.PrihodElement[count].Input.kol)
      ,CIzena,CMantissaZ,sSumma);

    MyStr(StrToReal(sSumma)*
    StrToReal(sNds)/(100+StrToReal(sNds))
      ,CIzena,CMantissaZ,sSummaNDS);

  rformat(sKOl,Ckol);
  rformat(sSummaNDS,CIZena);
  rformat(sSumma,CIZena);
  s:=Pr.DateC+';'+Pr.Document+';'+Pr.Osn.DateNakl+';'+Pr.osn.NaklNumer+';'
  +GetClientField(fInn,pr.MakeKod ,2)+';'+ws+';'+pr.MakeKod+';'+sKol+';'
  +sSummaNDS+';'+sSumma+';'+sNDS;

  Temp^.List^.Insert(NewStr(s));
  Temp^.SetRange(Temp^.List^.Count);
 end;

End;

procedure AddVzwToList;
var i: word;
    find: boolean;
    ws,s: string;
    sDate: TDateString;
    sDocument: string[CDocNumer];
    sKod: ArtikulStr;
Begin
  if Temp^.List^.Count>0 then
  for i:=0 to Temp^.List^.Count-1 do
  begin
   ws:=Temp^.GetText(i,Temp^.List^.Count);
   s:=ws;
   sDate:=copy(s,1,pos(';',s));
   system.Delete(s,1,pos(';',s));
   sDocument:=copy(s,1,pos('/',s)-1);
   system.Delete(s,1,pos(';',s));
   sKod:=copy(s,1,pos(';',s));

  end;
End;


BEGIN
 if not DatePeriodDialog(StartDate,StopDate,False) then exit;

 Start:=DateStringToDate(DateMask,StartDate);
 Stop:=DateStringToDate(DateMask,StopDate);

 R.Assign(0,0,0,0);
 Temp:= New(PBox, Init(R, 1, Nil));
 Temp^.NewList(New(PMyCollection, Init(0,1)));
 {}
 for Den:=Start to Stop do
 begin
  DInfoMSgShkala('Обрабатываю приходы за '+DateToDateString(DateMAsk,Den),Start,Stop,Den);
  Assign(fPr,Path.ToPrihod+DateToDateString(DateMAsk,Den)+'.prh');
  IOrez:=ioresult;
  Reset(fPr);
  IOrez:=ioresult;
  if IOrez = 0 then
  BEGIN
    while not eof(fPr) do
    begin
      read(fpr,pr);
      AddToList;
    end;
   close(fpr);
  END
  else continue;
 end;
 NoInfoMsg;

 Assign(t,'c:\post1s.csv');
 Iorez:=ioresult;
 Rewrite(t);
 Iorez:=ioresult;
 if iorez = 0 then
 begin
  writeln(t,DosToWin('Дата скл;N скл;Дата пост;N пост;ИНН;Поставшик;Код;Количество;Сумма НДС;Сумма всего;НДС'));
  if (Temp<>nil) and (Temp^.List^.Count>0) then
  for i:=0 to Temp^.List^.Count-1 do
  begin
    s:=Temp^.GetText(i,Temp^.List^.Count);
    if i<>Temp^.List^.Count-1 then writeln(t,DosToWin(s))
    else write(t,DosToWin(s));

  end;
  close(t);
 end
 else memcc('c:\post1s.csv');

 Dispose (Temp,Done);

 R.Assign(0,0,0,0);
 Temp:= New(PBox, Init(R, 1, Nil));
 Temp^.NewList(New(PMyCollection, Init(0,1)));


 for Den:=Start to Stop do
 begin
  DInfoMSgShkala('Обрабатываю продажи за '+DateToDateString(DateMAsk,Den),Start,Stop,Den);
  Assign(fMr,Path.ToMarket+DateToDateString(DateMAsk,Den)+'.mrk');
  IOrez:=ioresult;
  Reset(fMr);
  IOrez:=ioresult;
  if IOrez = 0 then
  begin
  while not eof(fMr) do
    begin

      New(Mr,Init);

      read(fMr,Mr^.Dat);
      if Mr^.Dat.Active then
       (* If ((Mr.DocSelector in [3,4]) And Not(Mr.Realiz)) Or{не вторичная консигнация}
        (Mr.DocSelector in [5,6,7,8]) Then{консигнация} *)
        If (Not(Mr^.Dat.Realiz) And (Mr^.Dat.DocSelector in [3,4])) Or
         ((Mr^.Dat.Realiz) And (Mr^.Dat.DocSelector in [6,7,8])) Then
      begin
      RecalcFromVozwrat(Mr);
      for i := 1 to Mr^.Dat.Amount do
        begin

    sKol:=Mr^.Dat.MarketElement[i].Input.kol;
    sNds:=IntToStr(Trunc(StrToReal(GetIdField(FNDS,Mr^.Dat.MarketElement[i].BazKOd))),2);

    If Mr^.Dat.SkidkaSelector in [0,2] Then
               Begin

                DelSpace(Mr^.Dat.MarketElement[i].Input.Proz);
			 MyStr((StrToReal(Mr^.Dat.MarketElement[i].Input.Zena)*
                (StrToReal(Mr^.Dat.MarketElement[i].Input.Proz))),CZena,CMantissa,
                         Mr^.Dat.MarketElement[i].Input.Zena);

               End
                Else
               Begin
                {сумма скидки}
                MyStr((StrToReal(Mr^.Dat.MarketElement[i].Input.Zena)-
                         StrToReal(Mr^.Dat.MarketElement[i].Input.Skidka)),
                         CZena,CMantissa,
                                        Mr^.Dat.MarketElement[i].Input.Zena);
               End;

    MyStr(StrToReal(Mr^.Dat.MarketElement[i].Input.Zena)*StrToReal(Mr^.Dat.MarketElement[i].Input.kol)
      ,CIzena,CMantissa,sSumma);

    MyStr(StrToReal(sSumma)*
    StrToReal(sNds)/(100+StrToReal(sNds))
      ,CIzena,CMantissa,sSummaNDS);

    MyStr((StrToReal(Mr^.Dat.MarketElement[i].Input.Zakupka)
    -StrToReal(Mr^.Dat.MarketElement[i].Input.Zakupka)*StrToReal(sNds)/(100+StrToReal(sNds)))
    *StrToReal(Mr^.Dat.MarketElement[i].Input.kol),
      CIzena,CMantissa,sSeb);


    MyStr(StrToReal(Mr^.Dat.MarketElement[i].Input.Zakupka)*StrToReal(sNds)/(100+StrToReal(sNds))
    *StrToReal(Mr^.Dat.MarketElement[i].Input.kol),
      CIzena,CMantissa,vxNDS);


    rformat(sKOl,Ckol);
    rformat(sSummaNDS,CIZena);
    rformat(sSumma,CIZena);

  s:=Mr^.Dat.DateC+';'+Mr^.Dat.Document+'/'+Mr^.Dat.SfNumer+';'+
  +GetClientField(fInn,Mr^.Dat.ClientKod ,0)+';'+GetClientField(FFFName,Mr^.Dat.ClientKod,0)+';'
  +Mr^.Dat.ClientKod+';'+sKol+';'
  +sSummaNDS+';'+sSumma+';'+sSeb+';'+sNDS+';'+vxNDS+';';

  if Mr^.Dat.DocSelector in [6,8] then
  s:=s+'1'
  else s:=s+'0';

  Temp^.List^.Insert(NewStr(s));
  Temp^.SetRange(Temp^.List^.Count);


        end;
      end;
      Dispose(mr,Done);
    end;
   close(fMr);
  end
  else
  begin
    continue;
  end;
 end;
 NoInfoMsg;


 Assign(t,'c:\mrk1s.csv');
 Iorez:=ioresult;
 Rewrite(t);
 Iorez:=ioresult;
 if iorez = 0 then
 begin
{  writeln(t,DosToWin(';;Отчет по покупателям с '+StartDate+' по '+StopDate));}
  writeln(t,DosToWin('Дата;N док/N сф;ИНН;Покупатель;Код;Количество;Сумма НДС;Выручка;Себестоим;'+
  'НДС;Вх НДС;Опт'));
  if (Temp<>nil) and (Temp^.List^.Count>0) then
  for i:=0 to Temp^.List^.Count-1 do
  begin
    s:=Temp^.GetText(i,Temp^.List^.Count);
    if i<>Temp^.List^.Count-1 then writeln(t,DosToWin(s))
    else write(t,DosToWin(s));
  end;
  close(t);
 end
 else memcc('c:\mrk1s.csv');

 Dispose (Temp,Done);

 R.Assign(0,0,0,0);
 Temp:= New(PBox, Init(R, 1, Nil));
 Temp^.NewList(New(PMyCollection, Init(0,1)));


 Assign(t,'c:\kas1s.csv');
 Iorez:=ioresult;
 Rewrite(t);
 Iorez:=ioresult;
if iorez = 0 then
 begin
 writeln(t,DosToWin('N док;Дата;Вид док;Бух счет;ИНН конр;Наимен.конр;Сумма;НДС'));


 for Den:=Start to Stop do
 begin
  DInfoMSgShkala('Обрабатываю оплаты за '+DateToDateString(DateMAsk,Den),Start,Stop,Den);
  Assign(fOp,Path.ToOplata+DateToDateString(DateMAsk,Den)+'.opl');
  IOrez:=ioresult;
  Reset(fOp);
  IOrez:=ioresult;
  if IOrez = 0 then
  begin
  while not eof(fOp) do
    begin
      read(fOp,Op);
      if not (Op.Vozwrat) then
      if not (Op.Rashet) then
      begin

        SDoc:=Op.Document;
        sDate:=Op.DateDoc;

        Assign(Fm,Path.ToMarket+sDate+'.mrk');
        IOrez:=ioresult;
        Reset(fm);
        IOrez:=ioresult;
        if IOrez=0 then
        begin
          New(E,Init);
          while  not eof(fm) do
          begin
            read(fm,E^.Dat);
            if StrToInt(sDoc)=StrToInt(E^.Dat.Document) then
            Begin
             Rewrite(Txt1);
             FormSf(False, E, Txt1, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_);
             Close(txt1);

             MyStr(NDS,CIZena,CMantissa,sNDS);
             s:=';'+Op.DateC+';ПКО;'+';'+GetClientField(fInn,Op.ClientKod ,0)
	        +';'+GetClientField(FFFName,Op.ClientKod,0)+';'+Op.SummaZ+';'+sNds;
             Temp^.List^.Insert(NewStr(s));
             Temp^.SetRange(Temp^.List^.Count);
            end;
          end;
          Dispose(E,Done);
        end;
      end;
    end;

    close(fOp);
  end
  else continue;
 end;

end;

  if (Temp<>nil) and (Temp^.List^.Count>0) then
  for i:=0 to Temp^.List^.Count-1 do
  begin
    s:=Temp^.GetText(i,Temp^.List^.Count);
    if i<>Temp^.List^.Count-1 then writeln(t,DosToWin(s))
    else write(t,DosToWin(s));
  end;



Dispose(Temp,Done);

close(t);
NoInfoMsg;

 MessageBox(#3'Результаты сохранены в файлах c:\post1s.csv,c:\mrk1s.csv,kas1s.csv ',Nil,mfError+mfCancelButton);

END;

procedure ProzNdsDay;
var sDate : TDateString;
    fMr: file of SupermarketType;
    Mr: SupermarketType;
    i, IOrez: word;
    sSumma,sSummaNDS,sSummaNDS0,sSummaNDS10,sSummaNDS18: string[CIZena];
    SummaNDS,SummaNDS0,SummaNDS10,SummaNDS18:real;
    StartDate,StopDate: TDateString;
    den,start,stop: longint;
    sNds : string [CZena];
    t: text;
Begin
if not DatePeriodDialog(StartDate,StopDate,False) then exit;
start:=DateStringToDate(DAtemask,StartDate);
stop:=DateStringToDate(DAtemask,StopDate);

  assign(t,'c:\prozent.csv');
   Iorez:=ioresult;
   Rewrite(t);
   Iorez:=ioresult;
if iorez = 0 then
begin


for den:=start to stop do
begin

  sdate:=DateToDateString(DAtemask,den);
  DInfoMSgShkala(msg+sDate,Start,Stop,Den);
  sSummaNDS:='0.00';
  sSummaNDS0:='0.00';
  sSummaNDS10:='0.00';
  sSummaNDS18:='0.00';
  Assign(fMr,Path.ToMarket+sdate+'.mrk');
  IOrez:=ioresult;
  Reset(fMr);
  IOrez:=ioresult;

  if IOrez = 0 then
  begin
  while not eof(fMr) do
    begin
      read(fMr,Mr);
      if Mr.Active then
        If (Not(Mr.Realiz) And (Mr.DocSelector in [3,4])) Or
         ((Mr.Realiz) And (Mr.DocSelector in [5,7])) Then
      begin
      for i := 1 to Mr.Amount do
        begin

    sNds:=IntToStr(Trunc(StrToReal(GetIdField(FNDS,Mr.MarketElement[i].BazKOd))),2);
    if GetNullNDS(BakGetField(FKMake,Mr.MarketElement[i].BazKOd,0)) then
    begin
    sNds:='0';
    end;

    If Mr.SkidkaSelector in [0,2] Then
               Begin

                DelSpace(Mr.MarketElement[i].Input.Proz);
			 MyStr((StrToReal(Mr.MarketElement[i].Input.Zena)*
                (StrToReal(Mr.MarketElement[i].Input.Proz))),CZena,CMantissa,
                         Mr.MarketElement[i].Input.Zena);

               End
                Else
               Begin
                {сумма скидки}
                MyStr((StrToReal(Mr.MarketElement[i].Input.Zena)-
                         StrToReal(Mr.MarketElement[i].Input.Skidka)),
                         CZena,CMantissa,
                                        Mr.MarketElement[i].Input.Zena);
               End;

    MyStr(StrToReal(Mr.MarketElement[i].Input.Zena)*StrToReal(Mr.MarketElement[i].Input.kol)
      ,CIzena,CMantissa,sSumma);

    MyStr(StrToReal(sSummaNDS)+StrToReal(sSumma),CIzena,CMantissa,sSummaNDS);

    case StrToInt(sNds) of
     0:  MyStr(StrToReal(sSummaNDS0)+StrToReal(sSumma),CIzena,CMantissa,sSummaNDS0);
     10: MyStr(StrToReal(sSummaNDS10)+StrToReal(sSumma),CIzena,CMantissa,sSummaNDS10);
     18: MyStr(StrToReal(sSummaNDS18)+StrToReal(sSumma),CIzena,CMantissa,sSummaNDS18);
     else MyStr(StrToReal(sSummaNDS0)+StrToReal(sSumma),CIzena,CMantissa,sSummaNDS0);
    end;


  end; {for i := 1 to Mr.Amount}
  End; {if Mr.Active}
  End; {while not eof(fMr)}
  END else continue;  {if IOrez = 0}


   SummaNDS:=StrToReal(sSummaNds);
   SummaNDS0:=StrToReal(sSummaNds0);
   SummaNDS10:=StrToReal(sSummaNds10);
   SummaNDS18:=StrToReal(sSummaNds18);

   if SummaNds>0.01 then
   write(t,sDate,';',(SummaNds0*100)/SummaNds:8:2,';',SummaNds10*100/SummaNds:8:2,';',SummaNds18*100/SummaNds:8:2)
   else
   write(t,sDate,';',0,';',0,';',0);
   if den<>stop then writeln(t);
 End;
 close(t);
 NoInfoMsg;
 MessageBox(#3'Результаты сохранены в файле c:\prozent.csv',Nil,mfError+mfCancelButton);

end else memcc('Ошибка c:\prozent.csv');

End;


BEGIN
END.