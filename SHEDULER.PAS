{��६���� ��� ࠧ��饭�� ��⠫��� ��������㥬�� ���}
{client.db}
{make.db}
{barter.db}
{agent.db}
{sklad.db}
{eksped.db - �� �㦭� ���������� ��� �������� ���� RCD : Boolean;}
{group.db  - �� �㦭� ���������� ��� �������� ���� RCD : Boolean;}
{region.db - �� �㦭� ���������� ��� �������� ���� RCD : Boolean;}

{
����� � �᭮���� �ணࠬ�� �� ��� 䠩��
��६���� ��䨪�� ����� ���⮢�� ����⮢
A - ��室�
B - ��८業��
C - client.db
E - make.db
F - barter.db
G - agent.db
H - sklad.db
I - eksped.db
E - group.db
K - region.db
}
{
��६���� ��� ࠧ��饭�� ��⠫��� ��ᯮ�� ��� ������� ��ꥪ�}


{
1.��������� ����室���� 䠩��� p??,k??,eksped,group,region
2.����ᠭ�� ��ࠡ��稪� sheduler.exe
}

Uses Glob,Serv,Servstr,Mail,Utils,
     MsgBox,TpDate,NetCall,Dos,NetDbEng;

{$M 65520,0,655360 }

{��᫥����⥫쭮��� ᫥�����}
{
1.��������㥬 ���� ��������� ��ப�
/1 -������� ��ᯮ�� ��� ᪫��� N 1
/2 -������� ��ᯮ�� ��� ᪫��� N 2
/3 -������� ��ᯮ�� ��� ᪫��� N 3
/4 -������� ��ᯮ�� ��� ᪫��� N 4
/5 -������� ��ᯮ�� ��� ᪫��� N 5
/6 -������� ��ᯮ�� ��� ᪫��� N 6
/7 -������� ��ᯮ�� ��� ᪫��� N 7
/8 -������� ��ᯮ�� ��� ᪫��� N 8
/9 -������� ��ᯮ�� ��� ᪫��� N 9
/10 -������� ��ᯮ�� ��� ᪫��� N 10
/11 -������� ��ᯮ�� ��� ᪫��� N 11
/12 -������� ��ᯮ�� ��� ᪫��� N 12
/13 -������� ��ᯮ�� ��� ᪫��� N 13
/14 -������� ��ᯮ�� ��� ᪫��� N 14
/15 -������� ��ᯮ�� ��� ᪫��� N 15
/CLIENT - ९����樨 �� �����⠬
/MAKE - ९����樨 �� ���⠢騪��
/BARTER - ९����樨 �� ���������⠬
/AGENT - ९����樨 �� ᯨ᪠� �࣮��� �।�⠢�⥫��
/SKLAD - ९����樨 �� ᯨ᪠� ����७��� ���ࠧ�������
/EKSPED - ९����樨 �� ᯨ᪠� ��ᯥ���஢
/GROUP - ९����樨 �� ᯨ᪠� ��㯯
/REGION - ९����樨 �� ᯨ᪠� ॣ�����
/SKLADKOD=01
2.��⠥� ��⠫��� �� ini - 䠩�� sheduler.ini
  ᪠���㥬� ࠡ�稩 ��⠫��
  ���ᨢ [1..CMaxSklads] Of String[CSertif] - ࠧ��饭�� ��⠫���� ��ᯮ��
3.���� ࠡ���
}

Const

 CMaxSklads = 15;
 CMaxTasks = 8;


{������� ����� 䠩�� ��ᯮ��}
{
 P1201060.402 ��室�
 Z1201060.402 ��८業��
 C04450.402   ������
 M04960.103   ���⠢騪�
 B04960.103   �����
 T04960.103   ������
 S04960.103   ᪫��
 E04960.103   ��ᯥ����
 G04960.103   ��㯯�
 R04960.103   ॣ���
 }


 StartClient='CLIENT';{1}
 StartMAke='MAKE';{2}
 StartBarter='BARTER';{3}
 StartAgent='AGENT';{4}
 StartSklad='SKLAD';{5}
 StartEksped='EKSPED';{6}
 StartGroup='GROUP';{7}
 StartRegion='REGION';{8}





Procedure AddLog(Var Log:Text;s:String);
Var j : Word;
Begin
 j:=IoResult;
 WriteLn(Log,
 TodayString(DateMask)+'('+Times+')'+'"'+DayString[DayOfWeek(ToDay)]+'"'+'�'+
 s);
 Writeln('('+Times+') '+s);
 j:=IoResult;
End;




Var
    ReplicationObject: Array [1..CMaxSklads] Of Byte;{�ࠢ����� ��ࠬ��ࠬ� ���������� ��ப�}
    ScanPAth : String[CSertif];{᪠���㥬� ��⠫��}
    TempPAth : String[CSertif];{�६���� ��⠫�� ��। 㯠������}
    ReplicationPath : Array [1..CMaxSklads] Of String;
    ReplicationTasks: Array [1..CMaxTasks] Of Byte;{ᯨ᮪ ����� ��������� ��ࠡ�⪥}
    i,j : Word;
    Cl  : PClientType;
    Gr  : PGroupType;
    Rr  : PRegionType;
    Ini : Text;
    Log : Text;
    FileName : String;
    OutSklad,Pref  : ArtikulStr;



Procedure PackMessages(BakPath,NewPath:String);
Var s1 : String;
    Result : Word;
Begin
  s1:='rar a -m5 -ep -ep1 -av- -inul -ds -y -w'+TempPath+' '+
  NewPath+' '+BakPath+' '+'>NUL';
  DelSpaceRight(s1);
  SWAPVECTORS;
  exec (GetEnv('Comspec'),' /C '+S1);
  Result:=DosError;
  SWAPVECTORS;
  If FExists(NewPath) Then
    AddLog(Log,'�������� '+NewPath+' Ok')
  Else
    AddLog(Log,'�騡�� 㯠����� '+NewPath);
End;

Function GetImportFileNameWithPrefix(Pr,Kod:ArtikulStr):AllStr;
Begin
 GetImportFileNameWithPrefix:=Pr+Kod+OutSklad[1]+'.'+OutSklad[2];
End;

Procedure ReplicationClient(FN:String;Pr:ArtikulStr);
Var f : ClientFileType;
    c : Word;
    Cl : PClientType;
    PoS : LongInt;

Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(ClientType),SizeOf(ClientType));{�।���⥫쭠� �����஢��}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(ClientType),SizeOf(ClientType));
 Until DosError=0;
End;





Procedure ImportClient(Pr:ArtikulStr;Cl:ClientType);
Var ExpF : File Of ClientType;
    c : Word;
    Polush : ArtikulStr;
    j : Word;
Begin
 For j:=1 To CMaxSklads Do
  Begin
   If ReplicationObject[j]=1 Then
    Begin
     Polush:=IntToStr(j,CMantissa);
     RFormatZerro(Polush,CMantissa);
     Assign(ExpF,TempPath{ReplicationPath[j]}+GetImportFileNameWithPrefix(Pr,Cl.Kod)+
     Polush);
     c:=IOResult;
     Rewrite(ExpF);
     c:=IOResult;
     If c<>0 Then
      Begin
       AddLog(Log,'�訡�� ᮧ����� '+{ReplicationPath[j]}TempPath+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush+
	  ' ���:'+IntToSTr(c,CKol));
       Continue;{�����頥��� � For}
      End;
     Cl.Locked:=False;
     Cl.RCD:=False;
     Write(ExpF,Cl);
     c:=IOResult;
     Close(ExpF);
     c:=IOResult;
     PackMessages(TempPath+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush)
    End;{�஢�ઠ �㦭� �� ��ࠡ��뢠�� ��� ������� ��ꥪ�}
  End;{For}
End;{Procedure}


Begin
Assign(f,FN);
c:=IoResult;
Reset(f);
c:=IoResult;
if c<>0 Then
 Begin
  AddLog(Log,'�訡�� ������ '+FN+' ���:'+IntToStr(c,CKol)+' ����� �⫮����!');
  Exit;
 End;
New(Cl,Init);
While Not(Eof(f)) Do
 Begin
  ReadClient(f,Cl^.Dat);
  If Not(Cl^.DAt.Locked) Then
   {If Cl^.Dat.Employ Then}
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'�����㦥� ��ꥪ� '+Cl^.Dat.Kod+' '+Cl^.Dat.Name);
       If (System.Pos('BARTER',FN)>0) Or (System.Pos('MAKE',FN)>0) Then
        Begin
         Cl^.Dat.Name:='��.��������� �����';
         Cl^.Dat.FullName:='��.��������� �����';
         Cl^.Dat.Adress:='��.��������� �����';
         Cl^.Dat.AdressF:='��.��������� �����';
         Cl^.Dat.Telefon:='';
         Cl^.Dat.Gorod:='';
         Cl^.Dat.INN:='';
         Cl^.Dat.Enviropment:='';
         Cl^.Dat.Dogovor:='';
        End;
       ImportClient(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
End;


Procedure ReplicationExtended(FN:String;Pr:ArtikulStr);
Var f : RegionFileType;
    c : Word;
    Cl : PRegionType;
    PoS : LongInt;

Procedure ClearAttribRCD;
Begin
 Seek(f,FilePos(f)-1);
 Pos:=FilePos(f);
 Repeat
  Pause(1);
 Until Lock(f,Pos*SizeOf(RegionType),SizeOf(RegionType));{�।���⥫쭠� �����஢��}
 Cl^.Dat.RCD:=False;
 Write(f,Cl^.DAt);
 Repeat
  Unlock(f,Pos*SizeOf(RegionType),SizeOf(RegionType));
 Until DosError=0;
End;





Procedure ImportRegion(Pr:ArtikulStr;Cl:RegionType);
Var ExpF : File Of RegionType;
    c : Word;
    Polush : ArtikulStr;
    j : Word;
Begin
 For j:=1 To CMaxSklads Do
  Begin
   If ReplicationObject[j]=1 Then
    Begin
     Polush:=IntToStr(j,CMantissa);
     RFormatZerro(Polush,CMantissa);
     Assign(ExpF,TempPath{ReplicationPath[j]}+GetImportFileNameWithPrefix(Pr,Cl.Kod)+
     Polush);
     c:=IOResult;
     Rewrite(ExpF);
     c:=IOResult;
     If c<>0 Then
      Begin
       AddLog(Log,'�訡�� ᮧ����� '+{ReplicationPath[j]}TempPath+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush+
	  ' ���:'+IntToSTr(c,CKol));
       Continue;{�����頥��� � For}
      End;
     Cl.Locked:=False;
     Cl.RCD:=False;
     Write(ExpF,Cl);
     c:=IOResult;
     Close(ExpF);
     c:=IOResult;
     PackMessages(TempPath+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush,
	             ReplicationPath[j]+GetImportFileNameWithPrefix(Pr,Cl.Kod)+Polush)
    End;{�஢�ઠ �㦭� �� ��ࠡ��뢠�� ��� ������� ��ꥪ�}
  End;{For}
End;{Procedure}


Begin
Assign(f,FN);
c:=IoResult;
Reset(f);
c:=IoResult;
if c<>0 Then
 Begin
  AddLog(Log,'�訡�� ������ '+FN+' ���:'+IntToStr(c,CKol)+' ����� �⫮����!');
  Exit;
 End;
New(Cl,Init);
While Not(Eof(f)) Do
 Begin
  ReadRegion(f,Cl^.Dat);
  If Not(Cl^.DAt.Locked) Then
   {If Cl^.Dat.Employ Then}
    If Cl^.DAt.RCD Then
      Begin
       ClearAttribRCD;
       AddLog(Log,'�����㦥� ��ꥪ� '+Cl^.Dat.Kod);
       ImportRegion(Pr,Cl^.DAt);
      End;
 End;
c:=IoResult;
Close(f);
c:=IoResult;
End;





(*************    � � � � � � � �    � � � � � � � � �        ***********)
Begin
 j:=1;
 For j:=1 To CMaxSklads Do
  Begin
   If FindParam('/'+WordToMyHex(j)) Then ReplicationObject[j]:=1
   Else
   ReplicationObject[j]:=0;
  End;



 {横� ����ன�� �� ��ࠡ��뢠��� �����}
 For j:=1 To CMaxTasks Do
  Begin
   ReplicationTasks[j]:=0;
  End;

 If FindParam(StartClient) Then ReplicationTasks[1]:=1;{client}
 If FindParam(StartMake)   Then ReplicationTasks[2]:=1;{make}
 If FindParam(StartBarter) Then ReplicationTasks[3]:=1;{barter}
 If FindParam(StartAgent)  Then ReplicationTasks[4]:=1;{agent}
 If FindParam(StartSklad)  Then ReplicationTasks[5]:=1;{Sklad}
 If FindParam(StartEksped) Then ReplicationTasks[6]:=1;{eksped}
 If FindParam(StartGroup)  Then ReplicationTasks[7]:=1;{group}
 If FindParam(StartRegion) Then ReplicationTasks[8]:=1;{region}

 Assign(Log,'sheduler.log');
 j:=IoResult;
 Append(Log);
 j:=IoResult;
 If j<>0 Then
  Begin
   {SpecialBeep;}
   Writeln('�訡�� ������ ���-䠩��');
   Rewrite(Log);
   j:=IoResult;
   If j<>0 Then
    Begin
     {SpecialBeep;}
     Writeln('�訡�� ᮧ����� ���-䠩��');
    End;
  End;


 Assign(Ini,'sheduler.ini');
 j:=IoResult;
 Reset(Ini);
 j:=IoResult;
 If j<>0 Then
  Begin
   {SpecialBeep;}
   Writeln('�訡�� ������ ini-䠩��');
   AddLog(Log,'�訡�� ������ ini-䠩��');
   AddLog(Log,'���਩��� �����襭��');
   j:=IoResult;
   Close(Log);
   j:=IoResult;
   Exit;
  End;

 Readln(Ini,ScanPAth);{�⠥� ��⠫�� ᪠��஢����}
 Readln(Ini,TempPAth);{�⠥� ��⠫�� ᪠��஢����}
 Readln(Ini,OutSklad);{�⠥� ��� ᪫��� - ��ࠢ�⥫�}
 OutSklad:=IntToStr(StrToInt(OutSklad),CMantissa);
 RFormatZerro(OutSklad,CMantissa);

 For j:=1 To CMaxSklads Do
  Begin
   Readln(Ini,ReplicationPath[j]);
   I:=IoResult;
  End;
 I:=IoResult;
 Close(Ini);
 I:=IoResult;{�����⨥ ini 䠩��}



 {横� �᭮���� ࠡ���}
 AddLog(Log,'���� ᥠ�� ��ࠡ�⪨');

 {横� �� ����砬}
 For j:=1 To CMaxTasks Do
  BEgin
   If ReplicationTasks[j]=1 Then{�஢��塞 ����室������ ��ࠡ�⪨}
    Begin
     Case j Of
     1:Begin
	   fileName:=ScanPath+StartClient+'.db';
        Pref:=ClientPrefix;
        AddLog(Log,'��ࠡ�⪠ ����� '+StartClient+' ('+FileName+')');
        ReplicationClient(FileName,Pref);
       End;
     2:Begin
       Pref:=MakePrefix;
	  fileName:=ScanPath+StartMAke+'.db';
       AddLog(Log,'��ࠡ�⪠ ����� '+StartMake+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;
     3:Begin
	  fileName:=ScanPath+StartBarter+'.db';
       Pref:=BarterPrefix;
       AddLog(Log,'��ࠡ�⪠ ����� '+StartBarter+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;
     4:Begin
	  fileName:=ScanPath+StartAgent+'.db';
       Pref:=AgentPrefix;
       AddLog(Log,'��ࠡ�⪠ ����� '+StartAgent+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;
     5:Begin
	  fileName:=ScanPath+StartSklad+'.db';
       Pref:=SkladPrefix;
       AddLog(Log,'��ࠡ�⪠ ����� '+StartSklad+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;
     6:Begin
	  fileName:=ScanPath+StartEksped+'.db';
       Pref:=EkspeditorPrefix;
       AddLog(Log,'��ࠡ�⪠ ����� '+StartEksped+' ('+FileName+')');
       ReplicationClient(FileName,Pref);
       End;
     7:Begin
	  fileName:=ScanPath+StartGroup+'.db';
       Pref:=GroupPrefix;
       AddLog(Log,'��ࠡ�⪠ ����� '+StartGroup+' ('+FileName+')');
       ReplicationExtended(FileName,Pref);
       End;
     8:Begin
	  fileName:=ScanPath+StartRegion+'.db';
       Pref:=RegionPrefix;
       AddLog(Log,'��ࠡ�⪠ ����� '+StartRegion+' ('+FileName+')');
       ReplicationExtended(FileName,Pref);
       End;
     Else
	  Begin
        AddLog(Log,'��ࠡ��뢥��� ����� �� ��।�����');
        I:=IoResult;
        Close(Log);
        I:=IoResult;
	   Exit;
       End;{��⪠ Else � Case}
    End;{Case}
   End;{�஢��塞 ����室������ �믮������ �����}
  End;{横� �� ����砬}




 AddLog(Log,'�����襭�� ᥠ�� ��ࠡ�⪨');
 {����� 横�� �᭮���� ࠡ���}

 I:=IoResult;
 Close(Log);
 I:=IoResult;


End.