{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Balance;

Interface

Uses Glob,Dialogs,ServStr,Serv,Utils;


Procedure CalcBalance(Const Spis:PBox;Const M:Maska;Const Assort,Sort:Word);

Implementation


Uses App,DBEngine,MsgBox,Tools,Printers,Objects,Views,TpDate,Vision3,Vision4,
     NetDBEng;




Procedure CalcBalance(Const Spis:PBox;Const M:Maska;Const Assort,Sort:Word);
Const
BName=1;
BArtikul=1+CName+1;
BPrihod=1+CName+1+CArtikul+1+CPack+1;
BMarket=1+CName+1+CArtikul+1+CPack+1+CPack+1;
BRewizia=1+CName+1+CArtikul+1+CPAck+1+CPAck+1+CPack+1;
BReturn=1+CName+1+CArtikul+1+CPAck+1+CPAck+1+CPAck+1+CPack+1;
Shb='        0         0         0         0         0         0';
    {123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456123456}
Var R,R1 : TRect;
    Txt : Text;
    rs,Shablon,s1,RazdelName,Fas,TempArtikul,s,ss : TMyString;
    ws,ws1,ws2 : string[150];
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
    SArtikul : ArtikulStr;
    Itg : PNewItogType;
    ItogFile  : File Of NewItogType;
    Cl : Word;

Procedure BCalcRewisia(L:LongInt;Var TL,WL:PBox);
Var F : RewisiaFileType;
    Es : PRewisiaType;
    i,j : Word;
Begin
 Assign(F,Path.ToRewisia+DAteToDAteString(DateMask,L)+'.rwz');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
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
             Str(StrToInt(s)+StrToInt(Es^.Dat.Element[j].Input.Division[i]):CPAck,s);{для случая недель}
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
             s:='        0';
                {123456789}
             For i:=1 To CDivision Do
             Str(StrToInt(s)+StrToInt(Es^.Dat.Element[j].Input.Division[i]):CPAck,s);{для случая недель}
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
 Assign(F,Path.ToMarket+DAteToDAteString(DateMask,L)+'.mrk');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
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
             Str(StrToInt(s)+StrToInt(Es^.Dat.MarketElement[j].Input.Kol):CPAck,s);{для случая недель}
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
             s:='        0';
                {123456789}
             Str(StrToInt(s)+StrToInt(Es^.Dat.MarketElement[j].Input.Kol):CPAck,s);{для случая недель}
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
 Assign(F,Path.ToReturn+DAteToDAteString(DateMask,L)+'.vzw');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
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
             Str(StrToInt(s)+StrToInt(Es^.Dat.VozwratElement[j].Input.Kol):CPAck,s);{для случая недель}
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
             s:='        0';
                {123456789}
             Str(StrToInt(s)+StrToInt(Es^.Dat.VozwratElement[j].Input.Kol):CPAck,s);{для случая недель}
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



Procedure BCalcPrihod(L:LongInt;Var TL,WL:PBox);
Var F : PrihodFileType;
    Es : PPrihodType;
    i,j : Word;
Begin
 Assign(F,Path.ToPrihod+DAteToDAteString(DateMask,L)+'.prh');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
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
             Str(StrToInt(s)+StrToInt(Es^.Dat.PrihodElement[j].Input.Division[i]):CPAck,s);{для случая недель}
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
             Str(StrToInt(s)+StrToInt(Es^.Dat.PrihodElement[j].Input.Division[i]):CPAck,s);{для случая недель}
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


 Var AllOperation,SumBalance,Bal,jk: LongInt;
     Pack : AllStr;
     Shapka: Array [1..3] Of string[150];

Begin
If Not(DAtePeriodDialog(Start,Stop,False)) Then
   Begin
    Exit;
   End;

EE:=DateStringToDate(DateMask,Stop);
EE1:=DateStringToDate(DateMask,Start);

 Separator:=' ';
 Assign(Txt,Path.ToTemp+'bn.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'bn.txt',Nil,mfError+mfCancelButton);
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

 EdIzm:=SelectImport(2);
      If EdIzm=2 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;



  DInfo('Провожу балансировку товара...');
  Append(txt);
  Space:='   ';
  Writeln(Txt,Space+'Склад:'+FormKod(Rek.Kod)+' Оператор: '+CurrentPassword);
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
  Write(Txt,Space+'Единицы измерения: ');
  Case EdIzm Of
  0:Writeln(txt,'{Штуки}');
  1:Writeln(txt,'{Упаковки}');
  Else Writeln(txt);
  End;
  Writeln(txt);

 s:=' Код  Наименование товара        Ост.'+DAteToDAteString('dd.mm',EE1)+'    Приход Отг.и Р/П   Ревизия   Возврат Ост.'+
  {123456789 123456789 123456789 123456789 123456789}
 DAteToDAteString('dd.mm',EE);
                                        {12345 12345678901234567890123456 123456789 123456789 123456789 123456789 123456789}
Space[0]:=#0;
Shablon[0]:=#0;
Writeln(Txt,Space+' БАЛАНСИРОВКА ТОВАРНОГО НАЛИЧИЯ за период с '+DAteToDateString(DAteMask,EE1)+' по '+Stop);
Str(StrToInt(Rek.Kod):2,Ext);
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
Shapka[3]:=ws;


  R1.Assign(0,0,0,0);
  WspomlIST := New(PBox, Init(R1, 1, Nil));
  WspomList^.NewList(New(PTextCollection, Init(0,1)));
  New(Itg,Init);

    Str(StrToInt(Rek.Kod):2,Ext);
    RFormatZerro(Ext,2);
    s:=DAteToDAteString(DateMask,EE1);
    Assign(ItogFile,Path.ToArchiv+s+'.p'+Ext);
    i:=IOResult;
    Reset(ItogFile);
    i:=IOResult;
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

             Str(StrToInt(s)+StrToInt(Itg^.Dat.Ost):CPAck,s);{для случая недель}
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
             Str(StrToInt(Itg^.Dat.Ost):CPAck,s);
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
      MessageBox(^M+#3+'Не найдена база остатков за '+s+'!'^M+
	 #3'Не могу провести балансировку!',Nil,mfError+mfCancelButton);
      Exit;
     End;

    Str(StrToInt(Rek.Kod):2,Ext);
    RFormatZerro(Ext,2);
    s:=DAteToDAteString(DateMask,EE);
    Assign(ItogFile,Path.ToArchiv+s+'.p'+Ext);
    i:=IOResult;
    Reset(ItogFile);
    i:=IOResult;
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

             Str(StrToInt(s)+StrToInt(Itg^.Dat.Ost):CPAck,s);{для случая недель}
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
             Str(StrToInt(Itg^.Dat.Ost):CPAck,s);
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
      Dispose(Itg,Done);
      Dispose(WspomList,Done);
      Dispose(TempList,Done);
      NoInfo;
      Close(txt);
      MessageBox(^M+#3+'Не найдена база остатков за '+s+'!'^M+
	 #3'Не могу провести балансировку!',Nil,mfError+mfCancelButton);
      Exit;
     End;

  Dispose(Itg,Done);


  For L:=EE1+1 To EE Do
   Begin
   BCalcPrihod(L,TempList,WspomList);
   BCalcOtgruzka_RP(L,TempList,WspomList);
   BCalcRewisia(L,TempList,WspomList);
   BCalcReturn(L,TempList,WspomList);
   End;

If WspomList^.List^.Count>=1 Then
 Begin
 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);

If TestElementSpis (S,WspomList,Sort) Then
Begin
  Writeln(Txt);
  Writeln(Txt,Space+'                    Раздел: '+GetRazdel(s));
  Writeln(Txt,Space+Shapka[1]);
  Writeln(Txt,Space+Shapka[2]);
  Writeln(Txt,Space+Shapka[3]);
  For j:=0 To WspomList^.List^.Count-1 Do
   Begin
    ws:=WspomList^.GetText(j,WspomList^.List^.Count);
    If Sort=0 Then Delete(ws,1,CArtikul+1);
    ss:=Copy(ws,1+CName+1,CArtikul);
    Art:=ss;
  If StrToInt(Copy(ss,1,CRAzdelKod))=StrToInt(s) Then
  Begin
    Delete(ws,1+CNAme+1,CArtikul+1);
    ws:=ss+' '+ws;

   While System.Pos('│',ws)>0 Do
    Begin
     i:=System.Pos('│',ws);
     ws[i]:=' ';
    End;

SumBalance:=0;
AllOperation:=0;
For jk:=0 To 5 Do
 Begin
  art:=Copy(ws,1,CArtikul);
  Bal:=StrToInt(Copy(ws,1+CName+1+CArtikul+1+(CPack+1)*jk,CPack));
  AllOperation:=AllOperation+Abs(Bal);
  Pack:=CalcPack(Art,IntToStr(Bal,CKol));
  Case jk Of
  0:SumBalance:=Bal;{остатки}
  1:SumBalance:=SumBalance+Bal;{приход}
  2:SumBalance:=SumBalance-Bal;{отгрузки и РП}
  3:SumBalance:=SumBalance+Bal;{ревизия}
  4:SumBalance:=SumBalance+Bal;{возврат}
  5:SumBalance:=SumBalance-Bal;{остатки на конец периода}
  Else;
  End;
  If EdIzm=1 Then
   Begin
    Delete(ws,1+CName+1+CArtikul+1+(CPack+1)*jk,CPack);
    Insert(Pack,ws,1+CName+1+CArtikul+1+(CPack+1)*jk);
   End;
 End;
If AllOperation<>0 Then
Begin
 SArtikul:=Copy(ws,1,CArtikul);

 If SumBalance<>0 Then
  Writeln(txt,Space+ws+' !')
  Else
  Writeln(txt,Space+ws);

          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,SArtikul)
          Else Ws2:=GetIdField(FFName2,SArtikul);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt,Space+'      '+ws2);
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
Close(txt);


 Dispose(WspomList,Done);

 Dispose(TempList,Done);
 NoInfo;
 ViewAsText(Path.ToTemp+'bn.txt',True);
 Report(Path.ToTemp+'bn.txt','',1,False,False);
End;


End.