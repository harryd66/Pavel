Uses Glob,Serv,ServStr,NetDbEng;

Var MarketFile : MarketFileType;
    C : Word;
    Doc,Date : String;
    Find : Boolean;
    Test : PSuperMarketType;

Begin
  Assign(MarketFile,'c:\09-01-01.mrk'{ParamStr(1)});
  C:=IOResult;
  Reset(MarketFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    Writeln('�訡�� ������ '+'c:\09-01-01.mrk');
    Exit;
   End;
   Seek(MarketFile,0);
   Find:=False;

   New(Test,Init);
   {横� ���᪠ ���������}
   While Not(eof(MarketFile)) And Not(Find) Do
    Begin
     ReadMarket(MarketFile,Test);
     DelSpace(Test^.DAt.Document);
     DelZerro(Test^.Dat.Document);
     If (Test^.DAt.Document='23') And (TEST^.DAt.DateC='09-01-01') Then Find:=True;
    End;

  {�᫨ ��������� �� �������}
   If Not(Find) Then
    Begin
      Dispose(test,Done);
      Close(MarketFile);
      Writeln('���㬥�� �� ������!');
      Exit;
    End;

   Seek(MarketFile,FilePos(MarketFile)-1);

{横� �����஢��}

   Test^.DAt.Active:=False;
   Write(MarketFile,Test^.DAt);
   Close(MarketFile);
   Dispose(Test,Done);
   Writeln('All Ok');
End.
