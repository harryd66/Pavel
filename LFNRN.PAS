uses Lfn;      { by David Parsons, <david.parsons@virgin.net }

var
   c:Word;
   f : Text;
begin
  Assign  (F, ParamStr(1));
  c:=IOResult;
  LFNDeleteFile(ParamStr(2),False,0,0);
  c:=IOResult;
 { Writeln('��७����������� '+ParamStr(1)+' -> '+ParamStr(2));}
  {Writeln('�������: ',}LFNRename (ParamStr(1),ParamStr(2)){)};
  c:=IOResult;
end.
