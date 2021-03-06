{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


{$I Compile.INC}


Unit AgOpReal;

INTERFACE

Uses Glob,Dialogs,ServStr,Serv;

Function ViewAgentOplReal(Dates:TDateString;Regim : Boolean):AllStr;

IMPLEMENTATION

Uses Objects,Views,DBEngine,MsgBox,Tools,Printers,{Views,}TpDate,Vision4,
Vision3,Utils5,Utils4,Utils3,Vision7,DbEngin2,DbEngin3,Prise,ServStr2,
Access1,Access2,NetDBEng,Net,Propiss,Vision5,Utils;


Function ViewAgentOplReal(Dates:TDateString;Regim : Boolean):AllStr;
Const Space =' ';
      Space1='  ';
Var   f : File;
      Opl : PBufOplataRealizasiaType;
      PromItog,ItogoOZ ,ItogoSf,ItogoRet: Real;
      Txt : Text;
      l,i : Byte;
      S   : String;
      st  : AllStr;
      Vid : Word;
      StartDate,StopDAte:TDateString;
      Cur,Start,Stop : LongInt;
      c,Count,c1 : Word;
      ItogoVks,ItogoBN : Real;
      M3:MAska4;
      Tip : Word;
      SF : Boolean;
      FiltrDateMarket : Boolean;
      StartMarket,StopMarket : TDAteString;
      StartM,StopM : LongInt;
      AgentList,TempBox : PBox;
      R : TRect;
      sAgent,sOldAgent: string[CClientKod];
      AgItog,AgItogRet,AgItogSF,AgItogBN: Real;

Function GetAgentFromOpl(O:OplataRealizasiaType):AllStr;
var E: PSuperMarketType;
    As:DocumentEditZ;
Begin
  GetAgentFromOpl:='';
  As.D:=O.DateDoc;
  As.EditPosition:=O.Document;
  new(E,Init);
  If GetMarket1(As, E) Then GetAgentFromOpl:=E^.Dat.AgentKod;
  Dispose(E,Done);
End;

Begin

 ViewAgentOplReal:='           0.00            0.00';

 If Regim Then
 Begin
 StopDate:=FDate;
 StartDate:=FDate;
 if StrToInt(CurrentPassword)=0 Then DateToDateString(DateMask,DAteStringToDate(DateMask,StopDate)-30);
 If Not(DatePeriodDialog(StartDate,StopDate,False)) Then Exit;
 End
 Else
   Begin
    Dates:=FDate;
    StartDAte:=FDAte;
    StopDAte:=FDate;
   End;

 Assign(Txt,Path^.Dat.ToTemp+'oplagnt.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'�� ���� ᮧ���� 䠩� ���� '+Path^.Dat.ToTemp+'oplagnt.txt'+
   +' ���:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;

 For c:=1 To Max4 Do M3[c]:=1;
 M3[4]:=0;

 Tip:=2;
 FiltrDateMarket:=False;
 StopMarket:=StopDate;
 StartMArket:=StartDate;

 If Regim Then
  Begin
   Tip:=SelectSpecify(False,4);
   If Tip=3 Then Exit;
   If Not(SelectVidOplata(M3)) Then
    Begin
     Close(txt);
     Exit;
  End;

  If MessageBox(^M+#3'�⪫���� 䨫��� ������ �� ��ਮ�� ���㧮� ���㬥�⮢?',Nil,
   mfConfirmation+mfOkCancel)=cmCancel Then
   Begin
     FiltrDateMarket:=True;
     StopMarket:=StopDate;
     StartMArket:=StartDate;
     If Not(DatePeriodDialog(StartMArket,StopMArket,False)) Then
      Begin
       Close(txt);
       Exit;
      End;
   End;
  End;

  If Regim Then   DInfo('�������...');

  Writeln(Txt,Header+Space+'�����: ',GetClientField(FClient,Rek^.Dat.Kod,1)+' ������:'+CurrentPassword);


ItogoOZ:=0;
ItogoSf:=0;
ItogoRet:=0;
ItogoBN :=0;
ItogoVks:=0;


Write(Txt,Space+'�⡮�: ');
  Case Tip Of
  0:Writeln(Txt,'�/�');
  1:Writeln(Txt,'��� �/�');
  2:Writeln(Txt,'��');
  Else;
  End;

Writeln(Txt,Space+'�����:');
For c:=1 To Max4 Do
Begin
 If M3[c]=1 Then
  Case c Of
  1:Writeln(Txt,Space+'����� �����묨');
  2:Writeln(Txt,Space+'����� �/�');
  3:Writeln(Txt,Space+'����� ���ᥫ��');
  4:Writeln(Txt,Space+'����� �����⮬');
  Else;
  End;
End;

If FiltrDateMarket Then
 Begin
  Writeln(Txt,Space+'��������! � ���� ������ ⮫쪮 �� ���㧪�� �� ��ਮ� � '+StartMarket+' �� '+StopMarket);
 End;

 R.Assign(0, 0, 0, 0);
 AgentList := New(PBox, Init(R, 1, Nil));
 AgentList^.NewList(New(PTextCollection, Init(0,1)));

 If Not(SelectionAgent(AgentList)) Then
 Begin
 l:=Ioresult;
  Close(txt);
 l:=Ioresult;
  Dispose(AgentList,Done);
  Exit;
 End;

 Writeln(Txt,Space+'   � � � � � � �   � �   � � � � � �    � � � � � � � � � � �  � '+StartDate+' �� '+StopDate);
 Writeln(Txt,Space+'�������������������������������������������������������������������������������������������Ŀ');
 Writeln(Txt,Space+'�������              ���� ���� ���� ����    �㬬� ������ ��� �����६� ���   ������ �� �');
 Writeln(Txt,Space+'���������������������������������������������������������������������������������������������'+HeaderStop);
                    {12345678901234567890 1234 1234 12345678  123456789012345  12345678 12345678 123456789012}


 R.Assign(0, 0, 0, 0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));

Start:=DateStringToDate(DateMask,StartDate);
Stop :=DateStringToDate(DateMask,StopDate);

For Cur:=Start To Stop Do
Begin
 DAtes:=DateToDateString(DateMask,Cur);
 If Regim  Then DInfoMsgShkala('��ᬠ�ਢ�� ������ ���ᨣ��樨 �� '+Dates+' ...',Start,Stop,Cur);
 Assign(F,Path^.Dat.ToOplata+Dates+'.opl');
 l:=IOResult;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(f,SizeOf(OplataRealizasiaType));
 l:=Ioresult;
 FileMode:=OldFileMode;
 If L=0 Then
 Begin
  PromItog:=0.0;
  While Not Eof(f) Do
  Begin
   New(Opl,Init);
   Count:=0;
   ReadBufOplata(F,Opl,Count);
For c1:=1 To Count Do
Begin
   sAgent:=GetAgentFromOpl(Opl^.Point.Dat[c1]);

   If Not TestElement1(sAgent{+'�'}, AgentList) Then

   If (Opl^.Point.Dat[c1].SkladKod=Rek^.Dat.Kod) Then
Begin
{  If DateStringToDate(DateMask,Opl^.Point.Dat[c1].DateDoc)<
      DateStringToDate(DateMask,'01-01-03') Then}
   If (Not(Opl^.Point.Dat[c1].Vozwrat) and (M3[Opl^.Point.Dat[c1].Rashet+1]=1)) Or
   ((Opl^.Point.Dat[c1].Vozwrat)And (M3[4]=1) ) Then
   Begin

   If TestSf(Opl^.Point.Dat[c1].ClientKod,Opl^.Point.Dat[c1].Document,Opl^.Point.Dat[c1].DateDoc) Then Sf:=True
   Else Sf:=False;

   {������뢠�� ������ �� �/�}

If (Tip=2) Or ((Sf) and (Tip=0)) Or (Not(sf) And (Tip=1)) Then
 Begin

If Not(FiltrDateMarket) Or (FiltrDAteMarket And (DateStringToDAte(DateMask,StartMarket)<=
                                                 DateStringToDAte(DateMask,Opl^.Point.Dat[c1].DateDoc))
                                            And (DateStringToDAte(DateMask,StopMarket)>=
								         DateStringToDAte(DateMask,Opl^.Point.Dat[c1].DateDoc)) ) Then
  Begin


   If Sf Then ItogoSF:=ItogoSF+StrToReal(Opl^.Point.Dat[c1].SummaZ);

   s:=GetClientField(FClient,Opl^.Point.Dat[c1].ClientKod,0);
   Format(s,CClient);
   s:=sAgent+SeparatorChar+s;
   s:=s+SeparatorChar+Opl^.Point.Dat[c1].CLientKod;
   DelSpace(Opl^.Point.Dat[c1].Document);
   Format(Opl^.Point.Dat[c1].Document,CDocNumer);
   DelSpace(Opl^.Point.Dat[c1].SummaZ);

   ItogoOZ:=ItogoOZ+StrToReal(Opl^.Point.Dat[c1].SummaZ);
   PromItog:=PromItog+StrToReal(Opl^.Point.Dat[c1].SummaZ);

   If (Opl^.Point.Dat[c1].Rashet=1) Then
    Begin
    ItogoBN:=ItogoBN+StrToReal(Opl^.Point.Dat[c1].SummaZ);
    End;

   If (Opl^.Point.Dat[c1].Rashet=2) Then
    Begin
    ItogoVks:=ItogoVks+StrToReal(Opl^.Point.Dat[c1].SummaZ);
    End;

   RFormat(Opl^.Point.Dat[c1].SummaZ,CIZena);
   st:=GetOperatorField(FNAme,Opl^.Point.Dat[c1].Caption);
   Format(St,CKto);
   s:=s+SeparatorChar+Opl^.Point.Dat[c1].Document+SeparatorChar+Opl^.Point.Dat[c1].DateDoc+SeparatorChar+' ';
{   +Opl.SummaZ+'  '+Opl.DateC+' '+Opl.TimeC+'  '+St;}

   If (Opl^.Point.Dat[c1].Vozwrat) Then
   Begin
    MyStr(StrToReal(Opl^.Point.Dat[c1].SummaZ)-StrToReal(Opl^.Point.Dat[c1].Skidka),CIZena,CMantissa,
    Opl^.Point.Dat[c1].SummaZ);
   End;
   s:=s+Opl^.Point.Dat[c1].SummaZ+' '+SeparatorChar+Opl^.Point.Dat[c1].DateC+SeparatorChar+
   Opl^.Point.Dat[c1].TimeC+SeparatorChar+St;

   If Sf Then s:=s+SeparatorChar+'��';

   If (Opl^.Point.Dat[c1].Vozwrat) Then
   Begin
    Format(Opl^.Point.Dat[c1].DocNumerReturn,CDocNumer);
    Format(Opl^.Point.Dat[c1].DocDAteReturn,CDate);
    ItogoRet:=ItogoRet+StrToReal(Opl^.Point.Dat[c1].SummaZ);
    MyStr(StrToReal(Opl^.Point.Dat[c1].Skidka),CIZena,CMantissa,Opl^.Point.Dat[c1].Skidka);
    s:=s+^M+Space1+'������ ⮢�� �� ��������� ������: '+Opl^.Point.Dat[c1].DocNumerReturn+' �� '+
    Opl^.Point.Dat[c1].DocDAteReturn+'  ������ ������: '+
    Opl^.Point.Dat[c1].Skidka;
   End;


   {Writeln(txt,Space1+s);}

   If (Opl^.Point.Dat[c1].Rashet=1) Then
    Begin
   {  Writeln(txt,Space1+'�/�:'+Opl^.Point.Dat[c1].Bn.NPlat+' �� '+Opl^.Point.Dat[c1].Bn.Date+' ����:'+
        GetBankField(FBank,Opl^.Point.Dat[c1].Bn.BankKod)+
        ' �㬬�:'+Opl^.Point.Dat[c1].Bn.Summa); }
      s:=s+^M+Space1+'�/�:'+Opl^.Point.Dat[c1].Bn.NPlat+' �� '+Opl^.Point.Dat[c1].Bn.Date+' ����:'+
        GetBankField(FBank,Opl^.Point.Dat[c1].Bn.BankKod)+
        ' �㬬�:'+Opl^.Point.Dat[c1].Bn.Summa;
    End;

    TempBox^.List^.Insert(NewStr(s));
    TempBox^.SetRange(TempBox^.List^.Count);
   (* Writeln(txt,Space1+s);*)


  (* If (Opl^.Point.Dat[c1].Rashet=2) Then
    Begin
     For i:=1 To MaxVeksel Do
     Begin
      If (Opl^.Point.Dat[c1].Veksel.Exampl[i].Numer[0]<>#0) Then
      Begin
       DelSpace(Opl^.Point.Dat[c1].Veksel.Exampl[i].Numer);
       Format(Opl^.Point.Dat[c1].Veksel.Exampl[i].Numer,CPack);
       MyStr(StrToReal(Opl^.Point.Dat[c1].Veksel.Exampl[i].Summa),CIZena,CMantissa,Opl^.Point.Dat[c1].Veksel.Exampl[i].Summa);
       Writeln(txt,Space1+'N ���ᥫ�:'+Opl^.Point.Dat[c1].Veksel.Exampl[i].Numer+' �� '+
          Opl^.Point.Dat[c1].Veksel.Exampl[i].Data+
          +' �� ��������: '+Opl^.Point.Dat[c1].Veksel.Exampl[i].DogovorNumer+
          ' �㬬�:'+Opl^.Point.Dat[c1].Veksel.Exampl[i].Summa);
      End;
     End;
    End;   *)

 End;{FiltrDateMarket}
End;{If tip}
   End;
end;
End;{For}
    Dispose(Opl,Done)
  End;
 l:=Ioresult;
 Close(f);
 l:=Ioresult;
 (* If Start<>Stop Then
  Begin
   Writeln(Txt,Space+'�������������������������������������������������������������������������������������������');
   Writeln(txt,Space+' �ᥣ� ����� ���ᨣ��樨 �� '+Dates+' ��⠢���: ',RecognizReal(PromItog,CIZena,CMantissa),' ��.');
   Writeln(txt);
  End;   *)
  End{IOResult=0}
  Else
   Begin
   {
   if Regim Then
     MessageBox(#3^M+#3'�� ������ 䠩� '+Path^.Dat.ToOplata+Dates+'.opl',Nil,mfError+mfCancelButton);
   }
   End;
End;{For}

AgItog:=0;
AgItogRet:=0;
AgItogSF:=0;
AgItogBN:=0;

sOldAgent:='';

if TempBox^.List^.Count>0 then
for i:=0 to TempBox^.List^.Count-1 do
begin
  s:=TempBox^.GetText(i,TempBox^.List^.Count);
  sAgent:=copy(s,1,CClientKod);
  if sAgent<>sOldAgent then
  begin
  if i>0 then
  begin
  Writeln(Txt,Space+'------------------------------------------------------------------------------------------');
  Writeln(txt,Space+'         �⮣� ����� ���ᨣ��樨: ',RecognizReal(AgItog,CIZena,CMantissa),' ��.');
  If (M3[4]=1) Then
  Writeln(txt,Space+'     � ⮬ �᫥ ����� �����⮬: ',RecognizReal(AgItogRet,CIZena,CMantissa),' ��.');
  Writeln(txt,Space+' �ᥣ� ����� ���ᨣ��樨 � �/� : ',RecognizReal(AgItogSF,CIZena,CMantissa),' ��.');
  Writeln(txt,Space+'     �ᥣ� ����� ���ᨣ��樨 �/�: ',RecognizReal(AgItogBN,CIZena,CMantissa),' ��.');
  Writeln(Txt,Space+'------------------------------------------------------------------------------------------');

   AgItog:=0;
   AgItogRet:=0;
   AgItogSF:=0;
   AgItogBN:=0;

  end;
   writeln(txt,Space+'�����: '+GetAgentField(FAgent,sAgent)+' ('+sAgent+')');
   sOldAgent:=sAgent;
  end;
  System.Delete(s,1,CClientKod+1);
  writeln(txt,Space1+s);

  AgItog:=AgItog+StrToReal(Copy(s,1+CClient+1+CClientKod+1+CDocNumer+1+CDate+1+1,CIZENA));
  if pos('������',s)>0 then
  AgItogRet:=AgItogRet+StrToReal(Copy(s,1+CClient+1+CClientKod+1+CDocNumer+1+CDate+1+1,CIZENA));
  if pos('��',s)>0 then
  AgItogSF:=AgItogSF+StrToReal(Copy(s,1+CClient+1+CClientKod+1+CDocNumer+1+CDate+1+1,CIZENA));
  if pos('����:',s)>0 then
  AgItogBN:=AgItogBN+StrToReal(Copy(s,1+CClient+1+CClientKod+1+CDocNumer+1+CDate+1+1,CIZENA));

  if i=TempBox^.List^.Count-1 then
  begin
  Writeln(txt,Space+'         �⮣� ����� ���ᨣ��樨: ',RecognizReal(AgItog,CIZena,CMantissa),' ��.');
  If (M3[4]=1) Then
  Writeln(txt,Space+'     � ⮬ �᫥ ����� �����⮬: ',RecognizReal(AgItogRet,CIZena,CMantissa),' ��.');
  Writeln(txt,Space+' �ᥣ� ����� ���ᨣ��樨 � �/� : ',RecognizReal(AgItogSF,CIZena,CMantissa),' ��.');
  Writeln(txt,Space+'     �ᥣ� ����� ���ᨣ��樨 �/�: ',RecognizReal(AgItogBN,CIZena,CMantissa),' ��.');
  End;

end;

  Writeln(Txt,Space+'�������������������������������������������������������������������������������������������');
  Writeln(txt,Space+'         �ᥣ� ����� ���ᨣ��樨 ��⠢���: ',RecognizReal(ItogoOZ,CIZena,CMantissa),' ��.');

  If (M3[4]=1) Then
  Writeln(txt,Space+'     � ⮬ �᫥ ����� �����⮬ ��⠢���: ',RecognizReal(ItogoRet,CIZena,CMantissa),' ��.');

  Writeln(txt,Space+' �ᥣ� ����� ���ᨣ��樨 � �/�  ��⠢���: ',RecognizReal(ItogoSF,CIZena,CMantissa),' ��.');
  Writeln(txt,Space+'     �ᥣ� ����� ���ᨣ��樨 �/� ��⠢���: ',RecognizReal(ItogoBN,CIZena,CMantissa),' ��.');
  (*Writeln(txt,Space+'�ᥣ� ����� ���ᨣ��樨 ���ᥫ�� ��⠢���: ',RecognizReal(ItogoVks,CIZena,CMantissa),' ��.');*)

  Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  Writeln(Txt,Space+'============================');

 l:=Ioresult;
Close(Txt);
 l:=Ioresult;

Dispose(TempBox,Done);

 if Regim then NoInfo;
 Dispose(AgentList,Done);

 If Regim Then ViewAsText(Path^.Dat.ToTemp+'oplagnt.txt','��ࠢ�� �� ����� ���ᨣ��樨 ����⮢ � '+StartDate+
' �� '+StopDate,True);


End;

BEGIN
END.