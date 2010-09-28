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
     PostKod  : String[CClientKod];
     FirmaPostKod  : String[CClientKod];
     NGroupKod: String[CClientKod];{Это поле указывает на код группы которой прин.товар}
     Main  : Word;{признак головная позиция или нет 0 - главная ; 1 - дочерняя}
     FantomKod: String[CArtikul];{код головной позиции в случае если текущая подчиненная}
     KSertif : String[CClientKod];
     DSertif : String[CDSertif];
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
    txt : Text;

BEGIN
  Assign(OldF,ParamStr(1)+'.id');
  Reset(OldF);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      writeln('Не могу открыть файл ',ParamStr(1));
      exit;
    end;

  Assign(txt,'lll.txt');
  Append(txt);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      Rewrite(txt);
      writeln('Не могу создать файл lll.txt');
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

     If Old.Employ Then

     If Old.Main=1 Then
      Begin
       Writeln(txt,Old.BazKod+' '+Old.FantomKod);
      End;

   end;

 IORez:=ioresult;
  Close(OldF);
 IORez:=ioresult;
  Close(txt);
 IORez:=ioresult;

 if IOREz=0 then Writeln('All Ok');
END.