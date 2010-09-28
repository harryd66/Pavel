Procedure TSuperMarketWindow.Refresh(Regim:Boolean);
Var R : TRect;
         i : Word;
         ws,S : String;
         PrevArt,Art : ArtikulStr;
         St : String[CZena];
         SDAte,Si : String[CInputIZena];
         l,Logik : Boolean;
         SName,SName2: String[60];
         SNSertif,SCod,sz : AllStr;
         SLitr : TDateString;
         sh,rs,Test1,Test2 : LongInt;
         {ts1,ts2 : String;}
         IndexFile : IndexFileType;
         Index : PIndexType;
      Propusk,SertifRazdel:Boolean;
         WspomList :PBox;
         c ,c1, Count,Count1 : Word;
         BazFilef,RazdelFile : File;
         BazElement1 : PBufSkladType;
         res : LongInt;
         RazdelElement : PBufRazdelType;
         {PrevStrihKod : String;}
         s1,s2 : TDAteString;
         {BakS : String;}
         Adding : Boolean;

         PrevStrihKod : AllStr;
         kr : Word;

Begin
{Test1:=CurrentTime;}
{DInfo('Формирую список товаров...');}

{BakS[0]:=#0;}

BazFull^.NewList(Nil);
BazFull^.NewList(New(PMyCollection{PTextCollection}, Init(0,1)));

SkladKol^.NewList(Nil);
SkladKol^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0, 0, 0, 0);
WspomList := New(PBox, Init(R, 1, Nil));
WspomList^.NewList(New(PTextCollection, Init(0,1)));

Assign (RazdelFile,Path^.Dat.ToRazdel+'razdel.db');
i:=IOResult;
Reset (RazdelFile,SizeOf(RazdelType));
If I=0 Then
Begin
While Not(Eof(RazdelFile)) Do
Begin
New(RazdelElement,Init);
Count1:=0;
BlockRead(RazdelFile,RazdelElement^.Point,BufferRazdel,Count1);
For c1:=1 To Count1 Do
Begin
{NoInfoMsg;}


DInfoMsgShkala('Выполняется загрузка остатков товара. Раздел '+
RazdelElement^.Point.Dat[c1].Kod+' ... ',1,EmployRazdel,StrToInt(RazdelElement^.Point.Dat[c1].Kod)+1);

If (RazdelElement^.Point.Dat[c1].Employ) {And (RazdelElement^.Point.Dat[c1].EnableDoc=0)} Then
Begin
SertifRazdel:=False;

If (RazdelElement^.Point.Dat[c1].EnableDoc=1) And (ShowSertif=0) Then Continue;


If RazdelElement^.Point.Dat[c1].EnableDoc=1 Then SertifRazdel:=True;


Logik:=True;



If EnableCashe=0 Then
Begin

If Logik Then
Begin
Assign (BazFilef,Path^.Dat.ToSklad+RazdelElement^.Point.Dat[c1].Kod+'.db');
i:=ioresult;
Reset (BazFilef,SizeOf(SkladType));
i:=ioresult;
If i=0 Then
Begin
While Not(Eof(BazFilef)) Do
 Begin
     Count:=0;
     New(BazElement1,Init);
     ReadBufSklad(BazFilef,BazElement1,Count);
For c:=1 To Count Do
Begin
  If BazElement1^.Point.Dat[c].Employ Then
  Begin
Begin
  l:=false;
  If Glob.Status=DocNormal Then
  If (StrToInt(BazElement1^.Point.Dat[c].Input.Kol)>0) then  l:=true;

  If Not l Then
  If Glob.Status=DocEdit Then
  if ((StrToInt(BazElement1^.Point.Dat[c].Input.Kol)+
     GetFullKolMarket(BazElement1^.Point.Dat[c].BazKod,PrevMarket))>0) Then l:=true;
 if l then
   Begin
    SName := GetIdField(FFFName,BazElement1^.Point.Dat[c].BazKod);
    SName2 := SNAme;
    SDate := IntToSTr(DateStringToDAte(DateMask,BazElement1^.Point.Dat[c].Input.Virabotano),CZena);
    RFormat(SDAte,CDAte);
    If SertifRazdel Then SName:='■'+SNAme;
    SName:=Copy(SName,1,CNAme);
    Format(SName,CName);
    Format(SName2,CName+1+CName);
    SNSertif:=BakGetField(FNSertif,BazElement1^.Point.Dat[c].BazKod,0);
    For i:=1 To CDivision Do
    Begin
Begin
Propusk:=False;

{!!!!
Rezerv[0]:=#0;

Логика действия для продажи

1.Вариант 1
   Если идет первая продажа(не коррекировка продажи) тогда
   при вывод количества в окне продажи
   используется алгоритм
   StrToInt(BazElement1^.Point.Dat[c].Input.Division[i])-
   StrToInt(BazElement1^.Point.Dat[c].Input.DivisionR[i])
1а.
   Если идет корретировка продажи тогда
   при вывод количества в окне продажи
   используется алгоритм
   StrToInt(BazElement1^.Point.Dat[c].Input.Division[i])-
   StrToInt(BazElement1^.Point.Dat[c].Input.DivisionR[i])+
   GetKolMarket(BazElement1^.Point.Dat[c].BazKod,i,PrevMarket)
2.Вариант 2

2. Если идет первое бронирование (не коррекировка брони) тогда
   при вывод количества в окне продажи
   используется алгоритм
   StrToInt(BazElement1^.Point.Dat[c].Input.Division[i])-
   StrToInt(BazElement1^.Point.Dat[c].Input.DivisionR[i])
2а.Если идет коррекировка брони тогда
   при вывод количества в окне продажи
   используется алгоритм
   StrToInt(BazElement1^.Point.Dat[c].Input.Division[i])-
   StrToInt(BazElement1^.Point.Dat[c].Input.DivisionR[i])+
   GetKolZakaz(BazElement1^.Point.Dat[c].BazKod,i,PrevZakaz)

3. Вариант идет оформление продажи через заказ.
   заказ при этом до момента закрытия документа отгрузки
   или смены номера заказа остается заблокирован
   StrToInt(BazElement1^.Point.Dat[c].Input.Division[i])-
   StrToInt(BazElement1^.Point.Dat[c].Input.DivisionR[i])+
   GetKolZakaz(BazElement1^.Point.Dat[c].BazKod,i,PrevZakaz)



If Glob.Status=DocNormal Then
Begin

End;
}

       Res:=0;
       Adding:=FAlse;

{$IfDEF Pharm}
       {эта херь для бакши сводит на нет фильтр по отделениям}
       If StrToInt(BazElement.Input.Division[i])>0 Then
           Begin
            Propusk:=True;
         Adding:=True;
        End;
{$ENDIF}

       If Glob.Status=DocEdit Then
        Begin
         {вычисляем количество в накладной}
         res:=GetKolMarket(BazElement1^.Point.Dat[c].BazKod,i,PrevMarket);
         Case InputZakaz Of
         {продажи}
         0:If OperatorSelector in [0,2] Then
            Str(StrToInt(BazElement1^.Point.Dat[c].Input.Division[i])-
            StrToInt(BazElement1^.Point.Dat[c].Input.DivisionR[i])+
         Res:CKol,BazElement1^.Point.Dat[c].Input.Division[i])
         Else
            Str(StrToInt(BazElement1^.Point.Dat[c].Input.Division[i])+
         Res:CKol,BazElement1^.Point.Dat[c].Input.Division[i]);
         {бронирование товара}
         1:Str(StrToInt(BazElement1^.Point.Dat[c].Input.Division[i])-
            StrToInt(BazElement1^.Point.Dat[c].Input.DivisionR[i])+
         Res:CKol,BazElement1^.Point.Dat[c].Input.Division[i]);
         Else;
         End;{Case}
         If Res>0 Then Propusk:=True;
        End
       Else
        Begin
         If OperatorSelector in [0,2] Then
            Str(StrToInt(BazElement1^.Point.Dat[c].Input.Division[i])-
            StrToInt(BazElement1^.Point.Dat[c].Input.DivisionR[i]):CKol,BazElement1^.Point.Dat[c].Input.Division[i]);
         {если идет оформление заказа}
         If InputZakaz=2 Then
            Str(StrToInt(BazElement1^.Point.Dat[c].Input.Division[i])+
            GetKolZakaz(Zakazmemory ,BazElement1^.Point.Dat[c].BazKod,i):CKol,BazElement1^.Point.Dat[c].Input.Division[i]);
        End;



 If (i=CurrentMakeOtdelenie) Or SertifRazdel Or Propusk Or (ENableFiltr=0) Then
 Begin
     If StrToInt(BazElement1^.Point.Dat[c].Input.Division[i])<0 Then
      Begin
       BazElement1^.Point.Dat[c].Input.Division[i]:='0';
      End;
          Str(i:1,SArtikul);
          MyStr(StrToReal(BazElement1^.Point.Dat[c].Input.R_Zena),CZena,CMantissa,BazElement1^.Point.Dat[c].Input.R_Zena);

          Prevs:=SName+'│'+SDate+'│'+BazElement1^.Point.Dat[c].BazKod+'│'+SArtikul+'│'+BazElement1^.Point.Dat[c].Input.R_Zena+
                '│'+SNAme2+'│'+SNSertif+'│'+IntToStr(BazElement1^.Point.Dat[c].Input.RegionMArka,COne);

          If (StrToInt(BazElement1^.Point.Dat[c].Input.Division[i])>0) Or
                 (Adding) Then
          Begin
          WspomList^.List^.Insert(NewStr(Prevs));
          WspomList^.SetRange(WspomList^.List^.Count);

          {временно выключна}
          {!!!!!!}

          If EnableShk=1 Then
          If Not(SertifRazdel) Then
          Begin
           PrevStrihKod:={BakGetField1(FStrihKod,}BazElement1^.Point.Dat[c].Input.StrihKod{BazKod,0)};
           RFormatZerro(PrevStrihKod,CStrihKod);
           PrevStrihKod:=PrevStrihKod+'│'+BazElement1^.Point.Dat[c].BazKod+'│'+SArtikul;
           If Not TestElementMy(PrevStrihKod,SkladKol,kr) Then
           Begin
            SkladKol^.List^.Insert(NewStr(PrevStrihKod));
            SkladKol^.SetRange(SkladKol^.List^.Count);
           End;
          End;

          End;
 End;{i=CurrentMakeOtdelenie}
End;
         End;{For}
        End;{If l=True}
End;{IdDebit}
  End;{Employ}
End;{For по Count}
  Dispose(BazElement1,Done);
 End;{While}

System.Close(BazFilef);
End
 Else
  Begin
   MessageBox(^M+#3' Ошибка открытия '+Path^.Dat.ToSklad+RazdelElement^.Point.Dat[c1].Kod+'.db'^M+
   #3'Код: '+IntToStr(i,3),Nil,mfError+mfCancelButton);
  End;
End;{Logik}
End{Not EnableCashe}
Else
Begin
{вариант обновления с кэшированием}

If Logik Then
Begin
Assign(IndexFile,Path^.Dat.ToIndex+RazdelElement^.Point.Dat[c1].Kod+'.idx');
New(Index,Init);
i:=ioresult;
Reset(IndexFile);
i:=ioresult;
If I=0 Then
Begin
 GetIndex(IndexFile,Index);
 System.Close(IndexFile);
End
 Else MessageBox(#3'Ошибка открытия файла '+Path^.Dat.ToIndex+RazdelElement^.Point.Dat[c1].Kod+'.idx!'+
 ClicProgrammer,Nil,mfInsertInApp+mfError+mfCancelButton);


Assign (BazFile,Path^.Dat.ToSklad+RazdelElement^.Point.Dat[c1].Kod+'.db');
i:=ioresult;
Reset (BazFile);
i:=ioresult;
If i=0 Then
Begin


 If Glob.Status=DocEdit Then
 Begin

 For i:=1 To PrevMarket^.Dat.AmountS Do
  Begin
   If Pos(RazdelElement^.Point.Dat[c1].Kod,PrevMarket^.Dat.DocumentElement[i].BazKod)=1 Then
    Begin
     sCod:=Copy(PrevMarket^.Dat.DocumentElement[i].BazKod,1+CRazdelKod,CKod);
     Index^.Dat.Present[StrToInt(sCod)]:=True;
    End;
  End;

 For i:=1 To PrevMarket^.Dat.Amount Do
  Begin
   If Pos(RazdelElement^.Point.Dat[c1].Kod,PrevMarket^.Dat.MarketElement[i].BazKod)=1 Then
    Begin
     sCod:=Copy(PrevMarket^.Dat.MarketElement[i].BazKod,1+CRazdelKod,CKod);
     Index^.Dat.Present[StrToInt(sCod)]:=True;
    End;
  End;
 End;


 For rs:=0 To 999 Do
  Begin
  If Index^.Dat.Present[rs] Then
  Begin
  Seek(BazFile,rs);
  ReadSklad(BazFile,BazElement);
          SName := GetIdField(FFFName,BazElement.BazKod);
          SName2 := SNAme;
       If SertifRazdel Then SName:='■'+SNAme;
          SName:=Copy(SName,1,CNAme);
          SDate := IntToSTr(DateStringToDAte(DateMask,BazElement.Input.Virabotano),CZena);
          RFormat(SDAte,CDAte);
          Format(SName,CName);
          Format(SName2,CName+1+CNAme);
          SNSertif:=BakGetField(FNSertif,BazElement.BazKod,0);


          For i:=1 To CDivision Do
                Begin

                 Propusk:=False;
                 {
                 If Glob.Status=DocEdit Then
                 Begin
                  Str(StrToInt(BazElement.Input.Division[i])+GetKolMarket(BazElement.BazKod,i,PrevMarket):CKol,
                  BazElement.Input.Division[i]);
                  If GetKolMarket(BazElement.BazKod,i,PrevMarket)>0 Then Propusk:=True;
                 End;
                 }

       Res:=0;
       Adding:=FAlse;

{$IfDEF Pharm}
       {эта херь для бакши сводит на нет фильтр по отделениям}
       If StrToInt(BazElement.Input.Division[i])>0 Then
           Begin
            Propusk:=True;
         Adding:=True;
        End;
{$ENDIF}

       If Glob.Status=DocEdit Then
        Begin
         {вычисляем количество в накладной}
         res:=GetKolMarket(BazElement.BazKod,i,PrevMarket);
         Case InputZakaz Of
         {продажи}
         0:If OperatorSelector in [0,2] Then
            Str(StrToInt(BazElement.Input.Division[i])-
            StrToInt(BazElement.Input.DivisionR[i])+
         Res:CKol,BazElement.Input.Division[i])
         Else
            Str(StrToInt(BazElement.Input.Division[i])+
         Res:CKol,BazElement.Input.Division[i]);
         {бронирование товара}
         1:Str(StrToInt(BazElement.Input.Division[i])-
            StrToInt(BazElement.Input.DivisionR[i])+
         Res:CKol,BazElement.Input.Division[i]);
         Else;
         End;{Case}
         If Res>0 Then Propusk:=True;
        End
       Else
        Begin
         If OperatorSelector in [0,2] Then
            Str(StrToInt(BazElement.Input.Division[i])-
            StrToInt(BazElement.Input.DivisionR[i]):CKol,BazElement.Input.Division[i]);
         {если идет оформление заказа}
         If InputZakaz=2 Then
            Str(StrToInt(BazElement.Input.Division[i])+
            GetKolZakaz(Zakazmemory ,BazElement.BazKod,i):CKol,BazElement.Input.Division[i]);
        End;


If (i=CurrentMakeOtdelenie) Or SertifRazdel Or Propusk Or (ENableFiltr=0) Then
 Begin

     If StrToInt(BazElement.Input.Division[i])<0 Then
      Begin
       BazElement.Input.Division[i]:='0';
      End;
                  {DelSpace(BazElement.Input.Division[i]);
                  Format (BazElement.Input.Division[i],CKol);
                  Str(StrToInt(BazElement.Input.Division[i]):CKol,BazElement.Input.Division[i]);}
                  Str(i:1,SArtikul);

                  MyStr(StrToReal(BazElement.Input.R_Zena),CZena,CMantissa,BazElement.Input.R_Zena);

                  Prevs:=SName+'│'+SDate+'│'+BazElement.BazKod+'│'+SArtikul+'│'+BazElement.Input.R_Zena+'│'
                           +SNAme2+'│'+SNSertif+'│'+IntToStr(BazElement.Input.RegionMArka,COne);

                  {
                  If PrevS=BakS Then
                   Begin
                    SpecialBeep;
                    MessageBox(#3'Обнаружено дублирование уникального индекса!'+
                    PrevS+^M+
                    BakS+ClicProgrammer,Nil,mfError+mfCancelButton);
                   End;

                  BakS:=PrevS;
                  }
                  If (StrToInt(BazElement.Input.Division[i])>0)
                           Or (Adding) Then
                Begin

                  WspomList^.List^.Insert(NewStr(Prevs{+IntToStr(WspomList^.List^.Count,CKol)}));
                  WspomList^.SetRange(WspomList^.List^.Count);


          {временно выключна}
          {!!!!!!}

          If EnableShk=1 Then
          If Not(SertifRazdel) Then
          Begin
          PrevStrihKod:={BakGetField1(FStrihKod,}BazElement.Input.StrihKod{BazKod,0);};
          RFormatZerro(PrevStrihKod,CStrihKod);
          PrevStrihKod:=PrevStrihKod+'│'+BazElement.BazKod+'│'+SArtikul;

           If Not TestElementMy(PrevStrihKod,SkladKol,kr) Then
           Begin
            SkladKol^.List^.Insert(NewStr(PrevStrihKod));
            SkladKol^.SetRange(SkladKol^.List^.Count);
           End;
          End;


                End;
 End;{i=CurrentMakeOtdelenie}




                End;{For}
 End;{Index^.Dat.Present}

End;{For}
System.Close(BazFile);
End{I=0}
 Else
  Begin
        MessageBox(^M+#3' Ошибка открытия '+Path^.Dat.ToSklad+RazdelElement^.Point.Dat[c1].Kod+'.db'^M+
        #3'Код: '+IntToStr(i,3),Nil,mfError+mfCancelButton);
  End;
{NoInfoMsg;}

Dispose(Index,Done);
End;{Logik}
End;{EnableCashe=1}




End;
End;{For по Count1}
  Dispose(RazdelElement,Done);
End;{While}
System.Close(RazdelFile);
End;


If WspomList^.List^.Count>0 Then
Begin
 For sh:=0 To WspomList^.List^.Count-1 Do
  Begin
        PrevS:=WspomList^.GetText(sh,WspomList^.List^.Count);
        System.Delete(PrevS,1+CNAme+1,CDate+1);
        BazFull^.List^.Insert(NewStr(Prevs));
        BazFull^.SetRange(BazFull^.List^.Count);
  End;
End;

NoInfoMsg;


Dispose(WspomList,Done);
FastRefresh(Regim);
End;

