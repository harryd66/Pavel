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


Procedure Concurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska6;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;
StartDatetov,StOpDatetov:TDAteString;bZakupka:boolean);

{
Procedure Concurs2(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska6;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;StartDatetov,StOpDatetov:TDAteString);
}



Implementation

Uses Serv,Drivers,Glob,TpDate,Tools,Printers,DbEngine,
     NetDbEng,Objects,Prise,Dos,
	App,Views,MsgBox;


Const CMantissaZ=4;
      SeparatorChar=';';
{
Клиент АгнтТовар   КОлич  Сумма к оплате
│12345│1234│12345│1234567│123456789012345│123456789012345}




VAr OldFileMode : Word;






               {код агента}   {позиция тоара}{код клиента}    {количество с плюсом}
Procedure AddMrk(Var P,P2,P3,P4:PBox;Art:ArtikulStr;KodAg,ClKod:ArtikulStr;
                 Kol,RetKol:AllStr;SumOpl,RetSumOpl,SumZ,RetSumZ:AllStr;bZakupka:boolean);
Label 2,3,4;
Var ss,st,st2,st3 : string;
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
  Kol:=IntToStr((StrToInt(Kol)+StrToInt(BiloKol)-StrToInt(RetKol)),CDate);
  DelSpace(Kol);
  RFormat(Kol,CDate);

  BiloSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloSumOpl)+StrToReal(SumOpl)-StrToReal(RetSumOpl),CIZena,CMantissaZ,SumOpl);

if bZakupka then
begin
  BiloSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1,CIZena);
  MyStr(StrToReal(BiloSummaZ)+StrToReal(SumZ)-StrToReal(RetSumZ),CIZena,CMantissaZ,SumZ);
end;

(*  BiloReturnKol:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate);
  RetKol:=IntToStr((StrToInt(RetKol)+StrToInt(BiloReturnKol)),CDate);
  DelSpace(RetKol);
  RFormat(RetKol,CDate);

  BiloRetSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloRetSumOpl)+StrToReal(RetSumOpl),CIZena,CMantissaZ,RetSumOpl);

  BiloRetSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1+CIZena+1,
  CIZena);
  MyStr(StrToReal(BiloRetSummaZ)+StrToReal(RetSumZ),CIZena,CMantissaZ,{Bilo}RetSumZ);*)


  st[0]:=Chr(1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul);
  if bZakupka then
  St:=st+Kol+'│'+SumOpl+'│'+SumZ{+'│'+RetKol+'│'+RetSumOpl+'│'+RetSumZ}
  else
  St:=st+Kol+'│'+SumOpl;


  P^.List^.AtFree(ls);
  P^.SetRange(P^.List^.Count);


 End
Else{если позиции нет}
 Begin
  st:=GetIdField(FName,Art);
  Format(st,CName);
  DelSpace(Art);
  RFormatZerro(Art,CArtikul);
  Kol:=IntToStr((StrToInt(Kol)-StrToInt(RetKol)),CDate);
  rformat(Kol,CDate);
  MyStr(StrToReal(SumOpl)-StrToREal(RetSumOpl),CIZena,CMantissa,SumOpl);
  rformat(SumOpl,CIZena);
 if bZakupka then
 begin
  MyStr(StrToReal(SumZ)-StrToREal(RetSumZ),CIZena,CMantissaZ,SumZ);
  rformat(SumZ,CIZena);
  st:=st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl+'│'+SumZ{+'│'+
  RetKol+'│'+RetSumOpl+'│'+RetSumZ}
  end
  else st:=st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl;

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
  Kol:=IntToStr(StrToInt(Kol)+StrToInt(BiloKol)-StrToInt(RetKol),CDate);
  DelSpace(Kol);
  RFormat(Kol,CDate);

  BiloSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloSumOpl)+StrToReal(SumOpl)-StrToReal(RetSumOpl),CIZena,CMantissaZ,SumOpl);
if bZakupka then
begin
  BiloSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1,CIZena);
  MyStr(StrToReal(BiloSummaZ)+StrToReal(SumZ)-StrToReal(RetSumZ),CIZena,CMantissaZ,SumZ);
end;

(*  BiloReturnKol:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate);
  RetKol:=IntToStr(StrToInt(RetKol)+StrToInt(BiloReturnKol),CDate);
  DelSpace(RetKol);
  RFormat(RetKol,CDate);

  BiloRetSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloRetSumOpl)+StrToReal(RetSumOpl),CIZena,CMantissaZ,RetSumOpl);

  BiloRetSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1+CIZena+1,
  CIZena);
  MyStr(StrToReal(BiloRetSummaZ)+StrToReal(RetSumZ),CIZena,CMantissaZ,{Bilo}RetSumZ);*)

  st[0]:=Chr(1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul);
  if bZakupka then
  St:=st+Kol+'│'+SumOpl+'│'+SumZ{+'│'+RetKol+'│'+RetSumOpl+'│'+RetSumZ}
  else St:=st+Kol+'│'+SumOpl;


  P2^.List^.AtFree(ls);
  P2^.SetRange(P2^.List^.Count);


 End
Else{если позиции нет}
 Begin
  st:=GetIdField(FName,Art);
  Format(st,CName);
  DelSpace(Art);
  RFormatZerro(Art,CArtikul);
  Kol:=IntToStr((StrToInt(Kol)-StrToInt(RetKol)),CDate);
  rformat(Kol,CDate);
  MyStr(StrToReal(SumOpl)-StrToREal(RetSumOpl),CIZena,CMantissa,SumOpl);
  rformat(SumOpl,CIZena);
  if bZakupka then
  begin
  MyStr(StrToReal(SumZ)-StrToREal(RetSumZ),CIZena,CMantissaZ,SumZ);
  rformat(SumZ,CIZena);

  st:=st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl+'│'+SumZ{+'│'+
  RetKol+'│'+RetSumOpl+'│'+RetSumZ}
  end else st:=st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl
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
  Kol:=IntToStr(StrToInt(Kol)+StrToInt(BiloKol)-StrToInt(RetKol),CDate);
  DelSpace(Kol);
  RFormat(Kol,CDate);

  BiloSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloSumOpl)+StrToReal(SumOpl)-StrToReal(RetSumOpl),CIZena,CMantissaZ,SumOpl);

if bZakupka then
begin
  BiloSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1,CIZena);
  MyStr(StrToReal(BiloSummaZ)+StrToReal(SumZ)-StrToReal(RetSumZ),CIZena,CMantissaZ,SumZ);
end;

(*  BiloReturnKol:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate);
  RetKol:=IntToStr(StrToInt(RetKol)+StrToInt(BiloReturnKol),CDate);
  DelSpace(RetKol);
  RFormat(RetKol,CDate);

  BiloRetSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloRetSumOpl)+StrToReal(RetSumOpl),CIZena,CMantissaZ,RetSumOpl);

  BiloRetSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1+CIZena+1,
  CIZena);
  MyStr(StrToReal(BiloRetSummaZ)+StrToReal(RetSumZ),CIZena,CMantissaZ,{Bilo}RetSumZ);*)

  st[0]:=Chr(1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul);
  if bZakupka then
  St:=st+Kol+'│'+SumOpl+'│'+SumZ{+'│'+RetKol+'│'+RetSumOpl+'│'+RetSumZ}
  else St:=st+Kol+'│'+SumOpl;


  P3^.List^.AtFree(ls);
  P3^.SetRange(P3^.List^.Count);


 End
Else{если позиции нет}
 Begin
  st:=GetIdField(FName,Art);
  Format(st,CName);
  DelSpace(Art);
  RFormatZerro(Art,CArtikul);
  Kol:=IntToStr((StrToInt(Kol)-StrToInt(RetKol)),CDate);
  rformat(Kol,CDate);
  MyStr(StrToReal(SumOpl)-StrToREal(RetSumOpl),CIZena,CMantissa,SumOpl);
  rformat(SumOpl,CIZena);
if bZakupka then
begin
  MyStr(StrToReal(SumZ)-StrToREal(RetSumZ),CIZena,CMantissaZ,SumZ);
  rformat(SumZ,CIZena);

  st:=st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl+'│'+SumZ{+'│'+
  RetKol+'│'+RetSumOpl+'│'+RetSumZ}
end else st:=st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl;
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
if bZakupka then
begin
  BiloSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1,CIZena);
  MyStr(StrToReal(BiloSummaZ)+StrToReal(SumZ),CIZena,CMantissaZ,SumZ);
end;

(*(  BiloReturnKol:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1,CDate);
  RetKol:=IntToStr(StrToInt(RetKol)+StrToInt(BiloReturnKol),CDate);
  DelSpace(RetKol);
  RFormat(RetKol,CDate);

  BiloRetSumOpl:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1,CIZena);
  MyStr(StrToReal(BiloRetSumOpl)+StrToReal(RetSumOpl),CIZena,CMantissaZ,RetSumOpl);

  BiloRetSummaZ:=Copy(St,1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul+1+CDate+1+CIZena+1+CIZena+1+CDate+1+CIZena+1,
  CIZena);
  MyStr(StrToReal(BiloRetSummaZ)+StrToReal(RetSumZ),CIZena,CMantissaZ,{Bilo}RetSumZ);*)

  st[0]:=Chr(1+CNAme+1+CArtikul+1+CClientKod+1+CArtikul);
if bZakupka then
  St:=st+Kol+'│'+SumOpl+'│'+SumZ{+'│'+RetKol+'│'+RetSumOpl+'│'+RetSumZ}
else St:=st+Kol+'│'+SumOpl;


  P4^.List^.AtFree(ls);
  P4^.SetRange(P4^.List^.Count);



 End
Else{если позиции нет}
 Begin
  st:=GetIdField(FName,Art);
  Format(st,CName);
  DelSpace(Art);
  RFormatZerro(Art,CArtikul);
  Kol:=IntToStr((StrToInt(Kol)-StrToInt(RetKol)),CDate);
  rformat(Kol,CDate);
  MyStr(StrToReal(SumOpl)-StrToREal(RetSumOpl),CIZena,CMantissa,SumOpl);
  rformat(SumOpl,CIZena);
if bZakupka then
begin
  MyStr(StrToReal(SumZ)-StrToREal(RetSumZ),CIZena,CMantissaZ,SumZ);
  rformat(SumZ,CIZena);
  st:=st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl+'│'+SumZ{+'│'+
  RetKol+'│'+RetSumOpl+'│'+RetSumZ}
end else st:=st+'│'+Art+'│'+KodAg+'│'+ClKod+'│'+Kol+'│'+SumOpl;
 End;

  P4^.List^.Insert(NewStr(st));
  P4^.SetRange(P4^.List^.Count);

End;{AddMrk}





Const

 koi82win: array[0..127] of byte = (
 $20, $20, $20, $20, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $95, $20, $20,
 $20, $20, $a0, $20, $b0, $20, $b7, $20,
 $20, $20, $20, $b8, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $20, $20, $20,
 $20, $20, $20, $a8, $20, $20, $20, $20,
 $20, $20, $20, $20, $20, $20, $20, $a9,
 $fe, $e0, $e1, $f6, $e4, $e5, $f4, $e3,
 $f5, $e8, $e9, $ea, $eb, $ec, $ed, $ee,
 $ef, $ff, $f0, $f1, $f2, $f3, $e6, $e2,
 $fc, $fb, $e7, $f8, $fd, $f9, $f7, $fa,
 $de, $c0, $c1, $d6, $c4, $c5, $d4, $c3,
 $d5, $c8, $c9, $ca, $cb, $cc, $cd, $ce,
 $cf, $df, $d0, $d1, $d2, $d3, $c6, $c2,
 $dc, $db, $c7, $d8, $dd, $d9, $d7, $da
);


alt2koi8: array[0..127] of byte = (
 $e1, $e2, $f7, $e7, $e4, $e5, $f6, $fa,
 $e9, $ea, $eb, $ec, $ed, $ee, $ef, $f0,
 $f2, $f3, $f4, $f5, $e6, $e8, $e3, $fe,
 $fb, $fd, $ff, $f9, $f8, $fc, $e0, $f1,
 $c1, $c2, $d7, $c7, $c4, $c5, $d6, $da,
 $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0,
 $90, $91, $92, $81, $87, $b2, $b4, $a7,
 $a6, $b5, $a1, $a8, $ae, $ad, $ac, $83,
 $84, $89, $88, $86, $80, $8a, $af, $b0,
 $ab, $a5, $bb, $b8, $b1, $a0, $be, $b9,
 $ba, $b6, $b7, $aa, $a9, $a2, $a4, $bd,
 $bc, $85, $82, $8d, $8c, $8e, $8f, $8b,
 $d2, $d3, $d4, $d5, $c6, $c8, $c3, $de,
 $db, $dd, $df, $d9, $d8, $dc, $c0, $d1,
 $b3, $a3, $99, $98, $93, $9b, $9f, $97,
 $9c, $95, $9e, $96, $bf, $9d, $94, $9a
);


function DosToWin(s:string):string;

Const Digits=['0','1','2','3','4','5','6','7','8','9'];
var i: byte;
begin
  for i:=1 to word(s[0]) do
    begin
       If s[i]=SeparatorChar Then s[i]:=';';

       IF Ord(s[i]) > 127 then
       begin
         s[i] := Chr(alt2Koi8[Ord(s[i])-128]);
         s[i] := Chr(Koi82Win[Ord(s[i])-128]);
       end;



       If i>1 Then
        Begin
         If s[i]='.' Then
          If s[i-1] in Digits Then s[i]:=',';
        End;

    end;
  DosToWin:=s;
end;



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


Procedure ConcursCalcMrk({mmm:Maska8;}l:LongInt;Const VArList,Agent:PBox; Const SClient:MAska3;
Const SVidDocTov:MAska9;Var Result,Result2,Result3,Result4 : PBox;bZakupka:boolean);
Var
   cc,count,i : Word;
   E  : PSuperMarketType;
   ef : MarketFileType;
   skol,SumOpl,SumZ,Ssum,ssumz :AllStr;
   Artikul : ArtikulStr;
   ws : string[150];
   k,j,r : Byte;
   Pos : LongInt;

Begin
 Assign(eF,Path.ToMarket+DateToDAteString(DAteMask,L)+'.mrk');
 i:=IOResult;
 OldFileMode:=FileMode;
 Reset(ef);
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
   ReadMarket(Ef,E);

   If E^.Dat.Active Then
Begin
  {тот ли агент}
  {If (Stat^.Point[StrToInt(E^.Point.Dat[cc].AgentKod)].Employ) Then}
  If TestAgentSpecial(E^.Dat.AgentKod,Agent) Then
  If (SClient[E^.Dat.OperatorSelector+1]=1) Then{фильтр группы операций}

  If Not((E^.Dat.OperatorSelector=1) And (E^.Dat.ClientKod=ClientRP)) Then
  Begin
   If Not ((E^.Dat.Realiz) And (E^.Dat.DocSelector in [0,1,2,3,4])) Then
   Begin
   If ((SVidDocTov[E^.Dat.DocSelector+1]=1)  And (E^.Dat.OperatorSelector in [0,2]))
    Or (E^.Dat.OperatorSelector=1)  Then
     Begin

        For j:=1 To E^.Dat.Amount Do
         Begin
          Pos:=0;

{if MMM[E^.Point.Dat[cc].MarketElement[j].Input.DivisionNumber]=1 Then}
Begin



  {проверяем по списку позиций}

  if Not TestElement(E^.Dat.MarketElement[j].BazKod,VarList) Then
{
  If TestElementSpecial (
  E^.Point.Dat[cc].MarketElement[j].BazKod,
  E^.Point.Dat[cc].AgentKod,
  IntToStr(E^.Point.Dat[cc].OperatorSelector,COne)+E^.Point.Dat[cc].ClientKod,
  Result,Pos)Then}
  {Pos возвращает номер товара в списке}
           Begin



            DelSpace(E^.Dat.MarketElement[j].Input.Kol);
            DelSpace(E^.Dat.MarketElement[j].Input.Zakupka);
            DelSpace(E^.Dat.MarketElement[j].Input.Zakupka);

              {просчитываем сумму к оплате}
            If E^.Dat.OperatorSelector in [0,2] Then
            Begin
              If E^.Dat.SkidkaSelector=0 Then
               Begin
                DelSpace(E^.Dat.MarketElement[j].Input.Proz);
                MyStr((StrToReal(E^.Dat.MarketElement[j].Input.Zena)/
                (1+StrToReal(E^.Dat.MarketElement[j].Input.Proz)/100)),CZena,CMantissa,
                         E^.Dat.MarketElement[j].Input.Zena);
               End
                Else
               Begin
                {сумма скидки}
                MyStr((StrToReal(E^.Dat.MarketElement[j].Input.Zena)-
                         StrToReal(E^.Dat.MarketElement[j].Input.Skidka)),
                         CZena,CMantissa,
                                        E^.Dat.MarketElement[j].Input.Zena);
               End;
            End
              Else
                MyStr(StRToReal(E^.Dat.MarketElement[j].Input.Zena),CZena,CMantissa,
                         E^.Dat.MarketElement[j].Input.Zena);


            MyStr(StrToReal(E^.Dat.MarketElement[j].Input.Zena)*
		        StrToInt(E^.Dat.MarketElement[j].Input.Kol),CIZena,CMantissaZ,SumOpl);

{            If EnableZakupka=1 Then}
            MyStr(StrToReal(E^.Dat.MarketElement[j].Input.Zakupka)*
		        StrToInt(E^.Dat.MarketElement[j].Input.Kol),CIZena,CMantissaZ,SumZ);
{            Else SumZ:=CodeSummaZ;}

            SKol:=E^.Dat.MarketElement[j].Input.Kol;

            AddMrk(Result,Result2,Result3,Result4,E^.Dat.MarketElement[j].BazKod,
		  E^.Dat.AgentKod,
		        IntToStr(E^.Dat.OperatorSelector,COne)+E^.Dat.ClientKod,
		        SKol,'0',SumOpl,'0.00',SumZ,'0.00',bZakupka);
           End;
End;
         End;{For по накладной}
      {код расчета}
     End;
   End;
  End;
End;{Active}
Dispose(E,Done);
  End;{While}

 i:=IOResult;
Close(ef);
 i:=IOResult;


End;



Function CalcAgentfromMrk(Doc:ArtikulStr;Date:TDateString;Var Cod : ArtikulStr):Boolean;
Var find : Boolean;
    st,s : string[150];
    i : word;
    ef : MarketFileType;
    e : PSupermarketType;
Begin
CalcAgentfromMrk:=False;
Str(StrToInt(Doc):CDocNumer,Doc);
DelSpace(Doc);
DelSpace(Date);
Assign(ef,Path.ToMarket+Date+'.mrk');
i:=IOResult;
Reset(ef);
i:=IOResult;
If i<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия '+Path.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);
  Exit;
 End;

New(E,Init);
Find:=False;

 {оптимизация поиска}
  If FileSize(eF)>(StrToInt(Doc)-1) Then
   Begin
     Seek(eF,StrToInt(Doc)-1);
     ReadMarket(eF,E);
     Str(StrToInt(E^.Dat.Document):CDocNumer,E^.Dat.Document);
     DelSpace(E^.Dat.Document);
     DelSpace(E^.Dat.DAtec);
     If (E^.Dat.Document=Doc) And (E^.Dat.DAtec=Date) Then
         Begin
             Find:=True;
             Cod:=E^.Dat.AgentKod;
         End
         Else Seek(eF,0);
   End;


While Not(Eof(ef)) And Not(Find) Do
Begin
 ReadMarket(ef,E);
 Str(StrToInt(E^.Dat.Document):CDocNumer,E^.Dat.Document);
 DelSpace(E^.Dat.Document);
 DelSpace(E^.Dat.DAtec);
 If (E^.Dat.Document=Doc) And (E^.Dat.DAtec=Date) Then
  Begin
   Find:=True;
   Cod:=E^.Dat.AgentKod;
   Break;
  End;
End;
Close(Ef);
Dispose(E,done);
If Not(Find) Then
 MessageBox(^M+#3'Документ отгрузки N: '+Doc+' от '+Date+' в базе не найден!'
 ,Nil,MfError+mfCancelButton);
CalcAgentfromMrk:=Find;
End;




Procedure ConcursCalcRet(l:LongInt;Const VArList,Agent:PBox; Const SClient:MAska3;
Const SVidDocTov:MAska9;Var Result,Result2,Result3,Result4 : PBox;bZakupka:boolean);
Var
   i : Word;
   E  : PNewVozwratType;
   ef : NewVozwratFileType;
   skol,SumOpl,Koefficient,sumz :AllStr;
   Artikul : ArtikulStr;
   ws : string[150];
   k,j,r : Byte;
   Pos : LongInt;
   Ag : String[CClientKod];

Begin
 Assign(eF,Path.ToReturn+DateToDAteString(DAteMask,L)+'.vzw');
 i:=IOResult;
 OldFileMode:=FileMode;
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
{if MMM[StrToInt(E^.Dat.VozwratElement[j].Input.Division)]=1 Then}
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
{            If EnableZakupka=1 Then}
            MyStr(StrToReal(E^.Dat.VozwratElement[j].Input.Zakupka)*
		  StrToInt(E^.Dat.VozwratElement[j].Input.Kol),CIZena,CMantissaZ,SumZ);
{            Else
            SumZ:=CodeSummaZ;}


            MyStr(StrToReal(E^.Dat.VozwratElement[j].Input.Zena)*
		  StrToInt(E^.Dat.VozwratElement[j].Input.Kol),CIZena,CMantissaZ,SumOpl);


            AddMrk(Result,Result2,Result3,Result4,E^.Dat.VozwratElement[j].BazKod,
		  Ag,
		  IntToStr(E^.Dat.OperatorSelector,COne)+E^.Dat.MakeKod,
		        '0',SKol,'0.00',SumOpl,'0.00',SumZ,bZakupka);

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

Procedure Concurs(Const VarList:PBox;OperationFiltr:Word;SVidOperation:MAska6;
OperationToV:Word;SClient:MAska3;Filtr:Word;SVidDocTov:Maska9;
OplataToV:Word;SStatusOplata: Maska2;StartDatetov,
StOpDatetov:TDAteString;bZakupka:boolean);

Var R   : TRect;
    Cur : LongInt;
    s   : string;
    txt : Text;
    i : Word;
    Agent : PBox;
    LStart,LStop : LongInt;
    Result,Result2,Result3, Result4 : PBox;
    sclKod,sagKod,ReKod : AllStr;
    c : Word;
    Event : TEvent;
Begin


R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));

If Not(SelectionAgent(Agent)) Then
 Begin
  Dispose(Agent,Done);
  Exit;
 End;

 Assign(txt,Path.ToTemp+'concurs.csv');
 i:=IOResult;
 Rewrite(txt);
 i:=IOResult;
 If i<>0 Then
  Begin
   Dispose(Agent,Done);
   MessageBox(#3'Ошибка создания '+Path.ToTemp+'concurs.csv',Nil,mfError+mfCancelButton);
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

 WordToBit6(OperationFiltr,SVidOperation);{отгрузки и возвраты}
 Convert6(SVidOperation);
 WordToBit3(OperationToV,SClient); {клиент склад обмен}
 Convert3(SClient);

 WordToBit9(Filtr,SVidDocTov);{фильтр документов отгрузки}
 Convert9(SVidDocTov);
 WordToBit2(OplataToV,SStatusOplata);{оплаченные неоплаченные}
 Convert2(SStatusOplata);

 LStart:=DateStringToDate(DateMask,StartDatetov);{начало периода}
 LStop :=DateStringToDate(DateMask ,StopDatetov);{конец периода}

 {формирование списка товаров участвующих в выборке}
 Writeln(txt,DosToWin('Склад: '+GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-2005'));
 Writeln(txt,DosToWin('ОТЧЕТ ЗА ПЕРИОД С '+StartDatetov+' ПО '+StopDatetov));

 if bZakupka then
 Writeln(txt,DosToWin('Наименование товара;Код;Агент;Код;Клиент;Код;Реализовано колич.;Реализовано ЦО; Реализовано ЗЦ;'
  {'Возврат колич.;Возврат ЦО; Возврат ЗЦ'}))
 else
 Writeln(txt,DosToWin('Наименование товара;Код;Агент;Код;Клиент;Код;Реализовано колич.;Реализовано ЦО;'));
 Writeln(txt);

 DInfoMsg('Просматриваю операции ...');
 For cur:=Lstart To LStop Do
  Begin

   if svidoperation[2]=1 Then
   ConcursCalcMrk(cur,VarList,Agent,SClient,SVidDocTov,Result,Result2,Result3,Result4,bZakupka);

   if svidoperation[3]=1 Then
   ConcursCalcRet(cur,VarList,Agent,SClient,SVidDocTov,Result,Result2,Result3,Result4,bZakupka);

  End;
 NoInfoMsg;

DInfoMsg('Формирую отчет ...');

If Result^.List^.Count>0 Then
 Begin
  For c:=0 To Result^.List^.Count-1 Do
   Begin
    s:=Result^.GetText(c,Result^.List^.Count);
    While Pos('│',s)>0 Do s[Pos('│',s)]:=';';
    sclKod:=copy(s,1+CName+1+CArtikul+1+CClientKod+1,CArtikul);
    System.Insert(GetClientField(FClient
    ,copy(sclKod,2,CCLientKod),
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
 DInfoMsg('Расчет завершен. Данные импортированы в '+{Path.ToTemp+}'concurs.csv');
 NoSound;
 Application^.ClearEvent(Event);
 Application^.GetEvent(Event);
 Application^.ClearEvent(Event);
 repeat
  Application^.GetEvent(Event);
 until (Event.What <> evNothing) And (Event.Command<>cmMenu);
 NoInfoMsg;
 Application^.ClearEvent(Event);

End;



Function TestAgent(Cod:ArtikulStr;Const Agent:PBox):Boolean;
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




End.