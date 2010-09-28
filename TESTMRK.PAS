Uses Glob,TpDate,NetDbEng,ServStr;


Const startDate='01-06-01';
      stopDate='17-09-01';


Var CountNkl,Count,CountD : LongInt;
    E : PSuperMarketType;
    EF : MArketFileType;
    k,c : LongInt;
    Start,Stop : LongInt;

Begin
Start:=DateStringToDate(DateMAsk,StartDate);
Stop:=DateStringToDate(DateMAsk,StopDate);

CountNkl:=0;
Count:=0;
CountD:=0;
For c:=Start To Stop Do
Begin
 Assign(ef,DateToDateString(DAteMask,c)+'.mrk');
 Reset(Ef);
 k:=IoResult;

 If k=0 Then
  Begin
   New(E,Init);
   While Not(Eof(Ef)) Do
    Begin
     ReadMarket(ef,E);
     If E^.DAt.Active Then
      Begin
       Inc(CountNkl);
       Inc(Count,E^.Dat.Amount);
       Inc(CountD,E^.Dat.AmountS);
      End;
    End;
   Close(ef);
   Dispose(E,Done);
  End;

End;


Writeln('            Всего накладных      :',CountNkl);
Writeln(' Всего используемых позиций товар:',Count,' ',Count/(CountNkl*55)*100:CKol:CMantissa);
Writeln(' Всего используемых позиций Серт.:',CountD,' ',Count/(CountNkl*55)*100:CKol:CMantissa);


End.