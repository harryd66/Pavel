Uses Glob,servstr,objects,tpdate;

Type BakInputReturnType = Record
     Zena     : String[CZena];
     R_Zena   : String[CZena];
     O_Zena   : String[CZena];
  LocalSkidka : String[CZena];
    LocalProz : String[CLitr];
     Kol      : String[CKol];
     NDS      : String[CLitr];
    VidNalog  : Word;{ вид налога 0=5% 1=3% 2=прочее}
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
0 - наличная продажа скидка автоматическая
1 - наличная продажа скидка ручная
2 - закрытая консигнация авоматическая
3 - закрытая консигнация ручная
4 - открытая консигнация автоматическая
5 - открытая консигнация ручная
}
     DocSelector    : Word;
     {тип документа по новой классфикации продажи}
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
   StatusDoc : Word; {1 : Буфер; 0 :Документ попал на склад}
     Locked  : Boolean;
    BasisDoc : String[CDocNumer];
    BasisDate: TDateString;
      Opt    : Boolean;
    Rashod   : Boolean;{признак печати расходника}
  RashodSumma: String[CIZena];{велечина суммы расходника}

{Примечание
4 вида возврата (по расходникам)
1.возврат по продаже - расходник выдается на сумму возврата-сумма скидки возврата
2.возврат по закрытой консигнаци - расходник выдается на сумму возврата-сумма скидки возврата
3.возврат по открытой консигнации, причем долг по оплате документа
  превышает сумму возврата - расходник не выдается (он получается на нулевую сумму)
  в файл оплаты консигнации и персональный файл оплаты клиента пишется
  фиктивная оплата консигнации    на сумму возврата

4.возврат по открытой консигнации, причем долг по оплате документа
  меньше суммы возврата - расходник выдается на сумму равную:

      Расходник = сумма возврата-Сумма Долга по документу в настощее время }

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
  Writeln('Не могу открыть '+s1+'.vzw');
  Halt;
 End;

Assign(F,s1+'.new');
i:=IOResult;
Rewrite(F);
i:=IOResult;
If I<>0 Then
 Begin
  Close(BakFile);
  Writeln('Не могу создать '+s1+'.new');
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
   StatusDoc :=BakPtr^.Dat.StatusDoc ; {1 : Буфер; 0 :Документ попал на склад}
     Locked  :=BakPtr^.Dat.Locked ;
    BasisDoc :=BakPtr^.Dat.BasisDoc ;
    BasisDate:=BakPtr^.Dat.BasisDate ;
      Opt    :=BakPtr^.Dat.Opt ;
    Rashod   :=BakPtr^.Dat.Rashod ;{признак печати расходника}
  RashodSumma:=BakPtr^.Dat.RashodSumma ;{велечина суммы расходника}

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