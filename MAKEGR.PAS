Uses Glob,ServStr,Serv,Objects,TpDAte,vision1;

Var
    F :File Of GroupType;
    Ptr :PGroupType;
    s1,s2:String;
    c1,c,i : Word;


Begin
Assign(F,'group.db');
i:=IOResult;
Rewrite(F);
i:=IOResult;
If I<>0 Then
 Begin
  Writeln('ç• ¨Æ£„ ·Æß§†‚Ï group.db');
  Halt;
 End;



For c:=0 To 999 Do
Begin
New(Ptr,Init);
 Ptr^.DAt.Kod:=IntToStr(c,CClientKod);
 RFormatZerro(Ptr^.DAt.Kod,CClientKod);
 If c=0 Then
  Begin
   Ptr^.Dat.GroupNAme:='<ÉêìèèÄ çÖ éèêÖÑÖãÖçÄ>';
   Ptr^.DAt.Employ:=True;
  End;

 If c=1 Then
  Begin
   Ptr^.Dat.GroupNAme:='èêéÅçÄü ÉêìèèÄ';
   Ptr^.DAt.Employ:=True;
  End;

 Seek(f,FileSize(f));
 Write(f,Ptr^.DAt);
Dispose(Ptr,Done);
End;

Close(f);

Writeln('All ok');

End.