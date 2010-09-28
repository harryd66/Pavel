{РОСС RU.ПР71.В46374.02286114 16.09.99 ГОССТАНДАРТ РОССИИ ТЕСТ_С1}

{$I Compile.INC}


{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

unit Vision2;

Interface

Uses Glob,Dialogs,ServStr,Serv;

Function ViewAllPrihod (Date: TDateString;Regim:Boolean;Default:Byte):AllStr;
Procedure PrintPrihod (As : DocumentEdit);

Function NewPrintVozwrat(As : DocumentEdit):Boolean;
Function  NewViewAllVozwrat (Date: TDateString;Regim:Boolean;Default:Byte):AllStr;

Function ViewAllAktPrz (Date: TDateString;Regim:Boolean;Default:Byte):AllStr;

Procedure PrintAktPrz (As : DocumentEdit);
Procedure FormAktFile (E : PPereozenkaType; DAte: TDateString);

Function ViewOplReal(Dates:TDateString;Regim : Boolean):AllStr;

Function CalcDolgDebit(Default:Byte;Regim:Boolean):TMyString;

Procedure CalcVozwratfromConsig(Date: TDateString;Var Return:AllStr;
Var ReturnKol : ArtikulStr; Var ReturnSkid:AllStr;
Var ReturnSf  :AllStr; Var ReturnSfKol : ArtikulStr;
Var ReturnSFSkid:AllStr;Var SNAlogReturnOpenConsig:AllStr);

Procedure CalcVozwratfromSFNal(Date: TDateString;
Var ReturnSfNal  :AllStr; Var ReturnSfKolNal : ArtikulStr; Var ReturnSFSkidNal:AllStr);

Procedure CalcVozwratfromNal(Date: TDateString;
Var ReturnNal  :AllStr; Var ReturnKolNal : ArtikulStr; Var ReturnSkidNal:AllStr);

Procedure CalcRashodfromVozwrat(Date: TDateString;Var Vidano  :AllStr; Var VidanoKol : ArtikulStr;
Var VidanoC  :AllStr; Var VidanoCKol : ArtikulStr);


Function CalcInpSkladPerevoski (ClientKod : ArtikulStr):AllStr;
Function CalcOutSkladPerevoski (ClientKod : ArtikulStr):AllStr;
{procedure PrintingZeni(As : DocumentEdit;Vid:Byte);}
Function CalcDolgBarter(Regim:Boolean):TMyString;
Function ViewOplBArter(Dates:TDateString;Regim : Boolean):AllStr;
Function CalcPrihodBarter (Date:TDateString):AllStr;
Procedure CreatPlan;
Procedure CalcOplBArter(Dates:TDateString;Var All,AllN,AllBN:Real);
Procedure CretLockReport;

implementation

(*{$IfNDEF DPMI}*)

Uses Objects,Views,DBEngine,MsgBox,Tools,Printers,{Views,}TpDate,Vision4,
     Access,NetDBEng,Utils,Vision5,Net,Dos;


(*
{$Else}
Uses DBEngine,MsgBox,Tools,Printers,Views,TpDate,Vision1;
{$EndIf}*)

Function TestLastDivision(M:TKolString;Position:Word):Boolean;
Var c: Word;
Begin
TestLastDiviSion:=True;
Inc(Position);

If Position>CDivision Then Exit;

  For c:=Position To CDiviSion Do
   Begin
    Delspace(M[c]);
    If StrToInt(M[c])<>0 Then
     Begin
      TestLastDiviSion:=False;
      Break;
     End;
   End;

End;


{$IFNDEF Kurz}

Function ViewAllPrihod (Date: TDateString;Regim:Boolean;Default:Byte):AllStr;
Var f : PrihodFileType;
    E : PPrihodType;
    ws,ws1 : string[150];
    SProz,Nalog,Fas,P : String[CPack];
    ItogoOZ,ItogoRZ,ItogoNo : Real;
    St : String[CMantissa];
    SArtikul,ss,ss1 : TEnjoyStr;
    l : Word;
    K : Byte;
    Vid:Byte;
    txt : Text;
    DocNo,Doc : LongInt;
    PrintNumer : Boolean;
    DDD : ArtikulStr;
    ShkalaZ : string[150];
    Barter : String[CMantissa];

Begin
{ ViewAllPrihod:='0.00'^M+#3'(0.00)';}
 ViewAllPrihod:='           0.00            0.00   0   0';
{                123456789012345 123456789012345 123 123}
 Assign(F,Path.ToPrihod+Date+'.prh');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
  If Regim Then
   MessageBox(#3^M+#3'Не найден файл '+Path.ToPrihod+Date+'.prh',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt,Path.ToTemp+'prihod.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   If Regim Then
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'prihod.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

  Vid:=Default;
  If Regim Then
  Begin
  Vid:=SelectSpecify(False,8);
  If Vid=4 Then
   Begin
    CLose(f);
    Close(txt);
    Exit;
   End;
  End;
ItogoOZ:=0;
ItogoRZ:=0;
ItogoNO:=0;
Doc:=0;
DocNo:=0;
If Regim Then  DInfo('Минуточку...');
  New(E,Init);
  While Not Eof(f) Do
  Begin
    {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(PrihodType),SizeOf(PrihodType));
    }
     ReadPrihod(f,E);
    {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(PrihodType),SizeOf(PrihodType));
     Until (DosError=0);
    }

If (E^.Dat.OperatorSelector=Vid) Or (Vid=3) Then
Begin
If Regim Then
Begin
Writeln(Txt,'Склад: ',{E^.Dat.Sklad}GetClientField(FClient,E^.Dat.SkladKod,1)+'  Оператор: '+E^.Dat.Caption);
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Write(txt,{'Последние изменения:'+}' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
If E^.Dat.StatusDoc=0 Then Writeln(Txt,' СТАТУС:'+' Документ введен на склад')
Else Writeln(Txt,' СТАТУС:'+' Документ подлежит согласованию');

BArter[0]:=#0;
If E^.Dat.OperatorSelector=2 Then Barter:='-Б';

If E^.Dat.OperatorSelector in [0,2] Then
Writeln(Txt,'                      Н А К Л А Д Н А Я (приход) N '+E^.Dat.Document+Barter+' от '+
E^.Dat.DateC+' ('+E^.Dat.TimeC+')')
Else
Writeln(Txt,'                Н А К Л А Д Н А Я (межскладской приход) N '+E^.Dat.Document+Barter+' от '+
E^.Dat.DateC+' ('+
E^.Dat.TimeC+')');
Writeln(Txt,'Поставщик: '+GetMakeField(FClient,E^.Dat.MakeKod,E^.Dat.OperatorSelector)+' '+E^.Dat.MakeKod);
Writeln(Txt,'Получатель: ',GetMakeField(FClient,Rek.Kod,1));
Writeln(Txt,'----------------------------------------------------------------------------------------');
Writeln(Txt,' N  Код  Наименование товара        Колич. Упаковок Фас   З/Цена   Р/Цена Нацен. НП  Отд');
Writeln(Txt,'----------------------------------------------------------------------------------------');
           {     123  12345678901234567890123456 12345 123456789 123 12345678 12345678 12.45 12345 1
             12345678901234567890123456789012345678901234567890123456789012345678901234567890
}
End;{Regim}
 l:=1;
{While E^.Dat.PrihodElement[l].BazKod[0]<>#0 Do}

For l:=1 To E^.Dat.Amount Do
 Begin

If (StrToInt(E^.Dat.PrihodElement[l].Input.Kol)>0) Then
Begin
 ShkalaZ[0]:=#0;
 For k:=1 To 2{CShkala} Do
  Begin
   ShkalaZ:=ShkalaZ+' Ц_'+IntToStr(k,COne)+':';
   MyStr(StrToReal(E^.Dat.PrihodElement[l].Input.R_Zena)*
   StrToReal(E^.Dat.PrihodElement[l].Input.AutoSkidka[k]),CZena,CMAntissa,ws);
   DelSpace(ws);
   ShkalaZ:=ShkalaZ+ws+' ';
  End;
 Writeln(txt,' '+ShkalaZ);
End;

 PrintNumer:=True;
 str(L:2,st);
 For k:=1 To CDivision Do
 Begin
 DelSpace(E^.Dat.PrihodElement[l].Input.DivisionS[k]);
If (StrToInt(E^.Dat.PrihodElement[l].Input.DivisionS[k])>0) Then
 Begin
 Format(E^.Dat.PrihodElement[l].BazKod,CArtikul);
 SArtikul:=E^.Dat.PrihodElement[l].BazKod;
{
 ws:=GetIdField(FName,E^.Dat.PrihodElement[l].BazKod);
}
 ws:=GetIdField(FName,E^.Dat.PrihodElement[l].BazKod);
 ws1:=GetIdField(FName2,E^.Dat.PrihodElement[l].BazKod);
 DelSpaceRight(ws1);
 If ws1[0]<>#0 Then
  Begin
   Writeln(txt,St+' '+SArtikul+' '+ws);
   SArtikul:='     ';
   St:='  ';
   ws:=ws1;
  End;




 Format(ws,CName);


 Str(StrToInt(E^.Dat.PrihodElement[l].Input.DiviSionS[k]):CKol,E^.Dat.PrihodElement[l].Input.DiviSionS[k]);
 DelSpace(E^.Dat.PrihodElement[l].Input.DiviSionS[k]);
 RFormat(E^.Dat.PrihodElement[l].Input.DivisionS[k],CKol);
 P:=CalcPack(E^.Dat.PrihodElement[l].BazKod,E^.Dat.PrihodElement[l].Input.DivisionS[k]);
 DelSpace(P);
 RFormat(P,CPack);
 DelSpace(E^.Dat.PrihodElement[l].Input.R_Zena);
 RFormat(E^.Dat.PrihodElement[l].Input.R_Zena,CZena);

 DelSpace(E^.Dat.PrihodElement[l].Input.Zakupka);
 RFormat(E^.Dat.PrihodElement[l].Input.Zakupka,CZena);

 DelSpace(E^.Dat.PrihodElement[l].Input.O_Zena);
 RFormat(E^.Dat.PrihodElement[l].Input.O_Zena,CZena);
 Fas:=GetIdField(FInPack,E^.Dat.PrihodElement[l].BazKod);
 Str(StrToInt(Fas):CInPack,Fas);

 Format(Fas,CInPack);

 Nalog:=GetIdField(FNalog,E^.Dat.PrihodElement[l].BazKod);
 MyStr(StrToReal(Nalog),Clitr,CMantissa,NAlog);

 SProz:='?????';
 If StrToReal(E^.Dat.PrihodElement[l].Input.Zakupka)>0.009 Then
  Begin
   MyStr((StrToReal(E^.Dat.PrihodElement[l].Input.R_Zena)-
          StrToReal(E^.Dat.PrihodElement[l].Input.Zakupka))/
		StrToReal(E^.Dat.PrihodElement[l].Input.Zakupka)*100,CLitr,CMantissa,SProz);
  End;



 ws:=SArtikul+' '+ws+' '+E^.Dat.PrihodElement[l].Input.DivisionS[k]+
   +' '+P+' '+Fas+' '+E^.Dat.PrihodElement[l].Input.Zakupka+' '+E^.Dat.PrihodElement[l].Input.R_Zena+' '+SProz+
   +' '+Nalog
   {E^.Dat.PrihodElement[l].Input.O_Zena};
(*
 Str((StrToInt(E^.Dat.PrihodElement[l].Input.DiviSion[k])*StrToReal(E^.Dat.PrihodElement[l].Input.R_Zena)):
 CInputIZena:CMantissa,ss);

 ws:=ws+' '+ss+' '{+P};
*)

 Str(k:2,P);

 DDD[0]:=#0;
 If Not(GetIdMarket(E^.Dat.PrihodElement[l].BAzKod)=1) Then DDD:=' З';

 If Regim Then
 Begin
   If TestLastDiviSion(E^.Dat.PrihodElement[l].Input.DivisionS,K) Then
  Begin
     If PrintNumer Then
      Begin
      Writeln(txt,st+' '+ws+P+DDD);
      PrintNumer:=False;
      End
     Else
      Writeln(txt,'   '+ws+P+DDD)
  End
  Else
     Begin
      If PrintNumer Then
      Begin
      Writeln(txt,st+' '+ws+P+DDD);
      PrintNumer:=False;
      End
      Else
      Writeln(txt,'   '+ws+P+DDD)
     End;
{
 If k=1 Then Writeln(txt,St+' '+ws)
 Else Writeln(txt,'   '+ws)}
 End;
 End;
 End;{For}
 If Regim Then
 Begin
 DelSpaceRight(E^.Dat.PrihodElement[l].Input.NSertif);
 If E^.Dat.PrihodElement[l].Input.NSertif[0]<>#0 Then
 Writeln(txt,' Сертификат: ',E^.Dat.PrihodElement[l].Input.NSertif);
 DelSpaceRight(E^.Dat.PrihodElement[l].Input.Akzis1);
 If E^.Dat.PrihodElement[l].Input.Akzis1[0]<>#0 Then
 Writeln(txt,' Примечание: ',E^.Dat.PrihodElement[l].Input.Akzis1);
 End;
{ Inc(l);}
 End;
 ItogoOZ:=ItogoOZ+StrToReal(E^.Dat.SummaO);
 ItogoRZ:=ItogoRZ+StrToReal(E^.Dat.SummaR);
 Inc(Doc);
 If E^.Dat.StatusDoc=1 Then Begin
                             ItogoNo:=ItogoNo+StrToReal(E^.Dat.SummaR);
                             Inc(DocNo);
                            End;
If Regim Then
Begin
RFormat(E^.Dat.SummaR,CIZena);
RFormat(E^.Dat.SummaO,CIZena);
RFormat(E^.Dat.SummaL,CIZena);
RFormat(E^.Dat.SummaZakupka,CIZena);
Writeln(Txt,'----------------------------------------------------------------------------------------');
Writeln(Txt,'                                               Всего наименований: ',E^.Dat.Amount:CIZena);
Writeln(Txt,'                                                 Всего по З/Ценам: ',Recogniz(E^.Dat.SummaZakupka));

Writeln(Txt,'                                                 Всего по Р/Ценам: ',Recogniz(E^.Dat.SummaR));
Writeln(Txt,'                                                 Всего по О/Ценам: ',Recogniz(E^.Dat.SummaO));
{Writeln(Txt,'                                                  Всего литраж    : ',Recogniz(E^.Dat.SummaL));}
Writeln(Txt,'========================================================================================');
Writeln(Txt);
End;
End;
  End;
If Regim Then
Begin
Writeln(txt,'Всего приход за '+Date+' составил: по Р/Ц ',RecognizReal(ItogoRZ,CIZena,CMantissa),' руб.');
Writeln(txt,'                                   по О/Ц ',RecognizReal(ItogoOZ,CIZena,CMantissa),' руб.');
Str(Doc:CLitrMAntissa,ws);
Writeln(Txt,'         Всего за день документов: ',Ws);
End;
  Close(f);
  Close(Txt);
If Regim Then NoInfo;
 Dispose(E,Done);
If Regim Then  ViewAsText(Path.ToTemp+'prihod.txt',False);
MyStr(ItogoRZ,CIZena,CMantissa,ss);
MyStr(ItogoNo,CIzena,CMantissa,ss1);
ss:=ss+' '+ss1;
Str(Doc:3,ss1);
ss:=ss+' '+ss1;
Str(DocNo:3,ss1);
ss:=ss+' '+ss1;
{ViewAllPrihod:=RecognizReal(ItogoRZ,CIZena,CMantissa)+''^M+#3+'('+RecognizReal(ItogoNo,CIZena,CMantissa)+')';}
ViewAllPrihod:=ss;
End;

{$ELSE}

Function ViewAllPrihod (Date: TDateString;Regim:Boolean;Default:Byte):AllStr;
Begin
End;

{$ENDIF}



Procedure CalcVozwratfromConsig(Date: TDateString;Var Return:AllStr;
Var ReturnKol : ArtikulStr; Var ReturnSkid:AllStr;
Var ReturnSf  :AllStr; Var ReturnSfKol : ArtikulStr;
Var ReturnSFSkid:AllStr;Var SNAlogReturnOpenConsig:AllStr);

Var f : NewVozwratFileType;
    E : PNewVozwratType;
    ws : string[150];
    St : String[CMantissa];
    ss,ss1 : TEnjoyStr;
    Summa : String[CIZena];
    l : Word;
    K : Byte;
    Vid:Byte;
Begin
{1}          Return :='           0.00';
                      {123456789012345}
{2}       ReturnKol :='  0';
                      {123}
{3}      ReturnSkid :='           0.00';
                      {123456789012345}
                      {123}
{4}       ReturnSf  :='           0.00';
                      {123456789012345}
{5}     ReturnSfKol :='  0';
                      {123}
{6}    ReturnSFSkid :='           0.00';
{7}
SNAlogReturnOpenConsig :='           0.00';
                         {123456789012345}

 Assign(F,Path.ToReturn+Date+'.vzw');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;

 If L <> 0 Then
  Begin
   Exit;
  End;

  New(E,Init);
  While Not Eof(f) Do
  Begin
    {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
    }
     ReadNewVozwrat(f,E);
    {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
    }

   If (E^.Dat.VidDocument in [4,5]) And (E^.Dat.StatusDoc=0) Then
    Begin
{1}   MyStr (StrToReal(Return)+StrToReal(E^.Dat.SummaR),CIZena,CMantissa,Return);
{2}   Str (StrToInt(ReturnKol)+1:CLitrMantissa,ReturnKol);
{3}   MyStr (StrToReal(ReturnSkid)+StrToReal(E^.Dat.Skidka),CIZena,CMantissa,ReturnSkid);

         If TestSF(E^.Dat.MakeKod,E^.Dat.BasisDoc,E^.Dat.BasisDate) Then
           Begin
{4}   MyStr (StrToReal(ReturnSf)+StrToReal(E^.Dat.SummaR),CIZena,CMantissa,ReturnSf);
{5}   Str (StrToInt(ReturnSfKol)+1:CLitrMantissa,ReturnSfKol);
{6}   MyStr (StrToReal(ReturnSFSkid)+StrToReal(E^.Dat.Skidka),CIZena,CMantissa,ReturnSFSkid);
        End;
    End;


   If (E^.Dat.DocSelector in [5,6]) And (E^.Dat.StatusDoc=0) Then
    Begin
{7}   MyStr (StrToReal(SNalogReturnOpenConsig)+StrToReal(E^.Dat.ENalog),CIZena,CMantissa,
      SNalogReturnOpenConsig);
    End;

  End;
Close(f);
Dispose(E,Done);
End;


Procedure CalcVozwratfromSFNal(Date: TDateString;
Var ReturnSfNal  :AllStr; Var ReturnSfKolNal : ArtikulStr; Var ReturnSFSkidNal:AllStr);

Var f : NewVozwratFileType;
    E : PNewVozwratType;
    ws : string[150];
    St : String[CMantissa];
    ss,ss1 : TEnjoyStr;
    Summa : String[CIZena];
    l : Word;
    K : Byte;
    Vid:Byte;
Begin
{4}       ReturnSfNal  :='           0.00';
                                  {123456789012345}
{5}     ReturnSfKolNal :='  0';
                                  {123}
{6}    ReturnSFSkidNal :='           0.00';
                                  {123456789012345}

 Assign(F,Path.ToReturn+Date+'.vzw');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   Exit;
  End;

  New(E,Init);
  While Not Eof(f) Do
  Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     }
     ReadNewVozwrat(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     }
   If (E^.Dat.VidDocument in [1,2,3,0])And(E^.Dat.Opt)And(E^.Dat.StatusDoc=0) Then
    Begin
{4}   MyStr (StrToReal(ReturnSfNal)+StrToReal(E^.Dat.SummaR),CIZena,CMantissa,ReturnSfNal);
{5}   Str (StrToInt(ReturnSfKolNal)+1:CLitrMantissa,ReturnSfKolNal);
{6}   MyStr (StrToReal(ReturnSFSkidNal)+StrToReal(E^.Dat.Skidka),CIZena,CMantissa,ReturnSFSkidNal);
    End;
  End;
Close(f);
Dispose(E,Done);
End;

Procedure CalcVozwratfromNal(Date: TDateString;
Var ReturnNal  :AllStr; Var ReturnKolNal : ArtikulStr; Var ReturnSkidNal:AllStr);

Var f : NewVozwratFileType;
    E : PNewVozwratType;
    ws : string[150];
    St : String[CMantissa];
    ss,ss1 : TEnjoyStr;
    Summa : String[CIZena];
    l : Word;
    K : Byte;
    Vid:Byte;
Begin
{4}       ReturnNal  :='           0.00';
                                  {123456789012345}
{5}     ReturnKolNal :='  0';
                                  {123}
{6}    ReturnSkidNal :='           0.00';
                                  {123456789012345}

 Assign(F,Path.ToReturn+Date+'.vzw');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   Exit;
  End;

  New(E,Init);
  While Not Eof(f) Do
  Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     }
     ReadNewVozwrat(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     }
   If (E^.Dat.VidDocument in [1,2,3,0]) And (E^.Dat.StatusDoc=0) Then
    Begin
{4}   MyStr (StrToReal(ReturnNal)+StrToReal(E^.Dat.SummaR),CIZena,CMantissa,ReturnNal);
{5}   Str (StrToInt(ReturnKolNal)+1:CLitrMantissa,ReturnKolNal);
{6}   MyStr (StrToReal(ReturnSkidNal)+StrToReal(E^.Dat.Skidka),CIZena,CMantissa,ReturnSkidNal);
    End;
  End;
Close(f);
Dispose(E,Done);
End;

Procedure CalcRashodfromVozwrat(Date: TDateString;Var Vidano  :AllStr; Var VidanoKol : ArtikulStr;
Var VidanoC  :AllStr; Var VidanoCKol : ArtikulStr);
Var f : NewVozwratFileType;
    E : PNewVozwratType;
    ws : string[150];
    St : String[CMantissa];
    ss,ss1 : TEnjoyStr;
    Summa : String[CIZena];
    l : Word;
    K : Byte;
    Vid:Byte;
Begin
{4}       Vidano  :='           0.00';
{4}       VidanoC :='           0.00';
                    {123456789012345}
{5}     VidanoKol :='  0';
{5}     VidanoCKol:='  0';
                    {123}

 Assign(F,Path.ToReturn+Date+'.vzw');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   Exit;
  End;

  New(E,Init);
  While Not Eof(f) Do
  Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     }
     ReadNewVozwrat(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     }
   If (E^.Dat.Rashod) And (E^.Dat.StatusDoc=0) Then
    Begin
{4}   MyStr (StrToReal(Vidano)+StrToReal(E^.Dat.RashodSumma),CIZena,CMantissa,Vidano);
{5}   Str (StrToInt(VidanoKol)+1:CLitrMantissa,VidanoKol);
     If (E^.Dat.VidDocument in [4,5]) Then
      Begin
 {4}   MyStr (StrToReal(VidanoC)+StrToReal(E^.Dat.RashodSumma),CIZena,CMantissa,VidanoC);
 {5}   Str (StrToInt(VidanoCKol)+1:CLitrMantissa,VidanoCKol);
      End;

    End;

  End;
Close(f);
Dispose(E,Done);
End;

Function  NewViewAllVozwrat (Date: TDateString;Regim:Boolean;Default:Byte):AllStr;
Var f : NewVozwratFileType;
    E : PNewVozwratType;
    Adres,ws,ws1 : string[150];
    Fas,P : String[CPack];
    ItogoOZ,ItogoRZ,ItogoNo : Real;
    St : String[CLitr];
    koefficient,ss,ss1 : TEnjoyStr;
    SArtikul,Summa : String[CIZena];
    l : Word;
    K : Byte;
    Vid:Byte;
    txt : Text;
    Doc,DocNo : LongInt;
    VVV : DocumentEdit;
    PP : PSuperMarketType;
Begin
 NewViewAllVozwrat:='           0.00            0.00   0   0';
 Assign(F,Path.ToReturn+Date+'.vzw');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
  If Regim Then
   MessageBox(#3^M+#3'Не найден файл '+Path.ToReturn+Date+'.vzw',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt,Path.ToTemp+'vozwrat.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
  If Regim Then
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'vozwrat.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
  Vid:=Default;
  If Regim Then
  Begin
  Vid:=SelectSpecify(False,0);
  If Vid=3 Then
   Begin
    CLose(f);
    Close(txt);
    Exit;
   End;
  End;
ItogoOZ:=0;
ItogoRZ:=0;
ItogoNo:=0;
Doc:=0;
DocNo:=0;
If Regim Then   DInfo('Минуточку...');
  New(E,Init);

  While Not Eof(f) Do
  Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     }
     ReadNewVozwrat(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     }
If (E^.Dat.OperatorSelector=Vid) Or (Vid=2) Then
Begin
 If Regim Then
  Begin
   Writeln(Txt,'Склад: ',{E^.Dat.Prihod.Sklad}GetClientField(FClient,E^.Dat.SkladKod,1)+
             '  Оператор: '+E^.Dat.Caption);
   If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
      Write(txt,{'Последние изменения:'+}' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
   If E^.Dat.StatusDoc=0 Then Writeln(Txt,' СТАТУС:'+' Документ введен на склад')
                         Else Writeln(Txt,' СТАТУС:'+' Документ подлежит согласованию');


   Write(Txt,' ВИД ВОЗВРАТА:');
   Case E^.Dat.VidDocument Of
   0:Writeln(txt,' Продажа, скидка автоматическая');
   1:Writeln(txt,' Продажа, скидка ручная');
   2:Writeln(txt,' Закрытая консигнация, скидка автоматическая');
   3:Writeln(txt,' Закрытая консигнация, скидка ручная');
   4:Writeln(txt,' Открытая консигнация, скидка автоматическая!');
   5:Writeln(txt,' Открытая консигнация, скидка ручная!');
   Else;
   End;



   If E^.Dat.OperatorSelector=0 Then
    Begin
     If E^.Dat.Opt Then
      Writeln(Txt,'                Н А К Л А Д Н А Я  возврата  N '+E^.Dat.Document+' от '+E^.Dat.DateC+' ('+
      E^.Dat.TimeC+')')
      Else
      Writeln(Txt,'                    Д О К У М Е Н Т  возврата N '+E^.Dat.Document+' от '+E^.Dat.DateC+' ('+
      E^.Dat.TimeC+')');
    End{E^.Dat.OperatorSelector=0}
    Else
    Writeln(Txt,'               Д О К У М Е Н Т межскладского возврата N '+E^.Dat.Document+' от '+E^.Dat.DateC+
    ' ('+E^.Dat.TimeC+')');


  Adres[0]:=#0;

  Writeln(Txt,'Основание: по документу N '+E^.Dat.BasisDoc+' от '+E^.Dat.BasisDate+' '+Adres);
  Writeln(Txt,'Поставщик: '+GetClientField(FClient,E^.Dat.MakeKod,E^.Dat.OperatorSelector)+' '+E^.Dat.MakeKod);
  Writeln(Txt,'Получатель: ',GetMakeField(FClient,Rek.Kod,1));
  Writeln(Txt,'----------------------------------------------------------------------------------');
  Writeln(Txt,' N  Код  Наименование товара        Фас Колич. Упаковок     Цена Итог со СК.НП Отд');
  Writeln(Txt,'----------------------------------------------------------------------------------');
End;{Regim}
  l:=1;
  For l:=1 To E^.Dat.Amount Do
   Begin
    str(L:2,st);
    Format(E^.Dat.VozwratElement[l].BazKod,CArtikul);
    SArtikul:=E^.Dat.VozwratElement[l].BazKod;
{
    ws:=GetIdField(FNAme,E^.Dat.VozwratElement[l].BazKod);
}
 {
 If NPrint.FullName=0 Then
 Begin
  ws:=GetIdField(FName,E^.Dat.VozwratElement[l].BazKod);
 End
 Else
  Begin
   ws:=GetIdField(FFName,E^.Dat.VozwratElement[l].BazKod);
  End;
    Format(ws,CName);
  }
 If NPrint.FullName=0 Then
  Begin
   ws:=GetIdField(FName,E^.Dat.VozwratElement[l].BazKod);
  ws1:=GetIdField(FName2,E^.Dat.VozwratElement[l].BazKod);
  DelSpaceRight(ws1);
   If ws1[0]<>#0 Then
    Begin
     Writeln(txt,st+' '+SArtikul+' '+ws);
     st:='  ';
     SArtikul:='     ';
     ws:=ws1;
    End;
 End
 Else
  Begin
   ws:=GetIdField(FFName,E^.Dat.VozwratElement[l].BazKod);
   ws1:=GetIdField(FFName2,E^.Dat.VozwratElement[l].BazKod);
   DelSpaceRight(ws1);
   If ws1[0]<>#0 Then
    Begin
     Writeln(txt,st+' '+SArtikul+' '+ws);
     st:='  ';
     SArtikul:='     ';
     ws:=ws1;
    End;
  End;

    Format(ws,CName);



    DelSpace(E^.Dat.VozwratElement[l].Input.Kol);
    RFormat(E^.Dat.VozwratElement[l].Input.Kol,CKol);
    P:=CalcPack(E^.Dat.VozwratElement[l].BazKod,E^.Dat.VozwratElement[l].Input.Kol);
    DelSpace(P);
    RFormat(P,CPack);

    MyStr((1+StrToReal(E^.Dat.VozwratElement[l].Input.SpecNalog)/100),CLitr,CMantissa,
    Koefficient);
    DelSpace(Koefficient);


If E^.Dat.DocSelector in [1,2,3,5,6] Then
   Begin

Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)*
           (StrToReal(E^.Dat.VozwratElement[l].Input.LocalProz)),CZena,CMantissa,E^.Dat.VozwratElement[l].Input.Zena);
        MyStr(StrToREal(E^.Dat.VozwratElement[l].Input.Zena){/*StrToReal(Koefficient)},CZena,CMantissa,
                         E^.Dat.VozwratElement[l].Input.Zena);

       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)-
                    StrToReal(E^.Dat.VozwratElement[l].Input.LocalSkidka),CZena,CMantissa,
                    E^.Dat.VozwratElement[l].Input.Zena);
          MyStr(StrToREal(E^.Dat.VozwratElement[l].Input.Zena){/*StrToReal(Koefficient)},CZena,CMantissa,
                        E^.Dat.VozwratElement[l].Input.Zena);
        End;
Else;
End;{Case}
End{If VidDocSelector}

Else

 Begin
Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)*
           (StrToReal(E^.Dat.VozwratElement[l].Input.LocalProz)),CZena,CMantissa,E^.Dat.VozwratElement[l].Input.Zena);
       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)-
                    StrToReal(E^.Dat.VozwratElement[l].Input.LocalSkidka),CZena,CMantissa,
                    E^.Dat.VozwratElement[l].Input.Zena);
        End;
Else;
End;{Case}
 End;

(*
    Case E^.Dat.VidDocument Of
     0,2,4:{Авто}  Str(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)/
                  (1+StrToReal(E^.Dat.VozwratElement[l].Input.LocalProz)):CIZena:CMantissa,
                  E^.Dat.VozwratElement[l].Input.Zena);

     1,3,5:{Ручная}Str(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)-
                  StrToReal(E^.Dat.VozwratElement[l].Input.LocalSkidka):CIZena:CMantissa,E^.Dat.VozwratElement[l].Input.Zena);
    Else;
    End;{Case}
*)

    DelSpace(E^.Dat.VozwratElement[l].Input.Zena);
    RFormat(E^.Dat.VozwratElement[l].Input.Zena,CZena);

    Fas:=GetIdField(FInPack,E^.Dat.VozwratElement[l].BazKod);
    DelSpace(Fas);
    Format(Fas,CInPack);

    ws:=SArtikul+' '+ws+' '+Fas+' '+E^.Dat.VozwratElement[l].Input.Kol+
    +' '+P+' '+E^.Dat.VozwratElement[l].Input.Zena;

    MyStr((StrToInt(E^.Dat.VozwratElement[l].Input.Kol)*StrToReal(E^.Dat.VozwratElement[l].Input.Zena))
    ,CInputIZena,CMantissa,ss);

    Str(StrToInt(E^.Dat.VozwratElement[l].Input.DivisionS):2,P);
    ws:=ws+' '+ss+' '+P;
    If Regim Then Writeln(txt,St+' '+ws)
  End;{For}

  ItogoOZ:=ItogoOZ+StrToReal(E^.Dat.SummaO);
  ItogoRZ:=ItogoRZ+StrToReal(E^.Dat.SummaR);
  Inc(Doc);
  If E^.Dat.StatusDoc=1 Then
   Begin
    ItogoNo:=ItogoNo+StrToReal(E^.Dat.SummaR);
    Inc(DocNo);
   End;
  If Regim Then
   Begin
    RFormat(E^.Dat.Skidka,CIZena);
    RFormat(E^.Dat.SummaR,CIZena);
    RFormat(E^.Dat.SummaO,CIZena);
    MySTr(StrToReal(E^.Dat.ENalog),CIZena,CMantissa,E^.Dat.ENalog);
    RFormat(E^.Dat.ENalog,CIZena);
    Writeln(Txt,'----------------------------------------------------------------------------------');
     Writeln(Txt,'                                           Всего наименований: ',E^.Dat.Amount:CIZena);
    If Not(E^.Dat.Opt) Then
     Begin
      Summa:=E^.Dat.SummaR;
     Writeln(Txt,'                                       Всего возврат на склад: ',Recogniz(E^.Dat.SummaR))
     End
     Else
      Begin
       Summa:=E^.Dat.SummaO;
     Writeln(Txt,'                                       Всего возврат на склад: ',Recogniz(E^.Dat.SummaO));
      End;
     Writeln(Txt,'                                             Скидка возврата : ',Recogniz(E^.Dat.Skidka));
     Writeln(Txt,'                                              НП по возврату : ',Recogniz(E^.Dat.ENalog));
     If StrToInt(CurrentPassword)=0 Then
      Begin
     Writeln(Txt,'                                Всего возврат на склад по З/Ц: ',Recogniz(E^.Dat.SummaZakupka));
     Writeln(Txt,'                                        Всего упущенный доход: ',Recogniz(E^.Dat.Delta));
      End;

     MyStr(StrToReal(Summa)-StrToReal(E^.Dat.Skidka){+StrToReal(E^.Dat.ENalog)},CIZena,CMantissa,Summa);
     Writeln(Txt,'                                                               ',Recogniz(Summa));
     MyStr(StrToReal(E^.DAt.RashodSumma),CIZena,CMantissa,Summa);
     Writeln(Txt,'                                       Всего к выдаче клиенту: ',Recogniz(Summa));
     Writeln(Txt,'==================================================================================');
     Writeln(Txt);
   End;
End;{If Vid=2 Or OperatorSelector=Vid}
End;{While}

If Regim Then
Begin
Writeln(txt,'Всего возврат за '+Date+' составил: по Р/Ц ',RecognizReal(ItogoRZ,CIZena,CMantissa),' руб.');
Writeln(txt,'                                    по О/Ц ',RecognizReal(ItogoOZ,CIZena,CMantissa),' руб.');
Str(Doc:CLitrMAntissa,ws);
Writeln(Txt,'          Всего за день документов: ',Ws);
End;

Dispose(E,Done);
If Regim Then  NoInfo;
  Close(f);
  Close(Txt);
If Regim Then
  ViewAsText(Path.ToTemp+'vozwrat.txt',False);

MyStr(ItogoRZ,CIZena,CMantissa,ss);
MyStr(ItogoNo,CIzena,CMantissa,ss1);
ss:=ss+' '+ss1;
Str(Doc:3,ss1);
ss:=ss+' '+ss1;
Str(DocNo:3,ss1);
ss:=ss+' '+ss1;
NewViewAllVozwrat:=ss;
End;



(*
Function  NewViewAllVozwrat (Date: TDateString;Regim:Boolean;Default:Byte):AllStr;
Var f : NewVozwratFileType;
    E : PNewVozwratType;
    ws : string[150];
    Fas,P : String[CPack];
    ItogoOZ,ItogoRZ,ItogoNo : Real;
    St : String[CMantissa];
    koefficient,ss,ss1 : TEnjoyStr;
    Summa : String[CIZena];
    l : Word;
    K : Byte;
    Vid:Byte;
    txt : Text;
    Doc,DocNo : LongInt;
Begin
 NewViewAllVozwrat:='           0.00            0.00   0   0';
 Assign(F,Path.ToReturn+Date+'.vzw');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
  If Regim Then
   MessageBox(#3^M+#3'Не найден файл '+Path.ToReturn+Date+'.vzw',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt,Path.ToTemp+'vozwrat.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
  If Regim Then
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'vozwrat.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
  Vid:=Default;
  If Regim Then
  Begin
  Vid:=SelectSpecify(False,0);
  If Vid=3 Then
   Begin
    CLose(f);
    Close(txt);
    Exit;
   End;
  End;
ItogoOZ:=0;
ItogoRZ:=0;
ItogoNo:=0;
Doc:=0;
DocNo:=0;
If Regim Then   DInfo('Минуточку...');
  New(E,Init);

  While Not Eof(f) Do
  Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     }
     ReadNewVozwrat(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     }
If (E^.Dat.OperatorSelector=Vid) Or (Vid=2) Then
Begin
 If Regim Then
  Begin
   Writeln(Txt,'Склад: ',{E^.Dat.Prihod.Sklad}GetClientField(FClient,E^.Dat.SkladKod,1)+
             '  Оператор: '+E^.Dat.Caption);
   If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
      Write(txt,{'Последние изменения:'+}' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
   If E^.Dat.StatusDoc=0 Then Writeln(Txt,' СТАТУС:'+' Документ введен на склад')
                         Else Writeln(Txt,' СТАТУС:'+' Документ подлежит согласованию');


   Write(Txt,' ВИД ВОЗВРАТА:');
   Case E^.Dat.VidDocument Of
   0:Writeln(txt,' Продажа, скидка автоматическая');
   1:Writeln(txt,' Продажа, скидка ручная');
   2:Writeln(txt,' Закрытая консигнация, скидка автоматическая');
   3:Writeln(txt,' Закрытая консигнация, скидка ручная');
   4:Writeln(txt,' Открытая консигнация, скидка автоматическая!');
   5:Writeln(txt,' Открытая консигнация, скидка ручная!');
   Else;
   End;



   If E^.Dat.OperatorSelector=0 Then
    Begin
     If E^.Dat.Opt Then
      Writeln(Txt,'                Н А К Л А Д Н А Я  возврата  N '+E^.Dat.Document+' от '+E^.Dat.DateC+' ('+
      E^.Dat.TimeC+')')
      Else
      Writeln(Txt,'                    Д О К У М Е Н Т  возврата N '+E^.Dat.Document+' от '+E^.Dat.DateC+' ('+
      E^.Dat.TimeC+')');
    End{E^.Dat.OperatorSelector=0}
    Else
    Writeln(Txt,'               Д О К У М Е Н Т межскладского возврата N '+E^.Dat.Document+' от '+E^.Dat.DateC+
    ' ('+E^.Dat.TimeC+')');

  Writeln(Txt,'Основание: по документу N '+E^.Dat.BasisDoc+' от '+E^.Dat.BasisDate);
  Writeln(Txt,'Поставщик: '+GetClientField(FClient,E^.Dat.MakeKod,E^.Dat.OperatorSelector)+' '+E^.Dat.MakeKod);
  Writeln(Txt,'Получатель: ',GetMakeField(FClient,Rek.Kod,1));
  Writeln(Txt,'----------------------------------------------------------------------------------');
  Writeln(Txt,' N  Код  Наименование товара        Фас Колич. Упаковок     Цена Итог со СК.НП Отд');
  Writeln(Txt,'----------------------------------------------------------------------------------');
End;{Regim}
  l:=1;
  For l:=1 To E^.Dat.Amount Do
   Begin
    str(L:2,st);
    Format(E^.Dat.VozwratElement[l].BazKod,CArtikul);
    ws:=GetIdField(FNAme,E^.Dat.VozwratElement[l].BazKod);
    Format(ws,CName);
    DelSpace(E^.Dat.VozwratElement[l].Input.Kol);
    RFormat(E^.Dat.VozwratElement[l].Input.Kol,CKol);
    P:=CalcPack(E^.Dat.VozwratElement[l].BazKod,E^.Dat.VozwratElement[l].Input.Kol);
    DelSpace(P);
    RFormat(P,CPack);

    Str((1+StrToReal(E^.Dat.VozwratElement[l].Input.SpecNalog)/100):CLitr:CMantissa,
    Koefficient);
    DelSpace(Koefficient);


If E^.Dat.DocSelector in [{1,}2,3,5,6] Then
   Begin

Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        Str(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)/
         (1+StrToReal(E^.Dat.VozwratElement[l].Input.LocalProz)/100):CZena:CMantissa,E^.Dat.VozwratElement[l].Input.Zena);
        Str(StrToREal(E^.Dat.VozwratElement[l].Input.Zena)*StrToReal(Koefficient):CZena:CMantissa,
                      E^.Dat.VozwratElement[l].Input.Zena);

       End;

1,3,5:{Ручная}
        Begin
          Str(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)-
              StrToReal(E^.Dat.VozwratElement[l].Input.LocalSkidka):CZena:CMantissa,
                        E^.Dat.VozwratElement[l].Input.Zena);
          Str(StrToREal(E^.Dat.VozwratElement[l].Input.Zena)*StrToReal(Koefficient):CZena:CMantissa,
                        E^.Dat.VozwratElement[l].Input.Zena);
        End;
Else;
End;{Case}
End{If VidDocSelector}

Else

 Begin
Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        Str(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)/
           (1+StrToReal(E^.Dat.VozwratElement[l].Input.LocalProz)/100):CZena:CMantissa,E^.Dat.VozwratElement[l].Input.Zena);
       End;

1,3,5:{Ручная}
        Begin
          Str(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)-
                    StrToReal(E^.Dat.VozwratElement[l].Input.LocalSkidka):CZena:CMantissa,
                    E^.Dat.VozwratElement[l].Input.Zena);
        End;
Else;
End;{Case}
 End;


    DelSpace(E^.Dat.VozwratElement[l].Input.Zena);
    RFormat(E^.Dat.VozwratElement[l].Input.Zena,CZena);

    Fas:=GetIdField(FInPack,E^.Dat.VozwratElement[l].BazKod);
    DelSpace(Fas);
    Format(Fas,CInPack);

    ws:=E^.Dat.VozwratElement[l].BazKod+' '+ws+' '+Fas+' '+E^.Dat.VozwratElement[l].Input.Kol+
    +' '+P+' '+E^.Dat.VozwratElement[l].Input.Zena;

    Str((StrToInt(E^.Dat.VozwratElement[l].Input.Kol)*StrToReal(E^.Dat.VozwratElement[l].Input.Zena)):
    CInputIZena:CMantissa,ss);

    Str(StrToInt(E^.Dat.VozwratElement[l].Input.Division):2,P);
    ws:=ws+' '+ss+' '+P;
    If Regim Then Writeln(txt,St+' '+ws)
  End;{For}

  ItogoOZ:=ItogoOZ+StrToReal(E^.Dat.SummaO);
  ItogoRZ:=ItogoRZ+StrToReal(E^.Dat.SummaR);
  Inc(Doc);
  If E^.Dat.StatusDoc=1 Then
   Begin
    ItogoNo:=ItogoNo+StrToReal(E^.Dat.SummaR);
    Inc(DocNo);
   End;
  If Regim Then
   Begin
    RFormat(E^.Dat.Skidka,CIZena);
    RFormat(E^.Dat.SummaR,CIZena);
    RFormat(E^.Dat.SummaO,CIZena);
    STr(StrToReal(E^.Dat.ENalog):CIZena:CMantissa,E^.Dat.ENalog);
    RFormat(E^.Dat.ENalog,CIZena);
    Writeln(Txt,'----------------------------------------------------------------------------------');
     Writeln(Txt,'                                           Всего наименований: ',E^.Dat.Amount:CIZena);
    If Not(E^.Dat.Opt) Then
     Begin
      Summa:=E^.Dat.SummaR;
     Writeln(Txt,'                                       Всего возврат на склад: ',Recogniz(E^.Dat.SummaR))
     End
     Else
      Begin
       Summa:=E^.Dat.SummaO;
     Writeln(Txt,'                                       Всего возврат на склад: ',Recogniz(E^.Dat.SummaO));
      End;
     Writeln(Txt,'                                             Скидка возврата : ',Recogniz(E^.Dat.Skidka));
     Writeln(Txt,'                                              НП по возврату : ',Recogniz(E^.Dat.ENalog));

     Str(StrToReal(Summa)-StrToReal(E^.Dat.Skidka)+StrToReal(E^.Dat.ENalog):CIZena:CMantissa,Summa);
     Writeln(Txt,'                                                               ',Recogniz(Summa));
     Str(StrToReal(E^.DAt.RashodSumma):CIZena:CMantissa,Summa);
     Writeln(Txt,'                                       Всего к выдаче клиенту: ',Recogniz(Summa));
     Writeln(Txt,'==================================================================================');
     Writeln(Txt);
   End;
End;{If Vid=2 Or OperatorSelector=Vid}
End;{While}

If Regim Then
Begin
Writeln(txt,'Всего возврат за '+Date+' составил: по Р/Ц ',RecognizReal(ItogoRZ,CIZena,CMantissa),' руб.');
Writeln(txt,'                                    по О/Ц ',RecognizReal(ItogoOZ,CIZena,CMantissa),' руб.');
Str(Doc:CLitrMAntissa,ws);
Writeln(Txt,'          Всего за день документов: ',Ws);
End;

Dispose(E,Done);
If Regim Then  NoInfo;
  Close(f);
  Close(Txt);
If Regim Then
  ViewAsText(Path.ToTemp+'vozwrat.txt',False);

Str(ItogoRZ:CIZena:CMantissa,ss);
Str(ItogoNo:CIzena:CMantissa,ss1);
ss:=ss+' '+ss1;
Str(Doc:3,ss1);
ss:=ss+' '+ss1;
Str(DocNo:3,ss1);
ss:=ss+' '+ss1;
NewViewAllVozwrat:=ss;
End;
*)

Function ViewAllAktPrz (Date: TDateString;Regim:Boolean;Default:Byte):AllStr;
Var f : PereozenkaFileType;
    E : PPereozenkaType;
    ws,ws1 : string[150];
    ItogoRZ,ItogoOZ : Real;
    SArtikul,ss,ss1 : TEnjoyStr;
    k,Vid,l : Word;
    txt : Text;
    Doc : LongInt;
    ShkalaZ: string[150];
Begin
 ViewAllAktPrz:='           0.00   0';
{                123456789012345 123}
 Assign(F,Path.ToCorrect+Date+'.prz');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
  If Regim Then
   MessageBox(#3^M+#3'Не найден файл '+Path.ToCorrect+Date+'.prz',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt,Path.ToTemp+'pereoz.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path.ToTemp+'pereoz.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

  Vid:=Default;
  If Regim Then
  Begin
  Vid:=SelectPrz;
  If Vid=3 Then
   Begin
    CLose(f);
    Close(txt);
    Exit;
   End;
  End;

  New(E,Init);
 ItogoRZ:=0;
 ItogoOZ:=0;


 Doc:=0;
If Regim Then   DInfo('Минуточку...');
  While Not Eof(f) Do
  Begin
   {
   Repeat
   Until Lock(f,FilePos(f)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
   }
   ReadPereozenka(F,E);
   {
   Repeat
    UnLock(f,(FilePos(f)-1)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
   Until DosError=0;
   }
   If (E^.Dat.Vid=Vid) Or (Vid=2) Then
   Begin
If Regim Then
Begin
Writeln(Txt,'Склад: ',{E^.Dat.Sklad}GetClientField(FClient,E^.Dat.SkladKod,1), '  Оператор: '+E^.Dat.Caption);
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt,{'Последние изменения:'+}' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
Writeln(Txt,'                        АКТ ПЕРЕОЦЕНКИ ТОВАРА N ',E^.Dat.Document,' от ',E^.Dat.DAteC+' ('+E^.Dat.TimeC+')');
If E^.Dat.Vid=1  Then
Writeln(Txt,'                   Переоценка проведена по документу возврата N '+E^.Dat.DocumentWith+' от '+E^.Dat.DateWith);
{Writeln(txt);
Writeln(Txt,'          Комиссия в составе:');
Writeln(Txt,'       1._____________________');
Writeln(Txt,'       2._____________________');
Writeln(Txt,'       3._____________________');
Writeln(Txt,'       4._____________________');
Writeln(Txt,'       произвела переоценку товара');}
Writeln(Txt,'                                               __ Было__        __ Стало __');
Writeln(Txt,'______________________________________________|_________|______|___________|_________________');

Writeln(Txt,' N  Код  Наименование товара        Колич   О/Цена   Р/Цена   О/Цена   Р/Цена  Переоценка Р/Ц ');
Writeln(Txt,'_____________________________________________________________________________________________');
End;
{                                                12345 12345678 12345678 12345678 12345678 123456789012345}
 l:=1;
{While E^.Dat.Element[l].BazKod[0]<>#0 Do}
 Inc(Doc);

For l:=1 To E^.Dat.Amount Do
 Begin

 ShkalaZ[0]:=#0;
 For k:=1 To 2{CShkala} Do
  Begin
   ShkalaZ:=ShkalaZ+' Ц_'+IntToStr(k,COne)+':';
   MyStr((StrToReal(E^.Dat.Element[l].New_R_Zena)*
   (StrToReal(E^.Dat.Element[l].AutoSkid[k]))),CZena,CMAntissa,ws);
   DelSpace(ws);
   ShkalaZ:=ShkalaZ+ws+' ';
  End;
 Writeln(txt,'  '+ShkalaZ);
 Format(E^.Dat.Element[l].BazKod,CArtikul);
{
 ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);
 Format(ws,CName);
}
  SArtikul:=E^.Dat.Element[l].BazKod;
  Str(l:CMantissa,ss);{l - порядковый номер по списку }

     If NPrint.FullName=0 Then
     Begin
      ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);
      ws1:=GetIdField(FName2,E^.Dat.Element[l].BazKod);
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
	  Begin
	   Writeln(txt,ss+' '+SArtikul+' '+ws);
        ss:='  ';
        SArtikul:='     ';
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
	   Writeln(txt,ss+' '+SArtikul+' '+ws);
        ss:='  ';
        SArtikul:='     ';
        ws:=ws1;
       End;
      End;

 Format(ws,CName);


 DelSpace(E^.Dat.Element[l].Kol);
 RFormat(E^.Dat.Element[l].Kol,CKol);
 DelSpace(E^.Dat.Element[l].Bak_O_Zena);
 RFormat(E^.Dat.Element[l].Bak_O_Zena,CZena);
 DelSpace(E^.Dat.Element[l].Bak_R_Zena);
 RFormat(E^.Dat.Element[l].Bak_R_Zena,CZena);
 DelSpace(E^.Dat.Element[l].New_O_Zena);
 RFormat(E^.Dat.Element[l].New_O_Zena,CZena);
 DelSpace(E^.Dat.Element[l].New_R_Zena);
 RFormat(E^.Dat.Element[l].New_R_Zena,CZena);
ws:=SArtikul+' '+ws+' '+E^.Dat.Element[l].Kol+' '+E^.Dat.Element[l].Bak_O_Zena+' '+
E^.Dat.Element[l].Bak_R_Zena+' '+E^.Dat.Element[l].New_O_Zena+' '+E^.Dat.Element[l].New_R_Zena;
 ws:=ss+' '+Ws;
 MyStr((StrToInt(E^.Dat.Element[l].Kol)*StrToReal(E^.Dat.Element[l].New_R_Zena))-(StrToInt(E^.Dat.Element[l].Kol)*
 StrToReal(E^.Dat.Element[l].Bak_R_Zena)),CIZena,CMantissa,ss1);
 ws:=ws+' '+ss1;
 If Regim Then Writeln(txt,ws);
{ Inc(l);}
 End;
{DelSpace(E^.Dat.Itogo_Bak_R_Zena);
 DelSpace(E^.Dat.Itogo_Bak_O_Zena);
 DelSpace(E^.Dat.Itogo_New_R_Zena);
 DelSpace(E^.Dat.Itogo_New_O_Zena);
 DelSpace(E^.Dat.Delta_RZ);
 DelSpace(E^.Dat.Delta_OZ);}
 If Regim Then
 Begin
 RFormat(E^.Dat.Delta_RZ,CIZena);
 RFormat(E^.Dat.Delta_OZ,CIZena);
 RFormat(E^.Dat.Itogo_Bak_R_Zena,CIZena);
 RFormat(E^.Dat.Itogo_Bak_O_Zena,CIZena);
 RFormat(E^.Dat.Itogo_New_R_Zena,CIZena);
 RFormat(E^.Dat.Itogo_New_O_Zena,CIZena);
 End;

 ItogoRZ:=ItogoRZ+StrToReal(E^.Dat.Delta_RZ);
 ItogoOZ:=ItogoOZ+StrToReal(E^.Dat.Delta_OZ);

 If Regim Then
 Begin
Writeln(Txt,'_____________________________________________________________________________________________');
Writeln(Txt,'                                                          Всего наименований: ',E^.Dat.Amount:CIZena);
{Writeln(Txt,'                                                                Было  по Р/Ц: ',
Recogniz(E^.Dat.Itogo_Bak_R_Zena));
Writeln(Txt,'                                                                Стало по Р/Ц: ',
Recogniz(E^.Dat.Itogo_New_R_Zena));}
Writeln(Txt,'                                                     Всего переоценка по Р/Ц: ',Recogniz(E^.Dat.Delta_RZ));
{Writeln(Txt,'                                                                Было  по О/Ц: ',
Recogniz(E^.Dat.Itogo_Bak_O_Zena));
Writeln(Txt,'                                                                Стало по О/Ц: ',
Recogniz(E^.Dat.Itogo_New_O_Zena));}
Writeln(Txt,'                                                     Всего переоценка по О/Ц: ',Recogniz(E^.Dat.Delta_OZ));
Writeln(Txt,'=============================================================================================');
Writeln(Txt);
  End;{Regim}
   End;{if (E^.Dat.Vid=Vid)Or(Vid=2)}
  End;
If Regim Then
Begin
Writeln(txt,'Всего переоценка за '+Date+' составила: по Р/Ц ',RecognizReal(ItogoRZ,CIZena,CMantissa),' руб.');
Writeln(txt,'                                        по О/Ц ',RecognizReal(ItogoOZ,CIZena,CMantissa),' руб.');
End;
Str(Doc:CLitrMAntissa,ws);
 If Regim Then Writeln(Txt,'              Всего за день документов: ',Ws);
  Dispose(E,Done);
If Regim Then   NoInfo;
  Close(f);
  Close(Txt);
If Regim Then ViewAsText(Path.ToTemp+'pereoz.txt',False);
MyStr(ItogoRZ,CIZena,CMantissa,ss);
Str(Doc:CLitrMantissa,ss1);
ViewAllAktPrz:=ss+' '+ss1;
{ViewAllAktPrz:=RecognizReal(ItogoRZ,CIZena,CMantissa);}
End;


Procedure FormAktFile (E : PPereozenkaType; DAte: TDateString);
Var Txt : Text;
    l:Byte;
    k,c : Word;
    Ws,ws1 : string[150];
    SArtikul,ss,ss1 : TEnjoyStr;
    ShkalaZ:string[150];
Begin
Assign(Txt,Path.ToTemp+'pereozp.txt');
Rewrite(Txt);
Writeln(Txt,'Склад: ',E^.Dat.SkladKod{E^.Dat.Sklad}, '  Оператор:',E^.Dat.Caption+' EYE & 1999');
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Writeln(txt,'Последние изменения:'+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
Writeln(Txt,'                        АКТ ПЕРЕОЦЕНКИ ТОВАРА N ',E^.Dat.Document,' от ',E^.Dat.DAteC+' ('+E^.Dat.TimeC+')');

If E^.Dat.Vid=1 Then
Writeln(Txt,Bold[NPrint.Printer]+'                   Переоценка проведена по документу возврата N '+E^.Dat.DocumentWith+' от '+

E^.Dat.DateWith+NoBold[NPrint.Printer]);

If E^.Dat.Vid=2  Then
Writeln(Txt,Bold[NPrint.Printer]+'                   Переоценка проведена по документу ревизии N '+E^.Dat.DocumentWith+' от '
+E^.Dat.DateWith+NoBold[NPrint.Printer]);


Writeln(txt);
Writeln(Txt,'                     Комиссия в составе:');
Writeln(Txt,'       1._____________________   2._____________________');
Writeln(Txt,'       3._____________________   4._____________________');
Writeln(Txt,'       произвела переоценку товара');
Writeln(Txt,'                                               __ Было__        __ Стало __');
Writeln(Txt,'______________________________________________|_________|______|___________|_________________');
Writeln(Txt,' N  Код  Наименование товара        Колич   О/Цена   Р/Цена   О/Цена   Р/Цена  Переоценка Р/Ц ');
Writeln(Txt,'_____________________________________________________________________________________________');
{                                                12345 12345678 12345678 12345678 12345678 123456789012345}
 l:=1;
{While E^.Dat.Element[l].BazKod[0]<>#0 Do}
 c :=0;
For l:=1 To E^.Dat.Amount Do
 Begin

 ShkalaZ[0]:=#0;
 For k:=1 To {CShkala}2 Do
  Begin
   ShkalaZ:=ShkalaZ+' Ц_'+IntToStr(k,COne)+':';
   MyStr((StrToReal(E^.Dat.Element[l].New_R_Zena)*
   (StrToReal(E^.Dat.Element[l].AutoSkid[k]))),CZena,CMAntissa,ws);
   DelSpace(ws);
   ShkalaZ:=ShkalaZ+ws+' ';
  End;
 Writeln(txt,Italic[Nprint.Printer]+'  '+ShkalaZ+NoItalic[Nprint.Printer]);


 Format(E^.Dat.Element[l].BazKod,CArtikul);
 SArtikul:=E^.Dat.Element[l].BazKod;
 Str(c:CMantissa,ss);{порядковый номер по списку}

{
 If NPrint.FullName=0 Then ws:=GetIdField(FName,E^.Dat.Element[l].BazKod)
 Else ws:=GetIdField(FFname,E^.Dat.Element[l].BazKod);
 }
     If NPrint.FullName=0 Then
     Begin
      ws:=GetIdField(FName,E^.Dat.Element[l].BazKod);
      ws1:=GetIdField(FName2,E^.Dat.Element[l].BazKod);
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
	  Begin
	   Writeln(txt,ss+' '+SArtikul+' '+ws);
        ss:='  ';
        SArtikul:='     ';
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
	   Writeln(txt,ss+' '+SArtikul+' '+ws);
        ss:='  ';
        SArtikul:='     ';
        ws:=ws1;
       End;
      End;



 Format(ws,CName);
 DelSpace(E^.Dat.Element[l].Kol);
{ If StrToInt(E^.Dat.Element[l].Kol) >0 Then}
 Begin
 Inc(c);
 RFormat(E^.Dat.Element[l].Kol,CKol);
 DelSpace(E^.Dat.Element[l].Bak_O_Zena);
 RFormat(E^.Dat.Element[l].Bak_O_Zena,CZena);
 DelSpace(E^.Dat.Element[l].Bak_R_Zena);
 RFormat(E^.Dat.Element[l].Bak_R_Zena,CZena);
 DelSpace(E^.Dat.Element[l].New_O_Zena);
 RFormat(E^.Dat.Element[l].New_O_Zena,CZena);
 DelSpace(E^.Dat.Element[l].New_R_Zena);
 RFormat(E^.Dat.Element[l].New_R_Zena,CZena);
ws:=SArtikul+' '+ws+' '+E^.Dat.Element[l].Kol+' '+E^.Dat.Element[l].Bak_O_Zena+' '+
E^.Dat.Element[l].Bak_R_Zena+' '+E^.Dat.Element[l].New_O_Zena+' '+E^.Dat.Element[l].New_R_Zena;
 Str(c:CMantissa,ss);{порядковый номер по списку}
 ws:=ss+' '+Ws;
 MyStr((StrToInt(E^.Dat.Element[l].Kol)*StrToReal(E^.Dat.Element[l].New_R_Zena))-(StrToInt(E^.Dat.Element[l].Kol)*
 StrToReal(E^.Dat.Element[l].Bak_R_Zena)),CIZena,CMantissa,ss1);
 ws:=ws+' '+ss1;
 Writeln(txt,Pitch[NPrint.Printer]+ws+NoPitch[NPrint.Printer]);
 End;
{ Inc(l);}
 End;
 RFormat(E^.Dat.Delta_RZ,CIZena);
 RFormat(E^.Dat.Delta_OZ,CIZena);
 RFormat(E^.Dat.Itogo_Bak_R_Zena,CIZena);
 RFormat(E^.Dat.Itogo_Bak_O_Zena,CIZena);
 RFormat(E^.Dat.Itogo_New_R_Zena,CIZena);
 RFormat(E^.Dat.Itogo_New_O_Zena,CIZena);
{Writeln(Txt,'_____________________________________________________________________________________________');}
{                                                12345 12345678 12345678 12345678 12345678 123456789012345}
Str(c:CIZena,ss);
Writeln(Txt,'                                                          Всего наименований: ',ss{E^.Dat.Amount:CIZena});
{Writeln(txt,'                                                                Было  по Р/Ц: ',
Recogniz(E^.Dat.Itogo_Bak_R_Zena));
Writeln(Txt,'                                                                Стало по Р/Ц: ',
Recogniz(E^.Dat.Itogo_New_R_Zena));}
Writeln(Txt,'                                                     Всего переоценка по Р/Ц: ',Recogniz(E^.Dat.Delta_RZ));
{Writeln(Txt,'                                                                Было  по О/Ц: ',
Recogniz(E^.Dat.Itogo_Bak_O_Zena));
Writeln(Txt,'                                                                Стало по О/Ц: ',
Recogniz(E^.Dat.Itogo_New_O_Zena));}
Writeln(Txt,'"'+DayString[DayOfWeek(ToDay)]+'" '+FDate+'('+Times+')'+'                              Всего переоценка по О/Ц: ',
Recogniz(E^.Dat.Delta_OZ));
Writeln(Txt,'=============================================================================================');
Writeln(Txt);
Close(Txt);
End;



Procedure PrintAktPrz (As: DocumentEdit);
Var f : PereozenkaFileType;
    E : PPereozenkaType;
    l : Word;
    txt : Text;
    Find : Boolean;
Begin
 AInfo('Ищу документ...');
 Assign(F,Path.ToCorrect+As.D+'.prz');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   MessageBox(#3^M+#3'Не найден файл '+Path.ToCorrect+As.D+'.prz',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt,Path.ToTemp+'pereozp.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   NoInfo;
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'pereozp.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Close(Txt);
 Find :=False;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
   {
   Repeat
   Until Lock(f,FilePos(f)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
   }
   ReadPereozenka(F,E);
   {
   Repeat
    UnLock(f,(FilePos(f)-1)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
   Until DosError=0;
   }
  DelSpace(E^.Dat.Document);
  If  ClearChar(E^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Close(f);
   Dispose(E,Done);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
{  If Status=DocPrint Then Status:=DocNormal;}
   Exit;
 End;
 Close(f);
 FormAktFile(E,As.D);
 NoInfo;

Dispose(E,Done);
{If Status=DocPrint Then Status:=DocNormal;}
Report(Path.ToTemp+'pereozp.txt','',NPrint.CopyPrz,False,False,false);

 If MessageBox(^M+#3'Печатать ценники для переоценки?',Nil,mfwarning+mfOkCancel)=cmOk Then
  Begin
   PrintingZeni(As,0);
  End;


End;



Procedure PrintPrihod(As : DocumentEdit);
Const Space='       ';
Var f : PrihodFileType;
    E : PPrihodType;
    ws,ws1 : string[150];
    SProz,Nalog,Fas,P : String[CPack];
    St : String[CMantissa];
    SArtikul,ss,ss1 : TEnjoyStr;
    r,l  : LongInt;
    k : Byte;
    txt : Text;
    PrintShkala,PrintNumer,Find : Boolean;
    DDD : ArtikulStr;
    ShkalaZ:string[150];
    Barter : ArtikulStr;

Begin
 AInfo('Ищу документ...');
 Assign(F,Path.ToPrihod+As.D+'.prh');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   MessageBox(#3^M+#3'Не найден файл '+Path.ToPrihod+As.D+'.prh',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
  End;
 Assign(Txt,Path.ToTemp+'prihodp.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   NoInfo;
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'prihodp.txt',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
  End;
 Find :=False;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(PrihodType),SizeOf(PrihodType));
     }
     ReadPrihod(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(PrihodType),SizeOf(PrihodType));
     Until (DosError=0);
     }
  DelSpace(E^.Dat.Document);
  If  ClearChar(E^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Dispose(E,Done);
   Close(f);
   Close(txt);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
 End;
 Close(f);
 NoInfo;

 Barter[0]:=#0;
 If E^.Dat.OperatorSelector=2 Then Barter:='-Б';

 Writeln(Txt,Space+'Склад: ',{E^.Dat.Sklad}E^.Dat.SkladKod+
                  '  Оператор: '+E^.Dat.Caption+' EYE & 1999');
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Write(txt,Space+{'Последние изменения:'}+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
If E^.Dat.StatusDoc=0 Then Writeln(Txt,Bold[NPrint.Printer]+Space+'СТАТУС:'+' Документ введен на склад'+NoBold[NPrint.Printer])
Else Writeln(Txt,Bold[NPrint.Printer]+Space+'СТАТУС:'+' Документ подлежит согласованию'+NoBold[NPrint.Printer]);
If E^.Dat.OperatorSelector in [0,2] Then
Writeln(Txt,'                      Н А К Л А Д Н А Я (приход) N '+E^.Dat.Document+Barter+' от '+E^.Dat.DateC+' ('+
E^.Dat.TimeC+')')
Else
Writeln(Txt,'                Н А К Л А Д Н А Я (межскладской приход) N '+E^.Dat.Document+Barter+' от '+E^.Dat.DateC+
' ('+E^.Dat.TimeC+')');
Writeln(Txt,Space+'Поставщик: '+GetMakeField(FClient,E^.Dat.MakeKod,E^.Dat.OperatorSelector)+' '+E^.Dat.MakeKod);
Writeln(Txt,Space+'Получатель: ',GetMakeField(FClient,Rek.Kod,1));
{Writeln(Txt,Space+'____________________________________________________________________________________');}
Writeln(Txt,Space+'----------------------------------------------------------------------------------------');
Writeln(Txt,Space+' N  Код  Наименование товара        Колич. Упаковок Фас   З/Цена   Р/Цена Нацен   НП Отд');
Writeln(Txt,Space+'----------------------------------------------------------------------------------------');
                     {12345 12345678901234567890123456     12345 123456789 12345678 12345678 12345 12345 123
             12345678901234567890123456789012345678901234567890123456789012345678901234567890
}
 l:=1;
{While E^.Dat.PrihodElement[l].BazKod[0]<>#0 Do}

If MessageBox(^M+#3+'Печатать накладную без цен по шкалам?',Nil,mfConfirmation+mfOkCancel)=cmOk Then
 PrintShkala:=FAlse
 Else
 PrintShkala:=True;

For l:=1 To E^.Dat.Amount Do
 Begin

If PrintShkala Then
Begin
If (StrToInt(E^.Dat.PrihodElement[l].Input.Kol)>0) Then
Begin
 ShkalaZ[0]:=#0;
 For r:=1 To 3{CShkala} Do
  Begin
   ShkalaZ:=ShkalaZ+' Ц_'+IntToStr(r,COne)+':';
   MyStr(StrToReal(E^.Dat.PrihodElement[l].Input.R_Zena)*StrToReal(E^.Dat.PrihodElement[l].Input.AutoSkidka[r]),
   CZena,CMAntissa,ws);
   DelSpace(ws);
   ShkalaZ:=ShkalaZ+ws+' ';
  End;
 Writeln(txt,Space+'  '+Italic[NPrint.Printer]+ShkalaZ+NoItalic[NPrint.Printer]);
End;
End;


 Str(l:CMantissa,St);
 PrintNuMer:=True;
 For k:=1 To CDivision Do
 Begin
 DelSpace(E^.Dat.PrihodElement[l].Input.DivisionS[k]);
If (StrToInt(E^.Dat.PrihodElement[l].Input.DivisionS[k])>0) Then
 Begin
 SArtikul:=E^.Dat.PrihodElement[l].BazKod;
 Format(E^.Dat.PrihodElement[l].BazKod,CArtikul);
 {
 If NPrint.FullName=0 Then ws:=GetIdField(FName,E^.Dat.PrihodElement[l].BazKod)
 Else ws:=GetIdField(FFName,E^.Dat.PrihodElement[l].BazKod);
 }
  If NPrint.FullName=0 Then
  Begin
   ws := GetIdField(FName ,E^.Dat.PrihodElement[l].BazKod);
   ws1:= GetIdField(FName2,E^.Dat.PrihodElement[l].BazKod);
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
   ws:=GetIdField(FFName,E^.Dat.PrihodElement[l].BazKod);
   ws1:=GetIdField(FName2,E^.Dat.PrihodElement[l].BazKod);
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
 Str(StrToInt(E^.Dat.PrihodElement[l].Input.DiviSionS[k]):CKol,E^.Dat.PrihodElement[l].Input.DiviSionS[k]);
 DelSpace(E^.Dat.PrihodElement[l].Input.DivisionS[k]);
 RFormat(E^.Dat.PrihodElement[l].Input.DivisionS[k],CKol);

 P:=CalcPack(E^.Dat.PrihodElement[l].BazKod,E^.Dat.PrihodElement[l].Input.DivisionS[k]);
 DelSpace(P);
 RFormat(P,CPack);

 DelSpace(E^.Dat.PrihodElement[l].Input.R_Zena);
 RFormat(E^.Dat.PrihodElement[l].Input.R_Zena,CZena);

 MyStr(StrToReal(E^.Dat.PrihodElement[l].Input.Zakupka)/
 StrToReal(GetIdField(FInPack,E^.Dat.PrihodElement[l].BazKOd)),CZena,CMantissaZ,E^.Dat.PrihodElement[l].Input.Zakupka);
 DelSpace(E^.Dat.PrihodElement[l].Input.Zakupka);
 RFormat(E^.Dat.PrihodElement[l].Input.Zakupka,CZena);

 Nalog:=GetIdField(FNalog,E^.Dat.PrihodElement[l].BazKod);
 MyStr(StrToReal(Nalog),Clitr,CMantissa,NAlog);

 DelSpace(E^.Dat.PrihodElement[l].Input.O_Zena);
 RFormat(E^.Dat.PrihodElement[l].Input.O_Zena,CZena);
 Fas:=GetIdField(FInPack,E^.Dat.PrihodElement[l].BazKod);
 Str(StrToInt(Fas):CInPack,Fas);

 Format(Fas,CInPack);

 SProz:='?????';
 If StrToReal(E^.Dat.PrihodElement[l].Input.Zakupka)>0.009 Then
  Begin
   MyStr((StrToReal(E^.Dat.PrihodElement[l].Input.R_Zena)-
          StrToReal(E^.Dat.PrihodElement[l].Input.Zakupka))/
		StrToReal(E^.Dat.PrihodElement[l].Input.Zakupka)*100,CLitr,CMantissa,SProz);
  End;


 ws:=SArtikul+' '+ws+' '+E^.Dat.PrihodElement[l].Input.DivisionS[k]+
   +' '+P+' '+Fas+' '+E^.Dat.PrihodElement[l].Input.Zakupka+' '+E^.Dat.PrihodElement[l].Input.R_Zena+
   +' '+SProz+' '+Nalog+' ';
(*
 Str((StrToInt(E^.Dat.PrihodElement[l].Input.DiviSion[k])*StrToReal(E^.Dat.PrihodElement[l].Input.R_Zena)):
 CInputIZena:CMantissa,ss);
 ws:=ws+' '+ss+' '{+ss1};
*)
 Str(k:2,P);

 DDD[0]:=#0;

 If Not(GetIdMarket(E^.Dat.PrihodElement[l].BAzKod)=1) Then DDD:=' З';


  If TestLastDiviSion(E^.Dat.PrihodElement[l].Input.DivisionS,K) Then
  Begin
     If PrintNumer Then
      Begin
      Writeln(txt,Space+st+' '+Pitch[NPrint.Printer]+ws+P+NoPitch[NPrint.Printer]+DDD);
      PrintNumer:=False;
      End
     Else
      Writeln(txt,Space+'   '+Pitch[NPrint.Printer]+ws+P+NoPitch[NPrint.Printer]+DDD)
  End
  Else
     Begin
      If PrintNumer Then
      Begin
      Writeln(txt,Space+st+' '+ws+P+DDD);
      PrintNumer:=False;
      End
      Else
      Writeln(txt,Space+'   '+ws+P+DDD)
     End;

(*
 If NPrint.FullSertif=0 Then
 Begin{Если не надо печатать полный сертификат}
  If PrintNumer Then
  Begin
   If TestLastDiviSion(E^.Dat.PrihodElement[l].Input.Division,K) Then
      Writeln(txt,Space+st+' '+Pitch+ws+P+NoItalic)
   Else
      Writeln(txt,Space+st+' '+ws+P);
  End
  Else
    Begin
    If TestLastDiviSion(E^.Dat.PrihodElement[l].Input.Division,K) Then
    Writeln(txt,Space+'   '+Pitch+ws+P+NoItalic)
    Else
    Writeln(txt,Space+'   '+ws+P);
    End;
  PrintNumer:=False;
 End
 Else
  Begin{если надо печатать полный сертификат}
   DelSpaceRight(E^.Dat.PrihodElement[l].Input.Sertifikat);
   If E^.Dat.PrihodElement[l].Input.Sertifikat[0]<>#0 Then
    Begin{если графа сертификата не пустая}
      If PrintNumer Then {если это первое приходное отделение}
        Writeln(txt,Space+st+' '+ws+P)
      Else  Writeln(txt,Space+'   '+ws+P);
      PrintNumer:=False;
    End
    Else
     Begin{если графа сертификата пустая}
       If PrintNumer Then
        Begin
         If TestLastDiviSion(E^.Dat.PrihodElement[l].Input.Division,K) Then
         Writeln(txt,Space+st+' '+Pitch+ws+P+NoItalic)
         Else
         Writeln(txt,Space+st+' '+ws+P);
        End
       Else
        Begin
         If TestLastDiviSion(E^.Dat.PrihodElement[l].Input.Division,K) Then
         Writeln(txt,Space+'   '+Pitch+ws+P+NoItalic)
         Else
         Writeln(txt,Space+'   '+ws+P);

        End;
       PrintNumer:=False;
     End;
  End;*)
 End;
 End;{For}

 If PrintSertifDoc[3]=1 Then
  Begin
   DelSpaceRight(E^.Dat.PrihodElement[l].Input.NSertif);
   If E^.Dat.PrihodElement[l].Input.NSertif[0]<>#0 Then
    Begin
     Format(E^.Dat.PrihodElement[l].Input.NSertif,CNSertif);
     Writeln(txt,Space+'   '+'Сертификат: '+E^.Dat.PrihodElement[l].Input.NSertif);
    End;
  End;

 If PrintAkzisDoc[3]=1 Then
  Begin
   DelSpaceRight(E^.Dat.PrihodElement[l].Input.Akzis1);
   If E^.Dat.PrihodElement[l].Input.Akzis1[0]<>#0 Then
    Begin
     Format(E^.Dat.PrihodElement[l].Input.Akzis1,CAkzis1);
     Writeln(txt,Space+'   '+'Примечание: '+E^.Dat.PrihodElement[l].Input.Akzis1);
    End;
  End;
(* Убраная печать сертификатов и акцизных марок
 DelSpaceRight(E^.Dat.PrihodElement[l].Input.Sertifikat);
 If E^.Dat.PrihodElement[l].Input.Sertifikat[0]<>#0 Then
 Writeln(txt,Space+' Сертификат: ',E^.Dat.PrihodElement[l].Input.Sertifikat);
 DelSpaceRight(E^.Dat.PrihodElement[l].Input.Akzis);
 If E^.Dat.PrihodElement[l].Input.Akzis[0]<>#0 Then
 Writeln(txt,Space+' Примечание: ',E^.Dat.PrihodElement[l].Input.Akzis);
 *)
{ Inc(l);}

 End;
{Writeln(Txt,Space+'____________________________________________________________________________________');}
RFormat(E^.Dat.SummaR,CIZena);
RFormat(E^.Dat.SummaO,CIZena);
RFormat(E^.Dat.SummaL,CIZena);
RFormat(E^.Dat.SummaZakupka,CIZena);

Writeln(Txt,Space+'----------------------------------------------------------------------------------------');
Writeln(Txt,Space+'                                               Всего наименований: ',E^.Dat.Amount:CIZena);
Writeln(Txt,Space+'                                               Всего по З/Ценам  : ',Recogniz(E^.Dat.SummaZakupka));
Writeln(Txt,Space+'    Проверил  __________                       Всего по Р/Ценам  : ',Recogniz(E^.Dat.SummaR));
{Writeln(Txt,Space+'                                                Всего по О/Ценам  : ',Recogniz(E^.Dat.SummaO));}
Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+FDate+'('+Times+')'+
{+'                         Всего литраж      : ',Recogniz(E^.Dat.SummaL));}
 +'                        Всего по О/Ценам  : ',Recogniz(E^.Dat.SummaO));
Writeln(Txt,Space+'========================================================================================');
Writeln(Txt);
Dispose(E,Done);
Close(txt);
{If Status=DocPrint Then Status:=DocNormal;}
Report(Path.ToTemp+'prihodp.txt','',NPrint.CopyPrihod,False,False,false);

       If MessageBox(^M+#3'Печатать ценники для прихода?',Nil,mfwarning+mfOkCancel)=cmOk Then
         Begin
          PrintingZeni(As,1);
         End;

End;


Function NewPrintVozwrat(As : DocumentEdit):Boolean;
Const Space='       ';
Var f : NewVozwratFileType;
    E : PNewVozwratType;
    Adres,ws,ws1 : string[150];
    SArtikul,koefficient,Fas,P : String[CPack];
    St : String[CMantissa];
    ss,ss1 : TEnjoyStr;
    Summa : String[CIZena];
    l  : LongInt;
    k : Byte;
    txt : Text;
    PrintNumer,Find : Boolean;
    PP : PSuperMArketType;
    VVV : DocumentEdit;
    sSumma,sSkidka: String[CIZena];

Begin
 AInfo('Ищу документ...');
 NewPrintVozwrat:=False;
 Assign(F,Path.ToReturn+As.D+'.vzw');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   MessageBox(#3^M+#3'Не найден файл '+Path.ToReturn+As.D+'.vzw',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
  End;
 Assign(Txt,Path.ToTemp+'vozwratp.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   NoInfo;
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'vozwratp.txt',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
  End;
 Find :=False;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     }
     ReadNewVozwrat(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     }
  DelSpace(E^.Dat.Document);
  If  ClearChar(E^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Dispose(E,Done);
   Close(f);
   Close(txt);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
 End;
 Close(f);
 NoInfo;
 NewPrintVozwrat:=True;
 If Not(E^.Dat.Rashod) Then NewPrintVozwrat:=False
 Else
  If Abs(StrToReal(E^.Dat.RashodSumma))<0.009 Then NewPrintVozwrat:=False;

Writeln(Txt,Space+(*'Склад: ',{E^.Dat.Prihod.Sklad}E^.Dat.SkladKod+*)
'Оператор: '+E^.Dat.Caption+' EYE & 1997-00');
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Write(txt,Space+{'Последние изменения:'}+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
If E^.Dat.StatusDoc=0 Then Writeln(Txt,Bold[NPrint.Printer]+Space+'СТАТУС:'+' Документ введен на склад'+NoBold[NPrint.Printer])
Else Writeln(Txt,Bold[NPrint.Printer]+Space+'СТАТУС:'+' Документ подлежит согласованию'+NoBold[NPrint.Printer]);

WriteLn(Txt,Space+'ВИД ВОЗВРАТА: ('+IntTostr(E^.Dat.VidDocument,CMantissa)+')');


If E^.Dat.OperatorSelector=0 Then
Begin
If E^.Dat.Opt Then
Writeln(Txt,'                Н А К Л А Д Н А Я   В О З В Р А Т А  N '+E^.Dat.Document+
   '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)
+' от '+E^.Dat.DateC+' ('+
E^.Dat.TimeC+')')
Else
Writeln(Txt,'                 Д О К У М Е Н Т   В О З В Р А Т А  N '+E^.Dat.Document+
   '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)
+' от '+E^.Dat.DateC+' ('+
E^.Dat.TimeC+')');
End
Else
Writeln(Txt,'         Д О К У М Е Н Т  межскладского  В О З В Р А Т А  N '+E^.Dat.Document+
   '/'+IntToStr(StrToInt(E^.Dat.SkladKod),CMantissa)
+' от '+E^.Dat.DateC+
' ('+E^.Dat.TimeC+')');

  Adres[0]:=#0;




Writeln(Txt,Space+Bold[NPrint.Printer]+'Основание: по документу N '+E^.Dat.BasisDoc+' от '+E^.Dat.BasisDate+' '+Adres+
NoBold[NPrint.Printer]);
Writeln(Txt,Space+'Поставщик: '+GetClientField(FClient,E^.Dat.MakeKod,E^.Dat.OperatorSelector)+' '+E^.Dat.MakeKod);
Writeln(Txt,Space+'Получатель: ',GetMakeField(FClient,Rek.Kod,1));
Writeln(Txt,Space+'----------------------------------------------------------------------------------');
Writeln(Txt,Space+' N  Код  Наименование товара        Фас Колич.  Упаковок    Цена Итого со скид Отд');
Writeln(Txt,Space+'----------------------------------------------------------------------------------');
{12345 12345678901234567890123456     12345 123456789             12345678 12345678 1234567890123 1234567890123
                   12345678901234567890123456789012345678901234567890123456789012345678901234567890
}
 l:=1;
{While E^.Dat.PrihodElement[l].BazKod[0]<>#0 Do}
sSumma:='0.00';
For l:=1 To E^.Dat.Amount Do
 Begin
 Str(l:CMantissa,St);
 PrintNuMer:=True;
 Format(E^.Dat.VozwratElement[l].BazKod,CArtikul);
 SArtikul:=E^.Dat.VozwratElement[l].BazKod;
{
 If NPrint.FullName=0 Then
 Begin
  ws:=GetIdField(FName,E^.Dat.VozwratElement[l].BazKod);
 End
 Else
  Begin
   ws:=GetIdField(FFName,E^.Dat.VozwratElement[l].BazKod);
  End;
}
 If NPrint.FullName=0 Then
 Begin
  ws:=GetIdField(FName,E^.Dat.VozwratElement[l].BazKod);
  ws1:=GetIdField(FName2,E^.Dat.VozwratElement[l].BazKod);
  DelSpaceRight(ws1);
   If ws1[0]<>#0 Then
    Begin
     Writeln(txt,Space+st+' '+SArtikul+' '+ws);
     st:='  ';
     SArtikul:='     ';
     ws:=ws1;
    End;
 End
 Else
  Begin
   ws:=GetIdField(FFName,E^.Dat.VozwratElement[l].BazKod);
   ws1:=GetIdField(FFName2,E^.Dat.VozwratElement[l].BazKod);
   DelSpaceRight(ws1);
   If ws1[0]<>#0 Then
    Begin
     Writeln(txt,Space+st+' '+SArtikul+' '+ws);
     st:='  ';
     SArtikul:='     ';
     ws:=ws1;
    End;
  End;

 Format(ws,CName);

 DelSpace(E^.Dat.VozwratElement[l].Input.Kol);
 RFormat(E^.Dat.VozwratElement[l].Input.Kol,CKol);

 P:=CalcPack(E^.Dat.VozwratElement[l].BazKod,E^.Dat.VozwratElement[l].Input.Kol);
 DelSpace(P);
 RFormat(P,CPack);

    MyStr((1+StrToReal(E^.Dat.VozwratElement[l].Input.SpecNalog)/100),CLitr,CMantissa,
    Koefficient);
    DelSpace(Koefficient);


If E^.Dat.DocSelector in [1,2,3,5,6] Then
   Begin

Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)*
           (StrToReal(E^.Dat.VozwratElement[l].Input.LocalProz)),CZena,CMantissa,
           E^.Dat.VozwratElement[l].Input.Zena);
        MyStr(StrToREal(E^.Dat.VozwratElement[l].Input.Zena){/*StrToReal(Koefficient)},CZena,CMantissa,
                         E^.Dat.VozwratElement[l].Input.Zena);
       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)-
                    StrToReal(E^.Dat.VozwratElement[l].Input.LocalSkidka),CZena,CMantissa,
                    E^.Dat.VozwratElement[l].Input.Zena);
          MyStr(StrToREal(E^.Dat.VozwratElement[l].Input.Zena){/*StrToReal(Koefficient)},CZena,CMantissa,
                        E^.Dat.VozwratElement[l].Input.Zena);
        End;
Else;
End;{Case}
End{If VidDocSelector}
Else

 Begin
Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        MyStr(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)*
           (StrToReal(E^.Dat.VozwratElement[l].Input.LocalProz)),CZena,CMantissa,E^.Dat.VozwratElement[l].Input.Zena);
       End;

1,3,5:{Ручная}
        Begin
          MyStr(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)-
                    StrToReal(E^.Dat.VozwratElement[l].Input.LocalSkidka),CZena,CMantissa,
                    E^.Dat.VozwratElement[l].Input.Zena);
        End;
Else;
End;{Case}
 End;

 MyStr(StrToReal(sSumma)+StrToReal(E^.Dat.VozwratElement[l].Input.Zena)*
    StrToReal(E^.Dat.VozwratElement[l].Input.Kol),CZena,CMantissa,sSumma);
 DelSpace(E^.Dat.VozwratElement[l].Input.Zena);
 RFormat(E^.Dat.VozwratElement[l].Input.Zena,CZena);
 Fas:=GetIdField(FInPack,E^.Dat.VozwratElement[l].BazKod);
 DelSpace(Fas);
 Format(Fas,CInPack);

 ws:=SArtikul+' '+ws+' '+Fas+' '+E^.Dat.VozwratElement[l].Input.Kol+
   +' '+P+' '+E^.Dat.VozwratElement[l].Input.Zena;

 MyStr((StrToInt(E^.Dat.VozwratElement[l].Input.Kol)*StrToReal(E^.Dat.VozwratElement[l].Input.Zena)),
 CInputIZena,CMantissa,ss);
 ws:=ws+' '+ss+' '{+ss1};
 Str(StrToInt(E^.Dat.VozwratElement[l].Input.DivisionS):2,P);
 Writeln(txt,Space+st+' '+Pitch[NPrint.Printer]+ws+P+NoPitch[NPrint.Printer]);

(*   If PrintSertifDoc[3]=1 Then
      Begin
       ws:=BakGetField(FSertif,E^.Dat.VozwratElement[l].BazKod,0);
       DelSpaceRight(ws);
       If not(ws[0]=#0) Then
        Begin
         Format(ws,CNSertif);
         ws:=Space+'   '+'    Сертификат: '+ws;
         Writeln(txt,ws);
        End;
      End;

     If PrintAkzisDoc[3]=1 Then
     Begin
       ws:=BakGetField(FAkzis,E^.Dat.VozwratElement[l].BazKod,0);
       DelSpaceRight(ws);
       If not(ws[0]=#0) Then
        Begin
         Format(ws,CAkzis1);
         ws:=Space+'   '+'    Примечание: '+ws;
         Writeln(txt,ws);
        End;
      End;

     If PrintGTD[3]=1 Then
     Begin
       ws:=BakGetField(FNGTD,E^.Dat.VozwratElement[l].BazKod,0);
       DelSpaceRight(ws);
       If not(ws[0]=#0) Then
        Begin
         Format(ws,CNSertif);
         ws:=Space+'   '+'         N ГТД: '+ws;
         Writeln(txt,ws);
        End;

       ws:=BakGetField(FPost,E^.Dat.VozwratElement[l].BazKod,0);
       DelSpaceRight(ws);
       If not(ws[0]=#0) Then
        Begin
         Format(ws,CPost);
         ws:=Space+'   '+'  Производство: '+ws;
         Writeln(txt,ws);
        End;
      End;

    If PrintAkzisDate[3]=1 Then
    Begin
       ws:=BakGetField(FMarka,E^.Dat.VozwratElement[l].BazKod,0);
       DelSpaceRight(ws);
       If Not(ws[0]=#0) Then
        Begin
         ws:=Space+'   '+'Акцизная марка: '+ws;
         Writeln(txt,ws);
        End;

       ws:=BakGetField(FVirabotano,E^.Dat.VozwratElement[l].BazKod,0);
       DelSpaceRight(ws);
       ws1:=BakGetField(FGodnost,E^.Dat.VozwratElement[l].BazKod,0);
       DelSpaceRight(ws1);

       If ws[0]<>#0 Then
        Begin
         ws:=Space+'   '+'Дата выработки: '+Bold[NPrint.Printer]+ws+NoBold[NPrint.Printer]+' ';
         Write(txt,ws);
        End;

      If ws1[0]<>#0 Then
       Begin
        if ws[0]=#0 Then ws1:=Space+'   '+'Реализовать до: '+Bold[NPrint.Printer]+ws1+NoBold[NPrint.Printer]
        Else ws1:= 'Реализовать до: '+Bold[NPrint.Printer]+ws1+NoBold[NPrint.Printer];
        WriteLn(txt,ws);
       End
      Else If ws[0]<>#0 Then Writeln(txt);
    End;
*)

 End;
{Writeln(Txt,Space+'____________________________________________________________________________________');}
RFormat(E^.Dat.SummaR,CIZena);
RFormat(E^.Dat.SummaO,CIZena);
RFormat(E^.Dat.Skidka,CIZena);
RFormat(E^.Dat.ENalog,CIZena);

Writeln(Txt,Space+'----------------------------------------------------------------------------------');
Writeln(Txt,Space+'                                           Всего наименований: ',E^.Dat.Amount:CIZena);
If E^.Dat.Opt Then
Begin
Writeln(Txt,Space+'    Проверил  __________               Всего возврат на склад: ',Recogniz(E^.Dat.SummaO));
Summa:=E^.Dat.SummaO;
End
Else
Begin
Writeln(Txt,Space+'    Проверил  __________               Всего возврат на склад: ',Recogniz(E^.Dat.SummaR));
Summa:=E^.Dat.SummaR;
End;
MyStr(StrToReal(E^.Dat.SummaO)-StrToReal(sSumma),CIZena,CMantissa,Summa);

(*Writeln(Txt,Space+'                                                              {',Recogniz(E^.Dat.Skidka)+'}');*)
Writeln(Txt,Space+'                                                              {',Recogniz(Summa)+'}');
Writeln(Txt,Space+'                                              НП по возврату : ',Recogniz(E^.Dat.ENalog));

Summa:=sSumma;
RFormat(sSumma,CIZEna);
(*MyStr(StrToReal(Summa)-StrToReal(E^.Dat.Skidka){+StrToReal(E^.Dat.ENalog)},CIZena,CMantissa,Summa);*)
Writeln(Txt,Space+'                                                               ',Recogniz(Summa));

MyStr(StrToReal(E^.Dat.RashodSumma),CIZena,CMantissa,Summa);
Writeln(Txt,Space+'                                       Всего к выдаче клиенту: ',Recogniz(Summa));

Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+FDate+'('+Times+')'+
+Bold[NPrint.Printer]+'           Причина возврата ______________________________'+NoBold[NPrint.Printer]);

Writeln(Txt,Space+'==================================================================================');
Writeln(Txt);
Close(txt);
{If Status=DocPrint Then Status:=DocNormal;}
Dispose(E,Done);
Report(Path.ToTemp+'vozwratp.txt','',NPrint.CopyReturn,False,False,false);
End;


(*
Function NewPrintVozwrat(As : DocumentEdit):Boolean;

Const Space='       ';
Var f : NewVozwratFileType;
    E : PNewVozwratType;
    ws : string[150];
    koefficient,Fas,P : String[CPack];
    St : String[CMantissa];
    ss,ss1 : TEnjoyStr;
    Summa : String[CIZena];
    l  : LongInt;
    k : Byte;
    txt : Text;
    PrintNumer,Find : Boolean;
Begin
 AInfo('Ищу документ...');
 NewPrintVozwrat:=False;
 Assign(F,Path.ToReturn+As.D+'.vzw');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   MessageBox(#3^M+#3'Не найден файл '+Path.ToReturn+As.D+'.vzw',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
  End;
 Assign(Txt,Path.ToTemp+'vozwratp.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   NoInfo;
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'vozwratp.txt',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
  End;
 Find :=False;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
     {
     Repeat
     Until Lock(f,FilePos(f)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     }
     ReadNewVozwrat(f,E);
     {
     Repeat
      UnLock(f,(FilePos(f)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     }
  DelSpace(E^.Dat.Document);
  If  ClearChar(E^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Dispose(E,Done);
   Close(f);
   Close(txt);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
 End;
 Close(f);
 NoInfo;
 NewPrintVozwrat:=True;
 If Not(E^.Dat.Rashod) Then NewPrintVozwrat:=False;

Writeln(Txt,Space+'Склад: ',{E^.Dat.Prihod.Sklad}E^.Dat.SkladKod+
'  Оператор: '+E^.Dat.Caption+' EYE & 1999');
If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
Write(txt,Space+{'Последние изменения:'}+' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
If E^.Dat.StatusDoc=0 Then Writeln(Txt,Bold[NPrint.Printer]+Space+'СТАТУС:'+' Документ введен на склад'+NoBold[NPrint.Printer])
Else Writeln(Txt,Bold[NPrint.Printer]+Space+'СТАТУС:'+' Документ подлежит согласованию'+NoBold[NPrint.Printer]);

WriteLn(Txt,Space+'ВИД ВОЗВРАТА: ('+IntTostr(E^.Dat.VidDocument,CMantissa)+')');


If E^.Dat.OperatorSelector=0 Then
Begin
If E^.Dat.Opt Then
Writeln(Txt,'                Н А К Л А Д Н А Я   В О З В Р А Т А  N '+E^.Dat.Document+' от '+E^.Dat.DateC+' ('+
E^.Dat.TimeC+')')
Else
Writeln(Txt,'                 Д О К У М Е Н Т   В О З В Р А Т А  N '+E^.Dat.Document+' от '+E^.Dat.DateC+' ('+
E^.Dat.TimeC+')');
End
Else
Writeln(Txt,'         Д О К У М Е Н Т  межскладского  В О З В Р А Т А  N '+E^.Dat.Document+' от '+E^.Dat.DateC+
' ('+E^.Dat.TimeC+')');
Writeln(Txt,Space+Bold[NPrint.Printer]+'Основание: по документу N '+E^.Dat.BasisDoc+' от '+E^.Dat.BasisDate+
NoBold[NPrint.Printer]);
Writeln(Txt,Space+'Поставщик: '+GetClientField(FClient,E^.Dat.MakeKod,E^.Dat.OperatorSelector)+' '+
E^.Dat.MakeKod);
Writeln(Txt,Space+'Получатель: ',GetMakeField(FClient,Rek.Kod,1));
Writeln(Txt,Space+'----------------------------------------------------------------------------------');
Writeln(Txt,Space+' N  Код  Наименование товара        Фас Колич.  Упаковок    Цена Итого со скид Отд');
Writeln(Txt,Space+'----------------------------------------------------------------------------------');
{12345 12345678901234567890123456     12345 123456789             12345678 12345678 1234567890123 1234567890123
                   12345678901234567890123456789012345678901234567890123456789012345678901234567890
}
 l:=1;
{While E^.Dat.PrihodElement[l].BazKod[0]<>#0 Do}
For l:=1 To E^.Dat.Amount Do
 Begin
 Str(l:CMantissa,St);
 PrintNuMer:=True;
 Format(E^.Dat.VozwratElement[l].BazKod,CArtikul);
 If NPrint.FullName=0 Then ws:=GetIdField(FName,E^.Dat.VozwratElement[l].BazKod)
 Else ws:=GetIdField(FName,E^.Dat.VozwratElement[l].BazKod);
 Format(ws,CName);
 DelSpace(E^.Dat.VozwratElement[l].Input.Kol);
 RFormat(E^.Dat.VozwratElement[l].Input.Kol,CKol);

 P:=CalcPack(E^.Dat.VozwratElement[l].BazKod,E^.Dat.VozwratElement[l].Input.Kol);
 DelSpace(P);
 RFormat(P,CPack);
    Str((1+StrToReal(E^.Dat.VozwratElement[l].Input.SpecNalog)/100):CLitr:CMantissa,
    Koefficient);
    DelSpace(Koefficient);


If E^.Dat.DocSelector in [{1,}2,3,5,6] Then
   Begin

Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        Str(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)/
           (1+StrToReal(E^.Dat.VozwratElement[l].Input.LocalProz)/100):CZena:CMantissa,
		 E^.Dat.VozwratElement[l].Input.Zena);
        Str(StrToREal(E^.Dat.VozwratElement[l].Input.Zena)*StrToReal(Koefficient):CZena:CMantissa,
                         E^.Dat.VozwratElement[l].Input.Zena);

       End;

1,3,5:{Ручная}
        Begin
          Str(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)-
              StrToReal(E^.Dat.VozwratElement[l].Input.LocalSkidka):CZena:CMantissa,
                    E^.Dat.VozwratElement[l].Input.Zena);
          Str(StrToREal(E^.Dat.VozwratElement[l].Input.Zena)*StrToReal(Koefficient):CZena:CMantissa,
                        E^.Dat.VozwratElement[l].Input.Zena);
        End;
Else;
End;{Case}
End{If VidDocSelector}
Else

 Begin
Case E^.Dat.VidDocument Of
0,2,4:{Авто}
       Begin
        {получили новую цену с учетом скидки}
        Str(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)/
	   (1+StrToReal(E^.Dat.VozwratElement[l].Input.LocalProz)/100):CZena:CMantissa,E^.Dat.VozwratElement[l].Input.Zena);
       End;

1,3,5:{Ручная}
        Begin
          Str(StrToReal(E^.Dat.VozwratElement[l].Input.Zena)-
		    StrToReal(E^.Dat.VozwratElement[l].Input.LocalSkidka):CZena:CMantissa,
		    E^.Dat.VozwratElement[l].Input.Zena);
        End;
Else;
End;{Case}
 End;



 DelSpace(E^.Dat.VozwratElement[l].Input.Zena);
 RFormat(E^.Dat.VozwratElement[l].Input.Zena,CZena);
 Fas:=GetIdField(FInPack,E^.Dat.VozwratElement[l].BazKod);
 DelSpace(Fas);
 Format(Fas,CInPack);

 ws:=E^.Dat.VozwratElement[l].BazKod+' '+ws+' '+Fas+' '+E^.Dat.VozwratElement[l].Input.Kol+
   +' '+P+' '+E^.Dat.VozwratElement[l].Input.Zena;

 Str((StrToInt(E^.Dat.VozwratElement[l].Input.Kol)*StrToReal(E^.Dat.VozwratElement[l].Input.Zena)):
 CInputIZena:CMantissa,ss);
 ws:=ws+' '+ss+' '{+ss1};
 Str(StrToInt(E^.Dat.VozwratElement[l].Input.Division):2,P);
 Writeln(txt,Space+st+' '+Pitch[NPrint.Printer]+ws+P+NoPitch[NPrint.Printer]);

      If PrintSertifDoc[3]=1 Then
      Begin
       ws:=BakGetField(FSertif,E^.Dat.VozwratElement[l].BazKod,0);
       DelSpaceRight(ws);
       If not(ws[0]=#0) Then
        Begin
         Format(ws,CNSertif);
            ws:=Space+'   '+'Сертификат: '+ws;
         Writeln(txt,ws);
        End;
      End;

     If PrintAkzisDoc[3]=1 Then
     Begin
       ws:=BakGetField(FAkzis,E^.Dat.VozwratElement[l].BazKod,0);
       DelSpaceRight(ws);
       If not(ws[0]=#0) Then
        Begin
         Format(ws,CAkzis1);
         ws:=Space+'   '+'Примечание: '+ws;
         Writeln(txt,ws);
        End;
      End;


 End;
{Writeln(Txt,Space+'____________________________________________________________________________________');}
RFormat(E^.Dat.SummaR,CIZena);
RFormat(E^.Dat.SummaO,CIZena);
RFormat(E^.Dat.Skidka,CIZena);
RFormat(E^.Dat.ENalog,CIZena);

Writeln(Txt,Space+'----------------------------------------------------------------------------------');
Writeln(Txt,Space+'                                           Всего наименований: ',E^.Dat.Amount:CIZena);
If E^.Dat.Opt Then
Begin
Writeln(Txt,Space+'    Проверил  __________               Всего возврат на склад: ',Recogniz(E^.Dat.SummaO));
Summa:=E^.Dat.SummaO;
End
Else
Begin
Writeln(Txt,Space+'    Проверил  __________               Всего возврат на склад: ',Recogniz(E^.Dat.SummaR));
Summa:=E^.Dat.SummaR;
End;
Writeln(Txt,Space+'                                                              {',Recogniz(E^.Dat.Skidka)+'}');
Writeln(Txt,Space+'                                              НП по возврату : ',Recogniz(E^.Dat.ENalog));

Str(StrToReal(Summa)-StrToReal(E^.Dat.Skidka)+StrToReal(E^.Dat.ENalog):CIZena:CMantissa,Summa);
Writeln(Txt,Space+'                                                               ',Recogniz(Summa));

Str(StrToReal(E^.Dat.RashodSumma):CIZena:CMantissa,Summa);
Writeln(Txt,Space+'                                       Всего к выдаче клиенту: ',Recogniz(Summa));

Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+FDate+'('+Times+')'+
+Bold[NPrint.Printer]+'           Причина возврата ______________________________'+NoBold[NPrint.Printer]);

Writeln(Txt,Space+'==================================================================================');

Writeln(Txt);
Close(txt);
{If Status=DocPrint Then Status:=DocNormal;}
Dispose(E,Done);
Report(Path.ToTemp+'vozwratp.txt','',NPrint.CopyReturn,False,False);
End;

*)

Function ViewOplReal(Dates:TDateString;Regim : Boolean):AllStr;
Const Space ='    ';
Var     f : OplataRealizasiaFileType;
      Opl : OplataRealizasiaType;
  ItogoOZ ,ItogoSf,ItogoRet: Real;
      Txt : Text;
      l   : Byte;
      S   : string[150];
      st  : AllStr;
      Vid : Word;

Begin
 ViewOplReal:='           0.00            0.00';
{              123456789012345 123456789012345}

 If Regim Then
 Begin
 Dates:=FDate;
 If Not(DateDialog(Dates)) Then Exit;
 End
 Else  Dates:=FDate;

 Assign(F,Path.ToOplata+Dates+'.opl');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
  If Regim Then
   MessageBox(#3^M+#3'Не найден файл '+Path.ToOplata+Dates+'.opl',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt,Path.ToTemp+'oplata.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'oplata.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

  Vid:=0;
  If Regim Then
  Begin
  Vid:=SelectSpecify(False,2);
  If Vid=3 Then
   Begin
    CLose(f);
    Close(txt);
    Exit;
   End;
  End
  Else
   Vid:=0;

ItogoOZ:=0;
ItogoSf:=0;
ItogoRet:=0;

If Regim Then   DInfo('Минуточку...');
  Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1));
  Case Vid Of
  0:Writeln(Txt,Space+'Отбор: Оплаты в кассу');
  1:Writeln(Txt,Space+'Отбор: Оплаты возвратом');
  2:Writeln(Txt,Space+'Отбор: Все оплаты');
  Else;
  End;

  Writeln(Txt,Space+'       С П Р А В К А   П О   О П Л А Т Е    К О Н С И Г Н А Ц И И  за '+Dates);
  Writeln(Txt,Space+'-----------------------------------------------------------------------------------------');
  Writeln(Txt,Space+'Клиент               Код  Док  Дата Док     Сумма оплаты  Дата опл Время опл     Оператор');
  Writeln(Txt,Space+'-----------------------------------------------------------------------------------------');
                    {12345678901234567890 1234 1234 12345678  123456789012345  12345678 12345678 123456789012}
  While Not Eof(f) Do
  Begin
   {
   Repeat
   Until (Lock(f,FilePos(f)*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)));
   }
   ReadOplata(F,Opl);
   {
   Repeat
    UnLock(f,(FilePos(f)-1)*SizeOf(OplataRealizasiaType),SizeOf(OplataRealizasiaType)*5);
   Until (DosError=0);
   }
   If ((Opl.Vozwrat)and(Vid=1)) Or (Vid=2) Or (Not(Opl.Vozwrat)and(Vid=0))Then
   Begin
   {подсчитываем оплату по С/Ф}

   If TestSf(Opl.ClientKod,Opl.Document,Opl.DateDoc) Then
       ItogoSF:=ItogoSF+StrToReal(Opl.SummaZ);


   s:=GetClientField(FClient,Opl.ClientKod,0);
   Format(s,CClient);
   s:=s+' '+Opl.CLientKod;
   DelSpace(Opl.Document);
   Format(Opl.Document,CDocNumer);
   DelSpace(Opl.SummaZ);

   ItogoOZ:=ItogoOZ+StrToReal(Opl.SummaZ);


   RFormat(Opl.SummaZ,CIZena);
   st:=GetOperatorName(Opl.Caption);
   Format(St,CKto);
   s:=s+' '+Opl.Document+' '+Opl.DateDoc+'  ';
{   +Opl.SummaZ+'  '+Opl.DateC+' '+Opl.TimeC+'  '+St;}

   If (Opl.Vozwrat) Then
   Begin
    MyStr(StrToReal(Opl.SummaZ)-StrToReal(Opl.Skidka),CIZena,CMantissa,Opl.SummaZ);
   End;
   s:=s+Opl.SummaZ+'  '+Opl.DateC+' '+Opl.TimeC+'  '+St;


   If (Opl.Vozwrat) Then
   Begin
    Format(Opl.DocNumerReturn,CDocNumer);
    Format(Opl.DocDAteReturn,CDate);
    ItogoRet:=ItogoRet+StrToReal(Opl.SummaZ);
    MyStr(StrToReal(Opl.Skidka),CIZena,CMantissa,Opl.Skidka);
    s:=s+^M+Space+'Возврат товара по накладной возврата: '+Opl.DocNumerReturn+' от '+Opl.DocDAteReturn+'  Скидка возврата: '+
    Opl.Skidka;
   End;


   Writeln(txt,Space+s);
   If Opl.Rashet Then
    Begin
     Writeln(txt,Space+'П/П:'+Opl.Bn.NPlat+' от '+Opl.Bn.Date+' Банк:'+Opl.Bn.Bank+' Сумма:'+Opl.Bn.Summa);
    End
    Else
    Begin
     if pos('РКО',Opl.Bn.Bank)>0 then
     Writeln(txt,Space+'РКО:'+Opl.Bn.NPlat+' от '+Opl.Bn.Date+' Сумма:'+Opl.Bn.Summa);
    End;
   End;
  End;

  Writeln(Txt,Space+'-----------------------------------------------------------------------------------------');
  Writeln(txt,Space+'     Всего оплата консигнации за '+Dates+' составила: ',RecognizReal(ItogoOZ,CIZena,CMantissa),' руб.');

  If (Vid=1) Or (Vid=2) Then
  Writeln(txt,Space+'В том числе оплата возвратом  за '+Dates+' составила: ',RecognizReal(ItogoRet,CIZena,CMantissa),' руб.');

{  Writeln(txt,Space+' Всего оплата консигнации со С/Ф '+Dates+' составила: ',RecognizReal(ItogoSF,CIZena,CMantissa),' руб.');}

  Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  Writeln(Txt,Space+'=========================================================================================');
Close(f);
Close(Txt);
If Regim Then NoInfo;

If Regim Then ViewAsText(Path.ToTemp+'oplata.txt',True);
If Regim Then
 Report(Path.ToTemp+'oplata.txt','',1,False,False,false);
 MyStr(ItogoOZ,CIZena,CMantissa,st);
 MyStr(ItogoSF,CIZena,CMantissa,s);
ViewOplReal:=st+' '+s
{RecognizReal(ItogoOZ,CIZena,CMantissa)};
End;

Function CalcDolgDebit(Default:Byte;Regim:Boolean):TMyString;
Var R : TRect;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    RealFile : File Of RealizasiaType;
    ClientList :PBox;
    SortList: PBox;
    E  : PRealizasiaType;
    s,w,w1,st : AllStr;
    ws : TMyString;
    ii,c,t1,t2 : LongInt;
    r1,r2,r3 , Rsf,RsfSkid,RsfStraf :Real;
    f : Text;
    {DateMask : TDateString;}
    As: DocumentEdit;
    Space : AllStr;
    M: PSupermarketType;
    Tip,Vid,Realno : Word;
    Criminal : Boolean;
    CriminalSumma : Real;
    sDate: string[CDate];
    bSpec: boolean;
    sStraf: string[CIZena];
begin
 CalcDolgDebit:='           0.00            0.00            0.00            0.00';
                {123456789012345 123456789012345 123456789012345 123456789012345}
 If Regim=True Then
 Begin
 Vid:=SelectSpecify(True,1);
 If Vid=3 Then Exit;
 Tip:=SelectSpecify(True,4);
 If Tip=3 Then Exit;
 Realno:=SelectImport(5);
 If Realno=2 Then Exit;
 End
 Else Begin
       Vid:=Default;
       Tip:=2;
       Realno:=1;
      End;

If Regim Then
Assign(f,Path.ToTemp+'dolg.txt')
Else
Assign(f,Path.ToTemp+'dolgi.txt');

c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0) And (Regim) Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path.ToTemp+'dolg.txt!!',Nil,mfError+mfCancelButton);
  Exit;
 End;
R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));

R.Assign(0, 0, 0, 0);
SortList := New(PBox, Init(R, 1, Nil));
SortList^.NewList(New(PTextCollection, Init(0,1)));


Assign (ClientFile,Path.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c=0 Then
Begin
If Regim Then AInfo('Рассчитываю долги клиентов...');
While Not(Eof(ClientFile)) Do
 Begin
   {
     Repeat
     Until NetCall.Lock(ClientFile,FilePos(ClientFile)*SizeOf(ClientType),SizeOf(ClientType));
   }
     ReadClient(ClientFile,ClientElement);
   {
     Repeat
      NetCall.UnLock(ClientFile,(FilePos(ClientFile)-1)*SizeOf(ClientType),SizeOf(ClientType));
     Until (DosError=0);
   }

  If ClientElement.Employ Then
   Begin
    Format (ClientElement.Name,CClient);
    ClientList^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
    ClientList^.SetRange(ClientList^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  Close(f);
  Dispose(ClientList,Done);
  MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов',Nil,mfError+mfCancelButton);
  Exit;
 End;
Space:='';
r1:=0;r2:=0;r3:=0;
rsf:=0;
rsfSkid:=0;
RsfStraf:=0;
Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword);
Case Vid Of
2:
Writeln(f,Space+'                 СПРАВКА ПО ДОЛГАМ КОНСИГНАТОРОВ'+'  '+FDate+' ('+Times+')');
1:
Writeln(f,Space+'             СПРАВКА ПО ПРОСРОЧЕННЫМ ДОЛГАМ КОНСИГНАТОРОВ'+'  '+FDate+' ('+Times+')');
0:
Writeln(f,Space+'            СПРАВКА ПО НЕ ПРОСРОЧЕННЫМ ДОЛГАМ КОНСИГНАТОРОВ'+'  '+FDate+' ('+Times+')');
Else;
End;
Write(f,Space+'Вид отбора: ');
Case Tip Of
0:Writeln(f,'"Только с приходниками"');
1:Writeln(f,'"Только без приходников"');
2:Writeln(f,'"Все"');
Else Writeln(f);
End;

Write(f,Space+'Вид долгов: ');
Case Realno Of
1:Writeln(f,'"Теоретичекие"');
0:Writeln(f,'"Реальные по оплате"');
Else Writeln(f);
End;


Writeln(f,Space+'----------------------------------------------------------------------------------------------');
(*If Realno=1 Then
Writeln(f,Space+'       Клиент        Код  Дата Пок  Дата Взв  Delta  N док    Сумма скидки   Сумма долга Т Вид')
Else
Writeln(f,Space+'       Клиент        Код  Дата Пок  Дата Взв  Delta  N док    Сумма скидки  Р долг по опл. Вид');*)
If Realno=1 Then
Writeln(f,Space+'Дата Пок        Клиент        Код   Дата Взв  Delta  N док    Сумма штрафа   Сумма долга Т Вид')
Else
Writeln(f,Space+'Дата Пок        Клиент        Код   Дата Взв  Delta  N док    Сумма штрафа  Р долг по опл. Вид');

{                 12345678901234567890|1234|12345678| 12345678|       |12345|123456789012345│123456789012345}
Writeln(f,Space+'----------------------------------------------------------------------------------------------');
CriminalSumma:=0;
If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    Criminal:=False;
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
    s:=GetClientField(FNDogovor,st,0);
    If s[0]=#0 Then
     Criminal:=True;

    Assign(RealFile,Path.ToDolg+st+'.dlg');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    If ii=0 Then
     Begin
      New(E,Init);
      While Not(Eof(RealFile)) Do
       Begin
        Read(RealFile,E^.Dat);
        If (E^.Dat.Market.Active) Then
Begin
        bSpec:=false;
        As.D:=E^.Dat.MArket.DateC;
        As.EditPosition:=E^.Dat.MArket.Document;
        New(M,Init);
        GetMarket1(As,M);
        if M^.Dat.Amount>0 then
         if StrToReal(GetRazdelSFProc(copy(M^.Dat.MarketElement[1].BazKod,1,2)))>0.01 then
         bSpec:=true;
        Dispose(M,Done);
        t2:=DateStringToDate(DAteMask,FDate);
        t1:=E^.Dat.MArket.Srok;
        If ((((E^.Dat.Dolg<>0)And((t2-t1)>=0))And(Vid=1))Or
           (Vid=2)Or
           ((((E^.Dat.Dolg<>0)And((t2-t1)<0))And(Vid=0)))) And Not(E^.Dat.Full) Then
         Begin
         If ((E^.Dat.MArket.DocSelector=5) And (Tip=0)) Or (Tip=2) Or (Not(E^.Dat.MArket.DocSelector=5) And (Tip=1)) Then
         Begin
          Str((t2-t1):5,w);
          If Criminal Then w:='?????';
          ws:=GetClientField(FClient,St,0);
          Format(ws,CClient);
          DelSpace(E^.DAt.MArket.Document);
          RFormat(E^.DAt.MArket.Document,CDocnumer);

          if E^.Dat.Realiz then
          begin
          ws:=ws+' '+St+' '+E^.Dat.Market.DateC+'  '+'Реализац'+' {'+w+
          '} '+E^.Dat.Market.Document+'  ';
          w:='0'
          end
          else
          ws:=ws+' '+St+' '+E^.Dat.Market.DateC+'  '+DateToDateString(DAteMask,E^.Dat.Market.Srok)+' {'+w+
          '} '+E^.Dat.Market.Document+'  ';

          w1:=w;

          If Realno=1 Then
          MyStr((E^.Dat.Dolg+StrToReal(E^.Dat.Market.Skidka)),CIZena,CMantissa,w)
          Else
          MyStr((E^.Dat.Dolg),CIZena,CMantissa,w);

          If Criminal Then CriminalSumma:=CriminalSumma+StrToReal(w);

         if bSpec then
         begin
          if StrToInt(w1)>0 then
          begin
            MyStr((StrToReal(w1))*0.005*StrToReal(w),CIZena,CMantissa,sStraf)
          end
          else sStraf:='0.00';
         end
         else
         begin
          if StrToInt(w1)-3>0 then
          begin
            MyStr((StrToReal(w1)-3)*0.005*StrToReal(w),CIZena,CMantissa,sStraf)
          end
          else sStraf:='0.00';
         end;

          MyStr(StrToReal(E^.Dat.Market.Skidka),CIZena,CMantissa,E^.Dat.Market.Skidka);
          MyStr(StrToReal(sStraf),CIZena,CMantissa,sStraf);

          r1:=r1+E^.Dat.Dolg+StrToReal(E^.Dat.Market.Skidka);
          r2:=r2+StrToReal(E^.Dat.Market.Skidka);
          r3:=r3+StrToReal(sStraf);

          ws:=ws+sStraf+' '+w;

          If E^.Dat.MArket.DocSelector in [6,8] Then
           Begin
            rsf:=rsf+E^.Dat.Dolg+StrToReal(E^.Dat.Market.Skidka);
            rsfSkid:=rsfSkid+StrToReal(E^.Dat.Market.Skidka);
            rsfStraf:=rsfStraf+StrToReal(sStraf);
           ws:=ws+' '+'СФ ';
           End
           else
           ws:=ws+'    ';
          {Writeln(f,Space+ws);}
          {сортируем по дате}
          sDate:=copy(ws,1+CClient+1+CClientKod+1,CDate);
          system.Delete(ws,1+CClient+1+CClientKod+1,CDate+1);
          if bSpec then
          SortList^.List^.Insert(NewStr(sDate+' '+ws+' !'))
          else
          SortList^.List^.Insert(NewStr(sDate+' '+ws));
          SortList^.SetRange(SortList^.List^.Count);
         End;
         End;
End;{active}
       End;
      Dispose(E,Done);
      Close(RealFile);
     End;
   End;
 End;


if (SortList<>nil) and (SortList^.List^.Count>0) then
for c:=0 to SortList^.List^.Count-1 do
begin
 ws:=SortList^.GetText(c,SortList^.List^.Count);
 Writeln(f,Space+ws);
end;


Dispose(ClientList,Done);
Dispose(SortList,Done);
Writeln(f,Space+'----------------------------------------------------------------------------------------------');
If Tip In [1,2] Then
Begin
Writeln(f,Space+'                                                   Всего долг:'+RecognizReal(R1,CIZena,CMantissa));
Writeln(f,Space+'                                                  Всего штраф:'+RecognizReal(R3,CIZena,CMantissa));
Writeln(f,Space+'                                      Реальный долг по оплате:'+RecognizReal(R1-R2,CIZena,CMantissa));
If CriminalSumma>0.009 Then
Writeln(f,Space+'ВНИМАНИЕ!Обнаружены накладные консигнации без договора   долг:'+RecognizReal(CriminalSumma,CIZena,CMantissa));
End;

If Tip In [0,2] Then
Begin
Writeln(f,Space+'                                               Всего долг СФ:'+RecognizReal(RSf,CIZena,CMantissa));
Writeln(f,Space+'                                              Всего штраф СФ:'+RecognizReal(RsfStraf,CIZena,CMantissa));
Writeln(f,Space+'                                  Реальный долг по оплате СФ:'+RecognizReal(Rsf-RsfSkid,CIZena,CMantissa));
End;

Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'==============================================================================================');
Close(f);
MyStr(R1,CIZena,CMantissa,st);
MyStr(R2,CIZena,CMantissa,ws);
MyStr(Rsf,CIZena,CMantissa,w);
MyStr(RsfSkid,CIZena,CMantissa,w1);
CalcDolgDebit:=st+' '+ws+' '+w+' '+w1;

If Regim Then
Begin
NoInfo;
ViewAsText(Path.ToTemp+'dolg.txt',True);
Report(Path.ToTemp+'dolg.txt','',1,False,False,false);
End
end;

Procedure CreatPlan;
Var R : TRect;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    RealFile : File Of BArterClientType;
    ClientList :PBox;
    E  : PBArterClientType;
    s,w,w1,st : AllStr;
    ws : TMyString;
    ii,c,t1,t2 : LongInt;
    AllPlateg :Real;
    AllDoc : Word;
    f : Text;
    {DateMask : TDateString;}
    TestDAte : DateString;
    Space : AllStr;
    Tip,Vid,Realno : Word;
begin

If Not DateDialog(TestDAte) Then Exit;


Assign(f,Path.ToTemp+'plan.txt');
c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0)Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path.ToTemp+'plan.txt!!',Nil,mfError+mfCancelButton);
  Exit;
 End;

R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'barter.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c=0 Then
Begin
AInfo('Рассчитываю долги поставщикам...');
While Not(Eof(ClientFile)) Do
 Begin
     ReadClient(ClientFile,ClientElement);

  If ClientElement.Employ Then
   Begin
    Format (ClientElement.Name,CClient);
    ClientList^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
    ClientList^.SetRange(ClientList^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  Close(f);
  Dispose(ClientList,Done);
  MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов',Nil,mfError+mfCancelButton);
  Exit;
 End;

Space:='';
Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword);
Writeln(f,Space+'СПРАВКА ПО ПЛАТЕЖАМ ДО '+TestDate+'            '+FDate+' ('+Times+')');


Writeln(f,Space+'----------------------------------------------------------------------------------');
Writeln(f,Space+'   Поставщик         Код  N док Дата док.  Сумма прихода   Остаток долга Дата плт.');
               { 12345678901234567890│1234│1234 │12345678│123456789012345│123456789012345│12345678}
Writeln(f,Space+'----------------------------------------------------------------------------------');

AllPlateg:=0;
AllDoc:=0;

If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);

    Assign(RealFile,Path.ToBarter+st+'.brt');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    If ii=0 Then
     Begin
      New(E,Init);
      While Not(Eof(RealFile)) Do
       Begin
        Read(RealFile,E^.Dat);
        If (E^.Dat.Active) Then
Begin
        If (E^.DAt.OperatorSelector=0) And (E^.Dat.VidPrihoda=1) Then
         Begin
          If (Abs(StrToReal(E^.DAt.OstatokDolga))>0.009) And
		(DateStringToDAte(DateMask,E^.DAt.SrokPlatega)<=DateStringToDAte(DateMask,TestDate)) Then
           Begin

          ws:=GetClientField(FClient,St,2);
          Format(ws,CClient);
          DelSpace(E^.DAt.Document);
          RFormat(E^.DAt.Document,CDocnumer);
          ws:=ws+' '+St+' '+E^.Dat.Document+'  '+E^.Dat.DateC+' '+
          RealToStr(StRToReal(E^.DAt.PSummaZakupka),CIZena,CMAntissa)+' '+
		RealToStr(StRToReal(E^.DAt.OstatokDolga),CIZena,CMAntissa)+
		+' '+E^.Dat.SrokPlatega;

          AllPlateg:=AllPlateg+StrToReal(E^.DAt.OstatokDolga);
          Inc(AllDoc);

          Writeln(f,Space+ws);

           End;
         End;
End;{active}
       End;{While}
      Dispose(E,Done);
      Close(RealFile);
     End;{ii=0}
   End;{For}
 End;{List<>Nil}
Dispose(ClientList,Done);
Writeln(f,Space+'----------------------------------------------------------------------------------');
Writeln(f,Space+'          Всего необходимо оплатить:'+RecognizReal(AllPlateg,CIZena,CMantissa));
Writeln(f,Space+'                      По '+IntToStr(AllDoc,CKOl)+' документам');

Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'==================================================================================');
    ii:=IOResult;
Close(f);
    ii:=IOResult;

NoInfo;
ViewAsText(Path.ToTemp+'plan.txt',True);
Report(Path.ToTemp+'plan.txt','',1,False,False,false);
end;


Function CalcOutSkladPerevoski (ClientKod : ArtikulStr):AllStr;
Var
    st : AllStr;
    l : Real;
    MarketFile : MArketFileType;
    E : PSuperMarketType;
    i : Word;
begin
 CalcOutSkladPerevoski:='0.00';
 l:=0;
 If GetClientEmploy(ClientKod,1) Then
 Begin
    Assign(MarketFile,Path.ToMarket+FDate+'.mrk');
    i:=IOResult;
    Reset(MArketFile);
    i:=IOResult;
    l:=0;
    If i=0 Then
     Begin
      New(E,Init);
      While Not(Eof(MArketFile)) Do
       Begin
    {
     Repeat
     Until Lock(MarketFile,FilePos(MarketFile)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
    }
     ReadMArket(MarketFile,E);
    {
     Repeat
      UnLock(MarketFile,(FilePos(MarketFile)-1)*SizeOf(SuperMarketType),SizeOf(SuperMarketType));
     Until (DosError=0);
    }

        If(E^.Dat.OperatorSelector=1)And(StrToInt(E^.Dat.ClientKod)=StrToInt(ClientKod))
          And(E^.Dat.Active) Then
         Begin
          l:=l+StrToReal(E^.DAt.SummaZ);
         End;
       End;
      Dispose(E,Done);
      Close(MarketFile);
     End
     Else
      Exit;
 End;
MyStr(L,CIZena,CMantissa,st);
DelSpace(St);
CalcOutSkladPerevoski:=st;
end;

Function CalcInpSkladPerevoski (ClientKod : ArtikulStr):AllStr;
Var
    st : AllStr;
    l : Real;
    PrihodFile : PrihodFileType;
    E : PPrihodType;
    i : Word;
begin
 CalcInpSkladPerevoski:='0.00';
 l:=0;
 If GetClientEmploy(ClientKod,1) Then
 Begin
    Assign(PrihodFile,Path.ToPrihod+FDate+'.prh');
    i:=IOResult;
    Reset(PrihodFile);
    i:=IOResult;
    l:=0;
    If i=0 Then
     Begin
      New(E,Init);
      While Not(Eof(PrihodFile)) Do
       Begin
     {
     Repeat
     Until Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType));
     }
     ReadPrihod(PrihodFile,E);
     {
     Repeat
      UnLock(PrihodFile,(FilePos(PrihodFile)-1)*SizeOf(PrihodType),SizeOf(PrihodType));
     Until (DosError=0);
     }
        If (E^.Dat.OperatorSelector=1)And(StrToInt(E^.Dat.MakeKod)=StrToInt(ClientKod))
           And(E^.Dat.StatusDoc=0) Then
         Begin
          l:=l+StrToReal(E^.DAt.SummaR);
         End;
       End;
      Dispose(E,Done);
      Close(PrihodFile);
     End
     Else
      Exit;
 End;
MyStr(L,CIZena,CMantissa,st);
DelSpace(St);
CalcInpSkladPerevoski:=st;
end;

Function CalcDolgBarter(Regim:Boolean):TMyString;
Var R : TRect;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    RealFile : BarterClientFileType;
    ClientList :PBox;
    E  : PBArterClientType;
    st : AllStr;
    ws,ws1,ws2 : TMyString;
    ii,c : LongInt;
    LSaldo,Saldo,LOborot:Real;
    f : Text;
    {DateMask : TDateString;}
    Space : AllStr;
    Tip,Vid,Realno : Word;
begin
 CalcDolgBarter:='           0.00';
                 {123456789012345 123456789012345 123456789012345 123456789012345}


Assign(f,Path.ToTemp+'dolgb.txt');
c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0) And (Regim) Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path.ToTemp+'dolgb.txt!!',Nil,mfError+mfCancelButton);
  Exit;
 End;
R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'Barter.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;

If c=0 Then
Begin
If Regim Then AInfo('Рассчитываю сальдо по клиентам...');
While Not(Eof(ClientFile)) Do
 Begin
     ReadClient(ClientFile,ClientElement);
  If ClientElement.Employ Then
   Begin
    Format (ClientElement.Name,CClient);
    ClientList^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
    ClientList^.SetRange(ClientList^.List^.Count);
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  Close(f);
  Dispose(ClientList,Done);
  MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов',Nil,mfError+mfCancelButton);
  Exit;
 End;
Space:='         ';
Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword);
Writeln(f,Space+'СПРАВКА ПО САЛЬДО РАСЧЕТОВ С ПОСТАВЩИКАМИ'+'  '+FDate+' ('+Times+')');
Writeln(f,Space+'---------------------------------------------------------');
Writeln(f,Space+'       Клиент         Код          Оборот          Сальдо');
Writeln(f,Space+'---------------------------------------------------------');
			 {12345678901234567890 1234 123456789012345 123456789012345}
Saldo:=0;
If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    St := Copy(st,1+CClient+1,CClientKod);
    ws:=GetClientField(FClient,St,2);
    Format(ws,CClient);
    ws:=ws+' '+st;
    Assign(RealFile,Path.ToBarter+st+'.brt');
    ii:=IOResult;
    Reset(RealFile);
    ii:=IOResult;
    If ii=0 Then
     Begin
      New(E,Init);
      LSaldo:=0;
      LOborot:=0;
      While Not(Eof(RealFile)) Do
       Begin
        Read(RealFile,E^.Dat);
        With E^.Dat Do
        Begin
        If (E^.Dat.Active) Then
          Begin
           Case E^.Dat.OperatorSelector Of
           0:Begin LSaldo:=LSaldo-StrToReal(OstatokDolga);LOborot:=LOborot+StrToReal(PSummaZakupka);End;
           1:Begin LSaldo:=LSaldo+StrToReal(SummaZ)+StrToReal(ENalog);LOborot:=LOborot+StrToReal(SummaZ)+
		      StrToReal(ENalog);
		   End;
          { 2:Begin LSaldo:=LSaldo+StrToReal(Vidano);LOborot:=LOborot+StrToReal(Vidano); End;}
           3:Begin LSaldo:=LSaldo-StrToReal(Priniato);LOborot:=LOborot+StrToReal(Priniato); End;
           5:Begin LSaldo:=LSaldo+StrToReal(Bn.Summa); End;
           Else;
           End;{Case}
          End;{active}
        End;{With}
       End;{While}
      Dispose(E,Done);
      Close(RealFile);
      Saldo:=Saldo+LSaldo;
      MyStr(LSaldo,CIZena,CMantissa,ws1);
      MyStr(LOborot,CIZena,CMantissa,ws2);
      Writeln(f,Space+ws+' '+ws2+' '+ws1);
     End;{ii=0}
   End;{For}
 End;
Dispose(ClientList,Done);
Writeln(f,Space+'---------------------------------------------------------');
Writeln(f,Space+'                            Всего сальдо:'+RecognizReal(Saldo,CIZena,CMantissa));
Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'=========================================================');
Close(f);
MyStr(Saldo,CIZena,CMantissa,st);
CalcDolgBarter:=st;

If Regim Then
Begin
NoInfo;
ViewAsText(Path.ToTemp+'dolgb.txt',True);
Report(Path.ToTemp+'dolgb.txt','',1,False,False,false);
End
end;

Function CalcPrihodBarter (Date:TDateString):AllStr;
Var f : PrihodFileType;
    E : PPrihodType;
    ws : string[150];
    Nalog,Fas,P : String[CPack];
    ItogoZ,ItogoNo : Real;
    St : String[CMantissa];
    ss,ss1 : TEnjoyStr;
    l : Word;
    K : Byte;
    DocNo,Doc : LongInt;
    DDD : ArtikulStr;

Begin
{ ViewAllPrihod:='0.00'^M+#3'(0.00)';}
 CalcPrihodBarter:='           0.00   0';
{                   123456789012345 123 456789012345 123 123}
 Assign(F,Path.ToPrihod+Date+'.prh');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   Exit;
  End;

ItogoZ:=0;
ItogoNO:=0;
Doc:=0;
DocNo:=0;
  New(E,Init);
  While Not Eof(f) Do
  Begin
     ReadPrihod(f,E);
     If (E^.Dat.OperatorSelector=2) Then
     Begin
      ItogoZ:=ItogoZ+StrToReal(E^.Dat.SummaZakupka);
      Inc(Doc);
     End;
  End;

  Close(f);
  Dispose(E,Done);

MyStr(ItogoZ,CIZena,CMantissa,ss);
ss:=ss+' ';
Str(Doc:3,ss1);
ss:=ss+ss1;
CalcPrihodBarter:=ss;
End;


Function ViewOplBArter(Dates:TDateString;Regim : Boolean):AllStr;
Const Space ='    ';
Var     f : OplataBarterFileType;
      Opl : POplataBarter;
  ItogoOZ, ItogoRet: Real;
      Txt : Text;
      l   : Byte;
      S   : string[150];
      TempS : AllStr;
      st,st1  : AllStr;
      Vid : Word;
      DatesEnd : TDAteString;
      l1 : LongInt;
      CurDate : TDAteString;

Begin
 ViewOplBarter:='           0.00            0.00';
{                123456789012345 123456789012345 123456789012345}

 If Regim Then
 Begin
 Dates:=FDate;
 DatesEnd:=FDate;
 If Not(DatePeriodDialog(Dates,DatesEnd,False)) Then Exit;
 End
 Else
  Begin
   Dates:=FDate;
   DatesEnd:=FDate;
  End;

 Assign(Txt,Path.ToTemp+'boplata.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'boplata.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

(*  Vid:=0;
  If Regim Then
  Begin
  Vid:=SelectSpecify(False,9);
  If Vid=3 Then
   Begin
    CLose(f);
    Close(txt);
    Exit;
   End;
  End     1
  Else  *)
   Vid:=2;

ItogoOZ:=0;
ItogoRet:=0;

If Regim Then   DInfo('Минуточку...');

  Writeln(Txt,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+' Оператор:'+CurrentPassword);
  Case Vid Of
  1:Writeln(Txt,Space+'Отбор: Приходы');
  0:Writeln(Txt,Space+'Отбор: Оплаты');
  2:Writeln(Txt,Space+'Отбор: Все');
  Else;
  End;

  Writeln(Txt,Space+' СПРАВКА  ПО  РАСЧЕТАМ  С ПОСТАВЩИКАМИ за период с '+Dates+' по '+DatesEnd);
  Writeln(Txt,Space+'-----------------------------------------------------------------------------------------');
  Writeln(Txt,Space+'Клиент               Код  Док  Вид опер.    Сумма оплаты  Дата опл Время опл     Оператор');
  Writeln(Txt,Space+'-----------------------------------------------------------------------------------------');
                    {12345678901234567890 1234 1234 12345678  123456789012345  12345678 12345678 123456789012}

   New(Opl,Init);

For l1:=DAteStringToDate(DAteMAsk,DAtes) To DAteStringToDate(DAteMAsk,DAtesEnd) Do
Begin
 CurDAte:=DAteToDateString(DAteMAsk,l1);

 Assign(F,Path.ToBarter+CurDAte+'.bpl');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L = 0 Then
  Begin
   While Not Eof(f) Do
    Begin
     ReadOplataBarter(F,Opl);
     If ((Opl^.Dat.OperatorSelector=Vid)Or (Vid=2))Then
     Begin
      s:=GetClientField(FClient,Opl^.Dat.ClientKod,2);
      Format(s,CClient);
      s:=s+' '+Opl^.Dat.CLientKod;
      DelSpace(Opl^.Dat.Order);
      RFormat(Opl^.Dat.Order,CDocNumer);

   If Opl^.Dat.OperatorSelector=0 Then
   Begin
    DelSpace(Opl^.Dat.SummaZ);
    TempS:=Opl^.Dat.SummaZ;
    ItogoRet:=ItogoRet+StrToReal(Opl^.Dat.SummaZ);
   End
   Else
   Begin
    DelSpace(Opl^.Dat.SummaZ);
    TempS:=Opl^.Dat.SummaZ;
    ItogoOZ:=ItogoOZ+StrToReal(Opl^.Dat.SummaZ);
   End;

   RFormat(TempS,CIZena);
   st:=GetOperatorName(Opl^.Dat.Caption);
   Format(St,CKto);
   s:=s+' '+Opl^.Dat.Order+' ';

   If Opl^.Dat.OperatorSelector=0 Then s:=s+'Оплата  '+'  '
   Else s:=s+'Приход  '+'  ';

   s:=s+TempS+'  '+Opl^.Dat.DateC+' '+Opl^.Dat.TimeC+'  '+St;


   If (Opl^.DAt.OperatorSelector=0) And (Opl^.DAt.Link=1) Then
   Begin
    s:=s+^M+Space+'Связанный платеж по документу N '+Opl^.Dat.Doc+' от '+Opl^.Dat.DateC;
   End;

   If (Opl^.Dat.Comment[0]<>#0) Then
   Begin
    s:=s+^M+Space+'Примечание: '+Opl^.Dat.Comment;
   End;


   Writeln(txt,Space+s);
   If Opl^.Dat.Rashet=1 Then
    Begin
     Writeln(txt,Space+'П/П:'+Opl^.Dat.Bn.NPlat+' от '+Opl^.Dat.Bn.Date+' Банк:'+Opl^.Dat.Bn.Bank+' Сумма:'+Opl^.Dat.Bn.Summa);
    End;
    End;
  End;{While}
 l:=Ioresult;
    Close(f);
 l:=Ioresult;
  End;{l=0}

End;{For}
  Dispose(Opl,Done);


  Writeln(Txt,Space+'-----------------------------------------------------------------------------------------');
  If Vid=5 Then
  Writeln(txt,Space+'Всего  сальдо  составило: ',RecognizReal(ItogoOZ-ItogoRet,CIZena,CMantissa)
  ,' руб.');

  If (Vid=5) Or (Vid=5) Then
  Writeln(txt,Space+'В том числе приходы составили: ',RecognizReal(ItogoOZ,CIZena,CMantissa)
  ,' руб.');

  If (Vid=0) Or (Vid=2) Then
  Writeln(txt,Space+'    В оплаты составили: ',RecognizReal(ItogoRet,CIZena,CMantissa)
  ,' руб.');

  Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  Writeln(Txt,Space+'=========================================================================================');
Close(Txt);
If Regim Then NoInfo;

If Regim Then ViewAsText(Path.ToTemp+'boplata.txt',True);
If Regim Then
 Report(Path.ToTemp+'boplata.txt','',1,False,False,false);
 MyStr((ItogoOZ),CIZena,CMantissa,st);
 MyStr((ItogoRet),CIZena,CMantissa,st1);
ViewOplBarter:=st+' '+st1;
End;



Procedure CalcOplBArter(Dates:TDateString;Var All,AllN,AllBN:Real);
Const Space ='    ';
Var     f : OplataBarterFileType;
      Opl : POplataBarter;
  ItogoOZ, ItogoRet: Real;
      Txt : Text;
      l   : Byte;
      S   : string[150];
      TempS : AllStr;
      st,st1  : AllStr;
      Vid : Word;
      DatesEnd : TDAteString;
      l1 : LongInt;
      CurDate : TDAteString;

Begin
All:=0;
AllN:=0;
AllBN:=0;

New(Opl,Init);

 Assign(F,Path.ToBarter+Dates+'.bpl');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L = 0 Then
  Begin
   While Not Eof(f) Do
    Begin
     ReadOplataBarter(F,Opl);
     If (Opl^.Dat.Active)Then
     If (Opl^.Dat.OperatorSelector=0)Then
     Begin
      All:=All+StrToReal(Opl^.Dat.SummaZ);
      If Opl^.Dat.Rashet=0 Then{нал}
         AllN:=AllN++StrToReal(Opl^.Dat.SummaZ);

      If Opl^.Dat.Rashet=1 Then{бн}
         AllBN:=AllBN++StrToReal(Opl^.Dat.SummaZ);

    End;
  End;{While}
  End;{l=0}
  Dispose(Opl,Done);


Close(f);
End;



(*
procedure PrintingZeni(As : DocumentEdit;Vid:Byte);
Const Space='   ';
Var txt : Text;
    k,c,l,t,i,j : LongInt;
    ws,ws1 : string[150];
    f : PereozenkaFileType;
    fp : PrihodFileType;
    s   : Array [1..13] Of string[150];
    E : PPereozenkaType;
    SArt : ArtikulStr;
    Ep : PPrihodType;
    Find : Boolean;
    Rek1 : Rekwiziti;
    Sk : PSkidkaType;
    SkZena : Array[1..CShkala] Of STring[CZena];
    R : TRect;
    Temp: PBox;
    Mas : Maska6;

Begin
 AInfo('Ищу документ...');
 R.Assign(0,0,0,0);
 Temp := New(PBox, Init(R, 1, Nil));
 Temp^.NewList(New(PTextCollection, Init(1,1)));
 Find:=False;
 If Vid=0 Then{если печатать переоценку}
Begin
 Assign(F,Path.ToCorrect+As.D+'.prz');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не найден файл '+Path.ToCorrect+As.D+'.prz',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
   {
   Repeat
   Until Lock(f,FilePos(f)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
   }
   ReadPereozenka(F,E);
   {
   Repeat
    UnLock(f,(FilePos(f)-1)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
   Until DosError=0;
   }
  DelSpace(E^.Dat.Document);
  If  ClearChar(E^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Close(f);
   Dispose(Temp,Done);
   Dispose(E,Done);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
{  If Status=DocPrint Then Status:=DocNormal;}
   Exit;
 End;
 Close(f);

 For c:=1 To E^.DAt.Amount Do
  Begin
   Temp^.List^.Insert(NewStr('│'+E^.DAt.Element[c].BAzKod));
   Temp^.SetRange(Temp^.List^.Count);
  End;
 Dispose(E,Done);
End{если печатать переоценку}
Else
 Begin
 Assign(Fp,Path.ToPrihod+As.D+'.prh');
 l:=IOResult;
 Reset(fp);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не найден файл '+Path.ToPrihod+As.D+'.prh',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(Ep,Init);
 While Not(Eof(fp))And Not(Find) Do
 Begin
   {
   Repeat
   Until Lock(f,FilePos(f)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
   }
   ReadPrihod(Fp,Ep);
   {
   Repeat
    UnLock(f,(FilePos(f)-1)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
   Until DosError=0;
   }
  DelSpace(Ep^.Dat.Document);
  If  ClearChar(Ep^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Close(fp);
   Dispose(Temp,Done);
   Dispose(Ep,Done);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
{  If Status=DocPrint Then Status:=DocNormal;}
   Exit;
 End;
 Close(fp);
 For c:=1 To Ep^.DAt.Amount Do
  Begin
   Temp^.List^.Insert(NewStr('│'+Ep^.DAt.PrihodElement[c].BAzKod));
   Temp^.SetRange(Temp^.List^.Count);
  End;
  Dispose(Ep,Done);
 End;
 NoInfo;

If (Temp^.List^.Count-1>=0) Then
Begin

Assign(txt,path.ToTemp+'zennik.txt');
i:=IOResult;
Rewrite(txt);
i:=IOResult;
If i<>0 Then
  Begin
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'zennik.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

{SelectPrize(Mas,False);}

AInfo('Формирую ценники...');

j:=1;
Rek1:=Rek;
DelSpace(Rek1.Name);
{       123456789012345678901234567890 123456789012345678901234567890 123456789012345678901234567890}

s[1,0]:=#0;
s[2] :=''+Rek1.Name+'$'+Rek1.Name+'$'+Rek1.Name+'$'+Rek1.Name+'$'+
Rek1.Name+'$'+Rek1.Name+'$'+Rek1.Name+'$'+Rek1.Name+'$'+Rek1.Name+'$'+Rek1.Name;
s[3,0]:=#0;{Наименование}
s[4,0]:=#0;{Производство и фасовка}
s[5,0]:=#0;
s[6,0]:=#0;{Базовая-169.50}
s[7,0]:=#0;{Базовая-169.50}
s[8,0]:=#0;{Цена 1}
s[9,0]:=#0;{Цена 2}
s[10,0]:=#0;{Цена 3}
s[11,0]:=#0;{Цена 4}
s[12,0]:=#0;{Цена 5}
s[13]:='Дата:'+FDAte+'$'+'Дата:'+FDAte+'$'+'Дата:'+FDAte+'$'+'Дата:'+FDAte+'$'+
'Дата:'+FDAte+'$'+'Дата:'+FDAte+'$'+'Дата:'+FDAte+'$'+'Дата:'+FDAte+'$'+
'Дата:'+FDAte+'$'+'Дата:'+FDAte;{Цена 6}

k:=0;
For i:=0 To Temp^.List^.Count-1 Do
Begin
SArt:=Copy(Temp^.GetText(i,Temp^.List^.Count),1+1,CArtikul);
{пробиваем наименование}
ws:=GetIdField(FName,SArt);
ws:=Copy(ws,1,13);
ws:=''+ws+'$';
s[3]:=s[3]+ws;

ws:=GetIdField(FName,SArt);
ws:=Copy(ws,14,13);
ws:=''+ws+'$';
s[4]:=s[4]+ws;

{пробиваем фасовку}
ws:=GetIdField(FInPack,SArt);
ws:='x'+ws+'  '+BakGetField(FPost,SArt,0);
s[5]:=s[5]+ws+'$';

{пробиваем цену}
ws:=BakGetField(FRZena,SArt,0);
Str(StrToReal(ws):CZena:CMantissa,ws);
DelSpace(ws);
ws:='   '+ws+'$';

s[6]:=s[6]+ws;


New(Sk,Init);
GetSkidka(SArt,Sk^.Dat);
ws:=BakGetField(FRZena,SArt,0);
Str(StrToReal(ws):CZena:CMantissa,ws);
DelSpace(ws);
For t:=1 To CShkala Do
 Begin
  Str(StrToREal(sk^.Dat.Skidka[t].Up):CZena:0,sk^.Dat.Skidka[t].Up);
  Str((StrToReal(ws)/(1+StrToReal(sk^.Dat.Skidka[t].Proz)/100)):CZena:CMAntissa,SkZena[t]);
  DelSpace(SkZena[t]);
 End;
{123456 123456   123456 123456}

  s[7]:= s[7]+IntToStr(StrToInt(sk^.Dat.Skidka[1].Up) div 1000,CMantissa)+'      '+SkZena[1]+'$';

  s[8]:= s[8]+IntToStr(StrToInt(sk^.Dat.Skidka[2].Up) div 1000,CMantissa)+'      '+SkZena[2]+'$';

  s[9]:= s[9]+IntToStr(StrToInt(sk^.Dat.Skidka[3].Up) div 1000,CMantissa)+'      '+SkZena[3]+'$';

  s[10]:= s[10]+IntToStr(StrToInt(sk^.Dat.Skidka[4].Up) div 1000,CMantissa)+'      '+SkZena[4]+'$';

  s[11]:= s[11]+IntToStr(StrToInt(sk^.Dat.Skidka[5].Up) div 1000,CMantissa)+'      '+SkZena[5]+'$';

  s[12]:= s[12]+IntToStr(StrToInt(sk^.Dat.Skidka[6].Up) div 1000,CMantissa)+'      '+SkZena[6]+'$';


Dispose(Sk,Done);

Inc(j);

{запись строки ценников в файл}
If (j=11) Or (i=Temp^.List^.Count-1) Then
 Begin
  Inc(k);
  For j:=1 To 13 Do
   Begin
    Writeln(txt,s[j]);
   End;

{заполнение чистой формы}
j:=1;
s[1,0]:=#0;
s[2] :=''+Rek1.Name+'$'+Rek1.Name+'$'+Rek1.Name+'$'+Rek1.Name+'$'+
Rek1.Name+'$'+Rek1.Name+'$'+Rek1.Name+'$'+Rek1.Name+'$'+Rek1.Name+'$'+Rek1.Name;

s[3,0]:=#0;{Наименование}
s[4,0]:=#0;{Производство и фасовка}
s[5,0]:=#0;
s[6,0]:=#0;
s[7,0]:=#0;{Базовая-169.50}
s[6,0]:=#0;{Базовая-169.50}
s[8,0]:=#0;{Цена 1}
s[9,0]:=#0;{Цена 2}
s[10,0]:=#0;{Цена 3}
s[11,0]:=#0;{Цена 4}
s[12,0]:=#0;{Цена 5}
s[13]:='Дата:'+FDAte+'$'+'Дата:'+FDAte+'$'+'Дата:'+FDAte+'$'+'Дата:'+FDAte+'$'+
'Дата:'+FDAte+'$'+'Дата:'+FDAte+'$'+'Дата:'+FDAte+'$'+'Дата:'+FDAte+'$'+
'Дата:'+FDAte+'$'+'Дата:'+FDAte;{Цена 6}
 End;
End;

NoInfo;
Close(txt);
MessageBox(^M+#3'Данные успешно эскпортированы в '+Path.ToTemp+'zennik.txt!'^M+
#3'Запустите MS Excel и распечатайте ценники',Nil,mfInformation+mfCancelButton);
End;
Dispose(Temp,Done);
End;

*)





(*
procedure PrintingZeni(As : DocumentEdit;Vid:Byte);
Const Space='   ';
Var txt : Text;
    k,c,l,t,i,j : LongInt;
    ws,ws1 : string[150];
    f : PereozenkaFileType;
    fp : PrihodFileType;
    s   : Array [1..14] Of string[150];
    E : PPereozenkaType;
    SArt : ArtikulStr;
    Ep : PPrihodType;
    Find : Boolean;
    Rek1 : Rekwiziti;
    Sk : PSkidkaType;
    SkZena : Array[1..CShkala] Of STring[CZena];
    R : TRect;
    Temp: PBox;
    Mas : Maska24;
    Region : Word;

Begin
 AInfo('Ищу документ...');
 R.Assign(0,0,0,0);
 Temp := New(PBox, Init(R, 1, Nil));
 Temp^.NewList(New(PTextCollection, Init(1,1)));
 Find:=False;
 If Vid=0 Then{если печатать переоценку}
Begin
 Assign(F,Path.ToCorrect+As.D+'.prz');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не найден файл '+Path.ToCorrect+As.D+'.prz',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(E,Init);
 While Not(Eof(f))And Not(Find) Do
 Begin
   {
   Repeat
   Until Lock(f,FilePos(f)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
   }
   ReadPereozenka(F,E);
   {
   Repeat
    UnLock(f,(FilePos(f)-1)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
   Until DosError=0;
   }
  DelSpace(E^.Dat.Document);
  If  ClearChar(E^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Close(f);
   Dispose(Temp,Done);
   Dispose(E,Done);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
{  If Status=DocPrint Then Status:=DocNormal;}
   Exit;
 End;
 Close(f);

 For c:=1 To E^.DAt.Amount Do
  Begin
   Temp^.List^.Insert(NewStr('│'+E^.DAt.Element[c].BAzKod));
   Temp^.SetRange(Temp^.List^.Count);
  End;
 Dispose(E,Done);
End{если печатать переоценку}
Else
 Begin
 Assign(Fp,Path.ToPrihod+As.D+'.prh');
 l:=IOResult;
 Reset(fp);
 l:=Ioresult;
 If L <> 0 Then
  Begin
   NoInfo;
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не найден файл '+Path.ToPrihod+As.D+'.prh',Nil,mfError+mfCancelButton);
   Exit;
  End;
 New(Ep,Init);
 While Not(Eof(fp))And Not(Find) Do
 Begin
   {
   Repeat
   Until Lock(f,FilePos(f)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
   }
   ReadPrihod(Fp,Ep);
   {
   Repeat
    UnLock(f,(FilePos(f)-1)*SizeOf(PereozenkaType),SizeOf(PereozenkaType));
   Until DosError=0;
   }
  DelSpace(Ep^.Dat.Document);
  If  ClearChar(Ep^.Dat.Document)=ClearChar(As.EditPosition) Then Find:=True;
 End;
 If Not(Find) Then
 Begin
   Close(fp);
   Dispose(Temp,Done);
   Dispose(Ep,Done);
   NoInfo;
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
{  If Status=DocPrint Then Status:=DocNormal;}
   Exit;
 End;
 Close(fp);
 For c:=1 To Ep^.DAt.Amount Do
  Begin
   Temp^.List^.Insert(NewStr('│'+Ep^.DAt.PrihodElement[c].BAzKod));
   Temp^.SetRange(Temp^.List^.Count);
  End;
  Dispose(Ep,Done);
 End;
 NoInfo;

If (Temp^.List^.Count-1>=0) Then
Begin

Assign(txt,path.ToTemp+'zennik.txt');
i:=IOResult;
Rewrite(txt);
i:=IOResult;
If i<>0 Then
  Begin
   Dispose(Temp,Done);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'zennik.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

SelectPrize(Mas,5,Region);

AInfo('Формирую ценники...');

j:=1;
Rek1:=Rek;
Format(Rek1.Name,20);
s[1] :='------------------------------------------------------------------------------------------';
{       123456789012345678901234567890 123456789012345678901234567890 123456789012345678901234567890}
s[2] :=Italic[Nprint.Printer]+Condensed[Nprint.Printer]+'     '+Rek1.Name+'     '+
                                                        '     '+Rek1.Name+'     '+
											 '     '+Rek1.Name+'     '+
											 '     '+Rek1.Name+'     '+
											 '     '+Rek1.Name+'     '+
NoItalic[Nprint.Printer]+NoCondensed[Nprint.Printer];
{5 наименование организации}
{}
s[3,0]:=#0;{Наименование}
s[4,0]:=#0;{Фасовка}
s[5,0]:=#0;{Производство}
s[6,0]:=#0; {Базовая}
s[7,0]:=#0;{169.50}
s[8,0]:=#0;{Цена 1}
s[9,0]:=#0;{Цена 2}
s[10,0]:=#0;{Цена 3}
s[11,0]:=#0;{Цена 4}
s[12,0]:=#0;{Цена 4}
s[13,0]:=#0;{Цена 4}
s[14,0]:=#0;{Цена 4}

k:=0;
For i:=0 To Temp^.List^.Count-1 Do
Begin
SArt:=Copy(Temp^.GetText(i,Temp^.List^.Count),1+1,CArtikul);
{пробиваем наименование}
ws:=GetIdField(FName,SArt);
format(ws,CName);
ws:=' '+ws+'   ';
s[3]:=s[3]+ws;
{пробиваем фасовку}
ws:=GetIdField(FLitr,SArt);
Format(ws,CInPack+2);
ws:=Condensed[Nprint.Printer]+'    Масса:     '+ws+'          '+NoCondensed[Nprint.Printer];
s[4]:=s[4]+ws;

ws:=BakGetField(FPost,SArt,0);
Format(ws,CPost);
ws:=Condensed[Nprint.Printer]+' Производство:'+ws+' '+NoCondensed[Nprint.Printer];
{Производ-во:123456789012345}
s[5]:=s[5]+ws;
{пробиваем цену}
ws:=BakGetField(FRZena,SArt,0);
Str(StrToReal(ws):CZena-2:CMantissa,ws);
DelSpace(ws);
ws:=' '+ws;
Format(ws,CZena+1);
s[6]:=s[6]+Italic[NPrint.Printer]+Bold[NPrint.Printer]+'     Базовая      '+
+NoItalic[NPrint.Printer]+NoBold[NPrint.Printer];
s[8]:=s[8]+{Condensed[NPrint.Printer]+' '+Condensed[NPrint.Printer]+}High[NPrint.Printer]+Bold[NPrint.Printer]+
{Italic[NPrint.Printer]+}
{Double[NPrint.Printer]+}
ws+
NoHigh[NPrint.Printer]{NoBold[NPrint.Printer]+NoItalic[NPrint.Printer]+NoDouble[NPrint.Printer]};
New(Sk,Init);
GetSkidka(SArt,Sk^.Dat);

For t:=1 To CShkala Do
 Begin
  Str(StrToREal(sk^.Dat.Skidka[t].Up):CZena-3:0,sk^.Dat.Skidka[t].Up);
  Str((StrToReal(ws)*StrToReal(sk^.Dat.Skidka[t].Proz)):CZena-2:CMAntissa,SkZena[t]);
 End;
{123456 123456   123456 123456}

If Mas[1]=1 Then
s[9]:= s[9]+Italic[NPrint.Printer]+Bold[NPrint.Printer]+'от '+sk^.Dat.Skidka[1].Up+' - '+SkZena[1]+'│';
If Mas[2]=1 Then
s[10]:= s[10]+Italic[NPrint.Printer]+Bold[NPrint.Printer]+'от '+sk^.Dat.Skidka[2].Up+' - '+SkZena[2]+'│';
If Mas[3]=1 Then
s[11]:=s[11]+Italic[NPrint.Printer]+Bold[NPrint.Printer]+'от '+sk^.Dat.Skidka[3].Up+' - '+SkZena[3]+'│';
If Mas[4]=1 Then
s[12]:=s[12]+Italic[NPrint.Printer]+Bold[NPrint.Printer]+'от '+sk^.Dat.Skidka[4].Up+' - '+SkZena[4]+'│';
If Mas[5]=1 Then
s[13]:=s[13]+Italic[NPrint.Printer]+Bold[NPrint.Printer]+'от '+sk^.Dat.Skidka[5].Up+' - '+SkZena[5]+'│';
If Mas[6]=1 Then
s[14]:=s[14]+Italic[NPrint.Printer]+Bold[NPrint.Printer]+'от '+sk^.Dat.Skidka[6].Up+' - '+SkZena[6]+'│';


Dispose(Sk,Done);

Inc(j);

{запись строки ценников в файл}
If (j=6) Or (i=Temp^.List^.Count-1) Then
 Begin
  Inc(k);
  For j:=1 To 14 Do
   Begin
    If j=3 Then s[3]:=Double[Nprint.Printer]+Condensed[Nprint.Printer]+s[3]+NoDouble[Nprint.Printer]+
    NoCondensed[Nprint.Printer];
    if j<>7 Then
     If Not((j=9)And(Mas[1]=0)) And
        Not((j=10)And(Mas[2]=0)) And
        Not((j=11)And(Mas[3]=0)) And
        Not((j=12)And(Mas[4]=0)) And
        Not((j=13)And(Mas[5]=0)) And
        Not((j=14)And(Mas[6]=0)) Then

    Writeln(txt,Space+s[j]);
   End;
  iF K=4 Then
   Begin
        k:=1;
    Writeln(txt,EndPage[NPrint.Printer]);
   End;

{заполнение чистой формы}
j:=1;
Format(Rek1.Name,20);
s[1] :='------------------------------------------------------------------------------------------';
{       123456789012345678901234567890 123456789012345678901234567890 123456789012345678901234567890}
{
s[2] :=Italic[Nprint.Printer]+Condensed[Nprint.Printer]+Rek1.Name+NoCondensed[Nprint.Printer]+NoItalic[NPrint.Printer]+'│'+
       Italic[Nprint.Printer]+Condensed[Nprint.Printer]+Rek1.Name+NoCondensed[Nprint.Printer]+NoItalic[NPrint.Printer]+'│'+
       Italic[Nprint.Printer]+Condensed[Nprint.Printer]+Rek1.Name+NoCondensed[Nprint.Printer]+NoItalic[NPrint.Printer]+'│'+
	  Italic[Nprint.Printer]+Condensed[Nprint.Printer]+Rek1.Name+NoCondensed[Nprint.Printer]+NoItalic[NPrint.Printer]+'│';
       }
s[2] :=Italic[Nprint.Printer]+Condensed[Nprint.Printer]+'     '+Rek1.Name+'     '+
                                                        '     '+Rek1.Name+'     '+
											 '     '+Rek1.Name+'     '+
											 '     '+Rek1.Name+'     '+
											 '     '+Rek1.Name+'     '+
NoItalic[Nprint.Printer]+NoCondensed[Nprint.Printer];

{5 наименование организации}
{}
s[3,0]:=#0;{Наименование}
s[4,0]:=#0;{Фасовка}
s[5,0]:=#0;{Производство}
s[6,0]:=#0;
s[7,0]:=#0;{Базовая-169.50}
s[8,0]:=#0;{Цена 1}
s[9,0]:=#0;{Цена 2}
s[10,0]:=#0;{Цена 3}
s[11,0]:=#0;{Цена 4}
s[12,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[13,0]:=#0;{'------------------------------------------------------------------------------------------';}
s[14,0]:=#0;{'------------------------------------------------------------------------------------------';}
 End;
End;

NoInfo;
Close(txt);
Report(Path.ToTemp+'zennik.txt','',NPrint.CopyPrz,False,False);
End;
Dispose(Temp,Done);
End;
*)



Procedure FindLAstDoc(Cod,DD:TDAteString; Var SSDoc,SSDAte,SAg:TDAteString);
Var Es : StatClientType;
    Esf : File Of StatClientType;
    i : Byte;
    j : LongInt;
    Find : Boolean;
Begin
 Assign(Esf,Path.ToClient+Cod+'.his');
 i:=IOResult;
 Reset(Esf);
 i:=IOResult;
 If i <> 0 Then
  Begin
    Exit;
  End;
        Find:=False;
        {алгоритм обратного позиционирования по файлу}
        j:=FileSize(Esf)-1;
        While (j>=0) And Not(Find) Do
         Begin
          Seek(Esf,j);
          Read(Esf,Es);
          If (DateStringToDAte(DAteMask,Es.DateC)<
		    DateStringToDAte(DAteMask,DD)) Then
		Begin
		 Find:=True;
           SAg:=Es.AgentKod;
           SSDoc:=Es.Document;
           SSDate:=Es.DateC;
          End;
          Dec(j);
         End;

    Close(EsF);
    i:=IoREsult;
End;


Procedure CretLockReport;
Var R : TRect;
    ClientFile : ClientFileType;
    ClientElement : ClientType;
    ClientList :PBox;
    SOperator,Status,SDAte: AllStr;
    s : string[150];
    st,ws : TMyString;
    f : Text;
    Period, SAgent,
    Space, SLAstDoc, SLAstDate : AllStr;
    Tip,Vid,Realno : Word;
    Cod,StartDate,StopDAte : TDAteString;
    ss,Start,Stop : LongInt;
    k,c : Word;
    Lk: LockClientType;
    fclk: File Of LockClientType;
    Separator : AllStr;

begin
{отбор клиентов по статусу}
Tip:=SelectSpecify(True,12);

If tip=3 Then Exit;


If Not(DAtePeriodDialog(StartDAte,StopDAte,FAlse)) Then Exit;

Start:=DateStringToDAte(DAteMAsk,StartDAte);
Stop:=DateStringToDAte(DAteMAsk,StopDAte);


Assign(f,Path.ToTemp+'loglock.txt');
c:=IOResult;
Rewrite(f);
c:=IOResult;
If (c<>0) Then
 Begin
  MessageBox(#3^M+#3'Ошибка создания файла '+Path.ToTemp+'loglock.txt.txt!!',Nil,mfError+mfCancelButton);
  Exit;
 End;


Separator:=' ';
If MessageBox(^M+#3'Подготовить данные к конвертации в Excel?',
              Nil,mfConfirmation+mfOkCancel)=cmOk Then Separator:='$';


R.Assign(0, 0, 0, 0);
ClientList := New(PBox, Init(R, 1, Nil));
ClientList^.NewList(New(PTextCollection, Init(0,1)));
Assign (ClientFile,Path.ToClient+'Client.db');
c:=IOResult;
Reset (ClientFile);
c:=IOResult;
If c=0 Then
Begin
DInfo('Создаю список клиентов...');
While Not(Eof(ClientFile)) Do
 Begin
     ReadClient(ClientFile,ClientElement);

  If (ClientElement.Employ) Then
   Begin
    {Writeln(ClientElement.LockTime,' ',Tip);}
    If (ClientElement.LockTime And (Tip=1)) Or
       (Not ClientElement.LockTime And (Tip=0)) Or (Tip=2) Then
    Begin
     Format (ClientElement.Name,CClient);
     ClientList^.List^.Insert(NewStr(ClientElement.Name+'│'+ClientElement.Kod));
     ClientList^.SetRange(ClientList^.List^.Count);
    End;
   End;
 End;
System.Close(ClientFile);
End
Else
 Begin
  Close(f);
  Dispose(ClientList,Done);
  MessageBox(#3^M+#3'Ошибка доступа к файлу клиентов',Nil,mfError+mfCancelButton);
  Exit;
 End;



Space:='';
Writeln(f,Space+'Склад: ',GetClientField(FClient,Rek.Kod,1)+'  Оператор: '+CurrentPassword);
Writeln(f,Space+'ОТЧЕТ по блокировкам клиентов за период с '+StartDAte+' по '+StopDAte);
Writeln(f,Space+'  '+FDate+' ('+Times+')');

Write(f,Space+'Вид отбора: ');
Case Tip Of
0:Writeln(f,'Разблокированные');
1:Writeln(f,'Заблокированные');
2:Writeln(f,'Все');
Else Writeln(f);
End;

Writeln(f,Space+'-------------------------------------------------------------------------------------------');
Writeln(f,Space+'       Клиент       '+Separator+' Код'+Separator+'Статус '+Separator+'  Дата'+Separator+
'  Оператор'+Separator+'   Nдок '+Separator+'Дата док'+Separator+'        Агент     '+Separator+' !'+Separator);
{                12345678901234567890|1234|Деблок|12345678|123456789012│1234│12345678│12345678901234567890│}
Writeln(f,Space+'-------------------------------------------------------------------------------------------');

If (ClientList^.List^.Count-1)>=0 Then
 Begin
  For c:=0 To ClientList^.List^.Count-1 Do
   Begin
    st := ClientList^.GetText(c,ClientList^.List^.Count);
    st[CClient+1]:=Separator[1];
    Cod := Copy(st,1+CClient+1,CClientKod);
    Assign(fclk,PAth.ToClient+Cod+'.lck');
    k:=IOResult;
    Reset(fclk);
    k:=IOResult;
    if k=0 Then
     Begin
      {поиск в протоколе блокировок указанного периода}
      While Not(Eof(fclk)) Do
      Begin
       Read(fclk,Lk);
       SS:=DateStringToDate(DateMAsk,Lk.LockDAte);
       If (ss>=Start) And (ss<=Stop) Then
        Begin
         Case Lk.Status of
         0:Status:='Деблок';
         1:Status:='Блокир';
         Else
	      Status:='??????';
         End;{CAse}
         SDAte:=Lk.LockDAte;
         Format(SDate,CDate);
         If StRToInt(Lk.Caption)=99 Then SOperator:='AUTO'
         Else SOperator:=GetOperatorNAme(Lk.CAption);
         Format(Soperator,CKto);
         Period:='  ?';
         SLastDoc:='';
         SLastDate:='';
         SAgent:='';
         FindLastDoc(Cod,SDAte,SLAstDoc,SLAstDAte,SAgent);
         If SAgent<>'' Then SAgent:=GetAgentField(FAgent,SAgent);
         Format(SAgent,CClient-2);
         Format(SLastDoc,CDocnumer);
         Format(SLastDate,CDate);

         If (Filepos(fclk)-2) >=0 Then
          Begin
           Seek(fclk,FilePos(fclk)-2);
           Read(fclk,Lk);
           Str(DateStringToDAte(DAteMAsk,SDAte)
		    -DateStringToDAte(DAteMAsk,Lk.LockDAte):3,Period);
           Read(fclk,Lk);{возвращаемся в старую позицию}
          End;


         s:=St+Separator+Status+Separator+SDAte+Separator+SOperator+Separator+
         SLAstDoc+Separator+SLAstDAte+Separator+SAgent+Separator+Period;
         Writeln(f,Space+s);


        End;{мы в указанном диапазоне дат}

        If ss>Stop Then Break;

     End;
      k:=IOResult;
      Close(fclk);
      k:=IOResult;
     End{нет онформации о блокировках}
     Else Writeln(f,Space+st);



   End;
 End;
Dispose(ClientList,Done);
Writeln(f,Space+'-------------------------------------------------------------------------------------------');
Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
Writeln(f,Space+'===========================================================================================');
Close(f);
NoInfo;
ViewAsText(Path.ToTemp+'loglock.txt',True);
Report(Path.ToTemp+'loglock.txt','',1,False,False,false);
end;








End.{Unit}
