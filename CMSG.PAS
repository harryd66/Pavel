Uses Glob,Serv,ServStr,TPDate,Utils;

Var c  :PClientType;
    cf :File of ClientType;
    l : Word;
    s : String;

Begin

Assign(cf,ParamStr(1));
Reset(cf);
l:=IoResult;
If l<>0 Then
 Begin
  Writeln('่จกช  ฎโชเ๋โจ๏ client.db');
  Exit;
 End;

New(C,Init);

While Not(Eof(cf)) Do
 Begin
  Read(cf,C^.Dat);
  If Pos(' ',c^.Dat.Messages)>0 Then
  Begin
   c^.Dat.Messages[0]:=#0;
   c^.Dat.RCD:=True;
   Seek(cf,FilePos(cf)-1);
   Write(cf,C^.Dat);
 End;
 End;

Dispose(c,Done);

Close(cf);

End.