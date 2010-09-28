{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit Vision10;

Interface

Uses Dialogs,ServStr,Serv,Utils,Glob,UKassa;

Procedure CalcParusTCh;
Procedure PrintRewisia(As:DocumentEditZ);
Function ViewAllRewisia(SDate:TDateString;Auto:Boolean;Default:Byte):AllStr;


Implementation


Uses App,DBEngine,DBEngin2,MsgBox,Tools,Printers,Objects,Views,TpDate,Vision4,Vision1,
     Access1,Validate,NetDBEng,Propiss,Utils4,ServStr2,
	Utils5,Prise;

VAr LocalTempBox,TempBox : PBox;
    StartDate,StopDate : TDateString;

Function TestLastDivision(M:TRewString;Position:Word;MMM:Maska8;Vid:Byte):Boolean;
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
  PInputLine(ControlStart)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));

ControlStart^.SetData(s1);

  R.Assign(3, 2, 6, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~с~:', ControlStart)));

R.Assign(20, 2, 30, 3);
ControlStop := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStop);
  PInputLine(ControlStop)^.Validator := New(PPXPictureValidator, Init({'[##-##-9#]'}DateFiltr, True));

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
(*   New(Lg,Init);
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

     If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
       MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
       (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
      End
      Else
       Begin
       MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
       ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
       End;

         Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
         MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena),CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
         RFormatZerro(Lg^.Dat.Document,CDocNumer);
         MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol),
            CIZena,CMantissa,ws);
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

     If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
       MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
       (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
      End
      Else
       Begin
       MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
       ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
       End;

        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
        MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena),CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        RFormatZerro(Lg^.Dat.Document,CDocNumer);
        MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol),CIZena,CMantissa,ws);
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
     If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
       MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
       (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
      End
      Else
       Begin
       MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
       ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
       End;

        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
        MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena),CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        RFormatZerro(Lg^.Dat.Document,CDocNumer);
        MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol),CIZena,CMantissa,ws);
         s:=GetIdField(FName,Artikul);
         Format(s,CName);

         s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+
        Lg^.Dat.MarketElement[i].Input.Zena+'│'+ws+'│'+Lg^.Dat.Document+'│'+Lg^.Dat.ClientKod;

        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
      End;
 End;{For i:=1 To E^.Dat.Amount Do}

 Dispose(lg,Done); *)
End;


(*Procedure AddMarketToMarketList(Const E:PSuperMarketType);
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
       If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
         begin
           DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
           MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
           (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
         End
       Else
         Begin
           MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
           ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
         End;
           Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
           MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena),CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
           MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol),
                 CIZena,CMantissa,ws);
           s:=GetIdField(FName,Artikul);
           Format(s,CName);

           ws1:=copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CName,CKol);
           Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)+StrToInt(ws1):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
           ws1:=copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CName+CKol+1,CIZena);
           MyStr(StrToReal(ws)+StrToReal(ws1),CIZena,CMantissa,ws);

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
      If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
        begin
          DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
          MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
          (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        End
      Else
        Begin
         MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
         ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        End;

        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
        MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena),CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol),CIZena,CMantissa,ws);
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

     If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
       MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
       (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
      End
      Else
       Begin
       MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
       ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
       End;

        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
        MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena),CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);
        RFormatZerro(Lg^.Dat.Document,CDocNumer);
        MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol),CIZena,CMantissa,ws);
        s:=GetIdField(FName,Artikul);
        Format(s,CName);

        s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+ws;

        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
      End;
 End;{For i:=1 To E^.Dat.Amount Do}

 Dispose(lg,Done);
End;  *)

Procedure AddMarketToMarketList(Const E:PSuperMarketType);
Var j,i : Word;
    l,k,pp:Byte;
    Artikul : ArtikulStr;
    Find : Boolean;
    ws1,ws,ws2 ,s,st1: TMyString;
    sZakupka: string[CZena];
    sRZena: string[CZena];
    sRSumma: string[CIZena];
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
       If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
         begin
           DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
           MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
           (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,sRZena);
         End
       Else
         Begin
           MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
           ,CZena,CMantissa,sRZena);
         End;
           Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
{$IFDEF Bakaleya}

        (*  MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zakupka{ena})+0.2,CZena,CMantissaZ,
		 Lg^.Dat.MarketElement[i].Input.Zena); *)

        If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
           MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
           (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100))
           ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena){новая цена}
         Else
          MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-
	  StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
            ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);{новая цена}

{$ELSE}
            MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zakupka{ena}),CZena,CMantissaZ,
		 sZakupka);

            If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
           MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
           (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100))
           ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena){новая цена}
         Else
          MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-
	  StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
            ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);{новая цена}


{$ENDIF}
           MyStr(StrToReal(sZakupka)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol),
		 CIZena,CMantissaZ,ws);
           s:=GetIdField(FName,Artikul);
           Format(s,CName);
           sRSumma:=copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CName+CKol+1+CIZena+1+CZena+1,CIZena);
           STR(StrToREal(sRSumma)+StrToREal(sRZena)*StrToREal(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,sRSumma);
           ws1:=copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CName,CKol);
           Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)+StrToInt(ws1):CKol,{Lg^.Dat.MarketElement[i].Input.Kol}ws2);
           ws1:=copy(TempBox^.GetText(j,TempBox^.List^.Count),1+1+CArtikul+1+CName+CKol+1,CIZena);
           MyStr(StrToReal(ws)+StrToReal(ws1),CIZena,CMantissaZ,ws);


           s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+{Lg^.Dat.MarketElement[i].Input.Kol}ws2+'│'+ws+'│'+sRZena+'│'+sRSumma;

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
      If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
        begin
          DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
          MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
          (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,sRZena);
        End
      Else
        Begin
         MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
         ,CZena,CMantissa,sRZena);
        End;

        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
{$IFDEF Bakaleya}
(* MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zakupka{ena})+0.2,CZena,CMantissaZ,Lg^.Dat.MarketElement[i].Input.Zena);*)
       If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
           MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
           (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100))
           ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena){новая цена}
         Else
          MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-
	  StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
            ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);{новая цена}
{$ELSE}
        If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
           MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
           (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100))
           ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena){новая цена}
         Else
          MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-
	  StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
            ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);{новая цена}
        MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zakupka{ena}),CZena,CMantissaZ,sZakupka);
{$ENDIF}
        MyStr(StrToReal(sZakupka)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol)
           ,CIZena,CMantissaZ,ws);
        s:=GetIdField(FName,Artikul);
        Format(s,CName);
        STR(StrToREal(sRZena)*StrToREal(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,sRSumma);
        s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+ws+'│'+sRZena+'│'+sRSumma;

        TempBox^.List^.Insert(NewStr(s));
       { writeln(s);
        readln; }
        TempBox^.SetRange(TempBox^.List^.Count);
        {Break;}
     End;
  End{если список не пустой}
    Else
      Begin

     If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
      begin
       DelSpace(Lg^.Dat.MarketElement[i].Input.Proz);
       MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
       (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100)),CZena,CMantissa,sRZena);
      End
      Else
       Begin
       MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
       ,CZena,CMantissa,sRZena);
       End;

        Str(StrToInt(Lg^.Dat.MarketElement[i].Input.Kol):CKol,Lg^.Dat.MarketElement[i].Input.Kol);
{$IFDEF Bakaleya}
(*MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zakupka{ena})+0.2,CZena,CMantissaZ,Lg^.Dat.MarketElement[i].Input.Zena);*)
        If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
           MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
           (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100))
           ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena){новая цена}
         Else
          MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-
	  StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
            ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);{новая цена}
{$ELSE}
        If Lg^.Dat.SkidkaSelector=0 Then{Если автомат}
           MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)/
           (1+StrToReal(Lg^.Dat.MarketElement[i].Input.Proz)/100))
           ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena){новая цена}
         Else
          MyStr((StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)-
	  StrToReal(Lg^.Dat.MarketElement[i].Input.Skidka))
            ,CZena,CMantissa,Lg^.Dat.MarketElement[i].Input.Zena);{новая цена}
        MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zakupka{ena}),CZena,CMantissaZ,Lg^.Dat.MarketElement[i].Input.Zena);
{$ENDIF}
        RFormatZerro(Lg^.Dat.Document,CDocNumer);
        MyStr(StrToReal(Lg^.Dat.MarketElement[i].Input.Zena)*StrToInt(Lg^.Dat.MarketElement[i].Input.Kol),CIZena
          ,CMantissaZ,ws);
        s:=GetIdField(FName,Artikul);
        Format(s,CName);
        STR(StrToREal(sRZena)*StrToREal(Lg^.Dat.MarketElement[i].Input.Kol):CIZena:CMantissa,sRSumma);
        s:=s+'│'+Lg^.Dat.MarketElement[i].BazKod+'│'+Lg^.Dat.MarketElement[i].Input.Kol+'│'+ws+'│'+sRZena+'│'+sRSumma;

        TempBox^.List^.Insert(NewStr(s));
        TempBox^.SetRange(TempBox^.List^.Count);
      End;
 End;{For i:=1 To E^.Dat.Amount Do}

 Dispose(lg,Done);
End;



Procedure CalcParusTCh;
Var f : MarketFileType;
    fv: NewVozwratFileType;
    R : TRect;
    E : PSuperMarketType;
    Er: PRealizasiaType;
    EE: PSuperMarketType;
    V : PNewVozwratType;
    l : Word;
    VBOX:PBox;
    Date : TDAteString;
    NDS,z,AllSkidka,AllItogo,AllItogoR,ItogoSkidka,Itogo : Real;
    s,s2,s3,st,st1 : TMyString;
    ws,ws1,ws2 : String;
    AllSum,AllNDS,All,AllKol : String[CAll];
    txt1 , txt2, txt3: Text;
    k,i,j,num  : Word;
    Vid : Word;
    ItogNds, SZena, SKol,CNDS,CArt,CZ,CSumma,Nalog, sNal:String[CAll];
    ItogoZ,ItogoR,SummaOutNDS:String[CAll];
    sNds20,sNDS10,sNDSPr,sNDS18,sNDS16,allNDS20,allNDS10,allNDS18,allNDS16,allNDSPr:String[CAll];
    RAbday,Start,Stop,Den : LongInt;
    Space : AllStr;
    sMera: string;
    GruzoOtpravitel,Podrazdel,GruzoPolushatel,Postawshik,
    Platelshik : string;

procedure Torg12;
var i: word;
BEGIN
    {ТОРГ-12}
Writeln(txt3,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.MinInterval2[Nprint^.DAt.Printer]);
Writeln(txt3,Space+' '+
'Унифицированная форма N ТОРГ - 12 нах');
Writeln(txt3,Space+' '+
'Утверждена постановлением Госкомстата России от 25.12.98г. N 132'+GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]);


Writeln(txt3,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+Space+
'                                                                                                      '+
'                             Код     ');
Writeln(txt3,Space+'                 ООО"Торговый Дом"Триада-Продукт",300600,г.Тула,пр.Ленина,д.108,р/с40702810300640002106  ,'
+'       '+
'Форма по ОКУД      ');


{Грузоотправитель}
GruzoOtpravitel:='';
DelSpaceRight(GruzoOtpravitel);
{ws:=GetMAkeField(FClient,Rek1^.Dat.Kod,1);
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+',Склад '+ws+',';}
ws:='Грузоотправитель: в ТФ ОАО"Банк Москвы",г.Тула,'
+'БИК 047003003714,к/с30101810100000000714';
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+ws+' ';
ws:='';
DelSpaceRight(ws);
GruzoOtpravitel:=GruzoOtpravitel+ws;
Format(GruzoOtpravitel,116);
GruzoOtpravitel:=GruzoOtpravitel+'   по ОКПО  ';
ws:='';
DelSpaceRight(ws);
format(ws,10);
GruzoOtpravitel:=GruzoOtpravitel+ws+' ';
{сформировали строку Грузоотправителя}



Writeln(txt3,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
Space+GruzoOtpravitel);

{Структурное подразделение}
Podrazdel:='';
ws:='';
DelSpaceRight(ws);
Podrazdel:=Podrazdel+ws;
ws:='';
DelSpaceRight(ws);
Podrazdel:=Podrazdel+ws;
Format(Podrazdel,75);
Podrazdel:=Podrazdel+'Вид деятельности по ОКДП             ';
Writeln(txt3,Space+'Структурное подразделение: '+Podrazdel);

{Writeln(txt,Space+Dop+'                                                                                                   '+
'ид деятельности по ОКДП │          │');}

{формируем строку Грузополучателя}
GruzoPolushatel:='ООО "Нестлайн", 129010, г.Москва, Грохольский пер.,д.8/3,стр.1';
DelSpaceRight(GruzoPolushatel);
ws:='';
DelSpaceRight(ws);
GruzoPolushatel:=GruzoPolushatel+ws;
ws:='';
DelSpaceRight(ws);
GruzoPolushatel:=GruzoPolushatel+ws;
Format(GruzoPolushatel,100);
GruzoPolushatel:=GruzoPolushatel+' '+'по ОКПО ';
ws:='';
DelSpaceRight(ws);
format(ws,10);
GruzoPolushatel:=GruzoPolushatel+' '+ws;
{сформировали строку Грузоотправителя}
Writeln(txt3,Space+' Грузополучатель: '+GruzoPolushatel);

{формируем строку поставщика}
Postawshik:='ООО"Торговый Дом"Триада-Продукт",300600,г.Тула,пр.Ленина,д.108';
DelSpaceRight(Postawshik);
 ws:='';
DelSpaceRight(ws);
Postawshik:=Postawshik+ws;
ws:='';
DelSpaceRight(ws);
Postawshik:=Postawshik+ws;
Format(Postawshik,100);
Postawshik:=Postawshik+' '+'по ОКПО ';
ws:='';
DelSpaceRight(ws);
FORMAT(WS,10);
Postawshik:=Postawshik+' '+ws+' ';
{сформировали строку поставщика}
Writeln(txt3,Space+'       Поставщик: '+Postawshik);

{формируем строку Плательщика}
Platelshik:='ООО "Нестлайн", 129010, г.Москва, Грохольский пер.,д.8/3,стр.1';
ws:='';
DelSpaceRight(ws);
Format(Platelshik,100);
Platelshik:=Platelshik+' '+'по ОКПО ';
ws:=' ';
format(ws,10);
Platelshik:=Platelshik+' '+ws+' ';
{сформировали строку Плательщика}
Writeln(txt3,Space+'      Плательщик: '+Platelshik);

Writeln(txt3,Space+'       Основание:                                                                                     '+
'                   номер             ');
Writeln(txt3,Space+'                                                                                                      '+
'                    дата             ');
Writeln(txt3,Space+'                                                                                                '+
'Транспортная накладная   номер             ');
{│Номер│  Дата  │}
Writeln(txt3,Space+'                                                   Номер документа    Дата составления                '+
'                    дата             ');
{ │докум│составл.│}
{}
Begin
Write(txt3,Header+Space+'         Т О В А Р Н А Я   Н А К Л А Д Н А Я    '+
+HeaderStop);
End;

Writeln(txt3,'                                                                Вид операции             ');


Space:=' ';

Writeln(txt3,Header+GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.MinInterval2[Nprint^.DAt.Printer]);
Writeln(txt3,Space+'┌─┬────────────────────────────────┬────────────┬─────┬───────────┬───────┬──────┬────────┬'
+'─────────────┬──────────────────┬────────────┐');
Writeln(txt3,Space+'│ │          Товар                 │Единица изм.│ Вид │Количество │ Масса │Коли- │ Цена,  │'
+'  Сумма      │      НДС         │   Сумма с  │');
Writeln(txt3,Space+'│ ├──────────────────────────┬─────┼───────┬────┤     ├─────┬─────┤       │чество│        │'
+' без учета   ├──────┬───────────┤   учетом   │');
Writeln(txt3,Space+'│N│  Наименование, характе-  │ код │наиме- │код │упак.│одном│мест,│ брутто│(масса│руб.коп.│'
+'   НДС,      │ставка│  сумма,   │    НДС,    │');
Writeln(txt3,Space+'│ │  ристики, сорт, артикул  │     │нование│ по │     │месте│штук │       │нетто)│        │'
+' руб. коп.   │  %   │  руб.коп. │  руб. коп. │');
Writeln(txt3,Space+'│ │                          │     │       │ОКЕЙ│     │     │     │       │      │        │'
+'             │      │           │            │');
Writeln(txt3,Space+'├─┼──────────────────────────┼─────┼───────┼────┼─────┼─────┼─────┼───────┼──────┼────────┼'
+'─────────────┼──────┼───────────┼────────────┤');
Writeln(txt3,Space+'│1│              2           │ 3   │    4  │  5 │  6  │  7  │  8  │   9   │  10  │   11   │'
+'     12      │  13  │    14     │     15     │');
Writeln(txt3,Space+'└─┴──────────────────────────┴─────┴───────┴────┴─────┴─────┴─────┴───────┴──────┴────────┴'
+'─────────────┴──────┴───────────┴────────────┘'+{MinInterval[Nprint^.DAt.Printer]+}
GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]+HeaderStop);


 AllKOl:='0';


AllItogo:=0;
AllItogo:=0;
AllSum[0]:=#0;
AllNDS[0]:=#0;
All[0]:=#0;

  If TempBox^.List^.Count-1>=0 Then
  Begin

  For i:=0 To TempBox^.List^.Count-1 Do
   Begin
    s:=TempBox^.GetText(i,TempBox^.List^.Count);
    ws:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CIzena+1+CZena+1,CIZena);
    AllItogo:=AllItogo+StrToReal(ws);
   End;

  For i:=0 To TempBox^.List^.Count-1 Do
   Begin

    s:=TempBox^.GetText(i,TempBox^.List^.Count);
    {memc(s);}
    SKol:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1,CKol);
    AllKol:=IntToStr(StrToInt(AllKol)+StrToInt(sKol),CKol);
    CArt:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1,CArtikul);
    (* ЗЦ !!!!!!!!!!!!!!
    CSumma:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1+CKol+1,CIZena);*)

    CSumma:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1+CKol+1+CIZena+1+Czena+1,CIZena);

  (*  s2:=GetNGTDField(FNGTD,BakGetField(FNGTD,CArt,0));
    s3:=GetPostField(FPost,BakGetField(FPost,CArt,0));
    sMera:=GetIDField(FMera,CArt);
    GetMeraField(FMera,sMera);
    DelSpaceRight(s2);
    DelSpaceRight(s3);
    Format(s2,30);
    Format(s3,CPost);  *)

    MyStr(StrToReal(CSUmma)/StrToReal(SKol),CIZena,CMantissaZ,SZena);
    {MyStr(StrToReal(CSumma)/6,10,CMantissa,CNDS);}
    Nalog:=GetIdField(FNDS,CArt);
    sNal:=Nalog;
    STr((1+StrToReal(NAlog)/100):CLitr:2,Nalog);

    MyStr(-StrToReal(SZena)/
              StrToReal(NAlog)+StrToReal(SZena),CZena,CMantissaZ,CNDS);
    {MyStr(StrToREal(SZena)-StrToReal(CNDS),CZena,CMantissa,CNDS);}
    NDS:=StrToReal(CNDS);  {НДС с цены}


    {Цена  НДС}
    SKol:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1,CKol);
    MyStr((StrToReal(CSumma)-StrToReal(CNDS)*StrToReal(SKol))/StrToReal(SKol),CIZena,CMantissaZ,CZ);

    {Сумма НДС}

    MyStr(StrToReal(CZ)*StrToReal(SKol),CIZena,CMantissa,SZena);
    MyStr(StrToReal(CNDS)*StrToReal(SKOL),CIZena,CMantissa,CNDS);

    MyStr(StrToReal(allNds)+StrToReal(CNDS),CIZena,CMantissa,allNDS);

          If NPrint^.DAt.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
          Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           ws1:=Copy(s,1,CName);
           System.Delete(s,1,CName);
           System.Insert(ws2,s,1);
           Writeln(txt3,Space+'     '+ws1);
          End;

   While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert(SeparatorChar,s,k);
    End;
    Str(i+1:CLitrMantissa+1,ws);
    System.Delete(s,45,CZena+1+CIZena);
    s:=ws+' '+s;

    rformat(CZ,CZena);
    rformat(SZena,13);
    rformat(CNDS,10);
    Mystr(StrToReal(SNal),6,2,sNAl);
    System.Delete(sNal,4,3);

    rformat(cz,CZena);
    System.Insert({ws}{SZena}cz+SZEna+'       '+sNal+' '+CNDS,s,1+cLitrMantissa+1+CName+1+CArtikul+1+CKol+1+1);
   { System.Delete(s,1+CName+1+5,CArtikul);}
  {  sMera:=GetMeraField(FMera,sMera);
    rformat(sMera,CArtikul+3);
    System.Insert(sMera+'  ',s,1+CName+1+6);}
   { MyStr(StrToReal(ws)/AllItogo*100,CKol,CMantissa,ws);}
(*    DelSpaceRight(s2);
    DelSpaceRight(s3);
    Format(s2,CNSertif-16{13 для того что бы влез акциз});
    Format(s3,CPost);
    s:=s+'          '+s3+' '+s2;*)
    System.Insert('    шт.  796                           ',
    s,38);
   System.Delete(s,106,3);
   System.Delete(s,125,1);
   System.Insert(SeparatorChar,s,125);
   System.Delete(s,113,1);
   System.Insert(SeparatorChar,s,113);
   System.Delete(s,106,1);
   System.Insert(SeparatorChar,s,106);
   System.Delete(s,92,1);
   System.Insert(SeparatorChar,s,92);
   System.Delete(s,68,1);
   System.Insert(SeparatorChar,s,68);
   System.Delete(s,62,1);
   System.Insert(SeparatorChar,s,62);
   System.Delete(s,56,1);
   System.Insert(SeparatorChar,s,56);
   System.Delete(s,50,1);
   System.Insert(SeparatorChar,s,50);
   System.Delete(s,45,1);
   System.Insert(SeparatorChar,s,45);
   System.Delete(s,38,1);
   System.Insert(SeparatorChar,s,38);
   System.Delete(s,5,1) ;
   System.Insert(SeparatorChar,s,5);
    Writeln(txt3,s);
   End;
  End;

{Заключительная часть}
Writeln(txt3,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+
Space+'──────────────────────────────────────────────────────────────────────────────────────────────────────'+
'─────────────────────────────────────────────');

Begin
    format(AllKol,Ckol+1);
    MyStr(AllItogo-StrToReal(AllNds),CIzena,CMantissa,SummaOutNDS);
    Writeln(txt3,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+'Позиций:',TempBox^.List^.Count:2,
    '                                                 ',{AllMassa,}'                ',AllKol,'      ',
    Recogniz(SummaOutNDS),' ',
    Recogniz(ws2),'   ',Recogniz(AllNDS),' ',Recogniz(RealToStr(AllItogo,CIzena,CMantissa))+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]{+
    '   Мест:'+CalcMesto(E)});



    (*  Begin
       Writeln(txt3,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+'     В т.ч. НДС:',
	  RecognizReal(Nds,CIZena,CMantissa));
       If NDS20>0.009 Then
       Writeln(txt,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
          GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+'         20%   :'+
          RecognizReal(NDS20,CIZena,CMantissa)+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

       If NDS18>0.009 Then
       Writeln(txt,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+Dop+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
          GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+'         18%   :'+
          RecognizReal(NDS18,CIZena,CMantissa)+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

       If NDS16>0.009 Then
       Writeln(txt,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+Dop+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
          GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+'         16%   :'+
          RecognizReal(NDS16,CIZena,CMantissa)+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

       If NDS10>0.009 Then
       Writeln(txt,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+Dop+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
          GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+'         10%   :'+
          RecognizReal(NDS10,CIZena,CMantissa)+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]);

       If NDS_>0.009 Then
       Writeln(txt,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+Dop+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
          GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+'         прочие:'+
          RecognizReal(NDS_,CIZena,CMantissa)+
          GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer])
      End;     *)
    {количество позиций}
    MyStr(StrToReal(IntToStr(TempBox^.List^.Count,CMAntissa)),CMantissa+1+CMAntissa,CMantissa,s);
    If TempBox^.List^.Count>0 Then
    Begin
    DelSpace(s);
    Propis(s,ws);
    l:=Pos('руб',ws);
    ws[0]:=Chr(l-2);
    ws[1]:=UpperCase(ws[1]);
    End
    Else ws:='Ноль';

    {количество мест}
  (*  ws1:='    0.00';
    Begin
    DelSpace(ws1);
    Propis(ws1,ws2);
    l:=Pos('руб',ws2);
    ws2[0]:=Chr(l-2);
    ws2[1]:=UpperCase(ws2[1]);
    End
    Else ws2:='Ноль'; *)

    {масса груза}
 (*   s:='';
    If Int(StrToReal(AllMassa))>0 Then
    Begin
    DelSpace(AllMassa);
    Propis(AllMassa,ws1);
    l:=Pos('руб',ws1);
    If l>0 Then
      Begin
       ws1[0]:=Chr(l-2);
       ws1[1]:=UpperCase(ws1[1]);
       ws1:=ws1+' килограмм';
      End;
    End
     Else ws1:='Ноль килограмм';


    l:=Pos('.',s);
    If l>0 Then
      Begin
       ws1:=ws1+' '+Copy(s,l+1,CLitrMantissa);
       ws1[1]:=UpperCase(ws1[1]);
       ws1:=ws1+' г.';
      End;         *)

    Writeln(txt3,GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]);
    Writeln(txt3,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+'         Товарная накладная имеет приложение '
    +'на ________ листах и содержит '+GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+ws+
    GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+
    ' порядковых номеров записей');

    Writeln(txt3,GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+'                       Масса груза (нетто): '+
    {GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+
    ws1+GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]}
    '____________________________________________');



    Writeln(txt3,Space+{GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+'         Итого наименований: '+GlobalPrn^.Dat.
    Pitch[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+ws+GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+}
    ' Всего мест: '+GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+ws2+
    GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+'       Масса груза (брутто): '+
    GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+
    ws1+GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.MinInterval2[Nprint^.DAt.Printer]);;

    Writeln(txt3,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+
    ' Приложение (паспорта, сертификаты) на ____________ листах             '+
    '│  По  доверенности № _________ от  "_____" __________________ г.');


    Begin
    s:=RealToStr(AllItogo,CIzena,CMantissa);
    DelSpace(s);
    Propis(s,ws);
    ws[1]:=UpperCase(ws[1]);
    ws:=ws+' '+s;
    Format(ws,71);
    Writeln(txt3,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+
    'Отпущено на сумму                                                      '+
    '│   выданной _________________________________________________');

    Writeln(txt3,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    +GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer] +ws+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
    '│');

    Writeln(txt3,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+
    '   Отпуск разрешил ___________________________________________________ '+
    '│');

    Writeln(txt3,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+
    'Главный (старший) бухгалтер __________________________________________ '+
    '│ Груз принял ________________________________________________');

    Writeln(txt3,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+
    'Отпуск груза произвел ________________________________________________ '+
    '│ Груз получил грузополучатель _______________________________');

    Writeln(txt3,GlobalPrn^.Dat.Condensed2[Nprint^.DAt.Printer]+Space+
    '       М.П.                                                            '+
    '│      М.П. '+GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]);

    End;


   Write(txt3,GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);

     Begin
      s:='';
      DelSpaceRight(s);
      If s[0]<>#0 Then
       Begin
        Writeln(txt3,Space+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
	   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+s
        +GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
	   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
	   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
       End;
     End;

   Write(txt3,Space{+' Всего: '},' '+'               '{+RecognizReal(Itogo,CIZena,CMantissa)},
    '                         '+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

   Writeln(txt3,Space+GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]+''+GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+' '+GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
   GlobalPrn^.Dat.NODouble[Nprint^.DAt.Printer]);
end;
End;

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

 Assign(Txt1,Path^.Dat.ToTemp+'calcthn.txt');
 l:=IOResult;
 Rewrite(Txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path^.Dat.ToTemp+'calcthn.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Close(Txt1);

 Assign(Txt2,Path^.Dat.ToTemp+'thnsf.txt');
 l:=IOResult;
 Rewrite(Txt2);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path^.Dat.ToTemp+'thnsf.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Close(Txt2);

 Assign(Txt3,Path^.Dat.ToTemp+'thn12.txt');
 l:=IOResult;
 Rewrite(Txt3);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path^.Dat.ToTemp+'thn12.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Close(Txt3);



R.Assign(0, 0, 0, 0);
TempBox := New(PBox, Init(R, 1, Nil));
TempBox^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0, 0, 0, 0);
VBox := New(PBox, Init(R, 1, Nil));
VBox^.NewList(New(PTextCollection, Init(0,1)));

AllItogo:=0;
AllItogoR:=0;
AllSkidka:=0;
RabDAy:=0;



For Den:=Start To Stop Do
Begin
{ If DayOfWeek(Den)<>Sunday Then}
 Begin
 Date:=DateToDateString(DateMask,DEn);

 Assign(F,Path^.Dat.ToMarket+Date+'.mrk');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);
  End;

If l=0 Then
Begin
 Inc(RabDay);
 DInfoMsg('Считаю продажи за '+Date+'...',True);

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
 If  (E^.Dat.Active)And(E^.Dat.DocSelector in[1]) And (E^.Dat.OperatorSelector=0) Then
  Begin
   {Добавление в список максимальных продаж по ТЧ}
   AddMarketToMaxList(E);
  End;{if (E^.Dat.OperatorSelector=1) And Not (E^.Dat.ClientKod='0596')And(E^.Dat.OperatorSelector=0) Then}
 End
 Else
  If (E^.Dat.Active)And(E^.Dat.OperatorSelector=0)And
  (
  ((E^.Dat.DocSelector in[1]) And Not(E^.Dat.Realiz))
  Or
  ((E^.Dat.DocSelector in [5,7]) And    (E^.Dat.Realiz))
  ) Then
  (*
  And ((Not(E^.Dat.Realiz)) Or ((E^.Dat.Realiz)And
  (E^.Dat.DocSelector in [5{,6,7,8}])))Then
  *)
   Begin
    {Добавление в список всех продаж}
    AddMarketToMarketList(E);
   End;

End;{While}
 Close(f);

 Dispose(E,Done);
 NoInfoMsg;
 End;{l=0}
 End;{Если не воскресенье}
End;{For Den}

{**********************************************************************}
{ВОЗВРАТЫ}

 ItogoZ:='0.00';
 ItogoR:='0.00';
num:=0;
For Den:=Start To Stop Do
Begin
{ If DayOfWeek(Den)<>Sunday Then}
 Begin
 Date:=DateToDateString(DateMask,DEn);

 Assign(FV,Path^.Dat.ToReturn+Date+'.vzw');
 l:=IOResult;
 Reset(fV);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToReturn+Date+'.vzw',Nil,mfError+mfCancelButton);
  End;


If l=0 Then
Begin
 Inc(RabDay);
 DInfoMsg('Считаю возвраты за '+Date+'...',True);

 New(V,Init);

While Not (Eof(fV)) Do
Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     }
     st:=''; st1:='';
        ReadNewVozwrat(fV,V);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
     }
    if V^.Dat.DocSelector in[1,2,5,7] then
     for i:=1 to v^.Dat.Amount do
      begin
        {Номер п/п}
        inc(num);
        st:=IntToStr(num,CKod);
        rformat(st,CKod);
        {Первая часть наименования}
        st1:=BakGetField(FName,V^.Dat.VozwratElement[i].BazKod,0);
        Format(st1,CName);
        st:=st+' '+st1;
        {Вторая часть наименования}
        st1:='';
        st1:=GetIdField(FName2,V^.Dat.VozwratElement[i].BazKod);
        Format(st1,CName);
        st:=st+' '+st1;
        {Кол-во}
        st1:=v^.Dat.VozwratElement[i].Input.Kol;
        rformat(st1,CKol);
        st:=st+' '+st1;
        {З/ц}
        Er:=New(PRealizasiaType,Init);
        EE:=New(PSuperMarketType,Init);
        Er^.Dat.Market.DateC:=DateStringToDate(DateMask,V^.Dat.BasisDate);
        Er^.Dat.Market.Document:=V^.Dat.BasisDoc;
       {writeln(V^.Dat.BasisDate,' ',V^.Dat.BasisDoc);
        readln; }
        GetMarket(Er,EE);
        st1:='';
        for j:=1 to EE^.Dat.Amount do
         begin
          if  EE^.Dat.MarketElement[j].BAzKod=V^.Dat.VozwratElement[i].BazKod then
           begin
            st1:=EE^.Dat.MarketElement[j].Input.Zakupka;
            break;
           end;
         end;

{$IFDEF Bakaleya}
        Mystr(StrToReal(st1)+0.2,CZena,CMantissa,st1);
{$ENDIF}
        rformat(st1,CZena);
        MyStr(StrToReal(ItogoZ)+StrToReal(st1)*
             StrToReal(v^.Dat.VozwratElement[i].Input.Kol),CIZena,CMantissa,ItogoZ);
        st:=st+' '+st1;
        rformat(st1,CIZena);
        MyStr(StrToReal(st1)*
             StrToReal(v^.Dat.VozwratElement[i].Input.Kol),CIZena,CMantissa,st1);
        st:=st+' '+st1;
        Dispose(EE,Done);
        Dispose(Er,Done);

        {Р/ц}
        If V^.Dat.DocSelector in [1,2,5,7] Then
         Begin
      Case V^.Dat.VidDocument Of
    0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(V^.Dat.VozwratElement[i].Input.Zena)/
           (1+StrToReal(V^.Dat.VozwratElement[i].Input.LocalProz)/100),CZena,CMantissa,V^.Dat.VozwratElement[i].Input.Zena);
        MyStr(StrToREal(V^.Dat.VozwratElement[i].Input.Zena){/*StrToReal(Koefficient)},CZena,CMantissa,
                         V^.Dat.VozwratElement[i].Input.Zena);

       End;

    1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(V^.Dat.VozwratElement[i].Input.Zena)-
                    StrToReal(V^.Dat.VozwratElement[i].Input.LocalSkidka),CZena,CMantissa,
                    V^.Dat.VozwratElement[i].Input.Zena);
          MyStr(StrToREal(V^.Dat.VozwratElement[i].Input.Zena){/*StrToReal(Koefficient)},CZena,CMantissa,
                        V^.Dat.VozwratElement[i].Input.Zena);
        End;
      Else;
      End;{Case}
        End{If VidDocSelector}

      Else

 Begin
Case V^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(V^.Dat.VozwratElement[i].Input.Zena)/
           (1+StrToReal(V^.Dat.VozwratElement[i].Input.LocalProz)/100),CZena,CMantissa,V^.Dat.VozwratElement[i].Input.Zena);
       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(V^.Dat.VozwratElement[i].Input.Zena)-
                    StrToReal(V^.Dat.VozwratElement[i].Input.LocalSkidka),CZena,CMantissa,
                    V^.Dat.VozwratElement[i].Input.Zena);
        End;
Else;
End;{Case}
 End;

        st1:=v^.Dat.VozwratElement[i].Input.Zena;
        {writeln(v^.Dat.VozwratElement[i].Input.R_Zena);
        readln;}
        rformat(st1,CZena);
        st:=st+' '+st1;
        rformat(st1,CIZena);
        MyStr(StrToReal(v^.Dat.VozwratElement[i].Input.Zena)*
             StrToReal(v^.Dat.VozwratElement[i].Input.Kol),CIZena,CMantissa,st1);
        st:=st+' '+st1;
        MyStr(StrToReal(ItogoR)+StrToReal(v^.Dat.VozwratElement[i].Input.Zena)*
             StrToReal(v^.Dat.VozwratElement[i].Input.Kol),CIZena,CMantissa,ItogoR);
        VBox^.List^.Insert(NewStr(st));
      end;

(* If Vid=1 Then
 Begin
 If  (E^.Dat.Active)And(E^.Dat.DocSelector in[1]) And (E^.Dat.OperatorSelector=0) Then
  Begin
   {Добавление в список максимальных продаж по ТЧ}
   AddMarketToMaxList(E);
  End;{if (E^.Dat.OperatorSelector=1) And Not (E^.Dat.ClientKod='0596')And(E^.Dat.OperatorSelector=0) Then}
 End

 Else
  If (E^.Dat.Active)And(E^.Dat.OperatorSelector=0)And
  (
  ((E^.Dat.DocSelector=1) And Not(E^.Dat.Realiz))
  Or
  ((E^.Dat.DocSelector in [5,7]) And    (E^.Dat.Realiz))
  ) Then
  {
  And ((Not(E^.Dat.Realiz)) Or ((E^.Dat.Realiz)And
  (E^.Dat.DocSelector in [5{,6,7,8}])))Then
  }
   Begin
    {Добавление в список всех продаж}
    AddMarketToMarketList(E);
   End; *)

End;{While}

 Close(fV);

 Dispose(V,Done);
 NoInfoMsg;
 End;{l=0}
 End;{Если не воскресенье}
End;{For Den}

{memc('1');}
 DInfo('Формирую отчет...');
 {записать список в файл и вывести на экран}
 l:=IOResult;
 Append(txt1);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу открыть файл отчета'+Path^.Dat.ToTemp+'calcthn.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

  Append(txt2);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу открыть файл отчета'+Path^.Dat.ToTemp+'thnsf.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

  Append(txt3);
 l:=IOResult;
 If L <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не могу открыть файл отчета'+Path^.Dat.ToTemp+'thn12.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
 {++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{ВОЗВРАТЫ}
 st:=''; st1:= '';
Space:=' ';
Writeln(txt1,Space+'Склад: '+FormKod(Rek^.Dat.Kod)+'  Оператор: '+CurrentPassword);
Writeln(txt1,Space+'Тип документа: 1');
{Writeln(txt1,Space,RabDay:3,' рабочих дней');}

Writeln(txt1,Space+'           Н А К Л А Д Н А Я    N _____ от '+StartDAte+' ('+Times+')');
{$IFNDEF Bakaleya}
Writeln(txt1,Space+'Поставщик:  Розница');
Writeln(txt1,Space+'Получатель: Склад');
{$ELSE}
Writeln(txt1,Space+'Поставщик:  ООО ТД "Триада-продукт"');
Writeln(txt1,Space+'Получатель: ');
{$ENDIF}
Writeln(txt1,Space+'----------------------------------------------------------------------------------------');
Writeln(txt1,Space+' пп    Наименование товара     Ко-во       З/Ц       Сумма З/Ц     Р/Ц        Сумма Р/Ц');
                   {123 12345678901234567890123456 12345  12345678 123456789012345 12345678 123456789012345}
Writeln(txt1,Space+'----------------------------------------------------------------------------------------');

 If VBox^.List^.Count-1>=0 Then
  Begin
  For i:=0 To VBox^.List^.Count-1 Do
   Begin
     st:=VBox^.GetText(i,VBox^.List^.Count);
     st1:=copy(st,Ckod+1+Cname+1,CName);
     delspace(st1);
     System.Delete(st,Ckod+1+Cname+1,CName);
     Writeln(txt1,space+st);
     if st1<>'' then Writeln(txt1,space+'    '+st1);
   end;
  end;
 Writeln(txt1,Space+'--------------------------------------------------------');
 Writeln(txt1,Space+'   Итого:   З/Ц:'+ ItogoZ,'     Р/Ц:',ItogoR);
 Writeln(txt1);
 Writeln(txt1,Space,'       Сдал: ___________          Принял:___________');

 Writeln(txt1,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt1,Space+'========================================================',
 GlobalPrn^.Dat.EndPage[NPrint^.DAt.Printer]);

 {++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

If Vid=1 Then
Begin
Writeln(txt1,Space+'Склад: '+FormKod(Rek^.Dat.Kod)++'  Оператор: '+CurrentPassword);

Writeln(txt1,Space+'   С П Р А В К А  О  РОЗНИЧНЫХ  ПРОДАЖАХ  ЗА  период с '+StartDAte+' по '+StopDate);

Writeln(txt1,Space,RabDay:3,' рабочих дней');

Writeln(txt1,Space+'-------------------------------------------------------------------------------------');
Writeln(txt1,Space+'  пп Наименование товара          Код   Ко-во  Р/Ц Цена     Сумма по З/Ц   N    Кл-нт');
                   {123 12345678901234567890123456  12345  12345  12345678  123456789012345  1234  12345678901234567890}
Writeln(txt1,Space+'-------------------------------------------------------------------------------------');
AllItogo:=0;
  If TempBox^.List^.Count-1>=0 Then
  Begin
  For i:=0 To TempBox^.List^.Count-1 Do
   Begin
    s:=TempBox^.GetText(i,TempBox^.List^.Count);

          ws1:=Copy(s,1+CName+1,CArtikul);
          If NPrint^.DAt.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
          Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           ws1:=Copy(s,1,CName);
           System.Delete(s,1,CName);
           System.Insert(ws2,s,1);
           Writeln(txt1,Space+'     '+ws1);
           {Format(ws2,CName);}
          End;


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
    Str(i+1:CLitrMantissa+1,ws);
    s:=ws+' '+s;
    Writeln(txt1,Space+s);
   End;
  End;
Writeln(txt1,Space+'-------------------------------------------------------------------------------------');
Writeln(txt1,Space,'                                                  Всего:',RecognizReal(AllItogo,CIZena,CMantissa));
Writeln(txt1,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt1,Space+'=====================================================================================');
 Close(txt1);
End
Else
 Begin

Space:=' ';
Writeln(txt1,Space+'Склад: '+FormKod(Rek^.Dat.Kod)+'  Оператор: '+CurrentPassword);
Writeln(txt1,Space+'Тип документа: 2');
{Writeln(txt1,Space,RabDay:3,' рабочих дней');}

Writeln(txt1,Space+'           Н А К Л А Д Н А Я  N _____ от '+StartDAte+' ('+Times+')');
{$IFNDEF Bakaleya}
Writeln(txt1,Space+'Поставщик:  Склад');
Writeln(txt1,Space+'Получатель: Розница');
{$ELSE}
Writeln(txt1,Space+'Поставщик:  ООО ТД "Триада-продукт');
Writeln(txt1,Space+'Получатель: "');
{$ENDIF}
{Writeln(txt1,Space+'   С П Р А В К А   О   ПРОДАЖАХ  ЗА  период с '+StartDAte+' по '+StopDate);}
Writeln(txt1,Space+'---------------------------------------------------------------------------------------------');
Writeln(txt1,Space+'  пп Наименование товара          Код   Ко-во З/Цена       Сумма ЗЦ     Р/Цена       Сумма РЦ');
                   {123 12345678901234567890123456  12345  12345  12345678 123456789012345}
Writeln(txt1,Space+'---------------------------------------------------------------------------------------------');
AllItogo:=0;
AllItogoR:=0;
AllSum[0]:=#0;
AllNDS[0]:=#0;
All[0]:=#0;
AllNds[0]:=#0;

  If TempBox^.List^.Count-1>=0 Then
  Begin

  For i:=0 To TempBox^.List^.Count-1 Do
   Begin
    s:=TempBox^.GetText(i,TempBox^.List^.Count);
    ws:=Copy(s,1+CName+1+CArtikul+1+CKol+1,CIZena);
    CArt:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1,CArtikul);
    CSumma:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1+CKol+1,CIZena);
    SKol:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1,CKol);
    MyStr(StrToReal(CSUmma)/StrToReal(SKol),CIZena,CMantissa,SZena);
    Nalog:=GetIdField(FNDS,CArt);
    STr((1+StrToReal(NAlog)/100):CLitr:2,Nalog);
    MyStr(-StrToReal(SZena)/
              StrToReal(NAlog)+StrToReal(SZena),CZena,CMantissa,CNDS);
    NDS:=StrToReal(CNDS);
    MyStr((StrToReal(CSumma)-StrToReal(CNDS)*StrToReal(SKol))/StrToReal(SKol),CIZena,CMantissa,CZ);
    MyStr(StrToReal(CZ)*StrToReal(SKol),CIZena,CMantissa,SZena);
    MyStr(StrToReal(CNDS)*StrToReal(SKOL),CIZena,CMantissa,CNDS);
    MyStr(StrToReal(allNds)+StrToReal(CNDS),CIZena,CMantissa,allNDS);
    AllItogo:=AllItogo+StrToReal(ws);

    ws:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CIZena+1+CZena+1,CIZena);
    AllItogoR:=AllItogoR+StrToReal(ws);
   End;

  For i:=0 To TempBox^.List^.Count-1 Do
   Begin
    s:=TempBox^.GetText(i,TempBox^.List^.Count);

          ws1:=Copy(s,1+CName+1,CArtikul);
          If NPrint^.DAt.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
          Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           ws1:=Copy(s,1,CName);
           System.Delete(s,1,CName);
           System.Insert(ws2,s,1);
           Writeln(txt1,Space+'     '+ws1);
           {Format(ws2,CName);}
          End;

     {
     ws:=Copy(s,1+1,CArtikul);
     ws:=GetIdField(FName,ws);
     Format(ws,CName);
     s:=ws+''+s;}
   While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert(' ',s,k);
    End;
    Str(i+1:CLitrMantissa+1,ws);
    s:=ws+' '+s;

    ws:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1+CKol+1,CIZena);
    ws2:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1,CKol);
    MyStr(StrToReal(ws)/StrToInt(ws2),CZena,CMantissa,ws);
    System.Insert(ws+' ',s,1+cLitrMantissa+1+CName+1+CArtikul+1+CKol+1);
{
    MyStr(StrToReal(ws)/AllItogo*100,CKol,CMantissa,ws);}
    Writeln(txt1,Space+s{+'  '+ws});
   End;
  End;
Writeln(txt1,Space+'----------------------------------------------------------------------------------------------');
Writeln(txt1,Space,'                                 Всего З/Ц:',RecognizReal(AllItogo,CIZena,CMantissa),'     Р/Ц: ',
      RecognizReal(AllItogoR,CIZena,CMantissa));
Writeln(txt1,Space,'                                       НДС:',RecognizReal(StrToREal(AllNds),CIZena,CMantissa));
Writeln(txt1);
Writeln(txt1,Space,'         Сдал: ___________                    Принял:___________');

Writeln(txt1,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt1,Space+'==============================================================================================',
GlobalPrn^.Dat.EndPage[NPrint^.DAt.Printer]);


Writeln(txt1,GlobalPrn^.Dat.Condensed[NPrint^.DAt.Printer]);
Space:='  ';
Writeln(txt1,Space+'                                                                  '+
'                                  Приложение N 1');
Writeln(txt1,Space+'                                                                  '+
'                       к порядку ведения журналов счетов-фактур');
Writeln(txt1,Space+'                                                                  '+
'                    при расчетах по налогу на добавленную стоимость');
Writeln(txt1,Space);

Writeln(txt1,Space+'Поставщик:  "Триада-продукт"');
Writeln(txt1,Space{+'Адрес: г. Рязань, ул. Новоселов, 15, к. 110'});
Writeln(txt1,Space{+'ИНН:6230035697'});
Writeln(txt1);
Writeln(txt1,Space+'Получатель: ');
Writeln(txt1,Space{+'Адрес: г. Тула, пр. Ленина, 108'});
Writeln(txt1,Space{+'ИНН:7104027031'});

Writeln(txt1,Space);
Writeln(txt1,Space+'       С Ч Е Т - Ф А К Т У Р А    N _____ от '+StartDAte+' ('+Times+')');

(*Writeln(txt1,Space+'-----------------------------------------------------------------------'+
'---------------------------------------------------------------------');
Writeln(txt1,Space
+' пп  Наименование товара        Код     Производство N Грузовой таможен.деклар.     Ко-во   Цена   '+
'     Сумма НДС  Сумма НДС   Итого сумма');
  {123 12345678901234567890123456 12345 123456789012345 123456789012345678901234567890 12345 12345678
 1234567890 123 1234567890 123456789012345}
Writeln(txt1,Space
+'-------------------------------------------------------------------------'+
'-------------------------------------------------------------------');*)

Writeln(txt1,GlobalPrn^.Dat.Condensed[NPrint^.DAt.Printer]+
GlobalPrn^.Dat.MinInterval2[NPrint^.DAt.Printer]+
            Space+'┌─────────────────────────────┬────────┬───────┬───────┬────────────┬─────┬───┬────────────┬─────────────'+
                  '┬───────┬──────────────┬──────────────────────┐');
Writeln(txt1,Space+'│N Наименование товара        │Единица │ Колич.│   Цена│      Сумма │В т.ч│НДС│   Сумма НДС│  Итого сумма'+
'│  Всего│ Производство │N Грузовой таможенной │');
Writeln(txt1,Space+'│                             │измерен.│       │       │            │Акц- │ % │            │    с НДС    '+
'│    НП │              │     декларации       │');
Writeln(txt1,Space+'│                             │        │       │       │            │из   │   │            │             '+
'│       │              │                      │');
Writeln(txt1,Space+'└─────────────────────────────┴────────┴───────┴───────┴────────────┴─────┴───┴────────────┴─────────────'+
'┴───────┴──────────────┴──────────────────────┘'+
GlobalPrn^.Dat.Normal[NPrint^.DAt.Printer]+
GlobalPrn^.Dat.Condensed[NPrint^.DAt.Printer]);


AllItogo:=0;
AllItogo:=0;
AllSum[0]:=#0;
AllNDS[0]:=#0;
All[0]:=#0;
sNDS10:='0.0';
sNDS20:='0.0';
sNDS18:='0.0';
sNDS16:='0.0';
sNDSPr:='0.0';
allNDS10:='0.0';
allNDS18:='0.0';
allNDS16:='0.0';
allNDS20:='0.0';
allNDSPr:='0.0';

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
    {memc(s);}
    SKol:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1,CKol);
    CArt:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1,CArtikul);
    (* ЗЦ !!!!!!!!!!!!!!
    CSumma:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1+CKol+1,CIZena);*)

    CSumma:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1+CKol+1+CIZena+1+Czena+1,CIZena);
    {memc(CSumma);}
    {SZena:=Copy(s,1+CName+1+CArtikul+1+CKol+1,CIZena);}

    s2:=GetNGTDField(FNGTD,BakGetField(FNGTD,CArt,0));
    s3:=GetPostField(FPost,BakGetField(FPost,CArt,0));
    sMera:=GetIDField(FMera,CArt);
    DelSpaceRight(s2);
    DelSpaceRight(s3);
    Format(s2,30);
    Format(s3,CPost);

    MyStr(StrToReal(CSUmma)/StrToReal(SKol),CIZena,CMantissa,SZena);
    {MyStr(StrToReal(CSumma)/6,10,CMantissa,CNDS);}
    Nalog:=GetIdField(FNDS,CArt);
    sNal:=Nalog;
    STr((1+StrToReal(NAlog)/100):CLitr:2,Nalog);

    MyStr(-StrToReal(SZena)/
              StrToReal(NAlog)+StrToReal(SZena),CZena,CMantissa,CNDS);
    {MyStr(StrToREal(SZena)-StrToReal(CNDS),CZena,CMantissa,CNDS);}
    NDS:=StrToReal(CNDS);  {НДС с цены}

    {readln;}

    {Цена  НДС}
    SKol:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1,CKol);
    MyStr((StrToReal(CSumma)-StrToReal(CNDS)*StrToReal(SKol))/StrToReal(SKol),CIZena,CMantissa,CZ);

    {Сумма НДС}
    {MyStr(StrToReal(CSumma)-StrToReal(SZena)*StrToReal(SKol),CIZena,Cmantissa,CZ);}


    MyStr(StrToReal(CZ)*StrToReal(SKol),CIZena,CMantissa,SZena);
    MyStr(StrToReal(CNDS)*StrToReal(SKOL),CIZena,CMantissa,CNDS);

    case StrToInt(GetIdField(FVidNDS,CArt)) of
       0: begin      {20%}
           MyStr(StrToReal(sNds20)+StrToReal(CNDS),CIZena,CMantissa,sNDS20);
           MyStr(StrToReal(allNds20)+StrToReal(sZena)+StrToReal(CNDS),CIZena,CMantissa,allNDS20);
          end;
       1: begin      {10%}
           MyStr(StrToReal(sNds10)+StrToReal(CNDS),CIZena,CMantissa,sNDS10);
           MyStr(StrToReal(allNds10)+StrToReal(sZena)+StrToReal(CNDS),CIZena,CMantissa,allNDS10);
          end;
       2: begin      {прочее}
           MyStr(StrToReal(sNdsPr)+StrToReal(CNDS),CIZena,CMantissa,sNDSPr);
           MyStr(StrToReal(allNdsPr)+StrToReal(sZena)+StrToReal(CNDS),CIZena,CMantissa,allNDSPr);
          end;
       3: begin      {прочее}
           MyStr(StrToReal(sNds18)+StrToReal(CNDS),CIZena,CMantissa,sNDS18);
           MyStr(StrToReal(allNds18)+StrToReal(sZena)+StrToReal(CNDS),CIZena,CMantissa,allNDS18);
          end;
       4: begin      {прочее}
           MyStr(StrToReal(sNds16)+StrToReal(CNDS),CIZena,CMantissa,sNDS16);
           MyStr(StrToReal(allNds16)+StrToReal(sZena)+StrToReal(CNDS),CIZena,CMantissa,allNDS16);
          end;
      end; {case}

    MyStr(StrToReal(allNds)+StrToReal(CNDS),CIZena,CMantissa,allNDS);

          If NPrint^.DAt.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
          Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           ws1:=Copy(s,1,CName);
           System.Delete(s,1,CName);
           System.Insert(ws2,s,1);
           Writeln(txt1,Space+'     '+ws1);
           {Format(ws2,CName);}
          End;

     {
     ws:=Copy(s,1+1,CArtikul);
     ws:=GetIdField(FName,ws);
     Format(ws,CName);
     s:=ws+''+s;}
   While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert(' ',s,k);
    End;
    Str(i+1:CLitrMantissa+1,ws);
    System.Delete(s,45,CZena+1+CIZena);
    {s:=s+'!';}
    s:=ws+' '+s;

    rformat(CZ,CZena);
    rformat(SZena,13);
    rformat(CNDS,10);
    Mystr(StrToReal(SNal),6,2,sNAl);
    System.Delete(sNal,4,3);

   { ws:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1+CKol+1,CIZena);
    ws2:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1,CKol);
    MyStr(StrToReal(ws)/StrToInt(ws2),CZena,CMantissa,ws);}
  {  System.Insert(s3+s2,s,1+cLitrMantissa+1+CName+1+CArtikul+1);}
    rformat(cz,CZena);
    System.Insert({ws}{SZena}cz+SZEna+'       '+sNal+' '+CNDS,s,1+cLitrMantissa+1+CName+1+CArtikul+1+CKol+1+1);
    System.Delete(s,1+CName+1+5,CArtikul);
    rformat(sMera,CArtikul+3);
    System.Insert(sMera+'  ',s,1+CName+1+6);
   { MyStr(StrToReal(ws)/AllItogo*100,CKol,CMantissa,ws);}
    DelSpaceRight(s2);
    DelSpaceRight(s3);
    Format(s2,CNSertif-16{13 для того что бы влез акциз});
    Format(s3,CPost);
    s:=s+'     0.00 '+s3+' '+s2;
    Writeln(txt1,{Space}+s{+'  '+ws});
   End;
  End;
Writeln(txt1,Space
+'-------------------------------------------------------------------------'+
'-------------------------------------------------------------------------------');
Writeln(txt1,Space,'                                                 Всего:',RecognizReal(AllItogo,CIZena,CMantissa));
Writeln(txt1,Space,'                                                   НДС:',RecognizReal(StrToREal(AllNds),CIZena,CMantissa));
Writeln(txt1,Space,'                                    В том числе НДС 20:'
     ,RecognizReal(StrToREal(sNds20),CIZena,CMantissa){,' ',RecognizReal(StrToREal(AllNds20),CIZena,CMantissa)});
Writeln(txt1,Space,'                                                НДС 18:'
     ,RecognizReal(StrToREal(sNds18),CIZena,CMantissa){,' ',RecognizReal(StrToREal(AllNds18),CIZena,CMantissa)});
Writeln(txt1,Space,'                                                НДС 16:'
     ,RecognizReal(StrToREal(sNds16),CIZena,CMantissa){,' ',RecognizReal(StrToREal(AllNds16),CIZena,CMantissa)});
Writeln(txt1,Space,'                                                НДС 10:'
     ,RecognizReal(StrToREal(sNds10),CIZena,CMantissa){,' ',RecognizReal(StrToREal(AllNds10),CIZena,CMantissa)});
Writeln(txt1,Space,'                                            НДС Прочее:'
     ,RecognizReal(StrToREal(sNdsPr),CIZena,CMantissa){,' ',RecognizReal(StrToREal(AllNdsPr),CIZena,CMantissa)});

Writeln(txt1);
Writeln(txt1,Space,'Руководитель предприятия ______________                  Главный бухгалтер _______________');
Writeln(txt1);
Writeln(txt1,Space,'         Сдал: ___________      М.П.                       М.П.    Принял:___________');

Writeln(txt1,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(txt1,Space,'20% - ',RecognizReal(StrToREal(AllNds20),CIZena,CMantissa));
Writeln(txt1,Space,'18% - ',RecognizReal(StrToREal(AllNds18),CIZena,CMantissa));
Writeln(txt1,Space,'16% - ',RecognizReal(StrToREal(AllNds16),CIZena,CMantissa));
Writeln(txt1,Space
+'========================================================================='+
'============================================================================='+
GlobalPrn^.Dat.EndPage[NPrint^.DAt.Printer]);

{Новая СФ}
Writeln(txt2);
Writeln(txt2,Space+'СЧЕТ-ФАКТУРА N _____________ от ______ _____________ 20____ г.');
Writeln(txt2);
Writeln(txt2,
GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]);
Writeln(txt2,Space+'Продавец: ООО "Торговый дом "Триада-Продукт" ');
Writeln(txt2,Space+'Адрес: 300600, г.Тула, пр.Ленина, д.108');
Writeln(txt2,Space+'ИНН/КПП продавца 7104027031/710401001');
Writeln(txt2,Space+'Грузоотправитель и его адрес: ООО "Торговый дом "Триада-Продукт", 300600, г.Тула, пр.Ленина, д.108');
Writeln(txt2,Space+'Грузополучатель и его адрес: ООО "Нестлайн", 129010, г.Москва, Грохольский пер., д. 8.3, стр.1');
Writeln(txt2,Space+'К платежно-расчетному документу N ______ от _________________');
Writeln(txt2,Space+'Покупатель: ООО "Нестлайн"');
Writeln(txt2,Space+'Адрес: 129010, г.Москва, Грохольский пер., д. 8.3, стр.1');
Writeln(txt2,Space+'ИНН/КПП покупателя: 7702545569/770201001');


Writeln(txt2,
GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.MinInterval2[Nprint^.DAt.Printer]+
            Space+
(*'┌─────────────────────────────┬────────┬───────┬───────┬────────────┬────────┬───┬────────────┬─────────────'+
'┬──────────────┬──────────────────────┐');
 Writeln(txt2,
Space+'│N Наименование товара,       │Единица │ Колич.│ Цена  │Стоим.товар.│        │НДС│            │Стоим.товаров'+
'│              │                    │');
Writeln(txt2,
Space+'│                             │измерен.│       │тарифа │имущ.прав   │ В т.ч. │   │ Сумма      │имущ.прав c  '+
'│    Страна    │  Номер таможенной  │');
Writeln(txt2,
Space+'│имуществееных прав           │        │       │за един│без налогов │ акциз  │ % │ налога     │учетом налога'+
'│происхождения │     декларации       │');
Writeln(txt2,
Space+'└─────────────────────────────┴────────┴───────┴───────┴────────────┴────────┴───┴────────────┴─────────────'+
'┴──────────────┴──────────────────────┘'+ *)
 '┌─────────────────────────────┬────────┬───────┬───────┬────────────┬────────┬───┬────────────┬─────────────┬─────────────'
 +'─┬──────────────────────┐');
 Writeln(txt2,
Space+'│N Наименование товара(описа- │Единица │ Коли- │ Цена  │Стоим.товар.│        │Нал│            │Стоим.товаров│         '
+'     │                      │');
  Writeln(txt2,
Space+'│ние выполненных работ,оказан-│измерен.│ чество│(тариф)│(работ,услуг│ В т.ч. │ого│ Сумма      │(работ,услуг)│    Страна'
+'    │  Номер таможенной    │');
 Writeln(txt2,
Space+'│ных услуг), имущественного   │        │       │за един│имущ.прав,  │        │вая│            │имуш. прав,  │          '
+'    │                      │');
  Writeln(txt2,
Space+'│права                        │        │       │измерен│всего без   │ акциз  │ста│ налога     │всего с учето│происхож'
+'дения │     декларации       │');
  Writeln(txt2,
Space+'│                             │        │       │       │налога      │        │вка│            │м налога     │        '
+'      │                      │');
  Writeln(txt2,
Space+'└─────────────────────────────┴────────┴───────┴───────┴────────────┴────────┴───┴────────────┴─────────────┴─────────'
+'─────┴──────────────────────┘'+
GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+HeaderStop);
AllItogo:=0;
AllItogo:=0;
AllSum[0]:=#0;
AllNDS[0]:=#0;
All[0]:=#0;
sNDS10:='0.0';
sNDS20:='0.0';
sNDS18:='0.0';
sNDS16:='0.0';
sNDSPr:='0.0';
allNDS10:='0.0';
allNDS18:='0.0';
allNDS16:='0.0';
allNDS20:='0.0';
allNDSPr:='0.0';

  If TempBox^.List^.Count-1>=0 Then
  Begin

  For i:=0 To TempBox^.List^.Count-1 Do
   Begin
    s:=TempBox^.GetText(i,TempBox^.List^.Count);
    ws:=Copy(s,1+CName+1+CArtikul+1+CKol+1+CIzena+1+CZena+1,CIZena);
    AllItogo:=AllItogo+StrToReal(ws);
   End;

  For i:=0 To TempBox^.List^.Count-1 Do
   Begin

    s:=TempBox^.GetText(i,TempBox^.List^.Count);
    {memc(s);}
    SKol:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1,CKol);
    CArt:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1,CArtikul);
    (* ЗЦ !!!!!!!!!!!!!!
    CSumma:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1+CKol+1,CIZena);*)

    CSumma:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1+CKol+1+CIZena+1+Czena+1,CIZena);

    s2:=GetNGTDField(FNGTD,BakGetField(FNGTD,CArt,0));
    s3:=GetPostField(FPost,BakGetField(FPost,CArt,0));
    sMera:=GetIDField(FMera,CArt);
    GetMeraField(FMera,sMera);
    DelSpaceRight(s2);
    DelSpaceRight(s3);
    Format(s2,30);
    Format(s3,CPost);

    MyStr(StrToReal(CSUmma)/StrToReal(SKol),CIZena,CMantissaZ,SZena);
    {MyStr(StrToReal(CSumma)/6,10,CMantissa,CNDS);}
    Nalog:=GetIdField(FNDS,CArt);
    sNal:=Nalog;
    STr((1+StrToReal(NAlog)/100):CLitr:2,Nalog);

    MyStr(-StrToReal(SZena)/
              StrToReal(NAlog)+StrToReal(SZena),CZena,CMantissaZ,CNDS);
    {MyStr(StrToREal(SZena)-StrToReal(CNDS),CZena,CMantissa,CNDS);}
    NDS:=StrToReal(CNDS);  {НДС с цены}


    {Цена  НДС}
    SKol:=Copy(TempBox^.GetText(i,TempBox^.List^.Count),1+CName+1+CArtikul+1,CKol);
    MyStr((StrToReal(CSumma)-StrToReal(CNDS)*StrToReal(SKol))/StrToReal(SKol),CIZena,CMantissaZ,CZ);

    {Сумма НДС}


    MyStr(StrToReal(CZ)*StrToReal(SKol),CIZena,CMantissa,SZena);
    MyStr(StrToReal(CNDS)*StrToReal(SKOL),CIZena,CMantissa,CNDS);

    MyStr(StrToReal(allNds)+StrToReal(CNDS),CIZena,CMantissa,allNDS);

          If NPrint^.DAt.FullName=0 Then Ws2:=GetIdField(FName2,ws1)
          Else Ws2:=GetIdField(FFName2,ws1);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           ws1:=Copy(s,1,CName);
           System.Delete(s,1,CName);
           System.Insert(ws2,s,1);
           Writeln(txt2,Space+'     '+ws1);
          End;

  While Pos('│',s)>0 Do
    Begin
     k:=Pos('│',s);
     System.Delete(s,k,1);
     System.Insert(' ',s,k);
    End;
    Str(i+1:CLitrMantissa+1,ws);
    System.Delete(s,45,CZena+1+CIZena);
    s:=ws+' '+s;

    rformat(CZ,CZena);
    rformat(SZena,13);
    rformat(CNDS,10);
    Mystr(StrToReal(SNal),6,2,sNAl);
    System.Delete(sNal,4,3);

    rformat(cz,CZena);
    System.Insert({ws}{SZena}cz+SZEna+'       '+sNal+' '+CNDS,s,1+cLitrMantissa+1+CName+1+CArtikul+1+CKol+1+1);
    System.Delete(s,1+CName+1+5,CArtikul);
    sMera:={GetMeraField(FMera,sMera)}'ШТ';
    rformat(sMera,CArtikul+3);
    System.Insert(sMera+'  ',s,1+CName+1+6);
    MyStr(StrToReal(ws)/AllItogo*100,CKol,CMantissa,ws);
    DelSpaceRight(s2);
    DelSpaceRight(s3);
    Format(s2,CNSertif-16{13 для того что бы влез акциз});
    Format(s3,CPost);
    s:=s+'          '+s3+' '+s2;
   System.Insert(' ',s,42);
   { System.Insert(' ',s,49);}
    System.Delete(s,126,1);
    System.Insert(SeparatorChar,s,126);
    System.Delete(s,111,1);
    System.Insert(SeparatorChar,s,111);
    System.Delete(s,97,1);
    System.Insert(SeparatorChar,s,97);
    System.Delete(s,84,1);
    System.Insert(SeparatorChar,s,84);
    System.Delete(s,79,1);
    System.Insert(SeparatorChar,s,79);
    System.Delete(s,72,1);
    System.Insert(SeparatorChar,s,72);
    System.Delete(s,59,1);
    System.Insert(SeparatorChar,s,59);
    System.Delete(s,50,1);
    System.Insert(SeparatorChar,s,50);
    System.Delete(s,42,1);
    System.Insert(SeparatorChar,s,42);
    System.Delete(s,33,1);
    System.Insert(SeparatorChar,s,33);
  {  System.Delete(s,5,1);
    System.Insert(SeparatorChar,s,5);}
    Writeln(txt2,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+s);
   End;
  End;
   Writeln(txt2,Space+'Всего к оплате                                                              '
   +RecognizReal(StrToREal(AllNds),CIZena,CMantissa)+' '+
   +RecognizReal(AllItogo,CIZena,CMantissa));
   Writeln(txt2);
   Writeln(txt2);
   Writeln(txt2,Space+'   Руководитель предприятия ____________________ /'+Rek^.Dat.Director+'/'+'     '
   +'  Главный бухгалтер    ____________________ /'+Rek^.Dat.Buchgalter+'/');
   Writeln(txt2);
   Writeln(txt2);
   Writeln(txt2,Space+'   Индивидуальный предприниматель_______________ /                   /');
   Writeln(txt2);
  Writeln(txt2,Space+'   Примечание: Первый экземпляр-покупателю, второй-продавцу'
  +GlobalPrn^.Dat.EndPage[NPrint^.DAt.Printer]);



   torg12;



 Close(txt1);
 Close(txt2);
 Close(txt3);
 End;



 Dispose(TempBox,Done);
NoInfo;
ViewAsText(Path^.Dat.ToTemp+'calcthn.txt','СФ и накладная (Триада-Продукт)',True);
ViewAsText(Path^.Dat.ToTemp+'thnsf.txt','СФ  (Триада-Продукт)',True);
ViewAsText(Path^.Dat.ToTemp+'thn12.txt','Торг-12 (Триада-Продукт)',True);
{Report(Path^.Dat.ToTemp+'calcthn.txt','',NPrintC^.Dat.CopyAll,False,False);}
End;{CalcTch}



Procedure PrintRewisia(As:DocumentEditZ);
Var MMM : Maska8;
    f : RewisiaFileType;
    E : PRewisiaType;
    ws,ws1 : String;
    Prom,Fas,P : String[CPack];
    LocItogoPlus,LocItogoMinus : Real;
    St : String[CMantissa];
    Space,ss,ss1 : TEnjoyStr;
    SArtikul,Summa : String[CIZena];
    l : Word;
    K : Byte;
    Vid:Byte;
    txt : Text;
    Doc : LongInt;
    Minus : Boolean;
    PrintNumer,Find : Boolean;
    VidZakupki,VidProsmotra : Byte;
    LocItogoPlusZ,LocItogoAkzisPlus,LocItogoAkzisMinus,
    LocItogoMinusZ : Float;
    LocItogoPlusZ2,LocItogoMinusZ2 : Float;

Begin
 {открытие файлов}
 Space:='   ';

 AInfo('Ищу документ...');
 Assign(F,Path^.Dat.ToRewisia+As.D+'.rwz');
 l:=IOResult;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(f);
 l:=Ioresult;
 FileMode:=OldFileMode;
 If L <> 0 Then
  Begin
   NoInfo;
   MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToRewisia+As.D+'.rwz'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt,Path^.Dat.ToTemp+'rewisiap.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   NoInfo;
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'rewisiap.txt'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;

LocItogoPlusZ:=0;
LocItogoMinusZ:=0;

LocItogoPlusZ2:=0;
LocItogoMinusZ2:=0;



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
  For l:=1 To Max8 Do
  Begin
   MMM[l]:=1;
  End;
  BitToWord8(MMM,L);

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
      WordToBit8(L,MMM);
      Convert8(MMM);
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

 If {FindParam('/EZ')}(EnableZakupka=1) Or (StrToInt(CurrentPassword)=0) Then
  Begin
   VidProsmotra:=SelectImport(12);
   If VidProsmotra=1 Then Space:='    ';
   If VidProsmotra>=2 Then
    Begin
      CLose(f);
      Close(txt);
      Dispose(E,Done);
      Exit;
    End;

   VidZakupki:=0;

   If VidProsmotra=1 Then
   Begin
    VidZakupki:=SelectImport(17);
    If VidZakupki>=2 Then
     Begin
      CLose(f);
      Close(txt);
      Dispose(E,Done);
      Exit;
     End;
   End;

  End
  Else VidProsmotra:=0;

DInfoMsg('Формирую документ ревизии. Ждите...',True);


   Writeln(Txt,Space+'Склад: ',E^.Dat.SkladKod+'  Оператор: '+E^.Dat.Caption);
   If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
   Write(txt,Space+{'Последние изменения:'+}' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');

  Writeln(txt,Space+'Выбранные отделения:');
  Write(txt,Space);
  For l:=1 To Max8 Do
  If MMM[l]=1 Then Write(txt,l:2,':',Rek^.Dat.Otdel[l],' ');
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
    Writeln(txt,Space+'Примечание: '+
    GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    E^.Dat.Comment+
    GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
    Writeln(txt);
   End;

   If E^.DAt.Tested<>1 Then
   Begin
    Writeln(txt,Space+'Подписан оператором: '+
    GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
    GetOperatorField(FNAme,E^.Dat.CaptionTested)+' Дата проверки:'+E^.Dat.DateT+'('+E^.Dat.TimeT+')'+
    GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
    GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]
    +GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);
    Writeln(txt);
   End;


  Writeln(Txt,Header+Space+'                   А К Т    Р Е В И З И И   N '+E^.Dat.Document+' от '+E^.Dat.DateC+' ('+
      E^.Dat.TimeC+')'+HeaderStop);
  Writeln(txt);
  Writeln(Txt,Space+'                     Комиссия в составе:');
  Writeln(Txt,Space+'       1._____________________   2._____________________');
  Writeln(Txt,Space+'       3._____________________   4._____________________');
  Writeln(Txt,Space+'       произвела ревизию на складе');

 If VidProsmotra=1 Then
 Begin
  If VidZakupki=1 Then
  Writeln(Txt,Header+Space+'Вид просмотра: '+
  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
  'Закупка 2'+
  GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+HeaderStop)
  Else
  Writeln(Txt,Header+Space+'Вид просмотра: '+
  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
  'Закупка для бухгалтерии'+
  GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+
  HeaderStop);
  Writeln(Txt,Header+Space+
                    '┌─────────────────────────────────────────────────────────────────────────────────────┐');
  Writeln(Txt,Space+'│N  Код  Наименование товара        Фас  Ко-во   Р/Цена     З/Цена Итого сумма Р/Ц Отд│');
  Writeln(Txt,Space+'└─────────────────────────────────────────────────────────────────────────────────────┘'+headerStop);
 End
 Else
 Begin
  Writeln(Txt,Header+Space+'Вид просмотра: '+
  GlobalPrn^.Dat.Italic[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]+
  'Стандартный'+
  GlobalPrn^.Dat.NoItalic[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]+HeaderStop);
  Writeln(Txt,Header+
              Space+'┌────────────────────────────────────────────────────────────────────────────────────┐');
  Writeln(Txt,Space+'│N  Код  Наименование товара        Фас  Ко-во  Упаковок     Цена Итого сумма Р/Ц Отд│');
  Writeln(Txt,Space+'└────────────────────────────────────────────────────────────────────────────────────┘'+headerStop);
 End;

                    {12 12345 12345678901234567890123456 123 123456 123456789 12345678 12345678 123456789012345  1 }

LocItogoPlus:=0;
LocItogoMinus:=0;
LocItogoAkzisPlus:=0;
LocItogoAkzisMinus:=0;

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
            SArtikul:=E^.Dat.Element[l].BAzKod;
                 {ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);}
          If Nprint^.DAt.FullName=0 Then
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

            If VidProsmotra=1 Then
            Begin
            ws:=SArtikul+' '+ws+' '+Fas+' '+E^.Dat.Element[l].Input.Division[k]+
             +' '+E^.Dat.Element[l].Input.R_Zena;

             DelSpace(E^.Dat.Element[l].Input.Zakupka);
             RFormat(E^.Dat.Element[l].Input.Zakupka,CZenaZ);

             DelSpace(E^.Dat.Element[l].Input.Zakupka2);
             RFormat(E^.Dat.Element[l].Input.Zakupka2,CZenaZ);
             If VidZakupki=0 Then
             ws:=ws+' '+E^.Dat.Element[l].Input.Zakupka
             Else
             ws:=ws+' '+E^.Dat.Element[l].Input.Zakupka2;
            End
            Else
            ws:=SArtikul+' '+ws+' '+Fas+' '+E^.Dat.Element[l].Input.Division[k]+
             +' '+P+' '+E^.Dat.Element[l].Input.R_Zena;


           MyStr((StrToInt(E^.Dat.Element[l].Input.DiviSion[k])*StrToReal(E^.Dat.Element[l].Input.R_Zena))
           ,CIZena,CMantissa,ss);
           Str(k:2,P);
           ws:=ws+' '+ss+' '+P;

  If TestLastDiviSion(E^.Dat.Element[l].Input.Division,K,MMM,Vid) Then
  Begin
     If PrintNumer Then
      Begin
      Writeln(txt,Space+st+' '+
	 GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+ws+
	 GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]);
      PrintNumer:=False;
      End
     Else
      Writeln(txt,Space+'   '+
	 GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]+ws+
	 GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer])
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
             Begin
                LocItogoMinus:=LocItogoMinus+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.R_Zena);
                LocItogoMinusZ:=LocItogoMinusZ+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.Zakupka);
                LocItogoMinusZ2:=LocItogoMinusZ2+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.Zakupka2);
                LocItogoAkzisMinus:=LocItogoAkzisMinus+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.AkzisSbor);

             End
            Else
             Begin
                LocItogoPlus:=LocItogoPlus+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.R_Zena);
                LocItogoPlusZ:=LocItogoPlusZ+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.Zakupka);
                LocItogoPlusZ2:=LocItogoPlusZ2+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.Zakupka2);
                LocItogoAkzisPlus:=LocItogoAkzisPlus+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.AkzisSbor);
             End;

          End;{Если сошлось отделение}
     End;{For по отделениям}
    End;{For по документу}

     Writeln(Txt,Space+'────────────────────────────────────────────────────────────────────────────────────-');
     Writeln(Txt,Space+'                                              Всего наименований: ',E^.Dat.Amount:CIZena);
     Writeln(Txt,Space+'                                                 приход на склад: ',RecognizReal(LocItogoPlus,CIZena,
        CMantissa),' руб');
     Writeln(Txt,Space+'                                                расход со склада: ',RecognizReal(LocItogoMinus,CIZena,
        CMantissa),' руб');
     Writeln(Txt,Space+'  Проверил акт ревизии ___________                 Всего ревизия: ',RecognizReal(LocItogoPlus+
        LocItogoMinus,
        CIZena,CMantissa),' руб');

     Writeln(Txt,Space+'                                       Акцизный сбор по ревизии : ',RecognizReal(
        (LocItogoAkzisPlus+LocItogoAkzisMinus),CIZena,CMAntissaZ));



     If VidProsmotra=1 Then
     Begin
     Writeln(Txt,Space+'                                          приход на склад по З/Ц: ',RecognizReal(LocItogoPlusZ,CIZena,
        CMantissa),' руб');
     Writeln(Txt,Space+'                                          приход на склад по ЗЦ2: ',RecognizReal(LocItogoPlusZ2,CIZena,
        CMantissa),' руб');
     Writeln(Txt,Space+'                                         расход со склада по З/Ц: ',RecognizReal(LocItogoMinusZ,CIZena,
        CMantissa),' руб');
     Writeln(Txt,Space+'                                         расход со склада по ЗЦ2: ',RecognizReal(LocItogoMinusZ2,
        CIZena,
        CMantissa),' руб');
     Writeln(Txt,Space+'                                            Всего ревизия по З/Ц: ',RecognizReal(LocItogoPlusZ+
        LocItogoMinusZ,CIZena,CMantissa),' руб');
     Writeln(Txt,Space+'                                            Всего ревизия по ЗЦ2: ',RecognizReal(LocItogoPlusZ2+
        LocItogoMinusZ2,CIZena,CMantissa),' руб');
     End;



     Writeln(txt,Space+'                                                               "'+DayString[DayOfWeek(ToDay)]+'" '+
        FDate+'('+Times+')');
     Writeln(Txt,Space+'=====================================================================================');

NoInfoMsg;

Dispose(E,Done);
Close(Txt);
Reportnew(Path^.Dat.ToTemp+'rewisiap.txt','',NprintC^.DAt.CopyRwz,False,False)

End;




Function ViewAllRewisia(SDate:TDateString;Auto:Boolean;Default:Byte):AllStr;
Var MMM : Maska8;
    f : RewisiaFileType;
    E : PRewisiaType;
    ws,ws1 : String;
    Prom,Fas,P : String[CPack];
    LocItogoPlus,LocItogoMinus,ItogoPlus,ItogoMinus,
    LocItogoPlusZ,LocItogoMinusZ,ItogoAkzisPlus,ItogoAkzisMinus,
    ItogoPlusZ,ItogoMinusZ : Float;
    LocItogoAkzisPlus,LocItogoAkzisMinus,
    LocItogoPlusZ2,LocItogoMinusZ2,ItogoPlusZ2,ItogoMinusZ2 : Float;
    St : String[CMantissa];
    ws2,ss,ss1 : TEnjoyStr;
    Summa : String[CIZena];
    l : Word;
    K : Byte;
    Vid:Byte;
    txt : Text;
    Doc : LongInt;
    PrintNumer,Minus : Boolean;
    SArtikul : AllStr;
    Space : AllStr;
    VidZakupki,VidProsmotra : Byte;

Begin
 ViewAllRewisia:='           0.00   0';
 {открытие файлов}

 Assign(F,Path^.Dat.ToRewisia+SDate+'.rwz');
 l:=IOResult;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(f);
 l:=Ioresult;
 FileMode:=OldFileMode;
 If L <> 0 Then
  Begin
   If Not(Auto) Then
   MessageBox(#3^M+#3'Не найден файл '+Path^.Dat.ToRewisia+SDate+'.rwz'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt,Path^.Dat.ToTemp+'rewisia.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   If Not(Auto) Then
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path^.Dat.ToTemp+'rewisia.txt'+
   +' Код:'+IntToStr(l,3),Nil,mfError+mfCancelButton);
   Exit;
  End;

 {начальная установка отделений}
  For l:=1 To Max8 Do
  Begin
   MMM[l]:=1;
  End;
  BitToWord8(MMM,L);
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
          WordToBit8(L,MMM);
          Convert8(MMM);
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
ItogoPlusZ2:=0;
ItogoMinusZ2:=0;
ItogoAkzisPlus:=0;
ItogoAkzisMinus:=0;
Doc:=0;


 Space:='';
 If Not(Auto) Then
 If {FindParam('/EZ')}(EnableZakupka=1) Or (StrToInt(CurrentPassword)=0) Then
  Begin
   VidProsmotra:=SelectImport(12);
   If VidProsmotra>=2 Then
    Begin
     CLose(f);
     Close(txt);
     Exit;
    End;
   VidZakupki:=0;
   If VidProsmotra=1 Then
   Begin
    VidZakupki:=SelectImport(17);
    If VidZakupki>=2 Then
     Begin
      CLose(f);
      Close(txt);
      Exit;
     End;
   End;
  End
  Else VidProsmotra:=0;



If Not(Auto) Then   DInfo('Минуточку...');



  New(E,Init);

Writeln(txt,Space+'Выбранные отделения:');
For l:=1 To Max8 Do
If MMM[l]=1 Then Write(txt,l:2,':',Rek^.Dat.Otdel[l],' ');
Writeln(txt);
Writeln(txt);

Case Vid Of
0:Writeln(txt,Space+'Отбор: Приходная часть');
1:Writeln(txt,Space+'Отбор: Расходная часть');
2:Writeln(txt,Space+'Отбор: Все');
Else;
End;
Writeln(txt);


While Not Eof(f) Do
Begin
   ReadRewisia(f,E);
   Inc(Doc);
   Writeln(Txt,Space+'Склад: ',{E^.Dat.Prihod.Sklad}E^.Dat.SkladKod+
             '  Оператор: '+E^.Dat.Caption);
   If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
   begin
   Write(txt,{'Последние изменения:'+}' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
   writeln(txt);
   end;
   DelSpaceRight(E^.Dat.Comment);
   If E^.DAt.Comment[0]<>#0 Then
   Writeln(txt,Space+'Примечание: '+E^.Dat.Comment);

   If E^.DAt.Tested<>1 Then
   Begin
    Writeln(txt,Space+'Подписан оператором: '+
    GetOperatorField(FNAme,E^.Dat.CaptionTested)+' Дата проверки:'+E^.Dat.DateT+'('+E^.Dat.TimeT+')');
    Writeln(txt);
   End;




  Writeln(Txt,Space+'                   А К Т    Р Е В И З И И   N '+E^.Dat.Document+' от '+E^.Dat.DateC+' ('+
      E^.Dat.TimeC+')');
{
  Writeln(Txt,Space+'┌────────────────────────────────────────────────────────────────────────────────────┐');
  Writeln(Txt,Space+'│N  Код  Наименование товара        Фас  Ко-во  Упаковок     Цена     Итого сумма Отд│');
  Writeln(Txt,Space+'└────────────────────────────────────────────────────────────────────────────────────┘');
}
              {12 12345 12345678901234567890123456 123 123456 123456789 12345678 123456789012345  1 }
 If VidProsmotra=1 Then
 Begin
  If VidZakupki=1 Then
  Writeln(Txt,'Вид просмотра: Закупка 2')
  Else
  Writeln(Txt,'Вид просмотра: Закупка для бухгалтерии');
  Writeln(Txt,Space+'┌────────────────────────────────────────────────────────────────────────────────────────────────┐');
  Writeln(Txt,Space+'│N  Код  Наименование товара        Фас  Ко-во   Р/Цена     З/Цена Итого сумма Р/Ц Акциз.сбор Отд│');
  Writeln(Txt,Space+'└────────────────────────────────────────────────────────────────────────────────────────────────┘');
 End
 Else
 Begin
  Writeln(Txt,'Вид просмотра: Стандартный');
  Writeln(Txt,Space+'┌────────────────────────────────────────────────────────────────────────────────────┐');
  Writeln(Txt,Space+'│N  Код  Наименование товара        Фас  Ко-во  Упаковок     Цена Итого сумма Р/Ц Отд│');
                                                                          {│123456789012345│1234567890│123}
  Writeln(Txt,Space+'└────────────────────────────────────────────────────────────────────────────────────┘');
 End;


LocItogoPlus:=0;
LocItogoMinus:=0;

LocItogoAkzisPlus:=0;
LocItogoAkzisMinus:=0;


LocItogoPlusZ:=0;
LocItogoMinusZ:=0;

LocItogoPlusZ2:=0;
LocItogoMinusZ2:=0;

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
            SArtikul:=E^.Dat.Element[l].BazKod;
            {
            ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);}
     If Nprint^.DAt.FullName=0 Then
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

            DelSpace(E^.Dat.Element[l].Input.Zakupka);
            RFormat(E^.Dat.Element[l].Input.Zakupka,CZenaZ);

            DelSpace(E^.Dat.Element[l].Input.Zakupka2);
            RFormat(E^.Dat.Element[l].Input.Zakupka2,CZenaZ);
{
           ws:=SArtikul+' '+ws+' '+Fas+' '+E^.Dat.Element[l].Input.Division[k]+
           +' '+P+' '+E^.Dat.Element[l].Input.R_Zena;
}
            If VidProsmotra=1 Then
            Begin
             ws:=SArtikul+' '+ws+' '+Fas+' '+E^.Dat.Element[l].Input.Division[k]+
             +' '+E^.Dat.Element[l].Input.R_Zena;

             DelSpace(E^.Dat.Element[l].Input.Zakupka);
             RFormat(E^.Dat.Element[l].Input.Zakupka,CZenaZ);

             DelSpace(E^.Dat.Element[l].Input.Zakupka2);
             RFormat(E^.Dat.Element[l].Input.Zakupka2,CZenaZ);

             If VidZakupki=0 Then
             ws:=ws+' '+E^.Dat.Element[l].Input.Zakupka
             Else
             ws:=ws+' '+E^.Dat.Element[l].Input.Zakupka2;

             MyStr(StrToReal(E^.Dat.Element[l].Input.AkzisSbor)
                         {*StrToInt(E^.Dat.Element[l].Input.Division[k])},CZenaZ,CMantissaZ,
                  ws2);
             ws2:=' '+ws2;
            End
            Else
            Begin
             ws:=SArtikul+' '+ws+' '+Fas+' '+E^.Dat.Element[l].Input.Division[k]+
             +' '+P+' '+E^.Dat.Element[l].Input.R_Zena;
              ws2[0]:=#0;
            End;



           MyStr((StrToInt(E^.Dat.Element[l].Input.DiviSion[k])*StrToReal(E^.Dat.Element[l].Input.R_Zena))
           ,CIZena,CMantissa,ss);

           Str(k:2,P);

           ws:=ws+' '+ss+ws2+' '+P;

           If PrintNumer Then Begin
                                Writeln(txt,Space+St+' '+ws);
                                PrintNumer:=False;
                              End
                 Else Writeln(txt,Space+'   '+ws);


            If Minus Then
            Begin
                LocItogoMinus:=LocItogoMinus+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.R_Zena);
                LocItogoMinusZ:=LocItogoMinusZ+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.Zakupka);
                LocItogoMinusZ2:=LocItogoMinusZ2+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.Zakupka2);
                LocItogoAkzisMinus:=LocItogoAkzisMinus+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.AkzisSbor);
            End
            Else
            Begin
                LocItogoPlus:=LocItogoPlus+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.R_Zena);
                LocItogoPlusZ:=LocItogoPlusZ+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.Zakupka);
                LocItogoPlusZ2:=LocItogoPlusZ2+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.Zakupka2);
                LocItogoAkzisPlus:=LocItogoAkzisPlus+StrToInt(E^.Dat.Element[l].Input.Division[k])*
                         StrToReal(E^.Dat.Element[l].Input.AkzisSbor);
            End;



          End;{Если сошлось отделение}
     End;{For по отделениям}
    End;{For по документу}

     If VidProsmotra=0 Then
     Writeln(Txt,'─────────────────────────────────────────────────────────────────────────────────────')
     Else
     Writeln(Txt,'──────────────────────────────────────────────────────────────────────────────────────────────────');

     Writeln(Txt,'                                              Всего наименований: ',E^.Dat.Amount:CIZena);
     Writeln(Txt,'                                          приход на склад по Р/Ц: ',RecognizReal(LocItogoPlus,CIZena,
        CMantissa),' руб');
     Writeln(Txt,'                                                    в т.ч. акциз: ',RecognizReal(LocItogoAkzisPlus,CIZena,
        CMantissaZ),' руб');
     Writeln(Txt,'                                         расход со склада по Р/Ц: ',RecognizReal(LocItogoMinus,CIZena,
        CMantissa),' руб');
     Writeln(Txt,'                                                    в т.ч. акциз: ',RecognizReal(LocItogoAkzisMinus,CIZena,
        CMantissaZ),' руб');

     Writeln(Txt,'                                            Всего ревизия по Р/Ц: ',RecognizReal(LocItogoPlus+LocItogoMinus,
        CIZena,CMantissa),' руб');
     Writeln(Txt,'                                                    в т.ч. акциз: ',RecognizReal(LocItogoAkzisPlus+
        LocItogoAkzisMinus,
        CIZena,CMantissaZ),' руб');

     If (StrToInt(CurrentPassword)=0) Or ({FindParam('/EZ')}(EnableZakupka=1)) Then
     Begin
     Writeln(txt);
     Writeln(Txt,'                                          приход на склад по З/Ц: ',RecognizReal(LocItogoPlusZ,CIZena,
        CMantissaZ),' руб');
     Writeln(Txt,'                                          приход на склад по ЗЦ2: ',RecognizReal(LocItogoPlusZ2,CIZena,
        CMantissaZ),' руб');
     Writeln(Txt,'                                         расход со склада по З/Ц: ',RecognizReal(LocItogoMinusZ,CIZena,
        CMantissaZ),' руб');
     Writeln(Txt,'                                         расход со склада по ЗЦ2: ',RecognizReal(LocItogoMinusZ2,CIZena,
        CMantissaZ),' руб');
     Writeln(Txt,'                                            Всего ревизия по З/Ц: ',RecognizReal(LocItogoPlusZ+
        LocItogoMinusZ,CIZena,CMantissaZ),' руб');
     Writeln(Txt,'                                            Всего ревизия по ЗЦ2: ',RecognizReal(LocItogoPlusZ2+
        LocItogoMinusZ2,CIZena,CMantissaZ),' руб');
     End;

     Writeln(Txt,'=====================================================================================');

     Writeln(Txt);



  ItogoMinus:=ItogoMinus+LocItogoMinus;
  ItogoPlus :=ItogoPlus+LocItogoPlus;
  ItogoMinusZ:=ItogoMinusZ+LocItogoMinusZ;
  ItogoPlusZ :=ItogoPlusZ+LocItogoPlusZ;
  ItogoMinusZ2:=ItogoMinusZ2+LocItogoMinusZ2;
  ItogoPlusZ2 :=ItogoPlusZ2+LocItogoPlusZ2;
  ItogoAkzisPlus :=ItogoAkzisPlus+LocItogoAkzisPlus;
  ItogoAkzisMinus :=ItogoAkzisMinus+LocItogoAkzisMinus;
End;{While по файлу}

{If IOREsult<>0 Then SpecialBeep;}

If Not(Auto) Then
Begin
Writeln(txt,'Всего ревизия за '+SDate+' по Р/Ц составила: ',RecognizReal(ItogoPlus+ItogoMinus,CIZena,CMantissa),' руб.');
Writeln(txt,'                        в том числе приход: ',RecognizReal(ItogoPlus,CIZena,CMantissa),' руб.');
Writeln(txt,'                                     акциз: ',RecognizReal(ItogoAkzisPlus,CIZena,CMantissaZ),' руб.');
Writeln(txt,'                        в том числе расход: ',RecognizReal(ItogoMinus,CIZena,CMantissa),' руб.');
Writeln(txt,'                                     акциз: ',RecognizReal(ItogoAkzisMinus,CIZena,CMantissaZ),' руб.');

Str(Doc:CLitrMAntissa,ws);
Writeln(Txt,'          Всего за день документов: ',Ws);
Writeln(Txt,'    Всего за день акциз по ревизии: ',RecognizReal(ItogoAkzisPlus+
+ItogoAkzisMinus,CIZena,CMantissaZ),' руб.');

 If (StrToint(CurrentPassword)=0) Or ({FindParam('/EZ')}(EnableZakupka=1)) Then
  Begin
Writeln(txt);
Writeln(txt,'Всего ревизия за '+SDate+' по З/Ц составила: ',RecognizReal(ItogoPlusZ+ItogoMinusZ,CIZena,CMantissaZ),' руб.');
Writeln(txt,'                        в том числе приход: ',RecognizReal(ItogoPlusZ,CIZena,CMantissaZ),' руб.');
Writeln(txt,'                        в том числе расход: ',RecognizReal(ItogoMinusZ,CIZena,CMantissaZ),' руб.');
Writeln(txt,'Всего ревизия за '+SDate+' по ЗЦ2 составила: ',RecognizReal(ItogoPlusZ2+ItogoMinusZ2,CIZena,CMantissaZ),' руб.');
Writeln(txt,'                        в том числе приход: ',RecognizReal(ItogoPlusZ2,CIZena,CMantissaZ),' руб.');
Writeln(txt,'                        в том числе расход: ',RecognizReal(ItogoMinusZ2,CIZena,CMantissaZ),' руб.');
  End;


End;

Dispose(E,Done);
If Not(Auto) Then  NoInfo;
  Close(f);
  Close(Txt);
If Not(Auto) Then
  ViewAsText(Path^.Dat.ToTemp+'rewisia.txt','Просмотр ревизий за '+SDate,False);

MyStr(ItogoPlus+ItogoMinus,CIZena,CMantissa,ss);
Str(Doc:3,ss1);
ss:=ss+' '+ss1;
ViewAllRewisia:=ss;
End;







BEGIN
END.
