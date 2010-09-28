{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}

{$I Compile.INC}

Unit Vision1;

Interface

Uses Glob,Dialogs,ServStr,Serv,Utils,UtilsP,DBIII;

Function PrintSklad_Or_Prise(Video:Boolean;K:Byte;Const Spis:PBox;Const M:MaskaNew;Const Assort,ZapretOpt,Sort,
  Sertif,Akzis:Word):
TEnjoyStr;
Function ViewAllNakl (Date: TDateString; Regim:Boolean;Debit:Boolean;Default:Byte):TMyString;
Function ViewAllRP (Date: TDateString; Regim:Boolean):TMyString;
Procedure PrintRashodOrder(As : DocumentEdit);
{Procedure PrintOrderPlategC(SDoc,SClient,Summa:AllStr;All:Boolean;l:Word;Var Txt:Text;NDS:Real);}

Procedure PrintOrderPlategC(PrhNum,NaklNum,SDoc,SClient,Summa:AllStr;All:Boolean;l:Word;
                            Var Txt:Text;NDS,NAlog:Real);

Procedure PrintOrder(E:PSuperMarketType; NDS,NP,Itogo:Real;Var Txt:Text);
Procedure FormSF( Video : Boolean; E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Real);


Function TestMarketSF(Const s:ArtikulStr;Const Lg:PsuperMarketType;Var i:Byte):Boolean;
Function TestRazdel(s:TDateString;Const M:MaskaNew;Const Assort:Byte;Const TipID:Word):Boolean;

Procedure PrintOrder2(Osn,Lizo,Doc,Date,Kod,Summa:AllStr);

{
Const Bold=#27+'E';
      NoBold=#27+'F';
      Double=#27+'G';
      NoDouble=#27+'H';
      Pitch ='!Б';
      Condensed=#27#15;
      NoCondensed=#27#18;
      High =#14;
      NoHigh=#27#87+'0';
      Italic='!A';
      NoItalic='!';
}


Implementation

Uses App,DBEngine,MsgBox,Tools,Printers,Objects,Views,Propiss,
     TpDate,Access,Prise,Dos,Drivers,
      Validate,NetDBEng,Vision4,Memory;




Function TestRazdel(s:TDateString;Const M:MaskaNew;Const Assort:Byte;Const TipID:Word):Boolean;
Var E : PSkladType;
    Ef: SkladFileType;
    I : Byte;
    B : Boolean;
Begin
 TestRazdel:=False;
 I:=IoResult;
 Assign(ef,Path.ToSklad+s+'.db');
 Reset(Ef);
 I:=IOResult;
 If I=0 Then
  Begin
   New(E,Init);
   B:=FAlse;
   While Not(Eof(ef)) And Not(B)Do
   Begin
   ReadSkladPointer(ef,E);
   For i:=1 To CDivision Do
    Begin
    If M[i]=1 Then
    If ((StrToInt(E^.Dat.Input.DivisionS[i])>0) And (E^.Dat.Employ) And (Assort=0))
    Or((E^.Dat.Employ) And (Assort>0)) Then
     Begin
     If (GetIdMArket(E^.Dat.BazKod)=TipID) Or (TipID=2) Then B:=True;
     End;
    End;
   End;
   TestRazdel:=B;
   Close(ef);
   Dispose(E,Done);
  End
  Else Exit;
End;


{$IFNDEF Kurz}

Function PrintSklad_Or_Prise
(Video:Boolean;K:Byte;Const Spis:PBox;Const M:MaskaNew;Const Assort,ZapretOpt,Sort,Sertif,Akzis:Word):TEnjoyStr;
Var R,R1 : TRect;
    l,lk : Word;
    Txt,ttt : Text;
    UnPack,Fas,TempArtikul,ss : AllStr;
    s,ws,ws1,ws2,sdbf : string;
    Otdel,Pack,P : String[CPack];
    TextSertif,Space : TEnJoyStr;
    RazdelZ,RazdelO,RazdelR,ItogoR,ItogoZ,ItogoO : Real;
    SpezZena,
    stzz,stRz,stOz : String[CPost];
    E : PSkladType;
    Valuta :Word;
    Withnp,KursUSD : String[CZena];
    Usd : Real;
    Wk : String[CKol];
    VidNal,Regim,i : Byte;
    Ef : SkladFileType;
    SProz : TDAteString;
    Skidka : Boolean;
    Koef : Real;
    Art,Koeffizient : String[CArtikul];
    KoefWord : Word;
    TempDBF,Temp,TempList : PBox;
    WspomList: PBox;
    Separator : String[CLitrMantissa];
    Ansi : Word;
    TipID : LongInt;
    MaxSh,sh,VidPrize,Ver : Word;
    ZPrize : Maska24;
    SK : PSkidkaType;
    MMM : ArtikulStr;
    Region : Word;
    VVV, MMMAr  : MAska6;
    VVVS : TAutoString1;
    c : LongInt;
    CList : PBox;
    ClKod : ArtikulStr;
    ClientShkala,RR : Word;
    Base : DBase3;
    Event: TEvent;
    PrintCopy: longint;
    LL: boolean;
    sfas: string[CLitr];
    sDes:String[2];

procedure PrintMyPrice;
Begin
  PrintCopy:=1;
{  PrintCopy:=GetCopy(PrintCopy,LL);
  If Not(ll) Then Exit;}

  Assign(ttt,Path.ToOperator+'price.ini');
  Rewrite(ttt);
  Writeln(ttt,'[common]');
  {Путь к файлам с отчетами}
  Writeln(ttt,'PathBase='+Path.ToTemp);
  Writeln(ttt,'PrintCopy=',PrintCopy);
  Close(ttt);


  NoInfoMsg;
  CursorLines:=1543;
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;

  DoneDosMem;
  SwapVectors;
  Ver := DosVersion;
  If Ver<>5{ у XP и 2000 версия 5} Then
  Exec(GetEnvMy,' /c Start.exe '+Path.ToOperator+'price.exe ')
  Else
  Exec(GetEnvMy,' /C Start /D'+Path.ToOperator+' price.exe ');
  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;

  Event.What:=evCommand;
  Event.Command:=cmNone;
  Application^.PutEvent(Event);

  Application^.Redraw;
End;

Begin
 PrintSklad_Or_Prise:='           0.00';
 If Video Then
 Assign(Txt,Path.ToTemp+'report.txt')
 Else
 Assign(Txt,Path.ToTemp+'reporti.txt');

 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If (L <> 0) And (Video) Then
  Begin
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'report.txt',Nil,mfError+mfCancelButton);
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

  {Dispose(Spis,Done);}

 If Video Then
 Begin
   if k<>1 then Regim:=SelectSort
   else Regim:=1;
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


  If k=0 Then
     Begin
     If FindParam('/EZ') Then
     VidNal:=SelectVidNalich
     Else
     VidNal:=0;
     If VidNal=3 Then
      Begin
       Close(Txt);
       Dispose(TempList,Done);
       Exit;
      End;
     End;
 End
 Else  Begin
        Regim:=1;
        VidNal:=0;
       End;

Valuta:=0;
KoefWord:=0;
Koef:=1.00;
Koef:=StrToReal(Koeffizient);

If Video Then
Begin

       For c:=1 To 6 Do
        Begin
         MMMAr[c]:=0;
        End;

(*  If k=100 Then
   Begin
    VidPrize:=SelectPrize(ZPrize,5,Region,True,MMMAr);
  If VidPrize<>0 Then
   Begin
    Close(Txt);
    Dispose(TempList,Done);
    Exit;
   End;

  If Region=5 Then
  Begin
  R1.Assign(0,0,0,0);
  CList := New(PBox, Init(R1, 1, Nil));
  CList^.NewList(New(PTextCollection, Init(0,1)));

   If Not SelectionClient(True,CList) Then
   Begin
    Close(Txt);
    Dispose(CList,Done);
    Dispose(TempList,Done);
    Exit;
   End;
    ws2:=CList^.GetText(0,CList^.List^.Count);
    ClKod:=Copy(ws2,1+1,CClientKod);

    ClientShkala:=StrToInt(GetClientField(FShkala,ClKod,0));
    RR:=StrToInt(GetClientField(FRegion,ClKod,0));

 If ClientShkala>0 Then
 Begin
  ClientShkala:=ClientShkala+(6)*(RR);
 End
 Else
 ClientShkala:=0;


   Dispose(CList,Done);
 End;

 If Region=5 Then
  If Not(Password(5)) Then
     Begin
      Close(Txt);
      Dispose(CList,Done);
      Dispose(TempList,Done);
      Exit;
     End;



    If Region=4 Then{вариант когда используется резервный регион - спец-прайс}
     Begin

       For c:=1 To 6 Do
        Begin
         VVV[c]:=0;
         VVVS[c]:=MYS[c];
        End;


       For c:=1 To 6{CShkala} Do
        Begin
         If MMMAr{ZPrize}[c]=1 Then
          Begin
           VVV[Round(c{-Region*6})]:=1;
           {MemCC(IntToStr(Round(c-Region*6),CKol));}
          End;
        End;

      If Not GetGranizi(VVV,VVVS) Then
       Begin
        Close(Txt);
        Dispose(TempList,Done);
        Exit;
       End;

     End;

   End;         *)

  TipID:=SelectIDTip;
  If TipID=3 Then
   Begin
    Close(Txt);
    Dispose(TempList,Done);
    Exit;
   End;


  If k in[0] Then
 Begin
  If True{(StrtoInt(CurrentPassword) in [0,8,9])} then
   begin
     Valuta:=Kurs(KursUSD);
     MyStr(StrToReal(KursUsd),CZena,CMantissa,KursUSD);
     If Valuta=2 Then
      Begin
        Close(Txt);
        Dispose(TempList,Done);
        Exit;
      End;
     If Valuta=1 Then Usd:=StrToReal(KursUSD);
   end
  End
   Else
     Begin
      Valuta:=0;
      Usd:=1;
     End;


  If k in[100] Then
  Begin
  {If (StrtoInt(CurrentPassword) in [0,8,9]) then}
   begin
     KoefWord:=Menedger(Koeffizient);
     If KoefWord=2 Then
      Begin
        Close(Txt);
        Dispose(TempList,Done);
        Exit;
      End;
     Koef:=StrToReal(Koeffizient);
   end
  End
   Else
    Begin
     Koef:=1;
    End;


  If {(StrtoInt(CurrentPassword) in [0,8,9]) And} (k in[0]) then
   begin
     Ansi:=SelectImport(0);
     If Ansi=2 Then
      Begin
        Close(Txt);
        Dispose(TempList,Done);
        Exit;
      End;
     Case Ansi Of
     0:Separator :='$';
     1:Separator :=' ';
     Else;
     End;
   end
   Else
   Separator:=' ';
End
Else
  Begin
   Separator:=' ';
   TipID:=2;
  End;




  DInfo('Анализирую данные...');

If Video Then
  Begin

  If k=1 Then
  Writeln(Txt,'Предприятие:'+Rek.Name);
  Writeln(Txt,'Склад: '+{GetClientField(FClient,}Rek.Kod{,1)+}+'Оператор: '+CurrentPassword+' EYE & 1999');
  If k=1 Then
   Begin
    Writeln(Txt,'Адрес:'+Rek.Adress+' Телефон: '+Rek.Telefon);
   End;

If k<>1 Then{если не прайс лист}
Begin
  Write(Txt,'Вид отбора: ');
  Case TipId Of
  0:Writeln(txt,'Запрещенные к продаже');
  1:Writeln(txt,'Разрешенные к продаже');
  2:Writeln(txt,'Все');
  Else Writeln(txt);
  End;

  Writeln(Txt,'Выбранные отделения:');
  For l:=1 To CDivision Do
  If M[l]=1 Then Write(txt,l:2,':',Rek.Otdel[l],' ');
  Writeln(Txt);
End;
  Case K Of
  0:Begin

  Case VidNal Of
  0:Begin
Space:='  ';
If Valuta=0 Then
Writeln(Txt,Space+'      Н А Л И Ч И Е   Т О В А Р А   Н А   С К Л А Д Е   (рубли)   '+FDate+'  '+Times)
Else
Begin
Writeln(Txt,Space+'      КУРС USD: ',KursUSD);
Writeln(Txt,Space+'      Н А Л И Ч И Е   Т О В А Р А   Н А   С К Л А Д Е   (USD)   '+FDate+'  '+Times);
End;

Writeln(Txt,Space+'_____________________________________________________________________________________');
Writeln(Txt,Space+' Код  О Наименование товара        Фас Колич   О/Цена   Р/Цена    Сумма Р/Ц  Упаковок');
                  {12345 1 12345678901234567890123456│123│12345│}
Writeln(Txt,Space+'_____________________________________________________________________________________');
    End;
  1:Begin
Space:='';
If Valuta=0 Then
  Writeln(Txt,Space+'               Н А Л И Ч И Е  ТОВАРА НА СКЛАДЕ (рубли) '+FDate+'  '+Times)
Else
 Begin
  Writeln(Txt,Space+'      КУРС USD: ',KursUSD);
  Writeln(Txt,Space+'               Н А Л И Ч И Е  ТОВАРА НА СКЛАДЕ (USD) '+FDate+'  '+Times);
 End;
  Writeln(Txt,Space+'_______________________________________________________________________________________________');
  Writeln(Txt,Space+' Код  О Наименование товара        Фас Колич.  Р/Цена  Сумма по Р/Ц   %     З/Цена Сумма по З/Ц');
 {Writeln(txt,Space+'12345 1 12345678901234567890123456 123 12345 12345678 1234567890123 12345 12345678 1234567890123');}
{Writeln(Txt,Space+' Код  Отд  Наименование товара        Фас Колич  Упаковок');}
  Writeln(Txt,Space+'_______________________________________________________________________________________________');
    End;
    Else;
    End;
    End;          {12345      12345678901234567890123456 12345 12345678 12345678 1234567890123 123456789}
  1:Begin
Space:='';
Writeln(txt);
Writeln(Txt,Space+Rek.Header);
Writeln(txt);
If Valuta=0 Then
Begin
Writeln(Txt,Space+'                     П Р А Й С - Л И С Т   (рубли)    '+FDate);
Writeln(Txt,Space+'('+Times+')');
End
Else
 Begin
  Writeln(Txt,Space+'      КУРС USD: ',KursUSD);
  Writeln(Txt,Space+'                     П Р А Й С - Л И С Т   (USD)    '+FDate);
  Writeln(Txt,Space+'('+Times+')');
 End;

If k=1 Then
If Region=5 Then
     Writeln(Txt,GetClientField(FClient,ClKod,0)+' ('+ClKod+')');


 s:=' Код  Отд  !!! Наименование товара      Фас Цена РЦ ';
{s:=' Код  Отд  Наименование товара        Производитель Фас Цена Р/Ц ';}
    {12345 123  123456789012345678901234 1234567890123 123 12345678 12345678 12345678 12345678 }
    {12345 123  123456789012345678901234 123 12345678 12345678 12345678 12345678 12345678 12345678}
 For sh:=1 To CShkala Do
  Begin
   If ZPrize[sh]=1 Then
    Begin
    ws:=IntToStr(Round(sh-Region*6),CMAntissa);
    RFormat(ws,COne);
    s:=s+' Цена '+ws+' ';
    End;
  End;

 For sh:=1 To 6 Do
  Begin
   If MMMAr[sh]=1 Then
    Begin
    ws:=IntToStr(Round(sh),CMAntissa);
    RFormat(ws,COne);
    s:=s+' Цена '+ws+' ';
    End;
  End;

  s[0]:=Chr(Ord(s[0])-1);
 ws[0]:=#0;
 For sh:=1 To Ord(s[0]) Do
  Begin
    ws[sh]:='_';
    ws[0]:=Chr(sh);
  End;
  MaxSh:=Sh;

CAse Region Of
0:Writeln(Txt,Space+Rek.LizensiaOptPiv[Region+1]);
1:Writeln(Txt,Space+Rek.LizensiaOptPiv[Region+1]);
2:Writeln(Txt,Space+Rek.LizensiaOptPiv[Region+1]);
3:Writeln(Txt,Space+Rek.LizensiaOptPiv[Region+1]);
4:Writeln(Txt,Space+'??');
Else;
End;

Writeln(Txt,Space+ws{'______________________________________________________________________________________________'});
DelSpaceRight(Rek.Shapka1);
If Rek.Shapka1[0]<>#0 Then
 Writeln(Txt,Space+Rek.Shapka1);
DelSpaceRight(Rek.Shapka2);
If Rek.Shapka2[0]<>#0 Then
 Writeln(Txt,Space+Rek.Shapka2);
DelSpaceRight(Rek.Shapka3);
If Rek.Shapka3[0]<>#0 Then
 Writeln(Txt,Space+Rek.Shapka3);

Writeln(Txt,Space+ws{'______________________________________________________________________________________________'});
{Writeln(Txt,Space+' Код  Отд  Наименование товара          Р/Цена   О/Цена Фас   Цена уп.Р/Ц   Цена уп.О/Ц');
Writeln(Txt,Space+'_______________________________________________________________________________________');}
Writeln(Txt,Space+s{' Код  Отд  Наименование товара        Производитель        Фас   О/Цена  Цена+НП   Цена+НП уп.'});
                  {12345 1    12345678901234567890123456 12345678901234567890 123 12345678 12345678 1234567890123}
Writeln(Txt,Space+ws{'______________________________________________________________________________________________'});

New(Sk,Init);

    End;
  2:Begin
Space:='  ';
Writeln(Txt,Space+'          А К Т   Р Е В И З И И   Н А   С К Л А Д Е   от '+FDate+'  '+Times);
Writeln(Txt,Space+'________________________________________________________________________________________');
Writeln(Txt,Space+'                                                                    Реальное наличие');
Writeln(Txt,Space+' Код  Отд  Наименование товара        Колич  Упаковок  Р/Цена,    Колич,     Упаковок');
Writeln(Txt,Space+'                                                         руб        шт');
Writeln(Txt,Space+'________________________________________________________________________________________');
{
Writeln(Txt,Space+'            А К Т   Р Е В И З И И   Н А   С К Л А Д Е   от '+FDate+'  '+Times);
Writeln(Txt,Space+'________________________________________________________________________________________');
Writeln(Txt,Space+'                                                                  Реальное наличие ');
Writeln(Txt,Space+' Код  Отд  Наименование товара        Колич  Упаковок        Колич,шт         Упаковок');
Writeln(Txt,Space+'________________________________________________________________________________________');
}
    End;
  Else;{12345  12  12345678901234567890123456 1234567890 12345 123456789}
  End;
  Writeln(Txt);
  End;{If Video}
  ItogoO:=0;
  ItogoR:=0;
  ItogoZ:=0;

   with Base do
     begin
      Assign(Path.ToTemp+'prise.dbf'); {пpисвоить БД имя}
      Init; {подготовиться к созданию БД}
      AddField('RAZDEL','C',100,0);{Имя раздела}
      AddField('TOVAR','C',150,0);{Наименование товара}
      AddField('КОD','C',CArtikul,0);{КодТовара}
      AddField('INPACK','N',CInPack,0);{фасовка}
      AddField('KOL','N',CKol,0); { кол-во}
      AddField('ZENA','N',CZena,CMantissa);  {Цена}
      AddField('ZENA1','N',CZena,CMantissa);  {Цена}
      AddField('ZENA2','N',CZena,CMantissa);  {Цена}
      AddField('ZENA3','N',CZena,CMantissa);  {Цена}
      AddField('ZENA4','N',CZena,CMantissa);  {Цена}
      AddField('ZENA5','N',CZena,CMantissa);  {Цена}
      AddField('ZENA6','N',CZena,CMantissa);  {Цена}
      AddField('MINKOL','N',CKol,0); {Мин кол-во в прайсе}
      AddField('MARKER','C',CInPack,0);
      AddField('DESIGN','C',2,0);
      if Create then Open(ReadWrite);
     end;

   if Base.IsOpen then
   begin
     c:=IOResult;
     Base.Close;
     c:=IOResult;
   end;


 R.Assign(0, 0, 0, 0);
 TempDBF := New(PBox, Init(R, 1, Nil));
 TempDBF^.NewList(New(PTextCollection, Init(0,1)));

 For L:=0 To TempList^.List^.Count-1 Do
 Begin
  If Regim=0 Then s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1,CRazdelKod)
  Else
  s:=Copy(TempList^.GetText(l,TempList^.List^.Count),1+CRazdel+1,CRazdelKod);

  If TestRazdel(s,M,Assort,TipID) Then
  Begin

     sdbf:=GetRazdel(s);

     If Video Then
     Begin
      Writeln(Txt,'                                 Раздел: '+GetRazdel(s));
      Writeln(Txt);
     End;{If Video}

      Assign(Ef,Path.ToSklad+s+'.db');
      Reset(Ef);
      New(E,Init);

      RazdelO:=0;
      RazdelR:=0;
      RazdelZ:=0;

   Case K Of
   0:Begin
     If VidNal=0 Then
     Begin
      R.Assign(0, 0, 0, 0);
      Temp := New(PBox, Init(R, 1, Nil));
      Temp^.NewList(New(PTextCollection, Init(0,1)));
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

      E^.Dat.Input.Kol[0]:=#0;
      For i:=1 To CDivision Do
        If (M[i]=1) And ((GetIDMArket(E^.Dat.BazKod)=TipID)Or(TipID=2)) Then

       Begin
        {Str((StrToInt(E^.Dat.Baz.Input.Kol)+StrToInt(E^.Dat.Baz.Input.DiviSion[i])):CKol,E^.Dat.Baz.Input.Kol);
       End;}
      DelSpace(E^.Dat.Input.Kol);

      MyStr(StrToReal(E^.Dat.Input.R_Zena),CZena,CMAntissa,E^.Dat.Input.R_Zena);
      MyStr(StrToReal(E^.Dat.Input.O_Zena),CZena,CMAntissa,E^.Dat.Input.O_Zena);
      MyStr(StrToReal(E^.Dat.Input.Zakupka),CZena,CMAntissa,E^.Dat.Input.Zakupka);

      If ((E^.Dat.Employ) And (StrToInt(E^.Dat.Input.DivisionS[i])>0)And(Assort=0))Or
       ((E^.Dat.Employ)And(Assort>0)And(((StrToInt(E^.Dat.Input.DivisionS[i])>0))Or(i<=1)))Then
{
      If (GetIdEmploy(E^.Dat.BazKod) And (StrToInt(E^.Dat.Input.Division[i])>0)And(Assort=0))Or
       (GetIdEmploy(E^.Dat.BazKod)And(Assort>0)And(((StrToInt(E^.Dat.Input.Division[i])>0))Or(i<=1)))Then}
       Begin

        If NPrint.FullName=0 Then Ws:=GetIdField(FName,E^.Dat.Bazkod)
        Else Ws:=GetIdField(FFName,E^.Dat.Bazkod);



        Format(ws,CName);
        RFormat(E^.Dat.Input.DiviSionS[i],CKol);

        UnPack:=GetIdField(FInPack,E^.Dat.Bazkod);
        DelSpace(UnPAck);
        RFormat(UnPack,CInPAck);


        {учет скидки наценки}
        {
        If KoefWord=0 Then
        Begin
         Str(StrToReal(E^.Dat.Input.O_Zena)/Koef:CZena:CMantissa,E^.Dat.Input.O_Zena);
         Str(StrToReal(E^.Dat.Input.R_Zena)/Koef:CZena:CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);
        End
        Else
        Begin
         Str(StrToReal(E^.Dat.Input.O_Zena)+Koef*StrToReal(E^.Dat.Input.O_Zena)/100:CZena:CMantissa,E^.Dat.Input.O_Zena);
         Str(StrToReal(E^.Dat.Input.R_Zena)+Koef*StrToReal(E^.Dat.Input.R_Zena)/100:CZena:CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);
        End;
        }

         MyStr(StrToReal(E^.Dat.Input.O_Zena),CZena,CMantissa,E^.Dat.Input.O_Zena);
         MyStr(StrToReal(E^.Dat.Input.R_Zena),CZena,CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);

        {учет валюты}
        If Valuta=0 Then
        Begin
        RFormat(E^.Dat.Input.O_Zena,CZena);
        RFormat(E^.Dat.Input.R_Zena,CZena);
        End
        Else
         Begin
          MyStr(StrToReal(E^.Dat.Input.O_Zena)/Usd,CZena,CMantissa,E^.Dat.Input.O_Zena);
          MyStr(StrToReal(E^.Dat.Input.R_Zena)/Usd,CZena,CMantissa,E^.Dat.Input.R_Zena);
          RFormat(E^.Dat.Input.O_Zena,CZena);
          RFormat(E^.Dat.Input.R_Zena,CZena);
         End;
        P:=CalcPackNoFile(GetIdField(FInPack,E^.Dat.Bazkod),E^.Dat.Input.DiviSionS[i]);
        DelSpace(P);
        RFormat(P,CPack);
        MyStr((StrToInt(E^.Dat.Input.DiviSionS[i])*StrToReal(E^.Dat.Input.R_Zena)),CInputIZena,CMantissa,Strz);
        MyStr((StrToInt(E^.Dat.Input.DiviSionS[i])*StrToReal(E^.Dat.Input.O_Zena)),CInputIZena,CMantissa,StOz);
        RazdelR:=RazdelR+StrToReal(StRz);
        RazdelO:=RazdelO+StrToReal(StOz);

        DelSpace(stOz);
        RFormat(stOz,CInputIZena-1);
        DelSpace(stRz);
        RFormat(stRz,CInputIZena-1);

        Str(i:1,S);
        If StrToInt(E^.Dat.Input.DivisionS[i])=0 Then S:=' ';

        If GetIdLocked(E^.Dat.BazKod) Then
        Ws:=Space+E^.Dat.BazKod+#249+s+Separator+ws+Separator+UnPack+Separator+E^.Dat.Input.DiviSionS[i]+Separator+
        E^.Dat.Input.O_Zena+Separator+{stOz+}+E^.Dat.Input.R_Zena+Separator+strz+Separator+P
        Else
        Ws:=Space+E^.Dat.BazKod+Separator+s+Separator+ws+Separator+UnPack+Separator+E^.Dat.Input.DiviSionS[i]+Separator+
        E^.Dat.Input.O_Zena+Separator+{stOz+}+E^.Dat.Input.R_Zena+Separator+strz+Separator+P;



        If Sort>0 Then
        Begin
         Otdel[0]:=#0;
         Otdel:=Copy(ws,Ord(Space[0])+1+CArtikul+1,1);
         P:=Copy(ws,Ord(Space[0])+1,CArtikul+1+1);
         Delete(ws,Ord(Space[0])+1,CArtikul+1+1);
         Insert(Otdel,ws,1+Ord(Space[0])+1+CName+1);
         ws:=ws+Separator+P;
        End;
        Temp^.List^.Insert(NewStr(ws));
        Temp^.SetRange(Temp^.List^.Count);
{        Writeln(txt,ws);}
       End;
      End;
      End;
      Close(Ef);



       If ((Temp^.List^.Count-1)>=0) Then
       For lk:=0 To Temp^.List^.Count-1 Do
        Begin
        ws:=Temp^.GetText(lk,Temp^.List^.Count);
        If Sort>0 Then
        Begin
{
         Delete(ws,Ord(Space[0])+1+CName+1+1,2);
         P:=Copy(ws,Ord(ws[0])-CArtikul-2-1,CArtikul+2+2);
         Delete(ws,Ord(ws[0])-CArtikul-2-2,CArtikul+2+2+1);
         Insert(P,ws,Ord(Space[0])+1);
}
         Delete(ws,Ord(Space[0])+1+CName+1+1,1);
         P:=Copy(ws,Ord(ws[0])-CArtikul-1,CArtikul+1+1);
         Delete(ws,Ord(ws[0])-CArtikul-1-1,CArtikul+1+1+1);
         Insert(P,ws,Ord(Space[0])+1);


        End;
        Art:= Copy(ws,Ord(Space[0])+1,CArtikul);
        If GetIdMarket(Art)=0 Then ws:=ws+' З';
        If Video Then
        Begin
         Writeln(txt,Ws);

          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,Art)
          Else Ws2:=GetIdField(FFName2,Art);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt,Space+'  '+Separator+'    '+Separator+ws2+Separator);
          End;


         If Sertif=1 Then
         Begin
          TempArtikul:=Copy(ws,Ord(Space[0])+1,CArtikul);
          TextSertif:=BakGetField(FSertif,TempArtikul,0);
          DelSpaceRight(TextSertif);
          If TextSertif[0]<>#0 Then
           Begin
            Format(TextSertif,CSertif-1);
            Writeln(Txt,Space+'           Сертификат:'+TextSertif);
           End;
         End;
         If Akzis=1 Then
         Begin
          TempArtikul:=Copy(ws,Ord(Space[0])+1,CArtikul);
          TextSertif:=BakGetField(FAkzis,TempArtikul,0);
          DelSpaceRight(TextSertif);
          If TextSertif[0]<>#0 Then
           Begin
            Format(TextSertif,CSertif-1);
            Writeln(Txt,Space+'           Примечание:'+TextSertif);
           End;
         End;
        End;
        End;
        Dispose(Temp,Done);
If Video Then
Begin
       Writeln(txt,'                                                  _________________________');
Writeln(Txt,Space+'                                            Всего: '
+{,RecognizReal(RazdelO,CIZena,CMantissa),}'        ',RecognizReal(RazdelR,CIZena,CMantissa));
      Writeln(txt);
End;
        ItogoO:=ItogoO+RazdelO;
        ItogoR:=ItogoR+RazdelR;
        ItogoZ:=ItogoZ+RazdelZ;
     End
     Else
      Begin
      R.Assign(0, 0, 0, 0);
      Temp := New(PBox, Init(R, 1, Nil));
      Temp^.NewList(New(PTextCollection, Init(0,1)));
      While Not(Eof(ef)) Do
      Begin
          ReadSkladPointer(ef,E);
          E^.Dat.Input.Kol[0]:=#0;
      For i:=1 To CDivision Do
        If (M[i]=1) And ((GetIDMArket(E^.Dat.BazKod)=TipID)Or(TipID=2)) Then

       Begin
      DelSpace(E^.Dat.Input.Kol);

      MyStr(StrToReal(E^.Dat.Input.R_Zena),CZena,CMAntissa,E^.Dat.Input.R_Zena);
      MyStr(StrToReal(E^.Dat.Input.O_Zena),CZena,CMAntissa,E^.Dat.Input.O_Zena);
      MyStr(StrToReal(E^.Dat.Input.Zakupka),CZena,CMAntissa,E^.Dat.Input.Zakupka);


      If ((E^.Dat.Employ) And (StrToInt(E^.Dat.Input.DivisionS[i])>0)And(Assort=0))Or
       ((E^.Dat.Employ)And(Assort>0)And(((StrToInt(E^.Dat.Input.DivisionS[i])>0))Or(i<=1)))Then
       Begin
        If NPrint.FullName=0 Then Ws:=GetIdField(FName,E^.Dat.Bazkod)
        Else Ws:=GetIdField(FFName,E^.Dat.Bazkod);
        Format(ws,CName);
        RFormat(E^.Dat.Input.DiviSionS[i],CKol);
        UnPack:=GetIdField(FInPack,E^.Dat.Bazkod);
        DelSpace(UnPAck);
        RFormat(UnPack,CInPAck);
{       RFormat(E^.Dat.Input.O_Zena,CZena);
        RFormat(E^.Dat.Input.R_Zena,CZena);}
        {учет скидки наценки}
        {
        If KoefWord=0 Then
        Begin
         Str(StrToReal(E^.Dat.Input.O_Zena)/Koef:CZena:CMantissa,E^.Dat.Input.O_Zena);
         Str(StrToReal(E^.Dat.Input.R_Zena)/Koef:CZena:CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);
        End
        Else
        Begin
         Str(StrToReal(E^.Dat.Input.O_Zena)+Koef*StrToReal(E^.Dat.Input.O_Zena)/100:CZena:CMantissa,E^.Dat.Input.O_Zena);
         Str(StrToReal(E^.Dat.Input.R_Zena)+Koef*StrToReal(E^.Dat.Input.R_Zena)/100:CZena:CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);
        End;
        }
         MyStr(StrToReal(E^.Dat.Input.O_Zena),CZena,CMantissa,E^.Dat.Input.O_Zena);
         MyStr(StrToReal(E^.Dat.Input.R_Zena),CZena,CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);

         SProz:='??.??';
         If StrToReal(E^.Dat.Input.Zakupka)>0.009 Then
          Begin
           MyStr((StrToReal(E^.Dat.Input.R_Zena)-StrToReal(E^.Dat.Input.Zakupka))
		     /StrToReal(E^.Dat.Input.Zakupka)*100,CLitr,CMAntissa,SProz);
          End;


        If Valuta=0 Then
        Begin
        RFormat(E^.Dat.Input.O_Zena,CZena);
        RFormat(E^.Dat.Input.R_Zena,CZena);
        RFormat(E^.Dat.Input.Zakupka,CZena);
        End
        Else
         Begin
          MyStr(StrToReal(E^.Dat.Input.O_Zena)/Usd,CZena,CMantissa,E^.Dat.Input.O_Zena);
          MyStr(StrToReal(E^.Dat.Input.R_Zena)/Usd,CZena,CMantissa,E^.Dat.Input.R_Zena);
          MyStr(StrToReal(E^.Dat.Input.Zakupka)/Usd,CZena,CMantissa,E^.Dat.Input.Zakupka);
          RFormat(E^.Dat.Input.O_Zena,CZena);
          RFormat(E^.Dat.Input.R_Zena,CZena);
          RFormat(E^.Dat.Input.Zakupka,CZena);
         End;

        MyStr(StrToInt(E^.Dat.Input.DiviSionS[i])*StrToReal(E^.Dat.Input.R_Zena),CInputIZena,CMantissa,Fas);

       {Fas:=GetIdField(FInPack,E^.Dat.Bazkod);
        RFormat(Fas,CInPack);}
{        P:=CalcPackNoFile(GetIdField(FInPack,E^.Dat.Bazkod),E^.Dat.Input.DiviSion[i]);
        DelSpace(P);
        RFormat(P,CPack);}
        MyStr((StrToInt(E^.Dat.Input.DiviSionS[i])*StrToReal(E^.Dat.Input.R_Zena)),CInputIZena,CMantissa,Strz);
        MyStr((StrToInt(E^.Dat.Input.DiviSionS[i])*StrToReal(E^.Dat.Input.O_Zena)),CInputIZena,CMantissa,StOz);
        MyStr((StrToInt(E^.Dat.Input.DiviSionS[i])*StrToReal(E^.Dat.Input.Zakupka)),CInputIZena,CMantissa,StZz);
        DelSpace(stOz);
        RFormat(stOz,CInputIZena);
        DelSpace(stRz);
        RFormat(stRz,CInputIZena);
        RazdelR:=RazdelR+StrToReal(StRz);
        RazdelO:=RazdelO+StrToReal(StOz);
        RazdelZ:=RazdelZ+StrToReal(Stzz);
        Str(i:1,S);

        RFormat(E^.Dat.Input.DiviSionS[i],CKol);

        If StrToInt(E^.Dat.Input.DivisionS[i])=0 Then S:=' ';

        If GetIdLocked(E^.Dat.BazKod) Then
        Ws:=Space+E^.Dat.BazKod+#249+s+Separator+ws+Separator+UnPack+Separator+
           +E^.Dat.Input.DiviSionS[i]+Separator+E^.Dat.Input.R_Zena+Separator+Fas+Separator+SProz+Separator
        Else
        ws:=Space+E^.Dat.BazKod+Separator+s+Separator+ws+Separator+UnPack+Separator+
           +E^.Dat.Input.DiviSionS[i]+Separator+E^.Dat.Input.R_Zena+Separator+Fas+Separator+SProz+Separator;

        MyStr(StrToInt(E^.Dat.Input.DiviSionS[i])*StrToReal(E^.Dat.Input.Zakupka),CInputIZena-1,CMantissa,Fas);

        ws:=ws+E^.Dat.Input.Zakupka+Separator+Fas;

        If Sort>0 Then
        Begin
         Otdel[0]:=#0;
         Otdel:=Copy(ws,Ord(Space[0])+1+CArtikul+1,1);
         P:=Copy(ws,Ord(Space[0])+1,CArtikul+1+1);
         Delete(ws,Ord(Space[0])+1,CArtikul+1+1);
         Insert(Otdel,ws,1+Ord(Space[0])+1+CName+1);
         ws:=ws+Separator+P;
        End;

        Temp^.List^.Insert(NewStr(ws));
        Temp^.SetRange(Temp^.List^.Count);
{        Writeln(txt,ws);}
       End;
      End;

      End;
      Close(Ef);
       If ((Temp^.List^.Count-1)>=0) Then
       For lk:=0 To Temp^.List^.Count-1 Do
        Begin
        ws:=Temp^.GetText(lk,Temp^.List^.Count);
        If Sort>0 Then
        Begin
         Delete(ws,Ord(Space[0])+1+CName+1+1,1);
         P:=Copy(ws,Ord(ws[0])-CArtikul-1,CArtikul+1+1);
         Delete(ws,Ord(ws[0])-CArtikul-1-1,CArtikul+1+1+1);
         Insert(P,ws,Ord(Space[0])+1);
        End;
        Art:= Copy(ws,Ord(Space[0])+1,CArtikul);
        If GetIdMarket(Art)=0 Then ws:=ws+' З';
{
        If Sort>0 Then
        Begin
         P:=Copy(ws,Ord(ws[0])-CArtikul-2-1,CArtikul+2+2);
         Delete(ws,Ord(ws[0])-CArtikul-2-2,CArtikul+2+2+1);
         Insert(P,ws,Ord(Space[0])+1);
        End;
}
         Writeln(txt,Ws);

          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,Art)
          Else Ws2:=GetIdField(FFName2,Art);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt,Space+'  '+Separator+'    '+Separator+ws2+Separator);
          End;


         If Sertif=1 Then
         Begin
          TempArtikul:=Copy(ws,Ord(Space[0])+1,CArtikul);
          TextSertif:=BakGetField(FSertif,TempArtikul,0);
          DelSpaceRight(TextSertif);
          If TextSertif[0]<>#0 Then
           Begin
            Format(TextSertif,CSertif-1);
            Writeln(Txt,Space+'           Сертификат:'+TextSertif);
           End;
         End;
         If Akzis=1 Then
         Begin
          TempArtikul:=Copy(ws,Ord(Space[0])+1,CArtikul);
          TextSertif:=BakGetField(FAkzis,TempArtikul,0);
          DelSpaceRight(TextSertif);
          If TextSertif[0]<>#0 Then
           Begin
            Format(TextSertif,CSertif-1);
            Writeln(Txt,Space+'           Примечание:'+TextSertif);
           End;
         End;

        End;
        Dispose(Temp,Done);



If Video Then
Begin
   Writeln(txt,'                                                   __________________________________________');
   Writeln(Txt,Space+'                                            Всего:',
   RecognizReal(RazdelR,CIZena+3,CMantissa),'       ',RecognizReal(RazdelZ,CIZena+3,CMantissa));
   Writeln(txt);
End;
        ItogoO:=ItogoO+RazdelO;
        ItogoR:=ItogoR+RazdelR;
        ItogoZ:=ItogoZ+RazdelZ;
      End;
     End;{наличие}
   2:Begin
      R.Assign(0, 0, 0, 0);
      Temp := New(PBox, Init(R, 1, Nil));
      Temp^.NewList(New(PTextCollection, Init(0,1)));
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

      E^.Dat.Input.Kol[0]:=#0;
      For i:=1 To CDivision Do
        If (M[i]=1) And ((GetIDMArket(E^.Dat.BazKod)=TipID)Or(TipID=2)) Then

{        If M[i]=1 Then}
       Begin
        {Str((StrToInt(E^.Dat.Baz.Input.Kol)+StrToInt(E^.Dat.Baz.Input.DiviSion[i])):CKol,E^.Dat.Baz.Input.Kol);
       End;}
       DelSpace(E^.Dat.Input.Kol);

      MyStr(StrToReal(E^.Dat.Input.R_Zena),CZena,CMAntissa,E^.Dat.Input.R_Zena);
      MyStr(StrToReal(E^.Dat.Input.O_Zena),CZena,CMAntissa,E^.Dat.Input.O_Zena);
      MyStr(StrToReal(E^.Dat.Input.Zakupka),CZena,CMAntissa,E^.Dat.Input.Zakupka);

       If ((E^.Dat.Employ) And (StrToInt(E^.Dat.Input.DivisionS[i])>0)And(Assort=0))Or
       ((E^.Dat.Employ)And(Assort>0)And(((StrToInt(E^.Dat.Input.DivisionS[i])>0))Or(i<=1)))Then

{      If (GetIdEmploy(E^.Dat.BazKod) And (StrToInt(E^.Dat.Input.Division[i])>0)And(Assort=0))Or
       (GetIdEmploy(E^.Dat.BazKod)And(Assort>0)And(((StrToInt(E^.Dat.Input.Division[i])>0))Or(i<=1)))Then}
       Begin

        If NPrint.FullName=0 Then Ws:=GetIdField(FName,E^.Dat.Bazkod)
        Else Ws:=GetIdField(FFName,E^.Dat.Bazkod);

        Format(ws,CName);
        RFormat(E^.Dat.Input.DiviSionS[i],CKol);
        P:=CalcPackNoFile(GetIdField(FInPack,E^.Dat.Bazkod),E^.Dat.Input.DiviSionS[i]);
        DelSpace(P);
        RFormat(P,CPack);
        Str(i:2,S);
        If StrToInt(E^.Dat.Input.DivisionS[i])=0 Then S:=' '+' ';



        MyStr(StrToReal(E^.Dat.Input.R_Zena),CZena,CMantissa,Ss);
        If GetIdLocked(E^.Dat.BazKod) Then
        Ws:=Space+E^.Dat.BazKod+Separator+#249+s+' '+Separator+ws+Separator+E^.Dat.Input.DiviSionS[i]+
        Separator+P+Separator+ss+'    ______________________'
        Else
        Ws:=Space+E^.Dat.BazKod+Separator+' '+s+' '+Separator+ws+Separator+E^.Dat.Input.DiviSionS[i]+
        Separator+P+Separator+ss+'    ______________________';
        If Sort>0 Then
        Begin
         Otdel[0]:=#0;
         Otdel:=Copy(ws,Ord(Space[0])+1+CArtikul+2,2);
         P:=Copy(ws,Ord(Space[0])+1,CArtikul+2+2);
         Delete(ws,Ord(Space[0])+1,CArtikul+2+2);
         Insert(Otdel,ws,1+Ord(Space[0])+1+CName+1);
         ws:=ws+Separator+P;
        End;

        Temp^.List^.Insert(NewStr(ws));
        Temp^.SetRange(Temp^.List^.Count);
       End;
      End;
      End;
      Close(Ef);
       If ((Temp^.List^.Count-1)>=0) Then
       For lk:=0 To Temp^.List^.Count-1 Do
        Begin
        ws:=Temp^.GetText(lk,Temp^.List^.Count);
        If Sort>0 Then
        Begin
         Delete(ws,Ord(Space[0])+1+CName+1+1,2);
         P:=Copy(ws,Ord(ws[0])-CArtikul-2-1,CArtikul+2+2);
         Delete(ws,Ord(ws[0])-CArtikul-2-2,CArtikul+2+2+1);
         Insert(P,ws,Ord(Space[0])+1);
        End;

        Art:= Copy(ws,Ord(Space[0])+1,CArtikul);
        If GetIdMarket(Art)=0 Then ws:=ws+' З';

         Writeln(txt,Ws);


          ws1:=Copy(ws,Ord(Space[0])+1,CArtikul);
          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,Art)
          Else Ws2:=GetIdField(FFName2,Art);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme);
           Writeln(txt,Space+'     '+Separator+'    '+Separator+ws2+Separator);
          End;



        End;
       Writeln(txt);
       Dispose(Temp,Done);
     End;{акт ревизии}

   1:Begin

      Base.Open(ReadWrite);

      R.Assign(0, 0, 0, 0);
      Temp := New(PBox, Init(R, 1, Nil));
      Temp^.NewList(New(PTextCollection, Init(0,1)));
      While Not(Eof(ef)) Do
      Begin

        ReadSkladPointer(ef,E);

	   E^.Dat.Input.Kol[0]:=#0;

        If E^.Dat.Employ then
        For i:=1 To CDivision Do
        If (M[i]=1) And ((GetIDMArket(E^.Dat.BazKod)=TipID)Or(TipID=2)) Then
        begin
          E^.Dat.Input.Kol:=IntToStr(StrToInt(E^.Dat.Input.Kol)+StrToInt(E^.Dat.Input.DivisionS[i]),CKol);
        end;

        if (E^.Dat.Employ)And(Assort>0) then E^.Dat.Input.Kol:='1000';

        if not((ZapretOpt>0) and GetIdZapretOpt(E^.Dat.BazKod)) then
        if StrToInt(E^.Dat.Input.Kol)>0 then
	   begin
         Base.Append;
         Base.WriteStr('RAZDEL',sdbf);
         Base.WriteStr('КОD',E^.Dat.BazKod);
         Base.WriteNum('KOL',StrToInt(E^.Dat.Input.Kol));
         Base.WriteStr('TOVAR',GetIdField(FName,E^.Dat.BazKod)+' '+
	      GetIdField(FName2,E^.Dat.BazKod));
         sFas:=BakGetField(FAkzis,E^.Dat.BazKod,0);
         {memcc(GetIdField(FMera,E^.Dat.BazKod));}
         if pos('бл',GetIdField(FMera,E^.Dat.BazKod))<=0 then
         begin
         Base.WriteNum('ZENA2',StrToReal(E^.Dat.Input.R_Zena)*StrToReal(sFas));
         Base.WriteNum('ZENA',StrToReal(E^.Dat.Input.R_Zena));
         end
         else
         begin
         if StrToInt(sFas)>0 then
         Base.WriteNum('ZENA',StrToReal(E^.Dat.Input.R_Zena)/StrToReal(sFas))
         else  Base.WriteNum('ZENA',0);
         Base.WriteNum('ZENA2',StrToReal(E^.Dat.Input.R_Zena));
         end;

         Base.WriteNum('ZENA1',StrToReal(GetIdField(FNDS,E^.Dat.BazKod)));

         Base.WriteNum('INPACK',StrToReal(GetIdField(FInPack,E^.Dat.BazKod)));
         Base.WriteNum('MINKOL',StrToInt(GetIdField(FMinimum,E^.Dat.BazKod)));
         Base.WriteStr('MARKER',GetIdField(FMarker,E^.Dat.BazKod));

         sDes:=GetRazdelDesignation(copy(E^.Dat.BazKod,1,2));
         Delspace(sDes);
         if sDes='' then sDes:='99';
         Base.WriteStr('DESIGN',sDes);
        end;
        GetSkidka(E^.Dat.BazKod,Sk^.Dat);
	   E^.Dat.Input.Kol[0]:=#0;

        If KoefWord=0 Then
        Begin
         MyStr(StrToReal(E^.Dat.Input.O_Zena)/Koef,CZena,CMantissa,E^.Dat.Input.O_Zena);
         MyStr(StrToReal(E^.Dat.Input.R_Zena)/Koef,CZena,CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);
        End
        Else
        Begin
         MyStr(StrToReal(E^.Dat.Input.O_Zena)+Koef*StrToReal(E^.Dat.Input.O_Zena)/100,CZena,CMantissa,E^.Dat.Input.O_Zena);
         MyStr(StrToReal(E^.Dat.Input.R_Zena)+Koef*StrToReal(E^.Dat.Input.R_Zena)/100,CZena,CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);
        End;

        For i:=1 To CDivision Do
        If (M[i]=1) And ((GetIDMArket(E^.Dat.BazKod)=TipID)Or(TipID=2)) Then
{
        If (StrToInt(GetIdField(FMinimum,E^.DAt.BazKod))<=StrToInt(E^.Dat.Input.Division[i]))
	      Or (Assort>0) Then
}
        Begin
        DelSpace(E^.Dat.Input.Kol);

      MyStr(StrToReal(E^.Dat.Input.R_Zena),CZena-1,CMAntissa,E^.Dat.Input.R_Zena);
      MyStr(StrToReal(E^.Dat.Input.O_Zena),CZena-1,CMAntissa,E^.Dat.Input.O_Zena);
      MyStr(StrToReal(E^.Dat.Input.Zakupka),CZena,CMAntissa,E^.Dat.Input.Zakupka);


      If ((E^.Dat.Employ) And (StrToInt(E^.Dat.Input.DivisionS[i])>0)And(Assort=0))Or
       ((E^.Dat.Employ)And(Assort>0)And(((StrToInt(E^.Dat.Input.DivisionS[i])>0))Or(i<=1)))Then

       Begin

        If NPrint.FullName=0 Then Ws:=GetIdField(FName,E^.Dat.Bazkod)
        Else Ws:=GetIdField(FFName,E^.Dat.Bazkod);


        Format(ws,CName-2);
        {учет скидки наценки}

         MyStr(StrToReal(E^.Dat.Input.O_Zena),CZena-1,CMantissa,E^.Dat.Input.O_Zena);
         MyStr(StrToReal(E^.Dat.Input.R_Zena),CZena-1,CMantissa,E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.R_Zena);
         DelSpace(E^.Dat.Input.O_Zena);

        If Valuta=0 Then
        Begin
        RFormat(E^.Dat.Input.O_Zena,CZena-1);
        RFormat(E^.Dat.Input.R_Zena,CZena-1);
        End
        Else
         Begin
          MyStr(StrToReal(E^.Dat.Input.O_Zena)/Usd,CZena-1,CMantissa,E^.Dat.Input.O_Zena);
          MyStr(StrToReal(E^.Dat.Input.R_Zena)/Usd,CZena-1,CMantissa,E^.Dat.Input.R_Zena);
          RFormat(E^.Dat.Input.O_Zena,CZena-1);
          RFormat(E^.Dat.Input.R_Zena,CZena-1);
         End;

        MyStr(StrToREal(E^.Dat.Input.O_Zena)*(1+StrToReal(GetIdField(FNAlog,E^.Dat.BazKod))/100),CZena-1,CMantissa,WithNP);


        If Region=5 Then
         Begin

          MyStr(StrToReal(WithNP)*GetShkalaProz1(E^.Dat.BazKod,ClientShkala),CZena,CMantissa,WithNP);
          E^.Dat.Input.O_Zena:=WithNP;

          If TestSpecZena(E^.Dat.BazKod,ClKod,E^.Dat.Input.Zakupka,SpezZena) Then
          Begin
           WithNP:=SpezZena;
           MyStr(StrToReal(WithNP),CZena-1,CMantissa,WithNP);
           E^.Dat.Input.O_Zena:=WithNP;
          End;

         End;

        Pack:=GetIdField(FInPack,E^.Dat.Bazkod);
        DelSpace(Pack);
        RFormat(Pack,CInPack);
        MyStr((StrToInt(Pack)*StrToReal(WithNP{E^.Dat.Input.O_Zena})),CInputIZena,CMantissa,StOz);
        DelSpace(stOz);
        RFormat(stOz,CInputIZena);
        Stzz:=BakGetField(FPost,E^.DAt.BAzKod,0);
        If Ord(Stzz[0])>(CPost-2) Then Stzz[0]:=Chr(CPost-2);
        Format(stzz,CPost-2);
        Str(i:2,s);
        If StrToInt(E^.Dat.Input.DivisionS[i])=0 Then S:=' '+' ';

        If GetIdLocked(E^.Dat.BazKod) Then
        Ws:=Space+E^.Dat.BazKod+Separator+#249+s+' '+Separator+ws+Separator+{Stzz+
        Separator}+Pack+Separator+E^.Dat.Input.O_Zena
        Else
        Ws:=Space+E^.Dat.BazKod+Separator+' '+s+' '+Separator+ws+Separator+{Stzz+
        Separator}+Pack+Separator+E^.Dat.Input.O_Zena;


       If Region in [0,1,2,3] Then
       Begin
        For sh:=1 To CShkala Do
         Begin
          If ZPrize[sh]=1 Then
           Begin
            MyStr(StrToReal(E^.Dat.Input.O_Zena)*
            (StrToReal(Sk^.Dat.Skidka[sh].Proz)),CZena-1,CMAntissa,strz);
            ws:=ws+Separator+Strz;
           End;
         End;
       End;

       If Region in [4] Then
        Begin
         For sh:=1 To 6 Do
          Begin
           If VVV[sh]=1 Then
            Begin
             MyStr(StrToReal(E^.Dat.Input.Zakupka)*
             (1+StrToReal(VVVS[sh])/100),CZena-1,CMAntissa,strz);
             ws:=ws+Separator+Strz;
            End;
          End;
        End;
{ WithNP+Separator+stoz{+Separator+Separator+P};

        If Sort>0 Then
        Begin
         Otdel[0]:=#0;
         Otdel:=Copy(ws,Ord(Space[0])+1+CArtikul+2,2);
         P:=Copy(ws,Ord(Space[0])+1,CArtikul+2+2);
         Delete(ws,Ord(Space[0])+1,CArtikul+2+2);
         Insert(Otdel,ws,1+Ord(Space[0])+1+CName+1);
         ws:=ws+Separator+P;
        End;

        Temp^.List^.Insert(NewStr(ws));
        Temp^.SetRange(Temp^.List^.Count);
       End;
       End;
      End;
      Close(Ef);
       If ((Temp^.List^.Count-1)>=0) Then
       For lk:=0 To Temp^.List^.Count-1 Do
        Begin
        ws:=Temp^.GetText(lk,Temp^.List^.Count);
        If Sort>0 Then
        Begin
         Delete(ws,Ord(Space[0])+1+CName+1+1,2);
         P:=Copy(ws,Ord(ws[0])-CArtikul-2-1,CArtikul+2+2);
         Delete(ws,Ord(ws[0])-CArtikul-2-2,CArtikul+2+2+1);
         Insert(P,ws,Ord(Space[0])+1);
        End;

        Art:= Copy(ws,Ord(Space[0])+1,CArtikul);
        If GetIdMarket(Art)=0 Then ws:=ws+' З';

        {MMM:=GetIdField(FMArker,Art);}
        MMM:=GetIdField(FMinimum,Art);
        If StrToInt(BakGetField(FKol,Art,0))<StrToInt(MMM) Then MMM:='@'
        Else MMM[0]:=#0;
        Format(MMM,CInPack);

        {Прайс в дбф}

     {   DosToWin(GetIdField(FName,Art)+' '+GetIdField(FName2,Art));

        BakGetField(FKol,Art,0);

        GetIdField(FInPack,Art); }




        If Ansi=1 Then
        Begin
         System.Insert(MMM+Separator,ws,Ord(Space[0])+1+CArtikul+1+4+1);
         Writeln(txt,Ws);


          ws1:=Copy(ws,Ord(Space[0])+1,CArtikul);
          If NPrint.FullName=0 Then Ws2:=GetIdField(FName2,Art)
          Else Ws2:=GetIdField(FFName2,Art);
          DelSpaceRight(ws2);

          If ws2[0]<>#0 Then
          Begin
           Format(ws2,CNAme-2);
           Writeln(txt,Space+'     '+Separator+'    '+Separator+'    '+ws2+Separator);
          End;
        End
          else
           begin
            ws1:=Copy(ws,Ord(Space[0])+1,CArtikul);
            System.Delete(ws,Ord(Space[0])+1+CArtikul+1+4{+1},CNAme);
            If NPrint.FullName=0 Then Ws2:=GetIdField(FFFName,Art)
            Else Ws2:=GetIdField(FFFName,Art);
            DelSpaceRight(ws2);
            ws2:=ws2+'$';
            System.Insert(ws2,ws,Ord(Space[0])+1+CArtikul+1+4{+1});
            System.Insert(MMM+Separator,ws,Ord(Space[0])+1+CArtikul+1+4{+1});
            Writeln(txt,Ws);
           end;

        End;
        Dispose(Temp,Done);
      Writeln(txt);
      Base.Close;
     End;{прайс}
   Else;
   End;{Case}
      Dispose(E,Done);
  End;
 End;

Case K Of
0:Begin
  If VidNal=0 Then
  Begin
   Writeln(txt,'                                                   ________________________');
   Writeln(Txt,Space+'                                             Всего: '+
   {,RecognizReal(ItogoO,CIZena+3,CMantissa),}'     ',RecognizReal(ItogoR,CIZena+3,CMantissa));
  End;
  If VidNal=1 Then
  Begin
   Writeln(txt,'                                                   __________________________________________');
   Writeln(Txt,Space+'                                            Всего:',
   RecognizReal(ItogoR,CIZena+3,CMantissa),'       ',RecognizReal(ItogoZ,CIZena+3,CMantissa));
  End;
  End;
1:Begin
  Dispose(sk,Done);
  End;
2:Begin
   Writeln(txt);
   Writeln(txt,Space+'                         Сдал Ф.И.О./_________________/  Подпись ___________');
   Writeln(txt);
   Writeln(txt,Space+'                         Сдал Ф.И.О./_________________/  Подпись ___________');
   Writeln(txt);
   Writeln(txt);
   Writeln(txt);
   Writeln(txt,Space+'                         Приняла комиссия в составе:');
   Writeln(txt);
   Writeln(Txt,Space+'                                 1. __________________   Подпись ___________');
   Writeln(txt);
   Writeln(Txt,Space+'                                 2. __________________   Подпись ___________');
   Writeln(txt);
   Writeln(Txt,Space+'                                 3. __________________   Подпись ___________');
   Writeln(txt);
   Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
   Writeln(txt,Space+'========================================================================================');
  End;
Else;
End;
 If (k=0) Then
    Begin
    If VidNal=1 Then
    Begin
     Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
     Writeln(txt,Space+'=============================================================================================')
    End
    Else
     Begin
      Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
      Writeln(txt,Space+'=====================================================================================');
     End;
    End
 Else
 If k<>2 Then
    Begin
     s[0]:=#0;
     For sh:=1 To MaxSh Do
     Begin
     s[sh]:='=';
     s[0]:=Chr(sh);
     End;
   Writeln(Txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
   Writeln(txt,Space+s{'=============================================================================================='});
    End;
 Close(txt);
 Dispose(TempList,Done);
 MyStr(ItogoR,CIZena,CMantissa,ws);
 PrintSklad_Or_Prise:=ws;
 If Video Then
 Begin
 NoInfo;
if K<>1 then  ViewAsText(Path.ToTemp+'report.txt',True);
{ If Not(TestOpenDate(FDate)) Then}
if K<>1 then Report(Path.ToTemp+'report.txt','',1,False,False,false)
else
Begin
 PrintMyPrice;
 end;

 End;
End;

{$ELSE}

Function PrintSklad_Or_Prise
(Video:Boolean;K:Byte;Const Spis:PBox;Const M:MaskaNew;Const Assort,Sort,Sertif,Akzis:Word):TEnjoyStr;
Begin
End;

{$ENDIF}


Procedure PrintRashodOrder(As : DocumentEdit);
Const Space=' ';
Var s,ws1,ws2 : TMyString;
    Summa : String[CIZena];
    Txt : Text;
    c : Word;
    E : PNewVozwratType;
    f : NewVozwratFileType;
    Find : Boolean;
Begin
{$IfDEF DPMI}
If MessageBox(^m+#3'Печатать расходный кассовый ордер?',Nil,mfConfirmation+mfOkCancel)=cmCancel Then Exit;
 Assign(F,Path.ToReturn+As.D+'.vzw');
 c:=IOResult;
 Reset(f);
 c:=Ioresult;
 If c <> 0 Then
  Begin
   MessageBox(#3^M+#3'Не найден файл '+Path.ToReturn+As.D+'.vzw',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
  End;

 Assign(Txt,Path.ToTemp+'order.txt');
 c:=IOResult;
 Rewrite(txt);
 c:=IOResult;

 If c <> 0 Then
  Begin
   Close(f);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'order.txt',Nil,mfError+mfCancelButton);
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
   MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
   {If Status=DocPrint Then Status:=DocNormal;}
   Exit;
 End;
 Close(f);

If Not(E^.Dat.Rashod) Then
Begin
 Close(txt);
 Dispose(E,Done);
 MessageBox(#3^M+#3'По документу возврата не производится выплата клиенту!',Nil,mfError+mfCancelButton);
 Exit;
End;

Writeln(txt,Space+'Предприятие:'+Rek.Name+' Склад:'+E^.Dat.SkladKod);
Writeln(txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+
'                      РАСХОДНЫЙ КАССОВЫЙ ОРДЕР N '+GetRKONumer+' от '+
E^.Dat.DateC+NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]);
Writeln(txt);
s:=GetClientField(FClient,E^.Dat.MakeKod,E^.Dat.OperatorSelector);
Format(s,CClient);
WriteLN(txt,Space+' Выдать: '+s+'        через: ______________________________________________');
WriteLN(txt,Space+' Основание: возврат товара по документу N '+E^.Dat.BasisDoc+' от '+E^.Dat.BasisDate);
If E^.Dat.Opt Then s:=E^.Dat.SummaO
Else s:=E^.Dat.SummaR;

MyStr(StrToReal(E^.Dat.RashodSumma){StrToReal(s)-StrToReal(E^.Dat.Skidka)},CIZena,CMantissa,S);

DelSpace(s);
summa:=s;
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);

ws1:=ws1+ws2;
Ws1[1]:=UpperCase(ws1[1]);
Writeln(txt,Space+' Сумма:   '+Italic[NPrint.Printer]+Double[NPrint.Printer]+ws1+NoDouble[NPrint.Printer]
+NoItalic[NPrint.Printer]);
If s[0]<>#0 Then
Begin
Format(s,41);
Writeln(txt,Space+Italic[NPrint.Printer]+Double[NPrint.Printer]+s+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer]);
End;
Writeln(txt,Space+'                    '+Double[NPrint.Printer]+Summa+' руб.'+NoDouble[NPrint.Printer]);
WriteLN(txt,Space+' Приложение: _____________________________________________________________________________');
WriteLN(txt);
WriteLN(txt,Space+'        Руководитель: ________ ___________   Главный бухгалтер: ________ ___________');
WriteLN(txt,Space+'                       Подпись   Расшифр.                        Подпись   Расшифр.');
WriteLN(txt);
WriteLN(txt,Space+'             "'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+
'  Подпись получателя: ___________________');
WriteLN(txt);

Writeln(txt,Space+' Получил: ________________________________________________________________________________');

WriteLN(txt,Space+' по документу: ___________________________________________________________________________');
WriteLN(txt);
WriteLN(txt,Space+'                            Выдал кассир: _________  ____________');
WriteLN(txt,Space+'                                           Подпись     Расшифр.');
WriteLN(txt,Space+'==========================================================================================');
Close(txt);
Dispose(E,Done);
Report(Path.ToTemp+'order.txt','',NPrint.CopyOrder,False,False,false);
{$EndIf}

End;


(*
Procedure PrintOrder(E:PSuperMarketType; NDS,Itogo:Real;Var Txt:Text);
Const Space=' ';
Var s,ws1,ws2 : TMyString;
    SDoc,SDate : TDateString;
Begin
{$IfDEF DPMI}
Writeln(txt,Space+'Предприятие:                                       ||');

If E^.DAt.DocSelector in [3,4,6,8] Then
s:=RekSF.Name
Else
s:=Rek.Name;
Format(s,CAll-15);

Writeln(txt,Space+s+' Склад:'+E^.Dat.SkladKod+'          || '+S);
Writeln(txt,Space+'                                                   ||');
DelZerro(E^.Dat.Document);
Format(E^.Dat.Document,CDocNumer);
Format(E^.Dat.DocReal,CDocNumer);
Writeln(txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'       ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР N '+E^.Dat.Document+
NoDouble[NPrint.Printer]+
NoBold[NPrint.Printer]+'             ||        '
+Bold[NPrint.Printer]+
+Double[NPrint.Printer]+' К В И Т А Н Ц И Я'+NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]);
Writeln(txt,Space+'              от '+E^.Dat.DateC+'                          || к приходному кассовому ордеру N '+
E^.Dat.Document);
s:=GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format (s,CClient);
Writeln(Txt,Space+'                                                   ||');
Writeln(txt,Space+'    Принято от '+s+'                ||  Принято от '+s);

If (E^.Dat.Realiz) Then
Begin
SDoc:=E^.Dat.DocReal;
SDate:=E^.Dat.DocDate;
DelZerro(SDoc);
End
Else
 Begin
  SDoc:=E^.Dat.Document;
  SDate:=E^.Dat.DateC;
  DelZerro(SDoc);
 End;

Writeln(txt,Space+'    Основание: по накладной N '+SDoc+'                 ||  Основание: по накладной N '+
SDoc);
Writeln(txt,Space+'                                                   ||');

s:=E^.Dat.SummaZ;
DelSpace(s);
ws1[0]:=#0;
ws2[0]:=#0;
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);
Format(ws1,41);
Ws1[1]:=UpperCase(ws1[1]);
Writeln(txt,Space+Italic[NPrint.Printer]+ws1+NoItalic[NPrint.Printer]+'          || '+Italic[NPrint.Printer]+ws1+
NoItalic[NPrint.Printer]);
If ws2[0]<>#0 Then
Begin
Format(ws2,41);
Writeln(txt,Space+Italic[NPrint.Printer]+ws2+NoItalic[NPrint.Printer]+'          || '+Italic[NPrint.Printer]+ws2+
NoItalic[NPrint.Printer]);
End;
If s[0]<>#0 Then
Begin
Format(s,41);
Writeln(txt,Space+Italic[NPrint.Printer]+s+NoItalic[NPrint.Printer]+'          || '+Italic[NPrint.Printer]+s+
NoItalic[NPrint.Printer]);
End;

Writeln(txt,Space+'         '+E^.Dat.SummaZ+' руб.                      ||      '+E^.Dat.SummaZ+' руб.');
Str(NDS:CIZena:CMantissa,s);
Writeln(txt,Space+'                                                   ||');
Writeln(txt,Space+'в том числе НДС:'+s+' руб.               || в том числе НДС:'+S+' руб.');
Writeln(Txt,Space+'                                                   ||');
Writeln(txt,Space+'Приложение: накладная N '+E^.Dat.Document+'                       ||              '+E^.Dat.DateC);
Writeln(txt,Space+'                                                   ||');
Writeln(Txt,Space+' Главный бухгалтер: _________    _________         || Главный бухгалтер: ________ _________');
Writeln(Txt,Space+'                     Подпись      Расшифр.         ||                     Подпись  Расшифр.');
Writeln(Txt,Space+' Получил кассир:    _________    _________         || Кассир:            ________ _________');
Writeln(txt,Space+'                     Подпись      Расшифр.         ||                     Подпись  Расшифр.');
Writeln(txt,Space+'============================================================================================');
{$EndIf}
End;
*)


(*
Procedure PrintOrderPlategC(SDoc,SClient,Summa:AllStr;All:Boolean;l:Word;Var Txt:Text;NDS:Real);
Const Space=' ';
Var s,ws1,ws2 : TMyString;
    Symbol:ArtikulStr;

Begin
{$IfDEF DPMI}
If (L in [5]) Then Symbol:='||'
Else Symbol:='**';

DelZerro(SDoc);

Format(SDoc,CDocNumer);
Str(StrToReal(Summa):CIZena:CMantissa,Summa);

Writeln(txt,Space+'Предприятие:                                       '+Symbol);

If L in [3,4,6,8] Then
s:=RekSF.Name
Else
s:=Rek.Name;

Format(s,CAll-15);

Writeln(txt,Space+s+' Склад:'+Rek.Kod+'          '+Symbol+' '+S);
Writeln(txt,Space+'                                                   '+Symbol);
If L in [5] Then
Begin
Writeln(txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'НК     ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР N Б/Н '+
NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]+'             '+Symbol+'        '
+Bold[NPrint.Printer]+Double[NPrint.Printer]+' К В И Т А Н Ц И Я'+NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]);
Writeln(txt,Space+'              от '+FDate+'                          '+Symbol+' к приходному кассовому ордеру N '+
'Б/Н')
End
Else
Begin
Writeln(txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'НК         КАССОВЫЙ ОРДЕР N Б/Н       '+
NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]+'             '+Symbol+'        '
+Bold[NPrint.Printer]+Double[NPrint.Printer]+' К В И Т А Н Ц И Я'+NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]);
Writeln(txt,Space+'              от '+FDate+'                          '+Symbol+' к кассовому ордеру N '+
'Б/Н');
End;
s:=GetClientField(FClient,SClient,0);
Format (s,CClient);
Writeln(Txt,Space+'                                                   '+Symbol);
Writeln(txt,Space+'    Принято от '+s+'                '+Symbol+'  Принято от '+s);

Writeln(txt,Space+'    Основание: по накладной N '+SDoc{E^.Dat.Document}+'                 '+
Symbol+'  Основание: по накладной N '+
SDoc);
Writeln(txt,Space+'                                                   '+Symbol);

s:=Summa;
DelSpace(s);
ws1[0]:=#0;
ws2[0]:=#0;
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);
{Ws1:='1111111111111111111111111111111111111111';}
Format(ws1,41);
Ws1[1]:=UpperCase(ws1[1]);
Writeln(txt,Space+Italic[NPrint.Printer]+ws1+NoItalic[NPrint.Printer]+'          '+Symbol+' '+Italic[NPrint.Printer]+ws1+
NoItalic[NPrint.Printer]);
If ws2[0]<>#0 Then
Begin
Format(ws2,41);
Writeln(txt,Space+Italic[NPrint.Printer]+ws2+NoItalic[NPrint.Printer]+'          '+Symbol+' '+
Italic[NPrint.Printer]+ws2+NoItalic[NPrint.Printer]);
End;
If s[0]<>#0 Then
Begin
Format(s,41);
Writeln(txt,Space+Italic[NPrint.Printer]+s+NoItalic[NPrint.Printer]+'          '+Symbol+' '+
Italic[NPrint.Printer]+s+NoItalic[NPrint.Printer]);
End;
Str(Nds:CIZena:CMantissa,s);
Writeln(txt,Space+'         '+Summa+' руб.                      '+Symbol+'      '+Summa+' руб.');
Writeln(txt,Space+'                                                   '+Symbol);
If All And (L in [5]) Then
Writeln(txt,Space+'в том числе НДС:'+s+' руб.               '+Symbol+' в том числе НДС:'+S+' руб.');
Writeln(Txt,Space+'                                                   '+Symbol);
Writeln(txt,Space+'Приложение: накладная N '+SDoc+'                       '+Symbol+'              '+FDate);
Writeln(txt,Space+'                                                   '+Symbol);
Writeln(Txt,Space+' Главный бухгалтер: _________    _________         '+Symbol+' Главный бухгалтер: ________ _________');
Writeln(Txt,Space+'                     Подпись      Расшифр.         '+Symbol+'                     Подпись  Расшифр.');
Writeln(Txt,Space+' Получил кассир:    _________    _________         '+Symbol+' Кассир:            ________ _________');
Writeln(txt,Space+'                     Подпись      Расшифр.         '+Symbol+'                     Подпись  Расшифр. ');
Writeln(txt,Space+'============================================================================================');
{$EndIf}
End;
*)



Procedure PrintOrder(E:PSuperMarketType; NDS,NP,Itogo:Real;Var Txt:Text);
Const Space=' ';
Var s,ws1,ws2 : TMyString;
    SNAlog,SDoc,SDate : TDateString;
    Res : Word;
Begin
{$IfDEF DPMI}

If E^.DAt.DocSelector in [3,4,6,8] Then
s:=RekSF.Name
Else
s:=Rek.Name;

s:='ЧП Еродский П.Е.';

Format(s,CAll-15);


Writeln(txt,Space+'Предприятие:                                       ||');
Writeln(txt,Space+s+' Склад:'+E^.Dat.SkladKod+'          || '+S);
Writeln(txt,Space+'                                                   ||');
DelZerro(E^.Dat.Document);
DelSpace(E^.Dat.NaklNumer);

Format(E^.Dat.PrhNumer,CDocNumer);
Format(E^.Dat.NaklNumer,CDocNumer);
Format(E^.Dat.DocReal,CDocNumer);


Writeln(txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'       ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР N '+E^.Dat.PrhNumer+
NoDouble[NPrint.Printer]+
NoBold[NPrint.Printer]+'             ||        '
+Bold[NPrint.Printer]+
+Double[NPrint.Printer]+' К В И Т А Н Ц И Я'+NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]);
Writeln(txt,Space+'              от '+E^.Dat.DateC+'                          || к приходному кассовому ордеру N '+
E^.Dat.PrhNumer);
s:=GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
Format (s,CClient);
Writeln(Txt,Space+'                                                   ||');
Writeln(txt,Space+'    Принято от '+s+'                ||  Принято от '+s);
If (E^.Dat.Realiz) Then
Begin
SDoc:=E^.Dat.DocReal;
SDate:=E^.Dat.DocDate;
DelZerro(SDoc);
{что писать в шапке документа - для наклдных консигнации-первичный документ}
End
Else
 Begin
  SDoc:=E^.Dat.Document;
  SDate:=E^.Dat.DateC;
  DelZerro(SDoc);
 End;
Writeln(txt,Space+'    Основание: по накладной N '+E^.Dat.NaklNumer{E^.Dat.Document}+
'                 ||  Основание: по накладной N '+E^.Dat.NaklNumer{E^.Dat.Document});
Writeln(txt,Space+'                                                   ||');

s:=E^.Dat.SummaZ;
DelSpace(s);
{s:='888888888.88';}
ws1[0]:=#0;
ws2[0]:=#0;
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);
{Ws1:='1111111111111111111111111111111111111111';}
Format(ws1,41);
Ws1[1]:=UpperCase(ws1[1]);
Writeln(txt,Space+Italic[NPrint.Printer]+ws1+NoItalic[NPrint.Printer]+'          || '+Italic[NPrint.Printer]+ws1+
NoItalic[NPrint.Printer]);
If ws2[0]<>#0 Then
Begin
Format(ws2,41);
Writeln(txt,Space+Italic[NPrint.Printer]+ws2+NoItalic[NPrint.Printer]+'          || '+Italic[NPrint.Printer]+ws2+
NoItalic[NPrint.Printer]);
End;
If s[0]<>#0 Then
Begin
Format(s,41);
Writeln(txt,Space+Italic[NPrint.Printer]+s+NoItalic[NPrint.Printer]+'          || '+Italic[NPrint.Printer]+s+
NoItalic[NPrint.Printer]);
End;

Writeln(txt,Space+'         '+E^.Dat.SummaZ+' руб.                      ||      '+E^.Dat.SummaZ+' руб.');
MyStr(NDS,CIZena,CMantissa,s);
MyStr(NP,6,CMantissa,SNAlog);
Writeln(txt,Space+'                                                   ||');
Writeln(txt,Space+'в том числе НДС:'+s+' руб.               || в том числе НДС:'+S+' руб.');

If E^.DAt.DocSelector in [2,3] Then
Writeln(txt,Space+'в том числе налог с продажи:'+SNAlog+' руб.            || в том числе налог с продажи:'+
SNAlog+' руб.');

Writeln(Txt,Space+'                                                   ||');
Writeln(txt,Space+'Приложение: накладная N '+E^.Dat.NaklNumer+'                       ||              '+E^.Dat.DateC);
Writeln(txt,Space+'                                                   ||');
Writeln(Txt,Space+' Главный бухгалтер: _________    _________         || Главный бухгалтер: ________ _________');
Writeln(Txt,Space+'                     Подпись      Расшифр.         ||                     Подпись  Расшифр.');
Writeln(Txt,Space+' Получил кассир:    _________    _________         || Кассир:            ________ _________');
Writeln(txt,Space+'                     Подпись      Расшифр.         ||                     Подпись  Расшифр.');
Writeln(txt,Space+'============================================================================================');
{$EndIf}
End;





Procedure PrintOrder2(Osn,Lizo,Doc,Date,Kod,Summa:AllStr);
Const Space=' ';
Var s,ws1,ws2 : TMyString;
    Status,Res : Word;
    Txt : Text;
Begin
{$IfDEF DPMI}

Assign(txt,Path.ToTemp+'prh.txt');
Res:=IoResult;
Rewrite(txt);
Res:=IoResult;
If Res<>0 Then
 Begin
  MessageBox(#3+'Ошибка создания '+Path.ToTemp+'prh.txt Код:'+
  IntToStr(Res,CKol),Nil,mfError+mfCancelButton);
  Exit;
 End;

s:='ООО "ПРОДЛАЙН"'{Rek.Name};
Format(s,CAll-15);

Status:=StrToInt(GetOperationField(FStatus,Kod));


If Status=1 Then
Begin

Writeln(txt,Space+'Предприятие:                                       ||');
Writeln(txt,Space+s+' Склад:'+Rek.Kod+'          || '+S);
Writeln(txt,Space+'                                                   ||');
DelZerro(Doc);

Doc:='___';
Format(Doc,CDocNumer);


Writeln(txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'       ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР N '+Doc+
NoDouble[NPrint.Printer]+
NoBold[NPrint.Printer]+'             ||        '
+Bold[NPrint.Printer]+
+Double[NPrint.Printer]+' К В И Т А Н Ц И Я'+NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]);
Writeln(txt,Space+'              от '+Date+'                          || к приходному кассовому ордеру N '+
Doc);
s:='____________________';
s:=Lizo;
Format (s,CClient);
Writeln(Txt,Space+'                                                   ||     от '+Date);
Writeln(txt,Space+'    Принято от '+s+'                ||  Принято от '+s);
s:=Osn;
Format (s,CClient);
Writeln(txt,Space+'    Основание  '+s+'                ||  Основание  '+s);
Writeln(txt,Space+'                                                   ||');

s:=Summa;
DelSpace(s);
ws1[0]:=#0;
ws2[0]:=#0;
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);
{Ws1:='1111111111111111111111111111111111111111';}
Format(ws1,41);
Ws1[1]:=UpperCase(ws1[1]);
Writeln(txt,Space+Italic[NPrint.Printer]+ws1+NoItalic[NPrint.Printer]+'          || '+Italic[NPrint.Printer]+ws1+
NoItalic[NPrint.Printer]);
If ws2[0]<>#0 Then
Begin
Format(ws2,41);
Writeln(txt,Space+Italic[NPrint.Printer]+ws2+NoItalic[NPrint.Printer]+'          || '+Italic[NPrint.Printer]+ws2+
NoItalic[NPrint.Printer]);
End;
If s[0]<>#0 Then
Begin
Format(s,41);
Writeln(txt,Space+Italic[NPrint.Printer]+s+NoItalic[NPrint.Printer]+'          || '+Italic[NPrint.Printer]+s+
NoItalic[NPrint.Printer]);
End;

Writeln(txt,Space+'         '+Summa+' руб.                      ||      '+Summa+' руб.');

Writeln(Txt,Space+'                                                   ||');
Writeln(txt,Space+'                                                   ||');
Writeln(Txt,Space+' Главный бухгалтер: _________    _________         || Главный бухгалтер: ________ _________');
Writeln(Txt,Space+'                     Подпись      Расшифр.         ||                     Подпись  Расшифр.');
Writeln(Txt,Space+' Получил кассир:    _________    _________         || Кассир:            ________ _________');
Writeln(txt,Space+'                     Подпись      Расшифр.         ||                     Подпись  Расшифр.');
Writeln(txt,Space+'============================================================================================');
End
  Else
    Begin

{MyStr(StrToReal(Summa)*(-1),CZena,CMAntissa,Summa);}
DelSpace(Summa);
Doc:='_____';
Writeln(txt,Space+'Предприятие: ООО "ПРОДЛАЙН"'+{Rek.Name}+'    Склад:'+Rek.Kod);
Writeln(txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+
'                      РАСХОДНЫЙ КАССОВЫЙ ОРДЕР N '+GetRKONumer+' от '+
Date+NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]);
Writeln(txt);
s:='____________________';
s:=Lizo;
Format(s,CClient);
WriteLN(txt,Space+' Выдать: '+s);
s:=osn;
Format(s,CClient);
WriteLN(txt,Space+' Основание: '+s);


s:=Summa;
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);

ws1:=ws1+ws2;
Ws1[1]:=UpperCase(ws1[1]);
Writeln(txt,Space+' Сумма:   '+Italic[NPrint.Printer]+Double[NPrint.Printer]+ws1+NoDouble[NPrint.Printer]
+NoItalic[NPrint.Printer]);
If s[0]<>#0 Then
Begin
Format(s,41);
Writeln(txt,Space+Italic[NPrint.Printer]+Double[NPrint.Printer]+s+NoDouble[NPrint.Printer]+NoItalic[NPrint.Printer]);
End;
Writeln(txt,Space+'                    '+Double[NPrint.Printer]+Summa+' руб.'+NoDouble[NPrint.Printer]);
WriteLN(txt,Space+' Приложение: _____________________________________________________________________________');
WriteLN(txt);
WriteLN(txt,Space+'        Руководитель: ________ ___________   Главный бухгалтер: ________ ___________');
WriteLN(txt,Space+'                       Подпись   Расшифр.                        Подпись   Расшифр.');
WriteLN(txt);
WriteLN(txt,Space+'             "'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+
'  Подпись получателя: ___________________');
WriteLN(txt);

Writeln(txt,Space+' Получил: ________________________________________________________________________________');

WriteLN(txt,Space+' по документу: ___________________________________________________________________________');
WriteLN(txt);
WriteLN(txt,Space+'                            Выдал кассир: _________  ____________');
WriteLN(txt,Space+'                                           Подпись     Расшифр.');
WriteLN(txt,Space+'==========================================================================================');
    End;



Res:=IoResult;
Close(txt);
Res:=IoResult;
Report(Path.ToTemp+'prh.txt','',1,False,False,false);

{$EndIf}
End;



Procedure PrintOrderPlategC(PrhNum,NaklNum,SDoc,SClient,Summa:AllStr;All:Boolean;l:Word;
                            Var Txt:Text;NDS,NAlog:Real);
Const Space=' ';
Var s,ws1,ws2 : TMyString;
    Symbol:ArtikulStr;
    Res : Word;
Begin
{$IfDEF DPMI}

{GetRek(Rek,Res,E^.Dat.Lizo);}

If (L in [5,6]) Then
 Begin
  Symbol:='||';
  SDoc:=NaklNum;
 End
Else
 Begin
  Symbol:='**';
  SDoc:='Б/Н ';
 End;

If L in [3,4,6,8] Then
s:=RekSF.Name
Else
s:=Rek.Name;

Format(s,CAll-15);


Format(PrhNum,CDocNumer);
Format(NaklNum,CDocNumer);

DelZerro(SDoc);

{PrhNum:='____';}



Format(SDoc,CDocNumer);
MyStr(StrToReal(Summa),CIZena,CMantissa,Summa);

Writeln(txt,Space+'Предприятие:                                       '+Symbol);

Format(s,CAll-15);
Writeln(txt,Space+s+' Склад:'+Rek.Kod+'          '+Symbol+' '+S);
Writeln(txt,Space+'                                                   '+Symbol);
If L in [6,8] Then
Begin
Writeln(txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'НК     ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР N '+PrhNum+
NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]+'             '+Symbol+'        '
+Bold[NPrint.Printer]+Double[NPrint.Printer]+' К В И Т А Н Ц И Я'+NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]);
Writeln(txt,Space+'              от '+FDate+'                          '+Symbol+' к приходному кассовому ордеру N '+
PrhNum)
End
Else
Begin
Writeln(txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'НК      ПРИХОДНЫЙ КАССОВЫЙ ОРДЕР N Б/Н   '+
NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]+'             '+Symbol+'        '
+Bold[NPrint.Printer]+Double[NPrint.Printer]+' К В И Т А Н Ц И Я'+NoDouble[NPrint.Printer]+NoBold[NPrint.Printer]);
Writeln(txt,Space+'              от '+FDate+'                          '+Symbol+' к кассовому ордеру N '+
'Б/Н');
End;
s:=GetClientField(FClient,SClient,0);
Format (s,CClient);
Writeln(Txt,Space+'                                                   '+Symbol);
Writeln(txt,Space+'    Принято от '+s+'                '+Symbol+'  Принято от '+s);
Writeln(txt,Space+'    Основание: по накладной N '+NaklNum+'                 '+
Symbol+'  Основание: по накладной N '+NaklNum);
Writeln(txt,Space+'                                                   '+Symbol);
s:=Summa;
DelSpace(s);
ws1[0]:=#0;
ws2[0]:=#0;
Propis(s,ws1);
s:=ws1+s;
SpecialFormat(s,ws1,ws2);
{Ws1:='1111111111111111111111111111111111111111';}
Format(ws1,41);
Ws1[1]:=UpperCase(ws1[1]);
Writeln(txt,Space+Italic[NPrint.Printer]+ws1+NoItalic[NPrint.Printer]+'          '+Symbol+' '+Italic[NPrint.Printer]+ws1+
NoItalic[NPrint.Printer]);
If ws2[0]<>#0 Then
Begin
Format(ws2,41);
Writeln(txt,Space+Italic[NPrint.Printer]+ws2+NoItalic[NPrint.Printer]+'          '+Symbol+' '+
Italic[NPrint.Printer]+ws2+NoItalic[NPrint.Printer]);
End;
If s[0]<>#0 Then
Begin
Format(s,41);
Writeln(txt,Space+Italic[NPrint.Printer]+s+NoItalic[NPrint.Printer]+'          '+Symbol+' '+
Italic[NPrint.Printer]+s+NoItalic[NPrint.Printer]);
End;
MyStr(Nds,CIZena,CMantissa,s);
Writeln(txt,Space+'         '+Summa+' руб.                      '+Symbol+'      '+Summa+' руб.');
Writeln(txt,Space+'                                                   '+Symbol);

If All {And (L in [5,6])} Then
Begin
If (L in [5,6,7,8]) Then Writeln(txt,Space+'в том числе НДС:'+s+' руб.               '+Symbol+' в том числе НДС:'+S+' руб.');
MySTr(NAlog,6,2,ws1);
If (L in [6]) Then Writeln(txt,Space+'в том числе налог с продажи:'+ws1+' руб.            '+Symbol+
' в том числе налог с продажи:'+ws1+' руб');
End;
Writeln(Txt,Space+'                                                   '+Symbol);
Writeln(txt,Space+'Приложение: накладная N '+NaklNum+'                       '+Symbol+'              '+FDate);
Writeln(txt,Space+'                                                   '+Symbol);
Writeln(Txt,Space+' Главный бухгалтер: _________    _________         '+Symbol+' Главный бухгалтер: ________ _________');
Writeln(Txt,Space+'                     Подпись      Расшифр.         '+Symbol+'                     Подпись  Расшифр.');
Writeln(Txt,Space+' Получил кассир:    _________    _________         '+Symbol+' Кассир:            ________ _________');
Writeln(txt,Space+'                     Подпись      Расшифр.         '+Symbol+'                     Подпись  Расшифр. ');
Writeln(txt,Space+'============================================================================================');
{$EndIf}
End;






Function TestMarketSF(Const s:ArtikulStr;Const Lg:PsuperMarketType;Var i:Byte):Boolean;
Var l : Byte;
Begin
TestMarketSF:=False;
i:=1;
 For l:=1 To Lg^.DAt.Amount Do
  Begin
   If Lg^.Dat.MArketElement[l].BazKod=S Then
    Begin
     TestMarketSF:=True;
     i:=L;
     Break;
    End;
  End;
End;




Procedure FormSF( Video : Boolean; E:PSuperMarketType;
                   Var Txt:Text; Var NDS,Itogo,ItogoSkidka,NDS20,NDS10,NDS_:Real);
Var l : Word;
    k,j : Byte;
    s,ws,ws1 : string;
    {ГТД и производитель}
    s2,s3,s4 : string;
    kkk:Text;
    st : String[CMantissa];
    ItogoLitr,PromItogoPos,ItogoPos,NDSPos : Real;
    Test : LongInt;
    SDoc,SDate,SummaNDS : String[CInputIZena];
    RealZena,ITOGONDS_NP,SummaZena: String[CInputIZena];
    Space : AllStr;
    ItogNalog,Koefficient,pp : String[CPack];
    Rek1 :Rekwiziti;
    Lg : PSuperMarketType;
    Barter : String[CMantissa];
    Art : ArtikulStr;
    NPNAlog : AllStr;
    Res : Word;

procedure WriteShapka;
Begin
   DelSpace(Rek1.LizensiaOptL_V);
   s:=copy(Rek1.Name,pos(',',Rek1.Name)+1,length(Rek1.Name)-pos(',',Rek1.Name))
   +' '+Rek1.LizensiaOptL_V+','+Rek1.AdressGruza;
   DelSpaceRight(s);
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'Продавец:'+Rek1.Name);
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'Адрес:'+Format(Rek1.Adress,CAll));
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'ИНН/КПП продавца:'+Format(Rek1.INN,CAll));
   Writeln(Txt,Condensed[NPrint.Printer]+Space
   +'Грузоотправитель и его адрес:'+s);
   s:=GetClientField(FEnvir,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Format(s,CAll);
   DelSpaceRight(s);
   ws:=GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   {Format(ws,CAll);}
   DelSpaceRight(ws);
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'Грузополучатель и его адрес:'+ws+' '+s);
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'К платежно-расчетному документу N _____'+' от '+'_________');
   s:=GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'Покупатель:'+s);
   s:=GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'Адрес:'+Format(s,CAll));
   s:=GetClientField(FInn,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'ИНН/КПП покупателя:'+Format(s,CAll));
End;

Begin
   s:=E^.Dat.Document;
   s:=Bold[NPrint.Printer]+S+NoBold[NPrint.Printer];
   Space:='     ';
   Rek1:=RekSF;
(*
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                         '+
   Nocondensed[NPrint.Printer]+
   '                 Приложение N 1');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                         '+
   Nocondensed[NPrint.Printer]+
   'к правилу ведения журналов учета полученных и');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                         '+
   Nocondensed[NPrint.Printer]+
   'выставленных счетов-фактур,книг покупок и книг');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                         '+
   Nocondensed[NPrint.Printer]+
   'продаж при расчетах по налогу на добавленную  ');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                         '+
   Nocondensed[NPrint.Printer]+
   'стоимость');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                     '+
   Nocondensed[NPrint.Printer]+
   '(в ред.Постановлений Правительства РФ от 15.03.2001');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                     '+
   Nocondensed[NPrint.Printer]+
   'N18,27.07.2002 N575, от 16.02.2004 N84)');
   Writeln(Txt);
*)

   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                         '+
   Nocondensed[NPrint.Printer]+
   '                 Приложение N 1');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                         '+
   Nocondensed[NPrint.Printer]+
   'к правилу ведения журналов учета полученных и');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                         '+
   Nocondensed[NPrint.Printer]+
   'выставленных счетов-фактур,книг покупок и книг');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                         '+
   Nocondensed[NPrint.Printer]+
   'продаж при расчетах по налогу на добавленную  ');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                     '+
   Nocondensed[NPrint.Printer]+
   'стоимость, утвержденных Постановлением Правительства РФ');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                     '+
   Nocondensed[NPrint.Printer]+
   '            от 02.12.2000 N 914');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                                     '+
   Nocondensed[NPrint.Printer]+
   '(в ред.Постановлений Правительства РФ от 15.03.2001');
   Writeln(Txt,Condensed[NPrint.Printer]+Space+'                                                             '+
   Nocondensed[NPrint.Printer]+
   'N189,27.07.2002 N575, от 16.02.2004 N84, от 11.05.2006 N 283)');
   Writeln(Txt);


{  Writeln(Txt,Space+'                                               Приложение N 1');
   Writeln(Txt,Space+'                                   к порядку ведения журналов счетов-фактур');
   Writeln(Txt,Space+'                                при расчетах по налогу на добавленную стоимость');
   Writeln(txt,Space+'-----------------------------------------------------------------------------------------------');}


DelZerro(E^.Dat.Document);
Barter[0]:=#0;
If E^.Dat.Realiz Then
Begin
{ws:=E^.Dat.DocDate;}
ws:=E^.Dat.DAteC;

If E^.Dat.DocSelector in [5,6,7,8] Then
Writeln(Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'СТАТУС: Документ подлежит оплате'+Nobold[NPrint.Printer]+
Nodouble[NPrint.Printer])
Else
Writeln(Txt,Space+Bold[NPrint.Printer]+Double[NPrint.Printer]+'СТАТУС: Документ оплачен'+Nobold[NPrint.Printer]+
Nodouble[NPrint.Printer]);

(*
ws:=ClearChar(ws);
Writeln(Txt,Space+'                                                                          '+
Bold[NPrint.Printer]+Double[NPrint.Printer]+'НК'+ws+E^.Dat.Document{E^.Dat.DocReal}+NOBold[NPrint.Printer]+
NoDouble[NPrint.Printer]);
*)

{   Writeln(txt,Space+Bold+Double+'Тип документа: (',LeadingZero(E^.Dat.DocSelector),')'+NOBold+NoDouble);}

If E^.Dat.OperatorSelector<2 Then Barter[0]:=#0
Else Barter:='-Б';

DelSpace(E^.DAt.Document);

If E^.Dat.DocSelector in [6,8] Then
   Writeln(Txt,Space+High[NPrint.Printer]+Double[NPrint.Printer]+'        СЧЕТ-ФАКТУРА N '+{E^.Dat.Document+Barter}
   +E^.Dat.SfNumer+Barter+
   ' от '
   +E^.Dat.DAteC+
   NoHigh[NPrint.Printer]+
   NoDouble[NPrint.Printer]+'(1)')
Else
   Writeln(Txt,Space+High[NPrint.Printer]+Double[NPrint.Printer]+'        СЧЕТ-ФАКТУРА N '+{E^.Dat.Document+Barter}
   +E^.Dat.SfNumer+Barter+
   ' от '
   +E^.Dat.DocDAte+
   NoHigh[NPrint.Printer]+
   NoDouble[NPrint.Printer]+'(1)');
End
Else
 Begin
{   Writeln(txt,Space+Bold+Double+'Тип документа: (',LeadingZero(E^.Dat.DocSelector),')'+NOBold+NoDouble);}
   If E^.Dat.OperatorSelector<2 Then Barter[0]:=#0
   Else Barter:='-Б';

   Writeln(Txt,Space+High[NPrint.Printer]+Double[NPrint.Printer]+'        СЧЕТ-ФАКТУРА N '+{E^.Dat.Document+Barter}
   +E^.Dat.SfNumer+Barter+
   ' от '
   +E^.Dat.DAteC+
   NoHigh[NPrint.Printer]+
   NoDouble[NPrint.Printer]+'(1)');
 End;

   Space:=' ';
   ItogoSkidka:=0;  Itogo:=0; NDS:=0; NDSPos:=0; ItogoPos:=0;PromitogoPos:=0;
   ItogoLitr:=0; NDS20:=0; NDS10:=0; NDS_:=0;
   Koefficient[0]:=#0;
   For l:=1 To E^.Dat.Amount Do
   Itogo:=Itogo+StrToReal(E^.Dat.MarketElement[l].Input.Zena)*StrToInt(E^.Dat.MarketElement[l].Input.Kol);

{
   Writeln(txt,Space+'---------------------------------------------------------------------------------------------');
   Writeln(txt,Space+'Наименование товара        Ед Колич     Цена         Сумма  НДС     Сумма НДС     Итого сумма');
   Writeln(txt,Space+'                                                             %                     с НДС и НП');
   Writeln(txt,Space+'---------------------------------------------------------------------------------------------');
}


(*
   Writeln(txt,Condensed[NPrint.Printer]+
               Space+'___________________________________________________________________________'+
			'____________________________________________________________________________');
   Writeln(txt,Space+'N Наименование товара        КОД  Ед.Колич.   '+
   ' Цена      Сумма  НДС Сумма НДС Итого сумма    Сумма      Страна      N Грузовой таможенной декларации  ');
   Writeln(txt,Space+'                             ОКДП        '+
   '                        %             с НДС          НСП    происхождения');
   Writeln(txt,Space+'____________________________________________________________________________________________________'+
   '___________________________________________________');

   New(Lg,Init);
   k:=1;j:=1;

   For l:=1 To E^.Dat.Amount Do
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
    End;
    Lg^.DAt.Amount:=k-1;


   For l:=1 To Lg^.Dat.Amount Do
    Begin

   s2[0]:=#0;
   s3:=BakGetField(FPost,Lg^.Dat.MarketElement[l].BazKod,0);

   DelSpaceRight(s2);
   DelSpaceRight(s3);
   Format(s2,CNSertif);
   Format(s3,CPost);

     ItogoLitr:=ItogoLitr+StrToReal(GetIdField(FLitr,Lg^.Dat.MarketElement[l].BazKod))*
     StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
     Str(l:CMantissa,St);
     s:=Lg^.Dat.MarketElement[l].BazKod;

     If NPrint.FullName=0 Then
     Begin
      ws:=GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod);
      ws1[0]:=#0;
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
	   Begin
	    Writeln(txt,Space+'   '+ws+' '+'    ');
         ws:=ws1;
        End;
     End
     Else
	 Begin
	  ws:=GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod);
       ws1[0]:=#0;
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
	   Begin
	    Writeln(txt,Space+'   '+ws+' '+'    ');
         ws:=ws1;
        End;
      End;

     Format(ws,CName);
     s:=ws+' '+'    ';
     s4:=IntToStr(l,CMantissa);
     RFormat(s4,CMantissa);
     s:=s4+' '+s;
     ws:=Lg^.Dat.MarketElement[l].Input.Kol;
     DelSpace(Ws);
     RFormat(ws,CKol);
     s:=s+' '+GetIdField(FMera,Lg^.Dat.MarketElement[l].BazKod)+' '+ws;
              {ед}

     If E^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
       Str((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)*
       (StrToReal(Lg^.Dat.MarketElement[l].Input.Proz)))
       :CZena:CMantissa,ws){новая цена}
     Else
       Str((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[l].Input.Skidka))
            :CZena:CMantissa,ws);{новая цена}


       NPNalog[0]:=#0;
       If E^.DAt.DocSelector in [{1,}2,3,5,6] Then
       Begin
       str(((1+strtoreal(Lg^.dat.marketelement[l].Input.SpecNalog)
              /100)):CLitr:CMantissa,koefficient);
       {новая цена}
       Str((StrToReal(ws)*StrToReal(Koefficient)-StrToReal(ws)):CZena:CMantissa,NPNalog);
       Str(StrToReal(NPNalog)*StrToInt(Lg^.dat.marketelement[l].Input.Kol):(CInputIZena-4):CMantissa,NPNAlog);
       Str(StrToReal(ws)*StrToReal(Koefficient):CZena:CMantissa,RealZena);
       End
       Else
	   Begin
	    RealZena:=ws;
         Str(StrToReal(NPNalog):(CInputIZena-4):CMantissa,NPNalog);
        End;




{Вычли скидку из цены}
       ItogoPos:=StrToReal({RealZena}ws)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);

{расчитали сумму Итого в позиции со скидкой}
       NdsPos:=ItogoPos*
       StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)/(100+StrToReal(Lg^.Dat.MarketElement[l].Input.NDS));

       If Not(E^.Dat.DocSelector in [3,4,6,8]) Then NDSPos:=0;



       Test:=StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
       If Test <> 0 Then
       Begin
       Str(((ItogoPos-NDSPos)/StrToInt(Lg^.Dat.MarketElement[l].Input.Kol)):CZena:CMantissa,ws);
       Str(StrToReal(ws):CZena:CMantissa,ws);
       End
       Else Ws:='        ';

       If Not(E^.Dat.DocSelector in [3,4,6,8]) Then ws:='  ----  ';
       s:=s+' '+ws;

       Str(NDSPos:(CIZena-4):CMantissa,Ws);
       NdsPos:=StrToReal(Ws);


       If Not(E^.Dat.DocSelector in [3,4,6,8]) Then  NDSPos:=0;



       Str((ItogoPos-NDSPos):(CInputIZena-4):CMantissa,ws);
{получили Сумму цены со скидкой и без НДС в позиции}


       s:=s+' '+ws;

       PromitogoPos:=PromitogoPos+StrToReal(ws);

       ws:=Lg^.Dat.MarketElement[l].Input.NDS;

       Str(StrToReal(ws):CLitr-1:0{CMantissa-1},ws);
       If Not(E^.Dat.DocSelector in [3,4,6,8]) Then  ws:='  -- ';
       s:=s+' '+Format(Ws,CLitr-1);

       If E^.Dat.DocSelector in [3,4,6,8] Then
       Str(NDsPos:(CInputIZena-4):CMantissa,ws)
       Else  ws:='   ---   ';
{расчитали размер НДС в позиции}
       s:=s+' '+ws;

{расчитали ставку НП в позиции}
       If Not (E^.DAt.DocSelector in [1,2,3,5,6]) Then ws:='0.00'
       Else
       ws:=Lg^.Dat.MarketElement[l].Input.SpecNalog;

       ItogoPos:=StrToReal(RealZena)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);

       Str(ItogoPos:(CInputIZena-4):CMantissa,ws);
       s:=s+'   '+ws;

       Nds:=Nds+NDSPos;

{разборка  НДС по классификации}
       Case Lg^.Dat.MarketElement[l].Input.VidNDs Of
       0:Nds20:=Nds20+NdsPos;
       1:Nds10:=Nds10+NdsPos;
       2:Nds_:=Nds_+NdsPos;
       Else;
       End;


{сумма НДС по с/ф}

   s3:=BakGetField(FPost,Lg^.Dat.MarketElement[l].BazKod,0);
   s2:=BakGetField(FAkzis,Lg^.Dat.MarketElement[l].BazKod,0);;
   DelSpaceRight(s2);
   DelSpaceRight(s3);
   Format(s2,CAkzis1);
   Format(s3,CPost);

     Writeln(txt,Space+s+' '+NPNalog+' '+s3+' '+s2);

    End;
    DelSpace(E^.Dat.SummaZ);
    RFormat(E^.Dat.SummaZ,CIZena-4);
    DelSpace(E^.Dat.ENalog);
    Str(StrToReal(E^.Dat.ENalog):CZena-1:CMantissa,ItogNalog);
   Writeln(txt,Condensed[NPrint.Printer]+Space+'___________________________________________________________________________'+
   '____________________________________________________________________________'+
   noCondensed[NPrint.Printer]);

    Str(StrToReal(E^.Dat.SummaZ):CIZena-6:CMantissa,E^.Dat.SummaZ);
    Writeln(Txt,Space+'Всего позиций:',Lg^.Dat.Amount:2);
    If E^.Dat.DocSelector In [3,4,6,8] Then
    Writeln(Txt,Space+'Всего к оплате:                                     ',
    PromItogoPos:(CIZena-4):CMantissa,'                  ',NDs:(CinputIZena-6):CMantissa,'        ',E^.Dat.SummaZ)
    Else
    Writeln(Txt,Space+'Всего к оплате:                                     ',
    PromItogoPos:(CIZena-4):CMantissa,'              ','     ',E^.Dat.SummaZ);
   Writeln(txt,Condensed[NPrint.Printer]+Space+'___________________________________________________________________________'+
   '____________________________________________________________________________'+
   noCondensed[NPrint.Printer]);

    s:=E^.Dat.SummaZ;
    DelSpace(s);
    Propis(s,ws);
    ws[1]:=UpperCase(ws[1]);
    Writeln(txt,Space+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+ws+NoItalic[NPrint.Printer]+
    NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
    If s[0]<>#0 Then
    Writeln(txt,Space+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+s+NoItalic[NPrint.Printer]+
    NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
    If Not (E^.Dat.DocSelector in [3,4,6,8]) Then
    Begin
    Writeln(txt,Space+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+
    'Без НДС'+NoItalic[NPrint.Printer]+
    NoBold[NPrint.Printer]+NoDouble[NPrint.Printer])
    End
    Else
    Writeln(txt,Space+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+
    'В том числе НДС: ',NDs:CinputIZena-3:CMantissa,NoItalic[NPrint.Printer]+
    NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);

    Writeln(txt,Space+Condensed[NPrint.Printer]+'___________________________________________________________________________'+
   '____________________________________________________________________________'+NoCondensed[NPrint.Printer]);
   Writeln(Txt);
*)
   WriteShapka;

{ убрал за ненадобностью для увеличения места на листе 23.10.98
   s:=GetClientField(FRSh,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'Расчетный счет:'+Format(Rek1.R_Sh,CAll)+'               Расчетный счет:'+Format(s,CAll));

   s:=GetClientField(FGde,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'в:'+Format(Rek1.Gde,CAll)+'                            в:'+Format(s,CAll));

   s:=GetClientField(FGorod,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'Город:'+Format(Rek1.Gde,CAll)+'                        Город:'+Format(s,CAll));
}
{
   s:=GetClientField(FInn,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'ИНН/КПП:'+Format(Rek1.INN,CAll)+'                      ИНН/КПП:'+Format(s,CAll));
}
{ убрал за ненадобностью для увеличения места на листе 23.10.98
   s:=GetClientField(FOkonh,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'ОКОНХ:'+Format(Rek1.Okonh,CAll)+'                        ОКОНХ:'+Format(s,CAll));

   s:=GetClientField(FOkpo,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'ОКПО:'+Format(Rek1.Okpo,CAll)+'                         ОКПО:'+Format(s,CAll));
}
(*
   s:=GetClientField(FEnvir,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   '                          Дополнительно (N лиценз.):'+Format(s,CAll));
   s:=GetClientField(FAdress,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   ws:=GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector);
   Writeln(Txt,Space+
   'Грузополучатель и его адрес:'+ws+' '+s);

   Writeln(Txt,Space+'К платежно-расчетному документу N _____________'{+E^.Dat.NaklNumer+' от '+E^.Dat.DAteC});
   Writeln(Txt,NoCondensed[NPrint.Printer]);
*)

   Writeln(txt,Condensed[NPrint.Printer]+MinInterval2[NPrint.Printer]+
             Space+'┌─┬──────────────────────────┬─────┬─────┬────────┬───────────┬─────┬──────┬─────────'+
		   '┬───────────┬───────────────┬─────────────────────────────────┐');
 Writeln(txt,Space+'│N│Наименование товара(описан│     │     │  Цена  │Стоимость  │     │      │         '+
 '│Стоимость  │               │              Номер              │');
 Writeln(txt,Space+'│ │ие выполн.работ,услуг),   │Един.│Колич│(тариф) │товаров,иму│В т.ч│Налог.│Сумма    '+
 '│товаров,иму│    Страна     │            таможенной           │');
 Writeln(txt,Space+'│ │имущественных прав        │измер│ество│за един.│ществ.прав │акциз│ставка│налога   '+
 '│ществен.пра│ происхождения │            декларации           │');
 Writeln(txt,Space+'│ │                          │     │     │        │без налога │     │      │         '+
 '│в с налогом│               │                                 │');
 Writeln(txt,Space+'├─┼──────────────────────────┼─────┼─────┼────────┼───────────┼─────┼──────┼─────────'+
 '┼───────────┼───────────────┼─────────────────────────────────┤');
 Writeln(txt,Space+'│ │           1              │  2  │  3  │   4    │     5     │  6  │   7  │    8    '+
 '│     9     │      10       │               11                │');
 Writeln(txt,Space+'└─┴──────────────────────────┴─────┴─────┴────────┴───────────┴─────┴──────┴─────────'+
 '┴───────────┴───────────────┴─────────────────────────────────┘'+
 Normal[NPrint.Printer]+
   Condensed[NPrint.Printer]);


(*
   Writeln(txt,Condensed[NPrint.Printer]+MinInterval2[NPrint.Printer]+
             Space+'┌─┬──────────────────────────┬─────┬─────┬────────┬───────────┬─────┬──────┬─────────'+
		   '┬───────────┬───────────────┬─────────────────────────────────┐');
 Writeln(txt,Space+'│N│Наименование товара(описан│Един.│Колич│  Цена  │Стоимость  │В т.ч│Налог.│Сумма    '+
 '│Стоимость с│    Страна     │N Грузовой таможенной декларации │');
 Writeln(txt,Space+'│ │ие выполн.работ,услуг)    │измер│ество│за един.│без налога │акциз│ставка│налога   '+
 '│налогом    │ происхождения │                                 │');
 Writeln(txt,Space+'├─┼──────────────────────────┼─────┼─────┼────────┼───────────┼─────┼──────┼─────────'+
 '┼───────────┼───────────────┼─────────────────────────────────┤');
 Writeln(txt,Space+'│ │           1              │  2  │  3  │   4    │     5     │  6  │   7  │    8    '+
 '│     9     │      10       │               11                │');
 Writeln(txt,Space+'└─┴──────────────────────────┴─────┴─────┴────────┴───────────┴─────┴──────┴─────────'+
 '┴───────────┴───────────────┴─────────────────────────────────┘'+
 Normal[NPrint.Printer]+
   Condensed[NPrint.Printer]);
*)


 {
   '┌─┬──────────────────────────┬───┬───┬─────┬────────┬───────────┬─────┬───'+
			'┬─────────┬───────────┬───────────────┬─────────────────────────────────┐');
   Writeln(txt,Space+'│N│Наименование товара       │КОД│ Ед│Колич│  Цена  │   Сумма   │В т.ч│НДС'+
   '│Сумма НДС│Итого сумма│    Страна     │N Грузовой таможенной декларации │');
   Writeln(txt,Space+'│ │                          │ОКДП из│     │        │           │акциз│ % '+
   '│         │ с НДС     │ происхождения │                                 │');
   Writeln(txt,Space+'└─┴──────────────────────────┴───┴───┴─────┴────────┴───────────┴─────┴───'+
   '┴─────────┴───────────┴───────────────┴─────────────────────────────────┘'+

   Normal[NPrint.Printer]+
   Condensed[NPrint.Printer]);
}
                    { 12│12345678901234567890123456│12│12345│12345678│123│
1234567890123│1234567890123}
{ убрана 12.04
   Writeln(txt,Space+'----------------------------------------------------------------------------------------------');
   Writeln(txt,Space+'Наименование товара        Ед Колич     Цена         Сумма  НДС     Сумма НДС  НП Итого сумма');
   Writeln(txt,Space+'                                                             %                  % с НДС и НП');
   Writeln(txt,Space+'----------------------------------------------------------------------------------------------');
}
                     {12345678901234567890123456│12│12345│12345678│1234567890123│1234│1234567890123│1234│123456789012345}
                                                                     {1234567890123 1234 1234567890123 1234567890123}
   New(Lg,Init);
   k:=1;j:=1;

   For l:=1 To E^.Dat.Amount Do
    Begin

     If testMarketSF(E^.Dat.MarketElement[l].BazKod,Lg,j) Then
      Begin
       Str((StrToInt(Lg^.Dat.MarketElement[j].Input.Kol)+
            StrToInt( E^.Dat.MarketElement[l].Input.Kol)):CKol,Lg^.Dat.MarketElement[j].Input.Kol);
{
       Lg^.Dat.MarketElement[j].Input.Zena:=E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[j].Input.SpecNalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
       Lg^.Dat.MarketElement[j].Input.NDS:=E^.Dat.MarketElement[l].Input.NDS;
}
      End
      Else
      Begin
       Lg^.Dat.MarketElement[k]:=E^.Dat.MarketElement[l];
{      Lg^.Dat.MarketElement[k].Input.Zena:=E^.Dat.MarketElement[l].Input.Zena;
       Lg^.Dat.MarketElement[k].Input.SpecNalog:=E^.Dat.MarketElement[l].Input.SpecNalog;
       Lg^.Dat.MarketElement[k].Input.NDS:=E^.Dat.MarketElement[l].Input.NDS;}
       Inc(k);
       Lg^.DAt.Amount:=k-1;
      End;
    End;
    Lg^.DAt.Amount:=k-1;


   For l:=1 To Lg^.Dat.Amount Do
    Begin

   s2:=BakGetField(FAkzis,Lg^.Dat.MarketElement[l].BazKod,0);
   s3:=BakGetField(FPost,Lg^.Dat.MarketElement[l].BazKod,0);

   DelSpaceRight(s2);
   DelSpaceRight(s3);
   Format(s2,CNSertif);
   Format(s3,CPost);

     ItogoLitr:=ItogoLitr+StrToReal(GetIdField(FLitr,Lg^.Dat.MarketElement[l].BazKod))*
     StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
     Str(l:CMantissa,St);

     {s:=Lg^.Dat.MarketElement[l].BazKod;}

(*
     If NPrint.FullName=0 Then
     Begin
      ws:=GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod);
      ws1[0]:=#0;
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
           Begin
            Writeln(txt,Space+'   '+ws+' '+'    ');
         ws:=ws1;
        End;
     End
     Else
         Begin
          ws:=GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod);
       ws1[0]:=#0;
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
           Begin
            Writeln(txt,Space+'   '+ws+' '+'    ');
         ws:=ws1;
        End;
      End;
*)
     s:=Lg^.Dat.MarketElement[l].BazKod;

     ws:=GetIdField(FFFName,Lg^.Dat.MarketElement[l].BazKod);
     DelSpaceRight(ws);

     s4:=IntToStr(l,CMantissa);
     RFormat(s4,CMantissa);

     If Ord(ws[0])>CNAme Then
     Begin
     If NPrint.FullName=0 Then
     Begin
      ws:=GetIdField(FName,Lg^.Dat.MarketElement[l].BazKod);
      ws1:=GetIdField(FName2,Lg^.Dat.MarketElement[l].BazKod);
      DelSpaceRight(ws1);
      If ws1[0]<>#0 Then
          Begin
           Writeln(txt,Condensed[NPrint.Printer]+Space+s4+' '+ws);
           ws:=ws1;
           s:='     ';
           s4:='  ';
       End;
     End
     Else
         Begin
          ws:=GetIdField(FFName,Lg^.Dat.MarketElement[l].BazKod);
       ws1:=GetIdField(FFName2,Lg^.Dat.MarketElement[l].BazKod);
       DelSpaceRight(ws1);
       If ws1[0]<>#0 Then
          Begin
           Writeln(txt,Condensed[NPrint.Printer]+Space+s4+' '+ws);
        ws:=ws1;
        s:='     ';
        s4:='  ';
       End;
      End;
      End;


     Format(ws,CName);
     s:=ws+' ';
     s:=s4+''+s;
     ws:=Lg^.Dat.MarketElement[l].Input.Kol;
     DelSpace(Ws);
     RFormat(ws,CKol);
     s:=s+GetIdField(FMera,Lg^.Dat.MarketElement[l].BazKod)+' '+ws+'   ';
              {ед}

     If E^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
       MyStr((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)*
       (StrToReal(Lg^.Dat.MarketElement[l].Input.Proz)))
       ,CZena,CMantissa,ws){новая цена}
     Else
       MyStr((StrToReal(Lg^.Dat.MarketElement[l].Input.Zena)-StrToReal(Lg^.Dat.MarketElement[l].Input.Skidka))
            ,CZena,CMantissa,ws);{новая цена}


       NPNalog[0]:=#0;

       If E^.DAt.DocSelector in [{1,}2,3,5,6] Then
       Begin
       Mystr(((1+strtoreal(Lg^.dat.marketelement[l].Input.SpecNalog)
              /100)),CLitr,CMantissa,koefficient);
       {новая цена}
       MyStr((StrToReal(ws)*StrToReal(Koefficient)-StrToReal(ws)),CZena,CMantissa,NPNalog);
       MyStr(StrToReal(NPNalog)*StrToInt(Lg^.dat.marketelement[l].Input.Kol),(CInputIZena-4),CMantissa,NPNAlog);
       MyStr(StrToReal(ws)*StrToReal(Koefficient),CZena,CMantissa,RealZena);
       End
       Else
           Begin
            RealZena:=ws;
            MyStr(StrToReal(NPNalog),(CInputIZena-4),CMantissa,NPNalog);
        End;




{Вычли скидку из цены}
       ItogoPos:=StrToReal({RealZena}ws)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);

{расчитали сумму Итого в позиции со скидкой}
       NdsPos:=ItogoPos*
       StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)/(100+StrToReal(Lg^.Dat.MarketElement[l].Input.NDS));


{NdsPos:=StrToReal(BakGetField
(FNds,Lg^.Dat.MarketElement[l].BazKod,0))/(100+StrToReal(BakGetField(FNDs,Lg^.Dat.MarketElement[l].BazKod,0)));}


       Test:=StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);
       If Test <> 0 Then
       Begin
       MyStr(((ItogoPos-NDSPos)/StrToInt(Lg^.Dat.MarketElement[l].Input.Kol)),CZena,CMantissa,ws);
       MyStr(StrToReal(ws),CZena,CMantissa,ws);
       End
       Else Ws:='        ';{без НДС}
       s:=s+' '+ws;

       MyStr(NDSPos,(CIZena-4),CMantissa,Ws);
       NdsPos:=StrToReal(Ws);


       MyStr((ItogoPos-NDSPos),(CIZena-4),CMantissa,ws);
{получили Сумму цены со скидкой и без НДС в позиции}


       s:=s+' '+ws+'  --- ';

       PromitogoPos:=PromitogoPos+StrToReal(ws);
{
       ws:=BakGetField(FNds,Lg^.Dat.MarketElement[l].BazKod,0);
}

       ws:=Lg^.Dat.MarketElement[l].Input.NDS;

       MyStr(StrToReal(ws),CLitr,0{CMantissa-1},ws);
       s:=s+' '+Format(Ws,CLitr)+'%';

       MyStr(NDsPos,(CInputIZena-4),CMantissa,ws);
{расчитали размер НДС в позиции}
       s:=s+' '+ws;

{расчитали ставку НП в позиции}
       If Not (E^.DAt.DocSelector in [1,2,3,5,6]) Then ws:='0.00'
       Else
       ws:=Lg^.Dat.MarketElement[l].Input.SpecNalog;

       ItogoPos:=StrToReal(RealZena)*StrToInt(Lg^.Dat.MarketElement[l].Input.Kol);

       MyStr(ItogoPos,(CInputIZena-4),CMantissa,ws);
       s:=s+'   '+ws;

       Nds:=Nds+NDSPos;

{разборка  НДС по классификации}

       Case Lg^.Dat.MarketElement[l].Input.VidNDs Of
       0:Nds20:=Nds20+NdsPos;
       1:Nds10:=Nds10+NdsPos;
       2:Nds_:=Nds_+NdsPos;
       Else;
       End;


(*
       If (StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)<20.01) And
          (StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)>19.99) Then
             Begin
              Nds20:=Nds20+NdsPos;
             End
       Else
          Begin
           If (StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)<10.01) And
              (StrToReal(Lg^.Dat.MarketElement[l].Input.NDs)>9.99) Then
              Begin
                Nds10:=Nds10+NdsPos;
              End
           Else
              Begin
                Nds_:=Nds_+NdsPos;
              End
          End;
*)



{сумма НДС по с/ф}

   s2:=BakGetField(FAkzis,Lg^.Dat.MarketElement[l].BazKod,0);
   s3:=BakGetField(FPost,Lg^.Dat.MarketElement[l].BazKod,0);

   DelSpaceRight(s2);
   DelSpaceRight(s3);
   Format(s2,CNSertif-4);
   Format(s3,CPost);

     Writeln(txt,Space+Pitch[NPrint.Printer]+
	Condensed[NPrint.Printer]+Space+s{+' '+NPNalog}+' '+s3+' '+s2+NoPitch[NPrint.Printer]+
	+Condensed[NPrint.Printer]);
{
 If PrintGTD[2]=1 Then
  Begin
   s2:=BakGetField(FNGTD,Lg^.Dat.MarketElement[l].BazKod,0);
   s3:=BakGetField(FPost,Lg^.Dat.MarketElement[l].BazKod,0);
   DelSpaceRight(s2);
   DelSpaceRight(s3);
   If (s2[0]<>#0)Or(s3[0]<>#0) Then
    Begin
     Format(s2,CNSertif);
     WriteLn(txt,Space+'N ГТД/ТТН: '+s2+
                    ' Производство:'+s3);
    End;
  End;
}
    End;
    DelSpace(E^.Dat.SummaZ);
    RFormat(E^.Dat.SummaZ,CIZena-4);
    DelSpace(E^.Dat.ENalog);
    MyStr(StrToReal(E^.Dat.ENalog),CZena-1,CMantissa,ItogNalog);
   Writeln(txt,Condensed[NPrint.Printer]+Space+'___________________________________________________________________________'+
   '__________________________________________________________________________');

    MyStr(StrToReal(E^.Dat.SummaZ),CIZena-6,CMantissa,E^.Dat.SummaZ);
    Writeln(Txt,Space+'Всего позиций:',Lg^.Dat.Amount:2,'                   Всего к оплате: ',
    '                         ',NDs:(CinputIZena-3):CMantissa,'    ',E^.Dat.SummaZ+
    NoCondensed[NPrint.Printer]);
    {
    Writeln(Txt,Space+'Всего ',ItogoLitr:CILitr:CLitrMantissa,' литров алкогольной продукции');}
   Writeln(txt,Condensed[NPrint.Printer]+Space+'___________________________________________________________________________'+
   '__________________________________________________________________________'+
   noCondensed[NPrint.Printer]);

    If E^.Dat.DocSelector in [3,4,6,8] Then
    Begin
    s:=E^.Dat.SummaZ;
    DelSpace(s);
    Propis(s,ws);
    ws[1]:=UpperCase(ws[1]);
    Writeln(txt,Space+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+ws+NoItalic[NPrint.Printer]+
    NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
    If s[0]<>#0 Then
    Writeln(txt,Space+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+s+NoItalic[NPrint.Printer]+
    NoBold[NPrint.Printer]+NoDouble[NPrint.Printer]);
    Writeln(txt,Space+Italic[NPrint.Printer]+Bold[NPrint.Printer]+Double[NPrint.Printer]+
    'В том числе НДС: ',NDs:CinputIZena-3:CMantissa,NoItalic[NPrint.Printer]+
    NoBold[NPrint.Printer]+NoDouble[NPrint.Printer])
    End;

    Writeln(txt,Space+Condensed[NPrint.Printer]+'___________________________________________________________________________'+
   '____________________________________________________________________________________'+NoCondensed[NPrint.Printer]);
   Writeln(Txt);
   Writeln(Txt,Space+'   Руководитель предприятия _______  Еродский Павел Евгеньевич  '+
   ' Главный бухгалтер _______  Еродский Павел Евгеньевич');
   Writeln(Txt,Space+'                            подпись         '+
   +'  ф.и.о                                подпись            ф.и.о  ');
   Writeln(Txt);
   Writeln(Txt,Space+'Индивидуальный предприниматель ______   Еродский Павел Евгеньевич');
   Writeln(Txt,Space+'                               подпись             ф.и.о   ');
   Writeln(Txt);
   Writeln(Txt,Space+'Реквизиты свидетельства о государственной');
   Writeln(Txt,Space+'регистрации :'
    {+'серия 71 N 001207049 выдано ИМНС по Центральному р-ну г.Тулы 14.12.2004г.'}
    +Rek.Svidetelstvo);

   Writeln(Txt);
   Writeln(Txt,Space+'   Примечание: Первый экземпляр-покупателю, второй-продавцу');


(*
   Writeln(Txt,Space+'   Руководитель предприятия _______  ___________   Главный бухгалтер _______  ___________');
   Writeln(Txt,Space+'                            подпись  Расшифровка                     подпись  Расшифровка  ');
   Writeln(Txt);
  {
   Writeln(Txt);
   Writeln(Txt,Space+'   Сдал _______    ____________  ');
   Writeln(Txt,Space+'        подпись    Расшифровка   ');
   Writeln(txt,Space+'                                 ');
   }

   Writeln(Txt,Space+'   Примечание: Первый экземпляр-покупателю, второй-продавцу');
*)
if StrToInt(Rek.kod)<>1 then
begin
Writeln(txt);
Writeln(txt);
Writeln(txt);
Writeln(txt);
Writeln(txt);
Writeln(txt);
Writeln(txt);
Writeln(txt);
end;
   Writeln(txt,Space+'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+
   ')'+Italic[NPrint.Printer]+Bold[NPrint.Printer]+
   Double[NPrint.Printer]+'                                                   Тип документа: (',
                     LeadingZero(E^.Dat.DocSelector),')'+NoItalic[NPrint.Printer]+NOBold[NPrint.Printer]+
				 NoDouble[NPrint.Printer]);

    Writeln(txt,Space+Condensed[NPrint.Printer]+'========================================================================='+
    '============================'+
    '====================================================='+NoCondensed[NPrint.Printer]);
   Dispose(Lg,Done);
End;








Function ViewAllRP (Date: TDateString; Regim:Boolean):TMyString;
Const Sp='                     ';
Var f : MarketFileType;
    E : PSuperMarketType;
    l : Word;
    As : DocumentEdit;
    NDS,z,AllSkidka,AllItogo,ItogoSkidka,Itogo,
    NDS20,NDS10,NDS_ : Real;
    s : TMyString;
    ws : String[CName];
    pp : String[CPack];
    Proz : String[CLitr];
    txt : Text;
    txt1 : Text;
    sh,Vid : Byte;
    Space: TDateString;
    Wiwod : Boolean;
    Doc : LongInt;
Begin
 Space[0]:=#0;
 ViewAllRP:='           0.00            0.00   0';
             { 123456789012345 123456789012345 123}
 Assign(F,Path.ToMarket+Date+'.mrk');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
  If Regim Then
   MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt1,Path.ToTemp+'temp.txt');

 Assign(Txt,Path.ToTemp+'rp.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   MessageBox(#3^M+#3'Не могу создать файл отчета '+Path.ToTemp+'rp.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
 AllItogo:=0;
 AllSkidka:=0;
 Doc:=0;
If Regim Then  DInfo('Минуточку...');
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

If (E^.Dat.ClientKod=ClientRP{'0000'}) And Not(E^.Dat.Realiz) And (E^.Dat.OperatorSelector=1) Then
Begin
 If (E^.Dat.Active) Then
 Begin
   Begin
 Writeln(Txt,'Склад: ',GetClientField(FClient,E^.Dat.SkladKod,1){E^.Dat.Sklad}+'  Оператор: '+E^.Dat.Caption);
 If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
 Writeln(txt,{'Последние изменения:'+}' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
 ItogoSkidka:=0;   Itogo:=0; NDS:=0;
 Inc(Doc);

 Rewrite(Txt1);
 As.D:=Date;
 As.EditPosition:=E^.Dat.Document;
 FormSf(False, E, Txt1, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_);
 Close(Txt1);

 Writeln(txt,'Тип документа:(',E^.Dat.DocSelector,')');

Case E^.Dat.DocSelector Of
0:begin
   If E^.Dat.OperatorSelector=0 Then
   Writeln(Txt,'                      С П И С О К   N '+E^.Dat.Document+ ' от ',E^.Dat.DAteC+' ('+E^.Dat.TimeC+')')
   Else
   Writeln(Txt,'        Н А К Л А Д Н А Я (межскладская перевозка) N '+E^.Dat.Document+ ' от ',E^.Dat.DAteC+' ('+
   E^.Dat.TimeC+')');
   If E^.Dat.OperatorSelector=1 Then
   Writeln(Txt,Space+'Получатель: ',GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+E^.Dat.ClientKod+')')
   Else
   Writeln(Txt,Space+'Получатель: ',{GetClient(E^.Dat.ClientKod)+}' ('+E^.Dat.ClientKod+')');
   As.EditPosition:=E^.Dat.Document;
   As.D:=E^.Dat.DAteC;
   FormNakl(Space,True,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,False);
   AllItogo:=AllItogo+Itogo;
   AllSkidka:=AllSkidka+ItogoSkidka;
  end;{список}
Else;
End;
End;
End;
End;
End;
Close(f);
Writeln(txt);
Writeln(Txt,'Всего за день скидка Р/П: ',RecognizReal(AllSkidka,CIZena,CMantissa),' руб.');
Writeln(Txt,'Всего за день  сумма Р/П: ',RecognizReal(AllItogo,CIZena,CMantissa),' руб.');
Str(Doc:CLitrMAntissa,ws);
Writeln(Txt,'Всего за день документов: ',Ws);

Close(txt);
Dispose(E,Done);
If Regim Then NoInfo;
ERase(Txt1);
If Regim Then ViewAsText(Path.ToTemp+'rp.txt',False);
MyStr(AllItogo,CIZena,CMantissa,ws);
s:=ws;
MyStr(AllSkidka,CIZena,CMantissa,ws);
s:=s+' '+ws;
Str(Doc:CLitrMAntissa,ws);
s:=s+' '+ws;
ViewAllRP:=s;
{ViewAllNakl:=RecognizReal(AllItogo,CIZena,CMantissa)+';'+RecognizReal(AllSkidka,CIZena,CMantissa)+'│'+s;}
End;








Function ViewAllNakl (Date: TDateString; Regim:Boolean;Debit:Boolean;Default:Byte):TMyString;
Const Sp='                     ';
Var f : MarketFileType;
    E : PSuperMarketType;
    l : Word;
    As : DocumentEdit;
    NDS,z,AllSkidka,AllItogo,ItogoSkidka,Itogo,AllNalog,
    NDS20,NDS10,NDS_ : Real;
    s : TMyString;
    ws : String[CName];
    pp : String[CPack];
    Proz : String[CLitr];
    txt : Text;
    txt1 : Text;
    sh,Vid : Byte;
    Space: TDateString;
    Wiwod : Boolean;
    Doc : LongInt;
    fr : File Of RealizasiaType;
    Barter : String[CMAntissa];
    Er : PRealizasiaType;
    Find : Boolean;

Begin
 Space[0]:=#0;
 ViewAllNakl:='           0.00            0.00   0';
             { 123456789012345 123456789012345 123}
 Assign(F,Path.ToMarket+Date+'.mrk');
 l:=IOResult;
 Reset(f);
 l:=Ioresult;
 If L <> 0 Then
  Begin
  If Regim Then
   MessageBox(#3^M+#3'Не найден файл '+Path.ToMarket+Date+'.mrk',Nil,mfError+mfCancelButton);
   Exit;
  End;
 Assign(Txt1,Path.ToTemp+'temp.txt');

 Assign(Txt,Path.ToTemp+'nakladn.txt');
 l:=IOResult;
 Rewrite(Txt);
 l:=IOResult;
 If L <> 0 Then
  Begin
   Close(f);
   MessageBox(#3^M+#3'Не могу создать файл отчета'+Path.ToTemp+'nakladn.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;
  Vid:=Default;
  If Regim Then
  Begin
  Vid:=SelectSpecify(Debit,8);
  If Vid=4 Then
   Begin
    CLose(f);
    Close(txt);
    Exit;
   End;
  End;
 AllItogo:=0;
 AllSkidka:=0;
 AllNalog:=0;
 Doc:=0;
If Regim Then  AInfo('Минуточку...');
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
If  (
      (
       (E^.Dat.OperatorSelector=Vid) Or (Vid=3)
      )
       And (Not Debit) And (Not E^.Dat.Realiz) And Not((E^.Dat.ClientKod=ClientRP{'0000'})And(E^.Dat.OperatorSelector=1))
       )

     Or (
         (Debit)And(E^.Dat.Realiz)And Not((E^.Dat.ClientKod={'0000'}ClientRP)And(E^.Dat.OperatorSelector=1)) And
           (
            (Vid=2)or
                    (
                     (Vid=1)And(E^.Dat.DocSelector in [5,6,7,8])
                    ) Or
                        (
                         (Vid in [0,2])And not(E^.Dat.DocSelector in[5,6,7,8])
                        )
           )
        )
                                                    Then
Begin


 If (E^.Dat.Active) Then
 Begin
{  If Not(Rp) Or (Rp and (E^.Dat.OperatorSelector=0) And (E^.Dat.ClientKod='0998')) Then}
   Begin
 Writeln(Txt,'Маршрут: ');
 Writeln(Txt,'Склад: ',GetClientField(FClient,E^.Dat.SkladKod,1){E^.Dat.Sklad}+'  Оператор: '+E^.Dat.Caption+
 +'  Агент: '+E^.Dat.AgentKod);
 If Not(E^.Dat.DAteM=E^.Dat.DAteC) Or Not(E^.Dat.TimeM=E^.Dat.TimeC) Then
 Writeln(txt,{'Последние изменения:'+}' '+E^.Dat.DAteM+'('+E^.Dat.TimeM+')');
 ItogoSkidka:=0;   Itogo:=0; NDS:=0;
 Inc(Doc);

 Rewrite(Txt1);
 As.D:=Date;
 As.EditPosition:=E^.Dat.Document;
 FormSf(False, E, Txt1, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_);
 Close(Txt1);

{
 If E^.Dat.DocSelector=5 Then
   If TestSf(E^.Dat.ClientKod,E^.Dat.Document,E^.Dat.DateC) Then Inc(E^.Dat.DocSelector);
}
 Writeln(txt,'Тип документа:(',LeadingZero(E^.Dat.DocSelector),')');

 AllNalog:=AllNAlog+StrToReal(E^.Dat.ENalog);

If (E^.Dat.Realiz) And Not(E^.DAt.DocSelector in[5,6,7,8]) Then
Begin
Writeln(Txt,'ПО НАКЛАДНОЙ КОНСИГНАЦИИ: '+E^.Dat.DocReal+ ' от  '+E^.Dat.DocDate);
End;


If E^.Dat.OperatorSelector<2 Then Barter[0]:=#0
Else Barter:='-Б';


Case E^.Dat.DocSelector Of
0:begin

   If E^.Dat.OperatorSelector=0 Then
   Writeln(Txt,'                     С П И С О К   N '+E^.Dat.Document+BArter+ ' от ',E^.Dat.DAteC+' ('+E^.Dat.TimeC+')')
   Else
   Writeln(Txt,'       Н А К Л А Д Н А Я (межскладская перевозка)  N '+E^.Dat.Document+BArter+ ' от ',E^.Dat.DAteC+' ('+
   E^.Dat.TimeC+')');
   If E^.Dat.OperatorSelector=1 Then
   Writeln(Txt,Space+'Получатель: ',GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+E^.Dat.ClientKod+')')
   Else
   Writeln(Txt,Space+'Получатель: ',{GetClient(E^.Dat.ClientKod)+}' ('+E^.Dat.ClientKod+')');
   As.EditPosition:=E^.Dat.Document;
   As.D:=E^.Dat.DAteC;
   FormNakl(Space,True,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,false);
   AllItogo:=AllItogo+Itogo;
   AllSkidka:=AllSkidka+ItogoSkidka;
  end;{список}
1:begin
    Writeln(txt,'                      Т О В А Р Н Ы Й  Ч Е К   N '+E^.Dat.Document+BArter+' от ',E^.Dat.DAteC+' ('+
    E^.Dat.TimeC+')');
    Writeln(Txt,'Получатель: ',GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+E^.Dat.ClientKod+')');
    As.EditPosition:=E^.Dat.Document;
    As.D:=E^.Dat.DAteC;
    FormNakl(Space,True,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,False);
    AllItogo:=AllItogo+Itogo;
    AllSkidka:=AllSkidka+ItogoSkidka;
  end;{товарный чек}
2:begin
    Writeln(txt,'                      Н А К Л А Д Н А Я   N '+E^.Dat.NaklNumer+BArter+'/'+E^.Dat.Document+
    +' от ',E^.Dat.DAteC+' ('+
    E^.Dat.TimeC+')');
    Writeln(Txt,'Получатель: ',GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+E^.Dat.ClientKod+')');
    {Убрал по просьбе Юрия Григорьевича
    Writeln(Txt,'                        Н А К Л А Д Н А Я   N '+E^.Dat.Document+' от ',E^.Dat.DAteC+' ('+E^.Dat.TimeC+')');
    Writeln(Txt,'Получатель: ',GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+E^.Dat.ClientKod+')');
    }
    As.EditPosition:=E^.Dat.Document;
    As.D:=E^.Dat.DAteC;
    FormNakl(Space,True,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,False);
    AllItogo:=AllItogo+Itogo;
    AllSkidka:=AllSkidka+ItogoSkidka;
  end;{накладная с приходником}
3,4:
   begin
    If E^.Dat.DocSelector=4 Then
    Begin
     Writeln(txt,'Платежное поручение N: '+E^.Dat.Bn.NPlat+' от '+E^.Dat.Bn.Date);
     Writeln(txt,'Банк: '+E^.Dat.Bn.BAnk);
    End;

    Writeln(txt,'                      Н А К Л А Д Н А Я   N '+E^.Dat.NaklNumer+BArter+'/'+E^.Dat.Document+
    ' от ',E^.Dat.DAteC+' ('+
    E^.Dat.TimeC+')');
    Writeln(Txt,'Получатель: ',GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+E^.Dat.ClientKod+')');
    {
    Writeln(Txt,'                        Н А К Л А Д Н А Я   N '+E^.Dat.Document+' от ',E^.Dat.DAteC+' ('+E^.Dat.TimeC+')');
    Writeln(Txt,'Получатель: ',GetClientField(FClient,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+E^.Dat.ClientKod+')');
    }
    As.EditPosition:=E^.Dat.Document;
    As.D:=E^.Dat.DAteC;
    FormNakl(Space,True,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,False);
    AllItogo:=AllItogo+Itogo;
    AllSkidka:=AllSkidka+ItogoSkidka;
   end;{с/ф накладная и приходник}
5,6,7,8:
   begin
   {DateMask:=InternationalDate(False,True);}

    If E^.Dat.DocSelector in [6,8] Then
    Writeln(txt,'                      Н А К Л А Д Н А Я   N '+E^.Dat.NaklNumer+BArter+'/'+E^.Dat.Document+
    ' от ',E^.Dat.DAteC+' ('+
    E^.Dat.TimeC+')')
    Else
    Writeln(txt,'                      Т О В А Р Н Ы Й  Ч Е К   N '+E^.Dat.Document+BArter+' от ',E^.Dat.DAteC+' ('+
    E^.Dat.TimeC+')');
{
Writeln(Txt,'           Н А К Л А Д Н А Я  на  консигнацию  N '+E^.Dat.Document+' от ',E^.Dat.DAteC+' ('+E^.Dat.TimeC+')');
}
Wiwod:=False;
Assign(fr,Path.ToDolg+E^.DAt.ClientKod+'.dlg');
sh:=IOResult;
Reset(fr);
sh:=IOResult;
If Sh=0 Then
Begin
  New(Er,Init);
  Find:=False;
  DelSpace(E^.Dat.Document);
   While Not(Eof(fr)) And Not(Find) Do
     Begin
      Read(fr,Er^.Dat);
      DelSpace(Er^.Dat.Market.Document);
      If (Er^.Dat.Market.Document=E^.Dat.Document)
         And(Er^.Dat.Market.DAteC=E^.Dat.DateC)
      And(Er^.Dat.Market.Active) Then Find:=True;
     End;
  Close(Fr);
  If Not(Find) Then
   Begin
    MessageBox(^m+#3'Документ не найден в долгах клиента!',Nil,mfError+mfCancelButton)
   End
    Else
   Begin
    For sh:=1 To 4 Do
      Begin
        If Er^.DAt.Doc[sh].Employ Then
          Begin
            Wiwod:=True;
            Break;
          End;
      End;
    If Wiwod Then
      Begin
        Writeln(Txt,Sp+'┌───────────────────────────────┐');
        Writeln(txt,Sp+'│ По данной накладной выведены: │');
        For sh:=1 To 4 Do
          Begin
            If Er^.DAt.Doc[sh].Employ Then
               Begin
                 s:='│      '+Er^.DAt.Doc[sh].DocReal+' от '+Er^.DAt.Doc[sh].DocDAte;
                 Format(s,31);
                 s:=s+' │';
                 Writeln(txt,Sp+s);
               End;
          End;
        Writeln(Txt,Sp+'└───────────────────────────────┘');
      End;
   End;
  Dispose(Er,Done);
End;

    If E^.Dat.DocSelector in [6,8] Then
      Begin
        Writeln(Txt,'            ВНИМАНИЕ! ПО НАКЛАДНОЙ КОНСИГНАЦИИ КЛИЕНТУ ВЫДАН СЧЕТ-ФАКТУРА');
      End;

Write(Txt,'Выдано на консигнацию: ',
GetClientField(FFFName,E^.Dat.ClientKod,E^.Dat.OperatorSelector)+' ('+E^.Dat.ClientKod+')');
    Writeln(Txt{,'    Срок консигнации до: '+DateToDateString(DateMask,E^.Dat.Srok)});
    As.EditPosition:=E^.Dat.Document;
    As.D:=E^.Dat.DAteC;
    FormNakl(Space,True,As, E, Txt, NDS, Itogo, ItogoSkidka,NDS20,NDS10,NDS_,False);
    AllItogo:=AllItogo+Itogo;
    AllSkidka:=AllSkidka+ItogoSkidka;
   end;{с/ф накладная и приходник}
Else;
End;
End;
End;
End;
End;

Close(f);
Writeln(txt);
Writeln(Txt,'    Всего за день скидка: ',RecognizReal(AllSkidka,CIZena,CMantissa),' руб.');
Writeln(Txt,'    Всего за день  сумма: ',RecognizReal(AllItogo,CIZena,CMantissa),' руб.');
Writeln(Txt,'        Всего за день НП: ',RecognizReal(AllNAlog,CIZena,CMantissa),' руб.');
Str(Doc:CLitrMAntissa,ws);
Writeln(Txt,'Всего за день документов: ',Ws);

Close(txt);
Dispose(E,Done);
If Regim Then NoInfo;
ERase(Txt1);
If Regim Then ViewAsText(Path.ToTemp+'nakladn.txt',False);

{ViewAsText('c:\newskl\1.txt',True); отладка просмотра фала большого размера}

MyStr(AllItogo,CIZena,CMantissa,ws);
s:=ws;
MyStr(AllSkidka,CIZena,CMantissa,ws);
s:=s+' '+ws;
Str(Doc:CLitrMAntissa,ws);
s:=s+' '+ws;
ViewAllNakl:=s;
{ViewAllNakl:=RecognizReal(AllItogo,CIZena,CMantissa)+';'+RecognizReal(AllSkidka,CIZena,CMantissa)+'│'+s;}
End;








Begin
DateMask:=InternationalDAte(False,True);
TimeMask:='hh:mm:ss';
{
writeln(datemask);
writeln(datestringtodate(datemask,'01-04-99'));
readln;
}

End.
