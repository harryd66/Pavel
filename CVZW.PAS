Uses Glob,servstr,objects,tpdate;

Type BakInputReturnType = Record
     Zena     : String[CZena];
     R_Zena   : String[CZena];
     O_Zena   : String[CZena];
  LocalSkidka : String[CZena];
    LocalProz : String[CLitr];
     Kol      : String[CKol];
     NDS      : String[CLitr];
    VidNalog  : Word;{ ��� ������ 0=5% 1=3% 2=��祥}
    SpecNalog : String[CLitr];
     Division : String[COne];
     End;


Type BakReturnElement = Record
     BazKod : String[CArtikul];
     Input  : BakInputReturnType;
     End;


Type
     BakVozwratType = Record
     OperatorSelector: Word;
     VidDocument    : Word;
{
0 - ����筠� �த��� ᪨��� ��⮬���᪠�
1 - ����筠� �த��� ᪨��� ��筠�
2 - ������� ���ᨣ���� �������᪠�
3 - ������� ���ᨣ���� ��筠�
4 - ������ ���ᨣ���� ��⮬���᪠�
5 - ������ ���ᨣ���� ��筠�
}
     DocSelector    : Word;
     {⨯ ���㬥�� �� ����� �����䨪�樨 �த���}
     MakeKod : String[CMakeKod];
     VozwratElement : Array[1..CMax] Of BakReturnElement;
     Document : String[CDocNumer];
     DocumentPrz : String[CDocNumer];
     SummaO,SummaR,Skidka : String[CIZena];
     PrevSummaZ,PrevSkidka:String[CIZena];

     ENalog  : String[CIZena];
     Nalog5  : String[CIZena];
     Nalog3  : String[CIZena];
     Nalog_  : String[CIZena];

     SkladKod: String[CClientKod];
     Caption : String[CRazdelKod];
     DateC   : TDateString;
     TimeC   : TDateString;
     DateM   : TDateString;
     TimeM   : TDateString;
     Amount  : Word;
   StatusDoc : Word; {1 : ����; 0 :���㬥�� ����� �� ᪫��}
     Locked  : Boolean;
    BasisDoc : String[CDocNumer];
    BasisDate: TDateString;
      Opt    : Boolean;
    Rashod   : Boolean;{�ਧ��� ���� ��室����}
  RashodSumma: String[CIZena];{����稭� �㬬� ��室����}

{�ਬ�砭��
4 ���� ������ (�� ��室�����)
1.������ �� �த��� - ��室��� �뤠���� �� �㬬� ������-�㬬� ᪨��� ������
2.������ �� �����⮩ ���ᨣ��� - ��室��� �뤠���� �� �㬬� ������-�㬬� ᪨��� ������
3.������ �� ����⮩ ���ᨣ��樨, ��祬 ���� �� ����� ���㬥��
  �ॢ�蠥� �㬬� ������ - ��室��� �� �뤠���� (�� ����砥��� �� �㫥��� �㬬�)
  � 䠩� ������ ���ᨣ��樨 � ���ᮭ���� 䠩� ������ ������ ������
  䨪⨢��� ����� ���ᨣ��樨    �� �㬬� ������

4.������ �� ����⮩ ���ᨣ��樨, ��祬 ���� �� ����� ���㬥��
  ����� �㬬� ������ - ��室��� �뤠���� �� �㬬� ࠢ���:

      ���室��� = �㬬� ������-�㬬� ����� �� ���㬥��� � ����饥 �६� }

 end;

Type
    PBakVozwratType = ^BakVozwratPtr;
    BakVozwratPtr=Object(TObject)
    Dat  :  BakVozwratType;
     Constructor Init;
     Destructor Done; Virtual;
 end;


Constructor BakVozwratPtr.Init ;
Var i,j : Byte;
Begin
TObject.Init;
With Dat Do
Begin
 BasisDoc[0]:=#0;
 BasisDate[0]:=#0;
 Opt:=False;
 Locked:=False;
 OperatorSelector:=0;
 VidDocument    :=0;
 MakeKod[0]:=#0;
 Document[0]:=#0;
 DocumentPrz[0]:=#0;
 Skidka[0]:=#0;
 SummaR[0]:=#0;
 SummaO[0]:=#0;
 PrevSummaZ[0]:=#0;
 PrevSkidka[0]:=#0;
 DateC[0]:=#0;
 TimeC[0]:=#0;
 DateM:=FDate;
 TimeM:=CurrentTimeString('hh:mm:ss');
 Caption:=CurrentPassword;
 SkladKod:=FormKod(Rek.Kod);
 Amount:=0;
 StatusDoc :=0;

 Rashod:=False;
 RashodSumma[0]:=#0;

End;
 For i:=1 To CMax Do
  Begin
  With Dat.VozwratElement[i] Do
   Begin
       Bazkod[0]:=#0;
       Input.Kol[0]:=#0;
       input.R_Zena[0]:=#0;
       input.Zena[0]:=#0;
       input.O_Zena[0]:=#0;
       Input.LocalSkidka[0]:=#0;
       Input.Division[0]:=#0;
   End;
  End;
End;

Destructor BakVozwratPtr.Done;
Begin
TObject.Done;
End;


Var BakFile : File Of BakVozwratType;
    F :File Of NewVozwratType;
    BakPtr :PBakVozwratType;
    Ptr :PNewVozwratType;
    s1,s2:String;
    i : Word;



Begin
s1:=ParamStr(1);
Assign(BakFile,s1+'.vzw');
i:=IOResult;
Reset(BakFile);
i:=IOResult;
If I<>0 Then
 Begin
  Writeln('�� ���� ������ '+s1+'.vzw');
  Halt;
 End;

Assign(F,s1+'.new');
i:=IOResult;
Rewrite(F);
i:=IOResult;
If I<>0 Then
 Begin
  Close(BakFile);
  Writeln('�� ���� ᮧ���� '+s1+'.new');
  Halt;
 End;

New(BakPtr,Init);
New(Ptr,Init);

While Not(Eof(BakFile)) Do
 Begin
  Read(BakFile,BakPtr^.Dat);
  With Ptr^.Dat Do
   Begin
     OperatorSelector:= BakPtr^.Dat.OperatorSelector;
     DocSelector:=BakPtr^.Dat.DocSelector;
     VidDocument:= BakPtr^.Dat.VidDocument;
     MakeKod :=BakPtr^.Dat.MakeKod;

     For i:=1 To CMax Do
      Begin
       With Ptr^.Dat.vozwratElement[i] Do
        Begin
         BazKod:=BakPtr^.Dat.vozwratElement[i].BazKod;
          With Ptr^.Dat.vozwratElement[i].Input Do
           Begin
             Kol     :=BakPtr^.Dat.vozwratElement[i].InPut.Kol;
             Zena    :=BakPtr^.Dat.vozwratElement[i].InPut.Zena    ;
             R_Zena  :=BakPtr^.Dat.vozwratElement[i].InPut.R_Zena  ;
             O_Zena  :=BakPtr^.Dat.vozwratElement[i].InPut.O_Zena  ;
             Zakupka[0]:=#0;
             LocalSkidka:=BakPtr^.Dat.vozwratElement[i].InPut.LocalSkidka;
             LocalProz    :=BakPtr^.Dat.vozwratElement[i].InPut.LocalProz;
             NDS:=BakPtr^.Dat.vozwratElement[i].InPut.NDS;
             VidNalog:=BakPtr^.Dat.vozwratElement[i].InPut.VidNalog;
             SpecNalog :=BakPtr^.Dat.vozwratElement[i].InPut.SpecNalog;
             Division:=BakPtr^.Dat.VozwratElement[i].InPut.Division;
           End;
        End;
      End;

     Document := BakPtr^.Dat.Document;
     DocumentPrz := BakPtr^.Dat.DocumentPrz;
     SummaZakupka[0]:=#0;
     Delta[0]:=#0;
     SummaO:= BakPtr^.Dat.SummaO;
	SummaR:= BakPtr^.Dat.SummaR;
	Skidka := BakPtr^.Dat.Skidka;
     ENalog:=BakPtr^.Dat.ENalog;
     Nalog5:=BakPtr^.Dat.Nalog5;
     Nalog3:=BakPtr^.Dat.Nalog3;
     Nalog_:=BakPtr^.Dat.Nalog_;
     PrevSummaZ :=BakPtr^.Dat.PrevSummaZ ;
	PrevSkidka:=BakPtr^.Dat.PrevSkidka ;
     SkladKod:=BakPtr^.Dat.SkladKod ;
     Caption :=BakPtr^.Dat.Caption ;
     DateC   :=BakPtr^.Dat.DateC ;
     TimeC   :=BakPtr^.Dat.TimeC ;
     DateM   :=BakPtr^.Dat.DateM ;
     TimeM   :=BakPtr^.Dat.TimeM ;
     Amount  :=BakPtr^.Dat.Amount ;
   StatusDoc :=BakPtr^.Dat.StatusDoc ; {1 : ����; 0 :���㬥�� ����� �� ᪫��}
     Locked  :=BakPtr^.Dat.Locked ;
    BasisDoc :=BakPtr^.Dat.BasisDoc ;
    BasisDate:=BakPtr^.Dat.BasisDate ;
      Opt    :=BakPtr^.Dat.Opt ;
    Rashod   :=BakPtr^.Dat.Rashod ;{�ਧ��� ���� ��室����}
  RashodSumma:=BakPtr^.Dat.RashodSumma ;{����稭� �㬬� ��室����}

   End;{With}
  seek(f,filesize(f));
  Write(f,ptr^.dat);
 End;

Dispose(BakPtr,Done);
Dispose(Ptr,Done);
Close(BakFile);
Close(f);

Rename(BakFile,s1+'.bak');
Rename(F,s1+'.vzw');
Writeln('All ok');

End.