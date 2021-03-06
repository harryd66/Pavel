Uses Glob,ServStr,Serv,Objects,TpDAte;


Type BakInputMarketType=Record
        Kol     : String[CKol];
        Skidka  : String[CZena];
        Zena    : String[CZena];
        R_Zena  : String[CZena];
        O_Zena  : String[CZena];
        Zakupka : String[CZena];
        Itogo   : String[CInputIZena];
        Proz    : String[CLitr+1];
       VidNDS   : Word;{ ��� ������ 0=20% 1=10% 2=��祥}
        NDS     : String[CLitr];
     VidNalog   : Word;{ ��� ������ 0=5% 1=3% 2=��祥}
      SpecNalog : String[CLitr];
  DiviSionSNumber: 1..CDivision;
       Last     : Boolean;
     End;



Type BakProdagaElement = Record
     BazKod : String[CArtikul];
     Input  : BakInputMarketType;
     End;


Type BakSuperMarketType=Record
     OperatorSelector:Word; {������ ᪫��}
     DocSelector : Word;    {ᯨ᮪, ⮢ 祪, 䨧.���, �/�,�/� �, ����� � ���� ���죨 �� �� �ய��祭�}
     ShkalaNumer : Word;    {ᯨ᮪, ⮢ 祪, 䨧.���, �/�,�/� �, ����� � ���� ���죨 �� �� �ய��祭�}
     Realiz  : Boolean;     {�ਧ��� �� ⮢�� �� �뤠� �� ॠ������}
     Region  : Word;{��� ��த ������� १��}
     Bn : BezNal;
     SkidkaSelector : Word; {��� ᪨���}
     ClientKod : String[CMakeKod]; {��� ������}
     AgentKod  : String[CMakeKod]; {��� ������}
     MarketElement : Array[1..CMax] Of BakProdagaElement; {���ଠ�� � �த����� ⮢��}
     Document : String[CDocNumer]; {����� ���㬥��}
     DocumentPrz : String[CDocNumer];{����� ��᫥����� ��� ��८業��}
     PrhNumer: String[CDocNumer];{����� ��室����}
     SfNumer: String[CDocNumer];{����� �/�}
     NaklNumer: String[CDocNumer];{����� ���������}
     DateC   : TDateString; {��� ᮧ�����}
     TimeC   : TDateString; {�६� ᮧ�����}
     DateM   : TDateString; {��� ����䨪�樨}
     TimeM   : TDateString; {�६� ����䨪�樨}
     ENalog  : String[CIZena];
     Nalog5  : String[CIZena];
     Nalog3  : String[CIZena];
     Nalog_  : String[CIZena];
     SummaZ  : String[CIZena];  {�㬬� �� ���㬥��� � �����}
     Skidka  : String[CIZena];  {᪨��� �� ���㬥���}
SummaZakupka : String[CIZena];  {�㬬� ���㬥�� �� ���㯮�� 業���}
  SkladKod   : String[CClientKod];{�ਧ��� ᪫���}
     Caption : String [CRazdelKod];{�ਧ��� ������}
     Active  : Boolean;{�ਧ��� ��⨢���� ���������}
     Amount  : Word;   {�᫮ ⮢�஢ � ���㬥��}
     Locked  : Boolean;{�⥢�� �����஢��}
     Srok    : LongInt;{�ப ������ �����}
     DocReal : String[CDocNumer];{����� ���㬥�� �� ����� ���� �ய���,�ᯮ������ ⮫쪮 ���}
     DocDate : TDateString;      {���㬥�⮢ �뢮����� ��᫥ ������}
     End;

Type
    PBakSuperMarketType = ^BakSuperMarketPtr;
    BakSuperMarketPtr=Object(TObject)
    Dat  :  BakSuperMarketType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Constructor BAkSuperMarketPtr.Init ;
Var i : Byte;
Begin
TObject.Init;
 For i:=1 To CMax Do
  Begin
    Dat.MarketElement[i].BazKod[0]:=#0;
    With Dat.MarketElement[i].Input Do
   Begin
     Kol    [0] :=#0;
     Zena   [0] :=#0;
     R_Zena [0] :=#0;
     O_Zena [0] :=#0;
     Skidka [0] :=#0;
     Zakupka[0] :=#0;
     Itogo[0] :=#0;
     Proz[0] :=#0;
     VidNDS:=2;
     NDS[0] :=#0;
     SpecNalog[0] :=#0;
     VidNalog:=2;
     DivisionSNumber:=1;
     Last :=False;
   End;
  End;
   With Dat Do
    Begin
     Realiz:=False;
     DocumentPRZ[0]:=#0;
     Document[0]:=#0;
     ENalog  [0]:=#0;
     Nalog5  [0]:=#0;
     Nalog3  [0]:=#0;
     Nalog_  [0]:=#0;

     SummaZ[0]:=#0;
     SummaZakupka[0]:=#0;

     Skidka[0]:=#0;
     Bn.DAte[0]:=#0;
     Bn.NPlat[0]:=#0;
     Bn.Bank[0]:=#0;
     Bn.Summa[0]:=#0;
     Caption:=CurrentPassword;
     Active:=True;
     Realiz := False;
      Locked:=False;
     Srok:=0;
     Amount:=0;
     DateC[0]:=#0;
     TimeC[0]:=#0;
     DateM:=FDate;
     TimeM:=CurrentTimeString('hh:mm:ss');
     SkladKod:=FormKod(Rek.Kod);
     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     ClientKod[0]:=#0;
     ShkalaNumer :=0;
     DocReal[0]:=#0;
     DocDate[0]:=#0;
    End;
End;

Destructor BakSuperMarketPtr.Done;
Begin
TObject.Done;
End;



Var BakFile : File Of BakSuperMarketType;
    F :File Of SuperMarketType;
    BakPtr :PBakSuperMarketType;
    Ptr :PSuperMarketType;
    s1,s2:String;
    i : Word;

Begin
s1:=ParamStr(1);
Assign(BakFile,s1+'.mrk');
i:=IOResult;
Reset(BakFile);
i:=IOResult;
If I<>0 Then
 Begin
  Writeln('�� ���� ������ '+s1+'.mrk');
  Halt;
 End;

Assign(F,s1+'.new');
i:=IOResult;
Rewrite(F);
i:=IOResult;
If I<>0 Then
 Begin
  Close(BakFile);
  Writeln('�� ���� ᮧ���� '+s1+'.new');
  Halt;
 End;

New(BakPtr,Init);
New(Ptr,Init);

While Not(Eof(BakFile)) Do
 Begin
i:=IOResult;
  Read(BakFile,BakPtr^.Dat);
i:=IOResult;
If I<>0 Then
 Begin
  Writeln('�訡�� �⥭��'+s1+'.mrk');
 End;
  With Ptr^.Dat Do
   Begin
     OperatorSelector:=BakPtr^.Dat.OperatorSelector;
     DocSelector :=BakPtr^.Dat.DocSelector ;
     ShkalaNumer :=BakPtr^.Dat.ShkalaNumer ;
     Realiz  :=BakPtr^.Dat.Realiz  ;
     Bn :=BakPtr^.Dat.Bn ;
     SkidkaSelector :=BakPtr^.Dat.SkidkaSelector ;
     ClientKod :=BakPtr^.Dat.ClientKod ;
     AgentKod :=BakPtr^.Dat.AgentKod ;
     Region :=BakPtr^.Dat.Region ;

     PrhNumer[0]:=#0;
     SfNumer[0]:=#0;
     NaklNumer[0]:=#0;

     For i:=1 To CMax Do
      Begin
       With Ptr^.Dat.MarketElement[i] Do
        Begin
         BazKod:=BakPtr^.Dat.MarketElement[i].BazKod;
          With Ptr^.Dat.MarketElement[i].Input Do
           Begin
             Kol     :=BakPtr^.Dat.MarketElement[i].InPut.Kol;
             Zena    :=BakPtr^.Dat.MarketElement[i].InPut.Zena    ;
             R_Zena  :=BakPtr^.Dat.MarketElement[i].InPut.R_Zena  ;
             O_Zena  :=BakPtr^.Dat.MarketElement[i].InPut.O_Zena  ;
             Skidka  :=BakPtr^.Dat.MarketElement[i].InPut.Skidka  ;
             Itogo   :=BakPtr^.Dat.MarketElement[i].InPut.Itogo ;
             Zakupka :=BakPtr^.Dat.MarketElement[i].InPut.Zakupka;
             Proz    :=BakPtr^.Dat.MarketElement[i].InPut.Proz;
             NDS     :=BakPtr^.Dat.MarketElement[i].InPut.NDS;
             VidNds  :=BakPtr^.Dat.MarketElement[i].InPut.VidNDS;
             VidNalog:=BakPtr^.Dat.MarketElement[i].InPut.VidNalog;
             SpecNalog :=BakPtr^.Dat.MarketElement[i].InPut.SpecNAlog;
       DivisionSNumber:=BakPtr^.Dat.MarketElement[i].InPut.DivisionSNumber;
             Last     :=BakPtr^.Dat.MarketElement[i].InPut.Last;
             Osn.NaklNumer[0]:=#0;
             Osn.DateNakl[0]:=#0;
           End;
        End;
      End;

    Document :=BakPtr^.Dat.Document ;
 DocumentPrz :=BakPtr^.Dat.DocumentPrz ;
     DateC   :=BakPtr^.Dat.DateC   ;
     TimeC   :=BakPtr^.Dat.TimeC   ;
     DateM   :=BakPtr^.Dat.DateM   ;
     TimeM   :=BakPtr^.Dat.TimeM   ;
     ENalog  :=BakPtr^.Dat.ENAlog;
     Nalog5  :=BakPtr^.Dat.NAlog5;
     Nalog3  :=BakPtr^.Dat.NAlog3;
     Nalog_  :=BakPtr^.Dat.NAlog_;
     SummaZ  :=BakPtr^.Dat.SummaZ  ;
     Skidka  :=BakPtr^.Dat.Skidka  ;
SummaZakupka :=BakPtr^.Dat.SummaZakupka;
  SkladKod   :=BakPtr^.Dat.SkladKod;
     Caption :=BakPtr^.Dat.Caption ;
     Active  :=BakPtr^.Dat.Active  ;
     Amount  :=BakPtr^.Dat.Amount  ;
     Locked  :=BakPtr^.Dat.Locked  ;
     Srok    :=BakPtr^.Dat.Srok    ;
     DocReal :=BakPtr^.Dat.DocReal ;
     DocDate :=BakPtr^.Dat.DocDate ;
   End;
   seek(f,filesize(f));
   Write(f,ptr^.dat);
 End;
Dispose(BakPtr,Done);
Dispose(Ptr,Done);
Close(BakFile);
Close(f);
Rename(BakFile,s1+'.bak');
Rename(F,s1+'.mrk');
End.


