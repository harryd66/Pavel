{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}


Unit Net3;

Interface

Uses ServStr,Dialogs,Glob;


Procedure SPRIDX(Regim:Boolean{Истина-автоматический;Ложь-командный});
Procedure FormPerevoskiFromMail;
Procedure NullIDX;{обнулить остатки}
Procedure TestComplect;
Procedure FindBron(Space:AllStr;SDAte:TDateString;SArt,SOtd:ArtikulStr;Var txt:Text);
Procedure SortZakazList(Var NoScreenList:PBox);


Function LockAndWriteKassa(var L:PDayKassaType):Boolean;
Function LockKassa(As : DocumentEditZ;Var E:PDayKassaType):Word;
Function UnLockKassa(Doc:ArtikulStr;DD: TDateString):Word;
Function LockAndWriteKassaOutEdit(Var L:PDayKassaType):Boolean;


Implementation

Uses Serv,MsgBox,NetCall,Dos,DbEngine,Views,Protect,Access,NetDbEng,Net,
     Memory,MAil,Printers,Tools,Utils5,Utils4,Net1,DbEngin2,ServStr2,
     Drivers,App,Objects,TpDate,inplong,ColorTxt,Utils,Utils1,Utils3;





Procedure FormPerevoskiFromMail;
Const SeparatorChar='│';
Var c,c1,FindOtd,Count : Word;
    StartDAte,StopDAte : TDAteString;
    Sklf : File;
    i : LongInt;
    star : TDAteSTring;
    NoScreenZakaz : PBox;
    Txt : Text;
    R : TRect;
    E : PBufZakazType;
    Start,Stop  : LongInt;
    s : String;
    SArt,SKol,SZena : TDAteString;
    Space,SSkladNAme,Summa,SItogo : AllStr;
    Pack,SFullName : String[CNAme+1+CNAme];
    SSKod : AllStr;
Begin
{
 вопрос относительно склада поставщика
 SelectOtkuda
  0:резервный
  1:кти
  2:сойфера
  3:зарезервировано
  4:отказ от расчета
 вопрос относительно даты доставки заказов
}

 If EnableAverageOtdel=0 Then Exit;

 If MessageBox(^M+Monopolia^,Nil,mfWarning+mfOkCancel)<>cmOk Then Exit;

 StartDate:=DateToDateString(DAteMask,DateStringToDAte(DAteMask,FDAte)+1);
 StopDate:=DateToDateString(DAteMask,DateStringToDAte(DAteMask,FDAte)+1);
 FindOtd:=SelOtkuda;

 If FindOtd=4 Then Exit;
 {If Not DatePeriodDialog(StartDate,StopDate,False) Then Exit;}
 If Not NewDateDialog(StartDate) Then Exit;

 StopDAte:=StartDAte;

 SSkladName:='????';
Case FindOtd Of
0:Begin
    FindOtd:=5;
    If StrToInt(Rek^.Dat.Kod)=10 Then
    SSkladName:=GetMAkeField(FMake,'0011',1){резервный продмаркета}
    Else
    SSkladName:=GetMAkeField(FMake,'0004',1){резервный};
  End;
1:Begin FindOtd:=6;SSkladName:=GetMAkeField(FMake,'0001',1){сойфера}End;
2:Begin FindOtd:=7;SSkladName:=GetMAkeField(FMake,'0009',1){кти}End;
3:FindOtd:=8;{зарезервировано}
Else Exit;
End;

 Start:=DateStringToDAte(DAteMask,StartDAte);
 Stop :=DateStringToDAte(DAteMask,StopDate);


SSKod:=IntToStr(StrToInt(Rek^.Dat.Kod),CClientKod);

RFormatZerro(SSKod,CMantissa);


Assign(Txt,Path^.Dat.ToMarket+'Zakaz.gid');
i:=IOResult;
Reset(Txt);
i:=IOResult;
If i<>0 Then
 BEgin
  MessageBox(^M+#3+'Ошибка открытия файла-маршрутизатора '+Path^.Dat.ToMarket+'Zakaz.gid',Nil,mfError+
  mfCancelButton);
 End
 Else
  Begin
   Readln(txt,Star);
   i:=IOResult;
   System.Close(Txt);
   i:=IOResult;
  End;


Assign(Sklf,Path^.DAt.ToMarket+'zakaz.db');
i:=IOResult;
Reset(Sklf,SizeOf(ZakazType));
i:=IOResult;
If I<>0 Then
 Begin
  MessageBox(^M+#3+'Ошибка открытия файла '+Path^.Dat.ToMarket+'Zakaz.db',Nil,mfError+
  mfCancelButton);
  Exit;
 End;

R.Assign(0, 0, 0, 0);
NoScreenZakaz := New(PBox, Init(R, 1, Nil));
NoScreenZakaz^.NewList(New(PTextCollection, Init(0,1)));

{формируем список забронированного товара по заказам}
If (StrToInt(Star)-10)>=0 Then
Begin
Seek(SklF,StrToInt(Star)-10);
Star:=IntToStr(StrToInt(Star)-10,CKOl);
End
Else
 Begin
  Seek(SklF,StrToInt(Star));
 End;

  New(E,Init);

While Not(Eof(Sklf)) Do
Begin

  DInfoMsgShkala('Формирую заявку для склада '+SSkladName+'...',0,FileSize(SklF)-StrToInt(Star),FilePos(SklF)-StrToInt(Star));

  ReadBufZakaz(Sklf,E,Count);

  For c:=1 To Count Do
   Begin
    {добавляем в список забронированный товар}
   If (E^.Point.Dat[c].Oformlenie=0)  Then
Begin

      E^.Point.Dat[c].DateC:=DateToDAteString(DateMask,
         DateStringToDate(DateMask,E^.Point.Dat[c].DateC)+E^.Point.Dat[c].EndDAte);

  If (DAteStringToDate(DateMask,E^.Point.Dat[c].DAteC)>=Start) And
     (DAteStringToDate(DateMask,E^.Point.Dat[c].DAteC)<=Stop) Then
  Begin

    s[0]:=#0;
    For c1:=1 to E^.Point.Dat[c].Amount Do
     Begin


      If E^.Point.Dat[c].MarketElement[c1].Input.InputDivision=FindOtd Then
   Begin
      If(TestElement(E^.Point.Dat[c].MarketElement[c1].BAzKod,NoScreenZakaz)) Then
        Begin{элемент не найден в списке}
         DelSpace(E^.Point.Dat[c].MarketElement[c1].Input.Kol);
         RFormat(E^.Point.Dat[c].MarketElement[c1].Input.Kol,CKOl);
         s:='│'+E^.Point.Dat[c].MarketElement[c1].BAzKod+'│'+E^.Point.Dat[c].MarketElement[c1].Input.Kol;
        End
        Else {элемент найден в списке}
         Begin
          s:=NoScreenZakaz^.GetText(
             Location(NoScreenZakaz,E^.Point.Dat[c].MarketElement[c1].BAzKod,False),NoScreenZakaz^.List^.Count);
          sKol:=Copy(s,1+1+CArtikul+1,CKol+1);
          Str(StrToInt(SKOl)+StrToInt(E^.Point.Dat[c].MarketElement[c1].Input.Kol):CKol+1,SKOl);
          s:='│'+E^.Point.Dat[c].MarketElement[c1].BAzKod+'│'+SKol;
          NoScreenZakaz^.List^.AtFree(Location(NoScreenZakaz,E^.Point.Dat[c].MArketElement[c1].BAzKod,False));
          NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
         End;

        NoScreenZakaz^.List^.Insert(NewStr(s));
        NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
   End;
     End;{For Amount}



    {добавляем в список забронированные сертификаты}
    s[0]:=#0;
    For c1:=1 to E^.Point.Dat[c].AmountS Do
     Begin

      If E^.Point.Dat[c].DocumentElement[c1].Input.InputDivision=FindOtd Then
   Begin
      If(TestElement(E^.Point.Dat[c].DocumentElement[c1].BAzKod,NoScreenZakaz)) Then
        Begin{элемент не найден в списке}
         DelSpace(E^.Point.Dat[c].DocumentElement[c1].Input.Kol);
         RFormat(E^.Point.Dat[c].DocumentElement[c1].Input.Kol,CKOl);
         s:='│'+E^.Point.Dat[c].DocumentElement[c1].BAzKod+'│'+E^.Point.Dat[c].DocumentElement[c1].Input.Kol;
        End
        Else {элемент найден в списке}
         Begin
         s:=NoScreenZakaz^.GetText(
            Location(NoScreenZakaz,E^.Point.Dat[c].DocumentElement[c1].BAzKod,False),
            NoScreenZakaz^.List^.Count);
         sKol:=Copy(s,1+1+CArtikul+1,CKol+1);
         Str(StrToInt(SKOl)+StrToInt(E^.Point.Dat[c].DocumentElement[c1].Input.Kol):CKol+1,SKOl);
         s:='│'+E^.Point.Dat[c].DocumentElement[c1].BAzKod+'│'+SKol;
          NoScreenZakaz^.List^.AtFree(Location(NoScreenZakaz,E^.Point.Dat[c].DocumentElement[c1].BAzKod,False));
          NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
         End;
        NoScreenZakaz^.List^.Insert(NewStr(s));
        NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
   End;
     End;{For Amount}
  End;{DAteC}
End;{Oformlenie}

   End;{For Count}
End;{While}
System.Close(Sklf);
i:=IOResult;
{закончили формировать список забронированного товара по заказам}
NoInfoMsg;

Dispose(E,Done);


Assign(Txt,Path^.Dat.ToTemp+'Zajavka.z'+SSKod);
i:=IOResult;
Rewrite(Txt);
i:=IOResult;
If i<>0 Then
 BEgin
  Dispose(NoScreenZakaz,Done);
  MessageBox(^M+#3+'Ошибка создания '+Path^.Dat.ToTemp+'Zajavka.z'+SSKod+' Код:'+
  IntToStr(i,CMAntissa),Nil,mfError+
  mfCancelButton);
  Exit;
 End;

 Space:='';
 Writeln(txt,NPrint^.Dat.Ini+GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]);
 Writeln(txt,Space+ 'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-01');
 Writeln(txt);


 Writeln(txt,Space+'           ЗАЯВКА НА ПЕРЕВОЗКУ ТОВАРА СО СКЛАДА '+SSkladName);
 Writeln(txt,Space+' для комплектации заказов подлежащих доставке клиенту в период с '+StartDate+' по '+StopDAte);
 Writeln(txt);
 Writeln(txt,Space+'┌──┬─────┬────────────────────────────────────────────┬────────┬──────┬────────┬─────────────┐');
 Writeln(txt,Space+'│N │ Код │Наименование товара                         │Упаковок│Колич │ Р/Цена │ Итого по Р/Ц│');
 Writeln(txt,Space+'└──┴─────┴────────────────────────────────────────────┴────────┴──────┴────────┴─────────────┘');

                    {123│12345│1234567890123456789012345612345678901234567│123456789│12345│12345678│1234567890123}

 Writeln(txt,GlobalPrn^.Dat.Pitch[Nprint^.DAt.Printer]);

 SortList(NoScreenZakaz);

 SItogo[0]:=#0;
 If NoScreenZakaz^.List^.Count-1>=0 Then
 For c:=0 To NoScreenZakaz^.List^.Count-1 Do
  Begin
   s := NoScreenZakaz^.GetText(c, NoScreenZakaz^.List^.Count);
   SKol:=Copy(s,1+1+CArtikul+1,CKol+1);{количество}
   SArt:=Copy(s,1+1,CArtikul);{количество}
   SZena:=BakGetField(FRZena,SArt,0);
   MyStr(StrToReal(SZena),CZena,CMAntissa,SZena);
   MyStr(StrToInt(SKol)*StrToReal(SZena),CInputIZena,CMAntissa,Summa);
   SFullNAme:=GetIdField(FFFNAme,SArt);
   Format(SFullNAme,CNAme+1+CNAme-(CPAck+1));
   S:=IntToStr(c+1,CLitrMAntissa);
   DelSPace(s);
   DelSpace(SKol);
   RFormat(SKol,CKol);
   RFormat(s,CLitrMAntissa);
   Pack:=CalcPack(SArt,SKol);
   DelSpace(Pack);
   RFormat(Pack,CPAck);

   If c<>NoScreenZakaz^.List^.Count-1 Then
   Writeln(txt,Space+s+SeparatorChar+SArt+SeparatorChar+SFullName+SeparatorChar+Pack+SeparatorChar+SKol+SeparatorChar+SZena+
   SeparatorChar+Summa)
   Else
   Writeln(txt,Space+s+SeparatorChar+SArt+SeparatorChar+SFullName+SeparatorChar+Pack+SeparatorChar+
   SKol+SeparatorChar+SZena+
   SeparatorChar+Summa);
   MyStr(StrToReal(SITogo)+StRToReal(Summa),CIZena,CMantissa,SItogo);
  End;
 MyStr(StrToReal(SITogo),CIZena,CMantissa,SItogo);
 Writeln(txt,Space+GlobalPrn^.Dat.NoPitch[Nprint^.DAt.Printer]);
 Writeln(txt,Space+'──────────────────────────────────────────────────────────────────────────────────────────────');
 Writeln(txt,Space+'Всего позиций:'+SeparatorChar,NoScreenZakaz^.List^.Count:CKol);
 Writeln(txt,Space+'Всего по Р/Ценам:'+SeparatorChar,SItogo);
 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'=============================================================================================='+
 GlobalPrn^.Dat.EndPage[NPrint^.Dat.Printer]);

 i:=IOResult;
 System.Close(txt);
 i:=IOResult;
 Dispose(NoScreenZakaz,Done);


  DInfoMsg('Отправляю заявку...',False);
  DoneSysError;
  DoneEvents;
  Application^.HideCursor;
  DoneDosMem;
  SwapVectors;
  Exec(GetEnvMy,' /c copy '+Path^.Dat.ToTemp+'Zajavka.z'+SSKod+' '+Path^.Dat.ToRemoteDir+' '+NullStr^);
  SwapVectors;
  InitDosMem;
  InitEvents;
  InitSysError;
  CursorLines:=1543;
  Application^.Redraw;
     Case DosError Of
    2:MessageBox(#3^M+#3'Файл не найден !',Nil,mfError+mfCancelButton);
    3:MessageBox(#3^M+#3'Путь не найден !',Nil,mfError+mfCancelButton);
    5:MessageBox(#3^M+#3'Доступ невозможен !',Nil,mfError+mfCancelButton);
    6:MessageBox(#3^M+#3'Неверное устройство !',Nil,mfError+mfCancelButton);
    8:MessageBox(#3^M+#3'Недостаточно памяти !',Nil,mfError+mfCancelButton);
   10:MessageBox(#3^M+#3'Неверные настройки !',Nil,mfError+mfCancelButton);
   11:MessageBox(#3^M+#3'Неверный формат !',Nil,mfError+mfCancelButton);
   18:MessageBox(#3^M+#3'Слишком много файлов !',Nil,mfError+mfCancelButton);
    Else;
    End;
  NoInfoMsg;

 If FExists(Path^.Dat.ToRemoteDir+'Zajavka.z'+SSKod) Then
 Begin
 MessageBox(^M+#3+'Отправка заявки успешно завершена!',nil,mfWarning+mfCancelButton);
 AddProtocol('Отправка заявки на перевозку товара со склада '+SSkladName,
 'для комплектации заказов подлежащих доставке клиенту в период с '+StartDate+' по '+StopDAte,'');
 End
 Else
 MessageBox(^M+#3'Заявка не отправлена!',nil,mfWarning+mfCancelButton);

End;




Procedure SPRIDX(Regim:Boolean{Истина-автоматический;Ложь-командный});
Label 1{марка},
      2{гтд},
      3{спец.марка},
      4{эксперт},
      5{орган},
      6{поставщик},
      7{фирма поставщик},
	 8{ед.измерения},
	 9{группы},
	 10{регионы},
	 11{маршруты},
      12,14,15,16,17;
Var c : LongInt;
    ws : String;
    MarkaFile : MarkaFileType;
    MarkaElement :MarkaType;
    ExpertFile : ExpertFileType;
    ExpertElement :ExpertType;
    MeraFile : MeraFileType;
    MeraElement :MeraType;
    RegionFile : RegionFileType;
    RegionElement :RegionType;
    RouteFile : RouteFileType;
    RouteElement :RouteType;
    GroupFile : GroupFileType;
    GroupElement :GroupType;
    LandsFile : PostFileType;
    LandsElement :PostType;
    FirmaFile : FirmaPostFileType;
    FirmaElement :FirmaPostType;
    KSertifFile : KSertifFileType;
    KSertifElement :KSertifType;
    SpecMarkaFile : SpecMarkaFileType;
    SpecMarkaElement :SpecMarkaType;
    NGTDFile : NGTDFileType;
    NGTDElement :NGTDType;
    ClassFile : ClassFileType;
    ClassElement : ClassificatorBuchType;
    PersonalFile   : PersonalFileType;
    PersonalElement : PersonalType;
    KassaOpFile :KassaOperationFileType;
    KassaElement : KassaOperationType;
    BankFile : BankFileType;
    BankElement : BankType;


Begin

If Not Regim Then
If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
Exit;

Assign (MarkaFile,Path^.Dat.ToSPR+'marka.db');
c:=IOResult;
Reset (MarkaFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы акц.марок '+Path^.Dat.ToSPR+'marka.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 2;
 End;
c:=0;

While Not(Eof(MarkaFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы акц.марок ...',0,FileSize(MarkaFile),FilePos(MarkaFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(MarkaFile,FilePos(MarkaFile)*SizeOf(MarkaType),SizeOf(MarkaType));

     Read(MarkaFile,MarkaElement);

  Str(c:CArtikul,ws);
  RFormatZerro(ws,CArtikul);
  Seek(MarkaFile,FilePos(MarkaFile)-1);
  MarkaElement.Kod:=ws;
  Write(MarkaFile,MarkaElement);

     Repeat
      NetCall.UnLock(MarkaFile,(FilePos(MarkaFile)-1)*SizeOf(MarkaType),SizeOf(MarkaType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(MarkaFile);
c:=IOResult;
NoInfoMsg;

2:
Assign (NGTDFile,Path^.Dat.ToSPR+'NGTD.db');
c:=IOResult;
Reset (NGTDFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы гтд '+Path^.Dat.ToSPR+'NGTD.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 3;
 End;
c:=0;

While Not(Eof(NGTDFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы гтд ...',0,FileSize(NGTDFile),FilePos(NGTDFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(NGTDFile,FilePos(NGTDFile)*SizeOf(NGTDType),SizeOf(NGTDType));

     Read(NGTDFile,NGTDElement);

  Str(c:CArtikul,ws);
  RFormatZerro(ws,CArtikul);
  Seek(NGTDFile,FilePos(NGTDFile)-1);
  NGTDElement.Kod:=ws;
  Write(NGTDFile,NGTDElement);

     Repeat
      NetCall.UnLock(NGTDFile,(FilePos(NGTDFile)-1)*SizeOf(NGTDType),SizeOf(NGTDType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(NGTDFile);
c:=IOResult;
NoInfoMsg;

3:
Assign (SpecMarkaFile,Path^.Dat.ToSPR+'SMarka.db');
c:=IOResult;
Reset (SpecMarkaFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы спец.марок '+Path^.Dat.ToSPR+'sMarka.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 4;
 End;
c:=0;

While Not(Eof(SpecMarkaFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы спец.марок ...',0,FileSize(SpecMarkaFile),FilePos(SpecMarkaFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(SpecMarkaFile,FilePos(SpecMarkaFile)*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType));

     Read(SpecMarkaFile,SpecMarkaElement);

  Str(c:CArtikul,ws);
  RFormatZerro(ws,CArtikul);
  Seek(SpecMarkaFile,FilePos(SpecMarkaFile)-1);
  SpecMarkaElement.Kod:=ws;
  Write(SpecMarkaFile,SpecMarkaElement);

     Repeat
      NetCall.UnLock(SpecMarkaFile,(FilePos(SpecMarkaFile)-1)*SizeOf(SpecMarkaType),SizeOf(SpecMarkaType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(SpecMarkaFile);
c:=IOResult;
NoInfoMsg;
4:

Assign (ExpertFile,Path^.Dat.ToSPR+'expert.db');
c:=IOResult;
Reset (ExpertFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы экспертных заключений '+Path^.Dat.ToSPR+'Expert.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 5;
 End;
c:=0;

While Not(Eof(ExpertFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы экпертных заключений...',0,FileSize(ExpertFile),FilePos(ExpertFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(ExpertFile,FilePos(ExpertFile)*SizeOf(ExpertType),SizeOf(ExpertType));

     Read(ExpertFile,ExpertElement);

  Str(c:CArtikul,ws);
  RFormatZerro(ws,CArtikul);
  Seek(ExpertFile,FilePos(ExpertFile)-1);
  ExpertElement.Kod:=ws;
  Write(ExpertFile,ExpertElement);

     Repeat
      NetCall.UnLock(ExpertFile,(FilePos(ExpertFile)-1)*SizeOf(ExpertType),SizeOf(ExpertType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(ExpertFile);
c:=IOResult;
NoInfoMsg;

5:
Assign (KSertifFile,Path^.Dat.ToSPR+'KSertif.db');
c:=IOResult;
Reset (KSertifFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы органов сертификации '+Path^.Dat.ToSPR+'KSertif.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 6;
 End;
c:=0;

While Not(Eof(KSertifFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы органов сертификации...',0,FileSize(KSertifFile),FilePos(KSertifFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(KSertifFile,FilePos(KSertifFile)*SizeOf(KSertifType),SizeOf(KSertifType));

     Read(KSertifFile,KSertifElement);

  Str(c:CClientKod,ws);
  RFormatZerro(ws,CClientKod);
  Seek(KSertifFile,FilePos(KSertifFile)-1);
  KSertifElement.Kod:=ws;
  Write(KSertifFile,KSertifElement);

     Repeat
      NetCall.UnLock(KSertifFile,(FilePos(KSertifFile)-1)*SizeOf(KSertifType),SizeOf(KSertifType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(KSertifFile);
c:=IOResult;
NoInfoMsg;

6:
Assign (LandsFile,Path^.Dat.ToSPR+'Lands.db');
c:=IOResult;
Reset (LandsFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы стран '+Path^.Dat.ToSPR+'Lands.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 7;
 End;
c:=0;

While Not(Eof(LandsFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы стран...',0,FileSize(LandsFile),FilePos(LandsFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(LandsFile,FilePos(LandsFile)*SizeOf(PostType),SizeOf(PostType));

     Read(LandsFile,LandsElement);

  Str(c:CClientKod,ws);
  RFormatZerro(ws,CClientKod);
  Seek(LandsFile,FilePos(LandsFile)-1);
  LandsElement.Kod:=ws;
  Write(LandsFile,LandsElement);

     Repeat
      NetCall.UnLock(LandsFile,(FilePos(LandsFile)-1)*SizeOf(PostType),SizeOf(PostType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(LandsFile);
c:=IOResult;
NoInfoMsg;


7:
Assign (FirmaFile,Path^.Dat.ToSPR+'Firma.db');
c:=IOResult;
Reset (FirmaFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы стран '+Path^.Dat.ToSPR+'Firma.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 8;
 End;
c:=0;

While Not(Eof(FirmaFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы стран...',0,FileSize(FirmaFile),FilePos(FirmaFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(FirmaFile,FilePos(FirmaFile)*SizeOf(FirmaPostType),SizeOf(FirmaPostType));

     Read(FirmaFile,FirmaElement);

  Str(c:CClientKod,ws);
  RFormatZerro(ws,CClientKod);
  Seek(FirmaFile,FilePos(FirmaFile)-1);
  FirmaElement.Kod:=ws;
  Write(FirmaFile,FirmaElement);

     Repeat
      NetCall.UnLock(FirmaFile,(FilePos(FirmaFile)-1)*SizeOf(FirmaPostType),SizeOf(FirmaPostType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(FirmaFile);
c:=IOResult;
NoInfoMsg;


8:
Assign (MeraFile,Path^.Dat.ToSPR+'Mera.db');
c:=IOResult;
Reset (MeraFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы единиц измерения '+Path^.Dat.ToSPR+'Mera.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 9;
 End;
c:=0;

While Not(Eof(MeraFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы единиц измерения...',0,FileSize(MeraFile),FilePos(MeraFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(MeraFile,FilePos(MeraFile)*SizeOf(MeraType),SizeOf(MeraType));

     Read(MeraFile,MeraElement);

  Str(c:CClientKod,ws);
  RFormatZerro(ws,CClientKod);
  Seek(MeraFile,FilePos(MeraFile)-1);
  MeraElement.Kod:=ws;
  Write(MeraFile,MeraElement);

     Repeat
      NetCall.UnLock(MeraFile,(FilePos(MeraFile)-1)*SizeOf(MeraType),SizeOf(MeraType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(MeraFile);
c:=IOResult;
NoInfoMsg;


9:
Assign (GroupFile,Path^.Dat.ToSPR+'Group.db');
c:=IOResult;
Reset (GroupFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы групп '+Path^.Dat.ToSPR+'Group.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 10;
 End;
c:=0;

While Not(Eof(GroupFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы групп...',0,FileSize(GroupFile),FilePos(GroupFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(GroupFile,FilePos(GroupFile)*SizeOf(GroupType),SizeOf(GroupType));

     Read(GroupFile,GroupElement);

  Str(c:CClientKod,ws);
  RFormatZerro(ws,CClientKod);
  Seek(GroupFile,FilePos(GroupFile)-1);
  GroupElement.Kod:=ws;
  Write(GroupFile,GroupElement);

     Repeat
      NetCall.UnLock(GroupFile,(FilePos(GroupFile)-1)*SizeOf(GroupType),SizeOf(GroupType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(GroupFile);
c:=IOResult;
NoInfoMsg;


10:
Assign (RegionFile,Path^.Dat.ToSPR+'Region.db');
c:=IOResult;
Reset (RegionFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы регионов '+Path^.Dat.ToSPR+'Region.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 11;
 End;
c:=0;

While Not(Eof(RegionFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы регионов...',0,FileSize(RegionFile),FilePos(RegionFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(RegionFile,FilePos(RegionFile)*SizeOf(RegionType),SizeOf(RegionType));

     Read(RegionFile,RegionElement);

  Str(c:CClientKod,ws);
  RFormatZerro(ws,CClientKod);
  Seek(RegionFile,FilePos(RegionFile)-1);
  RegionElement.Kod:=ws;
  Write(RegionFile,RegionElement);

     Repeat
      NetCall.UnLock(RegionFile,(FilePos(RegionFile)-1)*SizeOf(RegionType),SizeOf(RegionType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(RegionFile);
c:=IOResult;
NoInfoMsg;

11:
Assign (RouteFile,Path^.Dat.ToSPR+'Route.db');
c:=IOResult;
Reset (RouteFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы маршрутов '+Path^.Dat.ToSPR+'Route.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 12;
 End;
c:=0;

While Not(Eof(RouteFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы маршрутов...',0,FileSize(RouteFile),FilePos(RouteFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(RouteFile,FilePos(RouteFile)*SizeOf(RouteType),SizeOf(RouteType));

     Read(RouteFile,RouteElement);

  Str(c:CClientKod,ws);
  RFormatZerro(ws,CClientKod);
  Seek(RouteFile,FilePos(RouteFile)-1);
  RouteElement.Kod:=ws;
  Write(RouteFile,RouteElement);

     Repeat
      NetCall.UnLock(RouteFile,(FilePos(RouteFile)-1)*SizeOf(RouteType),SizeOf(RouteType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(RouteFile);
c:=IOResult;
NoInfoMsg;


12:
Assign (ClassFile,Path^.Dat.ToSPR+'Class.db');
c:=IOResult;
Reset (ClassFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы классов '+Path^.Dat.ToSPR+'Class.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 14;
 End;
c:=0;


While Not(Eof(ClassFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы классов бухгалтерии...',0,FileSize(ClassFile),FilePos(ClassFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(ClassFile,FilePos(ClassFile)*SizeOf(ClassificatorBuchType),SizeOf(ClassificatorBuchType));

     Read(ClassFile,ClassElement);

  Str(c:CClientKod,ws);
  RFormatZerro(ws,CClientKod);
  Seek(ClassFile,FilePos(ClassFile)-1);
  ClassElement.Kod:=ws;
  Write(ClassFile,ClassElement);

     Repeat
      NetCall.UnLock(ClassFile,(FilePos(ClassFile)-1)*SizeOf(ClassificatorBuchType),SizeOf(ClassificatorBuchType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(ClassFile);
c:=IOResult;
NoInfoMsg;
14:

Assign (PersonalFile,Path^.Dat.ToSPR+'Personal.db');
c:=IOResult;
Reset (PersonalFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы персонала '+Path^.Dat.ToSPR+'Personal.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 15;
 End;
c:=0;


While Not(Eof(PersonalFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы персонала...',0,FileSize(PersonalFile),FilePos(PersonalFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(PersonalFile,FilePos(PersonalFile)*SizeOf(PersonalType),SizeOf(PersonalType));

     Read(PersonalFile,PersonalElement);

  Str(c:CClientKod,ws);
  RFormatZerro(ws,CClientKod);
  Seek(PersonalFile,FilePos(PersonalFile)-1);
  PersonalElement.Kod:=ws;
  Write(PersonalFile,PersonalElement);

     Repeat
      NetCall.UnLock(PersonalFile,(FilePos(PersonalFile)-1)*SizeOf(PersonalType),SizeOf(PersonalType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(PersonalFile);
c:=IOResult;
NoInfoMsg;


15:

Assign (BankFile,Path^.Dat.ToSPR+'Banks.db');
c:=IOResult;
Reset (BankFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы банков '+Path^.Dat.ToSPR+'Banks.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 16;
 End;
c:=0;


While Not(Eof(BankFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы банков...',0,FileSize(BankFile),FilePos(BankFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(BankFile,FilePos(BankFile)*SizeOf(BankType),SizeOf(BankType));

     Read(BankFile,BankElement);

  Str(c:CClientKod,ws);
  RFormatZerro(ws,CClientKod);
  Seek(BankFile,FilePos(BankFile)-1);
  BankElement.Kod:=ws;
  Write(BankFile,BankElement);

     Repeat
      NetCall.UnLock(BankFile,(FilePos(BankFile)-1)*SizeOf(BankType),SizeOf(BankType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(BankFile);
c:=IOResult;
NoInfoMsg;


16:

Assign (KassaOpFile,Path^.Dat.ToSPR+'Kassa.db');
c:=IOResult;
Reset (KassaOpFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox('Ошибка открытия базы кассовых операци '+Path^.Dat.ToSPR+'Kassa.db!'+' Код:'+IntToStr(c,CKol),
  Nil,mfError+mfCancelButton);
  Goto 17;
 End;
c:=0;


While Not(Eof(KassaOpFile)) Do
 Begin
     DInfoMsgShkala('Идет восстановление индексов базы кассовых операций...',0,FileSize(KassaOpFile),FilePos(KassaOpFile));

     Repeat
      Pause(1);
     Until NetCall.Lock(KassaOpFile,FilePos(KassaOpFile)*SizeOf(KassaOperationType),SizeOf(KassaOperationType));

     Read(KassaOpFile,KassaElement);

  Str(c:CClientKod,ws);
  RFormatZerro(ws,CClientKod);
  Seek(KassaOpFile,FilePos(KassaOpFile)-1);
  KassaElement.Kod:=ws;
  Write(KassaOpFile,KassaElement);
  c:=IOResult;

     Repeat
      NetCall.UnLock(KassaOpFile,(FilePos(KassaOpFile)-1)*SizeOf(KassaOperationType),SizeOf(KassaOperationType));
     Until (DosError=0);
  Inc(c);
 End;{While}
c:=IOResult;
System.Close(KassaOpFile);
c:=IOResult;
NoInfoMsg;


17:




If Not Regim Then
AddProtocol('Индексация дополнительных справочников','','')
Else
AddProtocol('Автоматическая индексация дополнительных справочников','','');

If Not Regim Then
MessageBox(^M+#3'Индексация завершена!',Nil,mfInformation+mfCancelButton);

End;



Procedure NullIDX;
VAr sklFile : File Of SkladType;
    skl : pSkladType;
    RazdelFile : File Of RazdelType;
    RazdelElement : RazdelType;
    IndexFileNew : File Of SkladTypeNew;
    Indexnew : PSkladTypenew;
    Be : PBazType;

    F : Boolean;
    jk,c : Word;
    ch : LongInt;
    ws : String;
    k,All : LongInt;
    j : Word;
Begin
If Not (CurrentPassword='00') Then Exit;

If MessageBox(^M+#3'Функция требует монопольного использования базы данных!',Nil,mfWarning+mfOkCancel)<>cmOk Then
Exit;

If MessageBox(#3^M+#3'Эта операция приведет к полной очистке остатков товара! Желаете продолжить?',Nil,
  mfFatalError+mfConfirmation+mfNoButton+mfCancelButton)<>cmNo Then Exit;


c:=IOResult;
Assign(RazdelFile,Path^.Dat.ToRazdel+'Razdel.db');
Reset(RazdelFile);
c:=IOResult;
If c<>0 Then
 Begin
  MessageBox(^M+#3'Ошибка доступа к файлу разделов!',Nil,mfError+mfCancelButton);
  Exit;
 End;
While Not(Eof(RazdelFile)) Do
 Begin
  Read(RazdelFile,RazdelElement);
  If RazdelElement.Employ Then
  Begin
   DInfo('Идет очистка остатков и восстановление индексов раздела '+RazdelElement.Kod+'...');
   Assign(SklFile,Path^.Dat.ToSklad+RazdelElement.Kod+'.db');
   c:=IOResult;
   Reset(SklFile);
   c:=IOResult;
If c<>0 Then
 Begin
  c:=IOResult;
  Close(RazdelFile);
  c:=IOResult;
  NoInfo;
  MessageBox(^M+#3'Ошибка доступа к файлу '+Path^.Dat.ToSklad+RazdelElement.Kod+'.db',Nil,mfError+mfCancelButton);
  Exit;
 End;


c:=IOResult;
Assign(IndexFileNew,Path^.Dat.ToIndex+RazdelElement.Kod+'.kdx');
Rewrite(IndexFileNew);
c:=IOResult;
If c<>0 Then
 Begin
  Close(RazdelFile);
  c:=IOResult;
  Close(SklFile);
  c:=IOResult;
  NoInfo;
  MessageBox(^M+#3'Ошибка создания файла индексов '+Path^.Dat.ToIndex+RazdelElement.Kod+'.kdx'+'!',Nil,
  mfError+mfCancelButton);
  Exit;
 End;

   New(Skl,Init);
   New(IndexNew,Init);
   ch:=0;
   While Not(Eof(sklFile)) Do
    Begin

     Repeat
      Pause(1);
     Until NetCAll.Lock(SklFile,FilePos(SklFile)*SizeOf(SkladType),SizeOf(SkladType));

     Read(SklFile,Skl^.Dat);
     Str(ch:3,ws);
     RFormatZerro(ws,3);


     If Skl^.Dat.Employ Then
     With Skl^.Dat.Input Do
     Begin
      All:=0;
      For k:=1 To CDivision Do
        Begin
           Division[k,0]:=#0;
           DivisionR[k,0]:=#0;
           Str(StrToInt(Division[k]):CKol,Division[k]);
           DelSpace(Division[k]);
           All:=All+StrToInt(Division[k]);
        End;
     Str(All:CKol,Skl^.Dat.Input.Kol);
     DelSpace(Skl^.Dat.Input.Kol);


     DelSpace(Skl^.Dat.Input.Kol);



      All:=0;
      For k:=1 To CDivision Do
        Begin
           Str(StrToInt(DivisionR[k]):CKol,DivisionR[k]);
           DelSpace(DivisionR[k]);
           All:=All+StrToInt(DivisionR[k]);
        End;
     Str(All:CKol,Skl^.Dat.Input.KolR);
     DelSpace(Skl^.Dat.Input.KolR);

     MyStr(StrToReal(Skl^.Dat.Input.R_Zena),CZena,CMantissa,Skl^.Dat.Input.R_Zena);
     DelSpace(Skl^.Dat.Input.R_Zena);

     Skl^.Dat.Input.NMAkeKod:=IntToStr(StrToInt(Skl^.Dat.Input.NMAkeKod),CArtikul);
     RFormatZerro(Skl^.Dat.Input.NMAkeKod,CArtikul);
     Skl^.Dat.BazKod:=IntToStr(FilePos(SklFile)-1,3);
     RFormatZerro(Skl^.Dat.BazKod,3);
     Skl^.Dat.BazKod:=RazdelElement.Kod+Skl^.Dat.BazKod;
     Skl^.Dat.Input.NGTD    :=IntToStr(StrToInt(Skl^.Dat.Input.NGTD),CArtikul);
     RFormatZerro(Skl^.Dat.Input.NGTD,CArtikul);
	Skl^.Dat.Input.Marka   :=IntToStr(StrToInt(Skl^.Dat.Input.Marka),CArtikul);
     RFormatZerro(Skl^.Dat.Input.Marka,CArtikul);
     Skl^.Dat.Input.SpecMarka :=IntToStr(StrToInt(Skl^.Dat.Input.SpecMarka),CArtikul);
     RFormatZerro(Skl^.Dat.Input.SpecMarka,CArtikul);
     Skl^.Dat.Input.Expert :=IntToStr(StrToInt(Skl^.Dat.Input.Expert),CArtikul);
     RFormatZerro(Skl^.Dat.Input.Expert,CArtikul);
	Skl^.Dat.Input.NSertif :=IntToStr(StrToInt(Skl^.Dat.Input.NSertif),CArtikul);
     RFormatZerro(Skl^.Dat.Input.NSertif,CArtikul);

     MyStr(StrToReal(Skl^.Dat.Input.O_Zena),CZena,CMantissa,Skl^.Dat.Input.O_Zena);
     DelSpace(Skl^.Dat.Input.O_Zena);
     MyStr(StrToReal(Skl^.Dat.Input.Spec_Zena),CZena,CMantissa,Skl^.Dat.Input.Spec_Zena);
     DelSpace(Skl^.Dat.Input.Spec_Zena);

     Skl^.Dat.Date:=DateStringToDAte(DateMask,FDate);
     Skl^.Dat.Time:=CurrentTime;
     MyStr(StrToReal(Skl^.Dat.Input.Zakupka),CZenaZ,CMantissaZ,Skl^.Dat.Input.Zakupka);
     Skl^.Dat.Input.Caption:=CurrentPassword;

     End;

     If Skl^.Dat.Employ Then
     Begin
     New(BE,Init);
     GetBazElement(Skl^.Dat.BazKod,BE^.Dat);
     IndexNew^.Dat.Name :=Be^.Dat.Name;
     IndexNew^.Dat.Name2:=Be^.Dat.Name2;
     IndexNew^.Dat.Main:=Be^.Dat.Main;
     IndexNew^.Dat.FantomKod:=StrToInt(Be^.Dat.FantomKod);
     IndexNew^.Dat.EnableSklads:=Be^.Dat.EnableSklads;
     IndexNew^.Dat.NGroupKod:=StrToInt(Be^.Dat.NGroupKod);
     IndexNew^.Dat.FirmaPostKod:=StrToInt(Be^.Dat.FirmaPostKod);
     IndexNew^.Dat.NMarkaKod:=StrToInt(Skl^.Dat.Input.Marka);
     IndexNew^.Dat.NSpecMarkaKod:=StrToInt(Skl^.Dat.Input.SpecMarka);
     IndexNew^.Dat.NExpertKod:=StrToInt(Skl^.Dat.Input.Expert);
     IndexNew^.Dat.NGTDKod:=StrToInt(Skl^.Dat.Input.NGTD);
     Dispose(BE,Done);
     End
      Else
       Begin
     IndexNew^.Dat.Name :='';
     IndexNew^.Dat.Name2:='';
     IndexNew^.Dat.Main:=0;
     IndexNew^.Dat.FantomKod:=IndexNew^.Dat.BazKod;
     IndexNew^.Dat.EnableSklads:=0;
     IndexNew^.Dat.NGroupKod:=0;
     IndexNew^.Dat.NMarkaKod:=0;
     IndexNew^.Dat.NSpecMarkaKod:=0;
     IndexNew^.Dat.NGTDKod:=0;
     IndexNew^.Dat.NExpertKod:=0;
     IndexNew^.Dat.FirmaPostKod:=0;
       End;

     IndexNew^.Dat.Virabotano :=DateStringToDate(DateMask,Skl^.Dat.input.Virabotano);
     IndexNew^.Dat.Employ :=Skl^.DAt.Employ;
     IndexNew^.Dat.NSertif :=StrToInt(Skl^.DAt.Input.NSertif);

     For j:=1 To CDivision Do IndexNew^.Dat.Division[j]:=StrToInt(Skl^.Dat.Input.Division[j]);
     For j:=1 To CDivision Do IndexNew^.Dat.DivisionR[j]:=StrToInt(Skl^.Dat.Input.DivisionR[j]);
     IndexNew^.Dat.R_Zena  :=StrToreal(Skl^.Dat.Input.R_Zena);

     IndexNew^.Dat.Zakupka :=StrToreal(Skl^.Dat.Input.Zakupka);
     IndexNew^.Dat.Zakupka2:=StrToreal(Skl^.Dat.Input.Zakupka2);
     IndexNew^.Dat.AkzisSbor:=StrToreal(Skl^.Dat.Input.AkzisSbor);

     IndexNew^.Dat.RegionMarka:=Skl^.Dat.Input.RegionMarka;
     IndexNew^.Dat.BazKod:=StrToInt(Skl^.Dat.BazKod);
     IndexNew^.Dat.Kol:=StrToInt(Skl^.Dat.Input.Kol);
     IndexNew^.Dat.StrihKod:=Skl^.Dat.Input.StrihKod;
     IndexNew^.Dat.NMakeKod:=StrToInt(Skl^.Dat.Input.NMakeKod);

     ws:=RazdelElement.Kod+ws;

     Seek(SklFile,FilePos(SklFile)-1);
     Skl^.Dat.BazKod:=ws;
     Write(SklFile,Skl^.Dat);

     Write(IndexFileNew,IndexNew^.Dat);

     Seek(SklFile,FilePos(SklFile)-1);
     Write(SklFile,Skl^.Dat);

     Repeat
      NetCall.UnLock(SklFile,(FilePos(SklFile)-1)*SizeOf(SkladType),SizeOf(SkladType));
     Until (DosError=0);

     Inc(ch);
     End;

   Dispose(Skl,Done);
   jk:=IOResult;
   Close(SklFile);
   jk:=IOResult;
   Close(IndexFileNew);
   jk:=IOResult;
   Dispose(IndexNew,Done);
   NoInfo;
   End;
 End;
     ch:=IOResult;
Close(RazdelFile);
     ch:=IOResult;
AddProtocol('Очистка остатков и индексация','','{уничтожение информации об остатках}');

MessageBox(^M+#3'Очистка остатков и переиндексация успешно завершена!',Nil,mfInformation+mfCancelButton);
End;



Procedure SortZakazList(Var NoScreenList:PBox);
VAr TempList : PBox;
    R : TRect;
    S : String;
    c : Word;
    SFullNAme: String;
    SOtd,SKOl,SArt,SRAzd,SSKol,Delta,SSum : AllStr;
Begin
If NoScreenList^.List<>Nil Then
 Begin
  If NoScreenList^.List^.Count-1>=0 Then
  Begin
   R.Assign(0, 0, 0, 0);
   TempList := New(PBox, Init(R, 1, Nil));
   TempList^.NewList(New(PTextCollection, Init(0,1)));

   For c:=0 To NoScreenList^.List^.Count-1 Do
    Begin
     DInfoMsgShkala('Анализирую складские остатки ...',0,NoScreenList^.List^.Count-1,c);
     s:=NoScreenList^.GetText(c,NoScreenList^.List^.Count);
     SKol:=Copy(s,1+1+CArtikul+1+COne+1,CKol+1);{количество}
     SArt:=Copy(s,1+1,CArtikul);{код}
     SRAzd:=COpy(SArt,1,CRAzdelKod);
     SOtd:=Copy(s,1+1+CArtikul+1,COne);{количество}
     SFullNAme:=GetIdField(FFFNAme,SArt);
     Format(SFullNAme,CNAme+1+CNAme);
     RFormat(s,CLitrMAntissa);
     SSKol:=BakGetField(FDiv,SArt,StrToInt(SOtd));
     DelSpace(Skol);
     RFormat(SKOl,CKol);
     DelSpace(SSkol);
     RFormat(SSKOl,CKol);
     Delta:=IntToStr(StrToInt(SKol)-StrToInt(SSKol),CKol);
     DelSpace(Delta);
     RFormat(Delta,CKOl);
     MyStr(StrToREal(BakGetField(FRZena,SArt,0))*StrToInt(Delta),CZenaZ,CMAntissa,SSum);
     s:=SRAzd+' '+SFullNAme+' '+SArt+' '+SOtd+' '+SKol+' '+SSKol+' '+Delta+' '+SSum;
     TempList^.List^.Insert(NewStr(s));
     TempList^.SetRange(TempList^.List^.Count);
    End;{For по}
   NoInfoMsg;

   NoScreenList^.NewList(Nil);
   NoScreenList^.NewList(New(PMyCollection, Init(0,1)));

   For c:=0 To TempList^.List^.Count-1 Do
    Begin
     DInfoMsgShkala('Сортирую отчет ...',0,TempList^.List^.Count-1,c);
     s:=TempList^.GetText(c,TempList^.List^.Count);
     System.Delete(s,1,CRAzdelKod+1);
     SArt:=Copy(s,1+(CNAme+1+CNAme)+1,CArtikul);
     System.Delete(s,1+(CNAme+1+CNAme)+1,CArtikul+1);
     s:=SArt+' '+S;
     NoScreenList^.List^.Insert(NewStr(s));
     NoScreenList^.SetRange(NoScreenList^.List^.Count);
    End;{For по}
   NoInfoMsg;

   Dispose(TempList,Done);
  End;{NoScreenList}
 End;{NoScreenList}
End;{Procedure}




Procedure FindBron(Space:AllStr;SDAte:TDateString;SArt,SOtd:ArtikulStr;Var txt:Text);
Var Txt1 : Text;
    i,c,c1,Count : Word;
    SClient : AllStr;
    Star : AllStr;
    E : PBufZAkazType;
    Sklf : File;
    Start : LongInt;
    Find : Boolean;
Begin
Start:=DAteStringToDAte(DAteMAsk,SDAte);
Assign(Txt1,Path^.Dat.ToMarket+'Zakaz.gid');
i:=IOResult;
Reset(Txt1);
i:=IOResult;
If i<>0 Then
 BEgin
  MessageBox(^M+#3+'Ошибка открытия файла-маршрутизатора '+Path^.Dat.ToMarket+'Zakaz.gid',Nil,mfError+
  mfCancelButton);
 End
 Else
  Begin
   Readln(txt1,Star);
   i:=IOResult;
   System.Close(Txt1);
   i:=IOResult;
  End;
Assign(Sklf,Path^.DAt.ToMarket+'zakaz.db');
i:=IOResult;
Reset(Sklf,SizeOf(ZakazType));
i:=IOResult;
If I<>0 Then
 Begin
  MessageBox(^M+#3+'Ошибка открытия файла '+Path^.Dat.ToMarket+'Zakaz.db',Nil,mfError+
  mfCancelButton);
  Exit;
 End;

{формируем список забронированного товара по заказам}
If (StrToInt(Star)-10)>=0 Then
Begin
Seek(SklF,StrToInt(Star)-10);
Star:=IntToStr(StrToInt(Star)-10,CKOl);
End
Else
 Begin
  Seek(SklF,StrToInt(Star));
 End;

  New(E,Init);

While Not(Eof(Sklf)) Do
Begin

  ReadBufZakaz(Sklf,E,Count);

  For c:=1 To Count Do
   Begin
    {добавляем в список забронированный товар}
   If (E^.Point.Dat[c].Oformlenie=0)  Then
Begin
   E^.Point.Dat[c].DateC:=DateToDAteString(DateMask,
   DateStringToDate(DateMask,E^.Point.Dat[c].DateC)+E^.Point.Dat[c].EndDAte);

  If (DAteStringToDate(DateMask,E^.Point.Dat[c].DAteC)=Start) Then
  Begin
    Find:=FAlse;
    For c1:=1 to E^.Point.Dat[c].Amount Do
     Begin
      If (E^.Point.Dat[c].MarketElement[c1].BAzKod=SArt) Then
      If (E^.Point.Dat[c].MarketElement[c1].Input.InputDiviSion=StrToInt(SOtd)) Then
        Begin{элемент не найден в списке}
         DelSpace(E^.Point.Dat[c].MarketElement[c1].Input.Kol);
         RFormat(E^.Point.Dat[c].MarketElement[c1].Input.Kol,CKOl);
         Format(E^.Point.Dat[c].Document,CKOl);
         sClient:=GetClientField(FClient,E^.Point.Dat[c].ClientKod,E^.Point.Dat[c].operatorSelector);
         Format(sClient,CClient);
         Writeln(txt,Space+'      Клиент:'+SClient+' '+E^.Point.Dat[c].ClientKod+' Заказ:'+
            E^.Point.Dat[c].Document+' Колич:'+E^.Point.Dat[c].MarketElement[c1].Input.Kol);
         Find:=True;
        End
     End;{For Amount}


    If Not Find Then
    For c1:=1 to E^.Point.Dat[c].AmountS Do
     Begin
      If (E^.Point.Dat[c].DocumentElement[c1].BAzKod=SArt) Then
      If (E^.Point.Dat[c].DocumentElement[c1].Input.InputDiviSion=StrToInt(SOtd)) Then
        Begin{элемент не найден в списке}
         DelSpace(E^.Point.Dat[c].DocumentElement[c1].Input.Kol);
         RFormat(E^.Point.Dat[c].DocumentElement[c1].Input.Kol,CKOl);
         Format(E^.Point.Dat[c].Document,CKOl);
         sClient:=GetClientField(FClient,E^.Point.Dat[c].ClientKod,E^.Point.Dat[c].operatorSelector);
         Format(sClient,CClient);
         Writeln(txt,Space+'      Клиент:'+SClient+' '+E^.Point.Dat[c].ClientKod+' Заказ:'+
            E^.Point.Dat[c].Document+' Колич:'+E^.Point.Dat[c].DocumentElement[c1].Input.Kol);
         Find:=True;
        End
     End;{For Amount}

  End;{DAteC}
End;{Oformlenie}

   End;{For Count}
End;{While}
System.Close(Sklf);
i:=IOResult;
Dispose(E,Done);
End;





Procedure TestComplect;
Var c,c1,FindOtd,Count : Word;
    StartDAte,StopDAte : TDAteString;
    Sklf : File;
    CCC,i : LongInt;
    star : TDAteSTring;
    NoScreenZakaz : PBox;
    Txt : Text;
    R : TRect;
    E : PBufZakazType;
    Start,Stop  : LongInt;
    s : String;
    SArt,SKol,SZena : TDAteString;
    Space,SSkladNAme,Summa,SItogo : AllStr;
    SFullName : String[CNAme+1+CNAme];
    SSKol,Delta,SOtd : TDateString;
    AllSumMinus,AllSumPlus,SSum : AllStr;
    Reg : Word;
    FindAuto : Boolean;
Begin
{вопрос относительно склада поставщика
 SelectOtkuda
  0:резервный
  1:кти
  2:сойфера
  3:зарезервировано
  4:отказ от расчета
  вопрос относительно даты доставки заказов}

 If EnableAverageOtdel=0 Then Exit;

 StartDate:=DateToDateString(DAteMask,DateStringToDAte(DAteMask,FDAte)+1);
 StopDate:=DateToDateString(DAteMask,DateStringToDAte(DAteMask,FDAte)+1);

 If Not NewDateDialog(StartDate) Then Exit;

 Reg:=SelectImport(25);

 If Reg=2 Then Exit;


 FindAuto:=FAlse;
 If MessageBox(^M+#3'Провести автоматический поиск связанных заказов для недостающего товара?',Nil,
 mfConfirmation+mfOkCAncel)=cmOk Then FindAuto:=True;



 StopDAte:=StartDAte;

 Start:=DateStringToDAte(DAteMask,StartDAte);
 Stop :=DateStringToDAte(DAteMask,StopDate);

Assign(Txt,Path^.Dat.ToMarket+'Zakaz.gid');
i:=IOResult;
Reset(Txt);
i:=IOResult;
If i<>0 Then
 BEgin
  MessageBox(^M+#3+'Ошибка открытия файла-маршрутизатора '+Path^.Dat.ToMarket+'Zakaz.gid',Nil,mfError+
  mfCancelButton);
 End
 Else
  Begin
   Readln(txt,Star);
   i:=IOResult;
   System.Close(Txt);
   i:=IOResult;
  End;


Assign(Sklf,Path^.DAt.ToMarket+'zakaz.db');
i:=IOResult;
Reset(Sklf,SizeOf(ZakazType));
i:=IOResult;
If I<>0 Then
 Begin
  MessageBox(^M+#3+'Ошибка открытия файла '+Path^.Dat.ToMarket+'Zakaz.db',Nil,mfError+
  mfCancelButton);
  Exit;
 End;

R.Assign(0, 0, 0, 0);
NoScreenZakaz := New(PBox, Init(R, 1, Nil));
NoScreenZakaz^.NewList(New(PTextCollection, Init(0,1)));




{формируем список забронированного товара по заказам}
If (StrToInt(Star)-10)>=0 Then
Begin
Seek(SklF,StrToInt(Star)-10);
Star:=IntToStr(StrToInt(Star)-10,CKOl);
End
Else
 Begin
  Seek(SklF,StrToInt(Star));
 End;

  New(E,Init);

While Not(Eof(Sklf)) Do
Begin

  DInfoMsgShkala('Проверяю комплектацию заказов, доставляемых '+StartDate+'...',0,
  FileSize(SklF)-StrToInt(Star),FilePos(SklF)-StrToInt(Star));

  ReadBufZakaz(Sklf,E,Count);

  For c:=1 To Count Do
   Begin
    {добавляем в список забронированный товар}
   If (E^.Point.Dat[c].Oformlenie=0)  Then
Begin
    E^.Point.Dat[c].DateC:=DateToDAteString(DateMask,
    DateStringToDate(DateMask,E^.Point.Dat[c].DateC)+E^.Point.Dat[c].EndDAte);

  If (DAteStringToDate(DateMask,E^.Point.Dat[c].DAteC)>=Start) And
     (DAteStringToDate(DateMask,E^.Point.Dat[c].DAteC)<=Stop) Then
  Begin

    s[0]:=#0;
    For c1:=1 to E^.Point.Dat[c].Amount Do
     Begin
      {If Not(E^.Point.Dat[c].MArketElement[c1].Input.InputDiviSion in SetEnableOtdel)Then}
   Begin
      {
      If E^.Point.Dat[c].MarketElement[c1].Input.InputDiviSion in [5,6,7,8] Then
      E^.Point.Dat[c].MarketElement[c1].Input.InputDiviSion:=1;
      }
      If(TestElementDivision(E^.Point.Dat[c].MarketElement[c1].BAzKod,
         IntToStr(E^.Point.Dat[c].MarketElement[c1].Input.InputDiviSion,COne),
                                                NoScreenZakaz)) Then
        Begin{элемент не найден в списке}
         DelSpace(E^.Point.Dat[c].MarketElement[c1].Input.Kol);
         RFormat(E^.Point.Dat[c].MarketElement[c1].Input.Kol,CKOl);

         s:='│'+E^.Point.Dat[c].MarketElement[c1].BAzKod+'│'+
               +IntToStr(E^.Point.Dat[c].MarketElement[c1].Input.InputDiviSion,COne)+'│'+
               +E^.Point.Dat[c].MarketElement[c1].Input.Kol;
        End
        Else {элемент найден в списке}
         Begin
         s:=NoScreenZakaz^.GetText(
            LocationWithDivision(NoScreenZakaz,E^.Point.Dat[c].MarketElement[c1].BAzKod,
            IntToStr(E^.Point.Dat[c].MarketElement[c1].Input.InputDiviSion,COne),False),
                  NoScreenZakaz^.List^.Count);
         sKol:=Copy(s,1+1+CArtikul+1+COne+1,CKol);
         Str(StrToInt(SKOl)+StrToInt(E^.Point.Dat[c].MarketElement[c1].Input.Kol):CKol,SKOl);
         SOtd:=Copy(s,1+1+CArtikul+1,COne);
         s:='│'+E^.Point.Dat[c].MarketElement[c1].BAzKod+'│'+
               +SOtd+'│'+SKol;

          NoScreenZakaz^.List^.AtFree(LocationWithDivision(NoScreenZakaz,E^.Point.Dat[c].MArketElement[c1].BAzKod,
            IntToStr(E^.Point.Dat[c].MArketElement[c1].Input.InputDiviSion,COne),False));
          NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);

         End;

        NoScreenZakaz^.List^.Insert(NewStr(s));
        NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
    End;
     End;{For Amount}



    {добавляем в список забронированные сертификаты}
    s[0]:=#0;
    For c1:=1 to E^.Point.Dat[c].AmountS Do
     Begin

      {If Not(E^.Point.Dat[c].DocumentElement[c1].Input.InputDiviSion in SetEnableOtdel)Then}
   Begin
      {
      If E^.Point.Dat[c].DocumentElement[c1].Input.InputDiviSion in [5,6,7,8] Then
      E^.Point.Dat[c].DocumentElement[c1].Input.InputDiviSion:=1;
      }
      If(TestElementDivision(E^.Point.Dat[c].DocumentElement[c1].BAzKod,
         IntToStr(E^.Point.Dat[c].DocumentElement[c1].Input.InputDiviSion,COne),
                                                NoScreenZakaz)) Then
        Begin{элемент не найден в списке}
         DelSpace(E^.Point.Dat[c].DocumentElement[c1].Input.Kol);
         RFormat(E^.Point.Dat[c].DocumentElement[c1].Input.Kol,CKOl);

         s:='│'+E^.Point.Dat[c].DocumentElement[c1].BAzKod+'│'+
               +IntToStr(E^.Point.Dat[c].DocumentElement[c1].Input.InputDiviSion,COne)+'│'+
               +E^.Point.Dat[c].DocumentElement[c1].Input.Kol;
        End
        Else {элемент найден в списке}
         Begin
         s:=NoScreenZakaz^.GetText(
            LocationWithDivision(NoScreenZakaz,E^.Point.Dat[c].DocumentElement[c1].BAzKod,
            IntToStr(E^.Point.Dat[c].DocumentElement[c1].Input.InputDiviSion,COne),False),
                  NoScreenZakaz^.List^.Count);
         sKol:=Copy(s,1+1+CArtikul+1+COne+1,CKol);
         Str(StrToInt(SKOl)+StrToInt(E^.Point.Dat[c].DocumentElement[c1].Input.Kol):CKol,SKOl);
         SOtd:=Copy(s,1+1+CArtikul+1,COne);
         s:='│'+E^.Point.Dat[c].DocumentElement[c1].BAzKod+'│'+
               +SOtd+'│'+SKol;
          NoScreenZakaz^.List^.AtFree(LocationWithDivision(NoScreenZakaz,E^.Point.Dat[c].DocumentElement[c1].BAzKod,
            IntToStr(E^.Point.Dat[c].DocumentElement[c1].Input.InputDiviSion,COne),False));
          NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
         End;

        NoScreenZakaz^.List^.Insert(NewStr(s));
        NoScreenZakaz^.SetRange(NoScreenZakaz^.List^.Count);
    End;
     End;{For Amount}

  End;{DAteC}
End;{Oformlenie}

   End;{For Count}
End;{While}

System.Close(Sklf);
i:=IOResult;
{закончили формировать список забронированного товара по заказам}
NoInfoMsg;

Dispose(E,Done);


Assign(Txt,Path^.Dat.ToTemp+'testgot.txt');
i:=IOResult;
Rewrite(Txt);
i:=IOResult;
If i<>0 Then
 BEgin
  Dispose(NoScreenZakaz,Done);
  MessageBox(^M+#3+'Ошибка создания '+Path^.Dat.ToTemp+'testgot.txt'+' Код:'+
  IntToStr(i,CMAntissa),Nil,mfError+
  mfCancelButton);
  Exit;
 End;

 Space:='';
 AllSumMinus:='0.00';
 AllSumPlus:='0.00';
 Writeln(txt,Header+Space+ 'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-01');
 Writeln(txt);

 Writeln(txt,Space+' АКТ РАЗНОГЛАСИЙ ПО КОМПЛЕКТАЦИИ ЗАКАЗОВ, подлежащих доставке клиенту '+StartDate);
 Write(txt,Space+'Вид отбора:');
 CAse Reg Of
 0:Writeln(txt,'Полный отчет');
 1:Writeln(txt,'Только дефицит');
 Else Writeln(txt);
 End;
 Writeln(txt,Space+'┌───┬─────┬──────────────────────────────────────────────┬──────┬─────┬─────┬─────┬──────────┐');
 Writeln(txt,Space+'│ N │ Код │Наименование товара                           │      │Колич│Колич│Delta│  E Delta │');
 Writeln(txt,Space+'│   │     │                                              │     N│Заказ│Склад│     │          │');
 Writeln(txt,Space+'└───┴─────┴──────────────────────────────────────────────┴──────┴─────┴─────┴─────┴──────────┘'+
 HeaderStop);

                   {123│12345│1234567890123456789012345612345678901234567890123456│1│12345│12345│12345│1234567890}

 SItogo[0]:=#0;
 CCC:=0;
 {MemC(IntToSTr(Reg,COne));}

 {вставить сортировку}
(*
 If NoScreenZakaz^.List^.Count-1>=0 Then
 For c:=0 To NoScreenZakaz^.List^.Count-1 Do
  Begin
   DInfoMsgShkala('Анализирую складские остатки ...',0,NoScreenZakaz^.List^.Count-1,c);
   s := NoScreenZakaz^.GetText(c, NoScreenZakaz^.List^.Count);
   SKol:=Copy(s,1+1+CArtikul+1+COne+1,CKol+1);{количество}
   SArt:=Copy(s,1+1,CArtikul);{код}
   SOtd:=Copy(s,1+1+CArtikul+1,COne);{количество}
   SFullNAme:=GetIdField(FFFNAme,SArt);
   Format(SFullNAme,CNAme+1+CNAme);
   RFormat(s,CLitrMAntissa);
   SSKol:=BakGetField(FDiv,SArt,StrToInt(SOtd));
   DelSpace(Skol);
   RFormat(SKOl,CKol);
   DelSpace(SSkol);
   RFormat(SSKOl,CKol);
   Delta:=IntToStr(StrToInt(SKol)-StrToInt(SSKol),CKol);

   If (Reg=0) Or ((Reg=1)And(StrToInt(Delta)>0)) Then
   Begin
    INC(CCC);
    S:=IntToStr(CCC,CLitrMAntissa);
    DelSPace(s);
    RFormat(s,3);
    DelSpace(Delta);
    RFormat(Delta,CKol);
    MyStr(StrToREal(BakGetField(FRZena,SArt,0))*StrToInt(Delta),CZenaZ,CZena,SSum);

    If StrToReal(SSum)>0 Then
    MyStr(StrToReal(AllSumPlus)+StrToReal(SSum),CIZena,CMantissa,AllSumPlus)
    Else
    MyStr(StrToReal(AllSumMinus)+StrToReal(SSum),CIZena,CMantissa,AllSumMinus);

    If c <> NoScreenZakaz^.List^.Count-1 Then
    Writeln(txt,Space+s+' '+SArt+' '+SFullName+SOtd+' '+SKol+' '+SSKol+' '+Delta+' '+SSum)
    Else
    Writeln(txt,Space+OnlyLink+s+' '+SArt+' '+SFullName+SOtd+' '+SKol+' '+SSKol+' '+Delta+' '+SSum);

     If StrToInt(Delta)>0 Then
      Begin
       If FindAuto Then
       FindBron(Space,StartDate,SArt,SOtd,txt);
      End;

   End;
  End;
*)

 SortZakazList(NoScreenZakaz);


 If NoScreenZakaz^.List^.Count-1>=0 Then
 For c:=0 To NoScreenZakaz^.List^.Count-1 Do
  Begin
   DInfoMsgShkala('Формирую отчет ...',0,NoScreenZakaz^.List^.Count-1,c);
   s := NoScreenZakaz^.GetText(c, NoScreenZakaz^.List^.Count);
   SKol:=Copy(s,1+CArtikul+1+(CNAme+1+CNAme)+1+COne+1,CKol);{количество}
   SSKol:=Copy(s,1+CArtikul+1+(CNAme+1+CNAme)+1+COne+1+(CKol)+1,CKol);{количество}
   SArt:=Copy(s,1,CArtikul);{код}
   SOtd:=Copy(s,1+CArtikul+1+(CNAme+1+CNAme)+1,COne);{количество}
   Delta:=IntToStr(StrToInt(SKol)-StrToInt(SSKol),CKol);
   SSum:=Copy(s,1+CArtikul+1+(CNAme+1+CNAme)+1+COne+1+(CKol)+1+CKol+1+CKOl+1,CZenaZ);{количество}

   If (Reg=0) Or ((Reg=1)And(StrToInt(Delta)>0)) Then
   Begin
    INC(CCC);
    sSKol:=IntToStr(CCC,CLitrMAntissa);
    DelSPace(sSKol);
    RFormat(sSKol,3);
    DelSpace(Delta);
    RFormat(Delta,CKol);

    If StrToReal(SSum)>0 Then
    MyStr(StrToReal(AllSumPlus)+StrToReal(SSum),CIZena,CMantissa,AllSumPlus)
    Else
    MyStr(StrToReal(AllSumMinus)+StrToReal(SSum),CIZena,CMantissa,AllSumMinus);

    If c <> NoScreenZakaz^.List^.Count-1 Then
    Writeln(txt,Space+sSKol+SeparatorChar+s)
    Else
    Writeln(txt,Space+OnlyLink+SSKol+SeparatorChar+s);

     If StrToInt(Delta)>0 Then
      Begin
       If FindAuto Then
       FindBron(Space,StartDate,SArt,SOtd,txt);
      End;
   End;
  End;




 MyStr(StrToReal(SItogo),CIZena,CMantissa,SItogo);
 Writeln(txt,Space+'─────────────────────────────────────────────────────────────────────────────────────────────');
 Writeln(txt,Space+'Всего позиций:'+SeparatorChar,CCC:CKol);
 Writeln(txt,Space+'Всего дефицит:'+SeparatorChar,AllSumPlus);
 Writeln(txt,Space+'Всего избыток:'+SeparatorChar,AllSumMinus);
 Writeln(txt);
 Writeln(txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(txt,Space+'=============================================================================================');

 i:=IOResult;
 System.Close(txt);
 i:=IOResult;
 Dispose(NoScreenZakaz,Done);
 AddProtocol('Формирование акта разногласий по комплектации заказов, подлежащимих доставке клиенту '+
 StartDate,'','');
 NoInfoMsg;
 ViewAsText(Path^.Dat.ToTemp+'testgot.txt','Акт разногласий по заказам,доставляемым  '+StartDate,True);
 {ReportNew(Path^.Dat.ToTemp+'testgot.txt','',1,False,False);}
End;




Function LockAndWriteKassa( Var L:PDayKassaType) : Boolean;
Var DayKassaFile : DayKassaFileType;
     c : Byte;
     ChangeNumer : Boolean;
     Pos1 : LongInt;
Begin
 LockAndWriteKassa:=False;
 Assign(DayKassaFile,Path^.Dat.ToClient+L^.Dat.DateC+'.kas');
 c:=IOResult;
{$I-}
 Reset(DayKassaFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox('Файл '+L^.Dat.DateC+'.kas не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil, mfConfirmation + mfOkCancel)=cmOk Then
     Begin
{      c:=IOResult;
      Reset(DayKassaFile);
      c:=IOResult;
      If c<>0 Then Rewrite(DayKassaFile);}
      If Not(CreatToDayF(DocKassa,L^.Dat.DateC)) Then Exit;
      Reset(DayKassaFile);
      c:=IOResult;
     End
    Else
     Begin
      Exit;
     End;
 End;
 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу '+L^.Dat.DateC+'.kas!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;

     {запись прихода для случая формирования накладной}

     DInfoNetMsg('Сохраняю кассовую операцию N '+L^.Dat.Document+' от '+L^.Dat.Datec+'...');

    ChangeNumer:=False;

     Repeat
     Until LockAppendBase(NetlockKassa,False);

    Repeat

     Repeat {блокируем участок записи}
      Pause(1);
      Pos1:=FileSize(DayKassaFile);
      Seek(DayKassaFile,Pos1);
     Until (Lock(DayKassaFile,FilePos(DayKassaFile)*SizeOf(DayKassaType),SizeOf(DayKassaType)*ComputersKol));

      Pos1:=FileSize(DayKassaFile);

     If FilePos(DayKassaFile)<>Pos1{FileSize(DayKassaFile)} Then
      Begin
       Repeat {деблокируем участок записи}
        Pause(1);
        UnLock(DayKassaFile,(FilePos(DayKassaFile))*SizeOf(DayKassaType),SizeOf(DayKassaType)*ComputersKol);
       Until (DosError=0);
      End;

    Until (FilePos(DayKassaFile)=Pos1{FileSize(DayKassaFile)});

     L^.Dat.Locked:=False;
     L^.Dat.LockCaption:=CurrentPassword;
     L^.Dat.LockTime:=CurrentTime;
     L^.Dat.ComputerNameLocked:=NetComputerName;

     If (({FileSize(DayKassaFile)}Pos1+1)<>(StrToInt(L^.Dat.Document))) Then
     Begin
      ChangeNumer:=True;
         L^.Dat.Document:=IntToStr({FileSize(DayKassaFile)}Pos1+1,CDocNumer);
      DelSpace(L^.Dat.Document);
     End;

     Write(DayKassaFile,L^.DAt);
     Seek(DayKassaFile,FilePos(DayKassaFile)-1);
     NoNetInfoMsg;

     DInfoMsg('Деблокирую запись в файле кассовых операций...',False);

     Repeat {деблокируем участок записи}
      Pause(1);
      UnLock(DayKassaFile,(FilePos(DayKassaFile))*SizeOf(DayKassaType),
         SizeOf(DayKassaType)*ComputersKol);
     {If DosError<>0 Then
       MessageBox(#3+'DosError='+IntToStr(DosError,3),Nil,
          mfError+mfCancelButton);}
     Until (DosError=0);
     Close(DayKassaFile);

     LockAndWriteKassa:=True;
     NoInfoMsg;

     AddProtocol('Добавление кассовой операции '+L^.DAt.Document+
	' успешно завершено {протокол сетевых блокировок}','{кассовые операции}','');

     Repeat
     Until UnLockAppendBase(NetlockKassa,False);

     If ChangeNumer Then
     Begin
      If (ShowNumer=1) Then
       Begin
       MessageBox(#3+'За время формирования Вами кассовой операции проведены другие '+
          'операции. Присваиваю документу новый номер: '+L^.Dat.Document+'!',
                Nil,mfInformation+mfCancelButton);
       End;
     End;
End;

Function LockKassa(As : DocumentEditZ;Var E:PDayKassaType):Word;
Var C : Byte;
    Find : Boolean;
    DayKassaFile : DayKassaFileType;
    Code : InTeger;
    Pos : LongInt;
Begin
  LockKassa:=4;
  C:=IOResult;
  Assign(DayKassaFile,Path^.Dat.ToClient+As.D+'.kas');
  Reset(DayKassaFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия файла кассовых операций за '+As.D+'!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    C:=IOResult;
    LockKassa:=4;
    Exit;
   End;

   Seek(DayKassaFile,0);

   DelSpace(As.EditPosition);
   DelSpace(As.D);
   DelZerro(As.EditPosition);
   As.EditPosition:=ClearChar(As.EditPosition);
   Find:=False;

   {цикл поиска накладной}
   While Not(eof(DayKassaFile)) And Not(Find) Do
    Begin
     {
     Repeat
     Pause(1);
     Until Lock(PrihodFile,FilePos(PrihodFile)*SizeOf(PrihodType),SizeOf(PrihodType));
     }
     ReadDayKassa(DayKassaFile,E^.Dat);
     {
     Repeat
      UnLock(PrihodFile,(FilePos(PrihodFile)-1)*SizeOf(PrihodType),SizeOf(PrihodType));
     Until (DosError=0);
     }
     DelSpace(E^.DAt.Document);
     DelZerro(E^.Dat.Document);
     If (StrToInt(E^.DAt.Document)=StrToInt(As.EditPosition)) And (E^.DAt.DateC=As.D) Then Find:=True;
    End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      LockKassa:=2;
      Close(DayKassaFile);
      MessageBox(#3^M+#3'Документ N '+ As.EditPosition+' в базе за '+As.D+' не найден!',Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}

   DInfoNetMsg('Блокирую кассовую операцию N '+E^.Dat.Document+' от '+E^.Dat.DateC+'...');
   LockKassa:=3;
   Seek(DayKassaFile,FilePos(DayKassaFile)-1);

   Repeat
   Pause(1);
   Until Lock(DayKassaFile,FilePos(DayKassaFile)*SizeOf(DayKassaType),SizeOf(DayKassaType));
   Read(DayKassaFile,E^.Dat);

   {если документ уже заблокирован}
   If (E^.Dat.Locked) Then
    Begin
     NoNetInfoMsg;
     LockKassa:=3;
     {снятие предварительной блокировки}
     Seek(DayKassaFile,FilePos(DayKassaFile)-1);
     Repeat
      UnLock(DayKassaFile,FilePos(DayKassaFile)*SizeOf(DayKassaType),SizeOf(DayKassaType))
     Until Doserror=0;
     Close(DayKassaFile);
     Exit;
    End;

   {проведение вторичной блокировки}
{$IFDEF NetVersion}
   E^.DAt.Locked:=True;
   E^.Dat.LockCaption:=CurrentPassword;
   E^.Dat.LockTime:=CurrentTime;
   E^.Dat.ComputerNameLocked:=NetComputerName;
{$ENDIF}

   Seek(DayKassaFile,FilePos(DayKassaFile)-1);
   Write(DayKassaFile,E^.DAt);
   Seek(DayKassaFile,FilePos(DayKassaFile)-1);

   Repeat
    Pause(1);
    UnLock(DayKassaFile,FilePos(DayKassaFile)*SizeOf(DayKassaType),SizeOf(DayKassaType));
   Until Doserror=0;

   LockKassa:=0;
   NoNetInfoMsg;
   C:=IOResult;
   Close(DayKassaFile);
   C:=IOResult;
End;


Function UnLockKassa(Doc:ArtikulStr;DD: TDateString):Word;
Var C : Byte;
    Find : Boolean;
    DayKassaFile : DayKassaFileType;
    Test : PDayKassaType;

Begin
  UnLockKassa:=3;
  C:=IOResult;
  Assign(DayKassaFile,Path^.Dat.ToClient+DD+'.kas');
  Reset(DayKassaFile);
  C:=IOResult;
  If C<>0 Then
   Begin
    MessageBox(^M+#3'Ошибка сетевого открытия Файла кассовых операций за '+DD+'!'+
    +' Код:'+IntToStr(c,3),Nil,mfError+mfCancelButton);
    UnLockKassa:=3;
    C:=IOResult;
    Exit;
   End;

   Seek(DayKassaFile,0);

   DelSpace(Doc);
   DelSpace(DD);
   DelZerro(Doc);
   Find:=False;

   New(Test,Init);
   {цикл поиска накладной}
   While Not(eof(DayKassaFile)) And Not(Find) Do
    Begin
     {
     Repeat
     Pause(1);
     Until Lock(DayKassaFile,FilePos(DayKassaFile)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     }
     ReadDayKassa(DayKassaFile,Test^.DAt);
     {
     Repeat
      UnLock(DayKassaFile,(FilePos(DayKassaFile)-1)*SizeOf(NewVozwratType),SizeOf(NewVozwratType));
     Until (DosError=0);
     }
     DelSpace(Test^.DAt.Document);
     DelZerro(Test^.Dat.Document);
     If (Test^.DAt.Document=Doc) And (TEST^.DAt.DateC=DD) Then Find:=True;
    End;

  {если накладная не найдена}
   If Not(Find) Then
    Begin
      Dispose(test,Done);
      UnLockKassa:=2;
      Close(DayKassaFile);
      MessageBox(#3^M+#3'Документ N '+ Doc+' в базе за '+DD+' не найден!',
         Nil,mfError+mfCancelButton);
      Exit;
    End;

 {предварительная блокировка}

   DInfoNetMsg('Деблокирую кассовую операцию N '+Doc+' от '+DD+'...');
   UnLockKassa:=1;
   Seek(DayKassaFile,FilePos(DayKassaFile)-1);

 If Lock(DayKassaFile,FilePos(DayKassaFile)*SizeOf(DayKassaType),SizeOf(DayKassaType)) Then
 Begin
   Read(DayKassaFile,Test^.Dat);
   {проведение вторичной блокировки}
   Test^.DAt.Locked:=False;
   Seek(DayKassaFile,FilePos(DayKassaFile)-1);
   Write(DayKassaFile,Test^.DAt);
   Seek(DayKassaFile,FilePos(DayKassaFile)-1);
   Repeat
    UnLock(DayKassaFile,FilePos(DayKassaFile)*SizeOf(DayKassaType),SizeOf(DayKassaType))
   Until Doserror=0;
   UnLockKassa:=0;
   NoNetInfoMsg;
   Close(DayKassaFile);
   Dispose(Test,Done);
 End
   Else
      Begin
       NoNetInfoMsg;
       UnLockKassa:=1;
       Close(DayKassaFile);
       Dispose(Test,Done);
      End;
End;



Function LockAndWriteKassaOutEdit(Var L:PDayKassaType):Boolean;
Var DayKassaFile : DayKassaFileType;
    c : Byte;
    ChangeNumer,Find : Boolean;
    Test : PDayKassaType;
    Pos1,pos2,Pos,Code : LongInt;
Begin
 LockAndWriteKassaOutEdit:=False;
 Assign(DayKassaFile,Path^.Dat.ToClient+L^.Dat.DateC+'.kas');
 c:=IOResult;
{$I-}
 Reset(DayKassaFile);
 c:=IOResult;
If c<>0 Then
 Begin
  If MessageBox('Файл '+L^.Dat.DateC+'.kas не существует !'^M+
     'Создать такой файл ?'+' Код:'+IntToStr(c,3),nil,
        mfConfirmation + mfOkCancel)=cmOk  Then
     Begin
{     c:=IOResult;
      Reset(DayKassaFile);
      c:=IOResult;
      If c<>0 Then Rewrite(DayKassaFile);}
      If Not(CreatToDayF(DocKassa,L^.Dat.DateC)) Then Exit;
      Reset(DayKassaFile);
      c:=IOResult;
     End
    Else
     Begin
      Exit;
     End;
 End;
 If c <> 0 Then Begin
                 MessageBox(#3^M+#3'Нет доступа к файлу '+L^.Dat.DateC+'.kas!',
                 nil, mfError + mfOkButton);
                 Exit;
                End;

{если открытие прошло нормально}
     {создаем новый экземпляр прихода}
     New(test,Init);
     Find := False;
     DelSPace(L^.DAt.Document);
     DelSPace(L^.DAt.DAteC);
     DelSPace(L^.DAt.SkladKod);
     {цикл поиска исходного документа в файле}
     While Not(Eof(DayKassaFile)) And Not(Find) Do
      Begin
       ReadDayKassa(DayKassaFile,Test^.Dat);
       DelSpace(Test^.Dat.Document);
       DelSpace(Test^.Dat.DateC);
       DelSpace(Test^.Dat.SkladKod);
       If (Test^.Dat.Document=L^.DAt.Document) And
          (Test^.Dat.DateC=L^.DAt.DateC) And
          (Test^.Dat.SkladKod=L^.DAt.SkladKod) Then Find:=True;
      End;
      Dispose(Test,Done);

     {если документ не найден тогда выходим с сообщением}
     If Not(Find) Then
      Begin
       Close(DayKassaFile);
       MessageBox(#3^M+#3'Документ N '+ L^.Dat.Document+' в базе за '+L^.DAt.DAteC+' не найден!',Nil,
          mfError+mfCancelButton);
       Exit;
      End;

     DInfoNetMsg('Изменяю кассовую операцию N '+L^.Dat.Document+' от '+L^.Dat.Datec+'...');
     {если мы нашли документ тогда блокируем его и записываем}
     Seek(DayKassaFile,FilePos(DayKassaFile)-1);
     {блокировка}
     Repeat
      Pause(1);
     Until (Lock(DayKassaFile,FilePos(DayKassaFile)*SizeOf(DayKassaType),SizeOf(DayKassaType)));
     {запись}

{$IFDEF NetVersion}
     L^.Dat.Locked:=False;
     L^.Dat.LockCaption:=CurrentPassword;
     L^.Dat.LockTime:=CurrentTime;
     L^.Dat.ComputerNameLocked:=NetComputerName;
{$ENDIF}

     Write(DayKassaFile,L^.DAt);
     NoNetInfoMsg;
     DInfoMsg('Деблокирую запись в файле кассовых операций...',False);
     {снятие блокировки}
     Seek(DayKassaFile,FilePos(DayKassaFile)-1);
     Repeat
      Pause(1);
      UnLock(DayKassaFile,FilePos(DayKassaFile)*SizeOf(DayKassaType),SizeOf(DayKassaType));
     Until (DosError=0);
     Close(DayKassaFile);
     LockAndWriteKassaOutEdit:=True;
     NoInfoMsg;
End;






begin

End.