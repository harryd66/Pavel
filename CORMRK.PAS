{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


{$I Compile.INC}


Unit CorMrk;

Interface

Uses Dialogs,Glob,ColorTxt,ServStr,Drivers,Views,MyCalc;


Type
  PCorrectMarket = ^TCorrectMarket;
  TCorrectMarket = object(TDialog)
    Calc        : PMyCalculator;
    procedure  Start(SDoc,SDate:TDateString);
    procedure  RefreshNakl;
         procedure  DrawFullName;
         procedure  FormReport(Const P:PBox);
         procedure  RefreshTovar;
         procedure  DrawCurrent;
    procedure  HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;

{Function Modifed(SDoc,SDate:TDateString):Boolean;}

implementation


Uses app,Memory,Dos,MsgBox,Objects,Validate,TpDate,Serv,WinDos,Vision5,Vision4,
     ServStr2,
     DbEngine,Utils,NetCall,NetDbEng,CPrihod,Protect{,StarSky},Gadgets,Printers;


Const    DocPos = 1+CClient+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CMAntissa+1;
      SkidkaPos = 1+CClient+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CMAntissa+1+COne+1;
       AgentPos = 1+CClient+1+CDate+1+CIZena+1+CIZena+1+CKto+1+CMAntissa+1+COne+1+COne+1;

Var MrkWin : PCorrectMarket;
         MrkList : PBox;
         TvrList : PBox;
      ControlMaska,
         ControlFullName,ControlSkidka,ControlAgent,ControlDoc,ControlAmount,ControlVersion,
         ControlItogoOplata,ControlVidSkidka,ControlVidDoc : PView;
         CurrentLine : String;
         FindDoc,FindDate : TDateString;
         PrevNAme:String;
      MaskaFiltr: Maska2;
      Maska: Word;


procedure TCorrectMarket.Start(SDoc,SDate:TDateString);
Var R : TRect;
    Control : PView;
    C : Word;
Begin
FindDoc:=SDoc;
DelSpace(SDoc);
FindDate:=SDate;
R.Assign(0, 0, 80, 23);
New(MrkWin, Init(R, '�஭������ ।���஢���� ���㬥�� ���㧪� N '+FindDoc+' �� '+FindDate));

R.Assign(0, 7, 80, 8);
Control := New(PColoredText, Init(R, '�������������������������������������'+
     '�����������������������������������������͹', $7F));
MrkWin^.Insert(Control);

R.Assign(79, 2, 80, 6);
Control := New(PScrollBar, Init(R));
MrkWin^.Insert(Control);

R.Assign(1, 2, 79, 6);
MrkList := New(PBox, Init(R, 1, PScrollbar(Control)));
MrkList^.NewList(New(PMyCollection, Init(0,1)));
MrkWin^.HelpCtx:=$F093;
MrkWin^.Insert(MrkList);


  R.Assign(1, 1, 78, 2);
  MrkWin^.Insert(New(PLabel, Init(R, '������                �६�    �㬬� ���㧪�   �㬬� ᪨���    ������   N',
  MrkList)));
{
MaskaFiltr[1]:=1;
MaskaFiltr[2]:=1;
}
BitToWord2(MaskaFiltr,Maska);
{Convert2(MaskaFiltr);}

R.Assign(2, 7, 45, 8);
ControlMaska := New(PCheckboxes, Init(R,
  NewSItem('~�~����',
  NewSItem('~�~��஢���⥫�� ���㬥���', Nil))));
MrkWin^.Insert(ControlMaska);

ControlMaska^.SetData(MAska);


R.Assign(79, 9, 80, 21);
Control := New(PScrollBar, Init(R));
MrkWin^.Insert(Control);

R.Assign(1, 9, 79, 21);
TvrList := New(PBox, Init(R, 1, PScrollbar(Control)));
TvrList^.NewList(New(PTextCollection, Init(0,1)));
TvrList^.HelpCtx:=$F096;
MrkWin^.Insert(TvrList);

  R.Assign(1, 8, 78, 9);
  MrkWin^.Insert(New(PLabel, Init(R, '������������ ⮢��         ���  N ����� ���� ��� ���� ���  ������   ��業�', TvrList
  )));


R.Assign(2, 21, 22, 22);
Control := New(PColoredText, Init(R, '������������ ⮢��:', $74));
MrkWin^.Insert(Control);

R.Assign(22, 21, 79, 22);
ControlFullName := New(PColoredText, Init(R, ' ', $7e));
MrkWin^.Insert(ControlFullName);


R.Assign(2, 6, 9, 7);
Control := New(PColoredText, Init(R, '������:', $74));
MrkWin^.Insert(Control);

R.Assign(9, 6, 15, 7);
ControlSkidka := New(PColoredText, Init(R, '???', $7E));
MrkWin^.Insert(ControlSkidka);

R.Assign(18, 6, 32, 7);
Control := New(PColoredText, Init(R, '��� ���㬥��:', $74));
MrkWin^.Insert(Control);

R.Assign(32, 6, 41, 7);
ControlVidDoc := New(PColoredText, Init(R, '???', $7E));
MrkWin^.Insert(ControlVidDoc);

R.Assign(44, 6, 50, 7);
Control := New(PColoredText, Init(R, '�����:', $74));
MrkWin^.Insert(Control);

R.Assign(50, 6, 78, 7);
ControlAgent := New(PColoredText, Init(R, #3+'???', $1F));
MrkWin^.Insert(ControlAgent);

R.Assign(49, 7, 73, 8);
Control := New(PColoredText, Init(R, ' �⮣� ���ᨩ ���㬥��:', $74));
MrkWin^.Insert(Control);

R.Assign(43, 22, 47, 23);
ControlAmount := New(PColoredText, Init(R, #3+'?', $4E));
MrkWin^.Insert(ControlAmount);

R.Assign(28, 22, 43, 23);
Control := New(PColoredText, Init(R, ' �⮣� ����権:', $74));
MrkWin^.Insert(Control);

R.Assign(63, 22, 78, 23);
ControlItogoOplata := New(PColoredText, Init(R, #3+'0.00', $4E));
MrkWin^.Insert(ControlItogoOplata);

R.Assign(47, 22, 63, 23);
Control := New(PColoredText, Init(R, ' �⮣� � �����:', $74));
MrkWin^.Insert(Control);

R.Assign(73, 7, 78, 8);
ControlVersion := New(PColoredText, Init(R, #3+'?', $4E));
MrkWin^.Insert(ControlVersion);

MrkWin^.SelectNext(False);

RefreshNakl;

CurrentLine[0]:=#0;
PrevNAme[0]:=#0;
c:=Desktop^.ExecView(MrkWin);

Dispose(MrkWin,Done);
End;

procedure TCorrectMarket.DrawFullNAme;
Var S: String;
         R : TRect;
         SArt : ArtikulStr;
Begin
If (TVrList^.List<>Nil)And(TVrList^.List^.Count>=1) Then
Begin
s:=TVrList^.GetText(TVrList^.Focused,TVrList^.List^.Count);
If s<>PrevName Then
Begin
 PrevName:=s;
 Sart:=Copy(s,1,CArtikul);
 Dispose(ControlFullName,Done);
 R.Assign(22, 21, 79, 22);
 s:=GetIdField(FFFName,Sart);
 DelSpaceRight(s);
 {s:=' '+s+' '+GetIdField(FName2,Sart);}
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 MrkWin^.Insert(ControlFullName);
End;
End
 Else
  Begin
 PrevName[0]:=#0;
 Dispose(ControlFullName,Done);
 R.Assign(22, 21, 79, 22);
 s:=' ';
 ControlFullName := New(PColoredText, Init(R, s, $7e));
 MrkWin^.Insert(ControlFullName);
  End;


End;


procedure TCorrectMarket.RefreshNakl;
Var Ef : File;
         E  : PBufSuperMarketType;
         Version,c  : Word;
         Find : Boolean;
         s,s1 : String;
    wsSummaZ,wsSkidka : AllStr;
    wsAmount : Word;
    c1,Count : Word;
Begin
{᭠砫� ������塞 �� ���� ��ਠ���}
DInfoMsg('��ᬠ�ਢ�� ���४�஢�� ���㬥��...',False);
Assign(ef,Path^.Dat.ToMarket+FindDate+'.cor');
c:=IOResult;
Reset(ef,SizeOf(SuperMArketType));
c:=IOResult;
Version:=0;

MrkList^.NewList(Nil);
MrkList^.NewList(New(PMyCollection, Init(1,1)));
Find:=False;

WordToBit2(Maska,MaskaFiltr);
Convert2(MaskaFiltr);


If c=0 Then
Begin
While Not(Eof(ef)) Do
 Begin
  New(e,Init);
  ReadBufMarket(ef,E,Count);
For c1:=1 To Count Do
Begin
  DelSpace(E^.Point.DAt[c1].Document);
  ClearChar(E^.Point.DAt[c1].Document);

  If (E^.Point.DAt[c1].Document=FindDoc) And (E^.Point.DAt[c1].DateC=FindDate) Then Find:=True;

  If Find Then
   Begin
wsSummaZ[0]:=#0;
wsSkidka[0]:=#0;
wsAmount:=0;

    Inc(Version);
   {������                �६�    �㬬� ���㧪�   �㬬� ᪨���    ������   N}
    s:=GetClientField(FClient,E^.Point.DAt[c1].ClientKod,E^.Point.DAt[c1].OperatorSelector);
    Format(S,CClient);
    s1:=GetOperatorField(FNAme,E^.Point.DAt[c1].Caption);
    Format(s1,CKto);
    MyStr(StrToReal(E^.Point.DAt[c1].Skidka),CIZena,CMantissa,E^.Point.DAt[c1].Skidka);
    MyStr(StrToReal(E^.Point.DAt[c1].SertifSkidka),CIZena,CMantissa,E^.Point.DAt[c1].SertifSkidka);

    If MaskaFiltr[1]=1 Then
    MyStr(StrToReal(wsSkidka)+StrToReal(E^.Point.DAt[c1].Skidka),CIZena,CMantissa,wsSkidka);
    If MaskaFiltr[2]=1 Then
    MyStr(StrToReal(wsSkidka)+StrToReal(E^.Point.DAt[c1].SertifSkidka),CIZena,CMantissa,wsSkidka);

    MyStr(StrToReal(E^.Point.DAt[c1].Skidka)+StrToReal(E^.Point.DAt[c1].SummaZ),CIZena,CMantissa,E^.Point.DAt[c1].SummaZ);
    MyStr(StrToReal(E^.Point.DAt[c1].SertifSkidka)+StrToReal(E^.Point.DAt[c1].SertifSummaZ),CIZena,CMantissa,
    E^.Point.DAt[c1].SertifSummaZ);

    If MaskaFiltr[1]=1 Then
    MyStr(StrToReal(wsSummaZ)+StrToReal(E^.Point.DAt[c1].SummaZ),CIZena,CMantissa,wsSummaZ);
    If MaskaFiltr[2]=1 Then
    MyStr(StrToReal(wsSummaZ)+StrToReal(E^.Point.DAt[c1].SertifSummaZ),CIZena,CMantissa,wsSummaZ);

    MyStr(StrToReal(wsSummaZ),CIZena,CMantissa,wsSummaZ);
    MyStr(StrToReal(wsSkidka),CIZena,CMantissa,wsSkidka);

    s:=S+'�'+E^.Point.DAt[c1].TimeM+'�'+wsSummaZ{E^.Point.DAt[c1].SummaZ}+'�'+{E^.Point.DAt[c1].Skidka}wsSkidka+'�'+s1+'�';
    s1:=IntToStr(Version,CMantissa);
         RFormat(s1,CMantissa);
    s:=s+s1+'�'+IntToStr(E^.Point.DAt[c1].DocSelector,COne)+'�'+IntToStr(E^.Point.DAt[c1].SkidkaSelector,COne)+'�'+
    E^.Point.DAt[c1].AgentKod;
    MrkList^.List^.Insert(NewStr(s));
         MrkList^.SetRange(MrkList^.List^.Count);
    Find:=False;
   End;
End;
  Dispose(E,Done);
 End;{While}
System.Close(ef);
End;

{������塞 ��᫥���� ��ਠ�� ���������}
Assign(ef,Path^.Dat.ToMarket+FindDate+'.mrk');
c:=IOResult;
Reset(ef,SizeOf(SuperMArketType));
c:=IOResult;
If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'�訡�� ������ 䠩�� '+Path^.Dat.ToMarket+FindDate+'.mrk!',Nil,mfError+mfCancelButton);
  CurrentLine[0]:=#0;
  Exit;
 End;

Find:=False;
While Not(Eof(ef)) And (Not(Find)) Do
 Begin
  New(e,Init);
  ReadBufMarket(ef,E,Count);
  For c1:=1 To Count Do
Begin
  If E^.Point.DAt[c1].Active Then
        Begin
         If (E^.Point.DAt[c1].Document=FindDoc) And (E^.Point.DAt[c1].DateC=FindDate) Then Find:=True;
         If Find Then
          BEgin
wsSummaZ[0]:=#0;
wsSkidka[0]:=#0;
wsAmount:=0;
                Inc(Version);
          {������                �६�    �㬬� ���㧪�   �㬬� ᪨���    ������   N}
                s:=GetClientField(FClient,E^.Point.DAt[c1].ClientKod,E^.Point.DAt[c1].OperatorSelector);
      Format(S,CClient);
      s1:=GetOperatorField(FNAme,E^.Point.DAt[c1].Caption);
      Format(s1,CKto);
      MyStr(StrToReal(E^.Point.DAt[c1].Skidka),CIZena,CMantissa,E^.Point.DAt[c1].Skidka);
      MyStr(StrToReal(E^.Point.DAt[c1].SertifSkidka),CIZena,CMantissa,E^.Point.DAt[c1].SertifSkidka);
      MyStr(StrToReal(E^.Point.DAt[c1].Skidka)+StrToReal(E^.Point.DAt[c1].SummaZ),CIZena,CMantissa,E^.Point.DAt[c1].SummaZ);
      MyStr(StrToReal(E^.Point.DAt[c1].SertifSkidka)+StrToReal(E^.Point.DAt[c1].SertifSummaZ),CIZena,CMantissa,
         E^.Point.DAt[c1].SertifSummaZ);

    If MaskaFiltr[1]=1 Then
    MyStr(StrToReal(wsSkidka)+StrToReal(E^.Point.DAt[c1].Skidka),CIZena,CMantissa,wsSkidka);
    If MaskaFiltr[2]=1 Then
    MyStr(StrToReal(wsSkidka)+StrToReal(E^.Point.DAt[c1].SertifSkidka),CIZena,CMantissa,wsSkidka);

    If MaskaFiltr[1]=1 Then
    MyStr(StrToReal(wsSummaZ)+StrToReal(E^.Point.DAt[c1].SummaZ),CIZena,CMantissa,wsSummaZ);
    If MaskaFiltr[2]=1 Then
    MyStr(StrToReal(wsSummaZ)+StrToReal(E^.Point.DAt[c1].SertifSummaZ),CIZena,CMantissa,wsSummaZ);

    MyStr(StrToReal(wsSummaZ),CIZena,CMantissa,wsSummaZ);
    MyStr(StrToReal(wsSkidka),CIZena,CMantissa,wsSkidka);

      {s:=S+'�'+E^.Point.DAt[c1].TimeM+'�'+E^.Point.DAt[c1].SummaZ+'�'+E^.Point.DAt[c1].Skidka+'�'+s1+'�';}
      s:=S+'�'+E^.Point.DAt[c1].TimeM+'�'+wsSummaZ{E^.Point.DAt[c1].SummaZ}+'�'+{E^.Point.DAt[c1].Skidka}wsSkidka+'�'+s1+'�';
         s1:=IntToStr(Version,CMantissa);
      RFormat(s1,CMantissa);
      s:=s+s1+'�'+IntToStr(E^.Point.DAt[c1].DocSelector,COne)+'�'+IntToStr(E^.Point.DAt[c1].SkidkaSelector,COne)+'�'+
         E^.Point.DAt[c1].AgentKod;

      MrkList^.List^.Insert(NewStr(s));
      MrkList^.SetRange(MrkList^.List^.Count);
      Break;
          End;
   End;
End;{For}
Dispose(E,Done);
 End;{While}
System.Close(ef);


If Not(Find) Then
 MessageBox(^M+#3+'���㬥�� N '+FindDoc+' �� '+FindDate+' � ���� �� ������!'+ClicProgrammer^,Nil,
 mfError+mfCancelButton);

MrkList^.FocusItem(0);
CurrentLine[0]:=#0;
PrevNAme[0]:=#0;
NoInfoMsg;
RefreshTovar;
End;


procedure TCorrectMarket.RefreshTovar;
Var stime : TDateString;
    Ef : File;
    E : PSuperMarketType;
    E1 : PBufSuperMarketType;
    wspomskidka,ws,ws1,s : String;
    Find : Boolean;
    c : Word;
    R : TRect;
    wsSummaZ,wsSkidka : AllStr;
    wsAmount : Word;
    c1,Count : word;
Begin

If (MrkList^.List<>Nil)And(MrkList^.List^.Count>=1) Then
Begin
wsSummaZ[0]:=#0;
wsSkidka[0]:=#0;
wsAmount:=0;

TvrList^.NewList(Nil);
TvrList^.NewList(New(PTextCollection, Init(0,1)));

DInfoMsg('��� ����� N'+IntToStr(MrkList^.Focused+1,CMantissa)+' ���㬥�� N'+FindDoc+' �� '+FindDate+' ...',False);

STime := Copy(MrkList^.GetText(MrkList^.Focused,MrkList^.List^.Count),1+CCLient+1,CDate);

If MrkList^.Focused=MrkList^.List^.Count-1 Then
s:=Path^.Dat.ToMarket+FindDate+'.mrk'
Else s:=Path^.Dat.ToMarket+FindDate+'.cor';

Assign(ef,s);
c:=IOResult;
Reset(ef,SizeOf(SuperMArketType));
c:=Ioresult;

If c<>0 Then
 Begin
  NoInfoMsg;
  TvrList^.FocusItem(0);
  MessageBox(^M+#3'�訡�� ������ 䠩�� '+s+'!',Nil,mfError+mfCancelButton);
  Exit;
 End;

New(E,Init);
Find:=False;
While Not(Eof(Ef))And Not(Find) Do
Begin
  New(e1,Init);
  ReadBufMarket(ef,E1,Count);
For c1:=1 To Count Do
Begin
 DelSpace(E1^.Point.DAt[c1].Document);
 If (ClearChar(E1^.Point.DAt[c1].Document)=ClearChar(FindDoc)) And
 (E1^.Point.DAt[c1].DateC=FindDate) And (E1^.Point.DAt[c1].TimeM=STime) Then
  Begin
   Find:=True;
   E^.DAt:=E1^.Point.Dat[c1];
   Break;
  End;
End;
 Dispose(e1,Done);
End;

System.Close(Ef);

 If Not(Find) Then
 Begin
        Dispose(E,Done);
        NoInfoMsg;
        MessageBox(#3^M+#3'���㬥�� N '+ FindDoc+' �� '+FindDate+'('+Stime+') � ���� ���४�஢�� �� '+
        FindDate+' �� ������!'+
        ClicProgrammer^,Nil,mfError+mfCancelButton);
        Exit;
 End;


WordToBit2(Maska,MaskaFiltr);
Convert2(MaskaFiltr);

If MaskaFiltr[1] = 1 Then
Begin
For c:=1 To E^.Dat.Amount Do
 Begin
  S:=E^.Dat.MarketElement[c].BazKod;
  ws:=GetIdField(FName,s);
  Format(ws,CName);
  s:=s+'�'+ws+'�';
  Str(E^.Dat.MarketElement[c].Input.DivisionNumber:1,ws);
  s:=s+ws;



  DelSpace(E^.Dat.MarketElement[c].Input.Kol);
  Format(E^.Dat.MarketElement[c].Input.Kol,CKol);
  s:=s+'�'+E^.Dat.MarketElement[c].Input.Kol;

  DelSpace(E^.Dat.MarketElement[c].Input.Zena);
  Format(E^.Dat.MarketElement[c].Input.Zena,CZena);
  s:=s+'�'+E^.Dat.MarketElement[c].Input.Zena;

                  Case E^.Dat.SkidkaSelector Of
                0:Begin{᪨��� ��⮬���᪠�}
                        MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
                        (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100),CZena,
                                    CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

                        {�ଠ��㥬 ��業��}
                        MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Proz),CZena,CMantissa,ws1);
                        MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Skidka),CZena,CMantissa,
                                    E^.Dat.MarketElement[c].Input.Skidka);

                        MyStr((StrToReal(E^.Dat.MarketElement[c].Input.Zena)/
                  (1+StrToReal(E^.Dat.MarketElement[c].Input.Proz)/100)),CZena,CMantissa,wspomSkidka);

         S:=s+'�'+WspomSkidka+'�'+E^.Dat.MarketElement[c].Input.Skidka+'�'+ws1+'�';
        End;
      1:Begin{᪨��� ��筠�}

           If StrToReal(E^.Dat.MarketElement[c].Input.Skidka)>=0 Then
           Begin
          If (StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka))>0.009 Then
          MyStr(((StrToReal(E^.Dat.MarketElement[c].Input.Zena))/((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
          StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))-1)*100
          ,CZena,CLitrMantissa,ws1)
          Else ws1:='100.00';

                         MyStr(StrToReal(Ws1){*100},CZena,CMantissa,ws1);
           End
           Else
             Begin
              MyStr((-(Abs(StrToReal(E^.Dat.MarketElement[c].Input.Skidka)))/
              ((StrToReal(E^.Dat.MarketElement[c].Input.Zena)))*100),CZena,CMantissa,Ws1);
             End;

          MyStr(StrToReal(E^.Dat.MarketElement[c].Input.Skidka),CZena,CMantissa,E^.Dat.MarketElement[c].Input.Skidka);

          MyStr((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-StrToReal(E^.Dat.MarketElement[c].Input.Skidka))
          ,CZena,CMantissa,wspomSkidka);

          S:=s+'�'+WspomSkidka+'�'+E^.Dat.MarketElement[c].Input.Skidka+'�'+ws1+'�';
        End;
      Else;
      End;{E^.Dat.SkidkaSelector}

  TvrList^.List^.Insert(NewStr(s));
  TvrList^.SetRange(TvrList^.List^.Count);
  End;
End;

If MaskaFiltr[2] = 1 Then
Begin
For c:=1 To E^.Dat.AmountS Do
 Begin
  S:=E^.Dat.DocumentElement[c].BazKod;
  ws:=GetIdField(FName,s);
  ws:='�'+ws;
  Format(ws,CName);
  s:=s+'�'+ws+'�';
  Str(E^.Dat.DocumentElement[c].Input.DivisionNumber:1,ws);
  s:=s+ws;

  DelSpace(E^.Dat.DocumentElement[c].Input.Kol);
  Format(E^.Dat.DocumentElement[c].Input.Kol,CKol);
  s:=s+'�'+E^.Dat.DocumentElement[c].Input.Kol;

  DelSpace(E^.Dat.DocumentElement[c].Input.Zena);
  Format(E^.Dat.DocumentElement[c].Input.Zena,CZena);
  s:=s+'�'+E^.Dat.DocumentElement[c].Input.Zena;

                  Case E^.Dat.SkidkaSelector Of
                0:Begin{᪨��� ��⮬���᪠�}
                        MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Zena)-StrToReal(E^.Dat.DocumentElement[c].Input.Zena)/
                        (1+StrToReal(E^.Dat.DocumentElement[c].Input.Proz)/100),CZena,CMantissa,
                                    E^.Dat.DocumentElement[c].Input.Skidka);

                        {�ଠ��㥬 ��業��}
                        MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Proz),CZena,CMantissa,ws1);
                        MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Skidka),CZena,CMantissa,
                                    E^.Dat.DocumentElement[c].Input.Skidka);

                        MyStr((StrToReal(E^.Dat.DocumentElement[c].Input.Zena)/
                  (1+StrToReal(E^.Dat.DocumentElement[c].Input.Proz)/100)),CZena,CMantissa,wspomSkidka);

         S:=s+'�'+WspomSkidka+'�'+E^.Dat.DocumentElement[c].Input.Skidka+'�'+ws1+'�';
        End;
      1:Begin{᪨��� ��筠�}

           If StrToReal(E^.Dat.DocumentElement[c].Input.Skidka)>=0 Then
           Begin
          If (StrToReal(E^.Dat.DocumentElement[c].Input.Zena)-StrToReal(E^.Dat.DocumentElement[c].Input.Skidka))>0.009 Then
          MyStr(((StrToReal(E^.Dat.DocumentElement[c].Input.Zena))/((StrToReal(E^.Dat.DocumentElement[c].Input.Zena)-
          StrToReal(E^.Dat.DocumentElement[c].Input.Skidka)))-1)*100
          ,CZena,CLitrMantissa,ws1)
          Else ws1:='100.00';

                         MyStr(StrToReal(Ws1){*100},CZena,CMantissa,ws1);
           End
           Else
             Begin
              MyStr((-(Abs(StrToReal(E^.Dat.DocumentElement[c].Input.Skidka)))/
              ((StrToReal(E^.Dat.DocumentElement[c].Input.Zena)))*100),CZena,CMantissa,Ws1);
             End;

          MyStr(StrToReal(E^.Dat.DocumentElement[c].Input.Skidka),CZena,CMantissa,E^.Dat.DocumentElement[c].Input.Skidka);

          MyStr((StrToReal(E^.Dat.DocumentElement[c].Input.Zena)-StrToReal(E^.Dat.DocumentElement[c].Input.Skidka))
          ,CZena,CMantissa,wspomSkidka);

          S:=s+'�'+WspomSkidka+'�'+E^.Dat.DocumentElement[c].Input.Skidka+'�'+ws1+'�';
        End;
      Else;
      End;{E^.Dat.SkidkaSelector}

  TvrList^.List^.Insert(NewStr(s));
  TvrList^.SetRange(TvrList^.List^.Count);
  End;
End;

TvrList^.FocusItem(0);

Dispose(ControlAmount,Done);
R.Assign(43, 22, 47, 23);

If MaskaFiltr[1] = 1 Then
wsAmount:=wsAmount+E^.Dat.Amount;
If MaskaFiltr[2] = 1 Then
wsAmount:=wsAmount+E^.Dat.Amounts;

ControlAmount := New(PColoredText, Init(R, #3+IntToStr(wsAmount{E^.Dat.Amount},CMantissa), $4E));
MrkWin^.Insert(ControlAmount);

Dispose(ControlItogoOplata,Done);
R.Assign(63, 22, 78, 23);
DelSpace(E^.Dat.SummaZ);

    If MaskaFiltr[1]=1 Then
    MyStr(StrToReal(wsSummaZ)+StrToReal(E^.Dat.SummaZ),CIZena,CMantissa,wsSummaZ);
    If MaskaFiltr[2]=1 Then
    MyStr(StrToReal(wsSummaZ)+StrToReal(E^.Dat.SertifSummaZ),CIZena,CMantissa,wsSummaZ);

    MyStr(StrToReal(wsSummaZ),CIZena,CMantissa,wsSummaZ);
    DelSpace(wsSummaZ);

ControlItogoOplata := New(PColoredText, Init(R, #3+wsSummaZ{E^.Dat.SummaZ}, $4E));
MrkWin^.Insert(ControlItogoOplata);

Dispose(E,Done);
NoInfoMsg;
End;
End;


procedure TCorrectMarket.DrawCurrent;
Var S,s1 : String;
         R : TRect;
Begin
If (MrkList^.List<>Nil)And(MrkList^.List^.Count>=1) Then
Begin
 Dispose(ControlSkidka,Done);
 s:=Copy(CurrentLine,SkidkaPos,COne);
 Case StrToInt(s) Of
 0:s:='���';
 1:s:='��筠�';
 2:s:='�����';
 Else s:='???';
 End;

 R.Assign(9, 6, 15, 7);
 ControlSkidka := New(PColoredText, Init(R, #3+s, $7E));
 MrkWin^.Insert(ControlSkidka);

 Dispose(ControlVidDoc,Done);
 s:=Copy(CurrentLine,DocPos,COne);
 Case StrToInt(s) Of
    0:s:='���᮪';
    1:s:='���.���*';
    2:s:='���.�*';
    3:s:='��*';
    4:s:='�� �';
    5:s:='�����*';
    6:s:='����� ��*';
    7:s:='�����';
    8:s:='����� ���';
 Else s:='???';
 End;
 R.Assign(32, 6, 41, 7);
 ControlVidDoc := New(PColoredText, Init(R, #3+s, $7E));
 MrkWin^.Insert(ControlVidDoc);

 Dispose(ControlAgent,Done);
 s:=Copy(CurrentLine,AgentPos,CClientKod);
 s1:=GetAgentField(FClient,s);
 Format(S1,CClient);

 R.Assign(50, 6, 78, 7);
 ControlAgent := New(PColoredText, Init(R, #3+s1+'('+s+')', $1F));
 MrkWin^.Insert(ControlAgent);

 Dispose(ControlVersion,Done);
 R.Assign(73, 7, 78, 8);
 ControlVersion := New(PColoredText, Init(R, #3+IntToStr(MrkList^.List^.Count,CMantissa), $4E));
 MrkWin^.Insert(ControlVersion);
End
Else
 Begin
    If PStaticText(ControlSkidka)^.Text^<>#3'???' Then
    Begin
    Dispose(ControlSkidka,Done);
    R.Assign(9, 6, 15, 7);
    ControlSkidka := New(PColoredText, Init(R, #3+'???', $7E));
    MrkWin^.Insert(ControlSkidka);

    Dispose(ControlVidDoc,Done);
    R.Assign(32, 6, 41, 7);
    ControlVidDoc := New(PColoredText, Init(R, #3+'???', $7E));
    MrkWin^.Insert(ControlVidDoc);

    Dispose(ControlAgent,Done);
    R.Assign(50, 6, 78, 7);
    ControlAgent := New(PColoredText, Init(R, #3+'???', $1F));
    MrkWin^.Insert(ControlAgent);

    Dispose(ControlVersion,Done);
    R.Assign(73, 7, 78, 8);
    ControlVersion := New(PColoredText, Init(R, #3+'???', $4E));
    MrkWin^.Insert(ControlVersion);
    End;

 End;
End;

Procedure TCorrectMarket.FormReport(Const P:PBox);
Const Space='';
var f:text;
    k,c:word;

    S : String;
    s1,s2,s3 : AllStr;
Begin
DInfoMsg('��ନ��� ����...',False);

 Assign (f,Path^.Dat.ToTemp+'versionp.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(#3^m+#3+'�� ���� ᮧ���� 䠩� '+Path^.Dat.ToTemp+'versionp.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(f,Space+'�����: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  ������: '+CurrentPassword+' EYE & 97-00');
 Writeln(f,Space+'     ���������� �������������� ��������� N'+FINDDoc+' �� '+FindDate);
 Writeln(f,Space+'----------------------------------------------------------------------------------------------');
 Writeln(f,Space+'������                 �६�   �㬬� ���㧪�    �㬬� ᪨���     ������ N      ���.�  �����');
                 {12345678901234567890�12345678�123456789012345�123456789012345�123456789012�12���糄��.���1234}

 Writeln(f,Space+'----------------------------------------------------------------------------------------------');

If (P^.List^.Count-1)>=0 Then
 Begin
 For c:=0 To P^.List^.Count-1 Do
  Begin
   s := P^.GetText(c,P^.List^.Count);

   While Pos('�',s)>0 Do
    Begin
     k:=Pos('�',s);
     System.Delete(s,k,1);
     System.Insert(' ',s,k);
    End;
   s1:=Copy(s,SkidkaPos,COne);
   s2:=Copy(s,DocPos,COne);
   s3:=Copy(s,AgentPos,CClientKod);

   s[0]:=Chr(1+CClient+1+CDAte+1+CIZena+1+CIZena+1+CKto+1+2);
   CAse StrToInt(s1) Of
   0:s1:='���';
   1:s1:='���';
   2:s1:='���';
   Else s1:='   ';
   End;
   s:=s+' '+s1;

   CAse StrToInt(s2) Of
   0:s2:='���c��';
   1:s2:='���.�.';
   2:s2:='���.�.';
   3:s2:='��    ';
   4:s2:='�� �  ';
   5:s2:='����� ';
   6:s2:='���.��';
   7:s2:='����� ';
   8:s2:='������';
   Else s2:='      ';
   End;
   s:=s+' '+s2;

   s:=s+' '+s3;

   Writeln(f,Space+s);
  End;{For}
 End;
 Writeln(f,Space+'----------------------------------------------------------------------------------------------');
 Writeln(f,Space+'                                                               �ᥣ� ���ᨩ ���㬥��: ',P^.List^.Count);
 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'==============================================================================================');

 System.Close(f);
 NoInfoMsg;
 Report(Path^.Dat.ToTemp+'versionp.txt','',1,False,False);

End;



procedure TCorrectMarket.HandleEvent(var Event: TEvent);

procedure Calculator;
begin
  Calc^.Start;
end;

Var s : String;
    Test : Word;
Begin
  Case Event.What Of
  evCommand:
  Begin
   Case Event.Command Of
  cmLocalCalc : Calculator;
  cmRefresh: Begin
  If (DeskTop^.Current=PView(MrkWin)) And (Event.What <> EvKeyDown) Then
           Begin
              RefreshNakl;
              ClearEvent(Event);
              Redraw;
           End
           Else
            ClearEvent(Event);
          End;
 cmReestrReport:
            Begin
            if (MrkList^.List<>Nil)And(MrkList^.List^.Count>=1) Then
              Begin
               FormReport(MrkList);
              End;
            End;

  cmPrintReestr:
           Begin
            ClearFind;
     If (MrkList^.State and sfFocused <> 0) And (MrkList^.List<>Nil)And(MrkList^.List^.Count>=1) Then
            Begin
                s:=Copy(MrkList^.GetText(MrkList^.Focused,MrkList^.List^.Count),1+CClient+1,CDate);
                {Status:=DocPrint;}
                Assistent.EditPosition:=FindDoc;
                Assistent.D:=FindDate;
                If MrkList^.Focused=MrkList^.List^.Count-1 Then
                PrintNakl(Assistent,NprintC^.DAt.CopyNaklC)
                Else
                         PrintNaklSpec(Assistent,s,1);
                {Status:=DocNormal;}
            End
           End;
   Else;
   End;{Case Event.Command}
  End;{evCommand}
  EvKeyDown:
   Begin
    CAse Event.KeyCode Of
     kbEsc: Begin
              ClearFind;
              Event.What:=evCommand;
              Event.Command:=cmCancel;
              PutEvent(Event);
              ClearEvent(Event);
              ProdagaWindow:=False;
            End;
     Else;
     End;{Case}
   End;
 Else;
 End;

inherited HandleEvent(Event);
  If (Desktop^.Current=PView(MrkWin)) And (Event.What <> EvKeyDown) Then
                                 Begin

                                        DrawFullNAme;

                                if (MrkList^.List<>Nil)And(MrkList^.List^.Count>=1) Then
                                  Begin
                                        s:=MrkList^.GetText(MrkList^.Focused,MrkList^.List^.Count);
                                        If (s<>CurrentLine) Then
                                          Begin
                                                CurrentLine:=S;
                                                DrawCurrent;
                              RefreshToVar;
                              Redraw;
                           End;
                      End
                       Else
                  DrawCurrent;

          if (ControlMaska^.State and sfFocused <> 0)Then
              Begin
               ControlMaska^.GetData(Test);
               If Test <> Maska Then
               Begin
                  Maska:=Test;
                  RefreshNakl;
                  RefreshToVar;
                  Redraw;
               End;
              End;



                  if (TvrList^.List<>Nil)And(TvrList^.List^.Count>=1)
                  And(TvrList^.State and sfFocused <> 0) Then
                                  Begin
                                        ProdagaWindow:=True;
                                  End
                                  Else
                                        ProdagaWindow:=False;

                                 End;{(Desktop^.Current=PView(MrkWin)) And (Event.What <> EvKeyDown)}
End;

Destructor TCorrectMarket.Done;
Begin
ProdagaWindow:=False;
WordToBit2(Maska,MaskaFiltr);
{Convert2(MaskaFiltr);}
TDialog.Done;
End;
(*
Function Modifed(SDoc,SDate:TDAteString):Boolean;
Var   Ef : File;
         E  : PBufSuperMarketType;
         Version,c  : Word;
         Find : Boolean;
         s,s1 : String;
      c1,Count : Word;
Begin
Modifed:=False;
DelSpace(SDoc);
DelZerro(SDoc);
ClearChar(SDoc);

{᭠砫� ������塞 �� ���� ��ਠ���}
Assign(ef,Path^.Dat.ToMarket+SDate+'.cor');
c:=IOResult;
Reset(ef,SizeOf(SuperMarketType));
c:=IOResult;
Find:=False;

If c=0 Then
Begin
DInfoMsg('��ᬠ�ਢ�� ���४�஢�� ���㬥��...',False);
While Not(Eof(ef)) Do
 Begin
  New(E,Init);
  ReadBufMarket(ef,E,Count);
For c1:=1 To Count Do
Begin
  DelSpace(E^.Point.DAt[c1].Document);
  ClearChar(E^.Point.DAt[c1].Document);

  If (E^.Point.DAt[c1].Document=SDoc) And (E^.Point.DAt[c1].DateC=SDate) Then
   BEgin
    Find:=True;
    Break
   End;
End;{for}
Dispose(E,Done);
 End;{While}
System.Close(ef);
If Find Then Modifed:=True;
NoInfoMsg;
End;

End;

*)

Begin
MaskaFiltr[1]:=1;
MaskaFiltr[2]:=1;

End.