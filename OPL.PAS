Type OplataRealizasiaType = Record
    SkladKod : String[CClientKod];
   ClientKod :String[CClientKod];
    Document : String[CDocNumer]; {����� ���㬥��}
     DateDoc : TDateString; {��� ���㬥��}
     DateC   : TDateString; {��� ������}
     TimeC   : TDateString; {�६� ������}
     SummaZ  : String[CIZena];  {�㬬� ������}
     Skidka  : String[CIZena];  {����稭� ᯨᠭ�� ᪨���}
     Vozwrat : Boolean;      {�᫨ �� ������}
     DocNumerReturn: String[CDocNumer];{���㬥�� ������}
     DocDateReturn : STring[CDate];    {���㬥�� ������}
     Caption : String [CRazdelKod];{�ਧ��� ������}
     Rashet  : Word;
     Bn      : BezNal;
     Veksel  : VekselType;
     End;

