{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit utils9;


Interface

Uses Glob,ServStr,Dialogs,MyCalc,Drivers;

Function ExtendedBases(Pref:Char;MaxKod:ArtikulStr):Boolean;
Function ExtendedBases2(Pref:Char;MaxKod:ArtikulStr):Boolean;
Function ExtendedRazdel(P:PImportSuperMarketType):Boolean;
Function ExtendedMake(P:PImportSuperMarketType):Boolean;
Function ExtendedGroup(P:PImportSuperMarketType):Boolean;

Function {1}ExtendedMera(P:PImportSuperMarketType):Boolean;
Function {2}ExtendedPost(P:PImportSuperMarketType):Boolean;
Function {3}ExtendedFirmaPost(P:PImportSuperMarketType):Boolean;
Function {4}ExtendedKSertif(P:PImportSuperMarketType):Boolean;

Function {5}ExtendedMarka(P:PImportSuperMarketType):Boolean;
Function {6}ExtendedSpecMarka(P:PImportSuperMarketType):Boolean;
Function {7}ExtendedNGTD(P:PImportSuperMarketType):Boolean;
Function {8}ExtendedExpert(P:PImportSuperMarketType):Boolean;
Function {8}ExtendedClass(P:PImportSuperMarketType):Boolean;

Function {1}TestExtendedMera(Maximum : LongInt):Boolean;
Function {2}TestExtendedPost(Maximum : LongInt):Boolean;
Function {3}TestExtendedFirmaPost(Maximum : LongInt):Boolean;
Function {4}TestExtendedKSertif(Maximum : LongInt):Boolean;
Function {5}TestExtendedMarka(Maximum : LongInt):Boolean;
Function {6}TestExtendedSpecMarka(Maximum:LongInt):Boolean;
Function {7}TestExtendedNGTD(Maximum : LongInt):Boolean;
Function {8}TestExtendedExpert(Maximum:LongInt):Boolean;
Function    TestExtendedClass(Maximum : LongInt):Boolean;
Function    TestExtendedKassa(Maximum : LongInt):Boolean;
Function    TestExtendedPersonal(Maximum : LongInt):Boolean;
Function    TestExtendedBank(Maximum : LongInt):Boolean;


Procedure AddKSertifAuto(pp:String);
Procedure AddClassAuto(pp:String);
Procedure AddKassaAuto(pp:String);
Procedure AddPersonalAuto(pp:String);
Procedure AddBankAuto(pp:String);
Procedure AddMeraAuto(pp:String);
Procedure AddFirmaPostAuto(pp:String);
Procedure AddPostAuto(pp:String);

Procedure AddNGTDAuto(pp:String);
Procedure AddMarkaAuto(pp:String);
Procedure AddSpecMarkaAuto(pp:String);
Procedure AddExpertAuto(pp:String);


Procedure AddContrAgent(pp:String);
Procedure AddContrAgent2(pp:String);


Procedure CalcNDS1(As:DocumentEditZ; FiltrOtdel:Maska8;Var NDS,NDS20,NDS10,NDS_,NDS18,NDS16,Litr:Real);


implementation

Uses Serv,Objects,DbEngine,MsgBox,NetDbEng,Protect,NetCall,TPDAte,
     Mail,Utils5,Utils4,Utils6,Access1,DbEngin2,Memory,Dos,ServStr2,
     Views,ColorTxt,App,Utils,MrkTools,

     TVInput,TvType,TvConst,Validate,Vision1,Filetool,
     Printers,Prise,MyView,Tools,Vision11;

{Const amReadOnly=0;}

Type FindMaxElement=Array[0..99] Of Word;
Type LogikMaxElement=Array[0..99] Of Boolean;


Function ExtendedRazdel(P:PImportSuperMarketType):Boolean;

Var Find : FindMaxElement;
    Logik: LogikMaxElement;
     c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
     Eb : File Of BazType;
     Es : SkladFileType;
   KdxF : File Of SkladTypeNew;
    Skf : SkidkaFileType;
     bb : PBazType;
     ss : PSkladType;
    Kdx : PSkladTypeNew;
    sks : PSkidkaType;

Begin
For c:=0 To 99 Do
 Begin
  Find[c]:=0;
  Logik[c]:=False;
 End;

ExtendedRazdel:=True;
{расчитываем максимальные позиции в разделах}
For c:=1 To P^.Dat.Amount Do
 Begin
  StRazd:=Copy(P^.Dat.Element[c].Baz.BazKod,1,CRaZdelKod);
  SArt:=Copy(P^.Dat.Element[c].Baz.BazKod,CRaZdelKod+1,CKod);
  If Find[StrToInt(StRazd)]<StrToInt(SArt) Then
  Begin
   Find[StrToInt(StRazd)]:=StrToInt(SArt);
   Logik[StrToInt(StRazd)]:=True;
  End;

  If P^.Dat.Element[c].Baz.Main=1 Then
    Begin
     StRazd:=Copy(P^.Dat.Element[c].Baz.FantomKod,1,CRaZdelKod);
     SArt:=Copy(P^.Dat.Element[c].Baz.FantomKod,CRaZdelKod+1,CKod);
     If Find[StrToInt(StRazd)]<StrToInt(SArt) Then
     Begin
      Find[StrToInt(StRazd)]:=StrToInt(SArt);
      Logik[StrToInt(StRazd)]:=True;
     End;
    End;
 End;

For c:=1 To P^.Dat.AmountS Do
 Begin
  StRazd:=Copy(P^.Dat.ElementS[c].BAz.BazKod,1,CRaZdelKod);
  SArt:=Copy(P^.Dat.ElementS[c].BAz.BazKod,CRaZdelKod+1,CKod);
  If Find[StrToInt(StRazd)]<StrToInt(SArt) Then
  Begin
   Find[StrToInt(StRazd)]:=StrToInt(SArt);
   Logik[StrToInt(StRazd)]:=True;
  End;

  If P^.Dat.Elements[c].Baz.Main=1 Then
    Begin
     StRazd:=Copy(P^.Dat.Elements[c].Baz.FantomKod,1,CRaZdelKod);
     SArt:=Copy(P^.Dat.Elements[c].Baz.FantomKod,CRaZdelKod+1,CKod);
     If Find[StrToInt(StRazd)]<StrToInt(SArt) Then
     Begin
      Find[StrToInt(StRazd)]:=StrToInt(SArt);
      Logik[StrToInt(StRazd)]:=True;
     End;
    End;

 End;

For c:=1 To P^.Dat.AmountNS Do
 Begin
  StRazd:=Copy(P^.Dat.NSertif[c].Baz.BazKod,1,CRaZdelKod);
  SArt:=Copy(P^.Dat.NSertif[c].Baz.BazKod,CRaZdelKod+1,CKod);
  If Find[StrToInt(StRazd)]<StrToInt(SArt) Then
  Begin
   Find[StrToInt(StRazd)]:=StrToInt(SArt);
   Logik[StrToInt(StRazd)]:=True;
  End;

  If P^.Dat.NSertif[c].Baz.Main=1 Then
    Begin
     StRazd:=Copy(P^.Dat.NSertif[c].Baz.FantomKod,1,CRaZdelKod);
     SArt:=Copy(P^.Dat.NSertif[c].Baz.FantomKod,CRaZdelKod+1,CKod);
     If Find[StrToInt(StRazd)]<StrToInt(SArt) Then
     Begin
      Find[StrToInt(StRazd)]:=StrToInt(SArt);
      Logik[StrToInt(StRazd)]:=True;
     End;
    End;

 End;

DInfoMsg('Проверяю размерность разделов...',True);

For c:=0 To 99 Do
Begin
If Logik[c] Then
 Begin
  StRazd:=IntToStr(C,CMantissa);
  RFormatZerro(StRAzd,CMantissa);
  Assign(Eb,Path^.Dat.ToName+StRazd+'.id');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка доступа к файлу наименований '+Path^.Dat.ToName+strazd+'.id!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ExtendedRazdel:=False;
   Exit;
  End;
  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;
  If (Find[c]+1)>(Max) Then
   Begin
{If MessageBox('',Nil,mfFatalError+mfOkCancel)=cmOk Then}
Begin
         Assign(Eb,Path^.Dat.ToName+StRazd+'.id');
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;
         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Find[c]+1-MAx) Do
                Begin
                 Str(k+MAx-1:3,S);
                 RFormatZerro(s,3);
                 bb^.Dat.BazKod:=StRazd+s;
                 bb^.Dat.Employ:=False;
                 bb^.Dat.Caption:=CurrentPassword;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
           NoInfoMsg;
           ExtendedRazdel:=False;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToName+StRazd+'.id Код: '+IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

         Assign(Es,Path^.Dat.ToSklad+StRazd+'.db');
         r:=Ioresult;
         Reset(Es);
         r:=Ioresult;
         If r=0 Then
         Begin
          Seek(Es,FileSize(Es));
          New(ss,Init);
          For k:=1 To (Find[c]+1-MAx) Do
                Begin
                 Str(k+MAx-1:3,S);
                 RFormatZerro(s,3);
                 ss^.Dat.BazKod:=StRazd+s;
                 ss^.Dat.Employ:=False;
                 ss^.Dat.Time:=CurrentTime;
                 ss^.Dat.Date:=DateStringToDAte(DateMask,FDate);
                 Seek(es,FileSize(es));
                 Write(es,ss^.Dat);
                End;
          Dispose(ss,Done);
          r:=Ioresult;
          Close(Es);
          r:=Ioresult;
         End{If}
          Else
                Begin
           NoInfoMsg;
           ExtendedRazdel:=False;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSklad+StRazd+'.db Код: '+IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

         Assign(skf,Path^.Dat.ToSkidki+StRazd+'.skl');
         r:=Ioresult;
         Reset(skf);
         r:=Ioresult;
         If r=0 Then
         Begin
          Seek(skf,FileSize(Skf));
          New(sks,Init);
          For k:=1 To (Find[c]+1-MAx) Do
                Begin
                 Str(k+MAx-1:3,S);
                 RFormatZerro(s,3);
                 For c1:=1 To CShkala Do
                 Begin
                  sks^.Dat.Skidka[c1].Up:='0.00';
                  sks^.Dat.Skidka[c1].Proz:='0.00';
                 End;
                 sks^.Dat.Caption:=CurrentPassword;
                 sks^.Dat.BazKod:=StRazd+s;
                 sks^.Dat.Time:=Times;
                 sks^.Dat.Date:=FDate;
                 Seek(skf,FileSize(skf));
                 Write(skf,sks^.Dat);
                End;
          Dispose(sks,Done);
          r:=Ioresult;
          Close(skf);
          r:=Ioresult;
         End{If}
          Else
                Begin
           NoInfoMsg;
           ExtendedRazdel:=False;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToSkidki+StRazd+'.skl Код: '+IntToStr(r,CLitrMantissa),
                 Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}


         Assign(kdxf,Path^.Dat.ToIndex+StRazd+'.kdx');
         r:=Ioresult;
         Reset(kdxf);
         r:=Ioresult;
         If r=0 Then
         Begin
          Seek(kdxf,FileSize(kdxf));
          New(kdx,Init);
          For k:=1 To (Find[c]+1-MAx) Do
                Begin
                 Str(k+MAx-1:3,S);
                 RFormatZerro(s,3);
                 kdx^.Dat.BazKod:=StrToInt(StRazd+s);
                 kdx^.Dat.Employ:=False;
                 Seek(kdxf,FileSize(kdxf));
                 Write(kdxf,kdx^.Dat);
                End;
          Dispose(kdx,Done);
          r:=Ioresult;
          Close(kdxf);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ExtendedRazdel:=False;
                 MessageBox(^M+#3'Ошибка открытия '+Path^.Dat.ToIndex+StRazd+'.kdx Код: '+IntToStr(r,CLitrMantissa),
                 Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}

End
 {
 Else
   Begin
    NoInfoMsg;
    ExtendedRazdel:=False;
    Exit;
   End;
 }
   End;{если надо добавлять}

 End;{Logik}
End;{For по результатам анализа}
NoInfoMsg;
ExtendedRazdel:=True;
End;{Procedure}



Function ExtendedMake(P:PImportSuperMarketType):Boolean;
Var Find : FindMaxElement;
    Logik: LogikMaxElement;
     c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : ClientFileType;
    bb  : PClientType;
    Eb1  : KurzClientFileType;
    bb1  : PKurzClientType;

Begin

For c:=0 To 2 Do
 Begin
  Find[c]:=0;
  Logik[c]:=False;
 End;

ExtendedMAke:=True;

{расчитываем максимальные позиции в разделах}
For c:=1 To P^.Dat.Amount Do
 Begin
  StRazd:=Copy(P^.Dat.Element[c].Input.NMakeKod,1,COne);
  SArt:=Copy(P^.Dat.Element[c].Input.NMAkeKod,1+1,CClientKod);
  If Find[StrToInt(StRazd)]<StrToInt(SArt) Then
  Begin
   Find[StrToInt(StRazd)]:=StrToInt(SArt);
   Logik[StrToInt(StRazd)]:=True;
  End;
 End;

For c:=1 To P^.Dat.AmountS Do
 Begin
  StRazd:=Copy(P^.Dat.ElementS[c].Input.NMakeKod,1,COne);
  SArt:=Copy(P^.Dat.ElementS[c].Input.NMakeKod,1+1,CClientKod);
  If Find[StrToInt(StRazd)]<StrToInt(SArt) Then
  Begin
   Find[StrToInt(StRazd)]:=StrToInt(SArt);
   Logik[StrToInt(StRazd)]:=True;
  End;
 End;


For c:=1 To P^.Dat.AmountNS Do
 Begin
  StRazd:=Copy(P^.Dat.NSertif[c].NMAkeKod,1,COne);
  SArt:=Copy(P^.Dat.NSertif[c].NMakeKod,1+1,CClientKod);
  If Find[StrToInt(StRazd)]<StrToInt(SArt) Then
  Begin
   Find[StrToInt(StRazd)]:=StrToInt(SArt);
   Logik[StrToInt(StRazd)]:=True;
  End;
 End;

DInfoMsg('Проверяю размерность баз поставщиков...',True);

For c:=0 To 2 Do
Begin
If Logik[c] Then
 Begin

  Case c Of
  0:Begin
     Assign(Eb,Path^.Dat.ToClient+'Make.Db');
     Assign(Eb1,Path^.Dat.ToClientBaseIndex+'Make.idx');
    End;
  1:Begin
     Assign(Eb,Path^.Dat.ToClient+'Sklad.Db');
     Assign(Eb1,Path^.Dat.ToClientBaseIndex+'Sklad.idx');
    End;
  2:Begin
     Assign(Eb,Path^.Dat.ToClient+'Barter.Db');
     Assign(Eb1,Path^.Dat.ToClientBaseIndex+'Barter.idx');
    End;
  Else;
  End;

  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла поставщиков группы '+IntToStr(c,COne)+'!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ExtendedMake:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Find[c]+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         Reset(Eb1);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          Seek(Eb1,FileSize(Eb1));
          New(bb,Init);
          New(bb1,Init);
          For k:=1 To (Find[c]+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,4);
                 bb^.Dat.Kod:={IntToStr(c,Cone)}s;
                 bb1^.Dat.Kod:={IntToStr(c,Cone)}StrToInt(s);
                 bb^.Dat.Employ:=False;
                 bb1^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                 Seek(eb1,FileSize(eb1));
                 Write(eb1,bb1^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
          Dispose(bb1,Done);
          r:=Ioresult;
          Close(Eb1);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ExtendedMake:=False;
                 MessageBox(^M+#3'Ошибка открытия файла поставщиков группы '+IntToStr(c,COne)+' Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End
 End;{Logik}
End;{For по результатам анализа}
NoInfoMsg;
ExtendedMake:=True;
End;{Procedure}



Function ExtendedGroup(P:PImportSuperMarketType):Boolean;
Var Find : FindMaxElement;
    Logik: LogikMaxElement;
     c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : GroupFileType;
    bb  : PGroupType;
    Maximum : LongInt;
Begin

Maximum:=0;

ExtendedGroup:=True;

{расчитываем максимальные позиции в разделах}
For c:=1 To P^.Dat.Amount Do
 Begin
  StRazd:=P^.Dat.Element[c].Baz.NGroupKod;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;

For c:=1 To P^.Dat.AmountS Do
 Begin
  StRazd:=P^.Dat.ElementS[c].Baz.NGroupKod;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;


For c:=1 To P^.Dat.AmountNS Do
 Begin
  StRazd:=P^.Dat.NSertif[c].Baz.NGroupKod;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;

DInfoMsg('Проверяю размерность базы групп...',True);

  Assign(Eb,Path^.Dat.ToSPR+'Group.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла групп!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ExtendedGroup:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CClientKod);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ExtendedGroup:=False;
                 MessageBox(^M+#3'Ошибка открытия файла групп Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
ExtendedGroup:=True;
End;{Procedure}




Function ExtendedMera(P:PImportSuperMarketType):Boolean;
Var Find : FindMaxElement;
    Logik: LogikMaxElement;
     c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : MeraFileType;
    bb  : PMeraType;
    Maximum : LongInt;
Begin

Maximum:=0;

ExtendedMera:=True;

{расчитываем максимальные позиции в разделах}
For c:=1 To P^.Dat.Amount Do
 Begin
  StRazd:=P^.Dat.Element[c].Baz.Mera;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;

For c:=1 To P^.Dat.AmountS Do
 Begin
  StRazd:=P^.Dat.ElementS[c].Baz.Mera;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;


For c:=1 To P^.Dat.AmountNS Do
 Begin
  StRazd:=P^.Dat.NSertif[c].Baz.Mera;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;

DInfoMsg('Проверяю размерность базы единиц измерения...',True);

  Assign(Eb,Path^.Dat.ToSPR+'mera.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла единиц измерения!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ExtendedMera:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CClientKod);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ExtendedMera:=False;
                 MessageBox(^M+#3'Ошибка открытия файла единиц измерения Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
ExtendedMera:=True;
End;{Procedure}


Function TestExtendedMera(Maximum : LongInt):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : MeraFileType;
    bb  : PMeraType;
Begin
TestExtendedMera:=False;
DInfoMsg('Проверяю размерность базы единиц измерения...',True);
  Assign(Eb,Path^.Dat.ToSPR+'Mera.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия базы единиц измерения!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия базы единиц измерения Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
TestExtendedMera:=True;
End;{Procedure}







Function ExtendedPost(P:PImportSuperMarketType):Boolean;
Var Find : FindMaxElement;
    Logik: LogikMaxElement;
     c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : PostFileType;
    bb  : PPostType;
    Maximum : LongInt;
Begin

Maximum:=0;

ExtendedPost:=True;

{расчитываем максимальные позиции в разделах}
For c:=1 To P^.Dat.Amount Do
 Begin
  StRazd:=P^.Dat.Element[c].Baz.PostKod;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;

For c:=1 To P^.Dat.AmountS Do
 Begin
  StRazd:=P^.Dat.ElementS[c].Baz.PostKod;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;


For c:=1 To P^.Dat.AmountNS Do
 Begin
  StRazd:=P^.Dat.NSertif[c].Baz.PostKod;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;

DInfoMsg('Проверяю размерность базы стран...',True);

  Assign(Eb,Path^.Dat.ToSPR+'Lands.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла стран!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ExtendedPost:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CClientKod);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ExtendedPost:=False;
                 MessageBox(^M+#3'Ошибка открытия файла стран Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
ExtendedPost:=True;
End;{Procedure}





Function TestExtendedPost(Maximum : LongInt):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : PostFileType;
    bb  : PPostType;
Begin
TestExtendedPost:=False;
DInfoMsg('Проверяю размерность базы стран...',True);
  Assign(Eb,Path^.Dat.ToSPR+'Lands.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла стран!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия файла стран Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
TestExtendedPost:=True;
End;{Procedure}




Function ExtendedFirmaPost(P:PImportSuperMarketType):Boolean;
Var Find : FindMaxElement;
    Logik: LogikMaxElement;
     c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : FirmaPostFileType;
    bb  : PFirmaPostType;
    Maximum : LongInt;
Begin

Maximum:=0;

ExtendedFirmaPost:=True;

{расчитываем максимальные позиции в разделах}
For c:=1 To P^.Dat.Amount Do
 Begin
  StRazd:=P^.Dat.Element[c].Baz.FirmaPostKod;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;

For c:=1 To P^.Dat.AmountS Do
 Begin
  StRazd:=P^.Dat.ElementS[c].Baz.FirmaPostKod;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;


For c:=1 To P^.Dat.AmountNS Do
 Begin
  StRazd:=P^.Dat.NSertif[c].Baz.FirmaPostKod;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;

DInfoMsg('Проверяю размерность базы фирм-производителей...',True);

  Assign(Eb,Path^.Dat.ToSPR+'firma.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла фирм!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ExtendedFirmaPost:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CClientKod);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ExtendedFirmaPost:=False;
                 MessageBox(^M+#3'Ошибка открытия файла фирм Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
ExtendedFirmaPost:=True;
End;{Procedure}


Function TestExtendedFirmaPost(Maximum : LongInt):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : FirmaPostFileType;
    bb  : PFirmaPostType;
Begin
TestExtendedFirmaPost:=False;
DInfoMsg('Проверяю размерность базы фирм...',True);
  Assign(Eb,Path^.Dat.ToSPR+'firma.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла фирм!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия файла фирм Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
TestExtendedFirmaPost:=True;
End;{Procedure}






Function ExtendedKSertif(P:PImportSuperMarketType):Boolean;
Var Find : FindMaxElement;
    Logik: LogikMaxElement;
     c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : KSertifFileType;
    bb  : PKSertifType;
    Maximum : LongInt;
Begin

Maximum:=0;

ExtendedKSertif:=True;

{расчитываем максимальные позиции в разделах}
For c:=1 To P^.Dat.Amount Do
 Begin
  StRazd:=P^.Dat.Element[c].Baz.KSertif;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;

For c:=1 To P^.Dat.AmountS Do
 Begin
  StRazd:=P^.Dat.ElementS[c].Baz.KSertif;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;


For c:=1 To P^.Dat.AmountNS Do
 Begin
  StRazd:=P^.Dat.NSertif[c].Baz.KSertif;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;

DInfoMsg('Проверяю размерность базы органов сертификации...',True);

  Assign(Eb,Path^.Dat.ToSPR+'ksertif.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ExtendedKSertif:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CClientKod);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ExtendedKSertif:=False;
                 MessageBox(^M+#3'Ошибка открытия файла Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
ExtendedKSertif:=True;
End;{Procedure}


Function TestExtendedKSertif(Maximum : LongInt):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : KSertifFileType;
    bb  : PKSertifType;
Begin
TestExtendedKSertif:=False;
DInfoMsg('Проверяю размерность базы органов сертификации...',True);
  Assign(Eb,Path^.Dat.ToSPR+'kSertif.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла органов сертификации!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия файла органов сертификации Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
TestExtendedKSertif:=True;
End;{Procedure}



Function ExtendedClass(P:PImportSuperMarketType):Boolean;
Var Find : FindMaxElement;
    Logik: LogikMaxElement;
     c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : ClassFileType;
    bb  : PClassificatorBuchType;
    Maximum : LongInt;
Begin

Maximum:=0;

ExtendedClass:=True;

{расчитываем максимальные позиции в разделах}
For c:=1 To P^.Dat.Amount Do
 Begin
  StRazd:=P^.Dat.Element[c].Baz.Class;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;

For c:=1 To P^.Dat.AmountS Do
 Begin
  StRazd:=P^.Dat.ElementS[c].Baz.Class;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;


For c:=1 To P^.Dat.AmountNS Do
 Begin
  StRazd:=P^.Dat.NSertif[c].Baz.Class;
  RFormatZerro(StRazd,CClientKod);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;

DInfoMsg('Проверяю размерность базы классов бухгалтерии...',True);

  Assign(Eb,Path^.Dat.ToSPR+'Class.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ExtendedClass:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CClientKod);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ExtendedClass:=False;
                 MessageBox(^M+#3'Ошибка открытия файла Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
ExtendedClass:=True;
End;{Procedure}


Function TestExtendedClass(Maximum : LongInt):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : ClassFileType;
    bb  : PClassificatorBuchType;
Begin
TestExtendedClass:=False;
DInfoMsg('Проверяю размерность базы классов бухгалтерии...',True);
  Assign(Eb,Path^.Dat.ToSPR+'class.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла классов бухгалтерии!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CClientKod);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия файла классов бухгалтерии Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
TestExtendedClass:=True;
End;{Procedure}



Function TestExtendedKassa(Maximum : LongInt):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : KassaOperationFileType;
    bb  : PKassaOperationType;
Begin
TestExtendedKassa:=False;
DInfoMsg('Проверяю размерность базы кассовых операций...',True);
  Assign(Eb,Path^.Dat.ToSPR+'kassa.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла кассовых операций!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CClientKod);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия файла кассовых операций Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
TestExtendedKassa:=True;
End;{Procedure}


Function TestExtendedPersonal(Maximum : LongInt):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : PersonalFileType;
    bb  : PPersonalType;
Begin
TestExtendedPersonal:=False;
DInfoMsg('Проверяю размерность базы персонала...',True);
  Assign(Eb,Path^.Dat.ToSPR+'personal.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла персонала!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CClientKod);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия файла персонала Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
TestExtendedPersonal:=True;
End;{Procedure}


Function TestExtendedBank(Maximum : LongInt):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : BankFileType;
    bb  : PBankType;
Begin
TestExtendedBank:=False;
DInfoMsg('Проверяю размерность базы банков...',True);
  Assign(Eb,Path^.Dat.ToSPR+'Banks.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия базы банков!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,CClientKod);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия базы банков Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
TestExtendedBank:=True;
End;{Procedure}




Function ExtendedMarka(P:PImportSuperMarketType):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : MarkaFileType;
    bb  : PMarkaType;
    Maximum : LongInt;
Begin

Maximum:=0;

ExtendedMarka:=True;

{расчитываем максимальные позиции в разделах}
For c:=1 To P^.Dat.Amount Do
 Begin
  StRazd:=P^.Dat.Element[c].Input.Marka;
  RFormatZerro(StRazd,CArtikul);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;


DInfoMsg('Проверяю размерность базы акц.марок...',True);

  Assign(Eb,Path^.Dat.ToSPR+'marka.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла акц.марок!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ExtendedMarka:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:5,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ExtendedMarka:=False;
                 MessageBox(^M+#3'Ошибка открытия файла акц.марок Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
ExtendedMarka:=True;
End;{Procedure}


Function TestExtendedMarka(Maximum : LongInt):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : MarkaFileType;
    bb  : PMarkaType;
Begin
TestExtendedMarka:=False;
DInfoMsg('Проверяю размерность базы акц.марок...',True);
  Assign(Eb,Path^.Dat.ToSPR+'Marka.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла акц.марок!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:5,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия файла акц.марок Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
TestExtendedMarka:=True;
End;{Procedure}




Function ExtendedNGTD(P:PImportSuperMarketType):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : NGTDFileType;
    bb  : PNGTDType;
    Maximum : LongInt;
Begin

Maximum:=0;

ExtendedNGTD:=True;

{расчитываем максимальные позиции в разделах}
For c:=1 To P^.Dat.Amount Do
 Begin
  StRazd:=P^.Dat.Element[c].Input.NGTD;
  RFormatZerro(StRazd,CArtikul);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;


DInfoMsg('Проверяю размерность базы ГТД...',True);

  Assign(Eb,Path^.Dat.ToSPR+'NGTD.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла ГТД!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ExtendedNGTD:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:5,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ExtendedNGTD:=False;
                 MessageBox(^M+#3'Ошибка открытия файла ГТД Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
ExtendedNGTD:=True;
End;{Procedure}


Function TestExtendedNGTD(Maximum : LongInt):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : NGTDFileType;
    bb  : PNGTDType;
Begin
TestExtendedNGTD:=False;
DInfoMsg('Проверяю размерность базы ГТД...',True);
  Assign(Eb,Path^.Dat.ToSPR+'NGTD.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла ГТД!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:5,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия файла ГТД Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
TestExtendedNGTD:=True;
End;{Procedure}



Function TestExtendedSpecMarka(Maximum:LongInt):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : SpecMarkaFileType;
    bb  : PSpecMarkaType;
Begin
TestExtendedSpecMarka:=False;

DInfoMsg('Проверяю размерность базы спец.марок...',True);

  Assign(Eb,Path^.Dat.ToSPR+'SMarka.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла с.марок!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:5,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия файла c.марок Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
TestExtendedSpecMarka:=True;
End;{Procedure}




Function ExtendedSpecMarka(P:PImportSuperMarketType):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : SpecMarkaFileType;
    bb  : PSpecMarkaType;
    Maximum : LongInt;
Begin
Maximum:=0;
ExtendedSpecMarka:=True;

{расчитываем максимальные позиции в разделах}
For c:=1 To P^.Dat.Amount Do
 Begin
  StRazd:=P^.Dat.Element[c].Input.SpecMarka;
  RFormatZerro(StRazd,CArtikul);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;


DInfoMsg('Проверяю размерность базы спец.марок...',True);

  Assign(Eb,Path^.Dat.ToSPR+'SMarka.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла с.марок!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ExtendedSpecMarka:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:5,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ExtendedSpecMarka:=False;
                 MessageBox(^M+#3'Ошибка открытия файла c.марок Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
ExtendedSpecMarka:=True;
End;{Procedure}


Function ExtendedExpert(P:PImportSuperMarketType):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : ExpertFileType;
    bb  : PExpertType;
    Maximum : LongInt;
Begin
Maximum:=0;
ExtendedExpert:=True;

{расчитываем максимальные позиции в разделах}
For c:=1 To P^.Dat.Amount Do
 Begin
  StRazd:=P^.Dat.Element[c].Input.Expert;
  RFormatZerro(StRazd,CArtikul);
  SArt:=StRAzd;
  If MAximum<StrToInt(SArt) Then Maximum:=StrToInt(SArt);
 End;


DInfoMsg('Проверяю размерность базы ...',True);

  Assign(Eb,Path^.Dat.ToSPR+'Expert.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла э.заключений!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ExtendedExpert:=False;
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:5,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ExtendedExpert:=False;
                 MessageBox(^M+#3'Ошибка открытия файла эксп.заключений Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
ExtendedExpert:=True;
End;{Procedure}


Function TestExtendedExpert(Maximum:LongInt):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : ExpertFileType;
    bb  : PExpertType;
Begin
TestExtendedExpert:=False;


DInfoMsg('Проверяю размерность базы ...',True);

  Assign(Eb,Path^.Dat.ToSPR+'Expert.db');
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла э.заключений!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   Exit;
  End;

  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (Maximum+1)>(Max) Then
   Begin
         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (Maximum+1-MAx) Do
                Begin
                 Str(k+MAx-1:5,S);
                 RFormatZerro(s,CArtikul);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 MessageBox(^M+#3'Ошибка открытия файла эксп.заключений Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;

NoInfoMsg;
TestExtendedExpert:=True;
End;{Procedure}






Function ExtendedBases(Pref:Char;MaxKod:ArtikulStr):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : ClientFileType;
    bb  : PClientType;
    Paths1,Paths2 : String;
    Eb1  : KurzClientFileType;
    bb1  : PKurzClientType;

Begin
ExtendedBases:=True;
DInfoMsg('Проверяю размерность баз контрагентов...',False);
 Paths1[0]:=#0;
 Paths2[0]:=#0;

  Case Pref Of
  ClientPrefix:Begin
                Paths1:=Path^.Dat.ToClient+'Client.Db';
                Paths2:=Path^.Dat.ToClientBAseIndex+'Client.idx';
               End;
  MakePrefix:Begin
                Paths1:=Path^.Dat.ToClient+'Make.Db';
                Paths2:=Path^.Dat.ToClientBAseIndex+'Make.idx';
               End;
  BarterPrefix:Begin
                Paths1:=Path^.Dat.ToClient+'Barter.Db';
                Paths2:=Path^.Dat.ToClientBaseIndex+'Barter.idx';
               End;
  AgentPrefix :Begin
                Paths1:=Path^.Dat.ToClient+'Agent.Db';
                Paths2:=Path^.Dat.ToClientBaseIndex+'Agent.idx';
               End;
  SkladPrefix :Begin
                Paths1:=Path^.Dat.ToClient+'Sklad.Db';
                Paths2:=Path^.Dat.ToClientBaseIndex+'Sklad.idx';
               End;
  EkspeditorPrefix :Begin
                Paths1:=Path^.Dat.ToClient+'Eksped.Db';
                Paths2:=Path^.Dat.ToClientBaseIndex+'Eksped.idx';
               End;
Else
  Begin
   NoNetInfoMsg;
   exit;
  End;
  End;


  Assign(Eb,Paths1);
  Assign(Eb1,Paths2);
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла '+Paths1+'!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ExtendedBases:=False;
   Exit;
  End;

  {определяем максимальную позицию в файле}
  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (StrToInt(MaxKod)+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         Reset(Eb1);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          Seek(Eb1,FileSize(Eb1));
          New(bb,Init);
          New(bb1,Init);
          For k:=1 To (StrToInt(MaxKod)+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,4);
                 bb^.Dat.Kod:=s;
                 bb1^.Dat.Kod:=StrToInt(s);
                 bb^.Dat.Employ:=False;
                 bb1^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                 Seek(eb1,FileSize(eb1));
                 Write(eb1,bb1^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
          Dispose(bb1,Done);
          r:=Ioresult;
          Close(Eb1);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ExtendedBAses:=False;
                 MessageBox(^M+#3'Ошибка открытия файла '+Paths1+' Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;
NoInfoMsg;
ExtendedBAses:=True;
End;{Procedure}


Function ExtendedBases2(Pref:Char;MaxKod:ArtikulStr):Boolean;
Var c1,c,k,r : Word;
    s,stRazd,SArt : ArtikulStr;
    Max : LongInt;
    Eb  : RegionFileType;
    bb  : PRegionType;
    Paths1 : String;

Begin
ExtendedBases2:=True;
DInfoMsg('Проверяю размерность баз регионов, групп, маршрутов...',False);
 Paths1[0]:=#0;

  Case Pref Of
  GroupPrefix:Begin
                Paths1:=Path^.Dat.ToSPR+'Group.Db';
               End;
  RegionPrefix:Begin
                Paths1:=Path^.Dat.ToSPR+'Region.Db';
               End;
  RoutePrefix:Begin
                Paths1:=Path^.Dat.ToSPR+'Route.Db';
               End;
Else
  Begin
   NoNetInfoMsg;
   exit;
  End;
  End;


  Assign(Eb,Paths1);
  k:=IOResult;
  Reset(Eb);
  k:=IOResult;
  If k<>0 Then
  Begin
   NoInfoMsg;
   MessageBox(^M+#3'Ошибка открытия файла '+Paths1+'!'^M+
   +#3' Код: '+IntToStr(k,CLitrMantissa)+'. '+ClicProgrammer^,nil,mfError+mfCancelButton);
   ExtendedBases2:=False;
   Exit;
  End;

  {определяем максимальную позицию в файле}
  Max:=FileSize(Eb);
  k:=IOResult;
  Close(Eb);
  k:=IOResult;

  If (StrToInt(MaxKod)+1)>(Max) Then
   Begin

         r:=Ioresult;
         Reset(Eb);
         r:=Ioresult;

         If r=0 Then
         Begin
          Seek(Eb,FileSize(Eb));
          New(bb,Init);
          For k:=1 To (StrToInt(MaxKod)+1-MAx) Do
                Begin
                 Str(k+MAx-1:4,S);
                 RFormatZerro(s,4);
                 bb^.Dat.Kod:=s;
                 bb^.Dat.Employ:=False;
                 Seek(eb,FileSize(eb));
                 Write(eb,bb^.Dat);
                End;
          Dispose(bb,Done);
          r:=Ioresult;
          Close(Eb);
          r:=Ioresult;
         End{If}
          Else
                Begin
                 NoInfoMsg;
                 ExtendedBAses2:=False;
                 MessageBox(^M+#3'Ошибка открытия файла '+Paths1+' Код: '+
                          IntToStr(r,CLitrMantissa)
                 ,Nil,mfError+mfCancelButton);
                 Exit;
                End;{Else}
     End;
NoInfoMsg;
ExtendedBAses2:=True;
End;{Procedure}



Procedure AddKSertifAuto(pp:String);
Var f,fnew : File of KSertifType;
    cl,cl1 : KSertifType;
    Pos,l : LongInt;
    Code : Integer;
    s,Paths : String;
    Pref : Char;
    st : ArtikulStr;
    Result : Integer;
    SKod   : AllStr;
Begin
{
 определяем префикс
 распаковываем из архива
 открываем файл
 читаем из него данные
 открываем корреспондирующую базу определяемую по префиксу
 пишем в нее
 закрываем ее
 Ок!
}
 Pref:=pp[1];{префикс объекта}
 SKod:=Copy(pp,1+1,CClientKod);
 DInfoNetMsg('Обрабатываю изменения '+pp+'...');
 Paths[0]:=#0;
 Paths:=Path^.Dat.ToSPR+'KSertif.db';

{распаковываем файл}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'+{-av-}' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' '+
  Path^.Dat.ToTemp{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

{открываем корреспондирующую базу}
 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  Exit;
 End;


{открываем распакованный файл}
 Assign (FNew,Path^.Dat.ToTemp+pp);
 l:=IOResult;
 Reset(fnew);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Path^.Dat.ToTemp+pp,nil,mfError+mfCancelButton);
  Exit;
 End;


 Read(fnew,Cl);
 l:=IOResult;
 Close(FNew);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

 Assign (FNew,PathExpImp^.Dat.ToImport[1]+pp);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

   DelSpace(SKod);

   l:=StrToInt(SKod);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к органу сертификации ('+SKod+')- позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(KSertifType),SizeOf(KSertifType));{предварительная блокировка}

   L:=IOResult;
   Cl.Rcd:=False;

      Seek(f,Pos);
      Write(f,Cl);
      L:=IOResult;
      Repeat
      Unlock(f,Pos*SizeOf(KSertifType),SizeOf(KSertifType));
      Until DosError=0;
      L:=IOResult;
      Close(f);
      L:=IOResult;

      NoNetInfoMsg;
      AddProtocolNoMsg('Добавление органа сертификации '+pp+' успешно завершено!','','');
End;



Procedure AddClassAuto(pp:String);
Var f,fnew : File of ClassificatorBuchType;
    cl,cl1 : ClassificatorBuchType;
    Pos,l : LongInt;
    Code : Integer;
    s,Paths : String;
    Pref : Char;
    st : ArtikulStr;
    Result : Integer;
    SKod   : AllStr;
Begin
{
 определяем префикс
 распаковываем из архива
 открываем файл
 читаем из него данные
 открываем корреспондирующую базу определяемую по префиксу
 пишем в нее
 закрываем ее
 Ок!
}
 Pref:=pp[1];{префикс объекта}
 SKod:=Copy(pp,1+1,CClientKod);
 DInfoNetMsg('Обрабатываю изменения '+pp+'...');
 Paths[0]:=#0;
 Paths:=Path^.Dat.ToSPR+'Class.db';

{распаковываем файл}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'{ -av-}+' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' '+
  Path^.Dat.ToTemp{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

{открываем корреспондирующую базу}
 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  Exit;
 End;


{открываем распакованный файл}
 Assign (FNew,Path^.Dat.ToTemp+pp);
 l:=IOResult;
 Reset(fnew);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Path^.Dat.ToTemp+pp,nil,mfError+mfCancelButton);
  Exit;
 End;


 Read(fnew,Cl);
 l:=IOResult;
 Close(FNew);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

 Assign (FNew,PathExpImp^.Dat.ToImport[1]+pp);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

   DelSpace(SKod);

   l:=StrToInt(SKod);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к классу ('+SKod+')- позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(ClassificatorBuchType),SizeOf(ClassificatorBuchType));{предварительная блокировка}

   L:=IOResult;
   Cl.Rcd:=False;

      Seek(f,Pos);
      Write(f,Cl);
      L:=IOResult;
      Repeat
      Unlock(f,Pos*SizeOf(ClassificatorBuchType),SizeOf(ClassificatorBuchType));
      Until DosError=0;
      L:=IOResult;
      Close(f);
      L:=IOResult;

      NoNetInfoMsg;
      AddProtocolNoMsg('Добавление класса '+pp+' успешно завершено!','','');
End;



Procedure AddKassaAuto(pp:String);
Var f,fnew : File of KassaOperationType;
    cl,cl1 : KassaOperationType;
    Pos,l : LongInt;
    Code : Integer;
    s,Paths : String;
    Pref : Char;
    st : ArtikulStr;
    Result : Integer;
    SKod   : AllStr;
Begin
{
 определяем префикс
 распаковываем из архива
 открываем файл
 читаем из него данные
 открываем корреспондирующую базу определяемую по префиксу
 пишем в нее
 закрываем ее
 Ок!
}
 Pref:=pp[1];{префикс объекта}
 SKod:=Copy(pp,1+1,CClientKod);
 DInfoNetMsg('Обрабатываю изменения '+pp+'...');
 Paths[0]:=#0;
 Paths:=Path^.Dat.ToSPR+'Kassa.db';

{распаковываем файл}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'{ -av-}+' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' '+
  Path^.Dat.ToTemp{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

{открываем корреспондирующую базу}
 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  Exit;
 End;


{открываем распакованный файл}
 Assign (FNew,Path^.Dat.ToTemp+pp);
 l:=IOResult;
 Reset(fnew);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Path^.Dat.ToTemp+pp,nil,mfError+mfCancelButton);
  Exit;
 End;


 Read(fnew,Cl);
 l:=IOResult;
 Close(FNew);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

 Assign (FNew,PathExpImp^.Dat.ToImport[1]+pp);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

   DelSpace(SKod);

   l:=StrToInt(SKod);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к кассовой операции ('+SKod+')- позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(KassaOperationType),SizeOf(KassaOperationType));{предварительная блокировка}

   L:=IOResult;
   Cl.Rcd:=False;

      Seek(f,Pos);
      Write(f,Cl);
      L:=IOResult;
      Repeat
      Unlock(f,Pos*SizeOf(KassaOperationType),SizeOf(KassaOperationType));
      Until DosError=0;
      L:=IOResult;
      Close(f);
      L:=IOResult;

      NoNetInfoMsg;
      AddProtocolNoMsg('Добавление кассовой операции '+pp+' успешно завершено!','','');
End;


Procedure AddPersonalAuto(pp:String);
Var f,fnew : File of PersonalType;
    cl,cl1 : PersonalType;
    Pos,l : LongInt;
    Code : Integer;
    s,Paths : String;
    Pref : Char;
    st : ArtikulStr;
    Result : Integer;
    SKod   : AllStr;
Begin
{
 определяем префикс
 распаковываем из архива
 открываем файл
 читаем из него данные
 открываем корреспондирующую базу определяемую по префиксу
 пишем в нее
 закрываем ее
 Ок!
}
 Pref:=pp[1];{префикс объекта}
 SKod:=Copy(pp,1+1,CClientKod);
 DInfoNetMsg('Обрабатываю изменения '+pp+'...');
 Paths[0]:=#0;
 Paths:=Path^.Dat.ToSPR+'Personal.db';

{распаковываем файл}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'{ -av-}+' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' '+
  Path^.Dat.ToTemp{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

{открываем корреспондирующую базу}
 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  Exit;
 End;


{открываем распакованный файл}
 Assign (FNew,Path^.Dat.ToTemp+pp);
 l:=IOResult;
 Reset(fnew);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Path^.Dat.ToTemp+pp,nil,mfError+mfCancelButton);
  Exit;
 End;


 Read(fnew,Cl);
 l:=IOResult;
 Close(FNew);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

 Assign (FNew,PathExpImp^.Dat.ToImport[1]+pp);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

   DelSpace(SKod);

   l:=StrToInt(SKod);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к сотруднику ('+SKod+')- позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(PersonalType),SizeOf(PersonalType));{предварительная блокировка}

   L:=IOResult;
   Cl.Rcd:=False;

      Seek(f,Pos);
      Write(f,Cl);
      L:=IOResult;
      Repeat
      Unlock(f,Pos*SizeOf(PersonalType),SizeOf(PersonalType));
      Until DosError=0;
      L:=IOResult;
      Close(f);
      L:=IOResult;

      NoNetInfoMsg;
      AddProtocolNoMsg('Добавление сотрудника '+pp+' успешно завершено!','','');
End;


Procedure AddBankAuto(pp:String);
Var f,fnew : File of BankType;
    cl,cl1 : BankType;
    Pos,l : LongInt;
    Code : Integer;
    s,Paths : String;
    Pref : Char;
    st : ArtikulStr;
    Result : Integer;
    SKod   : AllStr;
Begin
{
 определяем префикс
 распаковываем из архива
 открываем файл
 читаем из него данные
 открываем корреспондирующую базу определяемую по префиксу
 пишем в нее
 закрываем ее
 Ок!
}
 Pref:=pp[1];{префикс объекта}
 SKod:=Copy(pp,1+1,CClientKod);
 DInfoNetMsg('Обрабатываю изменения '+pp+'...');
 Paths[0]:=#0;
 Paths:=Path^.Dat.ToSPR+'Banks.db';

{распаковываем файл}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'{ -av-}+' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' '+
  Path^.Dat.ToTemp{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

{открываем корреспондирующую базу}
 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  Exit;
 End;


{открываем распакованный файл}
 Assign (FNew,Path^.Dat.ToTemp+pp);
 l:=IOResult;
 Reset(fnew);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Path^.Dat.ToTemp+pp,nil,mfError+mfCancelButton);
  Exit;
 End;


 Read(fnew,Cl);
 l:=IOResult;
 Close(FNew);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

 Assign (FNew,PathExpImp^.Dat.ToImport[1]+pp);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

   DelSpace(SKod);

   l:=StrToInt(SKod);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к банку ('+SKod+')- позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(BankType),SizeOf(BankType));{предварительная блокировка}

   L:=IOResult;
   Cl.Rcd:=False;

      Seek(f,Pos);
      Write(f,Cl);
      L:=IOResult;
      Repeat
      Unlock(f,Pos*SizeOf(BankType),SizeOf(BankType));
      Until DosError=0;
      L:=IOResult;
      Close(f);
      L:=IOResult;

      NoNetInfoMsg;
      AddProtocolNoMsg('Добавление банка '+pp+' успешно завершено!','','');
End;




Procedure AddMeraAuto(pp:String);
Var f,fnew : File of MeraType;
    cl,cl1 : MeraType;
    Pos,l : LongInt;
    Code : Integer;
    s,Paths : String;
    Pref : Char;
    st : ArtikulStr;
    Result : Integer;
    SKod   : AllStr;
Begin
{определяем префикс
 распаковываем из архива
 открываем файл
 читаем из него данные
 открываем корреспондирующую базу определяемую по префиксу
 пишем в нее
 закрываем ее
 Ок!}
 Pref:=pp[1];{префикс объекта}
 SKod:=Copy(pp,1+1,CClientKod);
 DInfoNetMsg('Обрабатываю изменения '+pp+'...');
 Paths[0]:=#0;
 Paths:=Path^.Dat.ToSPR+'Mera.db';

{распаковываем файл}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'{ -av-}+' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' '+
  Path^.Dat.ToTemp{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

{открываем корреспондирующую базу}
 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  Exit;
 End;


{открываем распакованный файл}
 Assign (FNew,Path^.Dat.ToTemp+pp);
 l:=IOResult;
 Reset(fnew);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Path^.Dat.ToTemp+pp,nil,mfError+mfCancelButton);
  Exit;
 End;


 Read(fnew,Cl);
 l:=IOResult;
 Close(FNew);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

 Assign (FNew,PathExpImp^.Dat.ToImport[1]+pp);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

   DelSpace(SKod);

   l:=StrToInt(SKod);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к единице измерения ('+SKod+')- позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(MeraType),SizeOf(MeraType));{предварительная блокировка}

   L:=IOResult;
   Cl.Rcd:=False;

      Seek(f,Pos);
      Write(f,Cl);
      L:=IOResult;
      Repeat
      Unlock(f,Pos*SizeOf(MeraType),SizeOf(MeraType));
      Until DosError=0;
      L:=IOResult;
      Close(f);
      L:=IOResult;

      NoNetInfoMsg;
      AddProtocolNoMsg('Добавление единицы измерения '+pp+' успешно завершено!','','');
End;



Procedure AddFirmaPostAuto(pp:String);
Var f,fnew : File of FirmaPostType;
    cl,cl1 : FirmaPostType;
    Pos,l : LongInt;
    Code : Integer;
    s,Paths : String;
    Pref : Char;
    st : ArtikulStr;
    Result : Integer;
    SKod   : AllStr;
Begin
{
 определяем префикс
 распаковываем из архива
 открываем файл
 читаем из него данные
 открываем корреспондирующую базу определяемую по префиксу
 пишем в нее
 закрываем ее
 Ок!
}
 Pref:=pp[1];{префикс объекта}
 SKod:=Copy(pp,1+1,CClientKod);
 DInfoNetMsg('Обрабатываю изменения '+pp+'...');
 Paths[0]:=#0;
 Paths:=Path^.Dat.ToSPR+'Firma.db';

{распаковываем файл}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'{ -av-}+' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' '+
  Path^.Dat.ToTemp{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

{открываем корреспондирующую базу}
 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  Exit;
 End;


{открываем распакованный файл}
 Assign (FNew,Path^.Dat.ToTemp+pp);
 l:=IOResult;
 Reset(fnew);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Path^.Dat.ToTemp+pp,nil,mfError+mfCancelButton);
  Exit;
 End;


 Read(fnew,Cl);
 l:=IOResult;
 Close(FNew);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

 Assign (FNew,PathExpImp^.Dat.ToImport[1]+pp);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

   DelSpace(SKod);

   l:=StrToInt(SKod);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к фирме ('+SKod+')- позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(FirmaPostType),SizeOf(FirmaPostType));{предварительная блокировка}

   L:=IOResult;
   Cl.Rcd:=False;

      Seek(f,Pos);
      Write(f,Cl);
      L:=IOResult;
      Repeat
      Unlock(f,Pos*SizeOf(FirmaPostType),SizeOf(FirmaPostType));
      Until DosError=0;
      L:=IOResult;
      Close(f);
      L:=IOResult;

      NoNetInfoMsg;
      AddProtocolNoMsg('Добавление фирмы '+pp+' успешно завершено!','','');
End;


Procedure AddPostAuto(pp:String);
Var f,fnew : File of PostType;
    cl,cl1 : PostType;
    Pos,l : LongInt;
    Code : Integer;
    s,Paths : String;
    Pref : Char;
    st : ArtikulStr;
    Result : Integer;
    SKod   : AllStr;
Begin
{
 определяем префикс
 распаковываем из архива
 открываем файл
 читаем из него данные
 открываем корреспондирующую базу определяемую по префиксу
 пишем в нее
 закрываем ее
 Ок!
}
 Pref:=pp[1];{префикс объекта}
 SKod:=Copy(pp,1+1,CClientKod);
 DInfoNetMsg('Обрабатываю изменения '+pp+'...');
 Paths[0]:=#0;
 Paths:=Path^.Dat.ToSPR+'Lands.db';

{распаковываем файл}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'{ -av-}+' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' '+
  Path^.Dat.ToTemp{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

{открываем корреспондирующую базу}
 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  Exit;
 End;


{открываем распакованный файл}
 Assign (FNew,Path^.Dat.ToTemp+pp);
 l:=IOResult;
 Reset(fnew);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Path^.Dat.ToTemp+pp,nil,mfError+mfCancelButton);
  Exit;
 End;


 Read(fnew,Cl);
 l:=IOResult;
 Close(FNew);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

 Assign (FNew,PathExpImp^.Dat.ToImport[1]+pp);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

   DelSpace(SKod);

   l:=StrToInt(SKod);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к стране ('+SKod+')- позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(PostType),SizeOf(PostType));{предварительная блокировка}

   L:=IOResult;
   Cl.Rcd:=False;

      Seek(f,Pos);
      Write(f,Cl);
      L:=IOResult;
      Repeat
      Unlock(f,Pos*SizeOf(PostType),SizeOf(PostType));
      Until DosError=0;
      L:=IOResult;
      Close(f);
      L:=IOResult;

      NoNetInfoMsg;
      AddProtocolNoMsg('Добавление страны '+pp+' успешно завершено!','','');
End;


Procedure AddNGTDAuto(pp:String);
Var f,fnew : File of NGTDType;
    cl,cl1 : NGTDType;
    Pos,l : LongInt;
    Code : Integer;
    s,Paths : String;
    Pref : Char;
    st : ArtikulStr;
    Result : Integer;
    SKod   : AllStr;
Begin
{
 определяем префикс
 распаковываем из архива
 открываем файл
 читаем из него данные
 открываем корреспондирующую базу определяемую по префиксу
 пишем в нее
 закрываем ее
 Ок!
 }
 Pref:=pp[1];{префикс объекта}
 SKod:=Copy(pp,1+1,CArtikul);
 DInfoNetMsg('Обрабатываю изменения '+pp+'...');
 Paths[0]:=#0;
 Paths:=Path^.Dat.ToSPR+'ngtd.db';

{распаковываем файл}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'{ -av-}+' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' '+
  Path^.Dat.ToTemp{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

{открываем корреспондирующую базу}
 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  Exit;
 End;


{открываем распакованный файл}
 Assign (FNew,Path^.Dat.ToTemp+pp);
 l:=IOResult;
 Reset(fnew);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Path^.Dat.ToTemp+pp,nil,mfError+mfCancelButton);
  Exit;
 End;


 Read(fnew,Cl);
 l:=IOResult;
 Close(FNew);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

 Assign (FNew,PathExpImp^.Dat.ToImport[1]+pp);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

   DelSpace(SKod);

   l:=StrToInt(SKod);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к ГТД ('+SKod+')- позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(NGTDType),SizeOf(NGTDType));{предварительная блокировка}

   L:=IOResult;
   Cl.Rcd:=False;

      Seek(f,Pos);
      Write(f,Cl);
      L:=IOResult;
      Repeat
      Unlock(f,Pos*SizeOf(NGTDType),SizeOf(NGTDType));
      Until DosError=0;
      L:=IOResult;
      Close(f);
      L:=IOResult;

      NoNetInfoMsg;
      AddProtocolNoMsg('Добавление ГТД '+pp+' успешно завершено!','','');
End;


Procedure AddMarkaAuto(pp:String);
Var f,fnew : File of MarkaType;
    cl,cl1 : MarkaType;
    Pos,l : LongInt;
    Code : Integer;
    s,Paths : String;
    Pref : Char;
    st : ArtikulStr;
    Result : Integer;
    SKod   : AllStr;
Begin
{
 определяем префикс
 распаковываем из архива
 открываем файл
 читаем из него данные
 открываем корреспондирующую базу определяемую по префиксу
 пишем в нее
 закрываем ее
 Ок!
 }
 Pref:=pp[1];{префикс объекта}
 SKod:=Copy(pp,1+1,CArtikul);
 DInfoNetMsg('Обрабатываю изменения '+pp+'...');
 Paths[0]:=#0;
 Paths:=Path^.Dat.ToSPR+'Marka.db';

{распаковываем файл}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'{ -av-}+' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' '+
  Path^.Dat.ToTemp{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

{открываем корреспондирующую базу}
 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  Exit;
 End;


{открываем распакованный файл}
 Assign (FNew,Path^.Dat.ToTemp+pp);
 l:=IOResult;
 Reset(fnew);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Path^.Dat.ToTemp+pp,nil,mfError+mfCancelButton);
  Exit;
 End;


 Read(fnew,Cl);
 l:=IOResult;
 Close(FNew);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

 Assign (FNew,PathExpImp^.Dat.ToImport[1]+pp);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

   DelSpace(SKod);

   l:=StrToInt(SKod);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к акц.маркам ('+SKod+')- позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(MarkaType),SizeOf(MarkaType));{предварительная блокировка}

   L:=IOResult;
   Cl.Rcd:=False;

      Seek(f,Pos);
      Write(f,Cl);
      L:=IOResult;
      Repeat
      Unlock(f,Pos*SizeOf(MarkaType),SizeOf(MarkaType));
      Until DosError=0;
      L:=IOResult;
      Close(f);
      L:=IOResult;

      NoNetInfoMsg;
      AddProtocolNoMsg('Добавление акц.марки '+pp+' успешно завершено!','','');
End;


Procedure AddSpecMarkaAuto(pp:String);
Var f,fnew : File of SpecMarkaType;
    cl,cl1 : SpecMarkaType;
    Pos,l : LongInt;
    Code : Integer;
    s,Paths : String;
    Pref : Char;
    st : ArtikulStr;
    Result : Integer;
    SKod   : AllStr;
Begin
{
 определяем префикс
 распаковываем из архива
 открываем файл
 читаем из него данные
 открываем корреспондирующую базу определяемую по префиксу
 пишем в нее
 закрываем ее
 Ок!
 }
 Pref:=pp[1];{префикс объекта}
 SKod:=Copy(pp,1+1,CArtikul);
 DInfoNetMsg('Обрабатываю изменения '+pp+'...');
 Paths[0]:=#0;
 Paths:=Path^.Dat.ToSPR+'SMarka.db';

{распаковываем файл}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'{ -av-}+' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' '+
  Path^.Dat.ToTemp{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

{открываем корреспондирующую базу}
 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  Exit;
 End;


{открываем распакованный файл}
 Assign (FNew,Path^.Dat.ToTemp+pp);
 l:=IOResult;
 Reset(fnew);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Path^.Dat.ToTemp+pp,nil,mfError+mfCancelButton);
  Exit;
 End;


 Read(fnew,Cl);
 l:=IOResult;
 Close(FNew);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

 Assign (FNew,PathExpImp^.Dat.ToImport[1]+pp);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

   DelSpace(SKod);

   l:=StrToInt(SKod);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к спец.маркам ('+SKod+')- позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType));{предварительная блокировка}

   L:=IOResult;
   Cl.Rcd:=False;

      Seek(f,Pos);
      Write(f,Cl);
      L:=IOResult;
      Repeat
      Unlock(f,Pos*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType));
      Until DosError=0;
      L:=IOResult;
      Close(f);
      L:=IOResult;

      NoNetInfoMsg;
      AddProtocolNoMsg('Добавление спец.марки '+pp+' успешно завершено!','','');
End;


Procedure AddExpertAuto(pp:String);
Var f,fnew : File of ExpertType;
    cl,cl1 : ExpertType;
    Pos,l : LongInt;
    Code : Integer;
    s,Paths : String;
    Pref : Char;
    st : ArtikulStr;
    Result : Integer;
    SKod   : AllStr;
Begin
{
 определяем префикс
 распаковываем из архива
 открываем файл
 читаем из него данные
 открываем корреспондирующую базу определяемую по префиксу
 пишем в нее
 закрываем ее
 Ок!
}
 Pref:=pp[1];{префикс объекта}
 SKod:=Copy(pp,1+1,CArtikul);
 DInfoNetMsg('Обрабатываю изменения '+pp+'...');
 Paths[0]:=#0;
 Paths:=Path^.Dat.ToSPR+'Expert.db';

{распаковываем файл}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'{ -av-}+' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' '+
  Path^.Dat.ToTemp{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

{открываем корреспондирующую базу}
 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  Exit;
 End;


{открываем распакованный файл}
 Assign (FNew,Path^.Dat.ToTemp+pp);
 l:=IOResult;
 Reset(fnew);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Path^.Dat.ToTemp+pp,nil,mfError+mfCancelButton);
  Exit;
 End;


 Read(fnew,Cl);
 l:=IOResult;
 Close(FNew);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

 Assign (FNew,PathExpImp^.Dat.ToImport[1]+pp);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

   DelSpace(SKod);

   l:=StrToInt(SKod);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к '+Expert_RegNom^+' ('+SKod+')- позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(ExpertType),SizeOf(ExpertType));{предварительная блокировка}

   L:=IOResult;
   Cl.Rcd:=False;

      Seek(f,Pos);
      Write(f,Cl);
      L:=IOResult;
      Repeat
      Unlock(f,Pos*SizeOf(ExpertType),SizeOf(ExpertType));
      Until DosError=0;
      L:=IOResult;
      Close(f);
      L:=IOResult;

      NoNetInfoMsg;
      AddProtocolNoMsg('Добавление эксп.заключ. '+pp+' успешно завершено!','','');
End;



Procedure AddContrAgent(pp:String);
Var fcopy,f,fnew : File of ClientType;
    FIdx : File Of KurzClientType;
    cl,cl1 : ClientType;
    ClIdx:KurzClientType;
    Pos,l : LongInt;
    Code : Integer;
    s,Paths,Paths2 : String;
    Pref : Char;
    st : ArtikulStr;
    AllSkl : Maska15;
    Result : Integer;
    SKod   : AllStr;
    OpenCopy : Boolean;
Begin
{определяем префикс
 распаковываем из архива
 открываем файл
 читаем из него данные
 открываем корреспондирующую базу определяемую по префиксу
 пишем в нее
 закрываем ее
 Ок!}
 Pref:=pp[1];{префикс объекта}
 SKod:=Copy(pp,1+1,CClientKod);
 DInfoNetMsg('Обрабатываю изменения '+pp+'...');
 Paths[0]:=#0;
 Paths2[0]:=#0;
Case Pref Of
  ClientPrefix:Begin
                Paths:=Path^.Dat.ToClient+'Client.db';
                Paths2:=Path^.Dat.ToClientBaseIndex+'Client.idx';
               End;
  MakePrefix  :Begin
                Paths:=Path^.Dat.ToClient+'Make.db';
                Paths2:=Path^.Dat.ToClientBaseIndex+'Make.idx';
               End;
  BarterPrefix:Begin
                Paths:=Path^.Dat.ToClient+'Barter.db';
                Paths2:=Path^.Dat.ToClientBaseIndex+'Barter.idx';
               End;
  AgentPrefix :Begin
                Paths:=Path^.Dat.ToClient+'Agent.db';
                Paths2:=Path^.Dat.ToClientBaseIndex+'Agent.idx';
               End;
  SkladPrefix :Begin
                Paths:=Path^.Dat.ToClient+'Sklad.db';
                Paths2:=Path^.Dat.ToClientBaseIndex+'Sklad.idx';
               End;
EkspeditorPrefix:Begin
                  Paths:=Path^.Dat.ToClient+'Eksped.db';
                  Paths2:=Path^.Dat.ToClientBaseIndex+'Eksped.idx';
                 End;
Else
  Begin
   NoNetInfoMsg;
   exit;
  End;
End;

{открываем корреспондирующую базу}
 OpenCopy:=True;
 Assign (FCopy,Path^.Dat.ToClient+Pref+SKod+'.cor');
 l:=IOResult;
 Reset(fCopy);
 l:=IOResult;
 If l <> 0 Then
 Begin
  l:=IOResult;
  Rewrite(fCopy);
  l:=IOResult;
  If l<>0 Then
   Begin
    OpenCopy:=False;
    MessageBox(^M+#3'Ошибка создания файла '+Path^.Dat.ToClient+Pref+SKod++'.cor',nil,mfError+mfCancelButton);
   End;
 End;

{распаковываем файл}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'{ -av-}+' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' '+
  Path^.Dat.ToTemp{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;

{распаковка комментариев по просьбе стаса}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'{ -av-}+' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' *.mcx '+Path^.Dat.ToClient{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;

  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

{открываем корреспондирующую базу}
 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  l:=IOResult;
  If OpenCopy Then Close(FCopy);
  l:=IOResult;
  Exit;
 End;

{открываем корреспондирующую базу}
 Assign (FIDX,Paths2);
 l:=IOResult;
 Reset(fIDX);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths2,nil,mfError+mfCancelButton);
  l:=IOResult;
  If OpenCopy Then Close(FCopy);
  l:=IOResult;
  Exit;
 End;

{открываем распакованный файл}
 Assign (FNew,Path^.Dat.ToTemp+pp);
 l:=IOResult;
 Reset(fnew);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  Close(fIdx);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Path^.Dat.ToTemp+pp,nil,mfError+mfCancelButton);
  l:=IOResult;
  If OpenCopy Then Close(FCopy);
  l:=IOResult;
  Exit;
 End;

 Read(fnew,Cl);
 l:=IOResult;
 Close(FNew);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;


 Assign (FNew,PathExpImp^.Dat.ToImport[1]+pp);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

   DelSpace(SKod);

   l:=StrToInt(SKod);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к контрагенту - позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     l:=IOResult;
     If OpenCopy Then Close(FCopy);
     l:=IOResult;
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(ClientType),SizeOf(ClientType));{предварительная блокировка}

   Read(f,cl1);

   L:=IOResult;

  With Cl Do {заполняем поля для IDX - файла}
  Begin
  ClIDX.Name:=Name;
  ClIDX.Inn:=Copy(Inn,1,CIZena);
  ClIDX.Kod:=StrToInt(Kod);
  ClIDX.Employ:=Employ;
  ClIDX.Status:=Status;
  ClIDX.Main:=Main;
  ClIDX.FantomKod:=StrToInt(FantomKod);
  ClIDX.RouteKod:=StrToInt(RouteKod);
  ClIDX.RegionKod:=StrToInt(RegionKod);
  End;

      Seek(fIdx,Pos);
      Write(fIdx,ClIdx);
      L:=IOResult;

   Cl.Rcd:=False;

      Seek(f,Pos);
      Write(f,Cl);
      L:=IOResult;


      If OpenCopy Then
       Begin
        L:=IOResult;
        Seek(FCopy,FileSize(FCopy));
        L:=IOResult;
     {проверяем корректировка это или добавление новой}
     If Cl1.Employ Then
      Begin
        Write(FCopy,Cl1);
        L:=IOResult;
      End;

        Close(FCopy);
       End;

      Repeat
      Unlock(f,Pos*SizeOf(ClientType),SizeOf(ClientType));
      Until DosError=0;
      L:=IOResult;
      Close(f);
      L:=IOResult;
      Close(fIdx);
      L:=IOResult;

      NoNetInfoMsg;
      AddProtocolNoMsg('Добавление контрагента '+pp+' успешно завершено!','','');
End;




Procedure AddContrAgent2(pp:String);
Var f,fnew : File of RegionType;
    cl,cl1 : RegionType;
    Pos,l : LongInt;
    Code : Integer;
    s,Paths : String;
    Pref : Char;
    st : ArtikulStr;
    Result : Integer;
    SKod   : AllStr;
Begin
{
 определяем префикс
 распаковываем из архива
 открываем файл
 читаем из него данные
 открываем корреспондирующую базу определяемую по префиксу
 пишем в нее
 закрываем ее
 Ок!
 }
 Pref:=pp[1];{префикс объекта}
 SKod:=Copy(pp,1+1,CClientKod);
 DInfoNetMsg('Обрабатываю изменения '+pp+'...');
 Paths[0]:=#0;
Case Pref Of
  GroupPrefix:Begin
                Paths:=Path^.Dat.ToSPR+'Group.db';
               End;
  RegionPrefix  :Begin
                Paths:=Path^.Dat.ToSPR+'Region.db';
               End;
  RoutePrefix  :Begin
                Paths:=Path^.Dat.ToSPR+'Route.db';
               End;
Else
  Begin
   NoNetInfoMsg;
   exit;
  End;
End;

{распаковываем файл}
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SWAPVECTORS;

  s:=Path^.Dat.ToUtils+'rar.exe e -inul -y'{ -av-}+' -ds -w'+Path^.Dat.ToTemp+' '+
  PathExpImp^.Dat.ToImport[1]+pp+' '+
  Path^.Dat.ToTemp{+' '+NullStr^};

  exec (GetEnv('Comspec'),' /c '+s);
  SWAPVECTORS;
  InitDosMem;
  InitEvents;
  InitSysError;
  Result:=DosError;
  CursorLines:=1543;
  Application^.Redraw;
  NoInfoMsg;

    Case Result Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
   Else
   End;

{открываем корреспондирующую базу}
 Assign (F,Paths);
 l:=IOResult;
 Reset(f);
 l:=IOResult;
 If l <> 0 Then
 Begin
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Paths,nil,mfError+mfCancelButton);
  Exit;
 End;


{открываем распакованный файл}
 Assign (FNew,Path^.Dat.ToTemp+pp);
 l:=IOResult;
 Reset(fnew);
 l:=IOResult;
 If l <> 0 Then
 Begin
  Close(f);
  NoNetInfoMsg;
  MessageBox(^M+#3'Ошибка сетевого открытия файла '+Path^.Dat.ToTemp+pp,nil,mfError+mfCancelButton);
  Exit;
 End;


 Read(fnew,Cl);
 l:=IOResult;
 Close(FNew);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

 Assign (FNew,PathExpImp^.Dat.ToImport[1]+pp);
 l:=IOResult;
 Erase(FNew);
 l:=IOResult;

   DelSpace(SKod);

   l:=StrToInt(SKod);

   If L>FileSize(f) Then
    Begin
     System.Close(f);
     NoNetInfoMsg;
     MessageBox(^M+#3'Обращение к группе, региону, маршруту - позиция вне файла '+Paths,nil,mfError+mfCancelButton);
     Exit;
    End;

   Seek(f,l);
   Pos:=FilePos(f);
   Repeat
   Pause(1);
   Until Lock(f,Pos*SizeOf(RegionType),SizeOf(RegionType));{предварительная блокировка}

   Read(f,cl1);

   L:=IOResult;

   Cl.Rcd:=False;
{$IFDEF NetVersion}
   {
   Cl.Locked:=Cl1.Locked;
   Cl.LockCaption:=Cl1.LockCaption;
   Cl.ComputerNameLocked:=Cl1.ComputerNameLocked;
   }
{$ENDIF}

      Seek(f,Pos);
      Write(f,Cl);
      L:=IOResult;
      Repeat
      Unlock(f,Pos*SizeOf(RegionType),SizeOf(RegionType));
      Until DosError=0;
      L:=IOResult;
      Close(f);
      L:=IOResult;

      NoNetInfoMsg;
      AddProtocolNoMsg('Добавление группы, региона, маршрута '+pp+' успешно завершено!','','');
End;


Procedure CalcNDS1(As:DocumentEditZ; FiltrOtdel:Maska8;Var NDS,NDS20,NDS10,NDS_,NDS18,NDS16,Litr:Real);

Var l : Word;
    k,j : Byte;
    s,ws,ws1 : String;
    st : String[CMantissa];
    ItogoLitr,PromItogoPos,ItogoPos,NDSPos : Real;
    Test : LongInt;
    RealZena,ITOGONDS_NP,SummaZena: String[CInputIZena];
    ItogNalog,Koefficient,pp : String[CPack];
    E,Lg : PSuperMarketType;
    BBB : PBazType;

Begin
   NDS:=0; NDSPos:=0; ItogoPos:=0;PromitogoPos:=0;
   NDS20:=0; NDS18:=0;NDS16:=0; NDS10:=0; NDS_:=0;Litr:=0;
   Koefficient[0]:=#0;

   New(E,Init);
   If Not(GEtMarket1(As,E)) Then
    Begin
     Dispose(E,Done);
     Exit;
    End;


   New(Lg,Init);
   k:=1;j:=1;

   For l:=1 To E^.Dat.Amount Do
    Begin
     If FiltrOtdel[E^.Dat.MarketElement[l].Input.DivisionNumber]=1 Then
     Begin
     If testMarketSF(E^.Dat.MarketElement[l].BazKod,Lg,j) Then
      Begin
       Str((StrToInt(Lg^.Dat.MarketElement[j].Input.Kol)+
            StrToInt( E^.Dat.MarketElement[l].Input.Kol)):CKol,Lg^.Dat.MarketElement[j].Input.Kol);
      End
      Else
      Begin
       Lg^.Dat.MarketElement[k]:=E^.Dat.MarketElement[l];
       Inc(k);
       Lg^.DAt.Amount:=k-1;
      End;
     End;{FiltrOtdel[]=1}
    End;
    Lg^.DAt.Amount:=k-1;

   New(BBB,Init);

   For l:=1 To Lg^.Dat.Amount Do
    Begin
     GetBazElement(Lg^.Dat.MarketElement[l].BazKod,BBB^.Dat);

     ItogoLitr:=0;

     StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=Lg^.Dat.MarketElement[l].BazKod;


     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
       MyStr((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)/
       (1+StrToReal(Lg^.Dat.MarketElement[l].Input.Proz)/100))
       ,CZena,CMantissa,ws){новая цена}
     Else
       MyStr((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[l].Input.Skidka))
            ,CZena,CMantissa,ws);{новая цена}



       If Lg^.DAt.DocSelector in [{1,2,3,5,6}100] Then
       Begin
       Mystr(((1+strtoreal(Lg^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);
       {новая цена}
       MyStr(StrToReal(ws)/StrToReal(Koefficient),CZena,CMantissa,Ws);
       End;


{Вычли скидку из цены}
       ItogoPos:=StrToReal(ws)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
       ItogoLitr:=StrToReal(BBB^.Dat.Litr)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);



{расчитали сумму Итого в позиции со скидкой}
       NdsPos:=ItogoPos*
       StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)/(100+StrToReal(Lg^.Dat.MarketElement[l].Input.NDS));

       MyStr(NDSPos,CIZena,CMantissa,Ws);
       NdsPos:=StrToReal(Ws);


       Nds:=Nds+NDSPos;

       Litr:=Litr+ItogoLitr;

{разборка  НДС по классификации}
       Case Lg^.Dat.MarketElement[l].Input.VidNDs Of
       0:Nds20:=Nds20+NdsPos;
       1:Nds10:=Nds10+NdsPos;
       2:Nds_:=Nds_+NdsPos;
       3:Nds18:=Nds18+NdsPos;
       4:Nds16:=Nds16+NdsPos;
       Else;
       End;

{сумма НДС по с/ф}

    End;
   Dispose(BBB,Done);
   Dispose(Lg,Done);


{теперь по сертификатам}
   New(Lg,Init);
   k:=1;j:=1;

   For l:=1 To E^.Dat.AmountS Do
    Begin
     If FiltrOtdel[E^.Dat.DocumentElement[l].Input.DivisionNumber]=1 Then
     Begin
     If testMarketSF(E^.Dat.DocumentElement[l].BazKod,Lg,j) Then
      Begin
       Str((StrToInt(Lg^.Dat.DocumentElement[j].Input.Kol)+
            StrToInt( E^.Dat.DocumentElement[l].Input.Kol)):CKol,Lg^.Dat.DocumentElement[j].Input.Kol);
      End
      Else
      Begin
       Lg^.Dat.DocumentElement[k]:=E^.Dat.DocumentElement[l];
       Inc(k);
       Lg^.DAt.AmountS:=k-1;
      End;
     End;{FiltrOtdel[]=1}
    End;
    Lg^.DAt.AmountS:=k-1;


   New(BBB,Init);

   For l:=1 To Lg^.Dat.AmountS Do
    Begin
     GetBazElement(Lg^.Dat.DocumentElement[l].BazKod,BBB^.Dat);

     ItogoLitr:=0;

     StrToInt(Lg^.Dat.DocumentElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=Lg^.Dat.DocumentElement[l].BazKod;


     If E^.Dat.SkidkaSelector=0 Then{Если автомат}
       MyStr((StrToReal(Lg^.Dat.DocumentElement[l].Input.Zena)/
       (1+StrToReal(Lg^.Dat.DocumentElement[l].Input.Proz)/100))
       ,CZena,CMantissa,ws){новая цена}
     Else
       MyStr((StrToReal(Lg^.Dat.DocumentElement[l].Input.Zena)-StrToReal(Lg^.Dat.DocumentElement[l].Input.Skidka))
            ,CZena,CMantissa,ws);{новая цена}



       If Lg^.DAt.DocSelector in [{1,2,3,5,6}100] Then
       Begin
       Mystr(((1+strtoreal(Lg^.dat.DocumentElement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);
       {новая цена}
       MyStr(StrToReal(ws)/StrToReal(Koefficient),CZena,CMantissa,Ws);
       End;



{Вычли скидку из цены}
       ItogoPos:=StrToReal(ws)*StrToInt(Lg^.Dat.DocumentElement[l].Input.Kol);
       ItogoLitr:=StrToReal(BBB^.Dat.Litr)*StrToInt(Lg^.Dat.DocumentElement[l].Input.Kol);



{расчитали сумму Итого в позиции со скидкой}
       NdsPos:=ItogoPos*
       StrToReal(Lg^.Dat.DocumentElement[l].Input.NDs)/(100+StrToReal(Lg^.Dat.DocumentElement[l].Input.NDS));

       MyStr(NDSPos,CIZena,CMantissa,Ws);
       NdsPos:=StrToReal(Ws);


       Nds:=Nds+NDSPos;

       Litr:=Litr+ItogoLitr;

{разборка  НДС по классификации}
       Case Lg^.Dat.DocumentElement[l].Input.VidNDs Of
       0:Nds20:=Nds20+NdsPos;
       1:Nds10:=Nds10+NdsPos;
       2:Nds_:=Nds_+NdsPos;
       3:Nds18:=Nds18+NdsPos;
       4:Nds16:=Nds16+NdsPos;
       Else;
       End;

{сумма НДС по с/ф}

    End;
   Dispose(BBB,Done);
   Dispose(Lg,Done);

   Dispose(E,Done);

End;



End.