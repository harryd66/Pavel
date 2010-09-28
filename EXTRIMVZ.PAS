Unit ExtrimVz;

{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}



INTERFACE

Uses Dialogs, Utils,ServStr,StatTols;

{ Вызов из TStat.Pas

после Reg:=SelectImport(35) - саму SelectImport(35) я не трогал,
при отладке вызывал вне зависимости от Reg

ExtrimConcurs(SelectNameList,OperationFiltr,SVidOperation,OperationToV,SClient,Filtr,SVidDocTov,
               OplataToV,SStatusOplata,StartDatetov,StOpDatetov,Otdel,2);

вроде чо-то считает :)
               }

Procedure ExtrimConcurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska7;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;
StartDatetov,StOpDatetov:TDAteString;Otdel:Word;KKK:Word);

IMPLEMENTATION

Uses Serv,Drivers,Glob,TpDate,Tools,Printers,DbEngine,DbEngin2,
     ServStr2,NetDbEng,Objects,Slava2,Prise,Dos,
	App,Views,MsgBox,Utils5,Utils4;



Procedure AddMrk(Var P,P2,P3,P4:PBox;Art:ArtikulStr;KodAg,ClKod:ArtikulStr;
                 Kol,RetKol:AllStr;SumOpl,RetSumOpl,SumZ,RetSumZ,Doc:AllStr;sDate:TDateString;
                 bKraft: boolean);
Label 2,3,4;
Var ss,st,st2,st3,st4 : String;
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
st2:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1,CClientKod);{код агента}
st3:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1,CArtikul);{код клиента}
{st4:=Copy(St,1+CName+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1+CIZena+1+CIZena+1,CDate);}
st4:=Copy(St,1,CDate);
st:=Copy(St,1+CDate+1+CNAme+1,CArtikul);{код товара}
rFormat(Doc,CDate);
{
If Art='18044' Then
 Begin
  MemC(st);
  MemC(Art+' '+KodAg+' '+ClKod);
 End;
}
If (Art=St) And (KodAg=St2) And (ClKod=St3) And ((sDate=st4) or not bKraft) Then
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



(*If Find Then{если позиция есть}
 Begin
  St:=P^.GetText(ls,P^.List^.Count);

  BiloKol:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1,CDate);
  Kol:=IntToStr((StrToInt(Kol)+StrToInt(BiloKol)),CDate);
  DelSpace(Kol);
  RFormat(Kol,CDate);

  BiloSumOpl:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloSumOpl)+StrToReal(SumOpl),CIZena,CMantissaZ,SumOpl);
  BiloSummaZ:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1,CIZena);
  MyStr(StrToReal(BiloSummaZ)+StrToReal(SumZ),CIZena,CMantissaZ,SumZ);

  BiloReturnKol:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate);
  RetKol:=IntToStr((StrToInt(RetKol)+StrToInt(BiloReturnKol)),CDate);
  DelSpace(RetKol);
  RFormat(RetKol,CDate);

  BiloRetSumOpl:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloRetSumOpl)+StrToReal(RetSumOpl),CIZena,CMantissaZ,RetSumOpl);

  BiloRetSummaZ:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1+CIZena+1,
  CIZena);
  MyStr(StrToReal(BiloRetSummaZ)+StrToReal(RetSumZ),CIZena,CMantissaZ,{Bilo}RetSumZ);


  st[0]:=Chr(1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul);
  St:=st+Kol+'│'+SumOpl+'│'+SumZ+'│'+{Bilo}RetKol+'│'+{Bilo}RetSumOpl+'│'+{Bilo}RetSumZ;


  P^.List^.AtFree(ls);
  P^.SetRange(P^.List^.Count);


 End
Else{если позиции нет}*)
 Begin
  st:=GetIdField(FName,Art);
  Format(st,CName);
  DelSpace(Art);
  RFormatZerro(Art,CArtikul);
  RFormat(Doc,CDate);

  st:=sDate+'│'+st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl+'│'+SumZ+'│'+
  RetKol+'│'+RetSumOpl+'│'+RetSumZ+'│'+dOC;
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

st2:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1,CClientKod);{код агента}

st3:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1,CArtikul);{код клиента}
st4:=Copy(St,1,CDate);

st:=Copy(St,1+CDate+1+CNAme+1,CArtikul);{код товара}

If (Art=St) And (KodAg=St2) And (ClKod=St3) And ((sDate=st4) or not bKraft) Then
   Begin
    Find:=True;
    Break;
   End;
End;{for}

  If (Not (Find))  And (P2^.List^.Count>=MaxCollectionSize-1) Then
   Begin
    Goto 3;
   End;

(*If Find Then{если позиция есть}
 Begin
  St:=P2^.GetText(ls,P2^.List^.Count);
  BiloKol:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1,CDate);
  Kol:=IntToStr(StrToInt(Kol)+StrToInt(BiloKol),CDate);
  DelSpace(Kol);
  RFormat(Kol,CDate);
  BiloSumOpl:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloSumOpl)+StrToReal(SumOpl),CIZena,CMantissaZ,SumOpl);
  BiloSummaZ:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1,CIZena);
  MyStr(StrToReal(BiloSummaZ)+StrToReal(SumZ),CIZena,CMantissaZ,SumZ);

  BiloReturnKol:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate);
  RetKol:=IntToStr(StrToInt(RetKol)+StrToInt(BiloReturnKol),CDate);
  DelSpace(RetKol);
  RFormat(RetKol,CDate);

  BiloRetSumOpl:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloRetSumOpl)+StrToReal(RetSumOpl),CIZena,CMantissaZ,RetSumOpl);

  BiloRetSummaZ:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1+CIZena+1,
  CIZena);
  MyStr(StrToReal(BiloRetSummaZ)+StrToReal(RetSumZ),CIZena,CMantissaZ,{Bilo}RetSumZ);

  st[0]:=Chr(1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul);

  {St:=st+Kol+'│'+SumOpl+'│'+SumZ+'│'+BiloReturnKol+'│'+BiloRetSumOpl+'│'+BiloRetSummaZ;}
  St:=st+Kol+'│'+SumOpl+'│'+SumZ+'│'+{Bilo}RetKol+'│'+{Bilo}RetSumOpl+'│'+{Bilo}RetSumZ+'│'+sDate;


  P2^.List^.AtFree(ls);
  P2^.SetRange(P2^.List^.Count);


 End
Else{если позиции нет}                 *)
 Begin
  st:=GetIdField(FName,Art);
  Format(st,CName);
  DelSpace(Art);
  RFormatZerro(Art,CArtikul);
  st:=sDate+'│'+st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl+'│'+SumZ+'│'+
  RetKol+'│'+RetSumOpl+'│'+RetSumZ+'│'+sDate+'│'+dOC;
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
st2:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1,CClientKod);{код агента}
st3:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1,CArtikul);{код клиента}
st4:=Copy(St,1,CDate);
st:=Copy(St,1+CDate+1+CNAme+1,CArtikul);{код товара}
If (Art=St) And (KodAg=St2) And (ClKod=St3) And ((sDate=st4) or not bKraft) Then
   Begin
    Find:=True;
    Break;
   End;
End;{for}

  If (Not (Find))  And (P3^.List^.Count>=MaxCollectionSize-1) Then
   Begin
    Goto 4;
   End;

(*If Find Then{если позиция есть}
 Begin
  St:=P3^.GetText(ls,P3^.List^.Count);
  BiloKol:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1,CDate);
  Kol:=IntToStr(StrToInt(Kol)+StrToInt(BiloKol),CDate);
  DelSpace(Kol);
  RFormat(Kol,CDate);
  BiloSumOpl:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloSumOpl)+StrToReal(SumOpl),CIZena,CMantissaZ,SumOpl);
  BiloSummaZ:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1,CIZena);
  MyStr(StrToReal(BiloSummaZ)+StrToReal(SumZ),CIZena,CMantissaZ,SumZ);

  BiloReturnKol:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate);
  RetKol:=IntToStr(StrToInt(RetKol)+StrToInt(BiloReturnKol),CDate);
  DelSpace(RetKol);
  RFormat(RetKol,CDate);

  BiloRetSumOpl:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloRetSumOpl)+StrToReal(RetSumOpl),CIZena,CMantissaZ,RetSumOpl);

  BiloRetSummaZ:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1+CIZena+1,
  CIZena);
  MyStr(StrToReal(BiloRetSummaZ)+StrToReal(RetSumZ),CIZena,CMantissaZ,{Bilo}RetSumZ);

  st[0]:=Chr(1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul);
  {St:=st+Kol+'│'+SumOpl+'│'+SumZ+'│'+BiloReturnKol+'│'+BiloRetSumOpl+'│'+BiloRetSummaZ;}
  St:=st+Kol+'│'+SumOpl+'│'+SumZ+'│'+{Bilo}RetKol+'│'+{Bilo}RetSumOpl+'│'+{Bilo}RetSumZ+'│'+sDate;


  P3^.List^.AtFree(ls);
  P3^.SetRange(P3^.List^.Count);


 End
Else{если позиции нет} *)
 Begin
  st:=GetIdField(FName,Art);
  Format(st,CName);
  DelSpace(Art);
  RFormatZerro(Art,CArtikul);
  st:=sDate+'│'+st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl+'│'+SumZ+'│'+
  RetKol+'│'+RetSumOpl+'│'+RetSumZ+'│'+sDate;
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
st2:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1,CClientKod);{код агента}
st3:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1,CArtikul);{код клиента}
st4:=Copy(St,1,CDate);
st:=Copy(St,1+CDate+1+CNAme+1,CArtikul);{код товара}

If (Art=St) And (KodAg=St2) And (ClKod=St3) And ((sDate=st4) or not bKraft) Then
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

(*If Find Then{если позиция есть}
 Begin
  St:=P4^.GetText(ls,P4^.List^.Count);
  BiloKol:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1,CDate);
  Kol:=IntToStr(StrToInt(Kol)+StrToInt(BiloKol),CDate);
  DelSpace(Kol);
  RFormat(Kol,CDate);
  BiloSumOpl:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloSumOpl)+StrToReal(SumOpl),CIZena,CMantissaZ,SumOpl);
  BiloSummaZ:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1,CIZena);
  MyStr(StrToReal(BiloSummaZ)+StrToReal(SumZ),CIZena,CMantissaZ,SumZ);

  BiloReturnKol:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate);
  RetKol:=IntToStr(StrToInt(RetKol)+StrToInt(BiloReturnKol),CDate);
  DelSpace(RetKol);
  RFormat(RetKol,CDate);

  BiloRetSumOpl:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloRetSumOpl)+StrToReal(RetSumOpl),CIZena,CMantissaZ,RetSumOpl);

  BiloRetSummaZ:=Copy(St,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1+CIZena+1,
  CIZena);
  MyStr(StrToReal(BiloRetSummaZ)+StrToReal(RetSumZ),CIZena,CMantissaZ,{Bilo}RetSumZ);

  st[0]:=Chr(1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul);
  {St:=st+Kol+'│'+SumOpl+'│'+SumZ+'│'+BiloReturnKol+'│'+BiloRetSumOpl+'│'+BiloRetSummaZ;}
  St:=st+Kol+'│'+SumOpl+'│'+SumZ+'│'+{Bilo}RetKol+'│'+{Bilo}RetSumOpl+'│'+{Bilo}RetSumZ+'│'+sDate;


  P4^.List^.AtFree(ls);
  P4^.SetRange(P4^.List^.Count);



 End
Else{если позиции нет}  *)
 Begin
  st:=GetIdField(FName,Art);
  Format(st,CName);
  DelSpace(Art);
  RFormatZerro(Art,CArtikul);
  RFormat(Doc,CDate);
  st:=sDate+'│'+st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl+'│'+SumZ+'│'+
  RetKol+'│'+RetSumOpl+'│'+RetSumZ+'│'+sDate+'│'+DOC;
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


Procedure ConcursCalcRet(mmm:Maska8;l:LongInt;Const VArList,Agent:PBox; Const SClient:MAska3;
Const SVidDocTov:MAska9;Var Result,Result2,Result3,Result4 : PBox; bKraft: boolean);
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
   OldFileMode : word;

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
		        '0',SKol,'0.00',SumOpl,'0.00',SumZ,E^.Dat.Document,E^.Dat.DateC,TRUE);

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




Procedure ConcursCalcMrk(mmm:Maska8;l:LongInt;Const VArList,Agent:PBox; Const SClient:MAska3;
Const SVidDocTov:MAska9;Var Result,Result2,Result3,Result4 : PBox;bKraft:boolean);
Var
   cc,count,i : Word;
   E  : PBufSuperMarketType;
   ef : File;
   skol,SumOpl,SumZ,Ssum,ssumz :AllStr;
   Artikul : ArtikulStr;
   ws : String;
   k,j,r : Byte;
   Pos : LongInt;
   OldFileMode : word;
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
		        SKol,'0',SumOpl,'0.00',SumZ,'0.00',E^.Point.Dat[cc].Document,E^.Point.Dat[cc].DateC,bKraft);
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




Procedure ExtrimConcurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska7;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;
StartDatetov,StOpDatetov:TDAteString;Otdel:Word;KKK:Word);

Var R   : TRect;
    Cur : LongInt;
    s   : String;
    txt : Text;
    i : Word;
    Agent : PBox;
    LStart,LStop : LongInt;
    Result,Result2,Result3, Result4 : PBox;
    sclKod,sclKodClient,sagKod,ReKod : AllStr;
    c : Word;
    Event : TEvent;
    MMM : Maska8;
    sKOlMrk,sKolREt : String[CDate];
    Kraft: word;
    bKraft: boolean;
    sArt: string[CArtikul];
    sKol,sKolV,sDoc: string[CDate];
    sSumma,sSummaV: string[CIZena];
    sFas,sMassa: string[CZena];
Begin
WordToBit8(Otdel,MMM);
Convert8(MMM);

Kraft:=0; bKraft:=false;
Kraft:=KKK{SelectImport(16)};
if Kraft=2 then bKraft:=true;

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
 if not bKraft then Writeln(txt,DosToWin('ОТЧЕТ ЗА ПЕРИОД С '+StartDatetov+' ПО '+StopDatetov))
 else Writeln(txt,DosToWin('ОТЧЕТ ЗА ПЕРИОД С '+StartDatetov+' ПО '+StopDatetov));

 if not bKraft then
 Writeln(txt,DosToWin('Наименование товара;Код;Агент;Код;Клиент;Код;Релаизовано колич.;Реализовано ЦО; Реализовано ЗЦ;'+
 'Возврат колич.;Возврат ЦО; Возврат ЗЦ'))
else Writeln(txt,DosToWin('День;Агент;Код покупателя;Наменование;Код товара;Наименование;Реализация, шт;Сумма;'
 +'Возврат, шт;Сумма;N документа'));
 Writeln(txt);

 For cur:=Lstart To LStop Do
  Begin
   DInfoMsgShkala('Просматриваю операции за '+DateToDateString(DateMask,Cur)+' ...',LStart,LStop,Cur);

   if svidoperation[2]=1 Then
   ConcursCalcMrk(mmm,cur,VarList,Agent,SClient,SVidDocTov,Result,Result2,Result3,Result4,bKraft);

   if svidoperation[3]=1 Then
   ConcursCalcRet(mmm,cur,VarList,Agent,SClient,SVidDocTov,Result,Result2,Result3,Result4,bKraft);

  End;
 NoInfoMsg;

DInfoMsg('Формирую отчет ...',False);

If Result^.List^.Count>0 Then
 Begin
  For c:=0 To Result^.List^.Count-1 Do
   Begin
    s:=Result^.GetText(c,Result^.List^.Count);

    sDoc:= copy(s,length(s)-CDate+1,CDate);

    While Pos('│',s)>0 Do s[Pos('│',s)]:=';';
    sclKodClient:=copy(s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1,CArtikul);
    if not bKraft then System.Insert(GetClientField(FAgent,copy(sclKodClient,2,CCLientKod),
    StrToInt(copy(sclKod,1,COne)))+';',s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1);
    sclKod:=copy(s,1+CDate+1+CName+1+CArtikul+1,CClientKod);
    if not bKraft then System.Insert(GetAgentField(FAgent,sclKod)+';',s,1+CDate+1+CName+1+CArtikul+1);

    if not bKraft then
    begin
      System.Delete(s,1,CDate+1);
    end
    else
    begin
      sArt:=copy(s,1+CDate+1+CName+1,CArtikul);
      sKol:=copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1,CDate);
      sKolv:=copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate);

      MyStr(StrToReal(copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena))
        ,CIZena,CMantissa,sSumma);

      MyStr(StrToReal(copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIzena+1+cDate+1,CIZena))
      ,CIZena,CMantissa,sSummaV);

      sFas:=GetIdField(FInPack,sArt);
      if StrToInt(sFas)<>0 then
       MyStr(StrToReal(sKol)/StrToReal(sFas),CZena,CMantissa,sFas);
      sMassa:=GetIdField(FMAssa,sArt);
      MyStr(StrToReal(sKOl)*StrToReal(sMassa),CZena,CMantissa,sMassa);
      System.Delete(s,1+CDate+1,CName+1+CArtikul+1+CClientKod+1);
      s[0]:=Chr(1+CDate+1+CArtikul+1);
      System.Insert(GetAgentField(FAgent,sclKod)+';',s,1+CDate+1);
      System.Insert(GetClientField(FAgent,copy(sclKodClient,2,CCLientKod),
       StrToInt(copy(sclKod,1,COne)))+';',s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1);
      s:=s+sArt+';'+gETiDfIELD(fnAME,sArt)+';';
      s:=s+sKOl+';';
      s:=s+sSumma+';';
      s:=s+sKOlV+';';
      s:=s+sSummaV+';';
      s:=s+sDoc+';';

     { s:=s+sFas+';';
      s:=s+sMassa+';';}
    end;

    WriteLn(txt,DosToWin(s));
   End;{цикл по полному списку клиентов - выводим его в строчку}
 End;{если список клиентов не пустой}

If Result2^.List^.Count>0 Then
 Begin
  For c:=0 To Result2^.List^.Count-1 Do
   Begin
    s:=Result2^.GetText(c,Result2^.List^.Count);
    While Pos('│',s)>0 Do s[Pos('│',s)]:=';';
    sclKod:=copy(s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1,CArtikul);
    if not bKraft then System.Insert(GetClientField(FAgent,copy(sclKod,2,CCLientKod),
    StrToInt(copy(sclKod,1,COne)))+';',s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1);
    sclKod:=copy(s,1+CDate+1+CName+1+CArtikul+1,CClientKod);
    if not bKraft then System.Insert(GetAgentField(FAgent,sclKod)+';',s,1+CDate+1+CName+1+CArtikul+1);

    if not bKraft then
    begin
      System.Delete(s,1,CDate+1);
    end
    else
    begin
      sArt:=copy(s,1+CDate+1+CName+1,CArtikul);
      sKol:=IntToStr(StrToInt(copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1,CDate))
         -StrToInt(copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate)),CDate);
      MyStr(StrToReal(copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena))
      -StrToReal(copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIzena+1+cDate+1,CIZena))
      ,CIZena,CMantissa,sSumma);
      sFas:=GetIdField(FInPack,sArt);
      if StrToInt(sFas)<>0 then
       MyStr(StrToReal(sKol)/StrToReal(sFas),CZena,CMantissa,sFas);
      sMassa:=GetIdField(FMAssa,sArt);
      MyStr(StrToReal(sKOl)*StrToReal(sMassa),CZena,CMantissa,sMassa);
      System.Delete(s,1+CDate+1,CName+1+CArtikul+1+CClientKod+1);
      s[0]:=Chr(1+CDate+1+CArtikul+1);
      System.Insert(GetAgentField(FAgent,sclKod)+';',s,1+CDate+1);
      s:=s+sArt+';';
      s:=s+sSumma+';';
      s:=s+sFas+';';
      s:=s+sMassa+';';
    end;

    WriteLn(txt,DosToWin(s));
   End;{цикл по полному списку клиентов - выводим его в строчку}
 End;{если список клиентов не пустой}

If Result3^.List^.Count>0 Then
 Begin
  For c:=0 To Result3^.List^.Count-1 Do
   Begin
    s:=Result3^.GetText(c,Result3^.List^.Count);
    While Pos('│',s)>0 Do s[Pos('│',s)]:=';';
    sclKod:=copy(s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1,CArtikul);
    if not bKraft then System.Insert(GetClientField(FAgent,copy(sclKod,2,CCLientKod),
    StrToInt(copy(sclKod,1,COne)))+';',s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1);
    sclKod:=copy(s,1+CDate+1+CName+1+CArtikul+1,CClientKod);
    if not bKraft then System.Insert(GetAgentField(FAgent,sclKod)+';',s,1+CDate+1+CName+1+CArtikul+1);

    if not bKraft then
    begin
      System.Delete(s,1,CDate+1);
    end
    else
    begin
      sArt:=copy(s,1+CDate+1+CName+1,CArtikul);
      sKol:=IntToStr(StrToInt(copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1,CDate))
         -StrToInt(copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate)),CDate);
      MyStr(StrToReal(copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena))
      -StrToReal(copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIzena+1+cDate+1,CIZena))
      ,CIZena,CMantissa,sSumma);
      sFas:=GetIdField(FInPack,sArt);
      if StrToInt(sFas)<>0 then
       MyStr(StrToReal(sKol)/StrToReal(sFas),CZena,CMantissa,sFas);
      sMassa:=GetIdField(FMAssa,sArt);
      MyStr(StrToReal(sKOl)*StrToReal(sMassa),CZena,CMantissa,sMassa);
      System.Delete(s,1+CDate+1,CName+1+CArtikul+1+CClientKod+1);
      s[0]:=Chr(1+CDate+1+CArtikul+1);
      System.Insert(GetAgentField(FAgent,sclKod)+';',s,1+CDate+1);
      s:=s+sArt+';'+gETiDfIELD(fnAME,sArt)+';';
      s:=s+sSumma+';';
      s:=s+sFas+';';
      s:=s+sMassa+';';
    end;

    WriteLn(txt,DosToWin(s));
   End;{цикл по полному списку клиентов - выводим его в строчку}
 End;{если список клиентов не пустой}

If Result4^.List^.Count>0 Then
 Begin
  For c:=0 To Result4^.List^.Count-1 Do
   Begin
    s:=Result4^.GetText(c,Result4^.List^.Count);
    While Pos('│',s)>0 Do s[Pos('│',s)]:=';';
    sclKod:=copy(s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1,CArtikul);
    if not bKraft then System.Insert(GetClientField(FAgent,copy(sclKod,2,CCLientKod),
    StrToInt(copy(sclKod,1,COne)))+';',s,1+CDate+1+CName+1+CArtikul+1+CClientKod+1);
    sclKod:=copy(s,1+CDate+1+CName+1+CArtikul+1,CClientKod);
    if not bKraft then System.Insert(GetAgentField(FAgent,sclKod)+';',s,1+CDate+1+CName+1+CArtikul+1);

    if not bKraft then
    begin
      System.Delete(s,1,CDate+1);
    end
    else
    begin
      sArt:=copy(s,1+CDate+1+CName+1,CArtikul);
      sKol:=IntToStr(StrToInt(copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1,CDate))
         -StrToInt(copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate)),CDate);
      MyStr(StrToReal(copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena))
      -StrToReal(copy(s,1+CDate+1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIzena+1+cDate+1,CIZena))
      ,CIZena,CMantissa,sSumma);
      sFas:=GetIdField(FInPack,sArt);
      if StrToInt(sFas)<>0 then
       MyStr(StrToReal(sKol)/StrToReal(sFas),CZena,CMantissa,sFas);
      sMassa:=GetIdField(FMAssa,sArt);
      MyStr(StrToReal(sKOl)*StrToReal(sMassa),CZena,CMantissa,sMassa);
      System.Delete(s,1+CDate+1,CName+1+CArtikul+1+CClientKod+1);
      s[0]:=Chr(1+CDate+1+CArtikul+1);
      System.Insert(GetAgentField(FAgent,sclKod)+';',s,1+CDate+1);
      s:=s+sArt+';'+gETiDfIELD(fnAME,sArt)+';';
      s:=s+sSumma+';';
      s:=s+sFas+';';
      s:=s+sMassa+';';
    end;

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


BEGIN

END.
