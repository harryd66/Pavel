function TestTMailIn: boolean;
var
 DirInfo: SearchRec;
begin
 TestTMailIn:=false;
 FindFirst(Path^.Dat.ToWinLnk+'IN\*.*', Archive, DirInfo);
 if DosError = 0 then TestTMailIn:=true;
end;