{$DEFINE Converter}

Uses Glob,ServStr,Utils;

Type OldBazType = Record
     Name  : String[CName];
     Name2 : String[CName];
     Litr  : String[CLitr];
     InPack: String[CInPack];
    InPack2: String[CInPack];
     OKP   : LongInt{String[COKP]};
     Massa : String[CMassa];
 BuchGroup : LongInt;
     Etil  : String[CLitr];
     Class : String[CClientKod];
     Market: Word;
EnableDebit: Word;  {разрешение консигнации}
     Prihod: Word;  {разрешение поставки в позицию}
     VidNalog : Word; { вид налога 0=5% 1=3% 2=прочее}
     Nalog    : String[CLitr];
     VidNDS   : Word; { вид НДС 0=20% 1=10% 2=прочее 3=18%}
     NDS      : String[CLitr];
     Mera     : String[CClientKod];
     EnableContract : Word;
     Contract : String[CContract];
 ContractDate : String[CDate];
 {!} Otdel : Word;{массив пока на 8 отделений}
     EnableSklads : LongInt;
 {!} Marker   : String[CLitrMantissa];
 {!} Min      : ArtikulStr;{процент минимальной наценки}
 {!} Recalc   : Word;{признак необходимости пересчета цены за единицу в примечании для Триады Продукт}
     PostKod  : String[CClientKod];
     FirmaPostKod  : String[CClientKod];
     NGroupKod: String[CClientKod];{Это поле указывает на код группы которой прин.товар}
     Main  : Word;{признак головная позиция или нет 0 - главная ; 1 - дочерняя}
     FantomKod: String[CArtikul];{код головной позиции в случае если текущая подчиненная}
     KSertif : String[CClientKod];
     DSertif : String[CDSertif];
     DVidan  : String[CDate];
     {вставить поле дата выдачи сертификаты для триады продукт
	дописать алгоритм печати в примечании цены за 1 кг}


     BazKod  : String[CArtikul];
     Employ: Boolean;
 {!} RCD   : Boolean;{ризнак репликации в SQL или еще куда товарной позиции}
     Caption: String[CRazdelKod];
     End;

var
    Old: OldBazType;
    New: BazType;
    OldF: file of OldBazType;
    NewF: file of BazType;
    IORez,i: word;
    l : LongInt;
    MMM : Maska30;
    M15 : Maska15;

BEGIN
  Assign(OldF,ParamStr(1)+'.id');
  Reset(OldF);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      writeln('Не могу открыть файл ',ParamStr(1));
      exit;
    end;

  Assign(NewF,ParamStr(2)+'.new');
  Rewrite(NewF);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      writeln('Не могу создать файл ',ParamStr(2));
      exit;
    end;

  while not eof(OldF)do
   begin
     IORez:=IOResult;
     Read(OldF,Old);
     IORez:=IOResult;

     If IORez<>0 Then
      Begin
       Writeln('Ошибка ',IORez:3);
	  Halt;
      End;

    With New do
     begin
       Name  :=OLd.Name;
       Name2 :=OLd.Name2;
       Litr  :=OLd.Litr;
       InPack:=OLd.InPack;
      InPack2:=Old.InPack2;
       OKP   :=Old.Okp;
       Massa :=Old.Massa;
       Market:=OLd.Market;
  EnableDebit:=Old.EnableDebit;
    VidNalog :=OLd.VidNalog;
    Nalog    :=OLd.Nalog;
    VidNDS   :=OLd.VidNDS;
    NDS      :=OLd.NDS;
    BuchGroup:=Old.BuchGroup;
     Etil:=Old.Etil;
     RCD:=Old.Rcd;
     Otdel:=Old.Otdel;
     Marker:=Old.Marker;
     Min:=Old.Min;
     Class:=Old.Class;
     Mera:=Old.Mera;
     EnableContract :=Old.EnableContract;
     Contract :=Old.Contract;
 ContractDate :=Old.ContractDate;
     KSertif :=Old.KSertif;
     DSertif :=Old.DSertif;
     BazKod:=OLd.BazKod;
     Employ:=OLd.Employ;
    Caption:=OLd.Caption;

     Prihod:=Old.Prihod;
     Recalc:=Old.Recalc;
     DVidan:=Old.DVidan;

     EnableSklads:=Old.EnableSklads;

     PostKod:=Old.PostKod;
     FirmaPostKod:=Old.FirmaPostKod;
     NGroupKod:=Old.NGroupKod;
     Main:=Old.Main;
     FantomKod:=Old.FantomKod;
     MetroKod[0]:=#0;

     end;
     write(NewF,New);
   end;

 IORez:=ioresult;
  Close(OldF);
 IORez:=ioresult;
  Close(NewF);
 IORez:=ioresult;

  Rename(OldF,ParamStr(1)+'.bid');
  Rename(NewF,ParamStr(1)+'.id');
  IORez:=ioresult;

 if IOREz=0 then Writeln('All Ok');

END.