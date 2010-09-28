{$I Compile.INC}

{$IfNDEF DPMI}

{$F+}
{$O+}

{$EndIf}
Unit utils7;


Interface


Uses Glob,Views,Dialogs,ServSTr,Utils,Drivers,
     Utils1,Utils4,Slava3,FindPrh;





Type ArrayBazType = Record
     Tovar     : PBox; {клиент│код клиента│Количество товара}
     {Структура строки│
        5      26           26         1        5             3              3
      │код│наименование│наименование2│Main:1│Litr:CLitr│InPack:CInPack│InPack2:CInPack│
        15      9        2          5            1                1          1
      OKP:15│Massa:9│BuchGroup:2│Etil:CLitr│Market:COne│EnableDebit:COne│VidNalog:COne│
           5            1        5         15            1
      Nalog:CLitr│VidNDS:COne│NDS:CLitr│Mera:CMera│EnableContract:COne│
             12                  8                  5                   8               5
      Contract:CContract│ContractDate:CDate│EnableSklads:CArtikul│DSertif:CDAte│FantomKod:CArtikul│+
              4                   4                     4               1
      PostKod:CClientKod│FirmaPostKod:CClientKod│KSertif:CClientKod│Employ:COne│}
     Time      : LongInt;
     Last      : LongInt;
     Refresh   : Boolean;{True не нужно обновлять False - актуальность утрачена надо обновлять}
     Employ    : Boolean;{признак наименование используется в расчете}
    End;



Type ArraySPRDATAType = Record
     Elements  : PBox; {клиент│код клиента│Количество товара}
     Time      : LongInt;
     Last      : LongInt;
     Refresh   : Boolean;{True не нужно обновлять False - актуальность утрачена надо обновлять}
     Employ    : Boolean;{признак наименование используется в расчете}
    End;


Type CasheTovarType = Array [0..99] Of ArrayBazType;
Type CasheSPRDataType = Array [1..13] Of ArraySPRDATAType;


{0-страны производства
 1-фирмы производители
 2-единицы измерения
 3-марки
 4-гтд
 5-эксп.закл
 6-спец.марки
 12-бухгалтерский классификатор
 13-база банков}


Procedure InitCash;{стартовая настройка обнуление всех дат и времени}

Procedure LoadCash;{тотальная загрузка справочников выполняется только при входе в систему
                    или смене объекта}

Procedure RefreshCash;{точечное сканирование и обновление отдельных разделов}
Procedure RefreshCashOneRazdel(Art:ArtikulStr);{точечное сканирование и обновление отдельных разделов}
Procedure RefreshCashOneSPR(Base:Word);{чтение данных и кэша}

Function ReadCash(Art:ArtikulStr; Var E: BazType):Boolean;{чтение данных и кэша}
Function ReadCashSPR(Base:Word;Art:ArtikulStr; Var s: TMyString):Boolean;{чтение данных и кэша}

{Procedure TestDialogList;}

{Function ReadCashSPR(Art:ArtikulStr; Var s: tMyString):Boolean;{чтение справочников из кэша}
Procedure DestroyCash;{уничтожение кэша только при выходе или смене объекта}


Var CasheTovarList : CasheTovarType;
    SprList        : CasheSprDataType;
    CashCount      : LongInt;
    CashCountSpr   : LongInt;

Procedure FormReport4(Const P:PBox;StartDate,StopDAte:TDAteString;Sorting:Word;
FiltrDoc:Maska9;FiltrRash:Maska3;sertifword,Izmen:Word;FiltrOtdel:Maska8);
function SelDoc(Var As:DocumentEditz):Boolean;



implementation


Uses App,Serv,Objects,DbEngine,MsgBox,StHolder,Utils5,Net,Mail,Access1,
     TVObject,TVDialog,TVInput,TvType,TvConst,Validate,Vision1,NetDbEng,Filetool,
     Printers,TPDate,Prise,Protect,MyView,Tools,Vision11,ServStr2;

Const
     LocalReadOnlyN=$42;




Function TestAgent(Agent:PBox;Cod:ArtikulStr):Boolean;
Var L : Boolean;
    i : word;
    st : String;
Begin
TestAgent:=False;
If (Agent^.List^.Count-1)>=0 Then
Begin
For i:=0 To Agent^.List^.Count-1 Do
 Begin
  st:=Agent^.GetText(i,Agent^.List^.Count);
  st:=Copy(st,1+1,CClientKod);
  If (St=Cod) Then
   Begin
    TestAgent:=True;
    Break;
   End;{St=Cod}
 End;
End;
End;



(*
Procedure FormReport4(Const P:PBox;StartDate,StopDAte:TDAteString;Sorting:Word;
FiltrDoc:Maska9;FiltrRash:Maska3;sertifword,Izmen:Word;FiltrOtdel:Maska8);
Const Space='';
Var f : text;
         SVersia,Skidka,Summa,ws,s : String;
         AllLitr,NDSZ,NDS,Zakupka,Litr,AllNDS20,AllNDS10,AllNDS_,AllNDS18,AllNDS16,

            ZakupkaOutNDS,Itogo,ISkid : Array[0..8] Of Real;
         c,k,VidZak : Word;
         Open : String;
      As : DocumentEditZ;
      Tip : Word;
      SAllLitr,SNDS,SNDSZ,SClient,SLitr,SZakupka,SZakupkaOutNDS,SEkspeditor,
      OplataOutNDS,
         SLocNDS,SLocNDSZ,SLocNDS20,SLocNDS10,SLocNDS_,SLocNDS18,SLocNDS16,SLocLitr,
	    SLocZakupkaOutNDS : AllStr;
      Agent : PBox;
      AgKod : AllStr;
      R : TRect;
      E : PSuperMArketType;
      TempStr,DateStr,SClientKod,SDoc,SDAte : TDAteString;
      NDS20,NDS10,NDS_,NDS18,NDS16,
      LocNDS,LocNDS20,LocNDS10,LocNDS_,LocNDS18,LocNDS16,LocLitr,
         LocZakupkaOutNDS,LocNDSZ:Real;
      PrintItog,PrintDate : Boolean;
      sertif2 : Maska2;
      LocLocOpl,LocLocNDS,LocLocZ,LocLocZOutNDS,LocLocLitr : Real;
      LocLocDoc:Word;

Begin


If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin


 VidZak:=SelectImport(17);
 If VidZak=2 Then Exit;


 Assign (f,Path^.Dat.ToTemp+'list.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
        MessageBox(#3^m+#3+'Не могу создать файл '+Path^.Dat.ToTemp+'list.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));

If Not(SelectionAgent(Agent)) Then
 Begin
  System.Close(f);
  Dispose(Agent,Done);
  Exit;
 End;

 Writeln(f,Header+Space+ 'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');

 Write(f,Space+'Вид сортировки:');
 Case Sorting Of
 0:Writeln(f,Space+'"Клиент"');
 1:Writeln(f,Space+'"Номер документа"');
 2:Writeln(f,Space+'"Сумма отгрузки"');
 3:Writeln(f,Space+'"Сумма скидки"');
 Else Writeln(f);
 End;

 Writeln(f,Space+'Включены в рассмотрение виды документов:');
 Write(f,Space);
 For c:=1 To Max9 Do
  Begin
   If FiltrDoc[c]=1 Then
    Case c Of
    1:Write(f,' "Список" ');
    2:Write(f,' "Тов.Чек*" ');
    3:Write(f,' "Физ.Л*" ');
    4:Write(f,' "СФ*" ');
    5:Write(f,' "СФ Б" ');
    6:Write(f,' "Дебит*" ');
    7:Write(f,' "Дебит СФ*" ');
    8:Write(f,' "Дебит" ');
    9:Write(f,' "Дебит СФБ" ');
    Else;
    End;
  End;
 Writeln(f);

 Writeln(f,Space+'Включены в рассмотрение виды расчета:');
 Write(f,Space);
 For c:=1 To Max3 Do
  Begin
   If FiltrRash[c]=1 Then
    Case c Of
    1:Write(f,' "Наличный" ');
    2:Write(f,' "Безналичн." ');
    3:Write(f,' "Вексель" ');
    Else;
    End;
  End;
 Writeln(f);

 Writeln(f);

 Write(f,Space+'Вид отгрузки: ');
 WordToBit2(sertifword,sertif2);
 Convert2(sertif2);

 If Sertif2[1]=1 Then Write(f,'"Товар" ');
 If Sertif2[2]=1 Then Write(f,'"Сопроводительные документы"');

 Writeln(f);

 Write(f,Space+'Вид закупки:');
 Case VidZak Of
 0:Writeln(f,Space+'"Закупка для бухгалтерии"');
 1:Writeln(f,Space+'"Закупка 2"');
 Else Writeln(f);
 End;
 Writeln(f);

 Writeln(f,Space+'Включены в рассмотрение отгрузки по отделениям:');
 Write(f,Space);
 For c:=1 To CDivision Do
  Begin
   If FiltrOtdel[c]=1 Then Write(f,' "'+IntToStr(c,COne)+'" ');
  End;
 Writeln(f);

 Writeln(f);

 If Izmen=1 Then
 Begin
  Writeln(f,Space+'Внимание! В справку включены только изменявшиеся документы!');
  Writeln(f);
 End;

Case TestOpenDate1(StopDate) Of
False  :Open:='заблокирован';
True   :Open:='не заблокирован';
Else;
End;

 Writeln(f,Space+'                                              Доступ к данным за '+StopDate+' '+Open);

 Writeln(f,Space+'РЕЕСТР ДОКУМ-ОВ ОТГРУЗКИ ТОВАРА И СОПРОВОД.ДОКУМ-ОВ'+' с '+StartDate+' по '+StopDate+
 ' ('+FDate+' '+Times+')');
 WriteLn(f,Space+'Форма N 4');

 Writeln(f,Condensed[Nprint^.DAt.Printer]+MinInterval2[Nprint^.DAt.Printer]);
 Writeln(f,Space+
'┌───────────────────┬─────┬────┬────────┬──────────┬──────────┬────────────────────────────────'+
'┬────────────┬─────────┬─────────┐');
Writeln(f, Space+
'│                   │     │    │        │ Сумма по │ Сумма по │           В т.ч. НДС           '+
'│  Сумма по  │         │Тип доку-│');
Writeln(f, Space+
'│    Клиент         │Код  │Док.│  Дата  │   ценам  │ценам опл.│──────────┬──────────┬──────────'+
'│ зак.ценам  │  Литров │  мента  │');
Writeln(f, Space+
'│                   │     │    │        │ к оплате │  без НДС │   20%    │    10%   │  Прочее  '+
'│  без НДС   │         │         │');
Writeln(f, Space+
'└───────────────────┴─────┴────┴────────┴──────────┴──────────┴──────────┴──────────┴──────────'+
'┴────────────┴─────────┴─────────┘'+
+Normal[Nprint^.DAt.Printer]+HeaderStop);
                 {12345678901234567890│12345│1234│12345678│1234567890│12345678│12345678│12345678│1234567890│123456789│}

 For c:=0 To 8 Do
 Begin
  ISkid[c]:=0;
  Itogo[c]:=0;
  AllNDS20[c]:=0;
  AllNDS10[c]:=0;
  AllNDS_[c]:=0;
  AllNDS18[c]:=0;
  AllNDS16[c]:=0;
  AllLitr[c]:=0;
  ZakupkaOutNDS[c]:=0;
  Litr[c]:=0;
  NDS[c]:=0;
  NDSZ[c]:=0;
 End;

SZakupkaOutNDS[0]:=#0;
SAllLitr[0]:=#0;
SNDS[0]:=#0;
SNDSZ[0]:=#0;

NDS20:=0;
NDS10:=0;
NDS_:=0;
NDS18:=0;
NDS16:=0;


MyStr(StrToReal(SZakupkaOutNDS),CIZenaK,CMAntissa,SZakupkaOutNDS);
MyStr(StrToReal(SAllLitr),CZena,CLitrMantissa,SAllLitr);
MyStr(StrToReal(SNDS),CZena,CMantissa,SNDS);


If Sorting=1 Then
Begin
s := P^.GetText(0,P^.List^.Count);
DateStr:=Copy(s,1+CClient+1+CDocNumer+1,CDate);
Writeln(f,Space+'Дата: '+DateStr);
End;


 LocLocOpl:=0;
 LocLocNDS:=0;
 LocLocZ:=0;
 LocLocZOutNDS:=0;
 LocLocLitr:=0;
 LocLocDoc:=0;



 For c:=0 To P^.List^.Count-1 Do
  Begin
     DInfoMsgShkala('Формирую отчет за период с '+StartDate+' по '+StopDate+' ...',0,P^.List^.Count-1,c);

   PrintItog:=False;
   PrintDate:=False;


     s := P^.GetText(c,P^.List^.Count);
     AgKod:=Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+COne+1+CKto+1+CDate+1+CDAte+1+CClient+2,
	CClientKod);

If TestAgent(Agent,AgKod) Then
Begin
As.EditPosition:=Copy(s,1+CClient+1,CDocNumer);
As.D:={Copy(s,Ord(s[0])-CArtikul-1-CDAte-1-CMantissa,CDate);;}
      Copy(s,1+CClient+1+CDocNumer+1,CDate);

        While Pos('│',s)>0 Do
         Begin
          k:=Pos('│',s);
          System.Delete(s,k,1);
          System.Insert(SeparatorChar,s,k);
         End;
         SVersia:=Copy(s,Ord(S[0])-CArtikul-CMantissa,CMantissa);
         {Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+COne+1+CKto+1+CDate+1+CDAte+1+CClient+2,
                  CClientKod);}
         If StrToInt(SVersia)>1 Then SVersia:='!'
         Else SVersia[0]:=#0;

        SEkspeditor:=
           Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+COne+1+CKto+1+CDate+1+CDAte+1+CClient+2+
                 CClientKod+1,CClient);
        s[0]:=Chr(1+CClient+1+CDocNumer+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+COne+1+CKto);

        SClient:=Copy(s,1,CCLient);
        As.EditPosition := Copy(s,1+CCLient+1,CDocNumer);
        As.D := Copy(s,1+CCLient+1+CDocNumer+1,CDAte);
        Summa:=Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CDate+1,CIZenaK);
        Skidka:=Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CDate+1+CIZenaK+1,CIZenaK);
        MyStr(StrToReal(Summa)-StrToReal(Skidka),CIZenaK,CMantissa,Summa);
        ws:=Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1,COne);
        Tip:=StrToInt(Ws);

        New(E,Init);
        GetMArket1(As,E);
        SClientKod:=IntToStr(E^.DAt.OperatorSelector,COne)+E^.DAt.ClientKod;

        CalcNDS2(FiltrOtdel,Sertif2,E,VidZak,LocNDS,LocNDS20,LocNDS10,LocNDS_,LocNDS18,LocNDS16,LocLitr,
	   LocZakupkaOutNDS,LocNDSZ);

        MySTr(LocNDS,CIZenaK,CMAntissa,SLocNDS);
        MySTr(LocNDSZ,CIZenaK,CMAntissa,SLocNDSZ);
        MySTr(LocNDS20,CIZenaK,CMAntissa,SLocNDS20);
        MySTr(LocNDS10,CIZenaK,CMAntissa,SLocNDS10);
        MySTr(LocNDS_,CIZenaK,CMAntissa,SLocNDS_);
        MySTr(LocNDS18,CIZenaK,CMAntissa,SLocNDS18);
        MySTr(LocNDS16,CIZenaK,CMAntissa,SLocNDS16);
        MySTr(LocZakupkaOutNDS,CIZenaK+2,CMAntissaZ,SLocZakupkaOutNDS);
        MySTr(LocLitr,CIZenaK,CLitrMAntissa,SLocLitr);

        NDS20:=NDS20+StrToReal(SLocNDS20);
        NDS10:=NDS10+StrToReal(SLocNDS10);
        NDS_:=NDS_+StrToReal(SLocNDS_);
        NDS18:=NDS18+StrToReal(SLocNDS18);
        NDS16:=NDS16+StrToReal(SLocNDS16);

        Dispose(E,Done);

        MyStr(StrToReal(SZakupkaOutNDS)+StrToReal(SLocZakupkaOutNDS),CIZenaK+2,CMAntissaZ,SZakupkaOutNDS);
        MyStr(StrToReal(SAllLitr)+StrToReal(SLocLitr),CIZenaK,CLitrMantissa,SAllLitr);
        MyStr(StrToReal(SNDS)+StrToReal(SLocNDS),CIZenaK,CMantissa,SNDS);


  If Sorting=1 Then
   Begin
     LocLocOpl:=LocLocOpl+StrToReal(Summa);
     LocLocNDS:=LocLocNDS+StrToReal(SLocNds);
     LocLocZ:=LocLocOpl-LocLocNDS;
     LocLocZOutNDS:=LocLocZOutNDS+StrToReal(SLocZakupkaOutNDS);
     LocLocLitr:=LocLocLitr+StrToReal(SLocLitr);
     Inc(LocLocDoc);
   End;



  If Sorting = 1 Then
  Begin
   If c<P^.List^.Count-1 Then
    Begin
     ws := P^.GetText(c+1,P^.List^.Count);
     TempStr:=Copy(ws,1+CClient+1+CDocNumer+1,CDate);
     If TempStr<>DateStr Then
      Begin
       {DateStr:=TempStr;}
       PrintDate:=True;
       PrintItog:=True;
      End;
    End
    Else PrintItog:=True;
  End;



        If Tip In [0..8] Then
        BEgin
        Itogo[Tip]:=Itogo[Tip]+StrToReal(Summa);
        ISkid[Tip]:=Iskid[Tip]+StrToReal(Skidka);
        Litr[Tip]:=Litr[Tip]+StrToReal(SLocLitr);
        NDS[Tip]:=NDS[Tip]+StrToReal(SLocNDS);
        NDSZ[Tip]:=NDSZ[Tip]+StrToReal(SLocNDSZ);
        AllNDS20[Tip]:=AllNDS20[Tip]+StrToReal(SLocNDS20);
        AllNDS10[Tip]:=AllNDS10[Tip]+StrToReal(SLocNDS10);
        AllNDS_ [Tip]:=AllNDS_ [Tip]+StrToReal(SLocNDS_);
        ZakupkaOutNDS[TIP]:=ZakupkaOutNDS[TIP]+StrToReal(SLocZakupkaOutNDS);
        End;

        OplataOutNDS[0]:=#0;
        MyStr(StrToReal(Summa)-StrToReal(SLocNDS),CIZenaK,CMantissa,OplataOutNDS);


        Case Tip of
        8:ws:='Дебит СФБ';
        7:ws:='Дебит';
        6:ws:='Дебит СФ*';
        5:ws:='Дебит*';
        4:ws:='СФ Б';
        3:ws:='СФ*';
        2:ws:='Физ.лиц*';
        1:ws:='Тов.Чек*';
        0:ws:='Список';
        Else ws[0]:=#0;
        End;

        Format(ws,9);
        S:=SClient+SeparatorChar+SClientKod+SeparatorChar+As.EditPosition+SeparatorChar+
        As.D+SeparatorChar+Summa+SeparatorChar+OplataOutNDS+SeparatorChar+SLoCNDS20+SeparatorChar+SLoCNDS10+SeparatorChar+
        SLoCNDS_+SeparatorChar+SLocZakupkaOutNDS+SeparatorChar+SLocLitr+SeparatorChar+Ws;


    If c=(P^.List^.Count-1) Then s:=ONLYLINK+S;

     Writeln(f,Space+s);


  If Sorting = 1 Then
Begin
 If PrintItog Then
 Begin
 Writeln(f,Space,'── Всего за:'+DateStr+' к оплате: ', RecognizReal(LocLocOpl,CIZena,CMantissa),
{' в т.ч. НДС: ', RecognizReal(LocLocNDS,CIZena,CMantissaZ),
 ' к оплате без НДС: ', RecognizReal(LocLocZ,CIZena,CMantissaZ),}
 ' по ЗЦ без НДС: ', RecognizReal(LocLocZOutNDS,CIZena,CMantissaZ),
 ' литров: ', RecognizReal(LocLocLitr,CInputIZena,CLitrMantissa),
 ' док-тов: ',LocLocDoc:3,' ───');
 DateStr:=TempStr;
 LocLocOpl:=0;
 LocLocNDS:=0;
 LocLocZ:=0;
 LocLocZOutNDS:=0;
 LocLocLitr:=0;
 LocLocDoc:=0;
 End;
 If PrintDate Then
 Writeln(f,Space+'Дата: '+DateStr);
end;

End;{AgKod}
  End;
 Writeln(f,Space+'────────────────────────────────────────────────────────────────────────────────────────'+
 '──────────────────────────────'+
 NoCondensed[Nprint^.DAt.Printer]);


 Summa[0]:=#0;
 For c:=0 To 8 Do MyStr(StrToReal(Summa)+Itogo[c],CIZena,CMantissa,Summa);

 Skidka[0]:=#0;
 For c:=0 To 8 Do MyStr(StrToReal(Skidka)+ISkid[c],CIZena,CMantissa,SKidka);

 s:='Всего по ценам к оплате: '+Recogniz(Summa)+' руб '+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
        If Abs(Itogo[c])>=0.01 Then
         Begin
          Case c Of
          0:ws:=ws+Space+Spisok+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          1:ws:=ws+Space+TovChek+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          2:ws:=ws+Space+FizLico+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          3:ws:=ws+Space+SFDOC+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          4:ws:=ws+Space+SFDOCBN+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          5:ws:=ws+Space+Debit1DOC+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          6:ws:=ws+Space+DebitSF+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          7:ws:=ws+Space+Debit2Doc+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          8:ws:=ws+Space+DebitSFB+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          Else ;
          End;
         End;
  End;
 Writeln(f,Space+s+ws);



 s:='Всего НДС: '+Recogniz(SNDS)+' руб '+^M;
 Writeln(f,Space+s);
 If NDS20>0.009 Then
 Begin
 s:='В том числе 20%:'+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(AllNDS20[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+Spisok+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     1:ws:=ws+Space+TovChek+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     2:ws:=ws+Space+FizLico+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     3:ws:=ws+Space+SFDOC+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     4:ws:=ws+Space+SFDOCBN+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     5:ws:=ws+Space+Debit1DOC+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     6:ws:=ws+Space+DebitSF+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     7:ws:=ws+Space+Debit2Doc+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     8:ws:=ws+Space+DebitSFB+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     Else ;
     End;
    End;
  End;
 End;
 Writeln(f,Space+s+ws);

 If NDS10>0.009 Then
 Begin
 s:='            10%:'+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(AllNDS10[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+Spisok+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     1:ws:=ws+Space+TovChek+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     2:ws:=ws+Space+FizLico+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     3:ws:=ws+Space+SFDOC+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     4:ws:=ws+Space+SFDOCBN+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     5:ws:=ws+Space+Debit1DOC+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     6:ws:=ws+Space+DebitSF+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     7:ws:=ws+Space+Debit2Doc+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     8:ws:=ws+Space+DebitSFB+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     Else ;
     End;
    End;
  End;
 Writeln(f,Space+s+ws);
 End;

 If NDS_>0.009 Then
 Begin
 s:='            прочее:'+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(AllNDS_[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+Spisok+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     1:ws:=ws+Space+TovChek+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     2:ws:=ws+Space+FizLico+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     3:ws:=ws+Space+SFDOC+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     4:ws:=ws+Space+SFDOCBN+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     5:ws:=ws+Space+Debit1DOC+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     6:ws:=ws+Space+DebitSF+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     7:ws:=ws+Space+Debit2Doc+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     8:ws:=ws+Space+DebitSFB+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     Else ;
     End;
    End;
  End;
 Writeln(f,Space+s+ws);
 End;

 s:='Всего литров: '+Recogniz(SAllLitr)+' л '+^M;
 If STrToReal(SAllLitr)>0.0009 Then
 Begin
 s:=s+'В том числе:'+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(Litr[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+Spisok+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     1:ws:=ws+Space+TovChek+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     2:ws:=ws+Space+FizLico+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     3:ws:=ws+Space+SFDOC+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     4:ws:=ws+Space+SFDOCBN+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     5:ws:=ws+Space+Debit1DOC+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     6:ws:=ws+Space+DebitSF+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     7:ws:=ws+Space+Debit2Doc+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     8:ws:=ws+Space+DebitSFB+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     Else ;
     End;
    End;
  End;
 End;
 Writeln(f,Space+s+ws{,Litr[1]:CIZena:CMAntissa,Litr[2]:CIZena:CMAntissa,Litr[3]:CIZena:CMAntissa,Litr[4]:CIZena:CMAntissa,
 Litr[5]:CIZena:CMAntissa,Litr[6]:CIZena:CMAntissa,Litr[7]:CIZena:CMAntissa,Litr[8]:CIZena:CMAntissa});


 s:='Всего по ЗЦ без НДС: '+Recogniz(SZakupkaOutNDS)+' руб '+^M;
 s:=s+'В том числе:'+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(ZakupkaOutNDS[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+Spisok+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     1:ws:=ws+Space+TovChek+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     2:ws:=ws+Space+FizLico+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     3:ws:=ws+Space+SFDOC+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     4:ws:=ws+Space+SFDOCBN+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     5:ws:=ws+Space+Debit1DOC+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     6:ws:=ws+Space+DebitSF+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     7:ws:=ws+Space+Debit2Doc+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     8:ws:=ws+Space+DebitSFB+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     Else ;
     End;
    End;
  End;
 Writeln(f,Space+s+ws);

 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'============================================================================================');

 System.Close(f);
 Dispose(Agent,Done);

 NoInfoMsg;
 ViewAsText(Path^.Dat.ToTemp+'list.txt','Отчет реестр документов отгрузки (форма 4) за период с '+
StartDate+' по '+StopDate,True);
 If Izmen=1 Then
 MessageBox(^M+#3'В справку включены только изменявшиеся документы!',Nil,mfWarning+mfCancelButton);;
 {ReportNew(Path^.Dat.ToTemp+'list.txt','',1,False,False);}
 End;
End;
*)


Procedure FormReport4(Const P:PBox;StartDate,StopDAte:TDAteString;Sorting:Word;
FiltrDoc:Maska9;FiltrRash:Maska3;sertifword,Izmen:Word;FiltrOtdel:Maska8);
Const Space='';
     Spisok=' Список:   ';
     TovChek=' Тов.Чек*: ';
     FizLico=' Физ.лицо*:';
     SFDOC=' С/Ф*:     ';
     SFDOCBN=' С/Ф Б:    ';
     DEBIT1DOC=' Дебит*:   ';
     DEBITSF=' Дебит СФ*:';
     DEBIT2DOC=' Дебит    :';
     DEBITSFB=' Дебит СФБ:';

Var f : text;
         SVersia,Skidka,Summa,ws,s : String;
         AllLitr,NDSZ,NDS,Zakupka,Litr,AllNDS20,AllNDS18,AllNDS16,AllNDS10,AllNDS_,

            ZakupkaOutNDS,Itogo,ISkid : Array[0..8] Of Real;
         c,k,VidZak : Word;
         Open : String;
      As : DocumentEditZ;
      Tip : Word;
      SAllLitr,SNDS,SNDSZ,SClient,SLitr,SZakupka,SZakupkaOutNDS,SEkspeditor,
      OplataOutNDS,
         SLocNDS,SLocNDSZ,SLocNDS20,SLocNDS10,SLocNDS18,SLocNDS16,SLocNDS_,SLocLitr,
            SLocZakupkaOutNDS : AllStr;
      Agent : PBox;
      AgKod : AllStr;
      R : TRect;
      E : PSuperMArketType;
      TempStr,DateStr,SClientKod,SDoc,SDAte : TDAteString;
      NDS20,NDS18,NDS16,NDS10,NDS_,
      LocNDS,LocNDS20,LocNDS10,LocNDS18,LocNDS16,LocNDS_,LocLitr,
         LocZakupkaOutNDS,LocNDSZ:Real;
      PrintItog,PrintDate : Boolean;
      sertif2 : Maska2;
      LocLocOpl,LocLocNDS,LocLocZ,LocLocZOutNDS,LocLocLitr : Real;
      LocLocDoc:Word;

Begin


If (P^.List<>Nil) And (P^.List^.Count>=1) Then
 Begin


 VidZak:=SelectImport(17);
 If VidZak=2 Then Exit;


 Assign (f,Path^.Dat.ToTemp+'list4.txt');
 c:=0;
 Rewrite(f);
 c:=IOResult;
 If c<>0 Then
  Begin
        MessageBox(#3^m+#3+'Не могу создать файл '+Path^.Dat.ToTemp+'list4.txt',Nil,mfError+mfCancelButton);
   Exit;
  End;


R.Assign(0, 0, 0, 0);
Agent := New(PBox, Init(R, 1, Nil));
Agent^.NewList(New(PTextCollection, Init(0,1)));

If Not(SelectionAgent(Agent)) Then
 Begin
  System.Close(f);
  Dispose(Agent,Done);
  Exit;
 End;

 Writeln(f,Header+Space+ 'Склад: ',GetClientField(FClient,Rek^.Dat.Kod,1)+'  Оператор: '+CurrentPassword+' EYE & 1997-98');

 Write(f,Space+'Вид сортировки:');
 Case Sorting Of
 0:Writeln(f,Space+'"Клиент"');
 1:Writeln(f,Space+'"Номер документа"');
 2:Writeln(f,Space+'"Сумма отгрузки"');
 3:Writeln(f,Space+'"Сумма скидки"');
 Else Writeln(f);
 End;

 Writeln(f,Space+'Включены в рассмотрение виды документов:');
 Write(f,Space);
 For c:=1 To Max9 Do
  Begin
   If FiltrDoc[c]=1 Then
    Case c Of
    1:Write(f,' "Список" ');
    2:Write(f,' "Тов.Чек*" ');
    3:Write(f,' "Физ.Л*" ');
    4:Write(f,' "СФ*" ');
    5:Write(f,' "СФ Б" ');
    6:Write(f,' "Дебит*" ');
    7:Write(f,' "Дебит СФ*" ');
    8:Write(f,' "Дебит" ');
    9:Write(f,' "Дебит СФБ" ');
    Else;
    End;
  End;
 Writeln(f);

 Writeln(f,Space+'Включены в рассмотрение виды расчета:');
 Write(f,Space);
 For c:=1 To Max3 Do
  Begin
   If FiltrRash[c]=1 Then
    Case c Of
    1:Write(f,' "Наличный" ');
    2:Write(f,' "Безналичн." ');
    3:Write(f,' "Вексель" ');
    Else;
    End;
  End;
 Writeln(f);

 Writeln(f);

 Write(f,Space+'Вид отгрузки: ');
 WordToBit2(sertifword,sertif2);
 Convert2(sertif2);

 If Sertif2[1]=1 Then Write(f,'"Товар" ');
 If Sertif2[2]=1 Then Write(f,'"Сопроводительные документы"');

 Writeln(f);

 Write(f,Space+'Вид закупки:');
 Case VidZak Of
 0:Writeln(f,Space+'"Закупка для бухгалтерии"');
 1:Writeln(f,Space+'"Закупка 2"');
 Else Writeln(f);
 End;
 Writeln(f);

 Writeln(f,Space+'Включены в рассмотрение отгрузки по отделениям:');
 Write(f,Space);
 For c:=1 To CDivision Do
  Begin
   If FiltrOtdel[c]=1 Then Write(f,' "'+IntToStr(c,COne)+'" ');
  End;
 Writeln(f);

 Writeln(f);

 If Izmen=1 Then
 Begin
  Writeln(f,Space+'Внимание! В справку включены только изменявшиеся документы!');
  Writeln(f);
 End;

Case TestOpenDate1(StopDate) Of
False  :Open:='заблокирован';
True   :Open:='не заблокирован';
Else;
End;

 Writeln(f,Space+'                                              Доступ к данным за '+StopDate+' '+Open);

 Writeln(f,Space+'РЕЕСТР ДОКУМ-ОВ ОТГРУЗКИ ТОВАРА И СОПРОВОД.ДОКУМ-ОВ'+' с '+StartDate+' по '+StopDate+
 ' ('+FDate+' '+Times+')');
 WriteLn(f,Space+'Форма N 4');

Writeln(f,GlobalPrn^.Dat.Condensed[Nprint^.DAt.Printer]+
GlobalPrn^.Dat.MinInterval2[Nprint^.DAt.Printer]);
Writeln(f, Space+'┌───────────────────┬─────┬────┬────────┬──────────┬──────────┬───────────────────────────────────────────'+
'┬────────────┬─────────┬─────────┐');
Writeln(f, Space+'│                   │     │    │        │ Сумма по │ Сумма по │                 В т.ч. НДС                '+
'│  Сумма по  │         │Тип доку-│');
Writeln(f, Space+'│    Клиент         │Код  │Док.│  Дата  │   ценам  │ценам опл.│──────────┬──────────┬──────────┬──────────'+
'│ зак.ценам  │  Литров │  мента  │');
Writeln(f, Space+'│                   │     │    │        │ к оплате │  без НДС │   20%    │    18%   │    10%   │  Прочее  '+
'│  без НДС   │         │         │');
Writeln(f, Space+'└───────────────────┴─────┴────┴────────┴──────────┴──────────┴──────────┴──────────┴──────────┴──────────'+
'┴────────────┴─────────┴─────────┘'+
+GlobalPrn^.Dat.Normal[Nprint^.DAt.Printer]+HeaderStop);
                 {12345678901234567890│12345│1234│12345678│1234567890│12345678│12345678│12345678│1234567890│123456789│}

 For c:=0 To 8 Do
 Begin
  ISkid[c]:=0;
  Itogo[c]:=0;
  AllNDS20[c]:=0;
  AllNDS18[c]:=0;
  AllNDS16[c]:=0;
  AllNDS10[c]:=0;
  AllNDS_[c]:=0;
  AllLitr[c]:=0;
  ZakupkaOutNDS[c]:=0;
  Litr[c]:=0;
  NDS[c]:=0;
  NDSZ[c]:=0;
 End;

SZakupkaOutNDS[0]:=#0;
SAllLitr[0]:=#0;
SNDS[0]:=#0;
SNDSZ[0]:=#0;

NDS20:=0;
NDS18:=0;
NDS16:=0;
NDS10:=0;
NDS_:=0;


MyStr(StrToReal(SZakupkaOutNDS),CIZenaK,CMAntissa,SZakupkaOutNDS);
MyStr(StrToReal(SAllLitr),CZena,CLitrMantissa,SAllLitr);
MyStr(StrToReal(SNDS),CZena,CMantissa,SNDS);


If Sorting=1 Then
Begin
s := P^.GetText(0,P^.List^.Count);
DateStr:=Copy(s,1+CClient+1+CDocNumer+1,CDate);
Writeln(f,Space+'Дата: '+DateStr);
End;


 LocLocOpl:=0;
 LocLocNDS:=0;
 LocLocZ:=0;
 LocLocZOutNDS:=0;
 LocLocLitr:=0;
 LocLocDoc:=0;



 For c:=0 To P^.List^.Count-1 Do
  Begin
     DInfoMsgShkala('Формирую отчет за период с '+StartDate+' по '+StopDate+' ...',0,P^.List^.Count-1,c);

   PrintItog:=False;
   PrintDate:=False;


     s := P^.GetText(c,P^.List^.Count);
     AgKod:=Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+COne+1+CKto+1+CDate+1+CDAte+1+CClient+2,
        CClientKod);

If TestAgent(Agent,AgKod) Then
Begin
As.EditPosition:=Copy(s,1+CClient+1,CDocNumer);
As.D:={Copy(s,Ord(s[0])-CArtikul-1-CDAte-1-CMantissa,CDate);;}
      Copy(s,1+CClient+1+CDocNumer+1,CDate);

        While Pos('│',s)>0 Do
         Begin
          k:=Pos('│',s);
          System.Delete(s,k,1);
          System.Insert(SeparatorChar,s,k);
         End;
         SVersia:=Copy(s,Ord(S[0])-CArtikul-CMantissa,CMantissa);
         {Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+COne+1+CKto+1+CDate+1+CDAte+1+CClient+2,
                  CClientKod);}
         If StrToInt(SVersia)>1 Then SVersia:='!'
         Else SVersia[0]:=#0;

        SEkspeditor:=
           Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+COne+1+CKto+1+CDate+1+CDAte+1+CClient+2+
                 CClientKod+1,CClient);
        s[0]:=Chr(1+CClient+1+CDocNumer+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1+COne+1+CKto);

        SClient:=Copy(s,1,CCLient);
        As.EditPosition := Copy(s,1+CCLient+1,CDocNumer);
        As.D := Copy(s,1+CCLient+1+CDocNumer+1,CDAte);
        Summa:=Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CDate+1,CIZenaK);
        Skidka:=Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CDate+1+CIZenaK+1,CIZenaK);
        MyStr(StrToReal(Summa)-StrToReal(Skidka),CIZenaK,CMantissa,Summa);
        ws:=Copy(s,1+CClient+1+CDocNumer+1+CDate+1+CDate+1+CIZenaK+1+CIZenaK+1,COne);
        Tip:=StrToInt(Ws);

        New(E,Init);
        GetMArket1(As,E);
        SClientKod:=IntToStr(E^.DAt.OperatorSelector,COne)+E^.DAt.ClientKod;

        CalcNDS2(FiltrOtdel,Sertif2,E,VidZak,LocNDS,LocNDS20,LocNDS10,LocNDS_,LocNDS18,LocNDS16,LocLitr,
	   LocZakupkaOutNDS,LocNDSZ);

        MySTr(LocNDS,CIZenaK,CMAntissa,SLocNDS);
        MySTr(LocNDSZ,CIZenaK,CMAntissa,SLocNDSZ);
        MySTr(LocNDS20,CIZenaK,CMAntissa,SLocNDS20);
        MySTr(LocNDS10,CIZenaK,CMAntissa,SLocNDS10);
        MySTr(LocNDS18,CIZenaK,CMAntissa,SLocNDS18);
        MySTr(LocNDS16,CIZenaK,CMAntissa,SLocNDS16);
        MySTr(LocNDS_,CIZenaK,CMAntissa,SLocNDS_);
        MySTr(LocZakupkaOutNDS,CIZenaK+2,CMAntissaZ,SLocZakupkaOutNDS);
        MySTr(LocLitr,CIZenaK,CLitrMAntissa,SLocLitr);

        NDS20:=NDS20+StrToReal(SLocNDS20);
        NDS18:=NDS18+StrToReal(SLocNDS18);
        NDS16:=NDS16+StrToReal(SLocNDS16);
        NDS10:=NDS10+StrToReal(SLocNDS10);
        NDS_:=NDS_+StrToReal(SLocNDS_);

        Dispose(E,Done);

        MyStr(StrToReal(SZakupkaOutNDS)+StrToReal(SLocZakupkaOutNDS),CIZenaK+2,CMAntissaZ,SZakupkaOutNDS);
        MyStr(StrToReal(SAllLitr)+StrToReal(SLocLitr),CIZenaK,CLitrMantissa,SAllLitr);
        MyStr(StrToReal(SNDS)+StrToReal(SLocNDS),CIZenaK,CMantissa,SNDS);


  If Sorting=1 Then
   Begin
     LocLocOpl:=LocLocOpl+StrToReal(Summa);
     LocLocNDS:=LocLocNDS+StrToReal(SLocNds);
     LocLocZ:=LocLocOpl-LocLocNDS;
     LocLocZOutNDS:=LocLocZOutNDS+StrToReal(SLocZakupkaOutNDS);
     LocLocLitr:=LocLocLitr+StrToReal(SLocLitr);
     Inc(LocLocDoc);
   End;



  If Sorting = 1 Then
  Begin
   If c<P^.List^.Count-1 Then
    Begin
     ws := P^.GetText(c+1,P^.List^.Count);
     TempStr:=Copy(ws,1+CClient+1+CDocNumer+1,CDate);
     If TempStr<>DateStr Then
      Begin
       {DateStr:=TempStr;}
       PrintDate:=True;
       PrintItog:=True;
      End;
    End
    Else PrintItog:=True;
  End;



        If Tip In [0..8] Then
        BEgin
        Itogo[Tip]:=Itogo[Tip]+StrToReal(Summa);
        ISkid[Tip]:=Iskid[Tip]+StrToReal(Skidka);
        Litr[Tip]:=Litr[Tip]+StrToReal(SLocLitr);
        NDS[Tip]:=NDS[Tip]+StrToReal(SLocNDS);
        NDSZ[Tip]:=NDSZ[Tip]+StrToReal(SLocNDSZ);
        AllNDS20[Tip]:=AllNDS20[Tip]+StrToReal(SLocNDS20);
        AllNDS10[Tip]:=AllNDS10[Tip]+StrToReal(SLocNDS10);
        AllNDS18[Tip]:=AllNDS18[Tip]+StrToReal(SLocNDS18);
        AllNDS16[Tip]:=AllNDS16[Tip]+StrToReal(SLocNDS16);
        AllNDS_ [Tip]:=AllNDS_ [Tip]+StrToReal(SLocNDS_);
        ZakupkaOutNDS[TIP]:=ZakupkaOutNDS[TIP]+StrToReal(SLocZakupkaOutNDS);
        End;

        OplataOutNDS[0]:=#0;
        MyStr(StrToReal(Summa)-StrToReal(SLocNDS),CIZenaK,CMantissa,OplataOutNDS);


        Case Tip of
        8:ws:='Дебит СФБ';
        7:ws:='Дебит';
        6:ws:='Дебит СФ*';
        5:ws:='Дебит*';
        4:ws:='СФ Б';
        3:ws:='СФ*';
        2:ws:='Физ.лиц*';
        1:ws:='Тов.Чек*';
        0:ws:='Список';
        Else ws[0]:=#0;
        End;

        Format(ws,9);
        S:=SClient+SeparatorChar+SClientKod+SeparatorChar+As.EditPosition+SeparatorChar+
        As.D+SeparatorChar+Summa+SeparatorChar+OplataOutNDS+SeparatorChar+SLoCNDS20+SeparatorChar+SLoCNDS18+
	   SeparatorChar+SLoCNDS10+SeparatorChar+
        SLoCNDS_+SeparatorChar+SLocZakupkaOutNDS+SeparatorChar+SLocLitr+SeparatorChar+Ws;


    If c=(P^.List^.Count-1) Then s:=ONLYLINK+S;

     Writeln(f,Space+s);


  If Sorting = 1 Then
Begin
 If PrintItog Then
 Begin
 Writeln(f,Space,'── Всего за:'+DateStr+' к оплате: ', RecognizReal(LocLocOpl,CIZena,CMantissa),
{' в т.ч. НДС: ', RecognizReal(LocLocNDS,CIZena,CMantissaZ),
 ' к оплате без НДС: ', RecognizReal(LocLocZ,CIZena,CMantissaZ),}
 ' по ЗЦ без НДС: ', RecognizReal(LocLocZOutNDS,CIZena,CMantissaZ),
 ' литров: ', RecognizReal(LocLocLitr,CInputIZena,CLitrMantissa),
 ' док-тов: ',LocLocDoc:3,' ───');
 DateStr:=TempStr;
 LocLocOpl:=0;
 LocLocNDS:=0;
 LocLocZ:=0;
 LocLocZOutNDS:=0;
 LocLocLitr:=0;
 LocLocDoc:=0;
 End;
 If PrintDate Then
 Writeln(f,Space+'Дата: '+DateStr);
end;

End;{AgKod}
  End;
 Writeln(f,Space+'────────────────────────────────────────────────────────────────────────────────────────'+
 '──────────────────────────────'+
 GlobalPrn^.Dat.NoCondensed[Nprint^.DAt.Printer]);


 Summa[0]:=#0;
 For c:=0 To 8 Do MyStr(StrToReal(Summa)+Itogo[c],CIZena,CMantissa,Summa);

 Skidka[0]:=#0;
 For c:=0 To 8 Do MyStr(StrToReal(Skidka)+ISkid[c],CIZena,CMantissa,SKidka);

 s:='Всего по ценам к оплате: '+Recogniz(Summa)+' руб '+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
        If Abs(Itogo[c])>=0.01 Then
         Begin
          Case c Of
          0:ws:=ws+Space+Spisok+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          1:ws:=ws+Space+TovChek+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          2:ws:=ws+Space+FizLico+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          3:ws:=ws+Space+SFDOC+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          4:ws:=ws+Space+SFDOCBN+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          5:ws:=ws+Space+Debit1DOC+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          6:ws:=ws+Space+DebitSF+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          7:ws:=ws+Space+Debit2Doc+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          8:ws:=ws+Space+DebitSFB+RecognizReal(Itogo[c],CIZena,CMantissa)+' '+^M;
          Else ;
          End;
         End;
  End;
 Writeln(f,Space+s+ws);



 s:='Всего НДС: '+Recogniz(SNDS)+' руб '+^M;
 Writeln(f,Space+s);

 If NDS20>0.009 Then
 Begin
 s:='В том числе 20%:'+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(AllNDS20[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+Spisok+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     1:ws:=ws+Space+TovChek+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     2:ws:=ws+Space+FizLico+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     3:ws:=ws+Space+SFDOC+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     4:ws:=ws+Space+SFDOCBN+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     5:ws:=ws+Space+Debit1DOC+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     6:ws:=ws+Space+DebitSF+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     7:ws:=ws+Space+Debit2Doc+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     8:ws:=ws+Space+DebitSFB+RecognizReal(AllNDS20[c],CIZenaK,CMantissa)+' '+^M;
     Else ;
     End;
    End;
  End;
  If ws[0]<>#0 Then Writeln(f,Space+s+ws);
 End;


 ws[0]:=#0;
 s[0]:=#0;
 If NDS18>0.009 Then
 Begin
 s:='            18%:'+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(AllNDS18[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+Spisok+RecognizReal(AllNDS18[c],CIZenaK,CMantissa)+' '+^M;
     1:ws:=ws+Space+TovChek+RecognizReal(AllNDS18[c],CIZenaK,CMantissa)+' '+^M;
     2:ws:=ws+Space+FizLico+RecognizReal(AllNDS18[c],CIZenaK,CMantissa)+' '+^M;
     3:ws:=ws+Space+SFDOC+RecognizReal(AllNDS18[c],CIZenaK,CMantissa)+' '+^M;
     4:ws:=ws+Space+SFDOCBN+RecognizReal(AllNDS18[c],CIZenaK,CMantissa)+' '+^M;
     5:ws:=ws+Space+Debit1DOC+RecognizReal(AllNDS18[c],CIZenaK,CMantissa)+' '+^M;
     6:ws:=ws+Space+DebitSF+RecognizReal(AllNDS18[c],CIZenaK,CMantissa)+' '+^M;
     7:ws:=ws+Space+Debit2Doc+RecognizReal(AllNDS18[c],CIZenaK,CMantissa)+' '+^M;
     8:ws:=ws+Space+DebitSFB+RecognizReal(AllNDS18[c],CIZenaK,CMantissa)+' '+^M;
     Else ;
     End;
    End;{If}
  End;{For}
  If ws[0]<>#0 Then Writeln(f,Space+s+ws);
 End;

 ws[0]:=#0;
 s[0]:=#0;
 If NDS16>0.009 Then
 Begin
 s:='            16%:'+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(AllNDS16[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+Spisok+RecognizReal(AllNDS16[c],CIZenaK,CMantissa)+' '+^M;
     1:ws:=ws+Space+TovChek+RecognizReal(AllNDS16[c],CIZenaK,CMantissa)+' '+^M;
     2:ws:=ws+Space+FizLico+RecognizReal(AllNDS16[c],CIZenaK,CMantissa)+' '+^M;
     3:ws:=ws+Space+SFDOC+RecognizReal(AllNDS16[c],CIZenaK,CMantissa)+' '+^M;
     4:ws:=ws+Space+SFDOCBN+RecognizReal(AllNDS16[c],CIZenaK,CMantissa)+' '+^M;
     5:ws:=ws+Space+Debit1DOC+RecognizReal(AllNDS16[c],CIZenaK,CMantissa)+' '+^M;
     6:ws:=ws+Space+DebitSF+RecognizReal(AllNDS16[c],CIZenaK,CMantissa)+' '+^M;
     7:ws:=ws+Space+Debit2Doc+RecognizReal(AllNDS16[c],CIZenaK,CMantissa)+' '+^M;
     8:ws:=ws+Space+DebitSFB+RecognizReal(AllNDS16[c],CIZenaK,CMantissa)+' '+^M;
     Else ;
     End;
    End;{If}
  End;{For}
  If ws[0]<>#0 Then Writeln(f,Space+s+ws);
 End;



 ws[0]:=#0;
 s[0]:=#0;
 If NDS10>0.009 Then
 Begin
 s:='            10%:'+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(AllNDS10[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+Spisok+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     1:ws:=ws+Space+TovChek+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     2:ws:=ws+Space+FizLico+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     3:ws:=ws+Space+SFDOC+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     4:ws:=ws+Space+SFDOCBN+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     5:ws:=ws+Space+Debit1DOC+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     6:ws:=ws+Space+DebitSF+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     7:ws:=ws+Space+Debit2Doc+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     8:ws:=ws+Space+DebitSFB+RecognizReal(AllNDS10[c],CIZenaK,CMantissa)++^M;
     Else ;
     End;
    End;
  End;
  If ws[0]<>#0 Then Writeln(f,Space+s+ws);
 End;

 ws[0]:=#0;
 s[0]:=#0;
 If NDS_>0.009 Then
 Begin
 s:='            прочее:'+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(AllNDS_[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+Spisok+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     1:ws:=ws+Space+TovChek+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     2:ws:=ws+Space+FizLico+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     3:ws:=ws+Space+SFDOC+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     4:ws:=ws+Space+SFDOCBN+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     5:ws:=ws+Space+Debit1DOC+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     6:ws:=ws+Space+DebitSF+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     7:ws:=ws+Space+Debit2Doc+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     8:ws:=ws+Space+DebitSFB+RecognizReal(AllNDS_[c],CIZenaK,CMantissa)+' '+^M;
     Else ;
     End;
    End;
  End;
  If ws[0]<>#0 Then Writeln(f,Space+s+ws);
 End;

 ws[0]:=#0;
 s[0]:=#0;
 s:='Всего литров: '+Recogniz(SAllLitr)+' л '+^M;
 If STrToReal(SAllLitr)>0.0009 Then
 Begin
 s:=s+'В том числе:'+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(Litr[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+Spisok+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     1:ws:=ws+Space+TovChek+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     2:ws:=ws+Space+FizLico+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     3:ws:=ws+Space+SFDOC+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     4:ws:=ws+Space+SFDOCBN+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     5:ws:=ws+Space+Debit1DOC+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     6:ws:=ws+Space+DebitSF+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     7:ws:=ws+Space+Debit2Doc+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     8:ws:=ws+Space+DebitSFB+RecognizReal(Litr[c],CIZenaK,CLitrMantissa)+' '+^M;
     Else ;
     End;
    End;
  End;
  If ws[0]<>#0 Then Writeln(f,Space+s+ws);
 End;


 ws[0]:=#0;
 s[0]:=#0;
 s:='Всего по ЗЦ без НДС: '+Recogniz(SZakupkaOutNDS)+' руб '+^M;
 s:=s+'В том числе:'+^M;
 ws[0]:=#0;
 For c:=0 To 8 Do
  Begin
   If Abs(ZakupkaOutNDS[c])>=0.01 Then
    Begin
     Case c Of
     0:ws:=ws+Space+Spisok+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     1:ws:=ws+Space+TovChek+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     2:ws:=ws+Space+FizLico+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     3:ws:=ws+Space+SFDOC+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     4:ws:=ws+Space+SFDOCBN+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     5:ws:=ws+Space+Debit1DOC+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     6:ws:=ws+Space+DebitSF+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     7:ws:=ws+Space+Debit2Doc+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     8:ws:=ws+Space+DebitSFB+RecognizReal(ZakupkaOutNDS[c],CIZenaK+2,CLitrMantissa)+' '+^M;
     Else ;
     End;
    End;
  End;
 Writeln(f,Space+s+ws);

 Writeln(f,Space,'"'+DayString[DayOfWeek(ToDay)]+'" '+TodayString(DateMask)+'('+Times+')');
 Writeln(f,Space+'============================================================================================');

 System.Close(f);
 Dispose(Agent,Done);

 NoInfoMsg;
 ViewAsText(Path^.Dat.ToTemp+'list4.txt',
'Отчет реестр отгрузки форма 4 за период с '+
StartDate+' по '+StopDate,True);
 If Izmen=1 Then
 MessageBox(^M+#3'В справку включены только изменявшиеся документы!',Nil,mfWarning+mfCancelButton);;
 {ReportNew(Path^.Dat.ToTemp+'list.txt','',1,False,False);}
 End;
End;








function SelDoc(Var As:DocumentEditz):Boolean;
Label 1;
var
  R : TRect;
  Control1 : PView;
  Control2 : PbxEditLine;
  Dlg  : PbxEntryDialog;
  Dt: TbxDateRec;
  c : Word;
  l : LongInt;
  s,ss : TDateString;

begin
SelDoc:=False;

If Not(TestDate(As.D,L)) Then ss:=FDate
Else ss:=As.D;


1:

R.Assign(27, 10, 53, 13);
New(Dlg, Init(R, 'Укажите документ'));
Dlg^.Options := Dlg^.Options or ofCenterX or ofCenterY;
Dlg^.HelpCtx := $E002;
Dlg^.Palette := dpCyanDialog;

R.Assign(4, 1, 10, 2);
Control1 := New(PInputLine, Init(R, CDocNumer));
  PInputLine(Control1)^.Validator := New(PFilterValidator, Init(['1','2','3','4','5','6','7','8','9','0']));
Dlg^.Insert(Control1);

 Control1^.SetData(As.Editposition);

  R.Assign(1, 1, 4, 2);
  Dlg^.Insert(New(PLabel, Init(R, 'N:', Control1)));

 R.Assign(14, 1, 24, 2);
 Control2:= New(PbxDateEdit, Init(R, DateMask));
 Control2^.SetEditFlag(dfRequired, True);
 Dlg^.Insert(Control2);


 ExtractDateFromString(Dt,DateMask,ss);
 Control2^.SetData(Dt);

 R.Assign(10, 1, 14, 2);
 Dlg^.Insert(New(PLabel, Init(R, 'от:', Control2)));

Dlg^.SelectNext(False);

c:=Desktop^.ExecView(Dlg);

If c<>cmCancel Then
 Begin
  Control1^.GetData(As.EditPosition);
  DelSpace(As.EditPosition);
  Control2^.GetData(Dt);

  Ss:=DateToDateStr(DT,DateMask);
  DelSpace(ss);
  As.D:=ss;


   If As.EditPosition[0]=#0 Then
    Begin
     MessageBox(^M+#3'Не указан номер документа!',Nil,mfError+mfCancelButton);
     Dispose(Control1,Done);
     Dispose(Control2,Done);
     Dispose(Dlg,Done);
     Goto 1;
    End;

   If Not(TestDate(ss,L)) Then
    Begin
     MessageBox(^M+#3'Ошибка при вводе даты!',Nil,mfError+mfCancelButton);
     Dispose(Control1,Done);
     Dispose(Control2,Done);
     Dispose(Dlg,Done);
     Goto 1;
    End;

     SelDoc:=True;

     Dispose(Control1,Done);
     Dispose(Control2,Done);
     Dispose(Dlg,Done);
 End
Else
 Begin
  Dispose(Control1,Done);
  Dispose(Control2,Done);
  Dispose(Dlg,Done);
 End;

end;

(*
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
   NDS20:=0;NDS18:=0;NDS16:=0; NDS10:=0; NDS_:=0;Litr:=0;
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
*)





Procedure InitCash;{стартовая настройка обнуление всех дат и времени}
Var c : Word;
    R : TRect;
Begin
R.Assign(0,0,0,0);
For c:=0 To 99 Do
 Begin
  CasheTovarList[c].Tovar := New(PBox, Init(R, 1, Nil));
  CasheTovarList[c].Tovar^.NewList(New(PMyCollection, Init(0,1)));
  CasheTovarList[c].Time:=0;
  CasheTovarList[c].Last:=0;
  CasheTovarList[c].Refresh:=False;
  CasheTovarList[c].Employ:=False;
 End;

For c:=1 To 13 Do
 Begin
  SprList[c].Elements := New(PBox, Init(R, 1, Nil));
  SprList[c].Elements^.NewList(New(PMyCollection, Init(0,1)));
  SprList[c].Time:=0;
  SprList[c].Last:=0;
  SprList[c].Refresh:=False;
  SprList[c].Employ:=False;
 End;

End;


Procedure LoadCash;{тотальная загрузка справочников выполняется только при входе в систему
                    или смене объекта}
Var c : Word;
    BE : PBufBazType;
    BF : File;
    st : ArtikulStr;
    i : Word;
    count,cc : Word;
    s : String;
    SMain,SMarket,
    SEnableDebit,
    SVidNalog,SVidNDS,
    SEnableContract,SOtdel,
    SEmploy,SOKP,SBuchGroup,SEnablePrihod,
    SEnableSklads:AllStr;
    L : LongInt;
    FFF: ^Integer;
    R : RazdelFileType;
    RE : RazdelType;
    OldFileMode : Word;
    Fm : File;
    M : PBufMarkaType;
    SM : PBufSpecMarkaType;
    GTD : PBufNGTDType;
    KS : PBufKSertifType;
    KB : PBufBankType;
    KC : PBufClassificatorBuchType;
    Ex : PBufExpertType;
    Ps : PBufPostType;
    Gr : PBufGroupType;
    Mr : PBufMeraType;
    FP : PBufFirmaPostType;
    Index : Word;
    SKod : AllStr;

Begin
(*
If EnableCashe=1 Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
Assign(R,Path^.DAt.ToRazdel+'razdel.db');
L :=IOResult;
Reset(R);
L :=IOResult;
 FileMode:=OLDFileMode;
If L=0 Then
Begin
While Not(Eof(R)) Do
{For c:=0 To 99 Do}
 Begin
  DInfoMsgShkala('Минуточку. Выполняется подключение к базе данных ...',0,FileSize(r),FilePos(R));
  Read(R,RE);
  If RE.CAshe=1 Then
Begin
  c:=StrToInt(RE.Kod);
  st:=IntToStr(C,CMantissa);
  RFormatZerro(st,CMantissa);

  {If FileExists(Path^.Dat.ToName+st+'.id') Then}

 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;

 Assign(BF,Path^.Dat.TOName+st+'.id');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;

 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   CasheTovarList[c].Time:=L;
   CasheTovarList[c].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToName+st+'.id');
   i:=IOResult;
   Reset(BF,SizeOf(BazType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     CasheTovarList[c].Tovar^.NewList(Nil);
     CasheTovarList[c].Tovar^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(BE,Init);
     ReadBufBaz(BF,BE,Count);
     cc:=IOResult;

For cc:=1 To Count Do
Begin
     {If BE^.Point.Dat[cc].Employ Then}
     With BE^.Point.Dat[cc] Do
      Begin
          Format(Name,CNAme);
          Format(Name2,CNAme);
          DelSpaceRight(Name2);
          Format(Litr,CLitr);
          Format(InPack,CInPack);
          Format(InPack2,CInPack);
          Format(Massa,CMAssa);
          Format(Etil,CLitr);
          Format(Nalog,CLitr);
          Format(NDS,CLitr);

          Format(Marker,CLitrMantissa);
          Format(Min,CArtikul);
          SOtdel :=IntToStr(Otdel,CArtikul);
          Format(SOtdel,CArtikul);


          RFormatZerro(Mera,CClientKod);
          RFormatZerro(NGroupKod,CClientKod);
          Format(Contract,CContract);
          Format(ContractDate,CDate);
          Format(DSertif,CDate);
          RFormatZerro(BazKod,CArtikul);
          RFormatZerro(FantomKod,CArtikul);
          RFormatZerro(PostKod,CClientKod);
          RFormatZerro(FirmaPostKod,CClientKod);
          RFormatZerro(KSertif,CClientKod);
          RFormatZerro(Caption,CRazdelKod);
          SMain  :=IntToStr(Main,COne);
          SMarket:=IntToStr(Market,COne);
          SEnableDebit:=IntToStr(EnableDebit,COne);
          SVidNalog:=IntToStr(VidNalog,COne);
          SVidNDS  :=IntToStr(VidNDS,COne);
          SEnableContract:=IntToStr(EnableContract,COne);
          If Employ Then SEmploy:='1' Else SEmploy:='0';
          SOKP   :=IntToStr(OKP,9);
          SBuchGroup :=IntToStr(BuchGroup,9);
          SEnableSklads:=IntToStr(EnableSklads,9);
          SEnablePrihod:=IntToStr(Prihod,COne);

          Format(SOKP,9);
          Format(SBuchGroup,9);
          Format(SEnableSklads,9);
          RFormatZerro(Class,CClientKod);

       s:='│'+
	     BazKod+'│'+
          FantomKod+'│'+
          Litr+'│'+
          InPack+'│'+
          InPack2+'│'+
          Massa+'│'+
          Etil+'│'+
          Nalog+'│'+
          NDS+'│'+
          Mera+'│'+
          Contract+'│'+
          ContractDate+'│'+
          DSertif+'│'+
          PostKod+'│'+
          FirmaPostKod+'│'+
          KSertif+'│'+
          Caption+'│'+
          SMain+'│'+
          SMarket+'│'+
          SEnableDebit+'│'+
          SVidNalog+'│'+
          SVidNDS+'│'+
          SEnableContract+'│'+
          SEmploy+'│'+
          SOKP+'│'+
          SBuchGroup+'│'+
          SEnableSklads+'│'+
		NGroupKod+'│'+
		SEnablePrihod+'│'+
          SOtdel+'│'+{CArtikul}
          Marker+'│'+{CLitrMantissa}
          Min+'│'+{CArtikul}
          Class+'│'+{CArtikul}
	     Name+'│'+
          Name2;


       CasheTovarList[c].Tovar^.List^.Insert(NewStr(s));
       CasheTovarList[c].Tovar^.SetRange(CasheTovarList[c].Tovar^.List^.Count);

      End;{With}
End;{For cc}
     Dispose(BE,Done);

      End;{While}

     CasheTovarList[c].Refresh:=True;
     CasheTovarList[c].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
  End;{FileExist}
 End;{For}
End;
End;
 NoInfoMsg;
 i:=IOResult;
 Close(R);
 i:=IOResult;
End;
*)


If Compress=1 Then {разрешено кэширование справочников гтд акц и всякой хери}
Begin
DInfoMsg('Минуточку. Загружаю акцизные марки....',False);
{чтение акцизных марок}
 Index:=1;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'marka.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'marka.db');
   i:=IOResult;
   Reset(BF,SizeOf(MarkaType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(M,Init);
     ReadBufMarka(BF,M,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With M^.Point.Dat[cc] Do
      Begin
          Format(Marka,CMarka);
          DelSpaceRight(Marka);
          RFormatZerro(Kod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+Kod+'│'+SEmploy+'│'+Marka;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(M,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
  End;{l=0}

NoInfoMsg;

{чтение ГТД}
DInfoMsg('Минуточку. Загружаю ГТД....',False);
 Index:=2;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'ngtd.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'ngtd.db');
   i:=IOResult;
   Reset(BF,SizeOf(ngtdType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(GTD,Init);
     ReadBufngtd(BF,GTD,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With GTD^.Point.Dat[cc] Do
      Begin
          Format(ngtd,Cngtd);
          DelSpaceRight(ngtd);
          RFormatZerro(Kod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+Kod+'│'+SEmploy+'│'+ngtd;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(GTD,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
  End;


NoInfoMsg;

{чтение ГТД}
DInfoMsg('Минуточку. Загружаю экспертные заключения....',False);
{чтение  экспертных заключений}
 Index:=3;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'Expert.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'Expert.db');
   i:=IOResult;
   Reset(BF,SizeOf(ExpertType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(Ex,Init);
     ReadBufExpert(BF,Ex,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With Ex^.Point.Dat[cc] Do
      Begin
          Format(Expert,CExpert);
          DelSpaceRight(Expert);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+Expert;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(Ex,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
  End;



NoInfoMsg;

{чтение ГТД}
DInfoMsg('Минуточку. Загружаю специальные марки....',False);

{чтение спец.марок}
 Index:=4;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'SMarka.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'SMarka.db');
   i:=IOResult;
   Reset(BF,SizeOf(SpecMarkaType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(SM,Init);
     ReadBufSpecMarka(BF,SM,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With SM^.Point.Dat[cc] Do
      Begin
          Format(SpecMarka,CSpecMarka);
          DelSpaceRight(SpecMarka);
          RFormatZerro(Kod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+Kod+'│'+SEmploy+'│'+SpecMarka;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);

      End;{With}
End;{For cc}
     Dispose(SM,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
  End;


NoInfoMsg;

{чтение ГТД}
DInfoMsg('Минуточку. Загружаю органы сертификации....',False);

{чтение органов сертификации}
 Index:=5;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'ksertif.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'ksertif.db');
   i:=IOResult;
   Reset(BF,SizeOf(KSertifType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(KS,Init);
     ReadBufKSertif(BF,KS,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With KS^.Point.Dat[cc] Do
      Begin
          Format(KSertif,CKSertif);
          DelSpaceRight(KSertif);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+KSertif;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(KS,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
  End;

NoInfoMsg;




{чтение ГТД}
DInfoMsg('Минуточку. Загружаю страны происхождения....',False);
{чтение стран}
 Index:=6;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'Lands.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'Lands.db');
   i:=IOResult;
   Reset(BF,SizeOf(PostType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(PS,Init);
     ReadBufPost(BF,PS,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With PS^.Point.Dat[cc] Do
      Begin
          Format(Post,CPost);
          DelSpaceRight(Post);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+Post;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(PS,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
  End;

NoInfoMsg;

{чтение ГТД}
DInfoMsg('Минуточку. Загружаю фирмы-производители....',False);
{чтение Фирм-производителей}
 Index:=7;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'firma.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'firma.db');
   i:=IOResult;
   Reset(BF,SizeOf(FirmaPostType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(FP,Init);
     ReadBufFirmaPost(BF,FP,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With FP^.Point.Dat[cc] Do
      Begin
          Format(FirmaPost,CFirmaPost);
          DelSpaceRight(FirmaPost);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+FirmaPost;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(FP,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
  End;


NoInfoMsg;

{чтение ГТД}
DInfoMsg('Минуточку. Загружаю единицы измерения....',False);
{чтение единиц измерения}
 Index:=8;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'mera.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'mera.db');
   i:=IOResult;
   Reset(BF,SizeOf(MeraType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(Mr,Init);
     ReadBufMera(BF,Mr,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With Mr^.Point.Dat[cc] Do
      Begin
          Format(Mera,CMera);
          DelSpaceRight(Mera);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+Mera;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(Mr,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
  End;

NoInfoMsg;

{чтение ГТД}
DInfoMsg('Минуточку. Загружаю группы....',False);
{чтение групп продаж}
 Index:=9;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'Group.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'Group.db');
   i:=IOResult;
   Reset(BF,SizeOf(GroupType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(Gr,Init);
     ReadBufGroup(BF,Gr,Count);
     cc:=IOResult;

For cc:=1 To Count Do
Begin
     With Gr^.Point.Dat[cc] Do
      Begin
          Format(GroupName,CName);
          DelSpaceRight(GroupName);
          RFormatZerro(Kod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+Kod+'│'+SEmploy+'│'+GroupName;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(Gr,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
  End;

{регионы и маршруты пока не делаем}

NoInfoMsg;

{чтение ГТД}
DInfoMsg('Минуточку. Загружаю классификатор продукции....',False);

{чтение органов сертификации}
 Index:=12;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'class.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'class.db');
   i:=IOResult;
   Reset(BF,SizeOf(ClassificatorBuchType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(KC,Init);
     ReadBufClass(BF,KC,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With KC^.Point.Dat[cc] Do
      Begin
          Format(Name,CSertif);
          DelSpaceRight(Name);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+Name;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(KC,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
  End;

NoInfoMsg;


{чтение ГТД}
DInfoMsg('Минуточку. Загружаю справочник банков....',False);

{чтение органов сертификации}
 Index:=13;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'banks.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'banks.db');
   i:=IOResult;
   Reset(BF,SizeOf(BankType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(KB,Init);
     ReadBufBank(BF,KB,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With KB^.Point.Dat[cc] Do
      Begin
          Format(FullName,CAll);
          DelSpaceRight(FullName);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+FullName;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(KB,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
  End;

NoInfoMsg;


End;



End;


Procedure RefreshCash;{точечное сканирование и обновление отдельных разделов}
Var c : Word;
    BE : PBufBazType;
    BF : File;
    st : ArtikulStr;
    i : Word;
    count,cc : Word;
    s : String;
    SMain,SMarket,
    SEnableDebit,
    SVidNalog,SVidNDS,
    SEnableContract,
    SOtdel,SRecalc,SEmploy,SOKP,SBuchGroup,SEnablePrihod,
    SEnableSklads:AllStr;
    L : LongInt;
    FFF : ^Integer;
    R : RazdelFileType;
    RE : RazdelType;
    OldFileMode : Word;
    Fm : File;
    M : PBufMarkaType;
    SM : PBufSpecMarkaType;
    GTD : PBufNGTDType;
    KS : PBufKSertifType;
    KB : PBufBankType;
    KC : PBufClassificatorBuchType;
    Ex : PBufExpertType;
    Ps : PBufPostType;
    Gr : PBufGroupType;
    SKod : ArtikulStr;
    Mr : PBufMeraType;
    FP : PBufFirmaPostType;
    Max,Index : Word;
Begin
  If EnableCashe=1 Then
Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Max:=0;
Assign(R,Path^.DAt.ToRazdel+'razdel.db');
L :=IOResult;
Reset(R);
L :=IOResult;
 FileMode:=OldFileMode;
If L=0 Then
Begin
While Not(Eof(R)) Do
{For c:=0 To 99 Do}
 Begin
  if (Desktop^.Current=Nil) Then
  DInfoMsgShkala('Минуточку. Обновляю информацию ...',0,FileSize(r),FilePos(R));
  Read(R,RE);
  If RE.CAshe=1 Then
Begin
  c:=StrToInt(RE.Kod);
  st:=IntToStr(C,CMantissa);
  RFormatZerro(st,CMantissa);
{For c:=0 To 99 Do}
  {If FileExists(Path^.Dat.ToName+st+'.id') Then}


 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.TOName+st+'.id');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not CasheTovarList[c].Employ) Or
      (CasheTovarList[c].Time<>{GetFileTime(Path^.Dat.ToName+st+'.id')}L) Then
   Begin
   CasheTovarList[c].Time:=L;
   CasheTovarList[c].Last:=L;
   {Writeln(CasheTovarList[c].Time,' ',l);}
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToName+st+'.id');
   i:=IOResult;
   Reset(BF,SizeOf(BazType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     CasheTovarList[c].Tovar^.NewList(Nil);
     CasheTovarList[c].Tovar^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(BE,Init);
     ReadBufBaz(BF,BE,Count);
     cc:=IOResult;

For cc:=1 To Count Do
Begin
     {If BE^.Point.Dat[cc].Employ Then}
     With BE^.Point.Dat[cc] Do
      Begin
          Format(Name,CNAme);
          Format(Name2,CNAme);
          DelSpaceRight(Name2);
          Format(Litr,CLitr);
          Format(InPack,CInPack);
          Format(InPack2,CInPack);
          Format(Massa,CMAssa);
          Format(Etil,CLitr);
          Format(Nalog,CLitr);
          Format(NDS,CLitr);
          RFormatZerro(Mera,CClientKod);
          RFormatZerro(NGroupKod,CClientKod);
          Format(Contract,CContract);
          Format(ContractDate,CDate);
          Format(DSertif,CDate);
          Format(DVidan,CDate);

          Format(Marker,CLitrMantissa);
          Format(Min,CArtikul);
          SRecalc:=IntToStr(Recalc,COne);
          SOtdel :=IntToStr(Otdel,CArtikul);
          Format(SOtdel,CArtikul);

          RFormatZerro(BazKod,CArtikul);
          RFormatZerro(FantomKod,CArtikul);
          RFormatZerro(PostKod,CClientKod);
          RFormatZerro(FirmaPostKod,CClientKod);
          RFormatZerro(KSertif,CClientKod);
          RFormatZerro(Class,CClientKod);
          RFormatZerro(Caption,CRazdelKod);
          RFormatZerro(MetroKod,CMetroKod);
          SMain  :=IntToStr(Main,COne);
          SMarket:=IntToStr(Market,COne);
          SEnableDebit:=IntToStr(EnableDebit,COne);
          SVidNalog:=IntToStr(VidNalog,COne);
          SVidNDS  :=IntToStr(VidNDS,COne);
          SEnableContract:=IntToStr(EnableContract,COne);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

          SOKP   :=IntToStr(OKP,9);
          SBuchGroup :=IntToStr(BuchGroup,9);
          SEnableSklads:=IntToStr(EnableSklads,10);
          SEnablePrihod:=IntToStr(Prihod,COne);

          Format(SOKP,9);
          Format(SBuchGroup,9);
          Format(SEnableSklads,10);
          RFormatZerro(MetroKod,CMetroKod);
          RFormatZerro(Class,CClientKod);


       s:='│'+
	     BazKod+'│'+
          FantomKod+'│'+
          Litr+'│'+
          InPack+'│'+
          InPack2+'│'+
          Massa+'│'+
          Etil+'│'+
          Nalog+'│'+
          NDS+'│'+
          Mera+'│'+
          Contract+'│'+
          ContractDate+'│'+
          DSertif+'│'+
          PostKod+'│'+
          FirmaPostKod+'│'+
          KSertif+'│'+
          Caption+'│'+
          SMain+'│'+
          SMarket+'│'+
          SEnableDebit+'│'+
          SVidNalog+'│'+
          SVidNDS+'│'+
          SEnableContract+'│'+
          SEmploy+'│'+
          SOKP+'│'+
          SBuchGroup+'│'+
          SEnableSklads+'│'+
		NGroupKod+'│'+
		SEnablePrihod+'│'+
          SOtdel+'│'+
          Marker+'│'+
          Min+'│'+
          Class+'│'+
          SRecalc+'│'+
          DVidan+'│'+
          MetroKod+'│'+
	     Name+'│'+
          Name2;


          {If Max<(Length(s)) Then Max:=Length(s);}



       CasheTovarList[c].Tovar^.List^.Insert(NewStr(s));
       CasheTovarList[c].Tovar^.SetRange(CasheTovarList[c].Tovar^.List^.Count);

      End;{With}
End;{For cc}
     Dispose(BE,Done);

      End;{While}

     CasheTovarList[c].Refresh:=True;
     CasheTovarList[c].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End{FileExist}
 End;{For}
End;
End;
 { отладочная печать для контроля длины строки

 Writeln(Max);
 Readln;
 }
 NoInfoMsg;
 Close(R);
 GlobalTime:=TimeStringToTime('hh:mm:ss',Times);
End;


If Compress=1 Then {разрешено кэширование справочников гтд акц и всякой хери}
Begin
if (Desktop^.Current=Nil) Then
DInfoMsg('Минуточку. Загружаю справочники....',False);

{чтение акцизных марок}
 Index:=1;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'marka.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'marka.db');
   i:=IOResult;
   Reset(BF,SizeOf(MarkaType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(M,Init);
     ReadBufMarka(BF,M,Count);
     cc:=IOResult;
     For cc:=1 To Count Do
    Begin
      With M^.Point.Dat[cc] Do
      Begin
          Format(Marka,CMarka);
          DelSpaceRight(Marka);
          RFormatZerro(Kod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+Kod+'│'+SEmploy+'│'+Marka;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
    End;{For cc}
     Dispose(M,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;{старт обновления если время разное}
  End;{l=0}


{чтение ГТД}
 Index:=2;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'ngtd.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'ngtd.db');
   i:=IOResult;
   Reset(BF,SizeOf(ngtdType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(GTD,Init);
     ReadBufngtd(BF,GTD,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With GTD^.Point.Dat[cc] Do
      Begin
          Format(ngtd,Cngtd);
          DelSpaceRight(ngtd);
          RFormatZerro(Kod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+Kod+'│'+SEmploy+'│'+ngtd;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(GTD,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;


{чтение  экспертных заключений}
 Index:=3;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'Expert.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'Expert.db');
   i:=IOResult;
   Reset(BF,SizeOf(ExpertType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(Ex,Init);
     ReadBufExpert(BF,Ex,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With Ex^.Point.Dat[cc] Do
      Begin
          Format(Expert,CExpert);
          DelSpaceRight(Expert);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+Expert;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(Ex,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;




{чтение спец.марок}
 Index:=4;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'SMarka.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'SMarka.db');
   i:=IOResult;
   Reset(BF,SizeOf(SpecMarkaType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(SM,Init);
     ReadBufSpecMarka(BF,SM,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With SM^.Point.Dat[cc] Do
      Begin
          Format(SpecMarka,CSpecMarka);
          DelSpaceRight(SpecMarka);
          RFormatZerro(Kod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+Kod+'│'+SEmploy+'│'+SpecMarka;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);

      End;{With}
End;{For cc}
     Dispose(SM,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;



{чтение органов сертификации}
 Index:=5;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'ksertif.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'ksertif.db');
   i:=IOResult;
   Reset(BF,SizeOf(KSertifType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(KS,Init);
     ReadBufKSertif(BF,KS,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With KS^.Point.Dat[cc] Do
      Begin
          Format(KSertif,CKSertif);
          DelSpaceRight(KSertif);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+KSertif;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(KS,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;

{чтение стран}
 Index:=6;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'Lands.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'Lands.db');
   i:=IOResult;
   Reset(BF,SizeOf(PostType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(PS,Init);
     ReadBufPost(BF,PS,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With PS^.Point.Dat[cc] Do
      Begin
          Format(Post,CPost);
          DelSpaceRight(Post);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+Post;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(PS,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;

{чтение Фирм-производителей}
 Index:=7;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'firma.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'firma.db');
   i:=IOResult;
   Reset(BF,SizeOf(FirmaPostType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(FP,Init);
     ReadBufFirmaPost(BF,FP,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With FP^.Point.Dat[cc] Do
      Begin
          Format(FirmaPost,CFirmaPost);
          DelSpaceRight(FirmaPost);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+sKod+'│'+SEmploy+'│'+FirmaPost;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(FP,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;


{чтение единиц измерения}
 Index:=8;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'mera.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'mera.db');
   i:=IOResult;
   Reset(BF,SizeOf(MeraType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(Mr,Init);
     ReadBufMera(BF,Mr,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With Mr^.Point.Dat[cc] Do
      Begin
          Format(Mera,CMera);
          DelSpaceRight(Mera);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+Mera;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(Mr,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;

{чтение групп продаж}
 Index:=9;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'Group.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'Group.db');
   i:=IOResult;
   Reset(BF,SizeOf(GroupType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(Gr,Init);
     ReadBufGroup(BF,Gr,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With Gr^.Point.Dat[cc] Do
      Begin
          Format(GroupName,CName);
          DelSpaceRight(GroupName);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+GroupName;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(Gr,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;

{регионы и маршруты пока не делаем}

{чтение органов сертификации}
 Index:=12;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'class.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'class.db');
   i:=IOResult;
   Reset(BF,SizeOf(ClassificatorBuchType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(KC,Init);
     ReadBufClass(BF,KC,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With KC^.Point.Dat[cc] Do
      Begin
          Format(Name,CSertif);
          DelSpaceRight(Name);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+Name;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(KC,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;

{чтение органов сертификации}
 Index:=13;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'banks.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'banks.db');
   i:=IOResult;
   Reset(BF,SizeOf(BankType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(KB,Init);
     ReadBufBank(BF,KB,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With KB^.Point.Dat[cc] Do
      Begin
          Format(FullName,CAll);
          DelSpaceRight(FullName);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+FullName;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(KB,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;

NoInfoMsg;
 GlobalTime:=TimeStringToTime('hh:mm:ss',Times);
End;

End;





Function ReadCash(Art:ArtikulStr; Var E: BazType):Boolean;{чтение данных и кэша}
Var Index,c : Word;
    R : TRect;
    SIndex,St : ArtikulStr;
    s : String;
    fid : File;
    FFF : ^Integer;{Handler}
    l : LongInt;
    OldFileMode:Word;
Begin
  ReadCash:=False;

  If EnableCashe=0 Then Exit;

  st:=Copy(Art,1,CRAzdelKod);
  c:= StrToInt(St);
  RFormatZerro(st,CMantissa);


  If Not CasheTovarList[c].Employ Then
   Begin
   Exit; {раздела пока нет в кэше}
   End;


  If Not CasheTovarList[c].Refresh Then {актуальность кэша утрачена}
   Begin
   Exit; {раздела пока нет в кэше}
   End;



 If Abs(CurrentTime-CasheTovarList[c].Last)>TimeActualCash Then
 Begin
 {Writeln(IntToStr(CurrentTime,9)+' '+IntToStr(CasheTovarList[c].Last,9));}
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(fId,Path^.Dat.TOName+st+'.id');
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 Close(fid);

  If (CasheTovarList[c].Time<>l{GetFileTime(Path^.Dat.ToName+st+'.id')}) Then
   Begin
    CasheTovarList[c].Refresh:=False;
    Exit; {раздела пока нет в кэше}
   End
  Else
  CasheTovarList[c].Last:=CurrentTime;
 End;



  SIndex:=Copy(Art,3,3);
  Index:=StrToInt(SIndex);

  If CasheTovarList[c].Tovar^.List^.Count<Index Then
   Begin
    Exit; {раздела пока нет в кэше}
   End;

  s:=CasheTovarList[c].Tovar^.GetText(Index,CasheTovarList[c].Tovar^.List^.Count);


  ReadCash:=True;

  Inc(CashCount);
  With E Do
   Begin
    BazKod:=Art;
    FantomKod:=Copy(s,1+1+CArtikul+1,CArtikul);
    Litr:=Copy(s,1+1+CArtikul+1+CArtikul+1,CLitr);
    DelSpaceRight(Litr);
    InPAck:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1,CInPack);
    DelSpaceRight(InPack);
    InPAck2:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1,CInPack);
    DelSpaceRight(InPack2);
    Massa:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1,CMassa);
    DelSpaceRight(Massa);
    Etil:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1,CLitr);
    DelSpaceRight(Etil);
    Nalog:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1,CLitr);
    DelSpaceRight(Nalog);
    NDS:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1,CLitr);
    DelSpaceRight(NDS);
    Mera:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+1,
    CClientKod);
    DelSpaceRight(Mera);
    RFormatZerro(Mera,CClientKod);
    Contract:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+
    CLitr+1+CClientKod+1,CContract);
    DelSpaceRight(Contract);
    ContractDate:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+
    CLitr+1+CClientKod+1+CContract+1,CDate);
    DelSpaceRight(ContractDate);
    DSertif:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+1+
    CClientKod+1+CContract+1+CDate+1,CDate);
    DelSpaceRight(DSertif);
    PostKod:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+1+
    CClientKod+1+CContract+1+CDate+1+CDate+1,CClientKod);

    FirmaPostKod:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+
    1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1,CClientKod);

    KSertif:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+
    1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1,CClientKod);

    Caption:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+
    1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1,CRazdelKod);
    {
    Caption:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+
    1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1,CRazdelKod);
    }
    Main:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+CLitr+
    1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1,COne));

    Market:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+
    CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1,COne));

    EnableDebit:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1,
    COne));

    VidNalog:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+
    CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+COne+1,
    COne));

    VidNDS:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+CLitr+1+
    CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+COne+1+
    COne+1,COne));

    EnableContract:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1,COne));

    If StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1,COne))=1 Then Employ:=True
    Else Employ:=False;

    OKP:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1,9));

    BuchGroup:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1,9));

    EnableSklads:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1,10));

    NGroupKod:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1,CClientKod);

    Prihod:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1,COne));


    Otdel:=StrToInt(Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1,CArtikul));

    Marker:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1+CArtikul+1,CLitrMantissa);
    DelSpaceRight(Marker);

    Min:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1+CArtikul+1+CLitrMantissa+1,CArtikul);
    DelSpace(Min);


    Class:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1+CArtikul+1+CLitrMantissa+1+CArtikul+1,CClientKOd);
    RFormatZerro(Class,CClientKod);

(*
          SOtdel+'│'+{CArtikul}
          Marker+'│'+{CLitrMantissa}
          Min+'│'+{CArtikul}

          Format(Marker,CLitrMantissa);
          Format(Min,CArtikul);
          SOtdel :=IntToStr(Otdel,CArtikul);
          Format(SOtdel,CArtikul);
*)



    Recalc:=StrToInt(
    Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1+CArtikul+1+CLitrMantissa+1+CArtikul+1+CClientKod+1,
    COne));


    DVidan:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1+CArtikul+1+CLitrMantissa+1+CArtikul+1+CClientKod+1+
    COne+1,CDate);

    MetroKod:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1+CArtikul+1+CLitrMantissa+1+CArtikul+1+CClientKod+1+
    COne+1+CDate+1,CMetroKod);

    Name:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1+CArtikul+1+CLitrMantissa+1+CArtikul+1+CClientKod+1+
    COne+1+CDate+1+CMetroKod+1,CName);
    DelSpaceRight(Name);


    Name2:=Copy(s,1+1+CArtikul+1+CArtikul+1+CLitr+1+CInPack+1+CInPack+1+CMassa+1+CLitr+1+
    CLitr+1+CLitr+1+CClientKod+1+CContract+1+CDate+1+CDate+1+CClientKod+1+CClientKod+1+CClientKod+1+CRazdelKod+1+COne+1+COne+1+
    COne+1+COne+1+COne+1+COne+1+COne+1+9+1+9+1+10+1+CClientKod+1+COne+1+CArtikul+1+CLitrMantissa+1+CArtikul+1+CClientKod+1+
    COne+1+CDate+1+CMetroKod+1+CName+1,CName);
    DelSpaceRight(Name2);




   End;

  {элемента нет в списке аналог позиция вне файла - какая-то кривизна}

{проверить актуальность данных в кэше
 да начинаем искать
 нет выход и нужно искать по сети}
End;




Function ReadCashSPR(Base:Word;Art:ArtikulStr; Var s: TMyString):Boolean;{чтение данных и кэша}
Var Index : Word;
    R : TRect;
    SIndex,St : String;
    fid : File;
    FFF : ^Integer;{Handler}
    k,l : LongInt;
    OldFileMode:Word;

Begin
  ReadCashSpr:=False;
  s[0]:=#0;

  If Not(Base in[bMarka,bNgtd,bExpert,bSMarka,bKSertif,bBank,
                 bLands,bFirma,bMera,bGroup,bRoute,bRegion,bClass]) Then
			   Begin
 			    Exit;
                  End;


  If Compress=0 Then Exit;


  If Not SprList[Base].Employ Then
   Begin
    Exit; {раздела пока нет в кэше}
   End;


  If Not SprList[Base].Refresh Then {актуальность кэша утрачена}
   Begin
   Exit; {раздела пока нет в кэше}
   End;



 If Abs(CurrentTime-SPRList[Base].Last)>TimeActualCash Then
 Begin
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Case Base Of
  bMarka:st:='marka.db';
   bNgtd:st:='ngtd.db';
 bExpert:st:='expert.db';
 bSMarka:st:='smarka.db';
bKSertif:st:='ksertif.db';
  bLands:st:='lands.db';
  bFirma:st:='firma.db';
   bMera:st:='mera.db';
  bGroup:st:='group.db';
  bRoute:st:='route.db';
 bRegion:st:='region.db';
  bClass:st:='class.db';
   bBank:st:='banks.db';
 Else
  Begin
   Exit;
  End;
 End;

 Assign(fId,Path^.Dat.ToSPR+st);
 l:=IOResult;
 Reset(fid);
 l:=IOResult;
 FileMode:=OldFileMode;
 FFF:=@FID;
 l:=GetFTime(FFF^);
 Close(fid);
 k:=IoResult;

  If (SPRList[Base].Time<>l{GetFileTime(Path^.Dat.ToName+st+'.id')}) Then
   Begin
    SprList[Base].Refresh:=False;
    Exit; {раздела пока нет в кэше}
   End
  Else SprList[Base].Last:=CurrentTime;
 End;



  Index:=StrToInt(Art);


  If SprList[Base].Elements^.List^.Count<Index Then
   Begin
    Exit; {раздела пока нет в кэше}
   End;

  s:=SprList[Base].Elements^.GetText(Index,SprList[Base].Elements^.List^.Count);



  {проверяем employ
   если False тогда выход с пустым значением s и ReadCashSpr=False
   иначе возвращаем значение в s}



  st:=Copy(s,1+1,CArtikul);


  If StrToInt(st)<>StrToInt(Art) Then
   Begin
    {MessageBox(^M+#3'Ошибка чтения кеша база'+IntToStr(Base,CKOl)+'-'+IntToStr(Index,CKol),Nil,mfError+mfCancelButton);}
    s[0]:=#0;
    Exit;
   End;

  st:=Copy(s,1+1+CArtikul+1,COne);

  If StrToInt(st)=0 Then{Employ = False}
   Begin
    s[0]:=#0;
    Exit;
   End;

  s:=Copy(s,1+1+CArtikul+1+COne+1,CSpecMarka);

  ReadCashSpr:=True;
  Inc(CashCountSpr);


  {элемента нет в списке аналог позиция вне файла - какая-то кривизна}

{проверить актуальность данных в кэше
 да начинаем искать
 нет выход и нужно искать по сети}
End;



Procedure DestroyCash;{уничтожение кэша только при выходе или смене объекта}
Var c : Word;
Begin
For c:=0 To 99 Do
 Begin
  Dispose(CasheTovarList[c].Tovar,Done);
 End;


For c:=1 To 13 Do
 Begin
  Dispose(SprList[c].Elements,Done);
 End;

End;





Procedure RefreshCashOneRazdel(Art:ArtikulStr);{точечное сканирование и обновление отдельных разделов}
Var c : Word;
    BE : PBufBazType;
    BF : File;
    st : ArtikulStr;
    i : Word;
    count,cc : Word;
    s : String;
    SMain,SMarket,
    SEnableDebit,
    SVidNalog,SVidNDS,
    SEnableContract,
    SEmploy,SOKP,SBuchGroup,SEnablePrihod,SOtdel,
    SRecalc,SEnableSklads:AllStr;
    L : LongInt;
    FFF : ^Integer;
    R : RazdelFileType;
    RE : RazdelType;
    OldFileMode : Word;
    Fm : File;
    M : PBufMarkaType;
    SM : PBufSpecMarkaType;
    GTD : PBufNGTDType;
    KS : PBufKSertifType;
    Ex : PBufExpertType;
    Ps : PBufPostType;
    Gr : PBufGroupType;
    SKod : ArtikulStr;
    Mr : PBufMeraType;
    FP : PBufFirmaPostType;
    Index : Word;
Begin
 if (Desktop^.Current=Nil) Then DInfoMsg('Минуточку...',False);

  If EnableCashe=1 Then
Begin
  c:=StrToInt(Copy(Art,1,CRazdelKod));
  st:=IntToStr(C,CMantissa);
  RFormatZerro(st,CMantissa);

 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.TOName+st+'.id');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OldFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   {If (Not CasheTovarList[c].Employ)Then}
   Begin
   CasheTovarList[c].Time:=L;
   CasheTovarList[c].Last:=L;
   {Writeln(CasheTovarList[c].Time,' ',l);}
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToName+st+'.id');
   i:=IOResult;
   Reset(BF,SizeOf(BazType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     CasheTovarList[c].Tovar^.NewList(Nil);
     CasheTovarList[c].Tovar^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(BE,Init);
     ReadBufBaz(BF,BE,Count);
     cc:=IOResult;

For cc:=1 To Count Do
Begin
     {If BE^.Point.Dat[cc].Employ Then}
     With BE^.Point.Dat[cc] Do
      Begin
          Format(Name,CNAme);
          Format(Name2,CNAme);
          DelSpaceRight(NAme2);
          Format(Litr,CLitr);
          Format(InPack,CInPack);
          Format(InPack2,CInPack);
          Format(Massa,CMAssa);
          Format(Etil,CLitr);
          Format(Nalog,CLitr);
          Format(NDS,CLitr);
          RFormatZerro(Mera,CClientKod);
          RFormatZerro(NGroupKod,CClientKod);
          Format(Contract,CContract);
          Format(ContractDate,CDate);
          Format(DSertif,CDate);
          Format(DVidan,CDate);

          Format(Marker,CLitrMantissa);
          Format(Min,CArtikul);
          SOtdel :=IntToStr(Otdel,CArtikul);
          Format(SOtdel,CArtikul);

          SRecalc :=IntToStr(Recalc,COne);
          Format(SRecalc,COne);

          RFormatZerro(BazKod,CArtikul);
          RFormatZerro(FantomKod,CArtikul);
          RFormatZerro(PostKod,CClientKod);
          RFormatZerro(FirmaPostKod,CClientKod);
          RFormatZerro(KSertif,CClientKod);
          RFormatZerro(Class,CClientKod);
          RFormatZerro(Caption,CRazdelKod);
          RFormatZerro(MetroKod,CMetroKod);
          SMain  :=IntToStr(Main,COne);
          SMarket:=IntToStr(Market,COne);
          SEnableDebit:=IntToStr(EnableDebit,COne);
          SVidNalog:=IntToStr(VidNalog,COne);
          SVidNDS  :=IntToStr(VidNDS,COne);
          SEnableContract:=IntToStr(EnableContract,COne);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

          SOKP   :=IntToStr(OKP,9);
          SBuchGroup :=IntToStr(BuchGroup,9);
          SEnableSklads:=IntToStr(EnableSklads,10);

          Format(SOKP,9);
          Format(SBuchGroup,9);
          Format(SEnableSklads,10);
          SEnablePrihod:=IntToStr(EnablePrihod,COne);

          RFormatZerro(Class,CClientKod);


       s:='│'+
	     BazKod+'│'+
          FantomKod+'│'+
          Litr+'│'+
          InPack+'│'+
          InPack2+'│'+
          Massa+'│'+
          Etil+'│'+
          Nalog+'│'+
          NDS+'│'+
          Mera+'│'+
          Contract+'│'+
          ContractDate+'│'+
          DSertif+'│'+
          PostKod+'│'+
          FirmaPostKod+'│'+
          KSertif+'│'+
          Caption+'│'+
          SMain+'│'+
          SMarket+'│'+
          SEnableDebit+'│'+
          SVidNalog+'│'+
          SVidNDS+'│'+
          SEnableContract+'│'+
          SEmploy+'│'+
          SOKP+'│'+
          SBuchGroup+'│'+
          SEnableSklads+'│'+
		NGroupKod+'│'+
		SEnablePrihod+'│'+
          SOtdel+'│'+
          Marker+'│'+
          Min+'│'+
          Class+'│'+
          SRecalc+'│'+
          DVidan+'│'+
          MetroKod+'│'+
		Name+'│'+
          Name2;

       CasheTovarList[c].Tovar^.List^.Insert(NewStr(s));
       CasheTovarList[c].Tovar^.SetRange(CasheTovarList[c].Tovar^.List^.Count);

       {
       If BE^.Point.Dat[cc].BazKod=Art Then
        Begin
         Writeln(Art);
         Writeln(s);
        End;
       }

      End;{With}
End;{For cc}
     Dispose(BE,Done);

      End;{While}

     CasheTovarList[c].Refresh:=True;
     CasheTovarList[c].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End{FileExist}
 End;{For}
 NoInfoMsg;
 Close(R);
End;



Procedure RefreshCashOneSPR(Base:Word);{чтение данных и кэша}
Var c : Word;
    BE : PBufBazType;
    BF : File;
    st : ArtikulStr;
    i : Word;
    count,cc : Word;
    s : String;
    SMain,SMarket,
    SEnableDebit,
    SVidNalog,SVidNDS,
    SEnableContract,
    SEmploy,SOKP,SBuchGroup,SEnablePrihod,
    SEnableSklads:AllStr;
    L : LongInt;
    FFF : ^Integer;
    R : RazdelFileType;
    RE : RazdelType;
    OldFileMode : Word;
    Fm : File;
    M : PBufMarkaType;
    SM : PBufSpecMarkaType;
    GTD : PBufNGTDType;
    KS : PBufKSertifType;
    KC : PBufClassificatorBuchType;
    KB : PBufBankType;
    Ex : PBufExpertType;
    Ps : PBufPostType;
    Gr : PBufGroupType;
    SKod : ArtikulStr;
    Mr : PBufMeraType;
    FP : PBufFirmaPostType;
    Index : Word;
Begin
If Compress=1 Then {разрешено кэширование справочников гтд акц и всякой хери}
Begin

  If Not(Base in[bMarka,bNgtd,bExpert,bSMarka,bKSertif,
                 bLands,bFirma,bMera,bGroup,bRoute,bRegion,bClass]) Then
			   Begin
 			    Exit;
                  End;

if (Desktop^.Current=Nil) Then DInfoMsg('Минуточку. Перезагружаю справочники....',False);

{чтение акцизных марок}
 Case Base Of
bMarka:Begin
 Index:=1;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'marka.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'marka.db');
   i:=IOResult;
   Reset(BF,SizeOf(MarkaType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(M,Init);
     ReadBufMarka(BF,M,Count);
     cc:=IOResult;
     For cc:=1 To Count Do
    Begin
      With M^.Point.Dat[cc] Do
      Begin
          Format(Marka,CMarka);
          DelSpaceRight(Marka);
          RFormatZerro(Kod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+Kod+'│'+SEmploy+'│'+Marka;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
    End;{For cc}
     Dispose(M,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;{старт обновления если время разное}
  End;{l=0}
  End;{0 Case}

BNGTD:
 Begin
{чтение ГТД}
 Index:=2;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'ngtd.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'ngtd.db');
   i:=IOResult;
   Reset(BF,SizeOf(ngtdType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(GTD,Init);
     ReadBufngtd(BF,GTD,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With GTD^.Point.Dat[cc] Do
      Begin
          Format(ngtd,Cngtd);
          DelSpaceRight(ngtd);
          RFormatZerro(Kod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+Kod+'│'+SEmploy+'│'+ngtd;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(GTD,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;
  End;{Case BNGTD}

BExpert:
 Begin
{чтение  экспертных заключений}
 Index:=3;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'Expert.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'Expert.db');
   i:=IOResult;
   Reset(BF,SizeOf(ExpertType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(Ex,Init);
     ReadBufExpert(BF,Ex,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With Ex^.Point.Dat[cc] Do
      Begin
          Format(Expert,CExpert);
          DelSpaceRight(Expert);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+Expert;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(Ex,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;
  End;{Case BExpert}


BSMarka:
 Begin
{чтение спец.марок}
 Index:=4;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'SMarka.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'SMarka.db');
   i:=IOResult;
   Reset(BF,SizeOf(SpecMarkaType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(SM,Init);
     ReadBufSpecMarka(BF,SM,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With SM^.Point.Dat[cc] Do
      Begin
          Format(SpecMarka,CSpecMarka);
          DelSpaceRight(SpecMarka);
          RFormatZerro(Kod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+Kod+'│'+SEmploy+'│'+SpecMarka;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);

      End;{With}
End;{For cc}
     Dispose(SM,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;
 End;{Case BSmarka}


BKSertif:
 Begin
{чтение органов сертификации}
 Index:=5;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'ksertif.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'ksertif.db');
   i:=IOResult;
   Reset(BF,SizeOf(KSertifType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(KS,Init);
     ReadBufKSertif(BF,KS,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With KS^.Point.Dat[cc] Do
      Begin
          Format(KSertif,CKSertif);
          DelSpaceRight(KSertif);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+KSertif;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(KS,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;
 End;{BKSertif}

BLands:Begin
{чтение стран}
 Index:=6;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'Lands.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'Lands.db');
   i:=IOResult;
   Reset(BF,SizeOf(PostType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(PS,Init);
     ReadBufPost(BF,PS,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With PS^.Point.Dat[cc] Do
      Begin
          Format(Post,CPost);
          DelSpaceRight(Post);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+Post;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(PS,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;
 End;{Case BPost}

BFirma:
 Begin
{чтение Фирм-производителей}
 Index:=7;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'firma.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'firma.db');
   i:=IOResult;
   Reset(BF,SizeOf(FirmaPostType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(FP,Init);
     ReadBufFirmaPost(BF,FP,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With FP^.Point.Dat[cc] Do
      Begin
          Format(FirmaPost,CFirmaPost);
          DelSpaceRight(FirmaPost);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+sKod+'│'+SEmploy+'│'+FirmaPost;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(FP,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;
  End;{Case BFirma}


BMera:
 Begin
{чтение единиц измерения}
 Index:=8;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'mera.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'mera.db');
   i:=IOResult;
   Reset(BF,SizeOf(MeraType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(Mr,Init);
     ReadBufMera(BF,Mr,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With Mr^.Point.Dat[cc] Do
      Begin
          Format(Mera,CMera);
          DelSpaceRight(Mera);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+Mera;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(Mr,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;
 End;{Case BMera}

BGroup:
 Begin
{чтение групп продаж}
 Index:=9;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'Group.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'Group.db');
   i:=IOResult;
   Reset(BF,SizeOf(GroupType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(Gr,Init);
     ReadBufGroup(BF,Gr,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With Gr^.Point.Dat[cc] Do
      Begin
          Format(GroupName,CName);
          DelSpaceRight(GroupName);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+GroupName;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(Gr,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;
End;{Case BGroup}

BClass:
 Begin
{чтение органов сертификации}
 Index:=12;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'class.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'class.db');
   i:=IOResult;
   Reset(BF,SizeOf(ClassificatorBuchType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(KC,Init);
     ReadBufClass(BF,KC,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With KC^.Point.Dat[cc] Do
      Begin
          Format(Name,CSertif);
          DelSpaceRight(NAme);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+Name;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(KC,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;
 End;{BClass}

BBank:
 Begin
{чтение органов сертификации}
 Index:=13;
 OldFileMode:=FileMode;
 FileMode:=LocalReadOnlyN;
 Assign(BF,Path^.Dat.ToSPR+'banks.db');
 l:=IOResult;
 Reset(BF);
 l:=IOResult;
 FileMode:=OLDFileMode;
 If l=0 Then
  Begin
    FFF:=@BF;
    l:=GetFTime(FFF^);
    l:=IOResult;
    l:=GetFTime(FFF^);
    Close(BF);
   If (Not SPRList[index].Employ) Or (SPRList[Index].Time<>L) Then
   Begin
   SprList[Index].Time:=L;
   SprList[Index].Last:=L;
   OldFileMode:=FileMode;
   FileMode:=LocalReadOnlyN;
   Assign(BF,Path^.Dat.ToSPR+'banks.db');
   i:=IOResult;
   Reset(BF,SizeOf(BankType));
   i:=IOResult;
   FileMode:=OldFileMode;
   If i=0 Then
    Begin
     SprList[index].Elements^.NewList(Nil);
     SprList[index].Elements^.NewList(New(PMyCollection, Init(0,50)));
     While Not(Eof(bf)) Do
      Begin
     Count:=0;
     New(KB,Init);
     ReadBufBank(BF,KB,Count);
     cc:=IOResult;
For cc:=1 To Count Do
Begin
     With KB^.Point.Dat[cc] Do
      Begin
          Format(FullName,CAll);
          DelSpaceRight(FullNAme);
          SKod:=Kod;
          RFormatZerro(SKod,CArtikul);
          If Employ Then SEmploy:='1' Else SEmploy:='0';

       s:='│'+SKod+'│'+SEmploy+'│'+FullName;

       SprList[index].Elements^.List^.Insert(NewStr(s));
       SprList[index].Elements^.SetRange(SprList[Index].Elements^.List^.Count);
      End;{With}
End;{For cc}
     Dispose(KB,Done);
      End;{While}

     SprList[index].Refresh:=True;
     SprList[index].Employ:=True;
     i:=IOResult;
     Close(BF);
     i:=IOResult;
    End;{IORESULT}
   End;
  End;
 End;{BClass}



Else;
End;
{регионы и маршруты пока не делаем}
NoInfoMsg;
End;
End;








(*

Procedure TestDialogList;
var
  Dlg : PDialog;
  R : TRect;
  Control : PView;
  ControlTest: PView;
  A : PbxCheckListBox;
  count,c : Word;
  CLF : File;
  CLE : PBufKurzClientType;
  st1 : AllStr;
  Test : LongInt;

begin
R.Assign(10, 2, 50, 18);
New(Dlg, Init(R, 'test'));
Dlg^.HelpCtx:=$E002;


R.Assign(1, 1, 39, 10);
A := New(PbxCheckListBox, Init(R, 3, Nil));
A^.NewList(New(PBxCollection, Init(1,1)));


Assign (ClF,Path^.Dat.ToClientBaseIndex+'Sklad.idx');
Reset (ClF,SizeOf(KurzClientType));
c:=IOResult;
FileMode:=OldFileMode;
If c=0 Then
Begin
{AInfo('Обновляю списки клиентов...');}
While Not(Eof(ClF)) Do
 Begin
    DInfoMsgShkala('Читаю списки контрагентов. Ждите... ',0,FileSize(CLF),FilePos(CLF));

    New(CLE,Init);
    ReadBufKurzClient(Clf,CLE,Count);
  For c:=1 To Count Do
  Begin
  If ClE^.Point.Dat[c].Employ Then
   Begin
    Format (ClE^.Point.Dat[c].Name,CClient);
    St1:=IntToStr(ClE^.Point.Dat[c].Kod,CClientKod);
    RFormatZerro(St1,CMantissa);

    A^.List^.Insert(New(PbxSelectStr,Init({ClE^.Point.Dat[c].Name+'│'+}st1)));
    A^.SetRange(A^.List^.Count);
   End;
  End;{For}
   Dispose(CLE,Done);
 End;{While}
NoInfoMsg;
System.Close(ClF);
End;

A^.SetSelectSet([0,15,4]);


R.Assign(12, 13, 24, 15);
ControlTest := New(PCheckboxes, Init(R,
  NewSItem('Label1',
  NewSItem('Label2', Nil))));
Dlg^.Insert(ControlTest);


Test :=737000;
ControlTest^.SetData(Test);



Dlg^.Insert(a);

Dlg^.SelectNext(False);
c:=Desktop^.ExecView(Dlg);

ControlTest^.GetData(Test);
MemC(IntToStr(Test,CKol));
Dispose(a^.List,Done);
Dispose(a,Done);
Dispose(Dlg,Done);
end;


*)





Begin
TimeActualCash:=0;
AutoRefreshCash:=30;
CashCount:=0;
CashCountSpr:=0;
End.