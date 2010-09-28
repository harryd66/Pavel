{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit Reestr;

Interface


Uses Dialogs,Drivers,Glob,Access,ServStr,Utils;

Type
  PReestrWindow = ^TReestrWindow;
  TReestrWindow = object(TDialog)
    ViewMrk  : PFullScreenMrk;
    constructor Init(Var l: Boolean);
    procedure OpenReestrWindow;
    procedure FullPreview;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure DrawCurrent;
    procedure SortScreenList(Logik:Boolean);
    procedure NetUnLock;
    procedure ExportNakl(As:DocumentEdit);
    Procedure FormReport(Const p:PBox);
    procedure Refresh;
  end;


Implementation

uses DBEngine,Objects, Views, MsgBox,{Vision,Calc,}Dos,Vision1,TpDate,Utils2,MrkTool,UtilsP,
     Vision5,App,Validate, ColorTxt,Serv,{InpLong,{Validate,}Tools,Printers,ComboBox,NetDbEng,Net;


var
 NoScreenList,DocList : PBox;
 ControlActiv,ControlAgent,
 ControlSort,ControlDirection,ControlVidDoc,ControlAllDoc,ControlAllSumma,
 ControlAllSkid,ControlAllClient,
 ControlFiltr,ControlModifyDate,ControlRefreshTime,ControlCombo: PView;
 PrevCur : TMyString;
 DocReestrWindow:PReestrWindow;
 ControlOtdel : PView;
 ControlMarsh : PView;
 DocDate : TDateString;
 Direction ,Sorting : Word;
 StartTime:LongInt;
 RefreshTime:LongInt;
 ShowItog : Boolean;
 ActivMas:Maska2;
 OtdelMas: MaskaNew;
 Otdel : Word;
 Marsh: word;
 M3:Maska3;
 Activ,FiltrSf,Filtr : Word;


Procedure TReestrWindow.ExportNAkl(As:DocumentEdit);
 Var Fexp : File Of ImportSuperMarketType;
     Exp : PImportSuperMarketType;
     E : PSuperMarketType;
     s : string[150];
     i,j : Word;

Begin
New(E,Init);
If Not(GetMarket1(As,E)) Then
 Begin
  Dispose(E,Done);
  Exit;
 End;


{
 If (E^.DAt.OperatorSelector <> 0) Then
  Begin
   SpecialBeep;
   MessageBox(^M+#3'Экспортировать можно только межскладские перевозки!',
   Nil,mfError+mfCancelButton);
   Dispose(E,Done);
   Exit;
  End;
}
 Assign(FExp,Path.ToExport+GetImportFileName(As,Rek.Kod));
 I:=IoResult;
 Rewrite(FExp);
 I:=IoResult;
 If I<>0 Then
  Begin
   MessageBox(^M+#3'Ошибка создания файла '+GetImportFileName(As,Rek.Kod)+'.'+
   ClicProgrammer,Nil,mfError+mfCancelButton);
   Dispose(E,Done);
   Exit;
  End;

 DInfoMsg('Экспортирую документ. Ждите...');
 New(Exp,Init);
 {цикл конвертации}
 With Exp^.Dat Do
  Begin
     OperatorSelector :=E^.DAt.OperatorSelector;
     Status    :=0;           {статус: импортирован 1 или нет 0}
     MakeKod   :=Rek.Kod; {код поставщика}
     Document  :=E^.DAt.Document; {номер документа}
     DateC     :=FDate; {дата импорта}
     TimeC     :=Times; {время импорта}
     {только для сертификатов}

     MyStr(StrToReal(E^.Dat.SummaZ),CIZena,CMantissa,SummaZ);
     MyStr(StrToReal(E^.Dat.SummaZakupka),CIZena,CMantissa,SummaZakupka);

  SkladKod   :=Rek.Kod;{признак склада}
     Caption :=CurrentPAssword;{признак оператора}
     Amount  :=E^.DAt.Amount;   {число товаров в документе}
     {цикл заполнения накладной}

   If E^.Dat.Amount>0 Then
   Begin
   For i:=1 To E^.Dat.Amount Do
   Begin
    With Element[i] Do
     Begin
      If Not GetBazElement(E^.DAt.MarketElement[i].Bazkod,Element[i].Baz) Then
       Begin
        Element[i].Baz.Locked:=False;
        Element[i].Baz.Stat:=False;
        Element[i].BazKod:=E^.Dat.MarketElement[i].BazKod;
If FindParam('/PEREEZD') Then
Begin
        MyStr(StrToReal(E^.Dat.MarketElement[i].Input.Zakupka),CZena,CMAntissa,Input.Zakupka);
	   Input.R_Zena     :=BakGetField(FRZena,E^.Dat.MarketElement[i].BazKod,1);
	   Input.O_Zena     :=BakGetField(FOZena,E^.Dat.MarketElement[i].BazKod,1);
End
Else
 Begin
        MyStr(StrToReal(E^.Dat.MarketElement[i].Input.R_Zena)-StrToReal(E^.Dat.MarketElement[i].Input.Skidka),
        CZena,CMAntissa,E^.Dat.MarketElement[i].Input.Zakupka);

        MyStr(StrToReal(E^.Dat.MarketElement[i].Input.Zakupka),CZena,CMAntissa,Input.Zakupka);
	   Input.R_Zena     :=E^.Dat.MarketElement[i].Input.R_Zena;
	   Input.O_Zena     :=E^.Dat.MarketElement[i].Input.O_Zena;
 End;

	   Input.Post       :=BakGetfield(FPost,E^.Dat.MarketElement[i].BazKod,0);
        DelSpaceRight(Input.Post);
	   Input.NSertif      :=BakGetfield(FSertif,E^.Dat.MarketElement[i].BazKod,0);;
        DelSpaceRight(Input.NSertif);
	   Input.DSertif    :=BakGetfield(FDateSertif,E^.Dat.MarketElement[i].BazKod,0);
        DelSpaceRight(Input.DSertif);
	   Input.KSertif     :=BakGetfield(FKtoSertif,E^.Dat.MarketElement[i].BazKod,0);
        DelSpaceRight(Input.KSertif);
 	   Input.Kol        :=E^.Dat.MarketElement[i].Input.Kol;
        GetSkidka(E^.Dat.MarketElement[i].BazKod,Input.Sk);
       End
       Else {если не удалось прочитать наименования}
        Begin
         NoInfoMsg;
         Dispose(Exp,Done);
         Dispose(E,Done);
         System.Close(FExp);
         Exit;
        End;
     End;{With Element[i]}
   End;{For}
   j:=i+1;
   End Else j:=1;



  End;{With}

 Write(FExp,Exp^.Dat);
 {конец цикла конвертации}
 Dispose(Exp,Done);
 Dispose(E,Done);

 I:=IoResult;
 System.Close(FExp);
 I:=IoResult;
 AddProtocol('Экспорт документа N '+As.EditPosition+' от '+As.D,'','');
 NoInfoMsg;
 MessageBox(^M+#3'Экспорт документа успешно завершен!',Nil,mfInformation+mfCancelButton);
End;



procedure TReestrWindow.DrawCurrent;
VAr S : TMyString;
    R : TRect;
    TempS : AllStr;
Begin
If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
  Begin
   Dispose(ControlModifyDate,Done);
   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +CDocNumer+1+CDate+1+CIZena+1+CIZena+1+1+1+CKto+1,CDate+1+CDAte);
   s[9]:='(';
   s:=s+')';
   R.Assign(6, 21, 24, 22);


   ControlModifyDate := New(PColoredText, Init(R, #3+s, $7E));
   Insert(ControlModifyDate);


   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +CDocNumer+1+CDate+1+CIZena+1+CIZena+1,1);
   CAse StrToInt(s) Of
   0:s:='Список';
   1:s:='Тов.чек*';
   2:s:='Физ.лиц.*';
   3:s:='СФ*';
   4:s:='СФ ';
   5:s:='Дебит*';
   6:s:='Дебит СФ*';
   7:s:='Дебит';
   8:s:='Дебит СФ';
   Else s:='???';
   End;

   Dispose(ControlVidDoc,Done);
   R.Assign(38, 21, 47, 22);
   ControlVidDoc := New(PColoredText, Init(R, #3+s, $7E));
   Insert(ControlVidDoc);

   s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
   s:=Copy(s,Ord(s[0])-CClientKod,CClientKod);

   Dispose(ControlAgent,Done);
   Temps:=GetAgentField(FClient,S);
   DelSpaceRight(TempS);
   Format(TempS,CClient);
   R.Assign(22, 20, 48, 21);
   ControlAgent := New(PColoredText, Init(R, TempS+'('+s+')', $7E));
   Insert(ControlAgent);




{  Dispose(ControlAllSkidka,Done);
   s:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1
           +CDocNumer+1+CDate+1+CDAte+1+CIZena+1+1+1+CKto+1+CDate+1+CDAte+1,CIZena);
   DelSpace(S);
   R.Assign(65, 20, 79, 21);
   ControlAllSkidka := New(PColoredText, Init(R, #3+s, $7E));
   Insert(ControlAllSkidka);}
  End
  Else
   Begin
    If PStaticText(ControlModifyDate)^.Text^<>#3'???' Then
    Begin
    Dispose(ControlModifyDate,Done);
    R.Assign(6, 21, 24, 22);

    ControlModifyDate := New(PColoredText, Init(R, #3+'???', $7E));
    Insert(ControlModifyDate);


    Dispose(ControlVidDoc,Done);
    R.Assign(38, 21, 47, 22);
    ControlVidDoc := New(PColoredText, Init(R, #3+'???', $7E));
    Insert(ControlVidDoc);

    Dispose(ControlAgent,Done);
    R.Assign(22, 20, 48, 21);
    ControlAgent := New(PColoredText, Init(R, #3'???', $7E));
    Insert(ControlAgent);
    End;
   End;
End;


procedure TReestrWindow.OpenReestrWindow;
Var l : Boolean;
begin
  if Message(Desktop, evBroadcast, cmReestrDoc, nil) = nil then
  begin
    L:=True;

    If Not(DateDialog(DocDAte)) Then Exit;
    If Password(2) Then ShowItog:=True Else ShowItog:=False;
    if not (User[82] or (CurrentPassword='00')) then ShowItog:=false;
    DInfo('Инициализация реестра документов...');
    DocReestrWindow := New(PReestrWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(DocReestrWindow);
    NoInfo;
    End
    Else
     Begin
      TekDate:=FDate;
      Dispose(DocReestrWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(DocReestrWindow) <> Desktop^.TopView then DocReestrWindow^.Select;
end;

Procedure TReestrWindow.SortScreenList(Logik:Boolean);
Var i,j : Word;
    ws,ws1 : string[150];
    Doc : ArtikulStr;
    TempBox : PBox;
    R : TRect;
Begin
DInfoMsg('Сортирую документы...');

if (DocList^.List^.Count>0) And Not(Logik) Then
  Doc:=Copy(DocList^.GEtText(DocList^.Focused,DocList^.List^.Count),
      1+CClient+1,CArtikul)
Else Doc[0]:=#0;



R.Assign(0,0,0,0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));


DocList^.NewList(Nil);
DocList^.NewList(New(PMyCollection, Init(0,1)));




If Direction=1 Then
DistanationSorting:=False
Else
DistanationSorting:=True;


If NoScreenList^.List^.Count>0 Then
Begin
{формируем отсортированный список}
For j:=0 to NoScreenList^.List^.Count-1 Do
Begin
 ws:=NoScreenList^.GEtText(j,NoScreenList^.List^.Count);
Case Sorting Of
{клиент}
0:ws:=ws;
{номер документа}
1:Begin
   ws1:=Copy(ws,1+CClient+1,CDocNumer);
   System.Delete(ws,1+CClient+1,CDocNumer+1);
   ws:=ws1+' '+ws;
  End;
{сумма отгрузки}
2:Begin
   ws1:=Copy(ws,1+CClient+1+CDocNumer+1+CDate+1,CIZena);
   RFormatZerro(ws1,CIZena);
   {System.Delete(ws,1+CClient+1+CDocNumer+1+CDate+1,CIZena+1);}
   ws:=ws1+' '+ws;
  End;
{сумма скидки}
3:Begin
   ws1:=Copy(ws,1+CClient+1+CDocNumer+1+CDAte+1+CIZena+1,CIZena);
   RFormatZerro(ws1,CIZena);
   {System.Delete(ws,1+CClient+1+CDocNumer+1+CDAte+1+CIZena+1,CIZena+1);}
   ws:=ws1+' '+ws;
  End;
Else;
End;{CAse}
  TempBox^.List^.Insert(NewStr(ws));
  TempBox^.SetRange(TempBox^.List^.Count);
End;



{форматируем сформированый список под экранную форму}
If TempBox^.List^.Count>0 Then
Begin
For j:=0 to TempBox^.List^.Count-1 Do
Begin
  ws:=TempBox^.GEtText(j,TempBox^.List^.Count);

Case Sorting Of
{клиент}
0:ws:=ws;
{N документа}
1:Begin
   ws1:=Copy(ws,1,CDocNumer);
   System.Delete(ws,1,CDocNumer+1);
   System.Insert(ws1+'│',ws,1+CClient+1);
  End;
{сумма отгрузки}
2:Begin
   ws1:=Copy(ws,1,CIZena);
   System.Delete(ws,1,CIZena+1);
   {System.Insert(ws1+'│',ws,1+CClient+1+CDocNumer+1+CDate+1);}
  End;
{сумма скидки}
3:Begin
   ws1:=Copy(ws,1,CIZena);
   System.Delete(ws,1,CIZena+1);
   {System.Insert(ws1+'│',ws,1+CClient+1+CDocNumer+1+CDAte+1+CIZena+1);}
  End;
Else;
End;{CAse}

  DocList^.List^.Insert(NewStr(ws));
  DocList^.SetRange(DocList^.List^.Count);
End;
End;
End;{If TempCalcList^.List^.Count>0 Then}



Dispose(TempBox,Done);

NoInfoMsg;

If Doc[0]=#0 Then
DocList^.FocusItem(0)
Else
DocList^.FocusItem(Location(DocList,Doc,False));

DocList^.HelpCtx:=$E210;

DistanationSorting:=True;
PrevCur[0]:=#0;
End;


Procedure TReestrWindow.Refresh;
Var Fp : MarketFileType;
    s: TMyString;
    ws : AllStr;
    AllNalogC,AllNalogP,AllDoc,AllClient,AllSkid,AllTara,AllSumma : String[CIZena];
    E : PSuperMarketType;
    FPos:Byte;
    TempArtikul,FS : AllStr;
    Sh,c : Word;
    R : TRect;
Begin
DInfoMsg('Минуточку...');
c:=IOResult;
Assign(fp,Path.ToMarket+DocDate+'.mrk');
Reset(fp);
c:=IOResult;
If c<>0 Then
 Begin
   MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+DocDate+'.mrk',Nil,mfError+mfCancelButton);
   Exit;
 End;

NoScreenList^.NewList(Nil);
NoScreenList^.NewList(New(PTextCollection, Init(1,1)));
New(E,Init);
AllDoc[0]:=#0;
AllSkid[0]:=#0;
AllSumma[0]:=#0;
AllClient[0]:=#0;
AllTara[0]:=#0;
AllNalogP[0]:=#0;
AllNalogC[0]:=#0;

ControlActiv^.GetData(Activ);
WordToBit2(Activ,ActivMas);
Convert2(ActivMas);


ControlOtdel^.GetData(Otdel);
WordToBitNew(Otdel,OtdelMas);
ConvertNew(OtdelMas);

{ControlMarsh^.GetData(Marsh);}

While Not(Eof(Fp)) Do
 Begin
  ReadMarket(Fp,E);

  If Otdel<>255 Then RecalcFromOtdel(E,OtdelMas);



  If (E^.Dat.Active) Then
   Begin
   If M3[E^.DAt.OperatorSelector+1]=1 Then
   Begin
   If (FiltrSf=0)Or(E^.Dat.DocSelector in [3,4,6,8]) Then
Begin
    if (STRtOInt(GetClientfield(FMarsh,E^.DAT.ClientKod,E^.DAt.OperatorSelector))=Marsh) or
     (Marsh=0) then
   {memcc(;}

   If ((E^.DAt.Realiz) And (E^.Dat.DocSelector in [5,6,7,8])) or Not(E^.Dat.Realiz) Then
   Begin
    If ((ActivMas[1]=1) And (StrToInt(E^.Dat.AgentKod)=0)) Or
       ((ActivMas[2]=1) And (StrToInt(E^.Dat.AgentKod)<>0)) Then

 Begin
 {
 If E^.Dat.DocSelector=5 Then
    If TestSf(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC) Then Inc(E^.Dat.DocSelector);
}
    Str(StrToInt(AllDoc)+1:CLitrMantissa,AllDoc);
    DelSpace(AllDoc);
    s:=GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
    Format(S,CClient);
    s:=s+'│';
    RFormatZerro(E^.Dat.Document,CDocNumer);
    Format(E^.Dat.Document,CDocNumer);
    s:=s+E^.Dat.Document+{'│'+E^.Dat.DateC}+'│'+E^.Dat.TimeC+'│';
    DelSpace(E^.Dat.SummaZ);
    RFormat(E^.Dat.SummaZ,CIZena);

{   Str(StrToReal(AllSumma)+StrToReal(E^.Dat.SummaZ):CIZena:CMantissa,AllSumma);
    DelSpace(AllSumma);

    If E^.Dat.OperatorSelector=0 Then
    Begin
    Str(StrToReal(AllClient)+StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka):CIZena:CMantissa,AllClient);
    DelSpace(AllClient);
    End;

    Str(StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka):CIZena:CMantissa,E^.Dat.SummaZ);}

    Str(StrToReal(AllSumma)+StrToReal(E^.Dat.SummaZ)-StrToReal(E^.Dat.ENalog):CIZena:CMantissa,AllSumma);
    DelSpace(AllSumma);

    If E^.Dat.OperatorSelector=0 Then
    Begin
    Str(StrToReal(AllClient)+StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka)
    -StrToReal(E^.Dat.ENalog):CIZena:CMantissa,AllClient);
    DelSpace(AllClient);
    End;


    Str(StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka)-StrToReal(E^.Dat.ENalog):CIZena:CMantissa,E^.Dat.SummaZ);


    s:=s+E^.Dat.SummaZ+'│';
    DelSpace(E^.Dat.Skidka);
    Str(StrToReal(E^.Dat.Skidka):CIZena:CMantissa,(E^.Dat.Skidka));

    Str(StrToReal(AllSkid)+StrToReal(E^.Dat.Skidka):CIZena:CMantissa,AllSkid);
    DelSpace(AllSkid);

    For Sh:=1 To E^.Dat.Amount Do
     Begin
      TempArtikul:=Copy(E^.Dat.MarketElement[Sh].BazKod,1,CRAzdelKod);
      If StrToInt(TempArtikul)=8 Then
       Begin
        Str(StrToReal(AllTara)+
	       StrToInt(E^.Dat.MarketElement[Sh].InPut.Kol)*StrToReal(E^.Dat.MarketElement[Sh].InPut.Zena):CIZena:CMantissa,
            AllTara);

       End;
     End;



    {Format(E^.Dat.Skidka,CIZena);}
    s:=s+E^.Dat.Skidka+'│';

    Str(E^.Dat.DocSelector:1,ws);
    s:=s+ws+'│';
    ws:=GetOperatorName(E^.Dat.Caption);
    Format(Ws,CKto);
    s:=s+ws+'│'+E^.Dat.DateM+'│'+E^.Dat.TimeM+'│'{+E^.Dat.AgentKod+'│'};
    If E^.Dat.DocSelector in [0,1,2,3,4] Then
     Begin
      Str(StrToReal(E^.Dat.ENAlog):CIZena:CMantissa,E^.Dat.ENalog);
     End
    Else
     Begin
      Str(StrToReal(E^.Dat.ENAlog):CIZena:CMantissa,E^.Dat.ENalog);
     End;
    s:=s+E^.Dat.ENAlog+'│'+E^.Dat.AgentKod+'│';

    NoScreenList^.List^.Insert(NewStr(s));
    NoScreenList^.SetRange(NoScreenList^.List^.Count);
End;{Фильтр активных продаж}
   End;
   End;
   End;
End;
 End;
Dispose(E,Done);
{NoScreenList^.FocusItem(0);}

System.Close(Fp);

Str(StrToReal(AllSkid):CIZena:CMantissa,AllSkid);
DelSpace(AllSkid);

Str(StrToReal(AllSumma):CIZena:CMantissa,AllSumma);
DelSpace(AllSumma);

Str(StrToInt(AllDoc):CLitrMantissa,AllDoc);
DelSpace(AllDoc);

Str(StrToReal(AllClient):CIZena:CMantissa,AllClient);
DelSpace(AllClient);

Str(StrToReal(AllTara):CIZena:CMantissa,AllTara);
DelSpace(AllTara);

Dispose(ControlAllClient,Done);
R.Assign(63, 22, 78, 23);
If ShowItog Then
ControlAllClient := New(PColoredText, Init(R, #3+AllClient, $4E))
Else
ControlAllClient := New(PColoredText, Init(R, #3+'????', $4E));
Insert(ControlAllClient);

Dispose(ControlAllDoc,Done);
R.Assign(38, 22, 42, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);

Dispose(ControlAllSkid,Done);
R.Assign(15, 22, 30, 23);
If ShowItog Then
ControlAllSkid := New(PColoredText, Init(R, #3+AllSkid, $4E))
Else
ControlAllSkid := New(PColoredText, Init(R, #3+'????', $4E));
Insert(ControlAllSkid);

Str(StrToReal(AllSumma)+StrToReal(AllSkid):CIZena:CMantissa,AllSumma);
DelSpace(AllSumma);

Dispose(ControlAllSumma,Done);
R.Assign(63, 21, 78, 22);
If ShowItog Then
ControlAllSumma := New(PColoredText, Init(R, #3+AllSumma, $4E))
Else
ControlAllSumma := New(PColoredText, Init(R, #3+'????', $4E));
Insert(ControlAllSumma);



NoInfoMsg;
End;


constructor TReestrWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  s: TMyString;
  ws : AllStr;
  AllDoc,AllClient,AllSkid,AllTara,AllSumma : String[CIZena];
  E : PSuperMarketType;
  fp : MarketFileType;
begin
L:=False;
R.Assign(0, 0, 80, 23);
inherited Init(R, 'Реестр документов отгрузки товара со склада за '+DocDate);
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E002;
{
c:=IOResult;
Assign(fp,Path.ToMarket+DocDate+'.mrk');
Reset(fp);
c:=IOResult;
If c<>0 Then
 Begin
   MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+DocDate+'.mrk',Nil,mfError+mfCancelButton);
   Exit;
 End;
}
R.Assign(0, 0, 0, 0);
NoScreenList := New(PBox, Init(R, 1, Nil));
NoScreenList^.NewList(New(PTextCollection, Init(1,1)));
New(E,Init);
AllDoc[0]:=#0;
AllSkid[0]:=#0;
AllTara[0]:=#0;
AllSumma[0]:=#0;
AllClient[0]:=#0;
(*
While Not(Eof(Fp)) Do
 Begin
  {
  Repeat
  Until (NetCall.Lock (Fp,FilePos(Fp)*SizeOf(SuperMarketType),SizeOf(SuperMarketType)));
  }
  ReadMarket(Fp,E);

  {
  Repeat
  NetCAll.UnLock(Fp,(FilePos(Fp)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
  Until (DosError=0);
  }


  If (E^.Dat.Active) Then
   Begin
   If ((E^.DAt.Realiz) And (E^.Dat.DocSelector in[5,6,7,8])) or Not(E^.Dat.Realiz) Then
   Begin
    Str(StrToInt(AllDoc)+1:CLitrMantissa,AllDoc);
    DelSpace(AllDoc);
    s:=GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
    Format(S,CClient);
    s:=s+'│';
    RFormatZerro(E^.Dat.Document,CDocNumer);
    Format(E^.Dat.Document,CDocNumer);
    s:=s+E^.Dat.Document+{'│'+E^.Dat.DateC}+'│'+E^.Dat.TimeC+'│';
    DelSpace(E^.Dat.SummaZ);

    RFormat(E^.Dat.SummaZ,CIZena);



    Str(StrToReal(AllSumma)+StrToReal(E^.Dat.SummaZ)-StrToReal(E^.Dat.ENalog):CIZena:CMantissa,AllSumma);
    DelSpace(AllSumma);

    If E^.Dat.OperatorSelector=0 Then
    Begin
    Str(StrToReal(AllClient)+StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka)
    -StrToReal(E^.Dat.ENalog):CIZena:CMantissa,AllClient);
    DelSpace(AllClient);
    End;

    Str(StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka)-StrToReal(E^.Dat.ENalog):CIZena:CMantissa,E^.Dat.SummaZ);

    s:=s+E^.Dat.SummaZ+'│';
    DelSpace(E^.Dat.Skidka);
    Str(StrToReal(E^.Dat.Skidka):CIZena:CMantissa,(E^.Dat.Skidka));

    Str(StrToReal(AllSkid)+StrToReal(E^.Dat.Skidka):CIZena:CMantissa,AllSkid);
    DelSpace(AllSkid);

    {Format(E^.Dat.Skidka,CIZena);}
    s:=s+E^.Dat.Skidka+'│';

    Str(E^.Dat.DocSelector:1,ws);
    s:=s+ws+'│';
    ws:=GetOperatorName(E^.Dat.Caption);
    Format(Ws,CKto);
    s:=s+ws+'│'+E^.Dat.DateM+'│'+E^.Dat.TimeM;
    NoScreenList^.List^.Insert(NewStr(s));
    NoScreenList^.SetRange(NoScreenList^.List^.Count);

   End;

   End;

 End;
Dispose(E,Done);
NoScreenList^.FocusItem(0);
{Insert(NoScreenList);}


System.Close(Fp);
*)

Str(StrToReal(AllSkid):CIZena:CMantissa,AllSkid);
DelSpace(AllSkid);

Str(StrToReal(AllSumma):CIZena:CMantissa,AllSumma);
DelSpace(AllSumma);

Str(StrToInt(AllDoc):CLitrMantissa,AllDoc);
DelSpace(AllDoc);

Str(StrToReal(AllClient):CIZena:CMantissa,AllClient);
DelSpace(AllClient);

R.Assign(71, 0, 75, 1);
ControlRefreshTime := New(PInputLine, Init(R, 2));
Insert(ControlRefreshTime);

s:=IntToStr(RefreshTime,2);
DelSpace(s);
ControlRefreshTime^.SetData(s);

  R.Assign(75, 0, 78, 1);
  ControlCombo := New(PCombo, Init(R, PInputLine(ControlRefreshTime), cbxOnlyList or cbxDisposesList or cbxNoTransfer,
    NewSItem('│10',
    NewSItem('│15',
    NewSItem('│20',
    NewSItem('│25',
    NewSItem('│30',
    NewSItem('│35',
    NewSItem('│40',
    NewSItem('│45',
    NewSItem('│50',
    NewSItem('│55',
    NewSItem('│60',
    NewSItem('│65',
    NewSItem('│70',
    NewSItem('│75',
    NewSItem('│80',
    NewSItem('│85',
    NewSItem('│90',
    NewSItem('│95',
    Nil))))))))))))))))))));
  PCombo(ControlCombo)^.ActivateChar('*');
{$IFDEF Not NetVersion}
  ControlCombo^.Options := ControlCombo^.Options and not ofSelectable;
{$ENDIF}
  Insert(ControlCombo);


R.Assign(13, 1, 63, 2);
ControlSort := New(PRadioButtons, Init(R,
  NewSItem('Кл~и~ент',
  NewSItem('N ~д~ок.',
  NewSItem('О~т~грузка',
  NewSItem('Скидк~а~', Nil))))));
Sorting:=0;
ControlSort^.SetData(Sorting);
Insert(ControlSort);

  R.Assign(1, 1, 13, 2);
  Insert(New(PLabel, Init(R, 'Сортировка:', ControlSort)));

R.Assign(64, 1, 78, 2);
ControlDirection := New(PRadioButtons, Init(R,
  NewSItem(#30,
  NewSItem(#31, Nil))));
Direction:=0;
{ControlDirection^.HelpCtx:=$E002;}
ControlDirection^.SetData(Direction);
Insert(ControlDirection);

R.Assign(13, 2, 48, 3);
ControlFiltr := New(PCheckboxes, Init(R,
  NewSItem('К~л~иент',
  NewSItem('~С~клад ',
  NewSItem('~О~бмен', Nil)))));
  Insert(ControlFiltr);

Convert3(M3);
BitToWord3(M3,Filtr);
Convert3(M3);
ControlFiltr^.SetData(Filtr);


R.Assign(22, 20, 48, 21);
ControlAgent := New(PColoredText, Init(R, #3'???', $7E));
Insert(ControlAgent);

R.Assign(13, 20, 22, 21);
Control := New(PColoredText, Init(R, 'Доставка:', $74));
Insert(Control);



R.Assign(1, 2, 13, 3);
  Insert(New(PLabel, Init(R, 'Показывать:', ControlFiltr)));


R.Assign(1, 21, 5, 22);
Control := New(PColoredText, Init(R, 'Изм:', $74));
Insert(Control);

R.Assign(6, 21, 24, 22);
ControlModifyDate := New(PColoredText, Init(R, #3, $7E));
Insert(ControlModifyDate);


R.Assign(49, 2, 78, 3);
ControlActiv := New(PCheckboxes, Init(R,
  NewSItem('~П~ассивные',
  NewSItem('Акти~в~ные', Nil))));
Insert(ControlActiv);
Convert2(ActivMas);
BitToWord2(ActivMas,Activ);
ControlActiv^.Setdata(Activ);
Activ:=3;



R.Assign(22, 3, 79, 4);
ControlOtdel := New(PCheckboxes, Init(R,
  NewSItem('~1~',
  NewSItem('~2~',
  NewSItem('~3~',
  NewSItem('~4~',
  NewSItem('~5~',
  NewSItem('~6~',
  NewSItem('~7~',
  NewSItem('~8~',
Nil))))))))));
Insert(ControlOtdel);

Otdel:=255;
WordToBitNew(Otdel,OtdelMas);

ConvertNew(OtdelMas);
BitToWordNew(OtdelMas,Otdel);
ControlOtdel^.Setdata(Otdel);



  R.Assign(1, 3, 22, 4);
  Insert(New(PLabel, Init(R, 'Выбранные отделения:', ControlOtdel)));

R.Assign(23, 4, 27, 5);
ControlMarsh := New(PInputLine, Init(R, 2));

PInputLine(ControlMarsh)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));
Insert(ControlMarsh);

R.Assign(1, 4, 22, 5);
  Insert(New(PLabel, Init(R, 'Выбранные маршруты:', ControlMarsh)));

s:=IntToStr(Marsh,2);
DelSpace(s);
ControlMarsh^.SetData(s);

R.Assign(80, 6, 81, 20);
Control := New(PScrollBar, Init(R));
Insert(Control);

R.Assign(0, 6, 80, 20);
DocList := New(PBox, Init(R, 1, PScrollbar(Control)));
DocList^.NewList(New(PMyCollection, Init(0,1)));
DocList^.FocusItem(0);
DocList^.HelpCtx:=$E210;

Insert(DocList);

  R.Assign(1, 5, 78, 6);
  Insert(New(PLabel, Init(R, ' Клиент               N   Время    Сумма отгрузки   Сумма скидки  Т   Оператор  ', DocList)));




R.Assign(34, 21, 38, 22);
Control := New(PColoredText, Init(R, 'Вид:', $74));
Insert(Control);

R.Assign(38, 21, 47, 22);
ControlVidDoc := New(PColoredText, Init(R, #3, $7E));
Insert(ControlVidDoc);


R.Assign(44, 22, 63, 23);
Control := New(PColoredText, Init(R, ' Отгружено клиенту:', $74));
Insert(Control);

R.Assign(63, 22, 78, 23);
If ShowItog Then
ControlAllClient := New(PColoredText, Init(R, #3+AllClient, $4E))
Else
ControlAllClient := New(PColoredText, Init(R, #3+'????', $4E));
Insert(ControlAllClient);

R.Assign(30, 22, 38, 23);
Control := New(PColoredText, Init(R, ' Докум.:', $74));
Insert(Control);

R.Assign(38, 22, 42, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);

R.Assign(1, 22, 15, 23);
Control := New(PColoredText, Init(R, ' Итого скидка:', $74));
Insert(Control);

R.Assign(15, 22, 30, 23);
If ShowItog Then
ControlAllSkid := New(PColoredText, Init(R, #3+AllSkid, $4E))
Else
ControlAllSkid := New(PColoredText, Init(R, #3+'????', $4E));
Insert(ControlAllSkid);



R.Assign(51, 21, 63, 22);
Control := New(PColoredText, Init(R, 'E отгружено:', $74));
Insert(Control);

Str(StrToReal(AllSumma)+StrToReal(AllSkid):CIZena:CMantissa,AllSumma);
DelSpace(AllSumma);

R.Assign(63, 21, 78, 22);
If ShowItog Then
ControlAllSumma := New(PColoredText, Init(R, #3+AllSumma, $4E))
Else
ControlAllSumma := New(PColoredText, Init(R, #3+'????', $4E));
Insert(ControlAllSumma);

{R.Assign(44, 20, 64, 21);
Control := New(PColoredText, Init(R, 'Скидка по документу:', $74));
Insert(Control);
{R.Assign(65, 20, 79, 21);
ControlAllSkidka := New(PColoredText, Init(R, #3, $7E));
Insert(ControlAllSkidka);}

SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);
SelectNext(False);

L:=True;
Refresh;
PrevCur[0]:=#0;
SortScreenList(True);
StartTime:=TimeStringToTime('hh:mm:ss',Times);
end;



procedure TReestrWindow.FullPreview;
Var Ass : DocumentEdit;
    E : PSuperMarketType;
    R : TRect;
    f : MarketFileType;
    c : Word;
    P : PBox;
    s,ws : TMyString;
    Find : Boolean;
    SDoc : ArtikulStr;
    SDate : TDateString;
    ws1,WspomSkidka:String[CIZena];

Begin
If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
Begin
  Ass.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=DocDate{Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CDocNumer+1,CDate)};
  DelSpace(Ass.D);
  ViewMrk^.FullScreenMrk(Ass);
End
End;

Procedure TReestrWindow.NetUnLock;
Var Ass : DocumentEdit;
Begin
If (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
Begin
  If Password(2) Then
  Begin
  Ass.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
  DelSpace(Ass.EditPosition);
  DelZerro(Ass.EditPosition);
  Ass.D:=DocDate;
  DelSpace(Ass.D);
  Repeat
  Until (UnLockMarket(Ass.EditPosition,Ass.D) in [0,2]);
  MessageBox(^M+#3'Документ N '+Ass.EditPosition+' от '+
  'успешно деблокирован!',Nil,mfInformation+mfCancelButton);
  End;
end;
End;


Procedure TReestrWindow.FormReport(Const P:PBox);
Const Space=' ';
Var f : text;
    news,Nalog,Skidka,Summa,ws,s : string[150];
    sAllMassa,sMAssa: String[CIZena];
    INalog,Itogo,ISkid : Array[0..8] Of Real;
    c,k : Word;
    AS: DOCumentEDIT;
Begin

If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin
 Assign (f,Path.ToTemp+'list.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'Не могу создать файл '+Path.ToTemp+'list.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Write(f,Space+'Вид сортировки:');
 Case Sorting Of
 0:Writeln(f,'"Клиент"');
 1:Writeln(f,'"Номер документа"');
 2:Writeln(f,'"Сумма отгрузки"');
 3:Writeln(f,'"Сумма скидки"');
 Else Writeln(f);
 End;

WordToBitNew(Otdel,OtdelMas);
ConvertNew(OtdelMas);

   Write(f,Space+'Внимание! в отчет включены следующие отделения:');
   For c:=1 To CDivision Do
   Begin
    If OtdelMas[c]=1 Then Write(f,c:2,'  ');
   End;
   Writeln(f);



 Writeln(f);

 Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');
 Writeln(f,Space+'           РЕЕСТР ДОКУМЕНТОВ ОТГРУЗКИ ТОВАРА СО СКЛАДА '^M+
 Space+'        '+GetClientField(FClient,Rek.Kod,1)+' за '+DocDate+
 ' ('+FDate+' '+Times+')');
 Writeln(f,Space+'------------------------------------------------------------------------------------------');
 Writeln(f,Space+'Клиент               Док   Время    Сумма к оплате Тип док-та     Оператор           Масса');
                 {12345678901234567890│1234│12-45-78│123456789012345│1234567890│123456789012}
 Writeln(f,Space+'------------------------------------------------------------------------------------------');
 Nalog[0]:=#0;
 sAllMassa:='';
 For c:=0 To 8 Do Begin INalog[c]:=0; ISkid[c]:=0;Itogo[c]:=0; End;
 For c:=0 To P^.List^.Count-1 Do
  Begin
   s := P^.GetText(c,P^.List^.Count);
   While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert(' ',s,k);
    End;
   ws:=Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1,COne);
   Summa:=Copy(s,1+CClient+1+CDocNumer+1+CDate+1,CIZena);
   Skidka:=Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CIZena+1,CIZena);
   Nalog:=Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1+COne+1+CKto+1+CDate+1+CDate+1,CIZena);
   As.EditPosition:=Copy(s,1+CClient+1,CDocNumer);
   As.D:=DocDate;
   sMassa:=CalcVes(AS);
   Str(StrToReal(sMassa)+StrToReal(sAllMassa):CIZena:CMantissa,sAllMassa);
   Str(StrToReal(Summa)-StrToReal(Skidka)+StrToReal(Nalog):CIZena:CMantissa,News);

   s[0]:=Chr(1+CClient+1+CDocNumer+1+CDate+1+CIZena+1+CIZena+1+COne+1+CKto);
   System.Delete(s,1+CClient+1+CDocNumer+1+CDate+1,CIZena+1+CIZena+1);
   System.Insert(News+' ',s,1+CClient+1+CDocNumer+1+CDate+1);

   Case StrToInt(Ws) of
   8:Begin ws:='Дебит СФ';
           Itogo[8]:=Itogo[8]+StrToReal(Summa);
           ISkid[8]:=Iskid[8]+StrToReal(Skidka);
          INalog[8]:=INalog[8]+StrToReal(Nalog);
     End;
   7:Begin ws:='Дебит';
           Itogo[7]:=Itogo[7]+StrToReal(Summa);
           ISkid[7]:=Iskid[7]+StrToReal(Skidka);
          INalog[7]:=INalog[7]+StrToReal(Nalog);
     End;
   6:Begin ws:='Дебит СФ*';
           Itogo[6]:=Itogo[6]+StrToReal(Summa);
           ISkid[6]:=Iskid[6]+StrToReal(Skidka);
          INalog[6]:=INalog[6]+StrToReal(Nalog);
     End;
   5:Begin ws:='Дебит*';
           Itogo[5]:=Itogo[5]+StrToReal(Summa);
           ISkid[5]:=Iskid[5]+StrToReal(Skidka);
          INalog[5]:=INalog[5]+StrToReal(Nalog);
     End;
   4:Begin ws:='СФ ';
           Itogo[4]:=Itogo[4]+StrToReal(Summa);
           ISkid[4]:=Iskid[4]+StrToReal(Skidka);
          INalog[4]:=INalog[4]+StrToReal(Nalog);
     End;
   3:Begin ws:='СФ*';
           Itogo[3]:=Itogo[3]+StrToReal(Summa);
           ISkid[3]:=Iskid[3]+StrToReal(Skidka);
          INalog[3]:=INalog[3]+StrToReal(Nalog);
     End;
   2:Begin ws:='Физ.лиц*';
           Itogo[2]:=Itogo[2]+StrToReal(Summa);
           ISkid[2]:=Iskid[2]+StrToReal(Skidka);
          INalog[2]:=INalog[2]+StrToReal(Nalog);
     End;
   1:Begin ws:='Тов.Чек*';
           Itogo[1]:=Itogo[1]+StrToReal(Summa);
           ISkid[1]:=Iskid[1]+StrToReal(Skidka);
          INalog[1]:=INalog[1]+StrToReal(Nalog);
     End;
   0:Begin ws:='Список';
           Itogo[0]:=Itogo[0]+StrToReal(Summa);
           ISkid[0]:=Iskid[0]+StrToReal(Skidka);
          INalog[0]:=INalog[0]+StrToReal(Nalog);
     End;
   Else ws[0]:=#0;
   End;
   Format(ws,10);
   System.Delete(s,1+CClient+1+CDocNumer+1+CDate+1+CIZena+1,1);
   System.Insert(ws,s,1+CClient+1+CDocNumer+1+CDate+1+CIZena+1);
   Writeln(f,Space+s+sMassa);
  End;
 Writeln(f,Space+'------------------------------------------------------------------------------------------');
{Writeln(f,Space+'------------------------------------------------------------------------------------------');}
 Summa[0]:=#0;
 For c:=0 To 8 Do Str(StrToReal(Summa)+Itogo[c]:CIZena:CMantissa,Summa);

 Skidka[0]:=#0;
 For c:=0 To 8 Do Str(StrToReal(Skidka)+ISkid[c]:CIZena:CMantissa,SKidka);

 Nalog[0]:=#0;
 For c:=0 To 8 Do Str(StrToReal(Nalog)+INalog[c]:CIZena:CMantissa,Nalog);

If ShowItog Then
Begin
 s:='Всего на сумму: '+Recogniz(Summa)+' руб '+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(Itogo[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+' Список   :'+RecognizReal(Itogo[c],CIZena,CMantissa)+' руб '+^M;
     1:ws:=ws+Space+' Тов.Чек* :'+RecognizReal(Itogo[c],CIZena,CMantissa)+' руб '+^M;
     2:ws:=ws+Space+' Физ.лицо*:'+RecognizReal(Itogo[c],CIZena,CMantissa)+' руб '+^M;
     3:ws:=ws+Space+' С/Ф*     :'+RecognizReal(Itogo[c],CIZena,CMantissa)+' руб '+^M;
     4:ws:=ws+Space+' С/Ф      :'+RecognizReal(Itogo[c],CIZena,CMantissa)+' руб '+^M;
     5:ws:=ws+Space+' Дебит*   :'+RecognizReal(Itogo[c],CIZena,CMantissa)+' руб '+^M;
     6:ws:=ws+Space+' Дебит СФ*:'+RecognizReal(Itogo[c],CIZena,CMantissa)+' руб '+^M;
     7:ws:=ws+Space+' Дебит    :'+RecognizReal(Itogo[c],CIZena,CMantissa)+' руб '+^M;
     8:ws:=ws+Space+' Дебит СФ :'+RecognizReal(Itogo[c],CIZena,CMantissa)+' руб '+^M;
     Else ;
     End;
    End;
  End;
 Writeln(f,Space+s+ws);
 s:='Всего скидка: '+Recogniz(Skidka)+' руб '+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(ISkid[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+' Список   :'+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     1:ws:=ws+Space+' Тов.Чек  :'+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     2:ws:=ws+Space+' Физ.лицо*:'+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     3:ws:=ws+Space+' С/Ф*     :'+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     4:ws:=ws+Space+' С/Ф      :'+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     5:ws:=ws+Space+' Дебит*   :'+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     6:ws:=ws+Space+' Дебит СФ*:'+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     7:ws:=ws+Space+' Дебит    :'+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     8:ws:=ws+Space+' Дебит СФ :'+RecognizReal(ISkid[c],CIZena,CMantissa)+' руб '+^M;
     Else ;
     End;
    End;
  End;
 Writeln(f,Space+s+ws);
 s:='Всего налог: '+Recogniz(Nalog)+' руб '+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(INAlog[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+' Список   :'+RecognizReal(INalog[c],CIZena,CMantissa)+' руб '+^M;
     1:ws:=ws+Space+' Тов.Чек  :'+RecognizReal(INAlog[c],CIZena,CMantissa)+' руб '+^M;
     2:ws:=ws+Space+' Физ.лицо*:'+RecognizReal(INalog[c],CIZena,CMantissa)+' руб '+^M;
     3:ws:=ws+Space+' С/Ф*     :'+RecognizReal(INalog[c],CIZena,CMantissa)+' руб '+^M;
     4:ws:=ws+Space+' С/Ф      :'+RecognizReal(INalog[c],CIZena,CMantissa)+' руб '+^M;
     5:ws:=ws+Space+' Дебит*   :'+RecognizReal(INalog[c],CIZena,CMantissa)+' руб '+^M;
     6:ws:=ws+Space+' Дебит СФ*:'+RecognizReal(INAlog[c],CIZena,CMantissa)+' руб '+^M;
     7:ws:=ws+Space+' Дебит    :'+RecognizReal(INalog[c],CIZena,CMantissa)+' руб '+^M;
     8:ws:=ws+Space+' Дебит СФ :'+RecognizReal(INalog[c],CIZena,CMantissa)+' руб '+^M;
     Else ;
     End;
    End;
  End;
 Writeln(f,Space+s+ws);
 Writeln(f,Space+'Всего масса: '+sAllMassa);
End;
 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'==========================================================================================');


 System.Close(f);
 ViewAsText(Path.ToTemp+'list.txt',True);
 Report(Path.ToTemp+'list.txt','',1,False,False,false);
 End;
End;


procedure TReestrWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    s,s1 : string[150];
    SDoc : ArtikulStr;
    SDate: TDateString;
    l : Boolean;
    FC:Byte;
    FS : AllStr;

begin
  if Abs(TimeStringToTime('hh:mm:ss',Times)-StartTime)>RefreshTime then
   Begin
     Event.What:=evCommand;
     Event.Command:=cmRefresh;
   End;


  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
       kbF8 : Begin
		     Event.What:=evCommand;
			Event.Command:=cmExportImport;
			PutEvent(Event);
              End;
     kbEsc: Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
            End;
{
     kbAltF9: Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmReestrReport;
              PutEvent(Event);
              ClearEvent(Event);
            End;
}
      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of

  cmAbout: Begin
    AboutCHM('53');
    ClearEvent(Event);
  End;

  cmRefresh: Begin
  If (DeskTop^.Current=PView(DocReestrWindow)) And (Event.What <> EvKeyDown)
      And Not(Glob.Show) And Not(Glob.ShowMsg) Then
           Begin
              FS:=FindStrok;
              FC:=Ord(FindStrok[0]);
              Refresh;
              ClearEvent(Event);
              StartTime:=TimeStringToTime('hh:mm:ss',Times);
              PrevCur[0]:=#0;
              SortScreenList(False);
              FindStrok:=FS;
              FindSymbol:=FC;
              Redraw;
           End
           Else
            ClearEvent(Event);
          End;
  cmUnlockMarket :
   Begin
    ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
     NetUnLock;
   End;
  cmEdit: if (User[83] or (CurrentPassword='00')) then
     Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                Dispose(NoScreenList,Done);
               {Dispose(ControlRefreshTime,Done);
                Dispose(ControlCombo,Done);
                Dispose(ControlAllClient,Done);
                Dispose(ControlAllSkid,Done);
                Dispose(ControlAllSumma,Done);
                Dispose(ControlAllDoc,Done);
                Dispose(ControlAllTara,Done);
                Dispose(ControlFiltr,Done);}

                Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=DocDate;

                {Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CDocNumer+1,CDate)}
                DelSpace(Assistent.D);
                Event.What:=evCommand;
                Event.Command:=cmSuperMarket;
                PutEvent(Event);
                ClearEvent(Event);
                Event.What:=evCommand;
                Event.Command:=cmClose;
                Status:=DocEdit;
            End
            End;

  cmExportImport: Begin
                 ClearFind;
     If {(DocList^.State and sfFocused <> 0) And} (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=DocDate;
                DelSpace(Assistent.D);
              If MessageBox(^M+#3'Экспортироваь документ N'+Assistent.EditPosition+
		    ' от '+Assistent.D+' ?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
               Begin
                ExportNAkl(Assistent);
               End;
            End

                  End;
  cmPrintReestr: if (User[85] or (CurrentPassword='00')) then
      Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=DocDate;
                DelSpace(Assistent.D);
                {Status:=DocPrint;}
                 {PrintNaklSklad(Assistent,NPrint.CopyNkl);}
                 PrintNakl(Assistent,NPrint.CopyNkl);
                {Status:=DocNormal;}
            End
            End;

 cmReestrReport: if (User[84] or (CurrentPassword='00')) then
     Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
            FormReport(DocList);
            End
            End;

  cmFullView:    Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
              FullPreview;
{               Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CDocNumer+1,CDate);
                DelSpace(Assistent.D);
                Status:=DocPrint;
                PrintNAklSklad(Assistent);
                PrintNakl(Assistent);
                Status:=DocNormal;}
            End
            End;
     cmReestrDoc:Begin
                  ClearFind;
                  ClearEvent(Event);
                 End;
     cmCancel    : Begin
                 Dispose(NoScreenList,Done);
                {Dispose(ControlRefreshTime,Done);
                 Dispose(ControlCombo,Done);
                 Dispose(ControlAllClient,Done);
                 Dispose(ControlAllSkid,Done);
                 Dispose(ControlAllSumma,Done);
                 Dispose(ControlAllDoc,Done);
                 Dispose(ControlAllTara,Done);
                 Dispose(ControlFiltr,Done);}
                 ClearFind;
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 ClearEvent(Event);
                End;

      Else;
      End;{evCommand}
      Else;
      End;{*Case*}
  if (Event.What = evBroadcast) and
    (Event.Command = cmReestrDoc) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);


  inherited HandleEvent(Event);


  If (Desktop^.Current=PView(DocReestrWindow)) And (Event.What <> EvKeyDown) Then
             Begin

            if (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
              Begin
               s:=DocList^.GetText(DocList^.Focused,DocList^.List^.Count);
               If s <> PrevCur Then
                 Begin
                  PrevCur:=S;
                  DrawCurrent;
                 End;
              End
              Else
                  DrawCurrent;

                if (ControlSort^.State and sfFocused <> 0)Then
                    Begin
                        ControlSort^.GetData(Test);
                        If Test <> Sorting Then
                        Begin
                           ClearFind;
                           Sorting:=Test;
                           SortScreenList(False);
                           Redraw;
                        End;
                    End;

                if (ControlDirection^.State and sfFocused <> 0)Then
                    Begin
                        ControlDirection^.GetData(Test);
                        If Test <> Direction Then
                        Begin
                           ClearFind;
                           Direction:=Test;
                           SortScreenList(False);
                           Redraw;
                        End;
                    End;


                if (ControlActiv^.State and sfFocused <> 0)Then
                    Begin
                        ControlActiv^.GetData(Test);
                        If Test <> Activ Then
                        Begin
                           ClearFind;
                           Activ:=Test;
                           Refresh;
                           ClearEvent(Event);
                           StartTime:=TimeStringToTime('hh:mm:ss',Times);
                           PrevCur[0]:=#0;
                           SortScreenList(True);
                           Redraw;
                        End;
                    End;

                if (ControlFiltr^.State and sfFocused <> 0)Then
                    Begin
                        ControlFiltr^.GetData(Test);
                        If Test <> Filtr Then
                        Begin
                           ClearFind;
                           Filtr:=Test;
                           WordToBit3(Filtr,M3);
                           Convert3(m3);
                           Refresh;
              ClearEvent(Event);
              StartTime:=TimeStringToTime('hh:mm:ss',Times);
              PrevCur[0]:=#0;
              SortScreenList(True);
                           Redraw;
                        End;
                    End;


                if (ControlOtdel^.State and sfFocused <> 0)Then
                    Begin
                        ControlOtdel^.GetData(Test);
                        If Test <> Otdel Then
                        Begin
                           ClearFind;
                           Otdel:=Test;
                           Refresh;
              ClearEvent(Event);
              StartTime:=TimeStringToTime('hh:mm:ss',Times);
              PrevCur[0]:=#0;
              SortScreenList(True);
                           Redraw;
                        End;
                    End;

               if (ControlMarsh^.State and sfFocused <> 0)Then
                    Begin
                        ControlMarsh^.GetData(s);
                        If StrToInt(s) <> Marsh Then
                        Begin
                           ClearFind;
                           Marsh:=StrToInt(s);
                           Refresh;
              ClearEvent(Event);
              StartTime:=TimeStringToTime('hh:mm:ss',Times);
              PrevCur[0]:=#0;
              SortScreenList(True);
                           Redraw;
                        End;
                    End;



                if (ControlRefreshTime^.State and sfFocused <> 0)Then
                    Begin
                        ControlRefreshTime^.GetData(s);
                        If StrToInt(s) <> RefreshTime Then
                        Begin
                           ClearFind;
                           RefreshTime:=StrToInt(s);
                        End;
                    End;

{
    If (DocList^.List^.Count>=1) Then
       EnableCommands([cmFullview,cmReestrReport])
      Else
      DisableCommands([cmFullview,cmReestrReport])

}             End;

end;

BEgin
marsh:=0;
Direction:=0;
Sorting:=0;
FiltrSf:=0;
RefreshTime:=20;
M3[1]:=1;
M3[2]:=1;
M3[3]:=1;
ActivMas[1]:=1;
ActivMas[2]:=1;
End.