Uses Glob,Serv,ServStr,TpDate,Net,Net1,NetDbEng;
Var E : PSuperMArketType;
    f : MArketFileType;
    c : Word;

Begin
FileMode:={66}$42;
Assign(f,'d:\newskl\20-09-01.mrk');
Reset(f);

New(E,Init);
Seek(f,0);

     {�����஢��}
     Repeat
     {������}

     Writeln('������ ������');
     Read(f,E^.DAt);
     c:=IOResult;
     Writeln('�������:',c:3);

     Until (c=0);

Close(f);
Dispose(E,Done);
End.
