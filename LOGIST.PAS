{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}
Unit Logist;

Interface

Uses Glob,Dialogs,Drivers,Access1,ServStr,kassa;

Type
  PReestrDostWindow = ^TReestrDostWindow;
  TReestrDostWindow = object(TDialog)
    Ag   : PLizoWindow;
    constructor Init(Var l: Boolean);
    procedure OpenReestrPWindow;
    {procedure FullPreview;}
    procedure HandleEvent(var Event: TEvent); virtual;
    Procedure FormPReport(Const p:PBox);
    procedure Refresh;
    procedure Oforml(Var st:AllStr;Var Res: Word);
  end;

IMPLEMENTATION

uses DBEngine,Objects, Views, MsgBox,{Vision,Calc,}Dos,Vision1,TpDate,Vision2,
     App, ColorTxt,Serv,{InpLong,}Validate,Tools,Printers,ComboBox,NetDbEng,
	Net,Utils,Prise,UtilsP;

var PrevAgent : String[CAll];
    DocList : PBox;
    ControlStatus,Control,ControlAllDoc,ControlAllSumma,ControlAllZakupka: PView;
    ControlMarsh : PView;
    PrevCur : TMyString;
    DocReestrPWindow:PReestrDostWindow;
    StartDate,StopDAte,DocDate : TDateString;
    Status ,Sorting : Word;
    StartTime:LongInt;
    Start,Stop,RefreshTime:LongInt;
    AllDoc,AllZakupka,AllSumma : String[CIZena];
    Marsh: string[CAll];


procedure TReestrDostWindow.OpenReestrPWindow;
Var l : Boolean;
begin
StartDate:=DateToDateString(DateMAsk,DateStringToDate(DateMask,FDate)-1);
StopDate:=FDate;
  if Message(Desktop, evBroadcast, cmReestrDost, nil) = nil then
  begin
    L:=True;
  If Not(DatePeriodDialog(StartDAte,StopDate,false)) Then Exit;
   start:=DateStringToDate(DAtemask,StartDate);
   stop:=DateStringToDate(DAtemask,StopDate);

    DInfo('���樠������ ॥��� ���㬥�⮢ ���⠢��...');
    DocReestrPWindow := New(PReestrDostWindow, Init(L));
    If L Then
    Begin
    Application^.InsertWindow(DocReestrPWindow);
    NoInfo;
    End
    Else
     Begin
      TekDate:=FDate;
      Dispose(DocReestrPWindow,Done);
      NoInfo;
     End;
  end
  else
    if PView(DocReestrPWindow) <> Desktop^.TopView then DocReestrPWindow^.Select;

end;


Procedure TReestrDostWindow.Refresh;
Var Fp : file of DostavkaType;
    s: TMyString;
    ws : AllStr;
    E : PDostavkaType;
    FPos:Byte;
    FS : AllStr;
    c : Word;
    R : TRect;
    Cur : LongInt;
    TempS : TDateString;
    mSorting:Maska3;
    mStatus:Maska2;

function FindMarsh(snew,stek:string):boolean;
var ws: string;
Begin
  FindMarsh:=false;

  Delspace(snew);
  Delspace(stek);

  if snew='' then
  begin
   FindMarsh:=true;
   exit;
  end;

  if length(snew)<=2 then
  begin
   if StrToInt(stek)=StrToInt(snew) then FindMarsh:=true;
   exit;
  end
  else
  Begin
   while pos('-',snew)>0 do
   begin
    ws:=copy(snew,1,pos('-',snew)-1);
    system.delete(snew,1,pos('-',snew));
    if StrToInt(stek)=strtoint(ws) then
    begin
     FindMarsh:=true;
     exit;
    end;
   end;
   ws:=snew;
   if StrToInt(stek)=strtoint(ws) then FindMarsh:=true;
  End;
End;

Begin

DInfo('�������...');
New(E,Init);
AllDoc[0]:=#0;
AllSumma[0]:=#0;
AllZakupka[0]:=#0;

DocList^.NewList(Nil);
DocList^.NewList(New(PMyCollection, Init(0,1)));

ControlStatus^.GetData(Status);
WordToBit3(Sorting,mSorting);
Convert3(mSorting);
WordToBit2(STatus,mStatus);
Convert2(mStatus);


For Cur:=Start To Stop Do
Begin
c:=IOResult;
TempS:=DAteToDateString(DAteMask,Cur);
Assign(fp,Path.ToMarket+TempS+'.dst');
Reset(fp);
c:=IOResult;
If c=0 Then
 Begin
While Not(Eof(Fp)) Do
 Begin
  Read(Fp,E^.Dat);
  if FindMarsh(Marsh,E^.Dat.Marsh) then
  If ((mstatus[1]=1) And (E^.Dat.Oformlen)) or
     ((mstatus[2]=1) And (not E^.Dat.Oformlen))
  Then
   Begin
    Str(StrToInt(AllDoc)+1:CLitrMantissa,AllDoc);
    DelSpace(AllDoc);
    s:=GetClientField(FClient,E^.Dat.ClientKod,0);
    Format(S,CClient);
    s:=s+'�';
    RFormatZerro(E^.Dat.DocOsn,CDocNumer);
    Format(E^.Dat.DocOsn,CDocNumer);
    Format(E^.Dat.DateDost,CDate);
    s:=s+E^.Dat.DocOsn+{'�'+E^.Dat.DateC}+'�'+E^.Dat.DateDoc+'�';
    DelSpace(E^.Dat.SumOplata);
    RFormat(E^.Dat.SumOplata,CIZena);
    DelSpace(E^.Dat.SumOplata);
    RFormat(E^.Dat.SumOplata,CIZena);
    Str(StrToReal(AllSumma)+StrToReal(E^.Dat.SumOplata):CIZena:CMantissa,AllSumma);
    DelSpace(AllSumma);
    Str(StrToReal(AllZakupka)+StrToReal(E^.Dat.SumOplata):CIZena:CMantissa,AllZakupka);
    DelSpace(AllZakupka);
    s:=s+E^.Dat.SumOplata+'�'+E^.Dat.DateDost+'�';
    if E^.Dat.EkspedKod<>'' then
    ws:=GetLizoField(FAgent,E^.Dat.EkspedKod)
    else ws:='';
    format(ws,15);
    s:=s+ws+'�'+E^.Dat.Marsh;
    DocList^.List^.Insert(NewStr(s));
    DocList^.SetRange(DocList^.List^.Count);
   End;{If StatusDoc=0}
 End;{While}
System.Close(Fp);
End;{If IOResult}
End;{For}
Dispose(E,Done);
DocList^.FocusItem(0);


Str(StrToReal(AllSumma):CIZena:CMantissa,AllSumma);
DelSpace(AllSumma);
Str(StrToReal(AllZakupka):CIZena:CMantissa,AllZakupka);
DelSpace(AllZakupka);

Str(StrToInt(AllDoc):CLitrMantissa,AllDoc);
DelSpace(AllDoc);



Dispose(ControlAllSumma,Done);
R.Assign(64, 22, 79, 23);
ControlAllSumma := New(PColoredText, Init(R, #3+AllSumma, $4E));
Insert(ControlAllSumma);

Dispose(ControlAllZakupka,Done);
R.Assign(16, 22, 31, 23);
ControlAllZakupka := New(PColoredText, Init(R, #3+AllZakupka, $4E));
Insert(ControlAllZakupka);

Dispose(ControlAllDoc,Done);
R.Assign(44, 22, 48, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);
NoInfo;

End;


constructor TReestrDostWindow.Init(Var l : Boolean);
var
  R : TRect;
  Control : PView;
  C : Word;
  s: TMyString;
  ws : AllStr;
  E : PPrihodType;
  fp : PrihodFileType;
  Cur,start,Stop:LongInt;
begin
L:=False;
R.Assign(0, 0, 80, 23);
inherited Init(R, '������ ���㬥�⮢ ���⠢�� ⮢�� � '+StartDate+' �� '+StopDate);
Options := Options or ofCenterX or ofCenterY;
HelpCtx:=$E002;

R.Assign(11, 1, 45, 5);
ControlMarsh := New(PInputLine, Init(R, CAll));

PInputLine(ControlMarsh)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','-']));
Insert(ControlMarsh);

R.Assign(1, 1, 11, 5);
  Insert(New(PLabel, Init(R, '��������:', ControlMarsh)));

marsh:='';
DelSpace(Marsh);
ControlMarsh^.SetData(Marsh);


(*R.Assign(11, 1, 45, 2);
ControlSort := New(PCheckBoxes, Init(R,
  NewSItem('��~�~���',
  NewSItem('��~�~��',
  NewSItem('�����',
   Nil)))));
Sorting:=7;
ControlSort^.SetData(Sorting);
Insert(ControlSort);

  R.Assign(1, 1, 11, 2);
  Insert(New(PLabel, Init(R, '��� ���:', ControlSort)));*)

R.Assign(54, 1, 79, 2);
ControlStatus := New(PCheckBoxes, Init(R,
  NewSItem('~�~�ଫ����',
  NewSItem('��~�~��',
  Nil))));
Status:=3;
ControlStatus^.SetData(Status);
Insert(ControlStatus);

  R.Assign(46, 1, 54, 2);
  Insert(New(PLabel, Init(R, '�����:', ControlStatus)));

R.Assign(80, 3, 81, 21);
Control := New(PScrollBar, Init(R));
Insert(Control);



R.Assign(0, 3, 80, 22);
DoCList := New(PBox, Init(R, 1, Nil));
DoCList^.NewList(New(PMyCollection, Init(1,1)));
DocList^.HelpCtx:=(*F061*)$F201;
Insert(DocList);


Str(StrToReal(AllSumma):CIZena:CMantissa,AllSumma);
DelSpace(AllSumma);
Str(StrToReal(AllZakupka):CIZena:CMantissa,AllZakupka);
DelSpace(AllZakupka);

Str(StrToInt(AllDoc):CLitrMantissa,AllDoc);
DelSpace(AllDoc);

  R.Assign(1, 2, 78, 3);
  Insert(New(PLabel, Init(R, ' ������               N   ���     �㬬� �� �/�   ��⠄��� ��ᯥ����      ���. ', DocList)));

R.Assign(49, 22, 64, 23);
Control := New(PColoredText, Init(R, ' �㬬�  �� �/�:', $74));
Insert(Control);

R.Assign(64, 22, 79, 23);
ControlAllSumma := New(PColoredText, Init(R, #3+AllSumma, $4E));
Insert(ControlAllSumma);

R.Assign(1, 22, 16, 23);
Control := New(PColoredText, Init(R, ' �㬬�  �� �/�:', $74));
Insert(Control);

R.Assign(16, 22, 31, 23);
ControlAllZakupka := New(PColoredText, Init(R, #3+AllZakupka, $4E));
Insert(ControlAllZakupka);

R.Assign(32, 22, 44, 23);
Control := New(PColoredText, Init(R, ' ���㬥�⮢:', $74));
Insert(Control);

R.Assign(44, 22, 48, 23);
ControlAllDoc := New(PColoredText, Init(R, #3+AllDoc, $4E));
Insert(ControlAllDoc);

SelectNext(False);
SelectNext(False);
SelectNext(False);
L:=True;
Refresh;
PrevCur[0]:=#0;
end;

Function DateDostDialog(Var s:TDAteString):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
begin
DateDostDialog := False;
R.Assign(28, 9, 52, 14);
New(Dlg, Init(R, '��� ���⠢��'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx:=$E002;

R.Assign(7, 2, 17, 3);
Control := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

Dlg^.SelectNext(False);
Dlg^.SetData(FDate);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  DateDostDialog:=True;
  Dlg^.GetData(S);
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;


Procedure TReestrDostWindow.FormPReport(Const P:PBox);
Const Space='';
Var f : text;
    Summa,SummaSF,sVol,sMassa,ws,s,s1 : string;
    i,c,k : Word;
    mSorting:Maska3;
    mStatus : Maska2;
    tt : Real;
    TempStr,Datestr:DateString;
    LocZ,LocP:Real;
    LocDoc:LongInt;
    PrintItog,PrintDate : Boolean;
    sDataDost: string[CDate];
    sAgentKod: string[CClientKod];
    fd: file of dostavkaType;
    d: PDostavkaType;
    Start,Stop,Cur: longint;
    IORez: word;
    AgentList :PBox;
    R: Trect;
    VidReport,Res: word;
    sStartDAte,sStopDate: string[CDate];
    sstart,sstop: longint;
    TempBox:PBox;
    OldCl,NewCl: string[CName];
    itSumma: string[CIzena];
    itVol,itMas: string[CKol+2];

procedure WriteShapka;
Begin
writeln(f,'�����������������������������������������������������������������������������������������Ŀ');
writeln(f,'�N � ������             ���᪳N����C㬬� � ����� ������ ᤠ�   ������ �ਭ�             �');
writeln(f,'�  �                    �    �    �               ���������������������������������������Ĵ');
writeln(f,'�  �                    �    �    �               �������쳂६ﳔ.�.�. �������� ������  �');
writeln(f,'�������������������������������������������������������������������������������������������');
End;

procedure WriteShapka1;
Begin
writeln(f,'���������������������������������������������������������������������������������������������������Ŀ');
writeln(f,'� ����⥫�                ��������    �N   � ������             �� � �㬬� � ���� � ���� ���ꥬ  �');
writeln(f,'�                         ��������⠢��� ����                    �  �               �       �       �');
writeln(f,'���������������������������������������������������������������������������������������������������Ĵ');
End;


Begin

 VidReport:=SelectImport(34);
 If VidReport=2 Then
  Begin
   Exit;
  End;

if VidReport=0 then
begin
  If Not(DatePeriodDialog(sStartDAte,sStopDate,false)) Then Exit;
   sstart:=DateStringToDate(DAtemask,sStartDate);
   sstop:=DateStringToDate(DAtemask,sStopDate);
end
else
begin
If Not(DateDostDialog(sDataDost)) Then Exit;
 sstart:=DateStringToDate(DAtemask,sDataDost);
 sstop:=DateStringToDate(DAtemask,sDataDost);
end;

 R.Assign(0, 0, 0, 0);
 AgentList := New(PBox, Init(R, 1, Nil));
 AgentList^.NewList(New(PTextCollection, Init(0,1)));


if VidReport=0 then
begin
 If Not(SelectionSortrudn(AgentList)) Then
 Begin
  Dispose(AgentList,Done);
  Exit;
 End;
end
else
begin
  Ag^.ShowAgentList(s,Res);
  if Res=1 then
  begin
  Dispose(AgentList,Done);
  exit;
  end;
  sAgentKod:=copy(s,pos('�',s)+1,CClientKod);
  System.Delete(s,1,CClient);
  AgentList^.List^.Insert(NewStr(s+'�           0.00�           0.00'));
  AgentList^.SetRange(AgentList^.List^.Count);
end;

 R.Assign(0, 0, 0, 0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));


if VidReport=0 then
begin
end
else
begin
sStop:=DateStringToDate(DateMask,sDataDost);
sStart:=sStop-5;
end;

 Assign (f,Path.ToTemp+'listd.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   MessageBox(#3^m+#3+'�� ���� ᮧ���� 䠩� '+Path.ToTemp+'listd.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


Summa:='0.00';
SummaSF:='0.00';
sVol:='0.00';
sMassa:='0.00';
if VidReport=0 then
writeln(f,Space+'   ������ ���������� �������� ������ c '+sStartDate+' �� '+sStopDate)
else
writeln(f,Space+'   ������ ���������� �������� ������ �� '+sDataDost);
WriteLN(f);

Write(f,Space+'��� ����:');
if VidReport=0 then
writeln(f,Space+'������')
else writeln(f,Space+'���ᮭ���� �� ����⥫�');
WriteLN(f);


 WriteLN(f,Space+'��࠭�� ����⥫�: ');

 For i:=0 To AgentList^.List^.Count-1 Do
   Begin
    s:=AgentList^.GetText(i,AgentList^.List^.Count);
    WS:=Copy(s,1+1,CClientKod);
    ws:=GetlIZOField(FAgent,ws);
    Format(ws,CClient);
  s:=ws+s;
  While Pos('�',s)>0 Do s[Pos('�',s)]:=' ';
  s[0]:=Chr(1+CClient+1+CClientKod);
  Writeln(f,Space+s);
 End;


 WriteLN(f);

IF vIDrEPORT=1 THEN WriteShapka
else WriteShapka1;
IF vIDrEPORT=1 then writeln(f,space+' ���᮪ ���㬥�⮢: �����(*)');
i:=1;
for Cur:=sStart To sStop do
begin
  new(d,init);
  Assign(fd,Path.ToMarket+DateToDateString(DateMask,Cur)+'.dst');
  IOrez:=ioresult;
  Reset(fd);
  IOrez:=ioresult;
  if IORez<>0 then continue
  else
  begin

    while not eof(fd) do
    begin
      read(fd,d^.Dat);
      if VidReport=0 then
      sDataDost:=DateToDateString(DateMask,Cur);
      if d^.Dat.Oformlen and
       (Not(TestElement(d^.Dat.EkspedKod+'�',AgentList))) and
       (d^.Dat.DocSelector in [5,7]) and
	  ((d^.Dat.DateDost=sDataDost) or (VidReport=0)) then
       begin
        ws:=GetLizoField(FClient,d^.Dat.EkspedKod);
        format(ws,CName);
        s1:=ws+'�';
        s1:=s1+' �*'+'�';
        s1:=s1+sDataDost+'�';
        ws:=d^.Dat.DocOsn;
        rformat(ws,CDocNumer);
        s1:=s1+ws+'�';
        ws:=intToStr(i,3);
        rformat(ws,3);
        s:=ws+'�';
        ws:=GetClientField(FClient,d^.Dat.ClientKod,0);
        format(ws,CClient);
        s1:=s1+ws+'�';
        s:=s+ws+'� ';
        ws:=d^.Dat.Maska;
        s:=s+ws+' �';
        s1:=s1+ws+'�';
        ws:=d^.Dat.DocOsn;
        rformat(ws,CDocNumer);
        s:=s+ws+'�';
        ws:=d^.Dat.SumOplata;
        rformat(ws,CIzena);
        s:=s+ws+'�';
        s1:=s1+ws+'�';
        ws:=d^.Dat.Massa;
        rformat(ws,CKol+2);
        s1:=s1+ws+'�';
        ws:=d^.Dat.Vol;
        rformat(ws,CKol+2);
        s1:=s1+ws+'�';

        ws:='       �     �       �        �        �';
        s:=s+ws;
        inc(i);
        IF vIDrEPORT=1 THEN Writeln(f,Space+s);

        MyStr(StrToReal(d^.Dat.SumOplata)+StrToReal(Summa),CIZena,CMantissa,Summa);
        MyStr(StrToReal(d^.Dat.Vol)+StrToReal(SVol),CKol,1,SVol);
        MyStr(StrToReal(d^.Dat.Massa)+StrToReal(SMassa),CKol,1,SMassa);

        TempBox^.List^.Insert(NewStr(s1));
        TempBox^.SetRange(TempBox^.List^.Count);

       end; {if d^.Dat.Oformlen}
    end; {WHILE NOT EOF}
    System.Close(fd);
    Dispose(d,Done);
   END; {if IORez<>0}
  end;{for Cur:=sStart To sStop}

if VidReport=1 then writeln(f,space+' ���᮪ ���㬥�⮢: ����⑔');
for Cur:=sStart To sStop do
begin
  new(d,init);
  Assign(fd,Path.ToMarket+DateToDateString(DateMask,Cur)+'.dst');
  IOrez:=ioresult;
  Reset(fd);
  IOrez:=ioresult;
  if IORez<>0 then continue
  else
  begin
    {i:=1;}
    while not eof(fd) do
    begin
      read(fd,d^.Dat);
      if d^.Dat.Oformlen and
       (Not(TestElement(d^.Dat.EkspedKod+'�',AgentList))) and
       (d^.Dat.DocSelector in [6,8]) and
	  ((d^.Dat.DateDost=sDataDost) or (VidReport=0)) then
       begin
        ws:=GetLizoField(FClient,d^.Dat.EkspedKod);
        format(ws,CName);
        s1:=ws+'�';
        s1:=s1+'���'+'�';
        s1:=s1+sDataDost+'�';
        ws:=d^.Dat.DocOsn;
        rformat(ws,CDocNumer);
        s1:=s1+ws+'�';
        ws:=intToStr(i,3);
        rformat(ws,3);
        s:=ws+'�';
        ws:=GetClientField(FClient,d^.Dat.ClientKod,0);
        format(ws,CClient);
        s1:=s1+ws+'�';
        s:=s+ws+'� ';
        ws:=d^.Dat.Maska;
        s:=s+ws+' �';
        s1:=s1+ws+'�';
        ws:=d^.Dat.DocOsn;
        rformat(ws,CDocNumer);
        s:=s+ws+'�';
        ws:=d^.Dat.SumOplata;
        rformat(ws,CIzena);
        s1:=s1+ws+'�';
        s:=s+ws+'�';
        ws:=d^.Dat.Massa;
        rformat(ws,CKol+2);
        s1:=s1+ws+'�';
        ws:=d^.Dat.Vol;
        rformat(ws,CKol+2);
        s1:=s1+ws+'�';
        ws:='       �     �       �        �        �';
        s:=s+ws;
        inc(i);

        IF vIDrEPORT=1 THEN Writeln(f,Space+s);

        TempBox^.List^.Insert(NewStr(s1));
        TempBox^.SetRange(TempBox^.List^.Count);

        MyStr(StrToReal(d^.Dat.SumOplata)+StrToReal(SummaSF),CIZena,CMantissa,SummaSF);
        MyStr(StrToReal(d^.Dat.Vol)+StrToReal(SVol),CKol,1,SVol);
        MyStr(StrToReal(d^.Dat.Massa)+StrToReal(SMassa),CKol,1,SMassa);
       end; {if d^.Dat.Oformlen}
    end; {while not eof(fd)}



   end; {if IORez<>0}
   System.Close(fd);
   Dispose(d,Done);
 end;{for Cur:=sStart To sStop}

 if TempBox^.List^.Count>0 then
 OldCl:=copy(TempBox^.GetText(0,TempBox^.List^.Count),1,CName);
 itSumma:='0.0';
 itVol:='0.0';
 itMas:='0.0';

 IF vIDrEPORT=0 THEN
 if TempBox^.List^.Count>0 then
 for i:=0 to TempBox^.List^.Count-1 do
 begin
   s:=TempBox^.GetText(i,TempBox^.List^.Count);
   newCl:=copy(s,1,CName);
   myStr(StrToReal(itSumma)+StrToReal(copy(s,70,CIZena)),ciZENA,cmANTISSA,itSumma);
   myStr(StrToReal(itMas)+StrToReal(copy(s,86,CIZena)),Ckol+2,1,itMas);
   myStr(StrToReal(itVol)+StrToReal(copy(s,86,CIZena)),Ckol+2,1,itVol);
   if (OldCl<>NewCl) then
   begin
    OldCl:=NewCl;
    Writeln(f,Space+' �⮣�:                                                              '+itSumma+' '+itMas+' '+itVol);
    Writeln(f);
     itSumma:='0.0';
     itVol:='0.0';
     itMas:='0.0';
   end;

   Writeln(f,Space+s);

   if (i=TempBox^.List^.Count-1) then
   begin
    OldCl:=NewCl;
    Writeln(f,Space+' �⮣�:                                                              '+itSumma+' '+itMas+' '+itVol);
   end;

 end;

 Writeln(f,Space+'-------------------------------------------------------------------------------------------');
 Writeln(f,Space+'�ᥣ� ��ꥬ: '+sVol);
 Writeln(f,Space+'�ᥣ� ����: '+sMassa);
 Writeln(f,Space+'�ᥣ� �㬬� �� ���㬥�⠬ �����* : '+Summa);
 Writeln(f,Space+'�ᥣ� �㬬� �� ���㬥�⠬ ����⑔: '+SummaSF);
 Writeln(f);

if VidReport=1 then
begin
 Writeln(f);
 Writeln(f,Space+'������ ������������ ����������');
 WriteShapka;
 for i:=1 to 7 do
  writeln(f,'�  �                    �    �    �               �       �     �       �        �        �');
  writeln(f,'�������������������������������������������������������������������������������������������');
  Writeln(f,Space+'�ᥣ� �㬬� ������ _____________________________');
  Writeln(f,Space+'�ᥣ� �㬬� � ᤠ� � �����  ____________________________ (_______________________________');
  Writeln(f,Space+'                                 (��ࠬ�)                               (�ந���)        ');
  Writeln(f,Space+'_________________________________________________________________________________________)');
  Writeln(f,Space+'����⥫�: _____________________________');
  Writeln(f);
  Writeln(f);

  Writeln(f,Space+'������ �������� �������� ��������� '+sDataDost);
  writeln(f,'���������������������������������������������������������������������������������������������Ŀ');
  writeln(f,'�N � ������             ���᪳N����C㬬� � ����� ���������� ᤠ�   ������ �ਭ�             �');
  writeln(f,'�  �                    �    �    �               �������������������������������������������Ĵ');
  writeln(f,'�  �                    �    �    �               �   �������쳂६ﳔ.�.�. �������� ������  �');
  writeln(f,'�����������������������������������������������������������������������������������������������');

   i:=1;
   for Cur:=sStart To sStop do
    begin
      Assign(fd,Path.ToMarket+DateToDateString(DateMask,Cur)+'.dst');
      IOrez:=ioresult;
      Reset(fd);
      IOrez:=ioresult;
      if IORez<>0 then continue
      else
      begin
       new(d,init);
       while not eof(fd) do
       begin
        read(fd,d^.Dat);
        if d^.Dat.Oformlen and
         (Not(TestElement(d^.Dat.EkspedKod+'�',AgentList))) and
         (d^.Dat.DocSelector in [5,7]) and
	    (d^.Dat.DateDost=sDataDost) then
         begin
          ws:=intToStr(i,3);
          rformat(ws,3);
          s:=ws+'�';
          ws:=GetClientField(FClient,d^.Dat.ClientKod,0);
          format(ws,CClient);
          s:=s+ws+'� ';
          ws:=d^.Dat.Maska;
          s:=s+ws+' �';
          ws:=d^.Dat.DocOsn;
          rformat(ws,CDocNumer);
          s:=s+ws+'�';
          ws:=d^.Dat.SumOplata;
          rformat(ws,CIzena);
          s:=s+ws+'�';
          ws:=' �*';
          s:=s+ws+'�';
          ws:='       �     �       �        �        �';
          s:=s+ws;
          inc(i);
          Writeln(f,Space+s);

          MyStr(StrToReal(d^.Dat.SumOplata)+StrToReal(Summa),CIZena,CMantissa,Summa);
          MyStr(StrToReal(d^.Dat.Vol)+StrToReal(SVol),CKol,1,SVol);
          MyStr(StrToReal(d^.Dat.Massa)+StrToReal(SMassa),CKol,1,SMassa);

         end; {if d^.Dat.Oformlen}
       end;  {while not eof(fd)}
        Dispose(d,Done);
        System.Close(fd);
      end; {else}
   end; {for   }

   for Cur:=sStart To sStop do
    begin
      Assign(fd,Path.ToMarket+DateToDateString(DateMask,Cur)+'.dst');
      IOrez:=ioresult;
      Reset(fd);
      IOrez:=ioresult;
      if IORez<>0 then
      else
      begin
        new(d,init);
        {i:=1;}
        while not eof(fd) do
        begin
         read(fd,d^.Dat);
          if d^.Dat.Oformlen and
          (Not(TestElement(d^.Dat.EkspedKod+'�',AgentList))) and
          (d^.Dat.DocSelector in [6,8]) and
	     (d^.Dat.DateDost=sDataDost) then
           begin
            ws:=intToStr(i,3);
            rformat(ws,3);
            s:=ws+'�';
            ws:=GetClientField(FClient,d^.Dat.ClientKod,0);
            format(ws,CClient);
            s:=s+ws+'� ';
            ws:=d^.Dat.Maska;
            s:=s+ws+' �';
            ws:=d^.Dat.DocOsn;
            rformat(ws,CDocNumer);
            s:=s+ws+'�';
            ws:=d^.Dat.SumOplata;
            rformat(ws,CIzena);
            s:=s+ws+'�';
            ws:='���';
            s:=s+ws+'�';
            ws:='       �     �       �        �        �';
            s:=s+ws;
            inc(i);
            Writeln(f,Space+s);

            MyStr(StrToReal(d^.Dat.SumOplata)+StrToReal(SummaSF),CIZena,CMantissa,SummaSF);
            MyStr(StrToReal(d^.Dat.Vol)+StrToReal(SVol),CKol,1,SVol);
            MyStr(StrToReal(d^.Dat.Massa)+StrToReal(SMassa),CKol,1,SMassa);
          end; {if d^.Dat.Oformlen}
        end; {while not eof(fd) }

        Dispose(d,Done);
        System.Close(fd);
    end;{IORez=0}
  end; {for Cur:=sStart To sStop }


  Writeln(f,Space+'-------------------------------------------------------------------------------------------');
  end; {if VidReport=1 then}

 Writeln(f,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'===========================================================================================');

  System.close(f);
  ViewAsText(Path.ToTemp+'listd.txt',True);
  Report(Path.ToTemp+'listd.txt','',1,False,False,false);


End;




procedure TReestrDostWindow.Oforml(Var st:AllStr;Var Res: Word);
var sDataDost,sDateDoc: TDateString;
    sAgentKod: string[CClientKod];
    sDocOsn: string[CDocNumer];
    f: file of DostavkaType;
    d: PDostavkaType;
    IORez,i: word;
Begin
 {Agent}
 Ag^.ShowAgentList(st,Res);
 if Res=1 then exit;
 system.Delete(st,1,2);
 sAgentKod:=copy(st,pos('�',st)+1,CClientKod);
 {DataDost}
 If Not(DateDostDialog(sDataDost)) Then Exit;

for i:=0 to DocList^.List^.Count-1 do
begin
 {N}
 sDocOsn:=Copy(DocList^.GetText(i,DocList^.List^.Count),1+CClient+1,CDocNumer);
 {DataDoc}
 sDateDoc:=Copy(DocList^.GetText(i,DocList^.List^.Count),1+CClient+1+CDocNumer+1,CDate);
 if DateStringToDate(DateMask,FDate)-DateStringToDate(DateMask,sDateDoc)>=2 then continue;
 Assign(f,Path.ToMarket+sDateDoc+'.dst');
 IOrez:=ioresult;
 Reset(f);
 IOrez:=ioresult;
 if iorez=0 then
 begin
  New(d,Init);
  while not eof(f) do
  begin
    read(f,d^.Dat);
    if (d^.Dat.DateDoc=sDateDoc) and (StrToInt(d^.Dat.DocOsn)=StrToInt(sDocOsn)) then
    begin
      d^.Dat.DateDost:=sDataDost;
      d^.Dat.EkspedKod:=sAgentKod;
      d^.Dat.Oformlen:=true;
      seek(f,filePos(f)-1);
      write(f,d^.Dat);
      break;
    end;
  end;
  Dispose(d,Done);
  System.close(f);
 end
 else
 begin
   memcc(Path.ToMarket+sDateDoc+'.dst');
   exit;
 end;
end;
 Refresh;
End;

procedure TReestrDostWindow.HandleEvent(var Event: TEvent);
Var test : Word;
    stest,s,s1 : string;
    SDoc : ArtikulStr;
    SDate: TDateString;
    l : Boolean;
    FC:Byte;
    FS : AllStr;
    Cod : ArtikulStr;


begin

  Case Event.What Of
  evKeyDown :
  Case Event.KeyCode Of
     kbEsc: Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
            End;
      kbF4: Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmProperties;
              PutEvent(Event);
              ClearEvent(Event);
            End;
      Else;
      End;{KeyDown}
  evCommand :
     Case Event.Command Of

  cmAbout: Begin
    AboutCHM('58');
    ClearEvent(Event);
    End;

  cmPrintReestr: if (User[87] or (CurrentPassword='00')) then
     Begin
               (*  ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CDocNumer+1,CDate);
                DelSpace(Assistent.D);
                PrintPrihod(Assistent);
            End  *)
            End;
 cmProperties:Begin

          (*       ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
                Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                DelZerro(Assistent.EditPosition);
                Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CDocNumer+1,CDate);
                DelSpace(Assistent.D);

                If TestPrihod(Assistent,Cod) Then
                Begin
                  If SetClientLock(Cod,0,2) Then
                   Begin
                    If PAssword(9) Then
                    PrhW^.Ini(Cod,Assistent.EditPosition,Assistent.D);
                    Repeat
                    Until (SetClientUnLock(Cod,0,2));
                   End
                   Else
                    MessageBox(^M+#3+'�� ���� �������஢��� ���⠢騪�! ������ ������ �����!',Nil,mfError+mfCAncelButton);
                End;
             End;     *)

              End;



 cmReestrReport: {if (User[86] or (CurrentPassword='00')) then}
      Begin
                 ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
            FormPReport(DocList);
            End
            End;
  cmFullView:    Begin
             (*    ClearFind;
     If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1) Then
            Begin
              FullPreview;
{               Assistent.EditPosition:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1,CDocNumer);
                DelSpace(Assistent.EditPosition);
                Assistent.D:=Copy(DocList^.GetText(DocList^.Focused,DocList^.List^.Count),1+CClient+1+CDocNumer+1,CDate);
                DelSpace(Assistent.D);
                Status:=DocPrint;
                PrintNaklSklad(Assistent);
                PrintNakl(Assistent);
                Status:=DocNormal;}
            End *)
            End;
     cmReestrDoc:Begin
                  ClearFind;
                  ClearEvent(Event);

                 End;
     cmRefresh  :Begin
                  ClearFind;
                  ClearEvent(Event);
                  Refresh;
                 End;
     cmCancel    : Begin
                 Dispose(DocList,Done);
                 {
                 Dispose(ControlRefreshTime,Done);
                 Dispose(ControlCombo,Done);
                 Dispose(ControlAllClient,Done);
                 Dispose(ControlAllSkid,Done);
                 Dispose(ControlAllSumma,Done);
                 Dispose(ControlAllDoc,Done);
                 }
                 ClearFind;
                 Event.What:=evCommand;
                 Event.Command:=cmClose;
                 PutEvent(Event);
                 ClearEvent(Event);
                End;

      Else;
  End;{evCommand}
      Else;
      End;{*Case*}


  if (Event.What = evBroadcast) and
    (Event.Command = cmReestrDoc) then ClearEvent(Event);

  if (Event.What = evBroadcast) and
    (Event.Command = cmQuit) then ClearEvent(Event);

  if (Event.What = evKeyboard) and ((Event.KeyCode=kbEnter) or (Event.KeyCode=kbTab))
  then
                   Begin
                        ControlMarsh^.GetData(sTest);
                        If sTest <> Marsh Then
                        Begin
                           ClearFind;
                           Marsh:=sTest;
                           Refresh;
                           Redraw;
                        End;
                    End;

  inherited HandleEvent(Event);



  If (Desktop^.Current=PView(DocReestrPWindow)) And (Event.What <> EvKeyDown) Then
             Begin
                if (ControlStatus^.State and sfFocused <> 0)
			 Then
                    Begin
                        ControlStatus^.GetData(Test);
                        If Test <> Status Then
                        Begin
                           ClearFind;
                           Status:=Test;
                           Refresh;
                           Redraw;
                        End;
                    End;

           (*if (ControlMarsh^.State and sfFocused <> 0) and (Event.Command = cmReestrDoc)

			 Then
                    Begin

                        ControlMarsh^.GetData(sTest);
                        If sTest <> Marsh Then
                        Begin
                           ClearFind;
                           Marsh:=sTest;
                           memcc(Marsh);
                           Refresh;
                           Redraw;
                        End;
                    End;   *)

               If (DocList^.State and sfFocused <> 0) And (DocList^.List<>Nil)And(DocList^.List^.Count>=1)
			 and (Event.Command = cmOk) Then
                Begin
                 Oforml(s,test);
                End;

             End;

end;

BEGIN

END.