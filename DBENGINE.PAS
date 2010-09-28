{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit DbEngine;

Interface

Uses Dialogs,Glob,Serv,ServStr;
(*
Function GetFullName(C:ArtikulStr):TEnjoyStr;                 {1}
Function GetName(C:ArtikulStr):TEnjoyStr;                     {2}
Function GetPost(C:ArtikulStr):TEnjoyStr;                     {3}
Function GetDivision(C:ArtikulStr;i:Byte):TDateString;        {4}
Function GetKol(C:ArtikulStr):TEnjoyStr;                      {5}
Function GetLitr(C:ArtikulStr):TEnjoyStr;                     {6}
Function GetInPack(C:ArtikulStr):TEnjoyStr;                   {7}
Function GetAkzis(C:ArtikulStr):TEnjoyStr;                    {8}
Function GetSertif(C:ArtikulStr):TEnjoyStr;                   {9}
Function GetNDS(C:ArtikulStr):TEnjoyStr;                      {10}
Function GetRZena(C:ArtikulStr):TEnjoyStr;                    {11}
Function GetOZena(C:ArtikulStr):TEnjoyStr;                    {12}
Function GetTimes(C:ArtikulStr):TEnjoyStr;                    {13}
Function GetDAtes(C:ArtikulStr):TEnjoyStr;                    {14}
Function GetOperator(C:ArtikulStr):TEnjoyStr;                 {15}
Function GetKodMake(C:ArtikulStr):TEnjoyStr;                  {16}
Function GetMakeVid(C:ArtikulStr):Byte;                       {17}
*)
Function CreatRemoteClientDolgFile(E:PSuperMarketType):Boolean;
Function BakGetField(Field:Byte;C:ArtikulStr;i:Byte):TEnjoyStr;
Procedure GetSkladRecord(VAr SklDan:PSkladType);
Function GetIdField(Field:Byte;C:ArtikulStr):TEnjoyStr;
Function GetIdLocked(C:ArtikulStr):Boolean;
Function GetIdEmploy(C:ArtikulStr):Boolean;
Function GetIdRealiz(C:ArtikulStr):Boolean;
Function GetIdZapretOpt(C:ArtikulStr):Boolean;
Function GetIdMarket(C:ArtikulStr):Integer;
Procedure SetIDMarket(C:ArtikulStr;R:Word);

Function GetKassaEmploy(C:ArtikulStr):Boolean;        {2}
function GetAutoSkidka(opt,dost:boolean;srok:artikulstr):ArtikulStr;

{Function GetMAke(C:ArtikulStr;VidOperator:Byte):TEnjoyStr;}
Function GetMakeField(Field:Byte;C:ArtikulStr;VidOperator:Byte):TEnjoyStr;

Function GetRazdel(C:ArtikulStr):TEnjoyStr;                    {1}
Function GetRazdelLitr(C:ArtikulStr):Word;                    {1}
Function GetRazdelBegin(C:ArtikulStr):boolean;
Function GetRazdelEnd(C:ArtikulStr):boolean;
Function GetRazdelProc(C:ArtikulStr):TEnjoyStr;
Function GetRazdelSFProc(C:ArtikulStr):TEnjoyStr;
Function GetRazdelGroup(C:ArtikulStr):TEnjoyStr;
Function GetRazdelShkalaNaz(C:ArtikulStr;I:Word):TDateString;                    {1}
Function GetRazdelDesignation(C:ArtikulStr):TEnjoyStr;         {2}
Function GetRazdelState(C:ArtikulStr):Boolean;                 {4}
Function GetRazdelNaz(C:ArtikulStr):TDateString;                    {1}
Function GetPrihodStatus(Doc:ArtikulStr;Date:TDAteSTring):Word;

Function GetClientField(Field:Byte;C:ArtikulStr;VidOperator:Byte):TEnjoyStr;           {1}
Function GetClientState(C:ArtikulStr;VidOperator:Byte):Boolean;        {2}
Function GetClientLockSrok(C:ArtikulStr;VidOperator:Byte):ArtikulStr;        {2}
Function GetClientEmploy(C:ArtikulStr;VidOperator:Byte):Boolean;        {2}
Function GetClientOpt(C:ArtikulStr;VidOperator:Byte):Boolean;

Function GetAgentField(Field:Byte;C:ArtikulStr):TEnjoyStr;           {1}
Function GetAgentState(C:ArtikulStr):Boolean;        {2}
Function GetAgentEmploy(C:ArtikulStr):Boolean;        {2}

Function GetLizoField(Field:Byte;C:ArtikulStr):TEnjoyStr;           {1}
Function GetLizoState(C:ArtikulStr):Boolean;        {2}
Function GetLizoEmploy(C:ArtikulStr):Boolean;        {2}

Function GetEkspedField(Field:Byte;C:ArtikulStr):TEnjoyStr;           {1}
Function GetEkspedState(C:ArtikulStr):Boolean;        {2}
Function GetEkspedEmploy(C:ArtikulStr):Boolean;        {2}


Function GetMakeEmploy(C:ArtikulStr;VidOperator:Byte):Boolean;        {2}

Function CalcPackNoFile(Kod,Kol:TDateString):AllStr;
Function CalcPack(Kod,Kol:TDateString):AllStr;

Function GetTextSkidka (c:ArtikulStr):string;                    {1}
Function GetSkidkaOperator(c:ArtikulStr):TEnjoyStr;              {2}
Function GetSkidkaTimes(C:ArtikulStr):TDateString;               {3}
Function GetSkidkaDAtes(C:ArtikulStr):TDateString;               {4}
Procedure GetSkidka(C:ArtikulStr; Var Sk : SkidkaType);          {5}
Function GetSkidkaProz(Sa:ArtikulStr;Op:Word;ClKod:ArtikulStr;T:Real):Real;
Function GetShkalaProz(Sa:ArtikulStr;Sh:Word;Op:Word;ClKod:ArtikulStr):Real;
Function GetShkalaProz1(Sa:ArtikulStr;Sh:Word{номер шкалы}):Real;

Function GetPlataKredit(Region,Shkala,Docs:Word;Srok:LongInt):Real;
Function GetOperationField(Field:Byte;C:ArtikulStr):TEnjoyStr;

Function GetOperatorPassword(C:ArtikulStr):StrName;               {1}
Function GetOperatorName(C:ArtikulStr):StrName;                   {2}
Function GetReturnKol(SDoc,SDate,SClientKod,SBazKod,SDivision:TDateString;Vid:Word):ArtikulStr;
Function GetReturnStatus(SDoc,SDate,SClientKod:TDateString):Boolean;
Function GetReturnSkidka(SDoc,SDate,SClientKod:TDateString;Vid:Word):AllStr;

Function CreatClientDolgFile(E:PSuperMarketType):Boolean;
Function CreatClientStatFile(L:PSuperMarketType):Boolean;

Procedure CalcReturnPosition(SDoc,SDate,SClientKod,SBazKod:TDateString;SDivision:artikulStr;Vid:Word;
                             Var Skol:ArtikulStr;Var St : String);
Procedure GetKolFromOstat(DD:TDateString;Art:ArtikulStr;VAr Kol:AllStr);{4}

Function GetReturnDoc(As:DocumentEdit;Var E:PNewVozwratType):Boolean;

Function SetClientStatus(C:ArtikulStr;VidOperator:Byte;Status:Boolean):Boolean;
Function GetClientStatus(C:ArtikulStr;VidOperator:Byte):Boolean;
Function TestClientSrok(Kod:ArtikulStr;OperatorSelector:Word):Boolean;

Function GetMarket(Er:PRealizasiaType;Var E:PSuperMarketType):Boolean;
Function CreatClientBarterFile(SClientKod:ArtikulStr):Boolean;
Function GetMarket1(As:DocumentEdit;Var E:PSuperMarketType):Boolean;

Function GetBAzElement(C:ArtikulStr;Var E:BazType):Boolean;
Function GetImport(As:DocumentEdit;W: ArtikulStr;Var E:PImportSuperMarketType):Boolean;
Function GetMinNazenka(C:ArtikulStr;I:Word):AllStr;
Function GetShkalaMin(Sa:ArtikulStr;Sh:Word):Real;
Function TestSpecZena(SArt:ArtikulStr;ClKod:ArtikulStr;SZakupka:TDAteString;VAr SpezZena:TDAteString):Boolean;
Function TestSpec(SArt:ArtikulStr;ClKod:ArtikulStr):Boolean;


Function GetGroupEmploy(C:ArtikulStr):Boolean;
Function GetGroupField(Field:Byte;C:ArtikulStr):TEnjoyStr;

Function GetRewGroupEmploy(C:ArtikulStr):Boolean;
Function GetRewGroupField(Field:Byte;C:ArtikulStr):TEnjoyStr;
Function GetDolgClient(Date : TDAteString;Kod:ArtikulStr; Regim:Word;
   VAr Summa: AllStr;Var NewStart:TDAteString):Boolean;

Implementation

Uses Memory,Dos,MsgBox,Views,Objects,{Validate,}App,Drivers,TPDate,
     NetCall,NetDbEng,Access,Utils,Net;

Const ReadOnly=0+$42 {на самом деле не ReadOnly a DenyNone
                      открытие на чтениеи запись но всем разрешено все};

Function GetDolgClient(Date : TDAteString;Kod:ArtikulStr; Regim:Word;
{признак какой долг интересует 0 - только СФ
                               1 - черный
						 2 - ВСЕ}
   VAr Summa: AllStr;Var NewStart:TDAteString):Boolean;
Label 544;
Var ClientDolgFile : File Of ClientDolgType;
    ClientDolgElement : ClientDolgType;
    c : Word;
    l,l1,l2 : LongInt;
    Ext : TDAteSTring;

Begin
GetDolgClient:=False;
Summa[0]:=#0;

Ext:=IntToSTr(StrToInt(Rek.Kod),CMantissa);
RFormatZerro(Ext,CMAntissa);

NewStart:=DateToDateString(DateMask,DateStringToDate(DateMask,Date)+1);
Assign (ClientDolgFile,Path.TOarchiv+Date+'.d'+Ext);
c:=IOResult;
Reset  (ClientDolgFile);
c:=IOResult;
If c<>0 Then
 Begin
  {цикл поиска ближайшего файла долгов}
   l1:=DateStringToDAte(DAteMAsk,DAte)-1;
   l2:=l1-200;{DateStringToDAte(DAteMAsk,'01-01-00')};
   For l:=l1 DownTo l2 Do
    Begin
     DAte:=DateToDateString(DAteMAsk,l);
     NewStart:=DateToDateString(DateMask,DateStringToDate(DateMask,Date)+1);
     If FExists(Path.TOarchiv+Date+'.d'+Ext) Then
      Begin
Assign (ClientDolgFile,Path.TOarchiv+Date+'.d'+Ext);
c:=IOResult;
Reset  (ClientDolgFile);
c:=IOResult;
       NewStart:=DateToDateString(DateMask,DateStringToDate(DateMask,Date)+1);
       Goto 544;
      End;
    End;

  Exit;
 End;

544:
DInfoMsg('Определяю долг клиента на '+Date+'. Ждите... ');

If (FileSize(ClientDolgFile)-1)<StrToInt(Kod) Then
 Begin
  NoInfoMsg;
  Close(ClientDolgFile);
  c:=IOResult;
  Exit;
 End;

Seek(ClientDolgFile,StrToInt(Kod));
Read(ClientDolgFile,ClientDolgElement);
Case Regim Of
0:Summa:=RealToStr(ClientDolgElement.DolgSF,CIZena,CMantissa);
1:Summa:=RealToStr(ClientDolgElement.Dolg-ClientDolgElement.DolgSF,CIZena,CMantissa);
2:Summa:=RealToStr(ClientDolgElement.Dolg,CIZena,CMantissa);
Else;
End;

System.Close(ClientDolgFile);
  c:=IOResult;

NoInfoMsg;
GetDolgClient:=True;
End;


function GetAutoSkidka(opt,dost:boolean;srok:artikulstr):ArtikulStr;
var f: file of AutoSkidkaType;
    sk: AutoSkidkaType;
    OldFileMode : Word;
    l: longint;
   {dost1:  string[CKOl];
    dost7:  string[CKOl];
    dost14: string[CKOl];
    dost21: string[CKOl];
    dost28: string[CKOl];
    sam1: string[CKOl];
    sam7:    string[CKOl];
    sam14:    string[CKOl];}
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;

 Assign (f,Path.ToClient+'Skidki.db');
 GetAutoSkidka:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла автоскидок!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   read(f,sk);
   {ОПТ}
   if opt then
   begin
    {нал srok=1}
    if StrToInt(Srok)=1 then
    begin
     {доставка}
     if dost then GetAutoSkidka:=sk.Opt.dost1
     {самовывоз}
     else GetAutoSkidka:=sk.Opt.sam1
    end;

    {Отсрочка srok>1}
    if StrToInt(Srok)>1 then
    begin
    {доставка}
    if dost then
     begin
       if StrToInt(srok)<=7 then GetAutoSkidka:=sk.Opt.dost7;
       if (StrToInt(srok)>7) and (StrToInt(srok)<=14) then GetAutoSkidka:=sk.Opt.dost14;
       if (StrToInt(srok)>14) and (StrToInt(srok)<=21) then GetAutoSkidka:=sk.Opt.dost21;
       if (StrToInt(srok)>21) then GetAutoSkidka:=sk.Opt.dost28;
     end
    {самовывоз}
    else
     begin
      if StrToInt(Srok)<=7 then GetAutoSkidka:=sk.Opt.sam7
      else GetAutoSkidka:=sk.Opt.sam14
     end;
    end;

   end
   else {if opt then}
   {РОЗНИЦА}
   begin
      {самовывоз}
    {нал srok=1}
    if StrToInt(Srok)=1 then
    begin
     {доставка}
     if dost then GetAutoSkidka:=sk.rozn.dost1
     {самовывоз}
     else GetAutoSkidka:=sk.rozn.sam1
    end;

    {Отсрочка srok>1}
    if StrToInt(Srok)>1 then
    begin
    {доставка}
    if dost then
      begin
       if StrToInt(srok)<=7 then GetAutoSkidka:=sk.rozn.dost7;
       if (StrToInt(srok)>7) and (StrToInt(srok)<=14) then GetAutoSkidka:=sk.rozn.dost14;
       if (StrToInt(srok)>14) and (StrToInt(srok)<=21) then GetAutoSkidka:=sk.rozn.dost21;
       if (StrToInt(srok)>21) then GetAutoSkidka:=sk.rozn.dost28;
      end
    {самовывоз}
    else
     if StrToInt(srok)<=7 then GetAutoSkidka:=sk.rozn.sam7
     else GetAutoSkidka:=sk.rozn.sam14;
    end;
   end;


   Close(f);
   FileMode:=OldFileMode;
  end;

End;



Function TestSpec(SArt:ArtikulStr;ClKod:ArtikulStr):Boolean;
VAr c : Word;
    TovarFile : File Of TovarClientType;
    ToVarElement : TovarClientType;
    RTovarFile : File Of RAzdelClientType;
    RToVarElement : RAzdelClientType;
    Find : Boolean;
Begin
TestSpec:=FAlse;
{сначала поиск по наименованиям}
Assign(TovarFile,Path.ToClient+ClKod+'.skl');
c:=IOResult;
Reset(TovarFile);
c:=IOResult;
Find := FAlse;
If c=0 Then
Begin
 While Not(Eof(TovarFile)) And Not (Find) DO
  Begin
   Read(ToVarFile,ToVArElement);
   If ToVArElement.Active Then
   Begin
    If TovarElement.BazKod=SArt Then
    Begin
     Find:=True;
     Break;
    End;
   End;
  End;{While}
  c:=IOResult;
  System.Close(TovarFile);
  c:=IOResult;
  TestSpec:=Find;
End;


{поиск по списку разделов}
If Not Find Then
Begin
Assign(RTovarFile,Path.ToClient+ClKod+'.rsk');
c:=IOResult;
Reset(RTovarFile);
c:=IOResult;
Find := FAlse;
If c=0 Then
Begin
 While Not(Eof(RTovarFile)) And Not (Find) DO
  Begin
   Read(RToVarFile,RToVArElement);
   If RToVArElement.Active Then
   Begin
    If StrToInt(Copy(RTovarElement.BazKod,1,2))=StrToInt(Copy(SArt,1,2)) Then
    Begin
     Find:=True;
     Break;
    End;
   End;
  End;{While}
  c:=IOResult;
  System.Close(RTovarFile);
  c:=IOResult;
  TestSpec:=Find;
End
End;
End;


Function GetShkalaProz1(Sa:ArtikulStr;Sh:Word{номер шкалы}):Real;
Var s : PSkidkaType;
    f : SkidkaFileType;
    l : Word;
    code : Integer;
    c : Byte;
    st : ArtikulStr;
    Proz : TDAteString;
    OldFileMode:word;
Begin
 GetShkalaProz1:=1.0000;

 If sh=0 Then
 Begin
  GetShkalaProz1:=1.0000;
  Exit;
 End;

 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 St := Copy(sa,1,CRazdelKod);
 Assign(f,Path.TOSkidki+st+'.skl');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'Не найден файл скидок!'^M+
   #3'Автоматическая скидка невозможна !',Nil,mfError+mfCancelButton);
   FileMode:=OldFileMode;
   Exit;
  End;
 Sa:=Copy(sa,1+CRazdelKod,CKod);
 Val(sa,l,Code);
 Seek(f,l);
 New(s,Init);
 Code:=IOResult;
 REadSkidka(F,s);
 Close(f);
 FileMode:=OldFileMode;
 GetShkalaProz1:=StrToReal(S^.Dat.Skidka[Sh].Proz);
 Dispose(S,Done);
End;

Function TestSpecZenaProz(SArt:ArtikulStr;ClKod:ArtikulStr;Var Proz:TDateString):Boolean;
VAr c : Word;
    TovarFile : File Of TovarClientType;
    ToVarElement : TovarClientType;
    RTovarFile : File Of RAzdelClientType;
    RToVarElement : RAzdelClientType;
    Find : Boolean;
    SRZena,SZakupka:TDateString;
Begin
TestSpecZenaProz:=FAlse;
Proz[0]:=#0;
Assign(TovarFile,Path.ToClient+ClKod+'.skl');
c:=IOResult;
Reset(TovarFile);
c:=IOResult;
Find := FAlse;
If c=0 Then
Begin
 While Not(Eof(TovarFile)) And Not (Find) DO
  Begin
   Read(ToVarFile,ToVArElement);
   If ToVArElement.Active Then
   Begin
    If TovarElement.BazKod=SArt Then
    Begin
     SZakupka:=BakGetField(FZakupka,SArt,0);
     SRZena:=BakGetField(FRZena,SArt,0);

     MyStr(StrToReal(SZakupka)*(1+StrToReal(ToVarElement.Nazenka)/100),CZena,CMantissa,SZakupka);
     DelSpace(SZakupka);

     {выделяем максимальную цену}
{
     Writeln(SZakupka+' '+TovarElement.SpecZena);
     Readln;
}
     If StrToReal(SZakupka)<StrToReal(TovarElement.SpecZena) Then SZakupka:=TovarElement.SpecZena;
     DelSpace(SZakupka);


     MyStr(StrToReal(SZakupka)/StrToReal(SRZena),CLitr+1,CLitrmantissa,Proz);

     Find:=True;
     Break;
    End;
   End;
  End;{While}
  c:=IOResult;
  System.Close(TovarFile);
  c:=IOResult;
  TestSpecZenaProz:=Find;
End;


{поиск по списку разделов}
If Not Find Then
Begin
Assign(RTovarFile,Path.ToClient+ClKod+'.rsk');
c:=IOResult;
Reset(RTovarFile);
c:=IOResult;
Find := FAlse;
If c=0 Then
Begin
 While Not(Eof(RTovarFile)) And Not (Find) DO
  Begin
   Read(RToVarFile,RToVArElement);
   If RToVArElement.Active Then
   Begin
    If StrToInt(Copy(RTovarElement.BazKod,1,2))=StrToInt(Copy(SArt,1,2)) Then
    Begin
     SZakupka:=BakGetField(FZakupka,SArt,0);
     SRZena:=BakGetField(FRZena,SArt,0);

     If RTovarElement.Vid=0 Then {если наценка от закупки}
     Begin
     MyStr(StrToReal(SZakupka)*(1+StrToReal(RToVarElement.Nazenka)/100),CZena,CMantissa,SZakupka);
     DelSpace(SZakupka);
     MyStr(StrToReal(SZakupka)/StrToReal(SRZena),CLitr+1,CLitrmantissa,Proz);
     End
     Else
      Begin{если шкала}
       SZakupka:=SRZena;
       MyStr(StrToReal(SZakupka)*GetShkalaProz1(SArt,StrToInt(RTovarElement.Shkala)),CZena,CMantissa,SZakupka);
       DelSpace(SZakupka);
       MyStr(StrToReal(SZakupka)/StrToReal(SRZena),CLitr+1,CLitrmantissa,Proz);
      End;

     Find:=True;
     Break;
    End;
   End;
  End;{While}
  c:=IOResult;
  System.Close(RTovarFile);
  c:=IOResult;
  TestSpecZenaProz:=Find;
End;
End;

End;




Procedure RazdelError(i:Byte;Const sc:TMyString);
VAr s,sf : ArtikulStr;
Begin
Str(i:3,s);
Str(FileMode:2,sf);
MessageBox(#3'Ошибка открытия базы разделов!'^M+
#3'('+s+','+sf+')'^M+
sc,nil,mfError+mfCancelButton);
End;


Procedure NameError(i:Byte;Const sc:TMyString);
VAr s,sf : ArtikulStr;
Begin
Str(i:3,s);
Str(FileMode:2,sf);
MessageBox(#3'Ошибка открытия базы наименований!'^M+
#3'('+s+','+sf+')'^M+
sc,nil,mfError+mfCancelButton);
End;


Procedure BazError(i:Byte;Const sc:TMyString);
VAr s,sf : ArtikulStr;
Begin
Str(i:3,s);
Str(FileMode:2,sf);
MessageBox(#3'Ошибка открытия базы наличия!'^M+
#3'('+s+','+sf+')'^M+
sc,nil,mfError+mfCancelButton);
End;


Procedure SystemError(i:Byte);
VAr s,sf : ArtikulStr;
Begin
Str(i:3,s);
Str(FileMode:2,sf);
MessageBox(^M+#3'Ошибка открытия реестра операторов!'^M+
#3'('+s+','+sf+')',nil,mfError+mfCancelButton);
End;


Function GetRazdel(C:ArtikulStr):TEnjoyStr;
Var f : File of RazdelType;
    l : LongInt;
    Code : Integer;
    s : RazdelType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;

 Assign(f,Path.ToRazdel+'razdel.db');
 GetRazdel[0]:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  FileMode:=OldFileMode;
  RazdelError(l,Path.ToRazdel+'razdel.db'+' Код:['+c+']');
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   Repeat
   Read(f,s);
   Code:=IOResult;
   If (Code in [5,150]) Then
    Begin
     Seek(f,L);
     DInfoNetMsg('База разделов. Идет чтение позиции: '+C);

    End;
   Until Not(Code in[5,150]);
   NoNetInfoMsg;
   Code:=IOResult;
   Close(f);
   GetRazdel:=S.Name;
   FileMode:=OldFileMode;
  End;
End;

Function GetRazdelShkalaNaz(C:ArtikulStr;I:Word):TDateString;                    {1}
Var f : File of RazdelType;
    l : LongInt;
    Code : Integer;
    s : RazdelType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;

 Assign(f,Path.ToRazdel+'razdel.db');
 GetRazdelShkalaNaz[0]:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  FileMode:=OldFileMode;
  RazdelError(l,Path.ToRazdel+'razdel.db'+' Код:['+c+']');
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   c:=Copy(c,1,CMAntissa);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   Repeat
   Read(f,s);
   Code:=IOResult;
   If (Code in [5,150]) Then
    Begin
     Seek(f,L);
     DInfoNetMsg('База разделов. Идет чтение позиции: '+C);

    End;
   Until Not(Code in[5,150]);
   NoNetInfoMsg;
   Code:=IOResult;
   Close(f);
   GetRazdelShkalaNaz:=S.Skidka[i].MinNaz;
   FileMode:=OldFileMode;
  End;
End;

Function GetRazdelNaz(C:ArtikulStr):TDateString;                    {1}
Var f : File of RazdelType;
    l : LongInt;
    Code : Integer;
    s : RazdelType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;

 Assign(f,Path.ToRazdel+'razdel.db');
 GetRazdelNaz[0]:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  FileMode:=OldFileMode;
  RazdelError(l,Path.ToRazdel+'razdel.db'+' Код:['+c+']');
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   c:=Copy(c,1,CMAntissa);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   Repeat
   Read(f,s);
   Code:=IOResult;
   If (Code in [5,150]) Then
    Begin
     Seek(f,L);
     DInfoNetMsg('База разделов. Идет чтение позиции: '+C);

    End;
   Until Not(Code in[5,150]);
   NoNetInfoMsg;
   Code:=IOResult;
   Close(f);
   GetRazdelNaz:=S.MinNazenka;
   FileMode:=OldFileMode;
  End;
End;


Function GetOperatorName(C:ArtikulStr):StrName;
Var f : File of TSystemReestr;
    l : LongInt;
    s : TSystemReestr;
    Code : Integer;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;

 Assign(f,Path.ToOperator+'system.db');
 GetOperatorName[0]:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  FileMode:=OldFileMode;
  SystemError(l);
  Exit;
 End
 Else
  Begin
   l:=StrToInt(c);
   Seek(f,l);
   Code:=IOResult;
   Repeat
   Read(f,s);
   Code:=IOResult;
   If (Code in [5,150]) Then
    Begin
     Seek(f,L);
     DInfoNetMsg('База операторов. Идет чтение позиции: '+C);

    End;
   Until Not(Code in[5,150]);
   NoNetInfoMsg;
   Code:=IOResult;

   Close(f);
   GetOperatorName:=S.Name;
   FileMode:=OldFileMode;
  End;
End;

Function GetOperatorPassword(C:ArtikulStr):StrName;
Var f : File of TSystemReestr;
    l : LongInt;
    s : TSystemReestr;
    Code,i : INteger;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign(f,Path.ToOperator+'system.db');
 GetOperatorPassword[0]:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  FileMode:=OldFileMode;
  SystemError(l);
  Exit;
 End
 Else
  Begin
   l:=StrToInt(c);
   Seek(f,l);
   Code:=IOResult;
   If Code<>0 Then
    Begin
     GetOperatorPassword:='89d7f87sd9';
     FileMode:=OldFileMode;
     Close(f);
     Exit;
    End;
   Repeat
   Read(f,s);
   Code:=IOResult;
   If (Code <>0) Then
    Begin
     Seek(f,L);
     DInfoNetMsg('База операторов. Идет чтение позиции: '+C);
    End;
   Until Not(Code <>0);
   NoNetInfoMsg;
   Code:=IOResult;
   Close(f);
   for i:=0 to CMaxRoles do User[i]:=S.User[i];
   GetOperatorPassword:=S.Password;
   If Not(s.Employ) Then GetOperatorPassword:='!ОПЕР.УДАЛ!';
   FileMode:=OldFileMode;
  End;
End;


Function GetRazdelDesignation(C:ArtikulStr):TEnjoyStr;
Var f : File of RazdelType;
    l : LongInt;
    Code : Integer;
    s : RazdelType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;

 Assign(f,Path.ToRazdel+'razdel.db');
 GetRazdelDesignation[0]:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  FileMode:=OldFileMode;
  RazdelError(l,Path.ToRazdel+'razdel.db'+' Код:['+c+']');
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   Repeat
   Read(f,s);
   Code:=IOResult;
   If (Code in [5,150]) Then
    Begin
     Seek(f,L);
     DInfoNetMsg('База разделов. Идет чтение позиции: '+C);

    End;
   Until Not(Code in[5,150]);
   NoNetInfoMsg;
   Code:=IOResult;
   Close(f);
   GetRazdelDesignation:=S.Designation;
   If Not(s.Employ) Then GetRazdelDesignation:='!РАЗДЕЛ.УДАЛ!';
   FileMode:=OldFileMode;
  End;
End;

Function GetRazdelProc(C:ArtikulStr):TEnjoyStr;
Var f : File of RazdelType;
    l : LongInt;
    Code : Integer;
    s : RazdelType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign(f,Path.ToRazdel+'razdel.db');
 GetRazdelProc[0]:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  FileMode:=OldFileMode;
  RazdelError(l,Path.ToRazdel+'razdel.db'+' Код:['+c+']');
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   Repeat
   Read(f,s);
   Code:=IOResult;
   If (Code in [5,150]) Then
    Begin
     Seek(f,L);
     DInfoNetMsg('База разделов. Идет чтение позиции: '+C);

    End;
   Until Not(Code in[5,150]);
   NoNetInfoMsg;
   Code:=IOResult;
   Close(f);
   DelSpace(S.DostProz);
   GetRazdelProc:=S.DostProz;
   FileMode:=OldFileMode;
  End;
End;

Function GetRazdelSFProc(C:ArtikulStr):TEnjoyStr;
Var f : File of RazdelType;
    l : LongInt;
    Code : Integer;
    s : RazdelType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign(f,Path.ToRazdel+'razdel.db');
 GetRazdelSFProc[0]:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  FileMode:=OldFileMode;
  RazdelError(l,Path.ToRazdel+'razdel.db'+' Код:['+c+']');
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   Repeat
   Read(f,s);
   Code:=IOResult;
   If (Code in [5,150]) Then
    Begin
     Seek(f,L);
     DInfoNetMsg('База разделов. Идет чтение позиции: '+C);

    End;
   Until Not(Code in[5,150]);
   NoNetInfoMsg;
   Code:=IOResult;
   Close(f);
   DelSpace(S.Skidka[CShkala].MinNaz);
   GetRazdelSFProc:=S.Skidka[CShkala].MinNaz;
   FileMode:=OldFileMode;
  End;
End;


Function GetRazdelGroup(C:ArtikulStr):TEnjoyStr;
Var f : File of RazdelType;
    l : LongInt;
    Code : Integer;
    s : RazdelType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign(f,Path.ToRazdel+'razdel.db');
 GetRazdelGroup:='00';
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  FileMode:=OldFileMode;
  RazdelError(l,Path.ToRazdel+'razdel.db'+' Код:['+c+']');
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   Repeat
   Read(f,s);
   Code:=IOResult;
   If (Code in [5,150]) Then
    Begin
     Seek(f,L);
     DInfoNetMsg('База разделов. Идет чтение позиции: '+C);
    End;
   Until Not(Code in[5,150]);
   NoNetInfoMsg;
   Code:=IOResult;
   Close(f);
   DelSpace(S.Group);
   GetRazdelGroup:=S.Group;
   FileMode:=OldFileMode;
  End;
End;

Function GetRazdelBegin(C:ArtikulStr):boolean;
Var f : File of RazdelType;
    l : LongInt;
    Code : Integer;
    s : RazdelType;
    OldFileMode: word;
Begin
 GetRazdelBegin:=false;
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign(f,Path.ToRazdel+'razdel.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  FileMode:=OldFileMode;
  RazdelError(l,Path.ToRazdel+'razdel.db'+' Код:['+c+']');
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   Repeat
   Read(f,s);
   Code:=IOResult;
   If (Code in [5,150]) Then
    Begin
     Seek(f,L);
     DInfoNetMsg('База разделов. Идет чтение позиции: '+C);
    End;
   Until Not(Code in[5,150]);
   NoNetInfoMsg;
   Code:=IOResult;
   Close(f);
   if (DateStringToDate(DateMask,s.BeginStartSeason)>=DateStringToDate(DateMask,FDate))
   and(DateStringToDate(DateMask,Fdate)<=DateStringToDate(DateMask,s.BeginStopSeason)) then
   GetRazdelBegin:=true;
   FileMode:=OldFileMode;
  End;
End;

Function GetRazdelEnd(C:ArtikulStr):boolean;
Var f : File of RazdelType;
    l : LongInt;
    Code : Integer;
    s : RazdelType;
    OldFileMode: word;
Begin
 GetRazdelEnd:=false;
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign(f,Path.ToRazdel+'razdel.db');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  FileMode:=OldFileMode;
  RazdelError(l,Path.ToRazdel+'razdel.db'+' Код:['+c+']');
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   Repeat
   Read(f,s);
   Code:=IOResult;
   If (Code in [5,150]) Then
    Begin
     Seek(f,L);
     DInfoNetMsg('База разделов. Идет чтение позиции: '+C);
    End;
   Until Not(Code in[5,150]);
   NoNetInfoMsg;
   Code:=IOResult;
   Close(f);
   if (DateStringToDate(DateMask,s.EndStartSeason)>=DateStringToDate(DateMask,FDate))
   and(DateStringToDate(DateMask,Fdate)<=DateStringToDate(DateMask,s.EndStopSeason)) then
   GetRazdelEnd:=true;
   FileMode:=OldFileMode;
  End;
End;

Function GetRazdelLitr(C:ArtikulStr):Word;                    {1}
Var f : File of RazdelType;
    l : LongInt;
    Code : Integer;
    s : RazdelType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign(f,Path.ToRazdel+'razdel.db');
 GetRazdelLitr:=0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  FileMode:=OldFileMode;
  RazdelError(l,Path.ToRazdel+'razdel.db'+' Код:['+c+']');
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   Repeat
   Read(f,s);
   Code:=IOResult;
   If (Code in [5,150]) Then
    Begin
     Seek(f,L);
     DInfoNetMsg('База разделов. Идет чтение позиции: '+C);

    End;
   Until Not(Code in[5,150]);
   NoNetInfoMsg;
   Code:=IOResult;
   Close(f);
   GetRazdelLitr:=S.EnableLitr;
   FileMode:=OldFileMode;
  End;
End;


Function GetRazdelState(C:ArtikulStr):Boolean;
Var f : File of RazdelType;
    l : LongInt;
    Code : Integer;
    s : RazdelType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign(f,Path.ToRazdel+'razdel.db');
 GetRazdelState:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  FileMode:=OldFileMode;
  RazdelError(l,Path.ToRazdel+'razdel.db'+' Код:['+c+']');
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   Repeat
   Read(f,s);
   Code:=IOResult;
   If (Code in [5,150]) Then
    Begin
     Seek(f,L);
     DInfoNetMsg('База разделов. Идет чтение позиции: '+C);

    End;
   Until Not(Code in[5,150]);
   NoNetInfoMsg;
   Code:=IOResult;
   Close(f);
   GetRazdelState:=S.Locked;
   FileMode:=OldFileMode;
  End;
End;


Function GetClientField(Field:Byte;C:ArtikulStr;VidOperator:Byte):TEnjoyStr;
Var f : ClientFileType;
    l : LongInt;
    s : ClientType;
    st : ArtikulStr;
    Code : Integer;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
{
 If VidOperator=0 Then
 Assign(f,Path.ToClient+'Client.db')
 Else
 Assign(f,Path.ToClient+'Sklad.db');
}
Case VidOperator Of
0:Assign (f,Path.ToClient+'Client.db');
1:Assign (f,Path.ToClient+'Sklad.db');
2:Assign (f,Path.ToClient+'Barter.db');
Else;
End;

 GetClientField:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла клиентов!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   ReadClient(f,s);
   Close(f);
   FileMode:=OldFileMode;
   Case Field Of
    fClient,
    FMake  : GetClientField:=S.Name;

    FFFName: GetClientField:=S.FullName;
    fSrok  : GetClientField:=S.SrokLizensia;
    Fregion: Begin
              Str(S.Region:1,St);
              GetClientField:=St;
             End;
    FDebit : Begin
              Str(S.Debit:1,St);
              GetClientField:=St;
             End;
    FShkala: Begin
              Str(S.ClientShkala:1,St);
              GetClientField:=St;
             End;
    FMessages:GetClientField:=S.Messages;

    fEnvir : GetClientField:=S.EnviropMent;
    fINN   : GetClientField:=S.Inn;
    fOkonh : GetClientField:=S.Okonh;
    fOkpo  : GetClientField:=S.Okpo;
    fRSh   : GetClientField:=S.R_Sh;
    fGde   : GetClientField:=S.Gde;
    fGorod : GetClientField:=S.Gorod;
    fAdress: GetClientField:=S.Adress;
    fLimit : GetClientField:=S.Limit;
    fNoLimit : GetClientField:=IntToStr(S.NoLimit,CKol);
    FAgKod   : GetClientField:=S.AgentKod[1];
    FAgSamKod: GetClientField:=S.AgentKod[1];
    FAgVenKod: GetClientField:=S.AgentKod[2];
  fTelefon : GetClientField:=S.Telefon;
    fKod   : GetClientField:=S.Kod;
    fDolg  : GetClientField:=CalcDolg(S.Kod);
    fMaska : GetClientField:=Copy(S.Name,length(S.Name)-1,2);
    FcProz : GetClientField:=S.Prozent;
  fNDogovor: GetClientField:=S.Dogovor;
    fPunkt :Begin
            Code:=0;
            For l:=1 to CPunkt Do
             Begin
              Code:=Code+StrToInt(S.Punkt[l]);
             End;
             Str(Code:2,St);
             GetClientField:=St;
           End;
     fPunkt1: GetClientField:=S.Punkt[1];
     fPunkt2: GetClientField:=S.Punkt[2];
     FMarsh:  GetClientField:=S.Punkt[4];
    Else;
   End;
  End;
  If Not(s.Employ) And (Field<>FPunkt) Then GetClientField:='!!!КЛИЕНТ УДАЛЕН!!!';
End;




Function GetMakeField(Field:Byte;C:ArtikulStr;VidOperator:Byte):TEnjoyStr;
Var f : ClientFileType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    st : ArtikulStr;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
{
 If VidOperator=0 Then
 Assign(f,Path.TOClient+'Make.db')
 Else
 Assign(f,Path.TOClient+'Sklad.db');
}
Case VidOperator Of
0:Assign (f,Path.ToClient+'Make.db');
1:Assign (f,Path.ToClient+'Sklad.db');
2:Assign (f,Path.ToClient+'Barter.db');
Else;
End;


 GetMakeField:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла поставщиков!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   Code:=IOResult;
   ReadClient(f,s);

   Close(f);
   FileMode:=OldFileMode;
   Case Field Of
    fClient,
    FMAke  : GetMakeField:=S.Name;
    fSrok  : GetMakeField:=S.SrokLizensia;
    FDebit : Begin
              Str(S.Debit:1,St);
              GetMakeField:=St;
             End;
    FShkala: Begin
              Str(S.ClientShkala:1,St);
              GetMAkeField:=St;
             End;
  FMessages:GetMAkeField:=S.Messages;
    fEnvir : GetMakeField:=S.Enviropment;
    fINN   : GetMakeField:=S.Inn;
    fOkonh : GetMakeField:=S.Okonh;
    fOkpo  : GetMakeField:=S.Okpo;
    fRSh   : GetMakeField:=S.R_Sh;
    fGde   : GetMakeField:=S.Gde;
    fGorod : GetMakeField:=S.Gorod;
    fAdress: GetMakeField:=S.Adress;
    fLimit : GetMakeField:=S.Limit;
  fTelefon : GetMakeField:=S.Telefon;

{    fDolg  : GetMakeField:=S.Dolg;}
    fKod   : GetMakeField:=S.Kod;
  fNDogovor: GetMakeField:=S.Dogovor;
    fPunkt :Begin
            Code:=0;
            For l:=1 to CPunkt Do
             Begin
              Code:=Code+StrToInt(S.Punkt[l]);
             End;
             Str(Code:2,St);
             GetMakeField:=St;
           End;
    Else;
   End;
  End;
  If Not(s.Employ) And (Field<>FPunkt) Then GetMakeField:='!!!КЛИЕНТ УДАЛЕН!!!';
End;


Function GetClientState(C:ArtikulStr;VidOperator:Byte):Boolean;
Var f : ClientFileType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
{
 If VidOperator=0 Then
 Assign(f,Path.TOClient+'Client.db')
 Else
 Assign(f,Path.TOClient+'Sklad.db');
}
Case VidOperator Of
0:Assign (f,Path.ToClient+'Client.db');
1:Assign (f,Path.ToClient+'Sklad.db');
2:Assign (f,Path.ToClient+'Barter.db');
Else;
End;

 GetClientState:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла клиентов!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   ReadClient(f,s);
   Close(f);
   GetClientState:=S.Stat;
   FileMode:=OldFileMode;
  End;
End;

Function GetClientLockSrok(C:ArtikulStr;VidOperator:Byte):ArtikulStr;
Var f : ClientFileType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
{
 If VidOperator=0 Then
 Assign(f,Path.TOClient+'Client.db')
 Else
 Assign(f,Path.TOClient+'Sklad.db');
}
Case VidOperator Of
0:Assign (f,Path.ToClient+'Client.db');
1:Assign (f,Path.ToClient+'Sklad.db');
2:Assign (f,Path.ToClient+'Barter.db');
Else;
End;

 GetClientLockSrok[0]:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла клиентов!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   ReadClient(f,s);
   Close(f);
   GetClientLockSrok:=S.Test_Srok;
   FileMode:=OldFileMode;
  End;
End;

Function GetClientStatus(C:ArtikulStr;VidOperator:Byte):Boolean;
Var f : ClientFileType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
{ 
 If VidOperator=0 Then
 Assign(f,Path.TOClient+'Client.db')
 Else
 Assign(f,Path.TOClient+'Sklad.db');
}
Case VidOperator Of
0:Assign (f,Path.ToClient+'Client.db');
1:Assign (f,Path.ToClient+'Sklad.db');
2:Assign (f,Path.ToClient+'Barter.db');
Else;
End;

 GetClientStatus:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла клиентов!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   ReadClient(f,s);
   Close(f);
   GetClientStatus:=S.LockTime;
   FileMode:=OldFileMode;
  End;
End;


Function SetClientStatus(C:ArtikulStr;VidOperator:Byte;Status:Boolean):Boolean;
Var f : ClientFileType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
Begin
 SetClientStatus:=False;
{
 If VidOperator=0 Then
 Assign(f,Path.TOClient+'Client.db')
 Else
 Assign(f,Path.TOClient+'Sklad.db');
}
Case VidOperator Of
0:Assign (f,Path.ToClient+'Client.db');
1:Assign (f,Path.ToClient+'Sklad.db');
2:Assign (f,Path.ToClient+'Barter.db');
Else;
End;

 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла клиентов!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   ReadClient(f,s);

   Seek(f,Filepos(f)-1);
   l:=IoResult;

   Repeat
   Pause(1);
   Until (Lock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType)));

   S.LockTime:=Status;
   l:=IoResult;

   Write(f,s);
   l:=IoResult;

   Seek(f,Filepos(f)-1);
   Repeat
   Unlock(f,FilePos(f)*SizeOf(ClientType),SizeOf(ClientType));
   Until DosError=0;
   Close(f);
   l:=IoResult;
   SetClientStatus:=True;

  End;
End;

Function GetClientOpt(C:ArtikulStr;VidOperator:Byte):Boolean;
Var f : ClientFIleType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
{
 If VidOperator=0 Then
 Assign(f,Path.TOClient+'Client.db')
 Else
 Assign(f,Path.TOClient+'Sklad.db');
}
Case VidOperator Of
0:Assign (f,Path.ToClient+'Client.db');
1:Assign (f,Path.ToClient+'Sklad.db');
2:Assign (f,Path.ToClient+'Barter.db');
Else;
End;

 GetClientOpt:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла клиентов!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   ReadClient(f,s);
   Close(f);
   GetClientOpt:=S.Opt;
   FileMode:=OldFileMode;
  End;
End;


Function GetClientEmploy(C:ArtikulStr;VidOperator:Byte):Boolean;
Var f : ClientFIleType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
{
 If VidOperator=0 Then
 Assign(f,Path.TOClient+'Client.db')
 Else
 Assign(f,Path.TOClient+'Sklad.db');
}
Case VidOperator Of
0:Assign (f,Path.ToClient+'Client.db');
1:Assign (f,Path.ToClient+'Sklad.db');
2:Assign (f,Path.ToClient+'Barter.db');
Else;
End;

 GetClientEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла клиентов!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   ReadClient(f,s);
   Close(f);
   GetClientEmploy:=S.Employ;
   FileMode:=OldFileMode;
  End;
End;



Function GetMAkeEmploy(C:ArtikulStr;VidOperator:Byte):Boolean;
Var f : ClientFileType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
{
 If VidOperator=0 Then
 Assign(f,Path.TOClient+'MAke.db')
 Else
 Assign(f,Path.TOClient+'Sklad.db');
}

Case VidOperator Of
0:Assign (f,Path.ToClient+'Make.db');
1:Assign (f,Path.ToClient+'Sklad.db');
2:Assign (f,Path.ToClient+'Barter.db');
Else;
End;

 GetMakeEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла поставщиков!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   ReadClient(f,s);
   Close(f);
   GetMAkeEmploy:=S.Employ;
   FileMode:=OldFileMode;
  End;
End;


Var Skl : PSkladType;
    Fskl : SkladFileType;
    FId  : BazFileType;
    Id   : PBazType;

Function GetIdLocked(C:ArtikulStr):Boolean;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fId,Path.TOName+c+'.id');
 GetIdLocked:=True;
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NAmeError(l,Path.TOName++c+'.id'+' Код:['+st+']');
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Seek(fid,L);
   New(id,Init);
   Code:=IOResult;
   ReadBazPointer(FId,Id);
   Code:=IOResult;
   Close(fid);
   Code:=IOResult;
   FileMode:=OldFileMode;
   GetIDLocked:=Id^.Dat.Locked;
  End;
  If Not(Id^.Dat.Employ) Then GetIDLocked:=True;
  Dispose(Id,Done);
End;

Function GetIdZapretOpt(C:ArtikulStr):Boolean;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fId,Path.TOName+c+'.id');
 GetIdZapretOpt:=false;
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NAmeError(l,Path.TOName++c+'.id'+' Код:['+st+']');
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Seek(fid,L);
   New(id,Init);
   Code:=IOResult;
   ReadBazPointer(FId,Id);
   Code:=IOResult;
   Close(fid);
   Code:=IOResult;
   FileMode:=OldFileMode;
   GetIdZapretOpt:=Id^.Dat.ZapretOpt;
  End;
  If Id^.Dat.ZapretOpt Then GetIdZapretOpt:=True;
  Dispose(Id,Done);
End;


Function GetIDField(Field:Byte;C:ArtikulStr):TEnjoyStr;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fId,Path.TOName++c+'.id');
 GetIdField[0]:=#0;
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NAmeError(l,Path.TOName++c+'.id'+' Код:['+st+'] Код:'+IntToStr(l,CKol));
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Code:=IOResult;
   Seek(fid,L);
   New(id,Init);
   Code:=IOResult;
   ReadBazPointer(FId,Id);
   Code:=IOResult;
   Close(fid);
   FileMode:=OldFileMode;
   Case Field Of
  FFFName:Begin
           DelSpaceRight(Id^.Dat.Name);
           DelSpaceRight(Id^.Dat.Name2);
           GetIdField:=Id^.Dat.Name+' '+Id^.Dat.Name2;
          End;

  FName  : GetIdField:=Id^.Dat.Name;
  FName2 : GetIdField:=Id^.Dat.Name2;
  FFName : GetIdField:=Id^.Dat.FullName;
  FFName2: GetIdField:=Id^.Dat.FullName2;
  FLitr  : GetIdField:=Id^.Dat.Litr;
  FEnableOtdel : GetIdField:=IntToStr(Id^.Dat.EnableOtdel,CKol);
  FInPack: GetIdField:=Id^.Dat.InPack;
  FMarker: GetIdField:=Id^.Dat.Marker;
 FMinimum: GetIdField:=IntToStr(StrToInt(Id^.Dat.Minimum),CKol);
 FMinNAzenka : GetIdField:=Id^.Dat.MinNazenka;
FOperator: GetIdField:=Id^.Dat.CAption;
    FLock: GetIdField:=Id^.Dat.LockCAption;

  FNalog:GetIdField:=Id^.Dat.Nalog;
  FVidNalog:Begin
             Str(Id^.Dat.VidNalog:COne,St);
             DelSpace(St);
             GetIdField:=St;
            End;
  FNDS     :GetIdField:=Id^.Dat.NDS;
  FVol     :GetIdField:=Id^.Dat.Vol;
  FProz    :GetIdField:=Id^.Dat.DostProc;
  FVidNDS  :Begin
             Str(Id^.Dat.VidNDS:COne,St);
             DelSpace(St);
             GetIdField:=St;
            End;
  FMera    : Begin
              Case Id^.Dat.Mera Of
              0:st:='шт';
              1:st:='кг';
              2:st:='мш';
              3:st:='л ';
              4:st:='бл';
              Else St:='??';
              End;{Case}
              GetIdField:=St;
             End;
   Else;
   End;{CAse}
  End;
  If Not(Id^.Dat.Employ) And (Field in [FFName,FNAme]) Then GetIDField:='!!!ТОВАР УДАЛЕН!!!';
  Dispose(Id,Done);
End;

Function GetIDEmploy(C:ArtikulStr):Boolean;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fId,Path.TOName+c+'.id');
 GetIdEmploy:=False;
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NAmeError(l,Path.TOName++c+'.id'+' Код:['+st+'] Код:'+IntToStr(l,CKol));
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Seek(fid,L);
   New(id,Init);
   Code:=IOResult;
   ReadBazPointer(FID,Id);
   Close(fid);
   GetIdEmploy:=Id^.Dat.Employ;
   FileMode:=OldFileMode;
  End;
  Dispose(Id,Done);
End;

Function GetIdRealiz(C:ArtikulStr):Boolean;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fId,Path.TOName+c+'.id');
 GetIdRealiz:=False;
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NAmeError(l,Path.TOName++c+'.id'+' Код:['+st+'] Код:'+IntToStr(l,CKol));
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Seek(fid,L);
   New(id,Init);
   Code:=IOResult;
   ReadBazPointer(FID,Id);
   Close(fid);
   GetIdRealiz:=Id^.Dat.Realiz;
   FileMode:=OldFileMode;
  End;
  Dispose(Id,Done);
End;

Function GetIDMarket(C:ArtikulStr):Integer;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fId,Path.TOName+c+'.id');
 GetIdMarket:=0;
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NAmeError(l,Path.TOName++c+'.id'+' Код:['+st+'] Код:'+IntToStr(l,CKol));
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Seek(fid,L);
   New(id,Init);
   Code:=IOResult;
   ReadBazPointer(fid,id);
   Close(fid);
   GetIdMarket:=Id^.Dat.Market;
   FileMode:=OldFileMode;
  End;
  Dispose(Id,Done);
End;

Procedure SetIDMarket(C:ArtikulStr;R:Word);
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
Begin
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fId,Path.TOName+c+'.id');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NAmeError(l,Path.TOName++c+'.id'+' Код:['+st+']');
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Seek(fid,L);
   New(id,Init);
   Code:=IOResult;
   ReadBazPointer(fid,id);
   Seek(fid,FilePos(fid)-1);
   Code:=IOResult;
   Id^.Dat.MArket:=r;
   WriteBazPointer(fid,id);
   Close(fid);
   Code:=IOResult;
  End;
  Dispose(Id,Done);
End;


Function BakGetField(Field:Byte;C:ArtikulStr;i:Byte):TEnjoyStr;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fskl,Path.TOSklad+c+'.db');
 BakGetField[0]:=#0;
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  BazError(l,Path.TOSklad++c+'.db'+' Код:['+st+'] Код:'+IntToStr(l,CKol));
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Code:=IOResult;
   Seek(fskl,L);
   Code:=IOResult;
   New(Skl,Init);
   ReadSkladPointer(fskl,Skl);
   Code:=IOResult;


   Close(fskl);
   Code:=IOResult;
   FileMode:=OldFileMode;
   Case Field Of
  FPost:BakGetField:=Skl^.Dat.Input.Post;
  FDiv:BakGetField:=Skl^.Dat.Input.DivisionS[i];
  FKol:BakGetField:=Skl^.Dat.Input.Kol;
  FAkzis:BakGetField:=Skl^.Dat.Input.Akzis1;
  FRealiz:BakGetField:=Skl^.Dat.Input.RealizovatDo;
  FNaklOsn : BakGetField:=Skl^.Dat.Input.Osn.NaklNumer;
  FDateOsn : BakGetField:=Skl^.Dat.Input.Osn.DateNakl;

  FNGroupKod,
  FGroup:Begin
         BakGetField:=Skl^.Dat.Input.NGroupKod;
         End;
  FSertif:
          BakGetField:=Skl^.Dat.Input.NSertif;
  FDateSertif:
          BakGetField:=Skl^.Dat.Input.DSertif;
  FKtoSertif:
          BakGetField:=Skl^.Dat.Input.KSertif;
  FNDS:BakGetField:=GetIdField(FNDS,Skl^.Dat.BazKod);
  FNalog:BakGetField:=GetIdField(FNalog,Skl^.Dat.BazKod);
  FRZena:BakGetField:=Skl^.Dat.Input.R_Zena;
  FOZena:BakGetField:=Skl^.Dat.Input.O_Zena;
FZakupka:BakGetField:=Skl^.Dat.Input.Zakupka;
  FDates:BakGetField:=Skl^.Dat.Date;
  FTimes:BakGetField:=Skl^.Dat.Time;
{  FOperator:BakGetField:=Skl^.Dat.Input.CAption;}
  FName:BakGetField:=GetIdField(FName,Skl^.Dat.BazKod);
  FFName:BakGetField:=GetIdField(FFName,Skl^.Dat.BazKod);
  FLitr:BakGetField:=GetIdField(FLitr,Skl^.Dat.BazKod);
  FInPack:BakGetField:=GetIdField(FInPack,Skl^.Dat.BazKod);
  FOperator:BakGetField:=GetIdField(FOperator,Skl^.Dat.BazKod);
  FLock:BakGetField:=GetIdField(FLock,Skl^.Dat.BazKod);

  FMake:Begin
        Str(Skl^.Dat.MAkeVid:CMakeKod,St);
        BakGetField:=St;
        End;
  FKMake:BakGetField:=Skl^.Dat.MAkeKod;
   Else;
   End;{CAse}
  End;
{  If Not(skl^.Dat.Employ) And (Field in [FFName,FNAme]) Then GetField:='!!!ТОВАР УДАЛЕН!!!';}
  Dispose(skl,Done);

End;


Procedure GetSkladRecord(Var SklDan:PSkladType);
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
       c : ArtikulStr;
       OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=SklDan^.Dat.BazKod;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fskl,Path.TOSklad+c+'.db');
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  BazError(l,Path.TOSklad++c+'.db'+' Код:['+st+'] Код:'+IntToStr(l,CKol));
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Seek(fskl,L);
   ReadSkladPointer(FSkl,SklDan);
   Close(fskl);
   FileMode:=OldFileMode;
  End;
End;


Function CalcPack(Kod,Kol:TDateString):AllStr;
 Var Code : Integer;
     INP,Pack,Itogo  : LongInt;
     ws : AllStr;
Begin
 CalcPack[0]:=#0;
 DElspace(Kol);
 Val(GetIdField(FInPack,Kod),INP,Code);
 Val(Kol,Itogo,Code);
 If Inp=0 Then Exit;
 Pack :=Itogo div Inp;
 If (Itogo-Pack*Inp)<>0 Then
  Begin
   Str(Pack:5,ws);
   Str((Itogo-Pack*Inp):3,Kol);
   ws:=Ws+'+'+Kol;
   Format(Ws,CPack);
  End
  Else
   Begin
    Str(Pack:5,ws);
    Format(Ws,CPack);
   End;
  CalcPack:=Ws;
End;

Function CalcPackNoFile(Kod,Kol:TDateString):AllStr;
 Var INP,Pack,Itogo  : LongInt;
     ws : AllStr;
Begin
 CalcPackNoFile[0]:=#0;
 DElspace(Kol);
 DElspace(Kod);
 Inp:=StrToInt(Kod);
 Itogo:=StrToInt(Kol);
 If Inp=0 Then Exit;
 Pack :=Itogo div Inp;


 If (Itogo-Pack*Inp)<>0 Then
  Begin
   Str(Pack:5,ws);
   Str((Itogo-Pack*Inp):3,Kol);
   ws:=Ws+'+'+Kol;
   Format(Ws,CPack);
  End
  Else
   Begin
    Str(Pack:5,ws);
    Format(Ws,CPack);
   End;
  CalcPackNoFile:=Ws;
End;

(*

Function GetTextSkidka(C:ArtikulStr):string[150];
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
Begin
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fskl,Print.PathToMain+c+'.db');
 GetTextSkidka[0]:=#0;
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  RazdelError;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   Val(c,l,Code);
   Seek(fskl,l);
   New(skl,Init);
   Read(fskl,skl^.Dat);
   Close(fskl);
   For l:=1 To 6 Do
   Begin
    Str(StrToReal(Skl^.Dat.Baz.Skidka[l].Up):CIZena:CMantissa,Skl^.Dat.Baz.Skidka[l].Up);
    Str(StrToReal(Skl^.Dat.Baz.Skidka[l].Proz):CLitr:CMantissa,Skl^.Dat.Baz.Skidka[l].Proz);
   End;
    GetTextSkidka:=Skl^.Dat.Baz.Skidka[1].Up+'-'+Skl^.Dat.Baz.Skidka[1].Proz+'% '+
                   Skl^.Dat.Baz.Skidka[2].Up+'-'+Skl^.Dat.Baz.Skidka[2].Proz+'% '+
                   Skl^.Dat.Baz.Skidka[3].Up+'-'+Skl^.Dat.Baz.Skidka[3].Proz+'%'^M+
                   Skl^.Dat.Baz.Skidka[4].Up+'-'+Skl^.Dat.Baz.Skidka[4].Proz+'% '+
                   Skl^.Dat.Baz.Skidka[5].Up+'-'+Skl^.Dat.Baz.Skidka[5].Proz+'% '+
                   Skl^.Dat.Baz.Skidka[6].Up+'-'+Skl^.Dat.Baz.Skidka[6].Proz+'%';

   Dispose(skl,Done);
  End;
End;

Function GetSkidkaOperator(C:ArtikulStr):TEnjoyStr;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
Begin
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 GetSkidkaOperator[0]:=#0;
 Assign(fskl,Print.PathToMain+c+'.db');
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  RazdelError;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   Val(c,l,Code);
   Seek(fskl,l);
   New(skl,Init);
   Read(fskl,skl^.Dat);
   Close(fskl);
   GetSkidkaOperator:=Skl^.Dat.Baz.Input.Caption;
   Dispose(skl,Done);
  End;
End;


Function GetSkidkaDAtes(C:ArtikulStr):TDateString;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;

Begin
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 GetSkidkaDates[0]:=#0;
 Assign(fskl,Print.PathToMain+c+'.db');
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  RazdelError;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   Val(c,l,Code);
   Seek(fskl,l);
   New(skl,Init);
   Read(fskl,skl^.Dat);
   Close(fskl);
   GetSkidkaDates:=Skl^.Dat.Date;
   Dispose(skl,Done);
  End;
End;

Function GetSkidkaTimes(C:ArtikulStr):TDateString;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
Begin
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 GetSkidkaTimes[0]:=#0;
 Assign(fskl,Print.PathToMain+c+'.db');
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  RazdelError;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   Val(c,l,Code);
   Seek(fskl,l);
   New(skl,Init);
   Read(fskl,skl^.Dat);
   Close(fskl);
   GetSkidkaTimes:=Skl^.Dat.Time;
   Dispose(skl,Done);
  End;
End;



Procedure GetSkidka(C:ArtikulStr; Var Sk : SkidkaType);
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
Begin
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fskl,Print.PathToMain+c+'.db');
 l:=IOResult;
 Reset(fskl);
 l:=IOResult;
 If l <> 0 Then
 Begin
  RazdelError;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   Val(c,l,Code);
   Seek(fskl,l);
   New(skl,Init);
   Read(fskl,skl^.Dat);
   Close(fskl);
   For l:=1 To 6 Do
   Begin
    DElSpace(Skl^.Dat.Baz.Skidka[l].Up);
    DElSpace(Skl^.Dat.Baz.Skidka[l].Proz);
    Sk.Skidka[l].Up:=Skl^.Dat.Baz.Skidka[l].Up;
    Sk.Skidka[l].Proz:=Skl^.Dat.Baz.Skidka[l].Proz;
    End;
   Dispose(skl,Done);
  End;
End;

Function GetSkidkaProz(Sa:ArtikulStr;T:Real):Real;
Var
    l : Word;
    code : Integer;
    c : Byte;
    st : ArtikulStr;
Begin
 GetSkidkaProz:=0.0;
 St := Copy(sa,1,CRazdelKod);
 Assign(fskl,Print.PathToMain+st+'.db');
 c:=IOResult;
 Reset(fskl);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'Не найден файл скидок!'^M+
   #3'Автоматическая скидка невозможна !',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Sa:=Copy(sa,1+CRazdelKod,CKod);
 Val(sa,l,Code);
 Seek(fskl,l);
 New(skl,Init);
 Read(fskl,skl^.Dat);
 Close(fskl);
 For c:=6 DownTo 1 Do
  Begin
   If StrToReal(Skl^.Dat.Baz.Skidka[c].Up)<=T Then
   Begin
    GetSkidkaProz:=StrToReal(Skl^.Dat.Baz.Skidka[c].Proz);
    Break;
   End;
  End;
 Dispose(Skl,Done);
End;

 *)

Var skid : PSkidkaType;


Function GetTextSkidka(C:ArtikulStr):string;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    s    : string[150];
    f    : SkidkaFileType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(f,Path.TOSkidki+c+'.skl');
 GetTextSkidka[0]:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  BazError(l,Path.TOSkidki+c+'.skl'+' Код:['+st+'] Код:'+IntToStr(l,CKol));
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   Val(c,l,Code);
   Seek(f,l);
   New(skid,Init);
   Code:=IOResult;
   ReadSkidka(f,Skid);
   Close(f);
   FileMode:=OldFileMode;
   For l:=1 To 6 Do
   Begin
    Str(StrToReal(Skid^.Dat.Skidka[l].Up):CIZena:CMantissa,Skid^.Dat.Skidka[l].Up);
    Str(StrToReal(Skid^.Dat.Skidka[l].Proz):CLitr+1:CMantissa+2,Skid^.Dat.Skidka[l].Proz);
   End;
    GetTextSkidka:=Skid^.Dat.Skidka[1].Up+'-'+Skid^.Dat.Skidka[1].Proz+'% '+
                   Skid^.Dat.Skidka[2].Up+'-'+Skid^.Dat.Skidka[2].Proz+'% '+
                   Skid^.Dat.Skidka[3].Up+'-'+Skid^.Dat.Skidka[3].Proz+'%'^M+
                   Skid^.Dat.Skidka[4].Up+'-'+Skid^.Dat.Skidka[4].Proz+'% '+
                   Skid^.Dat.Skidka[5].Up+'-'+Skid^.Dat.Skidka[5].Proz+'% '+
                   Skid^.Dat.Skidka[6].Up+'-'+Skid^.Dat.Skidka[6].Proz+'%';

   Dispose(skid,Done);
  End;
End;

Function GetSkidkaOperator(C:ArtikulStr):TEnjoyStr;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    s    : string[150];
    f    : SkidkaFileType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 GetSkidkaOperator[0]:=#0;
 Assign(f,Path.TOSkidki+c+'.skl');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  BazError(l,Path.TOSkidki+c+'.skl'+' Код:['+st+'] Код:'+IntToStr(l,CKol));
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   Val(c,l,Code);
   Seek(f,l);
   New(skid,Init);
   Code:=IOResult;
   ReadSkidka(f,Skid);
   Close(f);
   FileMode:=OldFileMode;
   GetSkidkaOperator:=Skid^.Dat.Caption;
   Dispose(skid,Done);
  End;
End;

Function GetSkidkaDAtes(C:ArtikulStr):TDateString;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    s    : string[150];
    f    : SkidkaFileType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 GetSkidkaDates[0]:=#0;
 Assign(f,Path.TOSkidki+c+'.skl');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  BazError(l,Path.TOSkidki+c+'.skl'+' Код:['+st+'] Код:'+IntToStr(l,CKol));
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   Val(c,l,Code);
   Seek(f,l);
   New(skid,Init);
   REadSkidka(f,Skid);
   Close(f);
   FileMode:=OldFileMode;
   GetSkidkaDates:=Skid^.Dat.Date;
   Dispose(skid,Done);
  End;
End;

Function GetSkidkaTimes(C:ArtikulStr):TDateString;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    s    : string[150];
    f    : SkidkaFIleType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 GetSkidkaTimes[0]:=#0;
 Assign(f,Path.TOSkidki+c+'.skl');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  BazError(l,Path.TOSkidki+c+'.skl'+' Код:['+st+'] Код:'+IntToStr(l,CKol));
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   Val(c,l,Code);
   Seek(f,l);
   New(skid,Init);
   ReadSkidka(f,Skid);
   Close(f);
   FileMode:=OldFileMode;
   GetSkidkaTimes:=Skid^.Dat.Time;
   Dispose(skid,Done);
  End;
End;


Procedure GetSkidka(C:ArtikulStr; Var Sk : SkidkaType);
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    s    : string[150];
    f    : SkidkaFIleType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(f,Path.TOSkidki+c+'.skl');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  BazError(l,Path.TOSkidki+c+'.skl'+' Код:['+st+'] Код:'+IntToStr(l,CKol));
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   Val(c,l,Code);
   Seek(f,l);
   New(skid,Init);
   Code:=IOResult;
   ReadSkidka(f,Skid);
   Close(f);
   FileMode:=OldFileMode;
   For l:=1 To CShkala Do
   Begin
    DElSpace(Skid^.Dat.Skidka[l].Up);
    DElSpace(Skid^.Dat.Skidka[l].Proz);
    DElSpace(Skid^.Dat.Skidka[l].MinNaz);
   End;
   Sk:=Skid^.Dat;
   Dispose(skid,Done);
  End;
End;

Function GetMinNazenka(C:ArtikulStr;I:Word):AllStr;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    s    : string[150];
    f    : SkidkaFIleType;
    OldFileMode: word;
Begin
 GetMinNazenka:='0';
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(f,Path.TOSkidki+c+'.skl');
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  BazError(l,Path.TOSkidki+c+'.skl'+' Код:['+st+'] Код:'+IntToStr(l,CKol));
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   Val(c,l,Code);
   Seek(f,l);
   New(skid,Init);
   Code:=IOResult;
   ReadSkidka(f,Skid);
   Close(f);
   FileMode:=OldFileMode;
   GetMinNazenka:=Skid^.Dat.Skidka[I].MinNaz;
   Dispose(skid,Done);
  End;
End;


Function GetSkidkaProz(Sa:ArtikulStr;Op:Word;ClKod:ArtikulStr;T:Real):Real;
Var s : PSkidkaType;
    f : SkidkaFileType;
    l : Word;
    code : Integer;
    c : Byte;
    st : ArtikulStr;
    Proz : TDateString;
    OldFileMode: word;
Begin
 GetSkidkaProz:=1.0000;

 If Op=0 Then
  Begin
   If TestSpecZenaProz(SA,ClKod,Proz) Then
    Begin
     GetSkidkaProz:=StrToReal(Proz);
     Exit;
    End;
  End;

 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 St := Copy(sa,1,CRazdelKod);
 Assign(f,Path.TOSkidki+st+'.skl');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'Не найден файл скидок!'^M+
   #3'Автоматическая скидка невозможна !',Nil,mfError+mfCancelButton);
   FileMode:=OldFileMode;
   Exit;
  End;
 Sa:=Copy(sa,1+CRazdelKod,CKod);
 Val(sa,l,Code);
 Seek(f,l);
 New(s,Init);
 Code:=IOResult;
 REadSkidka(F,s);
 Close(f);
 FileMode:=OldFileMode;
 For c:=6 DownTo 1 Do
  Begin
   If StrToReal(S^.Dat.Skidka[c].Up)<=T Then
   Begin
    GetSkidkaProz:=StrToReal(S^.Dat.Skidka[c].Proz);
    Break;
   End;
  End;
 Dispose(S,Done);
End;




Function GetPlataKredit(Region,Shkala,Docs:Word;Srok:LongInt):Real;
Var s : PKreditType;
    f : File Of KreditType;
    l : Word;
    code : Integer;
    c : Byte;
    st : ArtikulStr;
    Name : AllStr;
    OldFileMode: word;
Begin
 GetPlataKredit:=1.0000;

 If Srok<=0 Then Exit;

 If Abs(Srok)>=9 Then Srok:=9;

 If Not (Docs in[5,6,7,8]) Then
 Begin
  Exit;
 End;

Case Region of
0:Name:='office';
1:Name:='gorod';
2:Name:='region';
3:Name:='rezerv';
Else Exit;
End;


 If Shkala>0 Then
 Shkala:=Shkala-(6*Region)+1
 Else
    Shkala:=1;


 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign(f,Path.TODolg+Name+'.dlg');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'Не найден файл настройки платного кредита для региона!'
   ,Nil,mfError+mfCancelButton);
   FileMode:=OldFileMode;
   Exit;
  End;


 New(s,Init);
 Code:=IOResult;
 Read(F,s^.Dat);


 GetPlataKredit:=StrToReal(S^.DAt.Kredit[Shkala].Proz[Srok]);


 Close(f);
 c:=IOResult;

 Dispose(S,Done);
End;





Function GetShkalaProz(Sa:ArtikulStr;Sh:Word;Op:Word;ClKod:ArtikulStr):Real;
Var s : PSkidkaType;
    f : SkidkaFileType;
    l : Word;
    code : Integer;
    c : Byte;
    st : ArtikulStr;
    Proz : TDAteString;
    OldFileMode: word;
Begin
  GetShkalaProz:=1.0000;

 If Op=0 Then
  Begin
   If TestSpecZenaProz(SA,ClKod,Proz) Then
    Begin
     GetShkalaProz:=StrToReal(Proz);
     Exit;
    End;
  End;

 If sh=0 Then
 Begin
  GetShkalaProz:=1.0000;
  Exit;
 End;


 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 GetShkalaProz:=0.0;
 St := Copy(sa,1,CRazdelKod);
 Assign(f,Path.TOSkidki+st+'.skl');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'Не найден файл скидок!'^M+
   #3'Автоматическая скидка невозможна !',Nil,mfError+mfCancelButton);
   FileMode:=OldFileMode;
   Exit;
  End;
 Sa:=Copy(sa,1+CRazdelKod,CKod);
 Val(sa,l,Code);
 Seek(f,l);
 New(s,Init);
 Code:=IOResult;
 REadSkidka(F,s);
 Close(f);
 FileMode:=OldFileMode;
 GetShkalaProz:=StrToReal(S^.Dat.Skidka[Sh].Proz);
 Dispose(S,Done);
End;



Function GetShkalaMin(Sa:ArtikulStr;Sh:Word):Real;
Var s : PSkidkaType;
    f : SkidkaFileType;
    l : Word;
    code : Integer;
    c : Byte;
    st : ArtikulStr;
    OldFileMode: word;
Begin
 If sh=0 Then
 Begin
  GetShkalaMin:=1.0000;
  Exit;
 End;
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 GetShkalaMin:=0.0;
 St := Copy(sa,1,CRazdelKod);
 Assign(f,Path.TOSkidki+st+'.skl');
 c:=IOResult;
 Reset(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3'Не найден файл скидок!'^M+
   #3'Автоматическая скидка невозможна !',Nil,mfError+mfCancelButton);
   FileMode:=OldFileMode;
   Exit;
  End;
 Sa:=Copy(sa,1+CRazdelKod,CKod);
 Val(sa,l,Code);
 Seek(f,l);
 New(s,Init);
 Code:=IOResult;
 REadSkidka(F,s);
 Close(f);
 FileMode:=OldFileMode;
 GetShkalaMin:=StrToReal(S^.Dat.Skidka[Sh].MinNaz);
 Dispose(S,Done);
End;


Function GetReturnKol(SDoc,SDate,SClientKod,SBazKod,SDivision:TDateString;Vid:Word):ArtikulStr;
Var ClientReturnFile : File Of ClientNewVozwratType;
    ClientReturn     : PClientNewVozwratType;
    i : Word;
    L : LongInt;
    ws : AllStr;
    GetSKol : ArtikulStr;
    Find : Boolean;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 GetReturnKol[0]:=#0;
 GetSKol[0]:=#0;
 If Vid=0 Then
 Assign(ClientReturnFile,Path.TOReturn+SClientKod+'.cvz')
 Else
 Assign(ClientReturnFile,Path.TOReturn+SClientKod+'.svz');
 i:=IOResult;
 Reset(ClientReturnFile);
 i:=IOResult;
 If i<>0 Then
  Begin
   {возвратов не было}
   FileMode:=OldFileMode;
   Exit;
  End;
 New(ClientReturn,Init);
 SDoc:=ClearChar(Sdoc);
 While Not(Eof(ClientReturnFile)) Do
  Begin
   Read(ClientReturnFile,ClientReturn^.Dat);
   ClearChar(ClientReturn^.Dat.Return.Document);
   {Ищем возврат по исходному документу}
   If (ClientReturn^.Dat.Return.BasisDoc=SDoc) And (ClientReturn^.Dat.Return.BasisDate=SDate)
   And (ClientReturn^.Dat.Return.MakeKod=SClientKod) Then
    Begin{если мы нашли искомый документ}
     For i:=1 To ClientReturn^.Dat.Return.Amount Do
      Begin
       ws:=ClientReturn^.Dat.Return.VozwratElement[i].BazKod+'│'+
          ClientReturn^.Dat.Return.VozwratElement[i].Input.DivisionS;

       {если мы нашли позицию }
       If wS=SBazKod+'│'+SDivision Then
        Begin
         Str(StrToInt(GetSKol)+StrToInt(ClientReturn^.Dat.Return.VozwratElement[i].Input.Kol):CKol,GetSKol);
        End;
      End;{сканируем накладную}
    End;{если нашли документ}


  End;{КОнец сканирования файла}
 GetReturnKol:=GetSKol;
 Close(ClientReturnFile);
 FileMode:=OldFileMode;
 Dispose(ClientReturn,Done);
End;

Function GetReturnSkidka(SDoc,SDate,SClientKod:TDateString;Vid:Word):AllStr;
Var ClientReturnFile : File Of ClientNewVozwratType;
    ClientReturn     : PClientNewVozwratType;
    i : Word;
    L : LongInt;
    ws : AllStr;
    SKidka : AllStr;
    Find : Boolean;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 GetReturnSkidka[0]:=#0;
 Skidka[0]:=#0;
 If Vid=0 Then
 Assign(ClientReturnFile,Path.TOReturn+SClientKod+'.cvz')
 Else
 Assign(ClientReturnFile,Path.TOReturn+SClientKod+'.svz');
 i:=IOResult;
 Reset(ClientReturnFile);
 i:=IOResult;
 If i<>0 Then
  Begin
   {возвратов не было}
   FileMode:=OldFileMode;
   Exit;
  End;
 New(ClientReturn,Init);
 SDoc:=ClearChar(Sdoc);
 While Not(Eof(ClientReturnFile)) Do
  Begin
   Read(ClientReturnFile,ClientReturn^.Dat);
   ClearChar(ClientReturn^.Dat.Return.Document);
   {Ищем возврат по исходному документу}
   If (ClientReturn^.Dat.Return.BasisDoc=SDoc) And (ClientReturn^.Dat.Return.BasisDate=SDate)
   And (ClientReturn^.Dat.Return.MakeKod=SClientKod) Then
    Begin{если мы нашли искомый документ}
     Str(STrToReal(ClientReturn^.Dat.Return.Skidka)+StrToReal(Skidka):CIZena:CMantissa,Skidka);
    End;{если нашли документ}


  End;{КОнец сканирования файла}
 GetReturnSkidka:=Skidka;
 Close(ClientReturnFile);
 FileMode:=OldFileMode;
 Dispose(ClientReturn,Done);
End;

Function GetReturnStatus(SDoc,SDate,SClientKod:TDateString):Boolean;
Var ClientReturnFile : File Of ClientNewVozwratType;
    ClientReturn     : PClientNewVozwratType;
    i : Word;
    L : LongInt;
    ws : AllStr;
    GetSKol : ArtikulStr;
    Find : Boolean;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 GetReturnStatus:=False;
 Assign(ClientReturnFile,Path.TOReturn+SClientKod+'.cvz');
 i:=IOResult;
 Reset(ClientReturnFile);
 i:=IOResult;
 If i<>0 Then
  Begin
   {возвратов не было}
   FileMode:=OldFileMode;
   Exit;
  End;
 New(ClientReturn,Init);
 SDoc:=ClearChar(Sdoc);
 Find:=False;
 While Not(Eof(ClientReturnFile)) And Not(Find)Do
  Begin
   Read(ClientReturnFile,ClientReturn^.Dat);
   ClearChar(ClientReturn^.Dat.Return.Document);
   {Ищем возврат по исходному документу}
   If (ClientReturn^.Dat.Return.BasisDoc=SDoc) And (ClientReturn^.Dat.Return.BasisDate=SDate)
   And (ClientReturn^.Dat.Return.MakeKod=SClientKod) Then
                                                          Find:=True;

  End;{КОнец сканирования файла}
 GetReturnStatus:=Find;
 Close(ClientReturnFile);
 FileMode:=OldFileMode;
 Dispose(ClientReturn,Done);
End;

Function CreatClientDolgFile(E:PSuperMarketType):Boolean;
Var RealFile : File Of RealizasiaType;
    i : Byte;
Begin
 CreatClientDolgFile:=False;
 Assign(RealFile,Path.ToDolg+E^.Dat.ClientKod+'.dlg');
 i:=IOResult;
 Reset(RealFile);
 i:=IOResult;
 If i <> 0 Then
  Begin
   If MessageBox(#3'Файл задолженности клиента '^M+#3+Path.ToDolg+E^.Dat.ClientKod+'.dlg не найден!'^M+
   #3'Создать файл заново?'+
   +' Код:'+IntToStr(i,3),Nil,mfWarning+mfOkCancel)=cmOk Then
    Begin
        i:=IOResult;
        Rewrite(RealFile);
        i:=IOResult;
        If i<>0 Then
         Begin
          MessageBox(^m+#3'Не могу создать файл '^M+
          #3+Path.ToDolg+E^.Dat.ClientKod+'.dlg'+
                ' Код:'+IntToStr(i,3),Nil,mfError+mfCancelButton);
          Exit;
         End;
    End
    Else Exit;
  End;
 Close(RealFile);
 i:=IOResult;
 CreatClientDolgFile:=True;
End;

Function CreatRemoteClientDolgFile(E:PSuperMarketType):Boolean;
Var RealFile : File Of RealizasiaType;
    i : Byte;
Begin
 CreatRemoteClientDolgFile:=False;
 Assign(RealFile,Path.ToRemoteSklad+'DOLG\'+E^.Dat.ClientKod+'.dlg');
 i:=IOResult;
 Reset(RealFile);
 i:=IOResult;
 If i <> 0 Then
  Begin
   If MessageBox(#3'Файл задолженности клиента '^M+#3+Path.ToRemoteSklad+'DOLG\'+E^.Dat.ClientKod+'.dlg не найден!'^M+
   #3'Создать файл заново?'+
   +' Код:'+IntToStr(i,3),Nil,mfWarning+mfOkCancel)=cmOk Then
    Begin
        i:=IOResult;
        Rewrite(RealFile);
        i:=IOResult;
        If i<>0 Then
         Begin
          MessageBox(^m+#3'Не могу создать файл '^M+
          #3+Path.ToRemoteSklad+'DOLG\'+E^.Dat.ClientKod+'.dlg'+
                ' Код:'+IntToStr(i,3),Nil,mfError+mfCancelButton);
          Exit;
         End;
    End
    Else Exit;
  End;
 Close(RealFile);
 i:=IOResult;
 CreatRemoteClientDolgFile:=True;
End;

Function CreatClientStatFile(L:PSuperMarketType):Boolean;
Var Esf : File Of StatClientType;
    i : Byte;
Begin
 CreatClientStatFile:=False;
 Assign(esf,Path.ToClient+L^.Dat.ClientKod+'.his');
 i:=IOResult;
 Reset(esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
   If MessageBox(#3'Файл расчетов с клиентом '^M+#3+Path.ToClient+L^.Dat.ClientKod+'.his не найден!'^M+
   #3'Создать файл заново ?',Nil,mfWarning+mfOkCancel)=cmOk Then
    Begin
        i:=IOResult;
        Rewrite(Esf);
        i:=IOResult;
        If i<>0 Then
         Begin
          MessageBox(^m+#3'Не могу создать файл '^M+
          #3+Path.ToClient+L^.Dat.ClientKod+'.his'+
                ' Код:'+IntToStr(i,3),Nil,mfError+mfCancelButton);
          Exit;
         End;
    End
    Else Exit;
  End;
 Close(esf);
 i:=IOResult;
CreatClientStatFile:=True;
End;{Function}


Function GetAgentField(Field:Byte;C:ArtikulStr):TEnjoyStr;
Var f : ClientFileType;
    l : LongInt;
    s : ClientType;
    st : ArtikulStr;
    Code : Integer;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'Agent.db');

 GetAgentField:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла агентов!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   ReadClient(f,s);
   Close(f);
   FileMode:=OldFileMode;
   Case Field Of
    fClient,FAgent,
    FMake  : GetAgentField:=S.Name;
    fSrok  : GetAgentField:=S.SrokLizensia;
    FDebit : Begin
              Str(S.Debit:1,St);
              GetAgentField:=St;
             End;
    FMessages:GetAgentField:=S.Messages;

    fEnvir : GetAgentField:=S.EnviropMent;
    fINN   : GetAgentField:=S.Inn;
    fOkonh : GetAgentField:=S.Okonh;
    fOkpo  : GetAgentField:=S.Okpo;
    fRSh   : GetAgentField:=S.R_Sh;
    fGde   : GetAgentField:=S.Gde;
    fGorod : GetAgentField:=S.Gorod;
    fAdress: GetAgentField:=S.Adress;
    fLimit : GetAgentField:=S.Limit;
  fTelefon : GetAgentField:=S.Telefon;
    fKod   : GetAgentField:=S.Kod;
  fNDogovor: GetAgentField:=S.Dogovor;
    {номер отгрузочного отделения}
    fOtdel : GetAgentField:=S.Punkt[1];

    fPunkt :Begin
            Code:=0;
            For l:=1 to CPunkt Do
             Begin
              Code:=Code+StrToInt(S.Punkt[l]);
             End;
             Str(Code:2,St);
             GetAgentField:=St;
           End;
    Else;
   End;
  End;
  If Not(s.Employ) And (Field<>FPunkt) Then GetAgentField:='!!!АГЕНТ  УДАЛЕН!!!';
End;

Function GetAgentState(C:ArtikulStr):Boolean;
Var f : ClientFileType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'Agent.db');

 GetAgentState:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла агентов!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   ReadClient(f,s);
   Close(f);
   GetAgentState:=S.Stat;
   FileMode:=OldFileMode;
  End;
End;

Function GetAgentEmploy(C:ArtikulStr):Boolean;
Var f : ClientFIleType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'Agent.db');
 GetAgentEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла агентов!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   ReadClient(f,s);
   Close(f);
   GetAgentEmploy:=S.Employ;
   FileMode:=OldFileMode;
  End;
End;

Function GetLizoField(Field:Byte;C:ArtikulStr):TEnjoyStr;
Var f : ClientFileType;
    l : LongInt;
    s : ClientType;
    st : ArtikulStr;
    Code : Integer;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'lizo.db');

 GetLizoField:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла сотрудников!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   ReadClient(f,s);
   Close(f);
   FileMode:=OldFileMode;
   Case Field Of
    fClient,FAgent,
    FMake  : GetLizoField:=S.Name;
    FFName: GetLizoField:=S.FullName;
    fSrok  : GetLizoField:=S.SrokLizensia;
    FDebit : Begin
              Str(S.Debit:1,St);
              GetLizoField:=St;
             End;
    FMessages:GetLizoField:=S.Messages;

    fEnvir : GetLizoField:=S.EnviropMent;
    fINN   : GetLizoField:=S.Inn;
    fOkonh : GetLizoField:=S.Okonh;
    fOkpo  : GetLizoField:=S.Okpo;
    fRSh   : GetLizoField:=S.R_Sh;
    fGde   : GetLizoField:=S.Gde;
    fGorod : GetLizoField:=S.Gorod;
    fAdress: GetLizoField:=S.Adress;
    fLimit : GetLizoField:=S.Limit;
  fTelefon : GetLizoField:=S.Telefon;
    fKod   : GetLizoField:=S.Kod;
  fNDogovor: GetLizoField:=S.Dogovor;
    {номер отгрузочного отделения}
    fOtdel : GetLizoField:=S.Punkt[1];

    fPunkt :Begin
            Code:=0;
            For l:=1 to CPunkt Do
             Begin
              Code:=Code+StrToInt(S.Punkt[l]);
             End;
             Str(Code:2,St);
             GetLizoField:=St;
           End;
    Else;
   End;
  End;
  If Not(s.Employ) And (Field<>FPunkt) Then GetLizoField:='!!!СОТРУДНИК  УДАЛЕН!!!';
End;

Function GetLizoState(C:ArtikulStr):Boolean;
Var f : ClientFileType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'Lizo.db');

 GetLizoState:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла сотрудников!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   ReadClient(f,s);
   Close(f);
   GetLizoState:=S.Stat;
   FileMode:=OldFileMode;
  End;
End;

Function GetLizoEmploy(C:ArtikulStr):Boolean;
Var f : ClientFIleType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'Lizo.db');
 GetLizoEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла сотрудников!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   ReadClient(f,s);
   Close(f);
   GetLizoEmploy:=S.Employ;
   FileMode:=OldFileMode;
  End;
End;

Function GetEkspedField(Field:Byte;C:ArtikulStr):TEnjoyStr;
Var f : ClientFileType;
    l : LongInt;
    s : ClientType;
    st : ArtikulStr;
    Code : Integer;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'exped.db');

 GetEkspedField:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла экспедиторов!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   ReadClient(f,s);
   Close(f);
   FileMode:=OldFileMode;
   Case Field Of
    fClient,FAgent,
    FMake  : GetEkspedField:=S.Name;
    FFName: GetEkspedField:=S.FullName;
    fSrok  : GetEkspedField:=S.SrokLizensia;
    FDebit : Begin
              Str(S.Debit:1,St);
              GetEkspedField:=St;
             End;
    FMessages:GetEkspedField:=S.Messages;

    fEnvir : GetEkspedField:=S.EnviropMent;
    fINN   : GetEkspedField:=S.Inn;
    fOkonh : GetEkspedField:=S.Okonh;
    fOkpo  : GetEkspedField:=S.Okpo;
    fRSh   : GetEkspedField:=S.R_Sh;
    fGde   : GetEkspedField:=S.Gde;
    fGorod : GetEkspedField:=S.Gorod;
    fAdress: GetEkspedField:=S.Adress;
    fLimit : GetEkspedField:=S.Limit;
  fTelefon : GetEkspedField:=S.Telefon;
    fKod   : GetEkspedField:=S.Kod;
  fNDogovor: GetEkspedField:=S.Dogovor;
    {номер отгрузочного отделения}
    fOtdel : GetEkspedField:=S.Punkt[1];

    fPunkt :Begin
            Code:=0;
            For l:=1 to CPunkt Do
             Begin
              Code:=Code+StrToInt(S.Punkt[l]);
             End;
             Str(Code:2,St);
             GetEkspedField:=St;
           End;
    Else;
   End;
  End;
  If Not(s.Employ) And (Field<>FPunkt) Then GetEkspedField:='!!!ЭКСПЕДИТОР УДАЛЕН!!!';
End;

Function GetEkspedState(C:ArtikulStr):Boolean;
Var f : ClientFileType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'eksped.db');

 GetEkspedState:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла экспедиторов!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   ReadClient(f,s);
   Close(f);
   GetEkspedState:=S.Stat;
   FileMode:=OldFileMode;
  End;
End;

Function GetEkspedEmploy(C:ArtikulStr):Boolean;
Var f : ClientFIleType;
    l : LongInt;
    Code : Integer;
    s : ClientType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'exped.db');
 GetEkspedEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла экспедиторов!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   ReadClient(f,s);
   Close(f);
   GetEkspedEmploy:=S.Employ;
   FileMode:=OldFileMode;
  End;
End;



Procedure CalcReturnPosition(SDoc,SDate,SClientKod,SBazKod:TDateString;SDivision:artikulStr;Vid:Word;
                             Var Skol:ArtikulStr;Var St : String);
Var ClientReturnFile : File Of ClientNewVozwratType;
    ClientReturn     : PClientNewVozwratType;
    i : Word;
    L : LongInt;
    ws : AllStr;
         GetSKol : ArtikulStr;
    Find : Boolean;
    OldFileMode : Word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 St[0]:=#0;
 SKol[0]:=#0;
 If Vid=0 Then
 Assign(ClientReturnFile,Path.TOReturn+SClientKod+'.cvz')
 Else
 Assign(ClientReturnFile,Path.TOReturn+SClientKod+'.svz');
 i:=IOResult;
 Reset(ClientReturnFile);
 i:=IOResult;
 If i<>0 Then
  Begin
   {возвратов не было}
   FileMode:=OldFileMode;
   Exit;
  End;
 New(ClientReturn,Init);
 SDoc:=ClearChar(Sdoc);
 While Not(Eof(ClientReturnFile)) Do
  Begin
   Read(ClientReturnFile,ClientReturn^.Dat);
   ClearChar(ClientReturn^.Dat.Return.Document);
   {Ищем возврат по исходному документу}
   If (ClientReturn^.Dat.Return.BasisDoc=SDoc) And (ClientReturn^.Dat.Return.BasisDate=SDate)
   And (ClientReturn^.Dat.Return.MakeKod=SClientKod) Then
    Begin{если мы нашли искомый документ}
     For i:=1 To ClientReturn^.Dat.Return.Amount Do
      Begin
        If (ClientReturn^.Dat.Return.VozwratElement[i].BazKod=SBazKod) And
           (StrToInt(ClientReturn^.Dat.Return.VozwratElement[i].Input.DivisionS)
                  =StrToInt(SDivision)) Then
         Begin
        {если мы нашли позицию }
          Str(StrToInt(SKol)+StrToInt(ClientReturn^.Dat.Return.VozwratElement[i].Input.Kol):CKol,
                SKol);
          DelSpace(ClientReturn^.Dat.Return.Document);
          St:=St+' '+ClientReturn^.Dat.Return.Document+' от '+ClientReturn^.Dat.Return.DateC+' ';
                        End;
      End;{сканируем накладную}
    End;{если нашли документ}


  End;{Конец сканирования файла}
 Close(ClientReturnFile);
 FileMode:=OldFileMode;
 Dispose(ClientReturn,Done);
End;

Procedure GetKolFromOstat(DD:TDateString;Art:ArtikulStr;VAr Kol:AllStr);{4}
Var Itg : PNewItogType;
    ItogFile  : File Of NewItogType;
    Ext : AllStr;
    i : Word;
    Find : Boolean;
Begin
 Str(StrToInt(Rek.Kod):2,Ext);
 RFormatZerro(Ext,2);
 Assign(ItogFile,Path.ToArchiv+DD+'.p'+Ext);
 i:=IOResult;
 Reset(ItogFile);
 i:=IOResult;
 If i<>0 Then
  Begin
   If DD=FDate Then
    Begin
     Kol:=BakGetField(FKol,Art,0);
     DelSpace(Kol);
     Exit;
    End
   Else
    Begin
     Kol:='?';
     Exit;
    End;
  End;
  Find:=False;
  New(Itg,Init);
  Kol:='0';
  While Not(Eof(ItogFile)) And Not(Find) Do
        Begin
         Read(ItogFile,Itg^.Dat);
         {оптимизация поиска добавлена 27-02-2000}
         If StrToInt(Itg^.Dat.BazKod)>StrToInt(Art) Then Break;
    If (Itg^.Dat.BazKod=Art) Then
          Begin
                Kol:=Itg^.Dat.Ost;
                DelSpace(Kol);
                Find:=True;
                Break;
          End;
        End;

  Dispose(Itg,Done);
  i:=IOResult;
  Close(ItogFile);
  i:=IOResult;
End;

Function TestClientSrok(Kod:ArtikulStr;OperatorSelector:Word):Boolean;
Var f : Boolean;
Begin
 TestClientSrok:=False;
 f:=GetClientStatus(Kod,OperatorSelector);
 TestClientSrok:=f;
 If (f) Then
  Begin
   MessageBox(^M+#3'Клиент временно заблокирован!'^M+
                          #3'Немедленно позовите руководство!',
                         nil,mfInformation+mfCancelButton);
  End;
End;



Function GetPrihodStatus(Doc:ArtikulStr;Date:TDAteSTring):Word;
VAr  ef : PrihodFileType;
     Find : Boolean;
     i : Word;
     L : PPrihodType;
Begin
  GetPrihodStatus:=2;
  Assign(ef,Path.ToPrihod+Date+'.prh');
  i:=IOResult;
  Reset(ef);
  i:=IOResult;
  If i<>0 Then
   Begin
    MessageBox(#3+'Ошибка открытия '+Path.ToPrihod+
    Date+'.prh'+
               ' при поиске статуса прихода!'^M+#3+
               ClicProgrammer,Nil,mfInsertInApp+mfError+mfCancelButton);
    Exit;
   End;

  New(L,Init);
  DelSpace(Doc);
  Find:=False;


 {оптимизация поиска}
   If FileSize(ef)>(StrToInt(Doc)-1) Then
    Begin
     Seek(ef,StrToInt(Doc)-1);
     ReadPrihod(ef,L);
     DelSpace(L^.Dat.Document);
     If ((ClearChar(Doc)=ClearChar(L^.Dat.Document))And
     (Date=L^.Dat.DateC) ) Then
         Begin
             Find:=True;
         End
         Else Seek(ef,0);
    End;




  While Not(Eof(ef)) And Not(Find) Do
        Begin
         ReadPrihod(ef,L);
         DelSpace(L^.Dat.Document);
          If ((ClearChar(Doc)=ClearChar(L^.Dat.Document))And
          (Date=L^.Dat.DateC) ) Then Find:=True;
        End;

  If Not(Find) Then
   Begin
    {NoInfoMsg;}
    Dispose(L,Done);
    Close(Ef);
    MessageBox(#3'Документ N '+ClearChar(Doc)+
    ' от '+Date+' не найден (поиск статуса прихода)!'^M+
    #3+ClicProgrammer,Nil,mfError+mfCancelButton);
    Exit;
   End;

  If L^.Dat.Amount>0 Then
   Begin
    If StrToInt(L^.Dat.PrihodElement[1].Input.DivisionS[1])>0 Then GetPrihodStatus:=0
    Else GetPrihodStatus:=1;
   End;


  Dispose(L,Done);
  Close(Ef);
  {NoInfoMsg;}
End;


Function GetMarket(Er:PRealizasiaType;Var E:PSuperMarketType):Boolean;
VAr  ef : MarketFileType;
     Find : Boolean;
     i : Word;
     L : PSuperMarketType;
Begin
  GetMarket:=False;
  Assign(ef,Path.ToMarket+Er^.Dat.Market.DateC+'.mrk');
  i:=IOResult;
  Reset(ef);
  i:=IOResult;
  If i<>0 Then
   Begin
    MessageBox(#3+'Ошибка открытия '+Path.ToMarket+
    Er^.Dat.Market.DateC+'.mrk'+
               ' при поиске первичного документа консигнации!'^M+#3+
               ClicProgrammer,Nil,mfInsertInApp+mfError+mfCancelButton);
    Exit;
   End;
  New(L,Init);
  DelSpace(Er^.Dat.Market.Document);
  Find:=False;


 {оптимизация поиска}
   If FileSize(ef)>(StrToInt(Er^.Dat.Market.Document)-1) Then
    Begin
     Seek(ef,StrToInt(Er^.Dat.Market.Document)-1);
     ReadMarket(ef,L);
     DelSpace(L^.Dat.Document);
     If ((ClearChar(Er^.Dat.Market.Document)=ClearChar(L^.Dat.Document))And
     (Er^.Dat.Market.DateC=L^.Dat.DateC) And (L^.Dat.Active)) Then
         Begin
             Find:=True;
         End
         Else Seek(ef,0);
    End;




{ DInfoMsg('Ищу документ '+Er^.Dat.Market.Document+' от '+Er^.Dat.Market.DateC+'...',False);}
  While Not(Eof(ef)) And Not(Find) Do
        Begin
         ReadMarket(ef,L);
         DelSpace(L^.Dat.Document);
          If ((ClearChar(Er^.Dat.Market.Document)=ClearChar(L^.Dat.Document))And
          (Er^.Dat.Market.DateC=L^.Dat.DateC) And (L^.Dat.Active)) Then Find:=True;
        End;

  If Not(Find) Then
   Begin
    {NoInfoMsg;}
    Dispose(L,Done);
    Close(Ef);
    MessageBox(#3'Документ N '+ClearChar(Er^.Dat.Market.Document)+
    ' от '+Er^.Dat.Market.DateC+' не найден (поиск первичного документа)!'^M+
    #3+ClicProgrammer,Nil,mfError+mfCancelButton);
    Exit;
   End;
  E^.Dat:=L^.Dat;
  Dispose(L,Done);
  Close(Ef);
  {NoInfoMsg;}
  GetMarket:=True;
End;

Function CreatClientBarterFile(SClientKod:ArtikulStr):Boolean;
Var Esf : File Of StatClientType;
    i : Byte;
Begin
 CreatClientBarterFile:=False;
 Assign(esf,Path.ToBarter+SClientKod+'.brt');
 i:=IOResult;
 Reset(esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
   If MessageBox(#3'Файл расчетов с клиентом '^M+#3+Path.ToBArter+SClientKod+'.brt не найден!'^M+
   #3'Создать файл заново ?',Nil,mfWarning+mfOkCancel)=cmOk Then
    Begin
        i:=IOResult;
        Rewrite(Esf);
        i:=IOResult;
        If i<>0 Then
         Begin
          MessageBox(^m+#3'Не могу создать файл '^M+
          #3+Path.ToBarter+SClientKod+'.brt'+
		' Код:'+IntToStr(i,3),Nil,mfError+mfCancelButton);
          Exit;
         End;
    End
    Else Exit;
  End;
 Close(esf);
 i:=IOResult;
 CreatClientBarterFile:=True;
End;{Function}


Function GetKassaEmploy(C:ArtikulStr):Boolean;
Var f : OperationFileType;
    l : LongInt;
    Code : Integer;
    s : KassaOperation;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'Kassa.db');
 GetKAssaEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла кассовых операций!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);
   Seek(f,l);
   Code:=IOResult;
   ReadOperation(f,s);
   Close(f);
   GetKassaEmploy:=S.Employ;
   FileMode:=OldFileMode;
  End;
End;

Function GetOperationField(Field:Byte;C:ArtikulStr):TEnjoyStr;
Var f : OperationFileType;
    l : LongInt;
    s : KassaOperation;
    st : ArtikulStr;
    Code : Integer;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'kassa.db');

 GetOperationField:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла кассовых операций!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);
   Seek(f,l);
   ReadOperation(f,s);
   Close(f);
   FileMode:=OldFileMode;
   Case Field Of
    fClient,FAgent,FNAme,
    FMake  : GetOperationField:=S.Name;
    FStatus: GetOperationField:=IntToStr(S.Status,COne);
    Else;
   End;
  End;
  If Not(s.Employ) And (Field<>FPunkt) Then GetOperationField:='!!ОПЕРАЦИЯ УДАЛЕНА!';
End;

Function GetMarket1(As:DocumentEdit;Var E:PSuperMarketType):Boolean;
VAr  ef : MarketFileType;
     Find : Boolean;
     i : Word;
     L : PSuperMarketType;
Begin
  GetMarket1:=False;
  Assign(ef,Path.ToMarket+As.D+'.mrk');
  i:=IOResult;
  Reset(ef);
  i:=IOResult;
  If i<>0 Then
   Begin
    MessageBox(^M+#3+'Ошибка открытия '+Path.ToMarket+As.D+'.mrk!'^M+#3+
               ClicProgrammer,Nil,mfInsertInApp+mfError+mfCancelButton);
    Exit;
   End;
  New(L,Init);
  DelSpace(As.EditPosition);
  Find:=False;
 {оптимизация поиска}
   If FileSize(ef)>(StrToInt(As.EditPosition)-1) Then
    Begin
     Seek(ef,StrToInt(As.EditPosition)-1);
     ReadMarket(ef,L);
     DelSpace(L^.Dat.Document);
     If ((StrToInt(ClearChar(As.EditPosition))=StrToInt(ClearChar(L^.Dat.Document)))And
          (As.D=L^.Dat.DateC) And (L^.Dat.Active)) Then
         Begin
             Find:=True;
         End
         Else Seek(ef,0);
    End;

  While Not(Eof(ef)) And Not(Find) Do
        Begin
         ReadMarket(ef,L);
         DelSpace(L^.Dat.Document);
          If ((StrToInt(ClearChar(As.EditPosition))=StrToInt(ClearChar(L^.Dat.Document)))And
          (As.D=L^.Dat.DateC) And (L^.Dat.Active)) Then Find:=True;
        End;

  If Not(Find) Then
   Begin
    {NoInfoMsg;}
    Dispose(L,Done);
    Close(Ef);
    MessageBox(^M+#3'Документ N '+ClearChar(As.EditPosition)+
    ' от '+As.D+' не найден !'^M+
    #3+ClicProgrammer,Nil,mfInsertInApp+mfError+mfCancelButton);
    Exit;
   End;
  E^.Dat:=L^.Dat;
  Dispose(L,Done);
  Close(Ef);
  {NoInfoMsg;}
  GetMarket1:=True;
End;


Function GetBAzElement(C:ArtikulStr;Var E:BazType):Boolean;
Var l    : LongInt;
    Code : Integer;
    st   : ArtikulStr;
    OldFileMode: word;
Begin
 GetBAzElement:=False;
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 st:=c;
 DelSpace(st);
 c:=Copy(st,1,CRazdelKod);
 Assign(fId,Path.TOName+c+'.id');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NAmeError(l,Path.TOName++c+'.id'+' Код:['+st+']');
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   c:=Copy(st,1+CRazdelKod,CKod);
   L:=StrToInt(C);
   Seek(fid,L);
   New(id,Init);
   Code:=IOResult;
   ReadBazPointer(FId,Id);
   Close(fid);
   E:=Id^.Dat;
   FileMode:=OldFileMode;
   If Not(Id^.Dat.Employ) Then MessageBox
   (^M+#3'Позиция ('+Id^.Dat.BazKod+')'+' помечена как удаленная!',Nil,mfWarning+mfCancelButton);
   Dispose(Id,Done);
  End;
End;

Function GetImport(As:DocumentEdit;W: ArtikulStr;Var E:PImportSuperMarketType):Boolean;
VAr  ef : File Of ImportSuperMarketType;
     Find : Boolean;
     i : Word;
Begin
  GetImport:=False;
  Assign(ef,Path.ToImport+GetImportFileName(As,w));
  i:=IOResult;
  Reset(ef);
  i:=IOResult;
  If i<>0 Then
   Begin
    MessageBox(^M+#3+'Ошибка открытия '+Path.ToImport+GetImportFileName(As,w)+'!'^M+#3+
               ClicProgrammer,Nil,mfError+mfCancelButton);
    Exit;
   End;
  Read(ef,E^.Dat);

  i:=IOResult;
  Close(Ef);
  i:=IOResult;
  GetImport:=True;
End;


Function TestSpecZena(SArt:ArtikulStr;ClKod:ArtikulStr;SZakupka:TDAteString;VAr SpezZena:TDAteString):Boolean;
VAr c : Word;
    TovarFile : File Of TovarClientType;
    ToVarElement : TovarClientType;
    RTovarFile : File Of RAzdelClientType;
    RToVarElement : RAzdelClientType;
    Find : Boolean;
Begin
TestSpecZena:=FAlse;
SpezZena[0]:=#0;
Assign(TovarFile,Path.ToClient+ClKod+'.skl');
c:=IOResult;
Reset(TovarFile);
c:=IOResult;
Find := FAlse;
If c=0 Then
Begin
 While Not(Eof(TovarFile)) And Not (Find) DO
  Begin
   Read(ToVarFile,ToVArElement);
   If ToVArElement.Active Then
   Begin
    If TovarElement.BazKod=SArt Then
    Begin
     MyStr(StrToReal(SZakupka)*(1+StrToReal(ToVarElement.Nazenka)/100),CZena,CMantissa,SpezZena);
     {If StrToReal(SpezZena)<StrToReal(TovarElement.SpecZena) Then} SpezZena:=TovarElement.SpecZena;
     DelSpace(SpezZena);
     Find:=True;
     Break;
    End;
   End;
  End;{While}
  c:=IOResult;
  System.Close(TovarFile);
  c:=IOResult;
  TestSpecZena:=Find;
End;

If Not Find Then
Begin
Assign(RTovarFile,Path.ToClient+ClKod+'.rsk');
c:=IOResult;
Reset(RTovarFile);
c:=IOResult;
Find := FAlse;
If c=0 Then
Begin
 While Not(Eof(RTovarFile)) And Not (Find) DO
  Begin
   Read(RToVarFile,RToVArElement);
   If RToVArElement.Active Then
   Begin
    If StrToInt(Copy(RTovarElement.BazKod,1,2))=StrToInt(Copy(SArt,1,2)) Then
    Begin

     If RTovarElement.Vid=0 Then
     MyStr(StrToReal(SZakupka)*(1+StrToReal(RToVarElement.Nazenka)/100),CZena,CMantissa,SpezZena)
     Else
     Begin
      SZakupka:=BakGetField(FRZena,SArt,0);
      MyStr(StrToReal(SZakupka)*GetShkalaProz1(SArt,StrToInt(RTovarElement.Shkala)),CZena,CMantissa,SpezZena);
     End;
     DelSpace(SpezZena);
     Find:=True;
     Break;
    End;
   End;
  End;{While}
  c:=IOResult;
  System.Close(RTovarFile);
  c:=IOResult;
  TestSpecZena:=Find;
End
End;


End;



Function GetGroupEmploy(C:ArtikulStr):Boolean;
Var f : GroupFIleType;
    l : LongInt;
    Code : Integer;
    s : GroupType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'group.db');
 GetGroupEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла групп!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     MessageBox(^M+#3'Попытка чтения группы '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Code:=IOResult;
   ReadGroup(f,s);
   Close(f);
   GetGroupEmploy:=S.Employ;
   FileMode:=OldFileMode;
  End;
End;


Function GetGroupField(Field:Byte;C:ArtikulStr):TEnjoyStr;
Var f : GroupFileType;
    l : LongInt;
    s : GroupType;
    st : ArtikulStr;
    Code : Integer;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'Group.db');

 GetGroupField:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла групп!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     MessageBox(^M+#3'Попытка чтения группы '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   ReadGroup(f,s);
   Close(f);
   FileMode:=OldFileMode;
   Case Field Of
    FName,
    fClient,
    FMake  : GetGroupField:=S.GroupName;
    Else;
   End;
  End;
  If Not(s.Employ) Then GetGroupField:='!!!ГРУППА УДАЛЕНА!!';
End;


Function GetRewGroupEmploy(C:ArtikulStr):Boolean;
Var f : GroupFIleType;
    l : LongInt;
    Code : Integer;
    s : GroupType;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'rgroup.db');
 GetRewGroupEmploy:=False;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла групп!'+
  ^M+#3+'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   Val(c,l,Code);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     MessageBox(^M+#3'Попытка чтения группы '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Code:=IOResult;
   ReadGroup(f,s);
   Close(f);
   GetRewGroupEmploy:=S.Employ;
   FileMode:=OldFileMode;
  End;
End;


Function GetRewGroupField(Field:Byte;C:ArtikulStr):TEnjoyStr;
Var f : GroupFileType;
    l : LongInt;
    s : GroupType;
    st : ArtikulStr;
    Code : Integer;
    OldFileMode: word;
Begin
 OldFileMode:=FileMode;
 FileMode:=ReadOnly;
 Assign (f,Path.ToClient+'rGroup.db');

 GetRewGroupField:=#0;
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  MessageBox(^M+#3'Ошибка открытия файла групп!'+
  ^M+#3'Код:'+IntToStr(l,3),nil,mfError+mfCancelButton);
  FileMode:=OldFileMode;
  Exit;
 End
 Else
  Begin
   DelSpace(c);
   l:=StrToInt(c);

   If l>FileSize(f) Then
    Begin
     System.Close(f);
     MessageBox(^M+#3'Попытка чтения группы '+c+' - позиция вне файла!',nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   ReadGroup(f,s);
   Close(f);
   FileMode:=OldFileMode;
   Case Field Of
    FName,
    fClient,
    FMake  : GetRewGroupField:=S.GroupName;
    Else;
   End;
  End;
  If Not(s.Employ) Then GetRewGroupField:='!!!ГРУППА УДАЛЕНА!!';
End;



Function GetReturnDoc(As:DocumentEdit;Var E:PNewVozwratType):Boolean;
VAr  ef : NewVozwratFileType;
     Find : Boolean;
     i : Word;
     L : PNewVozwratType;
Begin
  GetReturnDoc:=False;
  Assign(ef,Path.ToReturn+As.D+'.vzw');
  i:=IOResult;
  Reset(ef);
  i:=IOResult;
  If i<>0 Then
   Begin
    MessageBox(^M+#3+'Ошибка открытия '+Path.ToReturn+As.D+'.vzw!'^M+#3+
               ClicProgrammer,Nil,mfInsertInApp+mfError+mfCancelButton);
    Exit;
   End;
  New(L,Init);
  DelSpace(As.EditPosition);
  Find:=False;
{ DInfoMsg('Ищу документ '+Er^.Dat.Market.Document+' от '+Er^.Dat.Market.DateC+'...',False);}



 {оптимизация поиска}
   If FileSize(ef)>(StrToInt(As.EditPosition)-1) Then
    Begin
     Seek(ef,StrToInt(As.EditPosition)-1);
     ReadNewVozwrat(ef,L);
     DelSpace(L^.Dat.Document);
     If ((StrToInt(ClearChar(As.EditPosition))=StrToInt(ClearChar(L^.Dat.Document)))And
          (As.D=L^.Dat.DateC) ) Then
         Begin
             Find:=True;
         End
         Else Seek(ef,0);
    End;




  While Not(Eof(ef)) And Not(Find) Do
        Begin
         ReadNewVozwrat(ef,L);
         DelSpace(L^.Dat.Document);
          If ((StrToInt(ClearChar(As.EditPosition))=StrToInt(ClearChar(L^.Dat.Document)))And
          (As.D=L^.Dat.DateC) ) Then Find:=True;
        End;

  If Not(Find) Then
   Begin
    {NoInfoMsg;}
    Dispose(L,Done);
    Close(Ef);
    MessageBox(^M+#3'Документ N '+ClearChar(As.EditPosition)+
    ' от '+As.D+' не найден !'^M+
    #3+ClicProgrammer,Nil,mfInsertInApp+mfError+mfCancelButton);
    Exit;
   End;
  E^.Dat:=L^.Dat;
  Dispose(L,Done);
  Close(Ef);
  {NoInfoMsg;}
  GetReturnDoc:=True;
End;






End.