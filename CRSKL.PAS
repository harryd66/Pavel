Uses Glob,ServStr;

Var fskl : SkladFiletype;
    skl : PSkladType;
    idf : File Of BazType;
    id  : PBazType;
    skidf : File Of SkidkaType;
    skid : PSkidkaType;
     cl  : PClientType;

       st : String;
       st1 : String;
       j,c : Word;
    fcl : File Of ClientType;


Begin
For j:=0 to 99 Do
BEgin
 Str(j:2,St1);
 RFormatZerro(st1,2);

Assign(fskl,st1+'.db');
Rewrite(fskl);
Assign(idf,st1+'.id');
Rewrite(idf);

Assign(skidf,st1+'.skl');
Rewrite(skidf);
New(Skl,Init);
New(Id,Init);
New(Skid,Init);

 For c:=0 To 999 Do
  Begin
   Str(c:3,St);
   RFormatZerro(st,3);
   Skl^.DAt.BazKod:=st1+st;
   Id^.DAt.BazKod:=st1+st;
   Skid^.DAt.BazKod:=st1+st;

   Seek(FSkl,FileSize(FSkl));
   Write(FSkl,Skl^.Dat);

   Seek(idf,FileSize(idf));
   Write(idf,Id^.Dat);

   Seek(Skidf,FileSize(SkidF));
   Write(SkidF,Skid^.Dat);
  End;

Close(fskl);
Close(idf);

Close(skidf);

Dispose(Skl,Done);
Dispose(Id,Done);
Dispose(skid,Done);
End;



End.