Uses ServStr,Serv, TpDAte;
Var Time,TimeStop,CurTime : LongInt;
Begin
 Time:=TimeStringToTime('hh:mm:ss',Times);
 TimeStop:=TiMe+StrToInt(ParamStr(1));
 Writeln(Times);
 Repeat
  CurTime:=TimeStringToTime('hh:mm:ss',Times);
 Until (CurTime>=TimeStop);
 Writeln(Times);
End.