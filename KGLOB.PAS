{  ������� ᮮ�ࠦ����
   ��ॢ�� ���媮�� � db-䠩�, �.�. � InputType
1. ������ �� ������ ��ॢ�� ����� �� ����� ���㯮��� 業�
2. ���室 �� 4-�� ������ �ᮢ��
3. ���室 �� �஡��� ������⢮ ⮢�� (9 ᨬ�����)
4. ���室 � �����ᠬ 䠩��� �த��
5. ��ᬮ�� ���ᨩ �������
}

Unit KGlob;

Interface



{$I Compile.INC}


Uses Objects,ServStr,TpDate{,OWindows};

Const


{��ਠ��� �����}
{ DocPrint      =1;}
  DocEdit       =2;
  DocNormal     =0;
{����� ��ਠ�⮢ �����}

{ᯨ᮪ ࠧ�����, ����� ���� ������� � }
  NoSertif=85000;
  NoRegion=0;
  NoSertifStr='85000';
  NoRegionStr='0000';
  NoGroupStr='0000';
  NoControl =19610405;

{����⠭�� ���ਧ�樨}


{��ਠ��� ���� ���㬥��}
  DocPrihod      =0;
  DocPereozen    =1;
  DocReturn      =2;
  DocRewisia     =3;
  DocMarket      =4;
  DocOplata      =5;
  DocProtocol    =6;
DocProtocolReturn=7;
DocBarterOplata  =8;
   DocTransport  =9;
  DocOplataOtkat =10;
  DocZakaz       =11;

{����� ��ਠ�⮢ ���� ���㬥��}

 {�᫨ ����� ���� � 䨣���� ᪮���� �⮨� * � ��� 㦥 �ᯮ������}


Type InputMarketType=Record
        Kol     : String[CKol];
        Grammi  : String[CGram];
        Skidka  : String[CZena];
        Zena    : String[CZena];
        R_Zena  : String[CZena];
        O_Zena  : String[CZena];
        Zakupka : String[CZenaZ];
        Zakupka2: String[CZenaZ];
        Proz    : String[CLitr];
       VidNDS   : Word;{ ��� ������ 0=20% 1=10% 2=��祥}
        NDS     : String[CLitr];
     VidNalog   : Word;{ ��� ������ 0=5% 1=3% 2=��祥}
      SpecNalog : String[CLitr];
  DiviSionNumber: 1..CDivision;
       Last     : Boolean;
       NSertif  : ArtikulStr;
       SertifKol: String[CKol];{�ᯮ������ ⮫쪮 ��� ⮢��}
       NMAkeKod : ArtikulStr;{��� ���⠢騪� �த�樨}
     RegionMarka: Word;{0 - ���; 1- ��}
       AkzisSbor: String[CZenaZ];
       ZenaMarki: String[CZenaZ];
       Version  : Word;
      End;




Type ProdagaElement = Record
     BazKod : String[CArtikul];
     Input  : InputMarketType;
     End;




Type SuperMarketType=Record
     OperatorSelector : Word;{������ ᪫�� ����� �����}
     DocSelector      : Word;{ᯨ᮪, ⮢ 祪, 䨧.���, �/�,�/� �, ����� � ���� ���죨 �� �� �ய��祭�}
     Versia{ShkalaNumer}:Word;{�६���� �� �ᯮ������ ��� ᮢ���⨬��� � 㭨���ᠫ�� �ଠ⮬ ��� 䠩���}
     Realiz  : Boolean;     {�ਧ��� �� ⮢�� �� �뤠� �� ॠ������}
     Bn : BezNal;
     SkidkaSelector : Word; {��� ᪨���}
     {�����}
     ShkalaNumer: Word; {�६���� �� �ᯮ������ ��� ᮢ���⨬��� � 㭨���ᠫ�� �ଠ⮬ ��� 䠩���
	                    ����� ᪨��筮� 誠��}
     ClientKod : String[CMakeKod]; {��� ������}
     AgentKod  : String[CMakeKod]; {��� �����}
     {ExtElement   : Array[1..CMax] Of ExtMarket;}
     MarketElement   : Array[1..CMax] Of ProdagaElement; {���ଠ�� � �த����� ⮢��}
     DocumentElement : Array[1..CMAx] Of ProdagaElement; {���ଠ�� � �த����� ⮢��}
     Document : String[CDocNumer]; {����� ���㬥��}
     DocumentPrz : String[CDocNumer];{����� ��᫥����� ��� ��८業��}
     DocumentComment : Integer;
     DateC   : TDateString; {��� ᮧ�����}
     TimeC   : TDateString; {�६� ᮧ�����}
     DateM   : TDateString; {��� ����䨪�樨}
     TimeM   : TDateString; {�६� ����䨪�樨}

{    SENalog  : String[CIZena];
     SNalog5  : String[CIZena];
     SNalog3  : String[CIZena];
     SNalog_  : String[CIZena];}

  {⮫쪮 ��� ���䨪�⮢}
(* *)  SertifSummaZ: String[CIZena];
(* *) SertifSkidka: String[CIZena];
(* *)SertifSummaZakupka: String[CIZena];
(* *)SertifSummaZakupka2: String[CIZena];

     ENalog  : String[CIZena];
     Nalog5  : String[CIZena];
     Nalog3  : String[CIZena];
     Nalog_  : String[CIZena];

     SummaZ  : String[CIZena];  {�㬬� �� ���㬥��� � �����}
 SummaAkzis  : String[CIZena];  {�㬬� ����� �� ���㬥���}
     Skidka  : String[CIZena];  {᪨��� �� ���㬥���}
SummaZakupka : String[CIZena];  {�㬬� ���㬥�� �� ���㯮�� 業���}
SummaZakupka2: String[CIZena];  {�㬬� ���㬥�� �� ���㯮�� 業���}

     Otkat   : Double;{�⪠� ⮫쪮 � ���� � ⮫쪮 ��� ���ᨣ��樮���� ���㬥�⮢}

   SkladKod  : String[CClientKod];{�ਧ��� ᪫���}
     Caption : String [CRazdelKod];{�ਧ��� ������}
     Active  : Boolean;{�ਧ��� ��⨢���� ���������}
     Amount  : Word;   {�᫮ ⮢�஢ � ���㬥��}
(**) AmountS : Word;  {�᫮ ��⨨��⮢ � ���㬥��}
     Locked  : Boolean;{�⥢�� �����஢��}
     Srok    : LongInt;{�ப ������ �����}
     DocReal : String[CDocNumer];{����� ���㬥�� �� ����� ���� �ய���,�ᯮ������ ⮫쪮 ���}
     DocDate : LongInt{TDateString};{���㬥�⮢ �뢮����� ��᫥ ������}
     Rashet  : Word;{0-���/1-��/2-���ᥫ�}
   Oformlenie: Word;{0 ��� �ᯮ�������� �஭�; � �ᯮ�짮������ �஭�
                     �� ������ ����� ᬮ�� ���� FromZakaz}
    FromZakaz: ArtikulStr;{����� ��ଫ塞��� ������}
     Veksel  : VekselType;
     {PKO     : PKOType;}
     {Comment : AllStr;{�������਩ � ���������}
     End;



Type SuperMarketTypeIDX=Record
     OperatorSelector : Word; {������ ᪫�� ����� �����}
     DocSelector      : Word;    {ᯨ᮪, ⮢ 祪, 䨧.���, �/�,�/� �, ����� � ���� ���죨 �� �� �ய��祭�}
     Versia           : Word; {�६���� �� �ᯮ������ ��� ᮢ���⨬��� � 㭨���ᠫ�� �ଠ⮬ ��� 䠩���}
     Realiz           : Boolean;     {�ਧ��� �� ⮢�� �� �뤠� �� ॠ������}
     SkidkaSelector   : Word; {��� ᪨���}
     ShkalaNumer: Word; {�६���� �� �ᯮ������ ��� ᮢ���⨬��� � 㭨���ᠫ�� �ଠ⮬ ��� 䠩���
	                    ����� ᪨��筮� 誠��}
     ClientKod : String[CMakeKod]; {��� ������}
     AgentKod  : String[CMakeKod]; {��� �����}
     Document : String[CDocNumer]; {����� ���㬥��}
     DateC   : LongInt; {��� ᮧ�����}
     TimeC   : LongInt; {�६� ᮧ�����}
     DateM   : LongInt; {��� ����䨪�樨}
     TimeM   : LongInt; {�६� ����䨪�樨}
  {⮫쪮 ��� ���䨪�⮢}
(* *)  SertifSummaZ: Double;
(* *) SertifSkidka:  Double;
(* *)SertifSummaZakupka: Double;
(* *)SertifSummaZakupka2: Double;
     SummaZ  : Double;  {�㬬� �� ���㬥��� � �����}
 SummaAkzis  : Double;  {�㬬� �� ���㬥��� ����歮�� ᡮ�}
     Skidka  : Double;  {᪨��� �� ���㬥���}
SummaZakupka : Double;  {�㬬� ���㬥�� �� ���㯮�� 業���}
SummaZakupka2: Double;  {�㬬� ���㬥�� �� ���㯮�� 業���}
   SkladKod  : String[CClientKod];{�ਧ��� ᪫���}
     Caption : String [CRazdelKod];{�ਧ��� ������}
     Active  : Boolean;{�ਧ��� ��⨢���� ���������}
     Rashet  : Word;{0-���/1-��/2-���ᥫ�}
   Oformlenie: Word;{0 ��� �ᯮ�������� �஭�; � �ᯮ�짮������ �஭�
                     �� ������ ����� ᬮ�� ���� FromZakaz}
    FromZakaz: ArtikulStr;{����� ��ଫ塞��� ������}
     End;

Type
    PSuperMarketType = ^SuperMarketPtr;
    SuperMarketPtr=Object(TObject)
    Dat  :  SuperMarketType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Var
     {FileName: String;}
     FDate,TekDate :  TDateString;
     {Print : PrintIni;}
     EditPosition : LongInt;
     DateMask : TDateString;
     TimeMask : TDateString;

     PrihodMax,Lizensia : Real;
     Wzlom : Boolean;
     SkayScreen: Word;
     GlobalReadOnly:Word;
     EnableBron,Compress,Status,EditMode,
	ZakazShema : Word;
     CurrentPassword : String[CKto];
     ClientRP:String[CCLientKod];
     ZeniInZakaz : Word;
     InputZakaz : Word;{㪠�뢠�� �� ०�� ࠡ��� ���� �த��� (�த��� ��� �����)}
     AnsverGlobal,GlobalShow,ProdagaWindow,Show,ShowMsg,ShowMsgCopy,ShowNetMsg: Boolean;
     GlobalSkladsName: TMyString;
     GlobalOperatorNAme: AllStr;
     Interval,GlobalTime,GlobalTimeMsg,GlobalTimeMsg1 : LongInt;
     NetComputerNAme: AllStr;
     EnablePril,EnableSpravka: Set of Byte;
     AutoMarket : Word;
     DefaultSetMArker,EnableAutoSHK,EnableSHK,RemoteProtocol,
	EnableOtkat,RemoteAccess,PrihodFromClient,EnablePeremeshenie,FiktivSkidka,
     DisableCLose,DisableProtocol,EnableNewTovar,EnableHandZeni,EnableComplect,
     RegimOtsheta,
	EnableZakupka,EnablePosVersion,EnableOtdel: Word;
     YesMarker,NoMarker : String[CONe];





Implementation

 Constructor SuperMarketPtr.Init ;
Var i : Byte;
Begin
TObject.Init;
 For i:=1 To CMax Do
  Begin
    Dat.MarketElement[i].BazKod[0]:=#0;
    With Dat.MarketElement[i].Input Do
   Begin
     NSertif[0] :=#0;
     NMakeKod:='00000';
   SertifKol[0] :=#0;
     Kol    [0] :=#0;
    Grammi  [0] :=#0;

     Zena   [0] :=#0;
     R_Zena [0] :=#0;
     O_Zena [0] :=#0;
     Skidka [0] :=#0;
     Zakupka[0] :=#0;
     {Itogo  [0] :=#0;}
     Proz   [0] :=#0;
     VidNDS :=2;
     NDS    [0] :=#0;
     SpecNalog[0] :=#0;
     VidNalog:=2;
     DivisionNumber:=1;
     LAst :=FAlse;
     NSertif[0] :=#0;
   SertifKol[0] :=#0;
   RegionMarka:=0;
     AkzisSbor[0]:=#0;
     ZenaMarki[0]:=#0;
     Version:=1;
   End;

    Dat.DocumentElement[i].BazKod[0]:=#0;
    With Dat.DocumentElement[i].Input Do
   Begin
     NSertif[0] :=#0;
   SertifKol[0] :=#0;
     Kol    [0] :=#0;
     Zena   [0] :=#0;
     R_Zena [0] :=#0;
     O_Zena [0] :=#0;
     Skidka [0] :=#0;
     Zakupka[0] :=#0;
     {Itogo[0] :=#0;}
     Proz[0] :=#0;
     VidNDS:=2;
     NDS[0] :=#0;
     SpecNalog[0] :=#0;
     VidNalog:=2;
     DivisionNumber:=1;
     LAst :=FAlse;
   End;
  End;
   With Dat Do
    Begin
     Realiz:=False;
     DocumentPRZ[0]:=#0;
     Document[0]:=#0;
     DocumentComment:=0;
     ENalog  [0]:=#0;
     Nalog5  [0]:=#0;
     Nalog3  [0]:=#0;
     Nalog_  [0]:=#0;

     SummaAkzis[0]:=#0;
     SummaZ[0]:=#0;
     SummaZakupka[0]:=#0;
     SummaZakupka2[0]:=#0;
     Skidka[0]:=#0;

     SertifSummaZ[0]:=#0;
     SertifSummaZakupka[0]:=#0;
     SertifSummaZakupka2[0]:=#0;
     SertifSkidka[0]:=#0;
     Bn.DAte[0]:=#0;
     Bn.NPlat[0]:=#0;
     Bn.Bank[0]:=#0;
     Bn.Summa[0]:=#0;
     Caption:='00';
     Active:=True;
     Realiz := False;
      Locked:=False;
     Srok:=0;
     Otkat:=0.0000;
     Amount:=0;
     ShkalaNumer:=0;
     AmountS:=0;
     DateC[0]:=#0;
     TimeC[0]:=#0;
     DateM:=FDate;
     TimeM:=CurrentTimeString('hh:mm:ss');
{$IFNDEF Converter}
     SkladKod:='0001';
{$ENDIF}

     OperatorSelector:=0;
     DocSelector :=0;
     SkidkaSelector :=0;
     Versia :=1;
     ClientKod[0]:=#0;
     AgentKod[0]:=#0;
     DocReal[0]:=#0;
     DocDate:=DateStringToDate(DateMask,FDate);
     Rashet:=0;
     Oformlenie :=0;
     FromZakaz[0]:=#0;

     With Veksel Do
     Begin
      For i:=1 To MaxVeksel Do
       Begin
        Exampl[i].Seria:=SeriaConst;
        Exampl[i].Numer[0]:=#0;
        Exampl[i].Data [0]:=#0;
        Exampl[i].Summa[0]:=#0;
        Exampl[i].Proz :='0';
        Exampl[i].DogovorNumer[0]:=#0;
       End;{For}
     End;{With}
     {comment[0]:=#0;}
    End;{With}
End;




Destructor SuperMarketPtr.Done;
Begin
TObject.Done;
End;



End.