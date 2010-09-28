Uses Glob,ServStr,Utils;

var
    New: BazType;
    NewF: file of BazType;
    IORez,i: word;
    l : LongInt;
    MMM : Maska30;
    M15 : Maska15;

BEGIN
  Assign(NewF,ParamStr(1));
  Reset(NewF);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      writeln('Не могу создать файл ',ParamStr(1));
      exit;
    end;

  while not eof(NewF)do
   begin
     IORez:=IOResult;
     Read(NewF,New);
     IORez:=IOResult;

     If IORez<>0 Then
      Begin
       Writeln('Ошибка ',IORez:3);
	  Halt;
      End;

     New.EnableSklads:=1073741823;
     Seek(NewF,FilePos(NewF)-1);

     write(NewF,New);
   end;

 IORez:=ioresult;
  Close(NewF);
 IORez:=ioresult;

 if IOREz=0 then Writeln('All Ok');
END.

