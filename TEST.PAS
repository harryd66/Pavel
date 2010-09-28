Uses MinMAx;

Var A,B : LongInt;

                         {xx:}

function Maximum(A, B: LongInt): LongInt;
inline(
   $58/     {pop   ax   }
   $5B/     {pop   bx   }
   $3B/$C3/ {cmp   ax,bx}
   $7F/$01/ {jg    @@1  }
   $93);    {xchg  ax,bx}







Begin
Readln(A);
Readln(B);

A:=IntMin(A,B);
Writeln(a);
End.