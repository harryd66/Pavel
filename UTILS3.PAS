{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit utils3;


Interface
!
Uses Glob,ServStr,Dialogs,MyCalc,Drivers,Access5,Utils,
      TVType,TVConst,TVInput,TVDialog;

Function WritePrihodToSkladFile(L:PPrihodType) : Boolean;

{Function InputBN(Var l,P:PSuperMarketType):Boolean;}
Procedure PrihodToMarket(Var PrevMArket:PSuperMarketType;PrevZakaz:PPrihodType);
Procedure ZakazToMarket(Var PrevMArket:PSuperMarketType;PrevZakaz:PZakazType);
Procedure ZakazToIndex(PrevZakaz:PZakazType;Var PrevMarket:PHeaderZakazType);
Procedure PredZakazToIndex(PrevPredZakaz:PPredZakazType;Var PrevMarket:PHeaderPredZakazType);

Procedure MarketToIndex(PrevZakaz:PSuperMArketType;Var PrevMarket:PSuperMarketTypeIDX);
Procedure MarketToZakaz(L:PSuperMarketType;Var Zakaz:PZakazType);
Function CalcZakazMassa(PrevZakaz:PZakazType):AllStr;
Function CalcPredZakazMassa(PrevZakaz:PPredZakazType):AllStr;
Function CalcZakazMassaExt(PrevZakaz:PZakazType):AllStr;
Function CalcPredZakazMassaExt(PrevZakaz:PPredZakazType):AllStr;
Function CalcMarketMassa(FiltrOtdel:Maska8;PrevZakaz:PSuperMarketType):AllStr;

Function WriteZakazToSkladFile(L:PZakazType) : Boolean;
Function DeleteZakazFromSkladFile(L:PZakazType) : Boolean;
Procedure Average(DDD : TKolString;BakKol,BAkZena,NewKol,NewZena:AllStr; VAr AverageZena:AllStr);

Procedure SortNKL (Var L:PSuperMarketType);
Procedure SortNKLStatic (Var L:SuperMarketType);

Procedure FindINN(Reg,sel:Word;INN:AllStr);
Function InputFindInn(Var Inn:AllStr):Boolean;

Procedure LockUnlock(c:ArtikulStr;LockRegim:Word);
Procedure LockUnlockNalog(c:ArtikulStr;LockRegim:Word);
Procedure LockUnlockD(c:ArtikulStr;LockRegim:Word);
Function LockSelectName(S:ArtikulStr):Boolean;
Function SelectOperationAndDocument(Var mm3s:Maska3;Var mm9S:Maska9):Boolean;

procedure DelProdagaDoc(i:Word);
procedure DelProdagaU(i:Word);
Procedure DeterminateOtdelSertif(s:String;SFAntomArtikul:ArtikulStr;VAr A:ArtikulStr);
Function TestFAntomOtdel(s:String;SFAntomArtikul:ArtikulStr;VAr Active:ArtikulStr):Boolean;
Function TestZakaz(E:PZakazType):Boolean;
Function TestOtdel2(c:Word):Boolean;
Function TestOtdelName({отделение}vvv:Word;{разрешенные}c:Word):Boolean;
Function TestReturn(E:PNewVozwratType):Boolean;
Function DatePeriodDialog(Var s1,s2:TDAteString;Regim:Boolean):Boolean;
Function DatePeriodDialog1(DDD:TDateString;Var s1,s2:TDAteString):Boolean;
Function AddMarkerLast(Var L:PSuperMarketType) : Boolean;
Procedure ConfigExportImport;
Procedure ConfigDistantionSklads;


Type
    PInputBezNal= ^TInputBezNal;
    TInputBezNal = object(TbxEntryDialog)
    BankWin : PBankWindow;
    Function InputBN(Var L:BNType):Boolean;
    procedure HandleEvent(var Event: TEvent); virtual;
    Destructor Done;Virtual;
  end;



implementation

Uses Serv,Objects,DbEngine,MsgBox,NetDbEng,Protect,Editors,TpDate,NetCall,
     CPrihod,Net,Utils1,Tools,Memory,Mail,Net1,Utils5,Utils4,Utils6,
     DbEngin3,ServStr2,Utils11,
     Views,ColorTxt,Validate,App,Printers,DOS,Vision1,MrkTools,MrkTool;



Var Inp : PInputBezNal;
    ControlBank,ControlBanks : PView;
    Control1 : PbxEditLine;{PView}
    Control2 : PView;
    SBankKod : ArtikulStr;

    B : BNType;
    AA : Record
       BankKod : String[CClientKod];
       Dt1: TbxDateRec;
       NPlat: String[CPlat];
       Summa : String[CIZena];
       End;


Procedure ConvertingToB;
Begin
b.BankKod:=AA.BankKod;
RFormatZerro(B.BankKod,CClientKod);
DelSpace(AA.NPlat);
DelSpace(AA.Summa);
B.Date:=DateToDateStr(AA.DT1,DateMask);
B.NPlat:=AA.NPlat;
B.Summa:=AA.Summa;
End;


Procedure ConvertingToA;
Begin
aa.BankKod:=B.BankKod;
RFormatZerro(AA.BankKod,CClientKod);
DelSpace(B.NPlat);
DelSpace(B.Summa);
ExtractDateFromString(AA.Dt1,DateMask,B.Date);
AA.NPlat:=B.NPlat;
AA.Summa:=B.Summa;
End;



Function TInputBezNal.InputBN(Var L:BNType):Boolean;
Label 1;
var
  R : TRect;
  ss : AllStr;
  c : Word;
  k : LongInt;
Begin

InputBN:=False;

If (InputZakaz=1) Then
Begin
InputBN:=True;
Exit;
End;

B:=L;


1:



InputBN:=False;


R.Assign(12, 9, 67, 13);
New(Inp, Init(R, 'Реквизиты платежа'));
Inp^.Options := Inp^.Options or ofCenterX or ofCenterY;
Inp^.HelpCtx := $E011;

R.Assign(48, 1, 54, 2);
ControlBank := New(PROInputLine, Init(R, CClientKod));
ControlBank^.Options := ControlBank^.Options and not ofFirstClick;
Inp^.Insert(ControlBank);



R.Assign(7, 1, 49, 2);
SBankKod:=B.BankKod;
RFormatZerro(SBankKod,CClientKod);
ss:=GetBankField(FBank,SBankKod);
Format(ss,40);
ControlBankS := New(PColoredText, Init(R, ' '+ss+'│', $13));
Inp^.Insert(ControlBankS);

R.Assign(7, 2, 17, 3);
Control1:= New(PbxDateEdit, Init(R, DateMask));
Control1^.SetEditFlag(dfRequired, True);
Inp^.Insert(Control1);

  R.Assign(1, 2, 7, 3);
  Inp^.Insert(New(PLabel, Init(R, 'Дата:', Control1)));

R.Assign(23, 2, 30, 3);
Control2 := New(PInputLine, Init(R, CPlat));
Inp^.Insert(Control2);

  R.Assign(17, 2, 23, 3);
  Inp^.Insert(New(PLabel, Init(R, 'N ПП:', Control2)));

R.Assign(37, 2, 54, 3);
Control2 := New(PInputLine, Init(R, CIZena));
Inp^.Insert(Control2);
  PInputLine(Control2)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(30, 2, 37, 3);
  Inp^.Insert(New(PLabel, Init(R, 'Сумма:', Control2)));

Inp^.SelectNext(False);

ConvertingToA;
Inp^.SetData(aa);

c:=Desktop^.ExecView(Inp);
If c<>CmCancel Then
 Begin
  Inp^.GetData(AA);
  ConvertingToB;

  DelSpace(B.Date);
  DelSpace(B.NPlat);
  MyStr(StrToReal(B.Summa),CIZena,CMAntissa,B.Summa);
  DelSpace(B.Summa);
  DelSpaceRight(B.BankKod);

  If StrToInt(b.BankKod)=StrToInt(NoBankStr) Then
   Begin
    MessageBox(#3^M+#3'Не указан банк !',Nil,mfError+mfCancelButton);
   End;

  If DateStringToDate(DateMask,B.Date)<DateStringToDate(DateMask,'01-01-01') Then
   Begin
Dispose(ControlBank,Done);
Dispose(ControlBankS,Done);
Dispose(Control1,Done);
Dispose(Control2,Done);
Dispose(Inp,Done);
    MessageBox(#3^M+#3'Это лажа а не дата !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  If Not(TestDate(B.Date,k)) Then
   Begin
Dispose(ControlBank,Done);
Dispose(ControlBankS,Done);
Dispose(Control1,Done);
Dispose(Control2,Done);
Dispose(Inp,Done);
    MessageBox(#3^M+#3'Не существующая дата !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  If b.Date[0]=#0 Then
   Begin
Dispose(ControlBank,Done);
Dispose(ControlBankS,Done);
Dispose(Control1,Done);
Dispose(Control2,Done);
Dispose(Inp,Done);
    MessageBox(#3^M+#3'Не указана дата п/п !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  If b.NPlat[0]=#0 Then
   Begin
Dispose(ControlBank,Done);
Dispose(ControlBankS,Done);
Dispose(Control1,Done);
Dispose(Control2,Done);
Dispose(Inp,Done);
    MessageBox(#3^M+#3'Не указан номер п/п !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  If StrToReal(b.Summa)=0 Then
   Begin
Dispose(ControlBank,Done);
Dispose(ControlBankS,Done);
Dispose(Control1,Done);
Dispose(Control2,Done);
Dispose(Inp,Done);
    MessageBox(#3^M+#3'Нулевая сумма б/н платежа !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  InputBn:=True;
  L:=B;
ENd;


Dispose(ControlBank,Done);
Dispose(ControlBankS,Done);
Dispose(Control1,Done);
Dispose(Control2,Done);
Dispose(Inp,Done);


End;

Destructor TInputBezNal.Done;
Begin
ClearFind;
TDialog.Done;
End;


procedure TInputBezNal.HandleEvent(var Event: TEvent);
Var R : TRect;
    test : Word;
    s : TMyString;
    L : Boolean;
   cod : ArtikulStr;
    Op : StrNAme;

begin

Case Event.What Of
 evCommand :
   Case Event.Command Of

   cmSelectBank : Begin
  If (PView(BankWin)<>Desktop^.TopView)And(ControlBank^.State and sfFocused <> 0) Then
  Begin
     PStaticText(ControlBankS)^.GetText(S);
     System.Delete(S,1,1);
     {ControlBank^.GetData(TT.BankKod);}
     s:=s+SBAnkKod;
     BankWin^.ShowBankList(s,Test);
     SBankKod:=Copy(s,Pos('│',s)+1,CClientKod);
     ControlBank^.SetData(SBankKod);
     s[0]:=#0;
	s:=GetBankField(FBank,SBankKod);
     Format(s,40);
     s:=s+'│';
     PStaticText(ControlBankS)^.Text^:=' '+S;
     Redraw;
     Case Test Of
      0,3 :FocusNext(True);
      1,2 :FocusNext(False);
     Else;
          End;
     Redraw;

     ClearEvent(Event);
  End
  Else
   ClearEvent(Event);
 End;

   Else;
   End;
   Else;
   End;


 If (PView(BankWin)<>Desktop^.TopView)And(ControlBank^.State and sfFocused <> 0)
 And (Event.Command<>cmSelectBank) And
(
 ((AutoList=1) And (Event.What <> EvKeyDown))

 Or
 ((AutoList=0)And(Event.What = EvKeyDown)And(Event.KeyCode=kbConst))
)Then
            Begin
             Event.What:=EvCommand;
             Event.Command:=cmSelectBank;
             PutEvent(Event);
             ClearEvent(Event);
            End;

  inherited HandleEvent(Event);
end;






Function WritePrihodToSkladFile(L:PPrihodType) : Boolean;
Var SkladFile : File Of SkladType;
    KdxFile : File Of SkladTypeNew;
    Sklad : PSkladType;
    Kdx : PSkladTypeNew;
    i,p,k,j : Byte;
    Ls:LongInt;
    AverageZena,s1,s2 : TEnjoyStr;
    Bilo,Stalo : ArtikulStr;
Begin

WritePrihodToSkladFile:=False;
New(Sklad,Init);
New(Kdx,Init);
 For i:=1 To L^.DAt.Amount{J} Do
  Begin
   S1:=Copy(L^.Dat.PrihodElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path^.Dat.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;


   Assign(KdxFile,Path^.Dat.ToIndex+s1+'.kdx');
   p:=IOResult;
   Reset(KdxFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     Close(SkladFile);
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.kdx!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;

        Ls:=GetFileLocation3(Copy(L^.Dat.PrihodElement[i].BazKod,CRazdelKod+1,CKod));
        Seek(SkladFile,Ls);
        Seek(KdxFile,Ls);
        {блокируем позицию предварительной блокировкой}
        Repeat
        Pause(1);
        Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
        Read(SkladFile,Sklad^.DAt);
        Read(KDXFile,Kdx^.DAt);

        Bilo:=Sklad^.Dat.Input.Kol;

        With Sklad^.Dat.Input Do
        Begin
         USD := L^.Dat.PrihodElement[i].Input.USD;
         Average(Sklad^.DAt.Input.Division,Sklad^.DAt.Input.Kol,Sklad^.DAt.Input.Zakupka,
            L^.Dat.PrihodElement[i].Input.Kol,
            L^.Dat.PrihodElement[i].Input.Zakupka,AverageZena);

         LastZakupka:=Zakupka;
         Zakupka:=AverageZena;

         Average(Sklad^.DAt.Input.Division,Sklad^.DAt.Input.Kol,Sklad^.DAt.Input.Zakupka2,
            L^.Dat.PrihodElement[i].Input.Kol,
            L^.Dat.PrihodElement[i].Input.Zakupka2,AverageZena);
         Zakupka2:=AverageZena;
         StrihKod:=L^.Dat.PrihodElement[i].Input.StrihKod;

         NGTD:=L^.Dat.PrihodElement[i].Input.NGTD;
         Expert:=L^.Dat.PrihodElement[i].Input.Expert;
         Marka:=L^.Dat.PrihodElement[i].Input.Marka;
         SpecMarka:=L^.Dat.PrihodElement[i].Input.SpecMarka;
         Godnost:=L^.Dat.PrihodElement[i].Input.Godnost;
         NSertif:=L^.Dat.PrihodElement[i].Input.NSertif;
         NMakeKod:=L^.Dat.PrihodElement[i].Input.NMakeKod;
        {NGroupKod:=L^.Dat.PrihodElement[i].Input.NGroupKod;}

          GRZena:=L^.Dat.PrihodElement[i].Input.GRZena;
          Proz:=L^.Dat.PrihodElement[i].Input.Proz;
          Spec_Zena:=L^.Dat.PrihodElement[i].Input.Spec_Zena;
          R_Zena:=L^.Dat.PrihodElement[i].Input.R_Zena;
          O_Zena:=L^.Dat.PrihodElement[i].Input.O_Zena;
          RegionMarka:=L^.Dat.PrihodElement[i].Input.RegionMArka;
          AkzisSbor:=L^.Dat.PrihodElement[i].Input.AkzisSbor;
          ZenaMArki:=L^.Dat.PrihodElement[i].Input.ZenaMarki;

          Virabotano:=L^.Dat.PrihodElement[i].Input.Virabotano;
          Sklad^.Dat.MakeKod:=L^.Dat.MakeKod;
          Caption:=L^.Dat.Caption;
          DelSpace(L^.Dat.PrihodElement[i].Input.Kol);
          Sklad^.Dat.Date := ToDay;
          Sklad^.Dat.Time := CurrentTime;
          For k:=1 To CDivision Do
          Str((StrToInt(Division[k])+StrToInt(L^.Dat.PrihodElement[i].Input.Division[k])):CKol,Division[k]);
          Kol[0]:=#0;
        End;
        Sklad^.Dat.MakeVid:=L^.Dat.OperatorSelector;
        Sklad^.Dat.Input.Kol[0]:=#0;
        For k:=1 To CDivision Do
        Str((StrToInt(Sklad^.Dat.Input.Division[k])+StrToInt(Sklad^.Dat.Input.Kol)):CKol,Sklad^.Dat.Input.Kol);
        Sklad^.Dat.Employ:=True;

        With Kdx^.DAt Do
        Begin
         Employ:=True;
         BazKod  :=StrToInt(Sklad^.Dat.BazKod);
         NSertif :=StrToInt(Sklad^.Dat.Input.NSertif);
         NMakeKod:=StrToInt(Sklad^.Dat.Input.NMakeKod);

         NGTDKod:=StrToInt(L^.Dat.PrihodElement[i].Input.NGTD);
         NExpertKod:=StrToInt(L^.Dat.PrihodElement[i].Input.Expert);
         NMarkaKod:=StrToInt(L^.Dat.PrihodElement[i].Input.Marka);
         NSpecMarkaKod:=StrToInt(L^.Dat.PrihodElement[i].Input.SpecMarka);
         FirmaPostKod:=StrToInt(GetIDField(FFirmaPost,L^.Dat.PrihodElement[i].BazKod));
         NGroupKod:=StrToInt(GetIDField(FNGroupKod,L^.Dat.PrihodElement[i].BazKod));

         Zakupka:=StrToReal(Sklad^.Dat.Input.Zakupka);
         Zakupka2:=StrToReal(Sklad^.Dat.Input.Zakupka2);
         AkzisSbor:=StrToReal(Sklad^.Dat.Input.AkzisSbor);
         StrihKod:=Sklad^.Dat.Input.StrihKod;
         Kol:=StrToInt(Sklad^.Dat.Input.Kol);
         RegionMarka:=Sklad^.Dat.Input.RegionMarka;
         For j:=1 To CDivision Do Division[j]:=StrToInt(Sklad^.Dat.Input.Division[j]);
         For j:=1 To CDivision Do DivisionR[j]:=StrToInt(Sklad^.Dat.Input.DivisionR[j]);
         R_Zena  :=StrToReal(Sklad^.Dat.Input.R_Zena);
        End;


        Stalo:=Sklad^.Dat.Input.Kol;

  {сохраняем изменения}
        Seek(SkladFile,FilePos(SkladFile)-1);
        Write(SkladFile,Sklad^.Dat);


        Seek(KdxFile,FilePos(KdxFile)-1);
        Write(KdxFile,Kdx^.Dat);
  {деблокируем позицию}

        Seek(SkladFile,FilePos(SkladFile)-1);
(*
        If (StrToInt(Stalo)>0) And (StrToInt(Bilo)=0) Then
                  SetIndex(Sklad^.Dat.BazKod,True);
*)
        Repeat
         UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
        Until (DosError=0);


   p:=IOResult;
        Close(SkladFile);{закрытие файла}
   p:=IOResult;
        Close(KdxFile);{закрытие файла}
   p:=IOResult;
  End;
Dispose(Sklad,Done);
Dispose(Kdx,Done);
WritePrihodToSkladFile:=True;
End;


Procedure ZakazToMarket(Var PrevMArket:PSuperMarketType;PrevZakaz:PZakazType);
VAr Skl : PSkladType;
    BBB : PBazType;
    c : Word;
    NewProz: TDAteString;
Begin
 With PrevMarket^.Dat Do
  Begin
     Caption :=PrevZakaz^.DAt.Caption;
     OperatorSelector :=PrevZakaz^.DAt.OperatorSelector;
     DocSelector      :=PrevZakaz^.DAt.DocSelector;
     DocumentComment  :=PrevZakaz^.DAt.DocumentComment;

     Versia:=PrevZakaz^.DAt.Versia;
     SkidkaSelector :=PrevZakaz^.DAt.SkidkaSelector;
     ShkalaNumer:=PrevZakaz^.DAt.ShkalaNumer;
     Processing:=PrevZakaz^.Dat.Processing;
     Comment1 :=PrevZakaz^.DAt.Comment1;
     Comment2 :=PrevZakaz^.DAt.Comment2;

     Summaz:=PrevZakaz^.DAt.SummaZ;
     Skidka:=PrevZakaz^.DAt.Skidka;
     SertifSummaz:=PrevZakaz^.DAt.SertifSummaZ;
     SertifSkidka:=PrevZakaz^.DAt.SertifSkidka;

     ClientKod :=PrevZakaz^.DAt.ClientKod;

     AgentKod :=PrevZakaz^.DAt.AgentKod;
     EkspeditorKod :=PrevZakaz^.DAt.EkspeditorKod;

     New(Skl,Init);
     New(BBB,Init);

     {перенос наименований}
     For c:=1 To PrevZakaz^.Dat.Amount Do
     Begin
     MarketElement[c].Bazkod:=PrevZakaz^.Dat.MarketElement[c].BAzKod;

     With MarketElement[c].Input Do
      Begin
        Skl^.Dat.BazKod:=PrevZakaz^.Dat.MarketElement[c].BAzKod;
        Version:=PrevZakaz^.Dat.MarketElement[c].Input.Version;
        GetSkladRecord(Skl);
        GetBazElement(Skl^.Dat.BazKod,BBB^.Dat);
        Kol := PrevZakaz^.Dat.MarketElement[c].Input.Kol;

        {пересчет ручной скидки}
        DelSpace(Skl^.Dat.Input.R_Zena);
        DelSpace(PrevZakaz^.Dat.MarketElement[c].Input.Zena);

If ZeniInZakaz=1 Then{если менять цени на складские}
Begin
        NewProz[0]:=#0;
       If (Skl^.Dat.Input.R_Zena)<>(PrevZakaz^.Dat.MarketElement[c].Input.Zena) Then
    Begin
       If StrToReal(PrevZakaz^.Dat.MarketElement[c].Input.Skidka)>=0 Then
        Begin
         If (StrToReal(PrevZakaz^.Dat.MarketElement[c].Input.Zena)-
            StrToReal(PrevZakaz^.Dat.MarketElement[c].Input.Skidka)) >0.009 Then
         Begin
         MySTr(StrToreal(PrevZakaz^.Dat.MarketElement[c].Input.Zena)/
            (StrToReal(PrevZakaz^.Dat.MarketElement[c].Input.Zena)-
            StrToReal(PrevZakaz^.Dat.MarketElement[c].Input.Skidka)),CKol,CMAntissa,NewProz);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)/StrToReal(NewProz),CZena,CMantissa,Skidka);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)-StrToReal(Skidka),CZena,CMantissa,Skidka);
         End
         Else Skidka:=Skl^.Dat.Input.R_Zena;
        End
         Else
        Begin
         {вариант наценки}
         MyStr(Abs(StrToReal(PrevZakaz^.Dat.MarketElement[c].Input.Skidka)/
                  StrToReal(PrevZakaz^.Dat.MarketElement[c].Input.Zena)),CKol,CMantissaZ,NewProz);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)*
                  StrToReal(NewProz),CKol,CMantissaZ,Skidka);
               DelSpace(Skidka);
               Skidka:='-'+Skidka;
        End;
    End
     Else
        {цена не изменилась}
        Begin
          Skidka:=PrevZakaz^.Dat.MarketElement[c].Input.Skidka;
        End;
End
    Else{если оставлять в накладной цени заказа}
    Begin
     NewProz[0]:=#0;
       If (Skl^.Dat.Input.R_Zena)<>(PrevZakaz^.Dat.MarketElement[c].Input.Zena) Then
    Begin
       {получили реальную цену к оплате в заказе}
       MyStr(StrToReal(PrevZakaz^.Dat.MarketElement[c].Input.Zena)
               -StrToReal(PrevZakaz^.Dat.MarketElement[c].Input.Skidka),
                  CZena,CMantissa,NewProz);

       {расчитываем отклонение нужной цены от текущей складской}
       MyStr(StrToReal(Skl^.Dat.Input.R_Zena)-
                StrToReal(NewProz),CZena,CMantissa,NewProz);
       DelSpace(NewProz);
       Skidka:=NewProz;
    End
     Else
        {цена не изменилась}
        Begin
          Skidka:=PrevZakaz^.Dat.MarketElement[c].Input.Skidka;
        End;

    End;{Else ZeniInZakaz}

        DelSpace(Skidka);

        Zena    :=Skl^.Dat.Input.R_Zena;
        R_Zena  :=Skl^.Dat.Input.R_Zena;
        O_Zena  :=Skl^.Dat.Input.O_Zena;
        Zakupka :=Skl^.Dat.Input.Zakupka;
        Zakupka2 :=Skl^.Dat.Input.Zakupka2;
        AkzisSbor:=Skl^.Dat.Input.AkzisSbor;
        ZenaMarki:=Skl^.Dat.Input.ZenaMarki;
        RegionMarka :=Skl^.Dat.Input.RegionMarka;

        {MyStr(StrToReal(Zena)*StrToInt(Kol),CInputIZena,CMantissa,Itogo);}

        Proz    :=PrevZakaz^.Dat.MarketElement[c].Input.Proz;

        VidNDS  :=BBB^.Dat.VidNDS;
        NDS     :=BBB^.Dat.NDS;
        VidNalog   :=BBB^.Dat.VidNalog;
        SpecNalog  :=BBB^.Dat.Nalog;
        DiviSionNumber:=PrevZakaz^.Dat.MarketElement[c].Input.InputDivision;
        Last     :=False;

        NSertif  :=PrevZakaz^.Dat.MarketElement[c].Input.NSertif;
        SertifKol:=PrevZakaz^.Dat.MarketElement[c].Input.SertifKol;

       MarkaKod :=PrevZakaz^.Dat.MarketElement[c].Input.MarkaKod;
       SMarkaKod:=PrevZakaz^.Dat.MarketElement[c].Input.SMarkaKod;
       NGTDKod  :=PrevZakaz^.Dat.MarketElement[c].Input.NGTDKod;
       ExpertKod:=PrevZakaz^.Dat.MarketElement[c].Input.ExpertKod;
       Srok     :=PrevZakaz^.Dat.MarketElement[c].Input.Srok;
     Virabotano :=PrevZakaz^.Dat.MarketElement[c].Input.Virabotano;

      End;{With}
     End;

     {перенос сертификатов}
     For c:=1 To PrevZakaz^.Dat.AmountS Do
     Begin
     DocumentElement[c].Bazkod:=PrevZakaz^.Dat.DocumentElement[c].BAzKod;
     With DocumentElement[c].Input Do
      Begin
        Version:=PrevZakaz^.Dat.DocumentElement[c].Input.Version;

        Skl^.Dat.BazKod:=PrevZakaz^.Dat.DocumentElement[c].BAzKod;

        GetSkladRecord(Skl);
        GetBazElement(Skl^.Dat.BazKod,BBB^.Dat);

        Kol:=PrevZakaz^.Dat.DocumentElement[c].Input.Kol;

        {пересчет ручной скидки}
        {пересчет ручной скидки}
       DelSpace(Skl^.Dat.Input.R_Zena);
       DelSpace(PrevZakaz^.Dat.DocumentElement[c].Input.Zena);

If ZeniInZakaz=1 Then{если менять цени на складские}
Begin
        NewProz[0]:=#0;
       If (Skl^.Dat.Input.R_Zena)<>(PrevZakaz^.Dat.DocumentElement[c].Input.Zena) Then
    Begin
       If StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Skidka)>=0 Then
        Begin
         If (StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Zena)-
            StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Skidka)) >0.009 Then
         Begin
         MySTr(StrToreal(PrevZakaz^.Dat.DocumentElement[c].Input.Zena)/
            (StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Zena)-
            StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Skidka)),CKol,CMAntissa,NewProz);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)/StrToReal(NewProz),CZena,CMantissa,Skidka);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)-StrToReal(Skidka),CZena,CMantissa,Skidka);
         End
         Else Skidka:=Skl^.Dat.Input.R_Zena;
        End
         Else
        Begin
         {вариант наценки}
         MyStr(Abs(StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Skidka)/
                  StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Zena)),CKol,CMantissaZ,NewProz);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)*
                  StrToReal(NewProz),CKol,CMantissaZ,Skidka);
               DelSpace(Skidka);
               Skidka:='-'+Skidka;
        End;
    End
     Else
        {цена не изменилась}
        Begin
          Skidka:=PrevZakaz^.Dat.DocumentElement[c].Input.Skidka;
        End;
End
    Else{если оставлять в накладной цени заказа}
    Begin
     NewProz[0]:=#0;
       If (Skl^.Dat.Input.R_Zena)<>(PrevZakaz^.Dat.DocumentElement[c].Input.Zena) Then
    Begin
       {получили реальную цену к оплате в заказе}
       MyStr(StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Zena)
               -StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Skidka),
                  CZena,CMantissa,NewProz);

       {расчитываем отклонение нужной цены от текущей складской}
       MyStr(StrToReal(Skl^.Dat.Input.R_Zena)-
                StrToReal(NewProz),CZena,CMantissa,NewProz);
       DelSpace(NewProz);
       Skidka:=NewProz;
    End
     Else
        {цена не изменилась}
        Begin
          Skidka:=PrevZakaz^.Dat.DocumentElement[c].Input.Skidka;
        End;

    End;{Else ZeniInZakaz}


(*
       If (Skl^.Dat.Input.R_Zena)<>(PrevZakaz^.Dat.DocumentElement[c].Input.Zena) Then
    Begin
         NewProz[0]:=#0;
       If StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Skidka)>=0 Then
        Begin
         If (StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Zena)-
            StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Skidka)) >0.009 Then
         Begin
         MySTr(StrToreal(PrevZakaz^.Dat.DocumentElement[c].Input.Zena)/
            (StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Zena)-
            StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Skidka)),CKol,CMAntissaZ,NewProz);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)/StrToReal(NewProz),CZena,CMantissa,Skidka);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)-StrToReal(Skidka),CZena,CMantissa,Skidka);
         End
         Else Skidka:=Skl^.Dat.Input.R_Zena;
        End
         Else
        Begin
         {вариант наценки}
         MyStr(Abs(StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Skidka)/
                  StrToReal(PrevZakaz^.Dat.DocumentElement[c].Input.Zena)),CKol,CMantissa,NewProz);
         MyStr(StrToReal(Skl^.Dat.Input.R_Zena)*
                  StrToReal(NewProz),CKol,CMantissaZ,Skidka);
               DelSpace(Skidka);
               Skidka:='-'+Skidka;
        End;
    End
     Else
        {цена не изменилась}
        Begin
          Skidka:=PrevZakaz^.Dat.DocumentElement[c].Input.Skidka;
        End;
*)
        DelSpace(Skidka);

        Zena    :=Skl^.Dat.Input.R_Zena;
        R_Zena  :=Skl^.Dat.Input.R_Zena;
        O_Zena  :=Skl^.Dat.Input.O_Zena;
        Zakupka :=Skl^.Dat.Input.Zakupka;
        Zakupka2:=Skl^.Dat.Input.Zakupka2;
        AkzisSbor:=Skl^.Dat.Input.AkzisSbor;
        ZenaMarki:=Skl^.Dat.Input.ZenaMarki;
        RegionMarka :=Skl^.Dat.Input.RegionMarka;

        {MyStr(StrToReal(Zena)*StrToInt(Kol),CInputIZena,CMantissa,Itogo);}

        Proz    :='0.00';
        VidNDS  :=BBB^.Dat.VidNDS;
        NDS     :=BBB^.Dat.NDS;
        VidNalog   :=BBB^.Dat.VidNalog;
        SpecNalog  :=BBB^.Dat.Nalog;
        DiviSionNumber:=PrevZakaz^.Dat.DocumentElement[c].Input.InputDivision;
        Last     :=False;
        NSertif  :=PrevZakaz^.Dat.DocumentElement[c].Input.NSertif;
        SertifKol:=PrevZakaz^.Dat.DocumentElement[c].Input.SertifKol;
      End;
     End;

     Dispose(Skl,Done);
     Dispose(BBB,Done);

     DateC   :=PrevZakaz^.DAt.DateC;
     TimeC   :=PrevZakaz^.DAt.TimeC;
     DateM   :=PrevZakaz^.DAt.DateM;
     TimeM   :=PrevZakaz^.DAt.TimeM;

   SkladKod  :=PrevZakaz^.DAt.SkladKod;
     Active  :=True;
     Srok    :=PrevZakaz^.DAt.Srok;
     Amount  :=PrevZakaz^.DAt.Amount;
(**) AmountS :=PrevZakaz^.DAt.AmountS;
     Locked  :=PrevZakaz^.DAt.Locked;
     Rashet  :=PrevZakaz^.DAt.Rashet;
     {Comment :=PrevZakaz^.DAt.Comment;}

  End;{With}
End;{Procedure}



Function CalcZakazMassa(PrevZakaz:PZakazType):AllStr;
VAr BBB : PBazType;
    c : Word;
    AllMassa:AllStr;
    Bk : ArtikulStr;
Begin
CalcZakazMassa[0]:=#0;
AllMassa[0]:=#0;

 With PrevZakaz^.Dat Do
  Begin
     {перенос наименований}
   For c:=1 To PrevZakaz^.Dat.Amount Do
   Begin
     BK:=PrevZakaz^.Dat.MarketElement[c].BAzKod;
     New(BBB,Init);
     With MarketElement[c].Input Do
      Begin
        GetBazElement(BK,BBB^.Dat);
        MyStr(StrToReal(AllMassa)+StrToInt(PrevZakaz^.Dat.MarketElement[c].Input.Kol)*
	   StrToReal(BBB^.DAt.Massa),CPack,CLitrMantissa,AllMAssa);
      End;{With}
     Dispose(BBB,Done);
   End;{For}
  End;{With}

CAlcZakazMassa:=AllMassa;
End;{Procedure}



Function CalcZakazMassaExt(PrevZakaz:PZakazType):AllStr;
VAr BBB : PBazType;
    c : Word;
    AllMassa:AllStr;
    Bk : ArtikulStr;
Begin
CalcZakazMassaExt[0]:=#0;
AllMassa[0]:=#0;

 With PrevZakaz^.Dat Do
  Begin
     {перенос наименований}
   For c:=1 To PrevZakaz^.Dat.Amount Do
   Begin
     BK:=PrevZakaz^.Dat.MarketElement[c].BAzKod;
     New(BBB,Init);
     With MarketElement[c].Input Do
      Begin
        GetBazElementExt(BK,BBB^.Dat);
        MyStr(StrToReal(AllMassa)+StrToInt(PrevZakaz^.Dat.MarketElement[c].Input.Kol)*
	   StrToReal(BBB^.DAt.Massa),CPack,CLitrMantissa,AllMAssa);
      End;{With}
     Dispose(BBB,Done);
   End;{For}
  End;{With}

CAlcZakazMassaExt:=AllMassa;
End;{Procedure}


Function CalcPredZakazMassa(PrevZakaz:PPredZakazType):AllStr;
VAr BBB : PBazType;
    c : Word;
    AllMassa:AllStr;
    Bk : ArtikulStr;
Begin
CalcPredZakazMassa[0]:=#0;
AllMassa[0]:=#0;

 With PrevZakaz^.Dat Do
  Begin
     {перенос наименований}
   For c:=1 To PrevZakaz^.Dat.Amount Do
   Begin
     BK:=PrevZakaz^.Dat.Element[c].BAzKod;
     New(BBB,Init);
     With Element[c] Do
      Begin
        GetBazElement(BK,BBB^.Dat);
        MyStr(StrToReal(AllMassa)+StrToInt(PrevZakaz^.Dat.Element[c].Kol)*
	   StrToReal(BBB^.DAt.Massa),CPack,CLitrMantissa,AllMAssa);
      End;{With}
     Dispose(BBB,Done);
   End;{For}
  End;{With}

CAlcPredZakazMassa:=AllMassa;
End;{Procedure}



Function CalcPredZakazMassaExt(PrevZakaz:PPredZakazType):AllStr;
VAr BBB : PBazType;
    c : Word;
    AllMassa:AllStr;
    Bk : ArtikulStr;
Begin
CalcPredZakazMassaExt[0]:=#0;
AllMassa[0]:=#0;

 With PrevZakaz^.Dat Do
  Begin
     {перенос наименований}
   For c:=1 To PrevZakaz^.Dat.Amount Do
   Begin
     BK:=PrevZakaz^.Dat.Element[c].BAzKod;
     New(BBB,Init);
     With Element[c] Do
      Begin
        GetBazElementExt(BK,BBB^.Dat);
        MyStr(StrToReal(AllMassa)+StrToInt(PrevZakaz^.Dat.Element[c].Kol)*
	   StrToReal(BBB^.DAt.Massa),CPack,CLitrMantissa,AllMAssa);
      End;{With}
     Dispose(BBB,Done);
   End;{For}
  End;{With}

CAlcPredZakazMassaExt:=AllMassa;
End;{Procedure}



Function CalcMarketMassa(FiltrOtdel:Maska8;PrevZakaz:PSuperMarketType):AllStr;
VAr BBB : PBazType;
    c : Word;
    AllMassa:AllStr;
    Bk : ArtikulStr;
Begin
CalcMArketMassa[0]:=#0;
AllMassa[0]:=#0;

 With PrevZakaz^.Dat Do
  Begin
     {перенос наименований}
   For c:=1 To PrevZakaz^.Dat.Amount Do
   Begin
     If FiltrOtdel[PrevZakaz^.Dat.MarketElement[c].Input.DivisionNumber]=1 Then
     Begin
     BK:=PrevZakaz^.Dat.MarketElement[c].BAzKod;
     New(BBB,Init);
     With MarketElement[c].Input Do
      Begin
        GetBazElement(BK,BBB^.Dat);
        MyStr(StrToReal(AllMassa)+StrToInt(PrevZakaz^.Dat.MarketElement[c].Input.Kol)*
	   StrToReal(BBB^.DAt.Massa),CPack,CLitrMantissa,AllMAssa);
      End;{With}
     Dispose(BBB,Done);
     End;
   End;{For}
  End;{With}

CalcMarketMassa:=AllMassa;
End;{Procedure}


Procedure ZakazToIndex(PrevZakaz:PZakazType;Var PrevMarket:PHeaderZakazType);
VAr Skl : PSkladType;
    BBB : PBazType;
    c : Word;
    NewProz: TDAteString;
Begin
 With PrevMarket^.Dat Do
  Begin
     OperatorSelector :=PrevZakaz^.DAt.OperatorSelector;
     DocSelector      :=PrevZakaz^.DAt.DocSelector;
     Rashet      :=PrevZakaz^.DAt.Rashet;
     ShkalaNumer :=PrevZakaz^.DAt.ShkalaNumer;
     Processing :=PrevZakaz^.DAt.Processing;
     Versia:=PrevZakaz^.DAt.Versia;
     SkidkaSelector :=PrevZakaz^.DAt.SkidkaSelector;

     Summaz:=StrToReal(PrevZakaz^.DAt.SummaZ);
     Skidka:=StrToReal(PrevZakaz^.DAt.Skidka);
     SertifSummaz:=StrToReal(PrevZakaz^.DAt.SertifSummaZ);
     SertifSkidka:=StrToReal(PrevZakaz^.DAt.SertifSkidka);

     Document:=StrToInt(PrevZakaz^.DAt.Document);

     ClientKod :=StrToInt(PrevZakaz^.DAt.ClientKod);

     AgentKod :=StrToInt(PrevZakaz^.DAt.AgentKod);
     EkspeditorKod:=StrToInt(PrevZakaz^.DAt.EkspeditorKod);


     DateC   :=DateStringToDate(DateMask,PrevZakaz^.DAt.DateC);
     TimeC   :=TimeStringToTime('hh:mm:ss',PrevZakaz^.DAt.TimeC);
     DateM   :=DateStringToDate(DateMask,PrevZakaz^.DAt.DateM);
     TimeM   :=TimeStringToTime('hh:mm:ss',PrevZakaz^.DAt.TimeM);

     Caption :=StrToInt(PrevZakaz^.DAt.Caption);
     EndDate :=PrevZakaz^.DAt.EndDate;

     DocReal :=StrToInt(PrevZakaz^.DAt.DocReal);
     DocDate :=DateStringToDate(DateMask,PrevZakaz^.DAt.DocDate);
     Oformlenie := PrevZakaz^.DAt.Oformlenie;
     SkladKod := StrToInt(PrevZakaz^.DAt.SkladKod);

     Status         :=PrevZakaz^.DAt.Status;
     PredZakazNumer :=PrevZakaz^.DAt.PredZakazNumer;
     PredZakazDate  :=PrevZakaz^.DAt.PredZakazDate;
     PredZakazClient:=PrevZakaz^.DAt.PredZakazClient;


  End;{With}
End;{Procedure}


Procedure PredZakazToIndex(PrevPredZakaz:PPredZakazType;Var PrevMarket:PHeaderPredZakazType);
Begin
 With PrevMarket^.Dat Do
  Begin
   OperatorSelector :=PrevPredZakaz^.Dat.OperatorSelector;
   DocSelector :=PrevPredZakaz^.Dat.DocSelector;
   Versia :=PrevPredZakaz^.Dat.Versia;
   ShkalaNumer:=PrevPredZakaz^.Dat.ShkalaNumer;
   SkidkaSelector:=PrevPredZakaz^.Dat.SkidkaSelector;

   DateConv:=PrevPredZakaz^.Dat.DateConv;
   TimeConv:=PrevPredZakaz^.Dat.TimeConv;

   ClientNumer :=PrevPredZakaz^.Dat.ClientNumer;
   Date  :=DateStringToDate(DateMask,PrevPredZakaz^.Dat.Date);
   ClientKod:=StrToInt(PrevPredZakaz^.Dat.ClientKod);
   SkladKod:=StrToInt(PrevPredZakaz^.Dat.SkladKod);
   AgentKod:=StrToInt(PrevPredZakaz^.Dat.AgentKod);
   Document :=StrToInt(PrevPredZakaz^.Dat.Document);
   DateC:=PrevPredZakaz^.Dat.DateC;
   DateM:=PrevPredZakaz^.Dat.DateM;
   TimeC:=PrevPredZakaz^.Dat.TimeC;
   TimeM:=PrevPredZakaz^.Dat.TimeM;
   DateEnd :=DateStringToDate(DateMask,PrevPredZakaz^.Dat.DateEnd);

   ZakazNumer:=StrToInt(PrevPredZakaz^.Dat.ZakazNumer);
   Summa:=StrToReal(PrevPredZakaz^.Dat.Summa);
   Skidka:=StrToReal(PrevPredZakaz^.Dat.Skidka);
   SertifSumma:=StrToReal(PrevPredZakaz^.Dat.SertifSumma);
   SertifSkidka:=StrToReal(PrevPredZakaz^.Dat.SertifSkidka);
   Defizit:=PrevPredZakaz^.Dat.Defizit;
   DataOtpr :=DateStringToDate(DateMask,PrevPredZakaz^.Dat.DataOtpr);

   Rezerv :=  PrevPredZakaz^.Dat.Rezerv;
   SendConfirmation:=PrevPredZakaz^.Dat.SendConfirmation;
   DateConfirmation :=PrevPredZakaz^.Dat.DateConfirmation;
   TimeConfirmation :=PrevPredZakaz^.Dat.TimeConfirmation;
   BN:=PrevPredZakaz^.Dat.Bn;
   Amount:=PrevPredZakaz^.Dat.Amount;
   Status:=PrevPredZakaz^.Dat.Status;
   sf:=PrevPredZakaz^.Dat.Sf;
   Caption:=StrToInt(PrevPredZakaz^.Dat.Caption);

  End;{With}
End;{Procedure}






Procedure PrihodToMarket(Var PrevMArket:PSuperMarketType;PrevZakaz:PPrihodType);
VAr Skl : PSkladType;
    BBB : PBazType;
    c : Word;
    NewProz: TDAteString;
Begin

 With PrevMarket^.Dat Do
  Begin
     OperatorSelector :=PrevZakaz^.DAt.OperatorSelector;
     DocSelector      :=3;
     DocumentComment  :=0;
     Caption:=PrevZakaz^.DAt.Caption;

     Versia:=0;
     SkidkaSelector :=1;
     ShkalaNumer:=0;

     Summaz:=PrevZakaz^.DAt.SummaR;
     Skidka:='0.00';
     SertifSummaz:='0.00';
     SertifSkidka:='0.00';

     ClientKod :='0020'{фармагентсвто};

     AgentKod :='0000'{самовывоз};
     EkspeditorKod:='0000';

     New(Skl,Init);
     New(BBB,Init);

     {перенос наименований}
     For c:=1 To PrevZakaz^.Dat.Amount Do
     Begin
     MarketElement[c].Bazkod:=PrevZakaz^.Dat.PrihodElement[c].BAzKod;

     With MarketElement[c].Input Do
      Begin
        Skl^.Dat.BazKod:=PrevZakaz^.Dat.PrihodElement[c].BAzKod;
        GetSkladRecord(Skl);
        GetBazElement(Skl^.Dat.BazKod,BBB^.Dat);
        Kol := PrevZakaz^.Dat.PrihodElement[c].Input.Kol;
        Skidka[0]:=#0;
        Proz[0]:=#0;

        Zena:=PrevZakaz^.Dat.PrihodElement[c].Input.R_Zena;
        R_Zena:=PrevZakaz^.Dat.PrihodElement[c].Input.R_Zena;
        O_Zena:=PrevZakaz^.Dat.PrihodElement[c].Input.O_Zena;
        DivisionNumber:=1;

        VidNDS  :=BBB^.Dat.VidNDS;
        NDS     :=BBB^.Dat.NDS;
        VidNalog   :=BBB^.Dat.VidNalog;
        SpecNalog  :=BBB^.Dat.Nalog;
        Last     :=False;
        NSertif  :=PrevZakaz^.Dat.PrihodElement[c].Input.NSertif;
        SertifKol:='0';
      End;{With}
     End;


     Dispose(Skl,Done);
     Dispose(BBB,Done);

     DateC   :=PrevZakaz^.DAt.DateC;
     TimeC   :=PrevZakaz^.DAt.TimeC;
     DateM   :=PrevZakaz^.DAt.DateM;
     TimeM   :=PrevZakaz^.DAt.TimeM;

   SkladKod  :=PrevZakaz^.DAt.SkladKod;
     Active  :=True;
     Amount  :=PrevZakaz^.DAt.Amount;
     Locked  :=PrevZakaz^.DAt.Locked;
     Rashet  :=0;
     FromZakaz[0]:=#0;
     Oformlenie:=0;
     {Comment[0]:=#0;}
  End;{With}
End;{Procedure}





Procedure MarketToZakaz(L:PSuperMarketType;Var Zakaz:PZakazType);
VAr Skl : PSkladType;
    BBB : PBazType;
    c : Word;
    NewProz: TDAteString;
Begin
 With Zakaz^.Dat Do
  Begin
     Caption :=L^.DAt.Caption;
     OperatorSelector :=L^.DAt.OperatorSelector;
     DocSelector      :=L^.DAt.DocSelector;
     DocumentComment  :=L^.DAt.DocumentComment;
     Versia:=L^.DAt.Versia;
     SkidkaSelector :=L^.DAt.SkidkaSelector;
     ShkalaNumer:=L^.DAt.ShkalaNumer;

     Summaz:=L^.DAt.SummaZ;
     Skidka:=L^.DAt.Skidka;
     SertifSummaz:=L^.DAt.SertifSummaZ;
     SertifSkidka:=L^.DAt.SertifSkidka;

     ClientKod :=L^.DAt.ClientKod;

     AgentKod :=L^.DAt.AgentKod;
     EkspeditorKod :=L^.DAt.EkspeditorKod;

     New(Skl,Init);
     New(BBB,Init);

     {перенос наименований}
     For c:=1 To L^.Dat.Amount Do
     Begin
     MarketElement[c].Bazkod:=L^.Dat.MarketElement[c].BAzKod;
     With MarketElement[c].Input Do
      Begin
        Version:=L^.Dat.MarketElement[c].Input.Version;
        Skl^.Dat.BazKod:=L^.Dat.MarketElement[c].BAzKod;
        GetSkladRecord(Skl);
        GetBazElement(Skl^.Dat.BazKod,BBB^.Dat);
        Kol := L^.Dat.MarketElement[c].Input.Kol;
        Skidka:=L^.Dat.MarketElement[c].Input.Skidka;
        Zena    :=L^.Dat.MarketElement[c].Input.Zena;
        Proz    :=L^.Dat.MarketElement[c].Input.Proz;
        InputDivision:=L^.Dat.MarketElement[c].Input.DivisionNumber;
        NSertif  :=L^.Dat.MarketElement[c].Input.NSertif;
        SertifKol:=L^.Dat.MarketElement[c].Input.SertifKol;

       MarkaKod :=L^.Dat.MarketElement[c].Input.MarkaKod;
       SMarkaKod:=L^.Dat.MarketElement[c].Input.SMarkaKod;
       NGTDKod  :=L^.Dat.MarketElement[c].Input.NGTDKod;
       ExpertKod:=L^.Dat.MarketElement[c].Input.ExpertKod;
       Srok     :=L^.Dat.MarketElement[c].Input.Srok;
     Virabotano :=L^.Dat.MarketElement[c].Input.Virabotano;

      End;{With}
     End;

     {перенос сертификатов}
     For c:=1 To L^.Dat.AmountS Do
     Begin
     DocumentElement[c].Bazkod:=L^.Dat.DocumentElement[c].BAzKod;
     With DocumentElement[c].Input Do
      Begin
        Version:=L^.Dat.DocumentElement[c].Input.Version;

        Skl^.Dat.BazKod:=L^.Dat.DocumentElement[c].BAzKod;

        GetSkladRecord(Skl);
        GetBazElement(Skl^.Dat.BazKod,BBB^.Dat);

        Kol     :=L^.Dat.DocumentElement[c].Input.Kol;

        Skidka:=L^.Dat.DocumentElement[c].Input.Skidka;

        Zena    :=L^.Dat.DocumentElement[c].Input.Zena;

        Proz    :='0.00';


        InputDivision:=L^.Dat.DocumentElement[c].Input.DivisionNumber;
        NSertif  :=L^.Dat.DocumentElement[c].Input.NSertif;
        SertifKol:=L^.Dat.DocumentElement[c].Input.SertifKol;
      End;
     End;

     Dispose(Skl,Done);
     Dispose(BBB,Done);

     DateC   :=L^.DAt.DateC;
     TimeC   :=L^.DAt.TimeC;
     DateM   :=L^.DAt.DateM;
     TimeM   :=L^.DAt.TimeM;

   SkladKod  :=L^.DAt.SkladKod;

     {пересчет срок отсрочки платежа от накладной к Заказу}
     Srok    :=L^.DAt.Srok;{-DateStringToDate(DAteMask,L^.Dat.DateC)};




     Amount  :=L^.DAt.Amount;
(**) AmountS :=L^.DAt.AmountS;
     Locked  :=L^.DAt.Locked;
     Rashet  :=L^.DAt.Rashet;
     {Comment :=L^.DAt.Comment;}
  End;{With}
End;{Procedure}


Procedure MarketToIndex(PrevZakaz:PSuperMArketType;Var PrevMarket:PSuperMarketTypeIDX);
Var c : Word;
    SOpl,SAkzis,SSkidka,SZakupka,SZakupka2 : AllStr;
Begin
   With PrevMarket^.Dat Do
    Begin
     Realiz  :=PrevZakaz^.Dat.Realiz;
     Document:=PrevZakaz^.Dat.Document;

     SummaZ:=StrToReal(PrevZakaz^.Dat.SummaZ);
     SummaAkzis:=StrToReal(PrevZakaz^.Dat.SummaAkzis);
     SummaZakupka:=StrToReal(PrevZakaz^.Dat.SummaZakupka);
     SummaZakupka2:=StrToReal(PrevZakaz^.Dat.SummaZakupka2);
     Skidka:=StrToReal(PrevZakaz^.Dat.Skidka);
     Otkat:=PrevZakaz^.Dat.Otkat;
     ENalog:=StrToReal(PrevZakaz^.Dat.ENalog);

{здесь надо вставить код расчета сумм по отделениям}
     With PrevZakaz^.Dat Do
     Begin
      For c:=1 To Amount Do
      Begin
       {считаем цену к оплате}
       If SkidkaSelector in [0,2] Then
         MyStr(StrToReal(MarketElement[c].Input.Zena)/
         (1+StrToReal(MarketElement[c].Input.Proz)/100),CZena,CMantissa,SOpl)
         Else
         MyStr(StrToReal(MarketElement[C].Input.Zena)-
               StrToReal(MarketElement[C].Input.Skidka),CZena,CMantissa,SOpl);
       {ситаем величну скидки}
         MyStr(StrToReal(MarketElement[C].Input.Zena)-StrToReal(SOpl),
	           CZena,CMantissa,SSkidka);

         MSummaZ[MarketElement[C].Input.DivisionNumber]:=
	    MSummaZ[MarketElement[C].Input.DivisionNumber]+StrToReal(SOpl)*
	    StrToInt(MarketElement[C].Input.Kol);

         MSkidka[MarketElement[C].Input.DivisionNumber]:=
	    MSkidka[MarketElement[C].Input.DivisionNumber]+StrToReal(SSkidka)*
	    StrToInt(MarketElement[C].Input.Kol);

         MSummaZakupka[MarketElement[C].Input.DivisionNumber]:=
	    MSummaZakupka[MarketElement[C].Input.DivisionNumber]+
	    StrToReal(MarketElement[C].Input.Zakupka)*
	    StrToInt(MarketElement[C].Input.Kol);

         MSummaZakupka2[MarketElement[C].Input.DivisionNumber]:=
	    MSummaZakupka2[MarketElement[C].Input.DivisionNumber]+
	    StrToReal(MarketElement[C].Input.Zakupka2)*
	    StrToInt(MarketElement[C].Input.Kol);
      End;{For}

      For c:=1 To AmountS Do
      Begin
       {считаем цену к оплате}
       If SkidkaSelector in [0,2] Then
         MyStr(StrToReal(DocumentElement[c].Input.Zena)/
         (1+StrToReal(DocumentElement[c].Input.Proz)/100),CZena,CMantissa,SOpl)
         Else
         MyStr(StrToReal(DocumentElement[C].Input.Zena)-
               StrToReal(DocumentElement[C].Input.Skidka),CZena,CMantissa,SOpl);
       {ситаем величну скидки}
         MyStr(StrToReal(DocumentElement[C].Input.Zena)-StrToReal(SOpl),
	           CZena,CMantissa,SSkidka);

         MSSummaZ[DocumentElement[C].Input.DivisionNumber]:=
	    MSSummaZ[DocumentElement[C].Input.DivisionNumber]+StrToReal(SOpl)*
	    StrToInt(DocumentElement[C].Input.Kol);

         MSSkidka[DocumentElement[C].Input.DivisionNumber]:=
	    MSSkidka[DocumentElement[C].Input.DivisionNumber]+StrToReal(SSkidka)*
	    StrToInt(DocumentElement[C].Input.Kol);

         MSSummaZakupka[DocumentElement[C].Input.DivisionNumber]:=
	    MSSummaZakupka[DocumentElement[C].Input.DivisionNumber]+
	    StrToReal(DocumentElement[C].Input.Zakupka)*
	    StrToInt(DocumentElement[C].Input.Kol);

         MSSummaZakupka2[DocumentElement[C].Input.DivisionNumber]:=
	    MSSummaZakupka2[DocumentElement[C].Input.DivisionNumber]+
	    StrToReal(DocumentElement[C].Input.Zakupka2)*
	    StrToInt(DocumentElement[C].Input.Kol);
      End;{For}
     End;{With}
{конец этого чудесного кода}

     SertifSummaZ:=StrToReal(PrevZakaz^.Dat.SertifSummaZ);
     SertifSummaZakupka:=StrToReal(PrevZakaz^.Dat.SertifSummaZakupka);
     SertifSummaZakupka2:=StrToReal(PrevZakaz^.Dat.SertifSummaZakupka2);
     SertifSkidka:=StrToReal(PrevZakaz^.Dat.SertifSkidka);
     Caption:=PrevZakaz^.Dat.Caption;
     Active:=PrevZakaz^.Dat.Active;
     ShkalaNumer:=PrevZakaz^.Dat.ShkalaNumer;
     Processing:=PrevZakaz^.Dat.Processing;
     DateC:=DateStringToDAte(DateMask,PrevZakaz^.Dat.DateC);
     TimeC:=TiMeStringToTime('hh:mm:ss',PrevZakaz^.Dat.TimeC);
     DateM:=DateStringToDAte(DateMask,PrevZakaz^.Dat.DateM);
     TimeM:=TiMeStringToTime('hh:mm:ss',PrevZakaz^.Dat.TimeM);
     SkladKod:=FormKod(Rek^.Dat.Kod);
     OperatorSelector:=PrevZakaz^.Dat.OperatorSelector;
     DocSelector :=PrevZakaz^.Dat.DocSelector;
     SkidkaSelector :=PrevZakaz^.Dat.SkidkaSelector;
     Versia :=PrevZakaz^.Dat.Versia;
     ClientKod:=PrevZakaz^.Dat.ClientKod;
     AgentKod:=PrevZakaz^.Dat.AgentKod;
     EkspeditorKod:=PrevZakaz^.Dat.EkspeditorKod;
     Rashet:=PrevZakaz^.Dat.Rashet;
     Oformlenie :=PrevZakaz^.Dat.Oformlenie;
     FromZakaz:=PrevZakaz^.Dat.FromZakaz;
     Exporting :=PrevZakaz^.Dat.Exporting;
    End;{With}
End;{Procedure}




Function WriteZakazToSkladFile(L:PZakazType) : Boolean;
Var SkladFile : File Of SkladType;
    KdxFile : File Of SkladTypeNew;
    Sklad : PSkladType;
    Kdx   : PSkladTypeNew;
    i,p,j : Byte;
    s1 : TEnjoyStr;

Begin
WriteZakazToSkladFile:=False;
If Status=DocEdit Then
Begin
 {товар}
 For i:=1 To PrevMarket^.Dat.Amount{J} Do
  Begin
   New(Sklad,Init);
   New(Kdx,Init);
   S1:=Copy(PrevMarket^.Dat.MarketElement[i].BazKod,1,CRazdelKod);

   Assign(SkladFile,Path^.Dat.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;

   Assign(KdxFile,Path^.Dat.ToIndex+s1+'.kdx');
   p:=IOResult;
   Reset(KdxFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     Close(SkladFile);
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.kdx!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;


   Seek(SkladFile,GetFileLocation3(Copy(PrevMarket^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   Seek(KdxFile,GetFileLocation3(Copy(PrevMarket^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));


   Repeat
   Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Sklad^.Dat);
   Read(KdxFile,Kdx^.Dat);

   With Sklad^.Dat.Input Do
   Begin
     Caption:=PrevMarket^.Dat.Caption;
     DelSpace(PrevMarket^.Dat.MarketElement[i].Input.Kol);
     Sklad^.Dat.Date := DateStringToDate(DAteMask,TekDate);
     Sklad^.Dat.Time := CurrentTime;

     Str((StrToInt(DiviSionR[PrevMarket^.Dat.MarketElement[i].Input.DiviSionNumber])
     -StrToInt(PrevMarket^.Dat.MarketElement[i].input.kol)):
     CKol,DivisionR[PrevMarket^.Dat.MarketElement[i].InPut.DiviSionNumber]);

     If StrToInt(DivisionR[PrevMarket^.Dat.MarketElement[i].InPut.DiviSionNumber])<0 Then
     DivisionR[PrevMarket^.Dat.MarketElement[i].InPut.DiviSionNumber]:='0';

     KolR[0]:=#0;
     For p:=1 To CDiviSion Do
     Str((StrToInt(KolR)+StrToInt(DivisionR[p])):CKol,KolR);
   End;


        With Kdx^.DAt Do
        Begin
         Employ:=True;
         BazKod  :=StrToInt(Sklad^.Dat.BazKod);
         {
         NSertif :=StrToInt(Sklad^.Dat.Input.NSertif);
         NMakeKod:=StrToInt(Sklad^.Dat.Input.NMakeKod);
         NGroupKod:=StrToInt(Sklad^.Dat.Input.NGroupKod);
         StrihKod:=Sklad^.Dat.Input.StrihKod;
         }
         Zakupka:=StrToReal(Sklad^.Dat.Input.Zakupka);
         Zakupka2:=StrToReal(Sklad^.Dat.Input.Zakupka2);
         AkzisSbor:=StrToReal(Sklad^.Dat.Input.AkzisSbor);
         Kol:=StrToInt(Sklad^.Dat.Input.Kol);
         RegionMarka:=Sklad^.Dat.Input.RegionMarka;
         For j:=1 To CDivision Do Division[j]:=StrToInt(Sklad^.Dat.Input.Division[j]);
         For j:=1 To CDivision Do DivisionR[j]:=StrToInt(Sklad^.Dat.Input.DivisionR[j]);
         R_Zena  :=StrToReal(Sklad^.Dat.Input.R_Zena);
        End;



   Seek(SkladFile,GetFileLocation3(Copy(PrevMarket^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(SkladFile,Sklad^.Dat);

   Seek(KdxFile,GetFileLocation3(Copy(PrevMarket^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(KdxFile,Kdx^.Dat);

   Seek(SkladFile,FilePos(SkladFile)-1);

   Repeat
    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

   Close(SkladFile);
   Close(KdxFile);
   Dispose(Kdx,Done);
  End;
 {товар}

 For i:=1 To PrevMarket^.Dat.AmountS{J} Do
  Begin
   New(Sklad,Init);
   New(Kdx,Init);
   S1:=Copy(PrevMarket^.Dat.DocumentElement[i].BazKod,1,CRazdelKod);

   Assign(SkladFile,Path^.Dat.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;

   Assign(KdxFile,Path^.Dat.ToIndex+s1+'.kdx');
   p:=IOResult;
   Reset(KdxFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     Close(SkladFile);
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.kdx!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;


   Seek(SkladFile,GetFileLocation3(Copy(PrevMarket^.Dat.DocumentElement[i].BazKod,CRazdelKod+1,CKod)));
   Seek(KdxFile,GetFileLocation3(Copy(PrevMarket^.Dat.DocumentElement[i].BazKod,CRazdelKod+1,CKod)));

   Repeat
   Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Sklad^.Dat);
   Read(KdxFile,Kdx^.Dat);

   With Sklad^.Dat.Input Do
   Begin
     Caption:=PrevMarket^.Dat.Caption;
     DelSpace(PrevMarket^.Dat.DocumentElement[i].Input.Kol);
     Sklad^.Dat.Date := DateStringToDate(DateMask,TekDate);
     Sklad^.Dat.Time := CurrentTime;

     Str((StrToInt(DiviSionR[PrevMarket^.Dat.DocumentElement[i].Input.DiviSionNumber])
     -StrToInt(PrevMarket^.Dat.DocumentElement[i].input.kol)):
     CKol,DivisionR[PrevMarket^.Dat.DocumentElement[i].InPut.DiviSionNumber]);

     If StrToInt(DivisionR[PrevMarket^.Dat.DocumentElement[i].InPut.DiviSionNumber])<0 Then
     DivisionR[PrevMarket^.Dat.DocumentElement[i].InPut.DiviSionNumber]:='0';

     KolR[0]:=#0;
     For p:=1 To CDiviSion Do
     Str((StrToInt(KolR)+StrToInt(DivisionR[p])):CKol,KolR);
   End;

        With Kdx^.DAt Do
        Begin
         Employ:=True;
         BazKod  :=StrToInt(Sklad^.Dat.BazKod);
         {
         NSertif :=StrToInt(Sklad^.Dat.Input.NSertif);
         StrihKod:=Sklad^.Dat.Input.StrihKod;
         NMakeKod:=StrToInt(Sklad^.Dat.Input.NMakeKod);
         NGroupKod:=StrToInt(Sklad^.Dat.Input.NGroupKod);
         }
         Kol:=StrToInt(Sklad^.Dat.Input.Kol);
         RegionMarka:=Sklad^.Dat.Input.RegionMarka;

         Zakupka:=StrToReal(Sklad^.Dat.Input.Zakupka);
         Zakupka2:=StrToReal(Sklad^.Dat.Input.Zakupka2);
         AkzisSbor:=StrToReal(Sklad^.Dat.Input.AkzisSbor);

         For j:=1 To CDivision Do Division[j]:=StrToInt(Sklad^.Dat.Input.Division[j]);
         For j:=1 To CDivision Do DivisionR[j]:=StrToInt(Sklad^.Dat.Input.DivisionR[j]);
         R_Zena  :=StrToReal(Sklad^.Dat.Input.R_Zena);
        End;


   Seek(SkladFile,GetFileLocation3(Copy(PrevMarket^.Dat.DocumentElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(SkladFile,Sklad^.Dat);

   Seek(KdxFile,GetFileLocation3(Copy(PrevMarket^.Dat.DocumentElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(KdxFile,Kdx^.Dat);

   Seek(SkladFile,FilePos(SkladFile)-1);

   Repeat
    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

   Close(SkladFile);
   Dispose(Sklad,Done);
   Close(KdxFile);
   Dispose(Kdx,Done);
  End;
End;



 {товар}
 For i:=1 To L^.DAt.Amount{J} Do
  Begin
   New(Sklad,Init);
   New(Kdx,Init);
   S1:=Copy(L^.Dat.MArketElement[i].BazKod,1,CRazdelKod);

   Assign(SkladFile,Path^.Dat.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;

   Assign(KdxFile,Path^.Dat.ToIndex+s1+'.kdx');
   p:=IOResult;
   Reset(KdxFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     Close(SkladFile);
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.kdx!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;

   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   Seek(KdxFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));


   Repeat
   Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Sklad^.Dat);
   Read(KdxFile,Kdx^.Dat);

   With Sklad^.Dat.Input Do
   Begin
     Caption:=L^.Dat.Caption;
     DelSpace(L^.Dat.MarketElement[i].Input.Kol);
     Sklad^.Dat.Date := DateStringToDate(DateMAsk,TekDate);
     Sklad^.Dat.Time := CurrentTime;

     Str((StrToInt(DiviSionR[L^.Dat.MarketElement[i].Input.InputDivision])+
        StrToInt(L^.Dat.MarketElement[i].Input.Kol))
     :CKol,DivisionR[L^.Dat.MarketElement[i].InPut.InputDivision]);
     KolR[0]:=#0;
     For p:=1 To CDiviSion Do
     Str((StrToInt(KolR)+StrToInt(DivisionR[p])):CKol,KolR);
   End;

        With Kdx^.DAt Do
        Begin
         Employ:=True;
         BazKod  :=StrToInt(Sklad^.Dat.BazKod);
         {
         NSertif :=StrToInt(Sklad^.Dat.Input.NSertif);
         NMakeKod:=StrToInt(Sklad^.Dat.Input.NMakeKod);
         NGroupKod:=StrToInt(Sklad^.Dat.Input.NGroupKod);
         StrihKod:=Sklad^.Dat.Input.StrihKod;
         }
         Kol:=StrToInt(Sklad^.Dat.Input.Kol);
         RegionMarka:=Sklad^.Dat.Input.RegionMarka;
         Zakupka:=StrToReal(Sklad^.Dat.Input.Zakupka);
         Zakupka2:=StrToReal(Sklad^.Dat.Input.Zakupka2);
         AkzisSbor:=StrToReal(Sklad^.Dat.Input.AkzisSbor);
         For j:=1 To CDivision Do Division[j]:=StrToInt(Sklad^.Dat.Input.Division[j]);
         For j:=1 To CDivision Do DivisionR[j]:=StrToInt(Sklad^.Dat.Input.DivisionR[j]);
         R_Zena  :=StrToReal(Sklad^.Dat.Input.R_Zena);
        End;


   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(SkladFile,Sklad^.Dat);

   Seek(KdxFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(KdxFile,Kdx^.Dat);

   Seek(SkladFile,FilePos(SkladFile)-1);

   Repeat
    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

   Close(SkladFile);
   Dispose(Sklad,Done);

   Close(KdxFile);
   Dispose(Kdx,Done);
  End;

{сертификаты}
 For i:=1 To L^.DAt.AmountS{J} Do
  Begin
   New(Sklad,Init);
   New(Kdx,Init);
   S1:=Copy(L^.Dat.DocumentElement[i].BazKod,1,CRazdelKod);

   Assign(SkladFile,Path^.Dat.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;

   Assign(KdxFile,Path^.Dat.ToIndex+s1+'.kdx');
   p:=IOResult;
   Reset(KdxFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     Close(SkladFile);
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.kdx!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;

   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.DocumentElement[i].BazKod,CRazdelKod+1,CKod)));
   Seek(KdxFile,GetFileLocation3(Copy(L^.Dat.DocumentElement[i].BazKod,CRazdelKod+1,CKod)));


   Repeat
   Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Sklad^.Dat);
   Read(KdxFile,Kdx^.Dat);

   With Sklad^.Dat.Input Do
   Begin
     Caption:=L^.Dat.Caption;
     DelSpace(L^.Dat.DocumentElement[i].Input.Kol);
     Sklad^.Dat.Date := DateStringToDAte(DateMask,TekDate);
     Sklad^.Dat.Time := CurrentTime;
     Str((StrToInt(DiviSionR[L^.Dat.DocumentElement[i].Input.InputDiviSion])+
        StrToInt(L^.Dat.DocumentElement[i].Input.Kol))
     :CKol,DivisionR[L^.Dat.DocumentElement[i].InPut.InputDiviSion]);
     KolR[0]:=#0;
     For p:=1 To CDiviSion Do
     Str((StrToInt(KolR)+StrToInt(DivisionR[p])):CKol,KolR);
   End;

        With Kdx^.DAt Do
        Begin
         Employ:=True;
         BazKod  :=StrToInt(Sklad^.Dat.BazKod);
         {
         NSertif :=StrToInt(Sklad^.Dat.Input.NSertif);
         NMakeKod:=StrToInt(Sklad^.Dat.Input.NMakeKod);
         NGroupKod:=StrToInt(Sklad^.Dat.Input.NGroupKod);
         StrihKod:=Sklad^.Dat.Input.StrihKod;
         }
         Kol:=StrToInt(Sklad^.Dat.Input.Kol);
         RegionMarka:=Sklad^.Dat.Input.RegionMarka;
         Zakupka:=StrToReal(Sklad^.Dat.Input.Zakupka);
         Zakupka2:=StrToReal(Sklad^.Dat.Input.Zakupka2);
         AkzisSbor:=StrToReal(Sklad^.Dat.Input.AkzisSbor);
         For j:=1 To CDivision Do Division[j]:=StrToInt(Sklad^.Dat.Input.Division[j]);
         For j:=1 To CDivision Do DivisionR[j]:=StrToInt(Sklad^.Dat.Input.DivisionR[j]);
         R_Zena  :=StrToReal(Sklad^.Dat.Input.R_Zena);
        End;

   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.DocumentElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(SkladFile,Sklad^.Dat);

   Seek(KdxFile,GetFileLocation3(Copy(L^.Dat.DocumentElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(KdxFile,Kdx^.Dat);

   Seek(SkladFile,FilePos(SkladFile)-1);

   Repeat
    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

   Close(SkladFile);
   Dispose(Sklad,Done);
   Close(KdxFile);
   Dispose(Kdx,Done);
  End;
WriteZakazToSkladFile:=True;
End;




Function DeleteZakazFromSkladFile(L:PZakazType) : Boolean;
Var SkladFile : File Of SkladType;
    KdxFile : File Of SkladTypeNew;
    Sklad : PSkladType;
    Kdx   : PSkladTypeNew;
    i,p,j : Byte;
    s1 : TEnjoyStr;

Begin
DeleteZakazFromSkladFile:=False;
 {товар}
 For i:=1 To L^.DAt.Amount{J} Do
  Begin
   New(Sklad,Init);
   New(Kdx,Init);
   S1:=Copy(L^.Dat.MArketElement[i].BazKod,1,CRazdelKod);

   Assign(SkladFile,Path^.Dat.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;

   Assign(KdxFile,Path^.Dat.ToIndex+s1+'.kdx');
   p:=IOResult;
   Reset(KdxFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     Close(SkladFile);
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;

   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   Seek(KdxFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));


   Repeat
   Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Sklad^.Dat);
   Read(KdxFile,Kdx^.Dat);

   With Sklad^.Dat.Input Do
   Begin
     Caption:=L^.Dat.Caption;
     DelSpace(L^.Dat.MarketElement[i].Input.Kol);
     Sklad^.Dat.Date := DateStringToDAte(DateMask,TekDate);
     Sklad^.Dat.Time := CurrentTime;

     Str((StrToInt(DiviSionR[L^.Dat.MarketElement[i].Input.InputDivision])-
        StrToInt(L^.Dat.MarketElement[i].Input.Kol))
     :CKol,DivisionR[L^.Dat.MarketElement[i].InPut.InputDivision]);

     If StrToInt(DivisionR[L^.Dat.MarketElement[i].InPut.InputDivision])<0 Then
     DivisionR[L^.Dat.MarketElement[i].InPut.InputDivision]:='0';

     KolR[0]:=#0;
     For p:=1 To CDiviSion Do
     Str((StrToInt(KolR)+StrToInt(DivisionR[p])):CKol,KolR);
   End;

        With Kdx^.DAt Do
        Begin
         Employ:=True;
         BazKod  :=StrToInt(Sklad^.Dat.BazKod);
         {
         NSertif :=StrToInt(Sklad^.Dat.Input.NSertif);
         StrihKod:=Sklad^.Dat.Input.StrihKod;
         NMakeKod:=StrToInt(Sklad^.Dat.Input.NMakeKod);
         NGroupKod:=StrToInt(Sklad^.Dat.Input.NGroupKod);
         }
         Kol:=StrToInt(Sklad^.Dat.Input.Kol);
         RegionMarka:=Sklad^.Dat.Input.RegionMarka;

         Zakupka:=StrToReal(Sklad^.Dat.Input.Zakupka);
         Zakupka2:=StrToReal(Sklad^.Dat.Input.Zakupka2);
         AkzisSbor:=StrToReal(Sklad^.Dat.Input.AkzisSbor);

         For j:=1 To CDivision Do Division[j]:=StrToInt(Sklad^.Dat.Input.Division[j]);
         For j:=1 To CDivision Do DivisionR[j]:=StrToInt(Sklad^.Dat.Input.DivisionR[j]);
         R_Zena  :=StrToReal(Sklad^.Dat.Input.R_Zena);
        End;



   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(SkladFile,Sklad^.Dat);

   Seek(KdxFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(KdxFile,Kdx^.Dat);

   Seek(SkladFile,FilePos(SkladFile)-1);

   Repeat
    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

   Close(SkladFile);
   Dispose(Sklad,Done);
   Close(KdxFile);
   Dispose(Kdx,Done);
  End;

{сертификаты}
 For i:=1 To L^.DAt.AmountS{J} Do
  Begin
   New(Sklad,Init);
   New(Kdx,Init);
   S1:=Copy(L^.Dat.DocumentElement[i].BazKod,1,CRazdelKod);

   Assign(SkladFile,Path^.Dat.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;

   Assign(KdxFile,Path^.Dat.ToIndex+s1+'.kdx');
   p:=IOResult;
   Reset(KdxFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     Close(SkladFile);
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.kdx!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Dispose(Kdx,Done);
     Exit;
    End;


   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.DocumentElement[i].BazKod,CRazdelKod+1,CKod)));
   Seek(KdxFile,GetFileLocation3(Copy(L^.Dat.DocumentElement[i].BazKod,CRazdelKod+1,CKod)));

   Repeat
   Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Sklad^.Dat);
   Read(KdxFile,Kdx^.Dat);

   With Sklad^.Dat.Input Do
   Begin
     Caption:=L^.Dat.Caption;
     DelSpace(L^.Dat.DocumentElement[i].Input.Kol);
     Sklad^.Dat.Date := DateStringToDAte(DateMask,TekDate);
     Sklad^.Dat.Time := CurrentTime;
     Str((StrToInt(DiviSionR[L^.Dat.DocumentElement[i].Input.InputDiviSion])-
        StrToInt(L^.Dat.DocumentElement[i].Input.Kol))
     :CKol,DivisionR[L^.Dat.DocumentElement[i].InPut.InputDiviSion]);

     If StrToInt(DivisionR[L^.Dat.DocumentElement[i].InPut.InputDivision])<0 Then
     DivisionR[L^.Dat.DocumentElement[i].InPut.InputDivision]:='0';

     KolR[0]:=#0;
     For p:=1 To CDiviSion Do
     Str((StrToInt(KolR)+StrToInt(DivisionR[p])):CKol,KolR);
   End;

        With Kdx^.DAt Do
        Begin
         Employ:=True;
         BazKod  :=StrToInt(Sklad^.Dat.BazKod);
         {
         NSertif :=StrToInt(Sklad^.Dat.Input.NSertif);
         NMakeKod:=StrToInt(Sklad^.Dat.Input.NMakeKod);
         NGroupKod:=StrToInt(Sklad^.Dat.Input.NGroupKod);
         StrihKod:=Sklad^.Dat.Input.StrihKod;
         }
         Kol:=StrToInt(Sklad^.Dat.Input.Kol);
         RegionMarka:=Sklad^.Dat.Input.RegionMarka;

         Zakupka:=StrToReal(Sklad^.Dat.Input.Zakupka);
         Zakupka2:=StrToReal(Sklad^.Dat.Input.Zakupka2);
         AkzisSbor:=StrToReal(Sklad^.Dat.Input.AkzisSbor);

         For j:=1 To CDivision Do Division[j]:=StrToInt(Sklad^.Dat.Input.Division[j]);
         For j:=1 To CDivision Do DivisionR[j]:=StrToInt(Sklad^.Dat.Input.DivisionR[j]);
         R_Zena  :=StrToReal(Sklad^.Dat.Input.R_Zena);
        End;



   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.DocumentElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(SkladFile,Sklad^.Dat);

   Seek(KdxFile,GetFileLocation3(Copy(L^.Dat.DocumentElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(KdxFile,Kdx^.Dat);

   Seek(SkladFile,FilePos(SkladFile)-1);

   Repeat
    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

   Close(SkladFile);
   Dispose(Sklad,Done);
   Close(KdxFile);
   Dispose(Kdx,Done);
  End;
DeleteZakazFromSkladFile:=True;
End;




Procedure Average(DDD : TKolString;BakKol,BAkZena,NewKol,NewZena:AllStr; VAr AverageZena:AllStr);
VAr c : Word;
Begin
CAse VidZakupka Of
{последняя закупка}
0:Begin
   MyStr(StrToReal(NewZena),CZenaZ,CMantissaZ,AverageZena);
   DelSpace(AverageZena);
  End;
{средневзвешенная закупка}
1:Begin
    If EnableAverageOtdel<>0 Then
    Begin
     BakKol[0]:=#0;
     For c:=1 To CDivision Do
      Begin
       If c in SetEnableOtdel Then
        Begin
         Str(StrToInt(BAkKol)+StrToInt(DDD[c]):CKol,BAkKol);
        End;
      End;
     DelSpace(BakKol);
    End;

    If (StrToInt(NewKol)+StrToInt(BakKol))>0 Then
    Begin
     MyStr(((StrToInt(NewKol)*StrToReal(NewZena)+
         StrToInt(BakKol)*StrToReal(BakZena))/(StrToInt(NewKol)+StrToInt(BakKol))),
            CZenaZ,CMantissaZ,AverageZena)
    End
    Else
    MyStr(StrToReal(NewZena),CZenaZ,CMantissaZ,AverageZena);
    DelSpace(AverageZena);
  End;
{оставить старую закупку}
2:Begin
   MyStr(StrToReal(BakZena),CZenaZ,CMantissaZ,AverageZena);
   DelSpace(AverageZena);
  End;
Else;
End;
End;






Procedure SortNKL (Var L:PSuperMarketType);
Var i : Word;
    R : TRect;
    E : PSuperMarketType;
    Wl,Wk,Wn : AllStr;
    SS1,SS2 : AllStr;
    S : String;
    Key : String;
    OSD,TempBox : PBox;
    Itogo : AllStr;
Begin
 R.Assign(0, 0, 0, 0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));

 OSD := New(PBox, Init(R, 1, Nil));
 OSD^.NewList(New(PTextCollection, Init(0,1)));

 For i :=1 To L^.Dat.Amount Do
  Begin
   With L^.Dat.MarketElement[i].Input Do
   Begin
   Format(Kol,CKol);
        Format(Zena,CZena);
   Format(Skidka,CZena);
   {Format(Itogo,CInputIZena);}

   MyStr(StrToReal(R_Zena)*
   StrToInt(Kol),CInputIZena,CMantissa,Itogo);


   Format(R_Zena,CZena);
   Format(O_Zena,CZena);
   Format(Proz,CLitr);
   Format(SpecNalog,CLitr);
   Format(NDS,CLitr);
   Format(Zakupka,CZenaZ);
   Format(Zakupka2,CZenaZ);
   Format(AkzisSbor,CZenaZ);
   Format(ZenaMArki,CZenaZ);
   RFormat(SertifKol,CKol);
   DelSpace(NSertif);
   If NSertif[0]=#0 Then NSertif:=Glob.NoSertifStr;
   Wk := Copy(L^.Dat.MarketElement[i].BazKod,1,CRazdelKod);
   Wn := GetIdField(FName,L^.Dat.MarketElement[i].BazKod);
   Wl := GetIdField(FLitr,L^.Dat.MarketElement[i].BazKod);
   Format (wn,CName);
   Str(L^.Dat.MarketElement[i].Input.DivisionNumber:COne,s);

   Key[0]:=#0;

   Case SortOtgruzka Of
    0:Key:=wn{наименование}+'│'+s{Div}+'│'+wk{разд};
    1:Key:=s{Div}+'│'+wn{наименование}+'│'+wk{разд};
    2:Key:=wk{разд}+'│'+wn{наименование}+'│'+s{Div};
    3:Key:=wk{разд}+'│'+s{Div}+'│'+wn{наименование};
    4:Key[0]:=#0;
    Else
      Key:=s{Div}+'│'+wn{наименование}+'│'+wk{разд};
    End;


   s:=Key+' '{s}+
   '│'+wk+{код раздела}
   '│'+Wn+{первая часть наименования}
   '│'+L^.Dat.MarketElement[i].BazKod+
   '│'+L^.Dat.MarketElement[i].Input.Kol+
   '│'+Wl+{литраж}
   '│'+L^.Dat.MarketElement[i].Input.Zena+
   '│'+L^.Dat.MarketElement[i].Input.Skidka+
   '│'+L^.Dat.MarketElement[i].Input.R_Zena+
   '│'+L^.Dat.MarketElement[i].Input.O_Zena+
   '│'+Itogo+
   '│'+L^.Dat.MarketElement[i].Input.Proz+
   '│'+L^.Dat.MarketElement[i].Input.SpecNalog+
   '│'+IntToStr(VidNalog,COne)+
   '│'+L^.Dat.MarketElement[i].Input.Nds+
   '│'+IntToStr(VidNDS,COne)+
   '│'+L^.Dat.MarketElement[i].Input.Zakupka+
   '│'+L^.Dat.MarketElement[i].Input.Zakupka2+
   '│'+IntToStr(L^.Dat.MarketElement[i].Input.RegionMArka,COne)+
   '│'+L^.DAt.MArketElement[i].Input.AkzisSbor+
   '│'+L^.Dat.MArketElement[i].Input.ZenaMArki+
   '│'+L^.Dat.MarketElement[i].Input.NSertif+
   '│'+L^.Dat.MarketElement[i].Input.SertifKol+
   '│'+s{отделение};
   TempBox^.List^.Insert(NewStr(s));
   TempBox^.SetRange(TempBox^.List^.Count);


    {список параметров ОСД в накладной}
    If (TestElement(L^.Dat.MarketElement[i].BazKod,OSD)) Then
    Begin
     RFormatZerro(L^.Dat.MarketElement[i].Input.MarkaKod,CArtikul);
     RFormatZerro(L^.Dat.MarketElement[i].Input.SMarkaKod,CArtikul);
     RFormatZerro(L^.Dat.MarketElement[i].Input.NGTDKod,CArtikul);
     RFormatZerro(L^.Dat.MarketElement[i].Input.ExpertKod,CArtikul);
     SS1:=IntToStr(L^.Dat.MarketElement[i].Input.Srok,CDate);
     Format(SS1,CDAte);

     SS2:=IntToStr(L^.Dat.MarketElement[i].Input.Virabotano,CDate);
     Format(SS2,CDAte);

     s:='│'+L^.Dat.MarketElement[i].BazKod+'│'+
            L^.Dat.MarketElement[i].Input.MarkaKod+'│'+
            L^.Dat.MarketElement[i].Input.SMarkaKod+'│'+
            L^.Dat.MarketElement[i].Input.NGTDKod+'│'+
            L^.Dat.MarketElement[i].Input.ExpertKod+'│'+
		  SS1+'│'+SS2;
    OSD^.List^.Insert(NewStr(s));
    OSD^.SetRange(OSD^.List^.Count);
   End;



   End;{With}
  End;{For}


  New(E,Init);
  E^.Dat:=L^.Dat;

If (TempBox^.List^.Count)>0 Then
For i:=0 To TempBox^.List^.Count-1 Do
 Begin
  s:=TempBox^.GetText(i,TempBox^.List^.Count);
{для новой структуры стороки}
  E^.Dat.MarketElement[i+1].BazKod:=Copy(s,Ord(Key[0])+1+COne+1+CRazdelKod+1+CName+1,CArtikul);
  With E^.Dat.MarketElement[i+1].Input Do
   Begin
   {NDS:=BakGetField(FNds,E^.Dat.MarketElement[i+1].BazKod,0);
    DelSpace(Nds);}
    Kol:=Copy(s,Ord(Key[0])+1+COne+1+CName+1+CArtikul+1+CRazdelKod+1,CKol);
    DelSpace(Kol);
    Zena:=Copy(s,Ord(Key[0])+1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CRazdelKod+1,CZena);
    DelSpace(Zena);
    Skidka:=Copy(s,Ord(Key[0])+1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CRazdelKod+1,CZena);
    DelSpace(Skidka);

    Itogo:=Copy(s,Ord(Key[0])+1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CRazdelKod+1,
    CInputIZena);
    DelSpace(Itogo);

    R_Zena:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+COne+1+CRazdelKod+1,CZena);
    DelSpace(R_Zena);

    O_Zena:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+COne+1+CZena+1+CRazdelKod+1,CZena);
    DelSpace(O_Zena);

    DiviSionNumber:=StrToInt(Copy(s,Ord(Key[0])+
    1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1+CZenaZ+1+CArtikul+1+CKol+1,COne));

    Proz:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+1+
    CRazdelKod+
    1{CZena+1},CLitr);
    DelSpace(Proz);

    SpecNalog:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+1+
    CRazdelKod+
         1+CLitr+1,CLitr);
    DelSpace(SpecNalog);

    VidNalog:=StrToInt(Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+
    COne+1+CRazdelKod+1+CLitr+1+CLitr+1,COne));

    NDS:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1,CLitr);
    DelSpace(NDS);

    VidNDS:=StrToInt(Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1,COne));

    Zakupka:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1,CZenaZ);
    DelSpace(Zakupka);

    Zakupka2:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1,CZenaZ);
    DelSpace(Zakupka2);


    RegionMarka:=StrToInt(
              Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1,COne));

    AkzisSbor:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1,CZenaZ);

    ZenaMarki:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1,CZenaZ);

    NSertif:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1+CZenaZ+1,CArtikul);

    SertifKol:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1+CZenaZ+1+CArtikul+1,CKol);
   End;
 End;
 L^.Dat.MarketElement:=E^.Dat.MarketElement;

 Read_OSD(OSD,L);
 Dispose(TempBox,Done);
 Dispose(OSD,Done);
 Dispose(E,Done);


 R.Assign(0, 0, 0, 0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));
 For i :=1 To L^.Dat.AmountS Do
  Begin
   With L^.Dat.DocumentElement[i].Input Do
   Begin
   Format(Kol,CKol);
        Format(Zena,CZena);
   Format(Skidka,CZena);

   MyStr(StrToReal(R_Zena)*
   StrToInt(Kol),CInputIZena,CMantissa,Itogo);

   Format(R_Zena,CZena);
   Format(O_Zena,CZena);
   Format(Proz,CLitr);
   Format(SpecNalog,CLitr);
   Format(NDS,CLitr);
   Format(Zakupka,CZenaZ);
   Format(Zakupka2,CZenaZ);
   Wk := Copy(L^.Dat.DocumentElement[i].BazKod,1,CRazdelKod);
   Wn := GetIdField(FName,L^.Dat.DocumentElement[i].BazKod);
   Wl := GetIdField(FLitr,L^.Dat.DocumentElement[i].BazKod);
   Format (wn,CName);
   Str(L^.Dat.DocumentElement[i].Input.DivisionNumber:1,s);
   s:=
   s+'│'+{отделение}
   wk+'│'+{код раздела}
   Wn+'│'+{наименование}
   L^.Dat.DocumentElement[i].BazKod+'│'+{код товара}
   L^.Dat.DocumentElement[i].Input.Kol+'│'+{количество}
   Wl+'│'+{литраж}
   L^.Dat.DocumentElement[i].Input.Zena+'│'+
   L^.Dat.DocumentElement[i].Input.Skidka+'│'+
   L^.Dat.DocumentElement[i].Input.R_Zena+'│'+
   L^.Dat.DocumentElement[i].Input.O_Zena+'│'+{L^.Dat.DocumentElement[i].input.}Itogo+'│'+
   L^.Dat.DocumentElement[i].Input.Proz+'│'+
   L^.Dat.DocumentElement[i].Input.SpecNalog+'│'+
   IntToStr(VidNalog,COne)+'│'+
   L^.Dat.DocumentElement[i].Input.Nds+'│'+
   IntToStr(VidNDS,COne)+'│'+
   L^.Dat.DocumentElement[i].Input.Zakupka+'│'+
   L^.Dat.DocumentElement[i].Input.Zakupka2;
   TempBox^.List^.Insert(NewStr(s));
   TempBox^.SetRange(TempBox^.List^.Count);
   End;{With}

  End;{For}
  New(E,Init);
  E^.Dat:=L^.Dat;

If (TempBox^.List^.Count)>0 Then
For i:=0 To TempBox^.List^.Count-1 Do
 Begin
  s:=TempBox^.GetText(i,TempBox^.List^.Count);
{для новой структуры стороки}
  E^.Dat.DocumentElement[i+1].BazKod:=Copy(s,1+COne+1+CRazdelKod+1+CName+1,CArtikul);
  With E^.Dat.DocumentElement[i+1].Input Do
   Begin
   {
    NDS:=BakGetField(FNds,E^.Dat.DocumentElement[i+1].BazKod,0);
    DelSpace(Nds);
   }
    Kol:=Copy(s,1+COne+1+CName+1+CArtikul+1+CRazdelKod+1,CKol);
    DelSpace(Kol);
    Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CRazdelKod+1,CZena);
    DelSpace(Zena);
         Skidka:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CRazdelKod+1,CZena);
    DelSpace(Skidka);
    Itogo:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CRazdelKod+1,CInputIZena);
    DelSpace(Itogo);
    R_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+COne+1+CRazdelKod+1,CZena);
    DelSpace(R_Zena);
    O_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+COne+1+CZena+1+CRazdelKod+1,CZena);
    DelSpace(O_Zena);

    DiviSionNumber:=StrToInt(Copy(s,1,COne));
    Proz:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CRazdelKod+
    1{CZena+1},CLitr);
    DelSpace(Proz);

    SpecNalog:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CRazdelKod+
         1+CLitr+1,CLitr);
    DelSpace(SpecNalog);

    VidNalog:=StrToInt(Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1,COne));

    NDS:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1,CLitr);
    DelSpace(NDS);

    VidNDS:=StrToInt(Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1,COne));

    Zakupka:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1,CZenaZ);
    DelSpace(Zakupka);

    Zakupka2:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1,CZenaZ);
    DelSpace(Zakupka2);
   End;
 End;
 L^.Dat.DocumentElement:=E^.Dat.DocumentElement;
 Dispose(TempBox,Done);
 Dispose(E,Done);
End;




Procedure SortNKLStatic (Var L:SuperMarketType);
Var i : Word;
    R : TRect;
    E : PSuperMarketType;
    Wl,Wk,Wn : AllStr;
    S : String;
    Key : String;
    TempBox : PBox;
    Itogo : AllStr;
    SS1,SS2 : AllStr;
    OSD : PBox;
Begin
 R.Assign(0, 0, 0, 0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));

 OSD := New(PBox, Init(R, 1, Nil));
 OSD^.NewList(New(PTextCollection, Init(0,1)));

 For i :=1 To L.Amount Do
  Begin
   With L.MarketElement[i].Input Do
   Begin
   Format(Kol,CKol);
        Format(Zena,CZena);
   Format(Skidka,CZena);
   {Format(Itogo,CInputIZena);}

   MyStr(StrToReal(R_Zena)*
   StrToInt(Kol),CInputIZena,CMantissa,Itogo);


   Format(R_Zena,CZena);
   Format(O_Zena,CZena);
   Format(Proz,CLitr);
   Format(SpecNalog,CLitr);
   Format(NDS,CLitr);
   Format(Zakupka,CZenaZ);
   Format(Zakupka2,CZenaZ);
   Format(AkzisSbor,CZenaZ);
   Format(ZenaMArki,CZenaZ);
   RFormat(SertifKol,CKol);
   DelSpace(NSertif);
   If NSertif[0]=#0 Then NSertif:=Glob.NoSertifStr;
   Wk := Copy(L.MarketElement[i].BazKod,1,CRazdelKod);
   Wn := GetIdField(FName,L.MarketElement[i].BazKod);
   Wl := GetIdField(FLitr,L.MarketElement[i].BazKod);
   Format (wn,CName);
   Str(L.MarketElement[i].Input.DivisionNumber:COne,s);

   Key[0]:=#0;

   Case SortOtgruzka Of
    0:Key:=wn{наименование}+'│'+s{Div}+'│'+wk{разд};
    1:Key:=s{Div}+'│'+wn{наименование}+'│'+wk{разд};
    2:Key:=wk{разд}+'│'+wn{наименование}+'│'+s{Div};
    3:Key:=wk{разд}+'│'+s{Div}+'│'+wn{наименование};
    4:Key[0]:=#0;
    Else
      Key:=s{Div}+'│'+wn{наименование}+'│'+wk{разд};
    End;


   s:=Key+' '{s}+
   '│'+wk+{код раздела}
   '│'+Wn+{первая часть наименования}
   '│'+L.MarketElement[i].BazKod+
   '│'+L.MarketElement[i].Input.Kol+
   '│'+Wl+{литраж}
   '│'+L.MarketElement[i].Input.Zena+
   '│'+L.MarketElement[i].Input.Skidka+
   '│'+L.MarketElement[i].Input.R_Zena+
   '│'+L.MarketElement[i].Input.O_Zena+
   '│'+Itogo+
   '│'+L.MarketElement[i].Input.Proz+
   '│'+L.MarketElement[i].Input.SpecNalog+
   '│'+IntToStr(VidNalog,COne)+
   '│'+L.MarketElement[i].Input.Nds+
   '│'+IntToStr(VidNDS,COne)+
   '│'+L.MarketElement[i].Input.Zakupka+
   '│'+L.MarketElement[i].Input.Zakupka2+
   '│'+IntToStr(L.MarketElement[i].Input.RegionMArka,COne)+
   '│'+L.MArketElement[i].Input.AkzisSbor+
   '│'+L.MArketElement[i].Input.ZenaMArki+
   '│'+L.MarketElement[i].Input.NSertif+
   '│'+L.MarketElement[i].Input.SertifKol+
   '│'+s{отделение};
   TempBox^.List^.Insert(NewStr(s));
   TempBox^.SetRange(TempBox^.List^.Count);


    {список параметров ОСД в накладной}
    If (TestElement(L.MarketElement[i].BazKod,OSD)) Then
    Begin
     RFormatZerro(L.MarketElement[i].Input.MarkaKod,CArtikul);
     RFormatZerro(L.MarketElement[i].Input.SMarkaKod,CArtikul);
     RFormatZerro(L.MarketElement[i].Input.NGTDKod,CArtikul);
     RFormatZerro(L.MarketElement[i].Input.ExpertKod,CArtikul);
     SS1:=IntToStr(L.MarketElement[i].Input.Srok,CDate);
     Format(SS1,CDAte);

     SS2:=IntToStr(L.MarketElement[i].Input.Virabotano,CDate);
     Format(SS2,CDAte);

     s:='│'+L.MarketElement[i].BazKod+'│'+
            L.MarketElement[i].Input.MarkaKod+'│'+
            L.MarketElement[i].Input.SMarkaKod+'│'+
            L.MarketElement[i].Input.NGTDKod+'│'+
            L.MarketElement[i].Input.ExpertKod+'│'+
		  SS1+'│'+SS2;
    OSD^.List^.Insert(NewStr(s));
    OSD^.SetRange(OSD^.List^.Count);
   End;



   End;{With}
  End;{For}
  New(E,Init);

  E^.Dat:=L;

If (TempBox^.List^.Count)>0 Then
For i:=0 To TempBox^.List^.Count-1 Do
 Begin
  s:=TempBox^.GetText(i,TempBox^.List^.Count);
{для новой структуры стороки}
  E^.Dat.MarketElement[i+1].BazKod:=Copy(s,Ord(Key[0])+1+COne+1+CRazdelKod+1+CName+1,CArtikul);
  With E^.Dat.MarketElement[i+1].Input Do
   Begin
   {NDS:=BakGetField(FNds,E^.Dat.MarketElement[i+1].BazKod,0);
    DelSpace(Nds);}
    Kol:=Copy(s,Ord(Key[0])+1+COne+1+CName+1+CArtikul+1+CRazdelKod+1,CKol);
    DelSpace(Kol);
    Zena:=Copy(s,Ord(Key[0])+1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CRazdelKod+1,CZena);
    DelSpace(Zena);
    Skidka:=Copy(s,Ord(Key[0])+1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CRazdelKod+1,CZena);
    DelSpace(Skidka);

    Itogo:=Copy(s,Ord(Key[0])+1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CRazdelKod+1,
    CInputIZena);
    DelSpace(Itogo);

    R_Zena:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+COne+1+CRazdelKod+1,CZena);
    DelSpace(R_Zena);

    O_Zena:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+COne+1+CZena+1+CRazdelKod+1,CZena);
    DelSpace(O_Zena);

    DiviSionNumber:=StrToInt(Copy(s,Ord(Key[0])+
    1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1+CZenaZ+1+CArtikul+1+CKol+1,COne));

    Proz:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+1+
    CRazdelKod+
    1{CZena+1},CLitr);
    DelSpace(Proz);

    SpecNalog:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+1+
    CRazdelKod+
         1+CLitr+1,CLitr);
    DelSpace(SpecNalog);

    VidNalog:=StrToInt(Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+
    COne+1+CRazdelKod+1+CLitr+1+CLitr+1,COne));

    NDS:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1,CLitr);
    DelSpace(NDS);

    VidNDS:=StrToInt(Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1,COne));

    Zakupka:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1,CZenaZ);
    DelSpace(Zakupka);

    Zakupka2:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1,CZenaZ);
    DelSpace(Zakupka2);


    RegionMarka:=StrToInt(
              Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1,COne));

    AkzisSbor:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1,CZenaZ);

    ZenaMarki:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1,CZenaZ);

    NSertif:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1+CZenaZ+1,CArtikul);

    SertifKol:=Copy(s,Ord(Key[0])+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1+CZenaZ+1+CArtikul+1,CKol);
   End;
 End;

 Read_OSD(OSD,E);
 L.MarketElement:=E^.Dat.MarketElement;
 Dispose(TempBox,Done);
 Dispose(OSD,Done);
 Dispose(E,Done);

 R.Assign(0, 0, 0, 0);
 TempBox := New(PBox, Init(R, 1, Nil));
 TempBox^.NewList(New(PTextCollection, Init(0,1)));
 For i :=1 To L.AmountS Do
  Begin
   With L.DocumentElement[i].Input Do
   Begin
   Format(Kol,CKol);
        Format(Zena,CZena);
   Format(Skidka,CZena);

   MyStr(StrToReal(R_Zena)*
   StrToInt(Kol),CInputIZena,CMantissa,Itogo);

   Format(R_Zena,CZena);
   Format(O_Zena,CZena);
   Format(Proz,CLitr);
   Format(SpecNalog,CLitr);
   Format(NDS,CLitr);
   Format(Zakupka,CZenaZ);
   Format(Zakupka2,CZenaZ);
   Wk := Copy(L.DocumentElement[i].BazKod,1,CRazdelKod);
   Wn := GetIdField(FName,L.DocumentElement[i].BazKod);
   Wl := GetIdField(FLitr,L.DocumentElement[i].BazKod);
   Format (wn,CName);
   Str(L.DocumentElement[i].Input.DivisionNumber:1,s);
   s:=
   s+'│'+{отделение}
   wk+'│'+{код раздела}
   Wn+'│'+{наименование}
   L.DocumentElement[i].BazKod+'│'+{код товара}
   L.DocumentElement[i].Input.Kol+'│'+{количество}
   Wl+'│'+{литраж}
   L.DocumentElement[i].Input.Zena+'│'+
   L.DocumentElement[i].Input.Skidka+'│'+
   L.DocumentElement[i].Input.R_Zena+'│'+
   L.DocumentElement[i].Input.O_Zena+'│'+{L.DocumentElement[i].input.}Itogo+'│'+
   L.DocumentElement[i].Input.Proz+'│'+
   L.DocumentElement[i].Input.SpecNalog+'│'+
   IntToStr(VidNalog,COne)+'│'+
   L.DocumentElement[i].Input.Nds+'│'+
   IntToStr(VidNDS,COne)+'│'+
   L.DocumentElement[i].Input.Zakupka+'│'+
   L.DocumentElement[i].Input.Zakupka2;
   TempBox^.List^.Insert(NewStr(s));
   TempBox^.SetRange(TempBox^.List^.Count);
   End;{With}
  End;{For}
  New(E,Init);
  E^.Dat:=L;

If (TempBox^.List^.Count)>0 Then
For i:=0 To TempBox^.List^.Count-1 Do
 Begin
  s:=TempBox^.GetText(i,TempBox^.List^.Count);
{для новой структуры стороки}
  E^.Dat.DocumentElement[i+1].BazKod:=Copy(s,1+COne+1+CRazdelKod+1+CName+1,CArtikul);
  With E^.Dat.DocumentElement[i+1].Input Do
   Begin
   {
    NDS:=BakGetField(FNds,E^.Dat.DocumentElement[i+1].BazKod,0);
    DelSpace(Nds);
   }
    Kol:=Copy(s,1+COne+1+CName+1+CArtikul+1+CRazdelKod+1,CKol);
    DelSpace(Kol);
    Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CRazdelKod+1,CZena);
    DelSpace(Zena);
         Skidka:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CRazdelKod+1,CZena);
    DelSpace(Skidka);
    Itogo:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CRazdelKod+1,CInputIZena);
    DelSpace(Itogo);
    R_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+COne+1+CRazdelKod+1,CZena);
    DelSpace(R_Zena);
    O_Zena:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+COne+1+CZena+1+CRazdelKod+1,CZena);
    DelSpace(O_Zena);

    DiviSionNumber:=StrToInt(Copy(s,1,COne));
    Proz:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CRazdelKod+
    1{CZena+1},CLitr);
    DelSpace(Proz);

    SpecNalog:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+1+CRazdelKod+
         1+CLitr+1,CLitr);
    DelSpace(SpecNalog);

    VidNalog:=StrToInt(Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1,COne));

    NDS:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1,CLitr);
    DelSpace(NDS);

    VidNDS:=StrToInt(Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1,COne));

    Zakupka:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1,CZenaZ);
    DelSpace(Zakupka);

    Zakupka2:=Copy(s,1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1+CZena+1+CZena+1+CZena+1+CInputIZena+1+COne+
    1+CRazdelKod+1+CLitr+1+CLitr+1+COne+1+CLitr+1+COne+1+CZenaZ+1,CZenaZ);
    DelSpace(Zakupka2);
   End;
 End;
 L.DocumentElement:=E^.Dat.DocumentElement;
 Dispose(TempBox,Done);
 Dispose(E,Done);
End;





Procedure FindINN(Reg,sel:Word;INN:AllStr);
var
  R : TRect;
  Control : PView;
  s : String[CSertif];
  c,Cod,Count: Word;
  Clf  : File;
  CLE : PBufClientType;
  Find : Boolean;
  FindKod : ArtikulStr;
begin
ClearFind;
DelSpace(INN);

Case Reg Of
0:Begin
{ If Sel = 0 Then Assign (ClientFile,Path^.Dat.ToClient+'Client.db')
  Else Assign (ClientFile,Path^.Dat.ToClient+'Sklad.db');}

    Case Sel Of
     0:Assign (ClF,Path^.Dat.ToClient+'Client.db');
     1:Assign (ClF,Path^.Dat.ToClient+'Sklad.db');
     2:Assign (ClF,Path^.Dat.ToClient+'Barter.db');
     Else;
     End;{CAse}


  End;

1:Begin
{ If Sel = 0 Then Assign (ClientFile,Path^.Dat.ToClient+'Make.db')
  Else Assign (ClientFile,Path^.Dat.ToClient+'Sklad.db');}

    Case Sel Of
     0:Assign (ClF,Path^.Dat.ToClient+'Make.db');
     1:Assign (ClF,Path^.Dat.ToClient+'Sklad.db');
     2:Assign (ClF,Path^.Dat.ToClient+'Barter.db');
     Else;
     End;{CAse}

  End;
Else;
End;

c:=IOResult;
Reset (ClF,SizeOf(ClientType));
c:=IOResult;
If c=0 Then
Begin
{AInfo('Обновляю списки клиентов...');}
Find:=False;
FindKod[0]:=#0;
While Not(Eof(ClF))  And Not (Find) Do
 Begin
    DInfoMsgShkala('Идет поиск клиента с указанным ИНН. Ждите... ',0,FileSize(CLF),FilePos(CLF));
    New(CLE,Init);
    {ReadClient(ClientFile,ClientElement);}
    ReadBufClient(Clf,CLE,Count);
  {If Count=0 Then c:=80;}
  For c:=1 To Count Do
  Begin
  If ClE^.Point.Dat[c].Employ Then
   Begin
    DelSpace(ClE^.Point.Dat[c].INN);
    If INN=ClE^.Point.Dat[c].INN Then
     Begin
      Find:=True;
      FindKod:=ClE^.Point.Dat[c].Kod;
      Break;{останавливаем For}
     End;
   End;
  End;{For}
   Dispose(CLE,Done);
 End;
NoInfoMsg;
System.Close(ClF);


If Find Then
Begin
If Reg =0 Then  Client^.FocusItem(Location(Client,FindKod,False));
If Reg =1 Then  MakeList^.FocusItem(Location(MakeList,FindKod,False));
End
Else
 MessageBox(^M+#3+'Клиент с ИНН: '+INN+' не найден!',Nil,mfError+mfCancelButton);
End
Else
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлам базы !',nil,mfError+mfCanCelButton);
  Exit;
 End;
end;


Function InputFindInn(Var Inn:AllStr):Boolean;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c: Word;
  St : AllStr;
begin
InputFindInn:=False;
DelSpace(INN);
R.Assign(3, 19, 25, 20);

New(Dlg, Init(R, ''));
Dlg^.HelpCtx:=$E002;

R.Assign(0, 0, 23, 1);
Control := New(PInputLine, Init(R, CAll));
PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));
Control^.SetDAta(INN);

Dlg^.Insert(Control);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(St);
  DelSpaceRight(St);
  If ST[0]<>#0 Then
        Begin
         DelSpace(St);
      InputFindInn:=True;
         INN:=St;
        End;
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;


Procedure LockUnlock(c:ArtikulStr;LockRegim:Word);
Var
    bazF : File Of BazType;
    b : PBazType;
    i : Word;

Begin
 Assign(Bazf,Path^.Dat.ToName+c+'.id');
 i:=IOResult;
 Reset(Bazf);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3+'Ошибка открытия '+Path^.Dat.ToName+c+'.id',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(B,Init);
  While Not(Eof(BazF)) Do
   Begin

     Repeat
     Pause(1);
     Until Lock(BazF,FilePos(BazF)*SizeOf(BazType),SizeOf(BazType));

     Read(BazF,b^.Dat);
     If B^.Dat.Employ Then
     Begin
      B^.Dat.Market:=LockRegim;
      Seek(BazF,FilePos(BazF)-1);
      Write(BazF,B^.Dat);
     End;

     Repeat
     Unlock(Bazf,(FilePos(Bazf)-1)*SizeOf(BazType),SizeOf(BazType));
     Until DosError=0;

   End;
 Close(BazF);
 Dispose(B,Done);
 MessageBox(^M+#3+'Операция успешно завершена!',Nil,mfInformation+mfCancelButton);
End;

Procedure LockUnlockD(c:ArtikulStr;LockRegim:Word);
Var
    bazF : File Of BazType;
    b : PBazType;
    i : Word;

Begin
 Assign(Bazf,Path^.Dat.ToName+c+'.id');
 i:=IOResult;
 Reset(Bazf);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3+'Ошибка открытия '+Path^.Dat.ToName+c+'.id',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(B,Init);
  While Not(Eof(BazF)) Do
   Begin

     Repeat
     Pause(1);
     Until Lock(BazF,FilePos(BazF)*SizeOf(BazType),SizeOf(BazType));

     Read(BazF,b^.Dat);
     If B^.Dat.Employ Then
     Begin
      B^.Dat.EnableDebit:=LockRegim;
      Seek(BazF,FilePos(BazF)-1);
      Write(BazF,B^.Dat);
     End;

     Repeat
     Unlock(Bazf,(FilePos(Bazf)-1)*SizeOf(BazType),SizeOf(BazType));
     Until DosError=0;

   End;
 Close(BazF);
 Dispose(B,Done);
 MessageBox(^M+#3+'Операция успешно завершена!',Nil,mfInformation+mfCancelButton);
End;

Procedure LockUnlockNalog(c:ArtikulStr;LockRegim:Word);
Var
    bazF : File Of BazType;
    b : PBazType;
    i : Word;
Begin
 Assign(Bazf,Path^.Dat.ToName+c+'.id');
 i:=IOResult;
 Reset(Bazf);
 i:=IOResult;
 If i<>0 Then
  Begin
   MessageBox(^M+#3+'Ошибка открытия '+Path^.Dat.ToName+c+'.id',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(B,Init);
  While Not(Eof(BazF)) Do
   Begin

     Repeat
     Pause(1);
     Until Lock(BazF,FilePos(BazF)*SizeOf(BazType),SizeOf(BazType));

     Read(BazF,b^.Dat);
     If B^.Dat.Employ Then
     Begin
      B^.Dat.VidNalog:=LockRegim;
      Case LockRegim Of
      0:B^.Dat.NAlog:='5.00';
      1:B^.Dat.NAlog:='3.00';
      Else B^.Dat.NAlog:='0.00';
      End;{Case}
      Seek(BazF,FilePos(BazF)-1);
      Write(BazF,B^.Dat);
     End;

     Repeat
     Unlock(Bazf,(FilePos(Bazf)-1)*SizeOf(BazType),SizeOf(BazType));
     Until DosError=0;

   End;
 Close(BazF);
 Dispose(B,Done);
 MessageBox(^M+#3+'Операция успешно завершена!',Nil,mfInformation+mfCancelButton);
End;


Function LockSelectName(S:ArtikulStr):Boolean;
Var
    Event : TEvent;
    R : Boolean;
    Msg : StrNAme;
Begin
  LockSelectName:=False;
  R:=GetIdEmploy(s);
  If Not(r) Then
   Begin
    Beep;
    DInfoMsg('Позиция ['+s+'] отмечена как удаленная. Не могу заблокировать!',False);
    Application^.ClearEvent(Event);
    Application^.ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    Application^.ClearEvent(Event);
    Application^.ClearEvent(Event);
    Exit;
   End;

  If SetNameLock(s,Msg) Then LockSelectName:=True
  Else
   Begin
    Beep;
    DInfoMsg('Позиция ['+s+'] используется'+Msg+'. Не могу заблокировать!',False);
    Application^.ClearEvent(Event);
    Application^.ClearEvent(Event);
    repeat
    Application^.GetEvent(Event);
    {until (Event.What in [evKeyDown,evMouseDown]);}
    until (Event.What <> evNothing);
    NoInfoMsg;
    Application^.ClearEvent(Event);
    Application^.ClearEvent(Event);
   End;
End;


(*
Function InputBN(Var l,P:PSuperMarketType):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  b : BN;
  c : WOrd;
  k : LongInt;

begin
If (InputZakaz=1) Then
Begin
InputBN:=True;
Exit;
End;

If Glob.Status=DocEdit Then
 B:=P^.Dat.Bn
 Else
 B:=L^.Dat.Bn;
1:
InputBN:=False;
R.Assign(12, 8, 70, 15);
New(Dlg, Init(R, 'Безналичный расчет'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E002;

R.Assign(3, 2, 13, 3);
Control := New(PInputLine, Init(R, CDate));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));

  R.Assign(2, 1, 8, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~Д~ата:', Control)));

R.Assign(19, 2, 31, 3);
Control := New(PInputLine, Init(R, 10));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(18, 1, 25, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'N ~п~/п:', Control)));

R.Assign(35, 2, 52, 3);
Control := New(PInputLine, Init(R, CIZena));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(34, 1, 50, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~С~умма платежа:', Control)));

R.Assign(7, 4, 54, 5);
Control := New(PInputLine, Init(R, CAll));
Dlg^.Insert(Control);

  R.Assign(54, 4, 57, 5);
  Dlg^.Insert(New(PHistory, Init(R, PInputline(Control), 250)));

  R.Assign(1, 4, 7, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Б~а~нк:', Control)));

Dlg^.SelectNext(False);

Dlg^.SetData(B);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
  Dlg^.GetData(B);
  DelSpace(B.Date);
  DelSpace(B.NPlat);
{ Writeln(B.Summa);}
  MyStr(StrToReal(B.Summa),CIZena,CMAntissa,B.Summa);
{ Writeln(B.Summa);
  Readln;}
  DelSpace(B.Summa);
  DelSpaceRight(B.Bank);
  If b.Bank[0]=#0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не указан банк !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  {ChekBank(B.Bank);}

  If Not(TestDate(B.Date,k)) Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не существующая дата !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  If b.Date[0]=#0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не указана дата п/п !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  If b.NPlat[0]=#0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Не указан номер п/п !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  If StrToReal(b.Summa)=0 Then
   Begin
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    MessageBox(#3^M+#3'Нулевая сумма б/н платежа !',Nil,mfError+mfCancelButton);
    Goto 1;
   End;

  InputBn:=True;
  L^.Dat.Bn:=B;
 End;
Dispose(Control,Done);
Dispose(Dlg,Done);
end;
*)


Function SelectOperationAndDocument(Var mm3s:Maska3;Var mm9S:Maska9):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  ControlOperation : PView;
  Control,ControlDoc : PView;
  Test,c,OperationFiltr,DocFiltr:Word;
  mm3:Maska3;
  mm9:Maska9;

begin
SelectOperationAndDocument:=False;
For c:=1 to 3 Do mm3s[c]:=1;
For c:=1 to 9 Do mm9s[c]:=1;
BitToWord3(mm3s,OperationFiltr);
BitToWord9(mm9s,DocFiltr);
1:
R.Assign(16, 9, 63, 14);
New(Dlg, Init(R, 'Фильтр операций и документов отгрузки'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E002;

R.Assign(2, 1, 14, 4);
ControlOperation := New(PCheckboxes, Init(R,
  NewSItem('Клиент',
  NewSItem('Склад',
  NewSItem('Бартер', Nil)))));
Dlg^.Insert(ControlOperation);
ControlOperation^.SetData(OperationFiltr);



R.Assign(17, 1, 45, 4);
ControlDoc := New(PCheckboxes, Init(R,
  NewSItem('Сп',
  NewSItem('Тч',
  NewSItem('ФЛ',
  NewSItem('СФ',
  NewSItem('СФБ',
  NewSItem('Д*',
  NewSItem('Д СФ*',
  NewSItem('Д',
  NewSItem('Д СФБ', Nil)))))))))));
Dlg^.Insert(ControlDoc);
ControlDoc^.SetData(DocFiltr);

Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);

If c <>cmCancel Then
 Begin
  ControlOperation^.getData(OperationFiltr);
  ControlDoc^.getData(DocFiltr);
  WordToBit3(OperationFiltr,mm3);
  Test:=0;
  For c:=1 To 3 Do If mm3[c]=1 Then Inc(Test);
  If Test=0 Then
   Begin
    MessageBox(^M+#3'Не выбран ни один вид отгрузки!',Nil,mfError+mfCancelButton);
    Dispose(ControlOperation,Done);
    Dispose(ControlDoc,Done);
    Dispose(Dlg,Done);
    Goto 1;
   End;

  WordToBit9(DocFiltr,mm9);
  Test:=0;
  For c:=1 To 9 Do If mm9[c]=1 Then Inc(Test);
  If Test=0 Then
   Begin
    MessageBox(^M+#3'Не выбран ни один вид документа отгрузки!',Nil,mfError+mfCancelButton);
    Dispose(ControlOperation,Done);
    Dispose(ControlDoc,Done);
    Dispose(Dlg,Done);
    Goto 1;
   End;

   Convert3(mm3);
   Convert9(mm9);

   For c:=1 to 3 Do mm3s[c]:=mm3[c];
   For c:=1 to 9 Do mm9s[c]:=mm9[c];
   SelectOperationAndDocument:=True;
 End;
 Dispose(ControlOperation,Done);
 Dispose(ControlDoc,Done);
 Dispose(Dlg,Done);
end;



procedure DelProdagaU(i:Word);
Var j:Word;
    s : String;
    sArt,SKol,SFantomKol : ArtikulStr;
Begin
  s:=Prodaga^.GetText(i,Prodaga^.List^.Count);
  SArt:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
              COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1+CZenaZ+1,CArtikul);

  SKol:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
              COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1+CZenaZ+1+CArtikul+1,CKol);

  Prodaga^.List^.AtFree(i);
  Prodaga^.SetRange(Prodaga^.List^.Count);
  If Prodaga^.Focused>0 Then Prodaga^.FocusItem(Prodaga^.Focused);

  If (Prodaga^.Focused>=Prodaga^.List^.Count) and(Prodaga^.Focused>0) Then
  Prodaga^.FocusItem(Prodaga^.Focused-1);

  If (StrToInt(SKol)>0) And (SArt<>Glob.NoSertifStr) Then
   Begin
    ProdagaDoc^.FocusItem(LoCation(ProdagaDoc,SArt,True));
    s:=ProdagaDoc^.GetText(ProdagaDoc^.Focused,ProdagaDoc^.List^.Count);
    SFantomKol:=Copy(s,1+CName+1+CArtikul+1+COne+1,CKol);
    If (StrToInt(SFantomKol)-StrToInt(SKol))>0 Then
     Begin
      ProdagaDoc^.List^.AtFree(ProdagaDoc^.Focused);
      ProdagaDoc^.SetRange(ProdagaDoc^.List^.Count);
      System.Delete(s,1+CName+1+CArtikul+1+COne+1,CKol);
      Str(StrToInt(SFantomKol)-StrToInt(SKol):CKol,SFantomKol);
      DelSpace(SFAntomKol);
      RFormat(SFantomKol,CKol);
      System.Insert(SFantomKol,s,1+CName+1+CArtikul+1+COne+1);
      ProdagaDoc^.List^.Insert(NewStr(S));
      ProdagaDoc^.SetRange(ProdagaDoc^.List^.Count);
     End
     Else
      Begin
       If (StrToInt(SFantomKol)-StrToInt(SKol))<0 Then
       MessageBox(^M+#3+'Отрицательное количество сертификатов! '+ClicProgrammer^,Nil,mfError+mfCancelButton);

       ProdagaDoc^.List^.AtFree(ProdagaDoc^.Focused);
       ProdagaDoc^.SetRange(ProdagaDoc^.List^.Count);
      End;
  If ProdagaDoc^.Focused>0 Then ProdagaDoc^.FocusItem(ProdagaDoc^.Focused);
  If (ProdagaDoc^.Focused>=ProdagaDoc^.List^.Count) and(ProdagaDoc^.Focused>0) Then
  ProdagaDoc^.FocusItem(ProdagaDoc^.Focused-1);
   End;{если есть связанные сертификаты}
End;



procedure DelProdagaDoc(i:Word);
Var j:Word;
    s : String;
    SArt,SFantomArt,SFantomKol : ArtikulStr;
    R : TRect;
    TTTBox : PBox;
Begin
  s:=ProdagaDoc^.GetText(i,ProdagaDoc^.List^.Count);
  SFantomArt:=Copy(s,1,CArtikul);
  ProdagaDoc^.List^.AtFree(i);
  ProdagaDoc^.SetRange(ProdagaDoc^.List^.Count);
  If ProdagaDoc^.Focused>0 Then ProdagaDoc^.FocusItem(ProdagaDoc^.Focused);

  If (ProdagaDoc^.Focused>=ProdagaDoc^.List^.Count) and(ProdagaDoc^.Focused>0) Then
  ProdagaDoc^.FocusItem(ProdagaDoc^.Focused-1);

  If Prodaga^.List^.Count>0 Then
  Begin
   R.Assign(0,0,0,0);
   TTTBox := New(PBox, Init(R, 1, Nil));
   TTTBox^.NewList(New(PTextCollection, Init(0,1)));
   For j:=0 to Prodaga^.List^.Count-1 Do
   Begin
    s:=Prodaga^.GetText(j,Prodaga^.List^.Count);
    SArt:=Copy(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+CLitr+1+
              COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1+CZenaZ+1,CArtikul);
    If StrToInt(SArt)=StrToInt(SFantomArt) Then
     Begin
      System.Delete(s,1+CName+1+CArtikul+1+COne+1+CLitr+1+CKol+1+CZena+1+CZena+1+CInputIZena+1+CZena+1+CZena+1+COne+1+CLitr+1+
      COne+1+CLitr+1+COne+1+CZenaZ+1+CZenaZ+1+COne+1+CZenaZ+1+CZenaZ+1+CArtikul+1,CKol);
      s:=s+'    0';
     End;
    TTTBox^.List^.Insert(NewStr(S));
    TTTBox^.SetRange(TTTBox^.List^.Count);
   End;{For записи в TTTBox}

   Prodaga^.Newlist(Nil);
   Prodaga^.NewList(New(PTextCollection, Init(0,1)));

   If TTTBox^.List^.Count>0 Then
   For j:=0 to TTTBox^.List^.Count-1 Do
   Begin
    s:=TTTBox^.GetText(j,TTTBox^.List^.Count);
    Prodaga^.List^.Insert(NewStr(S));
    Prodaga^.SetRange(Prodaga^.List^.Count);
   End;

   Dispose(TTTBox,Done);
  End;{If}
End;



Procedure DeterminateOtdelSertif(s:String;SFAntomArtikul:ArtikulStr;VAr A:ArtikulStr);
VAr s2 : AllStr;
  FindArt : ArtikulStr;
  Find : Boolean;
  Count : Word;
Begin
{пробежать}
Find := FAlse;
If ProdagaDoc^.List^.Count>0 Then
 Begin
  For count:=0 To ProdagaDoc^.List^.Count-1 Do
   Begin
    s2:=ProdagaDoc^.GetText(count,ProdagaDoc^.List^.Count);
    FindArt:=Copy(s2,1,CArtikul);
    If (FindArt=SFAntomArtikul) Then
     Begin
      Find:=True;
      Break;
     End;
   end;{For}

   If Find Then ActiveFantomOtdel:=Copy(s2,1+CName+1+CArtikul+1,COne)
   Else
     ActiveFantomOtdel:=GetOtdelSertif(SFantomArtikul);


 End
 Else ActiveFantomOtdel:=GetOtdelSertif(SFantomArtikul);
End;


Function TestFAntomOtdel(s:String;SFAntomArtikul:ArtikulStr;VAr Active:ArtikulStr):Boolean;
VAr s2 : AllStr;
  FindArt : ArtikulStr;
  Find : Boolean;
  Count : Word;
Begin
TestFAntomOtdel:=True;
Find := FAlse;
If ProdagaDoc^.List^.Count>0 Then
 Begin
  For count:=0 To ProdagaDoc^.List^.Count-1 Do
   Begin
    s2:=ProdagaDoc^.GetText(count,ProdagaDoc^.List^.Count);
    FindArt:=Copy(s2,1,CArtikul);
    If (FindArt=SFAntomArtikul) Then
     Begin
      Find:=True;
      Break;
     End;
   end;{For}

   If Find Then
    Begin
     FindArt:=Copy(s2,1+CName+1+CArtikul+1,COne);
     If StrToInt(FindArt)<>StrToInt(Active) Then
	 Begin
       Active:=IntToStr(StrToInt(FindArt),COne);
	  TestFAntomOtdel:=False;
      End;
    End;

 End;

End;



Function TestOtdel2(c:Word):Boolean;
Begin
 TestOtdel2:=True;
 If EnableAverageOtdel=0 Then Exit;
 If Not (c in SetEnableOtdel) Then TestOtdel2:=False;
End;


Function TestOtdelName({отделение}vvv:Word;{разрешенные}c:Word):Boolean;
Var MMM:Maska8;
Begin
 TestOtdelName:=True;
 WordToBit8(c,MMM);
 Convert8(MMM);
 If (MMM[vvv]=0) Then TestOtdelName:=False;
End;


Function TestZakaz(E:PZakazType):Boolean;
Var c : Word;
    sss : AllStr;

Begin
TestZakaz:=True;
If EnableAverageOtdel=0 Then Exit;


For c:=1 To CDivision Do
 Begin
  If c in SetEnableOtdel Then sss:=sss+IntToStr(c,CKol)+' ';
 End;


For c:=1 To E^.DAt.Amount Do
 Begin
  If Not(E^.DAt.MArketElement[c].Input.InputDiviSion in SetEnableOtdel) Then
   Begin
    TestZakaz:=False;
    Exit;
   End
   {
   Else
    AddProtocol('Заказ '+E^.Dat.Document+' отложен!','E^.DAt.MArketElement['+IntToStr(c,CKol)+
    '].Input.InputDiviSion='+IntToStr(E^.DAt.MArketElement[c].Input.InputDiviSion,CKol)+
    ' SetEnableOtdel='+SSS,'');
   }
 End;

For c:=1 To E^.DAt.AmountS Do
 Begin
  If Not(E^.DAt.DocumentElement[c].Input.InputDiviSion in SetEnableOtdel) Then
   Begin
    TestZakaz:=False;
    Exit;
   End
   {
   Else
    AddProtocol('Заказ '+E^.Dat.Document+' отложен!','E^.DAt.DocumentElement['+IntToStr(c,CKol)+
    '].Input.InputDiviSion='+IntToStr(E^.DAt.DocumentElement[c].Input.InputDiviSion,CKol)+
    ' SetEnableOtdel='+SSS,'');
   }

 End;

 AddProtocol('Заказ '+E^.Dat.Document+' отложен!','SetEnableOtdel='+SSS,'');

End;




Function TestReturn(E:PNewVozwratType):Boolean;
Var c : Word;
Begin
TestReturn:=True;
If EnableAverageOtdel=0 Then Exit;
For c:=1 To E^.DAt.Amount Do
 Begin
  If Not(StrToInt(E^.DAt.VozwratElement[c].Input.Division) in SetEnableOtdel) Then
   Begin
    TestReturn:=False;
    MessageBox(^M+#3'Обнаружен товар из отделений запрещенных к отгрузке!',Nil,
    mfError+mfCancelButton);
    Exit;
   End;
 End;
End;






Function DatePeriodDialog(Var s1,s2:TDAteString;Regim:Boolean):Boolean;
var
  {Dlg : PDialog;}
  R : TRect;
  Control1,Control2 : PbxEditLine;{PView}
  Dlg  : PbxEntryDialog;
  Dt1,Dt2: TbxDateRec;
  c : Word;
  l : LongInt;
  s : TDateString;

begin
DatePeriodDialog := False;
R.Assign(25, 9, 55, 14);
New(Dlg, Init(R, 'Укажите период'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;
Dlg^.Palette := dpCyanDialog;

R.Assign(4, 2, 14, 3);
(*
Control1 := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control1);
  PInputLine(Control1)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DAteFiltr, True));
*)
      Control1:= New(PbxDateEdit, Init(R, DateMask));
      Control1^.SetEditFlag(dfRequired, True);
      Dlg^.Insert(Control1);

  R.Assign(1, 2, 4, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~с~:', Control1)));

If StrToInt(CurrentPAssword)=0 Then
s:=DateToDateString(DateMask,DateStringToDate(Datemask,FDate)-30)
Else s:=FDAte;

      ExtractDateFromString(Dt1,DateMask,S);

Control1^.SetData(Dt1{s});

R.Assign(18, 2, 28, 3);
(*
Control2 := New(PInputLine, Init(R, 8));
Dlg^.Insert(Control2);
  PInputLine(Control2)^.Validator := New(PPXPictureValidator, Init(DAteFiltr{'[##-##-9#]'}, True));
*)
      Control2:= New(PbxDateEdit, Init(R, DateMask));
      Control2^.SetEditFlag(dfRequired, True);
      Dlg^.Insert(Control2);

  R.Assign(14, 2, 18, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~п~о:', Control2)));
    ExtractDateFromString(Dt2,DateMask,FDate);

Control2^.SetData(Dt2{FDate});

Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Control1^.GetData(Dt1);
  Control2^.GetData(Dt2);

  S1:=DateToDateStr(DT1,DateMask);
  S2:=DateToDateStr(DT2,DateMask);

  DelSpace(s1);
  DelSpace(s2);

   If Not(TestDate(s1,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
     DatePeriodDialog:=FAlse;
     Dispose(Control1,Done);
     Dispose(Control2,Done);
     Dispose(Dlg,Done);
     Exit;
    End;

   If Not(TestDate(s2,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе окончания периода!',Nil,mfError+mfCancelButton);
     DatePeriodDialog:=FAlse;
     Dispose(Control1,Done);
     Dispose(Control2,Done);
     Dispose(Dlg,Done);
     Exit;
    End;

   {если даты перепутаны переставляем их}
   If DateStringToDate(DateMask,s1)>DateStringToDate(DateMask,s2) Then
    Begin
        s:=s2;
        s2:=s1;
        s1:=s;
    End;

   {если диапазон превышает 30 дней}
  If Regim Then
   If (DateStringToDate(DateMask,s2)-DateStringToDate(DateMask,s1))>35 Then
    Begin
        MessageBox(^M+#3'Указан слишком большой диапазон!'^M+
           #3+'Сокращаю его до 35 дней!',Nil,mfWarning+mfCancelButton);
        s1:=DAteToDAteString(DAteMask,
       DateStringToDate(DateMask,s2)-35);
    End;

     DatePeriodDialog:=True;

     Dispose(Control1,Done);
     Dispose(Control2,Done);
     Dispose(Dlg,Done);
 End
Else
 Begin
  Dispose(Control1,Done);
  Dispose(Control2,Done);
  Dispose(Dlg,Done);
 End;
end;


Function DatePeriodDialog1(DDD:TDateString;Var s1,s2:TDAteString):Boolean;
var
  R : TRect;
{  Dlg : PDialog;
  Control1,Control2 : PView;}
  Control1,Control2 : PbxEditLine;{PView}
  Dlg  : PbxEntryDialog;
  Dt1,Dt2: TbxDateRec;

  c : Word;
  l : LongInt;
  s : TDateString;
begin
DatePeriodDialog1 := False;
R.Assign(25, 9, 55, 14);
New(Dlg, Init(R, 'Укажите период'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;
Dlg^.Palette := dpCyanDialog;

R.Assign(4, 2, 14, 3);
(*
Control1 := New(PInputLine, Init(R, CDAte));
Dlg^.Insert(Control1);
  PInputLine(Control1)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DAteFiltr, True));
*)
      Control1:= New(PbxDateEdit, Init(R, DDD));
      Control1^.SetEditFlag(dfRequired, True);
      Dlg^.Insert(Control1);

  R.Assign(1, 2, 4, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~с~:', Control1)));

{Control1^.SetData(s1);}
      ExtractDateFromString(Dt1,DateMask,S1);

Control1^.SetData(Dt1{s});


R.Assign(18, 2, 28, 3);
(*
Control2 := New(PInputLine, Init(R, CDate));
Dlg^.Insert(Control2);
  PInputLine(Control2)^.Validator := New(PPXPictureValidator, Init(DAteFiltr{'[##-##-9#]'}, True));
*)
      Control2:= New(PbxDateEdit, Init(R, DDD));
      Control2^.SetEditFlag(dfRequired, True);
      Dlg^.Insert(Control2);

  R.Assign(14, 2, 18, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~п~о:', Control2)));
{Control2^.SetData(s2);}
      ExtractDateFromString(Dt2,DateMask,S2);

Control2^.SetData(Dt2{s});


Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Control1^.GetData(dt1);
  Control2^.GetData(dt2);

  S1:=DateToDateStr(DT1,DDD);
  S2:=DateToDateStr(DT2,DDD);

  DelSpace(s1);
  DelSpace(s2);

   If Not(TestDate(s1,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
     DatePeriodDialog1:=FAlse;
     Dispose(Control1,Done);
     Dispose(Control2,Done);
     Dispose(Dlg,Done);
     Exit;
    End;


   If Not(TestDate(s2,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе окончания периода!',Nil,mfError+mfCancelButton);
     DatePeriodDialog1:=FAlse;
     Dispose(Control1,Done);
     Dispose(Control2,Done);
     Dispose(Dlg,Done);
     Exit;
    End;

   {если даты перепутаны переставляем их}
   If DateStringToDate(DateMask,s1)>DateStringToDate(DateMask,s2) Then
    Begin
        s:=s2;
        s2:=s1;
        s1:=s;
    End;

   {если диапазон превышает 30 дней}

     DatePeriodDialog1:=True;
     Dispose(Control1,Done);
     Dispose(Control2,Done);
     Dispose(Dlg,Done);
 End
Else
 Begin
  Dispose(Control1,Done);
  Dispose(Control2,Done);
  Dispose(Dlg,Done);
 End;
end;




{управляет полем Last и RegionMArka в накладной расхода}
Function AddMarkerLast(Var L:PSuperMarketType) : Boolean;
Var SkladFile : File Of SkladType;
    Sklad : PSkladType;
    i,p : Byte;
    s1 : TEnjoyStr;
Begin
{$IFDEF DPMI}
AddMarkerLast:=False;

 For i:=1 To L^.DAt.Amount{J} Do
  Begin
   New(Sklad,Init);
   S1:=Copy(L^.Dat.MArketElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path^.Dat.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Exit;
    End;
   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));

   Repeat
   Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));


   Read(SkladFile,Sklad^.Dat);

   Seek(SkladFile,FilePos(SkladFile)-1);

   Repeat

    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);
   Close(SkladFile);

   With Sklad^.Dat.Input Do
   Begin
     DelSpace(L^.Dat.MarketElement[i].Input.Kol);
     If Glob.Status=DocEdit Then
     Begin
     Str((StrToInt(DiviSion[L^.Dat.MarketElement[i].Input.DiviSionNumber])+
            +GetKolMarket(L^.Dat.MarketElement[i].BazKod,L^.Dat.MarketElement[i].Input.DiviSionNumber,PrevMarket)
            -StrToInt(L^.Dat.MarketElement[i].Input.Kol))
     :CKol,Division[L^.Dat.MarketElement[i].InPut.DiviSionNumber]);
     End
     Else
     Str((StrToInt(DiviSion[L^.Dat.MarketElement[i].Input.DiviSionNumber])-StrToInt(L^.Dat.MarketElement[i].Input.Kol))
     :CKol,Division[L^.Dat.MarketElement[i].InPut.DiviSionNumber]);

     if StrToInt(division[L^.Dat.MarketElement[i].InPut.DiviSionNumber])<=0 Then
     L^.Dat.MarketElement[i].Input.Last:=True;

     {L^.Dat.MarketElement[i].Input.RegionMarka:=RegionMArka;}
   End;

   L^.Dat.MarketElement[i].Input.NMakeKod:=Sklad^.Dat.Input.NMakeKod;
   Dispose(Sklad,Done);
End;{For}


 For i:=1 To L^.DAt.AmountS{J} Do
  Begin
   New(Sklad,Init);
   S1:=Copy(L^.Dat.DocumentElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path^.Dat.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Exit;
    End;
   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.DocumentElement[i].BazKod,CRazdelKod+1,CKod)));

   Repeat
   Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Sklad^.Dat);

   Seek(SkladFile,FilePos(SkladFile)-1);

   Repeat
    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);
   Close(SkladFile);

   With Sklad^.Dat.Input Do
   Begin
     DelSpace(L^.Dat.DocumentElement[i].Input.Kol);
     If Glob.Status=DocEdit Then
     Str((StrToInt(DiviSion[L^.Dat.DocumentElement[i].Input.DiviSionNumber])+
            +GetKolMarket(L^.Dat.DocumentElement[i].BazKod,L^.Dat.DocumentElement[i].Input.DiviSionNumber,PrevMarket)
            -StrToInt(L^.Dat.DocumentElement[i].Input.Kol))
     :CKol,Division[L^.Dat.DocumentElement[i].InPut.DiviSionNumber])
     Else
     Str((StrToInt(DiviSion[L^.Dat.DocumentElement[i].Input.DiviSionNumber])-StrToInt(L^.Dat.DocumentElement[i].Input.Kol))
     :CKol,Division[L^.Dat.DocumentElement[i].InPut.DiviSionNumber]);
     if StrToInt(division[L^.Dat.DocumentElement[i].InPut.DiviSionNumber])<=0 Then
     L^.Dat.DocumentElement[i].Input.Last:=True;
   End;
   L^.Dat.DocumentElement[i].Input.NMakeKod:=Sklad^.Dat.Input.NMakeKod;
   Dispose(Sklad,Done);
End;{For}

AddMarkerLast:=True;
{$ENDIF}
End;




Procedure ConfigExportImport;
var
  Dlg : PDialog;
  R : TRect;
  c : LongInt;

  Control : PView;
  PathExpImp1:PDistantionExpImp;

begin
New(PathExpImp1,Init);
PathExpImp1^.Dat:=PathExpImp^.Dat;
R.Assign(0, 0, 80, 23);
New(Dlg, Init(R, 'Размещение экспорта/импорта'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E011;

For c:=1 To 10 Do
Begin
R.Assign(5, 1+C, 27, 2+C);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 1+C, 5, 2+C);
  Dlg^.Insert(New(PLabel, Init(R, IntToStr(c,CMantissa)+':', Control)));
End;



R.Assign(31, 2, 53, 3);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 2, 31, 3);
  Dlg^.Insert(New(PLabel, Init(R, '11:', Control)));

R.Assign(31, 3, 53, 4);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 3, 31, 4);
  Dlg^.Insert(New(PLabel, Init(R, '12:', Control)));

R.Assign(31, 4, 53, 5);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 4, 31, 5);
  Dlg^.Insert(New(PLabel, Init(R, '13:', Control)));

R.Assign(31, 5, 53, 6);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 5, 31, 6);
  Dlg^.Insert(New(PLabel, Init(R, '14:', Control)));

R.Assign(31, 6, 53, 7);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 6, 31, 7);
  Dlg^.Insert(New(PLabel, Init(R, '15:', Control)));

R.Assign(31, 7, 53, 8);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 7, 31, 8);
  Dlg^.Insert(New(PLabel, Init(R, '16:', Control)));

R.Assign(31, 8, 53, 9);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 8, 31, 9);
  Dlg^.Insert(New(PLabel, Init(R, '17:', Control)));

R.Assign(31, 9, 53, 10);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 9, 31, 10);
  Dlg^.Insert(New(PLabel, Init(R, '18:', Control)));

R.Assign(31, 10, 53, 11);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 10, 31, 11);
  Dlg^.Insert(New(PLabel, Init(R, '19:', Control)));

R.Assign(31, 11, 53, 12);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 11, 31, 12);
  Dlg^.Insert(New(PLabel, Init(R, '20:', Control)));

R.Assign(57, 2, 79, 3);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 2, 57, 3);
  Dlg^.Insert(New(PLabel, Init(R, '21:', Control)));

R.Assign(57, 3, 79, 4);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 3, 57, 4);
  Dlg^.Insert(New(PLabel, Init(R, '22:', Control)));

R.Assign(57, 4, 79, 5);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 4, 57, 5);
  Dlg^.Insert(New(PLabel, Init(R, '23:', Control)));

R.Assign(57, 5, 79, 6);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 5, 57, 6);
  Dlg^.Insert(New(PLabel, Init(R, '24:', Control)));

R.Assign(57, 6, 79, 7);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 6, 57, 7);
  Dlg^.Insert(New(PLabel, Init(R, '25:', Control)));

R.Assign(57, 7, 79, 8);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 7, 57, 8);
  Dlg^.Insert(New(PLabel, Init(R, '26:', Control)));

R.Assign(57, 8, 79, 9);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 8, 57, 9);
  Dlg^.Insert(New(PLabel, Init(R, '27:', Control)));

R.Assign(57, 9, 79, 10);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 9, 57, 10);
  Dlg^.Insert(New(PLabel, Init(R, '28:', Control)));

R.Assign(57, 10, 79, 11);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 10, 57, 11);
  Dlg^.Insert(New(PLabel, Init(R, '29:', Control)));

R.Assign(57, 11, 79, 12);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 11, 57, 12);
  Dlg^.Insert(New(PLabel, Init(R, '30:', Control)));

R.Assign(5, 13, 27, 14);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(2, 13, 5, 14);
  Dlg^.Insert(New(PLabel, Init(R, '1:', Control)));

R.Assign(5, 14, 27, 15);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(2, 14, 5, 15);
  Dlg^.Insert(New(PLabel, Init(R, '2:', Control)));

R.Assign(5, 15, 27, 16);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(2, 15, 5, 16);
  Dlg^.Insert(New(PLabel, Init(R, '3:', Control)));

R.Assign(5, 16, 27, 17);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(2, 16, 5, 17);
  Dlg^.Insert(New(PLabel, Init(R, '4:', Control)));

R.Assign(5, 17, 27, 18);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(2, 17, 5, 18);
  Dlg^.Insert(New(PLabel, Init(R, '5:', Control)));

R.Assign(5, 18, 27, 19);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(2, 18, 5, 19);
  Dlg^.Insert(New(PLabel, Init(R, '6:', Control)));

R.Assign(5, 19, 27, 20);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(2, 19, 5, 20);
  Dlg^.Insert(New(PLabel, Init(R, '7:', Control)));

R.Assign(5, 20, 27, 21);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(2, 20, 5, 21);
  Dlg^.Insert(New(PLabel, Init(R, '8:', Control)));

R.Assign(5, 21, 27, 22);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(2, 21, 5, 22);
  Dlg^.Insert(New(PLabel, Init(R, '9:', Control)));

R.Assign(5, 22, 27, 23);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(1, 22, 5, 23);
  Dlg^.Insert(New(PLabel, Init(R, '10:', Control)));

R.Assign(31, 13, 53, 14);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 13, 31, 14);
  Dlg^.Insert(New(PLabel, Init(R, '11:', Control)));

R.Assign(31, 14, 53, 15);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 14, 31, 15);
  Dlg^.Insert(New(PLabel, Init(R, '12:', Control)));

R.Assign(31, 15, 53, 16);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 15, 31, 16);
  Dlg^.Insert(New(PLabel, Init(R, '13:', Control)));

R.Assign(31, 16, 53, 17);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 16, 31, 17);
  Dlg^.Insert(New(PLabel, Init(R, '14:', Control)));

R.Assign(31, 17, 53, 18);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 17, 31, 18);
  Dlg^.Insert(New(PLabel, Init(R, '15:', Control)));

R.Assign(31, 18, 53, 19);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 18, 31, 19);
  Dlg^.Insert(New(PLabel, Init(R, '16:', Control)));

R.Assign(31, 19, 53, 20);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 19, 31, 20);
  Dlg^.Insert(New(PLabel, Init(R, '17:', Control)));

R.Assign(31, 20, 53, 21);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 20, 31, 21);
  Dlg^.Insert(New(PLabel, Init(R, '18:', Control)));

R.Assign(31, 21, 53, 22);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 21, 31, 22);
  Dlg^.Insert(New(PLabel, Init(R, '19:', Control)));

R.Assign(31, 22, 53, 23);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(27, 22, 31, 23);
  Dlg^.Insert(New(PLabel, Init(R, '20:', Control)));

R.Assign(57, 13, 79, 14);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 13, 57, 14);
  Dlg^.Insert(New(PLabel, Init(R, '21:', Control)));

R.Assign(57, 14, 79, 15);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 14, 57, 15);
  Dlg^.Insert(New(PLabel, Init(R, '22:', Control)));

R.Assign(57, 15, 79, 16);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 15, 57, 16);
  Dlg^.Insert(New(PLabel, Init(R, '23:', Control)));

R.Assign(57, 16, 79, 17);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 16, 57, 17);
  Dlg^.Insert(New(PLabel, Init(R, '24:', Control)));

R.Assign(57, 17, 79, 18);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 17, 57, 18);
  Dlg^.Insert(New(PLabel, Init(R, '25:', Control)));

R.Assign(57, 18, 79, 19);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 18, 57, 19);
  Dlg^.Insert(New(PLabel, Init(R, '26:', Control)));

R.Assign(57, 19, 79, 20);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 19, 57, 20);
  Dlg^.Insert(New(PLabel, Init(R, '27:', Control)));

R.Assign(57, 20, 79, 21);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 20, 57, 21);
  Dlg^.Insert(New(PLabel, Init(R, '28:', Control)));

R.Assign(57, 21, 79, 22);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 21, 57, 22);
  Dlg^.Insert(New(PLabel, Init(R, '29:', Control)));

R.Assign(57, 22, 79, 23);
Control := New(PInputLine, Init(R, 64));
Dlg^.Insert(Control);

  R.Assign(53, 22, 57, 23);
  Dlg^.Insert(New(PLabel, Init(R, '30:', Control)));

R.Assign(1, 1, 79, 2);
Control := New(PColoredText, Init(R, 'Размещение экспорта', $5E));
Dlg^.Insert(Control);

R.Assign(1, 12, 79, 13);
Control := New(PColoredText, Init(R, 'Размещение импорта', $5E));
Dlg^.Insert(Control);

Dlg^.SelectNext(False);


(*
R.Assign(0, 3, 80, 20);
New(Dlg, Init(R, 'Экспорт/импорт'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E002;

R.Assign(12, 1, 40, 2);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 1, 12, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'Экспорт ~1~:', Control)));

R.Assign(12, 2, 40, 3);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 2, 12, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Экспорт ~2~:', Control)));

R.Assign(12, 3, 40, 4);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 3, 12, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Экспорт ~3~:', Control)));

R.Assign(12, 4, 40, 5);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 4, 12, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Экспорт ~4~:', Control)));

R.Assign(12, 5, 40, 6);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 5, 12, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Экспорт ~5~:', Control)));

R.Assign(12, 6, 40, 7);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 6, 12, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Экспорт ~6~:', Control)));

R.Assign(12, 7, 40, 8);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 7, 12, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'Экспорт ~7~:', Control)));

R.Assign(12, 8, 40, 9);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 8, 12, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Экспорт ~8~:', Control)));

R.Assign(12, 9, 40, 10);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 9, 12, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Экспорт ~9~:', Control)));

R.Assign(12, 10, 40, 11);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 10, 12, 11);
  Dlg^.Insert(New(PLabel, Init(R, 'Экспорт1~0~:', Control)));

R.Assign(12, 11, 40, 12);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 11, 12, 12);
  Dlg^.Insert(New(PLabel, Init(R, '~Э~кспорт11:', Control)));

R.Assign(12, 12, 40, 13);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 12, 12, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'Э~к~спорт12:', Control)));

R.Assign(12, 13, 40, 14);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 13, 12, 14);
  Dlg^.Insert(New(PLabel, Init(R, 'Эк~с~порт13:', Control)));

R.Assign(12, 14, 40, 15);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 14, 12, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Экс~п~орт14:', Control)));

R.Assign(12, 15, 40, 16);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 15, 12, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'Эксп~о~рт15:', Control)));

R.Assign(51, 1, 79, 2);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 1, 51, 2);
  Dlg^.Insert(New(PLabel, Init(R, '~И~мпорт 1:', Control)));

R.Assign(51, 2, 79, 3);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 2, 51, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'И~м~порт 2:', Control)));

R.Assign(51, 3, 79, 4);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 3, 51, 4);
  Dlg^.Insert(New(PLabel, Init(R, 'Импо~р~т 3:', Control)));

R.Assign(51, 4, 79, 5);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 4, 51, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Импор~т~ 4:', Control)));

R.Assign(51, 5, 79, 6);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 5, 51, 6);
  Dlg^.Insert(New(PLabel, Init(R, 'Импорт 5:', Control)));

R.Assign(51, 6, 79, 7);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 6, 51, 7);
  Dlg^.Insert(New(PLabel, Init(R, 'Импорт 6:', Control)));

R.Assign(51, 7, 79, 8);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 7, 51, 8);
  Dlg^.Insert(New(PLabel, Init(R, 'Импорт 7:', Control)));

R.Assign(51, 8, 79, 9);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 8, 51, 9);
  Dlg^.Insert(New(PLabel, Init(R, 'Импорт 8:', Control)));

R.Assign(51, 9, 79, 10);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 9, 51, 10);
  Dlg^.Insert(New(PLabel, Init(R, 'Импорт 9:', Control)));

R.Assign(51, 10, 79, 11);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 10, 51, 11);
  Dlg^.Insert(New(PLabel, Init(R, 'Импорт10:', Control)));

R.Assign(51, 11, 79, 12);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 11, 51, 12);
  Dlg^.Insert(New(PLabel, Init(R, 'Импорт11:', Control)));

R.Assign(51, 12, 79, 13);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 12, 51, 13);
  Dlg^.Insert(New(PLabel, Init(R, 'Импорт12:', Control)));

R.Assign(51, 13, 79, 14);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 13, 51, 14);
  Dlg^.Insert(New(PLabel, Init(R, 'Импорт13:', Control)));

R.Assign(51, 14, 79, 15);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 14, 51, 15);
  Dlg^.Insert(New(PLabel, Init(R, 'Импорт14:', Control)));

R.Assign(51, 15, 79, 16);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(41, 15, 51, 16);
  Dlg^.Insert(New(PLabel, Init(R, 'Импорт15:', Control)));

R.Assign(40, 1, 41, 17);
Control := New(PColoredText, Init(R, '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '│'^M+
     '╧', $3F));
Dlg^.Insert(Control);
*)

Dlg^.SetData(PathExpImp1^.Dat);

c:=Desktop^.ExecView(Dlg);
If c<>cmCAncel Then
 Begin
  Dlg^.GetData(PathExpImp^.Dat);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  WriteNewCfg(c);
  If c<> 0 Then Errors('Ошибка записи файла конфигурации !')
  Else AddProtocol('Корректировка настроек экспорта-импорта системы!!!','','')

 End
Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
Dispose(PathExpImp1,Done);

end;


Procedure ConfigDistantionSklads;
var
  Dlg : PDialog;
  R : TRect;
  c : LongInt;

  Control : PView;
  PathExpImp1:PDistantionSklads;

begin
New(PathExpImp1,Init);
PathExpImp1^.Dat:=PathSklads^.Dat;

R.Assign(0, 5, 80, 17);
New(Dlg, Init(R, 'Размещение баз складов'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E011;

For c:=1 To 10 Do
Begin
R.Assign(5, 0+C, 27, 1+C);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(1, 0+C, 5, 1+C);
  Dlg^.Insert(New(PLabel, Init(R, IntToStr(c,CMantissa)+':', Control)));
End;


For c:=1 To 10 Do
Begin
R.Assign(31, 0+C, 53, 1+C);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(27, 0+C, 31, 1+C);
  Dlg^.Insert(New(PLabel, Init(R, IntToStr(c+10,CMantissa)+':', Control)));
End;


For c:=1 To 10 Do
Begin
R.Assign(57, 0+C, 79, 1+C);
Control := New(PInputLine, Init(R, CSertif));
Dlg^.Insert(Control);

  R.Assign(53, 0+C, 57, 1+C);
  Dlg^.Insert(New(PLabel, Init(R, IntToStr(c+20,CMantissa)+':', Control)));
End;


Dlg^.SelectNext(False);


Dlg^.SetData(PathExpImp1^.Dat);

c:=Desktop^.ExecView(Dlg);
If c<>cmCAncel Then
 Begin
  Dlg^.GetData(PathSklads^.Dat);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  WriteNewCfg(c);
  If c<> 0 Then Errors('Ошибка записи файла конфигурации !')
  Else AddProtocol('Корректировка размещения складов!!!','','')

 End
Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
Dispose(PathExpImp1,Done);
end;







End.