Unit RepPZak;

INTERFACE

Uses Glob,ServStr,Serv;

function PredZakazReport:boolean;

IMPLEMENTATION

Uses     Objects,App,Views,Validate,Dialogs, MsgBox, TPDate,Printers,
     NetDbEng,DBEngine, Tools, Utils,Utils5,Utils4,Prise;

const Space=' ';

var StopDate, StartDate: TDateString;


Function TestAgent(Agent:PBox;Cod:ArtikulStr):Boolean;
Var L : Boolean;
    i : word;
    st : String;
Begin
TestAgent:=False;
If (Agent^.List^.Count-1)>=0 Then
Begin
For i:=0 To Agent^.List^.Count-1 Do
 Begin
  st:=Agent^.GetText(i,Agent^.List^.Count);
  st:=Copy(st,1+1,CClientKod);
  If (StrToInt(St)=StrToInt(Cod)) Then
   Begin
    TestAgent:=True;
    Break;
   End;{St=Cod}
 End;
End;
End;

Function PeriodProd:Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control,ControlStart,ControlStop : PView;
  C : Word;
  l : LongInt;
  s1,s2 : TDateString;

begin
PeriodProd :=False;
s1:=FDate;
s2:=FDate;

1:
R.Assign(23, 9, 57, 14);
New(Dlg, Init(R, 'Период расчета продаж'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E011;
Dlg^.Palette := dpCyanDialog;

R.Assign(6, 2, 16, 3);
ControlStart := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStart);
  PInputLine(ControlStart)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));

ControlStart^.SetData(s1);

  R.Assign(3, 2, 6, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~с~:', ControlStart)));

R.Assign(20, 2, 30, 3);
ControlStop := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStop);
  PInputLine(ControlStop)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));

ControlStop^.SetData(s2);

  R.Assign(16, 2, 20, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~п~о:', ControlStop)));

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
   ControlStart^.GetData(s1);
   ControlStop^.GetData(s2);
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);

   If Not(TestDate(s1,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Not(TestDate(s2,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   StartDate:=s1;
   StopDate:=s2;
   PeriodProd:=True;

   {если даты перепутаны переставляем их}
   If DateStringToDate(DateMask,StopDate)<DateStringToDate(DateMask,StartDate) Then
    Begin
        s1:=StopDate;
        StopDate:=StartDate;
        StartDate:=s1;
    End;
 End
 Else
  Begin
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);
  End;
end;

function AddPredZakazToReport(s:string;P:PBox):boolean;
var find: boolean;
    i,j: word;
    sKod:ArtikulStr;
    sKOl: string[CKol];
    sZena: string[CIZena];
    ws:string;
Begin
  find:=false;
  sKOd:=copy(s,1,CArtikul);
  if (P<>nil) and (P^.List^.Count>0) then
  for i:=0 to P^.List^.Count-1 do
  begin
    ws:=P^.GetText(i,P^.List^.Count);
    if StrToInt(sKod)=StrToInt(copy(ws,1,CArtikul)) then
    begin

      {заказ}
       sKol:=Copy(s,1+CARtikul+1,CKol);
       sKOl:=IntToStr(StrToInt(sKol)+StrToInt(copy(ws,1+CARtikul+1,CKol)),CKol);
       sZena:=copy(s,1+CArtikul+1+Ckol+1,CIZena);
       MyStr(StrToReal(copy(ws,1+CArtikul+1+Ckol+1,CIZena))+StrToReal(sZena),CIzena,CMantissa,SZena);
       rformat(sKOl,CKol);
       rformat(sZena,CIZena);
       system.Delete(ws,1+CArtikul+1,CKol);
       System.Insert(sKOl,ws,1+CArtikul+1);
       system.Delete(ws,1+CArtikul+1+CKol+1,CIZena);
       System.Insert(sZena,ws,1+CArtikul+1+CKol+1);
      {фактически}
       sKol:=Copy(s,1+CARtikul+1+CKol+1+CIZena+1,CKol);
       sKOl:=IntToStr(StrToInt(sKol)+StrToInt(copy(ws,1+CARtikul+1+CKol+1+CIZena+1,CKol)),CKol);
       sZena:=copy(s,1+CArtikul+1+Ckol+1+CIZena+1+CKol+1,CIZena);
       MyStr(StrToReal(copy(ws,1+CArtikul+1+Ckol+1+CIZena+1+CKol+1,CIZena))+StrToReal(sZena),CIzena,CMantissa,SZena);
       rformat(sKOl,CKol);
       rformat(sZena,CIZena);
       system.Delete(ws,1+CArtikul+1+Ckol+1+CIZena+1,CKol);
       System.Insert(sKOl,ws,1+CArtikul+1+Ckol+1+CIZena+1);
       system.Delete(ws,1+CArtikul+1+CKol+1+CIZena+1+Ckol+1,CIZena);
       System.Insert(sZena,ws,1+CArtikul+1+CKol+1+CIZena+1+Ckol+1);

      find:=true;

      P^.List^.AtFree(i);
      P^.SetRange(P^.List^.Count);

      P^.List^.Insert(NewStr(ws));
      P^.SetRange(P^.List^.Count);

    end;
  end;

  if not Find then
  Begin

    P^.List^.Insert(NewStr(s));
    P^.SetRange(P^.List^.Count);

  End;

End;

function AddFullPredZakazToReport(s:string;P:PBox):boolean;
var find: boolean;
    i,j: word;
    sKod:ArtikulStr;
    sZakKod: string[CZena];
    sKOl: string[CKol];
    sZena: string[CIZena];
    ws:string;
Begin
  find:=false;
  sKOd:=copy(s,1,CArtikul);
  sZakKOd:=copy(s,1+CArtikul+1+Ckol+CIZena+1+CKol+1+CIZena+1,CZena);
  if (P<>nil) and (P^.List^.Count>0) then
  for i:=0 to P^.List^.Count-1 do
  begin
    ws:=P^.GetText(i,P^.List^.Count);
    if StrToInt(sKod)=StrToInt(copy(ws,1,CArtikul)) then
    if StrToInt(sZakKOd)=StrToInt(copy(s,1+CArtikul+1+Ckol+CIZena+1+CKol+1+CIZena+1,CZena)) then
    begin
      {заказ}
       sKol:=Copy(s,1+CARtikul+1,CKol);
       sKOl:=IntToStr(StrToInt(sKol)+StrToInt(copy(ws,1+CARtikul+1,CKol)),CKol);
       sZena:=copy(s,1+CArtikul+1+Ckol+1,CIZena);
       MyStr(StrToReal(copy(ws,1+CArtikul+1+Ckol+1,CIZena))+StrToReal(sZena),CIzena,CMantissa,SZena);
       rformat(sKOl,CKol);
       rformat(sZena,CIZena);
       system.Delete(ws,1+CArtikul+1,CKol);
       System.Insert(sKOl,ws,1+CArtikul+1);
       system.Delete(ws,1+CArtikul+1+CKol+1,CIZena);
       System.Insert(sZena,ws,1+CArtikul+1+CKol+1);
      {фактически}
       sKol:=Copy(s,1+CARtikul+1+CKol+1+CIZena+1,CKol);
       sKOl:=IntToStr(StrToInt(sKol)+StrToInt(copy(ws,1+CARtikul+1+CKol+1+CIZena+1,CKol)),CKol);
       sZena:=copy(s,1+CArtikul+1+Ckol+1+CIZena+1+CKol+1,CIZena);
       MyStr(StrToReal(copy(ws,1+CArtikul+1+Ckol+1+CIZena+1+CKol+1,CIZena))+StrToReal(sZena),CIzena,CMantissa,SZena);
       rformat(sKOl,CKol);
       rformat(sZena,CIZena);
       system.Delete(ws,1+CArtikul+1+Ckol+1+CIZena+1,CKol);
       System.Insert(sKOl,ws,1+CArtikul+1+Ckol+1+CIZena+1);
       system.Delete(ws,1+CArtikul+1+CKol+1+CIZena+1+Ckol+1,CIZena);
       System.Insert(sZena,ws,1+CArtikul+1+CKol+1+CIZena+1+Ckol+1);

      find:=true;

      P^.List^.AtFree(i);
      P^.SetRange(P^.List^.Count);

      P^.List^.Insert(NewStr(ws));
      P^.SetRange(P^.List^.Count);

    end;
  end;

  if not Find then
  Begin

    P^.List^.Insert(NewStr(s));
    P^.SetRange(P^.List^.Count);

  End;

End;



Function PredZakazReport:boolean;
Var FIDX: File;
    IDX: PBufHeaderPredZakazType;
    FPZ: File of PredZakazType;
    E: PPredZakazType;
    PZ: PPredZakazType;
    FZ: file of ZakazType;
    Z: ZakazType;
    i, IORez: word;
    s,ws: string;
    t: text;
    Agent,NoScreanList,ScreanList: PBox;
    AgKOd: ArtikulStr;
    R: TREct;
    Start,Stop: longint;
    count,c: word;
    sKod: ArtikulStr;
    sZakKod,sOldZakKod: string[CZena];
    sKol: string[CKol];
    sZena: string[CZena];
    sName: string[CName];
    wZakazNumer: longint;
    sSumKol,sSumFaktKOl: string[CKol];
    sSumZakKol,sSumZakFaktKOl: string[CKol];
    sSumZena,sSumFaktZena: string[CIZena];
    sSumZakZena,sSumZakFaktZena: string[CIZena];
    vid: word;
    Defizit: boolean;
    SAg,sAgName: string[CName];
    sWarn: string[1];
Begin

PredZakazReport:=false;

{период}
If Not(PeriodProd) Then Exit;

Start:=DateStringToDate(DateMask,StartDate);
Stop:=DateStringToDate(DateMask,StopDate);

{список агентов}
R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));

If Not(SelectionAgent(Agent)) Then
 Begin
  {System.Close(FPZ);}
  Dispose(Agent,Done);
  Exit;
 End;



Vid:=SelectImport(19);
If Vid=2 Then
  Begin
   Dispose(Agent,Done);
   Exit;
  End;

R.Assign(0, 0, 0, 0);
NoScreanList := New(PBox, Init(R, 1, Nil));
NoScreanList^.NewList(New(PTextCollection, Init(0,1)));


Assign(FIDX,Path^.Dat.ToMarketIndex+'pzakaz.idx');
IORez:=ioresult;
Reset(FIDX,SizeOf(HeaderPredZakazType));
IORez:=ioresult;


sSumKol:='0';
sSumFaktKOl:='0';
sSumZena:='0.00';
sSumFaktZena:='0.00';



if IORez<>0 then
 Begin
  Dispose(Agent,Done);
  Dispose(NoScreanList,Done);
  MessageBox(#3'Ошибка отрытия '+Path^.Dat.ToMarketIndex+'pzakaz.idx! Код:'+IntToStr(IORez,CKol),Nil,
  mfError+mfCancelButton);
  Exit;
 End;


while not eof(FIDX) do
begin
  Count:=0;
  New(IDX,Init);
  DInfoMsgShkala('Просматриваю реестр предзаказов ...',0,FileSize(FIDX),FilePos(FIDX));
  ReadBufHeaderPredZakaz(FIDX,IDX,Count);


  For c:=1 To Count Do
  Begin
   If IDX^.Point.Dat[c].Status=5 Then   {??????????????????}
   if (IDX^.Point.Dat[c].DateC >= Start) and (IDX^.Point.Dat[c].DateC <= Stop) then
   SAg:=IntToStr(IDX^.Point.Dat[c].AgENTKod,CClientKod);
   RFormatZerro(SAg,CClientKod);

   If TestAgent(Agent,SAg) Then
   Begin
        {Открываем рееcтр предзаказов}

        Assign(fPZ,Path^.Dat.ToMarket+'pzakaz.db');
        IORez:=ioresult;
        Reset(FPZ);
        IORez:=ioresult;
        New(E,Init);
        GetPredZakaz(IntToStr(IDX^.Point.Dat[c].Document,CArtikul),E);

        s:='';
        {заказано}

    for i:=1 to E^.Dat.Amount do
    begin
        {для полного отчета}
        if Vid=0 then
        begin
          s:='';
          sKod:=E^.Dat.Element[i].BazKod;
          s:=s+sKod+SeparatorChar;
          sKol:=E^.Dat.Element[i].Kol;
          rformat(sKol,Ckol);
          s:=s+sKol+SeparatorChar;
          MyStr(StrToReal(E^.Dat.Element[i].Zena)*StrToReal(E^.Dat.Element[i].Kol),CIZena,CMantissa,sZena);
          rformat(sZena,CIZena);
          s:=s+sZena+SeparatorChar;
          sKol:='0';
          rformat(sKol,Ckol);
          s:=s+sKol+SeparatorChar;
          sZena:='0.00';
          rformat(sZena,CIZena);
          s:=s+sZena+SeparatorChar;
          sZakKod:=E^.Dat.ZakazNumer;
          rformat(sZakKod,CZena);
          s:=s+sZakKod+SeparatorChar;
          s:=s+E^.Dat.AgentKod+SeparatorChar;
          s:=s+GetOperatorField(FNAme,E^.Dat.Caption)+SeparatorChar;

          AddFullPredZakazToReport(s,NoScreanList);
        end;
          {для каткого отчета}
        if Vid=1 then
        begin
          s:='';
          sKod:=E^.Dat.Element[i].BazKod;
          s:=s+sKod+SeparatorChar;
          sKol:=E^.Dat.Element[i].Kol;
          rformat(sKol,Ckol);
          s:=s+sKol+SeparatorChar;
          MyStr(StrToReal(E^.Dat.Element[i].Zena)*StrToReal(E^.Dat.Element[i].Kol),CIZena,CMantissa,sZena);
          rformat(sZena,CIZena);
          s:=s+sZena+SeparatorChar;
          sKol:='0';
          rformat(sKol,Ckol);
          s:=s+sKol+SeparatorChar;
          sZena:='0.00';
          rformat(sZena,CIZena);
          s:=s+sZena+SeparatorChar;
          AddPredZakazToReport(s,NoScreanList);
        end;

   end;{For i}



        {получено}
         wZakazNumer:=StrToInt(E^.Dat.ZakazNumer);

         {MemC(IntToStr(IDX^.Point.Dat[c].Document,CArtikul)+'-'+E^.Dat.ZakazNumer);}


         IOrez:=ioresult;
         Close(FPZ);
         IOrez:=ioresult;

         Assign(FZ,Path^.Dat.ToMarket+'zakaz.db');
         IOrez:=ioresult;
         Reset(FZ);
         IOrez:=ioresult;
         if iorez=0 then
          Begin
           if wZakazNumer < FileSize(FZ) then
           begin
             IOrez:=ioresult;
             Seek(FZ,wZakazNumer-1);
             IOrez:=ioresult;
             read(FZ,Z);
             IOrez:=ioresult;

            if IORez = 0 then
            Begin
             if Z.Oformlenie<2 then{только оформленные заказы}
             Begin
             for i:=1 to Z.Amount do
             begin

               {Для полного отчета}
              if Vid=0 then
                begin
                 s:='';
                 sKod:=Z.MarketElement[i].BazKod;
                 s:=s+sKod+SeparatorChar;
                 sKol:='0';
                 rformat(sKol,Ckol);
                 s:=s+sKol+SeparatorChar;
                 sZena:='0.00';
                 rformat(sZena,CIZena);
                 s:=s+sZena+SeparatorChar;
                 sKol:=Z.MarketElement[i].Input.Kol;
                 rformat(sKol,Ckol);
                 s:=s+sKol+SeparatorChar;
                 If z.SkidkaSelector=0 Then{Если автомат}
                  begin
                   DelSpace(z.MarketElement[i].Input.Proz);
                   MyStr((StrToReal(z.MarketElement[i].Input.Zena)/
                   (1+StrToReal(z.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,sZena);
                  end
                  else
                   MyStr((StrToReal(z.MarketElement[i].Input.Zena)-StrToReal(z.MarketElement[i].Input.Skidka))
                   ,CZena,CMantissa,sZena);

                 MyStr(StrToReal(sZena)*StrToReal(Z.MarketElement[i].Input.Kol),CIZena,CMAntissa,sZena);
                 rformat(sZena,CIZena);
                 s:=s+sZena+SeparatorChar;

                 sZakKod:=E^.Dat.ZakazNumer;
                 rformat(sZakKod,CZena);
                 s:=s+sZakKod+SeparatorChar;

                 s:=s+E^.Dat.AgentKod+SeparatorChar;
                 s:=s+GetOperatorField(FNAme,E^.Dat.Caption)+SeparatorChar;

                 AddFullPredZakazToReport(s,NoScreanList);
                end;
               {Для краткого отчета}
              if Vid=1 then
                begin
                 s:='';
                 sKod:=Z.MarketElement[i].BazKod;
                 s:=s+sKod+SeparatorChar;
                 sKol:='0';
                 rformat(sKol,Ckol);
                 s:=s+sKol+SeparatorChar;
                 sZena:='0.00';
                 rformat(sZena,CIZena);
                 s:=s+sZena+SeparatorChar;
                 sKol:=Z.MarketElement[i].Input.Kol;
                 rformat(sKol,Ckol);
                 s:=s+sKol+SeparatorChar;
                 If z.SkidkaSelector=0 Then{Если автомат}
                  begin
                   DelSpace(z.MarketElement[i].Input.Proz);
                   MyStr((StrToReal(z.MarketElement[i].Input.Zena)/
                   (1+StrToReal(z.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,sZena);
                  end
                  else
                   MyStr((StrToReal(z.MarketElement[i].Input.Zena)-StrToReal(z.MarketElement[i].Input.Skidka))
                   ,CZena,CMantissa,sZena);

                 MyStr(StrToReal(sZena)*StrToReal(Z.MarketElement[i].Input.Kol),CIZena,CMAntissa,sZena);
                 rformat(sZena,CIZena);
                 s:=s+sZena+SeparatorChar;
                 AddPredZakazToReport(s,NoScreanList);
                end;
             End;{For z.Amount}
             End;{if Z.Oformlenie<2 then{только оформленные заказы}
            end{IORez=0}
            else MessageBox(^M+#3'Ошибка чтения заказа N '+IntTOStr(wZakazNumer,6),Nil,mfError+mfCancelButton);

           End{if wZakazNumer < FileSize(FZ) then}
           else

           begin
             MessageBox(^M+#3'Заказ N '+IntTOStr(wZakazNumer,6)+' отсутствует в базе заказов',Nil,mfError+mfCancelButton);
           end;


             System.Close(FZ);
          end{IORez=0}
          Else MessageBox(^M+#3'Ошибка открытия базы заказов! Код:'+IntToStr(IoRez,CKol),Nil,mfError+mfCancelButton);

      End;{For}

      Dispose(E,Done);

   end; {TestAgent}

End; {For}

  dISPOSE(IDX,Done);

end; {while not eof(FPZ) do}
NoInfoMsg;


R.Assign(0, 0, 0, 0);
ScreanList := New(PBox, Init(R, 1, Nil));
ScreanList^.NewList(New(PTextCollection, Init(0,1)));

if (NoScreanList<>nil) and  (NoScreanList^.List^.Count>0) then
for c:=0 to NoScreanList^.List^.Count-1 do
BEgin
  DInfoMsgShkala('Сортировка отчета  ...',0,NoScreanList^.List^.Count-1,c);
  s:=NoScreanList^.GetText(c,NoScreanList^.List^.Count);

  {Подсчитали суммы}
  sSumKol:=IntToStr(StrToInt(sSumKol)+StrToInt(copy(s,1+CArtikul+1,CKol)),Ckol);
  sSumFaktKOl:=IntToStr(StrToInt(sSumFaktKol)+StrToInt(copy(s,1+CArtikul+1+Ckol+1+CIzena+1,CKol)),CKol);
  if (StrToInt(copy(s,1+CArtikul+1,CKol))-StrToInt(copy(s,1+CArtikul+1+Ckol+1+CIzena+1,CKol))=0)
  and (abs(StrToReal(copy(s,1+CArtikul+1+Ckol+1,CIZena))-StrToReal(copy(s,1+CArtikul+1+CKol+1+CIZena+1+Ckol+1,CIZena)))<0.009)
  then sWarn:=''
  else sWarn:='!';
  MyStr(StrToreal(sSumZena)+StrToReal(copy(s,1+CArtikul+1+Ckol+1,CIZena)),CIzena,CMantissa,sSumZena);
  MyStr(StrToreal(sSumFaktZena)+StrToReal(copy(s,1+CArtikul+1+CKol+1+CIZena+1+Ckol+1,CIZena)),CIzena,CMantissa,sSumFaktZena);

  {Полный отчет}
    {код агента Nзаказа Наименование}
  sName:=GetIdField(FName,copy(s,1,CArtikul));
  format(sName,CName);
  sZakKod:=copy(s,1+CArtikul+1+Ckol+1+cIZena+1+Ckol+1+cIZena+1,CZena);
  AgKOd:=copy(s,1+CArtikul+1+Ckol+1+cIZena+1+Ckol+1+cIZena+1+Czena+1,CArtikul-1);
  System.Delete(s,1+CArtikul+1+Ckol+1+cIZena+1+Ckol+1+cIZena+1+Czena+1,CArtikul);
  System.Delete(s,1+CArtikul+1+Ckol+1+cIZena+1+Ckol+1+cIZena+1,CZena+1);

  s:=sName+SeparatorChar+s;
  s:=sZakKod+SeparatorChar+s;
  s:=AgKod+SeparatorChar+s;


  ScreanList^.List^.Insert(NewStr(s+sWarn));
  ScreanList^.SetRange(ScreanList^.List^.Count);
End;

NoInfoMsg;

Dispose(NoScreanList,Done);


Assign(t,Path^.Dat.ToTemp+'pzakrep.txt');
IORez:=ioresult;
Rewrite(t);
IORez:=ioresult;
if IORez<>0 then
begin
 Dispose(ScreanList,Done);
 exit;
end;

  Writeln(t,Header+Space+'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword);
  WRiteln(t,'        ОТЧЕТ ПО ПРЕДЗАКАЗАМ  с '+StartDate+' по '+StopDate);
  WriteLN(t,Space+HeaderStop);


 WriteLN(t,Space+'Выбранные агенты: ');
 For i:=0 To Agent^.List^.Count-1 Do
   Begin
    s:=Agent^.GetText(i,Agent^.List^.Count);
    sKod:=Copy(s,1+1,CClientKod);
    ws:=GetAgentField(FAgent,sKod);
    Format(ws,CClient);
  s:=ws+s;
  While Pos('│',s)>0 Do s[Pos('│',s)]:=SeparatorChar;
  s[0]:=Chr(1+CClient+1+CClientKod);
  Writeln(t,Space+s);
 End;

 Dispose(Agent,Done);

 {Полный}
if Vid=0 then
begin
 Writeln(t,Header+Space+
  '┌────────────────────┬──────┬──────────────────────────┬─────┬─────┬───────────────┬─────┬───────────────┬────────┐');
 Writeln(t,Space+
  '│Агент               │Номер │ Наименование             │ Код │Кол. │  Сумма зак.   │Кол. │ Сумма факт.   │Оператор│');
 Writeln(t,Space+
  '│                    │заказа│                          │     │ зак.│               │факт.│               │        │');
 Writeln(t,Space+
  '└────────────────────┴──────┴──────────────────────────┴─────┴─────┴───────────────┴─────┴───────────────┴────────┘'+
 HeaderStop);
end;
 {Краткий}
if Vid=1 then
begin
 Writeln(t,Header+Space+' ┌─────────────────────────┬─────┬─────┬───────────────┬─────┬───────────────┐');
 Writeln(t,Space+' │ Наименование            │ Код │Кол. │  Сумма зак.   │Кол. │ Сумма факт.   │');
 Writeln(t,Space+' │                         │     │ зак.│               │факт.│               │');
 Writeln(t,Space+' └─────────────────────────┴─────┴─────┴───────────────┴─────┴───────────────┘'+
 HeaderStop);
end;

 if (ScreanList<>nil) and (ScreanList^.List^.Count>0) then
 s:=ScreanList^.GetText(0,ScreanList^.List^.Count);
 sOldZakKod:=Copy(s,1+CArtikul,CZena);
 sSumZakKol:='0';
 sSumZakFaktKOl:='0';
 sSumZakZena:='0.00';
 sSumZakFaktZena:='0.00';
 sSumZakKol:=IntToStr(StrToInt(sSumZakKol)+StrToInt(copy(s,1+CZena+1+CArtikul+1+CName+1,CKol)),Ckol);
 sSumZakFaktKOl:=IntToStr(StrToInt(sSumZakFaktKol)+StrToInt(copy(s,1+CZena+1+CArtikul+1+Ckol+1+CIzena+1+CName+1,CKol)),CKol);
 MyStr(StrToreal(sSumZakZena)+StrToReal(copy(s,1+CZena+1+CArtikul+1+Ckol+1+CName+1,CIZena)),CIzena,CMantissa,sSumZakZena);
 MyStr(StrToreal(sSumZakFaktZena)+StrToReal(copy(s,1+CZena+1+CArtikul+1+CKol+1+CIZena+1+Ckol+1+CName+1,CIZena)),CIzena,
     CMantissa,sSumZakFaktZena);

 if (ScreanList<>nil) and (ScreanList^.List^.Count>0) then
 for i:=0 to ScreanList^.List^.Count-1 do
 begin
   DInfoMsgShkala('Формирую отчет ...',0,ScreanList^.List^.Count-1,c);
   s:=ScreanList^.GetText(i,ScreanList^.List^.Count);
   {Убираем код агента}
   if Vid = 0 then
   begin
   sAgName:=GetAgentField(FAgent,copy(s,1,CClientKod));
   format(sAgName,CCLient);
   system.Delete(s,1,CArtikul);
   sZakKod:=Copy(s,1,CZena);
   if (StrToInt(sOldZakKod)<>StrToInt(sZakKod)) then
   begin
    Writeln(t,Space
 +'-------------------------------------------------------------------------------------------------------------------');
    Writeln(t,Space+'Итого по документу:                                             ',sSumZakKol,
      ' ',sSumZakZena,'   ',
      sSumZakFaktKOl,' ',sSumZakFaktZena);
    writeln(t);
    sOldZakKod:=sZakKod;
    sSumZakKol:='0';
    sSumZakFaktKOl:='0';
    sSumZakZena:='0.00';
    sSumZakFaktZena:='0.00';
   end;

   sSumZakKol:=IntToStr(StrToInt(sSumZakKol)+StrToInt(copy(s,1+CZena+1+CArtikul+1+CName+1,CKol)),Ckol);
   sSumZakFaktKOl:=IntToStr(StrToInt(sSumZakFaktKol)+StrToInt(copy(s,1+CZena+1+CArtikul+1+Ckol+1+CIzena+1+CName+1,CKol)),CKol);
   MyStr(StrToreal(sSumZakZena)+StrToReal(copy(s,1+CZena+1+CArtikul+1+Ckol+1+CName+1,CIZena)),CIzena,CMantissa,sSumZakZena);
   MyStr(StrToreal(sSumZakFaktZena)+StrToReal(copy(s,1+CZena+1+CArtikul+1+CKol+1+CIZena+1+Ckol+1+CName+1,CIZena)),CIzena,
     CMantissa,sSumZakFaktZena);
   end;{if Vid = 0 then}

   if Vid=0 then
   writeln(t,Space+sAgNAme+s)
   else writeln(t,Space+s);

   if Vid = 0 then
   if (i=ScreanList^.List^.Count-1) then
   begin
     Writeln(t,Space
 +'-------------------------------------------------------------------------------------------------------------------');
     Writeln(t,Space+'Итого по документу:                                              ',sSumZakKol,
      ' ',sSumZakZena,'    ',
      sSumZakFaktKOl,' ',sSumZakFaktZena);
   end;

 end;

  Writeln(t);
  Writeln(t,Space+'Всего: заказ '+sSumKOl+' шт. '+sSumZena+' руб.');
  Writeln(t,Space+'Всего: факт. '+sSumFaktKol+' шт. '+sSumFaktZena+' руб.');

  Writeln(t);
  Writeln(t,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  if Vid=1 then
  Writeln(t,Space+'=============================================================================');
  if Vid=0 then
  Writeln(t,Space
  +'===================================================================================================================');


NoInfoMsg;

Dispose(ScreanList,Done);

System.Close(t);

 ViewAsText(Path^.Dat.ToTemp+'pzakrep.txt','Ведомость предзаказов с '+StartDate+' по '+StopDate,True);

End;

BEGIN
END.