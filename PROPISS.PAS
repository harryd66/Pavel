{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Propiss;

Interface

Uses ServStr;


{****************************************************************}

Procedure Propis(Var St , s1:String);


Var Sl,ProwSt,Stroka1,Stroka2,Stroka3 : string[150];
    S1 ,S2 ,S3 : string[150];
    i,k : Integer;
    Tis,Sotni,Mil : Boolean;

Implementation



Procedure Razbiwka (Var S : String);
Var j,l : Integer;
  Begin
   S[0] := Chr(0);
     For J := 1 To 3 Do
    Begin
      S[j]:='0';
      S[0] := Chr(j);
    End;
   S[0] := Chr(j);
   i := k-1;
   j := 3;
   l:=i-2;
   If L<=0 Then l:=1;
   For k := i Downto l Do
       Begin
        S[j]:=ProwSt[k];
        Dec(j);
       End;
   For l := j Downto 1 Do
     If Not(S[l] in ['0'..'9']) Then
                                     S[l] :='0';
   S[0] := Chr(3);
  End;

{****************************************************************}


Procedure Stroki (Razrad : Byte; Var S : string; Var St : String);
Var i : Integer;
    Ok : Boolean;
  Begin
   St[0] := #0;
   For i:=1 To 3 Do
    Begin
    Case I Of
    3:Begin
     Case S[i] Of
     '0':St:=St+'';
     '1':Begin
          If Razrad = 2 Then St:=St+'одна '
           Else  St:=St+'один ';
         End;
     '2':Begin
          If Razrad = 2 Then St:=St+'две '
           Else  St:=St+'два ';
         End;
     '3':St:=St+'три ';
     '4':St:=St+'четыре ';
     '5':St:=St+'пять ';
     '6':St:=St+'шесть ';
     '7':St:=St+'семь ';
     '8':St:=St+'восемь ';
     '9':St:=St+'девять ';
    End;
     End;
    2:Begin
     Case S[i] Of
     '0':St:=St+'';
     '1':Begin
          Case S[i+1] Of
     '0':St:=St+'десять ';
     '1':St:=St+'одиннадцать ';
     '2':St:=St+'двенадцать ';
     '3':St:=St+'тринадцать ';
     '4':St:=St+'четырнадцать ';
     '5':St:=St+'пятнадцать ';
     '6':St:=St+'шестнадцать ';
     '7':St:=St+'семнадцать ';
     '8':St:=St+'восемнадцать ';
     '9':St:=St+'девятнадцать ';
           Else;
           End;
           I:=3;
         End;
     '2':St:=St+'двадцать ';
     '3':St:=St+'тридцать ';
     '4':St:=St+'сорок ';
     '5':St:=St+'пятьдесят ';
     '6':St:=St+'шестьдесят ';
     '7':St:=St+'семьдесят ';
     '8':St:=St+'восемьдесят ';
     '9':St:=St+'девяносто ';
    End;
      End;
    1:Begin
     Case S[i] Of
     '0':St:=St+'';
     '1':St:=St+'сто ';
     '2':St:=St+'двести ';
     '3':St:=St+'триста ';
     '4':St:=St+'четыреста ';
     '5':St:=St+'пятьсот ';
     '6':St:=St+'шестьсот ';
     '7':St:=St+'семьсот ';
     '8':St:=St+'восемьсот ';
     '9':St:=St+'девятьсот ';
    End;
     End;
     End;
   End;
   Ok := True;
   Case Razrad Of
    2: If St <> '' Then
                      Begin
                       If (S[3] In ['5'..'9','0']) Or
                          ((S[2]='1') And (S[3]In['0'..'9'])) Then
                           Begin
                            St := St+'тысяч ';
                            Ok := False;
                           End;
                       If (S[3] In ['2'..'4']) And (S[2] <>'1') And Ok
                          Then St := St+'тысячи ';
                       If (S[3]='1') And (S[2]<>'1') And Ok Then St := St+'тысяча ';
                       If (S[3]='1') And (S[2]='1') And Ok Then St := St+'тысяч ';
                      End;
    3: If St <> '' Then
                      Begin
                       If (S[3] In ['5'..'9','0']) Or
                          ((S[2]='1') And (S[3]In['0'..'9'])) Then
                           Begin
                            St := St+'миллионов ';
                            Ok := False;
                           End;
                       If (S[3] In ['2'..'4']) And (S[2] <>'1') And Ok
                          Then St := St+'миллиона ';
                       If (S[3]='1') And (S[2]<>'1') And Ok Then St := St+'миллион ';
                       If (S[3]='1') And (S[2]='1') And Ok Then St := St+'миллионов ';
                      End;
    1: If St <> '' Then St := St+' ';
   End;
   Del2Space(St);
  End;


Procedure Format(St : String;Var Sum1,Sum2 :String);
Var s : string[150];
Begin
 S[0] := #0;
 Sum1[0] := #0;
 Sum2[0] := #0;
 If Ord (St[0]) > 75 Then
 Begin
 For i := 75 Downto 1 Do
  Begin
   If St[i]=' ' Then Break;
  End;
  Sum1 := Copy (St,1,i-1);
  k:=i;
  i:=Ord(St[0]);
  Sum2 := Copy (St,k,i);
  Del2Space(Sum1);
  Del2Space(Sum2);
  i := Ord(Sum2[0]);
  k:=85-i;
  If k>1 Then
     Begin
    For i:=0 To Trunc(k/2) Do
    s[i+1] := ' ';
    s[0] := Char(Trunc(k/2)-1);
      Insert(s,Sum2,1);
     End;
 End
 Else Begin
       Sum1 := St;
       Del2Space(Sum1);
      End;
End;


Procedure Propis(Var St , s1:String);
 Var i,j,l : Integer;
     Ws : string[150];
     prop :string[150];
     Mantissa : string[150];
Begin
Stroka1[0] := #0;
Stroka2[0] := #0;
Stroka3[0] := #0;
Prop[0]:=#0;
l:=Pos('.',St);
Mantissa:=Copy(st,l+1,Ord(St[0]));
St[0]:=Chr(l-1);
i := Ord(St[0]);
j := 1;
For k:=1 To i Do
 Begin
  If (St[k] in ['0'..'9']) Then
   Begin
    ProwSt[j] := St[k];
    Inc(j);
   End;
 End;
ProwSt[0] := chr(j-1);
{If (j-1) < 9 Then
             Begin
              For l:= 1 To 9-(j-1) Do
                 Insert('0',ProwST,1);
             End;}
Case i{j-1} Of
   0:Begin
      Sotni := False;
      Tis := False;
      Mil := False;
     End;
1..3:Begin
      Sotni := True;
      Tis := False;
      Mil := False;
     End;
4..6:Begin
      Sotni := True;
      Tis := True;
      Mil := False;
     End;
7..9:Begin
      Sotni := True;
      Tis := True;
      Mil := True;
     End;
 Else
{      Begin
      Sotni := True;
      Tis := True;
      Mil := True;
      End;   ;
} End;
Inc(k);
{If k>9 Then
Begin
k:=9;
ProwSt[0] := Chr(k);
End;}
S1[0] := #0;
S2[0] := #0;
S3[0] := #0;
 For i := 1 To 3 Do
  Begin
      S1[i]:='0';
      S1[0] := Chr(i);
      S2[i]:='0';
      S2[0] := Chr(i);
      S3[i]:='0';
      S3[0] := Chr(i);
  End;
S1[0] := Chr(i);
S2[0] := Chr(i);
S3[0] := Chr(i);
If Sotni Then RazBiwka(S1);
If Tis Then RazBiwka(S2);
If Mil Then RazBiwka(S3);
Stroki (1, S1 ,  Stroka1 );
Stroki (2, S2 ,  Stroka2 );
Stroki (3, S3 ,  Stroka3 );
St[0]:=#0;
St :=Stroka3+Stroka2+Stroka1;
i := Ord(S1[0]);
If S1[i-1] <> '1' Then
 Begin
Case (S1[i]) Of
 '1':St := St + 'рубль';
 '2','3','4':St := St + 'рубля';
 '5','6','7','8','9','0':St := St + 'рублей';
Else;
 End;
 End
 Else St := St + 'рублей';
i := Ord(Mantissa[0]);
If Mantissa[i-1] <> '1' Then
 Begin
Case (Mantissa[i]) Of
 '0','5','6','7','8','9':St:=St+' '+Mantissa+' копеек';
 '1':St:=St+' '+Mantissa+' копейка';
 '2','3','4':St:=St+' '+Mantissa+' копейки';
Else;
 End;
 End
 Else
 St:=St+' '+Mantissa+' копеек';
 Format (st,s1,Prop);
Del2Space(Prop);
St:=Prop
End;


End.
