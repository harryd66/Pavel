Uses Glob,TpDate,ServStr,Serv;

Var Txt:Text;
    s : String;
    f : File Of BankType;
    BN : PBankType;
    w : Word;

Begin
Assign(txt,ParamStr(1));
Reset(txt);
Assign(f,ParamStr(2));
Reset(f);

While Not(SeekEof(txt)) Do
 Begin
  Readln(txt,s);
  New(Bn,Init);
  {���}
  Bn^.Dat.Kod:=Copy(s,1,Pos(';',s)-1);
  System.Delete(s,1,Pos(';',s));
  Writeln(s);
  RFormatZerro(Bn^.Dat.Kod,CClientKod);

  {��������}
  Bn^.Dat.FullName:=Copy(s,1,Pos(';',s)-1);
  System.Delete(s,1,Pos(';',s));
  Writeln(s);
  {���}
  Bn^.Dat.Bik:=Copy(s,1,Pos(';',s)-1);
  System.Delete(s,1,Pos(';',s));
  Writeln(s);

  {���.���}
  Bn^.Dat.KSh:=Copy(s,1,Pos(';',s)-1);
  System.Delete(s,1,Pos(';',s));
  Writeln(s);

  {��த}
  Bn^.Dat.Gde:=Copy(s,1,Pos(';',s)-1);
  System.Delete(s,1,Pos(';',s));

  {㫨�}
  Bn^.Dat.Gde:=Bn^.Dat.Gde+', '+s;
  Writeln(s);
  Bn^.Dat.Status:=1;
  Bn^.Dat.Employ:=True;

  seek(f,StrToInt(Bn^.Dat.Kod));
  Write(f,Bn^.Dat);

  Writeln(StrToInt(Bn^.Dat.Kod));
  Readln;


  Dispose(Bn,Done);
 End;

w:=IoResult;
Close(txt);
w:=IoResult;
Close(f);
w:=IoResult;

End.