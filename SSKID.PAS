{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit Sskid;


Procedure SpecialCalc;


Interface


Uses Dialogs,Drivers,Glob,Access,LockInfo,ServStr,MyCalc,DStat;


Procedure SpecialCalc;
Type Dur =  Record;

Var Start,Stop,Cur : LongInt;
    E : PSuperMarketType;
    s1,s2 : TDateString;
Begin
   If Not(DatePeriodDialog(S1,S2,False)) Then Exit;
   start:=DateStringToDate(DAtemask,S1);
   stop:=DateStringToDate(DAtemask,S2);


End;


End;
