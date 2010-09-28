Uses Glob,ServStr,Utils;

Label Next;

var
    Old: BazType;
    OldF: file of BazType;
    IORez,i: word;
    SArt1,SArt,Rz,Kod : ArtikulStr;
    l : LongInt;
    MMM : Maska30;
    M15 : Maska15;
    txt : Text;
    S : String;

BEGIN
  Assign(txt,'lll.txt');
  Reset(txt);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      writeln('Не могу открыть файл lll.txt');
      exit;
    end;

  while not eof(txt)do
   begin
Next:
     IORez:=IOResult;
     Readln(txt,s);
     IORez:=IOResult;
     SArt1:=Copy(s,1,CArtikul);
     SArt:=Copy(s,1+CArtikul+1,CArtikul);
     Writeln(SArt1+' '+SArt);
     IORez:=IOResult;
     Rz:=Copy(SArt1,1,2);{код раздела}
     Assign(OldF,Rz+'.id');
     IORez:=IOResult;
     Reset(OldF);
     IORez:=IOResult;

     If IORez=0 Then
      Begin
       Kod:=Copy(SArt1,3,5);

       If StrToInt(Kod)>FileSize(OldF) Then
        Begin
         Writeln(Kod+'>'+IntToStr(FileSize(OldF),CKol));
         IORez:=IOResult;
         Close(OldF);
         IORez:=IOResult;
         Goto Next;
        End
       Else
        Begin
         Seek(OldF,StrToInt(Kod));
         Read(OldF,Old);
         Old.FantomKod:=SArt;
         Seek(OldF,FilePos(OldF)-1);
         IORez:=IOResult;
         Write(OLDF,Old);
         IORez:=IOResult;
        End;

      IORez:=IOResult;
      Close(OldF);
      IORez:=IOResult;
      End
       Else
        Writeln(Rz+'.id не найден!');


   end;

 IORez:=ioresult;
  Close(txt);
 IORez:=ioresult;

 if IOREz=0 then Writeln('All Ok');
END.