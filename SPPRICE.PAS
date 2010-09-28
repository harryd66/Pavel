{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


Unit SpPrice;

INTERFACE


{$I Compile.INC}

Uses Glob,Dialogs,ServStr,Utils;

{вызов - Selection(15)  из Price.pas}
(*в Selection:
  Case k Of
   .............
  15:New(RazdelWinS, Init(R, 'Печать спец-прайса'));

  и собственно вызов

  if k=15 Then
   Begin
     PrintSpecPrise(True,K,RazdelSelect,M,Assort,Sort,Sertif,Akzis);
   End;
    *)

{Параметры как и в обычном прайсе}
Function PrintSpecPrise (Video:Boolean;K:Byte;Const Spis:PBox;Const M:Maska8;Const Assort,Sort,Sertif,Akzis:Word):
TEnjoyStr;

IMPLEMENTATION
Uses App,DBEngine,DBEngin2,DBEngin3,MsgBox,Tools,Printers,Objects,Views,Propiss,TpDate,Access,
     Validate,NetDBEng,Vision4,Serv,Utils4,NAstr,Protect,Access1,
     ServStr2, Vision5,Vision6,Utils1,Utils5,Prise,ExpImp,Vision1;


Var OldFileMode: Word;
    AllEnable: LongInt;


Procedure CalcNewKolNew(Var E:SkladTypeNew;i,Bron:Word);
Begin
      Case Bron Of
{забронированный}
      1:E.Division[i]:=E.DivisionR[i];
{не забронированный}
      2:E.Division[i]:=E.Division[i]-E.DivisionR[i];
      Else;
      End;
End;


Function TestRazdelSpec(s:TDateString;Const M:Maska8;Const Assort:Byte;Const TipID,TipID1:Word;
Const Bron:Word; Const Price : Boolean):Boolean;
Var E : PBufSkladTypeNew;
    Ef: File;
    I : Byte;
    B : Boolean;
    dop : artikulstr;
    rs : Word;
    c , Count : Word;
    AllSkl : Maska30;
    NameSkl : LongInt;
    AllSklCur : Maska30;
Begin
If Price Then
 Begin
  WordToBit30(AllEnable,AllSkl);
  Convert30(AllSkl);
 End;

Begin
 TestRazdelSpec:=False;
 I:=IoResult;
 Assign(ef,Path^.Dat.ToIndex+s+'.kdx');
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(Ef,SizeOf(SkladTypeNew));
 I:=IOResult;
 FileMode:=OldFileMode;
 If I=0 Then
  Begin
   B:=FAlse;
   While Not(Eof(ef)) And Not(B)Do
   Begin
   New(E,Init);
   Count:=0;
   ReadBufNewSklad(ef,E,Count);
   {
   If s='41' Then
    Begin
     Readln;
    End;
   }
For c:=1 To Count Do
Begin
   For i:=1 To CDivision Do
    Begin
    If M[i]=1 Then
Begin
      Case Bron Of
{забронированный}
      1:E^.Point.Dat[c].Division[i]:=E^.Point.Dat[c].DivisionR[i];
	 {Str(StrToInt(E^.Point.Dat[c].Input.DivisionR[i]):CKol,E^.Point.Dat[c].Input.Division[i]);}
{не забронированный}
      2:E^.Point.Dat[c].Division[i]:=E^.Point.Dat[c].Division[i]-
      E^.Point.Dat[c].DivisionR[i];
      Else;
      End;

    If ((E^.Point.Dat[c].Division[i]>0) And (E^.Point.Dat[c].Employ) And (Assort=0))
    Or((E^.Point.Dat[c].Employ) And (Assort>0)) Then
     Begin
     If (GetIdMArket(AsArtikul(E^.Point.Dat[c].BazKod))=TipID) Or (TipID=2) Then
          Begin
     If (E^.Point.Dat[c].RegionMArka=TipID1) Or (TipID1=2) Then
          Begin
           If Price Then
            Begin
             NAmeSkl:=E^.Point.Dat[c].EnableSklads;
             WordToBit30(NAmeSkl,AllSklCur);
             Convert30(AllSklCur);


             {If TestMassiv(AllSkl,AllSklCur) Then}
              Begin
               B:=True;
               Break
              End;
            End
            Else
             Begin
              B:=True;
              Break
             End;
          End;{GetIdMarket}
          End;
     End;{Division[i]>0}
End;{пересчет брони}
    End;{For}
    If b Then Break;
End;{For}
   Dispose(E,Done);
   End;{While}
   TestRazdelSpec:=B;
   Close(ef);
  End
  Else Exit;
End

End;




Function PrintSpecPrise (Video:Boolean;K:Byte;Const Spis:PBox;Const M:Maska8;Const Assort,Sort,Sertif,Akzis:Word):
TEnjoyStr;
VAR Temp,TempList : PBox;
    R : TRect;
    E : PBufSkladTypeNew;
    Ef: File;
    GO: BOOLEAN;
    l: word;
    txt: text;
    s: string;
    TipID,TipID1 : LongInt;
    Count,Bron,TTT : Word;
    FiltrDivision,j : Word;
    AllSkl,AllSklCur : Maska30;
    Otdel,Pack,P : AllStr;
    stRz,stOz : String[CPost+5];
    STest,FirmaPost{,GTD,PPP,PPost} : AllStr;

Procedure FormPriceSpec;
Var lk,c,Count,sh : Word;
    i : Byte;
    AllSklL: Maska30;
    jj : Word;
    SSrok : TDAteString;
    SKol,SpecZena,SRZena,SOZena,SZakupka:AllStr;
    ws,ws1,ws2,SExpert,SOrgan : String;
    ssa,SSertif,SNGTD,SSeria : TMyString;
    BBB : PBazType;
    NameSkl : LongInt;
    SA: ArtikulStr;
    SMin0,SMin1,SMin2: string[CZena];
Begin

      R.Assign(0, 0, 0, 0);
      Temp := New(PBox, Init(R, 1, Nil));
      Temp^.NewList(New(PTextCollection, Init(0,1)));

      WordToBit30(AllEnable,AllSkl);
      Convert30(AllSkl);

      While Not(Eof(ef)) Do
      Begin
         New(E,Init);
         Count:=0;
         ReadBufNewSklad(ef,E,Count);
For c:=1 To Count Do
Begin

      New(BBB,Init);
      BBB^.Dat.BazKod:=AsArtikul(E^.Point.Dat[c].BazKod);
      GetBazElementS(AsArtikul(E^.Point.Dat[c].BazKod),BBB^.Dat);

        E^.Point.Dat[c].Kol:=0;

        NAmeSkl:=E^.Point.Dat[c].EnableSklads;
        WordToBit30(NAmeSkl,AllSklCur);
        Convert30(AllSklCur);
        (*If TestMassiv(AllSklCur,AllSkl{[StrToInt(Rek^.DAt.Kod}) Then*)
      If ((BBB^.Dat.Market=TipID)Or(TipID=2)) Then
      If ((E^.Point.Dat[c].RegionMarka=TipID1)Or(TipID1=2)) Then
      Begin
        For i:=1 To CDivision Do
        Begin
         If (M[i]=1) Then
         Begin

          CalcNewKolNew(E^.Point.Dat[c],i,Bron);

          E^.Point.Dat[c].Kol:=E^.Point.Dat[c].Kol+E^.Point.Dat[c].Division[i];
         End;
        End;


       MyStr(E^.Point.Dat[c].R_Zena,CZena,CMAntissa,SRZena);
       SOZena:=SRZena;
       MyStr(E^.Point.Dat[c].Zakupka,CZenaZ,CMAntissaZ,SZakupka);


       If (((E^.Point.Dat[c].Employ) And (E^.Point.Dat[c].Kol>0)And(Assort=0))Or
       ((E^.Point.Dat[c].Employ)And(Assort>0)And(((E^.Point.Dat[c].Kol>0))Or(i<=1))))
       {это условие сделано по просьбе Бакши 21-06-01}
       Or ((E^.Point.Dat[c].employ)And(Assort>0)) Then
       Begin

        Ws:=E^.Point.Dat[c].Name+E^.Point.Dat[c].Name2;

        Format(ws,CName+1+CName);
        Begin

         DelSpace(SRZena);
         DelSpace(SOZena);
         DelSpace(SpecZena);
         DelSpace(SZakupka);
        End;


        RFormat(SOZena,CZena);
        RFormat(SRZena,CZena);
        RFormat(SpecZena,CZena);
        RFormat(SZakupka,CZenaZ);

        Pack:=BBB^.Dat.InPack;
        DelSpace(Pack);
        SKol:=IntToStr(E^.Point.Dat[c].Kol,CKol);
        P:=CalcPackNoFile(Pack,SKol);
        DelSpace(P);

        s:=P;

        If Pos('+',s)>0 Then s[0]:=Chr(Pos('+',s)-1);

        RFormat(Pack,CInPack);

        FirmaPost[0]:=#0;
        SSeria[0]:=#0;
        SNGTD[0]:=#0;
        SSertif[0]:=#0;
        SSrok[0]:=#0;


        StRz:=GetMakeField(FClient,Copy(AsArtikul(E^.Point.Dat[c].NMakeKod),2,CClientKod),
	                        StrToInt(Copy(AsArtikul(E^.Point.Dat[c].NMakeKod),1,1)));
        Format(stRz,CPost+5);

        Str(E^.Point.Dat[c].Kol:CKol,s);
        {ценовые ограничения}
        SA:=CalcMainKod(BBB^.Dat.BazKod);
        SMin0:=GetMinRange(0,SA,ListRange);
        DelSpace(SMin0);
        If Length(SMin0)>0 Then
        else Smin0:=SRZena;
        SMin1:=GetMinRange(1,SA,ListRange);
        DelSpace(SMin1);
        If Length(SMin1)<=0 Then Smin1:=SRZena;
        SMin2:=GetMinRange(2,SA,ListRange);
        DelSpace(SMin2);
        If Length(SMin2)<=0 Then Smin2:=SRZena;

        {Vip1 - пока 17%}
        MyStr(StrToReal(SZakupka)*(1+17/100),CZena,CMantissa,SpecZena);
        {Vip1 - пока 23%}
        MyStr(StrToReal(SZakupka)*(1+23/100),CZena,CMantissa,SOZena);

        Ws:=BBB^.Dat.BazKod+';'+s+';'+ws+';'+Strz+';'+
          {+';'+FirmaPost+';'+}Pack+';'+SRZena+';'+ SMin0+';'+ SMin1+';'+ SMin2
         +';'+ SpecZena+';'+SOZena;

        Writeln(txt,DosToWin(Ws));

        Temp^.List^.Insert(NewStr(ws));
        Temp^.SetRange(Temp^.List^.Count);
       End;
      End;

Dispose(BBB,Done);
End;{For}
       Dispose(E,Done);
      End;{While}
      Close(Ef);


      Dispose(Temp,Done);
      Writeln(txt);
End;


BEGIN

 PrintSpecPrise:='           0.00';

 Assign(Txt,Path^.Dat.ToTemp+'spreport.csv');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If (L <> 0) Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'spreport.csv'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   {Dispose(Spis,Done);}
   Exit;
  End;

  R.Assign(0,0,0,0);
  TemplIST := New(PBox, Init(R, 1, Nil));
  TempList^.NewList(New(PTextCollection, Init(0,1)));
  For L:=0 To Spis^.List^.Count-1 Do
 Begin
  s:=Spis^.GetText(l,Spis^.List^.Count);
  TempList^.List^.Insert(NewStr(s));
  TempList^.SetRange(TempList^.List^.Count);
 End;


 TipID1:=2;
 TipID:=2;


  TipID1:=SelectSpecify(False,12);  {маркированные - немаркированные}
  If TipID1=3 Then
   Begin
    Close(Txt);
    Dispose(TempList,Done);
    Exit;
   End;

  TipID:=SelectIDTip;   {Разрешенные к продаже}
  If TipID=3 Then
   Begin
    Close(Txt);
    Dispose(TempList,Done);
    Exit;
   End;

    Bron:=0;              {Бронь}
    TTT := Bron;
 If Not SelectVidProsmotra(TTT) Then
      Begin
        Close(Txt);
        Dispose(TempList,Done);
        Exit;
      End
  Else Bron:=TTT;

(*                        {Разбивать по отделениям }
    FiltrDivision:=SelectImport(34);
      If FiltrDivision=2 Then
      Begin
        Close(Txt);
        Dispose(TempList,Done);
        Exit;
      End;          *)

  Writeln(Txt,DosToWin('Склад:'+GetClientField(FClient,Rek^.Dat.Kod,1)+' Оператор: '+GetOperatorField(FName,CurrentPassword)));
  Write(Txt,DosToWin('Вид отбора: '));
  Case TipId Of
  0:Write(txt,DosToWin('Запрещенные к продаже '));
  1:Write(txt,DosToWin('Разрешенные к продаже '));
  2:Write(txt,DosToWin('Все '));
  Else;
  End;

  Write(Txt,DosToWin('Вид отбора: '));
  Case TipId1 Of
  0:Write(txt,DosToWin('Немаркированные'));
  1:Write(txt,DosToWin('Маркированные'));
  2:Write(txt,DosToWin('Все {региональная марка}'));
  Else;
  End;


  Case Bron Of
  0:Writeln(txt,DosToWin('Без учета брони'));
  1:Writeln(txt,DosToWin('Только забронированный'));
  2:Writeln(txt,DosToWin('Только незабронированный'));
  Else Writeln(txt);
  End;

{  Case FiltrDivision of
  0:Writeln(txt,'СОВМЕЩЕННЫЕ ОТДЕЛЕНИЯ');
  1:Writeln(txt,'');
  End;    }

  Writeln(Txt,DosToWin('Выбранные отделения:'));
  For l:=1 To CDivision Do
  If M[l]=1 Then Write(txt,l:2,':',DosToWin(Rek^.Dat.Otdel[l]),' ');
  Writeln(Txt);

  Writeln(Txt,DosToWin('  П Р А Й С - Л И С Т   (рубли)    '+FDate+'  '+Times));
  Writeln(Txt);
  Writeln(Txt,DosToWin('Код;Кол-во;Наименование;Поставщик;Фас.;Цена;Цена1;Цена2;Цена3;Vip1;Vip2;'));
  Writeln(Txt);

 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);

  DInfoMsgShkala('Анализирую остатки товара. Раздел '+s+' ...',0,TempList^.List^.Count-1,L);


  go:=TestRazdelSpec(s,M,Assort,TipID,TipID1,Bron,True);


  if go then
  Begin
    Writeln(Txt,DosToWin('Раздел: '+GetRazdel(s)));
    Assign(Ef,Path^.Dat.ToIndex+s+'.kdx');
    OldFileMode:=FileMode;
    FileMode:=ReadOnlyN;
    Reset(Ef,SizeOf(SkladTypeNew));
    FileMode:=OldFileMode;

    FormPriceSpec;

  End;
end;

  Dispose(TempList,Done);

  NoInfoMsg;
  close(txt);

  MessageBox(#3^M+#3'Результаты сохранены в файле '
          +Path^.Dat.ToTemp+'spreport.csv',Nil,mfError+mfCancelButton);


END;



BEGIN
END.