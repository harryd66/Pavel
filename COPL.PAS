Uses Glob,Serv,ServStr,Utils,DbEngine,Objects,TpDate;

Type BakOplataRealizasiaType = Record
             SkladKod : String[CClientKod];
        ClientKod :String[CClientKod];
     PrhNumer : String[CDocNumer]; {����� �뤠����� ��室����}
     Document : String[CDocNumer]; {����� ���㬥��}
     DateDoc : TDateString; {��� ���㬥��}
     DateC   : TDateString; {��� ������}
     TimeC   : TDateString; {�६� ������}
     SummaZ  : String[CIZena];  {�㬬� ������}
     Skidka  : String[CIZena];  {����稭� ᯨᠭ�� ᪨���}
     Vozwrat : Boolean;      {�᫨ �� ������}
     DocNumerReturn: String[CDocNumer];{���㬥�� ������}
     DocDateReturn : STring[CDate];    {���㬥�� ������}
     Caption : String [CRazdelKod];{�ਧ��� ������}
     Rashet  : Boolean;
     Bn      : BezNal;

     End;




Var Er : File Of OplataRealizasiaType;
    ErB: File Of BakOplataRealizasiaType;
    E  : OplataRealizasiaType;
    EB : BakOplataRealizasiaType;
    c,i: Word;
    s1,s2,ext : String;

Begin
 Assign(Erb,ParamStr(1)+'.opl');
 i:=IoResult;
 Reset(erb);
 i:=IoResult;
 If i<>0 Then
  Begin
   Writeln('Error open '+ParamStr(1)+'.opl');
   Readln;
   Halt;
  End;

 Assign(er,ParamStr(1)+'.new');
 i:=IoResult;
 Rewrite(er);
 i:=IoResult;
 If i<>0 Then
  Begin
   Writeln('Error creat '+ParamStr(1)+'.new');
   Readln;
   Halt;
  End;


 While Not(Eof(Erb)) Do
 Begin
  Read(erb,Eb);

 With E Do
 Begin
     SkladKod :=Eb.SkladKod;
     ClientKod:=Eb.ClientKod;
     Document    :=Eb.Document;
     DateDoc :=Eb.DateDoc;
     DateC   :=Eb.DateC;
     TimeC   :=Eb.TimeC;
     SummaZ  :=Eb.SummaZ;
     Skidka  :=Eb.Skidka;
     Vozwrat :=Eb.Vozwrat;
     DocNumerReturn:=Eb.DocNumerReturn;
     DocDateReturn :=Eb.DocDateReturn;
     Caption :=Eb.Caption;
     if Eb.Rashet Then Rashet:=True
     Else Rashet:=False;
     Bn      :=Eb.Bn;
     PrhNumer:=Eb.PrhNumer;
     Realiz:=false;
 End;


  Seek(er,FileSize(Er));
  Write(Er,E);

 End;

  Close(Er);
  Close(Erb);

  Rename(Erb,ParamStr(1)+'.bak');
  Rename(Er,ParamStr(1)+'.opl');
  Writeln('All ok');
End.

