Uses Servstr, UKassa;

Type OLDKassaType = Record
                       SummaInKassa : String[CIZENA];
                     OstatokInKassa : String[CIZENA];
                              Sdano : String[CIZENA];
                      ExtendedDohod : String[CIZENA];
                             Rashod : String[CIZENA];
                           DohodAll : String[CIZENA];
                         DohodAgent : String[CIZENA];
                        DohodSertif : String[CIZENA];
                             Prihod : String[CIZena];{9}
                            Ostatok : String[CIZena];{10}
                                 RP : String[CIZena];{11}
                           SertifRP : String[CIZena];{11}
                      SummaOutSklad : String[CIZena];{12}
                            Prodagi : String[CIZena];{13}
                          SkProdagi : String[CIZena];{14}
                      SertifProdagi : String[CIZena];{13}
                    SertifSkProdagi : String[CIZena];{14}
                       VidanoConsig : String[CIZena];{15}
                     SkVidanoConsig : String[CIZENA];{16}
                      OplataINKassa : String[CIZENA];{17}
                     SkOformConsign : String[CIZENA];{18}
                ReturnOutOpenConsig : String[CIZENA];{19}
              SkReturnOutOpenConsig : String[CIZENA];{20}
   ReturnOutMArketDocAndCloseConsig : String[CIZENA];{21}
 SkReturnOutMArketDocAndCloseConsig : String[CIZENA];{22}
                      OstatokConsig : String[CIZENA];{23}
                    SkOstatokConsig : String[CIZENA];{24}
                         Pereozenka : String[CIZENA];{25}
               PereozenkaFromReturn : String[CIZENA];{26}
                   RashodFromReturn : String[CIZENA];{27}
         RashodFromReturnOpenConsig : String[CIZENA];{28}
                           VidanoSF : String[CIZENA];{29}
                            Rewisia : String[CIZENA];{30}
                            SNalogP : String[CIZENA];{31}
                            SNalogC : String[CIZENA];{32}
             SNalogReturnOpenConsig : String[CIZENA];{33}
                      OstatokBarter : String[CIZENA];{34}
                       BarterPrihod : String[CIZENA];{35}
                     BarterPrihodRZ : String[CIZENA];{36}
                            BarterT : String[CIZENA];{37}
                       BarterSkidki : String[CIZENA];{38}
                      SertifBarterT : String[CIZENA];{37}
                 SertifBarterSkidki : String[CIZENA];{38}
                      BarterInKassa : String[CIZENA];{39}
                     BarterOutKassa : String[CIZENA];{40}
                     BNOPlataConsig : String[CIZENA];{��������� ������ ���ᨣ��樨}
                          BNProdagi : String[CIZENA];{��������� ���ᨣ��樨 � �����}
                    BNBarterInKassa : String[CIZENA];{��������� ����㯫���� �� ������
                                                      ���� ��⠢��� ����� BarterInKassa}
                   BNBarterOutKassa : String[CIZENA];{��������� ��室� �� ������
                                                                  ���� ��⠢��� ����� BarterOutKassa}
                {=} OstatokPereplatN: String[CIZENA];{���⮪ ������� ��९���(�ᥣ�� ����� "0")}
                {=} OstatokPereplatB: String[CIZENA];{���⮪ ���������� ��९���(�ᥣ�� ����� "0")}
                {=} OstatokPereplatV: String[CIZENA];{���⮪ ���ᥫ��� ��९���(�ᥣ�� ����� "0")}
                    {+}NewPereplatN : String[CIZENA];{���� ����㯫���� ��९��� ������}
                    {+}NewPereplatB : String[CIZENA];{���� ����㯫���� ��९��� ���������}
                    {+}NewPereplatV : String[CIZENA];{���� ����㯫���� ��९��� �� ���ᥫ�}
                 {-}RashodPereplatN : String[CIZena];{ᯨᠭ�� ��९��� �������}
                 {-}RashodPereplatB : String[CIZena];{ᯨᠭ�� ��९��� ����������}
                 {-}RashodPereplatV : String[CIZena];{ᯨᠭ�� ��९��� ���ᥫ���}
{+}                   OstatokAkzis  : String[CIZena];{���⮪ �� ᪫��� ��樧�}
                      ProdagiCAkzis : String[CIZena];{��樧�� ᡮ� �� �������� ��� ����窨 �����⠬}
                      ProdagiSAkzis : String[CIZena];{��樧�� ᡮ� �� �������� ���᪫��᪨�}
                      ProdagiBAkzis : String[CIZena];{��樧�� ᡮ� �� �������� �����}
                  VidanoConsigAkzis : String[CIZena];{��樧�� ᡮ� �� ���ᨣ����}
               OformlenoConsigAkzis : String[CIZena];{��樧�� ᡮ� �� ���ᨣ����}
                      PrihodCAkzis  : String[CIZena];{��樧�� ᡮ� �� ��室�� �� ������}
                      PrihodSAkzis  : String[CIZena];{��樧�� ᡮ� �� ��室�� �� ᪫���}
                      PrihodBAkzis  : String[CIZena];{��樧�� ᡮ� �� ��室�� � �����}
                      ReturnCAkzis  : String[CIZena];{��樧�� ᡮ� �� ������� �� ������}
                      ReturnSAkzis  : String[CIZena];{��樧�� ᡮ� �� ������� �� ᪫���}
                      RevisiaAkZis  : String[CIZena];{��樧�� ᡮ� �� ॢ���� �� ᪫���}

   PerewoskiOut  : Array[1..15] Of String[CIZena];{�室�騥 ��ॢ����}{41-47}
   PerewoskiInp  : Array[1..15] Of String[CIZena];{��室�騥 ��ॢ����}{48-62}
   EPerewoskiOut : String[CIZENA];{63}
   EPerewoskiInp : String[CIZENA];{64}

                            ReportKassa: String[CIZena];
                            {���㯮�� 業�}
                            PrihodZC: String[CIZena];
                            PrihodZS: String[CIZena];
                            PrihodZB: String[CIZena];
                           OstatokZ : String[CIZena];
                     OstatokConsigZ : String[CIZena];
                           RewisiaZ : String[CIZENA];
                            ReturnZ : String[CIZENA];
                          MinusDohod: String[CIZENA];
                            AllDohod: String[CIZENA];
                           AllDohodA: String[CIZENA];
                           AllDohodB: String[CIZENA];
                           AllDohodS: String[CIZENA];
                          OtgruzkaZC: String[CIZENA];
                          OtgruzkaZS: String[CIZENA];
                          OtgruzkaZB: String[CIZENA];
                         OtgruzkaZRP: String[CIZENA];

                            {���㯮�� 業�2}
                            PrihodZC2: String[CIZena];
                            PrihodZS2: String[CIZena];
                            PrihodZB2: String[CIZena];
                           OstatokZ2 : String[CIZena];
                           RewisiaZ2 : String[CIZENA];
                            ReturnZ2 : String[CIZENA];
                          MinusDohod2: String[CIZENA];
                            AllDohod2: String[CIZENA];
                           AllDohodA2: String[CIZENA];
                           AllDohodB2: String[CIZENA];
                           AllDohodS2: String[CIZENA];
                          OtgruzkaZC2: String[CIZENA];
                          OtgruzkaZS2: String[CIZENA];
                          OtgruzkaZB2: String[CIZENA];
                         OtgruzkaZRP2: String[CIZENA];
                            OstatokAZ: String[CIZENA];
                           OstatokAZ2: String[CIZENA];
                            OstatokNZ: String[CIZENA];
                           OstatokNZ2: String[CIZENA];

{�ଯ��⭥�}
                               Otkat: String[CIZENA];{���⮪ �⪠�}
                            AddOtkat: String[CIZENA];{���������� ����� �⪠⮢}
                           KillOtkat: String[CIZENA];{��襭�� ����� �⪠⮢}
                      KillOtkatToDay: String[CIZENA];{��襭�� ����� �⪠⮢}
                        OtgruzkaWithOplataWithOutAkzis: String[CIZENA];{�� ������ 業��}

   PerewoskiOutZ  : Array[1..15] Of String[CIZena];{�室�騥 ��ॢ����}{41-47}
   PerewoskiInpZ  : Array[1..15] Of String[CIZena];{�室�騥 ��ॢ����}{41-47}
   PerewoskiOutZ2  : Array[1..15] Of String[CIZena];{�室�騥 ��ॢ����}{41-47}
   PerewoskiInpZ2  : Array[1..15] Of String[CIZena];{�室�騥 ��ॢ����}{41-47}

   Caption       : String[CRazdelKod];{65}
   DateC,TimeC,DateM,TimeM:TDateString;{66-69}
   End;




Var NewK: KassaType;
    Old : OldKassaType;
    FN: file of KassaType;
    FO: file of OldKassaType;
    FNameO : String;
    ws : AllStr;
    c,IORez : Word;
BEGIN
    FNameO:=ParamStr(1);

    Assign(FO,FNameO);
    IORez:= ioresult;
    Reset(fo);
    IORez:= ioresult;
    if IORez <> 0 then begin
       writeln('�� ���� ������ 䠩� '+FNameO);
       exit;
    end;

    read(FO,OLd);

    Close(FO);

    Rename(FO,ParamStr(2));

    Assign(FN,FNameO);
    IORez:= ioresult;
    Rewrite(fn);
    IORez:= ioresult;
    if IORez <> 0 then begin
       writeln('�� ���� ᮧ���� 䠩� '+FNameO);
       exit;
    end;

 with NewK do
  begin
                       ReportKassa  :=Old.ReportKassa;
                       SummaInKassa :=Old.SummaInKassa;
                     OstatokInKassa :=Old.OstatokInKassa;
                              Sdano :=Old.Sdano;
                      ExtendedDohod :=Old.ExtendedDohod;
                             Rashod :=Old.Rashod;
                           DohodAll :=Old.DohodAll;
                         DohodAgent :=Old.DohodAgent;
                        DohodSertif :=Old.DohodSertif;
                             Prihod :=Old.Prihod;
                            Ostatok :=Old.Ostatok;
                                 RP :=Old.RP;
                           SertifRP :=Old.SertifRP;
                      SummaOutSklad :=Old.SummaOutSklad;
                            Prodagi :=Old.Prodagi;
                          SkProdagi :=Old.SkProdagi;
                      SertifProdagi :=Old.SertifProdagi;
                    SertifSkProdagi :=Old.SertifSkProdagi;
                       VidanoConsig :=Old.VidanoConsig;
                     SkVidanoConsig :=Old.SkVidanoConsig;
                      OplataINKassa :=Old.OplataINKassa;
                     SkOformConsign :=Old.SkOformConsign;
                ReturnOutOpenConsig :=Old.ReturnOutOpenConsig;
              SkReturnOutOpenConsig :=Old.SkReturnOutOpenConsig;
   ReturnOutMArketDocAndCloseConsig :=Old.ReturnOutMArketDocAndCloseConsig;
 SkReturnOutMArketDocAndCloseConsig :=Old.SkReturnOutMArketDocAndCloseConsig;
                      OstatokConsig :=Old.OstatokConsig;
                    SkOstatokConsig :=Old.SkOstatokConsig;
                         Pereozenka :=Old.Pereozenka;
               PereozenkaFromReturn :=Old.PereozenkaFromReturn;
                   RashodFromReturn :=Old.RashodFromReturn;
         RashodFromReturnOpenConsig :=Old.RashodFromReturnOpenConsig;
                           VidanoSF :=Old.VidanoSF;
                            Rewisia :=Old.Rewisia;
                            SNalogP :=Old.SNalogP;
                            SNalogC :=Old.SNalogC;
             SNalogReturnOpenConsig :=Old.SNalogReturnOpenConsig;
                      OstatokBarter :=Old.OstatokBarter;
                       BarterPrihod :=Old.BarterPrihod;
                     BarterPrihodRZ :=Old.BarterPrihodRZ;
                            BarterT :=Old.BarterT;
                       BarterSkidki :=Old.BarterSkidki;
                      SertifBarterT :=Old.SertifBarterT;
                 SertifBarterSkidki :=Old.SertifBarterSkidki;
                      BarterInKassa :=Old.BarterInKassa;
                     BarterOutKassa :=Old.BarterOutKassa;
                     BNOPlataConsig :=Old.BNOPlataConsig;
                          BNProdagi :=Old.BNProdagi;
                    BNBarterInKassa :=Old.BNBarterInKassa;
                   BNBarterOutKassa :=Old.BNBarterOutKassa;
                {=} OstatokPereplatN:=Old.OstatokPereplatN;
                {=} OstatokPereplatB:=Old.OstatokPereplatB;
                {=} OstatokPereplatV:=Old.OstatokPereplatV;
                    {+}NewPereplatN :=Old.NewPereplatN;
                    {+}NewPereplatB :=Old.NewPereplatB;
                    {+}NewPereplatV :=Old.NewPereplatV;
                 {-}RashodPereplatN :=Old.RashodPereplatN;
                 {-}RashodPereplatB :=Old.RashodPereplatB;
                 {-}RashodPereplatV :=Old.RashodPereplatV;
{+}                   OstatokAkzis  :=Old.OstatokAkzis;
                      ProdagiCAkzis :=Old.ProdagiCAkzis;
                      ProdagiSAkzis :=Old.ProdagiSAkzis;
                      ProdagiBAkzis :=Old.ProdagiBAkzis;
                  VidanoConsigAkzis :=Old.VidanoConsigAkzis;
               OformlenoConsigAkzis :=Old.OformlenoConsigAkzis;
                      PrihodCAkzis  :=Old.PrihodCAkzis;
                      PrihodSAkzis  :=Old.PrihodSAkzis;
                      PrihodBAkzis  :=Old.PrihodBAkzis;
                      ReturnCAkzis  :=Old.ReturnCAkzis;
                      ReturnSAkzis  :=Old.ReturnSAkzis;
                      RevisiaAkZis  :=Old.RevisiaAkZis;
                      EPerewoskiOut :=Old.EPerewoskiOut;
                      EPerewoskiInp :=Old.EPerewoskiInp;

   For c:=1 To 15 Do
   Begin
   PerewoskiOut[c]  :=Old.PerewoskiOut[c];
   PerewoskiInp[c]  :=Old.PerewoskiInp[c];
   End;

   For c:=16 To 30 Do
   Begin
   PerewoskiOut[c,0]  :=#0;
   PerewoskiInp[c,0]  :=#0;
   End;

                            {���㯮�� 業�}
                            PrihodZC:=Old.PrihodZC;
                            PrihodZS:=Old.PrihodZS;
                            PrihodZB:=Old.PrihodZB;
                           OstatokZ :=Old.OstatokZ;
                     OstatokConsigZ :=Old.OstatokConsigZ;
                           RewisiaZ :=Old.RewisiaZ;
                            ReturnZ :=Old.ReturnZ;
                          MinusDohod:=Old.MinusDohod;
                            AllDohod:=Old.AllDohod;
                           AllDohodA:=Old.AllDohodA;
                           AllDohodB:=Old.AllDohodB;
                           AllDohodS:=Old.AllDohodS;
                          OtgruzkaZC:=Old.OtgruzkaZC;
                          OtgruzkaZS:=Old.OtgruzkaZS;
                          OtgruzkaZB:=Old.OtgruzkaZB;
                         OtgruzkaZRP:=Old.OtgruzkaZRP;

                            {���㯮�� 業�2}
                            PrihodZC2:=Old.PrihodZC2;
                            PrihodZS2:=Old.PrihodZS2;
                            PrihodZB2:=Old.PrihodZB2;
                           OstatokZ2 :=Old.OstatokZ2;
                           RewisiaZ2 :=Old.RewisiaZ2;
                            ReturnZ2 :=Old.ReturnZ2;
                          MinusDohod2:=Old.MinusDohod2;
                            AllDohod2:=Old.AllDohod2;
                           AllDohodA2:=Old.AllDohodA2;
                           AllDohodB2:=Old.AllDohodB2;
                           AllDohodS2:=Old.AllDohodS2;
                          OtgruzkaZC2:=Old.OtgruzkaZC2;
                          OtgruzkaZS2:=Old.OtgruzkaZS2;
                          OtgruzkaZB2:=Old.OtgruzkaZB2;
                         OtgruzkaZRP2:=Old.OtgruzkaZRP2;
                            OstatokAZ:=Old.OstatokAZ;
                           OstatokAZ2:=Old.OstatokAZ2;
                            OstatokNZ:=Old.OstatokNZ;
                           OstatokNZ2:=Old.OstatokNZ2;
                                Otkat:=Old.Otkat;
                             AddOtkat:=Old.AddOtkat;
                            KillOtkat:=Old.KillOtkat;
                       KillOtkatToDay:=Old.KillOtkatToDay;
       OtgruzkaWithOplataWithOutAkzis:=Old.OtgruzkaWithOplataWithOutAkzis;


   For c:=1 To 15 Do
   Begin
   PerewoskiOutZ[c]  :=Old.PerewoskiOutZ[c];
   PerewoskiInpZ[c]  :=Old.PerewoskiInpZ[c];
   PerewoskiOutZ2[c]  :=Old.PerewoskiOutZ2[c];
   PerewoskiInpZ2[c]  :=Old.PerewoskiInpZ2[c];
   End;

   For c:=16 To 30 Do
   Begin
   PerewoskiOutZ[c,0]  :=#0;
   PerewoskiInpZ[c,0]  :=#0;
   PerewoskiOutZ2[c,0]  :=#0;
   PerewoskiInpZ2[c,0]  :=#0;
   End;

                    {
                    PerewoskiOutZ   :=Old.PerewoskiOutZ;
                    PerewoskiInpZ   :=Old.PerewoskiInpZ;
                    PerewoskiOutZ2  :=Old.PerewoskiOutZ2;
                    PerewoskiInpZ2  :=Old.PerewoskiInpZ2;
                    }
                    Caption         :=Old.Caption;
                    DateC           :=Old.DateC ;
                    TimeC           :=Old.TimeC;
                    DateM           :=Old.DateM;
                    TimeM           :=Old.TimeM;
       end;

 Seek(FN,0);
 IORez:= ioresult;
 write(FN,NewK);

 Close(FN);

 IORez:= ioresult;
 if IOREz=0 then writeln('all ok')
  else writeln(IORez);

END.
