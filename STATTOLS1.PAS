{
18044
18145
18515
}
{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Stattols;


Interface

Uses Dialogs, Utils,ServStr;


Procedure Concurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska7;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;
StartDatetov,StOpDatetov:TDAteString;Otdel:Word);

{
Procedure Concurs2(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska6;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;StartDatetov,StOpDatetov:TDAteString);
}
procedure FormSpecIdentifikazia(Const SelectNAmeList:PBox);
procedure TestTovar(Var TovSelect:PBox);
Procedure SpecialCalcMrk(l:LongInt;Const Cl,Agent:PBox;SClient:MAska3;SVidDocTov:Maska9;
Var EList,NMakeList:PBox;var er : text);
Procedure SpecialCalcRet(l:LongInt;Const Cl,Agent:PBox;SClient:MAska3;SVidDocTov:Maska9;
Var EList,NMAkeList:PBox;var er : text);





Implementation

Uses Serv,Drivers,Glob,TpDate,Tools,Printers,DbEngine,DbEngin2,
     ServStr2,NetDbEng,Objects,Slava2,Prise,Dos,
	App,Views,MsgBox,Utils5;

{
Клиент АгнтТовар   КОлич  Сумма к оплате
│12345│1234│12345│1234567│123456789012345│123456789012345}




VAr OldFileMode : Word;



               {код агента}   {позиция тоара}{код клиента}    {количество с плюсом}
Procedure AddMrk(Var P,P2,P3,P4:PBox;Art:ArtikulStr;KodAg,ClKod:ArtikulStr;
                 Kol,RetKol:AllStr;SumOpl,RetSumOpl,SumZ,RetSumZ:AllStr);
Label 2,3,4;
Var ss,st,st2,st3 : String;
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
st2:=Copy(St,1+CNAme+1+CArtikul+1,CClientKod);{код агента}
st3:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1,CArtikul);{код клиента}
st:=Copy(St,1+CNAme+1,CArtikul);{код товара}
{
If Art='18044' Then
 Begin
  MemC(st);
  MemC(Art+' '+KodAg+' '+ClKod);
 End;
}
If (Art=St) And (KodAg=St2) And (ClKod=St3) Then
   Begin
    Find:=True;
    {If Art='18044' Then Otladka:=True;}
    Break;
   End;
End;{for}



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


  If (Not (Find))  And (P^.List^.Count>=MaxCollectionSize-1) Then
   Begin
    Goto 2;
   End;



If Find Then{если позиция есть}
 Begin
  St:=P^.GetText(ls,P^.List^.Count);



  BiloKol:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1,CDate);
  Kol:=IntToStr((StrToInt(Kol)+StrToInt(BiloKol)),CDate);
  DelSpace(Kol);
  RFormat(Kol,CDate);


  BiloSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloSumOpl)+StrToReal(SumOpl),CIZena,CMantissaZ,SumOpl);
  BiloSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1,CIZena);
  MyStr(StrToReal(BiloSummaZ)+StrToReal(SumZ),CIZena,CMantissaZ,SumZ);

  BiloReturnKol:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate);
  RetKol:=IntToStr((StrToInt(RetKol)+StrToInt(BiloReturnKol)),CDate);
  DelSpace(RetKol);
  RFormat(RetKol,CDate);

  BiloRetSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloRetSumOpl)+StrToReal(RetSumOpl),CIZena,CMantissaZ,RetSumOpl);

  BiloRetSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1+CIZena+1,
  CIZena);
  MyStr(StrToReal(BiloRetSummaZ)+StrToReal(RetSumZ),CIZena,CMantissaZ,{Bilo}RetSumZ);


  st[0]:=Chr(1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul);
  St:=st+Kol+'│'+SumOpl+'│'+SumZ+'│'+{Bilo}RetKol+'│'+{Bilo}RetSumOpl+'│'+{Bilo}RetSumZ;


  P^.List^.AtFree(ls);
  P^.SetRange(P^.List^.Count);


 End
Else{если позиции нет}
 Begin
  st:=GetIdField(FName,Art);
  Format(st,CName);
  DelSpace(Art);
  RFormatZerro(Art,CArtikul);
  st:=st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl+'│'+SumZ+'│'+
  RetKol+'│'+RetSumOpl+'│'+RetSumZ;
 End;

  P^.List^.Insert(NewStr(st));
  P^.SetRange(P^.List^.Count);

Exit;

2:


Find:=False;

{проверяем есть позиция или нет}
For ls :=0 To P2^.List^.Count Do
Begin
St:=P2^.GetText(ls,P2^.List^.Count);

st2:=Copy(St,1+CNAme+1+CArtikul+1,CClientKod);{код агента}

st3:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1,CArtikul);{код клиента}

st:=Copy(St,1+CNAme+1,CArtikul);{код товара}

If (Art=St) And (KodAg=St2) And (ClKod=St3) Then
   Begin
    Find:=True;
    Break;
   End;
End;{for}

  If (Not (Find))  And (P2^.List^.Count>=MaxCollectionSize-1) Then
   Begin
    Goto 3;
   End;

If Find Then{если позиция есть}
 Begin
  St:=P2^.GetText(ls,P2^.List^.Count);
  BiloKol:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1,CDate);
  Kol:=IntToStr(StrToInt(Kol)+StrToInt(BiloKol),CDate);
  DelSpace(Kol);
  RFormat(Kol,CDate);
  BiloSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloSumOpl)+StrToReal(SumOpl),CIZena,CMantissaZ,SumOpl);
  BiloSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1,CIZena);
  MyStr(StrToReal(BiloSummaZ)+StrToReal(SumZ),CIZena,CMantissaZ,SumZ);

  BiloReturnKol:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate);
  RetKol:=IntToStr(StrToInt(RetKol)+StrToInt(BiloReturnKol),CDate);
  DelSpace(RetKol);
  RFormat(RetKol,CDate);

  BiloRetSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloRetSumOpl)+StrToReal(RetSumOpl),CIZena,CMantissaZ,RetSumOpl);

  BiloRetSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1+CIZena+1,
  CIZena);
  MyStr(StrToReal(BiloRetSummaZ)+StrToReal(RetSumZ),CIZena,CMantissaZ,{Bilo}RetSumZ);

  st[0]:=Chr(1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul);

  {St:=st+Kol+'│'+SumOpl+'│'+SumZ+'│'+BiloReturnKol+'│'+BiloRetSumOpl+'│'+BiloRetSummaZ;}
  St:=st+Kol+'│'+SumOpl+'│'+SumZ+'│'+{Bilo}RetKol+'│'+{Bilo}RetSumOpl+'│'+{Bilo}RetSumZ;


  P2^.List^.AtFree(ls);
  P2^.SetRange(P2^.List^.Count);


 End
Else{если позиции нет}
 Begin
  st:=GetIdField(FName,Art);
  Format(st,CName);
  DelSpace(Art);
  RFormatZerro(Art,CArtikul);
  st:=st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl+'│'+SumZ+'│'+
  RetKol+'│'+RetSumOpl+'│'+RetSumZ;
 End;

  P2^.List^.Insert(NewStr(st));
  P2^.SetRange(P2^.List^.Count);

Exit;

3:

Find:=False;

{проверяем есть позиция или нет}
For ls :=0 To P3^.List^.Count Do
Begin
St:=P3^.GetText(ls,P3^.List^.Count);
st2:=Copy(St,1+CNAme+1+CArtikul+1,CClientKod);{код агента}
st3:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1,CArtikul);{код клиента}
st:=Copy(St,1+CNAme+1,CArtikul);{код товара}
If (Art=St) And (KodAg=St2) And (ClKod=St3) Then
   Begin
    Find:=True;
    Break;
   End;
End;{for}

  If (Not (Find))  And (P3^.List^.Count>=MaxCollectionSize-1) Then
   Begin
    Goto 4;
   End;

If Find Then{если позиция есть}
 Begin
  St:=P3^.GetText(ls,P3^.List^.Count);
  BiloKol:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1,CDate);
  Kol:=IntToStr(StrToInt(Kol)+StrToInt(BiloKol),CDate);
  DelSpace(Kol);
  RFormat(Kol,CDate);
  BiloSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloSumOpl)+StrToReal(SumOpl),CIZena,CMantissaZ,SumOpl);
  BiloSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1,CIZena);
  MyStr(StrToReal(BiloSummaZ)+StrToReal(SumZ),CIZena,CMantissaZ,SumZ);

  BiloReturnKol:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate);
  RetKol:=IntToStr(StrToInt(RetKol)+StrToInt(BiloReturnKol),CDate);
  DelSpace(RetKol);
  RFormat(RetKol,CDate);

  BiloRetSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloRetSumOpl)+StrToReal(RetSumOpl),CIZena,CMantissaZ,RetSumOpl);

  BiloRetSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1+CIZena+1,
  CIZena);
  MyStr(StrToReal(BiloRetSummaZ)+StrToReal(RetSumZ),CIZena,CMantissaZ,{Bilo}RetSumZ);

  st[0]:=Chr(1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul);
  {St:=st+Kol+'│'+SumOpl+'│'+SumZ+'│'+BiloReturnKol+'│'+BiloRetSumOpl+'│'+BiloRetSummaZ;}
  St:=st+Kol+'│'+SumOpl+'│'+SumZ+'│'+{Bilo}RetKol+'│'+{Bilo}RetSumOpl+'│'+{Bilo}RetSumZ;


  P3^.List^.AtFree(ls);
  P3^.SetRange(P3^.List^.Count);


 End
Else{если позиции нет}
 Begin
  st:=GetIdField(FName,Art);
  Format(st,CName);
  DelSpace(Art);
  RFormatZerro(Art,CArtikul);
  st:=st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl+'│'+SumZ+'│'+
  RetKol+'│'+RetSumOpl+'│'+RetSumZ;
 End;

  P3^.List^.Insert(NewStr(st));
  P3^.SetRange(P3^.List^.Count);

Exit;


4:

Find:=False;

{проверяем есть позиция или нет}
For ls :=0 To P4^.List^.Count Do
Begin
St:=P4^.GetText(ls,P4^.List^.Count);
st2:=Copy(St,1+CNAme+1+CArtikul+1,CClientKod);{код агента}
st3:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1,CArtikul);{код клиента}
st:=Copy(St,1+CNAme+1,CArtikul);{код товара}
If (Art=St) And (KodAg=St2) And (ClKod=St3) Then
   Begin
    Find:=True;
    Break;
   End;
End;{for}

  If (Not (Find))  And (P4^.List^.Count>=MaxCollectionSize-1) Then
   Begin
    MessageBox(^M+#3+'Переполнение коллекции!',Nil,mfError+mfCancelButton);
    Exit;
   End;

If Find Then{если позиция есть}
 Begin
  St:=P4^.GetText(ls,P4^.List^.Count);
  BiloKol:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1,CDate);
  Kol:=IntToStr(StrToInt(Kol)+StrToInt(BiloKol),CDate);
  DelSpace(Kol);
  RFormat(Kol,CDate);
  BiloSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloSumOpl)+StrToReal(SumOpl),CIZena,CMantissaZ,SumOpl);
  BiloSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1,CIZena);
  MyStr(StrToReal(BiloSummaZ)+StrToReal(SumZ),CIZena,CMantissaZ,SumZ);

  BiloReturnKol:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate);
  RetKol:=IntToStr(StrToInt(RetKol)+StrToInt(BiloReturnKol),CDate);
  DelSpace(RetKol);
  RFormat(RetKol,CDate);

  BiloRetSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloRetSumOpl)+StrToReal(RetSumOpl),CIZena,CMantissaZ,RetSumOpl);

  BiloRetSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1+CIZena+1,
  CIZena);
  MyStr(StrToReal(BiloRetSummaZ)+StrToReal(RetSumZ),CIZena,CMantissaZ,{Bilo}RetSumZ);

  st[0]:=Chr(1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul);
  {St:=st+Kol+'│'+SumOpl+'│'+SumZ+'│'+BiloReturnKol+'│'+BiloRetSumOpl+'│'+BiloRetSummaZ;}
  St:=st+Kol+'│'+SumOpl+'│'+SumZ+'│'+{Bilo}RetKol+'│'+{Bilo}RetSumOpl+'│'+{Bilo}RetSumZ;


  P4^.List^.AtFree(ls);
  P4^.SetRange(P4^.List^.Count);



 End
Else{если позиции нет}
 Begin
  st:=GetIdField(FName,Art);
  Format(st,CName);
  DelSpace(Art);
  RFormatZerro(Art,CArtikul);
  st:=st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl+'│'+SumZ+'│'+
  RetKol+'│'+RetSumOpl+'│'+RetSumZ;
 End;

  P4^.List^.Insert(NewStr(st));
  P4^.SetRange(P4^.List^.Count);

End;{AddMrk}








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


(*
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
*)


Procedure ConcursCalcMrk(mmm:Maska8;l:LongInt;Const VArList,Agent:PBox; Const SClient:MAska3;
Const SVidDocTov:MAska9;Var Result,Result2,Result3,Result4 : PBox);
Var
   cc,count,i : Word;
   E  : PBufSuperMarketType;
   ef : File;
   skol,SumOpl,SumZ,Ssum,ssumz :AllStr;
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

if MMM[E^.Point.Dat[cc].MarketElement[j].Input.DivisionNumber]=1 Then
Begin



  {проверяем по списку позиций}

  if Not TestElement(E^.Point.Dat[cc].MarketElement[j].BazKod,VarList) Then
{
  If TestElementSpecial (
  E^.Point.Dat[cc].MarketElement[j].BazKod,
  E^.Point.Dat[cc].AgentKod,
  IntToStr(E^.Point.Dat[cc].OperatorSelector,COne)+E^.Point.Dat[cc].ClientKod,
  Result,Pos)Then}
  {Pos возвращает номер товара в списке}
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

            AddMrk(Result,Result2,Result3,Result4,E^.Point.Dat[cc].MarketElement[j].BazKod,
		  E^.Point.Dat[cc].AgentKod,
		        IntToStr(E^.Point.Dat[cc].OperatorSelector,COne)+E^.Point.Dat[cc].ClientKod,
		        SKol,'0',SumOpl,'0.00',SumZ,'0.00');
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





Procedure ConcursCalcRet(mmm:Maska8;l:LongInt;Const VArList,Agent:PBox; Const SClient:MAska3;
Const SVidDocTov:MAska9;Var Result,Result2,Result3,Result4 : PBox);
Var
   i : Word;
   E  : PNewVozwratType;
   ef : NewVozwratFileType;
   skol,SumOpl,Koefficient,sumz :AllStr;
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
{  If TestElementSpecial (E^.Dat.VozwratElement[j].BazKod,VarList,Pos)Then}
  {проверяем по списку позиций}
if MMM[StrToInt(E^.Dat.VozwratElement[j].Input.Division)]=1 Then
Begin
  if Not TestElement(E^.Dat.VozwratElement[j].BazKod,VarList) Then
  BEgin

    MyStr((1+StrToReal(E^.Dat.VozwratElement[j].Input.SpecNalog)/100),CLitr,CMantissa,
    Koefficient);
    DelSpace(Koefficient);

If E^.Dat.DocSelector in [{1,2,3,5,6}100] Then
   Begin

Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(E^.Dat.VozwratElement[j].Input.Zena)/
           (1+StrToReal(E^.Dat.VozwratElement[j].Input.LocalProz)/100),CZena,CMantissa,E^.Dat.VozwratElement[j].Input.Zena);
        MyStr(StrToREal(E^.Dat.VozwratElement[j].Input.Zena){/*StrToReal(Koefficient)},CZena,CMantissa,
                         E^.Dat.VozwratElement[j].Input.Zena);
       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(E^.Dat.VozwratElement[j].Input.Zena)-
                    StrToReal(E^.Dat.VozwratElement[j].Input.LocalSkidka),CZena,CMantissa,
                    E^.Dat.VozwratElement[j].Input.Zena);
          MyStr(StrToREal(E^.Dat.VozwratElement[j].Input.Zena){/*StrToReal(Koefficient)},CZena,CMantissa,
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


            DelSpace(E^.Dat.VozwratElement[j].Input.Kol);
            SKol:=E^.Dat.VozwratElement[j].Input.Kol;
            If EnableZakupka=1 Then
            MyStr(StrToReal(E^.Dat.VozwratElement[j].Input.Zakupka)*
		  StrToInt(E^.Dat.VozwratElement[j].Input.Kol),CIZena,CMantissaZ,SumZ)
            Else
            SumZ:=CodeSummaZ;


            MyStr(StrToReal(E^.Dat.VozwratElement[j].Input.Zena)*
		  StrToInt(E^.Dat.VozwratElement[j].Input.Kol),CIZena,CMantissaZ,SumOpl);


            AddMrk(Result,Result2,Result3,Result4,E^.Dat.VozwratElement[j].BazKod,
		  Ag,
		  IntToStr(E^.Dat.OperatorSelector,COne)+E^.Dat.MakeKod,
		        '0',SKol,'0.00',SumOpl,'0.00',SumZ);

            {AddMrk(StrToInt(ReKodAgent(Ag)),Pos,
		  IntToStr(E^.Dat.OperatorSelector,COne)+E^.Dat.MakeKod,
		  '-'+E^.Dat.VozwratElement[j].Input.Kol);}
  End;
         End;{For по накладной}
      {код расчета}
End;
End;
 End;
 End;{While}
Dispose(E,Done);

 i:=IOResult;
 Close(ef);
 i:=IOResult;
End;

{
Procedure FormReportSConcurs(Const Agent,NoScreenList:PBox;
StartDateTov,StopDateTov:TDAteString;VidReport:Word;Var txt,er:Text);
Begin
End;
}


(*
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
*)

Procedure Concurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska7;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;StartDatetov,
StOpDatetov:TDAteString;Otdel:Word);

Var R   : TRect;
    Cur : LongInt;
    s   : String;
    txt : Text;
    i : Word;
    Agent : PBox;
    LStart,LStop : LongInt;
    Result,Result2,Result3, Result4 : PBox;
    sclKod,sagKod,ReKod : AllStr;
    c : Word;
    Event : TEvent;
    MMM : Maska8;
Begin

WordToBit8(Otdel,MMM);
Convert8(MMM);


R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));

If Not(SelectionAgent(Agent)) Then
 Begin
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

R.Assign(0, 0, 0, 0);
Result := New(PBox, Init(R, 1, Nil));
Result^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0, 0, 0, 0);
Result2 := New(PBox, Init(R, 1, Nil));
Result2^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0, 0, 0, 0);
Result3 := New(PBox, Init(R, 1, Nil));
Result3^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0, 0, 0, 0);
Result4 := New(PBox, Init(R, 1, Nil));
Result4^.NewList(New(PTextCollection, Init(0,1)));

 WordToBit7(OperationFiltr,SVidOperation);{отгрузки и возвраты}
 Convert7(SVidOperation);
 WordToBit3(OperationToV,SClient); {клиент склад обмен}
 Convert3(SClient);

 WordToBit9(Filtr,SVidDocTov);{фильтр документов отгрузки}
 Convert9(SVidDocTov);
 WordToBit2(OplataToV,SStatusOplata);{оплаченные неоплаченные}
 Convert2(SStatusOplata);

 LStart:=DateStringToDate(DateMask,StartDatetov);{начало периода}
 LStop :=DateStringToDate(DateMask ,StopDatetov);{конец периода}

 {формирование списка товаров участвующих в выборке}
 Writeln(txt,DosToWin('Склад: '+GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-2005'));
 Writeln(txt,DosToWin('ОТЧЕТ ЗА ПЕРИОД С '+StartDatetov+' ПО '+StopDatetov));


 Writeln(txt,DosToWin('Наименование товара;Код;Агент;Код;Клиент;Код;Релаизовано колич.;Реализовано ЦО; Реализовано ЗЦ;'+
 'Возврат колич.;Возврат ЦО; Возврат ЗЦ'));
 Writeln(txt);

 For cur:=Lstart To LStop Do
  Begin
   DInfoMsgShkala('Просматриваю операции за '+DateToDateString(DateMask,Cur)+' ...',LStart,LStop,Cur);

   if svidoperation[2]=1 Then
   ConcursCalcMrk(mmm,cur,VarList,Agent,SClient,SVidDocTov,Result,Result2,Result3,Result4);

   if svidoperation[3]=1 Then
   ConcursCalcRet(mmm,cur,VarList,Agent,SClient,SVidDocTov,Result,Result2,Result3,Result4);

  End;
 NoInfoMsg;

DInfoMsg('Формирую отчет ...',False);

If Result^.List^.Count>0 Then
 Begin
  For c:=0 To Result^.List^.Count-1 Do
   Begin
    s:=Result^.GetText(c,Result^.List^.Count);
    While Pos('│',s)>0 Do s[Pos('│',s)]:=';';
    sclKod:=copy(s,1+CName+1+CArtikul+1+CClientKod+1,CArtikul);
    System.Insert(GetClientField(FAgent,copy(sclKod,2,CCLientKod),
    StrToInt(copy(sclKod,1,COne)))+';',s,1+CName+1+CArtikul+1+CClientKod+1);
    sclKod:=copy(s,1+CName+1+CArtikul+1,CClientKod);
    System.Insert(GetAgentField(FAgent,sclKod)+';',s,1+CName+1+CArtikul+1);
    WriteLn(txt,DosToWin(s));
   End;{цикл по полному списку клиентов - выводим его в строчку}
 End;{если список клиентов не пустой}

If Result2^.List^.Count>0 Then
 Begin
  For c:=0 To Result2^.List^.Count-1 Do
   Begin
    s:=Result2^.GetText(c,Result2^.List^.Count);
    While Pos('│',s)>0 Do s[Pos('│',s)]:=';';
    sclKod:=copy(s,1+CName+1+CArtikul+1+CClientKod+1,CArtikul);
    System.Insert(GetClientField(FAgent,copy(sclKod,2,CCLientKod),
    StrToInt(copy(sclKod,1,COne)))+';',s,1+CName+1+CArtikul+1+CClientKod+1);
    sclKod:=copy(s,1+CName+1+CArtikul+1,CClientKod);
    System.Insert(GetAgentField(FAgent,sclKod)+';',s,1+CName+1+CArtikul+1);
    WriteLn(txt,DosToWin(s));
   End;{цикл по полному списку клиентов - выводим его в строчку}
 End;{если список клиентов не пустой}

If Result3^.List^.Count>0 Then
 Begin
  For c:=0 To Result3^.List^.Count-1 Do
   Begin
    s:=Result3^.GetText(c,Result3^.List^.Count);
    While Pos('│',s)>0 Do s[Pos('│',s)]:=';';
    sclKod:=copy(s,1+CName+1+CArtikul+1+CClientKod+1,CArtikul);
    System.Insert(GetClientField(FAgent,copy(sclKod,2,CCLientKod),
    StrToInt(copy(sclKod,1,COne)))+';',s,1+CName+1+CArtikul+1+CClientKod+1);
    sclKod:=copy(s,1+CName+1+CArtikul+1,CClientKod);
    System.Insert(GetAgentField(FAgent,sclKod)+';',s,1+CName+1+CArtikul+1);
    WriteLn(txt,DosToWin(s));
   End;{цикл по полному списку клиентов - выводим его в строчку}
 End;{если список клиентов не пустой}

If Result4^.List^.Count>0 Then
 Begin
  For c:=0 To Result4^.List^.Count-1 Do
   Begin
    s:=Result4^.GetText(c,Result4^.List^.Count);
    While Pos('│',s)>0 Do s[Pos('│',s)]:=';';
    sclKod:=copy(s,1+CName+1+CArtikul+1+CClientKod+1,CArtikul);
    System.Insert(GetClientField(FAgent,copy(sclKod,2,CCLientKod),
    StrToInt(copy(sclKod,1,COne)))+';',s,1+CName+1+CArtikul+1+CClientKod+1);
    sclKod:=copy(s,1+CName+1+CArtikul+1,CClientKod);
    System.Insert(GetAgentField(FAgent,sclKod)+';',s,1+CName+1+CArtikul+1);
    WriteLn(txt,DosToWin(s));
   End;{цикл по полному списку клиентов - выводим его в строчку}
 End;{если список клиентов не пустой}

Writeln(txt);
Writeln(Txt,DosToWin('"'+DayString[DayOfWeek(ToDay)]+'" '+DateToDateString(DateMask,ToDay)+'('+Times+')'));

c:=IOResult;
Close(txt);
c:=IOResult;

NoInfoMsg;

 Dispose(Result,Done);
 Dispose(Result2,Done);
 Dispose(Result3,Done);
 Dispose(Result4,Done);

 Dispose(Agent,Done);

 Sound(100);
 DInfoMsg('Расчет завершен. Данные импортированы в '+Path^.Dat.ToTemp+'concurs.csv',False);
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
 Exec(GetEnvMy,' /C Start /D'+Path^.Dat.ToExcel+' '+Path^.Dat.ToTemp+'concurs.csv');


End;


(*
Procedure Concurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska7;
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

 If (Agent^.List^.Count-1) > MaxStatAgent Then
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
 { Writeln(ReKod+ss);
   Readln; }
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

*)


procedure FormSpecIdentifikazia(Const SelectNAmeList:PBox);
Var Txt : Text;
    c : Word;
    Skl : PSkladType;
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
GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+headerStop);
If (SelectNameList^.List<>Nil)And(SelectNAmeList^.List^.Count>0)  Then
 Begin
  For c:=0 To SelectNAmeList^.List^.Count-1 Do
   Begin
    s:=Copy(SelectNAmeList^.GetText(c,SelectNAmeList^.List^.Count),1+CName+1,CArtikul);
    New(Skl,Init);
    New(B,Init);
    Skl^.Dat.BazKod:=s;
    GetSkladRecord(Skl);
    B^.Dat.BazKod:=s;
    GetBazElement(s,B^.DAt);
    Writeln(txt,Space,(c+1):2,' '+B^.DAt.BazKod+' '+B^.Dat.NAme+' '+B^.Dat.NAme2);
    Writeln(txt,Space,'         ','Производство:'+GetPostField(FPost,B^.DAt.Postkod));
    Writeln(txt,Space,'         ','  Выработано:'+Skl^.DAt.Input.Virabotano+
    '         Реализовать до: '+Skl^.Dat.Input.Godnost);
    Writeln(txt,Space,'                ',Seria_Akzis^+':'+GetMarkaField(FMarka,Skl^.DAt.Input.Marka));
    Writeln(txt,Space,'         ','         ГТД:'+GetNGTDField(FNGTD,Skl^.DAt.Input.NGTD));
    Writeln(txt,Space,'         ','  Спец.марка:'+GetSpecMarkaField(FSpecMarka,Skl^.DAt.Input.SpecMarka));
    Writeln(txt,Space,'         ','   Штрих-код:'+Skl^.DAt.Input.StrihKod);
    New(BS,Init);
    BS^.DAt.BAzKod:=Skl^.Dat.Input.NSertif;
    GetBazElement(Skl^.Dat.Input.NSertif,Bs^.DAt);
    Writeln(txt,Space,'         ','  Сертификат:'+Bs^.Dat.NAme+' '+Bs^.Dat.Name2+'['+Skl^.Dat.Input.NSertif+']');
    Writeln(txt,Space,'         ','─────────────────────────────────────────────────────────────────');
    Dispose(Bs,Done);
    Dispose(Skl,Done);
    Dispose(B,Done);
   End;{For}
 End;{Count>0}

Writeln(txt,GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]);
Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt,Space+'==============================================================================');

c:=IOResult;
System.Close(txt);
c:=IOResult;
NoInfoMsg;
 ViewAsText(Path^.Dat.ToTemp+'identif.txt','Отчет для идентификации',True);
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
  If TestAgent(E^.Point.Dat[cc].ClientKod,Cl) Then
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
   If TestAgent(E^.Dat.MakeKod,Cl) Then
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




procedure TestTovar(Var TovSelect:PBox);
Label 1;
var db: PSkladType;
    fdb: SkladFileType;
    nskl: word;
    r: string[CRazdelKod];
    sKod: string[CKod];
    Kod, Code: word;
    sr,sArt: string[CAll];
    sOldName,st: TMystring;
    sKOl:string[CAll];
    sName : TMyString;
    npp,IORez,i: word;
    t : Text;
    TovTest : PBox;
    RR : TRect;
    sGodnost: String[CDSertif];
    sMarka: String[CNSertif];
    sSpecMarka:  String[CSpecMArka];
    sMarkaKod: string[CArtikul];
    sGTD : String[CNGTD];
    MMM : Maska30;
    AllEnable : LongInt;
BEGIN

     AllEnable:=AllSKlads;
     If Not SelAssortiment(AllEnable) Then
      Begin
       Exit;
      End;

WordToBit30(AllEnable,MMM);
Convert30(MMM);


If (TovSelect^.List<>Nil)And(TovSelect^.List^.Count>0)  Then
begin
       RR.Assign(0, 0, 0, 0);
       TovTest := New(PBox, Init(RR, 1, Nil));
       TovTest^.NewList(New(PMyCollection, Init(1,1)));

 for i:=0 to TovSelect^.List^.Count-1 do
 begin
  DInfoMsgShkala('Тестирую позиции товаров ...',0,TovSelect^.List^.Count-1,i);
  st:=TovSelect^.GetText(i,TovSelect^.List^.COunt);
  St[0]:=Chr(1+CNAME+1+CArtikul+1);
  sArt:=copy(st,1+CNAME+1,CArtikul);
  RFormatZerro(sArt,CArtikul);
  r:=copy(sArt,1,CRazdelKod);
  sKOd:=copy(sArt,3,CKod);
  Kod:=StrToInt(sKod);
  sKol:='0';

  for nskl:=1 to CMaxSklads do
   begin
     DelSpace(PathSklads^.Dat.Path[nskl]);
     if MMM[Nskl]=1 then
     begin
       Assign(fdb,PathSklads^.Dat.Path[nSkl]+'MAIN\'+r+'.db');
       IORez:=ioresult;
       reset(fdb);
       IORez:=ioresult;
       if IORez<>0 then
         begin
           {
           MessageBox(#3+'Ошибка открытия '+
		 PathSklads^.Dat.Path[nSkl]+'MAIN\'+r+'.db для объекта N '+IntToStr(Nskl,CMantissa)+
		 ' Код:'+IntToStr(IORez,CKol),Nil,mfError+mfCancelButton);
           }
           Continue;
         end;

       New(db,Init);
       IORez:=ioresult;
       seek(fdb,KOd);
       IORez:=ioresult;
       read(fdb,db^.Dat);
       IORez:=ioresult;
       str(StrToInt(sKOl)+StrToInt(db^.Dat.Input.kol):CKOl+2,sKOl);
       system.close(fdb);
       IORez:=ioresult;
       Dispose(db,Done);
     end; {PathSklads^.Dat.Path[nskl]<>''}
   end; {for nskl:=1 to Max30 do}

  system.Delete(st,1+CName+1+CArtikul+1,CKol+2);
  st:=st+sKOl;
  TovTest^.List^.Insert(NewStr(st));
 end; {for i:=0 to TovSelect^.List^.Count-1 do}
 NoInfoMsg;

   DInfoMSG('Формирую отчет...',false);
   Assign(t,Path^.Dat.ToTemp+'findpos.txt');
   IORez:=ioresult;
   Rewrite(t);
   IORez:=ioresult;
   if IORez<>0 then
     begin
      MessageBox(^M+#3+'Ошибка создания '+Path^.Dat.ToTemp+'findpos.txt '+'Код:'+
	 IntToStr(IORez,CKol),Nil,mfError+mfCancelButton);
      Goto 1;
     end;
  Writeln(T,Header+'Оператор: '+CurrentPassword+' EYE & 1997-00'+HeaderStop);
  Writeln(t);
  {
  Writeln(t,'Выбраны следующие склады:');
  for nSkl:=1 to CMaxSklads do
  if MMM[nSkl]=1 then
  writeln(t,GetClientField(FClient,IntToStr(nSkl,CClientKod),1));
  Writeln(t);
  }

  Writeln(t,'          ТЕСТ СВОБОДНЫХ ПОЗИЦИЙ');

sOldName:='';
npp:=1;
If (TovTest^.List<>Nil)And(TovTest^.List^.Count>0)  Then
for i:=0 to TovTest^.List^.Count - 1 do
begin
  st:=TovTest^.GetText(i,TovTest^.List^.COunt);
  sName:=copy(st,1,CName)+' '+GetIDField(FName2,copy(st,1+CName+1,CArtikul));
  sArt:=copy(st,1+CName+1,CArtikul);
  sKol:=copy(st,1+CName+1+CArtikul+1,CKOl+2);
  if sName<>sOldName then
    BEGIN
      writeln(t);
      writeln(t,'─────────────────────────────────────────────────────────────────────────────────────────────');
      writeln(t,npp:4,'. ',sName);
      sOldName:=sName;
      inc(npp);
    END;
   write(t,'Код: ',SArt,' ');
   sr:=copy(sArt,1,2);
   sKOd:=copy(sArt,3,3);
   if StrToInt(sKol)=0 then writeln(t,' - СВОБОДЕН')
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
     writeln(t,' - Дата выработки:'+SeparatorChar,BakGetField(FVirabotano,sArt,0),SeparatorChar+' Реализ. до: ',sGodnost);
     writeln(t,'            Акциз:'+SeparatorChar,sMarka,SeparatorChar+' Спец. марка: ',sSpecMarka);
     {
     writeln(t,'              ГТД:'+SeparatorChar,GetNGTDField(FNGTD,BakGetField(FNGTD,SArt,0)));
     writeln(t,'     Сертификатaт:'+SeparatorChar,GetIdField(FName,BakGetField(FNSertif,SArt,0))+
	' ['+BakGetField(FNSertif,SArt,0)+']');}
    end;
end;
   writeln(t);
   Writeln(t,' Отпечатано:"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
   writeln(t,'=============================================================================================');
   IORez:=ioresult;
   Close(t);
   IORez:=ioresult;
   NoInfoMsg;
   ViewAsText(Path^.Dat.ToTemp+'findpos.txt','Тест свободных позиций ('+Times+')',True);
1:

   Dispose(TovTest, Done);
end;




END;
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