const
      CMaxClZakaz=Cmax;


Type ClTovarType = record
       Kod  : string[CArtikul];  {���}
       Kol  : string[CKol];  {���-��}
       Zena : string[CZena];  {����}
       NadoSertif : boolean; {�ਧ��� ����室����� ���䨪��}
     end;

     {������}
Type ClZakazType = record
       Kod   : String[CCLientKod];
       Numer : word;    { �����  }
       Date  : longint;    { ���   }
       Tovar : array [1..CMaxClZakaz] of ClTovarType;
       Summa : string[CIZena];    { �㬬�  }
       DataOtpr : string[CDate]; { ��� ��ࠢ�� }
       Amount: word;   { ���-�� ����権 }
       Podpis: word;  {0 - �ନ஢���� 1 - �����ᠭ 2 - ��ࠢ��� 3 - 㤠���}
       sf: boolean;  {�ਧ��� �� }
       BN: boolean;  {�ਧ��� ������}
       Caption: string[CRazdelkod]; {������}
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
     Kod:=FormKod(Rek^.Dat.Kod);{�ਧ��� ᪫���}
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


