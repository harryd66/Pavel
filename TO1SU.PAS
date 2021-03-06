{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit to1su;


{$M 65520,0,655360 }

interface

Uses Glob,Serv,Servstr,Mail,Utils,Utils4,Utils5,
     Objects,StHolder,Protect,
     Dialogs,DBIII,TpDate,NetCall,Dos,NetDbEng;


Const

 CMaxTasks = 13;

StartOpt='OPT';
StartRozn='ROZN';
StartPrihod='PRIHOD';
StartReturn='RETURN';
StartInternal='INTERNAL';
StartCLIENT='CLIENT';
StartMake='MAKE';{11}
StartBarter='BARTER';{12}
StartVeksel='VEKSEL';
StartKassa='KASSA';
StartTest='RUNTEST';


Const
 KurzSklad : array[1..30] of Char=('1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K',
 {21 22  23   24  25  26  27  28  29  30}
 'L','M','N','O','P','Q','R','S','T','U');


Type PathTaskElement = Record
ObjectName   : TMyString;
PathToKassa  : TMyString;
PathToPrihod : TMyString;
PathToRazdel : TMyString;
PathToSklad  : TMyString;
PathToId     : TMyString;
PathToClient : TMyString;
PathToMarket : TMyString;
PathToReturn : TMyString;
PathToOplata : TMyString;
PathToDolg   : TMyString;
CalcAkzis    : Word;
ShemaAkzis   : Word;
VidZakupka   : Word;
ExternalPrihod:Word;
VirtualPrihod :Word;
End;



Var Starting : Boolean;
    ClientDolgList,AgentDolgList : PBox;
    R:TRect;

Var OldFileMode : Word;
    EDate : TMyString;
    Base : DBase3;
    LogFile :Text;


Type SkladTask =Record
     Task : Array [1..CMaxSklads] Of PathTaskElement;
     PathToExport:TMyString;
     PathToClientLst:TMyString;
     DeltaDate:Integer;
     RoznizaClientPrefix:TMyString;
     BufferSkladKod : Word;
     AkzisKoeff: Array[0..8] Of String[CDAte];
     End;





Function GetBuchKod(Kod:Word;Vid:Word;ClKod:ArtikulStr):AllStr;
Function GetClient(Kod:Word;Var Cl : PClientType):Boolean;
Function GetMake(Kod:Word;Var Cl : PClientType):Boolean;
Function GetBarter(Kod:Word;Var Cl : PClientType):Boolean;
Function GetIDField(Ind:Word;Field:Word;C:ArtikulStr):TEnjoyStr;
Procedure AddLog(Var LogFile:Text;s:String);
Procedure ReadNewIni(Var f : text;Var Res : LongInt);
Procedure ClearIni;
Function ClearChar(S : AllStr):AllStr;
Procedure ShowHelp;
Procedure ImportClient(Kod:Word);
Procedure ImportMake(Kod:Word);
Procedure ImportBarter(Kod:Word);



Var
    ReplicationObject: Array [1..CMaxSklads] Of Byte;{�ࠢ����� ��ࠬ��ࠬ� ���������� ��ப�}
    IndexTasks: Array [1..CMaxTasks] Of Byte;{ᯨ᮪ ����� ��������� ��ࠡ�⪥}
    i,j : Word;
    Res : LongInt;
    Ini : Text;
    FileName : String;
    III : SkladTask;




implementation

Function ClearChar(S : AllStr):AllStr;
Var i,j : Word;
    ss  : TDateString;
Begin
j:=1;
ss[0]:=#0;
For i := 1 To Ord(S[0]) Do
 If s[i] in ['1','2','3','4','5','6','7','8','9','0'] Then
  Begin
   ss[j]:=s[i];
   ss[0]:=Chr(j);
   Inc(j);
  End;
ClearChar:=ss;
End;



Procedure AddLog(Var LogFile:Text;s:String);
Var j : Word;
Begin
 j:=IoResult;
 WriteLn(LogFile,
 TodayString(DateMask)+'('+Times+')'+'"'+DayString[DayOfWeek(ToDay)]+'"'+'�'+
 s);
 j:=IoResult;
 Writeln('('+Times+') '+s);
 j:=IoResult;
End;






Function GetBuchKod(Kod:Word;Vid:Word;ClKod:ArtikulStr):AllStr;
Var f : ClientFileType;
    l : LongInt;
    s : ClientType;
    st : ArtikulStr;
    c,Code : Integer;
    ss : AllStr;
    cl : PClientType;
Begin
 GetBuchKod:='9999';
 FileMode:=66;
 Case Vid Of
 0:Assign (f,III.Task[Kod].PathToClient+'client.db');
 1:Assign (f,III.Task[Kod].PathToClient+'sklad.db');
 2:Assign (f,III.Task[Kod].PathToClient+'barter.db');
 Else exit;
 End;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  AddLog(LogFile,'�訡�� ������ 䠩�� �����⮢ ��� ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(l,CKol));
  Exit;
 End
 Else
  Begin
   New(Cl,Init);
   Cl^.DAt.Kod:=ClKod;
   DelSpace(Cl^.DAt.Kod);
   l:=StrToInt(Cl^.DAt.Kod);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     c:=IOResult;
     AddLog(LogFile,'����⪠ �⥭�� ������ '+Cl^.DAt.Kod+' - ������ ��� 䠩��! ������:'+
	IntToStr(l,CKol)+'('+IntToStr(FileSize(f),CKol)+')');
     Exit;
    End;

   Seek(f,l);
   l:=IOResult;
   ReadClient(f,Cl^.DAt);
   l:=IOResult;
   Close(f);
   l:=IOResult;
   RFormatZerro(Cl^.Dat.BuchKod,CClientKod);
   GetBuchKod:=Cl^.Dat.BuchKod;
   If Not(Cl^.Dat.Employ) Then GetBuchKod:='????';
   Dispose(Cl,Done);
  End;
End;



Function GetClient(Kod:Word;Var Cl : PClientType):Boolean;
Label 3;
Var f : ClientFileType;
    l : LongInt;
    s : ClientType;
    st : ArtikulStr;
    c,Code : Integer;
    ss : AllStr;
Begin
 GetClient:=False;
 FileMode:=66;
 Assign (f,III.Task[Kod].PathToClient+'client.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  AddLog(LogFile,'�訡�� ������ 䠩�� �����⮢ ��� ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(l,CKol));
  {Writeln('�訡�� ������ 䠩�� �����⮢ ��� ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(l,CKol));}
  Exit;
 End
 Else
  Begin
  3:
   DelSpace(Cl^.DAt.Kod);
   l:=StrToInt(Cl^.DAt.Kod);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     c:=IOResult;
     AddLog(LogFile,'����⪠ �⥭�� ������ '+Cl^.DAt.Kod+' - ������ ��� 䠩��! ������:'+
	IntToStr(l,CKol)+'('+IntToStr(FileSize(f),CKol)+')');
     {
	Writeln('����⪠ �⥭�� ������ '+Cl^.DAt.Kod+' - ������ ��� 䠩��! ������:'+
	IntToStr(l,CKol)+'('+IntToStr(FileSize(f),CKol)+')');
     }
     Exit;
    End;

   Seek(f,l);
   l:=IOResult;
   ReadClient(f,Cl^.DAt);
   l:=IOResult;

   If StrToInt(Cl^.Dat.Kod)<>StrToInt(Cl^.Dat.BuchKod) Then
    Begin
     AddLog(LogFile,'��७��ࠢ����� ������ �� ���� 1� '+Cl^.Dat.Kod+' --> '+Cl^.Dat.BuchKod);
     Cl^.DAt.Kod:=Cl^.DAt.BuchKod;
     DelSpace(Cl^.DAt.Kod);
     goto 3;
    End;


   Close(f);
   l:=IOResult;
  End;

  If Not(Cl^.Dat.Employ) Then Cl^.Dat.Name:='!!!������ ������!!!';

  GetClient:=True;

End;

Function GetMake(Kod:Word;Var Cl : PClientType):Boolean;
Var f : ClientFileType;
    l : LongInt;
    s : ClientType;
    st : ArtikulStr;
    c,Code : Integer;
    ss : AllStr;
Begin
 GetMake:=False;
 FileMode:=66;
 Assign (f,III.Task[Kod].PathToClient+'make.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  AddLog(LogFile,'�訡�� ������ 䠩�� ���⠢騪�� ��� ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(l,CKol));
  Exit;
 End
 Else
  Begin
   DelSpace(Cl^.DAt.Kod);
   l:=StrToInt(Cl^.DAt.Kod);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     c:=IOResult;
     AddLog(LogFile,'����⪠ �⥭�� ���⠢騪� '+Cl^.DAt.Kod+' - ������ ��� 䠩��! ������:'+
	IntToStr(l,CKol)+'('+IntToStr(FileSize(f),CKol)+')');
     {
	Writeln('����⪠ �⥭�� ������ '+Cl^.DAt.Kod+' - ������ ��� 䠩��! ������:'+
	IntToStr(l,CKol)+'('+IntToStr(FileSize(f),CKol)+')');
     }
     Exit;
    End;

   Seek(f,l);
   l:=IOResult;
   ReadClient(f,Cl^.DAt);
   l:=IOResult;
   Close(f);
   l:=IOResult;
  End;

  If Not(Cl^.Dat.Employ) Then Cl^.Dat.Name:='!!!��������� ������!!!';

  GetMake:=True;

End;




Function GetBarter(Kod:Word;Var Cl : PClientType):Boolean;
Var f : ClientFileType;
    l : LongInt;
    s : ClientType;
    st : ArtikulStr;
    c,Code : Integer;
    ss : AllStr;
Begin
 GetBarter:=False;
 FileMode:=66;
 Assign (f,III.Task[Kod].PathToClient+'barter.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  AddLog(LogFile,'�訡�� ������ 䠩�� ���⠢騪�� �� ���������⠬ ��� ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+
  IntToStr(l,CKol));
  Exit;
 End
 Else
  Begin
   DelSpace(Cl^.DAt.Kod);
   l:=StrToInt(Cl^.DAt.Kod);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     c:=IOResult;
     AddLog(LogFile,'����⪠ �⥭�� ���⠢騪� �� ���������⠬ '+Cl^.DAt.Kod+' - ������ ��� 䠩��! ������:'+
	IntToStr(l,CKol)+'('+IntToStr(FileSize(f),CKol)+')');
     {
	Writeln('����⪠ �⥭�� ������ '+Cl^.DAt.Kod+' - ������ ��� 䠩��! ������:'+
	IntToStr(l,CKol)+'('+IntToStr(FileSize(f),CKol)+')');
     }
     Exit;
    End;

   Seek(f,l);
   l:=IOResult;
   ReadClient(f,Cl^.DAt);
   l:=IOResult;
   Close(f);
   l:=IOResult;
  End;

  If Not(Cl^.Dat.Employ) Then Cl^.Dat.Name:='!!!���������2 ������!!!';

  GetBArter:=True;

End;




Function GetIDField(Ind:Word;Field:Word;C:ArtikulStr):TEnjoyStr;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    OldFileMode : Word;
    FId  : BazFileType;
    Id   : PBazType;
Begin
 GetIdField[0]:=#0;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fId,III.Task[Ind].PathToID+c+'.id');
 GetIdField[0]:=#0;
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  AddLog(LogFile,'�訡�� ������ '+III.Task[Ind].PathToID+c+'.id ��� ��ꥪ�'+IntToSTr(Ind,2)+
  ' ���:'+IntToStr(l,CKol));
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);

   If l>FileSize(fid) Then
    Begin
     System.Close(fid);
     l:=IOResult;
     {MessageBox(^M+#3'����⪠ �⥭�� ���� ������������ ('+st+') '+c+' - ������ ��� 䠩��!',nil,mfError+mfCancelButton);}
     AddLog(LogFile,'����⪠ �⥭�� ���� ������������ ('+st+') '+c+' - ������ ��� 䠩��!'+
	' ��� ��ꥪ� '+IntToSTr(Ind,2));
     Exit;
    End;

   Seek(fid,L);
   New(id,Init);
   Code:=IOResult;
   ReadBazPointer(FId,Id);
   Close(fid);
   Case Field Of
  FFFName:Begin
           DelSpaceRight(Id^.Dat.Name);
           DelSpaceRight(Id^.Dat.Name2);
           GetIdField:=Id^.Dat.Name+' '+Id^.Dat.Name2;
          End;

  FName:GetIdField:=Id^.Dat.Name;
  FName2:GetIdField:=Id^.Dat.Name2;
  FFName:GetIdField:=Id^.Dat.Name;
  FFName2:GetIdField:=Id^.Dat.Name2;

  FLitr:Begin
         GetIdField:=Id^.Dat.Litr;
        End;
  FMAssa:GetIdField:=Id^.Dat.Massa;

  FEnableContract : GetIdField:=IntToStr(Id^.Dat.EnableContract,COne);
  FContractNumer : GetIdField:=Id^.Dat.Contract;
  FContractDate  : GetIdField:=Id^.Dat.ContractDate;

  FInPack:GetIdField:=Id^.Dat.InPack;
  FOperator:GetIdField:=Id^.Dat.CAption;
  FKtoSertif:GetIdField:=Id^.Dat.KSertif;
  FDateSertif:GetIdField:=Id^.Dat.DSertif;
  FEnableSklads:GetIdField:=IntToStr(Id^.Dat.EnableSklads,CKol);

  FNalog:GetIdField:=Id^.Dat.Nalog;
  FVidNalog:Begin
             Str(Id^.Dat.VidNalog:COne,St);
             DelSpace(St);
             GetIdField:=St;
            End;

  FMain :Begin
          Str(Id^.Dat.Main:COne,St);
          DelSpace(St);
          GetIdField:=St;
         End;
  FFantomKod:
     Begin
      RFormatZerro(Id^.Dat.Mera,CClientKod);
	 GetIdField:=Id^.Dat.FantomKod;
     End;

  FNDS     :GetIdField:=Id^.Dat.NDS;
  FVidNDS  :Begin
             Str(Id^.Dat.VidNDS:COne,St);
             DelSpace(St);
             GetIdField:=St;
            End;
  FOrganization :Begin
             {
             Str(Id^.Dat.Organization:COne,St);
             DelSpace(St);
             GetIdField:=St;
             }
            End;
{$IfDEF Tara}
  FFEnable :Begin
             Str(Id^.Dat.FantomEnable:COne,St);
             DelSpace(St);
             GetIdField:=St;
            End;
  FFKod    :GetIdField:=Id^.Dat.FantomKod;
  FFInPack :GetIdField:=Id^.Dat.FantomInPack;
{$EndIF}

  FBuchGroup:GetIdField:=IntToStr(Id^.Dat.BuchGroup,COne);
  FGroup,
  FNGroupKod:GetIdField:=Id^.Dat.NGroupKod;
  FEtil     :GetIdField:=Id^.Dat.Etil;
  FMera    : Begin
             st:=Id^.Dat.Mera;
             RFormatZerro(Id^.Dat.Mera,CClientKod);
             DelSpaceRight(St);
             GetIdField:=St;
            {0Case Id^.Dat.Mera Of
              0:st:='��';
              1:st:='��';
              2:st:='��';
              3:st:='� ';
              4:st:='��';
              5:st:='��';
              Else St:='??';
              End;{Case}
             { GetIdField:=St;}
             End;
   Else;
   End;{CAse}
  End;
  If Not(Id^.Dat.Employ) And (Field in [FFName,FNAme]) Then GetIDField:='!!!����� ������!!!';
End;



Procedure ClearIni;
VAr c : Word;
Begin
III.PathToExport[0]:=#0;
III.PathToClientLst[0]:=#0;
III.DeltaDate:=0;
III.RoznizaClientPrefix:='7000';
III.BufferSkladKod:=99;
III.AkzisKoeff[0,0]:=#0;
III.AkzisKoeff[1,0]:=#0;
III.AkzisKoeff[2,0]:=#0;
III.AkzisKoeff[3,0]:=#0;
III.AkzisKoeff[4,0]:=#0;
III.AkzisKoeff[5,0]:=#0;
III.AkzisKoeff[6,0]:=#0;
III.AkzisKoeff[7,0]:=#0;
III.AkzisKoeff[8,0]:=#0;

For c:=1 To CMaxSklads Do
Begin
III.Task[c].ObjectName[0]:=#0;
III.Task[c].PathToRazdel [0]:=#0;
III.Task[c].PathToPrihod [0]:=#0;
III.Task[c].PathToKassa [0]:=#0;
III.Task[c].PathToSklad  [0]:=#0;
III.Task[c].PathToId     [0]:=#0;
III.Task[c].PathToClient[0]:=#0;
III.Task[c].PathToDolg[0]:=#0;
III.Task[c].PathToMarket[0]:=#0;
III.Task[c].PathToReturn[0]:=#0;
III.Task[c].PathToOplata[0]:=#0;
III.Task[c].CalcAkzis:=0;
III.Task[c].ShemaAkzis:=0;
III.Task[c].VidZakupka:=0;{0 ��ࢠ� 1-����}
III.Task[c].VirtualPrihod:=0;{0 ��ࢠ� 1-����}
III.Task[c].ExternalPrihod:=0;{0 ��ࢠ� 1-����}
End;
End;


Procedure ReadNewIni(Var f : text;Var Res : LongInt);
Var i : Byte;
    c : Byte;
    SH: TStringHolder;

Function GetAsString(Name:AllStr):String;
Begin
GetAsString[0]:=#0;
GetAsString:=SH.GetString (Name);
End;

Function GetAsInteger(Name:AllStr):LongInt;
Begin
GetAsInteger:=0;
GetAsInteger:=StrToInt(SH.GetString (Name));
End;

Begin
Assign (f,'to1s.ini');
Res := IOResult;
Reset(f);
Res := IOResult;
If Res <> 0 Then Exit;
Close(f);
Res := IOResult;
SH.Init;
SH.LoadFromFile ('to1s.ini');

III.PathToClientLst:=GetAsString('PathToClientLst');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.PathToExport:=GetAsString('PathToExport');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.DeltaDate:=GetAsInteger('DeltaDate');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.BufferSkladKod:=GetAsInteger('BufferSkladKod');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


III.RoznizaClientPrefix:=GetAsString('RoznizaClientPrefix');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

For c:=0 To 8 Do
Begin
III.AkzisKoeff[c]:=GetAsString('AkzisKoeff['+IntToStr(c,CMantissa)+']');
{Writeln(III.AkzisKoeff[c]);}
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;
End;

For c:=1 To CMaxSklads Do
Begin
III.Task[c].ObjectName:=GetAsString('ObjectName['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToKassa:=GetAsString('PathToKassa['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToPrihod:=GetAsString('PathToPrihod['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToClient:=GetAsString('PathToClient['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].CalcAkzis:=GetAsInteger('CalcAkzis['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].ShemaAkzis:=GetAsInteger('ShemaAkzis['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].VidZakupka:=GetAsInteger('VidZakupka['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].ExternalPrihod:=GetAsInteger('ExternalPrihod['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].VirtualPrihod:=GetAsInteger('VirtualPrihod['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToMarket:=GetAsString('PathToMarket['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


III.Task[c].PathToReturn:=GetAsString('PathToReturn['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToOplata:=GetAsString('PathToOplata['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToDolg:=GetAsString('PathToDolg['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToRAzdel:=GetAsString('PathToRazdel['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToSklad:=GetAsString('PathToSklad['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III.Task[c].PathToId:=GetAsString('PathToId['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


End;
SH.Done;
End;



Procedure ShowHelp;
Begin
Writeln('�⨫�� ��ᯮ�� � 1� '+CompileDate);
Writeln('���� ���䨣��樨 to1s.ini');
Writeln('��ࠢ����� ᫥���騬� ��ࠬ��ࠬ� ���������� ��ப�:');
Writeln('/1 - ������� �����ਭ� ��������� ��� ᪫��� N 1');
Writeln('/2 - ��� ᪫��� N 2   /3 - ��� ᪫��� N 3');
Writeln('/4 - ��� ᪫��� N 4   /5 - ��� ᪫��� N 5');
Writeln('/6 - ��� ᪫��� N 6   /7 - ��� ᪫��� N 7');
Writeln('/8 - ��� ᪫��� N 8   /9 - ��� ᪫��� N 9');
Writeln('/A - ��� ᪫��� N 10  /B - ��� ᪫��� N 11');
Writeln('/C - ��� ᪫��� N 12  /D - ��� ᪫��� N 13');
Writeln('/E - ��� ᪫��� N 14  /F - ��� ᪫��� N 15');
Writeln('/G - ��� ᪫��� N 16  /H - ��� ᪫��� N 17');
Writeln('/I - ��� ᪫��� N 18  /J - ��� ᪫��� N 19');
Writeln('/K - ��� ᪫��� N 20  /L - ��� ᪫��� N 21');
Writeln('/M - ��� ᪫��� N 22  /N - ��� ᪫��� N 23');
Writeln('/O - ��� ᪫��� N 24  /P - ��� ᪫��� N 25');
Writeln('/Q - ��� ᪫��� N 26  /R - ��� ᪫��� N 27');
Writeln('/S - ��� ᪫��� N 28  /T - ��� ᪫��� N 29');
Writeln('/U - ��� ᪫��� N 30');
Writeln('DECDATE=   - �⪫������ �� ⥪�饩 ���� +/- (�⪫�砥��� ���祬 OUTDATE=)');
Writeln('OPT        - ������ ��⮢�� ॠ�����');
Writeln('ROZN       - ������ ஧��筮� ॠ����樨');
Writeln('RETURN     - ������ �����⮢');
Writeln('INTERNAL   - ������ ���᪫��᪨� ��ॢ����');
Writeln('CLIENT     - ������ �ࠢ�筨�� �����⮢');
Writeln('MAKE       - ������ �ࠢ�筨�� ���⠢騪��');
Writeln('BARTER     - ������ �ࠢ�筨�� ���⠢騪�� �� ���������⠬');
Writeln('VEKSEL     - ������ ���ᥫ��');
Writeln('KASSA      - ������ ���ᮢ�� ����権');
Writeln('LITR       - �ந������� ���� � �����');
Writeln('ZAKUPKAKOL - � �㡫��');
Writeln('             ���� � ��㪠�');
Halt;
End;




Procedure ImportClient(Kod:Word);
Var c : Word;
    P : PClientType;
    f : Text;
    SClientKod,
     SKod,
     SDate: AllStr;
    NDS20,
    NDS18,
    NDS10,
    NDS_,
    Litr20,
    Litr18,
    Litr10,
    Litr_,
    ZakupkaOutNDS20,
    ZakupkaOutNDS18,
    ZakupkaOutNDS10,
    ZakupkaOutNDS_,
    NDSZ20,
    NDSZ18,
    NDSZ10,
    NDSZ_,
    Opl20,
    Opl18,
    Opl10,
    Opl_,
    Akzis:Real;
    S : String;
Begin

If Not fExists(III.Task[Kod].PathToClient+'client.db') Then
 Begin
   {
   Writeln('��� ������ ��� ��ᯮ�� '+III.Task[Kod].PathToClient+'client.db'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa));
   }
   AddLog(LogFile,'��� ������ ��� ��ᯮ�� '+III.Task[Kod].PathToClient+'client.db'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa));
   Exit;
 End;


If Not fExists(III.PathToExport+'c'+EDate+'.dbf') Then
Begin
with Base do
begin
 Assign(III.PathToExport+'c'+EDate+'.dbf'); {�p�᢮��� �� ���}
 Init; {�����⮢����� � ᮧ����� ��}
 AddField('CLIENTKOD','C',8,0);{��� ������}
 AddField('LIZO','N',1,0);{1-䨧��᪮� ��� 0 -�ਤ��᪮� ���}
 AddField('FULLNAME','C',50,0);{������ �ਤ��᪮� ��������}
 AddField('NAME','C',20,0);{��������}
 AddField('UADRES','C',50,0);{�ਤ��᪨� ����}
 AddField('FADRES','C',50,0);{䠪��᪨� ����}
 AddField('TELEFON','C',50,0);{⥫�䮭}
 AddField('INN','C',30,0);{���}

      if Create then
         Open(ReadWrite)
      else
     begin
      {
      Writeln('�訡�� ᮧ����� '+III.PathToExport+'c'+EDate+
	 '.dbf'+' � ��ꥪ� '+IntToStr(Kod,CMantissa));
      }
      AddLog(LogFile,'�訡�� ᮧ����� '+III.PathToExport+'c'+EDate+
	 '.dbf'+' � ��ꥪ� '+IntToStr(Kod,CMantissa));
      exit;
     end;

  AddLog(LogFile,'�������� ���� ������ '+III.PathToExport+'c'+EDate+'.dbf'+' �ᯥ譮 �����襭�');

c:=IOResult;
     Close;
c:=IOResult;
End;{With Base}
End;

 Assign(f,III.PathToClientLst+'client.lst');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('��� ������ ��� ��ᯮ�� �訡�� ������ '+'client.lst'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'��� ������ ��� ��ᯮ�� '+III.PathToClientLst+'client.lst'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(c,CMantissa));
   Exit;
  End;

 Base.Assign(III.PathToExport+'c'+EDate+'.dbf');
 c:=IOResult;
 Base.Open(ReadWrite);
 c:=IOResult;
 If c<>0 Then
  Begin
   Close(f);
   c:=IOResult;
   {
   Writeln('�訡�� ������ '+III.PathToExport+'c'+EDate+'.dbf'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,III.PathToExport+'c'+EDate+'.dbf'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(c,CMantissa));
   Exit;
  End;

{����� ��⠢��� ��� ������ �����⮢}

 While Not(SeekEof(f)) Do
  Begin
   Readln(f,s);
   DelSpace(s);
   RFormatZerro(s,CClientKod);
   New(P,Init);
   P^.Dat.Kod:=S;

   If GetClient(Kod,P) Then
     With Base Do
      Begin
       Append; {�������� ����� ������}
      s:=P^.Dat.BuchKod;
      RFormatZerro(s,8);
      WriteStr('CLIENTKOD',S);{��� ������}
      WriteNum('LIZO',P^.Dat.LIZO);{1-䨧��᪮� ��� 0 -�ਤ��᪮� ���}
      WriteStr('FULLNAME',P^.Dat.FULLNAme);{������ �ਤ��᪮� ��������}
      WriteStr('NAME',P^.Dat.NAme);{��������}
      WriteStr('UADRES',P^.Dat.Adress);{�ਤ��᪨� ����}
      WriteStr('FADRES',P^.Dat.AdressF);{䠪��᪨� ����}
      WriteStr('TELEFON',P^.Dat.Telefon);{⥫�䮭}
      WriteStr('INN',P^.Dat.INN);{���}
      End;

   Dispose(p,Done);
  End;{Eof(f)}


c:=IOResult;
 Close(f);  {�����⨥ ⥪�⮢���}
c:=IOResult;
Erase(f);
c:=IOResult;

c:=IOResult;
 Base.Close;{�����⨥ DBF}
c:=IOResult;
  AddLog(LogFile,'������ �����⮢ '+FDate+' ��� ��ꥪ� '+IntToStr(Kod,CMantissa)+' �ᯥ譮 �����襭');
End;



Procedure ImportMake(Kod:Word);
Var c : Word;
    P : PClientType;
    f : Text;
    SClientKod,
     SKod,
     SDate: AllStr;
    NDS20,
    NDS18,
    NDS10,
    NDS_,
    Litr20,
    Litr18,
    Litr10,
    Litr_,
    ZakupkaOutNDS20,
    ZakupkaOutNDS18,
    ZakupkaOutNDS10,
    ZakupkaOutNDS_,
    NDSZ20,
    NDSZ18,
    NDSZ10,
    NDSZ_,
    Opl20,
    Opl18,
    Opl10,
    Opl_,
    Akzis:Real;
    S : String;
Begin

If Not fExists(III.Task[Kod].PathToClient+'make.db') Then
 Begin
   {
   Writeln('��� ������ ��� ��ᯮ�� '+III.Task[Kod].PathToClient+'client.db'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa));
   }
   AddLog(LogFile,'��� ������ ��� ��ᯮ�� '+III.Task[Kod].PathToClient+'make.db'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa));
   Exit;
 End;


If Not fExists(III.PathToExport+'s'+EDate+'.dbf') Then
Begin
with Base do
begin
 Assign(III.PathToExport+'s'+EDate+'.dbf'); {�p�᢮��� �� ���}
 Init; {�����⮢����� � ᮧ����� ��}
 AddField('CLIENTKOD','C',8,0);{��� ������}
 AddField('LIZO','N',1,0);{1-䨧��᪮� ��� 0 -�ਤ��᪮� ���}
 AddField('FULLNAME','C',50,0);{������ �ਤ��᪮� ��������}
 AddField('NAME','C',20,0);{��������}
 AddField('UADRES','C',50,0);{�ਤ��᪨� ����}
 AddField('FADRES','C',50,0);{䠪��᪨� ����}
 AddField('TELEFON','C',50,0);{⥫�䮭}
 AddField('INN','C',30,0);{���}

      if Create then
         Open(ReadWrite)
      else
     begin
      {
      Writeln('�訡�� ᮧ����� '+III.PathToExport+'c'+EDate+
	 '.dbf'+' � ��ꥪ� '+IntToStr(Kod,CMantissa));
      }
      AddLog(LogFile,'�訡�� ᮧ����� '+III.PathToExport+'s'+EDate+
	 '.dbf'+' � ��ꥪ� '+IntToStr(Kod,CMantissa));
      exit;
     end;

  AddLog(LogFile,'�������� ���� ������ '+III.PathToExport+'s'+EDate+'.dbf'+' �ᯥ譮 �����襭�');

c:=IOResult;
     Close;
c:=IOResult;
End;{With Base}
End;

 Assign(f,III.PathToClientLst+'Make.lst');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('��� ������ ��� ��ᯮ�� �訡�� ������ '+'client.lst'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'��� ������ ��� ��ᯮ�� '+III.PathToClientLst+'Make.lst'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(c,CMantissa));
   Exit;
  End;

 Base.Assign(III.PathToExport+'s'+EDate+'.dbf');
 c:=IOResult;
 Base.Open(ReadWrite);
 c:=IOResult;
 If c<>0 Then
  Begin
   Close(f);
   c:=IOResult;
   {
   Writeln('�訡�� ������ '+III.PathToExport+'c'+EDate+'.dbf'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,III.PathToExport+'s'+EDate+'.dbf'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(c,CMantissa));
   Exit;
  End;

{����� ��⠢��� ��� ������ �����⮢}

 While Not(SeekEof(f)) Do
  Begin
   Readln(f,s);
   DelSpace(s);
   RFormatZerro(s,CClientKod);
   New(P,Init);
   P^.Dat.Kod:=S;

   If GetMake(Kod,P) Then
     With Base Do
      Begin
       Append; {�������� ����� ������}
      s:=P^.Dat.BuchKod;
      RFormatZerro(s,7);
      s:='8'{��䨪� ��몭������� ���⠢騪��}+s;
      WriteStr('CLIENTKOD',S);{��� ������}
      WriteNum('LIZO',P^.Dat.LIZO);{1-䨧��᪮� ��� 0 -�ਤ��᪮� ���}
      WriteStr('FULLNAME',P^.Dat.FULLNAme);{������ �ਤ��᪮� ��������}
      WriteStr('NAME',P^.Dat.NAme);{��������}
      WriteStr('UADRES',P^.Dat.Adress);{�ਤ��᪨� ����}
      WriteStr('FADRES',P^.Dat.AdressF);{䠪��᪨� ����}
      WriteStr('TELEFON',P^.Dat.Telefon);{⥫�䮭}
      WriteStr('INN',P^.Dat.INN);{���}
      End;

   Dispose(p,Done);
  End;{Eof(f)}


c:=IOResult;
 Close(f);  {�����⨥ ⥪�⮢���}
c:=IOResult;
Erase(f);
c:=IOResult;

c:=IOResult;
 Base.Close;{�����⨥ DBF}
c:=IOResult;
  AddLog(LogFile,'������ ���⠢騪�� '+FDate+' ��� ��ꥪ� '+IntToStr(Kod,CMantissa)+' �ᯥ譮 �����襭');
End;



Procedure ImportBarter(Kod:Word);
Var c : Word;
    P : PClientType;
    f : Text;
    SClientKod,
     SKod,
     SDate: AllStr;
    NDS20,
    NDS18,
    NDS10,
    NDS_,
    Litr20,
    Litr18,
    Litr10,
    Litr_,
    ZakupkaOutNDS20,
    ZakupkaOutNDS18,
    ZakupkaOutNDS10,
    ZakupkaOutNDS_,
    NDSZ20,
    NDSZ18,
    NDSZ10,
    NDSZ_,
    Opl20,
    Opl18,
    Opl10,
    Opl_,
    Akzis:Real;
    S : String;
Begin

If Not fExists(III.Task[Kod].PathToClient+'barter.db') Then
 Begin
   {
   Writeln('��� ������ ��� ��ᯮ�� '+III.Task[Kod].PathToClient+'barter.db'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa));
   }
   AddLog(LogFile,'��� ������ ��� ��ᯮ�� '+III.Task[Kod].PathToClient+'barter.db'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa));
   Exit;
 End;


If Not fExists(III.PathToExport+'b'+EDate+'.dbf') Then
Begin
with Base do
begin
 Assign(III.PathToExport+'b'+EDate+'.dbf'); {�p�᢮��� �� ���}
 Init; {�����⮢����� � ᮧ����� ��}
 AddField('CLIENTKOD','C',8,0);{��� ������}
 AddField('LIZO','N',1,0);{1-䨧��᪮� ��� 0 -�ਤ��᪮� ���}
 AddField('FULLNAME','C',50,0);{������ �ਤ��᪮� ��������}
 AddField('NAME','C',20,0);{��������}
 AddField('UADRES','C',50,0);{�ਤ��᪨� ����}
 AddField('FADRES','C',50,0);{䠪��᪨� ����}
 AddField('TELEFON','C',50,0);{⥫�䮭}
 AddField('INN','C',30,0);{���}

      if Create then
         Open(ReadWrite)
      else
     begin
      {
      Writeln('�訡�� ᮧ����� '+III.PathToExport+'c'+EDate+
	 '.dbf'+' � ��ꥪ� '+IntToStr(Kod,CMantissa));
      }
      AddLog(LogFile,'�訡�� ᮧ����� '+III.PathToExport+'b'+EDate+
	 '.dbf'+' � ��ꥪ� '+IntToStr(Kod,CMantissa));
      exit;
     end;

  AddLog(LogFile,'�������� ���� ������ '+III.PathToExport+'b'+EDate+'.dbf'+' �ᯥ譮 �����襭�');

c:=IOResult;
     Close;
c:=IOResult;
End;{With Base}
End;

 Assign(f,III.PathToClientLst+'Barter.lst');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   {
   Writeln('��� ������ ��� ��ᯮ�� �訡�� ������ '+'client.lst'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,'��� ������ ��� ��ᯮ�� '+III.PathToClientLst+'Barter.lst'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(c,CMantissa));
   Exit;
  End;

 Base.Assign(III.PathToExport+'b'+EDate+'.dbf');
 c:=IOResult;
 Base.Open(ReadWrite);
 c:=IOResult;
 If c<>0 Then
  Begin
   Close(f);
   c:=IOResult;
   {
   Writeln('�訡�� ������ '+III.PathToExport+'c'+EDate+'.dbf'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(c,CMantissa));
   }
   AddLog(LogFile,III.PathToExport+'b'+EDate+'.dbf'+
	 +' � ��ꥪ� '+IntToStr(Kod,CMantissa)+' ���:'+IntToStr(c,CMantissa));
   Exit;
  End;

{����� ��⠢��� ��� ������ �����⮢}

 While Not(SeekEof(f)) Do
  Begin
   Readln(f,s);
   DelSpace(s);
   RFormatZerro(s,CClientKod);
   New(P,Init);
   P^.Dat.Kod:=S;

   If GetBarter(Kod,P) Then
     With Base Do
      Begin
       Append; {�������� ����� ������}
      s:=P^.Dat.BuchKod;
      RFormatZerro(s,7);
      s:='9'{��䨪� ������� ���⠢騪��}+s;
      WriteStr('CLIENTKOD',S);{��� ������}
      WriteNum('LIZO',P^.Dat.LIZO);{1-䨧��᪮� ��� 0 -�ਤ��᪮� ���}
      WriteStr('FULLNAME',P^.Dat.FULLNAme);{������ �ਤ��᪮� ��������}
      WriteStr('NAME',P^.Dat.NAme);{��������}
      WriteStr('UADRES',P^.Dat.Adress);{�ਤ��᪨� ����}
      WriteStr('FADRES',P^.Dat.AdressF);{䠪��᪨� ����}
      WriteStr('TELEFON',P^.Dat.Telefon);{⥫�䮭}
      WriteStr('INN',P^.Dat.INN);{���}
      End;

   Dispose(p,Done);
  End;{Eof(f)}


c:=IOResult;
 Close(f);  {�����⨥ ⥪�⮢���}
c:=IOResult;
Erase(f);
c:=IOResult;

c:=IOResult;
 Base.Close;{�����⨥ DBF}
c:=IOResult;
  AddLog(LogFile,'������ ���⠢騪�� �� ����������� '+FDate+' ��� ��ꥪ� '+IntToStr(Kod,CMantissa)+' �ᯥ譮 �����襭');
End;







End.{Unit}