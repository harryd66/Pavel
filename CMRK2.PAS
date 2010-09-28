Uses Glob,ServStr;

Var MarketFile : MarketFileType;
    C : Word;
    Doc,Date : String;
    Find : Boolean;
    Test : PSuperMarketType;
Begin
  Assign(MarketFile,'e:\nskl\market\12-09-02.new'{ParamStr(1)});
  Reset(MarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    Writeln('Ошибка открытия '+'c:\newskl\market\29-08-01.mrk');
    Exit;
   End;
   New(Test,Init);
   Test^.Dat.Document:='118';
   Test^.Dat.DateC:='12-09-02';
   Test^.Dat.TimeC:='19:51:02';
   Test^.Dat.AgentKod:='0000';
   Test^.Dat.ClientKod:='0999';
   Test^.Dat.SkladKod:='0001';
   Seek(MArketFile,FileSize(MarketFile));
   Test^.DAt.Active:=True;
   Write(MarketFile,Test^.DAt);
   Dispose(Test,Done);

   New(Test,Init);
   Test^.Dat.Document:='119';
   Test^.Dat.DateC:='12-09-02';
   Test^.Dat.TimeC:='19:51:02';
   Test^.Dat.AgentKod:='0000';
   Test^.Dat.ClientKod:='2153';
   Test^.Dat.SkladKod:='0001';
   Seek(MArketFile,FileSize(MarketFile));
   Test^.DAt.Active:=True;
   Write(MarketFile,Test^.DAt);
   Close(MarketFile);
   Dispose(Test,Done);
   Writeln('All Ok');

End.
