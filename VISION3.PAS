{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

Unit Vision3;

Interface

Uses Glob,Dialogs,ServStr,Serv,Utils;

(*Procedure CalcTCh; полностью испрвана*)
Procedure Ostatki_Market(Const Spis:PBox;Const M:MaskaNew;Const Assort,Sort:Word);
Procedure Test_Sertif(Const Spis:PBox;Const M:MaskaNew;Const Assort,Sort:Word);

Function ViewAllRewisia(SDate:TDateString;Auto:Boolean;Default:Byte):AllStr;
Procedure PrintRewisia(As:DocumentEdit);

Procedure ViewKAssa(Auto:Boolean;Shablon:TDAteString);
Procedure ViewSpecialKAssa(Auto:Boolean;Shablon:TDAteString);
Procedure PrintSKL(Const Spis:PBox;Const M:MaskaNew; Const Assort,Sort:Word);

Procedure CalcAllNakl (Date: TDateString;
Var VidaNoC:AllStr;Var VidanoCKol:ArtikulStr;Var VidanoCSkidki:AllStr;
Var SkidkiOfC:AllStr;Var SkidkiOfCKol:ArtikulStr;
Var ProdagiC :AllStr;Var ProdagiCKol :ArtikulStr;Var ProdagiCSkidki :AllStr;
Var ProdagiS :AllStr;Var ProdagiSKol :ArtikulStr;
Var RP :AllStr;Var RPKol :ArtikulStr;
Var Sf :AllStr;Var SfKol :ArtikulStr;

Var VidanoCSf:AllStr;Var VidanoCSfKol:ArtikulStr;
Var VidanoCSfSkid:AllStr;Var VidanoCSfSkidKol:ArtikulStr;
Var SkidkiOfCSf:AllStr;Var SkidkiOfCKolSf:ArtikulStr;
Var SpecNAlogP:AllStr;Var SpecNAlogC:AllStr;
Var BarterT:AllStr;Var BarterKol:Artikulstr; Var BarterSkidki:AllStr);

Function TestElementSpis (Const S : ArtikulStr;Const P : PBox;Const Sort:Word) : Boolean;
Procedure CalcBuch;
Procedure AddToReportRewisia(As:DocumentEdit;Space:AllStr;Var Txt:Text);

Implementation


Uses App,DBEngine,MsgBox,Tools,Printers,Objects,
     Views,TpDate,Vision4,Vision1,
     Access,Validate,NetDBEng,Net;

VAr LocalTempBox,TempBox : PBox;

    StartDate,StopDate : TDateString;



Function TestLastDivision(M:TRewString;Position:Word;MMM:MaskaNew;Vid:Byte):Boolean;
Var c: Word;
Begin
TestLastDiviSion:=True;
Inc(Position);

If Position>CDivision Then Exit;

  For c:=Position To CDiviSion Do
   Begin
    Delspace(M[c]);
    If (StrToInt(M[c])<>0) And (MMM[c]=1) Then
     Begin
If ( ((StrToInt(M[c])>0)And(Vid=0))
   Or((StrToInt(M[c])<0)And(Vid=1))
   Or((StrToInt(M[c])<>0)And(Vid=2))) Then

   Begin
      TestLastDiviSion:=False;
      Break;
   End;
     End;
   End;

End;


Function PeriodProd:Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control,ControlStart,ControlStop : PView;
  C : Word;
  l : LongInt;
  s1,s2 : TDateString;

begin
PeriodProd :=False;
s1:=FDate;
s2:=FDate;

1:
R.Assign(23, 9, 57, 14);
New(Dlg, Init(R, 'Период расчета продаж'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E011;
Dlg^.Palette := dpCyanDialog;

R.Assign(6, 2, 16, 3);
ControlStart := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStart);
  PInputLine(ControlStart)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

ControlStart^.SetData(s1);

  R.Assign(3, 2, 6, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~с~:', ControlStart)));

R.Assign(20, 2, 30, 3);
ControlStop := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStop);
  PInputLine(ControlStop)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

ControlStop^.SetData(s2);

  R.Assign(16, 2, 20, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~п~о:', ControlStop)));

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
   ControlStart^.GetData(s1);
   ControlStop^.GetData(s2);
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);

   If Not(TestDate(s1,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Not(TestDate(s2,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   StartDate:=s1;
   StopDate:=s2;
   PeriodProd:=True;

   {если даты перепутаны переставляем их}
   If DateStringToDate(DateMask,StopDate)<DateStringToDate(DateMask,StartDate) Then
    Begin
        s1:=StopDate;
        StopDate:=StartDate;
        StartDate:=s1;
    End;
 End
 Else
  Begin
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);
  End;
end;




Procedure AddMarketToMaxList(Const E:PSuperMarketType);
Var j,i : Word;
    l,k,pp:Byte;
    Artikul : ArtikulStr;
    Find : Boolean;
    ws ,s: TMyString;
    Lg : PSuperMarketType;
    Logik : Boolean;


Begin
   New(Lg,Init);
   k:=1;pp:=1;

   For l:=1 To E^.Dat.Amount Do
    Begin
     If testMarketSF(E^.Dat.MarketElement[l].BazKod,Lg,pp) Then
      Begin
       Str((StrToInt(Lg^.Dat.MarketElement[pp].Input.Kol)+
            StrToInt( E^.Dat.MarketElement[l].Input.Kol)):CKol,Lg^.Dat.MarketElement[pp].Input.Kol);
      End
      Else
      Begin
       Lg^.Dat.MarketElement[k]:=E^.Dat.MarketElement[l];
       Inc(k);
       Lg^.DAt.Amount:=k-1;
      End;
    End;
    Lg^.DAt.Amount:=k-1;
    Lg^.Dat.Document:=E^.Dat.Document;
    Lg^.Dat.ClientKod:=E^.Dat.ClientKod;
    Lg^.Dat.SkidkaSelector:=E^.Dat.SkidkaSelector;

For i:=1 To Lg^.Dat.Amount Do
 Begin
  Artikul:=Lg^.Dat.MarketElement[i].BazKod;

{ If Artikul='03035' Then
   Begin
    Readln;
   End;}
  If TempBox^.List^.Count-1>=0 Then
  Begin
   Logik:=True;
   For j:=0 To TempBox^.List^.Count-1 Do
    Begin
     Find:=False;
     ws:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CName,CArtikul);

     If ws=Lg^.Dat.MarketElement[i].BazKod Then
      Begin
       Logik:=False;
       ws:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CName,CKol);
       If StrToInt(ws)<StrToInt(Lg^.Dat.MarketElement[i].Input.Kol) Then
        Begin

     If Lg^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
      begin
       DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
       Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
       (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
      End
      Else
       Begin
       Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
       :CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
       End;

         Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
         Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
         RFormatZerro(Lg^.Dat.Document,CDocNumer);
         Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,ws);
         s:=GetIdField(FName,Artikul);
         Format(s,CName);

         s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+
         Lg^.Dat.MarketElement[i].Input.Zena+'│'+ws+'│'+Lg^.Dat.Document+'│'+Lg^.Dat.ClientKod;

         TempBox^.List^.AtFree(j);
         TempBox^.SetRange(TempBox^.List^.Count);

         TempBox^.List^.Insert(NewStr(s));
         TempBox^.SetRange(TempBox^.List^.Count);
         Find:=True;
         Break;
        End;
      End
      Else{Если совпали}
      Begin
      End;
    End;{For по списку продаж}
    If Logik Then{Если не найдено ни одного вхождения}
     Begin

     If Lg^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
      begin
       DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
       Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
       (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
      End
      Else
       Begin
       Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
       :CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
       End;

        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        RFormatZerro(Lg^.Dat.Document,CDocNumer);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,ws);
         s:=GetIdField(FName,Artikul);
         Format(s,CName);

         s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+
        Lg^.Dat.MarketElement[i].Input.Zena+'│'+ws+'│'+Lg^.Dat.Document+'│'+Lg^.Dat.ClientKod;

        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
        {Break;}
     End;
  End{если список не пустой}
    Else
      Begin

     If Lg^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
      begin
       DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
       Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
       (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
      End
      Else
       Begin
       Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
       :CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
       End;

        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        RFormatZerro(Lg^.Dat.Document,CDocNumer);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,ws);
         s:=GetIdField(FName,Artikul);
         Format(s,CName);

         s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+
        Lg^.Dat.MarketElement[i].Input.Zena+'│'+ws+'│'+Lg^.Dat.Document+'│'+Lg^.Dat.ClientKod;

        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
      End;
 End;{For i:=1 To E^.Dat.Amount Do}

 Dispose(lg,Done);
End;


Procedure AddMarketToMarketList(Const E:PSuperMarketType);
Var j,i : Word;
    l,k,pp:Byte;
    Artikul : ArtikulStr;
    Find : Boolean;
    ws1,ws ,s: TMyString;
    Lg : PSuperMarketType;
    Logik : Boolean;

Begin
   New(Lg,Init);

   k:=1;pp:=1;
   For l:=1 To E^.Dat.Amount Do
    Begin
     If testMarketSF(E^.Dat.MarketElement[l].BazKod,Lg,pp) Then
      Begin
       Str((StrToInt(Lg^.Dat.MarketElement[pp].Input.Kol)+
            StrToInt( E^.Dat.MarketElement[l].Input.Kol)):CKol,Lg^.Dat.MarketElement[pp].Input.Kol);
      End
      Else
      Begin
       Lg^.Dat.MarketElement[k]:=E^.Dat.MarketElement[l];
       Inc(k);
       Lg^.DAt.Amount:=k-1;
      End;
    End;
    Lg^.DAt.Amount:=k-1;
    Lg^.Dat.Document:=E^.Dat.Document;
    Lg^.Dat.ClientKod:=E^.Dat.ClientKod;
    Lg^.Dat.SkidkaSelector:=E^.Dat.SkidkaSelector;



For i:=1 To Lg^.Dat.Amount Do
 Begin
  Artikul:=Lg^.Dat.MarketElement[i].BazKod;
  If TempBox^.List^.Count-1>=0 Then
  Begin
   Logik:=True;
   For j:=0 To TempBox^.List^.Count-1 Do
    Begin
     Find:=False;
     ws:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CName,CArtikul);
     If ws=Lg^.Dat.MarketElement[i].BazKod Then
      Begin
       Logik:=False;
       ws:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CName,CKol);
       If Lg^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
         begin
           DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
           Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
           (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
         End
       Else
         Begin
           Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
           :CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
         End;
           Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
           Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
       Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,ws);
           s:=GetIdField(FName,Artikul);
           Format(s,CName);

           ws1:=copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CName,CKol);
           Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)+StrToInt(ws1):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
           ws1:=copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CName+CKol+1,CIZena);
           Str(StrToReal(ws)+StrToReal(ws1):CIZena:CMantissa,ws);

           s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+ws;
           TempBox^.List^.AtFree(j);
           TempBox^.SetRange(TempBox^.List^.Count);
           TempBox^.List^.Insert(NewStr(s));
           TempBox^.SetRange(TempBox^.List^.Count);
           Find:=True;
           Break;
      End;
    End;{For по списку продаж}
    If Logik Then{Если не найдено ни одного вхождения}
     Begin
      If Lg^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
        begin
          DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
          Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
          (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        End
      Else
        Begin
         Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
         :CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        End;

        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,ws);
        s:=GetIdField(FName,Artikul);
        Format(s,CName);

        s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+ws;

        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
        {Break;}
     End;
  End{если список не пустой}
    Else
      Begin

     If Lg^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
      begin
       DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
       Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
       (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
      End
      Else
       Begin
       Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
       :CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
       End;

        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        RFormatZerro(Lg^.Dat.Document,CDocNumer);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,ws);
        s:=GetIdField(FName,Artikul);
        Format(s,CName);

        s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+ws;

        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
      End;
 End;{For i:=1 To E^.Dat.Amount Do}

 Dispose(lg,Done);
End;


Procedure AddMarketToList({LocalTempBox:PBox;}Const E:PSuperMarketType; M:MaskaNew);
Var j,i : Word;
    l,k,pp:Byte;
    Artikul : ArtikulStr;
    Otd  : ArtikulStr;
    Find : Boolean;
    ws1,ws ,s: TMyString;
    Lg : PSuperMarketType;
    Logik : Boolean;

Begin
   New(Lg,Init);
   Lg^.Dat:=E^.Dat;
For i:=1 To Lg^.Dat.Amount Do
 Begin
  If M[Lg^.Dat.MarketElement[i].Input.DiviSionSNumber]=1 Then
Begin
  Artikul:=Lg^.Dat.MarketElement[i].BazKod;

  If LocalTempBox^.List^.Count-1>=0 Then
  Begin
   Logik:=True;
   For j:=0 To LocalTempBox^.List^.Count-1 Do
    Begin
     Find:=False;
     ws:=Copy(LocalTempBox^.GetText(j,LocalTempBox^.List^.Count),1+1+CName,CArtikul);
     Otd:=Copy(LocalTempBox^.GetText(j,LocalTempBox^.List^.Count),1+1+CName+CArtikul+1,COne);
     If (ws=Lg^.Dat.MarketElement[i].BazKod)
     And(StrToInt(Otd)=Lg^.Dat.MarketElement[i].Input.DiviSionSNumber) Then
      Begin
       Logik:=False;
       {ws:=Copy(LocalTempBox^.GetText(j,LocalTempBox^.List^.Count),1+1+CArtikul+1+CName,CKol);}
       If Lg^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
         begin
           DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
           Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
           (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
         End
       Else
         Begin
           Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
           :CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
         End;
           Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
           Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
       Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,ws);
           s:=GetIdField(FName,Artikul);
           Format(s,CName);

           ws1:=copy(LocalTempBox^.GetText(j,LocalTempBox^.List^.Count),1+CArtikul+1+CName+1+CONe+1,CKol);

           Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)+StrToInt(ws1):CKol,Lg^.Dat.MarketElement[i].Input.Kol);

           Str(Lg^.Dat.MarketElement[i].Input.DiviSionSNumber:COne,Otd);
           s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Otd+'│'+Lg^.Dat.MarketElement[i].Input.Kol;

           LocalTempBox^.List^.AtFree(j);
           LocalTempBox^.SetRange(LocalTempBox^.List^.Count);
           LocalTempBox^.List^.Insert(NewStr(s));
           LocalTempBox^.SetRange(LocalTempBox^.List^.Count);
           Find:=True;
           Break;
      End;
    End;{For по списку продаж}
    If Logik Then{Если не найдено ни одного вхождения}
     Begin
      If Lg^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
        begin
          DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
          Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
          (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        End
      Else
        Begin
         Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
         :CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        End;

        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,ws);
        s:=GetIdField(FName,Artikul);
        Format(s,CName);

        Str(Lg^.Dat.MarketElement[i].Input.DiviSionSNumber:COne,Otd);
        s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Otd+'│'+Lg^.Dat.MarketElement[i].Input.Kol;

        LocalTempBox^.List^.Insert(NewStr(s));
        LocalTempBox^.SetRange(LocalTempBox^.List^.Count);
        {Break;}
     End;
  End{если список не пустой}
    Else
      Begin

     If Lg^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
      begin
       DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
       Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
       (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
      End
      Else
       Begin
       Str((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
       :CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
       End;

        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        RFormatZerro(Lg^.Dat.Document,CDocNumer);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,ws);
        s:=GetIdField(FName,Artikul);
        Format(s,CName);

        Str(Lg^.Dat.MarketElement[i].Input.DiviSionSNumber:COne,Otd);
        s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Otd+'│'+Lg^.Dat.MarketElement[i].Input.Kol;

        LocalTempBox^.List^.Insert(NewStr(s));
        LocalTempBox^.SetRange(LocalTempBox^.List^.Count);
     End;
End;{M[StrToInt()]=1}
 End;{For i:=1 To E^.Dat.Amount Do}
 Dispose(lg,Done);
End;

(*
Procedure CalcTCh;
Var f : MarketFileType;
    R : TRect;
    E : PSuperMarketType;
    l : Word;
    Date : TDAteString;
    NDS,z,AllSkidka,AllItogo,ItogoSkidka,Itogo : Real;
    s : TMyString;
    ws : AllStr;
    txt1 : Text;
    k,i,j  : Word;
    Vid : Word;
    RAbday,Start,Stop,Den : LongInt;
    Space : AllStr;
Begin
 Space:='      ';
 {Date:=FDate;}
 {If Not(DateDialog(Date)) Then Exit;}
 If Not(PeriodProd) Then Exit;

 Start:=DateStringToDate(DateMask,StartDate);
 Stop:=DateStringToDate(DateMask,StopDate);

 Vid:=0;

 Vid:=SelectImport(1);
 If Vid=2 Then Exit;

 Assign(Txt1,Path.ToTemp+'calcth.txt');
 l:=IOResult;
 Rewrite(Txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path.ToTemp+'calcth.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Close(Txt1);

R.Assign(0, 0, 0, 0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

AllItogo:=0;
AllSkidka:=0;
RabDAy:=0;



For Den:=Start To Stop Do
Begin
{ If DayOfWeek(Den)<>Sunday Then}
 Begin
 Date:=DateToDateString(DateMask,DEn);

 Assign(F,Path.ToMarket+Date+'.mrk');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);
  End;
If l=0 Then
Begin
 Inc(RabDay);
 DInfo('Считаю продажи за '+Date+'...');

 New(E,Init);

While Not (Eof(f)) Do
Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMArket(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }

 If Vid=1 Then
 Begin
 If  (E^.Dat.Active)And(E^.Dat.DocSelector=1) And (E^.Dat.OperatorSelector=0) Then
  Begin
   {Добавление в список максимальных продаж по ТЧ}
   AddMarketToMaxList(E);
  End;{if (E^.Dat.OperatorSelector=1) And Not (E^.Dat.ClientKod='0596')And(E^.Dat.OperatorSelector=0) Then}
 End

 Else
  If (E^.Dat.Active)And(E^.Dat.OperatorSelector=0) And ((Not(E^.Dat.Realiz)) Or ((E^.Dat.Realiz)And
  (E^.Dat.DocSelector in [5,6,7,8])))Then
   Begin
    {Добавление в список всех продаж}
    AddMarketToMarketList(E);
   End;

End;{While}
 Close(f);

 Dispose(E,Done);
 NoInfo;
 End;{l=0}
 End;{Если не воскресенье}
End;{For Den}
 DInfo('Формирую отчет...');
 {записать список в файл и вывести на экран}
 Append(txt1);
If Vid=1 Then
Begin
Writeln(txt1,Space+'Склад: '+FormKod(Rek.Kod)++'  Оператор: '+CurrentPassword);

Writeln(txt1,Space+'   С П Р А В К А  О  РОЗНИЧНЫХ  ПРОДАЖАХ  ЗА  период с '+StartDAte+' по '+StopDate);

Writeln(txt1,Space,RabDay:3,' рабочих дней');

Writeln(txt1,Space+'------------------------------------------------------------------------------------');
Writeln(txt1,Space+' пп Наименование товара          Код   Ко-во  Р/Ц Цена     Сумма по Р/Ц   N    Кл-нт');
                   {123 12345678901234567890123456  12345  12345  12345678  123456789012345  1234  12345678901234567890}
Writeln(txt1,Space+'------------------------------------------------------------------------------------');
AllItogo:=0;
  If TempBox^.List^.Count-1>=0 Then
  Begin
  For i:=0 To TempBox^.List^.Count-1 Do
   Begin
    s:=TempBox^.GetText(i,TempBox^.List^.Count);
    ws:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CZena+1,CIZena);
    AllItogo:=AllItogo+StrToReal(ws);
     {
     ws:=Copy(s,1+1,CArtikul);
     ws:=GetIdField(FName,ws);
     Format(ws,CName);
     s:=ws+''+s;}
   While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert('  ',s,k);
    End;
    Str(i+1:CLitrMantissa,ws);
    s:=ws+' '+s;
    Writeln(txt1,Space+s);
   End;
  End;
Writeln(txt1,Space+'------------------------------------------------------------------------------------');
Writeln(txt1,Space,'                                                  Всего:',RecognizReal(AllItogo,CIZena,CMantissa));
Writeln(txt1,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt1,Space+'====================================================================================');
 Close(txt1);
End
Else
 Begin
Space:='                ';
Writeln(txt1,Space+'Склад: '+FormKod(Rek.Kod)+'  Оператор: '+CurrentPassword);

Writeln(txt1,Space,RabDay:3,' рабочих дней');


Writeln(txt1,Space+'   С П Р А В К А   О   ПРОДАЖАХ  ЗА  период с '+StartDAte+' по '+StopDate);
Writeln(txt1,Space+'--------------------------------------------------------------------');
Writeln(txt1,Space+' пп Наименование товара          Код   Ко-во     Сумма по Р/Ц  Проц.');
                   {123 12345678901234567890123456  12345  12345  123456789012345}
Writeln(txt1,Space+'--------------------------------------------------------------------');
AllItogo:=0;

  If TempBox^.List^.Count-1>=0 Then
  Begin

  For i:=0 To TempBox^.List^.Count-1 Do
   Begin
    s:=TempBox^.GetText(i,TempBox^.List^.Count);
    ws:=Copy(s,1+CName+1+CArtikul+1+CKol+1,CIZena);
    AllItogo:=AllItogo+StrToReal(ws);
   End;

  For i:=0 To TempBox^.List^.Count-1 Do
   Begin
    s:=TempBox^.GetText(i,TempBox^.List^.Count);
     {
     ws:=Copy(s,1+1,CArtikul);
     ws:=GetIdField(FName,ws);
     Format(ws,CName);
     s:=ws+''+s;}
   While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert('  ',s,k);
    End;
    Str(i+1:CLitrMantissa,ws);
    s:=ws+' '+s;

    ws:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1+CKol+1,CIZena);
    Str(StrToReal(ws)/AllItogo*100:CKol:CMantissa,ws);
    Writeln(txt1,Space+s+'  '+ws);
   End;
  End;
Writeln(txt1,Space+'--------------------------------------------------------------------');
Writeln(txt1,Space,'                                        Всего:',RecognizReal(AllItogo,CIZena,CMantissa));
Writeln(txt1,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt1,Space+'====================================================================');
 Close(txt1);
 End;

 Dispose(TempBox,Done);
NoInfo;
ViewAsText(Path.ToTemp+'calcth.txt',True);
Report(Path.ToTemp+'calcth.txt','',1,False,False);
End;{CalcTch}

*)


Function TestMyMarket(s:TDateString;Const M:MaskaNew{;Const LocalTempBox:PBox}):Boolean;
Var b : Boolean;
    j : Word;
    i : Byte;
    Otd :String[COne];
    SArtikul : ArtikulStr;
    st : String;
Begin
TestMyMarket:=False;
     If LocalTempBox^.List^.Count-1>=0 Then
     Begin
      b:=False;
      For j:=0 To LocalTempBox^.List^.Count-1 Do
       Begin
        st:=LocalTempBox^.GetText(j,LocalTempBox^.List^.Count);
        Sartikul:=Copy(st,1+CName+1,CRazdelKod);
        Otd:=Copy(st,1+CName+1+CArtikul+1,COne);
        If (SArtikul=s) And (M[StrToInt(Otd)]=1) Then
         Begin
          b:=True;
          Break;
         End;
       End;
       TestMyMarket:=B;
     End;{If Es^.List.Count-1>=0 Then}
End;

Function GetToDayMarket(s:ArtikulStr;i:Byte{;Const LocalTempBox:PBox}):ArtikulStr;
Var b : Boolean;
    j : Word;
    Otd :String[COne];
    SArtikul : ArtikulStr;
    st : String;
Begin
GetToDayMarket[0]:=#0;
     If LocalTempBox^.List^.Count-1>=0 Then
     Begin
      b:=False;
      For j:=0 To LocalTempBox^.List^.Count-1 Do
       Begin
        st:=LocalTempBox^.GetText(j,LocalTempBox^.List^.Count);
        Sartikul:=Copy(st,1+1+CName,CArtikul);
        Otd:=Copy(st,1+CName+1+CArtikul+1,COne);
        If (SArtikul=s) And (StrToInt(Otd)=i) Then
         Begin
          SArtikul:=Copy(st,1+CName+1+CArtikul+1+COne+1,CKol);
          If StrToInt(SArtikul)>0 Then
           Begin
            DelSpace(SArtikul);
            GetToDayMarket:=SArtikul;
            Exit;
           End;
         End;
       End;
     End;{If Es^.List.Count-1>=0 Then}
End;


{$IFNDEF Kurz}

Procedure Ostatki_Market(Const Spis:PBox;Const M:MaskaNew;Const Assort,Sort:Word);
Var R,R1 : TRect;
    i,l,lk : Word;
    Txt : Text;
    RazdelName,Fas,TempArtikul,s,ss : AllStr;
    ws,ws1,ws2 : String[100];
    Pack,P : String[CPack];
    Space : TEnJoyStr;
    VidProsmotra : Word; {1 - все остатки продажи,
                          0 - остатки только по продающимся позициям}
    RazdelO,RazdelR,ItogoR,ItogoO : Real;
    E : PSkladType;
    Wk : String[CKol];
    Ef : SkladFileType;
    Skidka : Boolean;
    TempList : PBox;
    WspomList: PBox;
    Regim : Word;
    Separator : ArtikulStr;
    sf : MarketFileType;
    es : PSuperMarketType;
    {esbox : PBox;}
    MyWsopList : PBox;
    SInPack,MarketKol,MarketPack:string[CPack];
    PositionZena,Date : TDateString;
    EdIzm : Word;
    RAbday,Start,Stop,Den : LongInt;
    Protocol : Text;


Begin
{ Assign(Protocol,'c:\temp.txt');
 Rewrite(Protocol);            }
 Separator:=' ';
 Assign(Txt,Path.ToTemp+'ostatki.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'ostatki.txt',Nil,mfError+mfCancelButton);
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

 VidProsmotra:=SelectImport(4);
      If VidProsmotra=2 Then
      Begin
        Dispose(TempList,Done);
        Exit;
      End;



 If Not(PeriodProd) Then
    Begin
     Dispose(TempList,Done);
     Exit;
    End;

 Start:=DateStringToDate(DateMask,StartDate);
 Stop:=DateStringToDate(DateMask,StopDate);

{
 Date := FDate;
 If Not(DateDialog(Date)) Then
      Begin
       Dispose(TempList,Done);
       Exit;
      End;
}

R.Assign(0, 0, 0, 0);
LocalTempBox := New(PBox, Init(R, 1, Nil));
LocalTempBox^.NewList(New(PTextCollection, Init(0,1)));

RabDay :=0;

For Den:=Start To Stop Do
Begin
 {If DayOfWeek(Den)<>Sunday Then}
 Begin

 Date:=DateToDateString(DateMask,Den);

 Assign(sF,Path.ToMarket+Date+'.mrk');
 l:=IOResult;
 Reset(sf);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);
  End;

 If L=0 Then
 Begin
 Inc(RabDay);

 DInfo('Рассчитываю продажи за '+Date+'...');


 New(Es,Init);

While Not (Eof(sf)) Do
Begin
     {
     Repeat
     Until Lock(sf,FilePos(sf)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMarket(sf,Es);
     {
     Repeat
      UnLock(sf,(FilePos(sf)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
  If (Es^.Dat.Active)And(Es^.Dat.OperatorSelector=0) And ((Not(Es^.Dat.Realiz)) Or ((Es^.Dat.Realiz)
  And(Es^.Dat.DocSelector in [5,6,7,8])))Then
   Begin
    {Добавление в список всех продаж}
    AddMarketToList({LocalTempBox,}Es,M);
   End;

End;{While}
 Dispose(Es,Done);
 Close(sf);
 NoInfo;
  End;{Если файл удалось открыть}
 End;{Если не воскресенье}
End;{For}


  DInfo('Анализирую остатки...');
  Append(txt);
Space:='                   ';
  Writeln(Txt,Space+'Склад:'+FormKod(Rek.Kod));
  Write(Txt,Space+'Вид отбора: ');
  Case VidProsmotra Of
  0:Writeln(txt,'Полная ведомость');
  1:Writeln(txt,'Только отгруженные');
  Else Writeln(txt);
  End;

  Writeln(Txt,Space+'Выбранные отделения:');
  Write(Txt,Space);
  For l:=1 To CDivision Do
  If M[l]=1 Then Write(txt,l:2,':',Rek.Otdel[l],' ');
  Writeln(Txt);
Space:='          ';
Writeln(Txt,Space+' ВЕДОМОСТЬ ОСТАТКОВ и ОТГРУЗКИ ТОВАРА за период с '+StartDate+' по '+StopDate);

Writeln(Txt,Space+'______________________________________________________________________');
Writeln(Txt,Space+' Код  Отд  Наименование товара        Фас   Цена,   Остатки  Отгружено');
If EdIzm=0 Then
Writeln(Txt,Space+'                                             руб    Колич,шт  Колич,шт')
Else
Writeln(Txt,Space+'                                             руб    Упаковки  Упаковки');

                   {12345│123│12345678901234567890123456│123│12345678│123456789│123456789}
Writeln(Txt,Space+'______________________________________________________________________');

Writeln(Txt);
  ItogoO:=0;
  ItogoR:=0;

{For L:=0 To LocalTempBox^.List^.Count-1 Do
 Begin
  s:=LocalTempBox^.GetText(l,LocalTempBox^.List^.Count);
  wRITELN(TXT,s);
 End;}
 New(E,Init);

 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);



  If TestRazdel(s,M,0,2) Or TestMyMarket(s,M{,LocalTempBox}) Then
  Begin
      RazdelName:=GetRazdel(s);
{
      Writeln(Txt,'                       Раздел: '+GetRazdel(s));
      Writeln(Txt);
}
      Assign(Ef,Path.ToSklad+s+'.db');
      Reset(Ef);
      RazdelO:=0;
      RazdelR:=0;

      R1.Assign(0, 0, 0, 0);
      MyWsopList := New(PBox, Init(R, 1, Nil));
      MyWsopList^.NewList(New(PTextCollection, Init(0,1)));
      While Not(Eof(ef)) Do
      Begin
   {
   Repeat
   Until Lock(ef,FilePos(ef)*SizeOf(SkladType),SizeOf(SkladType));
   }
   ReadSkladPointer(ef,E);
   {
   Repeat
    UnLock(ef,(FilePos(ef)-1)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);
   }
       For i:=1 To CDivision Do
        If M[i]=1 Then
       Begin
           DelSpace(E^.Dat.Input.Kol);
        If ((E^.Dat.Employ)And(M[i]=1)And ((StrToInt(E^.Dat.Input.DivisionS[i])>0))
        Or (StrToInt(GetToDayMarket(E^.Dat.BazKod,i{,LocalTempBox}))>0)) Then
         Begin
          If NPrint.FullName=0 Then Ws:=GetIdField(FName,E^.Dat.Bazkod)
          Else Ws:=GetIdField(FFName,E^.Dat.Bazkod);
          Format(ws,CName);
          RFormat(E^.Dat.Input.DiviSionS[i],CKol);

          PositionZena:=BakGetField(FRZena,E^.Dat.Bazkod,0);
          STr(STrToReal(PositionZena):CZena:CMantissa,PositionZena);

          P:=CalcPackNoFile(GetIdField(FInPack,E^.Dat.Bazkod),E^.Dat.Input.DiviSionS[i]);
          DelSpace(P);
          RFormat(P,CPack);

          If EdIzm=0 Then
            Begin
             P:=E^.Dat.Input.DiviSionS[i];
             DelSpace(P);
             RFormat(P,CPack);
            End;

          Str(i:2,S);


          {If StrToInt(E^.Dat.Input.Division[i])=0 Then S:=Separator+Separator;}
          Str(StrToInt(E^.Dat.Input.DivisionS[i]):CKol,E^.Dat.Input.DivisionS[i]);
          Str(StrToInt(GetToDayMarket(E^.Dat.BazKod,i{,LocalTempBox})):CKol,MarketKol);

          MarketPack:=CalcPackNoFile(GetIdField(FInPack,E^.Dat.Bazkod),MarketKol);
          DelSpace(MarketPack);
          RFormat(MarketPack,CPack);

          If (VidProsmotra=0) Or
            ((VidProsmotra=1) And (StrToInt(MarketKol)>0)) Then
        Begin

          If EdIzm=0 Then
            Begin
             MarketPack:=MarketKol;
             DelSpace(MarketPack);
             RFormat(MarketPack,CPack);
            End;

          SInPack:=GetIdField(FInPack,E^.Dat.BazKod);
          RFormat(SInPack,CInPack);

          Ws:=Space+E^.Dat.BazKod+Separator+Separator+s+Separator+Separator+ws+Separator+SInPAck+Separator+PositionZena+
                Separator+P+Separator+MarketPack;

          If Sort>0 Then
           Begin
            P:=Copy(ws,Ord(Space[0])+1,CArtikul+2+2);
            Delete(ws,Ord(Space[0])+1,CArtikul+2+2);
            ws:=ws+Separator+P;
           End;
          {Writeln(txt,ws);}

          MyWsopList^.List^.Insert(NewStr(ws));
          MyWsopList^.SetRange(MyWsopList^.List^.Count);
        End;
       End;
       End;{For}
      End;{While}

      Close(Ef);

       If ((MyWsopList^.List^.Count-1)>=0) {And (MyWsopList^.List<>Nil)} Then
       Begin
       {печать заголовка раздела}

       Writeln(Txt,'                       Раздел: '+RazdelName);
       Writeln(Txt);

       For lk:=0 To MyWsopList^.List^.Count-1 Do
        Begin
        ws:=MyWsopList^.GetText(lk,MyWsopList^.List^.Count);
        If Sort>0 Then
         Begin
          P:=Copy(ws,Ord(ws[0])-CArtikul-2-1,CArtikul+2+2);
          Delete(ws,Ord(ws[0])-CArtikul-2-2,CArtikul+2+2+1);
          Insert(P,ws,Ord(Space[0])+1);
         End;
          Writeln(txt,ws);

          ws1:=Copy(ws,Ord(Space[0])+1,CArtikul);
          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
          Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt,Space+'      '+Separator+Separator+'   '+ws2);
          End;

        End;
        Writeln(txt);
       End;
        {MyWsopList^.NewList(Nil);}
        Dispose(MyWsopList,Done);
        {MemC;}
   End;{TestRazdel}
     End;{наличие}

    Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

    Writeln(txt,Space+'======================================================================');

 Close(txt);
 Dispose(E,Done);

 Dispose(TempList,Done);
 Dispose(LocalTempBox,Done);
 Str(ItogoR:CIZena:CMantissa,ws);
 NoInfo;
 ViewAsText(Path.ToTemp+'ostatki.txt',True);
{ If Not(TestOpenDate(FDate)) Then}
 Report(Path.ToTemp+'ostatki.txt','',1,False,False,false);
End;


Procedure Test_Sertif(Const Spis:PBox;Const M:MaskaNew;Const Assort,Sort:Word);
Var R,R1 : TRect;
    i,l,lk : Word;
    Txt : Text;
    RazdelName,Fas,TempArtikul,s,ss : AllStr;
    ws,ws1,ws2 : String;
    Pack,P : String[CPack];
    Space : TEnJoyStr;
    VidProsmotra : Word; {1 - все остатки продажи,
                          0 - остатки только по продающимся позициям}
    RazdelO,RazdelR,ItogoR,ItogoO : Real;
    E : PSkladType;
    Wk : String[CKol];
    Ef : SkladFileType;
    Skidka : Boolean;
    TempList : PBox;
    WspomList: PBox;
    Regim : Word;
    Separator : ArtikulStr;
    {esbox : PBox;}
    MyWsopList : PBox;
    SInPack,MarketKol,MarketPack:string[CPack];
    PositionZena,Date : TDateString;
    VidPoiska,Diapason,EdIzm : Word;
    Protocol : Text;


Begin
{ Assign(Protocol,'c:\temp.txt');
 Rewrite(Protocol);            }
 Separator:=' ';
 Assign(Txt,Path.ToTemp+'dsertif.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'dsertif.txt',Nil,mfError+mfCancelButton);
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




 If Not(SelectDSertif(VidPoiska,Diapason)) Then
    Begin
     Dispose(TempList,Done);
     Exit;
    End;

R.Assign(0, 0, 0, 0);
LocalTempBox := New(PBox, Init(R, 1, Nil));
LocalTempBox^.NewList(New(PTextCollection, Init(0,1)));

  DInfo('Анализирую остатки...');
  Append(txt);
  Space:=' ';
  Writeln(Txt,Space+'Склад:'+FormKod(Rek.Kod)+' Оператор:'+CurrentPassword+' EYE & 1999');

  Writeln(Txt,Space+'Выбранные отделения:');
  Write(Txt,Space);
  For l:=1 To CDivision Do
  If M[l]=1 Then Write(txt,l:2,':',Rek.Otdel[l],' ');
  Writeln(Txt);
Space:='      ';
If VidPoiska=1 Then
Writeln(Txt,Space+'        СЕРТИФИКАТЫ, СРОК ДЕЙСТВИЯ КОТОРЫХ ИСТЕКАЕТ В БЛИЖАЙШИЕ '+IntToStr(Diapason,3)+' дней ')
Else
Writeln(Txt,Space+'                               БАЗА СЕРТИФИКАТОВ');

writeln(txt,Condensed[NPrint.Printer]);
Writeln(txt,Space+'_______________________________________________________________________________'+
'______________________________________________________________');
Writeln(txt,Space+' Код    N  Наименование товара        Колич Регистрационный и учетный                  Ср'+
'ок       Наименование органа,');
Writeln(txt,Space+'                                        шт  N сертификата                              дей'+
'ствия   выдающего сертификат');
Writeln(txt,Space+'______________________________________________________________________________'+
'_______________________________________________________________');
Writeln(Txt);

 New(E,Init);

 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);



  If TestRazdel(s,M,0,2) Then
  Begin
      RazdelName:=GetRazdel(s);

      Assign(Ef,Path.ToSklad+s+'.db');
      Reset(Ef);

      R1.Assign(0, 0, 0, 0);
      MyWsopList := New(PBox, Init(R, 1, Nil));
      MyWsopList^.NewList(New(PTextCollection, Init(0,1)));
      While Not(Eof(ef)) Do
      Begin
       ReadSkladPointer(ef,E);
       For i:=1 To CDivision Do
        If M[i]=1 Then
       Begin
        DelSpace(E^.Dat.Input.Kol);

      If ((E^.Dat.Employ) And (StrToInt(E^.Dat.Input.DivisionS[i])>0)And(Assort=0))Or
       ((E^.Dat.Employ)And(Assort>0)And(((StrToInt(E^.Dat.Input.DivisionS[i])>0))Or(i<=1)))Then
         Begin
          If NPrint.FullName=0 Then Ws:=GetIdField(FName,E^.Dat.Bazkod)
          Else Ws:=GetIdField(FFName,E^.Dat.Bazkod);
          Format(ws,CName);
          RFormat(E^.Dat.Input.DiviSionS[i],CKol);

          Str(i:2,S);

          Str(StrToInt(E^.Dat.Input.DivisionS[i]):CKol,E^.Dat.Input.DivisionS[i]);

          Ws:=Space+E^.Dat.BazKod+Separator+Separator+s+Separator+Separator+ws+Separator+
                E^.Dat.Input.DivisionS[i]+Separator;
          ws1:=E^.DAt.Input.NSertif;
          DelSpaceRight(ws1);
          Format(ws1,CNSertif);
          ws:=ws+ws1+Separator;

          ws1:=E^.DAt.Input.DSertif;
          DelSpaceRight(ws1);
          Format(ws1,CDSertif);
          ws:=ws+ws1+Separator;

          ws1:=E^.DAt.Input.KSertif;
          DelSpaceRight(ws1);
          Format(ws1,CKSertif);
          ws:=ws+ws1;


          If (VidPoiska=0) Or
                   (VidPoiska=1) And (DateStringToDate(DateMask,E^.Dat.Input.DSertif)<=
                                     (DateStringToDate(DateMask,FDate)+Diapason)) Then
         Begin
          If Sort>0 Then
           Begin
            P:=Copy(ws,Ord(Space[0])+1,CArtikul+2+2);
            Delete(ws,Ord(Space[0])+1,CArtikul+2+2);
            ws:=ws+Separator+P;
           End;
          {Writeln(txt,ws);}
          MyWsopList^.List^.Insert(NewStr(ws));
          MyWsopList^.SetRange(MyWsopList^.List^.Count);
         End;
         End;
       End;{ if m[i]=1}
      End;{While}

      Close(Ef);

       If ((MyWsopList^.List^.Count-1)>=0) {And (MyWsopList^.List<>Nil)} Then
       Begin
       {печать заголовка раздела}

       Writeln(Txt,'                       Раздел: '+RazdelName);
       Writeln(Txt);

       For lk:=0 To MyWsopList^.List^.Count-1 Do
        Begin
        ws:=MyWsopList^.GetText(lk,MyWsopList^.List^.Count);
        If Sort>0 Then
         Begin
          P:=Copy(ws,Ord(ws[0])-CArtikul-2-1,CArtikul+2+2);
          Delete(ws,Ord(ws[0])-CArtikul-2-2,CArtikul+2+2+1);
          Insert(P,ws,Ord(Space[0])+1);
         End;
          Writeln(txt,ws);

     	ws1:=Copy(ws,Ord(Space[0])+1,CArtikul);
          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
		Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt,Space+'      '+Separator+Separator+'   '+ws2);
          End;


        End;
        Writeln(txt);
       End;
        {MyWsopList^.NewList(Nil);}
        Dispose(MyWsopList,Done);
        {MemC;}
   End;{TestRazdel}
 End;{for по разделам}

    Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

Writeln(txt,Space+'=============================================================================='+
'===============================================================');

 Close(txt);
 Dispose(E,Done);

 Dispose(TempList,Done);
 Dispose(LocalTempBox,Done);
 Str(ItogoR:CIZena:CMantissa,ws);
 NoInfo;
 ViewAsText(Path.ToTemp+'dsertif.txt',True);
{ If Not(TestOpenDate(FDate)) Then}
 Report(Path.ToTemp+'dsertif.txt','',1,False,False,false);
End;



{$ELSE}

Procedure Ostatki_Market(Const Spis:PBox;Const M:MaskaNew;Const Assort,Sort:Word);
Begin
End;


Procedure Test_Sertif(Const Spis:PBox;Const M:MaskaNew;Const Assort,Sort:Word);
Begin
End;


{$ENDIF}




(*
Procedure PrintRewisia(As:DocumentEdit);
Const Space='    ';
Var MMM : Maska;
    f : RewisiaFileType;
    E : PRewisiaType;
    ws : String;
    Prom,Fas,P : String[CPack];
    LocItogoPlus,LocItogoMinus : Real;
    St : String[CMantissa];
    ss,ss1 : TEnjoyStr;
    Summa : String[CIZena];
    l : Word;
    K : Byte;
    Vid:Byte;
    txt : Text;
    Doc : LongInt;
    Minus : Boolean;
    PrintNumer,Find : Boolean;

Begin
 {открытие файлов}
 AInfo('Ищу документ...');
 Assign(F,Path.ToRewisia+As.D+'.rwz');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   MessageBox(#3^M+#3'Не найден файл '+Path.ToRewisia+As.D+'.rwz',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt,Path.ToTemp+'rewisiap.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   NoInfo;
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'rewisiap.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Find :=False;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(RewisiaType),SizeOf(RewisiaType));
     }
     ReadRewisia(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(RewisiaType),SizeOf(RewisiaType));
     Until (DosError=0);
     }
  DelSpace(E^.Dat.Document);
  If  ClearChar(E^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;

 If Not(Find) Then
 Begin
   Close(f);
   Close(txt);
   Dispose(E,Done);
   NoInfo;
   MessageBox(#3^M+#3'Документ ревизии N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
 End;

 Close(f);
 NoInfo;

 {начальная установка отделений}
  For l:=1 To Bit Do
  Begin
   MMM[l]:=1;
  End;
  BitToWord(MMM,L);

  {настройка отделений}
  If Not(SelectOtd(l)) Then
   Begin
    CLose(f);
    Close(txt);
    Dispose(E,Done);
    Exit;
   End
   Else
     Begin
      WordToBit(L,MMM);
      Convert(MMM);
     End;

   {настройка вида отчета: расход/доход/все}
    vid:=SelectSpecify(False,3);
    If Vid=3 Then
     Begin
      CLose(f);
      Close(txt);
      Dispose(E,Done);
      Exit;
     End;


   Writeln(Txt,Space+'Склад: ',E^.Dat.SkladKod+'  Оператор: '+E^.Dat.Caption);
   If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
   Write(txt,Space+{'Последние изменения:'+}' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');

  Writeln(txt,Space+'Выбранные отделения:');
  Write(txt,Space);
  For l:=1 To Bit Do
  If MMM[l]=1 Then Write(txt,l:2,':',Rek.Otdel[l],' ');
  Writeln(txt);

  Case Vid Of
  0:Writeln(txt,Space+'Отбор: Приходная часть');
  1:Writeln(txt,Space+'Отбор: Расходная часть');
  2:Writeln(txt,Space+'Отбор: Все');
  Else;
  End;

   If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
   begin
   Write(txt,Space+{'Последние изменения:'+}' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
   writeln(txt);
   end;




   DelSpaceRight(E^.Dat.Comment);
   If E^.DAt.Comment[0]<>#0 Then
   Begin
    Writeln(txt,Space+'Примечание: '+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+
    E^.Dat.Comment+NoItalic[NPrint.Printer]+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
    Writeln(txt);
   End;


  Writeln(Txt,Space+'                   А К Т    Р Е В И З И И   N '+E^.Dat.Document+' от '+E^.Dat.DateC+' ('+
      E^.Dat.TimeC+')');
  Writeln(txt);
  Writeln(Txt,Space+'                     Комиссия в составе:');
  Writeln(Txt,Space+'       1._____________________   2._____________________');
  Writeln(Txt,Space+'       3._____________________   4._____________________');
  Writeln(Txt,Space+'       произвела ревизию на складе');

  Writeln(Txt,Space+'-------------------------------------------------------------------------------------');
  Writeln(Txt,Space+' N  Код  Наименование товара        Фас  Ко-во  Упаковок     Цена     Итого сумма Отд');
  Writeln(Txt,Space+'-------------------------------------------------------------------------------------');
              {12 12345 12345678901234567890123456 123 123456 123456789 12345678 123456789012345  1 }

LocItogoPlus:=0;
LocItogoMinus:=0;

   For l:=1 To E^.Dat.Amount Do
    Begin
     str(L:2,st);
     PrintNumer:=True;
     For k:=1 To CDivision Do
     Begin
      If (MMM[k]=1) And
            ( ((StrToInt(E^.DAt.element[l].Input.Division[k])>0)And(Vid=0))
         Or((StrToInt(E^.DAt.element[l].Input.Division[k])<0)And(Vid=1))
         Or((StrToInt(E^.DAt.element[l].Input.Division[k])<>0)And(Vid=2))) Then
          Begin
            DelSpace(E^.Dat.Element[l].Input.Division[k]);
            Format(E^.Dat.Element[l].BazKod,CArtikul);
            ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);
            Format(ws,CName);
            DelSpace(E^.Dat.Element[l].Input.DiviSion[k]);

            If (StrToInt(E^.Dat.Element[l].Input.Division[k])<0) Then Minus:=True
            Else Minus:=False;

            Prom:=E^.Dat.Element[l].Input.Division[k];
            {если <0 тогда удаляем минус впереди и считаем упаковки без минуса,
                  а затем подставляем его вновь}
            If Minus Then System.Delete(Prom,Pos('-',Prom),1);

            RFormat(E^.Dat.Element[l].Input.Division[k],CKol+1);


            P:=CalcPack(E^.Dat.Element[l].BazKod,Prom);
            DelSpace(P);

            If Minus Then P:='-('+P+')';

            RFormat(P,CPack);

            Fas:=GetIdField(FInPack,E^.Dat.Element[l].BazKod);
            DelSpace(Fas);
            Format(Fas,CInPack);

            DelSpace(E^.Dat.Element[l].Input.R_Zena);
            RFormat(E^.Dat.Element[l].Input.R_Zena,CZena);

            ws:=E^.Dat.Element[l].BazKod+' '+ws+' '+Fas+' '+E^.Dat.Element[l].Input.Division[k]+
           +' '+P+' '+E^.Dat.Element[l].Input.R_Zena;
           Str((StrToInt(E^.Dat.Element[l].Input.DiviSion[k])*StrToReal(E^.Dat.Element[l].Input.R_Zena)):
           CIZena:CMantissa,ss);
           Str(k:2,P);
           ws:=ws+' '+ss+' '+P;

  If TestLastDiviSion(E^.Dat.Element[l].Input.Division,K,MMM,Vid) Then
  Begin
     If PrintNumer Then
      Begin
      Writeln(txt,Space+st+' '+Pitch[NPrint.Printer]+ws+NoPitch[NPrint.Printer]);
      PrintNumer:=False;
      End
     Else
      Writeln(txt,Space+'   '+Pitch[NPrint.Printer]+ws+NoPitch[NPrint.Printer])
  End
  Else
     Begin
      If PrintNumer Then
      Begin
      Writeln(txt,Space+st+' '+ws);
      PrintNumer:=False;
      End
      Else
      Writeln(txt,Space+'   '+ws)
     End;

{
           If PrintNumer Then Begin
                               Writeln(txt,Space+St+' '+ws);
                               PrintNumer:=False;
                              End
                 Else Writeln(txt,Space+'   '+ws);
}

            If Minus Then
                LocItogoMinus:=LocItogoMinus+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.R_Zena)
            Else
                LocItogoPlus:=LocItogoPlus+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.R_Zena);




          End;{Если сошлось отделение}
     End;{For по отделениям}
    End;{For по документу}

     Writeln(Txt,Space+'-------------------------------------------------------------------------------------');
     Writeln(Txt,Space+'                                              Всего наименований: ',E^.Dat.Amount:CIZena);
     Writeln(Txt,Space+'                                                 приход на склад: ',RecognizReal(LocItogoPlus,CIZena,
        CMantissa),' руб');
     Writeln(Txt,Space+'                                                расход со склада: ',RecognizReal(LocItogoMinus,CIZena,
        CMantissa),' руб');
     Writeln(Txt,Space+'  Проверил акт ревизии ___________                 Всего ревизия: ',RecognizReal(LocItogoPlus+
        LocItogoMinus,
        CIZena,CMantissa),' руб');
     Writeln(txt,Space+'                                                               "'+DayString[DayOfWeek(ToDay)]+'" '+
        FDate+'('+Times+')');
     Writeln(Txt,Space+'=====================================================================================');


Dispose(E,Done);
Close(Txt);
Report(Path.ToTemp+'rewisiap.txt','',NPrint.CopyPrz,False,False)

End;
*)


Procedure PrintRewisia(As:DocumentEdit);
Const Space='    ';
Var MMM : MaskaNew;
    f : RewisiaFileType;
    E : PRewisiaType;
    ws,ws1 : String;
    Prom,Fas,P : String[CPack];
    LocItogoPlus,LocItogoMinus : Real;
    St : String[CMantissa];
    ss,ss1 : TEnjoyStr;
    SArtikul,Summa : String[CIZena];
    l : Word;
    K : Byte;
    Vid:Byte;
    txt : Text;
    Doc : LongInt;
    Minus : Boolean;
    PrintNumer,Find : Boolean;

Begin
 {открытие файлов}
 AInfo('Ищу документ...');
 Assign(F,Path.ToRewisia+As.D+'.rwz');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   MessageBox(#3^M+#3'Не найден файл '+Path.ToRewisia+As.D+'.rwz',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt,Path.ToTemp+'rewisiap.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   NoInfo;
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'rewisiap.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Find :=False;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(RewisiaType),SizeOf(RewisiaType));
     }
     ReadRewisia(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(RewisiaType),SizeOf(RewisiaType));
     Until (DosError=0);
     }
  DelSpace(E^.Dat.Document);
  If  ClearChar(E^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;

 If Not(Find) Then
 Begin
   Close(f);
   Close(txt);
   Dispose(E,Done);
   NoInfo;
   MessageBox(#3^M+#3'Документ ревизии N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
 End;

 Close(f);
 NoInfo;

 {начальная установка отделений}
  For l:=1 To Bit8 Do
  Begin
   MMM[l]:=1;
  End;
  BitToWordNew(MMM,L);

  {настройка отделений}
  If Not(SelectOtd(l)) Then
   Begin
    CLose(f);
    Close(txt);
    Dispose(E,Done);
    Exit;
   End
   Else
     Begin
      WordToBitNew(L,MMM);
      ConvertNew(MMM);
     End;

   {настройка вида отчета: расход/доход/все}
    vid:=SelectSpecify(False,3);
    If Vid=3 Then
     Begin
      CLose(f);
      Close(txt);
      Dispose(E,Done);
      Exit;
     End;


   Writeln(Txt,Space+'Склад: ',E^.Dat.SkladKod+'  Оператор: '+E^.Dat.Caption);
   If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
   Write(txt,Space+{'Последние изменения:'+}' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');

  Writeln(txt,Space+'Выбранные отделения:');
  Write(txt,Space);
  For l:=1 To Max8 Do
  If MMM[l]=1 Then Write(txt,l:2,':',Rek.Otdel[l],' ');
  Writeln(txt);

  Case Vid Of
  0:Writeln(txt,Space+'Отбор: Приходная часть');
  1:Writeln(txt,Space+'Отбор: Расходная часть');
  2:Writeln(txt,Space+'Отбор: Все');
  Else;
  End;

   If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
   begin
   Write(txt,Space+{'Последние изменения:'+}' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
   writeln(txt);
   end;


   Writeln(txt,Space+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+
   'Вид ревизии: '+GetRewGroupField(FNAme,IntToStr(E^.Dat.Class,CKOl))+
+NoItalic[NPrint.Printer]+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);


   DelSpaceRight(E^.Dat.Comment);
   If E^.DAt.Comment[0]<>#0 Then
   Begin
    Writeln(txt,Space+'Примечание: '+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+
    E^.Dat.Comment+NoItalic[NPrint.Printer]+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
    Writeln(txt);
   End;



  Writeln(Txt,Space+'                   А К Т    Р Е В И З И И   N '+E^.Dat.Document+' от '+E^.Dat.DateC+' ('+
      E^.Dat.TimeC+')');
  Writeln(txt);
  Writeln(Txt,Space+'                     Комиссия в составе:');
  Writeln(Txt,Space+'       1._____________________   2._____________________');
  Writeln(Txt,Space+'       3._____________________   4._____________________');
  Writeln(Txt,Space+'       произвела ревизию на складе');

  Writeln(Txt,Space+'-------------------------------------------------------------------------------------');
  Writeln(Txt,Space+' N  Код  Наименование товара        Фас  Ко-во  Упаковок     Цена     Итого сумма Отд');
  Writeln(Txt,Space+'-------------------------------------------------------------------------------------');
              {12 12345 12345678901234567890123456 123 123456 123456789 12345678 123456789012345  1 }

LocItogoPlus:=0;
LocItogoMinus:=0;

   For l:=1 To E^.Dat.Amount Do
    Begin
     str(L:2,st);
     PrintNumer:=True;
     For k:=1 To CDivision Do
     Begin
      If (MMM[k]=1) And
            ( ((StrToInt(E^.DAt.element[l].Input.DivisionS[k])>0)And(Vid=0))
         Or((StrToInt(E^.DAt.element[l].Input.DivisionS[k])<0)And(Vid=1))
         Or((StrToInt(E^.DAt.element[l].Input.DivisionS[k])<>0)And(Vid=2))) Then
          Begin
            DelSpace(E^.Dat.Element[l].Input.DivisionS[k]);
            Format(E^.Dat.Element[l].BazKod,CArtikul);
            SArtikul:=E^.Dat.Element[l].BAzKod;
		 {ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);}
{
	  If NPrint.FullName=0 Then
	  Begin
		ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);
     End
     Else
	 Begin
	  ws:=GetIdField(FFName,E^.Dat.Element[l].BazKod);
	 End;
}
	  If NPrint.FullName=0 Then
	  Begin
		ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);
		ws1:=GetIdField(FName2,E^.Dat.Element[l].BazKod);
		DelSpaceRight(ws1);
		If ws1[0]<>#0 Then
	  Begin
		Writeln(txt,Space+St+' '+SArtikul+' '+ws);
          SArtikul:='     ';
          St:='  ';
          ws:=ws1;
	  End;
     End
     Else
	 Begin
	  ws:=GetIdField(FFName,E^.Dat.Element[l].BazKod);
	  ws1:=GetIdField(FFName2,E^.Dat.Element[l].BazKod);
	  DelSpaceRight(ws1);
	  If ws1[0]<>#0 Then
	  Begin
		Writeln(txt,Space+St+' '+SArtikul+' '+ws);
          SArtikul:='     ';
          St:='  ';
          ws:=ws1;
	  End;
	 End;


	    Format(ws,CName);
	    DelSpace(E^.Dat.Element[l].Input.DiviSionS[k]);

            If (StrToInt(E^.Dat.Element[l].Input.DivisionS[k])<0) Then Minus:=True
            Else Minus:=False;

            Prom:=E^.Dat.Element[l].Input.DivisionS[k];
            {если <0 тогда удаляем минус впереди и считаем упаковки без минуса,
                  а затем подставляем его вновь}
            If Minus Then System.Delete(Prom,Pos('-',Prom),1);

            RFormat(E^.Dat.Element[l].Input.DivisionS[k],CKol+1);


            P:=CalcPack(E^.Dat.Element[l].BazKod,Prom);
            DelSpace(P);

            If Minus Then P:='-('+P+')';

            RFormat(P,CPack);

            Fas:=GetIdField(FInPack,E^.Dat.Element[l].BazKod);
            DelSpace(Fas);
            Format(Fas,CInPack);

            DelSpace(E^.Dat.Element[l].Input.R_Zena);
            RFormat(E^.Dat.Element[l].Input.R_Zena,CZena);

            ws:=SArtikul+' '+ws+' '+Fas+' '+E^.Dat.Element[l].Input.DivisionS[k]+
           +' '+P+' '+E^.Dat.Element[l].Input.R_Zena;
           Str((StrToInt(E^.Dat.Element[l].Input.DiviSionS[k])*StrToReal(E^.Dat.Element[l].Input.R_Zena))
           :CIZena:CMantissa,ss);
           Str(k:2,P);
           ws:=ws+' '+ss+' '+P;

  If TestLastDiviSion(E^.Dat.Element[l].Input.DivisionS,K,MMM,Vid) Then
  Begin
     If PrintNumer Then
      Begin
      Writeln(txt,Space+st+' '+Pitch[NPrint.Printer]+ws+NoPitch[NPrint.Printer]);
      PrintNumer:=False;
      End
     Else
      Writeln(txt,Space+'   '+Pitch[NPrint.Printer]+ws+NoPitch[NPrint.Printer])
  End
  Else
     Begin
      If PrintNumer Then
      Begin
      Writeln(txt,Space+st+' '+ws);
      PrintNumer:=False;
      End
      Else
      Writeln(txt,Space+'   '+ws)
     End;

{
           If PrintNumer Then Begin
                               Writeln(txt,Space+St+' '+ws);
                               PrintNumer:=False;
                              End
                 Else Writeln(txt,Space+'   '+ws);
}

            If Minus Then
                LocItogoMinus:=LocItogoMinus+StrToInt(E^.Dat.Element[l].Input.DivisionS[k])*
                         StrToReal(E^.Dat.Element[l].Input.R_Zena)
            Else
                LocItogoPlus:=LocItogoPlus+StrToInt(E^.Dat.Element[l].Input.DivisionS[k])*
                         StrToReal(E^.Dat.Element[l].Input.R_Zena);




          End;{Если сошлось отделение}
     End;{For по отделениям}
    End;{For по документу}

     Writeln(Txt,Space+'-------------------------------------------------------------------------------------');
     Writeln(Txt,Space+'                                              Всего наименований: ',E^.Dat.Amount:CIZena);
     Writeln(Txt,Space+'                                                 приход на склад: ',RecognizReal(LocItogoPlus,CIZena,
        CMantissa),' руб');
     Writeln(Txt,Space+'                                                расход со склада: ',RecognizReal(LocItogoMinus,CIZena,
        CMantissa),' руб');
     Writeln(Txt,Space+'  Проверил акт ревизии ___________                 Всего ревизия: ',RecognizReal(LocItogoPlus+
        LocItogoMinus,
        CIZena,CMantissa),' руб');
     Writeln(txt,Space+'                                                               "'+DayString[DayOfWeek(ToDay)]+'" '+
        FDate+'('+Times+')');
     Writeln(Txt,Space+'=====================================================================================');


Dispose(E,Done);
Close(Txt);
Report(Path.ToTemp+'rewisiap.txt','',NPrint.CopyPrz,False,False,false)

End;



(*
Function ViewAllRewisia(SDate:TDateString;Auto:Boolean;Default:Byte):AllStr;
Var MMM : Maska;
    f : RewisiaFileType;
    E : PRewisiaType;
    ws : String;
    Prom,Fas,P : String[CPack];
    LocItogoPlus,LocItogoMinus,ItogoPlus,ItogoMinus : Real;
    St : String[CMantissa];
    ss,ss1 : TEnjoyStr;
    Summa : String[CIZena];
    l : Word;
    K : Byte;
    Vid:Byte;
    txt : Text;
    Doc : LongInt;
    PrintNumer,Minus : Boolean;

Begin
 ViewAllRewisia:='           0.00   0';
 {открытие файлов}
 Assign(F,Path.ToRewisia+SDate+'.rwz');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   If Not(Auto) Then
   MessageBox(#3^M+#3'Не найден файл '+Path.ToRewisia+SDate+'.rwz',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt,Path.ToTemp+'rewisia.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   If Not(Auto) Then
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'rewisia.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 {начальная установка отделений}
  For l:=1 To Bit Do
  Begin
   MMM[l]:=1;
  End;
  BitToWord(MMM,L);
  Vid := Default;

  {если на экран то дополнительные настройки}
  If Not(Auto) Then
  Begin
  {настройка отделений}
  If Not(SelectOtd(l)) Then
   Begin
    CLose(f);
    Close(txt);
    Exit;
   End
   Else
         Begin
          WordToBit(L,MMM);
          Convert(MMM);
         End;
   {настройка вида отчета: расход/доход/все}
    vid:=SelectSpecify(False,3);
    If Vid=3 Then
     Begin
      CLose(f);
      Close(txt);
      Exit;
     End;
  End;

ItogoPlus:=0;
ItogoMinus:=0;
Doc:=0;

If Not(Auto) Then   DInfo('Минуточку...');

  New(E,Init);

Writeln(txt,'Выбранные отделения:');
For l:=1 To Bit Do
If MMM[l]=1 Then Write(txt,l:2,':',Rek.Otdel[l],' ');
Writeln(txt);
Writeln(txt);

Case Vid Of
0:Writeln(txt,'Отбор: Приходная часть');
1:Writeln(txt,'Отбор: Расходная часть');
2:Writeln(txt,'Отбор: Все');
Else;
End;
Writeln(txt);


While Not Eof(f) Do
Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(RewisiaType),SizeOf(RewisiaType));
     }
     ReadRewisia(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(RewisiaType),SizeOf(RewisiaType));
     Until (DosError=0);
     }

   Inc(Doc);
   Writeln(Txt,'Склад: ',{E^.Dat.Prihod.Sklad}E^.Dat.SkladKod+
             '  Оператор: '+E^.Dat.Caption);
   If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
   begin
   Write(txt,{'Последние изменения:'+}' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
   writeln(txt);
   end;
   DelSpaceRight(E^.Dat.Comment);
   If E^.DAt.Comment[0]<>#0 Then
   Writeln(txt,'Примечание: '+E^.Dat.Comment);
  Writeln(Txt,'                   А К Т    Р Е В И З И И   N '+E^.Dat.Document+' от '+E^.Dat.DateC+' ('+
      E^.Dat.TimeC+')');

  Writeln(Txt,'-------------------------------------------------------------------------------------');
  Writeln(Txt,' N  Код  Наименование товара        Фас  Ко-во  Упаковок     Цена     Итого сумма Отд');
  Writeln(Txt,'-------------------------------------------------------------------------------------');
              {12 12345 12345678901234567890123456 123 123456 123456789 12345678 123456789012345  1 }

LocItogoPlus:=0;
LocItogoMinus:=0;

   For l:=1 To E^.Dat.Amount Do
    Begin
     str(L:2,st);
     PrintNumer:=True;
     For k:=1 To CDivision Do
     Begin
      If (MMM[k]=1) And
         ( ((StrToInt(E^.DAt.element[l].Input.Division[k])>0)And(Vid=0))
         Or((StrToInt(E^.DAt.element[l].Input.Division[k])<0)And(Vid=1))
         Or((StrToInt(E^.DAt.element[l].Input.Division[k])<>0)And(Vid=2))) Then
          Begin
            DelSpace(E^.Dat.Element[l].Input.Division[k]);
            Format(E^.Dat.Element[l].BazKod,CArtikul);
            ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);
            Format(ws,CName);
            DelSpace(E^.Dat.Element[l].Input.DiviSion[k]);

            If (StrToInt(E^.Dat.Element[l].Input.Division[k])<0) Then Minus:=True
            Else Minus:=False;

            Prom:=E^.Dat.Element[l].Input.Division[k];
            {если <0 тогда удаляем минус впереди и считаем упаковки без минуса,
                  а затем подставляем его вновь}
            If Minus Then System.Delete(Prom,Pos('-',Prom),1);

            RFormat(E^.Dat.Element[l].Input.Division[k],CKol+1);


            P:=CalcPack(E^.Dat.Element[l].BazKod,Prom);
            DelSpace(P);

            If Minus Then P:='-('+P+')';

            RFormat(P,CPack);

            Fas:=GetIdField(FInPack,E^.Dat.Element[l].BazKod);
            DelSpace(Fas);
            Format(Fas,CInPack);

            DelSpace(E^.Dat.Element[l].Input.R_Zena);
            RFormat(E^.Dat.Element[l].Input.R_Zena,CZena);

            ws:=E^.Dat.Element[l].BazKod+' '+ws+' '+Fas+' '+E^.Dat.Element[l].Input.Division[k]+
           +' '+P+' '+E^.Dat.Element[l].Input.R_Zena;
           Str((StrToInt(E^.Dat.Element[l].Input.DiviSion[k])*StrToReal(E^.Dat.Element[l].Input.R_Zena)):
           CIZena:CMantissa,ss);
           Str(k:2,P);
           ws:=ws+' '+ss+' '+P;
           If PrintNumer Then Begin
                                      Writeln(txt,St+' '+ws);
                                PrintNumer:=False;
                              End
                 Else Writeln(txt,'   '+ws);


            If Minus Then
                LocItogoMinus:=LocItogoMinus+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.R_Zena)
            Else
                LocItogoPlus:=LocItogoPlus+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.R_Zena);




          End;{Если сошлось отделение}
     End;{For по отделениям}
    End;{For по документу}

     Writeln(Txt,'-------------------------------------------------------------------------------------');
     Writeln(Txt,'                                              Всего наименований: ',E^.Dat.Amount:CIZena);
     Writeln(Txt,'                                                 приход на склад: ',RecognizReal(LocItogoPlus,CIZena,
        CMantissa),' руб');
     Writeln(Txt,'                                                расход со склада: ',RecognizReal(LocItogoMinus,CIZena,
        CMantissa),' руб');
     Writeln(Txt,'                                                   Всего ревизия: ',RecognizReal(LocItogoPlus+LocItogoMinus,
        CIZena,CMantissa),' руб');
     Writeln(Txt,'=====================================================================================');

     Writeln(Txt);



  ItogoMinus:=ItogoMinus+LocItogoMinus;
  ItogoPlus :=ItogoPlus+LocItogoPlus;
End;{While по файлу}

{If IOREsult<>0 Then SpecialBeep;}

If Not(Auto) Then
Begin
Writeln(txt,'Всего ревизия за '+SDate+' по Р/Ц составила: ',RecognizReal(ItogoPlus+ItogoMinus,CIZena,CMantissa),' руб.');
Writeln(txt,'                        в том числе приход: ',RecognizReal(ItogoPlus,CIZena,CMantissa),' руб.');
Writeln(txt,'                        в том числе расход: ',RecognizReal(ItogoMinus,CIZena,CMantissa),' руб.');
Str(Doc:CLitrMAntissa,ws);
Writeln(Txt,'          Всего за день документов: ',Ws);
End;

Dispose(E,Done);
If Not(Auto) Then  NoInfo;
  Close(f);
  Close(Txt);
If Not(Auto) Then
  ViewAsText(Path.ToTemp+'rewisia.txt',False);

Str(ItogoPlus+ItogoMinus:CIZena:CMantissa,ss);
Str(Doc:3,ss1);
ss:=ss+' '+ss1;
ViewAllRewisia:=ss;

End;
*)

Function ViewAllRewisia(SDate:TDateString;Auto:Boolean;Default:Byte):AllStr;
Var MMM : MaskaNew;
    f : RewisiaFileType;
    E : PRewisiaType;
    ws,ws1 : String;
    Prom,Fas,P : String[CPack];
    LocItogoPlus,LocItogoMinus,ItogoPlus,ItogoMinus,
    LocItogoPlusZ,LocItogoMinusZ,ItogoPlusZ,ItogoMinusZ : Real;
    St : String[CMantissa];
    ss,ss1 : TEnjoyStr;
    Summa : String[CIZena];
    l : Word;
    K : Byte;
    Vid:Byte;
    txt : Text;
    c,Doc : LongInt;
    PrintNumer,Minus : Boolean;
    SArtikul : AllStr;

Begin
 ViewAllRewisia:='           0.00   0';
 {открытие файлов}
 Assign(F,Path.ToRewisia+SDate+'.rwz');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   If Not(Auto) Then
   MessageBox(#3^M+#3'Не найден файл '+Path.ToRewisia+SDate+'.rwz',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt,Path.ToTemp+'rewisia.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   If Not(Auto) Then
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'rewisia.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 {начальная установка отделений}
  For l:=1 To Bit8 Do
  Begin
   MMM[l]:=1;
  End;
  BitToWordNew(MMM,L);
  Vid := Default;

  {если на экран то дополнительные настройки}
  If Not(Auto) Then
  Begin
  {настройка отделений}
  If Not(SelectOtd(l)) Then
   Begin
    CLose(f);
    Close(txt);
    Exit;
   End
   Else
         Begin
          WordToBitNew(L,MMM);
          ConvertNew(MMM);
         End;
   {настройка вида отчета: расход/доход/все}
    vid:=SelectSpecify(False,3);
    If Vid=3 Then
     Begin
      CLose(f);
      Close(txt);
      Exit;
     End;
  End;

ItogoPlus:=0;
ItogoMinus:=0;
ItogoPlusZ:=0;
ItogoMinusZ:=0;
Doc:=0;

If Not(Auto) Then   DInfo('Минуточку...');

  New(E,Init);

Writeln(txt,'Выбранные отделения:');
For l:=1 To Max8 Do
If MMM[l]=1 Then Write(txt,l:2,':',Rek.Otdel[l],' ');
Writeln(txt);
Writeln(txt);

Case Vid Of
0:Writeln(txt,'Отбор: Приходная часть');
1:Writeln(txt,'Отбор: Расходная часть');
2:Writeln(txt,'Отбор: Все');
Else;
End;
Writeln(txt);


While Not Eof(f) Do
Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(RewisiaType),SizeOf(RewisiaType));
     }
     ReadRewisia(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(RewisiaType),SizeOf(RewisiaType));
     Until (DosError=0);
     }

   Inc(Doc);
   Writeln(Txt,'Склад: ',{E^.Dat.Prihod.Sklad}E^.Dat.SkladKod+
             '  Оператор: '+E^.Dat.Caption);
   If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
   begin
   Write(txt,{'Последние изменения:'+}' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
   writeln(txt);
   end;
   DelSpaceRight(E^.Dat.Comment);

   Writeln(txt,'Вид ревизии: '+GetRewGroupField(FNAme,IntToStr(E^.Dat.Class,CKOl)));

   DelSpaceRight(ws);
   If E^.DAt.Comment[0]<>#0 Then
   Writeln(txt,'Примечание: '+E^.Dat.Comment);





  Writeln(Txt,'                   А К Т    Р Е В И З И И   N '+E^.Dat.Document+' от '+E^.Dat.DateC+' ('+
      E^.Dat.TimeC+')');

  Writeln(Txt,'-------------------------------------------------------------------------------------');
  Writeln(Txt,' N  Код  Наименование товара        Фас  Ко-во  Упаковок     Цена     Итого сумма Отд');
  Writeln(Txt,'-------------------------------------------------------------------------------------');
              {12 12345 12345678901234567890123456 123 123456 123456789 12345678 123456789012345  1 }

LocItogoPlus:=0;
LocItogoMinus:=0;

LocItogoPlusZ:=0;
LocItogoMinusZ:=0;

   For l:=1 To E^.Dat.Amount Do
    Begin
     str(L:2,st);
     PrintNumer:=True;
     For k:=1 To CDivision Do
     Begin
      If (MMM[k]=1) And
         ( ((StrToInt(E^.DAt.element[l].Input.DivisionS[k])>0)And(Vid=0))
         Or((StrToInt(E^.DAt.element[l].Input.DivisionS[k])<0)And(Vid=1))
         Or((StrToInt(E^.DAt.element[l].Input.DivisionS[k])<>0)And(Vid=2))) Then
          Begin
            DelSpace(E^.Dat.Element[l].Input.DivisionS[k]);
            Format(E^.Dat.Element[l].BazKod,CArtikul);
            SArtikul:=E^.Dat.Element[l].BazKod;
            {
            ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);}

{
     If NPrint.FullName=0 Then
     Begin
      ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);
     End
     Else
	 Begin
	  ws:=GetIdField(FFName,E^.Dat.Element[l].BazKod);
      End;
}
     If NPrint.FullName=0 Then
     Begin
      ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);
      ws1:=GetIdField(FName2,E^.Dat.Element[l].BazKod);
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
	  Begin
	   Writeln(txt,St+' '+SArtikul+' '+ws);
        SArtikul:='     ';
        St:='  ';
        ws:=ws1;
       End;
     End
     Else
	 Begin
	  ws:=GetIdField(FFName,E^.Dat.Element[l].BazKod);
       ws1:=GetIdField(FFName2,E^.Dat.Element[l].BazKod);
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
	  Begin
	   Writeln(txt,St+' '+SArtikul+' '+ws);
        ws:=ws1;
        SArtikul:='     ';
        St:='  ';
       End;
      End;

             c:=IOResult;

            Format(ws,CName);



            DelSpace(E^.Dat.Element[l].Input.DiviSionS[k]);

            If (StrToInt(E^.Dat.Element[l].Input.DivisionS[k])<0) Then Minus:=True
            Else Minus:=False;

            Prom:=E^.Dat.Element[l].Input.DivisionS[k];
            {если <0 тогда удаляем минус впереди и считаем упаковки без минуса,
                  а затем подставляем его вновь}
            If Minus Then System.Delete(Prom,Pos('-',Prom),1);

            RFormat(E^.Dat.Element[l].Input.DivisionS[k],CKol+1);


            P:=CalcPack(E^.Dat.Element[l].BazKod,Prom);
            DelSpace(P);

            If Minus Then P:='-('+P+')';

            RFormat(P,CPack);

            Fas:=GetIdField(FInPack,E^.Dat.Element[l].BazKod);
            DelSpace(Fas);
            Format(Fas,CInPack);

            DelSpace(E^.Dat.Element[l].Input.R_Zena);
            RFormat(E^.Dat.Element[l].Input.R_Zena,CZena);

            DelSpace(E^.Dat.Element[l].Input.Zakupka);
            RFormat(E^.Dat.Element[l].Input.Zakupka,CZena);

            ws:=SArtikul+' '+ws+' '+Fas+' '+E^.Dat.Element[l].Input.DivisionS[k]+
           +' '+P+' '+E^.Dat.Element[l].Input.R_Zena;

           Str((StrToInt(E^.Dat.Element[l].Input.DiviSionS[k])*StrToReal(E^.Dat.Element[l].Input.R_Zena))
           :CIZena:CMantissa,ss);

           Str(k:2,P);

           ws:=ws+' '+ss+' '+P;

           If PrintNumer Then Begin
                                Writeln(txt,St+' '+ws);
                                PrintNumer:=False;
                              End
                 Else Writeln(txt,'   '+ws);


            If Minus Then
            Begin
                LocItogoMinus:=LocItogoMinus+StrToInt(E^.Dat.Element[l].Input.DivisionS[k])*
                         StrToReal(E^.Dat.Element[l].Input.R_Zena);
                LocItogoMinusZ:=LocItogoMinusZ+StrToInt(E^.Dat.Element[l].Input.DivisionS[k])*
                         StrToReal(E^.Dat.Element[l].Input.Zakupka);
            End
            Else
            Begin
                LocItogoPlus:=LocItogoPlus+StrToInt(E^.Dat.Element[l].Input.DivisionS[k])*
                         StrToReal(E^.Dat.Element[l].Input.R_Zena);
                LocItogoPlusZ:=LocItogoPlusZ+StrToInt(E^.Dat.Element[l].Input.DivisionS[k])*
                         StrToReal(E^.Dat.Element[l].Input.Zakupka);
            End;



          End;{Если сошлось отделение}
     End;{For по отделениям}
    End;{For по документу}

     Writeln(Txt,'-------------------------------------------------------------------------------------');
     Writeln(Txt,'                                              Всего наименований: ',E^.Dat.Amount:CIZena);
     Writeln(Txt,'                                          приход на склад по Р/Ц: ',RecognizReal(LocItogoPlus,CIZena,
        CMantissa),' руб');
     Writeln(Txt,'                                         расход со склада по Р/Ц: ',RecognizReal(LocItogoMinus,CIZena,
        CMantissa),' руб');
     Writeln(Txt,'                                            Всего ревизия по Р/Ц: ',RecognizReal(LocItogoPlus+LocItogoMinus,
        CIZena,CMantissa),' руб');
     If StrToInt(CurrentPassword)=0 Then
     Begin
     Writeln(txt);
     Writeln(Txt,'                                          приход на склад по З/Ц: ',RecognizReal(LocItogoPlusZ,CIZena,
        CMantissa),' руб');
     Writeln(Txt,'                                         расход со склада по З/Ц: ',RecognizReal(LocItogoMinusZ,CIZena,
        CMantissa),' руб');
     Writeln(Txt,'                                            Всего ревизия по З/Ц: ',RecognizReal(LocItogoPlusZ+
	LocItogoMinusZ,CIZena,CMantissa),' руб');
     End;
     Writeln(Txt,'=====================================================================================');

     Writeln(Txt);



  ItogoMinus:=ItogoMinus+LocItogoMinus;
  ItogoPlus :=ItogoPlus+LocItogoPlus;
  ItogoMinusZ:=ItogoMinusZ+LocItogoMinusZ;
  ItogoPlusZ :=ItogoPlusZ+LocItogoPlusZ;
End;{While по файлу}

{If IOREsult<>0 Then SpecialBeep;}

If Not(Auto) Then
Begin
Writeln(txt,'Всего ревизия за '+SDate+' по Р/Ц составила: ',RecognizReal(ItogoPlus+ItogoMinus,CIZena,CMantissa),' руб.');
Writeln(txt,'                        в том числе приход: ',RecognizReal(ItogoPlus,CIZena,CMantissa),' руб.');
Writeln(txt,'                        в том числе расход: ',RecognizReal(ItogoMinus,CIZena,CMantissa),' руб.');
Str(Doc:CLitrMAntissa,ws);
Writeln(Txt,'          Всего за день документов: ',Ws);

 If StrToint(CurrentPassword)=0 Then
  Begin
Writeln(txt);
Writeln(txt,'Всего ревизия за '+SDate+' по З/Ц составила: ',RecognizReal(ItogoPlusZ+ItogoMinusZ,CIZena,CMantissa),' руб.');
Writeln(txt,'                        в том числе приход: ',RecognizReal(ItogoPlusZ,CIZena,CMantissa),' руб.');
Writeln(txt,'                        в том числе расход: ',RecognizReal(ItogoMinusZ,CIZena,CMantissa),' руб.');
  End;


End;

Dispose(E,Done);
If Not(Auto) Then  NoInfo;
  Close(f);
  Close(Txt);
If Not(Auto) Then
  ViewAsText(Path.ToTemp+'rewisia.txt',False);

Str(ItogoPlus+ItogoMinus:CIZena:CMantissa,ss);
Str(Doc:3,ss1);
ss:=ss+' '+ss1;
ViewAllRewisia:=ss;
End;




Procedure ViewKAssa(Auto:Boolean;Shablon:TDAteString);
Const Space='  ';
VAr Data : TDAteString;
    fk,kf : File Of KassaType;
    Txt : Text;
    s : String;
    ktest,Kassa : PKassaType;
    Ext : ArtikulStr;
    w, i,j,c : LongInt;
    find : Boolean;
    OstK,OstB,SumKassa,OstC,OstS : String[CIZena+1];

Begin
 Data :=Shablon;
 If Not(Auto) Then
 If Not(DateDialog(Data)) Then Exit;
 Str(StrToInt(Rek.Kod):2,Ext);
 RFormatZerro(Ext,2);

 Assign(fk,Path.ToArchiv+Data+'.k'+Ext);
 c:=IOResult;
 Reset(fk);
 c:=IOResult;
 If c<>0 Then
 Begin
  MessageBox(^M+#3+'Не могу открыть файл!'+^M+#3+'('+IntToSTr(c,3)+')',Nil,mfError+mfCancelButton);
  Exit;
 End;

 New(Kassa,Init);
 c:=IOResult;
 Read(fk,Kassa^.Dat);
 c:=IOResult;
  If c<>0 Then
   Begin
    c:=IOResult;
    System.Close(fk);
    c:=IOResult;
    Dispose(Kassa,Done);
    MessageBox(^M+#3+'Ошибка чтения файла кассы за '+Data,Nil,mfError+mfCancelButton);
    Exit;
   End;

 System.Close(fk);






Str(StrToInt(Rek.Kod):2,Ext);
RFormatZerro(Ext,2);
Find:=FAlse;
i:=DAteStringToDate(DateMask,Data);
j:=i-10;

 While Not(Find) and (i>=j) Do
  Begin
   Dec(i);
   s:=DAteToDateString(DateMask,i);
   s:=s+'.k'+Ext;
   w := IOResult;
   Assign(kf,Path.ToArchiv+s);
   Reset(kf);
   w:=IOResult;
   If (w=0) Then Find:=True;
  End;

If Not(Find) Then
Begin
 MessageBox(^M+#3'Не могу провести проверку т.к. не найдено ни одного файла за последние 10 дней!',
 Nil,mfError+mfCancelButton);
End
Else
Begin
New(kTest,Init);
w:=IOResult;
Read(kf,KTest^.Dat);
w:=IOResult;
If W<>0 Then
Begin
 Dispose(kTest,Done);
 MessageBox(^M+#3'Ошибка чтения файла '+Path.ToArchiv+s,Nil,mfError+mfCancelButton);
 Find:=False;
End;
Close(kf);
End;


SumKAssa[0]:=#0;
OstK[0]:=#0;
OstS[0]:=#0;
OstC[0]:=#0;
OstB[0]:=#0;


If Find Then
{сумма в кассе}
With kassa^.Dat Do
Begin

Str(STrToReal(SummaInKassa)
-  (StrToReal(Prodagi)
-   StrToReal(SkProdagi)
+   StrToReal(OplataINKassa)
+   StrToReal(Sertifikat)
+   StrToReal(ExtendedDohod)
-   StrToReal(RAshod)
-   StrToReal(RAshodFromReturn)
{-   StrToReal(SkOformConsign)}
+   StrToReal(KTest^.DAt.OstatokInKAssa)
+   StrToReal(SNalogP)  ):CIZena+1:CMAntissa,SumKAssa);
If (Abs(StrToReal(SumKAssa))<0.01) Then SumKassa:='Ок';
DelSpace(SumKassa);


Str(StrToReal(OstatokInKassa)
-  (StrToReal(SummaInKassa)
-   StrToReal(Sdano))
   :CIZena+1:CMAntissa,OstK);

If (Abs(StrToReal(OstK))<0.01) Then OstK:='Ок';
DelSpace(OstK);

Str(StrToReal(OStatok)
-  (StrToReal(kTest^.DAt.OStatok)
+   StrToReal(Prihod)
+   StrToReal(BarterPrihodRZ)
+   StrToReal(EPerewoskiInp)
-   StrToReal(EPerewoskiOut)
-   StrToReal(RP)
-   StrToReal(Prodagi)
-   StrToReal(VidanoConsig)
-   StrToReal(BarterT)
+   StrToReal(Rewisia)
+   StrToReal(Pereozenka)
+   StrToReal(PereozenkaFromReturn)
+   StrToReal(ReturnOutMArketDocAndCloseConsig)
+   StrToReal(ReturnOutOpenConsig))
   :CIZena+1:CMantissa,OstS);
If (Abs(StrToReal(OstS))<0.01) Then OstS:='Ок';
DelSpace(OstS);

Str(StrToReal(OstatokConsig)
-  (StrToReal(kTest^.DAt.OstatokConsig)
+   StrToReal(VidanoConsig)
+   StrToReal(SNalogC)
-   StrToReal(OplataINKassa)
-   StrToReal(SkOformConsign)
-   StrToReal(ReturnOutOpenConsig)
-   StrToReal(SNalogReturnOpenConsig)
+   StrToReal(RashodFromReturnOpenConsig))
    :CIZena+1:CMantissa,OstC);
If (Abs(StrToReal(OstC))<0.01) Then OstC:='Ок';
DelSpace(OstC);


{Сальдо бартера}
Str(StrToReal(OstatokBarter)
-   StrToReal(kTest^.DAt.OstatokBarter)
+   StrToReal(BarterPrihod)
+   StrToReal(BarterINKassa)
-   StrToReal(BarterOutKassa)
-   StrToReal(BarterT)
+   StrToReal(BarterSkidki):CIZena+1:CMantissa,OstB);
If (Abs(StrToReal(OstB))<0.01) Then OstB:='Ок';
DelSpace(OstB);



Dispose(KTest,Done);
End;



 Assign(Txt,Path.ToTemp+'kassa.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;
 If c<>0 Then
  BEgin
  Dispose(Kassa,Done);
  MessageBox(^M+#3+'Не могу создать файл отчета!'+^M+#3+'('+IntToSTr(c,3)+')',Nil,mfError+mfCancelButton);
  Exit;
  End;

Kassa^.FormatReal;

s:=FormKod(Rek.Kod);
s:=GEtClientField(FClient,s,1);
DelSpaceLeftRight(s);


  Writeln(txt,Bold[NPrint.Printer]+Double[NPrint.Printer]);
  Writeln(txt,Space+'       КОНТРОЛЬНЫЙ КАССОВЫЙ ЛИСТ СКЛАДА "'+s+'" ЗА '+DAta);
  Writeln(txt);
  Writeln(txt,Space+'     Заполнил:'+GEtOperatorName(Kassa^.DAt.CAption));
  If Find Then
  Begin
   Writeln(Txt);
   Writeln(txt,Space+'     Результаты проверки');
   Writeln(txt,'   Остаток на складе:'+OstS);
   Writeln(txt,' Остаток консигнации:'+OstC);
   Writeln(txt,'       Сумма в кассе:'+SumKassa);
   Writeln(txt,'     Остаток в кассе:'+OstK);
   Writeln(txt,'   Сальдо по бартеру:'+OstB);
  End;
  Writeln(Txt);
With Kassa^.Dat Do
Begin
Writeln(txt,Space+'   1. Приход на склад от клиента                                  : ',''+Recogniz(Prihod)+'');
Writeln(txt,Space+'   2. Остаток на складе                                           : ',''+Recogniz(Ostatok)+'');
Writeln(txt,Space+'   3. РП работы                                                   : ',''+Recogniz(RP)+'');
Writeln(txt,Space+'   4. Сумма со склада                                             : ',''+Recogniz(SummaOutSklad)+'');
Writeln(txt,Space+'   5. Выдано без отсрочки платежа (Т)                             : ',''+Recogniz(Prodagi)+'');
Writeln(txt,Space+'   6. Скидки выдачи без отсрочки платежа                          : ',''+Recogniz(SkProdagi)+'');
Writeln(txt,Space+'   7. Выдано на консигнацию (Т)                                   : ',''+Recogniz(VidanoConsig)+'');
Writeln(txt,Space+'   8. Скидки выданной консигнации                                 : ',''+Recogniz(SkVidanoConsig)+'');
Writeln(txt,Space+'   9. Оплата консигнации в кассу                                  : ',''+Recogniz(OplataInKassa)+'');
Writeln(txt,Space+'   10.Скидки оформленной консигнации                              : ',''+Recogniz(SkOformConsign)+'');
Writeln(txt,Space+'   11.Возврат по открытой консигнации (Т)                         : ',''+Recogniz(ReturnOutOpenConsig)+'');
Writeln(txt,Space+'   12.Скидки возврата по открытой консигнации                     : ',''+Recogniz(SkReturnOutOpenConsig)+
'');
Writeln(txt,Space+'   13.Возврат по документам продажи и закрытой консигнации (Т)    : ',''+Recogniz
(ReturnOutMArketDocAndCloseConsig)+
'');
Writeln(txt,Space+'   14.Скидки возврата по документам продажи и закрытой консигнации: ',''+Recogniz
(SkReturnOutMArketDocAndCloseConsig)+'');
Writeln(txt,Space+'   15.Остаток консигнации (Т)                                     : ',''+Recogniz(OstatokConsig)+'');
Writeln(txt,Space+'   16.Скидки остатка консигнации                                  : ',''+Recogniz(SkOstatokConsig)+'');
Writeln(txt,Space+'   17.Переоценка                                                  : ',''+Recogniz(Pereozenka)+'');
Writeln(txt,Space+'   18.Переоценка по возврату                                      : ',''+Recogniz(PereozenkaFromReturn)+'');
Writeln(txt,Space+'   19.Сумма в кассе                                               : ',''+Recogniz(SummaInKassa)+'');
Writeln(txt,Space+'   20.Остаток в кассе                                             : ',''+Recogniz(OstatokInKassa)+'');
Writeln(txt,Space+'   21.Дополнительный доход                                        : ',''+Recogniz(ExtendedDohod)+'');
Writeln(txt,Space+'   22.Расходы по возврату                                         : ',''+Recogniz(RashodFromReturn)+'');
Writeln(txt,Space+'   23.Расходы по возврату открытой консигнации                    : ',''
+Recogniz(RashodFromReturnOpenConsig)+'');
Writeln(txt,Space+'   24.Расходы                                                     : ',''+Recogniz(Rashod)+'');
Writeln(txt,Space+'   25.Сертификаты                                                 : ',''+Recogniz(Sertifikat)+'');
Writeln(txt,Space+'   26.Сдано                                                       : ',''+Recogniz(Sdano)+'');
Writeln(txt,Space+'   27.Ревизия на складе                                           : ',''+Recogniz(Rewisia)+'');
Writeln(txt,Space+'   28.Сбор НП по отгрузке клиенту без отсрочки платежа            : ',''+Recogniz(SNAlogP)+'');
Writeln(txt,Space+'   29.Сбор НП по отгрузке клиенты на консигнацию товару           : ',''+Recogniz(SNAlogC)+'');
Writeln(txt,Space+'   30.НП по возврату отрытой консигнации                          : ',''
+Recogniz(SNAlogReturnOpenConsig)+'');

If Password(2) Then
Begin
Writeln(txt,Space+'   27.Доход по итогам торгового дня                               : ',''+Recogniz(VidanoSF)+'');
Writeln(txt,Space+'  31. Сальдо по взаимозачетам                                     : ',''+Recogniz(OstatokBarter)+'');
Writeln(txt,Space+'  32. Приход в счет взаимозачетов по З/Ц                          : ',''+Recogniz(BarterPrihod)+'');
Writeln(txt,Space+'  33. Приход в счет взаимозачетов по Р/Ц                          : ',''+Recogniz(BarterPrihodRZ)+'');
Writeln(txt,Space+'  34. Выдано в счет взаимозачетов (Т)                             : ',''+Recogniz(BarterT)+'');
Writeln(txt,Space+'  35. Скидки выдачи в счет взаимозачетов (Т)                      : ',''+Recogniz(BarterSkidki)+'');
Writeln(txt,Space+'  36. Поступления в кассу в счет взаимозачетов                    : ',''+Recogniz(BarterInKassa)+'');
Writeln(txt,Space+'  37. Расход из кассы в счет взаимозачетов                        : ',''+Recogniz(BarterOutKassa)+'');
End;


For c:=0 To 6 Do
Begin
Str(c+1:CClientKod,s);
s:=GEtClientField(FClient,s,1);
DelSpaceLeftRight(s);
Format(s,CClient);
If Abs(StrToReal(PerewoskiOut[c]))>0.01 Then
Writeln(txt,Space,'   ',c+38:2,'.Перевозки со склада на '+s+'                 : ',''+Recogniz(PerewoskiOut[c])+'');
End;

For c:=0 To 6 Do
Begin
Str(c+1:CClientKod,s);
s:=GEtClientField(FClient,s,1);
DelSpaceLeftRight(s);
Format(s,CClient);
If Abs(StrToReal(PerewoskiInp[c]))>0.01 Then
Writeln(txt,Space,'   ',c+45:2,'.Перевозки на склад  с  '+s+'                 : ',''+Recogniz(PerewoskiInp[c])+'');
End;



Writeln(txt,Space+'   46.Итого перевозки со склада                                   : ',''+Recogniz(EPerewoskiOut)+'');
Writeln(txt,Space+'   47.Итого перевозки на склад                                    : ',''+Recogniz(EPerewoskiInp)+'');

Writeln(txt);
Writeln(txt,Space+'                                                           "'+DayString[DayOfWeek(ToDay)]+'" '+
        FDate+'('+Times+')'+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);

Writeln(txt,Space+'   ================================================================================');
End;
 Dispose(Kassa,Done);
 Close(Txt);
 ViewAsText(Path.ToTemp+'Kassa.txt',True);
 Report(Path.ToTemp+'Kassa.txt','',NPrint.CopyPrz,False,False,false)
End;


Procedure ViewSpecialKAssa(Auto:Boolean;Shablon:TDAteString);
Const Space='  ';
VAr Data : TDAteString;
    fk,kf : File Of HiddenKassaType;
    Txt : Text;
    s : String;
    ktest,Kassa : PHiddenKassaType;
    Ext : ArtikulStr;
    w, i,j,c : LongInt;
    find : Boolean;
    OstK,SumKassa,OstC,OstS : String[CIZena+1];

Begin
 Data :=Shablon;
 If Not(Auto) Then
 If Not(DateDialog(Data)) Then Exit;
 Str(StrToInt(Rek.Kod):2,Ext);
 RFormatZerro(Ext,2);

 Assign(fk,Path.ToArchiv+Data+'.h'+Ext);
 c:=IOResult;
 Reset(fk);
 c:=IOResult;
 If c<>0 Then
 Begin
  MessageBox(^M+#3+'Не могу открыть файл!'+^M+#3+'('+IntToSTr(c,3)+')',Nil,mfError+mfCancelButton);
  Exit;
 End;

 New(Kassa,Init);
 c:=IOResult;
 Read(fk,Kassa^.Dat);
 c:=IOResult;
  If c<>0 Then
   Begin
    c:=IOResult;
    System.Close(fk);
    c:=IOResult;
    Dispose(Kassa,Done);
    MessageBox(^M+#3+'Ошибка чтения файла кассы за '+Data,Nil,mfError+mfCancelButton);
    Exit;
   End;

 System.Close(fk);






Str(StrToInt(Rek.Kod):2,Ext);
RFormatZerro(Ext,2);



 Assign(Txt,Path.ToTemp+'hkassa.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;
 If c<>0 Then
  BEgin
  Dispose(Kassa,Done);
  MessageBox(^M+#3+'Не могу создать файл отчета!'+^M+#3+'('+IntToSTr(c,3)+')',Nil,mfError+mfCancelButton);
  Exit;
  End;

Kassa^.FormatReal;

s:=FormKod(Rek.Kod);
s:=GEtClientField(FClient,s,1);
DelSpaceLeftRight(s);


  Writeln(txt,Bold[NPrint.Printer]+Double[NPrint.Printer]);
  Writeln(txt,Space+'       ДОПОЛНИТЕЛЬНЫЙ КОНТРОЛЬНЫЙ КАССОВЫЙ ЛИСТ СКЛАДА "'+s+'" ЗА '+DAta);
  Writeln(txt);

  Writeln(Txt);
With Kassa^.Dat Do
Begin
Writeln(txt,Space+'   1. Приход на склад по З/Ц                                      : ',''+Recogniz(PrihodZ)+'');
Writeln(txt,Space+'   2. Остаток на складе по З/Ц                                    : ',''+Recogniz(OstatokZ)+'');

Writeln(txt,Space+'   3. Возврат на склад по З/Ц                                     : ',''+Recogniz(ReturnZ)+'');
Writeln(txt,Space+'   4. Остаток консигнации по оплате (САМОВЫВОЗ)                   : ',''+Recogniz(AllDolg)+'');

Writeln(txt,Space+'   5. Остаток консигнации по оплате (Торговые представители)      : ',''+Recogniz(AllDolgA)+'');
Writeln(txt,Space+'   6. Ревизия на складе по З/Ц                                    : ',''+Recogniz(RewisiaZ)+'');

Writeln(txt,Space+'   7. Упущенный доход из-за возврата                              : ',''+Recogniz(MinusDohod)+'');
Writeln(txt,Space+'   8. Доход по отгрузке (САМОВЫВОЗ)                               : ',''+Recogniz(AllDohod)+'');

Writeln(txt,Space+'   9. Доход по отгрузке (Торговые представители)                  : ',''+Recogniz(AllDohodA)+'');

Writeln(txt,Space+'  10. Остаток консигнации (просроченные долги)                    : ',''+Recogniz(DolgiIstekshie)+'');
Writeln(txt,Space+'  11. Остаток консигнации                                         : ',''+Recogniz(DolgiVse)+'');

Writeln(txt,Space+'  12. Сумма просроченных платежей поставщикам                     : ',''+Recogniz(PlategiIstekshie)+'');
Writeln(txt,Space+'  12. Сумма долга поставщикам                                     : ',''+Recogniz(PlategiVse)+'');

Writeln(txt);
Writeln(txt,Space+'                                                           "'+DayString[DayOfWeek(ToDay)]+'" '+
        FDate+'('+Times+')'+NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);

Writeln(txt,Space+'   ================================================================================');
End;
 Dispose(Kassa,Done);
 Close(Txt);
 ViewAsText(Path.ToTemp+'hKassa.txt',True);
 Report(Path.ToTemp+'hKassa.txt','',NPrint.CopyPrz,False,False,false)
End;




Procedure CalcAllNakl (Date: TDateString;
Var VidaNoC:AllStr;Var VidanoCKol:ArtikulStr;Var VidanoCSkidki:AllStr;
Var SkidkiOfC:AllStr;Var SkidkiOfCKol:ArtikulStr;
Var ProdagiC :AllStr;Var ProdagiCKol :ArtikulStr;Var ProdagiCSkidki :AllStr;
Var ProdagiS :AllStr;Var ProdagiSKol :ArtikulStr;
Var RP :AllStr;Var RPKol :ArtikulStr;
Var Sf :AllStr;Var SfKol :ArtikulStr;

Var VidanoCSf:AllStr;Var VidanoCSfKol:ArtikulStr;
Var VidanoCSfSkid:AllStr;Var VidanoCSfSkidKol:ArtikulStr;
Var SkidkiOfCSf:AllStr;Var SkidkiOfCKolSf:ArtikulStr;
Var SpecNAlogP:AllStr;Var SpecNAlogC:AllStr;
Var BarterT:AllStr;Var BarterKol:Artikulstr; Var BarterSkidki:AllStr);

Label 1;

Var f : MarketFileType;
    E : PSuperMarketType;
    l : Word;
    s : TMyString;
    ws : String[CName];
    pp : String[CPack];
    Proz : String[CLitr];
    sh,Vid : Byte;
    Space: TDateString;
    Wiwod : Boolean;
    Doc : LongInt;
    fr : File Of RealizasiaType;
    Er : PRealizasiaType;
    Find : Boolean;

Begin
     ProdagiC :='           0.00';{1}
  ProdagiCKol :='  0';            {2}
ProdagiCSkidki:='           0.00';{3}
     ProdagiS :='           0.00';{4}
  ProdagiSKol :='  0';            {5}
           RP :='           0.00';{6}
        RPKol :='  0';            {7}
       VidaNoC:='           0.00';{8}
    VidanoCKol:='  0';            {9}
 VidanoCSkidki:='           0.00';{10}
     SkidkiOfC:='           0.00';{11}
  SkidkiOfCKol:='  0';            {12}
           Sf :='           0.00';{13}
        SfKol :='  0';            {14}

  VidanoCSfKol:='  0';            {15}
     VidanoCSF:='           0.00';{16}

VidanoCSfSkidKol:='  0';          {17}
 VidanoCSFSkid:='           0.00';{18}

SkidkiOfCKolSf:='  0';            {19}
   SkidkiOfCSf:='           0.00';{20}
   SpecNalogP:='           0.00';{28}
   SpecNalogC:='           0.00';{29}
      BarterT:='           0.00'; {30}
    BarterKol:='  0';            {31}
 BarterSkidki:='           0.00'; {32}



 Assign(F,Path.ToMarket+Date+'.mrk');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   Exit;
  End;
 New(E,Init);
While Not (Eof(f)) Do
Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     ReadMarket(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
 If (E^.Dat.Active) Then
  Begin
   {подсчитываем СФ}
   If (E^.Dat.OperatorSelector in [0,2]) Then
   If (E^.Dat.DocSelector in [0,1,2,3,4]) Then
        Begin
  {13}   Str(StrToReal(Sf)+StrToReal(E^.Dat.SummaZ)-
             StrToReal(E^.Dat.ENalog)-StrToReal(E^.Dat.SummaZakupka)
             :CIZena:CMantissa,Sf);
  {14}   Str(StrToInt(SfKol)+1:CLitrMantissa,SfKol);
        End;

   {подсчитываем бартер}
   If (E^.Dat.OperatorSelector=2) Then
        Begin
  {30}   Str(StrToReal(BarterT)+StrToReal(E^.Dat.SummaZ)+StrToReal(E^.Dat.Skidka):CIZena:CMantissa,BarterT);
  {31}   Str(StrToInt(BarterKol)+1:CLitrMantissa,BarterKol);
  {32}   Str(StrToReal(BarterSkidki)+StrToReal(E^.Dat.Skidka):CIZena:CMantissa,BarterSkidki);
        End;

   {подсчитываем величину спец налога без отсрочки платежа}
   If (E^.Dat.OperatorSelector=0) Then
   If (Not(E^.Dat.Realiz)And(E^.Dat.DocSelector in [{1,}2,3])) Then {отключен расчет НП в ТЧ}
        Begin
  {28}   Str(StrToReal(SpecNalogP)+StrToReal(E^.Dat.ENAlog):CIZena:CMantissa,SpecNalogP);
        End;


   If (E^.Dat.OperatorSelector=0) Then
   If ((E^.Dat.DocSelector in [5,6])) Then
        Begin
  {29}   Str(StrToReal(SpecNalogC)+StrToReal(E^.Dat.ENAlog):CIZena:CMantissa,SpecNalogC);
        End;


   If (E^.Dat.OperatorSelector in [0,2]) And (E^.Dat.DocSelector in [3,4]) Then
        Begin
            If (E^.Dat.Realiz){ And Not(E^.DAt.DocSelector in[5,6])} Then
                Begin
                 If TestSf(E^.Dat.ClientKod,E^.Dat.DocReal,E^.Dat.DocDate) Then
                  Begin
         {19}   Str(StrToReal(SkidkiOfCSf)+StrToReal(E^.Dat.Skidka):CIZena:CMantissa,SkidkiOfCSf);
         {20}   Str(StrToInt(SkidkiOfCKolSf)+1:CLitrMantissa,SkidkiOfCKolSf);
                  End;
                End;
        End;




   {подсчитываем РП}
   If (StrToInt(E^.Dat.ClientKod)=StrToInt(ClientRP)) And (E^.Dat.OperatorSelector=1) And Not(E^.Dat.Realiz) Then
        Begin
   {1}   Str(StrToReal(RP)+StrToReal(E^.Dat.SummaZ):CIZena:CMantissa,RP);
   {2}   Str(StrToInt(RPKol)+1:CLitrMantissa,RPKol);
         Goto 1;
        End;

   {подсчитываем продажи с клиентом}
   If (E^.Dat.OperatorSelector=0) And (E^.Dat.DocSelector in [0,1,2,3,4]) And Not(E^.Dat.Realiz) Then
     Begin
   {3}   Str(StrToReal(ProdagiC)+StrToReal(E^.Dat.SummaZ)-StrToReal(E^.DAt.ENalog):CIZena:CMantissa,ProdagiC);
   {4}   Str(StrToReal(ProdagiCSkidki)+StrToReal(E^.Dat.Skidka):CIZena:CMantissa,ProdagiCSkidki);
   {5}   Str(StrToInt(ProdagiCKol)+1:CLitrMantissa,ProdagiCKol);
         Goto 1;
     End;

   {подсчитываем продажи со складом}
   If (E^.Dat.OperatorSelector=1) And (E^.Dat.DocSelector in [0,1,2,3,4]) And Not(E^.Dat.Realiz) Then
     Begin
   {6}   Str(StrToReal(ProdagiS)+StrToReal(E^.Dat.SummaZ)-StrToReal(E^.DAt.ENalog):CIZena:CMantissa,ProdagiS);
   {7}   Str(StrToInt(ProdagiSKol)+1:CLitrMantissa,ProdagiSKol);
         Goto 1;
     End;

   {подсчитываем выдано на консигнацию}
   If (E^.Dat.OperatorSelector=0) And (E^.Dat.DocSelector in [5,6,7,8]) Then
     Begin
   {8}   Str(StrToReal(VidaNoC)+StrToReal(E^.Dat.SummaZ)-StrToReal(E^.DAt.ENalog):CIZena:CMantissa,VidaNoC);
   {9}   Str(StrToReal(VidaNoCSkidki)+StrToReal(E^.Dat.Skidka):CIZena:CMantissa,VidaNoCSkidki);
   {10}  Str(StrToInt(VidaNoCKol)+1:CLitrMantissa,VidaNoCKol);


   If (E^.Dat.DocSelector in [6,8]){TestSf(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC)} Then
   Begin
   {15}  Str(StrToInt(VidaNoCSFKol)+1:CLitrMantissa,VidaNoCSFKol);
   {16}  Str(StrToReal(VidanoCSF)+StrToReal(E^.Dat.SummaZ)-StrToReal(E^.DAt.ENalog):CIZena:CMantissa,VidanoCSF);

   {17}  Str(StrToInt(VidaNoCSFSkidKol)+1:CLitrMantissa,VidaNoCSFSkidKol);
   {18}  Str(StrToReal(VidanoCSFSkid)+StrToReal(E^.Dat.Skidka):CIZena:CMantissa,VidanoCSFSkid);
   End;
      Goto 1;
     End;

   {подсчитываем оформленную консигнацию}
   If (E^.Dat.OperatorSelector=0) And (E^.Dat.DocSelector in [0,1,2,3,4]) And (E^.Dat.Realiz) Then
     Begin
   {11}  Str(StrToReal(SkidkiOfC)+StrToReal(E^.Dat.Skidka):CIZena:CMantissa,SkidkiOfC);
   {12}  Str(StrToInt(SkidkiOfCKol)+1:CLitrMantissa,SkidkiOfCKol);
      Goto 1;
     End;
  End;
1:
End;
Dispose(E,Done);
Close(f);
End;




Function TestElementSpis (Const S : ArtikulStr;Const P : PBox;Const Sort:Word) : Boolean;
Var ls : Word;
    k  : Byte;
    st : String[CALL];
Begin
TestElementSpis:=False;
For ls :=0 To P^.List^.Count-1 Do
Begin
St:=P^.GetText(ls,P^.List^.Count);
k:=Pos('│',St);
If Sort=1 Then
ST:=Copy(St,K+1,CRazdelKod) Else ST:=Copy(St,1,CRazdelKod);
If St=S Then
   Begin
    TestElementSpis:=True;
    Break;
   End;
End;
End;



Procedure PrintSKL(Const Spis:PBox;Const M:MaskaNew; Const Assort,Sort:Word);

Const Space='';
VAr sklFile : SkladFileType;
    skl : pSkladType;
    Skid : PSkidkaType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    F : Boolean;
    TArt,Zena,Zakupka,Lob:String[CZena];
    Max,Min : TDAteString;
    jk,l,c : Word;
    txt : Text;
    wws,ws,s : String;
    R,R1 : TRect;
    lk : LongInt;
    ttt,TempList, WspomList :PBox;
    Regim : LongInt;
    sh,VidPrize : Word;
    Mas : Maska24;
    Region : Word;
    SSS : Boolean;
    MMM : Maska6;
Begin

  VidPrize:=SelectPrize(Mas,6,Region,FAlse,MMM);
  If VidPrize=1 Then
   Begin
    Exit;
   End;

   SSS:=FAlse;
If MessageBox(^M+#3'Показать минимальные наценки по шкалам?',Nil,mfOkCancel)=cmOk Then SSS:=True;


c:=IOResult;
Assign(txt,Path.ToTemp+'skidki.txt');
Rewrite(txt);
c:=IOResult;

Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+' Оператор:'+CurrentPassword);
Writeln(Txt,Space+'         ТАБЛИЦЫ АВТОМАТИЧЕСКИХ СКИДОК на '+FDate);

Case Region Of
0:Writeln(Txt,Space+'Офис');
1:Writeln(Txt,Space+'Город');
2:Writeln(Txt,Space+'Область');
3:Writeln(Txt,Space+'Резерв');
Else;
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
      Close(Txt);
      Dispose(TempList,Done);
      Exit;
     End;

   Else;
   End;



DInfo('Минуточку...');




 For jk:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then wws:=Copy(TempList^.GetText(jk,TempList^.List^.Count),1,CRazdelKod)
  Else
  wws:=Copy(TempList^.GetText(jk,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);

  If TestRazdel(wws,M,Assort,2) Then
Begin

   Writeln(txt);
   Writeln(txt,Space+'   Раздел:'+GetRazdel(wws));

   s:='Код   Наименование             З/Цена   Р/Ц ';

 For sh:=1 To CShkala Do
  Begin
   If Mas[sh]=1 Then
    Begin
    ws:=IntToStr(Round(sh-Region*6),CMAntissa);
    RFormat(ws,CLitr);
    s:=s+ws+' ';
    If SSS Then s:=s++' Min %';
    End;
  End;
  s:=s+'   Max   Min ';

  s[0]:=Chr(Ord(s[0])-1);

 ws[0]:=#0;
 For sh:=1 To Ord(s[0]) Do
  Begin
    ws[sh]:='_';
    ws[0]:=Chr(sh);
  End;



   Writeln(txt,Space+ws);
   Writeln(txt,Space+s);
   Writeln(txt,Space+ws);
                     {12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789}
                     {12345 12345678901234567890123456 12345678 12345 12345 12345 12345 12345 12345 12345 12345}
   Assign(SklFile,Path.ToSklad+wws+'.db');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;
   If c<>0 Then
    Begin
     Close(txt);
     MessageBox(^M+#3'Ошибка доступа к файлу '+Path.ToSklad+RazdelElement.Kod+'.db',Nil,mfError+mfCancelButton);
     Exit;
    End;

   R1.Assign(0,0,0,0);
   ttt := New(PBox, Init(R1, 1, Nil));
   ttt^.NewList(New(PTextCollection, Init(0,1)));

   New(Skl,Init);
   New(Skid,Init);

   While Not(Eof(sklFile)) Do
Begin
     ReadSkladPointer(SklFile,Skl);
     If ((StrToInt(Skl^.Dat.Input.Kol)>0) and (Assort=0)) Or
         (Assort=1) Then
     {фильтр количества}
Begin
     s[0]:=#0;
     ws[0]:=#0;
     ws := GetIdField(FName,Skl^.Dat.BazKod);
     Format(ws,CNAme-3);
     Str(StrtoReal(Skl^.Dat.Input.Zakupka):CZena:CMantissa,Zakupka);
     Str(StrtoReal(Skl^.Dat.Input.R_Zena):CZena:CMantissa,Lob);

     If StrToreal(Zakupka)>0.01 Then
       Str((StrToReal(Lob)-StrToReal(Zakupka))/StrToreal(Zakupka)*100:Clitr:CMantissa,Max)
     Else Max:='?????';
       s:=Skl^.Dat.BazKod+' '+ws+' '+Zakupka+' '+Max;

     GetSkidka(Skl^.Dat.BazKod,Skid^.Dat);

     Str(StrToReal(Lob)*(StrToreal(Skid^.DAt.Skidka[1].Proz)):CZena:CMantissa,Zena);

     If StrToreal(Zakupka)>0.01 Then
  Begin
      Str((StrToReal(Zena)-StrToReal(Zakupka))/StrToReal(Zakupka)*100:CLitr:CMantissa,Max);
      Min:=Max;
  End
     Else
  Begin
      Max:='?????';
      Min:='?????';
  End;


     For l:=1 To CShkala Do
      Begin
       If Mas[l]=1 Then
  Begin
       Str(StrToReal(Lob)*(StrToreal(Skid^.DAt.Skidka[l].Proz)):CZena:CMantissa,Zena);
       If StrToreal(Zakupka)>0.01 Then
       Begin
         Str((StrToReal(Zena)-StrToReal(Zakupka))/StrToReal(Zakupka)*100:CLitr:CMantissa,
        	 Skid^.DAt.Skidka[l].Proz);
         If StrToReal(Skid^.DAt.Skidka[l].Proz)>StrToReal(Max) Then Max:=Skid^.DAt.Skidka[l].Proz;
         If StrToReal(Skid^.DAt.Skidka[l].Proz)<StrToReal(Min) Then Min:=Skid^.DAt.Skidka[l].Proz;
       End
       Else
	   Begin
	    Skid^.DAt.Skidka[l].Proz:='?????';
         Max:='?????';
         Min:='?????';
        End;
        Str(StrToReal(Skid^.DAt.Skidka[l].MinNaz):CLitr:CMantissa,Skid^.DAt.Skidka[l].MinNaz);
        s:=s+' '+Skid^.DAt.Skidka[l].Proz;
        If SSS Then s:=s+' '+Skid^.DAt.Skidka[l].MinNaz;
  End;
      End;{For l:=1 To CShkala}

    s:=s+' '+Max+' '+Min;
    If Sort > 0 Then
    Begin
     System.Delete(s,1,CArtikul);
     s:=s+Skl^.Dat.BazKod;
    End;
    ttt^.List^.Insert(NewStr(s));
    ttt^.SetRange(ttt^.List^.Count);

End;{тест количества}
End;{While}

      Dispose(Skl,Done);
      Dispose(Skid,Done);

     If ((ttt^.List^.Count-1)>=0) Then
      For lk:=0 To ttt^.List^.Count-1 Do
      Begin
       s:=ttt^.GetText(lk,ttt^.List^.Count);
       If Sort>0 Then
       Begin
        TArt:=Copy(s,Ord(s[0])-CArtikul+1,CArtikul);
        Delete(s,Ord(s[0])-CArtikul+1,CArtikul);
       End;
       Writeln(txt,Space+TArt+s);
      End;{for печати}

    Dispose(ttt,Done);
    c:=IoResult;
    Close(SklFile);

   End;{TestRazdel}
End;{For}

c:=IOResult;
Dispose(TempList,Done);
Writeln(txt);
Writeln(txt);
Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt,Space+'============================================================================================');
Close(txt);
NoInfo;
ViewAsText(Path.ToTemp+'Skidki.txt',True);
End;




Procedure AddMarketToMarketListWithZena(Const E:PSuperMarketType);
Var j,i : Word;
    l,k,pp:Byte;
    Artikul : ArtikulStr;
    Find : Boolean;
    ws1,ws ,s,ws2,ws3: TMyString;
    Lg : PSuperMarketType;
    Logik : Boolean;
    Zen,ZenZ : TDateString;

Begin
   New(Lg,Init);
   k:=1;pp:=1;
   For l:=1 To E^.Dat.Amount Do
    Begin
      Lg^.Dat.MarketElement[l]:=E^.Dat.MarketElement[l];

       Case E^.Dat.SkidkaSelector Of
            0,2:Begin{скидка автоматическая}
               Str(StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)/
               (1+StrToReal(Lg^.Dat.MarketElement[l].Input.Proz)/100):CZena:CMantissa,Lg^.Dat.MarketElement[l].Input.Zena);
              End;
            1:Begin{скидка ручная}
                Str(StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)-
                StrToReal(Lg^.Dat.MarketElement[l].Input.Skidka):CZena:CMantissa,Lg^.Dat.MarketElement[l].Input.Zena);
               End;
       Else
       End;
    End;

    Lg^.DAt.Amount:=E^.Dat.Amount;
    Lg^.Dat.Document:=E^.Dat.Document;
    Lg^.Dat.ClientKod:=E^.Dat.ClientKod;
    Lg^.Dat.SkidkaSelector:=E^.Dat.SkidkaSelector;

For i:=1 To Lg^.Dat.Amount Do
 Begin
  Artikul:=Lg^.Dat.MarketElement[i].BazKod;
  If TempBox^.List^.Count-1>=0 Then
  Begin
   Logik:=True;
   For j:=0 To TempBox^.List^.Count-1 Do
    Begin
     Find:=False;
     ws:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CName,CArtikul);
     ZenZ:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CName+1+CArtikul+1+CKol+1,CZena);
     Zen:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CName+1+CArtikul+1+CKol+1+CZena+1,CZena);
     Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
     Str(StrToReal(Zen):CZena:CMantissa,Zen);
     Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zakupka):CZena:CMantissaZ,Lg^.Dat.MarketElement[i].Input.Zakupka);
     Str(StrToReal(Zen):CZena:CMantissaZ,ZenZ);

     If (ws=Lg^.Dat.MarketElement[i].BazKod) And (Zen=Lg^.Dat.MarketElement[i].Input.Zena) Then
      Begin
       Logik:=False;
       ws:=Copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CName,CKol);
           Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);

       Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
       s:=GetIdField(FName,Artikul);
       Format(s,CName);

       ws1:=copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CName,CKol);
       Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)+StrToInt(ws1):CKol,Lg^.Dat.MarketElement[i].Input.Kol);

       ws1:=copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CName+CKol+1+CZena+1,CZena);
       Str(StrToReal(ws1):CZena:CMantissa,ws);

       ws2:=copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CName+CKol+1,CZena);
       Str(StrToReal(ws2):CZena:CMantissaZ,ws2);

       s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+ws2+'│'+ws;
       TempBox^.List^.AtFree(j);
       TempBox^.SetRange(TempBox^.List^.Count);
       TempBox^.List^.Insert(NewStr(s));
       TempBox^.SetRange(TempBox^.List^.Count);
       Find:=True;
       Break;
      End;
    End;{For по списку продаж}

    If Logik Then{Если не найдено ни одного вхождения}
     Begin
        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,ws);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zakupka):CZena:CMantissaZ,ws2);
        s:=GetIdField(FName,Artikul);
        Format(s,CName);

        s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+ws2+'│'+ws;

        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
        {Break;}
     End;
  End{если список не пустой}
    Else
      Begin

        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena):CZena:CMantissa,ws);
        Str(StrToReal(Lg^.Dat.MarketElement[i].Input.Zakupka):CZena:CMantissaZ,ws2);
        s:=GetIdField(FName,Artikul);
        Format(s,CName);

        s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+ws2+'│'+ws;

        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
      End;
 End;{For i:=1 To E^.Dat.Amount Do}
 Dispose(lg,Done);
End;




Procedure CalcBuch;
Var f : MarketFileType;
    R : TRect;
    E : PSuperMarketType;
    l : Word;
    Date : TDAteString;
    NDS,z,AllSkidka,AllItogo,AllItogoZ,ItogoSkidka,Itogo : Real;
    s : TMyString;
    ws,ws1,ws2, ws3 : string[CName];
    txt1 : Text;
    k,i,j  : Word;
    Vid : Word;
    RAbday,Start,Stop,Den : LongInt;
    Space : string[10];
    mm3 : Maska3;
    mm9 : Maska9;
Begin
 Space:=' ';
 {Date:=FDate;}
 {If Not(DateDialog(Date)) Then Exit;}
 If Not(PeriodProd) Then Exit;

 Start:=DateStringToDate(DateMask,StartDate);
 Stop:=DateStringToDate(DateMask,StopDate);

 If Not(SelectOperationAndDocument(mm3,mm9)) Then Exit;


 {
 Vid:=0;

 Vid:=SelectImport(1);
 If Vid=2 Then Exit;
 }

 Assign(Txt1,Path.ToTemp+'calcbuch.txt');
 l:=IOResult;
 Rewrite(Txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл'+Path.ToTemp+'calcbuch.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Close(Txt1);

R.Assign(0, 0, 0, 0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

AllItogo:=0;
AllItogoZ:=0;
AllSkidka:=0;
RabDAy:=0;

For Den:=Start To Stop Do
Begin
{ If DayOfWeek(Den)<>Sunday Then}
 Begin
 Date:=DateToDateString(DateMask,DEn);

 Assign(F,Path.ToMarket+Date+'.mrk');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);
  End;
If l=0 Then
Begin
 Inc(RabDay);
DInfo('Считаю продажи за '+Date+'...');

 New(E,Init);

While Not (Eof(f)) Do
Begin
     ReadMArket(f,E);

  If (E^.Dat.Active) Then
   If mm3[E^.Dat.OperatorSelector+1]=1 Then
   If mm9[E^.Dat.DocSelector+1]=1 Then

  If ((Not(E^.Dat.Realiz)) Or ((E^.Dat.Realiz)And
  (E^.Dat.DocSelector in [5,6,7,8])))Then
   Begin
    AddMarketToMarketListWithZena(E);
   End;

End;{While}
 Close(f);

 Dispose(E,Done);
 NoInfo;
 End;{l=0}
 End;{Если не воскресенье}
End;{For Den}

 DInfoMsg('Формирую отчет...');
 {записать список в файл и вывести на экран}
 Append(txt1);
Writeln(txt1,Space+'Склад: '+FormKod(Rek.Kod)++'  Оператор: '+CurrentPassword);

Writeln(txt1,Space+'   СПРАВКА О ПРОДАЖАХ ЗА период с '+StartDAte+' по '+StopDate);

Writeln(txt1,Space,RabDay:3,' рабочих дней');

Writeln(txt1,Space+'-----------------------------------------------------------------------');
Writeln(txt1,Space+' пп Наименование товара          Код   Ко-во  З/Ц Цена  Р/Ц Цена  Сумма по З/Ц    Сумма по Р/Ц');
                   {123 12345678901234567890123456  12345  12345  12345678  12345678 123456789012345 123456789012345}
Writeln(txt1,Space+'-----------------------------------------------------------------------');
AllItogo:=0;
AllItogoZ:=0;
  If TempBox^.List^.Count-1>=0 Then
  Begin
  For i:=0 To TempBox^.List^.Count-1 Do
   Begin
    s:=TempBox^.GetText(i,TempBox^.List^.Count);
    ws:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CZena+1,CZena);
    ws3:=Copy(s,1+CName+1+CArtikul+1+CKol+1,CZena);
    ws1:=Copy(s,1+CName+1+CArtikul+1,CKol);
    Str(StrToReal(ws)*StrToInt(ws1):CIZena:CMantissa,ws2);
    Str(StrToReal(ws3)*StrToInt(ws1):CIZena:CMantissa,ws3);
    AllItogo:=AllItogo+StrToReal(ws)*StrToInt(ws1);
    AllItogoZ:=AllItogoZ+StrToReal(ws3);
    ws1:=Copy(s,1+CName+1,CArtikul);
     {
     ws:=Copy(s,1+1,CArtikul);
     ws:=GetIdField(FName,ws);
     Format(ws,CName);
     s:=ws+''+s;}
   While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert('  ',s,k);
    End;
    Str(i+1:CLitrMantissa,ws);
    s:=ws+' '+s;
    Writeln(txt1,Space+s+' '+ws3+' '+ws2);

          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
		Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt1,Space+' '+'  '+' '+ws2);
           {Format(ws2,CName);}
          End;


   End;
  End;
Writeln(txt1,Space+'-----------------------------------------------------------------------');
Writeln(txt1,Space,'                                            Всего: ЗЦ ',RecognizReal(AllItogoZ,CIZena,CMantissa),
' РЦ ',RecognizReal(AllItogo,CIZena,CMantissa));
{Writeln(txt1,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');}
Writeln(txt1,Space+'=======================================================================');
 Close(txt1);

 Dispose(TempBox,Done);
NoInfoMsg;
ViewAsText(Path.ToTemp+'calcbuch.txt',True);
Report(Path.ToTemp+'calcbuch.txt','',1,False,False,false);
End;{CalcTch}


{$IFDEF DPMI}
Procedure AddToReportRewisia(As:DocumentEdit;Space:AllStr;Var Txt:Text);
Var MMM : MaskaNew;
    f : RewisiaFileType;
    E : PRewisiaType;
	 ws,ws1 : String;
	 Prom,Fas,P : String[CPack];
	 LocItogoPlus,LocItogoMinus : Real;
	 St : String[CMantissa];
	 ss,ss1 : TEnjoyStr;
	 Summa : String[CIZena];
	 l : Word;
	 K : Byte;
	 Vid:Byte;
	 Doc : LongInt;
	 Minus : Boolean;
	 PrintNumer,Find : Boolean;

Begin
 {открытие файлов}
 Assign(F,Path.ToRewisia+As.D+'.rwz');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не найден файл '+Path.ToRewisia+As.D+'.rwz'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;

 Find :=False;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(RewisiaType),SizeOf(RewisiaType));
     }
     ReadRewisia(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(RewisiaType),SizeOf(RewisiaType));
     Until (DosError=0);
     }
  DelSpace(E^.Dat.Document);
  If  ClearChar(E^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;

   Close(f);

 If Not(Find) Then
 Begin
   Dispose(E,Done);
   MessageBox(#3^M+#3'Документ ревизии N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   Exit;
 End;


  Writeln(Txt,Space+'---------------------------------------------------------------------------');
  Writeln(Txt,Space+' N  Код  Наименование товара        Фас  Ко-во     Цена     Итого сумма Отд');
  Writeln(Txt,Space+'---------------------------------------------------------------------------');
                    {12 12345 12345678901234567890123456 123 123456 12345678 123456789012345  1 }

LocItogoPlus:=0;
LocItogoMinus:=0;

   Vid:=2;

   For l:=1 To E^.Dat.Amount Do
    Begin
     str(L:2,st);
     PrintNumer:=True;
     For k:=1 To CDivision Do
     Begin
       If (StrToInt(E^.DAt.element[l].Input.DivisionS[k])<>0) Then
          Begin
            DelSpace(E^.Dat.Element[l].Input.DivisionS[k]);
            Format(E^.Dat.Element[l].BazKod,CArtikul);
				{ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);}

	  If NPrint.FullName=0 Then
	  Begin
		ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);
		ws1:=GetIdField(FName2,E^.Dat.Element[l].BazKod);
		DelSpaceRight(ws1);
		If ws1[0]<>#0 Then
	  Begin
		Writeln(txt,Space+'   '+'      '+ws);
		ws:=ws1;
	  End;
     End
     Else
	 Begin
	  ws:=GetIdField(FFName,E^.Dat.Element[l].BazKod);
	  ws1:=GetIdField(FFName2,E^.Dat.Element[l].BazKod);
	  DelSpaceRight(ws1);
	  If ws1[0]<>#0 Then
	  Begin
	   Writeln(txt,Space+'   '+'      '+ws);
	   ws:=ws1;
	  End;
	 End;


				Format(ws,CName);
				DelSpace(E^.Dat.Element[l].Input.DiviSionS[k]);

				If (StrToInt(E^.Dat.Element[l].Input.DivisionS[k])<0) Then Minus:=True
				Else Minus:=False;

				Prom:=E^.Dat.Element[l].Input.DivisionS[k];
				{если <0 тогда удаляем минус впереди и считаем упаковки без минуса,
                  а затем подставляем его вновь}
            If Minus Then System.Delete(Prom,Pos('-',Prom),1);

            RFormat(E^.Dat.Element[l].Input.DivisionS[k],CKol+1);


            Fas:=GetIdField(FInPack,E^.Dat.Element[l].BazKod);
            DelSpace(Fas);
            Format(Fas,CInPack);

            DelSpace(E^.Dat.Element[l].Input.R_Zena);
            RFormat(E^.Dat.Element[l].Input.R_Zena,CZena);

            ws:=E^.Dat.Element[l].BazKod+' '+ws+' '+Fas+' '+E^.Dat.Element[l].Input.DivisionS[k]+
           +' '+E^.Dat.Element[l].Input.R_Zena;
           Str((StrToInt(E^.Dat.Element[l].Input.DiviSionS[k])*StrToReal(E^.Dat.Element[l].Input.R_Zena))
           :CIZena:CMantissa,ss);
           Str(k:2,P);
           ws:=ws+' '+ss+' '+P;

  If TestLastDiviSion(E^.Dat.Element[l].Input.DivisionS,K,MMM,Vid) Then
  Begin
     If PrintNumer Then
      Begin
      Writeln(txt,Space+st+' '+ws);
      PrintNumer:=False;
      End
     Else
      Writeln(txt,Space+'   '+ws)
  End
  Else
     Begin
      If PrintNumer Then
      Begin
		Writeln(txt,Space+st+' '+ws);
      PrintNumer:=False;
      End
      Else
      Writeln(txt,Space+'   '+ws)
     End;

            If Minus Then
                LocItogoMinus:=LocItogoMinus+StrToInt(E^.Dat.Element[l].Input.DivisionS[k])*
                         StrToReal(E^.Dat.Element[l].Input.R_Zena)
            Else
                LocItogoPlus:=LocItogoPlus+StrToInt(E^.Dat.Element[l].Input.DivisionS[k])*
                         StrToReal(E^.Dat.Element[l].Input.R_Zena);




          End;{Если сошлось отделение}
     End;{For по отделениям}
    End;{For по документу}
     Writeln(Txt,Space+'---------------------------------------------------------------------------');

     Writeln(Txt,Space+'                                    Всего наименований: ',E^.Dat.Amount:CIZena);
     Writeln(Txt,Space+'                                       приход на склад: ',RecognizReal(LocItogoPlus,CIZena,
        CMantissa),' руб');
     Writeln(Txt,Space+'                                      расход со склада: ',RecognizReal(LocItogoMinus,CIZena,
        CMantissa),' руб');
     Writeln(Txt,Space+'                                         Всего ревизия: ',RecognizReal(LocItogoPlus+
        LocItogoMinus,
        CIZena,CMantissa),' руб');
     Writeln(Txt,Space+'---------------------------------------------------------------------------');


Dispose(E,Done);
End;
{$Else}

Procedure AddToReportRewisia(As:DocumentEdit;Space:AllStr;Var Txt:Text);
Begin
End;
{$ENDIF}






End.
