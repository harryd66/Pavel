Uses Glob,ServStr,Crt;
Var      f : File Of SkidkaType;
       skl : PSkidkaType;
   j,Max,i : Integer;
    Razdel : string[150];


Begin {�ணࠬ�� ������ 㪠���� � PathStr(1) 䠩� ������ �� ParamStr(2)}

 ClrScr;
 If (ParamStr(1)='') Or (ParamStr(2)='') Or
    (ParamStr(3)='') Then
   Begin
    Writeln('�ணࠬ�� �ॡ����:');
    Writeln('1 - ��� � ���� � 䠩�� *.skl');
    Writeln('2 - ������⢮ ������塞�� ����権');
    Writeln('3 - ��� ࠧ����');
    Halt;
   End;

 Assign(f,ParamStr(1));
 Reset(f);

 i:=StrToInt(ParamStr(2));
 New(Skl,Init);
 Max:=FileSize(f);

 If (Max+i)>=999 Then
 Begin
  i:=999-Max;
  Writeln('����� ������⢮:',i:3);
  Readln;
 End;

 For j:=Max To Max+i Do
  Begin
   Seek(f,FileSize(f));
   Skl^.Dat.BazKod:=IntToStr(j,3);
   RFormatZerro(Skl^.Dat.BazKod,3);
   Skl^.Dat.BazKod:=ParamStr(3)+Skl^.Dat.BazKod;
   Write(f,Skl^.Dat);
  End;

 Writeln('All Ok');

 Close(f);
End.