{$I Compile.INC}
{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

unit UkassaT;

Interface

Uses Dialogs,Drivers,ServStr,MyCalc,Glob,Objects;


Procedure ViewKAssaSpec(Auto:Boolean;Shablon:TDAteString);
Procedure ViewKAssa(Auto:Boolean;Shablon:TDAteString);

Procedure FormReportKAssa;


Implementation


uses Views, MsgBox,Vision3,Validate,Access3,Access1,DBEngine,Utils4,Utils3,Utils1,
     TPDate,Vision1,Vision4,Vision5,Vision7,Vision2,App, Serv, ColorTxt,
     ServStr2,
     Protect,Prihod,Return,NetDbEng,Printers,Net,Utils,Tools, UKassa;

{Const ReadOnly=0;}

VAr OldFileMode: Word;

Procedure ViewKAssa(Auto:Boolean;Shablon:TDAteString);
Const Space='  ';
VAr Data : TDAteString;
    fk : File Of KassaType;
    Txt : Text;
    s : String;
    Kassa : PKassaType;
    Ext : ArtikulStr;
    c : Word;
    Sho : Boolean;
Begin
 Data :=Shablon;
 If Not(Auto) Then
 If Not(DateDialog(Data)) Then Exit;
 Str(StrToInt(Rek^.Dat.Kod):2,Ext);
 RFormatZerro(Ext,2);

 Assign(fk,Path^.Dat.ToArchiv+Data+'.k'+Ext);
 c:=IOResult;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(fk);
 c:=IOResult;
 FileMode:=OldFileMode;
 If c<>0 Then
 Begin
  MessageBox(^M+#3+'�� ���� ������ 䠩�!'+^M+#3+'('+IntToSTr(c,3)+')'
  ,Nil,mfError+mfCancelButton);
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
    MessageBox(^M+#3+'�訡�� �⥭�� 䠩�� ����� �� '+Data,Nil,mfError+mfCancelButton);
    Exit;
   End;

 System.Close(fk);
 Assign(Txt,Path^.Dat.ToTemp+'kassa.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;
 If c<>0 Then
  BEgin
  Dispose(Kassa,Done);
  MessageBox(^M+#3+'�� ���� ᮧ���� 䠩� ����!'+^M+#3+'('+IntToSTr(c,3)+')',Nil,mfError+mfCancelButton);
  Exit;
  End;

Kassa^.FormatReal;

s:=FormKod(Rek^.Dat.Kod);
s:=GetClientField(FClient,s,1);
DelSpaceLeftRight(s);


  Writeln(txt{,Bold[NPrint^.DAt.Printer]+Double[Nprint^.DAt.Printer]});
  Writeln(txt,Space+SeparatorChar+'       ����������� �������� ���� ������ "'+s+'" �� '+DAta);
  Writeln(txt);
  Writeln(txt,Space+SeparatorChar+'    ��������:'+GetOperatorField(FNAme,Kassa^.DAt.CAption));
  Writeln(Txt);

With Kassa^.Dat Do
Begin
Writeln(txt,Space+'      ����� ���� �� ���                                       : ',SeparatorChar+
Recogniz(ReportKassa)+SeparatorChar);
Writeln(txt,Space+'    1.�㬬� � ����                                               : ',SeparatorChar+
Recogniz(SummaInKassa)+SeparatorChar);
Writeln(txt,Space+'    2.���⮪ � ����                                             : ',SeparatorChar+
Recogniz(OstatokInKassa)+SeparatorChar);
Writeln(txt,Space+'    3.�����                                                       : ',SeparatorChar+
Recogniz(Sdano)+SeparatorChar);
Writeln(txt,Space+'    4.�������⥫�� ��室                                        : ',SeparatorChar+
Recogniz(ExtendedDohod)+SeparatorChar);
Writeln(txt,Space+'    5.���室�                                                     : ',SeparatorChar+
Recogniz(Rashod)+SeparatorChar);
{Writeln(txt,Space+'    6.����䨪���                                                 : ',SeparatorChar+
Recogniz(Sertifikat)+SeparatorChar);}

Sho:=False;
If Password(5) Then Sho:=True;

If Sho Then
 Begin
Writeln(txt,Space+'    6.��室 �� �⮣�� �࣮���� ���                               : ',SeparatorChar+
Recogniz(DohodAll)+SeparatorChar);
Writeln(txt,Space+'    7.��室 �� �⮣�� �࣮���� ��� (�࣮�� �।�⠢�⥫�)      : ',SeparatorChar+
Recogniz(DohodAgent)+SeparatorChar);
Writeln(txt,Space+'    8.��室 �� �⮣�� �࣮���� ��� (���䨪���)                 : ',SeparatorChar+
Recogniz(DohodSertif)+SeparatorChar);
 End;

Writeln(txt,Space+'    9.��室 �� ᪫�� �� ������                                  : ',SeparatorChar+
Recogniz(Prihod)+SeparatorChar);
Writeln(txt,Space+'   10.���⮪ �� ᪫���                                           : ',SeparatorChar+
Recogniz(Ostatok)+SeparatorChar);
Writeln(txt,Space+'   11.�� ࠡ���                                                   : ',SeparatorChar+
Recogniz(RP)+SeparatorChar);
Writeln(txt,Space+'   12.�� ࠡ��� (���䨪���)                                     : ',SeparatorChar+
Recogniz(SertifRP)+SeparatorChar);
Writeln(txt,Space+'   13.�㬬� � ᪫���                                             : ',SeparatorChar+
Recogniz(SummaOutSklad)+SeparatorChar);
Writeln(txt,Space+'   14.�뤠�� ��� ����窨 ���⥦� (�)                             : ',SeparatorChar+
Recogniz(Prodagi)+SeparatorChar);
Writeln(txt,Space+'   15.������ �뤠� ��� ����窨 ���⥦�                          : ',SeparatorChar+
Recogniz(SkProdagi)+SeparatorChar);
Writeln(txt,Space+'   16.�뤠�� ���䨪�⮢ ��� ����窨 ���⥦� (�)                : ',SeparatorChar+
Recogniz(SertifProdagi)+SeparatorChar);
Writeln(txt,Space+'   17.������ �뤠� ���䨪�⮢ ��� ����窨 ���⥦�             : ',SeparatorChar+
Recogniz(SertifSkProdagi)+SeparatorChar);
Writeln(txt,Space+'   18.�뤠�� �� ���ᨣ���� (�)                                   : ',SeparatorChar+
Recogniz(VidanoConsig)+SeparatorChar);
Writeln(txt,Space+'   19.������ �뤠���� ���ᨣ��樨                                 : ',SeparatorChar+
Recogniz(SkVidanoConsig)+SeparatorChar);
Writeln(txt,Space+'   20.����� ���ᨣ��樨 � �����                                  : ',SeparatorChar+
Recogniz(OplataInKassa)+SeparatorChar);
Writeln(txt,Space+'   21.������ ��ଫ����� ���ᨣ��樨                              : ',SeparatorChar+
Recogniz(SkOformConsign)+SeparatorChar);
Writeln(txt,Space+'   22.������ �� ����⮩ ���ᨣ��樨 (�)                         : ',SeparatorChar+
Recogniz(ReturnOutOpenConsig)+SeparatorChar);
Writeln(txt,Space+'   23.������ ������ �� ����⮩ ���ᨣ��樨                     : ',SeparatorChar+
Recogniz(SkReturnOutOpenConsig)+
SeparatorChar);
Writeln(txt,Space+'   24.������ �� ���㬥�⠬ �த��� � �����⮩ ���ᨣ��樨 (�)    : ',SeparatorChar+Recogniz
(ReturnOutMArketDocAndCloseConsig)+
SeparatorChar);
Writeln(txt,Space+'   25.������ ������ �� ���㬥�⠬ �த��� � �����⮩ ���ᨣ��樨: ',SeparatorChar+Recogniz
(SkReturnOutMArketDocAndCloseConsig)+SeparatorChar);
Writeln(txt,Space+'   26.���⮪ ���ᨣ��樨 (�)                                     : ',SeparatorChar+
Recogniz(OstatokConsig)+SeparatorChar);
Writeln(txt,Space+'   27.������ ���⪠ ���ᨣ��樨                                  : ',SeparatorChar+
Recogniz(SkOstatokConsig)+SeparatorChar);
Writeln(txt,Space+'   28.��८業��                                                  : ',SeparatorChar+
Recogniz(Pereozenka)+SeparatorChar);
Writeln(txt,Space+'   29.��८業�� �� �������                                      : ',SeparatorChar+
Recogniz(PereozenkaFromReturn)+SeparatorChar);
Writeln(txt,Space+'   30.���室� �� �������                                         : ',SeparatorChar+
Recogniz(RashodFromReturn)+SeparatorChar);
Writeln(txt,Space+'   31.���室� �� ������� ����⮩ ���ᨣ��樨                    : ',SeparatorChar
+Recogniz(RashodFromReturnOpenConsig)+SeparatorChar);
Writeln(txt,Space+'   32.�㬬� �� �뤠��� �/�                                       : ',SeparatorChar+
Recogniz(VidanoSF)+SeparatorChar);
Writeln(txt,Space+'   33.������� �� ᪫���                                           : ',SeparatorChar+Recogniz(Rewisia)+
SeparatorChar);
Writeln(txt,Space+'   34.���� �� �� ���㧪� ������� ��� ����窨 ���⥦�            : ',SeparatorChar+Recogniz(SNAlogP)+
SeparatorChar);
Writeln(txt,Space+'   35.���� �� �� ���㧪� ������� �� ���ᨣ����                  : ',SeparatorChar+Recogniz(SNAlogC)+
SeparatorChar);
Writeln(txt,Space+'   36.�� �� ������� ����⮩ ���ᨣ��樨                          : ',SeparatorChar
+Recogniz(SNAlogReturnOpenConsig)+SeparatorChar);
Writeln(txt,Space+'   37.���줮 �� ���������⠬                                     : ',SeparatorChar+
Recogniz(OstatokBarter)+SeparatorChar);
Writeln(txt,Space+'   38.��室 � ��� ���������� �� �/�                           : ',SeparatorChar+Recogniz(BarterPrihod)+
SeparatorChar);
Writeln(txt,Space+'   39.��室 �� ᪫�� � ��� ���������� �� �/�                  : ',SeparatorChar+
Recogniz(BarterPrihodRZ)+SeparatorChar);
Writeln(txt,Space+'   40.�뤠�� �����⠬ � ��� ����������  (�)                    : ',SeparatorChar+Recogniz(BarterT)+
SeparatorChar);
Writeln(txt,Space+'   41.������ �뤠� �����⠬ � ��� ����������                  : ',SeparatorChar+Recogniz(BarterSkidki)+
SeparatorChar);
Writeln(txt,Space+'   42.�뤠�� ���䨪�⮢ �����⠬ � ��� ����������  (�)       : ',SeparatorChar+Recogniz(SertifBarterT)+
SeparatorChar);
Writeln(txt,Space+'   43.������ �뤠� ���䨪�⮢ �����⠬ � ��� ����������     : ',SeparatorChar+
Recogniz(SertifBarterSkidki)+SeparatorChar);
Writeln(txt,Space+'   44.����㯫���� � ����� � ��� ����������                     : ',SeparatorChar+Recogniz(BarterInKassa)+
SeparatorChar);
Writeln(txt,Space+'   45.���室 �� ����� � ��� ���������                          : ',SeparatorChar+Recogniz(BarterOutKassa)
+SeparatorChar);


 {38}

Writeln(txt,Space+'   46.��������� ������ ���ᨣ��樨                              : ',SeparatorChar+
Recogniz(BNOPlataConsig));
Writeln(txt,Space+'   47.��������� ������ ⮢�� ��� ����窨 ���⥦�              : ',SeparatorChar+Recogniz(BNProdagi));
Writeln(txt,Space+'   48.��������� ����㯫���� � ��� ����������                 : ',SeparatorChar+
Recogniz(BNBarterInKassa));
Writeln(txt,Space+'   49.��������� ��室� � ��� ����������                     : ',SeparatorChar+
Recogniz(BNBarterOutKassa));
Writeln(txt,Space+'   50.���⮪ ��९��� �����⮢ �� ������ ����                : ',SeparatorChar+
Recogniz(OstatokPereplatN));
Writeln(txt,Space+'   51.���⮪ ��९��� �����⮢ �� ��������� ����             : ',SeparatorChar+
Recogniz(OstatokPereplatB));
Writeln(txt,Space+'   52.���⮪ ��९��� �����⮢ �� ���ᥫ�                       : ',SeparatorChar+
Recogniz(OstatokPereplatV));
Writeln(txt,Space+'   53.����㯫���� � ��� ��९��� �����⮢ �� ������ ����     : ',SeparatorChar+Recogniz(NewPereplatN));
Writeln(txt,Space+'   54.����㯫���� � ��� ��९��� �����⮢ �� ��������� ����  : ',SeparatorChar+Recogniz(NewPereplatB));
Writeln(txt,Space+'   55.����㯫���� � ��� ��९��� �����⮢ �� ���ᥫ�� ����   : ',SeparatorChar+Recogniz(NewPereplatV));
Writeln(txt,Space+'   56.���室 ������� ��९��� �����⮢                           : ',SeparatorChar+
Recogniz(RashodPereplatN));
Writeln(txt,Space+'   57.���室 ���������� ��९��� �����⮢                        : ',SeparatorChar+
Recogniz(RashodPereplatB));
Writeln(txt,Space+'   58.���室 ���ᥫ��� ��९��� �����⮢                         : ',SeparatorChar+
Recogniz(RashodPereplatV));

Writeln(txt,Space+'   59.���⮪ ��樧� �� ᪫���                                    : ',SeparatorChar+Recogniz(OstatokAkzis));
Writeln(txt,Space+'   60.��樧�� ᡮ� �� ���㬥�⠬ ��� ����窨 ���⥦�            : ',SeparatorChar+
Recogniz(ProdagiCAkzis));
Writeln(txt,Space+'   61.��樧�� ᡮ� �� ���᪫��᪨� ��ॢ�����                    : ',SeparatorChar+
Recogniz(ProdagiSAkzis));
Writeln(txt,Space+'   62.��樧�� ᡮ� �� ���㬥�⠬ ���㧪� � ��� ����������    : ',SeparatorChar+
Recogniz(ProdagiBAkzis));
Writeln(txt,Space+'   63.��樧�� ᡮ� �� ���㬥�⠬, �뤠��� �� ���ᨣ����        : ',SeparatorChar+
Recogniz(VidanoConsigAkzis));
Writeln(txt,Space+'   64.��樧�� ᡮ� �� ���㬥�⠬ ��ଫ����� ���ᨣ��樨         : ',SeparatorChar+
Recogniz(OformlenoConsigAkzis));
Writeln(txt,Space+'   65.��樧�� ᡮ� �� ���㬥�⠬ ��室� �� ������              : ',SeparatorChar+Recogniz(PrihodCAkzis));
Writeln(txt,Space+'   66.��樧�� ᡮ� �� ���㬥�⠬ ���᪫��᪮�� ��室�           : ',SeparatorChar+Recogniz(PrihodSAkzis));
Writeln(txt,Space+'   67.��樧�� ᡮ� �� ���㬥�⠬ ��室� � ��� ����������     : ',SeparatorChar+Recogniz(PrihodBAkzis));
Writeln(txt,Space+'   68.��樧�� ᡮ� �� ���㬥�⠬ ������ �� ������             : ',SeparatorChar+Recogniz(ReturnCAkzis));
Writeln(txt,Space+'   69.��樧�� ᡮ� �� ���㬥�⠬ ���᪫��᪮�� ������          : ',SeparatorChar+Recogniz(ReturnSAkzis));
Writeln(txt,Space+'   70.��樧�� ᡮ� �� ���㬥�⠬ ॢ����                         : ',SeparatorChar+Recogniz(RevisiaAkZis));





For c:=1 To Max30 Do
Begin
Str(c:CClientKod,s);
s:=GEtClientField(FClient,s,1);
DelSpaceLeftRight(s);
Format(s,CClient);
If Abs(StrToReal(PerewoskiOut[c]))>0.009 Then
Writeln(txt,Space,'  ',c+{58}70:3,'.��ॢ���� � ᪫��� �� '+s+'                 : ',SeparatorChar+
Recogniz(PerewoskiOut[c])+SeparatorChar);
End;

For c:=1 To 30 Do
Begin
Str(c:CClientKod,s);
s:=GEtClientField(FClient,s,1);
DelSpaceLeftRight(s);
Format(s,CClient);
If Abs(StrToReal(PerewoskiInp[c]))>0.009 Then
Writeln(txt,Space,'  ',c+100{73}:3,'.��ॢ���� �� ᪫��  �  '+s+'                 : ',SeparatorChar+Recogniz(PerewoskiInp[c])+
SeparatorChar);
End;

Writeln(txt,Space+'  131.�⮣� ��ॢ���� � ᪫���                                   : ',SeparatorChar+
Recogniz(EPerewoskiOut)+SeparatorChar);
Writeln(txt,Space+'  132.�⮣� ��ॢ���� �� ᪫��                                    : ',SeparatorChar+
Recogniz(EPerewoskiInp)+SeparatorChar);

If Sho Then
 Begin
Writeln(txt,Space+'  133.���⮪ �� ᪫��� �� �/�����                                : ',SeparatorChar+
Recogniz(OstatokZ)+SeparatorChar);
Writeln(txt,Space+'  134.���⮪ ���ᨣ��樨 �� ࠧ�����                             : ',SeparatorChar+
Recogniz(OstatokConsigZ)+SeparatorChar);
Writeln(txt,Space+'  135.��室 �� ᪫�� �� ������ �� �/�����                       : ',SeparatorChar+
Recogniz(PrihodZC)+SeparatorChar);
Writeln(txt,Space+'  136.��室 �� ᪫�� � ��� ���������� �� �/�����              : ',SeparatorChar+
Recogniz(PrihodZB)+SeparatorChar);

Writeln(txt,Space+'  137.���㧪� ������� �� �/�����                                 : ',SeparatorChar+
Recogniz(OtgruzkaZC)+SeparatorChar);
Writeln(txt,Space+'  138.���㧪� � ��� ���������� �� �/�����                     : ',SeparatorChar+
Recogniz(OtgruzkaZB)+SeparatorChar);
Writeln(txt,Space+'  139.�� ࠡ��� �� �/�����                                        : ',SeparatorChar+
Recogniz(OtgruzkaZRP)+SeparatorChar);

Writeln(txt,Space+'  140.�⮣� ��ॢ���� � ᪫��� �� �/�����                        : ',SeparatorChar+
Recogniz(OtgruzkaZS)+SeparatorChar);
Writeln(txt,Space+'  141.�⮣� ��ॢ���� �� ᪫�� �� �/�����                         : ',SeparatorChar+
Recogniz(PrihodZS)+SeparatorChar);

Writeln(txt,Space+'  142.������� �� ᪫��� �� �/�����                                : ',SeparatorChar+
Recogniz(RewisiaZ)+SeparatorChar);
Writeln(txt,Space+'  143.������ �� ᪫�� �� �/�����                                 : ',SeparatorChar+
Recogniz(ReturnZ)+SeparatorChar);

Writeln(txt,Space+'  144.���饭�� ��室 �� �������                                 : ',SeparatorChar+
Recogniz(MinusDohod)+SeparatorChar);
Writeln(txt,Space+'  145.��室����� �� ����. �� �⮣�� �࣮���� ��� (���������)   : ',SeparatorChar+
Recogniz(AllDohod)+SeparatorChar);
Writeln(txt,Space+'  146.��室����� �� ����. �� �⮣�� �࣮���� ��� (�� �������)  : ',SeparatorChar+
Recogniz(AllDohodA)+SeparatorChar);
Writeln(txt,Space+'  147.��室����� �� ���㧪� � ��� ����������                  : ',SeparatorChar+
Recogniz(AllDohodB)+SeparatorChar);
 End;

Writeln(txt,Space+'  148.���⮪ "�������"                                           : ',SeparatorChar+
Recogniz(Otkat)+SeparatorChar);
Writeln(txt,Space+'  149.���������� "�������"                                        : ',SeparatorChar+
Recogniz(AddOtkat)+SeparatorChar);
Writeln(txt,Space+'  150.��襭�� "�������"                                           : ',SeparatorChar+
Recogniz(KillOtkat)+SeparatorChar);
Writeln(txt,Space+'  151.��襭�� "�������" �� �������� ⥪�饣� ���                 : ',SeparatorChar+
Recogniz(KillOtkatToDay)+SeparatorChar);

Writeln(txt,Space+'                                                           "'+DayString[DayOfWeek(ToDay)]+'" '+
                  FDate+'('+Times+')'+
			   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
			   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);

Writeln(txt,Space+'   ================================================================================');
End;

 Dispose(Kassa,Done);
 Close(Txt);
 ViewAsText(Path^.Dat.ToTemp+'Kassa.txt','��� �� '+DAta,True);
 {Report(Path^.Dat.ToTemp+'Kassa.txt','',NprintC^.DAt.CopyAll,False,False)}
End;





Procedure ViewKAssaSpec(Auto:Boolean;Shablon:TDAteString);
Const Space='  ';
VAr Data : TDAteString;
    fk : File Of KassaType;
    Txt : Text;
    s : String;
    Kassa : PKassaType;
    Ext : ArtikulStr;
    c : Word;
    Summ : Real;
Begin
 Data :=Shablon;
 If Not(Auto) Then
 If Not(DateDialog(Data)) Then Exit;
 Str(StrToInt(Rek^.Dat.Kod):2,Ext);
 RFormatZerro(Ext,2);

 Assign(fk,Path^.Dat.ToArchiv+Data+'.k'+Ext);
 c:=IOResult;
 OldFileMode:=FileMode;
 FileMode:=ReadOnlyN;
 Reset(fk);
 c:=IOResult;
 FileMode:=OldFileMode;
 If c<>0 Then
 Begin
  MessageBox(^M+#3+'�� ���� ������ 䠩�!'+^M+#3+'('+IntToSTr(c,3)+')'
  ,Nil,mfError+mfCancelButton);
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
    MessageBox(^M+#3+'�訡�� �⥭�� 䠩�� ����� �� '+Data,Nil,mfError+mfCancelButton);
    Exit;
   End;

 System.Close(fk);
 Assign(Txt,Path^.Dat.ToTemp+'skassa.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;
 If c<>0 Then
  BEgin
  Dispose(Kassa,Done);
  MessageBox(^M+#3+'�� ���� ᮧ���� 䠩� ����!'+^M+#3+'('+IntToSTr(c,3)+')',Nil,mfError+mfCancelButton);
  Exit;
  End;

Kassa^.FormatReal;

s:=FormKod(Rek^.Dat.Kod);
s:=GEtClientField(FClient,s,1);
DelSpaceLeftRight(s);


  Writeln(txt,GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]);
  Writeln(txt,Space+' �������������� ����������� �������� ���� ������ "'+s+'" �� '+DAta);
  Writeln(txt);
  Writeln(txt,Space+'    ��������:'+GetOperatorField(FNAme,Kassa^.DAt.CAption));
  Writeln(Txt);
With Kassa^.Dat Do
Begin
If ({FindParam('/EZ')}(EnableZakupka=1)  Or (StrToInt(CurrentPassword)=0)) Then
Begin
Writeln(txt,Space+'      ����� ���� �� ���                                       : ',SeparatorChar+Recogniz(ReportKassa)+
SeparatorChar);
Writeln(txt,Space+'    1.�㬬� � ����                                               : ',SeparatorChar+Recogniz(SummaInKassa)+
SeparatorChar);
Writeln(txt,Space+'    2.���⮪ � ����                                             : ',SeparatorChar+Recogniz(OstatokInKassa)
+SeparatorChar);
Writeln(txt,Space+'    3.�����                                                       : ',SeparatorChar+Recogniz(Sdano)+
SeparatorChar);
Writeln(txt,Space+'    4.�������⥫�� ��室                                        : ',SeparatorChar+Recogniz(ExtendedDohod)+
SeparatorChar);
Writeln(txt,Space+'    5.���室�                                                     : ',SeparatorChar+Recogniz(Rashod)+
SeparatorChar);
Writeln(txt,Space+'   14.�뤠�� ��� ����窨 ���⥦� (�)                             : ',SeparatorChar+Recogniz(Prodagi)+
SeparatorChar);
Writeln(txt,Space+'   15.������ �뤠� ��� ����窨 ���⥦�                          : ',SeparatorChar+Recogniz(SkProdagi)+
SeparatorChar);
Writeln(txt,Space+'      �뤠�� ��� ����窨 ���⥦� (ॠ�쭮)                       : ',SeparatorChar+Recogniz(
RealToStr(StrToReal(Prodagi)-StrToReal(SkProdagi),CIZena,CMantissa)));

Writeln(txt,Space+'   18.�뤠�� �� ���ᨣ���� (�)                                   : ',SeparatorChar+Recogniz(VidanoConsig)+
SeparatorChar);
Writeln(txt,Space+'   19.������ �뤠���� ���ᨣ��樨                                 : ',SeparatorChar+Recogniz(SkVidanoConsig)
+SeparatorChar);
Writeln(txt,Space+'      �뤠�� �� ���ᨣ���� (ॠ�쭮)                             : ',SeparatorChar+Recogniz(
RealToStr(StrToReal(VidanoConsig)-StrToReal(SkVidanoConsig),CIZena,CMantissa)));

Writeln(txt,Space+'   20.����� ���ᨣ��樨 � �����                                  : ',SeparatorChar+Recogniz(OplataInKassa)+
SeparatorChar);
Writeln(txt,Space+'   22.������ �� ����⮩ ���ᨣ��樨 (�)                         : ',SeparatorChar+
Recogniz(ReturnOutOpenConsig)+SeparatorChar);
Writeln(txt,Space+'   23.������ ������ �� ����⮩ ���ᨣ��樨                     : ',SeparatorChar+
Recogniz(SkReturnOutOpenConsig));
Writeln(txt,Space+'      ������ �� ����⮩ ���ᨣ��樨 (ॠ�쭮)                   : ',SeparatorChar+Recogniz(
RealToStr(StrToReal(ReturnOutOpenConsig)-StrToReal(SkReturnOutOpenConsig),CIZena,CMantissa)));


Writeln(txt,Space+'   26.���⮪ ���ᨣ��樨 (�)                                     : ',SeparatorChar+Recogniz(OstatokConsig)+
SeparatorChar);
Writeln(txt,Space+'   27.������ ���⪠ ���ᨣ��樨                                  : ',SeparatorChar+
Recogniz(SkOstatokConsig)+SeparatorChar);
Writeln(txt,Space+'      ���⮪ ���ᨣ��樨 (ॠ�쭮)                               : ',SeparatorChar+Recogniz(
RealToStr(StrToReal(OstatokConsig)-StrToReal(SkOstatokConsig),CIZena,CMantissa)));

Writeln(txt,Space+'   30.���室� �� �������                                         : ',SeparatorChar+
Recogniz(RashodFromReturn)+SeparatorChar);
Writeln(txt,Space+'   46.��������� ������ ���ᨣ��樨                              : ',SeparatorChar+
Recogniz(BNOPlataConsig));
Writeln(txt,Space+'  133.���⮪ �� ᪫��� �� �/�����                                : ',SeparatorChar+Recogniz(OstatokZ)+
SeparatorChar);
Writeln(txt,Space+'  135.��室 �� ᪫�� �� ������ �� �/�����                       : ',SeparatorChar+Recogniz(PrihodZC)+
SeparatorChar);
Writeln(txt,Space+'  137.���㧪� ������� �� �/�����                                 : ',SeparatorChar+Recogniz(OtgruzkaZC)+
SeparatorChar);
Writeln(txt,Space+'  139.�� ࠡ��� �� �/�����                                        : ',SeparatorChar+Recogniz(OtgruzkaZRP)+
SeparatorChar);
Writeln(txt,Space+'  142.������� �� ᪫��� �� �/�����                                : ',SeparatorChar+Recogniz(RewisiaZ)+
SeparatorChar);
Writeln(txt,Space+'  143.������ �� ᪫�� �� �/�����                                 : ',SeparatorChar+Recogniz(ReturnZ)+
SeparatorChar);
Writeln(txt,Space+'  144.���饭�� ��室 �� �������                                 : ',SeparatorChar+Recogniz(MinusDohod)+
SeparatorChar);
Writeln(txt,Space+'  145.��室����� �� ����. �� �⮣�� �࣮���� ��� (���������)   : ',SeparatorChar+Recogniz(AllDohod)+
SeparatorChar);
Writeln(txt,Space+'  146.��室����� �� ����. �� �⮣�� �࣮���� ��� (�� �������)  : ',SeparatorChar+Recogniz(AllDohodA)+
SeparatorChar);


Writeln(txt,Space+'      ���⮪ �� ᪫��� �� �/�����2                               : ',SeparatorChar+Recogniz(OstatokZ2)+
SeparatorChar);
Writeln(txt,Space+'      ��室 �� ᪫�� �� ������ �� �/�����2                      : ',SeparatorChar+Recogniz(PrihodZC2)+
SeparatorChar);
Writeln(txt,Space+'      ���㧪� ������� �� �/�����2                                : ',SeparatorChar+Recogniz(OtgruzkaZC2)+
SeparatorChar);
Writeln(txt,Space+'      �� ࠡ��� �� �/�����2                                       : ',SeparatorChar+Recogniz(OtgruzkaZRP2)+
SeparatorChar);
Writeln(txt,Space+'      ������� �� ᪫��� �� �/�����2                               : ',SeparatorChar+Recogniz(RewisiaZ2)+
SeparatorChar);
Writeln(txt,Space+'      ������ �� ᪫�� �� �/�����2                                : ',SeparatorChar+Recogniz(ReturnZ2)+
SeparatorChar);
Writeln(txt,Space+'      ���饭�� ��室 �� �������                                 : ',SeparatorChar+Recogniz(MinusDohod2)+
SeparatorChar);


Summ:=0;
for c:=1 To Max30 Do Summ:=Summ+StrToReal(PerewoskiOutZ[c]);

Writeln(txt,Space+'      �⮣� ��ॢ���� � ᪫��� �� ��                             : ',SeparatorChar+
RecognizReal(Summ,CIZena,CMantissaZ)+SeparatorChar);
Summ:=0;
for c:=1 To Max30 Do Summ:=Summ+StrToReal(PerewoskiInpZ[c]);
Writeln(txt,Space+'      �⮣� ��ॢ���� �� ᪫�� �� ��                              : ',SeparatorChar+
RecognizReal(Summ,CIZena,CMantissaZ)+SeparatorChar);

Summ:=0;
for c:=1 To Max30 Do Summ:=Summ+StrToReal(PerewoskiOutZ2[c]);

Writeln(txt,Space+'      �⮣� ��ॢ���� � ᪫��� �� ��2                            : ',SeparatorChar+
RecognizReal(Summ,CIZena,CMantissaZ)+SeparatorChar);
Summ:=0;
for c:=1 To Max30 Do Summ:=Summ+StrToReal(PerewoskiInpZ2[c]);
Writeln(txt,Space+'      �⮣� ��ॢ���� �� ᪫�� �� ��2                             : ',SeparatorChar+
RecognizReal(Summ,CIZena,CMantissaZ)+SeparatorChar);



Writeln(txt,Space+'      �ᥣ� ��室����� �� ���㧪� �� �⮣�� �࣮���� ���        : ',SeparatorChar+Recogniz(
RealToStr(StrToReal(AllDohod)+StrToReal(AllDohodA),CIZena,CMantissa)));

End;

Writeln(txt,Space+'                                                           "'+DayString[DayOfWeek(ToDay)]+'" '+
                  FDate+'('+Times+')'+
			   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
			   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);

Writeln(txt,Space+'   ================================================================================');
End;

 Dispose(Kassa,Done);
 Close(Txt);
 ViewAsText(Path^.Dat.ToTemp+'sKassa.txt','�������⥫�� ��� �� '+DAta,True);
 {Report(Path^.Dat.ToTemp+'sKassa.txt','',NprintC^.DAt.CopyAll,False,False)}
End;

{$IFDEF DPMI}
Procedure FormReportKAssa;
Var f,f1 : Text;
    i : Word;
    Fk : File Of KassaType;
    Tag,c,l,l1,l2 : LongInt;
    Ext,s : String;
    EBonus,ENBonus,EBarter,EBarterl,ESoSklada,EPrihod,EDohod,EDohodOpl,ERP,ERwz,ERashod,ESdano:Float;
    EBonusL,ENBonusL,EOstL,EOsta,Evzz,Evza,ESoSkladaL,EPrihodL,EDohodL,EDohodOplL,ERPL,ERwzL,ERashodL,ESdanoL,
    ESFL,EMinusDohodL,ESF,EMinusDohod,ESkidkiL,ESkidki,
    ESertif, ESertifL:Float;
    K : PKassaType;
    ProzSkidki,ProzOtgr,ProzOpl,Start,Stop : TDateString;
    EBn,EBNL,EOtgruzkaZL,EOtgruzkaZ,EOtgruskaKOplateL,EOtgruskaKOplate :Float;
Begin
 Start:=FDAte;
 Stop:=FDate;

 If Not(DatePeriodDialog(Start,Stop,False)) Then Exit;

 ESoSklada:=0;
   EBarter:=0;
   EPrihod:=0;
    EDohod:=0;
 EDohodOpl:=0;
       ERP:=0;
      ERwz:=0;
   ERashod:=0;
    ESdano:=0;
      Evza:=0;
     EOsta:=0;
       ESF:=0;
   ESkidki:=0;
EMinusDohod:=0;
    EBonus:=0;
   ENBonus:=0;
   ESertif:=0;
   EOtgruzkaZ:=0;
   EOtgruskaKOplate:=0;
   EBN:=0;

 Assign(f,Path^.Dat.ToTemp+'nstati.txt');
 i:=IOResult;
 Rewrite(f);
 i:=IOResult;
 If I<>0 Then
  Begin
   MessageBox(^M+#3+'�� ���� ᮧ���� '+Path^.Dat.ToTemp+'nstati.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Assign(f1,Path^.Dat.ToTemp+'kassaer.txt');
 i:=IOResult;
 Rewrite(f1);
 i:=IOResult;
 If I<>0 Then
  Begin
   Close(f);
   MessageBox(^M+#3+'�� ���� ᮧ���� '+Path^.Dat.ToTemp+'kassaer.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(f,'�����: '+FormKod(Rek^.Dat.Kod)++'  ������: '+CurrentPassword);
 Writeln(f,GlobalPrn^.Dat.OrientAlbom[Nprint^.DAt.Printer]+
 GlobalPrn^.Dat.MinInterval[Nprint^.DAt.Printer]);
 Writeln(f,'             ����⨪� �� ��ਮ� � '+Start+' �� '+Stop+' ('+Times+')');
 WriteLn(f);

 Writeln(f,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
 GlobalPrn^.Dat.MinInterval2[Nprint^.DAt.Printer]);

{Writeln(f,
 '����������������������������������������������������������������������������������������������������������������'+
 '����������������������������������������������������������������������������������������������������������������');
 Writeln(f,'  ���  ���室 �� ᪫��병㬬� � ᪫�������室����� ���.���室����� ��� .�     ���室�    �  �/�           � '+
 '    �����      � '+

 '�뤠�� �� ��������� ᪫����⮪ ���ᨣ�.�  �뤠�� �� ����饭�� �峑����� ���㳐������');
 Writeln(f,'����������������������������������������������������������������������������������������������������������������'+
 '����������������������������������������������������������������������������������������������������������������');}

Writeln(f,'�������������������������������������������������������������������������������������������������'+
+'�������������������������������������������������������������������������������������������������������������������Ŀ');
Writeln(f,'� ���  ���室    ��㬬�     ���室�����  %  ���室�����  %  � ���室�  �  �/�     �  �����   '+
+'� ������.  � �뤠��   �������   ����⮪   ��뤠�� �� ����饭�� �������    �  %  ��뤠�� �� ����᫥�� ��������   �');
Writeln(f,'�       ��� ᪫��  �� ᪫��� ����㧪�  �     ������    �     �          �          �          '+
+'� ����㯫. � �� ��    ��� ᪫��  ����ᨣ�.  �          ���室     ����㧪�  �     �����ᠬ   �����ᮢ   ��� ᪫��� �');
Writeln(f,'�������������������������������������������������������������������������������������������������'+
+'���������������������������������������������������������������������������������������������������������������������'+
+GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]);


 New(K,Init);
 l1:=DateStringToDate(DateMask,Start);
 l2:=DateStringToDate(DateMask,Stop);
 Tag:=0;
 For l:=l1 To l2 Do
  Begin
{ If Not(DayOfWeek(L) in [Sunday]) Then}
Begin
 DInfoMSgShkala('���������� �����...',l1,l2,L);
 ESoSkladaL:=0;
   EPrihodL:=0;
    EDohodL:=0;
  EDohodOplL:=0;
       ERPL:=0;
       ESFL:=0;
EMinusDohodL:=0;
   ERashodL:=0;
    ESdanoL:=0;
   EBarterL:=0;
   ESkidkiL:=0;
   EVzz:=0;
   EBarterL:=0;
   ErwzL:=0;
   EOstL:=0;
   EOtgruzkaZL:=0;
   EOtgruskaKOplateL:=0;
   EOtgruskaKOplateL:=0;
   ESertifL:=0;
   EBonusL:=0;
   ENBonusL:=0;
   Ebnl:=0;
   ProzOtgr:='??.??';
   ProzOpl:='??.??';
   ProzSkidki:='??.??';
   s:=DateToDateString(DateMask,l);
   {��⠢�� ��� �ନ஢���� ����⨪�}
   Inc(Tag);
   c:=StrToInt(Rek^.Dat.Kod);
     Ext:=IntToStr(c,CMantissa);
     RFormatZerro(Ext,CMAntissa);
     Insert('.k',Ext,1);
     i:=IOResult;
     Assign(fk,Path^.Dat.ToArchiv+s+Ext);
     OldFileMode:=FileMode;
     FileMode:=ReadOnlyN;
     Reset(fk);
     i:=IOResult;
     FileMode:=OldFileMode;
     If i<>0 Then Writeln(f1,'�訡�� ����㯠 � 䠩�� ����� �� '+S+
        '  "'+DayString[DayOfWeek(DAteStringToDate(DAteMask,S))]+'"'+' ���:'+IntToStr(I,3)
        )
     Else
      Begin
       Read(fk,K^.Dat);
       i:=IOResult;
       If i<>0 Then Writeln(f1,'�訡�� �⥭�� 䠩�� ����� �� '+S);

       Close(Fk);
       i:=IOResult;
       ESoSkladaL:=ESoSkladaL+StrToReal(K^.Dat.SummaOutSklad);
       EVzz:=Evzz+StrToReal(K^.Dat.ReturnOutOpenConsig)+StrToReal(K^.Dat.ReturnOutMArketDocAndCloseConsig);
       EPrihodL:=EPrihodL+StrToReal(K^.Dat.Prihod);

       EDohodL:=EDohodL+StrToReal(K^.Dat.AllDohod{SertifProdagi})+StrToReal(K^.Dat.AllDohodA)+StrToReal(K^.Dat.AllDohodB);

       EOtgruzkaZL:=EOtgruzkaZL+StrToReal(K^.Dat.OtgruzkaZC);
       {EOtgruskaOplZ:=EOtgruskaOplZ+;}

       EOtgruskaKOplateL:=EOtgruskaKOplateL+StrToReal(k^.Dat.OtgruzkaWithOplataWithOutAkzis);




       EDohodOplL:=EDohodOplL+StrToReal(K^.Dat.DohodAll);

       EMinusDohodL:=EMinusDohodL+StrToReal(K^.Dat.MinusDohod);
       {-StrToReal(K^.Dat.SertifSkProdagi)}
       ERpL:=ERpL+StrToReal(K^.Dat.Rp){+StrToReal(K^.Dat.Rewisia)};
       ERwzL:=ERwzL+StrToReal(K^.Dat.Rewisia);
       ESFL:=ESFL+StrToReal(K^.Dat.VidanoSF);
       ERashodL:=ERashodL+{StrToReal(K^.Dat.Rashod)}StrToReal(K^.Dat.Rashod{SertifSkProdagi});
       ESdanoL:=ESdanoL+StrToReal(K^.Dat.Sdano);
       ESkidkiL:=ESkidkiL+StrToReal(K^.Dat.SkProdagi)+StrToReal(K^.Dat.SkVidanoConsig);
       EBarterL:=EBarterL+StrToReal(K^.Dat.BarterT);
       EOstL:=EOstL+StrToReal(K^.Dat.OstatokConsig);
       ESertifL:=ESertifL+StrToReal(K^.Dat.SertifProdagi){-StrToReal(K^.Dat.SertifSkProdagi)}+StrToReal(K^.Dat.SertifBarterT);
       EBonusL:=EBonusL+StrToReal(K^.Dat.KillOtkat);
       ENBonusL:=ENBonusL+StrToReal(K^.Dat.AddOtkat);
       EBnL:=EbnL+StrToReal(K^.Dat.BNOPlataConsig)+StrToReal(K^.Dat.BNProdagi)+
       StrToReal(K^.Dat.BNBarterInKassa);

       If Abs(EOtgruzkaZL)>0.009 Then
       MyStr(EDohodL/EOtgruzkaZL*100,CLitr,CMantissa,ProzOtgr)
       Else ProzOtgr:='??.??';


       If Abs(EOtgruskaKOplateL-strtoreal(k^.dat.DohodAll))>0.009 Then
       MyStr(StRToreal(K^.Dat.DohodAll)/(EOtgruskaKOplateL-strtoreal(k^.dat.DohodAll))*100,CLitr,CMantissa,ProzOpl)
       Else ProzOpl:='??.??';



       If Abs(ESoSkladaL)>0.009 Then
       MyStr(eSkidkiL/ESoSkladaL*100,CLitr,CMantissa,ProzSkidki)
       Else ProzSkidki:='??.??';

      End;
    s:=s+'�'+RealToStr(EPrihodL,CZenaZ,CMantissa)+'�'+RealToStr(ESoSkladaL,CZenaZ,CMantissa)+'�'+
    +RealToStr(EDohodL,CZenaZ,CMantissa)+'�'+ProzOtgr+'�'+
    +RealToStr(EDohodOplL,CZenaZ,CMantissa)+'�'+ProzOpl+'�'+
    RealToStr(ERashodL,CZenaZ,CMantissa)+'�'+
    +RealToStr(ERpL,CZenaZ,CMantissa)+'�'+RealToStr(ESdanoL,CZenaZ,CMantissa)+'�'+
    RealToStr(EBnL,CZenaZ,CMantissa)+'�'+
    RealToStr(EBarterL,CZenaZ,CMantissa)+'�'+RealToStr(EVzz,CZenaZ,CMantissa)+'�'+
    RealToStr(EOstL,CZenaZ,CMantissa)+'�'+RealToStr(EsFL,CZenaZ,CMantissa)+
    '�'+RealToStr(emINUSdOHODL,CZenaZ,CMantissa)+'�'+RealToStr(eSkidkiL,CZenaZ,CMantissa)+'�'+
    ProzSkidki+'�'+RealToStr(EBonusL,CZenaZ,CMantissa)+'�'+
    RealToStr(ENBonusL,CZenaZ,CMantissa)+'�'+
    RealToStr(ERwzL,CZenaZ,CMantissa)+'�'{+RealToStr(ESertifL,CZenaZ,CMantissa)};

  While Pos('�',s)>0 Do s[Pos('�',s)]:=SeparatorChar;

    Writeln(f,s);
   i:=IOResult;

 ESoSklada:=ESoSklada+ESoSkladaL;
   EPrihod:=EPrihod+EPrihodL;
    EDohod:=EDohod+EDohodL;
    EDohodOpl:=EDohodOpl+EDohodOplL;
       ERP:=ERP+ERPL;
       ERwz:=Erwz+ErwzL;
       ESF:=ESF+ESFL;
       EOtgruzkaZ:=EOtgruzkaZ+EOtgruzkaZL;
       ESkidki:=ESkidki+ESkidkiL;
       EMinusDohod:=EMinusDohod+EMinusDohodL;
   ERashod:=ERashod+ERashodL;
    ESdano:=ESdano+ESdanoL;
    EBarter:=EBarter+EBarterL;
    Evza:=Evza+Evzz;
    EOsta:=EOsta+EOstL;
    ESertif:=ESertif+ESertifL;
    EBonus:=EBonus+EBonusL;
    ENBonus:=ENBonus+ENBonusL;
    EBn:=Ebn+EbnL;

End;
  End;{for �� ��⠬}

 Dispose(K,Done);

 Writeln(f,'�������������������������������������������������������������������������������������������������������������'+
 '���������������������������������������������������������������������������������');
 s:='   �ᥣ�'+SeparatorChar+RealToStr(EPrihod,CZenaZ,CMantissa)+'�'+RealToStr(ESoSklada,CZenaZ,CMantissa)+'�'+
    +RealToStr(EDohod,CZenaZ,CMantissa)+'�'+'     �'+
     RealToStr(EDohodOpl,CZenaZ,CMantissa)+'�'+'     �'+
     RealToStr(ERashod,CZenaZ,CMantissa)+'�'+
    +RealToStr(ERp,CZenaZ,CMantissa)+'�'+RealToStr(ESdano,CZenaZ,CMantissa)+
    '�'+RealToStr(EBN,CZenaZ,CMantissa)+
    '�'+RealToStr(EBarter,CZenaZ,CMantissa)+'�'+RealToStr(EVZa,CZenaZ,CMantissa)+
    '�'+RealToStr(EOsta,CZenaZ,CMantissa)+
    '�'+RealToStr(ESF,CZenaZ,CMantissa)+'�'+RealToStr(EMinusDohod,CZenaZ,CMantissa)+
    '�'+RealToStr(ESkidki,CZenaZ,CMantissa)+
    '�'+'     �'++RealToStr(EBonus,CZenaZ,CMantissa)+'�'+
    RealToStr(ENBonus,CZenaZ,CMantissa)+'�'+
    RealToStr(ERwz,CZenaZ,CMantissa){+'�'+RealToStr(ESertif,CZenaZ,CMantissa)};

 While Pos('�',s)>0 Do s[Pos('�',s)]:=SeparatorChar;

 Writeln(f,s);
 Writeln(f);

 Writeln(f,'             ������ ����:'+SeparatorChar,(Tag):CKol);
If Tag>0 Then
Begin
 Writeln(f,'         � �।��� ��室:'+SeparatorChar,EPrihod/(Tag):CIZena+2:CMantissa);

 Writeln(f,'      � �।��� � ᪫���:'+SeparatorChar,ESoSklada/(Tag):CIZena+2:CMantissa);

 Writeln(f,'  � �।��� ��室 ����.:'+SeparatorChar,(EDohod-EMinusDohod)/(Tag):CIZena+2:CMantissa);

 Writeln(f,'  � �।��� ��室 �����.:'+SeparatorChar,(EDohodOpl)/(Tag):CIZena+2:CMantissa);

 Writeln(f,'         � �।��� ��室:'+SeparatorChar,(ERashod)/(Tag):CIZena+2:CMantissa);

 Writeln(f,'         � �।��� ᪨���:'+SeparatorChar,(ESkidki)/(Tag):CIZena+2:CMantissa);

 Writeln(f,'           � �।��� �/� :'+SeparatorChar,ERp/(Tag):CIZena+2:CMantissa);

 Writeln(f,'       � �।��� ॢ���� :'+SeparatorChar,ERwz/(Tag):CIZena+2:CMantissa);

 Writeln(f,'  � �।��� �뤠�� �����.:'+SeparatorChar,EBonus/(Tag):CIZena+2:CMantissa);

 Writeln(f,'  � �।��� ����.�����.:'+SeparatorChar,ENBonus/(Tag):CIZena+2:CMantissa);

 Writeln(f,'          � �।��� ᤠ��:'+SeparatorChar,ESdano/(Tag):CIZena+2:CMantissa);

 Writeln(f,'� �।��� ���.���.����㯫:'+SeparatorChar,EBN/(Tag):CIZena+2:CMantissa);

 Writeln(f,'        � �।��� ������:'+SeparatorChar,EVZa/(Tag):CIZena+2:CMantissa);

 Writeln(f,'      � �।��� ���⮪ �:'+SeparatorChar,EOsta/(Tag):CIZena+2:CMantissa);
End;

 Writeln(f);
 Writeln(f,'[�ਬ�砭��:]');
 Close(f1);

 Assign(f1,Path^.Dat.ToTemp+'kassaer.txt');
 i:=IOResult;
 Reset(f1);
 i:=IOResult;
 While Not (Eof(f1)) Do
  Begin
 i:=IOResult;
   Readln(f1,s);
 i:=IOResult;
   Writeln(f,s);
  End;
 Close(f1);
 i:=IOResult;

  Writeln(f);




  Writeln(f,' �⯥�⠭�:"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

 Writeln(f,'============================================================================================================='+
 '====================================================='+
 GlobalPrn^.Dat.OrientNormal[Nprint^.DAt.Printer]+
 GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]+
 GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);



  Close(f);
 i:=IOResult;
 NoInfoMsg;
 ViewAsText(Path^.Dat.ToTemp+'nstati.txt','����⨪� �� ��� �� ��ਮ� � '+Start+' �� '+Stop,True);
 {Report(Path^.Dat.ToTemp+'nstati.txt','',NprintC^.DAt.CopyAll,False,False);}
End;



{$ELSE}
Procedure FormReportKAssa;
Begin
End;

{$ENDIF}



End.