{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Stattols;


Interface

Uses Dialogs, Utils,ServStr;


Procedure Concurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska6;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;StartDatetov,StOpDatetov:TDAteString);

procedure FormSpecIdentifikazia(Const SelectNAmeList:PBox);

Procedure SpecialCalcMrk(l:LongInt;Const Agent:PBox;SClient:MAska3;SVidDocTov:Maska9;
Var EList,NMakeList:PBox;var er : text);
Procedure SpecialCalcRet(l:LongInt;Const Agent:PBox;SClient:MAska3;SVidDocTov:Maska9;
Var EList,NMAkeList:PBox;var er : text);





Implementation

Uses Serv,Drivers,Glob,TpDate,Tools,Printers,DbEngine,
     NetDbEng, Objects, Slava2,Prise,MsgBox,Utils5;



Const MAxStatAgent=70;
      MAxStatNAme=82;
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


Type Special = Array [0..MaxStatAgent] Of ArrayPositionMemory;


Type PSpecial = ^SpecialPtr;
     SpecialPtr =Object(TObject)
     Point :Special;
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



VAr Stat : PSpecial;{массив агентов}
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




Procedure ConcursCalcMrk(l:LongInt;Const VArList:PBox; Const SClient:MAska3;
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


  If (Stat^.Point[StrToInt(E^.Point.Dat[cc].AgentKod)].Employ) Then
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
            AddMrk(StrToInt(E^.Point.Dat[cc].AgentKod),Pos,
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





Procedure ConcursCalcRet(l:LongInt;Const VArList:PBox; Const SClient:MAska3;
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
  If (Stat^.Point[StrToInt(Ag)].Employ) Then

Begin
        For j:=1 To E^.DAt.Amount Do
         Begin

  {если нужно анализировать наименование}
  Pos:=0;
  If TestElementSpecial (E^.Dat.VozwratElement[j].BazKod,VarList,Pos)Then
  BEgin
            DelSpace(E^.Dat.VozwratElement[j].Input.Kol);
            AddMrk(StrToInt(Ag),Pos,
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
  Write(txt,Separator+Separator);
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
       s:=Copy(s,1,CNAme+1+CArtikul);

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
           Kol:=CAlcResultKOl(StrToInt(AgKod),j,ClKod);
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





Procedure Concurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska6;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;StartDatetov,StOpDatetov:TDAteString);
Var R   : TRect;
    Space : AllStr;
    ItogKol,ItogSum,s1,s2,s3,s4,s5,s6,s7 : AllStr;
    Cur : LongInt;
    s   : TMyString;
    wsd : TDateString;
    txt : Text;
    i : Word;
    Agent : PBox;
    LStart,LStop : LongInt;
    NoScreenList : PBox;
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

 Assign(txt,Path^.Dat.ToTemp+'concurs.csv');
 i:=IOResult;
 Rewrite(txt);
 i:=IOResult;
 If i<>0 Then
  Begin
   Dispose(Agent,Done);
   MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'concurs.csv',Nil,mfError+mfCancelButton);
   Exit;
  End;

 WordToBit6(OperationFiltr,SVidOperation);
 Convert6(SVidOperation);
 WordToBit3(OperationToV,SClient);
 Convert3(SClient);


 WordToBit9(Filtr,SVidDocTov);
 Convert9(SVidDocTov);
 WordToBit2(OplataToV,SStatusOplata);
 Convert2(SStatusOplata);
 LStart:=DateStringToDate(DateMask,StartDatetov);
 LStop :=DateStringToDate(DateMask ,StopDatetov);


 New(Stat,Init);

 For c:=0 To Agent^.List^.Count-1 Do
  Begin
   s:=Agent^.GetText(c,Agent^.List^.Count);
   s:=Copy(s,1+1,CClientKod);
   NewElement(StrToInt(s),VarList);
  End;


 {формирование списка товаров участвующих в выборке}
 Writeln(txt,DosToWin('ОТЧЕТ ЗА ПЕРИОД С '+StartDatetov+' ПО '+StopDatetov));


 For cur:=Lstart To LStop Do
  Begin
   DInfoMsgShkala('Просматриваю операции за '+DateToDateString(DateMask,Cur)+' ...',LStart,LStop,Cur);

   if svidoperation[2]=1 Then
   ConcursCalcMrk(cur,VarList,SClient,SVidDocTov);

   if svidoperation[3]=1 Then
   ConcursCalcRet(cur,VarList,SClient,SVidDocTov);

  End;
 NoInfoMsg;

 DInfoMsg('Формирую отчет ...',True);
 FormReportSConcurs(Agent,VArList,txt);

 NoInfoMsg;

 DoneArrayList;
 Dispose(Stat,Done);
 Dispose(Agent,Done);
 MessageBox(^M+#3'Расчет успешно завершен!',Nil,mfInformation+mfCancelButton);
End;


procedure FormSpecIdentifikazia(Const SelectNAmeList:PBox);
Var Txt : Text;
    c : Word;
    Skl : PSkladType;
    ESkl : PExtSkladType;
    B,Bs : PBazType;
    s : String;
    Space : AllStr;
Begin
Space:=' ';
DInfoMsg('Формирую отчет...',True);
Assign(txt,Path^.Dat.ToTemp+'identif.txt');
c:=IOResult;
Rewrite(txt);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(#3'Ошибка создания '+Path^.Dat.ToTemp+'identif.txt'+
  'Код: '+IntToStr(c,2),Nil,mfError+mfCancelButton);
  Exit;
 End;
Writeln(txt,Header+Space+'Склад: '+FormKod(Rek^.Dat.Kod)++'  Оператор: '+CurrentPassword+'   '+
Condensed[Nprint^.DAt.Printer]+headerStop);
If (SelectNameList^.List<>Nil)And(SelectNAmeList^.List^.Count>0)  Then
 Begin
  For c:=0 To SelectNAmeList^.List^.Count-1 Do
   Begin
    s:=Copy(SelectNAmeList^.GetText(c,SelectNAmeList^.List^.Count),1+CName+1,CArtikul);
    New(Skl,Init);
    New(ESkl,Init);
    New(B,Init);
    Skl^.Dat.BazKod:=s;
    GetSkladRecord(Skl);
    ESkl^.Dat.BazKod:=s;
    GetExtSkladRecord(ESkl);
    B^.Dat.BazKod:=s;
    GetBazElement(s,B^.DAt);
    Writeln(txt,Space,(c+1):2,' '+B^.DAt.BazKod+' '+B^.Dat.NAme+' '+B^.Dat.NAme2);
    Writeln(txt,Space,'         ','Производство:'+ESkl^.DAt.Input.Post);
    Writeln(txt,Space,'         ','  Выработано:'+Skl^.DAt.Input.Virabotano+
    '         Реализовать до: '+ESkl^.Dat.Input.Godnost);
    Writeln(txt,Space,'                ',Seria_Akzis^+':'+ESkl^.DAt.Input.Marka);
    Writeln(txt,Space,'         ','         ГТД:'+ESkl^.DAt.Input.NGTD);
    Writeln(txt,Space,'         ','  Спец.марка:'+ESkl^.DAt.Input.SpecMarka);
    Writeln(txt,Space,'         ','   Штрих-код:'+Skl^.DAt.Input.StrihKod);
    New(BS,Init);
    BS^.DAt.BAzKod:=Skl^.Dat.Input.NSertif;
    GetBazElement(Skl^.Dat.Input.NSertif,Bs^.DAt);
    Writeln(txt,Space,'         ','  Сертификат:'+Bs^.Dat.NAme+' '+Bs^.Dat.Name2+'['+Skl^.Dat.Input.NSertif+']');
    Writeln(txt,Space,'         ','─────────────────────────────────────────────────────────────────');
    Dispose(Bs,Done);
    Dispose(Skl,Done);
    Dispose(ESkl,Done);
    Dispose(B,Done);
   End;{For}
 End;{Count>0}

Writeln(txt,Normal[Nprint^.DAt.Printer]);
Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt,Space+'==============================================================================');

c:=IOResult;
System.Close(txt);
c:=IOResult;
NoInfoMsg;
 ViewAsText(Path^.Dat.ToTemp+'identif.txt',True);
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




Procedure SpecialCalcMrk;
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
   Writeln(er,'Не найден файл продаж за '+DateToDAteString(DAteMask,L)+
   '  "'+DayString[DayOfWeek(l)]+'"'+
   +' Код:'+IntToStr(i,3));
   i:=IOResult;
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
  If TestAgent(E^.Point.Dat[cc].AgentKod,Agent) Then
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

          If Not TestElement(E^.Point.Dat[cc].MarketElement[j].BazKod,EList) Then
           BEgin
            Pos:=Location(EList,E^.Point.Dat[cc].MarketElement[j].BazKod,False);
            ws:=EList^.GetText(Pos,EList^.List^.Count);
            bKol:=Copy(ws,1+CNAme+1+CArtikul+1,CKol+1);{общее количество}
            bsum:=Copy(ws,1+CNAme+1+CArtikul+1+(CKol+1)+1,CIZena);{сумма по оплате}
           bsumz:=Copy(ws,1+CNAme+1+CArtikul+1+(CKol+1)+1+CIZena+1,CIZena);{сумма по закупке}

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

              {просчитываем сумму по закупке}

            MyStr(StrToReal(bsum)+StrToInt(E^.Point.Dat[cc].MarketElement[j].Input.Kol)*
                  STrToReal(E^.Point.Dat[cc].MarketElement[j].Input.Zena),CIZena,CMantissa,SSum);

            MyStr(StrToReal(BSumZ)+StrToInt(E^.Point.Dat[cc].MarketElement[j].Input.Kol)*
                  STrToReal(E^.Point.Dat[cc].MarketElement[j].Input.Zakupka),
                  CIZena,CMantissaZ,SSumZ);

            {MemC(BSumZ+' '+ZenaZakup+' '+SSumZ);}

            Str(StrToInt(E^.Point.Dat[cc].MarketElement[j].Input.Kol)+StrToInt(bKol):(Ckol+1),SKol);

            System.Delete(ws,1+CNAme+1+CArtikul+1,(CKOl+1)+1+CIZena+1+CIZena+1);
            System.Insert(SKol+'│'+SSum+'│'+SSumZ+'│',ws,1+CNAme+1+CArtikul+1);
            {удаляем старую строчку}
            EList^.List^.AtFree(Pos);
            {вставлем новую строчку}
            EList^.List^.Insert(NewStr(ws));
            EList^.SetRange(EList^.List^.Count);
           End;{позиция есть в списке}
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




Procedure SpecialCalcRet;
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
   Writeln(er,'Не найден файл возврата за '+DateToDAteString(DAteMask,L)+
   '  "'+DayString[DayOfWeek(l)]+'"'+
   +' Код:'+IntToStr(i,3));
   i:=IOResult;
   Exit;
  End;

 New(E,Init);

 While Not(Eof(ef)) Do
  Begin
   ReadNewVozwrat(ef,e);
   If (SClient[E^.Dat.OperatorSelector+1]=1)And (E^.Dat.StatusDoc=0) Then{фильтр группы операций}
   If CalcAgentfromMrk(E^.Dat.BasisDoc,E^.Dat.BasisDate,Ag) Then
  Begin
    If TestAgent(Ag,Agent) Then
Begin
        For j:=1 To E^.DAt.Amount Do
         Begin
          If Not TestElement(E^.Dat.VozwratElement[j].BazKod,EList) Then
           BEgin
            Pos:=Location(EList,E^.Dat.VozwratElement[j].BazKod,False);
            ws:=EList^.GetText(Pos,EList^.List^.Count);
            bKol :=Copy(ws,1+CNAme+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1,CKol+1);{общее количество}
            bsum :=Copy(ws,1+CNAme+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1+(CKol+1)+1,CIZena);{сумма по оплате}
            bsumz:=Copy(ws,1+CNAme+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1+(CKol+1)+1+CIZena+1,CIZena);{сумма по оплате}

If E^.Dat.DocSelector in [1,2,3,5,6] Then
   Begin
Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(E^.Dat.VozwratElement[j].Input.Zena)/
           (1+StrToReal(E^.Dat.VozwratElement[j].Input.LocalProz)/100),CZena,CMantissa,E^.Dat.VozwratElement[j].Input.Zena);
       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(E^.Dat.VozwratElement[j].Input.Zena)-
                    StrToReal(E^.Dat.VozwratElement[j].Input.LocalSkidka),CZena,CMantissa,
                    E^.Dat.VozwratElement[j].Input.Zena);
        End;
Else;
End;{Case}
End{If VidDocSelector}
Else
 Begin
Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(E^.Dat.VozwratElement[j].Input.Zena)/
           (1+StrToReal(E^.Dat.VozwratElement[j].Input.LocalProz)/100),CZena,CMantissa,E^.Dat.VozwratElement[j].Input.Zena);
       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(E^.Dat.VozwratElement[j].Input.Zena)-
                    StrToReal(E^.Dat.VozwratElement[j].Input.LocalSkidka),CZena,CMantissa,
                    E^.Dat.VozwratElement[j].Input.Zena);
        End;
Else;
End;{Case}
 End;

            MyStr(StrToReal(bsum)+StrToInt(E^.Dat.VozwratElement[j].Input.Kol)*
                  STrToReal(E^.Dat.VozwratElement[j].Input.Zena),CIZena,CMantissa,SSum);
            MyStr(StrToReal(bsumz)+StrToInt(E^.Dat.VozwratElement[j].Input.Kol)*
                  STrToReal(E^.Dat.VozwratElement[j].Input.Zakupka),
                  CIZena,CMantissaZ,SSumZ);

            Str(StrToInt(E^.Dat.VozwratElement[j].Input.Kol)+StrToInt(bKol):(Ckol+1),SKol);

            System.Delete(ws,1+CNAme+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1,(CKol+1)+1+CIZena+1+CIZena+1);
            System.Insert(SKol+'│'+SSum+'│'+SSumZ+'│',ws,1+CNAme+1+CArtikul+1+(CKol+1)+1+CIZena+1+CIZena+1);
            {удаляем старую строчку}
            EList^.List^.AtFree(Pos);
            {вставлем новую строчку}
            EList^.List^.Insert(NewStr(ws));
            EList^.SetRange(EList^.List^.Count);
           End;{позиция есть в списке}
         End;{For по накладной}
      {код расчета}
End;
 End;
 End;{While}
Dispose(E,Done);
Close(ef);
End;







End.