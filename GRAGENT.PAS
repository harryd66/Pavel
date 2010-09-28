{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
{$I Compile.INC}

Unit GrAgent;

Interface

Uses Glob,Dialogs,Drivers,ServStr,MyCalc,Nastr;

procedure CalcGroupAgent;

IMPLEMENTATION

uses Objects, Views, MsgBox,Vision3,Validate,Access,
     DBEngine,TPDate,Vision1,Vision4,Vision2,Utils2,
     Tools,Prise,App, Serv, ColorTxt,Protect,DosWin,
        Prihod,Return,NetDbEng,Printers,Net,Utils;


procedure CalcGroupAgent;
Var f : MArketFileType;
    R : TRect;
    E : PSuperMarketType;
    s : string;
    l : Word;
    RetF : NewVozwratFileType;
    Ret  : PNewVozwratType;
    fr: file of RazdelType;
    raz: RazdelType;
    SZakupka,Delta,DateOpl,Date : TDAteString;
    NDS,z,AllLocZakupka,
    AllSkidka,AllItogo,ItogoSkidka,Itogo : Real;
    ww1: AllStr;
    txt1 : Text;
    t:text;
    Docs,Slujba,Current,Cur,sh,VidSkidka,Vid : Word;

    Space : TMyString;
    RAbday,Start,Stop,Den : LongInt;
    NoScreen,TempBox : PBox;

    DateOtgr,DateOplata: TDateString;
    StartDate,StopDate : TDateString;
    VidReport,c,Count,ClCount : Word;

    Doc,Cod,Ag:AllStr;
    Dohod,Dolg : Real;
    ws11,ws22:string;
    SumO,SumZ:AllStr;
    sgr,sr,sgrNew,srNew: string[CRazdelKOd];
    sZena,sSumma,prnZena: string[CIZena];
    sag,scl,sagNew,sclNew: string[CCLientKod];
    bFind: boolean;

Function TestAgent(Cod:ArtikulStr):Boolean;
Var L : Boolean;
    i : word;
    st : string;
Begin
TestAgent:=False;
If (Agent^.List^.Count-1)>=0 Then
Begin
For i:=0 To Agent^.List^.Count-1 Do
 Begin
  st:=Agent^.GetText(i,Agent^.List^.Count);
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    TestAgent:=True;
    Break;
   End;{St=Cod}
 End;
End;
End;

function GetGroupName(kod:ArtikulStr):AllStr;
var i: word;
    s,skod: string;
Begin
  GetGroupName:='';
  delspace(kod);
  if (Group<>nil) and (Group^.List^.Count>0) then
  begin
   for i:=0 to Group^.List^.Count-1 do
   begin
     s:=Group^.GetText(i,Group^.List^.Count);
     skod:=copy(s,1+CRazdel+1,CRazdelKod);

     if StrToInt(kod)=StrToInt(skod) then
     begin
	  GetGroupName:=copy(s,1,CRazdel);
       exit;
     end;
   end;
  end;
End;

procedure CalcMRK(E:PSuperMarketType;Art:ArtikulStr;ww1:string);
var find: boolean;
    s: string;
    sgr,sr,sgr1,sr1: string[CRazdelKOd];
    sZena: string[CIZena];
    sag,scl,sag1,scl1: string[CCLientKod];
    i: word;
    sMarker:string;
Begin
   find:=false;
   DelSpace(Art);
   DelSpace(ww1);
   sMarker:=GetIdField(FMarker,Art);
   Delspace(sMarker);
   sr:=copy(Art,1,CRazdelKod);
   if sMarker<>'' then sgr:='05' else
   sgr:=GetRazdelGroup(sr);
   sag:=E^.Dat.AgentKod;
   scl:=E^.Dat.ClientKod;
   if (NoScreen<>nil) and (NoScreen^.List^.Count>0) then
   for i:=0 to NoScreen^.List^.Count-1 do
   begin
     find:=false;
     s:=NoScreen^.GetText(i,NoScreen^.List^.Count);
     sgr1:=copy(s,1,CRazdelKod);
	sag1:=copy(s,1+CRazdelKod+1,CClientKod);
	sr1:=copy(s,1+CRazdelKod+1+CClientKod+1,CRazdelKod);
	scl1:=copy(s,1+CRazdelKod+1+CClientKod+1+CRazdelKod+1,CClientKod);
     if sgr= sgr1 then
     if sag=sag1 then
     if sr=sr1 then
     if scl=scl1 then
     Begin
       sZena:=copy(s,1+CRazdelKod+1+CClientKod+1+CRazdelKod+1+CClientKod+1,CIZena);
       MyStr(StrToreal(sZena)+StrToreal(ww1),CIzena,CMantissa,sZena);
       System.Delete(s,1+CRazdelKod+1+CClientKod+1+CRazdelKod+1+CClientKod+1,CIZena);
       rformat(sZena,CIZena);
       s:=s+sZena;

       NoScreen^.List^.AtFree(i);
       NoScreen^.SetRange(NoScreen^.List^.Count);
       NoScreen^.List^.Insert(NewStr(s));
       NoScreen^.SetRange(NoScreen^.List^.Count);

       find:=true;
       break;
     End;

   end; {if (NoScreen}

   if not find then
   begin
    {новая строка}
    Format(sgr,CRazdelKod);
    Format(sag,CClientKod);
    Format(sr,CRazdelKod);
    Format(scl,CClientKod);
    rFormat(ww1,CIZena);
    s:=sgr+';'+sag+';'+sr+';'+scl+';'+ww1;
    NoScreen^.List^.Insert(NewStr(s));
    NoScreen^.SetRange(NoScreen^.List^.Count);
   end;{if not find}
End;

procedure WriteShapka;
var i: word;
    ws: string;
begin

  WriteLN(txt1,DosToWin(';Детальные отгрузки по разделам'));
   WriteLN(txt1,DosToWin(';за период с '+StartDate+' по '+StopDate));
   WriteLN(txt1);
 WriteLN(txt1,DosToWin('Выбранные агенты:'));
 For i:=0 To Agent^.List^.Count-1 Do
   Begin
    s:=Agent^.GetText(i,Agent^.List^.Count);
    WS:=Copy(s,1+1,CClientKod);
    ws:=GetAgentField(FAgent,ws);
    Format(ws,CClient);
Writeln(txt1,DosToWin(copy(s,2,4)+';'+ws));
 End;
WriteLN(txt1);
IF vIDrEPORT=0 Then
begin
Writeln(txt1,DosToWin('Название;;;За прошедший месяц;;ПЛАН на МЕСЯЦ;;;ФАКТ'));
Writeln(txt1,DosToWin('N раздела;Раздел;Ф.И.О. ТП;ОХВАТ(ТТ);ПРОДАЖИ (руб);ПРИРАЩЕНИЕ(ТТ);УДЕРЖАНИЕ(ТТ);'+
   'ПРОДАЖИ (руб);ПРИРАЩЕНИЕ(ТТ);УДЕРЖАНИЕ(ТТ);ПРОДАЖИ (руб);'));
end
else
begin
Writeln(txt1,DosToWin('Название;;За прошедший месяц;;ПЛАН на МЕСЯЦ;;;ФАКТ'));
Writeln(txt1,DosToWin('N раздела;Раздел;ОХВАТ(ТТ);ПРОДАЖИ (руб);ПРИРАЩЕНИЕ(ТТ);УДЕРЖАНИЕ(ТТ);'+
   'ПРОДАЖИ (руб);ПРИРАЩЕНИЕ(ТТ);УДЕРЖАНИЕ(ТТ);ПРОДАЖИ (руб);'));
end;
end;

Begin
  If Not(DatePeriodDialog(StartDate,StopDate,False)) Then Exit;

R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));

If Not(SelectionAgent(Agent)) Then
 Begin
  Dispose(Agent,Done);
  Exit;
 End;

 Start:=DateStringToDate(DateMask,StartDate);
 Stop:=DateStringToDate(DateMask,StopDate);

  VidReport:=1;
  VidReport:=SelectImport(31);
 If VidReport=2 Then
  Begin
   Dispose(Agent,Done);
   Exit;
  End;

 Assign(Txt1,Path.ToTemp+'grmeng.csv');
 l:=IOResult;
 Rewrite(Txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Dispose(Agent,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path.ToTemp+'grmeng.csv',Nil,mfError+mfCancelButton);
   Exit;
  End;

 R.Assign(0,0,0,0);
 NoScreen:= New(PBox, Init(R, 1, Nil));
 NoScreen^.NewList(New(PTextCollection, Init(0,1)));

if  VidReport=0 then
begin
Writeln(txt1,DosToWin('Период программы:'));
Writeln(txt1,DosToWin('РЕГИОН:;;Тульская область'));
Writeln(txt1,DosToWin('ГОРОД:;;Тула'));
Writeln(txt1,DosToWin('ФИО составил:;;Еродский П.Е.'));
end;

WriteShapka;

For Den:=Start To Stop Do
Begin
 Date:=DateToDateString(DateMask,DEn);
 Assign(F,Path.ToMarket+Date+'.mrk');

 DInfoMsgShkala('Просматриваю операции за '+DateToDateString(DateMask,Den)+' ...',Start,Stop,Den);

 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 if l<>0 then continue;
 If l=0 Then
   Begin
     While Not (Eof(f)) Do
       Begin
        New(E,Init);
        Count:=0;
        ReadMArket(f,E);

         If E^.Dat.Active Then
         If (E^.Dat.OperatorSelector=0) And TestAgent(E^.Dat.AgentKod)
         And (E^.Dat.DocSelector in [0,1,2,3,4])
         Then
           Begin
             Docs:=0;
              If (E^.Dat.Realiz)  Then
               Begin
                 Case E^.Dat.DocSelector Of
                 0:Docs:=7;
                 1:Docs:=5;
                 3:Docs:=6;
                 4:Docs:=8;
                 Else ;
                 End;
              End
              Else
              Begin
                Docs:=E^.Dat.DocSelector;
              End; {If (E^.Dat.Realiz)}

             {здесь считаем продаж}
             RecalcFromVozwrat(E);

             For Cur:=1 To E^.Dat.Amount Do
             Begin
               {считаем отгрузку по ценам к оплате}
               Case E^.Dat.SkidkaSelector Of
               0,2:Begin{скидка автоматическая}
                     MyStr(StrToReal(E^.Dat.MarketElement[cur].Input.Zena)*
                     (StrToReal(E^.Dat.MarketElement[cur].Input.Proz)),CZena,CMantissa,
                        E^.Dat.MarketElement[cur].Input.Zena);
                   End;
               1:Begin{скидка ручная}
                  MyStr(StrToReal(E^.Dat.MarketElement[Cur].Input.Zena)-
                  StrToReal(E^.Dat.MarketElement[Cur].Input.Skidka),CZena,CMantissa,
                         E^.Dat.MarketElement[Cur].Input.Zena);
                   End;
               End;
            ww1:='0.00';
            MyStr(StrToInt(E^.Dat.MArketElement[Cur].Input.Kol)*
            StrToReal(E^.Dat.MArketElement[Cur].Input.Zena),
		  CIZena,CMantissa,ww1);
            Rformat(ww1,CIZena);
            CalcMRK(E,E^.Dat.MArketElement[Cur].BazKod,ww1);

             END; {For Cur:=1 To E^.Dat.Amount}

           End; {If E^.Dat.Active}
           Dispose(E,Done);
        end; {While Not (Eof(f))}
     System.Close(f);
   End;{If l=0 Then}
   NoInfoMsg;
End; {For Den:=Start}

{сводный отчет}
R.Assign(0, 0, 0, 0);
Group := New(PBox, Init(R, 1,nil));
Group^.NewList(New(PTextCollection, Init(0,1)));

Assign(t,Path.ToSklad+'group.txt');
c:=ioresult;
Reset(t);
c:=ioresult;

If c=0 Then
Begin
While Not(Eof(t)) Do
 Begin
  Readln(t,s);
  Group^.List^.Insert(NewStr(s));
  Group^.SetRange(Group^.List^.Count);
 End;
System.Close(t);
End;


R.Assign(0, 0, 0, 0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

IF vIDrEPORT=0 Then
if (Noscreen<>nil) and (Noscreen^.List^.Count>0) then
begin
for cur:=0 to Noscreen^.List^.Count-1 do
begin
  s:=Noscreen^.GetText(cur,Noscreen^.List^.Count);
  srNew:=copy(s,1+CRazdelKod+1+CClientKod+1,CRazdelKod);
  system.Delete(s,1+CRazdelKod+1+CClientKod,CRazdelKod+1);
  system.Insert(srNew+';',s,1+CRazdelKod+1);
  TempBox^.List^.Insert(NewStr(s));
  TempBox^.SetRange(TempBox^.List^.Count);
end;
end;

IF vIDrEPORT=1 Then
if (Noscreen<>nil) and (Noscreen^.List^.Count>0) then
begin
{вытаскиваем все разделы}
 Assign(fr,Path.ToRAzdel+'Razdel.db');
 cur:=IOResult;
 Reset(fr);
 cur:=IOResult;
 If cur=0 Then
 begin
   for cur:=0 to Agent^.List^.Count-1 do
   begin
     s:=Agent^.GetText(cur,Agent^.List^.Count);
     scl:=copy(s,2,4);
     while not eof(fr) do
     begin
       read(fr,raz);
       if raz.Employ then
       begin
       s:=scl+';'+GetRazdelGroup(raz.kod)+';'+raz.kod+';0000;            0.00';
       TempBox^.List^.Insert(NewStr(s));
       TempBox^.SetRange(TempBox^.List^.Count);
       end;
     end;
     Reset(fr);
   end;
 end;

for cur:=0 to Noscreen^.List^.Count-1 do
begin
  s:=Noscreen^.GetText(cur,Noscreen^.List^.Count);
  sagNew:=copy(s,1+CRazdelKod+1,CClientKod+1);
  system.Delete(s,1+CRazdelKod+1,CClientKod+1);
  s:=sagNew+';'+s;
  TempBox^.List^.Insert(NewStr(s));
  TempBox^.SetRange(TempBox^.List^.Count);
end;
end;

(*for cur:=0 to TempBox^.List^.Count-1 do
begin
  s:=TempBox^.GetText(cur,TempBox^.List^.Count);
  writeln(txt1,s)
end;*)

IF vIDrEPORT=0 Then
if (TempBox<>nil) and (TempBox^.List^.Count>0) then
Begin
  s:=TempBox^.GetText(0,TempBox^.List^.Count);
  sgr:='';{copy(s,1,CRazdelKod);}
  sag:=copy(s,1+CRazdelKod+1+CRazdelKod+1,CClientKod);
  sr:=copy(s,1+CRazdelKod+1,CRazdelKod);
  scl:='';{copy(s,1+CRazdelKod+1+CClientKod+1+CRazdelKod+1,CClientKod);}
  sZena:='0.00';
  sSumma:='0.00';
  ClCount:=0;

  for cur:=0 to TempBox^.List^.Count-1 do
  begin
    bFind:=false;
    s:=TempBox^.GetText(cur,TempBox^.List^.Count);
    sgrNew:=copy(s,1,CRazdelKod);
    sagNew:=copy(s,1+CRazdelKod+1+CRazdelKod+1,CClientKod);
    srNew:=copy(s,1+CRazdelKod+1,CRazdelKod);
    System.Delete(s,1,CRazdelKod+1);

  if (sag<>sagNew) or ((sag=sagNew) and (sr<>srNew)) then
  begin
     MyStr(StrToReal(sSumma)+StrToReal(sZena),CIZena,CMantissa,sSumma);
     while pos('.',sZena)>0 do sZena[pos('.',sZena)]:=',';
     prnZena:=sZena;
     while pos('.',prnZena)>0 do prnZena[pos('.',prnZena)]:=',';
     Write(txt1,DosToWin(';;Агент: '+GetAgentField(FClient,sag)));
     Writeln(txt1,';',ClCount,';'+prnZena);
      sAg:=sAgNew;
      sZena:='0.00';
      ClCount:=0;
  end;


    if (sgr<>sgrNew) then
    begin
      if cur>0 then
      begin
        prnZena:=ssUMMA;
        while pos('.',prnZena)>0 do prnZena[pos('.',prnZena)]:=',';
        Writeln(txt1,DosToWin(';Итого по разделу '+GetRazdel(sr)+':;'+PRNzENA));
        sr:=srNew;
        sSumma:='0.00';
      end;
      Writeln(txt1,DosToWin('Товарная группа: '+GetGroupName(sgrnew)));
      Writeln(txt1,DosToWin(srNew+';'+GetRazdel(srNew))+';');
      {if sr=srNew then
           Write(txt1,DosToWin(';Агент: '+GetAgentField(FClient,sagnew)));}
      bFind:=true;
    end
    else
    if cur<>0 then
    if sr<>srNew then
      begin
        prnZena:=ssUMMA;
        while pos('.',prnZena)>0 do prnZena[pos('.',prnZena)]:=',';
        Writeln(txt1,DosToWin(';Итого по разделу '+GetRazdel(sr)+':;'+PRNzENA));
        if not bFind then
        Writeln(txt1,DosToWin(srNew+';'+GetRazdel(srNew))+';');
        sr:=srNew;
        sSumma:='0.00';
        {if (sgr=sgrNew) then
        Write(txt1,DosToWin(';Агент: '+GetAgentField(FClient,sagnew)));}
      end;

      if bFind then
      begin
        sgr:=sgrnew;
        sSumma:='0.00';
      end;


  MyStr(StrToReal(sZena)+StrToReal(copy(s,1+CRazdelKod+1+CClientKod+1+CClientKod+1,CIzena)),CIzena,CMantissa,sZena);
  inc(ClCount);

  if cur=TempBox^.List^.Count-1 then
  begin
     MyStr(StrToReal(sSumma)+StrToReal(sZena),CIZena,CMantissa,sSumma);
     while pos('.',sZena)>0 do sZena[pos('.',sZena)]:=',';
     prnZena:=sZena;
     while pos('.',prnZena)>0 do prnZena[pos('.',prnZena)]:=',';
     Write(txt1,DosToWin(';;Агент: '+GetAgentField(FClient,sag)));
     Writeln(txt1,';',ClCount,';'+prnZena);

        prnZena:=ssUMMA;
        while pos('.',prnZena)>0 do prnZena[pos('.',prnZena)]:=',';
        Writeln(txt1,DosToWin(';Итого по разделу '+GetRazdel(sr)+':;'+PRNzENA));
        if not bFind then
        Writeln(txt1,DosToWin(srNew+';'+GetRazdel(srNew))+';');
  end;


  end; {for cur:=0 to TempBox^.List^.Count}

End;{IF vIDrEPORT=0}


IF vIDrEPORT=1 Then
if (TempBox<>nil) and (TempBox^.List^.Count>0) then
begin

(*for cur:=0 to TempBox^.List^.Count-1 do
begin
  s:=TempBox^.GetText(cur,TempBox^.List^.Count);
  writeln(txt1,DosToWin(s));
end;

writeln(txt1,'_______________________________________');*)

s:=TempBox^.GetText(0,TempBox^.List^.Count);
sgr:=copy(s,1+CClientKod+1,CRazdelKod);
sag:=copy(s,1,CClientKod);
sr:=copy(s,1+CClientKod+1+CRazdelKod+1,CRazdelKod);
scl:=copy(s,1+CClientKod+1+CRazdelKod+1+CRazdelKod+1,CClientKod);
sZena:='0.00';
sSumma:='0.00';
ClCount:=0;

for cur:=0 to TempBox^.List^.Count-1 do
begin

  s:=TempBox^.GetText(cur,TempBox^.List^.Count);
  sgrNew:=copy(s,1+CClientKod+1,CRazdelKod);
  sagNew:=copy(s,1,CClientKod);
  srNew:=copy(s,1+CClientKod+1+CRazdelKod+1,CRazdelKod);
  sclNew:=copy(s,1+CClientKod+1+CRazdelKod+1+CRazdelKod+1,CClientKod);
  system.Delete(s,1,CClientKod+1);

  if (cur=0) then
  begin
   Writeln(txt1,DosToWin(';Агент: '+GetAgentField(FClient,sagnew)));
   Writeln(txt1,DosToWin('Товарная группа: '+GetGroupName(sgrnew)));
  end;

  if (sgr<>sgrNew) then
  begin

  if sr<>srNew then
   begin
    prnZena:=sZena;
    while pos('.',prnZena)>0 do prnZena[pos('.',prnZena)]:=',';
    Writeln(txt1,sr+';'+DosToWin(GetRazdel(sr))+';',cLcOUNT-1,';'+prnZena);
    ClCount:=0;
    SR:=SRnEW;
    SzENA:='0.00';
   end;

   Writeln(txt1,DosToWin('Товарная группа: '+GetGroupName(sgrnew)));
   if cur=TempBox^.List^.Count-1 then
   begin
    prnZena:=sZena;
    while pos('.',prnZena)>0 do prnZena[pos('.',prnZena)]:=',';
    Writeln(txt1,sr+';'+DosToWin(GetRazdel(sr))+';',1,';'+prnZena);
    Writeln(txt1,DosToWin('Итого: '+sZena));
   end;

   sgr:=sgrnew;
   sSumma:='0.00';

  end; {if (sgr<>sgrNew)}

  if sr<>srNew then
   begin
    prnZena:=sZena;
    while pos('.',prnZena)>0 do prnZena[pos('.',prnZena)]:=',';
    Writeln(txt1,sr+';'+DosToWin(GetRazdel(sr))+';',cLcOUNT-1,';'+prnZena);
    ClCount:=0;
    SR:=SRnEW;
    SzENA:='0.00';
   end;

  if (sag<>sagNew) then
  begin
   if sr<>srNew then
   begin
    prnZena:=sZena;
    while pos('.',prnZena)>0 do prnZena[pos('.',prnZena)]:=',';
    Writeln(txt1,sr+';'+DosToWin(GetRazdel(sr))+';',cLcOUNT-1,';'+prnZena);
    ClCount:=0;
    SR:=SRnEW;
    SzENA:='0.00';
   end;
    if Cur<>0 then Writeln(txt1);
    Writeln(txt1,DosToWin(';Агент: '+GetAgentField(FClient,sagnew)));
    sag:=sagNew;
    sSumma:='0.00';
    if (sgr=sgrNew) then Writeln(txt1,DosToWin('Товарная группа: '+GetGroupName(sgrnew)));
  end;

  MyStr(StrToReal(sZena)+StrToReal(copy(s,1+CRazdelKod+1+CRazdelKod+1+CClientKod+1,CIzena)),CIzena,CMantissa,sZena);
  inc(ClCount);

end;
end;
NoInfoMsg;


System.Close(txt1);

memcc('Отчет сохранен в файле '+{Path.ToTemp+}'grmeng.csv' );

End;

BEGIN
END.
