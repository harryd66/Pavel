Type OplataRealizasiaType = Record
    SkladKod : String[CClientKod];
   ClientKod :String[CClientKod];
    Document : String[CDocNumer]; {номер документа}
     DateDoc : TDateString; {дата документа}
     DateC   : TDateString; {дата ОПЛАТЫ}
     TimeC   : TDateString; {время ОПЛАТЫ}
     SummaZ  : String[CIZena];  {сумма оплаты}
     Skidka  : String[CIZena];  {велечина списания скидки}
     Vozwrat : Boolean;      {если был возврат}
     DocNumerReturn: String[CDocNumer];{документ возврата}
     DocDateReturn : STring[CDate];    {документ возврата}
     Caption : String [CRazdelKod];{признак оператора}
     Rashet  : Word;
     Bn      : BezNal;
     Veksel  : VekselType;
     End;

