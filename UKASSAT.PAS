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
  MessageBox(^M+#3+'Не могу открыть файл!'+^M+#3+'('+IntToSTr(c,3)+')'
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
    MessageBox(^M+#3+'Ошибка чтения файла кассы за '+Data,Nil,mfError+mfCancelButton);
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
  MessageBox(^M+#3+'Не могу создать файл отчета!'+^M+#3+'('+IntToSTr(c,3)+')',Nil,mfError+mfCancelButton);
  Exit;
  End;

Kassa^.FormatReal;

s:=FormKod(Rek^.Dat.Kod);
s:=GetClientField(FClient,s,1);
DelSpaceLeftRight(s);


  Writeln(txt{,Bold[NPrint^.DAt.Printer]+Double[Nprint^.DAt.Printer]});
  Writeln(txt,Space+SeparatorChar+'       КОНТРОЛЬНЫЙ КАССОВЫЙ ЛИСТ СКЛАДА "'+s+'" ЗА '+DAta);
  Writeln(txt);
  Writeln(txt,Space+SeparatorChar+'    Заполнил:'+GetOperatorField(FNAme,Kassa^.DAt.CAption));
  Writeln(Txt);

With Kassa^.Dat Do
Begin
Writeln(txt,Space+'      Суточный отчет по ККМ                                       : ',SeparatorChar+
Recogniz(ReportKassa)+SeparatorChar);
Writeln(txt,Space+'    1.Сумма в кассе                                               : ',SeparatorChar+
Recogniz(SummaInKassa)+SeparatorChar);
Writeln(txt,Space+'    2.Остаток в кассе                                             : ',SeparatorChar+
Recogniz(OstatokInKassa)+SeparatorChar);
Writeln(txt,Space+'    3.Сдано                                                       : ',SeparatorChar+
Recogniz(Sdano)+SeparatorChar);
Writeln(txt,Space+'    4.Дополнительный доход                                        : ',SeparatorChar+
Recogniz(ExtendedDohod)+SeparatorChar);
Writeln(txt,Space+'    5.Расходы                                                     : ',SeparatorChar+
Recogniz(Rashod)+SeparatorChar);
{Writeln(txt,Space+'    6.Сертификаты                                                 : ',SeparatorChar+
Recogniz(Sertifikat)+SeparatorChar);}

Sho:=False;
If Password(5) Then Sho:=True;

If Sho Then
 Begin
Writeln(txt,Space+'    6.Доход по итогам торгового дня                               : ',SeparatorChar+
Recogniz(DohodAll)+SeparatorChar);
Writeln(txt,Space+'    7.Доход по итогам торгового дня (торговые представители)      : ',SeparatorChar+
Recogniz(DohodAgent)+SeparatorChar);
Writeln(txt,Space+'    8.Доход по итогам торгового дня (сертификаты)                 : ',SeparatorChar+
Recogniz(DohodSertif)+SeparatorChar);
 End;

Writeln(txt,Space+'    9.Приход на склад от клиента                                  : ',SeparatorChar+
Recogniz(Prihod)+SeparatorChar);
Writeln(txt,Space+'   10.Остаток на складе                                           : ',SeparatorChar+
Recogniz(Ostatok)+SeparatorChar);
Writeln(txt,Space+'   11.РП работы                                                   : ',SeparatorChar+
Recogniz(RP)+SeparatorChar);
Writeln(txt,Space+'   12.РП работы (сертификаты)                                     : ',SeparatorChar+
Recogniz(SertifRP)+SeparatorChar);
Writeln(txt,Space+'   13.Сумма со склада                                             : ',SeparatorChar+
Recogniz(SummaOutSklad)+SeparatorChar);
Writeln(txt,Space+'   14.Выдано без отсрочки платежа (Т)                             : ',SeparatorChar+
Recogniz(Prodagi)+SeparatorChar);
Writeln(txt,Space+'   15.Скидки выдачи без отсрочки платежа                          : ',SeparatorChar+
Recogniz(SkProdagi)+SeparatorChar);
Writeln(txt,Space+'   16.Выдано сертификатов без отсрочки платежа (Т)                : ',SeparatorChar+
Recogniz(SertifProdagi)+SeparatorChar);
Writeln(txt,Space+'   17.Скидки выдачи сертификатов без отсрочки платежа             : ',SeparatorChar+
Recogniz(SertifSkProdagi)+SeparatorChar);
Writeln(txt,Space+'   18.Выдано на консигнацию (Т)                                   : ',SeparatorChar+
Recogniz(VidanoConsig)+SeparatorChar);
Writeln(txt,Space+'   19.Скидки выданной консигнации                                 : ',SeparatorChar+
Recogniz(SkVidanoConsig)+SeparatorChar);
Writeln(txt,Space+'   20.Оплата консигнации в кассу                                  : ',SeparatorChar+
Recogniz(OplataInKassa)+SeparatorChar);
Writeln(txt,Space+'   21.Скидки оформленной консигнации                              : ',SeparatorChar+
Recogniz(SkOformConsign)+SeparatorChar);
Writeln(txt,Space+'   22.Возврат по открытой консигнации (Т)                         : ',SeparatorChar+
Recogniz(ReturnOutOpenConsig)+SeparatorChar);
Writeln(txt,Space+'   23.Скидки возврата по открытой консигнации                     : ',SeparatorChar+
Recogniz(SkReturnOutOpenConsig)+
SeparatorChar);
Writeln(txt,Space+'   24.Возврат по документам продажи и закрытой консигнации (Т)    : ',SeparatorChar+Recogniz
(ReturnOutMArketDocAndCloseConsig)+
SeparatorChar);
Writeln(txt,Space+'   25.Скидки возврата по документам продажи и закрытой консигнации: ',SeparatorChar+Recogniz
(SkReturnOutMArketDocAndCloseConsig)+SeparatorChar);
Writeln(txt,Space+'   26.Остаток консигнации (Т)                                     : ',SeparatorChar+
Recogniz(OstatokConsig)+SeparatorChar);
Writeln(txt,Space+'   27.Скидки остатка консигнации                                  : ',SeparatorChar+
Recogniz(SkOstatokConsig)+SeparatorChar);
Writeln(txt,Space+'   28.Переоценка                                                  : ',SeparatorChar+
Recogniz(Pereozenka)+SeparatorChar);
Writeln(txt,Space+'   29.Переоценка по возврату                                      : ',SeparatorChar+
Recogniz(PereozenkaFromReturn)+SeparatorChar);
Writeln(txt,Space+'   30.Расходы по возврату                                         : ',SeparatorChar+
Recogniz(RashodFromReturn)+SeparatorChar);
Writeln(txt,Space+'   31.Расходы по возврату открытой консигнации                    : ',SeparatorChar
+Recogniz(RashodFromReturnOpenConsig)+SeparatorChar);
Writeln(txt,Space+'   32.Сумма по выданным С/Ф                                       : ',SeparatorChar+
Recogniz(VidanoSF)+SeparatorChar);
Writeln(txt,Space+'   33.Ревизия на складе                                           : ',SeparatorChar+Recogniz(Rewisia)+
SeparatorChar);
Writeln(txt,Space+'   34.Сбор НП по отгрузке клиенту без отсрочки платежа            : ',SeparatorChar+Recogniz(SNAlogP)+
SeparatorChar);
Writeln(txt,Space+'   35.Сбор НП по отгрузке клиенты на консигнацию                  : ',SeparatorChar+Recogniz(SNAlogC)+
SeparatorChar);
Writeln(txt,Space+'   36.НП по возврату отрытой консигнации                          : ',SeparatorChar
+Recogniz(SNAlogReturnOpenConsig)+SeparatorChar);
Writeln(txt,Space+'   37.Сальдо по взаимозачетам                                     : ',SeparatorChar+
Recogniz(OstatokBarter)+SeparatorChar);
Writeln(txt,Space+'   38.Приход в счет взаимозачета по З/Ц                           : ',SeparatorChar+Recogniz(BarterPrihod)+
SeparatorChar);
Writeln(txt,Space+'   39.Приход на склад в счет взаимозачета по Р/Ц                  : ',SeparatorChar+
Recogniz(BarterPrihodRZ)+SeparatorChar);
Writeln(txt,Space+'   40.Выдано клиентам в счет взаимозачета  (Т)                    : ',SeparatorChar+Recogniz(BarterT)+
SeparatorChar);
Writeln(txt,Space+'   41.Скидки выдачи клиентам в счет взаимозачета                  : ',SeparatorChar+Recogniz(BarterSkidki)+
SeparatorChar);
Writeln(txt,Space+'   42.Выдано сертификатов клиентам в счет взаимозачета  (Т)       : ',SeparatorChar+Recogniz(SertifBarterT)+
SeparatorChar);
Writeln(txt,Space+'   43.Скидки выдачи сертификатов клиентам в счет взаимозачета     : ',SeparatorChar+
Recogniz(SertifBarterSkidki)+SeparatorChar);
Writeln(txt,Space+'   44.Поступления в кассу в счет взаимозачета                     : ',SeparatorChar+Recogniz(BarterInKassa)+
SeparatorChar);
Writeln(txt,Space+'   45.Расход из кассы в счет взимозачета                          : ',SeparatorChar+Recogniz(BarterOutKassa)
+SeparatorChar);


 {38}

Writeln(txt,Space+'   46.Безналичные оплаты консигнации                              : ',SeparatorChar+
Recogniz(BNOPlataConsig));
Writeln(txt,Space+'   47.Безналичные оплаты товара без отсрочки платежа              : ',SeparatorChar+Recogniz(BNProdagi));
Writeln(txt,Space+'   48.Безналичные поступления в счет взаимозачета                 : ',SeparatorChar+
Recogniz(BNBarterInKassa));
Writeln(txt,Space+'   49.Безналичные расходы в счет взаимозачета                     : ',SeparatorChar+
Recogniz(BNBarterOutKassa));
Writeln(txt,Space+'   50.Остаток переплат клиентов за наличный расчет                : ',SeparatorChar+
Recogniz(OstatokPereplatN));
Writeln(txt,Space+'   51.Остаток переплат клиентов за безналичный расчет             : ',SeparatorChar+
Recogniz(OstatokPereplatB));
Writeln(txt,Space+'   52.Остаток переплат клиентов по векселям                       : ',SeparatorChar+
Recogniz(OstatokPereplatV));
Writeln(txt,Space+'   53.Поступления в счет переплат клиентов за наличный расчет     : ',SeparatorChar+Recogniz(NewPereplatN));
Writeln(txt,Space+'   54.Поступления в счет переплат клиентов за безналичный расчет  : ',SeparatorChar+Recogniz(NewPereplatB));
Writeln(txt,Space+'   55.Поступления в счет переплат клиентов за вексельный расчет   : ',SeparatorChar+Recogniz(NewPereplatV));
Writeln(txt,Space+'   56.Расход наличных переплат клиентов                           : ',SeparatorChar+
Recogniz(RashodPereplatN));
Writeln(txt,Space+'   57.Расход безналичных переплат клиентов                        : ',SeparatorChar+
Recogniz(RashodPereplatB));
Writeln(txt,Space+'   58.Расход вексельных переплат клиентов                         : ',SeparatorChar+
Recogniz(RashodPereplatV));

Writeln(txt,Space+'   59.Остаток акциза на складе                                    : ',SeparatorChar+Recogniz(OstatokAkzis));
Writeln(txt,Space+'   60.Акцизный сбор по документам без отсрочки платежа            : ',SeparatorChar+
Recogniz(ProdagiCAkzis));
Writeln(txt,Space+'   61.Акцизный сбор по межскладским перевозкам                    : ',SeparatorChar+
Recogniz(ProdagiSAkzis));
Writeln(txt,Space+'   62.Акцизный сбор по документам отгрузки в счет взаимозачета    : ',SeparatorChar+
Recogniz(ProdagiBAkzis));
Writeln(txt,Space+'   63.Акцизный сбор по документам, выданным на консигнацию        : ',SeparatorChar+
Recogniz(VidanoConsigAkzis));
Writeln(txt,Space+'   64.Акцизный сбор по документам оформленной консигнации         : ',SeparatorChar+
Recogniz(OformlenoConsigAkzis));
Writeln(txt,Space+'   65.Акцизный сбор по документам прихода от клиента              : ',SeparatorChar+Recogniz(PrihodCAkzis));
Writeln(txt,Space+'   66.Акцизный сбор по документам межскладского прихода           : ',SeparatorChar+Recogniz(PrihodSAkzis));
Writeln(txt,Space+'   67.Акцизный сбор по документам прихода в счет взаимозачета     : ',SeparatorChar+Recogniz(PrihodBAkzis));
Writeln(txt,Space+'   68.Акцизный сбор по документам возврата от клиента             : ',SeparatorChar+Recogniz(ReturnCAkzis));
Writeln(txt,Space+'   69.Акцизный сбор по документам межскладского возврата          : ',SeparatorChar+Recogniz(ReturnSAkzis));
Writeln(txt,Space+'   70.Акцизный сбор по документам ревизии                         : ',SeparatorChar+Recogniz(RevisiaAkZis));





For c:=1 To Max30 Do
Begin
Str(c:CClientKod,s);
s:=GEtClientField(FClient,s,1);
DelSpaceLeftRight(s);
Format(s,CClient);
If Abs(StrToReal(PerewoskiOut[c]))>0.009 Then
Writeln(txt,Space,'  ',c+{58}70:3,'.Перевозки со склада на '+s+'                 : ',SeparatorChar+
Recogniz(PerewoskiOut[c])+SeparatorChar);
End;

For c:=1 To 30 Do
Begin
Str(c:CClientKod,s);
s:=GEtClientField(FClient,s,1);
DelSpaceLeftRight(s);
Format(s,CClient);
If Abs(StrToReal(PerewoskiInp[c]))>0.009 Then
Writeln(txt,Space,'  ',c+100{73}:3,'.Перевозки на склад  с  '+s+'                 : ',SeparatorChar+Recogniz(PerewoskiInp[c])+
SeparatorChar);
End;

Writeln(txt,Space+'  131.Итого перевозки со склада                                   : ',SeparatorChar+
Recogniz(EPerewoskiOut)+SeparatorChar);
Writeln(txt,Space+'  132.Итого перевозки на склад                                    : ',SeparatorChar+
Recogniz(EPerewoskiInp)+SeparatorChar);

If Sho Then
 Begin
Writeln(txt,Space+'  133.Остаток на складе по З/Ценам                                : ',SeparatorChar+
Recogniz(OstatokZ)+SeparatorChar);
Writeln(txt,Space+'  134.Остаток консигнации по разделам                             : ',SeparatorChar+
Recogniz(OstatokConsigZ)+SeparatorChar);
Writeln(txt,Space+'  135.Приход на склад от клиента по З/Ценам                       : ',SeparatorChar+
Recogniz(PrihodZC)+SeparatorChar);
Writeln(txt,Space+'  136.Приход на склад в счет взаимозачета по З/Ценам              : ',SeparatorChar+
Recogniz(PrihodZB)+SeparatorChar);

Writeln(txt,Space+'  137.Отгрузка клиенту по З/Ценам                                 : ',SeparatorChar+
Recogniz(OtgruzkaZC)+SeparatorChar);
Writeln(txt,Space+'  138.Отгрузка в счет взаимозачета по З/Ценам                     : ',SeparatorChar+
Recogniz(OtgruzkaZB)+SeparatorChar);
Writeln(txt,Space+'  139.РП работы по З/Ценам                                        : ',SeparatorChar+
Recogniz(OtgruzkaZRP)+SeparatorChar);

Writeln(txt,Space+'  140.Итого перевозки со склада по З/Ценам                        : ',SeparatorChar+
Recogniz(OtgruzkaZS)+SeparatorChar);
Writeln(txt,Space+'  141.Итого перевозки на склад по З/Ценам                         : ',SeparatorChar+
Recogniz(PrihodZS)+SeparatorChar);

Writeln(txt,Space+'  142.Ревизия на складе по З/Ценам                                : ',SeparatorChar+
Recogniz(RewisiaZ)+SeparatorChar);
Writeln(txt,Space+'  143.Возврат на склад по З/Ценам                                 : ',SeparatorChar+
Recogniz(ReturnZ)+SeparatorChar);

Writeln(txt,Space+'  144.Упущенный доход по возврату                                 : ',SeparatorChar+
Recogniz(MinusDohod)+SeparatorChar);
Writeln(txt,Space+'  145.Доходность по отгруз. по итогам торгового дня (САМОВЫВОЗ)   : ',SeparatorChar+
Recogniz(AllDohod)+SeparatorChar);
Writeln(txt,Space+'  146.Доходность по отгруз. по итогам торгового дня (ПО АГЕНТАМ)  : ',SeparatorChar+
Recogniz(AllDohodA)+SeparatorChar);
Writeln(txt,Space+'  147.Доходность по отгрузке в счет взаимозачета                  : ',SeparatorChar+
Recogniz(AllDohodB)+SeparatorChar);
 End;

Writeln(txt,Space+'  148.Остаток "БОНУСОВ"                                           : ',SeparatorChar+
Recogniz(Otkat)+SeparatorChar);
Writeln(txt,Space+'  149.Пополнение "БОНУСОВ"                                        : ',SeparatorChar+
Recogniz(AddOtkat)+SeparatorChar);
Writeln(txt,Space+'  150.Гашение "БОНУСОВ"                                           : ',SeparatorChar+
Recogniz(KillOtkat)+SeparatorChar);
Writeln(txt,Space+'  151.Гашение "БОНУСОВ" по накладным текущего дня                 : ',SeparatorChar+
Recogniz(KillOtkatToDay)+SeparatorChar);

Writeln(txt,Space+'                                                           "'+DayString[DayOfWeek(ToDay)]+'" '+
                  FDate+'('+Times+')'+
			   GlobalPrn^.Dat.NoBold[Nprint^.DAt.Printer]+
			   GlobalPrn^.Dat.NoDouble[Nprint^.DAt.Printer]);

Writeln(txt,Space+'   ================================================================================');
End;

 Dispose(Kassa,Done);
 Close(Txt);
 ViewAsText(Path^.Dat.ToTemp+'Kassa.txt','ККЛ за '+DAta,True);
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
  MessageBox(^M+#3+'Не могу открыть файл!'+^M+#3+'('+IntToSTr(c,3)+')'
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
    MessageBox(^M+#3+'Ошибка чтения файла кассы за '+Data,Nil,mfError+mfCancelButton);
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
  MessageBox(^M+#3+'Не могу создать файл отчета!'+^M+#3+'('+IntToSTr(c,3)+')',Nil,mfError+mfCancelButton);
  Exit;
  End;

Kassa^.FormatReal;

s:=FormKod(Rek^.Dat.Kod);
s:=GEtClientField(FClient,s,1);
DelSpaceLeftRight(s);


  Writeln(txt,GlobalPrn^.Dat.Bold[Nprint^.DAt.Printer]+
  GlobalPrn^.Dat.Double[Nprint^.DAt.Printer]);
  Writeln(txt,Space+' ДОПОЛНИТЕЛЬНЫЙ КОНТРОЛЬНЫЙ КАССОВЫЙ ЛИСТ СКЛАДА "'+s+'" ЗА '+DAta);
  Writeln(txt);
  Writeln(txt,Space+'    Заполнил:'+GetOperatorField(FNAme,Kassa^.DAt.CAption));
  Writeln(Txt);
With Kassa^.Dat Do
Begin
If ({FindParam('/EZ')}(EnableZakupka=1)  Or (StrToInt(CurrentPassword)=0)) Then
Begin
Writeln(txt,Space+'      Суточный отчет по ККМ                                       : ',SeparatorChar+Recogniz(ReportKassa)+
SeparatorChar);
Writeln(txt,Space+'    1.Сумма в кассе                                               : ',SeparatorChar+Recogniz(SummaInKassa)+
SeparatorChar);
Writeln(txt,Space+'    2.Остаток в кассе                                             : ',SeparatorChar+Recogniz(OstatokInKassa)
+SeparatorChar);
Writeln(txt,Space+'    3.Сдано                                                       : ',SeparatorChar+Recogniz(Sdano)+
SeparatorChar);
Writeln(txt,Space+'    4.Дополнительный доход                                        : ',SeparatorChar+Recogniz(ExtendedDohod)+
SeparatorChar);
Writeln(txt,Space+'    5.Расходы                                                     : ',SeparatorChar+Recogniz(Rashod)+
SeparatorChar);
Writeln(txt,Space+'   14.Выдано без отсрочки платежа (Т)                             : ',SeparatorChar+Recogniz(Prodagi)+
SeparatorChar);
Writeln(txt,Space+'   15.Скидки выдачи без отсрочки платежа                          : ',SeparatorChar+Recogniz(SkProdagi)+
SeparatorChar);
Writeln(txt,Space+'      Выдано без отсрочки платежа (реально)                       : ',SeparatorChar+Recogniz(
RealToStr(StrToReal(Prodagi)-StrToReal(SkProdagi),CIZena,CMantissa)));

Writeln(txt,Space+'   18.Выдано на консигнацию (Т)                                   : ',SeparatorChar+Recogniz(VidanoConsig)+
SeparatorChar);
Writeln(txt,Space+'   19.Скидки выданной консигнации                                 : ',SeparatorChar+Recogniz(SkVidanoConsig)
+SeparatorChar);
Writeln(txt,Space+'      Выдано на консигнацию (реально)                             : ',SeparatorChar+Recogniz(
RealToStr(StrToReal(VidanoConsig)-StrToReal(SkVidanoConsig),CIZena,CMantissa)));

Writeln(txt,Space+'   20.Оплата консигнации в кассу                                  : ',SeparatorChar+Recogniz(OplataInKassa)+
SeparatorChar);
Writeln(txt,Space+'   22.Возврат по открытой консигнации (Т)                         : ',SeparatorChar+
Recogniz(ReturnOutOpenConsig)+SeparatorChar);
Writeln(txt,Space+'   23.Скидки возврата по открытой консигнации                     : ',SeparatorChar+
Recogniz(SkReturnOutOpenConsig));
Writeln(txt,Space+'      Возврат по открытой консигнации (реально)                   : ',SeparatorChar+Recogniz(
RealToStr(StrToReal(ReturnOutOpenConsig)-StrToReal(SkReturnOutOpenConsig),CIZena,CMantissa)));


Writeln(txt,Space+'   26.Остаток консигнации (Т)                                     : ',SeparatorChar+Recogniz(OstatokConsig)+
SeparatorChar);
Writeln(txt,Space+'   27.Скидки остатка консигнации                                  : ',SeparatorChar+
Recogniz(SkOstatokConsig)+SeparatorChar);
Writeln(txt,Space+'      Остаток консигнации (реально)                               : ',SeparatorChar+Recogniz(
RealToStr(StrToReal(OstatokConsig)-StrToReal(SkOstatokConsig),CIZena,CMantissa)));

Writeln(txt,Space+'   30.Расходы по возврату                                         : ',SeparatorChar+
Recogniz(RashodFromReturn)+SeparatorChar);
Writeln(txt,Space+'   46.Безналичные оплаты консигнации                              : ',SeparatorChar+
Recogniz(BNOPlataConsig));
Writeln(txt,Space+'  133.Остаток на складе по З/Ценам                                : ',SeparatorChar+Recogniz(OstatokZ)+
SeparatorChar);
Writeln(txt,Space+'  135.Приход на склад от клиента по З/Ценам                       : ',SeparatorChar+Recogniz(PrihodZC)+
SeparatorChar);
Writeln(txt,Space+'  137.Отгрузка клиенту по З/Ценам                                 : ',SeparatorChar+Recogniz(OtgruzkaZC)+
SeparatorChar);
Writeln(txt,Space+'  139.РП работы по З/Ценам                                        : ',SeparatorChar+Recogniz(OtgruzkaZRP)+
SeparatorChar);
Writeln(txt,Space+'  142.Ревизия на складе по З/Ценам                                : ',SeparatorChar+Recogniz(RewisiaZ)+
SeparatorChar);
Writeln(txt,Space+'  143.Возврат на склад по З/Ценам                                 : ',SeparatorChar+Recogniz(ReturnZ)+
SeparatorChar);
Writeln(txt,Space+'  144.Упущенный доход по возврату                                 : ',SeparatorChar+Recogniz(MinusDohod)+
SeparatorChar);
Writeln(txt,Space+'  145.Доходность по отгруз. по итогам торгового дня (САМОВЫВОЗ)   : ',SeparatorChar+Recogniz(AllDohod)+
SeparatorChar);
Writeln(txt,Space+'  146.Доходность по отгруз. по итогам торгового дня (ПО АГЕНТАМ)  : ',SeparatorChar+Recogniz(AllDohodA)+
SeparatorChar);


Writeln(txt,Space+'      Остаток на складе по З/Ценам2                               : ',SeparatorChar+Recogniz(OstatokZ2)+
SeparatorChar);
Writeln(txt,Space+'      Приход на склад от клиента по З/Ценам2                      : ',SeparatorChar+Recogniz(PrihodZC2)+
SeparatorChar);
Writeln(txt,Space+'      Отгрузка клиенту по З/Ценам2                                : ',SeparatorChar+Recogniz(OtgruzkaZC2)+
SeparatorChar);
Writeln(txt,Space+'      РП работы по З/Ценам2                                       : ',SeparatorChar+Recogniz(OtgruzkaZRP2)+
SeparatorChar);
Writeln(txt,Space+'      Ревизия на складе по З/Ценам2                               : ',SeparatorChar+Recogniz(RewisiaZ2)+
SeparatorChar);
Writeln(txt,Space+'      Возврат на склад по З/Ценам2                                : ',SeparatorChar+Recogniz(ReturnZ2)+
SeparatorChar);
Writeln(txt,Space+'      Упущенный доход по возврату                                 : ',SeparatorChar+Recogniz(MinusDohod2)+
SeparatorChar);


Summ:=0;
for c:=1 To Max30 Do Summ:=Summ+StrToReal(PerewoskiOutZ[c]);

Writeln(txt,Space+'      Итого перевозки со склада по ЗЦ                             : ',SeparatorChar+
RecognizReal(Summ,CIZena,CMantissaZ)+SeparatorChar);
Summ:=0;
for c:=1 To Max30 Do Summ:=Summ+StrToReal(PerewoskiInpZ[c]);
Writeln(txt,Space+'      Итого перевозки на склад по ЗЦ                              : ',SeparatorChar+
RecognizReal(Summ,CIZena,CMantissaZ)+SeparatorChar);

Summ:=0;
for c:=1 To Max30 Do Summ:=Summ+StrToReal(PerewoskiOutZ2[c]);

Writeln(txt,Space+'      Итого перевозки со склада по ЗЦ2                            : ',SeparatorChar+
RecognizReal(Summ,CIZena,CMantissaZ)+SeparatorChar);
Summ:=0;
for c:=1 To Max30 Do Summ:=Summ+StrToReal(PerewoskiInpZ2[c]);
Writeln(txt,Space+'      Итого перевозки на склад по ЗЦ2                             : ',SeparatorChar+
RecognizReal(Summ,CIZena,CMantissaZ)+SeparatorChar);



Writeln(txt,Space+'      Всего доходность по отгрузке по итогам торгового дня        : ',SeparatorChar+Recogniz(
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
 ViewAsText(Path^.Dat.ToTemp+'sKassa.txt','Дополнительный ККЛ за '+DAta,True);
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
   MessageBox(^M+#3+'Не могу создать '+Path^.Dat.ToTemp+'nstati.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Assign(f1,Path^.Dat.ToTemp+'kassaer.txt');
 i:=IOResult;
 Rewrite(f1);
 i:=IOResult;
 If I<>0 Then
  Begin
   Close(f);
   MessageBox(^M+#3+'Не могу создать '+Path^.Dat.ToTemp+'kassaer.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;

 Writeln(f,'Склад: '+FormKod(Rek^.Dat.Kod)++'  Оператор: '+CurrentPassword);
 Writeln(f,GlobalPrn^.Dat.OrientAlbom[Nprint^.DAt.Printer]+
 GlobalPrn^.Dat.MinInterval[Nprint^.DAt.Printer]);
 Writeln(f,'             Статистика за период с '+Start+' по '+Stop+' ('+Times+')');
 WriteLn(f);

 Writeln(f,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
 GlobalPrn^.Dat.MinInterval2[Nprint^.DAt.Printer]);

{Writeln(f,
 '────────────────────────────────────────────────────────────────────────────────────────────────────────────────'+
 '────────────────────────────────────────────────────────────────────────────────────────────────────────────────');
 Writeln(f,'  Дата  │Приход на склады│Сумма со складов│Доходность Отгр.│Доходность Опл .│     Расходы    │  Р/П           │ '+
 '    Сдано      │ '+

 'Выдано по ВЗ│Возврат скл│Остаток консигн.│  Выдано СФ │Упущенный Дх│Скидки отгру│Ревизии');
 Writeln(f,'────────────────────────────────────────────────────────────────────────────────────────────────────────────────'+
 '────────────────────────────────────────────────────────────────────────────────────────────────────────────────');}

Writeln(f,'┌───────┬──────────┬──────────┬──────────┬─────┬──────────┬─────┬──────────┬──────────┬──────────'+
+'┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬──────────┬─────┬──────────┬──────────┬──────────┐');
Writeln(f,'│ Дата  │Приход    │Сумма     │Доходность│  %  │Доходность│  %  │ Расходы  │  Р/П     │  Сдано   '+
+'│ Безнал.  │ Выдано   │Возврат   │Остаток   │Выдано СФ │Упущенный │Скидки    │  %  │Выдано по │Начислено │Ревизии   │');
Writeln(f,'│       │на склад  │со склада │отгрузка  │     │оплата    │     │          │          │          '+
+'│ поступл. │ по ВЗ    │на склад  │консигн.  │          │доход     │отгрузки  │     │бонусам   │бонусов   │на складе │');
Writeln(f,'└───────┴──────────┴──────────┴──────────┴─────┴──────────┴─────┴──────────┴──────────┴──────────'+
+'┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────┴─────┴──────────┴──────────┴──────────┘'+
+GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]);


 New(K,Init);
 l1:=DateStringToDate(DateMask,Start);
 l2:=DateStringToDate(DateMask,Stop);
 Tag:=0;
 For l:=l1 To l2 Do
  Begin
{ If Not(DayOfWeek(L) in [Sunday]) Then}
Begin
 DInfoMSgShkala('Анализирую данные...',l1,l2,L);
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
   {Вставит код формирования статистики}
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
     If i<>0 Then Writeln(f1,'Ошибка доступа к файлу кассы за '+S+
        '  "'+DayString[DayOfWeek(DAteStringToDate(DAteMask,S))]+'"'+' Код:'+IntToStr(I,3)
        )
     Else
      Begin
       Read(fk,K^.Dat);
       i:=IOResult;
       If i<>0 Then Writeln(f1,'Ошибка чтения файла кассы за '+S);

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
    s:=s+'│'+RealToStr(EPrihodL,CZenaZ,CMantissa)+'│'+RealToStr(ESoSkladaL,CZenaZ,CMantissa)+'│'+
    +RealToStr(EDohodL,CZenaZ,CMantissa)+'│'+ProzOtgr+'│'+
    +RealToStr(EDohodOplL,CZenaZ,CMantissa)+'│'+ProzOpl+'│'+
    RealToStr(ERashodL,CZenaZ,CMantissa)+'│'+
    +RealToStr(ERpL,CZenaZ,CMantissa)+'│'+RealToStr(ESdanoL,CZenaZ,CMantissa)+'│'+
    RealToStr(EBnL,CZenaZ,CMantissa)+'│'+
    RealToStr(EBarterL,CZenaZ,CMantissa)+'│'+RealToStr(EVzz,CZenaZ,CMantissa)+'│'+
    RealToStr(EOstL,CZenaZ,CMantissa)+'│'+RealToStr(EsFL,CZenaZ,CMantissa)+
    '│'+RealToStr(emINUSdOHODL,CZenaZ,CMantissa)+'│'+RealToStr(eSkidkiL,CZenaZ,CMantissa)+'│'+
    ProzSkidki+'│'+RealToStr(EBonusL,CZenaZ,CMantissa)+'│'+
    RealToStr(ENBonusL,CZenaZ,CMantissa)+'│'+
    RealToStr(ERwzL,CZenaZ,CMantissa)+'│'{+RealToStr(ESertifL,CZenaZ,CMantissa)};

  While Pos('│',s)>0 Do s[Pos('│',s)]:=SeparatorChar;

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
  End;{for по датам}

 Dispose(K,Done);

 Writeln(f,'─────────────────────────────────────────────────────────────────────────────────────────────────────────────'+
 '─────────────────────────────────────────────────────────────────────────────────');
 s:='   Всего'+SeparatorChar+RealToStr(EPrihod,CZenaZ,CMantissa)+'│'+RealToStr(ESoSklada,CZenaZ,CMantissa)+'│'+
    +RealToStr(EDohod,CZenaZ,CMantissa)+'│'+'     │'+
     RealToStr(EDohodOpl,CZenaZ,CMantissa)+'│'+'     │'+
     RealToStr(ERashod,CZenaZ,CMantissa)+'│'+
    +RealToStr(ERp,CZenaZ,CMantissa)+'│'+RealToStr(ESdano,CZenaZ,CMantissa)+
    '│'+RealToStr(EBN,CZenaZ,CMantissa)+
    '│'+RealToStr(EBarter,CZenaZ,CMantissa)+'│'+RealToStr(EVZa,CZenaZ,CMantissa)+
    '│'+RealToStr(EOsta,CZenaZ,CMantissa)+
    '│'+RealToStr(ESF,CZenaZ,CMantissa)+'│'+RealToStr(EMinusDohod,CZenaZ,CMantissa)+
    '│'+RealToStr(ESkidki,CZenaZ,CMantissa)+
    '│'+'     │'++RealToStr(EBonus,CZenaZ,CMantissa)+'│'+
    RealToStr(ENBonus,CZenaZ,CMantissa)+'│'+
    RealToStr(ERwz,CZenaZ,CMantissa){+'│'+RealToStr(ESertif,CZenaZ,CMantissa)};

 While Pos('│',s)>0 Do s[Pos('│',s)]:=SeparatorChar;

 Writeln(f,s);
 Writeln(f);

 Writeln(f,'             Рабочих дней:'+SeparatorChar,(Tag):CKol);
If Tag>0 Then
Begin
 Writeln(f,'         В среднем приход:'+SeparatorChar,EPrihod/(Tag):CIZena+2:CMantissa);

 Writeln(f,'      В среднем со склада:'+SeparatorChar,ESoSklada/(Tag):CIZena+2:CMantissa);

 Writeln(f,'  В среднем доход отгруз.:'+SeparatorChar,(EDohod-EMinusDohod)/(Tag):CIZena+2:CMantissa);

 Writeln(f,'  В среднем доход оплата.:'+SeparatorChar,(EDohodOpl)/(Tag):CIZena+2:CMantissa);

 Writeln(f,'         В среднем расход:'+SeparatorChar,(ERashod)/(Tag):CIZena+2:CMantissa);

 Writeln(f,'         В среднем скидки:'+SeparatorChar,(ESkidki)/(Tag):CIZena+2:CMantissa);

 Writeln(f,'           В среднем Р/П :'+SeparatorChar,ERp/(Tag):CIZena+2:CMantissa);

 Writeln(f,'       В среднем ревизии :'+SeparatorChar,ERwz/(Tag):CIZena+2:CMantissa);

 Writeln(f,'  В среднем выдано бонус.:'+SeparatorChar,EBonus/(Tag):CIZena+2:CMantissa);

 Writeln(f,'  В среднем начисл.бонус.:'+SeparatorChar,ENBonus/(Tag):CIZena+2:CMantissa);

 Writeln(f,'          В среднем сдано:'+SeparatorChar,ESdano/(Tag):CIZena+2:CMantissa);

 Writeln(f,'В среднем без.нал.поступл:'+SeparatorChar,EBN/(Tag):CIZena+2:CMantissa);

 Writeln(f,'        В среднем возврат:'+SeparatorChar,EVZa/(Tag):CIZena+2:CMantissa);

 Writeln(f,'      В среднем Остаток К:'+SeparatorChar,EOsta/(Tag):CIZena+2:CMantissa);
End;

 Writeln(f);
 Writeln(f,'[Примечание:]');
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




  Writeln(f,' Отпечатано:"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');

 Writeln(f,'============================================================================================================='+
 '====================================================='+
 GlobalPrn^.Dat.OrientNormal[Nprint^.DAt.Printer]+
 GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]+
 GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);



  Close(f);
 i:=IOResult;
 NoInfoMsg;
 ViewAsText(Path^.Dat.ToTemp+'nstati.txt','Статистика по ККЛ за период с '+Start+' по '+Stop,True);
 {Report(Path^.Dat.ToTemp+'nstati.txt','',NprintC^.DAt.CopyAll,False,False);}
End;



{$ELSE}
Procedure FormReportKAssa;
Begin
End;

{$ENDIF}



End.