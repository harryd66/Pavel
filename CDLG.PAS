Uses Glob,ServStr,Serv,Objects,TpDAte;

Type BakRealizasiaType = Record
     Market : PsevdoSuperMarketType;
     Dolg   : Real;
     Full   : Boolean;
     Payment: Boolean;{признак оплаты, если началась оплата то корректировать нельзя}
                      {по умолчанию False ,обращается в True, если при расплате долга}
                      {SummaZ=Dolg см док-т реализации}
     Doc    : Array [1..4] Of DocumentLink;     {используется только в первичных документах реализации
                                                 для обозначения выведенных документов }
     Sf     : Boolean;
     End;


Type PBAkRealizasiaType = ^BakRealizasiaPtr;
     BAkRealizasiaPtr=Object(TObject)
     Dat : BAkRealizasiaType;
     Constructor Init;
     Destructor Done; Virtual;
     End;


Constructor BakRealizasiaPtr.Init ;
Var i : Byte;
Begin
TObject.Init;
   With Dat.Market Do
    Begin
     Document[0]:=#0;
     SummaZ[0]:=#0;
     Skidka[0]:=#0;
     Caption:=CurrentPassword;
     Active:=True;
     Srok:=0;
     DateC[0]:=#0;
     SkladKod:=FormKod(Rek.Kod);
     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     ClientKod[0]:=#0;

(*
     With Veksel Do
     Begin
      For i:=1 To 10 Do
       Begin
        Exampl[i].Seria:='ТЛР';
        Exampl[i].Numer[0]:=#0;
        Exampl[i].Data [0]:=#0;
        Exampl[i].Summa[0]:=#0;
        Exampl[i].Proz :='0';
        Exampl[i].DogovorNumer[0]:=#0;
       End;{For}
     End;{With}
    *)
    End;
  With Dat Do
  Begin
   Dolg:=0;
   Full:=False;
     Payment:=False;
     sf := False;
     For i :=1 To 4 Do
      Begin
      Doc[i].DocReal[0]:=#0;
      Doc[i].DocDate[0]:=#0;
      Doc[i].Employ:=False;
      End;
  End;

End;

Destructor BakRealizasiaPtr.Done;
Begin
TObject.Done;
End;



Var BakFile : File Of BakRealizasiaType;
    F :File Of RealizasiaType;
    BakPtr :PBakRealizasiaType;
    Ptr :PRealizasiaType;
    s1,s2:String;
    i : Word;

Begin
s1:=ParamStr(1);
Assign(BakFile,s1+'.dlg');
i:=IOResult;
Reset(BakFile);
i:=IOResult;
If I<>0 Then
 Begin
  Writeln('Не могу открыть '+s1+'.dlg');
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

  Ptr^.Dat.Market:=BakPtr^.Dat.MArket;

  With Ptr^.Dat Do
   Begin
     Dolg   :=BakPtr^.Dat.Dolg;
     Full   :=BakPtr^.Dat.Full;
     Payment:=BakPtr^.Dat.Payment;
     For i:=1 To 4 Do
     Doc[i] :=BakPtr^.Dat.Doc[i];
     Sf     :=BakPtr^.Dat.Sf;
     Realiz:=false;
   End;

   seek(f,filesize(f));
   Write(f,ptr^.dat);
 End;

Dispose(BakPtr,Done);
Dispose(Ptr,Done);
Close(BakFile);
Close(f);

Rename(BakFile,s1+'.bak');
Rename(F,s1+'.dlg');
End.