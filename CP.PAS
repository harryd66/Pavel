Uses Glob,Objects,Serv,ServStr,TpDate;


Type BakItogType = Record
     BazKod : String[CArtikul];(**)
     Ost    : String[CKol];    (**)
     OstE   : String[CIZena];  (**)
     PrhC   : String[CKol];
     PrhS   : String[CKol];
     PrhB   : String[CKol];
     PrhEC   : String[CIZena];
     PrhES   : String[CIZena];
     PrhEB   : String[CIZena];
     MrkC   : String[CKol];
     MrkS   : String[CKol];
     MrkB   : String[CKol];
     MrkEC  : String[CIZena];
     MrkES  : String[CIZena];
     MrkEB  : String[CIZena];
     End;


 VAr f : File Of BakItogType;
     fn : File Of NewItogType;
     N : PNewItogType;
     B : BAkItogType;
     c : Word;

Begin

Assign(f,paramstr(1)+'.p01');
c:=IoResult;
Reset(f);
c:=IoResult;
If c<>0 Then
 Begin
  Writeln('Ошибка чтения остатков!');
  Readln;
  Exit;
 End;


Assign(fn,paramstr(1)+'.g01');
c:=IoResult;
Rewrite(fn);
c:=IoResult;
If c<>0 Then
 Begin
  Writeln('Ошибка создания новых остатков!');
  Readln;
  Exit;
 End;


 While Not Eof(f) Do
 Begin
  Read(f,B);
  New(N,Init);
   With N^.Dat Do
    Begin
     BazKod :=B.BazKod;
     Osn.NaklNumer[0]:=#0;
     Osn.DateNakl[0]:=#0;
     Ost    :=B.Ost;
     OstE   :=B.OstE;
     PrhC   :=B.PrhC;
     PrhS   :=B.PrhS;
     PrhB   :=B.PrhB;
     PrhEC  :=B.PrhEC;
     PrhES  :=B.PrhES;
     PrhEB  :=B.PrhEB;
     MrkC   :=B.MrkC;
     MrkS   :=B.MrkS;
     MrkB   :=B.MrkB;
     MrkEC  :=B.MrkEC;
     MrkES  :=B.MrkES;
     MrkEB  :=B.MrkEB;
    End;
  Write(fn,N^.DAt);
  Dispose(N,Done);
 End;{While}


 Close(f);
 Close(fn);


 Writeln('All ok');

End.