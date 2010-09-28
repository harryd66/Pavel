Unit SStr;


Interface


Uses Glob,ServStr,Strings;


Function FormatP(Var St1 : PChar; Max : Byte):PChar;
Function DelSpaceP (Var S1 : PChar):PChar;
Function StrToRealP(S1:PChar) : Real;
Procedure MyStrP(S:Extended;A,B:Byte;Var As : PChar);
Function IntToStrP(K:LongInt;Form:Integer) : PChar;
Function RealToStrP(K:Double;Form1,Form2:Integer) : PChar;
Function CopyP(St1 : PChar; StartPos,Max : Word):String;
Function InsertP(Var St1 : PChar; S:String;Start,Pos : Word):PChar;

Implementation


Function FormatP(Var St1 : PChar; Max : Byte):PChar;
Var x,i : Byte;
    St  : AllStr;
Begin
 St:=StrPas(St1);
 x := Ord(St[0]);
 If (X) > (Max) Then
 Begin
  St[0]:= Chr(Max-1);
  St[max] := '.';
  St[0] :=Chr(Max);
 End;
 If (X) < (Max) Then
        Begin
         St:=AddSpace(St,Max)
        End;
 StrPCopy(St1,St);
FormatP:=St1;
End;



Function DelSpaceP (Var S1 : PChar):PChar;
 Var i,j : Integer;
     s : String;
Begin
 S:=StrPas(S1);
 DelAsmSpace(S);
 StrPCopy(S1,S);
 DelSpaceP:=s1;
End;



Function StrToRealP(S1:PChar) : Real;
Var Code : Integer;
    K : Real;
    s : String;
Begin
 k:=0;
 S:=StrPas(S1);
 DelSpace(S);
 Val(S,K,Code);
 If Code = 0 Then
 StrToRealP:=k
 Else StrToRealP:=0;
End;



Procedure MyStrP(S:Extended;A,B:Byte;Var As : PChar);
Var R : Extended;
    Res : LongInt;
    Res1 : Extended;
    s1 : String;
    m : Extended;
Begin
 If s>=0 Then
 Begin
 Case b Of
 0 :r:=10;
 1 :r:=10;
 2 :r:=100;
 3 :r:=1000;
 4 :r:=10000;
 5 :r:=100000;
 6 :R:=1000000;
 7 :R:=10000000;
 8 :R:=100000000;
 9 :R:=1000000000;
 {
 10:R:=10000000000;
 11:R:=100000000000;
 12:R:=1000000000000;
 13:R:=10000000000000;
 14:R:=100000000000000;
 15:R:=1000000000000000;}
 Else
   R:=1e19;
 End;
 End
 Else Begin

 Case b Of
 0 :r:=-10;
 1 :r:=-10;
 2 :r:=-100;
 3 :r:=-1000;
 4 :r:=-10000;
 5 :r:=-100000;
 6 :R:=-1000000;
 7 :R:=-10000000;
 8 :R:=-100000000;
 9 :R:=-1000000000;
{
 10:R:=-10000000000;
 11:R:=-100000000000;
 12:R:=-1000000000000;
 13:R:=-10000000000000;
 14:R:=-100000000000000;
 15:R:=-1000000000000000;}
 Else
   R:=-1e19;
 End;
 End;

 S:=S*r;
 m:=Frac(s);
 If Frac(s)>=0.495 Then
                       S:=S+0.005;
 Res1:=s/R;
 Str(Res1:A:B,S1);
 If A>B Then
 s1[0]:=Chr(A)
 Else
 s1[0]:=Chr(B);

 StrPCopy(AS,S1);

 {as:=s1;}
End;


Function IntToStrP(K:LongInt;Form:Integer) : PChar;
Var s : AllStr;
    s1 : PChar;
Begin
 Str(K:Form,S);
 DelSpace(S);

 StrPCopy(S1,S);
 IntToStrP:=s1;
End;


Function RealToStrP(K:Double;Form1,Form2:Integer) : PChar;
Var s : AllStr;
    s1 : PChar;
Begin
 MyStr(K,Form1,Form2,S);
 StrPCopy(S1,S);
 RealToStrP:=s1;
End;




Function CopyP(St1 : PChar; StartPos,Max : Word):String;
Var x,i : Byte;
    St  : String;
    c : Word;
Begin
 c:=1;
 St[0]:=#0;
 For c:=StartPos To StartPos+Max Do
 Begin
  St[c]:=St1[c];
  st[0]:=Chr(c);
 End;
 CopyP:=St;
End;


Function InsertP(Var St1 : PChar; S:String;Start,Pos : Word):PChar;
Var k : Word;
    c : Word;
Begin
 Format(S,Pos);
 k:=1;
 For c:=Start To (Start+Pos) Do
  Begin
   St1[C]:=s[k];
   Inc(k);
  End;

End;






End.