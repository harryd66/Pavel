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
     PostKod  : String[CClientKod];
     FirmaPostKod  : String[CClientKod];
     NGroupKod: String[CClientKod];{�� ���� 㪠�뢠�� �� ��� ��㯯� ���ன �ਭ.⮢��}
     Main  : Word;{�ਧ��� �������� ������ ��� ��� 0 - ������� ; 1 - ������}
     FantomKod: String[CArtikul];{��� �������� ����樨 � ��砥 �᫨ ⥪��� ���稭�����}
     KSertif : String[CClientKod];
     DSertif : String[CDSertif];
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
    txt : Text;

BEGIN
  Assign(OldF,ParamStr(1)+'.id');
  Reset(OldF);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      writeln('�� ���� ������ 䠩� ',ParamStr(1));
      exit;
    end;

  Assign(txt,'lll.txt');
  Append(txt);
  IORez:=IOResult;
  if IORez <> 0 then
    begin
      Rewrite(txt);
      writeln('�� ���� ᮧ���� 䠩� lll.txt');
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