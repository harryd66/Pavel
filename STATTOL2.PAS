{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Stattol2;


Interface

Uses Dialogs, Utils,ServStr;


Procedure BakConcurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska7;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;StartDatetov,StOpDatetov:TDAteString);

{
Procedure Concurs2(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska6;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;StartDatetov,StOpDatetov:TDAteString);
}




Implementation

Uses Serv,Drivers,Glob,TpDate,Tools,Printers,DbEngine,DbEngin2,
     ServStr2,
     NetDbEng, Objects, Slava2,Prise,MsgBox,Utils5;



Const MAxStatAgent=70;
      MAxStatNAme=82;
      MAxStatNAme1=700;
      {ReadOnly=0;}

    {массив клиентов}
Type ArrayClientMemory = Record
     ClientList  : PBox; {клиент│код клиента│Количество товара}
     Kod : ArtikulStr; {код товара}
     Employ : Boolean;{признак наименование используется в расчете}
    End;


    {массив позиций}
Type ArrayPositionMemory = Record
     NameList  : Array[0..MAxStatNAme] Of ArrayClientMemory;{наименования товара│количество за вычетом возврата}
     Employ : Boolean;{признак агент используется}
    End;


Type ArrayPositionMemory1 = Record
     NameList  : Array[0..MAxStatNAme1] Of ArrayClientMemory;{наименования товара│количество за вычетом возврата}
     Employ : Boolean;{признак агент используется}
    End;


Type Special = Array [0..MaxStatAgent] Of ArrayPositionMemory;


Type PSpecial = ^SpecialPtr;
     SpecialPtr =Object(TObject)
     Point :Special;
     Constructor Init;
     Destructor Done; Virtual;
End;

Type PSpecialNew = ^SpecialNewPtr;
     SpecialNewPtr =Object(TObject)
     Point :{SpecialNew}ArrayPositionMemory1;
     Constructor Init;
     Destructor Done; Virtual;
End;


Constructor SpecialPtr.Init ;
Begin
TObject.Init;
End;

Destructor SpecialPtr.Done;
Begin
TObject.Done;
End;


Constructor SpecialNewPtr.Init ;
Begin
TObject.Init;
End;

Destructor SpecialNewPtr.Done;
Begin
TObject.Done;
End;



VAr Stat : PSpecial;{массив агентов}
    Stat1 : PSpecialNew;{массив для наменований}
    OldFileMode : Word;
    AgentRekod : PBox;


Procedure NewElement(KodAg : Word;Const VArList :PBox{полный список конкурсных наименований});
Var R : TRect;
    s : String;
    c : Word;
Begin
R.Assign(0, 0, 0, 0);

With Stat^.Point[KodAg] Do
Begin
 Employ:=True;
 For c:=0 To VArList^.List^.Count-1 Do
  Begin
   s:=VArList^.GetText(c,VArList^.List^.Count);
   s:=Copy(s,1+CNAme+1,CArtikul);
   NameList[c].Kod:=s;
   NameList[c].Employ:=True;
   NameList[c].ClientList := New(PBox, Init(R, 1, Nil));
   NameList[c].ClientList^.NewList(New(PTextCollection, Init(0,1)));
  End;{For}
End;{With}

End;{NewElement}



               {код агента}   {позиция тоара}{код клиента}    {количество с плюсом}
Procedure AddMrk(KodAg : Word;Pos:Word;ClKod:ArtikulStr;Kol:TDAteString);
Var s,s1 : TMyString;
    c : Word;
    Find : Boolean;
    NewPos : LongInt;
Begin
Find:=False;

With Stat^.Point[KodAg].NameList[Pos] Do
Begin
If ClientList^.List^.Count>0 Then
Begin
For c:=0 To ClientList^.List^.Count-1 Do
Begin
 s:=ClientList^.GetText(c,
    ClientList^.List^.Count);
 s1:=Copy(s,1+1,CArtikul);

 If s1=ClKod Then
  Begin
   Find:=True;
   Break;
  End;

End;{For}
End;

If Find Then
 Begin
  {читаем старое количество}
  s1:=Copy(s,1+1+CArtikul+1,Ckol+1);
  {удаляем старое количество}
  System.Delete(s,1+1+CArtikul+1,CKol+1);
  DelSpace(s1);
  {поучаем новое количество}
  Str(StrToInt(s1)+StrToInt(Kol):CKOl+1,s1);
  {формируем новую строку}
  s:=s+s1;
  {уладяем старую строку из списка}
  ClientList^.List^.AtFree(c);
  {вставлем новую строчку}
  ClientList^.List^.Insert(NewStr(s));
  ClientList^.SetRange(
  ClientList^.List^.Count);
 End
 Else
  Begin{если клиент в списке отсутствовал}
   Str(StrToInt(Kol):CKol+1,Kol);
   s:='│'+ClKod+'│'+Kol;
   ClientList^.List^.Insert(NewStr(s));
   ClientList^.SetRange(
   ClientList^.List^.Count);
  End;
End{With}

End;{NewElement}



               {код агента}   {позиция тоара}{код клиента}    {количество с плюсом}
Procedure AddMrk1(KodAg : Word;Pos:Word;ClKod:ArtikulStr;Kol:TDAteString);
Var s,s1 : TMyString;
    c : Word;
    Find : Boolean;
    NewPos : LongInt;
Begin
Find:=False;


With Stat1^.Point.NameList[Pos] Do
Begin
If ClientList^.List^.Count>0 Then
Begin
For c:=0 To ClientList^.List^.Count-1 Do
Begin
 s:=ClientList^.GetText(c,
    ClientList^.List^.Count);
 s1:=Copy(s,1+1,CArtikul);

 If s1=ClKod Then
  Begin
   Find:=True;
   Break;
  End;

End;{For}
End;

If Find Then
 Begin
  {читаем старое количество}
  s1:=Copy(s,1+1+CArtikul+1,Ckol+1);
  {удаляем старое количество}
  System.Delete(s,1+1+CArtikul+1,CKol+1);
  DelSpace(s1);
  {поучаем новое количество}
  Str(StrToInt(s1)+StrToInt(Kol):CKOl+1,s1);
  {формируем новую строку}
  s:=s+s1;
  {уладяем старую строку из списка}
  ClientList^.List^.AtFree(c);
  {вставлем новую строчку}
  ClientList^.List^.Insert(NewStr(s));
  ClientList^.SetRange(
  ClientList^.List^.Count);
 End
 Else
  Begin{если клиент в списке отсутствовал}
   Str(StrToInt(Kol):CKol+1,Kol);
   s:='│'+ClKod+'│'+Kol;
   ClientList^.List^.Insert(NewStr(s));
   ClientList^.SetRange(
   ClientList^.List^.Count);
  End;
End{With}

End;{NewElement}




Procedure DoneArrayList;
Var  c : Word;
     j : Word;
Begin
For c:=0 To MaxStatAgent Do
Begin
 If Stat^.Point[c].Employ Then
  Begin
   For j:=0 To MaxStatNAme Do
    Begin
     If Stat^.Point[c].NameList[j].Employ Then
     Dispose(Stat^.Point[c].NameList[j].ClientList,Done);
    End
  End;
End;{For}
End;


Procedure DoneArrayList1;
Var  c : Word;
     j : Word;
Begin
   For j:=0 To MaxStatNAme1 Do
    Begin
     If Stat^.Point[c].NameList[j].Employ Then
     Dispose(Stat^.Point[c].NameList[j].ClientList,Done);
    End
End;








Function TestElementSpecial (Const ACod:ArtikulStr ;Const P : PBox; Var Pos:LongInt) : Boolean;
Var ls : Word;
    k  : Byte;
    st : TMyString;
    AgKod,ClKod,ArtKod : ArtikulStr;
Begin
Pos:=-1;
TestElementSpecial:=False;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
st:=Copy(St,1+CNAme+1,CArtikul);{код агента}
If (ACod=St) Then
   Begin
    TestElementSpecial:=True;
    Pos:=ls;
    Break;
   End;
End;
End;

Function TestElementSpecial1 (Const ACod:ArtikulStr ;Const P : PBox; Var Pos:LongInt) : Boolean;
Var ls : Word;
    k  : Byte;
    st : TMyString;
    AgKod,ClKod,ArtKod : ArtikulStr;
Begin
Pos:=-1;
TestElementSpecial1:=False;
For ls :=0 To P^.List^.Count Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
st:=Copy(St,1+CNAme+1,CArtikul);{код агента}
If (ACod=St) Then
   Begin
    TestElementSpecial1:=True;
    Pos:=ls;
    Break;
   End;
End;
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
End;


Function RekodAgent(ACod:ArtikulStr):ArtikulStr;
Var ls : Word;
    St : TMySTring;
    Find : Boolean;
Begin
RekodAgent[0]:=#0;
Find:=FAlse;
For ls :=0 To AgentReKod^.List^.Count Do
Begin
St:=AgentReKod^.GetText(ls,AgentReKod^.List^.Count);
st:=Copy(St,Pos('│',st)+1,CClientKod);{код агента}
If (ACod=St) Then
   Begin
    Find:=True;
    RekodAgent:=Copy(AgentReKod^.GetText(ls,AgentReKod^.List^.Count),1,CClientKod);
    Break;
   End;
End;{For}

If Not Find Then
 Begin
  MessageBox(^M+#3'Не могу определить индекс агента с кодом '+ACod+'!',Nil,mfError+mfCancelButton);
 End;

End;




Procedure ConcursCalcMrk(l:LongInt;Const VArList,Agent:PBox; Const SClient:MAska3;
Const SVidDocTov:MAska9);
Var
   cc,count,i : Word;
   E  : PBufSuperMarketType;
   ef : File;
   skol,Ssum,ssumz,bkol,bsum,bsumz :AllStr;
   Artikul : ArtikulStr;
   ws : String;
   k,j,r : Byte;
   Pos : LongInt;

Begin
 Assign(eF,Path^.Dat.ToMarket+DateToDAteString(DAteMask,L)+'.mrk');
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
  If TestAgentSpecial(E^.Point.Dat[cc].AgentKod,Agent) Then
  If (SClient[E^.Point.Dat[cc].OperatorSelector+1]=1) Then{фильтр группы операций}

  If Not((E^.Point.Dat[cc].OperatorSelector=1) And (E^.Point.Dat[cc].ClientKod=ClientRP)) Then
  Begin


   If Not ((E^.Point.Dat[cc].Realiz) And (E^.Point.Dat[cc].DocSelector in [0,1,2,3,4])) Then
   Begin
   If ((SVidDocTov[E^.Point.Dat[cc].DocSelector+1]=1)  And (E^.Point.Dat[cc].OperatorSelector in [0,2]))
    Or (E^.Point.Dat[cc].OperatorSelector=1)  Then
     Begin

        For j:=1 To E^.Point.Dat[cc].Amount Do
         Begin
          Pos:=0;
  If TestElementSpecial (E^.Point.Dat[cc].MarketElement[j].BazKod,VarList,Pos)Then
  {Pos возвращает номер товара в списке}
           Begin
            DelSpace(E^.Point.Dat[cc].MarketElement[j].Input.Kol);
            AddMrk(StrToInt(RekodAgent(E^.Point.Dat[cc].AgentKod)),Pos,
		  IntToStr(E^.Point.Dat[cc].OperatorSelector,COne)+E^.Point.Dat[cc].ClientKod,
		  E^.Point.Dat[cc].MarketElement[j].Input.Kol);
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
Close(ef);
End;



Procedure ConcursCalcMrk1(l:LongInt;Const VArList,Agent:PBox; Const SClient:MAska3;
Const SVidDocTov:MAska9);
Var
   cc,count,i : Word;
   E  : PBufSuperMarketType;
   ef : File;
   skol,Ssum,ssumz,bkol,bsum,bsumz :AllStr;
   Artikul : ArtikulStr;
   ws : String;
   k,j,r : Byte;
   Pos : LongInt;

Begin
 Assign(eF,Path^.Dat.ToMarket+DateToDAteString(DAteMask,L)+'.mrk');
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
  If (SClient[E^.Point.Dat[cc].OperatorSelector+1]=1) Then{фильтр группы операций}
  If Not((E^.Point.Dat[cc].OperatorSelector=1) And (E^.Point.Dat[cc].ClientKod=ClientRP)) Then
  Begin

   If Not ((E^.Point.Dat[cc].Realiz) And (E^.Point.Dat[cc].DocSelector in [0,1,2,3,4])) Then
   Begin
   If ((SVidDocTov[E^.Point.Dat[cc].DocSelector+1]=1)  And (E^.Point.Dat[cc].OperatorSelector in [0,2]))
    Or (E^.Point.Dat[cc].OperatorSelector=1)  Then
     Begin

        For j:=1 To E^.Point.Dat[cc].Amount Do
         Begin
          Pos:=0;
  If TestElementSpecial1 (E^.Point.Dat[cc].MarketElement[j].BazKod,VarList,Pos)Then
  {Pos возвращает номер товара в списке}
           Begin
            DelSpace(E^.Point.Dat[cc].MarketElement[j].Input.Kol);
            {
            AddMrk1(Pos,IntToStr(E^.Point.Dat[cc].OperatorSelector,COne)+E^.Point.Dat[cc].ClientKod,
		  E^.Point.Dat[cc].MarketElement[j].Input.Kol);
            }
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
Close(ef);
End;





Procedure ConcursCalcRet(l:LongInt;Const VArList,Agent:PBox; Const SClient:MAska3;
Const SVidDocTov:MAska9);
Var
   i : Word;
   E  : PNewVozwratType;
   ef : NewVozwratFileType;
   skol,Ssum,ssumz,bkol,bsum,bsumz :AllStr;
   Artikul : ArtikulStr;
   ws : String;
   k,j,r : Byte;
   Pos : LongInt;
   Ag : String[CClientKod];

Begin
 Assign(eF,Path^.Dat.ToReturn+DateToDAteString(DAteMask,L)+'.vzw');
 i:=IOResult;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(ef);
 i:=IOResult;
 FileMode:=OldFileMode;

 If i<>0 Then
  Begin
   Exit;
  End;

 New(E,Init);

 While Not(Eof(ef)) Do
  Begin
   ReadNewVozwrat(ef,e);
   If (SClient[E^.Dat.OperatorSelector+1]=1)And (E^.Dat.StatusDoc=0) Then{фильтр группы операций}
   If CalcAgentfromMrk(E^.Dat.BasisDoc,E^.Dat.BasisDate,Ag) Then
  Begin
  {тот ли агент}
{  If (Stat^.Point[StrToInt(Ag)].Employ) Then}
  If TestAgentSpecial(Ag,Agent) Then
Begin
        For j:=1 To E^.DAt.Amount Do
         Begin

  {если нужно анализировать наименование}
  Pos:=0;
  If TestElementSpecial (E^.Dat.VozwratElement[j].BazKod,VarList,Pos)Then
  BEgin
            DelSpace(E^.Dat.VozwratElement[j].Input.Kol);
            AddMrk(StrToInt(ReKodAgent(Ag)),Pos,
		  IntToStr(E^.Dat.OperatorSelector,COne)+E^.Dat.MakeKod,
		  '-'+E^.Dat.VozwratElement[j].Input.Kol);
  End;
         End;{For по накладной}
      {код расчета}
End;
 End;
 End;{While}
Dispose(E,Done);
Close(ef);
End;

{
Procedure FormReportSConcurs(Const Agent,NoScreenList:PBox;
StartDateTov,StopDateTov:TDAteString;VidReport:Word;Var txt,er:Text);
Begin
End;
}


Function CAlcResultKol(KodAg : Word;Pos:Word;ClKod:ArtikulStr):TDAteString;
VAr c,Res : LongInt;
    Find : Boolean;
    s,s1 : TMyString;
Begin
CAlcResultKol[0]:=#0;
Res:=0;
Find:=FAlse;
With Stat^.Point[KodAg] Do
Begin
 If NameList[Pos].Employ Then
 If NameList[Pos].ClientList^.List^.Count>0 Then
 For c:=0 To NameList[Pos].ClientList^.List^.Count-1 Do
 Begin
  s:=NameList[Pos].ClientList^.GetText(c,NameList[Pos].ClientList^.List^.Count);
  s1:=Copy(s,1+1,CArtikul);

  If s1=ClKod Then
  Begin
   Find:=True;
   Break;
  End;
 End;{For}
End;{With}

If Find Then
 Begin
  s1:=Copy(s,1+1+CArtikul+1,Ckol+1);
  Res:=StrToInt(s1);
 End;

CalcResultKol:=IntToStr(Res,CKOl+2);
End;


Procedure FormReportSConcurs(Const Agent:PBox;Const VarList:PBox;Var txt:Text);
Const Separator = ';';
Var s1 : AllStr;
    R : TRect;
    Cur : LongInt;
    s: TMyString;
    SArt : ArtikulStr;
    cl : Word;
    ClKod,AgKod : ArtikulStr;
    FullClient : PBox;
    Kol : TDAteSTring;
    c,j,k : Word;

Begin


 R.Assign(0,0,0,0);
 FullClient := New(PBox, Init(R, 1, Nil));
 FullClient^.NewList(New(PTextCollection, Init(0,1)));

{формируем полный список клиентов}
 For c:=0 To MaxStatAgent Do
 Begin
 With Stat^.Point[c] Do
 Begin
  If Employ Then
  For j:=0 To VarList^.List^.Count-1 Do
  Begin
     If NameList[j].Employ Then
     If NameList[j].ClientList^.List^.Count>0 Then
     Begin
      For k:=0 To NameList[j].ClientList^.List^.Count-1 Do
       Begin
        s:=NameList[j].ClientList^.GetText(k,NameList[j].ClientList^.List^.Count);
        s:=Copy(s,1+1,CArtikul);
        If (TestElement(s,FullCLient)) Then
         Begin
          s1:=GetClientField(FClient,Copy(s,2,CCLientKod),StrToInt(Copy(s,1,1)));
          Format(s1,CCLient);
          s:=s1+'│'+s;
          FullClient^.List^.Insert(NewStr(s));
          FullClient^.SetRange(FullClient^.List^.Count);
         End;
       End;{For}
     End;{Employ по наименованиям}
  End;{цикл по всем наименованиям}
 End;{With}
 End;


{закончили формировать полный список клиентов}
If FullClient^.List^.Count>0 Then
 Begin
  Write(txt,Separator);
  For c:=0 To FullClient^.List^.Count-1 Do
   Begin
    s:=FullClient^.GetText(c,FullClient^.List^.Count);
    While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert(' ',s,k);
    End;
    Write(txt,DosToWin(s)+Separator);
   End;{цикл по полному списку клиентов - выводим его в строчку}
 End;{если список клиентов не пустой}
 Writeln(txt);


If (Agent^.List^.Count)>=1 Then
Begin
  For cur:=0 To Agent^.List^.Count-1 Do
  Begin
   s:=Agent^.GetText(cur,Agent^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
   AgKod:=s;
   Writeln(txt);
   Writeln(txt,DosToWin('Агент - '+GetAgentField(FAgent,AgKod)+' ('+AgKod+')')+Separator);


    For j:=0 To VarList^.List^.Count-1 Do
     Begin
       s:=VArList^.GetText(j,VArList^.List^.Count);
       SArt:=Copy(s,1+CNAme+1,CArtikul);
       s:={Copy(s,1,CNAme+1+CArtikul);}GetIdField(FFFName,SArt);

         While Pos('│',s)>0 Do
          Begin
           k:=Pos('│',s);
           System.Delete(s,k,1);
           System.Insert(SeparatorChar,s,k);
          End;

       {печатаем наименование}
       Write(txt,DosToWin(s)+Separator);

         If FullClient^.List^.Count>0 Then
         For k:=0 To FullClient^.List^.Count-1 Do
          Begin
           s:=FullClient^.GetText(k,FullClient^.List^.Count);
           ClKod:=Copy(s,1+CCLient+1,CArtikul);
           {MemC(AgKod+'│'+ReKodAgent(AgKod));}
           Kol:=CAlcResultKOl(StrToInt(ReKodAgent(AgKod)),j,ClKod);
           Write(txt,Kol+Separator);
          End;

       Writeln(txt);{закончили наименование переводим строку}
     End;{цикл по наименованиям}
  End;{цикл по агентам}
End;{если список агентом не пустой цикл по агентам}




Dispose(FullClient,Done);
{печатаем дату и время расчета}
Writeln(Txt,DosToWin('"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')'));

System.Close(txt);
c:=IoResult;
End;{Procedure}





Procedure BakConcurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska7;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;StartDatetov,StOpDatetov:TDAteString);
Var R   : TRect;
    Space : AllStr;
    ItogKol,ItogSum,s1,s2,s3,s4,s5,s6,s7 : AllStr;
    Cur : LongInt;
    s,ss   : TMyString;
    wsd : TDateString;
    txt : Text;
    i : Word;
    Agent : PBox;
    LStart,LStop : LongInt;
    NoScreenList : PBox;
    ReKod : ArtikulStr;
    c : Word;
Begin

 If (VarList^.List^.Count-1) > MAxStatName Then
 Begin
  MessageBox(^M+#3'Выбрано слишком много наименований !',Nil,mfError+mfCancelButton);
  Exit;
 End;


R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));

If Not(SelectionAgent(Agent)) Then
 Begin
  Dispose(Agent,Done);
  Exit;
 End;

 If (Agent^.List^.Count-1) > MAxStatAgent Then
 Begin
  MessageBox(^M+#3'Выбрано слишком много агентов !',Nil,mfError+mfCancelButton);
  Dispose(Agent,Done);
  Exit;
 End;



R.Assign(0, 0, 0, 0);
AgentReKod := New(PBox, Init(R, 1, Nil));
AgentReKod^.NewList(New(PTextCollection, Init(0,1)));

 For c:=0 To Agent^.List^.Count-1 Do
  Begin
   ss:=Agent^.GetText(c,Agent^.List^.Count);
   s:=Copy(ss,1+1,CClientKod);

   ReKod:=IntToStr(c,CClientKod);
   RFormatZerro(Rekod,CClientKod);

   AgentReKod^.List^.Insert(NewStr(ReKod+ss));
   {
   Writeln(ReKod+ss);
   Readln;
   }
   AgentReKod^.SetRange(AgentReKod^.List^.Count);
  End;



 Assign(txt,Path^.Dat.ToTemp+'concurs.csv');
 i:=IOResult;
 Rewrite(txt);
 i:=IOResult;
 If i<>0 Then
  Begin
   Dispose(Agent,Done);
   Dispose(AgentReKod,Done);
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'concurs.csv',Nil,mfError+mfCancelButton);
   Exit;
  End;

 WordToBit7(OperationFiltr,SVidOperation);
 Convert7(SVidOperation);
 WordToBit3(OperationToV,SClient);
 Convert3(SClient);


 WordToBit9(Filtr,SVidDocTov);
 Convert9(SVidDocTov);
 WordToBit2(OplataToV,SStatusOplata);
 Convert2(SStatusOplata);
 LStart:=DateStringToDate(DateMask,StartDatetov);
 LStop :=DateStringToDate(DateMask ,StopDatetov);


 New(Stat,Init);

 For c:=0 To AgentReKod^.List^.Count-1 Do
  Begin
   s:=AgentReKod^.GetText(c,AgentReKod^.List^.Count);
   s:=Copy(s,1,CClientKod);
   NewElement(StrToInt(s),VarList);
  End;


 {формирование списка товаров участвующих в выборке}
 Writeln(txt,DosToWin('ОТЧЕТ ЗА ПЕРИОД С '+StartDatetov+' ПО '+StopDatetov));


 For cur:=Lstart To LStop Do
  Begin
   DInfoMsgShkala('Просматриваю операции за '+DateToDateString(DateMask,Cur)+' ...',LStart,LStop,Cur);

   if svidoperation[2]=1 Then
   ConcursCalcMrk(cur,VarList,Agent,SClient,SVidDocTov);

   if svidoperation[3]=1 Then
   ConcursCalcRet(cur,VarList,Agent,SClient,SVidDocTov);

  End;
 NoInfoMsg;

 DInfoMsg('Формирую отчет ...',True);
 FormReportSConcurs(Agent,VArList,txt);

 NoInfoMsg;

 DoneArrayList;
 Dispose(Stat,Done);
 Dispose(Agent,Done);
 Dispose(AgentReKod,Done);
 MessageBox(^M+#3'Расчет успешно завершен!',Nil,mfInformation+mfCancelButton);
End;


Procedure Concurs2(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska7;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;StartDatetov,StOpDatetov:TDAteString);
Var R   : TRect;
    Space : AllStr;
    ItogKol,ItogSum,s1,s2,s3,s4,s5,s6,s7 : AllStr;
    Cur : LongInt;
    s,ss   : TMyString;
    wsd : TDateString;
    txt : Text;
    i : Word;
    Agent : PBox;
    LStart,LStop : LongInt;
    NoScreenList : PBox;
    ReKod : ArtikulStr;
    c : Word;
Begin

 If (VarList^.List^.Count-1) > MAxStatName1 Then
 Begin
  MessageBox(^M+#3'Выбрано слишком много наименований !',Nil,mfError+mfCancelButton);
  Exit;
 End;


 Assign(txt,Path^.Dat.ToTemp+'concurs1.csv');
 i:=IOResult;
 Rewrite(txt);
 i:=IOResult;
 If i<>0 Then
  Begin
   Dispose(Agent,Done);
   Dispose(AgentReKod,Done);
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'concurs1.csv',Nil,mfError+mfCancelButton);
   Exit;
  End;

 WordToBit7(OperationFiltr,SVidOperation);
 Convert7(SVidOperation);
 WordToBit3(OperationToV,SClient);
 Convert3(SClient);


 WordToBit9(Filtr,SVidDocTov);
 Convert9(SVidDocTov);
 WordToBit2(OplataToV,SStatusOplata);
 Convert2(SStatusOplata);
 LStart:=DateStringToDate(DateMask,StartDatetov);
 LStop :=DateStringToDate(DateMask ,StopDatetov);


 New(Stat1,Init);

 {формирование списка товаров участвующих в выборке}
 Writeln(txt,DosToWin('ОТЧЕТ ЗА ПЕРИОД С '+StartDatetov+' ПО '+StopDatetov));


 For cur:=Lstart To LStop Do
  Begin
   DInfoMsgShkala('Просматриваю операции за '+DateToDateString(DateMask,Cur)+' ...',LStart,LStop,Cur);

   if svidoperation[2]=1 Then
   ConcursCalcMrk1(cur,VarList,Agent,SClient,SVidDocTov);
{
   if svidoperation[3]=1 Then
   ConcursCalcRet1(cur,VarList,Agent,SClient,SVidDocTov);
}
  End;
 NoInfoMsg;

 DInfoMsg('Формирую отчет ...',True);
 {FormReportSConcurs1(Agent,VArList,txt);}

 NoInfoMsg;

 DoneArrayList;
 Dispose(Stat1,Done);
 MessageBox(^M+#3'Расчет успешно завершен!',Nil,mfInformation+mfCancelButton);
End;






Function TestAgent(Cod:ArtikulStr;Const Agent:PBox):Boolean;
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
  If (St=Cod) Then
   Begin
    TestAgent:=True;
    Break;
   End;{St=Cod}
 End;
End;
End;







(*
procedure PrintTestFile;
var t:text;
    i, IOrez: word;
    st: string;
    sName, sOldName: string[CName+1+CName];
    sArt: string[CArtikul];
    sKOl: string[CKOl];
    sR: string[CRazdelKod];
    sKOd: string[CKOd];
    KOd, Code: word;
    npp: word;
    sGodnost: String[CDSertif];
    sMarka: String[CNSertif];
    sSpecMarka:  String[CSpecMArka];
    sMarkaKod: string[CArtikul];


BEGIN
   DInfoMSG('Формирую отчет...',false);
   Assign(t,Path^.Dat.ToTemp+'test.txt');
   IORez:=ioresult;
   Rewrite(t);
   IORez:=ioresult;
   if IORez<>0 then
     begin
     end;
sOldName:='';
npp:=1;
If (TovTest^.List<>Nil)And(TovTest^.List^.Count>0)  Then
for i:=0 to TovTest^.List^.Count - 1 do
begin
  st:=TovTest^.GetText(i,TovTest^.List^.COunt);
  sName:=copy(st,1,CName)+' '+copy(st,1+CName+1+CArtikul+1,CName);
  sArt:=copy(st,1+CName+1,CArtikul);
  sKol:=copy(st,1+CName+1+CArtikul+1+CName+1,CKOl);
  if sName<>sOldName then
    BEGIN
      writeln(t);
      writeln(t,'_____________________________________________________________________________________________');
      writeln(t,npp:4,'. ',sName);
      sOldName:=sName;
      inc(npp);
    END;
   write(t,'Код: ',SArt,' ');
   sr:=copy(sArt,1,2);
   sKOd:=copy(sArt,3,3);
   val(sKOd,KOd,Code);
   if StrToInt(sKol)=0 then writeln(t,' - свободен')
   else
    begin
     {СпецМарка}
     sMarkaKod:= BakGetField(FSpecMarka,sArt,0);
     sSpecMarka:=GetSpecMarkaField(FName,sMarkaKod);
     format(sSpecMarka,CSpecMArka);
     {Акциз}
     sMarkaKod:=BakGetField(FMarka,sArt,0);
     sMarka:=GetMarkaField(FNAme,sMarkaKod);
     format(sMarka,CNSertif);
     {Реализ. до:}
     sGodnost:=BakGetField(FGodnost,sArt,0);
     format(sGodnost,CDSertif);
     writeln(t,' - Дата выработки: ',BakGetField(FVirabotano,sArt,0),' Реализ. до: ',sGodnost);
     writeln(t,'            Акциз: ',sMarka,' Спец. марка: ',sSpecMarka);
    end;
end;
   writeln(t);
   Writeln(t,' Отпечатано:"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
   writeln(t,'=============================================================================================');
   IORez:=ioresult;
   Close(t);
   IORez:=ioresult;
   NoInfoMsg;
   ViewAsText(Path^.Dat.ToTemp+'test.txt','Тест свободных позиций',True);
   Report(Path^.Dat.ToTemp+'test.txt','',1,False,False);
END;

*)


End.