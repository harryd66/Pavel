Uses Glob,DbEngine,Serv,ServSTr,TpDAte;


Var f : File Of RealizasiaType;
    vv : RealizasiaType;
    Find: Boolean;
    c : Word;

Begin
 Assign(f,'0214.dlg');
 c:=IOResult;
 Reset(f);
 c:=IOResult;

 While (Not Eof(f))  Do
  Begin
   Read(f,vv);
   If VV.Market.Active And
   ((DateToDAteString(DateMask,vv.Market.DateC)='13-01-05') And (StrToInt(vv.Market.Document)=74)) Or
   ((DateToDAteString(DateMask,vv.Market.DateC)='21-01-05') And (StrToInt(vv.Market.Document)=91)) Then
    Begin
    Seek(f,FilePos(f)-1);
    VV.Market.DocSelector:=5;
    Write(f,vv);
    Writeln('Обработан '+vv.Market.Document+' от '+(DateToDAteString(DateMask,vv.Market.DateC)));
    Readln;
    End;
  End;

Close(f);
Writeln('All Ok');
End.

