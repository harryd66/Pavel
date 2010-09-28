Uses Glob, Servstr;

Const

      HexStr     : string[16] = '0123456789ABCDEF';
      HexStrNew  : string[34] = '0123456789ABCDEFGHIJKLMNOPQRSTUXYZ';
                                {1234567890123456789012345678901234}

Function WordToMyHex(L:LongInt):AllStr;
Var s : AllStr;
    K : LongInt;
Begin
 s[0]:=#0;
 If L<34 Then
  Begin
   s:=s+HexStrNew[l+1];
   WordToMyHex:=S;
   Exit;
  End;

  While (L div 34)>0 Do
   Begin
    K:=L Div 34;
    s:=s+HexStrNew[k+1];
    k:=Round(K * 34);
    L:=L-k;

     If L<34 Then
       Begin
       s:=s+HexStrNew[l+1];
       WordToMyHex:=S;
       Exit;
     End;

   End;
End;



Function MyHexToWord(L:AllStr):LongInt;
Var s : AllStr;
    c,K,J : LongInt;

Function FindIndex(C:Char):Byte;
Var pp: Byte;
Begin
 FindIndex:=0;
 For pp:=1 To 34 Do
  Begin
   If c=HexStrNew[pp] Then
    Begin
     FindIndex:=pp;
     Break;
    End;
  End;
End;

Begin
 DelSpace(L);

 If Ord(l[0])<1 Then
  Begin
   k:=0;
   MyHexToWord:=k;
   Exit;
  End;

 k:=0;
 For c:=1 To Ord(L[0]) Do
  Begin
   k:=k+(findindex(l[c])-1)*Round(exp((Ord(L[0])-c)*ln(34)));
  End;

 MyHexToWord:=k;
End;

var a: longint;
    t: text;

BEGIN
assign(t,'c:\test.txt');
 rewrite(t);
for a:=0 to 10001 do
begin
 Write(t,WordToMyHex(a),'=');
 Writeln(t,MyHexToWord(WordToMyHex(a)));
 {writeln(exp(3*ln(34)));}
end;
close(t);
 {readln;}
END.