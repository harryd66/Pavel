{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}



Unit AgOpl;

INTERFACE

Uses Dialogs,Drivers,ServStr,MyCalc,Nastr,Glob;

Procedure CalcDolgOplataAgent;

{$I Compile.INC}

IMPLEMENTATION


uses Objects, Views, MsgBox,Vision3,Validate,Access3,
     DBEngine,TPDate,Vision1,Vision4,Vision2,DosWin,
     Tools,Prise,App, Serv, ColorTxt,Protect,
     Prihod,Return,NetDbEng,Printers,Net,Utils;

const Space = ' ';
      posKey = 1+CClient+1+CClientKod+1+CDate+1+CDocNumer+1+CIZena+1;

VAr OldFileMode : Word;
    Errors: PBox;


Procedure ChangeSeparatorAndPsevdo(VAr S: String);
Var k : Word;
    First : Boolean;
begin
  First:=True;
  While Pos('�',s)>0 Do
   Begin
    If First Then
      Begin
       s[Pos('�',s)]:=' ';
       First:=FAlse;
      End
      Else s[Pos('�',s)]:=SeparatorChar;
   End;

  While Pos('�',s)>0 Do s[Pos('�',s)]:=SeparatorChar;
  While Pos('�',s)>0 Do s[Pos('�',s)]:=' ';
  While Pos('�',s)>0 Do s[Pos('�',s)]:=' ';
  While Pos('�',s)>0 Do s[Pos('�',s)]:=' ';
  While Pos('�',s)>0 Do s[Pos('�',s)]:=' ';
  While Pos('�',s)>0 Do s[Pos('�',s)]:=' ';
  While Pos('�',s)>0 Do s[Pos('�',s)]:=' ';
  While Pos('�',s)>0 Do s[Pos('�',s)]:=' ';
  While Pos('�',s)>0 Do s[Pos('�',s)]:=' ';
  While Pos('�',s)>0 Do s[Pos('�',s)]:=' ';
  While Pos('�',s)>0 Do s[Pos('�',s)]:=' ';
  While Pos('�',s)>0 Do s[Pos('�',s)]:=' ';


  While Pos(';',s)>0 Do s[Pos(SeparatorChar,s)]:=' ';

If SeparatorChar<>' ' Then
 Begin
  While Pos(SeparatorChar,s)>0 Do s[Pos(SeparatorChar,s)]:=';';
 End;

end;

Procedure ChangeSeparator(VAr S: String);
begin
  While Pos(';',s)>0 Do s[Pos(';',s)]:=' ';
end;





Procedure ReportToExcel(f:String);
Var txt : text;
    Excel : Text;
    ss,sname,s : string;
    c : Word;
    Event : TEvent;
Begin

  If Pos('.',F)>0 Then  SName:=Copy(F,1,Pos('.',F)-1);
  While Pos('\',SNAme)>0 Do System.Delete(SNAme,1,Pos('\',SNAme));
  SNAme:=Path.ToTemp+SName+'.csv';


Assign(Excel,SNAme);
c:=Ioresult;
Rewrite(Excel);
c:=Ioresult;
if c<>0 Then
 begin
  MessageBox(#3+'�訡�� ᮧ����� '+SNAme+^M+
  #3'���: '+IntToStr(c,CKol),Nil,mfCancelButton);
  Exit;
 End;

Assign(Txt,f);
c:=Ioresult;
Reset(Txt);
c:=Ioresult;
if c<>0 Then
 begin
  c:=Ioresult;
  Close(Excel);
  c:=Ioresult;
  MessageBox(#3+'�訡�� ������ '+f+^M+
  #3'���: '+IntToStr(c,CKol),Nil,mfCancelButton);
  Exit;
 End;

DInfoMsg('���� ��४���஢��. �������...');
While Not(Eof(txt)) Do
 Begin
  Readln(txt,s);
  ChangeSeparatorAndPsevdo(S);
  Del2Space(s);
  ss:=s;
  DelSpace(SS);
  If ss[0]<>#0 Then
  If Not(Pos('---------------',s)>0) And Not(Pos('����������������',s)>0) And
  Not(Pos('________________________',s)>0) And Not(Pos('=======',s)>0) Then
  Writeln(Excel,DosToWin(s));
  {
  Writeln(s);
  Writeln(DosToWin(s));
  Readln;
  }
  c:=Ioresult;
 End;
NoInfoMsg;

c:=Ioresult;
Close(txt);
c:=Ioresult;
Close(Excel);
c:=Ioresult;

 Sound(1800);
 Delay(700);
 NoSound;
 DInfoMsg('����� �ᯥ譮 ������஢��� � '+SNAme+'...');
 Application^.ClearEvent(Event);
 Application^.GetEvent(Event);
 Application^.ClearEvent(Event);
 repeat
   Application^.GetEvent(Event);
 until (Event.What <> evNothing) And (Event.Command<>cmMenu);
 NoInfoMsg;




End;





function CalcOplAgent(P:PBox;ClKod:string;D:longint;Doc:word;s:string;var sSrok:string;r:boolean):string;
var o: pBufClientOplataRealizasiaType;
    fo: file;
    IORez,BakFileMode:word;
    oCount,j: word;
    ops:string;
    SumOpl, SumVozwr, SkVozwr,sOpl,sShtraf,sSrokTek,sShtrafTek: string[CIZena];
begin
   CalcOplAgent:='0.00';
   sOpl:='0.00';
   sSrok:='';
   sShtraf:='0.0';
   DelSpace(ClKod);
   Assign(fo,Path.ToClientOplata+ClKod+'.cpl');
   IORez:=ioresult;
   Reset(fo,SizeOf(ClientOplataRealizasiaType));
   IORez:=ioresult;
   if IORez<>0 then
    begin
      MessageBox(^M+#3'�訡�� ������ '+Path.ToClientOplata+ClKod+'.cpl'+
      '���: ' ,Nil,mfError+mfCancelButton);
       if Errors<> nil then
       begin
        Errors^.List^.Insert(NewStr('�� ������� ������ ������ '+ClKod));
        Errors^.SetRange(Errors^.List^.Count);
       end;
    end;
    if IORez=0 then
    while not eof(fo) do
      begin
        New(o,Init);
        oCount:=0;
        BlockRead(fo,o^.Point,BufferCOpl,oCount);
        for j:=1 to oCount  do
         begin
           ops:='';
           if (StrToInt(o^.Point.Dat[j].Document)=Doc)
           and (o^.Point.Dat[j].DateDoc=DateToDateString(DateMask,D)) and
		 (abs(StrToReal(o^.Point.Dat[j].SummaZ))>0.009) then
           begin
             SumOpl:='0.00';
             SumVozwr:='0.00';
             SkVozwr:='0.00';
             sShtrafTek:='0.00';
             if o^.Point.Dat[j].Vozwrat then
              begin
               MyStr(StrToReal(o^.Point.Dat[j].SummaZ)-StrToReal(o^.Point.Dat[j].Skidka),CIZena,CMantissa,SumVozwr);
               MyStr(StrToReal(o^.Point.Dat[j].Skidka),CIZena,CMantissa,SkVozwr);
              end
              else
              begin
               MyStr(StrToReal(o^.Point.Dat[j].SummaZ),CIZena,CMantissa,SumOPl);
              end;
              MyStr(StrToReal(sOpl)+StrToReal(o^.Point.Dat[j].SummaZ),CIZena,CMantissa,sOpl);
              if o^.Point.Dat[j].Vozwrat then
              MyStr(StrToReal(sOpl)-StrToReal(o^.Point.Dat[j].Skidka),CIZena,CMantissa,sOpl);

              ops:=s;
              MyStr(StrToReal(SumOpl),CIZena,CMantissa,SumOpl);
              MyStr(StrToReal(SumVozwr),CIZena,CMantissa,SumVozwr);
              MyStr(StrToReal(SkVozwr),CIZena,CMantissa,SkVozwr);
              format(o^.Point.Dat[j].Document,CDocNumer);
              ops:=ops+o^.Point.Dat[j].Document;
              ops:=ops+'�'+o^.Point.Dat[j].DateC;
              ops:=ops+'�'+SumOpl;
              ops:=ops+'�'+SumVozwr;
              ops:=ops+'�'+SkVozwr;
              format(o^.Point.Dat[j].DocNumerReturn,CDocNumer);
              ops:=ops+'�'+o^.Point.Dat[j].DocNumerReturn;
              format(o^.Point.Dat[j].DocDateReturn,CDate);
              ops:=ops+'�'+o^.Point.Dat[j].DocDateReturn;


              if StrToReal(o^.Point.Dat[j].Delta)<=3 then o^.Point.Dat[j].Delta:='0'
		    else MyStr(StrToReal(o^.Point.Dat[j].Delta)-3,CIZena,CMantissa,o^.Point.Dat[j].Delta);
              if r then o^.Point.Dat[j].Delta:='0'; {�᫨ ⮢�� �� ॠ������ - ���䮢 ���}

              {ops:=ops+'�'+o^.Point.Dat[j].Delta;}

           if o^.Point.Dat[j].Vozwrat then
           begin
           end
           else
           begin
              MyStr(StrToReal(sShtraf)+(StrToReal(o^.Point.Dat[j].Delta))*0.005*StrToReal(SumOpl)
		       ,CIZena,CMantissa,sShtraf);
              MyStr(StrToReal(o^.Point.Dat[j].Delta)*0.005*StrToReal(SumOpl)
		       ,CIZena,CMantissa,sShtrafTek);
              sSrokTek:=o^.Point.Dat[j].Delta;
              rformat(sSrokTek,CZena);
              rformat(sShtraf,CZena);
              rformat(sShtrafTek,CZena);
		    sSrok:=sSrokTek+'�'+sShtraf;
           end;

              P^.List^.Insert(NewStr(ops+'�'+sSrokTek+'�'+sShtrafTek));
              P^.SetRange(P^.List^.Count);

             end;
           end; {for j:=1}
           Dispose(o,Done);
         end;  {while not eof(fo)}
        close(fo);
        CalcOplAgent:=sOpl;

end;

procedure CalcDolgAgent(P:PBOX;ClKod:string;Date:longint;Doc:word;Sum:float;var s: string);
var d: PBufRealizasiaType;
    fd: file;
    BakFileMode,IOrez: word;
    SdOLG: string;
    dCount,j: word;
    sOpl: string{[CIZena]};
    find: boolean;
    sSrok: string;
Begin
 DelSpace(ClkOD);
 sSrok:='';
 Assign(fd,Path.ToDolg+cLkOD+'.dlg');
 IOrez:=ioresult;
 BakFileMode:=FileMode;
 FileMode:=$40;
 reset(fd,SizeOf(RealizasiaType));
 IOrez:=ioresult;
 FileMode:=BakFileMode;
 if IOrez<>0 then
 begin
 MessageBox(^M+#3'�訡�� ������ '+Path.ToDolg+cLkOD+'.dlg',Nil,mfError+mfCancelButton);
 if Errors<> nil then
 begin
  Errors^.List^.Insert(NewStr('�� ������� ����� ������ '+ClKod));
  Errors^.SetRange(Errors^.List^.Count);
 end;
 sDolg:='0.00';
 end;
 find:=false;

 if IOrez=0 then
 while not eof(fd) do
 begin
  new(d,Init);
  dCount:=0;
  BlockRead(fd,d^.Point,BufferDLG,dCount);
  For j:=1 to dCount do
  if d^.Point.Dat[j].Market.Active then
   Begin
     if (StrToInt(d^.Point.Dat[j].Market.Document)=Doc)
       and (d^.Point.Dat[j].Market.DateC=DateToDateString(DateMask,Date)) then
     begin
      sDolg:='0.00';
      if not d^.Point.Dat[j].full then
        MyStr(d^.Point.Dat[j].Dolg,CIZena,CMantissa,sDolg)
      else sDolg:='0.00';
      MyStr(StrToReal(SDolg),CIZena,CMantissa,SDolg);
      s:=s+sDolg+'�';


      {������}
      if (d^.Point.Dat[j].Full) or
      (abs(d^.Point.Dat[j].Dolg-Sum)>0.009)
      then
      begin
       sOpl:='';
       if d^.Point.Dat[j].Realiz then
       sOpl:=CalcOplAgent(P,ClKod,Date,
         Doc,s,sSrok,true)
       else
       sOpl:=CalcOplAgent(P,ClKod,Date,
         Doc,s,sSrok,false)
       end
       else sOpl:='0.00';
       MyStr(StrToReal(SOpl),CIZena,CMantissa,SOpl);
       s:=s+sOpl+'�'+sSrok;
       find:=true;
       break;
     end; {if (StrToInt(d^.Point.Dat[jj]}

   end; {For jj:=1 to dCount}
   Dispose(d,Done);
   end; {while not eof(fd) do}

   if not find then
         begin
          MessageBox(^M+#3'���㬥�� N '+IntToStr(Doc,5)+
          ' �� '+DateToDateString(Datemask,Date)+' �� ������ � ������ ������ !!! ('+
          Path.ToDolg+ClKod+'.dlg)',Nil,mfError+mfCancelButton);
          MyStr(StrToReal(SDolg),CIZena,CMantissa,SDolg);
          {MyStr(StrToReal(SOpl),CIZena,CMantissa,SOpl);}
          s:=s+sDolg+'�'+sOpl;
           if Errors<> nil then
           begin
              Errors^.List^.Insert(NewStr('���㬥�� N '+IntToStr(Doc,5)+
                ' �� '+DateToDateString(Datemask,Date)+' �� ������ � ������ ������ !!! ('+
                Path.ToDolg+ClKod+'.dlg)'));
              Errors^.SetRange(Errors^.List^.Count);
           end;
         end;

  IOrez:=ioresult;
        close(fd);
  IOrez:=ioresult;

End;


Procedure CalcDolgOplataAgent;
Var R: TRect;
    m: PSuperMarketType;
    fm: MarketfileType;
    Result,AgentList,AgentDolgList :PBox;
    Errors, OplList:Pbox;
    IORez, i: word;
    StartDate, StopDate, sDate: TDateString;
    Start,Stop, tek: longint;
    VidReport, OplReport: word;
    s,ws,ops: string;
    sZena,sDolg,sOpl: string[CIZena];
    Find,findO: boolean;
    Count,dCount,oCount,j,jj,jjj: word;
    c,bAKfILEmODE,k: WORD;
    t: text;
    stDate: string[CDate];
    sSummaDen,sSummaPriod,sDolgDen,sDolgPeriod,sOplDen,
    sOplPeriod,sStrafPeriod: string[CIZena];
    sStrafDen: string[CIZena+1];
    OldDate,NewDate: string[CDate];
    sAgKod: string[CClientKod];
    NewKey, OldKey: string;
    first: boolean;
BEGIN
  If Not DatePeriodDialog(StartDate,StopDate,False) Then Exit;

  Start:=DateStringToDate(DateMask,StartDate);
  Stop:=DateStringToDate(DateMask,StopDate);


 R.Assign(0, 0, 0, 0);
 AgentList := New(PBox, Init(R, 1, Nil));
 AgentList^.NewList(New(PTextCollection, Init(0,1)));

 If Not(SelectionAgent(AgentList)) Then
 Begin
  Dispose(AgentList,Done);
  Exit;
 End;

 VidReport:=SelectImport(31);
 If VidReport=2 Then
  Begin
   Dispose(AgentList,Done);
   Exit;
  End;

 OplReport:=SelectImport(10);
 if OplReport=2 then
  Begin
   Dispose(AgentList,Done);
   Exit;
  End;

 R.Assign(0, 0, 0, 0);
 AgentDolgList := New(PBox, Init(R, 1, Nil));
 AgentDolgList^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0, 0, 0, 0);
 OplList := New(PBox, Init(R, 1, Nil));
 OplList^.NewList(New(PTextCollection, Init(0,1)));

 R.Assign(0, 0, 0, 0);
 Errors := New(PBox, Init(R, 1, Nil));
 Errors^.NewList(New(PMyCollection, Init(0,1)));

 DInfoMsg('��ᬠ�ਢ�� ���㧪� �� ��ਮ� � '+StartDate+' �� '+StopDate+'...');

 for tek:=Start to Stop do
 BEGIN
  sDate:=DateToDateString(DateMask,tek);
  Assign(fm,Path.Tomarket+sDate+'.mrk');
  IOrez:=ioresult;
  Reset(fm);
  IOrez:=ioresult;
  if IOrez<>0 then
  begin
    {MessageBox(^M+#3'�訡�� ������ '+Path.TomarketIndex+sDate+'.mrx',Nil,mfError+mfCancelButton);
    Dispose(AgentList,Done);
    Dispose(AgentDolgList,Done);
    Exit;}
     if Errors<> nil then
     begin
       Errors^.List^.Insert(NewStr('�� ������� �த��� ��  '+sDate+' ('+
       DayString[DayOfWeek(tek)]+')'));
       Errors^.SetRange(Errors^.List^.Count);
     end;
    continue;
  end
  else
  Begin
    while not eof(fm) do
    begin
    new(m,Init);
    ReadMarket(fm,m);
      if m^.Dat.Active (*then
      if (((m^.Dat.Realiz) and (m^.Dat.DocSelector in [5,7,6,8]))
       Or (not(m^.Dat.Realiz))and (m^.Dat.DocSelector in [0,1,2,3,4]))
          *)
       and
        (Not(TestElement(m^.Dat.AgentKod+'�',AgentList)))
         then
      begin
      If (m^.Dat.Realiz) and (m^.Dat.DocSelector in [0,1,2,3,4])Then
         Begin
          m^.Dat.Document:=m^.Dat.DocReal;
          m^.Dat.DateC:=m^.Dat.DocDate;
         End;
        {��� �����}
        s:=M^.Dat.AgentKod+'�';
        {��� ������}
        s:=s+M^.Dat.ClientKod+'�';
        {���}
        s:=s+m^.Dat.DateC+'�';
        {�����}
        rFormat(m^.Dat.Document,CDocnumer);
        s:=s+m^.Dat.Document+'�';
        {�㬬�}
        MyStr(StrToReal(m^.Dat.SummaZ),CIZena,CMantissa,sZena);
        s:=s+sZena+'�';
        {���⮪ �����}
        CalcDolgAgent(OplList,M^.Dat.ClientKod,DateStringToDate(DateMask,m^.Dat.DateC),StrToInt(m^.Dat.Document),
           StrToReal(m^.Dat.Summaz),s);

        AgentDolgList^.List^.Insert(NewStr(s));
        AgentDolgList^.SetRange(AgentDolgList^.List^.Count);

      end;
    Dispose(m,Done);
  End;
    close(fm);

  End;
 END;
 NoInfoMsg;


 {��ࠡ�⪠ १���⮢}
 R.Assign(0, 0, 0, 0);
 Result := New(PBox, Init(R, 1, Nil));
 Result^.NewList(New(PTextCollection, Init(0,1)));


 DInfoMsg('����஢�� ���㧮� �� ����⠬');
 if (AgentDolgList<>nil) and (AgentDolgList^.List^.Count>0) then
 for i:=0 to AgentDolgList^.List^.Count-1 do
 begin
  s:='';
  s:=AgentDolgList^.GetText(i,AgentDolgList^.List^.Count);
  case VidReport of
  0,1: Begin
       ws:=GetClientField(FClient,Copy(s,1+CClientKod+1,CClientKod),0);
       Format(ws,CClient);
       s:=ws+'�'+s;
       stDate:=copy(s,1+CClient+1+CClientKod+1+CClientKod+1,CDate);
       stDate:=IntToStr(DateStringToDate(DateMask,StDate),CDate);
       format(stDate,CDate);
       s:=stDate+s;
     end;
  end;

  Result^.List^.Insert(NewStr(s));
  Result^.SetRange(Result^.List^.Count);
 end;
  NoInfoMsg;

 {������}
 DInfoMsg('����஢�� ����� �� ����⠬');
 if OplReport=0 then
 if (OplList<>nil) and (OplList^.List^.Count>0) then
 for i:=0 to OplList^.List^.Count-1 do
 begin
  s:='';
  s:=OplList^.GetText(i,OplList^.List^.Count);
  case VidReport of
  0,1: Begin
       ws:=GetClientField(FClient,Copy(s,1+CClientKod+1,CClientKod),0);
       Format(ws,CClient);
       s:=ws+'�'+s;
       stDate:=copy(s,1+CClient+1+CClientKod+1+CClientKod+1,CDate);
       stDate:=IntToStr(DateStringToDate(DateMask,StDate),CDate);
       format(stDate,CDate);
       s:=stDate+s;
     end;
  end;

  Result^.List^.Insert(NewStr(s));
  Result^.SetRange(Result^.List^.Count);
 end;
  NoInfoMsg;


OldDate:=StartDate;
NewDate:=StartDate;
sSummaDen:='0.00';
sSummaPriod:='0.00';
sDolgDen:='0.00';
sDolgPeriod:='0.00';
sOplDen:='0.00';
sOplPeriod:='0.00';
sStrafDen:='0.00';
sStrafPeriod:='0.00';

 {����� १���⮢}
if VidReport=0 then
begin
 Assign(t,Path.ToTemp+'agopl.txt');
 IORez:=ioresult;
 Rewrite(t);
 IORez:=ioresult;
 if IOrez<>0 then
 begin
   Dispose(Result,Done);
   Dispose(AgentList,Done);
   Dispose(AgentDolgList,Done);
   Exit;
 end;

 first:=true;
 OldKey:=COPY(Result^.GetText(i,Result^.List^.Count),1,posKey+1+CDate+1+CClientKod);
 System.Delete(OldKey,1,CDate);
 System.delete(OldKey,1+CClient+1,CClientKod+1);

 Writeln(t,Space+'�����: ',GetClientField(FClient,Rek.Kod,1)+'  ������: '+CurrentPassword);
 WRiteln(t,'        ����� �� ������� (᢮���) � '+StartDate+' �� '+StopDate);

 WriteLN(t,Space+'��࠭�� ������: ');
 For i:=0 To AgentList^.List^.Count-1 Do
   Begin
    s:=AgentList^.GetText(i,AgentList^.List^.Count);
    WS:=Copy(s,1+1,CClientKod);
    ws:=GetAgentField(FAgent,ws);
    Format(ws,CClient);

  s:=ws+s;
  While Pos('�',s)>0 Do s[Pos('�',s)]:=' ';
  s[0]:=Chr(1+CClient+1+CClientKod);
  Writeln(t,Space+s);
 End;

 WriteLN(t);

 Writeln(t,
           Space+'��������������������������������������������������������������������������������������������������'
		 +'����������������Ŀ');
 Writeln(t,Space+'�    �����           �  ������            ���� � ���   �N����  �㬬�    �   ����    �  �����   �'
          +'��.������ ����  �');
 Writeln(t,Space+'��������������������������������������������������������������������������������������������������'
          +'������������������');
  WriteLN(t);

 DInfoMsg('��ନ��� ���� �� ����⠬...');
 if (Result<>nil) and (Result^.List^.Count>0) then
 for i:=0 to Result^.List^.Count-1 do
 begin
  s:='';
  s:=Result^.GetText(i,Result^.List^.Count);
  sAgKod:=copy(s,1+CClient+1+CDate,CClientKod);
  System.Delete(s,1,CDate);
  System.delete(s,1+CClient+1,CClientKod+1);
  NewKey:=copy(s,1,PosKey);
  if (OplReport=0) and (OldKey=NewKey) then
  begin

    System.Delete(s,1,posKey+CiZena);
    if StrToReal(copy(s,1+CDate+1+CDocNumer+1,CIzena))>0.009 then
     writeln(t,Space+'          ����� '+{ �� ���㬥��� N ',copy(s,1,CDocNumer),' �� ',copy(s,1+CDocNumer+1,CDate),}
          ' �� �㬬�:  ',copy(s,1+CDocNumer+1+CDate+1,CIzena))
    else
    begin
     writeln(t,Space+'          ������ N ',copy(s,1+CDocNumer+1+CDate+1+CIzena+1+CIzena+1+CIzena+1,CDocNumer),
      ' �� ',copy(s,1+CDocNumer+1+CDate+1+CIzena+1+CIzena+1+CIzena+1+CDocNumer+1,CDate),
          ' �� �㬬�:  ',copy(s,1+CDocNumer+1+CDate+1+CIzena+1,CIZena));
    end;

  end
else
begin
  OldKey:=NewKey;

(*  NewDate:=copy(s,1+CClient+1+CClientKod+1,CDate);
  if (OldDate<>NewDate) then
  begin
    Writeln(t,Space+'��������������������������������������������������������������������������������������������������'
    +'������������������');
    rformat(sSummaDen,CIzena-4);
    rformat(sDolgDen,CIzena-4);
    rformat(sOplDen,CIzena-4);
    rformat(sStrafDen,CIzena+1);
    Writeln(t,Space+' �⮣� �� '+OldDate,': '+SeparatorChar+
    SeparatorChar+'                                     '+SeparatorChar+SeparatorChar+SeparatorChar,sSummaDen,SeparatorChar,
    sDolgDen,SeparatorChar,sOplDen,SeparatorChar,SeparatorChar,sStrafDen);
    sSummaDen:='0.00';
    sDolgDen:='0.00';
    sOplDen:='0.00';
    sStrafDen:='0.00';
    Writeln(t,Space+'��������������������������������������������������������������������������������������������������'
    +'������������������');
    first:=true;
    oldDate:=NewDate;
  end;                  *)

  MyStr(StrToReal(sSummaDen)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1,CIZena))
     ,CIZena,CMantissa,sSummaDen);
  MyStr(StrToReal(sSummaPriod)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1,CIZena))
     ,CIZena,CMantissa,sSummaPriod);
  MyStr(StrToReal(sDolgDen)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1,CIZena))
           ,CIZena,CMantissa,sDolgDen);
  MyStr(StrToReal(sDolgPeriod)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1,CIZena))
           ,CIZena,CMantissa,sDolgPeriod);
  MyStr(StrToReal(sOplDen)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1+CIZena+1,CIZena))
          ,CIZena,CMantissa,sOplDen);
  MyStr(StrToReal(sOplPeriod)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1+CIZena+1,CIZena))
          ,CIZena,CMantissa,sOplPeriod);
    MyStr(StrToReal(sStrafDen)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1+CIZena
  +1+CIZena+1+CZena+1,CIZena))
          ,CIZena,CMantissa,sStrafDen);

  MyStr(StrToReal(sStrafPeriod)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1+CIZena
  +1++CIZena+1+CZena+1,CIZena))
          ,CIZena,CMantissa,sStrafPeriod);

  System.Delete(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1+CIZena+1,4);
  System.Delete(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1,4);
  System.Delete(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1,4);



  While Pos('�',s)>0 Do
    Begin
     k:=Pos('�',s);
     System.Delete(s,k,1);
     System.Insert(SeparatorChar,s,k);
    End;


  if not first then
  Writeln(t,Space+'�����������     �����������    �����������     �����������     �����������');
  first:=false;

  ws:=GetAgentField(FAgent,sAgKod);
  format(ws,CClient);
  s:=' '+ws+SeparatorChar+s;
  writeln(t,Space+s);
end;

(*  if i=Result^.List^.Count-1 then
  begin
  Writeln(t,Space+'��������������������������������������������������������������������������������������������������'
        +'������������������');
    rformat(sSummaDen,CIzena-4);
    rformat(sDolgDen,CIzena-4);
    rformat(sOplDen,CIzena-4);
    rformat(sStrafDen,CIzena+1);
    Writeln(t,Space+' �⮣� �� '+OldDate,': '+SeparatorChar+
    SeparatorChar+'                                     '+SeparatorChar+SeparatorChar+SeparatorChar,sSummaDen,SeparatorChar,
    sDolgDen,SeparatorChar,sOplDen,SeparatorChar,SeparatorChar,SStrafDen);
    sSummaDen:='0.00';
    sDolgDen:='0.00';
    sOplDen:='0.00';
    sStrafDen:='0.00';
  Writeln(t,Space+'��������������������������������������������������������������������������������������������������'
   +'������������������');
    oldDate:=NewDate;
  end; *)
 end;

   Writeln(t,Space+'��������������������������������������������������������������������������������������������������'
   +'������������������');

  Writeln(t,Space+'����� � '+StartDate+' �� '+StopDate+' : ');
  Writeln(t,Space+
  '                                          �㬬� ���ᨣ��樨:'+SeparatorChar
   +RecognizReal(StrToReal(sSummaPriod),CIZena,CMantissa));
  Writeln(t,Space+
  '                                          ���⮪ �����:    '+SeparatorChar
  +RecognizReal(StrToReal(sDolgPeriod),CIZena,CMantissa));

  Writeln(t,Space+
   '                                          �㬬� ������:     '+SeparatorChar
   +RecognizReal(StrToReal(sOplPeriod),CIZena,CMantissa));
  Writeln(t,Space+
   '                                          �㬬� ���䮢:    '+SeparatorChar
   +RecognizReal(StrToReal(sStrafPeriod),CIZena,CMantissa));

  if (Errors<>nil) and (Errors^.List^.Count>0) then
  begin
   Writeln(t,Space+'��������!');
   for i:=0 to Errors^.List^.Count-1 do
     Writeln(t,Space+Errors^.GetText(i,Errors^.List^.Count));
  end;

  Writeln(t,Space+'��������������������������������������������������������������������������������������������������'
  +'������������������');
  Writeln(t,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  Writeln(t,Space+'=================================================================================================='
  +'==================');

 i:=IOResult;
 close(t);
 i:=IOResult;
 NoInfoMSG;
 ReportToExcel(Path.ToTemp+'agopl.txt');
 ViewAsText(Path.ToTemp+'agopl.txt',True);
end {if VidReport=0}
else
begin
 {VidReport=1}
first:=true;
OldKey:=COPY(Result^.GetText(i,Result^.List^.Count),1,posKey+1+CDate+1+CClientKod);
System.Delete(OldKey,1,CDate);
System.delete(OldKey,1+CClient+1,CClientKod+1);
For j:=0 To AgentList^.List^.Count-1 Do
 Begin
  s:=AgentList^.GetText(j,AgentList^.List^.Count);

  ws:=Copy(s,1+1,CClientKod);
  Assign(t,Path.ToTemp+ws+'.tmp');
  IORez:=IOResult;
  Rewrite(t);
  IORez:=IOResult;
  If IORez<>0 Then
   Begin
    MessageBox(#3^M+#3'�訡�� ᮧ����� '+Path.ToTemp+ws+'.tmp ���:'+IntToStr(IOrez,CKOl),Nil,mfError+mfCancelButton);
    Continue;
   End;


  OldDate:=StartDate;
  NewDate:=StartDate;
  sSummaDen:='0.00';
  sSummaPriod:='0.00';
  sDolgDen:='0.00';
  sDolgPeriod:='0.00';
  sOplDen:='0.00';
  sOplPeriod:='0.00';
  sStrafDen:='0.00';
  sStrafPeriod:='0.00';

  Writeln(t,Space+'�����: ',GetClientField(FClient,Rek.Kod,1)+'  ������: '+CurrentPassword);
  Writeln(t,Space+'           ����� �� ������ '+
  GetAgentField(FAgent,Copy(AgentList^.GetText(j,AgentList^.List^.Count),1+1,CClientKod))+' � '+StartDate+' �� '+StopDate);
  WriteLN(t,Space+'�����: '+GetAgentField(FAgent,Copy(AgentList^.GetText(j,AgentList^.List^.Count),1+1,CClientKod))+' ('+
  Copy(AgentList^.GetText(j,AgentList^.List^.Count),1+1,CClientKod)+')');
  WriteLN(t);

  Writeln(t,Space+'�����������������������������������������������������������������������������'+
                 +'����������������Ŀ');
  Writeln(t,Space+'�  ������            ���� � ���   �N����  �㬬�    �   ����    �  �����   �'+
                 +'��.������ ����  �');
  Writeln(t,Space+'�����������������������������������������������������������������������������'+
                 +'������������������');


  DInfoMsg('��ନ��� ���� �� ������ '+GetAgentField(FAgent,Copy(AgentList^.GetText(j,AgentList^.List^.Count),1+1,
  CClientKod))+'...');

 if (Result<>nil) and (Result^.List^.Count>0) then
 for i:=0 to Result^.List^.Count-1 do
 begin
  s:='';
  s:=Result^.GetText(i,Result^.List^.Count);
 if StrToInt(Copy(AgentList^.GetText(j,AgentList^.List^.Count),1+1,CClientKod))=
    StrToInt(copy(s,1+CClient+1+CDate,CClientKod)) then
BEGIN

  System.Delete(s,1,CDate);

  System.delete(s,1+CClient+1,CClientKod+1);
  NewKey:=copy(s,1,PosKey);
  if OldKey=NewKey then
  begin

    System.Delete(s,1,posKey+CiZena);
    {writeln(t,'!'+s);}
    if StrToReal(copy(s,1+CDate+1+CDocNumer+1,CIzena))>0.009 then
     writeln(t,Space+'�����  �� ���㬥��� N ',copy(s,1,CDocNumer),' �� ',copy(s,1+CDocNumer+1,CDate),
          ' �� �㬬�:',copy(s,1+CDocNumer+1+CDate+1,CIzena),' ��.��.:'
		,copy(s,length(s)-CZena-CZena,CZena),' ���.:',copy(s,length(s)-CZena+1,CZena))
    else
    begin
     writeln(t,Space+'          ������ �� ���㬥��� N ',copy(s,1+CDocNumer+1+CDate+1+CIzena+1+CIzena+1+CIzena+1,CDocNumer),
      ' �� ',copy(s,1+CDocNumer+1+CDate+1+CIzena+1+CIzena+1+CIzena+1+CDocNumer+1,CDate),
          ' �� �㬬�:  ',copy(s,1+CDocNumer+1+CDate+1+CIzena+1,CIZena));
    end;

  end
else
begin
  OldKey:=NewKey;
  NewDate:=copy(s,1+CClient+1+CClientKod+1,CDate);

(*  if (OldDate<>NewDate) then
  begin
    Writeln(t,Space+'�����������������������������������������������������������������������������'
                   +'������������������');
    rformat(sSummaDen,CIzena-4);
    rformat(sDolgDen,CIzena-4);
    rformat(sOplDen,CIzena-4);
    rformat(sStrafDen,CIzena+1);
    Writeln(t,Space+' �⮣� �� '+OldDate,': '+SeparatorChar+
    SeparatorChar+'                 '+SeparatorChar+SeparatorChar,sSummaDen,SeparatorChar,
    sDolgDen,SeparatorChar,sOplDen,SeparatorChar,SeparatorChar,sStrafDen);
    sSummaDen:='0.00';
    sDolgDen:='0.00';
    sOplDen:='0.00';
    sStrafDen:='0.00';
    Writeln(t,Space+'�����������������������������������������������������������������������������'
     +'������������������');
    first:=true;
    oldDate:=NewDate;
  end;  *)

  MyStr(StrToReal(sSummaDen)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1,CIZena))
     ,CIZena,CMantissa,sSummaDen);
  MyStr(StrToReal(sSummaPriod)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1,CIZena))
     ,CIZena,CMantissa,sSummaPriod);
  MyStr(StrToReal(sDolgDen)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1,CIZena))
           ,CIZena,CMantissa,sDolgDen);
  MyStr(StrToReal(sDolgPeriod)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1,CIZena))
           ,CIZena,CMantissa,sDolgPeriod);
  MyStr(StrToReal(sOplDen)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1+CIZena+1,CIZena))
          ,CIZena,CMantissa,sOplDen);


  MyStr(StrToReal(sOplPeriod)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1+CIZena+1,CIZena))
          ,CIZena,CMantissa,sOplPeriod);

  { memcc(sOplPeriod+' '+sOplDen);}

  MyStr(StrToReal(sStrafDen)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1+CIZena
  +1+CIZena+1+CZena+1,CIZena))
          ,CIZena,CMantissa,sStrafDen);

  MyStr(StrToReal(sStrafPeriod)+StrToReal(copy(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1+CIZena
  +1+CIZena+1+CZena+1,CIZena))
          ,CIZena,CMantissa,sStrafPeriod);

  System.Delete(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1+CIZena+1,4);
  System.Delete(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1+CIZena+1,4);
  System.Delete(s,1+CClient+1+CClientKod+1+CDate+1+CDocnumer+1,4);



  While Pos('�',s)>0 Do
    Begin
     k:=Pos('�',s);
     System.Delete(s,k,1);
     System.Insert(SeparatorChar,s,k);
    End;
  if not first then
  Writeln(t,Space+'�����������     �����������    �����������     �����������     �����������');
  first:=false;
  writeln(t,Space+' '+s);
end;

END;
 end;

(*    Writeln(t,Space+'�����������������������������������������������������������������������������'
      +'������������������');
    rformat(sSummaDen,CIzena-4);
    rformat(sDolgDen,CIzena-4);
    rformat(sOplDen,CIzena-4);
    rformat(sStrafDen,CIzena+1);
        Writeln(t,Space+' �⮣� �� '+NewDate,': '+SeparatorChar+
    SeparatorChar+'                '+SeparatorChar+SeparatorChar+SeparatorChar,sSummaDen,SeparatorChar,
    sDolgDen,SeparatorChar,sOplDen,SeparatorChar,SeparatorChar,sStrafDen);*)

  Writeln(t,Space+'�����������������������������������������������������������������������������'
   +'������������������');

  Writeln(t,Space+'����� � '+StartDate+' �� '+StopDate+' : ');
  Writeln(t,Space+
   '                                          �㬬� ���ᨣ��樨: '+SeparatorChar
   +RecognizReal(StrToReal(sSummaPriod),CIZena,CMantissa));
  Writeln(t,Space+
   '                                          ���⮪ �����:     '+SeparatorChar
   +RecognizReal(StrToReal(sDolgPeriod),CIZena,CMantissa));
  Writeln(t,Space+
   '                                          �㬬� ������:      '+SeparatorChar
   +RecognizReal(StrToReal(sOplPeriod),CIZena,CMantissa));
    Writeln(t,Space+
   '                                          �㬬� ���䮢:     '+SeparatorChar
   +RecognizReal(StrToReal(sStrafPeriod),CIZena,CMantissa));

  if (Errors<>nil) and (Errors^.List^.Count>0) then
  begin
   Writeln(t,Space+'��������!');
   for i:=0 to Errors^.List^.Count-1 do
     Writeln(t,Space+Errors^.GetText(i,Errors^.List^.Count));
  end;

  Writeln(t,Space+'�����������������������������������������������������������������������������'
   +'������������������');
  Writeln(t,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  Writeln(t,Space+'============================================================================='
  +'==================');

  i:=IoResult;
  Close(t);
  i:=IoResult;
  NoInfoMSG;
  ViewAsText(Path.ToTemp+Copy(AgentList^.GetText(j,AgentList^.List^.Count),1+1,CClientKod)+'.tmp',True);

end;
end;
 {}

 Dispose(Result,Done);
 Dispose(AgentList,Done);
 Dispose(AgentDolgList,Done);
 Dispose(OplList,Done);
 Dispose(Errors,Done);

END;

BEGIN
END.