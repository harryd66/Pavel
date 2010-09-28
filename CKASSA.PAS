Uses Glob,Objects,Serv,ServStr,TpDate;


Type BakKassaType = Record
{1}                              Prihod : String[CIZena];
{2}                             Ostatok : String[CIZena];
{3}                                  RP : String[CIZena];
{4}                       SummaOutSklad : String[CIZena];
{43}                            Prodagi : String[CIZena];
{43}                          SkProdagi : String[CIZena];
{5}                        VidanoConsig : String[CIZena];
{6}                      SkVidanoConsig : String[CIZENA];
{7}                       OplataINKassa : String[CIZENA];
{8}                      SkOformConsign : String[CIZENA];
{9}                 ReturnOutOpenConsig : String[CIZENA];
{10}              SkReturnOutOpenConsig : String[CIZENA];
{11}   ReturnOutMArketDocAndCloseConsig : String[CIZENA];
{12} SkReturnOutMArketDocAndCloseConsig : String[CIZENA];
{13}                      OstatokConsig : String[CIZENA];
{14}                    SkOstatokConsig : String[CIZENA];
{15}                         Pereozenka : String[CIZENA];
{16}               PereozenkaFromReturn : String[CIZENA];
{17}                       SummaInKassa : String[CIZENA];
{18}                     OstatokInKassa : String[CIZENA];
{19}                      ExtendedDohod : String[CIZENA];
{20}                   RashodFromReturn : String[CIZENA];
{21}         RashodFromReturnOpenConsig : String[CIZENA];
{21}                             Rashod : String[CIZENA];
{23}                         Sertifikat : String[CIZENA];
{24}                              Sdano : String[CIZENA];
{25}                           VidanoSF : String[CIZENA];
{26}                            Rewisia : String[CIZENA];
{27}                            SNalogP : String[CIZENA];
{28}                            SNalogC : String[CIZENA];
{29}             SNalogReturnOpenConsig : String[CIZENA];
{30,31,32,33,34,35,36}

   PerewoskiOut : Array[0..6] Of String[CIZena];{входящие перевозки}
{37,38,39,40,41,42}
   PerewoskiInp : Array[0..6] Of String[CIZena];{исходящие перевозки}
{Эти поля не фигурируют на экране}

   EPerewoskiOut : String[CIZENA];
   EPerewoskiInp : String[CIZENA];


   CAption       : String[CRazdelKod];
   DAteC,TimeC,DateM,TimeM:TDateString;
   End;

Type
    PBakKassaType = ^BakKassaPtr;
    BakKassaPtr=Object(TObject)
    Dat  :  BakKassaType;
     Constructor Init;
     Procedure FormatReal;
     Destructor Done; Virtual;
 end;


Constructor BakKassaPtr.Init ;
Var i : Byte;
Begin
TObject.Init;
With DAt Do
Begin
{1}                              Prihod[0] :=#0;
{2}                             Ostatok[0] :=#0;
{3}                                  RP[0] :=#0;
{4}                       SummaOutSklad[0] :=#0;
{43}                            Prodagi[0] :=#0;
{44}                          SkProdagi[0] :=#0;
{5}                        VidanoConsig[0] :=#0;
{6}                      SkVidanoConsig[0] :=#0;
{7}                       OplataINKassa[0] :=#0;
{8}                      SkOformConsign[0] :=#0;
{9}                 ReturnOutOpenConsig[0] :=#0;
{10}              SkReturnOutOpenConsig[0] :=#0;
{11}   ReturnOutMArketDocAndCloseConsig[0] :=#0;
{12} SkReturnOutMArketDocAndCloseConsig[0] :=#0;
{13}                      OstatokConsig[0] :=#0;
{14}                    SkOstatokConsig[0] :=#0;
{15}                         Pereozenka[0] :=#0;
{16}               PereozenkaFromReturn[0] :=#0;
{17}                       SummaInKassa[0] :=#0;
{18}                     OstatokInKassa[0] :=#0;
{19}                      ExtendedDohod[0] :=#0;
{20}                   RashodFromReturn[0] :=#0;
{21}         RashodFromReturnOpenConsig[0] :=#0;
{21}                             Rashod[0] :=#0;
{23}                         Sertifikat[0] :=#0;
{24}                              Sdano[0] :=#0;
{25}                           VidanoSF[0] :=#0;
{26}                            Rewisia[0] :=#0;
{27}                            SNalogP[0] :=#0;
{28}                            SNalogC[0] :=#0;
{29}             SNalogReturnOpenConsig[0] :=#0;



{44}   EPerewoskiOut[0] :=#0;
{45}   EPerewoskiInp[0] :=#0;

For i:=0 To 6 Do
Begin
{29,30,31,32,33,34,35}
 PerewoskiInp[i,0]:=#0;
{36,37,38,39,40,41,42}
 PerewoskiOut[i,0]:=#0;
End;{For}
 CAption:=CurrentPassword;
 DAteC:=FDate;
 TimeC:=CurrentTimeString('hh:mm:ss');
 DAteM:=DateC;
 TimeM:=TimeC;
End;{With}
End;

Procedure BakKassaPtr.FormatReal;
Var i : Byte;
Begin
With DAt Do
Begin
{1}Str(StrToReal(Prihod):CIZena:CMantissa,Prihod);
{2}Str(StrToReal(Ostatok):CIZena:CMantissa,Ostatok);
{3}Str(StrToReal(RP):CIZena:CMantissa,RP);
{4}Str(StrToReal(SummaOutSklad):CIZena:CMantissa,SummaOutSklad);
{43}Str(StrToReal(Prodagi):CIZena:CMantissa,Prodagi);
{44}Str(StrToReal(SkProdagi):CIZena:CMantissa,SkProdagi);
{5}Str(StrToReal(VidanoConsig):CIZena:CMantissa,VidanoConsig);
{6}Str(StrToReal(SkVidanoConsig):CIZena:CMantissa,SkVidanoConsig);
{7}Str(StrToReal(OplataInKAssa):CIZena:CMantissa,OplataInKAssa);
{8}Str(StrToReal(SkOformConsign):CIZena:CMantissa,SkOformConsign);

{9}Str(StrToReal(ReturnOutOpenConsig):CIZena:CMantissa,ReturnOutOpenConsig);
{10}Str(StrToReal(SkReturnOutOpenConsig):CIZena:CMantissa,SkReturnOutOpenConsig);


{11}Str(StrToReal(ReturnOutMArketDocAndCloseConsig):CIZena:CMantissa,ReturnOutMArketDocAndCloseConsig);
{12}Str(StrToReal(SkReturnOutMArketDocAndCloseConsig):CIZena:CMantissa,SkReturnOutMArketDocAndCloseConsig);
{13}Str(StrToReal(OstatokConsig):CIZena:CMantissa,OstatokConsig);
{14}Str(StrToReal(SkOstatokConsig):CIZena:CMantissa,SkOstatokConsig);
{15}Str(StrToReal(Pereozenka):CIZena:CMAntissa,Pereozenka);
{16}Str(StrToReal(PereozenkaFromReturn):CIZena:CMAntissa,PereozenkaFromReturn);
{17}Str(StrToReal(SummaInKassa):CIZena:CMantissa,SummaInKassa);
{18}Str(StrToReal(OstatokInKAssa):CIZena:CMantissa,OstatokInKassa);
{19}Str(StrToReal(ExtendedDohod):CIZena:CMAntissa,ExtendedDohod);
{20}Str(StrToReal(RashodFromReturn):CIZena:CMAntissa,RashodFromReturn);
{20}Str(StrToReal(RashodFromReturnOpenConsig):CIZena:CMAntissa,RashodFromReturnOpenConsig);
{21}Str(StrToReal(Rashod):CIZena:CMAntissa,Rashod);
{23}Str(StrToReal(Sertifikat):CIZena:CMAntissa,Sertifikat);
{24}Str(StrToReal(Sdano):CIZena:CMAntissa,Sdano);
{25}Str(StrToReal(VidanoSF):CIZena:CMAntissa,VidanoSF);
{26}Str(StrToReal(Rewisia):CIZena:CMantissa,Rewisia);
{27}Str(StrToReal(SNAlogP):CIZena:CMantissa,SNalogP);
{28}Str(StrToReal(SNAlogC):CIZena:CMantissa,SNalogC);
{29}Str(StrToReal(SNAlogReturnOpenConsig):CIZena:CMantissa,SNalogReturnOpenConsig);


For i:=0 To 6 Do
Begin
{29,30,31,32,33,34,35}
 Str(StrToReal(PerewoskiInp[i]):CIZena:CMAntissa,PerewoskiInp[i]);
{36,37,38,39,40,41,42}
 Str(StrToReal(PerewoskiOut[i]):CIZena:CMAntissa,PerewoskiOut[i]);
End;{For}

{43}Str(StrToReal(EPerewoskiOut):CIZena:CMAntissa,EPerewoskiOut);
{44}Str(StrToReal(EPerewoskiInp):CIZena:CMAntissa,EPerewoskiInp);

End;{With}
End;

Destructor BakKassaPtr.Done;
Begin
TObject.Done;
End;






Var f : File Of BakKassaType;
    fn: File Of KassaType;
    B : PBakKAssaType;
    N : PKassaType;
    c : Word;

Begin
Assign(f,paramstr(1)+'.k01');
c:=IoResult;
Reset(f);
c:=IoResult;
If c<>0 Then
 Begin
  Writeln('Ошибка чтения кассы!');
  Readln;
  Exit;
 End;


Assign(fn,paramstr(1)+'.n01');
c:=IoResult;
Rewrite(fn);
c:=IoResult;
If c<>0 Then
 Begin
  Writeln('Ошибка создания кассы!');
  Readln;
  Exit;
 End;



 New(B,Init);
 New(N,Init);

 Read(f,B^.DAt);
 With N^.Dat Do
  Begin
{1}                              Prihod :=B^.DAt.Prihod;
{2}                             Ostatok :=B^.DAt.Ostatok;
{3}                                  RP :=B^.DAt.RP;
{4}                       SummaOutSklad :=B^.DAt.SummaOutSklad;
{43}                            Prodagi :=B^.DAt.Prodagi;
{43}                          SkProdagi :=B^.DAt.SkProdagi;
{5}                        VidanoConsig :=B^.DAt.VidanoConsig;
{6}                      SkVidanoConsig :=B^.DAt.SkVidanoConsig;
{7}                       OplataINKassa :=B^.DAt.OplataINKassa;
{8}                      SkOformConsign :=B^.DAt.SkOformConsign;
{9}                 ReturnOutOpenConsig :=B^.DAt.ReturnOutOpenConsig;
{10}              SkReturnOutOpenConsig :=B^.DAt.SkReturnOutOpenConsig;
{11}   ReturnOutMArketDocAndCloseConsig :=B^.DAt.ReturnOutMArketDocAndCloseConsig;
{12} SkReturnOutMArketDocAndCloseConsig :=B^.DAt.SkReturnOutMArketDocAndCloseConsig;
{13}                      OstatokConsig :=B^.DAt.OstatokConsig;
{14}                    SkOstatokConsig :=B^.DAt.SkOstatokConsig;
{15}                         Pereozenka :=B^.DAt.Pereozenka;
{16}               PereozenkaFromReturn :=B^.DAt.PereozenkaFromReturn;
{17}                       SummaInKassa :=B^.DAt.SummaInKassa;
{18}                     OstatokInKassa :=B^.DAt.OstatokInKassa;
{19}                      ExtendedDohod :=B^.DAt.ExtendedDohod;
{20}                   RashodFromReturn :=B^.DAt.RashodFromReturn;
{21}         RashodFromReturnOpenConsig :=B^.DAt.RashodFromReturnOpenConsig;
{21}                             Rashod :=B^.DAt.Rashod;
{23}                         Sertifikat :=B^.DAt.Sertifikat;
{24}                              Sdano :=B^.DAt.Sdano;
{25}                           VidanoSF :=B^.DAt.VidanoSF;
{26}                            Rewisia :=B^.DAt.Rewisia;
{27}                            SNalogP :=B^.DAt.SNalogP;
{28}                            SNalogC :=B^.DAt.SNalogC;
{29}             SNalogReturnOpenConsig :=B^.DAt.SNalogReturnOpenConsig;
{30,31,32,33,34,35,36}

                      OstatokBarter[0] :=#0;
                       BarterPrihod[0] :=#0;
                     BarterPrihodRZ[0] :=#0;
                            BarterT[0] :=#0;
                       BarterSkidki[0] :=#0;
                      BarterInKassa[0] :=#0;
                     BarterOutKassa[0] :=#0;

  For c:=0 To 4 Do
  Begin
   PerewoskiOut[c]:=B^.DAt.PerewoskiOut[c];
   PerewoskiInp[c]:=B^.DAt.PerewoskiInp[c];
  End;
{Эти поля не фигурируют на экране}

   EPerewoskiOut:=B^.DAt.EPerewoskiOut;
   EPerewoskiInp:=B^.DAt.EPerewoskiInp;

   CAption:=B^.DAt.CAption;
   DAteC:=B^.DAt.DateC;
   TimeC:=B^.DAt.TimeC;
   DateM:=B^.DAt.DateM;
   TimeM:=B^.DAt.TimeM;

  End;{With}

 Write(fn,N^.DAt);

 Close(f);
 Close(fn);

 Dispose(B,Done);
 Dispose(N,Done);




End.