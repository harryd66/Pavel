Uses Glob,Serv,ServStr,TPDate,Utils;


Var c  :PClientType;
    cf :File of ClientType;
    a  :PClientType;
    af :File of ClientType;
   txt : Text;
    l : Word;
    s : String;
    SKod,SRouteKod : AllStr;

Begin

Assign(cf,ParamStr(1));
Reset(cf);
l:=IoResult;
If l<>0 Then
 Begin
  Writeln('Žè¨¡ª  ®âªàëâ¨ï client.db');
  Exit;
 End;

New(C,Init);

While Not(Eof(cf)) Do
 Begin
  Read(cf,C^.Dat);
  If Pos('Ž‘Ž—…€ ‹ˆ–…‡ˆŸ',c^.Dat.Messages)>0 Then
  Begin
   c^.Dat.RCD:=True;
   Seek(cf,FilePos(cf)-1);
   Write(cf,C^.Dat);
 End;
 End;

Dispose(c,Done);

Close(cf);

End.