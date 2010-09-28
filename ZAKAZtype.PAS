const
      CMaxClZakaz=Cmax;


Type ClTovarType = record
       Kod  : string[CArtikul];  {Код}
       Kol  : string[CKol];  {Кол-во}
       Zena : string[CZena];  {Цена}
       NadoSertif : boolean; {признак необходимости сертификата}
     end;

     {Заказы}
Type ClZakazType = record
       Kod   : String[CCLientKod];
       Numer : word;    { Номер  }
       Date  : longint;    { Дата   }
       Tovar : array [1..CMaxClZakaz] of ClTovarType;
       Summa : string[CIZena];    { Сумма  }
       DataOtpr : string[CDate]; { Дата отправки }
       Amount: word;   { Кол-во позиций }
       Podpis: word;  {0 - формирование 1 - подписан 2 - отправлен 3 - удален}
       sf: boolean;  {признак СФ }
       BN: boolean;  {признак безнал}
       Caption: string[CRazdelkod]; {оператор}
     end;


Type PClZakazType = ^TClZakazType;
     TClZakazType = Object(TObject)
     Dat: ClZakazType;
     constructor Init;
     destructor Done; virtual;
   end;


constructor TClZakazType.Init;
var i:word;
Begin
 inherited init;
 with Dat do
 begin
   Numer :=0;
   Date  :=0;
{$IFNDEF Converter}
     Kod:=FormKod(Rek^.Dat.Kod);{признак склада}
{$ELSE}
     Kod[0]:=#0;
{$ENDIF}


   for i:=1 to CMaxClZakaz do
 Begin
  with Dat[i] do
  begin
   Kod[0]:=#0;
   Kol[0]:=#0;
   Zena[0]:=#0;
   NadoSertif:= false;
  end;
 End;
   Summa[0] :=#0;
   DataOtpr :=FDate;
   Amount:=0;
   Podpis:=0;
   sf:=false;
   Caption:=CurrentPassword;
 end;
End;


destructor TClZakazType.Done;
Begin;
 inherited Done;
End;


