Uses Glob,ServStr;
Var Es : BarterClientType;
    Esf : File Of BarterClientType;
    i : Byte;
Begin
 Assign(esf,Paramstr(1));
 i:=IOResult;
 Reset(esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
    writeln(Paramstr(1));
    halt;
  end;

  while not eof(esf) do
  begin
    read(esf,Es);
    if Es.OperatorSelector=0 then
    begin
     Es.VidPrihoda:=1;
     Es.OstatokDolga:=Es.pSummaZakupka;
     writeln(Es.PSummaZakupka);
     Seek(Esf,filepos(Esf)-1);

     write(Esf,Es);
    end;
  end;

  close(Esf);

End.