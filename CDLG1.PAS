Uses Glob,Serv,ServStr,NetDbEng;

Var MarketFile : File Of RealizasiaType;
    C : Word;
    Doc,Date : String;
    Find : Boolean;
    Test : PRealizasiaType;
Begin
  Assign(MarketFile,'d:\works\nsklxp\Dolg\0196.dlg');
  Reset(MarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    Writeln('Ошибка открытия '+'d:\works\nsklxp\Dolg\0196.dlg');
    Exit;
   End;
   Seek(MarketFile,0);
   Find:=False;

   New(Test,Init);
   {цикл поиска накладной}
   While Not(eof(MarketFile)) And Not(Find) Do
    Begin
     Read(MarketFile,Test^.Dat);
     DelSpace(Test^.DAt.MArket.Document);
     DelZerro(Test^.Dat.MArket.Document);

     If (StrToInt(Test^.DAt.MArket.Document)=134) And (TEST^.DAt.MArket.DateC='02-08-05') Then
      Begin
        Seek(MarketFile,FilePos(MarketFile)-1);
        Test^.DAt.MArket.Active:=False;
        Write(MarketFile,Test^.DAt);
      End;

    End;{While}

   Close(MarketFile);
   Dispose(Test,Done);
   Writeln('All Ok');

End.
