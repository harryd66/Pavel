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
EnableDebit: Word;  {ࠧ�襭�� ���ᨣ��樨}
     Prihod: Word;  {ࠧ�襭�� ���⠢�� � ������}
     VidNalog : Word; { ��� ������ 0=5% 1=3% 2=��祥}
     Nalog    : String[CLitr];
     VidNDS   : Word; { ��� ��� 0=20% 1=10% 2=��祥 3=18%}
     NDS      : String[CLitr];
     Mera     : String[CClientKod];
     EnableContract : Word;
     Contract : String[CContract];
 ContractDate : String[CDate];
 {!} Otdel : Word;{���ᨢ ���� �� 8 �⤥�����}
     EnableSklads : LongInt;
 {!} Marker   : String[CLitrMantissa];
 {!} Min      : ArtikulStr;{��業� �������쭮� ��業��}
 {!} Recalc   : Word;{�ਧ��� ����室����� ������ 業� �� ������� � �ਬ�砭�� ��� �ਠ�� �த��}
     PostKod  : String[CClientKod];
     FirmaPostKod  : String[CClientKod];
     NGroupKod: String[CClientKod];{�� ���� 㪠�뢠�� �� ��� ��㯯� ���ன �ਭ.⮢��}
     Main  : Word;{�ਧ��� �������� ������ ��� ��� 0 - ������� ; 1 - ������}
     FantomKod: String[CArtikul];{��� �������� ����樨 � ��砥 �᫨ ⥪��� ���稭�����}
     KSertif : String[CClientKod];
     DSertif : String[CDSertif];
     DVidan  : String[CDate];
     {��⠢��� ���� ��� �뤠� ���䨪��� ��� �ਠ�� �த��
	������� ������ ���� � �ਬ�砭�� 業� �� 1 ��}


     BazKod  : String[CArtikul];
     Employ: Boolean;
 {!} RCD   : Boolean;{ਧ��� ९����樨 � SQL ��� �� �㤠 ⮢�୮� ����樨}
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
      writeln('�� ���� ������ 䠩� ',ParamStr(1));
      exit;
    end;

  Assign(NewF,ParamStr(2)+'.new');
  Rewrite(NewF);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      writeln('�� ���� ᮧ���� 䠩� ',ParamStr(2));
      exit;
    end;

  while not eof(OldF)do
   begin
     IORez:=IOResult;
     Read(OldF,Old);
     IORez:=IOResult;

     If IORez<>0 Then
      Begin
       Writeln('�訡�� ',IORez:3);
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