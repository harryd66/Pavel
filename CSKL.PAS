Uses Glob,ServStr,Serv,Objects,TpDAte;

{Информация по наименованию}
Type BakShkala = Record
     Up : String[CIZena];
     Proz : String[CLitr+1];
     End;

Type PBakShkala = ^BakShkalaPtr;
     BakShkalaPtr = Object(TObject)
     Dat : BakShkala;
     Next : PBakShkala;
     Constructor Init(s:BakShkala);
     Destructor Done; Virtual;
     End;


Type BakSkidkaType = Record
     BazKod : String[CArtikul];
     Date   : TDateString;
     Time   : TDateString;
     Caption: String [CRazdelKod];
     Skidka : Array [1..6] of BakShkala;
     End;

Type PBakSkidkaType = ^BakSkidkaPtr;
     BakSkidkaPtr = Object(TObject)
     Dat : BakSkidkaType;
     Constructor Init;
     Destructor Done; Virtual;
     End;

Var BakFile : File Of BakSkidkaType;
    F :File Of SkidkaType;
    BakPtr :PBakSkidkaType;
    Ptr :PSkidkaType;
    s1,s2:String;
    i : Word;



Constructor BakSkidkaPtr.Init ;
Var i : Byte;
Begin
TObject.Init;
 With Dat Do
  Begin
  BazKod[0]:=#0;
  Date:=FDate;
  Time:=CurrentTimeString('hh:mm:ss');
  Caption:=CurrentPassword;
  For i :=1 To CShkala Do
  Begin
   Skidka[i].Up:='0.00';
   Skidka[i].Proz:='1.000';
  End;
  End;
End;

Destructor BakSkidkaPtr.Done;
Begin
TObject.Done;
End;

Constructor BakShkalaPtr.Init(s:BakShkala);
Var i : Byte;
Begin
TObject.Init;
Dat:=S;
Next := Nil;
End;

Destructor BakShkalaPtr.Done;
Begin
If Next <> Nil Then Dispose(Next,Done);
TObject.Done;
End;



Begin
If ParamStr(1)='' Then
 Begin
  Writeln('Программе требуется путь и имя файла скидок без расширения !');
  Halt;
 End;
s1:=ParamStr(1);
Assign(BakFile,s1+'.skl');
i:=IOResult;
Reset(BakFile);
i:=IOResult;
If I<>0 Then
 Begin
  Writeln('Не могу открыть '+s1+'.skl');
  Halt;
 End;

Assign(F,s1+'.new');
i:=IOResult;
Rewrite(F);
i:=IOResult;
If I<>0 Then
 Begin
  Close(BakFile);
  Writeln('Не могу создать '+s1+'.new');
  Halt;
 End;

New(BakPtr,Init);
New(Ptr,Init);

While Not(Eof(BakFile)) Do
 Begin
  Read(BakFile,BakPtr^.Dat);
  With Ptr^.Dat Do
   Begin
     BazKod  :=BakPtr^.Dat.BazKod;
     Caption :=BakPtr^.Dat.Caption;
     Date    :=BakPtr^.Dat.Date;
     Time    :=BakPtr^.Dat.Time;
     For i:=1 To CShkala Do
      Begin
       Skidka[i].Proz:='1.0000';
       Skidka[i].Up:='1';
      End;
   End;
   seek(f,filesize(f));
   Write(f,ptr^.dat);
 End;

Dispose(BakPtr,Done);
Dispose(Ptr,Done);
Close(BakFile);
Close(f);

Rename(BakFile,s1+'.bak');
Rename(F,s1+'.skl');
Writeln('Ok');
End.