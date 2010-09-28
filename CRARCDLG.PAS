Uses Glob, ServStr, NetDbEng, Dos, Dialogs, Objects, TPDate;
{ParamStr(1) - дата
 ParamStr(2) - код склада - 3 символа!!!!
 ParamStr(3) - путь к складу н. j:\newskl\ }


Var {OldClient: PBox;}
    R: TRect;
    f: text;
    sDate : TDAteString;
    IORez: word;
    str: string;


function FExists(FileName: TMyString): Boolean;
var
  F: file;
  Attr: Word;
begin
  Attr:=IOResult;
  Assign(F, FileName);
  GetFAttr(F, Attr);
  Attr:=IOResult;
  FExists := DosError = 0;
  Attr:=IOResult;
  DosError:=0;
end;


Function FindOldClient(Kod:AllStr; P: PBox): TEnjoyStr;
Var ls : Word;
    k  : Byte;
    s1,st : String[CArtikul];
Begin
FindOldClient:='';
For ls :=0 To P^.List^.Limit Do
 Begin
   ST:=Copy(P^.GetText(ls,P^.List^.Limit),6,4);
   If strtoint(St)=strtoint(KOd) Then
    Begin
     FindOldClient:=Copy(P^.GetText(ls,P^.List^.Limit),1,4);
     Break;
    End;
  End;
End;

Function FindOldList(Kod:AllStr; P: PBox): boolean;
Var ls : Word;
    k  : Byte;
    s1,st : String[CArtikul];
Begin
FindOldList:=false;
For ls :=0 To P^.List^.Limit Do
 Begin
   ST:=Copy(P^.GetText(ls,P^.List^.Limit),6,4);
   If StrToInt(St)=StrToInt(KOd) Then
    Begin
     FindOldList:=true;
     Break;
    End;
  End;
End;



Function FindNewClient(Kod:AllStr; P: PBox): boolean;
Var ls : Word;
    k  : Byte;
    s1,st : String[CArtikul];
Begin
FindNewClient:=false;
For ls :=0 To P^.List^.Limit Do
 Begin
   ST:=Copy(P^.GetText(ls,P^.List^.Limit),1,4);
   If StrToInt(St)=StrToInt(KOd) Then
    Begin
     if not FindOldList(ST,p) then FindNewClient:=true;
     Break;
    End;
  End;
End;




Function CalcDolg(s:ALLStr;s1:ALLStr):TEnjoyStr;
Label 1;
Var i : Byte;
    R : Real;
    Count : Word;
    c : Word;
    RealFile : File;
    E : PBufRealizasiaType;
Begin
r:=0;
Assign (RealFile,'works\nsklxp\dolg\'+s+'.dlg');
i:=Ioresult;
Reset(Realfile,SizeOf(RealizasiaType));
i:=IOresult;
If (i<>0) Then Begin
                s:='НЕТ_КОНСИГНАЦИИ';
                Goto 1;
               End;
While Not(Eof(RealFile)) Do
 Begin
  New(E,Init);
  {Read(RealFile,E^.Dat);}
  BlockRead(RealFile,E^.Point,BufferDLG,Count);
For c:=1 To Count Do
Begin
  If (E^.Point.Dat[c].Market.Active) Then
  If Not(E^.Point.Dat[c].FULL) Then  r:=r+E^.Point.Dat[c].Dolg;
End;{For}
 Dispose(E,Done);
 End;
i:=Ioresult;
Close(RealFile);
i:=Ioresult;


{ Assign(RealFile,'tmp\'+s1+'.dlg');
 if s<>s1 then
 begin
  if FExists('tmp\'+s1+'.dlg') then erase(RealFile);
  Assign(RealFile,'tmp\'+s+'.dlg');
  rename(RealFile,'tmp\'+s1+'.dlg');
 end;  }

MyStr(R,CIZena,CMantissa,s);
1:
DelSpace(S);
CalcDolg:=s;
End;


Function CalcDolgSF(s:ALLStr;s1:ALLStr):TEnjoyStr;
Label 1;
Var i : Byte;
    R : Real;
    Count : Word;
    c : Word;
    RealFile : File;
    E : PBufRealizasiaType;
Begin
r:=0;
Assign (RealFile,'tmp\'+s+'.dlg');
i:=Ioresult;
Reset(Realfile,SizeOf(RealizasiaType));
i:=IOresult;
If (i<>0) Then Begin
                s:='НЕТ_КОНСИГНАЦИИ';
                Goto 1;
               End;
While Not(Eof(RealFile)) Do
 Begin
  New(E,Init);
  {Read(RealFile,E^.Dat);}
  BlockRead(RealFile,E^.Point,BufferDLG,Count);
For c:=1 To Count Do
Begin
  If (E^.Point.Dat[c].Market.Active) Then
  If (E^.Point.Dat[c].Market.DocSelector in [3,4,6,8]) Then
  If Not(E^.Point.Dat[c].FULL) Then  r:=r+E^.Point.Dat[c].Dolg;
End;{For}
 Dispose(E,Done);
 End;
i:=Ioresult;
Close(RealFile);
i:=Ioresult;

IF DateStringToDate(DateMask,sDate)=DateStringToDate(DateMask,'24-07-02') THEN
BEGIN
 if s<>s1 then
 begin
  {Assign(RealFile,'tmp\'+s1+'.dlg');
  if FExists('tmp\'+s1+'.dlg') then erase(RealFile);}
  Assign(RealFile,'tmp\'+s+'.dlg');
  rename(RealFile,'tmp1\'+s1+'.dlg');
 end;
END;

MyStr(R,CIZena,CMantissa,s);
1:
DelSpace(S);
CalcDolgSF:=s;
End;




Function CalcDolgClient(Date : TDAteString):Boolean;
Var ClientFile : File of ClientType;
    ClientElement : ClientType;
    Find : Boolean;
    ClientDolgFile : File Of ClientDolgType;
    ClientDolgElement : ClientDolgType;
    c ,count : Word;
    sKOd: String[4];
    Kod, Code, OldPOs: word;
    {s : String;}
Begin
CalcDolgClient:=False;
Assign (ClientFile,ParamStr(3)+'client\Client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c=0 Then
Begin
Assign (ClientDolgFile,Date+'.d01');
c:=IOResult;
Rewrite (ClientDolgFile);
c:=IOResult;

If c<>0 Then
 Begin
  writeln('Ошибка создания '+Date+'.d01');
  close(ClientFile);
  Exit;
 End;

(*While Not(Eof(ClientFile)) Do
 Begin
   Read(ClientFile,ClientElement);
   ClientDolgElement.Kod:=ClientElement.Kod;
   ClientDolgElement.Dolg:=0.0000;
   ClientDolgElement.DolgSF:=0.0000;
   Write(ClientDolgFile,ClientDolgElement);
 End;{While}

 Reset(ClientFile);
 Reset(ClientDolgFile);  *)

While Not(Eof(ClientFile)) Do
 Begin
  { Writeln('Подсчитываю долги клиентов. Ждите... ');}


   Read(ClientFile,ClientElement);
  { if strtoint(ClientElement.Kod) = 942 then writeln(ClientElement.Kod);}
   ClientDolgElement.Kod:=ClientElement.Kod;
   ClientDolgElement.Dolg:=0.0000;
   ClientDolgElement.DolgSF:=0.0000;

(*IF DateStringToDate(DateMask,Date)<DateStringToDate(DateMask,'25-07-02') THEN
BEGIN
If ClientElement.Employ Then
 if not findNewClient(ClientElement.Kod,OldClient) then
   Begin
    sKOd:= FindOldClient(ClientElement.Kod,OldClient);
    DelSpace(sKOd);
    if sKOd='' then sKOd:=ClientElement.Kod;

    ClientDolgElement.Dolg:=StrToReal(CalcDolg(sKOd,ClientElement.Kod));
    ClientDolgElement.DolgSF:=StrToReal(CalcDolgSF(sKOd,ClientElement.Kod));
   End;
END
ELSE*)
BEGIN
If ClientElement.Employ Then
   Begin
    sKOd:=ClientElement.Kod;
    ClientDolgElement.Dolg:=StrToReal(CalcDolg(sKOd,ClientElement.Kod));
    ClientDolgElement.DolgSF:=StrToReal(CalcDolgSF(sKOd,ClientElement.Kod));
   End;
END;


    Write(ClientDolgFile,ClientDolgElement);

End{While};


System.Close(ClientFile);
System.Close(ClientDolgFile);


CalcDolgClient:=True;
End
Else
  writeln('Ошибка открытия '+ParamStr(3)+'Client.db');
End;


BEGIN

  sDate:=ParamStr(1);

  SWAPVECTORS;

    Exec (GetEnv('Comspec'),' /c '+ 'arj x -y+ '+ParamStr(1)+'.'+ParamStr(2)+' works\nsklxp\dolg\*.dlg');

  SWAPVECTORS;

(* R.Assign(0, 0, 0, 0);
 OldClient := New(PBox, Init(R, 1, Nil));
 OldClient^.NewList(New(PTextCollection, Init(0,1)));

 Assign(f,'s1.txt');
 IORez:=ioresult;
 reset(f);
 IORez:=ioresult;
 if IORez<>0 then
   begin
     writeln('Ошибка открытия s1.txt');
     SWAPVECTORS;
     Exec (GetEnv('Comspec'),' /c '+'del tmp\*.dlg ');
     SWAPVECTORS;
     exit;
   end;

 while not eof(f) do
 begin
  readln(f,str);
  OldClient^.List^.Insert(NewStr(str));
 end;    *)

 CalcDolgClient(sDate);

(*IF DateStringToDate(DateMask,sDate)=DateStringToDate(DateMask,'24-07-02') THEN
BEGIN
  SWAPVECTORS;

  Exec (GetEnv('Comspec'),' /c '+'copy tmp1\*.dlg tmp');

  SWAPVECTORS;

END; *)

  SWAPVECTORS;

  Exec (GetEnv('Comspec'),' /c '+'del works\nsklxp\dolg\*.dlg ');

  SWAPVECTORS;

  Writeln('OK!');

END.