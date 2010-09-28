Uses Glob,Serv,ServStr;
Var i : Word;
    kod : ArtikulStr;
Begin
Kod:=ParamStr(1);
RFormatZerro(Kod,3);
If Not FExists(ParamStr(2)+FDate+'.'+Kod) Then Exit;

For i:=1 To StrToInt(ParamStr(1)) Do
Begin
 Sound(10);
 Delay(100);
 NoSound;
 Delay(100);
End;
 Delay(500);

End.