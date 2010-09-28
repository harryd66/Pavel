
VAr c:Word;
    f : File;
Begin
Assign(f,'c:\sig.txt');
c:=IOResult;
Repeat
Rewrite(f);
c:=IOResult;
Writeln(c);
Readln;
Until c=0;

Close(f);
End.