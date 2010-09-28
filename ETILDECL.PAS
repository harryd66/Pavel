Unit EtilDecl;

{Декларации 2006 - в меню есть
- формат выгрузки для налоговой - 3.1
печатает декларацию с пом. decl.exe и Report1.rav}

INTERFACE

Uses Glob,ServStr;

function CalcDeclareOborot: boolean;

IMPLEMENTATION
Uses Objects,App,Views,Validate,MsgBox, TPDate,Printers,Prise,
     Serv,Dialogs,Drivers,DBengin2,Dos,Memory,
     NetDbEng,DBEngine, Tools, Utils,Utils5, ColorTxt,Utils3,Utils4;

const posArt = 1;
      posOstN = posArt+CArtikul+1;
      posPrhProizv = posOstN+CIZena+1;
      posPrhOpt = posPrhProizv+CIZena+1;
      posPrhImp = posPrhOpt+CIZena+1;
      posVozvPost = posPrhImp+CIZena+1;  {Упс! КЛИЕНТОВ!!!!}
      posMrkOpt = posVozvPost+CIZena+1;
      posMrkRozn = posMrkOpt+CIZena+1;
      posMrkEksp = posMrkRozn+CIZena+1;
      posVozvCl = posMrkEksp+CIZena+1;   {Упс! Поставщиков!!!!}
      posRashXZ = posVozvCl+CIZena+1;
      posOstK = posRashXZ+CIZena+1;

      posArtD = 1;
      posClientD = posArtD+CArtikul+1;
      posDateD = posClientD+CClientKod+1;
      posNumerD = posDateD+CDate+1;
      PosKolD = posDateD+CDate+1;
      PosKolDZak = posNumerD+CName+1;
      PosNumDMrk = PosKolD+CIzena+1;

      Dall = 10000000;

Shablon ='│              0│              0│              0│              0│              0│              0│              0│'
+'              0│              0│              0│              0│';
{          123456789012345 123456789012345 123456789012345 123456789012345 123456789012345 123456789012345 123456789012345
           posOstN         posPrhProizv    posPrhOpt       posPrhImp       posVozvPost     posMrkOpt        posMrkRozn
            123456789012345 123456789012345 123456789012345 123456789012345
           posMrkEksp       posVozvCl       posRashXZ       posOstK}
ShablonD ='│              0';

const BufferNewItog = 30;

Type BufNewItogType = Record
     Dat : Array [1..BufferNewItog] Of NewItogType;
     end;

var TempBox: PBox;
    PostavkaBox: PBox;
    PostavkaBox1: PBox;
    ZakupkaBox: PBox;
    {ZakupkaBox1: PBox;}
    ErrorBox: PBox;
    SelectClass: boolean;
    OborotFile: text;
    PostavkaFile: text;
    ZakupkaFile: text;

{--------ФУНКЦИИ ДЛЯ ВЫГРУЗКМ В АЦЦКОМ ФОРМАТЕ ДЛЯ ФНС}
const OborotFilePrefix = 'a5';
      PostavkaFilePrefix = 'a6';
      ZakupkaFilePrefix = 'a7';

const Digits: set of Char = ['1','2','3','4','5','6','7','8','9','0'];
      RusLetters: set of Char = ['а'..'я','А'..'Я'];

const DeclDat: array [1..18] of AllStr = (
                 {  ОБОРОТ         ЗАКУПКА         ПОСТАВКА }
'П000000000001:',
'П000000000002:',{ наименование продукции                   }
'П000000000003:',{ код вида продукции         │             }
'П000000000004:',{ ост н       │ наим пост    │             }
'П000000000005:',{ пост всего  │ код субъектРФ│  -- !! ---  }
'П000000000006:',{ зак всего   │ ИНН пост     │  ИНН получ  }
'П000000000007:',{ зак произв  │ КПП пост     │  КПП получ  }
'П000000000008:',{ зак опт     │ Адрес пост   │  Адрес      }
'П000000000009:',{ зак имп     │ лицензия     │  лицензия   }
'П000000000010:',{ возврат     │ кем выдана   │  кем выдана }
'П000000000011:',{ расх всего  │ уведомление  │  уведомление}
'П000000000012:',{ отгр всего  │ дата отгр    │  -- !! ---  }
'П000000000013:',{ отгр опт    │ номер ТТН    │  -- !! ---  }
'П000000000014:',{ отгр розн   │ д перес гранц│  -- !! ---  }
'П000000000015:',{ отгр эксп   │ объем пост   │  -- !! ---  }
'П000000000016:',{ возвр нам   │     -        │     -       }
'П000000000017:',{ прочее      │     -        │     -       }
'П000000000018:');{ост кон     │     -        │     -       }

function FormName(kod: Artikulstr): string;
{тестер не пропустил, длины поля не хватат - пришлось так...}
const n211 = 'ЛИКЕРОВОДОЧНЫЕ ИЗДЕЛИЯ С СОДЕРЖАНИЕМ ЭТИЛОВОГО СПИРТА ДО 25% ВКЛЮЧИТЕЛЬНО';
      n212 = 'ЛИКЕРОВОДОЧНЫЕ ИЗДЕЛИЯ С СОДЕРЖАНИЕМ ЭТИЛОВОГО СПИРТА СВЫШЕ 25%';
      n250 = 'НАПИТКИ ВИННЫЕ С СОДЕРЖАНИЕМ ЭТИЛОВОГО СПИРТА ДО 25% ВКЛЮЧИТЕЛЬНО';
begin

  case StrToInt(kod) of
  211: begin
         FormName:=DeclDat[2]+n211;
         exit;
       end;
  212: begin
         FormName:=DeclDat[2]+n212;
         exit;
       end;
  250: begin
         FormName:=DeclDat[2]+n250;
         exit;
       end;
  end;
  FormName:=
  DeclDat[2]+GetClassField(FName,KOd);

end;


Function SelectOrg:Byte;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
SelectOrg:=0;

R.Assign(26, 9, 53, 13);
New(Dlg, Init(R, 'Выбор организации'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E241;

R.Assign(1, 1, 26, 3);
Control := New(PRadioButtons, Init(R,
  NewSItem('Триада-Сервис',
  NewSItem('Продмаркет', Nil))));

Dlg^.Insert(Control);

c:=0;

Dlg^.SetData(c);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
  Begin
   Dlg^.GetData(c);
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectOrg:=c;
  End
  Else
  Begin
   Dispose(Control,Done);
   Dispose(Dlg,Done);
   SelectOrg:=2;
  End;
end;

function FormClientAdres(s: AllStr;Inn:AllStr):string;
Begin
   FormClientAdres:='643,,,,,,,,,';
   if s='' then exit;
   while pos(',',s)>0 do s[pos(',',s)]:=' ';
   format(s,40);
   DelSpaceRight(s);
   FormClientAdres:='643,300000,'+Copy(inn,1,2)+','+s+',,,,,,';
End;

function FormDate(d:DateString):string;
{работает до 2100 года}
var s: string;
Begin
  while pos('-',d)>0 do d[pos('-',d)]:='.';
  s:=d;
  system.insert('20',s,length(s)-1);
  FormDate:=s;
End;

function FormLicName(s:string):string;
BEgin
   FormLicName:=',,';
   if s='' then exit;
   if pos('.',s)>5 then
   system.insert(',',s,pos('.',s)-3);
   if pos('Р/',s)>0 then
   begin
     system.insert(',',s,pos('Р/',s));
     system.delete(s,pos('Р/',s),3);
   end;
   if pos('ОТ',s)>0 then
     system.delete(s,pos('ОТ',s),2);
   if pos('РЕГ',s)>0 then
     system.delete(s,pos('РЕГ',s),3);
   Delspace(s);
   if not (s[length(s)] in Digits) then system.delete(s,length(s),1);
   system.insert('20',s,length(s)-1);
   FormLicName:=s;
End;

{end-----ФУНКЦИИ ДЛЯ ВЫГРУЗКМ В АЦЦКОМ ФОРМАТЕ ДЛЯ ФНС}

function BinSearch(P:PBox;var ind:word;s: string): boolean;
{по коду товара}
var l,r,m: word;
    st: string;
Begin
 BinSearch:=false;
 ind:=0;
 l:=0; r:=P^.List^.Count;
 while l<r do
 begin
   m:=(l+r) div 2;
   St:=P^.GetText(m,P^.List^.Count);
   ST:=Copy(St,1,CArtikul);
   If StrToInt(St)=StrToInt(S) Then
     begin
      BinSearch:=true;
      ind:=m;
      exit;
     end;
   if StrToInt(St)<StrToInt(s) then l:=m+1
   else r:=m;
 end;
 if StrToInt(St)=StrToInt(S) then
  Begin
   BinSearch:=true;
   ind:=m;
  End;
End;

function BinSearchCl(P:PBox;var ind:word;s: string): boolean;
{по коду товара + код клиента}
var l,r,m: word;
    st,st1: string;
Begin
 BinSearchCl:=false;
 ind:=0;
 l:=0; r:=P^.List^.Count;
 while l<r do
 begin
   m:=(l+r) div 2;
   St:=P^.GetText(m,P^.List^.Count);
   st1:=Copy(St,posClientD,CClientKod);
   rformatZerro(st1,CClientKod);
   ST:=Copy(St,1,CArtikul);
   rformatzerro(st,CArtikul);
   If StrToInt(St+st1)=StrToInt(S) Then
     begin
      BinSearchCl:=true;
      ind:=m;
      exit;
     end;
   if StrToInt(St)<StrToInt(s) then l:=m+1
   else r:=m;
 end;
 if StrToInt(St)=StrToInt(S) then
  Begin
   BinSearchCl:=true;
   ind:=m;
  End;
End;


procedure MrkXZAddToList(E: SuperMarkettype);
var i,j : word;
    find: boolean;
    SumKol:String[CIZena];
    SumZena:String[CIZena];
    sKol: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    sKOd,sKOd1 : string[CArtikul];
    s: string;
    sLitr:String[CIZena];
Begin
 find:=false;

For i:=1 to E.Amount do
Begin

if GetRazdelLitr(copy(E.MarketElement[i].bazkod,1,CRazdelKod))=1 then
begin
 find:=false;
 if not SelectClass then sKOd:=E.MarketElement[i].bazkod
 else
 sKOd:=GetIdField(FClass,E.MarketElement[i].BazKod);
 case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430: sKod:='420';
  440,450: sKOd:='450';
 end;
 rformatzerro(sKOd,CArtikul);
 sLitr:=GetIdField(FLitr,E.MarketElement[i].bazkod);
 sLitr:=IntToStr(Round(StrToReal(sLitr)*1000),CIZena);
 If (TempBox^.List^.Count>0) and (TempBox^.List^.Count<10) Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
         s:=TempBox^.GetText(j,TempBox^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         if StrToInt(sKod1)=StrToInt(sKod) then
         begin
           {код есть в списке}
           sKol:=E.MarketElement[i].Input.kol;

           SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
              StrToInt(copy(s,posRashXZ,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,posRashXZ,CIZena);
           System.Insert(SumKol,s,posRashXZ);

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
           break;
         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end {If TempBox^.List^.Count>0}
   else if BinSearch(TempBox,j,sKOd) then
     begin
           s:=TempBox^.GetText(j,TempBox^.List^.Count);
           sKol:=E.MarketElement[i].Input.kol;

           SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
              StrToInt(copy(s,posRashXZ,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,posRashXZ,CIZena);
           System.Insert(SumKol,s,posRashXZ);

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
     end;

   if not Find then
   begin
    {позиция новая}
    {s:=E.MarketElement[i].bazkod+Shablon;}
    s:=sKOd+Shablon;

    sKol:=IntToStr(StrToInt(E.MarketElement[i].Input.Kol)*StrToInt(sLitr),CIZena);
    rFormat(sKOl,CIzena);
    System.Delete(s,posRashXZ,CIZena);
    System.Insert(sKol,s,posRashXZ);

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

  end; {if GetRazdelLitr(sKOd)}
 end;  {For i:=1 to E.Amount}

End;


procedure MrkAddToList(E: SuperMarkettype);
var i,j : word;
    find: boolean;
    SumKol:String[CIZena];
    SumZena:String[CIZena];
    sKol: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    sKOd,sKOd1 : string[CArtikul];
    s: string;
    sLitr:String[CIZena];
Begin
 find:=false;

For i:=1 to E.Amount do
Begin

if GetRazdelLitr(copy(E.MarketElement[i].bazkod,1,CRazdelKod))=1 then
begin
 find:=false;
 if not SelectClass then sKOd:=E.MarketElement[i].bazkod
 else
 sKOd:=GetIdField(FClass,E.MarketElement[i].BazKod);
 case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430: sKod:='420';
  440,450: sKOd:='450';
 end;
 rformatzerro(sKOd,CArtikul);
 sLitr:=GetIdField(FLitr,E.MarketElement[i].bazkod);
 sLitr:=IntToStr(Round(StrToReal(sLitr)*1000),CIZena);
 If (TempBox^.List^.Count>0) and (TempBox^.List^.Count<10) Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
         s:=TempBox^.GetText(j,TempBox^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         if StrToInt(sKod1)=StrToInt(sKod) then
         begin
           {код есть в списке}
           sKol:=E.MarketElement[i].Input.kol;

           SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
              StrToInt(copy(s,PosMrkRozn,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,PosMrkRozn,CIZena);
           System.Insert(SumKol,s,PosMrkRozn);

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
           break;
         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end {If TempBox^.List^.Count>0}
   else if BinSearch(TempBox,j,sKOd) then
     begin
           s:=TempBox^.GetText(j,TempBox^.List^.Count);
           sKol:=E.MarketElement[i].Input.kol;

           SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
              StrToInt(copy(s,PosMrkRozn,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,PosMrkRozn,CIZena);
           System.Insert(SumKol,s,PosMrkRozn);

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
     end;

   if not Find then
   begin
    {позиция новая}
    {s:=E.MarketElement[i].bazkod+Shablon;}
    s:=sKOd+Shablon;

    sKol:=IntToStr(StrToInt(E.MarketElement[i].Input.Kol)*StrToInt(sLitr),CIZena);
    rFormat(sKOl,CIzena);
    System.Delete(s,PosMrkRozn,CIZena);
    System.Insert(sKol,s,PosMrkRozn);

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

  end; {if GetRazdelLitr(sKOd)}
 end;  {For i:=1 to E.Amount}

End;

procedure MrkDeclarePostavka(E: SuperMarkettype);
{Декларация об объемах поставки}
var i,j : word;
    find: boolean;
    SumKol:String[CIZena];
    sLitr:String[CIZena];
    sKol: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    sKOd,sKOd1 : string[CArtikul];
    sClient,sClient1: string [CClientKod];
    s: string;
    sDate,sDate1:TDateString;

Begin

For i:=1 to E.Amount do
Begin
find:=false;
if not SelectClass then sKOd:=E.MarketElement[i].bazkod
else sKOd:=GetIdField(FClass,E.MarketElement[i].BazKod);
case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430: sKod:='420';
  440,450: sKOd:='450';
end;

RFormat(sKod,CArtikul);
sClient:=E.ClientKOd;
sDate:=E.DateC;
RFormatZerro(sKod,CArtikul);
RFormatZerro(sClient,CClientKod);
if GetRazdelLitr(copy(E.MarketElement[i].BazKod,1,CRazdelKod))=1 then
begin
 sLitr:=GetIdField(FLitr,E.MarketElement[i].bazkod);
 sLitr:=IntToStr(Round(StrToReal(sLitr)*1000),CIZena);
 If (PostavkaBox^.List^.Count>0) and (PostavkaBox^.List^.Count<MaxCollectionSize) Then
   begin
    for j:=0 to PostavkaBox^.List^.Count-1 do
      begin
         s:=PostavkaBox^.GetText(j,PostavkaBox^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         sClient1:=copy(s,posClientD,CClientKOd);
         sDate1:= copy(s,posDateD,CDate);
         if ((StrToInt(sKod1)=StrToInt(sKod))
            and (StrToInt(sClient1)=StrToInt(sClient))) and
            (sDate=sDate1) then
         begin
           {код есть в списке}

           sKol:=E.MarketElement[i].Input.kol;

           SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
              StrToInt(copy(s,PosKolD,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,PosKolD,CIZena);
           System.Insert(SumKol,s,PosKolD);

           PostavkaBox^.List^.AtFree(j);
           PostavkaBox^.SetRange(PostavkaBox^.List^.Count);

           PostavkaBox^.List^.Insert(NewStr(s));
           PostavkaBox^.SetRange(PostavkaBox^.List^.Count);

           find:=true;
           break;
         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to PostavkaBox^.List^.Count-1}
   end  {If PostavkaBox^.List^.Count>0}
   else If (PostavkaBox1^.List^.Count>0) then
   begin
      for j:=0 to PostavkaBox1^.List^.Count-1 do
      begin
         s:=PostavkaBox1^.GetText(j,PostavkaBox1^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         sClient1:=copy(s,posClientD,CClientKOd);
         sDate1:= copy(s,posDateD,CDate);
         if ((StrToInt(sKod1)=StrToInt(sKod))
            and (StrToInt(sClient1)=StrToInt(sClient))) and
            (sDate=sDate1) then
         begin
           {код есть в списке}

           sKol:=E.MarketElement[i].Input.kol;

           SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
              StrToInt(copy(s,PosKolD,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,PosKolD,CIZena);
           System.Insert(SumKol,s,PosKolD);

           PostavkaBox1^.List^.AtFree(j);
           PostavkaBox1^.SetRange(PostavkaBox1^.List^.Count);

           PostavkaBox1^.List^.Insert(NewStr(s));
           PostavkaBox1^.SetRange(PostavkaBox1^.List^.Count);

           find:=true;
           break;
         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to PostavkaBox1^.List^.Count-1}
   end;

   if not Find then
   begin
    {позиция новая}
    s:=sKod+'│'+E.ClientKod+'│'+sDate+ShablonD+'│'+E.Document;

    sKol:=IntToStr(StrToInt(E.MarketElement[i].Input.Kol)*StrToInt(sLitr),CIZena);
    rFormat(sKOl,CIzena);
    System.Delete(s,PosKolD,CIZena);
    System.Insert(sKol,s,PosKolD);

    if  PostavkaBox^.List^.Count<MaxCollectionSize THEN
    begin
     PostavkaBox^.List^.Insert(NewStr(s));
     PostavkaBox^.SetRange(PostavkaBox^.List^.Count);
    end
    else
    begin
     PostavkaBox1^.List^.Insert(NewStr(s));
     PostavkaBox1^.SetRange(PostavkaBox1^.List^.Count);
    end;
   end;

  end; {if GetRazdelLitr(sKOd)}
 end;  {For i:=1 to E.Amount}

End;

procedure PrhDeclare(E: Prihodtype);
{Декларация об объемах закупки}
var i,j : word;
    find: boolean;
    SumKol,sLitr,sLitr1:String[CIZena];
    SumZena:String[CIZena];
    sKol: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    sKOd,sKOd1 : string[CArtikul];
    sClient, sClient1: string[CClientKOd];
    s: string;
    sDate,sDate1:TDateString;
    SnUMER,SnUMER1: String[CName];
Begin
 find:=false;

For i:=1 to E.Amount do
Begin
find:=false;
{sKOd:=E.PrihodElement[i].bazkod;}
if not SelectClass then sKOd:=E.PrihodElement[i].bazkod
else sKOd:=GetIdField(FClass,E.PrihodElement[i].BazKod);
 case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430: sKod:='420';
  440,450: sKOd:='450';
 end;
RFormat(sKod,CArtikul);
sClient:=E.MakeKOd;
sDate:=E.DateC;
sNumer:=E.Rekwizit.Numer;
rformatzerro(sKOd,CArtikul);
rformatzerro(sClient,CClientKod);
DelSpace(sNumer);
if GetRazdelLitr(copy(E.PrihodElement[i].BazKod,1,CRazdelKod))=1 then
begin
 sLitr:=GetIdField(FLitr,E.PrihodElement[i].bazkod);
 sLitr:=IntToStr(Round(StrToReal(sLitr)*1000),CIZena);
 If ZakupkaBox^.List^.Count>0 Then
   begin
    for j:=0 to ZakupkaBox^.List^.Count-1 do
      begin
         s:=ZakupkaBox^.GetText(j,ZakupkaBox^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         sClient1:=copy(s,posClientD,CClientKOd);
         sDate1:= copy(s,posDateD,CDate);
         sNumer1:=copy(s,posNumerD,CName);
         DelSpace(sNumer1);
         if (StrToInt(sKod1)=StrToInt(sKod))
            and (StrToInt(sClient1)=StrToInt(sClient))
            and (sDate=sDate1) and (sNumer=sNumer1)
            then
         begin
           {код есть в списке}

           sKol:=E.PrihodElement[i].Input.kol;

           SumKol:=IntToStr(StrToInt(E.PrihodElement[i].Input.kol)*StrToInt(sLitr)+
           StrToInt(copy(s,PosKolDZak,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,PosKolDZak,CIZena);
           System.Insert(SumKol,s,PosKolDZak);


           ZakupkaBox^.List^.AtFree(j);
           ZakupkaBox^.SetRange(ZakupkaBox^.List^.Count);

           ZakupkaBox^.List^.Insert(NewStr(s));
           ZakupkaBox^.SetRange(ZakupkaBox^.List^.Count);

           find:=true;
           break;
         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end  {If TempBox^.List^.Count>0}
   else if BinSearchCl(ZakupkaBox,j,sKOd+sClient) then
   begin
     sKol:=E.PrihodElement[i].Input.kol;

           SumKol:=IntToStr(StrToInt(E.PrihodElement[i].Input.kol)*StrToInt(sLitr)+
           StrToInt(copy(s,PosKolD,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,PosKolDZak,CIZena);
           System.Insert(SumKol,s,PosKolDZak);


           ZakupkaBox^.List^.AtFree(j);
           ZakupkaBox^.SetRange(ZakupkaBox^.List^.Count);

           ZakupkaBox^.List^.Insert(NewStr(s));
           ZakupkaBox^.SetRange(ZakupkaBox^.List^.Count);

           find:=true;
   end;

   if not Find then
   begin
    {позиция новая}

    Format(E.Rekwizit.Numer,CName);
    s:=sKOd+'│'+E.MakeKod+
      '│'+sDate+'│'+E.Rekwizit.Numer+'│'+ShablonD;

    sKol:=IntToStr(StrToInt(E.PrihodElement[i].Input.Kol)*StrToInt(sLitr),CIZena);
    rFormat(sKOl,CIzena);
    System.Delete(s,PosKolDZak,CIZena);
    System.Insert(sKol,s,PosKolDZak);

    ZakupkaBox^.List^.Insert(NewStr(s));
    ZakupkaBox^.SetRange(ZakupkaBox^.List^.Count);
   end;

  end; {if GetRazdelLitr(sKOd)}
 end;  {For i:=1 to E.Amount}

End;


procedure MrkOptAddToList(E: SuperMarkettype);
var i,j : word;
    find: boolean;
    SumKol:String[CIZena];
    sLitr,SumZena:String[CIZena];
    sKol: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    sKOd,sKOd1 : string[CArtikul];
    s: string;
Begin
 find:=false;

For i:=1 to E.Amount do
Begin
if GetRazdelLitr(copy(E.MarketElement[i].bazkod,1,CRazdelKod))=1 then
begin
 find:=false;
 if not SelectClass then sKOd:=E.MarketElement[i].bazkod
 else
 sKOd:=GetIdField(FClass,E.MarketElement[i].BazKod);
 case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430: sKod:='420';
  440,450: sKOd:='450';
 end;

 rformatzerro(sKOd,CArtikul);
 sLitr:=GetIdField(FLitr,E.MarketElement[i].bazkod);
 sLitr:=IntToStr(Round(StrToReal(sLitr)*1000),CIZena);
 If (TempBox^.List^.Count>0) and (TempBox^.List^.Count<10) Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
         s:=TempBox^.GetText(j,TempBox^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         if StrToInt(sKod1)=StrToInt(sKod) then
         begin
           {код есть в списке}

           sKol:=E.MarketElement[i].Input.kol;

           SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
              StrToInt(copy(s,posMrkOpt,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,posMrkOpt,CIZena);
           System.Insert(SumKol,s,posMrkOpt);

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
           break;
         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end  {If TempBox^.List^.Count>0}
   else if BinSearch(TempBox,j,sKod) then
   begin
        s:=TempBox^.GetText(j,TempBox^.List^.Count);
        sKol:=E.MarketElement[i].Input.kol;

           SumKol:=IntToStr(StrToInt(E.MarketElement[i].Input.kol)*StrToInt(sLitr)+
              StrToInt(copy(s,posMrkOpt,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,posMrkOpt,CIZena);
           System.Insert(SumKol,s,posMrkOpt);

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
   end;

   if not Find then
   begin
    {позиция новая}
    s:=sKOd+Shablon;

    sKol:=IntToStr(StrToInt(E.MarketElement[i].Input.Kol)*StrToInt(sLitr),CIZena);
    rFormat(sKOl,CIzena);
    System.Delete(s,posMrkOpt,CIZena);
    System.Insert(sKol,s,posMrkOpt);

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

  end; {if GetRazdelLitr(sKOd)}
 end;  {For i:=1 to E.Amount}

End;


procedure PrhOptAddToList(E: Prihodtype);
var i,j : word;
    find: boolean;
    SumKol:String[CIZena];
    sLitr,SumZena:String[CIZena];
    sKol: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    sKOd,sKOd1 : string[CArtikul];
    s: string;
Begin
 find:=false;

For i:=1 to E.Amount do
Begin
if GetRazdelLitr(copy(E.PrihodElement[i].bazkod,1,CRazdelKod))=1 then
begin
 find:=false;
 if not SelectClass then sKOd:=E.PrihodElement[i].bazkod
 else
 sKOd:=GetIdField(FClass,E.PrihodElement[i].BazKod);
 case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430: sKod:='420';
  440,450: sKOd:='450';
 end;
 rformatzerro(sKOd,CArtikul);
 sLitr:=GetIdField(FLitr,E.PrihodElement[i].bazkod);
 sLitr:=IntToStr(Round(StrToReal(sLitr)*1000),CIZena);
 If (TempBox^.List^.Count>0) and (TempBox^.List^.Count<10) Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
         s:=TempBox^.GetText(j,TempBox^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         if StrToInt(sKod1)=StrToInt(sKod) then
         begin
           {код есть в списке}

           sKol:=E.PrihodElement[i].Input.kol;

           SumKol:=IntToStr(StrToInt(E.PrihodElement[i].Input.kol)*StrToInt(sLitr)+
              StrToInt(copy(s,posPrhOpt,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,posPrhOpt,CIZena);
           System.Insert(SumKol,s,posPrhOpt);

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
           break;
         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end  {If TempBox^.List^.Count>0}
   else if BinSearch(TempBox,j,sKOd) then
   begin
           s:=TempBox^.GetText(j,TempBox^.List^.Count);
           sKol:=E.PrihodElement[i].Input.kol;

           SumKol:=IntToStr(StrToInt(E.PrihodElement[i].Input.kol)*StrToInt(sLitr)+
              StrToInt(copy(s,posPrhOpt,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,posPrhOpt,CIZena);
           System.Insert(SumKol,s,posPrhOpt);

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
   end;

   if not Find then
   begin
    {позиция новая}
    s:=sKOd+Shablon;

    sKol:=IntToStr(StrToInt(E.PrihodElement[i].Input.Kol)*StrToInt(sLitr),CIZena);
    rFormat(sKOl,CIzena);
    System.Delete(s,posPrhOpt,CIZena);
    System.Insert(sKol,s,posPrhOpt);

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

  end; {if GetRazdelLitr(sKOd)}
 end;  {For i:=1 to E.Amount}

End;




procedure OstNAddToList(E: NewItogType);

var i,j : word;
    find: boolean;
    SumKol:String[CIZena];
    sLitr,SumZena:String[CIZena];
    sKol: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    sKOd,sKOd1 : string[CArtikul];
    s: string;
Begin
if GetRazdelLitr(copy(E.bazkod,1,CRazdelKod))=1 then
begin
 find:=false;
 if not SelectClass then sKOd:=E.bazkod
 else
 sKOd:=GetIdField(FClass,E.BazKod);
 case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430: sKod:='420';
  440,450: sKOd:='450';
 end;
 rformatzerro(sKOd,CArtikul);
 sLitr:=GetIdField(FLitr,E.bazkod);
 sLitr:=IntToStr(Round(StrToReal(sLitr)*1000),CIZena);
 If (TempBox^.List^.Count>0) and (TempBox^.List^.Count<10) Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
         s:=TempBox^.GetText(j,TempBox^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         if StrToInt(sKod1)=StrToInt(sKod) then
         begin
           {код есть в списке}

           sKol:=E.Ost;

           SumKol:=IntToStr(StrToInt(E.Ost)*StrToInt(sLitr)+
              StrToInt(copy(s,posOstN,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,posOstN,CIZena);
           System.Insert(SumKol,s,posOstN);

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
           break;
         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end  {If TempBox^.List^.Count>0}
   else if BinSearch(TempBox,j,sKOd) then
     begin
       s:=TempBox^.GetText(j,TempBox^.List^.Count);
       sKol:=E.Ost;

       SumKol:=IntToStr(StrToInt(E.Ost)*StrToInt(sLitr)+
       StrToInt(copy(s,posOstN,CIzena)),CIZena);

       rformat(SumKol,CIZena);
       System.Delete(s,posOstN,CIZena);
       System.Insert(SumKol,s,posOstN);

       TempBox^.List^.AtFree(j);
       TempBox^.SetRange(TempBox^.List^.Count);

       TempBox^.List^.Insert(NewStr(s));
       TempBox^.SetRange(TempBox^.List^.Count);

       find:=true;
     end; {if BinSearch(}

   if not Find then
   begin
    {позиция новая}
    s:=sKOd+Shablon;

    sKol:=IntToStr(StrToInt(E.Ost)*StrToInt(sLitr),CIZena);
    rFormat(sKOl,CIzena);
    System.Delete(s,posOstN,CIZena);
    System.Insert(sKol,s,posOstN);

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

  end; {if GetRazdelLitr(sKOd)}

End;

procedure OstkAddToList(E: NewItogType);
var i,j : word;
    find: boolean;
    SumKol:String[CIZena];
    sLitr,SumZena:String[CIZena];
    sKol: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    sKOd,sKOd1 : string[CArtikul];
    s: string;
Begin
if GetRazdelLitr(copy(E.bazkod,1,CRazdelKod))=1 then
begin
 find:=false;
 if not SelectClass then sKOd:=E.bazkod
 else
 sKOd:=GetIdField(FClass,E.BazKod);
 case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430: sKod:='420';
  440,450: sKOd:='450';
 end;
 rformatzerro(sKOd,CArtikul);
 sLitr:=GetIdField(FLitr,E.bazkod);
 sLitr:=IntToStr(Round(StrToReal(sLitr)*1000),CIZena);
 If (TempBox^.List^.Count>0) and (TempBox^.List^.Count<10) Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
         s:=TempBox^.GetText(j,TempBox^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         if StrToInt(sKod1)=StrToInt(sKod) then
         begin
           {код есть в списке}

           sKol:=E.Ost;

           SumKol:=IntToStr(StrToInt(E.Ost)*StrToInt(sLitr)+
              StrToInt(copy(s,posOstK,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,posOstK,CIZena);
           System.Insert(SumKol,s,posOstK);

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
           break;
         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end  {If TempBox^.List^.Count>0}
   else  if BinSearch(TempBox,j,sKOd) then
     begin
       s:=TempBox^.GetText(j,TempBox^.List^.Count);
       sKol:=E.Ost;

       SumKol:=IntToStr(StrToInt(E.Ost)*StrToInt(sLitr)+
       StrToInt(copy(s,posOstK,CIzena)),CIZena);

       rformat(SumKol,CIZena);
       System.Delete(s,posOstK,CIZena);
       System.Insert(SumKol,s,posOstK);

       TempBox^.List^.AtFree(j);
       TempBox^.SetRange(TempBox^.List^.Count);

       TempBox^.List^.Insert(NewStr(s));
       TempBox^.SetRange(TempBox^.List^.Count);

       find:=true;
     end; {if BinSearch(}

   if not Find then
   begin
    {позиция новая}
    s:=sKOd+Shablon;

    sKol:=IntToStr(StrToInt(E.Ost)*StrToInt(sLitr),CIzena);
    rFormat(sKOl,CIzena);
    System.Delete(s,posOstN,CIZena);
    System.Insert(sKol,s,posOstN);

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

  end; {if GetRazdelLitr(sKOd)}

End;


procedure VzwAddToList(E: NewVozwratType);
var i,j : word;
    find: boolean;
    SumKol:String[CIZena];
    sLitr,SumZena:String[CIZena];
    sKol: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    sKOd,sKOd1 : string[CArtikul];
    s: string;
Begin
 find:=false;

For i:=1 to E.Amount do
Begin
find:=false;
if not SelectClass then sKOd:=E.VozwratElement[i].bazkod
else sKOd:=GetIdField(FClass,E.VozwratElement[i].bazkod);
 case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430: sKod:='420';
  440,450: sKOd:='450';
 end;
rformatzerro(sKOd,CArtikul);

if GetRazdelLitr(copy(E.VozwratElement[i].bazkod,1,CRazdelKod))=1 then
find:=false;
 if not SelectClass then sKOd:=E.VozwratElement[i].bazkod
 else
 sKOd:=GetIdField(FClass,E.VozwratElement[i].BazKod);
  case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430: sKod:='420';
  440,450: sKOd:='450';
 end;
 rformatzerro(sKOd,CArtikul);
 sLitr:=GetIdField(FLitr,E.VozwratElement[i].bazkod);
 sLitr:=IntToStr(Round(StrToReal(sLitr)*1000),CIZena);
begin
 If TempBox^.List^.Count>0 Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
         s:=TempBox^.GetText(j,TempBox^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         if StrToInt(sKod1)=StrToInt(sKod) then
         begin
           {код есть в списке}

           sKol:=E.VozwratElement[i].Input.kol;

           SumKol:=IntToStr(StrToInt(E.VozwratElement[i].Input.kol)*StrToInt(sLitr)+
              StrToInt(copy(s,posVozvPost,CIzena)),CIZena);

           rformat(SumKol,CIZena);
           System.Delete(s,posVozvPost,CIZena);
           System.Insert(SumKol,s,posVozvPost);

           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
           break;
         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end;  {If TempBox^.List^.Count>0}

   if not Find then
   begin
    {позиция новая}
    s:=sKOd+Shablon;

    sKol:=IntToStr(StrToInt(E.VozwratElement[i].Input.Kol)*StrToInt(sLitr),CIZena);
    rFormat(sKOl,CIzena);
    System.Delete(s,posVozvPost,CIZena);
    System.Insert(sKol,s,posVozvPost);

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

  end; {if GetRazdelLitr(sKOd)}
 end;  {For i:=1 to E.Amount}


End;


procedure RwzAddToList(E: RewisiaType);
{ревизии + в возврат нам}
var i,j : word;
    find: boolean;
    sLitr,SumKol:String[CIZena];
    SumZena:String[CIZena];
    sKol: String[CIZena];
    sClass: string[CClientKod];
    sRazd: string[CRazdelKOd];
    sKOd,sKOd1 : string[CArtikul];
    s: string;
Begin
 find:=false;

For i:=1 to E.Amount do
Begin
find:=false;
if not SelectClass then sKOd:=E.Element[i].bazkod
else sKOd:=GetIdField(FClass,E.Element[i].bazkod);
 case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430: sKod:='420';
  440,450: sKOd:='450';
 end;
rformatzerro(sKOd,CArtikul);
if GetRazdelLitr(copy(E.Element[i].bazkod,1,CRazdelKod))=1 then
begin
 find:=false;
 if not SelectClass then sKOd:=E.Element[i].bazkod
 else
 sKOd:=GetIdField(FClass,E.Element[i].BazKod);
  case StrToInt(sKOd) of
  0,1,200: sKOd:='200';
  420,430: sKod:='420';
  440,450: sKOd:='450';
 end;
 rformatzerro(sKOd,CArtikul);
 sLitr:=GetIdField(FLitr,E.Element[i].bazkod);
 sLitr:=IntToStr(Round(StrToReal(sLitr)*1000),CIZena);
 If TempBox^.List^.Count>0 Then
   begin
    for j:=0 to TempBox^.List^.Count-1 do
      begin
         s:=TempBox^.GetText(j,TempBox^.List^.Count);
         sKod1:=copy(s,1,CArtikul);
         if StrToInt(sKod1)=StrToInt(sKod) then
         begin
           {код есть в списке}

           sKol:=E.Element[i].Input.kol;

           if StrToInt(sKol)>=0 then
           begin
           SumKol:=IntToStr(StrToInt(E.Element[i].Input.kol)*StrToInt(sLitr)+
              StrToInt(copy(s,posVozvPost,CIzena)),CIZena);
              rformat(SumKol,CIZena);
              System.Delete(s,posVozvPost,CIZena);
              System.Insert(SumKol,s,posVozvPost);
           end
           else
           begin
           SumKol:=IntToStr(-StrToInt(E.Element[i].Input.kol)*StrToInt(sLitr)+
           StrToInt(copy(s,posRashXZ,CIzena)),CIZena);
           rformat(SumKol,CIZena);
           System.Delete(s,posRashXZ,CIZena);
           System.Insert(SumKol,s,posRashXZ);

           end;


           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);

           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);

           find:=true;
           break;
         end; {if StrToInt(sKod1)=StrToInt(sKod)}
      end; {for j:=0 to TempBox^.List^.Count-1}
   end;  {If TempBox^.List^.Count>0}

   if not Find then
   begin
    {позиция новая}
    s:=sKOd+Shablon;

    sKol:=IntToStr(StrToInt(E.Element[i].Input.Kol)*StrToInt(sLitr),CIZena);
    if StrToInt(sKol)<0 then
    begin
      sKol:=IntToStr(-StrToInt(sKOl),CIZena);
      rFormat(sKOl,CIzena);
      System.Delete(s,posRashXZ,CIZena);
      System.Insert(sKol,s,posRashXZ);
    end
    else
    begin
      rFormat(sKOl,CIzena);
      System.Delete(s,posVozvPost,CIZena);
      System.Insert(sKol,s,posVozvPost);
    end;

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   end;

  end; {if GetRazdelLitr(sKOd)}
 end;  {For i:=1 to E.Amount}


End;


function CalcDeclareOborot: boolean;

label l1,l2;

var AllSkl: Maska30;
    t,tt,ttt: text;
    IORez,cc, Count,i: word;
    Den, Start, Stop,OstNach: longint;
    Errors: PBox;
    tekSkl,ii: word;
    Date: TDateString;
    StartDate,StopDate,ostDate : TDateString;
    OldFileMode,c1 : Word;
    AllEnable: longint;
    pf: file;
    fm,fp:File;
    p: PBufPrihodType;
    m: PBufSuperMarketType;
    fv: file of NewVozwratType;
    v: PNewVozwratType;
    R: Trect;
    s: string;
    SklKod: string[CRazdelKod];
    BufItog: BufNewItogType;
    NItg: PNewItogType;
    findost: boolean;
    FR:RewisiaFileType;
    RW: PRewisiaType;
    sKOd: string[CArtikul];
    sAllPrh, sAll1Prh,sAllMrk, sAll1Mrk: string[CIZena];
    sLitr,sLitr1: string[CIZena];
    sCl: string[CClientKod];
    INN : String[CName];
    Event: TEvent;
    ws: string;
    ver: word;
    VidRep: word;
Begin
  CalcDeclareOborot:=false;

  {Выбор организации}
   vidrep:=SelectOrg;
   if vidrep=2 then exit;

   SelectClass:=true;




  {Выбор периода}
  If Not DatePeriodDialog(StartDate,StopDate,False) Then Exit;
  Start:=DateStringToDate(DateMask,StartDate);
  Stop:=DateStringToDate(DateMask,StopDate);
  {Выбор складов}
  AllEnable:=AllSKlads;
  If Not SelAssortiment(AllEnable) Then Exit;
  WordToBit30(AllEnable,AllSkl);
  Convert30(AllSkl);

  Assign(OborotFile,Path^.Dat.ToTemp+OborotFilePrefix+copy(REk^.Dat.INN,5,5)+copy(Fdate,Length(FDate),1)+'.001');
  IORez:=ioresult;
  Rewrite(OborotFile);
  IORez:=ioresult;
  If IOrez<>0 then
  begin
    MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+OborotFilePrefix+copy(REk^.Dat.INN,5,5)
    +copy(Fdate,Length(FDate),1)+'.001 !!!',Nil,mfError+mfCancelButton);
    exit;
  end;

  Assign(PostavkaFile,Path^.Dat.ToTemp+PostavkaFilePrefix+copy(REk^.Dat.INN,5,5)+copy(Fdate,Length(FDate),1)+'.001');
  IORez:=ioresult;
  Rewrite(PostavkaFile);
  IORez:=ioresult;
  If IOrez<>0 then
  begin
    MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+PostavkaFilePrefix+copy(REk^.Dat.INN,5,5)
    +copy(Fdate,Length(FDate),1)+'.001 !!!',Nil,mfError+mfCancelButton);
    Close(OborotFile);
    exit;
  end;

  Assign(ZakupkaFile,Path^.Dat.ToTemp+ZakupkaFilePrefix+copy(REk^.Dat.INN,5,5)+copy(Fdate,Length(FDate),1)+'.001');
  IORez:=ioresult;
  Rewrite(ZakupkaFile);
  IORez:=ioresult;
  If IOrez<>0 then
  begin
    MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.ToTemp+ZakupkaFilePrefix+copy(REk^.Dat.INN,5,5)
    +copy(Fdate,Length(FDate),1)+'.001 !!!',Nil,mfError+mfCancelButton);
    Close(OborotFile);
    Close(ZakupkaFile);
    exit;
  end;

  {Для отладки!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
(*Writeln(ZakupkaFile,'ИдФайл:7104024633**71040100120070403145502');
Writeln(ZakupkaFile,'ТипИнф:1152025');
Writeln(ZakupkaFile,'ВерсФорм:3.01');
Writeln(ZakupkaFile,'ИдПол:7100');
Writeln(ZakupkaFile,'ВерсПрог:1С:ПРЕДПРИЯТИЕ7.7 07Q1004 7.70.486');
Writeln(ZakupkaFile,'КолДок:1');
Writeln(ZakupkaFile,'НаимОтпрЮЛ:ООО ТОРГОВЫЙ ДОМ "ТРИАДА-СЕРВИС"');
Writeln(ZakupkaFile,'ТелОтпр:20-66-63,20-68-71');
Writeln(ZakupkaFile,'ДолжнОтпр:ГЛАВНЫЙ БУХГАЛТЕР');
Writeln(ZakupkaFile,'ФИООтпр:КУНАЕВА,ГАЛИНА,ЮРЬЕВНА');
Writeln(ZakupkaFile,'@@@');
Writeln(ZakupkaFile,'ИдДок:7104024633**710401001200720310101');
Writeln(ZakupkaFile,'ДатаДок:03.04.2007');
Writeln(ZakupkaFile,'###');
Writeln(ZakupkaFile,'НаимЮЛПол:ООО ТОРГОВЫЙ ДОМ "ТРИАДА-СЕРВИС"');
Writeln(ZakupkaFile,'ИННЮЛ:7104024633');
Writeln(ZakupkaFile,'КППЮЛ:710401001');
Writeln(ZakupkaFile,'ОГРН:1027100600273');
Writeln(ZakupkaFile,'ОКАТО:70401000000');
Writeln(ZakupkaFile,'АдрОрг:643,300026,71,,ТУЛА,,ЛЕНИНА ПР-Т,108,,');
Writeln(ZakupkaFile,'ТелОрг:20-66-63,20-68-71');
Writeln(ZakupkaFile,'###');
Writeln(ZakupkaFile,'ВидДеят:07');
Writeln(ZakupkaFile,'СерЛиц:Б 073699');
Writeln(ZakupkaFile,'НомерЛиц:0606/0127');
Writeln(ZakupkaFile,'ДатаНачЛиц:30.06.2006');
Writeln(ZakupkaFile,'ДатаОконЛиц:30.06.2011');
Writeln(ZakupkaFile,'###');
Writeln(ZakupkaFile,'ФИОРук:ОЛЕЙНИК,ВЛАДИМИР,АЛЕКСАНДРОВИЧ');
Writeln(ZakupkaFile,'ИННРук:710706874574');
Writeln(ZakupkaFile,'ФИОБух:КУНАЕВА,ГАЛИНА,ЮРЬЕВНА');
Writeln(ZakupkaFile,'ИННБух:710601303608');
Writeln(ZakupkaFile,'ФИОУпПред:,,');
Writeln(ZakupkaFile,'ИННУпПред:');
Writeln(ZakupkaFile,'###');
Writeln(ZakupkaFile,'ПризФОтч:4');
Writeln(ZakupkaFile,'НаимФОтч:ДЕКЛАРАЦИЯ ОБ ОБЪЕМАХ ЗАКУПКИ ЭТИЛОВОГО СПИРТА, АЛКОГОЛЬНОЙ И СПИРТОСОДЕРЖАЩЕЙ ПРОДУКЦИИ');
Writeln(ZakupkaFile,'ПериодВерОтч:27.09.2006,');
Writeln(ZakupkaFile,'ПризВидДок:1');
Writeln(ZakupkaFile,'ПризПериодОтч:3');
Writeln(ZakupkaFile,'ГодПериодОтч:2007');
Writeln(ZakupkaFile,'ДокПредст:210');
Writeln(ZakupkaFile,'ДокПредстРО:2');
Writeln(ZakupkaFile,'КолПокФОтч:280');
Writeln(ZakupkaFile,'###'); *)


  R.Assign(0, 0, 0, 0);
  ErrorBox := New(PBox, Init(R, 1, Nil));
  ErrorBox^.NewList(New(PMyCollection, Init(0,1)));

  R.Assign(0, 0, 0, 0);
  TempBox := New(PBox, Init(R, 1, Nil));
  TempBox^.NewList(New(PTextCollection, Init(0,1)));

  R.Assign(0, 0, 0, 0);
  PostavkaBox := New(PBox, Init(R, 1, Nil));
  PostavkaBox^.NewList(New(PTextCollection, Init(0,1)));

  R.Assign(0, 0, 0, 0);
  PostavkaBox1 := New(PBox, Init(R, 1, Nil));
  PostavkaBox1^.NewList(New(PTextCollection, Init(0,1)));

  R.Assign(0, 0, 0, 0);
  ZakupkaBox := New(PBox, Init(R, 1, Nil));
  ZakupkaBox^.NewList(New(PTextCollection, Init(0,1)));



  {memc('a5'+copy(REk^.Dat.INN,5,5)+copy(Fdate,Length(FDate),1));
  exit;}
{остаток на начало}
    {остатки на начало периода - в лист}
for TekSkl:=1 to CMaxSklads do
  begin
   if AllSkl[TekSkl]=1 then
   begin
   DelSpace(PathSklads^.Dat.Path[TekSkl]);

      OstNach:=Start-1;
l1:   ostDate:=DateToDateString(DateMask,OstNach);
      while pos('-',ostdate)>0 do delete(ostdate,pos('-',ostdate),1);
      if ostDate[1]='0' then delete(ostdate,1,1);
      Str(TekSkl:CRazdelKod,SklKOd);
      RformatZerro(SklKOd,CRAzdelKOd);
      if FExists (PathSklads^.Dat.Path[TekSkl]+'ARC\'+ostDate+'.p'+sklKod) then
      begin
        Assign(pf,PathSklads^.Dat.Path[TekSkl]+'ARC\'+ostDate+'.p'+sklKod);
        ioRez:=ioresult;
        Reset(pf,SizeOf(NewItogType));
        ioRez:=ioresult;
        findost:=true;
      end
      else
      begin
          dec(OstNach);
          if ostNach>Start-4 then goto l1
          else findost:=false;
      End;

if findost then
begin
New(NItg,Init);
      while not eof(pf) do
      begin
        Count:=0;
DInfoMsgShkala('Просматриваю остатки за '+DateToDateString(DateMask,OstNach)+' склада '
+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1),0,FileSize(pf),FilePos(pf));
        BlockRead(pf,BufItog.Dat,BufferNewItog,Count);
        For c1:=1 To Count Do
        Begin
          NItg^.Dat:=BufItog.Dat[c1];
         if Not(GetRazdelStatus(NItg^.Dat.BazKod)) then
         begin
           OstNAddToList(NItg^.Dat);
         end;
        end; {For c1:=1 To Count Do}
      end; {while not eof(pf)}
      close(pf);
Dispose(NItg,Done);
NoinfoMsg;
end {if findost then}
else
begin
   ErrorBox^.List^.Insert(NewStr(' Отсутствуют остатки склада '+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)+' за '
    +DateToDateString(DateMask,OstNach)
     + ' "'+DayString[DayOfWeek(OstNach)]+'" '));
   ErrorBox^.SetRange(ErrorBox^.List^.Count);
end;

 end;  {if AllSkl[TekSkl]=1}
end;  {for TekSkl:=1 to CMaxSklads}

{ПРИХОД}
 {от производителей}
 {от оптовиков}
 {по импорту}
 for TekSkl:=1 to CMaxSklads do
  begin
   if AllSkl[TekSkl]=1 then
   {по датам}
   for Den:=Start to stop do
   begin
     Date:=DateToDateString(DateMask,DEn);
     DelSpace(PathSklads^.Dat.Path[TekSkl]);
     DInfoMsgShkala('Просматриваю приходы склада '+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)+'...',Start,Stop,Den);
     if PathSklads^.Dat.Path[TekSkl]<>'' then
     begin
      Assign(FP,PathSklads^.Dat.Path[TekSkl]+'PRIHOD\'+Date+'.prh');
      OldFileMode:=FileMode;
      FileMode:=ReadOnlyN;
      IORez:=IOResult;
      Reset(fp,SizeOf(PrihodType));
      IORez:=IOResult;
      FileMode:=OldFileMode;
      If IORez <> 0 Then
      Begin
       {MessageBox(#3^M+#3'Не могу ... файл '+PathSklads^.Dat.Path[TekSkl]+Date+'.prh',Nil,mfError+mfCancelButton);}
       continue;
      End;

       While Not(Eof(fp)) Do
       Begin
       cc:=0;
       New(p,Init);
       ReadBufPrihod(fp,p,Count);
       For cc:=1 To Count Do
        Begin
         If p^.Point.Dat[cc].OperatorSelector in [0,2] Then
         BEGIN
           {филтр опт - розница}
            PrhOptAddToList(p^.Point.Dat[cc]);
            PrhDeclare(p^.Point.Dat[cc]);
         END; {}
        End; {For cc:=1 To}
        Dispose(p,Done);
       End;{While Not(Eof(ef)) Do}
     IORez:=ioresult;
     close(fp);
     IORez:=ioresult;
     end;{if PathSklads^.Dat.Path[TekSkl]<>''}
   end;{по датам}
     NoInfoMsg;
  end;{по складам}


 {возврат от поставщиков - не показывать ГЮ 21.02.06
  на самом деле оказался возврат нам :-) ГЮ 08.02.07
  меняем колонки (ниже)}
 {розницу- в прочий расход ГЮ 17.03.06}
  {на самом деле в орг розн. торговли :-) ГЮ 08.02.07}
{РАСХОД}
 {оптовикам}
 {орг розн. торговли}
 {на экспорт}
  {по складам}
  for TekSkl:=1 to CMaxSklads do
  begin
   if AllSkl[TekSkl]=1 then
   {по датам}
   for Den:=Start to stop do
   begin
     Date:=DateToDateString(DateMask,DEn);
     DelSpace(PathSklads^.Dat.Path[TekSkl]);
     DInfoMsgShkala('Просматриваю продажи склада '+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)+'...',Start,Stop,Den);
     if PathSklads^.Dat.Path[TekSkl]<>'' then
     begin
      Assign(FM,PathSklads^.Dat.Path[TekSkl]+'MARKET\'+Date+'.mrk');
      OldFileMode:=FileMode;
      FileMode:=ReadOnlyN;
      IORez:=IOResult;
      Reset(fm,SizeOf(SuperMarketType));
      IORez:=IOResult;
      FileMode:=OldFileMode;
      If IORez <> 0 Then
      Begin
       {MessageBox(#3^M+#3'Не могу ... файл '+PathSklads^.Dat.Path[TekSkl]+Date+'.mrk',Nil,mfError+mfCancelButton);}
      ErrorBox^.List^.Insert(NewStr(' Отсутствуют продажи склада '+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)+' за '
         +DateToDateString(DateMask,Den)
         + ' "'+DayString[DayOfWeek(Den)]+'" '));
         ErrorBox^.SetRange(ErrorBox^.List^.Count);
       continue;
      End;

       While Not(Eof(fm)) Do
       Begin
       cc:=0;
       New(m,Init);
       ReadBufMarket(fm,m,Count);
       For cc:=1 To Count Do
        Begin
         If m^.Point.Dat[cc].Active Then
         If m^.Point.Dat[cc].OperatorSelector in [0,2] Then
         If ((m^.Point.Dat[cc].Realiz) And (m^.Point.Dat[cc].DocSelector in [5,6,7,8])) or Not(m^.Point.Dat[cc].Realiz) Then

         BEGIN
           {филтр опт - розница!!!!!!!!!!!!!}
           { }
           if m^.Point.Dat[cc].DocSelector in [3,4,6,8] then
           begin
            {со СФ}
            IF (StrToInt(m^.Point.Dat[cc].ClientKod)=656)
               or (StrToInt(m^.Point.Dat[cc].ClientKod)=658) then
             MrkOptAddToList(m^.Point.Dat[cc])
            else
             MrkAddToList(m^.Point.Dat[cc]);

             MrkDeclarePostavka(m^.Point.Dat[cc]);
           end
           else
           begin
             {без СФ}
             MrkAddToList(m^.Point.Dat[cc]);  {ГЮ 08.02.07}

           end;


         END; {If m^.Point.Dat[cc].Active}
         {Р/П}
         If m^.Point.Dat[cc].Active then
        If (m^.Point.Dat[cc].ClientKod=ClientRP) And Not(m^.Point.Dat[cc].Realiz) And (m^.Point.Dat[cc].OperatorSelector=1)Then
             MrkXZAddToList(m^.Point.Dat[cc]);
        End; {For cc:=1 To}
        Dispose(m,Done);
       End;{While Not(Eof(ef)) Do}
     IORez:=ioresult;
     close(fm);
     IORez:=ioresult;
     end;{if PathSklads^.Dat.Path[TekSkl]<>''}
   end;{по датам}
     NoInfoMsg;
  end;{по складам}

 {возврат нам от клиентов}
  for TekSkl:=1 to CMaxSklads do
  begin
   if AllSkl[TekSkl]=1 then
   {по датам}
   for Den:=Start to stop do
   begin
     Date:=DateToDateString(DateMask,DEn);
     DelSpace(PathSklads^.Dat.Path[TekSkl]);
   DInfoMsgShkala('Просматриваю возвраты склада '+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)+'...',Start,Stop,Den);
     if PathSklads^.Dat.Path[TekSkl]<>'' then
     begin
      Assign(FV,PathSklads^.Dat.Path[TekSkl]+'RETURN\'+Date+'.vzw');
      OldFileMode:=FileMode;
      FileMode:=ReadOnlyN;
      IORez:=IOResult;
      Reset(fV);
      IORez:=IOResult;
      FileMode:=OldFileMode;
      If IORez <> 0 Then
      Begin
       {MessageBox(#3^M+#3'Не могу ... файл '+PathSklads^.Dat.Path[TekSkl]+Date+'.mrk',Nil,mfError+mfCancelButton);}

       continue;
      End;

       While Not(Eof(fv)) Do
       Begin
       cc:=0;
       New(v,Init);
       Read(fv,v^.Dat);

         If v^.Dat.OperatorSelector in [0,2] Then
         {if v^.Dat.DocSelector in [3,4,6,8] then}  {остальные куда?}
         BEGIN
           {фильтр опт - розница}
           VzwAddToList(v^.Dat);
         END; {}

        Dispose(v,Done);
       End;{While Not(Eof(ef)) Do}
     IORez:=ioresult;
     close(fv);
     IORez:=ioresult;
     end;{if PathSklads^.Dat.Path[TekSkl]<>''}
   end;{по датам}
     NoInfoMsg;
  end;{по складам}

  for TekSkl:=1 to CMaxSklads do
  begin
   if AllSkl[TekSkl]=1 then
   {по датам}
   for Den:=Start to stop do
   begin
     Date:=DateToDateString(DateMask,DEn);
     DelSpace(PathSklads^.Dat.Path[TekSkl]);
   DInfoMsgShkala('Просматриваю ревизии склада '+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)+'...',Start,Stop,Den);
     if PathSklads^.Dat.Path[TekSkl]<>'' then
     begin
      Assign(FR,PathSklads^.Dat.Path[TekSkl]+'REVISIA\'+Date+'.rwz');
      OldFileMode:=FileMode;
      FileMode:=ReadOnlyN;
      IORez:=IOResult;
      Reset(FR);
      IORez:=IOResult;
      FileMode:=OldFileMode;
      If IORez <> 0 Then
      Begin
       {MessageBox(#3^M+#3'Не могу ... файл '+PathSklads^.Dat.Path[TekSkl]+Date+'.mrk',Nil,mfError+mfCancelButton);}
       NoInfoMsg;
       continue;
      End;

       While Not(Eof(fr)) Do
       Begin
       cc:=0;
       New(rw,Init);
       Read(fr,rw^.Dat);

         BEGIN
           {ревизии - в прочий расход }
           RwzAddToList(rw^.Dat);
         END; {}

        Dispose(rw,Done);
       End;{While Not(Eof(ef)) Do}
     IORez:=ioresult;
     close(fr);
     IORez:=ioresult;
     end;{if PathSklads^.Dat.Path[TekSkl]<>''}
   end;{по датам}
     NoInfoMsg;
  end;{по складам}

{остаток на конец}
for TekSkl:=1 to CMaxSklads do
  begin
   if AllSkl[TekSkl]=1 then
   begin
   DelSpace(PathSklads^.Dat.Path[TekSkl]);

      OstNach:=Stop;
l2:   ostDate:=DateToDateString(DateMask,OstNach);
      while pos('-',ostdate)>0 do delete(ostdate,pos('-',ostdate),1);
      if ostDate[1]='0' then delete(ostdate,1,1);
      Str(TekSkl:CRazdelKod,SklKOd);
      RformatZerro(SklKOd,CRAzdelKOd);
      if FExists (PathSklads^.Dat.Path[TekSkl]+'ARC\'+ostDate+'.p'+sklKod) then
      begin
        Assign(pf,PathSklads^.Dat.Path[TekSkl]+'ARC\'+ostDate+'.p'+sklKod);
        ioRez:=ioresult;
        Reset(pf,SizeOf(NewItogType));
        ioRez:=ioresult;
        findost:=true;
      end
      else
      begin
   ErrorBox^.List^.Insert(NewStr(' Отсутствуют остатки склада '+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)+' за '
    +DateToDateString(DateMask,OstNach)
     + ' "'+DayString[DayOfWeek(OstNach)]+'" '));
   ErrorBox^.SetRange(ErrorBox^.List^.Count);
        {  dec(OstNach);
          if ostNach>Stop-2 then goto l2}
          {else} findost:=false;
      End;

if findost then
begin
New(NItg,Init);
      while not eof(pf) do
      begin
        Count:=0;
DInfoMsgShkala('Просматриваю остатки за '+DateToDateString(DateMask,OstNach)+' склада '
+GetClientField(FClient,IntToStr(TekSkl,CClientKod),1),0,FileSize(pf),FilePos(pf));
        BlockRead(pf,BufItog.Dat,BufferNewItog,Count);
        For c1:=1 To Count Do
        Begin
          NItg^.Dat:=BufItog.Dat[c1];
         if Not(GetRazdelStatus(NItg^.Dat.BazKod)) then
         begin
           OstKAddToList(NItg^.Dat);
         end;
        end; {For c1:=1 To Count Do}
      end; {while not eof(pf)}
      close(pf);
Dispose(NItg,Done);
NoinfoMsg;
end; {if findost then}

 end;  {if AllSkl[TekSkl]=1}
end;  {for TekSkl:=1 to CMaxSklads}

  {Обработка результатов}
  {Декларация об оборотах}
  Assign(t,Path^.Dat.ToTemp+'litrdecl.csv');
  Iorez:=ioresult;
  Rewrite(t);
  Iorez:=ioresult;
  if IORez<>0 then
  begin
  end;



  Writeln(t,DosToWin(';ДЕКЛАРАЦИЯ ОБ ОБЪЕМАХ ОБОРОТА ЭТИЛОВОГО СПИРТА, АЛКОГОЛЬНОЙ И СПИРТОСОДЕРЖАЩЕЙ ПРОДУКЦИИ с '+StartDate
     +' по '+StopDate));
  Writeln(t);
  Writeln(t,dOStOwIN('Выбраны следующие склады:'));
  for TekSkl:=1 to CMaxSklads do
  if AllSkl[TekSkl]=1 then
  writeln(t,DosToWin(GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)));
  Writeln(t);

  Writeln(t,DosToWin('N п/п;Наименование продукции;Код вида продукции;Остаток на начало отчетного периода;Поступление;;;;;;'
  +'Расход;;;;;;;Остаток на конец отчетного периода;'));
  Writeln(t,DosToWin( ';;;;Всего;Закупки;;;;Возврат продукции;Всего;Поставки;;;;Возврат поставщикам;Прочий расход'));
  Writeln(t,DosToWin(';;;;;Всего;В том числе;;;;;Всего;В том числе;'));
  Writeln(t,DosToWin(';;;;;;От организаций поизводителей;от организаций оптовой торговли;по импорту;;;;'+
  'организациям оптовой торговли;организациям розничной торговли;на экспорт;'));


  if TempBox^.List^.Count>0 then
  for i:=0 to TempBox^.List^.Count-1 do
  begin
   DInfoMsgShkala('Формирую декларацию об объемах оборота ...',0,TempBox^.List^.Count,i);
   s:= TempBox^.GetText(i,TempBox^.List^.Count);
   sKod:=copy(s,1,CArtikul);
   {всего закупки: произв+опт+импорт}
   sAll1Prh:=IntToStr(StrToInt(copy(s,posPrhProizv,CIzena))+StrToInt(copy(s,posPrhOpt,CIzena))
      +StrToInt(copy(s,posPrhImp,CIzena)),CIZena);
   {Всего поступление: закупки + возврат}
   sAllPrh:=IntToStr(StrToInt(sAll1Prh)+StrToInt(copy(s,posVozvPost,CIzena)),CIZena);

   {всего поставки: произв+опт+импорт}
    sAll1Mrk:=IntToStr(StrToInt(copy(s,posMrkOpt,CIzena))+StrToInt(copy(s,posMrkRozn,CIzena))
      +StrToInt(copy(s,posMrkEksp,CIzena)),CIZena);
   {Всего расход: поставки + возврат плюс прочий расход}
    sAllMrk:=IntToStr(StrToInt(sAll1Mrk)+StrToInt(copy(s,posVozvCl,CIzena))
    +StrToInt(copy(s,posRashXZ,CIzena)),CIZena);

    {перевод в тыс. дал}

    MyStr(StrToReal(sAllMrk)/Dall,CIZena,8,sAllMrk);
    MyStr(StrToReal(sAll1Mrk)/Dall,CIZena,8,sAll1Mrk);
    MyStr(StrToReal(sAll1Prh)/Dall,CIZena,8,sAll1Prh);
    MyStr(StrToReal(sAllPrh)/Dall,CIZena,8,sAllPrh);

    sLitr1:=copy(s,posOstN,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posOstN,CIZena);
    System.Insert(sLitr1,s,posOstN);

    sLitr1:=copy(s,posPrhProizv,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posPrhProizv,CIZena);
    System.Insert(sLitr1,s,posPrhProizv);

    sLitr1:=copy(s,posPrhOpt,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posPrhOpt,CIZena);
    System.Insert(sLitr1,s,posPrhOpt);

    sLitr1:=copy(s,posPrhImp,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posPrhImp,CIZena);
    System.Insert(sLitr1,s,posPrhImp);

    sLitr1:=copy(s,posVozvPost,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posVozvPost,CIZena);
    System.Insert(sLitr1,s,posVozvPost);

    sLitr1:=copy(s,posMrkOpt,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posMrkOpt,CIZena);
    System.Insert(sLitr1,s,posMrkOpt);

    sLitr1:=copy(s,posMrkRozn,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posMrkRozn,CIZena);
    System.Insert(sLitr1,s,posMrkRozn);

    sLitr1:=copy(s,posMrkEksp,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posMrkEksp,CIZena);
    System.Insert(sLitr1,s,posMrkEksp);

    sLitr1:=copy(s,posVozvCl,CIZena);
    MyStr(StrToReal(sLitr1)/Dall,CIZena,8,sLitr1);
    System.Delete(s,posVozvCl,CIZena);
    System.Insert(sLitr1,s,posVozvCl);

    sLitr1:=copy(s,posRashXZ,CIZena);
    MyStr(StrToReal(sLitr1)/10000000,CIZena,8,sLitr1);
    System.Delete(s,posRashXZ,CIZena);
    System.Insert(sLitr1,s,posRashXZ);

    sLitr1:=copy(s,posOstK,CIZena);
    MyStr(StrToReal(sLitr1)/10000000,CIZena,8,sLitr1);
    System.Delete(s,posOstK,CIZena);
    System.Insert(sLitr1,s,posOstK);


    System.Insert(sAll1Mrk+';',s,posMrkOpt);
    System.Insert(sAllMrk+';',s,posMrkOpt);
    System.Insert(sAll1Prh+';',s,posPrhProizv);
    System.Insert(sAllPrh+';',s,posPrhProizv);


   while Pos('│', S) > 0 do   S[Pos('│', S)] := ';';

   write(t,DosToWin(IntToStr(i+1,CArtikul)+';'));
   if not SelectClass then write(t,DosToWin(GetIdField(FName,sKOd)+' '+GetIdField(FName2,sKOd)+';'))
   else write(t,DosToWin(GetClassField(FName,sKOd)+';'));
   {Наименование продукции}
   if not SelectClass then writeln(OborotFile,DeclDat[2]+GetIdField(FName,sKOd)+' '+GetIdField(FName2,sKOd))
   else writeln(OborotFile,FormName(sKOd));
   writeln(t,DosToWin(s));
   {Код продукции и прочая херь}
   for ii:=3 to 18 do
   begin
     ws:=copy(s,1,pos(';',s)-1);
     System.Delete(s,1,pos(';',s));
     if ii=3 then ws:=copy(ws,3,3)
     else MyStr(StrToReal(ws),15,4,ws);
     DelSpace(ws);
     writeln(OborotFile,DeclDat[ii]+ws);
   end;
   writeln(OborotFile,'###');
  end;

  if ErrorBox^.List^.Count>0 then
  begin
    writeln(t);
    writeln(t,DosToWin(';ВНИМАНИЕ!'));
    for i:=0 to ErrorBox^.List^.Count-1 do
      begin
        s:=ErrorBox^.GetTExt(i,ErrorBox^.List^.Count);
        writeln(t,';'+DosToWin(s));
      end;
  end;

  NoinfoMsg;
  System.close(t);

  {Декларация о поставках}
  Assign(tt,Path^.Dat.ToTemp+'litrmrk.csv');
  Iorez:=ioresult;
  Rewrite(tt);
  Iorez:=ioresult;
  if IORez<>0 then
  begin
  end;

  Writeln(tt,DosToWin(';ДЕКЛАРАЦИЯ ОБ ОБЪЕМАХ ПОСТАВКИ ЭТИЛОВОГО СПИРТА, АЛКОГОЛЬНОЙ И СПИРТОСОДЕРЖАЩЕЙ ПРОДУКЦИИ'));
  Writeln(tt);
  Writeln(tt,dOStOwIN('Выбраны следующие склады:'));
  for TekSkl:=1 to CMaxSklads do
  if AllSkl[TekSkl]=1 then
  writeln(tt,DosToWin(GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)));
  Writeln(tt);

  Writeln(tt,DosToWin('N п/п;Наименование продукции;Код вида продукции;Получатель;;;;;;;Номер, дата уведомления;'
  +'Дата отгрузки;Номер товарно-транспортного средства;Номер грузовой таможенной декларации;Дата пересечения границы;'
  +'Объем поставленной продукции'));
  Writeln(tt,DosToWin(';;;наименование;код субъекта РФ;ИНН;КПП;адрес;лицензия;;'));
  Writeln(tt,DosToWin(';;;;;;;;серия, номер, дата получения;кем выдана;'));
  if PostavkaBox^.List^.Count>0 then
  for i:=0 to PostavkaBox^.List^.Count-1 do
  begin
     DInfoMsgShkala('Формирую декларацию поставках ...',0,PostavkaBox^.List^.Count,i);

   s:= PostavkaBox^.GetText(i,PostavkaBox^.List^.Count);
   sKod:=copy(s,1,CArtikul);
   while Pos('│', S) > 0 do   S[Pos('│', S)] := ';';

   writeln(PostavkaFile,DeclDat[1]+IntToStr(i+1,CArtikul));

   write(tt,DosToWin(IntToStr(i+1,CArtikul)+';'));
   {Наименование продукции}
   if not SelectClass then writeln(PostavkaFile,DeclDat[2]+GetIdField(FName,sKOd)+' '+GetIdField(FName2,sKOd))
   else writeln(PostavkaFile,FormName(sKOd));
   if not SelectClass then write(tt,DosToWin(GetIdField(FName,sKOd)+' '+GetIdField(FName2,sKOd)+';'))
   else write(tt,DosToWin(GetClassField(FName,sKOd)+';'));
   {Код вида продукции}
   Write(tt,copy(s,1,CArtikul)+';');
   writeln(PostavkaFile,DeclDat[3]+copy(s,3,3));
   {Наименование клиента}
   sCl:=copy(s,posClientD,CClientKod);
   Write(tt,DosToWin(GetClientField(FFullClient,sCl,0))+';');
   INN:=GetClientField(FINN,sCl,0);
   writeln(PostavkaFile,DeclDat[4]+GetClientField(FFullClient,sCl,0));
   {код субъекта РФ}
   Write(tt,copy(INN,1,CRazdelKod)+';');
   writeln(PostavkaFile,DeclDat[5]+copy(INN,1,CRazdelKod));
   {ИНН}
   Write(tt,DosToWin('_'+INN+';'));
   writeln(PostavkaFile,DeclDat[6]+INN);
   {КПП}
   Write(tt,DosToWin('_'+GetClientField(FKPP,sCl,0))+';');
   writeln(PostavkaFile,DeclDat[7]+GetClientField(FKPP,sCl,0));
   {адрес}
   ws:=GetClientField(fAdress,sCl,0);
   Write(tt,DosToWin(ws)+';');
   FormClientAdres(ws,INN);
   writeln(PostavkaFile,DeclDat[8]+FormClientAdres(ws,INN));
   {лицензия}
   ws:=GetClientField(fEnvir,sCl,0);
   Write(tt,DosToWin(ws)+';');
   writeln(PostavkaFile,DeclDat[9]+FormLicName(ws)+',');

   Write(tt,DosToWin(GetClientField(fKto,sCl,0))+';');
   writeln(PostavkaFile,DeclDat[10]+GetClientField(fKto,sCl,0));
   {номер дата уведомления}
   Write(tt,';');
   writeln(PostavkaFile,DeclDat[11]);
   {Дата отгрузки}
   Write(tt,copy(s,posDateD,CDate)+';');
   writeln(PostavkaFile,DeclDat[12]+FormDate(copy(s,posDateD,CDate)));
   {N TTH пока тока в файле выгрузки}
   writeln(PostavkaFile,DeclDat[13]+copy(s,PosNumDMrk,CDate));
   {Номер трансп. ср-ва - в законодат-ве}
   Write(tt,';');

   {Номер ГТД}
   Write(tt,';');
   writeln(PostavkaFile,DeclDat[14]);
   {Дата пересечения границы}
   Write(tt,';');
   writeln(PostavkaFile,DeclDat[15]);
   {объем поставленной продукции}
   sLitr:= copy(s,posKolD,CIzena);
   MyStr(StrToReal(sLitr)/10000000,CIZena,8,sLitr);
   Writeln(tt,DosToWin(sLitr));
   {приводим к 15,4 а это тыс далл - бред!}
   myStr(StrToReal(sLitr),15,4,sLitr);
   delspace(sLitr);
   writeln(PostavkaFile,DeclDat[16]+sLitr);
   {конец записи}
   writeln(PostavkaFile,'###');
  end;


  if PostavkaBox1^.List^.Count>0 then
  for i:=0 to PostavkaBox1^.List^.Count-1 do
  begin
     DInfoMsgShkala('Формирую декларацию поставках ...',0,PostavkaBox1^.List^.Count,i);

   s:=PostavkaBox1^.GetText(i,PostavkaBox1^.List^.Count);
   sKod:=copy(s,1,CArtikul);
   while Pos('│', S) > 0 do   S[Pos('│', S)] := ';';
   write(tt,DosToWin(IntToStr(i+1,CArtikul)+';'));
   writeln(PostavkaFile,DeclDat[1]+IntToStr(i+1,CArtikul));
   {Наименование продукции}
   if not SelectClass then write(tt,DosToWin(GetIdField(FName,sKOd)+' '+GetIdField(FName2,sKOd)+';'))
   else write(tt,DosToWin(GetClassField(FName,sKOd)+';'));
   if not SelectClass then writeln(PostavkaFile,DeclDat[2]+GetIdField(FName,sKOd)+' '+GetIdField(FName2,sKOd))
   else writeln(PostavkaFile,FormName(sKOd));
   {Код вида продукции}
   Write(tt,copy(s,1,CArtikul)+';');
   writeln(PostavkaFile,DeclDat[3]+copy(s,3,3));
   {Наименование клиента}
   sCl:=copy(s,posClientD,CClientKod);
   Write(tt,DosToWin(GetClientField(FFullClient,sCl,0))+';');
   INN:=GetClientField(FINN,sCl,0);
   writeln(PostavkaFile,DeclDat[4]+GetClientField(FFullClient,sCl,0));
   {код субъекта РФ}
   Write(tt,copy(INN,1,CRazdelKod)+';');
   writeln(PostavkaFile,DeclDat[5]+copy(INN,1,CRazdelKod));
   {ИНН}
   Write(tt,DosToWin('_'+INN+';'));
   writeln(PostavkaFile,DeclDat[6]+INN);
   {КПП}
   Write(tt,DosToWin('_'+GetClientField(FKPP,sCl,0))+';');
   writeln(PostavkaFile,DeclDat[7]+GetClientField(FKPP,sCl,0));
   {адрес}
   ws:=GetClientField(fAdress,sCl,0);
   Write(tt,DosToWin(ws)+';');
   FormClientAdres(ws,INN);
   writeln(PostavkaFile,DeclDat[8]+FormClientAdres(ws,INN));
   {лицензия}
   ws:=GetClientField(fEnvir,sCl,0);
   Write(tt,DosToWin(ws)+';');
   writeln(PostavkaFile,DeclDat[9]+FormLicName(ws)+',');
   Write(tt,DosToWin(GetClientField(fKto,sCl,0))+';');
   writeln(PostavkaFile,DeclDat[10]+GetClientField(fKto,sCl,0));
   {номер дата уведомления}
   Write(tt,';');
   writeln(PostavkaFile,DeclDat[11]);
   {Дата отгрузки}
   Write(tt,copy(s,posDateD,CDate)+';');
   writeln(PostavkaFile,DeclDat[12]+FormDate(copy(s,posDateD,CDate)));
   {N TTH пока тока в файле выгрузки}
   writeln(PostavkaFile,DeclDat[13]+copy(s,PosNumDMrk,CDate));
   {Номер трансп. ср-ва}
   Write(tt,';');
   {Номер ГТД}
   Write(tt,';');
   writeln(PostavkaFile,DeclDat[14]);
   {Дата пересечения границы}
   Write(tt,';');
   writeln(PostavkaFile,DeclDat[15]);
   {объем поставленной продукции}
   sLitr:= copy(s,posKolD,CIzena);
   MyStr(StrToReal(sLitr)/10000000,CIZena,8,sLitr);
   Writeln(tt,DosToWin(sLitr));
   {приводим к 15,4 а это тыс далл - бред!}
   myStr(StrToReal(sLitr),15,4,sLitr);
   delspace(sLitr);
   writeln(PostavkaFile,DeclDat[16]+sLitr);
   {конец записи}
   writeln(PostavkaFile,'###');
  end;

  NoInfoMsg;
  System.close(tt);

  {Декларация о закупках}
  Assign(ttt,Path^.Dat.ToTemp+'litrprh.csv');
  Iorez:=ioresult;
  Rewrite(ttt);
  Iorez:=ioresult;

(*  Writeln(ttt,DosToWin(';ДЕКЛАРАЦИЯ ОБ ОБЪЕМАХ ЗАКУПКИ ЭТИЛОВОГО СПИРТА, АЛКОГОЛЬНОЙ И СПИРТОСОДЕРЖАЩЕЙ ПРОДУКЦИИ'));
  Writeln(ttt);
  Writeln(ttt,dOStOwIN('Выбраны следующие склады:'));
  for TekSkl:=1 to CMaxSklads do
  if AllSkl[TekSkl]=1 then
  writeln(ttt,DosToWin(GetClientField(FClient,IntToStr(TekSkl,CClientKod),1)));
  Writeln(ttt);

  Writeln(ttt,DosToWin('N п/п;Наименование продукции;Код вида продукции;Получатель;;;;;;;Номер, дата уведомления;'
  +'Дата отгрузки;Номер товарно-транспортной накладной;Номер грузовой таможенной декларации;Дата пересечения границы;'
  +'Объем полученной продукции'));
  Writeln(ttt,DosToWin(';;;наименование;код субъекта РФ;ИНН;КПП;адрес;лицензия;;'));
  Writeln(ttt,DosToWin(';;;;;;;;серия, номер, дата получения;кем выдана;'));*)

  if ZakupkaBox^.List^.Count>0 then
  for i:=0 to ZakupkaBox^.List^.Count-1 do
  begin
   IORez:=ioresult;
   if IOrez<>0 then memc(IntToStr(IORez,6));
   DInfoMsgShkala('Формирую декларацию закупках ...',0,ZakupkaBox^.List^.Count,i);
   writeln(ZakupkaFile,DeclDat[1]+IntToStr(i+1,CArtikul));
   s:= ZakupkaBox^.GetText(i,ZakupkaBox^.List^.Count);
   sKod:=copy(s,1,CArtikul);
   while Pos('│', S) > 0 do   S[Pos('│', S)] := ';';
   write(ttt,DosToWin(IntToStr(i+1,CArtikul)+';'));
   {Наименование продукции}
   if not SelectClass then write(ttt,DosToWin(GetIdField(FName,sKOd)+' '+GetIdField(FName2,sKOd)+';'))
   else write(ttt,DosToWin(GetClassField(FName,sKOd)+';'));
   if not SelectClass then writeln(ZakupkaFile,DeclDat[2]+GetIdField(FName,sKOd)+' '+GetIdField(FName2,sKOd))
   else writeln(ZakupkaFile,FormName(sKOd));
   IORez:=ioresult;
   if IOrez<>0 then memc(IntToStr(IORez,6));
   {Код вида продукции}
   Write(ttt,copy(s,1,CArtikul)+';');
   writeln(ZakupkaFile,DeclDat[3]+copy(s,3,3));
   {Наименование клиента}
   sCl:=copy(s,posClientD,CClientKod);
   ws:=GetMakeField(FFullClient,sCl,0);
   while pos('"',ws)>0 do ws[pos('"',ws)]:=' ';
   Write(ttt,DosToWin(ws)+';');
   INN:=GetMakeField(FINN,sCl,0);

   writeln(ZakupkaFile,DeclDat[4]+GetMakeField(FFullClient,sCl,0));
   {код субъекта РФ}
   Write(ttt,copy(INN,1,CRazdelKod)+';');
   writeln(ZakupkaFile,DeclDat[5]+copy(INN,1,CRazdelKod));
   {ИНН}
   Write(ttt,DosToWin({'_'+}INN+';'));
   writeln(ZakupkaFile,DeclDat[6]+INN);
   {КПП}
   Write(ttt,DosToWin({'_'}+GetMakeField(FKPP,sCl,0))+';');
   writeln(ZakupkaFile,DeclDat[7]+GetMakeField(FKPP,sCl,0));
   {адрес}
   ws:=GetMakeField(fAdress,sCl,0);
   Write(ttt,DosToWin(ws)+';');
   FormClientAdres(ws,INN);
   writeln(ZakupkaFile,DeclDat[8]+FormClientAdres(ws,INN));
   {лицензия}
   ws:=GetMakeField(fEnvir,sCl,0);
   Write(ttt,DosToWin(ws)+' '+GetMakeField(fSrok,sCl,0)+';');
   write(ZakupkaFile,DeclDat[9]+FormLicName(ws)+',');
   ws:=GetMakeField(fSrok,sCl,0);
   writeln(ZakupkaFile,FormDate(ws));
   Write(ttt,DosToWin(GetMakeField(fKto,sCl,0))+';');
   ws:=GetMakeField(fKto,sCl,0);
   {ClearChar(ws);}
   writeln(ZakupkaFile,DeclDat[10]+ws);
   {номер дата уведомления}
   Write(ttt,';');
   writeln(ZakupkaFile,DeclDat[11]);
   {Дата отгрузки}
   Write(ttt,copy(s,posDateD,CDate)+';');
   writeln(ZakupkaFile,DeclDat[12]+FormDate(copy(s,posDateD,CDate)));
   {Номер товарно-транспортной накладной}
   ws:=copy(s,PosNumerD,CDate);
   DelSpace(ws);
   Write(ttt,DosToWin({'_'+}copy(s,PosNumerD,CName))+';');
   writeln(ZakupkaFile,DeclDat[13]+ws);
   {Номер ГТД}
   Write(ttt,';');
   writeln(ZakupkaFile,DeclDat[14]);
   {Дата пересечения границы}
   Write(ttt,';');
   writeln(ZakupkaFile,DeclDat[15]);
   {объем поставленной продукции}
   sLitr:= copy(s,posKolDZak,CIzena);
   MyStr(StrToReal(sLitr)/10000000,CIZena,8,sLitr);
   Writeln(ttt,DosToWin(sLitr));
   {приводим к 15,4 а это тыс далл - бред!}
   myStr(StrToReal(sLitr),15,4,sLitr);
   delspace(sLitr);
   writeln(ZakupkaFile,DeclDat[16]+sLitr);
   {конец записи}
   writeln(ZakupkaFile,'###');
  end;

  NoInfoMsg;
  System.close(ttt);
  writeln(OborotFile,'@@@');
  writeln(OborotFile,'===');
  Close(OborotFile);
  writeln(ZakupkaFile,'@@@');
  writeln(ZakupkaFile,'===');
  Close(ZakupkaFile);
  writeln(PostavkaFile,'@@@');
  writeln(PostavkaFile,'===');
  Close(PostavkaFile);

  Dispose(PostavkaBox1,Done);
  Dispose(PostavkaBox,Done);
  Dispose(TempBox,Done);
  Dispose(ZakupkaBox,Done);
  Dispose(ErrorBox,Done);

(*  Sound(100);
  DInfoMsg('Данные импортированы в '+Path^.Dat.ToTemp+'litrdecl.csv,litrmrk.csv,litrprh.csv',False);
  NoSound;
  Application^.ClearEvent(Event);
  Application^.GetEvent(Event);
  Application^.ClearEvent(Event);
  repeat
  Application^.GetEvent(Event);
  until (Event.What <> evNothing) And (Event.Command<>cmMenu);
  NoInfoMsg;
  Application^.ClearEvent(Event); *)

  Assign(ttt,Path^.Dat.ToTemp+'decl.ini');
  Rewrite(ttt);
  Writeln(ttt,'[common]');
  {Путь к файлам с отчетами}
  Writeln(ttt,'Path='+Path^.Dat.ToTemp);
  {Файл RAVE-отчета}
  Writeln(ttt,'ToReport='+Path^.Dat.ToUtils+'Project1.rav');
  {Путь к файлам form7.dsn и schema.ini}
   Writeln(ttt,'ToDSN='+Path^.Dat.ToUtils);
   Writeln(ttt,'VidReport=',IntToStr(vidrep+1,2));
  Close(ttt);


  NoInfoMsg;
  CursorLines:=1543;
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;

  DoneDosMem;
  SwapVectors;
  Ver := DosVersion;
  If Ver<>5{ у XP и 2000 версия 5} Then
  Exec(GetEnvMy,' /c Start.exe '+Path^.Dat.ToUtils+'decl.exe '+Path^.Dat.ToTemp+'decl.ini')
  Else
  Exec(GetEnvMy,' /C Start /D'+Path^.Dat.ToUtils+' decl.exe '+Path^.Dat.ToTemp+'decl.ini');
  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;

  Event.What:=evCommand;
  Event.Command:=cmNone;
  Application^.PutEvent(Event);

  Application^.Redraw;

  CalcDeclareOborot:=true;
End; {function CalcDeclareOborot}


BEGIN
END.