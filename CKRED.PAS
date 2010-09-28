Uses Glob,Servstr;

Var E : PKreditType;
    f : File Of KreditType;
  Res : Word;


Begin
 New(E,Init);
 Assign(f,'office.dlg');
 Res:=IOResult;
 Rewrite(f);
 Write(f,E^.Dat);
 Res:=IOResult;
 close(f);
 Res:=IOResult;

 Assign(f,'gorod.dlg');
 Res:=IOResult;
 Rewrite(f);
 Write(f,E^.Dat);
 Res:=IOResult;
 close(f);
 Res:=IOResult;

 Assign(f,'region.dlg');
 Res:=IOResult;
 Rewrite(f);
 Write(f,E^.Dat);
 Res:=IOResult;
 close(f);
 Res:=IOResult;

 Assign(f,'rezerv.dlg');
 Res:=IOResult;
 Rewrite(f);
 Write(f,E^.Dat);
 Res:=IOResult;
 close(f);
 Res:=IOResult;
End.
