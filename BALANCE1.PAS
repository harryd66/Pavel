{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Balance1;

Interface

Uses Glob,Dialogs,ServStr,Utils,Vision6;


Procedure CalcBalance1(Const Spis:PBox;Const M:Maska8;Const Assort,Sort:Word);

Implementation


Uses App,DBEngine,MsgBox,Tools,Printers,Objects,Views,TpDate,Vision3,
     NetDBEng,Serv,Utils4,Utils3,Utils5,ServStr2;

{Const ReadOnly = 0;}


Procedure CalcBalance1(Const Spis:PBox;Const M:Maska8;Const Assort,Sort:Word);

Const
CPack=12;
CMantissa=4;
BName=1;
BArtikul   =1+CName+1;
BPrihod    =1+CName+1+CArtikul+1+CPack+1;
BMarket    =1+CName+1+CArtikul+1+CPack+1+CPack+1;
BRewizia   =1+CName+1+CArtikul+1+CPAck+1+CPAck+1+CPack+1;
BReturn    =1+CName+1+CArtikul+1+CPAck+1+CPAck+1+CPAck+1+CPack+1;
BPereozenka=1+CName+1+CArtikul+1+CPAck+1+CPAck+1+CPAck+1+CPack+1+CPack+1;
Shb='        0.00│        0.00│        0.00│        0.00│        0.00│        0.00│        0.00';

    {123456789012│123456789012│123456789012│123456789012│
    123456789012│123456789012│123456789012 123456789 123456789 123456789 123456789 123456789 123456789 123456123456}
Var R,R1 : TRect;
    Txt : Text;
    rs,s,ss : String;
    ws,ws1,ws2 : String;
    Reiting,SumKol,Ext,Space : TEnJoyStr;
    TempList : PBox;
    WspomList1,WspomList: PBox;
    EdIzm,Regim : Word;
    Separator : ArtikulStr;
    SInPack,MarketKol,MarketPack:string[CPack];
    Art,PositionZena,Date : TDateString;
    l,l1,EE,EE1 : LongInt;
    Pos,j,i,Srok,Day: Word;
    Start,Stop : TDAteString;
    Itg : PNewItogType;
    ItogFile  : File Of NewItogType;
    Cl : Word;
    VidZen : Word;
    BakFileMode : Word;



Function LoadCurrentDB(Var WspomList,TempList:PBox;Const Regim:Word):Boolean;
Var c : Word;
    k,cc,L,Count : Word;
    All : LongInt;
    ws,S : String;
    SklFile : File;
    Skl : PBufSkladType;
begin
 LoadCurrentDB:=FAlse;
 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  DInfoMsgShkala('Балансировка. Загружаю текущие остатки товаров...',0,TempList^.List^.Count-1,l);
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);

   Assign(SklFile,Path^.Dat.ToSklad+s+'.db');
   c:=IOResult;
   BakFileMode:=FileMode;
   FileMode:=ReadOnlyN;
   Reset(SklFile,SizeOf(SkladType));
   c:=IOResult;
   FileMode:=BAkFileMode;

If c<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToSklad+S+'.db',Nil,mfError+mfCancelButton);
  Exit;
 End;

   While Not(Eof(sklFile)) Do
    Begin
     New(Skl,Init);
     Count:=0;
     ReadBufSklad(SklFile,Skl,Count);

For cc:=1 To Count Do
Begin

     With Skl^.Point.Dat[cc].Input Do
     Begin
      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(Division[k]):CKol,Division[k]);
           DelSpace(Division[k]);
           All:=All+StrToInt(Division[k]);
        End;

        Str(All:CKol,Skl^.Point.Dat[cc].Input.Kol);
        DelSpace(Skl^.Point.Dat[cc].Input.Kol);

        If TestElementSpis (Copy(Skl^.Point.Dat[cc].BAzKod,1,CRAzdelKod),TempList,regim) Then
          Begin
           If Not(TestElement(Skl^.Point.Dat[cc].BAzKod,WspomList)) Then
            Begin{позиция уже есть-нужно вставит только нове колич}
             Pos:= Location(WspomList,Skl^.Point.Dat[cc].BAzKod,False);
             ws := WspomList^.GetText(pos,WspomList^.List^.Count);
             s:=Copy(ws,Ord(ws[0])-CPack+1,CPack);
             Delete(ws,Ord(ws[0])-CPack+1,CPack);


             If VidZen=0 Then
             Str(StrToReal(s)+{Itg^.Dat.OstE}StrToInt(Skl^.Point.Dat[cc].Input.Kol)*
		   StrToReal(Skl^.Point.Dat[cc].Input.R_Zena):CPAck:CMantissa,s)
             Else
             {Str(StrToReal(s)+Itg^.Dat.OstEZ:CPAck:CMantissa,s);}
             Str(StrToReal(s)+StrToInt(Skl^.Point.Dat[cc].Input.Kol)*
		   StrToReal(Skl^.Point.Dat[cc].Input.Zakupka):CPAck:CMantissa,s);

             ws:=ws+s;

             WspomList^.List^.AtFree(Pos);
             WspomList^.SetRange(WspomList^.List^.Count);

             WspomList^.List^.Insert(NewStr(ws));
             WspomList^.SetRange(WspomList^.List^.Count);
            End{If Not(TestElement(Itg^.Dat.BAzKod,WspomList)) Then}
           Else
            Begin
             ws:=GetIdField(FNAme,Skl^.Point.Dat[cc].BAzKod);
             Format(ws,CNAme);
             ws:=ws+'│'+Skl^.Point.Dat[cc].BAzKod+'│'+Shb;
             Delete(ws,Ord(ws[0])-CPack+1,CPAck);

             If VidZen=0 Then
             Str(StrToInt(Skl^.Point.Dat[cc].Input.Kol)*
		   StrToReal(Skl^.Point.Dat[cc].Input.R_Zena):CPAck:CMantissa,s)
             Else
             Str(StrToInt(Skl^.Point.Dat[cc].Input.Kol)*
		   StrToReal(Skl^.Point.Dat[cc].Input.Zakupka):CPAck:CMantissa,s);

             ws:=ws+s;
             WspomList^.List^.Insert(NewStr(ws));
             WspomList^.SetRange(WspomList^.List^.Count);
            End;
          End{If TestElementSpis (Copy(Itg^.Dat.BAzKod,1,CRAzdelKod),TempList,regim) Then}
     End;{With}
End;
    Dispose(Skl,Done);
   End;{While}

   c:=IOResult;
   Close(SklFile);
   c:=IOResult;
   End;
NoInfoMsg;

LoadCurrentDB:=True;
End;



Procedure BCalcRewisia(L:LongInt;Var TL,WL:PBox);
Var F : RewisiaFileType;
    Es : PRewisiaType;
    i,j : Word;
Begin
 Assign(F,Path^.Dat.ToRewisia+DAteToDAteString(DateMask,L)+'.rwz');
 l:=IOResult;
 BakFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(f);
 l:=Ioresult;
 FileMode:=BakFileMode;
 If L <> 0 Then
  Begin
   Exit;
  End;
 New(Es,Init);
 While Not(Eof(f)) Do
  Begin
   ReadRewisia(f,Es);
    For j:=1 To Es^.Dat.Amount Do
     Begin
        If TestElementSpis(Copy(Es^.Dat.Element[j].BAzKod,1,CRAzdelKod),Tl,regim) Then
          Begin
           If Not(TestElement(Es^.Dat.Element[j].BAzKod,WL)) Then
            Begin{позиция уже есть-нужно вставит только нове колич}
             Pos:= Location(WL,Es^.Dat.Element[j].BAzKod,False);
             ws := WL^.GetText(pos,WL^.List^.Count);
             s:=Copy(ws,BRewizia,CPack);
             Delete(ws,BRewizia,CPAck);
             For i:=1 To CDivision Do
             Begin
             If VidZen=0 Then
             Str(StrToReal(s)+StrToInt(Es^.Dat.Element[j].Input.Division[i])*
		   StrToReal(Es^.Dat.Element[j].Input.R_Zena):CPAck:CMantissa,s)
             Else
             Str(StrToReal(s)+StrToInt(Es^.Dat.Element[j].Input.Division[i])*
		   StrToReal(Es^.Dat.Element[j].Input.Zakupka):CPAck:CMantissa,s);
             End;
             Insert(s,ws,BRewizia);
             WL^.List^.AtFree(Pos);
             WL^.SetRange(WL^.List^.Count);
             WL^.List^.Insert(NewStr(ws));
             WL^.SetRange(WL^.List^.Count);
            End
           Else
            Begin{позиции нет в списке ее нужно добавит заново}
             ws:=GetIdField(FNAme,Es^.Dat.Element[j].BAzKod);
             Format(ws,CNAme);
             ws:=ws+'│'+Es^.Dat.Element[j].BAzKod+'│'+Shb;
             Delete(ws,BRewizia,CPAck);
             s:='        0.00';
                {123456789}
             For i:=1 To CDivision Do
             Begin
             If VidZen=0 Then
             Str(StrToReal(s)+StrToInt(Es^.Dat.Element[j].Input.Division[i])*
		   StrToReal(Es^.Dat.Element[j].Input.R_Zena):CPAck:CMAntissa,s)
             Else
             Str(StrToReal(s)+StrToInt(Es^.Dat.Element[j].Input.Division[i])*
		   StrToReal(Es^.Dat.Element[j].Input.Zakupka):CPAck:CMAntissa,s)
             End;
             Insert(s,ws,BRewizia);
             WL^.List^.Insert(NewStr(ws));
             WL^.SetRange(WL^.List^.Count);
            End;
          End;{если раздел нужно балансировать}
     End;
  End;{While}
 Dispose(Es,Done);
 Close(f);
End;




Procedure BCalcOtgruzka_RP(L:LongInt;Var TL,WL:PBox);
Var F : MarketFileType;
    Es : PSuperMarketType;
    i,j : Word;
Begin
 Assign(F,Path^.Dat.ToMarket+DAteToDAteString(DateMask,L)+'.mrk');
 l:=IOResult;
   BakFileMode:=FileMode;
   FileMode:=ReadOnlyN;
 Reset(f);
 l:=Ioresult;
   FileMode:=BakFileMode;
 If L <> 0 Then
  Begin
   Exit;
  End;
 New(Es,Init);
 While Not(Eof(f)) Do
  Begin
   ReadMarket(f,Es);
   If (Es^.Dat.Active) Then
   If ((Es^.Dat.Realiz)And(Es^.Dat.DocSelector in [5,6,7,8])) Or
      ((Es^.Dat.DocSelector in [0,1,2,3,4]) And Not(Es^.Dat.Realiz)) Then
    For j:=1 To Es^.Dat.Amount Do
     Begin
        If TestElementSpis(Copy(Es^.Dat.MarketElement[j].BAzKod,1,CRAzdelKod),Tl,regim) Then
          Begin
           If Not(TestElement(Es^.Dat.MarketElement[j].BAzKod,WL)) Then
            Begin{позиция уже есть-нужно вставит только нове колич}
             Pos:= Location(WL,Es^.Dat.MarketElement[j].BAzKod,False);
             ws := WL^.GetText(pos,WL^.List^.Count);
             s:=Copy(ws,BMarket,CPack);
             Delete(ws,BMarket,CPAck);

             If VidZen=0 Then
             Str(StrToReal(s)+StrToInt(Es^.Dat.MarketElement[j].Input.Kol)*
             StrToReal(Es^.Dat.MarketElement[j].Input.R_Zena):CPAck:CMAntissa,s)
             Else
             Str(StrToReal(s)+StrToInt(Es^.Dat.MarketElement[j].Input.Kol)*
             StrToReal(Es^.Dat.MarketElement[j].Input.Zakupka):CPAck:CMAntissa,s);
             Insert(s,ws,BMarket);
             WL^.List^.AtFree(Pos);
             WL^.SetRange(WL^.List^.Count);
             WL^.List^.Insert(NewStr(ws));
             WL^.SetRange(WL^.List^.Count);
            End
           Else
            Begin{позиции нет в списке ее нужно добавит заново}
             ws:=GetIdField(FNAme,Es^.Dat.MarketElement[j].BAzKod);
             Format(ws,CNAme);
             ws:=ws+'│'+Es^.Dat.MarketElement[j].BAzKod+'│'+Shb;
             Delete(ws,BMarket,CPAck);
             s:='        0.00';
                {123456789}
             If VidZen=0 Then
             Str(StrToReal(s)+StrToInt(Es^.Dat.MarketElement[j].Input.Kol)
		   *StrToReal(Es^.Dat.MarketElement[j].Input.R_Zena):CPAck:CMAntissa,s)
             Else
             Str(StrToReal(s)+StrToInt(Es^.Dat.MarketElement[j].Input.Kol)
		   *StrToReal(Es^.Dat.MarketElement[j].Input.Zakupka):CPAck:CMAntissa,s);

             Insert(s,ws,BMarket);
             WL^.List^.Insert(NewStr(ws));
             WL^.SetRange(WL^.List^.Count);
            End;
          End;{если раздел нужно балансировать}
     End;


   If (Es^.Dat.Active) Then
   If ((Es^.Dat.Realiz)And(Es^.Dat.DocSelector in [5,6,7,8])) Or
      ((Es^.Dat.DocSelector in [0,1,2,3,4]) And Not(Es^.Dat.Realiz)) Then
    For j:=1 To Es^.Dat.AmountS Do
     Begin
        If TestElementSpis(Copy(Es^.Dat.DocumentElement[j].BAzKod,1,CRAzdelKod),Tl,regim) Then
          Begin
           If Not(TestElement(Es^.Dat.DocumentElement[j].BAzKod,WL)) Then
            Begin{позиция уже есть-нужно вставит только нове колич}
             Pos:= Location(WL,Es^.Dat.DocumentElement[j].BAzKod,False);
             ws := WL^.GetText(pos,WL^.List^.Count);
             s:=Copy(ws,BMarket,CPack);
             Delete(ws,BMarket,CPAck);
             If VidZen=0 Then
             Str(StrToReal(s)+StrToInt(Es^.Dat.DocumentElement[j].Input.Kol)*
             StrToReal(Es^.Dat.DocumentElement[j].Input.R_Zena):CPAck:CMantissa,s)
             Else
             Str(StrToReal(s)+StrToInt(Es^.Dat.DocumentElement[j].Input.Kol)*
             StrToReal(Es^.Dat.DocumentElement[j].Input.Zakupka):CPAck:CMantissa,s);

             Insert(s,ws,BMarket);
             WL^.List^.AtFree(Pos);
             WL^.SetRange(WL^.List^.Count);
             WL^.List^.Insert(NewStr(ws));
             WL^.SetRange(WL^.List^.Count);
            End
           Else
            Begin{позиции нет в списке ее нужно добавит заново}
             ws:=GetIdField(FNAme,Es^.Dat.DocumentElement[j].BAzKod);
             Format(ws,CNAme);
             ws:=ws+'│'+Es^.Dat.DocumentElement[j].BAzKod+'│'+Shb;
             Delete(ws,BMarket,CPAck);
             s:='        0.00';
                {123456789}
             If VidZen=0 Then
             Str(StrToReal(s)+StrToInt(Es^.Dat.DocumentElement[j].Input.Kol)*
		   StrToReal(Es^.Dat.DocumentElement[j].Input.R_Zena):CPAck:CMantissa,s)
             Else
             Str(StrToReal(s)+StrToInt(Es^.Dat.DocumentElement[j].Input.Kol)*
		   StrToReal(Es^.Dat.DocumentElement[j].Input.Zakupka):CPAck:CMantissa,s);

             Insert(s,ws,BMarket);
             WL^.List^.Insert(NewStr(ws));
             WL^.SetRange(WL^.List^.Count);
            End;
          End;{если раздел нужно балансировать}
     End;

  End;{While}
 Dispose(Es,Done);
 Close(f);
End;



Procedure BCalcReturn(L:LongInt;Var TL,WL:PBox);
Var F : NewVozwratFileType;
    Es : PNewVozwratType;
    i,j : Word;
Begin
 Assign(F,Path^.Dat.ToReturn+DAteToDAteString(DateMask,L)+'.vzw');
 l:=IOResult;
   BakFileMode:=FileMode;
   FileMode:=ReadOnlyN;
 Reset(f);
 l:=Ioresult;
   FileMode:=BakFileMode;
 If L <> 0 Then
  Begin
   Exit;
  End;
 New(Es,Init);
 While Not(Eof(f)) Do
  Begin
   ReadNewVozwrat(f,Es);
   If (Es^.Dat.StatusDoc=0) Then
    For j:=1 To Es^.Dat.Amount Do
     Begin
        If TestElementSpis(Copy(Es^.Dat.VozwratElement[j].BAzKod,1,CRAzdelKod),Tl,regim) Then
          Begin
           If Not(TestElement(Es^.Dat.VozwratElement[j].BAzKod,WL)) Then
            Begin{позиция уже есть-нужно вставит только нове колич}
             Pos:= Location(WL,Es^.Dat.VozwratElement[j].BAzKod,False);
             ws := WL^.GetText(pos,WL^.List^.Count);
             s:=Copy(ws,BReturn,CPack);
             Delete(ws,BReturn,CPAck);
             If VidZen=0 Then
             Str(StrToReal(s)+StrToInt(Es^.Dat.VozwratElement[j].Input.Kol)*
		   StrToReal(Es^.Dat.VozwratElement[j].Input.R_Zena):CPAck:CMantissa,s)
             Else
             Str(StrToReal(s)+StrToInt(Es^.Dat.VozwratElement[j].Input.Kol)*
		   StrToReal(Es^.Dat.VozwratElement[j].Input.Zakupka):CPAck:CMantissa,s);

             Insert(s,ws,BReturn);
             WL^.List^.AtFree(Pos);
             WL^.SetRange(WL^.List^.Count);
             WL^.List^.Insert(NewStr(ws));
             WL^.SetRange(WL^.List^.Count);
            End
           Else
            Begin{позиции нет в списке ее нужно добавит заново}
             ws:=GetIdField(FNAme,Es^.Dat.VozwratElement[j].BAzKod);
             Format(ws,CNAme);
             ws:=ws+'│'+Es^.Dat.VozwratElement[j].BAzKod+'│'+Shb;
             Delete(ws,BReturn,CPAck);
             s:='        0.00';
                {123456789}
             If VidZen=0 Then
             Str(StrToReal(s)+StrToInt(Es^.Dat.VozwratElement[j].Input.Kol)*
             StrToReal(Es^.Dat.VozwratElement[j].Input.R_Zena):CPAck:CMantissa,s)
             Else
             Str(StrToReal(s)+StrToInt(Es^.Dat.VozwratElement[j].Input.Kol)*
             StrToReal(Es^.Dat.VozwratElement[j].Input.Zakupka):CPAck:CMantissa,s);

             Insert(s,ws,BReturn);
             WL^.List^.Insert(NewStr(ws));
             WL^.SetRange(WL^.List^.Count);
            End;
          End;{если раздел нужно балансировать}
     End;
  End;{While}
 Dispose(Es,Done);
 Close(f);
End;

Procedure BCalcPereozenka(L:LongInt;Var TL,WL:PBox);
Var F : PereozenkaFileType;
    Es : PPereozenkaType;
    i,j : Word;
Begin
 Assign(F,Path^.Dat.ToCorrect+DAteToDAteString(DateMask,L)+'.prz');
 l:=IOResult;
   BakFileMode:=FileMode;
   FileMode:=ReadOnlyN;
 Reset(f);
 l:=Ioresult;
   FileMode:=BakFileMode;
 If L <> 0 Then
  Begin
   Exit;
  End;
 New(Es,Init);
 While Not(Eof(f)) Do
  Begin
   ReadPereozenka(f,Es);
    For j:=1 To Es^.Dat.Amount Do
     Begin
        If TestElementSpis(Copy(Es^.Dat.Element[j].BAzKod,1,CRAzdelKod),Tl,regim) Then
          Begin
           If Not(TestElement(Es^.Dat.Element[j].BAzKod,WL)) Then
            Begin{позиция уже есть-нужно вставит только нове колич}
             Pos:= Location(WL,Es^.Dat.Element[j].BAzKod,False);
             ws := WL^.GetText(pos,WL^.List^.Count);
             s:=Copy(ws,BPereozenka,CPack);
             Delete(ws,BPereozenka,CPAck);
             Str(StrToReal(s)+StrToInt(Es^.Dat.Element[j].Kol)*
		  (StrToReal(Es^.Dat.Element[j].New_R_Zena)-
             StrToReal(Es^.Dat.Element[j].Bak_R_Zena))
		   :CPAck:CMantissa,s);{для случая недель}
             Insert(s,ws,BPereozenka);
             WL^.List^.AtFree(Pos);
             WL^.SetRange(WL^.List^.Count);
             WL^.List^.Insert(NewStr(ws));
             WL^.SetRange(WL^.List^.Count);
            End
           Else
            Begin{позиции нет в списке ее нужно добавит заново}
             ws:=GetIdField(FNAme,Es^.Dat.Element[j].BAzKod);
             Format(ws,CNAme);
             ws:=ws+'│'+Es^.Dat.Element[j].BAzKod+'│'+Shb;
             Delete(ws,BPereozenka,CPAck);
             s:='        0.00';
                {123456789}
             Str(StrToReal(s)+StrToInt(Es^.Dat.Element[j].Kol)*
             (StrToReal(Es^.Dat.Element[j].New_R_Zena)
             -StrToReal(Es^.Dat.Element[j].Bak_R_Zena))
		   :CPAck:CMantissa,s);{для случая недель}

             Insert(s,ws,BPereozenka);
             WL^.List^.Insert(NewStr(ws));
             WL^.SetRange(WL^.List^.Count);
            End;
          End;{если раздел нужно балансировать}
     End;
  End;{While}
 Dispose(Es,Done);
 Close(f);
End;




Procedure BCalcPrihod(L:LongInt;Var TL,WL:PBox);
Var F : PrihodFileType;
    Es : PPrihodType;
    i,j : Word;
Begin
 Assign(F,Path^.Dat.ToPrihod+DAteToDAteString(DateMask,L)+'.prh');
 l:=IOResult;
   BakFileMode:=FileMode;
   FileMode:=ReadOnlyN;
 Reset(f);
 l:=Ioresult;
   FileMode:=BakFileMode;
 If L <> 0 Then
  Begin
   Exit;
  End;
 New(Es,Init);
 While Not(Eof(f)) Do
  Begin
   ReadPrihod(f,Es);
   If (Es^.Dat.StatusDoc=0) Then
    For j:=1 To Es^.Dat.Amount Do
     Begin
        If TestElementSpis(Copy(Es^.Dat.PrihodElement[j].BAzKod,1,CRAzdelKod),Tl,regim) Then
          Begin
           If Not(TestElement(Es^.Dat.PrihodElement[j].BAzKod,WL)) Then
            Begin{позиция уже есть-нужно вставит только нове колич}
             Pos:= Location(WL,Es^.Dat.PrihodElement[j].BAzKod,False);
             ws := WL^.GetText(pos,WL^.List^.Count);
             s:=Copy(ws,BPrihod,CPack);
             Delete(ws,BPrihod,CPAck);
             For i:=1 To CDivision Do
             Begin
             If VidZen=0 Then
             Str(StrToReal(s)+StrToInt(Es^.Dat.PrihodElement[j].Input.Division[i])*
             StrToReal(Es^.Dat.PrihodElement[j].Input.R_Zena):CPAck:CMantissa,s)
             Else
             Str(StrToReal(s)+StrToInt(Es^.Dat.PrihodElement[j].Input.Division[i])*
             StrToReal(Es^.Dat.PrihodElement[j].Input.Zakupka):CPAck:CMantissa,s);
             End;
             Insert(s,ws,BPrihod);
             WL^.List^.AtFree(Pos);
             WL^.SetRange(WL^.List^.Count);
             WL^.List^.Insert(NewStr(ws));
             WL^.SetRange(WL^.List^.Count);
            End
           Else
            Begin{позиции нет в списке ее нужно добавит заново}
             ws:=GetIdField(FNAme,Es^.Dat.PrihodElement[j].BAzKod);
             Format(ws,CNAme);
             ws:=ws+'│'+Es^.Dat.PrihodElement[j].BAzKod+'│'+Shb;
             Delete(ws,BPrihod,CPAck);
             s:='        0';
                {123456789}
             For i:=1 To CDivision Do
             Begin
             If VidZen=0 Then
             Str(StrToReal(s)+StrToInt(Es^.Dat.PrihodElement[j].Input.Division[i])*
		   StrToReal(Es^.Dat.PrihodElement[j].Input.R_Zena):CPAck:CMAntissa,s)
             Else
             Str(StrToReal(s)+StrToInt(Es^.Dat.PrihodElement[j].Input.Division[i])*
		   StrToReal(Es^.Dat.PrihodElement[j].Input.Zakupka):CPAck:CMAntissa,s);
             End;
             Insert(s,ws,BPrihod);
             WL^.List^.Insert(NewStr(ws));
             WL^.SetRange(WL^.List^.Count);
            End;
          End;{если раздел нужно балансировать}
     End;
  End;{While}
 Dispose(Es,Done);
 Close(f);
End;



 Var jk: LongInt;
     AllOperation,SumBalance,Bal : Real;
     Shapka: Array [1..3] Of String;
     FileName : TDateString;
     RegReport : Word;

Begin

  VidZen:=SelectImport(22);
  If VidZen=2 Then Exit;


If Not(DAtePeriodDialog(Start,Stop,False)) Then
   Begin
    Exit;
   End;

RegReport:=SelectImport(26);
If RegReport=2 Then Exit;


EE:=DateStringToDate(DateMask,Stop);
EE1:=DateStringToDate(DateMask,Start)-1;


 Separator:=' ';
 Assign(Txt,Path^.Dat.ToTemp+'bn1.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'bn1.txt',Nil,mfError+mfCancelButton);
   {Dispose(Spis,Done);}
   Exit;
  End;
 Close(txt);


  R.Assign(0,0,0,0);
  TemplIST := New(PBox, Init(R, 1, Nil));
  TempList^.NewList(New(PTextCollection, Init(0,1)));
  For L:=0 To Spis^.List^.Count-1 Do
 Begin
  s:=Spis^.GetText(l,Spis^.List^.Count);
  TempList^.List^.Insert(NewStr(s));
  TempList^.SetRange(TempList^.List^.Count);
 End;
 {Dispose(Spis,Done);}

 Regim:=SelectSort;

   CAse Regim Of
   0:Begin
  R1.Assign(0,0,0,0);
  WspomlIST := New(PBox, Init(R1, 1, Nil));
  WspomList^.NewList(New(PTextCollection, Init(0,1)));
  For L:=0 To TempList^.List^.Count-1 Do
   Begin
    s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod)+'│'+
       Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdel);
    WspomList^.List^.Insert(NewStr(s));
    WspomList^.SetRange(WspomList^.List^.Count);
   End;

  TEmpList^.NewList(Nil);
  TEmpList^.NewList(New(PTextCollection, Init(0,1)));
  For L:=0 To WspomList^.List^.Count-1 Do
   Begin
    s:=WspomList^.GetText(l,WspomList^.List^.Count);
    TempList^.List^.Insert(NewStr(s));
    TempList^.SetRange(TempList^.List^.Count);
   End;
   Dispose(WspomList,Done);

     End;
   2:Begin
      Dispose(TempList,Done);
      Exit;
     End;

   Else;
   End;


  DInfo('Загружаю базу остатков...');
  Append(txt);
  Space:='   ';
  Writeln(Txt,Header+Space+'Склад:'+FormKod(Rek^.Dat.Kod)+' Оператор: '+CurrentPassword);
  Writeln(Txt,Space+'Дата и время расчета: '+FDate+'  ('+Times+')');
  Write(Txt,Space+'Вид сортировки товара: ');
  Case Sort Of
  1:Writeln(txt,'{По наименованию}');
  0:Writeln(txt,'{По кодам}');
  Else Writeln(txt);
  End;

  Write(Txt,Space+'Вид сортировки разделов: ');
  Case Regim Of
  1:Writeln(txt,'{По наименованиям разделов}');
  0:Writeln(txt,'{По кодам разделов}');
  Else Writeln(txt);
  End;
  Write(Txt,Space+'Единицы измерения:');
  Case VidZen Of
  1:Writeln(txt,'{По закупочным ценам}');
  0:Writeln(txt,'{По розничным ценам}');
  Else Writeln(txt);
  End;
  Write(Txt,Space+'Вид отчета: ');
  Case RegReport Of
  0:Writeln(txt,'{Полный отчет}');
  1:Writeln(txt,'{Только разногласия}');
  Else Writeln(txt);
  End;

  Writeln(txt);

 s:=' Код'+SeparatorChar+' Наименование товара'+SeparatorChar+'      Ост.'+DAteToDAteString('dd.mm.yy',EE1)+
 SeparatorChar+'   Приход'+SeparatorChar+'   Отг.и Р/П'+SeparatorChar+
 '     Ревизия'+SeparatorChar+'     Возврат'+SeparatorChar+'  Переоценка'+SeparatorChar+
 '   Ост.'+DAteToDAteString('dd.mm.yy',EE)+SeparatorChar;
                                        {12345 12345678901234567890123456 123456789 123456789 123456789 123456789 123456789}
Space[0]:=#0;
Writeln(Txt,Space+' БАЛАНСИРОВКА ТОВАРНОГО НАЛИЧИЯ за период с '+DAteToDateString(DAteMask,EE1+1)+' по '+Stop);
Writeln(Txt,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]);
Str(StrToInt(Rek^.Dat.Kod):2,Ext);
RFormatZerro(Ext,2);

Space[0]:=#0;

ws[0]:=#0;
For l:=1 To Ord(s[0]) Do
Begin
ws[l]:='_';
ws[0]:=Chr(l);
End;

rs:=ws;

{
Writeln(Txt,Space+ws);
Writeln(Txt,Space+s);
Writeln(Txt,Space+ws);
}

Shapka[1]:=ws;
Shapka[2]:=s;
Shapka[3]:=ws+HeaderStop;


  Writeln(Txt,Space+Shapka[1]);
  Writeln(Txt,Space+Shapka[2]);
  Writeln(Txt,Space+Shapka[3]);



  R1.Assign(0,0,0,0);
  WspomlIST := New(PBox, Init(R1, 1, Nil));
  WspomList^.NewList(New(PTextCollection, Init(0,1)));
  New(Itg,Init);

    Str(StrToInt(Rek^.Dat.Kod):2,Ext);
    RFormatZerro(Ext,2);
    s:=DAteToDAteString(DateMask,EE1);
    FileName:=s;
    ClearChar(FileName);
    Assign(ItogFile,Path^.Dat.ToArchiv+FileName+'.p'+Ext);
    i:=IOResult;
    BakFileMode:=FileMode;
    FileMode:=ReadOnlyN;
    Reset(ItogFile);
    i:=IOResult;
    FileMode:=BakFileMode;
    If i=0 Then
     Begin
      While Not(Eof(ItogFile)) Do
       Begin
        Read(ItogFile,Itg^.Dat);
        If TestElementSpis (Copy(Itg^.Dat.BAzKod,1,CRAzdelKod),TempList,regim) Then
          Begin
           If Not(TestElement(Itg^.Dat.BAzKod,WspomList)) Then
            Begin{позиция уже есть-нужно вставит только нове колич}
             Pos:= Location(WspomList,Itg^.Dat.BAzKod,False);
             ws := WspomList^.GetText(pos,WspomList^.List^.Count);
             s:=Copy(ws,1+CName+1+CArtikul+1,CPack);
             Delete(ws,1+CName+1+CArtikul+1,CPAck);

             If VidZen=0 Then
             Str(StrToReal(s)+Itg^.Dat.OstE:CPAck:CMantissa,s)
             Else
             Str(StrToReal(s)+Itg^.Dat.OstEZ:CPAck:CMantissa,s);

             Insert(s,ws,1+CName+1+CArtikul+1);

             WspomList^.List^.AtFree(Pos);
             WspomList^.SetRange(WspomList^.List^.Count);

             WspomList^.List^.Insert(NewStr(ws));
             WspomList^.SetRange(WspomList^.List^.Count);
            End{If Not(TestElement(Itg^.Dat.BAzKod,WspomList)) Then}
           Else
            Begin
             ws:=GetIdField(FNAme,Itg^.Dat.BAzKod);
             Format(ws,CNAme);
             ws:=ws+'│'+Itg^.Dat.BAzKod+'│'+Shb;
             Delete(ws,1+CName+1+CArtikul+1,CPAck);

             If VidZen=0 Then
             Str(Itg^.Dat.OstE:CPAck:CMantissa,s)
             Else
             Str(Itg^.Dat.OstEZ:CPAck:CMantissa,s);

             Insert(s,ws,1+CName+1+CArtikul+1);
             WspomList^.List^.Insert(NewStr(ws));
             WspomList^.SetRange(WspomList^.List^.Count);
            End;
          End{If TestElementSpis (Copy(Itg^.Dat.BAzKod,1,CRAzdelKod),TempList,regim) Then}
      End;{Wihle}
      Close(ItogFile);
     End{i=0}
    Else
     Begin
      Dispose(Itg,Done);
      Dispose(WspomList,Done);
      Dispose(TempList,Done);
      NoInfo;
      Close(txt);
      MessageBox(^M+#3+'Не найдена база остатков за '+FileName+'!'^M+
         #3'Не могу провести балансировку!',Nil,mfError+mfCancelButton);
      Exit;
     End;

    Str(StrToInt(Rek^.Dat.Kod):2,Ext);
    RFormatZerro(Ext,2);
    s:=DAteToDAteString(DateMask,EE);
    FileName:=s;
    ClearChar(FileName);
    Assign(ItogFile,Path^.Dat.ToArchiv+FileName+'.p'+Ext);
    i:=IOResult;
   BakFileMode:=FileMode;
   FileMode:=ReadOnlyN;
    Reset(ItogFile);
    i:=IOResult;
   FileMode:=BakFileMode;
    If i=0 Then
     Begin
      While Not(Eof(ItogFile)) Do
       Begin
        Read(ItogFile,Itg^.Dat);
        If TestElementSpis (Copy(Itg^.Dat.BAzKod,1,CRAzdelKod),TempList,regim) Then
          Begin
           If Not(TestElement(Itg^.Dat.BAzKod,WspomList)) Then
            Begin{позиция уже есть-нужно вставит только нове колич}
             Pos:= Location(WspomList,Itg^.Dat.BAzKod,False);
             ws := WspomList^.GetText(pos,WspomList^.List^.Count);
             s:=Copy(ws,Ord(ws[0])-CPack+1,CPack);
             Delete(ws,Ord(ws[0])-CPack+1,CPack);


             If VidZen=0 Then
             Str(StrToReal(s)+Itg^.Dat.OstE:CPAck:CMantissa,s)
             Else
             Str(StrToReal(s)+Itg^.Dat.OstEZ:CPAck:CMantissa,s);

             ws:=ws+s;

             WspomList^.List^.AtFree(Pos);
             WspomList^.SetRange(WspomList^.List^.Count);

             WspomList^.List^.Insert(NewStr(ws));
             WspomList^.SetRange(WspomList^.List^.Count);
            End{If Not(TestElement(Itg^.Dat.BAzKod,WspomList)) Then}
           Else
            Begin
             ws:=GetIdField(FNAme,Itg^.Dat.BAzKod);
             Format(ws,CNAme);
             ws:=ws+'│'+Itg^.Dat.BAzKod+'│'+Shb;
             Delete(ws,Ord(ws[0])-CPack+1,CPAck);
             If VidZen=0 Then
             Str(Itg^.Dat.OstE:CPAck:CMantissa,s)
             Else
             Str(Itg^.Dat.OstEZ:CPAck:CMantissa,s);

             ws:=ws+s;
             WspomList^.List^.Insert(NewStr(ws));
             WspomList^.SetRange(WspomList^.List^.Count);
            End;
          End{If TestElementSpis (Copy(Itg^.Dat.BAzKod,1,CRAzdelKod),TempList,regim) Then}
      End;{Wihle}
      Close(ItogFile);
     End
    Else
     Begin
      NoInfo;
      If MessageBox(^M+#3+'Не найдена база остатков за '+FileName+'!'^M+
         #3'Использовать текущие остатки?',Nil,mfError+mfOkCancel)=cmCancel Then
         Begin
      Dispose(Itg,Done);
      Dispose(WspomList,Done);
      Dispose(TempList,Done);
      Close(txt);
      Exit;
         End
          Else
           Begin
            If Not LoadCurrentDB(WspomList,TempList,Regim) Then
              Begin
               Dispose(Itg,Done);
               Dispose(WspomList,Done);
               Dispose(TempList,Done);
               Close(txt);
               Exit;
              End;
           End;
     End;

(*   Begin
      Dispose(Itg,Done);
      Dispose(WspomList,Done);
      Dispose(TempList,Done);
      NoInfo;
      Close(txt);
      MessageBox(^M+#3+'Не найдена база остатков за '+FileName+'!'^M+
         #3'Не могу провести балансировку!',Nil,mfError+mfCancelButton);
      Exit;
     End;
*)
  Dispose(Itg,Done);

NoInfo;

  For L:=EE1+1 To EE Do
   Begin
   DInfoMsgShkala('Провожу балансировку товаров...',EE1+1,EE,l);
   BCalcPrihod(L,TempList,WspomList);
   BCalcOtgruzka_RP(L,TempList,WspomList);
   BCalcRewisia(L,TempList,WspomList);
   BCalcReturn(L,TempList,WspomList);
   If VidZen=0 Then BCalcPereozenka(L,TempList,WspomList);
   End;
   NoInfoMsg;

If WspomList^.List^.Count>=1 Then
 Begin
 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  DInfoMsgShkala('Балансировка. Формирую отчет ...',0,TempList^.List^.Count-1,l);
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);

If TestElementSpis (S,WspomList,Sort) Then
Begin
  Writeln(Txt);
  Writeln(Txt,Space+'Раздел: '+GetRazdel(s));
  {
  Writeln(Txt,Space+Shapka[1]);
  Writeln(Txt,Space+Shapka[2]);
  Writeln(Txt,Space+Shapka[3]);
  }
  For j:=0 To WspomList^.List^.Count-1 Do
   Begin
    ws:=WspomList^.GetText(j,WspomList^.List^.Count);
    If Sort=0 Then Delete(ws,1,CArtikul+1);
    ss:=Copy(ws,1+CName+1,CArtikul);
    Art:=ss;
  If StrToInt(Copy(ss,1,CRAzdelKod))=StrToInt(s) Then
  Begin
    Delete(ws,1+CNAme+1,CArtikul+1);
    ws:=ss+SeparatorChar+ws;

   While System.Pos('│',ws)>0 Do
    Begin
     i:=System.Pos('│',ws);
     ws[i]:=SeparatorChar;
    End;

SumBalance:=0;
AllOperation:=0;
For jk:=0 To 6 Do
 Begin
  art:=Copy(ws,1,CArtikul);
  Bal:=StrToReal(Copy(ws,1+CName+1+CArtikul+1+(CPack+1)*jk,CPack));
  AllOperation:=AllOperation+Abs(Bal);
  {Pack:=CalcPack(Art,IntToStr(Bal,CKol));}
  Case jk Of
  0:SumBalance:=Bal;{остатки}
  1:SumBalance:=SumBalance+Bal;{приход}
  2:SumBalance:=SumBalance-Bal;{отгрузки и РП}
  3:SumBalance:=SumBalance+Bal;{ревизия}
  4:SumBalance:=SumBalance+Bal;{возврат}
  5:SumBalance:=SumBalance+Bal;{переоценка}
  6:SumBalance:=SumBalance-Bal;{остатки на конец периода}
  Else;
  End;
 End;


If AllOperation<>0 Then
Begin
If (Abs(SumBalance)>0.00009) Or ((Abs(SumBalance)<0.00009)And(RegReport=0)) Then
Begin
          ws1:=Copy(ws,1,CArtikul);
          If Nprint^.DAt.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
          Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);
          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           ws1:=Copy(ws,1+CArtikul+1,CName);
           System.Delete(ws,1+CArtikul+1,CName);
           System.Insert(ws2,ws,1+CArtikul+1);
           Writeln(txt,Space+'     '+SeparatorChar+ws1);
          End;

 If Abs(SumBalance)>0.00009 Then
  Writeln(txt,Space+ws+SeparatorChar+'!'+SeparatorChar+'{'+RealToStr(SumBalance,CPack,CMantissa)+'}')
  Else
  Writeln(txt,Space+ws);
End;
End;
End;
  End;
   End;

 End;{for по разделам}
 End;

ws[0]:=#0;
For l:=1 To Ord(rs[0]) Do
Begin
ws[l]:='=';
ws[0]:=Chr(l);
End;

Writeln(Txt);
Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(Txt,Space+ws);
Writeln(Txt,GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);
Close(txt);


 Dispose(WspomList,Done);

 Dispose(TempList,Done);
 NoInfoMsg;
 ViewAsText(Path^.Dat.ToTemp+'bn1.txt','Отчет по результатам балансировки (цены)',True);
 {ReportNew(Path^.Dat.ToTemp+'bn1.txt','',1,False,False);}
End;


End.