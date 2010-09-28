Uses Glob,Objects,Serv,ServStr,TpDate;


Type BakHiddenKassaType = Record
{1}                              PrihodZ : String[CIZena];
{2}                             OstatokZ : String[CIZena];
{26}                            RewisiaZ : String[CIZENA];
                                 ReturnZ : String[CIZENA];
                               MinusDohod: String[CIZENA];
                                 AllDohod: String[CIZENA];
                                AllDohodA: String[CIZENA];
                                  AllDolg: String[CIZENA];
                                 AllDolgA: String[CIZENA];
   End;

Type
    PBakHiddenKassaType = ^BakHiddenKassaPtr;
    BakHiddenKassaPtr=Object(TObject)
    Dat  :  BakHiddenKassaType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Constructor BakHiddenKassaPtr.Init ;
Var i : Byte;
Begin
TObject.Init;
With DAt Do
Begin
End;{With}
End;


Destructor BakHiddenKassaPtr.Done;
Begin
TObject.Done;
End;






Var f : File Of BakHiddenKassaType;
    fn: File Of HiddenKassaType;
    B : PBakHiddenKAssaType;
    N : PHiddenKassaType;
    c : Word;

Begin
Assign(f,paramstr(1)+'.h01');
c:=IoResult;
Reset(f);
c:=IoResult;
If c<>0 Then
 Begin
  Writeln('Ошибка чтения кассы!');
  Readln;
  Exit;
 End;


Assign(fn,paramstr(1)+'.n01');
c:=IoResult;
Rewrite(fn);
c:=IoResult;
If c<>0 Then
 Begin
  Writeln('Ошибка создания кассы!');
  Readln;
  Exit;
 End;



 New(B,Init);
 New(N,Init);

 Read(f,B^.DAt);
 With N^.Dat Do
  Begin
              PrihodZ :=B^.DAt.PrihodZ;
             OstatokZ :=B^.DAt.OstatokZ;
             RewisiaZ :=B^.DAt.RewisiaZ;
              ReturnZ :=B^.DAt.ReturnZ;
            MinusDohod:=B^.DAt.MinusDohod;
              AllDohod:=B^.DAt.AllDohod;
             AllDohodA:=B^.DAt.AllDohodA;
               AllDolg:=B^.DAt.AllDolg;
              AllDolgA:=B^.DAt.AllDolgA;
       DolgiIstekshie [0]:=#0;
             DolgiVse [0]:=#0;
     PlategiIstekshie [0]:=#0;
           PlategiVse [0]:=#0;


  End;{With}

 Write(fn,N^.DAt);

 Close(f);
 Close(fn);

 Dispose(B,Done);
 Dispose(N,Done);




End.