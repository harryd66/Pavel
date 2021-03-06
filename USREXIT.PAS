Unit UsrExit;
{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


Interface

Uses MsgBox,ServStr,Glob,Serv;

Var OldExit : Pointer;

Procedure UserExit;
Function HexB(b:Byte):String;
Function HexW(N:Word):String;

Implementation

Procedure UserExit;
Var ws,Txt : String;
    f : Text;
    c : Byte;
Begin
 Assign(f,'c:\error.txt');
 c:=IOResult;
 Append(f);
 c:=IOResult;
 If c<>0 Then Rewrite(f);
 c:=IOResult;

 ExitProc:=OldExit;
 case ExitCode Of
  1: txt:='������ ����� �㭪樨';
  2: txt:='�� ������ 䠩�';
  3: txt:='�� ������ ����';
  4: txt:='���誮� ����� ������� 䠩���';
  5: txt:='�⪠���� � ����㯥 � 䠩��';
  6: txt:='�������⨬� 䠩���� ���ਯ��';
 12: txt:='�������⨬� ��� ����㯠 � 䠩��';
 15: txt:='�������⨬� ����� ��᪮����';
 16: txt:='����� 㤠���� ⥪�騩 ��⠫��';
 17: txt:='����� 㪠�뢠�� ࠧ�� ��᪮����';
100: txt:='�訡�� �⥭�� ��᪠';
101: txt:='�訡�� ����� �� ���';
102: txt:='����� �� ��᢮��� ���';
103: txt:='���� �� �����';
104: txt:='���� �� ����� ��� �����';
105: txt:='���� �� ����� ��� �뢮��';
106: txt:='������ �᫮��� �ଠ�';
150: txt:='��� ���饭 �� �����';
151: txt:='��������� �����';
152: txt:='��� �� ��⮢';
153: txt:='������������ �������';
154: txt:='�訡�� ��室��� ������';
155: txt:='����ୠ� ����� ��������';
156: txt:='�訡�� ��⠭���� ������� �� ��᪥';
157: txt:='��������� ⨯ ���⥫�';
158: txt:='�� ������ ᥪ��';
159: txt:='���稫��� �㬠�� �� �ਭ��';
160: txt:='�訡�� �� ����� �� ���ன�⢮';
161: txt:='�訡�� �� �⥭�� � ���ன�⢠';
162: txt:='���� ���������';
200: txt:='������� �� ����';
201: txt:='�訡�� �� �஢�થ �࠭��';
202: txt:='��९������� �⥪�';
203: txt:='��९������� ���';
204: txt:='�������⨬�� ������ � 㪠��⥫��';
205: txt:='��९������� �� ����樨 � ������饩 �窮�';
206: txt:='��祧������� ���浪� �� ����樨 � ������饩 �窮�';
207: txt:='�������⨬�� ������ � ������饩 �窮�';
208: txt:='�� ���樨஢�� ���૥�';
209: txt:='�訡�� �⥭�� ���૥����� 䠩��';
210: txt:='��ꥪ� �� ���樠����஢��';
211: txt:='�맢�� �����ࠪ�� ��⮤';
212: txt:='�訡�� ॣ����樨 ��⮪�';
213: txt:='������ ������樨 ��室�� �� �࠭��� ���������';
214: txt:='��९������� ������樨';
215: txt:='��䬥��᪮� ��९�������';
216: txt:='�訡�� ����� DPMI';
Else Begin
      Str(ExitCode,ws);
      DelSpace(ws);
      txt:='�訡�� N'+ws;
     End;
End;{CAse}

If ExitCode=216 Then
Begin
 Writeln(f,'���਩��� �����襭��: '+ FDate+'('+Times+') '+txt);
 Writeln(f,'������: '+CurrentPassword);
 Writeln(f,'___________________________________________________________');
 Close(f);
 DelFlag;
End
 Else
  Begin
   Writeln(f,'���਩��� �����襭��: '+ FDate+'('+Times+') '+txt);
   Writeln(f,'���� �訡��: '+HexW(Seg(ErrorAddr^))+':'+HexW(ofs(ErrorAddr^)));
   Writeln(f,'������: '+CurrentPassword);
   Writeln(f,'___________________________________________________________');
   Close(f);
   DelFlag;
   txt:=^M+#3+txt+^M+#3+' �� ����� ';
   txt:=txt+HexW(Seg(ErrorAddr^))+':'+HexW(ofs(ErrorAddr^));
   MessageBox(txt,Nil,mfFatalError+mfInsertInApp+mfCancelButton);
  End;
ExitCode:=0;
ErrorAddr:=Nil;
End;{UserExit}


Function HexB(b:Byte):String;
Const HD : Array [0..15] Of Char =('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
Begin
 HexB:=HD [b shr 4]+ HD[b and $F];
End;

Function HexW(N:Word):String;
Begin
 HexW:=HexB(Hi(n))+HexB(Lo(n))
End;

End.