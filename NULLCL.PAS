Uses Glob,ServStr,Crt;
Var f : File Of ClientType;
  skl : ClientType;
   j,Max,i : Integer;
   Razdel : String;


Begin {�ணࠬ�� ������ 㪠���� � PathStr(1) 䠩� ������ �� ParamStr(2)}
 ClrScr;
 If (ParamStr(1)='') Then
   Begin
    Writeln('�ணࠬ�� �ॡ����:');
    Writeln('1 - ��� � ���� � 䠩�� *.db');
    Halt;
   End;

 Assign(f,ParamStr(1));
 Reset(f);



 While Not(Eof(f)) Do
 Begin
  Read(f,Skl);
  If Not (Skl.Kod='0000') Then
  Begin
   Skl.Employ:=False;
   Seek(f,FilePos(f)-1);
   Write(f,Skl);
  End;
 End;
 Close(f);
 Writeln('All Ok');
End.