
{$DEFINE Converter}

Uses Glob,Serv,ServStr,TPDate,Utils;



Var
    b  :PClientType;
    bf :File of ClientType;
    l : Word;

Begin
Assign (bf,ParamStr(1));
l:=IOResult;
Reset(bf);
l:=IOResult;

If l <> 0 Then
 Begin
  Writeln('File As ParamStr(1) not found!');
  Halt;
 End;

New(b,Init);

While Not Eof(bf) Do
Begin
  Read(bf,b^.Dat);
  B^.Dat.MinimalProz:='30';
  B^.Dat.RCD:=True;
 If b^.Dat.Lizo=1 Then
  Begin
   b^.Dat.Otgruska:=0;
   b^.Dat.Status:=3;
  End;
   seek(bf,FilePos(bf)-1);
   l:=IOResult;
   Write(bf,b^.Dat);
   l:=IOResult;
End;
 Dispose(b,Done);

Close(bf);
l:=IOResult;
writeln('Ok');
l:=IOResult;
End.