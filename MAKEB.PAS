Uses Glob,Serv,ServStr,TpDate;

Var f  : File Of KassaOperationType;
    kk : PKassaOperationType;
    fb : File Of BankType;
    kb : PBankType;
    fp : File Of PersonalType;
    kp : PPersonalType;
    jj : File Of LockBazType;
    Lck: LockBazType;
    c  : Word;
    i  : Word;
Begin
 Assign(f,'kassa.db');
 Rewrite(f);
 New(kk,Init);
 For c:=1 To 200 Do
 Begin
   With KK^.Dat Do
   Begin
   NAme   [0]:=#0;
   Status    :=0;{0-ā áåŽ¤ ¨§ Ē ááë 1-¯Žáâã¯ĢĨ­¨ī ĸ Ē ááã}
   Kod:=IntToStr(c,CClientKod);
   Enable:=0;
   RFormatZerro(Kod,CClientKod);
   Enable    :=0;
   Employ :=False;
   Caption:='00';{Ž¯Ĩā âŽā}
   DateM   :=DateStringToDAte(DateMAsk,FDAte);
   TimeM   :=TimeStringToTime('hh:mm:ss',CurrentTimeString('hh:mm:ss'));
   RCD     :=False;
   If c=0 Then
    Begin
     Name:=' ';
     Employ:=True;
    End;
   End;{With}
   Write(f,kk^.DAt);
 End;{For}
 i:=IoResult;
 Close(f);
 i:=IoResult;
 Dispose(kk,Done);


 Assign(fp,'Personal.db');
 Rewrite(fp);
 New(kp,Init);
 For c:=1 To 200 Do
 Begin
   With KP^.Dat Do
   Begin
      NAme     [0]:=#0;
      StatusOut:=0;
      StatusIn :=0;
      Kassir   :=0;
      Kod:=IntToStr(c,CClientKod);
      RFormatZerro(Kod,CClientKod);
      Employ  :=FAlse;
      Caption :='00';
      DateM   :=DateStringToDAte(DateMAsk,FDAte);
      TimeM   :=TimeStringToTime('hh:mm:ss',CurrentTimeString('hh:mm:ss'));
      RCD     :=FAlse;
   If c=0 Then
    Begin
     Name:=' ';
     Employ:=True;
    End;
   End;{With}
   Write(fp,kp^.DAt);
 End;{For}
 i:=IoResult;
 Close(fp);
 i:=IoResult;
 Dispose(kp,Done);

 Assign(fb,'Banks.db');
 Rewrite(fb);
 New(kb,Init);
 For c:=1 To 200 Do
 Begin
   With Kb^.Dat Do
   Begin
      NAme     [0]:=#0;
      FullName [0]:=#0;
      GDE [0]:=#0;
      BIK [0]:=#0;
      KSh [0]:=#0;
      RSh [0]:=#0;
      INN [0]:=#0;
      KPP [0]:=#0;
      Kod:=IntToStr(c,CClientKod);
      RFormatZerro(Kod,CClientKod);
      Employ  :=FAlse;
      RCD     :=FAlse;
   If c=0 Then
    Begin
     Name:=' ';
     FullName:=' ';
     Employ:=True;
    End;
   End;{With}
   Write(fb,kb^.DAt);
 End;{For}
 i:=IoResult;
 Close(fb);
 i:=IoResult;
 Dispose(kb,Done);







Assign(jj,'kassa.lck');
Rewrite(jj);
For c:=0 To 1000 Do
 Begin
  Lck.BazKod:=IntToStr(c,CClientKod);
  RFormatZerro(Lck.BazKod,CClientKod);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(jj,Lck);
 End;

 i:=IoResult;
 Close(jj);
 i:=IoResult;

Assign(jj,'personal.lck');
Rewrite(jj);
For c:=0 To 1000 Do
 Begin
  Lck.BazKod:=IntToStr(c,CClientKod);
  RFormatZerro(Lck.BazKod,CClientKod);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(jj,Lck);
 End;

 i:=IoResult;
 Close(jj);
 i:=IoResult;


Assign(jj,'Banks.lck');
Rewrite(jj);
For c:=0 To 1000 Do
 Begin
  Lck.BazKod:=IntToStr(c,CClientKod);
  RFormatZerro(Lck.BazKod,CClientKod);
  Lck.LockCaption[0]:=#0;
  Lck.ComputerNameLocked[0]:=#0;
  Lck.Locked:=False;
  Write(jj,Lck);
 End;

 i:=IoResult;
 Close(jj);
 i:=IoResult;






End.
