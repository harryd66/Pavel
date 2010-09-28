Uses Glob,ServStr,Crt;

Var f : File Of BazType;
  skl : PBazType;
   j,Max,i : Integer;
   Razdel : string[150];


Begin {программа расширяет указаный в PathStr(1) файл наличия на ParamStr(2)}

 ClrScr;
 If (ParamStr(1)='') Or (ParamStr(2)='') Or
    (ParamStr(3)='') Then
   Begin
    Writeln('Программе требуется:');
    Writeln('1 - имя и путь к файлу *.id');
    Writeln('2 - количество добавляемых позиций');
    Writeln('3 - код раздела');
    Halt;
   End;

 Assign(f,ParamStr(1));
 Reset(f);

 i:=StrToInt(ParamStr(2));
 New(Skl,Init);
 Max:=FileSize(f);

 For j:=Max To Max+i Do
  Begin
   Seek(f,FileSize(f));
   Skl^.Dat.BazKod:=IntToStr(j,3);
   RFormatZerro(Skl^.Dat.BazKod,3);
   Skl^.Dat.BazKod:=ParamStr(3)+Skl^.Dat.BazKod;
   Write(f,Skl^.Dat);
  End;


 Close(f);
End.