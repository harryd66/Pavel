{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit Utils2;

Interface

Uses Dialogs,Glob,ColorTxt,Serv,Utils,ServStr,Drivers,Views,MyCalc,DosWin;

Procedure CreatOperatorReport;
Procedure RecalcFromVozwrat(Var E : PSuperMarketType);
Procedure GlobalSkidkaOutZakupka(ClKod:ArtikulStr;Op:Word);
Procedure RecalcFromOtdel(Var E : PSuperMarketType;Const OtdelMas:MaskaNew);
Function TestPC:Byte;
Function GetLizensiaFromProgramm:AllStr;
Function WriteMarketToSkladFile(PrevMarket,L:PSuperMarketType) : Boolean;
Function Period(VAr StartDate,StopDate:TDateString):Boolean;
Function DelDolgNakl(SClientKod:ArtikulStr;As:DocumentEdit):Boolean;


implementation

Uses app,Memory,Dos,MsgBox,Objects,Validate,TpDate,WinDos,Nastr,Access,
 DbEngine,NetCall,NetDbEng,CPrihod,Protect{,StarSky},Gadgets,Printers,Tools;

Procedure ImportClientInfo(Reg,Sel:Word);
Const SeparatorChar=';';
Var f : ClientFileType;
    Rd : ClientType;
    s : String;
    txt : Text;
    i : LongInt;
Begin
Case Reg Of
0:begin
     Case Sel Of
     0:s:=Path.ToClient+'Client.db';
     1:s:=Path.ToClient+'Sklad.db';
     2:s:=Path.ToClient+'Barter.db';
     Else;
     End;{CAse}

  end;
1:begin
       Case Sel Of
     0:s:=Path.ToClient+'Make.db';
     1:s:=Path.ToClient+'Sklad.db';
     2:s:=Path.ToClient+'Barter.db';
     Else;
     End;{CAse}
  End;
Else;
End;{Case}
DInfoMsg('Импортирую данные. Ждите...');
Assign (F,s);
i:=IOResult;
Reset(f);
i:=IOResult;

If i<>0 Then
 Begin
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка открытия '+s+'! (Код:'+IntToStr(i,CLitrMantissa)+')'+
  ClicProgrammer,Nil,
  mfError+mfCancelButton);
  Exit;
 End;
memc;
Assign(txt,Path.ToTemp+'impbaza.csv');
i:=IOResult;
Rewrite(txt);
i:=IOResult;
If i<>0 Then
 Begin
  Close(f);
  NoInfoMsg;
  MessageBox(^M+#3'Ошибка создания '+Path.ToTemp+'impbaza.csv'+'! (Код:'+IntToStr(i,CLitrMantissa)+')'+
  ClicProgrammer,Nil,
  mfError+mfCancelButton);
  Exit;
 End;

Case Reg Of
0:begin
     Case Sel Of
     0:s:=SeparatorChar+'БАЗА КЛИЕНТОВ';
     1:s:=SeparatorChar+'БАЗА СКЛАДОВ';
     2:s:=SeparatorChar+'БАЗА КЛИЕНТОВ (БАРТЕР)';
     Else;
     End;{CAse}

  end;
1:begin
       Case Sel Of
     0:s:=SeparatorChar+'БАЗА ПОСТАВЩИКОВ';
     1:s:=SeparatorChar+'БАЗА СКЛАДОВ';
     2:s:=SeparatorChar+'БАЗА ПОСТАВЩИКА (БАРТЕР)';
     Else;
     End;{CAse}
  End;
Else;

End;{Case}
Writeln(txt,DosToWin(s));
Writeln(txt,DosToWin(s));

Write(txt,DosToWin('код склада'+SeparatorChar+
'код контрагента'+SeparatorChar+
'наименование контрагента'+SeparatorChar+
'полное наименование'+SeparatorChar+
'Vip'+SeparatorChar+
'последняя сверка'+SeparatorChar+
'статус'+SeparatorChar+
'период'+SeparatorChar+
'код 1с'+SeparatorChar+
'Дочерний'+SeparatorChar+
'От'+SeparatorChar+
'N договора'+SeparatorChar+
'Адрес фактический'+SeparatorChar+
'Лимит'+SeparatorChar+
'Консигнация'+SeparatorChar+
'Отгрузка'+SeparatorChar+
'Юр.лицо/ФизЛицо'+SeparatorChar+
'Адрес юридический'+SeparatorChar+
'Телефон'+SeparatorChar+
'расчетный счет'+SeparatorChar+
'банк'+SeparatorChar+
'_ИНН'+SeparatorChar+
'_КПП'+SeparatorChar+
'ОКОНХ'+SeparatorChar));

WriteLN(txt,DosToWin(
'ОКПО'+SeparatorChar+
'Лицензия'+SeparatorChar+
'Срок до'+SeparatorChar+
'Свидетельство'+SeparatorChar+
'Имен.падеж'+SeparatorChar+
'Дат.падеж'+SeparatorChar+
'Серия паспорта'+SeparatorChar+
'Номер паспорта'+SeparatorChar+
'Выдан'+SeparatorChar+
'Сообщение'+SeparatorChar+
'Автосообщение'+SeparatorChar+
'Почтовый каталог'+SeparatorChar+
'Авто генерация прайса'+SeparatorChar+
'Контроль ценовых ограничений'+SeparatorChar+
'Контроль минимальных наценок'+SeparatorChar+
'Min%'+SeparatorChar+
'Коэффициент'+SeparatorChar+
'Дата именений'+SeparatorChar+
'Время именений'+SeparatorChar+
'Оператор'+SeparatorChar+
'Регион'+SeparatorChar+
'Код региона'+SeparatorChar+
'Маршрут'+SeparatorChar+
'Код маршрута'+SeparatorChar)
);

While not(eof(f)) do
 begin
  readclient(f,Rd);
  If rd.Employ Then
   Begin
    With Rd Do
     Begin

Format(Kod,CCLientKod);
Write(txt,DosToWin(Kod)+SeparatorChar);

Format(Name,CClient);
Write(txt,DosToWin(Name)+SeparatorChar);

Write(txt,DosToWin(FullName)+SeparatorChar);

(*Case Status of
0:Write(Txt,DosToWin('Активный ')+SeparatorChar);
1:Write(Txt,DosToWin('Пассивный ')+SeparatorChar);
2:Write(Txt,DosToWin('СБ ')+SeparatorChar);
3:Write(Txt,DosToWin('Закрыт ')+SeparatorChar);
4:Write(Txt,DosToWin('? ')+SeparatorChar);
Else;
End; *)

(*
Dogovor  : String[CAll];
Punkt    : Array [1..4] Of String[CRazdelKod];
{1 Павильоны} {2 Палатки} {3 Магазин} {4 Кафе}
Limit    : String[CIZena];
Adress   : String[CAll];
Telefon   : String[CAll];
R_Sh    : String[CAll];
Gde      : String[CAll];
Gorod    : String[CAll];
INN      : String[CAll];
OKONH    : String[CAll];
OKPO     : String[CAll];
Enviropment : String[CAll];
Messages : String[CSertif];
Debit    : Word;
NoLimit  : Word;
ClientShkala : Word;
SrokLizensia : TDateString;
Test_Srok: String[CArtikul];
Region   : Word;
Prozent  : String[Clitr];
AgentKod : array [1..2] of ArtikulStr;
Kod      : String[CClientKod];
Employ   : Boolean;
LockTime : Boolean;
LOCKDATE : TDAteString;
LockTimeCaption : String[CRazdelKod];
Stat     : Boolean;
Locked   : Boolean;
Opt: Boolean;*)

Format(Dogovor,CAll);
Write(txt,DosToWin(Dogovor)+SeparatorChar);


If Debit=0 Then Write(Txt,DosToWin('Консигнация запрещена')+SeparatorChar)
Else Write(Txt,DosToWin('Консигнация разрешена')+SeparatorChar);



Write(txt,'_'+DosToWin(INN)+SeparatorChar);



Writeln(txt);
i:=IOResult;

     End;
   End;
 end;

Close(f);
i:=IOResult;
Writeln(txt,DosToWin('"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')'));
Close(txt);
i:=IOResult;

NoInfoMsg;
MessageBox(^M+#3'Данные успешно импортированы в '+Path.ToTemp+'impbaza.csv!',Nil,
  mfInformation+mfCancelButton);
End;


Procedure CreatOperatorReport;
Var sDAte : string;
    s: string;
    AllSumma,Space,OperatorName1,OperatorName: AllStr;
    Open,AllProdagi,AllProdagiB,AllOPlataB,
    AllOPlataBarterB,AllOPlataBarterN,AllRashodBarterB,AllRashodBarterN,
    AllOPlata,AllRashod,AllOPlataRozn,AllOPlataOpt:AllStr;
    AllOPlataVzaim,AllOPlataVzaimOpt,AllOPlataVzaimRozn,
    AllOPlataRKO,AllOPlataRKORozn,AllOPlataRKOOpt:AllStr;
    txt : Text;
    Fm : MArketFileType;
    Em : PSuperMArketType;
    Fp : OplataRealizasiaFileType;
    Ep : OplataRealizasiaType;
    Fb : OplataBarterFileType;
    Fv : NewVozwratFileType;
    Ev : PNewVozwratType;
    Eb : POplataBarter;
    i : Word;

Begin
Space:='   ';
AllSumma[0]:=#0;
AllProdagi[0]:=#0;
AllProdagiB[0]:=#0;
AllOPlata[0]:=#0;
AllOPlataB[0]:=#0;
AllOPlataBarterN[0]:=#0;
AllOPlataBarterB[0]:=#0;
AllRashodBarterN[0]:=#0;
AllRashodBarterB[0]:=#0;
AllRashod[0]:=#0;
AllOPlataVzaimOpt[0]:=#0;
AllOPlataVzaimRozn[0]:=#0;
AllOPlataRKO[0]:=#0;
AllOPlataRKOOpt[0]:=#0;
AllOPlataRKORozn[0]:=#0;

AllOPlataVzaim[0]:=#0;
If Not(OpenRegistrWindow(OperatorNAme)) Then  Exit;
Sdate:=FDAte;
If Not DAteDialog(sdate) Then Exit;
Assign(txt,Path.ToTemp+'kassa'+OperatorNAme+'.txt');
i:=IOResult;
Rewrite(txt);
i:=IOResult;
if i<>0 Then
 Begin
  MessageBox(#3'Ошибка создания файла '+Path.ToTemp+'kassa'+OperatorNAme+'.txt',Nil,mfError+mfCancelButton);
  Exit;
 End;
DInfoMsg('Минуточку...');
  Writeln(Txt,Space+'Склад:'+FormKod(Rek.Kod)+' Оператор: '+CurrentPassword);
  Writeln(Txt);
Case TestOpenDate1(SDate) Of
False  :Open:='ДЕНЬ ЗАКРЫТ';
True   :Open:='ДЕНЬ ОТКРЫТ';
Else;
End;

  Writeln(txt,Space+' Статус:'+Open);
  Writeln(Txt);
  Writeln(Txt,Space+'                ОТЧЕТ ОПЕРАТОРА '+GetOperatorName(OperatorName)+' ('+OperatorName+') за '+SDate);


Assign(Fm,Path.ToMarket+SDAte+'.mrk');
i:=IOResult;
Reset(Fm);
i:=IOResult;
If I=0 Then
Begin
  Writeln(Txt,Space+'{Отгрузка клиенту без отсрочки платежа за наличный расчет}');
  Writeln(Txt,Space+'-----------------------------------------------------------------------------');
  Writeln(Txt,Space+'Клиент               Док   Время    Сумма к оплате    Сумма скидки Тип док-та');
                    {12345678901234567890│1234│12-45-78│123456789012345│123456789012345│Дебит СФ*}
  Writeln(txt,Space+'-----------------------------------------------------------------------------');
  New(Em,Init);
  While Not Eof(fm) Do
  Begin
   ReadMarket(Fm,Em);
   If (Em^.Dat.OperatorSelector=0) And (StrToint(Em^.Dat.Caption)=StrToInt(OperatorNAme)) And
   ((Em^.Dat.DocSelector in [0,1,2,3]) And Not(Em^.Dat.Realiz)) Then
   Begin
   s:=GetClientField(FClient,Em^.DAt.ClientKod,0);
   Format(s,CClient);
   {s:=s+' '+Em^.DAt.CLientKod;}
   DelSpace(Em^.Dat.Document);
   Format(Em^.Dat.Document,CDocNumer);
   DelSpace(Em^.Dat.SummaZ);

   Str(StrToReal(AllProdagi)+StrToReal(Em^.Dat.SummaZ):CIZena:CMantissa,AllProdagi);

   s:=s+' '+Em^.DAt.Document+' '+Em^.Dat.TimeC+' ';


   RFormat(Em^.Dat.SummaZ,CIZena);
   RFormat(Em^.Dat.Skidka,CIZena);

   s:=s+Em^.Dat.SummaZ+' '+Em^.Dat.Skidka;

     Case Em^.DAt.DocSelector Of
     0:s:=s+' Список   ';
     1:s:=s+' Тов.Чек ';
     2:s:=s+' Физ.лицо*';
     3:s:=s+' С/Ф*     ';
     4:s:=s+' С/Ф Б    ';
     5:s:=s+' Дебит*   ';
     6:s:=s+' Дебит СФ*';
     7:s:=s+' Дебит    ';
     8:s:=s+' Дебит СФБ';
     Else ;
     End;

   Writeln(txt,Space+s);

   End;
  End;{While}
i:=IOResult;
Close(Fm);
i:=IOResult;
  Writeln(Txt,Space+'-----------------------------------------------------------------------------');
  Writeln(txt,Space+'Всего к оплата по документам за '+SDate+' за наличный расчет : ',RecognizReal(StrToReal(AllProdagi),
  CInputIZena,CMantissa),' руб.');
  Writeln(Txt);
Dispose(Em,Done);
End;

Assign(Fm,Path.ToMarket+SDAte+'.mrk');
i:=IOResult;
Reset(Fm);
i:=IOResult;
If I=0 Then
Begin
  Writeln(Txt,Space+'{Отгрузка клиенту без отсрочки платежа за БЕЗналичный расчет}');
  Writeln(Txt,Space+'-----------------------------------------------------------------------------');
  Writeln(Txt,Space+'Клиент               Док   Время    Сумма к оплате    Сумма скидки Тип док-та');
                    {12345678901234567890│1234│12-45-78│123456789012345│123456789012345│Дебит СФ*}
  Writeln(txt,Space+'-----------------------------------------------------------------------------');
  New(Em,Init);
  While Not Eof(fm) Do
  Begin
   ReadMarket(Fm,Em);
   If (Em^.DAt.Active) Then
   If (Em^.Dat.OperatorSelector=0) And (StrToint(Em^.Dat.Caption)=StrToInt(OperatorNAme)) And
   ((Em^.Dat.DocSelector in [4]) And Not(Em^.Dat.Realiz)) Then
   Begin
   s:=GetClientField(FClient,Em^.DAt.ClientKod,0);
   Format(s,CClient);
   {s:=s+' '+Em^.DAt.CLientKod;}
   DelSpace(Em^.Dat.Document);
   Format(Em^.Dat.Document,CDocNumer);
   DelSpace(Em^.Dat.SummaZ);

   Str(StrToReal(AllProdagiB)+StrToReal(Em^.Dat.SummaZ):CIZena:CMantissa,AllProdagiB);

   s:=s+' '+Em^.DAt.Document+' '+Em^.Dat.TimeC+' ';


   RFormat(Em^.Dat.SummaZ,CIZena);
   RFormat(Em^.Dat.Skidka,CIZena);

   s:=s+Em^.Dat.SummaZ+' '+Em^.Dat.Skidka;

     Case Em^.DAt.DocSelector Of
     0:s:=s+' Список   ';
     1:s:=s+' Тов.Чек ';
     2:s:=s+' Физ.лицо*';
     3:s:=s+' С/Ф*     ';
     4:s:=s+' С/Ф Б    ';
     5:s:=s+' Дебит*   ';
     6:s:=s+' Дебит СФ*';
     7:s:=s+' Дебит    ';
     8:s:=s+' Дебит СФБ';
     Else ;
     End;

   Writeln(txt,Space+s);

   End;
  End;{While}
i:=IOResult;
Close(Fm);
i:=IOResult;
  Writeln(Txt,Space+'-----------------------------------------------------------------------------');
  Writeln(txt,Space+'Всего к оплата по документам за '+SDate+' за БЕЗналичный расчет : ',
  RecognizReal(StrToReal(AllProdagiB),CInputIZena,CMantissa),' руб.');
  Writeln(Txt);
Dispose(Em,Done);
End;

AllOPlataRozn:='';

Assign(Fp,Path.ToOplata+SDAte+'.opl');
i:=IOResult;
Reset(Fp);
i:=IOResult;
If I=0 Then
Begin
  Writeln(Txt,Space+'{Оплата консигнации за наличный расчет - розница (Дебит*,Дебит)}');
  Writeln(Txt,Space+'----------------------------------------------------------------------------');
  Writeln(Txt,Space+'Клиент               Код  Док  Дата Док     Сумма оплаты  Дата опл Время опл');
  Writeln(Txt,Space+'----------------------------------------------------------------------------');

  While Not Eof(fp) Do
  Begin
   ReadOplata(Fp,Ep);
   If Not(Ep.Vozwrat) And Not(Ep.RAshet)  And (StrToInt(OperatorName)=StrToInt(Ep.CAption)) Then
   {фильтруем взаимозачеты}
   Begin
   {If TestNakl(StrToInt(OperatorName),StrToInt(Ep.Document),Ep.DateDoc) Then}
    {смотрим продажу}
    Assign(Fm,Path.ToMarket+Ep.DateDoc+'.mrk');
    i:=IOResult;
    Reset(Fm);
    i:=IOResult;
  if i=0 then
  begin
    New(Em,Init);
    While Not Eof(fm) Do
      Begin
        ReadMarket(Fm,Em);
        if StrToInt(Ep.Document)=StrToInt(Em^.Dat.Document) then break;
      end;
   If (Em^.Dat.OperatorSelector=0) And
   (Em^.Dat.DocSelector in [5,7]) Then
    Begin
     s:=GetClientField(FClient,Ep.ClientKod,0);
     Format(s,CClient);
     s:=s+' '+Ep.CLientKod;
     DelSpace(Ep.Document);
     Format(Ep.Document,CDocNumer);
     DelSpace(Ep.SummaZ);
  If Ep.Rashet Then
    Begin
     Str(StrToReal(AllOPlata)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOplata);
     Str(StrToReal(AllOPlataRozn)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOPlataRozn);
    end
    Else if Ep.Bn.Bank<>'' then
      begin
       if pos('РКО',Ep.Bn.Bank)>0 then
       begin
        Str(StrToReal(AllOPlataRKO)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOPlataRKO);
        Str(StrToReal(AllOPlataRKORozn)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOPlataRKORozn);
       end
       else
       begin
        Str(StrToReal(AllOPlataVzaim)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOPlataVzaim);
        Str(StrToReal(AllOPlataVzaimRozn)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOPlataVzaimRozn);
       end
      end
      else
      Begin
        Str(StrToReal(AllOPlata)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOplata);
        Str(StrToReal(AllOPlataRozn)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOPlataRozn);
      End;

     s:=s+' '+Ep.Document+' '+Ep.DateDoc+'  ';
     RFormat(Ep.SummaZ,CIZena);
     s:=s+Ep.SummaZ+'  '+Ep.DateC+' '+Ep.TimeC;
     Writeln(txt,Space+s);
      If Ep.Rashet Then
       Begin
        Writeln(txt,Space+'П/П:'+Ep.Bn.NPlat+' от '+Ep.Bn.Date+' Банк:'+Ep.Bn.Bank+' Сумма:'+Ep.Bn.Summa);
       End
       Else if Ep.Bn.Bank<>'' then
       begin
       if pos('РКО',Ep.Bn.Bank)>0 then writeln(txt,Space+'РКО')
       else
       writeln(txt,Space+'ВЗАИМОЗАЧЕТ');
       end;
    End;{TestNakl}
    Close(Fm);
    Dispose(Em,Done);
   End;
   End;
  End;{While}
i:=IOResult;
Close(Fp);
i:=IOResult;
  Writeln(Txt,Space+'----------------------------------------------------------------------------');
Writeln(txt,Space+'Всего оплата консигнации за '+SDate+' за наличный расчет (розница): ',RecognizReal(StrToReal(AllOplataRozn),
  CInputIZena,CMantissa),' руб.');
Writeln(txt,Space+'Всего оплата консигнации за '+SDate+' по взаимозачету (розница): ',
  RecognizReal(StrToReal(AllOplataVzaimRozn),
  CInputIZena,CMantissa),' руб.');
Writeln(txt,Space+'Всего оплата консигнации за '+SDate+' по расходн.касс ордерам(розница): ',
  RecognizReal(StrToReal(AllOplataRKORozn),
  CInputIZena,CMantissa),' руб.');

  Writeln(Txt);
End;

AllOPlataOpt:='';
Assign(Fp,Path.ToOplata+SDAte+'.opl');
i:=IOResult;
Reset(Fp);
i:=IOResult;
If I=0 Then
Begin
  Writeln(Txt,Space+'{Оплата консигнации за наличный расчет - опт (Дебит СФ*,Дебит СФБ)}');
  Writeln(Txt,Space+'----------------------------------------------------------------------------');
  Writeln(Txt,Space+'Клиент               Код  Док  Дата Док     Сумма оплаты  Дата опл Время опл');
  Writeln(Txt,Space+'----------------------------------------------------------------------------');

  While Not Eof(fp) Do
  Begin
   ReadOplata(Fp,Ep);
   If Not(Ep.Vozwrat) And Not(Ep.RAshet)  And (StrToInt(OperatorName)=StrToInt(Ep.CAption)) Then
   Begin
   {If TestNakl(StrToInt(OperatorName),StrToInt(Ep.Document),Ep.DateDoc) Then}
    {смотрим продажу}
    Assign(Fm,Path.ToMarket+Ep.DateDoc+'.mrk');
    i:=IOResult;
    Reset(Fm);
    i:=IOResult;
  if i=0 then
  begin
    New(Em,Init);
    While Not Eof(fm) Do
      Begin
        ReadMarket(Fm,Em);
        if StrToInt(Ep.Document)=StrToInt(Em^.Dat.Document) then break;
      end;
   If (Em^.Dat.OperatorSelector=0) And
   (Em^.Dat.DocSelector in [6,8])  Then
    Begin
     s:=GetClientField(FClient,Ep.ClientKod,0);
     Format(s,CClient);
     s:=s+' '+Ep.CLientKod;
     DelSpace(Ep.Document);
     Format(Ep.Document,CDocNumer);
     DelSpace(Ep.SummaZ);
    If Ep.Rashet Then
    Begin
     Str(StrToReal(AllOplata)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOplata);
     Str(StrToReal(AllOplataOpt)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOplataOpt);
    end
    Else if Ep.Bn.Bank<>'' then
      begin
       if pos('РКО',Ep.Bn.Bank)>0 then
       begin
        Str(StrToReal(AllOPlataRKO)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOPlataRKO);
        Str(StrToReal(AllOPlataRKOOpt)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOPlataRKOOpt);
       end
       else
       begin
        Str(StrToReal(AllOPlataVzaim)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOPlataVzaim);
        Str(StrToReal(AllOPlataVzaimOpt)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOPlataVzaimOpt);
        end
      end
      else
      Begin
       Str(StrToReal(AllOplata)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOplata);
       Str(StrToReal(AllOplataOpt)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOplataOpt);
      End;

     s:=s+' '+Ep.Document+' '+Ep.DateDoc+'  ';
     RFormat(Ep.SummaZ,CIZena);
     s:=s+Ep.SummaZ+'  '+Ep.DateC+' '+Ep.TimeC;
     Writeln(txt,Space+s);
      If Ep.Rashet Then
       Begin
        Writeln(txt,Space+'П/П:'+Ep.Bn.NPlat+' от '+Ep.Bn.Date+' Банк:'+Ep.Bn.Bank+' Сумма:'+Ep.Bn.Summa);
       End
       Else if Ep.Bn.Bank<>'' then
       begin
        if pos('РКО',Ep.Bn.Bank)>0 then writeln(txt,Space+'РКО')
        else
        writeln(txt,Space+'ВЗАИМОЗАЧЕТ');
       end;
    End;{TestNakl}
    Close(Fm);
    Dispose(Em,Done);
   End;
   End;
  End;{While}
i:=IOResult;
Close(Fp);
i:=IOResult;
  Writeln(Txt,Space+'----------------------------------------------------------------------------');
  Writeln(txt,Space+'Всего оплата консигнации за '+SDate+' за наличный расчет (опт): ',RecognizReal(StrToReal(AllOplataOpt),
  CInputIZena,CMantissa),' руб.');
  Writeln(txt,Space+'Всего оплата консигнации за '+SDate+' по взаимозачету (опт): ',RecognizReal(StrToReal(AllOplataVzaimOpt),
  CInputIZena,CMantissa),' руб.');
Writeln(txt,Space+'Всего оплата консигнации за '+SDate+' по расходн.касс.ордерам (опт): ',
RecognizReal(StrToReal(AllOplataRKOOpt),
  CInputIZena,CMantissa),' руб.');

  Writeln(Txt);

End;


Assign(Fp,Path.ToOplata+SDAte+'.opl');
i:=IOResult;
Reset(Fp);
i:=IOResult;
If I=0 Then
Begin
  Writeln(Txt,Space+'{Оплата консигнации за БЕЗналичный расчет}');
  Writeln(Txt,Space+'----------------------------------------------------------------------------');
  Writeln(Txt,Space+'Клиент               Код  Док  Дата Док     Сумма оплаты  Дата опл Время опл');
  Writeln(Txt,Space+'----------------------------------------------------------------------------');

  While Not Eof(fp) Do
  Begin
   ReadOplata(Fp,Ep);
   If Not(Ep.Vozwrat) And (Ep.RAshet)  And (StrToInt(OperatorName)=StrToInt(Ep.CAption)) Then
   Begin
   {memcc(Ep.ClientKod);}
   s:=GetClientField(FClient,Ep.ClientKod,0);
   Format(s,CClient);
   s:=s+' '+Ep.CLientKod;
   DelSpace(Ep.Document);
   Format(Ep.Document,CDocNumer);
   DelSpace(Ep.SummaZ);

   Str(StrToReal(AllOplataB)+StrToReal(Ep.SummaZ):CIZena:CMantissa,AllOplataB);

   s:=s+' '+Ep.Document+' '+Ep.DateDoc+'  ';

   RFormat(Ep.SummaZ,CIZena);

   s:=s+Ep.SummaZ+'  '+Ep.DateC+' '+Ep.TimeC;

   Writeln(txt,Space+s);

    If Ep.Rashet Then
     Begin
      Writeln(txt,Space+'П/П:'+Ep.Bn.NPlat+' от '+Ep.Bn.Date+' Банк:'+Ep.Bn.Bank+' Сумма:'+Ep.Bn.Summa);
     End;
   End;

  End;{While}
i:=IOResult;
Close(Fp);
i:=IOResult;
  Writeln(Txt,Space+'----------------------------------------------------------------------------');
  Writeln(txt,Space+'Всего оплата консигнации за '+SDate+' за БЕЗналичный расчет : ',RecognizReal(StrToReal(AllOplataB),
  CInputIZena,CMantissa),' руб.');
  Writeln(Txt);

End;

New(Eb,Init);
Assign(Fb,Path.ToBarter+SDAte+'.bpl');
i:=IOResult;
Reset(Fb);
i:=IOResult;
If I=0 Then
Begin
  Writeln(Txt,Space+'{Расход в счет взаимозачета с клиентом за наличный расчет}');
  Writeln(Txt,Space+'-----------------------------------------------------------');
  Writeln(Txt,Space+'Клиент               Код    Сумма оплаты  Дата опл  Время');
  Writeln(Txt,Space+'-----------------------------------------------------------');
  While Not Eof(fb) Do
  Begin
   ReadOplataBarter(Fb,Eb);
   If Not(Eb^.Dat.OperatorSelector=1) And (Eb^.Dat.RAshet=0){нал}  And (StrToInt(OperatorName)=StrToInt(Eb^.Dat.CAption)) Then
   Begin
   s:=GetClientField(FClient,Eb^.Dat.ClientKod,2);
   Format(s,CClient);
   s:=s+' '+Eb^.Dat.CLientKod;
   Str(StrToReal(Eb^.Dat.SummaZ):CIZena:CMantissa,Eb^.Dat.SummaZ);

   Str(StrToReal(AllRashodBarterN)+StrToReal(Eb^.Dat.SummaZ):CIZena:CMantissa,AllRashodBarterN);

   s:=s+Eb^.Dat.SummaZ+'  '+Eb^.Dat.DateC+' '+Eb^.Dat.TimeC;

   Writeln(txt,Space+s);
   End;

  End;{While}
i:=IOResult;
Close(Fb);
i:=IOResult;
  Writeln(Txt,Space+'-----------------------------------------------------------');
  Writeln(txt,Space+'Всего расход в счет взаимозачета за '+SDate+' за наличный расчет : ',
  RecognizReal(StrToReal(AllRashodBarterN),CInputIZena,CMantissa),' руб.');
  Writeln(Txt);
End;

Assign(Fb,Path.ToBarter+SDAte+'.bpl');
i:=IOResult;
Reset(Fb);
i:=IOResult;
If I=0 Then
Begin
  Writeln(Txt,Space+'{Расход в счет взаимозачета с клиентом за БЕЗналичный расчет}');
  Writeln(Txt,Space+'-----------------------------------------------------------');
  Writeln(Txt,Space+'Клиент               Код    Сумма оплаты  Дата опл  Время');
  Writeln(Txt,Space+'-----------------------------------------------------------');
  While Not Eof(fb) Do
  Begin
   ReadOplataBarter(Fb,Eb);
   If Not(Eb^.Dat.OperatorSelector=1) And (Eb^.Dat.RAshet=1){нал}  And (StrToInt(OperatorName)=StrToInt(Eb^.Dat.CAption)) Then
   Begin
   s:=GetClientField(FClient,Eb^.Dat.ClientKod,2);
   Format(s,CClient);
   s:=s+' '+Eb^.Dat.CLientKod;
   Str(StrToReal(Eb^.Dat.SummaZ):CIZena:CMantissa,Eb^.Dat.SummaZ);

   Str(StrToReal(AllRashodBarterB)+StrToReal(Eb^.Dat.SummaZ):CIZena:CMantissa,AllRashodBarterB);

   s:=s+Eb^.Dat.SummaZ+'  '+Eb^.Dat.DateC+' '+Eb^.Dat.TimeC;
   Writeln(txt,Space+s);
   Writeln(txt,Space+'П/П:'+Eb^.Dat.Bn.NPlat+' от '+Eb^.Dat.Bn.Date+' Банк:'+Eb^.Dat.Bn.Bank+' Сумма:'+Eb^.Dat.Bn.Summa);
   End;

  End;{While}
i:=IOResult;
Close(Fb);
i:=IOResult;
  Writeln(Txt,Space+'-----------------------------------------------------------');
  Writeln(txt,Space+'Всего расход в счет взаимозачета за '+SDate+' за БЕЗналичный расчет : ',
  RecognizReal(StrToReal(AllRashodBarterB),CInputIZena,CMantissa),' руб.');
  Writeln(Txt);
End;


Assign(Fb,Path.ToBarter+SDAte+'.bpl');
i:=IOResult;
Reset(Fb);
i:=IOResult;
If I=0 Then
Begin
  Writeln(Txt,Space+'{Оплата в счет взаимозачета с клиентом за наличный расчет}');
  Writeln(Txt,Space+'-----------------------------------------------------------');
  Writeln(Txt,Space+'Клиент               Код    Сумма оплаты  Дата опл  Время');
  Writeln(Txt,Space+'-----------------------------------------------------------');
  While Not Eof(fb) Do
  Begin
   ReadOplataBarter(Fb,Eb);
   If Not(Eb^.Dat.OperatorSelector=0) And (Eb^.Dat.RAshet=0){нал}  And (StrToInt(OperatorName)=StrToInt(Eb^.Dat.CAption)) Then
   Begin
   s:=GetClientField(FClient,Eb^.Dat.ClientKod,2);
   Format(s,CClient);
   s:=s+' '+Eb^.Dat.CLientKod;
   Str(StrToReal(Eb^.Dat.SummaZ):CIZena:CMantissa,Eb^.Dat.SummaZ);

   Str(StrToReal(AllOplataBarterN)+StrToReal(Eb^.Dat.SummaZ):CIZena:CMantissa,AllOplataBarterN);

   s:=s+Eb^.Dat.SummaZ+'  '+Eb^.Dat.DateC+' '+Eb^.Dat.TimeC;

   Writeln(txt,Space+s);
   End;

  End;{While}
i:=IOResult;
Close(Fb);
i:=IOResult;
  Writeln(Txt,Space+'-----------------------------------------------------------');
  Writeln(txt,Space+'Всего оплата в счет взаимозачета за '+SDate+' за наличный расчет : ',
  RecognizReal(StrToReal(AllOplataBarterN),CInputIZena,CMantissa),' руб.');
  Writeln(Txt);
End;

Assign(Fb,Path.ToBarter+SDAte+'.bpl');
i:=IOResult;
Reset(Fb);
i:=IOResult;
If I=0 Then
Begin
  Writeln(Txt,Space+'{Оплата в счет взаимозачета с клиентом за БЕЗналичный расчет}');
  Writeln(Txt,Space+'-----------------------------------------------------------');
  Writeln(Txt,Space+'Клиент               Код    Сумма оплаты  Дата опл  Время');
  Writeln(Txt,Space+'-----------------------------------------------------------');
  While Not Eof(fb) Do
  Begin
   ReadOplataBarter(Fb,Eb);
   If Not(Eb^.Dat.OperatorSelector=0) And (Eb^.Dat.RAshet=1){б/нал}  And (StrToInt(OperatorName)=StrToInt(Eb^.Dat.CAption))
   Then
   Begin
   s:=GetClientField(FClient,Eb^.Dat.ClientKod,2);
   Format(s,CClient);
   s:=s+' '+Eb^.Dat.CLientKod;
   Str(StrToReal(Eb^.Dat.SummaZ):CIZena:CMantissa,Eb^.Dat.SummaZ);

   Str(StrToReal(AllOplataBarterB)+StrToReal(Eb^.Dat.SummaZ):CIZena:CMantissa,AllOplataBarterB);

   s:=s+Eb^.Dat.SummaZ+'  '+Eb^.Dat.DateC+' '+Eb^.Dat.TimeC;
   Writeln(txt,Space+s);
   Writeln(txt,Space+'П/П:'+Eb^.Dat.Bn.NPlat+' от '+Eb^.Dat.Bn.Date+' Банк:'+Eb^.Dat.Bn.Bank+' Сумма:'+Eb^.Dat.Bn.Summa);

   End;

  End;{While}
i:=IOResult;
Close(Fb);
i:=IOResult;
  Writeln(Txt,Space+'-----------------------------------------------------------');
  Writeln(txt,Space+'Всего оплата в счет взаимозачета за '+SDate+' за БЕЗналичный расчет : ',
  RecognizReal(StrToReal(AllOplataBarterB),CInputIZena,CMantissa),' руб.');
  Writeln(Txt);
End;

Dispose(Eb,Done);


Assign(Fv,Path.ToReturn+SDAte+'.vzw');
i:=IOResult;
Reset(Fv);
i:=IOResult;
If I=0 Then
Begin
  Writeln(Txt,Space+'{Расходы по возврату от клиента}');
  Writeln(Txt,Space+'---------------------------------------------------------------------');
  Writeln(Txt,Space+'Клиент               Код  Док  Осн  Дата осн. Сумма к выдаче   Время');
  Writeln(Txt,Space+'---------------------------------------------------------------------');
                    {12345678901234567890│1234│1234│1234│12345678│123456789012345│12345678}

  New(Ev,Init);
  While Not Eof(fv) Do
  Begin
   ReadNewVozwrat(fv,Ev);
   If (Ev^.Dat.Rashod) And (Ev^.Dat.StatusDoc=0) And (StrToInt(OperatorName)=StrToInt(Ev^.Dat.CAption))Then
    Begin
{4}   Str (StrToReal(AllRAshod)+StrToReal(Ev^.Dat.RashodSumma):CIZena:CMantissa,AllRashod);
      s:=GetClientField(FClient,Ev^.Dat.MakeKod,0);
      Format(s,CClient);
      s:=s+' '+Ev^.Dat.MakeKod;
      DelSpace(Ev^.Dat.Document);
      DelSpace(Ev^.Dat.BasisDoc);
      Format(Ev^.Dat.Document,CDocNumer);
      Format(Ev^.Dat.BasisDoc,CDocNumer);
      Format(Ev^.Dat.BasisDate,CDate);
      DelSpace(Ev^.Dat.RashodSumma);
      RFormat(Ev^.Dat.RashodSumma,CIZena);

      s:=s+' '+Ev^.Dat.Document+' '+Ev^.Dat.BAsisDoc+' '+Ev^.Dat.BAsisDAte+' '+
         Ev^.Dat.RashodSumma+' '+Ev^.Dat.TimeC;
      Writeln(txt,Space+s);
    End;

  End;
  Dispose(Ev,Done);
i:=IOResult;
Close(Fv);
i:=IOResult;
  Writeln(Txt,Space+'---------------------------------------------------------------------');
  Writeln(txt,Space+'Всего расходы по возврату за '+SDate+' : ',RecognizReal(StrToReal(AllRashod),
  CInputIZena,CMantissa),' руб.');
  Writeln(Txt);
End;
  Writeln(Txt);

  Writeln(Txt,Space,' Всего Б/Н выручка (оплаты и продажи) за '+sdate+':'+RecognizReal(
  StrToReal(AllProdagiB)+StrToReal(AllOplataB),CInputIZena,CMantissa));
  Writeln(Txt);
  Writeln(Txt,Space,'+Оплаты по взаимозачету (Б/Н) за '+sdate+':'+RecognizReal(
  StrToReal(AllOplataBarterB),CInputIZena,CMantissa));
  Writeln(Txt);
  Writeln(Txt,Space,'-Расход по взаимозачету (Б/Н) за '+sdate+':'+RecognizReal(
  StrToReal(AllRashodBarterB),CInputIZena,CMantissa));
  Writeln(Txt);
  Writeln(Txt);
  Writeln(Txt);
  Writeln(Txt,Space,'+Всего выручка (оплаты и продажи) за '+sdate+':'+RecognizReal(
  StrToReal(AllProdagi)+StrToReal(AllOplata),CInputIZena,CMantissa));
  Writeln(Txt);
  Writeln(Txt,Space,'+ Оплаты по взаимозачету (нал) за '+sdate+':'+RecognizReal(
  StrToReal(AllOplataVzaim),CInputIZena,CMantissa));
  Writeln(Txt);
  Writeln(Txt,Space,'+ Оплаты по Раходн.касс.ордерам (нал) за '+sdate+':'+RecognizReal(
  StrToReal(AllOplataRKO),CInputIZena,CMantissa));
  Writeln(Txt,Space,'- Расход по взаимозачету (нал) за '+sdate+':'+RecognizReal(
  StrToReal(AllRAshodBArterN),CInputIZena,CMantissa));

  Writeln(Txt);
  Writeln(Txt,Space,'+                     Дополнительный доход: ______________');
  Writeln(Txt);
  Writeln(Txt,Space,'-                      Расходы по возврату:'+RecognizReal(StrToReal(AllRAshod),CInputIZena,CMantissa));
  Writeln(Txt);
  Writeln(Txt,Space,'-                 Расходы без учета оплаты: ______________');
  Writeln(Txt);
  Writeln(Txt,Space,'+       Остаток в кассе за предыдущий день: ______________');
  Writeln(Txt);
  Writeln(Txt,Space,'=                            Сумма в кассе: ______________');
  Writeln(Txt);
  Writeln(Txt,Space,'-                              Всего сдано: ______________');
  Writeln(Txt);
  Writeln(Txt,Space,'=              Остаток в кассе за '+sdate+': ______________');
  Writeln(Txt);
  OperatorName1:=GetOperatorName(OperatorName);
  Format(OperatorName1,CKto);
  Writeln(Txt,Space,'      Подпись оператора '+OperatorName1+': ______________');
  Writeln(Txt);
  Writeln(Txt,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
  Writeln(Txt,Space+'============================================================================');

i:=IOResult;
Close(txt);
i:=IOResult;
NoInfoMsg;

ViewAsText(Path.ToTemp+'kassa'+OperatorNAme+'.txt',True);
Report(Path.ToTemp+'kassa'+OperatorNAme+'.txt','',1,False,False,false);
End;



Procedure RecalcFromVozwrat(Var E : PSuperMarketType);
Var c,k : Word;
    s : string[150];
    RetKol : ArtikulStr;
    sk,ws,wsNP,NP : AllStr;
    koefficient : AllStr;
    E1 : PSuperMArketType;
    cc,sh : Word;
Begin

  Sh:=E^.Dat.Amount;
  For c:=1 To E^.Dat.Amount Do
   Begin
   {уменшаем количество на велечину возврата}
    RetKol:=GetReturnKol(E^.Dat.Document,E^.Dat.DateC,E^.Dat.ClientKod,
    E^.Dat.MarketElement[c].BazKod,
    IntToStr(E^.Dat.MarketElement[c].Input.DiviSionSNumber,COne),
    E^.Dat.OperatorSelector);
    Str(STrToInt(E^.Dat.MarketElement[c].Input.Kol)-
    StrToInt(RetKol):CKol,E^.Dat.MarketElement[c].Input.Kol);

    If StRToInt(RetKol)>0 Then
     Begin
      {MyStr(StrToReal(E^.Dat.ENalog)-}
      {вычислить сбор НП за единицу товара}

     If E^.Dat.SkidkaSelector in [0,2] Then{Если автомат}
      begin
       DelSpace(E^.Dat.MarketElement[c].Input.Proz);
       Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)*
       (StrToReal(E^.Dat.MarketElement[c].Input.Proz))):CZena:CMantissa,ws);
       Str(StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
	      StrToReal(ws):CZena:CMantissa,sk);
      End
      Else
       Begin
        Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
	   StrToReal(E^.Dat.MarketElement[c].Input.Skidka))
        :CZena:CMantissa,ws);
        sk:=E^.Dat.MarketElement[c].Input.Skidka;
       End;
       {ws - цена за единицу}

       wsNP:=ws;
       NP:='0.00';
       If E^.DAt.DocSelector in [{1,2,3,5,6}100] Then {отключен расчет НП нах}
       Begin
        str(((1+strtoreal(e^.dat.marketelement[c].Input.SpecNalog)
             /100)):CLitr:CMantissa,koefficient);
        {новая цена}
        Str(StrToReal(ws)*StrToReal(Koefficient):CZena:CMantissa,wsNP);
       End;
       {wsNP - цена за единицу с налогом НП}

       Str(StrToReal(wsNP)-StrToReal(ws):CZena:CMAntissa,NP);

       Str(StrToREal(E^.Dat.ENalog)-
           StrToInt(RetKol)*StrToReal(NP):CIZena:CMantissa,
		 E^.Dat.ENalog);

      {отработка налога с продажи}
      Case E^.Dat.MarketElement[c].Input.ViDNalog Of
      0:  Str(StrToREal(E^.Dat.Nalog5)-
           StrToInt(RetKol)*StrToReal(NP):CIZena:CMantissa,
		 E^.Dat.Nalog5);

      1:  Str(StrToREal(E^.Dat.Nalog3)-
           StrToInt(RetKol)*StrToReal(NP):CIZena:CMantissa,
		 E^.Dat.Nalog3);

      2:  Str(StrToREal(E^.Dat.Nalog_)-
           StrToInt(RetKol)*StrToReal(NP):CIZena:CMantissa,
		 E^.Dat.Nalog_);

      Else
	 Str(StrToREal(E^.Dat.Nalog_)-
           StrToInt(RetKol)*StrToReal(NP):CIZena:CMantissa,
		 E^.Dat.Nalog_);
      End;{CAse}

      {вычислить цену за единицу товара}
      {вычислить скидку за единицу}


      MyStr(StrToReal(E^.Dat.SummaZ)-
	 (StrToInt(RetKol)*StrToReal(wsNP)),
	 CIZena,CMantissa,E^.Dat.SummaZ);


      MyStr(StrToReal(E^.Dat.Skidka)-
	 (StrToInt(RetKol)*StrToReal(sk)),
	 CIZena,CMantissa,E^.Dat.Skidka);

      MyStr(StrToReal(E^.Dat.SummaZakupka)-
	 (StrToInt(RetKol)*StrToReal(E^.Dat.MarketElement[c].Input.Zakupka)),
	 CIZena,CMantissa,E^.Dat.SummaZakupka);
     End;{RetKOl>0}
   End;{For}

New(E1,Init);

E1^.Dat:=E^.DAt;

cc:=0;

  For c:=1 To E^.Dat.Amount Do
   Begin
    If StrToInt(E^.Dat.MarketElement[c].Input.Kol)>0 Then
     Begin
      Inc(cc);
      E1^.Dat.MarketElement[cc].Input.LAst:=False;
      E1^.Dat.MarketElement[cc]:=E^.Dat.MarketElement[c];
     End
   End;

E^.Dat:=E1^.Dat;

E^.Dat.Amount:=cc;

Dispose(E1,Done);

End;{Procedure}




Procedure RecalcFromOtdel(Var E : PSuperMarketType;Const OtdelMas:MaskaNew);
Var c,k : Word;
    s : string;
    RetKol : ArtikulStr;
    sk,ws,wsNP,NP : AllStr;
    koefficient : AllStr;
    E1 : PSuperMArketType;
    ItogoS: Real;
    ItogoSkidka:Real;
    cc,sh : Word;
Begin

  Sh:=E^.Dat.Amount;
  E^.Dat.SummaZ[0]:=#0;
  E^.Dat.Skidka[0]:=#0;
  E^.Dat.SummaZakupka[0]:=#0;
  E^.Dat.Nalog5[0]:=#0;
  E^.Dat.Nalog3[0]:=#0;
  E^.Dat.Nalog_[0]:=#0;
  E^.Dat.ENalog[0]:=#0;
  ItogoS:=0;
  ItogoSkidka:=0;
{
  Writeln(OtdelMas[1],' ',OtdelMas[2],' ',OtdelMas[3],' ',OtdelMas[4],' ',OtdelMas[5]);
  Readln;
}
  For c:=1 To E^.Dat.Amount Do
   Begin
   {уменшаем количество на велечину возврата}

  If OtdelMas[E^.Dat.MarketElement[c].Input.DivisionSNumber]=1 Then
 Begin

     If E^.Dat.SkidkaSelector in [0,2] Then
      begin
       DelSpace(E^.Dat.MarketElement[c].Input.Proz);
       Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)*
       (StrToReal(E^.Dat.MarketElement[c].Input.Proz))):CZena:CMantissa,ws);
       Str(StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
	      StrToReal(ws):CZena:CMantissa,sk);
      End
      Else
       Begin
        Str((StrToReal(E^.Dat.MarketElement[c].Input.Zena)-
	   StrToReal(E^.Dat.MarketElement[c].Input.Skidka))
        :CZena:CMantissa,ws);
        sk:=E^.Dat.MarketElement[c].Input.Skidka;
       End;
       {ws - цена за единицу}

       wsNP:=ws;
       NP:='0.00';

       If E^.DAt.DocSelector in [{1,}2,3,5,6] Then {отключен расчет НП в тч}
       Begin
        str(((1+strtoreal(e^.dat.marketelement[c].Input.SpecNalog)
             /100)):CLitr:CMantissa,koefficient);
        {новая цена}
        Str(StrToReal(ws)*StrToReal(Koefficient):CZena:CMantissa,wsNP);
       End;
       {wsNP - цена за единицу с налогом НП}
       Str(StrToReal(wsNP)-StrToReal(ws):CZena:CMAntissa,NP);

       Str((StrToReal(WsNP)*StrToInt(E^.Dat.MarketElement[c].Input.Kol))
       :CInPutIZena:CMantissa,ws);

       ItogoS:=StrToReal(wS);

       Str((StrToReal(sk)*
	        StrToInt(E^.Dat.MarketElement[c].Input.Kol))
           :CInPutIZena:CMantissa,sk);

       ItogoSkidka:=StrToReal(Sk);



       Str(StrToREal(E^.Dat.ENalog)+StrToInt(E^.Dat.MarketElement[c].Input.Kol)*
		 StrToReal(NP):CIZena:CMantissa,E^.Dat.ENalog);


       Str(StrToREal(E^.Dat.SummaZakupka)+StrToInt(E^.Dat.MarketElement[c].Input.Kol)*
		 StrToReal(E^.Dat.MarketElement[c].Input.Zakupka):CIZena:CMantissa,E^.Dat.SummaZakupka);

      {вычислить цену за единицу товара}
      {вычислить скидку за единицу}


      MyStr(StrToReal(E^.Dat.SummaZ)+ItogoS,CIZena,CMantissa,E^.Dat.SummaZ);


      MyStr(StrToReal(E^.Dat.Skidka)+ItogoSkidka,CIZena,CMantissa,E^.Dat.Skidka);

End;{OtdelMas=1}
   End;{For}

End;{Procedure}





Procedure GlobalSkidkaOutZakupka(ClKod:ArtikulStr;Op:Word);

var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  c : Word;
  st : ArtikulStr;
  ws,Zena,Zakupka : TDateString;
  s : string[150];
  WspomList1:PBox;
  ls : Word;
  SArt1 : ArtikulStr;
  Add : Boolean;
begin
If Prodaga^.List^.Count>0 Then
Begin
R.Assign(28, 10, 52, 13);
New(Dlg, Init(R, 'Наценка'));
Dlg^.Palette := dpCyanDialog;
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E004;
R.Assign(13, 1, 20, 2);
Control := New(PInputLine, Init(R, CLitrMantissa));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0','.']));

  R.Assign(1, 1, 13, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'от закупки:', Control)));

R.Assign(21, 1, 23, 2);
Control := New(PStaticText, Init(R, '%'));
Dlg^.Insert(Control);


c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Dlg^.GetData(st);
  Dispose(Control,Done);
  Dispose(Dlg,Done);
  DelSpace(St);
  Str(StrToReal(St):CArtikul:CMAntissa,St);
  If StrToReal(st)<1.00 Then
   Begin
    Messagebox(^M+#3'Недопустимое ЗНАЧЕНИЕ скидки (менее 1% от закупки)!',Nil,mfError+mfCancelButton);
    Exit;
   End;
   {вставить код изменения скидки}

If Prodaga^.List^.Count>0 Then
Begin

  R.Assign(0,0,0,0);
  WspomlIST1 := New(PBox, Init(R, 1, Nil));
  WspomList1^.NewList(New(PTextCollection, Init(0,1)));

For ls:=0 To Prodaga^.List^.Count-1 Do
 Begin
{артикул}
 s:=Prodaga^.GetText(ls,Prodaga^.List^.Count);
 SArt1:=Copy(s,1,CArtikul);

 Add:=True;
 If Op=0 Then
  Begin
   If TestSpec(SArt1,ClKod) Then Add:=False;
  End;

 If Add Then
 Begin
 Zena:=Copy(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1,CZena);
 {закупочная цена}
 Zakupka:=Copy(s,Ord(s[0])-CZena+1,CZena);

 Str( StrToReal(Zena)
    -(StrToReal(Zakupka)*
     (1+StrToReal(st)/100)):CZena:CMantissa,ws);

{Удаляем старую ручную скидку}
 System.Delete(s,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1,CZena);

{Добавляем новую ручную скидку}
 System.Insert(ws,S,1+COne+1+CName+1+CArtikul+1+CLitr+1+CKol+1+CZena+1);

{вставляем исправленную строку}
 End;{Add}
 WspomList1^.List^.Insert(NewStr(s));
 WspomList1^.SetRange(WspomList1^.List^.Count);

End;{For}
{очистка Prodaga}
  Prodaga^.NewList(Nil);
  Prodaga^.NewList(New(PTextCollection, Init(0,1)));

{обновление Prodaga}
For ls:=0 To WspomList1^.List^.Count-1 Do
 Begin
{артикул}
 s:=WspomList1^.GetText(ls,WspomList1^.List^.Count);
 Prodaga^.List^.Insert(NewStr(s));
 Prodaga^.SetRange(Prodaga^.List^.Count);
End;{For}

{удаление Wspom}
Dispose(WspomList1,Done);
End;{Prodaga^.List^.Count>0}
 End
 Else
 Begin
  Dispose(Control,Done);
  Dispose(Dlg,Done);
 End;
End;{If Prodaga^.List^.Count>0 Then}
end;


Procedure CalcComputer(VAr S: String;Res:Boolean);
Var k,a,b,c,m,e : Word;
    r : LongInt;
Begin

 s[0]:=#0;
{$IfDEF not dpmi}
(*
 For k:=0 To 7 Do
  Begin
   s[k+1]:=chr(Mem[$F000:$FFF5+k]);
  End;
 s[0]:=Chr(k+1);
 r:=DateStringToDAte('mm/dd/yy',s);{Дата прошивки ПЗУ}
 s:=IntToStr(r,CIZena);

 Writeln(s);
r:=MemW[0:$413];
r:=r*1024;           {общий объем памяти}


If MEM [$F000:$FFFE]= $FC Then
 Begin {AT}
  Res:=True;
  Port[$70]:=$15;
  m:=Port[$71];
  Port[$70]:=$16;
  m:=m+Port[$71] shl 8; {основная память}
  Port[$70]:=$17;
  e:=Port[$71];
  Port[$70]:=$18;
  e:=e+Port[$71] shl 8; {дополнительная память}

  a:=0;
  for b:=0 to 3 Do
  If MemW[0:$400+b shl 2] <>0 Then Inc(a); {количество последовательный портов}

  c:=0;
  for b:=0 to 3 Do
  If MemW[0:$408+b shl 2] <>0 Then Inc(c); {количество параллельных портов}

 s:=s+' '+IntToStr(r,CIZena)+' '+IntToStr(m,CIZena)+' '+IntToStr(e,CIZena)+
 ' '+IntToStr(a,CIZena)+' '+IntToStr(c,CIZena);
 {Пароль СрокЛицензии Датапрошивки}

 End
 Else {XT}
  Begin
   Res:=FAlse;
  End;
*)
{$ENDIF}
End;

Function Install(Var Password,DAte:LongInt):Boolean;
LAbel Start;
var
  c : Word;
  Dlg : PDialog;
  R : TRect;
  Control : PView;

  DataRec : record
    Password : String[8];
    DateLS   : String[8];
  end;

Begin
Install:=False;

DAtaRec.Password[0]:=#0;
DAtaRec.DateLS[0]:=#0;

Start:

R.Assign(24, 8, 56, 15);
New(Dlg, Init(R, 'Инсталяция'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.Palette := dpCyanDialog;
Dlg^.HelpCtx := $E002;

R.Assign(20, 2, 30, 3);
Control := New(PSInputLine, Init(R, CDAte));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));

  R.Assign(1, 2, 20, 3);
  Dlg^.Insert(New(PLabel, Init(R, 'Пароль инсталяции:', Control)));

R.Assign(20, 4, 30, 5);
Control := New(PInputLine, Init(R, CDate));
Dlg^.Insert(Control);
  PInputLine(Control)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

  R.Assign(2, 4, 20, 5);
  Dlg^.Insert(New(PLabel, Init(R, 'Срок лиц.соглаш.:', Control)));

Dlg^.SetData(DataRec);

Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);

If c<>cmCAncel Then
 Begin
  Dlg^.GetDAta(DataRec);
  Password:=StrToInt(DataRec.Password);
  If Password<>19610512 Then
   Begin
    MessageBox(^M+#3'Неправильно указан пароль инсталяции!',Nil,mfError+mfCancelButton);
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    Goto Start;
   End;

  If Not(TestDate(DataRec.DAteLS,DAte)) Then
   Begin
    MessageBox(#3'Неправильно указана дата лицензионного соглашения!',Nil,mfError+mfCancelButton);
    Dispose(Control,Done);
    Dispose(Dlg,Done);
    Goto Start;
   End;

  Date:=DateStringToDate(DAteMAsk,DataRec.DAteLS);
  Install:=True;
 End;

Dispose(Control,Done);
Dispose(Dlg,Done);
End;



Function TestPC:Byte;
Label Test;
VAr PZU : AllStr;
    s,s1 : string;
    Ti,k,Max,L,Password : LongInt;
    F : File;
    Res : Boolean;

Begin
      TestPC:=0;
{If DateStringToDate(DateMask,FDate)>=DateStringToDate(DateMask,'31-12-99') Then
  Halt;}
      l:=IOResult;
      If FindPAram('/ADM') Then
       begin
        If Install(Password,Max) Then
        Begin
         l:=ioresult;
            Assign(F,{(Path.ToProgram+'sklad.exe'}ParamStr(0));
         Reset(F,1);
         If IOResult<>0 Then HAlt;
         L:=FileSize(F);
         Seek(F,L);

         s[0]:=#0;
         s:=IntToStr(Password,CIZena)+' '+{s+' '+}IntToStr(MAX,CIZena);

         BlockWrite(F,s,Succ(Length(s)));{контрольная сумма}

         Seek(F,L);
         Truncate(F);
         Close(F);

        End
        Else Goto Test;
       end
       else
       begin
       Test:
        Assign(F,ParamStr(0){Path.ToProgram+'sklad.exe'});
        Reset(F,1);
        l:=ioresult;
        If IOResult<>0 Then Halt;
        DInfoMsg('Проверяю легальность копии программы...');
        L:=FileSize(F);
        Seek(F,L);

        Seek(F,L+256);
        BlockWrite(F,s,1);
        Seek(F,L);
        BlockRead(F,s,256);
        Seek(F,L);
        Truncate(F);
        Close(f);

        k:=1;
        If Ord(S[0])>0 Then
        For k:=Ord(S[0]) DownTo 1 Do
         If s[k]=' ' Then Break;

        PZU := Copy (s,k+1,Ord(s[0])-(k));

        s[0]:=Chr(k-1);

        {CalcComputer(S1,Res);}

        If (s)<>(IntToStr(19610512,CIZena){+s1}) Then
            Begin
          TestPC:=1;
          NoInfoMsg;
          Exit;
{
          Writeln('Внимание ! Незаконная копия программы...');
          Writeln('При дальнейших попытках запуска - данные на диске будут уничтожены!');
          WriteLn('Подумайте! Может лучше легально приобрести программное обеспечение,');
                WriteLn('которому вы доверяете свои деньги?');
          Writeln;
          Writeln('Attention! A pirate copy of the program...');
          Writeln('At further attempts of starting - the data on a disk will be erased!');
          Writeln('Think! Can better legally acquire the software, you trust which one the money?');
          SpecialBeep;
          Halt;
}
            End;

        If Today > StrToInt(PZU) Then
            Begin
          TestPC:=2;
          NoInfoMsg;
          Exit;
{         Writeln('Внимание ! Истекла лицензия на использование программного продукта...');
          Writeln('Для продления лицензионного соглашения обратитесь к разработчику!');
          Writeln;
          Writeln('Attention! The license for usage of the software product has expired...');
          Writeln('For extension of the license agreement address to the developer!');
          SpecialBeep;
          Halt;}
            End;

        If Today = StrToInt(PZU) Then
            Begin
          TestPC:=3;
          NoInfoMsg;
          Exit;
{
          Writeln('Внимание ! Истекла лицензия на использование программного продукта...');
          Writeln('Для продления лицензионного соглашения обратитесь к разработчику!');
          Writeln;
          Writeln('Attention! The license for usage of the software product has expired...');
          Writeln('For extension of the license agreement address to the developer!');
          SpecialBeep;
}
            End;
          NoInfoMsg;
       end;
 end;


Function GetLizensiaFromProgramm:AllStr;
Label Test;
VAr PZU : AllStr;
    s,s1 : string;
    k,Max,L,Password : LongInt;
    F : File;
    Res : Boolean;
Begin
        Assign(F,{Path.ToProgram+'sklad.exe'}ParamStr(0));
        l:=ioresult;
        Reset(F,1);
        l:=ioresult;
        If L<>0 Then
            Begin
             GetLizensiaFromProgramm:='Ошибка';
          Exit;
         End;
        L:=FileSize(F);
        Seek(F,L);

        Seek(F,L+256);
        BlockWrite(F,s,1);
        Seek(F,L);
        BlockRead(F,s,256);
        Seek(F,L);
        Truncate(F);
        Close(f);

        k:=1;
        If Ord(S[0])>0 Then
        For k:=Ord(S[0]) DownTo 1 Do
         If s[k]=' ' Then Break;

        PZU := Copy (s,k+1,Ord(s[0])-(k));

        s[0]:=Chr(k-1);
        {CalcComputer(S1,Res);}

        GetLizensiaFromProgramm:=DateToDAteString(DAteMAsk,StrToInt(PZU));
end;



Function WriteMarketToSkladFile(PrevMarket,L:PSuperMarketType) : Boolean;
Var SkladFile : File Of SkladType;
    Sklad : PSkladType;
    i,p : Byte;
    s1 : TEnjoyStr;
Begin
WriteMarketToSkladFile:=False;
If Status=DocEdit Then
Begin
 For i:=1 To PrevMarket^.Dat.Amount{J} Do
  Begin
   New(Sklad,Init);
   S1:=Copy(PrevMarket^.Dat.MarketElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Exit;
    End;
   Seek(SkladFile,GetFileLocation3(Copy(PrevMarket^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));

   Repeat
   Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Sklad^.Dat);
   With Sklad^.Dat.Input Do
   Begin
     Caption:=PrevMarket^.Dat.Caption;
     DelSpace(PrevMarket^.Dat.MarketElement[i].Input.Kol);
     Sklad^.Dat.Date := TekDate;
     Sklad^.Dat.Time := Times;
     Str((StrToInt(DiviSionS[PrevMarket^.Dat.MarketElement[i].Input.DiviSionSNumber])
     +StrToInt(PrevMarket^.Dat.MarketElement[i].input.kol)):
     CKol,DivisionS[PrevMarket^.Dat.MarketElement[i].InPut.DiviSionSNumber]);
   End;
   {Sklad^.Dat.Employ:=True;}
   Sklad^.Dat.Input.Kol[0]:=#0;
   For p:=1 To CDiviSion Do
   Str((StrToInt(Sklad^.Dat.Input.Kol)+StrToInt(Sklad^.Dat.Input.DivisionS[p])):CKol,Sklad^.Dat.Input.Kol);

   Seek(SkladFile,GetFileLocation3(Copy(PrevMarket^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(SkladFile,Sklad^.Dat);

   Seek(SkladFile,FilePos(SkladFile)-1);
   Repeat
    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

   Close(SkladFile);
   Dispose(Sklad,Done);
  End;
End;

 For i:=1 To L^.DAt.Amount{J} Do
  Begin
   New(Sklad,Init);
   S1:=Copy(L^.Dat.MArketElement[i].BazKod,1,CRazdelKod);
   Assign(SkladFile,Path.ToSklad+s1+'.db');
   p:=IOResult;
   Reset(SkladFile);
   p:=IOResult;
   If p <> 0 Then
    Begin
     MessageBox(#3^M+#3'Ошибка доступа к файлу '+S1+'.db!',Nil,mfError+mfCancelButton);
     Dispose(Sklad,Done);
     Exit;
    End;
   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));

   Repeat
   Pause(1);
   Until Lock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));

   Read(SkladFile,Sklad^.Dat);
   With Sklad^.Dat.Input Do
   Begin
     Caption:=L^.Dat.Caption;
     DelSpace(L^.Dat.MarketElement[i].Input.Kol);
     Sklad^.Dat.Date := TekDate;
     Sklad^.Dat.Time := Times;
Str((StrToInt(DiviSionS[L^.Dat.MarketElement[i].Input.DiviSionSNumber])-StrToInt(L^.Dat.MarketElement[i].Input.Kol))
:CKol,DivisionS[L^.Dat.MarketElement[i].InPut.DiviSionSNumber])
   End;
{   Sklad^.Dat.Baz.Employ:=True;}
   Sklad^.Dat.Input.Kol[0]:=#0;
   For p:=1 To CDiviSion Do
   Str((StrToInt(Sklad^.Dat.Input.Kol)+StrToInt(Sklad^.Dat.Input.DivisionS[p])):CKol,Sklad^.Dat.Input.Kol);
   Seek(SkladFile,GetFileLocation3(Copy(L^.Dat.MarketElement[i].BazKod,CRazdelKod+1,CKod)));
   Write(SkladFile,Sklad^.Dat);

   Seek(SkladFile,FilePos(SkladFile)-1);

   Repeat
    UnLock(SkladFile,FilePos(SkladFile)*SizeOf(SkladType),SizeOf(SkladType));
   Until (DosError=0);

   Close(SkladFile);
   Dispose(Sklad,Done);
  End;
WriteMarketToSkladFile:=True;
End;




Function Period(VAr StartDate,StopDate:TDateString):Boolean;
Label 1;
var
  Dlg : PDialog;
  R : TRect;
  Control,ControlStart,ControlStop : PView;
  C : Word;
  l : LongInt;
  s1: TDateString;

begin
Period :=False;

1:
R.Assign(23, 9, 57, 14);
New(Dlg, Init(R, 'Укажите период отгрузки'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx:=$E011;
Dlg^.Palette := dpCyanDialog;

R.Assign(6, 2, 16, 3);
ControlStart := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStart);
  PInputLine(ControlStart)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

ControlStart^.SetData(startDate);

  R.Assign(3, 2, 6, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~с~:', ControlStart)));

R.Assign(20, 2, 30, 3);
ControlStop := New(PInputLine, Init(R, 8));
Dlg^.Insert(ControlStop);
  PInputLine(ControlStop)^.Validator := New(PPXPictureValidator, Init(DateFiltr, True));

ControlStop^.SetData(StopDate);

  R.Assign(16, 2, 20, 3);
  Dlg^.Insert(New(PLabel, Init(R, '~п~о:', ControlStop)));

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);
If c<>cmCancel Then
 Begin
   ControlStart^.GetData(StartDate);
   ControlStop^.GetData(StopDate);
   Dispose(ControlStart,Done);
   Dispose(ControlStop,Done);
   Dispose(Dlg,Done);

   If Not(TestDate(StartDate,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе начала периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   If Not(TestDate(StopDAte,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе конца периода!',Nil,mfError+mfCancelButton);
     Goto 1;
    End;

   Period:=True;

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

Function DelDolgNakl(SClientKod:ArtikulStr;As:DocumentEdit):Boolean;
Var l : PRealizasiaType;
    RealFile : File Of RealizasiaType;
    i : Byte;
    Find,Log : Boolean;
    j : LongInt;
Begin
 DelDolgNakl:=False;
 Assign(RealFile,Path.ToDolg+SClientKod+'.dlg');
 i:=IOResult;
 Reset(RealFile);
 i:=IOResult;
 If i <> 0 Then
  Begin
    MessageBox(#3^M+#3'Файл задолженности клиента '^M+#3+Path.ToDolg+SClientKod+'.dlg не найден!'^M
   ,Nil,mfError+mfCancelButton);
    Exit;
  End;
  New(l,Init);
  DelSpace(As.EditPosition);
  Find:=False;
  DInfoMsg('Ищу документ в долгах клиента '+SClientKod+'...');
  {поиск от конца файла}
  j:=FileSize(RealFile)-1;
  While (j>=0) And Not(Find) Do
   Begin
    Seek(RealFile,j);
    Read(RealFile,L^.Dat);
    DelSpace(L^.Dat.Market.Document);
    If (StrToInt(As.EditPosition)=StrToInt(L^.Dat.Market.Document))And
        (As.D=L^.Dat.Market.DateC)
           And (L^.Dat.Market.Active) Then Find:=True;
    Dec(j);
   End;

  If Not(Find) Then
   Begin
    NoInfoMsg;
    Dispose(L,Done);
    Close(RealFile);
    MessageBox(#3'Документ N '+ClearChar(As.EditPosition)+
    ' от '+As.D+' в долгах клиента не найден!'^M
    ,Nil,mfError+mfCancelButton);
    Exit;
   End;
    Seek(RealFile,FilePos(RealFile)-1);
    L^.Dat.Market.Active:=False;
    Write(RealFile,L^.Dat);
    i:=IoREsult;
    Close(RealFile);
    i:=IoREsult;
    Dispose(L,Done);
    AddProtocol('Удаление документа N'+As.EditPosition+' от '+As.D+' из долгов клиента!','{консигнация}','');
    NoInfoMsg;
    DelDolgNakl:=True;
End;


Begin
End.
