Unit HZ;

INTERFACE
Uses Glob,ServStr;

Function SelectionHZRazdel:Boolean;

IMPLEMENTATION

Uses Objects,App,Views,Validate,MsgBox, TPDate,Printers,Prise,
     Serv,Dialogs,Drivers,Dos,
     NetDbEng,DBEngine, Tools, Utils,Utils5, ColorTxt,Utils3,Utils4;


Type
  PRazdelHZSelectWindows = ^TRazdelHZSelectWindows;
  TRazdelHZSelectWindows = object(TDialog)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure AddName;
    Destructor Done; virtual;
  end;


VAR Razdel,RazdelSelect,AgentList,Errors: PBox;
    RazdelWinS: PRazdelHZSelectWindows;
    ControlAmount : PView;
    StartDate, StopDate, sDate: TDateString;
    Start,Stop, tek: longint;
    c: word;



Procedure CalcMrk(s: string;P:PBox; E:SupermarketType);
var sKod: string[CClientKod];
    sSumma: String[CIZena];
    sKol:string[CDate];
    sr: string[CrazdelKod];
    find: boolean;
    i,j: word;
    st: string;
Begin

If (P^.List^.Count-1)>=0 Then
Begin
For i:=0 To P^.List^.Count-1 Do
 Begin
  st:=P^.GetText(i,P^.List^.Count);
  sKod:=Copy(st,2,CClientKod);
  If StrToInt(copy(s,2,CClientKod))=StrToInt(sKOd) Then
   Begin
    sSumma:=Copy(st,1+1+CClientKod+1,CIZena);
    sKol:= Copy(st,1+1+CClientKod+1+CIZena+1+CIZena+1,CDate);
    sKOl:=IntToStr(StrToInt(sKol)+1,CDate);
    rformat(sKol,CDate);
    System.Delete(st,1+1+CClientKod+1+CIZena+1+CIZena+1,CDate);
    System.Delete(st,1+1+CClientKod+1,CIZena);
    MyStr(StrToReal(sSumma)+StrToReal(copy(s,1+1+CClientKod+1,CIZena)),CIZena,CMantissa,s);
    System.Insert(s,st,1+1+CClientKod+1);
    System.Insert(sKOl,st,1+1+CClientKod+1+CIZena+1+CIZena+1);

    {по разделам}
    if RazdelSelect^.List^.Count>0 then
    for j:=1 To E.Amount do
    begin
       sr:=copy(E.MarketElement[j].BazKod,1,CRazdelKod);
       if not(TestRazdelMemory (sr+'│',RazdelSelect)) then
       begin
         if E.SkidkaSelector=0 Then{Если автомат}
         begin
           DelSpace(E.MarketElement[j].Input.Proz);
           MyStr((StrToReal(E.MarketElement[j].Input.Zena)/
           (1+StrToReal(E.MarketElement[j].Input.Proz)/100)),CZena,CMantissa,sSumma);
         end
         else
           MyStr((StrToReal(E.MarketElement[j].Input.Zena)-StrToReal(E.MarketElement[j].Input.Skidka))
          ,CZena,CMantissa,sSumma);

           MyStr(StrToReal(copy(st,1+1+CClientKod+1+CIZena+1+CIZena+1+CDate+1+CIZena+1+CIZena+1+CIZena+1,CIZena))
           +StrToReal(sSumma)*
           StrToReal(E.MarketElement[j].Input.Kol),CIZena,CMantissa,sSumma);

           System.Delete(st,1+1+CClientKod+1+CIZena+1+CIZena+1+CDate+1+CIZena+1+CIZena+1+CIZena+1,CIZena);
           System.Insert(sSumma,st,1+1+CClientKod+1+CIZena+1+CIZena+1+CDate+1+CIZena+1+CIZena+1+CIZena+1);
       end;
    end;

    AgentList^.List^.AtFree(i);
    AgentList^.SetRange(AgentList^.List^.Count);
    AgentList^.List^.Insert(NewStr(st));
    AgentList^.SetRange(AgentList^.List^.Count);
    Break;
   End;{St=Cod}

 End;
 end;

End;

Procedure CalcOpl(s: string;P:PBox);
var sKod: string[CClientKod];
    sSumma: String[CIZena];
    find: boolean;
    i: word;
    st: string;
Begin
If (P^.List^.Count-1)>=0 Then
Begin
For i:=0 To P^.List^.Count-1 Do
 Begin
  st:=P^.GetText(i,P^.List^.Count);
  sKod:=Copy(st,2,CClientKod);
  If StrToInt(copy(s,2,CClientKod))=StrToInt(sKOd) Then
   Begin
    sSumma:=Copy(st,1+1+CClientKod+1+CIZena+1,CIZena);
    System.Delete(st,1+1+CClientKod+1+CIZena+1,CIZena);
    MyStr(StrToReal(sSumma)+StrToReal(copy(s,1+1+CClientKod+1,CIZena)),CIZena,CMantissa,s);
    System.Insert(s,st,1+1+CClientKod+1+CIZena+1);

    AgentList^.List^.AtFree(i);
    AgentList^.SetRange(AgentList^.List^.Count);
    AgentList^.List^.Insert(NewStr(st));
    AgentList^.SetRange(AgentList^.List^.Count);
    Break;
   End;{St=Cod}

 End;
 end;

End;

Procedure CalcVzw(s: string;P:PBox);
var sKod: string[CClientKod];
    sSumma: String[CIZena];
    find: boolean;
    i: word;
    st: string;
Begin
If (P^.List^.Count-1)>=0 Then
Begin
For i:=0 To P^.List^.Count-1 Do
 Begin
  st:=P^.GetText(i,P^.List^.Count);
  sKod:=Copy(st,2,CClientKod);
  If StrToInt(copy(s,2,CClientKod))=StrToInt(sKOd) Then
   Begin
    sSumma:=Copy(st,1+CClientKod+1+CIZena+1+CIZena+1+CDate+1,CIZena);
    System.Delete(st,1+1+CClientKod+1+CIZena+1+CIZena+1+CDate+1,CIZena);
    MyStr(StrToReal(sSumma)+StrToReal(copy(s,1+1+CClientKod+1,CIZena)),CIZena,CMantissa,s);
    System.Insert(s,st,1+1+CClientKod+1+CIZena+1+CIZena+1+CDate+1);

    AgentList^.List^.AtFree(i);
    AgentList^.SetRange(AgentList^.List^.Count);
    AgentList^.List^.Insert(NewStr(st));
    AgentList^.SetRange(AgentList^.List^.Count);
    Break;
   End;{St=Cod}

 End;
 end;

End;


Procedure CalcTekDolg(s: string;P:PBox);
var sKod: string[CClientKod];
    sSumma: String[CIZena];
    find: boolean;
    i: word;
    st: string;
Begin
If (P^.List^.Count-1)>=0 Then
Begin
For i:=0 To P^.List^.Count-1 Do
 Begin
  st:=P^.GetText(i,P^.List^.Count);
  sKod:=Copy(st,2,CClientKod);
  If StrToInt(copy(s,2,CClientKod))=StrToInt(sKOd) Then
   Begin
    sSumma:=Copy(st,1+1+CClientKod+1+CIZena+1+CIZena+1+CDate+1+CIZena+1,CIZena);
    System.Delete(st,1+1+CClientKod+1+CIZena+1+CIZena+1+CDate+1+CIZena+1,CIZena);
    MyStr(StrToReal(sSumma)+StrToReal(copy(s,1+1+CClientKod+1,CIZena)),CIZena,CMantissa,s);
    System.Insert(s,st,1+1+CClientKod+1+CIZena+1+CIZena+1+CDate+1+CIZena+1);

    AgentList^.List^.AtFree(i);
    AgentList^.SetRange(AgentList^.List^.Count);
    AgentList^.List^.Insert(NewStr(st));
    AgentList^.SetRange(AgentList^.List^.Count);
    Break;
   End;{St=Cod}

 End;
 end;

End;

Procedure CalcPrDolg(s: string;P:PBox);
var sKod: string[CClientKod];
    sSumma: String[CIZena];
    find: boolean;
    i: word;
    st: string;
Begin
If (P^.List^.Count-1)>=0 Then
Begin
For i:=0 To P^.List^.Count-1 Do
 Begin
  st:=P^.GetText(i,P^.List^.Count);
  sKod:=Copy(st,2,CClientKod);
  If StrToInt(copy(s,2,CClientKod))=StrToInt(sKOd) Then
   Begin
    sSumma:=Copy(st,1+1+CClientKod+1+CIZena+1+CIZena+1+CDate+1+CIZena+1+CIZena+1,CIZena);
    System.Delete(st,1+1+CClientKod+1+CIZena+1+CIZena+1+CDate+1+CIZena+1+CIZena+1,CIZena);
    MyStr(StrToReal(sSumma)+StrToReal(copy(s,1+1+CClientKod+1,CIZena)),CIZena,CMantissa,s);
    System.Insert(s,st,1+1+CClientKod+1+CIZena+1+CIZena+1+CDate+1+CIZena+1+CIZena+1);

    AgentList^.List^.AtFree(i);
    AgentList^.SetRange(AgentList^.List^.Count);
    AgentList^.List^.Insert(NewStr(st));
    AgentList^.SetRange(AgentList^.List^.Count);
    Break;
   End;{St=Cod}

 End;
 end;

End;

Procedure CalcDolgAgent;
Var R : TRect;
    ClientFile : File;
    ClientElement : PBufKurzClientType;
    RealFile : File;
    ClientList :PBox;
    E  : PBufRealizasiaType;
    st,s,s1 : String;
    TempS,w,w1 : AllStr;
    ws : TMyString;
    ii,c,t1,t2 : LongInt;
    r1,r2,Rsf,RsfSkid :Float;
    f : Text;
    Key,Delta,Space,sss : AllStr;
    PrevDistant:Word;
    Tip,Vid,Realno,
    Sort,Dis,IncludeDostavka: Word;
    jjj,Count : Word;
    Del : LongInt;
    K : WOrd;
    St1 : ArtikulStr;
    BakFileMode : Word;
    OldFileMode: word;
Begin

R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path^.Dat.ToClientBaseIndex+'Client.idx');
c:=IOResult;
OldFileMode:=FileMode;
FileMode:=ReadOnlyN;
Reset (ClientFile,SizeOf(KurzClientType));
c:=IOResult;
FileMode:=OldFileMode;
If c=0 Then
Begin

While Not(Eof(ClientFile)) Do
 Begin
    DInfoMsgShkala('Читаю списки консигнаторов. Ждите... ',0,FileSize(CLientFile),FilePos(CLientFile));
    New(ClientElement,Init);
    Count:=0;
    ReadBufKurzClient(ClientFile,ClientElement,Count);
    For jjj:=1 To Count Do
    Begin
      If ClientElement^.Point.Dat[jjj].Employ Then
        Begin
          Format(ClientElement^.Point.Dat[jjj].Name,CClient);
          St1:=IntToStr(ClientElement^.Point.Dat[jjj].Kod,CClientKod);
          RFormatZerro(St1,CClientKod);
          ClientList^.List^.Insert(NewStr(ClientElement^.Point.Dat[jjj].Name+'│'+st1{ClientElement^.Point.Dat[jjj].Kod}));
          ClientList^.SetRange(ClientList^.List^.Count);
        End;
    End;{For}
    Dispose(ClientElement,Done);
 End;{While}
System.Close(ClientFile);
End
Else
 Begin
  Close(f);
  NoInfoMsg;
  Dispose(ClientList,Done);
  MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов',Nil,mfError+mfCancelButton);
  Exit;
 End;
NoInfoMsg;

If ((ClientList^.List^.Count-1)>=0) Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    DInfoMsgShkala('Рассчитываю долги агентов. Ждите... ',0,ClientList^.List^.Count-1,c);
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
    Assign(RealFile,Path^.Dat.ToDolg+st+'.dlg');
    ii:=IOResult;
    BakFileMode:=FileMode;
    FileMode:=$42;
    Reset(RealFile,SizeOf(RealizasiaType));
    ii:=IOResult;
    FileMode:=BakFileMode;
    If ii=0 Then
     Begin
      While Not(Eof(RealFile)) Do
       Begin
        New(E,Init);
        Count:=0;
        BlockRead(RealFile,E^.Point,BufferDLG,Count);

        For jjj:=1 To Count Do
          Begin
            If (E^.Point.Dat[jjj].Market.Active) Then
              Begin
               If Not(TestElement(E^.Point.Dat[jjj].Market.AgentKod+'│',AgentList)) Then
                 Begin
                   t2:=DateStringToDate(DAteMask,FDate);
                   t1:=E^.Point.Dat[jjj].MArket.Srok;

                   { тек долг}
                   if Not(E^.Point.Dat[jjj].Full) then
                   begin
                   MyStr((E^.Point.Dat[jjj].Dolg),CIZena,CMantissa,w);
                   rformat(w,CIzena);
                   CalcTekDolg('│'+E^.Point.Dat[jjj].Market.AgentKod+'│'+w,AgentList);
                   end;
                   {Просрочка}
                   if (Not(E^.Point.Dat[jjj].Full))And((t2-t1)>=0) then
                   begin
                   MyStr((E^.Point.Dat[jjj].Dolg),CIZena,CMantissa,w);
                   rformat(w,CIzena);
                   CalcPrDolg('│'+E^.Point.Dat[jjj].Market.AgentKod+'│'+w,AgentList);
                   end;

                   ws:=GetClientField(FClient,St,0);
                   DelSpace(E^.Point.Dat[jjj].MArket.AgentKod);
                   RFormatZerro(E^.Point.Dat[jjj].MArket.AgentKod,CClientKod);
                   r1:=r1+E^.Point.Dat[jjj].Dolg;
                   r2:=r2+(E^.Point.Dat[jjj].Market.Skidka);


                   MyStr((E^.Point.Dat[jjj].Market.Skidka),CIZena,CMantissa,sss);

                 end; {If Not(TestElement(}
              End;{active}
         End;{For}

         Dispose(E,Done);
      End;{While}
     ii:=IOResult;
     Close(RealFile);
     ii:=IOResult;
  End;
End;

End;

Dispose(ClientList,Done);

NoInfoMsg;
End;

function CalcHZ: boolean;
Var i : word;
    s:string;
    t: text;
    IOrez: word;
    m: PBufSuperMarketType;
    fm,f: file;
    Opl : PBufOplataRealizasiaType;
    c1,j,Count,OldFileMode: word;
    sZena: string[CIzena];
    v: PNewVozwratType;
    fv: file of NewVozwratType;
    sRashodSumma,sSumma: string[CIZena];
    sclKod: string[CClientKod];
    Event: TEvent;
    TmpBox: PBox;
    R: TRect;
Function GetAgentFromOpl(O:OplataRealizasiaType):AllStr;
var E: PSuperMarketType;
    As:DocumentEditZ;
Begin
  GetAgentFromOpl:='';
  As.D:=O.DateDoc;
  As.EditPosition:=O.Document;
  new(E,Init);
  If GetMarket1(As, E) Then GetAgentFromOpl:=E^.Dat.AgentKod;
  Dispose(E,Done);
End;


Function GetAgentFromReturn(v:NewVozwratType):AllStr;
var E: PSuperMarketType;
    As:DocumentEditZ;
Begin
  GetAgentFromReturn:='';
  As.D:=v.BasisDate;
  As.EditPosition:=v.BasisDoc;
  new(E,Init);
  If GetMarket1(As, E) Then GetAgentFromReturn:=E^.Dat.AgentKod;
  Dispose(E,Done);
End;

Begin
  CalcHZ:=false;
  {отгрузки}
for tek:=Start to Stop do
 BEGIN
  DInfoMsgShkala('Просматриваю отгрузки за период с '+StartDate+' по '+StopDate+'...',
  Start,Stop,Tek);
  sDate:=DateToDateString(DateMask,tek);
  Assign(fm,Path^.Dat.Tomarket+sDate+'.mrk');
  IOrez:=ioresult;
  OldFileMode:=FileMode;
  FileMode:=ReadOnlyN;
  Reset(fm,SizeOf(SupermarketType));
  IOrez:=ioresult;
  FileMode:=OldFileMode;
  if IOrez<>0 then
  begin
     if Errors<> nil then
     begin
       Errors^.List^.Insert(NewStr('Не найдены продажи за  '+sDate+' ('+
       DayString[DayOfWeek(tek)]+')'));
       Errors^.SetRange(Errors^.List^.Count);
     end;
    continue;
  end
  else
  Begin
    while not eof(fm) do
    begin
    new(m,Init);
    ReadBufMarket(fm,m,Count);
    for j:=1 to Count do
    BEGIN
      if m^.Point.Dat[j].Active then
      if (((m^.Point.Dat[j].Realiz) and (m^.Point.Dat[j].DocSelector in [5,6,7,8]))
       Or (not(m^.Point.Dat[j].Realiz))and (m^.Point.Dat[j].DocSelector in [0,1,2,3,4]))
       then
       if
        (Not(TestElement(m^.Point.Dat[j].AgentKod+'│',AgentList)))
         then
      begin
        {Код агента}
        s:='│'+M^.Point.Dat[j].AgentKod+'│';
        rformat(m^.Point.Dat[j].SummaZ,CIZena);
        s:=s+m^.Point.Dat[j].SummaZ;
        CalcMrk(s,AgentList,m^.Point.Dat[j]);
      end;
    end;
    Dispose(m,Done);
  End;
    close(fm);

  End;
 END;

 NoInfoMsg;
  {оплаты}
For tek:=Start To Stop Do
Begin
 sDAte:=DateToDateString(DateMask,tek);
 DInfoMsgShkala('Просматриваю оплаты консигнации за '+sDate+' ...',Start,Stop,tek);
 Assign(F,Path^.Dat.ToOplata+sDate+'.opl');
 IOrez:=IOResult;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(f,SizeOf(OplataRealizasiaType));
 IOrez:=Ioresult;
 FileMode:=OldFileMode;
 If IOrez=0 Then
 Begin
  While Not Eof(f) Do
  Begin
   New(Opl,Init);
   Count:=0;
   ReadBufOplata(F,Opl,Count);
   For c1:=1 To Count Do
   Begin
      s:=GetAgentFromOpl(Opl^.Point.Dat[c1]);

      If Not TestElement(s+'│', AgentList) Then
      If (Opl^.Point.Dat[c1].SkladKod=Rek^.Dat.Kod) Then
          If Not(Opl^.Point.Dat[c1].Vozwrat) Then
            Begin
             rformat(Opl^.Point.Dat[c1].SummaZ,CIZena);
             s:='│'+s+'│'+Opl^.Point.Dat[c1].SummaZ;
             CalcOpl(s,AgentList);
            end;
   End;{For}
    Dispose(Opl,Done)
  End;
 end;
 Iorez:=Ioresult;
 Close(f);
 Iorez:=Ioresult;
End;

  NoInfoMsg;

{возвраты}

For tek:=Start To Stop Do
Begin
 sDAte:=DateToDateString(DateMask,tek);
 DInfoMsgShkala('Просматриваю возвраты за '+sDate+' ...',Start,Stop,tek);
 Assign(fv,Path^.Dat.ToReturn+ SDate +'.vzw');
 IORez:=IOResult;
 Reset (fv);
 IORez:=IOResult;
 If IORez<>0 Then
 Begin
   Errors^.List^.Insert(NewStr(' Отсутствуют данные о возвратах за '+sDate
       + ' "'+DayString[DayOfWeek(DateStringToDate(DateMask,sDate))]+'" '));
   Errors^.SetRange(Errors^.List^.Count);
 End
 else
 Begin
   while not eof(fv) do
     begin
       new(v,Init);
       read(fv,v^.Dat);

       s:=GetAgentFromReturn(v^.Dat);

       If Not TestElement(s+'│', AgentList) Then
       if (v^.Dat.OperatorSelector in [0,2]) then
       {If (v^.Dat.VidDocument in [4,5]) Then}
       Begin
         if v^.Dat.Rashod then sRashodSumma:=v^.Dat.RashodSumma;
            {величина возврата}
         MyStr(StrToReal(v^.Dat.SummaR)-StrToReal(v^.Dat.Skidka)
         {+StrToReal(sRashodSumma)},CIZena,CMantissa,sSumma);
         s:='│'+s+'│'+sSumma;
         CalcVzw(s,AgentList);
       end;
        Dispose(v,Done);
     end; {while not eof(fv)}
     close(fv);
 end;

End;

  NoInfoMsg;

  {Долги}
  CalcDolgAgent;

  Assign(t,Path^.Dat.ToTemp+'repag.csv');
  IOrez:=ioresult;
  rewrite(t);
  IOrez:=ioresult;



if IORez=0 then
begin
  writeln(t,DosToWin(';;Отчет за преиод с '+StartDate+' по '+StopDate));
  writeln(t);
  writeln(t,DosToWin('Выбраны разделы:;'));
  if RazdelSelect^.List^.count>0 then
  for i:=0 to RazdelSelect^.List^.count-1 do
  begin
    s:=RazdelSelect^.GetText(i,RazdelSelect^.List^.count);
    while  Pos('│',s)>0 Do s[Pos('│',s)]:=';';
    writeln(t,DosToWin(s));
  end
  else writeln(t,DosToWin('Нет выбранных разделов;'));
  writeln(t);
  writeln(t,DosToWin('Торговый представитель;Отгрузка;Оплата;Кол-во докум.;Возврат;Тек.долг;'
  +'Просроч.долг;Сумма реал.по разделам;'));


  {Сорт по агентам}

  TmpBox := New(PBox, Init(R, 1, Nil));
  TmpBox^.NewList(New(PTextCollection, Init(0,1)));


  if AgentList^.List^.Count>0 then
  for i:=0 to AgentList^.List^.Count-1 do
  begin
    s:=AgentList^.GetText(i,AgentList^.List^.Count);
    While Pos('│',s)>0 Do s[Pos('│',s)]:=';';
    sclKod:=copy(s,1+1,CClientKod);
    system.Delete(s,1+1,CClientKod+1);
    s:=GetAgentField(FAgent,sclKod)+s;
    TmpBox^.List^.Insert(NewStr(s));
    TmpBox^.SetRange(TmpBox^.List^.Count);
  end;

  Dispose(AgentList,Done);

  if TmpBox^.List^.Count>0 then
  for i:=0 to TmpBox^.List^.Count-1 do
  begin
    s:=TmpBox^.GetText(i,TmpBox^.List^.Count);
    writeln(t,DosToWin(s));
  end;

  Dispose(TmpBox,Done);

end {if IORez=0}
else
begin
  MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'repag.csv'+
   +' Код:'+IntToStr(IOrez,3),Nil,mfError+mfCancelButton);
   Dispose(Errors,Done);
   Dispose(AgentList,Done);
   exit;
end;


  Dispose(Errors,Done);

  IOrez:=ioresult;
  Close(t);

  Sound(100);
  DInfoMsg('Расчет завершен. Данные импортированы в '+Path^.Dat.ToTemp+'repag.csv',False);
  NoSound;
  Application^.ClearEvent(Event);
  Application^.GetEvent(Event);
  Application^.ClearEvent(Event);
  repeat
  Application^.GetEvent(Event);
  until (Event.What <> evNothing) And (Event.Command<>cmMenu);
  NoInfoMsg;
  Application^.ClearEvent(Event);


   If Path^.Dat.ToExcel[0]<>#0 Then
   Exec(GetEnvMy,' /C Start /D'+Path^.Dat.ToExcel+' '+Path^.Dat.ToTemp+'repag.csv');

  CalcHZ:=true;
End;


Function SelectionHZRazdel:Boolean;
Var RazdelFile : File;
    RazdelElement : PBufRazdelType;
    c1,Count1 : Word;
    sKOl: string[CDate];
    sZena: string[CIZena];
    TmpBox: PBox;
    st: string;
var
  R : TRect;
  Control : PView;
begin
SelectionHZRazdel:=False;

If Not DatePeriodDialog(StartDate,StopDate,False) Then Exit;

  Start:=DateStringToDate(DateMask,StartDate);
  Stop:=DateStringToDate(DateMask,StopDate);

R.Assign(0, 0, 0, 0);
Errors:= New(PBox, Init(R, 1, Nil));
Errors^.NewList(New(PMyCollection, Init(0,1)));



R.Assign(0, 0, 0, 0);
AgentList := New(PBox, Init(R, 1, Nil));
AgentList^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0, 0, 0, 0);
TmpBox := New(PBox, Init(R, 1, Nil));
TmpBox^.NewList(New(PTextCollection, Init(0,1)));


If Not(SelectionAgent(TmpBox)) Then
 Begin
  Dispose(AgentList,Done);
  Dispose(TmpBox,Done);
  Dispose(Errors,Done);
  Exit;
 End;

if TmpBox^.List^.Count>0 then
for c1:=0 to TmpBox^.List^.Count-1 do
begin
  st:=TmpBox^.GetText(c1,TmpBox^.List^.Count);
  st[0]:=chr(1+CClientKod+1);
  sKol:='0';
  rformat(sKol,CDate);
  sZena:='0.00';
  rformat(sZena,CIZena);
  st:=st+sZena+'│'+sZena+'│'+sKol+'│'+sZena+'│'+sZena+'│'+sZena+'│'+sZena+'│';
  AgentList^.List^.Insert(NewStr(st));
  AgentList^.SetRange(AgentList^.List^.Count);
end;

Dispose(TmpBox,Done);

ClearFind;

R.Assign(1, 0, 54, 23);
New(RazdelWinS, Init(R, 'Укажите разделы для расчета объема отгрузки'));
RazdelWinS^.Options := RazdelWinS^.Options or ofCenterX or ofCenterY;
RazdelWinS^.HelpCtx:=$E002;

R.Assign(25, 2, 26, 22);
Control := New(PScrollBar, Init(R));
RazdelWinS^.Insert(Control);

R.Assign(1, 2, 25, 22);
Razdel := New(PBox, Init(R, 1, PScrollbar(Control)));
Razdel^.NewList(New(PTextCollection, Init(1,1)));
Assign (RazdelFile,Path^.Dat.Torazdel+'razdel.db');
c1:=IoResult;
Reset (RazdelFile,SizeOf(RazdelType));
c1:=IoResult;
If c1=0 Then
Begin
While Not(Eof(RazdelFile)) Do
 Begin
Count1:=0;
New(RazdelElement,Init);
BlockRead(RazdelFile,RazdelElement^.Point,BufferRazdel,Count1);
For c1:=1 To Count1 Do
Begin
  If RazdelElement^.Point.Dat[c1].Employ Then
   Begin
    Format (RazdelElement^.Point.Dat[c1].Name,CClient);
    Razdel^.List^.Insert(NewStr(RazdelElement^.Point.Dat[c1].Name+'│'+RazdelElement^.Point.Dat[c1].Kod));
    Razdel^.SetRange(Razdel^.List^.Count);
   End;
End;{For}
Dispose(RAzdelElement,Done);
End;{While}
System.Close(RazdelFile);
End;

Razdel^.FocusItem(0);
Razdel^.HelpCtx:=$E044;
RazdelWinS^.Insert(Razdel);

  R.Assign(1, 1, 25, 2);
  RazdelWinS^.Insert(New(PLabel, Init(R, 'Ра~з~делы             Код', Razdel)));

R.Assign(51, 2, 52, 22);
Control := New(PScrollBar, Init(R));
RazdelWinS^.Insert(Control);

R.Assign(27, 2, 51, 22);
RazdelSelect := New(PBox, Init(R, 1, PScrollbar(Control)));
RazdelSelect^.NewList(New(PTextCollection, Init(1,1)));
RazdelSelect^.HelpCtx:=$E041;
RazdelWinS^.Insert(RazdelSelect);

  R.Assign(27, 1, 51, 2);

  RazdelWinS^.Insert(New(PLabel, Init(R, 'Выбранн~ы~е разделы   Код', RazdelSelect)));


R.Assign(17, 22, 35, 23);
Control := New(PColoredText, Init(R, ' Выбрано разделов:', $74));
RazdelWinS^.Insert(Control);

R.Assign(35, 22, 40, 23);
ControlAmount := New(PColoredText, Init(R, #3+'0', $4e));
RazdelWinS^.Insert(ControlAmount);

RazdelWinS^.SelectNext(False);
RazdelWinS^.AddName;
NoInfoMsg;
C := Desktop^.ExecView(RazdelWinS);

If C <> cmCancel Then
 Begin
  ClearFind;
  If RazdelSelect^.List^.Count=0 Then
   Begin
    CalcHZ;
    Dispose(ControlAmount,Done);
    Dispose(RazdelSelect,Done);
    Dispose(RazdelWinS,Done);
    {MessageBox(^M+#3'Не выбрано ни одного раздела !',Nil,mfError+mfCancelButton);}
    Exit;
   End;
   SelectionHZRazdel:=True;
   CalcHZ;
   Dispose(Control,Done);
   Dispose(ControlAmount,Done);
   Dispose(Razdel,Done);
   Dispose(RazdelSelect,Done);
   Dispose(RazdelWinS,Done);
 End
 else
 Begin
   CalcHZ;
   Dispose(Control,Done);
   Dispose(ControlAmount,Done);
   Dispose(Razdel,Done);
   Dispose(RazdelSelect,Done);
   Dispose(RazdelWinS,Done);
 End;

End;

Destructor TRazdelHZSelectWindows.Done;
Begin
TDialog.Done;
End;

procedure TRazdelHZSelectWindows.AddName;
Var R : TRect;
    KolStr : String[3];
Begin
  Str(RazdelSelect^.List^.Count:2,KolStr);
  Dispose(ControlAmount,Done);
  R.Assign(35, 22, 40, 23);
  ControlAmount := New(PColoredText, Init(R, #3+KolStr, $4e));
  RazdelWinS^.Insert(ControlAmount);
End;

procedure TRazdelHZSelectWindows.HandleEvent(var Event: TEvent);
Label 2,3;
Var s,s1,fstr : TMyString;
    Res : Word;
    Logik : Boolean;
    ls : Word;
Begin
  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
   kbEnter  :Begin
                ClearFind;
                inherited HandleEvent(Event);
                If (RazdelWinS^.Current=PView(Razdel)) Then
                   Begin
                    Event.What:=evCommand;
                    Event.Command:=CmOk;
                   End;
             End;

   kbGrayPlus,kbAltF1:Begin
                ClearFind;
          If ((RAzdel^.State and sfFocused <> 0)And(RAzdel^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...',True);
             For ls :=0 To RAzdel^.List^.Count-1 Do
              Begin
               s:=RAzdel^.GetText(ls,RAzdel^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CRAzdel);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               If TestElement(Copy(s,1+CRAzdel+1,CRazdelKod),RazdelSelect) Then
                Begin
                 RazdelSelect^.List^.Insert(NewStr(s));
                 RazdelSelect^.SetRange(RAzdelSelect^.List^.Count);
                End;{TestElement}
              End;{For}
              NoInfoMsg;
              ProdagaWindow:=False;
              If RAzdelSelect^.Focused+1<RAzdelSelect^.List^.Count Then
              RAzdelSelect^.FocusItem(RAzdelSelect^.List^.Count-1);
              RAzdelSelect^.FocusItem(0);
                End;{Maska}
              Redraw;
              AddName;
            End;{Nil}
              ClearEvent(Event);
              End;
   kbGrayMinus,kbAltF2:Begin
                ClearFind;
          If ((RAzdelSelect^.State and sfFocused <> 0)And(RAzdelSelect^.List^.Count>= 1)) Then
            Begin
               fstr[0]:=#0;
               Res:=0;
               ProdagaWindow:=False;
               ClearFind;
               If MaskaSelect(fstr,Res) Then
                Begin
             DInfoMsg('Минуточку...',True);
             3:
             if (RAzdelSelect^.List^.Count>= 1) Then
             For ls :=0 To RAzdelSelect^.List^.Count-1 Do
              Begin
               s:=RAzdelSelect^.GetText(ls,RAzdelSelect^.List^.Count);
               Logik:=False;
               s1:=Copy(s,1,CRAzdel);
               DelSpaceRight(s1);
               Case Res Of
               0:If (Pos(fstr,s1)>0)Or (Pos('*',Fstr)>0)  Then Logik:=True;
               1:If (fstr=s1) Then Logik:=True;
               Else ;
               End;{Case}

               If Logik Then
               Begin
                RAzdelSelect^.List^.AtFree(Ls);
                RAzdelSelect^.SetRange(RAzdelSelect^.List^.Count);
                goto 3;
               End;
              End;{For}

             If RAzdelSelect^.Focused>0 Then
             RAzdelSelect^.FocusItem(RAzdelSelect^.Focused);

             If (RAzdelSelect^.Focused>=RAzdelSelect^.List^.Count) and(RAzdelSelect^.Focused>0) Then
             RAzdelSelect^.FocusItem(RAzdelSelect^.Focused-1);


              NoInfoMsg;
              ProdagaWindow:=False;
              RAzdelSelect^.FocusItem(0);
                End;{Maska}
             Redraw;
             AddName;
            End;{Nil}
              ClearEvent(Event);
              End;
   kbF1   : Begin
            ClearFind;
            If ((Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>= 1)) Then
            Begin
             RazdelSelect^.Focusitem(0);
             DInfoMsg('Минуточку...',True);
             For ls :=0 To Razdel^.List^.Count-1 Do
              Begin
               s:=Razdel^.GetText(ls,Razdel^.List^.Count);
               If GetRAzdelLitr(Copy(s,1+CRazdel+1,CRazdelKod))=1 Then
               if Testelement(Copy(s,1+CRazdel+1,CRazdelKod),RazdelSelect) then
                Begin
                 RazdelSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
                 If RazdelSelect^.Focused+1<RazdelSelect^.List^.Count Then
                 RazdelSelect^.FocusItem(RazdelSelect^.List^.Count-1);
              AddName;
             NoInfoMSg;
             End
            Else ClearEvent(Event);
            Redraw;
            End;

   kbF2   : Begin
            ClearFind;
            If ((Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>= 1)) Then
            Begin
             RazdelSelect^.Focusitem(0);
             DInfoMsg('Минуточку...',True);
             For ls :=0 To Razdel^.List^.Count-1 Do
              Begin
               s:=Razdel^.GetText(ls,Razdel^.List^.Count);
               If GetRAzdelStatus(Copy(s,1+CRazdel+1,CRazdelKod)) Then
               if Testelement(Copy(s,1+CRazdel+1,CRazdelKod),RazdelSelect) then
                Begin
                 RazdelSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
                 If RazdelSelect^.Focused+1<RazdelSelect^.List^.Count Then
                 RazdelSelect^.FocusItem(RazdelSelect^.List^.Count-1);
              AddName;
             NoInfoMSg;
             End
            Else ClearEvent(Event);
            Redraw;
            End;


   kbF3   : Begin
            ClearFind;
            If ((Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>= 1)) Then
            Begin
             RazdelSelect^.Focusitem(0);
             DInfoMsg('Минуточку...',True);
             For ls :=0 To Razdel^.List^.Count-1 Do
              Begin
               s:=Razdel^.GetText(ls,Razdel^.List^.Count);
               If GetRAzdelLitr(Copy(s,1+CRazdel+1,CRazdelKod))=0 Then
               if Testelement(Copy(s,1+CRazdel+1,CRazdelKod),RazdelSelect) then
                Begin
                 RazdelSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
                 If RazdelSelect^.Focused+1<RazdelSelect^.List^.Count Then
                 RazdelSelect^.FocusItem(RazdelSelect^.List^.Count-1);
              AddName;
             NoInfoMSg;
             End
            Else ClearEvent(Event);
            Redraw;
            End;


   kbCtrlIns: Begin
                ClearFind;
            If ((Razdel^.State and sfFocused <> 0)And(Razdel^.List^.Count>= 1)) Then
            Begin
             RazdelSelect^.Focusitem(0);
             For ls :=0 To Razdel^.List^.Count-1 Do
              Begin
               s:=Razdel^.GetText(ls,Razdel^.List^.Count);
               if Testelement(Copy(s,1+CRazdel+1,CRazdelKod),RazdelSelect) then
                Begin
                 RazdelSelect^.List^.Insert(NewStr(s));
                End;
              End;
                 RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
                 If Razdel^.Focused+1<Razdel^.List^.Count Then Razdel^.FocusItem(Razdel^.Focused+1);
                 If RazdelSelect^.Focused+1<RazdelSelect^.List^.Count Then
                 RazdelSelect^.FocusItem(RazdelSelect^.List^.Count-1);
              AddName;
             End
            Else ClearEvent(Event);
            Redraw;
            End;

  kbCtrLDel: Begin
                ClearFind;
     If (RazdelSelect^.State and sfFocused <> 0) And (RazdelSelect^.List<>Nil)And(RazdelSelect^.List^.Count>=1) Then
            Begin
             RazdelSelect^.NewList(nil);
             RazdelSelect^.NewList(New(PTextCollection, Init(1,25)));
            End;
            ClearEvent(Event);
             AddName;
             Redraw;
            End;
     kbDel: Begin
                ClearFind;
     If (RazdelSelect^.State and sfFocused <> 0) And (RazdelSelect^.List<>Nil)And(RazdelSelect^.List^.Count>=1) Then
            Begin
             RazdelSelect^.List^.AtFree(RazdelSelect^.Focused);
             RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
             If RazdelSelect^.Focused>0 Then
             RazdelSelect^.FocusItem(RazdelSelect^.Focused);

             If (RazdelSelect^.Focused>=RazdelSelect^.List^.Count) and(RazdelSelect^.Focused>0) Then
             RazdelSelect^.FocusItem(RazdelSelect^.Focused-1);

            End;
              ClearEvent(Event);
              AddName;
              Redraw;
            End;
      kbIns: Begin
                ClearFind;
            If(Razdel^.State and sfFocused <> 0) And (Razdel^.List^.Count>=1) Then
            Begin
               s:=Razdel^.GetText(Razdel^.Focused,Razdel^.List^.COunt);
               If TestElement(Copy(s,1+CRazdel+1,CRazdelKod),RazdelSelect) Then
               Begin
               RazdelSelect^.List^.Insert(NewStr(s));
               RazdelSelect^.SetRange(RazdelSelect^.List^.Count);
               s:=Copy(s,1+CRazdel+1,CRazdelKod);
               RazdelSelect^.FocusItem(LoCation(RazdelSelect,S,ProdagaWindow));
             If RazdelSelect^.Focused+1<RazdelSelect^.List^.Count Then
             RazdelSelect^.FocusItem(RazdelSelect^.List^.Count-1);
               End;
               If (Razdel^.Focused+1) <  Razdel^.List^.Count Then
               Razdel^.FocusItem(Razdel^.Focused+1);
              End;
              ClearEvent(Event);
              AddName;
              Redraw;
            End;
    Else;
    End;
    Else;
    End;
  inherited HandleEvent(Event);
End;



BEGIN
END.