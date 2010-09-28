
Uses Glob,Utils5,Utils,Nastr,ServStr, TPDate;

Type BazType = Record
     Name  : String[CName];
     Name2 : String[CName];
     Litr  : String[CLitr];
     InPack: String[CInPack];
    InPack2: String[CInPack];
     OKP   : LongInt{String[COKP]};
     Massa : String[CMassa];
 BuchGroup : LongInt;
     Etil  : String[CLitr];
     Market: Word;
   EnableDebit: Word;  {разрешение консигнации}
     VidNalog : Word; { вид налога 0=5% 1=3% 2=прочее}
     Nalog    : String[CLitr];
     VidNDS   : Word; { вид НДС 0=20% 1=10% 2=прочее}
     NDS      : String[CLitr];
     Mera     : String[CMera];
     EnableContract : Word;
     Contract : String[CContract];
 ContractDate : String[CDate];
     EnableSklads : Word;
     {Slave : Word; {поле от 16-05-02 0-главная или 1-подчиненная позиция}
     {SlaveKod : Longint;}
     KSertif : String[CKSertif];
     DSertif : String[CDSertif];
     BazKod  : String[CArtikul];
     Employ: Boolean;
    Caption: String[CRazdelKod];
LockCaption: String[CRazdelKod];
ComputerNameLocked : String[CCNAme];
     Locked: Boolean;
     End;


var
    Baz : BazType;
    Skl : SkladType;
    KDX : SkladTypeNew;
    OldF: file of BazType;
    FSkl : File Of SkladType;
    FKDX : File Of SkladTypeNew;
    IORez,i: word;
    Txt : Text;

BEGIN

  If FindParam('/ONLY2004') Then
  if Today <= DateStringToDate('dd-mm-yy','31-12-03') then
   begin
    exit;
   end;


  IORez:=IOResult;
  Assign(OldF,ParamStr(1)+'.id');
  Reset(OldF);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      writeln('Не могу открыть файл ',ParamStr(1)+'.id');
      exit;
    end;


  Assign(FSkl,ParamStr(2)+'.db');
  Reset(FSkl);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      close(OldF);
      writeln('Не могу открыть файл ',ParamStr(2)+'.db');
      exit;
    end;


  Assign(FKDX,ParamStr(3)+'.db');
  Reset(FSkl);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      IORez:=IOResult;
      close(OldF);
      IORez:=IOResult;
      close(FSkl);
      IORez:=IOResult;
      writeln('Не могу открыть файл ',ParamStr(3)+'.db');
      exit;
    end;

  IORez:=IOResult;

  while not eof(OldF)do
   begin
     IORez:=IOResult;
     Read(OldF,Baz);
     IORez:=IOResult;
     If IORez<>0 Then
      Begin
       Writeln('Ошибка ',IORez:3);
	  Halt;
      End;

     if Baz.employ then
     begin

       if Baz.VidNds=0 then
        begin
         Baz.VidNds:=3;
         Baz.Nds:='18.00';
         {пересчет закупок для бухгалтерии}
         Seek(FSkl,StrToInt(Copy(Baz.BazKOd,3,3)));
         Read(FSkl,Skl);

         MyStr(StrToReal(Skl.Input.Zakupka)/1.2*1.18,CZenaZ,CMantissaZ,Skl.Input.Zakupka);
         DelSpace(Skl.Input.Zakupka);

         MyStr(StrToReal(Skl.Input.Zakupka2)/1.2*1.18,CZenaZ,CMantissaZ,Skl.Input.Zakupka2);
         DelSpace(Skl.Input.Zakupka2);


         Seek(FSkl,FilePos(FSkl)-1);
         Write(FSkl,Skl);

         Seek(FKDX,StrToInt(Copy(Baz.BazKOd,3,3)));
         Read(FKDX,KDX);

         KDX.Zakupka :=KDX.Zakupka/1.2*1.18;
         KDX.Zakupka2:=KDX.Zakupka2/1.2*1.18;

         Seek(FKDX,FilePos(FKDX)-1);
         Write(FKDX,KDX);

        end;

       Baz.VidNalog:=2;
       Baz.Nalog:='0.00';
     end;

     seek(OldF,FilePos(OldF)-1);
     write(OldF,Baz);

   end;

 IORez:=ioresult;
  Close(OldF);
 IORez:=ioresult;

 IORez:=ioresult;
  Close(FSKL);
 IORez:=ioresult;

 IORez:=ioresult;
  Close(FKDX);
 IORez:=ioresult;


 {if IOREz=0 then Writeln('All Ok');}
END.