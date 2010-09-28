{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


Unit UMakeHis;



Interface





Implementation

Uses Glob,TpDate,Serv,ServStr;

Var Start , Cur ,Stop : LongInt;
    CurS,StartS,StopS: TDateString;



Procedure SaveHistory(L:PSuperMArketType);
Begin
 Assign(esf,ParamStr(2)+L^.Dat.ClientKod+'.his');
 i:=IOResult;
 Reset(esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
   Writeln('Создаю файл заново '+ParamStr(2)+L^.Dat.ClientKod+'.his');
   i:=IOResult;
   Rewrite(Esf);
   i:=IOResult;
   If i<>0 Then
   Begin
   Writeln('Не могу создать файл заново '+ParamStr(2)+L^.Dat.ClientKod+'.his');
   Readln;
   Exit;
   End;
  End;

 New(Es,Init);
         With Es^.Dat Do
      Begin
        If L^.Dat.DocSelector in [4,8] Then    Rashet:=0
        Else    Rashet:=1;
        Realiz:=L^.Dat.Realiz;
        Document:=L^.Dat.Document;

        ENalog  :=L^.Dat.ENalog;
        Nalog5  :=L^.Dat.Nalog5;
        Nalog3  :=L^.Dat.Nalog3;
        Nalog_  :=L^.Dat.Nalog_;

        SummaZ:=L^.Dat.SummaZ;;
        SummaZakupka:=L^.Dat.SummaZakupka;;
        Skidka:=L^.Dat.Skidka;
        Bn.DAte:=L^.Dat.bn.Date;
        Bn.NPlat:=L^.Dat.bn.NPlat;
        Bn.Bank:=L^.Dat.bn.Bank;
        Bn.Summa:=L^.Dat.bn.Summa;
        Caption:=L^.Dat.Caption;
        DateC:=L^.Dat.DateC;;
        TimeC:=L^.Dat.TimeC;
        DateM:=L^.Dat.DateM;
        TimeM:=L^.Dat.TimeM;;
        SkladKod:= ParamStr(3);
        DocSelector :=L^.Dat.DocSelector;
        SkidkaSelector :=L^.Dat.SkidkaSelector;
        ClientKod:=L^.Dat.ClientKod;
        Active:=True;
        If L^.Dat.DocSelector in [6,8] Then Sf :=True
        Else Sf:=False;
     End;
   Seek(Esf,FileSize(Esf));
   Write(Esf,Es^.Dat);
Dispose(Es,Done);
Close(Esf);
End;


Procedure Make
Begin
DateMask:=InternationalDAte(False,True);
TimeMask:='hh:mm:ss';
StartS:='01-04-98';
StopS:=DateToDateString(DAteMask,ToDay);

Start:=DateStringToDAte(DAteMask,StartS);
Stop:=DateStringToDAte(DAteMask,StopS);

 If (ParamStr(1)='') Or (ParamStr(2)='') Or (ParamStr(3)='') Then
   Begin
    Writeln('Программе не хватает входных параметров!');
    Writeln('Для работы необходимо:');
    Writeln('1- путь к файлам продаж');
    Writeln('2- путь к файлам хронологии');
    Writeln('3- код склада (1,2,3,4,5)');
    Halt;
   End;



For Cur := Start To Stop Do
Begin
CurS:=DateToDateString(DateMask,Cur);

Assign (f,ParamStr(1)+CurS+'.mrk');
i:=IOResult;
Reset(f);
i:=IOResult;
If I =0 Then
Begin
 New(E,Init);
 While Not(Eof(f)) Do
  Begin
   Read(f,E^.Dat);
   If (E^.Dat.OperatorSelector=0) And (E^.Dat.Active) Then
   Begin
    If ((E^.Dat.DocSelector in [0,1,2,3,4]) And Not(E^.Dat.Realiz))
    Or ((E^.Dat.DocSelector in [5,6,7,8]) And (E^.Dat.Realiz)) Then
    SaveHistory(E);
   End;
  End;
 Dispose(E,Done);
 Close(f);
End
Else
 Writeln('Ошибка открытия '+ParamStr(1)+CurS+'.mrk');

End;

End.

