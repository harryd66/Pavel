Uses Glob,ServStr,Serv,Objects,TpDAte;

Type BakRazdelType = Record
      Name       : String[CRazdel];
      Designation: String[CDate];
      EnableLitr : Word;
      MinNAzenka : String[CLitr+1];
      Skidka     : Array [1..CShkala] of Shkala;
      Kod        : String[CRazdelKod];
      DostProz   : String[CZena]; {процент за доставку - бум использовать для вычисления РЦ}
      Employ     : Boolean;
      Locked     : Boolean;
      Group      : String[CRazdelKod];
     End;

Var BakFile : File Of BakRazdelType;
    F :File Of RazdelType;
    BakPtr : BakRazdelType;
    Ptr : RazdelType;
    s1,s2:String;
    i : Word;


Begin
Assign(BakFile,'razdel.db');
i:=IOResult;
Reset(BakFile);
i:=IOResult;
If I<>0 Then
 Begin
  Writeln('Не могу открыть razdel.db');
  Halt;
 End;

Assign(F,'razdel.new');
i:=IOResult;
Rewrite(F);
i:=IOResult;
If I<>0 Then
 Begin
  Close(BakFile);
  Writeln('Не могу создать '+'razdel.new');
  Halt;
 End;

While Not(Eof(BakFile)) Do
 Begin
  Read(BakFile,BakPtr);
  With Ptr Do
   Begin
      Name       :=BakPtr.Name;
      Designation:=BakPtr.Designation;
      EnableLitr :=BakPtr.EnableLitr;
      MinNAzenka :=BakPtr.MinNazenka;
      BeginStartSeason[0]:=#0;
      BeginStopSeason[0]:=#0;
      EndStartSeason[0]:=#0;
      EndStopSeason[0]:=#0;
      For i:=1 To CShkala Do
      Begin
       Skidka[i].Up:=BakPtr.Skidka[i].Up;
       Skidka[i].Proz:=BakPtr.Skidka[i].Proz;
      End;
      Kod        :=BakPtr.Kod;
      DostProz   :=BakPtr.DostProz;
	 Group      :=BakPtr.Group;
      Employ     :=BakPtr.Employ;
      Locked     :=BakPtr.Locked;
   End;

   seek(f,filesize(f));
   Write(f,ptr);
 End;


Close(BakFile);
Close(f);

Rename(BakFile,'razdel.bak');
Rename(F,'razdel.db');
Writeln('Ok');
End.