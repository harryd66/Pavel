{если меняется длина строки в ProdagaDoc
 то надо смотреть следующие модули
 MArket,
 MrkTools,
 MrkTool,
 CPrihod,
 Utils2}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


{$I Compile.INC}

Unit MrkTools;

Interface

Uses Glob,ServStr,Dialogs,Drivers,MyCalc,Views,Utils4,FindPrh;

Type NalogType=Record
      ENalog  : String[CIZena];
      Nalog5  : String[CIZena];
      Nalog3  : String[CIZena];
      Nalog_  : String[CIZena];
      AkZis   : String[CIZena];
      Zakupka : String[CIZena];
      Zakupka2: String[CIZena];
      SENalog  : String[CIZena];
      SNalog5  : String[CIZena];
      SNalog3  : String[CIZena];
      SNalog_  : String[CIZena];
      SZakupka : String[CIZena];
      SZakupka2 : String[CIZena];
     End;

Procedure NetChangeProdaga(A,otd:allstr;Vid:Char;Znashenie:AllStr);

Type
  PNetTestWindow = ^TNetTestWindow;
  TNetTestWindow = object(TDialog)
    Function Start(l:PSuperMarketType;Itog:Real;LockBox:PBox;Selector:Word):Boolean;
    procedure Refresh;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;


Type
  PMarketWindow = ^TMarketWindow;
  TMarketWindow = object(TDialog)
    Calc        : PMyCalculator;
    FR  :     PFindRezervWindow;
    FindPrevOtgruzka : Boolean;
    LastZena :PLastZenaWindow;
    FP        : PFindPrh;
    Procedure Ini(s:String;Regim:Word;DisableTovar,DisableDocument:Boolean);
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;

Function CalcItog(Var ItogNalog:NalogType;Var Skid:AllStr;
Var Itogo:Float;Var Mesto:LongInt;Var Itogo_O: AllStr;Var SertifItogo,SertifSkidkaItogo:Float) : Float;

Var
 NetTestWindow : PNetTestWindow;
 PrevMarket : PSuperMarketType;
 NetTestBox : PBox;
 ControlClientLabel,ControlGR : PView;
 PrevNet : String;
 PrevKolPack : Byte;
 PrevKol : String[CKol];
 PrevS,PrevAgent,PrevEkspeditor : TEnjoyStr;
 PrevName,
 PrevSMarket : String;
 SOtd,SArtikul,SFantomArtikul : String[CArtikul];
 ActiveOtdel :ArtikulStr;
 ActiveFantomOtdel :String[CKol];
 Selector,Skidka,OperatorSelector,Prom   : Word;
 AddSertif: Boolean;
 Information,DebInfo : Boolean;
 ItogNalog:NalogType;
 ZakazMemory : PZakazType;
 FStr : String[CNAme];
 SGRZena : AllStr;

Implementation

Uses App,Objects,Market,Validate,Serv,ColorTxt,Utils,Utils1,MrkTool,
     DbEngin2,ServStr2,Utils10,
     msgbox,NetCall,Net,NetDbEng,Dos,CPrihod,DbEngine,TpDate,Utils2,Utils3;


Type MW = Record
     Pack   : Word;
     Kol    : String[CKol];
     NZena  : String[CZena];
     Skidka : String[CZena];
    FantomKol    : String[CKol];
    FantomNZena  : String[CZena];
    FantomSkidka : String[CZena];
     End;


Var ControlFantomNZena,ControlFantomSkidka,
 ControlError,ControlNetNDS,ControlNetKol,ControlNetZena,ControlRemarka,
 ControlNetNalog:PView;
 ControlBox:PBox;
 MSelector:Word;
 SClientMinZena : TDateString;
 MarketWin : PMarketWindow;
 El : MW;
 Control1Skidka,ControlZakupka,Pack,ControlFantomKol,
 ControlKol,ControlPack,ControlNZena: PView;
 ViewZakupka:Boolean;



Procedure NetChangeProdaga(A,otd:allstr;Vid:Char;Znashenie:AllStr);
LAbel 777;
Var Count : Word;
    s : String;
    find : boolean;
    FindArt,FindOtd:ArtikulStr;
    Summa : String[CIZena];
    Delta,PrevKol : String[CKol];
    SRZena,SOZena,Zena:String[CIZena];
Begin
Find:=False;
{$IFDEF DPMI}

If Prodaga^.List^.Count>0 Then
 Begin
  For count:=0 To Prodaga^.List^.Count-1 Do
   Begin
    s:=Prodaga^.GetText(count,Prodaga^.List^.Count);
    FindArt:=Copy(s,1,CArtikul);
    FindOtd:=Copy(s,1+CArtikul+1+CName+1,COne);
    If (FindArt=A) And (FindOtd=Otd) Then
     Begin
      Find:=True;
      Break;
     End;
   end;{For}

   If Not(Find) Then Goto 777;
    (*
    Begin
     MessageBox(#3'Позиция '+A+' из отделения '+Otd+' не найдена!'^M+
        ClicProgrammer,Nil,mfError+mfCancelButton);
     Goto 777;
    End;{if Not(Find)}*)

{1-наименование запретили к продаже
 2-отсутствует необходимое количество
 3-изменена цена
 4-изменена ставка ндс
 5-вид НДС
 6-изменена ставка нп
 7-вид НП
 8-изменена ставка скидки (авто)
 9-изменена закупка}

{Имя код отд кол литраж цена скидка сумма цена Р Цена О Налог ВидНП НДС ВидНДС Закупка}

   Case Vid Of
{количество}
   '2':Begin

      Str(StrToInt(Znashenie):CKol,Znashenie);
      Format(ZnaShenie,CKol);{новое количество}
      Delete(s,1+CName+1+CArtikul+1+COne+1,CKol);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1);
      {обновление суммы итого}
      SRZena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1,CZena);{новая цена}
      MyStr(StrToInt(Znashenie)*StrToReal(SRZena),CInputIZena,CMantissa,Summa);
      DelSPace(summa);
      Format(Summa,CInputIZena);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1,CInputIZena);
      Insert(Summa,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1);

     End;
{цена}
   '3':Begin
      SRZena:=BakGetField(FRZena,A,0);
      DelSpace(SRZena);
      MyStr(StrToReal(SRZena),CZena,CMAntissa,SRZena);
      SOZena:=BakGetField(FOZena,A,0);
      DelSpace(SOZena);
      MyStr(StrToReal(SOZena),CZena,CMAntissa,SOZena);
      If MSelector in [0,1] Then
      ZnaShenie:=SRZena
      Else ZnaShenie:=SOZena;
      Format(ZnaShenie,CZena);
      Format(SRZena,CZena);
      Format(SOZena,CZena);
      {замена цены продажи}
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1,CZena);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1);
      {замена Р/Ц}
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1,CZena);
      Insert(SRZena,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1);
      {замена О/Ц}
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+CZena+1,CZena);
      Insert(SOZena,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+CZena+1);

      {обновление суммы итого}
      SRZena:=Copy(s,1+CName+1+CArtikul+1+COne+1,CKol);{новое количество}
      MyStr(StrToReal(Znashenie)*StrToInt(SRZena),CInputIZena,CMantissa,Summa);
      DelSPace(summa);
      Format(Summa,CInputIZena);

      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1,CInputIZena);
      Insert(Summa,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1);
     End;
{НДС}
   '4':Begin
      MyStr(StrToReal(Znashenie),CLitr,CMAntissa,Znashenie);
      Format(ZnaShenie,CLitr);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1,CLitr);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1);
     End;
{вид НДС}
   '5':Begin
      Format(ZnaShenie,COne);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1,COne);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1);
     End;
{НП}
   '6':Begin
      MyStr(StrToReal(Znashenie),CLitr,CMAntissa,Znashenie);
      Format(ZnaShenie,CLitr);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1,CLitr);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1);
     End;
{вид НП}
   '7':Begin
      Format(ZnaShenie,COne);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1,COne);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1);
     End;
{Закупка}
   '9':Begin
      MyStr(StrToReal(Znashenie),CZenaZ,CMAntissaZ,Znashenie);
      Format(ZnaShenie,CZenaZ);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1,CZenaZ);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1);
     End;

   'A':Begin
      MyStr(StrToReal(Znashenie),CZenaZ,CMAntissaZ,Znashenie);
      Format(ZnaShenie,CZenaZ);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1,CZenaZ);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1);
     End;

   {изменена информация о наличии региональной марки}
   'B':Begin
      Znashenie:=IntToStr(StrToInt(ZnaShenie),COne);
      Format(ZnaShenie,COne);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1,COne);
      Insert(Znashenie,s,
                  1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1);
     End;

   {изменена информация об акцизном сборе}
   'C':Begin
      MyStr(StrToReal(Znashenie),CZenaZ,CMAntissaZ,Znashenie);
      Format(ZnaShenie,CZenaZ);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1,CZenaZ);
      Insert(Znashenie,s,
                  1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1);
     End;

   {изменена информация о цене марки}
   'D':Begin
      MyStr(StrToReal(Znashenie),CZenaZ,CMAntissaZ,Znashenie);
      Format(ZnaShenie,CZenaZ);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1,CZenaZ);
      Insert(Znashenie,s,
                  1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1);
     End;
   Else;
   End;{Case}
   Prodaga^.List^.AtFree(Count);
   Prodaga^.SetRange(Prodaga^.List^.Count);
   Prodaga^.List^.Insert(NewStr(S));
   Prodaga^.SetRange(Prodaga^.List^.Count);
   Exit;
 End;

777:

If ProdagaDoc^.List^.Count>0 Then
 Begin
  For count:=0 To ProdagaDoc^.List^.Count-1 Do
   Begin
    s:=ProdagaDoc^.GetText(count,ProdagaDoc^.List^.Count);
    FindArt:=Copy(s,1,CArtikul);
    FindOtd:=Copy(s,1+CArtikul+1+CName+1,COne);
    If (FindArt=A) And (FindOtd=Otd) Then
     Begin
      Find:=True;
      Break;
     End;
   end;{For}

   If Not(Find) Then
    Begin
     MessageBox(#3'Позиция '+A+' из отделения '+Otd+' не найдена!'^M+
        ClicProgrammer^,Nil,mfError+mfCancelButton);
     Exit;
    End;{if Not(Find)}

{1-наименование запретили к продаже
 2-отсутствует необходимое количество
 3-изменена цена
 4-изменена ставка ндс
 5-вид НДС
 6-изменена ставка нп
 7-вид НП
 8-изменена ставка скидки (авто)
 9-изменена закупка}

{Имя код отд кол литраж цена скидка сумма цена Р Цена О Налог ВидНП НДС ВидНДС Закупка}

   Case Vid Of
{количество}
   '2':Begin
      Str(StrToInt(Znashenie):CKol,Znashenie);
      Format(ZnaShenie,CKol);{новое количество}
      PrevKol:=Copy(s,1+CName+1+CArtikul+1+COne+1,CKol);{прежнее количество}
      Str(StrToInt(PrevKol)-StrToInt(Znashenie):CKol,Delta);{невязка}

      Delete(s,1+CName+1+CArtikul+1+COne+1,CKol);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1);
      {обновление суммы итого}
      SRZena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1,CZena);{новая цена}
      MyStr(StrToInt(Znashenie)*StrToReal(SRZena),CInputIZena,CMantissa,Summa);
      DelSPace(summa);
      Format(Summa,CInputIZena);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1,CInputIZena);
      Insert(Summa,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1);
      SFantomArtikul:=Copy(s,1,CArtikul);

      {начинаем вносить изменения в Prodaga}
      DelProdagaDocAndInsert(SFantomArtikul,Znashenie);


     End;
{цена}
   '3':Begin
      SRZena:=BakGetField(FRZena,A,0);
      DelSpace(SRZena);
      MyStr(StrToReal(SRZena),CZena,CMAntissa,SRZena);
      SOZena:=BakGetField(FOZena,A,0);
      DelSpace(SOZena);
      MyStr(StrToReal(SOZena),CZena,CMAntissa,SOZena);
      If MSelector in [0,1] Then
      ZnaShenie:=SRZena
      Else ZnaShenie:=SOZena;
      Format(ZnaShenie,CZena);
      Format(SRZena,CZena);
      Format(SOZena,CZena);
      {замена цены продажи}
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1,CZena);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1);
      {замена Р/Ц}
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1,CZena);
      Insert(SRZena,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1);
      {замена О/Ц}
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+CZena+1,CZena);
      Insert(SOZena,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+CZena+1);

      {обновление суммы итого}
      SRZena:=Copy(s,1+CName+1+CArtikul+1+COne+1,CKol);{новое количество}
      MyStr(StrToReal(Znashenie)*StrToInt(SRZena),CInputIZena,CMantissa,Summa);
      DelSPace(summa);
      Format(Summa,CInputIZena);

      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1,CInputIZena);
      Insert(Summa,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1);
     End;
{НДС}
   '4':Begin
      MyStr(StrToReal(Znashenie),CLitr,CMAntissa,Znashenie);
      Format(ZnaShenie,CLitr);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1,CLitr);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1);
     End;
{вид НДС}
   '5':Begin
      Format(ZnaShenie,COne);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1,COne);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1);
     End;
{НП}
   '6':Begin
      MyStr(StrToReal(Znashenie),CLitr,CMAntissa,Znashenie);
      Format(ZnaShenie,CLitr);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1,CLitr);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1);
     End;
{вид НП}
   '7':Begin
      Format(ZnaShenie,COne);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1,COne);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1);
     End;
{Закупка}
   '9':Begin
      MyStr(StrToReal(Znashenie),CZenaZ,CMAntissaZ,Znashenie);
      Format(ZnaShenie,CZenaZ);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1,CZenaZ);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1);
     End;
{Закупка}
   'A':Begin
      MyStr(StrToReal(Znashenie),CZenaZ,CMAntissaZ,Znashenie);
      Format(ZnaShenie,CZenaZ);
      Delete(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1,CZenaZ);
      Insert(Znashenie,s,1+CName+1+CArtikul+1+COne+1+CKol+1+CLitr+1+CZena+1+CZena+1+CInputIZena+1+
         CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1);
     End;


   Else;
   End;{Case}
   ProdagaDoc^.List^.AtFree(Count);
   ProdagaDoc^.SetRange(ProdagaDoc^.List^.Count);
   ProdagaDoc^.List^.Insert(NewStr(S));
   ProdagaDoc^.SetRange(ProdagaDoc^.List^.Count);
 End;
{$ENDIF}
End;


Procedure TNetTestWindow.Refresh;
Var r :TRect;
    Ansver,Res : String;
    i : Word;
    Otd,A : ArtikulStr;

Begin
If NetTestBox^.List^.Count>0 Then
Begin
PrevNet:=NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count);
Res:=Copy(PrevNet,1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CLitr+1+CLitr+1+
          CZena+1+CProz+1+CZenaZ+1+CZenaZ+1,
     Ord(PrevNet[0])-1+CNAme+1+CArtikul+1+COne+1+CKol+1+CZena+1+CLitr+1+CLitr+1+CZena+1+CProz+1+CZenaZ+1+CZenaZ+1);
a:=Copy(NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count),1+CNAme+1,CArtikul);
Otd:=Copy(NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count),1+CNAme+1+CArtikul+1,COne);

{0-все ок
 1-наименование запретили к продаже
 2-отсутствует необходимое количество
 3-изменена цена
 4-изменена ставка ндс
 5-вид НДС
 6-изменена ставка нп
 7-вид НП
 8-изменена ставка скидки (авто)
 9-изменена закупка }

Ansver[0]:=#0;

For i:=1 To Ord(Res[0]) Do
 Begin
  Case Res[i] Of
  '1':If Ord(Ansver[0])<55 then Ansver:=Ansver+'запрет к продаже; '
    else Ansver:=Ansver+^M+'запрет к продаже; ';
  '2':If Ord(Ansver[0])<55 then Ansver:=Ansver+'нет необх.колич.; '
    else Ansver:=Ansver+'нет необх.колич.; ';
  '3':If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.цена; '
    else Ansver:=Ansver+'измен.цена; ';
  '4':If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.НДС; '
    else Ansver:=Ansver+'измен.НДС; ';
  '5':If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.вид НДС; '
    else Ansver:=Ansver+'измен.вид НДС; ';
  '6':If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.НП; '
    else Ansver:=Ansver+'измен.НП; ';
  '7':If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.вид НП; '
    else Ansver:=Ansver+'измен.вид НП; ';

  '8':If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.скид.; '
    else Ansver:=Ansver+'измен.скид.; ';

  '9':If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.закуп.; '
    else Ansver:=Ansver+'измен.закуп.; ';
  'A':If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.закуп.2; '
    else Ansver:=Ansver+'измен.закуп.2; ';
  'B':If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.рег.марка; '
    else Ansver:=Ansver+'измен.рег.марка; ';
  'C':If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.акц.сбор; '
    else Ansver:=Ansver+'измен.акз.сбор; ';
  'D':If Ord(Ansver[0])<55 then Ansver:=Ansver+'измен.цена марки; '
    else Ansver:=Ansver+'измен.цена марки; ';
  Else ansver:='???; ';
  End;
 End;

Dispose(ControlError,Done);
R.Assign(21, 16, 78, 18);
ControlError := New(PColoredText, Init(R,#3+Ansver, $5f));
NetTestWindow^.Insert(ControlError);


AnsVer:=BakGetField(FDiv,a,StrToInt(Otd));
DelSpace(ansver);
Dispose(ControlNetKol,Done);
R.Assign(28, 15, 33, 16);
Controlnetkol := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetkol);


AnsVer:=BakGetField(FRZena,a,0);
DelSpace(ansver);

Dispose(ControlNetZena,Done);
R.Assign(42, 15, 50, 16);
Controlnetzena := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetzena);

AnsVer:=GetIDField(FNDS,a);
DelSpace(ansver);

Dispose(ControlNetNDS,Done);
R.Assign(58, 15, 63, 16);
Controlnetnds := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetnds);

AnsVer:=GetIDField(FNalog,a);
DelSpace(ansver);
Dispose(ControlNetNAlog,Done);
R.Assign(70, 15, 75, 16);
Controlnetnalog := New(PColoredText, Init(R, #3+Ansver, $7E));
nettestwindow^.Insert(Controlnetnalog);
Redraw;
End;

End;


Function TNetTestWindow.Start(L:PSuperMarketType;Itog:Real;LockBox:PBox;Selector:Word):Boolean;
Label 1,2;
Var R:TRect;
    Control : PView;
    ssk,ErrorStr:AllStr;
    s,Msg:String;
    i : Word;
    FindError:Boolean;
    Temp : PBox;
    Wspom,sklad,res,zakaz:longint;
    StopProcess,LogikZena,LogikZakupka : boolean;
Begin
MSelector:=Selector;
Start:=True;
R.Assign(0, 0, 0, 0);
Temp := New(PBox, Init(R, 1, Nil));
Temp^.NewList(New(PTextCollection, Init(0,1)));
{0-все ок
 1-наименование запретили к продаже
 2-отсутствует необходимое количество
 3-изменена цена
 4-изменена ставка ндс
 5-вид НДС
 6-изменена ставка нп
 7-вид НП
 8-изменена ставка скидки (авто)
 9-закупка}
FindError:=False;
StopProcess:=False;
 If L^.Dat.Amount>0 Then
  Begin
   For i:=1 To L^.Dat.Amount Do
    Begin
     ErrorStr[0]:=#0;
     {наименование запретили к продаже}
     If Not((L^.Dat.OperatorSelector=1)And(L^.Dat.DocSelector=0)) Then
     {если не межскладская первозка}
     If (GetIdMArket(L^.Dat.MarketElement[i].BazKod)=0) Then ErrorStr:=ErrorStr+'1';

     {в отделении отсутствует необходимое количество}
     res:=0;
     zakaz:=0;

     If Glob.Status=DocEdit Then
       res:=GetKolMarket(L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionNumber,PrevMarket);

     Res:=StrToInt(L^.Dat.MarketElement[i].Input.Kol)-res;

     sklad:=StrToInt(BakGetField(FDiv,L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionNumber));

{     MemC(IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne));}
If (OperatorSelector<>1) Then{отключается при преобразовании заказа в накладную}
Begin
     Zakaz:=StrToInt(BakGetField(FDivR,L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionNumber));
End;

If Glob.Status=DocNormal Then
Begin
     Case InputZakaz Of
     {продажа,бронирование}
     0,1:Begin
          {
          MemC('Sklad '+IntToStr(Sklad,CKOl)+' Zakaz '+IntToStr(Zakaz,CKOl)+' Res '+IntToStr(Res,CKOl) );
          MemC(IntToSTr((Sklad-Zakaz-res),CKOl));}
          If (Sklad-Zakaz-res)<0 Then
          Begin
           ErrorStr:=ErrorStr+'2';
           Msg:=IntToStr(Sklad-Zakaz,CKol);
           NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),
                 '2',Msg);
          End;
          {Else  MemC('По хуй');}

            End;{0,1}
     {оформление}
     2:Begin
          If (Sklad-res)<0 Then
          Begin
           ErrorStr:=ErrorStr+'2';
           Msg:=IntToStr(Sklad,CKol);
           NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),
                 '2',Msg);
          End;
       End;
     Else
      MessageBox (#3'Недопустимое значение InputZakaz ='+IntToSTr(InputZakaz,CMantissa),Nil,mfWarning+mfCancelButton);
     End;{Case}
End{Если идет первичный набор документа}
Else
 Begin{Status=DocEdit}
     If Res>0 Then{новое количество больше старого}
     Case InputZakaz Of
     {продажа}
     0:Begin
          If (Sklad-Zakaz-res)<0 Then
          Begin
           ErrorStr:=ErrorStr+'2';
           wspom:=Sklad-Zakaz;
           If Wspom<0 Then Wspom:=0;
           Msg:=IntToStr(GetKolMarket(L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionNumber,PrevMarket)+
                               Wspom,CKol);
           NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),
                 '2',Msg);
          End;
            End;{0}
     {Бронирование}
     1:Begin
          If (Sklad-Zakaz-res)<0 Then
          Begin
           ErrorStr:=ErrorStr+'2';
           wspom:=Sklad-Zakaz;
           If Wspom<0 Then Wspom:=0;
           Msg:=IntToStr(GetKolMarket(L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionNumber,PrevMarket)+
                               Wspom,CKol);
           NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),
                 '2',Msg);
          End;
       End;
(*
     при корректировке накладной она не может быть связана с заказом
     {оформление Zakaz=0}
     2:Begin
          If (Sklad-Zakaz-res)<0 Then
          Begin
           Msg:=IntToStr(Sklad-Zakaz+GetKolMarket(L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionNumber,
                 PrevMarket),CKol);
           NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),2,Msg);
          End;
       End;
*)
     Else
      MessageBox (#3'Status=DocEdit Недопустимое значение InputZakaz ='+IntToSTr(InputZakaz,CMantissa),Nil,mfWarning+
         mfCancelButton);
     End;{Case}
 End;{редактирование документа}



If InputZakaz<>1 Then
Begin
     {изменена цена оптовая или розничная}
     If Glob.Status=DocNormal Then LogikZena:=True
     Else
      Begin
       {проверяем бала ли позиция в накладной}
       LogikZena:=Not FindMarket(L^.Dat.MarketElement[i].BazKod,PrevMarket);
       If LogikZena Then{если позиции не бало в накладной}
        Begin
         (*
         LogikZena:=TestMarket(L^.Dat.MarketElement[i].Bazkod,PrevMarket,0,True);
         {если была переоценка после выписки накладной тогда остановить процесс
            и запретить выписку товара LogikZena=True}
         If Not(LogikZena) Then StopProcess:=True;
         If Not(LogikZena) Then FindError:=True;
         If Not(LogikZena) Then Goto 2;
         *)
         if TestMarket(L^.Dat.MarketElement[i].Bazkod,PrevMarket,0,True) then
           begin
            StopProcess:=True;
            FindError:=True;
            Goto 2;
           end;
         LogikZena:=True;
        End
       Else             {если позиция была в накладной}
        Begin
                                                                      {не выводить сообщение}
          If Not(TestMarket(L^.Dat.MarketElement[i].Bazkod,PrevMarket,0,False)) Then
            Begin{если переоценки после выписки первого варианта не было}
             LogikZena:=False;
            End
                Else
                  Begin{если переоценка была после выписки}
             If GetFullKolMArket(L^.Dat.MarketElement[i].Bazkod,L)>
                GetFullKolMArket(L^.Dat.MarketElement[i].Bazkod,PrevMarket) Then
               Begin{если количество новое изменилось в большую сторону}
                LogikZena:=FAlse;
                StopProcess:=True;
                FindError:=True;
              MessageBox(#3+'Товар с кодом ('+L^.Dat.MarketElement[i].Bazkod+') после выписки документа уже был переоценен! '+
                         'Редактирование этой позиции документа запрещено!',Nil,mfError+mfCancelButton);
                Goto 2;
               End{конец уловия если новое количество не изменилось}
              Else
               Begin{если новое количество не изменилось или стало меньше}
                LogikZena:=False;
               End;
                  End;
        End;{Else если позиция была в наклдной}
      End;{Status=DocEdit}

{Алгоритм проверки:
1 позия была в накладной?
  да - была ли переоценка?
  да - новое количество больше старого?
  да - запрет выписки!
 нет - цену не проверяем
 нет - проверяем цену
...}

     If LogikZena Then
     If((StrToReal(BakGetField(FRZena,L^.Dat.MarketElement[i].BazKod,0)))<>
           (StrToReal(L^.Dat.MarketElement[i].Input.R_Zena))) Or
       ((StrToReal(BakGetField(FOZena,L^.Dat.MarketElement[i].BazKod,0)))<>
           (StrToReal(L^.Dat.MarketElement[i].Input.O_Zena))) Then
        Begin
         ErrorStr:=ErrorStr+'3';
         Msg:=BakGetField(FRZena,L^.Dat.MarketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),'3',Msg);
         Msg:=BakGetField(FOZena,L^.Dat.MarketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),'3',Msg);
        End;

     {изменена ставка ндс}
    If Glob.Status<>DocEdit Then
     If (StrToReal(GetIDField(FNDS,L^.Dat.MarketElement[i].BazKod)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.NDS)) Then
        Begin
{        ErrorStr:=ErrorStr+'4';}
         Msg:=GetIDField(FNDS,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),'4',Msg);
        End;
     {изменен вид ндс}
    If Glob.Status<>DocEdit Then
     If (StrToInt(GetIDField(FVidNDS,L^.Dat.MarketElement[i].BazKod)))<>
           (L^.Dat.MarketElement[i].Input.VidNDS) Then
        Begin
{        ErrorStr:=ErrorStr+'5';}
         Msg:=GetIDField(FVidNDS,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),'5',Msg);
        End;
     {изменена ставка нп}
    If Glob.Status<>DocEdit Then
     If (StrToReal(GetIDField(FNalog,L^.Dat.MarketElement[i].BazKod)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.SpecNalog)) Then
        Begin
        {ErrorStr:=ErrorStr+'6';}
         Msg:=GetIDField(FNalog,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),'6',Msg);
        End;
     {изменен вид нп}
    If Glob.Status<>DocEdit Then
     If (StrToInt(GetIDField(FVidNalog,L^.Dat.MarketElement[i].BazKod)))<>
        (L^.Dat.MarketElement[i].Input.VidNAlog) Then
        Begin
         {ErrorStr:=ErrorStr+'7';}
         Msg:=GetIDField(FVidNalog,L^.Dat.MarketElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),'7',Msg);
        End;

     {изменена таблица авто-скидок}
     MyStr((GetSkidkaProz(L^.Dat.MarketElement[i].BazKod,Itog)),CProz,CMantissaProz,Msg);
     DelSpace(msg);
     If (Abs(StrToreal(Msg)-StrToReal(L^.Dat.MarketElement[i].Input.proz))>0.00009) Then ErrorStr:=ErrorStr+'8';

     If Glob.Status=DocNormal Then LogikZakupka:=True
     Else
      Begin
       {проверяем бала ли позиция в накладной}
       LogikZakupka:=Not FindMarket(L^.Dat.MarketElement[i].BazKod,PrevMarket);
       If LogikZakupka Then{если позиции не было в накладной}
        Begin
         LogikZakupka:=True;
        End
       Else     {если позиция была в накладной}
        Begin
          If GetFullKolMArket(L^.Dat.MarketElement[i].Bazkod,L)>
             GetFullKolMArket(L^.Dat.MarketElement[i].Bazkod,PrevMarket) Then
Begin
     If (StrToReal(BakGetField(FZakupka,L^.Dat.MarketElement[i].BazKod,0)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.Zakupka)) Then
             Begin   {если количество новое изменилось в большую сторону}
                LogikZakupka:=FAlse;
                StopProcess:=True;
                FindError:=True;
                MessageBox(#3+'У товара с кодом ('+L^.Dat.MarketElement[i].Bazkod+') изменилась закупочная цена! '+
                           'Редактирование этой позиции документа запрещено!',Nil,mfError+mfCancelButton);
                Goto 2;
             End{конец уловия если новое количество не изменилось}
              Else
               Begin{если новое количество не изменилось или стало меньше}
                LogikZakupka:=False;
               End;

     If (StrToReal(BakGetField(FZakupka2,L^.Dat.MarketElement[i].BazKod,0)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.Zakupka2)) Then
             Begin   {если количество новое изменилось в большую сторону}
                LogikZakupka:=FAlse;
                StopProcess:=True;
                FindError:=True;
                MessageBox(#3+'У товара с кодом ('+L^.Dat.MarketElement[i].Bazkod+') изменилась закупочная цена 2! '+
                         'Редактирование этой позиции документа запрещено!',Nil,mfError+mfCancelButton);
                Goto 2;
             End{конец уловия если новое количество не изменилось}
              Else
               Begin{если новое количество не изменилось или стало меньше}
                LogikZakupka:=False;
               End;
End;
        End;{Else если позиция была в наклдной}
      End;{Status=DocEdit}

     {изменена закупочная цена}
     {
     If LogikZakupka Then      MemC('True')
     Else MemC('False');}

     If LogikZakupka Then
     If (StrToReal(BakGetField(FZakupka,L^.Dat.MarketElement[i].BazKod,0)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.Zakupka)) Then
        Begin
         ErrorStr:=ErrorStr+'9';
         Msg:=BakGetField(FZakupka,L^.Dat.MarketElement[i].BazKod,0);
         {MemCC;}
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),'9',Msg);
        End;

     If LogikZakupka Then
     If (StrToReal(BakGetField(FZakupka2,L^.Dat.MarketElement[i].BazKod,0)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.Zakupka2)) Then
        Begin
         ErrorStr:=ErrorStr+'A';
         Msg:=BakGetField(FZakupka2,L^.Dat.MarketElement[i].BazKod,0);
         {MemCC;}
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),'A',Msg);
        End;


    If Glob.Status<>DocEdit Then
     If (StrToInt(BakGetField(FRegionMarka,L^.Dat.MarketElement[i].BazKod,0)))<>
        (L^.Dat.MArketElement[i].Input.RegionMArka) Then
        Begin
         ErrorStr:=ErrorStr+'B';
         Msg:=BakGetField(FRegionMarka,L^.Dat.MArketElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MArketElement[i].BazKod,IntToStr(L^.Dat.MArketElement[i].Input.DiviSionNumber,COne),'B',Msg);
        End;

    If Glob.Status<>DocEdit Then
     If (StrToReal(BakGetField(FAkzisSbor,L^.Dat.MarketElement[i].BazKod,0)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.AkzisSbor)) Then
        Begin
         ErrorStr:=ErrorStr+'C';
         Msg:=BakGetField(FAkzisSbor,L^.Dat.MarketElement[i].BazKod,0);
         {MemCC;}
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),'C',Msg);
        End;

    If Glob.Status<>DocEdit Then
     If (StrToReal(BakGetField(FZenaMarki,L^.Dat.MarketElement[i].BazKod,0)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.ZenaMarki)) Then
        Begin
         ErrorStr:=ErrorStr+'D';
         Msg:=BakGetField(FZenaMarki,L^.Dat.MarketElement[i].BazKod,0);
         {MemCC;}
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.MarketElement[i].BazKod,IntToStr(L^.Dat.MarketElement[i].Input.DiviSionNumber,COne),'D',Msg);
        End;

End;{InputZakaz<>1 отключана проверка при формировании заказа}


     If ErrorStr[0]<>#0 Then
      Begin
{наименование код n колич цена ндс нп скидка руч скидка авто errorstr}
       s:=GetIdField(FName,L^.Dat.MarketElement[i].BazKod);
       DelSpaceRight(s);
       Format(s,CName);
       DelSpace(L^.Dat.MarketElement[i].Input.Kol);
       Format(L^.Dat.MarketElement[i].Input.Kol,CKol);
       DelSpace(L^.Dat.MarketElement[i].Input.Zena);
       Format(L^.Dat.MarketElement[i].Input.Zena,CZena);
       DelSpace(L^.Dat.MarketElement[i].Input.NDS);
       Format(L^.Dat.MarketElement[i].Input.NDS,CLitr);
       DelSpace(L^.Dat.MarketElement[i].Input.SpecNalog);
       Format(L^.Dat.MarketElement[i].Input.SpecNAlog,CLitr);
       DelSpace(L^.Dat.MarketElement[i].Input.Skidka);
       Format(L^.Dat.MarketElement[i].Input.Skidka,CZena);
       DelSpace(L^.Dat.MarketElement[i].Input.Proz);
       Format(L^.Dat.MarketElement[i].Input.Proz,CProz);
       DelSpace(L^.Dat.MarketElement[i].Input.Zakupka);
       Format(L^.Dat.MarketElement[i].Input.Zakupka,CZenaZ);
       DelSpace(L^.Dat.MarketElement[i].Input.Zakupka2);
       Format(L^.Dat.MarketElement[i].Input.Zakupka2,CZenaZ);
       s:=s+'│'+L^.Dat.MarketElement[i].BazKod+'│'+IntToSTr(L^.Dat.MarketElement[i].Input.DivisionNumber,COne)+'│'
          +L^.Dat.MarketElement[i].Input.Kol+'│'+L^.Dat.MarketElement[i].Input.Zena+'│'+L^.Dat.MarketElement[i].Input.NDS+'│'+
       +L^.Dat.MarketElement[i].Input.SpecNAlog+'│'+L^.Dat.MarketElement[i].Input.Skidka+'│'+
       +L^.Dat.MarketElement[i].Input.Proz+'│'+L^.Dat.MarketElement[i].Input.Zakupka+'│'+
          L^.Dat.MarketElement[i].Input.Zakupka2+'│'+ErrorStr;
       Temp^.List^.Insert(NewStr(s));
       Temp^.SetRange(Temp^.List^.Count);
       DelSpace(L^.Dat.MarketElement[i].Input.Kol);
       DelSpace(L^.Dat.MarketElement[i].Input.Zakupka);
       DelSpace(L^.Dat.MarketElement[i].Input.Zakupka2);
       DelSpace(L^.Dat.MarketElement[i].Input.Zena);
       DelSpace(L^.Dat.MarketElement[i].Input.NDS);
       DelSpace(L^.Dat.MarketElement[i].Input.SpecNalog);
       DelSpace(L^.Dat.MarketElement[i].Input.Skidka);
       DelSpace(L^.Dat.MarketElement[i].Input.Proz);
       findError:=true;
       start:=false;
      End;
   End;
 end;{if}

 If L^.Dat.AmountS>0 Then
  Begin
   For i:=1 To L^.Dat.AmountS Do
    Begin
     ErrorStr[0]:=#0;
     {наименование запретили к продаже}
     If Not((L^.Dat.OperatorSelector=1)And(L^.Dat.DocSelector=0)) Then
     {если не межскладская первозка}
     If (GetIdMArket(L^.Dat.DocumentElement[i].BazKod)=0) Then ErrorStr:=ErrorStr+'1';

     res:=0;
     zakaz:=0;

     If Glob.Status=DocEdit Then
       res:=GetKolMarket(L^.Dat.DocumentElement[i].BazKod,L^.Dat.DocumentElement[i].Input.DiviSionNumber,PrevMarket);

     Res:=StrToInt(L^.Dat.DocumentElement[i].Input.Kol)-res;

     sklad:=StrToInt(BakGetField(FDiv,L^.Dat.DocumentElement[i].BazKod,L^.Dat.DocumentElement[i].Input.DiviSionNumber));

If (InputZakaz<>2) And (OperatorSelector<>1)  Then{отключается при преобразовании заказа в накладную}
Begin
     Zakaz:=StrToInt(BakGetField(FDivR,L^.Dat.DocumentElement[i].BazKod,L^.Dat.DocumentElement[i].Input.DiviSionNumber));
End;

If Glob.Status=DocNormal Then
Begin
     Case InputZakaz Of
     {продажа,бронирование}
     0,1:Begin
          If (Sklad-Zakaz-res)<0 Then
          Begin
           ErrorStr:=ErrorStr+'2';
           Msg:=IntToStr(Sklad-Zakaz,CKol);
           NetChangeProdaga(L^.Dat.DocumentElement[i].BazKod,IntToStr(L^.Dat.DocumentElement[i].Input.DiviSionNumber,COne),'2',
                 Msg);
          End;
            End;{0,1}
     {оформление}
     2:Begin
          If (Sklad-res)<0 Then
          Begin
           ErrorStr:=ErrorStr+'2';
           Msg:=IntToStr(Sklad,CKol);
           NetChangeProdaga(L^.Dat.DocumentElement[i].BazKod,IntToStr(L^.Dat.DocumentElement[i].Input.DiviSionNumber,COne),'2',
                 Msg);
          End;
       End;
     Else
      MessageBox (#3'Недопустимое значение InputZakaz ='+IntToSTr(InputZakaz,CMantissa),Nil,mfWarning+mfCancelButton);
     End;{Case}
End{Если идет первичный набор документа}
Else
 Begin{Status=DocEdit}
     If Res>0 Then{новое количество больше старого}
     Case InputZakaz Of
     {продажа}
     0:Begin
          If (Sklad-Zakaz-res)<0 Then
          Begin
           ErrorStr:=ErrorStr+'2';
           wspom:=Sklad-Zakaz;
           If Wspom<0 Then Wspom:=0;
           Msg:=IntToStr(GetKolMarket(L^.Dat.DocumentElement[i].BazKod,L^.Dat.DocumentElement[i].Input.DiviSionNumber,
                 PrevMarket)+
                               Wspom,CKol);
           NetChangeProdaga(L^.Dat.DocumentElement[i].BazKod,IntToStr(L^.Dat.DocumentElement[i].Input.DiviSionNumber,COne),'2',
                 Msg);
          End;
            End;{0}
     {Бронирование}
     1:Begin
          If (Sklad-Zakaz-res)<0 Then
          Begin
           ErrorStr:=ErrorStr+'2';
           wspom:=Sklad-Zakaz;
           If Wspom<0 Then Wspom:=0;
           Msg:=IntToStr(GetKolMarket(L^.Dat.DocumentElement[i].BazKod,L^.Dat.DocumentElement[i].Input.DiviSionNumber,
                 PrevMarket)+
                               Wspom,CKol);
           NetChangeProdaga(L^.Dat.DocumentElement[i].BazKod,IntToStr(L^.Dat.DocumentElement[i].Input.DiviSionNumber,COne),'2',
                 Msg);
          End;
       End;
     Else
      MessageBox (#3'Status=DocEdit Недопустимое значение InputZakaz ='+IntToSTr(InputZakaz,CMantissa),Nil,mfWarning+
         mfCancelButton);
     End;{Case}
 End;{редактирование документа}


If InputZakaz<>1 Then
Begin
     {изменена цена оптовая или розничная}
     If Glob.Status=DocNormal Then LogikZena:=True
     Else
      Begin
       {проверяем была ли позиция в накладной}
       LogikZena:=Not FindMarket(L^.Dat.DocumentElement[i].BazKod,PrevMarket);
       If LogikZena Then{если позиции не бало в накладной}
        Begin
         (*
         LogikZena:=TestMarket(L^.Dat.DocumentElement[i].Bazkod,PrevMarket,0,True);
         {если была переоценка после выписки накладной тогда остановить процесс
            и запретить выписку товара LogikZena=True}
         If Not(LogikZena) Then StopProcess:=True;
         If Not(LogikZena) Then FindError:=True;
         If Not(LogikZena) Then Goto 2;
         *)
         if TestMarket(L^.Dat.DocumentElement[i].Bazkod,PrevMarket,0,True) then
           begin
            StopProcess:=True;
            FindError:=True;
            Goto 2;
           end;
         LogikZena:=True;
        End
       Else             {если позиция была в накладной}
        Begin
                                                                       {не выводить сообщение}
          If Not(TestMarket(L^.Dat.DocumentElement[i].Bazkod,PrevMarket,0,False)) Then
            Begin{если переоценки после выписки первого варианта не было}
             LogikZena:=False;
            End
                Else
                  Begin{если переоценка была после выписки}
             If GetFullKolMArket(L^.Dat.DocumentElement[i].Bazkod,L)>
                GetFullKolMArket(L^.Dat.DocumentElement[i].Bazkod,PrevMarket) Then
               Begin{если количество новое изменилось в большую сторону}
                LogikZena:=FAlse;
                StopProcess:=True;
                FindError:=True;
                MessageBox(#3+'Товар с кодом ('+L^.Dat.DocumentElement[i].Bazkod+
                         ') после выписки документа уже был переоценен! '+
                'Редактирование этой позиции документа запрещено!',Nil,mfError+mfCancelButton);
                Goto 2;
               End{конец уловия если новое количество не изменилось}
              Else
               Begin{если новое количество не изменилось или стало меньше}
                LogikZena:=False;
               End;
                  End;
        End;{Else если позиция была в наклдной}
      End;{Status=DocEdit}
{Алгоритм проверки:
1 позия была в накладной?
  да - была ли переоценка?
  да - новое количество больше старого?
  да - запрет выписки!
 нет - цену не проверяем
 нет - проверяем цену
...}
     If LogikZena Then
     If((StrToReal(BakGetField(FRZena,L^.Dat.DocumentElement[i].BazKod,0)))<>
           (StrToReal(L^.Dat.DocumentElement[i].Input.R_Zena))) Or
       ((StrToReal(BakGetField(FOZena,L^.Dat.DocumentElement[i].BazKod,0)))<>
           (StrToReal(L^.Dat.DocumentElement[i].Input.O_Zena))) Then
        Begin
         {
         memC(L^.Dat.DocumentElement[i].BazKod+^M+
            BakGetField(FOZena,L^.Dat.DocumentElement[i].BazKod,0)+'<>'+
            L^.Dat.DocumentElement[i].Input.O_Zena);}
         ErrorStr:=ErrorStr+'3';
         Msg:=BakGetField(FRZena,L^.Dat.DocumentElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.DocumentElement[i].BazKod,IntToStr(L^.Dat.DocumentElement[i].Input.DiviSionNumber,COne),
            '3',Msg);
         Msg:=BakGetField(FOZena,L^.Dat.DocumentElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.DocumentElement[i].BazKod,IntToStr(L^.Dat.DocumentElement[i].Input.DiviSionNumber,COne),
            '3',Msg);
        End;

     {изменена ставка ндс}
    If Glob.Status<>DocEdit Then
     If (StrToReal(GetIDField(FNDS,L^.Dat.DocumentElement[i].BazKod)))<>
        (StrToReal(L^.Dat.DocumentElement[i].Input.NDS)) Then
        Begin
{        ErrorStr:=ErrorStr+'4';}
         Msg:=GetIDField(FNDS,L^.Dat.DocumentElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.DocumentElement[i].BazKod,IntToStr(L^.Dat.DocumentElement[i].Input.DiviSionNumber,COne),
            '4',Msg);
        End;
     {изменен вид ндс}
    If Glob.Status<>DocEdit Then
     If (StrToInt(GetIDField(FVidNDS,L^.Dat.DocumentElement[i].BazKod)))<>
           (L^.Dat.DocumentElement[i].Input.VidNDS) Then
        Begin
{        ErrorStr:=ErrorStr+'5';}
         Msg:=GetIDField(FVidNDS,L^.Dat.DocumentElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.DocumentElement[i].BazKod,IntToStr(L^.Dat.DocumentElement[i].Input.DiviSionNumber,COne),
            '5',Msg);
        End;
     {изменена ставка нп}
    If Glob.Status<>DocEdit Then
     If (StrToReal(GetIDField(FNalog,L^.Dat.DocumentElement[i].BazKod)))<>
        (StrToReal(L^.Dat.DocumentElement[i].Input.SpecNalog)) Then
        Begin
        {ErrorStr:=ErrorStr+'6';}
         Msg:=GetIDField(FNalog,L^.Dat.DocumentElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.DocumentElement[i].BazKod,IntToStr(L^.Dat.DocumentElement[i].Input.DiviSionNumber,COne),
            '6',Msg);
        End;

     {изменен вид нп}
    If Glob.Status<>DocEdit Then
     If (StrToInt(GetIDField(FVidNalog,L^.Dat.DocumentElement[i].BazKod)))<>
        (L^.Dat.DocumentElement[i].Input.VidNAlog) Then
        Begin
         {ErrorStr:=ErrorStr+'7';}
         Msg:=GetIDField(FVidNalog,L^.Dat.DocumentElement[i].BazKod);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.DocumentElement[i].BazKod,IntToStr(L^.Dat.DocumentElement[i].Input.DiviSionNumber,COne),
            '7',Msg);
        End;

     {изменена таблица авто-скидок}
     MyStr((GetSkidkaProz(L^.Dat.DocumentElement[i].BazKod,Itog)),CProz,CMantissaProz,Msg);
     DelSpace(msg);

     If (Abs(StrToreal(Msg)-StrToReal(L^.Dat.DocumentElement[i].Input.proz))>0.00009) Then ErrorStr:=ErrorStr+'8';

     {If (Msg<>L^.Dat.DocumentElement[i].Input.proz) Then ErrorStr:=ErrorStr+'8';}

     {изменена закупочная цена}
     If Glob.Status=DocNormal Then LogikZakupka:=True
     Else
      Begin
       {проверяем бала ли позиция в накладной}
       LogikZakupka:=Not FindMarket(L^.Dat.DocumentElement[i].BazKod,PrevMarket);
       If LogikZakupka Then{если позиции не было в накладной}
        Begin
         LogikZakupka:=True;
        End
       Else     {если позиция была в накладной}
        Begin
          If GetFullKolMArket(L^.Dat.DocumentElement[i].Bazkod,L)>
             GetFullKolMArket(L^.Dat.DocumentElement[i].Bazkod,PrevMarket) Then
Begin
     If (StrToReal(BakGetField(FZakupka,L^.Dat.MarketElement[i].BazKod,0)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.Zakupka)) Then
             Begin   {если количество новое изменилось в большую сторону}
                LogikZakupka:=FAlse;
                StopProcess:=True;
                FindError:=True;
                MessageBox(#3+'У сертификата с кодом ('+L^.Dat.DocumentElement[i].Bazkod+') изменилась закупочная цена! '+
                         'Редактирование этой позиции документа запрещено!',Nil,mfError+mfCancelButton);
                Goto 2;
             End{конец уловия если новое количество не изменилось}
              Else
               Begin{если новое количество не изменилось или стало меньше}
                LogikZakupka:=False;
               End;

     If (StrToReal(BakGetField(FZakupka2,L^.Dat.MarketElement[i].BazKod,0)))<>
        (StrToReal(L^.Dat.MarketElement[i].Input.Zakupka2)) Then
             Begin   {если количество новое изменилось в большую сторону}
                LogikZakupka:=FAlse;
                StopProcess:=True;
                FindError:=True;
                MessageBox(#3+'У сертификата с кодом ('+L^.Dat.DocumentElement[i].Bazkod+') изменилась закупочная цена 2! '+
                         'Редактирование этой позиции документа запрещено!',Nil,mfError+mfCancelButton);
                Goto 2;
             End{конец уловия если новое количество не изменилось}
              Else
               Begin{если новое количество не изменилось или стало меньше}
                LogikZakupka:=False;
               End;
End;
        End;{Else если позиция была в наклдной}

      End;{Status=DocEdit}

     {изменена закупочная цена}
     If LogikZakupka Then
     If (StrToReal(BakGetField(FZakupka,L^.Dat.DocumentElement[i].BazKod,0)))<>
        (StrToReal(L^.Dat.DocumentElement[i].Input.Zakupka)) Then
        Begin
         ErrorStr:=ErrorStr+'9';
         Msg:=BakGetField(FZakupka,L^.Dat.DocumentElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.DocumentElement[i].BazKod,IntToStr(L^.Dat.DocumentElement[i].Input.DiviSionNumber,COne),
            '9',Msg);
        End;

     If LogikZakupka Then
     If (StrToReal(BakGetField(FZakupka2,L^.Dat.DocumentElement[i].BazKod,0)))<>
        (StrToReal(L^.Dat.DocumentElement[i].Input.Zakupka2)) Then
        Begin
         ErrorStr:=ErrorStr+'A';
         Msg:=BakGetField(FZakupka2,L^.Dat.DocumentElement[i].BazKod,0);
         DelSpace(Msg);
         NetChangeProdaga(L^.Dat.DocumentElement[i].BazKod,IntToStr(L^.Dat.DocumentElement[i].Input.DiviSionNumber,COne),
            'A',Msg);
        End;
End;{InputZakaz<>1}


     If ErrorStr[0]<>#0 Then
      Begin
{наименование код n колич цена ндс нп скидка руч скидка авто errorstr}
       s:=GetIdField(FName,L^.Dat.DocumentElement[i].BazKod);
       DelSpaceRight(s);
       Format(s,CName);
       DelSpace(L^.Dat.DocumentElement[i].Input.Kol);
       Format(L^.Dat.DocumentElement[i].Input.Kol,CKol);
       DelSpace(L^.Dat.DocumentElement[i].Input.Zena);
       Format(L^.Dat.DocumentElement[i].Input.Zena,CZena);
       DelSpace(L^.Dat.DocumentElement[i].Input.NDS);
       Format(L^.Dat.DocumentElement[i].Input.NDS,CLitr);
       DelSpace(L^.Dat.DocumentElement[i].Input.SpecNalog);
       Format(L^.Dat.DocumentElement[i].Input.SpecNAlog,CLitr);
       DelSpace(L^.Dat.DocumentElement[i].Input.Skidka);
       Format(L^.Dat.DocumentElement[i].Input.Skidka,CZena);
       DelSpace(L^.Dat.DocumentElement[i].Input.Proz);
       Format(L^.Dat.DocumentElement[i].Input.Proz,CProz);
       DelSpace(L^.Dat.DocumentElement[i].Input.Zakupka);
       Format(L^.Dat.DocumentElement[i].Input.Zakupka,CZenaZ);
       DelSpace(L^.Dat.DocumentElement[i].Input.Zakupka2);
       Format(L^.Dat.DocumentElement[i].Input.Zakupka2,CZenaZ);
       s:=s+'│'+L^.Dat.DocumentElement[i].BazKod+'│'+IntToSTr(L^.Dat.DocumentElement[i].Input.DivisionNumber,COne)+'│'
          +L^.Dat.DocumentElement[i].Input.Kol+'│'+L^.Dat.DocumentElement[i].Input.Zena+'│'+
                L^.Dat.DocumentElement[i].Input.NDS+'│'+
       +L^.Dat.DocumentElement[i].Input.SpecNAlog+'│'+L^.Dat.DocumentElement[i].Input.Skidka+'│'+
       +L^.Dat.DocumentElement[i].Input.Proz+'│'+L^.Dat.DocumentElement[i].Input.Zakupka+'│'+
          +L^.Dat.DocumentElement[i].Input.Zakupka2+'│'+ErrorStr;
       Temp^.List^.Insert(NewStr(s));
       Temp^.SetRange(Temp^.List^.Count);
       DelSpace(L^.Dat.DocumentElement[i].Input.Kol);
       DelSpace(L^.Dat.DocumentElement[i].Input.Zakupka);
       DelSpace(L^.Dat.DocumentElement[i].Input.Zakupka2);
       DelSpace(L^.Dat.DocumentElement[i].Input.Zena);
       DelSpace(L^.Dat.DocumentElement[i].Input.NDS);
       DelSpace(L^.Dat.DocumentElement[i].Input.SpecNalog);
       DelSpace(L^.Dat.DocumentElement[i].Input.Skidka);
       DelSpace(L^.Dat.DocumentElement[i].Input.Proz);
       findError:=true;
       start:=false;
      End;
   End;
 end;{if}

If Not(FindError) Then
Begin
 Dispose(Temp,Done);
 Exit;
End;

2:UnLockAllPosition(LockBox);

If StopProcess Then
 Begin
  Dispose(Temp,Done);
  Start:=False;
  Exit;
 End;


NetBeep;
R.Assign(0, 3, 79, 22);
New(NetTestWindow, Init(R, 'Сетевое предупреждение'));
NetTestWindow^.Options := NetTestWindow^.Options or ofCenterX or ofCenterY;
NetTestWindow^.HelpCtx:=$E090;

R.Assign(78, 2, 79, 15);
Control := New(PScrollBar, Init(R));
NetTestWindow^.Insert(Control);

R.Assign(1, 2, 78, 15);
NetTestBox := New(PBox, Init(R, 1, PScrollbar(Control)));
NetTestBox^.NewList(New(PTextCollection, Init(0,1)));

If (Temp^.List^.Count)>0 Then
  For i:=0 To Temp^.List^.Count-1 Do
   Begin
    s:=Temp^.GetText(i,Temp^.List^.Count);
    NetTestBox^.List^.Insert(NewStr(s));
    NetTestBox^.SetRange(NetTestBox^.List^.Count);
   End;
Dispose(Temp,Done);

NetTestWindow^.Insert(NetTestBox);

R.Assign(1, 1, 77, 2);
NetTestWindow^.Insert(New(PLabel,
Init(R, 'Наименование товара         Код  N Колич.Цена лоб. НДС   НП    Скидка  Проц',
NetTestBox)));

R.Assign(1, 16, 21, 17);
Control := New(PColoredText, Init(R, 'Произошли изменения:', $7E));
NetTestWindow^.Insert(Control);

R.Assign(21, 16, 78, 18);
ControlError := New(PColoredText, Init(R,#3+'', $5f));
NetTestWindow^.Insert(ControlError);

R.Assign(21, 15, 28, 16);
Control := New(PColoredText, Init(R, 'Колич.:', $74));
nettestwindow^.Insert(Control);

R.Assign(28, 15, 33, 16);
Controlnetkol := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetkol);

R.Assign(37, 15, 42, 16);
Control := New(PColoredText, Init(R, 'Цена:', $74));
nettestwindow^.Insert(Control);

R.Assign(42, 15, 50, 16);
Controlnetzena := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetzena);

R.Assign(54, 15, 58, 16);
Control := New(PColoredText, Init(R, 'НДС:', $74));
nettestwindow^.Insert(Control);

R.Assign(58, 15, 63, 16);
Controlnetnds := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetnds);

R.Assign(67, 15, 70, 16);
Control := New(PColoredText, Init(R, 'НП:', $74));
nettestwindow^.Insert(Control);

R.Assign(70, 15, 75, 16);
Controlnetnalog := New(PColoredText, Init(R, #3+'', $7E));
nettestwindow^.Insert(Controlnetnalog);

R.Assign(4, 15, 16, 16);
Control := New(PColoredText, Init(R, 'На складе: ', $71));
nettestwindow^.Insert(Control);

NetTestWindow^.SelectNext(False);
PrevNet[0]:=#0;
DeskTop^.EXecView(NetTestWindow);
Dispose(Control,Done);
Dispose(NetTestWindow,Done);

1:

  If Prodaga^.List^.Count>0 Then
   Begin
    For i:=0 to prodaga^.list^.Count-1 Do
     Begin
     {колич}
      SSk:=Copy(Prodaga^.GetText(i,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1,CKol);
      DelSpace(sSk);

      If StrToInt(ssk)=0 Then
      Begin
       DelProdagaU(i);
       {
       Prodaga^.List^.AtFree(i);
       Prodaga^.SetRange(Prodaga^.List^.Count);
       If Prodaga^.Focused>0 Then Prodaga^.FocusItem(Prodaga^.Focused);
       If (Prodaga^.Focused>=Prodaga^.List^.Count) and(Prodaga^.Focused>0) Then
       Prodaga^.FocusItem(Prodaga^.Focused-1);
       }
       Goto 1;
      End;
     End;
   End;

  If ProdagaDoc^.List^.Count>0 Then
   Begin
    For i:=0 to ProdagaDoc^.list^.Count-1 Do
     Begin
     {колич}
      SSk:=Copy(ProdagaDoc^.GetText(i,ProdagaDoc^.List^.Count),1+COne+1+CName+1+CArtikul+1,CKol);
      DelSpace(sSk);

      If StrToInt(ssk)=0 Then
      Begin
       DelProdagaDoc(i);
       {
       ProdagaDoc^.List^.AtFree(i);
       ProdagaDoc^.SetRange(ProdagaDoc^.List^.Count);
       If ProdagaDoc^.Focused>0 Then ProdagaDoc^.FocusItem(ProdagaDoc^.Focused);
       If (ProdagaDoc^.Focused>=ProdagaDoc^.List^.Count) and(ProdagaDoc^.Focused>0) Then
       ProdagaDoc^.FocusItem(ProdagaDoc^.Focused-1);
       }
       Goto 1;
      End;
     End;
   End;

End;


Procedure TNetTestWindow.HandleEvent(Var Event:TEvent);
Var s: String;
Begin
inherited handleEvent(Event);
 if (NetTestBox^.State and sfFocused <> 0)  And(NetTestBox^.List<>Nil) And (NetTestBox^.List^.Count>=1)Then
  Begin
   s:=NetTestBox^.GetText(NetTestBox^.Focused,NetTestBox^.List^.Count);
   If s <> PrevNet Then
    Begin
     Refresh;
    End
  End;
End;


Destructor TNetTestWindow.Done;
Begin
ClearFind;
Dispose(ControlError,Done);
Dispose(ControlNetKol,Done);
Dispose(ControlNetZena,Done);
Dispose(ControlNetNDS,Done);
Dispose(ControlNetNalog,Done);
TDialog.Done;
End;

(*
Procedure TMarketWindow.Ini(s:TMyString;Regim:Word);
Label 1;
var
  R : TRect;
  c: Word;
  Control : PView;
  Dopolnenie,Ws,ws1 : TEnjoyStr;
  SFantomSkidka,SSkidka,SName,SFantomName,SFantomName2: String[CAll];
  SFantomZakupka,SZakupka,SFantomNDS,SNDS,SFantomNalog,SNalog,
  SFantomOZena,SOZena,SFAntomRZena,SRZena,SFAntomLitr,SLitr,
  SKol,SFantomInPAck,SInPack:String[CZena];
  Event : TEvent;
  SFantomVidNalog,VidNalog,SFantomVidNDS,VidNDS : Word;
  AddTovar : Boolean;
  SFantomOtd,SFantomKod,SFantomKol : ArtikulStr;
Begin
ClearFind;
SName:=Copy(S,1,CName);
SOtd:=Copy(s,1+CName+1+CArtikul+1,COne);
ActiveOtdel:=SOtd;

{Для новой структуры строки}
If Regim=0 Then SArtikul:=Copy(S,1+CName+1,CArtikul)
Else SArtikul:=Copy(S,1,CArtikul);


AddTovar:= GetRazdelStatus(Copy(SArtikul,1,CRAzdelKod));

If Regim=0 Then {если добавляем новое}
Begin
 If AddTovar Then
  Begin
   SFantomKod:=BAkGetField(FNsertif,SArtikul,0);
   SFAntomNAme:=GetIdField(FNAme,SArtikul);
   SFAntomNAme2:=GetIdField(FNAme2,SArtikul);
  End
  Else
   Begin
    SFantomKod:=BAkGetField(FNsertif,SArtikul,0);
    SFAntomNAme:=GetIdField(FNAme,SArtikul);
    SFAntomNAme2:=GetIdField(FNAme2,SArtikul);
   End;
End
Else
 Begin
  SFantomKod:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
              COne+1+CLitr+1+COne+1+CZena+1,CArtikul);
  DelSpace(SFantomKod);
  If SFantomKod[0]=#0 Then
   Begin
    SFantomKod:=Glob.NoSertifStr;
   End;
  SFantomKol:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
              COne+1+CLitr+1+COne+1+CZena+1+CArtikul+1,CKol);
  DelSpace(SFantomKol);
 End;



If (Selector<>0) Or
  ((Selector=0)And(OperatorSelector in [0,2])) Then
Begin
If GetIdMarket(Sartikul)=0 Then
  Begin
          Sound(100);
          DinfoMsg('Внимание! Товар с кодом '+SArtikul+' запрещено отгружать клиенту!',False);
          Delay(300);
          NoSound;
          ClearEvent(Event);
          repeat
                 Application^.GetEvent(Event);
          until (Event.What <> evNothing) And (Event.Command<>cmMenu);
          NoInfoMsg;
          ClearEvent(Event);
          Exit;
  End;

If SFantomKod<>Glob.NoSertifStr Then
If GetIdMarket(SFantomKod)=0 Then
  Begin
          Sound(100);
          DinfoMsg('Внимание! Товар с кодом '+SFantomKod+' запрещено отгружать клиенту!',False);
          Delay(300);
          NoSound;
          ClearEvent(Event);
          repeat
                 Application^.GetEvent(Event);
          until (Event.What <> evNothing) And (Event.Command<>cmMenu);
          NoInfoMsg;
          ClearEvent(Event);
          Exit;
  End;
End;

If(Selector in [5,6,7,8]) Then
Begin
If GetIdDebit(Sartikul)=0 Then
  Begin
     Sound(100);
     DinfoMsg('Внимание! Товар с кодом '+SArtikul+' запрещено отгружать с отсрочкой платежа!',False);
     Delay(300);
     NoSound;
     ClearEvent(Event);
     repeat
       Application^.GetEvent(Event);
     until (Event.What <> evNothing) And (Event.Command<>cmMenu);
     NoInfoMsg;
     ClearEvent(Event);
     Exit;
  End;
End;


SLitr:=GetIdField(FLitr,SArtikul);
SInPack:=GetIdField(FINPack,SArtikul);
SKol:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CInPack+1,CKol);
SNalog:=GetIdField(FNalog,SArtikul);
SNDS:=GetIdField(FNDS,SArtikul);
VidNalog:=StrToInt(GetIdField(FVidNalog,SArtikul));
VidNDS:=StrToInt(GetIdField(FVidNDS,SArtikul));
DelSpace(SNalog);
DelSpace(SNDS);


Case Regim Of
0:Begin
  El.Pack:=0;
  PrevKolPack:=El.Pack;
  El.Kol:=GetIdField(FInPack,SArtikul);
  If Status = DocNormal Then
  If StrToInt(El.Kol)>StrToInt(BakGetField(FDiv,SArtikul,StrToInt(SOtd))) Then El.Kol:=BakGetField
  (FDiv,SArtikul,StrToInt(SOtd))
  Else
  If StrToInt(El.Kol)>StrToInt(BakGetField(FDiv,SArtikul,StrToInt(SOtd))) Then El.Kol:=SKol;
  DelSpace(El.kol);
  El.Skidka[0]:=#0;
  SRZena:=BakGetField(FRZena,SArtikul,0);
  Format(SRZena,CZena);
  SOZena:=BakGetField(FOZena,SArtikul,0);
  Format(SOZena,CZena);
  SZakupka:=BakGetField(FZakupka,SArtikul,0);
  Format(SZakupka,CZena);
  End;
1:Begin
{Для новой структуры строки}
    SArtikul:=Copy(S,1,CArtikul);
    SName:=Copy(S,1+CArtikul+1,CName);
    El.Kol:=Copy(s,1+CName+1+CArtikul+1+COne+1,CKol);
    El.SKidka:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1,CZena);
    SOtd:=Copy(s,1+CName+1+CArtikul+1,COne);
    ActiveOtdel:=SOtd;
    sskidka:=CalcPack(SArtikul,El.Kol);
    System.Delete(sskidka,Pos('+',Sskidka),Ord(S[0]));
    If (StrToInt(sskidka)-1) >= 0 Then
    El.Pack:=StrToInt(sskidka)-1
    Else El.Pack:=StrToInt(sskidka);
    If El.PAck>9 Then El.Pack:=9;
    PrevKolPack:=El.Pack;
    SRZena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1,CZena);
    SOZena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1,CZena);
    SNalog:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1,CLitr);
    VidNalog:=StrToInt(Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1,
              COne));
    SNDS  :=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+COne+1,
    CLitr);

    VidNDS:=StrToInt(Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
    COne+1+CLitr+1,COne));

    SZakupka:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
              COne+1+CLitr+1+COne+1,CZena);


    DelSpace(SNAlog);
    DelSpace(SNDS);


    DelSpace(El.Kol);
    DelSpace(El.Skidka);
  End;
  Else;
  End;

ClearFind;

Dopolnenie:=GetIdField(Fname2,Sartikul);
DelSpaceRight(Dopolnenie);

SZakupka:=RealToStr(StrToReal(SZakupka),CZena,CMantissa);
DelSpace(SZakupka);
Format(SZakupka,CZena);

1:
AInfo('Читаю информацию о товаре...');
R.Assign(2, 13, 78, 21);
New(MarketWin, Init(R, 'Продажа наименования товара - отделение ['+SOtd+']'));
MarketWin^.Options := MarketWin^.Options or ofCenterX;
MarketWin^.Palette := dpCyanDialog;
MarketWin^.HelpCtx := $E199;

{R.Assign(1, 3, 37, 5);}
R.Assign(1, 4, 44, 6);
Pack := New(PRadioButtons, Init(R,
  NewSItem('~1~',
  NewSItem('~2~',
  NewSItem('~3~',
  NewSItem('~4~',
  NewSItem('~5~',
  NewSItem('~6~',
  NewSItem('~7~',
  NewSItem('~8~',
  NewSItem('~9~',
  NewSItem('1~0~',
  NewSItem('~А~', Nil)))))))))))));


MarketWin^.Insert(Pack);

  R.Assign(1, 3, 25, 4);
  MarketWin^.Insert(New(PLabel, Init(R, 'Количество ~у~паковок:', Pack)));


R.Assign(45, 4, 54, 5);
Control := New(PColoredText, Init(R, 'Упаковок:', $3E));
MarketWin^.Insert(Control);


R.Assign(54, 4, 63, 5);
ControlPack := New(PStaticText, Init(R, #3+'0+0'));
MarketWin^.Insert(ControlPack);


R.Assign(50, 5, 57, 6);
ControlKol := New(PInputLine, Init(R, CKol));
MarketWin^.Insert(ControlKol);
  PInputLine(ControlKol)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(42, 5, 50, 6);
  MarketWin^.Insert(New(PLabel, Init(R, 'К~о~лич.:', ControlKol)));

R.Assign(2, 1, 74, 2);
Control := New(PStaticText, Init(R, 'Наименование:'+SName+' Код:'+SArtikul+' Литраж:'+Slitr+' Фас:'+SInPack));
MarketWin^.Insert(Control);


If Dopolnenie[0]<>#0 Then
Begin
R.Assign(2, 2, 74, 3);
Control := New(PStaticText, Init(R, '             '+Dopolnenie));
MarketWin^.Insert(Control);
End;



{If FindParam('/EZ') Or (StrToInt(CurrentPassword)=0) Then
Begin}
DelSpace(SZakupka);
ViewZakupka:=False;
R.Assign(65, 4, 75, 5);
ControlZakupka:=New(PColoredText, Init(R, #3+SZakupka, $33));
MarketWin^.Insert(ControlZakupka);
Format(SZakupka,CZena);
{End;}



If Skidka=1 Then
Begin
EnableCommands([cmLocalSkidka,cmLocalNazenka]);


R.Assign(65, 5, 75, 6);
ControlNZena := New(PInputLine, Init(R, CZena));
MarketWin^.Insert(ControlNZena);
  PInputLine(ControlNZena)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  If Not FindParam('/EZ') And Not(StrToInt(CurrentPassword)=0) Then
  ControlNZena^.Options := ControlNZena^.Options and not ofSelectable;

  R.Assign(57, 5, 64, 6);
  MarketWin^.Insert(New(PLabel, Init(R, 'Цена:', ControlNZena)));

R.Assign(65, 6, 75, 7);
Control1Skidka := New(PInputLine, Init(R, CZena));
MarketWin^.Insert(Control1Skidka);
  PInputLine(Control1Skidka)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));

  R.Assign(57, 6, 65, 7);
  MarketWin^.Insert(New(PLabel, Init(R, '~С~кидка:', Control1Skidka)));

MyStr(StrToReal(SRZena)-StrToReal(El.Skidka),CZena,CMantissa,El.NZena);
DelSpace(El.NZena);

End
Else
DisableCommands([cmLocalSkidka,cmLocalNazenka]);

If Status=DocEdit Then
Begin
Str((StrToInt(BakGetField(FKol,SArtikul,0))+GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket)):CKol,ws1);
Str((StrToInt(BakGetField(FDiv,SArtikul,StrToInt(SOtd)))+GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket)):CKol,ws);

ws:='На складе:'+ws1+' В отделении:'+ws+' Цена:';
End
Else
ws:='На складе:'+BakGetField(FKol,SArtikul,0)+' В отделении:'+BakGetField(FDiv,Sartikul,StrToInt(SOtd))+' Цена:';

If Selector in [0,1] Then ws:=ws+SRZena
Else ws:=ws+SOZena;

R.Assign(23, 3, 75, 4);
Control := New(PColoredText, Init(R,ws, $31));
MarketWin^.Insert(Control);

If Status=DocNormal Then ws1:=BakGetField(FKol,SArtikul,0);
DelSpace(Ws1);
ws1:=CalcPack(SArtikul,ws1);
DelSpace(Ws1);
R.Assign(1, 7, Length(' На складе имеется: '+ws1+' упаковок(ки)'+' Ставка НП:'+SNalog+' Ставка НДС:'+SNDS)+2, 8);
Control := New(PColoredText, Init(R,' На складе имеется: '+ws1+' упаковок(ки)'+' Ставка НП:'+SNalog+' Ставка НДС:'+SNDS, $31));
Control^.Options := Control^.Options or ofCenterX;
MarketWin^.Insert(Control);

MarketWin^.SelectNext(False);
MarketWin^.SetData(El);

DrawPack;

NoInfo;

PrevKol[0]:=#0;

c:=Desktop^.ExecView(MarketWin);

If c<>cmCancel Then
 Begin
  MarketWin^.GetData(El);
  Dispose(Control,Done);
  Dispose(MarketWin,Done);
  If (El.Kol[0]=#0) Or (StrTOInt(El.Kol)=0) Then
   Begin
    MessageBox(#3+NullKol,nil, mfError + mfCancelButton);
    GoTo 1;
   End;
  If Status=DocNormal Then
   Begin
  If (StrToInt(BakGetField(FDiv,SArtikul,StrToInt(SOtd)))<(StrTOInt(El.Kol))) Then
   Begin
     MessageBox(^M+'На складе (отделение ['+SOtd+']) отсутствует такое количество товара ! ',nil, mfError + mfCancelButton);
     GoTo 1;
   End;
   End;
  If Status=DocEdit Then
  Begin
If (StrToInt(BakGetField
(FDiv,SArtikul,StrToInt(SOtd)))-StrTOInt(El.Kol)+GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket))<0 Then
   Begin
     MessageBox(^M+'На складе (отделение ['+SOtd+']) отсутствует такое количество товара ! ',nil, mfError + mfCancelButton);
     GoTo 1;
   End;
  End;

  if skidka=1 then{ручной режим контроль себестоимости}
  If (StrToReal(SRZena)-StrTOReal(El.Skidka))<(StrToReal(SZakupka){(StrToReal(GetOZena(SArtikul))}) Then
   Begin
    SpecialBeep;
    MessageBox(^M+'Внимание товар продается ниже себестоимости!',nil, mfError + mfCancelButton);
   End;



  If Selector in [0,1] Then
  Begin
  If (StrTOReal(El.Skidka))>(StrtoReal(SRZena){(StrToReal(GetRZena(SArtikul))}) Then
   Begin
      MessageBox(^M+'Скидка превышает розничную цену !'^M+
                 'Повторите ввод ! ',nil, mfError + mfCancelButton);
      GoTo 1;
   End;
  If StrToreal(El.Skidka)>=StrToReal(SRZena)/2 Then
   Begin
    If Not(Password(4)) Then Goto 1;
   End;
  End
   Else
    Begin
     If (StrTOReal(El.Skidka))>(StrToReal(SOZena){(StrToReal(GetOZena(SArtikul))}) Then
      Begin
       MessageBox(^M+'Скидка превышает оптовую цену!'^M+
                'Повторите ввод ! ',nil, mfError + mfCancelButton);
       GoTo 1;
      End;
  If StrToreal(El.Skidka)>=StrToReal(SRZena)/2 Then
   Begin
    If Not(Password(4)) Then Goto 1;
   End;
    End;




   MyStr(StrToReal(El.Skidka),CZena,CMantissa,El.Skidka);
   s:=SArtikul+'│'+SName+'│'+SOtd+'│';
   With El Do
   Begin
    Str(StrToInt(Kol):CKol,Kol);
    Format(Kol,CKol);
    MyStr(StrToReal(Skidka),CZena,CMAntissa,Skidka);
    Format(Skidka,CZena);

   If (Selector in [0,1]) Then
    MyStr(StrToReal(SRZena),CZena,CMantissa,ws)
   Else MyStr(StrToReal(SOZena),CZena,CMantissa,ws);

    Format(ws,CZena);
    Format(slitr,CLitr);
    Format(sNalog,CLitr);
    Format(sNDS,CLitr);

    s:=s+Kol+'│'+SLitr+'│'+ws+'│'+Skidka+'│';
    {Имя код отд кол литраж цена скидка сумма цена Р Цена О Налог ВидНП НДС ВидНДС Закупка}
   If (Selector in [0,1]) Then MyStr((StrToReal(SRZena)*StrToInt(El.Kol)),CInputIZena,CMantissa,ws)
   Else
   MyStr((StrToReal(SOZena)*StrToInt(El.Kol)),CInputIZena,CMantissa,ws);
    DelSpace(ws);
    Format(Ws,CInputIZena);
    Format(SZakupka,CZena);
    s:=s+ws+'│'+SRZena+'│'+SOZena+'│'+SNalog+'│'+IntToStr(VidNalog,COne)+
    '│'+SNDS+'│'+IntToStr(VidNDS,COne)+'│'+SZakupka;
   End;

  If Regim=1 Then
    Begin
     Regim:=Prodaga^.Focused;
     Prodaga^.List^.AtFree(Prodaga^.Focused);
     Prodaga^.SetRange(Prodaga^.List^.Count);
    End;

   Prodaga^.List^.Insert(NewStr(S));
   Prodaga^.SetRange(Prodaga^.List^.Count);
   Prodaga^.FocusItem(Location(Prodaga,SArtikul,True));
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(MarketWin,Done);
 End;
End;

*)

Procedure DrawPack;
Var s: String[CPack];
    R : TRect;
Begin
If Not(AddSertif) Then
Begin
    ControlKol^.GetData(El.Kol);
    If El.Kol<>PrevKol Then
    Begin
    PrevKol:=El.Kol;
    s:=CalcPack(sArtikul,El.Kol);
    DelSpace(s);
    Dispose(ControlPack,Done);
    R.Assign(54, 4, 63, 5);
    ControlPack:=New(PStaticText, Init(R, #3+s));
    MarketWin^.Insert(ControlPack);
    End;
End;
End;


Procedure DrawKol(VAr Show:Boolean;Var Kol:ArtikulStr);
Var s: String[CKol];
    R : TRect;
    l : LongInt;
    TestKol :String[CKol];
Begin
If Not(AddSertif) Then
Begin
 Show:=FAlse;
 Pack^.GetData(El.Pack);
 If El.PAck<>10 Then
Begin

If El.Pack<>PrevKolPack Then
 Begin
  s:=GetIdField(FINPack,SArtikul);
  Str(StrToInt(s)*(El.Pack+1):CKol,s);
  DelSpace(s);
  Kol :=S;

  TestKol:=GetSkladKolWithUshetBron(SArtikul,StrToInt(ActiveOtdel));
  {BakGetField(FDiv,SArtikul,StrToInt(ActiveOtdel));!!!}

  If Glob.Status=DocNormal Then
  Begin
  If StrToInt(s)>StrToInt(TestKol) Then
  Begin
   Show:=True;
   DelSpace(TestKol);
   s:=TestKol;
   DelSpace(s);
  End;
  End;

  If Glob.Status=DocEdit Then
  Begin
  If StrToInt(s)>StrToInt(TestKol){+GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket)!!!} Then
  Begin
   Show:=True;
   s:=IntToStr(STrToInt(TestKol){+GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket)!!!},CKol);
   DelSpace(s);
  End;
  End;



  ControlKol^.SetData(s);
  PrevKolPack:=El.Pack;
 End;
End{если не нажата буква ~А~}
 Else
  Begin
   If Glob.Status=DocNormal Then
   TestKol:=GetSkladKolWithUshetBron(SArtikul,StrToInt(ActiveOtdel)){!!!BakGetField(FDiv,SArtikul,StrToInt(ActiveOtdel))}
   Else
   TestKol:={IntToStr(StrToInt(BakGetField(FDiv,SArtikul,StrToInt(ActiveOtdel)))+
            GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket),CKol)}
   GetSkladKolWithUshetBron(SArtikul,StrToInt(ActiveOtdel));
   DelSpace(TestKol);
   ControlKol^.SetData(TestKol);
   PrevKolPack:=El.Pack;
  End;
End;
End;




{Procedure TMarketWindow.Ini(s:TMyString;Regim:Word);}

Function FindPrevOtgruzkaProc(SFantomArtikul:ArtikulStr;Var FindPrevOtgruzkaDoc,FindPrevOtgruzkaDate,
FindPrevOtgruzkaKol:TDateString):Boolean;
Var Posit:Word;
    s : String;
    SDoc,SDAte,SKol : TDateString;
Begin
FindPrevOtgruzkaProc:=False;
FindPrevOtgruzkaDoc[0]:=#0;
FindPrevOtgruzkaDate[0]:=#0;
FindPrevOtgruzkaKol[0]:=#0;
If Not TestElement(SFantomArtikul,DocumentSList) Then
Begin
  FindPrevOtgruzkaProc:=True;
  Posit:=Location(DocumentSList,SFantomArtikul,False);
  s:=DocumentSList^.GetText(Posit,DocumentSList^.List^.Count);
  SDoc:=Copy(s,1+1+CArtikul+1+CKol+1,CDate{CDocNumer});
  DelSpace(SDoc);
  SDate:=Copy(s,1+1+CArtikul+1+CKol+1+CDAte{CDocNumer}+1,CDate);
  DelSpace(SDate);
  SKol:=Copy(s,1+1+CArtikul+1,CKol);
  DelSpace(SKol);
  FindPrevOtgruzkaDate:=SDate;
  FindPrevOtgruzkaDoc:={IntToStr(StrToInt(}SDoc;{),CDocNumer);}
  DelSpaceRight(FindPrevOtgruzkaDoc);
  FindPrevOtgruzkaKol:=IntToStr(StrToInt(SKol),CKol);
End;
End;


Procedure Signal;
VAr Event : TEvent;
Begin
          Sound(100);
          DinfoMsg('Внимание! Сертификат '+SFantomArtikul+' уже присутствует в документе. Отделение '+ActiveFAntomOtdel,False);
          Delay(300);
          NoSound;
          Application^.ClearEvent(Event);
          repeat
           Application^.GetEvent(Event);
          until (Event.What <> evNothing) And (Event.Command<>cmMenu);
          NoInfoMsg;
          Application^.ClearEvent(Event);
End;


Procedure LineMsg(s:String);
VAr Event : TEvent;
Begin
     Sound(100);
     DinfoMsg(S,False);
     Delay(300);
     NoSound;
     Application^.ClearEvent(Event);
     repeat
       Application^.GetEvent(Event);
     until (Event.What <> evNothing) And (Event.Command<>cmMenu);
     NoInfoMsg;
     Application^.ClearEvent(Event);
End;


{$IFDEF DPMI}
Procedure TMarketWindow.Ini(s:String;Regim:Word;DisableTovar,DisableDocument:Boolean);
Label 1;
var
  R : TRect;
  c: Word;
  Control : PView;
  Dopolnenie,Ws,ws1,ws2 : String;
  SAkzis,SVirabotano,SGodnost,PrevEkzemplar,SSrok,SVidan,
  SFantomSkidka,SSkidka,SName,SFirma,SFantomName,SFantomName2: String[CAll];
  SFantomNDS,SNDS,SFantomNalog,SNalog,
  SFantomOZena,SOZena,SFAntomRZena,SRZena,SFAntomLitr,SLitr,
  SKol,SFantomInPAck,SInPack,SInPack2:String[CZena];
  SFantomZakupka,SZakupka ,SAkzisSbor,SZenaMArki,
  SFantomZakupka2,SZakupka2 : String[CZenaZ];
  SSRegion : AllStr;
  SFantom : String;
  Event : TEvent;
  SFantomVidNalog,VidNalog,SFantomVidNDS,VidNDS : Word;
  Position,localregim : Word;
  Vid,Count:Word;
  ResKol,PrevFantomKol : String[CKol];
  FullFantomKol,SFantomOtd,SFantomKol,
  MaxKol,MaxKol1,MaxFantomKol : ArtikulStr;
  DisableFantom:Boolean;
  BBB : PBazType;
  Skl : PSkladType;
  FindPrevOtgruzkaDoc:TDateString;
  NDS,Sr1,Sr2 : TDAteString;
  FindPrevOtgruzkaKol:TDateString;
  FindPrevOtgruzkaDate:TDateString;
  Color,SRegion : Word;
  Marking : Boolean;
  Lobovaya : Real;
  ck,ReturnZena,BakKol,BakFantomKol,SMin : TDAteString;


Procedure InsertLabel;
Var SA : ArtikulStr;
    FClientProz : ArtikulStr;
    SZena,SZakupka1 : AllStr;
    RM : Word;

Begin
SMin[0]:=#0;
SClientMinZena[0]:=#0;
If OperatorSelector in [0,2] Then
If Skidka=1 Then
 Begin
  If ControlPricePosition in [0] Then
   Begin
    PStaticText(ControlClientLabel)^.GetText(S);
    System.Delete(S,Pos(#3,S),1);
    Ck:=Copy(s,1+CClient+1,CClientKod);

    Vid:=StrToInt(GetClientField(FDisableControlZeni,ck,OperatorSelector));

  If Vid in [0,1,2] Then
   Begin
    SA:=CalcMainKod(SArtikul);
    {MemC(SA);}
    SMin:=GetMinRange(Vid,SA,ListRange);
    DelSpace(SMin);

    If Length(SMin)>0 Then
    R.Assign(65, 0, 66+Length(SMin)+2, 1)
    Else
    R.Assign(65, 0, 65, 1);
    Control := New(PColoredText, Init(R, #3+SMin, $CE));
    MarketWin^.Insert(Control);

    R.Assign(61, 0, 65, 1);
    Control := New(PStaticText, Init(R, 'Min:'));
    MarketWin^.Insert(Control);
   End;{Vid}
   End;{ControlPricePosition}

 {если включен контроль наценки от закупки}

 If GetRazdelLitr(Copy(SA,1,CRAzdelKod))=1 Then
 If DisableControlMinNazCl=0 Then
  Begin
    PStaticText(ControlClientLabel)^.GetText(S);
    System.Delete(S,Pos(#3,S),1);
    Ck:=Copy(s,1+CClient+1,CClientKod);

   If StrToInt(GetClientField(FDisableControlNaz,ck,OperatorSelector))=0 Then
   Begin

   {лезем в карточку клиента и достаем минимальный процент наценки}
    FClientProz:=GetClientField(FMinimalProz,ck,OperatorSelector);
   {лезем в карточку товара и вычисляем закупочную цену}
    SZakupka1:=BakGetField(FZakupka,SArtikul,0);

    RM:=StrToInt(BakGetField(FRegionMarka,SArtikul,0));


  If RM=1 Then
   Begin
    MyStr(StrToReal(SZakupka1)+StrToReal(BakGetField(FZenaMarki,SArtikul,0))+
    StrToReal(BakGetField(FAkzisSbor,SArtikul,0)),CZenaZ,CMantissaZ,SZakupka1);
   End;



   {просчитываем минимальную цену отгрузки и выводим в Label}
    MyStr(StrToReal(SZakupka1)*(1+StrToReal(FClientProz)/100),CZena,CMantissa,SZena);
    DelSpace(SZena);

    R.Assign(72, 0, 72+Length(SZena)+2, 1);
    Control := New(PColoredText, Init(R, #3+SZena, $CE));
    MarketWin^.Insert(Control);
    SClientMinZena:=SZena;

    If SMin[0]<>#0 Then SClientMinZena:=SMin;

   End;
  End;

 End;{Skidka=1}


End;


Procedure FormList;
Var ccc : Word;
Begin
 If (Prodaga^.List^.Count>0) Then
 Begin
 For CCC:=0 To Prodaga^.List^.Count-1 Do
  Begin
   S:=Prodaga^.GetText(CCC,Prodaga^.List^.Count);
   If StrToInt(Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
              COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1+CZenaZ+1,CArtikul))=StrToInt(SFantomArtikul) Then
    Begin
     {код}
     wS2:=Copy(s,1,CArtikul);
     {имя}
     ws1:=GetIdField(FFFName,ws2);
     Format(ws1,CNAme+1+CName);
     {отделение}
     wS:=Copy(s,1+CName+1+CArtikul+1,COne);
     {Количество}
     s:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
     COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1+CZenaZ+1+CArtikul+1,CKol);
     s:=IntToStr(StrToInt(s),CKOl);
     RFormat(s,CKOl);
     {If StrToInt(s)>0 Then}
     Begin
     S:=wS1+'│'+ws2+'│'+wS+'│'+s;
     ControlBox^.List^.Insert(NewStr(S));
     ControlBox^.SetRange(ControlBox^.List^.Count);
     End;
    End;
  End;
 End
  Else
   Begin
     {ControlBox^.List^.Insert(NewStr('?????│НЕТ СВЯЗЕЙ С ТОВАРОМ'));}
     ControlBox^.SetRange(ControlBox^.List^.Count);
     ControlBox^.Options := ControlBox^.Options and not ofSelectable;
   End;

End;



Procedure Chast;
Begin

If Not AddSertif Then
Begin
New(BBB,Init);
GetBazElement(SArtikul,BBB^.Dat);
SLitr:=BBB^.Dat.Litr{GetIdField(FLitr,SArtikul)};
SInPack:=BBB^.Dat.InPack{GetIdField(FINPack,SArtikul)};
SInPack2:=BBB^.Dat.InPack2{GetIdField(FINPack,SArtikul)};
SKol:=Copy(s,1+CName+1+CArtikul+1+COne+1+CKol+1+CInPack+1,CKol);
SNalog:=BBB^.Dat.Nalog{GetIdField(FNalog,SArtikul)};
SNDS:=BBB^.Dat.NDS{GetIdField(FNDS,SArtikul)};
VidNalog:={StrToInt(}BBB^.Dat.VidNalog{GetIdField(FVidNalog,SArtikul))};
VidNDS:={StrToInt(GetIdField(FVidNDS,SArtikul))}BBB^.Dat.VidNDS;
DelSpace(SNalog);
DelSpace(SNDS);
Dispose(BBB,Done);


New(Skl,Init);
Skl^.Dat.BazKod:=SArtikul;
GetSkladRecord(Skl);

GetOLD_OSD(OSDList,Skl);

SRegion:=Skl^.Dat.Input.RegionMarka;
SAkzisSbor:=Skl^.Dat.Input.AkzisSbor;
SZenaMArki:=Skl^.Dat.Input.ZenaMarki;

SAkzis:=GetMarkaField(FMarka,Skl^.Dat.Input.Marka)+' ['+Skl^.Dat.Input.Marka+']';
SGodnost:=Skl^.Dat.Input.Godnost{BakGetField(FGodnost,SArtikul,0)};
SVirabotano:=Skl^.Dat.Input.Virabotano;

Dispose(Skl,Done);

New(BBB,Init);
GetBazElement(SFantomArtikul,BBB^.Dat);
SFirma:=GetFirmaPostField(FFirmaPost,BBB^.Dat.FirmaPostKod);
SFantomLitr:=BBB^.Dat.Litr{GetIdField(FLitr,SFantomArtikul)};
SFantomInPack:=BBB^.Dat.InPack{GetIdField(FINPack,SFantomArtikul)};
SFantomNalog:=BBB^.Dat.Nalog{GetIdField(FNalog,SFantomArtikul)};
SFantomNDS:=BBB^.Dat.NDS{GetIdField(FNDS,SFantomArtikul)};
SFantomVidNalog:=BBB^.Dat.VidNalog{StrToInt(GetIdField(FVidNalog,SFantomArtikul))};
SFantomVidNDS:=BBB^.Dat.VidNDS{StrToInt(GetIdField(FVidNDS,SFantomArtikul))};
DelSpace(SFantomNalog);
DelSpace(SFantomNDS);
Dispose(BBB,Done);

DelSpaceRight(SAkzis);
DelSpaceRight(SFirma);
DelSpaceRight(SVirabotano);
DelSpaceRight(SGodnost);
End
 Else
Begin
 SAkzis[0]:=#0;
 SFirma[0]:=#0;
 SVirabotano[0]:=#0;
 SGodnost[0]:=#0;
 SRZena[0]:=#0;
 SOZena[0]:=#0;
 SZakupka[0]:=#0;
 SZakupka2[0]:=#0;
 SNalog[0]:=#0;
 SNDS[0]:=#0;
 SInPack[0]:=#0;
 SInPack2[0]:=#0;
 SLitr[0]:=#0;
 SKol[0]:=#0;
 SAkzisSbor[0]:=#0;
 SZenaMArki[0]:=#0;

New(BBB,Init);
GetBazElement(SFantomArtikul,BBB^.Dat);

SFantomLitr:=BBB^.Dat.Litr{GetIdField(FLitr,SFantomArtikul)};
SFantomInPack:=BBB^.Dat.InPack{GetIdField(FINPack,SFantomArtikul)};
SFantomNalog:=BBB^.Dat.Nalog{GetIdField(FNalog,SFantomArtikul)};
SFantomNDS:=BBB^.Dat.NDS{GetIdField(FNDS,SFantomArtikul)};
SFantomVidNalog:=BBB^.Dat.VidNalog{StrToInt(GetIdField(FVidNalog,SFantomArtikul))};
SFantomVidNDS:=BBB^.Dat.VidNDS{StrToInt(GetIdField(FVidNDS,SFantomArtikul))};
Dispose(BBB,Done);
DelSpace(SFantomNalog);
DelSpace(SFantomNDS);
End;
End;


Begin
ClearFind;
SMin[0]:=#0;
SName:=Copy(S,1,CName);
SOtd:=Copy(s,1+CName+1+CArtikul+1,COne);
ActiveOtdel:=SOtd;

If Not TestOtdel(StrToInt(SOtd)) Then
  Begin
          LineMsg('Внимание! Товар с отделения '+SOtd+' запрещен к отгрузке!');
          {
          Sound(100);
          DinfoMsg('Внимание! Товар с отделения '+SOtd+' запрещен к отгрузке!',False);
          Delay(300);
          NoSound;
          ClearEvent(Event);
          repeat
           Application^.GetEvent(Event);
          until (Event.What <> evNothing) And (Event.Command<>cmMenu);
          NoInfoMsg;
          ClearEvent(Event);
          }
          Exit;
  End;

SFantomArtikul[0]:=#0;
SFantomNAme[0]:=#0;
SFantomNAme2[0]:=#0;

MaxKol[0]:=#0;
MaxFantomKol[0]:=#0;

If Regim=0 Then {добавляем новую}
  Begin
   SArtikul:=Copy(S,1+CName+1,CArtikul);
   If AddSertif Then
    Begin
     SFantomArtikul:=SArtikul;
     SArtikul[0]:=#0;
     ActiveFantomOtdel:=SOtd;
     If Not TestFAntomOtdel(s,SFAntomArtikul,ActiveFantomOtdel) Then
      Begin
          Signal;
          Exit;
      End;
    End
   Else
   Begin
    SFantomArtikul:=BakGetField(FNSertif,SArtikul,0);
    ActiveFantomOtdel:=GetOtdelSertif(SFantomArtikul);
   End;

   New(BBB,Init);
   GetBazElement(SFantomArtikul,BBB^.Dat);
   SFantomNAme:=BBB^.Dat.Name{GetIdField(FNAme,SFantomArtikul)};
   SFantomNAme2:=BBB^.Dat.Name2{GetIdField(FNAme2,SFantomArtikul)};
   DelSpaceRight(SFantomNAme);
   DelSpaceRight(SFantomNAme2);
   SVidan:=GetKSertifField(FKSertif,BBB^.Dat.KSertif){GetIdField(FKtoSertif,SFantomArtikul)}+
   ' ['+BBB^.Dat.KSertif+']';
   DelSpaceRight(SVidan);
   SSrok :=BBB^.Dat.DSertif{GetIdField(FDateSertif,SFantomArtikul)};
   DelSpaceRight(SSrok);
   Dispose(BBB,Done);
  End
Else
  Begin
   SArtikul:=Copy(s,1,CArtikul);
   If AddSertif Then
    Begin
     SFantomArtikul:=SArtikul;
     SArtikul[0]:=#0;
     ActiveFantomOtdel:=SOtd;
     If Not TestFAntomOtdel(s,SFAntomArtikul,ActiveFantomOtdel) Then
      Begin
          Signal;
          Exit;
      End;

    End
   Else
    Begin
     SFantomArtikul:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+
     CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1+CZenaZ+1,CArtikul);

     DeterminateOtdelSertif(s,SFantomArtikul,ActiveFAntomOtdel);

    End;

   {BakGetField(FNSertif,SArtikul,0)};
   New(BBB,Init);
   GetBazElement(SFantomArtikul,BBB^.Dat);
   SFantomNAme:=BBB^.Dat.Name{GetIdField(FNAme,SFantomArtikul)};
   SFantomNAme2:=BBB^.Dat.Name2{GetIdField(FNAme2,SFantomArtikul)};
   DelSpaceRight(SFantomNAme);
   DelSpaceRight(SFantomNAme2);
   SVidan:=BBB^.Dat.KSertif{GetIdField(FKtoSertif,SFantomArtikul)};
   DelSpaceRight(SVidan);
   SSrok :=BBB^.Dat.DSertif{GetIdField(FDateSertif,SFantomArtikul)};
   DelSpaceRight(SSrok);
   Dispose(BBB,Done);
  End;

PrevFantomKol[0]:=#0;




If StrToInt(GetKolDocument(SFantomArtikul))>0 Then LocalRegim:=1{редактирование}
Else LocalRegim:=0; {выписка новой позиции}


{вставить поцедуру проверки наличия идентифицированного аналога}
{$IFDEF Pharm}
If Not(AddSertif) And (LocalRegim=0) Then
Begin
 If (SFAntomArtikul=NoSertifStr) Or (Pos('*',
 GetIdField(FFFNAme,SFAntomArtikul))>0) Then{если позиция не идентифицирована}
  Begin
   If FindZamena(SArtikul,SOtd) Then
    Begin
     Exit;
    End;
  End;
End;
{$ENDIF}


DisableFantom:=False;

If LocalRegim=0 Then
 Begin
  If Glob.Status=DocNormal Then
  Begin
  If {BakGetField(FDiv,SFantomArtikul,1)!!!}
  {???}
  StrToInt(GetSkladKolWithUshetBron(SFantomArtikul,StrToInt(ActiveFantomOtdel)))<1 Then DisableFantom:=True;
  End
   Else
    Begin
  If (StrToInt({BakGetField(FDiv,SFantomArtikul,1)!!!}
{???}
      GetSkladKolWithUshetBron(SFantomArtikul,StrToInt(ActiveFantomOtdel))){+GetKolMarket(SFantomArtikul,1,PrevMarket)!!!})
  <1 Then DisableFantom:=True;
    End;
{???}
   MaxFantomKol := GetSkladKolWithUshetBron(SFantomArtikul,StrToInt(ActiveFantomOtdel));
   If StrToInt(MaxFantomKol)<0 Then MaxFantomKol[0]:=#0;
 End;

{If Status=DocEdit Then DisableDocument:=TestMarket(sFantomArtikul,PrevMarket,0,True);}


{Для новой структуры строки}
{
0 - добавлем сертификат (без товара)
1 - добавлем наименование с сертификатом
2 - редактируем сертификат (без товара)
3 - редактируем товар с сертификатом
}
(*
If Regim=0 Then {добавляем новую}
 Begin
  SArtikul:=Copy(S,1+CName+1,CArtikul);
  If GetRazdelStatus(SArtikul) Then {если добавляем сертификат}
   Begin
    SFantomKod:=SArtikul;
    Podregim:=0;
    Warning:='Нет сертификата !';
   End{}
   Else
    Begin {если добавляем товар}
     SFantomKod:=GetIDField(FNSertif,SArtikul);
     Podregim:=1;
     If SFantomKod=Glob.NoSertifStr Then
         Begin
          Warning:='Нет сертификата !';
      End;
    End;
  SFantomNAme:=GetIdField(FNAme,SFantomKod);
  SFantomNAme2:=GetIdField(FNAme2,SFantomKod);
 End {добавление новой}
Else
 Begin {редактируем накладную}
  SArtikul:=Copy(S,1,CArtikul);
  If GetRazdelStatus(SArtikul) Then {если добавляем сертификат}
   Begin
    Podregim:=2;
    SFantomKod:=SArtikul;
   End
  Else
   Begin
    Podregim:=3;
    SFantomKod:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
              COne+1+CLitr+1+COne+1+CZena+1,CArtikul);
   End;
  SFantomNAme:=GetIdField(FNAme,SFantomKod);
  SFantomNAme2:=GetIdField(FNAme2,SFantomKod);
  If SFantomKod=Glob.NoSertifStr Then Warning:='Нет сертификата !';
 End;{редактируем накладную}
*)



If (Selector<>0) Or
  ((Selector=0)And(OperatorSelector in [0,1,2])) Then
Begin
If OperatorSelector<>1 Then
Begin
If Not AddSertif Then
If GetIdMarket(Sartikul)=0 Then
  Begin
          LineMsg('Внимание! Товар с кодом '+SArtikul+' запрещено отгружать клиенту!');
          {
          Sound(100);
          DinfoMsg('Внимание! Товар с кодом '+SArtikul+' запрещено отгружать клиенту!',False);
          Delay(300);
          NoSound;
          ClearEvent(Event);
          repeat
           Application^.GetEvent(Event);
          until (Event.What <> evNothing) And (Event.Command<>cmMenu);
          NoInfoMsg;
          ClearEvent(Event);
          }
       {если это не бронирование товара тогда выход}
          If (InputZakaz<>1)Or Not((Pharm=1)) Then Exit;
  End;
End
 Else
  Begin
If Not AddSertif Then
If GetIdMarket(Sartikul)=0 Then
  Begin
   SpecialBeep;
   If MessageBox(^M+#3+'Товар с кодом '+SArtikul+' запрещен к продаже!'^M+
   #3'Желаете продолжить операцию?',Nil,mfWarning+mfOkCancel)<>cmOk Then Exit;
  End;
  End;

If SFantomArtikul<>Glob.NoSertifStr Then
If GetIdMarket(SFantomArtikul)=0 Then
  Begin
       DisableDocument:=True;
          LineMsg('Внимание! Товар с кодом '+SFantomArtikul+' запрещено отгружать клиенту!');
          {
          Sound(100);
          DinfoMsg('Внимание! Товар с кодом '+SFantomArtikul+' запрещено отгружать клиенту!',False);
          Delay(300);
          NoSound;
          ClearEvent(Event);
          repeat
           Application^.GetEvent(Event);
          until (Event.What <> evNothing) And (Event.Command<>cmMenu);
          NoInfoMsg;
          ClearEvent(Event);
          }
          {Exit;}
  End;

End;

If(Selector in [5,6,7,8]) Then
Begin
If Not AddSertif Then
If GetIdDebit(Sartikul)=0 Then
  Begin
     LineMsg('Внимание! Товар с кодом '+SArtikul+' запрещено отгружать с отсрочкой платежа!');
     {
     Sound(100);
     DinfoMsg('Внимание! Товар с кодом '+SArtikul+' запрещено отгружать с отсрочкой платежа!',False);
     Delay(300);
     NoSound;
     ClearEvent(Event);
     repeat
       Application^.GetEvent(Event);
     until (Event.What <> evNothing) And (Event.Command<>cmMenu);
     NoInfoMsg;
     ClearEvent(Event);
     }
     {если это не бронирование товара тогда выход}
          If (InputZakaz<>1)Or Not((Pharm=1)) Then Exit;
  End;
End;

SAkzisSbor[0]:=#0;
SZenaMArki[0]:=#0;

Chast;

Case Regim Of
0:Begin
If Not(AddSertif) Then
Begin
  MaxKol := GetSkladKolWithUshetBron(SArtikul,StrToInt(SOtd));
  If StrToInt(MaxKol)<0 Then MaxKol[0]:=#0;
  El.Pack:=0;
  PrevKolPack:=0;

  El.Kol:=GetIdField(FInPack,SArtikul);

New(Skl,Init);
New(BBB,Init);
Skl^.Dat.BazKod:=SArtikul;
GetSkladRecord(Skl);
GetOLD_OSD(OSDList,Skl);

GetBazElement(SArtikul,BBB^.Dat);

  If Glob.Status = DocNormal Then
  Begin
  If StrToInt(El.Kol)>StrToInt(MaxKol){StrToInt(Skl^.Dat.Input.Division[StrToInt(SOtd)])!!!} Then
  El.Kol:=MaxKol{Skl^.Dat.Input.Division[StrToInt(SOtd)]!!!}
  End
  Else
  If StrToInt(El.Kol)>StrToInt(MaxKol){StrToInt(Skl^.Dat.Input.Division[StrToInt(SOtd)])!!!}
  Then El.Kol:=MaxKol{SKol};
  DelSpace(El.kol);

{
  MemC(MaxKol);
  MemC(El.Kol);
}


  If DisableTovar Then El.Kol[0]:=#0;
  El.Skidka[0]:=#0;
  SRZena:={BakGetField(FRZena,SArtikul,0)}Skl^.Dat.Input.R_Zena;
  Format(SRZena,CZena);
  SOZena:={BakGetField(FOZena,SArtikul,0)}Skl^.Dat.Input.O_Zena;
  Format(SOZena,CZena);
  El.NZena:=SRZena;
  DelSpace(El.NZena);
  SZakupka:={BakGetField(FZakupka,SArtikul,0)}Skl^.Dat.Input.Zakupka;
  Format(SZakupka,CZenaZ);
  SZakupka2:={BakGetField(FZakupka2,SArtikul,0)}Skl^.Dat.Input.Zakupka2;
  Format(SZakupka2,CZenaZ);

  SAkzisSbor:=Skl^.Dat.Input.AkzisSbor;
  Format(SAkzisSbor,CZenaZ);
  SZenaMArki:=Skl^.Dat.Input.ZenaMarki;
  Format(SZenaMArki,CZenaZ);

  SAkzis:={BakGetField(FMarka,SArtikul,0)}GetMarkaField(FMarka,Skl^.Dat.Input.Marka)+' ['+Skl^.Dat.Input.Marka+']';
  DelSpaceRight(SAkzis);

  SFirma:=GetFirmaPostField(FFirmaPost,BBB^.Dat.FirmaPostKod);
  DelSpaceRight(SFirma);

  SVirabotano:={BakGetField(FVirabotano,SArtikul,0)}Skl^.Dat.Input.Virabotano;
  DelSpaceRight(SVirabotano);
  SGodnost:={BakGetField(FGodnost,SArtikul,0)}Skl^.Dat.Input.Godnost;
  DelSpaceRight(SGodnost);

  Skl^.Dat.BazKod:=SFantomArtikul;
  GetSkladRecord(Skl);
  GetOLD_OSD(OSDList,Skl);

  SFantomRZena:=Skl^.Dat.Input.R_Zena{BakGetField(FRZena,SFantomArtikul,0)};
  Format(SFantomRZena,CZena);
  SFantomOZena:={BakGetField(FOZena,SFantomArtikul,0)}Skl^.Dat.Input.O_Zena;
  Format(SFantomOZena,CZena);
  SFAntomOZena:=SFantomRZena;
  SFantomZakupka:={BakGetField(FZakupka,SFantomArtikul,0)}Skl^.Dat.Input.Zakupka;
  Format(SFantomZakupka,CZenaZ);

  SFantomZakupka2:=Skl^.Dat.Input.Zakupka2;
  Format(SFantomZakupka2,CZenaZ);


  If LocalRegim=0 Then
  Begin{режим добавления количества сертификатов}
   PrevEkzemplar:='0';
   DelSpace(PrevEkzemplar);
   El.FantomKol:=GetIdField(FInPack,SFantomArtikul);
   If StrToInt(El.FantomKol)>StrToInt(MaxFantomKol){StrToInt(BakGetField(FDiv,SFantomArtikul,1))!!!} Then
   El.FantomKol:=MaxFantomKol{BakGetField(FDiv,SFantomArtikul,1)!!!};
   If DisableDocument Then El.FantomKol[0]:=#0;
   El.FantomSkidka[0]:=#0;
   El.FantomNZena:=SFantomRZena;
   DelSpace(El.FantomNZena);
  End
  Else
   Begin{режим редактирования количества сертификатов}
    GetFantomParametr(SFantomArtikul,SFantomRZena,PrevEkzemplar,SFantomSkidka,SFantomZakupka,
    SFantomZakupka2);
    DelSpace(PrevEkzemplar);
    El.FantomKol[0]:=#0;
    DelSpace(SFantomRZena);
    DelSpace(SFantomSkidka);
    El.FantomSkidka:=SFantomSkidka;
    DelSpace(SFantomZakupka);
    DelSpace(SFantomZakupka2);
    El.FantomNZena:=SFantomRZena;
    DelSpace(El.FantomNZena);
    SFAntomOZena:=SFantomRZena;
   End;
  DelSpace(El.FantomKol);
  If SFantomArtikul=Glob.NoSertifStr Then El.FantomKol:='0';
  Dispose(Skl,Done);
  Dispose(BBB,Done);

End {если добавляем товар в накладную}
 Else
   Begin

  New(Skl,Init);
  Skl^.Dat.BazKod:=SFantomArtikul;

  GetSkladRecord(Skl);
  GetOLD_OSD(OSDList,Skl);

  {???}
  MaxFantomKol := GetSkladKolWithUshetBron(SFantomArtikul,StrToInt(ActiveFantomOtdel));
  If StrToInt(MaxFantomKol)<0 Then MaxFAntomKol[0]:=#0;

  El.Kol:='0';
  If DisableTovar Then El.Kol[0]:=#0;
  PrevKolPack:=0;
  El.Skidka[0]:=#0;
  El.NZena[0]:=#0;

  SFantomRZena:=Skl^.Dat.Input.R_Zena{BakGetField(FRZena,SFantomArtikul,0)};
  Format(SFantomRZena,CZena);
  SFantomOZena:={BakGetField(FOZena,SFantomArtikul,0)}Skl^.Dat.Input.O_Zena;
  Format(SFantomOZena,CZena);
  SFantomZakupka:={BakGetField(FZakupka,SFantomArtikul,0)}Skl^.Dat.Input.Zakupka;
  Format(SFantomZakupka,CZenaZ);

  SFantomZakupka2:={BakGetField(FZakupka,SFantomArtikul,0)}Skl^.Dat.Input.Zakupka2;
  Format(SFantomZakupka2,CZenaZ);
  SFAntomOZena:=SFantomRZena;


  If LocalRegim=0 Then
  Begin{режим добавления количества сертификатов}
   {MemC('1');}
   PrevEkzemplar:='0';
   El.FantomKol:=GetIdField(FInPack,SFantomArtikul);
   If StrToInt(El.FantomKol)>{StrToInt(Skl^.Dat.Input.Division[1])!!!}StrToInt(MaxFantomKol)
    Then
   El.FantomKol:=MaxFantomKol{Skl^.Dat.Input.Division[1]!!!};
   If DisableDocument Then El.FantomKol[0]:=#0;
   DelSpace(El.FantomKol);
   DelSpace(PrevEkzemplar);
   El.FantomSkidka[0]:=#0;
   El.FantomNZena:=SFantomRZena;
   DelSpace(El.FantomNZena);
  End
  Else
   Begin{режим редактирования количества сертификатов}
    GetFantomParametr(SFantomArtikul,SFantomRZena,PrevEkzemplar,SFantomSkidka,SFantomZakupka,
    SFantomZakupka2);
    El.FantomKol[0]:=#0;
    DelSpace(SFantomRZena);
    SFAntomOZena:=SFantomRZena;
    DelSpace(SFantomSkidka);
    DelSpace(SFantomZakupka);
    DelSpace(SFantomZakupka2);
    El.FantomNZena:=SFantomRZena;
    El.FantomSkidka:=SFantomSkidka;
    DelSpace(El.FantomKol);
    DelSpace(El.FantomSkidka);
    DelSpace(PrevEkzemplar);
    DelSpace(El.FantomNZena);
   End;
  Dispose(Skl,Done);

   End;
  If SFantomArtikul=Glob.NoSertifStr Then El.FantomKol:='0';


  End;{Case '0'}
1:Begin
{Для новой структуры строки}
If Not(AddSertif) Then
Begin
    SArtikul:=Copy(S,1,CArtikul);
    SName:=Copy(S,1+CArtikul+1,CName);
    El.Kol:=Copy(s,1+CName+1+CArtikul+1+COne+1,CKol);
    El.SKidka:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1,CZena);
    SOtd:=Copy(s,1+CName+1+CArtikul+1,COne);
    ActiveOtdel:=SOtd;
    sskidka:=CalcPack(SArtikul,El.Kol);
    System.Delete(sskidka,Pos('+',Sskidka),Ord(S[0]));



    If (StrToInt(sskidka)-1) >= 0 Then
    El.Pack:=StrToInt(sskidka)-1
    Else El.Pack:=StrToInt(sskidka);
    If El.PAck>9 Then El.Pack:=9;
    PrevKolPack:=El.Pack;
    SRZena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1,CZena);
    SOZena:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1,CZena);
    SNalog:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1,CLitr);
    VidNalog:=StrToInt(Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1,
              COne));
    SNDS  :=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+COne+1,
    CLitr);

    VidNDS:=StrToInt(Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
    COne+1+CLitr+1,COne));

    SZakupka:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
              COne+1+CLitr+1+COne+1,CZenaZ);

    SZakupka2:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
              COne+1+CLitr+1+COne+1+CZenaZ+1,CZenaZ);

    SRegion:=StrToInt(Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
              COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1,COne));

  SAkzisSbor:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
              COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1,CZenaZ);

  SZenaMArki:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
              COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1,CZenaZ);


  SFantomArtikul:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
            COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1+CZenaZ+1,CArtikul);




  SFantomRZena:=BakGetField(FRZena,SFantomArtikul,0);
  Format(SFantomRZena,CZena);
  SFantomOZena:=BakGetField(FOZena,SFantomArtikul,0);
  Format(SFantomOZena,CZena);
  SFAntomOZena:=SFantomRZena;
  SFantomZakupka:=BakGetField(FZakupka,SFantomArtikul,0);
  Format(SFantomZakupka,CZenaZ);

  SFantomZakupka2:=BakGetField(FZakupka2,SFantomArtikul,0);
  Format(SFantomZakupka2,CZenaZ);


  If LocalRegim=0 Then
  Begin{режим добавления количества сертификатов}
   PrevEkzemplar:='0';
   {MemC('1');}
   El.FantomKol:=GetKolDocumentWithLinkAndDivision(SArtikul,StRToInt(SOtd));
   DelSpace(El.FantomKol);
   PrevFantomKol:=El.FantomKol;
   If DisableDocument Then El.FantomKol[0]:=#0;
   El.FantomSkidka[0]:=#0;
   DelSpace(El.FantomSkidka);
   El.FantomNZena:=SFantomRZena;
   DelSpace(El.FantomNZena);
  End
  Else
   Begin{режим редактирования количества сертификатов}
    GetFantomParametr(SFantomArtikul,SFantomRZena,PrevEkzemplar,SFantomSkidka,SFantomZakupka,
    SFantomZakupka2);
    DelSpace(PrevEkzemplar);
    El.FantomKol:=GetKolDocumentWithLinkAndDivision(SArtikul,StrToInt(SOtd));
    {MemC('2'+El.FantomKol);}
    DelSpace(El.FantomKol);
    PrevFantomKol:=El.FantomKol;
    DelSpace(SFantomRZena);
    SFAntomOZena:=SFantomRZena;
    DelSpace(SFantomSkidka);
    DelSpace(SFantomZakupka);
    DelSpace(SFantomZakupka2);
    El.FantomNZena:=SFantomRZena;
    El.FantomSkidka:=SFantomSkidka;
    {El.FantomNZena:=SFantomRZena;}
    DelSpace(El.FantomNZena);
    DelSpace(El.FantomSkidka);
   End;

    DelSpace(El.FantomKol);
    If SFantomArtikul=Glob.NoSertifStr Then El.FantomKol:='0';
    DelSpace(PrevEkzemplar);

    DelSpace(SNAlog);
    DelSpace(SNDS);
    DelSpace(El.Kol);
    DelSpace(El.Skidka);
End
Else
 Begin
  El.Kol:='0';
  PrevKolPack:=0;
  El.Skidka[0]:=#0;
  El.NZena[0]:=#0;
  GetFantomParametr(SFantomArtikul,SFantomRZena,PrevEkzemplar,SFantomSkidka,
  SFantomZakupka,SFantomZakupka2);
  DelSpace(PrevEkzemplar);
  Str(StrToInt(PrevEkzemplar)-StrToInt(GetKolDocument1(SFantomArtikul)):CKol,El.FantomKol);
  DelSpace(El.FantomKol);
  PrevFantomKol:=El.FantomKol;
  DelSpace(SFantomRZena);
  SFAntomOZena:=SFantomRZena;
  DelSpace(SFantomSkidka);
  DelSpace(SFantomZakupka);
  DelSpace(SFantomZakupka2);
  El.FantomNZena:=SFantomRZena;
  El.FantomSkidka:=SFantomSkidka;
  DelSpace(El.FantomNZena);
  DelSpace(El.FantomKol);
  {If DisableDocument Then El.FantomKol[0]:=#0;}
  DelSpace(PrevEkzemplar);
  DelSpace(El.FantomKol);
  DelSpace(PrevEkzemplar);
 End;{если редактируем сертификат}
  End;{метка Case "1" редактирование}
  Else;
  End;

SFAntomOZena:=SFantomRZena;

ClearFind;

If Not AddSertif Then
Dopolnenie:=GetIdField(Fname2,Sartikul)
Else Dopolnenie[0]:=#0;
DelSpaceRight(Dopolnenie);

SZakupka:=RealToStr(StrToReal(SZakupka),CZenaZ,CMantissaZ);
DelSpace(SZakupka);
Format(SZakupka,CZenaZ);

SZakupka2:=RealToStr(StrToReal(SZakupka2),CZenaZ,CMantissaZ);
DelSpace(SZakupka2);
Format(SZakupka2,CZenaZ);

SAkzisSbor:=RealToStr(StrToReal(SAkzisSbor),CZenaZ,CMantissaZ);
DelSpace(SAkzisSbor);
Format(SAkzisSbor,CZenaZ);

SZenaMarki:=RealToStr(StrToReal(SZenaMarki),CZenaZ,CMantissaZ);
DelSpace(SZenaMarki);
Format(SZenaMarki,CZenaZ);


BakKol:=El.Kol;
BakFantomKol:=El.FAntomKol;

1:




AInfo('Читаю информацию о товаре...');
Application^.GetExtent(r);
R.Assign(0, {3}R.B.Y-23, 80, {22}R.B.Y-4);
If Not AddSertif Then
New(MarketWin, Init(R, 'Продажа наименования товара - отделение ['+SOtd+']'))
Else
New(MarketWin, Init(R, 'Продажа наименования товара - отделение ['+
IntToStr(StrToInt(ActiveFantomOtdel),COne)+']'));
MarketWin^.Options := MarketWin^.Options or ofCenterX;
MarketWin^.Palette := dpCyanDialog;
MarketWin^.HelpCtx := $F427{E199};


MarketWin^.FindPrevOtgruzka:=False;

FindPrevOtgruzkaDoc[0]:=#0;
FindPrevOtgruzkaDate[0]:=#0;
FindPrevOtgruzkaKol[0]:=#0;

{MemCC;}

{If OperatorSelector=0 Then}{т.к. эта информация нужна для всех}
MarketWin^.FindPrevOtgruzka:=FindPrevOtgruzkaProc(SFantomArtikul,FindPrevOtgruzkaDoc,
FindPrevOtgruzkaDate,FindPrevOtgruzkaKol);


R.Assign(1, 4, 44, 6);
Pack := New(PRadioButtons, Init(R,
  NewSItem('~1~',
  NewSItem('~2~',
  NewSItem('~3~',
  NewSItem('~4~',
  NewSItem('~5~',
  NewSItem('~6~',
  NewSItem('~7~',
  NewSItem('~8~',
  NewSItem('~9~',
  NewSItem('1~0~',
  NewSItem('~А~', Nil)))))))))))));
  Pack^.SetData(El.Pack);

MarketWin^.Insert(Pack);

If AddSertif Then
Begin
  Pack^.Options := Pack^.Options and not ofSelectable;
End;

If DisableTovar Then
  Pack^.Options := Pack^.Options and not ofSelectable;


If DisablePack=1 Then
  Pack^.Options := Pack^.Options and not ofSelectable;



  R.Assign(1, 3, 25, 4);
  MarketWin^.Insert(New(PLabel, Init(R, 'Количество ~у~паковок:', Pack)));

R.Assign(45, 4, 54, 5);
Control := New(PColoredText, Init(R, 'Упаковок:', $3E));
MarketWin^.Insert(Control);

R.Assign(54, 4, 63, 5);
ControlPack := New(PStaticText, Init(R, #3+'0+0'));
MarketWin^.Insert(ControlPack);

R.Assign(53, 5, 60, 6);
ControlKol := New(PInputLine, Init(R, CKol));
If AddSertif Then
Begin
  ControlKol^.Options := ControlKol^.Options and not ofSelectable;
End;

If DisableTovar Then
  ControlKol^.Options := ControlKol^.Options and not ofSelectable;

  ControlKol^.SetData(El.Kol);
MarketWin^.Insert(ControlKol);
  PInputLine(ControlKol)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(45, 5, 53, 6);
  MarketWin^.Insert(New(PLabel, Init(R, 'К~о~лич.:', ControlKol)));

If Not AddSertif Then
Begin
SInPack2:=IntToStr(StrToInt(SInPack2),CInPack);

R.Assign(2, 1, 79, 2);
Control := New(PStaticText, Init(R, 'Наименование:'+SName+' Код:'+SArtikul+' Литраж:'+Slitr+' Фас:'+SInPack+'x'+SInPack2));
MarketWin^.Insert(Control);


{вставляем код с ценой по Ценовому ограничению если оно есть}
InsertLabel;




SGRZena:=BakGetField(FGRZena1,SArtikul,0);
Lobovaya:=StrToReal(BakGetField(FRZena,SArtikul,0));


If Dopolnenie[0]<>#0 Then
Begin
R.Assign(2, 2, 35, 3);
Control := New(PStaticText, Init(R, '             '+Dopolnenie));
MarketWin^.Insert(Control);
End;

R.Assign(42,2, 60, 3);
Control := New(PStaticText, Init(R, SFirma));
MarketWin^.Insert(Control);



R.Assign(60, 2, 78, 3);
SSRegion[0]:=#0;
Case SRegion Of
0:SSRegion:='Не маркированный';
1:SSRegion:='Маркированный';
Else;
End;
Control := New(PColoredText, Init(R, #3+SSRegion, $5F));
MarketWin^.Insert(Control);


{$IFDEF Pharm}
Color:=$33;
R.Assign(1, 2, 11 , 4);

Sr1:=SGRZena;
NDS:=GetIDField(FNDS,SArtikul);
MyStr(StrToReal(Sr1)+StrToReal(SR1)*StrToReal(NDS)/(100),CZena,CMAntissa,Sr2);
MyStr(StrToReal(Sr1),CZena,CMAntissa,Sr1);
DelSpace(sr1);
DelSpace(sr2);



{Memc(SGRZena+' '+sr1+' '+El.NZena);}
{
If ((StrToReal(SR)-StrToReal(sr1))<0.0009) And (StrToReal(SR1)>0.0009) Then
 Begin
}
  SSRegion:='ГР:'+SR1+^M+
  +'   ('+SR2+')';
  Color:=$5E;
{
 End
 Else
  SSRegion:='';
}
ControlGR := New(PColoredText, Init(R, #3+SSRegion, Color));
MarketWin^.Insert(ControlGR);
{$ENDIF}

End;

If Skidka=1 Then
EnableCommands([cmLocalSkidka,cmLocalNazenka])
Else
DisableCommands([cmLocalSkidka,cmLocalNazenka]);


If Skidka=1 Then
R.Assign(68, 5, 78, 6)
Else
R.Assign(0, 0, 0, 0);
ControlNZena := New(PInputLine, Init(R, CZena));
MyStr(StrToReal(SRZena)-StrToReal(El.Skidka),CZena,CMantissa,El.NZena);
DelSpace(El.NZena);
  ControlNZena^.SetData(El.NZena);
MarketWin^.Insert(ControlNZena);
  PInputLine(ControlNZena)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  If Not(StrToInt(CurrentPassword)=0) And Not(EnableHandZeni=1)  Then
  ControlNZena^.Options := ControlNZena^.Options and not ofSelectable;

If Skidka=0 Then
  ControlNZena^.Options := ControlNZena^.Options and not ofSelectable;

If AddSertif Then
Begin
  ControlNZena^.Options := ControlNZena^.Options and not ofSelectable;
End;



If Skidka=1 Then
R.Assign(60, 5, 68, 6)
Else
R.Assign(0, 0, 0, 0);
  MarketWin^.Insert(New(PLabel, Init(R, '  Цена:', ControlNZena)));

DelSpace(SZakupka2);
DelSpace(SZakupka);
DelSpace(SAkzisSbor);
DelSpace(SZenaMarki);

If ({FindParam('/EZ')}(EnableZakupka=1)) Or (StrToInt(CurrentPassword)=0 ) Then
Begin
If StrToInt(CurrentPassword)<>0 Then ViewZakupka:=False
Else ViewZakupka:=True;
If Skidka=1 Then
Begin
                 If StrToReal(SZakupka2)>0.009 Then
                 Begin
                  s[0]:=#0;
                  MyStr((StrToREal(El.NZena)-StrToReal(SZakupka2))/StrToReal(SZakupka2)*100,CLitr,CMantissa,s);
                  s:='('+s+'%)';
                 End
                 Else s:='(??.??%)';
End
Else s:=' ';



R.Assign(62, 3, 79, 4);
If Not(ViewZakupka) Then
ControlZakupka:=New(PColoredText, Init(R, SZakupka2+s, $33))
Else
ControlZakupka:=New(PColoredText, Init(R, SZakupka2+s, $31));
End
 Else
  Begin
   s:=' ';
   ViewZakupka:=False;
   R.Assign(62, 3, 79, 4);
   ControlZakupka:=New(PColoredText, Init(R, s, $33));
  End;
MarketWin^.Insert(ControlZakupka);

Format(SZakupka2,CZenaZ);
Format(SZakupka,CZenaZ);
Format(SAkzisSbor,CZenaZ);
Format(SZenaMarki,CZenaZ);

{End;}
If Skidka=1 Then
R.Assign(68, 6, 78, 7)
Else
R.Assign(0, 0, 0, 0);
Control1Skidka := New(PInputLine, Init(R, CZena));
MarketWin^.Insert(Control1Skidka);
  PInputLine(Control1Skidka)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));
Control1Skidka^.SetData(El.Skidka);

If Skidka=0 Then
  Control1Skidka^.Options := Control1Skidka^.Options and not ofSelectable;

If AddSertif Then
Begin
  Control1Skidka^.Options := Control1Skidka^.Options and not ofSelectable;
End;

{
If DisableTovar Then
  Control1Skidka^.Options := Control1Skidka^.Options and not ofSelectable;
}

If Skidka=1 Then
  R.Assign(60, 6, 68, 7)
Else
  R.Assign(0, 0, 0, 0);

  MarketWin^.Insert(New(PLabel, Init(R, '~С~кидка:', Control1Skidka)));

MyStr(StrToReal(SRZena)-StrToReal(El.Skidka),CZena,CMantissa,El.NZena);
DelSpace(El.NZena);

If Not(AddSertif) Then
Begin
New(Skl,Init);
Skl^.Dat.BazKod:=SArtikul;

GetSkladRecord(Skl);
GetOLD_OSD(OSDList,Skl);

MaxKol:=GetSkladAllKolWithUshetBron(SArtikul);{!!!}
MaxKol1:=GetSkladKolWithUshetBron(SArtikul,StrToInt(SOtd));{!!!}


If Glob.Status=DocEdit Then
Begin
Str(StrToInt(MaxKol):CKOl,ws1);
DelSpace(ws1);
Str(StrToInt(MaxKol1):CKol,ws);
DelSpace(ws);
DelSpace(Skl^.DAt.Input.StrihKod);
ws:='На складе:'+ws1+' В отделении:'+ws+' ШК:'+Skl^.DAt.Input.StrihKod+' Цена:';
End
Else
ws:='На складе:'+IntToStr(StrToInt(MaxKol),CKol)+
' В отделении:'+IntToStr(StrToInt(MaxKol1),CKOl)+' ШК:'+Skl^.DAt.Input.StrihKod+' Цена:';

Dispose(Skl,Done);
DelSpace(SOZena);
If Selector in [0,1] Then ws:=ws+SRZena
Else ws:=ws+SOZena;
End
 Else ws[0]:=#0;
{R.Assign(23, 3, 75, 4);}
R.Assign(1, 6, 59, 7);
Control := New(PColoredText, Init(R,ws, $31));
MarketWin^.Insert(Control);

R.Assign(0, 8, 80, 9);
Control := New(PColoredText, Init(R, Line_Separator^, $3F));
MarketWin^.Insert(Control);

If Not AddSertif Then
Begin
MaxKol:=GetSkladAllKolWithUshetBron(SArtikul);
If StrToInt(MaxKol)<0 Then MaxKol:='0';
If Glob.Status=DocNormal Then ws1:=MaxKol{BakGetField(FKol,SArtikul,0)};
DelSpace(Ws1);
ws1:=CalcPack(SArtikul,ws1);
DelSpace(Ws1);

R.Assign(1, 8, Length(' На складе имеется: '+ws1+' упаковок(ки)'+' Ставка НП:'+SNalog+' Ставка НДС:'+SNDS)+2,9);
Control := New(PColoredText, Init(R,' На складе имеется: '+ws1+' упаковок(ки)'+' Ставка НП:'+SNalog+' Ставка НДС:'+SNDS,
$31));
Control^.Options := Control^.Options or ofCenterX;
MarketWin^.Insert(Control);
End
Else ws1[0]:=#0;


If Not AddSertif Then
Begin
R.Assign(1, 7, 7, 8);
Control := New(PColoredText, Init(R, Seria_Akzis^+':', $3B));
MarketWin^.Insert(Control);

R.Assign(7, 7, 47, 8);
Control := New(PColoredText, Init(R, SAkzis, $31));
MarketWin^.Insert(Control);


Marking:=False;
If (SVirabotano[0]<>#0) And (SGodnost[0]<>#0) Then
Begin
{вставлено по просьбе судеба из фармпартнера чтобы
визуально оповещать оператора о том что больша часть срока реализации прошла!}
If (DateStringToDate(DateMask,FDate)-DateStringToDate(DateMask,SVirabotano))>0 Then
If (DateStringToDate(DateMask,SGodnost)-DateStringToDate(DateMask,FDate))>0 Then
  If (DateStringToDate(DateMask,FDate)-DateStringToDate(DateMask,SVirabotano))>
     (DateStringToDate(DateMask,SGodnost)-DateStringToDate(DateMask,FDate)) Then
      Begin
      Marking:=True;
      End;




End;


R.Assign(48, 7, 59, 8);
Control := New(PColoredText, Init(R, 'Выработано:', $3B));
MarketWin^.Insert(Control);

R.Assign(59, 7, 67, 8);
Control := New(PColoredText, Init(R, SVirabotano, $31));
MarketWin^.Insert(Control);

R.Assign(68, 7, 71, 8);
Control := New(PColoredText, Init(R, 'До:', $3B));
MarketWin^.Insert(Control);

R.Assign(71, 7, 79, 8);
If Not Marking Then
Control := New(PColoredText, Init(R, SGodnost, $31))
Else
Control := New(PColoredText, Init(R, SGodnost, $4E));
MarketWin^.Insert(Control);
End;



R.Assign(6, 14, 17, 15);
Control := New(PColoredText, Init(R, 'Сертификат:', $3B));
MarketWin^.Insert(Control);

R.Assign(17, 14, 78, 15);
Control := New(PColoredText, Init(R, SFantomName+' '+SFantomNAme2+' ('+SFantomArtikul+')', $30));
MarketWin^.Insert(Control);

R.Assign(3, 15, 17, 16);
Control := New(PColoredText, Init(R, 'Срок действия:', $3B));
MarketWin^.Insert(Control);

R.Assign(17, 15, 25, 16);
Control := New(PColoredText, Init(R, SSrok, $30));
MarketWin^.Insert(Control);

R.Assign(26, 15, 32, 16);
Control := New(PColoredText, Init(R, 'Выдан:', $3B));
MarketWin^.Insert(Control);

R.Assign(32, 15, 72, 16);
Control := New(PColoredText, Init(R, SVidan, $30));
MarketWin^.Insert(Control);

If AddSertif Then
R.Assign(1, 1, 79, 8)
Else
R.Assign(0, 0, 0, 0);
Control := New(PStaticText, Init(R, ''));
MarketWin^.Insert(Control);

New(Skl,Init);
Skl^.Dat.BazKod:=SFantomArtikul;

GetSkladRecord(Skl);
GetOLD_OSD(OSDList,Skl);

{???}
MaxFantomKol:=GetSkladKolWithUshetBron(SFantomArtikul,StrToInt(ActiveFantomOtdel));{!!!}

If Glob.Status=DocEdit Then
Begin
Str(StrToInt(MaxFantomKol):CKol,ws1);
End
Else
If Glob.Status=DocNormal Then
ws1:=IntToStr(StrToInt(MAxFantomKol),CKol){BakGetField(FKol,SFantomArtikul,0)};
DelSpace(Ws1);

Dispose(Skl,Done);

R.Assign(10, 18, 76, 19);
If (Glob.NoSertifStr <> SFantomArtikul) Then
Begin
 If Not(DisableFantom) Then
 Control := New(PColoredText, Init(R, #3+' На складе имеется: '+ws1+' штук(и). В отделении ['+
 IntToStr(StrToInt(ActiveFantomOtdel),COne)+']:'+ws1+' Цена: '+SFantomRZena, $31))
 Else
 Begin
{$IfNDef Pharm}
  {Beep;}
  Control := New(PColoredText, Init(R, #3+'Внимание! На складе нет сертификата соответствия!', $5F));
{$ELSE}
  Control := New(PColoredText, Init(R, '', $3B));
{$EndIF}
 End;
End
 Else
  Begin
   {Beep;}
   Control := New(PColoredText, Init(R, #3+'Внимание! Продукция не сертифицирована!', $5F));
  End;

Control^.Options := Control^.Options or ofCenterX;
MarketWin^.Insert(Control);

If MarketWin^.FindPrevOtgruzka Then
Begin
{SpecialBeep;}
{R.Assign(11, 8, 69, 9);}
R.Assign(3, 17, 62, 18);
ControlRemarka := New(PColoredText, Init(R, #3+{Сертификат уже }'Выдавался по документу N '+
 FindPrevOtgruzkaDoc+' от '+FindPrevOtgruzkaDate+' ('+FindPrevOtgruzkaKol+') '+'шт.', $CE));
{ControlRemarka^.Options := ControlRemarka^.Options or ofCenterX;}
MarketWin^.Insert(ControlRemarka);
End;



R.Assign(1, 16, 12, 17);
Control := New(PStaticText, Init(R, 'В докум-те:'));
MarketWin^.Insert(Control);

R.Assign(17, 16, 29, 17);
Control := New(PStaticText, Init(R, ' экземпляров'));
MarketWin^.Insert(Control);

R.Assign(12, 16, 17, 17  );
If StrToInt(PrevEkzemplar)=0 Then
Control := New(PColoredText, Init(R, #3+PrevEkzemplar, $1B))
Else
Control := New(PColoredText, Init(R, #3+PrevEkzemplar, $5F));
MarketWin^.Insert(Control);

R.Assign(53, 16, 60, 17);
ControlFantomKol := New(PInputLine, Init(R, CKol));
MarketWin^.Insert(ControlFantomKol);
  PInputLine(ControlFantomKol)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));


If (Regim=0) And Not(AddSertif) Then
  Begin
   If (MarketWin^.FindPrevOtgruzka)  Then El.FantomKol[0]:=#0;
  End;


If (DisableOtgruzkaSertif=1) Then
  Begin
   El.FantomKol[0]:=#0;
  End;



  El.FantomKol:=IntToStr(StrToInt(El.FantomKol),CKol);
  ControlFantomKol^.SetData(El.FantomKol);

If SFantomArtikul=Glob.NoSertifStr Then
  ControlFantomKol^.Options := ControlFantomKol^.Options and not ofSelectable;

If DisableFantom Then
  ControlFantomKol^.Options := ControlFantomKol^.Options and not ofSelectable;

If DisableDocument Then
  ControlFantomKol^.Options := ControlFantomKol^.Options and not ofSelectable;



  R.Assign(29, 16, 53, 17);

If LocalRegim=0 Then
  MarketWin^.Insert(New(PLabel, Init(R, '  Добавить эк~з~емпляров:', ControlFantomKol)))
Else
  MarketWin^.Insert(New(PLabel, Init(R, ' Нужно еще эк~з~емпляров:', ControlFantomKol)));

If Skidka=1 Then
R.Assign(68, 16, 78, 17)
Else
R.Assign(0, 0, 0, 0);
ControlFantomNZena := New(PInputLine, Init(R, CZena));
MarketWin^.Insert(ControlFantomNZena);
MyStr(StrToReal(SFantomRZena)-StrToReal(El.FantomSkidka),CZena,CMantissa,El.FantomNZena);
DelSpace(El.FantomNZena);
  ControlFantomNZena^.SetData(El.FantomNZena);
  PInputLine(ControlFantomNZena)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  If Not(StrToInt(CurrentPassword)=0) And Not(EnableHandZeni=1)  Then
  ControlFantomNZena^.Options := ControlFantomNZena^.Options and not ofSelectable;



If Skidka=0 Then
  ControlFantomNZena^.Options := ControlFantomNZena^.Options and not ofSelectable;

If SFantomArtikul=Glob.NoSertifStr Then
  ControlFantomNZena^.Options := ControlFantomNZena^.Options and not ofSelectable;

If DisableFantom Then
  ControlFantomNZena^.Options := ControlFantomNZena^.Options and not ofSelectable;
{
If DisableDocument Then
  ControlFantomNZena^.Options := ControlFantomNZena^.Options and not ofSelectable;
}
If Skidka=1 Then
  R.Assign(62, 16, 68, 17)
Else
  R.Assign(0, 0, 0, 0);
  MarketWin^.Insert(New(PLabel, Init(R, 'Цена:', ControlFantomNZena)));

If Skidka=1 Then
R.Assign(68, 17, 78, 18)
else
R.Assign(0, 0, 0, 0);
ControlFantomSkidka := New(PInputLine, Init(R, CZena));
MarketWin^.Insert(ControlFantomSkidka);
  PInputLine(ControlFantomSkidka)^.Validator := New(PFilterValidator, Init(['-','1','2','3','4','5','6','7','8','9','0','.']));
  ControlFantomSkidka^.SetData(El.FantomSkidka);

If Skidka=0 Then
  ControlFantomSkidka^.Options := ControlFantomSkidka^.Options and not ofSelectable;


If SFantomArtikul=Glob.NoSertifStr Then
  ControlFantomSkidka^.Options := ControlFantomSkidka^.Options and not ofSelectable;

If DisableFantom Then
  ControlFantomSkidka^.Options := ControlFantomSkidka^.Options and not ofSelectable;
{
If DisableDocument Then
  ControlFantomSkidka^.Options := ControlFantomSkidka^.Options and not ofSelectable;
}

MyStr(StrToReal(SFantomRZena)-StrToReal(El.FantomSkidka),CZena,CMantissa,El.FantomNZena);
DelSpace(El.FantomNZena);


If (DisableOtgruzkaSertif=1) Then
  Begin
   El.FantomKol[0]:=#0;
   ControlFantomKol^.Options := ControlFantomKol^.Options and not ofSelectable;
   ControlFantomNZena^.Options := ControlFantomNZena^.Options and not ofSelectable;
   ControlFantomSkidka^.Options := ControlFantomSkidka^.Options and not ofSelectable;
  End;




If Skidka=1 Then
R.Assign(60, 17, 68, 18)
Else
R.Assign(0, 0, 0, 0);
  MarketWin^.Insert(New(PLabel, Init(R, 'Ски~д~ка:', ControlFantomSkidka)));


R.Assign(74, 10, 75, 14);
Control := New(PScrollBar, Init(R));
MarketWin^.Insert(Control);

R.Assign(6, 10, 74, 14);
ControlBox := New(PBox, Init(R, 1, PScrollbar(Control)));
ControlBox^.NewList(New(PTextCollection, Init(0,1)));

FormList;

ControlBox^.FocusItem(0);

 If Not(ControlBox^.List^.Count-1>=0) Then
  Begin
   ControlBox^.SetRange(ControlBox^.List^.Count);
   ControlBox^.Options := ControlBox^.Options and not ofSelectable;
  End;

If DisableTovar And DisableDocument Then
 Begin
  ControlBox^.Options := ControlBox^.Options or ofSelectable;
 End;

MarketWin^.Insert(ControlBox);

  R.Assign(6, 9, 75, 10);
  MarketWin^.Insert(New(PLabel, Init(R, 'Связанные с сертификатом наименования товара           Код  N Колич.', ControlBox)));


{MarketWin^.SetData(El);}


MarketWin^.SelectNext(False);

{MarketWin^.SetData(El);}


If (Regim=0) Then
If (Skidka=1) And (OperatorSelector=0) Then
If (LocalRegim=0) Then
If  Not(AddSertif) Then
 Begin
  PStaticText(ControlClientLabel)^.GetText(S);
  System.Delete(S,Pos(#3,S),1);
  Ck:=Copy(s,1+CClient+1,CClientKod);
  ReturnZena[0]:=#0;
  If FindLastRegim(SArtikul,Ck,ReturnZena) Then
  If ReturnZena[0]<>#0 Then
   Begin
    El.NZena:=returnZena;
    MyStr(Lobovaya-StrToReal(ReturnZena),CZena,CMantissa,El.Skidka);
    DelSpace(El.NZena);
    DelSpace(El.Skidka);
    ControlNZena^.SetData(ReturnZena);
    Control1Skidka^.SetData(El.Skidka);
   End;

 End;






DrawPack;

NoInfo;

PrevKol[0]:=#0;
FullFantomKol:=GetKolDocument(SFantomArtikul);
DelSpace(FullFantomKol);
{ProdagaWindow:=True;}

c:=Desktop^.ExecView(MarketWin);

If c<>cmCancel Then
 Begin
{ MarketWin^.GetData(El);}

  Pack^.GetData(El.Pack);
  ControlKol^.GetData(El.Kol);
  ControlNZena^.GetData(El.NZena);
  Control1Skidka^.GetData(El.Skidka);
  ControlFantomKol^.GetData(El.FantomKol);
  El.FantomKol:=IntToStr(StrToInt(El.FantomKol),CKol);

  ControlFantomNZena^.GetData(El.FantomNZena);
  ControlFantomSkidka^.GetData(El.FantomSkidka);

  DelSpace(El.Kol);
  DelSpace(El.NZena);
  DelSpace(El.Skidka);
  DelSpace(El.FantomKol);
  DelSpace(El.FantomNZena);
  DelSpace(El.FantomSkidka);

  Dispose(Control,Done);
  Dispose(MarketWin,Done);

  If AddSertif Then
  If LocalRegim=0 Then {режим когда El.FantomKol-все количество}
   Begin
   If (El.FantomKol[0]=#0) Or (StrTOInt(El.FantomKol)=0) Then
    Begin
     MessageBox(#3+NullFantomKol^,nil, mfError + mfCancelButton);
     GoTo 1;
    End;
   End;



  If Glob.Status=DocNormal Then
  If LocalRegim=0 Then {режим когда El.FantomKol-все количество, т.е. режим добавления сертификата}
   Begin
    {формирование заказа}
{???}
    MaxFantomKol:=GetSkladKolWithUshetBron(SFantomArtikul,StrToInt(ActiveFantomOtdel));{!!!}
    If StrToInt(El.FAntomKol)>0 Then
  Begin
    If InputZakaz=1 Then
    Begin
    End;
    If (StrToInt({BakGetField(FDiv,SFantomArtikul,1)}MaxFantomKol))<(StrTOInt(El.FantomKol)) Then
     Begin
       MessageBox(^M+'На складе (отделение ['+IntToStr(StrToInt(ActiveFAntomOtdel),COne)+
	  ']) отсутствует такое количество документов!',nil, mfError +
          mfCancelButton);
       GoTo 1;
     End;
  End;
   End{LocalRegim=0}
   Else
    Begin
     {режим, когда El.FantomKol не все количество,т.е. режим редактирования количества сертификатов}
{???}
     MaxFantomKol:=GetSkladKolWithUshetBron(SFantomArtikul,StrToInt(ActiveFantomOtdel));{!!!}
     If (StrToInt({BakGetField(FDiv,SFantomArtikul,1)}MaxFantomKol)<(
     StrToInt(FullFantomKol)-StrToInt(PrevFantomKol)+StrTOInt(El.FantomKol))) Then
      Begin
       MessageBox(^M+'На складе (отделение ['+IntToStr(StrToInt(ActiveFAntomOtdel),COne)+
	  ']) отсутствует такое количество документов!',nil, mfError +
          mfCancelButton);
       GoTo 1;
      End;
    End;

  If Glob.Status=DocEdit Then
  Begin
{???}
  If StrToInt(El.FAntomKol)>StrToInt(BakFantomKol) Then
  Begin
  MaxFantomKol:=GetSkladKolWithUshetBron(SFantomArtikul,StrToInt(ActiveFantomOtdel));{!!!}
  If ((StrToInt({BakGetField(FDiv,SFantomArtikul,1)}MaxFantomKol){+
      GetKolMarket(SFantomArtikul,1,PrevMarket)})<
        (StrToInt(FullFantomKol)-StrToInt(PrevFantomKol)+StrTOInt(El.FantomKol))) Then
      Begin
       MessageBox(^M+'На складе (отделение ['+IntToStr(StrToInt(ActiveFAntomOtdel),COne)+
	  ']) отсутствует такое количество документов!',nil, mfError +
          mfCancelButton);
       GoTo 1;
      End;
  End;{количество увеличилось}
  End;


  if Inputzakaz=0 then{идет обыкновенная выписка}
   If OperatorSelector<>0 Then{межскладская операция}
  Begin
   If Glob.Status=DocNormal Then
   Begin
{???}
   If (StrToInt(BakGetField(FDiv ,SFantomArtikul,StrToInt(ActiveFantomOtdel)))-
       StrToInt(BakGetField(FDivR,SFantomArtikul,StrToInt(ActiveFantomOtdel))))<(StrTOInt(El.FantomKol)) Then
    Begin
     SpecialBeep;
     If MessageBox(NoComplect^+SFAntomArtikul+')?',Nil, mfFatalError + mfOkCancel)=cmOk then
     GoTo 1;
    End;
   End{Status=DocNormal}
   Else
    Begin
{???}
   If (StrToInt(BakGetField(FDiv ,SFantomArtikul,StrToInt(ActiveFantomOtdel)))-
       StrToInt(BakGetField(FDivR,SFantomArtikul,StrToInt(ActiveFantomOtdel)))+
       GetKolMarket(SFantomArtikul,StrToInt(ActiveFantomOtdel),PrevMarket))<(StrTOInt(El.FantomKol)) Then
    Begin
     SpecialBeep;
     If MessageBox(NoComplect^+SFAntomArtikul+')?',Nil, mfFatalError + mfOkCancel)=cmOk then
     GoTo 1;
    End;
  End;
  End;




  if skidka=1 then{ручной режим контроль себестоимости}
  If (StrToReal(SFantomRZena)-StrTOReal(El.FantomSkidka))<(StrToReal(SFantomZakupka)) Then
   Begin
    SpecialBeep;
    MessageBox(WarningDZakupka^,nil, mfError + mfCancelButton);
   End;

  if skidka=1 then{ручной режим контроль себестоимости}
  If (StrToReal(SFantomRZena)-StrTOReal(El.FantomSkidka))<(StrToReal(SFantomZakupka2)) Then
   Begin
    SpecialBeep;
    MessageBox(WarningDZakupka2^,nil, mfError + mfCancelButton);
   End;


If Not AddSertif Then
Begin
  If (El.Kol[0]=#0) Or (StrTOInt(El.Kol)=0) Then
   Begin
    MessageBox(#3+NullKol^,nil, mfError + mfCancelButton);
    GoTo 1;
   End;

  If Glob.Status=DocNormal Then
   Begin
  If (StrToInt(GetSkladKolWithUshetBron(SArtikul,StrToInt(SOtd))
  {BakGetField(FDiv,SArtikul,StrToInt(SOtd))!!!})<(StrTOInt(El.Kol))) Then
   Begin
     MessageBox(^M+'На складе (отделение ['+SOtd+']) отсутствует такое количество товара!',nil, mfError + mfCancelButton);
     GoTo 1;
   End;
   End;

  If Glob.Status=DocEdit Then
  Begin
   If StrToInt(El.Kol)>StrToInt(BAkKol) Then
   If (StrToInt(GetSkladKolWithUshetBron(SArtikul,StrToInt(SOtd)))
{BakGetField(FDiv,SArtikul,StrToInt(SOtd)))!!!}-StrTOInt(El.Kol){+GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket)!!!})<0 Then
   Begin
     MessageBox(^M+'На складе (отделение ['+SOtd+']) отсутствует такое количество товара!',nil, mfError + mfCancelButton);
     GoTo 1;
   End;
  End;

  if Inputzakaz=0 then{идет обыкновенная выписка}
   If OperatorSelector<>0 Then{межскладская операция}
  Begin
   If Glob.Status=DocNormal Then
   Begin
   If (StrToInt(BakGetField(FDiv ,SArtikul,StrToInt(SOtd)))-
       StrToInt(BakGetField(FDivR,SArtikul,StrToInt(SOtd))))<(StrTOInt(El.Kol)) Then
    Begin
     SpecialBeep;
     If MessageBox(NoComplect^+SArtikul+')?',Nil, mfFatalError + mfOkCancel)=cmOk then
     GoTo 1;
    End;
   End{Status=DocNormal}
   Else
    Begin
   If (StrToInt(BakGetField(FDiv ,SArtikul,StrToInt(SOtd)))-
       StrToInt(BakGetField(FDivR,SArtikul,StrToInt(SOtd)))+
          GetKolMarket(SArtikul,StrToInt(SOtd),PrevMarket))<(StrTOInt(El.Kol)) Then
    Begin
     SpecialBeep;
     If MessageBox(NoComplect^+SArtikul+')?',Nil, mfFatalError + mfOkCancel)=cmOk then
     GoTo 1;
    End;
  End;
  End;


  if skidka=1 then{ручной режим контроль себестоимости}
  If (StrToReal(SRZena)-StrTOReal(El.Skidka))<(StrToReal(SZakupka)) Then
   Begin
    SpecialBeep;
    MessageBox(WarningTZakupka^,nil, mfError + mfCancelButton);
   End;

  if skidka=1 then{ручной режим контроль себестоимости}
  If (StrToReal(SRZena)-StrTOReal(El.Skidka))<(StrToReal(SZakupka2)) Then
   Begin
    SpecialBeep;
    MessageBox(WarningTZakupka2^,nil, mfError + mfCancelButton);
   End;




  if skidka in [0,1] then{ручной режим контроль себестоимости}
  If ((StrToReal(SRZena)-StrTOReal(El.Skidka))-(StrToReal(SMin)))<-0.005 Then
   Begin
    MessageBox(^M+#3+'Товар продается ниже минимальнодопустимой цены '+SMin,nil, mfError + mfCancelButton);
    GoTo 1;
   End;


  if skidka in [1] then{ручной режим контроль минимальной наценки клиента и спец.цены}
  If SClientMinZena[0]<>#0 Then
  If ((StrToReal(SRZena)-StrTOReal(El.Skidka))-(StrToReal(SClientMinZena)))<-0.005 Then
   Begin
    MessageBox(^M+#3+'Товар продается ниже минимальнодопустимой цены для клиента '+SClientMinZena,
    nil, mfError + mfCancelButton);
    GoTo 1;
   End;






  If Selector in [0,1] Then
  Begin
  If (StrTOReal(El.Skidka))>(StrtoReal(SRZena){(StrToReal(GetRZena(SArtikul))}) Then
   Begin
      MessageBox(^M+'Скидка превышает розничную цену!'^M+
                 'Повторите ввод ! ',nil, mfError + mfCancelButton);
      GoTo 1;
   End;




  If StrToreal(El.Skidka)>=StrToReal(SRZena)/2 Then
   Begin
    If Not(Password(4)) Then Goto 1;
   End;
  End
   Else
    Begin
     If (StrTOReal(El.Skidka))>(StrToReal(SOZena){(StrToReal(GetOZena(SArtikul))}) Then
      Begin
       MessageBox(^M+'Скидка превышает оптовую цену!'^M+
                'Повторите ввод!',nil, mfError + mfCancelButton);
       GoTo 1;
      End;
  If StrToreal(El.Skidka)>=StrToReal(SRZena)/2 Then
   Begin
    If Not(Password(4)) Then Goto 1;
   End;
    End;
End
 Else
  Begin
   If Regim=1 Then
    Begin
     If StrToInt(GetKolDocumentWithLink(SArtikul))>StrToInt(El.FantomKol) Then
      Begin
       MessageBox(SeeTovar^,Nil,mfError+mfCancelButton);
       Goto 1;
      End;
    End;{Regim=1}
  End;

 MyStr(StrToReal(El.Skidka),CZena,CMantissa,El.Skidka);
 MyStr(StrToReal(El.FantomSkidka),CZena,CMantissa,El.FantomSkidka);
 MyStr(StrToReal(El.FantomNZena),CZena,CMantissa,El.FantomNZena);

{ResKol:='    0';{по умолчанию нуль отформатировано под 5 символов}
ResKol[0]:=#0;
If Not(AddSertif) Then
Begin
   If localregim=0 Then Str(StrTOInt(El.FantomKol):CKol,ResKol)
   Else
    Begin
       Str(StrTOInt(El.FantomKol):CKol,ResKol);
    End;
End;

If Not(AddSertif) Then
Begin
   s:=SArtikul+'│'+SName+'│'+SOtd+'│';
   With El Do
   Begin
    Str(StrToInt(Kol):CKol,Kol);
    Format(Kol,CKol);

    Str(StrToInt(FantomKol):CKol,FantomKol);
    Format(FantomKol,CKol);

    MyStr(StrToReal(Skidka),CZena,CMAntissa,Skidka);
    Format(Skidka,CZena);


   If (Selector in [0,1]) Then
    MyStr(StrToReal(SRZena),CZena,CMantissa,ws)
   Else MyStr(StrToReal(SOZena),CZena,CMantissa,ws);

    Format(ws,CZena);
    Format(ws1,CZena);
    Format(slitr,CLitr);
    Format(sNalog,CLitr);
    Format(sNDS,CLitr);

    s:=s+Kol+'│'+SLitr+'│'+ws+'│'+Skidka+'│';

    {Имя код отд кол литраж цена скидка сумма цена Р Цена О Налог ВидНП НДС ВидНДС Закупка}
   If (Selector in [0,1]) Then MyStr((StrToReal(SRZena)*StrToInt(El.Kol)),CInputIZena,CMantissa,ws)
   Else
    MyStr((StrToReal(SOZena)*StrToInt(El.Kol)),CInputIZena,CMantissa,ws);
    DelSpace(ws);
    Format(Ws,CInputIZena);
    Format(SZakupka,CZenaZ);
    Format(SZakupka2,CZenaZ);
    Format(SAkzisSbor,CZenaZ);
    Format(SZenaMArki,CZenaZ);
    Format(SOZena,CZena);
    Format(SRZena,CZena);
    s:=s+ws+'│'+SRZena+'│'+SOZena+'│'+SNalog+'│'+IntToStr(VidNalog,COne)+
    '│'+SNDS+'│'+IntToStr(VidNDS,COne)+'│'+SZakupka+'│'+SZakupka2+'│'+IntToStr(SRegion,COne)+
    '│'+SAkzisSbor+'│'+SZenaMarki+'│'+SFantomArtikul+'│'+ResKol;
    {MemC(s);}
   End;

  If Regim=1 Then
    Begin
     Regim:=Prodaga^.Focused;
     Prodaga^.List^.AtFree(Prodaga^.Focused);
     Prodaga^.SetRange(Prodaga^.List^.Count);
    End;

   Prodaga^.List^.Insert(NewStr(S));
   Prodaga^.SetRange(Prodaga^.List^.Count);
   Prodaga^.FocusItem(Location(Prodaga,SArtikul,True));
   Set_OSD(SArtikul,OSDList);
{
For c :=0 To OSDList^.List^.Count Do
Begin
S:=OSDList^.GetText(c,OSDList^.List^.Count);
Writeln(s);
End;
Readln;
}


End;{редактируем продажу только если речь идет о товаре}

 MyStr(StrToReal(El.FantomSkidka),CZena,CMantissa,El.FantomSkidka);
 MyStr(StrToReal(El.FantomNZena),CZena,CMantissa,El.FantomNZena);

 Format(SFAntomName,CNAme);
 s:=SFantomArtikul+'│'+SFAntomName+'│'+
    IntToStr(StrToInt(ActiveFantomOtdel),COne)+'│';

{If (LocalRegim=0) And (StrToInt(El.FantomKol)>0) Then}
{Если LocalRegim=0 тогда по-любому нужно добавлять строку}
{      Begin}

 Str(StrToInt(FullFantomKol)-StrToInt(PrevFantomKol)+StrTOInt(El.FantomKol):CKol,El.FantomKol);

{$IFDEF DPMI}
       If LocalRegim=1 Then
           Begin
            Position:=GetListNumer(SFantomArtikul);
         ProdagaDoc^.List^.AtFree(Position);
         ProdagaDoc^.SetRange(ProdagaDoc^.List^.Count);
         ProdagaDoc^.FocusItem(0);
        End;

       If StrToInt(El.FantomKol)<>0 Then
        Begin
       Format(El.FantomKol,CKol);
       MyStr(StrToReal(El.FantomSkidka),CZena,CMAntissa,El.FantomSkidka);
       Format(El.FantomSkidka,CZena);
       If (Selector in [0,1]) Then MyStr(StrToReal(SFantomRZena),CZena,CMantissa,ws)
       Else MyStr(StrToReal(SFantomOZena),CZena,CMantissa,ws);
       Format(ws,CZena);
       Format(sFantomlitr,CLitr);
       Format(sFantomNalog,CLitr);
       Format(sFantomNDS,CLitr);
       Format(sFantomRZena,CZena);
       Format(sFantomOZena,CZena);
       Format(sFantomZakupka,CZenaZ);
       Format(sFantomZakupka2,CZenaZ);
       s:=s+El.FantomKol+'│'+SFantomLitr+'│'+ws+'│'+El.FantomSkidka+'│';
       {Имя код отд кол литраж цена скидка сумма цена Р Цена О Налог ВидНП НДС ВидНДС Закупка}
       If (Selector in [0,1]) Then MyStr((StrToReal(SFantomRZena)*StrToInt(El.FantomKol)),
          CInputIZena,CMantissa,ws)
       Else
          MyStr((StrToReal(SFantomOZena)*StrToInt(El.FantomKol)),CInputIZena,CMantissa,ws);
       DelSpace(ws);
       Format(Ws,CInputIZena);
       Format(SFantomZakupka,CZenaZ);
       Format(SFantomZakupka2,CZenaZ);
       s:=s+ws+'│'+SFantomRZena+'│'+SFantomOZena+'│'+SFantomNalog+'│'+IntToStr(SFantomVidNalog,COne)+
       '│'+SFantomNDS+'│'+IntToStr(SFantomVidNDS,COne)+'│'+SFantomZakupka+'│'+SFantomZakupka2;

       ProdagaDoc^.List^.Insert(NewStr(S));
       ProdagaDoc^.SetRange(ProdagaDoc^.List^.Count);
       ProdagaDoc^.FocusItem(Location(ProdagaDoc,SFantomArtikul,True));
      End{Kol>0}

{$ENDIF}

(*    End

     Else
      Begin
       If Regim=0 Then
        Begin
         If (LocalRegim=0) Then
          Begin
          End{LocalRegim=0}
           Else
            Begin
            End;{LocalRegim=1}
        End
        Else
         Begin

         End;
      End;
*)
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(MarketWin,Done);
 End;
End;

{$ELSE}
Procedure TMarketWindow.Ini(s:String;Regim:Word;DisableTovar,DisableDocument:Boolean);
Begin
End;
{$ENDIF}

Destructor TMarketWinDow.Done;
Begin
Dispose(Pack,Done);
Dispose(ControlPack,Done);
Dispose(ControlKol,Done);
Dispose(ControlNZena,Done);
Dispose(Control1Skidka,Done);
Dispose(ControlFantomKol,Done);
Dispose(ControlFantomNZena,Done);
Dispose(ControlFantomSkidka,Done);

If MarketWin^.FindPrevOtgruzka Then{если была отгрузка этого документа}
Begin
Dispose(ControlRemarka,Done);
End;

Dispose(ControlBox,Done);
TDialog.Done;
End;




procedure TMarketWindow.HandleEvent(var Event: TEvent);

Procedure DrawZena;
Var s: String[CPack];
    R : TRect;
    c,Color : Word;
    Zena : TDateString;
    i : Byte;
Begin
    ControlNZena^.GetData(El.NZena);
    Control1Skidka^.GetData(El.Skidka);
    ControlFantomNZena^.GetData(El.FantomNZena);
    ControlFantomSkidka^.GetData(El.FantomSkidka);
    If Not AddSertif Then
    Begin
    Zena:=BakGetField(FRZena,SArtikul,c);
    MyStr(StrToReal(Zena)-StrToreal(El.Skidka),CZena,CMantissa,El.NZena);
    DelSpace(El.NZena);
    ControlNZena^.SetDAta(El.NZena);
    End;

    Zena:=BakGetField(FRZena,SFantomArtikul,c);
    MyStr(StrToReal(Zena)-StrToreal(El.FantomSkidka),CZena,CMantissa,El.FantomNZena);
    DelSpace(El.FantomNZena);
    ControlFantomNZena^.SetDAta(El.FantomNZena);
End;



Procedure DrawSkidka;
Var s: String[CPack];
    R : TRect;
    c,Color : Word;
    Zena : TDateString;
    i : Byte;
Begin
    {MarketWin^.GetData(El);}
    ControlNZena^.GetData(El.NZena);
    Control1Skidka^.GetData(El.Skidka);
    ControlFantomNZena^.GetData(El.FantomNZena);
    ControlFantomSkidka^.GetData(El.FantomSkidka);
    If Not AddSertif Then
    Begin
    Zena:=BakGetField(FRZena,SArtikul,c);
    MyStr(StrToReal(Zena)-StrToreal(El.NZena),CZena,CMantissa,El.Skidka);
    DelSpace(El.Skidka);
    Control1Skidka^.SetDAta(El.Skidka);
    End;
    Zena:=BakGetField(FRZena,SFantomArtikul,c);
    MyStr(StrToReal(Zena)-StrToreal(El.FantomNZena),CZena,CMantissa,El.FantomSkidka);
    DelSpace(El.FantomSkidka);
    ControlFantomSkidka^.SetDAta(El.FantomSkidka);
End;





procedure Calculator;
begin
  Calc^.Start;
end;


Function InputLocalSkidka(Var St1:TDateString;Const Reg :Boolean):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  st : ArtikulStr;
  Zena : TDateString;
  Event : TEvent;
begin
InputLocalSkidka:=False;
St1[0]:=#0;
c:=1;
If Reg Then
Begin
Control1Skidka^.GetData(El.Skidka);
If Selector in[0,1] Then
Zena:={El.NZena}BakGetField(FRZena,SArtikul,c)
Else
Zena:={El.NZena}BakGetField(FOZena,SArtikul,c);

If StrToREal(El.Skidka)>=0.01 Then
 Begin
  If (StrToReal(Zena)-StrToReal(El.Skidka))>0.009 Then
  Begin
  MyStr(((StrToReal(Zena))/((StrToReal(Zena)-StrToReal(El.Skidka)))-1),COne,CLitrMantissa,st);
  System.Delete(st,Pos('.',st)-1,2);
  System.Delete(st,Pos('-',st)-1,2);
  End
   Else St:='0';
 End
 Else St:='0';

End
 Else
Begin
ControlFantomSkidka^.GetData(El.FantomSkidka);
If Selector in[0,1] Then
Zena:=BakGetField(FRZena,SFantomArtikul,c)
Else
Zena:=BakGetField(FOZena,SFantomArtikul,c);
If StrToREal(El.FantomSkidka)>=0.01 Then
 Begin
  If (StrToReal(Zena)-StrToReal(El.FantomSkidka))>0.009 Then
  Begin
  MyStr(((StrToReal(Zena))/((StrToReal(Zena)-StrToReal(El.FantomSkidka)))-1),COne,CLitrMantissa,st);
  System.Delete(st,Pos('.',st)-1,2);
  System.Delete(st,Pos('-',st)-1,2);
  End
   Else St:='0';
 End
 Else St:='0';
end;


 DelSpace(St);

R.Assign(28, 9, 45, 12);
New(Dlg, Init(R, 'Скидка'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E004;
R.Assign(10, 1, 15, 2);
Control := New(PInputLine, Init(R, CLitrMantissa));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(1, 1, 9, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Скидка:', Control)));

{
R.Assign(15, 1, 18, 2);
Control := New(PStaticText, Init(R, '%'));
Dlg^.Insert(Control);
}

R.Assign(9, 1, 11, 2);
Control := New(PColoredText, Init(R, '1.', $1F));
Dlg^.Insert(Control);


Dlg^.SetData(St);

Dlg^.SelectNext(False);
Event.KeyCode:=kbEnd;
Event.What:=evKeyDown;
PutEvent(Event);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(st);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  DelSpace(St);

  If (St[1] in['2','3','4','5']) And Not(CurrentPassword='00') Then
   If Not (NewPassword(4)) Then Exit;

  St:='1.'+st;
  If StrToReal(st)>1.5 Then
   Begin
    Messagebox(^M+#3'Недопустимая ВЕЛИЧИНА скидки!',Nil,mfError+mfCancelButton);
    Exit;
   End;
  If StrToReal(st)<1.00 Then
   Begin
    Messagebox(^M+#3'Недопустимое ЗНАЧЕНИЕ скидки!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   {}
   If reg Then
   Begin
   MyStr(StrToReal(Zena)-(StrToReal(Zena)/(StrToReal(st))),CZena,CMantissa,El.Skidka);
   DelSpace(El.Skidka);
   St1:=El.Skidka;
   End
    Else
     Begin
   MyStr(StrToReal(Zena)-(StrToReal(Zena)/(StrToReal(st))),CZena,CMantissa,El.FantomSkidka);
   DelSpace(El.FantomSkidka);
   St1:=El.FantomSkidka;
     End;
   InputLocalSkidka:=True;
 End
 Else
 Begin
  St1[0]:=#0;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
end;



Function InputLocalNazenka(Var St1:TDateString;Const Reg :Boolean):Boolean;
var
   Dlg : PDialog;
     R : TRect;
Control: PView;
  c    : Word;
  st   : ArtikulStr;
  Zena : TDateString;
  Event: TEvent;
begin
{If Not(Password(2)) Then Exit;} {убрал по желанию бакши}
St1[0]:=#0;
InputLocalNazenka:=False;

c:=1;

If Reg Then
Begin
Control1Skidka^.GetData(El.Skidka);
If Selector in[0,1] Then Zena:=BakGetField(FRZena,SArtikul,c)
Else Zena:=BakGetField(FOZena,SArtikul,c);

If (StrToREal(El.Skidka))<=-0.01 Then
 Begin
  If StrToReal(Zena)>=0.009 Then
  MyStr((
      (Abs(StrToReal(El.Skidka))
      )
      /(
        (StrToReal(Zena)
        )
       )*100
     ),CKol,CMantissa,st)
  Else St:='0';
 End
 Else St:='0';
End
Else
 Begin
 ControlFantomSkidka^.GetData(El.FantomSkidka);
  If Selector in[0,1] Then Zena:=BakGetField(FRZena,SFantomArtikul,c)
  Else Zena:=BakGetField(FOZena,SFantomArtikul,c);

If (StrToREal(El.FantomSkidka))<=-0.01 Then
 Begin
  If StrToReal(Zena)>=0.009 Then
  MyStr((
      (Abs(StrToReal(El.FantomSkidka))
      )
      /(
        (StrToReal(Zena)
        )
       )*100
     ),CKol,CMantissa,st)
  Else St:='0';
 End
 Else St:='0';
 End;


 DelSpace(St);

R.Assign(29, 10, 50, 13);
New(Dlg, Init(R, 'Наценка'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E003;
R.Assign(10, 1, 17, 2);
Control := New(PInputLine, Init(R, CKol));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 1, 10, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Наценка:', Control)));

R.Assign(18, 1, 20, 2);
Control := New(PColoredText, Init(R, '%',$BE));
Dlg^.Insert(Control);

Dlg^.SetData(St);
Dlg^.SelectNext(False);

{Event.KeyCode:=kbEnd;
Event.What:=evKeyDown;
PutEvent(Event);}

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(st);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  DelSpace(St);
  InputLocalNazenka:=True;
  If reg Then
  Begin
  MyStr((StrToReal(Zena)*StrToReal(st)/(-100)),CZena,CMantissa,El.Skidka);
  DelSpace(El.Skidka);
  St1:=El.Skidka;
  End
  Else
  Begin
  MyStr((StrToReal(Zena)*StrToReal(st)/(-100)),CZena,CMantissa,El.FantomSkidka);
  DelSpace(El.FantomSkidka);
  St1:=El.FantomSkidka;
  End;
 End
 Else
 Begin
  St1[0]:=#0;
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
end;

{$IFDEF PHARM}
Function NazenkaOutZakupkaOI:Boolean;
Var
    Dlg : PDialog;
      R : TRect;
 Control: PView;
   c,res   : Word;
   Nazenka,st,ck: ArtikulStr;
   BBB  : PBazType;
   s    : String;
   Zena,
   SProz,Proz,ProzImport,FFClientProz : TDateString;
   Txt,SZakupka,Strana : AllStr;



begin
NazenkaOutZakupkaOI:=False;

PStaticText(ControlClientLabel)^.GetText(S);
System.Delete(S,Pos(#3,S),1);
Ck:=Copy(s,1+CClient+1,CClientKod);

If StrToInt(GetClientField(FPrice,ck,OperatorSelector))=0 Then
 Begin
  MessageBox(^M+#3'У клиента отключено автоформирование прайс-листа!'+
  'Запрошенная Вами функция недоступна!',Nil,mfWarning+mfCancelButton);
  Exit;
 End;

c:=1;

Zena:=BakGetField(FRZena,SArtikul,c);
SZakupka:=BakGetField(FZakupka,SArtikul,c);
res:=StrToInt(GetClientField(FDisableControlNaz,ck,OperatorSelector));

If res=0 Then
  {вариант формирования от закупочных цен}
  Begin
    Proz:=GetClientField(FProz,ck,OperatorSelector);
    ProzImport:=GetClientField(FProzImport,ck,OperatorSelector);
    New(BBB,Init);
    BBB^.Dat.BazKod:=SArtikul;
    GetBazElement(SArtikul,BBB^.Dat);
    Strana:=GetPostField(FPost,BBB^.Dat.PostKod);
    Txt :='От ЗЦ';
    If (Pos('РОССИЯ',Strana)>0) Or
     (Pos('БЕЛАРУСЬ',Strana)>0) Or
     (Pos('УКРАИНА',Strana)>0) Or
     (Pos('ЭСТОНИЯ',Strana)>0) Or
     (Pos('АРМЕНИЯ',Strana)>0) Or
     (Pos('ЛАТВИЯ',Strana)>0) Or
     (Pos('ЛИТВА',Strana)>0) Then
     Begin
      MyStr((StrToReal(Proz)-1.00)*100,CKOl,CMantissaZ,st);
     End
     Else
      Begin
       MyStr((StrToReal(ProzImport)-1.00)*100,CKOl,CMantissaZ,st);
      End;
    Dispose(BBB,Done);
  End
Else
 Begin
   Proz:=GetClientField(FMinimalProz,ck,OperatorSelector);
   MyStr(StrToReal(Proz),CKOl,CMantissaZ,st);
   Txt :='От РЦ';
 End;

DelSpace(St);

R.Assign(29, 10, 55, 14);
If Res=0 Then
New(Dlg, Init(R, 'Наценка от ЗЦ'))
Else
New(Dlg, Init(R, 'Наценка от РЦ'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E003;
R.Assign(10, 1, 17, 2);
Control := New(PInputLine, Init(R, CKol));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.','-']));

  R.Assign(1, 1, 10, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Наценка:', Control)));

R.Assign(2, 2, 17, 3);
Control := New(PStaticText, Init(R, #3+txt+':'+St));
Dlg^.Insert(Control);

R.Assign(18, 1, 20, 2);
Control := New(PColoredText, Init(R, '%',$BE));
Dlg^.Insert(Control);

Dlg^.SetData(St);
Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(st);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  DelSpace(St);
  NazenkaOutZakupkaOI:=True;
  If res=0 Then
  Begin
  MyStr((StrToReal(SZakupka)*(1+StrToReal(st)/100)),CZena,CMantissa,El.NZena);
  MyStr(StrToReal(Zena)-StrToReal(El.NZena),CZena,CMantissa,El.Skidka);
  DelSpace(El.Skidka);
  End
  Else
  Begin
  MyStr((StrToReal(Zena)*(1+StrToReal(st)/100)),CZena,CMantissa,El.NZena);
  MyStr(StrToReal(Zena)-StrToReal(El.NZena),CZena,CMantissa,El.Skidka);
  DelSpace(El.Skidka);
  End;
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
end;
{$ENDIF}




{$IFNDEF Pharm}
Procedure RecalcZeniDixy(sv:Word;Var NewZena:AllStr);
Var MainKod : ArtikulStr;
    Delta,DixyZen,RZ,Marka,Akzis,Zakupka : AllStr;
    Skl : PSkladType;
Begin
 NewZena[0]:=#0;
 MainKod:=CalcMainKod(SArtikul);


 If TestDixyElement2(MainKod) Then DixyZen:=GetDixyZena(sv,MainKod)
 Else Exit;


 New(Skl,Init);
 Skl^.Dat.BazKod:=SArtikul;

 GetSkladRecord(Skl);
 Marka[0]:=#0;
 Akzis[0]:=#0;
 Zakupka:=Skl^.Dat.Input.Zakupka;
 If Skl^.Dat.Input.RegionMarka=1 Then
  Begin
   Marka:=Skl^.Dat.Input.ZenaMarki;
   Akzis:=Skl^.Dat.Input.AkzisSbor;
  End;
 Dispose(Skl,Done);

 MyStr(StrToReal(Zakupka)+StrToReal(MArka)+StrToReal(Akzis)*1.18,CIZena,CMAntissaZ,Zakupka);

 If StrToReal(DixyZen)<StrToReal(Zakupka) Then
  Begin
   MessageBox(^M+#3+'Внимание спеццена реализации '+DixyZen+' у '+SArtikul+' меньше закупочной цены '+
   Zakupka+'!',Nil,mfWarning+mfCancelButton);
   Exit;
  End;

 {новая закупка}

 MyStr(StrToReal(DixyZen)-StrToReal(Zakupka),CIZena,CMAntissaZ,Delta);


 MyStr(StrToReal(Delta)*0.4,CIZena,CMAntissa,Delta);

 MyStr(StrToReal(Zakupka)+StrToReal(Delta),CZena,CMAntissa,NewZena);
 DelSpace(NewZena);

{1.Вычисляем главный код по позиции
 2.вычисляем закупочную цену  для акцизного товара a)ЗЦ+АКЦ*1.18+1.35!
                                                   b)ЗЦ
 3.Вычисляем цену дикси по этой позиции если таковой нет то возвращаем пустую строку
   и сообщение что такой цены не найдено!
 4.делим делту на 60% и 40%
 5.к новой закупке прибавляем 40% и получаем новую закупку}

End;

{$ENDIF}


Procedure ReCalc;
Var s,sz : AllStr;
    R : TRect;
    NDS,sr1,sr2,sr : String[CZena];
    Color : Word;
    SRegion : AllStr;
Begin
                 s:=PStaticText(ControlZakupka)^.Text^;
                 ControlNZena^.GetData(sr);
If (EnableZakupka=1) Or (StrToInt(CurrentPassword)=0) Then
If Skidka=1 Then
Begin
                 sz:=Copy(s,1,Pos('(',s)-1);
                 ControlNZena^.GetData(sr);
                 DelSpace(Sz);
                 DelSpace(Sr);
                 If StrToReal(sz)>0.009 Then
                 Begin
                  s[0]:=#0;
                  MyStr((StrToREal(sr)-StrToReal(sz))/StrToReal(sz)*100,CLitr,CMantissa,s);
                  s:='('+s+'%)';
                 End
                 Else s:='(??.??%)';
                 s:=sz+s;
End;
                 Dispose(ControlZakupka,Done);
                 R.Assign(61, 3, 79, 4);
                 If (ViewZakupka) Then
                 ControlZakupka := New(PColoredText, Init(R,s, $31))
                 Else
                 ControlZakupka:=New(PColoredText, Init(R, s, $33));
                 MarketWin^.Insert(ControlZakupka);

{$IFDEF Pharm}
Dispose(ControlGR,Done);
Color:=$33;
R.Assign(1, 2, 11 , 4);


Sr1:=SGRZena;
NDS:=GetIDField(FNDS,SArtikul);
MyStr(StrToReal(Sr1)+StrToReal(Sr1)*StrToReal(NDS)/(100),CZena,CMAntissa,Sr2);
MyStr(StrToReal(Sr1),CZena,CMAntissa,Sr1);
DelSpace(sr1);
DelSpace(sr2);



  SRegion:='ГР:'+SR1+^M+
  +'   ('+SR2+')';
  Color:=$5E;
{
 End
 Else
  SRegion:='';
}
ControlGR := New(PColoredText, Init(R, #3+SRegion, Color));
MarketWin^.Insert(ControlGR);
{$ENDIF}

    Redraw;
    ClearEvent(Event);
End;




VAr DZ,DS,ShowWarning : Boolean;
    InputPack   : ArtikulStr;
    St : TDateString;
    s : AllStr;
    R : TRect;
    Z : Word;
    Sk : TDateString;
    Ck : String[CCLientKod];
    NewZena : String[CZena];
    sv : Word;


Begin
Case Event.What Of
 evCommand :
   Case Event.Command Of
        cmLocalCalc: Calculator;

cmViewPrihodTovar
     :Begin
       If Not(AddSertif) Then FP^.FindScreenPrh(SArtikul)
       Else FP^.FindScreenPrh(SFAntomArtikul);
       ClearEvent(Event);
      End;

        cmViewBron : Begin
      Begin
       If Not(AddSertif) Then FR^.Start(SArtikul,True)
       Else FR^.Start(SFantomArtikul,True);
       ClearEvent(Event);
      End;
                        End;

        cmLastZeni2   :Begin
                If (Skidka=1) And (OperatorSelector=0) Then
                If  Not(AddSertif) Then
                   Begin
                    PStaticText(ControlClientLabel)^.GetText(S);
                    System.Delete(S,Pos(#3,S),1);
                    Ck:=Copy(s,1+CClient+1,CClientKod);
                    LaStZena^.Start(SArtikul,Ck,NewZena);

                    If NewZena[0]<>#0 Then
                     Begin
                      ControlNZena^.SetData(NewZena);
                      El.NZena:=NewZena;
                      DrawSkidka;
                      DrawZena;
                      Recalc;
                     End;
                     Redraw;

                   End;
                End;


      cmLocalSkidka: If Skidka=1 Then Begin

  if(Control1Skidka^.State and sfFocused <> 0) Or
    (ControlNZena^.State and sfFocused <> 0) Or
    (Pack^.State and sfFocused <> 0) Or
    (ControlKol^.State and sfFocused <> 0) Then
                                          If InputLocalSkidka(St,True) Then
                                        Begin
                                         Control1Skidka^.SetDAta(St);
                                         MarketWin^.Redraw;
                                         DrawZena;
                                         Recalc;
                                        End;

  if(ControlFantomSkidka^.State and sfFocused <> 0) Or
    (ControlFantomNZena^.State and sfFocused <> 0) Or
    (ControlFantomKol^.State and sfFocused <> 0) Then
                                          If InputLocalSkidka(St,False) Then
                                        Begin
                                         ControlFantomSkidka^.SetDAta(St);
                                         MarketWin^.Redraw;
                                         DrawZena;
                                         Recalc;
                                        End;
                                                           End;

{$IFNDEF Pharm}
     cmDixyZeni    : Begin
                      If Skidka=1 Then
                      If EnableDixyZeni=1 Then
                       Begin
                        NewZena[0]:=#0;
                        sv:=SelectImport(40);
                        if sv=2 Then Exit;
                        RecalcZeniDixy(sv,NewZena);
                        {пересчет происходит только для сучая когда есть цена ДИКСИ}
                        If NewZena[0]<>#0 Then
                        Begin
                        ControlNZena^.SetData(NewZena);
                        El.NZena:=NewZena;
                        End;
                        DrawSkidka;
                        DrawZena;
                        Recalc;
                       End;
                      Redraw;
                    End;
{$ENDIF}

     cmLocalNazenka: If Skidka=1 Then Begin
  if(Control1Skidka^.State and sfFocused <> 0) Or
    (ControlNZena^.State and sfFocused <> 0) Or
    (Pack^.State and sfFocused <> 0) Or
    (ControlKol^.State and sfFocused <> 0) Then
                                          If InputLocalNazenka(St,True) Then
                                        Begin
                                         Control1Skidka^.SetDAta(St);
                                         MarketWin^.Redraw;
                                         DrawZena;
                                         Recalc;
                                        End;

  if(ControlFantomSkidka^.State and sfFocused <> 0) Or
    (ControlFantomNZena^.State and sfFocused <> 0) Or
    (ControlFantomKol^.State and sfFocused <> 0) Then
                                          If InputLocalNazenka(St,False) Then
                                        Begin
                                         ControlFantomSkidka^.SetDAta(St);
                                         MarketWin^.Redraw;
                                         DrawZena;
                                         Recalc;
                                        End;
                                                         End;
   Else;
   End;
 evKeyDown:
   Case Event.KeyCode Of
 {
 kbF5:Begin
       Art:=Copy(Baz^.GetText(Baz^.Focused,Baz^.List^.Count),1+CName+1,Cartikul);
       FR^.Start(Art);
       ClearEvent(Event);
      End;
}
        kbAltF1:Begin
                    Event.What:=evCommand;
                    Event.Command:=CmLocalSkidka;
                    PutEvent(Event);
                End;
        kbAltF2:Begin
                    Event.What:=evCommand;
                    Event.Command:=CmLocalNazenka;
                    PutEvent(Event);
                End;
        kbF6:
             begin
              ViewZakupka:=Not ViewZakupka;
              Recalc;
              ClearEvent(Event);
             end;
{вставка скидки по шкале}
        kbF2,kbAltSpace,kbCtrlRusSh:
                begin
{только в режиме руной скидки}
  If Skidka=1 Then
  Begin
  if(Control1Skidka^.State and sfFocused <> 0) Or
    (ControlNZena^.State and sfFocused <> 0) Or
    (Pack^.State and sfFocused <> 0) Or
    (ControlKol^.State and sfFocused <> 0) Then
                Begin

                 If GetShkalaSkidka(SArtikul,Sk) Then
                 Begin
                  Control1Skidka^.SetData(Sk);
                  El.Skidka:=Sk;
                  DrawZena;
                  DrawSkidka;
                  Recalc;
                 End;
                 Redraw;
                End;

  if(ControlFantomSkidka^.State and sfFocused <> 0) Or
    (ControlFantomNZena^.State and sfFocused <> 0) Or
    (ControlFantomKol^.State and sfFocused <> 0) Then
                Begin

                 If GetShkalaSkidka(SFantomArtikul,Sk) Then
                 Begin
                  ControlFantomSkidka^.SetData(Sk);
                  El.FantomSkidka:=Sk;
                  DrawZena;
                  DrawSkidka;
                  Recalc;
                 End;
                 Redraw;
                End;
                 ClearEvent(Event);
  End;
                end;

{$IFDEF Pharm}
  kbF8   : Begin
               If ((Skidka=1) And (OperatorSelector in [0,2])) Then
               Begin
                PStaticText(ControlClientLabel)^.GetText(S);
                System.Delete(S,1,1);
                Begin
                  If NazenkaOutZakupkaOI Then
                  Begin
                   Control1Skidka^.SetData(El.Skidka);
                   DrawZena;
                   DrawSkidka;
                   Recalc;
                  End;

                End;
               End;
                ClearEvent(Event);
           End;
{$ENDIF}


        kbCtrlRusC,kbF9:Begin
{только в режиме ручной скидки}
  If Skidka=1 Then
  Begin
  if(Control1Skidka^.State and sfFocused <> 0) Or
    (ControlNZena^.State and sfFocused <> 0) Or
    (Pack^.State and sfFocused <> 0) Or
    (ControlKol^.State and sfFocused <> 0) Then
                Begin
                 NewZena:=BakGetField(FSpecZena,SArtikul,0);
                 MyStr(StrToreal(NewZena),CZena,CMantissa,NewZena);
                 DelSpace(NewZena);

                      ControlNZena^.SetData(NewZena);
                      El.NZena:=NewZena;
                      DrawSkidka;
                      DrawZena;
                      Recalc;
                 Redraw;
                End;
                 ClearEvent(Event);
  End;
             End;

        kbEnter:Begin
                inherited HandleEvent(Event);
                If ((MarketWin^.Current=Pack))
                         Or (AddSertif And (MarketWin^.Current=ControlFantomKol)) Then
                   Begin
                    Event.What:=evCommand;
                    Event.Command:=CmOk;
                   End;
                End;
   Else;
   End;
   Else;
   End;

  DZ:=False;
  DS:=False;

  If Skidka=1 Then
  If (Event.What=evKeyboard)And
  ((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.','-'])
Or (Event.KeyCode=kbDel)
Or (Event.KeyCode=kbBack)
Or (Event.KeyCode=kbShiftIns))
  And  ((Control1Skidka^.State and sfFocused <> 0)
  Or    (ControlFantomSkidka^.State and sfFocused <> 0)) Then
  DZ:=True;

  If Skidka=1 Then
  If (Event.What=evKeyboard)And((Event.CharCode in ['0','1','2','3','4','5','6','7','8','9','.','-'])
  Or (Event.KeyCode=kbDel) Or (Event.KeyCode=kbBack)
  Or (Event.KeyCode=kbShiftIns))
  And  ((ControlNZena^.State and sfFocused <> 0) Or
        (ControlFantomNZena^.State and sfFocused <> 0)) Then
  DS:=True;


  inherited HandleEvent(Event);

  If DZ Then
   Begin
    DrawZena;
    Recalc;
   End;

  If DS Then
   Begin
    DrawSkidka;
    Recalc;
   End;

  If (Pack^.State and sfFocused <> 0) Then
   Begin
    ShowWarning:=FAlse;
    InputPAck[0]:=#0;
    DrawKol(ShowWarning,InputPack);
    If ShowWarning Then
    Begin
     Sound(100);
     DinfoMsg('Внимание! В отделении ['+ActiveOtdel+'] нет такого количества '+InputPack+' шт.',False);
     Delay(700);
     NoSound;
     Delay(700);
     NoInfoMsg;
     ClearEvent(Event);
    End;
   End;
  DrawPack;
End;




Function CalcItog(Var ItogNalog:NalogType;Var Skid:AllStr;
Var Itogo:Float;Var Mesto:LongInt;Var Itogo_O: AllStr;Var SertifItogo,SertifSkidkaItogo:Float) : Float;

Var R : TRect;
    t,l : Float;
    SertifSr,nalogItogo,SertifnalogItogo,SkidkaItogo,
    Sl,Sk,So,Sr : Float;
    SA : ArtikulStr;
    RealZena,s : TMyString;
    Itogo_Zakupka,
    SertifItogo_Zakupka,
    Zakupka,
    Itogo_Zakupka2,
    SertifItogo_Zakupka2,
    Zakupka2,
    zena,nalogstr,ws,SArt,SSl,SSk,SSo,SSr,Itogo_R,Itogo_L:
    String[CIZena];
    ls : Word;
    VidNalog,kol :LongInt;
    TempCalc : PBox;
    Koefficient :String[CZena];
    AkzisSbor : AllStr;

Begin
SO:=0;
SR:=0;
SL:=0;
Mesto:=0;
SertifItogo:=0;
SertifSkidkaItogo:=0;
SertifItogo_Zakupka[0]:=#0;
SertifItogo_Zakupka2[0]:=#0;
SertifnalogItogo:=0;
kol:=0;

ItogNalog.SENalog[0]:=#0;
ItogNAlog.Akzis[0]:=#0;
ItogNalog.SNalog5[0]:=#0;
ItogNalog.SNalog3[0]:=#0;
ItogNalog.SNalog_[0]:=#0;
ItogNalog.SZakupka[0]:=#0;
ItogNalog.SZakupka2[0]:=#0;

If ProdagaDoc^.List^.Count>0 Then
Begin
For ls:=0 To ProdagaDoc^.List^.Count-1 Do
Begin
{артикул}
 Sa:=Copy(ProdagaDoc^.GetText(ls,ProdagaDoc^.List^.Count),1,CArtikul);
{литраж}
 SSl:=Copy(ProdagaDoc^.GetText(ls,ProdagaDoc^.List^.Count),1+CName+1+CArtikul+1+COne+1+CKol+1,CLitr);
 DelSpace(Ssl);
{колич}
 SSk:=Copy(ProdagaDoc^.GetText(ls,ProdagaDoc^.List^.Count),1+COne+1+CName+1+CArtikul+1,CKol);
 DelSpace(sSk);

 ws:=CalcPack(Sa,SSk);
 DelSpace(ws);
 If Pos('+',ws)>0 Then ws:=Copy(ws,1,Pos('+',ws)-1);
 Mesto:=Mesto+StrToInt(ws);

{Любая (оптовая или розничная зависит от вида документа) цена}
 SSo:=Copy(ProdagaDoc^.GetText(ls,ProdagaDoc^.List^.Count),1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);
 DelSpace(sso);

{Скидка}
 Skid:=Copy(ProdagaDoc^.GetText(ls,ProdagaDoc^.List^.Count),1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);
 DelSpace(skid);

 {добавлена 18-08-2000 для того чтобы при смене вида
  скидки с ручной на авто ручная скидка по сертификатам не учитывалась}
 If Skidka=0 Then Skid:='0.00';


 VidNalog:=StrToInt(Copy(ProdagaDoc^.GetText(ls,ProdagaDoc^.List^.Count),1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+
                        CZena+1+CInputIZena+1+COne+1+CZena+1+
                        CZena+1+clitr+1,COne));


{налог ставка налога}
 Nalogstr:=Copy(ProdagaDoc^.GetText(ls,ProdagaDoc^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+
               1+CInputIZena+1+CZena+1+CZena+1,CLitr);
 DelSpace(NalogStr);

 Zakupka:=Copy(ProdagaDoc^.GetText(ls,ProdagaDoc^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+
              CInputIZena+1+CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1,CZenaZ);

 Zakupka2:=Copy(ProdagaDoc^.GetText(ls,ProdagaDoc^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+
              CInputIZena+1+CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1,CZenaZ);


 kol:=StrToInt(ssk);{количество}


 t:=StrToReal(Skid);{размер позиционной скидки}
 SertifSkidkaItogo:=SertifSkidkaItogo+t*Kol;{велечина общей позиционной скидки}

 l:=StrToReal(SSl); {литраж}

 Sl:=Sl+L*Kol; {общий литраж}

 Sr:=Sr+l*Kol*Lizensia; {велечина ЛС}

 l:=StrToReal(SSo);{Цена}
 MyStr((l*Kol),CInputIZena,CMantissa,Itogo_L);


 l:=StrToReal(Zakupka);{Закупка}
 MyStr((l*Kol),CInputIZena,CMantissaZ,SertifItogo_Zakupka);

 l:=StrToReal(Zakupka2);{Закупка}
 MyStr((l*Kol),CInputIZena,CMantissaZ,SertifItogo_Zakupka2);


 MyStr((1+StrToReal(NalogStr)/100),CZena,CMantissaZ,Koefficient);
 DelSpace(Koefficient);

 MyStr(StrToReal(SSo)-StrToReal(Skid),CZena,CMAntissa,Zena);


 {т.к. сертификаты только на товарный чек то налог с продажи
  на них не считается}
 MyStr(StrToREal(Zena){/StrToReal(Koefficient)},CZena,CMantissa,RealZena);
 MySTr(StrToReal(Zena)-StrToReal(RealZena),CZena,CMantissa,RealZena);


 MyStr((StrToReal(SertifItogo_Zakupka)+StrToReal(ItogNalog.SZakupka)),CIZena,CMantissaZ,ItogNalog.SZakupka);
 MyStr((StrToReal(SertifItogo_Zakupka2)+StrToReal(ItogNalog.SZakupka2)),CIZena,CMantissaZ,ItogNalog.SZakupka2);

{расчитываем если необходимо велечину спец налога}
If Selector in [{1,}2,3,5,6] Then
Begin
{велечина спец налога с единицы товара}

MyStr(StrToReal(RealZena)*Kol,CIZena,CMantissa,RealZena);
DelSpace(RealZena);

{суммарная ставка налога}
MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.SENalog)),CIZena,CMantissa,ItogNalog.SENalog);
CAse VidNalog Of
0:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.SNalog5)),CIZena,CMantissa,ItogNalog.SNalog5);
1:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.SNalog3)),CIZena,CMantissa,ItogNalog.SNalog3);
2:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.SNalog_)),CIZena,CMantissa,ItogNalog.SNalog_);
Else;
End;
End;
So:=So+StrToReal(Itogo_L);{l*Kol};{стоимость всего накладной}
End;{for}
End;
{расчет итого по сертификатам завершен}

SertifItogo:=So;
SertifSr:=SertifItogo;


SO:=0;
SR:=0;
SL:=0;
Mesto:=0;
SkidkaItogo:=0;
Itogo_Zakupka[0]:=#0;
Itogo_Zakupka2[0]:=#0;
nalogItogo:=0;
kol:=0;

{расчет итого по товару}


ItogNalog.ENalog[0]:=#0;
ItogNalog.Nalog5[0]:=#0;
ItogNalog.Nalog3[0]:=#0;
ItogNalog.Nalog_[0]:=#0;
ItogNalog.Zakupka[0]:=#0;
ItogNalog.Zakupka2[0]:=#0;
ItogNalog.Akzis[0]:=#0;
If Prodaga^.List^.Count>0 Then
Begin
For ls:=0 To Prodaga^.List^.Count-1 Do
Begin
{артикул}
 Sa:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1,CArtikul);
{литраж}
 SSl:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+CName+1+CArtikul+1+COne+1+CKol+1,CLitr);
 DelSpace(Ssl);
{колич}
 SSk:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1,CKol);
 DelSpace(sSk);

 ws:=CalcPack(Sa,SSk);
 DelSpace(ws);
 If Pos('+',ws)>0 Then ws:=Copy(ws,1,Pos('+',ws)-1);
 Mesto:=Mesto+StrToInt(ws);

{Любая (оптовая или розничная зависит от вида документа) цена}
 SSo:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);
 DelSpace(sso);

{Скидка}
 Skid:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);
 DelSpace(skid);


 If StrToInt(Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),
 1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CZena+1+
 CZena+1+clitr+1+COne+1+Clitr+1+COne+1+CZenaZ+1+CZenaZ+1,COne))=1 {провереем есть региональная марка или нет} Then

 AkzisSbor :=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),
 1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CZena+1+
 CZena+1+clitr+1+COne+1+Clitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1,CZenaZ)
 Else
 AkzisSbor:='    0.0000';


 MyStr(StrToReal(ItogNAlog.Akzis)+
 StrToReal(AkzisSbor)*StrToInt(SSk),CIZena,CMantissaZ,ItogNAlog.Akzis);


 VidNalog:=StrToInt(Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+
                        CZena+1+CInputIZena+1+COne+1+CZena+1+
                        CZena+1+clitr+1,COne));


{налог ставка налога}
 Nalogstr:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+
               1+CInputIZena+1+CZena+1+CZena+1,CLitr);
 DelSpace(NalogStr);

 Zakupka:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+
              CInputIZena+1+CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1,CZenaZ);

 Zakupka2:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+
              CInputIZena+1+CZena+1+CZena+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1,CZenaZ);


 kol:=StrToInt(ssk);{количество}


 t:=StrToReal(Skid);{размер позиционной скидки}
 SkidkaItogo:=SkidkaItogo+t*Kol;{велечина общей позиционной скидки}

 l:=StrToReal(SSl); {литраж}

 Sl:=Sl+L*Kol; {общий литраж}

 Sr:=Sr+l*Kol*Lizensia; {велечина ЛС}

 l:=StrToReal(SSo);{Цена}
 MyStr((l*Kol),CInputIZena,CMantissa,Itogo_L);


 l:=StrToReal(Zakupka);{Закупка}
 MyStr((l*Kol),CInputIZena,CMantissaZ,Itogo_Zakupka);

 l:=StrToReal(Zakupka2);{Закупка}
 MyStr((l*Kol),CInputIZena,CMantissaZ,Itogo_Zakupka2);


 MyStr((1+StrToReal(NalogStr)/100),CZena,CMantissaZ,Koefficient);
 DelSpace(Koefficient);

 MyStr(StrToReal(SSo)-StrToReal(Skid),CZena,CMAntissa,Zena);


{$IFDEF NSP}
 MyStr(StrToREal(Zena)/StrToReal(Koefficient),CZena,CMantissa,RealZena);
 MySTr(StrToReal(Zena)-StrToReal(RealZena),CZena,CMantissa,RealZena);
{$ELSE}
 MyStr(StrToREal(Zena)*StrToReal(Koefficient),CZena,CMantissa,RealZena);
 MyStr(StrToReal(RealZena)-StrToReal(Zena),CZena,CMantissa,RealZena);
{$ENDIF}


 MyStr((StrToReal(Itogo_Zakupka)+StrToReal(ItogNalog.Zakupka)),CIZena,CMantissaZ,ItogNalog.Zakupka);
 MyStr((StrToReal(Itogo_Zakupka2)+StrToReal(ItogNalog.Zakupka2)),CIZena,CMantissaZ,ItogNalog.Zakupka2);

{расчитываем если необходимо велечину спец налога
 в товарном чеке налог с продажи отключен}
If Selector in [{1,}2,3,5,6] Then
Begin
{велечина спец налога с единицы товара}

MyStr(StrToReal(RealZena)*Kol,CIZena,CMantissa,RealZena);
DelSpace(RealZena);

{суммарная ставка налога}
MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.ENalog)),CIZena,CMantissa,ItogNalog.ENalog);
CAse VidNalog Of
0:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog5)),CIZena,CMantissa,ItogNalog.Nalog5);
1:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog3)),CIZena,CMantissa,ItogNalog.Nalog3);
2:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog_)),CIZena,CMantissa,ItogNalog.Nalog_);
Else;
End;
End;
So:=So+StrToReal(Itogo_L);{l*Kol};{стоимость всего накладной}
End;{for}
End;


Itogo:=So;
Sr:=Itogo;

If Skidka=0 Then
 Begin
ItogNalog.ENalog[0]:=#0;
ItogNalog.Nalog5[0]:=#0;
ItogNalog.Nalog3[0]:=#0;
ItogNalog.Nalog_[0]:=#0;
ItogNalog.SENalog[0]:=#0;
ItogNalog.SNalog5[0]:=#0;
ItogNalog.SNalog3[0]:=#0;
ItogNalog.SNalog_[0]:=#0;

If Prodaga^.List^.Count>0 Then
Begin
R.Assign(0, 0, 0, 0);
TempCalc := New(PBox, Init(R, 1, Nil));
TempCalc^.NewList(New(PTextCollection, Init(0,1)));
For ls:=0 To Prodaga^.List^.Count-1 Do
Begin
{артикул}
Sa:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1,CArtikul);

{колич}
SSk:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1,CKol);

{Любая (оптовая или розничная зависит от вида документа) цена}
SSo:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);

{налог ставка налога}
Nalogstr:=Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count),1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+
               1+CInputIZena+1+CZena+1+CZena+1,CLitr);

VidNalog:=StrToInt(Copy(Prodaga^.GetText(ls,Prodaga^.List^.Count)
          ,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CZena+1+
          CZena+1+clitr+1,COne));


If TestElement(Sa,TempCalc) Then
 Begin
   TempCalc^.List^.Insert(NewStr('│'+Sa+'│'+SSk+'│'+SSo+'│'+NalogStr+'│'+IntToStr(VidNalog,COne)));
   TempCalc^.SetRange(TempCalc^.List^.Count);
 End
  Else
   Begin
    TempCalc^.FocusItem(Location(TempCalc,Sa,False)); {нашли фокус}
    S:=TempCalc^.GetText(TempCalc^.Focused,TempCalc^.List^.Count);
    Skid:=Copy(s,2+Cartikul+1,CKol); {Выяснили количество в фокусе}
    Str(StrToInt(Skid)+StrToInt(SSk):CKol,Skid);{Вычислили новое количество}
    Format(Skid,CKol);
    TempCalc^.List^.AtFree(TempCalc^.Focused); {Удалили старую строку}
    System.Delete(s,2+Cartikul+1,CKol); {Подставли новое количество}
    System.Insert(skid,s,2+Cartikul+1);
    TempCalc^.List^.Insert(NewStr(s));
   End;
End;{for}

 Sr:=0;
 For ls:=0 To TempCalc^.List^.Count-1 Do
  Begin
  {артикул}
  Sa:=Copy(TempCalc^.GetText(ls,TempCalc^.List^.Count),2,CArtikul);
  {колич}
  SSk:=Copy(TempCalc^.GetText(ls,TempCalc^.List^.Count),2+CArtikul+1,CKol);
  {Любая (оптовая или розничная зависит от вида документа) цена}
  SSo:=Copy(TempCalc^.GetText(ls,TempCalc^.List^.Count),2+CArtikul+1+CKol+1,CZena);
  kol:=StrToInt(ssk);

  VidNalog:=StrToInt(Copy(TempCalc^.GetText(ls,TempCalc^.List^.Count),2+CArtikul+1+CKol+1+CZena+1+CLitr+1,COne));

  {Процент ставки спец налога}
  NalogStr:=Copy(TempCalc^.GetText(ls,TempCalc^.List^.Count),2+CArtikul+1+CKol+1+CZena+1,CLitr);
  DelSpace(NAlogStr);

  {старый вариант скидки}
  l:=StrToReal(SSo)/(1+GetSkidkaProz(Sa,Itogo)/100);

  MyStr(L,CZena,CMantissa,Itogo_L);






  MyStr((1+StrToReal(NalogStr)/100),CZena,CMantissaZ,Koefficient);
  DelSpace(Koefficient);

{$IFDEF NSP}
  MyStr(StrToReal(Itogo_L)/StrToReal(Koefficient),CZena,CMantissa,RealZena);
  MyStr((StrToReal(Itogo_L)-StrToReal(RealZena)),CZena,CMAntissa,RealZena);
{$ELSE}
  MyStr(StrToReal(Itogo_L)*StrToReal(Koefficient),CZena,CMantissa,RealZena);
  MyStr((StrToReal(Itogo_L)-StrToReal(RealZena)),CZena,CMAntissa,RealZena);
{$ENDIF}



  L:=StrToReal(Itogo_L);
{отключен расета налога с продажи в товарном чеке}
If Selector in [{1,}2,3,5,6] Then
Begin
  {расчитываем абсолютное значение сбора по спецналогу с единицы товара}
{  Str((StrToReal(RealZena)-StrToReal(Itogo_L)):CZena:CMantissa,NAlogStr);}
  {всего с позиции}
  MyStr(StrToReal(RealZena)*Kol,CIZena,CMantissa,RealZena);
  {суммарная ставка налога}
  MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.ENalog)),CIZena,CMantissa,ItogNalog.ENalog);
 CAse VidNalog Of
 0:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog5)),CIZena,CMantissa,ItogNalog.Nalog5);
 1:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog3)),CIZena,CMantissa,ItogNalog.Nalog3);
 2:MyStr((StrToReal(RealZena)+StrToReal(ItogNalog.Nalog_)),CIZena,CMantissa,ItogNalog.Nalog_);
 Else;
 End;
End;
  MyStr((L*Kol),CInputIZena,CMantissa,Itogo_L);

  Sr:=Sr+StrToReal(Itogo_L);


  End;{for}
  SkidkaItogo:=Itogo-Sr;

Dispose(TempCalc,Done);
End;
End;


Itogo:=Itogo-SkidkaItogo;
SertifItogo:=SertifItogo-SertifSkidkaItogo;

MyStr(Sl,CILitr,CLitrMantissa,Itogo_L);
DelSpace(Itogo_L);

MyStr(SkidkaItogo,CIZena,CMantissa,Skid);
DelSpace(Skid);

{отключен расета налога с продажи в товарном чеке}
If Selector in [{1,}2,3,5,6] Then
Begin
{$IFDEF NSP}
 MyStr((Itogo),CIZena,CMantissa,Itogo_O);
{$ELSE}
 MyStr((Itogo+STrToReal(ItogNalog.ENalog)),CIZena,CMantissa,Itogo_O);
{$ENDIF}
End
 Else MyStr(Itogo,CIZena,CMantissa,Itogo_O);


DelSpace(Itogo_O);

If Selector In [0,1] Then Sr:=0.00;
MyStr(Sr,CIZena,CMantissa,Itogo_R);
DelSpace(Itogo_R);

 CalcItog:=Itogo+SkidkaItogo;
End;






Procedure SetSkidkaFromRazdelMarket(RO:Boolean);
Var pItog,itog : Real;
    L : PSuperMarketType;
Begin
{
Itog := CalcItogo(ItogNAlog);

If Not FirstReadScreen(Itog,L,Skidka) Then
Begin
 Dispose(L,Done);
 Exit;
End;

 L^.Dat.Amount:=Prodaga^.List^.Count;
 L^.Dat.AmountS:=ProdagaDoc^.List^.Count;



}
End;







End.
