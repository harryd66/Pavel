Type ZakazType=Record
     OperatorSelector : Word; {������ ᪫�� ����� �����}
     DocSelector      : Word;    {ᯨ᮪, ⮢ 祪, 䨧.���, �/�,�/� �, ����� � ���� ���죨 �� �� �ய��祭�}
     Versia : Word;
	ShkalaNumer: Word; {�६���� �� �ᯮ������ ��� ᮢ���⨬��� � 㭨���ᠫ�� �ଠ⮬ ��� 䠩���}
     SkidkaSelector : Word; {��� ᪨���}
     ClientKod : String[CMakeKod]; {��� ������}
     AgentKod        : String[CMakeKod]; {��� �����}
     EkspeditorKod  : String[CMakeKod]; {��� �����}
     MarketElement   : Array[1..CMax] Of ZakazElementType; {���ଠ�� � �த����� ⮢��}
     DocumentElement : Array[1..CMAx] Of ZakazElementType; {���ଠ�� � �த����� ⮢��}
{!!!}ElementP: array[1..CMax] of PredZakazElement;  {� ������ 䠪��᪨ ���⢥ত���� ����⨬��� � ������⢮}
     Document : ArtikulStr; {����� ���㬥��}
     DocumentComment{ClientNumer} : Integer;
     DateC   : TDateString; {��� ᮧ�����}
     TimeC   : TDateString; {�६� ᮧ�����}
     DateM   : TDateString; {��� ����䨪�樨}
     TimeM   : TDateString; {�६� ����䨪�樨}

{!!!}     AmountP: word;

  {⮫쪮 ��� ���䨪�⮢}
(* *)  SertifSummaZ: String[CIZena];
(* *) SertifSkidka: String[CIZena];
     SummaZ  : String[CIZena];  {�㬬� �� ���㬥��� � �����}
     Skidka  : String[CIZena];  {᪨��� �� ���㬥���}

   SkladKod  : String[CClientKod];{�ਧ��� ᪫���}
     Caption : String [CRazdelKod];{�ਧ��� ������}
     Amount  : Word;   {�᫮ ⮢�஢ � ���㬥��}
(**) AmountS  : Word;  {�᫮ ��⨨��⮢ � ���㬥��}
     Locked  : Boolean;{�⥢�� �����஢��}
LockCaption  : String[CRazdelKod];
LockTime     : LongInt;
ComputerNameLocked : String[CCNAme];
     Srok    : LongInt;{�ப ������ �����}
     EndDate : LongInt;{�ப �஭� - ������⢮ ���� �⢮����� �� ���⠢��}
     DocReal : String[CDocNumer];{����� ���㬥�� �� ����� ���� �ய���,�ᯮ������ ⮫쪮 ���}
     DocDate{DateOtpr} : TDateString;{���㬥�⮢ �뢮����� ��᫥ ������}
     Rashet  : Word;{0-���/1-��/2-���ᥫ�}
     Oformlenie : Word;{�ਧ��� ��ଫ���� ������ ��� ���� � �஭� �� �६���}

     Status  : Word;{0-�⠭���⭠� �奬� १�ࢨ஢����;
                     1-�奬� १�ࢨ஢���� �१ 㤠����� �����}

     PredZakazNumer : LongInt;{�� ���� �।�������}
     PredZakazDate  : LongInt;
     PredZakazClient: String[CCLientKod];
     End;
