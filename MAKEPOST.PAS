Uses Glob,Serv,Servstr;


Var f: File Of PostType;
    E: PPostType;
    c : LongInt;
    txt : Text;
    SArt : ArtikulStr;
    s : String;
    MAx: LongInt;


Function FindElement(s:String):Boolean;
VAr Find : Boolean;
Begin
FindElement:=False;

Assign(f,'lands.db');
c:=IoResult;
Reset(f);
c:=IoResult;
Find := False;

New(E,Init);
While Not(Eof(f)) And Not(Find) Do
 Begin
  Read(f,E^.DAt);

  If E^.DAt.Employ Then
  Begin
   If E^.Dat.Name=S Then
    Begin
     Find:=True;
    End;
  End
   Else
    Begin
     If StrToInt(E^.Dat.Kod)>Max Then Max:=StrToInt(E^.Dat.Kod);
     E^.DAt.Name:=S;
     E^.Dat.Employ:=True;
     Find:=True;
     Seek(f,FilePos(f)-1);
     Write(f,E^.DAt);
    End;

 End;
Dispose(E,Done);
Close(f);
FindElement:=Find;
End;


Begin
Max:=0;
{создание базы smarka.db}
Assign(f,'lands.db');
c:=IoResult;
Rewrite(f);
c:=IoResult;
For c:=0 To 150 Do
 Begin
  New(E,Init);
  E^.Dat.Kod:=IntToStr(c,CArtikul);
  RFormatZerro(E^.Dat.Kod,CArtikul);
  If c=0 Then
   Begin
    E^.Dat.Employ:=True;
    E^.Dat.Name:='<НЕТ ДАННЫХ>';
    E^.Dat.Locked:=False;
   End;
  Write(f,E^.DAt);
  Dispose(E,Done);
 End;

c:=IoResult;
Close(f);
c:=IoResult;


{ее заполнение}
Assign(txt,'post.txt');
c:=IoResult;
Reset(txt);
c:=IoResult;
While Not(Eof(txt)) Do
 Begin
  Readln(txt,s);
  c:=Pos('$',s);
  System.Delete(s,1,c);
  DelSpaceRight(s);
  If FindElement(s) Then Writeln(s+'-Ok')
  Else Writeln(s+'-Error');
 End;
c:=IoResult;
Close(txt);
c:=IoResult;

Writeln(MAx:CKol,' -максимальный код')

End.