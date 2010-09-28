Uses ServStr,Crt;
Begin
 Clrscr;
 Writeln('e = ',Exp(2.0));
 Writeln(WordToMyHex(0)+'-',MyHexToWord(WordToMyHex(0)));
 Writeln(WordToMyHex(34)+'-',MyHexToWord(WordToMyHex(34)));
 Writeln(WordToMyHex(35)++'-',MyHexToWord(WordToMyHex(35)));
 Writeln(WordToMyHex(36)++'-',MyHexToWord(WordToMyHex(36)));

 Writeln(WordToMyHex(1000)++'-',MyHexToWord(WordToMyHex(1000)));

 Readln;
 {
 Writeln(WordToMyHex(35));
 Writeln(WordToMyHex(36));
 Writeln(WordToMyHex(1500));
 Writeln(WordToMyHex(1000));
 }

End.