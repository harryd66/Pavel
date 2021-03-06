{$IfNDEF DPMI}
{$F+}
{$O+}

{$EndIf}

Uses Glob,Serv,Servstr,Mail,Utils,Utils4,Utils5,
     Objects,StHolder,Protect,DBEngine,
     Dialogs,DBIII,TpDate,NetCall,Dos,NetDbEng;

{$M 65520,0,655360 }

{$I Compile.INC}
{$DEFINE Converter}


Const                                                                 {10  11   12  13  14  15  16  17  18  19  20}
 KurzSklad : array[1..30] of Char=('1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K',
 {21 22  23   24  25  26  27  28  29  30}
 'L','M','N','O','P','Q','R','S','T','U');

 CMaxTasks = 13;

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


Type SkladTask =Record
     Task : Array [1..CMaxSklads] Of PathTaskElement;
     PathToExport:TMyString;
     PathToClientLst:TMyString; {�ᯮ��㥬 ��� �࠭���� ⠡���� �痢�}
     DeltaDate:Integer;
     RoznizaClientPrefix:TMyString;
     BufferSkladKod : Word;
     TriadaINN:TMyString;
     TriadaKPP:TMyString;
     TriadaRKPP:TMyString;
     ProdmarketINN:TMyString;
     ProdmarketKPP:TMyString;
     ProdmarketRKPP:TMyString;
     SelectTriada: word;
     End;

Type PSkladTask  = ^SkladTaskPtr;
     SkladTaskPtr=Object(TObject)
     Dat  :  SkladTask;
      Constructor Init;
      Destructor Done; Virtual;
 end;


Var OldFileMode : Word;
    EDate : TMyString;
    Base : DBase3;
    LogFile :Text;

Var CountParam : Integer;
    ss : AllStr;


Var
    ReplicationObject: Array [1..CMaxSklads] Of Byte;{�ࠢ����� ��ࠬ��ࠬ� ���������� ��ப�}
    IndexTasks: Array [1..CMaxTasks] Of Byte;{ᯨ᮪ ����� ��������� ��ࠡ�⪥}
    i,j : Word;
    Res : LongInt;
    Ini : Text;
    FileName : String;
    III : pSkladTask;
    EgBox: PBox;
    EgBox1: PBox;
    fmrk: file of SuperMarketType;
    mrk: PSuperMarketType;
    fvzw: file of NewVozwratType;
    vzw: PNewVozwratType;
    As:DocumentEditZ;
    R: TRect;
    CodeAP,PartyID:string;
    Opt,Triada: boolean;
    IORez: word;
    P : PClientType;


constructor SkladTaskPtr.Init;
begin
 Inherited init;
end;

destructor SkladTaskPtr.Done;
begin
 Inherited Done;
end;

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

Procedure ClearIni;
VAr c : Word;
Begin
III^.Dat.PathToExport[0]:=#0;
III^.Dat.PathToClientLst[0]:=#0;
III^.Dat.DeltaDate:=0;
III^.Dat.RoznizaClientPrefix:='7000';
III^.Dat.BufferSkladKod:=99;

For c:=1 To CMaxSklads Do
Begin
III^.Dat.Task[c].ObjectName[0]:=#0;
III^.Dat.Task[c].PathToRazdel [0]:=#0;
III^.Dat.Task[c].PathToPrihod [0]:=#0;
III^.Dat.Task[c].PathToKassa [0]:=#0;
III^.Dat.Task[c].PathToSklad  [0]:=#0;
III^.Dat.Task[c].PathToId     [0]:=#0;
III^.Dat.Task[c].PathToClient[0]:=#0;
III^.Dat.Task[c].PathToDolg[0]:=#0;
III^.Dat.Task[c].PathToMarket[0]:=#0;
III^.Dat.Task[c].PathToReturn[0]:=#0;
III^.Dat.Task[c].PathToOplata[0]:=#0;
III^.Dat.Task[c].CalcAkzis:=0;
III^.Dat.Task[c].ShemaAkzis:=0;
III^.Dat.Task[c].VidZakupka:=0;{0 ��ࢠ� 1-����}
III^.Dat.Task[c].VirtualPrihod:=0;{0 ��ࢠ� 1-����}
III^.Dat.Task[c].ExternalPrihod:=0;{0 ��ࢠ� 1-����}
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
Assign (f,'toegais.ini');
Res := IOResult;
Reset(f);
Res := IOResult;
If Res <> 0 Then Exit;
Close(f);
Res := IOResult;
SH.Init;
SH.LoadFromFile ('toegais.ini');

III^.Dat.PathToClientLst:=GetAsString('PathToClientLst');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.PathToExport:=GetAsString('PathToExport');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.DeltaDate:=GetAsInteger('DeltaDate');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.BufferSkladKod:=GetAsInteger('BufferSkladKod');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


III^.Dat.RoznizaClientPrefix:=GetAsString('RoznizaClientPrefix');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.TriadaINN:=GetAsString('TriadaINN');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.TriadaKPP:=GetAsString('TriadaKPP');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.TriadaRKPP:=GetAsString('TriadaRKPP');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.ProdmarketINN:=GetAsString('ProdmarketINN');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.ProdmarketKPP:=GetAsString('ProdmarketKPP');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.ProdmarketRKPP:=GetAsString('ProdmarketRKPP');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.SelectTriada:=GetAsInteger('SelectTriada');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


For c:=1 To CMaxSklads Do
Begin
III^.Dat.Task[c].ObjectName:=GetAsString('ObjectName['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.Task[c].PathToKassa:=GetAsString('PathToKassa['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.Task[c].PathToPrihod:=GetAsString('PathToPrihod['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.Task[c].PathToClient:=GetAsString('PathToClient['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.Task[c].CalcAkzis:=GetAsInteger('CalcAkzis['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.Task[c].ShemaAkzis:=GetAsInteger('ShemaAkzis['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.Task[c].VidZakupka:=GetAsInteger('VidZakupka['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.Task[c].ExternalPrihod:=GetAsInteger('ExternalPrihod['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.Task[c].VirtualPrihod:=GetAsInteger('VirtualPrihod['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.Task[c].PathToMarket:=GetAsString('PathToMarket['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


III^.Dat.Task[c].PathToReturn:=GetAsString('PathToReturn['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

{III^.Dat.Task[c].PathToOplata:=GetAsString('PathToOplata['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.Task[c].PathToDolg:=GetAsString('PathToDolg['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;            }

III^.Dat.Task[c].PathToRAzdel:=GetAsString('PathToRazdel['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.Task[c].PathToSklad:=GetAsString('PathToSklad['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;

III^.Dat.Task[c].PathToId:=GetAsString('PathToId['+IntToStr(c,CMantissa)+']');
If Not Sh.IsOk Then Begin
                     Res:=1;Exit;
                    End;


End;
SH.Done;
End;

function LoadEgaisKode:boolean;
Var s: string;
    f: text;
    IOrez: word;
    count: word;
Begin
 LoadEgaisKode:=false;
 count:=0;
 Assign(f,III^.Dat.PathToClientLst);
 IOrez:=ioresult;
 Reset(f);
 IOrez:=ioresult;
 if iorez=0 then
 while not eof(f) do
 begin
   readln(f,s) ;
   if count<MaxCollectionSize then
   begin
    EgBox^.List^.Insert(NewStr(s));
    EgBox^.SetRange(EgBox^.List^.Count);
   end
   else
   begin
    EgBox1^.List^.Insert(NewStr(s));
    EgBox1^.SetRange(EgBox1^.List^.Count);
   end;

   inc(count);
 end
 else
 begin
   AddLog(LogFile,'�訡�� ������ 䠩�� �痢� egais');
   AddLog(LogFile,'���਩��� �����襭��');
   exit;
 end;
 AddLog(LogFile,'��裡 egais ����㦥��');
 IOrez:=ioresult;
 System.Close(f);
 IOrez:=ioresult;
 LoadEgaisKode:=true;
END;

function CreatWBH: boolean;
var c:word;
Begin
  CreatWBH:=false;

If Not fExists(III^.Dat.PathToExport+'wbh'+copy(EDate,1,4)+'.dbf') Then
   Begin
   with Base do
     begin
      Assign(III^.Dat.PathToExport+'wbh'+copy(EDate,1,4)+'.dbf'); {�p�᢮��� �� ���}
      Init; {�����⮢����� � ᮧ����� ��}
      AddField('WBID','C',100,0);{��ࢨ�� ����}
      AddField('NUMBER','C',50,0);{����� �������� - �� ���祢�� ����!!!!}
      AddField('DATE','D',8,0);{��� ���������}
      AddField('DOCTYPE','N',4,0);{��� 1 -��室��� 2 -��室���
                                       3 ����� ��� 4 -����� ���}
      AddField('STRUCDIV','C',200,0); { ������୮� ���ࠧ������� - ���� ����}
      AddField('SENDER','C',254,0);  {��ࠢ�⥫�}
      AddField('RECIPIENT','C',254,0); {�����⥫�}
      AddField('SUPPLIER','C',254,0);  {���⠢騪}
      AddField('PAYER','C',254,0);    {���⥫�騪}
      AddField('BASIS','C',200,0);    {���-� �᭮�����}
      AddField('PRICENDS','N',4,0);   {��� � �㬬� -1 �� � �㬬� - 0}
      AddField('OUTDATE','D',8,0);    {��� ���㧪�}
      AddField('INDATE','D',8,0);     {��� ��室�}
      AddField('WITHNDS','L',1,0);    {}

      AddField('KODSKL','N',4,0);  {��� ᪫���}
      if Create then
         Open(ReadWrite)
      else
     begin
      AddLog(LogFile,'�訡�� ᮧ����� '+III^.Dat.PathToExport+'wbh'+copy(EDate,1,4)+'.dbf');
      exit;
     end;

  AddLog(LogFile,'�������� ���� ������ '+III^.Dat.PathToExport+'wbh'+copy(EDate,1,4)+'.dbf'+' �ᯥ譮 �����襭�');

  c:=IOResult;
     Close;
  c:=IOResult;
End;{With Base}
End;

  CreatWBH:=true;
End;

function CreatWBC: boolean;
var c:word;
Begin
  CreatWBC:=false;

If Not fExists(III^.Dat.PathToExport+'wbc'+copy(EDate,1,4)+'.dbf') Then
   Begin
   with Base do
     begin
      Assign(III^.Dat.PathToExport+'wbc'+copy(EDate,1,4)+'.dbf'); {�p�᢮��� �� ���}
      Init; {�����⮢����� � ᮧ����� ��}
      AddField('WCID','C',38,0);{��ࢨ�� ���� ����塞 �����}
      AddField('WBID','C',100,0);{������ ᮢ������ � ����������!}
      AddField('AMOUNT','N',6,0);{������⢮}
      AddField('PARTYID','C',100,0); {����� ���⨨}
      AddField('PRODNAME','C',254,0); {������������ �த�樨}
      AddField('PRICE','F',20,4); {����}
      AddField('RATENDS','F',20,4);  {�⠢�� ���}
      AddField('NOTE','C',5,0);  {�ਬ�砭�� - �ᯮ��㥬 ��� BazKOd}
      if Create then
         Open(ReadWrite)
      else
     begin
      AddLog(LogFile,'�訡�� ᮧ����� '+III^.Dat.PathToExport+'wbc'+copy(EDate,1,4)+'.dbf');
      exit;
     end;

  AddLog(LogFile,'�������� ���� ������ '+III^.Dat.PathToExport+'wbc'+copy(EDate,1,4)+'.dbf'+' �ᯥ譮 �����襭�');

  c:=IOResult;
     Close;
  c:=IOResult;
End;{With Base}
End;
  CreatWBC:=true;
End;

function TestKodEgais(kod:ArtikulStr; var CodeAP,PartyID: string):boolean;
Var i: word;
    s: string;
    sKOd:ArtikulStr;
Begin
  TestKodEgais:=false;
  CodeAP:='';
  PartyID:='';
  if (EgBox<>nil) and (EgBox^.List^.Count>0) then
  for i:=0 to EgBox^.List^.Count-1 do
  begin
    s:=EgBox^.GetText(i,EgBox^.List^.Count);
    {DelSpace(s);}
    System.Delete(s,1,1);
    sKOd:=copy(s,1,CArtikul);
    sYstem.Delete(s,1,CArtikul);
    if StrToInt(skod)=StrToInt(kod) then
    begin
      System.Delete(s,1,2);
      CodeAP:=copy(s,1,pos(';',s)-1);
      System.Delete(s,1,pos(';',s)+1);
      {if  pos(';',s)>0 then System.Delete(s,pos(';',s),1);}
      PartyID:=s;
      TestKodEgais:=true;
      exit;
    end;
  end;
  if (EgBox1<>nil) and (EgBox1^.List^.Count>0) then
  for i:=0 to EgBox1^.List^.Count-1 do
  begin
    s:=EgBox1^.GetText(i,EgBox1^.List^.Count);
    {DelSpace(s);}
    System.Delete(s,1,1);
    sKOd:=copy(s,1,CArtikul);
    sYstem.Delete(s,1,CArtikul);
    if StrToInt(skod)=StrToInt(kod) then
    begin
      System.Delete(s,1,2);
      CodeAP:=copy(s,1,pos(';',s)-1);
      System.Delete(s,1,pos(';',s)+1);
      {if  pos(';',s)>0 then System.Delete(s,pos(';',s),1);}
      PartyID:=s;
      TestKodEgais:=true;
      exit;
    end;
  end;
End;

function FormTriadaRoznName: string;
Begin
 FormTriadaRoznName:=
 DosToWin('��� �� �ਠ��-��ࢨ� ஧� <Inn='+III^.Dat.TriadaINN+'/> <Kpp='+III^.Dat.TriadaRKPP+'/>');
End;

function FormPMRoznName: string;
Begin
 FormPMRoznName:=
 DosToWin('��� �த��થ� ஧� <Inn='+III^.Dat.ProdmarketINN+'/> <Kpp='+III^.Dat.ProdmarketRKPP+'/>');
End;

function FormPMOptName: string;
Begin
 FormPMOptName:=
 DosToWin('��� �த��થ� <Inn='+III^.Dat.ProdmarketINN+'/> <Kpp='+III^.Dat.ProdmarketKPP+'/>');
End;

function FormTriadaOptName: string;
Begin
 FormTriadaOptName:=
 DosToWin('��� �� �ਠ��-��ࢨ� <Inn='+III^.Dat.TriadaINN+'/> <Kpp='+III^.Dat.TriadaKPP+'/>');
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
 Assign(fId,III^.Dat.Task[Ind].PathToID+c+'.id');
 GetIdField[0]:=#0;
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l <> 0 Then
 Begin
  AddLog(LogFile,'�訡�� ������ '+III^.Dat.Task[Ind].PathToID+c+'.id ��� ��ꥪ�'+IntToSTr(Ind,2)+
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

{  FBuchGroup:GetIdField:=IntToStr(Id^.Dat.BuchGroup,COne);
  FGroup,
  FNGroupKod:GetIdField:=Id^.Dat.NGroupKod;
  FEtil     :GetIdField:=Id^.Dat.Etil;
  FMera    : Begin
             st:=Id^.Dat.Mera;
             RFormatZerro(Id^.Dat.Mera,CClientKod);
             DelSpaceRight(St);
             GetIdField:=St;
             End;  }
   Else;
   End;{CAse}
  End;
  If Not(Id^.Dat.Employ) And (Field in [FFName,FNAme]) Then GetIDField:='!!!����� ������!!!';
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

 Assign (f,III^.Dat.Task[Kod].PathToClient+'client.db');
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
  3:
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


function FormEgaisRECIPIENTName(cl:ArtikulStr;vid:word):string;
{��ନ��� ��� � ⥣��� ��� � ��� �� ४����⮢ ������}
var Name,Inn,Kpp: AllStr;
Begin
  Delspace(cl);
  New(P,Init);
  P^.Dat.Kod:=cl;
  GetClient(vid,P);

  Name:=P^.Dat.FULLNAme;
  Inn:=P^.Dat.INN;{���}
  Delspace(Inn);
  KPP:=P^.Dat.KPP;{���};
  DelSpace(Kpp);
  if Kpp='' then Kpp:='0';
  Dispose(P,Done);
  FormEgaisRECIPIENTName:=DosToWin(Name+' <Inn='+Inn+'/> <Kpp='+Kpp+'/>');
End;

function DateToDbfDate(d:TDateString): longint;
{�८�ࠧ�� ���� �ଠ� DD-MM-YY � �᫮ YYYYMMDD}
{����⠥� ⮪� � 21 ���� ....}
Begin
  DateToDbfDate := 0;
  While pos('-', D) > 0 do
    system.delete(D,pos('-', D),1);
  DateToDbfDate:=StrToInt(copy(D,1,2))+StrToInt(copy(D,3,2))*100+
     (2000+StrToInt(copy(D,5,2)))*10000;
End;

Procedure AddVzwToEgais(E:PNewVozwratType; opt:boolean; triada: boolean; kod:word);
Var c: word;
    id,id1: longint;
    sId,sId1,ws: AllStr;
    i: word;
    bfind: boolean;
    sDate: String[CDate+2];
    CodeAP,PartyID: string;
Begin

    {�ନ�㥬 ��������� ���������}
    Base.Assign(III^.Dat.PathToExport+'wbh'+copy(EDate,1,4)+'.dbf');

   if Base.IsOpen then
   begin
     c:=IOResult;
     Base.Close;
     c:=IOResult;
   end;

     if Base.Open(ReadWrite) then
     With Base Do
      Begin

       {�஢�ઠ ��� �� 㦥 ⠪�� ��������� � dbf}
       bfind:=false;
       Base.Go_To(0);
       while not Base.Eof do
       begin
         if Find('NUMBER',E^.Dat.Document+'/'+IntToStr(Kod,2)) then
         begin
           sDate:=E^.Dat.DateC;
           while Pos('-', sDate) > 0 do
             sDate[Pos('-', SDate)] := '/';
           System.Insert('20',SDate,7);
           if ((sDate=Date('DATE')) and (StrToInt(Str('DOCTYPE'))=3))
              and ( kod = StrToInt(Str('KODSKL')))  then
           begin
             bfind:=true;
             break;
           end;
         end;
         Base.Continue;
       end;

     if not bFind then
     begin
       id:=LastRec+1;
       sId:=IntToStr(id,38);
       DelSpace(sId);
       Append; {�������� ����� ������}
       WriteStr('WBID',sId);
       WriteStr('NUMBER',E^.Dat.Document+'/'+IntToStr(Kod,2));
       WriteNum('DATE',DateToDbfDate(E^.Dat.DateC));{��� ���������}
       WriteNum('DOCTYPE',3);{������}
       WriteStr('STRUCDIV','');
  if OPt then
    begin
       if Triada then WriteStr('RECIPIENT',FormTriadaOptName)
       else WriteStr('RECIPIENT',FormPMOptName); {�����⥫� - ��}

       WriteStr('SENDER',FormEgaisRECIPIENTName(E^.Dat.MakeKod,kod));  {��ࠢ�⥫� - ������}
       if Triada then WriteStr('PAYER',FormTriadaOptName)
       else WriteStr('PAYER',FormPMOptName);  {���⥫�騪 - ��}
       WriteStr('SUPPLIER',FormEgaisRECIPIENTName(E^.Dat.MakeKod,kod)); {���⠢騪 - ������}
    end
    else
    begin
       if Triada then WriteStr('SENDER',FormTriadaOptName)
       else WriteStr('SENDER',FormPMOptName);  {��ࠢ�⥫� - ��}
       if Triada then  {���㧪� �� �ਠ��-஧����}
       WriteStr('RECIPIENT',FormTriadaRoznName)
       else  WriteStr('RECIPIENT',FormPMRoznName); {���㧪� �� ��-஧�}
       if Triada then WriteStr('SUPPLIER',FormTriadaOptName)
       else WriteStr('SUPPLIER',FormPMOptName); {���⠢騪 - �� ? }
       if Triada then  {���㧪� �� �ਠ��-஧����}
       WriteStr('PAYER',FormTriadaRoznName)
       else WriteStr('PAYER',FormPMRoznName);
    end;

       WriteStr('BASIS',E^.Dat.BasisDoc+'/'+IntToStr(Kod,3)+' �� '+E^.Dat.BasisDate);
       WriteNum('PRICENDS',18);
       WriteNum('OUTDATE',DateToDbfDate(E^.Dat.DateC));
       WriteNum('INDATE',DateToDbfDate(E^.Dat.DateC));
       WriteNum('WITHNDS',1);  {��� � �㬬� -1 �� � �㬬� - 0}
       WriteNum('KODSKL',Kod);
      end
      else {��������� 㦥 ����};

   End;


   c:=IOResult;
   Base.Close;{�����⨥ DBF}
   c:=IOResult;


   {�ନ�㥬 ᮤ�ঠ��� ���������}
if not bFind then
 begin
   Base.Assign(III^.Dat.PathToExport+'wbc'+copy(EDate,1,4)+'.dbf');

   if Base.IsOpen then
   begin
     c:=IOResult;
     Base.Close;
     c:=IOResult;
   end;



    if Base.Open(ReadWrite) then
    for i:=1 to E^.Dat.Amount do
      Begin
       id1:=Base.LastRec+1;
       sId1:=IntToStr(id1,38);
       {�᫨ ������ ����� � �����⨨}
       if TestKodEgais(E^.Dat.VozwratElement[i].BazKOd,CodeAP,PartyID) then
       begin
         DelSpace(CodeAP);
         DelSpace(PartyID);
         Base.Append; {�������� ����� ������}
         Base.WriteStr('WCID',sId1);{��ࢨ�� ���� ����塞 ����� - �७ ⠬!}
         Base.WriteStr('WBID',sId); {������ ᮢ������ � ����������!}
         Base.WriteNum('AMOUNT',StrToInt(E^.Dat.VozwratElement[i].Input.KOl));{������⢮}
         Base.WriteStr('PARTYID',PartyId); {����� ���⨨}
         Base.WriteStr('PRODNAME',DosToWin(GetIdField(kod,FName,E^.Dat.VozwratElement[i].BazKOd)+
         ' '+GetIdField(kod,FName2,E^.Dat.VozwratElement[i].BazKOd)+' <AlcCode='+CodeAP+'/>')); {������������ �த�樨}

         (*If E^.Dat.SkidkaSelector=0 Then{�᫨ ��⮬��}
           MyStr((StrToReal(E^.Dat.MarketElement[i].Input.Zena)/
           (1+StrToReal(E^.Dat.MarketElement[i].Input.Proz)/100))
           ,CZena,CMantissa,ws){����� 業�}
         Else
          MyStr((StrToReal(E^.Dat.MarketElement[i].Input.Zena)-
	  StrToReal(E^.Dat.MarketElement[i].Input.Skidka))
            ,CZena,CMantissa,ws);{����� 業�} *)
         Base.WriteNum('PRICE',StrToReal(E^.Dat.VozwratElement[i].Input.Zena)); {����}
         Base.WriteNum('RATENDS',StrToReal(E^.Dat.VozwratElement[i].Input.NDS));
         Base.WriteStr('NOTE',E^.Dat.VozwratElement[i].BazKod);
        end;{if TestKodEgais(}
      End;{With}


   c:=IOResult;
   Base.Close;{�����⨥ DBF}
   c:=IOResult;

 end;

End;


Procedure AddMRkToEgais(E:PSuperMarketType; opt:boolean; triada: boolean; kod:word);
Var c: word;
    id,id1: longint;
    sId,sId1,ws: AllStr;
    i: word;
    bfind: boolean;
    sDate: String[CDate+2];
    CodeAP,PartyID: string;
Begin

    {�ନ�㥬 ��������� ���������}
    Base.Assign(III^.Dat.PathToExport+'wbh'+copy(EDate,1,4)+'.dbf');

   if Base.IsOpen then
   begin
     c:=IOResult;
     Base.Close;
     c:=IOResult;
   end;

     if Base.Open(ReadWrite) then
     With Base Do
      Begin

       {�஢�ઠ ��� �� 㦥 ⠪�� ��������� � dbf}
       bfind:=false;
       Base.Go_To(0);
       while not Base.Eof do
       begin
         if Find('NUMBER',E^.Dat.Document+'/'+IntToStr(Kod,2)) then
         begin
           sDate:=E^.Dat.DateC;
           while Pos('-', sDate) > 0 do
             sDate[Pos('-', SDate)] := '/';
           System.Insert('20',SDate,7);
           if ((sDate=Date('DATE')) and (StrToInt(Str('DOCTYPE'))=2))
              and ( kod = StrToInt(Str('KODSKL')))  then
           begin
             bfind:=true;
             break;
           end;
         end;
         Base.Continue;
       end;

     if not bFind then
     begin
       id:=LastRec+1;
       sId:=IntToStr(id,38);
       DelSpace(sId);
       Append; {�������� ����� ������}
       WriteStr('WBID',sId);
       WriteStr('NUMBER',E^.Dat.Document+'/'+IntToStr(Kod,2));
       WriteNum('DATE',DateToDbfDate(E^.Dat.DateC));{��� ���������}
       WriteNum('DOCTYPE',2);{���㧪�}
       WriteStr('STRUCDIV','');
  if OPt then
    begin
       if Triada then WriteStr('SENDER',FormTriadaOptName)
       else WriteStr('SENDER',FormPMOptName);  {��ࠢ�⥫� - ��}

       WriteStr('RECIPIENT',FormEgaisRECIPIENTName(E^.Dat.ClientKod,kod)); {�����⥫� - ������}
       if Triada then WriteStr('SUPPLIER',FormTriadaOptName)
       else WriteStr('SUPPLIER',FormPMOptName); {���⠢騪 - �� }
       WriteStr('PAYER',FormEgaisRECIPIENTName(E^.Dat.ClientKod,kod)); {���⥫�騪 - ������}
    end
    else
    begin
       if Triada then WriteStr('SENDER',FormTriadaOptName)
       else WriteStr('SENDER',FormPMOptName);  {��ࠢ�⥫� - ��}
       if Triada then  {���㧪� �� �ਠ��-஧����}
       WriteStr('RECIPIENT',FormTriadaRoznName)
       else  WriteStr('RECIPIENT',FormPMRoznName); {���㧪� �� ��-஧�}
       if Triada then WriteStr('SUPPLIER',FormTriadaOptName)
       else WriteStr('SUPPLIER',FormPMOptName); {���⠢騪 - �� ? }
       if Triada then  {���㧪� �� �ਠ��-஧����}
       WriteStr('PAYER',FormTriadaRoznName)
       else WriteStr('PAYER',FormPMRoznName);
    end;

       WriteStr('BASIS','');
       WriteNum('PRICENDS',18); {��� � �㬬� -1 �� � �㬬� - 0}
       WriteNum('OUTDATE',DateToDbfDate(E^.Dat.DateC));
       WriteNum('INDATE',DateToDbfDate(E^.Dat.DateC));
       WriteLog('WITHNDS',true);
       WriteNum('KODSKL',Kod);
      end
      else {��������� 㦥 ����};

   End;


   c:=IOResult;
   Base.Close;{�����⨥ DBF}
   c:=IOResult;


   {�ନ�㥬 ᮤ�ঠ��� ���������}
if not bFind then
 begin
   Base.Assign(III^.Dat.PathToExport+'wbc'+copy(EDate,1,4)+'.dbf');

   if Base.IsOpen then
   begin
     c:=IOResult;
     Base.Close;
     c:=IOResult;
   end;



    if Base.Open(ReadWrite) then
    for i:=1 to E^.Dat.Amount do
      Begin
       id1:=Base.LastRec+1;
       sId1:=IntToStr(id1,38);
       {�᫨ ������ ����� � �����⨨}
       if TestKodEgais(E^.Dat.MarketElement[i].BazKOd,CodeAP,PartyID) then
       begin
         {DelSpace(CodeAP);
         DelSpace(PartyID);}
         Base.Append; {�������� ����� ������}
         Base.WriteStr('WCID',sId1);{��ࢨ�� ���� ����塞 ����� - �७ ⠬!}
         Base.WriteStr('WBID',sId); {������ ᮢ������ � ����������!}
         Base.WriteNum('AMOUNT',StrToInt(E^.Dat.MarketElement[i].Input.KOl));{������⢮}
         Base.WriteStr('PARTYID',PartyId); {����� ���⨨}
         Base.WriteStr('PRODNAME',DosToWin(GetIdField(kod,FName,E^.Dat.MarketElement[i].BazKOd)+
         ' '+GetIdField(kod,FName2,E^.Dat.MarketElement[i].BazKOd)+' <AlcCode='+CodeAP+'/>')); {������������ �த�樨}

         If E^.Dat.SkidkaSelector=0 Then{�᫨ ��⮬��}
           MyStr((StrToReal(E^.Dat.MarketElement[i].Input.Zena)/
           (1+StrToReal(E^.Dat.MarketElement[i].Input.Proz)/100))
           ,CZena,CMantissa,ws){����� 業�}
         Else
          MyStr((StrToReal(E^.Dat.MarketElement[i].Input.Zena)-
	  StrToReal(E^.Dat.MarketElement[i].Input.Skidka))
            ,CZena,CMantissa,ws);{����� 業�}
         Base.WriteNum('PRICE',StrToReal(ws)); {����}
         Base.WriteNum('RATENDS',StrToReal(E^.Dat.MarketElement[i].Input.NDS));
         Base.WriteStr('NOTE',E^.Dat.MarketElement[i].BazKod);
        end;{if TestKodEgais(}
      End;{With}


   c:=IOResult;
   Base.Close;{�����⨥ DBF}
   c:=IOResult;

 end;

End;

procedure LoadReturnToEgais;
var j: word;
Begin
 For j:=1 To CMAxSklads Do
 Begin
  If ReplicationObject[j]=1 Then
  Begin
   Assign(fvzw,III^.Dat.Task[j].PathToReturn+FDate+'.vzw');
   IOrez:=ioresult;
   Reset(fvzw);
   IOrez:=ioresult;
   if IOREz<>0 then
   begin
    AddLog(LogFile,'��� ������ ��� ��ᯮ�� '+III^.Dat.Task[j].PathToReturn+FDate+'.vzw'+
	 +' � ��ꥪ� '+IntToStr(j,CMantissa));
    continue;
   end;

   New(vzw,Init);

  while not eof(fvzw) do
  begin
   Read(fvzw,vzw^.Dat);
   AddVzwToEgais(vzw,vzw^.Dat.Opt,Triada,j);

  end; {while not eof(fvzw)}
  AddLog(LogFile,'������ �����⮢ '+FDate+' ��� ��ꥪ� '+IntToStr(j,CMantissa)+' �ᯥ譮 �����襭');
  Dispose(vzw,Done);
  close(fvzw);

  End;
 End;

End;


procedure LoadMarketToEgais;
var j: word;
Begin
 For j:=1 To CMAxSklads Do
 Begin
  If ReplicationObject[j]=1 Then
  Begin
   Assign(fmrk,III^.Dat.Task[j].PathToMarket+FDate+'.mrk');
   IOrez:=ioresult;
   Reset(fmrk);
   IOrez:=ioresult;
   if IOREz<>0 then
   begin
    AddLog(LogFile,'��� ������ ��� ��ᯮ�� '+III^.Dat.Task[j].PathToMarket+FDate+'.mrk'+
	 +' � ��ꥪ� '+IntToStr(j,CMantissa));
    continue;
   end;


   New(mrk,Init);

  while not eof(fmrk) do
  begin
   Read(fmrk,mrk^.Dat);
   If mrk^.Dat.Active Then{��⨢��}
   If (mrk^.Dat.OperatorSelector=0)  Then {ॠ������ �������}
   If ((mrk^.Dat.DocSelector in [3,4]) And Not(mrk^.Dat.Realiz)) Or{�� ���筠� ���ᨣ����}
      (mrk^.Dat.DocSelector in [6,8]) Then{���ᨣ����}
      begin
       Opt:=true;
       AddMRkToEgais(mrk,Opt,Triada,j);
      end;

  If (mrk^.Dat.Active)And(mrk^.Dat.OperatorSelector=0)And
  (
  ((mrk^.Dat.DocSelector in[1]) And Not(mrk^.Dat.Realiz))
  Or
  ((mrk^.Dat.DocSelector in [5,7]) And  (mrk^.Dat.Realiz))
  ) Then
    begin
      Opt:=false;
      AddMRkToEgais(mrk,Opt,Triada,j);
    end;



  end; {while not eof(fmrk)}
  AddLog(LogFile,'������ ॠ���樨 '+FDate+' ��� ��ꥪ� '+IntToStr(j,CMantissa)+' �ᯥ譮 �����襭');
  Dispose(mrk,Done);
  close(fmrk);

  (* If IndexTasks[1]=1 Then ImportOPT(j);
  If IndexTasks[7]=1 Then ImportKassa(j);*)
  End;
 End;

End;

BEGIN

 ClearIni;

 Filemode:=66;

 j:=1;
 For j:=1 To CMaxSklads Do
  Begin
   If FindParam('/'+KurzSklad[j]) Then ReplicationObject[j]:=1
   Else
   ReplicationObject[j]:=0;
  End;

 If Not(FindParam('OUTDATE')) Then
  Begin
   CountParam:=0;
   If FindParamCount('DECDATE=',CountParam) Then
    Begin
     ss:=ParamStr(CountParam);
     CountParam:=StrToInt(Copy(ss,9,Ord(ss[0])-8));
     FDate:=DateToDateString(DateMask,DateStringToDate(DateMask,FDate)+CountParam);
    End;
  End;

 EDate:=FDate;

 EDate:=ClearChar(EDate);

 III^.Init;

 Assign(LogFile,'eg'+EDate+'.log');
 j:=IoResult;
 Append(LogFile);
 j:=IoResult;
 If j<>0 Then
  Begin
   Writeln('�訡�� ������ ���-䠩��');
   Rewrite(LogFile);
   j:=IoResult;
   If j<>0 Then
    Begin
     Writeln('�訡�� ᮧ����� ���-䠩��');
    End;
  End;

 Assign(Ini,'toegais.ini');
 j:=IoResult;
 Reset(Ini);
 j:=IoResult;
 If j<>0 Then
  Begin
   AddLog(LogFile,'�訡�� ������ ini-䠩��');
   AddLog(LogFile,'���਩��� �����襭��');
   j:=IoResult;
   Close(LogFile);
   j:=IoResult;
   Exit;
  End;
 j:=IoResult;
 Close(ini);
 j:=IoResult;
 Res:=0;
 ReadNewIni(INI,Res);
 j:=IoResult;
 Close(ini);
 j:=IoResult;
 If Res=1 Then
  Begin
   j:=IoResult;
   AddLog(LogFile,'�訡�� �⥭�� ini-䠩��');
   AddLog(LogFile,'���਩��� �����襭��');
   j:=IoResult;
   Close(LogFile);
   j:=IoResult;
   Exit;
  End;

 AddLog(LogFile,'���� ��⮬���᪮�� ��ࠡ��稪� ������ �� '+FDAte+' '+
 DayString[DayOfWeek(DateStringToDate(DateMask,FDate))]);

  R.Assign(0, 0, 0, 0);
  EgBox := New(PBox, Init(R, 1, Nil));
  EgBox^.NewList(New(PMyCollection, Init(1,1)));

  R.Assign(0, 0, 0, 0);
  EgBox1 := New(PBox, Init(R, 1, Nil));
  EgBox1^.NewList(New(PMyCollection, Init(1,1)));

  if not LoadEgaisKode then exit;

  CreatWBH;
  CreatWBC;

  Triada:=false;
  if III^.Dat.SelectTriada=1 then Triada:=true;

  LoadMarketToEgais;
  LoadReturnToEgais;

 III^.Done;

 AddLog(LogFile,'�����襭�� ��⮬���᪮�� ������');

 Dispose(EgBox,Done);
 Dispose(EgBox1,Done);

 I:=IoResult;
 Close(LogFile);
 I:=IoResult;

END.