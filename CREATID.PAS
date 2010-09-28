Uses Glob;


Var C : Word;
    Txt : Text;
    Id : PBAzType;
    IDF : File Of BazType;
    s : AllStr;


Begin
Assign(txt,ParamStr(1));
c:=IOResult;
Reset(txt);
c:=IOResult;
{читаем }
While Not(Eof(txt)) Do
 Begin
  Readln(txt,s);
 End;

Close(TXT);



End.