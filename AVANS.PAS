{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Avans;

INTERFACE

Uses Glob, Servstr;

procedure PrintAvansReport(EditKassa: DocumentEdit);

IMPLEMENTATION

Uses Tools,Views, DBEngine,MsgBox,Vision2, Serv, Printers,TPDate,Objects,Dialogs,NetDbEng,NetCall,Dos;

procedure PrintAvansReport(EditKassa: DocumentEdit);
const Space=' ';

var  E : KassaOperation;
     f : OperationFileType;
     Ak : PItogKassa;
     S,s1  : string[150];
     i,c: word;
     test: word;
     Fp : ItogKAssaFileType;
     AS: DocumentEdit;
     t: text;
Begin
Assign(fp,Path.ToClient+EditKassa.D+'.kas');
Reset(fp);
c:=IOResult;
If c=0 Then
Begin
  New(Ak,Init);
  While Not(Eof(Fp)) Do
   Begin
    ReadKassa(Fp,Ak^.DAt);
    if StrToInt(Ak^.DAt.Doc)=StrToInt(EditKassa.EditPosition) then
    begin
     {writeln(GetLizoField(ffName,AK^.DAt.Lizo));
     readln;}
     Assign(t,Path.ToTemp+'avans.txt');
     c:=IOResult;
     Rewrite(t);
     c:=IOResult;
     if c=0 then
     begin
       DelSpace(Ak^.DAt.Doc);
       While(pos('-',EditKassa.D)>0) do System.Delete(EditKassa.D,pos('-',EditKassa.D),1);
       Writeln(t,Space+'�� �த᪨� �.�.');
                 {12345678901234567890123456789012345678901234567890123456789012345678901234567890}
       Writeln(t,Space+'                                           ���������:');
       Writeln(t,Space+'                                           ���� � �㬬�___________________');
       Writeln(t,Space+'      � � � � � � � � �   � � � � �        _____________��.________���.___');
       Writeln(t,Space+'      �����:',Ak^.DAt.Doc,'/',EditKassa.D,' ���: ',FDate,' �.     �㪮����⥫�:');
       Writeln(t,Space+'                                           ________________________________');
       Writeln(t,Space+'                                           "______"_______________20_____�.');
       Writeln(t,Space+'������୮� ���ࠧ�������________________________________');
       Writeln(t,Space+'������⭮� ���: ',GetLizoField(ffName,AK^.DAt.Lizo));
       Writeln(t,Space+'������(��������)________________________________');
Writeln(t,Space+'����������������������������������������������������Ŀ');
Writeln(t,Space+'������������� ������⥫�      ��㬬� (��.,���)      �');
Writeln(t,Space+'����������������������������������������������������Ĵ');
Writeln(t,Space+'� �।��騩 ����� ����⮪   �                      �');
Writeln(t,Space+'�                  ������室�                      �');
Writeln(t,Space+'����������������������������������������������������Ĵ');
Writeln(t,Space+'�����祭 �����: 1. �� �����   � '+RecognizReal(Ak^.DAt.Summa,CIZena,CMantissa));
Writeln(t,Space+'����������������������������������������������������Ĵ');
Writeln(t,Space+'�               2.            �                      �');
Writeln(t,Space+'����������������������������������������������������Ĵ');
Writeln(t,Space+'� �⮣� ����祭�              �                      �');
Writeln(t,Space+'����������������������������������������������������Ĵ');
Writeln(t,Space+'� ����室�����               �                      �');
Writeln(t,Space+'����������������������������������������������������Ĵ');
Writeln(t,Space+'� ���⮪                     �                      �');
Writeln(t,Space+'����������������������������������������������������Ĵ');
Writeln(t,Space+'� �����室                  �                      �');
Writeln(t,Space+'������������������������������������������������������');
                {12345678901234567890123456789012345678901234567890123456789012345678901234567890}
Writeln(t,Space+'���� �஢�७. � �⢥ত���� � �㬬�_____________________________��.______���.');
Writeln(t,Space+'������ ��壠���_______________________________________');
Writeln(t,Space+'���⮪ ���ᥭ      � �㬬�            ��.    ���.   �� ���ᮢ��� �थ�� �______');
Writeln(t,Space+'�����室 �뤠�                                      ��"_______"_________20____�.');
Writeln(t,Space+'��壠��� (�����)_______________________________________');
Writeln(t,Space+'��������������������������������������������������������������������������������������������������Ŀ');
Writeln(t,Space+'� �  �  ���㬥��,     � ������������ ���㬥��      �     �㬬� ��室�                 ������     �');
Writeln(t,Space+'��/� �  ��⢥ত��騩 �    (��室�)                �����������������������������������Ĵ���,    �');
Writeln(t,Space+'�    �  ��室�       �                             �  �� �����,��.� �ਭ��� � ���� ������  �');
Writeln(t,Space+'�    ����������������Ĵ                             �                �                  �          �');
Writeln(t,Space+'�    ����   ������   �                             �                �                  �          �');
Writeln(t,Space+'��������������������������������������������������������������������������������������������������Ĵ');
Writeln(t,Space+'�    �       �        �                             �                �                  �          �');
Writeln(t,Space+'��������������������������������������������������������������������������������������������������Ĵ');
Writeln(t,Space+'�    �       �        �                             �                �                  �          �');
Writeln(t,Space+'��������������������������������������������������������������������������������������������������Ĵ');
Writeln(t,Space+'�    �       �        �                             �                �                  �          �');
Writeln(t,Space+'��������������������������������������������������������������������������������������������������Ĵ');
Writeln(t,Space+'�    �       �        �                             �                �                  �          �');
Writeln(t,Space+'��������������������������������������������������������������������������������������������������Ĵ');
Writeln(t,Space+'�    �       �        �                             �                �                  �          �');
Writeln(t,Space+'��������������������������������������������������������������������������������������������������Ĵ');
Writeln(t,Space+'                                �����:              �                �                  �          �');
Writeln(t,Space+'                                                    ������������������������������������������������');
Writeln(t,Space+' ������⭮� ���_______________________');
Writeln(t);
Writeln(t,Space+'-------------------------------------����� ��१�--------------------------------------------------');
Writeln(t);
Writeln(t,Space+'��ᯨ᪠.�ਭ�� � �஢�થ ��_____________________________����ᮢ� ���� � ',Ak^.DAt.Doc,'/',EditKassa.D);
Writeln(t,Space+'         �� ',FDate,' �. �� �㬬� ___________________________________��.____________���.');
Writeln(t,Space+'��壠��� _____________________________________________');
Writeln(t,Space+'  "_____" ___________________ 20_____�.');
Writeln(t);
Writeln(t,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  Writeln(t,Space+'==================================================================================================');
       close(t);

       ViewAsText(Path.ToTemp+'avans.txt',True);
     end
     else
     begin
     end;
     {Ak^.DAt.Input[Ak^.DAt.Amount+1].Summa:=StrToReal(sSumma);
     Ak^.DAt.Input[Ak^.DAt.Amount+1].Comment:=Comment;
     inc(Ak^.DAt.Amount);
     LockAndWriteKassaAs(EditKassa,Ak);}
     break;
    end;
   end;
  Dispose(Ak,Done);
END;
End;

BEGIN
END.