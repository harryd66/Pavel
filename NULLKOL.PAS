Uses Glob,ServStr;
Var f : File Of SkladType;
  skl : PSkladType;
   j,Max,i : Integer;
   Razdel : String;


Begin {программа расширяет указаный в PathStr(1) файл наличия на ParamStr(2)}
 If (ParamStr(1)='') Then
   Begin
    Writeln('Программе требуется:');
    Writeln('1 - имя и путь к файлу *.db');
    Halt;
   End;

 Assign(f,ParamStr(1));
 i:=IOresult;
 Reset(f);
 i:=IOresult;
 New(Skl,Init);

 While Not(Eof(f)) Do
 Begin
  Read(f,Skl^.Dat);
  For i:=1 To CDivision Do Skl^.Dat.Input.Divisions[i]:='0';
  Skl^.Dat.Input.Kol:='0';
  Seek(f,FilePos(f)-1);
  Write(f,Skl^.Dat);
 End;
 Close(f);
 Writeln('All Ok');
End.